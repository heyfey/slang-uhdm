# r10sd12 — the SeqDriver head: § declArrayElemKindIsDeclKind12

**The SeqDriver head is CUT on both rows, and `SeqDriver` now stands on the
SAME head as `SimpleUVM` and `Scoreboard`.** The `class_var` / `ref_var`
disagreement r10sd11 left as its R0 — the ELEMENT VARIABLE of
`uvm_resource_types::rsrc_q_t all[int];` at `uvm_resource.svh:955:34` — is gone
on all four UVM designs, together with its mirror image on `BuildUVMPkg`. The
new head is a DIFFERENT object, strictly LATER in Compare's walk, and it is
reported below as R0 rather than dressed up. **No row reaches `PASS_CMP`.**

| | |
|---|---|
| BASE | `4e3ca19` (`git rev-parse HEAD` grep-checked `=1` in both worktrees) |
| worktrees | `/tmp/wt_r10sd12` (delivered), `/tmp/wt_r10sd12pris` (pristine control, `git status --porcelain` = **0**) |
| delivered binary | md5 **`66eb59db9910ae25269ddfcf8a475b04`** |
| pristine binary | md5 **`a554402b367aeb786bef648638b94e35`** |
| production files | `src/EmitHelpers.h` **+140/−2**, `src/TaskFuncEmit.cpp` **+24/−9**, `src/StmtEmit.cpp` **+7/−2** |
| probe files | `tools/probe/r10sd12repro/` |

---

## 1. THE LAW

> **§ declArrayElemKindIsDeclKind12** — the ELEMENT variable of a
> DECLARATOR-ARRAY declaration at SUBROUTINE / STATEMENT scope (`T n[int]`,
> `T n[$]`, `T n[]`, `T n[4]`) takes **THE SAME OBJECT CLASS the SCALAR
> declaration `T n;` would take at that same site**. The brackets decide the
> `array_var`'s shape and NOTHING about the element's class.

### 1.1 WHY, read off Surelog and then measured

`CompileHelper::compileStmt`'s `paVariable_declaration` arm
(`src/DesignCompile/CompileStmt.cpp` ~1173) compiles the declarator's
dimensions and the DATA TYPE **separately**, and it builds the element by
calling the ordinary scalar factory on the DATA-TYPE NODE ALONE:

```cpp
variables* var = compileVariable(component, fC, Data_type, …);   // scalar
…
if (unpackedDimensions) {
  array_var* arr = s.MakeArray_var();
  …
  arr->VpiName(fC->SymName(Var));
  var->VpiName("");        // <- the SAME object, renamed
  var->VpiParent(arr);
  vars->push_back(var);    // <- and re-parented under vpiReg
}
```

**The element variable IS the scalar variable.** Every arm of
`compileVariable` therefore reaches it unchanged, and in particular the two
laws this emitter already carries for a class-nested typedef at subroutine
scope do:

* **§ classTdLocalVarKindFollowsCompileOrder10** — an `Owner::td` spelling ends
  at `compileVariable`'s `paClass_scope` arm, and **BOTH halves of that arm
  yield a `class_var`**: the resolved half runs `getSimpleVarFromTypespec` on a
  `class_typespec` (`CompileType.cpp` ~134, `case uhdmclass_typespec:
  MakeClass_var()`) and the tail is literally
  `if (var == nullptr) var = s.MakeClass_var();` (~616). A BARE `td` in an
  OUT-OF-BODY method body ends at the bare arm's `MakeRef_var` tail (~421).
* **§ aliasClassRefVar10** — the bare class-handle alias's `ref_var`.

**OURS ASKED NEITHER.** The four declarator-array element sites called
`makeReturnVar(s, <ELEMENT TYPE>)`, i.e. they handed the factory the type with
the brackets ALREADY PEELED and never looked at how the declaration was
WRITTEN.

### 1.2 THE TWO CORPUS ROWS, and they go in OPPOSITE directions

```
uvm_resource.svh:955:34   uvm_resource_types::rsrc_q_t all[int];
    golden class_var   ours ref_var       <- THE SeqDriver HEAD (sd11's R0)
uvm_factory.svh:2036      m_inst_typename_alias_t type_alias_inst[$];
    golden ref_var     ours struct_var    <- BuildUVMPkg, the OTHER arm
```

`all` is SCOPED and `uvm_resource_types` sorts after `uvm_resource_pool`, so
r10sd10's predicate answers `ClassVar`. `type_alias_inst` is BARE, its typedef
is `uvm_default_factory`'s own, and the body is an **out-of-body** `extern`
definition compiled by the FileContent pass before any class exists, so the same
predicate answers `RefVar`. **ONE predicate, two directions, both on the
corpus** — which is the reason to state the law as "the element is the scalar"
and not as "a scoped element is a class_var".

### 1.3 THE GRID — golden's rule, cell by cell

`grid12/`, five cells, each run on BOTH binaries by `ct12grid.sh` and scored on
the cmp verdict, the dump-content count AND the ELEMENT-KIND table
(`<array_var fullname>@line:col -> <element classes>`) golden-vs-ours.

