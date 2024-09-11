#!/usr/bin/env bash

echo "SRC_DIR=${SRC_DIR}"
echo "RECIPE_DIR=${RECIPE_DIR}"
echo "PREFIX=${PREFIX}"
echo "PYTHON=${PYTHON}"

# then add the NCCL plugin dependency so it makes it into the final package
cp -r ${RECIPE_DIR}/../../profile.d .
cp -r ${RECIPE_DIR}/../../utils .

export INSTALL_DIR="${PREFIX}"
./utils/build_nccl-ofi-plugin.sh
rm -vf ${INSTALL_DIR}/lib/libnccl_static.a
unset INSTALL_DIR

# create an activate script with NCCL settings
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp ${RECIPE_DIR}/../../profile.d/derecho-nccl-aws-ofi.cfg "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
