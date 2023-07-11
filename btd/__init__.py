# Authors:
#   Unai Martinez-Corral
#
# Copyright 2017-2023 Unai Martinez-Corral <unai.martinezcorral@ehu.eus>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

"""
Helpers to build BTD documentation websites
"""

from os import environ
from subprocess import call, check_call, check_output, run
from json import dump, loads

from sys import argv, executable, stdout
from pathlib import Path
from yaml import load, Loader, YAMLError
from typing import List, Union

from shutil import which, rmtree


def startBlock(msg):
    print("##[group]%s" % msg)
    stdout.flush()


def endBlock():
    print("##[endgroup]")
    stdout.flush()


class BTDConfigFile:
    def __init__(self, cfgfile):
        if not cfgfile:
            cfgfile = Path(".") / ".btd.yml"
        else:
            cfgfile = Path(cfgfile)

        if not cfgfile.exists():
            raise (Exception("Configuration file %s not found!" % str(cfgfile)))

        with cfgfile.open("r") as stream:
            self._cfg = load(stream, Loader=Loader)

        for key, val in self._cfg.items():
            print("%s: %s" % (key, val))
            stdout.flush()

        self._defaults = {
            "input": "doc",
            "output": "_build",
            "requirements": "requirements.txt",
            "formats": ["html"],
            "images": {"base": "btdi/sphinx:featured", "latex": "btdi/latex"},
            "target": "gh-pages",
        }

    def getPath(self, root: Path, key: str) -> Path:
        # TODO: check if self._cfg[key] is absolute
        # TODO: check if an envvar was provided
        return root / self._defaults[key] if key not in self._cfg else root / self._cfg[key]

    def getKey(self, key: str):  # -> Union[str, List[str]]
        if key not in self._cfg:
            return None if key not in self._defaults else self._defaults[key]
        else:
            val = self._cfg[key]
            if key == "images":
                for label, img in self._defaults[key].items():
                    if label not in val:
                        val[label] = img
            return val


def build(fmt: str, inputdir: Path, outputdir: Path):
    idir = str(inputdir.resolve())
    odir = str(outputdir.resolve())
    try:
        benv = environ.copy()
        benv["SPHINXBUILDDIR"] = odir
        check_call(["make", fmt], cwd=idir, env=benv)
    except:
        check_call([executable, "-m", "sphinx", "-TEWanb", fmt, idir, odir])


def publish(bdir: Path, remote: str, branch: str, message: str):
    for cmd in [
        ["touch", ".nojekyll"],
        ["git", "init"],
        ["git", "add", "."],
        ["git", "config", "--local", "user.email", "BTD@GHA"],
        ["git", "config", "--local", "user.name", "BuildTheDocs"],
        ["git", "remote", "add", "origin", remote],
        ["git", "commit", "-a", "-m", message],
        ["git", "push", "-u", "origin", "+HEAD:%s" % branch],
    ]:
        check_call(cmd, cwd=str(bdir))


