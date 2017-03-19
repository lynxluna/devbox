# A DevBox

This will startup minikube and vagrant consul machines for now. You'd need these
software to be installed first:

  - [Vagrant](https://www.vagrantup.com)
  - [VirtualBox](https://virtualbox.org)

The vagrant script is intended to bootstrap a development environment suitable for
local development of microservices or containerised application. With this, each
node will have:
  
  - Cluster Management using kubernetes.
  - Service Discovery using consul.
  - Monitoring with Elastic Search and Kibana.

## Running

First timer, you can execute the `bootstrap.sh` file:

```console
./bootstrap.sh
```

If you want to re-provision, just use Vagrant and minikube commands.

```console
vagrant up --provision
```

There are 6 machines launched by this script

  - 3 [consul](http://consul.io) cluster. vCPU: 1, RAM: 256MB each.
  - 1 [elasticsearch](http://elastic.co) node. vCPU: 1, RAM: 4Gb.
  - 1 [kibana](https://www.elastic.co/products/kibana) node, vCPU: 1, RAM: 512 MB.
  - 1 [kubernetes](http://kubernetes.io) node, vCPU: 1, RAM: 1024 Mb

Total RAM consumption is 6 Gb, so 8 Gb of minimum RAM is advised. During run, the
cluster will only consume only tiny amount of CPU.

![CPU Consumption](/pictures/cpu.png).

## Copyright

Copyright (c) 2017 Didiet Noor

