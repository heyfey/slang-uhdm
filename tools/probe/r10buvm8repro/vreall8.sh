#!/usr/bin/env bash
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; export PRISTINE PATCHED
cd "$(cd "$(dirname "$0")" && pwd)"
for f in vfwd8.sv vfwdts8.sv voob8.sv vxpkg8.sv v4order8.sv v5kinds8.sv v5a8.sv v5b8.sv v6ctx8.sv v7misc8.sv v8twice8.sv v9fold8.sv v10rep8.sv v11coll8.sv v12coll8.sv v20ord8.sv v22body8.sv vshadowcells8/v21_s1.sv vshadowcells8/v21_s2.sv vshadowcells8/v21_s3.sv vshadowcells8/v21_s4.sv vshadowcells8/v21_s5.sv vshadowcells8/v21_s6.sv vshadowcells8/v21_s7.sv vshadowcells8/v21_s8.sv; do
  [ -f "$f" ] || { echo "MISSING $f"; continue; }
  ./vgrid8.sh "$f" 2>&1 | grep -E '^ARM|REGRESSION|FIXED|cells=|dump-vs-golden|MOVED-AWAY'
done
