- [About](#about-buildthedocs-btd)
- [Install](#install)
- [Use](#use)
- [Development](#development)
- [Similar projects](#similar-projects)

---

NOTE! This is not an actively supported project. It is a documented and slightly cleaned up version of
scripts that were written to move some projects from RTD.org to Travis and GitHub Pages. Since the project is quite
small (<500 lines), best effort support is given to users willing to contribute bug fixes, enhancements or documentation
extension.

---

# About buildthedocs (BTD)

This is a proof-of-concept to provide a 'lightweight' multi-version documentation generator for users that:

- Rely on a git host service to handle users and access permissions.
- Need to generate/build documentation in different formats (HTML, PDF, EPUB...) and for multiple versions of the
project, using [Sphinx](http://www.sphinx-doc.org) and/or [Hugo](https://gohugo.io/) as the backend.
- Want to generate/build the documentation either locally or in a CI environment, without modifying any source.
- Want to be able to generate/build the documentation in a machine and have the products optionally deployed to a
hosting service automatically.

The most expected use case is a project hosted on [GitHub](https://github.com), the web site hosted on
[GitHub Pages](https://pages.github.com/) and Travis CI building the site after each push. Possible schemes:

- Save sources in:
  - A subdir of master/development branches.
  - The root of a given branch.
- Deploy to, either the same or a different repository:
  - Branch `master`.
  - Branch `gh-pages`.
  - Subdir docs in branch `master`.

# Install

This project comprises:

- A bunch of shell scripts, optionally packed in a single file.
- (optional) A configuration file (`.btd.yml`).
- (optional) A `Dockerfile`.
- (optional) A CI configuration file (`.travis.yml`).

Therefore, you just need to get the sources using any of the options below:

- Get the single script version from [release](https://github.com/1138-4EB/buildthedocs/releases).
- Get the latest archive ([ZIP](https://github.com/1138-4EB/readthedocs-docker-images/archive/master.zip) or [TAR.GZ](https://github.com/1138-4EB/readthedocs-docker-images/archive/master.tar.gz)).
- Add this project as a submodule of yours.

Shall you want to automatically deploy the build site to GitHub Pages or any other hosting service, you need to properly
configure access permissions for the CI tool (see [Site deployment](doc/site_deployment.md)).

# Use

- (optional) Add the example `.btd.yml` file to your project and edit it to fit your use case.
- Run `btd.sh build`. See options below.
- After a successful build, run `btd.sh deploy` to push changes to the hosting service.

---

Options for the build can be defined in the following ways (from lower to higher precedence):

- Defaults.
- Configuration file.
- Environment variables.
- Command line arguments.

| envvar | cli | default | |
|-|-|-|-|
| BTD_CONFIG_FILE | `-c` | `./.btd.yml` | |
| BTD_INPUT_DIR | `-i` | `doc/` | |
| BTD_OUTPUT_DIR | `-o` | `../btd_builds/` | |
| BTD_SOURCE_BRANCH | `-s` | `master` | |
| BTD_TARGET_BRANCH | `-t` |  `gh-pages` | |
| BTD_VERSION | `-v` | `master` | comma delimited list of versions |
| BTD_IMG_SPHINX | - | `btdi/sphinx` | |
| BTD_IMG_LATEX | - | `btdi/latex` | |


- `-c`, `-i` and `-o` are relative to the root of `-s`.
- `-i` must lie inside the repository.
- `-o` can be absolute, and it is recommended to be set out of the repository, e.g. `../btd_builds`.

The supported format for `SOURCE_REPO` and `TARGET_REPO` is:

``` bash
[[<protocol>://<domain>/]<user>/<repo>:]<branch>[/subdir[/subsubdir[...]]]
```

If nothing is prepended to `<branch>`, the location of `.btd.yml` is considered to be a previously cloned git repository.

# Development

## Modifying and testing docker images

[`Dockerfile`](https://github.com/1138-4EB/buildthedocs/blob/master/Dockerfile) contains definitions of all the images, by making the best of docker
[multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/). Each of the stages named
`do-*` is built and pushed to [hub.docker.com/u/btdi](https://hub.docker.com/u/btdi/) during an optional stage in
Travis CI.

You can build all the images with [`btd/images.sh`](https://github.com/1138-4EB/buildthedocs/blob/master/btd/images.sh)
or `btd.sh images`. Shall you need to compile only one of them, e.g. because you added a new dependency which affects a
single image:

```
docker build -t "btdi/$tag" --target "do-$tag" - < Dockerfile"
```

You can run [`btd/test.sh`](https://github.com/1138-4EB/buildthedocs/blob/master/btd/test.sh) or `btd.sh test` to check
if something breaks after the modifications you introduced in the Dockerfile. This will get an example project that uses
most of the features; and it will build a few versions of it.

## Commit messages

Some Travis CI stages are conditionally executed:

- `images.sh` is only executed if the commit message contains `[ci images]`.
- `test.sh` is only executed if the commit message container `[ci test]`.

Also, `[ci skip]` prevents Travis CI from running any image at all.

## Packing shell scripts in a single file

`pack.sh` merges `ansi_color.sh`, `travis_utils.sh`, `config.sh`, `build.sh`, `images.sh`, `deploy.sh` and `test.sh` in
a single file named `btd.sh`. In each of the sources, `#>` and `#<` indicate the first and last lines that are copied,
respectively. Any content prepended or appended to the block will only be available when sources are executed separately.

Do never edit `btd.sh` directly. Shall you want to modify any subcommand, edit the corresponding source and run
`pack.sh`.

# Similar projects

## ReadTheDocs.org (RTD.org)

This project started as an alternative to [readthedocs.org](https://readthedocs.org/) (RTD.org) for users that don't
need most of the features that RTD.org provides as a service (webhooks, user/team/project management, web frontend or
API to modify settings, etc) because they rely on a CI service such as Travis. 

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
