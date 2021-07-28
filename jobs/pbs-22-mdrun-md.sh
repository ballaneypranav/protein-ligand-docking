#!/bin/bash
#PBS -S /bin/bash
#PBS -N GROMACS_MD
#PBS -l select=1:ncpus=32
#PBS -l walltime=360:00:00
#PBS -q novoq
#PBS -o 22-mdrun-md-pbs.out
#PBS -e 22-mdrun-md-pbs.err
#PBS -j oe

# ## export environment variable from current session to job run-time ... better to use this always.
#PBS -V
module load gcc/6.1.0
module load intel/2018.3.222
module load gromacs/2019
cd $PBS_O_WORKDIR
which mpirun
NPROCS=`wc -l < $PBS_NODEFILE`

echo $NPROCS
export OMP_NUM_THREADS=1
export I_MPI_PRINT_VERSION=1

time
pwd
mpirun -np 32 gmx_mpi mdrun -deffnm 21-md -v -c 22-md.gro 2>&1 | tee 22-md.log
exit
