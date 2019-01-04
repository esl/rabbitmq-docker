FROM ubuntu:18.04

ARG server_release_version

WORKDIR /

ENV DEBIAN_FRONTEND noninteractive
RUN  apt-get update && apt-get install -y --no-install-recommends \
        gnupg \
        libxslt-dev \
        xsltproc \
        xmlto \
        curl \
        git \
        mandoc \
        rsync \
        ca-certificates \
        wget \
        python \
        zip \
        unzip

# add esl repository
RUN     curl -O http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
        dpkg -i erlang-solutions_1.0_all.deb && apt-get update

# install erlang
RUN apt-get update && apt-get install -y erlang-nox=1:21.1-1 erlang-dev=1:21.1-1 erlang-src=1:21.1-1

# install elixir
RUN apt-get update && apt-get install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y elixir=1.7.4-1

# add local RabbitMQ repo
RUN mkdir rabbitmq-server
COPY . rabbitmq-server/

# download rabbitmq-server-release
# RUN wget https://github.com/rabbitmq/rabbitmq-server-release/archive/v${server_release_version}.tar.gz && tar -xf v${server_release_version}.tar.gz
RUN git clone https://github.com/rabbitmq/rabbitmq-server-release.git
WORKDIR rabbitmq-server-release
RUN git checkout v${server_release_version}

# Set local RabbitMQ as dependency
RUN sed -i -e 's/^dep_rabbit .*$/dep_rabbit = cp \/rabbitmq-server/g' rabbitmq-components.mk

# build generic unix RabbitMQ package
RUN make package-generic-unix PROJECT_VERSION=${server_release_version}

# Run container
RUN tar -xf PACKAGES/rabbitmq-server-generic-unix-*.tar.xz -C /.
WORKDIR /rabbitmq_server-${server_release_version}
RUN echo "[rabbitmq_management]." > etc/rabbitmq/enabled_plugins
CMD ./sbin/rabbitmq-server