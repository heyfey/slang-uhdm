# r10buvm2 — `§ classPropTimeLitInit2`: the BuildUVMPkg head **CLEARED on both rows**, the same cell fixed **inside SimpleUVM and Scoreboard where their 593-line head hid it**, and the brief's own reading of the constant **REFUTED — `vpiConstType:9` is `vpiUIntConst`, not `vpiTimeConst`**

**FIRST LINE, as the standing rules demand.** `BuildUVMPkg`, `SimpleUVM` and
`Scoreboard` **DID NOT CONVERT**: all three are `CMP_NOTEQUAL` before and after,
and no conversion was expected. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines — whole ROW, dump column included — **0 differing ROWS** on
both.

**SECOND LINE.** The briefed 17-line head is **GONE from BOTH BuildUVMPkg
row-modes**. `BuildUVMPkg/default` and `BuildUVMPkg/testflags` each sat on the
byte-identical head

```
LHS: constant @38677:23-38677:28, parent time_var (uvm_pkg::uvm_root::phase_timeout)
     @38677:7-38677:20, vpiSize:64, UINT:9200000000000000, vpiConstType:9
RHS: <null>
```

and that cell is now **identical on both sides, field for field, at the same
span** — proven not by the head count but by a span-keyed census of the whole
design's class-property `vpiExpr` population (§1.2), which reads **0 MISSING, 0
EXTRA, 0 MISMATCHED** where it read 3 MISSING before.

**THIRD LINE, and it is the finding worth more than the patch.** The brief
wrote the golden cell as `vpiConstType:9 (TIME)`. **9 is `vpiUIntConst`.**
`vpiTimeConst` is **8** (`uhdm/vpi_user.h:492-493`), and Surelog's time-literal
arm never uses it:

```cpp
// Surelog src/DesignCompile/CompileExpression.cpp, case VObjectType::paTime_literal
UHDM::constant *c = s.MakeConstant();
c->VpiValue("UINT:" + std::to_string(val));
c->VpiConstType(vpiUIntConst);          // <- NINE.  Not vpiTimeConst.
c->VpiSize(64);
```

Chasing `vpiTimeConst` would have produced an object golden never builds.

**FOURTH LINE.** The brief also said *"The TIME value encoding needs its own
decode (timeunit scaling to the UINT)."* **There is no timeunit scaling.** The
value is a FIXED per-unit factor table that never consults the timescale, is
**not monotone** (`us` × 1e3 sits *below* `ns` × 1e6), and truncates `fs` to
zero — and it had **already been decoded and transcribed** in this repo as
`§ srlgTimeLitVal` (`src/EmitHelpers.h:2583`) for the *parameter* carrier. This
pass did not decode it; it re-proved it on seven golden cells (§3.1) and then
found the **second half nobody had**: the SIZE and the `vpiDecompile` are not
the literal's at all, they are whatever `CompileHelper::adjustSize` leaves
behind after `makeVar_` runs it over the property's **typespec** (§3.2).

