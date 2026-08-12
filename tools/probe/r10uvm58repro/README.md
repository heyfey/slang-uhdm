# r10uvm58 — THE HEAD IS **CLEARED AND ADVANCED** on THREE of the four target rows, and **MY BRIEF WAS WRONG ABOUT WHICH OF ITS THREE DIFFERENCES uhdm-cmp CAN EVEN SEE**

**FIRST LINE, as the brief demands:** the head **CLEARED** on `SimpleUVM`
(default and testflags), `Scoreboard` (default) and `BuildUVMPkg` (both modes)
and has advanced to a new, characterised head in every case
(54 → **50**, 54 → **50**, 58 → **15** cmp lines).  `SeqDriver` **never carried
this head at all** — its head is a `class_typespec (adpcm_pkg::type_id)` and it
is **byte-identical before and after** (§1.2, brief refutation 3).  The witness
arm `a1_witness.sv` goes from **54 cmp lines / 1 head to 0 / 0 — CMP EQUAL**.

ONE law landed — **§ typeParamRetIsRefVar58** — **7 byte movers**, all seven UVM
rows, **165 added shapes, every one COVERED by golden, 0 OVER-FIRES**, and one
over-fire this pass **found and fixed before landing** (`uvm_queue`'s
`protected T queue[$]`, §5.3).  **No conversion**: 0 differing ROWS against both
committed baselines.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**  `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; every driver here passes them that way and prints that it did.

Base **266d3a6**.  Worktree `.claude/worktrees/r10uvm58`; pristine control
worktree `.claude/worktrees/r10uvm58pris`, configured and built by me at the
same commit.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 266d3a6) | `663899bcad3b7696f1d3f9fa972ec085` | my own build of 266d3a6 — **byte-identical to the main-tree `build/slang-uhdm`** and to my work-tree's pre-edit build, which is what makes it a valid control |
| v1 (gate mis-scoped) | `665c0b5a356dd176489dba64adb9d395` | had the `uvm_queue` over-fire; **never gated, never shipped** |
| v2 (over-fire fixed) | `5a848ec21da8b73688c53de7d5dcf1d2` | superseded by the vpiSigned guards |
| **FINAL (shipped)** | **`62bac79f9274890d566178600ddbf3b9`** | every gate number below was measured on THIS binary |

Base-commit check, because a finding was retracted this week for exactly this:
`git -C .claude/worktrees/r10uvm58 rev-parse HEAD` and the same for `…pris`
both print `266d3a6649663dc151188b0623e88d9336b7c745`, and the two trees' builds
were byte-identical before my first edit (`md5sum` above).  The binary embeds no
commit string (`strings -a build/slang-uhdm | grep -i 'slang version'` gives
only the format string), so the worktree revision plus the identical control md5
IS the check.

`git stash` was never used.  `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **READ ONLY**; row counts are
lines-minus-one because `wc -l` counts the header.  The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched — audited mechanically by `canaudit.sh` (FENCE-BREACH=0).
`GOLDEN_DEFER` left at default: **5 DEFERRED** in both surelog modes, as in the
baseline.

---

## 0. THE LAW, in a form a future pass can grep for

**§ typeParamRetIsRefVar58** — *a declaration whose **written type is a TYPE
PARAMETER** is a bare `ref_var` in golden, with **no `vpiSigned`**, whatever the
parameter is bound to — **except** a **CLASS** binding, which stays a
`class_var`.*

