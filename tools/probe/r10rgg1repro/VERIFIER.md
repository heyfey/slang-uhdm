# r10rgg1 — ADVERSARIAL VERIFIER (vrgg1)

BASE `039295a`.  Fresh worktrees `/tmp/wt_vrgg1` (patched) + `/tmp/wt_vrgg1pris`
(pristine), both configured and built independently at `-j 2`.

## 0. REPRODUCTION — every headline number, bit for bit

| quantity | implementer claimed | verifier measured | |
|---|---|---|---|
| base binary md5 | `46ec7c0bc45b1db39ad166958072c784` | `46ec7c0bc45b1db39ad166958072c784` | EXACT |
| patched binary md5 | `20d8a03b9c1ecbea5cccdedad856cc33` | `20d8a03b9c1ecbea5cccdedad856cc33` | EXACT |
| patch md5 / lines | `82248a9f5586ab9d7d4b7c8f0f99653c` / 4836 | same, applies clean on FRESH `039295a` | EXACT |
| goldens patched | 23 / 0 | 23 / 0 | EXACT |
| goldens `/bin/false` | 0 / 23 | 0 / 23 | EXACT |
| u2r both modes, both binaries | 679 / 50 / 2 | 679 / 50 / 2 | EXACT |
| `ct8rows` u2r, 3 ways | 0 differing ROWS | 0, 0, 0 (over 731, 731, 1462) | EXACT |
| surelog both binaries vs committed | 0 differing ROWS / 1588 | 0 / 1588 both | EXACT |
| byteverify u2r | 0 / 1358, SELFCHECK 1357 | 0 / 1358, SELFCHECK 1357 | EXACT |
| byteverify surelog | 2 / 953 | 2 / 953 | EXACT |
| Rggen mover hashes | `455caa7c2e60` -> `188d8fc3c1cf` | identical pair | EXACT |
| ladder `default:Rggen` BEFORE | 98 rungs FIXPOINT | 98 FIXPOINT, and byte-identical to the COMMITTED `ladder_default_Rggen.txt` rung for rung (only the `budget=` and `secs=` lines differ) | EXACT |
| ladder AFTER | 70 rungs FIXPOINT | 70 FIXPOINT | EXACT |
| family census | 26 -> 0, 2 -> 0, all others unchanged, no new family | reproduced line for line (`vrgg1` re-ran `FAM=` histograms on both ladders) | EXACT |
| the 26 L1 rungs share ONE ours-side object | `ref_obj(RGGEN_OKAY)@:104:35-104:45#10646` | 26/26 that object, against 26 DISTINCT golden constants | EXACT |
| rung 1 unchanged | byte-identical | byte-identical | EXACT |
| R0 head base vs patched | byte-identical | byte-identical (`grep -c '^LHS:'` = 1 both) | EXACT |
| Rggen object delta | 44 fresh elab CAs + 2 param encodings, nothing else | 44 `vpiLhs`/`vpiRhs`/fresh constants, 46 added `BIN:00` = 44 + 2, and the ONLY removed lines are 2x{`UINT:0`,`vpiDecompile:0`,`vpiConstType:9`} | EXACT |
| golden has 44 at that site | yes | golden `hier_path(register_if.status)@104:11` = 135 dump lines, ours base 3 -> patched 135; CA count golden 135 = ours 135 | EXACT |
| residual `2'b00` gap 60 vs 58 | `enum_const` DECLARATION copies | golden 6 `enum_const(RGGEN_OKAY)` owners of a `BIN:00`, ours 4; `cont_assign` owners 44 = 44 and `param_assign` owners 10 = 10 | EXACT |
| canaries | all at their pins | InterfaceModPort `59a365f3ce2c`, BlackParrot `e3e354129d5a`/`73a10e8217e5`, YosysOldOr `d68e0796d62c`, SVSwitch `4842211c4030`, **YosysVerx `6ccda350c24a` BOTH modes `CMP_EQUAL,match`**, Earlgrey `7d55ccc8f53e` | EXACT |

