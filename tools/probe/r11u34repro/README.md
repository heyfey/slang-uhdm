# r11u34 — how an assignment-pattern operation is stamped (the r11u29 triage's K7)

Base `3621c70e`.  Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`0445655ee7`), uhdm2rtlil v0.68.  Every golden in this directory
is a real Surelog v1.87 run (`arm.sh`), never a carried-forward framing.

---

## 0. THE TRIAGE'S K7 IS WRONG ON TWO OF ITS THREE ROWS — re-measured at the base

`tools/probe/r11u29repro/TRIAGE.md` §K7 says *"All three heads sit on an
`operation` with `vpiOpType:75`"*, that two of them are a missing
`vpiTypespec` and one an extra `vpiSize`, and that the three tests are
conversion candidates.  Re-measuring the six rows at `3621c70e` with the
pristine binary (`md5 eb63e166e8f297649e0cf6371e4f2be4`, byte-identical to the
main tree) refutes the first claim on one row and the last claim on all three.
The six `uhdm-cmp` logs are in `evidence/head.pris.*.cmp`; each run reports
**one** head (`grep -c '^LHS:'` = 1 on all six).

### `cfg_func_width_loop` (u2r, both modes) — the size half, CONFIRMED and located

```
LHS:
operation: , id:93, line:21:37, endln:21:44      |vpiOpType:75
   operands: constant 4 (size 64) , constant 3 (size 64)
RHS:
operation: , id:115, line:21:37, endln:21:44     |vpiSize:1   |vpiOpType:75
   operands: constant 4 (size 64) , constant 3 (size 64)
```

The head object is **not** the parameter's own pattern: it is the FIRST NESTED
pattern `'{4, 3}` of `package q`'s
`localparam enc_t [0:NF-1] ENC = '{'{4, 3}, '{3, 2}, '{2, 1}};`
(`dut.sv:21`), in the **elaborated package listing**.  Everything else about
the object agrees.  Ours also stamps the THIRD nested op (`'{2, 1}`, 21:55) and
not the middle one — `front()` and `back()`.  `vpiSize` is the judged field
(`operation::Compare`).

### `iface_zero_width_field` (u2r, both modes) — the typespec half, CONFIRMED, and the struct is NAMED

```
LHS:
ref_typespec: , id:90                      (no VpiName, no VpiFullName, no VpiParent)
  |vpiActual:  struct_typespec: (p::bus_t), id:2, line:7:11, endln:7:75
RHS: <null>
```

The triage calls this struct typespec "NAMELESS".  It is not: `p::bus_t` is the
name, and it is the same object our own emitter already writes for the typedef.
What is nameless is the **`ref_typespec`** — golden's op-level ref carries no
name, no fullname and no parent.  The owner is the **elaborated package `p`**
listing's `param_assign` Rhs for `localparam bus_t B = '{CTL:0, DAT:8, STS:0}`
(`dut.sv:8`), and behind the missing ref golden has also FLATTENED the pattern:
three bare `constant`s at **size 32** (the `int unsigned` member width),
where ours keeps three `tagged_pattern`s wrapping 64-bit constants.

### `typed_named_pattern` (u2r, both modes) — NOT a `vpiOpType:75` row at all

```
LHS:
ref_typespec: (work@typed_named_pattern), id:103
  |vpiParent:  operation: , id:102, line:22:35, endln:22:132
  |vpiFullName:work@typed_named_pattern
  |vpiActual:  struct_typespec: (q::op32_i_t), id:13, line:9:11, endln:15:4
