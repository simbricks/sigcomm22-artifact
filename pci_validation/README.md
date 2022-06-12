# PCIe channel accuracy

**Codename:** `pci_validation`

For our PCIe accuracy experiment we have extracted [gem5’s 1000 NIC model](https://github.com/simbricks/gem5/blob/main/src/dev/net/i8254xGBe.cc) as [a separate SimBricks simulator](https://github.com/simbricks/simbricks/tree/main/sims/nic/e1000_gem5) connecting to host simulators through our PCIe interface so we can compare the behavior of the builtin e1000 NIC in gem5 to our extracted version. As gem5 has no built in NICs or other devices with PCIe semantics (link delays for PIO/DMA requests and responses as well as interrupts), [we have modified](https://github.com/simbricks/gem5/commits/main/src/dev/net/i8254xGBe.cc) gem5’s e1000 model slightly to model these delays. We then enable detailed debug logs in both the builtin and the extracted e1000 model and simulate a short netperf throughput and latency run (not the full 10s each, as the debug log is very verbose). Finally we compare the debug logs including time stamps for both runs.

## Running Experiment

**Note: As this experiments requires debug messages in gem5, please use the container image with gem5.opt which has debug messages enabled:** `simbricks/simbricks:gem5opt`

This experiment has no other special requirements (only the raw version of the base disk image has to be built first with `make convert-images-raw`. The experiment only has two separate data points: `pci_validation-internal` and `pci_validation-external` that each take about 50 minutes to simulate. To run use the following command in the `experiments` directory (as the experiment is very noisy, we recommend running without `--verbose` ) :

```bash
$ cd /simbricks/experiments
$ simbricks-run --force pyexps/pci_validation.py
```

Note: as we are not measuring simulation time, both data points can also be run in parallel by adding the `--parallel` switch assuming the system has at least 10 processor cores. 

## Processing Output

This experiment does not produce a graph, instead we compare detailed debug logs with timestamps from both configurations, internal  and external. As the two configurations format their debug messages differently, the `results/pci_validation.py` script does some reformatting and filtering of messages as some are specific to one of the configurations. (Below, `./out` can be replaced by the path to the `pci_validation/updated/` in a checkout of the sigcomm22-artifact repo)

```bash
$ cd /simbricks/experiments
$ python3 ../results/pci_validation.py ./out external > external
$ python3 ../results/pci_validation.py ./out internal > internal
```

 Afterwards we compare the two reformated logs with `diff`:

```bash
$ cd /simbricks/experiments
$ python3 ../results/pci_validation.py ./updated external > external
$ python3 ../results/pci_validation.py ./updated internal > internal
$ diff -u internal external
--- internal	2022-06-11 13:44:46.989463296 +0200                               
+++ external	2022-06-11 13:44:52.617478954 +0200
@@ -1,6 +1,3 @@
-978719381360 resuming from drain978719383000: system.pc.simbricks_0: igbe: -------------- cycle --------------
-978719383000 rxs: rx disabled, stopping ticking
-978719383000 txs: tx disabled, stopping ticking
 982586340250 read device register 0x8
 982587471500 read device register 0x8
 982589866374 wrote device register 0xd8 value 0xffffffff
@@ -27206,8 +27203,10 @@
 1743351263000 writing back descriptors head: 10 tail: 10 len: 256 cachepnt: 10 max_to_wb: 0 descleft: 0
 1743351263000 writing back 0 descriptors
 1743351263000 posting txdw interrupt because tidv timer expired
+1743375839000 writing back descriptors head: 10 tail: 10 len: 256 cachepnt: 10 max_to_wb: 0 descleft: 0
 1743375839000 writing back 0 descriptors
 1743375839000 posting txdw interrupt because tadv timer expired
+1743378823000 posting interrupt
 1743378823000 eint: posting interrupt to cpu now. vector 0x80000003
 1743464838375 read device register 0xc0
 1743464838375 reading icr. icr=0x80000003 imr=0x9d iam=0 iame=0
@@ -60357,6 +60356,7 @@
 1748768655000 writing back descriptors head: 143 tail: 143 len: 256 cachepnt: 143 max_to_wb: 0 descleft: 0
 1748768655000 writing back 0 descriptors
 1748768655000 posting txdw interrupt because tidv timer expired
+1748785172000 writing back descriptors head: 143 tail: 143 len: 256 cachepnt: 143 max_to_wb: 0 descleft: 0
 1748785172000 writing back 0 descriptors
 1748785172000 posting txdw interrupt because tadv timer expired
 1748988331000 posting interrupt
@@ -61015,8 +61015,10 @@
 1750080860000 writing back descriptors head: 156 tail: 156 len: 256 cachepnt: 156 max_to_wb: 0 descleft: 0
 1750080860000 writing back 0 descriptors
 1750080860000 posting txdw interrupt because tidv timer expired
+1750105436000 writing back descriptors head: 156 tail: 156 len: 256 cachepnt: 156 max_to_wb: 0 descleft: 0
 1750105436000 writing back 0 descriptors
 1750105436000 posting txdw interrupt because tadv timer expired
+1750110474000 posting interrupt
 1750110474000 eint: posting interrupt to cpu now. vector 0x80000003
 1750219198749 read device register 0xc0
 1750219198749 reading icr. icr=0x80000003 imr=0x9d iam=0 iame=0
```

As in the example above (as run on the data in the `sigcomm22-artifact` repo), there will only be a few small differences. The first hunk is just different because the internal model includes an additional initialization step of flushing some queues etc that does not affect the device state (as the device is already in the reset state). The additional hunks are because these lines in the internal configuration get corrupted because gem5 (undeterministically) intersperses the console output of the VM with the debug messages, which causes the reformatting script to ignore these lines. We verify these differences through manual inspection (run `json_pp<out/pci_validation-internal-1.json | less` and search for the timestamp of the preceeding lines), and as seen below the netperf output gets interspersed with those few lines but they otherwise match:

```json
"1743351263000: system.pc.simbricks_0: Posting TXDW interrupt because TIDV timer expired",
"MIGRATED T1743375839000: system.pc.simbricks_0.TxDesc: Writing back descriptors head: 10 tail: 10 len: 256 cachePnt: 10 max_to_wb: 0 descleft: 0",
"1743375839000: system.pc.simbricks_0.TxDesc: Writing back 0 descriptors",
"1743375839000: system.pc.simbricks_0: Posting TXDW interrupt because TADV timer expired",
"CP 1743378823000: system.pc.simbricks_0: Posting Interrupt",
"1743378823000: system.pc.simbricks_0: EINT: Posting interrupt to CPU now. Vector 0x80000003",
"STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET : demo1743464338375: system.pc.simbricks_0.pio: Received timing PIO",
"1743464838375: system.pc.simbricks_0: Read device register 0XC0",
```

```json
"1748768655000: system.pc.simbricks_0: Posting TXDW interrupt because TIDV timer expired",
"Recv   Se1748785172000: system.pc.simbricks_0.TxDesc: Writing back descriptors head: 143 tail: 143 len: 256 cachePnt: 143 max_to_wb: 0 descleft: 0",
"1748785172000: system.pc.simbricks_0.TxDesc: Writing back 0 descriptors",
```

```json
"1750080860000: system.pc.simbricks_0: Posting TXDW interrupt because TIDV timer expired",
"MIGRATED TCP1750105436000: system.pc.simbricks_0.TxDesc: Writing back descriptors head: 156 tail: 156 len: 256 cachePnt: 156 max_to_wb: 0 descleft: 0",
"1750105436000: system.pc.simbricks_0.TxDesc: Writing back 0 descriptors",
"1750105436000: system.pc.simbricks_0: Posting TXDW interrupt because TADV timer expired",
" REQU1750110474000: system.pc.simbricks_0: Posting Interrupt",
"1750110474000: system.pc.simbricks_0: EINT: Posting interrupt to CPU now. Vector 0x80000003",
"EST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET : demo : first burst 01750218698749: system.pc.simbricks_0.pio: Received timing PIO",
"1750219198749: system.pc.simbricks_0: Read device register 0XC0",
"1750219198749: system.pc.simbricks_0: Reading ICR. ICR=0x80000003 IMR=0x9d IAM=0 IAME=0",
```