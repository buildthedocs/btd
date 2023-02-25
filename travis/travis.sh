#!/bin/sh

set -e

cd $(dirname $0)/..

docker run --rm -itv $(pwd):/src/btd_prj -w /src/btd_prj/cli btdi/dev sh -c "go get ./...; go build -a -o btd"

./cli/btd
