- Themes/templates:
  - Extract zip name from tarball URL
  - Add comment about `--strip 1`, i.e., the tarball must have a top dir
  - Accept comma delimited list of URLs to tarballs as BTD_SPHINX_THEME
  - Can the tarball/zip file be replaced with a git clone? Guess the correct combination for `html_theme`,
  `html_theme_path` and `templates_path`.
    - https://sphinx-rtd-theme.readthedocs.io/en/latest/#via-git-or-download

- How to customize the builder/build process

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
