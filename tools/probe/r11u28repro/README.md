# r11u28 — the assembly over an OPERATION-valued member renders each operand
# at the member width divided by the operand count, and a concat-valued
# parameter read whole reduces to a BIN constant

Base `bb194df5` (matrix-1.87).  Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.
ONE producer lambda decoded (`ExprEval::reduceExpr`'s `uhdmstruct_var` arm),
THREE laws implemented, ONE fully decoded and deliberately NOT implemented.
The judge is the official `uhdm-cmp` through `scripts/verify_golden.py`;
everything in this directory is measurement-only and `results/*.csv` IS NOT
EDITED BY THIS PASS.

**ZERO tests convert, and that is the honest prediction, not a
disappointment: NO ROW OF EITHER CORPUS CARRIES THIS FACE.**  §4's a-priori
detector reads all 1608 pristine u2r databases and all 960 pristine surelog
databases, flags a named set, and every flagged name is decoded and measured
NOT to move.  What the pass buys is the r11u26 landing's R0 and R4 heads and
seven more like them: **NINE grid arms go from 1 head to CMP_EQUAL**, among
them `a1` — which is r11u26's residue witness `m8` VERBATIM — and `a10`,
which is r11u26's `m16` VERBATIM.

---

## 1. The heads, RE-MEASURED at this base

Measured on this pass's own pristine build (md5
`12cabf91599980e7325679310a7b22f6` — BYTE-IDENTICAL to the main tree at
`bb194df5`, the value the brief pins), official `uhdm-cmp`, LHS always golden,
ONE head per run (`grep -c '^LHS:'` on **stderr**).

**R0, grid `a1` = r11u26 `m8` VERBATIM.**  `pk::n_t` is
`{mid_t un; int unsigned dn}` with `mid_t = {in_t v; int unsigned w}`, so `un`
is 96 bits; the builder writes `c.un.w = 7; c.un.v = UU;` and r11u24's nested
stamp leaves UU's assignment-pattern OPERATION on the first-level member `un`.

| side | `pk::N`'s elaborated `param_assign` Rhs |
|---|---|
| golden (LHS) | `BIN` 128 bits — `11` at **48** bits, `22` at **48** bits, `64` at 32 |
| ours (RHS) | `BIN` 128 bits — the natural `11`/`22` at 32 bits each, zero-padded into 96 |

