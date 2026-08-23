# r10buvm28 — § `enumNoBaseTypespecZeroBits28` — **THE 32-LINE BuildUVMPkg HEAD CLEARED**

> **VERIFIER AMENDMENT (r10vbuvm28).** The rule as written here also CREATED
> folds where every earlier road declined, turning golden's own
> `sys_func_call` into a constant for `$bits(<instance>.<member>)` (20 def +
> 22 elab BROKE cells, corpus population 0). A 2-line gate in
> `src/ExprEmit.cpp` fixes it and changes no corpus cell. `ARMS.r10buvm28.txt`
> and this file's ARM numbers describe the UNGATED binary and are stale;
> `tools/probe/r10vbuvm28repro/{README.md,THE_FIX,ARMS,GATES}.*` describe what
> is shipped. The `g22.sv` attribution here is also corrected there: a NULL
> EDIT moves it too, so it is address-derived UB, not the type walk.


**IMPLEMENTER VERDICT: ACCEPT.** The 32-line `BuildUVMPkg` head clears in both
modes (32 → 17 cmp lines). The row stays `CMP_NOTEQUAL` at a new 17-line head;
**no corpus row converts and no baseline was edited.** Every other row of both
corpora is byte-identical, and the corpus census scores **4 cells TO-GOLDEN,
0 AWAY, 0 STILL-WRONG changed**.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY** (the copies in this
worktree) and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `6c74d2a` |
| worktree | `/tmp/wt_r10buvm28` |
| pristine binary | md5 `26fbd8c01ce0de4b3e257726f388de86` |
| patched binary | md5 `3d2fec8e71e6490ef8bc4c2acd8bde03` (reproduced twice from scratch sources) |
| production surface | `src/ExprEmit.cpp` ONLY — three static helpers and one substitution before the existing mint; **+201 lines, 0 deletions, 0 behaviour changes to any existing predicate** |
| probe surface | `tools/probe/r10buvm28repro/` only |
| deliverable | `/tmp/r10buvm28.patch`, applies clean on a FRESH `6c74d2a` |

## 0. THE HEADLINE

| | pristine | patched |
|---|---|---|
| `BuildUVMPkg` cmp lines (`2>&1`), default / testflags | **32 / 32** | **17 / 17** |
| `uhdm-cmp` heads (`grep -c '^LHS:'`) | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp md5, both modes byte-identical | `9b31531212f75a5a4bb1ebd47168e148` | `4b761630ccd5bbeeecaea4a866941655` |
| head object | a `constant UINT:0` vs our `constant UINT:32` at `uvm_pkg.sv:58248` | a golden `ref_typespec` vs `RHS: <null>` on the CAST at `uvm_pkg.sv:58249` (**R0**) |
| corpus census `VALUE`, surelog | **4** | **0** |
| surelog sweep | 937 `CMP_EQUAL` / 19 `CMP_NOTEQUAL` | 937 / 19 — **unchanged**, 0 differing rows |
| u2r sweep, both modes | 679 / 50 / 2 | 679 / 50 / 2 — 0 differing rows, **0 byte movers / 1358** |
| byte movers, surelog | — | **2 / 956**, both PREDICTED BY NAME, no coin flip |
| every other row's head | — | byte-identical (SeqDriver 60, SimpleUVM 17, Scoreboard 29, MiniAmiq 348, Earlgrey 64, Rggen PASS) |

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG

The pristine log is 32 lines `2>&1`, `grep -c '^LHS:'` = 1, and the two modes
are byte-identical. Source: `1800.2-2017-1.0/src/tlm2/uvm_tlm2_generic_payload.svh`
expanded into `pp_output/uvm_pkg.sv:58245-58250`, inside
`function void uvm_tlm_generic_payload::do_unpack(uvm_packer packer)`:

```systemverilog
  begin
    bit __array[] = new [32];
    packer.unpack_bits(__array, 32);
    __array = new [$bits(m_command)] (__array);        // :58248  <-- the head
    m_command = uvm_tlm_command_e'({ << bit { __array }});   // :58249  <-- R0
  end
```

