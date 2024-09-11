#!/usr/bin/env bash

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

echo "CUDA_HOME=${CUDA_HOME}"

cat pyproject.toml

python -m \
       pip install \
       --verbose --no-deps --no-build-isolation \
       .

conda list
