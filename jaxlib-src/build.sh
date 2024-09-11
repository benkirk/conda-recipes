#!/usr/bin/env bash

echo && echo && echo
env
echo && echo && echo


ncar_build_env_label="${NCAR_BUILD_ENV_COMPILER//-/.}"
echo "NCAR_BUILD_ENV_COMPILER=${NCAR_BUILD_ENV_COMPILER}"
echo ncar_build_env_label="${ncar_build_env_label}"
echo "SRC_DIR=${SRC_DIR}"
echo "RECIPE_DIR=${RECIPE_DIR}"
echo "PREFIX=${PREFIX}"
echo "PYTHON=${PYTHON}"

source modules.sh >/dev/null 2>&1
module unload mkl conda >/dev/null 2>&1
module load cudnn/9.2.0.82-12 >/dev/null 2>&1
module list


#PATH=/glade/u/apps/derecho/23.09/spack/opt/spack/llvm/15.0.7/gcc/7.5.0/37in/bin:$PATH
#PATH=/glade/work/benkirk/spack-downstreams/derecho/23.09/opt/spack/llvm/17.0.4/gcc/7.5.0/phgb/bin:$PATH
echo "CC=$CC"

which clang

git clone --branch jaxlib-v${PKG_VERSION//_derecho/} --depth 1 https://github.com/google/jax
# git clone --depth 1 https://github.com/google/jax
cd jax

#export TF_NCCL_VERSION="2.21.5"

python build/build.py \
       --clang_path $CC \
       --verbose \
       --enable_mkl_dnn \
       --enable_nccl \
       --enable_cuda \
       --cuda_path ${CUDA_HOME} \
       --cudnn_path ${NCAR_ROOT_CUDNN} \
       --cuda_compute_capabilities 8.0 \
       --bazel_options="--repo_env=LOCAL_NCCL_PATH=${PREFIX}"

python -m \
       pip install \
       --no-deps --verbose \
       dist/*.whl

# #       --bazel_options=--repo_env=LOCAL_CUDA_PATH="${NCAR_ROOT_CUDA}" \
# #       --bazel_options=--repo_env=LOCAL_CUDNN_PATH="${NCAR_ROOT_CUDNN}" \
