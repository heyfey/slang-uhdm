# r10uvm129 — § `declArrayElemVarSignedIsAtomKeyword129` — **A DECLARATOR ARRAY'S ELEMENT VARIABLE IS SIGNED ONLY WHEN AN INTEGER-ATOM KEYWORD IS WRITTEN** — the BuildUVMPkg ×2 **54-line head CLEARED**

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `aef5007` |
| pristine binary | reproduced the campaign's `build/slang-uhdm` at `aef5007` BYTE FOR BYTE (md5 `e36cb36103acbc3c2e44797ddc81a745`), frozen `chmod 555` before any sweep |
| patched binary | md5 `991fceb46f6776bfbb7627c52cd3ccd4`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` — ONE new helper (`declArrayElemVarSigned129`) carrying the law; `src/TaskFuncEmit.cpp` + `src/StmtEmit.cpp` — the FOUR existing `VpiSigned` call sites, re-asked |
| probe surface | `tools/probe/r10uvm129repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **BuildUVMPkg default / testflags** | **54** | **60** | 1 — a **NEW HEAD**, a different object and a different family |
| SeqDriver default / testflags | 17 | 17 | 1 unchanged, head log **BYTE-IDENTICAL** |
| SimpleUVM default / testflags | 124 | 124 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Scoreboard default | 124 | 124 | 1 unchanged, head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 17 | 17 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 90 / 150 | 90 / 150 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |

The a-priori prediction, made from the PRISTINE databases before the patched
binary existed, named **TWO** movers out of **2314** databases and no others.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduces the master's head log
`/tmp/buildpkg_head_b7995eb.cmp` **BYTE FOR BYTE** for BuildUVMPkg/default (and
line for line, ids aside, for BuildUVMPkg/testflags). Fifty-four lines, one
head, one object — an `enum_var`:

```
LHS (golden)                                   RHS (ours)
enum_var: (uvm_pkg::uvm_reg_hw_reset_seq::do_block::field_check_restore)
|vpiParent: array_var (same name/span)         |vpiParent: array_var (same)
|vpiTypespec: ref_typespec                     |vpiTypespec: ref_typespec
  |vpiActual: enum_typespec(uvm_pkg::uvm_check_e)  |vpiActual: enum_typespec(uvm_pkg::uvm_check_e)
                        @62383:35-62383:46                             @60837:4-60840:18
                                               |vpiSigned:1        <-- THE ONLY
                                                                       COMPARE-VISIBLE
                                                                       DIFFERENCE
```

**The object.** `uvm_reg_hw_reset_seq.svh:122`, inside
`uvm_reg_hw_reset_seq::do_block()` (BuildUVMPkg's 1800.2 `pp_output` line
79885):

```systemverilog
   uvm_check_e field_check_restore[uvm_reg_field];
```

an ASSOCIATIVE array whose element type NAMES the package enum typedef
`uvm_check_e` (`uvm_object_globals.svh`, an implicit `int` base).

### 1a. WHICH HALF THE JUDGE ACTUALLY READS — a measured correction

The head log shows TWO disagreements. Only ONE of them is a defect:

* **`vpiSigned:1` on the element `enum_var`.** `variables::Compare`
  (UHDM `build/generated/src/variables.cpp:251`) reads `VpiSigned`, and
  `expr::Compare` — which runs FIRST and compares `Typespec()` — returns 0 on
  this pair, so `VpiSigned` is the field that fails. **This is the head.**

* **The `enum_typespec`'s SPAN** (`62383:35-62383:46` golden vs
  `60837:4-60840:18` ours). **No generated `Compare` reads `VpiFile`,
  `VpiLineNo` or `VpiColumnNo`** — it is DUMP-ONLY. And the OBJECT is not
  wrong either: `cen129`'s id-free identity family shows both producers build
  **exactly two** `enum_typespec(uvm_pkg::uvm_check_e)` objects with **the same
  referrer counts (16 and 5)**, the same name and the same
  `vpiInstance = package(uvm_pkg)`, and the element variable and the
  `array_typespec`'s `Elem_typespec` bind the SAME one on both sides
  (`shared=Y`, `elevts_nrefs=16` on both):

  ```
  GOLDEN  TSOBJ enum_typespec|uvm_pkg::uvm_check_e  62383:35-62383:46  nrefs=16
          TSOBJ enum_typespec|uvm_pkg::uvm_check_e  79053:35-79053:46  nrefs=5
  OURS    TSOBJ enum_typespec|uvm_pkg::uvm_check_e  60837:4-60840:18   nrefs=16
          TSOBJ enum_typespec|uvm_pkg::uvm_check_e  60837:4-60840:18   nrefs=5
  ```

  Golden's spans are FOSSILS of a USE site (`62383:35` is the `uvm_check_e`
  written in `mirror_reg`'s io_decl, `79053:35` another one) because
  `compileTypespec`'s named arm calls `populateCoreMembers` on the SHARED
  object it hands back; ours are the typedef's own body. **The listing-object
  binding is already golden's**, so the brief's "ours binds the enum-BODY
  object" is a SPAN reading, not an identity one — recorded as a refuted
  framing rather than dressed up, and left untouched (re-spanning a shared
  package listing object is a whole-corpus re-point with no compare-visible
  gain).

