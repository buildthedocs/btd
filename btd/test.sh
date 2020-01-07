#!/bin/bash

set -e # Exit with nonzero exit code if anything fails

scriptdir=$(dirname $0)

. "${scriptdir}/utils.sh"

#>
printf "$ANSI_DARKCYAN[BTD] Test $ANSI_NOCOLOR\n"

VERSIONS_btd="master,featured"
VERSIONS_ghdl="master,v0.35,v0.34"
VERSIONS_PoC="master,relese"

for prj in "buildthedocs/btd" "ghdl/ghdl" "1138-4EB/PoC"; do
  p="`echo $prj | cut -d'/' -f2`"

  git clone "https://github.com/$prj" "${p}-test"
  cd "${p}-test"

  VERSIONS="VERSIONS_${p}"
  if [ "$p" = "PoC" ]; then INPUT="-i docs"; fi
  ${scriptdir}/build.sh -o "../${p}_test_builds" -v "${!VERSIONS}" $INPUT

  cd ..
  rm -rf "$p"
  rm -rf "${p}_test_builds"
done

exit 0

#git clone https://github.com/buildthedocs/btd btd-full
#cd btd-full

#cd ..
#rm -rf btd-full
#rm -rf btd_full_builds

#git clone https://github.com/VLSI-EDA/PoC
#cd PoC
#curl -L https://raw.githubusercontent.com/buildthedocs/btd/master/btd.sh | sh -s build -v "release,stable" -i docs
#<
