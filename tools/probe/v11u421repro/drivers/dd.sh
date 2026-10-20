#!/bin/bash
# dd.sh <casedir> <binary> [ENV..]: diff golden.dump vs ours dump
set -- $(bash /tmp/v11u421_drv/pair.sh "$@")
diff $(dirname $1)/golden.dump $2.dump
