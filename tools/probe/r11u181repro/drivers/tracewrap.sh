#!/bin/bash
# the law binary with the census trace on; each invocation appends its firings to $R11U181_TRACELOG (tagged by -o target)
out=""; prev=""; for a in "$@"; do [ "$prev" = "-o" ] && out=$a; prev=$a; done
R11U181_TRACE=1 /tmp/r11u181_bin/law181f.bin "$@" 2> >(grep '^R11U181 law' | sed "s#^#$out #" >> ${R11U181_TRACELOG:-/tmp/r11u181_trace.log})
