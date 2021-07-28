#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

main() {
    assertgitclean
    assertfile "2-complex.gro"

    echo -e "${YELLOW}Starting editconf..${NC}"
    qsub jobs/pbs-3-editconf.sh
    sleep 2
    while [ -z "$(qstat | grep ravi | grep -v 315772)" ] || [ ! -s "3-editconf.log" ]; do 
       sleep 1
    done
    less +F 3-editconf.log
    echo -e "${BLUE}Gromacs run complete.${NC}"
    git add 3-newbox.gro 3-editconf.log 3-editconf-pbs.out
    git commit -m "Generate bounding box"
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

