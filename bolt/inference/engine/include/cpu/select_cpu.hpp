// Copyright (C) 2019. Huawei Technologies Co., Ltd. All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef _SELECT_CPU_H
#define _SELECT_CPU_H

#include "select.hpp"

class SelectCPU : public Select {
public:
    SelectCPU(DataType dt) : Select(dt)
    {}

    std::shared_ptr<Operator> clone() override
    {
        std::shared_ptr<SelectCPU> mem = std::shared_ptr<SelectCPU>(new SelectCPU(this->dt));
        *mem = *this;
        return mem;
    }

    void run() override
    {
        CHECK_STATUS(select(this->inputTensors[0], this->inputTensors[1], this->inputTensors[2],
            this->outputTensors[0], &this->archInfo));
    }

    EE infer_output_tensors_size(
        std::vector<Tensor *> inTensors, std::vector<Tensor *> outTensors) override
    {
        return select_infer_output_size(inTensors[1], outTensors[0], &this->archInfo);
    }
};
#endif  // _SELECTCPU_H
