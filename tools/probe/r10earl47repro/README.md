# r10earl47 — § genLpUseFoldParentScope47

**THE HEADLINE: the 46-line Earlgrey head is CLEARED and the row ADVANCES to a
644-line head in a different file.** The design-wide census, run on the
pristine pair before a line of code was written, predicted **72 cells and only
those 72**; the patched run moved **exactly 72**, the per-shape multiset moved
**936 added / 288 removed = +648 dump lines**, and 648 is exactly what 72 cells
× (14 lines of substituted constant − 5 lines of ref_obj) + shared-shape
cancellation implies, to the line. Every named non-mover held.

**And the brief's hypothesis was the wrong shape of law.** The brief called
this "the § genLpConst SHARE law one step further out" — a question about the
gen-CA share mechanism. It is not. Four purpose-built arms measured the
substitution against Surelog cell for cell and the discriminator is not the
mechanism, not the position, and not the value: it is a **DISTANCE**. Golden
substitutes a gen-scope localparam's fold at a use site **exactly one hop up
the scope name and no further** — not in the localparam's own scope, not two
scopes down, not for a genvar at any distance. A patch built on "a gen scope
localparam read anywhere below it folds" would have fired where **golden keeps
a `ref_obj`** — and in `a3`'s `gen_x[1]` alone that is **18 cells**
(`p_own` ×2, `p_mod` ×2, `p_ini` ×2, `z_2up` ×4, `z_3up` ×4, `z_gv` ×4), every
one of them measured against Surelog and every one of them still a `ref_obj`
after this pass.

* BASE COMMIT `f0d93e1`, branch `auto5h`. Worktrees `/tmp/wt_r10earl47`
  (patched, branch `r10earl47wt`) and `/tmp/wt_r10earl47pris` (pristine,
  detached `f0d93e1`). Both trees' `git rev-parse HEAD` printed and checked:
  `f0d93e15aeab7fd559d9c7c00c6196fcc99023e6`.
* Patched binary md5 `f57b50b3987a6554a5ad63690c472d13`,
  pristine binary md5 `2ecf28a8494750468a6edcd435b8f874`.
* Production diff: `include/UhdmExporter.h` (+8, one declaration) and
  `src/ExprEmit.cpp` (one new function, four call sites given an `else if`
  fallback). Nothing else in `src/` or `include/` is touched. `slang` is NOT
  patched. `results/*.csv` were READ ONLY. `GOLDEN_DEFER` was never set.

---

## 1. THE LAW

