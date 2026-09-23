# r11u116 — pair A of the expression ground: the two ibex heads

**TWO ROWS CONVERT, BOTH MODES: `ibex_pmp` and `ibex_icache`.** With the law
binary each reads 0 uhdm-cmp lines and 0 heads, and the law sweep writes
`CMP_EQUAL`:

```
results/golden_uhdm2rtlil.csv:315:  ibex_icache,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:322:  ibex_pmp,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:1186: ibex_icache,testflags,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:1193: ibex_pmp,testflags,CMP_NOTEQUAL,decompile:,,
results/gate_uhdm2rtlil.csv:        ibex_icache,testflags,CMP_NOTEQUAL,decompile:,,
                                    ibex_pmp,testflags,CMP_NOTEQUAL,decompile:,,
LAW sweep:                          ibex_icache,default,CMP_EQUAL,,,differ
                                    ibex_icache,testflags,CMP_EQUAL,,,differ
                                    ibex_pmp,default,CMP_EQUAL,,,differ
                                    ibex_pmp,testflags,CMP_EQUAL,,,differ
```

* uhdm2rtlil: 801/3/67 → **803/1/67** in both modes. The one open row left is
  `stamped_gen_param` (pair B's ground).
* Surelog: 480/3 (default) and 474/3 (testflags) are unchanged.
* `results/*.csv` were NOT edited. The master promotes the rows.

Base `931a3c69`. Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `59c4a296bbc892558b6d637d7eff020e` | own worktree at `931a3c69`, `-j 2`; equals the OPS pin |
| **LAW** | `56ef1b3c917aee93e512a35107614e20` | this patch; the same md5 when the patch is applied to a FRESH `931a3c69` and rebuilt |

**Surface.** Two production files, both on this pass's ground:

* `src/EmitHelpers.h` holds every § block and switch, appended before the
  closing namespace.
* `src/ExprEmit.cpp` has four call sites (lines 15610, 16266, 17373, 18889).

`StmtEmit.cpp`, `TypeEmit.cpp`, `UhdmExporter.cpp`, `ModuleEmit.cpp`,
`ParamEmit.cpp`, `include/` and `results/` are absent from the patch. Neither
edited file uses `__LINE__`.

**Switches.** `R11U116_OFF=1` turns every law off. With it, the law binary is
byte-identical to pristine on all 318 grid arms (`evidence/OFF_grid.txt`) and on
all 46 moved control arms. Each face also drops alone: `R11U116_F1_OFF`,
`R11U116_F2_OFF`, `R11U116_F3R1_OFF` and `R11U116_F3R3_OFF`. Each switch
reverts exactly its own face's arms and no others (`evidence/SWITCH_grid.txt`,
`evidence/SWITCH_controls.txt`).

---

## Q1. The two rows at `931a3c69`

Measured with uhdm-cmp, LHS golden, on this pass's own pristine sweep. There is
one head per row, and both modes give the same count. The full heads are in
`evidence/HEADS_base.txt`.

| row | lines / heads | golden (LHS) | ours (RHS) |
|---|---|---|---|
| ibex_pmp | 64 / 1 | `constant` 240:72-240:82, parent `param_assign` 9:26-9:55, `vpiDecompile:32'h00000FFF`, size 32, `HEX:00000FFF`, ct 5, `ref_typespec (work@ibex_pmp)` → `int_typespec` 9:13-9:25 | the same span, parent and typespec, but `vpiDecompile:4095`, `UINT:4095`, ct 9 |
| ibex_icache | 50 / 1 | `ref_obj (work@ibex_icache.gen_fbs[0].gen_data_buf[0].g_fill_data_nr.fill_data_q.fill_data_q.BUS_SIZE)` 976:31-976:39, parent `operation` 976:29-976:39, `vpiActual` → `enum_const (BUS_SIZE)` | `constant` 976:31-976:39, `vpiDecompile:32`, size 32, `UINT:32`, ct 9, with a ts ref → `int_typespec` ibex_pkg 383:13 |

## Q2. Decodes, and where our emission happens

### FACE 1 — § loopCaParamReadKeepsLiteral116 (LANDED; `ExprEmit.cpp:18889`)

