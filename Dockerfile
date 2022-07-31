###################
# S6 Overlay
###################
FROM alpine:latest as s6downloader
WORKDIR /s6downloader

RUN set -x \
    && S6_OVERLAY_VERSION=$(wget --no-check-certificate -qO - https://api.github.com/repos/just-containers/s6-overlay/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]') \
    && S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION:1} \
    && wget -O /tmp/s6-overlay-arch.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64-${S6_OVERLAY_VERSION}.tar.xz" \
    && wget -O /tmp/s6-overlay-noarch.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch-${S6_OVERLAY_VERSION}.tar.xz" \
    && mkdir -p /tmp/s6 \
    && tar -Jxvf /tmp/s6-overlay-noarch.tar.xz -C /tmp/s6 \
    && tar -Jxvf /tmp/s6-overlay-arch.tar.xz -C /tmp/s6 \
    && cp -r /tmp/s6/* .

FROM alpine:latest as rootfs
WORKDIR /rootfs

COPY root .

RUN chmod -R +x *

# The version of nfs-utils 2.5.4 included in alpine 3.15
# has a bug where it doesn't work with v4 of the linux kernel
# https://bugzilla.redhat.com/show_bug.cgi?id=1979816
FROM alpine:latest

RUN set -x \
    && apk add \
        nfs-utils

# Configure for NFS v4 support
RUN set -x \
    && mkdir -p \
      /var/lib/nfs/rpc_pipefs \
      /var/lib/nfs/v4recovery \
      /proc/fs/nfsd \
    && echo "rpc_pipefs /var/lib/nfs/rpc_pipefs rpc_pipefs defaults 0 0" >> /etc/fstab \
    && echo "nfsd /proc/fs/nfsd nfsd defaults 0 0" >> /etc/fstab

# Ensure exports is empty
RUN set -x \
    && echo -n > /etc/exports

RUN set -x \
    && mkdir -p /log \
    && chmod 755 /log \
    && chown nobody:nobody /log

COPY --from=s6downloader /s6downloader /
COPY --from=rootfs /rootfs /

# System settings
ENV \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_LOGGING_SCRIPT="n10 s1000000 T 1 T" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

# User modifiable settings
ENV \
    DEFAULT_MOUNT_SETTINGS="*(rw,fsid=0,async,subtree_check,no_auth_nlm,insecure,no_root_squash)" \
    MOUNTD_ARGUMENTS="--no-udp --no-nfs-version 2 --no-nfs-version 3 8" \
    NFSD_ARGUMENTS="--debug 8 --no-udp --no-nfs-version 2 --no-nfs-version 3"


ENTRYPOINT ["/init"]

# NFS TCP
EXPOSE 2049
