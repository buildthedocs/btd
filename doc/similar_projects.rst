Similar projects
################

ReadTheDocs.org (RTD.org)
=========================

This project (BTD) started as an alternative to `readthedocs.org <https://readthedocs.org/>`__ (RTD.org) for users
that don't need most of the features that RTD.org provides as a service (webhooks, user/team/project management, web
frontend or API to modify settings, etc), because they use a different web hosting service and a CI service, such as,
GitHub Pages and GitHub Actions.
See :gh:`rtfd/readthedocs-build#35 <rtfd/readthedocs-build/issues/35>`.

buildthedocs.pietroalbini.org
=============================

There is a Python package with the same name as this project: :gh:`pietroalbini/buildthedocs`.
The development of both projects is independent ATM, but the same name is used because both tools are meant for the same
exact usage.
Differences are found in implementation details:

* The Python package is expected to be executed natively or inside a VM/container which has all the required
  dependencies pre-installed.

* This project is expected to be executed either natively or in CI jobs with `docker <https://www.docker.com/>`__.
  Multiple `docker images <https://hub.docker.com/u/btdi/>`__ with pre-installed dependencies are used to provide
  ready-to-use environments for each task.
