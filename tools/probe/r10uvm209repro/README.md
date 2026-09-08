# r10uvm209 — § `hoistedLocalKeepsItsLifetime209` — **A MATERIALISED-IMPORT COPY CARRIES THE SOURCE VARIABLE'S OWN LIFETIME: THE NET-vs-DATA-DECLARATION AMBIGUITY THAT DECIDES `vpiAutomatic` IS A PACKAGE-ITEM ONE, AND A HOISTED OUT-OF-BODY CONSTRUCTOR LOCAL IS NOT A PACKAGE ITEM** — the SimpleUVM ×2 86-line head CLEARED and **BOTH SimpleUVM ROW-MODES CONVERTED TO `CMP_EQUAL`**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
the ONE conversion this pass makes is stated LOUDLY and quoted verbatim in § 0.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are not spelled in any artifact; `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b14d8969` |
| pristine binary | md5 `ca22259d3130f2ff5b7e6a696f562ef3`, built from this pass's OWN worktree at a clean `b14d8969` and frozen `chmod 555` before any sweep. **Byte-identical to the main tree's binary at that commit**, measured when it was frozen. Its 956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduce the committed baselines row for row, with the ONE informational exception of R5. |
| patched binary | md5 `526cbd7fa52f03f17ad969c2f1ddcfef`, frozen `chmod 555`. The patch applied to a **FRESH `b14d8969` worktree** (`cmake -DCMAKE_BUILD_TYPE=Release`) and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on — and that fresh build passes the goldens **23/0**. A COMMENT-ONLY edit to either production file changes this md5, so the committed text is exactly the text that compiled to `526cbd7f`. |
| production surface | `src/ParamEmit.cpp`, `src/ModuleEmit.cpp` — **two files, one rule**: the decision that authors a materialised variable's `vpiAutomatic` is gated on WHERE THE DECLARATION WAS WRITTEN, and the two blanket stamps that used to override it are gone. Nothing deleted, no object re-pointed, no name written that golden does not write. |
| probe surface | `tools/probe/r10uvm209repro/` only |

---

## 0. READ THIS FIRST — the numbers, and the CONVERSION

| | |
|---|---|
| the head | **SimpleUVM default and testflags, 86 cmp lines, ONE head each → CLEARED.** The head object is `class_var: (work@top.clp)` under the ELABORATED `module_inst work@top` (`id:197854`, `TopModules[0]`), on `vpiAutomatic`: golden **1**, ours unset. It is a FAMILY of **ten objects** — five names (`clp`, `top`, `cs`, `bld`, `common`) × the two import copies `import uvm_pkg::*;` at file scope materialises — one masked rung each. |
| **THE CONVERSION — quoted verbatim, NOT summarised** | `ct8rows.sh` against this pass's OWN pristine sweep reports **2 differing ROWS** and they are: <br>`< SimpleUVM,default,CMP_NOTEQUAL,decompile:,,` <br>`< SimpleUVM,testflags,CMP_NOTEQUAL,decompile:,,` <br>`> SimpleUVM,default,CMP_EQUAL,,,differ` <br>`> SimpleUVM,testflags,CMP_EQUAL,,,differ` <br>**`results/*.csv` were NOT edited.** The integrator promotes these two rows. |
| the status histogram | surelog `default` **473 → 474 CMP_EQUAL, 8 → 7 CMP_NOTEQUAL**; `testflags` **468 → 469 CMP_EQUAL, 7 → 6 CMP_NOTEQUAL**. Every other cell of both histograms is unchanged; the dump-column histograms are unchanged. uhdm2rtlil: **679 / 50 / 2 in both modes, every row byte-identical**, against the committed gate AND against this pass's own pristine sweeps. |
| every other row's head | **unchanged, both binaries**: SeqDriver ×2 **112**, Scoreboard/default **95**, MiniAmiq ×2 **112**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. SimpleUVM ×2 **86 → 0, heads 1 → 0**. |
| byte movers | **4 / 956** surelog, and the moved set **EQUALS the predicted set**: all four were **PREDICTED BY NAME before the patched binary was used for anything**, from PRISTINE databases alone (`ct209pred`, `PREDICTION.pristine.surelog.r10uvm209.txt` — 956 databases visited, `FIRING=4`): `{default, testflags} × {SimpleUVM, SeqDriver}`. **0 / 1358** uhdm2rtlil, also predicted (`FIRING=0` over 1358). `Scoreboard/default` did not flip on this run and its predictor reads `FIRES=0`. |
| the census (every variable listing of every scope, golden × ours, nine names × both modes, 16 comparable row-modes) | listing **WRONG 30 → 0**; **MOVED-WRONG 0 / AWAY 0** on all sixteen. SimpleUVM ×2 `RIGHT 1218→1228, WRONG 10→0`; SeqDriver ×2 `RIGHT 1366→1371, WRONG 5→0`; Scoreboard, MiniAmiq ×2, BuildUVMPkg ×2, ApbSlave ×2, ClassExtends ×2, Rggen/default, Earlgrey_0_1 ×2 all `WRONG 0 → 0` with the whole-database variable multiset **identical before and after**. `ONLY-OURS` is **0 on every UVM row before and after** — this law adds not one object. |
| the grid (7 arms × 2 views, one REAL Surelog golden each) | CALIB golden-vs-golden **AGREE 662, everything else 0**. PRISTINE `AGREE 572 WRONG 70 ONLY-GOLDEN 20 ONLY-OURS 0`; PATCHED `AGREE 622 WRONG 20 ONLY-GOLDEN 20 ONLY-OURS 0`. **ONLY-GOLDEN and ONLY-OURS did not move**, and the patched WRONG set is a strict SUBSET of the pristine one — `NEW-WRONG-CELLS=0`, computed as a set difference, not inferred from the totals. **0 nonzero rcs.** |
| the four CMP_EQUAL rows the brief protects | `BuildUVMPkg/default`, `BuildUVMPkg/testflags`, `Earlgrey_0_1/testflags` and (scored with them) `Rggen/default` stay `CMP_EQUAL` with **BOTH columns byte-identical** — status AND dump — and their databases are byte-identical to the pristine ones. `Earlgrey_0_1/default` and `ClassExtends ×2` likewise. Scored explicitly in § 6. |
| gates | goldens **23/0** on BOTH binaries, negative control **0/23**; every `cmds.txt` in every sweep names exactly one binary path and it is the frozen one for that arm; canaries against this pass's own pristine `ok=50 changed=2` — **and the two changed rows are the SimpleUVM conversion, named** — `ok=8 changed=0` on u2r; `ctcan2` PASS ×3; `canaudit` PASS, `audited=29 UNCOVERED=0 FENCE-BREACH=0`; all ten protected databases **SAME**, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. Full battery verbatim in `GATES.r10uvm209.txt`. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

