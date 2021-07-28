#!/bin/bash
#PBS -S /bin/bash
#PBS -N GROMACS_MD
#PBS -l select=1:ncpus=32
#PBS -l walltime=360:00:00
#PBS -q novoq
#PBS -o out.txt
#PBS -e err.txt
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
cd covid-md/2933805
pwd
ls
# mpirun -np 32 gmx_mpi mdrun  -ntomp 1 -v -deffnm 5-neutralized -c 6-minimized-gro 
# mpirun -np 1 gmx_mpi pdb2gmx -f protein.pdb -o 1-pdb2gmx.gro -ff charmm36-feb2021 -water spce 2>&1 | tee 1-pdb2gmx.log
# create complex and include topology
# mpirun -np 1 gmx_mpi editconf -f 2-complex.gro -o 3-newbox.gro -bt dodecahedron -d 1.0 2>&1 | tee 3-newbox.log
# mpirun -np 1 gmx_mpi solvate -cp 3-newbox.gro -cs spc216.gro -p topol.top -o 4-solvated.gro 2>&1 | tee 4-solvate.log
# mpirun -np 1 gmx_mpi grompp -f ions-PME.mdp -c 4-solvated.gro -p topol.top -o 4-solvated.tpr -maxwarn 1 2>&1 | tee 4-grompp.log
# mpirun -np 1 gmx_mpi genion -s 4-solvated.tpr -o 5-neutralized.gro -p topol.top -pname NA -nname CL -neutral << EOF 2>&1 | tee 5-neutralize.log
# 15
# mpirun -np 1 gmx_mpi grompp -f em.mdp -c 5-neutralized.gro -p topol.top -o 5-neutralized.tpr 2>&1 | tee 5-grompp.log
# mpirun -np 32 gmx_mpi mdrun -deffnm 5-neutralized -v -c 6-minimized.gro 2>&1 | tee 6-minimization.log
mpirun -np 1 gmx_mpi energy -f 5-neutralized.edr -o 6-minimized-potential.xvg << EOF 2>&1 | tee 6-energy.log
10 0
exit