RHS: <null>
```

Golden's `operation` id:102 is **`vpiOpType:67` (vpiCastOp)** over one
**`vpiOpType:33` (vpiConcatOp)** whose operands alternate (bare `ref_obj` named
for the member, value) — the shape the landed `§ castDefaultPatternConcat`
already describes, at a scope that law deliberately excluded (NAMED keys over a
STRUCT cast target, not `default:` keys over a predefined-integer one).  The
head is in the **definition** (`uhdmallModules`) listing, where ours emits
`vpiOpType:75` + `tagged_pattern`s and no typespec at all.  Our ELABORATED
listing already carries the identical ref (same fullname, same actual) — so
this row is not a missing stamp, it is a missing SHAPE, and it needs the
cast-typespec machinery plus the phantom member nets golden's concat operands
point at (`ref_obj -> logic_net work@typed_named_pattern.imm_11_0`).

### None of the three is a conversion candidate

Whole-dump diffs against golden at the base (`uhdm-dump`, workdir normalised,
banner dropped):

| test | diff lines | judged differences BEHIND the K7 head |
|---|---|---|
| `cfg_func_width_loop` | 332 | `logic_typespec` VpiName `q::mask_t` vs `mask_t`; an extra `ref_typespec (q::maxw::i)` on two of our `ref_obj`s; an extra `cont_assign` in `work@sub`; the design `Typespecs` vector |
| `typed_named_pattern` | 709 | the whole cast/concat shape in BOTH listings |
| `iface_zero_width_field` | 1557 | the flatten, plus the interface family |

So K7 is a **head** cluster, not a conversion cluster.  This pass takes the one
face whose producer road it could close end to end and states the other two as
decoded residues.

---

## 1. THE LAW — `§ pkgNestedPatElabNoExpandSize34`

> **The elaborated package listing of a pattern parameter that nothing resolves
> through the package scope carries no operand `vpiSize`.**

**Producer.**  The nested-operand size is `CompileHelper::adjustOpSize`
(Surelog v1.87 `src/DesignCompile/CompileHelper.cpp:5114-5203`), and its only
caller is `expandPatternAssignment` (`CompileHelper.cpp:5421`).  A PACKAGE
parameter reaches that call down exactly one road:
`CompileHelper::getValue`'s `pkg::NAME` arm
(`src/DesignCompile/CompileExpression.cpp:901-955`), which fetches the
package's own `param_assign`, runs `expandPatternAssignment` +
`reorderAssignmentPattern` on it IN PLACE, and hands back a clone.  The other
three callers cannot reach a package parameter: `DesignElaboration::
elaborateInstance_` (`DesignElaboration.cpp:2588-2637`) walks a MODULE's
`paParam_assignment` objects, `NetlistElaboration` walks instances, and
`UhdmWriter.cpp:2204` walks `cont_assign`s.  A package parameter nobody writes
as `pkg::NAME` therefore keeps its DEFINITION listing's operand sizes.

> **r11v34 CORRECTION.**  "Exactly one road" is not provable from the source.
> `expandPatternAssignment` has SIX call sites, and THREE of them are inside
> `CompileExpression.cpp`: `:941` (the `pkg::NAME` arm quoted above), `:1012`
> (a module INSTANCE's netlist `param_assigns`, matched by BARE name) and
> `:1114` (`component->getParam_assigns()`, matched by BARE name — and
> `component` IS the package for an expression compiled inside one).  The road
> is unique in every shape that could be MEASURED, which is what the law rests
> on: arms `r11v34repro/v1`, `v10` and `v11` aim a bare in-package constant
> read, a bare in-package WHOLE-name constant read and a wildcard-imported
> whole-name constant read at the same package parameter, and golden leaves all
> three unstamped.  See `tools/probe/r11v34repro/README.md` §2.

This is the same `getValue` arm the landed `§ patParamPatElem26v` cites for the
FLATTEN (`tools/probe/r11v26repro/README.md:56`) — K7's size half and r11u25's
flatten half are two fields of one producer call.

**Grid** (`g1.sv` … `g6.sv`, run with `arm.sh`; every arm `slrc=0`, `slerr=0`,
`ourrc=0`).  Each package declares
`localparam enc_t [0:2] PA = '{'{4,3},'{3,2},'{2,1}}` (a
`packed_array_typespec` target, so `adjustOpSize` takes its ELSE branch —
`Bits(whole)` = 192) beside
`localparam logic [1:0][1:0][3:0] PV = '{'{4'h1,4'h2},'{4'h3,4'h4}}`
(a `logic_typespec` target — `fullSize/innerSize` = 4).  Only the reader
changes.  Read with `pred.py` / `sz.py`:

