# r10earl108 — § `ovStructPatNonStructFormal108`: a parameter OVERRIDE whose actual is a struct parameter substitutes that parameter's flattened pattern whatever the FORMAL's type is — unless the formal is `logic`

Everything in this directory is **MEASUREMENT ONLY**.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

`Earlgrey_0_1` **testflags** goes from **122 cmp lines / 1 head to 48 / 1** — a
NEW object, a different family.  `Earlgrey_0_1` **default** keeps its own
earlier head **byte-identical** while its database moves.  Three databases
moved: **two by the law and one by the recorded coin**, and the corpus census
scores **TO-GOLDEN 2 / AWAY-GOLDEN 0 / MOVED-WRONG 0** on surelog and
**0 / 0 / 0** on uhdm2rtlil.

* BASE COMMIT `bb2d4f24`, branch `auto5h`.  Worktree `/tmp/wt_r10earl108`.
* Pristine binary md5 `fd2870e34b3081cb23199acbdfdf838d` — **byte-identical to
  the main tree's build at `bb2d4f24`**, and to r10earl107's landed patched
  build — patched `b3b43f254fac7ddfd263e87681d097a7`.  Both frozen `chmod 555`
  at immutable paths **before any sweep**; all **3035** `cmds.txt` audited BY
  BINARY PATH (2981 name the frozen binary, **0** name the main-tree binary and
  **0** name the worktree's own `build/`).
* `/tmp/r10earl108.patch` applied to a **FRESH `bb2d4f24` worktree** with
  `git apply -3` (clean, 0 conflict markers) and rebuilt there produces the
  **BYTE-IDENTICAL** binary, same md5 `b3b43f254fac7ddfd263e87681d097a7` — the
  patch IS the artifact every number below was measured on.
* Production diff: `src/ParamEmit.cpp` **only** — three edits: one admission
  test, one `!ovNonStructPat108` on the default-render block, one disjunct on
  `structPat`.  No new function, no new member, no header change.  `slang` is
  NOT patched.  `results/*.csv` were **READ ONLY** and **no row was converted**.
  `GOLDEN_DEFER` stayed unset.  The four slang-fenced tests were never
  dispatched and appear in **0** of the 4822 boundary-listed files; they are
  named only inside `canaudit.sh`'s own fence list.

---

## 1. THE HEAD, and WHICH FIELD FAILS FIRST — decoded before a line of law

`rowheads.sh` on this pass's **own pristine build**, not carried forward:
`Earlgrey_0_1` **default 31 / 1**, **testflags 122 / 1**.  Only testflags is
this pass's; the default head is the pre-existing
`u_pinmux.gen_mio_periph_in[0].data_mux` null that r10earl107 named.

```
LHS (golden)  operation id:709890  op=75   pwrmgr_cdc.sv:108:17-108:41
              |vpiParent -> param_assign id:709883 prim_flop_2sync.sv:9:17-9:31
              |vpiTypespec -> ref_typespec (work@top_earlgrey.u_pwrmgr.i_cdc.i_ast_sync)
                              -> struct_typespec pwrmgr_pkg::pwr_ast_rsp_t 31:11-36:4
              |vpiOperand x4  2'b01/2/BIN  2'b01/2/BIN  2'b10/2/BIN  1'b0/1/BIN
                              at pwrmgr_pkg.sv:47, 48, 49, 50 — the MEMBER spans
RHS (ours)    constant  id:557631         prim_flop_2sync.sv:9:30-9:31
              |vpiDecompile:0  |vpiSize:1  |UINT:0  |vpiConstType:9
              |vpiTypespec -> ref_typespec (work@top_earlgrey.u_pwrmgr.i_cdc.i_ast_sync)
                              -> bit_typespec 9:13-9:16
```

```systemverilog
pwrmgr_pkg.sv:31   typedef struct packed {
pwrmgr_pkg.sv:32     logic [1:0] slow_clk_val;
pwrmgr_pkg.sv:33     logic [1:0] core_clk_val;
pwrmgr_pkg.sv:34     logic [1:0] io_clk_val;
pwrmgr_pkg.sv:35     logic       main_pok;
pwrmgr_pkg.sv:36   } pwr_ast_rsp_t;
pwrmgr_pkg.sv:46   parameter pwr_ast_rsp_t PWR_AST_RSP_SYNC_DEFAULT = '{
pwrmgr_pkg.sv:47     slow_clk_val: 2'b01,  48: core_clk_val: 2'b01,
pwrmgr_pkg.sv:49     io_clk_val:   2'b10,  50: main_pok:     1'b0 };
prim_flop_2sync.sv:7  module prim_flop_2sync #(
prim_flop_2sync.sv:8    parameter int Width      = 16,
prim_flop_2sync.sv:9    parameter bit ResetValue = 0 ) ( ... );
pwrmgr_cdc.sv:106  prim_flop_2sync # (
pwrmgr_cdc.sv:107    .Width($bits(pwr_ast_rsp_t)),
pwrmgr_cdc.sv:108    .ResetValue(PWR_AST_RSP_SYNC_DEFAULT)
pwrmgr_cdc.sv:109  ) i_ast_sync ( ... );
```

**THE JUDGE, read out of the generated `Compare`s and not assumed**
(`~/git-repos/UHDM/build/generated/src/{BaseClass,expr,constant,operation}.cpp`
plus `~/.local/include/uhdm/BaseClass.h`'s SafeCompare overloads):
`BaseClass::Compare` reads **`VpiType` FIRST**, and this is `operation` vs
`constant`.  **The head is a WHOLE-OBJECT question, not a field one** — no
per-kind field, no operand vector and no typespec is ever reached, because the
first comparison already fails.  No location is read anywhere.

Both sides already carry the **same connection-scoped `ref_typespec` fullname**
`work@top_earlgrey.u_pwrmgr.i_cdc.i_ast_sync` — our parameter-typespec
machinery scopes it correctly.  What differs is the ACTUAL typespec behind it:
golden's is the **ACTUAL parameter's** struct, ours is the **FORMAL's** `bit`.

### THE OWNER — `own108.cpp` (r10earl106/107's id-selector owner-finder)

`own108 <golden.uhdm> id:709890` on the golden testflags database:

```
constant/operation held SINGULAR by param_assign 9:17-9:31 (Rhs), VECTOR=0 SINGULAR=1
  under module_inst work@prim_flop_2sync (work@top_earlgrey.u_pwrmgr.i_cdc.i_ast_sync)
```

A **singular `Rhs` edge**, one holder, no vector — so unlike r10earl107's
double-held constant there is exactly one writer to get right.

---

## 2. WHERE OURS COMES FROM — MEASURED, not assumed

The brief's three candidates were *dropped*, *folded early*, *rejected*.  A
two-arm discriminator settles it (`/tmp/r10earl108_orig`, one bit changed per
arm):

| arm | actual's LSB member | formal's default | OUR Rhs |
|---|---|---|---|
| o1 | `main_pok: 1'b1` | `0` | `UINT:1` size 1 |
| o2 | `main_pok: 1'b0` | `1` | `UINT:0` size 1 |

**The value tracks the ACTUAL, not the default.**  The override is neither
dropped nor rejected: slang narrows the 7-bit struct value to the `bit` formal
and we render **the folded override**, anchored at the DEFAULT initializer's
span (`9:30-9:31`) because `ParamEmit.cpp`'s override render anchors an
expression override there.  `vpiOverriden:1` was already correct.

The reason the substitution never ran is one line: `structOvPat` (the landed
override-substitution detector, `ParamEmit.cpp` ~5553) is gated on
**`ps.getType().getCanonicalType().kind == PackedStructType ||
UnpackedStructType`** — the FORMAL's type.  With a `bit` formal it never fires.

---

## 3. THE SURELOG DECODE — read out of the source, and it is a TYPESPEC-KIND rule

**`NetlistElaboration::elab_parameters_`**
(`~/git-repos/Surelog/src/DesignCompile/NetlistElaboration.cpp:238-317`) keeps
the instance's **complex value** — the referenced struct parameter's already
flattened `op75` — as the child `param_assign`'s Rhs, under a guard that tests
only the OPERATION:

```cpp
expr* complexVal = instance->getComplexValue(paramName);
if (complexVal) rhs = complexVal;
if ((!isOverriden) || complexVal) {
  if (rhs && rhs->UhdmType() == uhdmoperation) {
    // Don't reduce these operations
    if (opType == vpiAssignmentPatternOp || opType == vpiMultiAssignmentPatternOp) {
      ... clone the mod_assign, substituteAssignedValue, expandPatternAssignment(ts, ...)
      assigns->push_back(pclone); continue;          // the OPERATION survives
```

The formal's type enters exactly once, inside
**`CompileHelper::expandPatternAssignment`**
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:5037`), whose tail
(**5303-5322**) is the ONLY place an assignment-pattern operation is turned back
into a constant:

```cpp
} else if (tps->UhdmType() == uhdmlogic_typespec) {
  if (patternSize) {
    constant* c = s.MakeConstant(); result = c;
    uint64_t value = 0;
    for (uint64_t i = 0; i < patternSize; i++)              // patternSize = the STRUCT's width
      value |= (values[i]) ? ((uint64_t)1 << (patternSize - 1 - i)) : 0;
    result->VpiSize(size);                                   // size = the FORMAL's width
    result->VpiValue("UINT:" + std::to_string(value));       // NOT masked to `size`
    result->VpiDecompile(std::to_string(size) + "'d" + std::to_string(value));
  }
} else if (tps->UhdmType() == uhdmstruct_typespec) { if (!invalidValue) result = rhs; }
return result;                                               // every other tps: the OP survives
```

Two facts a paraphrase would lose, both measured on `g2_form108`:

* **`values` is `std::vector<int32_t> values(size, 0)` — the FORMAL's width —
  while the assembling loop runs to `patternSize`, the STRUCT's.**  Below the
  struct width the collapse READS OUT OF BOUNDS: a 7-bit
  `'{2'b01,2'b01,2'b10,1'b0}` gives golden `7'd44` at `logic [6:0]` (correct),
  `3'd37` at `logic [2:0]` and `1'd5` at `logic` and at `logic [0:0]`.  Those
  are heap junk, not a rule to copy.
* **`bit [6:0]` is a `bit_typespec` with `Ranges()`, not a `logic_typespec`**,
  so it SURVIVES the collapse — but
  `CompileHelper::reorderAssignmentPattern` (`CompileExpression.cpp:5888`)
  then **REVERSES the operand vector** for a descending range
  (`if (lrv > rrv) { op->VpiReordered(true); std::reverse(...); }`).

**THE MATRIX, measured on one source with one actual and twelve formals**
(`g2_form108`, golden's own answer):

| formal | Surelog typespec | golden |
|---|---|---|
| `bit`, `int`, `integer`, `byte`, untyped, `rsp_t` | bit/int/integer/byte/int/struct | **the `op75` SURVIVES** |
| `bit [6:0]` | bit_typespec **+ Ranges** | survives, operands **REVERSED** |
| `logic`, `logic [0:0]`, `logic [2:0]`, `logic [6:0]` | logic_typespec | **COLLAPSED** (and junk below the struct width) |

---

## 4. THE LAW

> **§ ovStructPatNonStructFormal108** — an instance parameter **OVERRIDE**
> whose **ACTUAL** is a bare reference (named or hierarchical) to a
> **packed-struct parameter** whose own initializer is an assignment pattern
> substitutes that pattern as the child `param_assign`'s **Rhs** — the flat
> `op75` at the **override-site span**, one operand per member of the
> **ACTUAL's** struct at the member's own width and source encoding, tagged
> with a connection-scoped `ref_typespec` to a clone of the **ACTUAL's** struct
> typespec — **whatever the FORMAL's declared type is**, and NOT only when the
> formal is itself a struct.

`src/ParamEmit.cpp`, three edits, all inside `emitParameters`:

1. the **admission test** beside the landed `structOvPat` detector: when the
   formal's canonical type is a `PredefinedIntegerType` or a `ScalarType` whose
   `scalarKind` is `Bit`, and the actual is a bare packed-struct parameter with
   a pattern initializer, set `structOvPat` / `structOvLoc` /
   `structOvRefParam` exactly as the shadowed-override path already does;
2. `!ovNonStructPat108` on the **topView default-render block**
   (`if (!rhs && topView && !elabMiseval9 && !elabOvMiseval9)`): for an
   overridden parameter `init0` is the DECLARATION DEFAULT, so without this the
   block re-emits `parameter bit ResetValue = 0`'s own `0` and the flat arm
   further down — guarded on `!rhs` — is never reached;
3. one disjunct on `structPat`, so the flat walk runs for a non-aggregate
   formal.

Nothing else is touched.  The member walk, the operand sizing, the nested-member
recursion and the typespec clone are the **landed** `structOvRefParam`
machinery, reused verbatim: `paramOpTsSrcParam[rt] = structOvRefParam` already
makes `mintParamOpClones` build the clone off the ACTUAL parameter's type and
scope its fullname at the connection.

**THE FENCES, each with a golden witness measured on this pass's own arms:**

| fence | witness (golden, LHS) |
|---|---|
| **not a `logic`/`reg` formal** | `g2_form108` rows `c`/`d`/`h`/`k` and `g4_fence108` `i_l`/`i_v`: golden COLLAPSES those, and below the struct width its value is an out-of-bounds read (`3'd37`, `1'd5`).  Declined; all byte-identical between the two binaries |
| **not a formal with a PACKED RANGE** | `g2_form108` row `i` (`bit [6:0]`) and `g4_fence108` `i_b`: golden substitutes but `reorderAssignmentPattern` REVERSES the operand vector.  `bit [6:0]` canonicalises to a `PackedArrayType`, which neither admitted kind matches, so the fence is structural rather than an extra test |
| **the ACTUAL must be a bare PACKED-STRUCT parameter with a PATTERN init** | `g3_src108` `.R(1)`, `.R(K+1)` and `.R(PLAIN)` (a plain `int` package param) are controls and are byte-identical; a pattern written INLINE at the connection (`g3_src108` `.R(rsp_t'{...})`) is a different producer on golden's side too (an `op67` over an `op33`) and is declined |
| **an OVERRIDE only, in the ELAB view only** | the arm is inside `topView && overridden`; every DEF-view row of every arm is byte-identical, and the non-overridden module/package/`cont_assign` carriers (`g4_fence108` `MB`, `oc`, `om`) never reach it |
| **the landed struct-formal precedent is untouched** | `g4_fence108` `i_s` (`parameter s108::rsp_t R`) and `g2_form108` `i_f` take the ORIGINAL `structOvPat` arm and are byte-identical on both binaries |
| **r10earl107's PORT carrier is untouched** | `g4_fence108` `i_p` (`fp108 i_p (.p(RSP))`), byte-identical |

---

## 5. THE GOLDEN GRID (`grid108.sh`, `GRID.r10earl108.txt`)

| arm | pristine c/h | patched c/h |
|---|---|---|
| `g1_home108` plain | 122 / 1 | **0 / 0** |
| `g1_home108` elab | 122 / 1 | **0 / 0** |
| `g2_form108` plain / elab | 122 / 1 | 24 / 1 |
| `g3_src108` plain / elab | 4576 / 1 | 4576 / 1 |
| `g4_fence108` plain / elab | 44 / 1 | 44 / 1 |

`g1_home108` is the corpus shape reduced and it goes **EQUAL in both views**;
its 122/1 pristine head is the corpus head object-for-object.  The other three
arms are matrices whose FIRST failure is one of §8's residues, which is what the
three-way census is for.

**THE THREE-WAY SCORE** (`score108.py` over `cen108 --raw`; the scorer REFUSES
to score two runs whose golden side differs, and it reports the ONLY-sided
bucket separately so a row flipping into or out of it cannot hide):

```
g1_home108   plain/elab  TO_GOLDEN=1+1   AWAY_GOLDEN=0 MOVED_WRONG=0
g2_form108   plain/elab  TO_GOLDEN=4+4   AWAY_GOLDEN=0 MOVED_WRONG=0
g3_src108    plain/elab  TO_GOLDEN=7+7   AWAY_GOLDEN=0 MOVED_WRONG=0
g4_fence108  plain/elab  TO_GOLDEN=0+0   AWAY_GOLDEN=0 MOVED_WRONG=0
```

**24 cells move, every one of them ONTO golden; AWAY-GOLDEN 0 and MOVED-WRONG 0
on every arm in every view, and the whole fence arm moves NOTHING.**

`g3_src108`'s seven are the ACTUAL-kind axis: a bare wildcard-imported package
param, the same param written `pkg::`-QUALIFIED, a MODULE-LOCAL struct
localparam, a POSITIONAL pattern, a `default:` fill, a NESTED struct member and
UNBASED-UNSIZED member values all substitute, and all seven land on golden.

---

## 6. THE CENSUS — predicted from PRISTINE, then re-scored (`cen108.cpp`)

`cen108`'s population is **every `param_assign` in the arena**, keyed by the Lhs
parameter's `vpiFullName` + the assign's own span + `vpiOverriden`, with the
CARRIER's own typespec kind reported as a column.  It walks the CARRIER, not the
operands, because this pass's cell is one where golden holds an OPERATION and we
hold a CONSTANT — an operand-keyed population cannot see a row that has no
operands on our side at all.  The payload is the Rhs's compare-visible shape:
the object KIND first (which is where the head fails), then a constant's
decompile/size/consttype/value or an operation's optype + operand count + each
operand's own triple, plus the actual typespec behind its `ref_typespec`.
Payloads are DEDUPED per side before the join.  **The FILE is out of the key** —
our constants carry an EMPTY `VpiFile` (RESUME.md §9).  On a corpus run the
driver prefixes each row with the test, and the scorer puts that test IN the key:
without it two databases sharing a parameter fullname collide and a last-writer
dict silently drops rows.

Calibration first: `cen108 <golden> <golden>` on `g1_home108` gives
`SAME=6 DIFF=0 ONLY-GOLDEN=0 ONLY-OURS=0`.

**PREDICTED BEFORE THE PATCHED SWEEPS** (`PREDICT_R0.txt` §4): exactly ONE
database moves, `Earlgrey_0_1`, in BOTH modes, and inside it exactly ONE cell per
mode, named:

```
work@top_earlgrey.u_pwrmgr.i_cdc.i_ast_sync.ResetValue   param_assign 9:17-9:31, ov=1
```

**MEASURED** (`CEN_corpus_score.txt`, `CEN_cand_{pre,post}_{sl,u2r}.txt`):

| corpus | keys | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG | SAME |
|---|---|---|---|---|---|---|
| surelog (956 DBs, PROCESSED asserted) | 48441 | **2** | **0** | **0** | 2256 | 35922 |
| uhdm2rtlil (1358 DBs) | 67680 | **0** | **0** | **0** | 18 | 67602 |

golden-side mismatches **0** on both (the two runs compared against the same
goldens); ONLY-sided rows 10261 / 60 and the ONLY-sided key SET is **identical**
between the two runs on both corpora, so nothing hid there.

The CANDIDATE population — a `param_assign` whose golden Rhs is an
assignment-pattern operation while ours is a constant, at a formal that is
neither a struct nor a `logic` — is **2 rows before the patch and 0 after** on
surelog, and **0 before and 0 after** on uhdm2rtlil.

---

## 7. THE GATES — all green, and the boundary that could see

| gate | result |
|---|---|
| build both, md5 | pristine `fd2870e34b3081cb23199acbdfdf838d` (= the main tree at `bb2d4f24`), patched `b3b43f254fac7ddfd263e87681d097a7` |
| golden dumps | **23 PASS / 0 FAIL** patched (and 23/0 pristine); negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| u2r testflags | CMP_EQUAL **679** / SLANG_REJECT **50** / SURELOG_FAIL **2** (default identical) |
| surelog status histogram | CMP_EQUAL 937 / CMP_NOTEQUAL 19 / DEFERRED 10 / NO_DATABASE 3 / NO_UHDM 1 / SLANG_REJECT 567 / SURELOG_FAIL 48 / TIMEOUT 1 / UNTRANSLATABLE 2 — identical pristine and patched, so no rc=139 hid as a SLANG_REJECT |
| `ct8rows` u2r tf/def vs the committed baseline AND vs this pass's own pristine | **PASS — every row byte-identical** (status AND dump column) |
| `ct8rows` surelog vs the committed baseline AND vs this pass's own pristine | **PASS — every row byte-identical over 1588 rows.  NO ROW CONVERTED** |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL, selfcheck 1357/1358 flagged |
| `byteverify SELFCHECK=1` surelog | **MOVERS 3 / 956**, PATH_SETS_IDENTICAL, selfcheck 955/956 flagged |
| canaries | surelog `ok=52 changed=0`, u2r `ok=8 changed=0`; `ctcan2` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` → every brief-protected name and family carried by a script that RUNS here |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** |

**THE THREE MOVERS, EACH ATTRIBUTED LINE BY LINE** (path-normalised, ORDER-BLIND
`uhdm-dump` diff — `ATTRIB.r10earl108.txt`):

* `Earlgrey_0_1/testflags` — **198 lines, two hunks, zero unrelated lines**: the
  `param_assign` Rhs `constant 9:30-9:31 (0/1/UINT:0/ct 9, bit_typespec)`
  becomes `operation 108:17-108:41 (op75, four BIN operands at the member spans
  and member widths, struct_typespec pwrmgr_pkg::pwr_ast_rsp_t)`, plus the newly
  minted instance-scoped struct typespec clone with its four `typespec_member`s,
  their `ref_typespec`s (fullname `…i_ast_sync.pwrmgr_pkg::pwr_ast_rsp_t.<m>`)
  and the four member `logic_typespec`s with their ranges.
* `Earlgrey_0_1/default` — **the SAME two hunks** (202 diff lines, two of which
  are the uhdm-dump header's own workdir path).
* `Scoreboard/default` — **0 lines order-blind.**  This is the documented ~50/50
  COIN (RESUME.md §9), not a content move, and its head log is byte-identical
  before and after.

**HEADS** (`rowheads.sh`, before → after): SeqDriver 33/33 both modes,
SimpleUVM 17/17, Scoreboard/default 95/95, MiniAmiq 40/40, BuildUVMPkg 52/52,
Rggen/default 0/0, Earlgrey/default 31/31 — **every one of those head logs is
byte-identical**, including Earlgrey/default whose database moved.  Only
`Earlgrey_0_1/testflags` changed: **122 → 48, one head, a NEW object in a
different family.**

**THE WIDE BOUNDARY** (`wide108.sh`, `BOUNDARY_WIDE.*`) — every `.sv` / `.v`
under a COPY of `tools/probe` **at any depth**, both views, both frozen
binaries, workdir-normalised whole-dump byte compare.  The file list is read on
fd 3 with children `</dev/null`, and PROCESSED is asserted against LISTED:

```
LISTED=4822   PROCESSED=4822   identical=9260   DIFFERING=6   no_output=378
rc histogram   A: 0×8879  3×362  4×387  139×16      B: identical, ASYMMETRIC=0
DIFFERING:  plain/elab  r10earl108repro/{g1_home108,g2_form108,g3_src108}.sv
```

**The only cells that move are three of this pass's own four arms, in both
views** — and `g4_fence108`, the arm that carries the `logic` formal, the
`logic [6:0]` formal, the `bit [6:0]` formal, the landed struct formal, the port
high_conn and the two `cont_assign` carriers, is **byte-identical**.  Every
committed r10earl45–107 arm, every uvm / buvm arm, r10earl59's
`genCaNestedModuleLhsOpRhsBinds59` binder mirror, r10earl104/105/106's clone,
adjust and cast windows and every subdirectory arm are byte-identical.  The six
moving cells ARE the positive control: the gate demonstrably sees a moved cell.
The four slang-fenced names appear in **0** listed files.

---

## 8. RESIDUES, and R0

* **R0 — THE NEXT HEAD IS NAMED AND MEASURED.**  `Earlgrey_0_1/testflags`,
  **48 cmp lines, one head**, a different family — a packed-range LEFT BOUND's
  folded constant:

  ```
  LHS (golden)  constant id:729390  54:17-54:21  |vpiDecompile:6 |vpiSize:32 |UINT:6 |ct 9
                |vpiTypespec -> ref_typespec -> int_typespec (vpiSigned:1)
                |vpiParent -> range 54:16-54:24 -> logic_typespec 54:10-54:24
  RHS (ours)    constant id:580709  54:17-54:21  |vpiDecompile:6 |vpiSize:64 |UINT:6 |ct 9
                                                  and NO typespec at all
  ```

  `own108` reports `VECTOR=0 SINGULAR=0` and the parent chain stops at a bare
  `logic_typespec`, so the owner must be found by span: the source is
  `usbdev_usbif.sv:54` `input logic [PktW:0] in_size_i` (`[` at column 16,
  `PktW` at 17-20, `0` at 22 — the only Earlgrey line 54 whose columns match).
  `expr::Compare` reads `VpiDecompile` (equal, "6"), then **`VpiSize`
  (32 vs 64 — THE FIRST FAILURE)**, then `Typespec` (an `int_typespec` ref vs
  none).  The rule to decode is what types a **packed-dimension bound that is a
  PARAMETER READ**: Surelog folds it to the parameter's own `int` width 32 and
  tags it, we fold it at the unsized 64 and leave it bare.  Note the sibling
  bounds on lines 50/53/55 of the same listing are `size 64` on BOTH sides, so
  the rule is not "every range bound" — it is specifically the one whose written
  expression is a bare parameter reference of `int` type.

* **R1 — a `logic`/`reg` formal.**  Golden COLLAPSES the substituted pattern for
  exactly this formal kind, and below the struct's width its value is an
  out-of-bounds read of `expandPatternAssignment`'s `values` vector (`3'd37`,
  `1'd5` for a 7-bit struct).  `g2_form108` rows `d`/`h`/`k` and `g4_fence108`
  `i_l`: four arm cells, ZERO corpus cells.  Deliberately declined — the values
  are heap junk, and `logic [6:0]` (where the collapse is in-bounds and gives
  `7'd44`) is ALREADY byte-identical between the two tools.

* **R2 — a formal with a PACKED RANGE.**  `bit [6:0]` substitutes on golden's
  side but `reorderAssignmentPattern` REVERSES the operand vector for a
  descending range.  `g2_form108` row `i`, `g4_fence108` `i_b`: two arm cells,
  ZERO corpus cells.  Declined; implementing the reversal would need a witness
  the corpora do not supply.

* **R3 — a NO-DEFAULT formal.**  `parameter bit R;` overridden by a struct param:
  golden substitutes, we do not, because `init0` for an overridden parameter is
  the DECLARATION DEFAULT and there is none, so the whole tail this arm lives in
  is skipped.  `g2_form108` row `g`: one arm cell, ZERO corpus cells.  A
  different entry point (the `noDefOvRhsFallback` drain), not this arm.

* **R4 — a pattern written INLINE at the connection.**  `.R(rsp_t'{...})` on a
  `bit` formal: golden emits an `op67` (a cast) over an `op33` (a concat of the
  child's own port refs and the member constants), not an `op75` at all — a
  different producer.  `g3_src108` `.R(rsp_t'{...})`: one arm cell, ZERO corpus
  cells.

* **R5 — the module-level copy's op typespec fullname.**  A module's own
  materialised copy of a package struct parameter carries `tsfn=<bare>` on
  golden and the module prefix on ours (`g1_home108` `work@g1_home108.RSP_SYNC_
  DEFAULT`, and the same row in every arm).  It is in the census PAYLOAD because
  the payload carries the whole `ref_typespec`, but `VpiFullName` is read by NO
  generated `Compare` (RESUME.md §9) — `g1_home108` is `0/0` EQUAL with the row
  present.  Pre-existing, unchanged by this pass, and invisible to the judge.

---

## 9. FILE MAP

| file | what it is |
|---|---|
| `PREDICT_R0.txt` | the head decode, our object's measured ORIGIN, the Surelog decode and the mover + census prediction, written BEFORE the patched sweeps |
| `own108.cpp` | the id-selector owner-finder (r10earl106/107's) — names every VECTOR/SINGULAR holder of an object |
| `dumpop108.cpp` | prints every assignment-pattern operation in an arena with its operands' compare-visible triples, its typespec and its carrier |
| `cen108.cpp` | the param_assign Rhs census (`--raw`); `cenrun108.sh` (`RAW=1`) drives it over a `verify_golden` workdir with PROCESSED / SKIP-NOFILE / CENRC asserted |
| `score108.py` | the three-way scorer: TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG; REFUSES to score two runs whose golden side differs, and keys on the TEST as well as the parameter |
| `g1_home108.sv` … `g4_fence108.sv`, `TOPS.txt`, `grid108.sh` | the four arms and their driver |
| `GRID.r10earl108.txt` | the grid table, the formal-type and actual-kind matrices, and the three-way scores |
| `CEN_corpus_score.txt`, `CEN_cand_{pre,post}_{sl,u2r}.txt` | the corpus score and the candidate population before and after |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the pristine and patched head logs |
| `ATTRIB.r10earl108.txt` | the order-blind whole-dump attribution of all three movers |
| `BOUNDARY_WIDE.*`, `wide108.sh` | the wide boundary: list, tally, rc histogram, rc by side, signals, and the six moving cells |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the shared gate instruments, carried so this directory reproduces on its own |
