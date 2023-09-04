#!/bin/bash
export POD_IP=`hostname -i`
export KAFKA_BROKER_ID=${HOSTNAME##*-} 
export HOSTNAME=`hostname -f`
unset KAFKA_PORT && export KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://${POD_IP}:9092 && exec /etc/confluent/docker/run