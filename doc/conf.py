# For a full list of options see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

from json import loads
from pathlib import Path

# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'Build The Docs'
copyright = '2018-2020, BTD contributors'
author = 'BTD contributors'


# -- General configuration ---------------------------------------------------

extensions = [
    'sphinx.ext.extlinks',
]

templates_path = ['_templates']

# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['deprecated', '_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

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
    'gh': ('https://github.com/%s', ''),
    'btdsharp': ('https://github.com/buildthedocs/btd/issues/%s', '#'),
    'btdrepo':   ('https://github.com/buildthedocs/btd/blob/master/%s', None),
}
