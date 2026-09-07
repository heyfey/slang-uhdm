set -u
D=/tmp/v196_arms; R=/tmp/wt_v196/tools/probe/r10uvm196repro
export IMP=/tmp/v196_bin/ct196imp CEN=/tmp/v196_bin/ct196cen
run() { n=$1; shift; bash $R/grid196.sh "$n" /tmp/v196_frozen/pris.bin /tmp/v196_frozen/pat.bin /tmp/v196_wd/arms/$n "$@" > /tmp/v196_wd/arms/$n.out 2>&1; echo "ARM $n rc=$?"; }
run x12_shadow $D/v196_pkg.sv $D/v196_x12_shadow.sv
run x13_genarr $D/v196_pkg.sv $D/v196_x13_genarr.sv
echo ARMS2_DONE