The brief's target was re-measured, not inherited. This pass built its own
binary from a clean `b14d8969` worktree and it came out **byte-identical** to the
main tree's (md5 `ca22259d…`). `rowheads.sh` on its own pristine sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default        112      1
SeqDriver      testflags      112      1
SimpleUVM      default         86      1
SimpleUVM      testflags       86      1
Scoreboard     default         95      1
MiniAmiq       default        112      1
MiniAmiq       testflags      112      1
BuildUVMPkg    default          0      0
BuildUVMPkg    testflags        0      0
Earlgrey_0_1   default          0      0
Earlgrey_0_1   testflags        0      0
Rggen          default          0      0
```

ONE head per SimpleUVM mode, and it is one bit:

```
LHS  class_var: (work@top.clp), id:188924, line:801:27, endln:801:66
     |vpiParent: module_inst: work@top, id:197854      <-- TopModules[0], the ELAB view
     |vpiName:clp  |vpiFullName:work@top.clp  |vpiAutomatic:1  |vpiVisibility:1
RHS  class_var: (work@top.clp), id:181093, line:801:27, endln:801:66
     |vpiName:clp  |vpiFullName:work@top.clp                   |vpiVisibility:1
```

`variables::Compare` (`~/git-repos/UHDM/build/generated/src/variables.cpp:255`)
reads `VpiAutomatic` between `VpiSigned` and `VpiAllocScheme`, and every
`variables` subclass reaches it through `basetype_t::Compare` — `class_var`
(`class_var.cpp:76`) and `array_var` (`array_var.cpp:123`) included. So this is
a judged cell for every kind, not a byte-identity one.

`clp` is `uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();`
(`base/uvm_phase.svh:801`), a body local of the OUT-OF-BODY constructor
`function uvm_phase::new`, which § `oobCtorLocalsRideTheImport203` hoists into
`work@top`'s materialised-import listing.

---

## 2. QUESTION 1 — THE EDGE, WITH THE OWNER-FINDER

Our databases leave `VpiFile` EMPTY on every object (measured: all 7026 rows of a
SimpleUVM census read `<noloc>`), so "which scope was this declaration written
in" is not a question our side can be asked. It is a question GOLDEN can be
asked, and `ct209cen`'s **owner-finder** asks it: it indexes every `package`,
`class_defn`, `task`, `function`, `module_inst` and `begin` in the database by
file and span, and for each variable returns the INNERMOST one whose span
contains the declaration. That is what makes "function-local vs package-scope"
measurable, per object, on the golden side — the brief's asked-for key.

**GOLDEN's elaborated `work@top` listing, 68 entries, keyed by SOURCE SCOPE ×
KIND × `vpiAutomatic`** (uvm203's fifteen-object frame is the `function`/`begin`
rows; the counts are ×2 because a file-scope `import uvm_pkg::*;` materialises
the listing twice):

| source scope | kind | count | vpiAutomatic |
|---|---|---|---|
| `function:new` (uvm_component::new, uvm_phase::new) | `class_var` | 4 | **1** |
| `function:new` | `string_var` | 2 | **1** |
| `begin:` (a nested block inside those constructors) | `class_var` | 6 | **1** |
| `begin:` | `string_var` | 2 | **1** |
| `<none>` = the package's own items | `class_var` | 18 | **1** |
| `<none>` | `class_var` | 18 | **0** |
| `<none>` | `array_var` (assoc) | 2 | **1** |
| `<none>` | `bit_var` / `int_var` / `string_var` | 14 | **1** |
| `module_inst:` = the module's OWN declarations | `bit_var`, `class_var` | 2 | **0** |

**The split hypothesis is CONFIRMED and it is SHARPER than "function-local
automatic, package-scope unmarked".** Package scope is not uniformly unmarked —
half its `class_var` copies ARE automatic (§ `packageVarAutomaticIsDataDeclShape26`'s
`= new()` and `const` ones) and every package-scope NON-class kind is automatic.
What is uniform is:

* **function-local → 1, unconditionally, KIND-BLIND** (14 of 14, four kinds);
* **module-own → 0**, always;
* **package-scope → § 26's data-declaration shape decides.**

**AND THE MODULE'S COPY IS THE PACKAGE'S LISTING, VALUE FOR VALUE.** Golden's
`uvm_pkg` listing is 33 entries; golden's elaborated `work@top` listing is those
33 twice plus the module's own `clk`/`environment`, and a `diff` of the
qualifier faces (`kind|name|A|V|C`) of the package listing against each 33-entry
run is **EMPTY**. Not a re-derivation — a copy.

Our pristine listing agrees with golden on **1218 of 1228** cells; the ten that
disagree are `clp`, `top`, `cs`, `bld`, `common` × 2 copies. The other four
hoisted names (`error_str`, `val`, `uvm_random_seed_table_lookup` — a `string`,
a `string` and an associative array) were ALREADY right, by accident of the same
§ 26 rule: a `string` is a keyword-spelled type, so it never matched the net
shape. **The family is exactly the hoisted declarations whose written type is a
bare type IDENTIFIER.**

---

## 3. QUESTION 2 — DECODING SURELOG, END TO END

**Why a constructor's body locals are in the package's listing at all.**
`CompilePackage::collectObjects_` (`src/DesignCompile/CompilePackage.cpp:124`)
walks the package's syntax with a stop list:

```cpp
  std::vector<VObjectType> stopPoints = {
      VObjectType::paClass_declaration,
      VObjectType::paFunction_body_declaration,
      VObjectType::paTask_body_declaration,
      VObjectType::paInterface_class_declaration};