Base **dbb1b5a**. Worktree `/tmp/wt_r10buvm2`; pristine control worktree
`/tmp/wt_r10buvm2pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `dbb1b5a9b369b627faf0bb37cebcef55de246d1e`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine dbb1b5a) | `08d4d8f964eb99ecdae33ceed5a855c5` | my own build of the base commit |
| **SHIPPED (patched)** | **`35f7946d01b517ea642d5d63806369ae`** | every number below was measured on THIS binary |

BUILD DIRS (absolute): `/tmp/wt_r10buvm2/build`, `/tmp/wt_r10buvm2pris/build`,
both `-j 2`. `[100%] Linking CXX executable slang-uhdm` → `[100%] Built target
slang_uhdm` was read out of each build log before any md5 was taken; every md5
was asserted against `^[0-9a-f]{32}$` in its own command. **The control is
anchored twice**: the MAIN TREE's `build/slang-uhdm` at `HEAD == dbb1b5a` is
*also* `08d4d8f964eb99ecdae33ceed5a855c5`, i.e. my pristine build reproduces the
committed binary byte for byte. `git stash` was never used. `results/*.csv` were
only ever READ. slang was not patched. `GOLDEN_DEFER` was left **UNSET** (echoed
as `[UNSET]` at every sweep launch). The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched — `canaudit.sh` proves it mechanically (FENCE-BREACH=0).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

---

## 0. THE LAWS

Three arms, three greppable sections, one family: **class-property DECLARATION
INITIALIZER shapes that `emitClassDefn`'s inline whitelist and
`emitClassPropInit29` used to drop on the floor.** The census (§1.2, re-run after the patch in §1.4) proves these
three are the *complete* remaining population in all three UVM designs — 0
missing and 0 extra afterwards.

### § classPropTimeLitInit2

*A class-property declaration initializer that is a **TIME LITERAL** rides the
variable as a `constant` with `vpiConstType` = **`vpiUIntConst` (9)** — never
`vpiTimeConst` (8) — parented at the **VARIABLE**, spanned at the literal, and
valued by `§ srlgTimeLitVal`'s **fixed, timescale-independent, non-monotone**
factor table (`s` 1e12, `ms` 1e9, `ns` 1e6, `us` 1e3, `ps` 1, `fs` 1e-3
truncating). Its **SIZE and its `vpiDecompile` are decided by a SECOND, LATER
step**: `makeVar_`'s tail runs `CompileHelper::adjustSize(tps, …)` over every
constant initializer, and `adjustSize` is a **NO-OP exactly when `Bits()`
cannot size the property's typespec**. A `time_typespec` is such a typespec, so
a `time` / `realtime` property keeps the raw literal object — **`vpiSize` 64
and NO `vpiDecompile` at all**. Every other integral property type gets the
value **MASKED to that type's width**, `vpiSize` set to that width, and a
decimal `vpiDecompile` stamped on.*

```
UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv
38677   	time phase_timeout = 9200s;              <- the head, BuildUVMPkg
UVM/uvm-1.2/src/base/uvm_root.svh
218       time phase_timeout = `UVM_DEFAULT_TIMEOUT;  <- the SAME cell, SimpleUVM
UVM/uvm-1.2/src/macros/uvm_global_defines.svh
57      `define UVM_DEFAULT_TIMEOUT 9200s              +  Scoreboard
```

`9200 × 1e12 = 9200000000000000`. The brief's guess that the value encodes a
`fs` scaling is wrong twice over: the factor is 1e12, not 1e15, and it comes
from a hard-coded table rather than from any timescale.

### § classPropNullInitParentedByTypespec2

*A `= null` class-property initializer rides the variable as the vpiNullConst
(`vpiConstType` 11, `vpiSize` 64, `vpiDecompile` `0`, `UINT:0`) on **every**
property type that can hold it — and its **`vpiParent` is the CLASS_DEFN for
some of them and the VARIABLE for others**. The discriminator is whether the
property has a **TYPESPEC**: `bindProperties_` builds the initializer with
`exp->VpiParent(defn)` and hands it to `makeVar_`, whose typespec-driven arms
all re-parent it to the variable and whose trailing `subnettype` **fallback
chain** — reached only when the property has no typespec at all — ends in a
bare `var->Expr(assignExp)` that never does.*

**THIS WIDENS `§ virtualIfaceNullInitIsClassParented6` AND REFUTES ITS STATED
GATE.** That law's comment ends:

> "Every arm the fallback does NOT reach re-parents to the var, so **the gate is
> the virtual-interface property, not `null`**."

Arm a2 cell `m02_null` is the counterexample and it took one line of SystemVerilog
to find: `chandle m02_null = null;` is **CLASS_DEFN-parented too**, because
`paChandle_type` is one of the fallback chain's own branches and golden's
`chandle_var` carries no typespec whatsoever. The virtual interface was never
the gate. Having no typespec is.

### § classPropSysCallInit2

*A **SYSTEM function call** initializer stays a `sys_func_call` named `$<f>`,
parented at the property, spanning the WHOLE call, carrying its written
arguments — exactly what `emitExpr` already builds. The previous code excluded
system calls by name (`|| ic.as<CallExpression>().isSystemCall()` in the same
`return` as "not a call at all"); this arm only stops throwing the result away.
A call `emitExpr` **FOLDS** (`$bits`) is deliberately left OFF: golden's folded
constant is sized by `adjustSize` at the property's width, a rule this pass did
not decode, and a guessed width is worse than a missing object.*

### STATED GATE == CODE GATE — read off the source, not off this file

Two predicates in `src/EmitHelpers.h`, three call sites in
`src/UhdmExporter.cpp`, nothing else:

```bash
grep -n "classPropTimeLitInit2\|classPropNullInitParentedByTypespec2\|classPropSysCallInit2" \
     src/EmitHelpers.h src/UhdmExporter.cpp
grep -c "timeLikeType2(\|nullInitDefnParented2(" src/EmitHelpers.h src/UhdmExporter.cpp
#   src/EmitHelpers.h   : 2  (the two definitions)
#   src/UhdmExporter.cpp: 2  (the two uses)
```

The TIME gate is **exactly** this, and nothing else:

```cpp
else if (ic0.kind == ExpressionKind::TimeLiteral) {
    uint64_t tv2 = srlgTimeLitVal(rawText(ic0.sourceRange));
    const Type& pt2 = cp.getType().getCanonicalType();
    if (timeLikeType2(pt2))            { /* size 64, NO decompile, raw value */ }
    else if (pt2.isIntegral() && pt2.getBitWidth())
                                       { /* mask to width, size = width, decompile */ }
    /* real / shortreal: nothing — residue R2 */
}
```

```cpp
inline bool timeLikeType2(const slang::ast::Type& ct) {
    if (ct.kind == SymbolKind::PredefinedIntegerType)
        return ct.as<PredefinedIntegerType>().integerKind == PredefinedIntegerType::Time;
    if (ct.kind == SymbolKind::FloatingType)
        return ct.as<FloatingType>().floatKind == FloatingType::RealTime;
    return false;
}
```

TWO slang kinds, because `time` and `realtime` are **not** the same slang kind
and Surelog's `compileTypespec` maps `paNonIntType_RealTime` onto a
`time_typespec` exactly as it maps `paIntegerAtomType_Time`. Cell k09 is the
witness.

The NULL gate:

```cpp
inline bool nullInitDefnParented2(bool vifProp, const ClassPropertySymbol& cp) {
    return vifProp ||
           cp.getType().getCanonicalType().kind == SymbolKind::CHandleType;
}
```

The SYSCALL gate is the expression kind plus one **result-kind** test
(`uhdmsys_func_call`), which is what refuses the folded `$bits`.

---

## 1. WHAT WAS MEASURED BEFORE A LINE OF CODE WAS WRITTEN

Order, exactly as the brief demanded: **census both sides first, grid second,
patch third.**

### 1.1 The census instrument

`propcen.py` keys every class property by **(object kind, vpiFullName, span)**
and keeps the occurrence listed under `class_defn |vpiVariables:` — the only
place the property's own field set prints in full. The campaign law *"an object
is not a dump occurrence"* binds here: uhdm-dump prints the same property once
per reference chain that reaches it, so a raw grep over-counts. It reads the
`vpiExpr` child at **exactly one indent level deeper than the property header**,
so an expression belonging to a nested object can never be attributed to the
property.

### 1.2 The result — and it answered the brief's own open question

The brief asked: *"do SimpleUVM/Scoreboard goldens carry this cell too, i.e. is
this ANOTHER shared-fix family masked by their 593-line head? measure."*

**YES. Measured, both sides, span-keyed, before any patch:**

| design | distinct class properties | golden with `vpiExpr` | ours | **MISSING (golden has, we do not)** | **EXTRA** |
|---|---|---|---|---|---|
| BuildUVMPkg | 887 | 112 | 109 | **3** | **0** |
| SimpleUVM | 1061 | 241 | 223 | **1** | **0** |
| Scoreboard | 1070 | 246 | 228 | **1** | **0** |

and the MISSING cells, by name:

| design | property | golden's vpiExpr |
|---|---|---|
| BuildUVMPkg | `uvm_pkg::uvm_root::phase_timeout` @38677:7-20 | `constant`@38677:23-28 ctype 9 size 64 **no decompile** |
| BuildUVMPkg | `uvm_pkg::uvm_component::m_unsupported_resource_base` @38385:21-48 | `constant`@38385:51-55 ctype 11 size 64 decompile `0` |
| BuildUVMPkg | `uvm_pkg::uvm_default_coreservice_t::m_uvm_global_seed` @9423:21-38 | `sys_func_call ($urandom)`@9423:41-49 |
| SimpleUVM | `uvm_pkg::uvm_root::phase_timeout` @218:8-21 | `constant`@218:24-29 ctype 9 size 64 **no decompile** |
| Scoreboard | `uvm_pkg::uvm_root::phase_timeout` @218:8-21 | `constant`@218:24-29 ctype 9 size 64 **no decompile** |

**The time-literal cell IS a shared-fix family across all three UVM designs**,
and in SimpleUVM and Scoreboard it is the ONLY missing class-property `vpiExpr`
in the entire design. The 593-line `uvm_objection::new` head (r10uvm71's
territory) was hiding a cell that the census sees straight through.

**The census also fixed the SCOPE of the patch.** It found the other two
BuildUVMPkg cells — a `null` and a `$urandom` — which no brief mentioned, and it
proved the population **closed**: after the patch the same census reads 0/0/0 on
BuildUVMPkg (§1.4). Three arms, not one, because the census said three.

### 1.3 What is NOT in this family (measured, both sides, same census)

The censuses also print rows where BOTH sides have `EXPR=NONE` or BOTH have an
expression and the two disagree on something else. Those are **other families**
and this pass does not touch them; they are listed so the next reader does not
mistake them for residue of this one:

* `logic_var` vs `enum_var` (`uvm_mem_mam_cfg::mode`, `::locality`,
  `uvm_sequence_request::request`) and `struct_var` vs `bit_var`
  (`uvm_reg_map_info::mem_range`) — object-KIND family, BuildUVMPkg.
* `uvm_*::type_name` string constants whose golden end-span is `428:52` and
  ours `429:8` — a macro END-SPAN family, ~40 cells in SimpleUVM/Scoreboard.
* `work@env::` vs `uvm_pkg::` fullname prefixes — the naming family the memory
  note "naming is context-dependent" already fences off.

### 1.4 The SAME census, re-run on the PATCHED binary

`propcen.py`, same key, same designs, patched vs golden:

| design | MISSING | EXTRA | MISMATCHED SHAPE |
|---|---|---|---|
| BuildUVMPkg | **0** (was 3) | **0** | **0** |
| SimpleUVM | **0** (was 1) | **0** | **0** |
| Scoreboard | **0** (was 1) | **0** | **0** |

`MISMATCHED SHAPE` compares the whole reading — child kind, child span,
`vpiConstType`, `vpiSize` and whether a `vpiDecompile` is present — for every
property where BOTH sides have an expression. Zero. The family is closed on all
three designs, and `SeqDriver` (found later, by the mover predictor rather than
by this census) carries the same cell and the same fix (GATE 5).

---

## 2. THE GRID — cell for cell, golden beside ours

Four arms, all UVM-free, all run through `ct2arm.sh` (Surelog `-parse -nocache`
as LHS, the binary under test as RHS, each arm in its own scratch directory
because Surelog synthesizes `builtin.sv` into the CWD).

### 2.1 a1_timegrid.sv — the TIME axis, 24 cells

| cell | written | golden | pristine ours | **patched ours** |
|---|---|---|---|---|
| k01 | `time = 9200s` | ct9 size64 **UINT:9200000000000000** no-dec | **NONE** | **=golden** |
| k02 | `time = 7ms` | ct9 size64 UINT:7000000000 no-dec | NONE | **=golden** |
| k03 | `time = 7us` | ct9 size64 **UINT:7000** no-dec | NONE | **=golden** |
| k04 | `time = 7ns` | ct9 size64 **UINT:7000000** no-dec | NONE | **=golden** |
| k05 | `time = 7ps` | ct9 size64 UINT:7 no-dec | NONE | **=golden** |
| k06 | `time = 7fs` | ct9 size64 **UINT:0** no-dec | NONE | **=golden** |
| k07 | `time = 1.5ns` | ct9 size64 **UINT:1000000** no-dec | NONE | **=golden** |
| k08 | `int = 5ns` | ct9 **size32** UINT:5000000 **dec** | NONE | **=golden** |
| k09 | `realtime = 5ns` | ct9 size64 UINT:5000000 no-dec | NONE | **=golden** (expr); var KIND still differs, §5 R5 |
| k10 | `integer = 5ns` | ct9 size32 UINT:5000000 dec | NONE | **=golden** |
| k11 | `static time = 3ns` | ct9 size64 UINT:3000000 no-dec | NONE | **=golden** |
| k12 | `const time = 4ns` | ct9 size64 UINT:4000000 no-dec | NONE | **=golden** |
| k13 | `local time = 6ns` | ct9 size64 UINT:6000000 no-dec | NONE | **=golden** |
| k14 | `time = 5` | ct9 size64 UINT:5 dec `5` | **already =golden** | =golden |
| k15 | `time;` (no init) | **NONE** | NONE | **NONE** (control holds) |
| k16 | `time = 5ns + 3ns` | `operation`@22-31 | NONE | NONE — **residue R3** |
| k17 | `longint = 5ns` | ct9 **size64** UINT:5000000 **dec** | NONE | **=golden** |
| k18 | `shortint = 5ns` | ct9 size16 **UINT:19264** dec | NONE | **=golden** |
| k19 | `byte = 5ns` | ct9 size8 **UINT:64** dec | NONE | **=golden** |
| k20 | `bit [7:0] = 5ns` | ct9 size8 UINT:64 dec | NONE | **=golden** |
| k21 | `real = 5ns` | ct9 **size32** UINT:5000000 dec | NONE | NONE — **residue R2** |
| k22 | `logic [63:0] = 5ns` | ct9 size64 UINT:5000000 dec | NONE | **=golden** |
| k23 | `int = 9200s` | ct9 size32 **UINT:3958308864** dec | NONE | **=golden** |
| k24 | `logic [127:0] = 5ns` | ct9 **size128** UINT:5000000 dec | NONE | **=golden** |

Read the grid, not the summary:

* **k03 vs k04 is the anomaly, and it is golden's, not a typo of mine.**
  `7us → 7000` and `7ns → 7000000`. The factor table Surelog wrote has
  `Microsecond` at 1e3 and `Nanosecond` at 1e6, i.e. **`us` and `ns` are
  swapped** relative to any coherent picosecond base. Both sides now agree
  because we transcribe the table rather than convert units.
* **k17 is the cell that decides the SIZE law.** `longint` is 64 bits wide, so
  "size 64 and no decompile because the width is already 64" would predict
  no-decompile — and golden **decompiles it**. The gate is therefore the
  **typespec kind** (a `time_typespec`, which `Bits()` cannot size) and not the
  width. Without k17 the law would have been fitted to the corpus and wrong.
* **k18/k19/k23 prove `adjustSize` MASKS**: `5000000 & 0xFFFF = 19264`,
  `5000000 & 0xFF = 64`, `9200000000000000 & 0xFFFFFFFF = 3958308864`.
* **k06 proves the `fs` truncation is real**: `7 × 1e-3 = 0.007` assigned into a
  `uint64_t` is `0`, and golden stores `UINT:0`.
* **k21 (`real`) is refused on purpose**: golden sizes it **32**, which is not
  slang's width for a real (64) and not a rule this pass decoded. Emitting a
  guessed 64 would have replaced a missing object with a wrong one.

### 2.2 a2_kindgrid.sv — the NULL and SYSTEM-CALL axes, 11 cells

| cell | written | golden | pristine ours | **patched ours** |
|---|---|---|---|---|
| m01 | `base2 = null` | ct11 size64 dec`0` parent = **the VAR** | NONE | **=golden** |
| m02 | `chandle = null` | ct11 size64 dec`0` parent = **the CLASS_DEFN** | NONE | **=golden** |
| m03 | `string = "x"` | ct6 size8 | already =golden | =golden |
| m04 | `int = $urandom` | `sys_func_call ($urandom)`@23-31 | NONE | **=golden** |
| m05 | `int = $urandom_range(1,10)` | `sys_func_call`@23-**44** + 2 argument constants | NONE | **=golden** |
| m06 | `int = $random` | `sys_func_call ($random)` | NONE | **=golden** |
| m07 | `time = $time` | `sys_func_call ($time)` | NONE | **=golden** |
| m08 | `int = $bits(int)` | **constant** ct9 **size32** dec `32` | NONE | NONE — **residue R4** |
| m09 | `real = $sqrt(4.0)` | `sys_func_call ($sqrt)` + REAL argument | NONE | **=golden** |
| m10 | `int = uf2()` | `func_call` | already =golden | =golden |
| m11 | `virtual vif2 = null` | ct11 parent = **the CLASS_DEFN** | already =golden | =golden |

**m01 beside m02 is the whole refutation of `§ 6`'s stated gate**, and m11 is
the control that keeps the old behaviour: three `= null` properties, two
parents, and the split is the typespec, not the interface.

**m05 and m09 are the reason the sys-call arm routes through `emitExpr` instead
of building a bare `sys_func_call`**: arguments, the whole-call span, and the
REAL argument's `vpiDecompile:4.0` all come out right for free.

### 2.3 a4_macro.sv — the MACRO-EXPANDED literal: **DUMP_MATCH, cmp EQUAL**

This is the arm that reproduces what SimpleUVM and Scoreboard actually write.

| cell | written | golden | patched ours |
|---|---|---|---|
| q01 | `time = \`TMO2` (`\`define TMO2 9200s`) | `constant`@**18:24-18:29** UINT:9200000000000000 | **=golden** |
| q02 | `time = \`TMO2NS` (`7ns`) | `constant`@**19:24-19:27** UINT:7000000 | **=golden** |
| q03 | `time = 7ns` (in-place control) | `constant`@20:24-20:27 | **=golden** |
| q04 | `time = 9200s` (in-place control) | `constant`@21:24-21:29 | **=golden** |

