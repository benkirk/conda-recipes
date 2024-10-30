#!/usr/bin/env bash

source ../profile.d/modules.sh
module list

cat <<EOF > veros-deps.yaml
name: mpi4jax
channels:
  - file:///glade/derecho/scratch/benkirk/conda-recipes/output
  - conda-forge

dependencies:
  - python =3.11
  - jax =*_derecho
  - jaxlib =*_derecho
  - mpich =3*=external_*
  - mpi4jax =*_derecho
  - mpi4py =3*_derecho
  - numpy <=1.26.4
  - pip
  - pip:
     - setuptools
  #  - veros[jax]
EOF
cat ./veros-deps.yaml

conda env create --file ./veros-deps.yaml --prefix ./veros
conda activate ./veros
conda list


ml hdf5-mpi
export CC=$(which mpicc)
export HDF5_MPI="ON"
pip uninstall -y h5py
pip install --no-deps --verbose git+https://github.com/h5py/h5py.git@3.11.0



# cd $TMPDIR

#rm -rf veros.git
#pip uninstall -y veros
#git clone https://github.com/team-ocean/veros ./veros.git
#cd veros.git
#python3 setup.py install

pip install git+https://github.com/team-ocean/veros@main


conda list

# don't forget:
# ./jax-veros.sh
# conda activate ./veros
# ls
# cd veros-test/
# mpiexec -n 4 -ppn 4 veros run --backend jax --device gpu --force-overwrite acc/acc.py -n 2 2
