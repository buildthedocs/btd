package cmd

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"path"
	"strings"

	au "github.com/logrusorgru/aurora"
	homedir "github.com/mitchellh/go-homedir"
	"github.com/spf13/cobra"
	v "github.com/spf13/viper"
	git "gopkg.in/src-d/go-git.v4"
	"gopkg.in/src-d/go-git.v4/plumbing"
)

var cfgFile string

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:     "buildthedocs",
	Version: "", //fb.Version,
	//	Aliases: []string{"serve"},
	Short: "",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		src, err := parseRef(v.GetString("source"))
		checkErr(err)
		src.Print()

		vs := src.branch
		if t := v.GetString("versions"); t != "" {
			vs = vs + "," + t
		}
		v.Set("versions", vs)

		fmt.Println(au.Magenta("[List of versions]"))
		versions := strings.Split(vs, ",")
		fmt.Println("-", versions[0], "[default]")
		if len(versions) > 1 {
			for _, t := range versions[1:] {
				fmt.Println("-", t)
			}
		}

		repo := src.getRepo()

		trg, err := parseRef(v.GetString("target"))
		checkErr(err)
		trg.Print()

		odir := createOutputDir(v.GetString("output"))

		f, err := os.Create(path.Join(odir, "html", "index.html"))
		checkErr(err)
		defer f.Close()
		w := bufio.NewWriter(f)
		genIndex(w)
		w.Flush()

		ctx := make(context, 0)
		ctx.generate()

		getThemes(path.Join(odir, "themes"))

		buildDir := getRoot(repo)
		for _, s := range src.subdirs {
			buildDir = path.Join(buildDir, s)
		}

		wrk, err := repo.Worktree()
		checkErr(err)

		// TODO Use golang to copy themes
		execShCmd(fmt.Sprintf("cp %s/themes/* %s", odir, buildDir))

		for _, k := range versions {
			fmt.Println(au.Magenta("[Build]"), k)
			checkoutOpts := &git.CheckoutOptions{Branch: plumbing.ReferenceName(k), Create: false, Force: false}

			fmt.Println(fmt.Sprintf("Checkout version <%s>...", k))
			// Try to checkout branch
			err = wrk.Checkout(checkoutOpts)
			if err != nil {
				// got an error  - try to create it
				checkoutOpts.Create = true
				checkErr(wrk.Checkout(checkoutOpts))
			}

			ctx["current_version"] = k

			n := v.GetString("name")
			ctx["downloads"] = [][2]string{
				[2]string{"PDF", fmt.Sprintf("../pdf/%s_%s.pdf", n, k)},
				[2]string{"HTML", fmt.Sprintf("../tgz/%s_%s.tgz", n, k)},
			}

			/*
				       BTD_COMMIT="$(git rev-parse --verify HEAD)"
				       sed -i 's/BTD_COMMIT_PLACEHOLDER/'"$BTD_COMMIT"'/g' "$BTD_INPUT_DIR/context.json"
							 sed -i 's/BTD_COMMIT_SHORT_PLACEHOLDER/'`echo "$BTD_COMMIT" | cut -c1-8`'/g' "$BTD_INPUT_DIR/context.json"
			*/

			// TODO Save contex.json files used for each version to odir, just in case the user wants to check them, or rebuild a single version with sphinx.

			ctx.WriteFile(path.Join(buildDir, "context.json"))

			/*
						build_version "$v"
				log.Println(v.GetBool("display"))
			*/
			formats := strings.Split(v.GetString("formats"), ",")
			for _, f := range formats {
				switch f {
				case "html":
					log.Println(k, f)
					// sphinx
					// Check if requirements.txt exists
					req := path.Join(buildDir, "requirements.txt")
					_, err = os.Stat(req)
					if err != nil {
						req = ""
					}

					// INSTALL_REQUIREMENTS="pip install --exists-action=w -r ${REQ_PREFIX}requirements.txt &&";

					/*
						docker run --rm -tv /$(pwd):/src -v btd-vol://_build "$BTD_IMG_SPHINX" sh -c "\
						     cd $BTD_INPUT_DIR && cat context.json && $INSTALL_REQUIREMENTS \
						     sphinx-build -T -b html -D language=en . /_build/html && \
						     sphinx-build -T -b json -d /_build/doctrees-json -D language=en . /_build/json && \
						     sphinx-build -b latex -D language=en -d _build/doctrees . /_build/latex"
					*/
				case "pdf":
					log.Println(k, f)
					// latex
					/*
					   docker run --rm -tv /$(pwd):/src -v btd-vol://_build "$BTD_IMG_LATEX" sh -c "\
					     cd $BTD_INPUT_DIR && \
					     cd /_build/latex && \
					     FILE=\"\`ls *.tex | sed -e 's/\.tex//'\`\" && \
					     pdflatex -interaction=nonstopmode \$FILE.tex; \
					     makeindex -s python.ist \$FILE.idx; \
					     pdflatex -interaction=nonstopmode \$FILE.tex; \
					     mv -f \$FILE.pdf /_build/${BTD_NAME}_${1}.pdf"
					*/
				case "man":
					log.Println(k, f)
				default:
					fmt.Println(fmt.Sprintf("Unknown format <%s>", f))
				}
			}

			/*
				   btd_build() {

				     build_version() {
							 if container btd-box exists, remove it
							 if volume btd-vol exists, remove it

				       printf "$ANSI_DARKCYAN[BTD - build $1] Create volume btd-vol $ANSI_NOCOLOR\n"
				       docker volume create btd-vol

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


			*/

			/*
				       mv "$BTD_OUTPUT_DIR/$v/${BTD_NAME}_${v}.pdf" "$BTD_OUTPUT_DIR/html/pdf/"
				       mv "$BTD_OUTPUT_DIR/$v" "$BTD_OUTPUT_DIR/${BTD_NAME}_$v"
				       tar cvzf "$BTD_OUTPUT_DIR/html/tgz/${BTD_NAME}_${v}".tgz -C "$BTD_OUTPUT_DIR" "${BTD_NAME}_$v"
							 mv "$BTD_OUTPUT_DIR/${BTD_NAME}_$v/html" "$BTD_OUTPUT_DIR/html/$v/"
			*/
		}

		/*

			     #--- Back to original branch

			     git checkout "$current_branch"

			     if [ "$TRAVIS" = "true" ]; then
			       cd "$current_pwd"
			     fi

			     if [ "$CLEAN_BTD" != "./" ]; then
			       cd ..
			       rm -rf "$CLEAN_BTD"
			     fi

			err = os.RemoveAll(tmp_repo)
			checkErr(err)
		*/

	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	fmt.Println(au.Cyan("[Build The Docs]"))
	//checkRootAlias()
	if err := rootCmd.Execute(); err != nil {
		panic(err)
	}
}