Golden's span rule for a macro-expanded literal is **the macro USE's start
column plus the EXPANDED text's length** — `\`TMO2` is 5 columns wide on the
page and `9200s` is 5 characters, so 24-29; `\`TMO2NS` is 7 columns wide and
`7ns` is 3 characters, so 24-**27**, not 24-31. `uvm_root.svh:218` is the same
shape (`\`UVM_DEFAULT_TIMEOUT` is 20 columns, golden spans 218:24-218:29). Our
`setLoc`/`rawText` already produce exactly this; the whole arm is **DUMP_MATCH
and `uhdm-cmp` EQUAL (0 heads, 0 lines)**, so the macro half needed no code at
all. It is measured rather than assumed because assuming it is how a
macro-buffer span bug gets shipped.

Also recorded as an ops fact, not a finding of ours: `\`NUM2 s` (numeric prefix
from a macro, unit written separately) **segfaults Surelog**; the cell was
removed from a4 and replaced with an in-place control.

### 2.4 a3_overfire.sv — the OVER-FIRE control: **0 changed dump lines**

Every non-class-property carrier of the same three initializer kinds:
package/module `parameter time = 5ns`, `localparam time = 7us`, MODULE-scope
`time n03_mv = 5ns`, `int n04_mi = 5ns`, a packed-struct assignment pattern,
FUNCTION-LOCAL `time n07_lv = 5ns` and `int n08_lr = $urandom`, a `#5ns` delay
in statement position, and an assignment `n03_mv = 7ps`.

