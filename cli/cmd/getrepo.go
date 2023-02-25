package cmd

import (
	"fmt"
	"os"
	"path"
	"strings"

	au "github.com/logrusorgru/aurora"
	v "github.com/spf13/viper"
	git "gopkg.in/src-d/go-git.v4"
	"gopkg.in/src-d/go-git.v4/plumbing"
)

func getRoot(r *git.Repository) string {
	w, err := r.Worktree()
	checkErr(err)
	return w.Filesystem.Root()
}

func checkBranches(r *git.Repository) {
	// TODO Check if all the branches/tags corresponding to the requested versions are available in the repo. Else, checkout them.
	fmt.Println(au.Brown("TODO"), "Check branches/tags (versions) in", r)
	fmt.Println(fmt.Sprintf("Using repo at <%s> as root", getRoot(r)))
}

func gitClone(u, p string) *git.Repository {
	fmt.Println("gitClone", u)
	r, err := git.PlainClone(p, false, &git.CloneOptions{URL: u, Progress: os.Stdout})
	checkErr(err)
	return r
}

func getBranches(r *git.Repository) map[string]string {
	brs, err := r.Branches()
	checkErr(err)
	b := make(map[string]string)
	brs.ForEach(func(ref *plumbing.Reference) error {
		if ref.Type() == plumbing.HashReference {
			t := ref.Strings()
			b[t[0][11:]] = t[1]
		}
		return nil
	})
	return b
}

