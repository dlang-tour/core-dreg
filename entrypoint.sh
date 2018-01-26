#!/bin/bash

set -e
set -u
set -o pipefail

cd /sandbox
echo "$1" | base64 -d > onlineapp.d

args=${DOCKER_FLAGS:-""}
# fallback to $2
args=${args:-${@:2}}
compiler="dmd"

if [[ $args =~ .*-c.* ]] ; then
    exec timeout -s KILL ${TIMEOUT:-30} dreg "${compiler}" $args onlineapp.d | tail -n100
elif [ -z ${2:-""} ] ; then
    exec timeout -s KILL ${TIMEOUT:-30} dreg "${compiler}" $args -g -run onlineapp.d | tail -n10000
fi