```
patched o.dump vs pristine o.dump, workdir path normalised: 0 differing lines
```

Zero. The patch touches `emitClassDefn`'s property whitelist and
`emitClassPropInit29`, and nothing else in the emitter can see it.

---

## 3. THE DECODE

### 3.1 The value: `§ srlgTimeLitVal`, re-proved on golden

Surelog, `src/DesignCompile/CompileExpression.cpp`, `case
VObjectType::paTime_literal`: parse the numeric prefix with
`NumUtils::parseUint64` (an *integer* parse — `1.5ns` yields `1`), then multiply
by a hard-coded `double` factor and assign back into a `uint64_t`.

| unit | factor | a1 cell | golden |
|---|---|---|---|
| `s` | 1e12 | k01 `9200s` | 9200000000000000 |
| `ms` | 1e9 | k02 `7ms` | 7000000000 |
| `ns` | **1e6** | k04 `7ns` | 7000000 |
| `us` | **1e3** | k03 `7us` | 7000 |
| `ps` | 1 | k05 `7ps` | 7 |
| `fs` | 1e-3 | k06 `7fs` | **0** |
| (unknown) | 1 (`TimeInfo::unitFromString` falls through to Picosecond) | — | — |

a1 carries **no `timescale` at all** and a4 carries **`\`timescale 1ns/1ns`**,
and `9200s` reads `9200000000000000` in both. The table is timescale-blind.

