#!/bin/sh

#  [[https://<domain>/]<user>/<repo>|]  <branch>[/subdir[/subsubdir[...]]]
#      [[git@<domain>:]<user>/<repo>|]
#                     [file://<path>|]

cd $(dirname $0)

./cli/btd test ref \
  "" \
  "develop" \
  "develop/mydoc" \
  "develop/mydoc/withsubdir" \
  "user/repo|develop" \
  "user/repo|develop/mydoc" \
  "user/repo|develop/mydoc/withsubdir" \
  "mydomain.io/user/repo|develop" \
  "mydomain.io/user/repo|develop/mydoc" \
  "mydomain.io/user/repo|develop/mydoc/withsubdir" \
  "https://mydomain.io/user/repo|develop" \
  "https://mydomain.io/user/repo|develop/mydoc" \
  "https://mydomain.io/user/repo|develop/mydoc/withsubdir" \
  "git@mydomain.io:user/repo|develop" \
  "git@mydomain.io:user/repo|develop/mydoc" \
  "git@mydomain.io:user/repo|develop/mydoc/withsubdir" \
  "file:///src/btd_prj|develop" \
  "file:///src/btd_prj|develop/mydoc" \
  "file:///src/btd_prj|develop/mydoc/withsubdir"
