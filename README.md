# Support for creating `conda` packages for various tools

A set of tools for creating custom `conda` packages using `conda-build`

## Quickstart
### Clone, including submodules
```pre
git clone --recurse-submodules https://github.com/benkirk/conda-recipes.git
cd conda-recipes/
```
### Create a minimal `conda` environment containing `conda-build`
We patch `conda-build` in this step specifically to override its `RPATH` stripping.

`conda-build` likes to strip all rpaths that point to host directories, which makes perfect sense for the typical use case - building packages in an isolated environment to ensure proper redistribution.  

However, here we want to keep external dependences to ceertain host libraries, as we are intentionally building packages designed only to run on this host. We therefore patch the `conda-build` file `post.py` and introduce the configurable `host_runpath_whitelist`.
```pre
# creates ./conda_build/ from ./conda_build.yaml
make conda-build
```

### Create a `conda` package:
```pre
make conda-build-nccl-ofi
```

### Querying the local channel `./output/`:
```pre
conda search -c file://$(pwd)/output --override-channels -i 
```

## `conda-build` documentation
https://docs.conda.io/projects/conda-build/en/stable/
- https://docs.conda.io/projects/conda-build/en/stable/concepts/recipe.html
- https://docs.conda.io/projects/conda-build/en/stable/resources/index.html
  
---

## Supported packages

### `nccl-ofi-plugin`
