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
#define MANGLE_NAME_IMPL(base, IOM, AM, FW, FH, FT, ON) base##IOM##AM##FW##FH##FT##ON
#define MANGLE_NAME(base, IOM, AM, FW, FH, FT, ON) MANGLE_NAME_IMPL(base, IOM, AM, FW, FH, FT, ON)

#if (IN <= 4)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(v)                                     \
    {                                                     \
        LOAD_MEM_V4(v, (int4)(ix, iy + j, i * it + tt, 0), in);\
    }
#else
#define LOAD_INPUT(v)                                \
    {                                                \
        in_val = vload4(0, in_off + tt * iwh_str + j * iw_str + in);\
    }
#endif
#define UPDATE_REG_CORE(v) {\
    v.s0 = v.s1;\
    v.s1 = v.s2;\
    v.s2 = v.s3;\
}
#define UPDATE_REG UPDATE_REG_CORE(in_val)
#elif (IN <= 8)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(v)                                               \
    {                                                               \
        LOAD_MEM_V4(v.s0123, (int4)(ix, iy + j, i * it + tt, 0), in);    \
        LOAD_MEM_V4(v.s4567, (int4)(ix + 1, iy + j, i * it + tt, 0), in);\
    }
#else
#define LOAD_INPUT(v)                                \
    {                                                \
        in_val = vload8(0, in_off + tt * iwh_str + j * iw_str + in);\
    }
