Package contents
----------------
src/
  node/
    Source-code in coffeescript for nodelib.

    .. figure:: assets/nodelib.svg
       :alt: Internal Javascript dependencies in nodelib

       All modules in nodelib.

    context.coffee
      A context object to hold properties and create sub-contexts.

test/
  jasmine/
    Jasmine tests for ``src/``.

.versioned-files.list
  - A plain text list of paths that have version tags embedded.
  - The first path contains the canonical tags.

lib/git-versioning.sh
  - Shell script functions library.

bin/
  cli-version.sh
    - Command-line facade for lib/git-versioning functions.

tools/
  pre-commit.sh
    - GIT pre-commit hook Shell script.
    - Updates embedded metadata and add modified files to GIT staging area.
      FIXME: if triggered, need a trigger

  version-check.sh
    - Default check greps all metadata files to verify versions all match.

package
  .json
    - NPM standard project metadata file.
  .yaml
    - Another currently meaningless project metadata file.

Sitefile.yaml
  - Metadata for documentation browser sitefile


Project files inter-dependencies (javascript/css only):

.. image:: assets/nodelib-dev.svg
   :alt: javascript files in nodelib

Would be interesting to have references in other domains: metadata,
documentation, or grunt/gulp/make.
