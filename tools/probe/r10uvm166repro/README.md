# r10uvm166 — § `nameBasedArrayTdDeclIsRefVar166` — **A DECLARATION THAT NAMES A CLASS-HOMED TYPEDEF OF AN UNPACKED ARRAY WHOSE BASE IS WRITTEN AS A NAME IS ONE BARE `ref_var`, NOT AN `array_var` + ELEMENT PAIR** — the SeqDriver ×2 + SimpleUVM ×2 **82-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `4fbf5d0` |
| worktree | `/tmp/wt_r10uvm166` |
| pristine binary | md5 `3002e867e7137c2e5b2e2236d846dc2f`, built from a clean `4fbf5d0` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `8dc9d834176c7467f397b10f9d1f23d4`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` (the law + the predicate), `include/UhdmExporter.h` (one declaration), `src/TaskFuncEmit.cpp` (the factory + SITE 2), `src/StmtEmit.cpp` (SITE 1) — **+263 / −0**, purely additive |
| probe surface | `tools/probe/r10uvm166repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SeqDriver default / testflags** | **82** | **338** | 1 — a **NEW head**, a different object DEEPER in the walk (§7) |
| **SimpleUVM default / testflags** | **82** | **338** | 1 — the **SAME** new head |
| Scoreboard default | 145 | 145 | 1 unchanged, head log BYTE-IDENTICAL |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged, head log BYTE-IDENTICAL |
| BuildUVMPkg default / testflags | 29 | 29 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 34 | 34 | 1 unchanged, head log BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes; the surelog status histogram is IDENTICAL (`CMP_NOTEQUAL` stays 10 default / 9 testflags) and uhdm2rtlil stays `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2` | |
| byte movers | — | **7 / 956** surelog, **every one PREDICTED BY NAME**; **0 / 1358** uhdm2rtlil | |
| the family census (9 UVM DBs, both modes) | — | **14 cells moved, ALL TOWARD; 0 AWAY, 0 WRONG, 0 RESHAPE-AWAY** | |
| the grid (5 arms, both views) | — | **57 TOWARD + 22 RESHAPE-TOWARD, 0 AWAY, 0 WRONG, 0 RESHAPE-AWAY** | |
| the WIDE boundary (4668 arms, both views) | — | **9 moved arms, RC_DIFFS 0**; 4 are this pass's own grid (the positive control), 5 are r10vbuvm22's arms, re-measured against Surelog goldens: **109 TOWARD + 11 RESHAPE-TOWARD, 0 AWAY, 0 WRONG** | |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT'S
decompile size, and the new head is a five-argument `uvm_report_fatal` call that
decompiles its whole argument list twice.
`head_pris_SeqDriver.default.cmp` (82 lines) is the head the brief named;
`head_pat_SeqDriver.default.cmp` (338) is the new one.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduced the brief exactly —
SeqDriver ×2 **and** SimpleUVM ×2, **82 cmp lines, 1 head, ONE object on four
row-modes**. From `head_pris_SeqDriver.default.cmp`:

```
LHS  ref_var:   (uvm_pkg::uvm_utils::find_all::types) @651:13-651:18
       |vpiParent: \_begin: (uvm_pkg::uvm_utils::find_all) @651:5-651:19
       |vpiTypespec: \_ref_typespec: … |vpiActual:
                       \_array_typespec: (types_t) @642:11-642:26
RHS  array_var: (uvm_pkg::uvm_utils::find_all::types) @651:13-651:18
       |vpiTypespec: \_ref_typespec: … |vpiActual:
                       \_array_typespec:            @651:13-651:18
       |vpiArrayType:4
       |vpiReg: \_ref_var: (…::types) @651:13-651:18
                  |vpiTypespec: … |vpiActual:
                    \_array_typespec: (types_t) @642:11-642:26
```

**THE FIELD IS `VpiType`, on the DECLARATION ITSELF** — `BaseClass::Compare`'s
FIRST test, the arm that sets `m_failedLhs` **and** `m_failedRhs`, which is why
both sides print in full. Name, full name, parent `begin` and span already
agree; only the variable's CLASS and what it binds differ. Note that the
object golden binds — `array_typespec (types_t)` at `642:11-642:26` — is
**already in our database**, hanging off the element variable. We put it one
level too deep and wrap it in an `array_var` golden does not build.

