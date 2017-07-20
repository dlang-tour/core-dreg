#!/bin/bash

set -e
set -u
set -o pipefail

cd /sandbox
echo "$*" | base64 -d > onlineapp.d

exec timeout -s KILL ${TIMEOUT:-60} dreg dmd -run onlineapp.d | tail -n100