```

`paClass_constructor_declaration` **is not on it** — it has its own `case` at
`:248` that compiles the constructor and then falls through to the generic
"push the children" tail. So the walk DESCENDS INTO an out-of-body constructor
body and meets its `paData_declaration` block items as if they were package
items, handing each to `compileDataDeclaration(m_package, …)` (`:263`). That is
§ `collectOobCtorLocals`'s measured distinguisher — *a non-`new` out-of-body body
hoists nothing* — with its mechanism: a `function`/`task` body is a stop point,
a constructor is not.

**Why they are AUTOMATIC.** `CompileHelper::compileDataDeclaration`
(`src/DesignCompile/CompileHelper.cpp:2261`) opens with

```cpp
      bool is_static = (valuedcomponenti_cast<ModuleDefinition*>(component) ||
                        valuedcomponenti_cast<Program*>(component));
```

— FALSE for a package — and thereafter changes it only for a written
`paLifetime_Automatic` (`:2296`) or `paLifetime_Static` (in the qualifier loop at
`:2313`). `ElaborationStep::makeVar_`'s tail (`ElaborationStep.cpp:2349-2353`)
then writes

```cpp
    if (sig->isStatic()) obj->VpiAutomatic(false); else obj->VpiAutomatic(true);
```

**Why a PACKAGE ITEM of the very same written form is STATIC.** § 26 already
decoded it and this pass leaves that decode standing: a package item written
`<type-identifier> <name>;` matches **net_declaration** as well as
data_declaration — the user-defined-nettype ambiguity — and Surelog's parser
takes the net one, whose `compileNetDeclaration` (`:2186`/`:2199`) calls
`sig->setStatic()` unconditionally. **Inside a subroutine body that alternative
does not exist**: a block_item_declaration is a data_declaration and nothing
else. The ambiguity is a PACKAGE-ITEM ambiguity, and that single sentence
explains the whole family.

**Why the MODULE's copy carries the same value.** `CompileHelper::importPackage`
(`:127`, Variables arm `:171-181`) copies the package component's registry into
the importing scope wholesale; the module's elaborated variables are then built
from those Signals by `NetlistElaboration::elab_ports_nets_`
(`NetlistElaboration.cpp:2609`) through **the same `makeVar_`**. One Signal, one
`isStatic()`, two objects — which is exactly the value-for-value equality § 2
measured on the golden.

---

## 4. QUESTION 3 — DECODING SLANG, AND THE ONE GATED STAMP

slang declines nothing here; **we were applying a package-item test to a
statement-context declaration.** `emitPackageVar`'s § 26 block computed

```cpp
        netShape26 = dd26.type->kind == syntax::SyntaxKind::NamedType &&
                     !qual26 && !newInit26;