**Producer.** Surelog's identifier arm substitutes a parameter read from the
instance netlist (`CompileExpression.cpp:2880-2927`) or from the component
(`:2939-2966`). Both arms do the same thing:

```
result = UHDM::clone_tree(param_ass->Rhs(), &elaboratorContext);
result->VpiParent(param_ass);
```

Then they stamp the parameter's declaration typespec on the clone. The clone
carries the `param_assign` Rhs constant's OWN encoding. For `DmAddrMask =
32'h00000FFF` that is `HEX:00000FFF`, decompile `32'h00000FFF`, ct 5.

**Our site.** The read sits in a TOP-LEVEL loop-generate body
(`g_access_check[c]`) of the top module. That is the `genCaLoopParamFold`
window. It found the module's `param_assign` (`pa9`) and then minted a FRESH
decimal: `UINT:<value>` at the declared width (the `c9` mint, `ExprEmit.cpp`
~18880). The encoding copy already existed on two sibling windows:

* § genProcParamFold's `paSrc9`, for the always_comb twin (grid `ac`);
* § genCaTopLoopParamPaCopy105's `encSrc105`, for the child-instance twin
  (grid `ch`).

The top-module CA window was the one left out.

**The law.** In `genCaLoopParamFold`, for a TYPED PREDEFINED-INTEGER parameter
whose elaborated `param_assign` Rhs is a constant, the mint takes that
constant's encoding. It goes through `adjustCopiedParamConst64` (called here;
defined in ParamEmit.cpp, which is not edited) and `baseSpellingOk105`, the same
two guards `encSrc105` uses. Each field is written ONCE: the encoding is
computed before the first write, so no discarded string is left in the
serializer's table. The law3 binary wrote each field twice, and its F1 arms were
larger by 16-27 bytes with byte-identical dumps.

### FACE 2 — § nestedGenProcLhsKeepsRef116 (LANDED; `ExprEmit.cpp:15610`)

**Producer.** A generate block is its own `DesignComponent`. Its param_assigns
hold only its own localparams. An UNQUALIFIED package-parameter read inside a
NESTED generate scope's process therefore finds no substitution in
`compileExpression`. Surelog mints the `ref_obj` and calls
`component->needLateBinding(ref)` (`CompileExpression.cpp:2856-2867`).

`UhdmWriter::lateBinding` (`UhdmWriter.cpp:3297`; the mint is at `:3957`) then
answers a package name with `mod->getValue(name)`. It mints a fresh LOC-LESS
`enum_const` carrying the value (`UINT:32`, decompile `32`, size 32) and
parents it at the ref.

**What the `enum_const` is.** It is NOT a package enum. It is this per-reference
late-binding clone: one per ref, listed in the `_weaklyReferenced` tail (all
four BUS_SIZE refs at 976:31, :41, :72, :82 carry one). Nothing on that road
reads the SIDE of the assignment.

**Golden grid f2.** Every left-hand position keeps ref + `enum_const` exactly
like the right-hand side:

* the indexed-part-select base operand and its width (`976:31` and `:41` are
  the ibex cells);
* a bare bit-select index;
* both part-select bounds;
* an index operation.

This holds in always_ff, always_comb and initial, at depth 2 (for in for),
depth 3 (if in for in for: the ibex shape) and if-in-for, for wildcard and
explicit imports.

**Our site.** § genNestedScopePkgParamNoFold24 (`ExprEmit.cpp` ~15604) had
`!inLhs`. The law admits `inLhs` when `inGenScopeProc`. Every other gate of law
24 is inherited unchanged:

* the nesting test;
* `!defGenProcessEmit`;
* no `::`;
* `!currentTf`;
* `!inParamInit`;
* the package-scope branch.

The encoder is law 24's own.

**Fullname doubling (decoded, deliberately not chased).** Golden names the LHS
base-index ref `…g_fill_data_nr.fill_data_q.fill_data_q.BUS_SIZE`. That is
Surelog's indexed-part-select naming: the select's own fullname
`…fill_data_q.fill_data_q` is used as the prefix. Our RHS twin already carries
the single form (`…fill_data_d.BUS_SIZE` against golden's
`…fill_data_d.fill_data_d.BUS_SIZE`), which is law 24's FULLNAME NOTE.
Fullname is not a Compare field. A fullname-keyed scorer (`cells114.py`) lists
these cells as `WRONG` on 18 f2 arms. The fullname-free scorer (`cells116.py`)
reads them EQ.

### FACE 3 R1 — § impCopyCatReadIsRef116 (LANDED; `ExprEmit.cpp:16266`)

Pass 114 decoded this rule for case items only. `CompileExpression.cpp:2939-2966`
substitutes an imported parameter from the module's param_assigns only under
`reduce == Yes || (paramFromPackage && Rhs is constant)`. A concat-bearing
initializer's module copy stays an OPERATION, so the read stays the
module-scoped `ref_obj` with NO actual.

The rule holds at every module-body position: an if-condition operand, an
assignment Rhs, a `!=` operand, an `&` operand, and a continuous-assign Rhs and
operand (grid f3 r1_*; pass-114 b05).

The law runs in the package-parameter arm, before the fold. It uses pass 114's
own three predicates: the read is unqualified, `concatBearing114(init)` holds,
and `impCopyRhsNonConst114(parent, name) == 1` (a generate scope on the chain
declines). It is fenced away from:

* case items (the StmtEmit arm owns them);
* subroutine bodies (golden refs them too, residue R1f);
* parameter initializers;
* both generate-scope windows (residue R1g).

### FACE 3 R3 — § caseItemPkgFoldTs116 (LANDED; `ExprEmit.cpp:17373`)

A case-item read of a literal-valued imported parameter is the same substituted
clone as an operand fold. Golden stamps `ref_typespec (<module>)` → the
parameter's typespec on it, exactly like the `x == P_LIT` operand (b05). Ours
had none, because the materialized-import stamp's position list did not include
a `case_item` parent.

The law adds that position to the existing stamp (`importedParamDefTs`,
unqualified only). It applies only to a TYPED parameter (`typedPkgParam`) with
an INTEGER-LITERAL initializer (`caseItemTs116Lit`).

The literal fence was convicted on the pass-114 verifier's grid. With it absent,
the law2 binary stamped `v11u114repro` set1 d02, d07, d10, d17 and set2 m01. In
each of them `P` is another parameter, a conditional, a concat or a member
select. The value encoding there is already wrong (`UINT:5` where golden copies
`8'h5`), so the stamp only moved a wrong cell to another wrong cell. With the
fence all five are byte-identical to pristine.

