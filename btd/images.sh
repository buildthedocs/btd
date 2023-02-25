#! /bin/sh
# This script is executed in the travis-ci environment.

set -e

scriptdir=$(dirname $0)

. "${scriptdir}/travis_utils.sh"
. "${scriptdir}/ansi_color.sh"
#disable_color

#>
f="${scriptdir}/../Dockerfile"
for tag in `sed -e 's/FROM.*AS do-//;tx;d;:x' $f`; do
    echo "travis_fold:start:$tag"
    travis_time_start
    printf "$ANSI_BLUE[DOCKER build] ${tag}$ANSI_NOCOLOR\n"
    docker build -t "btdi/${tag}" --target "do-$tag" - < "$f"
    travis_time_finish
    echo "travis_fold:end:$tag"
done
#<
