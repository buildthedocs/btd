#! /bin/sh

set -e

scriptdir=$(dirname $0)

. "${scriptdir}/btd/travis_utils.sh"
. "${scriptdir}/btd/ansi_color.sh"
#disable_color

# Skip deploy if there is no '[ci images]' in the commit message
if [ "$1" = "skip" ] || [ "$(echo $1 | grep -o '\[ci images\]')" = "" ]; then
    printf "${ANSI_GREEN}SKIP DEPLOY2DOCKERHUB$ANSI_NOCOLOR\n";
    exit 0;
fi

docker login -u="$DOCKER_USER" -p="$DOCKER_PASS"
for tag in `echo $(docker images btdi/* | awk -F ' ' '{print $1 ":" $2}') | cut -d ' ' -f2-`; do
    if [ "$tag" = "REPOSITORY:TAG" ]; then break; fi
    t="`echo $tag | grep -oP 'btdi/\K.*'`"
    echo "travis_fold:start:$t"
    travis_time_start
    printf "$ANSI_YELLOW[DOCKER push] ${tag}$ANSI_NOCOLOR\n"
    docker push $tag
    travis_time_finish
    echo "travis_fold:end:$t"
done
docker logout