```
LHS golden  constant: , line:58248:20, endln:58248:36
              |vpiParent: \_method_func_call: (new) @58248:15-47
              |vpiDecompile:0 |vpiSize:64 |UINT:0 |vpiConstType:9
RHS ours     constant: , line:58248:20, endln:58248:36
              |vpiDecompile:32 |vpiSize:64 |UINT:32 |vpiConstType:9
```

**THE SLOT AND THE FIELD, from the generated sources.**
`method_func_call::Compare` delegates to `tf_call::Compare`, whose order is
`Scope`, then `Tf_call_args` as a VECTOR, then `VpiName`. Both sides carry ONE
call argument, so the vector overload compares element 0 — the size slot.
`constant::Compare` runs `expr::Compare` first (`VpiDecompile` IS read) and
`"0"` vs `"32"` differs there; this is the SINGULAR overload with both sides
present, so `m_failedLhs` = golden's constant and `m_failedRhs` = ours.
32 lines = the DEPTH of the two decompiled objects (each printed twice).

**THE BRIEF'S FRAMING WAS REFUTED BY THE FIRST GOLDEN PROBE.** The brief
proposed *"Surelog resolves NOTHING inside a dynamic-array `new[]` size
expression"*. It resolves everything there. `uvm_pkg.sv`'s
`uvm_tlm_generic_payload::do_unpack` writes **NINE** `new [$bits(...)]` sites,
and golden folds every one of them to the right width except the two whose
argument is an ENUM WITHOUT A BASE TYPE:

| line | written | golden | ours (pristine) |
|---|---|---|---|
| 58240 | `new [$bits(m_address)]` `bit [63:0]` | 64 | 64 |
| **58248** | **`new [$bits(m_command)]`** `rand uvm_tlm_command_e` | **0** | **32** |
| 58256 | `new [$bits(m_length)]` `int unsigned` | 32 | 32 |
| 58264 | `new [$bits(m_dmi)]` `bit` | 1 | 1 |
| 58275 | `new [$bits(m_data[i])]` `byte unsigned []` | 8 | 8 |
| **58283** | **`new [$bits(m_response_status)]`** `uvm_tlm_response_status_e` | **0** | **32** |
| 58291 | `new [$bits(m_byte_enable_length)]` | 32 | 32 |
| 58302 | `new [$bits(m_byte_enable[i])]` | 8 | 8 |
| 58310 | `new [$bits(m_streaming_width)]` | 32 | 32 |

The `new[]` CONTEXT is not what makes the head. The base-less enum is — and it
makes the same head everywhere else too (§2's grid: class property, module
variable, package function, TYPE name, scoped TYPE name, localparam init).

## 2. THE LAW

> **An enum declared WITHOUT an explicit base type is ZERO bits wide to
> Surelog, and that zero propagates through every aggregate.**
>
> `CompileHelper::compileBits`
> (Surelog `src/DesignCompile/CompileExpression.cpp:4663`) resolves the
> argument to a typespec and asks `Bits()` for its width; `Bits()`
> (`CompileExpression.cpp:4298`) bottoms out in UHDM's `ExprEval::size`
> (`~/git-repos/UHDM/templates/ExprEval.cpp:1461-1467`):
>
> ```cpp
> case UHDM_OBJECT_TYPE::uhdmenum_typespec: {
>   if (const ref_typespec *rt = ((const enum_typespec *)ts)->Base_typespec()) {
>     bits = size(rt->Actual_typespec(), invalidValue, inst, pexpr, full);
>   }
>   break;                       // <- no Base_typespec: bits stays 0
> }
> ```
>
> `bits` is left at **0** and `invalidValue` is **never set**, so
> `compileBits`' mint branch `(reduce == Reduce::Yes) && tps && (!invalidValue)`
> fires and Surelog emits `constant` `UINT:0` / `vpiDecompile "0"` /
> `vpiSize 64` / `vpiConstType 9` where the true width is 32.
>
> A base-less enum HAS no `Base_typespec`: Surelog builds one only when the
> source wrote an enum base (`src/DesignCompile/CompileHelper.cpp:796-804`,
> guarded by `the_enum->getBaseTypespec()`). The inline-anonymous road
> (`src/DesignCompile/CompileType.cpp:1327-1332`) makes the `ref_typespec` but
> leaves its `Actual_typespec` null, which `size(nullptr)` answers 0 for just
> the same — and golden's `enum { K0, K1 } p;` is indeed 0.

