# r10uvm115 — § `builtinClassLocalUnsupportedBeforeClassPhase115` — **SURELOG REGISTERS ITS BUILTIN `process` / `semaphore` / `mailbox` CLASSES *AFTER* PACKAGES AND MODULES ARE COMPILED, SO EVERY SUBROUTINE-BODY AND BLOCK-ITEM DECLARATION TYPED BY ONE DEGRADES TO `ref_var` + `unsupported_typespec`** — the SimpleUVM ×2 / Scoreboard-default **56-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `8a4b59a` |
| worktree | `/tmp/wt_r10uvm115` |
| pristine binary | reproduced the main tree's `build/slang-uhdm` at `8a4b59a` BYTE FOR BYTE (md5 `61228316cb53458c749fc64dec6df028`) — frozen `chmod 555` before any sweep |
| patched binary | md5 `22a4739a000c9e1ec68f2a3c1cad4fc0`, frozen `chmod 555` |
| production surface | `include/UhdmExporter.h` (the law + one predicate declaration), `src/UhdmExporter.cpp` (the predicate, 24 lines), `src/TaskFuncEmit.cpp` (SITE 1, the subroutine-body local), `src/StmtEmit.cpp` (SITE 2, the block-item local) |
| probe surface | `tools/probe/r10uvm115repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **56** | **17** | 1 (a NEW head, a different object) |
| **Scoreboard default** | **56** | **60** | 1 (a NEW head, a different object and a different FAMILY) |
| SeqDriver default / testflags | 62 | 62 | 1 unchanged, head log BYTE-IDENTICAL |
| MiniAmiq default / testflags | 62 | 62 | 1 unchanged, head log BYTE-IDENTICAL |
| BuildUVMPkg default / testflags | 47 | 47 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 36 | 36 | 1 unchanged, head log BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes; CMP_NOTEQUAL stays 19) | |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine PREDICTED BY NAME | |
| the family census | 140 differing cells (108 real + 32 listing artefacts) | **32** — the SAME 32 artefacts, **0 real cells left**, **0 MIRROR** | |
| direction, all 9 movers | — | **1644 identity lines moved, 1644 TOWARD GOLDEN, 0 AWAY** | |

`head_pris_default_SimpleUVM.cmp` is the whole 56-line head the brief named;
`head_pat_default_SimpleUVM.cmp` (17 lines) and
`head_pat_default_Scoreboard.cmp` (60 lines) are the two NEW ones — **different
objects**, see §7.

## 1. THE HEAD, CONFIRMED FROM THE CMP LOG AND `BaseClass.h` FIRST

The 56-line head, the decisive lines from the pristine cmp log
(`head_pris_default_SimpleUVM.cmp`):

```
LHS  ref_var:   (uvm_pkg::uvm_process_report_message::p)  @262:11-262:12
       |vpiParent:  \_begin: (uvm_pkg::uvm_process_report_message) @261:3-261:24
       |vpiTypespec: \_ref_typespec: … |vpiActual:
                       \_unsupported_typespec: (process) @262:3-262:10
RHS  class_var: (uvm_pkg::uvm_process_report_message::p)  @262:11-262:12
       … |vpiActual: \_class_typespec: (process) @262:3-262:10
```

**THE FIELD IS `VpiType`, on the DECLARATION ITSELF.** Both sides print in
full, which is `BaseClass::Compare`'s **first** test — the arm that sets
`m_failedLhs` **and** `m_failedRhs` (`~/.local/include/uhdm/BaseClass.h`).
Everything under it — the name `p`, the full name, the span, the parent — is
already identical on both sides and is the payload the law must not disturb.
The carrier is the `begin`'s `Variables()` vector: same size, differing
element.

Source: `uvm-1.2 base/uvm_globals.svh`

```systemverilog
function void uvm_process_report_message(uvm_report_message report_message);  // :259
  uvm_root top;                                                               // :260
  uvm_coreservice_t cs;                                                       // :261
  process p;                                                                  // :262  <- THE HEAD
  p = process::self();                                                        // :263
