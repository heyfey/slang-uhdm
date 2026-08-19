#!/usr/bin/env bash
# r10earl70 — score ONE arm 3-way (golden / pristine / patched) with the
# JUDGE-VISIBLE payload only: the span, the typespec span and the actual's
# fullname are stripped before scoring (earl60's attrv60.py lesson).
# MEASUREMENT ONLY.  usage: armscore70.sh <golden-dir> <pristine-dir> <patched-dir> [o|oe]
set -u
V=${4:-o}
ns() { sed 's/ span=[^ ]*//g; s/ tsspan=[^ ]*//g; s/ afn=[^ ]*//g; s/ tsname=[^ ]*//g' "$1" | sort; }
ns "$1/g.ex"      > /tmp/.as70g.$$
ns "$2/$V.ex"     > /tmp/.as70p.$$
ns "$3/$V.ex"     > /tmp/.as70q.$$
python3 "$(dirname "$0")/score70.py" /tmp/.as70g.$$ /tmp/.as70p.$$ /tmp/.as70q.$$ 4 "${5:-8}"
rm -f /tmp/.as70g.$$ /tmp/.as70p.$$ /tmp/.as70q.$$
