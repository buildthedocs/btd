#!/bin/sh
#
# Authors:
#   Unai Martinez-Corral
#
# Copyright 2017-2023 Unai Martinez-Corral <unai.martinezcorral@ehu.eus>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

set -e # Exit with nonzero exit code if anything fails

scriptdir=$(dirname $0)

. "${scriptdir}/utils.sh"

gstart "Config"
. ${scriptdir}/config.sh
gend

#>

#SOURCE_BRANCH="builders"
#TARGET_BRANCH="gh-pages"
#REPO=`git config remote.origin.url`

printf "\n$ANSI_DARKCYAN[BTD - deploy] Clone '$BTD_TARGET_URL:$BTD_TARGET_BRANCH/$BTD_TARGET_DIR' to 'out' and clean existing contents$ANSI_NOCOLOR\n"
git clone -b "$BTD_TARGET_BRANCH" "$BTD_TARGET_URL" out

OUTDIR="out"
if [ "$BTD_TARGET_DIR" = "" ]; then
  OUTDIR="out/$BTD_TARGET_DIR"
fi
rm -rf "$OUTDIR"/**/* || exit 0

cp -r "$BTD_OUTPUT_DIR/html"/. "$OUTDIR"
cd out

git config user.name "CI @ BTD"
git config user.email "ci@btd"

printf "\n$ANSI_DARKCYAN[BTD - deploy] Add .nojekyll$ANSI_NOCOLOR\n"
#https://help.github.com/articles/files-that-start-with-an-underscore-are-missing/
touch .nojekyll

printf "\n$ANSI_DARKCYAN[BTD - deploy] Add changes$ANSI_NOCOLOR\n"
git add .
# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
if [ $(git status --porcelain | wc -l) -lt 1 ]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi
git commit -am "BTD deploy: `git rev-parse --verify HEAD`"

printf "\n$ANSI_DARKCYAN[BTD - deploy] Push to $BTD_TARGET_BRANCH $ANSI_NOCOLOR\n"
# Now that we're all set up, we can push.
git push `echo "$BTD_TARGET_URL" | sed -e 's/https:\/\/github.com\//git@github.com:/g'` $TARGET_BRANCH
#<
