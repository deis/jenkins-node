# Jenkins Node
[![Build Status](https://ci.deis.io/job/jenkins-node/badge/icon)](https://ci.deis.io/job/jenkins-node)

**NOTE**: This is a work-in-progress. Things are expected to change over time.

This component comprises of a Docker image used to run a worker node for CI jobs on the Jenkins host specified by $JENKINS_URL (default: https://ci.deis.io)

This component does not support building Deis v1 end-to-end jobs due to lack of virtualization
support in containers.

## Usage

First, an administrator needs to create a new node at ${JENKINS_URL}/computer/new. Once it's
been created with the agent's launch method set to "Launch agent via Java Web Start", run the
container with the credentials supplied:

```
$ make build
$ docker run -e NODE_NAME=my-node-name -e NODE_SECRET=mynodesecret -v /var/run/docker.sock:/var/run/docker.sock -v /home/jenkins/workspace:/home/jenkins/workspace quay.io/deis/jenkins-node:canary
```

Assuming your credentials are correct, you should see the node connected to Jenkins.
