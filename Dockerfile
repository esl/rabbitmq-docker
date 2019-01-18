FROM ubuntu:18.04

ARG erlang_version
ARG elixir_version
ARG server_release_version

WORKDIR /

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Add esl repository
RUN     curl -O http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
        dpkg -i erlang-solutions_1.0_all.deb && apt-get update

# Install erlang
RUN apt-get update && apt-get install -y \
        erlang-dev=1:${erlang_version}-* \
        erlang-src=1:${erlang_version}-* \
        # Install erlang-nox manually
        erlang-base=1:${erlang_version}-* \
        erlang-asn1=1:${erlang_version}-* \
        erlang-crypto=1:${erlang_version}-* \
        erlang-diameter=1:${erlang_version}-* \
        erlang-edoc=1:${erlang_version}-* \
        erlang-eldap=1:${erlang_version}-* \
        erlang-erl-docgen=1:${erlang_version}-* \
        erlang-eunit=1:${erlang_version}-* \
        erlang-ic=1:${erlang_version}-* \
        erlang-inets=1:${erlang_version}-* \
        erlang-mnesia=1:${erlang_version}-* \
        erlang-odbc=1:${erlang_version}-* \
        erlang-os-mon=1:${erlang_version}-* \
        erlang-parsetools=1:${erlang_version}-* \
        erlang-public-key=1:${erlang_version}-* \
        erlang-runtime-tools=1:${erlang_version}-* \
        erlang-snmp=1:${erlang_version}-* \
        erlang-ssh=1:${erlang_version}-* \
        erlang-ssl=1:${erlang_version}-* \
        erlang-syntax-tools=1:${erlang_version}-* \
        erlang-tools=1:${erlang_version}-* \
        erlang-xmerl=1:${erlang_version}-*

# Install elixir
RUN apt-get update && apt-get install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y elixir=${elixir_version}-*

# Add local RabbitMQ repo
RUN mkdir rabbitmq-server
COPY . rabbitmq-server/

# Download rabbitmq-server-release
RUN git clone https://github.com/rabbitmq/rabbitmq-server-release.git
WORKDIR rabbitmq-server-release
RUN git checkout v${server_release_version}

# Set local RabbitMQ as dependency
RUN sed -i -e 's/^dep_rabbit .*$/dep_rabbit = cp \/rabbitmq-server/g' rabbitmq-components.mk

# Build generic unix RabbitMQ package tarball
RUN make package-generic-unix PROJECT_VERSION=${server_release_version}

# Install the RabbitMQ package
RUN tar -xf PACKAGES/rabbitmq-server-generic-unix-*.tar.xz -C /.

WORKDIR /rabbitmq_server-${server_release_version}

# Add ctl scripts to /usr/bin
RUN for script in rabbitmqctl rabbitmq-defaults rabbitmq-diagnostics rabbitmq-env rabbitmq-plugins rabbitmq-server; \
  do ln -s /rabbitmq_server-${server_release_version}/sbin/$script /usr/bin/$script; done

# Enable Management plugin
RUN echo "[rabbitmq_management]." > etc/rabbitmq/enabled_plugins

# Start RabbitMQ sever
CMD echo ${RABBITMQ_COOKIE} > /root/.erlang.cookie && chmod 600 /root/.erlang.cookie && ./sbin/rabbitmq-server
