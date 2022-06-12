# Decomposition of Parallelism (extracting e1000, network simulator bottleneck)

The script will validate the results in `7.3.2` . 

## Overview

```bash
# - This shows the simulation time difference of decomposing NIC from Gem5, 
# instead of gem5 built-in NIC.
# It compares the simulation times of gem5-i40e-switch versus 
# [ gem5 + built-in E1000 ]-switch configurations.

# The first experiment result is the same as the 2-host data point from Figure 7.
# or the output of running pyexps/ae/f7_scale.py, which is out/host-gt-ib-sw-1000m-2-1.json 
# 
# The second experiment result is the same as the 2-host data point from Figure 6.
# or the output of running experiments/ae/dist-gem5.sh, which is sims/external/gem5/util/dist/test/run-2.out

# - This experiment will validate the statements in 7.3.2
# The result will be printed on stdout
# Run in /simbricks/experiments/
$ ./ae/net-decmp.sh
```