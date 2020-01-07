#! /bin/sh

set -e

cd $(dirname "$0")

ANSI_RED="\033[31m"
ANSI_GREEN="\033[32m"
ANSI_YELLOW="\033[33m"
ANSI_BLUE="\033[34m"
ANSI_MAGENTA="\033[35m"
ANSI_GRAY="\033[90m"
ANSI_CYAN="\033[36;1m"
ANSI_DARKCYAN="\033[36m"
ANSI_NOCOLOR="\033[0m"

#---

print_start() {
  COL="$ANSI_YELLOW"
  if [ "x$2" != "x" ]; then
    COL="$2"
  fi
  printf "${COL}${1}$ANSI_NOCOLOR\n"
}

gstart () {
  print_start "$@"
}
gend () {
  :
}

if [ -n "$CI" ]; then
  echo "INFO: set 'gstart' and 'gend' for CI"
  gstart () {
    printf '::group::'
    print_start "$@"
    SECONDS=0
  }

  gend () {
    duration=$SECONDS
    echo '::endgroup::'
    printf "${ANSI_GRAY}took $(($duration / 60)) min $(($duration % 60)) sec.${ANSI_NOCOLOR}\n"
  }
fi

#---

dfile="${1:-Dockerfile}"

for tag in `sed -e 's/FROM.*AS //;tx;d;:x' "$dfile"`; do
  gstart "[DOCKER build] ${tag}"
  docker build -t "btdi/`echo $tag | sed -e 's/_/:/g'`" --target "$tag" . -f "$dfile"
  gend
done
