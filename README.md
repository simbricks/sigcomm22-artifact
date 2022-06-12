# SimBricks SIGCOMM’22 Artifact

This repository contains scripts and instructions for running the experiments from our SIGCOMM’22 submisson “[SimBricks: End-to-End Network System Evaluation with Modular Simulation](https://arxiv.org/abs/2012.14219)”.

(Note that we use the non-anonymized project name “SimBricks” instead of “ModES” as in the original submission, and will change this in the camera ready version of the paper as well).

## Overview

The artifact comprises two GitHub repositories:

1. [Artifact Scripts and Results](https://github.com/simbricks/sigcomm22-artifact)
2. [Main SimBricks Source](https://github.com/simbricks/simbricks) (contains sub-module pointers for external simulators in additional repositories)

For both repositories we have created a `sigcomm22-ae-submission` tag, and a `sigcomm22-ae` branch. The former is the authoritative stable version we submit for evaluation, while we will use the latter branch to push bug-fixes during and after the evaluation period (also in response to AE committee questions if needed). Both will remain in the repository after publication, while the later we plan to include in the appendix so we can apply bug-fixes but otherwise keep functionality stable. The `main` branches may receive larger (breaking) changes during and after the evaluation period.

### Artifact Script and Result Repository

The Artifact repository contains instructions for reproducing the experiments in the paper along with logs from experiment runs used in the paper. Each experiment is in a separate directory labeled with the experiment code-name (see overview below). Most experiment directories contain a `paper` directory with execution logs used to produce the graphs and results in the paper (except in a few cases where we no longer have the original logs). In some experiments we included an `updated` folder with logs run with the version submitted for evaluation. Each experiment also includes a `README.md` with more details on the specific experiment. Finally, for some of the experiments we also include plotting scripts for producing the graphs in the paper.

### Main SimBricks Repository

This repository contains the open source (MIT licensed) code for SimBricks, including sub-module pointers (in `sims/external/`) for modified versions of external simulators we have integrated into SimBricks. The [README in the main SimBricks repository](https://github.com/simbricks/simbricks/blob/main/README.md) contains an overview of the repo and general instructions for how to build and run SimBricks.

For this artifact evaluation, we suggest using our prepared docker images on [docker hub](https://hub.docker.com/u/simbricks) that can be used for all experiments (except the `tofino` docker image -- for more details, see the [tofino experiment README](tofino/README.md)). To build these images locally instead, clone the main SimBricks repo and run `make docker-images docker-images-debug`. SimBricks can also be built locally outside of docker (refer to the [simbricks README](https://github.com/simbricks/simbricks/blob/main/README.md)).

For artifact evaluation, three docker images are relevant:

- `simbricks/simbricks:sigcomm22-ae` is the main SimBricks docker image including a compiled version of SimBricks and external simulators.
- `simbricks/simbricks-gem5opt:sigcomm22-ae` is similar to the main image but additionally also includes the debug version of gem5 (`gem5.opt`) which is required to run two of the experiments that require detailed debug logs of gem5 simulations. But this image is also an additional 1.2GB larger.
- `simbricks/simbricks-dist-worker:sigcomm22-ae` Finally, this image also derives from the main image but includes an SSH server with pre-generated and configured ssh keys to quickly run distributed simulations. Note that the publicly available ssh private keys in this image make it completely unsuitable to run on publicly accessible hosts.

## Requirements

Running SimBricks with docker images, requires a working docker installation on the host, but other software dependencies are covered by docker images. There are however a few requirements for the host machines.

First off, many of the simulations require **kvm virtualization support**, either for performance (regular qemu simulations are multiple times faster than without kvm, and building additional disk images where required is much slower without kvm) or functionality (gem5 kvm configurations have no fallback). This requires the host kernel to support kvm and have it enabled. When running the SimBricks docker container, pass the `--device /dev/kvm` switch to `docker run`.

*gem5*-kvm configurations require `/proc/sys/kernel/perf_event_paranoid` to be set to -1 on the host and we suggest runninng the guest container with `--privileged`.

Hardware requirements vary significantly. The overview table below describes the number of processor cores required per experiment. Running with fewer cores will result in runs that fail or run orders of magnitude slower (SimBricks simulators use polled shared memory queues, and the implementation interacts badly with oversubscribed cores). For memory, we recommend at least 4-8GB of memory per simulated host system. Smaller experiments should run with 16GB of ram, while a copule of the largest experiments might require close to 200GB. Only the one distributed experiment requires more than one machine, but will need a 20Gbps network (10Gbps may still work but is untested by us). The experiments will also require around 20-100GB of disk storage (depending on how many are run and which logs are retained, and the docker storage driver).

## Running Experiments

### Container Preparation

Generally, the first step for running an experiment is starting an interactive shell in the SimBricks docker container (the `dist_memcache` experiment is a bit more complicated):

```bash
$ docker run --device=/dev/kvm --privileged -it simbricks/simbricks:sigcomm22-ae /bin/bash
```

Next, some experiments might require additional VM images to be built once (e.g., see [nopaxos](nopaxos/README.md)). All experiments involving gem5 (most of them) require as a next step that the disk images for simulated guest hosts be converted to raw files from qcow2. As these sparse raw images interact badly with docker storage in images, we do not include these. Instead we include a Makefile target that will convert built images to raw within less than a minute typically:

```bash
/simbricks$ make convert-images-raw
```

### SimBricks Experiment Orchestration

For our experiments we use the SimBricks python orchestration framework in the experiments subdirectory (`/simbricks/experiments` in the container). The orchestration framework is invoked either through `simbricks-run` (only in the container) or python3 run.py, and takes additional parameters specfiying which experiments to run.

SimBricks experiments are specified in individual python scripts which assemble one or multiple experiment configurations. The python scripts are mostly stored in `/simbricks/experiments/pyexps`. Each python script generates a list `experiments` of all configurations supported by the script, each with a label. `simbricks-run --list pyexps/netperf.py` will list the available experiment configurations in the script.

When running without the `--list` parameter, the framework will run these configurations (silently and sequentally by default) and then store the result of each experiment in `out/EXPNAME-1.json`, including outputs of all component simulators, commands run, and the start and end times of the experiment. This enables automated runs of multiple experiments and then analyzing data in a separate step. If a file `out/EXPNAME-1.json` already exists, then the experiment `EXPNAME` will not be re-run unless `--force` is specified.

When running with `--verbose`, output from each simulator is additionally printed live to stdout. This is in general useful for debugging but may be a bit noisy for very large experiments with detailed output.

The orchestration runtime also supports the `--filter` parameter to specify glob patterns to only run a subset of experiments, particularly useful to run individual data points selectively. Multiple instances of the parameter can be specified and will be treated as including any configuration that matches any of the filters.

The runtime also supports running multiple experiments in parallel when specifying `--parallel`. The runtime will ensure not to oversubscribe cores. This is useful for experiments that do not measure simulation time, but are only concerned with behavior of the simulated system. For the experiments measuring simulation time, running them in parallel can affect simulation time (among other things because of CPU thermal management as described in the paper). So we suggest running these experiments sequentially.

Note that the orchstration script will only successfully write the output to the json file if the experiment finishes cleanly (as opposed to interrupting the python script, e.g., with Ctrl+C). To abort an experiment without losing the output typically requires manually killing all host simulators (killing qemu-system-x86 or gem5 will cause the experiment to complete).

Finally, a few of the experiments for baselines do not involve SimBricks, and for these we use shell scripts to directly run these (see per-experiment details).

## Processing Output

As many of our experiments are long-running (even individual data points may take hours), we separate recording raw experiment data (output of simulators, simulation times) from processing and graphing the data. For most of the experiments we use the SimBricks orchestration runtime to generate json files for each run, and then use additional scripts to parse and aggregate data from these output files.

To enable artifact evaluation without re-running every single data points, we also include json output files from our runs in the artifact repository as mentioned above. You can either run the processing scripts on just the re-run files, or adding the missing json files from the original data set in the artifact repository.

Note: for manually inspecting the json files `json_pp < foo.json | less` is convenient.

## Experiment Overview

Our artifact comprises the following experiments from the paper. The table below also provides a rough idea for how long running each experiment might take, both for individual data points and for the full experiment, as well as the number of processor cores required. Please refer to the individual experiment descriptions linked below for detailed instructions.

| Codename | Section | Figure/Table | Time per  point | Total time | Cores required |
| --- | --- | --- | --- | --- | --- |
| [dctcp](dctcp/README.md) | §3, para 3 | Figure 1 | ~240 min | ~52 hours | 9 per data point |
| [netperf](netperf/README.md) | §7.2, §A.4 | Tab.1, Tab. 3 | see table |  | 5 per data point |
| [sync_overhead](sync_overhead/README.md) | §7.3.1, para 1 | N/A |  | ~200 min | 1 or 3 cores |
| [pci-latency](pci-latency/README.md) | §7.3.1, para 2 | Figure 9 | see the graph |  | 5 per data point |
| [dist_gem5](dist_gem5/README.md) | §7.3.1 | Figure 6 | see the graph |  | number of hosts + 1 |
| [decomp-pci](decomp-pci/README.md) | §7.3.2 para 1 | N/A |  |  | no need to run. compare the data generated from dist-gem5 experiment and host-scale |
| [net-decmp](net-decmp/README.md) | §7.3.2 para 2,3 | N/A |  | ~5 min | 3~37 |
| [host_scale](host_scale/README.md) | §7.4.1 | Figure 7 | see graph |  | 5 - 43 |
| [dist_memcache](dist_memcache/README.md) | §7.4.2 para 2 | Figure 8 | 200 - 1000 min | ~ 120 hours | 1x44 - 26x44 |
| [eth_accuracy](eth_accuracy/README.md) | §7.5 | N/A |  | seconds | 2 |
| [pci_validation](pci_validation/README.md) | §7.5 | N/A | ~50 min | ~100 min | 5 |
| [deterministic](deterministic/README.md) | §7.6 | N/A | ~1 hour | ~5 hours | 5 per data point |
| [corundum_pcilat](corundum_pcilat/README.md) | §8.1 | N/A |  |  | 5 per data point |
| [nopaxos](nopaxos/README.md) | §8.2 | Figure 10 |  |  | 5 per data point |
| [tofino](tofino/README.md) | §8.2 | Figure 10 |  |  |  |

## Artifact Claims

The two repositories should contain all of the software components, configurations, and scripts to run and reproduce the experiments in the paper. We also include most of the raw logs for the simulations used for graphs and results in the paper.

Our results fall into two categories: behavior/performance of the simulated system, and measured simulation times. The former results should be (close to) exactly reproducible (see errata below). But simulation time results are significantly affected by the physical testbed used. Here we expect minor differences even with closely matching hardware to what we report in the paper. Absolute simulation times may differ significantly, however we expect general trends such as scalability and relative performance on the same hardware to be similar to what we measured.

More generally the SimBricks framework is also flexible to support new configurations of simulators we have not run in the paper. While documentation of the orchestration framework is still somewhat sparse, we hope that the broad range of examples in the experiments/pyexp directory can serve as a starting point while we work on extending documentation.

Please note that we have made changes to the code since submission, including
cleanup and and some optimizations. As a result behavior does not match the
submission exactly. But we have found no major changes that affect the claims in
motivation or evaluation.

### Errata

There are still a few minor issues with the artifact or the experiments in the paper:

- We ran the SimBricks line for dctcp experiment with slightly different gem5 configuration parameters to the current defaults. We will update this in the paper and also added a diff in the artifact to change the parameters to match the paper, allowing the line to be reproduced exactly. This experiment also requires a larger maximum MTU which is currently not yet runtime configurable. The dctcp readme discusses details for the latter.
- In Tab. 3 in the paper: we found upon inspection that the QT + CB + SW/NS lines reported in the paper were run with the wrong host simulator frequency (8GHz instead of 4GHz as reported). The artifact repo contains the updated json file with the correct frequency.
- §A.3, Table 2 numbers also don’t match current code anymore, as we have been doing a lot of refactoring and cleanup of the code. We will update the table in the camera ready version of the paper to match the code.
- After refactoring our gem5 adapters, and importing a few other gem5 fixes we have found that our experiment validating our simulations as deterministic, does not always result in the same exit tick. But as the rest of the detailed simulation log with timestamps exactly matches, this is only a minor cosmetic issue that we hope to address before publication.
- TODO: pci latency experiment with 1us stuck
- TODO: corundum pci latency experiment scripts
