#!/usr/bin/env bash


#-------------------------------------------------------------------------------
# setup host environment
type module >/dev/null 2>&1 \
    || source /etc/profile.d/z00_modules.sh
module --force purge
module load ncarenv/23.09 gcc/12.2.0 ncarcompilers cray-mpich/8.1.27 cuda/12.2.1 mkl/2024.0.0 conda/latest cudnn/8.8.1.3-12
module list
#-------------------------------------------------------------------------------



cat <<EOF > veros-deps.yaml
name: mpi4jax
channels:
  - file:///glade/derecho/scratch/benkirk/conda-recipes/output
  - conda-forge

dependencies:
  - python =3.11
  - jax =*=*derecho*
  - jaxlib =*=*derecho*
  - h5py =*=*derecho*
  - mpi4jax =*=*derecho*
  - mpi4py =*=*derecho*
  - numpy <2
  - petsc4py =*=*derecho*
  - pip
  - pip:
     - setuptools
EOF
cat ./veros-deps.yaml

conda env create --file ./veros-deps.yaml --prefix ./veros
conda activate ./veros
conda list

# https://veros.readthedocs.io/en/latest/introduction/get-started.html
pip install git+https://github.com/team-ocean/veros@main

# https://veros-extra-setups.readthedocs.io/en/latest/installation.html:
pip install git+https://github.com/team-ocean/veros-extra-setups@main
conda list

#-------------------------------------------------------------------------------
# setup examples
if [ ! -d ./veros-tests ]; then
    mkdir -p ./veros-tests
    veros copy-setup acc --to ./veros-tests/acc
    veros copy-setup wave_propagation --to ./veros-tests/wave_propagation
    veros copy-setup global_1deg --to ./veros-tests/global_1deg
fi
#-------------------------------------------------------------------------------


# don't forget:
# cd veros-tests/
# mpiexec -n 4 -ppn 4 veros run --backend jax --device gpu --force-overwrite wave_propagation/wave_propagation.py -n 2 2
# mpibind veros run --backend jax --device gpu --force-overwrite wave_propagation/wave_propagation.py -n 2 2