**OUR OWN EMITTER ALREADY TAKES THIS DECISION FROM THIS FACT.** `buildEnumTs`
(`src/TypeEmit.cpp:5350-5352`) hangs a `Base_typespec` only when
`EnumTypeSyntax::baseType` is non-null. The predicate this pass adds
(`srlgEnumNoBase28`) reads the same syntax field, so it agrees with the
database we already write rather than inventing a second notion of "base-less".

**WHY `Reduce::No` DOES NOT SAVE THE `new[]` SITE.**
`compileBlockingAssignment`'s `paDynamic_array_new` arm
(`src/DesignCompile/CompileHelper.cpp:4483-4497`) compiles the size argument
through `compileTfCallArguments(..., Reduce::No, fcall, nullptr, false)` —
`Reduce::No`, instance `nullptr`. But `compileBits` bumps it itself: with
`m_elabMode` set and a `tps` in hand it runs `ExprEval::isFullySpecified(tps)`
and promotes `Reduce::No` to `Reduce::Yes`
(`CompileExpression.cpp:4726-4733`). A base-less enum typespec passes
`isFullySpecified`, so the fold HAPPENS — and answers 0. That is why the
sibling `$bits(m_address)` at :58240, compiled by exactly the same call with
exactly the same flags, folds to a correct 64.

**THE ROAD NOT TAKEN, recorded as refuted.** `ExprEval::size`'s
`uhdmoperation` case (which sums operands only for `vpiConcatOp` and otherwise
returns 0 without `invalidValue`) is buvm27's documented "0 without
invalidValue" road, and it is NOT this head's road: the argument here is a bare
name, `getTypespec` finds the enum typespec first, and the zero comes from the
enum arm. The two roads are separated by the grid: `$bits(p_int)` over
`typedef enum int {...}` is golden's **32**, so an enum ARGUMENT as such is not
what returns 0 — only a base-less one is.

## 3. THE GOLDEN GRIDS, RUN BEFORE ANY CODE

| grid | what it pins |
|---|---|
| `g28_a_enum.sv` | every enum BASE spelling × every home |
| `g28_b_shapes.sv` | where the ZERO propagates: arrays, structs, unions, type names, dotted members, `$clog2` of it, a declaration RANGE written from it |
| `g28_a0_head.sv` | the corpus head in 36 lines (three sibling `new [$bits(...)]` sites, one of them the enum) |
| `g28_c_castr0.sv` | R0: the cast-over-a-stream probe |

### 3a. The BASE spelling decides, and nothing else (grid A, class property)

| written | golden | ours before | ours after |
|---|---|---|---|
| `typedef enum { A0, A1, A2 } e_bare;` | **0** | 32 | **0** |
| `typedef enum { H0=1, H1=0, H2=-1 } e_neg;` | **0** | 32 | **0** |
| `enum { K0, K1 } p_anon;` (inline) | **0** | 32 | **0** |
| `typedef e_bare e_alias;` (through the alias) | **0** | 32 | **0** |
| `typedef enum int { B0, B1 } e_int;` | 32 | 32 | 32 |
| `typedef enum integer { .. }` | 32 | 32 | 32 |
| `typedef enum shortint { .. }` | 16 | 16 | 16 |
| `typedef enum byte { .. }` | 8 | 8 | 8 |
| `typedef enum bit [3:0] { .. }` | 4 | 4 | 4 |
| `typedef enum logic [7:0] { .. }` | 8 | 8 | 8 |

### 3b. Every HOME behaves the same (grid A)

| home | written | golden | before → after |
|---|---|---|---|
| class property | `$bits(p_bare)` | 0 | 32 → 0 |
| TYPE name | `$bits(e_bare)` | 0 | 32 → 0 |
| SCOPED type name | `$bits(p2::e_bare)` | 0 | 32 → 0 |
| operand of an operation | `$bits(p_bare) + 1` | 0 | 32 → 0 |
| package function, TOP listing | `$bits(e_bare)` | 0 | 32 → 0 |
| module variable (ported module) | `$bits(mv)` | 0 | 32 → 0 |
| module, scoped type | `$bits(p2::e_bare)` | 0 | 32 → 0 |
| **must NOT move:** `$size(p_bare)` | KEEP | KEEP | KEEP |
| **must NOT move:** `$bits(A0)` (enum MEMBER) | KEEP | KEEP | KEEP |
| **must NOT move:** `$bits(lv)` local / `$bits(fa)` formal | KEEP | KEEP | KEEP |

