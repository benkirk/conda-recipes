# Support for creating `conda` packages for various tools

A set of tools for creating custom `conda` packages using `conda-build`

## Quickstart
### Clone, including submodules
```pre
git clone --recurse-submodules https://github.com/benkirk/conda-recipes.git
cd conda-recipes/
```
### Create a minimal `conda` environment containing `conda-build`
We [patch](https://github.com/benkirk/conda-recipes/blob/main/README.md) `conda-build` in this step specifically to override its `RPATH` stripping.

`conda-build` likes to strip all rpaths that point to host
directories, which makes perfect sense for the typical use case -
building packages in an isolated environment to ensure proper
redistribution.

However, here we want to keep external dependencies to certain host
libraries, as we are intentionally building packages designed only to
run on this host. We therefore patch the `conda-build` file `post.py`
and introduce the configurable `host_runpath_whitelist`.
```bash
# creates ./conda_build/ from ./conda_build.yaml
make conda-build
```
(If this step is omitted, it will be run automatically when a package is built.)

### Create a `conda` package
```bash
# creates a conda package from ./nccl-ofi-plugin/{meta.yaml,build.sh}
make conda-build-nccl-ofi-plugin

# same thing, excepts submits the build job via qcmd to a dedicated node:
make pbs-build-nccl-ofi-plugin

# creates a conda package from ./mpi4py/{meta.yaml,build.sh}
# ... for the default mpi4py version:
make conda-build-mpi4py
# ... for a specified mpi4py version:
make conda-build-mpi4py MPI4PY_VERSION="3.1.6"
```
Output for successful builds are placed in the `./output/` directory.

### Querying the local channel `./output/`:
```bash
conda search -c file://$(pwd)/output --override-channels -i
```

## Installing from the local channel into a `conda` environment
You can select these packages in a `conda` `environment.yaml` file as follows:
```pre
name: resnet
channels:
  - file:///<full_path_to>/conda-recipes/output
  - conda-forge
dependencies:
  - python
  - libblas =*=*mkl
  - numpy
  - mpi4py =*_derecho
  - xarray
  - pandas
  - pytorch =*_derecho
  - torchvision =*_derecho
```
The special version string `*_derecho` can be used to force the dependecy solver to use our local packages regardless of overall channel priority.

## Support for multiple package, python versions
```bash
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

```

## `conda-build` documentation
[Overview](https://docs.conda.io/projects/conda-build/en/stable/)
- [Concepts and Build Process](https://docs.conda.io/projects/conda-build/en/stable/concepts/recipe.html)
- [References](https://docs.conda.io/projects/conda-build/en/stable/resources/index.html)

---

## Supported packages

### `nccl-ofi-plugin`
Builds NCCL + the AWS OFI plugin using Derecho's `libfabric`.
```bash
make conda-build-nccl-ofi-plugin
```
The resulting `conda` environment will contain an activation script with optimal NCCL default settings from `nccl-ofi-plugin/derecho-nccl-aws-ofi.cfg`.

### `mpi4py`
```bash
source profile.d/modules.sh
make conda-build-mpi4py
```

```bash
source profile.d/modules.sh

PYTHONS=("3.12" "3.11" "3.10")
MPI4PYS=("4.0.0" "3.1.6")

for ENV_PYTHON_VERSION in "${PYTHONS[@]}" ; do
    export ENV_PYTHON_VERSION
    for MPI4PY_VERSION in "${MPI4PYS[@]}"; do
        export MPI4PY_VERSION
        make conda-build-mpi4py
    done
done
```

### `pytorch` & `torchvision`
First, we will build a suite of wheel files in `./src_builds/derecho-pytorch-mpi/wheels/` by directly compiling `pytorch` and `torchvision` from source. These will then serve as source packages later in the `conda-build` process.
```bash
# First, we will build a suite of wheel files in ./src_builds/derecho-pytorch-mpi/wheels/
cd ./src_builds/derecho-pytorch-mpi/
time ./utils/build_all.sh
[...]

cd -

# then we will create conda packages from all the resultant wheel files.
PYTHONS=("3.12" "3.11" "3.10")
PYTORCH_VISIONS=("2.4.1:0.19.1" "2.3.1:0.18.1" "2.2.2:0.17.2")

for ENV_PYTHON_VERSION in "${PYTHONS[@]}" ; do
    export ENV_PYTHON_VERSION
    for pair in "${PYTORCH_VISIONS[@]}"; do
        export PYTORCH_VERSION=$(echo ${pair} | cut -d ':' -f1)
        export TORCHVISION_VERSION=$(echo ${pair} | cut -d ':' -f2)
        make pbs-build-{torch,vision}
    done
done
```

### `jaxlib`, `jax` & `mpi4jax`
```bash
make conda-build-{jaxlib,jax,mpi4jax}
```
