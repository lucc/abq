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
  cat <<-EOF
	Usage: $prog [-x] search terms
	       $prog -c
	       $prog -r
	       $prog -s
	       $prog -h
	       $prog -v
	EOF
}
help () {
  cat <<-EOF
	Search the little brothers data base for a matching email address.
	Options: -x for debugging, -h for help, -v for version.
	With -c the cache is cleared, with -r the cache is rebuild explicitly
	(it is normally checked on each query). The -s option prints some
	cache statistics.
	Search terms are used by grep(1) in case insensitive mode.
	EOF
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

while getopts chrsvx FLAG; do
  case $FLAG in
    c) echo Clearing cache... >&2; make "${make_options[@]}" clear-cache; exit;;
    h) usage; echo; help; exit;;
    r) echo Rebuilding cache... >&2; make "${make_options[@]}" rebuild; exit;;
    s) echo Statistics:; make "${make_options[@]}" cache-statistics; exit;;
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
