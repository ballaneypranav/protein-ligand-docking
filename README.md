# Protein Ligand Docking

### 0. Generate ligand topology

Prerequisites:

1. Ligand coordinates in XYZ file
2. Openbabel: `sudo apt install obabel`
3. [Antechamber](https://ambermd.org/GetAmber.php#ambertools)
4. [Acpype](https://alanwilter.github.io/acpype/)

#### Step 1: Convert `.xyz` coodinates to `.mol2`
```
obabel -ixyz LIGX.xyz -omol2 -OLIGX.mol2
```

#### Step 2: Run Acpype to generate topology
```
acpype -i LIGX.mol2
```

### 1. Generate protein starting structure and topology
Prerequisites: [charmm36-feb2021.ff](http://mackerell.umaryland.edu/charmm_ff.shtml#gromacs)

```
gmx pdb2gmx -f protein.pdb -o 1-pdb2gmx.gro -ff charmm36-feb2021 -water tip3p 2>&1 | tee 1-pdb2gmx.log
```

### 2. Combine structures and topologies

Follow the sections titled "Build the Complex" and "Build the Topology" described [here](http://www.mdtutorials.com/gmx/complex/02_topology.html). Make sure the filename of the complex is `2-complex.gro`.

### 3. Generate bounding box
```
gmx editconf -f 2-complex.gro -o 3-newbox.gro -bt dodecahedron -d 1.0 2>&1 | tee 3-newbox.log
```

### 4. Solvate
```
gmx solvate -cp 3-newbox.gro -cs spc216.gro -p topol.top -o 4-solvated.gro 2>&1 | tee 4-solvate.log
```

### 5. Preprocess
Download `ions-PME.mdp` from [here](./mdp-files/ions-PME.mdp).
```
gmx grompp -f ions-PME.mdp -c 4-solvated.gro -p topol.top -o 5-solvated.tpr -maxwarn 1 2>&1 | tee 5-grompp.log
```

### 6. Neutralize
```
gmx genion -s 5-solvated.tpr -o 6-neutralized.gro -p topol.top -pname NA -nname CL -neutral << 2>&1 | tee 6-neutralize.log
```

Select the SOL group (15) at the prompt.

### 7. Preprocess
Download `em.mdp` from [here](./mdp-files/em.mdp).
```
gmx grompp -f em.mdp -c 6-neutralized.gro -p topol.top -o 7-neutralized.tpr 2>&1 | tee 7-grompp.log
```

### 8. Energy Minimization
```
gmx mdrun -deffnm 7-neutralized -v -c 8-minimized.gro 2>&1 | tee 8-minimization.log
```

### 9. Plot Potential vs Timestep

* Get **GNUplot:** `sudo apt install gnuplot`
* If that doesn't work, try: `sudo apt install gnuplot-x11`
* Download [9-minimization-potential.p](./jobs/9-minimization-potential.p)

Extract potential data from EDR file:
```
gmx energy -f 7-neutralized.edr -o 9-minimized-potential.xvg 2>&1 | tee 16-energy.log
```

Select potential at the prompt. Plot using gnuplot:

```
gnuplot 9-minimization-potential.p
```

### 10. Create an index for the ligand

```
gmx make_ndx -f LIGX.gro -o index_LIGX.ndx 2>&1 | tee 10-index.log
```
Enter the following at the prompt to select all ligand atoms other than hydrogens:
```
0 & ! a H*
q
```

### 11. Generate position restraints for ligand
```
gmx genrestr -f LIGX.gro -n index_LIGX.ndx -o posre_LIGX.itp -fc 1000 1000 1000 2>&1 | tee 11-genrestr.log
```
Select the ligand (3) at the prompt.

### 12. Include the position restraints in the system topology
Follow the section titled `Restraining the Ligand` from [here](http://www.mdtutorials.com/gmx/complex/06_equil.html).

### 13. Create an index for the system
```
gmx make_ndx -f 8-minimized.gro -o index.ndx 2>&1 | tee 13-index.log
```
Enter the following at the prompt to group the protein and the ligand:
```
1 | 13
q
```

### 14. Preprocess for NVT
Download [nvt.mdp](./mdp-files/nvt.mdp).
```
gmx grompp -f nvt.mdp -c 8-minimized.gro -r 8-minimized.gro -p topol.top -n index.ndx -o 14-nvt.tpr 2>&1 | tee 14-grompp.log
```

### 15. NVT Run
```
gmx mdrun -deffnm 14-nvt -v -c 15-nvt.gro 2>&1 | tee 15-nvt.log
```

### 16. Plot Temperature from NVT
* Download [16-nvt-temperature.p](./jobs/16-nvt-temperature.p)
Extract temperature data from EDR file:
```
gmx energy -f 14-nvt.edr -o 16-nvt-temperature.xvg 2>&1 | tee 16-energy.log
```

Select temperature at the prompt. Plot using gnuplot:

```
gnuplot 16-nvt-temperature.p
```

### 17. Preprocess for NPT
Download [npt.mdp](./mdp-files/npt.mdp).
```
gmx grompp -f npt.mdp -c 15-nvt.gro -t 14-nvt.cpt -r 15-nvt.gro -p topol.top -n index.ndx -o 17-npt.tpr 2>&1 | tee 17-grompp.log
```

### 18. NPT Run 
```
gmx mdrun -deffnm 17-npt -v -c 18-npt.gro 2>&1 | tee 18-npt.log
```

### 19. Plot Pressure from NPT
* Download [19-npt-pressure.p](./jobs/19-npt-pressure.p)
Extract pressure data from EDR file:
```
gmx energy -f 17-npt.edr -o 19-npt-pressure.xvg 2>&1 | tee 19-energy-pressure.log
```

Select pressure at the prompt. Plot using gnuplot:

```
gnuplot 19-nvt-pressure.p
```

### 20. Plot Density from NPT
* Download [20-npt-density.p](./jobs/20-npt-density.p)
Extract density data from EDR file:
```
mpirun -np 1 gmx_mpi energy -f 17-npt.edr -o 20-npt-density.xvg 2>&1 | tee 20-energy-density.log
```

Select density at the prompt. Plot using gnuplot:

```
gnuplot 20-nvt-density.p
```

### 21. Preprocess for MD
Download [md.mdp](./mdp-files/md.mdp).
```
gmx grompp -f md.mdp -c 18-npt.gro -t 17-npt.cpt -r 18-npt.gro -p topol.top -n index.ndx -o 21-md.tpr 2>&1 | tee 21-grompp.log
```

### 22. MD Run
```
gmx mdrun -deffnm 21-md -v -c 22-md.gro 2>&1 | tee 22-md.log
```