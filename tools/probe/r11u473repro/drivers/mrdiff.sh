#!/bin/bash
# mrdiff.sh <casedir> <tag>: modroles diff golden vs <tag> (no parents, no ids)
R=/tmp/r11u473_runs$(realpath $1)
MR_NOPAR=1 /tmp/r11u473_tools/modroles $R/sl/slpp_all/surelog.uhdm > $R/mr.g
MR_NOPAR=1 /tmp/r11u473_tools/modroles $R/$2.uhdm > $R/mr.$2
diff $R/mr.g $R/mr.$2