func (r *ref) getRepo() *git.Repository {
	fmt.Println(au.Magenta("[getRepo]"))

	/*
		   |                                    |  protocol |    domain |    repo | branch | subdirs |
		   |------------------------------------|-----------|-----------|---------|--------|---------|
		   |                            <empty> |   <empty> |   <empty> | <empty> | master | <empty> | *1
		   |                        develop/d/s |   <empty> |   <empty> | <empty> |      d |       s | *1
		   |                   u/r\|develop/d/s |   <empty> |   <empty> |     u/r |      d |       s | *2
		   |         localhost/u/r\|develop/d/s |   <empty> | localhost |     u/r |      d |       s | *3
		   | https://localhost/u/r\|develop/d/s |   http(s) | localhost |     u/r |      d |       s | *3
		   |     git@localhost:u/r\|develop/d/s | git [ssh] | localhost |     u/r |      d |       s | *3
		   |   file:///src/btd_prj\|develop/d/s |      file | localhost |     u/r |      d |       s | *4

		   - Try PlainOpenWithOptions:
			 - If repo not found, error. Cannot proceed.
			   - If *2, add 'github.com' as a domain and proceed as if *3.
			   - If *3, generate clone url, clone to tmp and proceed as if found.
			   - If *4, process as if *3.
			 - If repo found:
			   - If <!no-local>, check if required branches/tags are available locally:
				 - If all branches/tags available, ok. Proceed.
				 - If not all available, proceed as if <no-local>
			   - If <no-local>, check if any remote is set:
				 - If no remote available, error. Cannot proceed.
				 - I remote(s) available, check sequentially (starting with <origin>):
				   - Do required branches/tags exists in the remote(s)?
					 - If not all exists, error. Cannot proceed.
					 - If exist:
					   - If <*1 && !clone> or *2 or *3, checkout each of them. Proceed.
					   - If <*1 clone>, clone from file://:
						 - If <no-local>:
						   - If not all branches/tags where available in some remote, error. Cannot proceed.
						 - If <!no-local>:
						   - If branches/tags where available locally, checkout them.
						   - If branches/tags where available in some remote, add the remote and checkout them.

		   NOTES:
			 - Create map[string]string to describe the checked out branch name for each version.
			 - Track is a temporal repo was cloned. Remove in cleanup stage.
			 - Track if some new branch/tag was created. Remove in cleanup stage.
			 - In *1 and *4, must check if some remote is set, which can be used to extract the <repo> slug. This is required for the optional feature that links back to the repo.
			   - If multiple remotes are set, use <origin> first. If <origin> does not exist, use the first one that matches (i.e., which is not of type <file://>).
	*/

	tmp_repo := path.Join(v.GetString("tmp"), "btd_tmp")
	url := ""

	repo, err := git.PlainOpenWithOptions("./", &git.PlainOpenOptions{DetectDotGit: true})
	if err != nil {
		if err != git.ErrRepositoryNotExists {
			checkErr(err)
		} else {
			if r.repo == "" {
				checkErr(fmt.Errorf("Source <repo> is empty and no <.git> was found in the execution path or its parents."))
			}
			domain := r.domain
			if domain == "" {
				domain = "github.com"
			}
			if r.protocol == "file" {
				url = "file://" + domain
			} else {
				url = "https://" + domain + "/" + r.repo
			}
			rmDir(tmp_repo)
			repo = gitClone(url, tmp_repo)
		}
	}

	verRefs := initVerRefs()

	if v.GetBool("no-local") {
		remotes, err := repo.Remotes()
		checkErr(err)
		if len(remotes) == 0 {
			checkErr(fmt.Errorf("Option <no-local> requires a remote, at least."))
		}
		for _, r := range remotes {
			rmt := strings.Split(strings.Split(r.String(), "\n")[0], "\t")
			//name := rmt[0]
			remote := parseRepo(strings.Split(rmt[1], " ")[0])
			remote.Print()
			/*
				err = r.Fetch(&git.FetchOptions{Tags: git.AllTags})
				if (err != nil) && (err != git.NoErrAlreadyUpToDate) {
					checkErr(err)
				}
			*/
		}

		/*
			   - If <no-local>, check if any remote is set:
				 - If no remote available, error. Cannot proceed.
				 - I remote(s) available, check sequentially (starting with <origin>):
				   - Do required branches/tags exists in the remote(s)?
					 - If not all exists, error. Cannot proceed.
					 - If exist:
					   - If <*1 && !clone> or *2 or *3, checkout each of them. Proceed.
					   - If <*1 clone>, clone from file://:
						 - If <no-local>:
						   - If not all branches/tags where available in some remote, error. Cannot proceed.
						 - If <!no-local>:
						   - If branches/tags where available locally, checkout them.
						   - If branches/tags where available in some remote, add the remote and checkout them.
		*/
	} else {
		/*
			refs, err := repo.References()
			checkErr(err)
			refs.ForEach(func(ref *plumbing.Reference) error {
				if ref.Type() == plumbing.HashReference {
					fmt.Println(ref)
				}
				return nil
			})
		*/
		branches := getBranches(repo)

		allDone := true
		for n, r := range verRefs {
			b, ok := branches[n]
			if ok {
				(*r).Name = n
				(*r).Hash = b
			} else {
				allDone = false
			}
		}

		if !allDone {
			fmt.Println(au.Brown("TODO"), "Check local Tags after Branches.")
			//tags := getTags(repo)
		}

		/*
			fmt.Println("TAGS")
			refs, err = repo.Tags()
			checkErr(err)
			refs.ForEach(func(ref *plumbing.Reference) error {
				if ref.Type() == plumbing.HashReference {
					fmt.Println(ref)
				}
				return nil
			})
		*/
		/*
			   - If <!no-local>, check if required branches/tags are available locally:
				 - If all branches/tags available, ok. Proceed.
				 - If not all available, proceed as if <no-local>
		*/

	}

	os.Exit(0)

	return repo

	//---
	/*
		if r.repo == "" {
			repo, err := git.PlainOpenWithOptions("./", &git.PlainOpenOptions{DetectDotGit: true})
			if err != nil {
				if err != git.ErrRepositoryNotExists {
					checkErr(err)
				} else {
					checkErr(fmt.Errorf("Source <repo> is empty and no <.git> was found in the execution path or its parents."))
				}
			}
			if !v.GetBool("clone") {
				checkBranches(repo)
				return repo
			}
			p, err := filepath.Abs("./")
			checkErr(err)
			r.protocol = "file"
			r.domain = p
		}
	*/
	/*
		if r.domain == "" {
			checkErr(fmt.Errorf("Cannot clone repository from empty domain!"))
		}

			checkBranches(repo)
			return repo
	*/
	/*
	 BTD_SOURCE_REPO="$(git config remote.origin.url | sed -r s#git@\(.*\):#http://\\1/#g):$BTD_SOURCE_REPO"
	 CLEAN_BTD="./"
	*/

	/*
	   #--- Get clean clone
	   current_branch="`git rev-parse --abbrev-ref HEAD`"
	   if [ "$TRAVIS" = "true" ]; then
	     current_branch="$TRAVIS_BRANCH"
	     current_pwd="`pwd`"
	     git clone --recursive -b "$current_branch" "`git remote get-url origin`" ../tmp-full
	     cd ../tmp-full
	   fi
	*/

}