| axis | cell | golden |
|---|---|---|
| **DECLARATOR FORM is irrelevant** | `h1` `a_aa[int]` `a_q[$]` `a_da[]` `a_fx[4]` | **class_var, all four** |
| **the TYPESPEC CLAIM is irrelevant** | `h1` `k_aa` `k_q` `k_da` `k_fx` on a CLAIMING typedef (r10sd11's `g8` axis) | **class_var, all four** — the typespec differs, the variable class does not |
| **the TARGET KIND is irrelevant** | `h1` `n_q` (`z1::i_t`, an INT typedef), `t_q` (`z1::st_t`, an in-place packed struct) | **class_var** — `paClass_scope` never asks what the typedef names |
| **BARE, own typedef, IN-BODY** | `h1` `s_q` `s_fx` | **ref_var** (§ aliasClassRefVar10, unchanged) |
| **OUT-OF-BODY flips the bare arm** | `h2` `e_own_q` `e_rec_q` `e_rec_fx` vs the identical `i_*` in-body declarations | **ref_var** out-of-body, resolved in-body |
| **SCOPED is class_var out-of-body too** | `h2` `e_sc_q`, `i_sc_q` | **class_var** both |
| **NEGATIVE CONTROL, 14 rows** | `h3` int / bit / `logic[3:0]` / string / real / byte / assoc / dyn / PACKAGE typedef (int, class, struct, enum) / a BARE CLASS NAME / an ANONYMOUS struct | **not one row moves**, on either binary |
| **SITE** | `h4` tf-item, `begin` block-item, `fork` arm, `initial` body | class_var at all four |
| **NON-SUBROUTINE sites must not move** | `h4` class PROPERTY `prop_q` / `prop_fx`, PACKAGE `pkg_q`, MODULE `mod_q` | byte-unchanged between the two binaries; `prop_*` is golden `logic_var` and ours already agrees |
| **ORDER** | `h5` `zz5::l_t` (owner LATE) vs `a5::e_t` (owner EARLY) | class_var for BOTH; the EARLY pair is r10sd10's residue R1 and is UNMOVED here — see §5.1 |

**`h3` is the cell that keeps the law honest.** It is 14 element types this law
must never touch, and its score is **IDENTICAL on both binaries** — the one
pre-existing disagreement it carries (an ANONYMOUS struct element: golden
`logic_var`, ours `struct_var`) is present before and after.

**`h2`'s cmp line count goes 52 → 331 and that is HEAD DEPTH, not a
regression.** The old head was the `struct_var` element itself (one small
object); once it is right, Compare's first divergence is a PRE-EXISTING
package-level listing difference, and a `package` decompiles its whole subtree.
The cell's dump content falls **298 → 258** and its ELEMENT-KIND table falls
**8 → 0**, and a `diff` of the two OURS dumps shows the only object lines that
moved are the three variable classes (everything else in it is the scratch-dir
path, which differs by construction between the two arms).

### 1.4 THE GRID SCORE — every cell, both binaries

`ct12grid.sh`, differing ELEMENT-KIND sides (golden-vs-ours, both sides
counted). **ZERO cells worsened.**

| cell | golden rows | pristine | delivered |
|---|---|---|---|
| `h1` declarator forms + spellings | 12 | 20 | **0** |
| `h2` out-of-body vs in-body | 8 | 8 | **0** |
| `h3` NEGATIVE CONTROL | 14 | 2 | **2** (unchanged — the point of the cell) |
| `h4` sites + non-subroutine negatives | 11 | 17 | **5** (all five are the PACKAGE / MODULE array rows, identical on both binaries) |
| `h5` order axis | 5 | 8 | **4** (the EARLY-owner pair, r10sd10 R1) |

---

## 2. STATED GATE == CODE GATE

**STATED**, as ONE question asked in ONE place:

1. **PEEL** — `declArrayElemDeclType12` takes the declared type and removes
   exactly as many unpacked containers as the DECLARATOR wrote dimensions.
   Never "peel every array level": a typedef that is ITSELF an array
   (`typedef int arr_t[4]; arr_t a[2];`) must keep its own level, because
   Surelog compiles `arr_t` as the Data_type and `[2]` as the unpacked
   dimension and nothing else. Fewer array levels than written dimensions (a
   PACKED dimension on the declarator) stops the peel and takes the unchanged
   direction.
2. **ASK r10sd10's PREDICATE, unchanged** — `classTdLocalVarKind10` gains one
   defaulted `tyOverride` parameter and nothing else; every existing caller
   still reads `dt->getType()`. The SPELLING half (`scoped` / `oneSeg`) already
   reads `getTypeSyntax()`, which for a declarator is the base `Owner::td` node
   and carries no brackets, so only the TYPE had to be peeled.
3. **`Resolved` IS THE UNCHANGED ARM** — it still calls `makeReturnVar` on the
   element type, so every int / bit / logic / enum / struct / string / class
   element the corpus has keeps the object it has today. The law can fire ONLY
   where r10sd10's predicate fires, i.e. where the declared type NAMES A
   TYPEDEF THAT LIVES IN A CLASS.

**SITES** — four, all of them `makeDeclArrayElemVar12(s, <decl symbol>, <elem
type>)` replacing `makeReturnVar(s, <elem type>)`, and nothing else moves:

* `src/TaskFuncEmit.cpp` ~1236 — `makeQueueDynArrayVar` (queue / dynamic).
* `src/TaskFuncEmit.cpp` ~1525 — `makeAssocArrayVar` (associative).
* `src/TaskFuncEmit.cpp` ~4826 — the FIXED-SIZE declarator array, tf-item form.
* `src/StmtEmit.cpp` ~1311 — the FIXED-SIZE declarator array, block-item form.

`makeQueueDynArrayVar` / `makeAssocArrayVar` are shared factories but are only
ever called from `TaskFuncEmit`'s tf-item arm and `StmtEmit`'s block-item arm
(vsd11 §V.3 measured that, and `h4` re-measures it here: the class property, the
package variable and the module variable are byte-unchanged).

**THE `vpiSigned` GUARD, extended for the same reason it exists.** All four
sites stamp `vpiSigned` AFTER the factory, guarded by
`!typeParamVarIsRefVar58(...)` because § typeParamRetIsRefVar58's `ref_var`
carries none. Surelog's `paClass_scope` and bare-name FALLBACKS compute no
signedness at all either, so the guard now also requires
`declArrayElemVarKind12(...) == Resolved`. Without it a signed packed-struct
typedef written `Owner::td` would have produced a `class_var` carrying a flag
golden never puts on one.

### 2.1 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | fires on the corpus? | what proves it |
|---|---|---|
| PEEL, `ndim == 0` early-out | **FIRES BOTH WAYS** | every non-array declaration returns `Resolved` immediately; `h3`'s 14 rows and the whole scalar census are the negative side |
| PEEL, fewer levels than written dims | **UNEXERCISED** | no corpus row and no grid cell writes a PACKED dimension on a declarator over a class-nested typedef; the arm returns the partially peeled type and can only reach `Resolved`, which is the unchanged direction. Stated, not hidden |
| r10sd10 SCOPED arm | **FIRES BOTH WAYS** | `h1` `a_*`/`k_*`/`n_q`/`t_q` and `h5` `l_*` accept; `h3`'s package typedefs and bare class name reject |
| r10sd10 BARE arm, out-of-body | **FIRES on the corpus** | `BuildUVMPkg` `type_alias_inst`; `h2` scores it in both directions |
| r10sd10 `Resolved` | **FIRES BOTH WAYS** | `h1` `s_q`/`s_fx` and `h5` `e_q`/`es_q` take it |
| the `vpiSigned` guard | **FIRES, and lands ON GOLDEN** — [V-CORRECTION vsd12 §V.1; this row read "UNEXERCISED" and was WRONG] | `h1`'s own `n_q` (`z1::i_t`, an INT typedef, LATE owner) is a SIGNED element under a FIRING predicate: pristine emits `int_var` + `vpiSigned:1`, delivered emits `class_var` with NO flag, and golden's `class_var` carries none. `vgrid12/v8` isolates it over five signed spellings (`int` / `byte` / signed packed struct / `logic signed [7:0]` / unsigned control) and the whole-variable table golden-vs-ours is **EMPTY** on the delivered binary. Without the guard the `class_var` would have carried a flag golden never puts on one — the guard is REQUIRED, not decorative |
| SITES 3 / 4 (fixed-size) | **grid-only** | no corpus row is a fixed-size declarator array over a class-nested typedef; `h1` `a_fx`/`k_fx`/`s_fx` (tf-item) and `h4` `blk_fx` (block-item) exercise both, and the boundary cell `qgrid4/qv12_clstype_fixedarray_oob` moves onto golden |

---

## 3. THE MOVERS

### 3.1 Census-predict, made FIRST and from the ARTIFACT — `ct12pred` / `ct12scan.sh`

**A NEW INSTRUMENT WAS REQUIRED, and why is the first thing its header says.**
r10sd10's `ct10pred` keys every `variables` object on *(vpiFullName, line:col)*
and calls a COLLIDING key `<AMBIGUOUS>`. A declarator array **is** a collision:
the `array_var` and its element carry the SAME `vpiFullName` and the SAME
`line:col`. Measured: on `default/SeqDriver` `ct10pred` reports
`G_CLASSVAR=0 … AMBIG=8` while the cmp head at 955:34 is precisely a golden
`class_var` against our `ref_var` under an `array_var`. **An instrument that
cannot see the head cannot predict the movers.**

`ct12pred` therefore joins on the ARRAY_VAR and compares the ORDERED list of
element classes under its `vpiReg`, in six buckets never netted: `G_CLASSVAR`,
`G_REFVAR`, `O_CLASSVAR`, `O_REFVAR`, `ELEM_COUNT`, `OTHER`.

**Calibrated before use**: golden-vs-golden on `SeqDriver` =
`shared=635 same=635`, every bucket **0**.

Run over every PRISTINE database of both corpora, **before any delivered
database was compared**:

| corpus | databases | scanned | empty-join | with rows | G_CLASSVAR | G_REFVAR | O_CLASSVAR | O_REFVAR | ELEM_COUNT | OTHER |
|---|---|---|---|---|---|---|---|---|---|---|
| surelog | **953** | 79 | 874 | **7** | **7** | **2** | 0 | 0 | 0 | 0 |
| uhdm2rtlil | **1358** | 82 | 1276 | **0** | 0 | 0 | 0 | 0 | 0 | 0 |

```
PREDICT default/BuildUVMPkg   default/Scoreboard   default/SeqDriver   default/SimpleUVM
        testflags/BuildUVMPkg testflags/SeqDriver  testflags/SimpleUVM
```

**Delivered score over the same 953 + 1358: EVERY BUCKET 0.** The population is
CLOSED — `G_CLASSVAR 7 → 0`, `G_REFVAR 2 → 0`, and `O_CLASSVAR` / `O_REFVAR` /
`ELEM_COUNT` / `OTHER` stay **0 → 0**, so the patch creates no disagreement of
any kind anywhere.

`ct12scan.sh` carries r10sd10/11's ACCOUNTING GUARD unchanged
(`scanned + empty_join + no_golden + no_line == found`, hard error otherwise);
the large `empty_join` counts are honest and counted, not skipped — most corpus
designs emit no `array_var` at all.

### 3.2 THE BRIEF'S OTHER HYPOTHESIS — MEASURED, AND REFUTED

The brief asked whether the residual `ct11pred` census `G_UNSUP=142`
(SeqDriver 44, SimpleUVM 10, Scoreboard 10, BuildUVMPkg 12 — reproduced
EXACTLY here) "may share the fix". **It does not, and this law converts ZERO
of it.** Enumerated with the committed `ct11pred -v`, the 142 are:

```
  REQ / RSP (12)   process (8)   uvm_vreg_field_cb_iter (6)   uvm_reg_field_cb_iter (8)
  uvm_vreg_cb_iter (2)  uvm_reg_cb_iter (2)  uvm_mem_cb_iter (2)
  uvm_cmdline_parsed_arg_t (2)  m_verbosity_setting (2)     ... x the 7 databases
```

— every one a **BARE** name and a **TYPESPEC** disagreement, while this law is a
**KIND** law that fires only on a class-nested typedef at a declarator array.
`ct11pred` scores **identically** on both binaries on all 7 databases
(`G_UNSUP` 44/10/10/12, `O_UNSUP=0`, `TS_KIND=0`, `TS_NAME` 152/138/140/164,
`TS_SPAN` 179/145/145/145), so this pass moves no typespec at all.

### 3.3 The MOVER RULE — size delta on every mover

`byteverify.sh`, both corpora, `SELFCHECK=1` and `SELFCHECK1=1`:

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 18 020 485 | 18 020 451 | **−34** |
| `testflags/SeqDriver` | 18 020 916 | 18 020 883 | **−33** |
| `default/SimpleUVM` | 11 141 173 | 11 141 170 | **−3** |
| `testflags/SimpleUVM` | 11 141 409 | 11 141 406 | **−3** |
| `default/Scoreboard` | 11 144 868 | 11 144 869 | **+1** |
| `default/BuildUVMPkg` | 11 104 635 | 11 104 642 | **+7** |
| `testflags/BuildUVMPkg` | 11 104 635 | 11 104 642 | **+7** |

All seven nonzero: **REAL movers** by the standing law, and they are **exactly
the seven predicted databases, name for name**. `testflags/Scoreboard` is
`SLANG_REJECT` at baseline, produces no database, and is a **SKIP**.

The signs differ because the two arms rename in opposite directions
(`ref_var` → `class_var` is +2 chars per line, `struct_var` → `ref_var` is −3),
and `default/Scoreboard` at **+1** is the smallest real delta this campaign has
recorded — it is one 9-character name becoming a 9-character name in a
length-prefixed record. vsd11 §V.5 recorded `default/Scoreboard` as NOT
byte-stable run to run at IDENTICAL size; here the size itself moves, so the
mover is real, and the per-shape table below is the reading that does not depend
on the md5.

### 3.4 Per-shape movers by MULTISET, ADDED and REMOVED separately

`ct7shape.py` on `sed 1d`-stripped, workdir-path-normalised dumps.
**ZERO shapes worsened on any design.**

| design | ADDED / REMOVED | shapes IMPROVED | shapes WORSENED | distance pris → new |
|---|---|---|---|---|
| `SeqDriver` | 3 / 3 | 2 | **0** | 356 606 → **356 600 (−6)** |
| `SimpleUVM` | 3 / 3 | 2 | **0** | 138 667 → **138 661 (−6)** |
| `Scoreboard` | 3 / 3 | 2 | **0** | 128 969 → **128 963 (−6)** |
| `BuildUVMPkg` | 9 / 9 | 3 | **0** | 76 451 → **76 433 (−18)** |

The transcription, and it is the WHOLE transcription:

```
SeqDriver / SimpleUVM / Scoreboard    class_var +3/−0   ref_var 0/−3
BuildUVMPkg                           class_var +3/−0   ref_var +6/−3   struct_var 0/−6
```

Three dump occurrences per moved object (the declaration, the `vpiReg` listing
and the elaborated view). **No `vpiSigned`, no span, no name, no `vpiFullName`,
no typespec line moves anywhere** — which is the law's own claim, stated as a
measurement.

### 3.5 The seven live UVM rows — head tuples on BOTH binaries

| row | pristine head | delivered head | cmp lines |
|---|---|---|---|
| `default/SeqDriver` | `class_var(…sort_by_precedence::all)@955:34` / `ref_var` | **`int_var(…m_wait_for_available_sequence::k)@919:35`** | 52 → **62** |
| `testflags/SeqDriver` | same | **same new head** | 52 → **62** |
| `default/SimpleUVM` | `int_var(…::k)@919:35` | **byte-identical head** | 62 → 62 |
| `testflags/SimpleUVM` | same | identical | 62 → 62 |
| `default/Scoreboard` | same | identical | 62 → 62 |
| `default/BuildUVMPkg` | `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@11947:40` | identical | 94 → 94 |
| `testflags/BuildUVMPkg` | same | identical | 94 → 94 |

Every head `grep -c '^LHS:' == 1`.

**READ THE 52 → 62 CORRECTLY.** `cmp lines` is HEAD DEPTH, never a distance.
The old head was a `class_var` under an `array_var`; the new one is an `int_var`
which prints `vpiName`, `vpiSigned` and `vpiAutomatic` as well. The head OBJECT
is different and strictly LATER, and it is **the head `SimpleUVM` and
`Scoreboard` already stood on** — `SeqDriver` has joined the other two uvm-1.2
rows rather than acquiring a head of its own. The distance measures agree:
`SeqDriver` −6, census −1 row on that database, and the whole `all[int]`
object at 955 is now byte-equal.

---

## 4. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex | both worktrees `git rev-parse HEAD` grep-checked `= 4e3ca19…` **=1**; delivered build ` error:` count **0**; `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`66eb59db9910ae25269ddfcf8a475b04`**, pristine **`a554402b367aeb786bef648638b94e35`** — 32 hex each, different. Pristine worktree `git status --porcelain` = **0 lines** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | 679/50/2, `ct8rows` 0 rows | default **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, testflags **679/50/2**, BOTH binaries; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` (**testflags-filtered FIRST** — the 731-row trap) → **0 differing ROWS (0 row-sides)**; pristine-vs-committed → **0**; pristine-vs-delivered (both modes, 1462 rows) → **0** |
| **4 surelog** | `--mode both`, `ct8rows` 0 rows over 1588 | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**, testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM), BOTH binaries. All four dump histograms **identical** to committed (default 225 match / 244 differ / 325 blank; testflags 165 / 300 / 329). `ct8rows` vs committed `results/golden_surelog.csv` → **0 differing ROWS** over 1588; pristine-vs-committed → **0**; pristine-vs-delivered → **0** |
| **5 BYTE VERIFIER** | both corpora, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | surelog **7 / 953**, u2r **0 / 1358**; `PATH_SETS_IDENTICAL` both; SELFCHECK **952/953** and **1357/1358**; SELFCHECK1 **8** and **1** — arithmetic consistent (1 corruption + 7 real; 1 corruption + 0 real). The 7 are **exactly the predicted set** (§3.1), all with nonzero SIZE-DELTA (§3.3); per-shape movers are the transcription and nothing else (§3.4) |

