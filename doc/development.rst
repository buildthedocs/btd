===========
Development
===========

## Modifying and testing docker images

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

## `BTD_DISPLAY_GH`

```
'display_github': True,
'github_user': 'ghdl',
'github_repo': 'ghdl',
'github_version': 'master/doc/',
```

##

Commit, revision, last updated

https://github.com/rtfd/sphinx_rtd_theme/issues/395
