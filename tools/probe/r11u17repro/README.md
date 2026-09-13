# r11u17 — an unpacked-array net is never found, and a found target's operation Rhs is rebuilt bare

Base commit `76c8a58b`, worktree `/tmp/wt_r11u17`. Pristine binary md5
`5bbb42c0fbc7e2c76e95e6f70464d0ae` — the OPS-stated main-tree md5 at the
base, reproduced exactly by my own build. Law binary md5
`34374b757fe4a886cfd472ab3a0d403b`, reproduced by applying `/tmp/r11u17.patch`
to a FRESH `76c8a58b` worktree and rebuilding. The judge is the
official `uhdm-cmp` through `scripts/verify_golden.py`; everything in this
directory is measurement-only. `results/*.csv` ARE NOT EDITED BY THIS PASS.

**TWO uhdm2rtlil tests CONVERT in BOTH modes**, four row-modes, each confirmed
at `uhdm-cmp` rc 0 against the golden the sweep itself used:

    ibex_multdiv_fast        genscope_module_ctx_reset

u2r reads **761 CMP_EQUAL / 43 CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH modes**
against the base's 759/45/67. The surelog corpus is unchanged: 468/15 default
and 464/13 testflags, status identical row for row on both binaries.
`ibex_alu` is byte-corrected without converting and lands on a head of its own
(§7, R0).

## 1. The two heads, RE-MEASURED on my own pristine build

`uhdm-cmp` run directly on the golden the sweep itself used, one head per row
(`grep -c '^LHS:'` on **stderr**), identical in both modes:

| row | head | cmp lines |
|---|---|---|
| `ibex_alu` | `LHS: <null>` / RHS `array_net work@ibex_alu.imd_val_d_o` @ `24:29` | 51 |
| `ibex_multdiv_fast` | `LHS: <null>` / RHS `logic_var work@ibex_multdiv_fast.sign_a` @ `54:16` | 15 |

Both are `ref_obj::Actual_group` singular heads (`BaseClass.h` SafeCompare with
`lhs == nullptr` names the VALUE): golden's reference carries no `vpiActual`
and ours does. The instrument that turns "15 lines" into "n cells" is
`refcen.py`, sectioned to the JUDGE-REACHABLE elaborated listing by
`armcen.sh` (the `weaklyReferenced` tail is unreachable and must not be
counted — it is where our surplus `enum_const` stamps live).

**THE BRIEF'S R2 FRAMING IS STALE AND THE RE-MEASURE IS THE AUTHORITY.**
`ibex_multdiv_fast`'s head is NOT "the PROCESS analogue" (`mult3_sign_a =
sign_a;` at `:192`/`:222` is in the DEAD `gen_mult_single_cycle` arm and agrees
on both sides). It is a CONTINUOUS ASSIGNMENT: `assign mac_res_signed =
$signed({sign_a, mult_op_a}) * $signed({sign_b, mult_op_b}) + $signed(accum);`
at `ibex_multdiv_fast.sv:277-278`, inside `gen_mult_fast`.

Judge-reachable elaborated ref cells, golden against pristine:

    ibex_multdiv_fast   18 differing keys of 148  ->  7 of them are real bindings
                        (the other 11 are `enum_const` LINE INFO, and no
                         generated Compare reads a file or a line)
    ibex_alu            1 differing key of 203   ->  the array_net Lhs cell,
                        and nothing else (§7: the brief's "second family" is
                        a DEFINITION-view artefact, refuted)

## 2. DECODE — ONE producer read, TWO laws

`UhdmWriter::writeCont_assign` (Surelog v1.87
`src/DesignCompile/UhdmWriter.cpp:2120-2166`) is the only writer that binds a
cont_assign Lhs, and everything both heads do follows from its first six lines:

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
  if (var) {
    if (rhs->UhdmType() == uhdmoperation) {
      …clone_tree(assign)…
      any* rhstmp = m_helper.reduceExpr((expr*)rhs, invalidValue, …);
      if ((invalidValue == false) && rhstmp) assign->Rhs((expr*)rhstmp);
      ref_obj* ref = (ref_obj*)lhs; ref->Actual_group(var);
```

`bindVariable` (`src/DesignCompile/CompileStmt.cpp:3095-3155`) switches on
`function` / `task` / `begin` / `module_inst` and recurses past anything else,
so a gen_scope falls through to the module body. Its `module_inst` case
searches `Variables()` then `Nets()` **and nothing else**.

