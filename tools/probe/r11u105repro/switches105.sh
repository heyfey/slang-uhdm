#!/usr/bin/env bash
# run every r11u105 switch tag (and, with P103=1, the landed pass-102 switch tags) of
# a binary over grid copies made by runall105.sh.  usage: G=<dir> REPO=<tree> BIN=<binary> [P103=1] [PFX=<tagprefix>] switches105.sh
set -u
G=${G:?}; REPO=${REPO:?}; BIN=${BIN:?}; PFX=${PFX:-}
D=$(cd "$(dirname "$0")" && pwd)
SPECS="off|R11U105_OFF=1 tkof|R11U105_TOPKEY_OFF=1 pkof|R11U105_PROGKEY_OFF=1 piof|R11U105_PROGINST_OFF=1 ikof|R11U105_IFACEKEY_OFF=1"
[ -n "${P103:-}" ] && SPECS="o103|R11U103_OFF=1 akof|R11U103_FILEKEY_OFF=1 adof|R11U103_FILEKEY_DEFONLY_OFF=1 fof|R11U103_UNELAB_F_OFF=1 niof|R11U103_UNELAB_NI_OFF=1 npof|R11U103_UNELAB_NP_OFF=1 lbof|R11U103_UNELAB_LIB_OFF=1 ifof|R11U103_UNELAB_IFACE_OFF=1"
for spec in $SPECS; do
  IFS='|' read tag envs <<< "$spec"
  G=$G REPO=$REPO bash $D/runall105.sh $BIN $PFX$tag $envs
done
