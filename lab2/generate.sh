#!/bin/sh

p4testgen \
    -DP4_TESTGEN=1 \
    --target bmv2 \
    --arch v1model \
    --test-backend STF \
    --track-coverage STATEMENTS \
    --stop-metric MAX_STATEMENT_COVERAGE \
    --max-tests 0 \
    --print-coverage \
    --path-selection GREEDY_STATEMENT_SEARCH \
    --out-dir tests \
    mystery.p4
