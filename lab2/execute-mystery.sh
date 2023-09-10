#!/bin/sh

if [ $# -eq 0 ]
then
    echo "usage: execute-mystery.sh <stf>"
    exit 1
fi

cp $@ mystery.stf
/p4c/build/run-bmv2-test.py \
    /p4c \
    mystery.p4
rm mystery.stf
