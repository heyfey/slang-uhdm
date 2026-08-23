# r10earl76 — § genScopeProcLoopCtrlNoFold76: a loop header is a scope Surelog compiles WITHOUT the instance

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `b494676`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The Earlgrey_0_1 head r10earl75 named as R0 — 36 cmp lines, one head,
byte-identical in both modes — is CLEARED in both modes,** and every other named
row's head is unchanged.

---

## 1. The head, reproduced before any code was written

`HEAD_BEFORE_{default,testflags}.cmp` are the verbatim pristine logs. They are
**identical to each other line for line**, they carry **36 lines and exactly one
head**, and the binary that produced them rebuilds to the main tree's own md5 at
`b494676` (`0488d7b62f80e7aecab313abd9320510`), so this pass starts on exactly
the object earl75's `README.md` §9 R0 named.

```
flash_phy_core.sv:191   for (int i = 0; i < WidthMultiple; i++)
                                            ^^^^^^^^^^^^^  191:27-191:40
in top_earlgrey.u_flash_eflash.gen_flash_banks[0|1].i_core.gen_prog_data

LHS (golden)  ref_obj  (…gen_flash_banks[0].i_core.gen_prog_data.WidthMultiple)
              |vpiParent -> operation 191:23-191:40
              |vpiName:WidthMultiple
              |vpiActual -> enum_const (WidthMultiple)
RHS (ours)    constant 191:27-191:40 |vpiDecompile:2 |vpiSize:32 |UINT:2
                                     |vpiConstType:9
```

**Which arm.** `basetype_t::Compare` (`BaseClass::Compare`) tests **VpiType**
first and names BOTH sides, so the failing field is the object **KIND** and
`expr::Compare` never reaches a value field. This is an OVER-FOLD, not a
mis-encoding — the fix must suppress the fold, not adjust the constant.

`WidthMultiple` is `flash_phy_pkg.sv:34
`parameter int WidthMultiple = DataWidth / BusWidth;`, read through
`module flash_phy_core import flash_phy_pkg::*;`.

---

## 2. Question 1 — what golden's `enum_const` IS (`ecprobe76`, `QUESTION1_ENUMCONST.txt`)

```
EC name=WidthMultiple val=INT:2 dec=2 sz=32 span=-:0:0-0:0 binders=1
   parent= … gen_flash_banks[0] … /gen_prog_data/gen_scope/always/begin/for_stmt/operation/ref_obj(WidthMultiple)
```

* it is **LOC-LESS** (no file, span `0:0-0:0`);
* its **`VpiParent` is the `ref_obj` that binds it**, so it lives NOWHERE in the
  package, the instance or the gen-scope tree — it is not the package
  parameter's value object and it is not reachable except through its binder;
* **`binders=1`**: a **per-reference CLONE**. The design holds 3578
  `enum_const`s, 1638 of them bound; exactly TWO are `WidthMultiple`, one per
  `gen_flash_banks` instance, each serving exactly one reference. It does **not**
  serve other refused folds;
* judged fields: `enum_const::Compare` reads `VpiType`/`VpiName`/`VpiDefName`
  (through `BaseClass::Compare`) then **`VpiName`, `VpiDecompile`, `VpiSize`** —
  and **never `VpiValue`**.

It is exactly the object `UhdmWriter::lateBinding` mints (§3).

---

## 3. Question 3 — the decode, from Surelog's source and then measured

**`CompileHelper::compileForLoop`**
(`~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp:2822`) compiles **all
four parts** of a for statement — the init RHS (`:2877`, `:2919`), the CONDITION
(`:2932`), the STEP (`:2954`) and the BODY (`:2976`) — with `Reduce::No` and
**no `instance`**; it is never handed one (`compileStmt` calls it at `:830`
without the instance argument). The three loop CONTROLS do the same one level
up:

```c++
// CompileStmt.cpp:665 (repeat), :683 (while), :701 (do…while)
compileExpression(component, fC, cond, compileDesign, Reduce::No, repeat)   // no instance
compileStmt   (component, fC, rstmt, compileDesign, Reduce::No, repeat, instance, …) // instance kept
```

so a loop's **CONTROL** loses the instance and its **BODY** keeps it.

Under `Reduce::No` with `instance == nullptr` the only substitution left in
`compileExpression` is the **COMPONENT-level** `getParam_assigns()` arm
(`CompileExpression.cpp:2915-2977`), which fires when `paramFromPackage` — i.e.
when the `parameter`'s **`VpiImported()` is non-empty**:

```c++
if (param_ass->Lhs()->UhdmType() == uhdmparameter) {
  const parameter* tp = (parameter*)param_ass->Lhs();
  if (!tp->VpiImported().empty()) paramFromPackage = true;
}
…
if ((reduce == Reduce::Yes) ||
    (paramFromPackage && (param_ass->Rhs()->UhdmType() == uhdmconstant))) { … clone … }
