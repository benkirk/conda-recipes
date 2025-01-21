#!/usr/bin/env bash

# for inspiration, ref: https://github.com/conda-forge/jaxlib-feedstock/blob/main/recipe/build.sh

echo && echo && echo
env
echo && echo && echo

ncar_build_env_label="${NCAR_BUILD_ENV_COMPILER//-/_}"
echo "NCAR_BUILD_ENV_COMPILER=${NCAR_BUILD_ENV_COMPILER}"
echo ncar_build_env_label="${ncar_build_env_label}"
echo "SRC_DIR=${SRC_DIR}"
echo "RECIPE_DIR=${RECIPE_DIR}"
echo "PREFIX=${PREFIX}"
echo "BUILD_PREFIX=${BUILD_PREFIX}"
echo "PYTHON=${PYTHON}"

source modules.sh >/dev/null 2>&1
module unload mkl conda cray-mpich >/dev/null 2>&1
module load cudnn/9.2.0.82-12 >/dev/null 2>&1
module list

# echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
# unset my_rpaths
# while read libpath; do
#     echo "${my_rpaths} -Wl,-rpath,${libpath}"
#     export my_rpaths="${my_rpaths} -Wl,-rpath,${libpath}"
#     export LDFLAGS="${LDFLAGS} -Wl,-rpath,${libpath}"
# done < <(echo "$LD_LIBRARY_PATH" | sed 's/:/\n/g')
# echo "my_rpaths=${my_rpaths}"
# echo "LDFLAGS=${LDFLAGS}"

# # locate & link with our NCCL+AWS plugin
# PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
# pkg-config nccl --modversion
# export TF_NCCL_VERSION="$(pkg-config nccl --modversion)"

# export CFLAGS="${CFLAGS} -DNDEBUG"
# export CXXFLAGS="${CXXFLAGS} -DNDEBUG"

# # copy the CUDA tree & NCCL into the same path as the SRC_DIR
# # (where our NCCL is located) since TF_NCCL_... seems to expect them to be in the same place...
# my_CUDA_HOME="${PREFIX}/cuda-${CUDA_VERSION}"
# mkdir -p ${my_CUDA_HOME}
# rsync -axq ${CUDA_HOME}/ ${my_CUDA_HOME}/
# rsync -axq ${NCAR_ROOT_CUDNN}/ ${my_CUDA_HOME}/

# # then add the NCCL plugin dependency so it can be located
# cp -r ${RECIPE_DIR}/../../profile.d .
# cp -r ${RECIPE_DIR}/../../utils .
# export INSTALL_DIR="${my_CUDA_HOME}"
# ./utils/build_nccl-ofi-plugin.sh
# rm -vf ${INSTALL_DIR}/lib/libnccl_static.a
# unset INSTALL_DIR


# git clone --branch jaxlib-v${PKG_VERSION//_derecho/} --depth 1 https://github.com/google/jax
git clone --branch jax-v${PKG_VERSION//_derecho/}-rc --depth 1 https://github.com/google/jax
cd jax

#PATH=/glade/u/apps/derecho/23.09/spack/opt/spack/llvm/15.0.7/gcc/7.5.0/37in/bin:$PATH
#PATH=/glade/work/benkirk/spack-downstreams/derecho/23.09/opt/spack/llvm/17.0.4/gcc/7.5.0/phgb/bin:$PATH

#CC=$(which clang)
CC=$(which gcc)
echo "CC=$CC"

# python build/build.py \
#        --use_clang false \
#        --verbose \
#        --enable_mkl_dnn \
#        --enable_nccl \
#        --enable_cuda \
#        --cuda_path ${my_CUDA_HOME} \
#        --cudnn_path ${my_CUDA_HOME} \
#        --cuda_compute_capabilities 8.0 \
#        --target_cpu_features release

python build/build.py \
       --help

export LOCAL_CUDA_PATH="${CUDA_HOME}"
export LOCAL_CUDNN_PATH="${NCAR_ROOT_CUDNN}"
export LOCAL_NCCL_PATH="${PREFIX}"

python build/build.py \
       --build_gpu_plugin --gpu_plugin_cuda_version=12 \
       --use_clang false \
       --verbose \
       --enable_mkl_dnn \
       --enable_nccl \
       --enable_cuda \
       --cuda_compute_capabilities sm_80 \
       --cuda_version=12.2.0 --cudnn_version=9.2.0 \
       --target_cpu_features release

# --bazel_options=--repo_env=LOCAL_CUDA_PATH="${CUDA_HOME}" \
# --bazel_options=--repo_env=LOCAL_CUDNN_PATH="${NCAR_ROOT_CUDNN}" \
# --bazel_options=--repo_env=LOCAL_NCCL_PATH="${PREFIX}"
# --enable_cuda --cuda_version 12.2.0 \

python -m \
       pip install \
       --no-deps --verbose \
       dist/*.whl



#rm -rf ${my_CUDA_HOME}/nsight*/ ${my_CUDA_HOME}/compute-sanitizer/ ${my_CUDA_HOME}/gds*/ $${my_CUDA_HOME}/{libnvvp,nvml,src,extras,bin}/
#find ${my_CUDA_HOME} -name "*_static*.a" -print0 | xargs -0 rm -f
