#!/bin/bash
# mutcases.sh: the hand-built mutations of questions 1 and 2 on the cases' own databases (built by case.sh
# under /tmp/r11u129_case/<case>/{g,o}.uhdm). Each mutation writes ONE changed field of ONE object of ours
# (mutate.cpp; raw-walk index from `mutate o.uhdm --list`, saved in evidence/mutations/<case>.list) and
# compares golden against it with: the r11u129 build in modes 2, 3, 4 (4 = default), the committed 9c839593
# binary (base = mode 3 as committed), and two naive repairs of the committed (b) for contrast:
# skipnamed = (b) with its parent lookup fixed, blanking every named root reached through a ref_typespec;
# skipall = the same for every root, named or anonymous (both dev builds kept in drivers/).
set -u
R=$(realpath "$(dirname "$0")/.."); E=$R/evidence/mutations; mkdir -p "$E"
SC=${SC:-/tmp/r11u129_bin/sc_m4g}; BASE=/tmp/r11u129_bin/uhdm-strictcmp.m3
M=/tmp/r11u129_bin/mutate
: > "$E/verdicts.txt"
run() { # case tag side(o|g) idx field value expectation
  local c=$1 t=$2 sd=$3 i=$4 f=$5 v=$6 x=$7 S=/tmp/r11u129_case/$1
  [ -f "$E/$c.$sd.list" ] || $M $S/$sd.uhdm --list > "$E/$c.$sd.list"
  rm -f $S/mut_$t.uhdm
  $M $S/$sd.uhdm $S/mut_$t.uhdm $i $f "$v" || { echo "$c $t: mutate failed" >> "$E/verdicts.txt"; return; }
  local A=$S/g.uhdm B=$S/mut_$t.uhdm
  [ $sd = g ] && { A=$S/mut_$t.uhdm; B=$S/o.uhdm; }
  local line="$c $t ($sd idx $i $f := '$v'; expected: $x):"
  for m in 2 3 4; do $SC --max 4 --canon-fullname $m $A $B > "$E/${c}_$t.m$m.txt" 2>&1; line="$line m$m=$(tail -1 "$E/${c}_$t.m$m.txt" | cut -d' ' -f1)"; done
  $BASE --max 4 $A $B > "$E/${c}_$t.base.txt" 2>&1; line="$line base=$(tail -1 "$E/${c}_$t.base.txt" | cut -d' ' -f1)"
  /tmp/r11u129_bin/sc_m4b --max 4 $A $B > "$E/${c}_$t.skipnamed.txt" 2>&1; line="$line skipnamed=$(tail -1 "$E/${c}_$t.skipnamed.txt" | cut -d' ' -f1)"
  SC4_BALL=1 /tmp/r11u129_bin/sc_dev_ball --max 4 $A $B > "$E/${c}_$t.skipall.txt" 2>&1; line="$line skipall=$(tail -1 "$E/${c}_$t.skipall.txt" | cut -d' ' -f1)"
  echo "$line" | tee -a "$E/verdicts.txt"
}
# the unmutated pairs first (the premise: every comparator but m2 reads them equal)
for c in q06_twin_members b05_named_clone_span b06_anon_root_span c_InsideOp; do
  S=/tmp/r11u129_case/$c; echo "$c unmutated: m2=$($SC --max 0 --canon-fullname 2 $S/g.uhdm $S/o.uhdm | tail -1 | cut -d' ' -f1) m3=$($SC --max 0 --canon-fullname 3 $S/g.uhdm $S/o.uhdm | tail -1 | cut -d' ' -f1) m4=$($SC --max 0 $S/g.uhdm $S/o.uhdm | tail -1 | cut -d' ' -f1) base=$($BASE --max 0 $S/g.uhdm $S/o.uhdm | tail -1 | cut -d' ' -f1) skipnamed=$(/tmp/r11u129_bin/sc_m4b --max 0 $S/g.uhdm $S/o.uhdm | tail -1 | cut -d' ' -f1) skipall=$(SC4_BALL=1 /tmp/r11u129_bin/sc_dev_ball --max 0 $S/g.uhdm $S/o.uhdm | tail -1 | cut -d' ' -f1)" | tee -a "$E/verdicts.txt"
done
# question 1: a name inside a copy (q06: in_t's member c against oth_t's member c)
run q06_twin_members S-last o 4 fullname 'p::p::in_t::cQ' 'content: caught'
run q06_twin_members S-mid o 4 fullname 'p::p::in_tQ::c' 'content (the owner name, a middle name of the path): caught'
run q06_twin_members S-top o 4 fullname 'pQ::p::in_t::c' 'above the owner: identity by construction'
run q06_twin_members P-par-ours o 4 parent 13 'invisible: ours STORES this name (buildStructTs), so re-parenting does not change it'
run q06_twin_members P-par-golden g 4 parent 13 'invisible: the golden database stores this name too (Surelog serialises the names it computed), so re-parenting does not change it'
# question 2: spans at a subtree root
run b05_named_clone_span line-clone o 29 line 9 'content (our s_t reached via port i; the same object is listed from the package too): caught'
run b05_named_clone_span file-clone o 29 file - 'content (the clone loses its file): caught'
run b05_named_clone_span line-member o 30 line 9 'content (a member inside the ref-reached copy): caught'
run b06_anon_root_span line-anon o 7 line 9 'content (the anonymous port type is listed only through its ref): caught'
# a NAMED clone of ours reached only through a ref_typespec (never listed from a scope: the census class),
# on a copy of the corpus row InsideOp/default (golden cache + the 9c839593 sweep database, copied)
run c_InsideOp line-clone o 178 line 9 'content (the enum clone under parameter GetWhat, never compared elsewhere): caught'
