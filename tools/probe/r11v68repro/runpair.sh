set -u
F=$(readlink -f "$1"); A=$2; B=$3
N=$(basename "$F" .sv)
rm -rf /tmp/v11u68_pc; mkdir -p /tmp/v11u68_pc
( cd /tmp/v11u68_pc && "$A" "$F" --single-unit -o ours.uhdm >/dev/null 2>&1 ); ra=$?
mv /tmp/v11u68_pc/ours.uhdm /tmp/v11u68_pc/a.uhdm
( cd /tmp/v11u68_pc && "$B" "$F" --single-unit -o ours.uhdm >/dev/null 2>&1 ); rb=$?
if cmp -s /tmp/v11u68_pc/a.uhdm /tmp/v11u68_pc/ours.uhdm; then echo "SAME     $N (ra=$ra rb=$rb)"; else echo "DIFFERS  $N (ra=$ra rb=$rb)"; fi
