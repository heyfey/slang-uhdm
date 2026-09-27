#!/bin/bash
# the law binary with the census trace on; each invocation appends its firings to $R11U184_TRACELOG (tagged by -o target)
# (SLANG_UHDM for verify_golden.py; LAWBIN names the frozen law binary)
out=""; prev=""; for a in "$@"; do [ "$prev" = "-o" ] && out=$a; prev=$a; done
R11U184_TRACE=1 ${LAWBIN:?LAWBIN unset} "$@" 2> >(grep '^R11U184 law' | sed "s#^#$out #" >> ${R11U184_TRACELOG:-/tmp/r11u184_trace.log})
