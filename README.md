# Build your custom RabbitMQ docker image

This repository contains `Dockerfile` and `build.sh` script that allow to build
a docker image that uses your local (maybe modified) RabbitMQ source code.

## Example of usage

To build an image run:

```bash
IMAGE=rabbitmq \
VERSION=3.7.9 \
RMQ_VERSION=v3.7.9 \
ERLANG_VERSION=21.1 \
ELIXIR_VERSION=1.7.4 \
CONTEXT_PATH=../rabbitmq-server \
./build.sh
```

where:

* `IMAGE` - name of the Docker image
* `VERSION` - version of the Docker image that will be build
* `RMQ_VERSION` - version of RabbitMQ that will be build
* `CONTEXT_PATH` - path to the local (to the host machine, not Docker) RabbitMQ
source code.
