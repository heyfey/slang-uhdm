#!/usr/bin/env bash
# r11u65 — for every arm of a sweep workdir, list the DEF-VIEW net names its
# database carries, as `<mode>/<armdir> <netname>`.  Feeds predict65.py's
# intersection: a name the PRISTINE database does not hold as a def-view net
# cannot move.  Reads databases only; runs no binary.
# usage: netnames65.sh <workdir> [<dbname>]   (dbname default slang.uhdm)
set -u
WD=${1:?workdir}
DB=${2:-slang.uhdm}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
for f in "$WD"/*/*/"$DB"; do
  [ -f "$f" ] || continue
  d=$(dirname "$f")
  key="$(basename "$(dirname "$d")")/$(basename "$d")"
  "$HERE/netcen65" --list "$f" 2>/dev/null |
    awk -F'|' -v k="$key" '$1=="DEF"{print k, $3}'
done
