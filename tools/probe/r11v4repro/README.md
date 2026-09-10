# r11v4 — adversarial verification of r11u4 `§ ifacePortViewPaFoldsDeclDefault`

VERDICT: **ACCEPT WITH FIX.** The submitted patch carries a
pristine-right → patched-wrong regression that the corpus cannot see; the fix
is one predicate on face (B), and it costs the pass nothing (same conversions,
strictly better arm scores).

Everything below was measured in this pass on REAL Surelog v1.87 goldens, with
binaries this pass built itself. Nothing is carried forward from the
implementer's write-up.

## 1. The three binaries

| build | md5 | what |
|---|---|---|
| pristine | `2f28c372da15bec082e100bd0dfdea51` | `ec81cb73`, the mandated hash |
| patched | `d04166c8a76696277865fd07469e022e` | `/tmp/r11u4.patch` as submitted |
| fixed | `0b790313456c47969f76b67be91221f7` | + the face-(B) guard below |

Patch surface, audited: 1 production file + 28 probe files, `+1563 −0`,
`results/*.csv` untouched (0 hits), fence scan 0/0/0/0. Applies clean on a
clean `ec81cb73` worktree (`git apply --check`, rc 0).

## 2. THE REGRESSION — face (B) may not copy an unreduced aggregate

Face (B) replaces a port view's `param_assign` Rhs with a `clone_tree` of the
DEF view's Rhs whenever that Rhs is an `op75`. That is right only when the def
view's tree is ALREADY in the reduced form. Where the def view still holds the
source's `tagged_pattern` members, golden's port view holds the REDUCED
`op75 + struct typespec -> bare constant` — which our pristine emitter already
produced there. Copying the def tree over it destroys a judge-EQUAL cell.

Measured, `v6/dut.sv`, no override anywhere, real Surelog v1.87, `[ERROR] : 0`,
slang rc 0:

```
view           Rhs shape                            size
work@tif       op75 -> tagged_pattern -> constant     64
work@top.u     op75 + struct ts -> constant           32
work@top.a0.q  op75 + struct ts -> constant           32   <-- golden
```

Official judge, same arm, same golden:

```
v6/pris  slang_rc=0 cmp_rc=0   LHSheads=0     <-- EQUAL
v6/pat   slang_rc=0 cmp_rc=255 LHSheads=1     <-- NOT EQUAL   (regression)
v6/fix   slang_rc=0 cmp_rc=0   LHSheads=0     <-- EQUAL
```

The head the patch creates (`v6/w_pat/cmp.err`, LHS is golden):

```
LHS:
decompile:
ref_typespec: , id:89
|vpiActual:
\_struct_typespec: (bus_t), id:79, line:2:9, endln:2:44
RHS: <null>
```

`v5` (the same shape with a package localparam default) flips identically:
`cmp_rc=0` pristine → `cmp_rc=255` patched → `cmp_rc=0` fixed. `v3`'s
array-element views `a3.q`/`a4.q` lose their `CFG` cell the same way without
flipping the whole arm.

Four COMPARE-VISIBLE cells lost across three arms, none of them reachable from
either corpus.

### The fix

In the face-(B) branch only, decline the clone when the def view's tree still
holds a `tagged_pattern` anywhere. Pure addition, one predicate:

```
+ std::function<bool(const UHDM::any*)> hasTaggedMember4 = ...   // recursive
      if (((const UHDM::operation*)defRhs4)->VpiOpType() ==
-             vpiAssignmentPatternOp) {
+             vpiAssignmentPatternOp &&
+         !hasTaggedMember4(defRhs4)) {
```

It is conservative in the right direction: on every arm measured, face (B)
contributes NO agreement gain outside the reduced-def cell — the corpus
conversion `iface_array_elem_cfg_param` is exactly that cell (its def view's
Rhs is already `op75 + struct ts -> constant UINT:8`, no `tagged_pattern`), and
it still converts.

## 3. Arms

Twelve arms, all built with the real `surelog` v1.87 binary the harness names,
all recording `surelog rc`, `[  ERROR] : 0`, `slang rc`, `uhdm-cmp rc` and the
`^LHS:` head count (`ARMS.run.txt`). g1/g2/g3 are the implementer's grid,
re-run here from its own sources; v1–v9 are this pass's.

- v1 aggregate face inside the gen-bearing / text-multi defs
- v2 generic port, nested interface, package scalar, unpacked-array default, TYPE parameter
- v3 multi-view sharing, array-element views (plain + named modport), instance ARRAY
- v4 the fold-scope substitution shape (the OneNetRange cell), no-parameter interface, generate-for
- v5 minimal package-localparam aggregate, no override — **flips EQUAL→NOTEQUAL under the patch**
- v6 minimal inline aggregate, no override — **flips EQUAL→NOTEQUAL under the patch**
- v7 face (C)'s typespec-drop boundary: typed / untyped / dependent / package / signed operation defaults + a literal control
- v8 face (B) with POSITIONAL patterns (no `tagged_pattern`): struct, nested struct, package ref, unpacked array
- v9 defparam, genvar-dependent override, interface array walked by a generate for, receiving module with its own same-named parameter
- v10 the cell face (A) is most likely to break: a NAMED MODPORT connection into an **overridden interface ARRAY element** (`namedModportPortView9` requires `inst.arrayPath.empty()`, so the gate is TRUE and the stamp is cleared there)