| arm | the only reader of the package params | golden, ELAB package listing | pristine |
|---|---|---|---|
| `g1` | `q::PA[0].e` — scoped, SELECTED | PA front **192**, PD both ends **192**, PV **4**, PU **64** | 1 / 1 / 4 / — |
| `g4` | `q::PA` — scoped, whole | PA front **192**, PV **4** | 1 / 1 / 4 / 4 |
| `g2` | `PA[i].e` unqualified, inside the package's own function | **NOTHING** | 1 / 1 / 4 / 4 |
| `g3` | `PA[0].e` unqualified after `import q::*` | **NOTHING** | 1 / 1 / 4 / 4 |
| `g5` | `q::PA` written ONLY in a parameter declaration | **NOTHING** | 1 / 1 / 4 / 4 |
| `g6` | no reader at all | **NOTHING** | 1 / 1 / 4 / 4 |

`g2` is the corpus shape.  The pristine binary stamps the same four cells in
ALL SIX arms — it never asks who reads the parameter.

**The gate** (`§ pkgNestedPatElabNoExpandSize34`, `include/UhdmExporter.h`
flag `pkgPatNoExpand34` + predicate `pkgPatScopedRef34`, set in
`src/ParamEmit.cpp` beside `paramInitPkg`, read in `src/ExprEmit.cpp`'s
`SimpleAssignmentPattern` arm):

```
pkgPatNoExpand34 = inPackage && topView && !pkgPatScopedRef34(pkg, name);
...
else if (nestedOps9 && !wasInPattern && !(paramInitPkg && pkgPatNoExpand34))
```

It only ever REMOVES a stamp, and only in a package's elaborated listing.  The
`paramInitPkg` guard rides in front so a stale flag can never reach a module.

**Why a NEW predicate and not `hasScopedPkgRef`.**  `hasScopedPkgRef`
(`src/TypeEmit.cpp:7881`) records a `ScopedName` only when its RIGHT is a bare
`IdentifierName`; slang spells `q::PA[0].e` with an `IdentifierSelectName`, so
arm `g1` — where golden DOES stamp — was invisible to it, and the first build
of this law removed `g1`'s `12:43=4` cell, which golden has: **one AWAY cell,
caught by the grid before any sweep**.  `pkgPatScopedRef34`
(`src/TypeEmit.cpp`, beside its sibling) accepts the select form too.
`hasScopedPkgRef` itself is left untouched: it is the trigger of the landed
struct-flatten SCOPED-REFERENCE rule and widening it would move that
population.  The PARAMETER-DECLARATION exclusion is kept — arm `g5` measures it
for this law independently.

---

## 2. CENSUS, and the movers predicted BY NAME before the patched sweep

`pred.py` is the shape lister: for a whole `verify_golden.py` workdir it dumps
both sides of every test and reports each `|uhdmtopPackages:` pattern operation
that is NESTED inside another pattern operation and carries a `vpiSize` — the
exact cell the law removes.  Golden-vs-golden is read FIRST, and the census's
golden column is the POSITIVE CONTROL: on `g1` it finds 5 golden cells and on
`g4` 2, so a golden stamp is visible to the lister; a zero golden column in a
corpus is therefore a fact about the corpus, not about the instrument.

* uhdm2rtlil, default and testflags, over the pristine sweep of all 871 rows:
  **one test, `cfg_func_width_loop`, two cells per mode**
  (`line:21:37=1`, `line:21:55=1`), and **zero** golden cells corpus-wide
  (`evidence/CENSUS.pred.u2r.*.txt`).
* Surelog suite, both modes, over the pristine sweep of all 798 rows: **not one
  `O` line in either mode** — no test in that corpus has the cell on OUR side.
  The GOLDEN column is again non-empty, and this time in the real corpus rather
  than the synthetic grid: `Ariane2024/default` one cell (`line:21:7=70`) and
  `AzadiRTL` one cell in each mode (`line:263:17=2560`), so the instrument is
  demonstrably able to see a stamp here too.  `AmiqEth/default`'s golden dump
  timed out and is recorded as `TIMEOUT` rather than as a zero
  (`evidence/CENSUS.pred.surelog.*.txt`); it is not in the byteverify mover
  list either way.

PREDICTED MOVER SET, stated LOUDLY before the patched sweeps were scored:
**`cfg_func_width_loop` in both uhdm2rtlil modes, and NOTHING ELSE — zero
movers in the Surelog suite, both modes.**  Measured after: `byteverify.sh`
reports **MOVERS 2 / 1608** on uhdm2rtlil, and both are
`./default/cfg_func_width_loop-e717ba60/slang.uhdm` and
`./testflags/cfg_func_width_loop-e717ba60/slang.uhdm` — the prediction, name
for name, with nothing outside it.  On the Surelog suite `byteverify.sh`
reports 4 / 960, every one of them a UVM-family COIN proven by re-draw from the
UNCHANGED pristine binary (gate 5), and not one of them a test the census
names.

