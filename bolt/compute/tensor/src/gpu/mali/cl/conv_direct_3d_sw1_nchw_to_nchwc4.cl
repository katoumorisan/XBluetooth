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
#define LOAD_INPUT(off, buf)           \
    {                                  \
        in_val = vload4(0, off + buf); \
    }
#elif (IN <= 8)
#define LOAD_INPUT(off, buf)           \
    {                                  \
        in_val = vload8(0, off + buf); \
    }
#elif (IN <= 16)
#define LOAD_INPUT(off, buf)            \
    {                                   \
        in_val = vload16(0, off + buf); \
    }
#endif

#if (ON == 2)
#define calCore(a0, a1, B, C) \
    {                         \
        C[0] += a0 * B;       \
        C[1] += a1 * B;       \
    }
#define calCore0(B, C) calCore(in_val.s0, in_val.s1, B, C)
#if (FW > 1)
#define calCore1(B, C) calCore(in_val.s1, in_val.s2, B, C)
#endif
#if (FW > 2)
#define calCore2(B, C) calCore(in_val.s2, in_val.s3, B, C)
#endif
#if (FW > 3)
#define calCore3(B, C) calCore(in_val.s3, in_val.s4, B, C)
#endif
#if (FW > 4)
#define calCore4(B, C) calCore(in_val.s4, in_val.s5, B, C)
#endif
#if (FW > 5)
#define calCore5(B, C) calCore(in_val.s5, in_val.s6, B, C)
#endif
#if (FW > 6)
#define calCore6(B, C) calCore(in_val.s6, in_val.s7, B, C)
#endif
#elif (ON == 3)
#define calCore(a0, a1, a2, B, C) \
    {                             \
        C[0] += a0 * B;           \
        C[1] += a1 * B;           \
        C[2] += a2 * B;           \
    }
#define calCore0(B, C) calCore(in_val.s0, in_val.s1, in_val.s2, B, C)
#if (FW > 1)
#define calCore1(B, C) calCore(in_val.s1, in_val.s2, in_val.s3, B, C)
#endif
#if (FW > 2)
#define calCore2(B, C) calCore(in_val.s2, in_val.s3, in_val.s4, B, C)
#endif
#if (FW > 3)
#define calCore3(B, C) calCore(in_val.s3, in_val.s4, in_val.s5, B, C)
#endif
#if (FW > 4)
#define calCore4(B, C) calCore(in_val.s4, in_val.s5, in_val.s6, B, C)
#endif
#if (FW > 5)
#define calCore5(B, C) calCore(in_val.s5, in_val.s6, in_val.s7, B, C)
#endif
#if (FW > 6)
#define calCore6(B, C) calCore(in_val.s6, in_val.s7, in_val.s8, B, C)
#endif
#elif (ON == 4)
#define calCore(a0, a1, a2, a3, B, C) \
    {                                 \
        C[0] += a0 * B;               \
        C[1] += a1 * B;               \
        C[2] += a2 * B;               \
        C[3] += a3 * B;               \
    }
#define calCore0(B, C) calCore(in_val.s0, in_val.s1, in_val.s2, in_val.s3, B, C)
#if (FW > 1)
#define calCore1(B, C) calCore(in_val.s1, in_val.s2, in_val.s3, in_val.s4, B, C)
#endif
#if (FW > 2)
#define calCore2(B, C) calCore(in_val.s2, in_val.s3, in_val.s4, in_val.s5, B, C)
#endif
#if (FW > 3)
#define calCore3(B, C) calCore(in_val.s3, in_val.s4, in_val.s5, in_val.s6, B, C)
#endif
#if (FW > 4)
#define calCore4(B, C) calCore(in_val.s4, in_val.s5, in_val.s6, in_val.s7, B, C)
#endif
#if (FW > 5)
#define calCore5(B, C) calCore(in_val.s5, in_val.s6, in_val.s7, in_val.s8, B, C)
#endif
#if (FW > 6)
#define calCore6(B, C) calCore(in_val.s6, in_val.s7, in_val.s8, in_val.s9, B, C)
#endif
#elif (ON == 5)
#define calCore(a0, a1, a2, a3, a4, B, C) \
    {                                     \
        C[0] += a0 * B;                   \
        C[1] += a1 * B;                   \
        C[2] += a2 * B;                   \
        C[3] += a3 * B;                   \
        C[4] += a4 * B;                   \
    }
#define calCore0(B, C) calCore(in_val.s0, in_val.s1, in_val.s2, in_val.s3, in_val.s4, B, C)
#if (FW > 1)
#define calCore1(B, C) calCore(in_val.s1, in_val.s2, in_val.s3, in_val.s4, in_val.s5, B, C)
#endif
#if (FW > 2)
#define calCore2(B, C) calCore(in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, B, C)
#endif
#if (FW > 3)
#define calCore3(B, C) calCore(in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, B, C)
#endif
#if (FW > 4)
#define calCore4(B, C) calCore(in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, B, C)
#endif
#if (FW > 5)
#define calCore5(B, C) calCore(in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, B, C)
#endif
#if (FW > 6)
#define calCore6(B, C) calCore(in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, B, C)
#endif
#elif (ON == 6)
#define calCore(a0, a1, a2, a3, a4, a5, B, C) \
    {                                         \
        C[0] += a0 * B;                       \
        C[1] += a1 * B;                       \
        C[2] += a2 * B;                       \
        C[3] += a3 * B;                       \
        C[4] += a4 * B;                       \
        C[5] += a5 * B;                       \
    }
#define calCore0(B, C) \
    calCore(in_val.s0, in_val.s1, in_val.s2, in_val.s3, in_val.s4, in_val.s5, B, C)
#if (FW > 1)
#define calCore1(B, C) \
    calCore(in_val.s1, in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, B, C)
