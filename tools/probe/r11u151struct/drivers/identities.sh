#!/bin/bash
# identities.sh <law-binary-tag> [gridroot]: the object-identity readings behind the decodes, from the grid
# databases gridall.sh wrote (<gridroot>/<class>/<case>/{gold/golden,pris,<tag>}.uhdm).
# Needs tsmem_db and arrexpr_db built with cc.sh into /tmp/r11u151_bin, and UHDM_DUMP.
T=${1:-law12}; R=${2:-/tmp/r11u151_g}; B=/tmp/r11u151_bin
echo "## D: typespec_member stamps (tsmem_db) -- golden's leftover is an object no listing walks"
for n in e01_mod_qual_call e02_mod_import_call e03_pkg_holder_bare e05_mod_qual_plainlit e06_mod_qual_wide e07_mod_qual_opmember; do
  for w in gold/golden pris $T; do echo "-- D/$n $w"; $B/tsmem_db $R/D/$n/$w.uhdm X | grep -v 'actual=-'; done; done
echo; echo "## DEFPAT: array_expr element identity (arrexpr_db)"
for n in p01_defaultpatternint p02_import_read p04_three_elems p05_explicit_import p06_unsized_ones p03_module_local_ctl; do
  for w in gold/golden pris $T; do echo "-- DEFPAT/$n $w"; $B/arrexpr_db $R/DEFPAT/$n/$w.uhdm; done; done
echo; echo "## ARR: whole-reference bindings (uhdm-dump; strict is blind where both targets were already walked)"
for n in a01_unpacked2d a07_ff_nonblocking a13_nb_varsel a14_nb_sibling_begin a15_nb_else_begin a16_nb_lfsr a17_varsel_range a18_nb_initial; do
  for w in gold/golden pris $T; do echo "-- ARR/$n $w"; $UHDM_DUMP $R/ARR/$n/$w.uhdm 2>/dev/null | grep -A6 '\\_ref_obj: (work@top\.\(v\|pa\|lfsr\|arr\))' | grep -A1 'vpiActual' | grep '\\_' | sed 's/^ *//' | sort | uniq -c; done; done
