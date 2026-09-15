# r11u39 — § hpCompMultiSelElemShape: a path component's MULTI-STEP select run

**The dissolved K11's first singleton** (`tools/probe/r11u29repro/TRIAGE.md` §K11,
`tools/probe/r11v29repro/evidence/splits.txt` SPLIT 6).  MEASUREMENT ONLY files;
`~/.local/bin/uhdm-cmp` (UHDM v1.87) is the sole acceptance judge.  LHS is
ALWAYS golden (Surelog), RHS is ALWAYS ours.

## 0. The head, re-measured at the base

`dyn_field_select` (uhdm2rtlil, BOTH modes), 160 cmp lines / **1 head** each,
`cmp rc=255`.  `dut.sv:27`, `assign taken_o = tbl[row_i][col_i].sat[sel_i][1];`
with `p::entry_t [1:0][1:0] tbl` and `logic [3:0][1:0] sat`:

```
LHS (golden)                                   RHS (ours)
hier_path: (tbl[row_i][col_i].sat[sel_i][1])   hier_path: (tbl[row_i][col_i].sat[sel_i][1])
|vpiActual: bit_select (tbl[row_i])            |vpiActual: ref_obj (tbl[row_i][col_i])
            |vpiName:tbl  |vpiIndex ref_obj row_i           |vpiName:tbl[row_i][col_i]
|vpiActual: bit_select (tbl[row_i][col_i])     |vpiActual: bit_select (…sat[sel_i])
            NO vpiName    |vpiIndex ref_obj col_i           |vpiName:sat[sel_i]
|vpiActual: var_select (…sat)                              |vpiIndex constant 1
            |vpiName:sat  |vpiIndex ref_obj sel_i
                          |vpiIndex constant 1
```

Both sides carry the SAME `hier_path` `VpiName`; the disagreement is the
`Path_elems` VECTOR — three elements against two, so `hier_path::Compare` sets
both containers and the head names the path.

## 1. What our composite spelling keys on — MEASURED, not guessed

It is **not** the dynamic index and **not** the root's dimension count.  Arm a1
(`a1/dut.sv`, ROOT select count 0..3 x MEMBER step count 0..3 x index kind
constant / module-localparam / package-localparam / genvar / runtime net) reads,
per side, 24 `hier_path`s.  Ours is golden's in exactly two families and wrong in
one:

| written reference | golden | pristine ours |
|---|---|---|
| `m0.sat[s_i][1]`        (root NOT selected) | `ref_obj[m0] + var_select[sat]/2` | SAME |
| `m2[r][c].sat[s_i]`     (member ONE step)   | `bit_select[m2] + bit_select[-] + bit_select[sat]/1` | SAME |
| `m2[r][c].sat[s_i][1]`  (root selected, member TWO steps) | `bit_select[m2] + bit_select[-] + var_select[sat]/2` | `ref_obj[m2[r][c]] + bit_select[sat[s_i]]/1` |
| `m2[r][c].sat[2][0]`    (both indices CONSTANT) | same var_select | same composite |
| `m3[r][c][t].sat[s_i][1]` | 3 bit_selects + var_select/2 | same composite |
| `g2[r][c].deep[t][s][1]`  (member THREE steps) | 2 bit_selects + `var_select[deep]/3` | `ref_obj + bit_select[deep[t][s]]/1` |

**THE KEY IS THE MEMBER TAIL HAVING TWO OR MORE SELECT STEPS WHILE THE ROOT
CARRIES AT LEAST ONE.**  `sat[2][0]` — every index a literal — breaks
identically to `sat[sel_i][1]`, so "dyn" names the test, not the face.

The producer: `ExprEmit.cpp`'s `ElementSelect` case routes to
`emitMixedHierPath` only when `es.value()` is a `MemberAccess`.  A second
trailing index makes `es.value()` another `ElementSelect`, the gate fails, the
nested-select arm below refuses too (its member chain must bottom out at a bare
`NamedValue`), and the reference falls through to the DOTTED-PATH arm, which
splits `rawTextExpr` on `.` and mints one `ref_obj` per leading text component —
brackets and all — plus one `bit_select` for the last written index.

## 2. The law

**§ hpCompMultiSelElemShape.**  A path component whose written select run has
MORE THAN ONE STEP is EITHER one `var_select` named after the component with one
`Exprs` entry per step, OR one `bit_select` PER STEP with only the FIRST
carrying the component's `VpiName`.  **TWO AXES DECIDE WHICH — and they are the
same two (`inLhs`, `baseSelMode`) that already decide the hier_path's own SPAN
and § hpTrailSelIdxDecompiled89's bracket convention, i.e. WHICH SURELOG BUILDER
RAN.**  Measured on golden, arm a3, every cell of every row:

