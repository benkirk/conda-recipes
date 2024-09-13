#!/usr/bin/env bash

echo "SRC_DIR=${SRC_DIR}"
echo "RECIPE_DIR=${RECIPE_DIR}"
echo "PREFIX=${PREFIX}"
echo "PYTHON=${PYTHON}"

source modules.sh >/dev/null 2>&1
module unload mkl conda >/dev/null 2>&1
module list

echo "CUDA_HOME=${CUDA_HOME}"

cat pyproject.toml

python -m \
       pip install \
       --verbose --no-deps --no-build-isolation \
       .

conda list

# create an activate script
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat <<EOF > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
export MPI4JAX_USE_CUDA_MPI=1
EOF


mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat <<EOF > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
unset MPI4JAX_USE_CUDA_MPI
EOF

for fname in ${PREFIX}/etc/conda/*activate.d/${PKG_NAME}_*activate.sh; do
    echo && echo && echo "# ${fname}:"
    cat ${fname}
done
