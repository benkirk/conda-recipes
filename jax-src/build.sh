#!/usr/bin/env bash

# for inspiration, ref: https://github.com/conda-forge/jaxlib-feedstock/blob/main/recipe/build.sh

echo && echo && echo
env
echo && echo && echo

ncar_build_env_label="${NCAR_BUILD_ENV_COMPILER//-/.}"
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

git clone --branch jax-v${PKG_VERSION//_derecho/}-rc --depth 1 https://github.com/google/jax
cd jax

python -m \
       pip install --verbose .

python -c "import jax; import jax._src"
