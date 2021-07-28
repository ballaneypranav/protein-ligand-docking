#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

main() {
    assertgitclean
    assertfile "21-md.tpr"

    echo -e "${YELLOW}Starting mdrun..${NC}"
    qsub jobs/pbs-22-mdrun-md.sh
    sleep 2
    while [ ! -s "22-md.log" ]; do 
       sleep 1
    done
    less +F 22-md.log
    echo -e "${BLUE}Gromacs run complete.${NC}"
    exit
    git add 21-md.cpt 21-md.edr 21-md.log 21-md.xtc 22-mdrun-md-pbs.out 22-md.gro 22-md.log
    git commit -m "MD run"
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