```

## 2. THE LAW

> **§ `builtinClassLocalUnsupportedBeforeClassPhase115`** — *Surelog parses its
> builtin `mailbox` / `process` / `semaphore` classes out of an in-memory
> `builtin.sv` and registers them in the DESIGN's class map under their SIMPLE
> names (`Builtin::addBuiltinClasses`, `Builtin.cpp:291-395`) — but only
> **AFTER** packages, modules and programs are compiled
> (`CompileDesign.cpp:358-361`, between the module/program pass at `:350-356`
> and the class pass at `:385-388`). Every declaration compiled in that EARLIER
> pass — a package or module subroutine's BODY LOCAL, a `begin` / `fork` /
> `initial` BLOCK-ITEM local, and an OUT-OF-BODY class method's body local,
> which is a package-level `paFunction_declaration` (§ 105) — therefore resolves
> the written name against a design that does not hold it yet:
> `CompileHelper::compileVariable` (`CompileType.cpp:335-435`) finds no
> `getDataType`, no `getClassDefinition`, and a `ts` that
> `compileDatastructureTypespec`'s catch-all (`CompileType.cpp:1051-1055`) has
> already degraded to an `unsupported_typespec` NAMED for the **WRITTEN TOKEN**
> and SPANNED over it — so the declaration takes the final `ref_var` arm
> (`CompileType.cpp:421-431`). `needLateTypedefBinding` never repairs it: the
> repair map holds **TYPEDEFS ONLY** (`ElaborationStep.cpp:102-148`). The
> placeholder's `vpiInstance` is `component->getUhdmInstance()`
> (`CompileType.cpp:2135-2136`) — the declaring PACKAGE, and NOTHING for a
> module. An **IN-BODY** class method's body local is compiled in the LATER
> class pass, sees the builtin, and takes the `cl` arm
> (`CompileType.cpp:360-382`): `class_var` + an **UNNAMED** `class_typespec`
> carrying `vpiClassDefn -> work@process`. Package / module VARIABLES and class
> PROPERTIES are not compiled by `compileVariable` at all and keep a NAMED
> `class_typespec`.*
>
> **AND THE SAME LAW ONE PHASE FURTHER DOWN:** *a GENERATE SCOPE's content is
> built during ELABORATION, after `addBuiltinClasses`, so in the ELABORATED
> listing a generate-block declaration RESOLVES — `class_var` + a NAMED
> `class_typespec` — while the SAME declaration in the module's DEF listing,
> where the generate construct is still a `gen_if` / `named_begin` compiled in
> the module pass, degrades like every other. Measured on both halves of one
> pair (`g115_d.sv` cells `ifp` / `unp`).*
>
> **AND THE SECOND CONJUNCT:** *no `ref_obj` ever binds to such a declaration.
> `UhdmWriter::lateBinding` (`UhdmWriter.cpp:3294`) refuses every candidate
> whose kind is `uhdmref_var` — eight times in that one function (`:3315`,
> `:3324`, `:3335`, `:3344`, `:3387`, `:3397`, `:3418`, `:3426`) — so the
> reference's `Actual_group` stays null in the DEF view. We inherit the refusal
> for free once the declaration IS a `ref_var`.*

### THE DECODE IS EXPERIMENTALLY CONFIRMED, NOT JUST READ

The whole law turns on ONE conditional: `if
(m_compiler->getCommandLineParser()->parseBuiltIn()) { … addBuiltinClasses(); }`
at `CompileDesign.cpp:358`. Flipping it with `-nobuiltin` must move the ONE
cell the ordering protects — the IN-BODY class method local — and nothing else.
**Measured** (`surelog -nobuiltin` on `g115_c.sv`): golden's `kp` becomes
`ref_var + unsupported_typespec 'process'`, exactly like every other cell. That
is the decode, run as an experiment.

Surelog has **no special case for `process`** anywhere: `grep -rn '"process"'`
over its whole `src/` and `include/` returns nothing outside `Builtin.cpp`'s
in-memory source text. These are ordinary class names to it — the ONLY thing
that distinguishes them is WHEN the definition exists.

## 3. THE GRID

`grid115.sh <arm.sv> <bin A> <bin B> <workdir> <cen bin>` builds three databases
per view (`def` and `--elabuhdm` / `-elabuhdm`), echoes every command with its
own `rc` into `<workdir>/cmds.txt` so the binary each database came from is
auditable BY PATH (RESUME §9), and censuses all six with `ct115cen`.
`GRID.txt` has the cells verbatim. Headline:

| arm | cells differing PRISTINE vs golden | cells differing PATCHED vs golden |
|---|---|---|
| `g115_a.sv` context grid | **29** | **3** (all three PRE-EXISTING and unrelated) |
| `g115_b.sv` CONTROL (user `process` / `semaphore` / typedef) | **2** | **2** — and the whole database is **BYTE-IDENTICAL** before and after in BOTH views |
| `g115_c.sv` spelling / position grid | **33** | **15** (all fifteen PRE-EXISTING; the recorded residues R3/R4/R5) |
| `g115_d.sv` generate-scope grid (written mid-pass, see §4) | **14** | **4** (all four PRE-EXISTING and unrelated) |
| `r10oth7repro/c3_bounds.sv` (an EARLIER pass's arm, `mailbox` in four positions) | **16** | **10** — 6 cells moved, **0 regressions** |
| `r10uvm77repro/v77x4_scope.sv` (an EARLIER pass's arm, `process` in five scopes) | **11** | **5** — 6 cells moved, **0 regressions** |

The four cells that make the law's SHAPE, all from golden:

* an IN-BODY class method local KEEPS `class_var` + an UNNAMED `class_typespec`
  (`vpiClassDefn -> class_defn (work@process)`, read off golden's own dump) —
  and that is **already ours**, so the law is fenced OUT of it;
* the SCOPED spelling `std::process x;` KEEPS `class_var` and degrades ONLY the
  typespec, named `std::process` — a DIFFERENT shape, fenced out (residue R3);
* an ARRAY declaration puts the placeholder on the ELEMENT `ref_var`, not on
  the array — fenced out, exactly as § 105 fenced it (residue R4);
* a package / module VARIABLE and a class PROPERTY keep a NAMED
  `class_typespec` — a different Surelog code path entirely, and already ours;
* a GENERATE-SCOPE local RESOLVES in the ELABORATED listing and degrades in the
  DEF listing — the same declaration, two answers, measured on both halves of
  the one pair `ifp` / `unp` (arm `g115_d.sv`).

**GOLDEN-VS-GOLDEN CALIBRATION.** The family's own calibration is read straight
off `fence115.sh`: the two producers' `default` and `testflags` goldens are two
independent Surelog runs of the same design for the five UVM tests that have
both modes, and the fence reports the SAME cell set and the SAME golden payload
in both — `EXPM_N = 0` for this family, so every golden-vs-ours number below is
read against zero expected mismatch.

## 4. THE FIX, AND ITS FOUR CONJUNCTS

The predicate `UhdmExporter::builtinStdClassToken115` (`src/UhdmExporter.cpp`,
24 lines) returns the WRITTEN TOKEN when:

1. the declared type IS one of slang's `std` builtin classes — `isBuiltinStdClass`,
   the SAME gate § `builtinClassTsLinksBuiltinFileDefn7` already uses, which
   walks the type's parent scopes and stops at the first Package /
   CompilationUnit / InstanceBody. A **user** class or typedef merely NAMED
   `process` lives in a compilation unit and is untouched — arm `g115_b.sv` is
   byte-identical across the change;
2. the type is written as a **BARE `IdentifierName`** — the scoped `std::process`
   is golden's `class_var` cell and must not be claimed;
3. the declaration is not an ARRAY — enforced by conjunct 1's kind test, since
   an array declaration's type is an array type, never a `ClassType`;
4. …and the two NEGATIVE conjuncts each site owns:
   * the enclosing subroutine is not an **IN-BODY class method** — SITE 1
     spells it `classScope && !oob` (the same pair that leaves `tsInst` null);
     SITE 2 reads the member flag `inBodyClassMethod88` that
     § `pkgVarBindsOnlyThroughInstance88` already keeps for exactly that state;
   * the declaration is not in an **ELABORATED GENERATE SCOPE** — SITE 1 reads
     `genScope` (`m->UhdmType() == uhdmgen_scope`), SITE 2 reads
     `inGenScopeProc` (§ 75's flag, set only while an elaborated gen-scope
     PROCESS body emits) OR a `gen_scope` on the block's UHDM parent chain
     (`inGenScopeChain115`, which catches a gen-scope SUBROUTINE's nested
     `begin`). No view flag is needed: the DEF listing builds `gen_if` /
     `named_begin` and never a `gen_scope`.

Two emission sites, one law:

* **SITE 1 — `src/TaskFuncEmit.cpp`**, the subroutine-body (tf-item) local: the
  variable is minted as a `ref_var` ahead of
  § `classTdLocalVarKindFollowsCompileOrder10` (which reasons about a
  class-nested TYPEDEF's compile order and has nothing to say here), and the
  binding takes a fresh `unsupported_typespec` named for the token, spanned at
  the type syntax, instanced at `importCopyTsInst ? importCopyTsInst : tsInst`.
  The now-unused `class_typespec` is left UNSTAMPED — it is a possibly SHARED
  object this declaration no longer owns.
* **SITE 2 — `src/StmtEmit.cpp`**, the block-item local (`begin` / named
  `begin` / `fork` arm / loop body / case item, and a module `initial` /
  `always` body): the same two moves, instanced at
  `importCopyTsInst ? importCopyTsInst : pkgScopeInst`.

**DIRECTION: it changes a KIND and its payload, never a carrier.** The
variable's own span, parent, full name and `vpiAutomatic` are untouched —
measured directly by the order-blind whole-dump score (§6): 1644 identity lines
moved over the nine databases, 1644 of them TOWARD golden.

### TWO DEFECTS THE INSTRUMENTS CAUGHT BEFORE ANY CLAIM

**(a) THE GENERATE-SCOPE CELL — caught by the BOUNDARY GATE.** A first cut had
no view conjunct and moved r10uvm77's committed arm `v77x4_scope.sv` cell (5) —
a `process` local in a for-generate's `initial` — AWAY from golden
(`class_var + class_typespec` → `ref_var + unsupported`). The wide boundary run
over a COPY of the whole probe tree named the arm; `g115_d.sv` was then written
to characterise the line, and it is a clean split by LISTING VIEW, not by
position. Nothing in either corpus witnesses that cell, so only the boundary
could have convicted it.

**(b) THE INSTANCE BUG THE SCORE CAUGHT**

A first cut used the bare `pkgScopeInst` at SITE 2. Inside an explicit-import
COPY (`svaunit_pkg` and `adpcm_pkg` re-emitting `uvm_component::…`) that is the
**IMPORTING** package, while golden reads `@uvm_pkg` — the HOME package. It
cost 8 AWAY-GOLDEN identity lines in four databases and `scoreall115.sh` named
them before any claim was made. `importCopyTsInst` (which SITE 1 already used)
is the fix, and it also joins the def/elab re-point list
(`importCopyTsCollect`) the way every other clone typespec does.

## 5. THE FENCE / THE PREDICTION — written from PRISTINE databases only

`fence115.sh <sweep workdir> <cen bin> <out.tsv>` censuses BOTH sides of every
test in a sweep workdir with `ct115cen` and prints every declaration CELL in the
builtin-class family whose payload differs, classified FAMILY (golden holds the
placeholder, we do not), MIRROR (**we** hold it and golden does not — a
WIDENING, which must stay 0) or OTHERDIF.

| corpus | measured | SKIP | FAMILY cells | MIRROR | **databases that MUST move** |
|---|---|---|---|---|---|
| surelog | 956 | 617 | **140** in 9 DBs | 0 | **9** |
| uhdm2rtlil | 1358 | 104 | **0** | 0 | **0** — the predicted NONE |

The nine, BY NAME (`PREDICTION.fence_pristine_surelog.tsv`, `PREDICTION.txt`):
`{default,testflags}/{SeqDriver,SimpleUVM,MiniAmiq,BuildUVMPkg}` and
`default/Scoreboard`. The FIVE SITES, identical in every one of them:

```
uvm-1.2 base/uvm_globals.svh:262    uvm_process_report_message        process p;   <- THE HEAD
        base/uvm_root.svh:411       uvm_root::run_test        process phase_runner_proc;
        reg/uvm_reg.svh:2976        uvm_reg::XatomicX         process m_reg_process;
        base/uvm_component.svh:3612 uvm_component::m_apply_verbosity_settings
                                                              process p = process::self();
        base/uvm_component.svh:3366 uvm_component::m_set_cl_msg_args  process p_;