def BTDRun(nolocal=False):

    startBlock("Get configuration...")

    BTD_DOCKER = which("docker")
    if run([BTD_DOCKER, "-v"], check=False).returncode != 0:
        BTD_DOCKER = None

    BTD_IN_DOCKER = False
    try:
        # https://stackoverflow.com/questions/69002675/on-debian-11-bullseye-proc-self-cgroup-inside-a-docker-container-does-not-sho
        mountinfo = str(check_output(["cat", "/proc/self/mountinfo"]))
        BTD_IN_DOCKER = ("docker" in mountinfo) or ("containerd" in mountinfo) or ("actions_job" in mountinfo)
    except:
        pass
    print("SPHINX:", which("sphinx-build"))
    print("DOCKER:", which("docker"))
    print("IN_DOCKER:", BTD_IN_DOCKER)
    print("LATEX:", which("pdflatex"))

    BTD_CFG = BTDConfigFile(environ.get("INPUT_CONFIG"))
    BTD_INPUT_DIR = BTD_CFG.getPath(Path("."), "input")
    BTD_OUTPUT_DIR = BTD_CFG.getPath(BTD_INPUT_DIR, "output")
    BTD_REQUIREMENTS = BTD_CFG.getPath(BTD_INPUT_DIR, "requirements")

    BTD_FORMATS = BTD_CFG.getKey("formats")
    BTD_IMGS = BTD_CFG.getKey("images")

    if BTD_IN_DOCKER:
        wrkspc = Path(environ.get("RUNNER_WORKSPACE"))
        workRoot = wrkspc / wrkspc.name
    else:
        workRoot = Path(".").resolve()
    print("workRoot:", workRoot)

    endBlock()

    startBlock("Add context...")
    addCtx(BTD_INPUT_DIR)
    endBlock()

    BTD_THEME = BTD_CFG.getKey("theme")
    if BTD_THEME:
        startBlock("Get theme...")
        getTheme(Path(BTD_INPUT_DIR), BTD_THEME)
        endBlock()

    for fmt in BTD_FORMATS:
        if fmt == "pdf" and "latex" not in BTD_FORMATS:
            fmt = "latex"

        startBlock("Build %s..." % fmt)

        BTD_SPHINX = which("sphinx-build")
        if (not nolocal) and BTD_SPHINX:
            print("BUILD local: %s %s" % (BTD_INPUT_DIR, BTD_OUTPUT_DIR))
            if BTD_REQUIREMENTS.exists():
                cmd = [executable, "-m", "pip", "install", "-r", str(BTD_REQUIREMENTS)]
                if '--break-system-packages' in str(check_output([executable, "-m", "pip", "install", "-h"])):
                    cmd += "--break-system-packages"
                check_call(cmd)
            build(fmt, BTD_INPUT_DIR, BTD_OUTPUT_DIR)
        elif BTD_DOCKER:

            with (BTD_INPUT_DIR / "btd_make.sh").open("w") as fptr:
                fptr.write("#!/usr/bin/env sh\n")
                if BTD_REQUIREMENTS.exists():
                    fptr.write(f'pip install --break-system-packages -r {Path("/src") / BTD_REQUIREMENTS}\n')
                fptr.write("make %s\n" % fmt)
                fptr.flush()

            check_call(["chmod", "+x", str(BTD_INPUT_DIR / "btd_make.sh")])

            #            with (BTD_INPUT_DIR / 'btd_make.sh').open('w') as fptr:
            #                fptr.write('''
            ##!/usr/bin/env sh
            #
            # pip install --break-system-packages -r %s
            # make %s
            #''' % (str(BTD_REQUIREMENTS), fmt))
            #            check_output(['chmod', '+x', str(BTD_INPUT_DIR / 'btd_make.sh')])
            # TODO: Integrate build, to support docs without makefile
            cmd = [
                BTD_DOCKER,
                "run",
                "--rm",
                "-v",
                "%s:/src" % str(workRoot),
                "-w",
                "/src/%s" % str(BTD_INPUT_DIR),
                BTD_IMGS["base"],
                "./btd_make.sh",
            ]
            print("BUILD docker: %s" % " ".join(cmd))
            stdout.flush()
            check_call(cmd)
        else:
            raise (Exception("Neither 'sphinx-build' nor 'docker' available!"))

        endBlock()

    if (
        "INPUT_TOKEN" in environ
        and "GITHUB_REPOSITORY" in environ
        and "GITHUB_SHA" in environ
        and "html" in BTD_FORMATS
        and (environ.get("INPUT_SKIP-DEPLOY", "false").lower() != "true")
    ):
        startBlock("Publish...")
        # TODO: Handle the complete target syntax for domain/repo/branch and path where products are to be deployed.
        publish(
            BTD_OUTPUT_DIR / "html",
            "https://x-access-token:%s@github.com/%s" % (environ.get("INPUT_TOKEN"), environ.get("GITHUB_REPOSITORY")),
            BTD_CFG.getKey("target"),
            "update %s" % environ.get("GITHUB_SHA"),
        )
        endBlock()

    if "pdf" in BTD_FORMATS:
        startBlock("Build PDF...")
        call(
            [
                "docker",
                "run",
                "--rm",
                "-e",
                "LATEXMKOPTS='-interaction=nonstopmode'",
                "-v",
                "%s:/src" % str(workRoot / BTD_OUTPUT_DIR / "latex"),
                BTD_IMGS["latex"],
                "make",
            ]
        )

        endBlock()


