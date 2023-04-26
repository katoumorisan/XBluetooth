// Copyright (C) 2019. Huawei Technologies Co., Ltd. All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#include "kernel_def.h"
#define MANGLE_NAME_IMPL(base, IOM, FM) base##IOM##FM
#define MANGLE_NAME(base, IOM, FM) MANGLE_NAME_IMPL(base, IOM, FM)
#define FM
#if defined(USE_NCHW)
#define FM nchw_
#endif

__kernel void MANGLE_NAME(clip_, IOM, FM)(const int iw_str,
    const int ih_str,
    const int ow_str,
    const int oh_str,
    const int i_off,
    const int o_off,
    const int w,
    const int bx,
    const int by,
    const float min_value,
    const float max_value,
    READ_ONLY_KERNEL_MEM input,
    KERNEL_MEM output)
{
    int idx = get_global_id(0);
    int idy = get_global_id(1);
    int idz = get_global_id(2);
    if (idx >= bx || idy >= by) {
        return;
    }

    T4 val;
#if defined(USE_NCHW)
    LOAD_MEM_V4_C1_COMMON(val, idx, idy, idz, iw_str, ih_str, i_off, w, input);
#else
    LOAD_MEM_V4_COMMON(val, idx, idy, idz, iw_str, ih_str, i_off, input);
#endif
    float4 val_f32;
    val_f32.s0 = (float)val.s0;
    val_f32.s1 = (float)val.s1;
    val_f32.s2 = (float)val.s2;
    val_f32.s3 = (float)val.s3;
    val_f32.s0 = clamp(val_f32.s0, min_value, max_value);
    val_f32.s1 = clamp(val_f32.s1, min_value, max_value);
    val_f32.s2 = clamp(val_f32.s2, min_value, max_value);
    val_f32.s3 = clamp(val_f32.s3, min_value, max_value);
    val.s0 = (T)val_f32.s0;
    val.s1 = (T)val_f32.s1;
    val.s2 = (T)val_f32.s2;
    val.s3 = (T)val_f32.s3;

#if defined(USE_NCHW)
    STORE_MEM_V4_C1_COMMON(val, idx, idy, idz, ow_str, oh_str, o_off, w, output);
#else
    STORE_MEM_V4_COMMON(val, idx, idy, idz, ow_str, oh_str, o_off, output);
#endif
}