**§ genCaLhsArrayNetNeverBinds17 — an UNPACKED-ARRAY NET is in `Array_nets()`**
(attached at `UhdmWriter.cpp:4144`/`4291`), never in `Nets()`. `var` comes back
null, the whole `if (var)` body is skipped, and the Lhs ref keeps the
definition compile's empty `Actual_group`. An unpacked-array VARIABLE is an
`array_var` and IS in `Variables()`, so it binds: the split is NET vs VAR, not
"array". That is HEAD A, verbatim — `assign imd_val_d_o = '{default: '0};` in
`g_no_alu_rvb` over `output logic [31:0] imd_val_d_o[2]`, whose SCALAR siblings
in the same block (`bitcnt_result` … `imd_val_we_o`) all bind in golden.

**§ genCaBoundLhsOperationRhsUnbindsRhs17 — when the Lhs IS found and the Rhs
IS an operation, `reduceExpr` REBUILDS the Rhs and the rebuilt tree's
references carry no `vpiActual`.** Every reference in that Rhs comes back bare
— the block's own gen-locals included. That is HEAD B: `mac_res_signed` is the
module-level `logic signed [34:0]` at `:51`, so it binds; the Rhs is a product,
so it is rebuilt; and all five references (`sign_a`, `sign_b` and `accum` from
the module body, `mult_op_a`/`mult_op_b` from the generate block itself) lose
their actuals. The same two cells appear at `:380`, `assign sva_mul_fsm_idle =
mult_state_q == ALBL;`.

This is the fact `§ genCaDrivenOpenerIsGenLocalOnly` (r11u15) could not see:
that law says an Rhs reference in a generate scope keeps its DEFINITION
binding, and it is right — this is the one arm in which the definition binding
is thrown away and re-made.

**The two laws are mutually exclusive and arm `c20` proves it in one file**: a
module array-NET Lhs with a pattern Rhs over a gen-local. The Lhs is never
found, so the Lhs takes no actual (LAW 1) AND no clone happens, so the Rhs
gen-local KEEPS its actual (LAW 2 stands down).

## 3. THE GOLDEN GRID — 41 arms, every rc recorded

`grid/` carries one `dut.sv` per arm; `run.sh <binary> <tag>` builds the GOLDEN
(`surelog -parse -nobuiltin -nocache -sv`) and ours (`--single-unit
--nobuiltin`) and records **both** return codes plus the head count and cmp
line count; `armcen.sh <tag>` prints each arm's `refcen.py` verdict over the
judge-reachable elaborated section. `GRID.r11u17.txt` is the table.

**Every arm is `golden_rc=0 ours_rc=0` in both tags** — no arm is testing error
recovery. **AN ARM AGREEING AT rc 0 IS NOT AN ARM TESTING THE LAW**: every
verdict below is read off `refcen.py`, never off the cmp rc (arms `d03`, `d05`
and `d07` read `cmp_rc=255` at pristine AND under the law on the
assignment-pattern FOLD of §7/R0, which has nothing to do with either law, and
their ref census is 0 on both binaries).

**21 arms convert, 0 arms regress** (36 c/d arms; the 5 e-arms are R1's
residue and are byte-unchanged by design).

