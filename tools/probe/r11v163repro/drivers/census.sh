source /tmp/v11u163_env.sh
[ -n "$FENCED" ] || { echo "no FENCED"; exit 3; }
F="^(?!($(echo $FENCED | tr ' ' '|'))\$)"
export SLANG_UHDM=/tmp/v11u163_bin/tracewrap.sh
cd /tmp/wt_v11u163
python3 scripts/check_probe.py --jobs 4 --workdir /tmp/v11u163_cen/probe --out /tmp/v11u163_cen/probe.csv > /tmp/v11u163_cen/probe.log 2>&1
for c in surelog uhdm2rtlil; do python3 scripts/verify_golden.py --corpus $c --mode both --jobs 4 --filter "$F" --out /tmp/v11u163_cen/$c.csv --workdir /tmp/v11u163_cen/$c > /tmp/v11u163_cen/$c.log 2>&1; done
echo done > /tmp/v11u163_cen/DONE
