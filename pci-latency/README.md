# Sensitivity to link latency

This experiment validates results in `7.3.1` Paragraph 3.

## Overview

This script runs with five different PCI latency configurations, which are [10, 50, 100, 500, 1000] ns. Each run uses the gem5-timing + i40e_behavioral model + switch_behavioral combination. After finishing all runs, the script will generate the output `pci_latency.data` in `simbricks/experiments/ae/`.

```bash
# In directory /simbricks/experiments/
$ ./ae/pci-latency.sh
```