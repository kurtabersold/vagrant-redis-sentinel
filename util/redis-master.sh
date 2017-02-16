#!/usr/bin/env bash
# TODO Try all sentinels in array?
SENTINEL_RESPONSE=( $(redis-cli -h 127.0.0.1 -p 26310 SENTINEL get-master-addr-by-name redis-cluster) )
MASTER_HOST="${SENTINEL_RESPONSE[0]}"
MASTER_PORT="${SENTINEL_RESPONSE[1]}"

# Connect to master redis instance:
redis-cli -h "$MASTER_HOST" -p "$MASTER_PORT" $@
