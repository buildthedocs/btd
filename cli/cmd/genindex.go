package cmd

import (
	"fmt"
	"html/template"
	"io"

	au "github.com/logrusorgru/aurora"
)

func genIndex(w io.Writer) {
	fmt.Println(au.Magenta("[generateIndex]"))

	const tpl = `<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0; url={{.Default}}">
    <title>[BuildTheDocs] {{.Title}}</title>
  </head>
  <body>
  </body>
</html>
`

	// TODO Support alternative templates for index.html
	/*
		for v in `echo "$BTD_VERSION" | sed 's/,/ /g'`; do
		  printf "<a href=\"$v\">$v</a>\n" >> "index.html"
		done
	*/

	fmt.Println("Processing template...")
	t, err := template.New("index").Parse(tpl)
	checkErr(err)

	data := struct {
		Title   string
		Default string
	}{
		Title:   "My page",
		Default: "master",
	}

	fmt.Println("Executing template...")
	err = t.Execute(w, data)
	checkErr(err)
}
