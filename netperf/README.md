# Netperf Cross-product combination

This experiment validates results in `7.2`  `Table 1`.

It will take ~22 hours to run all the experiments in `Table 1`.  Each experiment requires 5 cores. 

## Overview

The script by default runs all four combinations listed in `Table 1`.  

User can give the argument `all` to the script to run all the combinations listed in Appendix 4, Table 3

The execution will generate `netperf.data` in the directory `/simbricks/experiments/ae/`. 

```bash
# In directory /simbricks/experiments/
$ ./ae/netperf.sh [selected/all]
```

## Running all the combinations

To run all the combinations listed in `Table 3` in Appendix 4, the user can run the command below.

Note that it will take more than 72 Hours to complete, so we again suggest picking a few points to run and changing the filter parameter as described below. The result files will be generated under `/simbricks/experiments/out/`. 

```bash
# In directory /simbricks/experiments/
$ python3 run.py pyexps/ae/t1_netperf.py --filter nf-* --force --verbose
```

The `t1_netperf.py` script will generate all the combinations of simulators, which are the cross product of:

CPU simulator: `gem5-kvm`, `qemu-kvm(qemu)`, `gem5-timing(gt)`, `qemu-timing(qt)`.

NIC simulator: `i40e_behavioral(ib)`, `corundum_behavioral(cb)`, `corundum_verilator(cv)`

Network simulator: `switch_behavioral(sw)`, `ns-3(ns3)`

We can can run a single permutation by supplying `--filter` with `nf-[cpy_type]-[net_type]-[nic_type]` and replacing with the short names of each type without brackets. Note that gem5-kvm CPU is only used for making a checkpoint.