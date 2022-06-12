# DCTCP experiment (ns3 standalone, simbricks)

**Codename:** `dctcp`

This experiment will validate ns-3 line and SimBricks line in `Figure 1`
It will take around 240 mins to make one data point for Simbricks. We suggest choosing only a few key data points to run depending on the available time.

For simplicity we do not include instructions for the physical system baseline (requires very specific switch, network, and end-host configurations that are challenging to replicate). These results also closely match other measurements in other dctcp publications.

## Overview

In this experiment, we setup a network in dumbbell topology (two switches connected by a bottleneck link) and attach two servers at left side and two clients at right side. The hosts are running Iperf TCP test for 10 seconds. MTU size 4KB.

DCTCP experiment has two patches to complete its configuration.
1. Gem5 cache latency 
```bash
# In directory /simbricks/sims/external/gem5
$ git apply cache_conf.patch
$ rm ready
```

2. Network interface entry size
```bash
# In directory /simbricks
$ git apply net_entry_size.patch
$ make clean
```

3. Rebuild Gem5 and Simbricks library
```bash
# In directory /simbricks
$ make 
$ make external
```

For SimBricks lines, we setup the experiment using [ gem5-timingCPU + i40e + ns3 ] combination.

For ns-3 lines, we setup the same topology using standalone ns-3.

The script `simbricks-dctcp.sh`  runs both Simbricks lines and ns-3 lines.

The execution results are `dctcp_ns3.data` and `dctcp_simbricks.data` , which will be generated in  `/simbricks/experiments/ae/` .

```bash
# In directory /simbricks/experiments/
$ ./ae/simbricks-dctcp.sh

```

## Running the SimBricks data points manually

One SimBricks data point takes about 4 hours to run.

The `/simbricks/experiments/pyexps/ae/f1_dctcp.py` script generates 13 experiments with varying K-value from 0~199680 and step size 16640. It’s possible to run a specific K-value experiment by providing the filter option below and substituting [K] with the data point we are interested in. (without [ ] ). Note that the experiment won’t be generated if the K value isn’t a multiple of 16640.

The output JSON file will be generated in the directory `/simbricks/experiments/out/` directory. The file will be named as `gt-ib-dumbbell-DCTCPm[K]-4000-1.json`. 

```bash
# In directory /simbricks/experiments/
$ python3 run.py pyexps/ae/f1_dctcp.py --filter gt-ib-dumbbell-DCTCPm[K]-4000 --force --verbose
```

## Processing Output
To process the raw output data from ns-3, use the `pyexps/ae/data_ns3_dctcp.py` script. 
```bash
# In directory /simbricks/experiments/
$ python3 pyexps/ae/data_ns3_dctcp.py ../sims/external/ns3 > ae/dctcp_ns3.data
```
To process the raw output data from SimBricks, use the `pyexps/ae/data_sb_dctcp.py` script. 
(`./out` can be replaced with a path to the `dctcp/paper/` or `dctcp/updated` directory in the artifact repo to process the data used in the paper):
```bash
# In directory /simbricks/experiments/
python3 pyexps/ae/data_sb_dctcp.py out/ > ae/dctcp_simbricks.data
```

The artifact repository also has gnuplot file dctcp.gnuplot that converts this data (stored in `dctcp_ns3.data` and `dctcp_simbricks.data`) into the pdf graph similar to the paper (we use a tikz version).
```bash
$ gnuplot dctcp.gnuplot > result.pdf 
```

