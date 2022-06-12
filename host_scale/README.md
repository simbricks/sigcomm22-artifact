# Host scalability

This script will run the experiments for `Figure 7` results.

## Overview

It can take around 150 mins to run a single data point (refer Figure 7). Feel free to choose a few data points to run depending on the available time and actual hardware.

In this script, we will run five simulations, each will have 1/4/9/14/20 client hosts and one server host connected by a switch. The clients will run UDP test with the bandwidth set to `1000Mbps/number of clients`. 

The execution result will generate corresponding JSON files under `simbricks/experiments/out` directory and  those raw data will be processed into `host_scale.data` under `simbricks/experiments/ae/` directory.

```bash
# In simbricks/experiments/ directory
$ ./ae/host-scale.sh
```

## Run a single data point manually

To run a single data point manually, run below command in `simbricks/experiments` directory.

Substitute `[N]` into one of `[1, 4, 9, 14, 20]` (without [ ]). 

```bash
$ python3 run.py pyexps/ae/f7_scale.py --filter host-gt-ib-sw-1000m-[N] --force --verbose
```