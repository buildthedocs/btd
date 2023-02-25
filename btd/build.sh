#!/bin/bash

set -e # Exit with nonzero exit code if anything fails

scriptdir=$(dirname $0)

. "${scriptdir}/travis_utils.sh"
. "${scriptdir}/ansi_color.sh"
#disable_color

printf "$ANSI_DARKCYAN[BTD - build] Executing $0 `echo $@` $ANSI_NOCOLOR\n"

echo "travis_fold:start:config"
travis_time_start
. ${scriptdir}/config.sh
travis_time_finish
echo "travis_fold:end:config"

#>

check_v() { r="1"; if [ -n "$(docker volume inspect $1 2>&1 | grep "Error:")" ]; then r="0"; fi; echo "$r"; }
rm_v() {
  if [ "$(check_v $1)" = "1" ]; then
    echo "Removing existing volume $1"
    docker volume rm "$1";
  fi;
}

check_c() { r="1"; if [ -n "$(docker container inspect $1 2>&1 | grep "Error:")" ]; then r="0"; fi; echo "$r"; }
rm_c() {
  if [ "$(check_c $1)" = "1" ]; then
    echo "Removing existing container $1"
    docker rm -f "$1";
  fi;
}

build_version() {
  rm_c btd-box
  rm_v btd-vol

  printf "$ANSI_DARKCYAN[BTD - build $1] Create volume btd-vol $ANSI_NOCOLOR\n"
  docker volume create btd-vol

  echo "travis_fold:start:sphinx_$1"
  travis_time_start
  printf "$ANSI_DARKCYAN[BTD - build $1] Run Sphinx $ANSI_NOCOLOR\n"
  docker run --rm -tv /$(pwd):/src -v btd-vol://_build btdi/sphinx bash -c "\
    cd $BTD_INPUT_DIR && \
    sphinx-build -T -b html -D language=en . /_build/html && \
    sphinx-build -T -b json -d /_build/doctrees-json -D language=en . /_build/json && \
    sphinx-build -b latex -D language=en -d _build/doctrees . /_build/latex"
  travis_time_finish
  echo "travis_fold:end:sphinx_$1"

  echo "travis_fold:start:latex_$1"
  travis_time_start
  printf "$ANSI_DARKCYAN[BTD - build $1] Run LaTeX $ANSI_NOCOLOR\n"
  docker run --rm -tv /$(pwd):/src -v btd-vol://_build btdi/latex bash -c "\
    cd $BTD_INPUT_DIR && \
    cd /_build/latex && \
    FILE=\"\`ls *.tex | sed -e 's/\.tex//'\`\" && \
    pdflatex -interaction=nonstopmode \$FILE.tex; \
    makeindex -s python.ist \$FILE.idx; \
    pdflatex -interaction=nonstopmode \$FILE.tex; \
    mv -f \$FILE.pdf /_build/\${FILE}_${1}.pdf"
  travis_time_finish
  echo "travis_fold:end:latex_$1"

  echo "travis_fold:start:copy_$1"
  travis_time_start
  printf "$ANSI_DARKCYAN[BTD - build $1] Copy artifacts $ANSI_NOCOLOR\n"
  rm_c btd-box
  docker run --name btd-box -dv btd-vol://_build busybox sh -c "tail -f /dev/null"
  printf "Wait for btd-box to start...\n"
  while [ "`docker ps -f NAME=btd-box -q`" = "" ]; do
    docker ps -f NAME=btd-box -q
    sleep 1
  done
  printf "Wait for btd-box to run...\n"
  while [ "`docker inspect --format='{{json .State.Running}}' btd-box`" != "true" ]; do
    docker inspect --format='{{json .State.Running}}' btd-box
    sleep 1
  done
  printf "Copying...\n"
  docker cp "btd-box:_build/" "$BTD_OUTPUT_DIR/$1/"
  rm_c btd-box
  travis_time_finish
  echo "travis_fold:end:copy_$1"

  printf "$ANSI_DARKCYAN[BTD - build $1] Remove volume btd-vol $ANSI_NOCOLOR\n"
  rm_v btd-vol
}

echo "travis_fold:start:abs_output"
printf "$ANSI_DARKCYAN[BTD - build] Get absolute path of BTD_OUTPUT_DIR $ANSI_NOCOLOR\n"
if [ -d "$BTD_OUTPUT_DIR" ]; then rm -rf "$BTD_OUTPUT_DIR"; fi
mkdir -p "$BTD_OUTPUT_DIR"
cd "$BTD_OUTPUT_DIR"
mkdir -p html/pdf
BTD_OUTPUT_DIR="$(pwd)"
cd -
echo "travis_fold:end:abs_output"

echo "travis_fold:start:list"
travis_time_start
printf "$ANSI_DARKCYAN[BTD - build] Create version list $ANSI_NOCOLOR\n"
printf "<head></head><body>\n" > "index.html"
for v in `echo "$BTD_VERSION" | sed 's/,/ /g'`; do
  printf "<a href=\"$v\">$v</a>\n" >> "index.html"
done
printf "</body>\n" >> "index.html"
mv "index.html" "$BTD_OUTPUT_DIR/html/index.html"
travis_time_finish
echo "travis_fold:end:list"

for v in `echo "$BTD_VERSION" | sed 's/,/ /g'`; do
  echo "travis_fold:start:$v"
  travis_time_start
  printf "$ANSI_DARKCYAN[BTD - build] Start $v $ANSI_NOCOLOR\n"
  git checkout $v
  build_version "$v"
  mv "$BTD_OUTPUT_DIR/$v/html" "$BTD_OUTPUT_DIR/html/$v/"
  mv "$BTD_OUTPUT_DIR/$v/"*.pdf "$BTD_OUTPUT_DIR/html/pdf/"
  travis_time_finish
  echo "travis_fold:end:$v"
  printf "$ANSI_DARKCYAN[BTD - build] End $v $ANSI_NOCOLOR\n"
done

if [ "$CLEAN_BTD" != "" ]; then
  cd ..
  rm -rf "$CLEAN_BTD"
fi
#<
