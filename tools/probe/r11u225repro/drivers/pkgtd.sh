#!/bin/bash
# pkgtd.sh <db.uhdm> : the typedef entries (with spans) listed directly under each package, per listing section.
D=$(dirname "$0")
"$D/dump.sh" "$1" | awk '/^\|uhdm/{sec=$0} /^  \|vpiTypedef:/{getline; print sec" "$0}'