### FACE 4 — NOT LANDED (grid-measured residues, see §7)

## Q3. The golden grids (`grid/`, written by `mkgrid116.py`)

Each arm is a `dut.sv` file. Golden is the pinned Surelog in the testflags form
(`grid116.sh`). A CELL is (arm, read span). `cells116.py` scores the SORTED
MULTISET of compare-visible fields over every object that starts at the span,
per section (DEF/TOP). The fields are:

* kind and name;
* value, size, decompile and const type;
* the typespec's actual KIND;
* the actual's kind.

Parent and fullname are out of the key. The golden-vs-golden calibration reads 0
NE on every grid.

| grid | shape | arms | cells | pristine EQ/NE | law EQ/NE | moves |
|---|---|---|---|---|---|---|
| f1 | 7 literal bases (`32'h`, `32'o`, `32'b`, `32'd`, unsized decimal, `'h`, narrower `12'h`) × 6 homes (module header `int unsigned`, module localparam, package, untyped header, `logic [31:0]` header, gen-scope localparam) × 5 containers (top loop-gen CA `lg`, if-gen CA, module CA, loop-gen always_comb, child-instance loop-gen) × 7 positions (operand under `~`/`&`, bare, var_select index op, compare, arithmetic, both part-select bounds, LHS index) | 210 | 1680 | 1120 / 560 | 1190 / 490 | 70 NE→EQ, 0 EQ→NE, 0 NE→NE shape changes |
| f2 | 4 nestings (top loop `g1`, for-in-for `g2`, if-in-for-in-for `g3`, if-in-for `gi`) × 4 containers (always_ff, always_comb, CA, initial) × 5 kinds (wildcard pkg, `p::P`, module param, module localparam, explicit import) | 80 | 696 | 478 / 218 | 568 / 128 | 90 NE→EQ, 0 EQ→NE, 0 NE→NE shape changes |
| f3 | R1 (6 contexts × 2 imports) and R3 (8 contexts × 2 imports) | 28 | 130 | 20 / 110 | 80 / 50 | 60 NE→EQ, 0 EQ→NE; 4 NE→NE rows are multi-view cells whose DEF half moved TO golden and whose TOP half is a pre-existing structural difference (unchanged) |

