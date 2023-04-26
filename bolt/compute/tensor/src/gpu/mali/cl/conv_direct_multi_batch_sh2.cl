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
#define MANGLE_NAME_IMPL(base, IOM, AM, FW, FH, ON, KN, BN) base##IOM##AM##FW##FH##ON##KN##BN
#define MANGLE_NAME(base, IOM, AM, FW, FH, ON, KN, BN) \
    MANGLE_NAME_IMPL(base, IOM, AM, FW, FH, ON, KN, BN)

#if (KN == 1)
#define LOAD_BIAS(val, idz, bias)                   \
    {                                               \
        LOADBIAS_IMAGE_ARRAY_V4(val[0], idz, bias); \
    }
#define COPY_BIAS(src, dst)               \
    {                                     \
        SET_REG_ARRAY(src[0][0], dst[0]); \
    }
#if defined(USE_OUTPUT_IMG)
#define STORE_BUF(ov, ibn)                                                     \
    {                                                                          \
        STORE_OUTPUT_MEM_ARRAY_V4(                                             \
            ov[0], idx, idy *ON, out_off_z + ibn * oc_str, idy * ON, oh, out); \
    }
#else
#define STORE_BUF(ov, ibn)                                                                      \
    {                                                                                           \
        STORE_OUTPUT_MEM_ARRAY_V4(ov[0], out_off + ibn * on_str, ow_str, 0, idy * ON, oh, out); \
    }
#endif
#elif (KN == 2)
#define LOAD_BIAS(val, idz, bias)                           \
    {                                                       \
        LOADBIAS_IMAGE_ARRAY_V4(val[0], idz * 2, bias);     \
        LOADBIAS_IMAGE_ARRAY_V4(val[1], idz * 2 + 1, bias); \
    }
#define COPY_BIAS(src, dst)               \
    {                                     \
        SET_REG_ARRAY(src[0][0], dst[0]); \
        SET_REG_ARRAY(src[1][0], dst[1]); \
    }
#if defined(USE_OUTPUT_IMG)
#define STORE_BUF(ov, ibn)                                                         \
    {                                                                              \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                 \
            ov[0], idx, idy *ON, out_off_z + ibn * oc_str, idy * ON, oh, out);     \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                 \
            ov[1], idx, idy *ON, out_off_z + ibn * oc_str + 1, idy * ON, oh, out); \
    }
#else
#define STORE_BUF(ov, ibn)                                                                      \
    {                                                                                           \
        STORE_OUTPUT_MEM_ARRAY_V4(ov[0], out_off + ibn * on_str, ow_str, 0, idy * ON, oh, out); \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                              \
            ov[1], out_off + ibn * on_str + ohw_str, ow_str, 0, idy * ON, oh, out);             \
    }
#endif
#elif (KN == 4)
#define LOAD_BIAS(val, idz, bias)                           \
    {                                                       \
        LOADBIAS_IMAGE_ARRAY_V4(val[0], idz * 4, bias);     \
        LOADBIAS_IMAGE_ARRAY_V4(val[1], idz * 4 + 1, bias); \
        LOADBIAS_IMAGE_ARRAY_V4(val[2], idz * 4 + 2, bias); \
        LOADBIAS_IMAGE_ARRAY_V4(val[3], idz * 4 + 3, bias); \
    }
#define COPY_BIAS(src, dst)               \
    {                                     \
        SET_REG_ARRAY(src[0][0], dst[0]); \
        SET_REG_ARRAY(src[1][0], dst[1]); \
        SET_REG_ARRAY(src[2][0], dst[2]); \
        SET_REG_ARRAY(src[3][0], dst[3]); \
    }
#if defined(USE_OUTPUT_IMG)
#define STORE_BUF(ov, ibn)                                                         \
    {                                                                              \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                 \
            ov[0], idx, idy *ON, out_off_z + ibn * oc_str, idy * ON, oh, out);     \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                 \
            ov[1], idx, idy *ON, out_off_z + ibn * oc_str + 1, idy * ON, oh, out); \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                 \
            ov[2], idx, idy *ON, out_off_z + ibn * oc_str + 2, idy * ON, oh, out); \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                 \
            ov[3], idx, idy *ON, out_off_z + ibn * oc_str + 3, idy * ON, oh, out); \
    }
