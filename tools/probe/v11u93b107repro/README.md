# v11u93 — adversarial verification of r11u107 (type-parameter typespec faces)

Base `772d5083`. The implementer's patch is reproduced bit for bit: the law binary
md5 matches, the 55-arm grid matches every count, the five rows match their
cmp counts and heads, and the u2r and Surelog sweeps match.

## A defect in § tpElemRebindDefView107, fixed here

The law reads the "last" instance binding with a walk that visits every plain
module instance first and then every generate scope. Surelog's netlist walk
does not do that. `NetlistElaboration::elaborate_` (NetlistElaboration.cpp:703-791)
recurses `getChildren()`, where a generate block is itself a child, interleaved
with the plain instances in SOURCE order. Measured on real v1.87 goldens (`brk/`):

| arm | golden binds | r11u107 law | verdict |
|---|---|---|---|
| r01_gen_first (generate block, then plain `u0`) | u0 `logic [1:0]` | g.u1 `logic [2:0]` | wrong mint (pristine wrote nothing) |
| r09_gen_for (generate loop, then `u0`) | u0 | g[1].u1 | wrong mint |
| r11_nested_gen (nested generate, then `u0`) | u0 | g.h.u1 | wrong mint |
| r12_gen_mid (`u0`, generate `u1`, then a DEFAULT `u2`) | default (equal to def) | g.u1 | **AWAY**: pristine was right at this cell (60/1 at the R0 head), the law wrote a wrong typespec (51/1) |

The fix (UhdmExporter.cpp, `srcOrder107`) stable-sorts one scope's module
instances and generate-scope arrays by (line, column) before recursing.
`V11U93_ORDER_OFF=1` restores the old walk, which is byte-identical to the r11u107
binary on r01. With the fix, r01/r09/r11 move past the typespec to a pre-existing
def-view head (a port low_conn ref_obj with no actual when the first instance of
the definition is in a generate block; the same in pristine, ModuleEmit's ground).
r12 is back at pristine's R0 head. r02-r08 and r10 do not change. The 55 grid arms
are byte-identical law vs fixd.

## Evidence
* `evidence/BRK.txt`, `HEADS.brk.txt`: 47 break arms, cmp lines/heads for pris, law and fixd.
* `evidence/CELLS.txt`: name-keyed VALUE cell scorer (`cell93.py`), pris -> fixd, positive controls.
* `evidence/DIST.arms.txt`: order-blind whole-dump distance.
* `evidence/GATES.txt`: build, goldens, sweeps, byteverify, pins, canaries.
* Tools: `grid93.sh` (= r11u107 grid107.sh), `offrun93.sh` (switch runs), `head93.sh`,
  `cen93.py` + `cen93one.sh` (golden-shape census), `obl93.sh`, `dist93.sh`.
