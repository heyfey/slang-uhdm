# r10rgg12 — § elabVarRangeCallScopeDecl12: the symbolic-call RANGE BOUND binds in the DECLARING scope, not in `currentScope`

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge.  **BASE `c40ed40`.**  `results/*.csv` was READ ONLY and is
untouched.  **Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS
CONVERTED** — this pass says so up front.

Target: `default:Rggen`'s official head after r10rgg11 (104 cmp lines, 1 head) —
the LEFT bound of the packed dimension of
`logic [NEXT_N-1:0][WIDTH-1:0] next_data;`
(`rggen-sv-rtl/rggen_or_reducer.sv:66:9-66:21`), in the instance
`work@rggen.u_block_0.g_register_6.u_register.u_register_common.u_read_data_mux.g.u_reducer`:

```
golden : operation op 11 (vpiSubOp) @66:10-66:18
           [ func_call get_next_n( constant BIN:…10  vpiSize 400  vpiConstType 3 ),
             constant UINT:1 vpiSize 64 vpiConstType 9 ]
ours   : constant INT:0  vpiSize 64  vpiConstType 7   @66:10-66:16
```

**RESULT.  THE HEAD IS CLEARED.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): **104 → 64 cmp lines**, and
  the head object moves to a **DIFFERENT FAMILY** (§ 9, R0).  A cmp line count is
  the head OBJECT's decompile size, so that number is **not** a progress metric
  and is not reported as one.  The arbiter is the whole-dump diff below.
* **The whole-dump path-normalised diff of Rggen, base vs patched, is the
  TWELVE folded bound constants and nothing else** — 61 removed / 493 added
  lines over 1,580,412 dump lines a side, every removed line one of the twelve
  `constant … INT:0/INT:4 sz 64 ct 7` objects
  (`DUMPDIFF_rggen_base_vs_pat.txt`).
* **The thirteen `next_data` `logic_typespec` subtrees are now BYTE-IDENTICAL to
  golden**: the sectioned diff of those blocks is **576 lines before, 0 after**.
* Range-bound census over the WHOLE Rggen database (29,894 rows):
  **TO-GOLDEN 12, AWAY-GOLDEN 0, MOVED-STILL-WRONG 0**.
* Corpus: **0 movers over 1358 uhdm2rtlil databases**; **exactly 1 mover over
  956 surelog databases — `default/Rggen`, the target**, which is precisely the
  set predicted from the pristine base databases before the patched sweep was
  read (§ 7).
* **0 differing ROWS** in either corpus, either mode, status AND dump column,
  against the committed baselines AND against my own base sweeps.

---

## 1. THE HEAD, decoded from the PRISTINE cmp LOG

`HEAD_R0_BEFORE_default_Rggen.cmp`, verbatim (LHS is ALWAYS golden):

```
LHS: operation, id:60675, line:66:10, endln:66:18   |vpiParent: \_range: id:60625, 66:9-66:21
     |vpiOpType:11
     |vpiOperand: \_func_call: (get_next_n), id:60626, line:66:10, endln:66:16
                    |vpiArgument: \_constant: 64:58-64:68  vpiSize:400  BIN:…0010  vpiConstType:3
                    |vpiFunction: \_function: (work@rggen_or_reducer.get_next_n)
     |vpiOperand: \_constant: 66:17-66:18  vpiDecompile:1  vpiSize:64  UINT:1  vpiConstType:9
RHS: constant,  id:43191, line:66:10, endln:66:16   |vpiParent: \_range: id:43190, 66:9-66:21
     |vpiDecompile:0  |vpiSize:64  |INT:0  |vpiConstType:7
```