#else
#define STORE_BUF(ov, ibn)                                                                      \
    {                                                                                           \
        STORE_OUTPUT_MEM_ARRAY_V4(ov[0], out_off + ibn * on_str, ow_str, 0, idy * ON, oh, out); \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                              \
            ov[1], out_off + ibn * on_str + ohw_str, ow_str, 0, idy * ON, oh, out);             \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                              \
            ov[2], out_off + ibn * on_str + ohw_str * 2, ow_str, 0, idy * ON, oh, out);         \
        STORE_OUTPUT_MEM_ARRAY_V4(                                                              \
            ov[3], out_off + ibn * on_str + ohw_str * 3, ow_str, 0, idy * ON, oh, out);         \
    }
#endif
#endif

#if (BN == 1)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(ii)                                                                        \
    {                                                                                         \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[0], in_off_x + j, in_off_y + ii, in_off_z + i, 2, in); \
    }
#define LOAD_REST_MEM                                                                            \
    {                                                                                            \
        LOAD_MEM_V4(                                                                             \
            in_val[0][LN], (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i, 0), in); \
    }
#else
#define LOAD_INPUT(ii)                                                                  \
    {                                                                                   \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[0], in_off + j + ii * iw_str, iw_str, 0, 2, in); \
    }
#define LOAD_REST_MEM                                                          \
    {                                                                          \
        LOAD_MEM_V4(in_val[0][LN], in_off + j + ((LN << 1) + k) * iw_str, in); \
    }
#endif
#define UPDATE_INPUT_REG(iv) \
    {                        \
        UPDATE_REG(iv[0]);   \
    }
#define CALCORE_BN(iv, fv, ov0)                       \
    {                                                 \
        DIRECT_CONV_CAL_CORE_S1(iv[0], flt_val, ov0); \
    }
#define CALCORE0 CALCORE_BN(in_val, flt_val, out_val0[0]);
#if (KN > 1)
#define CALCORE1 CALCORE_BN(in_val, flt_val, out_val0[1]);
#endif
#if (KN > 2)
#define CALCORE2 CALCORE_BN(in_val, flt_val, out_val0[2]);
#define CALCORE3 CALCORE_BN(in_val, flt_val, out_val0[3]);
#endif
#endif

#if (BN == 2)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(ii)                                                                        \
    {                                                                                         \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[0], in_off_x + j, in_off_y + ii, in_off_z + i, 2, in); \
        LOAD_INPUT_MEM_ARRAY_V4(                                                              \
            in_val[1], in_off_x + j, in_off_y + ii, in_off_z + i + ic_str, 2, in);            \
    }
#define LOAD_REST_MEM                                                                            \
    {                                                                                            \
        LOAD_MEM_V4(                                                                             \
            in_val[0][LN], (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i, 0), in); \
        LOAD_MEM_V4(in_val[1][LN],                                                               \
            (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i + ic_str, 0), in);       \
    }
#else
#define LOAD_INPUT(ii)                                                                           \
    {                                                                                            \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[0], in_off + j + ii * iw_str, iw_str, 0, 2, in);          \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[1], in_off + j + ii * iw_str + in_str, iw_str, 0, 2, in); \
    }
#define LOAD_REST_MEM                                                                   \
    {                                                                                   \
        LOAD_MEM_V4(in_val[0][LN], in_off + j + ((LN << 1) + k) * iw_str, in);          \
        LOAD_MEM_V4(in_val[1][LN], in_off + j + ((LN << 1) + k) * iw_str + in_str, in); \
    }
#endif
#define UPDATE_INPUT_REG(iv) \
    {                        \
        UPDATE_REG(iv[0]);   \
        UPDATE_REG(iv[1]);   \
    }
#define CALCORE_BN(iv, fv, ov0, ov1)                  \
    {                                                 \
        DIRECT_CONV_CAL_CORE_S1(iv[0], flt_val, ov0); \
        DIRECT_CONV_CAL_CORE_S1(iv[1], flt_val, ov1); \
    }
