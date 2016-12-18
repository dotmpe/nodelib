#!/bin/sh
set -e

{
  cat <<EOF
prefix:file:123:<4>:<5>:<6>:<7>:<8>:<9>:<10>: Comment
:test/mocha/module.coffee:85-1
:test/mocha/module.coffee:90-
:test/mocha/module.coffee:96
:src/node/route.coffee:8
EOF
} | while read ref
do

  prefix=$(resolve_ref_element 1 "$ref" )
  file=$(resolve_ref_element 2 "$ref" )
  line_range=$(resolve_ref_element 3 "$ref" )
  line_span=$(resolve_ref_element 4 "$ref" )
  descr_range=$(resolve_ref_element 5 "$ref" )
  descr_span=$(resolve_ref_element 6 "$ref" )
  line_descr_span=$(resolve_ref_element 7 "$ref" )
  cmnt_range=$(resolve_ref_element 8 "$ref" )
  cmnt_span=$(resolve_ref_element 9 "$ref" )
  line_cmnt_span=$(resolve_ref_element 10 "$ref" )
  descr="$(resolve_ref_element 11 "$ref" )"

  test -e "$file" && {
    test -z "$line_range" \
      || resolve_lines "$file" $(echo $line_range | tr '-' ' ')
    test -z "$descr_range" \
      || resolve_chars "$file" $(echo $descr_range | tr '-' ' ')
    test -z "$cmnt_range" \
      || resolve_chars "$file" $(echo $cmnt_range | tr '-' ' ')
  } || printf ""
done

