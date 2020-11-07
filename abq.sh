#!/usr/bin/env bash

# Wrapper (command line interface) for the abq.mk file.

set -eu

prog=${0##*/}
makefile=${0%.sh}.mk
version=0.3
grep_options=( --ignore-case --text )
make_options=( --quiet --file "$makefile" )
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

# Grep for the logical AND of several search terms.  This is not possible with
# plain grep (or plain regex) which only provide logical OR.
grep_chain () {
  if [[ $# -eq 1 ]]; then
    grep "${grep_options[@]}" --regexp="$1"
  else
    local pattern=$1
    shift
    grep "${grep_options[@]}" --regexp="$pattern" | grep_chain "$@"
  fi
}

while getopts chvx FLAG; do
  case $FLAG in
    c) echo Clearing cache. >&2; make "${make_options[@]}" clear-cache; exit;;
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
  make_options=( "${make_options[@]/--quiet/--debug}" )
fi

make \
  --no-builtin-rules \
  --no-builtin-variables \
  "${make_options[@]}"
grep_chain "$@" < ~/.cache/abq/abq
