#!/usr/bin/env bash

source ../../profile.d/modules.sh
ml conda cudnn/8.8.1.3-12

conda env create --file ./modulus.yaml --prefix ./modulus-graphcast

conda activate ./modulus-graphcast

cd $TMPDIR

rm -rf apex
pip uninstall apex
git clone https://www.github.com/nvidia/apex
cd apex
python3 setup.py install

NVTE_FRAMEWORK=pytorch \
    pip install git+https://github.com/NVIDIA/TransformerEngine.git@stable

pip list
