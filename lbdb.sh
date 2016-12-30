#!/bin/bash

# Wrapper (command line interface) for the lbdb.mk file.

prog=${0##*/}
makefile=${0%.sh}.mk
version=0.1
grep_options=( -i -a )

usage () {
  echo "$prog [-x] search terms"
  echo "$prog -h"
  echo "$prog -v"
}
help () {
  echo "Search the little brothers data base for a matching email address."
  echo "Options: -x for debugging, -h for help, -v for version."
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

while getopts hvx FLAG; do
  case $FLAG in
    h) usage; echo; help; exit;;
    v) echo "$prog $version"; echo "Using $(grep --version|head -n 1)"; exit;;
    x) set -x;;
    *) usage >&2; exit 2;;
  esac
done

shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
  usage >&2
  exit 2
fi

make --file "$makefile" --quiet
grep_chain "$@" < ~/.cache/lbdb/lbdb
