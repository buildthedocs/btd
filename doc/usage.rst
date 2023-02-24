=====
Usage
=====

Theme
-----

The expected syntax for :samp:`BTD_SPHINX_THEME` is a comma separated list of URLs corresponding to tarballs/zip files that contain raw themes. These are downloaded and placed in :samp:`BTD_INPUT_DIR`. If the used theme is distributed as a python package, e.g. `rtfd/sphinx_rtd_theme <https://github.com/rtfd/sphinx_rtd_theme>`_, it must be added to :samp:`requirements.txt` instead.

* ATM, the default theme used in ReadTheDocs.org (RTD), `rtfd/sphinx_rtd_theme <https://github.com/rtfd/sphinx_rtd_theme>`_, does not support the *versions menu* for builds outside of their own CI service. Therefore, if :samp:`sphinx_rtd_theme` is used, multiple versions will be built, but the box will not be shown.
   * Because :samp:`sphinx_rtd_theme` is not a hard dependency, it must be added to the :samp:`requirements.txt` file: :samp:`git+https://github.com/rtfd/sphinx_rtd_theme@master`.
* `buildthedocs/sphinx_btd_theme <https://github.com/buildthedocs/sphinx_btd_theme>`_ is an alternative to `sphinx_rtd_theme`, which includes minor modifications in order to enable the *versions menu*. See `rtfd/sphinx_rtd_theme#543 <https://github.com/rtfd/sphinx_rtd_theme/issues/543>`_. To use it, set :samp:`html_theme = "sphinx_btd_theme"` in the :samp:`conf.py`.

In order to switch from `sphinx_rtd_theme` to `sphinx_btd_theme`, some minor modifications to `conf.py` might be required:

* Unlike :samp:`rtd_theme`, which is a python package, :samp:`btd_theme` is distributed as a tarball/zip file. BTD automatically downloads it and places it in the same directory as :samp:`conf-py`, so no modification to :samp:`requirements.txt` is required. Just set :samp:`html_theme_path = ["."]` to let Sphinx find it.
* A JSON file (:samp:`context.json`) is used to pass context data from BTD to Sphinx. Add the following snippet to the :samp:`conf.py`, just after the definition of :samp:`html_context`:

   .. code-block:: python

      # Add display_github and VERSIONING data
      if isfile('context.json'):
         from json import loads
         data = loads(open('context.json').read())
         html_context.update(data)

Syntax of `BTD_SOURCE_REPO` and `BTD_TARGET_REPO`
-------------------------------------------------

.. code-block:: bash

   [[<protocol>://<domain>/]<user>/<repo>:]<branch>[/subdir[/subsubdir[...]]]

If set to empty, it defaults to :samp:`master`. If nothing is prepended to `<branch>`, the location of `.btd.yml` is considered to be a previously cloned git repository.

`BTD_DISPLAY_GH`
----------------

If envvar :samp:`BTD_DISPLAY_GH` is not empty, the following fields are added to `context.json`:

.. code-block:: bash

   "display_github": True
   "github_user": "$BTD_GH_USER"
   "github_repo": "$BTD_GH_REPO"
   "github_version": "activeVersion$subdir"

where

* :samp:`BTD_GH_USER` and :samp:`BTD_GH_REPO` are automatically extracted from :samp:`BTD_SOURCE_URL`, which is itself extracted from :samp:`BTD_SOURCE_REPO`.
* :samp:`activeVersion` is replaced with the corresponding version name in each build.
* :samp:`subdir` is :samp:`BTD_INPUT_DIR`, if the latter is not empty.

When :samp:`context.json` is appended to :samp:`html_context` in the :samp:`conf.py` file, the content of these fields is used to replace :samp:`View page source` with :samp:`Edit on GitHub`.

`BTD_LAST_INFO`
---------------

Last updated info format is defined with ennvar :samp:`BTD_LAST_INFO`.

If theme :samp:`sphinx_rtd_theme` is used, these are the options:

* :samp:`BTD_LAST_INFO=build`: only available in Travis, :samp:'Build <BUILD_ID>' is shown, where :samp:`BUILD_ID` points to the build log.
* :samp:`BTD_LAST_INFO=commit`: :samp:'Revision <COMMIT_SHA>' is shown, where the first eight characters of the SHA are shown.
* :samp:`BTD_LAST_INFO=date`: is the default Sphinx format, defined by :samp:`html_last_updated_fmt` in :samp:`conf.py`.

If theme :samp:`sphinx_btd_theme` is used, the options above can be combined. For example, the default is:
:samp:`BTD_LAST_INFO="Last updated on LAST_DATE [LAST_COMMIT - LAST_BUILD]"`. BTD will replace each token with the corresponding
(linked) value. If :samp:`BTD_DISPLAY_GH` is set, the SHA is linked to the commit in the GitHub repo.

* http://www.sphinx-doc.org/en/stable/config.html#confval-html_last_updated_fmt
* https://stackoverflow.com/questions/39007271/why-doesnt-readthedocs-show-last-updated-on
* https://github.com/rtfd/sphinx_rtd_theme/issues/395

Preparation for deployment
--------------------------

During the deploy process a :samp:`.nojekyll` file is added to the root of the target repo/branch, in order to prevent directories and files starting with :samp:`_` from being ignored. See `GitHub Help: Files that start with an underscore are missing <https://help.github.com/articles/files-that-start-with-an-underscore-are-missing/>`_.
