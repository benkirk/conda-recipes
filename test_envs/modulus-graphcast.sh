#!/usr/bin/env bash

source ../../profile.d/modules.sh
module list

conda env create --file ./modulus.yaml --prefix ./modulus-graphcast

conda activate ./modulus-graphcast

cd $TMPDIR

rm -rf apex
pip uninstall -y apex
git clone https://www.github.com/nvidia/apex
cd apex
python3 setup.py install

NVTE_FRAMEWORK=pytorch \
    pip install git+https://github.com/NVIDIA/TransformerEngine.git@stable

pip uninstall -y dgl
pip install dgl -f https://data.dgl.ai/wheels/torch-2.3/cu121/repo.html

pip list
