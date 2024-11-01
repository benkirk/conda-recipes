#!/usr/bin/env bash


#-------------------------------------------------------------------------------
# setup host environment
type module >/dev/null 2>&1 \
    || source /etc/profile.d/z00_modules.sh
module --force purge
module load ncarenv/23.09 gcc/12.2.0 ncarcompilers cray-mpich/8.1.27 cuda/12.2.1 mkl/2024.0.0 conda/latest cudnn/8.8.1.3-12 cmake
module list
#-------------------------------------------------------------------------------


top_dir="$(pwd)"

package="petsc"
version="3.17.5"

src_dir_tar=${package}-${version}
tarball=${package}-${version}.tar.gz
export PETSC_ARCH=${NCAR_BUILD_ENV}
src_dir=${src_dir_tar}

[ -f ${tarball} ] || wget https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/${tarball} || exit 1
[ -d ${src_dir} ] || tar zxf ${tarball} || exit 1

MKL_LIB="$NCAR_ROOT_MKL/lib"
BLAS_LAPACK="-L${MKL_LIB} -Wl,-rpath,${MKL_LIB} -lmkl_intel_lp64 -lmkl_sequential -lmkl_core"

export PETSC_DIR=$(pwd)/${src_dir}

cd ${PETSC_DIR} && pwd || exit 1

unset CC CXX FC F77

rm -rf ./${PETSC_ARCH}
set -x
./configure \
    --with-cc=$(which mpicc) --COPTFLAGS="-O3" \
    --with-cxx=$(which mpicxx) --CXXOPTFLAGS="-O3" \
    --with-fc=$(which mpif90) --FOPTFLAGS="-O3" \
    --with-cmake-dir=${NCAR_ROOT_CMAKE} \
    --with-cmake-exec=$(which cmake) \
    --enable-cuda --CUDAOPTFLAGS="-O3" \
    --with-shared-libraries --with-debugging=0 \
    --with-blaslapack-lib="${BLAS_LAPACK}" \
    --with-hypre=1        --download-hypre=yes \
    --with-metis=1        --download-metis=yes \
    --with-ml=1           --download-ml=yes \
    --with-parmetis=1     --download-parmetis=yes \
    --with-scalapack=1    --download-scalapack=yes \
    --with-sowing=0 \
    --with-spooles=1      --download-spooles=yes \
    --with-suitesparse=1  --download-suitesparse=yes \
    --with-superlu=1      --download-superlu=yes \
    --with-superlu_dist=1 --download-superlu_dist=1 \
    --with-triangle=1     --download-triangle=yes \
    --with-tetgen=1       --download-tetgen=yes \
    --with-viennacl=1     --download-viennacl=yes \
    || exit 1

exit 0

make PETSC_DIR=${PETSC_DIR} PETSC_ARCH=${PETSC_ARCH} all || exit 1
#rm -rf ${inst_dir} && make PETSC_DIR=${PETSC_DIR} PETSC_ARCH=${PETSC_ARCH} install || exit 1
make PETSC_DIR=${PETSC_DIR} PETSC_ARCH=${PETSC_ARCH} check || exit 1

cd ${PETSC_DIR}/src/snes/tutorials/ || exit 1
gmake V=1 ex12 ex19

echo && echo && echo "Done at $(date)"

# mpirun -np 4 ./ex19 -da_refine 3 -snes_monitor -dm_mat_type mpiaijcusparse -dm_vec_type mpicuda -pc_type gamg -pc_gamg_esteig_ksp_max_it 10 -ksp_monitor  -mg_levels_ksp_max_it 3 -log_view
