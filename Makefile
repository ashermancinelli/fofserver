IMAGE ?= fof-server:local
SRCDS_MAP ?= fof_fistful
SRCDS_MAXPLAYERS ?= 20

.PHONY: build test test-mods run clean

build:
	podman build --format docker -t $(IMAGE) .

test: build
	podman run --rm --no-healthcheck --entrypoint /bin/sh $(IMAGE) -lc 'id && test -x ./srcds_run && test -d ./fof && test -d ./fof/cfg && echo ok'

test-mods: build
	podman run --rm --no-healthcheck --entrypoint /bin/sh $(IMAGE) -lc 'test -f ./fof/addons/metamod.vdf && test -f ./fof/addons/metamod/bin/server.so && test -f ./fof/addons/sourcemod/bin/sourcemod_mm_i486.so && test -f ./fof/addons/sourcemod/extensions/SteamWorks.ext.so && test -f ./fof/addons/sourcemod/plugins/fof_gungame_skooma.smx && test -f ./fof/addons/sourcemod/configs/gungame_weapons.txt && test -f ./fof/cfg/server.cfg && echo mods-ok'

run: build
	podman run --rm -it --no-healthcheck \
		-p 27015:27015/udp \
		-p 27015:27015/tcp \
		-p 27020:27020/udp \
		-p 27005:27005/udp \
		-e SRCDS_MAP=$(SRCDS_MAP) \
		-e SRCDS_MAXPLAYERS=$(SRCDS_MAXPLAYERS) \
		$(IMAGE)

clean:
	podman rmi $(IMAGE)
