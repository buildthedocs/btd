# Site deployment

The recommended procedure to allow deployments from Travis CI to GitHub Pages is using a deploy key. There are multiple
tutorials explaining how to do it step-by-step:

- [alrra/travis-scripts:docs/github-deploy-keys.md](https://github.com/alrra/travis-scripts/blob/master/docs/github-deploy-keys.md)
- [medium.com: Deploy to GitHub Pages using Travis CI and deploy keys](https://medium.com/@simon.legner/deploy-to-github-pages-using-travis-ci-and-deploy-keys-db84fed7a929)
- [gist.github.com/qoomon/README.md](https://gist.github.com/qoomon/c57b0dc866221d91704ffef25d41adcf)
- ...

Alternatively, in order to avoid installing Travis CLI locally and to have it automated, [travis-enc-deploy.sh](https://github.com/buildthedocs/btd/blob/master/travis/travis-enc-deploy.sh)
is provided:

- Run `$(command -v winpty) docker run --rm -it alpine sh -c "REPO='https://github.com/<user|organization>/<repo>'; $(cat travis-enc-deploy.sh)"`
- Follow the steps until `[master <SHORT_COMMIT_SHA>] Add deploy_key.enc <ENCRYPTION_LABEL>` is shown.
- Rebase, squash, fixup, move commit to different branch...
- When you are OK with the result, git push.
- `exit` to close and remove the container.
- Check the log and copy the public key to the repo: [GitHub Developer: Managing Deploy Keys, Deploy keys](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys)
- See instructions to edit `.travis.yml` and an example deploy script at [gist.github.com/domenic/auto-deploy.md](https://gist.github.com/domenic/ec8b0fc8ab45f39403dd)

---

Note that you need to encrypt the deploy key (and, therefore, save `deply_key.enc`) in the repo corresponding to the
source branch, but you have to add the public key to the repo corresponding to the target branch. Neither in the repo
where sources are located, nor in the user profile.

Using a deploy key limited to a repo is important, because it could be damaged, as long as it provides write access.
Indeed, when possible, it is suggested to keep sources and deployed sites in separate repositories.
