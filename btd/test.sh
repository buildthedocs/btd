#!/bin/bash

set -e # Exit with nonzero exit code if anything fails

scriptdir=$(dirname $0)

. "${scriptdir}/ansi_color.sh"
#disable_color

#>
printf "$ANSI_DARKCYAN[BTD] Test $ANSI_NOCOLOR\n"

git clone https://github.com/buildthedocs/btd btd-full
cd btd-full

${scriptdir}/build.sh -o '../btd_full_builds' -v "master,featured"

cd ..
rm -rf btd-full
rm -rf btd_full_builds
#<
