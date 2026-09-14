# r11u26 — the leftover of a WHOLE READ of a PATTERN parameter is that
# parameter's own elaborated Rhs operation, and the read FLATTENS it

Base `822420d0` (matrix-1.87).  Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.
ONE producer call decoded (`ExprEval::getValue`), TWO halves implemented, ONE
exception carved in the module assembler's bail.  The judge is the official
`uhdm-cmp` through `scripts/verify_golden.py`; everything in this directory is
measurement-only and `results/*.csv` IS NOT EDITED BY THIS PASS.

**ZERO tests convert, and that is the honest prediction, not a disappointment:
NO ROW OF EITHER CORPUS CARRIES THIS FACE.**  §4's a-priori detectors read all
1608 pristine u2r databases and all 960 pristine surelog databases, flag a
named set, and every flagged name is decoded and measured NOT to move; the
sweeps then measure **u2r MOVERS 0 / 1608** and the surelog coin family alone.
What the pass buys is the r11u24 landing's R0 head and seven more like it:
**EIGHT grid arms go from 1 head to CMP_EQUAL**, among them `m1` — which is
r11u24's control arm `n12` VERBATIM — and `m2`, which is r11u24 `n3`'s
remaining head object for object.

---

## 1. The head, RE-MEASURED at this base

Measured on this pass's own pristine build (md5
`66dc9cdb3437a4d220daef493a145fdd` — BYTE-IDENTICAL to the main tree at
`822420d0`, the value the brief pins), official `uhdm-cmp`, LHS always golden,
ONE head per run (`grep -c '^LHS:'` on **stderr**).

`m1` = r11u24 `n12`: `package pk; localparam in_t UU = '{a: 11, b: 22};
function automatic c_t mk(); c_t c; c.u = UU; c.d = 64; return c; endfunction;
localparam c_t C = mk();` with `in_t = {int unsigned a; int unsigned b;}` and
`c_t = {in_t u; int unsigned d;}`.

| side | object |
|---|---|
| golden (LHS) | the `typespec_member` `pk::c_t.u`'s **`Actual_value`** — an **`operation`**, `vpiOpType:75` (`vpiAssignmentPatternOp`), two `constant` operands `UINT:11`/`UINT:22` both `vpiSize:32`, a `ref_typespec` -> `struct_typespec pk::in_t`, spanned at `9:24-9:39` (the `'{a: 11, b: 22}` literal) |
| ours (RHS) | a `constant`, `UINT:47244640278` `vpiSize:64` — the 64-bit value slice `11<<32 \| 22`, re-encoded |

1 head / 36 cmp lines, both modes, identical on the two binaries at the base.

### THE SHARE, PROVED BY IDS — and it is a CLONE, not a share

The brief's caution is real: uhdm-dump ELIDES a repeated subtree, so dump text
cannot tell a share from a copy.  `idcen26.cpp` reads the databases through the
UHDM API and interns object POINTERS, printing every `param_assign` Rhs (`PA`)
and every `typespec_member::Actual_value` (`TM`) with its identity, payload and
`vpiParent`.  On grid `m12` (§2, the arm that isolates the leftover from the
flatten), golden's own database says:

```
PA topPkg pk.UU      rhs#9  operation op=75 operands=constant#10,constant#11 ts#12(pk::in_t) parent#13
TM topPkg pk::c_t.u  val#17 operation op=75 operands=constant#18,constant#19 ts#20(pk::in_t) parent#13
```

`#17 != #9` and `#18,#19 != #10,#11`: golden **CLONES**.  What proves the
provenance is `parent#13` — *both* objects carry `UU`'s own `param_assign` as
`vpiParent`, because the clone is made by `reduceExpr` off that Rhs and keeps
its parent pointer.  So the pass clones too (OPS: never share unless golden's
ids prove golden shares — here they prove the opposite).  No generated
`Compare` reads `VpiParent`, so the distinction is invisible to the judge and
this is a hygiene choice, not a correctness one.

---

## 2. § patParamLeftoverShare26 / § patParamEvalFuncRead26 — the producer

One call chain, read from source, UHDM v1.87 `templates/ExprEval.cpp`:

