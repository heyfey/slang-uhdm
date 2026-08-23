# r10earl72 — § caOpFoldElabTs72

**Base commit `3f50888`. The Earlgrey_0_1 head that r10earl71 named as R0 —
17 lines, one head, byte-identical in both modes — is CLEARED in both modes.**

---

## The head, decoded before any code was written

`HEAD_BEFORE_default.cmp` / `HEAD_BEFORE_testflags.cmp` (the pristine binary,
md5 `495802c9704f87d78832619fd95e55ae`, which rebuilds byte-identical to the
main tree at `3f50888`):

```
LHS: ref_typespec (work@top_earlgrey.u_flash_eflash.gen_flash_banks[0].i_core.i_rd)
       vpiParent -> constant   130:30-130:36
       vpiActual -> int_typespec 18:13-18:16
RHS: <null>
```

**Which arm.** `expr::Compare`
(`UHDM/build/generated/src/expr.cpp:83-102`) reads `VpiDecompile`, then
`VpiSize`, then `SafeCompare(lhs->Typespec(), rhs->Typespec())`. Decompile and
size agree on this constant, so the failing field is the **singular**
`Typespec` arm, and `BaseClass.h:187-199`'s singular overload with
`lhs != nullptr && rhs == nullptr` sets `m_failedLhs` to golden's
`ref_typespec` and leaves `m_failedRhs` unset — hence the `RHS: <null>`
spelling. The `ref_typespec`'s `vpiFullName` is the instantiation path, a
Surelog naming quirk; `typespec::Compare` never reads a fullname.

**Which object.** `flash_phy_rd.sv:130`

```systemverilog
  assign alloc = no_match ? {NumBuf{req_i}} &  buf_alloc : '0;
```

`130:30-130:36` is `NumBuf`, the **repeat count of the multi-concatenation**,
and `NumBuf` is `parameter int NumBuf = 4;` at `flash_phy_pkg.sv:18:13-18:16`
(`18:13-18:16` is the `int` keyword — the parameter's own declaration
typespec). `flash_phy_rd` reads it through `import flash_phy_pkg::*`.

**Where the copies are** (`findobj72`, the object located by span and its
`VpiParent` chain printed, run on golden and on both of our binaries):

| copy | golden | ours (pristine) |
|---|---|---|
| `constant <- param_assign <- module_inst` (def) | `ts=int_typespec` | — |
| `constant <- op x3 <- cont_assign <- module_inst` (def) | — | `ts=int_typespec` |
| `... <- cont_assign <- module_inst(i_rd) <- ... gen_flash_banks[0]` | `ts=int_typespec` | **`ts=NO_TS`** |
| `... <- cont_assign <- module_inst(i_rd) <- ... gen_flash_banks[1]` | `ts=int_typespec` | **`ts=NO_TS`** |

So the miss is **ELAB-only and it is exactly two objects** (the head names
`[0]`; `[1]` is the same defect one Compare step later). The def-listing copy
already carries the stamp in both binaries — the two producers park it under
different parents (golden re-parents it at the package `param_assign`, we leave
it under the operation), but `vpiParent` is read by no generated `Compare`, so
that difference is invisible to the judge and is not touched here.

---

## The law

**§ caOpFoldElabTs72 — a fold of a wildcard-imported package parameter that a
cont-assign RHS reduces carries the parameter's own declaration typespec in the
ELABORATED body exactly as it does in the DEF listing, whenever an OPERATION
stands between the fold and the `cont_assign`.**

`§ caOpFoldTs` (r10earl14) already implemented the DEF half and recorded the
ELAB half as a measured-but-not-taken note, because the *direct-parent* arm
beside it excludes `contAssignView == 2`. That exclusion does not generalise,
and Surelog says why.

### Decoded from Surelog