#define CALCORE0 CALCORE_BN(in_val, flt_val, out_val0[0], out_val1[0]);
#if (KN > 1)
#define CALCORE1 CALCORE_BN(in_val, flt_val, out_val0[1], out_val1[1]);
#endif
#if (KN > 2)
#define CALCORE2 CALCORE_BN(in_val, flt_val, out_val0[2], out_val1[2]);
#define CALCORE3 CALCORE_BN(in_val, flt_val, out_val0[3], out_val1[3]);
#endif
#endif

#if (BN == 3)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(ii)                                                                        \
    {                                                                                         \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[0], in_off_x + j, in_off_y + ii, in_off_z + i, 2, in); \
        LOAD_INPUT_MEM_ARRAY_V4(                                                              \
            in_val[1], in_off_x + j, in_off_y + ii, in_off_z + i + ic_str, 2, in);            \
        LOAD_INPUT_MEM_ARRAY_V4(                                                              \
            in_val[2], in_off_x + j, in_off_y + ii, in_off_z + i + (ic_str << 1), 2, in);     \
    }
#define LOAD_REST_MEM                                                                             \
    {                                                                                             \
        LOAD_MEM_V4(                                                                              \
            in_val[0][LN], (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i, 0), in);  \
        LOAD_MEM_V4(in_val[1][LN],                                                                \
            (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i + ic_str, 0), in);        \
        LOAD_MEM_V4(in_val[2][LN],                                                                \
            (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i + (ic_str << 1), 0), in); \
    }
#else
#define LOAD_INPUT(ii)                                                                           \
    {                                                                                            \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[0], in_off + j + ii * iw_str, iw_str, 0, 2, in);          \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[1], in_off + j + ii * iw_str + in_str, iw_str, 0, 2, in); \
        LOAD_INPUT_MEM_ARRAY_V4(                                                                 \
            in_val[2], in_off + j + ii * iw_str + (in_str << 1), iw_str, 0, 2, in);              \
    }
#define LOAD_REST_MEM                                                                          \
    {                                                                                          \
        LOAD_MEM_V4(in_val[0][LN], in_off + j + ((LN << 1) + k) * iw_str, in);                 \
        LOAD_MEM_V4(in_val[1][LN], in_off + j + ((LN << 1) + k) * iw_str + in_str, in);        \
        LOAD_MEM_V4(in_val[2][LN], in_off + j + ((LN << 1) + k) * iw_str + (in_str << 1), in); \
    }
#endif
#define UPDATE_INPUT_REG(iv) \
    {                        \
        UPDATE_REG(iv[0]);   \
        UPDATE_REG(iv[1]);   \
        UPDATE_REG(iv[2]);   \
    }
#define CALCORE_BN(iv, fv, ov0, ov1, ov2)             \
    {                                                 \
        DIRECT_CONV_CAL_CORE_S1(iv[0], flt_val, ov0); \
        DIRECT_CONV_CAL_CORE_S1(iv[1], flt_val, ov1); \
        DIRECT_CONV_CAL_CORE_S1(iv[2], flt_val, ov2); \
    }
#define CALCORE0 CALCORE_BN(in_val, flt_val, out_val0[0], out_val1[0], out_val2[0]);
#if (KN > 1)
#define CALCORE1 CALCORE_BN(in_val, flt_val, out_val0[1], out_val1[1], out_val2[1]);
#endif
#if (KN > 2)
#define CALCORE2 CALCORE_BN(in_val, flt_val, out_val0[2], out_val1[2], out_val2[2]);
#define CALCORE3 CALCORE_BN(in_val, flt_val, out_val0[3], out_val1[3], out_val2[3]);
#endif
#endif

