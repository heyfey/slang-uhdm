# r10uvm155 — § `blockLocalTdDeclIsRefVarUnsupported155` — **A TYPEDEF DECLARED INSIDE A STATEMENT SCOPE IS REGISTERED IN NO `DesignComponent`, SO EVERY DECLARATION THAT NAMES IT IS A `ref_var` OVER AN `unsupported_typespec`** — the BuildUVMPkg ×2 **56-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `5b84cae` |
| worktree | `/tmp/wt_r10uvm155` |
| pristine binary | md5 `62edd55590a0e02a0647ac59dfb32820`, built from a clean `5b84cae` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `cd167bd1925a7198211625b5124e8c4d`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` (the law + the predicate), `include/UhdmExporter.h` (one declaration), `src/TypeEmit.cpp` (the factory), `src/TaskFuncEmit.cpp` (SITES 1, 3, 4, 5), `src/StmtEmit.cpp` (SITES 2, 6) |
| probe surface | `tools/probe/r10uvm155repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **BuildUVMPkg default / testflags** | **56** | **1371** | 1 — a **NEW head**, a different object DEEPER in the walk (§7) |
| SeqDriver default / testflags | 22 | 22 | 1 unchanged, head log BYTE-IDENTICAL |
| SimpleUVM default / testflags | 36 | 36 | 1 unchanged, head log BYTE-IDENTICAL |
| Scoreboard default | 163 | 163 | 1 unchanged, head log BYTE-IDENTICAL |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 31 / 54 | 31 / 54 | 1 unchanged, head log BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes; `CMP_NOTEQUAL` stays **19** on surelog and `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2` on uhdm2rtlil, status histograms IDENTICAL | |
| byte movers | — | **3 / 956** surelog (two PREDICTED BY NAME + the Scoreboard COIN, 0 order-blind lines), **0 / 1358** uhdm2rtlil | |
| the family census (9 UVM DBs, full payload) | — | **1 cell moved, TOWARD; 0 WRONG, 0 AWAY, 0 RESHAPE** | |
| the grid (5 arms, both views) | 93 differing cells | **20** — **73 MOVED TOWARD, 0 MOVED WRONG, 0 AWAY** | |
| the WIDE boundary (4381 arms, both views) | — | **11 moved arms, 78 cells TOWARD, 0 AWAY, 0 RESHAPE** (5 of the 11 are this pass's own grid — the positive control) | |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT'S
decompile size, and the new head is a `begin` that decompiles its whole body.
`head_pris_BuildUVMPkg.default.cmp` (56 lines) is the head the brief named;
`head_pat_BuildUVMPkg.default.cmp` (1371) is the new one.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on the pristine sweep reproduced the brief exactly — BuildUVMPkg
×2, **56 cmp lines, 1 head**. From `head_pris_BuildUVMPkg.default.cmp`:

```
LHS  ref_var: (uvm_pkg::uvm_agent::build_phase::__tmp_int_val__) @51340:36-51340:51
       |vpiTypespec: \_ref_typespec: … |vpiActual:
                       \_unsupported_typespec: (__tmp_int_t__) @51340:6-51340:19
RHS  bit_var: (uvm_pkg::uvm_agent::build_phase::__tmp_int_val__) @51340:36-51340:51
       |vpiTypespec: \_ref_typespec: … |vpiActual:
                       \_bit_typespec:                          @51340:6-51340:19
```

**THE FIELD IS `VpiType`, on the DECLARATION ITSELF.** Both sides print in
full, which is `BaseClass::Compare`'s FIRST test — the arm that sets
`m_failedLhs` **and** `m_failedRhs`. The name, the full name, the span, the
parent `begin` and even the typespec's SPAN are already identical on both
sides; only the variable's kind and the bound typespec's kind+name differ.

Source — `1800.2-2017-1.0/pp_output/uvm_pkg.sv`, a `uvm_config_db` macro
expansion inside `uvm_agent::build_phase`:

```systemverilog
  if (!/* SUCCESS */ found) begin                                     // :51337
     typedef bit [$bits(                                              // :51338
                /* TYPE */    uvm_active_passive_enum)-1:0] __tmp_int_t__;  // :51339
     __tmp_int_t__                 __tmp_int_val__;                   // :51340  <- THE HEAD
     bit                           __tmp_success_val__;               // :51341
```

`__tmp_int_t__` occurs exactly THREE times in the whole 83,264-line file: the
typedef at 51339, this declaration at 51340, and a `uvm_resource#(__tmp_int_t__)`
actual at 51347 (a parameterised-class handle, `class_var` + `class_typespec`
on BOTH sides — untouched).

---

## 2. THE LAW

> **VERIFIER AMENDMENT (r10v155).** The statement below was measured true for
> modules, interfaces, packages and classes, but the adversarial verifier found
> TWO faces where it over-fires, and both are now gated in the production
> predicate. Read this box with the law:
>
> 1. **A PROGRAM's `initial` / `final` body is NOT a statement scope to
>    Surelog.** `CompileModule.cpp:529-538` carries `paSeq_block` / `paPar_block`
>    / the two subroutine-body types among the module's (and interface's)
>    collect `stopPoints`; `CompileProgram.cpp:97-99` carries
>    `{ paClass_declaration }` and nothing else, so the program's walk descends
>    into the procedural block, reaches the `paData_declaration`, and REGISTERS
>    the typedef. Golden RESOLVES there (`byte_var` + the real typespec). A
>    program's SUBROUTINE body still degrades. Gate:
>    `stmtScopeIsProgramProcedural155`.
> 2. **The shadow clause must consult IMPORTS.** `Scope::find` is direct
>    members only — it returns `nullptr` for an `ExplicitImport`
>    (slang `Scope.cpp:582-584`) and a wildcard import is not in the name map at
>    all (`MemberSymbols.h:88-91`) — while Surelog's `getClassDefinition` does
>    resolve an imported name. A statement-scope typedef shadowing an
>    explicitly- or wildcard-imported CLASS must NOT degrade. Gate:
>    `importedTypeLike155`.
>
> Evidence, grids and the ten arms: `tools/probe/r10v155repro/README.md`.


