#!/bin/sh

# - Run `$(command -v winpty) docker run --rm -it alpine sh -c "REPO='https://github.com/<user|organization>/<repo>'; $(cat travis-enc-deploy.sh)"`
# - Follow the steps until `[master <SHORT_COMMIT_SHA>] Add deploy_key.enc <ENCRYPTION_LABEL>` is shown.
# - Rebase, squash, fixup, move commit to different branch...
# - When you are OK with the result, git push.
# - `exit` to close and remove the container.
# - Check the log and copy the public key to the repo: https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys
# - See instructions to edit `.travis.yml` and an example deploy script at https://gist.github.com/domenic/ec8b0fc8ab45f39403dd

apk add -U --no-cache git openssh ruby ruby-dev libffi-dev build-base ruby-dev libc-dev libffi-dev linux-headers
gem install travis --no-rdoc --no-ri

git clone $REPO ./tmp-repo && cd tmp-repo

ssh-keygen -t rsa -b 4096 -C "travis@gh-pages" -f deploy_key -N ''
cat deploy_key.pub

travis login --org --auto
msg=$(travis encrypt-file deploy_key)

rm deploy_key
chmod 600 deploy_key.enc
git add deploy_key.enc

git config user.name "Travis CI"
git config user.email "travis@gh-pages"

git commit -m "Add deploy_key.enc `echo $msg | grep -o "encrypted_.*_key -iv" | sed -e 's/encrypted_\([0-9a-z]*\)_key -iv/\1/g'`"

sh
