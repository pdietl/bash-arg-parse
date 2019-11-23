DOCKER_IMAGE_VER := 1
DOCKER_IMAGE_TAG := pdietl/ubuntu18.04_base:$(DOCKER_IMAGE_VER)

vol_mnt    = -v $(1):$(1)
vol_mnt_ro = $(call vol_mnt,$(1)):ro
map        = $(foreach f,$(2),$(call $(1),$(f)))

DOCKER_ARGS = -t --rm -w $(CURDIR) $(call vol_mnt,$(CURDIR))
DOCKER_ARGS += $(call map,vol_mnt_ro,/etc/passwd /etc/group)
ifeq ($(ROOT),)
    DOCKER_ARGS += -u $(shell id -u):$(shell id -g)
    DOCKER_ARGS += $(call vol_mnt_ro,$(HOME)/.ssh)
else
    DOCKER_ARGS += -v $(HOME)/.ssh:/root/.ssh
endif
DOCKER_ARGS += $(DOCKER_IMAGE_TAG)

.PHONY: $(addprefix docker-,build publish shell) test

test:
	bats test/

docker-shell:
	docker run -ti $(DOCKER_ARGS) /bin/bash

docker-build:
	docker build . --tag $(DOCKER_IMAGE_TAG)

docker-publish:
	docker push $(DOCKER_IMAGE_TAG)

.docker_built: Dockerfile
	$(MAKE) docker-build
	touch $@

# Don't change `make` to `$(MAKE)` -- this will break MacOS support
docker-%: .docker_built
	docker run $(DOCKER_ARGS) $(notdir $(MAKE)) $* $(MAKEFLAGS)