```

A module's `import pkg::*` **materializes** the package parameter into the
MODULE's `param_assigns` with that flag set — which is why the byte-identical
statement in the MODULE BODY folds. **A generate block is its own
`DesignComponent`** and its `param_assigns` hold only the block's own
localparams, so `result` stays null, the `ref_obj` is minted and
`component->needLateBinding(ref)` is called. `UhdmWriter::lateBinding`
(`UhdmWriter.cpp:3952`) then answers a PACKAGE name with `mod->getValue(name)`
and mints the clone §2 measured:

```c++
enum_const* c = s.MakeEnum_const();
c->VpiName(name);  c->VpiValue(value->uhdmValue());
c->VpiDecompile(value->decompiledValue());  c->VpiSize(value->getSize());
c->VpiParent(ref); ref->Actual_group(c);
```

and leaves a MODULE-scope name **UNBOUND** — which is exactly the origin table
§5 measures on golden.

The **fullname** follows the emitted prefix: a gen-scope process is emitted with
`prefix` = the GEN BLOCK's path, so `joinRef(prefix, name)` is
`…gen_flash_banks[0].i_core.gen_prog_data.WidthMultiple`, character for
character golden's. (No generated `Compare` reads `VpiFullName`; it is matched
for exactness, not because the judge sees it.)

---

## 4. Question 2 — the census, both databases × both modes (`CENSUS.txt`)

`cscen76` is `r10earl75repro/cscen75.cpp` extended to **`ref_obj`s**, because
this head is a KIND flip and a constant-only census is structurally blind to it:
our cell exists and golden's does not, which reads as "no golden cell" rather
than as the over-fold it is. `norm76.sh` therefore **drops the object kind from
the KEY** (it rides in the payload) so a flip is ONE cell, not two half-cells.
Every statement descent is TAGGED with its statement kind, so `for:c`, `whl:c`,
`dow:c`, `rpt:c` and `if:c` are distinguishable ROUTES — that tagging is what
makes "split by position" answerable at all.

Calibrated **golden-vs-golden first**: 182,545 (default) and 247,637
(testflags) keys, **all STILL-RIGHT**.

> **In the whole Earlgrey design there are TEN cells per mode where golden has a
> `ref_obj` and we have a `constant`. FOUR of them are in a gen-scope PROCESS,
> and all four are inside the FOR STATEMENT. There is not one cell anywhere,
> in either mode, where WE keep a `ref_obj` inside that region and golden
> folds.**

| mode | site | position | span | symbol |
|---|---|---|---|---|
| both | `gen_flash_banks[0|1].i_core.gen_prog_data`, `always_comb` | `for:c` | `flash_phy_core.sv:191:27-191:40` | `WidthMultiple` |
| both | the same `always_comb` | `for:b / if:c / ips WIDTH` | `:192:25-192:33` | `WordSelW` |

The other six per mode are **not processes**: gen-scope `cont_assign` and port
`High_conn` cells of earl72's R1 / earl65's mirror families (in testflags they
are `gen_lut`'s `LfsrDw` / `GAL_XOR_LUT_OFF`), untouched by this law.

**The MODULE-BODY twin is measured and it folds.** `g1_gsfor76.sv` row A puts
all fifteen positions in a module-body `always_comb`: golden emits a `constant`
at every one of them, the pristine binary matches, and the patched binary is
byte-identical there (`GOLDEN_TABLE.txt`, 81 cells, golden == pristine ==
patched). The law is gen-scope-only and the control proves it.

---

## 5. The golden grids (`GOLDEN_TABLE.txt`, `GRID_SCORE.txt`)

`g1_gsfor76.sv` — **15 positions × 7 homes**, the module instantiated once, the
gen-`for` home twice. `g2_orig76.sv` — **18 origins × 3 homes**.

**POSITION**, inside a gen-scope process (`always_comb`, `always_ff`, `initial`
alike):

| position | golden | pristine | patched |
|---|---|---|---|
| for INIT rhs (`for:i`) | ref → enum_const | **const** | **ref → enum_const** |
| for CONDITION (`for:c`) | ref → enum_const | **const** | **ref → enum_const** |
| for STEP (`for:n`) | ref → enum_const | **const** | **ref → enum_const** |
| for BODY (`for:b`) | ref → enum_const | **const** | **ref → enum_const** |
| a NESTED for's condition | ref → enum_const | **const** | **ref → enum_const** |
| `while` CONDITION | ref → enum_const | **const** | **ref → enum_const** |
| `do…while` CONDITION | ref → enum_const | **const** | **ref → enum_const** |
| `repeat` COUNT | ref → enum_const | **const** | **ref → enum_const** |
| `while` / `do…while` / `repeat` / `foreach` BODY | **const** | const | const (unchanged) |
| `if` CONDITION, `case` ITEM, `case` body, plain statement | **const** | const | const (unchanged) |

**HOME**:

| home | golden | patched |
|---|---|---|
| MODULE BODY (the control) | folds everything | **unchanged, still folds** |
| gen-`if` block | ref → enum_const | **matches** |
| gen-`for` block, both iterations | ref → enum_const | **matches** |
| gen-scope `always_ff` | ref → enum_const | **matches** |
| gen-scope `initial` | ref → enum_const | **matches** |
| NESTED gen block | ref → enum_const | already right (`§ genNestedScopePkgParamNoFold24`) |
| gen-scope FUNCTION body | ref → enum_const | **still folds — R1**, `!currentTf` |

**ORIGIN**, read from the for CONDITION of a depth-1 gen-scope `always_comb`:

| origin | golden | patched |
|---|---|---|
| wildcard-imported `parameter int NB = 4` | ref → enum_const `4`, sz 32 | **matches** |
| the same package read **QUALIFIED** `g76q::QA` | **FOLDS** | **FOLDS** (negative control holds) |
| EXPLICIT single import `import g76q::QX;` | ref → enum_const | **matches** |
| package `parameter bit [7:0] TB = 8'hA5` | ref → enum_const, dec `8'hA5`, sz 8 | **matches** |
| package IMPLICITLY typed `parameter NU = 5` | ref → enum_const, **sz 64** | **matches** |
| package `parameter longint NL = 40` | ref → enum_const, sz 64 | **matches** |
| package param from `$clog2` / `+` / `*` / `/` / `%` / `-` / `**` / cross-package copy | ref → enum_const, correct value and size | **matches** |
| module parameter / module localparam / gen-scope localparam / genvar | ref, **UNBOUND** | unchanged (this branch is under `scope->kind == Package`) |

**Score, all four arms, DEFAULT view, judge-visible fields:**

| arm | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | MOVED-SIDEWAYS | NOGOLD-MOVED |
|---|---:|---:|---:|---:|---:|
| `g1_gsfor76.sv` | **23** | 0 | 0 | 0 | 0 |
| `g2_orig76.sv` | **16** | 0 | 0 | 0 | 0 |
| `r10earl75repro/g1_gsproc75.sv` | **3** | 0 | 0 | 0 | 0 |
| `r10v75repro/a2_loops75.sv` | **5** | 0 | 0 | 0 | 0 |

In the `--elabuhdm` view the same cells read TOWARD-NOT-EQUAL and every other
bucket is 0 — that view emits BOTH the DEF listing's ref and the elaborated one
at the same key while golden has only one (earl75's R3, pre-existing and equally
true of the pristine binary).

**THE ONE COMPARE-INVISIBLE RESIDUE, named and measured.** Scored with the
`enum_const`'s `VpiValue` included, `g2_orig76.sv` shows 6 MOVED-SIDEWAYS cells:
golden writes `INT:` where Surelog's `Value` came out signed (`8/2`, `2*3`,
`9%4`, `9-4`, `2**3`, `(2*3)+1`) and we write `UINT:`. `enum_const::Compare`
(`UHDM/build/generated/src/enum_const.cpp`) reads `VpiType`, `VpiName`,
`VpiDefName`, `VpiDecompile` and `VpiSize` and **never `VpiValue`**, so the judge
cannot see it — and it is **not this law's**: the encoder is
`§ genNestedScopePkgParamNoFold24`'s, and the PRISTINE binary carries the
identical divergence at the nested-gen home (measured side by side on this arm,
golden `ND=INT:4` vs pristine `ND=UINT:4`). slang cannot reproduce the split:
its `ConstantValue` is signed for `8/2` and for `3+1` alike. Recorded as R2.

---

## 6. The law

**§ genScopeProcLoopCtrlNoFold76 — inside an ELABORATED generate scope's
PROCESS, an UNQUALIFIED (wildcard- or explicitly imported) package-parameter read
that stands inside the FOR STATEMENT (header AND body, at any nesting) or inside
a LOOP CONTROL EXPRESSION (a `while` condition, a `do…while` condition, a
`repeat` count) is NOT substituted: emit the gen-scope-named `ref_obj` bound to a
FRESH loc-less `enum_const` carrying the parameter's value — the same
per-reference clone `§ genNestedScopePkgParamNoFold24` mints one nesting level
in. It suppresses a FOLD; it writes no typespec, no size and no new statement.**

```c++
if (inGenScopeProc && !defGenProcessEmit && !inLhs &&
    !inParamInit && !currentTf &&
    (procForAllDepth9 > 0 || procLoopCtrlDepth76 > 0) &&
    rawText(expr.sourceRange).find("::") == std::string::npos) { … }