#endif
#define UPDATE_REG_CORE(v) {\
    v.s0 = v.s1;\
    v.s1 = v.s2;\
    v.s2 = v.s3;\
    v.s3 = v.s4;\
    v.s4 = v.s5;\
    v.s5 = v.s6;\
    v.s6 = v.s7;\
}
#define UPDATE_REG UPDATE_REG_CORE(in_val)
#elif (IN <= 16)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(v)                                               \
    {                                                               \
        LOAD_MEM_V4(v.s0123, (int4)(ix, iy + j, i * it + tt, 0), in);    \
        LOAD_MEM_V4(v.s4567, (int4)(ix + 1, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(v.s89ab, (int4)(ix + 2, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(v.scdef, (int4)(ix + 3, iy + j, i * it + tt, 0), in);\
    }
#else
#define LOAD_INPUT(v)                                 \
    {                                                 \
        in_val = vload16(0, in_off + tt * iwh_str + j * iw_str + in);\
    }
#endif
#define UPDATE_REG_CORE(v) {\
    v.s0 = v.s1;\
    v.s1 = v.s2;\
    v.s2 = v.s3;\
    v.s3 = v.s4;\
    v.s4 = v.s5;\
    v.s5 = v.s6;\
    v.s6 = v.s7;\
    v.s7 = v.s8;\
    v.s8 = v.s9;\
    v.s9 = v.sa;\
    v.sa = v.sb;\
    v.sb = v.sc;\
    v.sc = v.sd;\
    v.sd = v.se;\
    v.se = v.sf;\
}
#define UPDATE_REG UPDATE_REG_CORE(in_val)
#elif (IN <= 24)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(v)                                               \
    {                                                               \
        LOAD_MEM_V4(v.s0123, (int4)(ix, iy + j, i * it + tt, 0), in);    \
        LOAD_MEM_V4(v.s4567, (int4)(ix + 1, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(v.s89ab, (int4)(ix + 2, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(v.scdef, (int4)(ix + 3, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(in_val_ex.s0123, (int4)(ix + 4, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(in_val_ex.s4567, (int4)(ix + 5, iy + j, i * it + tt, 0), in);\
    }
#else
#define LOAD_INPUT(v)                                 \
    {                                                 \
        v = vload16(0, in_off + j * iw_str + in);\
        in_val_ex = vload8(0, in_off + j * iw_str + in + 16);\
    }
#endif
#define UPDATE_REG_CORE(v, ve) {\
    v.s0 = v.s1;\
    v.s1 = v.s2;\
    v.s2 = v.s3;\
    v.s3 = v.s4;\
    v.s4 = v.s5;\
    v.s5 = v.s6;\
    v.s6 = v.s7;\
    v.s7 = v.s8;\
    v.s8 = v.s9;\
    v.s9 = v.sa;\
    v.sa = v.sb;\
    v.sb = v.sc;\
    v.sc = v.sd;\
    v.sd = v.se;\
    v.se = v.sf;\
    v.sf = ve.s0;\
    ve.s0 = ve.s1;\
    ve.s1 = ve.s2;\
    ve.s2 = ve.s3;\
    ve.s3 = ve.s4;\
    ve.s4 = ve.s5;\
    ve.s5 = ve.s6;\
    ve.s6 = ve.s7;\
}
#define UPDATE_REG UPDATE_REG_CORE(in_val, in_val_ex)
#elif (IN <= 32)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(v)                                               \
    {                                                               \
        LOAD_MEM_V4(v.s0123, (int4)(ix, iy + j, i * it + tt, 0), in);    \
        LOAD_MEM_V4(v.s4567, (int4)(ix + 1, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(v.s89ab, (int4)(ix + 2, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(v.scdef, (int4)(ix + 3, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(in_val_ex.s0123, (int4)(ix + 4, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(in_val_ex.s4567, (int4)(ix + 5, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(in_val_ex.s89ab, (int4)(ix + 6, iy + j, i * it + tt, 0), in);\
        LOAD_MEM_V4(in_val_ex.scdef, (int4)(ix + 7, iy + j, i * it + tt, 0), in);\
    }
#else
#define LOAD_INPUT(v)                                 \
    {                                                 \
        v = vload16(0, in_off + j * iw_str + in);\
        in_val_ex = vload16(0, in_off + j * iw_str + in + 16);\
    }
#endif
#define UPDATE_REG_CORE(v, ve) {\
    v.s0 = v.s1;\
    v.s1 = v.s2;\
    v.s2 = v.s3;\
    v.s3 = v.s4;\
    v.s4 = v.s5;\
    v.s5 = v.s6;\
    v.s6 = v.s7;\
    v.s7 = v.s8;\
    v.s8 = v.s9;\
    v.s9 = v.sa;\
    v.sa = v.sb;\
    v.sb = v.sc;\
    v.sc = v.sd;\
    v.sd = v.se;\
    v.se = v.sf;\
    v.sf = ve.s0;\
    ve.s0 = ve.s1;\
    ve.s1 = ve.s2;\
    ve.s2 = ve.s3;\
    ve.s3 = ve.s4;\
    ve.s4 = ve.s5;\
    ve.s5 = ve.s6;\
    ve.s6 = ve.s7;\
    ve.s7 = ve.s8;\
    ve.s8 = ve.s9;\
    ve.s9 = ve.sa;\
    ve.sa = ve.sb;\
    ve.sb = ve.sc;\
    ve.sc = ve.sd;\
    ve.sd = ve.se;\
    ve.se = ve.sf;\
}
#define UPDATE_REG UPDATE_REG_CORE(in_val, in_val_ex)
#endif

#if defined(USE_INPUT_IMG)
#define ADD_IN_OFF
#else
#define ADD_IN_OFF in_off += iwh_str * it;
#endif

#if (ON == 2)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
    }
#elif (ON == 3)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
    }
#elif (ON == 4)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
    }
#elif (ON == 5)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
    }
#elif (ON == 6)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
    }
#elif (ON == 7)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
        C[6] += in_val.sc * B;   \
    }
#elif (ON == 8)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
        C[6] += in_val.sc * B;   \
        C[7] += in_val.se * B;   \
    }
#elif (ON == 9)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
        C[6] += in_val.sc * B;   \
        C[7] += in_val.se * B;   \
        C[8] += in_val_ex.s0 * B;\
    }
#elif (ON == 10)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
        C[6] += in_val.sc * B;   \
        C[7] += in_val.se * B;   \
        C[8] += in_val_ex.s0 * B;\
        C[9] += in_val_ex.s2 * B;\
    }
#elif (ON == 11)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
        C[6] += in_val.sc * B;   \
        C[7] += in_val.se * B;   \
        C[8] += in_val_ex.s0 * B;\
        C[9] += in_val_ex.s2 * B;\
        C[10] += in_val_ex.s4 * B;\
    }
#elif (ON == 12)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
        C[6] += in_val.sc * B;   \
        C[7] += in_val.se * B;   \
        C[8] += in_val_ex.s0 * B;\
        C[9] += in_val_ex.s2 * B;\
        C[10] += in_val_ex.s4 * B;\
        C[11] += in_val_ex.s6 * B;\
    }
#elif (ON == 13)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
        C[6] += in_val.sc * B;   \
        C[7] += in_val.se * B;   \
        C[8] += in_val_ex.s0 * B;\
        C[9] += in_val_ex.s2 * B;\
        C[10] += in_val_ex.s4 * B;\
        C[11] += in_val_ex.s6 * B;\
        C[12] += in_val_ex.s8 * B;\
    }
#elif (ON == 14)
#define calCore(B, C)            \
    {                            \
        C[0] += in_val.s0 * B;   \
        C[1] += in_val.s2 * B;   \
        C[2] += in_val.s4 * B;   \
        C[3] += in_val.s6 * B;   \
        C[4] += in_val.s8 * B;   \
        C[5] += in_val.sa * B;   \
        C[6] += in_val.sc * B;   \
        C[7] += in_val.se * B;   \
        C[8] += in_val_ex.s0 * B;\
        C[9] += in_val_ex.s2 * B;\
        C[10] += in_val_ex.s4 * B;\
        C[11] += in_val_ex.s6 * B;\
        C[12] += in_val_ex.s8 * B;\
        C[13] += in_val_ex.sa * B;\
    }
#endif
#define CALCORE_FUNC(FUNC, fv, ov) {\
    fv = vload4(flt_off, flt);\
    FUNC(fv, ov);\
    UPDATE_REG;\
    flt_off++;\
}

__kernel void MANGLE_NAME(conv_direct_3d_sw2_nchw_to_nchwc4_qc_, IOM, AM, FW, FH, FT, ON)(const int iw_str,
    const int iwh_str,
    const int ic_str,
    const int iw_off,
    const int ih_off,
    const int ow_str,
    const int oh_str,
    const int o_off,
    const int ow,
    const int ot,
    const int it,
    const int pt,
    const int sh,
    const int st,
    const int bx,
    const int by,
    READ_ONLY_KERNEL_MEM in,
    __global const T* flt,
    __read_only image1d_t bias,
    KERNEL_MEM out)
{
    const int idx = get_global_id(0);
    const int idy = get_global_id(1);
    if (idx >= bx || idy >= by) {
        return;
    }
    const int idz = get_global_id(2);
    const int idt = idz % ot;
    const int idk = idz / ot;

#if (IN <= 4)
    T4 in_val;
#elif (IN <= 8)
    T8 in_val;
#elif (IN <= 16)
    T16 in_val;
#elif (IN <= 24)
    T16 in_val;
    T8 in_val_ex;
#elif (IN <= 32)
    T16 in_val;
    T16 in_val_ex;
#endif

    T4 flt_val;
    T4 out_val[ON];

    out_val[0] = READ_IMAGE(bias, sampler, idk);
    for (uchar i = 1; i < ON; i++) {
        out_val[i] = out_val[0];
    }

#if defined(USE_INPUT_IMG)
    int ix = idx * (ON >> 1) + iw_off;
    int iy = idy * sh + ih_off;
#else
    int in_off = (idy * sh + ih_off) * iw_str + (idx << 1) * ON + iw_off;
#endif
    int flt_off = idk * ic_str * FWHT;

    int t_be = idt * st - pt;
    int t_end = t_be + FT;
    int flt_be = 0;
    int flt_end = 0;
    if (t_be < 0) {
        flt_be -= t_be * FW * FH;
        t_be = 0;
    }
    if (t_end > it) {
        flt_end = (t_end - it) * FW * FH;
        t_end = it;
    }

    for (int i = 0; i < ic_str; ++i) {
        flt_off += flt_be;
        for (int tt = t_be; tt < t_end; ++tt) {
            for (uchar j = 0; j < FH; ++j) {
                LOAD_INPUT(in_val);
                CALCORE_FUNC(calCore, flt_val, out_val);
#if (FW > 1)
                CALCORE_FUNC(calCore, flt_val, out_val);
#endif
#if (FW > 2)
                CALCORE_FUNC(calCore, flt_val, out_val);
#endif
#if (FW > 3)
                CALCORE_FUNC(calCore, flt_val, out_val);
#endif
#if (FW > 4)
                CALCORE_FUNC(calCore, flt_val, out_val);
#endif
#if (FW > 5)
                CALCORE_FUNC(calCore, flt_val, out_val);
#endif
#if (FW > 6)
                CALCORE_FUNC(calCore, flt_val, out_val);
#endif
            }
        }
        ADD_IN_OFF
        flt_off += flt_end;
    }

    int xn = idx * ON;
#if defined(USE_OUTPUT_IMG)
    for (uchar i = 0; i < ON; i++) {
        if (xn + i < ow) {
            ACTIVATION_V4(out_val[i]);
            STORE_MEM_V4(out_val[i], (int4)(xn + i, idy, idz, 0), out);
        }
    }
#else
    int out_off = (idz * oh_str + idy) * ow_str + xn + o_off;
    for (uchar i = 0; i < ON; i++) {
        if (xn + i < ow) {
            ACTIVATION_V4(out_val[i]);
            STORE_MEM_V4(out_val[i], out_off + i, out);
        }
    }
#endif
}