1 head / 32 cmp lines, identical on the two binaries.  The leftover itself is
already golden-exact (r11u26's law) — the id census reads
`TM topPkg pk::n_t.un val#22 operation op=75 nops=2 operands=constant#23,#24`
on BOTH sides — so the only wrong cell is the assembled constant.

**R4, grid `a10` = r11u26 `m16` VERBATIM.**  `localparam in_t CAT =
{32'd3, 32'd4}` read whole by `x.c = CAT`:

| side | `pk::k_t.c`'s `Actual_value` |
|---|---|
| golden (LHS) | `constant` `BIN:0…0011 0…0100`, **size 64**, ct 3, NO decompile, NO typespec |
| ours (RHS) | `constant` `UINT:12884901892` size 64 ct 9 — the value slice |

1 head / 13 cmp lines, identical on the two binaries.

---

## 2. § patOpMemberAsmSplit28 / § patOpMemberSelSplit28 — the producer

One lambda, read from source, UHDM v1.87 `templates/ExprEval.cpp`, inside
`reduceExpr`'s `uhdmstruct_var` arm (`~4846`):

```
:4894   expr *rme = reduceExpr((any *)mv, …)        // the member's leftover
:4898   if (!iv && rme && rme is a constant) b = toBinary(rme);   // constant road
        …else the leftover is an OPERATION and:
:4952       } else if (op && op->Operands() && !op->Operands()->empty() &&
:4953           (optype == vpiAssignmentPatternOp || optype == vpiConcatOp)) {
:4954         size_t n = op->Operands()->size();
:4955         if (mw % n) { return false; }          // THE DIVISIBILITY BAIL
:4956         uint64_t ew = mw / n;
:4957-69      for each operand: reduceExpr, toBinary, TRUNCATE to the low `ew`
              bits or LEFT-PAD with zeros to `ew`, append
                                                    // FIRST OPERAND AT THE MSBs
:4996   if (assemble(stps, bits) && !bits.empty()) { mint the BIN constant }
:5008   return (expr *)result;                      // …else THE STRUCT_VAR
```

Three facts fall out of it.

**(A) THE EQUAL SPLIT.**  `mw` is the MEMBER's own packed width, never the
operand's natural one.  Our assemblers build each member's bits from slang's
own folded value at the member's range, which coincides with golden's answer
exactly when `mw / n` IS the natural element width — which is why r11u26's
`m1`/`m4`/`m6`/`m7`/`m12`/`m13`/`m15` assembled golden-exact and `m8` did
not.  Measured, one arm per face, and the OPERAND KIND is free:

| arm | member | n | `ew` | golden's bits |
|---|---|---|---|---|
| `a1` | `un` 96 | 2 | 48 | `11`@48 ++ `22`@48 |
| `a2` | the same through the MODULE holder | 2 | 48 | identical, cell for cell |
| `a4` | `u` 120 | **3** | 40 | `1`@40 ++ `2`@40 ++ `3`@40 |
| `a5` | `p` 96 / `q` 96 | 2 | 48 | literals at 48; **8-bit ENUM elements zero-extended to 48** |
| `a6` | `u` **32** | 2 | 16 | each operand **TRUNCATED** to its low 16 bits |
| `a7` | `u` **128** | 2 | 64 | each operand zero-extended to 64 |

`a6`/`a7` reach the NON-NESTED whole-write road (`c.u = UU` into a member
that is not the pattern's own type); `a1`/`a2`/`a4`/`a5` reach
§ pkgStructFuncAssembleNested24's road.  Both needed it, exactly as r11u26's
R0 line predicted.

**(B) AND THE READERS SEE IT TOO.**  `hierarchicalSelector` takes the member
out of the value `reduceExpr` assembled, so every member READ of such a
parameter carries the same rendering — golden `a1`'s
`localparam mid_t S2 = Q.un` is `11`@48 ++ `22`@48, `a6`'s `S1 = P.u` the two
16-bit truncations, `a7`'s the two 64-bit extensions.  Our readers slice
slang's own folded value, so fixing only the assembled constant would have
left one wrong cell per reader and converted nothing.  § patOpMemberSelSplit28
is that half: the corrected bit string is recorded per assembled parameter
(`patOpAsmBits28`), the base is followed through parameter references the way
the landed § asmEncFollowsRef family follows one, and the member slice is
taken out of THOSE bits.  It is a VALUE correction only — the whole encoding
pipeline below it is untouched, which is why the shape lister (§5) reports not
one changed tree on the whole grid.

**(C) THE DIVISIBILITY BAIL — DECODED, MEASURED, AND NOT IMPLEMENTED.**
`return false` inside the lambda aborts the WHOLE struct: golden's elaborated
Rhs stays a `struct_var` even though every other member assembles.  Three arms
say so, and they are the READY-MADE WITNESSES for the next pass (§7 R1):

| arm | face | golden's `pk::C` / `work@dut.L` |
|---|---|---|
| `a3` | `u` **95** bits, 2 operands, the NESTED road | `struct_var` in `topPackages` AND `topModules` AND `allModules` |
| `a18` | `u` 95 bits, the WHOLE-WRITE road | the same |
| `a19` | `u` 95 bits, the MODULE holder | `work@dut.L` a `struct_var`, and `work@dut.k0.CFG` too |

It is NOT implemented because the bail cannot be taken without moving cells
this pass cannot answer: § asmEncFollowsRef R1's reader arm and the
`asmRefOv` override arm both read the base's FINAL Rhs, and on a bail they
fall back to the unfolded `func_call` / the wide HEX fold where golden carries
a `struct_var`; and the READER of a bailed member is a third answer again
(golden `a3` `k0.S1` is the leftover OPERATION re-typespec'd to the reader's
own `pk::m95_t`, `a18`'s is `UINT:47244640278` at size 95, `a19`'s is
`INT:0`).  A build that took the bail measured **MOVED-WRONG 9** on exactly
those cells with AWAY 0; that build was discarded and the three arms are kept
here as MEASUREMENT-ONLY, **byte-identical on the two binaries**.

## 2b. § catParamLeftoverReduce28 — R4's producer, and what it yields per shape

`getValue` hands the read parameter's elaborated Rhs OBJECT back whatever its
kind (`ExprEval.cpp:307`).  An assignment pattern survives `reduceExpr`
unreduced — that is r11u26's law.  A CONCATENATION does not.  Decoded per
shape, and every row measured on a v1.87 golden:

| the read parameter's elaborated Rhs | golden's leftover | arm |
|---|---|---|
| `vpiConcatOp` of constants | `BIN` at the **SUM OF THE OPERAND SIZES**, **no decompile, no typespec** | `a8`, `a10`, `a11`'s `c` |
| `vpiMultiConcatOp` (`{2{32'hAB}}`) | `BIN` at n × the element width, **WITH decompile and WITH a `ref_typespec -> int_typespec`** | `a9`, `a11`'s `r`, `a12` |
| already a CONSTANT (a module-scope `logic [63:0]` concat param Surelog folded) | a CLONE of that constant — `BIN`, decompile `64'b…`, `ref_typespec -> logic_typespec` | `a20` |
| an arithmetic parameter (`3 + 4`) | folds to a constant; the landed `elabParamConst` arm already answers it | `a11`'s `y` |

That is exactly the landed § modEvalFuncLeftoverEnc reducer's own model with a
PARAMETER as the source instead of a body expression, so the pass runs the
SAME reducer (`memLeftReduceCat`) over the same member bits.  **The concat row
is implemented and converts `a8` and `a10`; the replication row is NOT, and
the reason is upstream of this law** — our elaborated `pk::REP` folds to a
`constant` (at `size=32` carrying a 64-bit BIN string) where golden keeps the
`vpiMultiConcatOp` operation, so there is no operation for the reducer to run
over.  §7 R2, with three arms already built.  The `a20` row is R3.

### THE GOLDEN GRID (Surelog v1.87, one arm per directory, EVERY rc recorded)

`grid.sh` runs `surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`,
then both frozen binaries, then the official `uhdm-cmp`.  **Every arm below
compiled `slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.**

| arm | shape | pris → patched |
|---|---|---|
| `a1` | **r11u26 `m8` VERBATIM** — nested write from a pattern parameter, `un` 96 bits | 1/32 → **0, CMP_EQUAL** |
| `a2` | THE MODULE HOLDER of `a1` — the assembly runs through § modStructFuncAssembleBin | 1/32 → **0, CMP_EQUAL** |
| `a3` | **THE DIVISIBILITY BAIL**, nested road, `u` 95 bits | 1/26 → 1/26, **BYTE-IDENTICAL** (R1) |
| `a4` | OPERAND COUNT **THREE**, `u` 120 bits, `ew` 40 | 1/32 → **0, CMP_EQUAL** |
| `a5` | THE OPERAND KINDS — 32-bit literals and 8-bit ENUM elements, both at `ew` 48 | 1/32 → **0, CMP_EQUAL** |
| `a6` | THE MEMBER NARROWER — `u` 32 bits, each operand TRUNCATED to 16 | 1/32 → **0, CMP_EQUAL** |
| `a7` | THE MEMBER WIDER, the NON-NESTED road — `u` 128 bits, `ew` 64 | 1/32 → **0, CMP_EQUAL** |
| `a8` | a CONCAT parameter into a WIDER (96-bit) member — decides that `reduceExpr` reduces FIRST and the split never applies | 1/13 → **0, CMP_EQUAL** |
| `a9` | a REPLICATION parameter into a wider member | 1/20 → 1/20, **BYTE-IDENTICAL** (R2) |
| `a10` | **r11u26 `m16` VERBATIM** — a concat parameter read whole, alone | 1/13 → **0, CMP_EQUAL** |
| `a11` | **r11u26 `m9` VERBATIM** — concat / replication / enum-pattern / arithmetic side by side | 1/13 → 1/20, 3 cells TO golden (the concat one), the replication left (R2) |
| `a12` | a REPLICATION parameter read whole at the NATURAL width, alone | 1/20 → 1/20, **BYTE-IDENTICAL** (R2) |
| `a13` | THE VIEW SPLIT — the holder is an instance override ACTUAL, so all three listings carry their own copy | 1/32 → **0, CMP_EQUAL** |
| `a14` | **r11u26 `m1` VERBATIM** — the landed family's own control | 0/0 **IDENTICAL** |
| `a15` | **r11u26 `m10` VERBATIM** — the NO-READER control | 0/0 **IDENTICAL** |
| `a16` | THE NATURAL-WIDTH NEGATIVE CONTROL — `mw / n` equals the natural width, so the split must not be visible | 0/0 **IDENTICAL** |
| `a17` | the REFERENCE operand kind (`'{a: RA, b: RB}`), `ew` 48 | 1/8 → 1/8, 4 cells TO golden; the head is the reference element's own `int_typespec` ref (pre-existing, r11u26 R1's neighbourhood) |
| `a18` | THE DIVISIBILITY BAIL, whole-write road | 1/26 → 1/26, **BYTE-IDENTICAL** (R1) |
| `a19` | THE DIVISIBILITY BAIL, MODULE holder | 1/23 → 1/23, **BYTE-IDENTICAL** (R1) |
| `a20` | a concat parameter Surelog already FOLDED, read whole (the module-scope face) | 1/20 → 1/20, **BYTE-IDENTICAL** (R3) |

`a14`, `a15`, `a16` are the CONTROLS that must stay byte-identical, and do;
`a3`, `a9`, `a12`, `a18`, `a19`, `a20` are the residue arms and are
byte-identical too — **nine of the twenty databases do not move a byte.**

---

## 3. Where it is implemented

Three edits, `src/ParamEmit.cpp` + `include/UhdmExporter.h`, and nothing
outside ParamEmit's assemble/leftover machinery:

* **`memLeftConstBits28`** — the producer's own `toBinary`, for
  BIN/HEX/OCT/DEC/INT/UINT at the constant's `VpiSize`.  It DECLINES a
  negative decimal and every other const type; a decline leaves the
  pre-existing bits untouched.
* **`memLeftPatOpSrc28`** — asks, AT THE PARAM SITE, whether a member's read
  parameter is the one § patParamLeftoverShare26 will later leave an
  OPERATION on.  It mirrors `memLeftPatParamClone26`'s acceptance exactly
  (`vpiAssignmentPatternOp`, non-empty, every operand a plain constant) and
  returns null for a parameter the landed constant arm answers
  (`elabParamConst`), which is why `portsel_struct_param`'s real `paramRead`
  cannot reach it.
* **`memLeftPatOpAsmSplit28`** — rewrites the assembled bit string member by
  member.  A SHAPE FENCE runs first (the fields must tile the string exactly
  and match the leftover vector), so a struct this rule does not model is
  left alone.  Called from BOTH assemble roads, at the param site, so the
  constant the readers and the override actuals inherit carries it too.
* **`patOpAsmBits28` + `memLeftAsmSplitBits28` + `memLeftPatOpSelValue28`** —
  the reader half.  The ONLY production wiring is one line at
  `src/ParamEmit.cpp`'s parameter-value site: `auto& iv = cvo.integer()`
  becomes a reference that prefers the corrected value when the parameter's
  initializer is a member-access chain into a base in `patOpAsmBits28`.  The
  map is empty unless § patOpMemberAsmSplit28 actually changed a base's bits.
* **the drain's `paramRead` fallback, one more arm** — reached only after
  `elabParamConst` misses AND `memLeftPatParamClone26` declines: run
  `memLeftReduceCat` over the read parameter's elaborated Rhs.  Its bail
  (a non-constant operand, a 64-bit INT/UINT operand in a multi-operand
  concat, a result wider than the member) is the producer's and is unchanged.
* **`SrlgMemLeft`'s `memBits`** now also built for a `paramRead` member, not
  only a `catRhs` one.  Stamp-local bookkeeping; nothing reaches the database
  from it unless the reducer accepts the shape.

The landed family laws are read-only inputs here: the stamp drain, the two
bail rules, the encodings, the member-slice fold, r11u24's nested stamp,
r11u26's clone and flatten trigger and r11v26's element gate are all
untouched.

---

## 4. The mover set, PREDICTED BY NAME BEFORE ANY PATCHED CORPUS DATABASE EXISTED

Every edit hangs off ONE recorded fact — the recognizer's
`SrlgMemLeft::paramRead`, set when a builder body writes a member from a WHOLE
READ OF A NAME.  No `paramRead`, no split, no reduce, no corrected reader.

**L2 (`predL28.py`, PRISTINE-DATABASE-keyed, a deliberate superset):** a
`function`/`task` body holding an `assignment` whose LHS is a `hier_path` and
whose RHS is a bare `ref_obj`.  It does NOT check that the read name is a
parameter, nor that the function returns a packed struct, nor that a parameter
calls it, nor that any member width fails to divide.

* **u2r: 22 databases = 11 test names × 2 modes.  All 1608 databases read, 0
  errors, nothing skipped** — `param_nested_struct_field_width`,
  `pkg_nested_struct_param_width`, `struct_param_func_config`,
  `struct_param_field_shift`, `portsel_struct_param`, `jeras_union`,
  `rp32_r5p_alu`, `rp32_r5p_bru`, `rp32_r5p_mdu`, `rp32_r5p_wbu`, `OneThis`.
  The r11u26 reading, reproduced exactly.
* **POSITIVE CONTROL:** the same detector over the grid's own PRISTINE dumps
  reports the face for `a1`–`a14` and `a16`–`a20` and reports NOTHING for
  `a15`, the no-reader control.

### Why every flagged u2r name DECLINES, decoded and then measured

* `param_nested_struct_field_width`, `pkg_nested_struct_param_width`,
  `struct_param_func_config`, `struct_param_field_shift` — every one reads a
  **FORMAL ARGUMENT**, not a parameter (the dump's fullname prefix names the
  SUBROUTINE scope: `pk::build::uu`, `p::build::u`, `cfg_pkg::build_config::xlen`).
  The recognizer records those as `argWhole`; `paramRead` stays null, so
  `memLeftPatOpSrc28` is never asked and the drain's new arm never runs.
* `portsel_struct_param` (`c.VLEN <- cfg_pkg::build_config::CVA6ConfigXlen`) —
  this one really IS a `paramRead`, of the package localparam
  `int unsigned CVA6ConfigXlen = 64`.  It FOLDS to a constant, so
  `elabParamConst` HITS: the drain `continue`s before either new arm, and
  `memLeftPatOpSrc28` returns null on its first test.  It is the landed arm's
  own golden witness and it did not move.
* `jeras_union`, `rp32_r5p_alu/bru/mdu/wbu` (`dec32.ill <- …::dec32::ILL`) —
  writes to the implicit function-name return variable of a function with no
  `return` statement; the recognizer's return-statement gate rejects the whole
  builder before the LHS is looked at.
* `OneThis` (`this.addr <- work@foo::set::body::addr`) — a CLASS write in a
  task body; the return-type gate (`rt.kind != SymbolKind::PackedStructType`)
  rejects it, and the read name is a task-body LOCAL, not a parameter.

---

## 5. The directional census, and the shape lister beside it

`dircen26.py` (r11u26's, carried unchanged) scores `idcen26`'s cells — BOTH
the `param_assign` Rhs cells and the `typespec_member::Actual_value`
leftovers, in all four listings — keyed on listing × scope × name, payload =
kind, value, decompile, size, const type, operand KINDS and the typespec's
Actual NAME.  Object ids and `vpiParent` are stripped (no generated `Compare`
reads `VpiParent`).  **Calibrated golden-vs-golden-vs-golden FIRST on `a1`,
`a5`, `a11`, `a19`: `SAME=46/52/40/26`, TO 0, AWAY 0, MW 0, SW 0.**

```
a1   SAME=42 TO=4  AWAY=0 MW=0 SW=0     a11  SAME=33 TO=3  AWAY=0 MW=0 SW=4
a2   SAME=32 TO=4  AWAY=0 MW=0 SW=0     a12  SAME=12 TO=0  AWAY=0 MW=0 SW=4
a3   SAME=28 TO=0  AWAY=0 MW=0 SW=4     a13  SAME=31 TO=3  AWAY=0 MW=0 SW=0
a4   SAME=32 TO=4  AWAY=0 MW=0 SW=0     a14  SAME=24 TO=0  AWAY=0 MW=0 SW=0
a5   SAME=47 TO=5  AWAY=0 MW=0 SW=0     a15  SAME=6  TO=0  AWAY=0 MW=0 SW=0
a6   SAME=16 TO=4  AWAY=0 MW=0 SW=0     a16  SAME=24 TO=0  AWAY=0 MW=0 SW=0
a7   SAME=16 TO=4  AWAY=0 MW=0 SW=0     a17  SAME=32 TO=4  AWAY=0 MW=0 SW=0
a8   SAME=13 TO=3  AWAY=0 MW=0 SW=0     a18  SAME=16 TO=0  AWAY=0 MW=0 SW=4
a9   SAME=12 TO=0  AWAY=0 MW=0 SW=4     a19  SAME=22 TO=0  AWAY=0 MW=0 SW=4
a10  SAME=21 TO=3  AWAY=0 MW=0 SW=0     a20  SAME=15 TO=0  AWAY=0 MW=0 SW=3
```

**TO-GOLDEN 41, AWAY-GOLDEN 0, MOVED-WRONG 0 over the whole grid.**  Every
still-wrong cell is named in §7.

**SHAPE LISTER** (`shapes26.py`, the Rhs operand TREE to depth 3, beside the
cell census — a shape change that kept every cell would be invisible to the
census, and a cell change out of a different tree would be attributed wrong):

* patched vs PRISTINE: **NOT ONE TREE CHANGED, on any of the twenty arms.**
  This law moves VALUES and ENCODINGS inside trees that were already right —
  which is exactly what a `mw / n` re-rendering and a leftover re-encoding
  should look like, and is why the nine byte-identical arms are byte-identical
  rather than merely cmp-equal.
* patched vs GOLDEN: the only non-SAME trees left are the three bail arms'
  (`a3`/`a18` `pk::C` and `work@kid.P`/`work@dut.k0.P`, `a19`'s `work@dut.L`
  and `work@dut.k0.CFG` — golden `struct_var`, ours `constant`; plus `a3`'s
  `k0.S1` and `a19`'s `MS` — golden `operation`, ours `constant`) and
  `pk::REP` on `a9`/`a11`/`a12` (golden
  `operation(constant,operation(constant))`, ours `constant`).  R1 and R2,
  both pre-existing and identical on the two binaries.

---

## 6. Head movement on the grid

| arm | pristine head | patched head |
|---|---|---|
| `a1` (= r11u26 `m8`) | 1 / 32 — `pk::N`'s assembled BIN, golden `11`@48 ++ `22`@48 | **0 heads, CMP_EQUAL** |
| `a2`, `a4`, `a5`, `a6`, `a7`, `a13` | 1 / 32 each | **0 heads, CMP_EQUAL** |
| `a8`, `a10` (= r11u26 `m16`) | 1 / 13 each — the concat leftover | **0 heads, CMP_EQUAL** |
| `a11` (= r11u26 `m9`) | 1 / 13 — the concat leftover | 1 / 20 — the REPLICATION leftover behind it (R2); the concat cell moved TO golden |
| `a17` | 1 / 8 | 1 / 8 — the reference element's `int_typespec` ref, UNCHANGED on both binaries; 4 cells moved TO golden behind it |
| `a3`, `a9`, `a12`, `a14`, `a15`, `a16`, `a18`, `a19`, `a20` | — | **IDENTICAL, byte for byte** |

---

## 7. Residues

* **R1 — THE DIVISIBILITY BAIL.**  `ExprEval.cpp:4954-4955`
  (`if (mw % n) return false;`) and `:5008` (`return (expr *)result`): a
  member whose packed width is not divisible by its leftover operation's
  operand count leaves the WHOLE parameter's elaborated Rhs a `struct_var`,
  in every listing and at every copy.  Decoded, measured on three arms
  (`a3` nested road, `a18` whole-write road, `a19` module holder) and NOT
  implemented: a build that took it measured MOVED-WRONG 9 / AWAY 0 on cells
  the pass cannot answer — § asmEncFollowsRef R1's reader arm and the
  `asmRefOv` override arm fall back to the unfolded `func_call` and the wide
  HEX fold where golden carries the `struct_var`, and the READER of a bailed
  member is a third answer again (`a3` `k0.S1` = the leftover OPERATION
  re-typespec'd to `pk::m95_t`; `a18` = `UINT:47244640278` size 95; `a19`
  `k0.S` = `INT:0` size 95).  **This is R0 for the next pass and the three
  arms are ready-made.**
* **R2 — THE REPLICATION-VALUED PARAMETER.**  Golden's leftover for
  `x.r = REP` with `localparam logic [63:0] REP = {2{32'hAB}}` is `BIN` at
  64, WITH decompile and WITH a `ref_typespec -> int_typespec` — exactly what
  `memLeftReduceCat`'s `vpiMultiConcatOp` branch mints.  It cannot run,
  because our own elaborated `pk::REP` is a `constant` where golden keeps the
  `vpiMultiConcatOp` operation — and our constant carries `size=32` against a
  64-bit BIN string, which is a defect of its own.  The distinguisher a future
  pass should start from is that fold, not the leftover.  Arms `a9`, `a11`,
  `a12`, all byte-identical on the two binaries.
* **R3 — A CONCAT PARAMETER SURELOG ALREADY FOLDED.**  `a20`: a MODULE-scope
  `localparam logic [63:0] CAT = {32'd3, 32'd4}` has an elaborated Rhs that is
  already a `constant` on BOTH sides (`BIN`, decompile `64'b…`, a
  `ref_typespec -> logic_typespec`), and golden's leftover is a CLONE of it
  where ours is the value slice.  The shape `memLeftReduceCat` declines (it
  takes an operation), and the landed `elabParamConst` arm does not hold a
  module localparam.  Byte-identical on the two binaries.
* **R4 — A PATTERN ELEMENT THAT IS A PARAMETER REFERENCE.**  `a17`'s
  `localparam in_t REF = '{a: RA, b: RB}` keeps a head on both binaries: the
  element constant's `ref_typespec -> int_typespec`.  The split itself is
  golden-exact there (4 cells TO golden).  Pre-existing, r11u26 R1's
  neighbourhood.

**R0 for the next pass: the DIVISIBILITY BAIL (R1 above) — the producer's
line is `ExprEval.cpp:4954`, the reach is the WHOLE struct, grid arms `a3`,
`a18` and `a19` are built and byte-identical today, and the three blocking
cells are named: § asmEncFollowsRef R1's reader arm, the `asmRefOv` override
arm, and the member READ of a bailed struct (three different golden answers,
one per arm).**

---

## 8. Gates

See §8 of the landing commit for the corpus numbers; the per-gate table is
`GATES.md` in this directory.

---

## 9. Files

| file | what it is |
|---|---|
| `grid.sh` | the golden grid runner: Surelog v1.87 + both binaries + official `uhdm-cmp` per arm, every rc recorded |
| `a1`–`a20` | the grid arms (§2).  `a14`, `a15`, `a16` are the CONTROLS; `a3`, `a9`, `a12`, `a18`, `a19`, `a20` are the residue arms — all nine must stay byte-identical |
| `idcen26.cpp` | the ID-KEYED census of every `param_assign` Rhs and every `typespec_member` leftover (r11u26's, carried unchanged) |
| `dircen26.py` | the DIRECTIONAL census over `idcen26`'s cells (TO / AWAY / MOVED-WRONG / STILL-WRONG), calibrated golden-vs-golden first |
| `shapes26.py` | the SHAPE LISTER — the Rhs operand tree beside the cell census |
| `predL28.py` | the a-priori mover prediction (pristine-database-keyed, with its positive control on the grid's own dumps) |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary battery that RUNS here |
| `coin.sh` | ORDER-BLIND attribution of one surelog byte mover: path- and id-normalised, sorted `uhdm-dump`s |
| `GATES.md` | the gate table (§8) |
