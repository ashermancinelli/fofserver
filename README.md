# Fistful of Frags Server Container

Podman/Docker image for a Linux Fistful of Frags dedicated server.

## Build

```sh
make build
```

The server app is installed with SteamCMD app `295230`. The Dockerfile forces
the Linux Steam platform because anonymous install can otherwise fail with
`Missing configuration`.

## Run Locally

```sh
make run
```

Run a quick container smoke test:

```sh
make test
```

Run a mod install smoke test:

```sh
make test-mods
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
- `/opt/fof/fof/logs`

Do not mount `/opt/fof/fof/addons` unless you intend to replace the baked
MetaMod/SourceMod/GunGame install.

## SourceMod/GunGame

The image bakes in the normal Source server plugin chain after the SteamCMD
game install layer:

- MetaMod:Source installed under `/opt/fof/fof/addons`
- SourceMod installed under `/opt/fof/fof/addons`
- SteamWorks installed under `/opt/fof/fof/addons/sourcemod/extensions`
- FoF GunGame plugin and configs under `addons/sourcemod`
- Server config overlay from `server/fof`

Current upstream references:

- MetaMod:Source stable branch is `1.12`.
- SourceMod stable builds are published at `sourcemod.net`.
- `CrimsonTautology/sm-gungame-fof` provides the FoF GunGame plugin version
  `1.10.0`, matching known public GunGame servers. It requires SourceMod
  `1.10` or later and the SteamWorks extension.
