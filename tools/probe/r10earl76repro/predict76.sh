#!/usr/bin/env bash
# r10earl76 — PREDICT THE MOVER SET BY NAME, from the PRISTINE databases alone,
# BEFORE the patched sweep exists.  MEASUREMENT ONLY.
#
# § genScopeProcLoopCtrlNoFold76 can only ever replace a `constant` that ALREADY
# EXISTS in the pristine database and that sits
#   * inside an `always` / `initial` / `final` written in a GENERATE SCOPE
#     (owner is a process AND gd>=1 in the cscen76 census), and
#   * on a ROUTE that passes through a FOR STATEMENT (`for:i`, `for:c`, `for:n`,
#     `for:b`) or a LOOP CONTROL (`whl:c`, `dow:c`, `rpt:c`),
# and whose folded symbol is an UNQUALIFIED read of an IMPORTED PACKAGE
# parameter (the `scope->kind == Package` branch plus the no-`::` gate).
#
# The last condition is NOT recorded in the database, so stage 1 is a deliberate
# OVER-approximation on the first two; stage 2 reads the SOURCE of every stage-1
# hit and refutes the ones with no package import at all.  Nothing else in
# either corpus can move: the law writes no new statement, touches no typespec,
# and its only effect is constant -> ref_obj+enum_const at those routes.
#
# STAGE 3 (run by hand on whatever stage 2 keeps): read the flagged constants'
# own SHAPE.  A fold of a package parameter is a SIZED constant (the parameter's
# declared width, 32 for `parameter int`); a bare unsized loop bound is Surelog's
# `sz=64`.  A candidate whose flagged cells are all `sz=64` cannot be this law's:
#   cscen76 <db.uhdm> | grep -E '^C [^ ]+ (always|initial|final) [^ ]+ ST[^ ]*(for:|whl:c|dow:c|rpt:c)' \
#     | grep -E 'gd=[1-9]' | sed 's/ ||.*//' | awk '{print $10,$11}' | sort | uniq -c
#
#   usage:          CSCEN76=<bin> predict76.sh <sweep-workdir> [label]
#   stage 2 only:   STAGE2=1 CSCEN76=<bin> predict76.sh <sweep-workdir> [label] < <stage-1 output>
set -u
W=${1:?workdir}; L=${2:-$W}
CEN=${CSCEN76:?set CSCEN76}
RE=' [^ ]+ (always|initial|final) [^ ]+ ST[^ ]*(for:|whl:c|dow:c|rpt:c)[^ ]* gd=[1-9]'
if [ "${STAGE2:-0}" != "1" ]; then
  n=0; hit=0
  while IFS= read -r db; do
    n=$((n+1))
    c=$(LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$CEN" "$db" 2>/dev/null \
        | { grep -cE "^C$RE"; true; })
    [ "${c:-0}" -gt 0 ] && { hit=$((hit+1)); echo "CANDIDATE $c $db"; }
  done < <(find "$W" -name '*.uhdm' ! -name 'golden.uhdm' | sort)
  echo "$L: scanned=$n flagged=$hit"
  exit 0
fi
# STAGE 2 — refute by SOURCE.  A test whose sources contain no `import <pkg>::`
# at all cannot satisfy the package-parameter gate for any constant, whatever
# stage 1 flagged.
#
# THE SOURCES ARE NOT IN `cmds.txt`.  A workdir holds only `cmds.txt` and
# `slang.uhdm`, and the command line inside it names its sources RELATIVELY
# (`dut.sv`, `-f lowrisc_systems_top_earlgrey_0.1.scr`) against a test directory
# it does not record.  Two wrong versions of this stage were written and are
# recorded so they are not written again: grepping the WORKDIR refuted every
# candidate (there is no source there at all), and grepping only the absolute
# `.sv` tokens on the `slang:` line refuted Earlgrey_0_1, whose whole design is
# behind a `-f` filelist.  What works is to resolve the TEST DIRECTORY by NAME
# — the workdir basename is `<TestName>-<hash>` — under the two corpus roots,
# and to grep that directory recursively.  A candidate whose directory cannot be
# located is reported UNKNOWN and KEPT; stage 2 may only ever refute on positive
# evidence.
ROOTS="$HOME/git-repos/uhdm2rtlil/test $HOME/git-repos/Surelog/tests
       $HOME/git-repos/Surelog/third_party/tests"
while IFS= read -r line; do
  case $line in CANDIDATE*) ;; *) continue;; esac
  db=${line##* }
  wd=$(dirname "$db"); base=$(basename "$wd"); name=${base%-*}
  # uhdm2rtlil names a DIRECTORY; the Surelog suite names a `<Name>.sl` FILE
  # whose directory holds the sources (several tests can share one directory,
  # which only ever makes this stage KEEP more, never refute more).
  d=""
  for r in $ROOTS; do
    [ -d "$r" ] || continue
    d=$(find "$r" -maxdepth 4 -type d -name "$name" 2>/dev/null | head -1)
    [ -n "$d" ] && break
    f=$(find "$r" -maxdepth 4 -type f -name "$name.sl" 2>/dev/null | head -1)
    [ -n "$f" ] && { d=$(dirname "$f"); break; }
  done
  if [ -z "$d" ]; then echo "UNKNOWN $db  (test directory for '$name' not located -- KEPT)"; continue; fi
  if grep -rqE '(^|[^a-zA-Z_0-9])import[ \t]+[A-Za-z_][A-Za-z_0-9]*::' "$d" 2>/dev/null; then
    echo "KEEP    $db  ($d has a package import)"
  else
    echo "REFUTED $db  (no package import anywhere under $d)"
  fi
done
