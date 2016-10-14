# Jenkins Node

This component comprises of a Docker image used to run a worker node for CI jobs on https://ci.deis.io

This component does not support building Deis v1 jobs due to lack of virtualization support in containers.

## Usage

First, an administrator needs to create a new node at https://ci.deis.io/computer/new. Once it's been
created with the agent's launch method set to "Launch agent via Java Web Start", run the container with the
credentials supplied:

```
$ docker build .
...
Successfully built be0896674128
docker run -e NODE_NAME=my-node-name -e NODE_SECRET=mynodesecret be0896674128
```

Assuming your credentials are correct, you should see the node connected to Jenkins.