### 3c. The zero PROPAGATES (grid B)

| written | golden | before → after |
|---|---|---|
| `e_bare p_ea [4]` → `$bits(p_ea)` | **0** | 128 → 0 |
| `$bits(p_ea[0])` (the ROOT rule, § `bitsSelectIgnoredRootBits95`) | **0** | 128 → 0 |
| `e_bare p_ed []` / `p_eq [$]` / `p_eaa [string]` | **0** each | 32 → 0 |
| `e_bare p_e2d [2][3]` | **0** | 192 → 0 |
| `struct packed { e_bare c; bit [7:0] d; }` | **8** (SUM, 0+8) | 40 → 8 |
| `struct { e_bare c; bit [7:0] d; }` (unpacked) | **8** | 40 → 8 |
| the TYPE names `$bits(ps_t)` / `$bits(us_t)` | **8** / **8** | 40 → 8 |
| `union packed { e_b4 a; bit [3:0] b; }` (MAX, no base-less leaf) | 4 | 4 → 4 (untouched) |
| `$clog2($bits(e_bare))` | inner **0** | inner 32 → 0 |
| module `initial` / three module localparams / a cont-assign operand | same values | all → golden |

## 4. THE CORPUS CENSUS, GOLDEN vs OURS, MADE BEFORE THE PATCH

`ct28cen.cpp` / `cen28.sh` / `join28.py` are r10buvm27's tools reused verbatim
(paths re-pointed): one row per CANDIDATE SPAN — a type-query `sys_func_call`,
or a `constant` with `vpiSize==64 && vpiConstType==vpiUIntConst` (the exact
signature `compileBits` mints) — joined golden-against-ours on the SPAN alone
(our expression objects carry an EMPTY `VpiFile`, so the file travels as an
attribute, never as key).

| | surelog 956 DBs | | uhdm2rtlil 1358 DBs | |
|---|---|---|---|---|
| | pristine | patched | pristine | patched |
| SAME | 919 | **923** | 214 | 214 |
| **VALUE** | **4** | **0** | 0 | 0 |
| KEEP_G_FOLD_O | 15 | 15 | 0 | 0 |
| FOLD_G_KEEP_O | 0 | 0 | 0 | 0 |
| OTHER | 246 | 246 | 2 | 2 |
| OUT_OF_SCOPE_DIFF | 17687 | 17687 | 1070 | 1070 |

The **4** `VALUE` cells were the head and nothing else:

```
VALUE  default_BuildUVMPkg    58248:20-58248:36  G=CONST:0  O=CONST:32
VALUE  default_BuildUVMPkg    58283:20-58283:44  G=CONST:0  O=CONST:32
VALUE  testflags_BuildUVMPkg  58248:20-58248:36  G=CONST:0  O=CONST:32
VALUE  testflags_BuildUVMPkg  58283:20-58283:44  G=CONST:0  O=CONST:32
```

They are gone; every other column is byte-unchanged in both corpora.
The 15 `KEEP_G_FOLD_O` are uvm95's R3 (the out-of-block over-fire), and this
pass checked each by SOURCE that its argument holds no enum at all —
`$bits(uvm_reg_data_t)` (a `bit [63:0]` typedef) and
`$bits(abstractions.size())` (an `int`). All 15 are byte-identical after.

**THE FENCE.** Every `$bits`/`$size`/`$clog2` cell of the whole `uhdm2rtlil`
corpus agreed before this pass and still agrees after it (0/0/0 in both
directions, both modes; **0 byte movers over 1358 databases**). uvm-1.2 carries
`uvm_tlm_generic_payload` too, but writes `do_unpack` without the
`$bits`-per-field expansion, so none of the five uvm-1.2 row-modes has a cell
of this law at all — which is why the census finds the disagreement in exactly
two databases, both `BuildUVMPkg`.

## 5. THE MOVER PREDICTION, MADE FROM THE PRISTINE DATABASES

