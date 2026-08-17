# r10earl55 — § replFoldTsW1

**Earlgrey_0_1/default's head CLEARED: a ONE-BIT typed parameter's replication
fold does not carry the declared type's bounds — golden hands it the same
LOC-LESS `int_typespec` the UNTYPED fold already gets, and the new head was
PREDICTED IN ADVANCE down to golden's own object id.**

Head: **34 cmp lines → 46**, 1 head → 1 head. (`cmp` LINE COUNT IS HEAD DEPTH,
never a distance: the new head object is deeper, so its listing is longer.)

Corpus effect: **ONE cell to golden, 0 away, 0 reshaped**, DEF view
byte-identical, and 34 grid cells across five arms moving the same way.

---

## THE HEAD (R0 of the pass, cleared)

```
LHS(golden): int_typespec  (no location)  #288957   |UINT:1
RHS(ours)  : logic_typespec (no location) #771001   |vpiRange range [0:0]
```

The head is a typespec with **no `vpiParent` at all** (`KINDP=<root>` on the
ladder), so a parent walk cannot name its owner. `tsown55.cpp` inverts the
database's outgoing-edge table and answers it:

```
int_typespec#288957
  <- Actual_typespec  ref_typespec{work@top_earlgrey.u_dm_top}#289042
  <- Typespec         constant @rv_dm.sv:50:52-50:67 #289041
  <- Rhs              param_assign @rv_dm.sv:50:34-50:67 #289040
                      < module_inst(u_dm_top) @top_earlgrey.sv:312:3-339:5
```

i.e. `hw/ip/rv_dm/rtl/rv_dm.sv:50`, in the ELABORATED listing of `u_dm_top`:

```systemverilog
module rv_dm #(parameter int NrHarts = 1, ...) (...);
  localparam logic [NrHarts-1:0] SelectableHarts = {NrHarts{1'b1}};
```

with `NrHarts = 1` from `rv_dm #(.NrHarts(1)) u_dm_top`. Both sides fold the
replication to the same `constant` (`1'b1`, `vpiSize:1`, `BIN:1`,
`vpiConstType:3`) and both hang the same instance-scoped
`ref_typespec{work@top_earlgrey.u_dm_top}` off it. **The single object that
differs is that ref's actual.**

## THE LAW

> **§ replFoldTsW1 — an ELAB-view `param_assign` whose Rhs is the folded
> REPLICATION of a parameter declared as a PACKED VECTOR exactly ONE BIT WIDE
> carries a LOC-LESS, nameless, range-less `int_typespec` whose `VpiValue` is
> the REPLICATED OPERAND's width — the same object shape the UNTYPED fold
> already gets (§ replFoldTs9) — and NOT the declared type's loc-less
> `logic_typespec` with the folded bounds.**
>
> The operand's width is NOT always 1: `logic [0:0] C = {1{2'b10}}` gets
> `UINT:2` (a5 cell C, measured on both sides).
>
> Fences, each with a measured witness: **module scope only** (in a PACKAGE
> golden's folded Rhs carries NO typespec at all — a5's `pk5_55::PKW1`), and
> **ELAB view only** (the DEF listing keeps the unfolded `operation` with no
> typespec — every DEF row of every arm).

## WHY int_typespec — AND WHAT THE WIDTH-1 RULE IS *NOT*

Four hypotheses were killed by measurement before the code was written. Each
one had a corpus coincidence behind it and each one is wrong:

| hypothesis | killed by |
|---|---|
| "the fold's WIDTH decides (32 and 1 → int, 15 → logic)" | a2 `c2_55`: widths 1, 2, 15 and 32 in ONE instance, golden gives **int for all four** |
| "the DECLARATION ORDER decides (the first in the module wins)" | a2 `c6_55`: the same four widths DESCENDING, golden gives int for all four; a1's 39 top-module cells are all int |
| "a port/signal sharing the written vector type flips it" | a3 `d2_55`/`d3_55`/`d6_55` — golden flips, but a3 `d5_55` shows the flip lands on the param the CONT-ASSIGN reads and NOT on its identically-typed neighbour `E15` |
| "the count's origin (literal vs module param vs package param) decides" | a1 `PG1`/`PG15`/`PG32` and a2 `c3_55` reproduce pinmux's package-parameter shape verbatim and answer differently from pinmux |

What survives every arm is `a4_earl55.sv`, the **full cross product** of 11
consumers × widths {1, 4, 15} — golden's kind, `int` = loc-less int_typespec,
`logic` = loc-less ranged logic_typespec (which is what we emit today):

| how the parameter is CONSUMED in the instance | w=1 | w=4 | w=15 |
|---|---|---|---|
| `c0` not used at all | **int** | int | int |
| `c1` `assign o = X[0];` (the select IS the RHS) | **int** | logic | logic |
| `c2` `assign o = X[0] ^ ext;` (a NON-constant operand) | **int** | int | int |
| `c3` `assign o2 = X;` (the whole param IS the RHS) | **int** | logic | logic |
| `c4` `assign o2 = {X};` | **int** | logic | logic |
| `c5` `if (X[0])` — an IF-GENERATE condition | **int** | logic | logic |
| `c6` `#(.P(X))` — whole param as an override actual | **int** | int | int |
| `c7` `#(.P(X[0]))` — a SELECT as an override actual | **int** | logic | logic |
| `c8` `always_comb o = X[0];` | **int** | int | int |
| `c9` `assign o = |X;` (a constant reduction) | **int** | logic | logic |
| `ca` `always_comb if (X[0])` | **int** | int | int |

