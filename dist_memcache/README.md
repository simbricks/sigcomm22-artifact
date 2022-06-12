# Distributed Scalability

**Codename:** `dist_memcache`

This experiment demonstrates SimBricks’ ability to scale to larger simulations beyond a single physical host, using our proxies that forward messages sent over shared memory queues between simulators through network sockets. We were using the sockets proxy that forwards over Linux TCP sockets.

## Running Experiment

These distributed experiments require a bit of additional setup on multiple physical machines. These experiments are also particularly the most resource intensive ones in the paper (the largest one used 26 machines with 96 Hyperthreads for 16h for the data-point of the largest configuration). We used instances with 20 Gbps networking likely located on one switch, but 10 Gbps may be sufficient. Each server must have minimum of 44 cores. As described in the paper, we have run these experiments on Amazon ec2 c5.metal spot instances. **The experiment requires `N+1` servers for the data points simulating `N` racks.**

We have prepared a separate docker image `simbricks/simbricks-dist-worker` for distributed experiments that includes an ssh server with pre-deployed ssh keys to minimize setup effort. An instance of this container needs to be run on each server. We recommend running the container in the host network namespace to avoid network virtualization overhead, alternatively ports `2222` and `12345` must be exposed from each container. Here is an example docker invocation:

```bash
$ docker run -d --name=dist-worker2 --net=host --device /dev/kvm simbricks/simbricks-dist-worker:latest
```

This will launch the container in the background. Next, **in each container instance** the memcached image needs to be built (we do not include this because of the size). This step will take about 10-20 minutes, and can be run in parallel on each host:

```bash
$ docker exec -it dist-worker2 /bin/bash
/simbricks # make -j20 images/output-memcached/memcached
```

If running the gem5 configuration, the image also needs to be converted to raw:

```bash
/simbricks # make -j20 images/output-memcached/memcached.raw
```

Next, pick one container as the leader and only on this one prepare to initiate the experiment. For this, switch into the `/simbricks/experiments` directory and first create a `hosts.json` file that lists all hosts with their IP addresses as in the example below. The first entry is for the local (leader) container, and only needs the IP address of the host specified, while the others need the additional parameters for running commands remotely (you should only have to update the IP addresses, and number of remote entries):

```json
[
	{"type": "local",
	 "ip": "10.10.1.1"},

	{"type": "remote",
	 "workdir": "/simbricks",
	 "host": "10.10.1.2",
	 "ip": "10.10.1.2",
	 "ssh_args": ["-p2222"],
	 "scp_args": ["-P2222"]},

	{"type": "remote",
	 "workdir": "/simbricks",
	 "host": "10.10.1.3",
	 "ip": "10.10.1.3",
	 "ssh_args": ["-p2222"],
	 "scp_args": ["-P2222"]}
]
```

For the paper we ran the following configurations:

- `dist_memcache-gem5-1-40` (gem5 line, 1 rack of 40 simulated hosts)
- `dist_memcache-gem5-25-40` (gem5 line, 25 racks of 40 = 1000 simulated hosts)
- `dist_memcache-qt-1-40` (qemu timing line, 1 rack of 40 simulated hosts)
- `dist_memcache-qt-5-40`
- `dist_memcache-qt-10-40`
- `dist_memcache-qt-15-40`
- `dist_memcache-qt-25-40` (qemu timing line, 25 racks of 40 = 1000 simulated hosts)

To run one of the data points run the following command on the leader node, again in the `experiments` directory where you placed the `hosts.json` and replace the value of `--filter`:

```bash
$ simbricks-run --verbose --force --dist --hosts hosts.json pyexps/dist_memcache.py --filter=dist_memcache-qt-5-40
```

This will start the simulator instances on all hosts, and display as well as collect the output locally in the `out/` directory, just as with the other experiments.

## Processing Output

**Note: as an experiment measuring simulation time, results may vary significantly depending on the physical test bed details.**

To process the raw output data use the `results/dist_memcache.py` script (`./out` can be replaced with a path to the `dist_memcache/paper/` directory in the artifact repo to process the data used in the paper):

```bash
$ python3 ../results/dist_memcache.py ./out
40	2.1621515464120438	15.765964714354938
200	3.0766478529903623	
400	3.952104051378038	
600	4.511332307921516	
1000	5.6005861098236505	17.653342972199123
```

The resulting tab-separated data has three columns and some cells may be empty if data files are missing. The first column is the total number of simulated hosts. The second column is the measured simulation time in hours for qemu timing, while the second column is the simulation time for gem5.

The artifact repository also has gnuplot file `dist_memcache.gnuplot` that converts this data (stored in `dist_memcache.dat`) into the pdf graph similar to the paper (we use a tikz version).