#if (BN == 4)
#if defined(USE_INPUT_IMG)
#define LOAD_INPUT(ii)                                                                        \
    {                                                                                         \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[0], in_off_x + j, in_off_y + ii, in_off_z + i, 2, in); \
        LOAD_INPUT_MEM_ARRAY_V4(                                                              \
            in_val[1], in_off_x + j, in_off_y + ii, in_off_z + i + ic_str, 2, in);            \
        LOAD_INPUT_MEM_ARRAY_V4(                                                              \
            in_val[2], in_off_x + j, in_off_y + ii, in_off_z + i + (ic_str << 1), 2, in);     \
        LOAD_INPUT_MEM_ARRAY_V4(                                                              \
            in_val[3], in_off_x + j, in_off_y + ii, in_off_z + i + ic_str * 3, 2, in);        \
    }
#define LOAD_REST_MEM                                                                             \
    {                                                                                             \
        LOAD_MEM_V4(                                                                              \
            in_val[0][LN], (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i, 0), in);  \
        LOAD_MEM_V4(in_val[1][LN],                                                                \
            (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i + ic_str, 0), in);        \
        LOAD_MEM_V4(in_val[2][LN],                                                                \
            (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i + (ic_str << 1), 0), in); \
        LOAD_MEM_V4(in_val[3][LN],                                                                \
            (int4)(in_off_x + j, in_off_y + (LN << 1) + k, in_off_z + i + ic_str * 3, 0), in);    \
    }
#else
#define LOAD_INPUT(ii)                                                                           \
    {                                                                                            \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[0], in_off + j + ii * iw_str, iw_str, 0, 2, in);          \
        LOAD_INPUT_MEM_ARRAY_V4(in_val[1], in_off + j + ii * iw_str + in_str, iw_str, 0, 2, in); \
        LOAD_INPUT_MEM_ARRAY_V4(                                                                 \
            in_val[2], in_off + j + ii * iw_str + (in_str << 1), iw_str, 0, 2, in);              \
        LOAD_INPUT_MEM_ARRAY_V4(                                                                 \
            in_val[3], in_off + j + ii * iw_str + in_str * 3, iw_str, 0, 2, in);                 \
    }
#define LOAD_REST_MEM                                                                          \
    {                                                                                          \
        LOAD_MEM_V4(in_val[0][LN], in_off + j + ((LN << 1) + k) * iw_str, in);                 \
        LOAD_MEM_V4(in_val[1][LN], in_off + j + ((LN << 1) + k) * iw_str + in_str, in);        \
        LOAD_MEM_V4(in_val[2][LN], in_off + j + ((LN << 1) + k) * iw_str + (in_str << 1), in); \
        LOAD_MEM_V4(in_val[3][LN], in_off + j + ((LN << 1) + k) * iw_str + in_str * 3, in);    \
    }
#endif
#define UPDATE_INPUT_REG(iv) \
    {                        \
        UPDATE_REG(iv[0]);   \
        UPDATE_REG(iv[1]);   \
        UPDATE_REG(iv[2]);   \
        UPDATE_REG(iv[3]);   \
    }
#define CALCORE_BN(iv, fv, ov0, ov1, ov2, ov3)        \
    {                                                 \
        DIRECT_CONV_CAL_CORE_S1(iv[0], flt_val, ov0); \
        DIRECT_CONV_CAL_CORE_S1(iv[1], flt_val, ov1); \
        DIRECT_CONV_CAL_CORE_S1(iv[2], flt_val, ov2); \
        DIRECT_CONV_CAL_CORE_S1(iv[3], flt_val, ov3); \
    }
#define CALCORE0 CALCORE_BN(in_val, flt_val, out_val0[0], out_val1[0], out_val2[0], out_val3[0]);
#if (KN > 1)
#define CALCORE1 CALCORE_BN(in_val, flt_val, out_val0[1], out_val1[1], out_val2[1], out_val3[1]);
#endif
#if (KN > 2)
#define CALCORE2 CALCORE_BN(in_val, flt_val, out_val0[2], out_val1[2], out_val2[2], out_val3[2]);
#define CALCORE3 CALCORE_BN(in_val, flt_val, out_val0[3], out_val1[3], out_val2[3], out_val3[3]);
#endif
#endif

#if defined(USE_INPUT_IMG)
#define ADD_IN_OFF
#else
#define ADD_IN_OFF in_off += ihw_str;
#endif

