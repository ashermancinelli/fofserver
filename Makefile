IMAGE ?= fof-server:local
REGISTRY ?= docker.io
DOCKERHUB_USER ?= ashermancinelli
REMOTE_IMAGE ?= $(REGISTRY)/$(DOCKERHUB_USER)/fof-server
REMOTE_TAG ?= latest
SRCDS_MAP ?= fof_fistful
SRCDS_MAXPLAYERS ?= 20

.PHONY: build test test-mods run docker-login tag push pull pull-image run-remote clean

build:
	podman build --format docker -t $(IMAGE) .

test: build
	podman run --rm --no-healthcheck --entrypoint /bin/sh $(IMAGE) -lc 'id && test -x ./srcds_run && test -d ./fof && test -d ./fof/cfg && echo ok'

test-mods: build
	podman run --rm --no-healthcheck --entrypoint /bin/sh $(IMAGE) -lc 'test -f ./fof/addons/metamod.vdf && test -f ./fof/addons/metamod/bin/server.so && test -f ./fof/addons/sourcemod/bin/sourcemod_mm_i486.so && test -f ./fof/addons/sourcemod/extensions/SteamWorks.ext.so && test -f ./fof/addons/sourcemod/plugins/gungame_fof.smx && test -f ./fof/addons/sourcemod/configs/gungame_weapons.txt && test -f ./fof/cfg/server.cfg && echo mods-ok'

run: build
	podman run --rm -it --no-healthcheck \
		-p 27015:27015/udp \
		-p 27015:27015/tcp \
		-p 27020:27020/udp \
		-p 27005:27005/udp \
		-e SRCDS_MAP=$(SRCDS_MAP) \
		-e SRCDS_MAXPLAYERS=$(SRCDS_MAXPLAYERS) \
		$(IMAGE)

docker-login:
	podman login $(REGISTRY)

tag:
	@test -n "$(DOCKERHUB_USER)" || (echo "Set DOCKERHUB_USER, for example: make push DOCKERHUB_USER=yourname" >&2; exit 1)
	podman tag $(IMAGE) $(REMOTE_IMAGE):$(REMOTE_TAG)

push: build tag
	podman push $(REMOTE_IMAGE):$(REMOTE_TAG)

pull:
	@test -n "$(DOCKERHUB_USER)" || (echo "Set DOCKERHUB_USER, for example: make pull DOCKERHUB_USER=yourname" >&2; exit 1)
	podman pull $(REMOTE_IMAGE):$(REMOTE_TAG)

pull-image: pull

run-remote: pull
	podman run -d \
		--name fof-server \
		--restart unless-stopped \
		--no-healthcheck \
		-p 27015:27015/udp \
		-p 27015:27015/tcp \
		-p 27020:27020/udp \
		-p 27005:27005/udp \
		-e SRCDS_MAP=$(SRCDS_MAP) \
		-e SRCDS_MAXPLAYERS=$(SRCDS_MAXPLAYERS) \
		$(REMOTE_IMAGE):$(REMOTE_TAG)

clean:
	podman rmi $(IMAGE)
