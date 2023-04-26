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
static EE clip(T *input, T *output, U32 len, F32 min_value, F32 max_value)
{
    if (nullptr == input || nullptr == output) {
        CHECK_STATUS(NULL_POINTER);
    }

    for (U32 i = 0; i < len; i++) {
        F32 value = input[i];
        value = (value > min_value) ? value : min_value;
        value = (value < max_value) ? value : max_value;
        output[i] = value;
    }
    return SUCCESS;
}

EE clip_general(
    TensorDesc inputDesc, void *input, ClipParamSpec p, TensorDesc outputDesc, void *output)
{
    UNUSED(outputDesc);
    EE ret = SUCCESS;
    switch (inputDesc.dt) {
#ifdef _USE_FP32
        case DT_F32: {
            ret = clip<F32>((F32 *)input, (F32 *)output, tensorNumElements(inputDesc), p.min, p.max);
            break;
        }
#endif
#ifdef _USE_FP16
        case DT_F16: {
            ret = clip<F16>((F16 *)input, (F16 *)output, tensorNumElements(inputDesc), p.min, p.max);
            break;
        }
#endif
        default:
            ret = NOT_SUPPORTED;
            break;
    }
    return ret;
}
