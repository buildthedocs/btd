package cmd

import (
	"errors"
	"fmt"
	"strings"

	au "github.com/logrusorgru/aurora"
	v "github.com/spf13/viper"
)

type ref struct {
	protocol string
	domain   string
	repo     string
	branch   string
	subdirs  []string
}

func (r *ref) Print() {
	fmt.Println("  - protocol:", r.protocol)
	fmt.Println("  - domain:", r.domain)
	fmt.Println("  - repo:", r.repo)
	fmt.Println("  - branch:", r.branch)
	fmt.Println("  - subdirs:", r.subdirs)
}

//  [[https://<domain>/]<user>/<repo>|]  <branch>[/subdir[/subsubdir[...]]]
//      [[git@<domain>:]<user>/<repo>|]
//                     [file://<path>|]

func parseRef(s string) (*ref, error) {
	fmt.Println(fmt.Sprintf("%s %s", au.Magenta("[parseRef]"), s))

	r := &ref{}

	if len(s) == 0 {
		s = "master"
	}

	var x string
	t := strings.Split(s, "|")
	switch len(t) {
	case 1:
		x = t[0]
	case 2:
		x = t[1]
		r = parseRepo(t[0])
	default:
		return nil, errors.New("Invalid reference format")
	}

	t = strings.Split(x, "/")
	r.branch = t[0]
	r.subdirs = t[1:]

	return r, nil
}

func parseRepo(s string) *ref {
	r := &ref{}

	switch s[0:4] {
	case "git@":
		r.protocol = "git"
		g := strings.Split(s, ":")
		r.domain = g[0][4:]
		r.repo = g[1]
	case "http":
		h := strings.Split(s, "://")
		r.protocol = h[0]
		h = strings.Split(h[1], "/")
		r.domain = h[0]
		r.repo = strings.Join(h[1:], "/")
	case "file":
		f := strings.Split(s, "://")
		r.protocol = f[0]
		r.domain = f[1]
	default:
		d := strings.Split(s, "/")
		switch len(d) {
		case 2:
			r.repo = s
		case 3:
			r.domain = d[0]
			r.repo = strings.Join(d[1:], "/")
		default:
			checkErr(fmt.Errorf("Invalid reference format"))
		}
	}

	return r
}

type versionRef struct {
	Hash   string
	Remote string
	Name   string
	IsTag  bool
}

func initVerRefs() map[string]*versionRef {
	verRefs := make(map[string]*versionRef)
	for _, x := range strings.Split(v.GetString("versions"), ",") {
		verRefs[x] = &versionRef{}
	}
	return verRefs
}