Source — `uvm-1.2/src/base/uvm_misc.svh`:

```systemverilog
class uvm_utils #(type TYPE=int, string FIELD="config");
  typedef TYPE types_t[$];                                    // :642
  static function types_t find_all(uvm_component start);      // :649
    uvm_component list[$];                                    // :650
    types_t types;                                            // :651  <- THE HEAD
    …
  static function TYPE find(uvm_component start);             // :669
    types_t types = find_all(start);                          // :670  <- its twin
```

`uvm_component list[$]` on the line ABOVE the head is the control that made the
question sharp: it writes its dimension ON THE DECLARATOR and is a `class_var` +
`array_var` pair in golden and in ours alike, untouched by this pass.

---

## 2. THE LAW

> **§ `nameBasedArrayTdDeclIsRefVar166`** — *a declaration whose written type is
> a BARE NAME, with NO dimension written on the declarator, denoting a TYPEDEF
> OF AN UNPACKED ARRAY — `typedef <BASE> td [$] / [] / [k] / [key_t];` — whose
> **BASE TYPE IS ITSELF WRITTEN AS A NAME**, is a bare **`ref_var`** bound
> straight to that typedef's own typespec: **no `array_var` wrapper, no
> `vpiArrayType`, no `vpiReg` element variable, no range of its own.** The same
> declaration keeps the ordinary `array_var` when the typedef's base is written
> as a KEYWORD (`int`, `bit`, `logic`, `string`, `real`, `byte`, …) or as an
> INLINE `enum {}` / `struct {}` / `union {}`, and when the typedef's HOME is a
> PACKAGE or `$unit`.*
>
> **WHY, read off Surelog.** `CompileHelper::compileTypeDef`
> (`src/DesignCompile/CompileHelper.cpp:500-1103`) decides, per typedef,
> whether a UHDM typespec is attached to the `DataType` at all, and it has
> exactly three outcomes for `typedef <BASE> td [dims];`:
>
> * **BASE is an INLINE `enum` / `struct` / `union`** — the enum arm (`:755-772`)
>   and the struct / union arms (`:665-740`) ALWAYS run
>   `the_enum->setTypespec(array_tps)` / `st->setTypespec(array_tps)`. The
>   DataType HAS a typespec, in every home.
> * **BASE is a KEYWORD type** — `fC->Type(stype)` is neither `slStringConst`
>   nor `paClass_scope`, so the final `else` at `:1043-1097` runs: a
>   `SimpleType` is built, `compileTypespec` is called UNCONDITIONALLY, the
>   result is wrapped in `array_tps`, named, and `simple->setTypespec(ts)` is
>   set. The DataType HAS a typespec, in every home.
> * **BASE is a NAME** (`slStringConst` or `paClass_scope`, `:889`) — the arm
>   carries the comment *"Don't create the typespec here, as it is most likely
>   going to be incomplete at compilation time, except for packages and
>   FileContent"* and guards the whole build with
>
>   ```cpp
>   if ((reduce == Reduce::Yes) &&
>       ((valuedcomponenti_cast<Package*>(scope) ||
>         valuedcomponenti_cast<FileContent*>(scope)))) {
>     UHDM::typespec* ts = compileTypespec(...);
>     if (ts && (ts->UhdmType() != uhdmclass_typespec) &&
>         (ts->UhdmType() != uhdmunsupported_typespec)) { … setTypespec … }
>   ```
>
>   A CLASS, a MODULE, an INTERFACE and a PROGRAM are none of those two, so
>   `newTypeDef->setTypespec` is NEVER reached and the DataType has NO typespec.
>
> And that is the whole question `compileVariable` asks FIRST
> (`CompileType.cpp:341-359`):
>
> ```cpp
> if (const DataType* dt = component->getDataType(typeName)) {
>   dt = dt->getActual();
>   if (typespec* tps = dt->getTypespec()) {              // <- NULL here
>     if (variables* var = getSimpleVarFromTypespec(tps, ranges, …)) {
> ```
>
> With no typespec the arm is skipped, `design->getClassDefinition` finds
> nothing, and the declaration falls to the function's LAST arm (`:421-431`) —
> `MakeRef_var()` carrying `ts`, the typespec `compileTypespec` built for the
> WRITTEN NAME; when that arrived as an `unsupported_typespec`,
> `needLateTypedefBinding` hands it to `ElaborationStep::bindTypedefs_`, which
> swaps in the typedef's real object. Either way the declaration ends up a
> `ref_var` bound to the typedef's OWN `array_typespec`, named and spanned AT
> THE TYPEDEF.
>
> **AND WHERE THE `array_var` COMES FROM, which is the other side of that same
> `if`.** `getSimpleVarFromTypespec`'s `uhdmarray_typespec` case
> (`CompileType.cpp:220-233`) recurses on `Index_typespec` when there is one and
> otherwise mints `MakeArray_var()` with a fresh `array_typespec` that the
> caller immediately overwrites with `ts`. A TYPEDEF's `array_typespec` never
> carries an `Index_typespec` — only `ElaborationStep.cpp:2136-2140` and
> `UhdmWriter.cpp:731` ever set one, and only for an ASSOCIATIVE DECLARATION —
> so the `else` branch always wins. **That is why golden's `array_var` for this
> shape carries no `vpiArrayType`, no `vpiReg` and no ranges either**: the
> element / array PAIR only ever comes from `compileStmt`'s unpacked-dimension
> wrapper, i.e. from dimensions WRITTEN ON THE DECLARATOR.

