# In-network processing usecase

## Overview

This experiment validates the Network-Ordered Paxos (NOPaxos) results in Section 8.2 (Figure 10) of the paper. Due to the complexity and the additional proprietary software requirement of the Tofino experiment, this experiment script compares the end-host sequencer setup with a configuration using a network sequencer implemented in ns-3. Evaluation of a sequencer implemented in Tofino P4 simulator can be found in a subsequent, standalone experiment.

The script `[nopaxos.sh](http://nopaxos.sh)` sets up 3 hosts running the NOPaxos replica process (tolerating 1 replica failure) and between 1 to 10 hosts running the NOPaxos client process. All hosts are connected to an i40e NIC simulator, which in turn are connected to a ns-3 instance consists of a single switch. The script runs two sequencer configurations: an end-host sequencer running in a separate host which is connected to the ns-3 simulator, and a network sequencer directly implemented in ns-3.

The script generates latency and throughput results in `/simbricks/experiments/ae/nopaxos.data`.

```bash
# In directory /simbricks/experiments/
$ ./ae/nopaxos.sh
```

## Running data points manually

The entire scripts takes a long time to run. To generate individual data points, run the following command:

```bash
# In directory /simbricks/experiments/
$ python3 run.py pyexps/ae/nopaxos.py --filter nopaxos-qt-ib-ehseq-1 --force --verbose
```

This command runs one client host and uses the end-host sequencer configuration. Replace `1` with the intended number of clients (up to 10). 

To run the network sequencer configuration, run the following command: 

```bash
# In directory /simbricks/experiments/
$ python3 run.py pyexps/ae/nopaxos.py --filter nopaxos-qt-ib-swseq-1 --force --verbose
```

Similarly, replace `1` with the intended number of clients. After all the manual experiments are done, run the following command to generate the parsed latency/throughput results:

```bash
# In directory /simbricks/experiments/
$ python3 pyexps/ae/data_nopaxos.py out/ > ae/nopaxos.data
```