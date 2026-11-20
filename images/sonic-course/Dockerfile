FROM docker-sonic-vs:202511

COPY --chmod=755 <<'SH' /usr/local/bin/sudo
#!/bin/sh
exec "$@"
SH

COPY --chmod=755 <<'SH' /usr/local/bin/docker
#!/bin/sh
# SONiC VS runs the services in this container.
[ "$1" = exec ] || exit 64
shift
while [ "${1#-}" != "$1" ]; do shift; done
shift
exec "$@"
SH

RUN ln -sf /usr/bin/vtysh /usr/local/bin/rvtysh
