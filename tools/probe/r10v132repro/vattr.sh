#!/bin/bash
# v132 per-mover ORDER-BLIND, PATH-NORMALISED, ID-STRIPPED attribution.
# Also scores every added/removed line against GOLDEN's own dump:
#   AWAY        = a line we ADDED that golden does NOT emit
#   MOVED-WRONG = a line we REMOVED that golden DOES emit
set -u
rel=$1
D=$HOME/.local/bin/uhdm-dump
norm() { sed -e 's#/tmp/v132_wd_[a-z]*/sl/##g' -e 's#, id:[0-9]*##g' -e 's#id:[0-9]*##g' | sort; }
a=/tmp/v132_wd_pris/sl/$rel/slang.uhdm
b=/tmp/v132_wd_pat/sl/$rel/slang.uhdm
c=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' /tmp/v132_wd_pris/sl/$rel/cmds.txt | head -1)/golden.uhdm
t=/tmp/v132_scratch/attr/$(echo $rel|tr / _); mkdir -p $t
$D "$a" 2>/dev/null | sed 1d | norm > $t/p.s
$D "$b" 2>/dev/null | sed 1d | norm > $t/q.s
$D "$c" 2>/dev/null | sed 1d | norm > $t/g.s
out=$(comm -23 $t/p.s $t/q.s | wc -l)   # lines only in pristine  (removed)
inn=$(comm -13 $t/p.s $t/q.s | wc -l)   # lines only in patched   (added)
comm -23 $t/p.s $t/q.s | sort -u > $t/rem.u
comm -13 $t/p.s $t/q.s | sort -u > $t/add.u
sort -u $t/g.s > $t/g.u
away=$(comm -23 $t/add.u $t/g.u | wc -l)
mw=$(comm -12 $t/rem.u $t/g.u | wc -l)
printf "%-28s OUT=%-4s IN=%-4s  distinct-added=%-3s AWAY(added-not-golden)=%-3s  distinct-removed=%-3s MOVED-WRONG(removed-is-golden)=%s\n" \
  "$rel" "$out" "$inn" "$(wc -l < $t/add.u)" "$away" "$(wc -l < $t/rem.u)" "$mw"