```

from the declaration's `DataDeclarationSyntax` — and a subroutine body local in
slang is a `DataDeclarationSyntax` too, so `uvm_cmdline_processor clp = …` read
as the net shape and came out unmarked. § 203's answer at the PACKAGE call site
had been to stamp every hoisted entry automatic AFTER the fact:

```cpp
                for (size_t i9 = before9; i9 < pvars->size(); i9++)
                    (*pvars)[i9]->VpiAutomatic(true);
```

That is an INFERENCE, it is wrong (§ 5), and it never reached the module's copy
because the module call site does not have it.

**THE LAW IS ONE GATE, IN THE ONE FUNCTION BOTH LISTINGS ALREADY CALL.**
`emitPackageVar` is called by `emitPackage`'s own listing, by its
wildcard-import clone arm, and by `ModuleEmit`'s elaborated materialised-import
listing; the class import copies are `clone_tree` copies of the package
listing's objects (`importVarCopy5`, `ModuleEmit.cpp:4638`), so they inherit the
value rather than deriving one. Gating there fixes all four faces at once.

| file | edit |
|---|---|
| `src/ParamEmit.cpp` | `emitPackageVar`: § 26's net-shape test now applies **only when the declaration's home scope is a `Package`**; otherwise the object carries the SOURCE VARIABLE'S OWN `lifetime`. `emitPkgArrayVar`: the same gate, so a hoisted container carries it too (the package-scope assoc-only split is untouched). `emitPackage`: **both** blanket `VpiAutomatic(true)` post-stamps — the own-listing one and the transitive-clone one — are GONE. |
| `src/ModuleEmit.cpp` | the ONE copy this listing mints itself instead of routing through `emitPackageVar` — the integral-typedef arm's `logic_var` — carries the lifetime here, by the same rule and the same gate. |

The span rule that shares § 26's `netShape26` is **unchanged by construction**:
it reads `netShape26 && ownPkgMember26`, and forcing `netShape26` false outside a
package leaves that conjunction exactly as it was.

**"CARRY THE LIFETIME, DO NOT INFER" IS SAFE HERE, AND GRID ARM G RECORDS WHY.**
Reading slang's `lifetime` could in principle differ from re-deriving from the
written qualifier, because slang resolves a body local's lifetime against the
enclosing subroutine's. For a hoisted constructor local it cannot: **neither
`function static <cls>::new()` nor `function automatic <cls>::new()` is accepted
by either producer** — slang says *"class methods cannot have static lifetime"*
and Surelog raises a syntax error on both spellings — so there is no enclosing
keyword to inherit and the two readings coincide. That arm was written, run, and
could not be built; the fact is kept as a comment in `grid209/g209_g_kinds.sv`.

---

## 5. THE LAW

> **§ `hoistedLocalKeepsItsLifetime209`.** The `vpiAutomatic` of a MATERIALISED
> variable — a package's own listing entry, the clone an importing PACKAGE makes,
> the copy a class inherits from an import, and the copy an importing MODULE's
> elaborated view lists — is the SOURCE VARIABLE'S OWN LIFETIME, carried
> verbatim, never re-derived at the copy.
>
> That lifetime is decided by WHERE THE DECLARATION WAS WRITTEN. A PACKAGE ITEM
> is subject to the net_declaration/data_declaration ambiguity
> § `packageVarAutomaticIsDataDeclShape26` decodes and is STATIC when it matches
> the net shape. A declaration written inside a SUBROUTINE BODY — which is what a
> hoisted out-of-body constructor local is — has no net_declaration alternative
> in the grammar, so it is AUTOMATIC unless the declaration itself is written
> `static`. A module's OWN declarations are static.

**GRID ARM B IS WHAT MAKES THAT A LAW AND NOT A STAMP.** On a real Surelog
golden, in the package's listing AND in both of the module's copies:

```
lb_plain          cb209b        -> vpiAutomatic 1
static  lb_static cb209b        -> vpiAutomatic 0      <== the blanket stamp got this wrong
automatic lb_auto cb209b        -> vpiAutomatic 1
static  lb_int_static  int      -> vpiAutomatic 0
automatic lb_int_auto  int      -> vpiAutomatic 1
```

The pristine binary reads **14 WRONG cells per view** on that arm — 4 in the
package's own listing and 8 in the class import copies where the old blanket
stamp marked `lb_static` automatic, plus 2 in the module copies where `lb_plain`
was left unmarked. The patched binary reads **0**.

---

## 6. QUESTION 4 — THE CENSUS

`cenrows209.sh` + `ct209cen` + `cen209.py` over nine names × both modes, sixteen
comparable row-modes, each scored against its OWN golden (read out of that row's
`cmds.txt`). Two faces: the POSITION-KEYED cells of every listing the judge walks
(`P:` package, `M:all` module DEF view, `M:top` module ELAB view, `C:` class), and
the whole-database variable MULTISET — counted, never a dict, because an import
copy legitimately repeats a face.

```
                          LISTING                              MOVE