#endif
#if (FW > 2)
#define calCore2(B, C) \
    calCore(in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, B, C)
#endif
#if (FW > 3)
#define calCore3(B, C) \
    calCore(in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, B, C)
#endif
#if (FW > 4)
#define calCore4(B, C) \
    calCore(in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, B, C)
#endif
#if (FW > 5)
#define calCore5(B, C) \
    calCore(in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, B, C)
#endif
#if (FW > 6)
#define calCore6(B, C) \
    calCore(in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, in_val.sb, B, C)
#endif
#elif (ON == 7)
#define calCore(a0, a1, a2, a3, a4, a5, a6, B, C) \
    {                                             \
        C[0] += a0 * B;                           \
        C[1] += a1 * B;                           \
        C[2] += a2 * B;                           \
        C[3] += a3 * B;                           \
        C[4] += a4 * B;                           \
        C[5] += a5 * B;                           \
        C[6] += a6 * B;                           \
    }
#define calCore0(B, C) \
    calCore(in_val.s0, in_val.s1, in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, B, C)
#if (FW > 1)
#define calCore1(B, C) \
    calCore(in_val.s1, in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, B, C)
#endif
#if (FW > 2)
#define calCore2(B, C) \
    calCore(in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, B, C)
#endif
#if (FW > 3)
#define calCore3(B, C) \
    calCore(in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, B, C)
#endif
#if (FW > 4)
#define calCore4(B, C) \
    calCore(in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, B, C)
#endif
#if (FW > 5)
#define calCore5(B, C) \
    calCore(in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, in_val.sb, B, C)
#endif
#if (FW > 6)
#define calCore6(B, C) \
    calCore(in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, in_val.sb, in_val.sc, B, C)
#endif
#elif (ON == 8)
#define calCore(a0, a1, a2, a3, a4, a5, a6, a7, B, C) \
    {                                                 \
        C[0] += a0 * B;                               \
        C[1] += a1 * B;                               \
        C[2] += a2 * B;                               \
        C[3] += a3 * B;                               \
        C[4] += a4 * B;                               \
        C[5] += a5 * B;                               \
        C[6] += a6 * B;                               \
        C[7] += a7 * B;                               \
    }
#define calCore0(B, C)                                                                   \
    calCore(in_val.s0, in_val.s1, in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, \
        in_val.s7, B, C)
#if (FW > 1)
#define calCore1(B, C)                                                                   \
    calCore(in_val.s1, in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, \
        in_val.s8, B, C)
#endif
#if (FW > 2)
#define calCore2(B, C)                                                                   \
    calCore(in_val.s2, in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, \
        in_val.s9, B, C)
#endif
#if (FW > 3)
#define calCore3(B, C)                                                                   \
    calCore(in_val.s3, in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, \
        in_val.sa, B, C)
#endif
#if (FW > 4)
#define calCore4(B, C)                                                                   \
    calCore(in_val.s4, in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, \
        in_val.sb, B, C)
#endif
#if (FW > 5)
#define calCore5(B, C)                                                                   \
    calCore(in_val.s5, in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, in_val.sb, \
        in_val.sc, B, C)
#endif
#if (FW > 6)
#define calCore6(B, C)                                                                   \
    calCore(in_val.s6, in_val.s7, in_val.s8, in_val.s9, in_val.sa, in_val.sb, in_val.sc, \
        in_val.sd, B, C)
#endif
#endif

__kernel void MANGLE_NAME(conv_direct_3d_sw1_nchw_to_nchwc4_, IOM, AM, FW, FH, FT, ON)(
    const int iw_str,
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
    __global const T *flt,
    __read_only image1d_t bias,
    KERNEL_MEM out)
{
    const int idx = get_global_id(0);
    const int idy = get_global_id(1);
    const int idz = get_global_id(2);
    const int idt = idz % ot;
    const int idk = idz / ot;

    if (idx >= bx || idy >= by) {
        return;
    }

#if (IN <= 4)
    T4 in_val;
#elif (IN <= 8)
    T8 in_val;
#elif (IN > 8)
    T16 in_val;
#endif
    T4 flt_val;
    T4 out_val[ON];

    LOADBIAS_IMAGE_ARRAY_V4(out_val, idk, bias);
    int in_off = (idy * sh + ih_off) * iw_str + idx * ON + iw_off;
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
#if (FW == 1 && FH == 1)
            flt_val = vload4(flt_off, flt);
            LOAD_INPUT(in_off + tt * iwh_str, in);
            calCore0(flt_val, out_val);
            flt_off++;
#else
            for (uchar j = 0; j < FH; ++j) {
                LOAD_INPUT(in_off + tt * iwh_str + j * iw_str, in);
                for (uchar k = 0; k < FW; ++k) {
                    flt_val = vload4(flt_off + k, flt);
                    if (k == 0) {
                        calCore0(flt_val, out_val);
                    } else if (k == 1) {
                        calCore1(flt_val, out_val);
                    } else if (k == 2) {
                        calCore2(flt_val, out_val);
#if (FW > 3)
                    } else if (k == 3) {
                        calCore3(flt_val, out_val);
                    } else if (k == 4) {
                        calCore4(flt_val, out_val);
#endif
#if (FW > 5)
                    } else if (k == 5) {
                        calCore5(flt_val, out_val);
                    } else if (k == 6) {
                        calCore6(flt_val, out_val);
#endif
                    }
                }
                flt_off += FW;
            }
#endif
        }
        in_off += iwh_str * it;
        flt_off += flt_end;
    }

    int xn = idx * ON;
    int out_off = (idz * oh_str + idy) * ow_str + xn + o_off;
    STORE_OUTPUT_MEM_ARRAY_V4_W(out_val, out_off, xn, ow, out);
}
