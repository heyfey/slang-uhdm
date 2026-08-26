# r10v155 — ADVERSARIAL VERIFICATION of r10uvm155 § `blockLocalTdDeclIsRefVarUnsupported155`

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge. The official
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table and
every script here.

| | |
|---|---|
| BASE | `5b84cae` |
| verifier worktrees | `/tmp/wt_v155pris` (clean), `/tmp/wt_v155` (as-shipped patch), `/tmp/wt_v155fix` (patch + this verifier's two fixes) |
| pristine binary | md5 `62edd55590a0e02a0647ac59dfb32820` — **reproduced the implementer's md5 bit-for-bit** |
| as-shipped patched | md5 `cd167bd1925a7198211625b5124e8c4d` — **reproduced bit-for-bit** |
| verified binary | md5 `7c1ff45e22d363dbfbad441291997ecd` (`/tmp/r10uvm155.verified.patch`) |
| all three frozen `chmod 555` before any sweep | yes |

## VERDICT: **ACCEPT-WITH-FIX**

The law is real, the decode is correct, and every headline number reproduces.
Two **over-fires** on legal SystemVerilog were found by adversarial grids and
fixed in place; both fixes are strictly *declines* (they never mint anything),
both are gated, and neither costs a single one of the implementer's 73 measured
cells.

## 1. WHAT REPRODUCED, BIT-FOR-BIT

* Both binary md5s, from independent worktrees and builds.
* The pristine head: BuildUVMPkg ×2, **56 cmp lines, 1 head**, `LHS ref_var`
  + `unsupported_typespec (__tmp_int_t__)` @51340:6-19 vs `RHS bit_var` +
  `bit_typespec`, same span. `VpiType` on the declaration.
* The patched head: **1371 lines, 1 head**, the enclosing `begin`
  @`uvm_pkg.sv:51337:29` with `RHS: <null>` — a NEW object, DEPTH not distance.
* **R0 verified independently**: golden's `begin` carries
  `|vpiTypedef: \_bit_typespec: (__tmp_int_t__) @51338:14-51339:48`; we list
  nothing. The R0 the pass names is exactly the residue that remains.
* Every other row's head log **byte-identical**: SeqDriver 22, SimpleUVM 36,
  Scoreboard 163, MiniAmiq 106, Earlgrey 31/54, Rggen 0 (`cmp` on the logs).
* Surelog byte movers **2 / 956** — `default/BuildUVMPkg-bf853d43` and
  `testflags/BuildUVMPkg-bf853d43`, the two the pass PREDICTED BY NAME.
  (The pass reported 3; the third was the Scoreboard/default COIN, which landed
  the same way in this run — a *stronger* result, not a discrepancy.)
* uhdm2rtlil movers **0 / 1358**, SELFCHECK 1357/1358 flagged (the comparator
  is live).
* The implementer's own five grid arms, re-scored against the **verified**
  binary: **73 cells TOWARD, 0 WRONG, 0 RESHAPE**, and `g155_a_home` reaches
  **0 differing cells** — their number exactly.

### Surelog decode, re-read from source

Every citation checked line by line:
* `CompileStmt.cpp:1283-1290` — `case paType_declaration: if (pstmt) component = nullptr;` ✔
* `CompileType.cpp:421-431` — `compileVariable`'s final `ref_var` arm, and it is
  the arm that calls `component->needLateTypedefBinding(ref)` ✔
* `CompileType.cpp:1051-1056` — the catch-all `unsupported_typespec` with
  `VpiName(typeName)` + `populateCoreMembers(type, type, tps)` ✔
* `ElaborationStep.cpp:109-148` — `defs` over file contents / packages /
  modules / programs / classes; a statement scope is in none ✔

## 2. FIX 1 — THE SHADOW GATE WAS BLIND TO IMPORTS

`stmtScopeTdName155`'s shadow gate asks `Scope::find(name)` at each enclosing
scope. **`Scope::find` is direct members only**: it returns `nullptr` for an
`ExplicitImport` (slang `source/ast/Scope.cpp:582-584`, *"Don't return imported
symbols; this function is for querying direct members only"*), and a wildcard
import is **not in the name map at all** (`include/slang/ast/symbols/
MemberSymbols.h:88-91`, *"won't even be in the name map of a symbol at all …
there is a sideband list"*). Surelog's `getDataType` / `getClassDefinition` DO
resolve an imported name.

Measured — `v155_e_import.sv`, both views, every typedef name unique in the
design so the uniqueness gate cannot mask the question:

| declaration | golden | pristine | AS SHIPPED | verified |
|---|---|---|---|---|
| local `typedef int KNone155v` (class only in an UN-imported package) | `ref_var` + `unsupported_typespec` | `int_var` + `int_typespec` | **`ref_var` + `unsupported_typespec` ✔** | ✔ |
| local `typedef int KExpl155v` + `import pq::KExpl155v;` | `class_var` + `class_typespec` | `int_var` + `int_typespec` | **`ref_var` + `unsupported_typespec` ✘** | `int_var` (declines) |
| local `typedef int KWild155v` + `import pq::*;` | `class_var` + `class_typespec` | `int_var` + `int_typespec` | **`ref_var` + `unsupported_typespec` ✘** | `int_var` (declines) |
| local `typedef int KLoc155v`, class a DIRECT member of the same package | `class_var` + `class_typespec` | `int_var` | `int_var` (already declined by `find`) | ✔ |

Plus `v155_d_shape.sv` `genValD155v` — a generic class reached by
`import pkgD155v::GenD155v;` — the same failure. **6 cells** (3 declarations ×
2 views) moved where the pass's OWN law says *"UNLESS the same NAME also denotes
a type OUTSIDE every statement scope — a class … — in which case Surelog binds
THAT one and nothing about the declaration moves."*

**Fix:** `importedTypeLike155(scope, name)` in `src/EmitHelpers.h` — the same
question asked of the scope's explicit imports (`ExplicitImportSymbol::
importedSymbol()`) and its wildcard imports (`Scope::getWildcardImportData()`
→ `WildcardImportSymbol::getPackage()` → `PackageSymbol::find`). Consulted only
when `Scope::find` came back empty, so nothing that already declined changes.

## 3. FIX 2 — A PROGRAM'S `initial` / `final` IS NOT A STATEMENT SCOPE TO SURELOG

The pass's law says *"a subroutine BODY, an `initial` / `always` body"* degrade
in every home. **A PROGRAM's procedural block does not.**

The mechanism, read off Surelog:

* `CompileModule.cpp:529-538` — the module (and interface) collect walk carries
  `stopPoints = { … paPar_block, paSeq_block, paFunction_body_declaration,
  paTask_body_declaration }`, so a `paData_declaration` inside a procedural
  block is **never** reached by `CompileHelper::compileDataDeclaration`
  (`CompileHelper.cpp:2260-2277`, which calls
  `compileTypeDef(component, …, /*pstmt*/ nullptr)` and DOES register). Only
  `compileStmt`'s arm sees it, with `component = nullptr` → degrade.
* `CompileProgram.cpp:97-99` — the program's walk carries
  `stopPoints = { paClass_declaration }` and **nothing else**. It descends into
  the `initial`/`final` `paSeq_block`, reaches the `paData_declaration`, and
  **registers the typedef in the Program** → `compileVariable` resolves it.

Measured — `v155_g_program.sv`, both views, every typedef name unique:

| home | golden |
|---|---|
| module `initial` / `always_comb` / `final` / task body | DEGRADES (`ref_var` + `unsupported_typespec`) |
| interface `initial` / task body | DEGRADES |
| package function body | DEGRADES |
| **program `initial` / `final`** | **RESOLVES** (`byte_var` + the real `byte_typespec`, named and spanned at the typedef) |
| program task body | DEGRADES |

As shipped, the two program cells (×2 views = 4) moved **AWAY** from golden:

```
golden   (byte_var, byte_typespec, tdPrgInit155v, <noinst>, 28:13-28:17)   
pristine (byte_var, byte_typespec, -,             <noinst>, 29:5-29:18)  2/5 fields right
SHIPPED  (ref_var,  unsupported_typespec, tdPrgInit155v, <noinst>, 29:5-29:18)  1/5
```

**Fix:** `stmtScopeIsProgramProcedural155(home)` — walk out from the alias's
home statement scope; a `Subroutine` on the way means the law still fires (a
subroutine body is a stop point in *every* container, program included), an
`InstanceBody` whose `definitionKind == DefinitionKind::Program` means decline.

## 4. THE ADVERSARIAL GRID — 10 arms, both views, pristine vs VERIFIED

| arm | what it varies | TOWARD | WRONG | RESHAPE |
|---|---|---|---|---|
| `v155_a_import` | wildcard / explicit / scoped package-typedef shadowing | 0 | 0 | 0 |
| `v155_b_kind` | 14 target kinds + a macro-expanded typedef + forward typedef | 36 | 0 | 0 |
| `v155_c_home` | program / interface / task / nested fork / class property / package + module vars / in-body + out-of-body methods | 16 | 0 | 0 |
| `v155_d_shape` | 1-3 declarators ± initialiser, packed dims at the use, 3 nested `begin`s, type parameter ± override, **3 instances**, `$unit` | 27 | 0 | 0 |
| `v155_e_import` | class names via explicit / wildcard / no import / direct member | 2 | 0 | 0 |
| `v155_f_shadow` | module name, interface name, inherited base typedef, inherited nested class, generic-class type parameter | 3 | 0 | **2** |
| `v155_g_program` | initial / always / final / task, in module vs program vs interface vs package | 13 | 0 | 0 |
| `v155_h_unique` | cross-component and same-component name collisions, forward typedef in a block, one typedef two declarators | 4 | 0 | 0 |
| `v155_i_order` | loop body, `case` item, `while` body, all four declarator-array forms in a task | 16 | 0 | 0 |
| implementer's `g155_a…e` | their own five arms | 73 | 0 | 0 |
| **TOTAL** | | **190** | **0** | **2** |

Plus the six boundary arms of earlier passes that moved (§6): `g114_c_clspkg`
4, `w2_locals` 1, `v5_homes` 2, `v145_h_param` 3, `v149 arms/scoped/dut` 5,
`g22` 0 — **all TOWARD, none away**.

### 4b. THE SECOND, STRONGER SCORER — `scoreref155.py`

The DECL census keys a cell on its own SPAN, and golden spans a `ref_var` at
the WRITTEN TYPE while we span it at the NAME (`CompileType.cpp:421-431` sets
`ref->VpiName(typeName)` and populates from the type node). On
`r10v145repro/v145_h_param.sv` that join FAILS, and a span-keyed scorer reports
the arm as 0 movers while its cells plainly moved. `scoreref155.py` therefore
re-keys on `(view, row type, owner, NAME)`, drops every span from the payload,
and **includes REF rows**, so the collateral a declaration's kind change has on
the references bound to it is visible. Re-scored that way, over all 19 arms:

**275 cells TOWARD · 0 WRONG · 0 AWAY · 44 RESHAPE**, and every one of the 44
is net-toward:

| reshape class | count | golden | pristine | verified |
|---|---|---|---|---|
| `ref_obj → Actual`, both views | 28 | `logic_net` (def) + `ref_var` (elab) | the resolved kind, twice — **0 of 2 match** | `ref_var` twice — **1 of 2 match** |
| `ref_obj → Actual`, def binding dropped | 16 | `logic_net` (def) + `ref_var` (elab) | the resolved kind, twice — **0 of 2** | `<null>` (def) + `ref_var` (elab) — **1 of 2** |
| the interface-name `VAR` cell (residue R1) | 2 | `ref_var` + `interface_typespec` | `byte_var` + `byte_typespec` — 2 of 5 | `ref_var` + `unsupported_typespec` — **4 of 5** |

**Not one pristine side of those 44 contained a golden-matching kind** — the
measurement that settles direction. `0 AWAY` under both scorers.

## 5. GATES (all on the VERIFIED binary unless stated)

* goldens **23 PASS / 0 FAIL** on pristine, as-shipped and verified;
  `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** (the negative control bites).
* uhdm2rtlil **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, both modes,
  all three binaries; `ct8rows` PASS vs the committed baseline **and** vs this
  verifier's own pristine sweep, both modes.
* surelog status histogram **IDENTICAL** to pristine; `CMP_NOTEQUAL` stays
  **19**; `ct8rows` PASS; **no row converted**, `results/*.csv` never written.
* byteverify `SELFCHECK=1`: surelog **2 / 956** (both PREDICTED BY NAME),
  uhdm2rtlil **0 / 1358**.
* **cmds audited BY BINARY PATH, file by file**: 1523 surelog + 1458
  uhdm2rtlil `cmds.txt` invocations per binary, every one naming the frozen
  `/tmp/v155_bin/*.bin`; **zero** main-tree-binary leakage.
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (uhdm2rtlil);
  `ctcan2` PASS ×2; `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`.
* protected DBs by name: InterfaceModPort / BlackParrotComplex / YosysOldOr
  byte-identical; **SVSwitch `4842211c4030`** and **YosysVerx `6ccda350c24a`**
  pins held, both modes.
* fence check on the shipped patch: 0/0/0/0; surface = 5 production files +
  `tools/probe/r10uvm155repro/` + `tools/probe/r10v155repro/` only.

## 6. THE WIDE BOUNDARY — `bound3v155.sh`, THREE BINARIES IN ONE TRAVERSAL

`bound3v155.sh` is `r10uvm155repro/bound155.sh` with a third binary column, so
the as-shipped and the verified binary are scored against the SAME pristine
traversal (same guards: list on fd 3, children `</dev/null`, `PROCESSED`
asserted against `LISTED`, scratch keyed on the RELATIVE path, no language
flag, a `PRODUCED_DBS` counter that convicts a green-on-nothing run).
`LISTED=4389` — the implementer's 4381 arms plus this verifier's 8.

**Segfaults are pre-existing**: exactly **2 on each** of pristine, as-shipped
and verified. Not introduced by the patch. (RESUME §9: a segfault must never
read as a result — the driver records rc per cell.)

### `r10buvm22repro/g22.sv` — decoded, and it is NOT the law

The one arm outside this pass's own grid that moves bytes on both the shipped
and the verified binary. `rc=4/4/4` (slang REJECTS it on all three), the
declaration census moves **0 cells**, the file size is **identical** (56619 on
all three), and the whole-dump diff is **14 lines**, of which the payload is
three folded constants on `typedef C22 ka_cls_t[string];`:

```
pristine  |vpiDecompile:22539993   |UINT:22539993
shipped   |vpiDecompile:22544089   |UINT:22544089    (+4096)
verified  |vpiDecompile:22548185   |UINT:22548185    (+4096)
```

A **three-point ladder, each step exactly one 4096-byte page**, tracking three
binaries of increasing image size. That is a *binary-image address* leaking
into a folded constant for an associative-array dimension on a design slang
rejects — a pre-existing emitter bug that moves for ANY binary whose image
grows, unreachable through either corpus (`SLANG_REJECT` is out of scope).
The implementer's attribution is correct; this ladder is the independent proof.

## 7. RESIDUES, RANKED

0. **The DEF-view `ref_obj` binding on a degraded local** (42 cells across the
   grid, and the largest remaining class). Golden's un-elaborated view binds
   the reference to an implicit **`logic_net` minted at the REFERENCE site**,
   not to the local at all; its elaborated view binds the `ref_var`. We now
   match the elaborated half exactly and either bind our own `ref_var` (28
   cells) or leave the actual unset (16 cells) in the def view. Pristine
   matched NEITHER half. A good candidate for the next head after R0.
1. **The interface-name collision** (`v155_f_shadow` `vIfc155v`, 2 cells).
   Golden reads `ref_var` + **`interface_typespec (name)`** — the KIND half of
   the law is RIGHT, and the verified binary now gets it right (pristine read
   `byte_var`). Only the placeholder's KIND is wrong: golden takes
   `compileDatastructureTypespec`'s *interface* arm, not the catch-all. 4 of 5
   payload fields now match, against 2 of 5 pristine. Deliberately NOT fixed:
   minting an `interface_typespec` is a separate law, and declining would throw
   away a correct `VpiType` (`BaseClass::Compare`'s FIRST test) for nothing.
2. **The name-collision repair** (`v155_h_unique` `userVal155v`). Golden binds
   the STRANGER's typespec — `ref_var` + `int_typespec (strangerTd155v)`
   spanned at the *other module's* typedef — and it does so **across
   components**, which this verifier measured directly. Question (4)'s
   uniqueness gate correctly declines; building the stranger's typespec is a
   different law.
3. **A FORWARD typedef inside a statement scope** (`v155_h_unique`
   `fwdBlkVal155v`). Golden degrades, but `buildTdNameCount155` counts the
   forward declaration AND the real one, so the count is 2 and the law
   declines. A missed conversion, cheap to reach later.
4. **An inherited base-class typedef / nested class shadowed by a
   method-local typedef** (`v155_f_shadow` `vInner155v`). Golden degrades; the
   patch declines because slang hoists inherited members as
   `TransparentMemberSymbol`, so `Scope::find` DOES see them. Over-decline,
   conservative.
5. **A class type parameter shadowed by a method-local typedef**
   (`v155_f_shadow` `vTp155v`). Golden reads `ref_var` + the type parameter's
   `int_typespec`; we read `byte_var`. Pre-existing, untouched.
6. **The pass's own R0** — the statement-scope typedef's listing on its
   enclosing `begin`. Unchanged and correctly named.

## 8. FILES

* `bound3v155.sh` — the three-binary wide boundary.
* `gridv155.sh`, `ctv155cen.cpp` — verbatim from `r10uvm155repro` (same guards).
* `scorecell155.py` — one machine-readable line per cell, so a cell that goes
  DIFF→DIFF *differently* (a RESHAPE) cannot hide behind an aggregate count.
* `scoreref155.py` — the span-independent, REF-aware scorer of §4b.
* `mover155.py` / `reshape155.py` — TOWARD / WRONG / RESHAPE, keyed on the
  cell identity only.
* `v155_{a..i}_*.sv` — the ten adversarial arms.
