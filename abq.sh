#!/bin/bash

# Wrapper (command line interface) for the abq.mk file.

set -eu

prog=${0##*/}
makefile=${0%.sh}.mk
version=0.3
grep_options=( --ignore-case --text )
debug=false

usage () {
  echo "$prog [-x] search terms"
  echo "$prog -c"
  echo "$prog -h"
  echo "$prog -v"
}
help () {
  echo "Search the little brothers data base for a matching email address."
  echo "Options: -x for debugging, -h for help, -v for version."
  echo "With -c the cache is cleared."
  echo "Search terms are used by grep(1) in case insensitive mode."
}
grep_chain () {
  if [[ $# -eq 1 ]]; then
    grep "${grep_options[@]}" "$1"
  else
    local pattern=$1
    shift
    grep "${grep_options[@]}" "$pattern" | grep_chain "$@"
  fi
}

while getopts chvx FLAG; do
  case $FLAG in
    c) echo Clearing cache. >&2; make --file "$makefile" clear-cache --quiet; exit;;
    h) usage; echo; help; exit;;
    v) echo "$prog $version"; echo "Using $(grep --version|head -n 1)"; exit;;
    x) debug=true; set -x;;
    *) usage >&2; exit 2;;
  esac
done

shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
  usage >&2
  exit 2
fi

if "$debug"; then
  make_options=( --debug )
else
  make_options=( --quiet )
fi

make \
  --no-builtin-rules \
  --no-builtin-variables \
  --file "$makefile" \
  "${make_options[@]}"
grep_chain "$@" < ~/.cache/abq/abq