### 3.2 The size and the decompile: `adjustSize`, the half nobody had

`ElaborationStep::makeVar_` ends with

```cpp
if (assignExp && assignExp->UhdmType() == uhdmconstant)
    m_helper.adjustSize(tps, component, m_compileDesign, instance, (constant*)assignExp);
```

and `adjustSize` (a) early-returns when `ts == nullptr`, (b) computes
`size = Bits(ts, invalidValue, …)`, and (c) **does nothing at all when
`invalidValue`**; otherwise, for a `vpiUIntConst`, it masks the value to
`size`, rewrites `VpiValue`, **sets `VpiDecompile`**, and sets `VpiSize`.

So the size/decompile split is one question: *can `Bits()` size the property's
typespec?* The grid answers it without reading another line of Surelog:
`time_typespec` and only `time_typespec` comes out untouched (k01-k07, k09,
k11-k13), and `longint` (k17) — same width, different typespec — is adjusted.

### 3.3 The parent: `bindProperties_` then `makeVar_`

```cpp
UHDM::expr* exp = exprFromAssign_(…);
if (exp != nullptr) exp->VpiParent(defn);            // CLASS_DEFN first
UHDM::any* obj = makeVar_(…, exp, tps);
```

`makeVar_`'s typespec-driven arms each do `assignExp->VpiParent(var)`; its
trailing `subnettype` fallback chain ends in a bare `var->Expr(assignExp);` and
**never re-parents**. `paChandle_type` and the default (`logic_var`, which is
what a `virtual <iface>` property becomes) are branches of that chain. Hence
§ classPropNullInitParentedByTypespec2, and hence the refutation in §0.

