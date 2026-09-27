#!/bin/bash
# runs the verified binary with the r11u184/r11v184 trace on, appending the V184 lines (with the cwd) to one census file
R11U184_TRACE=1 /tmp/v11u184_bin/ver.bin "$@" 2> >(grep 'R11U184 law' | sed "s#^#$(basename $PWD) #" >> /tmp/v11u184_census.txt)