**THE OWNER IS THE `range`'s `Left_expr`, and the failing field is `VpiType`.**
`range::Compare` (`UHDM/build/generated/src/range.cpp:78-93`) reads
`VpiSize`, then `SafeCompare(Left_expr)`, then `SafeCompare(Right_expr)` — and
nothing else, no `vpiParent`.  The two `range` objects are the SAME object on
both sides (`66:9-66:21`), the `VpiSize` compare passes, and `SafeCompare`'s
singular overload fails on the first field a `BaseClass::Compare` reads, the
object TYPE: golden's `operation` against our `constant`.  So the head is not a
value mismatch at all; it is a bound golden left as an EXPRESSION and we FOLDED.

Two facts read straight off the same dump fix the shape of the answer:

* the SECOND dimension of the same declaration, `[WIDTH-1:0]`, is FOLDED by
  golden in the same typespec (`constant INT:33 sz 64 ct 7`).  Golden folds
  range bounds; this one is the exception.
* the `func_call`'s span is `66:10-66:16` — the span of the `NEXT_N` TOKEN, not
  of the call in line 64.  Golden **substituted `NEXT_N` by a CLONE of its own
  `param_assign` Rhs and re-spanned the clone at the identifier**: r10rgg11's
  § genLpPortConnValue11 mechanism (`clone_tree(param_ass->Rhs())` +
  `populateCoreMembers`), in an expression position instead of a port actual.
  The clone's ARGUMENT keeps its own span (`64:58-64:68`, the `SUB_N_LIST`
  token), because `populateCoreMembers` re-spans only the top node.

`CompileExpression.cpp:3986-4030` is the site: `compileRanges` builds each bound
with `compileExpression(... reduce)` and then calls `reduceExpr` on it.  With
`NEXT_N` substituted by an unreduced `func_call`, `reduceExpr`'s `vpiSubOp` arm
has no constant to work with and **the operation survives**.  Nothing in this
pass patches Surelog; the mechanism is decoded, then modelled.

## 2. WHAT WAS ACTUALLY BROKEN — AND IT WAS NOT THE MODEL

`slang-uhdm` **already had** this law: `makeTypespec`'s symbolic-call bound arm
(`TypeEmit.cpp` ~4063, keyed on `elabParamCallSymbolic`), landed for
`FuncInModule`.  It fired on **1 of the 13** `rggen_or_reducer` instances.

`R10RGG12_TRACE`, a temporary instrumented build (removed before the patch), read
the arm's gate at every one of the thirteen:

```
R12T bound='NEXT_N-1' owner='…u_block_0.u_adapter.…u_reducer.next_data'
     cs=0x5c3d7650758 csName='rggen_or_reducer'   →  symCallParam=0x5c3d7651790
R12T bound='NEXT_N-1' owner='…g_register_6.…u_reducer.next_data'
     cs=0x5c3d7a6a320 csName='rggen_bit_field_if' →  symCallParam=(nil)
R12T bound='NEXT_N-1' owner='…g_register_8.…u_reducer.next_data'
     cs=0x5c3d7c773c0 csName='rggen_bit_field_if' →  symCallParam=(nil)
…  (12 of 13, `rggen_bit_field_if` / `rggen_register_if`)
```

**`currentScope` was pointing at an INTERFACE BODY.**  `NEXT_N` does not exist
there, `Expression::bind` came back BAD, `symCallParam` stayed null, and the
bound fell through to the arithmetic fold.  The one instance that was right was
right by accident — the stale pointer happened to hold `rggen_or_reducer` at that
moment.  This is RESUME §9's documented trap (“`currentScope` is STALE
throughout `emitInstance` … any name bind during elaborated emission reads
garbage”, earl57 R3) reaching a second arm.

The minimal reproduction is `cells/pc1` (three instances of one module, each
behind a `mid` that also instantiates an INTERFACE):

| cell | sibling of the reducer inside `mid` | base | patched |
|---|---|---|---|
| `pc1` | `ifc u_if();` — an **interface** instance | u_m1 right, **u_m2/u_m3 folded** | all three right |
| `pc2` | nothing | all three right | unchanged |
| `pc3` | `ifc` declared as a **module** | all three right | unchanged |