---

## 4. THE FIVE GATES

### GATE 1 — BUILD

| | |
|---|---|
| patched | `/tmp/wt_r10buvm2/build/slang-uhdm` md5 **`35f7946d01b517ea642d5d63806369ae`** (32-hex asserted) |
| pristine control | `/tmp/wt_r10buvm2pris/build/slang-uhdm` md5 **`08d4d8f964eb99ecdae33ceed5a855c5`** (32-hex asserted) |
| anchor | main tree `build/slang-uhdm` at `HEAD == dbb1b5a` is the SAME md5 as my pristine build |
| link line | `[100%] Linking CXX executable slang-uhdm` present in BOTH build logs, read BEFORE any md5 |
| jobs | `-j 2` on both |

DETERMINISM (`detcheck.sh`, patched binary): 3/3 identical sha256 on
`a1_timegrid.sv` (`8fe0d806841d0822`) and 3/3 identical on the **whole
BuildUVMPkg source** (`5f1a85ff72596d59`, 11097459 bytes) — `distinct hashes=1,
NO_OUTPUT runs=0` both times. Neither new arm touches a pointer-keyed container.

### GATE 2 — GOLDENS

| run | PASS | FAIL |
|---|---|---|
| `SLANG_UHDM=<patched>` | **23** | **0** |
| `SLANG_UHDM=/bin/false` | **0** | **23** |

The negative control is what makes the positive one mean anything.

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`

```
679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump column: 496 match   183 differ   52 (blank)
ct8rows.sh vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
```

Whole-ROW comparison, dump column included. 731 rows both sides.

### GATE 4 — Surelog corpus, BOTH modes, `--jobs 2`

```
default   : 469 CMP_EQUAL   11 CMP_NOTEQUAL   284 SLANG_REJECT   25 SURELOG_FAIL    5 DEFERRED
testflags : 465 CMP_EQUAL    8 CMP_NOTEQUAL   286 SLANG_REJECT   23 SURELOG_FAIL    5 DEFERRED
            3 NO_DATABASE    2 UNTRANSLATABLE   1 TIMEOUT    1 NO_UHDM
ct8rows.sh vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
```

1588 rows both sides. Both the STATUS histogram and the DUMP-column histogram
are **identical to the committed baseline in both modes** (`default` 225 match /
244 differ / 325 blank; `testflags` 165 / 300 / 329). `GOLDEN_DEFER` was UNSET,
so the five memory giants read `DEFERRED` 5/5 exactly as the baseline does. The
PRISTINE sweep was run through the same gate and is also 0 differing ROWS,
which is what makes the byte verifier's two workdirs comparable.

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs the PRISTINE build

The rule was **fixed and written into `predict2.py` before gate 5 ran**, and it
is computed from the **PRISTINE side alone**, so it cannot be fitted to the
answer. It is deliberately TWO-SIDED: `CERTAIN` (a source line writing a time
literal / `null` / `$sysfunc` beside a class property that has no `vpiExpr`) and
`MAYBE` (a MACRO-valued initializer, which the predictor cannot resolve without
preprocessing — and which is exactly how uvm-1.2 writes the cell).

| corpus | scanned | predicted CERTAIN | predicted MAYBE | **MOVERS measured** |
|---|---|---|---|---|
| uhdm2rtlil, testflags | 679 | **0** | **0** | **0 / 679** |
| Surelog, both modes | 953 | **2** | **5** | **7 / 953** |

**The 7 measured movers are EXACTLY the 2 CERTAIN plus the 5 MAYBE, by name:**

| database | predicted as | ADDED dump lines | REMOVED |
|---|---|---|---|
| `default/BuildUVMPkg` | CERTAIN (time=1 null=1 sys=1) | **+20** | **0** |
| `testflags/BuildUVMPkg` | CERTAIN (time=1 null=1 sys=1) | **+20** | **0** |
| `default/SimpleUVM` | MAYBE (macro=1) | **+7** | **0** |
| `testflags/SimpleUVM` | MAYBE (macro=1) | **+7** | **0** |
| `default/Scoreboard` | MAYBE (macro=1) | **+7** | **0** |
| `default/SeqDriver` | MAYBE (macro=1) | **+7** | **0** |
| `testflags/SeqDriver` | MAYBE (macro=1) | **+7** | **0** |

`SCAN-FAIL: 0` on both corpora — every database was actually read.

NEGATIVE CONTROLS, both mandatory, both run: `SELFCHECK=1` (every file vs one
fixed file) flagged **678/679** and **952/953**; `SELFCHECK1=1` (one file's
bytes corrupted in a copy of the pristine tree) reported **1** on uhdm2rtlil and
**8** on Surelog — that is `1 corrupted + the 7 real movers`, exactly as the
instrument's own comment says it must. `PATH_SETS_IDENTICAL` on both.

**MOVERS PER SHAPE, vs GOLDEN, BY MULTISET.** The MOVER RULE says a nonzero
size delta proves a real move and a zero delta proves nothing, and that the
authority is per-shape content. Here every mover has a nonzero delta AND its
content is named:

| row | golden-only line instances | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| BuildUVMPkg | 53472 → **53452** | 26453 → **26453** | 79925 → **79905** |
| SimpleUVM | 92920 → **92913** | 50426 → **50426** | 143346 → **143339** |
| Scoreboard | 83533 → **83526** | 50169 → **50169** | 133702 → **133695** |

**Every added line closed a GOLDEN-ONLY gap and not one new OURS-ONLY line
appeared.** That is the cleanest mover signature this instrument can produce:
`ADDED` and `REMOVED` measured separately, `REMOVED = 0` on every one of the 7
databases, and the added text is byte-for-byte what golden prints:

```
        |vpiExpr:
        \_constant: , line:38677:23, endln:38677:28
          |vpiParent:
          \_time_var: (uvm_pkg::uvm_root::phase_timeout), line:38677:7, endln:38677:20
          |vpiSize:64
          |UINT:9200000000000000
          |vpiConstType:9
