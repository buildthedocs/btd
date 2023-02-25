<p align="center">
  <!--
  -->
  <a title="Site" href="https://buildthedocs.github.io/btd"><img src="https://img.shields.io/website.svg?label=buildthedocs.github.io%2Fbtd&longCache=true&style=flat-square&url=http%3A%2F%2Fbuildthedocs.github.io%2Fbtd%2Findex.html&logo=GitHub"></a><!--
  -->
  <a title="Join the chat at gitter.im/buildthedocs/community" href="https://gitter.im/buildthedocs/community"><img src="https://img.shields.io/badge/chat-on%20gitter-4db797.svg?longCache=true&style=flat-square&logo=gitter&logoColor=e8ecef"></a><!--
  -->
  <a title="'images' workflow Status" href="https://github.com/buildthedocs/btd/actions/workflows/images.yml"><img alt="'images' workflow Status" src="https://img.shields.io/github/actions/workflow/status/buildthedocs/btd/images.yml?branch=main&longCache=true&style=flat-square&logo=Github%20Actions&logoColor=e8ecef&label=imgs"></a><!--
  -->
  <a title="'test' workflow Status" href="https://github.com/buildthedocs/btd/actions/workflows/test.yml"><img alt="'test' workflow Status" src="https://img.shields.io/github/actions/workflow/status/buildthedocs/btd/test.yml?branch=main&longCache=true&style=flat-square&logo=Github%20Actions&logoColor=e8ecef&label=test"></a><!--
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
