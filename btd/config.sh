#>
# Transform long options to short ones
for arg in $@; do
  shift
  case "$arg" in
      "--config"|"-config")    set -- "$@" "-c";;
      "--input"|"-input")      set -- "$@" "-i";;
      "--output"|"-output")    set -- "$@" "-o";;
      "--source"|"-source")    set -- "$@" "-s";;
      "--target"|"-target")    set -- "$@" "-t";;
      "--formats"|"-formats")  set -- "$@" "-f";;
      "--version"|"-version")  set -- "$@" "-v";;
      "--name"|"--name")       set -- "$@" "-n";;
      "--disp_gh"|"--disp_gh") set -- "$@" "-d";;
    *) set -- "$@" "$arg"
  esac
done
# Parse args
while getopts ":c:i:o:s:t:f:v:n:d" opt; do
  case $opt in
    c) BTD_CONFIG_FILE="$OPTARG";;
    i) BTD_INPUT_DIR="$OPTARG";;
    o) BTD_OUTPUT_DIR="$OPTARG";;
    s) BTD_SOURCE_REPO="$OPTARG";;
    t) BTD_TARGET_REPO="$OPTARG";;
    f) BTD_FORMATS="$OPTARG";;
    v) BTD_VERSION="$OPTARG";;
    n) BTD_NAME="$OPTARG";;
    d) BTD_DISPLAY_GH="true";;
    \?) printf "$ANSI_RED[BTD - config] Invalid option: -$OPTARG $ANSI_NOCOLOR\n" >&2
	exit 1 ;;
    :)  printf "$ANSI_RED[BTD - config] Option -$OPTARG requires an argument. $ANSI_NOCOLOR\n" >&2
	exit 1 ;;
  esac
done

if [   "$BTD_CONFIG_FILE" = "" ]; then   BTD_CONFIG_FILE=".btd.yml";       fi
if [     "$BTD_INPUT_DIR" = "" ]; then     BTD_INPUT_DIR="doc";            fi
if [    "$BTD_OUTPUT_DIR" = "" ]; then    BTD_OUTPUT_DIR="../btd_builds";  fi
if [   "$BTD_TARGET_REPO" = "" ]; then   BTD_TARGET_REPO="gh-pages";       fi
if [       "$BTD_FORMATS" = "" ]; then       BTD_FORMATS="html,pdf";       fi
if [          "$BTD_NAME" = "" ]; then          BTD_NAME="BTD";            fi
if [       "$BTD_VERSION" = "" ]; then       BTD_VERSION="master";         fi
if [     "$BTD_LAST_INFO" = "" ]; then     BTD_LAST_INFO="Last updated on LAST_DATE [LAST_COMMIT - LAST_BUILD]"; fi
if [    "$BTD_IMG_SPHINX" = "" ]; then    BTD_IMG_SPHINX="btdi/sphinx:py2-featured"; fi
if [     "$BTD_IMG_LATEX" = "" ]; then     BTD_IMG_LATEX="btdi/latex";     fi
if [  "$BTD_SPHINX_THEME" = "" ]; then  BTD_SPHINX_THEME="https://github.com/buildthedocs/sphinx_btd_theme/archive/btd.tar.gz"; fi
if [    "$BTD_DEPLOY_KEY" = "" ]; then    BTD_DEPLOY_KEY="deploy_key.enc"; fi

CLEAN_BTD=""

if [   "$BTD_SOURCE_REPO" = "" ] || [ "`echo "$BTD_SOURCE_REPO" | grep ":"`" = "" ]; then
  if [   "$BTD_SOURCE_REPO" = "" ]; then BTD_SOURCE_REPO="master"; fi
  if [ -d ".git" ] && [ "`command -v git`" != "" ]; then
    BTD_SOURCE_REPO="$(git config remote.origin.url | sed -r s#git@\(.*\):#http://\\1/#g):$BTD_SOURCE_REPO"
    CLEAN_BTD="./"
  fi
fi

if [ "$(echo $BTD_FORMATS | grep html)" != "" ]; then
  BTD_FORMAT_HTML="true";
fi

if [ "$(echo $BTD_FORMATS | grep pdf)" != "" ]; then
  BTD_FORMAT_PDF="true";
fi

#---

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
  fi
}

#--- Source repository and input dir

PARSED_URL=""
PARSED_DIR=""
PARSED_BRANCH="$BTD_SOURCE_REPO"
parse_branch
BTD_SOURCE_URL="$PARSED_URL"
BTD_SOURCE_BRANCH="$PARSED_BRANCH"
if [ "$PARSED_DIR" != "" ]; then
  BTD_INPUT_DIR="$PARSED_DIR"
fi

if [ "$BTD_SOURCE_URL" = "" ]; then
  CLEAN_BTD="./"
fi

if [ "$CLEAN_BTD" = "" ]; then
  printf "$ANSI_DARKCYAN[BTD - config] Clone -b $BTD_SOURCE_BRANCH $BTD_SOURCE_URL $ANSI_NOCOLOR\n"
  cd ..
  if [ -d "btd-work" ]; then rm -rf "btd-work"; fi
  git clone -b "$BTD_SOURCE_BRANCH" "$BTD_SOURCE_URL" btd-work
  cd btd-work
  CLEAN_BTD="btd-work"
fi

BTD_GH_USER="`echo "$BTD_SOURCE_URL" | cut -d'/' -f4`"
BTD_GH_REPO="`echo "$BTD_SOURCE_URL" | cut -d'/' -f5 | sed 's/\.git//g'`"

#--- Target repository

PARSED_BRANCH="$BTD_TARGET_REPO"
parse_branch
if [ "`echo "$BTD_TARGET_REPO" | grep ":"`" = "" ]; then
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
echo "---"
echo "BTD_GH_USER: $BTD_GH_USER"
echo "BTD_GH_REPO: $BTD_GH_REPO"

#<
