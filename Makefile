SHELL := /bin/bash -l

PBS_ACCOUNT ?= SCSG0001
ENV_PYTHON_VERSION ?= "3.11"

top_dir := $(shell git rev-parse --show-toplevel)
config_env := ml conda
config_conda_build := $(config_env) && conda activate ./conda_build
#vision_extra_channels := -c file://$(shell pwd)/output
libmesh_extra_args := -m libmesh/configs/osx_64_mpiopenmpiscalarreal.yaml

# about patch-post.py:
# total hack: conda-build likes to strip all rpaths that point to host directories. Which
# makes perfect sense for the typical use case.  However, here we want to keep those, as
# we are building packages designed only to run on this host, intentionally.
# (patch created by: diff -Naur conda_build/post.py{.old,} > <patchfile>)
%: %.yaml
	[ -d $@ ] && mv $@ $@.old && rm -rf $@.old &
	$(MAKE) solve-$*
	$(config_env) && conda env create --file $< --prefix $@
	$(config_env) && conda activate ./$@ && patchfile=$$(pwd)/patches/conda-build/patch-post.py && postdir=$$(find $$CONDA_PREFIX/lib -name post.py | xargs dirname) && cd $${postdir}/.. && pwd && patch -p0 < $${patchfile}
	$(config_env) && conda activate ./$@ && conda-tree deptree --small 2>/dev/null || conda list

solve-%: %.yaml
	$(config_env) && conda env create --file $< --prefix $@ --dry-run

conda-build-%: %/
	$(MAKE) --silent conda_build
	mkdir -p logs/ output/
	$(config_conda_build) && conda-build --python $(ENV_PYTHON_VERSION) $($*_extra_channels) --channel conda-forge --output-folder output/ $($*_extra_args) ./$< 2>&1 | tee logs/$*.log

pbs-build-%: %
	qcmd -q main -A $(PBS_ACCOUNT) -l walltime=2:00:00 -l select=1:ncpus=128 -l job_priority=premium \
          -- $(MAKE) conda-build-$*

clean:
	git clean -xdf --exclude=output/ --exclude=logs/ --exclude=conda_build/

clobber:
	git clean -xdf --exclude=output/ --exclude=logs/

distclean:
	git clean -xdf
