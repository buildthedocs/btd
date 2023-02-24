#! /bin/sh

set -e

scriptdir="`dirname $0`"

cd "`dirname $0`"
BTD_SH="`pwd`/`basename $0`"
cd -

enable_color() {
  ENABLECOLOR='-c '
  ANSI_RED="\033[31m"
  ANSI_GREEN="\033[32m"
  ANSI_YELLOW="\033[33m"
  ANSI_BLUE="\033[34m"
  ANSI_MAGENTA="\033[35m"
  ANSI_CYAN="\033[36;1m"
  ANSI_DARKCYAN="\033[36m"
  ANSI_NOCOLOR="\033[0m"
}

disable_color() { unset ENABLECOLOR ANSI_RED ANSI_GREEN ANSI_YELLOW ANSI_BLUE ANSI_MAGENTA ANSI_CYAN ANSI_DARKCYAN ANSI_NOCOLOR; }

enable_color

#---

# This is a trimmed down copy of
# https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/templates/header.sh
travis_time_start() {
  # `date +%N` returns the date in nanoseconds. It is used as a replacement for $RANDOM, which is only available in bash.
  travis_timer_id=`date +%N`
  travis_start_time=$(travis_nanoseconds)
  echo "travis_time:start:$travis_timer_id"
}
travis_time_finish() {
  travis_end_time=$(travis_nanoseconds)
  local duration=$(($travis_end_time-$travis_start_time))
  echo "travis_time:end:$travis_timer_id:start=$travis_start_time,finish=$travis_end_time,duration=$duration"
}

travis_nanoseconds() { date -u '+%s%N'; }
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
  travis_nanoseconds() { date -u '+%s000000000'; }
fi

#---