> **§ `blockLocalTdDeclIsRefVarUnsupported155`** — *a declaration whose written
> type is a BARE NAME denoting a **TYPEDEF DECLARED INSIDE A STATEMENT SCOPE**
> — a `begin` / `fork` arm / loop body / `case` item, a subroutine BODY, an
> `initial` / `always` body — binds NOT that typedef's real typespec but an
> `unsupported_typespec` **NAMED with the WRITTEN TYPE NAME** and **SPANNED
> over the WRITTEN TYPE**, and the declaration itself is a `ref_var`, whatever
> the typedef's target type is. **UNLESS the same NAME also denotes a type
> OUTSIDE every statement scope** — a class / package / module / `$unit`
> typedef, a type parameter, or a CLASS — in which case Surelog binds THAT one
> and nothing about the declaration moves.*
>
> **WHY, read off Surelog.** `CompileHelper::compileStmt`'s
> `paType_declaration` arm (`src/DesignCompile/CompileStmt.cpp:1284-1290`) is
>
> ```cpp
> case VObjectType::paType_declaration: {
>   if (pstmt) {
>     // Keep type declaration local to the current stmt
>     component = nullptr;
>   }
>   compileTypeDef(component, fC, fC->Parent(nodeId), compileDesign, Reduce::No, pstmt);
> ```
>
> and EVERY `insertTypeDef` / `insertDataType` inside `compileTypeDef`
> (`CompileHelper.cpp:558-636`, `:742-895`) is guarded `if (scope)`. A typedef
> compiled as a STATEMENT therefore lands in **no** `DesignComponent`'s
> data-type map — and a subroutine BODY takes that same arm, because
> `compileTask` / `compileFunction` pass the synthesised `begin` as `pstmt`
> (`CompileStmt.cpp:2046-2075`). So when the DECLARATION is compiled:
>   * `compileVariable` (`CompileType.cpp:340-435`) finds no
>     `component->getDataType(typeName)` and no `design->getClassDefinition`,
>     and falls to its FINAL arm — `ref_var` (`CompileType.cpp:421-431`);
>   * the `ts` it binds came from `compileTypespec`'s `slStringConst` arm,
>     which ends in `compileDatastructureTypespec`'s catch-all
>     (`CompileType.cpp:1051-1055`): an `unsupported_typespec` carrying
>     `VpiName(typeName)` and `populateCoreMembers(type, type, tps)` — the
>     WRITTEN NAME and the WRITTEN NAME'S SPAN;
>   * `needLateTypedefBinding` can NEVER repair it, because
>     `ElaborationStep::bindTypedefs_`'s `defs` vector
>     (`ElaborationStep.cpp:110-148`) is built from file contents, packages,
>     modules, programs and classes ONLY — a statement-scope typedef is in none
>     of them, so its name never enters the `specs` map that
>     `:305-320` swaps through.
>   * the placeholder's `vpiInstance` is `component->getUhdmInstance()`
>     (`CompileType.cpp:2135-2136`) — the HOME PACKAGE for a package free
>     subroutine and for an OUT-OF-BODY class method, NOTHING for an in-body
>     method and for every module home.
>
> **AND THE FIRST GATE, which is `component->getDataType`'s CHAIN and NOT
> lexical scoping.** `DesignComponent::getDataType` (`src/Design/DesignComponent.cpp:108`)
> walks the declaring component's PARENT SCOPES, so a same-named typedef in the
> class / package / module / `$unit` above the subroutine ANSWERS FIRST and the
> declaration resolves to IT — even though SystemVerilog scoping says the local
> typedef shadows it. A same-named CLASS answers through
> `design->getClassDefinition` (`CompileType.cpp:360-382`) and makes the
> declaration a `class_var`. A same-named MODULE answers NOTHING and the
> declaration still degrades.
>
> **AND THE SECOND GATE, THE REPAIR.** `ElaborationStep::bindTypedefs_` keys its
> repair map on the BARE typedef NAME (`specs.emplace(typd->getName(), ts)`,
> `ElaborationStep.cpp:217/240/276`) and the swap loop asks only
> `need == tps->VpiName()` (`:317`), over `defs` built from EVERY file content,
> package, module, program and class in the design. So a statement-scope
> typedef whose bare name is ALSO carried by ANY other typedef ANYWHERE is
> still a `ref_var` — but its placeholder is SWAPPED for that stranger's
> typespec, spanned at that stranger. Building the stranger's object is a
> different law with its own name race, so this one DECLINES the collision:
> the law fires only when the name occurs EXACTLY ONCE as a typedef in the
> whole design's syntax.

