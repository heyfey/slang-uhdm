#!/bin/bash
# enumpar.sh <uhdm> : parents (kind defname (fullname)) of enum_typespec objects parented by a module/interface/program/package
. /tmp/v11u180_scr/env.sh
$UHDM_DUMP $1 2>/dev/null | awk '/_enum_typespec: \(/{n=$0; getline a; getline b; if (a ~ /vpiParent/ && b ~ /module_inst|interface_inst|program|package:/) {sub(/.*_enum_typespec: /,"",n); sub(/, id:.*/,"",n); sub(/, line.*/,"",n); gsub(/id:[0-9]*, /,"",b); gsub(/file:[^,]*, /,"",b); sub(/^ */,"",b); sub(/, line.*/,"",b); print n" <- "b}}' | sort -u