What the f1 grid measured:

* Golden copies the elaborated `param_assign` Rhs in `lg`, as it does in
  always_comb and in a child instance:
  * `32'h`, `32'b`, narrow `12'h` and unsized `'h` stay HEX/BIN at size 32;
  * `32'd4095` is `INT:4095`, ct 7;
  * `32'o7777` and a plain decimal are `UINT` (Surelog folds octal).
* Face 1 lands exactly the 70 `lg` cells of the two typed-int homes (mh, ml):
  5 bases × 7 positions × 2 homes.
* The octal/decimal controls are unchanged, and so are all module-CA,
  if-gen, always_comb and child cells.

What the f2 grid measured:

* Face 2 lands the 90 left-hand cells of g2/g3/gi × ff/cb/in × w/e.
* The `p::P`, module-param, localparam and top-level (`g1`) arms stay as they
  were.

Controls: the pass 107-115 grids (1325 arms in `r11u115repro`, `v11u115repro`,
`r11u114repro`, `v11u114repro`, `r11u113repro`, `v11u113repro`,
`r11u112repro`, `r11u111repro`, `r11u109repro`, `r11u108repro`,
`r11u107repro`, `r11u110repro`, `v11u110repro`, `v11u111repro`,
`v11u112repro`):

* **1279 arms are byte-identical to pristine.**
* 46 arms move: 40 through R1 (the r11u111 f5 import-copy grid, v11u111 brk/f5,
  r11u114 b05/c01-c03, v11u114 e05/h02/h07/h08/p01) and 6 through R3 (r11u114
  b01/b06/b07/b08/b10, v11u114 e06).
* Scored with `cells114.py` (golden, pristine, law): 177 TO cells, **AWAY 0,
  WRONG-GAINED 0**.
* Arms whose law count rose: r11u111 e14 46→50 and v11u111 x59 46→50 (the head
  moved deeper in the same object after a TO cell). b05 46→30, h02/h08 42→30,
  e22 46→17, and many 46/17→0.

## Q4. The laws (each droppable alone; decodes in the § blocks in `EmitHelpers.h`)

| § | switch | window | gates |
|---|---|---|---|
| loopCaParamReadKeepsLiteral116 | `R11U116_F1_OFF` | `genCaLoopParamFold` (top-level loop-gen CA, top module) | typed predefined-integer param; elaborated pa Rhs is a constant; `adjustCopiedParamConst64` && `baseSpellingOk105`; not the `encSrc105` window |
| nestedGenProcLhsKeepsRef116 | `R11U116_F2_OFF` | law 24's window, process Lhs | `inGenScopeProc`; all law-24 gates |
| impCopyCatReadIsRef116 | `R11U116_F3R1_OFF` | package-param fold, module body | unqualified; not a case item / tf / param init / gen window; `concatBearing114`; `impCopyRhsNonConst114 == 1` |
| caseItemPkgFoldTs116 | `R11U116_F3R3_OFF` | the materialized-import stamp | `case_item` parent; `typedPkgParam`; integer-literal initializer |

## Q5. Census (`census116.py`), a priori, on the PRISTINE databases

The census parses each pristine dump's indent tree and counts the shape each law
rewrites:

* **C1 (F1):** an elaborated UINT constant in a top-module top-level loop gen
  scope. Its source text is an identifier whose instance param_assign Rhs is a
  non-UINT constant.
* **C2 (F2):** a constant under an assignment's vpiLhs, in a process nested in
  two or more gen scopes. Its text names a package parameter.