### 2.1 THE DECODE IS EXPERIMENTALLY CONFIRMED, NOT JUST READ

Five grid arms, both views, golden built by Surelog itself
(`-parse -nocache -nowritecache -noprecompiledcache -d coveruhdm [-elabuhdm]`),
every command echoed with its binary PATH into the arm's own `cmds.txt`, every
rc recorded:

| arm | what it settles | golden |
|---|---|---|
| **`g166_a_core.sv`** — the CORE | is it the element TYPE or the base SPELLING? | a class typedef of a queue / dynamic array / associative array / fixed array of a TYPE PARAMETER all degrade to `ref_var`; the same four written `typedef int …` keep `array_var`; a nested-`begin` use degrades identically; a package typedef and a plain (non-generic) class typedef of `int` keep `array_var`; `int wrtQ166[$]` (dims on the declarator) is untouched |
| **`g166_b_elem.sv`** — the ELEMENT axis, 16 targets | the base SPELLING, not what it resolves to | a type parameter bound to int / a class / an enum / a packed struct / a string, a typedef OF a type parameter, an array of an array of one, **and a CONCRETE class handle, a CONCRETE enum and a CONCRETE packed struct** all degrade; `real`, `string` and `int` bases keep `array_var`, **including an associative one keyed by a TYPE PARAMETER and a fixed one sized by a VALUE parameter** — the element and the index are irrelevant, the written base is everything |
| **`g166_c_gate.sv`** — the HOME axis | which homes build the typespec | class / module / interface / program with a NAME base degrade in EVERY view; `$unit` (FileContent) RESOLVES; a PACKAGE resolves in its ELABORATED copy and degrades in its DEF-listing copy (`reduce == Reduce::Yes` is elaboration) — which is why the package home is DECLINED; a package typedef of an array of CLASS handles degrades even in the elaborated copy, bound to the base's `class_typespec` (the `!= uhdmclass_typespec` guard); a `Owner::name` base still degrades |
| **`g166_d_home.sv`** — the HOMES and SHAPES that FIRE | the two emitter sites cover the population | in-body method body (queue / dynamic / associative / fixed), nested `begin`, `fork` arm, `for` body, `case` item, in-body TASK, out-of-body method body level AND its nested `begin`, 2 and 3 declarators off one declaration, `static`, `automatic`, a WITH-INITIALISER local — all degrade, in all views, and the REFERENCES bound to them follow |
| **`g166_e_decline.sv`** — the DECLINE arm | every shape the law must not move | class PROPERTY, FORMAL, MODULE-level variable, dims on the declarator, KEYWORD base, INLINE-enum base, PACKAGE home, `$unit` home, `virtual` base — golden is `array_var` / `io_decl` for **every one of them**, so these declines are CORRECT and not merely conservative. Two are genuine residues (§7) |