### LAW 2 axes — Lhs shape × Rhs shape × scope × driver

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| `c01` | module VAR Lhs, Rhs `src \| 32'd1` over a gen-local | UNBOUND | bound | UNBOUND |
| `c09` | the same with a module NET Lhs | UNBOUND | bound | UNBOUND |
| `c04` | a gen-local AND a module name in one Rhs | BOTH UNBOUND | both bound | BOTH UNBOUND |
| `c05` | the gen-local driven by a PROCESS in the block | UNBOUND | bound | UNBOUND |
| `c11` | two gen-locals in one Rhs | BOTH UNBOUND | both bound | BOTH UNBOUND |
| `c12` | the Rhs is a CONCAT | UNBOUND | bound | UNBOUND |
| `c14` | the Rhs is a UNARY op | UNBOUND | bound | UNBOUND |
| `c16` | the Rhs is a TERNARY | UNBOUND | bound | UNBOUND |
| `c17` | the Rhs is a REPLICATION | UNBOUND | bound | UNBOUND |
| `c18` | the Rhs is an EXPLICIT CAST `32'(src)` | UNBOUND | bound | UNBOUND |
| `c19` | a pattern Rhs over a module array VAR Lhs | UNBOUND | bound | UNBOUND |
| `c08` | the multdiv shape, `$signed({s,v}) * $signed({s,v})` | all four UNBOUND | all four bound | all four UNBOUND |
| `c23` | the same without `$signed` | UNBOUND | bound | UNBOUND |
| `c24` | one `$signed`, one literal | UNBOUND | bound | UNBOUND |
| `c25` | an UNSIGNED Lhs with the signed product | UNBOUND | bound | UNBOUND |
| `c26` | the multdiv shape in a CHILD INSTANCE, module Lhs | UNBOUND | bound | UNBOUND |
| `c22` | a gen-local Lhs with a MODULE NAMESAKE | Rhs UNBOUND (and golden points the Lhs at the NAMESAKE) | both bound | Rhs UNBOUND (Lhs still ours — R3) |
| `c02` | a gen-local Lhs, no namesake | BOUND | BOUND | BOUND |
| `c06` | the same, the gen-local process-driven | BOUND | BOUND | BOUND |
| `c27` | the multdiv shape in a CHILD INSTANCE, GEN-LOCAL Lhs | BOUND | BOUND | BOUND |
| `c03` | module Lhs, BARE-ref Rhs | BOUND | BOUND | BOUND |
| `c07` | module Lhs, `$unsigned(src)` Rhs (a sys_func_call) | BOUND | BOUND | BOUND |
| `c10` | for-generate, ELEMENT-SELECT Lhs `mv[i]` | BOUND | BOUND | BOUND |
| `c21` | a PART-SELECT Lhs | BOUND | BOUND | BOUND |
| `c13` | a NESTED gen-if with a module Lhs | UNBOUND | UNBOUND | UNBOUND |
| `c15` | the gen-local read through a BIT-SELECT | folds away | same | same |

### LAW 1 axes — Lhs object kind × scope × Rhs shape

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| `d01` | gen-if, module unpacked-array NET Lhs, pattern Rhs | `<none>` | `array_net` | `<none>` |
| `d06` | the same with a whole-ref Rhs | `<none>` | `array_net` | `<none>` |
| `d08` | the same in a for-generate | `<none>` | `array_net` | `<none>` |
| `c20` | the same with a pattern over a gen-local | `<none>` + Rhs BOUND | `array_net` + bound | `<none>` + Rhs BOUND |
| `d03` | gen-if, module unpacked-array VAR Lhs | `array_var` | `array_var` | `array_var` |
| `d04` | gen-LOCAL unpacked-array var Lhs | `array_var` | `array_var` | `array_var` |
| `d05` | module PACKED-array net Lhs | `logic_net` | `logic_net` | `logic_net` |
| `d09` | an ELEMENT-SELECT Lhs on the array net | no ref_obj | same | same |
| `d07` | MODULE-LEVEL unpacked-array VAR Lhs | `array_var` | `array_var` | `array_var` |
| `d02` | MODULE-LEVEL unpacked-array NET Lhs | `logic_net` | `array_net` | `array_net` (R1) |

## 4. A LANDED LAW NARROWED, WITH THE CELL THAT CONVICTS IT

