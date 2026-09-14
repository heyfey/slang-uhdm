# r11u24 — a const function that writes a NESTED struct member stamps the
# FIRST-LEVEL member, whole, and the assembled parameter is those stamped
# values — not slang's own evaluation of the local

Base `5346c1e9` (matrix-1.87).  Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.
ONE law, ONE recognizer, two assemble arms.  The judge is the official
`uhdm-cmp` through `scripts/verify_golden.py`; everything in this directory is
measurement-only and `results/*.csv` IS NOT EDITED BY THIS PASS.

**ZERO tests convert, and that is the honest prediction, not a disappointment:
say it plainly — NO ROW OF EITHER CORPUS CARRIES THIS FACE.**  The a-priori
database-keyed detector (§4) reads all 1608 pristine u2r databases and all 960
pristine surelog databases and flags six test names; every one of them is
decoded and measured NOT to move, and the sweeps then measure **u2r MOVERS
0 / 1608** and the surelog coin family alone.  What the pass buys is the
r11u21 landing's R0 head: grid `n1` is r11u21's `t9` VERBATIM and it
**CONVERTS — 1 head / 7 cmp lines → 0 heads, CMP_EQUAL** — and with it the
module holder (`n4`), the write-order arm (`n2`), three-level nesting (`n6`),
five leftover encodings (`n7`) and the union member (`n9`'s `c_t`).

---

## 1. The head, RE-MEASURED at this base

Measured on this pass's own pristine build (md5
`b46b0f3e573c5b435bb827c097e47091` — BYTE-IDENTICAL to the main tree at
`5346c1e9`, the value the brief pins), official `uhdm-cmp`, LHS always golden,
ONE head per run (`grep -c '^LHS:'` on **stderr**).

`n1`/`t9`: `package pk; … c_t mk(); c_t c; c.u.a = 3; c.u.b = 32; c.d = 64;
return c; endfunction; localparam c_t C = mk();` with `in_t = {int unsigned a;
int unsigned b;}` and `c_t = {in_t u; int unsigned d;}`.

| side | object |
|---|---|
| golden (LHS) | the `typespec_member` `pk::c_t.u`'s **`Actual_value`** — a `constant` at `8:31-8:33` (the span of the body literal `32`), `vpiDecompile:32`, `vpiSize:64`, `UINT:32`, `vpiConstType:9` |
| ours (RHS) | `<null>` — we stamp NOTHING, because the recognizer rejects the whole builder |

