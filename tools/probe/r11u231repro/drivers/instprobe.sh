#!/bin/bash
# instprobe.sh <probe workdir> <out>: instjoin.py over every probe case (golden from the cache, ours from the sweep).
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$H/env.sh" || exit 2
python3 $H/probegold.py $1 | while read rel g o; do
  python3 $H/instjoin.py $B/tsinst $g $o | sed "s#^#$rel #"
done > $2