```

(BuildUVMPkg names them at its `pp_output` lines 9683 / 38875 / 68683 / 41441 /
41140.)

AFTER the patch (`MEASURED.fence_patched_surelog.tsv`): FAMILY **32**, MIRROR
**0** — and the 32 are the SAME 32 rows the PRISTINE fence already carried: an
import-copy LISTING multiplicity in which golden lists a subroutine body local
TWICE (under the function/task AND under the `begin`) and we list it once. That
residue is not this family's (it hits `uvm_object::sprint`'s `bit_typespec p`
and `uvm_transaction::do_record`'s `enum_typespec` the same way) and is
UNCHANGED by this pass — counted directly: 34 golden rows / 27 ours, before and
after. **All 108 real cells went to golden.**

`semaphore` and `mailbox`: golden treats them IDENTICALLY (grid cells `sem`,
`mbx`, `msem`), but the corpus contains **ZERO** cells of either, in either
corpus. No widening is claimed on them; the shared predicate covers them because
the gate is the `std`-package IDENTITY and not a name list, and the purpose-built
arms are their only witnesses.

## 6. THE GATE BATTERY

See `GATES.txt` for the whole battery with its numbers, the `cmds.txt` binary
audit by PATH, the four boundary runs and the order-blind mover attribution.

## 7. RESIDUES, named for the queue

**R0 — THE NEW HEAD of SimpleUVM ×2 (17 lines).** An IMPLICIT NET golden mints
in the TOP MODULE for the one name the package-scope late binding could not
resolve:

```
LHS  logic_net: (work@top.p)  @263:3-263:4
       |vpiParent: \_module_inst: work@top
       |vpiName:p  |vpiFullName:work@top.p  |vpiNetType:1
