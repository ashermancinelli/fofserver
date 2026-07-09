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

ARG MMSOURCE_URL=https://github.com/alliedmodders/metamod-source/releases/download/1.12.0.1224/mmsource-1.12.0-git1224-linux.tar.gz
ARG SOURCEMOD_URL=https://github.com/alliedmodders/sourcemod/releases/download/1.12.0.7239/sourcemod-1.12.0-git7239-linux.tar.gz
ARG STEAMWORKS_URL=https://users.alliedmods.net/~kyles/builds/SteamWorks/SteamWorks-git132-linux.tar.gz
ARG FOF_GUNGAME_URL=https://github.com/connorrichlen/fof_gungame/archive/refs/tags/2.0.2.tar.gz

ADD --chown=steam:steam ${MMSOURCE_URL} /tmp/mmsource.tar.gz
ADD --chown=steam:steam ${SOURCEMOD_URL} /tmp/sourcemod.tar.gz
ADD --chown=steam:steam ${STEAMWORKS_URL} /tmp/steamworks.tar.gz
ADD --chown=steam:steam ${FOF_GUNGAME_URL} /tmp/fof-gungame.tar.gz

RUN tar -xzf /tmp/mmsource.tar.gz -C "${SERVER_DIR}/fof" && \
    tar -xzf /tmp/sourcemod.tar.gz -C "${SERVER_DIR}/fof" && \
    tar -xzf /tmp/steamworks.tar.gz -C "${SERVER_DIR}/fof" && \
    mkdir -p /tmp/fof-gungame \
      "${SERVER_DIR}/fof/addons/sourcemod/configs" \
      "${SERVER_DIR}/fof/addons/sourcemod/plugins" && \
    tar -xzf /tmp/fof-gungame.tar.gz -C /tmp/fof-gungame --strip-components=1 && \
    cp -R /tmp/fof-gungame/configs/. "${SERVER_DIR}/fof/addons/sourcemod/configs/" && \
    cp -R /tmp/fof-gungame/plugins/. "${SERVER_DIR}/fof/addons/sourcemod/plugins/" && \
    rm -rf /tmp/mmsource.tar.gz /tmp/sourcemod.tar.gz /tmp/steamworks.tar.gz /tmp/fof-gungame.tar.gz /tmp/fof-gungame

COPY --chown=steam:steam server/fof/ /opt/fof/fof/

WORKDIR /opt/fof

VOLUME ["/opt/fof/fof/cfg", "/opt/fof/fof/logs"]

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
