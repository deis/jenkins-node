# Jenkins Node
[![Build Status](https://ci.deis.io/job/jenkins-node/badge/icon)](https://ci.deis.io/job/jenkins-node)

This component comprises of a Docker image used to run a worker node for CI jobs specifically for the Deis Workflow project on https://ci.deis.io.

Essentially, it bundles all the dependencies specific to running CI for Deis Workflow with the stock Jenkins JNLP connection logic as used by the [jenkinsci/docker-jnlp-slave](https://github.com/jenkinsci/docker-jnlp-slave) [image](https://hub.docker.com/r/jenkinsci/jnlp-slave/).

This component does not support building Deis v1 end-to-end jobs due to lack of virtualization
support in containers.

## Usage

The agent needs three values at minimum to run.  They can be passed as arguments or exposed via environment variables.  Here we illustrate usage via the latter approach:
  * `JENKINS_URL` pointed to the Jenkins master host, e.g. `https://ci.deis.io`
  * `JENKINS_NAME` representing the name of the agent itself
  * `JENKINS_SECRET` representing the secret associated with `JENKINS_NAME` for connecting via the [Jenkins Remoting](https://github.com/jenkinsci/remoting) module.

Optionally, `JENKINS_TUNNEL` (of `host:port` format) can be specified if the JNLP service port is not handled by the host represented in `JENKINS_URL`

### As Static Agent

If a static agent is desired, an administrator will need to create a new node at https://ci.deis.io/computer/new. Once it has been created with the agent's launch method set to "Launch agent via Java Web Start", the resulting name and secret can be passed to the container, either via `docker run` or via the helm chart install.

To run directly:

```
$ make build
$ docker run \
  -e JENKINS_URL=https://my.jenkins.master \
  -e JENKINS_NAME=my-node-name \
  -e JENKINS_SECRET=mynodesecret \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/jenkins/workspace:/home/jenkins/workspace quay.io/deis/jenkins-node:canary
```

To run via the helm chart:

```
helm install charts/jenkins-node --name my-node-name --namespace jenkins \
  --set jenkins.url=https://my.jenkins.master \
  --set agent.name=my-node-name \
  --set agent.secret=mynodesecret
```

### As Dynamic Agent

The container may also be run via the [Kubernetes Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Kubernetes+Plugin), which provisions agents on-demand.  

First, configure the plugin itself, i.e., set `Jenkins URL` and other values as needed.  This can be done at https://${JENKINS_URL}/configure

Next, the only configuration necessary for this agent to run is to add the volume mounts, as seen in the docker command above and in the helm chart, to the pod template configuration under the general settings set above.  

The plugin will handle passing the provisioned name and secret to the container each time it spins up a new node.
