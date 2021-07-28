#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

main() {
    assertgitclean
    assertfile "15-nvt.gro"
    assertfile "14-nvt.cpt"
    assertfile "npt.mdp"
    assertfile "topol.top"
    assertfile "index.ndx"

    echo -e "${YELLOW}Starting grompp..${NC}"
    qsub jobs/pbs-17-grompp.sh
    while [ ! -s "17-grompp.log" ]; do 
       sleep 1
    done
    less +F 17-grompp.log
    echo -e "${BLUE}Gromacs run complete.${NC}"
    git add mdout.mdp 17-grompp-pbs.out 17-grompp.log 17-npt.tpr
    git commit -m "Grompp for NPT"
    echo -e "${BLUE}Git log:${NC}"
    git log --oneline --graph | head
    echo -e "${BLUE}Last commit:${NC}"
    git log --name-status HEAD^..HEAD
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