row-mode              WRONG pris -> patched   ONLY-G  ONLY-O   W->R  MOVED-WRONG  AWAY
SimpleUVM/default        10  ->  0              0        0      10        0         0
SimpleUVM/testflags      10  ->  0              0        0      10        0         0
SeqDriver/default         5  ->  0             33       33       5        0         0
SeqDriver/testflags       5  ->  0             33       33       5        0         0
Scoreboard/default        0  ->  0              0        0       0        0         0
MiniAmiq/{def,tf}         0  ->  0              0        0       0        0         0
BuildUVMPkg/{def,tf}      0  ->  0              0        0       0        0         0
ApbSlave/{def,tf}         0  ->  0              0        0       0        0         0
ClassExtends/{def,tf}     0  ->  0              0        0       0        0         0
Rggen/default             0  ->  0              0        0       0        0         0
Earlgrey_0_1/{def,tf}     0  ->  0              0        0       0        0         0
-- ROWS=16 SKIP-NOFILE=2 UNKNOWN-NAME=0
-- PATCHED  MOVED-WRONG 0  AWAY 0  WRONG->RIGHT 30
-- LISTING WRONG  pris 30  ->  patched 0
```

The two SKIP-NOFILE row-modes are `Scoreboard/testflags` and `Rggen/testflags`,
which have no golden in this workdir; they are COUNTED, not silently dropped.

**THE FOUR PROTECTED `CMP_EQUAL` ROWS, BOTH COLUMNS, EXPLICITLY:**

```
BuildUVMPkg   default   pris=CMP_EQUAL  patched=CMP_EQUAL  dump 'differ'->'differ'  SAME-ROW
BuildUVMPkg   testflags pris=CMP_EQUAL  patched=CMP_EQUAL  dump 'differ'->'differ'  SAME-ROW
Earlgrey_0_1  testflags pris=CMP_EQUAL  patched=CMP_EQUAL  dump ''      ->''        SAME-ROW
Rggen         default   pris=CMP_EQUAL  patched=CMP_EQUAL  dump 'differ'->'differ'  SAME-ROW
```

and their databases are byte-identical to the pristine ones, as are
`Earlgrey_0_1/default` and `ClassExtends ×2`.

**SeqDriver's five cells are the same family, at one import copy instead of two**
(`work@top_tb`, `#11 clp`, `#23 top`, `#24 cs`, `#25 bld`, `#26 common`), and they
are exactly the five the predictor named before the patch was measured. Its
`ONLY-GOLDEN 33` is unchanged in both directions: that is
§ `oobCtorLocalsRideTheImport203`'s R1 — the transitive wildcard-import clone
`adpcm_pkg` carries that the module hoist does not reproduce — and it is R2 here.

