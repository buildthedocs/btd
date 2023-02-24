- Themes/templates:
  - Make the versions menu point to the same page, not to the root of the version.
    - `{{ conf_py_path }}{{ pagename }}{{ suffix }}`
  - On branch `btd` re-enable click function in versions menu, in order to show/hide the other-versions block.
  - Replace `select class="versions"` with a better dropdown menu based on `ul` and `li`.
  - Extract zip name from tarball URL
  - Add comment about `--strip 1`, i.e., the tarball must have a top dir
  - Accept comma delimited list of URLs to tarballs as BTD_SPHINX_THEME
  - Can the tarball/zip file be replaced with a git clone? Guess the correct combination for `html_theme`,
  `html_theme_path` and `templates_path`.
    - https://sphinx-rtd-theme.readthedocs.io/en/latest/#via-git-or-download
- Add html tarball. The download link is broken now.
- Generate `context.json` dynamically:
  - Make the commit SHA point to the latest change of each page, not the commit that triggered the build.
- Provide both "Edit on GitHub" and "View on GitHub".
  - https://github.com/rtfd/sphinx_rtd_theme/issues/463
  - https://github.com/rtfd/readthedocs.org/issues/1661
  - Link to issues (fa-exclamation-circle)
- https://www.mathjax.org/cdn-shutting-down/
- How to customize the builder/build process
- Support to build/update a single version, instead of building all the versions every time. To allow so, subdirs corresponding
to other versions should be kept in the target repo.
- Improve detection of changes. Since last build info is provided in the footer, a new commit will be always pushed, even
if sources did not change. Changes to sources should be considered only.

---

- [Control Flow (build process)](#control-flow-build-process)

# Control Flow (build process)

- parse configuration file [WIP]
  - generate versions list and check status
- for each version
  - build html
  - (conditionally) build latex
  - move artifacts to output subdir
- (optional) add landing page
- push products to hosting service

---

`texlive-fonts-extra texlive-latex-extra-doc texlive-publishers-doc texlive-pictures-doc texlive-lang-english texlive-lang-japanese`

```
vim software-properties-common \
libpq-dev libxml2-dev libxslt-dev \
libxslt1-dev build-essential  \
doxygen g++ graphviz-dev libfreetype6 libbz2-dev libcairo2-dev \
libenchant1c2a libevent-dev libffi-dev libfreetype6-dev \
libgraphviz-dev libjpeg62-turbo-dev liblcms2-dev libreadline-dev \
libsqlite3-dev libtiff5-dev libwebp-dev pandoc pkg-config zlib1g-dev \
```
