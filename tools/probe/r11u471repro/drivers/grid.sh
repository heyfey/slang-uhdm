#!/bin/bash
# grid.sh <tag> <bin>: runcase.sh on every case dir of this repro (pristine first, then the law binary);
# writes one line per case dir (exit code, uhdm-cmp lines, strict verdict, dump distance, md5).
H=$(cd "$(dirname "$0")/.." && pwd)
for c in "$H"/cases/*/*/; do bash "$H/drivers/runcase.sh" "$2" "$1" "$c"; done
