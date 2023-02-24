- [About](#about-buildthedocs-btd)
- [Install](#install)
- [Use](#use)
- [Development](#development)
- [Similar projects](#similar-projects)

---

NOTE! This is not an actively supported project. It is a documented and slightly cleaned up version of
scripts that were written to move some projects from RTD.org to Travis and GitHub Pages. Since the project is quite
small (<500 lines), best effort support is given to users willing to contribute bug fixes, enhancements and/or
documentation extension. See [Development](http://buildthedocs.github.io/master/development).

---

# About buildthedocs (BTD)

This is a proof-of-concept to provide a 'lightweight' multi-version documentation generator for users that:

- Rely on a git host service to handle users and access permissions.
- Need to generate/build documentation in different formats (HTML, PDF, EPUB...) and for multiple versions of a
project, using [Sphinx](http://www.sphinx-doc.org) and/or [Hugo](https://gohugo.io/) as the backend.
- Want to generate/build the documentation either locally or in a CI environment, without modifying any source between
both platforms.
- Want to be able to generate/build the documentation in a machine and have the products optionally deployed to a
hosting service automatically.

The most expected use case is a project hosted on [GitHub](https://github.com), the web site hosted on
[GitHub Pages](https://pages.github.com/) and using Travis CI to build the site after each push. Possible schemes:

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
- (optional) A `Dockerfile`.
- (optional) A CI configuration file (`.travis.yml`).

Therefore, you just need to get the sources using any of the options shown at [Installation](https://buildthedocs.github.io/master/installation.html). Shall you want to automatically deploy the build site to GitHub Pages or any other hosting service, you need to properly configure access permissions for the CI tool (see [Site deployment](doc/site_deployment.md)).

# Use

- (optional) Add the example `.btd.yml` file to your project and edit it to fit your use case. [WIP]
- Run `btd.sh build`. See options below.
- After a successful build, run `btd.sh deploy` to push changes to the hosting service.

Options for the build can be defined in the following ways (from lower to higher precedence):

- Defaults.
- Configuration file. [WIP]
- Environment variables.
- Command line arguments.

| envvar | cli | default | |
|-|-|-|-|
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
| BTD_SPHINX_THEME | - | `https://github.com/buildthedocs/sphinx_btd_theme/archive/btd.tar.gz` | |
| BTD_DEPLOY_KEY | - | `deploy_key.enc` | |
| BTD_TRAVIS | `g` | - | ref to `travis-ci.org` instead of `travis-ci.com` |

---

- `-c`, `-i`, `-o` and `BTD_DEPLOY_KEY` are relative to the root of `-s`.
- `-i` must lie inside the repository.
- `-o` can be absolute, and it is recommended to be set out of the repository, e.g. `../btd_builds`.

NOTE: the `conf.py` file of the Sphinx project might require some minor modifications. See further info about it, `BTD_SOURCE_REPO`, `BTD_TARGET_REPO`, `BTD_SPHINX_THEME`, `BTD_DISPLAY_GH` and `BTD_LAST_INFO` at [Usage](https://buildthedocs.github.io/master/usage.html).

# Similar projects

## ReadTheDocs.org (RTD.org)

This project (BTD) started as an alternative to [readthedocs.org](https://readthedocs.org/) (RTD.org) for users that don't
need most of the features that RTD.org provides as a service (webhooks, user/team/project management, web frontend or
API to modify settings, etc) because they use a different web hosting service and a CI service, such as, GitHub Pages
and Travis.

See [rtfd/readthedocs-build#35](https://github.com/rtfd/readthedocs-build/issues/35).

## buildthedocs.pietroalbini.org

There is a Python package with the same name as this project:
[pietroalbini/buildthedocs](https://github.com/pietroalbini/buildthedocs). The development of both projects is
independent ATM, but the same name is used because both tools are meant for the same exact usage. Differences are found
in implementation details:

- The Python package is expected to be executed natively or inside a VM/container which has all the required
dependencies pre-installed.
- This project is expected to be executed either natively or in CI jobs with [docker](https://www.docker.com/) and a
[single](https://github.com/1138-4EB/buildthedocs/releases) shell script as unique dependencies. Multiple
[docker images](https://hub.docker.com/u/btdi/) with pre-installed dependencies are used to provide ready-to-use
environments for each task.

## sphinxcontrib-versioning

[Robpol86/sphinxcontrib-versioning](https://github.com/Robpol86/sphinxcontrib-versioning)