Two readings, and only the first is taken here:

1. **At width 1 the answer is `int_typespec` ELEVEN TIMES OUT OF ELEVEN.** The
   consumer does not matter. That is this pass's law, and `a5_earl55.sv` widens
   the width-1 column further — `[3:3]` (a single bit NOT at index 0), `signed`,
   `bit`, `reg`, `[0:0][0:0]`, a nested replication, a replication of a concat,
   and a WIDER replicated operand — **14 more cells, all int, no exception.**
2. At width > 1 the CONSUMER decides, and the split is exactly whether some
   other expression in the instance is REDUCED through the parameter's value: a
   cont-assign RHS that folds whole (`c1`, `c3`, `c4`, `c9`), a generate
   condition (`c5`) and a selected override actual (`c7`) all flip it to the
   declared `logic_typespec`; a cont-assign with a non-constant operand (`c2`),
   a procedural read (`c8`, `ca`), a whole-param override (`c6`) and no use at
   all (`c0`) leave it `int`. **That is a DIFFERENT law and it is NOT
   implemented here** — see R1. It is what our existing `sharedByCa9` /
   `pendingPartSelFoldTs` comment in `ParamEmit.cpp` had already half-seen from
   one probe, and a4 is the first full statement of it.

The corpus agrees with reading 2 without being used to derive it:
`pinmux.sv:176` reads `MioPeriphHasSleepMode` inside a `$bits()'( )` cast
(`int`, unreduced), and `pinmux.sv:108/194` read `DioPeriphHasSleepMode[k]` as a
bare if-generate condition (`logic`).

## THE PATCH

One `if` inside the `replFoldTs` arm of `src/ParamEmit.cpp` (§ replFoldTs, the
typed half of the replication-fold typespec rule), plus its fence:

```cpp
if (rct.kind == SymbolKind::PackedArrayType && rct.isIntegral()) {
    mkRef();
    if (rct.getBitWidth() == 1 && topView && !inPackage) {   // § replFoldTsW1
        auto* itsW1 = s.MakeInt_typespec();
        itsW1->VpiValue("UINT:" + std::to_string(<replicated operand's width>));
        rt->Actual_typespec(itsW1);
    } else {
        auto fr = rct.getFixedRange();                        // unchanged
        pendingPartSelFoldTs.push_back({rt, fr.left, fr.right});
    }
    replFoldTs = true;
}
```

The `!inPackage` half is not decoration: the FIRST build of this law omitted it
and `attrib55.py` immediately flagged `pk5_55::PKW1` as a STILL-WRONG reshape —
golden has NO typespec there, so the int_typespec would have swapped one wrong
answer for another. With the fence that cell is byte-unchanged.

## CENSUS: PREDICTED 1, MOVED 1