`UhdmWriter::writeCont_assign`
(`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:2090`) walks
`netlist->cont_assigns()` for the instance. At **:2121-2131** it does this:

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  UHDM::any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
  if (var) {
    if (rhs->UhdmType() == uhdmoperation) {
      if (cloned == false) {
        ElaboratorContext elaboratorContext(&s, false, true);
        const UHDM::any* pp = assign->VpiParent();
        assign = (cont_assign*)UHDM::clone_tree(assign, &elaboratorContext);
        ...
        any* rhstmp = m_helper.reduceExpr((expr*)rhs, invalidValue, mod, ...);
```

The elaborated copy is a **`clone_tree` of the def-compiled cont_assign**, and
the clone is made *only* when the Lhs is a `ref_obj` **and the Rhs is an
`operation`**. The clone carries the def tree's typespecs with it, then
`reduceExpr` runs over it in the instance's context; when the whole Rhs cannot
reduce (here `req_i` and `buf_alloc` are nets) the cloned sub-tree survives —
**including the constant the DEF compile had already folded out of `NumBuf`,
with the `ref_typespec` it was given there.** That is the entire mechanism, and
it is why the same stamp appears under `gen_flash_banks[0]` and `[1]`.

When the Rhs is **not** an operation Surelog never clones: the elaborated list
holds the DEF OBJECT ITSELF, so there is nothing to stamp separately. The grid
confirms this from the other side — golden's elaborated body of `g1m` contains
no `CA_L32/L34/L36/L40` rows at all (those four are select-Rhs assigns).

The patched gate is therefore exactly the writer's clone condition:
`contAssignView != 0` (was `== 1`) plus the pre-existing walk "up through
operations, land on a `cont_assign`".

### Measured on golden

`g1_pos72.sv` — ONE wildcard-imported package `int`, fourteen positions inside
a module-body cont-assign, module instantiated once. Every cell read with
`tscen72` (a direct `.uhdm` reader; Earlgrey's `uhdm-dump` is >1 GB) in the DEF
listing and in the elaborated body:

| position | source | golden DEF | golden ELAB | ours before |
|---|---|---|---|---|
| P1 repeat count, 2 ops deep | `{NB{req_i}} & buf_alloc` | int_ts | **int_ts** | `<null>` |
| P2 repeat count, 1 op deep | `{NB{req_i}}` | int_ts | **int_ts** | `<null>` |
| P3 concat MEMBER | `{NB, bus_i}` | int_ts | **int_ts** | `<null>` |
| P10 ternary arm | `req_i ? NB : 32'h7` | int_ts | **int_ts** | `<null>` |
| P11 3 ops deep | `({NB{req_i}} & buf_alloc) \| wide` | int_ts | **int_ts** | `<null>` |
| P4 binary operand | `NB + 32'h1` | int_ts | whole Rhs reduces away | = golden |
| P12 `$clog2` argument | `$clog2(NB)` | int_ts | whole Rhs reduces away | DEF miss (R4) |
| P8 whole Rhs | `assign p8 = NB;` | int_ts | int_ts | = golden |
| P13 net-decl-assign | `wire p13 = NB + 32'h1;` | — | int_ts | = golden |
| P5/P6/P7/P9 select Rhs | `bus_i[NB]`, `bus_i[NB:1]`, `bus_i[NB-1:0]`, `bus_i[1 +: NB]` | int_ts | **not cloned at all** | = golden |
| P14 port-connection count | `.pi({NB{1'b1}})` | int_ts | whole replication folds | = golden |

Five cells were missing and five moved. `GRID_SCORE.txt`: g1 scores
**TO-GOLDEN 5 / AWAY-GOLDEN 0 / MOVED-WRONG 0** in BOTH views.

`g2_origin72.sv` — the same position (a repeat count under one `&`), the symbol's
ORIGIN and the cont-assign's HOME varied, three instances of the module:

| origin | golden (DEF and ELAB alike) |
|---|---|
| wildcard-imported package `parameter int NB` | int_typespec, signed |
| the same parameter read QUALIFIED `g2p::NB` | **no stamp** (and no stamp in ours either) |
| package `parameter bit [7:0] TB` | **bit_typespec** |
| package IMPLICITLY typed `parameter UT = 5` | int_typespec, **UNSIGNED** |
| module parameter `MP` | **never folds** — stays a ref |
| module localparam `ML` | **never folds** |
| gen-scope localparam `GL` | **never folds** |
| a genvar `(i+1)` | only the literal `1` folds, and bare |

so the `importedParamDefTs` + no-`::` gate the DEF half already carried IS the
whole origin rule, and the typespec KIND follows the declaration, not the
position. HOMES: every one of `u0`/`u1`/`u2` stamps identically, and so does
every iteration of a gen-for **inside** the instance body; a NESTED gen block
does not fold the read at all (golden keeps a `ref_obj` to an `enum_const`), so
it is out of this law's reach.

---

## Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 17 cmp lines, 1 head | 64 cmp lines, 1 head |
| Earlgrey_0_1 / testflags | 17 cmp lines, 1 head | 64 cmp lines, 1 head |

The line count went UP because the **head OBJECT changed** (a cmp line count is
the head's decompile DEPTH, never a distance): the `ref_typespec`/`<null>` miss
is gone and the next head is a different family (below). The two modes remain
byte-identical modulo object ids.

**Earlgrey census** (`CENSUS.txt`; every constant reachable from a
`cont_assign`, a port `High_conn` or a `param_assign`, keyed on the owner's
`VpiParent` chain + site + positional path, 3-way multiset join, calibrated
golden-vs-golden first):

| | cells | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG |
|---|---|---|---|---|
| default | 146,740 | **6** | 0 | 0 |
| testflags | 237,698 | **12** | 0 | 0 |
| calibration golden-vs-golden | 144,381 / 234,229 | all STILL-RIGHT | | |

The 6 and 12 are the two objects (`gen_flash_banks[0]` and `[1]`) times the
listener's visit multiplicity. The whole-database **object-kind histogram**
(`kh72`) pins the delta shut: **+2 `ref_typespec` and +2 `int_typespec` per
mode, and no other kind's count moves by one.**

---

## Gates

All green — `GATES.txt` has the full battery. In one line: goldens 23/0 and
0/23 negative; uhdm2rtlil 679/50/2 in both modes with **0 differing rows**
against the committed baseline AND against my own pristine sweep; surelog
**0 differing rows over 1588** (status and dump column) with an identical
status histogram; **no row converted and `results/*.csv` not edited**; byte
movers 0/1358 and 3/956, the three being the two PREDICTED Earlgrey databases
plus the known Scoreboard/default coin (order-blind dump diff = 0 lines over
1,099,483 sorted lines); 52 + 8 canaries unchanged, ctcan2 PASS both corpora,
`canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0; the five protected databases
byte-identical with `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on
their pins.

**Movers were PREDICTED BY NAME from the pristine databases first**
(`PREDICT_R0.txt`, `predict72.sh`): 0 of 1358 uhdm2rtlil databases carry a
candidate, 2 of 956 surelog ones do, and they are the two that moved.

---

## Boundary

A COPY of `tools/probe` with **no path filter**, `.sv` and `.v`, at ANY depth,
both views, both frozen binaries, workdir-normalised dump byte-compare; the
file list is read on fd 3 with children `</dev/null`, `PROCESSED` is asserted
and every cell records its `rc`.

- **WIDE, per file**: `PROCESSED=3299 identical=6309 DIFFERING=15 no_output=274`
- **DIR, per directory**: `PROCESSED=1478 identical=2705 DIFFERING=8 no_output=243`

Every `rc=139` (20 wide, 10 dir) pairs up A-with-B — the pre-existing elab
segfaults, on both binaries; no new crash, no new timeout. Each differing arm:

| arm | verdict |
|---|---|
| `r10earl72repro/g1_pos72.sv`, `g2_origin72.sv` | this pass's own grids |
| `r10earl_repro/gg.sv` | **TO-GOLDEN 5, AWAY 0** both views |
| `r10earl_repro/hh.sv` | **TO-GOLDEN 8, AWAY 0** both views |
| `r10earl_repro/wd.sv` (§ caOpFoldTs's own witness) | **TO-GOLDEN 2, AWAY 0** both views |
| `r10earl_repro/wf.sv` | **TO-GOLDEN 1, AWAY 0** both views |
| `r10earl_repro/wa24.sv` | **TO-GOLDEN 1, AWAY 0** (default; elab does not fire) |
| `r10v65repro/a2_pos.sv` | one cell, see below |
| `r10uvm75repro`, `r10uvm76repro` (dir walk only) | the known COIN, see below |

**`r10v65repro/a2_pos.sv`.** Line 40 is `assign c_repl = {{PW{1'b1}},27'b0};`.
Golden's ELABORATED copy reduces that whole Rhs to a single 32-bit `BIN`
constant; we keep the operation tree, so our elaborated body holds three
sub-constants golden does not have at all — a PRE-EXISTING whole-Rhs-reduce
gap, not this law's. One of those three (the `PW` fold) now takes the stamp.
It is neither TO-GOLDEN nor AWAY-GOLDEN: golden has no counterpart object, and
the judge fails that Rhs at `VpiType` long before any typespec is read. **The
cells § connIpsPkgParamBoundNoTs65 owns are byte-identical** — every `HC_*`
(port `High_conn`) row in this arm is unchanged in both views, and this law
cannot reach them (a port connection's ancestor is a `port`, and it is emitted
with `contAssignView == 0`).

**`r10uvm75repro` / `r10uvm76repro`.** Whole-directory compiles only; the
per-file walk sees nothing. The diff is a `vpiTaskFunc` LIST-ORDER flip: the
order-blind (sorted) dump diff is **0 lines** on both, and running the
**pristine binary alone** three times reproduces flips of 10-16 lines. The
known per-invocation coin, not a mover.

---

## Refuted / not taken

- **"The DEF/ELAB split is a Surelog policy about elaborated bodies."**
  Refuted: it is `writeCont_assign`'s clone condition. The stamp is not
  re-derived in the instance at all — it rides in on `clone_tree`, which is
  why a select-Rhs cont_assign has no elaborated copy to stamp and why the
  stamped value, span, `Instance` (`package(g2p)`) and signedness are
  byte-identical to the def copy's in golden (`tsdet72`, wd.sv 36:21 and
  51:16).
- **Fixing the implicit-package-parameter signedness here.** `makeParamTs`
  has a dozen call sites; widening this pass into it would move cells with no
  head to justify them. Recorded as R2 instead.

---

## Residues, ranked (R0 first)

**R0 — THE NEW EARLGREY HEAD, both modes, 64 lines, 1 head, identical modulo
ids (`HEAD_AFTER_*.cmp`). A param_assign value ENCODING miss:**

```
prim_flash.sv:16   parameter int WordsPerPage = 256,
flash_phy_core.sv:215   .WordsPerPage(WordsPerPage / WidthMultiple)   // -> 128

golden  constant 16:32-16:35  INT:128   vpiConstType 7 (vpiIntConst)
ours    constant 16:32-16:35  UINT:128  vpiConstType 9 (vpiUIntConst)
```

Decompile (`128`), size (32), span and the whole `ref_typespec` ->
`int_typespec@16:13-16:16` chain already agree; only `vpiValue`'s prefix and
`vpiConstType` differ, and `constant::Compare` reads `VpiConstType` right after
`expr::Compare`'s decompile/size/typespec. The elaborated value of an
`int`-declared module parameter whose actual is an **arithmetic expression over
`int`s** is stored `INT:`/`vpiIntConst` by Surelog and `UINT:`/`vpiUIntConst`
by us. This is r10earl71's **R3 (value ENCODING)** family, now promoted: it
sits next to earl71's four measured encoding shapes (`20 + 8'd4` -> `INT:`,
`signed'(20)` -> `INT:`, `$bits(logic [23:0])` -> `UINT:1`, an `int`-declared
based-binary -> sign-extended `INT:`) and a pass that decodes Surelog's
`adjustSize`/`ExprEval` signedness rule for a parameter-port ACTUAL should
clear all of them together.

**R1 — the gen-scope cont_assign twin of THIS law, 58 objects / 174 census
cells, Earlgrey BOTH modes, unchanged by this pass.** Golden stamps and we do
not, on every one; all of them are owned by a `gen_scope` (the
`u_xbar_main/u_sm1_*` family, e.g. `CA_L236:12` path
`RHS/op28[0]/op28[1]/op14[0]/hp[1]/w` — an indexed-part-select WIDTH inside a
`hier_path`) and the typespec golden wants is an UNSIGNED `int_typespec`.
Two things separate them from this pass: a gen-scope cont_assign is emitted by
a different site (`ModuleEmit` ~14786 / `gs->Cont_assigns` ~16198) that never
sets `contAssignView`, and the position is `ipsWidFold9`'s, not
`caOpFold9`'s. `g2_origin72.sv` row H1 is the ready-made positive control:
golden stamps a gen-for cont-assign fold in all 6 cells (3 instances x 2
iterations) and we still emit `<null>`.

**R2 — an IMPLICITLY typed package parameter's fold typespec is UNSIGNED in
golden and SIGNED in ours.** `g2_origin72.sv` row O4
(`parameter UT = 5;` read as `{UT{req_i}}`): golden `int_typespec tssgn=0`,
ours `tssgn=1`. The DEF cell was already wrong this way at `3f50888` (1 cell,
STILL-WRONG); this pass makes the 3 elaborated cells wrong the same way instead
of missing (MOVED-WRONG 3, AWAY-GOLDEN 0) — they inherit the def object's error
rather than inventing a new one. Neither shape occurs in either corpus (the
predictor finds 0 candidate databases outside Earlgrey, and Earlgrey's
`flash_phy_pkg` declares `parameter int`). Our own `parameter` OBJECT carries
the unsigned typespec correctly, so the defect is isolated to `makeParamTs`'s
`typedParam=true` clone.

**R3 — a `$clog2` ARGUMENT fold in a DEF-view cont-assign carries the stamp in
golden and not in ours** (`g1_pos72.sv` P12, 1 cell, DEF listing only, both
views, unchanged by this pass). § caOpFoldTs's comment records the opposite for
a part-select BOUND under a sys-func call (`vo.sv` row F, no stamp); a bare
argument of a `sys_func_call` that IS the cont-assign Rhs is a different cell
and golden does stamp it. Not in either corpus.

**R4 — the `--elabuhdm` net-decl-assign whole-Rhs fold.** `g1_pos72.sv` P13 /
`wd.sv` R3: in the `--elabuhdm` view we reduce `wire p13 = NB + 32'h1;` to one
`UINT:5` constant where golden keeps the operation with a stamped operand; in
the default view we already match. Pre-existing, `ndaRhsEmit`'s, untouched.

**Carried forward from r10earl71, unchanged and re-ranked below R0:** its R1
(gen-scope UNBOUND-ref class — module parameter / outer gen localparam /
genvar bounds, golden keeps a ref with a NULL actual, 24 cells per grid),
its R2 (the own-localparam fold we have INVERTED), and earl69's R1 / R5
prettyPrint names.

---

## Reproduction

Build `tscen72.cpp`, `findobj72.cpp`, `tsdet72.cpp` and `kh72.cpp` against
`~/.local/{include,lib64}`:

```
g++ -O2 -std=c++17 <file>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <file>
```

then

- `SLANG_UHDM=<bin> ./earl72.sh <outdir> [default|testflags]` — the official
  Earlgrey comparison (golden comes from the immutable cache, never re-run);
- `findobj72 <db> 130 30` — locate the head object and print its owner chain
  and typespec presence; `tsdet72 <db> 36 21` — every typespec field the judge
  reads, on both sides;
- `TSCEN72=… SCORE72=… PRIS=… PATCHED=… ./armscore72.sh <arm.sv> <dir>` —
  build one arm with Surelog + both frozen binaries in both views and score it
  against golden;
- `predict72.sh <sweep-workdir> <tscen72>` — the mover prediction;
- `kh72 <db>` — whole-database object-kind histogram (never `uhdm-dump` on
  Earlgrey);
- `byteverify.sh`, `ct8rows.sh`, `rowheads.sh`, `canaries.sh`, `ctcan2.sh`,
  `canaudit.sh` — the sweep gates;
- `PATCHED_BIN=… PRISTINE_BIN=… PROBE_ROOT=… vwide72.sh <filelist> <out>` and
  `vdir72.sh <dirlist> <out>` — the exhaustive boundary.

No integration, commit, main-tree edit, `results/` edit, stash or fenced-test
dispatch belongs to this pass.