__kernel void MANGLE_NAME(conv_direct_multi_batch_sh2_, IOM, AM, FW, FH, ON, KN, BN)(
    const int iw_str,
    const int ihw_str,
    const int ic_str,
    const int iw_off,
    const int ih_off,
    const int ow_str,
    const int ohw_str,
    const int o_off,
    const int oh,
    const int oc,
    const int on,
    const int sw,
    const int in_str,
    const int on_str,
    const int bx,
    const int by,
    READ_ONLY_KERNEL_MEM in,
    __global const T *flt,
    __read_only image1d_t bias,
    KERNEL_MEM out)
{
    const int idx = get_global_id(0);
    const int idy = get_global_id(1);
    const int idz = get_global_id(2) % (((oc + 3) >> 2) / KN);
    const int idn = get_global_id(2) / (((oc + 3) >> 2) / KN);

    if (idx >= bx || idy >= by) {
        return;
    }
    T4 in_val[BN][IN];
    T16 flt_val;
    T4 out_val0[KN][ON];

    char en = ((idn * BN + BN) <= on) ? BN : (on % BN);
    LOAD_BIAS(out_val0, idz, bias);
#if (BN > 1)
    T4 out_val1[KN][ON];
    if (en > 1) {
        COPY_BIAS(out_val0, out_val1);
    }
#endif
#if (BN > 2)
    T4 out_val2[KN][ON];
    if (en > 2) {
        COPY_BIAS(out_val0, out_val2);
    }
#endif
#if (BN > 3)
    T4 out_val3[KN][ON];
    if (en > 3) {
        COPY_BIAS(out_val0, out_val3);
    }
#endif

#if defined(USE_INPUT_IMG)
    int in_off_x = idx * sw + iw_off;
    int in_off_y = (idy << 1) * ON + ih_off;
    int in_off_z = idn * BN * ic_str;
#else
    int in_off = idn * BN * in_str + ((idy << 1) * ON + ih_off) * iw_str + idx * sw + iw_off;
#endif
    int flt_off = idz * ic_str * FWH * KN;
    for (int i = 0; i < ic_str; ++i) {
#if (FH == 1)
        for (uchar j = 0; j < FW; ++j) {
            LOAD_INPUT(0);
            flt_val = vload16(flt_off, flt);
            CALCORE0;
#if (KN > 1)
            flt_val = vload16(flt_off + 1, flt);
            CALCORE1;
#endif
#if (KN > 2)
            flt_val = vload16(flt_off + 2, flt);
            CALCORE2;
            flt_val = vload16(flt_off + 3, flt);
            CALCORE3;
#endif
            flt_off += KN;
        }
#else
        for (uchar j = 0; j < FW; ++j) {
            for (uchar ii = 0; ii < 2; ++ii) {
                LOAD_INPUT(ii);
                for (uchar k = ii; k < FH; k += 2) {
                    LOAD_REST_MEM;
                    flt_val = vload16(flt_off + k * KN, flt);
                    CALCORE0;
#if (KN > 1)
                    flt_val = vload16(flt_off + k * KN + 1, flt);
                    CALCORE1;
#endif
#if (KN > 2)
                    flt_val = vload16(flt_off + k * KN + 2, flt);
                    CALCORE2;
                    flt_val = vload16(flt_off + k * KN + 3, flt);
                    CALCORE3;
#endif
                    UPDATE_INPUT_REG(in_val);
                }
            }
            flt_off += FH * KN;
        }
#endif
        ADD_IN_OFF;
    }

#if defined(USE_OUTPUT_IMG)
    int oc_str = (oc + 3) >> 2;
    int out_off_z = idz * KN + oc_str * idn * BN;
#else
    int out_off = idn * BN * on_str + idz * KN * ohw_str + idy * ON * ow_str + idx + o_off;
#endif
    STORE_BUF(out_val0, 0);
#if (BN > 1)
    if (en > 1) {
        STORE_BUF(out_val1, 1);
    }
#endif
#if (BN > 2)
    if (en > 2) {
        STORE_BUF(out_val2, 2);
    }
#endif
#if (BN > 3)
    if (en > 3) {
        STORE_BUF(out_val3, 3);
    }
#endif
}
