#!/usr/bin/env bash

SENTINEL_NAME="redis-cluster"
SENTINELS=(127.0.0.1:26310 127.0.0.1:26320 127.0.0.1:26330)
SENTINEL_RESPONSE=()

# Loop through sentinels array, asking each sentinel for the master redis instance
for i in "${SENTINELS[@]}"; do
    IFS=':' read -ra SENTINEL_SOCKET <<< "$i"
    SENTINEL_HOST="${SENTINEL_SOCKET[0]}"
    SENTINEL_PORT="${SENTINEL_SOCKET[1]}"
    SENTINEL_RESPONSE+=( $(redis-cli -h $SENTINEL_HOST -p $SENTINEL_PORT SENTINEL get-master-addr-by-name $SENTINEL_NAME) )
done

# There should be two elements per sentinel response
MASTER_HOST="${SENTINEL_RESPONSE[0]}"
MASTER_PORT="${SENTINEL_RESPONSE[1]}"

# Connect to master redis instance:
redis-cli -h "$MASTER_HOST" -p "$MASTER_PORT" $@