### 2.1 THE DECODE IS EXPERIMENTALLY CONFIRMED, NOT JUST READ

Five grid arms, both views, golden built by Surelog itself
(`-parse -nocache -nowritecache -noprecompiledcache -d coveruhdm [-elabuhdm]`),
every command echoed with its binary PATH into the arm's own `cmds.txt`:

| arm | what it settles | golden |
|---|---|---|
| **`g155_a_home.sv`** — ELEVEN homes | the law is home-INDEPENDENT | a `begin` in an in-body class method, an in-body method's body top level, a class TASK, an OUT-OF-BODY method's body level AND its nested `begin`, a package free function, a module `initial`, a module function, a module task, an `always_comb` named block, a `fork` arm, a `for` body, a `case` item and an `initial` inside a GENERATE block — **all thirteen degrade identically**; the same file's `hivePkgWidth` (package) and `RoostMember` (class) controls RESOLVE |
| **the `vpiInstance`** | it is `tsInst`, nothing new | `@Hive155` for the package free function `flock` and the OUT-OF-BODY `Roost155::perch` (body level and nested `begin` alike), **`<noinst>`** for the in-body method, the module function, the module task, the `initial`, the `fork` arm, the loop body and the `case` item |
| **`g155_b_form.sv`** — TWELVE declared-type forms | the target type is irrelevant | vector / `logic` / `int` / `string` / inline enum / packed struct / typedef-of-a-local-typedef / alias of a CLASS / alias of a TYPE PARAMETER / alias of a PACKAGE typedef, in a class method and in a module function — **all degrade**; package enum, package struct, package typedef-of-typedef, class typedef, class name, parameterised class name and `$unit` typedef controls **all RESOLVE** |
| **`g155_c_shape.sv`** — the SHAPE axis | declarators, initialisers, dims, nesting | 1, 2 and 3 declarators off one declaration, `= 5'd3` initialised and mixed, a PACKED dimension written at the use, and a use from a NESTED `begin` **all degrade**; the four DECLARATOR-ARRAY forms put the placeholder on the **ELEMENT** variable and leave the `array_var` / `array_typespec` untouched |
| **`g155_d_gate.sv`** — the GATE arm | the shadow rule, from four homes | a local typedef shadowing a PACKAGE / MODULE / `$unit` / CLASS name RESOLVES to the OUTER one; a typedef declared DIRECTLY in a GENERATE block RESOLVES (a generate block is not a statement scope); a use three `begin`s deep still degrades |
| **`g155_e_edge.sv`** — the EDGE arm | the class-name and module-name collisions | a local typedef named after a CLASS in the same package makes the declaration a **`class_var`** (`getClassDefinition`'s arm), a local typedef named after a MODULE still degrades; `const`, `automatic` and `static` locals degrade exactly like a plain one; the four declarator-array forms degrade in a MODULE TASK too |

`g155_d_gate`'s `oobBeadShadow` is the cell that made the gate honest: an
OUT-OF-BODY method is compiled in the PACKAGE, so a CLASS typedef of that name
is NOT in `getDataType`'s chain — golden gives `ref_var` **with the class
typedef's REPAIRED `bit_typespec`**, which is a DIFFERENT object from this
law's placeholder. The gate declines it rather than mint a plausible wrong one.

---

## 3. STATED GATE == CODE GATE

**STATED**, as ONE predicate (`stmtScopeTdName155`, `src/EmitHelpers.h`) asking
THREE questions and nowhere else:

1. **(1) SPELLING** — the declared type is a `NamedType` over ONE bare
   identifier (`IdentifierName`), or that same identifier carrying PACKED
   DIMENSIONS written at the use, which slang parses as one
   `IdentifierSelectName` (`g155_c_shape` `warpPacked`). A `Scope::td`
   spelling is § `classScopedTdDeclTsUnsupported11`'s and can never name a
   statement-scope typedef.
2. **(2) FIRST HIT IS A TYPEDEF IN A STATEMENT SCOPE** — walking outward from
   the declaration's own scope, the first scope holding that name must be a
   `StatementBlock` or a `Subroutine`, and the symbol must be a `TypeAlias`.
   Found anywhere else first (a generate block, a class, a package, `$unit`)
   means Surelog resolved it too.
3. **(3) THE SHADOW GATE** — continuing outward and SKIPPING further statement
   scopes (which are equally invisible to Surelog), no scope may hold a
   TYPE-LIKE symbol of that name: a type, a type parameter, a generic class
   definition or a forwarding typedef. A plain VALUE of the same name is none
   of `getDataType` / `getClassDefinition` / the `getParameters()`
   type-parameter arm, and is deliberately NOT a decline.
4. **(4) THE REPAIR GATE** — the name must occur EXACTLY ONCE as a typedef
   (forward typedefs included) across the whole design's SYNTAX. The count is
   taken in one syntax pass with no AST forcing and cached
   (`UhdmExporter::buildTdNameCount155`). **The WIDE BOUNDARY GATE convicted a
   first cut for not asking this**: `r10v98repro/v98_c20_dut.sv` and
   `v98_c26_dut.sv` each pit a method-local typedef against a same-named class
   typedef in another package, and golden binds THAT one's typespec
   (`int_typespec (mk20_t) @10:29-10:32`, `bit_typespec (wk26_t)
   @4:29-4:38`) under a `ref_var`. Both arms are byte-identical now.

**AND ONE STRUCTURAL RULE, not a question: questions (2)-(4) are asked ONLY
after a CHEAP PRE-GATE** that reads the declaration's own `DeclaredType` —
already resolved by every other law at these sites — and requires it to BE, or
to have as its element, a `TypeAliasType` of that very name whose home is a
statement scope. `Scope::find` FORCES a scope's members to elaborate, and
RESUME §9's Heisenbug warning is exactly that hazard; with the pre-gate the
lookup runs only for a declaration that genuinely names a statement-scope
typedef.

**SITES** — six, each applying the substitution to the BINDING and to the
variable's KIND, and to nothing else, so no variable's name, full name, span,
parent, `vpiAutomatic` or `vpiConstantVariable` moves:

* `src/TaskFuncEmit.cpp` 5730 / 5946 — SITE 1, the SUBROUTINE-BODY scalar
  local (kind + typespec).
* `src/StmtEmit.cpp` 2295 / 2384 — SITE 2, the BLOCK-ITEM scalar local
  (kind + typespec). **This is the corpus head's site.**
* `src/TaskFuncEmit.cpp` 1223 — SITE 3, the QUEUE / DYNAMIC-ARRAY element
  typespec.
* `src/TaskFuncEmit.cpp` 1489 — SITE 4, the ASSOCIATIVE element typespec.
* `src/TaskFuncEmit.cpp` 5361 — SITE 5, the FIXED-SIZE declarator array,
  tf-item form.
* `src/StmtEmit.cpp` 2208 — SITE 6, the FIXED-SIZE declarator array,
  BLOCK-item form.
* the ELEMENT VARIABLE's KIND for SITES 3-6 comes from ONE choke point,
  `declArrayElemVarKind12` (`src/EmitHelpers.h`), which now answers `RefVar`
  for this law before asking r10sd10's — the two predicates are MUTUALLY
  EXCLUSIVE (this one needs a typedef in a STATEMENT scope, r10sd10's one in a
  CLASS), so the order is documentation, not precedence.

**CODE** — `git diff 5b84cae --numstat`: `src/EmitHelpers.h` **+224/−3**,
`include/UhdmExporter.h` **+23/−0**, `src/TypeEmit.cpp` **+84/−0**,
`src/TaskFuncEmit.cpp` **+77/−6**, `src/StmtEmit.cpp` **+41/−2**. The eleven
deleted lines are the four `declArrayElemVarKind12` / `makeDeclArrayElemVar12`
call sites gaining one argument and the two ordering lines they sit on; **no
existing arm's ANSWER changed** — this law is only ever reached where all of
them declined.

### 3.1 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | fires on the corpus? | what proves it |
|---|---|---|
| (1) bare `IdentifierName` | **FIRES BOTH WAYS** | the corpus head accepts; every `Owner::td` corpus row rejects and is byte-unchanged |
| (1) `IdentifierSelectName` (packed dims at the use) | **UNEXERCISED on the corpus** | `g155_c_shape` `warpPacked` is its only coverage — and it is why this arm exists: without it that cell stayed `packed_array_var` while golden had `ref_var` |
| (2) first hit in a STATEMENT scope | **FIRES BOTH WAYS** | 11 grid homes accept; `g155_d_gate` `mintVal` (a GENERATE-block typedef) and every package/class/`$unit` control reject |
| (2) the hit must be a `TypeAlias` | **rejects on the grid** | `g155_b_form` `vTypeParamCtl` — a TYPE PARAMETER named directly — rejects |
| (3) SHADOW gate | **FIRES BOTH WAYS** | `g155_c_shape` `shadowPkgName`/`shadowClsName`, `g155_d_gate`'s six shadow cells and `g155_e_edge` `clashClassName` reject; `shadowNone` / `heddleOnly` / `tokenFresh` accept. On the CORPUS it is what keeps the 208 `uvm_*_cb_iter` / `uvm_cmdline_parsed_arg_t` / `m_verbosity_setting` cells still |
| SITES 3-6 (declarator arrays) | **UNEXERCISED on the corpus** | `g155_c_shape` warpFixed/warpQueue/warpDyn/warpAssoc and `g155_e_edge` tongs* are their only coverage, in a class method and a module task, both views. Stated rather than hidden: the corpus prediction found no array-of-statement-scope-typedef declaration in either corpus |
| the PACKED-ARRAY-OF-ENUM shape | **DECLINED, and named** | when the written type is a statement-scope typedef of an ENUM carrying packed dims, `makeEnumArrayVar` builds a `packed_array_var` FIRST and this law's kind arm is not reached, so the declaration is left exactly as it is today. Golden's answer for that shape was not measured, and the law declines rather than guess it |

---

## 4. THE MOVERS

### 4.1 PREDICTED FIRST, from the PRISTINE databases — `PREDICT.r10uvm155.txt`

`predsweep155.sh` censused **956 surelog** and **1358 uhdm2rtlil** databases on
BOTH sides with the pristine binary only, and bucketed every cell where the
declaration KIND disagrees and either side is a `ref_var`. Single-object cells:

```
TOWARD  38  unsupported_typespec (index)              -> class_var   FOREACH loop var
        14  array_typespec (types_t)                  -> array_var   class td of a queue of a type param
         9  enum_typespec (uvm_pkg::UVM_SEQ_ARB_TYPE) -> enum_var    OOB return, DEF view only
         2  unsupported_typespec (__tmp_int_t__)      -> bit_var     <-- THIS HEAD
AWAY     0                     uhdm2rtlil: TOWARD 0, AWAY 0
```

**PREDICTION, BY NAME:** `default/BuildUVMPkg-bf853d43` and
`testflags/BuildUVMPkg-bf853d43`, one cell each; nothing else in either corpus.

### 4.2 MEASURED — `byteverify.sh SELFCHECK=1`, both corpora

```
surelog     PATH_SETS_IDENTICAL (956)   MOVERS 3 / 956   SELFCHECK 955/956 flagged
              ./default/BuildUVMPkg-bf853d43/slang.uhdm     PREDICTED
              ./testflags/BuildUVMPkg-bf853d43/slang.uhdm   PREDICTED
              ./default/Scoreboard-59431470/slang.uhdm      THE COIN — see below
uhdm2rtlil  PATH_SETS_IDENTICAL (1358)  MOVERS 0 / 1358  SELFCHECK 1357/1358 flagged
```

**Scoreboard/default is the ~50/50 COIN and is attributed ORDER-BLIND**, as the
measurement laws require: both databases dumped with `uhdm-dump`, the dump's own
file-path header normalised, both sorted —
**0 differing lines out of 1,100,235**. It carries none of this law's content.

**BuildUVMPkg, path-normalised whole-dump diff: 9 lines, every one the law's:**

```
- \_bit_var:  (uvm_pkg::uvm_agent::build_phase::__tmp_int_val__), line:51340:36 …   (x2)
+ \_ref_var:  (…)
- \_bit_typespec: , line:51340:6, endln:51340:19                                     (x2)
+ \_unsupported_typespec: (__tmp_int_t__), line:51340:6, endln:51340:19
+   |vpiName:__tmp_int_t__
```

Both modes produce the SAME database (md5 `3ffbc2fa5459` patched,
`1044d58c3c02` pristine), as they did before.

### 4.3 THE FAMILY CENSUS — `CENSUS.r10uvm155.txt`

Calibrated golden-vs-golden FIRST (`shared=16563 same=16563 DIFF=0`). Over the
nine UVM databases, full payload (kind + typespec kind + name + vpiInstance +
span): **ONE cell moved, TOWARD golden; 0 WRONG, 0 AWAY.** Seven of the nine
databases have literally no cell of any kind moved.

### 4.4 THE GRID — `GRID.r10uvm155.txt`

```
a_home   pristine-DIFF=25  patched-DIFF=0   MOVED-TOWARD=25  MOVED-WRONG/AWAY=0
b_form   pristine-DIFF=18  patched-DIFF=6   MOVED-TOWARD=12  MOVED-WRONG/AWAY=0
c_shape  pristine-DIFF=19  patched-DIFF=2   MOVED-TOWARD=17  MOVED-WRONG/AWAY=0
d_gate   pristine-DIFF=16  patched-DIFF=11  MOVED-TOWARD=5   MOVED-WRONG/AWAY=0
e_edge   pristine-DIFF=15  patched-DIFF=1   MOVED-TOWARD=14  MOVED-WRONG/AWAY=0
-- TOTAL MOVED-TOWARD=73  MOVED-WRONG/AWAY=0
```

`a_home` reaches **0 differing cells** — every home the law names is now
golden-exact in both views. Every cell still differing is one the law
DECLINES, and each is byte-identical to the PRISTINE answer (listed in
`GRID.r10uvm155.txt`).

---

## 5. GATES — `GATES.r10uvm155.txt`

Every gate ran with `SLANG_UHDM` exported explicitly to the binary under test,
and every `cmds.txt` in both sweeps was audited BY PATH — 1523 references in
the pristine surelog sweep, all to `/tmp/r10uvm155_bin/pris.bin`, and 2981 in
the three patched sweeps, all to `/tmp/r10uvm155_bin/pat.bin`. No main-tree
binary reached any cell.

## 6. BOUNDARIES — `BOUNDARY.r10uvm155.txt`

`bound155.sh` over a COPY of the WHOLE `tools/probe` tree — top level AND
subdirectories, both views, both binaries:
**`LISTED=4381 PROCESSED=4381 PRODUCED_DBS=4234 MOVED_ARMS=11 RC_DIFFS=0`**,
and **78 cells TOWARD, 0 AWAY, 0 RESHAPE** over the eleven. Five of the eleven
are this pass's own grid arms — the positive control that proves the gate can
see. The other six each hold a typedef declared in a subroutine or a `begin`
and a declaration that names it: exactly this law's population.

Two of the eleven needed attribution and got it:

* **`r10v145repro/v145_h_param.sv`** — its two cells moved KIND and TYPESPEC
  onto golden's answer while the declaration's OWN SPAN stayed exactly where
  it was on both binaries (a pre-existing residue of a different law). The
  span-keyed reading calls that RESHAPE; `--nospan` calls it TOWARD. Both
  numbers are in `BOUNDARY.r10uvm155.txt`; neither is an AWAY.
* **`r10buvm22repro/g22.sv`** — MOVED IN BYTES, **0 CELLS**. slang REJECTS it
  on both binaries (rc=4/4); the whole-dump diff is three folded constants in
  an associative-dimension range for `typedef C22 ka_cls_t[string];`, differing
  by exactly one 4096-byte page; and the file contains no statement-scope
  typedef at all, so this law's predicate mints nothing in it. **The positive
  control that settles it:** a binary built from the PATCHED source plus one
  semantically dead externally linked function moved the same constants
  another +4096 with no semantic change whatsoever. The number is derived from
  the BINARY IMAGE's layout — its magnitude is the size of the binary itself —
  and moves for any binary.

## 7. RESIDUES AND R0

**R0 — the NEW BuildUVMPkg head, decoded from the same Surelog code path.**
The head is now the enclosing `begin` at `uvm_pkg.sv:51337:29`, printed with
`RHS: <null>`. Diffing golden's `begin` block against ours shows exactly what
is missing:

```
 |vpiName:__tmp_success_val__
-|vpiTypedef:
-\_bit_typespec: (__tmp_int_t__), line:51338:14, endln:51339:48
-|vpiName:__tmp_int_t__
-|vpiRange: \_range: … |vpiLeftRange: \_operation: (vpiOpType:11)
-  |vpiOperand: \_sys_func_call: ($bits) |vpiArgument:
-    \_ref_obj: (__tmp_int_t__.uvm_active_passive_enum) …
-  |vpiOperand: \_constant: UINT:1
-|vpiRightRange: \_constant: UINT:0
 |vpiStmt:
```

**Golden LISTS the block-local typedef on the enclosing `begin`'s
`Typespecs()` vector, and we list nothing there.** That is the OTHER half of
the very arm this pass decoded: `compileTypeDef`'s head
(`CompileHelper.cpp:509-517`) pushes the typespec onto
`any_cast<UHDM::scope*>(pstmt)->Typespecs()` *before* the `if (scope)` guards
skip every component registration. The `begin`'s `Typespecs` vector is a
compared field, so the size mismatch is the head. **R0: emit the STATEMENT-SCOPE
typedef listing on its enclosing `scope` — `begin` / `named_begin` / `fork` /
`function` / `task` — as Surelog's `compileTypeDef` does, with the `$bits`
range expression left symbolic.**

**RESIDUES this pass measured and deliberately did NOT move:**

* **the OUT-OF-BODY class-typedef declaration** (`g155_d_gate` `oobBeadPlain` /
  `oobBeadShadow`; on the corpus `uvm_sequencer_base::get_arbitration`'s
  return, 9 cells, DEF view only). Golden is `ref_var` + the class typedef's
  **REPAIRED** typespec, ours is the resolved kind. Same `compileVariable`
  arm, different question — and VIEW-DEPENDENT, because golden's ELABORATED
  copy is the resolved kind on both sides. A separate law.
* **`uvm_utils::find` / `find_all` `types`** (2 cells per UVM database):
  golden `ref_var` + `array_typespec (types_t)`, ours `array_var`. A CLASS
  typedef whose target is a TYPE PARAMETER has no typespec when
  `compileVariable` asks, so it takes the same final arm.
* **the FOREACH loop variable** (`index`, 38 cells; `sva_info`, `cover_info`,
  `arg`, `actions`, `a_lof_sva`): golden mints its own `ref_var` +
  `unsupported_typespec` at `CompileStmt.cpp:550`. A different factory and a
  different family.
* **the SHADOW cells' span and vpiInstance** (`g155_c_shape` `shadowPkgName`,
  `g155_d_gate` `modCarryShadow` / `modUnitShadow` / `ibBeadShadow` /
  `ibTallyShadow`): golden binds the OUTER typedef's typespec, spanned AT THAT
  TYPEDEF and carrying its package; we bind our own, spanned at the use. The
  KIND already agrees; only the identity of the bound object does not.
