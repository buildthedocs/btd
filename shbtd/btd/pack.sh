#!/usr/bin/env sh
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

scriptdir=$(dirname $0)

SOURCES="build deploy test"

add_subcmd() {
  X="`grep -n "#>" "${scriptdir}/$1".sh | sed -n 's/\(.*\):.*/\1/p'`"
  Y="`grep -n "#<" "${scriptdir}/$1".sh | sed -n 's/\(.*\):.*/\1/p'`"
  let "X++"
  let "Y--"
  sed -n -e "$X,$Y p" -e "$Y q" "${scriptdir}/$1".sh | sed "s/^/$2/"
}

BTD_FILE="${scriptdir}/../btd.sh"

printf "%s\n" \
  "#!/usr/bin/env sh" \
  "" \
  "set -e" \
  "" \
  'scriptdir="`dirname $0`"' \
  "" \
  'cd "`dirname $0`"' \
  'BTD_SH="`pwd`/`basename $0`"' \
  "cd -" \
> "$BTD_FILE"

printf "\n" >> "$BTD_FILE"
cat "${scriptdir}"/utils.sh >> "$BTD_FILE"

for f in config $SOURCES; do
  printf "\n#---\n\nbtd_$f() {\n"  >> "$BTD_FILE"
  add_subcmd $f "  " >> "$BTD_FILE"
  printf "}\n"  >> "$BTD_FILE"
done

printf "\n#---\n\ncase \"\$1\" in\n" >> "$BTD_FILE"

for f in $SOURCES; do
  printf "  $f)\n    shift;\n" >> "$BTD_FILE"
  case "$f" in
    "build"|"deploy")
      printf "%s\n" \
        "    btd_config \"\$@\"" \
        "    btd_$f" \
      >> "$BTD_FILE"
    ;;
    "test")
      printf "%s\n" \
        "    btd_$f \"\$0\"" \
      >> "$BTD_FILE"
    ;;
    *)
      printf "%s\n" \
        "    btd_$f" \
        >> "$BTD_FILE"
    ;;
  esac
  printf "  ;;\n" >> "$BTD_FILE"
done

printf "%s\n" \
  "  *)" \
  "    echo \"$ANSI_RED[BTD] Unknown command \$1$ANSI_NOCOLOR\"" \
  "    exit 1" \
  "  ;;" \
  "esac" >> "$BTD_FILE"

sed -i 's#\(.*\) .*/build.sh#\1 "$BTD_SH" build#' "$BTD_FILE"
sed -i 's#\(.*\)${scriptdir}/\.\./#\1${scriptdir}/#' "$BTD_FILE"
