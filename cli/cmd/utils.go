package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	au "github.com/logrusorgru/aurora"
)

func checkErr(err error) {
	if err != nil {
		fmt.Println(au.Red(err))
		os.Exit(1)
	}
}

func rmDir(p string) {
	_, err := os.Stat(p)
	if err == nil {
		fmt.Println(fmt.Sprintf("Remove existing dir <%s>", p))
		err = os.RemoveAll(p)
		checkErr(err)
	}
}

func execShCmd(args string) {
	cmd := exec.Command("sh", "-c", args)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	checkErr(cmd.Run())
}

// TODO Add utility functions to print travis folds and timing

func createOutputDir(d string) string {
	fmt.Println(au.Magenta("[createOutputDir]"), d)

	// If output dir exists, remove it
	_, err := os.Stat(d)
	if err == nil {
		fmt.Println(fmt.Sprintf("Remove existing dir <%s>", d))
		err = os.RemoveAll(d)
		checkErr(err)
	}

	// Create output dir and subdirs
	for _, p := range []string{filepath.Join(d, "html", "pdf"), filepath.Join(d, "html", "tgz"), filepath.Join(d, "themes")} {
		checkErr(os.MkdirAll(p, 0766))
	}

	// Get absolute path of output dir
	abs, err := filepath.Abs(d)
	checkErr(err)

	fmt.Println("Absolute path:", abs)

	return abs
}
