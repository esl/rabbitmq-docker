#!/bin/bash
set -euo pipefail

# Example of usage:
# IMAGE=rabbitmq VERSION=3.7.9 RMQ_VERSION=v3.7.9 ERLANG_VERSION=21.1 ELIXIR_VERSION=1.7.4 CONTEXT_PATH=../rabbitmq-server ./build.sh

docker build -t ${IMAGE}:${VERSION} \
       --build-arg erlang_version=${ERLANG_VERSION} \
       --build-arg elixir_version=${ELIXIR_VERSION} \
       --build-arg server_release_version=${RMQ_VERSION} \
       -f Dockerfile \
       $CONTEXT_PATH
