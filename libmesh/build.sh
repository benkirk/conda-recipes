#!/bin/bash
set -ex

./configure \
    --help

./configure \
    CXX=mpicxx CXXFLAGS="-Wno-deprecated-declarations -Wno-unused-but-set-variable" \
    CC=mpicc \
    FC=mpif90 \
    METHODS="devel" \
    --prefix=$PREFIX \
    PETSC_DIR=$PREFIX --enable-petsc-required \
    --disable-exodus --disable-nemesis \
    --disable-strict-lgpl \
    --enable-tecio \
    --with-methods="devel" \
    --enable-hdf5 --with-hdf5=$PREFIX \
    --with-boost=$PREFIX \
    --disable-dependency-tracking

make -j 6 --no-print-directory --silent all
make -j 6 --no-print-directory --silent install
make -j 6 --no-print-directory --silent installcheck