`census55.cpp` keys every `param_assign` in the database on
`(view, Lhs VpiFullName, line:col span)` and reports golden's Rhs kind and
typespec SHAPE against ours. The VIEW (`design::AllModules` vs
`design::TopModules`, resolved by set membership, never by name) is part of the
key: the two listings hold param_assigns at the SAME span for the SAME
parameter, so merging them halves the census and hides the earl38 DEF fence.

> **INSTRUMENT CORRECTION, made before any number was believed.** The first
> census keyed on the span WITH the file and reported 13 190 golden cells and
> 13 174 of ours as **all unpaired** — a total failure that reads exactly like
> "there is nothing to compare". Cause: our `param_assign` objects carry an
> EMPTY `VpiFile` where golden's carry the path. `param_assign::Compare` does
> not read `VpiFile`, so `line:col` is the honest key.

**CALIBRATION FIRST, golden vs golden** (a detector that flags everything is a
broken detector, and the campaign's standing law is to run this before reading
any number): `census55 <golden> <golden>` gives
**agree=13 190, disagree=0, unpaired=0/0** on Earlgrey, and 0 disagreements on
all five arms' goldens too (97 / 32 / 18 / 73 / 41 cells). Only then:

Earlgrey_0_1/default, golden vs ours, 10 822 paired cells:

| | predicted | measured |
|---|---:|---:|
| TO-GOLDEN (pristine wrong → patched right) | **1** | **1** |
| AWAY-GOLDEN (pristine right → patched wrong) | 0 | **0** |
| STILL-WRONG (changed, still wrong) | 0 | **0** |
| UNMOVED-GOOD | — | 10 749 |
| UNMOVED-BAD (named residues) | 72 | 72 |

> **THE 2 368 / 2 352 UNPAIRED CELLS ARE NOT MISSING OBJECTS.** They are
> golden-vs-ours **span end-column off-by-one** on imported package parameters in
> the DEF listing (`work@aes.AES_CTRL_OFFSET` golden `203:25-203:48`, ours
> `203:25-203:49`, and 2 300-odd of the same shape), so the census's line:col key
> cannot pair them. Pre-existing, unrelated to this law, and provably untouched
> by it: `attrib55.py` reports **KEY-ONLY-PRISTINE = 0 and KEY-ONLY-PATCHED = 0**,
> i.e. the two binaries produce the SAME key set. They are excluded from the
> table above rather than silently folded into "agree".

The one mover is `ELAB work@top_earlgrey.u_dm_top.SelectableHarts` at
`rv_dm.sv:50:34-50:67`, exactly the cell `CENSUS_PREDICT55.txt` names. It is the
design's ONLY width-1 typed replication fold; the head's own family has two
members and the other one is 32 bits wide (R1).

### The arms, three-way (golden / pristine / patched)

`attrib55.py` joins two `census55 --all` runs so the four outcomes a two-way
diff conflates are separated. **AWAY-GOLDEN is 0 on every arm** — that is the
only regression class, and the campaign has shipped a "gate clean" claim with 22
of them before, which is why it is tallied first.

| arm | UNMOVED-GOOD | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG | UNMOVED-BAD |
|---|---:|---:|---:|---:|---:|
| a1 (17 widths × 6 declared types) | 59 | **8** | **0** | 0 | 30 |
| a2 (instance count / order / overrides) | 21 | **2** | **0** | 0 | 9 |
| a3 (the pinmux split) | 15 | **0** | **0** | 0 | 3 |
| a4 (11 consumers × 3 widths) | 52 | **11** | **0** | 0 | 10 |
| a5 (the width-1 boundary) | 21 | **13** | **0** | 0 | 7 |

34 cells to golden, and every one of them is a width-1 packed-vector
replication fold in a module's ELAB listing.

> **TWO PREDICTION MISSES, both in the same direction (I under-counted my own
> law).** `CENSUS_PREDICT55.txt` names 7 a1 movers and got 8 — it forgot `PG1`,
> the package-parameter-count width-1 cell — and says "a2: no width-1 cell
> exists, so NOTHING moves", which is simply false: `c2_55.W1` and `c6_55.X1`
> are width-1 cells and both moved. The a4 (11) and a5 (13) predictions are
> exact and name every cell. The misses are enumeration errors in the
> prediction, not over-fires of the law: all 10 unpredicted-or-mispredicted
> cells are width-1 folds that landed ON golden.