`predict28.py` scans EVERY span of the pristine census — including the ones
`join28.py` files as `OUT_OF_SCOPE`, where a macro-body fold would hide — for
the only signature this law can produce: **golden folded to 0, we folded to
something else**. On the surelog corpus the type-query rows it returns are
exactly the four `BuildUVMPkg` cells above; on `uhdm2rtlil` it returns none.
The remaining `TO-GOLDEN-ZERO` rows it prints are single-character spans
(literal constants, range bounds) inside rows that are `CMP_EQUAL` in **both**
modes — census multiplicity artifacts, not `$bits` sites.

**PREDICTED: `default/BuildUVMPkg-bf853d43` and `testflags/BuildUVMPkg-bf853d43`,
and no other database in either corpus.**
**MEASURED (byteverify SELFCHECK=1): `MOVERS 2 / 956` — exactly those two —
and `MOVERS 0 / 1358` on `uhdm2rtlil`.** No Scoreboard coin flip this run.

## 6. THE PATCH

`src/ExprEmit.cpp` only, +201 lines, 0 deletions:

* `srlgEnumNoBase28(const Type&)` — true iff the canonical type is an
  `EnumType` whose `EnumTypeSyntax::baseType` is null (the same syntax field
  `buildEnumTs` already reads to decide whether to emit a `Base_typespec`).
* `srlgEnumZeroBits28(const Type&, uint64_t& out, bool& reached, int depth)` —
  `ExprEval::size` transcribed with the base-less-enum leaf counted as ZERO:
  fixed unpacked dimensions multiply and unsized ones count as ONE
  (§ `bitsSelectIgnoredRootBits95`), packed dimensions multiply their element,
  struct members SUM, union members take the MAX, `real`/`shortreal` are 32,
  `realtime`/`time` have no answer. **`reached` is the fence**: it is set only
  when the walk actually met a base-less enum leaf.
* `bitsEnumNoBaseValue28(const Expression&, std::optional<uint64_t>&)` — picks
  the typespec `compileBits` would have taken (the ROOT declaration for a bare
  name under any number of selects, the named type for a TYPE argument, the
  argument's own type for the dotted road) and answers only when `reached`.
* one substitution, placed AFTER every road that computes a width and BEFORE
  the existing mint, so it covers the § 95 root width, the § 61 own-property
  fallback and the root-context `tryEval` with one rule.

**No existing predicate changed.** The gate that decides KEEP-vs-FOLD is
untouched, so no cell that kept a `sys_func_call` now folds and no cell that
folded now keeps — the ONLY thing that can differ is the digits of a constant
whose type reaches a base-less enum. That is why 2312 of the 2314 corpus
databases are byte-identical.

## 7. BOUNDARY — AND THE TWO ATTRIBUTION CONTROLS

`bound28.sh` over a COPY of `tools/probe`, **no path filter**, `.sv` AND `.v`,
DEF and ELAB, fd-3 list, children `</dev/null`, PROCESSED asserted:

```
LISTED=3348 FENCED_SKIPPED=0 PROCESSED=3348 MOVED=10 NO_OUTPUT_PAIRS=274
PROCESSED-ASSERT-OK
```

Six of the ten are this pass's own grids × two views (`g28_c_castr0.sv`, the R0
probe, carries no type query and does not move). The two
earlier-pass arms that moved were re-measured against golden with `four28.py`:

| arm | four28 verdict |
|---|---|
| `r10uvm61repro/v4_type.sv` | **FIXED 1, BROKE 0** — `$bits(m_nb)` over `typedef enum { EA, EB, EC } noBase_t;` was 32, golden is **0**, patched is 0. The arm's own comment predicted "(32)"; golden disagrees with the arm. |
| `r10buvm22repro/g22.sv` | **FIXED 0, BROKE 0, STILL-CHANGED 3** — golden emits a `string_typespec` at `70:28` / `71:28` / `72:28` and **no constant at all**; ours emits a garbage `22371705` before and `22375801` after. |

`g22.sv` contains no base-less enum, so the VALUE law cannot reach it. Two
extra binaries settle which half of the patch did:

