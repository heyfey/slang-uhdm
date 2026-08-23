#!/usr/bin/env bash
# r10earl76 — normalise a cscen76 census into `KEY PAYLOAD` lines for
# score76.py's multiset join.
#
#  * THE LEADING `C` / `R` LETTER IS DROPPED FROM THE KEY, on purpose: this
#    pass's head is a KIND FLIP (golden `ref_obj` -> our `constant`) at ONE
#    site+route+span, and a key that carried the kind would split that flip
#    into two cells — "golden has one we do not" plus "we have one golden does
#    not" — and hide it from every AWAY / MOVED-WRONG counter.  The kind rides
#    in the PAYLOAD as `kind=` instead, where it is scored.
#  * OUR databases leave VpiFile EMPTY on a folded constant (RESUME §9), so the
#    FILE part of every span is dropped and only line:col survives in the key.
#  * everything after `||` is COMPARE-INVISIBLE evidence (the constant's
#    VpiParent — golden re-parents folds at the package param_assign and no
#    generated Compare reads VpiParent — the typespec's own span, and the
#    ref_obj's VpiFullName).  Dropped before scoring so it can never
#    manufacture a cell; read it out of the raw census instead.
#  * DEDUP (`sort -u`) — the listener reaches the same object by several routes
#    and the number of routes differs between databases (earl75 measured 102
#    phantom rows in the `--elabuhdm` view without it).  Deduping cannot hide a
#    divergence: if one of two identical duplicates changes, the deduped set
#    gains a second distinct line.
# usage: norm76.sh <in.cen> > <out.n>
set -u
sed 's/ ||.*//; s/span=[^ ]*:\([0-9][0-9]*:[0-9]\)/span=\1/' "$1" |
  awk -F' [|] ' 'NF==2 {n=split($1,a," "); k=""; for(i=2;i<=n;i++) k=(k==""?a[i]:k"~"a[i]); print k" "$2}' |
  sort -u
