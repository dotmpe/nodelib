#!/bin/sh
set -e


resolve_prefix_element()
{
  test -n "$3" || set -- "$1" "$2" ":"
  while test $1 -gt 1
  do
    set -- "$(( $1 - 1 ))" "$(echo "$2" | sed "s/^[^$3]*$3\\(.*\\)$/\\1/" )" "$3"
  done
  echo "$2" | sed "s/^\\([^$3]*\\)$3.*$/\\1/"
}

# Resolve line span (start line - line count)
resolve_lines()
{
  test -n "$3" || set -- "$1" "$2" "1"
  head -n $2 "$1" | tail -n $3
}

grep_or()
{
  echo "'\\($( echo $@ | sed 's/ /\\|/g' )\\)'"
}


. .package.sh


tags="$(echo $(
  typeset | grep package_pd_meta_tasks_tags__ | sed 's/^[^=]*=//g'
))"


npm run src-files | while read f
do
  test -n "$f" || continue
  test -f "$f" || continue; # npm run outputs garbage and has no options?

  eval grep -q $(grep_or $tags) $f || continue

  radical.py --issue-format=full-sh $f 2>/dev/null | while read ref
  do
    test -n "$ref" || continue

    prefix=$(resolve_prefix_element 1 "$ref" )
    file=$(resolve_prefix_element 2 "$ref" )
    line_span=$(resolve_prefix_element 3 "$ref" )
    descr_span=$(resolve_prefix_element 4 "$ref" )
    line_descr_span=$(resolve_prefix_element 5 "$ref" )
    cmnt_span=$(resolve_prefix_element 6 "$ref" )
    line_cmnt_span=$(resolve_prefix_element 7 "$ref" )
    descr="$(resolve_prefix_element 8 "$ref" )"

    echo "$prefix:$file:$line_span ref='$ref'"

    #resolve_lines "$file" $(echo $line_span | tr '-' ' ')

  done
  printf "." >&2
done