**Scoreboard nondeterminism — INDEPENDENTLY CONFIRMED, and more strongly than
claimed.**  The implementer reported `c347da7b9a4a` (base) -> `0b350a340611`
(patched) and argued nondeterminism from 4 runs.  The verifier's own sweeps give
**the same two hashes with the binaries in the OPPOSITE roles**
(`patched=c347da7b9a4a pristine=0b350a340611`), and the verifier's third
binary's sweep does not move Scoreboard at all (1 mover, not 2).  A hash that
swaps sides between runs cannot be caused by the patch.  MEMORY.md "emitter
nondeterminism" class.

## 1. THE BATTERY — seven purpose-built arms, golden = real Surelog

`v1..v7_vrgg1.sv`, run through `r10earl49repro/varm.sh` with all three binaries.
`vca.py` reads every elab `cont_assign` keyed by its Lhs name and prints the Rhs
kind, all constant fields AND its located-ness (loc-less vs located is the whole
carrier of these laws); `grid52.py` reads the `param_assign` cells.
GUARD: a side that reads zero rows prints EMPTY and exits non-zero.

### v3 — the five prior fold laws' positions, each reading an enum member
| position | golden | pristine | patched | fixed |
|---|---|---|---|---|
| cont-assign, iface member, bare enum | fresh loc-less `BIN:00` sz2 | ABSENT | OK | OK |
| cont-assign, iface member, THROUGH a ternary | fresh loc-less **`INT:2` sz64 ct7** | ABSENT | ABSENT | ABSENT |
| net-decl-assign, bare enum | loc-less `BIN:10` sz2 | `ref_obj` | `ref_obj` | `ref_obj` |
| net-decl-assign, through a ternary | UNFOLDED `operation` | OK | OK | OK |
| UNTAKEN ternary branch | UNFOLDED `operation` | OK | OK | OK |
| member-LHS (`s1.m = E_B`) | fresh `BIN:10` sz2 | ABSENT | ABSENT | ABSENT |
| CAST (`2'(E_B)`, `2'(ternary)`) | UNFOLDED `operation` | OK | OK | OK |
| REPLICATION (`{4{E_A}}`) | fresh `BIN:00000000` sz8 ts=Y | ABSENT | ABSENT | ABSENT |
| REPLICATION over a ternary | UNFOLDED `operation` | OK | OK | OK |
| variable INITIALIZER | (no CA) | — | — | — |
| GEN-SCOPE localparam ref | fresh `BIN:10` ts=Y | `ref_obj` | `ref_obj` | `ref_obj` |
| UNTAKEN generate branch | nothing read | OK | OK | OK |

**The untaken-branch rule, the cast rule and the replication-over-ternary rule
all HOLD: golden leaves them UNFOLDED and so do we, in all three binaries.**
No cell in v3 is pristine-right -> patched-wrong.

### v2 — the L2 ternary walk in every param shape (9 measured cells)
enum-typed taken/untaken, `logic`-typed, HEX member, base-less `enum int`,
NESTED ternary, bare reference (depth 0), literal leaf, cast-wrapped leaf:
**8 of 9 exactly golden after the patch, 0 of 9 before.**  Untaken branches are
correctly not read (`P1`); an explicit cast correctly blocks the walk (`PB`);
a non-constant condition correctly does not fire.  One residue: R-A below.

### v4 / v7 — L1's boundary, and the fix's discriminator
L1 GENERALISES CORRECTLY, unclaimed by the implementer: a **MODPORT** port
dotted Lhs (`m.a = E_B`), a **TWO-LEVEL** dotted path (`vif.sub.q`), a
**4-state** enum member (`2'bx1` -> `BIN:x1`) and gen-scope iface-dot CAs are
each EXACTLY golden after the patch and ABSENT before.  An explicit enum CAST
Rhs (`e_t'(2'b10)`) golden leaves UNFOLDED and we correctly do not fold it.

## 2. WHAT THE VERIFIER FIXED — § ifaceDotEnumDefConstWins1

`v1_vrgg1.sv` / `v7_vrgg1.sv`, six and ten one-position cells:

| Rhs form | golden's elab CA Rhs | pristine | implementer | FIXED |
|---|---|---|---|---|
| `PK_OKAY` unqualified import | FRESH loc-less `BIN:00` sz2 | ABSENT | OK | OK |
| `L_OKAY` module-local | FRESH loc-less `BIN:00` sz2 | ABSENT | OK | OK |
| `PK_H` unqualified, HEX | FRESH loc-less `HEX:6` sz4 | ABSENT | OK | OK |
| **`p_v1::PK_OKAY` QUALIFIED** | **SHARED def constant @16:18 (LOCATED)** | ABSENT | fresh loc-less **WRONG** | **OK** |
| **`p_v1::PK_ERR` QUALIFIED** | SHARED @19:18 | ABSENT | WRONG | **OK** |
| **`p_v1::PK_H` QUALIFIED HEX** | SHARED @20:18 | ABSENT | WRONG | **OK** |

