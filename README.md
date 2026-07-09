# Fistful of Frags Server Container

Podman/Docker image for a Linux Fistful of Frags dedicated server.

## Build

```sh
podman build --format docker -t fof-server:local .
```

The server app is installed with SteamCMD app `295230`. The Dockerfile forces
the Linux Steam platform because anonymous install can otherwise fail with
`Missing configuration`.

## Run Locally

```sh
podman run --rm -it \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -p 27020:27020/udp \
  -p 27005:27005/udp \
  -e SRCDS_MAP=fof_fistful \
  -e SRCDS_MAXPLAYERS=20 \
  fof-server:local
```

Useful runtime variables:

- `SRCDS_PORT`: game port, default `27015`
- `SRCDS_TV_PORT`: SourceTV port, default `27020`
- `SRCDS_CLIENT_PORT`: client port, default `27005`
- `SRCDS_MAP`: startup map, default `fof_fistful`
- `SRCDS_MAXPLAYERS`: player count, default `20`
- `SRCDS_EXTRA_ARGS`: extra `srcds_run`/console arguments

Persist or mount these paths for custom server state:

- `/opt/fof/fof/cfg`
- `/opt/fof/fof/addons`
- `/opt/fof/fof/logs`

## SourceMod/GunGame Plan

GunGame requires the normal Source server plugin chain:

- MetaMod:Source installed under `/opt/fof/fof/addons`
- SourceMod installed under `/opt/fof/fof/addons`
- A FoF GunGame SourceMod plugin plus its configs under `addons/sourcemod`
- Server config files under `/opt/fof/fof/cfg`

Current upstream references:

- MetaMod:Source stable branch is `1.12`.
- SourceMod stable builds are published at `sourcemod.net`.
- `connorrichlen/fof_gungame` is an updated FoF GunGame plugin requiring
  SourceMod `1.10` or later.

The clean next step is to add pinned download URLs/checksums for MetaMod and
SourceMod, then copy a local `server/fof` overlay into `/opt/fof/fof` so plugins,
configs, and admin lists are versioned in this repo.
