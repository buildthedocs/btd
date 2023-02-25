#>
# Transform long options to short ones
for arg in $@; do
  shift
  case "$arg" in
      "--config"|"-config")   set -- "$@" "-c";;
      "--input"|"-input")     set -- "$@" "-i";;
      "--output"|"-output")   set -- "$@" "-o";;
      "--source"|"-source")   set -- "$@" "-s";;
      "--target"|"-target")   set -- "$@" "-t";;
      "--version"|"-version") set -- "$@" "-v";;
    *) set -- "$@" "$arg"
  esac
done
# Parse args
while getopts ":c:i:o:s:t:v:" opt; do
  case $opt in
    c) BTD_CONFIG_FILE=$OPTARG;;
    i) BTD_INPUT_DIR=$OPTARG;;
    o) BTD_OUTPUT_DIR=$OPTARG;;
    s) BTD_SOURCE_BRANCH=$OPTARG;;
    t) BTD_TARGET_BRANCH=$OPTARG;;
    v) BTD_VERSION="$OPTARG";;
    \?) printf "$ANSI_RED[BTD - config] Invalid option: -$OPTARG $ANSI_NOCOLOR\n" >&2
	exit 1 ;;
    :)  printf "$ANSI_RED[BTD - config] Option -$OPTARG requires an argument. $ANSI_NOCOLOR\n" >&2
	exit 1 ;;
  esac
done

if [   "$BTD_CONFIG_FILE" = "" ]; then   BTD_CONFIG_FILE=".btd.yml";      fi
if [     "$BTD_INPUT_DIR" = "" ]; then     BTD_INPUT_DIR="doc";           fi
if [    "$BTD_OUTPUT_DIR" = "" ]; then    BTD_OUTPUT_DIR="../btd_builds"; fi
if [ "$BTD_SOURCE_BRANCH" = "" ]; then BTD_SOURCE_BRANCH="master";        fi
if [ "$BTD_TARGET_BRANCH" = "" ]; then BTD_TARGET_BRANCH="gh-pages";      fi
if [       "$BTD_VERSION" = "" ]; then       BTD_VERSION="master";        fi
if [    "$BTD_IMG_SPHINX" = "" ]; then    BTD_IMG_SPHINX="btdi/sphinx";   fi
if [     "$BTD_IMG_LATEX" = "" ]; then     BTD_IMG_LATEX="btdi/latex";    fi

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
#<
