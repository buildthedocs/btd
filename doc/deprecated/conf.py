# -*- coding: utf-8 -*-

import sys
import os
import shlex
import re
import subprocess

from os.path import abspath, isfile

# http://docs.readthedocs.io/en/latest/getting_started.html#in-markdown
from recommonmark.parser import CommonMarkParser
source_parsers = { '.md': CommonMarkParser, }

sys.path.insert(0, abspath('.'))
sys.path.insert(0, abspath('_extensions'))

# -- General configuration ------------------------------------------------

needs_sphinx = '1.5'

extensions = [
    # Standard Sphinx extensions
    'sphinx.ext.extlinks',
    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
    'sphinx.ext.graphviz',
    'sphinx.ext.mathjax',
    'sphinx.ext.ifconfig',
    'sphinx.ext.viewcode',
    # 'sphinx.ext.githubpages',
    # SphinxContrib extensions
    # 'sphinxcontrib.textstyle',
    # 'sphinxcontrib.spelling',
]

source_suffix = ['.rst', '.md']

master_doc = 'index'

project = u'BTD'
copyright = u'2018, Build The Docs'
author = u''

version = "0.0"    # The short X.Y version.
release = version  # The full version, including alpha/beta/rc tags.

language = None

# There are two options for replacing |today|: either, you set today to some non-false value, then it is used:
#today = ''
# Else, today_fmt is used as the format for a strftime call.
#today_fmt = '%B %d, %Y'

exclude_patterns = []

pygments_style = 'stata-dark'

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = True
todo_link_only = True

# reST settings
prologPath = "prolog.inc"
try:
    with open(prologPath, "r") as prologFile:
        rst_prolog = prologFile.read()
except Exception as ex:
    print("[ERROR:] While reading '{0!s}'.".format(prologPath))
    print(ex)
    rst_prolog = ""

# -- Options for HTML output ----------------------------------------------

html_theme_path = ["."]
html_theme = "btd.sphinx.theme"

html_context = {
    # Override default css
    # 'css_files': [
    #     '_static/theme_overrides.css',
    # ]
}

html_context = {
    'use_gfonts': True,
    'display_github': True,
    'slug_user': 'buildthedocs',
    'slug_repo': 'btd',
    'slug_path': 'master/doc/',
    'description': 'Build the Docs',
    'current_version': 'master'
}

# Add display_github and VERSIONING data
if isfile('context.json'):
    from json import loads
    data = loads(open('context.json').read())
    html_context.update(data)

html_theme_options = {
    'style_nav_header_background': '#e7e7e7ff',
    'logo_only': True,
    'home_breadcrumbs': False,
    # 'home_logo': False,
    'prevnext_location': 'bottom'
}

# html_title = None # Defaults to "<project> v<release> documentation".
# html_short_title = None
# html_logo = None
# html_favicon = None

html_static_path = ['_static']

# If not '', a 'Last updated on:' timestamp is inserted at every page bottom,
# using the given strftime format.
html_last_updated_fmt = '%b %d, %Y'

# If false, no module index is generated.
#html_domain_indices = True

# If false, no index is generated.
#html_use_index = True

# If true, the index is split into individual pages for each letter.
#html_split_index = False

# If true, links to the reST sources are added to the pages.
#html_show_sourcelink = True

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
#html_show_sphinx = True

# If true, "(C) Copyright ..." is shown in the HTML footer. Default is True.
#html_show_copyright = True

# Output file base name for HTML help builder.
htmlhelp_basename = 'BTDdoc'

# -- Options for LaTeX output ---------------------------------------------

latex_elements = {
    'papersize': 'a4paper',
    'pointsize': '10pt',
    # 'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title, author, documentclass [howto, manual, or own class]).
latex_documents = [
  ('index', 'BTD.tex', u'BTD Documentation', [author], 'manual'),
]

# -- Options for manual page output ---------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (master_doc, 'btd', u'BTD Documentation', [author], 1)
]

# If true, show URL addresses after external links.
# man_show_urls = False

# -- Options for Texinfo output -------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author, dir menu entry, description, category)
texinfo_documents = [
  (master_doc, 'BTD', u'BTD Documentation', author, 'BTD', 'Build The Docs.', 'Miscellaneous'),
]

# -- Sphinx.Ext.ExtLinks --------------------------------------------------

extlinks = {
   'wikipedia': ('https://en.wikipedia.org/wiki/%s', None),
   'btdsharp': ('https://github.com/buildthedocs/btd/issues/%s', '#'),
   'btdissue': ('https://github.com/buildthedocs/btd/issues/%s', 'issue #'),
   'btdpull':  ('https://github.com/buildthedocs/btd/pull/%s', 'pull request #'),
   'btdsrc':   ('https://github.com/buildthedocs/btd/blob/master/btd/%s', None)
}