---

## 3. STATED GATE == CODE GATE

**STATED**, as ONE predicate (`nameBasedArrayTdDeclIsRefVar166`,
`src/EmitHelpers.h`) asking FOUR questions and nowhere else:

1. **(1) SPELLING** — the declared type is a `NamedType` over ONE bare
   `IdentifierName`, and the declarator carries NO dimensions. A `Owner::td`
   spelling is § `classScopedTdDeclTsUnsupported11`'s arm (golden binds an
   `unsupported_typespec` named with the written scoped text there) and is
   deliberately out; a dimension written at the USE is `compileStmt`'s array
   wrapper and a different shape entirely (`g166_a_core` `wrtQ166`,
   `g166_e_decline` `declDimVal166`).
2. **(2) IT NAMES A REAL TYPEDEF OF AN UNPACKED ARRAY** — a `TypeAlias` whose
   syntax node is a `TypedefDeclaration` (a type PARAMETER's alias is spelled
   `TypeAssignment` and belongs to § `typeParamVarIsRefVar58`), and whose
   canonical type is a Queue / DynamicArray / AssociativeArray /
   FixedSizeUnpackedArray.
3. **(3) THE TYPEDEF'S OWN BASE IS WRITTEN AS A NAME** — its
   `TypedefDeclarationSyntax::type` is a `NamedType`. This is Surelog's
   `fC->Type(stype) == slStringConst || paClass_scope` and nothing else.
4. **(4) THE HOME GATE — A CLASS, and nothing else.** A PACKAGE and the
   COMPILATION UNIT are the two homes Surelog's guard lets through; a statement
   scope belongs to § `blockLocalTdDeclIsRefVarUnsupported155`. A MODULE /
   INTERFACE / PROGRAM home degrades in golden exactly like a class one, **but
   is DECLINED and the reason is measured**: the typespec our emitter has for
   such a declaration today is not the typedef's `array_typespec` (`g166_c_gate`
   `mEnumVal166` / `iEnumVal166` / `gEnumVal166` and `g166_d_home`
   `modInitVal166` / `modCombVal166` read `bit_typespec` spanned at the written
   type), so moving the KIND there would trade one wrong field for another
   instead of moving the cell toward golden. A first cut DID include those
   homes and the grid scored them `WRONG`; the gate was narrowed until the
   count was 0.

**SITES** — two, each asked BEFORE all three array factories, so ONE call
covers the queue, dynamic-array, associative and fixed-size shapes alike:

* `src/StmtEmit.cpp` ~2128 — SITE 1, the BLOCK-ITEM local. **This is the corpus
  head's site** (`uvm_utils::find_all`'s `types_t types;` and
  `uvm_utils::find`'s initialised twin).
* `src/TaskFuncEmit.cpp` ~5323 — SITE 2, the SUBROUTINE-BODY (TF-ITEM) local,
  which is the listing the `uvm_utils::find` cell also reaches. Gated on
  `blockItems9` exactly like the factories it stands in front of, so a
  PAREN-LESS function header keeps the flat model it has today (residue R1).

**THE FACTORY** (`makeNameBasedArrayTdRefVar166`, `src/TaskFuncEmit.cpp`) mints
ONE `ref_var` with the array_var's name, full name, parent and name-span, bound
through one `ref_typespec` to `makeTypespec(vs)` under `tfContext` — **the very
object the element variable binds today**, kind, name and span alike. **It does
NOT stamp `vpiInstance`**, and § `classHomedTypeTsNoPkgInstance4` is the reason
rather than an exception to it: the object bound here is the TYPEDEF's own
typespec and gate (4) has already required that typedef to live in a CLASS,
which is exactly the case those factories suppress the stamp for. (They ask
`classHomedType4` about the ELEMENT, because THEIR typespec is the element's; a
first cut copied that and stamped the class typedef's shared object with the
enclosing PACKAGE for an out-of-body method — golden reads `<noinst>` on all
four of `g166_d_home`'s `oobVal166` / `oobNestVal166` cells, in both views, and
the grid scored it `WRONG` until the stamp was dropped.)

