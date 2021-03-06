#!/bin/sh
set -e
lname=nodelib
grep -v '^dist' \
  | grep -v '\<TODO\>\.\<txt\>' \
  | grep -v '\<TODO\>\.\<list\>' \
  | grep -Ev '\<'"$lname"'\>.\<no[-]?check\>' \
  | grep -Ev '\<tasks\>.\<no[-]?check\>' \
  | grep -v '\<tasks\>.\<ignore\>' \
  | while IFS=: read srcname linenr comment
do
  grep -q '\<tasks\>.\<ignore\>.\<file\>' $srcname ||
  # Preserve quotes so cannot use echo/printf w/o escaping. Use raw cat.
  { cat <<EOM
$srcname:$linenr: $comment
EOM
  }
done
# Id: script-mpe/0.0.3-dev tools/sh/tags-filter.sh
