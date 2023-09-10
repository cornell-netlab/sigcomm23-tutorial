#!/bin/sh

if [ $# -eq 0 ]
then
    echo "usage: execute.sh <stf>"
    exit 1
fi

cp $@ reference.stf
/p4c/build/run-bmv2-test.py \
    /p4c \
    reference.p4
rm reference.stf
