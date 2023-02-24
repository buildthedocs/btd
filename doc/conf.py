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
#
# For a full list of options see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

from json import loads
from pathlib import Path

# -- Project information -----------------------------------------------------

project = 'Build The Docs'
copyright = '2017-2023, BTD contributors'
author = 'BTD contributors'

# -- General configuration ---------------------------------------------------

extensions = [
    'sphinx.ext.extlinks',
]

exclude_patterns = [
    'deprecated',
    '_build',
    'Thumbs.db',
    '.DS_Store'
]

# -- Options for HTML output -------------------------------------------------

html_static_path = ['_static']

html_logo = str(Path(html_static_path[0]) / 'logo.png')
html_favicon = str(Path(html_static_path[0]) / 'logo.png')

html_theme_options = {
    'logo_only': True,
    'home_breadcrumbs': False,
    'vcs_pageview_mode': 'blob',
}

html_context = {}
ctx = Path(__file__).resolve().parent / 'context.json'
if ctx.is_file():
    html_context.update(loads(ctx.open('r').read()))

html_theme_path = ["."]
html_theme = "_theme"

# -- Sphinx.Ext.ExtLinks -----------------------------------------------------

extlinks = {
    'gh': ('https://github.com/%s', 'gh:%s'),
    'btdsharp': ('https://github.com/buildthedocs/btd/issues/%s', '#%s'),
    'btdrepo':   ('https://github.com/buildthedocs/btd/blob/main/%s', None),
}
