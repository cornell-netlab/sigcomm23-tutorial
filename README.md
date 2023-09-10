# Overview

This repository contains code for the lab exercises in the SIGCOMM '23
tutorial "Designing Networks for Test". It relies on three other
software packages: [p4c](https://github.com/p4lang/p4c),
[Bmv2](https://github.com/p4lang/behavioral-model), and
[Mininet](https://github.com/mininet/mininet).

To streamline the process of installing these dependencies, we have
assembled a Docker container with all three packages.

# Instructions

1. Install Docker (https://docker.com/get-started)

2. Pull the tutorial container image:

```
% docker pull jnfoster/sigcomm23-tutorial:squashed

```

3. Start the container in interactive and privileged mode:
```
% docker run -it --privileged=true jnfoster/sigcomm23-tutorial:squashed 
```

4. Within the container, fetch the latest version of this repository:
```
root@add3d1327646:/# ./go.sh
```

For further instructions, see the README file in each lab directory.
