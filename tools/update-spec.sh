
set -e

bin=./bin/specs.coffee

set -- specs.rst specs-new.rst


$bin --specs rst > $2

diff -bq $1 $2 >/dev/null && {

  echo "No updates"
  exit 0
}

$bin --verify $1 || {
  echo "Error reading specs doc" >&2
  exit 1
}

$bin --verify $2 && {

  rst2pseudoxml.py --exit-status=2 $2 /dev/null && {

    $bin --update $1 $2 && {

      git diff -q $1 && {

        echo "Updated specs doc"
        $bin $1 --refs > spec-index.rst

      } || {
        echo "No updates"
        exit 0
      }
    } || {
      echo "Error updating specs doc" >&2
      exit 1
    }
  } || {
    echo "Invalid rSt produced" >&2
    exit 1
  }
} || {
  echo "Invalid specs doc produced" >&2
  exit 1
}