`§ genCaSysCallArgBinds22` (r10earl22, `ExprEmit.cpp`) re-binds a reference
nested inside a `$system` call's ARGUMENT in a gen-scope cont_assign Rhs
"regardless of the LHS", overriding `suppressRefActual`. That reach was never
tested against a bindable Lhs, because before this pass the only suppression it
ever saw in that window was `childGen`'s. Its own witnesses all assign a
GEN-LOCAL Lhs (`qf22.sv`'s `mult1_res` and `pv_res`; arm `c27`), which
`bindVariable` never finds.

Arm `c26` is the counter-cell, measured before the law was written: a CHILD
instance, a MODULE-level Lhs, `$signed({sa,oa}) * $signed({sb,ob})` — golden
leaves all four operands bare and the PRISTINE binary bound them. Arms
`c08`/`c24`/`c25` are the top-module twins. So the landed law takes the Lhs
conjunct it always had and never tested (`caBoundLhsOpRhs17` in
`UhdmExporter.h`), and `c27`/`qf22` keep their population unchanged — the
boundary (§6) proves `qf22.sv` and `qe22.sv` byte-identical on the two
binaries.

## 5. PREDICTION — the mover set BY NAME, a priori, with a positive control

`pred17.py` reads **PRISTINE databases only**; it never needs the patched
binary, and a database with no flagged cell cannot move. Two scans:

* **LAW 1** — a `cont_assign` owned by a `gen_scope` whose Lhs `ref_obj`'s
  `vpiActual` is an `array_net`.
* **LAW 2** — a `cont_assign` owned by a `gen_scope` whose Lhs `ref_obj` HAS an
  actual (anything but an `array_net`) and whose Rhs is an `operation`; every
  `ref_obj` carrying an actual in that Rhs subtree is a cell.

Both are deliberate SUPERSETS — the dump cannot say which Rhs kinds OUR emitter
classifies as an operation, and it cannot see a suppression another law already
applies (it flags `c02`/`c27`, whose gen-local Lhs the law spares). The
requirement they answer is CONTAINMENT, and it holds.

**POSITIVE CONTROL** — the grid arms, scored by the same script from their own
pristine dumps: it fires on every real mover (`c01`, `c08`, `c20`, `c26`,
`d01`, `d06`, `d08`) and is SILENT on `c03`, `c07`, `c21`, `d04`, `d09`. A scan
that could not see would have been silent on the movers too.

On the two corpus head rows it names the mover set EXACTLY, from the pristine
databases alone and before the law binary existed:

    default+testflags/ibex_alu           LAW1 1 cell  g_no_alu_rvb.imd_val_d_o -> array_net
    default+testflags/ibex_multdiv_fast  LAW2 7 cells lhs=mac_res_signed: sign_a, mult_op_a,
                                                      sign_b, mult_op_b, accum
                                                      lhs=sva_mul_fsm_idle: mult_state_q, ALBL

and those are, cell for cell, the 2 and 14 order-blind dump lines the law
actually moves (§7 and the census below).

## 6. BOUNDARY over the landed passes' own arms

`bnd.sh` compiles a file list with BOTH binaries, normalises the dump (workdir
path, object ids and the output filename) and sorts it order-blind. It reads
the list on fd 3 with children `</dev/null` and asserts `PROCESSED == LISTED`.

Over the 44 arms of `tools/probe/r11u15repro/grid` (both landed binding laws),
`tools/probe/r10earl_repro/q{d,e,f}22.sv` (§ genCaSysCallArgBinds22 and
§ genCaOpDeepBindGenLocal20) and `tools/probe/r10buvm5repro/v2_seltrack.sv`
(the V-FIX seltrack arm) — **PROCESSED=48 LISTED=48, and exactly ONE database
moves**:

    qd22.sv   2 lines   `v1` @ 56:18 loses its actual

and that cell is `assign my2 = v1 ^ 4'h5;`, one of qd22's own **"module-LHS
negatives: nothing in these binds"**. Golden's elaborated `ref_obj (v1) @
56:18` has no `vpiActual`, so the mover goes **TOWARD GOLDEN**: pristine-wrong,
patched-right. AWAY-GOLDEN 0.

**POSITIVE CONTROL for the boundary gate**: the same harness run over a known
mover (`c01`'s `dut.sv`) and a known non-mover reads `MOVED=1`, `norm_delta=2`
on the first and `0` on the second — it can see.

## 7. WHERE `ibex_alu` LANDS, AND THE BRIEF'S SECOND FAMILY REFUTED

`ibex_alu` byte-corrects and does NOT convert — as the brief predicted, but NOT
for the reason it named, and the correction is measured, not argued.

Under the law its judge-reachable elaborated ref census is **0 differing keys
of 203** (it was exactly 1 at pristine — the array_net Lhs at `:1311`) and its
head MOVES to a
new object, one line further down the same generate block:

    assign imd_val_we_o = '{default: '0};        ibex_alu.sv:1312
      LHS  golden  constant 2'd0 (folded)
      RHS  ours    operation vpiOpType=75 (vpiAssignmentPatternOp) + tagged_pattern

29 cmp lines, both modes. **A cmp line count going from 51 to 29 with the head
OBJECT CHANGED is the new head's decompile size, not a partial fix**, and the
order-blind dump delta (§6's method, run on the row itself) is **2 lines and
they are the array_net actual and its `|vpiActual:` marker — nothing added**.

**THE BRIEF'S "SECOND FAMILY" IS REFUTED AT THE JUDGE-REACHABLE LEVEL.** The
claim was that golden keeps the ternaries at `ibex_alu.sv:269`/`:275` symbolic
where we fold on the constant `RV32B != RV32BNone`. That is true only of the
DEFINITION listing (`|uhdmallModules:`). In the ELABORATED listing the judge
walks, golden folds them exactly as we do — its `:269` Rhs is a `constant` at
`269:74` and its `:274` Rhs a `constant` at `275:79`, and ours are the same
shape. Chasing that family would have chased a definition-view artefact.

The real fold cell is the one in the head: an ASSIGNMENT PATTERN over a PACKED
target. Arms `d01` and `d05` reproduce it exactly (`assign we = '{default:'0};`
in a gen-if over `output logic [1:0] we` — golden `constant 2'd0`, ours the
pattern operation, 29 cmp lines), on BOTH binaries, and `d02`/`d03`/`d07` carry
its unpacked variants. It is a CONSTANT-FOLD surface, not a binding one, and a
sister pass of this block works the continuous-assignment fold face — so it is
R0 (§8) with its arms committed here rather than a second law in this pass.