| component | root selected | lvalue | golden element(s) |
|---|---|---|---|
| TRAILING | yes | no  | `var_select[name]/n` |
| TRAILING | yes | YES | `ref_obj[name]` + `var_select[-]/n` |
| TRAILING | no  | no  | `var_select[name]/n` |
| TRAILING | no  | YES | `var_select[name]/n` |
| MID | yes | no  | `bit_select` chain |
| MID | yes | YES | `bit_select` chain |
| MID | no  | no  | `bit_select` chain |
| MID | no  | YES | `var_select[name]/n` |

So the SPLIT fires on `inLhs && baseSelMode` and the bit_select CHAIN fires
everywhere in the MID row except `inLhs && !baseSelMode`.  The witnesses:
`m0.lv[s_i][1].b` (rvalue) is a bit_select chain while `m0.lv[s_i][1].a`
(lvalue) is `var_select[lv]/2` — the SAME reference two lines apart; and
`wv[r_i][c_i].lv[s_i][1].b` is a bit_select chain because its root IS selected.

Spans and index parents: the first mid bit_select spans the COMPONENT NAME
TOKEN and each later one spans the PRECEDING SELECTOR, its ref_obj index
parents at the HIER_PATH and its constant index stays unparented; a var_select
spans the component name token to the END OF ITS LAST BRACKET with the doubled
lazily-frozen fullname and BOTH index kinds parented at the var_select; the
SPLIT's anonymous var_select carries no file, line or column at all and takes
`<prefix>.<whole path name>` as its fullname.

No arm reads the INDEX KIND.