**CODE** — `git diff 4fbf5d0 --numstat`: `src/EmitHelpers.h` **+164/−0**,
`include/UhdmExporter.h` **+12/−0**, `src/TaskFuncEmit.cpp` **+66/−0**,
`src/StmtEmit.cpp` **+21/−0**. **PURELY ADDITIVE — not one existing line was
deleted or changed**, so no existing arm's ANSWER can move except where this
predicate fires first and every earlier law had already produced the pair this
one replaces.

### 3.1 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | fires on the corpus? | what proves it |
|---|---|---|
| (1) bare `IdentifierName`, no declarator dims | **FIRES BOTH WAYS** | the corpus head accepts; `uvm_component list[$]` one line above it rejects and is byte-unchanged, as does every `Owner::td` corpus row |
| (2) `TypedefDeclaration`, not `TypeAssignment` | **rejects on the grid** | `g166_a_core` `rawQ166` (`T166 rawQ166[$]`, a type parameter named directly) is byte-unchanged |
| (2) canonical type is an UNPACKED array | **rejects on the grid** | `g166_a_core` `psVal166` (`typedef T166 parS166_t;`, a scalar alias) is byte-unchanged |
| (3) the BASE written as a NAME | **FIRES BOTH WAYS** | 10 of `g166_b_elem`'s 16 accept; `realQ166_t` / `textQ166_t` / `conQ166_t` / `keyed166_t` / `sized166_t` and `g166_e_decline`'s `keyBaseVal166` / `inlBaseVal166` reject, and golden keeps `array_var` for every one |
| (4) HOME is a CLASS | **FIRES BOTH WAYS** | the corpus head (a class) accepts; `g166_c_gate`'s module / interface / program / package / `$unit` cells and `g166_e_decline`'s `pkgHomeVal166` / `unitHomeVal166` / `modVarVal166` reject |
| SITE 2's `blockItems9` gate | **UNEXERCISED on the corpus** | `g166_e_decline` `parenLessVal166` is its only coverage, and it is residue R1 |
| the ASSOCIATIVE and FIXED-SIZE shapes | **UNEXERCISED on the corpus** | `g166_a_core` `paVal166` / `pfVal166` and `g166_d_home` `inAssocVal166` / `inFixVal166` are their only coverage, in both views. Stated rather than hidden: the corpus prediction found only queue-shaped cells |

---

## 4. THE MOVERS

### 4.1 PREDICTED FIRST, from the PRISTINE databases — `PREDICT.r10uvm166.txt`

`predsweep166.sh` censused **956 surelog** and **1358 uhdm2rtlil** databases on
BOTH sides with the pristine binary only, and kept every cell where the
declaration KIND disagrees and EITHER side is a `ref_var` bound to an
`array_typespec` — the only bucket this law can move, in either direction.

```
surelog     the law's bucket   14 cells   (golden ref_var+array_typespec(types_t), ours array_var)
            AWAY direction      0 cells
uhdm2rtlil  the law's bucket    0 cells
```

**PREDICTION, BY NAME:** seven databases, ONE cell each in
`uvm_utils::find` (`:670:13`) and `uvm_utils::find_all` (`:651:13`) —
`default/{MiniAmiq, Scoreboard, SeqDriver, SimpleUVM}` and
`testflags/{MiniAmiq, SeqDriver, SimpleUVM}`. Nothing else in either corpus.
BuildUVMPkg moves nothing: its `uvm_pkg` (the 1800.2 pp_output) carries no
`uvm_utils` class at all.

### 4.2 MEASURED — `byteverify.sh SELFCHECK=1`, both corpora

