# r11u52 — ROAD C: a body typedef's ELEMENT bound stays symbolic under an unpacked dimension

Base `4e421b38` (matrix-1.87). Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`, the golden producer),
uhdm2rtlil v0.68. Two binaries, both frozen `555` before any sweep: the
pristine worktree build, md5 `9be297f87ce752ca318a4d32b204ebe9` — **byte-identical
to the main tree's binary at the base** — and the law build, md5
`b83456d497931cf6aec70c2918efc63d`. Every `cmds.txt` in both sweeps was audited
by binary PATH (3323 + 3323 files, one binary each).

## 1. The head, re-measured at the base, both modes

`mem_packed_2d_byte_write` (uhdm2rtlil), `CMP_NOTEQUAL` in both modes at
`4e421b38`, 1 head / 28 cmp lines each — quoted whole in
[evidence/HEAD.base.txt](evidence/HEAD.base.txt):

```
LHS (golden)                         RHS (ours)
operation @19:18-19:25               constant @19:18-19:25
  vpiOpType:11                         vpiDecompile:NDATA-1
  ref_obj (NDATA) @19:18-19:23         vpiSize:64
  constant 1 @19:24-19:25              UINT:1
                                       vpiConstType:9
```

Line 19 is `typedef logic [NDATA-1:0][DATA_SIZE-1:0] mem_t [DEPTH];`. Golden
keeps the element's packed bound as an operation over a reference; we fold it to
a constant that is visibly wrong — the written text survives as the decompile
while the value is the reduced one.

## 2. The producer, confirmed against the pinned sources

```
CompileModule.cpp:653   paData_declaration, module body     -> compileDataDeclaration(…, Reduce::No, …)
CompileModule.cpp:1130  paData_declaration, interface body  -> compileDataDeclaration(…, Reduce::No, …)
CompileHelper.cpp:2278    case paType_declaration: compileTypeDef(…, reduce, nullptr)
CompileHelper.cpp:1060      compileTypespec(scope, fC, stype, compileDesign, reduce, array_tps, …)
```

The `Reduce::No` is hard-coded — not the `m_instance ? Reduce::Yes : Reduce::No`
the parameter cases beside it use. So the ELEMENT typespec's bounds never
reduce, in any copy, while the `array_typespec` wrapper's own unpacked bound is
rebuilt per instance.

## 3. The golden grid — seven arms, measured not assumed

`grid/` holds one design per arm; `run52.sh <binary> <tag>` runs Surelog and a
chosen binary over each and records **both** rcs; `cell52.py` lists, per SOURCE
POSITION, whether each range bound came out `SYM(names…)` (an operation over a
ref_obj), `FOLD(text)` (a constant carrying the written text) or `NUM(n)`, with
copy counts. Full tables, base and law: [evidence/GRID.txt](evidence/GRID.txt).

What the grid decided:

| cell | golden | ours at base | after |
|---|---|---|---|
| `logic [NDATA-1:0][DATA_SIZE-1:0] mem_t [DEPTH]` (c1, x1 `two_t`) | keeps, 3 copies | folds, 3 | **matches, 3** |
| `logic [NDATA-1:0] up1_t [DEPTH]` (c1, x1 `a_t`) | keeps, 3 | folds | **matches** |
| `logic signed [NDATA-1:0] sg_t [DEPTH]` (x1) | keeps | folds | **matches** |
| `bit [NDATA-1:0] bt_t [DEPTH]` (x1) | keeps | folds | **matches** |
| `logic [NDATA-1:0] rr_t [DEPTH-1:0]` (x1, ranged dim) | keeps | folds | **matches** (element only) |
| `logic [3:0] li_t [DEPTH]` (x1, LITERAL bound) | folds | folds | unchanged — control |
| `int it_t [DEPTH]` (x1, no packed bound) | — | — | unchanged — control |
| `vec_t nm_t [DEPTH]` (x1, NAMED element) | keeps | keeps | unchanged — control |
| `logic [NDATA-1:0] pk1_t;` (c1, no unpacked dim) | keeps | keeps | unchanged — control |
| struct member bound, net decl, port (c1) | keeps | keeps | unchanged — controls |
| interface body (c3) | keeps | folds | **matches** |
| module instantiated TWICE, one NDATA overridden (x2) | keeps in every copy | folds | **matches in kind** |

**The name-prefix cell, measured.** Golden writes the element bound's `ref_obj`
BARE (`NDATA`) in the definition-compiled copy and scoped through the typedef's
BARE name (`mem_t.NDATA`, `up_t.NDATA`, `a_t.NDATA`) in every per-reference
COPY — never `work@dut.mem_t.NDATA`, which is what the array's own `[DEPTH]`
bound carries one line above it. Our copy positions map one-for-one onto
golden's: the first, parentless listing object is the bare one, the copies
parented by a `ref_typespec (<name>)` are the scoped ones. After the law our
three copies read `1×NDATA + 2×mem_t.NDATA`, cell for cell.

**The two fences (V3) are untouched, and measured so.** `vc1_typedef_shapes`
(two unpacked dims; a typedef inside a generate block; a struct element) and
`c2_typedef_pkg` (the package twin, whose unpacked-dim typedef is missing from
our database entirely — r11u51 R2) come out **byte-identical** before and after:
the only line that differs in either dump is the dump's own header naming the
input file. The flag does not reach package scope, and the two-dims typedef has
no element typespec for it to reach.

**A third hole this pass measured and did not widen** (`x3_scopes`): a typedef
with an unpacked dimension declared in a FUNCTION body, a TASK body or a named
BEGIN block is emitted by golden (one copy each, bounds symbolic) and is absent
from our database entirely — the same class as V3's generate-block finding. The
module-body twin in the same design moves; the three others stay absent.

Arm score (`score52.sh`, cells that disagreed at base and agree after / agreed
and now disagree / disagree in both): **TOWARD 18, AWAY 0, STILL 65** over the
seven arms. The 65 are copy counts, the fenced holes and the residues below.

## 4. The law

§ `bodyTypedefElemBoundSymbolic52`, gated by a flag of its own so the CLASS arm
cannot move:

* `include/UhdmExporter.h` — `unfoldedTypedefElemDims`, read in exactly one
  function, plus `elemSymBoundTs52`, the identity set of element typespecs the
  law left symbolic.
* `src/TypeEmit.cpp`, `emitTypedefs` — set the flag (and clear
  `syntaxRefPrefix`, save-and-restore, as the class arm does) around the
  MODULE-BODY / INTERFACE-BODY `buildUnpackedArrayTypedefTs` route only.
* `src/TypeEmit.cpp`, `anonAggregateElemTs` — with the flag, a NON-NUMERIC
  packed bound is emitted through `emitSyntaxExpr` instead of folded by
  `makeBoundConst`; a numeric bound is left exactly as it was. The element ts
  is recorded in `elemSymBoundTs52`.
* `src/TypeEmit.cpp`, `copyRangeVec` / `freshLeafTsCopy` / `copyArrayTypedefTs`
  — a per-reference copy of an element the law left symbolic now CLONES the
  bound (operation, operands, locations) instead of sharing it, and scopes each
  cloned `ref_obj` as `<bare typedef name>.<ident>`. Every other symbolic bound
  is shared exactly as before, because the decision is the recorded identity,
  never a property read off the object.

**One trap this pass paid for and encoded.** `ref_obj::VpiFullName()` is not a
getter: with no stored name it calls `ComputeFullName()` and WRITES the result
back into the object (`UHDM/build/generated/src/ref_obj.cpp:43`). A first
attempt asked "is this ref bare?" by reading `VpiFullName().empty()` — the read
mutated the source object and never reported empty, so no copy was ever scoped.
The recorded-identity set replaces it. Never test a UHDM name by reading it.

## 5. Census, prediction and gates

The construct scan over `uhdm2rtlil/test`, `Surelog/tests` and
`Surelog/third_party/tests` finds the `typedef … <name> [ … ];` shape in 34
files across 20 test directories, but the law fires only where the element
typespec is minted INLINE with a NON-NUMERIC packed bound. That is ONE
discovered row in either corpus. **Predicted, by name, before the byte census
ran: `mem_packed_2d_byte_write` default + testflags; surelog ZERO.**

Measured ([evidence/CENSUS.txt](evidence/CENSUS.txt)):

* uhdm2rtlil byte census: **MOVERS 2 / 1608**, both of them
  `mem_packed_2d_byte_write` — the prediction, exactly. Positive control
  (`SELFCHECK=1`): 1607 / 1608 flagged.
* surelog byte census: **MOVERS 4 / 960**, all four the documented
  pristine-nondeterministic UVM family (MiniAmiq ×2, SeqDriver, SimpleUVM).
  Each one's order-blind whole-dump diff is exactly the documented 4-line
  `UINT:`/`vpiDecompile:` line-number class. **Positive control: the SAME
  pristine binary run twice on MiniAmiq/default produces two different
  databases** (`87d9…` vs `8a4a…`), both `CMP_EQUAL`. Their statuses did not
  move: `rowheads.sh` reads cmp rc=0 / 0 heads for SeqDriver, SimpleUVM,
  Scoreboard, MiniAmiq, BuildUVMPkg and Earlgrey_0_1 in both modes.
* Row gates: uhdm2rtlil testflags and default, and surelog both modes, are
  byte-identical to the committed baselines and to my own pristine sweep — the
  only two differing surelog rows are `LowMemLib` / `LowMemPkg`, whose
  `SURELOG_FAIL` detail string embeds the workdir path. Status histograms are
  identical: **474/9 + 469/8 surelog, 783/21 uhdm2rtlil in both modes.**
* Goldens 23 PASS / 0 FAIL; negative control `SLANG_UHDM=/bin/false` 0 / 23.
* Canaries `ok=52 changed=0` and `ok=8 changed=0`; both `ctcan2` PASS;
  `canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0. Every protected database
  is byte-SAME against my pristine sweep, at the pinned md5s: SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
  Earlgrey_0_1 default `8bdf25272e08` / testflags `59d0ee6d10c3`,
  BlackParrotComplex and YosysOldOr SAME.
