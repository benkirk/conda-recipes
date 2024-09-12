#!/usr/bin/env bash

set -e

top_dir=$(git rev-parse --show-toplevel)
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

make -C ${top_dir} pbs-build-nccl-ofi-plugin

PYTHONS=("3.12" "3.11" "3.10")
MPI4PYS=("4.0.0" "3.1.6")
PYTORCHS=("2.4.1" "2.3.1" "2.2.2")

for ENV_PYTHON_VERSION in "${PYTHONS[@]}" ; do

    for MPI4PY_VERSION in "${MPI4PYS[@]}"; do
        make -C ${top_dir} pbs-build-mpi4py
    done

    make -C ${top_dir} conda-build-{jax,jaxlib,mpi4jax}

    for PYTORCH_VERSION in "${PYTORCHS[@]}"; do
        make -C ${top_dir} pbs-build-{torch,vision}
    done

done
