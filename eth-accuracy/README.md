# Ethernet channel accuracy

This experiment will validate statements in `7.5`.  

The total experiment will take a few seconds to run to complete.

In this experiment we show that SimBricks Ethernet channel doesn’t break simulation accuracy. We run two simulated hosts purely (no SimBricks host simulators) in ns-3. The two hosts are connected over an Ethernet link. One host sends 20 packets in `1 us` period and the other host receives. The channel delay is set to `500 ns`.

We now run this simulation in two separate configurations. First, with everything in a single ns-3 instance without any SimBricks components, and the hosts connected together using  a`SimpleChannel`. Second, we run the two hosts in separate ns-3 instances and connect the hosts together using SimBricks Ethernet adapters (configured with identical link latency to the previous configuration). 

The hosts in this experiment will log the sending/receiving event logs including timestamp. We then compare simulation traces for the hosts in both configurations. For the SimBricks experiment, it will generate two log files under `simbricks/experiments/out/accuracy/`, one from sender (`sender.time`), the other on from receiver (`receiver.time`).   You will find sender sends one packet per `us`, and the receiver receives exactly `500 ns` later.

For the ns-3 standalone experiment, one sender & receiver aggregated log file `(single_ns3.time)` will be generated. You will find it the sending and receiving exactly matches with SimBricks runs.

```bash
# Ethernet channel accuracy experiments
$ ./ae/eth_accuracy.sh

```