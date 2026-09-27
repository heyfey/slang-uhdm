#!/bin/bash
# rows.sh <workdir> <corpus> <regex of test names>: run verify_golden.py (both modes) on the named rows with the binary
# in SLANG_UHDM; refuses a regex that could name a fenced test (every fenced name is tested against the regex).
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
W=$1; C=$2; RX=$3; REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)
for f in $FENCED; do python3 -c "import re,sys; sys.exit(0 if re.search(sys.argv[1], sys.argv[2]) else 1)" "$RX" "$f" && { echo "rows.sh: regex matches a fenced name: refused"; exit 4; }; done
mkdir -p $W; cd $REPO
python3 scripts/verify_golden.py --corpus $C --mode both --jobs 3 --filter "$RX" --out $W/$C.csv --workdir $W/$C > $W/$C.log 2>&1
cat $W/$C.csv
