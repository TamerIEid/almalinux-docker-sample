#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

work=$(mktemp -d)
volume=""
container=""
cleanup() {
    if [[ -n "$container" ]]; then docker rm -f "$container" >/dev/null || true; fi
    if [[ -n "$volume" ]]; then docker volume rm "$volume" >/dev/null || true; fi
    rm -rf -- "$work"
}
trap cleanup EXIT
image=almalinux-inventory-sample:local

if [[ $# -gt 1 ]]; then
    echo "Usage: ./verify.sh [source-stock-url]" >&2
    exit 2
elif [[ $# -eq 1 ]]; then
    curl -fsS --max-time 10 "$1" > "$work/source.json"
    echo "Source: running service"
else
    cp vm/stock.json "$work/source.json"
    echo "Source: saved sample fixture"
fi
python3 -c 'import json, sys; stock = json.load(sys.stdin); assert stock["items"]' < "$work/source.json"
docker build -q -t "$image" .
volume=$(docker volume create)
mount="type=volume,src=$volume,dst=/var/lib/inventory"
docker run --rm -i --mount "$mount" --entrypoint sh "$image" \
    -c 'cat > /var/lib/inventory/stock.json' < "$work/source.json"

start_and_compare() {
    container=$(docker run -d --read-only --cap-drop ALL --security-opt no-new-privileges \
        --mount "$mount,readonly" -p 127.0.0.1::8080 "$image")
    address=$(docker port "$container" 8080/tcp)
    for _ in {1..30}; do
        if curl -fs --max-time 2 "http://$address/stock" -o "$work/response.json"; then
            cmp "$work/source.json" "$work/response.json"
            sha256sum "$work/response.json" | cut -d' ' -f1
            return 0
        fi
        sleep 0.25
    done
    docker logs "$container" >&2
    return 1
}

echo "First container response:"
start_and_compare
docker rm -f "$container" >/dev/null
container=""
echo "Replacement container response:"
start_and_compare
echo "PASS: both responses matched the source byte for byte."