---

## 7. THE GRID

`grid209.sh`, seven arms × two views (`-parse` and `-parse -elabuhdm`), one REAL
Surelog golden per arm-view built by the canonical
`~/git-repos/Surelog/build/bin/surelog` that `scripts/verify_golden.py` itself
names. Calibration is golden-vs-golden and must be perfect.

```
-- CALIB    14 arm-views, AGREE 662, WRONG  0, ONLY-GOLDEN  0, ONLY-OURS 0
-- PRIS     14 arm-views, AGREE 572, WRONG 70, ONLY-GOLDEN 20, ONLY-OURS 0
-- PATCHED  14 arm-views, AGREE 622, WRONG 20, ONLY-GOLDEN 20, ONLY-OURS 0
-- NONZERO RCs: 0
--   NEW-WRONG-CELLS 0   (set difference of the PATCHED and PRIS cell lists,
--                        not inferred from the totals)
```

The grid is the brief's asked-for cross: **source scope × kind × view.**

| arm | what it isolates | patched verdict |
|---|---|---|
| `g209_a_cross` | THE CROSS — one package carrying package-scope declarations of five kinds beside out-of-body constructor locals of the same five (`class_var`, `int_var`, `string_var`, associative `array_var`, plus one nested one level deeper in a `begin`), imported at FILE scope so the module materialises the listing twice, with the module's OWN variables in the same listing | **WRONG 4 → 0** per view, ONLY-GOLDEN 0, ONLY-OURS 0. Every hoisted kind reads 1; `pa_cls` (a bare NamedType package item) reads 0; `mo_cls`/`mo_int` read 0. |
| `g209_b_lifetime` | THE DISTINGUISHER — `static` / `automatic` / plain constructor body locals, `class_var` and `int_var` | **WRONG 14 → 0** per view. This is the arm that refutes "stamp every hoisted local automatic". |
| `g209_c_scopes` | THE SCOPES THAT MUST NOT MOVE — a module's own variables, a TASK-local and a non-`new` out-of-body FUNCTION local (both stop points in `collectObjects_`, so neither hoists), and an IN-BODY constructor | **WRONG 0 → 0**, and the whole-database multiset is IDENTICAL on both binaries. |
| `g209_d_modimport` | the import written INSIDE the module — the law is about what a copy CARRIES, not where the import is written, so this must move exactly as arm A does | **WRONG 1 → 0**; present in the wide boundary's moved list, the second positive control. |
| `g209_e_ctl` | **NEGATIVE CONTROL** — arm A's shape minus the one thing the law names: no out-of-body constructor, so no hoisted local | **PATCHED identical to PRISTINE cell for cell** (AGREE 31, WRONG 0, multiset unchanged) and correctly **ABSENT** from the wide boundary's moved list. |
| `g209_f_pkgpkg` | the TRANSITIVE path — a package that wildcard-imports another, then a module importing THAT (SeqDriver's `adpcm_pkg` shape) | **unchanged, PRIS = PATCHED** (`AGREE 48 WRONG 2 ONLY-GOLDEN 10`). The residue is R2's, not this law's: our module hoist does not follow a transitive import, so its listing is 2 entries where golden's is 12. |
| `g209_g_kinds` | the REMAINING KINDS hoisted — a typedef'd `enum`, a packed-vector typedef, `real`, `bit`, `chandle`, a QUEUE — beside their package-scope twins | **WRONG 14 → 8** per view. The six that cleared are the hoisted `lg_enum`, `lg_vec` and `lg_q` in both module copies. The eight that remain are all ONE package-scope cell, `pg_q` (R1). |

---

## 8. THE PREDICTION

`ct209pred` evaluates the law's own consequence on a PRISTINE database and names
nothing else: a database moves iff one of its module's ELABORATED variable
entries disagrees, on `vpiAutomatic`, with the home package listing entry it is a
copy of — matched by (kind, name, span), which the two share because they are two
objects built from ONE source declaration. Faces that repeat with disagreeing
values are dropped as ambiguous rather than last-writer-wins (RESUME §9's
multiset-join trap).

```
surelog     -- VISITED=956  FIRING=4      {default,testflags} x {SimpleUVM, SeqDriver}
uhdm2rtlil  -- VISITED=1358 FIRING=0
```

and `byteverify.sh` on the patched sweeps returns **MOVERS 4 / 956** and
**0 / 1358**, the same four names. Per database: SimpleUVM `FIRES=10`, SeqDriver
`FIRES=5` — the same counts, and the same five/ten cells by name, that the census
scores.

The one arm this predicate cannot see is a hoisted constructor local written
`static`: that changes the PACKAGE listing itself and no database records the
written qualifier. Grid arm B is the only instance of that shape known to either
corpus, and the mover set equalling the prediction is what confirms it.

---

## 9. THE WIDE BOUNDARY AND THE FLOOR

```
LISTED=5381 PROCESSED=5381 PRODUCED_DBS=5196 MOVED_ARMS=22 RC_DIFFS=0
```

Subdirectory arms are compiled (the file list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, `PROCESSED` is asserted
against `LISTED`). **Four of this pass's seven `grid209/g209_*.sv` are in the
moved list — the POSITIVE CONTROL, without which a green gate would prove
nothing — and `g209_e_ctl`, `g209_c_scopes` and `g209_f_pkgpkg` are correctly
ABSENT.**

Every one of the 22 moved arms was rebuilt with a REAL Surelog golden in BOTH
views and scored (`bscore209.sh`, `BOUNDARY_SCORES.r10uvm209.txt`):

```
-- SCORED views=44 MISSING-ARMS=0 NODB-views=0 TO-GOLDEN=216 AWAY-GOLDEN=0
```

`ONLY-OURS` is **0 → 0 on all 44 views** and `ONLY-GOLDEN` never rises on any of
them. The moved set is one family — every arm in it declares an out-of-body
constructor and materialises its locals somewhere:

* **§ 203's own arms are in it and they moved TOWARD golden**: `g203_a_oob`
  `WRONG 6→0`, `g203_d_dump` `2→0`, `g203_c_mult` `1→0`, both views. The
  brief's floor is "§ `oobCtorLocalsRideTheImport203`'s arms MUST STAY"; they
  stay, with strictly more cells right and none made wrong. Its remaining three
  arms — `g203_b_cont`, `g203_e_ctl` and the packed-struct fence arm
  `g203_f_pkstruct` — are **absent from the moved list**, untouched.
* **§ 206's arms, § 205's arms, § 195's arms, `uvm82-91`, `buvm3-15`, `sd8-12`
  are ALL absent from the moved list**, verified by name against
  `BOUNDARY_MOVERS.r10uvm209.txt`.
* the `r10uvm152` / `r10v152` arms are a hoisted-constructor-local family too and
  they move the same way (`v152_a_collide` `6→0`, `v152_d_shape` `40→23`,
  `g152_d_pos` `15→0`, …), `AWAY 0` on every view.
* **two arms move BYTES with the census AGREE unchanged, and both are named**:
  `r10uvm87repro/v87_a3_oob.sv` and `r10v105repro/v105_b5.sv`. Their whole
  database dump differs by exactly ONE line, `|vpiAutomatic:1`, added to the
  module's materialised copy of an out-of-body constructor local
  (`work@m87a3.l_ctor`, `work@topb5.ctor_l`) — the law's own object on the law's
  own field, matching golden's `vpiAutomatic:1`. Their census cells stay WRONG
  because a DIFFERENT, pre-existing field is wrong there (§ 87's `logic_var`
  vs our `class_var` kind), so `AGREE` cannot rise; nothing went away and their
  multisets are identical before and after.
* `r10uvm152repro/g152_c_home.sv` and `r10v152repro/arms/v152_g_edge.sv` move
  with `AGREE` unchanged and the whole-database variable MULTISET strictly
  improving (`MISSING 14→5, EXTRA 23→14` and `MISSING 12→7, EXTRA 10→5`): those
  are variables living inside a task or function scope, which no listing key
  addresses and the multiset does.

## 10. THE HEAD AFTER — AND R0

```
TEST           MODE      CMPLINES  HEADS      (pristine -> patched)
SimpleUVM      default        86 -> 0     1 -> 0     CMP_NOTEQUAL -> CMP_EQUAL
SimpleUVM      testflags      86 -> 0     1 -> 0     CMP_NOTEQUAL -> CMP_EQUAL
SeqDriver      default/testflags   112    unchanged
Scoreboard     default              95    unchanged
MiniAmiq       default/testflags   112    unchanged
BuildUVMPkg    default/testflags     0    unchanged (CMP_EQUAL)
Earlgrey_0_1   default/testflags     0    unchanged (CMP_EQUAL)
Rggen          default                0    unchanged (CMP_EQUAL)
```

SimpleUVM has no head left: the row is `CMP_EQUAL`. **Five comparable
`CMP_NOTEQUAL` row-modes remain in the surelog corpus** — SeqDriver ×2,
MiniAmiq ×2, Scoreboard/default — plus the four slang-fenced tests, which are
`FENCED=` list only and are not spelled here.

**R0 — SeqDriver ×2, 112 cmp lines, ONE head: A TRANSITIVELY IMPORTED TYPESPEC
CLONE IS NAMED AND INSTANCED AT ITS HOME PACKAGE, NOT AT THE IMPORTER.**
Identical on both binaries, so this pass neither created nor touched it:

```
LHS golden  bit_typespec: (uvm_reg_addr_t), id:236486, line:73:10-73:31
            |vpiParent:   ref_typespec: (adpcm_pkg::uvm_reg_map::m_set_mem_offset::
                                         range::uvm_pkg::uvm_reg_map_addr_range::min::uvm_reg_addr_t)
            |vpiName:     uvm_reg_addr_t
            |vpiInstance: package uvm_pkg
RHS ours    bit_typespec: (uvm_pkg::uvm_reg_addr_t), id:3667, same span
            |vpiParent:   module_inst work@top_tb
            |vpiName:     uvm_pkg::uvm_reg_addr_t
            |vpiInstance: package adpcm_pkg
```

Three fields at once — the NAME (golden unqualified, ours `uvm_pkg::`-qualified),
the `vpiInstance` (golden the DEFINING package, ours the IMPORTING one) and the
`vpiParent` (golden the referring `ref_typespec`, ours the module). It sits on the
same transitive-import face as R2 below and is the natural next head.

## 11. RESIDUES

* **R1 — a package-scope QUEUE written with a KEYWORD element type is
  `vpiAutomatic 1` in golden and 0 in ours.** `emitPkgArrayVar` splits by
  container kind (assoc → 1, queue → 0), which matched the arm it was measured
  on because that arm's queue was written with a bare type IDENTIFIER (the net
  shape). Grid arm G's `int pg_q[$]` is a keyword-typed package item, golden
  reads 1, and eight of arm G's cells are that one declaration seen from four
  listings. It is § 26's rule generalised to `array_var` — a separate law, on a
  package-scope face this pass deliberately did not touch, and untouched here so
  that the CMP_EQUAL rows carrying package array_vars could not move.
