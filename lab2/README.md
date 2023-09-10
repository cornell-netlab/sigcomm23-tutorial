# Overview

In this lab, your job is to find a bug (or more than one bug ;-) in
the provided [pipeline.p4](pipeline.p4) program. To do this, you can
use [p4testgen](https://p4.org/projects/p4testgen) to generate tests
for your code and run them against the reference implementation
[reference.p4](reference.p4).

If you need a hint, we have also provided you with some "golden" tests
in the [golden](golden) directory.

# Instructions

We have provided the following scripts:

* [generate.sh](generate.sh): run `p4testgen` on `mystery.p4` and
  generate tests. Feel free to edit this script to modify some of the
  command-line arguments. In particular, trying out different values
  of the random seed (`--seed <int>`) are likely to yield different
  results.

* [execute-mystery.sh](execute-mystery.sh): run a given test on 
  `mystery.p4`.
* [execute-reference.sh](execute-reference.sh): run a given test on
  `reference.p4`.

# Implementation Hints

* Start out my generating some tests for `mystery.p4` and running them
  on `reference.p4`. Then debug the failures by examining the trace in
  the corresponding test file.

* If you get stuck, try the "[golden](golden)" tests we have
  provided. That should get you on the right track.

* Of course, this lab would be trivial if you compared the two P4
  programs. To make it slightly harder for you, we have partially
  obfuscated the `reference.p4` program. Don't peek!