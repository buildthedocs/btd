<p align="center">
  <!--
  -->
  <a title="Site" href="https://buildthedocs.github.io/btd"><img src="https://img.shields.io/website.svg?label=buildthedocs.github.io%2Fbtd&longCache=true&style=flat-square&url=http%3A%2F%2Fbuildthedocs.github.io%2Fbtd%2Findex.html&logo=GitHub"></a><!--
  -->
  <a title="Join the chat at gitter.im/buildthedocs/community" href="https://gitter.im/buildthedocs/community"><img src="https://img.shields.io/badge/chat-on%20gitter-4db797.svg?longCache=true&style=flat-square&logo=gitter&logoColor=e8ecef"></a><!--
  -->
  <a title="'images' workflow Status" href="https://github.com/buildthedocs/btd/actions?query=workflow%3Aimages"><img alt="'images' workflow Status" src="https://img.shields.io/github/workflow/status/buildthedocs/btd/images/master?longCache=true&style=flat-square&logo=Github%20Actions&logoColor=e8ecef&label=imgs"></a><!--
  -->
  <a title="'test' workflow Status" href="https://github.com/buildthedocs/btd/actions?query=workflow%3Atest"><img alt="'images' workflow Status" src="https://img.shields.io/github/workflow/status/buildthedocs/btd/test/master?longCache=true&style=flat-square&logo=Github%20Actions&logoColor=e8ecef&label=test"></a><!--
  -->
</p>

# Build The Docs (BTD)

This is a proof-of-concept to provide a 'lightweight' multi-version documentation generator for users that:

- Rely on a git hosting service to handle users and access permissions.
- Need to generate/build documentation in different formats (HTML, PDF, EPUB...) and for multiple versions of a project, using [Sphinx](http://www.sphinx-doc.org).
- Want to be able to generate/build the documentation and have the products optionally deployed to a hosting service automatically.

The most expected use case is:

- Project hosted on [GitHub](https://github.com).
- Web site hosted on [GitHub Pages](https://pages.github.com/).
- A GitHub Actions workflow to build the site after each push.

Possible schemes:

- Save doc sources in:
  - A subdir of master/development branches.
  - TODO: The root of a given branch.
- Deploy to, either the same or a different repository:
  - Branch `master`.
  - Branch `gh-pages`.
  - TODO: Subdir docs in branch `master`.

# Usage

This project is available as a Python package ([btd](btd)), along with the plumbing to use it as a GitHub Action.
Find usage guidelines and examples at [buildthedocs.github.io/btd](https://buildthedocs.github.io/btd).

# Similar projects

## ReadTheDocs.org (RTD.org)

This project (BTD) started as an alternative to [readthedocs.org](https://readthedocs.org/) (RTD.org) for users that don't
need most of the features that RTD.org provides as a service (webhooks, user/team/project management, web frontend or
API to modify settings, etc), because they use a different web hosting service and a CI service, such as, GitHub Pages
and GitHub Actions. See [rtfd/readthedocs-build#35](https://github.com/rtfd/readthedocs-build/issues/35).

## buildthedocs.pietroalbini.org

There is a Python package with the same name as this project:
[pietroalbini/buildthedocs](https://github.com/pietroalbini/buildthedocs). The development of both projects is
independent ATM, but the same name is used because both tools are meant for the same exact usage. Differences are found
in implementation details:

- The Python package is expected to be executed natively or inside a VM/container which has all the required
dependencies pre-installed.
- This project is expected to be executed either natively or in CI jobs with [docker](https://www.docker.com/). Multiple
[docker images](https://hub.docker.com/u/btdi/) with pre-installed dependencies are used to provide ready-to-use
environments for each task.

## sphinxcontrib-versioning

[Robpol86/sphinxcontrib-versioning](https://github.com/Robpol86/sphinxcontrib-versioning)
