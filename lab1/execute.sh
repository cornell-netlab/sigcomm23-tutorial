#!/bin/sh

if [ $# -eq 0 ]
then
    echo "usage: execute.sh <stf>"
    exit 1
fi

cp $@ mystery.stf
/p4c/build/run-bmv2-test.py \
    /p4c \
    mystery.p4
if [ $? -eq 0 ]
then
    echo -e "\033[32m\033[1mPassed\033[0m"
else
    echo -e "\033[31m\033[1mFailed\033[0m"
fi
rm mystery.stf