7 cmp lines, 1 head, in both modes.  **The r11u21 README's framing of this arm
("our base's elaborated Rhs is still a `func_call`") is true of the MODULE
copy and NOT of the package: re-measured, our pristine `pk::C` is already a
`constant`, `UINT:0` size 32 with decompile `55340232358567608384` (the
`pkgElabComputed` decimal fold of slang's own value a=3, b=32, d=64) where
golden is the 96-bit BIN.**  The head sits one level before that, on the
leftover.

### THE FIVE CELLS of the arm, re-measured (golden, both modes identical)

| cell | golden |
|---|---|
| `topPackages pk::C` | `BIN` size 96, decompile BARE, ts ref `(pk)` -> `struct_typespec pk::c_t`; the bits decode **a = 0, b = 32, d = 64** |
| `topModules work@dut.k0.CFG` | the same 96 bits with the `96'b` prefix, ts ref `(work@dut.k0)` |
| `topModules work@dut.k0.SUB` (`CFG.u`) | `BIN` size 64 BARE -> `struct_typespec pk::in_t`, value 32 |
| `topModules work@dut.k0.DEEP` (`CFG.u.b`) | `BIN` size 32 BARE -> the member's `int_typespec`, value 32 |
| `topModules work@dut.k0.BIT0` (`CFG.d[0]`) | `BIN:0` size 1, decompile `1'b0`, **NO typespec**, no parent |

**a = 0 is the whole decode.**  slang's own evaluation of the local has a = 3.
Golden's does not, and §2 says why.

---

## 2. § pkgStructFuncAssembleNested24 — the producer, read from source

Two UHDM v1.87 arms, both in `templates/ExprEval.cpp`:

**(1) THE STAMP.** `ExprEval::setValueInInstance` (~5665, and its twin at
~5350) resolves an `assignment` whose LHS is a `hier_path` with

```cpp
expr *object = (expr *)decodeHierPath(path, invalidValue, inst, lhsexp,
                                      ReturnType::MEMBER);
if (object && object->UhdmType() == uhdmtypespec_member) {
    ((typespec_member *)object)->Actual_value(rhsexp);   // <- WHOLE, one slot
    return false;
}
```

and `hierarchicalSelector`'s `struct_var` arm answers a `ReturnType::MEMBER`
walk with

```cpp
} else if (returnType == ReturnType::MEMBER) {
    return member;                       // ~2425 — NO recursion
}
```

— beside a `VALUE` arm three lines below that DOES walk the remaining
selectors.  So `c.u.a = 3` resolves at LEVEL ZERO to the `typespec_member` `u`
and stamps the RHS constant on it WHOLE; `c.u.b = 32` then overwrites the same
single slot.  **The first path element after the local decides the member, the
RHS lands on it whole, and the LAST write to a first-level member wins.**

**(2) THE ASSEMBLY.** `ExprEval::reduceExpr`'s `uhdmstruct_var` arm (~4846)
walks the FIRST-LEVEL members only, `toBinary`s each member's `Actual_value`,
then left-pads with zeros or truncates to the member's own packed width, first
declared member at the MSBs.  With `u` stamped `UINT:32` size 64 that is
`0…0100000` — a = 0, b = 32 — and `d` stamped `UINT:64` gives the 96-bit
answer above.  A member with NO value at all makes the arm `return false` and
the Rhs stays the `struct_var` (the landed § pkgStructFuncAssembleBinBail).

Both arms are holder-blind: `setValueInInstance` never sees who holds the
parameter, and grid `n4` measures the MODULE holder's `work@dut.L` as the same
96-bit answer as `n1`'s package-held `pk::C`.

### THE GOLDEN GRID (Surelog v1.87, one arm per directory, EVERY rc recorded)

`grid.sh` runs `surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`,
then both frozen binaries, then the official `uhdm-cmp`.  **Every arm below
compiled `slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.**  Cells are read by
`pacen24.py` (keyed on section x instance x the `param_assign` Lhs FULL name —
never a span, never an id) and leftovers by `memcen24.py` (keyed on section x
struct typespec name x member name).

| arm | shape | golden, and what it decides |
|---|---|---|
| `n1` | **r11u21 `t9` VERBATIM** — package holder, `c.u.a = 3; c.u.b = 32; c.d = 64` | `u` <- the `32` body object (UINT:32 size 64), `d` <- the `64` one; assembly a = 0, b = 32, d = 64.  **CONVERTS** |
| `n2` | WRITE ORDER — `mk` swaps n1's two nested writes; `mk2` writes one member three times (`c.u2.a = 7; c.u2.b = 9; c.u2.a = 5`) | `u` <- 3 (the MSB-side field's own value, proving the RHS lands WHOLE and not merged), `u2` <- 5.  **CONVERTS** |
| `n3` | MIXED whole + nested into ONE member, BOTH orders | `mkWN` (`c.u = UU; c.u.a = 3`) -> `u` <- 3; `mkNW` (`c.un.a = 3; c.un = UU`) -> `un` <- **UU's own elaborated Rhs OPERATION**.  Plain last-writer-wins across the two write kinds |
| `n4` | THE MODULE HOLDER — builder and localparam in `module dut`, typedefs in the package | `work@dut.L` assembles identically to `n1`'s package-held `pk::C` (`96'b…`), `MS`/`MD` slice, the override actual `.CFG(L)` carries the assembly.  **CONVERTS** |
| `n5` | THE BAIL + ITS FLAT CONTROL — `mkGap` writes only FIRST-LEVEL members and leaves `e` unwritten; `mkAllNested` writes every member nested | `pk::CG` stays a **`struct_var`** (golden's own bail) with `u`/`d` still stamped; `pk::CA` assembles 128 bits (u = 32, v = 6).  The `CG` half is the FLAT family's unwritten-member gap and its head is IDENTICAL pristine and patched |
| `n6` | THREE LEVELS — `c.u.v.a = 3; c.u.v.b = 32; c.u.w = 7; c.d = 64` | `u` <- **7** — the first element after the local still decides, at any depth.  `M`/`V`/`A`/`D` all slice to golden |
| `n7` | THE NESTED LEFTOVER'S ENCODING, one member per RHS shape | LITERAL -> the body object (UINT:5/64); TERNARY -> **INT:8 size 64**; PARAMETER read -> that parameter's own **UINT:21 size 32**; CONCAT -> **BIN size 32** (the operand sum) with NO decompile; FORMAL whole read -> the caller's actual **UINT:77 size 64**.  Every one is the FLAT family's own encoding rule, unchanged |
| `n8` | THE READERS — whole sub-struct, nested, bit select, taint (`+1`, `$clog2`), an override actual, a port width, and untainted controls beside them | every param cell but one moves to golden; the `.W(DEEP)` override actual stays on the `<w>'b` encoding road (R3) |
| `n9` | UNION member nested (`c.n.x = 9`) vs a packed-array ELEMENT write (`c.arr[0] = 8'h5`) | `c_t` assembles (the union member is stamped whole, u = 32, n = 9, d = 64); `d_t` golden also assembles (arr = 6, the last element write) and **we DECLINE it** — the indexed write is a different bit-range rule.  A decline writes nothing |
| `n10` | SHARED struct typespec, TWO builders, **FLAT writes only** | golden's single typespec carries the **LAST-EVALUATED** parameter's leftovers (`mkB`'s 5/9); we stamp the FIRST.  **IDENTICAL pristine and patched — the FLAT family's own rule** |
| `n11` | compilation-unit (`$root`) typedef, **FLAT writes only** | CMP_EQUAL on both binaries.  **IDENTICAL pristine and patched** |
| `n12` | `c.u = UU` with `UU` an assignment-pattern localparam, **FLAT only** | golden's leftover IS `UU`'s operation object; we re-encode a constant.  **IDENTICAL pristine and patched — and it is `n3`'s remaining head, object for object** |

`n10`, `n11` and `n12` are the pass's CONTROLS: every one is first-level-only,
every one is byte-identical on the two binaries, and each carries one of the
three residues that survive on a nested arm.  They are what says those
residues belong to the FLAT family and not to this law.

---

## 3. Where it is implemented

Three edits, all in `src/ParamEmit.cpp` + `include/UhdmExporter.h`:

* **the RECOGNIZER** (`srlgEvalFuncMemberLeftovers`): the LHS may now be a
  CHAIN of `MemberAccess` rooted at the builder's local.  The chain is walked
  root-first; every level's `member` must be a `FieldSymbol` and the levels'
  `bitOffset`s simply add (a packed UNION member's is 0, which is why `n9`'s
  `c.n.x = 9` stamps the whole of `n`).  The entry is keyed on
  `chain.front()->member.name` — the FIRST-LEVEL member — so the `std::map`
  assignment IS the producer's last-write-wins.  An INDEXED write still fails
  the whole builder, and so does a level whose member is not a field.
* **`SrlgMemLeft::selOff` / `selWidth` / `nestedWrite`**: the winning write's
  own bit range, recorded ONLY when the chain went below the first level.
  `selWidth == 0` means "first-level", and every reader then uses the
  `FieldSymbol`'s own offset and width — which is why the flat family is byte
  for byte what it was (`n10`/`n11`/`n12`, and u2r MOVERS 0 / 1608).
* **`UhdmExporter::memLeftNestedAsmBits`**: golden's assembly, built from the
  per-member winning ranges and re-rendered at each member's width.  It runs
  ONLY when some leftover is `nestedWrite`; when it cannot render the shape the
  caller assembles NOTHING and the database stays byte-identical.  The two
  assemble arms (§ pkgStructFuncAssembleBin's package arm and
  § modStructFuncAssembleBin's module candidate) each call it.

`makeMemLeftConst` and the `catRhs` bit string take the same (off, width)
override, so a nested member's re-encoded fallback and its concat bits are
read at the WRITE TARGET's range — `n7`'s `c.t.a = {16'h0, 16'h3}` needs
exactly that (golden BIN size 32 value 3; the member's own range would have
given the low 32 bits of `t`, which are zero).

The decoded model, the producer's file:line and every fence live at the
`SrlgMemLeft` declaration and at `memLeftNestedAsmBits` in
`include/UhdmExporter.h`.

**The landed family laws are read-only inputs here.**  Nothing in the stamp
drain, the bail rules, the encodings, the member-slice fold or the assemble
arms' own logic is touched; the only thing that changed is WHICH builders the
recognizer accepts and, for those, WHERE the bits are read.

---

## 4. The mover set, PREDICTED BY NAME BEFORE ANY PATCHED DATABASE WAS READ

**L1 (`predL1_24.py`, SOURCE-keyed, a deliberate superset):** every test
directory with a selector chain of depth >= 2 assigned inside a `function`
body.  u2r: 6 directories (`BitSelectPartSelectInFunction`, `cva6_equiv`,
`func_local_array`, `ibex`, `jeras_union`, `rp32`).  Surelog: 25 directories
(`BitSelectPartSelectInFunction`, `DollarRoot`, `IndexPartSelectBind`,
`SplitFile`, `ThisHier`, `AVLMM`, `AmiqEth`, `Earlgrey_0_1`,
`Earlgrey_Verilator_01_05_21`, `Earlgrey_Verilator_0_1`, `Earlgrey_nexysvideo`,
`Ibex`, `IbexGoogle`, `IncompTitan`, `OVMSwitch`, `Opentitan`, `Rp32`, `Rsd`,
`Tnoc`, `UVMSwitch`, `Verilator`, `XilinxUnisimLibrary`, `ariane`, `rggen`,
`wav-lpddr-hw`).

**L2 (`predL2_24.py`, PRISTINE-DATABASE-keyed).**  The law changes exactly one
recognizer, and that recognizer can only newly accept a subroutine whose body
holds an `assignment` whose LHS is a `hier_path` of THREE OR MORE elements.
That is readable off the pristine dump: the function bodies are emitted in
every view and the LHS path is emitted as written.

* **u2r: 2 databases = 1 test x 2 modes — `jeras_union`.  All 1608 databases
  read, 0 errors, nothing skipped.**
* **surelog: 11 of OUR databases — `MiniAmiq`, `SeqDriver`, `BuildUVMPkg`,
  `SimpleUVM`, `SVSwitch` (both modes) and `Scoreboard`/default.  All 960
  `slang.uhdm` read, 0 errors, nothing skipped.**  The walk also met three
  GOLDEN-side `slpp_all/surelog.uhdm` artifacts left in the workdir: two
  flagged (`TestBatchMode`'s two class dirs) and one
  (`YosysOpenSparc`/default) exceeded the dump budget.  Our binary never
  writes those files, so none of the three can be a mover; they are reported
  rather than dropped.
* **POSITIVE CONTROL:** the same detector run over the grid's own PRISTINE
  dumps reports `n1 <- c.u.a c.u.b`, `n6 <- c.u.v.a c.u.v.b c.u.w`,
  `n9 <- c.n.x c.u.a c.u.b` and reports NOTHING for the three flat control
  arms `n10`, `n11`, `n12`.  A zero from this detector is a reading, not a
  silence.

### Why all six predicted names DECLINE, decoded and then measured

* `jeras_union` — its nested writes (`dec32.gpr.adr = …`, 13 of them) are to
  the IMPLICIT FUNCTION-NAME return variable, and `dec32` has no
  `return` statement at all; the recognizer's return-statement gate rejects it
  before the LHS is ever looked at.  No parameter in that design is
  initialized by it either.
* `MiniAmiq`, `SeqDriver`, `BuildUVMPkg`, `SimpleUVM`, `SVSwitch` — every
  flagged path is a CLASS or CLOCKING-BLOCK write inside a task/function body
  (`printer.knobs.full_name`, `m_if.cb.a`, `this.__m_uvm_status_container.status`,
  `qc.queue[index].selected`), never a packed-struct-returning function whose
  result initializes a parameter.  The return-type gate
  (`rt.kind != SymbolKind::PackedStructType`) rejects them.

**Measured (`byteverify.sh SELFCHECK=1`, patched vs this pass's OWN pristine
workdirs): u2r MOVERS 0 / 1608, both modes, selfcheck 1607 / 1608.  Not one
corpus database moved a byte.**  `jeras_union` is in that 0.

---

## 5. The directional census, and the shape lister beside it

Keyed directional census (`dircen24.py` over `pacen24.py`'s cells: kind,
`VpiDecompile`, `VpiSize`, `VpiConstType`, the value tag, and the Rhs
`ref_typespec`'s name and Actual — the judge-visible set, never a span, never
an id), golden vs pristine vs patched:

```
n1  SAME=4  TO=6  AWAY=0 MW=0 SW=0      n7   SAME=5  TO=5  AWAY=0 MW=0 SW=0
n2  SAME=6  TO=10 AWAY=0 MW=0 SW=0      n8   SAME=13 TO=8  AWAY=0 MW=0 SW=1
n3  SAME=5  TO=8  AWAY=0 MW=0 SW=1      n9   SAME=5  TO=4  AWAY=0 MW=0 SW=5
n4  SAME=6  TO=6  AWAY=0 MW=0 SW=0      n10  SAME=12 TO=0  AWAY=0 MW=0 SW=0
n5  SAME=4  TO=4  AWAY=0 MW=0 SW=4      n11  SAME=4  TO=0  AWAY=0 MW=0 SW=0
n6  SAME=5  TO=7  AWAY=0 MW=0 SW=0      n12  SAME=7  TO=0  AWAY=0 MW=0 SW=1
```

**TO-GOLDEN 58, AWAY-GOLDEN 0, MOVED-WRONG 0 over the whole grid.**  Every
STILL-WRONG cell is named in §7 and every one of them has a FLAT control arm
that carries the identical cell on BOTH binaries.

**SHAPE LISTER** (`shapes24.py`, the Rhs operand TREE to depth 3, beside the
cell census — a shape change that kept every cell would be invisible to the
census, and a cell change out of a different tree would be attributed wrong):

* patched vs PRISTINE: **every moved shape is `func_call -> constant` (the
  assembly, in both the def and the elaborated module listings) or
  `hier_path(…) -> constant` (the member-read fold)** — 32 shapes over the
  twelve arms and not one of any other kind;
* patched vs GOLDEN: the only non-SAME shapes are the DECLINES (`n5`'s `CG`
  struct_var, `n9`'s `d_t`) and two shapes that pristine already had
  (`n9`'s `N1` union-member read, which golden keeps a `hier_path` and we
  already folded; `n3`/`n12`'s `UU` assignment-pattern operand tree).  The
  shape lister is what caught `N1`: the cell census scored it SAME and only
  the tree said golden keeps a `hier_path` there.

### Coin attribution, ORDER-BLIND + POSITIVE CONTROL

Sorted, path-normalised, id-stripped `uhdm-dump`s of the four surelog movers:
`Scoreboard`/default **0** lines (a pure order flip); `MiniAmiq`/default,
`MiniAmiq`/testflags and `SeqDriver`/default **4** lines each, and each is one
`UINT:<n>` plus its `vpiDecompile` — the line-number class.

POSITIVE CONTROL: the PRISTINE binary, re-invoked on `MiniAmiq`/default,
produced **six distinct databases** across this pass (`e224d8fb352e` in the
sweep, then `125d2c5e6807`, `c0b161ae21ad`, `b780459cb83f`, `310e498603ef`,
`e9183812b66f`), none equal to another.  The family is pinned by NAME and by
the coin CLASS, never by the count.

Scoreboard, both corpora, both modes:

| corpus | mode | pristine | patched |
|---|---|---|---|
| uhdm2rtlil | default | 767 / 37 / 67 | 767 / 37 / 67 |
| uhdm2rtlil | testflags | 767 / 37 / 67 | 767 / 37 / 67 |
| Surelog suite | default | 469 / 14 | 469 / 14 |
| Surelog suite | testflags | 465 / 12 | 465 / 12 |

---

## 6. Head movement on the grid

| arm | pristine head | patched head |
|---|---|---|
| `n1` (= r11u21 `t9`) | 1 head / 7 lines — `pk::c_t.u`'s `Actual_value`, golden `UINT:32`, ours `<null>` | **0 heads, 0 lines, CMP_EQUAL** |
| `n2` | 1 / 7, the same leftover | **0 heads, CMP_EQUAL** |
| `n4` (module holder) | 1 / 7 | **0 heads, CMP_EQUAL** |
| `n3` | 1 / 7 | 1 / 36 — `nw_t.un`, golden `UU`'s own OPERATION, ours a re-encoded constant.  Object for object `n12`'s PRISTINE head |
| `n5` | 1 / 40 | 1 / 40, **the same object** — the def listing's assignment-pattern operand |
| `n6`, `n7` | 1 / 7 each | 1 / 14 each — the ELABORATED `cont_assign` Rhs `^{…}` fold, which our emitter reduces from slang's own parameter values and golden from the assembled ones |
| `n8` | 1 / 7 | 1 / 32 — the `.W(DEEP)` override actual's encoding |
| `n9` | 1 / 7 | 1 / 7 — the head MOVED from the union struct's leftover (supplied) to the array-write struct's (declined) |
| `n10`, `n11`, `n12` | 1 / 14, 0 / 0, 1 / 36 | **IDENTICAL, byte for byte** |

---

## 7. Residues

* **R0 — THE LEFTOVER OF A WHOLE READ OF A PATTERN PARAMETER.**  Grid `n12`
  (FLAT) and `n3`'s `nw_t.un`: `c.u = UU` with `localparam in_t UU = '{a: 11,
  b: 22}` leaves golden the parameter's OWN elaborated Rhs OPERATION object;
  the package arm's `paramRead` re-encode mints a constant of `UU`'s width and
  the drain's `elabParamConst` lookup has no operation to share.  The FLAT
  family's own gap — `n12` carries it identically on both binaries.
* **R1 — TWO BUILDERS, ONE STRUCT TYPESPEC.**  Grid `n10` (FLAT): golden's
  single shared typespec carries the LAST-EVALUATED parameter's leftovers and
  `stampEvalFuncLeftovers` takes the FIRST matching stamp (and the first
  writer per member).  Matching is by MEMBER-NAME LIST, so two DISTINCT
  typedefs with the same member names collide too.  Identical on both
  binaries; declined here because the fix lives inside the landed stamp drain.
* **R2 — A FIRST-LEVEL MEMBER THE BODY NEVER WRITES.**  Grid `n5`'s `mkGap`
  (FLAT): golden stamps the members it wrote and BAILS the assembly; our
  recognizer fails the whole builder and stamps nothing.  Identical on both
  binaries.
* **R3 — AN OVERRIDE ACTUAL THAT READS A SLICED MEMBER.**  Grid `n8`'s
  `.W(DEEP)`: golden `32'b…100000` `vpiBinaryConst` with the FORMAL's
  typespec, ours the plain `UINT:32`.  The § asmEncFollowsRef / elabOv road,
  one law out; STILL-WRONG, never MOVED-WRONG.
* **R4 — THE ELABORATED `cont_assign` Rhs FOLD.**  Grid `n6`/`n7`: our
  emitter reduces `^{M[0], V[0], A[0], D[0]}` from slang's own values of
  `M`/`V`/`A`/`D`, golden from the ASSEMBLED ones, and the two differ exactly
  where this law makes them differ (n6: golden 1, ours 0).  Every
  `param_assign` cell of those arms is golden-exact; only the cont-assign
  consumer is not.  ModuleEmit's territory, not ParamEmit's.
* **R5 — AN INDEXED WRITE (`c.arr[0] = 8'h5`).**  Grid `n9`'s `d_t`: golden
  stamps the LAST element write on the whole `arr` member (arr = 6) and
  assembles; we decline the builder outright, which leaves the database
  byte-identical.  The bit range of a packed-array element is its own rule.
* **R6 — A UNION-MEMBER READ.**  Grid `n9`'s `N1 = P1.n.x`: golden keeps the
  `hier_path` (its selector's constant arm needs a `struct_typespec` and a
  `union_typespec` is not one) and our pristine binary already folds it to a
  constant.  Pre-existing, untouched, and only the SHAPE LISTER sees it.

**R0 for the next pass: the leftover of a whole read of a PATTERN parameter
(`c.u = UU` with `localparam in_t UU = '{a: 11, b: 22}`).  Golden's
`typespec_member::Actual_value` IS that parameter's own elaborated Rhs
OPERATION object — shared, not re-encoded — and § pkgStructFuncAssembleBin's
`paramRead` arm mints a `UINT` constant of the parameter's width instead,
because `elabParamConst` only ever registers constants.  Grid arm `n12` is the
ready-made FLAT witness: 1 head / 36 cmp lines, IDENTICAL on the pristine and
the patched binary, and its five golden cells are tabulated by
`memcen24.py n12/gold.dump` and `pacen24.py n12/gold.dump`.**

---

## 8. Gates

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `5346c1e9` | `b46b0f3e573c5b435bb827c097e47091` — BYTE-IDENTICAL (the value the brief pins) |
| patched build md5 | `92ec4c93f430951bd8e2948b701b092e` |
| both binaries frozen `chmod 555` BEFORE any sweep | `/tmp/r11u24_pris.bin`, `/tmp/r11u24_law.bin` |
| `tests/check_goldens.sh` pristine / patched | 23 PASS / 0 FAIL on BOTH |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | PASS — every row byte-identical |
| u2r both modes vs `results/golden_uhdm2rtlil.csv` (mode-filtered) | PASS — every row byte-identical in each mode |
| u2r patched vs this pass's own pristine sweep, both modes | PASS in each mode |
| u2r scoreboard | 767 / 37 / 67 pristine -> 767 / 37 / 67 patched, both modes |
| surelog patched | 469/14 default + 465/12 testflags — identical to this pass's PRISTINE sweep AND to the committed baseline |
| surelog vs `results/golden_surelog.csv` and vs own pristine | FOUR rows differ against each, **0 status moves**: `LowMemLib`/tf and `LowMemPkg`/tf differ only in the WORKDIR PATH inside a `SURELOG_FAIL` detail string, and `Earlgrey_0_1` both modes differ only in the DUMP COLUMN (`differ` -> empty).  That column is a `uhdm-dump` TIMEOUT coin and is convicted as one: the two binaries write the **byte-identical** database (`59d0ee6d10c350970cd9f8960ebedc56` testflags, `8bdf25272e08e21c5e3f565612b5f6fe` default), and re-running the SAME row in a scratch workdir gives empty for the patched binary and `differ` for the pristine one over that one identical file |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1608**, selfcheck 1607 / 1608, path sets identical |
| `byteverify SELFCHECK=1` surelog | **MOVERS 4 / 960**, selfcheck 959 / 960, path sets identical — `MiniAmiq` x 2 modes, `SeqDriver`/default, `Scoreboard`/default: the PROVEN UVM COIN FAMILY and nothing else.  **No law mover on the surelog corpus at all** |
| `canaries.sh` u2r | ok=8 changed=0 |
| `ctcan2.sh` u2r | PASS (ok=1 changed=0) |
| `canaries.sh` / `ctcan2.sh` surelog | ok=50 changed=2 — and the two are `Earlgrey_0_1`'s dump-column timeout coin, named above / PASS ok=58 changed=0 |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` `4842211c4030`, `YosysVerx` `6ccda350c24a` — both modes, both binaries, the exact brief values.  `SVSwitch` is one of the six L2-flagged names and it did not move |
| STATUS pins | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a` default / `73a10e8217e5` testflags, `YosysOldOr` `d68e0796d62c` — byte-identical pristine vs patched, both modes |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched, line for line (12 measured, 2 SKIP-NOFILE as expected) |
| every `cmds.txt` audited BY BINARY PATH | 1531 surelog + 1742 u2r pristine rows name `/tmp/r11u24_pris.bin`, 1531 + 1742 patched rows name `/tmp/r11u24_law.bin`, and NOTHING names any other `slang-uhdm` |
| grid arms | 12 arms, every one `slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0` |
| fence check (the four slang-fenced tests) | 0 hits in the production diff; 0 hits in `tools/probe/r11u24repro/`; no driver dispatches them |
| `results/*.csv` | UNTOUCHED |
| patch applies clean on a FRESH `5346c1e9` worktree | yes — 0 conflicts, 0 `<<<<<<<` markers, and the applied source REBUILDS to the patched md5 `92ec4c93f430951bd8e2948b701b092e` |

---

## 9. Files

| file | what it is |
|---|---|
| `grid.sh` | the golden grid runner: Surelog v1.87 + both binaries + official `uhdm-cmp` per arm, every rc recorded |
| `n1`–`n12` | the grid arms (§2).  `n10`, `n11`, `n12` are the FLAT CONTROLS and `n5`'s `CG` / `n9`'s `d_t` the DECLINE halves; all three controls must stay byte-identical |
| `pacen24.py` | the KEYED cell census of every elaborated/definition `param_assign` Rhs |
| `memcen24.py` | the LEFTOVER census — every `typespec_member` carrying a value annotation, keyed by section x struct typespec x member |
| `dircen24.py` | the DIRECTIONAL census over the param cells (TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG) |
| `rowcen24.sh` | `dircen24.py` on named SWEEP rows against each row's own golden, read out of its `cmds.txt` |
| `shapes24.py` | the SHAPE LISTER — the Rhs operand tree beside the cell census |
| `predL1_24.py`, `predL2_24.py` | the a-priori mover predictions (source-keyed L1; pristine-database-keyed L2 with its positive control) |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary battery that RUNS here |