* **R2 — the module hoist does not follow a TRANSITIVE wildcard import.** Grid
  arm F: golden's `work@gf209` lists twelve entries (both packages' listings,
  twice), ours lists two. On SeqDriver this is the `ONLY-GOLDEN 33` the census
  reports on both binaries. It is § 203's R1, unchanged.
* **R3 — our objects carry no `VpiFile`.** Judge-invisible
  (no generated `Compare` reads it) but it makes the owner-finder a golden-side
  instrument only, which is why § 2's table is a golden table.
* **R4 — grid arm G's package-scope packed-vector typedef twin is absent from the
  arm on purpose.** Such a declaration is a NET at package scope, so including it
  shifted every later listing position and buried the qualifier cells; the note
  is in the arm's own header.
* **R5 — `Earlgrey_0_1 ×2`'s informational dump column reads `differ` in the
  committed `results/golden_surelog.csv` and EMPTY in both of this pass's
  sweeps.** Status is `CMP_EQUAL` in all four cells. It is present on the
  PRISTINE binary, so it is environment-borne and not this pass's; `ct8rows`
  against this pass's own pristine sweep is therefore the authoritative
  comparison and it reports the SimpleUVM conversion and nothing else.

---

## 12. THE FILES

| file | what it is |
|---|---|
| `ct209cen.cpp` | the variable-listing census + the OWNER-FINDER; position-keyed listing cells and a counted whole-database variable multiset |
| `cen209.py` | scores one census pair; with `--pris`, scores the MOVE (WRONG→RIGHT, MOVED-WRONG, AWAY) |
| `join209.py` | the one-line arm-view scorer the grid and the boundary use |
| `cenrows209.sh` | the census over a NAMED SUBSET of two workdirs, both modes, each row against its OWN golden |
| `ct209pred.cpp`, `pred209.sh` | the pristine-only predictor and its workdir walk |
| `grid209.sh`, `grid209/` | seven arms × two views, real Surelog goldens |
| `bound209.sh`, `bscore209.sh` | the wide boundary and the golden-scored rebuild of every arm it moved |
| `rowheads.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh` | the standing gates, carried unchanged |
| `GATES.r10uvm209.txt` | the full battery, verbatim |
