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

  printf "$ANSI_DARKCYAN[BTD - build $1] Check if requirements.txt exists $ANSI_NOCOLOR\n"
  if [ -f "./requirements.txt" ] || [ -f "./$BTD_INPUT_DIR/requirements.txt" ]; then
    if [ -f "./$BTD_INPUT_DIR/requirements.txt" ]; then
      REQ_PREFIX="";
    else
      REQ_PREFIX="../";
    fi
    INSTALL_REQUIREMENTS="pip install --exists-action=w -r ${REQ_PREFIX}requirements.txt &&";
  fi

  echo "INSTALL_REQUIREMENTS: $INSTALL_REQUIREMENTS"

#  for f in $(echo $BTD_FORMATS | sed 's/,/ /g'`); do
#    echo "$f"
#  done



  if [ "$BTD_FORMAT_HTML" != "" ]; then

  fi

  if [ "$BTD_FORMAT_PDF" != "" ]; then

  fi

  echo "travis_fold:start:sphinx_$1"
  travis_time_start
  printf "$ANSI_DARKCYAN[BTD - build $1] Run Sphinx $ANSI_NOCOLOR\n"
  docker run --rm -tv /$(pwd):/src -v btd-vol://_build "$BTD_IMG_SPHINX" sh -c "\
    cd $BTD_INPUT_DIR && cat context.json && $INSTALL_REQUIREMENTS \
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
    mv -f \$FILE.pdf /_build/${BTD_NAME}_${1}.pdf"
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

#--- Get absolute path of BTD_OUTPUT_DIR

echo "travis_fold:start:abs_output"
printf "$ANSI_DARKCYAN[BTD - build] Get absolute path of BTD_OUTPUT_DIR $ANSI_NOCOLOR\n"
if [ -d "$BTD_OUTPUT_DIR" ]; then rm -rf "$BTD_OUTPUT_DIR"; fi
mkdir -p "$BTD_OUTPUT_DIR"
cd "$BTD_OUTPUT_DIR"
mkdir -p html/pdf
BTD_OUTPUT_DIR="$(pwd)"
cd -
echo "travis_fold:end:abs_output"

#--- Create index.html

#echo "travis_fold:start:list"
#travis_time_start
printf "$ANSI_DARKCYAN[BTD - build] Create index.html $ANSI_NOCOLOR\n"
printf "<html><head><meta http-equiv=\"refresh\" content=\"0; url=`echo "$BTD_VERSION" | cut -d ',' -f1`\"></head><body></body>\n" > "$BTD_OUTPUT_DIR/html/index.html"
#for v in `echo "$BTD_VERSION" | sed 's/,/ /g'`; do
#  printf "<a href=\"$v\">$v</a>\n" >> "index.html"
#done
#printf "</body>\n" >> "index.html"
#mv "index.html" "$BTD_OUTPUT_DIR/html/index.html"
#travis_time_finish
#echo "travis_fold:end:list"

#--- Get clean clone

current_branch="`git rev-parse --abbrev-ref HEAD`"

if [ "$TRAVIS" = "true" ]; then
  printf "$ANSI_DARKCYAN[BTD - build] Get clean clone $ANSI_NOCOLOR\n"
  current_branch="$TRAVIS_BRANCH"
  current_pwd="`pwd`"
  git clone -b "$current_branch" "`git remote get-url origin`" ../tmp-full
  cd ../tmp-full
fi

#--- Create context.json

printf "$ANSI_DARKCYAN[BTD - build] Create context.json $ANSI_NOCOLOR\n"

#- Latest date, commit, build...

split_custom() {
  if [ "$(echo $BTD_LAST_INFO | grep LAST_DATE)" != "" ]; then
    printf "%s\n" \
      "\"custom_last_pre\":\"$(echo $BTD_LAST_INFO | sed 's/\(.*\)LAST_DATE\(.*\)/\1/g')\"" \
      "\"custom_last\":\"$(echo $BTD_LAST_INFO | sed 's/\(.*\)LAST_DATE\(.*\)/\2/g')\"" \
    > context.tmp
  else
    printf "\"custom_last\":\"$BTD_LAST_INFO\"\n" > context.tmp
  fi
}

if [ "$TRAVIS" = "true" ]; then
  BTD_COMMIT="$TRAVIS_COMMIT"
  case $BTD_LAST_INFO in
    "build")
      printf "%s\n" \
        "\"build_id\": \"$TRAVIS_JOB_NUMBER\"" \
        "\"build_url\": \"https://travis-ci.org/$TRAVIS_REPO_SLUG/jobs/$TRAVIS_JOB_ID\"" \
      > context.tmp
    ;;
    "commit")
      printf "\"commit\": \"LAST_COMMIT\"\n" > context.tmp
    ;;
    "date")
    ;;
    *)
      split_custom
      last_build='<a href=\\"https://travis-ci.org/'"$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"'\\">'"$TRAVIS_BUILD_NUMBER"'</a>.<a href=\\"https://travis-ci.org/'"$TRAVIS_REPO_SLUG/jobs/$TRAVIS_JOB_ID"'\\">'"$(echo $TRAVIS_JOB_NUMBER | cut -d"." -f2)"'</a>'
      sed -i 's@LAST_BUILD@'"$last_build"'@g' context.tmp
    ;;
  esac
