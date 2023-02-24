# For a full list of options see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'Build The Docs'
copyright = '2018-2020, BTD contributors'
author = 'BTD contributors'


# -- General configuration ---------------------------------------------------

extensions = [
]

templates_path = ['_templates']

# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['deprecated', '_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------

try:
    import divio_docs_theme
except ModuleNotFoundError:
    html_theme = 'alabaster'
else:
    html_theme = 'divio_docs_theme'
    html_theme_path = [divio_docs_theme.get_html_theme_path()]
    # html_theme_options = {
    #     'show_cloud_banner': True,
    #     'cloud_banner_markup': """
    #         <div class="divio-cloud">
    #             <span class="divio-cloud-caption">Cloud management by Divio</span>
    #             <p>If you like our attitude to documentation, you'll love the way we do cloud management.</p>
    #             <a class="btn-neutral divio-cloud-btn" target="_blank" href="https://goo.gl/nHv16j">Talk to us</a>
    #         </div>
    #     """,
    # }

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']
