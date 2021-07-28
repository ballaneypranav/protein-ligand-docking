#!/usr/bin/env bash

ligand_filename="LIGX.xyz"
protein_filename="protein.pdb"
ff="charmm36-feb2021.ff"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

main() {
    gitinit
    echo "${YELLOW}Created git repository${NC}"
    assertgitclean
    assertfile "protein.pdb"
    assertdir "charmm36-feb2021.ff"

    echo -e "${YELLOW}Starting pdb2gmx run..${NC}"
    qsub jobs/pbs-1-pdb2gmx.sh
    sleep 2
    while [ -z "$(qstat | grep ravi | grep -v 315772)" ] || [ ! -s "1-pdb2gmx.log" ]; do 
       sleep 1
    done
    less +F 1-pdb2gmx.log
    echo -e "${BLUE}Gromacs run complete.${NC}"
    git add posre.itp topol.top 1-pdb2gmx.gro 1-pdb2gmx.log 1-pdb2gmx-pbs.out
    git commit -m "Generate protein starting structure and topology"
    echo -e "${BLUE}Git log:${NC}"
    git log --oneline --graph
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

