# (r11u308: copied from r11u306repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u304repro/drivers; the downstream lane's and the probe's databases mirrored too)
# r11u282: copied from v11u202repro/drivers
# v11u202: hard-link every corpus slang.uhdm of a sweep workdir into a mirror, skipping any path naming a fenced test (fail closed)
source "$(dirname "$0")/env.sh" || exit 3
W=$1; M=$2; rm -rf $M; mkdir -p $M; n=0; s=0
while read -r p; do
  if echo "$p" | grep -Pq "$FENCERE"; then s=$((s+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln "$W/$p" "$M/$p"; n=$((n+1))
done < <(cd $W && { find surelog uhdm2rtlil -name slang.uhdm; find downstream -mindepth 2 -maxdepth 2 -name slang.uhdm; find probe -maxdepth 1 -name '*.uhdm'; } | sort)
echo "mirrored=$n fenced_skipped=$s"
