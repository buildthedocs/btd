#! /bin/sh

scriptdir=$(dirname $0)

SOURCES="build images deploy test"

add_subcmd() {
  X="`grep -n "#>" "${scriptdir}/$1".sh | sed -n 's/\(.*\):.*/\1/p'`"
  Y="`grep -n "#<" "${scriptdir}/$1".sh | sed -n 's/\(.*\):.*/\1/p'`"
  let "X++"
  let "Y--"
  sed -n -e "$X,$Y p" -e "$Y q" "${scriptdir}/$1".sh | sed "s/^/$2/"
}

BTD_FILE="${scriptdir}/../btd.sh"

printf "#! /bin/sh\n\nset -e\n\nscriptdir=\"\$(dirname \$0)\"\n" > "$BTD_FILE"

add_subcmd ansi_color >> "$BTD_FILE"
printf "\n#---\n\n" >> "$BTD_FILE"
add_subcmd travis_utils  >> "$BTD_FILE"

for f in config $SOURCES; do
  printf "\n#---\n\nbtd_$f() {\n"  >> "$BTD_FILE"
  add_subcmd $f "  " >> "$BTD_FILE"
  printf "}\n"  >> "$BTD_FILE"
done

printf "\n#---\n\ncase \"\$1\" in\n" >> "$BTD_FILE"

for f in $SOURCES; do
  printf "  $f)\n    shift;\n" >> "$BTD_FILE"
  if [ "$f" = "build" ]; then
    printf "    btd_config \"\$@\"\n" >> "$BTD_FILE"
  fi
  printf "%s\n" \
    "    btd_$f" \
    "  ;;" >> "$BTD_FILE"
done

printf "%s\n" \
  "  *)" \
  "    echo \"$ANSI_RED[BTD] Unknown command \$1$ANSI_NOCOLOR\"" \
  "    exit 1" \
  "  ;;" \
  "esac" >> "$BTD_FILE"

sed -i "s#.*/build.sh#  \$0 build#" "$BTD_FILE"
