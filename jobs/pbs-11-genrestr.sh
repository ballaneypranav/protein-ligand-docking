#!/bin/bash
#PBS -S /bin/bash
#PBS -N GROMACS_MD
#PBS -l select=1:ncpus=4
#PBS -l walltime=360:00:00
#PBS -q novoq
#PBS -o 11-genrestr-pbs.out
#PBS -e 11-genrestr-pbs.err
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
mpirun -np 1 gmx_mpi genrestr -f LIGX.gro -n index_LIGX.ndx -o posre_LIGX.itp -fc 1000 1000 1000 << EOF 2>&1 | tee 11-genrestr.log
3
q
exit