else
  if [ -d ".git" ] && [ "`command -v git`" != "" ]; then
    BTD_COMMIT="$(git rev-parse --verify HEAD)"
  fi
  case $BTD_LAST_INFO in
    "build")
      printf "%s\n" \
        "\"build_id\": \"BUILD_ID\"" \
        "\"build_url\": \"BUILD_URL\"" \
      > context.tmp
    ;;
    "commit")
      printf "\"commit\": \"LAST_COMMIT\"\n" > context.tmp
    ;;
    "date")
    ;;
    *)
      split_custom
    ;;
  esac
fi

if [ "$BTD_DISPLAY_GH" != "" ]; then
  last_commit='<a href=\\"'"`echo "$BTD_SOURCE_URL" | sed 's/\.git$//g'`/commit/$BTD_COMMIT"'\\">'"`echo "$BTD_COMMIT" | cut -c1-8`</a>"
else
  last_commit="`echo "$BTD_COMMIT" | cut -c1-8`"
fi
sed -i 's@LAST_COMMIT@'"$last_commit"'@g' context.tmp

#- Versions

versions=""
for v in `echo "$BTD_VERSION" | sed 's/,/ /g'`; do
  versions="$versions [\"$v\", \"../$v\"],"
done
printf "%s\n" \
  "\"VERSIONING\": true" \
  "\"current_version\": \"activeVersion\"" \
  "\"versions\": [$versions ]" \
>> context.tmp
sed -i 's/], ]/] ]/g' context.tmp
last_line="\"downloads\": [ [\"PDF\", \"../pdf/${BTD_NAME}_activeVersion.pdf\"], [\"HTML\", \"../tgz/${BTD_NAME}_activeVersion.tgz\"] ]"

#- View/edit on GitHub

if [ "$BTD_DISPLAY_GH" != "" ]; then
  if [ "$last_line" != "" ]; then echo "$last_line" >> context.tmp; fi
  subdir=""; if [ "$BTD_INPUT_DIR" != "" ]; then subdir="/$BTD_INPUT_DIR/"; fi
  printf "%s\n" \
    "\"display_github\": true" \
    "\"github_user\": \"$BTD_GH_USER\"" \
    "\"github_repo\": \"$BTD_GH_REPO\"" \
  >> context.tmp
  last_line="\"github_version\": \"activeVersion$subdir\""
fi

echo "{" > context.json
while read -r line; do
  printf "  %s,\n" "$line" >> context.json
done < context.tmp
printf "  $last_line\n" >> context.json
echo "}" >> context.json

rm context.tmp
mv context.json $BTD_OUTPUT_DIR/context.json

#--- Get themes

printf "$ANSI_DARKCYAN[BTD - build $1] Get theme(s) $ANSI_NOCOLOR\n"
mkdir $BTD_OUTPUT_DIR/themes
if [ "$BTD_SPHINX_THEME" != "none" ]; then
  mkdir -p theme-tmp
  cd theme-tmp
  curl -L "$BTD_SPHINX_THEME" | tar xvz --strip 1
  zip -r "$BTD_OUTPUT_DIR/themes/sphinx_btd_theme.zip" ./*
  cd .. && rm -rf theme-tmp
fi

#--- Run builds(s) for each version

for v in `echo "$BTD_VERSION" | sed 's/,/ /g'`; do
  echo "travis_fold:start:$v"
  travis_time_start
  printf "$ANSI_DARKCYAN[BTD - build] Start $v $ANSI_NOCOLOR\n"
  git checkout $v
  cp -r "$BTD_OUTPUT_DIR/themes/"* "$BTD_INPUT_DIR"
  cp "$BTD_OUTPUT_DIR/context.json" "$BTD_INPUT_DIR"
  sed -i 's/activeVersion/'"$v"'/g' "$BTD_INPUT_DIR/context.json"
  build_version "$v"
  mv "$BTD_OUTPUT_DIR/$v/html" "$BTD_OUTPUT_DIR/html/$v/"
  mv "$BTD_OUTPUT_DIR/$v/${BTD_NAME}_${v}.pdf" "$BTD_OUTPUT_DIR/html/pdf/"
  travis_time_finish
  echo "travis_fold:end:$v"
  printf "$ANSI_DARKCYAN[BTD - build] End $v $ANSI_NOCOLOR\n"
done

#--- Back to original branch

git checkout "$current_branch"

if [ "$TRAVIS" = "true" ]; then
  cd "$current_pwd"
fi

if [ "$CLEAN_BTD" != "./" ]; then
  cd ..
  rm -rf "$CLEAN_BTD"
fi

#<
