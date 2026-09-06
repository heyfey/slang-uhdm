#!/usr/bin/env bash
# r10uvm173repro/census173.sh — THE CORPUS CENSUS, golden vs pristine vs patched,
# over the databases the prediction named.  MEASUREMENT ONLY; the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  LHS is ALWAYS golden.
#
#   census173.sh <pristine workdir> <patched workdir> <out dir> [name ...]
#
# For every <mode>/<name>-<hash>/ directory present in BOTH workdirs it runs
# ct173bind on the GOLDEN database (read out of that run's own cmds.txt, so the
# census cannot silently score against the wrong golden), on the PRISTINE
# database and on the PATCHED one, then scores the three with score173.py.
#
# GUARDS: a missing side prints SKIP-NOFILE and is COUNTED; the golden cache
# DIRECTORY is turned into .../golden.uhdm (handing a directory to a reader
# reads nothing); a name that matches no directory prints UNKNOWN-NAME and is
# COUNTED.  A driver that reaches nothing must never read as perfection.
set -u
PW=${1:?pristine workdir}
QW=${2:?patched workdir}
OUT=${3:?out dir}
shift 3
BIND=${CT173BIND:-/tmp/r10uvm173_scratch/ct173bind}
SCORE=${SCORE173:-$(dirname "$0")/score173.py}
[ -x "$BIND" ] || { echo "FATAL: no ct173bind at $BIND"; exit 3; }
[ -f "$SCORE" ] || { echo "FATAL: no score173.py at $SCORE"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$OUT"
miss=0; unk=0; done_=0
printf "%-46s %-9s %s\n" TEST MODE "TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / UNMOVED-OK"
for n in "$@"; do
  seen=0
  for mode in default testflags; do
    for d in "$PW/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      seen=1
      base=$(basename "$d")
      q="$QW/$mode/$base"
      P="$d/slang.uhdm"; Q="$q/slang.uhdm"; C="$d/cmds.txt"
      G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$P" ] || [ ! -f "$Q" ]; then
        printf "%-46s %-9s %s\n" "$n" "$mode" "SKIP-NOFILE(g=${G:-none})"
        miss=$((miss+1)); continue
      fi
      W="$OUT/$n.$mode"; mkdir -p "$W"
      for pair in "$G:g" "$P:a" "$Q:b"; do
        f=${pair%%:*}; tg=${pair#*:}
        # score173.py reads one file per (side, view); the corpus databases are
        # single-view, so the DEF slot carries it and the ELAB slot is empty.
        "$BIND" "$f" --rows 2>/dev/null | sed "s/^/[$tg.def] /" > "$W/bind.$tg.def.txt"
        : > "$W/bind.$tg.elab.txt"
      done
      # r10v173 (verifier) — PRINT BOTH SCORINGS.  The README's §4 mover table
      # is the SPAN-BLIND MULTISET reading (`--nospan`, no `--setmode`); this
      # driver originally printed only the span-KEYED bucket-membership one, so
      # an operator following §9 saw SimpleUVM AWAY-GOLDEN=4, SeqDriver 19,
      # Earlgrey_0_1/default 6 and EvalFuncNamed 1 where the README says 0, and
      # had no way to tell an evidence mismatch from a regression.  Both lines
      # are printed now, neither is hidden:
      #   NOSPAN  — the README's number; the span differences are R2
      #             (`uvm_hdl_concat2string`'s macro buffers) and no generated
      #             `Compare` reads a span.
      #   SETMODE — bucket membership, span-keyed; its residual AWAY cells are
      #             R4 (golden's def listing carries ONE call at ONE span twice
      #             and binds one copy each way; both binaries put both copies
      #             on one twin, so each gets exactly one of the two right —
      #             every AWAY name here also appears as a TO-GOLDEN name).
      rn=$(python3 "$SCORE" "$W" --view def --only PKGDEF --nospan | tail -1)
      r=$(python3 "$SCORE" "$W" --view def --only PKGDEF --setmode | tail -1)
      printf "%-46s %-9s NOSPAN  %s\n" "$n" "$mode" "$rn"
      printf "%-46s %-9s SETMODE %s\n" "$n" "$mode" "$r"
      done_=$((done_+1))
    done
  done
  [ "$seen" -eq 0 ] && { printf "%-46s %-9s %s\n" "$n" - UNKNOWN-NAME; unk=$((unk+1)); }
done
echo "-- scored=$done_  SKIP-NOFILE=$miss  UNKNOWN-NAME=$unk"
