#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
: "${STUDENT:?Export STUDENT}" "${N:?Export N without a leading zero}"
export N AS1=$((65000 + N)) AS2=$((65100 + N))

for router in r1 r2; do
    node="clab-${STUDENT}-l2-${router}"
    echo "== $node: waiting for SONiC"
    deadline=$((SECONDS + 180))
    until docker exec "$node" sh -c '
        test "$(redis-cli -n 4 exists "PORT|Ethernet0" "PORT|Ethernet4")" = 2 &&
        ip link show Ethernet4 &&
        supervisorctl status intfmgrd portmgrd zebra mgmtd staticd
    ' >/dev/null 2>&1; do
        if (( SECONDS >= deadline )); then
            echo "$node did not become ready" >&2
            exit 1
        fi
        sleep 3
    done
    if ! docker exec "$node" supervisorctl status bgpd >/dev/null 2>&1; then
        docker exec "$node" supervisorctl start bgpd
    fi
    echo "== $node: interfaces"
    envsubst '${N}' < "configs/$router.sh" | docker exec -i "$node" bash
    echo "== $node: FRR"
    envsubst '${N} ${AS1} ${AS2}' < "configs/$router-frr.conf" |
        docker exec -i "$node" bash -e -c 'cat > /tmp/lab2-frr.conf
        vtysh -f /tmp/lab2-frr.conf
        vtysh -c "write memory"'
done