btd_config() {
  # Transform long options to short ones
  for arg in $@; do
    shift
    case "$arg" in
        "--config"|"-config")   set -- "$@" "-c";;
        "--input"|"-input")     set -- "$@" "-i";;
        "--output"|"-output")   set -- "$@" "-o";;
        "--source"|"-source")   set -- "$@" "-s";;
        "--target"|"-target")   set -- "$@" "-t";;
        "--formats"|"-formats") set -- "$@" "-f";;
        "--version"|"-version") set -- "$@" "-v";;
      *) set -- "$@" "$arg"
    esac
  done
  # Parse args
  while getopts ":c:i:o:s:t:f:v:" opt; do
    case $opt in
      c) BTD_CONFIG_FILE=$OPTARG;;
      i) BTD_INPUT_DIR=$OPTARG;;
      o) BTD_OUTPUT_DIR=$OPTARG;;
      s) BTD_SOURCE_BRANCH=$OPTARG;;
      f) BTD_TARGET_BRANCH=$OPTARG;;
      t) BTD_FORMATS=$OPTARG;;
      v) BTD_VERSION="$OPTARG";;
      \?) printf "$ANSI_RED[BTD - config] Invalid option: -$OPTARG $ANSI_NOCOLOR\n" >&2
  	exit 1 ;;
      :)  printf "$ANSI_RED[BTD - config] Option -$OPTARG requires an argument. $ANSI_NOCOLOR\n" >&2
  	exit 1 ;;
    esac
  done
  
  if [   "$BTD_CONFIG_FILE" = "" ]; then   BTD_CONFIG_FILE=".btd.yml";       fi
  if [     "$BTD_INPUT_DIR" = "" ]; then     BTD_INPUT_DIR="doc";            fi
  if [    "$BTD_OUTPUT_DIR" = "" ]; then    BTD_OUTPUT_DIR="../btd_builds";  fi
  if [ "$BTD_SOURCE_BRANCH" = "" ]; then BTD_SOURCE_BRANCH="master";         fi
  if [ "$BTD_TARGET_BRANCH" = "" ]; then BTD_TARGET_BRANCH="gh-pages";       fi
  if [       "$BTD_FORMATS" = "" ]; then       BTD_FORMATS="html,pdf";       fi
  if [       "$BTD_VERSION" = "" ]; then       BTD_VERSION="master";         fi
  if [    "$BTD_IMG_SPHINX" = "" ]; then    BTD_IMG_SPHINX="btdi/sphinx:py2-featured"; fi
  if [     "$BTD_IMG_LATEX" = "" ]; then     BTD_IMG_LATEX="btdi/latex";     fi
  if [  "$BTD_SPHINX_THEME" = "" ]; then  BTD_SPHINX_THEME="https://github.com/buildthedocs/sphinx_btd_theme/archive/master.tar.gz"; fi
  if [    "$BTD_DEPLOY_KEY" = "" ]; then    BTD_DEPLOY_KEY="deploy_key.enc"; fi
  
  #--- Source repository and input dir
  
  parse_branch() {
    if [ "$PARSED_BRANCH" != "" ]; then
      if [ "`echo "$PARSED_BRANCH" | grep ":"`" != "" ]; then
        if [ "`echo "$PARSED_BRANCH" | grep "://"`" != "" ]; then
          PARSED_URL="`echo "$PARSED_BRANCH" | cut -d':' -f1-2`"
          CUT_BRANCH="3"
        else
          PARSED_URL="http://github.com/`echo "$PARSED_BRANCH" | cut -d':' -f1`"
          CUT_BRANCH="2"
        fi
        PARSED_BRANCH="`echo "$PARSED_BRANCH" | cut -d':' -f$CUT_BRANCH`"
      fi
  
      if [ "`echo "$PARSED_BRANCH" | grep "/"`" != "" ]; then
        PARSED_DIR="`echo "$PARSED_BRANCH" | cut -d'/' -f2-`"
        PARSED_BRANCH="`echo "$PARSED_BRANCH" | cut -d'/' -f1`"
      fi
  
      if [ "`echo "$PARSED_BRANCH" | grep "/"`" != "" ]; then
        PARSED_DIR="`echo "$PARSED_BRANCH" | cut -d'/' -f2-`"
        PARSED_BRANCH="`echo "$PARSED_BRANCH" | cut -d'/' -f1`"
      fi
    fi
  }
  
  PARSED_BRANCH="$BTD_SOURCE_BRANCH"
  parse_branch
  BTD_SOURCE_URL="$PARSED_URL"
  BTD_SOURCE_BRANCH="$PARSED_BRANCH"
  if [ "$PARSED_DIR" != "" ]; then
    BTD_INPUT_DIR="$PARSED_DIR"
  fi
  
  CLEAN_BTD=""
  if [ "$BTD_SOURCE_URL" != "" ]; then
    printf "$ANSI_DARKCYAN[BTD - config] Clone -b $BTD_SOURCE_BRANCH $BTD_SOURCE_URL $ANSI_NOCOLOR\n"
    if [ -d "btd-work" ]; then rm -rf "btd-work"; fi
    git clone -b "$BTD_SOURCE_BRANCH" "$BTD_SOURCE_URL" ./btd-work
    cd btd-work
    CLEAN_BTD="btd-work"
  fi
  
  #--- Target repository
  
  PARSED_BRANCH="$BTD_TARGET_BRANCH"
  parse_branch
  if [ "`echo "$BTD_TARGET_BRANCH" | grep ":"`" = "" ]; then
    BTD_TARGET_URL="`git config remote.origin.url`"
  else
    BTD_TARGET_URL="$PARSED_URL"
  fi
  BTD_TARGET_BRANCH="$PARSED_BRANCH"
  if [ "$PARSED_DIR" != "" ]; then
    BTD_TARGET_DIR="$PARSED_DIR"
  fi
  
  #---
  
  printf "$ANSI_DARKCYAN[BTD - config] Parsed options:$ANSI_NOCOLOR\n"
  
  echo "BTD_CONFIG_FILE: $BTD_CONFIG_FILE"
  echo "BTD_FORMATS: $BTD_FORMATS"
  echo "BTD_VERSION: $BTD_VERSION"
  echo "BTD_OUTPUT_DIR: $BTD_OUTPUT_DIR"
  echo "---"
  echo "BTD_SOURCE_URL: $BTD_SOURCE_URL"
  echo "BTD_SOURCE_BRANCH: $BTD_SOURCE_BRANCH"
  echo "BTD_INPUT_DIR: $BTD_INPUT_DIR"
  echo "---"
  echo "BTD_TARGET_URL: $BTD_TARGET_URL"
  echo "BTD_TARGET_BRANCH: $BTD_TARGET_BRANCH"
  echo "BTD_TARGET_DIR: $BTD_TARGET_DIR"
  echo "---"
  echo "BTD_IMG_SPHINX: $BTD_IMG_SPHINX"
  echo "BTD_IMG_LATEX: $BTD_IMG_LATEX"
  echo "BTD_SPHINX_THEME: $BTD_SPHINX_THEME"
  
}

#---

