#!/bin/bash
# v11u304 bytecmp.sh <workdirA> <workdirB> <probe|downstream>: byte comparison of the probe databases
# (<wd>/probe/*.uhdm) or the downstream lane's slang databases (<wd>/downstream/<test>/slang.uhdm) of two
# sweeps; the path list is built first and filtered by $FENCED (word boundary) before any file is opened.
# Prints the path-set check, every mover, `MOVERS n / N` and a self-check (every file vs one fixed file).
source "$(dirname "$0")/env.sh" || exit 3
A=$1; B=$2; K=$3
case $K in probe) sub=probe; pat='*.uhdm';; downstream) sub=downstream; pat='slang.uhdm';; *) exit 2;; esac
la=$(mktemp); lb=$(mktemp)
(cd $A/$sub && find . -name "$pat" | sort) | grep -vP "$FENCERE" > $la
(cd $B/$sub && find . -name "$pat" | sort) | grep -vP "$FENCERE" > $lb
cmp -s $la $lb && echo "PATH_SETS_IDENTICAL ($(wc -l < $la))" || { echo PATH_SETS_DIFFER; diff $la $lb | head; }
m=0; while read -r p; do cmp -s "$A/$sub/$p" "$B/$sub/$p" || { echo "MOVER $p"; m=$((m+1)); }; done < $la
echo "MOVERS $m / $(wc -l < $la)"
ref=$(head -1 $la); bad=0; while read -r p; do cmp -s "$A/$sub/$p" "$B/$sub/$ref" || bad=$((bad+1)); done < $la
echo "SELFCHECK $bad / $(wc -l < $la) flagged"
rm -f $la $lb
