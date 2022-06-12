# Impact of chanign Corundum NIC PCIe latency 

**Codename:** `corundum_pcilat`
This experiment validates results in `8.1`.

## Overview
For this experiment, we compare the netperf throughput for between `500ns and 1us` Corundum PCIe latency configuration.
The `500ns` configuration is the same output as `nf-gt-sw-cb-1.json` produced in [netperf](netperf/README.md) experiment. 

Only `1us` configuration simulation needs rerun. It will take around 12 hours to finish.
To run use the following command in the `simbricks/experiment` directory.
```bash
$ python3 run.py pyexps/ae/corundum_pcilat.py --filter cblat-gt-sw --verbose --force
```

## Processing Output
This experiment does not produce a graph, instead we compare the throughtput data from the `clinet host` output. 
After the simulation finishes, `cblat-gt-sw-1.json` file will be gererated in `simbricks/experiment/out` directory.

Then  the `experiments/pyexps/ae/data_netperf.py.py` script does some reformatting and prints the throughput.
```bash
$ python3 pyexps/ae/data_cbpcilat.py out/
```

