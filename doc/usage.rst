========
Usage
========

To use this script, simply call it::

	btd.sh

  curl -L https://raw.githubusercontent.com/buildthedocs/btd/master/btd.sh | sh -s build -v "master,v0.35"

Deploy
======

During the deploy process a `.nojekyll` file is added to the root of the target repo/branch, in order to prevent directories
and files starting with `_` from being ignored. See https://help.github.com/articles/files-that-start-with-an-underscore-are-missing/