## THE NEW HEAD WAS PREDICTED (`PREDICT_R0.txt`)

Written before the patched binary was compiled, from an 8-rung pristine ladder
(`lad_pris8.txt`, 8.9 s) — masking rung 1 is how the ladder emulates fixing it:

```
PREDICTED  L ref_obj(PTRV_W) @prim_fifo_sync.sv:70:38-70:44 #291403
           R constant @:70:38-70:44 #235788     KINDP=indexed_part_select
MEASURED   L ref_obj (work@…i_fifo.gen_normal_fifo.PTRV_W) id:291403 70:38-70:44
           R constant id:235789  UINT:1 sz32  ts -> int_typespec@55:16-55:28
```

Golden's object id is exact (**291403**), the kinds, the span, the parent kind
and the mechanism are exact. **Ours is #235789, not the predicted #235788** —
the patched database renumbers by one object at that point, so an id predicted
from the PRISTINE side is right only on the golden side. Recorded because the
next pass will predict ids the same way.

R0 of pass 56 is an **OVER-FOLD, not a typespec**: golden keeps the parameter
reference `PTRV_W` inside an `indexed_part_select`'s bound and we hand back a
constant. It is the direction-reversed member of the family earl54 measured at
2 036 pristine rungs.

## RESIDUES (measured, named, NOT fixed)

* **R1 — the width > 1 consumer law.** `u_pinmux.MioPeriphHasSleepMode` (32
  bits) still has our `logic_typespec` where golden has `int_typespec`; a4's
  10 UNMOVED-BAD cells are the same shape. Fixing it needs "is this parameter
  read by a REDUCED expression in this instance", which is a real analysis and a
  separate law — a4 is its specification.
* **R2 — a LOCATED int_typespec where golden's is loc-less.**
  `u_usbdev.AVFifoWidth` and `u_usbdev.u_memory_2p.LocalDataBitsPerMask`:
  `localparam int X = <fold>` gives us `int_typespec@83:14-83:17` (the `int`
  keyword) and golden nothing. a1's `IT32` adds that golden's is also carrying
  `VpiValue`, which we omit — cmp-invisible (`int_typespec::Compare` reads
  VpiType/VpiName/VpiDefName/Typedef_alias/Instance/Cast_to_expr/VpiSigned/
  Ranges, never VpiValue) but dump-visible. Deliberately left alone: it is a
  different branch of the same `if`, and moving it would put dump-column churn
  on every `int`-declared fold in the corpus for zero cmp gain.
* **R3 — we over-fold two flash_ctrl params.**
  `u_flash_erase_ctrl.{Page,Bank}AddrMask`: golden keeps an `operation`, we
  fold a constant. Pristine == patched.
* **R4 — `u_pwrmgr.i_cdc.i_ast_sync.ResetValue`**: golden's typespec is the
  named `struct_typespec` from `pwrmgr_pkg.sv:31`, ours a `bit_typespec` at the
  declaration. Pristine == patched.
* **R5 — a SCALAR `logic` (no range at all) wants the same int_typespec.**
  a5 `u_e3.G` (`localparam logic G = {1{1'b1}}`): golden loc-less
  `int_typespec UINT:1`, ours a LOCATED `logic_typespec@45:14-45:19`. It is a
  `ScalarType`, not a `PackedArrayType`, so it never reaches this arm — a
  different code path, left alone on purpose.
* **R6 — a GEN-SCOPE width-1 fold** (a5 `u_e5.gen_b[0..1].J`) keeps a LOCATED
  `logic_typespec@59:16-59:27` on our side where golden is loc-less `int`. The
  generate-scope parameter path does not go through this arm either.
* **R7 — a package-param REFERENCE initializer** (a5 `u_e6.K`,
  `localparam logic [0:0] K = pk5_55::PKW1`) has the same golden shape without
  being a replication at all, so this law correctly abstains.
* **R8 — a package's own width-1 fold** (a5 `pk5_55::PKW1`): golden's constant
  carries NO typespec, ours carries one. The `!inPackage` fence keeps it exactly
  as pristine.

## FILES

