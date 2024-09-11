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
       jax[cuda12]==${PKG_VERSION//_derecho/} \
       -f https://storage.googleapis.com/jax-releases/jax_releases.html

conda list

python -m \
       pip uninstall \
       --yes \
       jax nvidia-nccl-cu12

# override provided NCCL with our AWS-plugin enabled version
cp -r ${RECIPE_DIR}/../../profile.d .
cp -r ${RECIPE_DIR}/../../utils .
export INSTALL_DIR="${SP_DIR}/nccl"
rm -rf ${INSTALL_DIR}
./utils/build_nccl-ofi-plugin.sh
rm -vf ${INSTALL_DIR}/lib/libnccl_static.a
unset INSTALL_DIR

conda list
