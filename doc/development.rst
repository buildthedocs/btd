===========
Development
===========

Modifying and testing docker images
-----------------------------------

`Dockerfile <https://github.com/1138-4EB/buildthedocs/blob/master/Dockerfile>`_ contains definitions of all the images,
by making the best of docker `multi-stage builds <https://docs.docker.com/engine/userguide/eng-image/multistage-build/>`_.
Each of the stages named :samp:`do-*` is built and pushed to `hub.docker.com/u/btdi <https://hub.docker.com/u/btdi/>`_ during an
optional stage in Travis CI.

You can build all the images with `btd/images.sh <https://github.com/1138-4EB/buildthedocs/blob/master/btd/images.sh>`_
or :samp:`btd.sh images`. Shall you need to compile only one of them, e.g. because you added a new dependency which affects a
single image:

.. code-block:: bash

   docker build -t "btdi/$tag" --target "do-$tag" - < Dockerfile"

You can run `btd/test.sh` <https://github.com/1138-4EB/buildthedocs/blob/master/btd/test.sh>`_ or :samp:`btd.sh test` to check
if something breaks after the modifications you introduced in the Dockerfile. This will get an example project that uses
most of the features; and it will build a few versions of it.

Any image name can be used, i.e., you can build :samp:`<your_registry>/<your_username>/<image_name>:<tag>` and push
the image to your own repo/registry. Then, set :samp:`BTD_IMG_SPHINX` and/or :samp:`BTD_IMG_LATEX` accordingly.

Commit messages
---------------

Some Travis CI stages are conditionally executed:

- :samp:`images.sh` is only executed if the commit message contains :samp:`[ci images]`.
- :samp:`test.sh` is only executed if the commit message container :samp:`[ci test]`.

Also, :samp:`[ci skip]` prevents Travis CI from running any image at all.

Packing shell scripts in a single file
--------------------------------------

:samp:`pack.sh` merges :samp:`ansi_color.sh`, :samp:`travis_utils.sh`, :samp:`config.sh`, :samp:`build.sh`, :samp:`images.sh`, :samp:`deploy.sh` and :samp:`test.sh` in
a single file named :samp:`btd.sh`. In each of the sources, `#>` and `#<` indicate the first and last lines that are copied,
respectively. Any content prepended or appended to the block will only be available when sources are executed separately.

Do never edit :samp:`btd.sh` directly. Shall you want to modify any subcommand, edit the corresponding source and run
:samp:`pack.sh`.

`BTD_DISPLAY_GH`
----------------

If ennvar :samp:`BTD_DISPLAY_GH` is not empty, the following fields are added to `context.json`:

.. code-block::

   "display_github": True
   "github_user": "$BTD_GH_USER"
   "github_repo": "$BTD_GH_REPO"
   "github_version": "activeVersion$subdir"

where

- :samp:`BTD_GH_USER` and :samp:`BTD_GH_REPO` are automatically extracted from :samp:`BTD_SOURCE_URL`, which is itself extracted from :samp:`BTD_SOURCE_REPO`.
- :samp:`activeVersion` is replaced with the corresponding version name in each build.
- :samp:`subdir` is :samp:`BTD_INPUT_DIR`, if the latter is not empty.

When :samp:`context.json` is appended to :samp:`html_context` in the :samp:`conf.py` file, the content of these fields is used to replace :samp:`View page source` with :samp:`Edit on GitHub`.

`BTD_LAST_INFO`
---------------

Last updated info format is defined with ennvar :samp:`BTD_LAST_INFO`.

If theme :samp:`sphinx_rtd_theme` is used, these are the options:

- :samp:`BTD_LAST_INFO=build`: only available in Travis, :samp:'Build <BUILD_ID>' is shown, where :samp:`BUILD_ID` points to the
build log.
- :samp:`BTD_LAST_INFO=commit`: :samp:'Revision <COMMIT_SHA>' is shown, where the first eight characters of the SHA are shown.
- :samp:`BTD_LAST_INFO=date`: is the default Sphinx format, defined by :samp:`html_last_updated_fmt` in :samp:`conf.py`.

If theme :samp:`sphinx_btd_theme` is used, the options above can be combined. For example, the default is:
:samp:`BTD_LAST_INFO="Last updated on LAST_DATE [LAST_COMMIT - LAST_BUILD]"`. BTD will replace each token with the corresponding
(linked) value. If :samp:`BTD_DISPLAY_GH` is set, the SHA is linked to the commit in the GitHub repo.

-----------------------------------------------------------------------------

- http://www.sphinx-doc.org/en/stable/config.html#confval-html_last_updated_fmt
- https://stackoverflow.com/questions/39007271/why-doesnt-readthedocs-show-last-updated-on
- https://github.com/rtfd/sphinx_rtd_theme/issues/395