| file | what it is |
|---|---|
| `census55.cpp` | the param_assign typespec census, keyed on (view, Lhs fullname, line:col); the DUPKEY report and the view resolution are guards, not decoration |
| `tsown55.cpp` | the OWNER probe: inverts the outgoing-edge table so a loc-less, parent-less typespec can be traced to the object that points at it |
| `attrib55.py` | three-way pristine→patched attribution joined against golden; AWAY-GOLDEN is the number that must be 0 |
| `a1_earl55.sv` | 17 widths × 6 declared types + the pinmux package shape + port-list vs body params |
| `a2_earl55.sv` | instance count, declaration order, parameter overrides, ascending vs descending widths |
| `a3_earl55.sv` | the pinmux split: does another declaration of the same vector type change the answer |
| `a4_earl55.sv` | **the cross product**: 11 consumers × widths 1/4/15 — the table this law is read off |
| `a5_earl55.sv` | the width-1 boundary: `[3:3]`, signed, bit/reg, `[0:0][0:0]`, scalar, nested, wider operand, gen-scope, package |
| `arm55.sh` | arm driver, `-elabuhdm`/`--elabuhdm` on BOTH sides |
| `armplain55.sh` | the same arm with NEITHER flag, so the plain view is measured and not assumed |
| `earl55.sh` | the Earlgrey_0_1/default driver (golden from the immutable cache) |
| `CENSUS_PREDICT55.txt` | written before the patched binary existed |
| `PREDICT_R0.txt` | the new head, predicted before the patched binary existed |
| `sweeps55.sh` `ct8rows.sh` `byteverify55.sh` `canaries.sh` `canaudit.sh` `ctcan2.sh` `rowheads.sh` `varm.sh` `vbndall55.sh` `ladcmp55.py` | carried-forward harness |

> `plainreg55.py` was carried in from earl54 and then **REMOVED**: it
> `import census54`, a module that does not exist in this directory, so it could
> not run here. A carried guard that cannot execute is the campaign's "cited
> guard that does not exist" trap. `attrib55.py` + `armplain55.sh` do its job
> from the DATABASE rather than the dump text, and the plain-view table above is
> their output.

## GATE RESULTS (all five, exact numbers)

| gate | measurement | result |
|---|---|---|
| 1 build | both binaries, `-j 2`, md5 separately | pristine `31c3ca8d3b0217397b1d925162a844ce`, patched `5f0218adf3aabac37de8a320308642fe` |
| 2 goldens | `tests/check_goldens.sh` | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (the negative control) |
| 3 u2r | `ct8rows.sh`, baseline FIRST | testflags: baseline vs pristine **0** differing rows, baseline vs patched **0**, pristine vs patched **0**. default: pristine vs patched **0** (see the mode note below). Status **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** unchanged in both modes and both binaries; dump histograms identical (default 492 match / 187 differ / 52 blank, testflags 496 / 183 / 52) |
| 4 surelog | both modes concatenated, 1588 rows | baseline vs patched **0 differing rows**, baseline vs pristine **0**, pristine vs patched **0**. `PASS: every row byte-identical to the committed baseline` |
| 5 byteverify | `SELFCHECK=1 SELFCHECK1=1` | u2r 1358 paths **0 movers**; surelog 953 paths **1 mover** = `./default/Earlgrey_0_1-71da2fd7/slang.uhdm` (patched `5d2a9c1182c5`, pristine `29794f8bda09`). Controls: SELFCHECK 1357/1358 and 952/953 flagged; SELFCHECK1 = 1 and 2 |

`Earlgrey_0_1/testflags` is `SLANG_REJECT` and has no database, which is why the
surelog mover count is 1 and not 2.

> **GATE 3'S MODE NOTE, and it is a real instrument fact, not an excuse.**
> `results/gate_uhdm2rtlil.csv` is a **testflags-only** baseline (731 rows, every
> row `mode=testflags`). Comparing it against a DEFAULT-mode CSV reports **1462
> differing rows** — every row on both sides — because the mode column differs
> on all of them. That reading appears identically for the PRISTINE binary, which
> is what identifies it as a mode mismatch rather than a regression. The
> default mode's gate is therefore pristine-vs-patched (0 rows) plus the status
> and dump histograms above; there is no committed default-mode u2r baseline to
> diff against.