---

## 3. THE OTHER TWO K7 FACES — decoded, not landed

**`iface_zero_width_field` — an UNPACKED-struct package parameter flattens like
a packed one.**  Grid `u1.sv` puts three `bus_t` (an UNPACKED struct)
localparams in one package and varies only the reader:

| param | reader | golden, ELAB package listing |
|---|---|---|
| `BSEL` | `BSEL.DAT` — a member select, unqualified, inside the package | **typed + FLAT** (bare `ref_typespec` → `p::bus_t`, constants at 32) |
| `BSCP` | `p::BSCP.DAT` from a module — scoped | **typed + FLAT** |
| `BNON` | never read | **untyped, `tagged_pattern` tree kept** |

— the same trigger family (`hasMemberSelectOf` ∪ `hasScopedPkgRef`) the landed
packed-struct flatten already models.  `u2.sv` is the narrow (≤64-bit) control:
a never-read 32-bit struct, packed AND unpacked, keeps the tagged tree on both
sides, which is the landed SCOPED-REFERENCE rule doing its job.

Our blocker is one clause: `structPat` (`src/ParamEmit.cpp:12912`) requires
`pctS.kind == PackedStructType`, so an UNPACKED struct never enters the
flat-fold road at all — even though the road's own field walk
(`fsc9`, `src/ParamEmit.cpp:~13197`) already handles `UnpackedStructType`.
`pred2.py` censuses this face: over uhdm2rtlil the ELAB-package op-typespec
column differs on exactly **two** tests — `iface_zero_width_field` (the
unpacked-struct face) and `stamped_gen_param` (a PACKED-struct face, a
different sub-rule) — and both are already `CMP_NOTEQUAL`
(`evidence/CENSUS.tsface.u2r.default.txt`).  Left unlanded here because it
converts nothing and opens a new population; it is R0.

**`typed_named_pattern` — `T'{named keys}` over a STRUCT target.**  Decoded in
§0: golden's shape is `vpiCastOp(67) -> vpiConcatOp(33)` with the member names
as bare `ref_obj`s bound to phantom `logic_net`s, in BOTH listings, carrying
the cast target's `ref_typespec`.  This is `§ castDefaultPatternConcat`'s own
13-row golden matrix at the scope that law names and excludes.  It is a shape
change, not a stamp, and it needs the phantom-net mint; R1.

---

## 4. GATES — all green

Binaries frozen at immutable paths before any sweep; every `cmds.txt` audited
by binary PATH.

1. **BUILD.**  PRISTINE `md5 eb63e166e8f297649e0cf6371e4f2be4` — byte-identical
   to the main tree's `build/slang-uhdm` at `3621c70e`.  PATCHED
   `md5 a7a1468f0d81ca9a1f62fc36c2da899a`, 0 errors.  The tree was rebuilt once
   more after two comment-only corrections and came back
   `a7a1468f0d81ca9a1f62fc36c2da899a` again, so the DELIVERED tree is bit-for-bit
   the tree every gate below ran on.
2. **GOLDENS.**  `tests/check_goldens.sh` PASS 23 / FAIL 0.  Negative control
   `SLANG_UHDM=/bin/false` FAIL 23 / PASS 0.
3. **uhdm2rtlil, both modes** (own pristine sweep + committed baselines).
   Status: 772 CMP_EQUAL / 32 CMP_NOTEQUAL / 67 SLANG_REJECT in each mode —
   the baseline exactly.  `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv`
   *PASS: every row byte-identical*; vs the own-pristine testflags and default
   CSVs *PASS* both; a name+status diff against both mode-halves of
   `results/golden_uhdm2rtlil.csv` is **0 differing rows**.
