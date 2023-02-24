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

You can run `btd/test.sh <https://github.com/1138-4EB/buildthedocs/blob/master/btd/test.sh>`_ or :samp:`btd.sh test` to check
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

:samp:`pack.sh` merges :samp:`utils.sh`, :samp:`config.sh`, :samp:`build.sh`, :samp:`deploy.sh` and :samp:`test.sh` in
a single file named :samp:`btd.sh`. In each of the sources, `#>` and `#<` indicate the first and last lines that are copied,
respectively. Any content prepended or appended to the block will only be available when sources are executed separately.

Do never edit :samp:`btd.sh` directly. Shall you want to modify any subcommand, edit the corresponding source and run
:samp:`pack.sh`.