* **`clashClassName`** (`g155_e_edge`): a statement-scope typedef named after a
  CLASS makes the declaration a `class_var` in golden. Measured, declined,
  unchanged.
* **THE NAME-COLLISION REPAIR** (`r10v98repro/v98_c20_dut.sv`,
  `v98_c26_dut.sv`): a statement-scope typedef sharing its bare name with any
  other typedef in the design keeps `ref_var` in golden but binds THAT
  stranger's typespec, spanned at the stranger. Question (4) declines it.
  Modelling it needs the winner-selection race `bindTypedefs_`'s `defs` order
  implies — the same machinery § `classScopedTdDeclTsUnsupported11` built for
  its own claim table — and is a separate law.
* **the g22 associative-dimension constant** — a number folded out of the
  BINARY IMAGE's layout for `typedef C22 ka_cls_t[string];` on an arm slang
  rejects. It is a real emitter defect, it moves for every binary, and it is
  named here so the next pass's boundary gate can recognise it instead of
  re-attributing it.

## 8. HOW TO REPRODUCE

```bash
# one grid arm, both views, on two binaries
bash grid155.sh g155_a_home.sv <pristine> <patched> <workdir> <ct155cen>
python3 score155.py <workdir>/cen.g.txt <workdir>/cen.b.txt
bash scoreall155.sh <griddir-prefix> a_home b_form c_shape d_gate e_edge

# the a-priori prediction, from PRISTINE databases only
CEN=<ct155cen> JOIN=join155.py bash predsweep155.sh <pristine workdir> pred.tsv

# the family census
CEN=<ct155cen> bash scan155.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg
python3 join155.py <outdir>/BuildUVMPkg.default.g.tsv <outdir>/BuildUVMPkg.default.o.tsv --only-diff --set --cols VK

# build ct155cen
g++ -O2 -std=c++17 ct155cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct155cen
```
