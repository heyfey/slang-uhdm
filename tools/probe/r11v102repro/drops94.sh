#!/bin/bash
# r11v102 drop builds: in ONE worktree carrying the verified production patch,
# turn a flag (or ALLOFF = all fourteen) false, build -j 2, freeze the binary,
# turn it back and assert the source equals the patch again.
# usage: PATCH=<production patch> BINDIR=<dir> drops94.sh <worktree> <variant>...
set -u
d=${1:?worktree}; shift
PATCH=${PATCH:?production patch}; BINDIR=${BINDIR:?binary dir}
ALL="ndaUser102 ndaClog102 wideNet102v xDecl102 basedX102 xRef102 cmpOp102 pkgCall102 basedLead102v strCmp102v defArg102v bodyPkg102v argDigits102v clogNeg102v"
cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ -Dslang_DIR=$HOME/.local/lib64/cmake/slang -DUHDM_DIR=$HOME/.local/lib64/cmake/UHDM > $d.cmake.log 2>&1
for v in "$@"; do
  fl=$v; [ "$v" = ALLOFF ] && fl=$ALL
  for f in $fl; do
    n=$(grep -c "bool $f = true;" $d/src/ExprEmit.cpp $d/src/EmitHelpers.h | awk -F: '{s+=$2} END{print s}')
    [ "$n" = 1 ] || { echo "VARIANT $v flag $f count=$n ABORT"; exit 1; }
    sed -i "s/bool $f = true;/bool $f = false;/" $d/src/ExprEmit.cpp $d/src/EmitHelpers.h
  done
  timeout 3000 cmake --build $d/build -j 2 > $d.build.$v.log 2>&1; rc=$?
  cp $d/build/slang-uhdm $BINDIR/drop_$v.bin; chmod 555 $BINDIR/drop_$v.bin
  echo "VARIANT $v rc=$rc md5=$(md5sum $BINDIR/drop_$v.bin | cut -c1-32)"
  for f in $fl; do sed -i "s/bool $f = false;/bool $f = true;/" $d/src/ExprEmit.cpp $d/src/EmitHelpers.h; done
  (cd $d && git diff HEAD -- src | cmp -s - $PATCH && echo "  restored OK" || echo "  RESTORE MISMATCH")
done
