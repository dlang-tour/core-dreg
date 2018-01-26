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
docker run --rm $dockerId $bsource | grep -zq "Failure.*with output:.*Since.*2.069.2"

source='void main() { import std.stdio; }'
bsource=$(echo $source | base64 -w0)
[ $(docker run --rm $dockerId $bsource | wc -l) -eq 1 ]
