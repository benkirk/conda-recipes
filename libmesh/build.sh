#!/bin/bash
set -ex

./configure \
    --help

./configure \
    CXX=mpicxx CXXFLAGS="-Wno-deprecated-declarations -Wno-unused-but-set-variable" \
    CC=mpicc CFLAGS="-Wno-unused-but-set-variable" \
    FC=mpif90 \
    METHODS="opt devel" \
    --prefix=$PREFIX \
    PETSC_DIR=$PREFIX --enable-petsc-required \
    --disable-strict-lgpl \
    --enable-tecio --with-tecio-x11-include=$PREFIX/x86_64-conda-linux-gnu/sysroot/usr/include \
    --enable-hdf5 --with-hdf5=$PREFIX \
    --with-boost=$PREFIX \
    --with-eigen-include=$PREFIX/include/eigen3 \
    --enable-tbb --with-tbb=$PREFIX \
    --enable-exodus \
    --disable-metaphysicl \
    --disable-dependency-tracking

#    --disable-exodus --disable-nemesis \

make -j 6 --no-print-directory --silent all
make -j 6 --no-print-directory --silent install
make -j 6 --no-print-directory --silent installcheck -C examples
