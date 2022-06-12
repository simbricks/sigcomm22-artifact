# Comparison with dist-gem5

This experiment will validate the dist-gem5 data and SimbBricks data in `7.3.1 (Figure 9)`.  

Simulation time varies from ~400min to ~1700 min. Please refer to the paper and feel free to choose only a few data points to run. 

## Overview

This experiment configures 2~32 hosts to connect to a switch. Half of the hosts are running iperf server and the other half are the clients sending UDP packets at 1Gbps rate.

The script generates the result file `dist.data` in `/simbricks/experiments/ae/` directory.

For running dist-gem5 smoothly, the user should make sure `$ ssh localhost`
command works. For this using the `simbricks/simbricks-dist-worker` image as
with the dist memcache experiment is easiest. Please refer to the instructions
in that readme for how to start the container (start first with sshd, and then
use `docker exec` to get a shell).

```bash
# make sure ssh localhost works
# Run in /simbricks/experiments/ae/
$ ./ae/dist-gem5.sh

```

## Running single data points manually

To generate a single data point manually, change the following file:

`simbricks/sims/external/gem5/util/dist/test/exp_run.sh` 

```bash
bash run_x86.sh 2 > run-2.out
#bash run_x86.sh 16 > run-16.out
#bash run_x86.sh 32 > run-32.out
```

Usage: `bash run_x86.sh [num_hosts]` 

and same for Simbricks scripts in:

`simbricks/sims/external/gem5/util/simbricks/exp_run.sh`