[program:running-sample-data-reddit]
user=nobody
directory=/usr/local/share/landoop/sample-data
command=bash -c 'for ((i=0;i<90;i++)); do sleep 2; curl "http://localhost:$REGISTRY_PORT" | grep "{}" && { sleep 7; break; }; done; /usr/local/share/landoop/sample-data/running-reddit.sh'
redirect_stderr=true
stdout_logfile=/var/log/running-reddit.log
autorestart=false
startretries=1


export TOPICS=(sea_vessel_position_reports reddit_posts nyc_yellow_taxi_trip_data backblaze_smart telecom_italia_data telecom_italia_grid)
export PARTITIONS=(3 5 1 2 4 1)
export REPLICATION=(1 1 1 1 1 1)
export CLEANUP_POLICY=(delete delete delete delete delete compact)
export DATA=(ais.txt.gz reddit.may2015.30k.wkey.json.xz yellow_tripdata_2016-Jan_May.100k.json.xz backblaze_smart_2017_q1.75k.wkey.json.xz sms-call-internet-mi-2013-12.100k.ts.wkey.json.xz milano-grid.wkey.json.xz)
export VALUES=(classAPositionReportSchema.json reddit.value.json nyc_trip_records_yellow.value.json NULL TelecomItalia-Milano-SMS_Call_Internet.value.json TelecomItalia-Milano-Grid.value.json)
export KEYS=(classAPositionReportSchemaKey.json reddit.key.json NULL NULL TelecomItalia-Milano-SMS_Call_Internet.key.json TelecomItalia-Milano-SMS_Call_Internet.key.json)
export COMPRESSION=(uncompressed lz4 gzip uncompressed lz4 uncompressed)
export RATES=(10 15 20 5 6 NULL)
export JITTER=(2 5 4 1 0 NULL)
export PERIOD=(10s 20s 25s 15s 10s NULL)

#!/usr/bin/env bash

# shellcheck source=variables.env
# source variables.env

GENERATOR_BROKER=${GENERATOR_BROKER:-localhost}

# Create Topics
# shellcheck disable=SC2043
for key in 1; do
    # Create topic with x partitions and a retention size of 50MB, log segment
    # size of 20MB and compression type y.
    kafka-topics \
        --zookeeper localhost:${ZK_PORT} \
        --topic "${TOPICS[key]}" \
        --partitions "${PARTITIONS[key]}" \
        --replication-factor "${REPLICATION[key]}" \
        --config retention.bytes=26214400 \
        --config compression.type="${COMPRESSION[key]}" \
        --config segment.bytes=8388608 \
        --create
done

# Insert data with key
# shellcheck disable=SC2043
for key in 1; do
    unset SCHEMA_REGISTRY_OPTS
    unset SCHEMA_REGISTRY_JMX_OPTS
    unset SCHEMA_REGISTRY_LOG4J_OPTS
    /usr/local/bin/normcat -r "${RATES[key]}" -j "${JITTER[key]}" -p "${PERIOD[key]}" -c -v "${DATA[key]}" | \
        SCHEMA_REGISTRY_HEAP_OPTS="-Xmx50m" kafka-avro-console-producer \
            --broker-list ${GENERATOR_BROKER}:${BROKER_PORT} \
            --topic "${TOPICS[key]}" \
            --property parse.key=true \
            --property key.schema="$(cat "${KEYS[key]}")" \
            --property value.schema="$(cat "${VALUES[key]}")" \
            --property schema.registry.url=http://localhost:${REGISTRY_PORT}
done