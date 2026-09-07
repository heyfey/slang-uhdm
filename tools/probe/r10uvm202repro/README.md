# r10uvm202 — § `pkgClassTdImportCopyLocalUnsupported202` — **A WILDCARD-IMPORT CLONE'S BODY LOCAL OF A PACKAGE-SCOPE TYPEDEF *OF A CLASS* KEEPS THE PRE-REPAIR PLACEHOLDER** — the SeqDriver ×2 and MiniAmiq ×2 50-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own `FENCED=`
line, which `predict202.sh` reads at run time so this pass's artifacts never
spell them.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `5fda78a4` |
| pristine binary | md5 `caca35d885582f80ccfbdb01bf59d0a4`, built from this pass's OWN worktree at a clean `5fda78a4` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `02bc6ff4645cedb738c8ee1acfe67f16`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` (the law, its Surelog decode, its fence and the predicate `pkgClassTdLocalName202`), `src/TaskFuncEmit.cpp` (SITE 1 of 2, the subroutine-body local), `src/StmtEmit.cpp` (SITE 2 of 2, the block-item local, where the corpus head lives). **+129 / −0 lines, three files, no new exporter state, no new flag, no object re-pointed.** |
| probe surface | `tools/probe/r10uvm202repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default and testflags, 50 cmp lines, ONE head each → 29**; **MiniAmiq default and testflags, 50 → 29**. ONE object in all four row-modes before (§ 1) and a DIFFERENT object of a DIFFERENT family after (§ 8). A cmp line count is the HEAD OBJECT'S decompile size (RESUME.md §7). |
| every other row's head | cmp log **BYTE-IDENTICAL** between the two binaries — SimpleUVM ×2 17, Scoreboard/default 95, BuildUVMPkg ×2 **0**, Earlgrey_0_1 833 / **0**, Rggen/default **0**. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against **this pass's own pristine sweeps** (1588 surelog rows, 731 + 731 uhdm2rtlil rows). Against the committed baseline exactly one row-SIDE differs, `Earlgrey_0_1,testflags` `CMP_EQUAL/differ` → `CMP_EQUAL/`, and this pass's own PRISTINE sweep reads it the same way: a uhdm-dump TIMEOUT under sweep load, not a model change. **NO ROW WAS CONVERTED.** |
| byte movers | **5 / 956** surelog — the FOUR the prediction named BY NAME from the pristine databases alone, plus Scoreboard/default, the ~50/50 COIN, whose ORDER-BLIND dump diff is **0 content lines**. **0 / 1358** uhdm2rtlil. |
| the attribution | each of the four law rows: uhdm-dump ORDER-BLIND diff **242 lines, +201 / −41**, and every line is a `class_typespec (uvm_pkg::uvm_*_cb_iter)` replaced by an `unsupported_typespec (uvm_*_cb_iter)` carrying `vpiInstance -> package uvm_pkg`. Nothing else moves. |
| the corpus population | **28 keys per moved row-mode** — 8 TF-ITEM sites and 20 BLOCK-ITEM sites, every one a `cbs` iterator local in the importing package's clone, covering **five** of the seven `uvm_callback_iter#(...)` package typedefs. |
| the census (11 row-modes, golden-vs-golden calibrated FIRST on every one) | SeqDriver ×2 **TO-GOLDEN 28**, MiniAmiq ×2 **TO-GOLDEN 28**, **AWAY-GOLDEN 0, MOVED-WRONG 0** on both. SimpleUVM ×2, Scoreboard/default, **BuildUVMPkg ×2**, **Earlgrey_0_1 ×2**, **Rggen/default**: every mover column **0**. |
| the grid (5 arms × 2 views, one REAL Surelog golden each) | **TO-GOLDEN 60 total, AWAY-GOLDEN 0, MOVED-WRONG 0** in every arm in every view; 0 nonzero rcs. Arms A and E go **CMP_EQUAL in BOTH views** on the patched binary (36 cmp lines / one head → 0 / 0). |
| the a-priori prediction | `strict` non-zero on **exactly four row-modes over 948 scanned surelog databases** — `SeqDriver` ×2 and `MiniAmiq` ×2 — and on **none of the 1358** uhdm2rtlil ones, where the law's WIDE bound is **empty outright**. |
| the WIDE boundary (5276 arms, both views, both binaries) | `LISTED=5276 PROCESSED=5276 PRODUCED_DBS=5091`, **RC_DIFFS 0, MOVED_ARMS 6** — five are this pass's OWN grid arms (the positive control) and the sixth, `r10buvm9repro/w4v_imports.sv`, rebuilt against its OWN real Surelog golden, scores **TO-GOLDEN 1 / AWAY-GOLDEN 0 / MOVED-WRONG 0** in both views. |
| the protected rows | BuildUVMPkg ×2, Earlgrey_0_1/testflags and Rggen/default stay **CMP_EQUAL** with rowheads 0 lines / 0 heads and byte-identical databases; SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a` PINS HELD; InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical. |
| goldens | 23 PASS / 0 FAIL on both binaries; `/bin/false` 23 FAIL (the negative control). |
| what the brief got wrong | **BOTH halves of its framing.** The head is not about SPECIALISATIONS (a PLAIN class-handle typedef degrades identically — § 3), and the "specialisation SHARING" is not a second defect at all: golden shares and renames exactly as we do, span for span and alias for alias (§ 5). **ONE defect, not two.** |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `5fda78a4` worktree; it
came out **byte-identical** to the main tree's binary at that commit
(`caca35d8…`). Its 956-row surelog sweep and both 731-row uhdm2rtlil sweeps
reproduce the committed baselines row for row (the one informational
dump-column cell in `GATES.r10uvm202.txt` §4 excepted, which the pristine sweep
shows too), and `check_goldens.sh` reads 23 PASS / 0 FAIL with the `/bin/false`
negative control at 23 FAIL, before a line of code was written.

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         50      1
SeqDriver      testflags       50      1
MiniAmiq       default         50      1
MiniAmiq       testflags       50      1
```

