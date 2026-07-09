FROM --platform=linux/amd64 steamcmd/steamcmd:ubuntu-24

ARG STEAMAPPID=295230

ENV SERVER_DIR=/opt/fof \
    HOME=/home/steam \
    STEAMAPPID=${STEAMAPPID} \
    SRCDS_PORT=27015 \
    SRCDS_TV_PORT=27020 \
    SRCDS_CLIENT_PORT=27005 \
    SRCDS_MAP=fof_fistful \
    SRCDS_MAXPLAYERS=20 \
    SRCDS_EXTRA_ARGS=""

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      lib32gcc-s1 \
      lib32stdc++6 \
      lib32z1 \
      libc6:i386 \
      libgcc-s1:i386 \
      libstdc++6:i386 \
      netcat-openbsd \
      tini && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --home-dir /home/steam --shell /bin/bash steam && \
    mkdir -p "${SERVER_DIR}" && \
    chown -R steam:steam "${SERVER_DIR}" /home/steam

USER steam

RUN steamcmd \
      +@sSteamCmdForcePlatformType linux \
      +force_install_dir "${SERVER_DIR}" \
      +login anonymous \
      +app_update "${STEAMAPPID}" validate \
      +quit

WORKDIR /opt/fof

VOLUME ["/opt/fof/fof/cfg", "/opt/fof/fof/addons", "/opt/fof/fof/logs"]

EXPOSE 27015/udp 27015/tcp 27020/udp 27005/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
  CMD nc -z -u 127.0.0.1 "${SRCDS_PORT}" || exit 1

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ./srcds_run \
    -game fof \
    -console \
    -usercon \
    -port "${SRCDS_PORT}" \
    +clientport "${SRCDS_CLIENT_PORT}" \
    +tv_port "${SRCDS_TV_PORT}" \
    +map "${SRCDS_MAP}" \
    +maxplayers "${SRCDS_MAXPLAYERS}" \
    ${SRCDS_EXTRA_ARGS}
