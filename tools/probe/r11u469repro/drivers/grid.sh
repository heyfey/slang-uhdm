#!/bin/bash
# grid.sh <tag>:<binary>... -- <casedir>...: for each case, per binary: exit code, uhdm-cmp lines,
# strict verdict, md5 of ours, and the import-copy role census against golden (rolecmp: roles whose
# per-hop instance view differs from golden's).  Env passes through to the binaries (switches).
D=$(dirname $(realpath $0)); RC=${ROLECMP:-/tmp/r11u469_tools/rolecmp}
bins=(); while [ "$1" != "--" ]; do bins+=("$1"); shift; done; shift
for c in "$@"; do
  line="$(basename $(dirname $c))/$(basename $c)"
  for tb in "${bins[@]}"; do t=${tb%%:*}; b=${tb#*:}
    r=$($D/runcase.sh $b $t $c | awk '{print $2, $3, $4, $NF}')
    W=/tmp/r11u469_runs$(realpath $c)
    rc=$([ -x "$RC" ] && $RC $W/sl/slpp_all/surelog.uhdm $W/$t.uhdm | awk '{print $NF}')
    line="$line | $t $r roles:$rc"
  done
  echo "$line"
done