* `results/*.csv` were read, never written. The four slang-fenced tests were
  never dispatched.

**MOVED-WRONG 0, AWAY 0, both mode columns scored.**

## 6. The row: ADVANCE, not CONVERT — as predicted

`mem_packed_2d_byte_write` stays `CMP_NOTEQUAL` in both modes and its head
moves off the fold onto the `logic_net (work@dut.mem)` comparison
([evidence/HEAD.law.txt](evidence/HEAD.law.txt)). Its whole-dump residue against
golden drops from **120 golden-only / 35 ours-only lines to 27 / 6**
([evidence/RESIDUE.txt](evidence/RESIDUE.txt) enumerates every remaining line).
The arithmetic was predicted from the brief and holds: about 110 of the 120 were
the fold; the three things standing behind it are R0–R2 below.

## 7. Residues

* **R0 — THE NEXT HEAD: a net declared with an UNPACKED-ARRAY TYPEDEF carries
  no `vpiNetType`.** Golden stamps 36 (`vpiWire`) on it; we stamp nothing, and
  `net::Compare` reads `VpiNetType`, so it is judged. Measured across four arms
  and both scopes in [evidence/NETTYPE.txt](evidence/NETTYPE.txt): it is exactly
  the unpacked-array-typedef nets that lose the tag (`mem`, `u1`, `a`, `li`,
  `nm`, `rr`, `sg`, `tw`, `u`, and the interface's `a`), while every other net
  in the same designs agrees. The site is `src/EmitHelpers.h:970`
  `netTypeFor()`'s def-view arm, whose module-local-typedef test admits
  `PackedArrayType` and `ScalarType` and lets `FixedSizeUnpackedArrayType` fall
  through. NOT taken here: it is a net-tagging law whose blast radius is every
  net in both corpora, it wants its own census, and it does not convert the row
  either — R1 stands behind it.
* **R1 — the doubled hier-path segment.** Golden `work@dut.mem.mem.i` and
  `work@dut.wdata.wdata.i` at 27:49 / 27:71 against our single-segment
  `work@dut.mem.i` / `work@dut.wdata.i` (the loop index under a memory select).
  Judged; unrelated to the fold.
* **R2 — one extra golden copy of the array's own `[DEPTH]` bound**
  (`ref_obj mem_t.DEPTH` beside the `work@dut.mem_t.DEPTH` we both carry). The
  pre-existing typespec-pool copy-count residue (r11u35 R4). Visible in every
  arm: golden carries 2 wrapper-dim copies and 5 element copies for two
  instances where we carry 1 and 3.
* **R3 — a typedef with an unpacked dimension in a FUNCTION / TASK / named
  BEGIN body is absent from our database** (`x3_scopes`, three cells), as is one
  inside a GENERATE block (V3) and one in a PACKAGE (r11u51 R2). Three holes on
  one construct, none of them a fold decision, all three left fenced and
  measured byte-unchanged by this pass.
* **R4 — the wrapper's own RANGED unpacked dim still folds.** `typedef logic
  [NDATA-1:0] rr_t [DEPTH-1:0]` — golden keeps `[DEPTH-1:0]` symbolic in its
  copies, we fold to `3`. The symbolic path already exists at
  `src/TypeEmit.cpp` in `buildUnpackedArrayTypedefTs` behind
  `unfoldedTypedefDims`; this pass did not flip that flag because it also
  re-routes the struct-element and shared-alias arms beside it. One arm cell
  (`x1` 15:50), no corpus row carries the shape (`rp32`'s `select_t [IFN-1:0]`
  has no packed element bound, so it is untouched either way).
* **R5 — `bit`-element and 2-D-element kind mismatches exposed under the closed
  fold.** With the bounds now equal, `x1`'s head is golden `bit_typespec` vs our
  `logic_typespec` for `bit [NDATA-1:0] bt_t [DEPTH]`, and `c1`'s is a Typespecs
  listing whose element object we SHARE with a same-shaped sibling typedef
  (`up1_t`'s element is `pk1_t`'s object; golden mints a separate one). Both
  pre-existed and were masked by the fold.

## 8. Reproducing

```bash
GRID=$PWD/grid bash run52.sh <binary> <tag>        # golden + binary per arm, rcs recorded
python3 cell52.py grid/<arm>/gold.<tag>.dump grid/<arm>/ours.<tag>.dump
GRID=$PWD/grid BASE=base LAW=law2 bash score52.sh  # TOWARD / AWAY / STILL per arm
```

`canaries.sh`, `ctcan2.sh` and `canaudit.sh` are the current-generation battery,
carried here unmodified so the audit runs in this directory.
