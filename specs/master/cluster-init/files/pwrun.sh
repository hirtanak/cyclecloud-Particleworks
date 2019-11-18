#!/bin/bash
#PBS -j oe
#PBS -l select=2:ncpus=44
NP=88

#export PARTICLE_LICENSE_FILE=27000@<IPAddress>
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOME}/apps/pw-linux-package/module
export DISPLAY=localhost:0.0

# MPI settings HB anf HC setting
export MPI_ROOT="/opt/intel/impi/2018.4.274"
export I_MPI_ROOT=$MPI_ROOT
export I_MPI_DEBUG=5
export I_MPI_FABRICS=shm:ofa # for 2019, use I_MPI_FABRICS=shm:ofi
source /opt/intel/impi/2018.4.274/bin64/mpivars.sh
# H16r 
#export I_MPI_FABRICS=shm:dapl
#export I_MPI_DAPL_PROVIDER=ofa-v2-ib0
#export I_MPI_DYNAMIC_CONNECTION=0
