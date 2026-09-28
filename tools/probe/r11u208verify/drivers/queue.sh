#!/bin/bash
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# queue.sh <lane spec>...: run gate sweeps one after another in this lane; spec = <state>:<tag>[:<corpora>]
# (state = law or a wrapper name under $R208_BIN; tag = the /tmp/r11u208_sw<tag> workdir, one letter: same-length names).
source "$(dirname "$0")/env.sh" || exit 2
for s in "$@"; do
  st=${s%%:*}; r=${s#*:}; tag=${r%%:*}; c=""; [ "$r" != "$tag" ] && c=${r#*:}
  b=$R208_BIN/$st.sh; [ "$st" = law ] && b=$R208_BIN/law.bin; [ "$st" = fix ] && b=$R208_BIN/fix.bin
  W=/tmp/r11u208_sw$tag; rm -rf $W; echo "$(date +%T) start $s" >> /tmp/r11u208_queue.log
  bash $(dirname "$0")/sweep.sh $b $W "$c"
  echo "$(date +%T) done $s $(tail -1 $W.log)" >> /tmp/r11u208_queue.log
done