* **C3 (R1):** a module-body constant whose text names an imported parameter
  with an OPERATION module copy.
* **C4 (R3):** a case-item constant with no typespec whose text names an
  imported parameter with a constant copy.

**Positive controls.** Every one fires on the grid: mh_h_lg C1=14, g3_ff_w
C2=20, r1_ac_w C3=7, r3_ac_w C4=4. On the pristine target rows, ibex_pmp gives
C1=4 and ibex_icache C2=16.

**Corpus result.** 2568 pristine databases (uhdm2rtlil + surelog, both modes).
Nonzero:

```
u2r/default/ibex_icache    C2=16      u2r/testflags/ibex_icache  C2=16
u2r/default/ibex_pmp       C1=4       u2r/testflags/ibex_pmp     C1=4
```

The other 2564 are zero, with 0 errors. **Predicted movers: ibex_pmp and
ibex_icache, both modes, and nothing else** (plus the documented
pristine-nondeterministic UVM rows).

## Q6. Gates (law binary `56ef1b3c…`, `evidence/GATES.txt`)

1. **Builds.** Both use `-j 2`.
   * Pristine is `59c4a296…`, which equals the pin and the main tree.
   * The law binary is `56ef1b3c…`. A FRESH `931a3c69` + the patch
     (`git apply` rc 0) rebuilds to the same md5.
   * Both binaries were frozen (`chmod 555`) before any sweep. Every
     `cmds.txt` names the frozen law binary: surelog 1531/1531, u2r 1742/1742.
2. **Goldens.** 23 PASS / 0 FAIL; `/bin/false` 0 PASS / 23 FAIL.
3. **u2r both modes.** 803/1/67 in each mode. The row-join against
   `results/gate_uhdm2rtlil.csv` and `results/golden_uhdm2rtlil.csv` (both
   modes) differs in exactly the four quoted rows. Checks: `ct8rows` names
   them; `canaries` ok=8 changed=0; `ctcan2` PASS.
4. **Surelog `--mode both`.** The STATUS histograms are identical to
   `results/golden_surelog.csv`: default 480/3, testflags 474/3. The
   whole-row diff differs in two places, both environment:
   * **Earlgrey_0_1**, both modes: the dump COLUMN is `differ` → blank. This
     is the uhdm-dump timeout draw. The DATABASES are byte-identical to
     pristine (`8bdf25272e08` default, `59d0ee6d10c3` testflags), and the
     pristine sweep drew the same blank on default.
   * **LowMemLib/LowMemPkg** testflags: the SURELOG_FAIL detail embeds the
     workdir path.
   * `canaries` reads ok=50 changed=2; the 2 are those Earlgrey dump columns.
     `ctcan2` PASS; `canaudit` PASS.
