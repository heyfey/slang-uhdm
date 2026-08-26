#!/usr/bin/env bash
# r10uvm151 — the AUTHORITATIVE ROW-SET INSTRUMENT for an arm: the whole
# `uhdm-dump` of a database, cut at `\_weaklyReferenced:` (RESUME.md §9 — the
# weakly-referenced TAIL is a DEEP RE-VISIT of objects the design only
# back-references, `UHDM/templates/vpi_visitor.cpp:543`, and `uhdm-cmp` never
# walks it), path-normalised, `id:`-normalised and SORTED, so the comparison is
# ORDER-BLIND.  MEASUREMENT ONLY.
#
#   dumpsect151.sh <db.uhdm> <workdir-to-normalise-away>
# prints the normalised, sorted DESIGN SECTION on stdout.
set -u
DB=${1:?usage: dumpsect151.sh <db.uhdm> <workdir>}
WD=${2:-}
uhdm-dump "$DB" 2>/dev/null |
  awk 'BEGIN{d=1} /^\\_weaklyReferenced:/{d=0} d==1{print}' |
  sed -e "s|${WD}||g" -e 's/, id:[0-9]*//g' -e 's|/[^ ,]*/\([A-Za-z0-9_.]*\.sv\)|\1|g' |
  sort
