# Decomposition of Parallelism: Ethernet

**Codename:** `net-decmp`

The script will validate the results in the second and third paragraphs of
`7.3.2`. Here we first show that in larger simulations with many high-bandwidth
senders, a single network simulator can become a bottleneck. To explore the
limit we use a packet generator that can generate traffic much faster than our
host simulators. The packet generator implements the SimBricks Ethernet
interface and connects it to our switch simulator. We measure 2 and 32 idle
hosts (just synchronization messages) and 2 and 32 hosts sending 100G each. For
both cases we see a significant increase in simulation time for the larger
configuration, demonstrating that the switch is the bottleneck.

Next we then spread the 32 hosts, 8 each, to four separate "ToR" switch
instances that connect together through a fith "core" switch, all through
SimBricks Ethernet links. This spreads the load from originally one swtich to
five parallel switches and drastically reduces simulation time.

## Running Experiment and Processing Output

As this experiment runs all data points relatively quickly (about 5 minutes), we
provide one script that runs all configurations and parses the output.

```bash
# - This experiment will validate the statements in 7.3.2
# The result will be printed on stdout
# Run in /simbricks/experiments/
$ ./ae/net-decmp.sh
```
