#!/bin/sh
set -e
test -n "$1" || set -- build/js/lib "$2"
test -n "$2" && set -- "$1" "$2" "$2:test" || set -- "$1" "" "test"

# [2017-10-31] Rewriting paths in madge output/graphviz DOT to something more pretty

dir_alias()
{
  test -n "$1" || set -- / "$2" "$3"
  test "$1" = "/" || set -- "$1:" "$2" "$3"
  test -n "$3" || set -- "$1" "$2" 1
  local dir=$(dirname "$(printf "$2" | cut -d '/' -f $3-)")/
  test "$dir" = "./" && dir=""
  echo "$1$dir$(basename "$2" .js)"
}
npm_alias()
{
  test -n "$1" || set -- / "$2"
  test "$1" = "/" || set -- "$1:" "$2"
  echo "$1$(echo "$2" | sed 's/^[^\(node_modules\)]*node_modules\/\([^/]*\)\/.*/\1/g')"
}
alias_path()
{
  case "$1" in
    src/node/* ) dir_alias "$3" "$1" 3 ;;
    test/* ) dir_alias "$4" "$1" 2 ;;
    */node_modules/* ) npm_alias npm "$1" ;;
    #* ) echo "$(dirname "$1")/$(basename "$1" .js)" ;;
    * ) dir_alias "" "$1" 1 ;;
  esac
}

{ echo 'digraph G {'

grep ';' |
 sed 's/[";]//g' |
 while read node arc node2
do
  test -n "$arc" && {
    printf -- "\"$(alias_path "$node" "$@")\" $arc \"$(alias_path "$node2" "$@")\";\n"
  } || {
    printf -- "\"$(alias_path "$node" "$@")\";\n"
  }
done

echo '}'
}