```
:5319  setValueInInstance      rhsexp = reduceExpr(rhsexp, …)
:4809  reduceExpr, ref_obj arm     if (any *tmp = getValue(name, inst, pexpr, …))
:307   getValue                        result = (any *)p->Rhs();     // THE OBJECT
:342   getValue, still                 flattenPatternAssignments(s, rt->Actual_typespec(), result)
                                       …and the flattened operands are written
                                       BACK INTO result — the parameter's own Rhs
:372   getValue, last                  result = reduceExpr(result, …)   // the CLONE
:5671  setValueInInstance      ((typespec_member *)object)->Actual_value(rhsexp);
```

Two facts fall out of it, and this pass implements both.

**(A) THE LEFTOVER.**  `getValue` hands back the parameter's `param_assign`
Rhs OBJECT whatever its kind.  An assignment-pattern operation does not reduce
to a constant, so the member's leftover is an OPERATION.  Our drain's
`paramRead` arm looked the read parameter up in `elabParamConst`, **and that
registry only ever registers constants** — so a pattern parameter missed it
entirely and the value-slice fallback minted a UINT of the parameter's width.
The fix is one fallback: `elabParamRhsObj6` (the elaborated, physical-view Rhs
of every parameter, already recorded at the param site) cloned by
`memLeftPatParamClone26`.

**(B) THE FLATTEN.**  `:342` runs `flattenPatternAssignments` IN PLACE and
writes the result's operands back into `result`, which IS the parameter's own
elaborated `param_assign` Rhs.  So a by-name read does not merely produce a
leftover — it REWRITES the parameter's own elaborated listing, tagged_pattern
wrappers gone.  Our emitter already models two triggers for that rewrite
(`hasScopedPkgRef` and `hasMemberSelectOf`, `TypeEmit.cpp:7763` / `:7870`);
evaluating a const-function builder during elaboration is a THIRD, and it was
missing.  Three arms that differ only in who reads `pk::UU` decide it:

| arm | the only reader | golden | pristine |
|---|---|---|---|
| `m10` | NOBODY | tagged_pattern tree, no ts | **the same** |
| `m11` | `localparam AA = UU.a` | FLAT constants + ts | **the same** (member-select rule) |
| `m1` | only the builder's `c.u = UU` | **FLAT constants + ts** | **tagged tree** |
| `m14` | the same body, in a function NO parameter calls | tagged tree | the same |

`m14` is the negative control: the predicate (`evalFuncWholeReads26`) asks
`memLeftInitCall` / `srlgEvalFuncMemberLeftovers`, so a body nothing evaluates
is never a trigger — a rule fired off the SYNTAX of the body would flatten
here and be wrong.

**RANK.**  The new trigger sits exactly where the member-select rule sits: it
OUTRANKS the WIDTH rule (`m13`, a 128-bit `w_t` pattern parameter — golden
flattens it anyway) and, like the member select, it yields to the SYMBOLIC-DIM
rule, for the producer's own reason: `:342`'s flatten is gated on
`op->Typespec()` and Surelog leaves a symbolic-dim pattern op untyped.

**AND IT IS STRUCTURED-PATTERN ONLY.**  The same gate refuses a SIMPLE
positional pattern.  Grid `m3`'s `localparam in_t SPAT = '{33, 44}` is already
flat and UNTYPED in golden and in our pristine binary, object for object;
running the flat walk over it MINTED a typespec golden does not have.  That was
measured as an AWAY-GOLDEN move on the first build of this law and is why the
gate reads `k0 == StructuredAssignmentPattern`.  `k0` is the RESOLVED pattern
kind, so a CHAINED parameter (`localparam in_t CHN = PAT;`) still flattens and
still carries its leftover — `m3` moves 15 cells to golden on that account.

**(C) THE MODULE ASSEMBLER'S BAIL.**  `§ modStructFuncAssembleBin` required
EVERY member value to be a `constant` before swapping the assembled BIN in.
The producer's `assemble()` (`ExprEval.cpp:4846`) reduces each member value and
an assignment pattern of constants reduces — the PACKAGE arm's own `asmOk`
already says so.  Grid `m4` is the module-holder witness: `work@dut.L`'s `u`
leftover is the pattern operation and golden STILL assembles the same 96-bit
BIN the package-held `m1` gives.  The bail is widened for the operations THIS
law installed and nothing else (`SrlgMemLeftStamp::patOpVal`), so the two
witnesses that built it keep it: a `vpiLogAndOp` leftover
(StructParamFuncBodyFieldCompare) and a null one (FuncStructVal) are neither a
constant nor law-installed.

### THE GOLDEN GRID (Surelog v1.87, one arm per directory, EVERY rc recorded)

`grid.sh` runs `surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`,
then both frozen binaries, then the official `uhdm-cmp`.  **Every arm below
compiled `slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.**

