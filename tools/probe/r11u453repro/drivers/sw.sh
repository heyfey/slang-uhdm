#!/bin/bash
D=/tmp/wt_r11u453/tools/probe/r11u453repro/drivers
declare -A SW=([vsTrailRangeColonJoin453]=R11U453_VSCOLJOIN_OFF [vsTrailRangeParenStart453]=R11U453_VSPARENSTART_OFF [hpPartSelParenRightEnd453]=R11U453_HPPSPARENEND_OFF [hpVsParenBoundPretty453]=R11U453_HPVSPARENBND_OFF [pkgExplicitImpParamReExport453]=R11U453_XPARAMREEXP_OFF [pkgImpParamsAheadOfOwn453]=R11U453_IMPPARAMFIRST_OFF [pkgExplicitImpVarReExport453]=R11U453_XVARREEXP_OFF [modCopyImportsFirst453]=R11U453_MODCOPYIMPFIRST_OFF)
while read c; do
  p=$(grep -F "$c |" /tmp/r11u453_scr/ctlgrid2.out | awk -F' [|] ' '{print $2}' | sed 's/.*md5=//')
  td=/tmp/r11u453_scr/trsw; rm -rf $td; mkdir -p $td
  $D/run1.sh $c /tmp/r11u453_bin/law14 t R11U453_TRACE=$td >/dev/null
  laws=$(cat $td/* | grep -v '^OUT' | awk '{print $1}' | sort -u | tr '\n' ' ')
  envs=(); for l in $laws; do envs+=("${SW[$l]}=1"); done
  all=$($D/run1.sh $c /tmp/r11u453_bin/law14 sw "${envs[@]}" | sed 's/.*md5=//')
  single=""
  for l in $laws; do s=$($D/run1.sh $c /tmp/r11u453_bin/law14 sw "${SW[$l]}=1" | sed 's/.*md5=//'); [ "$s" = "$p" ] && single="$single $l:restores" || single="$single $l:partial"; done
  [ "$all" = "$p" ] && a=ALLRESTORE || a=ALLDIFF
  echo "${c#/tmp/wt_r11u453/tools/probe/} | $laws| $a |$single"
done < /tmp/r11u453_scr/movers.txt