* **NULL-EDIT control** (pristine + 60 emitted `extern "C"` functions nothing
  calls; comment-only edits produce a byte-IDENTICAL binary and were
  discarded): `g22.sv` **0** diff lines vs pristine. A bare binary/layout
  change does not move it.
* **WALK-ONLY control** (the patch with `bitsEnumNoBaseValue28` doing the whole
  type walk and then `return false`): `g22.sv` **12** diff lines vs pristine
  and **0** vs patched, while `v4_type.sv` is **0** vs pristine and **4** vs
  patched.

So the `g22` mover is the TYPE WALK's slang-arena side effect, not the law, and
it lands on buvm27's **R-G22RANGE**: the unchecked
`ct.as<FixedSizeUnpackedArrayType>()` at `src/TypeEmit.cpp:10359` applied to
the ASSOCIATIVE arrays of `typedef int ka_str_t[int];`. Both numbers are
garbage read through the wrong type; golden has no constant there at all, so
neither is closer to golden. **The side effect reaches no corpus database**:
byteverify over 956 + 1358 pristine/patched pairs found exactly the two
predicted movers.

## 8. NEW R0 AND RESIDUES

**R0 — the new `BuildUVMPkg` head**, both modes, **17 lines**, one head, cmp
logs byte-identical between modes (md5 `4b761630ccd5bbeeecaea4a866941655`), at
`uvm_pkg.sv:58249` (and `:58284`), the statement immediately after the cleared
one:

```
LHS golden  ref_typespec: (uvm_pkg::uvm_tlm_generic_payload::do_unpack)
              |vpiParent: \_operation: @58249:17-58249:58
              |vpiActual: \_enum_typespec: (uvm_pkg::uvm_tlm_command_e) @58491:37
RHS: <null>
```

Golden wraps the streaming concatenation in a CAST `operation` (`vpiOpType 67`)
spanning the whole `uvm_tlm_command_e'({ << bit { __array }})`, and hangs the
target `enum_typespec` off it as `vpiTypespec`. **We drop the cast entirely** —
our assignment's `vpiRhs` is the bare stream operation (`vpiOpType 72`) at
`58249:46-55`. `expr::Compare` reads `Typespec` before `operation::Compare` ever
reaches `VpiOpType`, so the SINGULAR overload fires on the missing ref and
prints `RHS: <null>`; 17 lines is that ref's decompile depth.

`g28_c_castr0.sv` characterises it: a cast whose operand is a STREAMING
CONCATENATION loses its cast operation for **every** target type (base-less
enum, based enum, packed struct, `int`) — golden 7 `operation` nodes per
statement, ours 4 — while a cast over any other operand (a plain expression, a
plain concatenation) keeps it (3 vs 3, 6 vs 6). **Corpus population: 2 spans ×
2 modes = 4 cells, `BuildUVMPkg` only** (`grep -c "'({ *<< *bit"` is 2 in the
1800.2 tree and **0** in uvm-1.2). The fix is an emitter one — bind the
`ConversionExpression` that slang builds for `T'(<stream>)` instead of
unwrapping to its operand — and it is the cheapest head in the queue.

**Residues this pass measured and deliberately left**

* **R-ENUMPARAM — an ELABORATED parameter's own value.**
  `localparam int LPA = $bits(q28::e_bare);` gets TWO copies; the definition
  copy now carries golden's 0, the elaborated `module_inst` copy still carries
  32, because that copy takes `ParameterSymbol::getValue()` — **slang's** own
  constant evaluation, which never consults this emitter's `$bits` road.
  **3 arm cells (grid B `LPA`/`LPB`/`LPC`) + 1 in grid A, corpus population 0**
  (`predict28.py` finds no such cell in either corpus). Fixing it means
  intercepting parameter values, a much wider surface than this head needed.
* **R-ENUMRANGE — a declaration RANGE written from a base-less enum.**
  `logic [$bits(e_bare)-1:0] p_dep;` is golden's `[-1:0]` (a 2-bit
  declaration, `$bits` = 0) where slang builds `[31:0]` and we follow it; and
  `$bits(p_dep)` is then golden's **2** against our 32. The range bound is
  evaluated by slang at type construction, not by the `$bits` emitter, so this
  pass cannot reach it. **2 arm cells (grid B lines 28 and 54), corpus
  population 0.**
