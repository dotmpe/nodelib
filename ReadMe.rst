Nodelib
=======
:Version: 0.0.5-dev+20150718-1849
:Status: Development
:project:

  .. image:: https://secure.travis-ci.org/dotmpe/nodelib.png
    :target: https://travis-ci.org/dotmpe/nodelib
    :alt: Build

:repository:

  .. image:: https://badge.fury.io/gh/dotmpe%2Fnodelib.png
    :target: http://badge.fury.io/gh/dotmpe%2Fnodelib
    :alt: GIT



Package contents
----------------
src/
  node/
    context.coffee
      A context object to hold properties and create sub-contexts.
    index.coffee
      ..

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
  - Metadata for documentation browser sitefile_

reader.rst
  - For use with sitefile_

Makefile
  - Nothing much.


----

.. _sitefile: http://github.com/dotmpe/node-sitefile