```

`procForAllDepth9` is the existing for-statement depth (`§ genProcParamFold`
measured the same region for a MODULE parameter). `procLoopCtrlDepth76` is new:
an RAII depth wrapped around the `repeat` COUNT, the `while` CONDITION and the
`do…while` CONDITION in `StmtEmit.cpp` — **around the CONTROL only, never the
body**, because Surelog passes the instance to the body's `compileStmt` and not
to the control's `compileExpression`, and golden folds in all five loop bodies.

The encoder is copied INLINE from `§ genNestedScopePkgParamNoFold24` and
deliberately not extracted (RESUME §9's no-premature-extraction rule).

**The two fences, both convicted on the grid before they were written:**

* **the loop BODIES stay folded** — golden emits a constant in the `while`,
  `do…while`, `repeat`, `foreach` and `forever` bodies (`g1_gsfor76.sv` rows
  B_P6/B_P8/B_P10/B_P11, `a2_loops75.sv`);
* **a QUALIFIED read is untouched** — `g76q::QA` folds in golden in every home,
  and the `::` test is the same discriminator law 24 and
  `§ defGenPkgParamFoldQual19` carry.

---

## 7. Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 36 cmp lines, 1 head | 11664 cmp lines, **1 head** |
| Earlgrey_0_1 / testflags | 36 cmp lines, 1 head | 11404 cmp lines, **1 head** |

The `for`-condition head is gone and the next head is a different family in a
different instance (R0 below). **A cmp line count is the head's decompile DEPTH,
never a distance**: the new head is a whole `module_inst` decompile, which is why
the number went up by three orders of magnitude while the design got closer.

**Earlgrey census** (`CENSUS.txt`, deduped, calibrated golden-vs-golden first):

| mode | keys | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | MOVED-SIDEWAYS | NOGOLD-MOVED |
|---|---:|---:|---:|---:|---:|---:|
| default | 185,773 | **4** | **0** | **0** | **0** | **0** |
| testflags | 249,393 | **4** | **0** | **0** | **0** | **0** |

(judge-visible fields; the four are `gen_flash_banks[0]` and `[1]` × the two
objects `WidthMultiple` and `WordSelW`). Nothing else in either database moved.

---

## 8. Gates

All green — `GATES.txt` carries every number. In one line: both binaries built
`-j 2` and frozen `chmod 555` before any sweep, and **every one of the 1462 +
1573 `cmds.txt` files per sweep audited by binary PATH — 0 name the main-tree
binary**; goldens 23/0 on BOTH binaries and 0/23 on `/bin/false`; uhdm2rtlil
**679/50/2 in both modes with 0 differing rows** against the committed baseline
AND against my own pristine sweep; surelog **0 differing rows over 1588** with
identical status histograms in both modes — **no row converted and
`results/*.csv` not edited**; byte movers **0/1358** and **3/956**, two of them
the PREDICTED Earlgrey databases and the third the documented Scoreboard/default
coin convicted by a neutral control; 52 + 8 canary rows unchanged, both
supplementary canary suites PASS, `canaudit` audited=29 UNCOVERED=0
FENCE-BREACH=0; all five protected databases byte-identical with
`SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on their pins; and every
other named row's head is unchanged.

Movers were **PREDICTED BY NAME from the PRISTINE databases first**
(`PREDICT_R0.txt`, `predict76.sh`): stage 1 flagged 9 databases, stage 2 refuted
4 by source, stage 3 refuted 3 more by the flagged constants' own shape (all
`sz=64` unsized loop bounds, and `hier_path`'s parameters are MODULE parameters),
leaving exactly the two Earlgrey databases — and exactly those two moved.

---

## 9. Boundary

`vwide76.sh` / `vdir76.sh` walk a COPY of `tools/probe` with **no path filter**,
`.sv` and `.v`, at ANY depth, both views, both frozen binaries, workdir-
normalised dump byte-compare; the file list is read on fd 3 with children
`</dev/null`, `PROCESSED` is asserted and every cell records its `rc`. **The four
slang-fenced tests are never dispatched** (the list is filtered; 0 files matched,
and `canaudit` asserts no driver in this directory names them).

- **WIDE, per file**: `PROCESSED=3484 identical=6680 DIFFERING=10 no_output=278`
- **DIR, per directory**: `PROCESSED=1508 identical=2754 DIFFERING=12 no_output=250`

`ARMS.txt` adjudicates every differing arm. In summary: this pass's two grids
and the two EARLIER-pass arms that carry this law's shape
(`r10earl75repro/g1_gsproc75.sv`, `r10v75repro/a2_loops75.sv`) move, and every
one of them moves **TO-GOLDEN with AWAY-GOLDEN 0 and MOVED-WRONG 0**;
`r10buvm22repro/g22.sv` is convicted **NOT this law** by a third, arm-disablable
binary (arm ON and arm OFF differ from the pristine by the same 12 lines and from
each other by 0 — the associative-array bound's allocation-tracking garbage
number, earl74's R5); and the three dir-only arms are the documented
per-invocation ORDERING coin (0 lines once both dumps are sorted, and the
PRISTINE binary alone differs from itself by 20-24 raw lines on the same arm).

Every `rc=139` pairs A with B in both walks (24 wide, 12 dir) — the pre-existing
elab segfaults, on both binaries. No new crash, no new timeout.

---

## 10. Residues, ranked (R0 first)

**R0 — THE NEW EARLGREY HEAD, both modes, 1 head each. A `module_inst` VECTOR
SIZE MISMATCH: golden classifies an INPUT port of a package-typedef'd logic
vector type as a `logic_var` in `Variables`, and we classify it as a `logic_net`
in `Nets`.**

```
spi_fwmode.sv:31   input  spi_device_pkg::spi_byte_t tx_data_i,
in  work@top_earlgrey.u_spi_device.u_fwmode   (spi_device.sv:330)

golden   Nets 17   Variables 11    tx_data_i -> logic_var
ours     Nets 18   Variables 10    tx_data_i -> logic_net
```

Both sides of the cmp head are the SAME `module_inst` object, which is the
signature of `BaseClass::SafeCompare`'s VECTOR overload on a SIZE MISMATCH
(RESUME §9): it sets both containers and names the OWNER on both sides, so the
cmp log cannot say which vector. `mvec76.cpp` (committed here) prints every
vector's size in `module_inst::Compare` order for one named instance out of one
database; `HEAD_R0_vectors_{golden,ours}.txt` and
`HEAD_R0_names_{golden,ours}.txt` are its output and name the single object.

**The discriminator is not "input" alone and not "typedef" alone**: in the same
port list `output spi_device_pkg::spi_byte_t rx_data_o` is a `logic_var` in
golden AND in ours, and `input spi_device_pkg::spi_mode_e mode_i` is an
`enum_var` in both. It is specifically an **INPUT** port whose type is a
package-typedef'd **LOGIC VECTOR**. The next pass should measure the
input/output × scalar/vector/enum/struct × typedef/inline grid on golden before
touching the net-vs-variable decision.

**R1 — the gen-scope FUNCTION and TASK body twin of this law.** `g1_gsfor76.sv`
row F: golden keeps the `ref_obj` + `enum_const` in a for statement and a repeat
count inside a **function declared in a generate block**, and both binaries fold
(3 cells, both views). This law carries `!currentTf` because the gen-scope tf is
emitted from `ModuleEmit.cpp:14618`, **before** the process loop sets
`inGenScopeProc` (and before `genNestedScopeEmit24` is set) — so law 24 has the
same hole one nesting level in. The fix is a gen-scope-subroutine marker set
around that call, not a change to this arm. 0 cells in the corpus.

**R2 — the `enum_const` VpiValue prefix, COMPARE-INVISIBLE and PRE-EXISTING.**
Golden writes `INT:` for a package parameter whose initialiser Surelog evaluated
to a signed `Value` (`8/2`, `2*3`, `9%4`, `9-4`, `2**3`, `(2*3)+1`) and `UINT:`
otherwise (a literal, `3+1`, `$clog2(16)`, a cross-package copy); the campaign's
encoder always writes `UINT:` for a nonnegative value. `enum_const::Compare`
never reads `VpiValue`. Shared with `§ genNestedScopePkgParamNoFold24` at HEAD
(measured), and slang's `ConstantValue` cannot reproduce the split — closing it
needs a model of Surelog's `Value::Type` propagation, not a local edit.

**R3 — earl75's R1 and R2, unchanged and untouched:** the gen-scope
`cont_assign` indexed-part-select WIDTH (87 objects, a module-localparam
declaration-typespec registry) and the gen-scope port `High_conn` ips WIDTH (6
objects, a BARE `int_typespec`). Both are visible in this pass's census as the
six non-process `golden ref_obj / ours constant` cells per mode.

**R4 — earl75's R3 and R4 carried forward:** the `--elabuhdm` view's duplicate
DEF+ELAB cells at one key (which is why every arm's elab STILL-WRONG count is
large on both binaries), and `§ procOpFold9`'s two unstamped positions (a whole
Rhs with no operation, and a `$clog2` argument) — the second of which this pass
re-measured in a module-body `repeat` count (`g1_gsfor76.sv` 38:13-38:15: golden
stamps an `int_typespec`, we leave the fold bare, in BOTH homes).

**R5 — carried forward unchanged:** earl74's R2/R3/R4/R5 (R5 is the
allocation-tracking garbage number this pass's boundary re-convicted),
earl72's R2 and R4, earl71's R1/R2, earl69's R1/R5.

---

## 11. Reproduction

```bash
# the censuses (direct .uhdm readers; never uhdm-dump on Earlgrey)
g++ -O2 -std=c++17 cscen76.cpp   -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cscen76
g++ -O2 -std=c++17 ecprobe76.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ecprobe76
g++ -O2 -std=c++17 mvec76.cpp    -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o mvec76

# the corpus head, one binary, one mode
SLANG_UHDM=<abs path> ./earl76.sh <outdir> default|testflags [--nodump]

# question 1
./ecprobe76 <golden.uhdm> WidthMultiple

# question 2 (the corpus census + the region table)
CSCEN76=./cscen76 ./cen76.sh <db.uhdm> <out-prefix>
python3 ./score76.py <g.n> <o.n> <q.n> [detail] [--judged]
python3 ./region76.py <a.n> <b.n>

# an arm: Surelog golden + both frozen binaries, both views, censused
CSCEN76=./cscen76 NORM76=./norm76.sh PRIS=<p> PATCHED=<q> ./arm76.sh g1_gsfor76.sv <outdir>
python3 ./goldtbl76.py <outdir>/g.n <outdir>/o.n <outdir>/q.n NB

# the mover prediction, from PRISTINE databases only
CSCEN76=./cscen76 ./predict76.sh <sweep-workdir> <label>
STAGE2=1 CSCEN76=./cscen76 ./predict76.sh <sweep-workdir> <label> < <stage-1 output>

# the boundaries
PROBE_ROOT=<copy of tools/probe> PATCHED_BIN=<p> PRISTINE_BIN=<q> ./vwide76.sh <file-list> <prefix>
PROBE_ROOT=<copy of tools/probe> PATCHED_BIN=<p> PRISTINE_BIN=<q> ./vdir76.sh  <dir-list>  <prefix>
```

`norm76.sh` is not optional: our databases leave `VpiFile` EMPTY on a folded
constant, everything after `||` is compare-invisible evidence, the object KIND
must stay OUT of the key (or a kind flip splits into two half-cells and hides),
and the dedup is what keeps the listener's per-database visit multiplicity from
manufacturing phantom rows in the `--elabuhdm` view.