4. **Surelog suite, `--mode both`.**  default 474 CMP_EQUAL / 9 CMP_NOTEQUAL,
   testflags 469 / 8 — the baseline exactly, and the per-mode status histograms
   are identical to the own-pristine sweep in every bucket.  `ct8rows.sh`
   against the own pristine sweep flags **two** rows, both quoted here and both
   the workdir path inside a golden-side failure message, status unchanged:

   ```
   < LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/r11u34_pris/sl/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
   > LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/r11u34_pat/sl/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
   < LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/r11u34_pris/sl/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   > LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/r11u34_pat/sl/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   ```

   Against the COMMITTED `results/golden_surelog.csv` two more rows appear, also
   quoted, also not this pass's:

   ```
   < Earlgrey_0_1,default,CMP_EQUAL,,,differ      > Earlgrey_0_1,default,CMP_EQUAL,,,
   < Earlgrey_0_1,testflags,CMP_EQUAL,,,differ    > Earlgrey_0_1,testflags,CMP_EQUAL,,,
   ```

   — the dump COLUMN reading blank on a `uhdm-dump` timeout draw.  The STATUS is
   `CMP_EQUAL` in both modes, and the blank is present identically in this
   pass's own PRISTINE sweep, so it is a property of this machine's sweeps and
   not of the patch.  The DATABASE byte-compare, which is the pin, is exact:
   see gate 6.
5. **byteverify, `SELFCHECK=1`, against this pass's own pristine workdirs.**
   * uhdm2rtlil: PATH_SETS_IDENTICAL (1608), **MOVERS 2 / 1608**, both
     `cfg_func_width_loop` — the predicted set, name for name.  SELFCHECK
     1607/1608 flagged.
   * Surelog: PATH_SETS_IDENTICAL (960), MOVERS 4 / 960 — `MiniAmiq` (both
     modes), `SeqDriver/default`, `SimpleUVM/default`.  SELFCHECK 959/960.
     **All four are the documented UVM-family pristine nondeterminism, and the
     attribution is by re-draw, not by assertion.**  Running the PRISTINE binary
     itself, three consecutive times, on the sweep's own command line:
     `MiniAmiq` → `27419f6011b4`, `11a21fd1078a`, `81c610fe0802` — three
     different hashes from one unchanged binary, none of them the sweep's
     `8188819b0d63`; `SeqDriver` → `0029af0e23ed`, `2fb39f8b4130`,
     `2fb39f8b4130`; `SimpleUVM` → `49d8efe2729b` three times, which is the
     PATCHED sweep's draw, while the PRISTINE sweep had drawn `6e38ebb21893`.
     The LAW binary flips the same coin: `SimpleUVM` → `49d8efe2729b`,
     `49d8efe2729b`, `8df4b11d7e79` (sizes 11240328 / 11240328 / 11240330).
     The order-blind sorted-dump diff on each of the four is the 4-line class
     (`SimpleUVM`: `UINT:0`/`vpiDecompile:0` against `UINT:955`/
     `vpiDecompile:955` — the macro-buffer line-number face).  Their STATUS is
     `CMP_EQUAL` in both modes on both sweeps, which is what the family's pin
     requires.
   * Both corpora: **MOVED-WRONG 0, AWAY-GOLDEN 0.**  On the golden grid,
     scored cell by cell against golden: g2 TO 6 / AWAY 0, g3 TO 4 / AWAY 0,
     g5 TO 4 / AWAY 0, g6 TO 4 / AWAY 0, and g1 / g4 (the READ face) TO 0 /
     AWAY 0 — untouched by construction.
6. **Protected databases, by name, patched vs own pristine** — every one SAME:
   `SVSwitch 4842211c4030` (both modes, the hard byte pin),
   `YosysVerx 6ccda350c24a` (both modes, the hard byte pin),
   `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex` (default
   `e3e354129d5a`, testflags `73a10e8217e5`), `YosysOldOr d68e0796d62c`,
   `Earlgrey_0_1` default `8bdf25272e08` and testflags `59d0ee6d10c3` — the two
   Earlgrey pins the brief names, hit exactly.
7. **Canaries.**  `canaries.sh` patched-vs-own-pristine: surelog `ok=52
   changed=0`, uhdm2rtlil `ok=8 changed=0`.  (Against the committed surelog CSV
   the only two "changes" are the Earlgrey dump-column blanks of gate 4.)
   `ctcan2.sh` PASS on both corpora.  `canaudit.sh canaries.sh ctcan2.sh` —
   `audited=29 UNCOVERED=0 FENCE-BREACH=0`.