and all four are the same object pair (`head_pris_*.cmp`; MiniAmiq's two modes
are byte-identical, SeqDriver's two differ only in the testbench's own path):

```
LHS: unsupported_typespec: (uvm_reg_field_cb_iter), line:1128:10, endln:1128:31
     |vpiParent: \_ref_typespec: (adpcm_pkg::uvm_reg_field::do_predict::cbs)
     |vpiName:uvm_reg_field_cb_iter
     |vpiInstance: \_package: uvm_pkg
RHS: class_typespec: (uvm_pkg::uvm_reg_field_cb_iter), line:334:9, endln:334:26
     |vpiName:uvm_pkg::uvm_reg_field_cb_iter
     |vpiTypedefAlias: \_ref_typespec -> class_typespec (uvm_pkg::uvm_mem_cb_iter)
     |vpiInstance: \_package: adpcm_pkg
     |vpiClassDefn: \_class_defn: (uvm_pkg::uvm_callback_iter)
```

uvm-1.2 `reg/uvm_reg_field.svh:1128` is `uvm_reg_field_cb_iter cbs = new(this);`
— a BLOCK-ITEM local of the `begin` of the `UVM_PREDICT_WRITE` case item of the
OUT-OF-BODY method `uvm_reg_field::do_predict` — read in the WILDCARD-IMPORT
CLONE that `adpcm_pkg` (SeqDriver) / `svaunit_pkg` (MiniAmiq) holds. Its type is
`reg/uvm_reg_cbs.svh:354`,
`typedef uvm_callback_iter#(uvm_reg_field, uvm_reg_cbs) uvm_reg_field_cb_iter;`
— a **PACKAGE-SCOPE** typedef.

## 2. DECODING THE JUDGE — `ct202own`

`ct202own.cpp` links the SAME generated `Compare` the judge does.
`DECODE.r10uvm202.txt` §1 carries the runs in full.

**THE FAILING FIELD is the KIND.** Both sides are present, so
`BaseClass::Compare`'s `VpiType` line fails before `VpiName` (which disagrees
too) and before `Instance` (which also disagrees).

**THE OWNER.** Golden's head has exactly ONE referrer and it is the edge the
judge walked:

```
REF .Actual_typespec  rel1  ref_typespec#213192
     < begin() < begin() < function(uvm_reg_field::do_predict) < package(adpcm_pkg)
```

