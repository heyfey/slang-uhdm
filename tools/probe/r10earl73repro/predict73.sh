#!/usr/bin/env bash
# r10earl73 — PREDICT the mover set of § ovActReduceIntOp73 from the PRISTINE
# databases, BEFORE the patched sweeps exist (RESUME §7).
#
# The law can only ever move a param_assign Rhs CONSTANT's vpiConstType /
# value TAG (and, for a vpiIntConst, its digits, which adjustSize no longer
# masks).  So a database can move TO golden only if golden and our pristine
# database already DISAGREE on the (ct, tag) of some param_assign Rhs
# constant.  This lists exactly those databases, with the disagreement count
# and the golden->ours shape, straight off the pristine artifacts.
#
# A database that moves in the byte sweep but is NOT listed here moved AWAY
# from golden or sideways — that is the signal this predictor exists to give.
#
# MEASUREMENT ONLY.  usage: predict73.sh <sweep-workdir> <pacen73> [jobs]
set -u
W=${1:?sweep workdir}; CEN=${2:?pacen73 binary}; J=${3:-4}
[ -x "$CEN" ] || { echo "FATAL: no census binary $CEN"; exit 9; }
export CEN
export FENCE_RE
# FENCED: the four slang-fenced corpus tests are never dispatched and never
# NAMED by this pass -- canaudit.sh is the one file allowed to spell them, so
# the skip regex is read OUT OF canaudit.sh at run time (naming them here would
# be a FENCE-BREACH).  This scanner only READS databases a sweep already wrote;
# it skips them anyway so no artifact of this pass can carry their names.
FENCE_RE=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$(dirname "$0")/canaudit.sh" | tr ' ' '|')
scan() {
  db=$1; d=$(dirname "$db")
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$db" | grep -Eq "$FENCE_RE"; then
    echo "FENCED-SKIP <one of the four slang-fenced tests>"
    return
  fi
  g=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)/golden.uhdm
  [ -f "$g" ] || { echo "NOGOLD ${db}"; return; }
  "$CEN" "$g"  2>/dev/null | sed 's/ dec=[^ ]*//; s/ sz=[^ ]*//; s/ val=\([A-Z]*\):[^ ]*/ tag=\1/; s/ ts=[^ ]*//; s/ tssgn=[^ ]*//; s/ lts=[^ ]*//; s/ lsgn=[^ ]*//; s/ lsz=[^ ]*//' | sort > /tmp/.r73g.$$
  "$CEN" "$db" 2>/dev/null | sed 's/ dec=[^ ]*//; s/ sz=[^ ]*//; s/ val=\([A-Z]*\):[^ ]*/ tag=\1/; s/ ts=[^ ]*//; s/ tssgn=[^ ]*//; s/ lts=[^ ]*//; s/ lsgn=[^ ]*//; s/ lsz=[^ ]*//' | sort > /tmp/.r73o.$$
  c=$(diff /tmp/.r73g.$$ /tmp/.r73o.$$ | grep -c '^[<>].*constant' || true)
  rm -f /tmp/.r73g.$$ /tmp/.r73o.$$
  [ "${c:-0}" -gt 0 ] && echo "CAND $c ${db}"
  return 0
}
export -f scan
find "$W" -name 'slang.uhdm' | sort | xargs -P "$J" -I{} bash -c 'scan "$@"' _ {} 2>/dev/null
