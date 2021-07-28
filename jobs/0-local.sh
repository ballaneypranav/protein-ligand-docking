#!/usr/bin/env zsh

ligand_filename="LIGX.xyz"
protein_filename="protein.pdb"
ff="charmm36-feb2021.ff"

set -e

main() {
    #assertgitclean
    assertfile $ligand_filename
    assertfile $protein_filename
    assertdir $ff

    printc -C lemon "Converting ${ligand_filename} to LIGX.mol2"
    obabel -ixyz LIGX.xyz -omol2 -OLIGX.mol2
    assertfile "LIGX.mol2"
    git add LIGX.mol2 
    git commit -m "Convert ligand to mol2 using openbabel"

    echo 
    printc -C lemon "Running acpype"
    acpype -i LIGX.mol2
    cp LIGX.acpype/LIGX_GMX.gro LIGX.gro
    cp LIGX.acpype/LIGX_GMX.itp LIGX.itp
    git add LIGX.acpype LIGX.gro LIGX.itp
    git commit -m "Generate ligand topology using acpype"

    curdir=${PWD##*/}
    echo $curdir
    cd ..
    zip -r $curdir.zip $curdir
    
}

assertfile() {
    if [ ! -s $1 ]; then
        printc -C maraschino "File $1 not found!" >&2
        exit 1
    fi
}

assertdir() {
    if [ ! -d $1 ]; then
        printc -C maraschino "Directory $1 not found!" >&2
        exit 1
    fi
}

assertgitclean() {
    if [ ! -z "$(git status --porcelain)" ]; then 
        printc -C maraschino "Directory has uncommitted changes. Exiting." >&2
        exit 1
    fi
}

main "$@"