**THE MINT.** Golden holds **16** `unsupported_typespec(uvm_reg_field_cb_iter)`
— **one per declaration**, `refs=1` each, every one instanced at
`package uvm_pkg` (the HOME) and every one under `package(adpcm_pkg)` (the
CLONE): eight declarations × two views. Golden's HOME listings and its
`class_defn` listings hold NONE. Ours holds **1** shared `class_typespec` with
**42** referrers: ten `Typespecs` listing slots, **sixteen declaration bindings
under `package(adpcm_pkg)`** — the cells this law rewrites — and sixteen under
`package(uvm_pkg)` and its `class_defn`s, **which must not move** (the census
scores them).

**THE ABLATION.** Masking the golden head alone moves the judge to
`class_var(uvm_pkg::uvm_reg_field::do_predict::cb)@1135:27` with `RHS: <null>` —
a different family (§ 8, R0). This object was the whole head.

## 3. THE BRIEF'S FIRST FRAMING, REFUTED — IT IS NOT THE SPECIALISATION

Grid arm A `g202_a_kinds` puts **seven package-scope typedefs side by side and
uses them side by side in the SAME cloned body, at BOTH sites**, against ONE
real Surelog golden, in BOTH views. Golden's clone listing:

| written type | golden, in the CLONE | ours (pristine) | |
|---|---|---|---|
| `Vein202#(int,string)` | `unsupported_typespec pkgSpec202` @`quarry202` | `class_typespec` | **FIRES** |
| `Vein202#(string,int)` | `unsupported_typespec pkgSpecB202` @`quarry202` | `class_typespec` | **FIRES** |
| `Plain202` — a PLAIN handle | `unsupported_typespec pkgCls202` @`quarry202` | `class_typespec` | **FIRES** |
| `struct` | `struct_typespec` RESOLVED | same | — |
| `enum` | `enum_typespec` RESOLVED | same | — |
| `logic [7:0]` | `logic_typespec` RESOLVED | same | — |
| `int` | `int_typespec` RESOLVED | same | — |

`pkgCls202` is the refutation: **a plain class-handle typedef degrades exactly
like a specialisation.** The distinguisher is the typedef's TARGET BEING A
CLASS. And in every OTHER listing of that same golden — the HOME package's own
def and elab, and the `class_defn` listings of both packages — golden keeps the
RESOLVED `class_typespec` for all three class cells: **only the listing directly
under the IMPORTING package degrades.**

The four plain-typedef controls are `uvm170`'s must-not-move family and
§ 198's own `tfPkg198` control restated, and they are what stops this law from
degrading every clone local.

## 4. DECODING SURELOG — WHY A CLASS TYPEDEF FILES A LATE BINDING AND A STRUCT DOES NOT

§ `classScopedTdImportCopyLocalUnsupported198`'s three sites, unchanged, with
the FIRST reached for a different reason (citations in full in
`DECODE.r10uvm202.txt` §2 and in `src/EmitHelpers.h`):

