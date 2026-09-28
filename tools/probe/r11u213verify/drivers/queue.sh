#!/bin/bash
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# queue.sh <lane spec>...: run gate sweeps one after another in this lane; spec = <state>:<tag>[:<corpora>]
# (state = law or a wrapper name under $R213_BIN; tag = the /tmp/r11u213_sw<tag> workdir, one letter: same-length names).
source "$(dirname "$0")/env.sh" || exit 2
for s in "$@"; do
  st=${s%%:*}; r=${s#*:}; tag=${r%%:*}; c=""; [ "$r" != "$tag" ] && c=${r#*:}
  b=$R213_BIN/$st.sh; [ "$st" = law ] && b=$R213_BIN/law.bin
  W=/tmp/r11u213_sw$tag; rm -rf $W; echo "$(date +%T) start $s" >> /tmp/r11u213_queue.log
  bash $(dirname "$0")/sweep.sh $b $W "$c"
  echo "$(date +%T) done $s $(tail -1 $W.log)" >> /tmp/r11u213_queue.log
done
