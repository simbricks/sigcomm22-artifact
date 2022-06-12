# Synchronization overhead

This experiment validates results in `7.3.1` Paragraph 1.

## Overview

This script runs four experiments. They are the cross product of:

`[ with SimBricks / without SimBricks] [Low event workload / Hight event workload]`. 

The script generates the output `sync_overhead.data` in directory `/simbricks/experiments/ae/`.

```bash
# In directory /simbricks/experiments
$ ./ae/sync-overhead.sh
```