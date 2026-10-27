#!/bin/bash
# lvx.sh <uhdm>: print each clone loop variable's shared home object (ref_var whose actual is a ref_var) with its typespec
/tmp/r11u449_tools/dumpids $1 | awk '/^\\_ref_var:/{p=1; n=0} p{print; n++; if(n>12){p=0}}' | grep -E '^\\_ref_var|vpiActual|_typespec|vpiInstance' | sed 's/, id:[0-9]*//' | grep -v '^\s*\\_ref_typespec' 
