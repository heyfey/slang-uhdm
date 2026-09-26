#!/bin/bash
/tmp/v11u171_scr/recs.sh $1 | tr '\n' ' '
n=$(readlink -f $1 | sed 's|.*/v11u171_cases/||' | tr / _); S=/tmp/v11u171_scr/rec_$n
comm -12 $S/g.ms $S/pris.ms > $S/pg; echo "away=$(comm -23 $S/pg $S/law.ms | wc -l)"
