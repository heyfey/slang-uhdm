#!/bin/bash
# grid.sh <dir of cases> <bin> <tag>  -> per case verdict (parallel 3)
ls -d $1/*/ | xargs -P 3 -I{} /tmp/r11u137_scr/case.sh {} $2 $3 | sort
