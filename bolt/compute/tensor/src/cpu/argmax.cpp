// Copyright (C) 2019. Huawei Technologies Co., Ltd. All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "cpu/tensor_computing_cpu.h"

template <typename T, U32 align = 1>
static U32 array_argmax(const T *input, U32 len, U32 stride)
{
    T value = input[0];
    U32 index = 0;
    for (U32 i = 0, n = 0; i < len / align; i++) {
        for (U32 j = 0; j < align; j++, n++) {
            U32 k = i * stride * align + j;
            if (input[k] > value) {
                value = input[k];
                index = n;
            }
        }
    }
    return index;
}

template <typename T>
static EE argmax(TensorDesc inputDesc, const T *input, I32 axis, TensorDesc outputDesc, U32 *output)
{
    UNUSED(outputDesc);
    if (nullptr == input || nullptr == output) {
        return NULL_POINTER;
    }
    if (axis < 0) {
        axis = inputDesc.nDims + axis;
    }
    axis = inputDesc.nDims - 1 - axis;
    U32 loopInner = 1;
    for (int i = 0; i < axis; i++) {
        loopInner *= inputDesc.dims[i];
    }
    U32 loopOuter = 1;
    for (U32 i = axis + 1; i < inputDesc.nDims; i++) {
        loopOuter *= inputDesc.dims[i];
    }
    int channel = inputDesc.nDims - 2;
    int align = 1;
    if (inputDesc.df == DF_NCHWC8) {
        align = 8;
    }
    if (inputDesc.df == DF_NCHWC16) {
        align = 16;
    }
    U32 len = inputDesc.dims[axis];
    if (axis == channel && align != 1) {
        if (inputDesc.df == DF_NCHWC8) {
            for (U32 i = 0; i < loopOuter; i++) {
                for (U32 j = 0; j < loopInner; j++) {
                    const T *array = input + i * (len * loopInner) + j * align;
                    output[i * loopInner + j] = array_argmax<T, 8>(array, len, loopInner);
                }
            }
        }
        if (inputDesc.df == DF_NCHWC16) {
            for (U32 i = 0; i < loopOuter; i++) {
                for (U32 j = 0; j < loopInner; j++) {
                    const T *array = input + i * (len * loopInner) + j * align;
                    output[i * loopInner + j] = array_argmax<T, 16>(array, len, loopInner);
                }
            }
        }
    } else {
        if (axis > channel) {
            loopOuter /= align;
            loopInner *= align;
        }
        for (U32 i = 0; i < loopOuter; i++) {
            for (U32 j = 0; j < loopInner; j++) {
                const T *array = input + i * (len * loopInner) + j;
                output[i * loopInner + j] = array_argmax<T>(array, len, loopInner);
            }
        }
    }
    return SUCCESS;
}

EE argmax_cpu(
    TensorDesc inputDesc, const void *input, ArgMaxParamSpec p, TensorDesc outputDesc, void *output)
{
    DataType idt = inputDesc.dt;
    EE ret = SUCCESS;
    int axis = p.axis;
    switch (idt) {
#ifdef _USE_FP32
        case DT_F32: {
            ret = argmax<F32>(inputDesc, (const F32 *)input, axis, outputDesc, (U32 *)output);
            break;
        }
#endif
#ifdef _USE_FP16
        case DT_F16: {
            ret = argmax<F16>(inputDesc, (const F16 *)input, axis, outputDesc, (U32 *)output);
            break;
        }
#endif
        case DT_I32: {
            ret = argmax<I32>(inputDesc, (const I32 *)input, axis, outputDesc, (U32 *)output);
            break;
        }
        default:
            ret = NOT_SUPPORTED;
            break;
    }

    return ret;
}
