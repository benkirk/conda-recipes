#!/usr/bin/env bash

echo "SRC_DIR=${SRC_DIR}"
echo "RECIPE_DIR=${RECIPE_DIR}"
echo "PREFIX=${PREFIX}"
echo "PYTHON=${PYTHON}"

source ${RECIPE_DIR}/../profile.d/modules.sh
module unload cray-mpich mkl
module list

export INSTALL_DIR="${PREFIX}"
export NCCL_HOME=${INSTALL_DIR}
export LIBFABRIC_HOME=/opt/cray/libfabric/1.15.2.0
export MPI_HOME=${CRAY_MPICH_DIR}

export NVCC_GENCODE="-gencode=arch=compute_80,code=sm_80"

export N=16
export MPICC=/bin/false
export CC=$(which gcc)
export CXX=$(which g++)

build_dir=${SRC_DIR}/build-${NCAR_BUILD_ENV_COMPILER}
rm -rf ${build_dir}
mkdir -p ${build_dir}

echo "========== BUILDING NCCL =========="
cd ${build_dir}
git clone --branch v2.21.5-1 https://github.com/NVIDIA/nccl.git
cd nccl
make -j ${N} PREFIX=${NCCL_HOME} src.build
make PREFIX=${NCCL_HOME} install

echo "========== BUILDING OFI PLUGIN =========="
cd ${build_dir}
git clone -b v1.6.0 https://github.com/aws/aws-ofi-nccl.git
cd aws-ofi-nccl
./autogen.sh
./configure --with-cuda=${CUDA_HOME} --with-libfabric=${LIBFABRIC_HOME} --prefix=${INSTALL_DIR} --disable-tests LDFLAGS="-Wl,-rpath,${LIBFABRIC_HOME}/lib64"
make -j ${N} install

rm -vf ${INSTALL_DIR}/lib/libnccl_static.a

# create an activate script with NCCL settings
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp ${RECIPE_DIR}/../profile.d/derecho-nccl-aws-ofi.cfg "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
