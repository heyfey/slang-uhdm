#!/bin/bash
source /tmp/v11u471_env.sh
C=/tmp/wt_v11u471/tools/probe/v11u471repro/cases
for tag in pristine law; do
  export SLANG_UHDM=/tmp/v11u471_bin/$tag GOLDEN_CACHE=/tmp/v11u471_gcache
  [ -x "$SLANG_UHDM" ] || exit 1
  cd /tmp/wt_v11u471 && python3 -c "
import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds
for c in sys.argv[1:]:
    r=ds.one(c.replace('/','_'), '$C/'+c, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u471_dsw_$tag', 300)
    print('$tag', c, r['verdict'], r['surelog_gates'], r['slang_gates'], r['differs'], r['detail'][:80])
" "$@"
done