* **R-ENUMDOTTED — a member reached through `.` on a class property.**
  `$bits(p_ps.c)` is golden's **0** and `$bits(p_ps.d)` golden's **8**; we KEEP
  the call for both, because `bitsOwnClassPropFold61` refuses a MemberAccess by
  construction. PRE-EXISTING and byte-unchanged by this pass. **3 arm cells,
  corpus population 0.**
* **§ `bitsOutOfBlockNoReduce95` (uvm95's R3) — still 15 corpus cells, still
  not shipped.** Unchanged, and re-verified byte-for-byte here.
* **Two wrong→wrong cells this pass moved, both corpus population 0, both
  named in `ARMS.r10buvm28.txt` as `STIL`:** `$bits(pv_bare)` over a PACKAGE
  variable (golden KEEPS, we folded 32 and now fold 0) and `$bits(arr_t)` over
  an unpacked-array TYPEDEF NAME (golden KEEPS, we folded 128 and now fold 0).
  Both are pre-existing over-fires of § `srlgBitsFoldArg` / `r9DimsLiteral`,
  and the kind mismatch `uhdm-cmp` sees is identical before and after.
* **buvm27's queue, RE-RANKED** by what this pass measured:
  1. **R0 above** — 4 corpus cells, one emitter site, and it is the current
     head. Cheapest thing in the campaign right now.
  2. **R-G22RANGE** — the unchecked `FixedSizeUnpackedArrayType` cast at
     `src/TypeEmit.cpp:10359`. This pass paid for it AGAIN: it is the only
     boundary mover that needed two extra binaries to attribute. It is a
     genuine wrong-type read whose value shifts with any allocation-order
     change, so every future pass that touches slang's lazy types pays the same
     toll. **Fix it next after R0.**
  3. **R-GENFOLD** (buvm27's) — a gen-scope `Reduce::No` context for `$bits`;
     would retire buvm27's verifier fence AND uvm95's R3's 15 corpus cells.
     Unchanged by this pass.
  4. **R-DOTTED** (buvm27's / uvm95's R2) — now shares a road with R-ENUMDOTTED
     above: both are `compileBits`' `paComplex_func_call` → `decodeHierPath`
     arm, which resolves struct members. Fixing R2 fixes 6 + 3 arm cells.
  5. **R-CONCATOVER**, **R-BOUNDEDQ**, buvm26's **R-TRAILMEM** / **R-LITARG** —
     unchanged and unmeasured by this pass.

## 9. REPRODUCE

```sh
g++ -O2 -std=c++17 ct28cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10buvm28_ct28cen
./cen28.sh <sweep workdir root> <censusdir>        # golden + ours, every row-mode
python3 join28.py <censusdir> [--verbose]          # SAME / VALUE / KEEP_G_FOLD_O
python3 predict28.py <PRISTINE censusdir>          # the mover prediction
PRI=… PAT=… MODE=def  ./three28.sh $PWD/g28_a0_head.sv     # builds golden + both
PRI=… PAT=… MODE=elab ./three28.sh $PWD/g28_b_shapes.sv
python3 spanval.py <G.dump> <OURS.dump> [lo hi] [-v]       # per-span golden vs ours
python3 four28.py  <G.dump> <PRI.dump> <PAT.dump> [lo hi]  # ALREADY-OK/FIXED/BROKE/STILL
PRI=… PAT=… ROOT=<a COPY of tools/probe> ./bound28.sh      # BOTH views, .sv AND .v
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <pat wd> <pris wd>
UHDM_CMP=~/git-repos/UHDM/build/bin/uhdm-cmp ./rowheads.sh <wd> <outdir> \
    SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
./pins28.sh <pat wd> <pris wd> ; bash canaudit.sh canaries.sh ctcan2.sh
~/git-repos/Surelog/build/bin/surelog -parse -nocache -d coveruhdm g28_a_enum.sv
```

Evidence files: `INPUTS.r10buvm28.txt`, `GATES.r10buvm28.txt`,
`CENSUS.r10buvm28.txt`, `PREDICT.r10buvm28.txt`, `BOUNDARY.r10buvm28.txt`,
`ARMS.r10buvm28.txt`, `head_pris_BuildUVMPkg.cmp`, `head_pat_BuildUVMPkg.cmp`.
