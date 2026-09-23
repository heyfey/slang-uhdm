#!/usr/bin/env bash
# run every switch tag of the law binary over the given grid copies, 3 grids at a time
LAW=${LAW:?}; RR=${RR:-$(cd "$(dirname "$0")" && pwd)/rr103.sh}
export LAW RR
run_grid() {
  g=$1
  for spec in "off|R11U103_OFF=1" "akoff|R11U103_FILEKEY_OFF=1" "adoff|R11U103_FILEKEY_DEFONLY_OFF=1" \
              "fof|R11U103_UNELAB_F_OFF=1" "niof|R11U103_UNELAB_NI_OFF=1" "npof|R11U103_UNELAB_NP_OFF=1" \
              "lbof|R11U103_UNELAB_LIB_OFF=1" "ifof|R11U103_UNELAB_IFACE_OFF=1"; do
    IFS='|' read tag envs <<< "$spec"
    env $envs GRID=$g bash $RR $LAW $tag > $g.$tag.txt 2>&1
  done
}
export -f run_grid
printf '%s\n' "$@" | xargs -P 3 -I{} bash -c 'run_grid {}'
