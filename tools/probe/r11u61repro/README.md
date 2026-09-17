# r11u61 — every operand of a flat ELABORATED struct pattern is sized at its member's width, not only the first

Base `2a4ac214` (v1.87 pass 59).  Pins per `SUPPORT_MATRIX.md`: slang
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 (`0445655ee7`), uhdm2rtlil corpus v0.68.
Every golden in this directory is a real Surelog v1.87 run through `arm.sh`;
every arm records `slrc`/`ourrc`/`slerr`, and no framing is carried forward from
an earlier pass's write-up — the head, the residue and the two binaries' md5s
were all re-measured here.

Target: r11u60's **R0**
([tools/probe/r11u60repro/README.md:333](tools/probe/r11u60repro/README.md#L333))
— the standing head of `iface_zero_width_field`, one level out from the
definition-view import copy that pass 59 landed.

**THE ROW CONVERTS.**  `iface_zero_width_field` is `CMP_EQUAL` in BOTH modes,
0 cmp lines, 0 heads, `uhdm-cmp` rc 0.  The prediction written down before the
patch said ADVANCE, not CONVERT, and it was WRONG; §0 says why, in the terms it
was wrong in.

---

## 0. THE HEAD AND THE SECTIONED RESIDUE, RE-MEASURED AT `2a4ac214`

Pristine binary `md5 9452577e1d0e0d64f87e78ad6e3b3cd6` — built in this pass's
own worktree and byte-identical to the main tree's `build/slang-uhdm` at
`2a4ac214`, which is the hash the brief states.

`iface_zero_width_field`, **both** modes, one head per run
(`grep -c '^LHS:'` = 1), 18 cmp lines each.  Full logs
`evidence/head.pris.{default,testflags}.cmp`:

```
LHS:                                    RHS:
constant: , id:715, line:8:37           constant: , id:517, line:8:37
|vpiParent: \_operation: , id:702       |vpiParent: \_operation: , id:515
|vpiDecompile:8                         |vpiDecompile:8
|vpiSize:32                             |vpiSize:64
|UINT:8   |vpiConstType:9               |UINT:8   |vpiConstType:9
```

`8:37` is `DAT:8` — the **second** operand of
`localparam bus_t B = '{CTL:0, DAT:8, STS:0}` (`dut.sv:8`).  Operand 0
(`CTL:0`, col 30) is 32 on both sides; operands 1 and 2 are golden's member
width 32 and our unsized 64.  (r11v60 recorded that in TESTFLAGS mode this cell
was MASKED by a design-level vector head at base `00608fe8`.  Re-measured at
`2a4ac214` that mask is gone: both modes head here, and both head texts are in
`evidence/`.)

The SHAPE LISTER (`shape.py`, over the row's own workdir databases, and here
made **encoding-visible** — see §4) puts every remaining cell in one place:

| listing | golden | pristine |
|---|---|---|
| `uhdmallPackages p::B` (DEF) | tagged | tagged ✔ |
| `uhdmtopPackages p::B` (ELAB) | flat 32/32/32 | flat 32/32/32 ✔ (pass 48) |
| `uhdmallInterfaces work@my_if.B` | flat 32/32/32 | flat 32/32/32 ✔ (pass 59) |
| `uhdmallModules work@pass.B` / `work@top.B` | flat 32/32/32 | flat 32/32/32 ✔ (pass 59) |
| `uhdmtopModules` ×6 copies | flat 32/32/32 | flat 32/**64**/**64** |

The ORDER-BLIND whole-dump distance at the base is **527** lines (identical in
both modes), and the sectioned split says where it lives — `evidence/RESIDUE.sectioned.txt`:

```
uhdmallPackages 0   uhdmallInterfaces 0   uhdmallModules 0   uhdmallClasses 0
uhdmtopPackages 5   uhdmtopModules  520   PRE 2 (the dump's own file-path header)
```

and the 520 splits into four named classes, counted line by line:

```
SIZE  24   the head: 12 x |vpiSize:32 (golden) vs 12 x |vpiSize:64 (ours)
CLONE 362  golden CLONES the struct_typespec per elaborated copy; we share one
CA     82  the elaborated cont_assign multiplicity (pass 54/55 ground)
PARAM  15  the `B.CTL` member select rendered as ref_obj(B)+ref_obj(CTL)
OTHER  37  27 stray |vpiParent: prints, 4 fused ref_obj names, 2 logic_net names
```

**THE PREDICTION, and how it was wrong.**  Written down before the patch: *this
ADVANCES, it does not CONVERT — closing SIZE leaves 503 of the 527 lines, so the
row stays `CMP_NOTEQUAL`.*  That arithmetic is right and the conclusion is
wrong, because it silently assumed the dump distance is what the judge reads.
It is not.  `uhdm-cmp` compares `VpiType` / `VpiName` / `VpiDefName` plus the
per-kind fields, and **no generated `Compare` reads `VpiParent` or
`VpiFullName`** (RESUME.md §9).  CLONE is object SHARING and instance-scoped
`vpiFullName`s; CA is parent multiplicity; PARAM and OTHER are fullnames and
parent prints.  All 496 surviving lines are INVISIBLE to the judge, and the 24
SIZE lines were the whole of what it could see.  Measured after:

```
              pristine   law
uhdmtopModules   520  ->  496     (SIZE 24 -> 0; CLONE/CA/PARAM/OTHER unmoved)
uhdmtopPackages    5  ->    5     (§7 R3 = pass 59's own R1, untouched)
whole dump       527  ->  503
uhdm-cmp     18 lines ->    0     CMP_NOTEQUAL -> CMP_EQUAL, BOTH MODES
```

(`evidence/head.law.{default,testflags}.cmp` are EMPTY FILES by construction:
`uhdm-cmp` writes its head to stderr and had nothing to write.  Both were
produced by the same command line as the pristine pair beside them, and both
runs exited 0.)

**THE CONVERSION, quoted from the committed baselines.  `results/*.csv` is NOT
edited by this pass** — the master promotes these rows:

```
results/golden_uhdm2rtlil.csv:377   iface_zero_width_field,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:1248  iface_zero_width_field,testflags,CMP_NOTEQUAL,decompile:,,
results/gate_uhdm2rtlil.csv:377     iface_zero_width_field,testflags,CMP_NOTEQUAL,decompile:,,
```

become

```
iface_zero_width_field,default,CMP_EQUAL,,,differ
iface_zero_width_field,testflags,CMP_EQUAL,,,differ
```

The `dump` column reads `differ`, not `match`: the 503 judge-invisible lines
are still there, and they are this pass's R0 (§7).

---

## 1. THE PRODUCER, read in the pinned Surelog and UHDM

An instance's parameter whose value is an assignment pattern is DEEP-CLONED per
instance and then reduced —
`src/DesignCompile/NetlistElaboration.cpp:261-283`:

```cpp
if (opType == vpiAssignmentPatternOp || opType == vpiMultiAssignmentPatternOp) {
  param_assign* pclone = (param_assign*)UHDM::clone_tree(mod_assign, &elaboratorContext);
  ...
  if (m_helper.substituteAssignedValue(rhs, m_compileDesign)) {
    rhs = m_helper.expandPatternAssignment(ts, (expr*)rhs, mod, m_compileDesign, instance);
  }
```

`substituteAssignedValue` (`src/DesignCompile/CompileExpression.cpp:83-105`)
answers the command-line `parametersubstitution` flag for a pattern op and
recurses into the operands, so on a default run it is TRUE for every elaborated
pattern.  **No member-select, scoped-reference or import predicate is involved
at this face at all** — unlike the DEFINITION face that pass 59 decoded, where
the trigger is which reduce already ran.

`expandPatternAssignment` (`src/DesignCompile/CompileHelper.cpp:5207`) first
flattens (`ExprEval::flattenPatternAssignments`, `UHDM/templates/ExprEval.cpp:751`,
which strips the `tagged_pattern` wrappers and re-parents the operands), and its
UNTAGGED arm (`CompileHelper.cpp:5409-5441`) then walks them:

```cpp
for (any* op : *operands) {
  expr* cop = (expr*)op;
  expr* vexp = reduceExpr(cop, invalidValue, ...);
  uint64_t v = eval.get_uvalue(invalidValue, vexp);
  int32_t csize = adjustOpSize(tps, cop, opIndex, rhs, ...);
  if (invalidValue) { return result; }          // <- AFTER the size is written
  ...
  int shift = (csize - 1 - i);
  if (shift < 0 || shift >= 64) { return result; }   // <- the >64-bit bail
  opIndex++;
}
```

and `adjustOpSize` (`CompileHelper.cpp:5114-5158`) matches `index == opIndex`
against the struct typespec's MEMBERS and writes
`cop->VpiSize(Bits(member_typespec))`.

> **THE RULE: operand *i* is sized at member *i*'s width, for EVERY *i* up to
> and INCLUDING the first operand that does not reduce.**

The committed *"a re-emitted OUTERMOST pattern sizes its FIRST operand"* stamp
in `src/ExprEmit.cpp` is the SPECIAL CASE of this walk in which operand 0 is a
`hier_path` that never reduces: `adjustOpSize` runs before the `invalidValue`
bail, so exactly one operand is sized.  That stamp is right where it was
measured and this pass does not widen it — the elaborated cont_assign face
(pass 54/55 ground) is not touched by one line of this patch.

The per-copy typespec CLONE is the same producer's other half, and it is
decoded here without being implemented (§7, R0): `clone_tree(mod_assign)` gives
each instance its own `param_assign`, Surelog's own comment at
`NetlistElaboration.cpp:300-307` says *"flattenPatternAssignments below clones
the pattern operation AND its struct typespec"*, and `ExprEval.cpp:928-932`
mints a FRESH `ref_typespec` per flatten.  Golden therefore carries 4 more
`struct_typespec` objects, 12 more `typespec_member`s and 12 more
`int_typespec`s than we do on this one test — and `uhdm-cmp` cannot see any of
it, which is why it is a residue and not this law.

---

## 2. THE LAW — `§ elabUnpStructOperandWidth61`

> **In the ELABORATED view of a module or interface, a struct-pattern parameter
> whose type is an UNPACKED struct enters the same flat op75 walk the packed
> one already uses: one operand per member, folded, each sized at ITS member's
> width — unless one of the six fences of §3b declines it.**

The fences, all of which only ever turn the law OFF, so none of them can mint an
AWAY cell: a non-integral or `time` member, a member wider than 64 bits, a
pattern-valued element, `typeSetters`/`indexSetters`, a CONCAT or REPLICATION
member value, and an OVERRIDDEN parameter.  §3b measures each on golden.

Why only the UNPACKED struct, measured rather than assumed.  A PACKED struct's
elaborated copy already reaches that walk through `structPat`, which sizes every
operand — grid arm `h2` (four packed members at 4/12/33/6 bits × plain / based /
enum / concat / replication / default / positional values) is **byte-identical
to golden on the PRISTINE binary in every cell**.  Its unpacked twin `h3` (the
same sweep over `byte` / `shortint` / `int` / `longint`) is wrong in EVERY cell:

```
             golden                              pristine
UPLAIN   8 / 16 / 32 / 64                    8 / 64 / 64 / 64
UBASED   BIN:11@8  HEX:AB@16  ..@32  BIN:101@64   BIN:11@8 HEX:AB@8 ..@4 BIN:101@3
UENUM    8 / 16 / 32 / 64                    8 /  6 / 64 /  6
UCAT     8 / 16(BIN) / 32 / 64               8 / op33 / 64 / 64
UREP     8 / 16 / 32(BIN) / 64               8 / 64 / op34 / 64
UDEF     8 / 16 / 32 / 64                    8 / 64 / 64 / 64
UPOS     8 / 16 / 32 / 64                    8 / 64 / 64 / 64
```

It is a THIRD separate disjunct in the same `if`, for the same reason pass 59's
was one: `unpPkgPat49` stays `inPackage`-only (widening it double-emits on the
elaborated road, r11u49 arms `a2`/`a6`), and `structWidePkg` /
`structModDefTagged9` keep deciding the faces they own.  The scope is
`topView && !defViewOrig9 && !inPackage && !funcScope` — the genuine elaborated
view of a module or interface, never the pass-59 definition copy (whose
`topView` is FLIPPED, which is what `defViewOrig9` exists to tell apart), never
the pass-57/58 elaborated package listing.

**`hasMemberSelectOfInPkg` is NOT read at this face, and that is measured, not
assumed.**  Arm `h6` carries one unpacked struct through an imported package
parameter, a module localparam, an interface localparam, a parameter PORT, an
OVERRIDDEN parameter port and two generate-block localparams, and golden sizes
every operand of every one.  The pass-59 trigger and its three fences answer a
question — "did the package's own reduce already run?" — that this face does not
ask: here the reduce runs per instance, unconditionally.

---

## 3. THE GOLDEN GRID — 6 arms, scored cell by cell

`score60.py` joins golden / pristine / law per `(listing, parameter, loc)` and
classifies TO / AWAY / MOVED-WRONG / STILL / SAME.  Full output:
`evidence/GRID.score.txt`.

```
ARM h1   TO 8   AWAY 0   MOVED-WRONG 0   STILL 0   SAME 10  MISSING 0
ARM h2   TO 0   AWAY 0   MOVED-WRONG 0   STILL 2   SAME 12  MISSING 0
ARM h3   TO 5   AWAY 0   MOVED-WRONG 0   STILL 2   SAME 7   MISSING 0
ARM h4   TO 0   AWAY 0   MOVED-WRONG 0   STILL 1   SAME 11  MISSING 6
ARM h5   TO 1   AWAY 0   MOVED-WRONG 0   STILL 2   SAME 7   MISSING 3
ARM h6   TO 9   AWAY 0   MOVED-WRONG 0   STILL 2   SAME 8   MISSING 4
GRID TOTAL over 6 arms:  TO 23   AWAY 0   MOVED-WRONG 0   STILL 9   SAME 55   MISSING 13
```

Every arm `slrc=0 ourrc=0 slerr=0` on both binaries.  The 13 MISSING keys are
golden's extra per-instance `param_assign` prints (the CLONE half, R0) and
`h6`'s two generate-block copies, which we do not emit at all — all pre-existing
and all unmoved.

### 3a. HOLDERS x COPY COUNTS x OVERRIDE (`h6`) — none of them decides anything

| holder | golden ELAB copy | pristine | law |
|---|---|---|---|
| imported package param `p6::PK`, in the top module | 8/16/32 | 8/64/64 | 8/16/32 ✔ |
| the same, in each of two child instances | 8/16/32 | 8/64/64 | 8/16/32 ✔ |
| module localparam `TOPL` / `CH` | 8/16/32 | 8/64/64 | 8/16/32 ✔ |
| interface localparam `IF`, in the instance | 8/16/32 | 8/64/64 | 8/16/32 ✔ |
| parameter PORT `c0.PP` (default) | 8/16/32 | 8/64/64 | 8/16/32 ✔ |
| parameter PORT `c1.PP` (OVERRIDDEN) | 8/16/32, values 16/17/18 | 8/64/64, values 7/8/9 | DECLINED |
| generate-block localparam `gb[0..1].GL` | 8/16/32 | **absent** | absent |

and `h1` adds the corpus shape itself — one package-selected unpacked struct
through an interface, two interface instances, two module instances and the
port-bound interface view — 8 cells, all TO golden.

### 3b. THE BAIL, with UNBASED literals so a size can never be misread (`h5`)

One module, five structs `{byte b8; X; shortint s16}`, every value written `2`:

| X | golden | verdict |
|---|---|---|
| `shortint` (the control) | 8 / **16** / **16** | the walk COMPLETES — the law's cell ✔ |
| `logic [95:0]` | 8 / **96** / 64 | sized, then `shift >= 64` bails: operand 3 keeps 64 |
| `time` | 8 / 64 / 64 | sized, then bails |
| `string` | 8 / **8** / 64 | sized at the string's own width, then bails |
| `real` | 8 / **32** / **16** | NO bail — but `Bits(real)` is 32, not the 64 a `getBitWidth()` walk writes |

`h4` adds the two NESTED shapes — a PATTERN-VALUED member and an
UNPACKED-ARRAY member — where golden keeps the inner `op75` as the operand and
bails on it, and where **the pristine binary already agrees with golden**.

Every one of those five is DECLINED by a fence, so each right cell stays right
and each wrong one stays wrong rather than being modelled wrong:

| fence | why | cell left behind |
|---|---|---|
| any member not integral, or `time` | golden bails; a `getBitWidth()` walk would write 64 where `Bits` writes 32 (`real`) or drop a member entirely | `h4` `REAL4`, `h5` `BR` STILL |
| any member wider than 64 bits | the per-bit loop's `shift >= 64` bail | `h5` `BW` STILL |
| a PATTERN-VALUED element (`patParamPatElem26v`) | golden keeps the inner op75; we already match | `h4` `NEST` / `ARR4` SAME |
| `typeSetters` / `indexSetters` | inherited verbatim from pass 48; never widened | — |
| a CONCAT or REPLICATION member value | §4 | `h3` `UCAT` / `UREP` STILL |
| an OVERRIDDEN parameter | §4 | `h6` `c1.PP` STILL |

---

## 4. THE TWO REGRESSIONS THE FIRST CUT PRODUCED, AND THE BLIND INSTRUMENT THAT HID ONE

Recorded as they happened, not as a finished fence table.  Three binaries were
built in sequence: the first cut, the enum fix, and the shipped one with the two
fences of §3b's last two rows.  Everything measured in this README is the third
(`md5 7f8134d354a92dfe46c7381b7295557e`).

**(a) `rp32_r5p_alu` and `rp32_r5p_wbu` went CMP_EQUAL -> CMP_NOTEQUAL**, both
modes, on the first law binary — a measured corpus regression, caught by the row
gate.  Head:

```
LHS golden  constant 18:34  |vpiDecompile:23'b01000000000000000000000 |vpiSize:23 |BIN:0100... |vpiConstType:3
RHS ours    constant 18:34  |vpiDecompile:2097152                     |vpiSize:23 |UINT:2097152 |vpiConstType:9
```

`wrap.sv:18` is `localparam isa_t ISA = '{spec: RV32I, priv: MODES_NONE}` with
`isa_t` an UNPACKED struct of two PACKED structs, so the law fires; `RV32I` is
an enum member whose own initializer is `{RV_32I, RV_NONE}` — a CONCAT with no
literal form.  The walk's enum arm admits `inPackage || isImported ||
enumMemberLiteralForm(...)`, all three false here, so the member fell through to
the generic UINT fold.  The answer was already written down beside the
`reemitting` road in `src/ExprEmit.cpp` — an expression-initialized enum member
at a MODULE-OWN site folds to the BIN STRING AT THE MEMBER WIDTH (`enumFold6`),
and handing back `enumConstMap`'s source text regressed these same two rows once
before.  `§ elabModOwnEnumBinFold61` reproduces that form on this road; the
rows return to CMP_EQUAL and `h3`'s `UENUM` (a literal-form member, which golden
writes as `vpiIntConst 9` at the member width) is untouched by it.

**(b) THE SHAPE LISTER WAS BLIND TO ENCODING.**  `shape.py` printed a constant
operand as `const/<size>` only.  With that lister the first cut's grid read
`TO 26 AWAY 0 MOVED-WRONG 0 STILL 4` — green, and WRONG, because it could not
see a UINT written where golden wrote a BIN of the same width, which is exactly
the shape of regression (a): the row gate found that one, the grid did not.
This pass's copy of `shape.py` prints `const/<size>@<vpiConstType>=<VALUE>`, and
re-scoring the SECOND binary (the one with the enum fix, on which the corpus was
already clean) with it immediately named three MOVED-WRONG cells the size-only
lister had scored SAME or TO:

```
h3 UCAT  golden const/16@3=BIN:10100101          law const/16@3=BIN:0000000010100101
h3 UREP  golden const/32@3=BIN:111               law const/32@3=BIN:00000000000000000000000000000111
h6 c1.PP golden UINT:16 UINT:17 UINT:18          law UINT:7 UINT:8 UINT:9 (right sizes, wrong values)
```

The first two are a PRE-EXISTING residue of the shared walk, not of this law:
`adjustOpSize` calls `adjustUnsized`, which re-encodes an UNSIZED constant only,
and then `cop->VpiSize(ncsize)` — so golden keeps the reduce's RAW digit string
and merely rewrites the size, while this walk's concat/replication arms write
the ZERO-PADDED string.  Grid arm `h2`'s `WCAT` and `WREP` carry that same
mismatch identically on the pristine and the law binary (the PACKED road, which
this pass does not touch), which is how it is known to be older than this law.
Both are FENCED rather than joined.  The third is the override-substitution gap
of §3a, also fenced.  Final grid: **MOVED-WRONG 0, AWAY 0**.

---

## 5. CENSUS, and the movers predicted BY NAME before the patched sweeps

Two instruments, both reading PRISTINE databases only.

`cen61.py` is the shape lister over a whole `verify_golden.py` workdir,
restricted to the ELABORATED listings, with three columns: golden's typed-flat
count (the POSITIVE CONTROL), the law's cell (golden typed+flat, ours
different), and the RISK bound (every other ELAB-listing op cell where the two
sides already AGREE — the complete AWAY exposure).

`pred61.py` is the A-PRIORI predictor and reads NO golden at all: an
ELAB-listing op75 over a struct typespec that `uhdm-dump` prints WITHOUT
`|vpiPacked:1` — the database mirror of the law's `UnpackedStructType` fence.

**uhdm2rtlil, both modes.**  Positive control non-zero, so a small law column is
a fact about the corpus and not about the instrument:

```
== ALLCTRL(golden typed-flat, every listing)=227  GCTRL(ELAB listings)=219
== LAWCELLS=7 on 2 tests  RISK(must not move)=447        [identical in both modes]
== LAW TESTS: cva6_struct_param_field iface_zero_width_field
```

Six of the seven are `iface_zero_width_field`'s six elaborated copies.  The
seventh is `cva6_struct_param_field`, whose `it_t` is `struct packed` — OUT of
this law's scope, and it does not move (its residue is golden keeping two
`op67` casts where we fold constants, a different face).

**THE SAME CENSUS RE-RUN OVER THE PATCHED DATABASES** is the cell-resolution
counterpart of the byteverify measurement, and it reads, identically in both
modes (`evidence/cen.u2r.law.{default,testflags}.txt`):

```
== ALLCTRL=227  GCTRL(ELAB listings)=219
== LAWCELLS=1 on 1 tests  RISK(must not move)=453
== LAW TESTS: cva6_struct_param_field
```

`LAWCELLS 7 -> 1`, and the one left is the out-of-scope packed cell.  `RISK
447 -> 453`: the six elaborated copies MOVED INTO the agreeing set, and not one
cell left it — AWAY-GOLDEN 0 at cell resolution over the whole corpus, not only
over the grid.

`pred61.py` names 14 cells on 6 tests per mode out of 184 candidates:

```
iface_nested_param_field  iface_scalar_localparam  iface_struct_field_partsel
iface_zero_width_field    rp32_r5p_alu             rp32_r5p_wbu
```

**Surelog suite, both modes.**  Positive control non-zero there too:

```
default    ALLCTRL=610  GCTRL(ELAB listings)=302  LAWCELLS=4  on 4 tests  RISK=339
testflags  ALLCTRL=608  GCTRL(ELAB listings)=286  LAWCELLS=60 on 5 tests  RISK=270
default    LAW TESTS: ParamNoImport StructParamFieldRange
                      StructParamFuncBodyFieldCompare StructParamPatternInitCast
testflags  LAW TESTS: the same four + Earlgrey_0_1
```

The default-mode reading was produced TWICE, by two builds of the instrument
(§8's `cen61.py` note), and reproduced to the digit.

`Earlgrey_0_1`'s 56 testflags-only cells are `ts=array_typespec()` — the AES
S-box UNPACKED-ARRAY parameters, which this law's `UnpackedStructType` gate
cannot reach.  They are a testflags-only residue of the unpacked-array face
(the same cells AGREE with golden in default mode, which is why that row shows
no cell there at all), the row is `CMP_EQUAL` in both modes, and its databases
are BYTE-IDENTICAL on the two binaries (`8bdf25272e08` / `59d0ee6d10c3`, the
brief's two pins).  The census's LAWCELL column is deliberately broader than
the law — it does not read the struct kind — so a cell appearing there is a
candidate to explain, not a cell to move.

**THE SAME CENSUS OVER THE PATCHED SURELOG DATABASES** reads back IDENTICALLY
(`evidence/cen.sl.law.default.txt`): `ALLCTRL=610  GCTRL=302  LAWCELLS=4 on the
same 4 tests  RISK=339`.  Not one Surelog cell moved in either direction.

and `pred61.py` over the same workdir names **4 cells on 1 test in BOTH modes —
`InterfaceParamOverrideProp`, out of 237 candidates in default and 244 in
testflags** — which is the bound working exactly
as an over-inclusive bound should: its `cfg_t` is
`typedef struct { hsk_t HSK; }` with `hsk_t` an UNPACKED STRUCT, so the
non-integral fence declines it, and its pattern `'{HSK: '{DLY: 1}}` has a
PATTERN-VALUED element, so `patParamPatElem26v` declines it too — two
independent fences on one cell.  Its databases are BYTE-IDENTICAL on the two
binaries in both modes (`629440ddcde4` / `e242072e9c7c`), and it stays
`CMP_EQUAL`.

None of the four census cells is this law's cell either.  `ParamNoImport`'s Rhs is not an
operation on our side at all (`op=? ts=- ops=[]`); the other three are golden
keeping a CAST (`op67`) or an arithmetic op (`op29`) as the operand where we
fold a constant — the same face as uhdm2rtlil's `cva6_struct_param_field`, and
a different one from this pass's.  All four are byte-identical on the two frozen
binaries, and none of them appears among the measured movers.

**TIMING, stated plainly.**  The uhdm2rtlil census and the uhdm2rtlil predictor
(both modes), and the direct two-binary `BlackBePipeInt` measurement with its
positive control, were all run BEFORE the patched sweeps.  The SURELOG census
and predictor read only PRISTINE databases but FINISH after the patched surelog
sweep does — they dump up to 1596 databases, several of them minutes each on
YosysOpenSparc / Ariane / BlackParrot.  What they add is therefore the positive
control and the cell names, not the prediction: the prediction for the Surelog
suite was stated from the TYPE fence and from `BlackBePipeInt`'s byte identity,
both in hand beforehand, and the byteverify movers (§6) are the measurement that
settles it.

**PREDICTED MOVER SET, stated before scoring: `iface_zero_width_field` (the
conversion) plus `rp32_r5p_alu` and `rp32_r5p_wbu` (byte-order only), each in
both modes — and on the Surelog suite NOTHING THIS LAW TOUCHES, because
BlackBePipeInt's `bp_proc_param_s` is `typedef struct packed`
(`bp_common_aviary_cfg_pkgdef.svh:85`) and the packed road is untouched; the
UVM family's own per-invocation coin draws are expected there and are attributed
by re-draw, not by this law.**

A FIRST CUT of `pred61.py` keyed on the SYMPTOM ("an operand past the first
still at the unsized 64") and MISSED both rp32 rows, whose pristine operands
were already at the right widths.  A predictor keyed on the symptom cannot bound
a law keyed on the type; the shipped one keys on `vpiPacked`.

---

## 6. WHAT MOVED, AND WHAT DID NOT

`iface_zero_width_field` converts in both modes.  The 12 moved cells are
attributed line by line, order-blind and path-normalised
(`evidence/MOVERS.u2r.txt`):

```
     12 < |vpiSize:64          (pristine)
     12 > |vpiSize:32          (law)
```

and nothing else, in either mode — 12 cells, all TO GOLDEN, because golden's own
listing carries exactly those 12 extra `|vpiSize:32` lines.

`rp32_r5p_alu` / `rp32_r5p_wbu` move BYTES in both modes and their ORDER-BLIND
dump diff is **0 lines**: content-identical databases, a different serialisation
order (the walk mints its operand constants in a different order).  Both rows
are CMP_EQUAL on the pristine and the patched sweep alike.

On the SURELOG suite nothing this law touches moves.  The four byte movers there
— `MiniAmiq` both modes, `Scoreboard/default`, `SeqDriver/default` — are the UVM
family's own per-invocation coin, RE-DRAWN from the unchanged pristine binary in
`evidence/MOVERS.sl.txt` rather than asserted, and their order-blind diffs are
the documented 0-or-4-line `UINT`/`vpiDecompile` class.  `BlackBePipeInt` is
BYTE-IDENTICAL on the two binaries (`evidence/BBPI.nomove.txt`, with a positive
control), and so are the four cells the Surelog census names
(`evidence/SL.lawcells.txt`).

---

## 7. RESIDUES

* **R0 — golden CLONES the elaborated copy's `struct_typespec`, we SHARE one,
  and the judge cannot see it.**  362 of the 496 order-blind lines left on
  `iface_zero_width_field`.  Object counts on that one test: `struct_typespec`
  golden 27 / ours 23, `typespec_member` 79 / 67, `int_typespec` 78 / 66,
  `ref_typespec` 162 / 156 on the law binary (150 on the pristine) — four extra
  clones, each with its three members,
  their three element typespecs and instance-scoped `vpiFullName`s
  (`work@top.u.man.B.p::bus_t.CTL` and its siblings).  The producer is decoded
  (§1): `clone_tree(mod_assign)` per instance plus
  `flattenPatternAssignments`' fresh `ref_typespec`.  **It is invisible to
  `uhdm-cmp`** — no generated `Compare` reads `VpiParent` or `VpiFullName`, and
  a shared and a cloned typespec of the same content compare identically — so
  it buys no row and costs 28 minted objects per cell.  Recorded, not
  implemented; the `dump` column's `differ` is this.
* **R1 — the elaborated cont_assign multiplicity.**  82 lines: our
  `uhdmtopModules` carries 5 more `cont_assign` objects (plus 5 `hier_path` and
  15 `ref_obj`) than golden's, which shares the definition listing's.  Pass
  54/55 ground and deliberately untouched here.
* **R2 — the `B.CTL` member select inside a packed struct member's dimension.**
  15 + 37 lines: golden renders it as `ref_obj (B)` + `ref_obj (CTL)` where we
  emit one fused `ref_obj (p::p::req_t::ctl.CTL)`, plus 27 stray `|vpiParent:`
  prints and two `logic_net` names.  Judge-invisible, on both sides of the
  conversion.
* **R3 — the elaborated-package op-level `ref_typespec` NAME.**  The 5
  `uhdmtopPackages` lines, unmoved: golden leaves it BARE and we name it `(p)`.
  Pass 59's R1 verbatim, and the mirror image of the cell pass 59 fixed — the
  two faces must not be "unified".
* **R4 — the shared walk pads a concat / replication member value's BIN digits
  to the member width; golden keeps the reduce's raw digit string.**  Measured
  on the PACKED road, which this pass does not touch (`h2` `WCAT` / `WREP`,
  identical on both binaries), and fenced out of the unpacked road (`h3` `UCAT`
  / `UREP`).  Closing it would move the packed road corpus-wide and belongs to
  its own pass.
* **R5 — an inline `#(.P('{...}))` OVERRIDE of a struct-pattern parameter is
  not substituted into the elaborated copy.**  `h6`'s `c1.PP`: golden carries
  16/17/18, both our binaries carry the default 7/8/9.  Pre-existing; fenced so
  the law does not re-size wrong values.
* **R6 — a module with a PARAMETER PORT LIST flattens an imported, never-
  selected unpacked struct param's DEFINITION copy where golden tags it.**
  Found while gridding, on the PRISTINE binary: `h6`'s `work@h6child.PK` in
  `uhdmallModules` — golden `tagged_pattern ×3`, ours typed + flat.  A
  pre-existing AWAY cell at pass 59's face, off-corpus, unmoved by this law and
  recorded so the next pass at that face does not read it as new.
* **R7 — a generate-block localparam has no elaborated copy at all on our
  side.**  `h6`'s `gb[0].GL` / `gb[1].GL` are in golden's `uhdmtopModules` and
  absent from ours, on both binaries.
* **R8 — routing a cell through the walk MINTS ONE `ref_typespec` PER CELL.**
  Measured with `uhdm-dump --stats`, which counts objects and not prints: the
  walk builds the op's own `ref_typespec`, and the ref the road it replaced had
  already built stays in the serializer.  No other object kind changes —
  `constant`, `operation`, `param_assign`, `struct_typespec`,
  `typespec_member`, `int_typespec` and `tagged_pattern` counts are IDENTICAL on
  the two binaries on both the witness and every arm, so nothing is
  double-emitted.  On the witness the count moves TOWARD golden (`ref_typespec`
  150 -> 156, golden 162); on the off-corpus arm `h3` it moves away (124 -> 129,
  golden 112).  The extra object has no parent in the tree, so it lands in the
  weakly-referenced tail the judge never walks — which the conversion
  demonstrates rather than assumes.  Recorded because a later pass counting
  objects must not read it as new breakage.

**R0 is the R0 the next pass should take only if a later measurement shows it
reaching the judge** — on the evidence here it does not, and the ranked
successor is R1 (82 lines, the elaborated cont_assign multiplicity) or a fresh
head on another row.

---

## 8. FILES

| file | what it is |
|---|---|
| `arm.sh` | one arm through Surelog + one slang-uhdm binary, both dumped, rc recorded (from r11u34) |
| `shape.py` | THE SHAPE LISTER, made ENCODING-VISIBLE here: every `param_assign` in every top-level listing — op type, op-level typespec actual, operand kinds, and each constant's `vpiSize` **and `vpiConstType` and VALUE** |
| `score60.py` | joins golden / pristine / law per cell: TO / AWAY / MOVED-WRONG / STILL / SAME (from r11u60) |
| `cen61.py` | `shape.py` over a whole `verify_golden.py` workdir, restricted to the ELAB listings: positive control, law cells, AWAY-risk bound.  Run over the PRISTINE workdir it is the prediction; run over the PATCHED one it is the cell-resolution score.  It existence-checks BOTH sides before dumping EITHER — the obvious loop dumps the golden first and only then finds our side missing, which on the Surelog suite is 571 of 798 tests and turns a minutes-long census into an hours-long one (the first build of this instrument timed out on Earlgrey's golden for that reason and scored the row as absent) |
| `pred61.py` | the A-PRIORI mover predictor — pristine databases only, keyed on `vpiPacked` |
| `h1.sv` | the corpus mirror: a package-selected unpacked struct through an interface, two interface instances, two module instances, the port-bound view, and a module-local twin |
| `h2.sv` | the PACKED control — member widths x element kinds, already golden on the pristine binary |
| `h3.sv` | the UNPACKED twin of `h2` — the law's face, wrong in every pristine cell |
| `h4.sv` | the nested shapes: pattern-valued member, unpacked-array member, `real`, `time`, `string`, a >64-bit member |
| `h5.sv` | THE BAIL, with unbased literals so a size is never confusable |
| `h6.sv` | holders x copy counts x override x generate |
| `byteverify.sh` `ct8rows.sh` `rowheads.sh` | the gates |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` | the current-generation battery (r10uvm221repro), run here |
| `evidence/` | the four cmp heads, the grid score, the sectioned residue, the two mover attributions, the BlackBePipeInt no-move proof with its positive control, the Surelog law cells and the Surelog predicted test by name, the object-count table, the censuses BEFORE and AFTER, and the four predictor runs |

---

## 9. GATES — all green

Binaries frozen `chmod 555` at `/tmp/r11u61_bin/` before any sweep; every
`cmds.txt` audited by binary PATH — 1742 + 1531 `pris.bin` lines in the
pristine workdirs, 1742 + 1531 `law3.bin` lines in the patched ones, and
**0 main-tree paths in any of the four**.

1. **BUILD.**  PRISTINE `md5 9452577e1d0e0d64f87e78ad6e3b3cd6`, built in this
   pass's own worktree and byte-identical to the main tree's `build/slang-uhdm`
   at `2a4ac214` — the brief's stated hash.  PATCHED
   `md5 7f8134d354a92dfe46c7381b7295557e`, 0 errors, `-j 2`, md5 taken
   separately.
2. **GOLDENS.**  `tests/check_goldens.sh` PASS 23 / FAIL 0 on BOTH binaries.
   Negative control `SLANG_UHDM=/bin/false` PASS 0 / FAIL 23.
3. **uhdm2rtlil, both modes.**  **786 CMP_EQUAL / 18 CMP_NOTEQUAL / 67
   SLANG_REJECT** in each mode, against the baseline's 785 / 19 / 67 — the
   claimed CONVERSION and nothing else.  `ct8rows.sh` whole-row diff against
   `results/gate_uhdm2rtlil.csv`, against `results/golden_uhdm2rtlil.csv` (both
   modes joined) and against this pass's own pristine CSVs in both modes reports
   **exactly the two conversion row-sides, quoted in §0, and no other row**.
4. **Surelog suite, `--mode both`.**  default **474 / 9**, testflags **469 / 8**
   — the baseline exactly, every other status bucket identical to the own-
   pristine sweep (DEFERRED 5/5, SLANG_REJECT 285/286, SURELOG_FAIL 25/23,
   NO_DATABASE 3, NO_UHDM 1, TIMEOUT 1, UNTRANSLATABLE 2).  `ct8rows.sh` flags
   **three** rows against the own pristine sweep and the same three against the
   committed `results/golden_surelog.csv`, none of them a status move:

   ```
   < Earlgrey_0_1,testflags,CMP_EQUAL,,,differ
   > Earlgrey_0_1,testflags,CMP_EQUAL,,,
   < LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../LowMemLib-f068a766/slpp_all/surelog.log".,,
   < LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   ```

   The last two are the workdir PATH inside a GOLDEN-side failure message.  The
   first is the documented `uhdm-dump` TIMEOUT DRAW on Earlgrey's dump COLUMN:
   the STATUS is `CMP_EQUAL` on both sweeps and the two DATABASES are
   BYTE-IDENTICAL (`59d0ee6d10c3`, the brief's testflags pin), so the column
   difference cannot be a content change.
5. **byteverify, `SELFCHECK=1`, against this pass's own pristine workdirs.**
   * uhdm2rtlil: PATH_SETS_IDENTICAL (1608), **MOVERS 6 / 1608** — the predicted
     set name for name: `iface_zero_width_field`, `rp32_r5p_alu`,
     `rp32_r5p_wbu`, each in both modes.  SELFCHECK 1607/1608 flagged.
     Attribution `evidence/MOVERS.u2r.txt`: `iface_zero_width_field` is 12
     `|vpiSize:64` -> `|vpiSize:32` lines and nothing else, all TO GOLDEN; both
     rp32 rows are **0 order-blind lines** — content-identical databases in a
     different serialisation order, CMP_EQUAL before and after.
   * Surelog: PATH_SETS_IDENTICAL (960), **MOVERS 4 / 960** — `MiniAmiq` both
     modes, `Scoreboard/default`, `SeqDriver/default`, every one a UVM-family
     COIN DRAW attributed by RE-DRAW from the UNCHANGED PRISTINE binary rather
     than by assertion (`evidence/MOVERS.sl.txt`).  Three runs of the pristine
     binary on the sweep's own command line:
     `MiniAmiq` -> `5a2e87045ac5` (18852322 B), `2b821b6d1086` (18852279 B),
     `e2fa1b202869` (18852279 B) — three hashes, two sizes, none of them the
     sweep's `27419f6011b4`; `SeqDriver` -> `cdd937c42903`, `3ef032bf4e46`,
     `a41bc97f8cc7` (18074291/18074291/18074292 B) — likewise;
     `Scoreboard` -> `1621aec6c9f3`, `e70775324004`, `1621aec6c9f3`, i.e. the
     PRISTINE binary alone produces BOTH the sweep-pristine and the
     sweep-patched hash.  The path-normalised ORDER-BLIND sorted-dump diff of
     each is the documented class and nothing else:

     ```
     default/MiniAmiq    4 lines   |UINT:0    <-> |UINT:879   (+ vpiDecompile)
     default/Scoreboard  0 lines   (the documented 0-line order draw)
     default/SeqDriver   4 lines   |UINT:748  <-> |UINT:1356  (+ vpiDecompile)
     testflags/MiniAmiq  4 lines   |UINT:1045 <-> |UINT:924   (+ vpiDecompile)
     ```

     SELFCHECK 959/960 flagged.  `BlackBePipeInt` was PREDICTED BY NAME not to
     move and MEASURED not to move before the patched sweep, with a positive
     control (`evidence/BBPI.nomove.txt`): both frozen binaries produce
     `md5 0754dbaa7154500d49565ad8407b0006` on its own source, while the same
     two binaries on arm `h3.sv` produce `d747b61786c0c5cfc8203ab81c3cf94d` and
     `64d7e8d959da566a9c455462350d63f6`.
   * Both corpora: **MOVED-WRONG 0, AWAY-GOLDEN 0**, scored cell by cell on the
     golden grid (§3) and by name in the corpora (§5).
6. **Protected databases, by name, patched vs own pristine** — every one SAME:
   `SVSwitch 4842211c4030` (both modes, hard byte pin), `YosysVerx 6ccda350c24a`
   (both modes, hard byte pin), `InterfaceModPort 59a365f3ce2c` (both modes),
   `BlackParrotComplex` (default `e3e354129d5a`, testflags `73a10e8217e5`),
   `YosysOldOr d68e0796d62c` (both modes), `Earlgrey_0_1` default
   `8bdf25272e08` and testflags `59d0ee6d10c3` — the two Earlgrey pins the brief
   names, hit exactly — and `BlackBePipeInt` (default `0754dbaa7154`, testflags
   `85520d3442c4`).
7. **Canaries.**  `canaries.sh` patched-vs-own-pristine: surelog `ok=51
   changed=1 absent=0`, uhdm2rtlil `ok=8 changed=0 absent=0`; surelog against the
   committed CSV reads the same `ok=51 changed=1`.  The one CHANGED row is
   `Earlgrey_0_1 testflags CMP_EQUAL/differ -> CMP_EQUAL/` — the dump-column
   timeout draw of gate 4, status unchanged and database byte-identical.
   `ctcan2.sh` PASS on both corpora.  `canaudit.sh canaries.sh ctcan2.sh` —
   *PASS: every brief-protected name and family is carried by a script that RUNS
   here*.  The battery is the current generation (`r10uvm221repro`).
8. **rowheads** on the converted families, patched workdir: `SeqDriver`,
   `SimpleUVM`, `Scoreboard/default`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1`
   and `BlackBePipeInt` — every one **0 cmp lines, 0 heads, rc=0** in both
   modes.  SKIP-NOFILE on `Scoreboard/testflags` and `Rggen/testflags` is the
   expected pair; `Rggen/default` reads 64 cmp lines / 1 head on the committed
   baseline, on this pass's pristine sweep and on its patched sweep alike.
9. **`results/*.csv` untouched** — `git status` in the main tree is EMPTY, and
   in this pass's worktree shows one modified source and one new probe
   directory, nothing else.  No fenced test was ever dispatched (`FENCED=` names
   were never spelled or run).  `GOLDEN_DEFER` unset throughout.
10. **The patch applies clean on a FRESH `2a4ac214`** — `git apply -3` rc 0,
    "Applied patch to 'src/ParamEmit.cpp' cleanly", 0 conflict markers, 31
    files, and the diff spells no fenced test name.
11. **Metric docs**: the uhdm2rtlil scoreboard moves 785/19/67 -> 786/18/67 in
    both modes, so `RESUME.md` §3b and `GOLDEN_EQUIVALENCE.md` §3.3 are refreshed
    in the SAME commit as this landing.
