#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

main() {
    assertgitclean
    assertfile "LIGX.gro"
    assertfile "index_LIGX.ndx"

    echo -e "${YELLOW}Starting Gromacs..${NC}"
    qsub jobs/pbs-11-genrestr.sh
    sleep 2
    while [ ! -s "11-genrestr.log" ]; do 
       sleep 1
    done
    less +F 11-genrestr.log
    echo -e "${BLUE}Gromacs run complete.${NC}"
    git add 11-genrestr-pbs.out 11-genrestr.log posre_LIGX.itp
    git commit -m "Generate position restraints for ligand"
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