```
surelog     PATH_SETS_IDENTICAL (956)   MOVERS 7 / 956   SELFCHECK 955/956 flagged
              ./default/MiniAmiq-544c7f61      PREDICTED
              ./default/Scoreboard-59431470    PREDICTED
              ./default/SeqDriver-32af76aa     PREDICTED
              ./default/SimpleUVM-1dc93a62     PREDICTED
              ./testflags/MiniAmiq-544c7f61    PREDICTED
              ./testflags/SeqDriver-32af76aa   PREDICTED
              ./testflags/SimpleUVM-1dc93a62   PREDICTED
uhdm2rtlil  PATH_SETS_IDENTICAL (1358)  MOVERS 0 / 1358  SELFCHECK 1357/1358 flagged
```

**Seven movers, seven predictions, no residue either way.** Every one was
attributed ORDER-BLIND (both databases dumped with `uhdm-dump`, the workdir path
normalised away, both sides sorted): **98 differing lines each, and not one line
outside the law** — the two `array_var`s and their anonymous `array_typespec` +
`range` + two unbounded constants + `vpiArrayType:4` + `vpiReg` + the element's
`ref_typespec` disappear, and ONE `ref_var` bound to
`array_typespec (types_t) @642:11-642:26` takes their place.

**`default/Scoreboard-59431470` is the ~50/50 COIN** and is attributed the same
way: **98 differing lines out of 1,100,404**, all of them this law's — the
`svunit_pkg` `vpiTaskFunc` order flip did not land this run.

### 4.3 THE FAMILY CENSUS — `CENSUS.r10uvm166.txt`

Nine UVM databases (Scoreboard/testflags has no golden), golden vs PRISTINE vs
PATCHED, scored by `score166.py`: **14 cells moved, ALL TOWARD; 0 AWAY,
0 WRONG, 0 RESHAPE-AWAY**, and they are exactly the fourteen predicted. Every
other cell of every one of the nine is unmoved.

### 4.4 THE GRID — `GRID.r10uvm166.txt`

```
a_core      TOWARD=10  RESHAPE-TOWARD=0   AWAY=0  WRONG=0  RESHAPE-AWAY=0
b_elem      TOWARD=10  RESHAPE-TOWARD=10  AWAY=0  WRONG=0  RESHAPE-AWAY=0
c_gate      TOWARD=2   RESHAPE-TOWARD=2   AWAY=0  WRONG=0  RESHAPE-AWAY=0
d_home      TOWARD=35  RESHAPE-TOWARD=10  AWAY=0  WRONG=0  RESHAPE-AWAY=0
e_decline   TOWARD=0   RESHAPE-TOWARD=0   AWAY=0  WRONG=0  RESHAPE-AWAY=0   (byte-identical)
-- TOTAL MOVED-TOWARD = 79   MOVED-WRONG / AWAY = 0
```

A `RESHAPE-TOWARD` here is a cell whose golden multiset has more entries than
ours (a pre-existing listing residue) and whose comparable entries went from
2 of 4 fields onto 4 of 4.

**`g166_e_decline` is the negative control and it is a REAL one.** A first cut
of that arm compiled to NOTHING in Surelog — 29 rows, all built-in classes —
and would have read green while testing nothing; it was rewritten until Surelog
reported `Compile package ek166` / `Compile class ek166::Ladder166` /
`Top level module work@yard166`, and it now carries 84 scored cells. Its two
databases are BYTE-IDENTICAL on the two binaries in both views.

---

## 5. GATES — `GATES.r10uvm166.txt`