Beside it, arms `e01`-`e05` measure the neighbouring fold ENCODING face, every
arm `golden_rc=0 ours_rc=0`:

| arm | conditional's selected branch | golden's folded constant | ours |
|---|---|---|---|
| `e01` | `1'b0`, 1-bit Lhs | `INT:0` sized | same — EQUAL |
| `e03` | `32'd0`, 32-bit Lhs | `INT:0` sized | same — EQUAL |
| `e05` | `'0`, true branch a bare ref | kept symbolic | same — EQUAL |
| `e02` | `'0`, 32-bit Lhs | `BIN:0` size 32, `vpiDecompile:'0`, constType 3 | `INT:0`, decompile `0`, constType 7 — **NOT equal** |
| `e04` | `'0`, 1-bit Lhs | `BIN:0` size 1, `vpiDecompile:'0`, constType 3 | `INT:0` — **NOT equal** |

So BOTH tools fold; when the selected branch is an UNBASED-UNSIZED literal
golden keeps that literal's own encoding through the fold and we re-encode it
as a plain integer. Wrong at pristine, byte-unchanged by this pass (R1).

## 8. Residues

* **R0 — `ibex_alu`'s new head is the PACKED-TARGET ASSIGNMENT-PATTERN FOLD.**
  `assign imd_val_we_o = '{default: '0};` (ibex_alu.sv:1312): golden folds the
  pattern to `constant 2'd0`, we emit `operation` opType 75 with a
  `tagged_pattern`. Arms `d01` and `d05` are the minimal repro and
  `d02`/`d03`/`d07` the unpacked variants. Wrong at pristine, unchanged here;
  clearing it is what converts the row.
* **R1 — `e02`/`e04`: an UNBASED-UNSIZED selected branch keeps its own encoding
  through the conditional fold.** Golden `BIN:0` / `vpiDecompile:'0` /
  `vpiConstType:3` at the Lhs width, ours `INT:0` / `0` / `7`. Wrong at
  pristine, unchanged.
* **R2 — `d02`: a MODULE-LEVEL unpacked-array NET Lhs binds the ELEMENT net.**
  Golden points `assign arr = '{default:'0};` at module scope to the
  `logic_net` named `arr` (`Nets()` holds the array's element net, and
  `bindVariable` finds it there), while we point it at the `array_net`. The
  GENERATE-scope twin finds nothing at all, which is LAW 1 — the two faces
  differ and only the gen-scope one is landed here. Wrong at pristine on both
  binaries.
* **R3 — `c22`: a gen-local Lhs with a MODULE NAMESAKE keeps the WRONG target.**
  `bindVariable` binds BY NAME, so golden re-points the Lhs `ref_obj` at the
  module-level `mv` even though the assignment's real target is the gen-local
  one; we bind the gen-local. The Rhs half of that arm CONVERTS under LAW 2
  (the name binds, so the clone runs). Wrong at pristine, unchanged.
