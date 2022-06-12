# Decomposition of Parallelism: PCIe

**Codename:** `decomp-pci`

The script will validate the results in the first paragraph of `7.3.2` . Here,
we compare the performance of running a simulation with gem5's builtin e1000 NIC
to using our extracted version of the e1000 NIC connected through the SimBricks
PCIe interface. This shows that the additional parallelism from decomposing the
simulation into parallel pieces, outweighs the communication cost for SimBricks
interfaces resulting in an overall lower simulation time.

## Running Experiment

This experiment does not need to run any additional data points but instead uses
two result files from different experiments, first the 1-client (two host)
configuration from `host_scale`, and the 2 host SimBricks point from the
`dist_gem5` comparison experiment.

## Processing Output

We again just directly use the parsed results from those two prior experiments.
See [host_scale.dat](../host_scale/host_scale.dat) and the last column in
[dist_gem5.dat](../dist_gem5/dist_gem5.dat) (i.e. 138 vs 350 minutes). We still
include the raw data files in the `paper` directory for completeness.