def getTheme(path: Path, url: str):
    """
    Check if the theme is available locally, retrieve it with curl and tar otherwise
    """
    tpath = path / "_theme"
    if tpath.is_dir() and (tpath / "theme.conf").is_file():
        return
    if not tpath.is_dir():
        tpath.mkdir()
    zpath = path / "theme.tgz"
    if not zpath.is_file():
        check_call(["curl", "-fsSL", url, "-o", str(zpath)])
    check_call(["tar", "--strip-components=1", "-C", str(tpath), "-xvzf", str(zpath)])
    isNonTaggedPath = tpath / "sphinx_btd_theme"
    if isNonTaggedPath.exists() and (isNonTaggedPath / "layout.html").exists():
        tmpPath = Path("tmp-theme")
        if tmpPath.is_dir():
            rmtree(str(tmpPath))
        isNonTaggedPath.rename(tmpPath)
        rmtree(str(tpath))
        tmpPath.rename(tpath)


def addCtx(idir):
    data = {}
    if "GITHUB_REPOSITORY" in environ and "GITHUB_REF" in environ:
        data["conf_py_path"] = "%s/" % Path(idir).name

        repo = environ["GITHUB_REPOSITORY"].split("/")
        data["github_user"] = repo[0]
        data["github_repo"] = repo[1]

        ref = environ["GITHUB_REF"].split("/")
        data["github_version"] = "%s/" % ref[-1]

        data["display_github"] = True

    ctx_file = Path(idir) / "context.json"
    ctx = {}
    if ctx_file.is_file():
        ctx = loads(ctx_file.open("r").read())
    ctx.update(data)
    with ctx_file.open("w") as fptr:
        dump(ctx, fptr)

    print("addCtx:", data)


# def custom_last(user=None, repo=None, cidomain='travis-ci.org'):
#    """
#    Build a custom 'Last updated on' field with CI info
#    """
#    custom = {'last': None, 'pre': None}
#
#    try:
#        # if not user or not repo:
#        # TODO: get user and repo from environment variable
#        slug = user + '/' + repo
#        commit = environ['GITHUB_SHA']
#        if not commit:
#            raise KeyError("GITHUB_SHA")
#        custom['pre'] = 'Last updated on '
#        custom['last'] = ''.join([
#            '[',
##            '<a href="https://github.com/', slug, '/commit/', commit, '">', commit[0:8], '</a>',
##            ' - ',
##            '<a href="https://', cidomain, '/', slug, '/builds/', environ['TRAVIS_BUILD_ID'], '">',
##            environ['TRAVIS_BUILD_NUMBER'], '</a>',
##            '.',
##            '<a href="https://', cidomain, '/', slug, '/jobs/', environ['TRAVIS_JOB_ID'], '">',
##            environ['TRAVIS_JOB_NUMBER'].split('.')[1], '</a>',
#            ']',
#        ])
#    except KeyError as err:
#        print('CI build info: envvar', err, 'not found or empty.')
#
#        try:
#            slug = user + '/' + repo
#            commit = environ['TRAVIS_COMMIT']
#            if not commit:
#                raise KeyError("TRAVIS_COMMIT")
#            custom['pre'] = 'Last updated on '
#            custom['last'] = ''.join([
#                '[',
#                '<a href="https://github.com/', slug, '/commit/', commit, '">', commit[0:8], '</a>',
#                ' - ',
#                '<a href="https://', cidomain, '/', slug, '/builds/', environ['TRAVIS_BUILD_ID'], '">',
#                environ['TRAVIS_BUILD_NUMBER'], '</a>',
#                '.',
#                '<a href="https://', cidomain, '/', slug, '/jobs/', environ['TRAVIS_JOB_ID'], '">',
#                environ['TRAVIS_JOB_NUMBER'].split('.')[1], '</a>',
#                ']',
#            ])
#        except KeyError as err:
#            print('CI build info: envvar', err, 'not found or empty.')
#
#    context = {}
#    if custom['pre']:
#        context['custom_last_pre'] = custom['pre']
#    if custom['last']:
#        context['custom_last'] = custom['last']
#
#    if context:
#        add2ctx(context)
