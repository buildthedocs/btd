package cmd

import (
	"fmt"
	"os"
	"path"
	"path/filepath"
	"strings"

	au "github.com/logrusorgru/aurora"
	v "github.com/spf13/viper"
)

func getThemes(o string) {
	fmt.Println(au.Magenta("[getThemes]"))

	// TODO Extract zip file name from version argument

	// TODO Allow to define the theme with different formats: git repo, tarball, zip file

	// TODO Support hugo themes too

	themes := strings.Split(v.GetString("themes"), ",")
	for _, t := range themes {
		fmt.Println("Get", t)
		p := path.Join(v.GetString("tmp"), "btd_theme")
		checkErr(os.MkdirAll(filepath.Join(p), 0766))

		fmt.Println("Downloading tar...")
		execShCmd(fmt.Sprintf("curl -L %s | tar xvz --strip 1 -C %s", t, p))

		fmt.Println("Generating zip...")
		execShCmd(fmt.Sprintf("zip -r %s %s", path.Join(o, "sphinx_btd_theme.zip"), path.Join(p, "*")))
		checkErr(os.RemoveAll(p))
	}
}