* **R4 — the `enum_const` LINE INFO.** 11 of `ibex_multdiv_fast`'s 18
  differing elaborated ref keys are golden's `enum_const (ALBL), line:269:7`
  against our location-less `enum_const (ALBL)`. No generated `Compare` reads
  a file or a line, so it is judge-invisible — the row CONVERTS with all
  eleven still in place. It is recorded because a future census on that row
  will see them and must not chase them.
* **R5 — r11u15's `b15`/`b16` (per-assignment vs per-reference) and `b21`
  (a for-generate's module-level Lhs) are UNCHANGED**: every one of the 44
  r11u15 grid arms is byte-identical between the two binaries (§6).

## 8b. THE CORPUS — every mover named a priori, every mover attributed

**uhdm2rtlil, `byteverify.sh SELFCHECK=1` against my own pristine workdir:
6 movers of 1608**, `PATH_SETS_IDENTICAL`, self-check 1607 of 1608 flagged so
the gate can see:

    default/ibex_alu   default/ibex_multdiv_fast   default/genscope_module_ctx_reset
    testflags/ …the same three…

`pred17.py`, run over the 1608 PRISTINE databases before the law binary
existed, flags **14 databases (7 rows × 2 modes)**: the three movers plus
`gen_test5` (1020 cells), `ibex_pmp` (16), `gen_test8` (2) and
`ParameterInitializedByPartSelectOfParametersAssignedToVar` (1) — every one of
those four has a GEN-LOCAL Lhs, which `bindVariable` never finds and the law
therefore spares. CONTAINMENT holds: every measured mover is named.

**AWAY-GOLDEN 0 / MOVED-WRONG 0**, cell by cell, from the order-blind
path- and id-normalised whole-dump diff of each moved database:

    ibex_alu           2 lines   1311:12 imd_val_d_o   array_net -> golden's <none>
    ibex_multdiv_fast 14 lines   278:18 sign_a, 278:26 mult_op_a, 278:49 sign_b,
                                 278:57 mult_op_b, 278:79 accum, 380:31 mult_state_q,
                                 380:47 ALBL          bound     -> golden's <none>
    genscope_module_ctx_reset
                       2 lines   34:16 in_i           logic_net -> golden's <none>

Nothing moved in the other direction and no line was ADDED in any database.
`genscope_module_ctx_reset` is LAW 2 verbatim: `assign p_o = in_i ^
{WIDTH{1'b1}};` inside `gen_use`, whose Lhs `p_o` is the module's own output
net and whose Rhs is a `^`. Its ref census against golden goes to 0 and the row
converts in both modes.

**surelog: 5 movers of 960** (self-check 959/960), and ALL FIVE are the proven
UVM coin family — `default/{MiniAmiq, SeqDriver, SimpleUVM}` and
`testflags/{MiniAmiq, SeqDriver}`. Two independent facts convict the coin and
not the law:

* `pred17.py` run on those five PRISTINE databases flags **ZERO cells** in each,
  so neither law has anything to reach there; and
* the PRISTINE binary alone, run FOUR times on MiniAmiq's own command line,
  produced FOUR different databases (`9483ec5da550`, `839eecbf6096`,
  `7dadb6060f53`, `ab93f603d8d0`), and every pristine-vs-pristine order-blind
  delta is the SAME 4-line shape — one constant's `UINT` + `vpiDecompile`
  drawing a different value per run. The pristine-vs-law delta on each of the
  five is that identical 4-line shape.

The COUNT is a per-run draw and is not pinned; the family is pinned by NAME.

`ct8rows.sh` on the surelog corpus names exactly two rows, and both are the
WORKDIR PATH inside a `SURELOG_FAIL` log message (`LowMemLib`/testflags,
`LowMemPkg`/testflags) — my PRISTINE sweep produces the identical two against
the same baseline, so it is a workdir artefact, not a move. Status and
dump-column histograms are identical base-to-fresh in both modes, and
`ct8rows.sh law vs MY OWN PRISTINE` reads the same two and nothing else.

`rowheads.sh` is IDENTICAL on the two binaries (measured=12, SKIP-NOFILE=2,
UNKNOWN-NAME=0). Canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0`
(u2r); `ctcan2` PASS on both corpora; `canaudit.sh` audited=29 UNCOVERED=0
FENCE-BREACH=0. The protected databases by name are byte-SAME in both modes:
`InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex`
`e3e354129d5a`/`73a10e8217e5`, `YosysOldOr` `d68e0796d62c`, `SVSwitch`
`4842211c4030`, `YosysVerx` `6ccda350c24a`.

## 9. Instruments

* `refcen.py` / `refall.py` — r11u15's ref census, copied byte-for-byte: every
  `ref_obj` keyed by (vpiFullName, line:col) with the CLASS and NAME of its
  `vpiActual`, golden against ours.
* `armcen.sh` — the census SECTIONED to the judge-reachable elaborated listing
  (`|uhdmtopModules:` … the `weaklyReferenced` tail). It exists because
  `ibex_multdiv_fast`'s surplus `enum_const` stamps live in that tail and a
  whole-dump census counts them as differences the judge cannot see.
* `run.sh` — the 41-arm grid runner; golden and ours per arm, **both** rcs,
  head count, cmp line count.
* `pred17.py` — the a-priori mover prediction (§5), computed from pristine
  databases and scored on the grid arms as its positive control.
* `bnd.sh` — the boundary runner (§6), fd-3 file list, `PROCESSED == LISTED`.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied byte-for-byte unmodified.

## 10. Gates

`GATES.r11u17.txt` carries the transcript. All green:

1. both binaries built `-j 2`, md5s taken separately; pristine
   `5bbb42c0fbc7e2c76e95e6f70464d0ae` = the OPS-stated main-tree md5 at
   `76c8a58b`. (The main tree's own `build/slang-uhdm` is no longer a valid
   comparand — the master rebuilt it while integrating the NEXT pass.)
2. `tests/check_goldens.sh` 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false`
   0 PASS / 23 FAIL.
3. every `cmds.txt` audited BY BINARY PATH: 1531 + 1531 + 1742 + 1742, each
   workdir carrying one and only one of `/tmp/r11u17_bin/{pris,law}.bin`.
4. u2r both modes: `ct8rows.sh` names exactly the two law rows, quoted, both
   `CMP_NOTEQUAL -> CMP_EQUAL`; my own PRISTINE sweep reads
   `PASS: every row byte-identical to the committed baseline` in BOTH modes.
5. surelog `--mode both`: 468/15 and 464/13 on both binaries, status identical
   row for row; the only `ct8rows` rows are the two workdir-path artefacts the
   pristine sweep also produces.
6. `byteverify.sh SELFCHECK=1` against my own pristine workdirs: u2r 6/1608,
   surelog 5/960, every mover named a priori and attributed (§8b),
   AWAY-GOLDEN 0 / MOVED-WRONG 0.
7. canaries, ctcan2, canaudit, rowheads and the protected databases: §8b.
8. the boundary over the landed passes' 48 arms: PROCESSED=48 LISTED=48,
   one mover, attributed and scored TOWARD golden (§6).

## 11. THE DOC EDIT THIS LANDING IMPLIES — NOT IN THE PATCH, AND WHY

The patch surface is production + `tools/probe/r11u17repro/` only, as briefed,
so the scoreboard edit is NOT in it. It is stated here exactly, because it must
ride with the landing commit.

While this pass ran, the master landed `3343dab6` (v1.87 pass 15,
`struct_param_func_arg` + `struct_param_func_loop`), whose own doc hunk already
moved u2r 759/45 -> 761/43 in `SUPPORT_MATRIX.md` and `GOLDEN_EQUIVALENCE.md`.
The two conversion sets are DISJOINT, so a hunk written against `76c8a58b`
would have both conflicted AND under-counted.

**Applied on top of `3343dab6`, set both files to 763 / 41 in both modes:**

    SUPPORT_MATRIX.md
      | uhdm2rtlil | default   | 871 | 763 | 41 |
      | uhdm2rtlil | testflags | 871 | 763 | 41 |

    GOLDEN_EQUIVALENCE.md §3.3
      | uhdm2rtlil | default   | 871 | CMP_EQUAL=763 SLANG_REJECT=67 CMP_NOTEQUAL=41 | 804 | 763 (94.9%) |
      | uhdm2rtlil | testflags | 871 | CMP_EQUAL=763 SLANG_REJECT=67 CMP_NOTEQUAL=41 | 804 | 763 (94.9%) |

The surelog lines do not move: 468/15 default, 464/13 testflags.
