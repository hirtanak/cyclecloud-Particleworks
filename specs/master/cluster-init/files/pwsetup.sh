#!/bin/sh

# General 
export PW_DIR="${HOME}/apps/pw-linux-package"
#export PARTICLE_LICENSE_FILE=27000@<IPAddress>

# Platform MPI
export MPI_HASIC_UDAPL=ofa-v2-ib0

# Intel MPI
export MPI_ROOT="/opt/intel/impi/2019.5.281"
export I_MPI_ROOT=$MPI_ROOT
export I_MPI_DEBUG=5
export I_MPI_FABRICS=shm:ofa # for 2019, use I_MPI_FABRICS=shm:ofi
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${HOME}/apps/pw-linux-package/module
source /opt/intel/impi/2019.5.281/intel64/bin/mpivars.sh
