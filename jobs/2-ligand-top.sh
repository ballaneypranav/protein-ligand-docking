#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

main() {
    assertgitclean
    assertfile "1-pdb2gmx.gro"
    assertfile "LIGX.gro"
    assertfile "topol.top"
    assertfile "LIGX.itp"
    
    protein_mol=$(head -2 1-pdb2gmx.gro | tail -1 | awk '{$1=$1};1')
    ligand_mol=$(head -2 LIGX.gro | tail -1 | awk '{$1=$1};1')
    sum=$(($protein_mol + $ligand_mol))
    
    head -n 1 1-pdb2gmx.gro >> 2-complex.gro
    echo " ${sum}" >> 2-complex.gro
    tail -n+3 1-pdb2gmx.gro | head -n-1 >> 2-complex.gro
    tail -n+3 LIGX.gro | head -n-1 >> 2-complex.gro
    echo -e "${BLUE}Complex generated.${NC}"

    mv topol.top topol.top.backup
    head -n 22 topol.top.backup >> topol.top
    echo "; Include ligand topology" >> topol.top
    echo "#include \"LIGX.itp\"" >> topol.top
    echo >> topol.top
    tail -n+23 topol.top.backup >> topol.top
    echo "LIGX        1" >> topol.top
    echo -e "${BLUE}Ligand topology included.${NC}"
    rm topol.top.backup

    git add 2-complex.gro topol.top
    git commit -m "Generate complex and topology."
    echo -e "${BLUE}Git log:${NC}"
    git log --oneline --graph | head
    echo -e "${BLUE}Last commit:${NC}"
    git log --name-status HEAD^..HEAD
}

gitinit() {
    git init
    git add . && git commit -m "Initialize git on server"
}

assertfile() {
    if [ ! -s $1 ]; then
        echo -e "${RED}File $1 not found!${NC}" >&2
        exit 1
    fi
}

assertdir() {
    if [ ! -d $1 ]; then
        echo -e "${RED}Directory $1 not found!${NC}" >&2
        exit 1
    fi
}

assertgitclean() {
    if [ ! -z "$(git status --porcelain)" ]; then 
        echo -e "${RED}Directory has uncommitted changes. Exiting.${NC}" >&2
        exit 1
    fi
}

assertjobcomplete() {
    if [ ! -z "$(qstat | grep ravi | grep -v 315772)" ]; then 
        echo -e "${GREEN}PBS job complete.${NC}" >&2
        exit 1
    fi
}

main "$@"

