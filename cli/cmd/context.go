package cmd

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path"
	"strings"

	au "github.com/logrusorgru/aurora"
	v "github.com/spf13/viper"
)

type context map[string]interface{}

func (c *context) WriteFile(p string) {
	ctxJSON, err := json.Marshal(c)
	checkErr(err)
	checkErr(ioutil.WriteFile(p, ctxJSON, 0644))
}

func (c *context) generate() {
	fmt.Println(au.Magenta("[generateContext]"))

	/*
		   {
		     "custom_last_pre":"Last updated on ",
				 "custom_last":" [<a href=\"http://github.com/buildthedocs/btd/commit/f504da3f582c1758128a2c1f0bd4cac82023ba72\">f504da3f</a> - LAST_BUILD]",

		     "VERSIONING": true,
		     "current_version": "demo",
		     "versions": [ ["master", "../master"], ["demo", "../demo"] ],
				 "downloads": [ ["PDF", "../pdf/BTD_demo.pdf"], ["HTML", "../tgz/BTD_demo.tgz"] ],

		     "display_github": true,
		     "github_user": "buildthedocs",
		     "github_repo": "btd",
		     "github_version": "demo/doc/"
		   }
	*/

	/*
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
	*/

	//	last := strings.Split(v.GetString("last"), "LAST_DATE")

	travis := os.Getenv("TRAVIS")
	fmt.Println("TRAVIS:", travis)
	if travis == "true" {
		/*
			case $BTD_LAST_INFO in
				"build")
					printf "%s\n" \
						"\"build_id\": \"$TRAVIS_JOB_NUMBER\"" \
						"\"build_url\": \"https://travis-ci.${BTD_TRAVIS}/${TRAVIS_REPO_SLUG}/jobs/${TRAVIS_JOB_ID}\"" \
					> context.tmp
				;;
				"commit")
					printf "\"commit\": \"LAST_COMMIT\"\n" > context.tmp
				;;
				"date")
				;;
				*)
					split_custom
					last_build='<a href=\\"https://travis-ci.'"${BTD_TRAVIS}/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}"'\\">'"${TRAVIS_BUILD_NUMBER}"'</a>.<a href=\\"https://travis-ci.'"${BTD_TRAVIS}/${TRAVIS_REPO_SLUG}/jobs/${TRAVIS_JOB_ID}"'\\">'"$(echo $TRAVIS_JOB_NUMBER | cut -d"." -f2)"'</a>'
					sed -i 's@LAST_BUILD@'"$last_build"'@g' context.tmp
				;;
			esac
		*/
	} else {
		/*
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
		*/
	}

	/*
		if [ "$BTD_DISPLAY_GH" != "" ]; then
			last_commit='<a href=\\"'"`echo "$BTD_SOURCE_URL" | sed 's/\.git$//g'`/commit/BTD_COMMIT_PLACEHOLDER"'\\">BTD_COMMIT_SHORT_PLACEHOLDER</a>'
		else
			last_commit="BTD_COMMIT_SHORT_PLACEHOLDER"
		fi
		sed -i 's@LAST_COMMIT@'"$last_commit"'@g' context.tmp
	*/

	versions := strings.Split(v.GetString("versions"), ",")
	if len(versions) > 1 {
		vs := make([][2]string, 0)
		for _, v := range versions {
			vs = append(vs, [2]string{v, path.Join("..", v)})
		}
		(*c)["versions"] = vs
		(*c)["VERSIONING"] = "true"
	}

	/*
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
	*/
}