so the arm's failure is not "deep nesting" and not "generate scope": it is an
interface instance leaving `currentScope` on the interface's body.

## 3. THE LAW

> **§ elabVarRangeCallScopeDecl12.**  The scope in which a declaration's RANGE
> BOUND must be bound is the scope that DECLARES the signal
> (`declSymbol.getParentScope()`), never the emitter's ambient `currentScope`,
> which is stale throughout elaborated emission and holds whatever body the DEF
> phase last set.  `currentScope` is tried FIRST, unchanged, so every bound this
> arm already claimed keeps its answer bit for bit; the declaring scope is a
> pure FALLBACK for the binds that found nothing.
>
> **§ elabParamCallCmpPoison12** (the companion the grid forced).  The arm's
> predicate `elabParamCallSymbolic` was too coarse for this question:
> `subroutinePoisonsEvalFunc` (calibrated for r10rgg8's cont-assign fold) poisons
> on a func-scope select reached through ANY non-`+` operator, so rggen's own
> `get_sub_n_list` (`current_n -= list[list_index]`) read as symbolic — yet
> golden FOLDS a bound that reads a parameter initialised by it.  Measured on
> golden over eight ablation bodies (`ABLATION_abl1.md`) and twelve grid
> initializers, the bound stays SYMBOLIC exactly when the function reaches a
> select of a function-scope value through a **COMPARISON, a LOGICAL/BITWISE
> operator, or a TERNARY CONDITION**.  The new test is ANDed with the old one, so
> the arm can only fire in a SUBSET of the places it fired before.

## 4. THE GRIDS

`gen_grid12.py` builds both; `run_grid12.sh` builds BOTH databases per cell and
censuses them with `rcensus12`; `score12.py` classifies every census row.

### Grid A — 48 cells: 12 initializers × 2 homes (module body / generate-if) × 2 declarations (variable / net)

Golden's answer per initializer, read off `GRID_A_golden_shapes.txt`
(`work@top.u_a`, left bound of `logic [P-1:0] v`):

| `localparam P =` | golden's bound |
|---|---|
| `5`, `BASE+2`, `$clog2(N)` | **FOLDS** (`INT:4`, `INT:2`, `INT:1`) |
| `f_plain(N)` — `return 4` | **FOLDS** |
| `f_for(N)` — a for loop | **FOLDS** |
| `f_ifelse(N)` — if/else inside a for | **FOLDS** |
| `f_nest(N)` — a call inside a call | **FOLDS** |
| `f_p2d(SUBL)` — a **packed-2D formal**, plain return | **FOLDS** |
| `f_sel(N)` — returns a select of a function-local array | **FOLDS** |
| `f_while(N)` — the `get_sub_n_list` shape (`while`, `-=`, selects of a local) | **FOLDS** |
| `gp::pf(N)` — the function lives in a PACKAGE | **FOLDS** |
| `f_terneq(SUBL)` — `acc += ((a[i] != 0) ? 1 : 0)`, i.e. **`get_next_n`** | **KEEPS the call**, argument folded to a `BIN` constant |

So the packed-2D argument is NOT the axis, the for loop is NOT the axis, the
`+=` is NOT the axis, and the function's HOME is NOT the axis.  **The ternary /
comparison over a select of a function-scope value is.**

### Grid B — 60 cells: the same 12 initializers × 5 read positions (variable, net, unpacked dim, parameter typespec, instance port)

### Scores of the patch (all census rows, both grids)

| grid | OK | **FIXED** | **BROKEN** | STILL | MOVED-STILL-WRONG |
|---|---|---|---|---|---|
| A (788 rows) | 723 | **7** | **0** | 57 | 1 |
| B (1278 rows) | 1190 | **4** | **0** | 84 | 0 |

**BROKEN is zero on both grids and on every censused row family, not only on
the bound rows.**  The four grid-B and four of the grid-A fixes are `f_while`
cells — § elabParamCallCmpPoison12 removing a fold the old predicate refused;
the rest are the scope law.

The single **MOVED-STILL-WRONG** row is named and not hidden:
`genif__f_terneq__var`, instance `u_b` (`N=6`).  Golden there is
`op11[ f_terneq( f_while(ref(N)) ), UINT:1 ]` — a NESTED unreduced call with a
BARE `ref(N)` argument, a shape neither the base (`const INT:1`) nor the patch
(`op11[f_terneq(<BIN const>)]`) produces.  It was wrong before and is wrong
after, differently.  It is filed as R2 in § 9.

## 5. THE FIX

Three edits, `src/TypeEmit.cpp` + `src/ParamEmit.cpp` + `include/UhdmExporter.h`
and no other file:

1. **the scope fallback** (`TypeEmit.cpp` ~4063): try `currentScope` exactly as
   before, then `declSymbol.getParentScope()`; the scope that FOUND the parameter
   is the scope the re-bind below uses (`symCallScope`), so the operand tree is
   built in the same scope the decision was made in.
2. **a cheap name-lookup pre-check on the FALLBACK bind only**
   (`boundNamesSymCallParam12`).  An unconditional `Expression::bind` in a second
   scope is an AST-FORCING walk, and RESUME §9 records that forcing binds changes
   later emission.  It did: with the fallback bind run on every declaration
   bound, `SimpleUVM/testflags`' queue typedef `TYPE types_t[$]` moved its right
   bound from `UINT:0` to `UINT:1475` (golden is `STRING:$` — both wrong, but the
   move was ours and unrelated to the law).  A name LOOKUP forces nothing.  The
   pre-check resolves `pkg::P` through the package's own scope, because a
   qualified leaf is not visible to `Lookup::unqualified`
   (`r10vrgg6repro/cells/v_pkg_chain`'s `p::P3` is the witness that caught it).
3. **the narrowed poison test** (`ParamEmit.cpp`, `elabParamCallCmpPoison12`),
   ANDed into `elabParamCallSymbolic`, which is used by this arm and by nothing
   else in the tree (`grep elabParamCallSymbolic` — one call site).

## 6. GATES

| gate | result |
|---|---|
| build both, md5 separately | base `0fdae25ddd95b0f406241f69197d3c4a`, patched `d65a69a246384ead7e96741e68a67c96` |
| goldens, base | 23 PASS / 0 FAIL |
| goldens, patched | **23 PASS / 0 FAIL** |
| goldens, `SLANG_UHDM=/bin/false` (negative control) | **0 PASS / 23 FAIL** |
| uhdm2rtlil, base, both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL per mode; the testflags slice **byte-identical to the committed `results/gate_uhdm2rtlil.csv`, 0 differing ROWS** |
| uhdm2rtlil, patched, both modes | **0 differing ROWS** vs the committed baseline AND vs my own base, status AND dump column |
| uhdm2rtlil byteverify, SELFCHECK=1 | selfcheck 0 movers; **base vs patched 0 MOVERS over 1358**, 0 only-in-A, 0 only-in-B |
| surelog, base, both modes | **byte-identical to the committed `results/golden_surelog.csv`, 0 differing ROWS over 1588** (470/11/5/283/25 default; 466/9/5/3/1/284/23/1/2 testflags) |
| surelog, patched, both modes | **0 differing ROWS** vs the committed baseline AND vs my own base |
| surelog byteverify, SELFCHECK=1 | selfcheck 0 movers over 956; **base vs patched 1 MOVER — `default/Rggen`** and nothing else |
| canaries.sh (surelog / u2r) | ok=52 changed=0 / ok=16 changed=0 |
| ctcan2.sh (surelog, `EXPECT_UNKNOWN=1`) | ok=58 changed=0, unknown-patterns=1 = the documented u2r-only `2DFunctionArg` |
| canaudit.sh | audited=29 **UNCOVERED=0 FENCE-BREACH=0**, both self-tests live |
| byte pins | `SVSwitch` / `YosysVerx` / `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` — all covered by the 0-mover byteverify and the canary battery |

Named-row heads, base → patched (each 1 head; `Scoreboard/testflags` and
`Rggen/testflags` are SKIP-NOFILE and COUNTED — non-CMP rows with no slang
database):

| row | mode | base | patched |
|---|---|---|---|
| SeqDriver | default / testflags | 28 / 28 | 28 / 28 |
| SimpleUVM | default / testflags | 28 / 28 | 28 / 28 |
| Scoreboard | default | 28 | 28 |
| MiniAmiq | default / testflags | 28 / 28 | 28 / 28 |
| BuildUVMPkg | default / testflags | 29 / 29 | 29 / 29 |
| Earlgrey_0_1 | default / testflags | 19 / 37 | 19 / 37 |
| **Rggen** | **default** | **104** | **64 (NEW FAMILY, § 9 R0)** |

## 7. THE PREDICTION, filed BEFORE the patched sweeps were read

`predictdb12.sh` runs the range-bound census on both sides of every PRISTINE
BASE workdir and prints every ELAB bound that disagrees in either direction this
pass can move (ours a folded constant where golden keeps a `func_call`, or the
reverse).  That predicate is an OVER-INCLUSIVE superset of the law.

```
uhdm2rtlil : -- dirs-scanned=1358 SKIP-NOFILE=104 FENCED-SKIP=0 PREDICTED-ROWS=0
surelog    : -- dirs-scanned=948  SKIP-NOFILE=617 FENCED-SKIP=8 PREDICTED-ROWS=12
             all 12 in default/Rggen, all `…u_reducer|logic_var:next_data|TS|0|L`
```

**POSITIVE CONTROL** (`PREDICT_db_POSITIVE_CONTROL.txt`): the same driver over a
one-test workdir finds those 12 rows — a predictor that reaches nothing must
never read as a clean prediction.

**THE PREDICTED MOVER SET IS EXACTLY `default/Rggen`, 12 rows — AND THAT IS
EXACTLY WHAT THE SWEEPS PRODUCED**: byteverify's surelog leg reports 1 mover over
956 databases and u2r's 0-row prediction matched its 0 movers over 1358.

`COIN_scoreboard.txt` is kept because an EARLIER revision's sweep pair also
listed `default/Scoreboard`, and the file is the proof that that row is the
documented ~50/50 COIN and never this patch: four runs of the BASE binary alone
produce three distinct hashes, **including the hash that sweep's PATCHED run
wrote**, and four runs of the PATCHED binary produce the hash the BASE run wrote.
The landing sweep pair did not list it at all.

## 8. BOUNDARY

`boundary12.sh` compiles EVERY source arm — subdirectories included — of the 41
precedent repro directories this law can reach (`r10rgg1…11`, `r10vrgg2…11`,
`r10rggen6…9`, `r10earl45…61`) with BOTH binaries and compares byte-wise:

```
-- files=1253 identical=1152 MOVERS=3 uncompilable=98 asymmetries=0
```

**AN ARM THAT MOVES IS NOT ENOUGH — IT HAS TO MOVE TOWARD GOLDEN.**
`scorearms12.sh` rebuilds the golden for each mover and classifies every
range-bound census row (`BOUNDARY_MOVERS_SCORED.txt`):

```
ARM r10vrgg2repro/z3_range_consumer/dut.sv        OK=29 FIXED=1 BROKEN=0 STILL=0
ARM r10vrgg6repro/cells/v_genscope_chain/dut.sv   OK=40 FIXED=2 BROKEN=0 STILL=0
ARM r10vrgg6repro/cells/v_ifgen_chain/dut.sv      OK=29 FIXED=1 BROKEN=0 STILL=0
-- arms=3 NOGOLD=0 OK=98 FIXED=4 BROKEN=0 STILL=0
```

All three are r10vrgg2/6's own symbolic-call arms — exactly the shape this law
names.  The 98 uncompilable files are the same multi-file arms r10rgg9…11
recorded, each printed and COUNTED.

**POSITIVE CONTROL** — the same driver over this pass's own cells:

```
MOVER r10rgg12repro/cells/pc1/top.sv
-- files=4 identical=2 MOVERS=1 uncompilable=1 asymmetries=0
ARM cells/pc1/top.sv OK=30 FIXED=2 BROKEN=0 STILL=0
ARM cells/pc2/top.sv OK=24 FIXED=0 BROKEN=0 STILL=0
ARM cells/pc3/top.sv OK=32 FIXED=0 BROKEN=0 STILL=0
```

so the comparator provably sees THIS pass's difference, and the two cells that
must NOT move do not.  (`cells/abl1` is UNCOMPILABLE by BOTH binaries and
counted: it is a golden-only ablation, see § 4 and `ABLATION_abl1.md`.)

An earlier revision of this patch was REJECTED BY THIS GATE and by the grid.
Three defects were found and fixed before landing, each recorded above:
the coarse poison predicate (2 BROKEN grid cells), the AST-forcing fallback bind
(`SimpleUVM/testflags` moved), and the pre-check's blindness to `pkg::P`
(`v_pkg_chain` lost a bound the base got structurally right).

## 9. RESIDUES AND THE NEXT HEAD

**R0 — THE NEW HEAD of `default:Rggen` (64 cmp lines, 1 head).  A DIFFERENT
FAMILY: the ARGUMENT constant of a `param_assign`'s `func_call`.**

```
rggen-sv-rtl/rggen_or_reducer.sv:62:62-62:63  (the `N` in `get_sub_n_list(N)`)
  golden : constant INT:2  sz 32 ct 7, vpiParent = the `param_assign` of `N`
             (3:17-3:26), ref_typespec -> N's own int_typespec (3:13-3:16)
  ours   : constant UINT:2 sz 32 ct 9, vpiParent = the func_call,
             ref_typespec -> the FORMAL's int_typespec (8:55-8:58)
```

This is r10rgg11's § genLpPortConnValue11 law again, in a THIRD position: a call
ARGUMENT that is a bare parameter name is golden's COPY of that parameter's own
`param_assign` Rhs constant, carrying that parameter's typespec — not a fresh
constant typed by the formal.  The census counts **11 such rows** in Rggen
(`CENSUS_rggen_residues.txt`).

**R-A — the BIGGEST Rggen range family, 810 rows, untouched.**  Golden's ELAB
view keeps `op11[ref(WIDTH), UINT:1]` — a bound with a BARE, unsubstituted
parameter reference — where we fold to `const INT:<n>`; every one of them is an
interface (`rggen_bit_field_if` / `rggen_register_if`) variable inside a
gen scope.  That is 810 of the 833 remaining differing census rows and is the
ranked next target after R0.

**R1 — 7 `param_assign` rows** whose value renders signed on our side
(`UINT:-60` vs golden `UINT:68` at `sz=7`), 4 ELAB `param_assign` rows we emit
and golden does not, and 1 `BIN:0` whose size is 64 where golden's is 2.

**R2 — the nested-call bound.**  Grid A `genif__f_terneq__var`, `u_b`: golden
keeps `f_terneq(f_while(ref(N)))` with a BARE ref, we (and the base) do not.
Surelog's substitution stops one level deep for some instances and not others;
unmodelled.

**R3 — `d_formal_add`, the one ablation shape the narrowed predicate calls
foldable and golden keeps** (`acc += 32'(a[i])`, a select of the formal in a
plain add).  Left deliberately on the FOLD side: that is the side the arm took
before this pass, so it cannot regress a row.

## 10. THE INSTRUMENTS

| file | what it measures |
|---|---|
| `rcensus12.cpp` / `build12.sh` | THE CENSUS: every RANGE BOUND reachable from a declaration in a database, DEF (`allModules`+`allInterfaces`) and ELAB (`topModules`, gen scopes walked), keyed `(view, owning-instance full path, owner kind:name, container, dim index, L/R)`, printing the bound expression's shape recursively with exactly the fields `constant::Compare` reads; plus every `param_assign` Rhs in the same scopes. Rggen: 29,890 golden rows / 29,894 ours. |
| `gen_grid12.py` + `run_grid12.sh` + `cell12.sh` | Grid A (48 cells) and Grid B (60 cells), and the single-cell driver. |
| `score12.py` | golden-vs-ours per cell, and the OK/FIXED/BROKEN/STILL three-way. |
| `reours12.sh` | re-reads ONLY our side of an already-built grid (the golden side is immutable). |
| `predictdb12.sh` | the database-level prediction of § 7 (carries the FENCE). |
| `boundary12.sh` + `scorearms12.sh` | the precedent-arm boundary of § 8, its positive control, and the toward-golden scoring of every mover. |
| `gates12.sh`, `ct12rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the mandatory gates. |
| `cells/` | `pc1` (the positive control: the bug in miniature), `pc2`/`pc3` (the two arms that must NOT move), `abl1` (the golden-only ablation of § 4). |

### Two instrument bugs, found and fixed before any number was believed

* `rcensus12.cpp` inherits r10rgg11's `string_view`-to-`printf` trap by
  construction: every name is materialised into a `std::string` first, because
  the raw bytes plus NULs turn the census file BINARY and `grep` then prints
  NOTHING for patterns that DO match.
* `scorearms12.sh` left Surelog's `slpp_all/` byproduct inside the repro
  directories, and `slpp_all/lib/work/<src>.sv` is a COPY of the arm — the next
  boundary run reported **7 movers where there were 3**.  The script now removes
  it and `boundary12.sh` refuses to walk into `slpp_all`.

## 11. WHAT THIS PASS DOES **NOT** CLAIM

* Rggen does **not** pass `uhdm-cmp`.  **NO CORPUS ROW WAS CONVERTED** in either
  corpus, in either mode, and `results/*.csv` was never written.
* 104 → 64 cmp lines is **not** progress: it is the next head object's decompile
  size.  The claims that rest on evidence are the 12-row census move with zero
  AWAY-GOLDEN, the 0-line block diff against golden, and the two 0-differing-row
  corpus gates.
* The predicate of § 3 is a MODEL of Surelog's `ExprEval` refusals measured on
  20 bodies (8 ablation + 12 grid), not a transcription of it.  `d_formal_add`
  (R3) is a known miss, on the safe side.

## 12. HOW TO REPRODUCE

```sh
git worktree add /tmp/wt_r10rgg12 c40ed40 && git apply /tmp/r10rgg12.patch   # in it
cmake -S /tmp/wt_r10rgg12 -B /tmp/r10rgg12_build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build /tmp/r10rgg12_build -j 2
bash    tools/probe/r10rgg12repro/build12.sh                      # the census tool
python3 tools/probe/r10rgg12repro/gen_grid12.py /tmp/r10rgg12_gridA A
bash    tools/probe/r10rgg12repro/run_grid12.sh /tmp/r10rgg12_gridA \
        /tmp/r10rgg12_base_bin /tmp/r10rgg12_gridAout
bash    tools/probe/r10rgg12repro/reours12.sh  /tmp/r10rgg12_gridA \
        /tmp/r10rgg12_pat_bin /tmp/r10rgg12_gridAout /tmp/r10rgg12_gridAoutPAT
python3 tools/probe/r10rgg12repro/score12.py /tmp/r10rgg12_gridAout/golden.cen \
        /tmp/r10rgg12_gridAout/ours.cen /tmp/r10rgg12_gridAoutPAT/ours.cen --rows
bash    tools/probe/r10rgg12repro/gates12.sh {gold|goldneg|u2r|sl} {base|pat}
bash    tools/probe/r10rgg12repro/rowheads.sh <workdir> <outdir> Rggen
```
