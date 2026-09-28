#!/bin/bash
export LC_ALL=C
# join.sh <a.txt> <b.txt> <c.txt>: case-view, verdict in a, verdict in b, bytes moved a->b, c bytes == a bytes
# join.sh a.txt b.txt c.txt : case, status a, status b, (md5 c == md5 a ? OFF=pris)
join <(awk '{print $1, $3"|"$5, $7}' $1 | sort) <(awk '{print $1, $3"|"$5, $7}' $2 | sort) | join - <(awk '{print $1, $7}' $3 | sort) | awk '{off=($3==$6)?"OFF=pris":"OFF!=pris"; mv=($3==$5)?"same":"MOVED"; print $1, $2, $4, mv, off}'
