SHELL := /bin/bash

top_dir := $(shell git rev-parse --show-toplevel)
config_env := ml conda

%: %.yaml
	[ -d $@ ] && mv $@ $@.old && rm -rf $@.old &
	$(MAKE) solve-$*
	$(config_env) && conda env create --file $< --prefix $@
	$(config_env) && conda activate ./$@ && conda-tree deptree --small 2>/dev/null || /bin/true
	$(config_env) && conda activate ./$@ && pipdeptree --all 2>/dev/null || /bin/true
	$(config_env) && conda activate ./$@ && conda list

solve-%: %.yaml
	$(config_env) && conda env create --file $< --prefix $@ --dry-run

%: %.sh
	[ -d $@ ] && mv $@ $@.old && rm -rf $@.old &
	./$<

run-%-container: %.sif
	module load apptainer ; \
	singularity \
	  --quiet \
	  shell \
	  --nv --cleanenv \
	  --writable-tmpfs \
	  --bind /glade \
	  ./$<

%.sif %.sif: %.def
	module load apptainer ; \
	export APPTAINER_TMPDIR=/var/tmp/ ; \
	export APPTAINER_CACHEDIR=${WORK}/.apptainer-cache/ ; \
	singularity build --nv $@ $<

.PRECIOUS: %.sif
