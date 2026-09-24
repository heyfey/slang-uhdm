#!/bin/bash
# A6c: a rejection only the downstream command line reaches (-DSYNTHESIS: an
# `ifdef SYNTHESIS branch slang-uhdm cannot take). The wrapper stands for such a
# slang-uhdm: it exits 1 without a database when -DSYNTHESIS is on its command
# line in the test's directory, and is the binary under test otherwise. The
# corpus stages never pass -DSYNTHESIS, so only the downstream stage can see it.
# Expected: the row leaves IDENTICAL -> the gate FAILS. Usage: <repo> <workdir>
set -u; R=$1; W=$2; T=adff
rm -rf $W; mkdir -p $W
cat > $W/slang-wrap <<EOW
#!/bin/bash
case " \$* " in *" -DSYNTHESIS "*) [ "\$(basename "\$PWD")" = "$T" ] && { echo "error: synthetic rejection under SYNTHESIS" >&2; exit 1; } ;; esac
exec $SLANG_UHDM "\$@"
EOW
chmod 555 $W/slang-wrap
echo "+ SLANG_UHDM=$W/slang-wrap tests/sweep.sh --corpus 'uhdm2rtlil downstream' --filter '^$T\$'"
SLANG_UHDM=$W/slang-wrap $R/tests/sweep.sh --jobs 3 --corpus "uhdm2rtlil downstream" --filter "^$T\$" --workdir $W | grep -v '^ONLY-COMMITTED'; rc=${PIPESTATUS[0]}
cat $W/uhdm2rtlil.csv; cat $W/downstream.csv
echo "SWEEP rc=$rc"