Scores (`ARMS.scores.txt`), COMPARE-VISIBLE `param_assign` census only
(`pacen.py` keeps kind / vpiName / vpiDefName / vpiOpType / vpiDecompile /
vpiSize / vpiConstType / the value line / vpiOverriden / the typespec's
presence and actual — and no span, id, fullname or parent, because no
generated `Compare` reads one):

```
arm   golden rows   agree pristine   PATCHED       FIXED
v1        26            15           15  L0        15  L0
v2        53             7            7  L0         7  L0
v3        48            28           30  L2 <--    32  L0
v4        28            20           26  L0        26  L0
v5         4             4            3  L1 <--     4  L0
v6         4             4            3  L1 <--     4  L0
v7        63            44           49  L0        49  L0
v8        36            14           14  L0        14  L0
v9        36            20           20  L0        20  L0
g1        60            36           41  L0        41  L0
v10       36            23           23  L0        23  L0
g2        45            19           20  L0        20  L0
g3        13            10           10  L0        10  L0
```

**FIXED: TOTAL-LOST 0 on every arm. PATCHED: 4 lost across 3 arms.**

v10 settles face (A)'s riskiest cell by measurement: golden gives a named
modport into an OVERRIDDEN interface-array element `ovr=0` and the DECLARATION
default (`W 4`, not the instantiation's 9), while the scalar named modport in
the same arm keeps `ovr=1 / W 9`. Clearing the stamp on the array-element view
is right; the array-element exclusion inside `namedModportPortView9` is exactly
the line golden draws.

### Wide boundary — every committed arm of the interface passes

27 arms compiled from `r11u1repro`, `r11u3repro`, `r11v1repro`, `r11vu3repro`
with both binaries. 11 move. Each was re-measured against its own real
Surelog v1.87 golden: **LOST 0 on all 11**, `r11u1repro/grid1` +4 and
`grid2` +3 toward golden, the head UNCHANGED on every arm, and the official
`uhdm-cmp` line count equal or SMALLER everywhere (23 → 16 on grid3, vA, vD,
vJ). No arm flipped EQUAL → NOTEQUAL. The other 16 arms are byte-identical.

Scorer positive control (`ARMS.scores.txt`, tail): with the arguments swapped
every gaining arm reports LOST>0 and NAMES the cells — v3 4, v4 6, v7 5, g1 5,
g2 1. The scorer can see a loss.

Sharing control: the home views (`work@top.u_ov`, `work@top.u_df`), the def
view (`work@tif`) and the column-zero tail duplicates are byte-identical
between pristine and fixed on g1, including the home's `vpiOverriden:1`
stamps — face (A)'s in-place clear and face (C)'s in-place `Typespec(nullptr)`
do not reach a shared neighbour.

## 4. Gates (fixed binary unless said otherwise)

- goldens **23 PASS / 0 FAIL** patched-side and pristine-side; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**.
- every `cmds.txt` audited by binary PATH: u2r_pris 1742 → `pristine.bin`, u2r_pat 1742 → `patched.bin`, u2r_fix 1742 → `fixed.bin`, sl_pris 1531 → `pristine.bin` (and likewise for the sl patched/fixed sweeps).
- pristine sweeps reproduce the committed baselines: u2r `ct8rows` **PASS, every row byte-identical**, both modes (741/63/67); surelog 459/18 testflags.
- **u2r byteverify 2 / 1608 movers**, both of them `iface_array_elem_cfg_param`, both modes; SELFCHECK 1607/1608. **Not one `CMP_EQUAL` database moved a byte.**
- a-priori mover prediction, `vpredict.py`, INDEPENDENT of the implementer's col-0 dump heuristic and computed from the corpus SOURCES alone (a design with no interface cannot enter `emitInterfaceInstance`): 106 of 798 surelog tests, 71 of 825 u2r test dirs. Every actual mover falls inside it; 692 surelog and 754 u2r tests are asserted immovable a priori and none moved.
- the converting database is byte-deterministic: three consecutive runs of the fixed binary give one hash, three of the pristine binary give another, and both match byteverify's attribution.
- r11u1's fence (`§ ifacePortViewParamAssignsOnly`, 18 converted tests): all 14 u2r members `CMP_EQUAL` in both modes under the fixed binary, and none of them moved a byte.

## 5. Reproduce

```bash
bash tools/probe/r11v4repro/run.sh <pristine-binary> <candidate-binary>
python3 tools/probe/r11v4repro/vpredict.py surelog   # a-priori superset
python3 tools/probe/r11v4repro/vpredict.py u2r
```

`run.sh` rebuilds every golden with Surelog v1.87 from the arm sources, runs
both binaries, and scores. A LOST line on any arm is a regression.
