#!/bin/bash
# v11u210 (copied from r11u210 drivers/switchreach.sh): the landing-201 switch reach check (§ landingSwitchReach210).  For every case dir (dut.sv) under the given
# roots, export it with the law binary in four states and compare the databases byte for byte:
#   ON  : no switch
#   L201: R11U210_LANDING201_OFF=1                       (the new switch: landing 201's whole ground-A state)
#   SUM : R11U201_OFF R11V201_OFF R11U200_NEWARRHP_OFF R11U200_UNITFOLD_OFF R11U200_FOLDDEPTH_OFF R11U210_GENBITS201_OFF
#         (r11u208's state '1' plus this pass's ExprEmit-only $bits switch)
#   OLD : R11U201_OFF R11V201_OFF                         (the brief's switches: r11u208's state 'b')
# prints one line per case: <case> L201==SUM L201==ON OLD==ON (1 = byte-identical); both views (ELAB=1: --elabuhdm).
# usage: switchreach.sh <law binary> <root>...   (probe case dirs only; no corpus source is read)
HERE=$(cd "$(dirname "$0")" && pwd); REPO=/home/heyfey/git-repos/slang-uhdm; FENCED="$(grep -m1 "^FENCED=" "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed "s/^FENCED=//; s/[\"']//g")"; [ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
BIN=$1; shift
T=/tmp/v11u210_reach${ELAB:+_elab}; mkdir -p $T
one() { c=$1; k=$(echo "$c" | md5sum | cut -c1-10); o=$T/$k; mkdir -p $o
  for f in $FENCED; do grep -qw "$f" <<< "$c" && { echo "$c FENCED"; return; }; done
  E=; [ -n "$ELAB" ] && E=--elabuhdm
  SRC=dut.sv; [ -f "$c/args" ] && SRC=$(cat "$c/args")
  run() { rm -f $o/$1.uhdm; ( cd $c && env $2 $BIN $SRC --single-unit --nobuiltin $E -o $o/$1.uhdm > /dev/null 2>&1 ); md5sum < $o/$1.uhdm 2>/dev/null | cut -c1-12; }
  on=$(run on "X=1"); l=$(run l201 "R11U210_LANDING201_OFF=1")
  sm=$(run sum "R11U201_OFF=1 R11V201_OFF=1 R11U200_NEWARRHP_OFF=1 R11U200_UNITFOLD_OFF=1 R11U200_FOLDDEPTH_OFF=1 R11U210_GENBITS201_OFF=1")
  od=$(run old "R11U201_OFF=1 R11V201_OFF=1")
  echo "$c $([ "$l" = "$sm" ] && echo 1 || echo 0) $([ "$l" = "$on" ] && echo 1 || echo 0) $([ "$od" = "$on" ] && echo 1 || echo 0)"; }
export -f one; export T BIN ELAB FENCED
find "$@" -name dut.sv -printf '%h\n' | sort -u | xargs -P2 -I{} bash -c 'one {}'
