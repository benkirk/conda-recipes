#!/usr/bin/env bash

#env

source ${RECIPE_DIR}/../profile.d/modules.sh >/dev/null 2>&1
module unload conda cudnn >/dev/null 2>&1


case "${PETSC_CUDA_VERSION}" in
    "None")
        module unload cuda >/dev/null 2>&1
        petsc_cuda_args="--disable-cuda"
        ;;
    *)
        petsc_cuda_args="--enable-cuda --with-viennacl=1 --download-viennacl=yes"
        ;;
esac


module list

BLAS_LAPACK="-L${NCAR_ROOT_MKL}/lib -Wl,-rpath,${NCAR_ROOT_MKL}/lib -lmkl_intel_lp64 -lmkl_sequential -lmkl_core"
export PETSC_DIR=${SRC_DIR}
export PETSC_ARCH=${NCAR_BUILD_ENV}
unset CC CXX FC F77

# Get an updated config.sub and config.guess
cp ${BUILD_PREFIX}/share/gnuconfig/config.* .

./configure --help

set -ex

./configure \
    --prefix=${PREFIX} \
    --with-cc=$(which mpicc) --COPTFLAGS="-O3 -Wno-deprecated-declarations" \
    --with-cxx=$(which mpicxx) --CXXOPTFLAGS="-O3 -Wno-deprecated-declarations" \
    --with-fc=$(which mpif90) --FOPTFLAGS="-O3 -Wno-deprecated-declarations" \
    --CUDAOPTFLAGS="-O3 -Wno-deprecated-declarations" \
    --with-shared-libraries --with-debugging=0 \
    --with-blaslapack-lib="${BLAS_LAPACK}" \
    --with-metis=1     --download-metis=yes \
    --with-ml=1           --download-ml=yes \
    --with-parmetis=1     --download-parmetis=yes \
    --with-hypre=1        --download-hypre=yes \
    --with-scalapack=1    --download-scalapack=yes \
    --with-sowing=0 \
    --with-spooles=1      --download-spooles=yes \
    --with-suitesparse=1  --download-suitesparse=yes \
    --with-superlu=1      --download-superlu=yes \
    --with-superlu_dist=1 --download-superlu_dist=1 \
    --with-triangle=1     --download-triangle=yes \
    --with-tetgen=1       --download-tetgen=yes ${petsc_cuda_args} \
    || { cat configure.log; exit 1; }

# sedinplace() {
#   if [[ $(uname) == Darwin ]]; then
#     sed -i "" "$@"
#   else
#     sed -i"" "$@"
#   fi
# }

# # Remove abspath of ${BUILD_PREFIX}/bin/python
# sedinplace "s%${BUILD_PREFIX}/bin/python%python%g" $PETSC_ARCH/include/petscconf.h
# sedinplace "s%${BUILD_PREFIX}/bin/python%python%g" $PETSC_ARCH/lib/petsc/conf/petscvariables
# #sedinplace "s%${BUILD_PREFIX}/bin/python%/usr/bin/env python%g" $PETSC_ARCH/lib/petsc/conf/reconfigure-arch-conda-c-opt.py

# # Replace abspath of ${PETSC_DIR} and ${BUILD_PREFIX} with ${PREFIX}
# for path in $PETSC_DIR $BUILD_PREFIX; do
#     for f in $(grep -l "${path}" $PETSC_ARCH/include/petsc*.h); do
#         echo "Fixing ${path} in $f"
#         sedinplace s%$path%\${PREFIX}%g $f
#     done
# done


make MAKE_NP=8
make install

# Remove unneeded files
rm -rf \
   ${PREFIX}/lib/petsc/conf/configure-hash \
   ${PREFIX}/lib/cmake \
   ${PREFIX}/share/petsc/bin
find ${PREFIX}/lib/petsc -name '*.pyc' -delete

echo "Removing example files"
du -hs ${PREFIX}/share/petsc/examples/src
rm -fr ${PREFIX}/share/petsc/examples/src
echo "Removing data files"
du -hs ${PREFIX}/share/petsc/datafiles/*
rm -fr ${PREFIX}/share/petsc/datafiles

# # Replace ${BUILD_PREFIX} and CUDA temporary information
# # after installation, otherwise 'make install' above may fail
# if [[ -n "$cuda_dir" ]]; then
#   for s in $cuda_incl $cuda_dir; do
#     for f in $(grep -l "${s}" -R "${PREFIX}/lib/petsc"); do
#       echo "Fixing ${s} in $f"
#       sedinplace s%${s}%${PREFIX}%g $f
#     done
#   done
# fi
# for f in $(grep -l "${BUILD_PREFIX}" -R "${PREFIX}/lib/petsc"); do
#   echo "Fixing ${BUILD_PREFIX} in $f"
#   sedinplace s%${BUILD_PREFIX}%${PREFIX}%g $f
# done

cd ${PETSC_DIR}/src/snes/tutorials/ && gmake V=1 ex12 ex19


exit 0










#cd ${PETSC_DIR}/src/snes/tutorials/ || exit 1
#gmake V=1 ex12 ex19

echo && echo && echo "Done at $(date)"

# mpirun -np 4 ./ex19 -da_refine 3 -snes_monitor -dm_mat_type mpiaijcusparse -dm_vec_type mpicuda -pc_type gamg -pc_gamg_esteig_ksp_max_it 10 -ksp_monitor  -mg_levels_ksp_max_it 3 -log_view
