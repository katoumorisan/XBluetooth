// Copyright (C) 2019. Huawei Technologies Co., Ltd. All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "cpu/general/tensor_computing_general.h"

template <typename T>
static EE scale_nchw(
    T *input, T *alpha, T *beta, U32 in, U32 ic, U32 elements_per_channel, U32 align_size, T *output)
{
    ic = ic / align_size;
    for (U32 n = 0; n < in; n++) {
        for (U32 c = 0; c < ic; c++) {
            for (U32 i = 0; i < elements_per_channel; i++) {
                for (U32 k = 0; k < align_size; k++) {
                    T alphaValue = (nullptr == alpha) ? 1 : alpha[c * align_size + k];
                    T betaValue = (nullptr == beta) ? 0 : beta[c * align_size + k];
                    U32 index = ((n * ic + c) * elements_per_channel + i) * align_size + k;
                    output[index] = alphaValue * input[index] + betaValue;
                }
            }
        }
    }
    return SUCCESS;
}

template <typename T, bool icoc_equal>
static EE scale_nhwc(
    T *input, T *alpha, T *beta, U32 in, U32 ic, U32 elements_per_channel, T *output)
{
    for (U32 n = 0, src = 0, dst = 0; n < in; n++) {
        for (U32 i = 0; i < elements_per_channel; i++, src++) {
            for (U32 c = 0; c < ic; c++, dst++) {
                T alphaValue = (nullptr == alpha) ? 1 : alpha[c];
                T betaValue = (nullptr == beta) ? 0 : beta[c];
                if (icoc_equal) {
                    output[dst] = alphaValue * input[dst] + betaValue;
                } else {
                    output[dst] = alphaValue * input[src] + betaValue;
                }
            }
        }
    }
    return SUCCESS;
}

template <typename T>
static EE scale(T *input,
    I32 axis,
    I32 nDims,
    T *alpha,
    T *beta,
    U32 on,
    U32 oc,
    U32 elements_per_channel,
    U32 align_size,
    U32 ic,
    T *output)
{
    EE ret = SUCCESS;
    if (axis == 1 || axis == 0 || oc == 1) {
        ret = scale_nchw<T>(input, alpha, beta, on, oc, elements_per_channel, align_size, output);
    } else if (axis == nDims - 1) {
        if (ic == oc) {
            ret = scale_nhwc<T, true>(input, alpha, beta, on, oc, elements_per_channel, output);
        } else {
            ret = scale_nhwc<T, false>(input, alpha, beta, on, oc, elements_per_channel, output);
        }
    } else {
        ret = NOT_SUPPORTED;
    }
    return ret;
}

EE scale_general(TensorDesc inputDesc,
    void *input,
    void *alpha,
    void *beta,
    ScaleParamSpec p,
    TensorDesc outputDesc,
    void *output)
{
    if (nullptr == input || nullptr == output) {
        CHECK_STATUS(NULL_POINTER);
    }

    U32 length = tensorNumElements(outputDesc);
    int axis = (p.axis + outputDesc.nDims) % outputDesc.nDims;
    I32 on = outputDesc.dims[outputDesc.nDims - 1];
    I32 oc = outputDesc.dims[outputDesc.nDims - 1 - axis];
    I32 ic = inputDesc.dims[inputDesc.nDims - 1 - axis];
    I32 elements_per_channel = length / (on * oc);
    I32 align_size = 1;
    if (outputDesc.df == DF_NCHWC8) {
        align_size = 8;
    }
    EE ret = SUCCESS;
    switch (outputDesc.dt) {
#ifdef _USE_FP32
        case DT_F32: {
            ret = scale<F32>((F32 *)input, axis, outputDesc.nDims, (F32 *)alpha, (F32 *)beta, on,
                oc, elements_per_channel, align_size, ic, (F32 *)output);
            break;
        }
#endif
#ifdef _USE_FP16
        case DT_F16: {
            ret = scale<F16>((F16 *)input, axis, outputDesc.nDims, (F16 *)alpha, (F16 *)beta, on,
                oc, elements_per_channel, align_size, ic, (F16 *)output);
            break;
        }
#endif
        default:
            ret = NOT_SUPPORTED;
            break;
    }

    return ret;
}