> **§ genLpUseFoldParentScope47** — A REFERENCE TO A GEN-SCOPE LOCALPARAM IS
> REPLACED, IN A SELECT BOUND, BY A USE-SITE COPY OF THAT LOCALPARAM'S FOLD
> CONSTANT — **EXACTLY WHEN THE LOCALPARAM'S DECLARING GEN SCOPE IS THE
> IMMEDIATE PARENT OF THE USE SITE'S EMISSION SCOPE PATH**. One hop up the
> name, no more and no less.
>
> The copy carries the localparam's folded **digits, size and encoding**, the
> **USE's own span**, the localparam's own `param_assign` as **vpiParent** (a
> BORROWED parent — the constant hangs structurally under the select), and a
> `ref_typespec` **named for the DECLARING gen scope** whose actual is that
> localparam's own typespec.
>
> Distance 0 (the localparam's own scope) and distance ≥ 2 keep a `ref_obj`.
> A **GENVAR never substitutes**, at any distance.

The `§` is greppable and appears in exactly six places in the production tree:
the declaration (`include/UhdmExporter.h`), the definition (`src/ExprEmit.cpp`,
immediately above `collectPkgParamFolds`) and the four call sites, each
labelled `CALL SITE n of 4`.

### 1.1 STATED GATE == CODE GATE

Every clause above is one line of `UhdmExporter::genLpUseFoldBound47`:

| stated clause | code |
|---|---|
| a REFERENCE (not an expression) | `stripImplicitConv(e).kind != NamedValue → nullptr` |
| to a LOCALPARAM | `sym.kind != SymbolKind::Parameter → nullptr` |
| whose declaring gen scope is the IMMEDIATE PARENT of the use's emission scope | `dot = usePrefix.rfind('.')`; `declScope = usePrefix.substr(0, dot)`; lookup `genLpFoldByPath[declScope + "." + sym.name]` — **one** `rfind`, never a loop up the path |
| a GENVAR never substitutes | genvars are not in `genLpFoldByPath` (ModuleEmit inserts only in the REAL-localparam arms); no extra clause needed |
| and it must be THAT declaration | `it->second.ps != &sym.as<ParameterSymbol>() → nullptr` |
| the localparam's folded digits, size, encoding | `VpiDecompile/VpiSize/VpiValue/VpiConstType` copied from `it->second.c` |
| the USE's own span | `setLoc(c, le.sourceRange)` |
| the param_assign as vpiParent | `c->VpiParent(it->second.pa)` |
| a ref_typespec named for the DECLARING gen scope | `rt->VpiFullName(declScope)` |
| whose actual is the localparam's own typespec | `pendingGenLpTs[…].shareRts.push_back(rt)` — the existing drain binds it |
| IN A SELECT BOUND | the function is called from **four** places and nowhere else: the two `indexed_part_select` bound setters and the two `part_select` range setters, in both the var_select-with-indices form and the whole-variable form |

The "SELECT BOUND" restriction is **this pass's, not golden's**: §3 measures
golden substituting in five further positions at the same distance. Those have
**zero** Earlgrey_0_1 cells (§4) and are ranked residues R1–R3, stated rather
than quietly implemented.

### 1.2 What the one-hop test buys that a scope-chain walk does not

The existing hier-path index fold (`gen_test4 foo[PREV].temp`) walks the whole
prefix chain looking for any ancestor that declares the name. That is the
natural thing to write here too, and it is **wrong**: `a3`'s `z_2up` reads its
grandparent's localparam and golden leaves a `ref_obj`, and `a2`'s `n_mpw`
reads a MODULE parameter two scopes down and golden leaves a `ref_obj` there
too, while `a1`'s `r_mpw` reads the SAME module parameter ONE scope down and
golden DOES substitute. A chain walk cannot tell those three apart. One
`rfind` can.

The one-hop test also produces the **declaration-initializer** cell for free,
without a clause for it: a gen-local variable's initializer is emitted with the
VARIABLE's own full name as its prefix, so the variable's own scope's
localparam is one hop up and IS substituted (`b1`'s `r_dini` — golden agrees),
while the same initializer one scope deeper is two hops and is NOT (`a3`'s
`p_ini` — golden agrees). Two rows that look like a contradiction under any
"context" model fall out of the distance model with nothing added.

---

## 2. THE TARGET, AND WHAT IT ACTUALLY WAS

`prim_keccak.sv:59-67`, in the elaborated `gen_rho_x[i].gen_rho_y[j]`:

```systemverilog
      localparam int Offset   = RhoOffset[x][y]%W;
      localparam int ShiftAmt = W- Offset;
      if (Offset == 0) begin : gen_offset0
        assign rho_data[x][y][W-1:0] = theta_data[x][y][W-1:0];
      end else begin : gen_others                       // <- a CHILD gen scope
        assign rho_data[x][y][W-1:0] = {theta_data[x][y][0+:ShiftAmt],   // 65:61
                                        theta_data[x][y][ShiftAmt+:Offset]};
      end                                               // 66:58     66:68
```

`Offset` and `ShiftAmt` are declared in `gen_rho_y`; the reads are inside
`gen_others`, one scope deeper. Golden writes the folded constant at each of
the three use sites; we wrote a `ref_obj`. Everything else about those three
cells — the enclosing `var_select`, its two `ref_obj` indices, the
`indexed_part_select`'s name/defname/fullname/`vpiConstantSelect`/
`vpiIndexedPartSelectType`, and the literal `0` base at 65:58 — was already
byte-identical to golden, which is why the head sat exactly on the leaf.

**What uhdm-cmp actually reads**, checked in the generated UHDM sources rather
than assumed: `BaseClass::Compare` = VpiType, VpiName, VpiDefName;
`expr::Compare` adds VpiDecompile, VpiSize and the **Typespec**;
`constant::Compare` adds VpiConstType. **vpiParent is never compared.** So the
72 movers are cmp-visible through the type change alone — and the substituted
constant MUST carry a `ref_typespec` with a matching actual, or the head would
simply have moved onto the typespec instead of clearing.

---

## 3. THE GRID, CELL FOR CELL

Four purpose-built arms. LHS is ALWAYS golden (Surelog). Reproduce with
`SLANG_UHDM=<bin> ./arm47.sh <arm>.sv <wd>` then
`python3 grid47.py <wd>/g.dump <wd>/o.dump '<scope>'`. Saved as
`/tmp/r10earl47/grid47_<arm>_<bin>_<scope>.txt`.

`grid47.py` separates the **def (allModules)** and **elab (topModules)** views,
which carry the SAME scope names — the first cut of this reader merged them and
reported the elab view's answer for both, which is how a def-view-only
hypothesis would have been "confirmed" (§7 R-4).

### 3.1 a2 — the POSITION axis at distance 1 (nested gen scope)

Instance `gen_x[1].gen_y[0]`, `LPA = 6`, `LPS = 58`. Both other instances agree
cell for cell.

| row | source | golden | pristine ours | patched ours |
|---|---|---|---|---|
| `n_ipsw` | `d[0 +: LPA]` — ips WIDTH | `INT:6 ct7 sz32` par=param_assign | **ref_obj ✗** | ✓ exact |
| `n_ipsb` | `d[LPA +: 4]` — ips BASE | `INT:6 ct7 sz32` par=param_assign | **ref_obj ✗** | ✓ exact |
| `n_ipswl` | `d[0 +: LPL]` — LITERAL-fold lp | `UINT:8 ct9 sz32` par=param_assign | **ref_obj ✗** | ✓ exact |
| `n_psl` | `d[LPA : 0]` — part_select LEFT | `INT:6 ct7 sz32` par=param_assign | **ref_obj ✗** | ✓ exact |
| `n_psr` | `d[31 : LPA]` — part_select RIGHT | `INT:6 ct7 sz32` par=param_assign | **ref_obj ✗** | ✓ exact |
| `n_2d` | `bx[x][y][0 +: LPS]` — **THE KECCAK SHAPE** | `INT:58 ct7 sz32` par=param_assign | **ref_obj ✗** | ✓ exact |
| `n_2db` | `bx[x][y][LPS +: 4]` — keccak BASE | `INT:58 ct7 sz32` par=param_assign | **ref_obj ✗** | ✓ exact |
| `n_bit` | `d[LPA]` — bit_select INDEX | `INT:6` par=**bit_select** | **ref_obj ✗** | ref_obj (R1) |
| `n_rhs` | `assign n_rhs = LPA` — bare Rhs | `INT:6` par=**cont_assign** | **ref_obj ✗** | ref_obj (R2) |
| `n_op` | `LPA + 1` — operation OPERAND | `INT:6` par=**operation** | **ref_obj ✗** | ref_obj (R3) |
| `n_mpw` | `d[0 +: MP]` — MODULE param, distance 2 | **ref_obj** | ref_obj ✓ | ref_obj ✓ |
| `n_mpb` | `d[MP +: 4]` — MODULE param, distance 2 | **ref_obj** | ref_obj ✓ | ref_obj ✓ |
| `n_gvb` | `d[x +: 4]` — GENVAR, distance 1 | **ref_obj** | ref_obj ✓ | ref_obj ✓ |
| indices | `bx[x][y]` — genvars as indices | ref_obj | ref_obj ✓ | ref_obj ✓ |

`a2` verdict: pristine **11 of 36 rows differ** at `gen_y[0]` and 11 at
`gen_y[1]`; patched **4 and 4**, and all four are R1–R3 plus one whole-RHS fold
encoding that predates this pass.

**The four SELECT-BOUND rows match golden on every field the dump prints,
vpiParent included** — not merely on the fields cmp reads.

### 3.2 a1 and a3 — the DISTANCE axis, which is the whole law

| arm | row | distance | golden | ours (pristine = patched) |
|---|---|---|---|---|
| a1 | `r_ipsw` `d[0 +: LPA]` in the lp's OWN scope | 0 | **ref_obj** | ref_obj ✓ |
| a1 | `r_ipsb`, `r_psl`, `r_psr`, `r_bit`, `r_2d`, `r_2db` | 0 | **ref_obj** | ref_obj ✓ |
| a1 | `r_mpw` `d[0 +: MP]` MODULE param | 1 | const par=param_assign | const, par=ips (R4) |
| a3 | `p_own` `d[0 +: LPY]` | 0 | **ref_obj** | ref_obj ✓ |
| a3 | `p_par` `d[0 +: LPX]` | 1 | const par=param_assign | **ref_obj ✗** → ✓ exact |
| a3 | `p_mod` `d[0 +: MP]` | 2 | **ref_obj** | ref_obj ✓ |
| a3 | `p_proc` `always_comb … d[0 +: LPX]` | 1 | const par=param_assign | **ref_obj ✗** → ✓ exact |
| a3 | `p_ini` `logic […] p_ini = d[0 +: LPX]` | 2 (var prefix) | **ref_obj** | ref_obj ✓ |
| a3 | `p_lhs[LPX +: 4]` — cont_assign LHS | 1 | const par=**ips** | **ref_obj ✗** → digits ✓, parent R5 |
| a3 | `z_1up` `d[0 +: LPY]` in gen_z | 1 | const par=param_assign | **ref_obj ✗** → ✓ exact |
| a3 | `z_2up` `d[0 +: LPX]` in gen_z | 2 | **ref_obj** | ref_obj ✓ |
| a3 | `z_3up` `d[0 +: MP]` in gen_z | 3 | **ref_obj** | ref_obj ✓ |
| a3 | `z_gv` `d[x +: 4]` GENVAR in gen_z | 2 | **ref_obj** | ref_obj ✓ |
| b1 | `r_same` (distance 0), `r_proc` (distance 0) | 0 | **ref_obj** | ref_obj ✓ |
| b1 | `r_dini` var INIT, own scope | 1 (var prefix) | const par=param_assign | **ref_obj ✗** → ✓ exact |
| b1 | `r_nest` in `gen_y`, `r_ifgen` in `gen_if` | 1 | const par=param_assign | **ref_obj ✗** → ✓ exact |

**`p_proc` is the row that kills the "processes never fold" model** (which
b1's distance-0 `r_proc` alone would have supported), and **`p_ini` versus
`r_dini` is the pair that kills every "declaration initializers always fold"
model.** Both pairs are explained by the one number the law uses.

`a3` verdict: pristine **12 of 61 rows differ**; patched **4**, every one of
them a vpiParent-only difference that `uhdm-cmp` does not read — and `a3`'s
whole-file compare is **`cmp heads=0`**, i.e. that arm is now EXACTLY golden.
`b1`: 7 → 3. `a1` (the distance-0 control): **5 → 5, and its `o.dump` is
byte-identical to the pristine binary's** apart from the workdir path baked
into `builtin.sv`'s location (0 non-path differing lines) — the patch is inert
where the law says it is inert.

---

## 4. THE CENSUS — PREDICTED FIRST, THEN MEASURED

`census47.py` walks **both** whole-design dumps and calls a `constant`
SUBSTITUTED when its printed `vpiParent` is a `param_assign` while it hangs
STRUCTURALLY somewhere else (a declaration's own Rhs constant has container ==
`param_assign` and is therefore never counted — the first cut of the instrument
omitted that test and reported 12 815 "substitutions", 12 556 of which were
ordinary `param_assign` Rhs constants). Cells are keyed on
`(nearest enclosing named scope, field, span)` — uhdm-dump prints no file name.

It was run on the **pristine** pair first and the prediction written from that
artifact is committed verbatim as `CENSUS_PREDICT.txt`.

### 4.1 The prediction (from the ARTIFACT, before the patched binary existed)

| population | cells |
|---|---|
| `prim_keccak.sv` `indexed_part_select.vpiWidthExpr` (65:61, 66:68) | 48 |
| `prim_keccak.sv` `indexed_part_select.vpiBaseExpr` (66:58) | 24 |
| **TOTAL PREDICTED** | **72** |

over 24 distinct `gen_rho_x[i].gen_rho_y[j].gen_others` scopes, 3 cells each —
every (i,j) with `Offset != 0`. Predicted **non**-movers, named so a move would
be a failed prediction: the 32 `pinmux.sv:176` operand cells (a MODULE
parameter, not reachable by this law), the 122 keys where golden substitutes
and we already emit a matching constant by another path, the 145 keys where WE
substitute and golden does not, and the 6 keys ABSENT on our side.

### 4.2 The measurement (`census47_patched.txt`)

| census row | pristine | patched | delta |
|---|---|---|---|
| `ips.vpiWidthExpr` ours-substituted | 5 | **53** | **+48** |
| `ips.vpiWidthExpr` ours-**ref_obj** | 48 | **0** | **−48** |
| `ips.vpiBaseExpr` ours-substituted | 2 | **26** | **+24** |
| `ips.vpiBaseExpr` ours-**ref_obj** | 24 | **0** | **−24** |
| `operation.vpiOperand` ours-ref_obj (pinmux) | 32 | 32 | 0 |
| `ours-constant` rows (50/25/21/14/6/5/1) | 122 | 122 | 0 |
| `part_select` ours-substituted (13 right, 5 left) | 18 | 18 | 0 |
| ABSENT (3 width, 2 right, 1 base) | 6 | 6 | 0 |
| OVER-FIRE: ours substituted where golden is not | **145** | **145** | 0 |

**72 predicted, 72 moved, 0 in the other direction, every named non-mover still
in place** — and `census47_patched_cells.txt` contains **zero** prim_keccak
rows, i.e. none of the 72 moved to a value that merely looks right.

### 4.3 The line arithmetic, independently

`shapes47.sh` (multiset, ADDED and REMOVED separately, never a diff alignment):

```
ADDED shapes=131 instances=936   REMOVED shapes=170 instances=288   NET=+648
a lines=4655216  b lines=4655864
```

A removed `ref_obj` leaf is 5 dump lines; a substituted constant with its
borrowed parent, its typespec ref and that ref's actual is 14. 72 × (14 − 5) =
**648**, which is exactly the file's growth. Every ADDED/REMOVED shape is
prim_keccak's (`\_param_assign: , line:60:22`, `\_int_typespec: , line:61:18`,
`|vpiName:Offset`, the per-instance fullnames …); no other module appears.

`msdist.sh` against golden: **307 428 → 306 492**, i.e. −936, the ADDED count.
The distance to golden went DOWN by every line this pass wrote.

---

## 5. THE FIVE GATES

Every gate was run on the FINAL binary, md5
`f57b50b3987a6554a5ad63690c472d13`. No source was edited after the gates began.

| gate | result |
|---|---|
| **1 BUILD** | `/tmp/r10earl47/bld47.sh /tmp/wt_r10earl47`, ABSOLUTE paths, `-j 2`; `[100%] Linking CXX executable slang-uhdm`; **0** lines matching ` error:`; md5 asserted SEPARATELY afterwards, 32 hex; binary mtime `08:24:43` vs `ExprEmit.cpp` `08:20:54` and `UhdmExporter.h` `08:19:22` — no gate stands on a stale binary. BASE printed and grep-checked on BOTH trees: `f0d93e15…` |
| **2 GOLDENS** | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| **3 u2r** | see §5.1 |
| **4 surelog both modes** | see §5.2 |
| **5 BYTE VERIFIER** | see §5.3 |

`GOLDEN_DEFER` was left UNSET throughout (`sweeps47.sh` unsets it explicitly so
an inherited value cannot leak in). `verify_golden.py` SILENTLY DEFAULTS
`SLANG_UHDM`, so every sweep EXPORTED it and the binary each sweep ACTUALLY
invoked was read back out of that sweep's own `cmds.txt`.

**R9 of r10earl46 is FIXED in this pass's copy of the harness.** `sweeps46.sh`
printed a "cmds.txt binary:" line built from `grep -o '[^ ]*slang-uhdm'`, whose
first match on the command line is the GOLDEN CACHE path, not the binary —
every earlier README that quoted that line quoted something that cannot show
what it claimed. `sweeps47.sh` uses `grep -oE '/[^ ]*/build/slang-uhdm'` and
the lines it printed are quoted below verbatim.

### 5.1 GATE 3 — the uhdm2rtlil corpus, both modes, both binaries

```
uhdm2rtlil default   pat : 679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
uhdm2rtlil testflags pat : 679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
uhdm2rtlil default   pris: 679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
uhdm2rtlil testflags pris: 679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
   cmds.txt binary: /tmp/wt_r10earl47/build/slang-uhdm       (pat sweeps)
   cmds.txt binary: /tmp/wt_r10earl47pris/build/slang-uhdm   (pris sweeps)
```

`ct8rows.sh results/gate_uhdm2rtlil.csv <fresh testflags csv>` (the committed
authoritative baseline is READ ONLY — the u2r baseline carries 731 testflags
rows and no default rows, which is why the fresh side is the testflags CSV and
not a concatenation):

```
baseline: 732 lines = 731 ROWS      fresh: 732 lines = 731 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  testflags  base :  52 blank / 183 differ / 496 match
  testflags  fresh:  52 blank / 183 differ / 496 match
PASS: every row byte-identical to the committed baseline
```

The PRISTINE sweep was checked against the same committed baseline as a
control: **0 differing rows**. The sorted patched/pristine CSVs `diff` **EMPTY
in both modes**.

### 5.2 GATE 4 — the surelog corpus, both modes

```
baseline: 1589 lines = 1588 ROWS      fresh: 1589 lines = 1588 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  default    469 CMP_EQUAL   11 CMP_NOTEQUAL   5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
  testflags  465 CMP_EQUAL    8 CMP_NOTEQUAL   5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
             3 NO_DATABASE  1 NO_UHDM  1 TIMEOUT  2 UNTRANSLATABLE
---- DUMP-column histogram, base -> fresh, IDENTICAL in both modes
  default    325 blank / 244 differ / 225 match
  testflags  329 blank / 300 differ / 165 match
PASS: every row byte-identical to the committed baseline
```

`469/11` and `465/8`, `FAIL 25/23`, `DEFER 5/5`, every histogram unchanged, and
the sorted patched/pristine CSVs `diff` EMPTY in both modes.

### 5.3 GATE 5 — the byte verifier, both corpora, both modes

`SELFCHECK=1 SELFCHECK1=1 byteverify47.sh <pat root> <pris root>`, one workdir
ROOT per (corpus, binary) with BOTH modes inside it:

```
uhdm2rtlil   PATH_SETS_IDENTICAL (1358 paths)     MOVERS: 0 / 1358
  SELFCHECK  1357 / 1358 flagged        SELFCHECK1  1  (= 0 real + 1 corrupted)

surelog      PATH_SETS_IDENTICAL (953 paths)      MOVERS: 1 / 953
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
        patched=09b53b21d06d  pristine=98b93a3e54d7
  SELFCHECK   952 / 953 flagged         SELFCHECK1  2  (= 1 real + 1 corrupted)
```

Both negative controls behave exactly as specified: the all-vs-one control
flags every path, and the single-corruption control reports precisely
`real movers + 1`.

#### The MOVER RULE applied to the one mover

| mover | size delta | real? | per-shape content, and DIRECTION vs GOLDEN |
|---|---|---|---|
| `Earlgrey_0_1` default | **+486 B** (49 939 391 → 49 939 877) | **REAL by size** | 936 dump lines ADDED / 288 REMOVED, NET +648; every shape prim_keccak's; MULTISET DISTANCE vs golden **307 428 → 306 492** |

The verifier's Earlgrey database is **byte-identical to the standalone
`earl47.sh` run** (`09b53b21d06dbd0d18127237992f87ce` for both, and for a
second independent run — Earlgrey is BYTE-DETERMINISTIC under this binary), so
every Earlgrey number in §4 was produced by the same bytes the gate measured.
The pristine side likewise matches (`98b93a3e54d7bcb076eadaa7de850267`), which
is also the database r10earl46 shipped — the base did not drift between
`c31af36` and `f0d93e1` for this test.

#### Named-database canaries, checked BY NAME

`bynames.sh` (written for this pass) closes the r10earl46 trap explicitly: it
enumerates the databases that EXIST under the patched root and reports
`ABSENT-PRISTINE` / `NO-DATABASE` separately, so a name with no database on
either side can never read as a mover the way a bare `cmp` of two missing files
does.

```
surelog : InterfaceModPort BlackParrotComplex YosysOldOr SVSwitch SimpleUVM
          SeqDriver BuildUVMPkg Scoreboard Earlgrey_0_1
          -> identical=15  moved=1 (Earlgrey_0_1 default)  absent=0
u2r     : gen_test4 gen_test5 gen_test9 genvar_loop_decl_2 genvar_loop_decl_3
          paramod_genscope_child genscope_cells LocalParamInNestedForLoops
          int_types (+ InterfaceModPort / SVSwitch, surelog-only names,
          reported NO-DATABASE rather than skipped)
          -> identical=22  moved=0  absent=0
```

**Every genscope canary the brief protects is byte-identical**, including
`gen_test4`, which r10earl46 moved — this pass does not touch it.

#### Canary scripts

| check | result |
|---|---|
| `canaries.sh` vs committed u2r baseline | `ok=8 changed=0 absent=0`, 25 unknown-names (all surelog-only, expected) |
| `canaries.sh` vs committed surelog baseline | `ok=52 changed=0 absent=0`, 7 unknown-names (all u2r-only, expected) |
| `ctcan2.sh` u2r, baseline FIRST, `EXPECT_UNKNOWN=6` | `ok=1 changed=0 absent=0 unknown-patterns=6` → PASS |
| `ctcan2.sh` surelog, baseline FIRST, `EXPECT_UNKNOWN=1` | `ok=58 changed=0 absent=0 unknown-patterns=1` → PASS |
| `canaudit.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` → PASS |

### 5.4 The Earlgrey head: 46 → 644, and the row ADVANCES

The pristine run reproduced the committed r10earl46 witness EXACTLY (`diff` of
`wd_pris/cmp.log` against `tools/probe/r10earl46repro/r6_nexthead46.cmp` is
empty — saved as `r6_oldhead47_pristine.cmp`), so the 46-line head was still
standing at `f0d93e1`. The patched run's head is 644 lines and sits in a
different file (`r6_nexthead47.cmp`, §6 R0).

---

## 6. RANKED RESIDUES

Ranked by Earlgrey_0_1 cells first, then by how sharply the shape is
characterised. Every count is measured.

**R0 — THE NEXT HEAD, `prim_present.sv:91-95`, 644 lines.** Committed witness
`r6_nexthead47.cmp`. Golden **FLATTENS the `gen_enc` if-generate scope**: its
gen_scope_array is `work@prim_present.gen_round[0].gen_d64` hanging directly off
`gen_round[0]`, while we emit `work@prim_present.gen_round[0].gen_enc.gen_d64`
with the `gen_enc` level in between. A gen-scope NESTING/NAMING question, not a
fold question, and the row's next law.

**R1 — the `bit_select` INDEX position at distance 1, 0 Earlgrey cells, 6 arm
cells (`a2` `n_bit`).** Golden substitutes with the constant parented at the
**bit_select**, not the param_assign. Same distance, same symbol class,
different container. Not implemented because Earlgrey has none: the census's 6
`bit_select.vpiIndex` golden-substituted keys are all cells where we already
emit a matching constant.

**R2 — the bare cont_assign Rhs at distance 1, 0 Earlgrey cells, 3 arm cells
(`a2` `n_rhs`).** Golden substitutes with the constant parented at the
**cont_assign**. We do exactly this at distance 0 already (the `genLpConst`
SHARE in ModuleEmit's gen-CA arm); the distance-1 twin is the same object with
a different parent and is a two-line extension of that arm, not of this one —
which is why it is fenced out here rather than done sloppily from ExprEmit.

**R3 — the operation OPERAND at distance 1, 32 Earlgrey cells, 3 arm cells.**
`a2` `n_op` (`LPA + 1`) and — the Earlgrey population — `pinmux.sv:176:43`,
`sleep_mux = $bits(…)'({MioPeriphHasSleepMode, 1'b1, 1'b1, 1'b1})` in
`gen_mio_out[k]`, 32 cells, one per MIO pad. The Earlgrey cells are a **MODULE
parameter of `pinmux` read one scope down**, not a gen-scope localparam, so
they are not in `genLpFoldByPath` and this law cannot reach them at all. The
distance is the same (one hop); the carrier is ParamEmit's module-parameter
fold. **This is the largest single remaining `ref_obj`-where-golden-substitutes
population in Earlgrey and it is the obvious next fold pass.**

**R4 — the MODULE parameter at distance 1 in a select bound: right digits,
wrong parent. 0 cmp cells, 15 arm cells.** `a1` `r_mpw` / `a2`-`a3` module-param
bound rows: we already fold `d[0 +: MP]` to `UINT:8 ct9 sz32 dec=8`, matching
golden on every field `uhdm-cmp` reads, but parent the constant at the
`indexed_part_select` where golden parents it at the `param_assign`. Since
`BaseClass::Compare` never reads vpiParent this costs nothing today; it is a
dump-fidelity residue and it belongs with R3's carrier.

**R5 — the cont_assign LHS bound: golden parents at the select. 0 Earlgrey
cells, 6 arm cells.** `a3` `p_lhs[LPX +: 4]` at distance 1: after this pass the
digits/size/encoding/typespec are golden's exactly, and the ONLY difference is
that golden parents the constant at the `indexed_part_select` while we (through
the one helper) parent it at the `param_assign`. Deliberately left: matching it
means passing the container into the helper and re-running five gates for a
field cmp does not read.

**R6 — the port-connection bound fold's ENCODING, 0 Earlgrey cells, 6 arm
cells.** `b1`'s `b1_leaf u_leaf (.i(d[0 +: LPA]), …)` at distance 1: golden
writes `UINT:0` for the base and `INT:6` for the width; we write `INT:0` and
`UINT:6` — the two encodings **swapped**. Pre-existing (`genvarConnFold`
territory), untouched by this pass, and unchanged before and after.

**R7 — 145 keys where WE substitute and golden does not** (141
`operation.vpiOperand`, 4 `bit_select.vpiIndex`). Pre-existing over-fire of some
OTHER fold path, counted before and after: **145 both times.** It must not
grow, and this pass did not grow it.

**R8 — census instrument: 6 ABSENT keys.** 3 `ips.vpiWidthExpr`, 2
`part_select.vpiRightRange`, 1 `ips.vpiBaseExpr` where golden has a substituted
constant and our side has no object at that (scope, field, span) at all. These
are STRUCTURAL differences (a select we do not emit, or emit elsewhere), not
leaf questions, and the instrument correctly refuses to guess.

**R9 — `a1`'s five standing rows are a DIFFERENT law.** After this pass a1 still
differs on 5 of 36 rows: two module-param parent cells (R4), two cells where
golden emits NO operand at all because it folded `MP + 1` whole, and one span
`?` row where both sides fold the RHS but disagree on the encoding
(`INT:7` vs `UINT:7`). All are distance-0 or module-param rows, i.e. outside
this law by construction.

---

## 7. REFUTATIONS, STATED PLAINLY

**R-1. The brief's framing — "the § genLpConst SHARE law one step further out"
— is the wrong shape.** The share mechanism (ModuleEmit re-parenting the
localparam's own fold constant into a reading gen CA) is a distance-0
mechanism and is not what golden does here: golden mints a SEPARATE constant
at the USE's span that merely BORROWS the param_assign as a parent, and it does
so only one scope down. This pass shares nothing; it copies.

**R-2. "Golden substitutes a gen localparam wherever it is read below its
scope" — REFUTED, and it would have been a 19-cell over-fire.** `a3`'s `z_2up`
(distance 2), `p_mod` (distance 2), `z_3up` (distance 3) and `a2`'s `n_mpw` /
`n_mpb` (distance 2) all keep a `ref_obj` in golden. The census's own OVER-FIRE
row is the standing warning: 145 keys already exist where we substitute and
golden does not.

**R-3. "The position discriminates" — REFUTED.** At distance 1 golden
substitutes in EVERY position measured: both indexed-part-select bounds, both
part-select ranges, a bit_select index, an operation operand, a bare
cont_assign Rhs, in a var_select-with-indices and in the whole-variable form,
inside a cont_assign and inside an `always_comb`. The position determines only
which object the constant is PARENTED at (param_assign for a select bound, the
container otherwise) — and vpiParent is exactly the field `uhdm-cmp` does not
read.

**R-4. "It is the def/allModules view" — REFUTED, and it nearly slipped
through the instrument.** `prim_keccak` is never instantiated in Earlgrey, so
its unrolled scopes could plausibly have been a def-view-only phenomenon. The
first `grid47.py` merged the def and elab views (identical scope names, first
occurrence won) and would have shown whatever the def view said. Splitting them
shows the substitution is in the **elab** view and that the def view does not
unroll the generate at all (`work@a1_earl47.gen_x`, no index), so it can carry
no cells of this kind either way.

**R-5. "`%`/`-`-folded values fold at the use site, literal ones do not" —
REFUTED.** `a2`'s `n_ipswl` reads `LPL = 8`, a literal-init localparam whose
fold is `UINT:8 ct9`, and golden substitutes it exactly like the `INT` ones.
The law does not look at the value at all; it copies whatever the declaration's
fold constant carries, which is what makes it compose with
§ genLpFoldSignedStructural46 instead of duplicating it.

**R-6. My own first arm found NOTHING, and the null result was the clue.**
`a1` — twelve positions, a genvar control and a module-param control, in the
localparam's OWN gen scope — came back with golden emitting a `ref_obj`
everywhere, i.e. "golden does not do this at all", which contradicts the
committed witness. The arm was not wrong; it was measuring distance 0. Reading
that as "no law here" would have ended the pass with a false refutation of a
head that is right there in `r6_nexthead46.cmp`.

**R-7. Nothing here says the `genLpConst` share, the hier-index fold or
`genvarConnFold` are right.** All three were left byte-for-byte alone. The new
helper is only ever consulted where the existing code was about to emit a plain
`ref_obj` (it is the `if` of an `if / else if`), so no existing fold can be
overridden by it.

---

## 8. REPRODUCING

```sh
# pristine + patched worktrees at f0d93e1, both built -j 2
/tmp/r10earl47/bld47.sh /tmp/wt_r10earl47pris
/tmp/r10earl47/bld47.sh /tmp/wt_r10earl47

# the head, before and after
SLANG_UHDM=/tmp/wt_r10earl47pris/build/slang-uhdm ./earl47.sh /tmp/r10earl47/wd_pris
SLANG_UHDM=/tmp/wt_r10earl47/build/slang-uhdm     ./earl47.sh /tmp/r10earl47/wd_pat

# the grid (LHS always golden), per arm and per scope
SLANG_UHDM=<bin> ./arm47.sh a2_earl47.sv /tmp/r10earl47/arm_a2
python3 grid47.py /tmp/r10earl47/arm_a2/g.dump /tmp/r10earl47/arm_a2/o.dump 'gen_x[1].gen_y[0]'

# the census, both sides, design-wide
uhdm-dump <golden.uhdm> | sed 1d > g.dump
python3 census47.py g.dump /tmp/r10earl47/wd_pris/o.dump /tmp/r10earl47/census47_pristine
python3 census47.py g.dump /tmp/r10earl47/wd_pat/o.dump  /tmp/r10earl47/census47_patched

# movers, per shape, by MULTISET, ADDED and REMOVED separately
./shapes47.sh /tmp/r10earl47/wd_pris/o.dump /tmp/r10earl47/wd_pat/o.dump
./msdist.sh   /tmp/r10earl47/g.dump /tmp/r10earl47/wd_pat/o.dump
```

`README.verifier.md` is the VERIFIER's to author and is deliberately absent
here.
