# If DEIS_REGISTRY is not set, try to populate it from legacy DEV_REGISTRY
DEIS_REGISTRY ?= $(DEV_REGISTRY)
IMAGE_PREFIX ?= deis
COMPONENT ?= jenkins-node
SHORT_NAME ?= $(COMPONENT)

include versioning.mk

check-kubectl:
	@if [ -z $$(which kubectl) ]; then \
	  echo "kubectl binary could not be located"; \
	  exit 2; \
	fi

check-docker:
	@if [ -z $$(which docker) ]; then \
	  echo "Missing \`docker\` client which is required for development"; \
	  exit 2; \
	fi

build: docker-build

docker-build: check-docker
	docker build --rm -t ${IMAGE} .
	docker tag ${IMAGE} ${MUTABLE_IMAGE}

clean: check-docker
	docker rmi $(IMAGE)

full-clean: check-docker
	docker images -q $(IMAGE_PREFIX)$(COMPONENT) | xargs docker rmi -f

.PHONY: build clean docker-build full-clean 
