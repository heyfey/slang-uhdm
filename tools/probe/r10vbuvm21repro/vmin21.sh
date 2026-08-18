#!/usr/bin/env bash
# r10vbuvm21repro/vmin21.sh — THE DECISIVE JUDGE ARMS.  One construct per file,
# each small enough that the PRISTINE binary is CMP_EQUAL (0 cmp lines), so any
# regression is convicted by the OFFICIAL judge rather than by a census.
# Writes the arms into <workdir> and runs vjudge21.sh on each with every binary
# given.  MEASUREMENT ONLY.
#
# usage: vmin21.sh <workdir> <bin1> [bin2 ...]
set -u
D=$(cd "$(dirname "$0")" && pwd)
W=${1:?workdir}; shift
mkdir -p "$W"
gen() {  # gen <name> <body>
  cat > "$W/$1.sv" <<EOF
package mp_$1;
  typedef enum { MA, MB } me;
  class mc;
    int aa[me];
    int c;
    event ev;
    $2
  endclass
endpackage
EOF
}
# golden BINDS these (the law's own window)
gen plain      'task m(me s); aa[s]++; endtask'
gen beg        'task m(me s); begin aa[s]++; end endtask'
gen fork       'task m(me s); fork aa[s]++; join endtask'
gen evt        'task m(me s); @(ev) aa[s]++; endtask'
gen assertblk  'function void m(me s); assert (c) aa[s]++; endfunction'
gen scalar     'task m(int s); s++; endtask'
# golden leaves these BARE — the CARRIER EXCLUSIONS (§ incDecOpaqueCarrier21)
gen delay      'task m(me s); #1 aa[s]++; endtask'
gen delaybeg   'task m(me s); begin #1 aa[s]++; end endtask'
gen delayfork  'task m(me s); fork #1 aa[s]++; join endtask'
gen delayonbeg 'task m(me s); #1 begin aa[s]++; end endtask'
gen delayscalar 'task m(int s); #1 s++; endtask'
gen evtdelay   'task m(me s); @(ev) #1 aa[s]++; endtask'
gen delayevt   'task m(me s); #1 @(ev) aa[s]++; endtask'
gen wait       'task m(me s); wait (c) aa[s]++; endtask'
gen waitbeg    'task m(me s); wait (c) begin aa[s]++; end endtask'
# golden BARE by § controlBodyNoBind28 (control arm, must not move)
gen ifstmt     'task m(me s); if (c) aa[s]++; endtask'
for f in "$W"/*.sv; do
  bash "$D/vjudge21.sh" "$f" "$W/out_$(basename "$f" .sv)" "$@"
done
