# DCTCP experiment (ns3 standalone, simbricks)

**Codename:** `dctcp`

This experiment validates the ns-3 and SimBricks line in `Figure 1`.
It takes around 240 mins to make one data point for Simbricks. We suggest choosing only a few key data points to run depending on the available time.

For simplicity we do not include instructions for the physical system baseline (requires very specific switch, network, and end-host configurations that are challenging to replicate). These results also closely match other measurements in other dctcp publications.

## Overview

In this experiment, we setup a network in dumbbell topology (two switches connected by a bottleneck link) and attach two servers at its left and two clients at its right side. The hosts are running an Iperf TCP test for 10 seconds with MTU size 4KB.

The DCTCP experiment requires two patches to complete its configuration.
1. Gem5 cache latency 
```bash
# In directory /simbricks/sims/external/gem5
$ patch -p1 < cache_conf.patch
```

2. Network interface entry size
```bash
# In directory /simbricks
$ git apply net_entry_size.patch
```

3. Rebuild Simbricks library
```bash
# In directory /simbricks
$ make -j `nproc`
```

We made a change on ns-3 repository after building the docker image. If you are using pre-built docker image, please update the ns-3 script.

4. Git pull ns-3 
```bash
# In directory /simbricks/sims/external/ns-3
$ git pull
```
For the SimBricks line, we set up the experiment using the combination [ gem5-timingCPU + i40e + ns3 ].
For the ns-3 line, we set up the same topology as using standalone ns-3.
The script `simbricks-dctcp.sh` generates the data for both lines.

The execution results `dctcp_ns3.data` and `dctcp_simbricks.data` are generated in `/simbricks/experiments/ae/`.

```bash
# In directory /simbricks/experiments/
$ ./ae/simbricks-dctcp.sh

```

## Running the SimBricks data points manually

A single SimBricks data point takes about 4 hours to run.

The `/simbricks/experiments/pyexps/ae/f1_dctcp.py` script generates 13 experiments with varying K-value from 0~199680 and step size 16640. It’s possible to run a specific K-value experiment by providing the filter option below and substituting [K] with the data point we are interested in. (without [ ] ). Note that the experiment won’t be generated if the K value isn’t a multiple of 16640.

The output JSON file is generated in the directory `/simbricks/experiments/out/` directory with the name `gt-ib-dumbbell-DCTCPm[K]-4000-1.json`. 

```bash
# In directory /simbricks/experiments/
$ python3 run.py pyexps/ae/f1_dctcp.py --filter gt-ib-dumbbell-DCTCPm[K]-4000 --force --verbose
```

## Processing Output
To process the raw output data from ns-3, use the script `pyexps/ae/data_ns3_dctcp.py`. 
```bash
# In directory /simbricks/experiments/
$ python3 pyexps/ae/data_ns3_dctcp.py ../sims/external/ns3 > ae/dctcp_ns3.data
```
To process the raw output data from SimBricks, use the script `pyexps/ae/data_sb_dctcp.py`. 
(`./out` can be replaced with a path to the `dctcp/paper/` or `dctcp/updated` directory in the artifact repo to process the data used in the paper instead):
```bash
# In directory /simbricks/experiments/
python3 pyexps/ae/data_sb_dctcp.py out/ > ae/dctcp_simbricks.data
```

The artifact repository also has the gnuplot file `dctcp.gnuplot` that converts this data (stored in `dctcp_ns3.data` and `dctcp_simbricks.data`) into the pdf graph similar to the paper (we use a tikz version).
```bash
$ gnuplot dctcp.gnuplot > result.pdf 
```

## Physical Testbed Results

Finally for completeness we also include the raw iperf logs we collected in the
physical testbed in the `paper/testbed-results` directory. As described in the
paper, the graph only uses the 4K MTU.
