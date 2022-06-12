# Tofino experiment

## Overview

This experiment complements the [nopaxos](../nopaxos/README.md) experiment by running NOPaxos (Section 8.2, Figure 10) with the Tofino P4 switch sequencer configuration. Similar to [nopaxos](../nopaxos/README.md), the script sets up 3 hosts running NOPaxos replica and between 1 to 10 hosts running NOPaxos client, each connected to an i40e NIC simulator. In this experiment, the NIC simulators are connected to a switch simulator implemented using the Intel Tofino model. The switch simulator runs the NOPaxos switch P4 code which implements basic L2 switching and network sequencing for Ordered Unreliable Multicast (OUM).

Since the Tofino model (part of the Intel Barefoot SDE) is proprietary software, we are unable to include it in the repository. If you want to run the Tofino experiment, you need to first follow the instructions below:

1. Download the Intel Barefoot SDE (we have tested with SDE version 9.7.0)
2. Copy the SDE tar ball (e.g., `bf_sde_9.7.0.tgz`) to `/simbricks/docker/`
3. Rename the tar ball to `bf_sde.tgz`
4. Download the `p4_build.sh` script (from Intel Connectivity academy)
5. Copy the `p4_build.sh` script to `/simbricks/docker/`

Then run the following commands:

```bash
# In the root directory of a simbricks repo clone (on the host, not inside a container)
$ make docker-images-tofino

# After the image is built, start the container.
$ docker run --rm --device=/dev/kvm --privileged -it simbricks/simbricks:tofino /bin/bash

# Inside the docker contain, run the following commands.
$ $SDE/install/bin/veth_setup.sh
$ cd /simbricks
$ make build-images
$ cd experiments
$ ./ae/nopaxos-tofino.sh
```

The script parses experiment output and generates latency and throughput results in `/simbricks/experiments/ae/nopaxos.data`

## Running data points manually

The entire script takes a long time to run. To generate individual data points, modify the `for` loop in the `/simbricks/experiments/ae/nopaxos-tofino.sh` script with the intended number of client hosts, and run the script.
