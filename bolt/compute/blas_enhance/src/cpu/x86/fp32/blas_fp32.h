// Copyright (C) 2019. Huawei Technologies Co., Ltd. All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef _H_BLAS_FP32
#define _H_BLAS_FP32

#include "cpu/x86/fp32/blas_common_fp32.h"

EE axpby_fp32(I32 len, F32 a, const F32 *x, F32 b, F32 *y);

inline EE mvm_avx2_fp32(U32 row, U32 col, DataFormat df, F32 *matrix, F32 *vector, F32 *result)
{
    EE ret = SUCCESS;
    switch (df) {
        case DF_NKN16: {
            mvm_pack_fp32(row, col, matrix, vector, result);
            break;
        }
        case DF_NORMAL: {
            mvm_row_fp32(row, col, matrix, vector, result);
            break;
        }
        case DF_TRANSPOSE: {
            mvm_col_fp32(row, col, matrix, vector, result);
            break;
        }
        default:
            ret = NOT_SUPPORTED;
            break;
    }
    return ret;
}

void matrix_matrix_multiply_tmp_bytes_fp32(
    U32 M, U32 N, U32 K, DataFormat matrixA_df, DataFormat matrixB_df, U32 *bytes);

EE mmm_avx2_fp32(int M,
    int N,
    int K,
    DataFormat matrixADataFormat,
    F32 *matrix1,
    F32 *matrix2,
    F32 *tmp,
    F32 *result);

EE matrix_vector_multiply_transform_weight_fp32(TensorDesc desc, F32 *src, F32 *dst);

void matrix_matrix_multiply_transform_rhs_bytes_fp32(
    U32 N, U32 K, DataFormat matrixB_df, U32 *bytes, U32 *rhsBytes);

EE matrix_matrix_multiply_transform_rhsN_fp32(TensorDesc desc, F32 *src, F32 *dst);

EE matrix_matrix_multiply_transform_rhsT_fp32(TensorDesc desc, F32 *src, F32 *dst);
#endif