```

(plus, on BuildUVMPkg only, the 8-line `vpiNullConst` on
`m_unsupported_resource_base` and the 5-line `sys_func_call ($urandom)` on
`m_uvm_global_seed`; 7 + 8 + 5 = the 20.)

**HEADS.**

| row-mode | pristine head | patched head |
|---|---|---|
| BuildUVMPkg/default | `constant` @38677:23-28 vs `<null>` — **17 lines** | `LHS:<null>` / `RHS: package uvm_pkg` — 1366987 lines |
| BuildUVMPkg/testflags | same 17-line head, byte-identical | same, 1366987 lines |
| SimpleUVM/default+testflags | `LHS:<null>` / `function uvm_objection::new` — 593 | **unchanged, 593** |
| Scoreboard/default | same — 593 | **unchanged, 593** |
| SeqDriver/default+testflags | `LHS:<null>` / `package uvm_pkg` — 1414881 | same shape, 1414895 |

**READ THIS BEFORE READING `17 → 1366987` AS A REGRESSION.** The campaign's own
law says the cmp line count is **HEAD DEPTH ONLY, never a distance**, and this
pass is the extreme case of it. `uhdm-cmp` prints
`UHDM::decompile(context.m_failedRhs)`, so when the first failing pair is a
whole `package` the tool prints the whole package. Three independent
instruments say the database moved strictly CLOSER: the multiset distance fell
on every row with **zero** new ours-only lines; the span-keyed class-property
census went from 3 MISSING to **0 MISSING / 0 EXTRA / 0 MISMATCHED**; and the
briefed cell is now identical field-for-field.

**And the new head is not new.** `SeqDriver` — a UVM design this pass did not
touch structurally — has carried the **same** `LHS:<null>` / `RHS: package
uvm_pkg` head at 1414881 lines all along, in both modes, on the pristine binary.
BuildUVMPkg's constant was simply masking the shape its sibling already had.
That is residue R1.

### CANARIES

Run against BOTH fresh CSVs, and the whole ROW is compared (status AND dump
column), never the status alone.

| script | csv | result |
|---|---|---|
| `canaries.sh` | uhdm2rtlil | `ok=8 changed=0 absent=0` (25 unknown = the surelog-only names) |
| `canaries.sh` | surelog | `ok=52 changed=0 absent=0` (**7** unknown = the u2r-only names, the documented number) |
| `ctcan2.sh` `EXPECT_UNKNOWN=6` | uhdm2rtlil | `ok=1 changed=0 absent=0 unknown=6` → **PASS** |
| `ctcan2.sh` `EXPECT_UNKNOWN=1` | surelog | `ok=58 changed=0 absent=0 unknown=1` → **PASS** |
| `canaudit.sh` | — | `audited=29 UNCOVERED=0 FENCE-BREACH=0` → **PASS** |

`EXPECT_UNKNOWN` was **mode-matched and baseline-first** in both directions, as
the standing rule requires. `canaudit.sh` is the guard on the guards: it proves
every brief-protected name and family is carried by a script that actually RUNS
here, and that **no driver in this directory mentions any of the four
slang-fenced tests** (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`).

BY NAME, as the standing rule demands:

```
InterfaceModPort   ,default  ,CMP_EQUAL,,,differ      identical to baseline
InterfaceModPort   ,testflags,CMP_EQUAL,,,differ      identical to baseline
BlackParrotComplex ,default  ,CMP_EQUAL,,,differ      identical to baseline
BlackParrotComplex ,testflags,CMP_EQUAL,,,differ      identical to baseline
```

and the four UVM rows this pass moved bytes in are all **status-unchanged**:
`BuildUVMPkg` CMP_NOTEQUAL/CMP_NOTEQUAL, `SimpleUVM` CMP_NOTEQUAL/CMP_NOTEQUAL,
`Scoreboard` CMP_NOTEQUAL/SLANG_REJECT, `SeqDriver` CMP_NOTEQUAL/CMP_NOTEQUAL —
byte-identical rows to the committed baseline.

---

## 5. RANKED RESIDUES

Ranked by *tests reached per unit of remaining unknown*, with what is already
decoded stated so the next pass starts where this one stopped.

