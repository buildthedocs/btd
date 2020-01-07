- [About](#about-buildthedocs-btd)
- [Install](#install)
- [Use](#use)
- [Development](#development)
- [Similar projects](#similar-projects)

---

NOTE! This is not an actively supported project. It is a documented and slightly cleaned up version of
scripts that were written to move some projects from RTD.org to Travis and GitHub Pages.

# About buildthedocs (BTD)

This is a proof-of-concept to provide a 'lightweight' multi-version documentation generator for users that:

- Rely on a git host service to handle users and access permissions.
- Need to generate/build documentation in different formats (HTML, PDF, EPUB...) and for multiple versions of a project, using [Sphinx](http://www.sphinx-doc.org) and/or [Hugo](https://gohugo.io/) as the backend.
- Want to generate/build the documentation either locally or in a CI environment, without modifying any source between both platforms.
- Want to be able to generate/build the documentation in a machine and have the products optionally deployed to a hosting service automatically.

The most expected use case is:

- Project hosted on [GitHub](https://github.com).
- Web site hosted on [GitHub Pages](https://pages.github.com/).
- A GitHub Actions workflow to build the site after each push.

Possible schemes:

- Save doc sources in:
  - A subdir of master/development branches.
  - The root of a given branch.
- Deploy to, either the same or a different repository:
  - Branch `master`.
  - Branch `gh-pages`.
  - Subdir docs in branch `master`.

# Install

This project comprises:

- A bunch of shell scripts, optionally packed in a single file.
- (optional) A configuration file (`.btd.yml`). [WIP]

Therefore, you need to get the sources using any of the options shown at [Installation](https://buildthedocs.github.io/master/installation.html). Shall you want to automatically deploy the build site to GitHub Pages or any other hosting service, you need to properly configure access permissions for the CI tool (see [Site deployment](doc/site_deployment.md)).

# Use

- (optional) Add the example `.btd.yml` file to your project and edit it to fit your use case. [WIP]
- Run `btd.sh build`. See options below.
- After a successful build, run `btd.sh deploy` to push changes to the hosting service.

Options for the build can be defined in the following ways (from lower to higher precedence):

- Defaults.
- Configuration file. [WIP]
- Environment variables.
- Command line arguments.

List of options:

| envvar | cli | default | |
|---|---|---|---|
| BTD_CONFIG_FILE | `-c` | `./.btd.yml` | WIP |
| BTD_INPUT_DIR | `-i` | `doc/` | |
| BTD_OUTPUT_DIR | `-o` | `../btd_builds/` | |
| BTD_SOURCE_REPO | `-s` | `master` | |
| BTD_TARGET_REPO | `-t` |  `gh-pages` | |
| BTD_FORMATS | `-f` | `html,pdf` | WIP comma delimited list of output formats |
| BTD_NAME | `-n` | `BTD` | base name for artifacts (PDFs, tarballs...) |
| BTD_VERSION | `-v` | `master` | comma delimited list of versions |
| BTD_DISPLAY_GH | `-d` | | Display `Edit on GitHub` instead of `View page source` |
| BTD_LAST_INFO | - | `Last updated on LAST_DATE [LAST_COMMIT - LAST_BUILD]` | Last updated info format |
| BTD_IMG_SPHINX | - | `btdi/sphinx:py2-featured` | |
| BTD_IMG_LATEX | - | `btdi/latex` | |
| BTD_SPHINX_THEME | - | `https://github.com/buildthedocs/sphinx.theme/archive/btd.tar.gz` | |

---

- `-c`, `-i`, and `-o` are relative to the root of `-s`.
- `-i` must lie inside the repository.
- `-o` can be absolute, and it is recommended to be set out of the repository, e.g. `../btd_builds`.

NOTE: the `conf.py` file of the Sphinx project might require some minor modifications. See further info about it, `BTD_SOURCE_REPO`, `BTD_TARGET_REPO`, `BTD_SPHINX_THEME`, `BTD_DISPLAY_GH` and `BTD_LAST_INFO` at [Usage](https://buildthedocs.github.io/master/usage.html).
