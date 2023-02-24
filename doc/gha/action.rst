.. program:: btd

Docker GitHub Action
####################

The most straightforward usage of BTD is as a GitHub Action. Three options are accepted:

- ``config``: path to the BTD configuration file (default ``.btd.yml``).
- ``token``: token for making authenticated API calls (optional, ``${{ github.token }}`` is available by default).
- ``skip-deploy``: whether to push the docs or to just build them.

.. code-block:: yaml

    - uses: buildthedocs/btd@v0
      with:
        token: ${{ github.token }}

See a complete workflow in :ref:`btd:workflow`.

.. IMPORTANT:: If parameter ``token`` is not provided, the Action will try to upload the results (typically to branch
  ``gh-pages``) using the default token.
  Use ``skip-deploy`` to prevent results being uploaded.