**R1 — the head BuildUVMPkg now shares with SeqDriver: a `(null, package)`
first-failure.** `uhdm-cmp`'s `m_failedLhs` is NULL and `m_failedRhs` is the
`uvm_pkg` package, i.e. **some object of ours carries a `package`-typed edge
(`vpiInstance`) that golden's counterpart leaves null**. Reach: BuildUVMPkg ×2
and SeqDriver ×2 today, and it is the wall behind every remaining UVM cell in
those designs. Already measured here: a span-keyed audit of every object
carrying `|vpiInstance:` on BuildUVMPkg finds **3279 on our side vs 3267 on
golden's**, with **106 objects ours-only** and **94 golden-only** — but some of
those pairs are the same object separated by a SPAN difference from another
family, so the next pass must key the audit on the object identity that survives
a span change before it theorises. `\_class_typespec` and `\_bit_typespec`
dominate the ours-only list.

**R2 — a `real` / `shortreal` property with a time-literal initializer.**
Golden: `ct9 size 32 UINT:5000000 decompile 5000000` (a1 k21). **32** is neither
slang's width for a real (64) nor the literal's; it is whatever
`ExprEval::size(real_typespec)` returns, and this pass did not decode it. The
arm deliberately emits NOTHING rather than a guessed 64. Reach: **0 corpus
tests** — no UVM property is a real with a time initializer — which is why it
was left. Cost to close: read UHDM `ExprEval::size` for `real_typespec` and add
one branch.

**R3 — a FOLD-NEEDING expression initializer** (`time = 5ns + 3ns`, a1 k16).
Golden builds the `operation` over two of these constants. `emitClassPropInit29`
already accepts operations for concatenations and assignment patterns; the
missing piece is whether the OPERANDS get `adjustSize`'d (Surelog's `makeVar_`
tail runs `adjustSize` over an operation's operands too, with `sizeMode=true` —
a *different* call than the constant one, and that difference is unmeasured).
Reach: 0 corpus tests today.

**R4 — a FOLDED `$bits` property initializer** (a2 m08). Golden's constant is
`size 32` — the PROPERTY's width, not the 64 `emitExpr` hands back. One
`adjustSize` question, the same one as R2/R3. Reach: BuildUVMPkg has none today
(its `$bits` uses are all in method bodies, which `§ bitsOwnClassPropFold61`
already owns).

**R5 — `realtime` is a `time_var` in golden and a `real_var` in ours** (a1 k09,
now the head of arm a1). `EmitHelpers.h`'s `makeVarForType` maps
`PredefinedIntegerType::Time` to `MakeTime_var` but sends `FloatingType::RealTime`
down the generic floating path; Surelog's `makeVar_` maps
`paNonIntType_RealTime` to `MakeTime_var` as well. This pass proved the
TYPESPEC half of the same fact (`timeLikeType2` covers both kinds) but
deliberately did not touch the variable factory, which is a different family
with its own canary surface. One line plus a grid.

**R6 — `chandle` properties carry a `chandle_typespec` in ours and NO typespec
in golden** (a2, now that arm's head: `LHS:<null>` vs
`RHS: ref_typespec (p2::c2::m02_null)`). This is *the same fact* R1's law rests
on — golden's chandle lands in `makeVar_`'s typespec-less fallback chain — seen
from the other side. Fixing it would make `nullInitDefnParented2`'s chandle
clause derivable rather than enumerated.

**R7 — an ops fact, not ours.** `\`NUM2 s` (a macro supplying only the numeric
prefix of a time literal, with the unit written separately) **segfaults
Surelog**. The cell was removed from arm a4. Nothing in the corpus writes it.

---

## 6. REFUTATIONS, stated plainly

1. **`vpiConstType:9` is NOT `vpiTimeConst`.** The brief annotated it "(TIME)".
   `vpiTimeConst` is 8; 9 is `vpiUIntConst`, and Surelog's `paTime_literal` arm
   writes `vpiUIntConst` literally. A `time_typespec` does appear on the
   *variable*, but never on the constant.
2. **There is no timeunit scaling to decode.** The brief asked for one. The
   value comes from a hard-coded, non-monotone, timescale-blind factor table,
   and it was already transcribed in this repo as `§ srlgTimeLitVal` for the
   parameter carrier — a1 re-proves all seven of its cells against golden.
   *What was actually undecoded was the SIZE and the decompile*, which come from
   a completely different function (`adjustSize`) running one step later.
3. **`§ virtualIfaceNullInitIsClassParented6`'s stated gate is false.** "The
   gate is the virtual-interface property, not `null`" — a plain `chandle p =
   null;` (a2 m02) is class-defn-parented too. The gate is *having no typespec*.
   The old code was not wrong, it was **a third of a law**, and the widening is
   what let BuildUVMPkg's `m_unsupported_resource_base` cell land.
4. **The brief's axis list was incomplete in the direction that mattered.** It
   named "property type × initializer kind × static vs automatic". `static`,
   `const` and `local` (k11/k12/k13) turn out to change **nothing**; the axis
   that actually splits the family is **property type → TYPESPEC KIND**, and the
   cell that proves it (`longint`, k17) is one the brief's axes would never have
   generated.
5. **This was not a one-cell fix and it was not one design.** The brief framed
   BuildUVMPkg's head as the target and asked whether SimpleUVM/Scoreboard share
   it. They do — and the census found **two more** BuildUVMPkg cells nobody had
   named, which is why the patch has three arms.
6. **The head count is not a distance and this pass is the extreme case.**
   BuildUVMPkg's cmp output went 17 → 1366987 lines while the database moved
   strictly CLOSER (§4). See the note under GATE 5.