btd_build() {
  
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
  
    printf "$ANSI_DARKCYAN[BTD - build $1] Check if requirements.txt exists $ANSI_NOCOLOR\n"
    if [ -f "./requirements.txt" ] || [ -f "./$BTD_INPUT_DIR/requirements.txt" ]; then
      if [ -f "./$BTD_INPUT_DIR/requirements.txt" ]; then
        REQ_PREFIX="";
      else
        REQ_PREFIX="../";
      fi
      INSTALL_REQUIREMENTS="pip2 install --exists-action=w -r ${REQ_PREFIX}requirements.txt &&";
    fi
  
    echo "INSTALL_REQUIREMENTS: $INSTALL_REQUIREMENTS"
  
    printf "$ANSI_DARKCYAN[BTD - build $1] Get theme(s) $ANSI_NOCOLOR\n"
    if [ "$BTD_SPHINX_THEME" != "none" ]; then
      mkdir -p theme-tmp
      cd theme-tmp
      curl -L "$BTD_SPHINX_THEME" | tar xvz --strip 1
      zip -r "../$BTD_INPUT_DIR/sphinx_btd_theme.zip" ./*
      cd .. && rm -rf theme-tmp
    fi
  
  #  for f in $(echo $BTD_FORMATS | sed 's/,/ /g'`); do
  #    echo "$f"
  #  done
  
    echo "travis_fold:start:sphinx_$1"
    travis_time_start
    printf "$ANSI_DARKCYAN[BTD - build $1] Run Sphinx $ANSI_NOCOLOR\n"
    docker run --rm -tv /$(pwd):/src -v btd-vol://_build "$BTD_IMG_SPHINX" sh -c "\
      cd $BTD_INPUT_DIR && $INSTALL_REQUIREMENTS \
      sphinx-build -T -b html -D language=en . /_build/html && \
      sphinx-build -T -b json -d /_build/doctrees-json -D language=en . /_build/json && \
      sphinx-build -b latex -D language=en -d _build/doctrees . /_build/latex"
    travis_time_finish
    echo "travis_fold:end:sphinx_$1"
  
    echo "travis_fold:start:latex_$1"
    travis_time_start
    printf "$ANSI_DARKCYAN[BTD - build $1] Run LaTeX $ANSI_NOCOLOR\n"
    docker run --rm -tv /$(pwd):/src -v btd-vol://_build "$BTD_IMG_LATEX" sh -c "\
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
  
  current_branch="`git rev-parse --abbrev-ref HEAD`"
  
  if [ "$TRAVIS" = "true" ]; then
    current_branch="$TRAVIS_BRANCH"
    current_pwd="`pwd`"
    git clone -b "$current_branch" "`git remote get-url origin`" ../tmp-full
    cd ../tmp-full
  fi
  
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
  
  git checkout "$current_branch"
  
  if [ "$TRAVIS" = "true" ]; then
    cd "$current_pwd"
  fi
  
  if [ "$CLEAN_BTD" != "" ]; then
    cd ..
    rm -rf "$CLEAN_BTD"
  fi
}

#---

btd_images() {
  cd "${scriptdir}/images"
  for tag in `sed -e 's/FROM.*AS do-//;tx;d;:x' Dockerfile`; do
      echo "travis_fold:start:$tag"
      travis_time_start
      printf "$ANSI_BLUE[DOCKER build] ${tag}$ANSI_NOCOLOR\n"
      docker build -t "btdi/`echo $tag | sed -e 's/__/:/g'`" --target "do-$tag" .
      travis_time_finish
      echo "travis_fold:end:$tag"
  done
}

#---

btd_deploy() {
  # Pull requests and commits to other branches shouldn't try to deploy, just build to verify
  # -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH"
  if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
      printf "\nSkipping pages deploy\n"
      exit 0
  fi
  
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
  
  git config user.name "Travis CI @ BTD"
  git config user.email "travis@buildthedocs.btd"
  
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
  
  printf "\n$ANSI_DARKCYAN[BTD - deploy] Get the deploy key $ANSI_NOCOLOR\n"
  # by using Travis's stored variables to decrypt deploy_key.enc
  eval `ssh-agent -s`
  openssl aes-256-cbc -K $encrypted_0198ee37cbd2_key -iv $encrypted_0198ee37cbd2_iv -in ../"$BTD_DEPLOY_KEY" -d | ssh-add -
  
  printf "\n$ANSI_DARKCYAN[BTD - deploy] Push to $BTD_TARGET_BRANCH $ANSI_NOCOLOR\n"
  # Now that we're all set up, we can push.
  git push `echo "$BTD_TARGET_URL" | sed -e 's/https:\/\/github.com\//git@github.com:/g'` $TARGET_BRANCH
}

#---

btd_test() {
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
    "$BTD_SH" build -o "../${p}_test_builds" -v "${!VERSIONS}" $INPUT
  
    cd ..
    rm -rf "$p"
    rm -rf "${p}_test_builds"
  done
  
  exit 0
  
  #git clone https://github.com/buildthedocs/btd btd-full
  #cd btd-full
  
  #BTD_DEPLOY_KEY="travis/deploy_key.enc" "$BTD_SH" build -o '../btd_full_builds' -v "master,featured"
  
  #cd ..
  #rm -rf btd-full
  #rm -rf btd_full_builds
  
  #git clone https://github.com/VLSI-EDA/PoC
  #cd PoC
  #curl -L https://raw.githubusercontent.com/buildthedocs/btd/master/btd.sh | sh -s build -v "release,stable" -i docs
}

#---

case "$1" in
  build)
    shift;
    btd_config "$@"
    btd_build
  ;;
  images)
    shift;
    btd_images
  ;;
  deploy)
    shift;
    btd_config "$@"
    btd_deploy
  ;;
  test)
    shift;
    btd_test "$0"
  ;;
  *)
    echo "[BTD] Unknown command $1"
    exit 1
  ;;
esac
