#!/usr/bin/env bash

set -e

top_dir=$(git rev-parse --show-toplevel)
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${top_dir}/profile.d/modules.sh
module list

make -C ${top_dir} conda-build-nccl-ofi-plugin

PYTHONS=("3.12" "3.11" "3.10")
MPI4PYS=("4.0.0" "3.1.6")
PYTORCH_VISIONS=("2.4.1:0.19.1" "2.3.1:0.18.1" "2.2.2:0.17.2")

for ENV_PYTHON_VERSION in "${PYTHONS[@]}" ; do
    export ENV_PYTHON_VERSION

    for MPI4PY_VERSION in "${MPI4PYS[@]}"; do
        export MPI4PY_VERSION
        make -C ${top_dir} conda-build-mpi4py
    done

    make -C ${top_dir} conda-build-{jaxlib,jax,mpi4jax}

    for pair in "${PYTORCH_VISIONS[@]}"; do
        export PYTORCH_VERSION=$(echo ${pair} | cut -d ':' -f1)
        export TORCHVISION_VERSION=$(echo ${pair} | cut -d ':' -f2)
        make -C ${top_dir} pbs-build-{torch,vision}
    done

done
