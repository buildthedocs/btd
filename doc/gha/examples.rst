.. program:: btd

.. _btd:examples:

Examples
########

:gh:`ghdl/ghdl-cosim` showcases the typical usage of BTD.

In :gh:`ghdl/ghdl`, a different HTML documentation generator is executed before BTD.
The content to be included in the final site is placed in a subdir, which is specified in the Sphinx configuration file
(``doc.py``).
For instance:

.. code-block::

    html_extra_path = [str(Path(__file__).resolve().parent.parent / 'public')]

See `html_extra_path <https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-html_extra_path>`_.
