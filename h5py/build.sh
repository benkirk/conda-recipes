#!/usr/bin/env bash

source ${RECIPE_DIR}/../profile.d/modules.sh >/dev/null 2>&1
module unload conda cudnn cuda >/dev/null 2>&1
module load hdf5-mpi >/dev/null 2>&1
module list

# ref: https://github.com/conda-forge/h5py-feedstock/blob/main/recipe/build.sh
export HDF5_DIR="${NCAR_ROOT_HDF5}"
export CC=$(which mpicc)
export HDF5_MPI="ON"


# tell setup.py to not 'pip install' exact package requirements
export H5PY_SETUP_REQUIRES="0"
"${PYTHON}" -m pip install . --no-deps --ignore-installed --no-cache-dir -vv
