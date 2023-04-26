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
#define MANGLE_NAME_IMPL(base, PRO, MODE) base##PRO##MODE
#define MANGLE_NAME(base, PRO, MODE) MANGLE_NAME_IMPL(base, PRO, MODE)

#if defined(USE_RNN_MODE)
#define MODE ch
#else
#define MODE s
#endif

#if defined(USE_PROJECTION)
#define PRO pro_
#else
#define PRO
#endif

#define load_float4(off, val, buf)  \
    {                               \
        T4 tmp;                     \
        tmp = vload4(0, buf + off); \
        val.x = tmp.x;              \
        val.y = tmp.y;              \
        val.z = tmp.z;              \
        val.w = tmp.w;              \
    }

#define store_float4(off, val, buf) \
    {                               \
        T4 tmp;                     \
        tmp.x = (T)val.x;           \
        tmp.y = (T)val.y;           \
        tmp.z = (T)val.z;           \
        tmp.w = (T)val.w;           \
        vstore4(tmp, 0, buf + off); \
    }
#define store_float3(off, val, buf) \
    {                               \
        T3 tmp;                     \
        tmp.x = (T)val.x;           \
        tmp.y = (T)val.y;           \
        tmp.z = (T)val.z;           \
        vstore3(tmp, 0, buf + off); \
    }
#define store_float2(off, val, buf) \
    {                               \
        T2 tmp;                     \
        tmp.x = (T)val.x;           \
        tmp.y = (T)val.y;           \
        vstore2(tmp, 0, buf + off); \
    }

__kernel void MANGLE_NAME(rnncell_update_res_, PRO, MODE)(const int col,
    const int out_off,
    const int bx,
    float fbias,
    float zonecell,
    float zoneout,
#if defined(USE_RNN_MODE)
    __global T *cmem,
    __global T *hmem,
#else
    __global T *smem,
#endif
    __global T *imem,
    __global T *out)
{
    int idx = get_global_id(0);
    if (idx >= bx) {
        return;
    }
    char ec = ((idx << 2) + 4 <= col) ? 4 : (col & 3);
    float4 cval;
    float4 lcval;
    float4 ival;
    float4 gval;
    float4 fval;
    float4 oval;
    float4 res;
    float4 hres;
    int off = idx << 2;
#if defined(USE_RNN_MODE)
    load_float4(off, cval, cmem);
#else
    load_float4(off, cval, smem);
#endif
    load_float4(off, ival, imem);
    load_float4(off + col, gval, imem);
    load_float4(off + col * 2, fval, imem);
    load_float4(off + col * 3, oval, imem);
    ival.x = 1.0 / (1.0 + exp(-ival.x));
    ival.y = 1.0 / (1.0 + exp(-ival.y));
    ival.z = 1.0 / (1.0 + exp(-ival.z));
    ival.w = 1.0 / (1.0 + exp(-ival.w));
    gval.x = tanh(gval.x);
    gval.y = tanh(gval.y);
    gval.z = tanh(gval.z);
    gval.w = tanh(gval.w);
    fval.x = 1.0 / (1.0 + exp(-(fval.x + fbias)));
    fval.y = 1.0 / (1.0 + exp(-(fval.y + fbias)));
    fval.z = 1.0 / (1.0 + exp(-(fval.z + fbias)));
    fval.w = 1.0 / (1.0 + exp(-(fval.w + fbias)));
    oval.x = 1.0 / (1.0 + exp(-oval.x));
    oval.y = 1.0 / (1.0 + exp(-oval.y));
    oval.z = 1.0 / (1.0 + exp(-oval.z));
    oval.w = 1.0 / (1.0 + exp(-oval.w));
    lcval = cval;
    cval.x = cval.x * fval.x + ival.x * gval.x;
    cval.y = cval.y * fval.y + ival.y * gval.y;
    cval.z = cval.z * fval.z + ival.z * gval.z;
    cval.w = cval.w * fval.w + ival.w * gval.w;
    res.x = oval.x * tanh(cval.x);
    res.y = oval.y * tanh(cval.y);
    res.z = oval.z * tanh(cval.z);
    res.w = oval.w * tanh(cval.w);
    hres = res;

    if (zonecell != 0) {
        cval.x = cval.x * (1 - zonecell) + lcval.x * zonecell;
        cval.y = cval.y * (1 - zonecell) + lcval.y * zonecell;
        cval.z = cval.z * (1 - zonecell) + lcval.z * zonecell;
        cval.w = cval.w * (1 - zonecell) + lcval.w * zonecell;
    }

#if !defined(USE_PROJECTION)
    if (zoneout != 0) {
#if defined(USE_RNN_MODE)
        load_float4(off, hres, hmem);
#else
        load_float4(off + col, hres, smem);
#endif
        hres.x = res.x * (1 - zoneout) + hres.x * zoneout;
        hres.y = res.y * (1 - zoneout) + hres.y * zoneout;
        hres.z = res.z * (1 - zoneout) + hres.z * zoneout;
        hres.w = res.w * (1 - zoneout) + hres.w * zoneout;
    }
#endif

#if defined(USE_RNN_MODE)
    store_float4(off, cval, cmem);
#if !defined(USE_PROJECTION)
    store_float4(off, hres, hmem);
#endif
    if (ec == 4) {
        store_float4(off + out_off, res, out);
    } else if (ec == 1) {
        out[off + out_off] = (T)res.x;
    } else if (ec == 2) {
        store_float2(off + out_off, res, out);
    } else if (ec == 3) {
        store_float3(off + out_off, res, out);
    }
#else
    if (ec == 4) {
        store_float4(off + out_off, res, out);
        store_float4(off, cval, smem);
#if !defined(USE_PROJECTION)
        store_float4(off + col, hres, smem);
#endif
    } else if (ec == 1) {
        smem[off] = (T)cval.x;
        out[off + out_off] = (T)res.x;
#if !defined(USE_PROJECTION)
        smem[off + col] = (T)hres.x;
#endif
    } else if (ec == 2) {
        store_float2(off, cval, smem);
        store_float2(off + out_off, res, out);
#if !defined(USE_PROJECTION)
        store_float2(off + col, hres, smem);
#endif
    } else if (ec == 3) {
        store_float3(off, cval, smem);
        store_float3(off + out_off, res, out);
#if !defined(USE_PROJECTION)
        store_float3(off + col, hres, smem);
#endif
    }
#endif
}