> **A STALE-CSV TRAP, caught and NOT reported as a win.** Diffing this pass's
> patched surelog CSV against `r10earl54`'s left-over
> `/tmp/r10earl54_csv/surelog_default_pat.csv` showed
> `YosysVerx,default CMP_NOTEQUAL -> CMP_EQUAL` with the dump going
> `differ -> match` — a row CONVERSION, which this pass would love to claim.
> It is not this pass's. Running YosysVerx directly on both binaries gives
> **PASS_CMP on BOTH**, this pass's own pristine sweep agrees, and the COMMITTED
> baseline already records `YosysVerx,default,CMP_EQUAL,,,match`: the conversion
> landed in commit `039295a`, which `git merge-base --is-ancestor` confirms is an
> ancestor of this pass's base `8477b5d`. earl54's CSV was produced by a binary
> whose base predates that merge. **Never diff against another pass's CSV** —
> the committed baseline and this pass's own pristine sweep are the only two
> honest references, and the campaign has already burned a session on exactly
> this ("+98 aliases from a null edit" was the same mistake).

**Canaries**: `canaries.sh` **52 rows OK / 0 changed / 0 absent** on the surelog
CSV and **8/0/0** on the u2r CSV; `ctcan2.sh` **58/0/0** (surelog,
`EXPECT_UNKNOWN=1`) and **1/0/0** (u2r, `EXPECT_UNKNOWN=6`); `canaudit.sh`
`audited=29 UNCOVERED=0 FENCE-BREACH=0` with UnsignedParam, HierPathEval,
FileLocalParam and TopParam dispatched by no driver here. The two DATABASE PINS
hold byte-exactly on BOTH binaries and BOTH modes: **SVSwitch `4842211c4030`**,
**YosysVerx `6ccda350c24a`**. `InterfaceModPort`, `BlackParrotComplex` and
`YosysOldOr` are byte-identical between the binaries (gate 5 lists every mover
and none of them appears).

**Wide boundary** (`vbndall55.sh`): 812 arms x 2 views = **1624 runs, 1596
identical, DIFFERING = 8** — and all eight are `a1_earl55.sv`, `a2_earl55.sv`,
`a4_earl55.sv` and `a5_earl55.sv`, this pass's own grid arms, in both views.
**`a3_earl55.sv` does NOT differ**, which is the correct answer: a3 contains no
width-1 cell, and the census predicted zero movers there. Nothing else in the
entire probe corpus moved. Signals are symmetric — `r10uvm67repro/c3_iface.sv`
and `v3_boundary.sv` segfault (rc=139) on BOTH binaries in BOTH views,
4 patched / 4 pristine, pre-existing (earl54 measured the same pair).

**THE PATCH REBUILDS TO THE SAME BINARY FROM A FRESH BASE.** `git worktree add`
on a clean `8477b5d`, `git apply --check` clean, `git apply`, configure and
`cmake --build -j 2` → **md5 `5f0218adf3aabac37de8a320308642fe`, byte-identical
to the binary every gate above was run with.** So the deliverable is not
"the patch that happens to be in my worktree": it is the patch that reproduces
the measured binary.

