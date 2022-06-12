# Deterministic

This experiment will validate statements in `7.6`.

## Overview

In this experiment we run the same simulation five times (default). The simulation will turn on the debug flags of CPU, NIC, NET simulators, which will log the events information including timestamps. Running five times is to make it more sure that the simulations are deterministic. But to minimize the experiment time, the user can run only twice and compare their logs.

Usage: `./ae/deterministic.sh [run_num]`

The script will first run the simulation and then parse the `json` file into `host.clilent.0`, `host.server.0`, `net.`, `nic.client.0`, `nic.server.0` files under the  `experiment/out/dt-gt-ib-sw/[run_idx]/` directory. The the user can compare the timestamps across the different runs.

use simbricks/simbricks:gem5opt image

To turn all the debug flags on, we have to manually make some changes to the SimBricks code.

Change `nicbm.cc` `net_switch.cc` debug flags and recompile.

In `simbricks/lib/simbricks/nicbm/nicbm.cc` , uncomment `line 44` 

```cpp
#define DEBUG_NICBM 1
```

In `simbricks/sims/net/switch/net_switch.cc`, uncomment `line 47`

```cpp
#define NETSWITCH_DEBUG
```

Then build simbricks code again. 

```bash
# in simbricks/ directory
$ make clean
$ make
```