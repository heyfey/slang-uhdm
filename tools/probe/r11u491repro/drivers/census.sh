#!/bin/bash
# census.sh <list> <lawbin> <out>
xargs -a "$1" -P 3 -I{} nice /tmp/r11u491_drv/away1.sh {} "$2" > "$3" 2>&1
echo CENSUSDONE >> "$3"
