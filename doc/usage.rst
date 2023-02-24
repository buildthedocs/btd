=====
Usage
=====

To use this script, simply call it::

	btd.sh

  curl -L https://raw.githubusercontent.com/buildthedocs/btd/master/btd.sh | sh -s build -v "master,v0.35"

Depending on the theme and the desired features, some minor modifications to `conf.py` might be required:

- ATM, the default theme used in ReadTheDocs.org (RTD), [rtfd/sphinx_rtd_theme](https://github.com/rtfd/sphinx_rtd_theme),
does not support the *versions menu* for builds outside of their own CI service. Therefore, if `sphinx_rtd_theme` is used,
multiple versions will be built, but the box will not be shown.
  - Because `sphinx_rtd_theme` is not a hard dependency, it must be added to the `requirements.txt` file: `git+https://github.com/rtfd/sphinx_rtd_theme@master`.
- [buildthedocs/sphinx_btd_theme](https://github.com/buildthedocs/sphinx_btd_theme) is an alternative to `sphinx_rtd_theme`,
which includes minor modifications in order to enable the *versions menu*. See [rtfd/sphinx_rtd_theme#543](https://github.com/rtfd/sphinx_rtd_theme/issues/543).
Set `html_theme = "sphinx_btd_theme"` in the `conf.py` file to use it.
   - Unlike `rtd_theme`, which is a python package, `btd_theme` is distributed as a tarball/zip file. BTD automatically
	 downloads it and places it in the same directory as `conf-py`, so no modification to `requirements.txt` is required.
	 Just set `html_theme_path = ["."]` to let Sphinx find it.
   - A JSON file is used to pass context data from BTD to Sphinx. Add the following snippet to the `conf.py`, just after
	 the definition of `html_context`:

   ```
   # Add display_github and VERSIONING data
   if isfile('context.json'):
      from json import loads
      data = loads(open('context.json').read())
      html_context.update(data)
   ```

html_last_updated_fmt

Preparation for deployment
==========================

During the deploy process a `.nojekyll` file is added to the root of the target repo/branch, in order to prevent directories
and files starting with `_` from being ignored. See https://help.github.com/articles/files-that-start-with-an-underscore-are-missing/
