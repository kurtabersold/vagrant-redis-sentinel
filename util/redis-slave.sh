#!/usr/bin/env bash

SENTINEL_NAME="redis-cluster"
SENTINELS=(127.0.0.1:26310 127.0.0.1:26320 127.0.0.1:26330)
SENTINEL_RESPONSE=()
SENTINEL_SLAVE_QUERY_LENGTH=40
SLAVES=()

# Loop through sentinels array, asking each sentinel for the master redis instance
for i in "${SENTINELS[@]}"; do
    IFS=':' read -ra SENTINEL_SOCKET <<< "$i"
    SENTINEL_HOST="${SENTINEL_SOCKET[0]}"
    SENTINEL_PORT="${SENTINEL_SOCKET[1]}"
    SENTINEL_RESPONSE+=( $(redis-cli -h $SENTINEL_HOST -p $SENTINEL_PORT SENTINEL slaves $SENTINEL_NAME) )
done

SENTINEL_RESPONSE_LENGTH=${#SENTINEL_RESPONSE[@]}
SENTINEL_SLAVE_COUNT=$(( ${SENTINEL_RESPONSE_LENGTH} / ${#SENTINELS[@]} / ${SENTINEL_SLAVE_QUERY_LENGTH}  ))

for ((n=0; n<${SENTINEL_RESPONSE_LENGTH}; n++)); do
    # Each slave yields 40 elements
    if (( $((n % ${SENTINEL_SLAVE_QUERY_LENGTH} )) == 0 )); then
        # 1st element in each group of 40 is a redis slave socket address
        ELEMENT=1
        SLAVES+=( ${SENTINEL_RESPONSE[${n}+${ELEMENT}]} )
    fi
done

# Uniqify the slaves socket array
SLAVES=( $(printf "%s\n" "${SLAVES[@]}" |  sort -u) )

# Loop through slaves array and connect to first slave. If successful break out of the loop
for i in "${SLAVES[@]}"; do
    IFS=':' read -ra SLAVE_SOCKET <<< "$i"
    SLAVE_HOST="${SLAVE_SOCKET[0]}"
    SLAVE_PORT="${SLAVE_SOCKET[1]}"
    redis-cli -h "$SLAVE_HOST" -p "$SLAVE_PORT" $@ && break
done