1. **The home body degrades FIRST.** `compileDatastructureTypespec` walks the
   DataType chain (`CompileType.cpp:852-861`): a `TypeDef` contributes
   `parent_tpd->getTypespec()` and BREAKS only if that typespec already exists.
   A struct / enum / union / SimpleType typedef has one by then (`:860-897`); a
   typedef whose target is a CLASS does not, and the walk has to reach the
   `ClassDefinition` arm (`:902-905`). When it cannot, `result` stays null and
   the named-type arm mints the placeholder — `CompileType.cpp:1617-1626`,
   `unsupported_typespec` with `VpiName(typeName)` (the **WRITTEN** name) and
   `populateCoreMembers(type, type, ref)` (the **WRITTEN TYPE TOKEN's** span).
   That is golden's object field for field.
2. **The declaration is FILED for late repair.** `CompileType.cpp:421-431`
   (`if (ts->UhdmType() == uhdmunsupported_typespec)
   component->needLateTypedefBinding(ref);`) and, for the block-item form,
   `CompileStmt.cpp:1799-1806`. That is why golden's variable is a `ref_var` in
   the HOME as well as in the clone (arm A, every class cell).
3. **The importer COPIES at collect time.** `CompilePackage.cpp:141-151` →
   `CompileHelper::importPackage` (`CompileHelper.cpp:299-324`) `clone_tree`s
   each imported task_func **when the importer is a PACKAGE**; the copy carries
   a COPY of the placeholder, `vpiInstance` included.
4. **The repair is POINTER-KEYED and cannot reach the copy.**
   `ElaborationStep::bindTypedefs_` records
   `getSwapedObjects().emplace(orig_ut, tps)` keyed on the ORIGINAL placeholder
   OBJECT (`ElaborationStep.cpp:302-321`), and `swapTypespecPointersInUhdm`
   rewrites every `expr`'s `Typespec`. The clone's `ref_typespec` points at its
   own copied object, which is not a key in that map.

**Unlike § 200, the ELAB view does not undo it.**
`ElaboratorListener::leaveRef_obj` re-binds dangling `ref_obj`s, but nothing
re-resolves a `ref_typespec`'s `Actual_typespec` — so this law's cells read the
same in both views, and arms A, C and E score identically in `def` and `elab`.

## 5. THE BRIEF'S SECOND FRAMING, REFUTED — THE SPECIALISATION SHARING IS GOLDEN'S OWN

The brief calls our object *"a resolved `class_typespec` spanned at the WRONG
typedef with the alias chaining to the wrong object"* and asks for the
specialisation SHARING as a second, independent defect. It is not one.
`ct202cen`'s `CLS|` rows put both sides of the corpus row side by side:

```
golden  111 package-qualified class_typespec rows
ours    111 package-qualified class_typespec rows
DIFF    ONE row, and it is an OWNSPAN flag on `adpcm_pkg::this_type` — a span
        heuristic of this census, and `typespec::Compare` reads no span at all
```

and for the head's own family, **both sides identical, base included**:

```
uvm_mem_cb_iter         ALIAS=-                     span uvm_reg_cbs.svh:334:9-334:26
uvm_reg_bd_cb_iter      ALIAS=-> uvm_mem_cb_iter    span uvm_reg_cbs.svh:334:9-334:26
uvm_reg_cb_iter         ALIAS=-> uvm_mem_cb_iter    span uvm_reg_cbs.svh:334:9-334:26
uvm_reg_field_cb_iter   ALIAS=-> uvm_mem_cb_iter    span uvm_reg_cbs.svh:334:9-334:26
uvm_report_cb_iter      ALIAS=-> uvm_mem_cb_iter    span uvm_reg_cbs.svh:334:9-334:26
uvm_vreg_cb_iter        ALIAS=-> uvm_mem_cb_iter    span uvm_reg_cbs.svh:334:9-334:26
uvm_vreg_field_cb_iter  ALIAS=-> uvm_mem_cb_iter    span uvm_reg_cbs.svh:334:9-334:26
```

Surelog itself mints ONE object per GENERIC class, spans every typedef of the
group at the NAME-FIRST member's own typedef line and chains the rest to it
with `vpiTypedefAlias` — which is exactly what
`src/ParamEmit.cpp:22661-22702` and § `pkgImportClassTdClone50` (`:22703-22740`)
already model. Grid arm A shows the same thing in a source of a few hundred
objects: golden's `pkgSpecB202` carries `ALIAS=class_typespec quarry202::pkgSpec202`
and the base's span. **The span is not judge-visible at all**
(`typespec::Compare` reads `VpiType` / `VpiName` / `Typedef_alias` / `Instance`,
never `VpiFile` or a span — RESUME.md §9). **ONE defect, and it is the degrade.**

## 6. DECODING SLANG — ONE PREDICATE, TWO SITES, THE SAME GATE § 198 USES

`src/EmitHelpers.h`'s `pkgClassTdLocalName202` is the predicate and the NAME:
the declared type must be a `TypeAlias` whose **parent scope is a Package** and
whose **canonical target is a `ClassType`**; the spelling must be scalar (THE
ARRAY FENCE — an array local's placeholder lives on the ELEMENT `ref_var`, which
is neither of these sites, the same fence § 198 and
§ `oobClassTypeParamLocalUnsupported105` state); and the name is the WRITTEN
BARE identifier. A SCOPED spelling is DECLINED rather than guessed at (arm B,
R1). § 198's predicate requires the parent scope to be a `ClassType` /
`GenericClassDef`, so **the two are disjoint by construction** and this one sits
after it in the chain.

The two call sites are the two the corpus and the grid need:

* `src/TaskFuncEmit.cpp` — the SUBROUTINE-BODY local (8 of the corpus's 28 keys),
* `src/StmtEmit.cpp` — the BLOCK-ITEM local (20 keys), where the corpus head lives.

Both are LAST in their site's placeholder chain, after
§ `builtinClassLocalUnsupportedBeforeClassPhase115`,
§ `oobClassTypeParamLocalUnsupported105`,
§ `blockLocalTdDeclIsRefVarUnsupported155`, § `classScopedTdDeclTsUnsupported11`
and § `classScopedTdImportCopyLocalUnsupported198`.

**The gate is § 198's, verbatim: `importCopyTsInst && pkgClassTfClone`** —
§ `clsScopedTdLocalCloneIsClassMethodOnly198v`'s conjunct, which names the
imported OUT-OF-BODY CLASS METHOD clone and excludes the two free-subroutine
clone drivers. Arm D measures why that conjunct is load-bearing here too: the
free-subroutine clone hands ONE typespec object to the package listing AND to
the home listing (visible in the arm's own pristine cells as a two-element
multiset on one key), so firing there would move the home cell AWAY from golden.
Declining it costs the arm's `dFree202d` cells and buys **AWAY-GOLDEN 0**
everywhere; the free-subroutine half stays R3, unmoved on both binaries.

Only the KIND, the NAME and the INSTANCE move; the variable's own class, span,
parent, full name and `vpiAutomatic` stay exactly where the surrounding laws put
them — golden's clone cell is the very `ref_var` we already emit.

## 7. THE GRID — five arms, one real Surelog golden each, both views

`GRIDS.r10uvm202.txt` carries the scored runs; every arm is scored with
`ct202cen` + `score202.py` over JUDGE-VISIBLE payload only (the declaration
typespec's kind, name, instance and typedef-alias — the fields
`typespec::Compare` reads; spans ride DUMP-ONLY `SPAN|` rows the scorer drops).

| arm | what it DECIDES | def | elab |
|---|---|---|---|
| A `g202_a_kinds` | WHICH KIND: specialisation, a SECOND specialisation of the same generic, a PLAIN class handle, and struct / enum / packed-vector / int controls in the same cloned body, at both sites | TO-GOLDEN 9, AWAY 0, WRONG 0 | 9 / 0 / 0 |
| B `g202_b_spellings` | THE SPELLING: bare, SCOPED (`quarry202b::…`), a THIRD package's typedef both qualified and bare, the ARRAY spelling, a class handle written with NO typedef, and a plain package typedef | 6 / 0 / 0 | 6 / 0 / 0 |
| C `g202_c_sites` | THE SITE: tf item, tf item WITH AN INITIALISER (the corpus head's own shape), plain `begin`, NAMED begin, loop body, `if` arm, CASE ITEM, `fork` arm, plus § 36's FORMAL as a must-stay | 10 / 0 / 0 | 10 / 0 / 0 |
| D `g202_d_drivers` | WHICH CLONE DRIVER and WHICH IMPORTER: wildcard vs EXPLICIT-item import, a package FREE SUBROUTINE, an IN-BODY method, and MODULE / INTERFACE / PROGRAM importers | 3 / 0 / 0 | 3 / 0 / 0 |
| E `g202_e_head` | the corpus head MINIMISED — the POSITIVE CONTROL | 2 / 0 / 0 | 2 / 0 / 0 |

**AWAY-GOLDEN 0 and MOVED-WRONG 0 on every arm in every view**, and **arms A
and E go CMP_EQUAL in BOTH views on the patched binary** (36 cmp lines with one
head → 0 / 0). Arm E reproduces the corpus head's exact SHAPE — golden's
`unsupported_typespec` at the WRITTEN type name against our resolved
`class_typespec` borrowing the group base's span — in a source of a few hundred
objects rather than SeqDriver's ~293 000, and clears it.

What the arms establish about the law's shape, **measured rather than assumed**:

* **TARGET-KEYED, not specialisation-keyed** — a plain class handle degrades
  exactly like a `#(...)` specialisation (arm A `pkgCls202`).
* **KIND-FENCED** — struct, enum, packed vector and int stay resolved in the
  very same cloned body (arm A, 8 control cells, both views).
* **TYPEDEF-KEYED** — a class handle written WITHOUT a typedef is not degraded
  by golden either: an UNNAMED `class_typespec` with no instance, in the clone
  as in the home, identical on both binaries (arm B `bNoTd202b` / `kNoTd202b`).
* **SITE-BLIND inside the clone** — all eight sites of arm C behave alike, the
  initialised tf item included; the FORMAL is § 36's and does not move (R2).
* **SCOPE-KEYED** — only the listing DIRECTLY under the importing package
  degrades; the home's def/elab and both packages' `class_defn` listings keep the
  resolved object (arm A, every view).
* **IMPORTER- AND DRIVER-KEYED** — the wildcard-import class-method clone only
  (arm D); module / interface / program importers SHARE the home subroutine and
  do not move.
* **THE INSTANCE IS THE CLONED METHOD'S HOME PACKAGE, NOT THE TYPEDEF'S** — arm
  B `bThirdB202b` writes a typedef declared in a THIRD package `third202` and
  golden stamps `quarry202b`, the home of the cloned method. Our patch writes
  the same pointer because it is `importCopyTsInst`.

## 8. THE PREDICTION, THE MOVERS AND THE NEW HEAD

`PREDICT.surelog.r10uvm202.txt` and `PREDICT.u2r.r10uvm202.txt` were written by
`predict202.sh` + `ct202pred` from the **PRISTINE** sweep workdirs alone, before
the patched sweep was read. The criterion is the one the emitter rewrites,
expressed in the database the emitter produced: a VARIABLE listed by a
subroutine (or one of its blocks) whose subroutine NAME carries `::` and whose
subroutine's own `vpiParent` is a PACKAGE `P`, bound to a `class_typespec` that
is not already a placeholder and whose `vpiClassDefn` lives under a DIFFERENT
package `Q != P`.

```
surelog     scanned=948 NODB=617 FENCED=8
  PREDCELLS MiniAmiq,default   strict=1616   PREDCELLS MiniAmiq,testflags  strict=1616
  PREDCELLS SeqDriver,default  strict=1616   PREDCELLS SeqDriver,testflags strict=1616
  every other row strict=0 — including SimpleUVM ×2 (wide=1796), Scoreboard
  (wide=1816) and BuildUVMPkg ×2 (wide=1836), which DO hold clone-body locals
  and none typed by another package's class typedef
uhdm2rtlil  scanned=1358 NODB=104 FENCED=0
  no row, and the WIDE bound is EMPTY over the whole corpus
```

The criterion OVER-covers on purpose — it cannot see from the database whether a
declaration was written with a TYPEDEF or with the class name itself, and the
emitter fires only on the typedef — so it can NAME a row that does not move but
can never MISS one that does. The patched sweep moved **exactly those four
rows**, plus Scoreboard/default, the coin, whose ORDER-BLIND dump diff is **0
content lines** (146 plain lines, the known `svunit_pkg` `vpiTaskFunc` order
flip). `MOVERS.r10uvm202.txt` carries the shapes: each law row is +201 / −41
lines, PLAIN == ORDER-BLIND, every line naming this law. SeqDriver/testflags's
PLAIN diff is 318 and its ORDER-BLIND diff is 242 with the SAME shape as the
other three — the extra 76 lines are pure serialisation ORDER, which is why the
order-blind reading is the arbiter (RESUME.md §9).

**R0 — THE NEXT HEAD, and it is a different object of a different family.**
SeqDriver ×2 and MiniAmiq ×2 now read **29 cmp lines, one head**, byte-identical
across each test's two modes and identical between the two tests once object ids
are stripped:

```
LHS: class_var: (uvm_pkg::uvm_reg_field::do_predict::cb), line:1135:27, endln:1135:29
     |vpiParent: \_assignment: , line:1135:15, endln:1135:43
     |vpiTypespec: \_ref_typespec -> class_typespec (unnamed) @1135:15-1135:26
     |vpiName:cb   |vpiFullName:uvm_pkg::uvm_reg_field::do_predict::cb
RHS: <null>
```

uvm-1.2 `reg/uvm_reg_field.svh:1135` is
`for (uvm_reg_cbs cb = cbs.first(); cb != null; cb = cbs.next())` — **the
FOR-LOOP INITIALISATION's own declared variable**, which golden lists (parented
at the loop's `assignment`, with an UNNAMED `class_typespec` spanning the written
type) and we do not list at all. `RHS: <null>` is the SINGULAR `SafeCompare`
overload's `rhs == nullptr` branch, so the FIELD is the container that holds
that `class_var`, not the variable's own payload (RESUME.md §9) — start by
finding which vector/edge golden reaches it through, with `ct202own --refs` on
the PATCHED pair, and note that the object lives in the **HOME** `uvm_pkg`
listing, not in a clone: this is not a clone law.

## 9. RESIDUES

* **R1 — the SCOPED spelling.** `quarry202b::pkgSpec202b` and
  `third202::thirdCls202` written in a clone body: golden emits a **`class_var`**
  (not a `ref_var`) bound to `unsupported_typespec` carrying the FULL written
  spelling. The VAR KIND is the first difference, so it is not this law's site
  at all; the predicate DECLINES the spelling rather than guessing at it (arm B,
  4 keys/view). Unmoved on both binaries.
* **R2 — the FORMAL.** § `classScopedTdImportCopyUnsupported36`'s own site: a
  clone's `io_decl` typed by a package-scope class typedef stays resolved where
  golden degrades it (arm C, 1 key/view; arm A has no formal). An `io_decl` is
  neither of this law's two sites. Unmoved.
* **R3 — the FREE-SUBROUTINE clone.** Golden degrades a package FREE
  subroutine's clone-body local the same way, and the `pkgClassTfClone` conjunct
  declines it — because that driver SHARES one typespec object between the
  package listing and the home listing, so firing there moves the home cell AWAY
  (arm D `dFree202d`, both importers, both views). Closing it needs the sharing
  split first. This is § 198's own residue restated, and it is what buys
  AWAY-GOLDEN 0. Unmoved.
* **R4 — the ARRAY FENCE.** `pkgSpec202b bArr202b[4]` keeps its placeholder on
  the ELEMENT `ref_var`, which is neither site; golden binds
  `unsupported_typespec pkgSpec202b` there and we bind a `logic_typespec` (def) /
  `class_typespec` (block). Closing it is an ELEMENT-site law (arm B, 2
  keys/view). Unmoved.
* **R5 — the clone's PLAIN-package-typedef INSTANCE.** A struct or enum local in
  a clone takes the IMPORTING package as its typespec instance where golden takes
  the HOME (arm A `blkSt202` / `blkEn202`). The KIND and the NAME already agree;
  this is § 198's R2, an instance-stamp law one construct over, and it is not
  judge-reachable in arm A (the arm is CMP_EQUAL on the patched binary).
  Unmoved.
* **R6 — listing ARITY.** Several unrelated declarations are listed ONCE by
  golden and TWICE by us in the elab view (arm E's `f202e`, `kind202e`, and the
  built-in `mailbox` / `semaphore` io_decls). A multiplicity family, orthogonal
  to this law. Unmoved.

## 10. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm202repro
g++ -O2 -std=c++17 ct202cen.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct202cen
g++ -O2 -std=c++17 ct202pred.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct202pred
g++ -O2 -std=c++17 ct202own.cpp  -I ~/.local/include -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct202own

# the judge decode, on the head's own row
/tmp/ct202own <golden.uhdm> <ours.uhdm> --refs --mint
#   (--cls and --locals are O(N^2) in the referrer index and are meant for the
#    grid arms; on a ~293k-object corpus database use ct202cen's CLS| rows)
/tmp/ct202cen <golden.uhdm> g | grep '^CLS|'      # the specialisation-sharing question
/tmp/ct202cen <ours.uhdm>   a | grep '^CLS|'

# the grid (one real Surelog golden per arm, both views, both binaries)
for a in grid202/g202_*.sv; do CEN=/tmp/ct202cen bash grid202.sh "$a" <PRISTINE> <PATCHED> /tmp/w_$(basename $a .sv); done
python3 score202.py /tmp/w_g202_a_kinds/cen.g.def.txt /tmp/w_g202_a_kinds/cen.a.def.txt /tmp/w_g202_a_kinds/cen.b.def.txt --show

# the a-priori prediction, from a completed PRISTINE sweep workdir
PRED=/tmp/ct202pred bash predict202.sh <pristine workdir> /tmp/pred.txt

# the corpus census over the UVM row-modes (golden-vs-golden calibrated first)
CEN=/tmp/ct202cen bash cen202.sh <pristine workdir> <patched workdir> /tmp/cen

# the mover attribution (order-blind; Scoreboard/default is a coin)
bash attrib202.sh <pristine wd> <patched wd> /tmp/attrib '^(SeqDriver|MiniAmiq|Scoreboard)$'

# the wide boundary
PRIS=<PRISTINE> PATCHED=<PATCHED> bash bound202.sh <a COPY of tools/probe> /tmp/bnd

# the canary audit
bash canaudit.sh canaries.sh ctcan2.sh
```