**SURELOG.**  `CompileHelper::compileSelectExpression`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:1259`) mints the
`var_select` at `:1272` the moment the select node has BOTH a child and a
sibling — "More than one" is the source's own comment — names it after the
component (`:1277`) and pushes one compiled index per step (`:1315-1320`); a
SINGLE step falls through to `:1332` and mints the flat `bit_select`.  The
hier_path element loop calls it only for a component's own select node
(`:5560-5570`); the MID bracket run is walked bracket-by-bracket by the loop's
own arm at `:5602`, which mints one `bit_select` each and clears the pending
name after the first — which is why golden's second and later mid bit_selects
are UNNAMED.

## 3. The golden grid (three arms, every arm's rc recorded)

| arm | axes | surelog rc | slang rc | golden `hier_path`s |
|---|---|---|---|---|
| `a1/dut.sv` | root 0..3 selects x member 0..3 steps x constant / module-localparam / package-localparam / genvar / net index | 0 | 0 | 24 (def) / 48 (elab) |
| `a2/dut.sv` | HOLDERS: cont-assign rvalue+lvalue, `always_comb` rvalue+lvalue, function body, condition, call argument, gen-block (def AND elab), interface instance, module high-conn; plus the MID cell `tb[r][c].lv[s][1].a` | 0 | 0 | 13 (def) / 24 (elab) |
| `a3/dut.sv` | LVALUE (cont-assign and process), genvar index on root AND member, module localparam, PACKAGE localparam, CLASS BODY (rvalue in a function, lvalue in a task), MID lvalue, and the ROOT-NOT-SELECTED MID/TRAILING cells in both positions | 0 | 0 | 20 |

An earlier a3 revision put a NON-CONSTANT select on a continuous-assign lvalue;
slang rejected the file (`rc=3`, "reference to non-constant variable 's_i' is
not allowed in a constant expression").  That arm taught error recovery, not
golden, and was rewritten — the dynamic lvalue cell now lives in the process.

Census (`ct39cen --cen`), golden vs ours, SHAPE rows:

| arm / view | pristine | patched | what is left |
|---|---|---|---|
| a1 def  | 13 | **0** | — |
| a1 elab | 26 | **0** | — |
| a2 def  | 12 | 1 | R0, the interface-instance holder |
| a2 elab | 22 | 2 | R0 (x2 copies) |
| a3 def  | 18 (+1 golden-only, +1 ours-only) | 1 | a DEF/ELAB COPY COUNT |
| a3 elab | 34 (+2 golden-only, +2 ours-only) | 5 | COPY COUNTS only (`g=3 o=5`, `g=2 o=3`; both sides carry the SAME shape string) |

`ct39cen --cen golden golden` reads `shape=0` — the census calibrates.

The a2 residue is the INTERFACE-INSTANCE holder `u_if.tb[r][c].sat[s][1]`
(residue **R1**): its base is an `ArbitrarySymbol`, not a `NamedValue`, so the
mixed builder declines by construction and the dotted-interface arm — whose own
`High_conn` folds are a different family's — keeps it.  The a3 residue is a
DEF/ELAB COPY COUNT, not a shape: both of our copies of `wb[1][1].lv[0][1].a`
carry golden's five-element shape, and the arm's non-elab surelog run has only
the def one.

Cells that MOVED, arm a3: 16 of the 18 that disagreed with golden pristine; the
two that did NOT move (`m0.sat[s_i][0]`, `m0.sat[s_i][1]`) are the
root-NOT-selected trailing pair that the nested-select arm owns and this law
does not route.  TO-GOLDEN 16 / AWAY-GOLDEN 0.

Byte convergence: after the patch every cell the law touches is BYTE-IDENTICAL
to golden in `uhdm-dump` (a1 `m1[r]/m2[r][c]/m2[0][1]/m3[r][c][t].sat[*][*]`,
`g2[r][c].deep[*]`, `g2[r][c].sub.sat[s][1]`; a3 `wb[0][1].sat[2][0]`,
`wb[1][0].sat[MP][1]`, `wv[*]` lvalues, `tb[gi][c_i].sat[gi][1]`,
`tb[r][c].sat[p3::PK][1]` — which the mixed builder's own
§ hierSelPkgParamFold renderer folds to `sat[1][1]`, golden's spelling — and the
class-body `q[0][1].sat[k][1]` in both positions).

## 4. Instruments

* `ct39cen.cpp` — the hier_path element-shape census / SHAPE LISTER / mover
  predictor.  `--cen` multiset-joins (view-blind) on the path's `VpiName` with
  the judge-visible element face as payload; `--list` prints every path's shape
  (the SHAPE LISTER that sits beside every census number here); `--pred` reads
  OURS ALONE and classifies each path COMPOSITE / DROPPED / ERASED / OK.
* `predsweep.sh` — runs `--pred` over every database of a `verify_golden`
  workdir and names the predicted movers; it counts databases and missing
  files, so a driver that reaches nothing cannot read as "no movers".

## 5. Residues

* **R0** — the INTERFACE / hierarchical-base twin: `u_if.tb[r][c].sat[s][1]`
  and `<iface>.<member>[i][j]` generally.  Golden gives it the same
  bit_select-chain + var_select shape; the mixed builder requires a
  `NamedValue` base, so it stays on the dotted-interface arm.  Corpus reach in
  either corpus: **zero** (the arm alone carries it).
* **R1** — the RANGE-tail sibling `tq[gi].is_page[2-gx][0:0]`
  (`anon_struct_packed_dim`): an element-select run followed by a PART select.
  That reference reaches `emitExpr` as a `RangeSelect`, not an `ElementSelect`,
  so this pass's routing does not see it; the RangeSelect arm's own
  member-chain gate still demands a bare `NamedValue` base.  Predicted NOT to
  move, and measured not to.
* **R2** — pre-existing byte residues on cells this law does NOT touch, both
  present pristine and unchanged: the root-NOT-selected `m0.sat[s][1]`
  var_select's span (golden anchors at the member token, we at the base) and
  its index fullname; the single-step `…sat[s_i]` index fullname; the mid
  `ref_obj[sub]`'s explicit fullname; and the HIGH-CONN holder's base-select
  index parent.

## 6. The corpus: prediction, then measurement

**PREDICTED BY NAME, from the PRISTINE databases, before the patched sweep.**
`predsweep.sh` ran `ct39cen --pred` over every database of both pristine
workdirs (`databases=1608 missing=0` uhdm2rtlil, `databases=960 missing=0`
surelog, probe rc non-zero 0 in both):

* uhdm2rtlil — **4 databases flagged**: `dyn_field_select` (both modes,
  `composite=2` each) and `anon_struct_packed_dim` (both modes, `composite=4`
  each).  `anon_struct_packed_dim`'s four cells are all
  `tq[gi].is_page[2-gx][0:0]`, an element-select run followed by a PART select:
  the predictor's COMPOSITE class is a deliberate SUPERSET (any element whose
  own name carries a `[`), and that reference reaches `emitExpr` as a
  `RangeSelect`, so it was predicted **NOT** to move (residue R1).
* surelog — **0 databases flagged**, `composite=0 dropped=0 erased=0`.

**POSITIVE CONTROL for the surelog ZERO** (a census zero needs one): the same
driver and probe, pointed at a directory holding the arms' PRISTINE databases,
reads `armA1-pris/default composite=13 … MOVER-PREDICTED` and
`armA2-pris/testflags composite=10 dropped=2 … MOVER-PREDICTED`.  Both of the
predictor's classes fire; the zero is a reading, not a silence.  The patched
arm databases read `composite=0 dropped=0 … NO-MOVE-PREDICTED`.

**MEASURED.**  `SELFCHECK=1 byteverify.sh` against this pass's OWN pristine
workdirs:

* uhdm2rtlil — `PATH_SETS_IDENTICAL (1608)`, **MOVERS 2 / 1608**, both
  `dyn_field_select` (default and testflags); SELFCHECK 1607/1608.  Exactly
  the predicted set; `anon_struct_packed_dim` is byte-identical in both modes.
* surelog — `PATH_SETS_IDENTICAL (960)`, **MOVERS 5 / 960**: `MiniAmiq`
  (both modes), `Scoreboard`, `SeqDriver`, `SimpleUVM` (default).  SELFCHECK
  959/960.  Every one is the KNOWN nondeterminism class and is attributed
  ORDER-BLIND (uhdm-dump, workdir path normalised, both sides sorted):
  `Scoreboard/default` **0 lines**; the other four **4 lines each**, and all
  four lines are one `|UINT:<n>` + `|vpiDecompile:<n>` pair (MiniAmiq/default
  937 vs 585, MiniAmiq/testflags 1302 vs 541, SeqDriver 1479 vs 0, SimpleUVM
  923 vs 981) with IDENTICAL dump sizes on both sides.  No `hier_path`,
  `bit_select` or `var_select` line is in any of them.

**THE CONVERSION.**  `dyn_field_select` CONVERTS in BOTH MODES.  The committed
baseline rows (`results/gate_uhdm2rtlil.csv`, `results/golden_uhdm2rtlil.csv`,
READ ONLY — this pass edited no CSV):

```
dyn_field_select,testflags,CMP_NOTEQUAL,decompile:,,   ->  dyn_field_select,testflags,CMP_EQUAL,,,differ
dyn_field_select,default,CMP_NOTEQUAL,decompile:,,     ->  dyn_field_select,default,CMP_EQUAL,,,differ
```

uhdm2rtlil goes 776 equal / 28 not-equal -> **777 / 27 in both modes**; the
surelog scoreboard is unchanged (474/9 default, 469/8 testflags).  The
converted database's four `hier_path`s all read `shape=0 agree=4` against
golden, its `--pred` class is `NO-MOVE-PREDICTED`, and the two head cells are
BYTE-IDENTICAL to golden; the whole database is 6 order-blind dump lines from
golden, all of them the pre-existing single-step index-fullname residue on
`tbl[row_i][col_i].sat[sel_i]`.  The 86 moved dump lines all sit inside the two
target path subtrees: TO-GOLDEN 2 / AWAY-GOLDEN 0 / STILL-WRONG 0.

## 7. Gates

| gate | reading |
|---|---|
| pristine build | md5 `fad856692f9431ebe8e264a4ed99f3bf` — byte-identical to the main tree at `6068228a` |
| patched build | md5 `ffc677a78847fe65baac4b65f0a930c0` |
| goldens | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` `PASS=0 FAIL=23` |
| cmds.txt audit | 3273 `slang:` lines under the patched workdirs, ALL `/tmp/…/fix4.bin`; 3273 under the pristine ones, ALL `/tmp/…/pris.bin`; none names the main tree |
| u2r rows (both modes, vs committed baselines AND vs this pass's own pristine) | ONE differing row, the claimed conversion, quoted above |
| surelog rows | no status change; the only whole-row differences are two `SURELOG_FAIL` detail strings that embed the WORKDIR PATH (`LowMemLib`, `LowMemPkg`) and one DUMP-COLUMN cell, below |
| byteverify | u2r 2/1608 predicted; surelog 5/960, all the known coin, attributed order-blind |
| canaries | u2r `ok=8 changed=0`, `ctcan2 PASS`; surelog `ctcan2 ok=58 changed=0 PASS` |
| canaudit | `audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS` |
| HARD byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` — both modes, patched == pristine |
| STATUS pins | InterfaceModPort `59a365f3ce2c`, BlackParrotComplex (`e3e354129d5a` / `73a10e8217e5`), YosysOldOr `d68e0796d62c` — patched == pristine |
| Earlgrey_0_1 | CMP_EQUAL both modes; databases `8bdf25272e08` (default) and `59d0ee6d10c3` (testflags), patched == pristine == the pins |
| UVM family heads | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg all `0 cmp lines, 0 heads, rc=0`; Rggen/default `64 lines, 1 head` — the cmp output BYTE-IDENTICAL to pristine |

**The one dump-column cell, measured rather than argued.**  The loaded sweep
recorded `Earlgrey_0_1,testflags,CMP_EQUAL,,,` where the baseline has
`…,differ`, and `canaries.sh` counted it (`ok=51 changed=1`).  `verify_golden.py`
defaults `--timeout` to 180 s and that row's `uhdm-dump` takes **173 s of user
time unloaded**, so under two concurrent passes it hits `TimeoutExpired` and the
dump verdict is left EMPTY.  Two measurements close it: the database is
byte-identical to the pristine one and to the pin (`59d0ee6d10c3`), and a re-run
of that single row with `--timeout 900` on the PATCHED binary records
`Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` — the baseline row, byte for byte —
with the same database md5.
