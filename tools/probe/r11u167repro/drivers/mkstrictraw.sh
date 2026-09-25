#!/bin/bash
# mkstrictraw.sh: builds /tmp/r11u167_bin/strictcmp_raw, a MEASUREMENT-ONLY variant of
# tools/uhdm-strictcmp whose record print appends each record's raw full name in braces after the
# canonical one (`<in>pkg::s_t.a{work@dut.pkg::s_t.a}`); the comparison itself is unchanged.
R=$(cd $(dirname $0)/../../../.. && pwd); O=/tmp/r11u167_bin; mkdir -p $O
sed 's|      s += fields\[i\];|      s += fields[i]; if (i == 4 \&\& !rawFull.empty() \&\& rawFull != fields[4]) s += "{" + rawFull + "}";|' \
    $R/tools/uhdm-strictcmp/uhdm-strictcmp.cpp > $O/sx.cpp
${CXX:-c++} -O2 -std=gnu++20 -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include \
    -include uhdm/config.h $O/sx.cpp -o $O/strictcmp_raw $HOME/.local/lib64/libuhdm.a \
    $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
