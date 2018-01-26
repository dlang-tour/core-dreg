#!/bin/bash

set -e
set -u
set -o pipefail

dockerId=$1

err_report() {
    echo "Error on line $1"
}
trap 'err_report $LINENO' ERR

source='void main() { import std.experimental.allocator; }'
bsource=$(echo $source | base64 -w0)
docker run --rm $dockerId $bsource| grep -zq "Failure.*with output:.*Since.*Success"

# test custom args
source='import std.experimental.allocator;'
bsource=$(echo $source | base64 -w0)
docker run --rm $dockerId $bsource -c | grep -zq "Failure.*with output:.*Since.*Success"

# test docker flags
source='import std.experimental.allocator;'
bsource=$(echo $source | base64 -w0)
DOCKER_FLAGS="-c" docker run -e DOCKER_FLAGS --rm $dockerId $bsource | grep -zq "Failure.*with output:.*Since.*Success"

source='void main() { import std.stdio; }'
bsource=$(echo $source | base64 -w0)
[ $(docker run --rm $dockerId $bsource | wc -l) -eq 1 ]