func init() {
	cobra.OnInitialize(initConfig)
	//	rootCmd.SetVersionTemplate("File Browser {{printf \"version %s\" .Version}}\n")

	f := rootCmd.PersistentFlags()

	f.StringVarP(&cfgFile, "config", "c", "", "config file (defaults are './.btd[ext]', '$HOME/.btd[ext]' or '/etc/btd/.btd[ext]')")

	flag := func(k string, i interface{}, u string) {
		switch y := i.(type) {
		case bool:
			f.Bool(k, y, u)
		case int:
			f.Int(k, y, u)
		case string:
			f.String(k, y, u)
		}
		v.SetDefault(k, i)
	}

	flagP := func(k, p string, i interface{}, u string) {
		switch y := i.(type) {
		case bool:
			f.BoolP(k, p, y, u)
		case int:
			f.IntP(k, p, y, u)
		case string:
			f.StringP(k, p, y, u)
		}
		v.SetDefault(k, i)
	}

	// Global settings
	flagP("output", "o", "../btd_builds", "relative/absolute output directory/tarball, must be located out of repo")
	flagP("source", "s", "master/doc", "source repository, branch and subdirs")
	flagP("target", "t", "gh-pages", "target repository and branch")
	flagP("formats", "f", "html,pdf,man", "comma delimited list of output formats")
	flagP("name", "n", "BTD", "base name for artifacts")
	flagP("versions", "v", "", "comma delimited list of additional versions")
	flagP("display", "d", false, "display 'Edit on...' instead of 'View page source'")
	flagP("last", "l", "Last updated on LAST_DATE [LAST_COMMIT - LAST_BUILD]", "last updated info format")
	flag("themes", "https://github.com/buildthedocs/sphinx_btd_theme/archive/btd.tar.gz", "comma delimited list of sphinx/hugo themes")
	flag("img.sphinx", "btdi/sphinx:py2-featured", "docker image for Sphinx runs")
	flag("img.latex", "btdi/latex", "docker image for LaTeX runs")
	flag("org", false, "ref to 'travis-ci.org' instead of 'travis-ci.com'")
	flag("tmp", "/tmp", "dir to use for temporal content")
	flag("clone", true, "clone source repository to temporal dir in tmp")
	flag("no-local", false, "ignore locally checked out branches/tags")

	//-c, -i, -o and -key are relative to the root of -s.

	// Bind the full flag set to the configuration
	if err := v.BindPFlags(f); err != nil {
		panic(err)
	}

}

// initConfig reads in config file and ENV variables if set.
func initConfig() {
	if cfgFile == "" {
		// Find home directory.
		home, err := homedir.Dir()
		if err != nil {
			panic(err)
		}
		v.AddConfigPath(".")
		v.AddConfigPath(home)
		v.AddConfigPath("/etc/btd/")
		v.SetConfigName(".btd")
	} else {
		// Use config file from the flag.
		v.SetConfigFile(cfgFile)
	}

	v.SetEnvPrefix("BTD")
	v.AutomaticEnv()
	v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	if err := v.ReadInConfig(); err != nil {
		if _, ok := err.(v.ConfigParseError); ok {
			panic(err)
		}
	} else {
		log.Println("Using config file:", v.ConfigFileUsed())
	}
}

/*
btd_config() {

  if [   "$BTD_SOURCE_REPO" = "" ] || [ "`echo "$BTD_SOURCE_REPO" | grep ":"`" = "" ]; then
    if [   "$BTD_SOURCE_REPO" = "" ]; then BTD_SOURCE_REPO="master"; fi
    if [ -d ".git" ] && [ "`command -v git`" != "" ]; then
      BTD_SOURCE_REPO="$(git config remote.origin.url | sed -r s#git@\(.*\):#http://\\1/#g):$BTD_SOURCE_REPO"
      CLEAN_BTD="./"
    fi
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
  echo "---"
  echo "BTD_TRAVIS: $BTD_TRAVIS"

}
*/

/*
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
*/
