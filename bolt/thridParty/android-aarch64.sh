#!/bin/bash
inner_script_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

cmake_env_options=""

export Protobuf_ROOT=${inner_script_dir}/android-aarch64/protobuf
if [[ ! -d "${Protobuf_ROOT}/bin" || ! -d "${Protobuf_ROOT}/lib" ]]; then
    echo "[ERROR] Protobuf not install success"
    exit 1
fi
export PATH=${Protobuf_ROOT}/bin:$PATH
export LD_LIBRARY_PATH=${Protobuf_ROOT}/lib:$LD_LIBRARY_PATH
cmake_env_options="${cmake_env_options} -DProtobuf_ROOT=${Protobuf_ROOT}"


export FlatBuffers_ROOT=${inner_script_dir}/android-aarch64/flatbuffers
if [[ ! -d "${FlatBuffers_ROOT}/include/flatbuffers" ]]; then
    echo "[ERROR] FlatBuffers not install success"
    exit 1
fi
cmake_env_options="${cmake_env_options} -DFlatBuffers_ROOT=${FlatBuffers_ROOT}"


export TFLite_ROOT=${inner_script_dir}/android-aarch64/tflite
if [[ ! -f "${TFLite_ROOT}/include/tensorflow/lite/schema/schema_generated.h" ]]; then
    echo "[ERROR] TFLite not install success"
    exit 1
fi
cmake_env_options="${cmake_env_options} -DTFLite_ROOT=${TFLite_ROOT}"


export JSONCPP_ROOT=${inner_script_dir}/android-aarch64/jsoncpp
export LD_LIBRARY_PATH=${JSONCPP_ROOT}/lib:$LD_LIBRARY_PATH
if [[ ! -d "${JSONCPP_ROOT}/lib" ]]; then
    echo "[ERROR] Jsoncpp not install success"
    exit 1
fi
cmake_env_options="${cmake_env_options} -DJSONCPP_ROOT=${JSONCPP_ROOT}"

