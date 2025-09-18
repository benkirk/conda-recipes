#!/usr/bin/env bash

set -e

top_dir=$(git rev-parse --show-toplevel)
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${top_dir}/profile.d/modules.sh
module list

make -C ${top_dir} conda-build-nccl-ofi-plugin

PYTHONS=("3.12" "3.11" "3.10")
MPI4PYS=("4.0.3" "3.1.6")
PYTORCH_VISIONS=("2.7.0:0.22.0" "2.6.0:0.21.0" "2.5.1:0.20.1")

for ENV_PYTHON_VERSION in "${PYTHONS[@]}" ; do
    export ENV_PYTHON_VERSION

    for MPI4PY_VERSION in "${MPI4PYS[@]}"; do
        export MPI4PY_VERSION
        make -C ${top_dir} conda-build-mpi4py
    done

    for JAX_VERSION in 0.4.38; do
        export JAX_VERSION
        make -C ${top_dir} conda-build-{jaxlib,jax}
    done

    export MPIJAX_VERSION=0.7.1
    make -C ${top_dir} conda-build-mpi4jax

    export PETSC_VERSION="3.21.6"
    for PETSC_CUDA_VERSION in "12.3"; do
        export PETSC_CUDA_VERSION
        make -C ${top_dir} conda-build-{petsc,petsc4py}
    done

    export H5PY_VERSION="3.12.1"
    make -C ${top_dir} conda-build-h5py

    for pair in "${PYTORCH_VISIONS[@]}"; do
        export PYTORCH_VERSION=$(echo ${pair} | cut -d ':' -f1)
        export TORCHVISION_VERSION=$(echo ${pair} | cut -d ':' -f2)
        make -C ${top_dir} pbs-build-{torch,vision}
    done

done