5. **Byteverify, SELFCHECK=1, against own pristine workdirs.**
   * u2r: **MOVERS 4/1608**. These are exactly the census-predicted ibex_pmp
     and ibex_icache databases, both modes. Selfcheck 1607/1608.
   * Surelog: MOVERS 6/960, all in the UVM family: MiniAmiq ×2, SeqDriver ×2,
     SimpleUVM/default and Scoreboard/default. Attributed order-blind (sorted
     dumps, ids stripped): 4 lines each (the documented `UINT`/`vpiDecompile`
     line-number class), and Scoreboard/default reads 0 lines (the order
     coin). All five UVM rows stay CMP_EQUAL. Selfcheck 959/960.
   * Protected databases are byte-identical to pristine in both modes:
     * SVSwitch `4842211c4030`;
     * YosysVerx `6ccda350c24a`;
     * InterfaceModPort `59a365f3ce2c`;
     * BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`;
     * YosysOldOr `d68e0796d62c`;
     * Earlgrey_0_1, as in item 4.
   * The law2 binary (the same laws before the R3 literal fence and the F1
     single-write) gave the same u2r movers and UVM-only surelog movers.

The two rows' whole-dump order-blind distance (default mode, sorted dumps, ids
and file paths normalised) goes down with the laws. The remaining lines are
judge-invisible (fullname and parent exactness, and the weaklyReferenced tail):

* ibex_pmp: 5800 → 5776;
* ibex_icache: 7120 → 6784.

## 7. Residues (ranked)

* **R0 — none on these two rows.** Both convert. The campaign's last open row
  is `stamped_gen_param`, on pair B's ground.
* **R4a — face 4, the var_select index substitution (f1: 14:20/18:13 in
  `ac`, 17:18 in `lg`/`ch`, all 7 bases × typed homes = 42 cells).**
  * Golden: the `M` inside `a[c][M % 32]` (always_comb) and inside the LHS
    `o7[c][M % 32]` (CA and process) is the substituted constant in TOP.
  * Ours: TOP `operation` + `ref_obj`. The var_select index path does not
    reach the fold windows.
* **R4b — face 4, a qualified `p::P` read in a generate scope (f2 `*_q`).**
  * Golden stamps `ref_typespec` → `int_typespec` on the folded indexed-part
    WIDTH (both sides, every nesting depth).
  * Ours folds bare: the stamp's `::` exclusion covers only `caPsOpFold9`.
* **R4c — the top-level loop-gen PROCESS (f2 `g1`).**
  * `ff`/`cb`: golden stamps the ts on the folded package-param reads; ours
    has none.
  * `in` (initial): golden keeps ref + `enum_const` at every position (no
    instance: `compileInitialBlock`); ours folds.
* **R4d — the nested-gen CA left-hand side (f2 `g2`/`g3`/`gi` × `ca`).**
  Golden keeps ref + `enum_const` on the CA Lhs too. The CA Lhs emission never
  runs with `inGenScopeCaRhs`, and the Lhs window flags are set in
  ModuleEmit.cpp (fenced). **STOPPED at the decode.**
* **R1u / R1v — face 1's declined homes.**
  * An untyped header parameter: golden has no ts on a `32'd`/unsized value,
    and size -1 on an unsized based one.
  * A `logic [31:0]` parameter: golden's clone carries a `logic_typespec`; the
    mint builds an `int_typespec`.
  * `pk_*`: a package parameter in a gen scope. Golden writes the ADJUSTED
    form (`32'hFFF` for `12'hFFF`, `INT:4095` for `32'd4095`); ours writes the
    raw literal.
  * All of these are f1 cells, unchanged.
* **R1f / R1g — R1's declined contexts.** A subroutine body (golden refs) and
  the generate-scope windows (golden refs in DEF and TOP). These are f3 cells,
  unchanged.
* **R3t — R3's declined kinds.** A typedef-typed parameter (`w_t P_TD`,
  golden's `logic_typespec`) and an untyped one (`P_UNT`, golden's
  `int_typespec`). The first has no `importedParamDefTs` object. The second
  hits the untyped-typespec residue R1b of pass 113 (ParamEmit, fenced).
* **Exactness (not Compare fields).**
  * The doubled indexed-part-select fullname
    (`…fill_data_q.fill_data_q.BUS_SIZE`), on both sides.
  * DmBaseAddr's golden parent is the `==` operation, where the clone's parent
    is the param_assign.
* **Ops trap found here.** The binary does not truncate an EXISTING `-o`
  file: rerunning into the same path left stale trailing bytes (306/318 false
  "differs"). Write every database to a fresh path (`grid116.sh` removes it
  first; `switch116.sh` uses `mktemp`).

## Scripts

| script | what |
|---|---|
| `mkgrid116.py` | writes `grid/f1`, `grid/f2`, `grid/f3` |
| `grid116.sh` | golden + N binaries per arm, parallel `-P 3`, records rc, uhdm-cmp line/head counts |
| `cells116.py` | per-cell multiset scorer (fullname/parent-free); `TOKRE` picks the read tokens |
| `census116.py` | the a-priori C1-C4 census over pristine databases (dumps cached under `$CENDIR`) |
| `switch116.sh` | per-switch revert check (`LAWTAG` names the law output) |
| `sweep116.sh` | own-workdir sweep driver (`WDROOT`, same-length tags) |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `byteverify.sh`, `ct8rows.sh` | the battery, copied from `r10uvm221repro` |
