# Netperf Cross-product combination

**Codename:** `netperf`

This experiment validates results in `7.2`  `Table 1` and `Table 3` in the
appendix.

Each experiment requires 5 cores. It will take ~22 hours to run all the
experiments in `Table 1`, and all experiments for `Table 3` will take over 72
hours.  We suggest you only pick a few data points to replicate.

## Running Experiments

The script by default runs all four combinations listed in `Table 1`.  

User can give the argument `all` to the script to run all the combinations
listed in Appendix 4, Table 3

The execution will generate `netperf.data` in the directory
`/simbricks/experiments/ae/`.

```bash
# In directory /simbricks/experiments/
$ ./ae/netperf.sh [selected/all]
```

### Manually Running Individual Configurations

You can manually run individual data points. The python orchestration script
`pyexps/ae/t1_netperf.py`, contains the full cross-product of configurations.
You can list them with `simbricks-run --list pyexps/ae/t1_netperf.py`.

The names are coded as follows: `nf-[cpy_type]-[net_type]-[nic_type]`. Here is
an overview of the simulator abbreviations:

* CPU simulator:`qemu-kvm(qemu)`, `gem5-timing(gt)`, `qemu-timing(qt)`.
* NIC simulator: `i40e_behavioral(ib)`, `corundum_behavioral(cb)`, `corundum_verilator(cv)`
* Network simulator: `switch_behavioral(sw)`, `ns-3(ns3)`

Then use the `--filter` parameter to specify which ones to run (also supports
globs):

```bash
# In directory /simbricks/experiments/
$ simbricks-run pyexps/ae/t1_netperf.py --filter "nf-qt-sw-*" --force --verbose
```

## Processing Output

The experiment produces a latex table with netperf latency and throughput, as
well as the simulation time. The `pyexps/ae/data_netperf.py` script parses all
json files and generates the table:

```bash
$ python3 pyexps/ae/data_netperf.py ./out/
```
