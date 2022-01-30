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

if grep -q "^--- .*d" onlineapp.d > /dev/null 2>&1  ; then
    mv onlineapp.d onlineapp.har
    har_files="$(har --dir=$PWD "onlineapp.har")"

    files=($(echo "$har_files" | grep "[.]d$" || echo ""))
else
    files=("onlineapp.d")
fi

if [[ $args =~ .*-c.* ]] ; then
    exec timeout -s KILL ${TIMEOUT:-60} dreg "${compiler}" $args ${files[@]} | tail -n100
elif [ -z ${2:-""} ] ; then
    N="${#files[@]}"
    add="${files[@]:1:$N}"
    entry="${files[0]}"
    exec timeout -s KILL ${TIMEOUT:-60} dreg "${compiler}" $args -g $add -run $entry | tail -n10000
fi
