SHELL := /bin/bash

PBS_ACCOUNT ?= SCSG0001

top_dir := $(shell git rev-parse --show-toplevel)
config_env := true
config_conda_build := #$(config_env) && which conda && conda activate ./conda_build

#vision_extra_channels := -c file://$(shell pwd)/output
libmesh_extra_args := -m libmesh/configs/osx_64_mpiopenmpiscalarreal.yaml

%: %.yaml
	[ -d $@ ] && mv $@ $@.old && rm -rf $@.old &
	$(MAKE) solve-$*
	$(config_env) && conda env create --file $< --prefix $@
	$(config_env) && conda activate ./$@ && conda-tree deptree --small 2>/dev/null || conda list

solve-%: %.yaml
	$(config_env) && conda env create --file $< --prefix $@ --dry-run

conda-build-%: %/
	$(MAKE) conda_build
	mkdir -p logs/ output/
	conda-build $($*_extra_channels) --channel conda-forge --output-folder output/ $($*_extra_args) ./$< 2>&1 | tee logs/$*.log

pbs-build-%: %
	PATH=/glade/derecho/scratch/vanderwb/experiment/pbs-bashfuncs/bin:$$PATH ;\
          qcmd -q main -A $(PBS_ACCOUNT) -l walltime=1:00:00 -l select=1:ncpus=128 \
          -- $(MAKE) conda-build-$*
