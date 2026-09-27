#!/bin/bash
# (r11u190: from v11u180repro/drivers/enumpar.sh, the env from this directory) enumpar.sh <uhdm>: the parents
# (kind defname (fullname)) of every enum_typespec parented by a module / interface / program / package, sorted
# unique.  Cases only.
source /tmp/wt_r11u190/tools/probe/r11u190verify/drivers/env.sh || exit 2
$UHDM_DUMP $1 2>/dev/null | awk '/_enum_typespec: \(/{n=$0; getline a; getline b; if (a ~ /vpiParent/ && b ~ /module_inst|interface_inst|program|package:/) {sub(/.*_enum_typespec: /,"",n); sub(/, id:.*/,"",n); sub(/, line.*/,"",n); gsub(/id:[0-9]*, /,"",b); gsub(/file:[^,]*, /,"",b); sub(/^ */,"",b); sub(/, line.*/,"",b); print n" <- "b}}' | sort -u