8. **rowheads** on the converted families, patched workdir: `SeqDriver`,
   `SimpleUVM`, `Scoreboard/default`, `MiniAmiq`, `BuildUVMPkg`,
   `Earlgrey_0_1` — every one `0 cmp lines, 0 heads, rc=0`.  SKIP-NOFILE on
   `Scoreboard/testflags` and `Rggen/testflags` is the expected pair.
   `Rggen/default` is `CMP_NOTEQUAL` on the committed v1.87 baseline, on this
   pass's pristine sweep and on its patched sweep alike.
9. **`results/*.csv` untouched** — `git status` shows four modified sources and
   one untracked probe directory, nothing else.

## 5. WHAT MOVED, AND WHAT DID NOT

`cfg_func_width_loop`'s K7 head is GONE in both modes.  The row does NOT
convert — it was never going to; the next head is a different face and is this
pass's R0:

```
LHS: <null>
RHS:
ref_typespec: (q::maxw::i), id:195
|vpiParent:  ref_obj: (q::maxw::i), id:194, line:31:20, endln:31:21
|vpiActual:  int_typespec: , id:41, line:23:42, endln:23:45
```

— an op-level `ref_typespec` we mint on a function-body `ref_obj` (`fwidth(i) >
res`, `dut.sv:31`) that golden does not carry.  `iface_zero_width_field` and
`typed_named_pattern` are byte-unchanged, heads unchanged (`evidence/head.law.*`
against `evidence/head.pris.*`).

Scoreboard:  uhdm2rtlil 772/32/67 both modes, surelog 474/9 + 469/8 — unmoved.
This pass buys one head on two rows, a corrected K7, and two decoded residues.

## 6. RESIDUES

* **R0 — `cfg_func_width_loop`'s next head**: the extra
  `ref_typespec (q::maxw::i)` on a function-body `ref_obj`, quoted above.
  Behind it, in the same 332-line dump diff: `logic_typespec` VpiName
  `q::mask_t` (golden) vs `mask_t` (ours) in the elaborated module listing; an
  extra `cont_assign` in `work@sub`; the design-level `Typespecs` vector.
* **R1 — the K7 TYPESPEC half, unpacked-struct face.**  `structPat`
  (`src/ParamEmit.cpp:12912`) refuses an UNPACKED struct, so
  `localparam bus_t B = '{CTL:0, DAT:8, STS:0}` never enters the flat-fold road
  even though the road's field walk already handles `UnpackedStructType`.  Grid
  `u1.sv`/`u2.sv` fix the polarity (member-select OR scoped read → typed+flat;
  unread → tagged; narrow-and-unread → tagged, packed and unpacked alike).
  Corpus population, from `pred2.py`: two uhdm2rtlil tests,
  `iface_zero_width_field` (this face) and `stamped_gen_param` (a PACKED-struct
  face of the same column), both already `CMP_NOTEQUAL`.
* **R2 — the K7 TYPESPEC half, cast face.**  `T'{named keys}` over a STRUCT
  target must be `vpiCastOp(67)` over `vpiConcatOp(33)` with the member names as
  bare `ref_obj`s bound to phantom `logic_net`s, in BOTH listings, carrying the
  cast target's ref — `§ castDefaultPatternConcat` at the scope it names and
  excludes.  A shape change plus a phantom-net mint, not a stamp.
* **R3 — the POSITIVE half of this law, unlanded.**  On the READ face (grid
  `g1`/`g4`) golden's stamp is `adjustOpSize`'s per-branch value and ours is
  not: a `packed_array_typespec` target takes the ELSE branch and stamps
  `Bits(whole)` (PA → **192**) where our `total/innermost` formula answers 1;
  only the `logic_typespec` branch (PV → 4) matches our formula.  Golden also
  REORDERS a scoped-read package pattern (PD, PV) where we do not, and stamps
  BOTH ENDS on PD but only the source-first operand on PV — consistent with
  `expandPatternAssignment` running once before and once after
  `reorderAssignmentPattern` on one and only once on the other.  No corpus cell
  is on this face (the census finds zero package parameters with both a nested
  pattern operand and a scoped `pkg::` read), which is why it is a residue and
  not a law here.