* **DIRECTION**: RESHAPE (one object's UHDM class + one bool).  Never add,
  never delete.
* **PREDICATE**: `typeParamVarIsRefVar58` in `src/EmitHelpers.h`.
* **GATE, and the gate in the code IS this gate** (checked by reading the
  source, not the comment): slang `TypeAlias` **AND** its syntax node is a
  `TypeAssignment` **AND** `getCanonicalType().kind != ClassType`.
* **SITE**: the **top** of `makeReturnVar` — the single factory that produces
  our function RETURN vars, our subroutine-body and block LOCALS, our container
  element regs and our non-integral for-loop variables.  One decision point, so
  no call site can drift.
* **ONE EXCLUSION**: the **class-property container element** factory
  (`src/UhdmExporter.cpp` ~1462) passes the **canonical** type so the gate
  cannot fire — a class property is the one declaration Surelog resolves
  (§5.3).
* **FOUR REPEATS of the "no vpiSigned" half**, at the only call sites that
  stamp `vpiSigned` *after* the factory: `src/TaskFuncEmit.cpp` ~941, ~1220,
  ~4438 and `src/StmtEmit.cpp` ~996.
* `grep -rn 'typeParamRetIsRefVar58\|typeParamVarIsRefVar58' include/ src/` →
  **15 hits across 5 files**: the law in `include/UhdmExporter.h`, the
  predicate + the gate in `src/EmitHelpers.h`, the exclusion in
  `src/UhdmExporter.cpp`, and the four signed repeats.

### The decoded Surelog mechanism (read, not guessed)

`CompileHelper::compileVariable`, `src/DesignCompile/CompileType.cpp:334-434`,
`slStringConst` arm, in order:

1. `component->getDataType("T")->getActual()->getTypespec()` fed to
   `getSimpleVarFromTypespec` — this is the arm that *would* give the concrete
   var class, and it yields **nothing** for a type parameter: a type parameter
   is a `Parameter`, and `DataType::m_typespec` is only ever set for `TypeDef`s
   (`ElaborationStep.cpp:217-284`).  `Parameter` has no `setTypespec` caller.
2. `design->getClassDefinition("T")` (and the two qualified retries) — there is
   no class called `T`.
3. `ts->UhdmType() == uhdmclass_typespec` → `class_var`.  **This is the ONE arm
   a type parameter can reach**, and only when its binding is a class.
4. the fallthrough at `CompileType.cpp:421` → **`MakeRef_var()`**, with
   `ref->VpiName(typeName)`, which the function-return caller
   (`CompileStmt.cpp:2401-2410`) then clears with `var->VpiName("")` — which is
   why golden's `ref_var` is anonymous.

A **CLASS PROPERTY** of type `T` is **not** this: it is compiled by
`ElaborationStep.cpp:1885-1900`, which has an explicit `Parameter` branch
calling `elabTypeParameter_` and **does** resolve to the concrete var class.
That asymmetry is the whole law, and it is why `uvm_queue`'s
`protected T queue[$]` must keep its `int_var` while `uvm_queue::get`, three
lines below it, becomes a `ref_var`.

---

## 1. THE HEAD, READ RATHER THAN ASSUMED — AND THREE REFUTATIONS

### 1.1 The head at 266d3a6 is the brief's, verbatim

`rowheads.sh` on my pristine sweep workdir, control binary
`663899bc…` (`grep -c '^LHS:'` at column 0):

| test | mode | cmp lines | heads |
|---|---|---|---|
| SimpleUVM | default | 54 | 1 |
| SimpleUVM | testflags | 54 | 1 |
| Scoreboard | default | 54 | 1 |
| Scoreboard | testflags | — | SKIP-NOFILE (`SLANG_REJECT`, no database — reported, not hidden) |
| SeqDriver | default / testflags | 85 | 1 |
| BuildUVMPkg | default / testflags | 58 | 1 |

`LHS ref_var (uvm_pkg::uvm_set_get_dap_base::get) @71:26` vs
`RHS int_var … |vpiSigned:1`, exactly as briefed.

### 1.2 REFUTATION 1 — **`SeqDriver` DOES NOT CARRY THIS HEAD.**

The brief says the head "also sits under BuildUVMPkg/SeqDriver".  BuildUVMPkg
does (see 1.5).  `SeqDriver`'s head is

```
LHS: class_typespec: (adpcm_pkg::type_id), line:440:12, endln:440:31
     |vpiParent: module_inst work@top_tb …
```

and its cmp output is **byte-identical before and after this pass** (`cmp -s`
on the two `.cmp` files: HEAD UNCHANGED, 85 → 85).  A pass that had reported
"cleared on all four rows" would have been wrong on one of them.

### 1.3 REFUTATION 2 — **ONLY ONE of the brief's THREE differences is a FIELD uhdm-cmp COMPARES.**

The brief lists three differences and calls all three "yours".  UHDM's compare
methods are **generated**, and the generator
(`~/git-repos/UHDM/scripts/classes.py`, `_get_Compare_implementation`) carries a
`vpi_blacklist` I read and quote in full:

```
uhdmId uhdmType vpiColumnNo vpiDefFile vpiDefLineNo vpiEndColumnNo
vpiEndLineNo vpiFile vpiFullName vpiIncludedFile vpiLineNo vpiRefColumnNo
vpiRefEndColumnNo vpiRefEndLineNo vpiRefFile vpiRefLineNo
```

`BaseClass::Compare` (`templates/BaseClass.cpp:163`) compares only
`VpiType`, `VpiName`, `VpiDefName`.  Therefore:

| brief's difference | compared? | evidence |
|---|---|---|
| (1) OBJECT CLASS `ref_var` vs `int_var` | **YES** — `BaseClass::Compare`'s `VpiType() - rhs->VpiType()` | this alone is the head |
| (2) TYPESPEC IDENTITY (`int_typespec@80:45` shared vs `@71:26` minted) | **NO** | `vpiLineNo`/`vpiColumnNo`/`vpiEnd*` blacklisted, **and the two objects are field-identical**: both `int_typespec`, both `|vpiSigned:1`, no ranges, no `Cast_to_expr` — `int_typespec::Compare` compares exactly those three things |
| (3) `vpiSigned:1` | **YES** — `variables::Compare` compares it | but it is a *consequence* of (1): a `ref_var` carries none |

So difference (2) — the half the brief asked me to build the fix around ("if
the shared object is the class parameter's default typespec then the fix is to
reuse it rather than mint") — **cannot clear or move any head**.  It is a pure
BYTE/dump residue, and it is ranked first in §7 with its mechanism fully
decoded, but implementing it would have risked hundreds of byte movers for
**zero** cmp gain.  I did not implement it, deliberately.

### 1.4 REFUTATION 3 — **the r10svs3 function span is NOT a compared field either, so it can never be a head.**

The brief says the `function` span difference "is visible in YOUR head too" and
asks me to measure it as confirmation for the concurrent pass.  Measured on the
FINAL SimpleUVM dumps, span-keyed, indentation stripped, `grep -Fc`:

| shape | golden | ours |
|---|---|---|
| `function: (uvm_pkg::uvm_set_get_dap_base::get), line:71:4, endln:71:16` | **2** | 0 |
| `function: (uvm_pkg::uvm_set_get_dap_base::get), line:71:4, endln:71:34` | 0 | **2** |
| `function: (uvm_pkg::uvm_set_get_dap_base::set), line:55:4, endln:55:16` | **2** | 0 |
| `function: (uvm_pkg::uvm_set_get_dap_base::set), line:55:4, endln:55:44` | 0 | **2** |

**CONFIRMED for r10svs3, and extended:** the qualifier-prefix end is not
specific to the type-parameter method — the `void`-returning `set` on line 55
has it too, and so does the NON-pure `uvm_set_before_get_dap::get`
(golden `113:4-113:11` = `virtual ` alone, ours `113:4-120:21`).  But
`vpiEndLineNo`/`vpiEndColumnNo` are blacklisted from `Compare`, so **that
difference is invisible to uhdm-cmp and is a dump/byte residue, not a head**.
I changed no `function` `setLoc`.

### 1.5 The four heads after the fix, and what each one now is

| test | mode | cmp lines | heads | verdict |
|---|---|---|---|---|
| SimpleUVM | default | 54 → **50** | 1 | **MOVED** — new head is a `constant` inside `uvm_report_error`: golden `@150:156` `vpiSize:64` `vpiConstType:9`, ours `@149:331` `vpiSize:1`, no `vpiConstType` (a macro-continuation constant; `vpiSize` and `vpiConstType` ARE compared) |
| SimpleUVM | testflags | 54 → **50** | 1 | MOVED, same head |
| Scoreboard | default | 54 → **50** | 1 | MOVED, same head |
| Scoreboard | testflags | — | — | SKIP-NOFILE (`SLANG_REJECT`, no database) |
| SeqDriver | default | 85 → **85** | 1 | **UNCHANGED** — never carried this head (§1.2) |
| SeqDriver | testflags | 85 → **85** | 1 | UNCHANGED |
| BuildUVMPkg | default | 58 → **15** | 1 | **MOVED** — its 266d3a6 head was THE SAME LAW at another site: `LHS ref_var (uvm_pkg::uvm_registry_common::__deferred_init::rgtry) @14104:16` vs our `int_var`.  New head: a `ref_obj (…::Tregistry::get) @14104:24` golden has and we lack (`RHS: <null>`) |
| BuildUVMPkg | testflags | 58 → **15** | 1 | MOVED, same |

---

## 2. WHAT IS AT 80:45 — ASKED, READ, ANSWERED

`uvm-1.2/src/dap/uvm_set_get_dap_base.svh` line 80, column 45, counted by hand
off the source line:

```
80:    pure virtual function bit try_get(output T value);
                                               ^ col 45
```

**It is the `T` of the FORMAL `output T value` in `try_get` — the LAST textual
use of the type parameter in that class.**  It is **NOT** the `type T=int`
default (that is at `32:44-32:47`, which is exactly where **we** put ours).

So the brief's guess ("plausibly the `type T=int` parameter's own default") is
**wrong**, and I did not guess — I censused the object on both sides.  Golden's
ONE `int_typespec @80:45` is shared by **five** things in the class listing plus
its own top-level entry (`grep -Fc`, indentation stripped):

| `int_typespec: , line:80:45, endln:80:46` | golden | ours |
|---|---|---|
| occurrences in the SimpleUVM dump | **6** | 2 |

Golden's six: the `type_parameter T`'s own `ref_typespec` → `vpiActual`;
`set::value`'s io_decl typespec; `try_set::value`'s; **`get`'s return var's**;
`try_get::value`'s; and the object's own top-level listing, where it shows
`|vpiParent: type_parameter (uvm_pkg::uvm_set_get_dap_base::T)` and
`|vpiSigned:1`.  **We mint a separate one per use**: `32:44` (the parameter),
`55:35`, `64:38`, `71:26` (the return), `80:45`.

### The typespec-sharing rule, MEASURED (this is residue R1, not the landed law)

Golden creates **ONE** typespec object per class type parameter and locates it
at the **default-value type token** of `type T=<type>`, then **RE-STAMPS** it to
the position of each `T`-typed **FORMAL** as those io_decls compile.  So the
final location is **the last `T`-typed formal when the class has one, and the
default token otherwise**.  Return vars, body locals and class properties bind
the same object and never move it.  Six independent cells agree:

| class | uses of `T` | golden's shared typespec | rule |
|---|---|---|---|
| `uvm_set_get_dap_base` | formals 55:35, 64:38, 80:45; return 71:26 | `80:45` | last FORMAL |
| `uvm_set_before_get_dap` | formals …, 128:40; property 77; return 113 | `128:40` | last FORMAL |
| `a1 c_pure` | formals 8:41, 9:45, 11:52; return 10:29 | `11:52` | last FORMAL |
| `a1 c_body` | formal 19:44; property 15:13; return 16:24 | `19:44` | the FORMAL |
| `a7 c_both` | formals 5:33, 6:40, 7:35, 7:47; returns 5:29, 6:29 | `7:47` | last FORMAL |
| `a5 base`, `a8 c_loc`, `v3 g58`, `a4 d_int` | **NO `T` formals at all** | the `int` of `type T=int` (6:32 / 6:25 / 6:23 / 10:36) | the DEFAULT token |

And when the binding is a **named typedef**, the shared object is the
**typedef's own** typespec (`v1 b_arr` → `array_typespec (p58v1::arr58_t)
@10:12`, `a4 d_enum` → `enum_typespec @4:4`, `a4 d_struct` →
`struct_typespec @5:12`).

---

## 3. THE ARMS

Every arm is one `.sv` in this directory, driven by `arm58.sh` (which prints the
slang binary and its md5 on every run, existence-checks all four tools, strips
`uhdm-dump`'s first line — the DATABASE PATH — from BOTH dumps, and treats a
missing database as exit 6 rather than a verdict).  Cell tables come from
`vcells.py`, which reads `vpiSigned` and the resolved typespec at the object's
**OWN CHILD DEPTH** (header indent + 2), never anywhere in its subtree, and
COUNTS identical `(kind,name,span)` keys so a multiplicity change is a differing
cell.  `S` = `vpiSigned` at own child depth.

| arm | what it isolates | cmp lines / heads before → after | differing cells before → after |
|---|---|---|---|
| **a2_pureconc** | **THE DECIDER, built first**: `pure virtual function int/bit/string g();` in a `#(type T=int)` virtual class AND in a non-parameterised one | **0 / 0 → 0 / 0** | **0/12 → 0/12** |
| **a1_witness** | the corpus witness `pure virtual function T get();` **and its NON-pure twin** with a body | **54 / 1 → 0 / 0** | 7/21 → 5/21 |
| a3_nonvirt | non-virtual, `static`, and a module-scope function in `module #(type T=int)` | 58 / 1 → 165 / 1 | 16/16 → 7/16 |
| a4_types | every binding a type parameter can default to | 2206 / 1 → 2200 / 1 | 20/24 → 11/24 |
| a5_spec | default vs `#(int)` vs `#(string)` vs specialised twice | **54 / 1 → 0 / 0** | 2/15 → 1/15 |
| a6_extern | `extern`/out-of-body + **the negative control** (pure virtual in a NON-parameterised class) | 58 / 1 → 24 / 1 | 12/16 → 10/16 |
| a7_formal | the parameter as return **and** formal | **54 / 1 → 0 / 0** | 7/14 → 5/14 |
| a8_locals | subroutine / named-begin / loop-body locals + **the class-property control** | **58 / 1 → 0 / 0** | 8/18 → 4/18 |
| v1_bound | array / queue / assoc / dynamic / virtual-interface / parameterised-class bindings | 319 / 1 → 319 / 1 | 10/15 → 7/15 |
| v2_elabmod | a module type parameter instantiated `#()`, `#(string)`, `#(byte)` | 169 / 1 → 165 / 1 | 6/6 → 3/6 |
| v3_specelab | a generic class as `#(int)`, `#(string)`, `#(byte)`-extended and defaulted | **58 / 1 → 0 / 0** | 5/14 → 2/14 |
| v4_contprop | **the ONE EXCLUSION as a repro**: container CLASS PROPERTY vs container LOCAL | 1210 / 1 → 1204 / 1 | 20/31 → 13/35 |

**Six arms became CMP EQUAL** (a1, a2, a5, a7, a8, v3).  `a3`/`v2`'s cmp-line
GROWTH is a head **ADVANCE**: their new head is `LHS: <null>` on a whole
`module_inst work@…` — a pre-existing, **arm-local** design-listing asymmetry
(`grep -c "module_inst: work@a3_mod58"`: golden 7, ours **8 before and 8
after**), unmasked because the class cells now compare equal.

### 3.1 a2 — the cell that decides which feature owns the law (BUILD FIRST, as briefed)

```
p58a2::c1::gi  8:29-8:32  vpiReturn function   golden int_var,S ts=int_typespec@8:29  ours int_var,S ts=int_typespec@8:29
p58a2::c1::gb  9:29-9:32  vpiReturn function   golden bit_var   ts=bit_typespec@9:29   ours bit_var   ts=bit_typespec@9:29
p58a2::c2::gs 16:29-16:35 vpiReturn function   golden string_var ts=string_typespec@16:29 ours the same
DIFFERING CELLS: 0 / 12          arm ours.uhdm: BYTE-IDENTICAL before and after
```

**PURE VIRTUAL IS NOT THE DISCRIMINATOR.  THE TYPE PARAMETER IS.**  A pure
virtual with a concrete return type was already right, in a parameterised class
and in a plain one, and this arm's database is **byte-identical** across the
patch.

### 3.2 a1 — the witness and its non-pure twin

Before (control binary):

```
p58a1::c_pure::get 10:29-10:30 vpiReturn function  g ref_var ts=int_typespec@11:52  o int_var,S ts=int_typespec@10:29  DIFF
p58a1::c_body::get 16:24-16:25 vpiReturn function  g ref_var ts=int_typespec@19:44  o int_var,S ts=int_typespec@16:24  DIFF
p58a1::c_body::m_value 15:15-15:22 vpiVariables class_defn  g int_var ts=@19:44  o int_var ts=@15:13  DIFF (ts only)
value 8:43-8:48 / 9:47-9:52  vpiIODecl function   g io_decl ts=@11:52  o io_decl ts=@8:41 / @9:45     DIFF (ts only)
DIFFERING CELLS: 7 / 21   cmp lines 54, heads 1
```

After (FINAL): **cmp lines 0, heads 0 — CMP EQUAL.**  The two `get` cells now
read `g ref_var / o ref_var`, and **all five remaining differing cells are
`ts=`-LOCATION ONLY** — the residue-R1 family, which §1.3 proves uhdm-cmp
cannot see.  Both `T` formals stay `io_decl` on both sides.  **The NON-pure twin
behaves exactly like the pure one**, which is the corpus's own second witness:
`uvm_set_before_get_dap::get` (line 113, `virtual`, with a body) is a golden
`ref_var` too.

### 3.3 a4 — the binding axis (axis 4, complete)

| `type T=` | golden return var | ours BEFORE | ours AFTER |
|---|---|---|---|
| `int` | `ref_var` ts=`int_typespec@10:36` | `int_var,S` | **`ref_var`** |
| `bit` | `ref_var` | `bit_var` | **`ref_var`** |
| `byte` | `ref_var` | `byte_var,S` | **`ref_var`** |
| `string` | `ref_var` | `string_var` | **`ref_var`** |
| `logic` | `ref_var` | `logic_var` | **`ref_var`** |
| `real` | `ref_var` | `real_var` | **`ref_var`** |
| enum typedef | `ref_var` ts=`enum_typespec@4:4` | `enum_var` ts=`bit_typespec` | **`ref_var`** ts=`bit_typespec` (ts is residue R3) |
| struct typedef | `ref_var` ts=`struct_typespec@5:12` | `struct_var` ts=`bit_typespec` | **`ref_var`** ts=`bit_typespec` (R3) |
| **a CLASS** | **`class_var`** ts=`class_typespec@16:36` | `class_var` | `class_var` (**unchanged — the exclusion**) |
| `type T` NO default | `ref_var`, **no typespec at all** | **ABSENT** | **ABSENT** (residue R2) |
| `type U=T` chain | `ref_var` ts=`int_typespec@18:36` | `int_var,S` | **`ref_var`** |

### 3.4 v1 — non-scalar bindings (the over-fire probe)

| `type T=` | golden | ours BEFORE | ours AFTER |
|---|---|---|---|
| `int arr58_t[3]` typedef | `ref_var` ts=`array_typespec(arr58_t)@10:12` | `array_var` ts=`int_typespec` | **`ref_var`** ts=`int_typespec` (R4) |
| `int q58_t[$]` | `ref_var` ts=`array_typespec@11:12` | `logic_var` | **`ref_var`** |
| `int as58_t[string]` | `ref_var` ts=`array_typespec@12:12` | `logic_var` | **`ref_var`** |
| `int dy58_t[]` | `ref_var` ts=`array_typespec@13:12` | `logic_var` | **`ref_var`** |
| `virtual if58` | `ref_var` ts=`interface_typespec@21:42` | `logic_var` | **`ref_var`** |
| **`kk58#(int)`** (parameterised class) | **`class_var`** | `class_var` | `class_var` (**unchanged**) |

### 3.5 a8 + v4 — WHERE the law reaches, and where it must NOT

| declaration | golden | ours BEFORE | ours AFTER |
|---|---|---|---|
| `T lv;` subroutine local (a8 m1) | `ref_var` | `int_var,S` | **`ref_var`** |
| `T bv;` named-begin local (a8 m2) | `ref_var` | `int_var,S` | **`ref_var`** |
| `T fv;` loop-body local (a8 m3) | `ref_var` | `int_var,S` | **`ref_var`** |
| `int i` loop var (a8 m3) | `int_var,S` | `int_var,S` | `int_var,S` (untouched) |
| **`T m_prop;` CLASS PROPERTY** (a8) | **`int_var`** | `int_var` | `int_var` (**untouched, both views**) |
| **`T qprop[$];` CLASS PROPERTY element** (v4) | **`int_var`** | `int_var` | `int_var` (**the EXCLUSION, §5.3**) |
| `T qloc[$];` subroutine-local element (v4) | `ref_var`, **no `vpiSigned`** | `int_var,S` | **`ref_var`** (the signed guards, §5.4) |
| `T sloc;` subroutine local (v4) | `ref_var` | `int_var,S` | **`ref_var`** |
| `T` as a FORMAL (a7, a1) | `io_decl` | `io_decl` | `io_decl` (**the law is about VARIABLES, not ports**) |

### 3.6 a5 / v2 / v3 — NOT view-scoped, NOT specialization-scoped

`a5` declares `base#(int)`, `base#(string)` and a second `base#(int)`, and
`extends base#(int)` / `extends base#(string)`; `v3` does the same for a
non-virtual generic class; `v2` instantiates `module m58 #(type T=int)` three
ways.  In **every** case golden emits exactly **ONE** listing of the generic's
method, and its return var is a `ref_var`.  There is no elaborated cell that
could disagree, so the gate needs no view test.  (`a5` `useint::get` /
`usestr::get`, which write `int`/`string` explicitly in the derived class, stay
`int_var,S` / `string_var` on both sides — 0 differing cells.)

### 3.7 a6 — THE NEGATIVE CONTROL

```
p58a6::c_negctl::get 20:29-20:32 vpiReturn function  golden int_var,S ts=int_typespec@20:29   ours the same
p58a6::c_negctl::ok  21:29-21:32 vpiReturn function  golden bit_var   ts=bit_typespec@21:29   ours the same
```

Per-shape, `grep -Fc`: `int_var: (p58a6::c_negctl::get), line:20:29, endln:20:32`
→ **golden 2 / pristine 2 / FINAL 2**; the same for `ok`.  The whole
`c_negctl` region of our dump has the **same md5** before and after
(`c948d615a1ebbea67c21c3def0b695fb`).  **The negative control is
byte-identical.**

---

## 4. THE FIVE GATES, each with the number I measured on `62bac79f…`

### GATE 1 — BUILD

Absolute build path
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10uvm58/build`;
`grep -c "Linking CXX executable slang-uhdm"` = **1** in the build log (a build
that compiles nothing still exits 0, so the link line is the check); `grep -iE
"error:"` = empty.  The md5 assertion ran as a **SEPARATE command**, with the
baseline validated as 32 hex chars (a missing or malformed baseline is exit 9):

```
v2   =5a848ec21da8b73688c53de7d5dcf1d2
FINAL=62bac79f9274890d566178600ddbf3b9
MD5 CHANGED: PASS
```

### GATE 2 — GOLDENS

```
./tests/check_goldens.sh            rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false …             rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump       496 match      183 differ        52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv → 0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both --jobs 2`

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump       default 225 match / 242 differ / 327 blank
           testflags 165 match / 298 differ / 331 blank
ct8rows.sh results/golden_surelog.csv → 0 differing ROWS (0 diff row-sides)
baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
PASS: every row byte-identical to the committed baseline
```

My **pristine** sweep reproduces the committed baseline exactly (0 differing
rows), which is what makes the byte comparison below meaningful.

### GATE 5 — BYTE VERIFIER, both corpora, against my own pristine 266d3a6 build

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged         SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
             SELFCHECK 952/953 flagged         SELFCHECK1 = 8  (= 7 real + 1 injected)
```

The 7 movers are exactly the UVM rows that produce a database:
`{SimpleUVM, BuildUVMPkg, SeqDriver} × {default, testflags}` +
`Scoreboard,default`.

---

## 5. EVERY MOVER ATTRIBUTED, PER SHAPE, AGAINST GOLDEN

`mv58.sh` dumps the patched, pristine and **golden** databases for every mover,
takes **every** changed dump line as a multiset delta (indentation stripped —
an object is not a dump occurrence), and looks each distinct shape up in
**golden** with a per-shape `grep -Fxc`.  ADDED and REMOVED are reported
separately.  This is the method that caught 11 over-fires an audit missed, and
this pass it caught one more (§5.3).

```
movers=7   ADDED instances=426   REMOVED instances=584
ADDED   : 165 distinct shapes — ALL of them `\_ref_var: …` — 165 covered, 0 OVER-FIRE
REMOVED : 172 distinct shapes — 158 `\_int_var:` + 7 `\_enum_var:` + 7 `|vpiSigned:1`
          170 correct, 2 UNDER-FIRE (both the bare `|vpiSigned:1` aggregate, §5.2)
SELFCHECK=1 (one fabricated shape injected per mover) → reported OVER-FIRE on all 7: PASS
```

Per mover: `SimpleUVM`/`Scoreboard`/`SeqDriver` +64/−88 line instances each,
`BuildUVMPkg` +53/−72 (both modes).

### 5.1 THE ONLY ATTRIBUTABLE MEASURE, per shape (`grep -Fc`, indentation stripped)

| shape | golden | before | after |
|---|---|---|---|
| `\_ref_var: (uvm_pkg::uvm_set_get_dap_base::get), line:71:26, endln:71:27` | **2** | 0 | **2** |
| `\_int_var: (uvm_pkg::uvm_set_get_dap_base::get), line:71:26, endln:71:27` | **0** | 2 | **0** |
| `\_ref_var: (uvm_pkg::uvm_set_before_get_dap::get), line:113:22, endln:113:23` | **2** | 0 | **2** |
| `\_int_var: (uvm_pkg::uvm_set_before_get_dap::get), line:113:22, endln:113:23` | **0** | 2 | **0** |

Exact, in both directions, on the witness **and** on its non-pure twin.  The
same holds for all 165 added shapes; a sample of the family (all `golden=ours`
after):

`uvm_built_in_clone::clone` 76:19 · `uvm_get_to_lock_dap::get` 94:22 ·
`uvm_queue::{get 86:20, get_global 72:19, pop_back 153:20, pop_front 143:20}` ·
`uvm_queue::get::default_value` 87:7 · `uvm_resource::read` 1587:12 ·
`uvm_simple_lock_dap::get` 92:22 · `uvm_utils::{find 669:19, find_all 649:19,
create_type_by_name 681:19, get_config 702:19}` and their locals
`typ`/`types`/`cfg` · `uvm_pool::{do_copy,do_print}::key` ·
`uvm_in_order_comparator::run_phase::{a,b}` · `uvm_tlm_fifo::flush::t` ·
`uvm_enum_wrapper::m_init_map::e` (the ENUM-bound cell, `enum_var → ref_var`).

Corpus-level reach on SimpleUVM, keyed on `(name,span)` with the variable-class
SET compared (`refvar58.py`): **73 → 50** mismatching keys that involve a
`ref_var` on either side; and over ALL variable cells (`vcells.py`), cells whose
**var class** differs: **172 → 114**.  Multiset distance (the **FIXED**
`r10uvm55repro/msdist.sh`, which keeps indentation): **146203 → 146063**.
Dump lines: ours 1100465 → 1100441 against golden's 1140700.

### 5.2 The two UNDER-FIRE flags are an INSTRUMENT ARTIFACT, and I proved it

Both are the same shape: the bare field line `|vpiSigned:1`, golden 5270 /
ours 4913 → 4889 in the two default-mode rows.  A **bare field line has no
owner** once indentation is stripped, so its multiplicity is a whole-database
aggregate and cannot be attributed.  The per-owner proof, at **own child
depth**, on SimpleUVM:

```
golden cells whose variable is a ref_var CARRYING vpiSigned : 0
ours   cells whose variable is a ref_var CARRYING vpiSigned : 0
```

**No `ref_var` in golden's SimpleUVM database carries `vpiSigned` at all**, so
dropping 24 of them per row is exactly right, and the pre-existing 5270-vs-4913
gap (357) is untouched by this pass except in the correct direction.  Recorded
here as a named caveat of `mv58.sh`: **never attribute a bare field line**.

### 5.3 THE OVER-FIRE THIS PASS CAUGHT AND FIXED BEFORE LANDING

Binary v1 (`665c0b5a…`, never gated) put the gate in `makeReturnVar` and nothing
else.  `mv58.sh` immediately reported, on **five** of the seven movers:

```
ADDED   x3  golden=0  ours=3  OVER-FIRE  \_ref_var: (uvm_pkg::uvm_queue::queue), line:43:15, endln:43:20
REMOVED x3  golden=3  ours=0  UNDER-FIRE \_int_var: (uvm_pkg::uvm_queue::queue), line:43:15, endln:43:20
```

`uvm_queue.svh:43` is `protected T queue[$];` — a **CLASS PROPERTY**, which
Surelog resolves through `ElaborationStep`'s `Parameter` branch and which is
therefore an `int_var` in golden.  Our container-element factory
(`src/UhdmExporter.cpp` ~1462) reached `makeReturnVar` with the **declared**
element type, so the gate fired on it.  Fixed by passing the **canonical** type
at that one site — every arm reachable from that branch reads only the canonical
type, so nothing else changes.  `v4_contprop.sv` is the repro; after the fix
`qprop`'s element is `int_var` on both sides while `qloc`'s (a subroutine-local
container) is `ref_var` on both.  **Final over-fire count: 0.**

### 5.4 The `vpiSigned` half needed FOUR repeats

The factory returns an unsigned `ref_var`, but four call sites stamp
`vpiSigned` **after** it (`TaskFuncEmit` ~941/~1220/~4438, `StmtEmit` ~996) and
would have produced `ref_var,S` — a flag golden never puts on a `ref_var`
(§5.2), and `variables::Compare` compares it.  `v4_contprop`'s `T qloc[$]`
element is the cell that showed it (`ref_var,S` → `ref_var`, arm cmp 1210 →
1206 → 1204).

---

## 6. CANARIES

| check | corpus | result |
|---|---|---|
| `r10oth7repro/ctcan2.sh`, `EXPECT_UNKNOWN=6` | uhdm2rtlil | ok=1 **changed=0 absent=0** unknown-patterns=6 → PASS |
| `r10oth7repro/ctcan2.sh`, `EXPECT_UNKNOWN=1` | surelog | ok=58 **changed=0 absent=0** unknown-patterns=1 → PASS |
| **`tools/probe/r10uvm52repro/canaries.sh`** (named explicitly — six files share that basename) | uhdm2rtlil | ok=8 **changed=0 absent=0** unknown-names=25 (expected for a u2r csv) |
| **`tools/probe/r10uvm52repro/canaries.sh`** | surelog | ok=52 **changed=0 absent=0** unknown-names=7 (the u2r-only canaries) |
| `r10uvm55repro/canaudit.sh` | static | audited=29 **UNCOVERED=0 FENCE-BREACH=0** → PASS |

BY NAME, on the surelog csv:

```
InterfaceModPort    default   OK  CMP_EQUAL/differ      InterfaceModPort   testflags OK CMP_EQUAL/differ
BlackParrotComplex  default   OK  CMP_EQUAL/differ      BlackParrotComplex testflags OK CMP_EQUAL/differ
ClassTypeParam      default   OK  CMP_EQUAL/differ      ClassParamAsParam  default   OK CMP_EQUAL/differ
SVSwitch            default   OK  CMP_NOTEQUAL/         Earlgrey_0_1       default   OK CMP_NOTEQUAL/
```

`ClassTypeParam` and `ClassParamAsParam` are worth naming: they are the two
canaries whose *subject* is a type parameter, and their databases are **byte-
identical** (they appear in no mover row), because neither declares a
type-parameter-typed variable — only type-parameter-typed *parameters*.

---

## 7. RANKED RESIDUE

Ranked by measured reach on the corpus, most valuable first.  R1 is the other
half of this pass's own subject.

| # | residue | measured reach | why it was not done here |
|---|---|---|---|
| **R1** | **The per-type-parameter SHARED TYPESPEC** (§2): golden mints ONE typespec per class type parameter, located at the `type T=<type>` default token and re-stamped to each `T`-typed FORMAL, and binds it from the return var, every `T` io_decl, every `T` property and every `T` local.  We mint one per use site. | `int_typespec@80:45` golden **6** / ours **2** in the dap class alone; **3971** of SimpleUVM's 8497 differing variable cells are `ts=`-LOCATION-ONLY; **every** remaining differing cell in a1/a5/a7/a8/v3 is this | **uhdm-cmp cannot see it** (§1.3: `vpiLineNo`/`vpiColumnNo`/`vpiEnd*`/`vpiFile` are blacklisted from the generated `Compare`, and the two typespecs are field-identical).  Pure byte residue; implementing it risks hundreds of movers for zero head movement.  **The rule is fully decoded above — a future pass can implement it from §2 without re-measuring.** |
| **R2** | `type T` with **NO default**: golden emits a `ref_var` with **no typespec at all**; we emit **no return variable** | a4 `d_nodef::get` — golden 1 object, ours ABSENT | a MISSING-object law, not a reshape; needs its own pass |
| **R3** | enum-/struct-bound type parameter: our typespec is a **`bit_typespec`** where golden shares the typedef's `enum_typespec`/`struct_typespec` | a4 `d_enum`, `d_struct`; **IS compared** (`VpiType` of the typespec) so it is head-making | wrong-typespec-KIND, adjacent to R1 but a different fix |
| **R4** | array-/queue-/assoc-/vif-bound type parameter: our typespec is `int_typespec`/`logic_typespec` where golden shares the typedef's `array_typespec`/`interface_typespec` | v1: 5 of 6 cells; a4's head and v1's head are both in the package `vpiTypedef` listing | same family as R3 |
| **R5** | `extern`/out-of-body method with a type-parameter return: golden emits **TWO** return vars (the in-class prototype's `ref_var` at the prototype span AND the out-of-body definition's `class_var` with an `unsupported_typespec (T)`), we emit one | a6, cmp 58 → **24**; its head is now golden's `unsupported_typespec: (T) @11:7` which we lack entirely | distinct law (prototype-vs-definition duplication) |
| **R6** | module-scope type parameter: golden's return typespec is an **`unsupported_typespec`** at the return token; ours is a resolved `int_typespec` | a3 `work@a3_mod58.mf`, v2 `work@m58.mf` (+ their locals) | R3/R4 family, module flavour |
| **R7** | **r10svs3's** `function` object span (qualifier-prefix end) | golden 2 / ours 0 at `71:4-71:16` **and** at `55:4-55:16` (the `void` sibling) and `113:4-113:11` (the non-pure sibling) | **owned by the concurrent pass**; I changed no `function` `setLoc`.  NOT a compared field (§1.4) |
| **R8** | golden `ref_var` / ours `class_var`\|`struct_var` at STATEMENT scope through a **typedef alias** to a class or struct — § aliasClassRefVar10 not extended past class handles | 14 keys on SimpleUVM (`uvm_component::m_set_cl_action::t`, `m_apply_verbosity_settings::{p,setting}`, `uvm_sequencer::{item_done,stop_sequences}::t`, …) | NOT type parameters; a sibling of the landed law with the same `MakeRef_var` shape |
| **R9** | golden `class_var` / ours `ref_var` — the **reverse** direction, an existing over-fire of § aliasClassRefVar10 on methods returning `uvm_queue#(…)` | 6 keys, all `uvm_resource_pool::lookup_*` / `find_unused_resources` | pre-existing, untouched by this pass |
| **R10** | a `TYPE[$]` typedef LOCAL: golden ONE `ref_var`, ours `array_var` + element `ref_var` (2 objects vs 1) | `uvm_utils::find::types` golden 4 / ours 3, `find_all::types` golden 3 / ours 3 | object-COUNT law, not a kind law |
| **R11** | `SimpleUVM`/`Scoreboard`'s NEW head: a macro-continuation `constant` inside `uvm_report_error` — golden `@150:156` `vpiSize:64` `vpiConstType:9`, ours `@149:331` `vpiSize:1`, no `vpiConstType` | the head on 3 of 7 UVM row-modes | the next head; both fields ARE compared, so this is the highest-value next target |
| **R12** | `BuildUVMPkg`'s NEW head: golden's `ref_obj (…uvm_registry_common::__deferred_init::Tregistry::get) @14104:24` with a `Tregistry::get` scoped name, `RHS: <null>` | the head on 2 of 7 UVM row-modes, at cmp depth **15** (was 58) | a scoped-name reference we do not emit |

---

## 8. THE DRIVERS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `a1_witness.sv` … `a8_locals.sv`, `v1_bound.sv` … `v4_contprop.sv` | the 12 arms, one axis each; header comments state the axis and the prediction |
| `arm58.sh` | one arm's golden + ours + dumps + cmp; prints the slang md5, existence-checks all four tools, `sed 1d` on both dumps, missing database = exit 6 |
| `vcells.py` | THE CELL TABLE: variable class + `vpiSigned` + resolved-typespec span at **OWN CHILD DEPTH**, multiplicities counted, golden always argv[1] |
| `mv58.sh` | PER-SHAPE MOVER ATTRIBUTION against golden, ADDED and REMOVED separately, with a `SELFCHECK=1` fabricated-shape control that must read OVER-FIRE |
| `kindcen58.py` | whole-database variable-class census keyed on `(name,span)`, by shape-set |
| `refvar58.py` | the `ref_var` slice of that census — the one-line reach number |

Reused unchanged: `r10uvm55repro/{rowheads.sh,msdist.sh,canaudit.sh}`,
`r10oth6repro/byteverify.sh`, `r10oth7repro/ctcan2.sh`,
`r10oth8repro/ct8rows.sh`, `r10uvm52repro/canaries.sh`.
`scripts/verify_golden.py` and `tests/check_goldens.sh` were not modified.