`GOLDEN_DEFER` printed **`[UNSET]`** before the sweeps. All sweeps `--jobs 2`
with private `--out` / `--workdir`, run SEQUENTIALLY so no two ever shared the
machine. **`SLANG_UHDM` pin verified by reading `cmds.txt` exhaustively**:
surelog 1573 cmds files / **1523 `slang:` lines, 1523 name the delivered binary,
0 name any other**; u2r 1462 / **1458, 1458 / 0**. `results/*.csv` READ ONLY.
No `git stash`. slang not patched.

### 4.1 CANARIES

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names 7 (the documented u2r-only names) |
| `canaries.sh` u2r | at baseline | **ok=8** vs committed (testflags-filtered), **ok=16** vs pristine (both modes), changed=0 absent=0 |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1` | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS** |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6` | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS**, run against THIS directory's scripts |
| fenced names | dispatched by no driver | `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` — all four **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch` databases | **byte-identical** | all four, **both modes**, `cmp -s` **BYTE-IDENTICAL** between the two binaries |

### 4.2 BOUNDARIES — every prior grid RE-RUN on BOTH binaries

`ct10bound.sh`, **90 cells** over `qgrid4` (13), `grid6` (6), `grid7` (6),
`grid7v` (3), `grid8` (6), `vgrid8` (3), `grid9` (7), `grid10` (9),
`vgrid10` (15), **`grid11` (8)** and **`vgrid11` (14)** — r10sd11's own grid and
its verifier's, both added to the boundary set by this pass:
**IDENTICAL 81, MOVED 7, UNSCORABLE 2.**

**The 2 UNSCORABLE are `vgrid11/v2_param_owner` and `vgrid11/v6_unit_scope`,
`NO_OUTPUT` on BOTH binaries**, and that is the cells' own documented state:
slang rejects them outright (`cannot refer to generic class with '::' without
providing parameter assignments`; `cannot reference compilation unit item from
within a package`) — vsd11 §V.4 built `v2` precisely to prove that arm is
unreachable. Named rather than netted; neither binary produces a database.

**All 7 movers land ON GOLDEN, and every one of them changes ONLY an element
variable's OBJECT CLASS** (no span, name, parent or typespec line moves in any
of them):

| cell | what moved | golden | direction |
|---|---|---|---|
| `qgrid4/q9_clstype_oob_local` | `p9::c9::f9::l9` struct_var → ref_var | ref_var | **CMP_FAIL → `PASS_CMP`**, content 54 → 42 |
| `qgrid4/q11_clstype_assoc_local` | `p11::…::l11` struct_var → ref_var | ref_var | **CMP_FAIL → `PASS_CMP`**, content 68 → 56 |
| `qgrid4/qv12_clstype_fixedarray_oob` | `p12::…::l12` struct_var → ref_var | ref_var | content 68 → 56 |
| `vgrid10/v1_aggregate_kinds` | `g_arr`, `g_q` struct_var → class_var | class_var | content 656 → 644 |
| `grid11/g1` | `a_carr` ref_var → class_var | class_var | content 400 → 396 |
| `grid11/g3` | `l_arr` ref_var → class_var | class_var | content 75 → 69 |
| `grid11/g8` | `a_aa` `a_q` `a_da` `a_fx` (+ the `k_*` four) ref_var → class_var | class_var | content 124 → **76** |

`grid11/g8` is r10sd11's own R0 cell and it falls by 48 dump lines. Two cells
reach `PASS_CMP` outright.

**r10sd11's LAW IS UNTOUCHED**: `ct11grid.sh` scores the TYPESPEC table on both
binaries as **10 / 10 / 2 / 8 / 4 / 11 / 2 / 8** — identical, cell for cell.
**r10sd10's LAW IS UNTOUCHED**: the SCALAR kind census (`ct10scan.sh` +
`ct10pred`) over all 953 surelog databases is **identical** on both binaries
(`scanned=783 candidates=7 G_CLASSVAR=0 G_REFVAR=52 O_CLASSVAR=0 O_REFVAR=0`).

**DETERMINISM.** `detcheck.sh` with the delivered binary on `h1 h2 h4 h5` and on
`grid11 g1 g8`: **3 runs each, 1 distinct sha256, 0 NO_OUTPUT.**

---

## 5. REFUTATIONS

### 5.1 "the ELEMENT is a class_var because the SPELLING is scoped" — TOO NARROW

The tempting one-line law reads off `grid11/g8` alone, where all eight cells are
scoped and all eight are `class_var`. `h2` refutes it as a complete statement:
`BuildUVMPkg`'s corpus row and `h2`'s `e_own_q` / `e_rec_q` / `e_rec_fx` are
**BARE** and golden gives them `ref_var`, not `class_var` and not `struct_var`.
The axis is not the spelling — it is **whatever the scalar declaration would
be**, which is r10sd10's whole predicate and not one arm of it. A pass that had
implemented the narrow reading would have left the BuildUVMPkg row wrong and
would have made `h2`'s three bare rows WORSE.

### 5.2 "the residual G_UNSUP=142 may share the fix" — REFUTED BY ENUMERATION

§3.2. All 142 are BARE-name TYPESPEC rows (`REQ` / `RSP` / `process` /
`uvm_*_cb_iter` / `uvm_cmdline_parsed_arg_t` / `m_verbosity_setting`); this law
converts none of them and `ct11pred` scores identically on both binaries. The
brief's own instrument was run first and answered the question against the
brief.

### 5.3 "ct10pred already measures variable kinds" — IT CANNOT SEE THIS HEAD

§3.1. The `array_var` and its element share `vpiFullName` AND `line:col`, so
r10sd10's census marks the entire population `<AMBIGUOUS>` — `G_CLASSVAR=0
… AMBIG=8` on the very database whose head is a `class_var`/`ref_var`
disagreement. Reusing it would have predicted **zero movers** for a pass that
moves seven databases. A new key was required and the reason is in the
instrument's own header.

### 5.4 "a fix at the element site can be read off the ELEMENT TYPE" — NO

`makeReturnVar(s, elemType)` is handed the type with the brackets already
peeled, and the class-nested typedef's OWNER-ORDER and OUT-OF-BODY questions are
not answerable from a type at all — they need the DECLARATION SYMBOL and its
written SYNTAX. That is why the fix passes the symbol, not the type, and why
the peel is by WRITTEN DIMENSION COUNT rather than by canonical array depth.

### 5.5 "the element and the scalar can be fixed independently" — THEY MUST NOT BE

`h5` `e_q` / `e_fx` — a SCOPED class-handle typedef whose owner sorts EARLY, so
r10sd10 answers `Resolved` — is golden `class_var` and ours `ref_var`, on BOTH
binaries. That is **r10sd10's residue R1 verbatim** (`grid10/g7 r_early_cls`),
at the scalar site as well as the element site. It would have been one line to
"fix" it here; doing so would have made the element DISAGREE WITH THE SCALAR
and broken this law's own statement. It is left alone, measured by `h5`, and
filed below as R1.

---

## 6. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct12pred.cpp` | **THE ELEMENT-KIND CENSUS**: joins the two databases on the ARRAY_VAR *(vpiFullName, line:col)* and compares the ordered list of element classes under `vpiReg`, six buckets, golden-first, never netted. Calibrated golden-vs-golden = 0; an empty join is exit 5, not a clean score. Its header states why `ct10pred` cannot do this job. |
| `ct12scan.sh` | `ct12pred` over every database of a sweep workdir, pairing each with the golden its own `cmds.txt` names. Carries the ACCOUNTING GUARD (`scanned + empty_join + no_golden + no_line == found`, hard error otherwise) and the `< /dev/null` that keeps a child from eating the list. |
| `ct12grid.sh` `grid12/h1…h5.sv` | the five cells of §1.3, each scored on cmp verdict + head count + dump content + the golden-vs-ours ELEMENT-KIND table, on both binaries. `LC_ALL=C sort` before `comm`. The table MERGES an array_var's repeated decompiles and prints `<AMBIGUOUS>` rather than silently resolving two different real element lists. |
| `ct10bound.sh` + `qgrid4/ grid6/ grid7/ grid7v/ grid8/ vgrid8/ grid9/ grid10/ vgrid10/ grid11/ vgrid11/` | the boundary re-run of §4.2, 90 cells, dumps NORMALISED for the workdir path first. |
| `ct10pred.cpp` `ct10scan.sh` `ct11pred.cpp` `ct11scan.sh` `ct11grid.sh` | r10sd10's and r10sd11's censuses and grid, carried forward UNCHANGED and re-run here as boundary instruments (§4.2). |
| `byteverify.sh` `msdist.sh` `ct7shape.py` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `rowheads.sh` `manifest.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `ct8arm.sh` `TAP.md` | carried forward from r10sd11 unchanged. |

---

## 7. THE PATCH

`/tmp/r10sd12.patch` — `git diff` vs `4e3ca19`, `include/` + `src/` +
`tools/probe/r10sd12repro` only. Reproducible with:

```sh
cd /tmp/wt_r10sd12 && git add -A tools/probe/r10sd12repro
git diff 4e3ca19 --binary -- include src tools/probe/r10sd12repro > /tmp/r10sd12.patch
md5sum /tmp/r10sd12.patch
```

The md5 is delivered with the pass's final report and NOT written here: this
file is inside the patch, so any md5 recorded here is stale the moment it is
written.

## 8. RESIDUES, RANKED

1. **R0 — THE NEW `SeqDriver` HEAD, and it is `SimpleUVM`'s and `Scoreboard`'s
   TOO.** `int_var (uvm_pkg::uvm_sequencer_base::m_wait_for_available_sequence::k)`
   at `uvm_sequencer_base.svh:919:35`. Everything is byte-equal —
   parent `assignment`, `int_typespec@919:31`, name, full name, span,
   `vpiSigned:1` — except that **golden carries `vpiAutomatic:1` and ours does
   not**. A for-header loop variable inside a class method. It is now the head
   on THREE of the four UVM rows at once, so one predicate closes three rows,
   and it is the cheapest next item by a wide margin.
2. **R1 — a SCOPED class-handle typedef whose owner IS compiled is `class_var`
   in golden and `ref_var` in ours**, at the scalar site AND the element site.
   `h5` `e_q` / `e_fx`, r10sd10's `grid10/g7 r_early_cls`. Surelog's
   `paClass_scope` arm has NO `ref_var` tail at all, so the fix is to make
   § aliasClassRefVar10 decline whenever the spelling is scoped — a change to
   r10sd10's `Resolved` arm, deliberately not made here (see §5.5). Zero corpus
   rows disagree today.
3. **R2 — a PACKAGE / MODULE-scope declarator array over a class-nested typedef
   has a `logic_var` element in golden and a `ref_var` in ours.** `h4` `pkg_q`,
   `mod_q`, identical on both binaries. A DIFFERENT Surelog pass compiles those
   (not `compileStmt`), so it is a different law and not this one's `Resolved`
   arm; the class PROPERTY form (`h4` `prop_q` / `prop_fx`) is golden `logic_var`
   and ours already agrees.
4. **R3 — an ANONYMOUS in-place struct element is a `logic_var` in golden and a
   `struct_var` in ours.** `h3` `an_s`, the one row of the negative-control cell
   that differs, unchanged by this pass and by design.
5. **R4 — the PEEL's "fewer levels than written dimensions" arm is
   UNEXERCISED** (§2.1). It is named rather than hidden and can only reach the
   unchanged direction. [V-CORRECTION vsd12 §V.1 — this residue ALSO claimed
   the extended `vpiSigned` guard was unexercised. **It is not.** `h1` `n_q`
   exercises it, the guard fires, and it lands ON golden; `vgrid12/v8` measures
   it over five signed spellings. The claim is struck, not softened.]
6. **Everything r10sd11 filed as R1–R6 stands**, unchanged and unmoved: the
   claim-blind FORMAL predicate, the non-`ref` formal's span, the bare
   class-nested typedef's typespec span, the RETURN variable's anonymous
   `class_typespec`, the nested DECLINED arm, and the claim table's blindness to
   un-instantiated modules.

---

## V. THE ADVERSARIAL VERIFICATION (vsd12)

Fresh worktrees `/tmp/wt_vsd12` (delivered) and `/tmp/wt_vsd12pris` (pristine),
both `git rev-parse HEAD` grep-checked `= 4e3ca19…` **=1**, pristine
`git status --porcelain` = **0**. Both binaries built independently at `-j 2`,
` error:` count **0**, link line seen before any md5:

| | |
|---|---|
| delivered | **`66eb59db9910ae25269ddfcf8a475b04`** — the pass's md5, **bit-for-bit** |
| pristine | **`a554402b367aeb786bef648638b94e35`** — likewise |
| patch | `/tmp/r10sd12.patch` md5 **`2cf340aebb83fea047c499c376108776`**, 7118 lines, applies clean on a FRESH `4e3ca19`; `git apply --numstat` = `140/2 src/EmitHelpers.h`, `7/2 src/StmtEmit.cpp`, `24/9 src/TaskFuncEmit.cpp`; files outside `src/` + `tools/probe/r10sd12repro/`: **0** |

**EVERY headline number reproduced independently**: grid12 `20→0 / 8→0 / 2→2 /
17→5 / 8→4`; boundary `90 cells IDENTICAL 81 MOVED 7 UNSCORABLE 2` with the
same seven cells and the same content counts; `ct12pred` calibration
`shared=635 same=635` all buckets 0; pristine predict **7 databases,
`G_CLASSVAR=7 G_REFVAR=2`**, delivered **every bucket 0** on 953 + 1358;
`byteverify` surelog **7/953** (the seven predicted names) and u2r **0/1358**,
`SELFCHECK` 952/953 + 1357/1358, `SELFCHECK1` **8** and **1**; all seven size
deltas `−34/−33/−3/−3/+1/+7/+7`; per-shape **0 shapes worsened**, distances
`−6/−6/−6/−18` with exactly the stated transcription; heads `52→62`,
`62→62`, `62→62`, `94→94`, every one `grep -c '^LHS:' == 1`, and the delivered
`SeqDriver` / `SimpleUVM` / `Scoreboard` heads IDENTICAL object for object;
gates 2/3/4 `23/0` + `/bin/false 0/23`, `679/50/2`, `469/11/25/5/284` +
`465/8/23/5/286/3/2/1/1`, `ct8rows` **0 differing ROWS** three ways on both
corpora; canaries `52/8/16` + `58` + `1` + `canaudit 29/0/0`; the four fenced
designs byte-identical; `ct11grid` `10/10/2/8/4/11/2/8` and the r10sd10 scalar
census `783/7/0/52/0/0` IDENTICAL on both binaries.

### V.1 THE ONE CLAIM THAT WAS WRONG — the `vpiSigned` guard is NOT unexercised

§2.1 and R4 both said the extended `vpiSigned` guard is UNEXERCISED. **grid12's
own `h1` exercises it.** `z1::i_t n_q[$]` is a class-nested INT typedef with a
LATE-sorting owner, i.e. a SIGNED element under a FIRING predicate:

```
h1 n_q element   pristine  int_var   + vpiSigned:1
                 delivered class_var + (no flag)
                 golden    class_var + (no flag)     <- the delivered answer