| arm | shape | golden, and what it decides | head |
|---|---|---|---|
| `m1` | **r11u24 `n12` VERBATIM** — package holder, `c.u = UU` | leftover = UU's flattened pattern operation; UU's own elab Rhs flattened by the read | 1/36 -> **0, CMP_EQUAL** |
| `m2` | **r11u24 `n3` VERBATIM** — mixed whole+nested writes, both orders | `mkWN` -> `u` <- 3 (nested wins, r11u24's law); `mkNW` -> `un` <- UU's OPERATION | 1/36 -> **0, CMP_EQUAL** |
| `m3` | RHS PARAMETER KINDS, one member each: structured pattern / SIMPLE pattern / CHAINED ref / computed-element pattern / folded scalar | every kind but the simple pattern flattens AND leaves an operation; the scalar keeps the landed constant arm; SPAT stays untyped | 1/36 -> 1/18 (R2) |
| `m4` | THE MODULE HOLDER — builder, pattern parameter and localparam all in `module dut` | identical answer to `m1`'s package holder, AND the module assembly still runs | 1/31 -> **0, CMP_EQUAL** |
| `m5` | THE READERS — whole sub-struct, nested slices, bit select, taint, an override actual, a port width | every param cell but one moves to golden; `.W(pk::C.u.b)` stays on the `<w>'b` encoding road | 1/36 -> 1/32 (R3) |
| `m6` | TWO builders, TWO struct typedefs, BOTH reading the SAME `UU` | both members carry their own clone of the same operation | 1/36 -> **0, CMP_EQUAL** |
| `m7` | CROSS-SCOPE — pattern parameter in the package, builder and holder in the module, read as `pk::UU` | the landed SCOPED-REFERENCE rule already flattened it; only the leftover was missing | 1/36 -> **0, CMP_EQUAL** |
| `m8` | NESTED write from a pattern parameter (`c.u.v = UU`), both orders | r11u24's nested stamp puts UU's operation on the FIRST-LEVEL member; the ASSEMBLY then renders it `mw/n` (R1) | 1/36 -> 1/32 (R1) |
| `m9` | THE OTHER NON-CONSTANT RHS KINDS — concat / replication / enum-element pattern / arithmetic | only the pattern is this law's; golden's concat and replication leftovers are BIN constants (R4) | 1/13 -> 1/13, 4 cells TO golden |
| `m10` | THE FLATTEN CONTROL, NO READER | tagged tree, no typespec | 0/0 **IDENTICAL** |
| `m11` | THE FLATTEN CONTROL, a plain `localparam AA = UU.a` reader | flat + ts on both binaries; the head is `VV = UU`, a chained pattern parameter with no builder (R5) | 1/60 **IDENTICAL** |
| `m12` | `m1` PLUS one member-selecting read of `UU`, so the PRISTINE binary already flattens | the ONLY judge-visible difference left is the leftover itself — the isolating arm, and the share proof's home | 1/36 -> **0, CMP_EQUAL** |
| `m13` | THE WIDTH RULE — a 128-bit `w_t` pattern parameter read whole | golden flattens it anyway: the new trigger OUTRANKS the width rule | 1/36 -> **0, CMP_EQUAL** |
| `m14` | THE NEGATIVE CONTROL — the same body in a function NO parameter calls | tagged tree; never evaluated | 0/0 **IDENTICAL** |
| `m15` | the ENUM-element pattern parameter, alone | the leftover is the operation, enum elements and all | 1/36 -> **0, CMP_EQUAL** |
| `m16` | a CONCAT-valued parameter read whole, alone | golden REDUCES it: the leftover is a BIN constant, not an operation.  This law declines the shape outright | 1/13 **IDENTICAL** |
| `n10` | r11u24's FLAT CONTROL — two builders, one struct typespec | r11u24 R1, untouched | 1/14 **IDENTICAL** |
| `n11` | r11u24's FLAT CONTROL — `$root` typedef | CMP_EQUAL | 0/0 **IDENTICAL** |

`m10`, `m11`, `m14`, `m16`, `n10`, `n11` are the CONTROLS: six arms that must
stay byte-identical on the two binaries, and do.

---

## 3. Where it is implemented

Three edits, `src/ParamEmit.cpp` + `include/UhdmExporter.h`, 319 diff lines of
production surface and nothing outside ParamEmit's leftover machinery:

* **`memLeftPatParamClone26`** — clones an elaborated `vpiAssignmentPatternOp`
  whose operands are all plain constants, copying every field a generated
  `Compare` reads (`VpiOpType`/`VpiReordered`/`VpiFlattened`/`VpiOpStrong`/
  `Operands` for the operation, `VpiDecompile`/`VpiSize`/`Typespec` for the
  expr, and the operands' values, sizes and const types), plus the source's
  `vpiParent` and spans so the dump reads like golden's.  It **DECLINES** any
  other shape: a still-tagged pattern (the parameter's own listing never ran
  the flatten), a concat (`m16`), a replication, a `ref_obj`.  A decline writes
  nothing and the database stays byte-identical.
* **the drain's `paramRead` fallback** — reached only when `elabParamConst`
  misses, i.e. only for a read parameter that did NOT fold to a constant.
  Every landed resolution above it (`litRhs`, `argWholeParam`, the
  constant-valued `paramRead`, `catRhs`) is untouched, which is why the FLAT
  family's own arms are byte for byte what they were.
* **`evalFuncWholeReads26`** — the third flatten trigger, scoped to ONE scope's
  own parameters (where the producer's instance walk lands) and gated on
  `structPat && inPackage && !symbolicMemberDim && k0 == Structured`.
* **`SrlgMemLeftStamp::patOpVal`** — the module assembler's bail exception,
  narrow to this law's own objects.

The landed family laws are read-only inputs here: the stamp drain, the bail
rules, the encodings, the member-slice fold, the assemble arms' own logic and
the r11u24 nested stamp are all untouched.

---

## 4. The mover set, PREDICTED BY NAME BEFORE ANY PATCHED CORPUS DATABASE EXISTED

Every edit hangs off ONE recorded fact — the recognizer's
`SrlgMemLeft::paramRead`, set when a builder body writes a member from a WHOLE
READ OF A NAME that resolves to a `Parameter`.  No `paramRead`, no clone, no
flatten trigger, no bail exception.

**L1 (`predL1_26.py`, SOURCE-keyed, a deliberate superset):** every test
directory with `<local>.<member>… = <identifier>;` inside a `function` body.
u2r: **7 of 876** (`OneThis`, `cva6_equiv`, `ibex`,
`param_nested_struct_field_width`, `rp32`, `struct_param_field_shift`,
`struct_param_func_config`).  Surelog: **7 of 699** (`ClassCons`,
`ClassMemberRef`, `DollarRoot`, `FuncStructVal`, `PackageVar`, `SplitFile`,
`ThisHier`).

**L2 (`predL2_26.py`, PRISTINE-DATABASE-keyed).**  The same face read off the
emitted dump: a `function`/`task` body holding an `assignment` whose LHS is a
`hier_path` and whose RHS is a bare `ref_obj`.  It does NOT check that the read
name is a parameter, nor that the function returns a packed struct, nor that a
parameter calls it — a deliberate superset, so a zero from it is a reading and
not a silence.

* **u2r: 22 databases = 11 test names x 2 modes.  All 1608 databases read, 0
  errors, nothing skipped.**  `param_nested_struct_field_width`,
  `pkg_nested_struct_param_width`, `struct_param_func_config`,
  `struct_param_field_shift`, `portsel_struct_param`, `jeras_union`,
  `rp32_r5p_alu`, `rp32_r5p_bru`, `rp32_r5p_mdu`, `rp32_r5p_wbu`, `OneThis`.
* **surelog: 15 databases = 8 test names.  All 960 of OUR databases read, 0
  errors.**  `MiniAmiq`, `SeqDriver`, `SimpleUVM`, `BuildUVMPkg`, `SVSwitch`,
  `ApbSlave` and `Scoreboard`/default are CLASS or constructor writes
  (`this.name`, `this.drvr2sb`, `__m_uvm_status_container.comparer`,
  `_knobs.indent`) inside a task/function body — never a packed-struct-returning
  function whose result initializes a parameter, so the return-type gate
  (`rt.kind != SymbolKind::PackedStructType`) rejects every one.
  `FuncStructVal`'s `cfg.DCACHE_INDEX_WIDTH <- build_config_pkg::build_config::
  DCACHE_INDEX_WIDTH` reads a LOCAL VARIABLE of the function body
  (`dut.sv:493`, `int unsigned DCACHE_INDEX_WIDTH = $clog2(…)`), not a
  parameter: `ml.paramRead` only fires for `SymbolKind::Parameter`, so the
  member keeps the value-slice encoding it has today.
  The walk also met THREE golden-side `slpp_all/surelog.uhdm` artifacts left in
  the workdir (`YosysOpenSparc`/default and `TestBatchMode`'s two class dirs).
  Our binary never writes those files, so none can be a mover; the detector
  NAMES and COUNTS them (`skipped-not-ours=3`) rather than dropping them
  silently — the first of them is large enough to sit on the dump budget for
  minutes, which is how it was found.
* **POSITIVE CONTROL:** the same detector over the grid's own PRISTINE dumps
  reports the face for `m1`–`m9`, `m12`, `m13`, `m14`, `m15`, `m16` and
  reports NOTHING for `m10`, `m11`, `n10`, `n11`.

### Why every flagged u2r name DECLINES, decoded and then measured

* `param_nested_struct_field_width` (`c.u <- pk::build::uu`),
  `pkg_nested_struct_param_width` (same), `struct_param_func_config`
  (`r.u <- p::build::u`), `struct_param_field_shift`
  (`cfg.XLEN <- cfg_pkg::build_config::xlen`) — every one of these reads a
  **FORMAL ARGUMENT**, not a parameter (the dump's fullname prefix names the
  SUBROUTINE scope).  The recognizer records those as `argWhole`, `paramRead`
  stays null, and the landed `argWholeParam` arm answers them as it did.
* `portsel_struct_param` (`c.VLEN <- cfg_pkg::build_config::CVA6ConfigXlen`) —
  this one really IS a `paramRead`, of the package localparam
  `int unsigned CVA6ConfigXlen = 64`.  It folds to a constant, so
  `elabParamConst` HITS and the new fallback never runs; and it is not a
  struct-pattern parameter, so `structPat` is false and the flatten trigger
  cannot fire either.  It is the landed arm's own golden witness and it did not
  move.
* `jeras_union`, `rp32_r5p_alu/bru/mdu/wbu` (`dec32.ill <- …::dec32::ILL`) —
  writes to the implicit function-name return variable of a function with no
  `return` statement; the recognizer's return-statement gate rejects the whole
  builder before the LHS is looked at, exactly as r11u24 measured.
* `OneThis` (`this.addr <- …::set::body::addr`) — a CLASS write in a task body;
  the return-type gate (`rt.kind != SymbolKind::PackedStructType`) rejects it.

**Measured (`byteverify.sh SELFCHECK=1`, patched vs this pass's OWN pristine
workdirs): u2r MOVERS 0 / 1608, both modes, selfcheck 1607 / 1608, path sets
identical.  Not one corpus database moved a byte.**

---

## 5. The directional census, and the shape lister beside it

`dircen26.py` scores `idcen26`'s cells — BOTH the `param_assign` Rhs cells and
the `typespec_member::Actual_value` leftovers, in all four listings — keyed on
listing x scope x name, payload = kind, value, decompile, size, const type,
operand KINDS and the typespec's Actual NAME.  Object ids are stripped (they
are per-database interning order; the identity claim lives INSIDE one database,
§1) and **so is `vpiParent`**: no generated `Compare` reads it, and scoring it
manufactured two phantom MOVED-WRONGs on `m4`, an arm the official `uhdm-cmp`
calls EQUAL.

```
m1   SAME=20 TO=4  AWAY=0 MW=0 SW=0     m10  SAME=6  TO=0  AWAY=0 MW=0 SW=0
m2   SAME=34 TO=4  AWAY=0 MW=0 SW=0     m11  SAME=9  TO=0  AWAY=0 MW=0 SW=1
m3   SAME=33 TO=15 AWAY=0 MW=0 SW=0     m12  SAME=23 TO=3  AWAY=0 MW=0 SW=0
m4   SAME=25 TO=3  AWAY=0 MW=0 SW=0     m13  SAME=20 TO=4  AWAY=0 MW=0 SW=0
m5   SAME=31 TO=4  AWAY=0 MW=0 SW=1     m14  SAME=10 TO=0  AWAY=0 MW=0 SW=0
m6   SAME=31 TO=7  AWAY=0 MW=0 SW=0     m15  SAME=20 TO=4  AWAY=0 MW=0 SW=0
m7   SAME=21 TO=3  AWAY=0 MW=0 SW=0     m16  SAME=21 TO=0  AWAY=0 MW=0 SW=3
m8   SAME=38 TO=4  AWAY=0 MW=0 SW=4     n10  SAME=14 TO=0  AWAY=0 MW=0 SW=6
m9   SAME=29 TO=4  AWAY=0 MW=0 SW=7     n11  SAME=8  TO=0  AWAY=0 MW=0 SW=0
```

**TO-GOLDEN 59, AWAY-GOLDEN 0, MOVED-WRONG 0 over the whole grid** (the
per-arm table above is what was measured and it sums to 59; an earlier draft of
this line said 61).  The verifier's own gate § patParamPatElem26v narrows the
flatten trigger by four faces this grid does not carry and leaves every arm
here unchanged, head for head and cell for cell —
`tools/probe/r11v26repro/README.md` §2.  Every
STILL-WRONG cell is named in §7.

**SHAPE LISTER** (`shapes26.py`, the Rhs operand TREE to depth 3, beside the
cell census — a shape change that kept every cell would be invisible to the
census, and a cell change out of a different tree would be attributed wrong):

* patched vs PRISTINE: **every moved shape is
  `operation(tagged_pattern,tagged_pattern) -> operation(constant,constant)`**
  — the flatten, on `pk::UU` / `pk::WW` / `pk::ENP` / `pk::PAT` / `pk::EXPR` —
  **plus exactly one of a second kind, `m3`'s `pk::CHN`
  `ref_obj(operation) -> operation(constant,constant)`**, the chained pattern
  parameter, which is a move TO golden.  Ten shapes over the eighteen arms and
  not one of any other kind.
* patched vs GOLDEN: the only non-SAME trees left are `m9`'s (golden's concat
  and replication parameters and the `struct_var` its assembly bails to — R4)
  and `m11`'s `VV` (R5).  Both are pre-existing and identical on the two
  binaries.

---

## 6. Head movement on the grid

| arm | pristine head | patched head |
|---|---|---|
| `m1` (= r11u24 `n12`) | 1 / 36 — `pk::c_t.u`'s `Actual_value`, golden an op75, ours `UINT:47244640278` | **0 heads, CMP_EQUAL** |
| `m2` (= r11u24 `n3`) | 1 / 36, the same object | **0 heads, CMP_EQUAL** |
| `m4`, `m6`, `m7`, `m12`, `m13`, `m15` | 1 / 31 or 1 / 36 each | **0 heads, CMP_EQUAL** |
| `m3` | 1 / 36 | 1 / 18 — `pk::SPAT`'s literal element `vpiSize` (32 golden, 64 ours): the § patElabUintResize reference-only gate, UNCHANGED on both binaries |
| `m5` | 1 / 36 | 1 / 32 — `work@dut.k0.W`, the override actual `.W(pk::C.u.b)`; `UINT:22` on BOTH binaries, golden `32'b…10110`.  r11u24's R3 verbatim |
| `m8` | 1 / 36 | 1 / 32 — `pk::N`'s assembled BIN; the leftover itself is now golden-exact |
| `m9` | 1 / 13 | 1 / 13, **the same object** — golden's concat leftover, a BIN constant |
| `m10`, `m11`, `m14`, `m16`, `n10`, `n11` | — | **IDENTICAL, byte for byte** |

---

## 7. Residues

* **R0 — THE ASSEMBLY OVER AN OPERATION-VALUED MEMBER RENDERS `mw / n`.**
  Grid `m8`: with `un` 96 bits wide and UU's operation carrying 2 operands,
  golden's assembled bits are `11` at 48 bits then `22` at 48 bits, not the
  natural 32/32 left-padded to 96.  The producer is explicit
  (`ExprEval.cpp:4953-4956`, inside `assemble()`):
  `size_t n = op->Operands()->size(); if (mw % n) { return false; }
  uint64_t ew = mw / n;` — each operand rendered at the MEMBER width divided
  by the operand count, first operand at the MSBs, **and the WHOLE assembly
  BAILS (the Rhs stays a `struct_var`) when the member width is not divisible
  by the operand count.**  Our assemblers build the member's bits from slang's
  own folded value at the member's range, which coincides with golden's answer
  exactly when `mw / n` is the natural element width — which is why `m1`,
  `m4`, `m6`, `m7`, `m12`, `m13` and `m15` all assemble golden-exact and `m8`
  does not.  Our `pk::N` cell is IDENTICAL on the two binaries, so this is a
  pre-existing gap the pass exposes, not one it creates.  **This is R0 for the
  next pass: it needs its own grid (unequal member widths, the divisibility
  bail) and it reaches both assemble arms.**
* **R1 — A SIMPLE PATTERN'S LITERAL ELEMENTS.**  Grid `m3`'s `pk::SPAT =
  '{33, 44}`: golden's elaborated element constants are `vpiSize:32` (the
  member widths) and ours are 64.  The landed § patElabUintResize gates the
  re-size on the element being a REFERENCE, measured that way on the corpus
  (FuncStructVal, NoReducTypespec, GenForStructParamBound all regress when
  literals re-size too); a SIMPLE pattern's literals apparently do re-size.
  IDENTICAL on both binaries; the r10fsv note already records that the literal
  arm has "a second, unfound condition" and this arm is a new witness for it.
* **R2 — AN OVERRIDE ACTUAL THAT READS A SLICED MEMBER.**  Grid `m5`'s
  `.W(pk::C.u.b)`: golden `32'b…10110` `vpiBinaryConst` and ours the plain
  `UINT:22`.  r11u24's R3 verbatim — the § asmEncFollowsRef / elabOv encoding
  road, one law out.  IDENTICAL on both binaries.
* **R3 — TWO BUILDERS, ONE STRUCT TYPESPEC.**  Grid `n10`, r11u24's R1,
  carried forward unchanged and byte-identical on both binaries.
* **R4 — A CONCAT- OR REPLICATION-VALUED PARAMETER READ WHOLE.**  Grid `m16`
  and `m9`'s `c`/`r` members: `getValue` hands the concat operation back and
  `reduceExpr` REDUCES it, so golden's leftover is a BIN constant sized at the
  operand sum (`{32'd3, 32'd4}` -> `BIN:0…0011 0…0100`, size 64) and ours is a
  value slice.  This is the landed § modEvalFuncLeftoverEnc concat rule with a
  PARAMETER as the source instead of a body expression.
  `memLeftPatParamClone26` declines the shape, so both arms are byte-identical
  on the two binaries.
* **R5 — A CHAINED PATTERN PARAMETER WITH NO BUILDER.**  Grid `m11`'s
  `localparam in_t VV = UU;`: golden's elaborated `VV` Rhs is an
  assignment-pattern OPERATION carrying `UU`'s tagged tree and ours is a bare
  `ref_obj`.  Pre-existing and identical on both binaries.  `m3`'s `CHN` is the
  same source shape and DOES move to golden there, because the builder's read
  turns on the flat walk that also re-materializes the chain — which is the
  distinguisher a future pass should start from.

**R0 for the next pass: the `mw / n` rendering (and its divisibility bail) of a
member whose EvalFunc leftover is an assignment-pattern OPERATION.  Grid arm
`m8` is the ready-made witness — 1 head / 32 cmp lines, the leftover already
golden-exact, and only the assembled `pk::N` constant wrong; the producer's
line is `ExprEval.cpp:4953-4956` and both `memLeftNestedAsmBits` and the
non-nested `whole`-slice path at `ParamEmit.cpp` need it.**

---

## 8. Gates

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `822420d0` | `66dc9cdb3437a4d220daef493a145fdd` — BYTE-IDENTICAL (the value the brief pins, and the main tree's own binary md5) |
| patched build md5 | `e5f9fcb4100c84bb23d0c44444feb511` |
| both binaries frozen `chmod 555` BEFORE any sweep | `/tmp/r11u26_pris.bin`, `/tmp/r11u26_law.bin` |
| `tests/check_goldens.sh` pristine / patched | 23 PASS / 0 FAIL on BOTH |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | PASS — every row byte-identical |
| u2r both modes vs `results/golden_uhdm2rtlil.csv` (mode-filtered) | 0 differing rows in each mode, status/detail/blocked_by/dump all |
| u2r patched vs this pass's own pristine sweep, both modes | PASS in each mode |
| u2r scoreboard | 768 / 36 / 67 pristine -> 768 / 36 / 67 patched, both modes |
| surelog patched | 469/14 default + 465/12 testflags — identical to this pass's PRISTINE sweep AND to the committed baseline |
| surelog vs `results/golden_surelog.csv` | TWO rows differ, **0 status moves, 0 dump-column moves**: `LowMemLib`/tf and `LowMemPkg`/tf differ only in the WORKDIR PATH inside a `SURELOG_FAIL` detail string |
| surelog vs own pristine | those two plus `Earlgrey_0_1`/tf's DUMP COLUMN (empty on the pristine draw, `differ` on the patched one — and `differ` is what the COMMITTED baseline carries).  Convicted as the `uhdm-dump` timeout coin: the two binaries write the **byte-identical** database, `59d0ee6d10c350970cd9f8960ebedc56` testflags and `8bdf25272e08e21c5e3f565612b5f6fe` default.  Status is `CMP_EQUAL` in both modes on both binaries |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1608**, selfcheck 1607 / 1608, path sets identical |
| `byteverify SELFCHECK=1` surelog | **MOVERS 4 / 960**, selfcheck 959 / 960, path sets identical — `MiniAmiq` x 2 modes and `SeqDriver` x 2 modes, both in the PROVEN UVM COIN FAMILY and both named a priori by L2.  **No law mover on either corpus** |
| coin attribution, ORDER-BLIND | sorted, path-normalised, id-stripped `uhdm-dump`s: **4 lines each**, and each is one `UINT:<n>` plus its `vpiDecompile:<n>` — the line-number class, nothing else |
| coin POSITIVE CONTROL | the PRISTINE binary re-invoked on `MiniAmiq`/default produced **three more distinct databases** (`6a2e142023de`, `9f2602565796`, `2174d0fd4b64`), none equal to another, to the sweep's `12c10ceab6b3`, or to the patched `e9183812b66f`.  The family is pinned by NAME and by the coin CLASS, never by the count |
| `canaries.sh` u2r / surelog | ok=8 changed=0 / **ok=52 changed=0** |
| `ctcan2.sh` u2r / surelog | PASS ok=1 changed=0 / PASS ok=58 changed=0 |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` `4842211c4030`, `YosysVerx` `6ccda350c24a` — both modes, both binaries, the exact brief values.  `SVSwitch` is one of the eight L2-flagged surelog names and it did not move |
| STATUS pins | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a` default / `73a10e8217e5` testflags, `YosysOldOr` `d68e0796d62c` — byte-identical pristine vs patched, both modes |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched, line for line (12 measured, 2 SKIP-NOFILE as expected).  `Earlgrey_0_1` 0 heads / 0 cmp lines in both modes |
| every `cmds.txt` audited BY BINARY PATH | 1531 surelog + 1742 u2r pristine rows name `/tmp/r11u26_pris.bin`, 1531 + 1742 patched rows name `/tmp/r11u26_law.bin`, and NOTHING names any other `slang-uhdm` |
| grid arms | 18 arms, every one `slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0` |
| fence check (the four slang-fenced tests) | 0 hits in the production diff; 0 hits in `tools/probe/r11u26repro/`; no driver dispatches them |
| `results/*.csv` | UNTOUCHED |
| patch applies clean on a FRESH `822420d0` worktree | yes — 0 conflicts, 0 `<<<<<<<` markers, and the applied source REBUILDS to the patched md5 `e5f9fcb4100c84bb23d0c44444feb511` |

---

## 9. Files

| file | what it is |
|---|---|
| `grid.sh` | the golden grid runner: Surelog v1.87 + both binaries + official `uhdm-cmp` per arm, every rc recorded |
| `m1`–`m16`, `n10`, `n11` | the grid arms (§2).  `m10`, `m11`, `m14`, `m16`, `n10`, `n11` are the CONTROLS and must stay byte-identical |
| `idcen26.cpp` | the ID-KEYED census of every `param_assign` Rhs and every `typespec_member` leftover — the instrument that proves the share/clone question by OBJECT IDENTITY rather than dump text |
| `dircen26.py` | the DIRECTIONAL census over `idcen26`'s cells (TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG) |
| `shapes26.py` | the SHAPE LISTER — the Rhs operand tree beside the cell census (unchanged from r11u24) |
| `predL1_26.py`, `predL2_26.py` | the a-priori mover predictions (source-keyed L1; pristine-database-keyed L2 with its positive control) |
| `pacen24.py`, `memcen24.py`, `rowcen24.sh` | the r11u24 cell / leftover censuses, carried for cross-checking |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary battery that RUNS here |
