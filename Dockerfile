FROM openjdk:8-jdk

ARG JENKINS_REMOTING_VERSION=3.7

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_REMOTING_VERSION}/remoting-${JENKINS_REMOTING_VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# Workflow-specific setup and dependency installation
ENV JENKINS_HOME=/home/jenkins

# HACK(bacongobbler): workaround for https://github.com/docker/docker/issues/14669
ENV HOME=/home/jenkins

# identify between containerized jenkins nodes and non-containerized
ENV IN_THE_MATRIX=true

# create jenkins user and group, sharing the same uid and gid as deis/e2e-runner
RUN addgroup --gid 999 jenkins
RUN adduser \
    --system \
    --shell /bin/bash \
    --disabled-password \
    --home $JENKINS_HOME \
    --gid 999 \
    --uid 999 \
    jenkins

# install test dependencies
RUN apt-get update -y \
    && apt-get install -yq \
        apt-transport-https \
        awscli \
        bzr \
        build-essential \
        bundler \
        cabal-install \
        curl \
        file \
        git \
        jq \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libpython2.7 \
        libsasl2-dev \
        libsdl1.2debian \
        libssl-dev \
        libyaml-dev \
        mercurial \
        ntp \
        openjdk-8-jre-headless \
        postgresql \
        postgresql-client \
        psmisc \
        python-dev \
        python-pip \
        rsync \
        sudo \
        unzip \
        wget \
        --no-install-recommends

# azure cli specific setup
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
    tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893

# install azure cli
RUN apt-get update -y \
    && apt-get install -yq azure-cli

# install docker standalone client to /usr/local/bin
RUN curl -L https://get.docker.com/builds/Linux/x86_64/docker-1.11.2.tgz | tar -C /usr/local/bin -xz --strip=1 \
    && chmod +x /usr/local/bin/docker*

# configure git email
RUN git config --global user.email "ci@deis.com"

# configure git user
RUN git config --global user.name 'Deis CI'

# install go 1.7.5
ENV GO_VERSION=1.7.5
RUN curl -L https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar -C /usr/local -xz

RUN mkdir -p $JENKINS_HOME/go/src
ENV GOPATH=$JENKINS_HOME/go

# install golint
RUN GOPATH=/tmp /usr/local/go/bin/go get -u github.com/golang/lint/golint

# install glide
RUN curl -L https://github.com/Masterminds/glide/releases/download/v0.12.3/glide-v0.12.3-linux-amd64.tar.gz | tar -C /usr/local/bin -xz --strip=1 \
    && rm /usr/local/bin/LICENSE /usr/local/bin/README.md

# fetch/install shellcheck
ENV SHELLCHECK_VERSION=0.4.3
RUN curl -L https://s3-us-west-2.amazonaws.com/get-deis/shellcheck-$SHELLCHECK_VERSION-linux-amd64 -o /usr/local/bin/shellcheck \
    && chmod +x /usr/local/bin/shellcheck

# copy everything to rootfs
COPY rootfs /

# change ownership of everything in $JENKINS_HOME to jenkins
RUN chown -R jenkins:jenkins $JENKINS_HOME

# add $JENKINS_HOME/bin and go to system path
ENV PATH=$JENKINS_HOME/bin:/usr/local/go/bin:$PATH

WORKDIR $JENKINS_HOME

ENTRYPOINT ["jenkins-slave"]
