#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

main() {
    assertgitclean
    assertfile "3-newbox.gro"
    assertfile "topol.top"

    echo -e "${YELLOW}Starting solvate..${NC}"
    qsub jobs/pbs-4-solvate.sh
    sleep 2
    while [ -z "$(qstat | grep ravi | grep -v 315772)" ] || [ ! -s "4-solvate.log" ]; do 
       sleep 1
    done
    less +F 4-solvate.log
    echo -e "${BLUE}Gromacs run complete.${NC}"
    git add 4-solvated.gro 4-solvate.log 4-solvate-pbs.out topol.top
    git commit -m "Solvate"
    echo -e "${BLUE}Git log:${NC}"
    git log --oneline --graph | head
    echo -e "${BLUE}Last commit:${NC}"
    git log --name-status HEAD^..HEAD
    rm \#topol* 
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

