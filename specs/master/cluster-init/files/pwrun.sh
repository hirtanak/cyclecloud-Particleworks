#!/bin/bash
#PBS -j oe
#PBS -l select=2:ncpus=44
NP=88

export PARTICLE_LICENSE_FILE=27000@<IPAddress>
source /etc/profile.d/pw.sh

# MPI settings
export MPI_ROOT="/opt/intel/impi/2018.4.274"
export I_MPI_ROOT=$MPI_ROOT
export I_MPI_DEBUG=5
export I_MPI_FABRICS=shm:ofa # for 2019, use I_MPI_FABRICS=shm:ofi
# H16r 
#export I_MPI_FABRICS=shm:dapl
#export I_MPI_DAPL_PROVIDER=ofa-v2-ib0
#export I_MPI_DYNAMIC_CONNECTION=0

# running config
INPUT=/mnt/exports/shared/home/azureuser/model_v2.adv

#Particleworks
#mpirun -np プロセス数 /path/to/module/app.solver.double -p scene -k simd -n プロセス当たりスレッド数 --job
#GPUの場合（8分程度）
#/path/to/module/app.solver.double -p scene -k cuda -g 0 -n 1

#Granuleworks
#CPUの場合
#/path/to/module/app.solver.double -p scene -k simd -n スレッド数
#GPUの場合
#/path/to/module/app.solver.double -p scene -k cuda -g 0 -n 1

mpirun -np ${NP} ${HOME}/apps/pw-linux-package/module/app.solver.double -p scene -k simd -n 1 --job 2>&1 | tee PWlog-`date +%Y%m%d_%H-%M-%S`.log
