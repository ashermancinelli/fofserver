IMAGE ?= fof-server:local
SRCDS_MAP ?= fof_fistful
SRCDS_MAXPLAYERS ?= 20

.PHONY: build test run clean

build:
	podman build --format docker -t $(IMAGE) .

test: build
	podman run --rm --entrypoint /bin/sh $(IMAGE) -lc 'id && test -x ./srcds_run && test -d ./fof && test -d ./fof/cfg && echo ok'

run: build
	podman run --rm -it \
		-p 27015:27015/udp \
		-p 27015:27015/tcp \
		-p 27020:27020/udp \
		-p 27005:27005/udp \
		-e SRCDS_MAP=$(SRCDS_MAP) \
		-e SRCDS_MAXPLAYERS=$(SRCDS_MAXPLAYERS) \
		$(IMAGE)

clean:
	podman rmi $(IMAGE)