```

Without the guard the minted `class_var` would have carried a flag golden never
puts on one, exactly as the code comment predicts. The guard is **required**,
it **fires**, and it lands **on golden**. `vgrid12/v8_signed` isolates the
question over five spellings (`int`, `byte`, a signed packed struct,
`logic signed [7:0]`, and an unsigned control) each with its SCALAR TWIN: the
whole-variable table golden-vs-ours is **EMPTY** on the delivered binary and has
**10 differing sides** on the pristine one. The corrections are made in place
above rather than appended.

### V.2 INSTRUMENT DEFECT — `ct12grid.sh` runs `comm` in the WRONG LOCALE

The script sorts with `LC_ALL=C sort` and then compares with a BARE `comm`,
whose GNU implementation collates with `strcoll` outside the C locale. Under
this machine's `LANG=en_US.UTF-8` that is the exact trap the script's own
comment claims to have fixed. It is silent on the five `grid12` cells (all ten
arm scores are identical under both collations — measured, not assumed) and it
FIRES on `vgrid12/v3_unit_scope`, printing `comm: file 1 is not in sorted
order` twice per arm. `vct12grid.sh` carries the fix (`LC_ALL=C comm`);
`ct12grid.sh` is left as the pass shipped it so its numbers stay reproducible.

### V.3 `vgrid12` — 13 CELLS ON THE EDGES grid12 DOES NOT CONTAIN

Scored by `vct12grid.sh` on the ELEMENT-KIND table AND by `vartab.py`, the
WHOLE-VARIABLE table `<vpiFullName> -> <object classes>` — the measure
`ct12grid.sh` cannot make, because joining on the `array_var` cannot see the
SCALAR declarations. **This law's entire claim is "the element takes the class
the scalar would take", so almost every cell declares the SCALAR TWIN beside
each element row.**

| cell | axis | pris → delivered (differing sides) |
|---|---|---|
| `v1_param_owner` | PARAMETERIZED owner, both order directions | 10 → **4** (all four are R1) |
| `v2_chains` | alias-of-alias, cross-class chains | 4 → **2** (R1) |
| `v3_unit_scope` | `$unit` owner, self-qualified, bare | 8 → **2** (V.5) |
| `v4_multiseg` | 2-segment cross-package / same-package / imported | 8 → **0** |
| `v5_nested` | the DECLARING class is NESTED (vsd10's V-FIX terms) | 6 → **4** (R1) |
| `v6_iface_class` | INTERFACE-CLASS owner, both order directions | 4 → **2** (V.4) |
| `v7_peel` | **THE PEEL**: 2 dims, fixed+queue, dyn+fixed, assoc+queue, an ARRAY typedef ± an extra dim, `ndim==0` | 11 → **3** (all three pre-existing shape gaps) |
| `v8_signed` | five SIGNED spellings + scalar twins | 10 → **0** |
| `v9_oob_forms` | out-of-body assoc / dyn / 2-dim / fixed, a NESTED block inside an oob body, `foreach`, `do…while`, a MODULE task | 19 → **1** (a golden-only `foreach` index) |
| `va_specializations` | a GENERIC declaring class with TWO specializations | 2 → **0** |
| `vb_declarators` | THREE declarators on ONE data type, `static` / `automatic` / `const` | 12 → **0** |
| `vc_containers` | INTERFACE task, PROGRAM body, GENERATE-block `initial`, `always_comb`, a class declared INSIDE an interface | 16 → **4** (golden's program DEF-view) |
| `vd_inherit` | INHERITED typedefs, bare and scoped, same-package and cross-package, a `virtual` base | 10 → **2** (V.6) |

**NO CELL WORSENED, ON ANY AXIS. There is no pristine-right → patched-wrong
anywhere in this grid.** Per moved line, the ONLY dump line kinds that move on
any of the thirteen cells are `\_<object>_var` and `|vpiSigned` — no name, no
span, no parent, no typespec line moves anywhere. Determinism: 3 runs of the
delivered binary on `v7`, `v9`, `vb`, `vc` → **1 distinct sha256, 0 NO_OUTPUT**.

**`v7_peel` is the cell that verifies the pass's own invention.** r10sd10's
predicate was reused verbatim; the PEEL is new, and grid12 exercises it at
exactly ONE written dimension over a non-array typedef. Golden's answers on the
shapes grid12 does not have:

```
z7::d_t   m2[2][3]   pris ref_var    -> class_var   GOLDEN class_var
z7::d_t   mq[2][$]   pris logic_var  -> class_var   GOLDEN class_var
z7::d_t   dq[][2]    pris array_var  -> class_var   GOLDEN class_var  <- a whole
                                                       nested array_var replaced
