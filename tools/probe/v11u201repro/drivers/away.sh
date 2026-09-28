#!/bin/bash
# away.sh golden pris law -> multiset lines: TOWARD (fixed) and AWAY (new wrong) counts + AWAY lines
. "$(cd "$(dirname "$0")" && pwd)/env.sh"
n() { "$UHDM_DUMP" "$1" 2>/dev/null | tail -n +2 | sed -E 's/id:[0-9]+//g; s#/[^ ,]*/##g' | sort; }
n "$1" > /tmp/v11u201_aw_g; n "$2" > /tmp/v11u201_aw_p; n "$3" > /tmp/v11u201_aw_l
# multiset differences
comm -23 /tmp/v11u201_aw_l /tmp/v11u201_aw_g > /tmp/v11u201_aw_lx   # law-only-vs-golden
comm -23 /tmp/v11u201_aw_p /tmp/v11u201_aw_g > /tmp/v11u201_aw_px
comm -23 /tmp/v11u201_aw_g /tmp/v11u201_aw_l > /tmp/v11u201_aw_gl   # golden missing in law
comm -23 /tmp/v11u201_aw_g /tmp/v11u201_aw_p > /tmp/v11u201_aw_gp
echo "extra: pris=$(wc -l < /tmp/v11u201_aw_px) law=$(wc -l < /tmp/v11u201_aw_lx)  missing: pris=$(wc -l < /tmp/v11u201_aw_gp) law=$(wc -l < /tmp/v11u201_aw_gl)"
echo "-- AWAY extra (in law, not golden, not pris):"; comm -23 /tmp/v11u201_aw_lx /tmp/v11u201_aw_px | head -${N:-10}
echo "-- AWAY missing (golden has, pris had, law lost):"; comm -23 /tmp/v11u201_aw_gl /tmp/v11u201_aw_gp | head -${N:-10}
