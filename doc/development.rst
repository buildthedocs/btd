===========
Development
===========

Modifying and testing docker images
-----------------------------------

[`Dockerfile`](https://github.com/1138-4EB/buildthedocs/blob/master/Dockerfile) contains definitions of all the images,
by making the best of docker [multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/).
Each of the stages named `do-*` is built and pushed to [hub.docker.com/u/btdi](https://hub.docker.com/u/btdi/) during an
optional stage in Travis CI.

You can build all the images with [`btd/images.sh`](https://github.com/1138-4EB/buildthedocs/blob/master/btd/images.sh)
or `btd.sh images`. Shall you need to compile only one of them, e.g. because you added a new dependency which affects a
single image:

```
docker build -t "btdi/$tag" --target "do-$tag" - < Dockerfile"
```

You can run [`btd/test.sh`](https://github.com/1138-4EB/buildthedocs/blob/master/btd/test.sh) or `btd.sh test` to check
if something breaks after the modifications you introduced in the Dockerfile. This will get an example project that uses
most of the features; and it will build a few versions of it.

Any image name can be used, i.e., you can build `<your_registry>/<your_username>/<image_name>:<tag>` and push
the image to your own repo/registry. Then, set `BTD_IMG_SPHINX` and/or `BTD_IMG_LATEX` accordingly.

Commit messages
---------------

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

`BTD_DISPLAY_GH`
----------------

If ennvar `BTD_DISPLAY_GH` is not empty, the following fields are added to `context.json`:

```
"display_github": True
"github_user": "$BTD_GH_USER"
"github_repo": "$BTD_GH_REPO"
"github_version": "activeVersion$subdir"
```

where

- `BTD_GH_USER` and `BTD_GH_REPO` are automatically extracted from `BTD_SOURCE_URL`, which is itself extracted from
`BTD_SOURCE_REPO`.
- `activeVersion` is replaced with the corresponding version name in each build.
- `subdir` is 'BTD_INPUT_DIR', if the latter is not empty.

When `context.json` is appended to `html_context` in the `conf.py` file, the content of these fields is used to replace
`View page source` with `Edit on GitHub`.

`BTD_LAST_INFO`
---------------

Last updated info format is defined with ennvar `BTD_LAST_INFO`.

If theme `sphinx_rtd_theme` is used, these are the options:

- `BTD_LAST_INFO=build`: only available in Travis, 'Build <BUILD_ID>' is shown, where `BUILD_ID` points to the
build log.
- `BTD_LAST_INFO=commit`: 'Revision <COMMIT_SHA>' is shown, where the first eight characters of the SHA are shown.
- `BTD_LAST_INFO=date`: is the default Sphinx format, defined by `html_last_updated_fmt` in `conf.py`.

If theme `sphinx_btd_theme` is used, the options above can be combined. For example, the default is:
`BTD_LAST_INFO="Last updated on LAST_DATE [LAST_COMMIT - LAST_BUILD]"`. BTD will replace each token with the corresponding
(linked) value. If `BTD_DISPLAY_GH` is set, the SHA is linked to the commit in the GitHub repo.

- http://www.sphinx-doc.org/en/stable/config.html#confval-html_last_updated_fmt
- https://stackoverflow.com/questions/39007271/why-doesnt-readthedocs-show-last-updated-on
- https://github.com/rtfd/sphinx_rtd_theme/issues/395
