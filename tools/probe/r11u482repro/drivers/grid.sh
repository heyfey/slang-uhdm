#!/bin/bash
# grid.sh <bin> <tag> [VAR=val...]: runcase.sh on every case directory of this repro (explicit
# directories), the extra variables (switches) exported for our run only.
R=$(cd "$(dirname "$0")/.." && pwd)
B=$1; T=$2; shift 2
for v in "$@"; do export "$v"; done
ls -d "$R"/cases/*/*/ | sed 's#/$##' | xargs -P 3 -n 1 "$R/drivers/runcase.sh" "$B" "$T" | sort
