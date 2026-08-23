#!/usr/bin/env bash
# r10earl75 — normalise a cscen75 census for a golden-vs-ours join.
#  * OUR databases leave VpiFile EMPTY on a folded constant (RESUME §9), so the
#    FILE part of every span is dropped and only line:col survives in the key.
#  * everything after `||` is COMPARE-INVISIBLE evidence (the constant's
#    VpiParent — golden re-parents a replication-count fold at the package
#    param_assign and no generated Compare reads VpiParent — and the typespec's
#    own span).  It is dropped before scoring so it can never manufacture a
#    cell; read it out of the raw census instead.
#  * DEDUP (`sort -u`, r10earl72repro/armscore72.sh's choice, and NOT optional):
#    the listener reaches the SAME object by several routes and the number of
#    routes differs between the two databases — most of all in the `--elabuhdm`
#    view, where an undeduped join reported 102 phantom "golden has no cell"
#    rows whose chain, site, path, span AND payload golden matches exactly.
#    Deduping cannot hide a divergence: if one of two identical duplicates
#    changes, the deduped set gains a second distinct line.
# usage: norm75.sh <in.cen> > <out.n>
sed 's/ ||.*//; s/span=[^ ]*:\([0-9][0-9]*:[0-9]\)/span=\1/' "$1" | sort -u