**Determinism**: the patched Earlgrey database re-runs to the same md5
(`5d2a9c1182c5bb8a45df726d56a4e0c8`, matching gate 5's mover), so the 46-line
head is not a coin. The pristine database is byte-identical to `r10earl54`'s
landed patched database (md5 `29794f8bda09`), which is how this pass knows its
base is the committed state and not a rebuild artifact.

**DEF view on the ARMS**: the `uhdmallModules` subtree of every arm's dump is
byte-identical between the two binaries once the WORKDIR PATH is normalised —
a1 2 070 lines `d61b696f05a8`, a2 1 157 `0834039f3d3d`, a3 1 105 `04d23af7eb1b`,
a4 5 835 `e51ec8e5e8af`, a5 1 940 `cd161fc26afb`. The normalisation is not
cosmetic: the first run of this check reported DIFFERS on all five arms
INCLUDING a3, which has no mover at all — because **dump paths embed the
workdir** and the two sides run in different directories. A fence check that
cannot tell a path from a defect proves nothing.

**DEF view on Earlgrey**: the `uhdmallModules` subtree, **1 046 523 lines,
md5 `3694eca02c308c3419cb5ae30405f505` on BOTH binaries** — byte-identical, and
the same md5 earl54 recorded. The earl38 fence holds.

### BOTH VIEWS, and the numbers are the SAME

`arm55.sh` runs Surelog and us with `-elabuhdm`/`--elabuhdm`; `armplain55.sh`
runs both with NEITHER. earl54's integration note is why this matters: the
discriminator for these laws is **`module_inst` vs `ref_module`**, not elaborated
vs plain, and our output carries BOTH listings either way — so `topView` in the
patch means "the module_inst listing", not "the CLI flag". Measured against a
freshly built PLAIN golden:

| arm | plain TO-GOLDEN | plain AWAY-GOLDEN | plain STILL-WRONG | (elab TO-GOLDEN) |
|---|---:|---:|---:|---:|
| a1 | **8** | **0** | 0 | 8 |
| a2 | **2** | **0** | 0 | 2 |
| a3 | **0** | **0** | 0 | 0 |
| a4 | **11** | **0** | 0 | 11 |
| a5 | **13** | **0** | 0 | 13 |

Cell for cell identical to the elaborated view, and AWAY-GOLDEN = 0 in both.
`KEY-ONLY-PRISTINE = KEY-ONLY-PATCHED = 0` on all ten runs, so no cell appeared
or vanished.

### The arms' own cmp heads

| arm | pristine | patched | what the head is |
|---|---|---|---|
| a1 | 34 / 1 | 34 / 1 | the SAME shape at width **2** (`logic_typespec` range [1:0]) — **R1**, not this law |
| a2 | 34 / 1 | 34 / 1 | ditto, width 2 — R1 |
| a3 | 52 / 1 | 52 / 1 | a3 has no width-1 cell at all |
| a4 | 34 / 1 | **52 / 1** | **ADVANCED**: a4's head WAS a width-1 typespec (`int_typespec#865` vs `logic_typespec#2477`) and is now a `constant` under a `cont_assign` |
| a5 | 78 / 1 | 78 / 1 | the PACKAGE fold `pk5_55::PKW1` (golden keeps an `operation`) — R8, fenced out on purpose |

Three arms' heads sit on the width > 1 half of a4's table or on the package
fence, which is why they do not move: this pass took the width-1 clause only,
and the arms say so out loud rather than the pass claiming a cleared probe.

## THE WHOLE-DESIGN BLAST RADIUS: 19 LINES

A `diff` of the two Earlgrey dumps — 4 701 635 lines pristine, 4 701 626 patched —
is **three hunks, nineteen lines**, and every line is named by the law:

```
1515125c1515125            <- the head: the ref_typespec's actual
<           \_logic_typespec:
>           \_int_typespec:
4034328a4034329,4034330    <- the new object, with its operand-width value
> \_int_typespec:
>   |UINT:1
4700705,4700715d4700706    <- the old object AND its whole range subtree, gone
< \_logic_typespec:
<   |vpiRange:  \_range:  |vpiParent: \_logic_typespec:
<   |vpiLeftRange:  \_constant: |UINT:0
<   |vpiRightRange: \_constant: |UINT:0
```

+2 / -11 = the 9-line net. Nothing else in the design moved, which is the same
fact gate 5 states as "1 mover in 2 311 databases" and the census states as
"TO-GOLDEN 1, AWAY 0".

## HOW THE HEAD WAS MEASURED

Via the official driver on the SWEEP databases, not a side run
(`rowheads.sh <workdir> <out> <names...>`, `LHS` always golden,
heads counted with `grep -c '^LHS:'` anchored at column 0):

```
pristine  Earlgrey_0_1 default   34 lines   1 head   cmp rc=255
patched   Earlgrey_0_1 default   46 lines   1 head   cmp rc=255
```

and on the same run every canary row reads `0 lines / 0 heads / rc=0` on BOTH
binaries: YosysVerx, SVSwitch, BlackParrotComplex, InterfaceModPort, YosysOldOr,
each in both modes. `Earlgrey_0_1/testflags` prints `SKIP-NOFILE` — it is
`SLANG_REJECT` and has no database, and the driver COUNTS that rather than
letting it read as a pass.

## LADDER: ONE matched-budget pair, run ALONE (`LADDER55.md`)

Both runs `--max=20000 --budget=1500`, back-to-back, nothing else on the machine
(the budget is WALL CLOCK — a concurrent job makes the patched walk look
shallower and the comparison worthless), joined by `ladcmp55.py` on the GOLDEN
SITE including its `#UhdmId`, never the rung index.

| | rungs | stop | secs | maxvis |
|---|---:|---|---:|---|
| pristine | 3 424 | BUDGET | 1500.6 | 632 269 / 783 183 |
| patched | 3 442 | BUDGET | 1500.2 | 632 907 / 783 183 |

```
CLEARED = 1   int_typespec|VpiType|KIND:int_typespec>logic_typespec
              rung 1  int_typespec@:0:0-0:0#288957
NEW     = 19
KEPT    = 3380
```

**The prediction, written before the patched run, was that CLEARED = 1 and that
the family would go 2 → 1, not 0** — because the pristine ladder carries exactly
two rungs in it and `tsown55` had already resolved the second one to
`u_pinmux` / `pinmux.sv:54` (R1, 32 bits). Measured: the head object #288957 is
gone from the patched ladder (0 occurrences), #595640 is still there, and the
family count is 1. A "family cleared" claim would have been wrong by one rung.

**The 19 NEW rungs are NOT new defects**, and this is checked rather than
asserted: all six of their families are families the PRISTINE ladder already
carries (`tagged_pattern>hier_path` 249, `int_typespec>integer_typespec` 455,
`ref_obj>constant` 120, `constant|VpiDecompile|TEXT:#'b#|#` 28, the
`a_source[IDW - #-:#]` hier_path 16, `tagged_pattern>ref_obj` 31), and 18 of the
19 sit in `tlul_socket_m1.sv`, which the pristine budget stopped just short of.
One fewer mask buys ~640 more proven-equal objects in the same 1 500 s.

`ladcmp55.py` also prints earl54's family as a control: `constant>operation`
**pristine 7 / patched 7**, `tlul_fifo_sync.sv:76:69-76:91` **0 / 0** — earl54's
44 → 7 is exactly where earl54 left it.

## WHAT THIS PASS DELIBERATELY DID NOT DO

The a4 table specifies a SECOND law (the consumer rule at width > 1) that would
take Earlgrey's remaining `int_typespec` cell (`u_pinmux.MioPeriphHasSleepMode`)
and 10 of the a4 residues. It is not implemented, and the reason is the earl52-F2
ranking rather than caution: implementing it requires deciding, per parameter and
per instance, whether some OTHER expression in that instance is REDUCED through
this parameter's value — a cont-assign RHS that folds whole, a generate
condition, a selected override actual — and the two corpus witnesses are on
OPPOSITE sides of the line for reasons this pass measured but did not model (the
`$bits()'( )` cast at `pinmux.sv:176` does NOT count as a reducing read, and the
bare `DioPeriphHasSleepMode[k]` generate condition at `pinmux.sv:108` does). A
law that got that wrong would turn 4 currently-CORRECT cells (a4 `c1`/`c3`/`c4`/
`c9` at widths 4 and 15, plus `c5`/`c7`) into wrong ones — AWAY-GOLDEN, the one
class this campaign treats as a regression. The width-1 clause has no such risk:
25 grid cells at width 1 with zero counterexamples, and 34 cells moved with
AWAY-GOLDEN = 0 everywhere.

Also NOT taken, and each is a one-line change in the same `if` chain that a
future pass should measure rather than assume:

* the `PredefinedIntegerType` arm (`localparam int X = {32{1'b1}}`) mints a bare
  `int_typespec` with NO `VpiValue`, where golden carries the operand width
  (a1 `IT32`). It is cmp-INVISIBLE and dump-VISIBLE, so it would put dump-column
  churn on every `int`-declared fold in the corpus for zero cmp gain — the gates
  would then have to name each moved row.
* the SCALAR `logic` and GEN-SCOPE paths (R5, R6) reach the same golden shape
  through different code and are not in this arm at all.
