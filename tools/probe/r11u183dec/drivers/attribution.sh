#!/bin/bash
# r11u183: the per-switch order-blind attribution (drivers/rowdist.sh) of the final law binary on the moved rows,
# default mode, every switch set alone; output evidence/attribution_lawJ.txt.  (Rows re-run from the swL command lines.)
. /tmp/wt_r11u183/tools/probe/r11u183dec/drivers/env.sh
R=/tmp/wt_r11u183/tools/probe/r11u183dec/drivers/rowdist.sh
SW="NONE R11U183_OFF R11U183_RANGEFILE_OFF R11U183_TSSPAN_OFF R11U183_IFARR_OFF R11U183_UARANGE_OFF R11U183_PATHSPAN_OFF R11U183_BITTSNAME_OFF R11U183_UVMCOPY_OFF R11U183_DEPTH_OFF R11U183_ALIASNAME_OFF R11U183_CLONELV_OFF R11U183_IMPCOPY_OFF R11U183_FEIDX_OFF R11U183_PROPELEM_OFF R11U183_TYPEPARAM_OFF R11U183_PARAMAGG_OFF R11U183_IMPNETTS_OFF"
{ for t in MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg ApbSlave SVSwitch; do for s in $SW; do echo "surelog $t $s"; done; done
  for t in Rggen Earlgrey_0_1 ArrayMethodIterator; do for s in NONE R11U183_OFF; do echo "surelog $t $s"; done; done
  for t in const_cast_signext struct_param_func_config jeras_union ParameterFromPkgInNestedModule ParameterFromPkgOnParameterPortList; do for s in NONE R11U183_OFF; do echo "uhdm2rtlil $t $s"; done; done; } |
  xargs -P3 -L1 sh -c 'bash '$R' /tmp/r11u183_swL $0 default $1 /tmp/r11u183_bin/slang-uhdm.lawJ $2=1' 2>&1 | grep -v -E 'Traceback|File|a = coll|\^|FileNotFound' | sed 's/NONE=1//' | sort
