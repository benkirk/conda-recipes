#!/usr/bin/env bash

echo "SRC_DIR=${SRC_DIR}"
echo "RECIPE_DIR=${RECIPE_DIR}"
echo "PREFIX=${PREFIX}"
echo "PYTHON=${PYTHON}"

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
       --verbose --no-build-isolation --no-deps \
       jax[cuda12_local]==${PKG_VERSION//_derecho/} \
       -f https://storage.googleapis.com/jax-releases/jax_releases.html

conda list