---

## 2. THE DECODED SURELOG MODEL

`CompileHelper::compileVariable`
(`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:250-760`) is a **CLOSED
switch on the PARSE NODE of the written data type** — eighteen `case` labels and
a `default`. `var->VpiSigned(isSigned)` appears in exactly **SEVEN** of them:

| written node | variable | `VpiSigned` |
|---|---|---|
| `paIntegerAtomType_Int` (:452) | `int_var` | **yes** |
| `paIntegerAtomType_Integer` (:462) | `integer_var` | **yes** |
| `paSigning_Unsigned` (:472) | `int_var` | **yes** |
| `paSigning_Signed` (:482) | `int_var` | **yes** |
| `paIntegerAtomType_Byte` (:492) | `byte_var` | **yes** |
| `paIntegerAtomType_LongInt` (:502) | `long_int_var` | **yes** |
| `paIntegerAtomType_Shortint` (:512) | `short_int_var` | **yes** |
| `paIntVec_TypeLogic` / `_TypeReg` (:437) | `logic_var` | no |
| `paIntVec_TypeBit` (:527) | `bit_var` | no |
| `paIntegerAtomType_Time` (:518) | `time_var` | no |
| `paNonIntType_Real` / `_ShortReal` | `real_var` / `short_real_var` | no |
| `paString_type` | `string_var` | no |
| `paChandle_type` | `chandle_var` | no |
| `paClass_scope` | via `getSimpleVarFromTypespec` | no |
| **`slStringConst` (a NAMED type, :338)** | **via `getSimpleVarFromTypespec`** | **no** |
| `default` — implicit type (:753) | `logic_var` | no |

`getSimpleVarFromTypespec` (`CompileType.cpp:78-235`) is a SECOND closed
dispatch — on the TYPESPEC kind this time, twelve rows — and it sets
`Actual_typespec` and **nothing else**; `VpiSigned` is never touched on any row.
That is why every NAMED type, an `int`-based enum typedef included, is unsigned.

`isSigned` is itself a SYNTAX question (`CompileType.cpp:456-460`):

```cpp
bool isSigned = true;
const NodeId signId = fC->Sibling(variable);
if (signId && (fC->Type(signId) == VObjectType::paSigning_Unsigned)) isSigned = false;
```

— "signed unless the word `unsigned` follows the keyword", the same reading
§ `implicitRetWrittenSigning70` already made for the RETURN variable.

**The array wrapper changes none of it.** `CompileStmt.cpp:1189-1255` compiles
the element with this very `compileVariable` call, THEN wraps it in an
`array_var` (blanking the element's name and sharing the element typespec into
`Elem_typespec`). So `t a[2]`, `t a[]`, `t a[$]`, `t a[k]` and `t a[2][3]` all
answer the table above — measured in grid C.

---

## 2a. VERIFIER CORRECTIONS TO §2 AND §4 (r10v129, measured)

Three statements above are inaccurate as written.  None of them changes a line
of production code — the four sites this pass touches are all block-item /
subroutine sites and all of them answer the corrected table the same way — but
the citations must match the checkout they cite.

