#!/usr/bin/env bash

env

ncar_build_env_label="${NCAR_BUILD_ENV_COMPILER//-/.}"
echo "NCAR_BUILD_ENV_COMPILER=${NCAR_BUILD_ENV_COMPILER}"
echo ncar_build_env_label="${ncar_build_env_label}"
echo "SRC_DIR=${SRC_DIR}"
echo "RECIPE_DIR=${RECIPE_DIR}"
echo "PREFIX=${PREFIX}"
echo "PYTHON=${PYTHON}"
echo "pip=$(which pip)"

source modules.sh >/dev/null 2>&1
module unload mkl conda >/dev/null 2>&1
module load cudnn/9.2.0.82-12 >/dev/null 2>&1
module list

PIP_NO_DEPENDENCIES=False
PIP_NO_INDEX=False
PIP_NO_BUILD_ISOLATION=True
PIP_IGNORE_INSTALLED=False

python -m \
       pip install \
       --verbose --no-build-isolation \
       jax[cuda12_local]==${PKG_VERSION//_derecho/} \
       -f https://storage.googleapis.com/jax-releases/jax_releases.html

conda list

python -m \
       pip uninstall \
       --yes \
       jax nvidia-nccl-cu12

conda list

module purge >/dev/null 2>&1
module load cuda cudnn/9
module list
echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

# create an activate script
# other flags for consideration: https://github.com/NVIDIA/JAX-Toolbox/blob/main/rosetta/docs/GPU_performance.md
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat <<EOF > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
export ${PKG_NAME}_hostdeps_LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}"
export XLA_FLAGS="--xla_gpu_cuda_data_dir=${CUDA_HOME}"
EOF

cat "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