z7::ia_t  ia[2]      pris int_var    -> class_var   GOLDEN class_var  <- ia_t IS
                                                       int[3]: the peel MUST stop
                                                       at the alias, and it does
z7::arr_t ar;        UNCHANGED (ndim == 0 early-out)
```

The README's "a typedef that is ITSELF an array must keep its own level" is
therefore not an argument — **golden says so**, at `ia`, and the code does it.

### V.4 NEW RESIDUE — an INTERFACE-CLASS owner NEVER resolves

`vgrid12/v6`: `aic6::a_t` (an `int` typedef in an **interface class** that sorts
BEFORE the declaring class, so r10sd10's REACH and ORDER terms both accept) is
golden **`class_var`** and ours **`int_var`** — while the identical shape over a
NORMAL early-sorting class (`h5` `es_q`, `a5::es_t`) golden-resolves. The
control is in the cell: the LATE-sorting interface class `zic6::z_t` is
`class_var` in golden too, so golden gives an interface-class owner `class_var`
in BOTH order directions. **Present at the SCALAR site and the ELEMENT site
IDENTICALLY, on BOTH binaries** — r10sd10's predicate is missing an
interface-class term, this pass inherits it faithfully, and no grid in the
campaign contained the shape.

### V.5 NEW RESIDUE — a `$unit` class's BARE own typedef whose TARGET is scoped

`vgrid12/v3`: `typedef uown3::u_t own3_t;` inside a `$unit` class, then
`own3_t b_q[$];`. r10sd10's BARE arm resolves lexically (its `g9`
`v_unit_self_bare`), so ours is `int_var`; golden is **`ref_var`**. Scalar twin
`b_s` gives the SAME pair, on BOTH binaries. Not this pass's arm; not previously
measured.

### V.6 NEW RESIDUE — an INHERITED bare typedef is NEVER resolved, either

`vgrid12/vd`: r10sd10's ORDER term names inheritance as its one unreconstructed
case and argues that on this corpus "the full-key relation agrees with the
fallback anyway". It does for a LATE-sorting base (`ib_q`, `zbase::zb_t`, ours
`ref_var` = golden) and for a cross-package base (`xb_q`, likewise). It does
**NOT** for an EARLY-sorting base in the SAME package: `abase::ab_t` named bare
from `zderiv` is golden **`ref_var`** and ours **`int_var`**, because
`owner.name < ctx.cls->name` says "compiled". Same on both binaries, same at the
scalar site.

**AND THIS IS THE CLEANEST CONFIRMATION OF THE LAW IN THE WHOLE VERIFICATION.**
On `vd` the delivered whole-variable table disagrees with golden on exactly two
names — `ea_q` and `ea_s` — and it gives them **the same wrong answer**:

```
GOLDEN   ea_q -> array_var,ref_var     ea_s -> ref_var
OURS     ea_q -> array_var,int_var     ea_s -> int_var
```

The element tracks the scalar even where the scalar is wrong. That is
§ declArrayElemKindIsDeclKind12 stated, and measured, on a row it gets wrong.

### V.7 SMALLER FINDINGS, none blocking

* `ct12pred` `continue`s on an `array_var` key present in ONE database only —
  there is no `MISSING` bucket. On `default/SeqDriver` it joins `shared=633`
  against a golden-vs-golden `635`, so two golden keys are unjoined and unnamed.
  The "zero over-fire" claim does not rest on this instrument alone
  (`byteverify` + the per-shape table cover a vanished object), but the census
  as written could not see one.
* `vgrid12/v7` `aq` — `z7::d_t aq[int][$]`, an ASSOCIATIVE array OF A QUEUE —
  emits NO `array_var` at all in ours (a flat `logic_var`) where golden emits
  `array_var` + `class_var`. Pre-existing, identical on both binaries, and
  outside this law's reach because the factory never runs.
* `vgrid12/v7` `ar` / `ir` — the SCALAR of a class-nested ARRAY typedef
  (`z7::arr_t ar;`) is a flat `class_var` in golden and `array_var` + element in
  ours. Pre-existing; the `ndim == 0` early-out correctly leaves it alone. It is
  the MIRROR of this law and the obvious next cell.
* `vgrid12/vc` — a PROGRAM's array local is decompiled TWICE in golden, once
  with a `class_var` element and once with a `logic_var` one; ours emits only
  the first view. The delivered binary moves onto golden's elaborated view.

### V.8 VERDICT

**ACCEPT.** Every headline number is reproduced bit-for-bit from an independent
build. The law is stated correctly, the code gate is the stated gate (with the
one `vpiSigned` correction in §V.1, which makes the guard MORE load-bearing than
the pass claimed, not less), the peel — the pass's only invention — is confirmed
by golden on five shapes its own grid does not contain, and thirteen adversarial
cells over parameterized owners, chains, interface classes, `$unit`, nested
declaring classes, multi-segment spellings, inheritance, specializations,
declaration lists, lifetimes and five container kinds produce **zero**
pristine-right → patched-wrong rows. The three new residues (§V.4, §V.5, §V.6)
are all r10sd10's predicate, all present identically at the scalar site, and all
unchanged by this pass.