1. **EIGHT, not seven.**  `var->VpiSigned(isSigned)` appears **eight** times in
   `compileVariable`, at `CompileType.cpp:418 454 464 474 484 494 504 514`
   (the table's line numbers are two low throughout).  The eighth, `:418`, is
   inside the NAMED-TYPE arm itself: when the name resolves to nothing and the
   caller passed `implicitInt=true`, Surelog mints an `int_var` and DOES stamp
   the flag.  It cannot fire for a declarator array: the block-item caller
   `CompileStmt.cpp:1191` passes the argument's default `false`
   (`CompileHelper.h:278`).  "and NOWHERE ELSE" in §2 should read "and nowhere
   a declarator array can reach".

2. **The law needs its SCOPE.**  As stated, §4 predicts that `int a[N]` carries
   `vpiSigned` wherever it is written.  Golden stamps it only in a
   SUBROUTINE or BLOCK-ITEM declaration.  At MODULE, CLASS-PROPERTY or PACKAGE
   scope golden's element variable carries NO `vpiSigned` even for the five
   atom keywords — measured on Surelog goldens: `int modInt129[47]` (module
   variable) `sgn=0`, `int propInt129[27]` (class property) `sgn=0`,
   `integer modIntg129[49]` `sgn=0`, against `int fnInt129[15]` (function
   local) `sgn=1` and `int itInt129[33]` (class task local) `sgn=1` in the same
   file.  This is exactly why residue R2 exists and why it is NOT reachable
   from this pass's four sites; the law should read "the element variable of a
   declarator array **declared as a block item**".

3. `pred129.sh` could not reproduce its own evidence — see the VERIFIER
   CORRECTION block in `PREDICT.r10uvm129.txt`.

Everything else in §1, §1a, §2, §3, §5–§9 reproduced bit for bit; see
`tools/probe/r10v129repro/README.md`.

---

## 3. OURS ASKED THE TYPE, AND ASKED IT TWICE

Four call sites minted the element variable's flag from
`elem->isSigned()` — the CANONICAL type's signedness:

| site | file |
|---|---|
| 1 queue / dynamic | `TaskFuncEmit.cpp` `makeQueueDynArrayVar` |
| 2 associative | `TaskFuncEmit.cpp` `makeAssocArrayVar` ← **the head** |
| 3 fixed-size, tf block-item | `TaskFuncEmit.cpp` `emitTaskFuncs` |
| 4 fixed-size, begin-block | `StmtEmit.cpp` `emitStmt` |

and `makeReturnVar` (`EmitHelpers.h`) stamped it a SECOND time off the canonical
`PredefinedIntegerType`, so a declaration that NAMES a typedef of an integer
atom (`typedef int t; t a[2]`) arrived at the call site **already flagged**. An
`if (...) VpiSigned(true)` could not clear that; all four sites therefore now
**WRITE** the law's answer (`reg->VpiSigned(<predicate>)`) — a no-op wherever
the factory left the flag alone, and a clear on exactly the named-atom-typedef
cells. Measured: without the write, grid A and grid E kept 6 wrong cells
(`auditTick129`, `pixelRow129`, `skewPair129`, `scopedInt129`, `chainInt129`,
`innerTally129`); with it, 0.

---

## 4. THE LAW

> **§ `declArrayElemVarSignedIsAtomKeyword129`.** The ELEMENT VARIABLE of a
> DECLARATOR ARRAY carries `vpiSigned` only when the declaration's **WRITTEN
> BASE TYPE is one of the five INTEGER ATOM KEYWORDS** (`int`, `integer`,
> `byte`, `shortint`, `longint`), and then its value is "no `unsigned` keyword
> was written" — never the element type's computed signedness. `logic`, `reg`,
> `bit`, `time`, `string`, `real`, `shortreal`, `chandle`, `event`, an INLINE
> enum or struct, and **EVERY NAMED TYPE** (a typedef of an integer atom
> included) carry NO `vpiSigned` at all. The element variable's CLASS, its
> typespec, the `array_typespec` and the `array_var` are exactly what they
> already were.

**The gate is the WRITTEN SYNTAX NODE, never the canonical type** — the same
shape of law as uvm126's element-TYPESPEC rule, one level up.

**`ImplicitType` is EXCLUDED and keeps the pre-pass answer.** Surelog emits no
variable at all for the `var`-keyword locals that produce it (grid E
`sgnImplicit129` / `varInt129` / `varLogic129` are ONLY-OURS on both binaries),
so the arm has no golden to be measured against and must not be moved on a
guess. Those three cells are byte-identical pristine vs patched.

**This is a vpiSigned-only law.** `cen129` also reports the element variable's
CLASS, the element typespec's kind/name/span/instance, the `shared` flag and the
referrer count, and the scorer's `COLLATERAL` counter fires on ANY pristine →
patched change outside the law's field. It is **0** in every grid, in both
views.

---

## 5. THE GRIDS

`ARMS.r10uvm129.txt` says what each arm is for. Every arm is built by `arm129.sh`
with BOTH frozen binaries in BOTH views and with Surelog `-parse` for the golden.

| grid | cells | LAW-WRONG (pristine) | LAW-FIXED | LAW-BROKE | LAW-STILL-WRONG | COLLATERAL |
|---|---|---|---|---|---|---|
| `g129_a_kinds.sv` (31 element-type forms) | 31 | 9 | **9** | **0** | **0** | **0** |
| `g129_b_homes.sv` (11 homes × 2 types) | 20 | 8 | **8** | **0** | **0** | **0** |
| `g129_c_dims.sv` (8 dimension kinds × 2 types) | 14 | 7 | **7** | **0** | **0** | **0** |
| `g129_d_bases.sv` (10 enum bases, 1-3 instances) | 16 | 12 | **12** | **0** | **0** | **0** |
| `g129_e_edge.sv` (13 edge forms) | 13 | 8 | **8** | **0** | **0** | **0** |
| **total, DEF view** | **94** | **44** | **44** | **0** | **0** | **0** |
| **total, ELAB view** | **94** | **44** | **44** | **0** | **0** | **0** |

The DEF and ELAB tables are IDENTICAL cell for cell.

**The positive controls fire.** Grid B's `int` twin of every enum cell
(`fnCount129`, `blkCount129`, `spinCount129`, `mtCount129`, `oobCount129`,
`fnLocal129`) is `vpiSigned:1` in golden and stays `vpiSigned:1`; grid A's
`plainCount129` / `scoreBoard129` / `crumbTrail129` / `stepDelta129` /
`ledgerBig129` keep theirs, and `quotaLeft129` (`int unsigned`) and
`tokenCount129` (`byte unsigned`) keep their `0`. A rule that simply stopped
stamping would have broken eleven cells; LAW-BROKE is 0.

**Golden's own table, read straight off grid A** (element variable | vpiSigned):

| written element type | golden | | written element type | golden |
|---|---|---|---|---|
| `int` | `int_var` **S** | | `string` | `string_var` — |
| `int unsigned` | `int_var` — | | `real` / `shortreal` | `real_var` / `short_real_var` — |
| `integer` | `integer_var` **S** | | enum typedef, ANY base | `enum_var` — |
| `byte` | `byte_var` **S** | | typedef of `int` | `int_var` — |
| `byte unsigned` | `byte_var` — | | typedef of `byte` | `byte_var` — |
| `shortint` | `short_int_var` **S** | | typedef of `shortint` | `short_int_var` — |
| `longint` | `long_int_var` **S** | | packed struct typedef | `struct_var` — |
| `time` | `time_var` — | | packed **signed** struct typedef | `struct_var` — |
| `logic` / `bit` | `logic_var` / `bit_var` — | | class handle | `class_var` — |
| `logic signed [3:0]` | `logic_var` — | | INLINE enum / struct | `logic_var` — |
| `bit signed [7:0]` | `bit_var` — | | `event` | `logic_var` — |

Grid D adds the sharpest cell of all: **the enum's BASE decides nothing.**
`enum {..}`, `enum int`, `enum int unsigned`, `enum byte`, `enum byte unsigned`,
`enum shortint`, `enum longint`, `enum bit [1:0]`, `enum logic [2:0]` and
`enum integer` are ALL unsigned in golden, and 1, 2 or 3 instances of the same
typedef all answer the same — it is a per-DECLARATION-SITE rule with a
per-declaration answer, not a property of the typedef.

---

## 6. THE CORPUS: PREDICTED, THEN MEASURED

`pred129.sh` walks all **2314** pristine databases in both workdirs, reads each
row's OWN golden out of its `cmds.txt`, censuses both with `cen129` and scores
them. **Before the patched binary was built** it named the mover set:

```
PREDICT law=1 tsspan=66 default/BuildUVMPkg-bf853d43
PREDICT law=1 tsspan=66 testflags/BuildUVMPkg-bf853d43
SCANNED=2314 PREDICTED_MOVERS=2 WITH_TSSPAN=13 NO_GOLDEN=0
```

Two databases, one law cell each, the same declaration in both.
**uhdm2rtlil holds not one law cell in 1358 databases**, and the other eight
UVM row-modes hold none either — the declaration is simply not in their
listings (`cen129` finds no `field_check_restore` at all in SeqDriver's golden
OR in ours).

`SELFCHECK=1 byteverify.sh` afterwards: **MOVERS 2 / 956** surelog (those two
names, no others) and **0 / 1358** uhdm2rtlil, `PATH_SETS_IDENTICAL` on both.
`attr129.sh` attributes each one line by line and ORDER-BLIND:

```
default/BuildUVMPkg    in-order=1  ORDER-BLIND=1
    <                 |vpiSigned:1
testflags/BuildUVMPkg  in-order=1  ORDER-BLIND=1
    <                 |vpiSigned:1
```

**One dump line per database.** TO-GOLDEN 2, AWAY-GOLDEN 0, STILL-WRONG 0.

Re-running the SAME census over the PATCHED workdirs:
`SCANNED=2314 PREDICTED_MOVERS=0 NO_GOLDEN=0` — **not one law cell is left in
2314 databases**.

`wide129.sh` over the nine UVM row-modes (4,978 array_var cells against their
own goldens) reports `LAW-FIXED 2, LAW-BROKE 0, COLLATERAL 0` and confirms the
residues it does not touch (6-9 `TSKIND` and 68-75 `TSSPAN` cells per database).

---

## 7. THE HEAD CLEARED

| row-mode | pristine | patched | verdict |
|---|---|---|---|
| **BuildUVMPkg default** | **54** | **60** | **NEW HEAD, a different object and a different family** |
| **BuildUVMPkg testflags** | **54** | **60** | the same new head |
| SeqDriver def/tf | 17 | 17 | head log **BYTE-IDENTICAL** |
| SimpleUVM def/tf | 124 | 124 | head log **BYTE-IDENTICAL** |
| Scoreboard default | 124 | 124 | head log **BYTE-IDENTICAL** |
| MiniAmiq def/tf | 17 | 17 | head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 def/tf | 90 / 150 | 90 / 150 | head logs **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | — |

The line count going **UP** is RESUME §7's rule: the head OBJECT changed, and
60 is the NEW head's decompile size, not a distance. The `enum_var` is gone.

---

## 8. THE BOUNDARY

`bound129.sh` (r10buvm30's gate, reused) compiles **every** `.sv`/`.v` under a
COPY of `tools/probe` with both binaries in both views — file list on fd 3,
children `</dev/null`, `PROCESSED` asserted against `LISTED`, subdirectory arms
included, scratch keyed on the RELATIVE path.

```
LISTED=3857  FENCED_SKIPPED=0  PROCESSED=3857  MOVED=82  NO_OUTPUT_PAIRS=294
PROCESSED-ASSERT-OK          (no ASYMMETRIC_OUTPUT)
```

41 unique arms × 2 views. **Five of them are this pass's own grids** — the
gate's built-in positive control, so a silent run would have been a broken gate.

**Every one of the 1436 moved dump lines is a `|vpiSigned:1` on an array element
variable**: 1427 removals and **9 additions**. The 9 additions are the MIXED
fixed-then-dynamic `int` element (`int mixCount129 [8][]` in grid C,
`automatic int w_qq [$][$]` in `r10uvm80repro/v2_kinds80.sv`), where **GOLDEN
CARRIES `vpiSigned:1`** and ours did not — TO-GOLDEN, not away. Our element
variable there is still a `logic_var` where golden has an `int_var`; that CLASS
is an older residue this law does not touch.

The 36 earlier-pass arms were each re-measured against their OWN Surelog golden
(`arm129.sh` + `score129.py`, both views):

| | |
|---|---|
| LAW-FIXED | **52** |
| LAW-BROKE | **0** |
| LAW-STILL-WRONG | 34 |
| COLLATERAL | **0** |
| object-set drift (`ONLY-OURS` vs `ONLY-PATCHED`) | **0** in every arm, both views |

The 34 STILL-WRONG cells are 17 cells × 2 views, all of ONE shape and all
**BYTE-UNCHANGED** by this pass (`sgn=1` before, `sgn=1` after): a MODULE- or
CLASS-scope associative array of a builtin (`int i_int[i_idx]` in
`r10uvm43repro/t60a/dut.sv`, `gv19` in `r10vbuvm19repro/vg19f.sv`), which golden
leaves unsigned and which no site this pass touches emits. Residue R2 below.

A note on the scorer's one blind spot, stated rather than hidden: where golden
lists NO element variable at all (`ELEMVAR <null>` — a local declared through a
typedef whose target is itself an array, `vt19 ta19;`, `tdarr_t w_tdarr;`), a
`sgn=` comparison is undefined and `score129.py` counts the cell SAME. Those
cells DO move here (the flag is dropped), and the move is judge-NEUTRAL: golden's
`Variables()` vector is empty and ours holds one element, so UHDM's VECTOR
`SafeCompare` overload fails on the SIZE before any element field is read. The
law's answer for them (a NAMED type never stamps) is also golden's, if golden
ever grows the variable.

---

## 9. RESIDUES AND R0

Left standing, all measured, none of them this law's:

1. **A NAMED element type in the FIXED-SIZE tf/begin-block arm binds an
   ANONYMOUS builtin typespec** where golden binds the shared NAMED one
   (uvm126's residue 1, unchanged): grid A has 16 such cells, grid D 16, and
   every UVM database carries **6-9** of them (`TSKIND` in `wide129.sh`). The
   queue / dynamic / associative arms already call `makeTypespec` and get this
   right — it is ONE site, `TaskFuncEmit.cpp`'s hand-rolled `elemTs` ladder.
2. **A MODULE- or CLASS-scope associative array of a builtin carries
   `vpiSigned` on its element** where golden does not (17 arm cells, 0 corpus
   cells): a different emitter site from this pass's four, and untouched.
3. **The MIXED `[N][]` shape gives a `logic_var` element** where golden gives
   the written keyword's variable class (grid C `mixCount129`/`mixMood129`,
   `r10uvm80repro` `w_qq`).
4. **A local declared through a typedef whose target is itself an array lists an
   element variable golden does not have** (`vt19 ta19;`, `tdarr_t w_tdarr;`,
   `qT q;`) — an extra object, a `Variables()` size mismatch to the judge.
5. **The shared named typespec's SPAN is the typedef body in ours and a USE
   site in golden** — DUMP-ONLY (no generated `Compare` reads file/line/column),
   13 of 2314 databases carry it, 66-75 cells each. §1a proves the OBJECT
   itself is already golden's.

**R0 (next head).** BuildUVMPkg ×2 now hands on a **60-line, 1-head**
`sys_func_call ($bits)` at `uvm_object_defines.svh` (BuildUVMPkg pp_output
`82730:10-82731:48`), whose `vpiArgument` is the `hier_path`
`abstractions.size` (a `ref_obj abstractions` + a `method_func_call size`)
inside a `uvm_reg_mem_hdl_paths_seq` field-automation block. That is the SAME
`abstractions.size` object family as the SimpleUVM ×2 / Scoreboard-default
124-line head (an `operation vpiOpType 15` over the same two hier_paths at
`uvm_object_defines.svh:1978`), so **one decode should clear three row-modes at
once** — check for overlap with uvm93 (`$bits` minting), uvm124 (method-call
receiver name/span) and earl84 (hier_path base fold) before dispatching.

---

## 10. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `cen129.cpp` | the census: one CELL per `array_var` — the array_var, its array_typespec, its ELEMENT VARIABLE (class / name / span / vpiSigned / vpiAutomatic / vpiArrayMember), the element typespec both bind, a `shared` flag and a referrer count. Plus the `TSOBJ` family: every NAMED typespec object and how many `ref_typespec`s point at it — the ID-FREE object-identity measurement §1a rests on. |
| `score129.py` | the multiset golden-vs-ours(-vs-patched) join. Scores the LAW FIELD (the element variable's `vpiSigned`) as LAW-WRONG / LAW-FIXED / LAW-BROKE / LAW-STILL-WRONG / LAW-SAME-OK, and every OTHER field as `COLLATERAL`. Also reports the TSKIND / TSSPAN / VARKIND residue families. |
| `pred129.sh` | the a-priori mover predictor / corpus census over a whole workdir |
| `wide129.sh` | the nine UVM row-modes, golden vs pristine vs patched |
| `arm129.sh` | one grid arm: Surelog golden + both binaries + both views + census + the OFFICIAL `uhdm-cmp` |
| `attr129.sh` | mover attribution: path-normalised whole-dump diff, in order AND order-blind |
| `bound129.sh` | the WIDE boundary gate over every arm under `tools/probe` |
| `g129_[abcde]_*.sv` | the five grids (see `ARMS.r10uvm129.txt`) |
| `head_pris_*.cmp` / `head_pat_*.cmp` | the whole head logs, before and after, for all eleven measured row-modes |
| `PREDICT` / `MOVERS` / `CENSUS` / `BOUNDARY` / `GATES` / `ARMS`.r10uvm129.txt | the six evidence files |
| `rowheads.sh` `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the campaign's gates, copied verbatim so this directory can re-run its own claims |
