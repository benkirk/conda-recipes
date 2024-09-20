#!/usr/bin/env python

import os
from mpi4py import MPI
import jax
import jax.numpy as jnp
import mpi4jax

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
local_rank = int(os.environ["PMI_LOCAL_RANK"])

available_devices = jax.devices("gpu")
print(available_devices)
if len(available_devices) <= local_rank:
    raise Exception("Could not find enough GPUs")

target_device = available_devices[local_rank]



@jax.jit
def foo(arr):
   arr = arr + rank
   arr_sum, _ = mpi4jax.allreduce(arr, op=MPI.SUM, comm=comm)
   return arr_sum



with jax.default_device(target_device):
    a = jnp.zeros((1024, 1024))
    print(f"Rank {rank}, local rank {local_rank}, a.device is {a.devices()}")
    result = foo(a)
    print(f"Rank {rank}, local rank {local_rank}, result.device is {result.devices()}")

    import time
    print("Sleeping for 5 seconds if you want to look at nvidia-smi ... ")
    import time
    time.sleep(5)
    print("Done sleeping")



if rank == 0:
   print(result)