All nine green. Goldens **23 PASS / 0 FAIL** on both binaries and **0 PASS /
23 FAIL** with `SLANG_UHDM=/bin/false`; uhdm2rtlil **679 / 50 / 2** both modes;
the surelog status histogram IDENTICAL to pristine; `ct8rows` PASS against the
committed baselines AND against this pass's own pristine sweeps, status and
dump columns, both corpora, both modes; **no row converted**; canaries
`ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS ×2; `canaudit audited=29
UNCOVERED=0 FENCE-BREACH=0`; the five protected databases byte-identical with
the **SVSwitch `4842211c4030`** and **YosysVerx `6ccda350c24a`** pins held in
both modes.

**Every `cmds.txt` was audited BY BINARY PATH** (not by the string
`slang-uhdm`, which also matches the goldens cache): 1523 surelog + 1458
uhdm2rtlil invocations per binary, every one naming the frozen
`/tmp/r10uvm166_bin/*.bin`; **zero** main-tree and zero worktree-`build/`
leakage. `GOLDEN_DEFER` was never set. slang was not patched. `results/*.csv`
were never written.

A comment-only edit made after the sweeps rebuilt **BIT-IDENTICALLY** to the
swept patched binary (md5 re-checked, same `8dc9d834…`), so every gate above
stands for the shipped source.

## 6. BOUNDARIES — `BOUNDARY.r10uvm166.txt`

`bound166.sh` over a COPY of the WHOLE `tools/probe` tree — top level AND
subdirectories, both views, both binaries, children `</dev/null`, the file list
on fd 3, PROCESSED asserted against LISTED, scratch keyed on the RELATIVE path:
**`LISTED=4668 PROCESSED=4668 PRODUCED_DBS=4512 MOVED_ARMS=9 RC_DIFFS=0`**.

Four of the nine are this pass's own grid arms — the positive control that
proves the gate can see (and the fifth, `g166_e_decline.sv`, is byte-identical,
which is what it exists to be). The other five are `r10vbuvm22repro`'s verifier
arms `v1_homes` / `v2_rettypes` / `v3_kinds` / `v4_adversary` / `v6_nasty`, and
every one of them is this law's own population: a class-homed typedef of a queue
whose base is written as a NAME (`typedef base3 q_cls3[$];`,
`typedef ti3_t q_tdint3[$];`) named bare by a subroutine local. Each was
re-measured against a Surelog golden built for it, both views:
**109 TOWARD + 11 RESHAPE-TOWARD, 0 AWAY, 0 WRONG, 0 RESHAPE-AWAY.**

**ONE ATTRIBUTION worth recording, because it is a census trap.** A first cut of
`score166.py` merged the `-o` and the `--elabuhdm` databases into ONE multiset
and reported three `RESHAPE-AWAY` cells on `v3_kinds`'s `p3::c3::ob_cls::r`.
They are an artefact of the merge: per RUN, our DEF-view reference to `r` is now
UNBOUND — and **GOLDEN'S DEF-view reference is UNBOUND TOO** (`uhdm-dump` of the
Surelog golden shows no `vpiActual` under `ref_obj: (p3::c3::ob_cls::r)`); the
PRISTINE binding to an `array_var` was the wrong one. With the RUN in the key
all three score TOWARD. `score166.py` now keys on
`(RUN, row type, owner, NAME)` — the RUN **in**, the ROOT LABEL **out**
(RESUME §9), the name never replaced by a span.

## 7. RESIDUES AND R0

**R0 — the NEW SeqDriver / SimpleUVM head, on all four row-modes.** The head is
now `method_func_call: (uvm_report_fatal)` at `uvm_misc.svh:720:14`, inside
`uvm_utils::get_config`, and BOTH sides print in full — a **`vpiArgument`
VECTOR SIZE mismatch**:

```systemverilog
comp.uvm_report_fatal( "GET_CFG_TYPE_FAIL",                      // :720
                  {"set_config_object with field name ",FIELD,
                  " is not of type '",TYPE::type_name,"'"},
                  UVM_NONE , `uvm_file , `uvm_line );            // :723
```

Golden carries **5** arguments — exactly the five WRITTEN. We carry **7**: the
same five plus two constants spanned at `uvm_globals.svh:236:33` (`""`) and
`237:37` (`0`), which are `uvm_report_fatal`'s own FORMAL DEFAULTS for
`filename` and `line`. **R0: a call's argument vector carries only the
arguments written at the call site; the callee's remaining defaulted formals
must not be appended.** A secondary residue is visible in the same head and is
NOT the head (Compare reads no span): our macro-expanded constant for
`` `uvm_file `` is spanned `723:47-51:5`, a cross-macro-buffer `SourceLocation`
of exactly the kind RESUME §9 warns about.

**RESIDUES this pass measured and deliberately did NOT move:**

* **R1 — the PAREN-LESS function body.** `g166_e_decline` `parenLessVal166`:
  golden fires this law (`ref_var` + `array_typespec (galeQ166_t)`), we keep the
  flat element variable (`enum_var` + the SAME typespec, 1 of 2 fields right).
  SITE 2's `blockItems9` gate declines it, because the paren-less production
  models EVERY array local as a flat element variable at a different span and
  only this one cell of it was measured.
* **R2 — a STATEMENT-SCOPE typedef of an unpacked array.**
  `g166_e_decline` `blkVal166`: golden is `ref_var` +
  **`unsupported_typespec (blkQ166_t)`** — the same collapse, with
  § `blockLocalTdDeclIsRefVarUnsupported155`'s placeholder instead of a real
  typespec — and ours is still `array_var` + an anonymous `array_typespec`.
  That law's SITES 3-6 put its placeholder on the ELEMENT of a DECLARATOR
  array; this shape (a statement-scope typedef that is ITSELF an array, named
  bare) is the intersection of the two laws and belongs to neither as written.
* **the MODULE / INTERFACE / PROGRAM home.** `g166_c_gate` `mEnumVal166` /
  `iEnumVal166` / `gEnumVal166`, `g166_d_home` `modFnVal166` / `modTaskVal166` /
  `modInitVal166` / `modCombVal166` / `modFixVal166`: golden degrades exactly as
  in a class, but the typespec we have for those declarations today is a
  `bit_typespec` spanned at the written type, not the typedef's
  `array_typespec`, so the KIND alone would be a wash. Fixing the typespec for
  a module-homed typedef first is what unlocks them.
* **the PACKAGE home's DEF/ELAB split.** `g166_c_gate` `pEnumVal166` /
  `pStrVal166` / `pTdVal166`: golden's ELABORATED package copy is an
  `array_var` and its DEF-listing copy is a `ref_var` — the `reduce ==
  Reduce::Yes` half of the guard, visible as two different objects in one
  database. A view-split law of its own.
* **a PACKAGE typedef of an array of CLASS handles.** `g166_c_gate`
  `pClsVal166`: golden is `ref_var` + the base's **`class_typespec`** (named
  `sk166::pClsQ166_t`), not an `array_typespec` — the
  `!= uhdmclass_typespec` guard. Measured, declined, unchanged.
* **the `array_var` HALF of the same Surelog arm.** For a KEYWORD-based or
  INLINE-based array typedef named bare, golden's `array_var` binds the
  TYPEDEF's NAMED `array_typespec` and carries **no** `vpiArrayType`, **no**
  `vpiReg` and **no** ranges, while ours mints an anonymous `array_typespec` at
  the USE plus an element variable. It is the same `getSimpleVarFromTypespec`
  arm and it is present in every grid arm as `STILL`. **0 cells on the corpus**
  (measured: the corpus census finds no `G=array_var + named array_typespec`
  cell disagreeing with ours), which is why it is named here rather than moved.
* **a `virtual` interface base** (`g166_e_decline` `vifVal166`) resolves in
  golden and is correctly declined; slang does not spell it as a `NamedType`
  anyway.

## 8. HOW TO REPRODUCE

```bash
# build the census tool
g++ -O2 -std=c++17 ct166cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct166cen

# one grid arm, both views, on two binaries, then score it three ways
bash grid166.sh g166_a_core.sv <pristine> <patched> <workdir> <ct166cen>
python3 score166.py <workdir>/cen.g.txt <workdir>/cen.a.txt <workdir>/cen.b.txt --list

# the a-priori prediction, from PRISTINE databases only
CEN=<ct166cen> JOIN=join166.py bash predsweep166.sh <pristine workdir> pred.tsv

# the family census over the nine UVM rows
CEN=<ct166cen> SCORE=score166.py bash census166.sh <pristine wd> <patched wd> <outdir> \
    SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg

# the wide boundary gate
PRIS=<pristine> PATCHED=<patched> bash bound166.sh <copy of tools/probe> <outdir>

# the heads
bash rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
    BuildUVMPkg Earlgrey_0_1 Rggen
```
