// Copyright (C) 2019. Huawei Technologies Co., Ltd. All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "cpu/arm/fp32/tensor_computing_fp32.h"
#include "cpu/arm/transform_functions.h"

inline EE convolution_transform_filter_kernel_fp32(TensorDesc filterDesc,
    const F32 *filterArray,
    TensorDesc *ftmDesc,
    F32 *ftmArray,
    DataFormat ftmDataFormat)
{
    if (nullptr == filterArray || nullptr == ftmDesc || nullptr == ftmArray) {
        CHECK_STATUS(NULL_POINTER);
    }
    if (filterDesc.df == ftmDataFormat) {
        *ftmDesc = filterDesc;
        UNI_MEMCPY(ftmArray, filterArray, tensorNumBytes(filterDesc));
        return SUCCESS;
    }
    if (filterDesc.df != DF_NCHW) {
        return NOT_SUPPORTED;
    }
    EE ret = SUCCESS;
    switch (ftmDataFormat) {
        case DF_NHWCN8: {
            ret = transformNCHWToNHWCNx<F32, 8>(
                filterDesc, filterArray, ftmDataFormat, ftmDesc, ftmArray);
            break;
        }
        case DF_HWNCN8: {
            ret = transformNCHWToHWNCNx<F32, 8>(
                filterDesc, filterArray, ftmDataFormat, ftmDesc, ftmArray);
            break;
        }
        default:
            ret = NOT_SUPPORTED;
            break;
    }
    return ret;
}

EE convolution_transform_filter_fp32(TensorDesc filterDesc,
    const F32 *filter,
    ConvolutionParamSpec convParamSpec,
    ConvolutionForwardAlgorithm algorithm,
    TensorDesc *ftmDesc,
    F32 *filterTransformed)
{
    DataFormat ftmDataFormat;
    switch (algorithm) {
        case CONVOLUTION_ALGORITHM_GEMM:
            ftmDataFormat = DF_NHWCN8;
            break;
        case CONVOLUTION_ALGORITHM_GEMM_ICNCHW:
            ftmDataFormat = DF_NHWCN8;
            break;
        case CONVOLUTION_ALGORITHM_WINOGRAD:
            ftmDataFormat = DF_HWNCN8;
            break;
        default:
            return NOT_MATCH;
    }

    U32 channelAxis = filterDesc.nDims - 1;
    TensorDesc tmpFilterDesc = filterDesc;
    tmpFilterDesc.dims[channelAxis] /= convParamSpec.group;
    U32 fnPadding = tmpFilterDesc.dims[channelAxis];
    if (fnPadding % 8 != 0) {
        fnPadding = (fnPadding / 8 + 1) * 8;
    }
    U32 originalTileSize = tensorNumElements(tmpFilterDesc);
    for (U32 g = 0; g < convParamSpec.group; g++) {
        CHECK_STATUS(convolution_transform_filter_kernel_fp32(
            tmpFilterDesc, filter, ftmDesc, filterTransformed, ftmDataFormat));
        U32 newTileSize = tensorNumElements(*ftmDesc) / tmpFilterDesc.dims[channelAxis] * fnPadding;
        filter += originalTileSize;
        filterTransformed += newTileSize;
    }
    ftmDesc->dims[channelAxis] = filterDesc.dims[channelAxis];
    return SUCCESS;
}