RHS  <null>
```

This pass moved the family MOST of the way there already: `work@top.phase_runner_proc`
(×2) and `work@top.m_reg_process` (×4) appeared with it and match golden's counts
EXACTLY, and 15 of SimpleUVM's 16 family REF cells now agree with golden in both
views (5 did before). The one left is `p` — the local of the FREE PACKAGE
FUNCTION `uvm_process_report_message`, where our implicit-net machinery still
does not fire while it does for the out-of-body class methods. Same family as
§ `fnLocalParamRangeNet` and as uvm105's own R0; one object, `RHS: <null>`
(the SINGULAR `SafeCompare` mirror — golden's `module_inst::Nets` holds an
element ours does not).

**R1 — THE NEW HEAD of Scoreboard/default (60 lines), a DIFFERENT FAMILY.**
`uvm-1.2 seq/uvm_sequence_builtin.svh:196`, inside
`uvm_exhaustive_sequence::body`:

```systemverilog
if (!randomize(l_kind) with { l_kind > l_exhaustive_seq_kind; l_kind < max_kind; })
```

golden models the scope-less `randomize(arg) with {…}` as a bare
`method_func_call: (randomize)` with `vpiArgument -> ref_obj(l_kind)` and
`vpiWith -> constraint`, parented at the enclosing `operation`; we build a
`hier_path: (l_kind.randomize)` with two `Path_elems`. Producer:
`CompileHelper::compileRandomizeCall` (`CompileStmt.cpp:3151`). Nothing to do
with this pass; Scoreboard/default is also the ~50/50 COIN, so its line count is
not a distance.

**R2 — the `-nobuiltin` mode.** MEASURED: with `-nobuiltin` golden gives
`ref_var + unsupported_typespec 'process'` to an IN-BODY class-method local too
(the builtin registry never exists, so the later class pass fails the same way).
We keep `class_var` there. **Zero** corpus witnesses in either corpus, so the
in-body exclusion is left unconditional rather than widened on no evidence.

**R3 — the SCOPED spelling.** `std::process x;` as a body local: golden keeps
`class_var` and degrades ONLY the typespec, to `unsupported_typespec` named
`std::process` (grid cell `sp`, both views). Zero corpus witnesses.

**R4 — the ARRAY spellings.** `process a[2]` / `a[$]` / `a[]` as a body local:
golden puts `ref_var + unsupported_typespec 'process'` on the ELEMENT, which is
a different emission site (grid cells `afix` / `aq` / `adyn`). Zero corpus
witnesses — the corpus's arrays of `process` are class PROPERTIES, where golden
keeps a NAMED `class_typespec` and we already agree on the kind.

**R5 — FORMALS and RETURN variables.** `function process f(process arg);`:
golden degrades BOTH (the return variable to `ref_var + unsupported`, the
`io_decl`'s typespec to `unsupported`). Zero corpus witnesses. Same law, two
more sites, deliberately not widened on no evidence.

**R6 — the import-copy LISTING multiplicity** (see §5): golden lists a
subroutine body local under BOTH the subroutine and the `begin` inside
`svaunit_pkg` / `adpcm_pkg` copies; we list it once. Pre-existing, unchanged,
and not confined to this family.

**R7 — the array-of-`process` class-property ELEMENT typespec SPAN.** 18 cells
in 9 databases: golden `227:10-227:17`, ours `0:0-0:0`. Judge-invisible
(`typespec::Compare` reads `Typedef_alias` and `Instance`; `BaseClass::Compare`
reads `VpiType` / `VpiName` / `VpiDefName` — never a span), unchanged by this
pass, and recorded only so the fence's OTHERDIF count is accounted for.

## 8. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct115cen.cpp` | the DECLARATION-KIND + TYPESPEC-KIND census. Descended from `r10uvm105repro/r10uvm105cen.cpp` with the two columns this head needs — the declared object's OWN kind (`ref_var` vs `class_var` IS the head) and its parent's kind — plus REF and CALL row types. Keyed on what both producers can spell (view / owner / span); NEVER the file (our objects carry an EMPTY `VpiFile`) and never the name alone. |
| `fence115.sh` + `fence115.py` | the family's differential census over a whole sweep workdir; MULTISET join, face-matched by declared name; FAMILY / MIRROR / OTHERDIF. |
| `g115_a.sv` / `g115_b.sv` / `g115_c.sv` / `g115_d.sv` | the four purpose-built goldens: the CONTEXT grid, the CONTROL (a user class named `process`), the SPELLING/POSITION grid, and the GENERATE-SCOPE grid. |
| `grid115.sh` | builds one arm's six databases (three producers × two views) and censuses them; every command echoed with its own rc. |
| `score115.py` + `scoreall115.sh` | the DIRECTION score: a multiset COUNT comparison against golden of exactly the lines the patch moved. Bare marker lines (`\|vpiActual:` — a field name and nothing else) carry no identity and are counted separately, never scored; a per-cell census settles those. |
| `attrib115.sh` | order-blind, path-normalised, id-stripped mover attribution (Scoreboard/default is a coin — RESUME §9). |
| `bound115.sh` | the BOUNDARY gate over a COPY of the whole probe tree, both MODEs, both VIEWs — plus a NULL CONTROL run (the SAME binary on both sides) that separates emitter nondeterminism from the patch. |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standing gates, copied unchanged. |