THE LAW.  The implementer's carrier ("REDUCIBILITY of the Rhs") is right about
*when* the fresh CA appears and wrong about *which object* it carries.  Surelog's
arm-2 reduce hands back the constant it has ALREADY installed: for the
`::`-QUALIFIED form the def view folded the enum const to a LOCATED constant
(the existing `§ pkgEnumRhs` `::`-gated rule a few lines below), so the elab Rhs
is a REPEAT of that object, not a second loc-less copy.  The discriminator was
therefore **already computed at the site** — "did the def view produce a
constant?" — and the shipped code simply consulted it second.  The fix is a
2-line precedence swap plus its evidence comment; it adds no predicate.

Rggen's own site (`assign register_if.status = RGGEN_OKAY;`) is UNQUALIFIED, its
def view keeps the `ref_obj`, and it therefore still takes the fresh arm:
**the Rggen database is BYTE-IDENTICAL between the implementer's binary and the
fixed one** (`cmp` clean), so the 98 -> 70 ladder result carries over unchanged.
`v1` dump-diff 138 -> 30 -> **6**, and the 6 that remain are three PRE-EXISTING
residues (a def-view `module_inst` vpiParent naming pair, and the `4'h6` vs `6`
decompile that IS this arm's uhdm-cmp head in all three binaries).

Fixed binary `7e9069e14f94a675f05d7745041c52cb`.  Full battery re-run on it:
goldens 23/0; u2r 679/50/2 both modes and `ct8rows` 0 differing rows vs the
committed CSV and vs base over 1462; surelog 0 differing rows over 1588 with
YosysVerx `CMP_EQUAL,match` both modes; byteverify u2r 0/1358 and 0/1358 against
the implementer's own workdir; byteverify surelog **1 mover** (Rggen only);
every canary at its pin; v2/v3/v4/v5/v6 cells byte-identical to the
implementer's binary — the fix touches nothing but the qualified form.

## 3. BOUNDARIES — 95 + 42 arms, and the five fold grids

`vbnd_rgg1.sh` (earl38/45/46/47/48/**49/50/51/52/53**) — **95 arms, 95
identical, 0 differing, 0 no-output**, for BOTH the implementer's binary and the
fixed one.  The earl49-53 fold grids (earl51 i-grids, earl52 a-grids) all HOLD.
`vbnd2_rgg1.sh` (the committed yos1 `vgrid` + `grid`, 42 arms) — identical
except two SYMMETRIC pre-existing non-outputs: `w15_ifaceport` (both binaries
emit the same `unconnected interface port` reject) and `v1_pkgonly` (a
package-only file for which SURELOG itself emits no database, so slang is never
even invoked).  Neither is a binary asymmetry.

## 4. RANKED RESIDUES — each with golden's exact answer, measured

1. **net-decl-assign of a bare enum constant** (`wire [1:0] w = E_B;`).  Golden
   folds to a LOC-LESS `BIN:10` sz2 ct3 — the SAME shape as L1, in a position L1
   does not reach.  Ours keeps the `ref_obj`.  Highest-value next step: it is
   the same mechanism one site over.  (v3)
2. **`int`-typed localparam through a ternary onto an enum member.**  Golden
   sizes the constant at the ENUM MEMBER's width (`sz=2`), not the parameter's
   (`sz=32`).  L2 deliberately keeps the folding arm's size, so value/ct/
   decompile are right and the size is wrong.  1 field, 1 cell.  (v2 `P3`)
3. **the OVERRIDE half of `§ enumConstOvEnc` does not walk the ternary.**
   `.OV((1'b1) ? E_B : E_A)` -> golden `BIN:10`, ours `UINT:2`; the read of that
   parameter inherits it.  L2 fixed the DEFAULT half only.  (v5 `OV`, `L1`)
4. **GEN-SCOPE localparam ternary fold is wrong at the VALUE level, pre-existing.**
   Golden `2'b10`/`BIN:10`/ct3; ours `-2`/`UINT:0`/ct9 — a decompile and a value
   that do not even agree with each other.  L2 does not reach gen-scope.  (v3 `GP`, `GR`)
5. **iface-dot cont_assign inside an INTERFACE BODY** is not emitted at all
   (both the unqualified fresh form and the qualified shared form).  (v7 `q0`, `q1`)
6. **cont_assign ternary / operation / member-LHS / replication folds** — the
   implementer's R3/R4 plus v3's `s1.m`, `s1.n`, `vif.wide`.  R3 is the proof
   that the enum encoding is LOST in a cont_assign ternary (`INT:0` sz64) while
   L2's param_assign keeps it, so these need their own Rhs-object policy.
7. **the constant-CALL fold constant is missing its `ref_typespec`.**  Golden's
   `vif.g = f_const(2)` Rhs carries `ref_typespec -> logic_typespec`; ours does
   not.  The implementer's grid marks this cell OK for both binaries — an
   over-claim, though a pre-existing one.  (`c1_rgg1.sv` C7)
8. **R0, the head** — unchanged and correctly not attempted.  The
   `setValueInInstance` compound-assign write-back is transcribed accurately
   against `UHDM/templates/ExprEval.cpp` and the verifier confirms the head is
   byte-identical in all three binaries.

## 5. TWO CLAIM ERRORS IN THE IMPLEMENTER'S REPORT (both in the safe direction)

* **Residue R2 is NOT a residue — the patch FIXES it.**  The report's grid says
  `vif.k = LE_SEL` stays SHARED in the patched binary.  Re-measured on the
  implementer's OWN `c1_rgg1.sv`: patched emits a fresh elab CA whose Rhs is the
  localparam's own constant `@23:27`, which is EXACTLY golden.  The mechanism is
  a second-order effect of L2 the report did not notice: `caReuseParamConst9`
  refuses a `vpiUIntConst` Rhs, and L2 turns `LE_SEL`'s constant from `UINT:0`
  into `BIN:00`, which unblocks that arm.  Reproduced independently on `v6`.
* **`c1_rgg1.sv` cell C7 is marked OK for both binaries** but ours is missing
  the golden `ref_typespec` (residue 7 above).

## 6. GATES, as run by the verifier (three binaries)

| gate | base `46ec7c0b…` | implementer `20d8a03b…` | fixed `7e9069e1…` |
|---|---|---|---|
| 1 build `-j 2`, md5 separately | rc=0 | rc=0 | rc=0 |
| 2 goldens / `/bin/false` | 23/0 | 23/0 · 0/23 | 23/0 |
| 3 u2r both modes | 679/50/2 | 679/50/2 | 679/50/2 |
| 3 `ct8rows` vs committed `gate_uhdm2rtlil.csv` | 0/731 | 0/731 | 0/731 |
| 3 `ct8rows` vs base, all rows | — | 0/1462 | 0/1462 |
| 4 surelog `--mode both` vs committed `golden_surelog.csv` | 0/1588 | 0/1588 | 0/1588 |
| 4 YosysVerx | `CMP_EQUAL,match` both modes | same | same |
| 5 byteverify u2r `SELFCHECK=1` | — | 0/1358 (SC 1357) | 0/1358 (SC 1357), and 0/1358 vs the implementer's own workdir |
| 5 byteverify surelog `SELFCHECK=1` | — | 2/953 (Rggen + the nondeterministic Scoreboard) | **1/953 (Rggen only)** |
| ladder `default:Rggen` | 98 FIXPOINT (= committed) | 70 FIXPOINT | 70 FIXPOINT, rung-for-rung identical to the implementer's |
| boundary arms (earl38-53) | — | 95/95 | 95/95 |
| boundary arms (yos1 vgrid+grid) | — | 40/42, 2 symmetric no-output | 40/42, same two |
| canaries | pins | all at pins | all at pins |

Every workdir's own `cmds.txt` was checked to name the binary that produced it
(`/tmp/vrgg1_slang_{base,pat,fix}`) and to carry exactly one golden cache hit, so
no number here can come from a stale binary or a wrong golden.
`results/*.csv` was READ-ONLY throughout; nothing was promoted.
