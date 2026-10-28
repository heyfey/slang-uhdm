#!/bin/bash
# probedump.sh <new probe dir> <control probe dir> <out list>: path-normalized dump compare
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || exit 2
norm(){ "$D" "$1" 2>&1 | sed -E 's#(/tmp/wt_[a-z0-9]+|/home/heyfey/git-repos/slang-uhdm)/##g; s#/tmp/[A-Za-z0-9_]+/probe/##g' | grep -v -E '^(Elapsed|Restored)'; }
export -f norm; export D
cd "$1" && ls *.uhdm | xargs -P 3 -I{} bash -c 'cmp -s <(norm "{}") <(norm "'"$2"'/{}") || echo "MOVER {}"' > "$3"
echo "movers=$(grep -c MOVER $3) of $(ls *.uhdm | wc -l)"
