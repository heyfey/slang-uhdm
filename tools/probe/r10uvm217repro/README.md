# r10uvm217 — § `transitiveImportRidesTheHoist217` — **WHAT A MODULE MATERIALISES FOR A PACKAGE IT IMPORTS IS THAT PACKAGE'S *WHOLE* LISTING, AND A PACKAGE'S OWN LISTING ALREADY CARRIES A CLONE OF EVERY PACKAGE *IT* WILDCARD-IMPORTS — TO ANY DEPTH** — the SeqDriver ×2 1327330-line head fell to **32 lines**, and the module's elaborated listing became golden's exactly

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY** and **NOT EDITED**; **nothing was promoted**
and **NO CORPUS ROW CONVERTED** in either direction. `GOLDEN_DEFER` stayed
unset. The four slang-fenced tests were never dispatched by any driver here;
the corpus predictor walks a sweep workdir that contains them, so `scrub217.sh`
redacts their names out of every artifact — reading the fence list out of
`canaudit.sh` rather than spelling it — and `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `48199935` |
| pristine binary | md5 `967765e2f329aadd3dc15abdb9543676`, built `-j 2` from this pass's OWN worktree at a clean `48199935` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `f70773944aedb3a96fbb0bc1120c4939`, frozen `chmod 555`. The patch applied to a **FRESH `48199935` worktree** (`cmake -DCMAKE_BUILD_TYPE=Release`) and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on, and that fresh rebuild passes `check_goldens.sh` 23/0 too. A COMMENT-ONLY edit to `src/EmitHelpers.h` would change this md5, so the committed text is exactly the text that compiled to `f7077394`. |
| production surface | `src/EmitHelpers.h` ONLY — **+91 / −25 lines, of which 39 are the decoded comment**. `collectImportedPkgVars`'s per-package body becomes one recursive builder with a `seen` set; not one other file, not one new object kind, nothing re-parented, nothing deleted. |
| probe surface | `tools/probe/r10uvm217repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, re-measured on this pass's own pristine build FIRST | **SeqDriver ×2, 1327330 cmp lines / ONE head each** — exactly r10uvm215's R0. Every other row at BASE: SimpleUVM ×2 **0**, Scoreboard/default **0**, MiniAmiq ×2 **838** (the sister pass's head, untouched here), BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. |
| the shape (question 1) | the **VECTOR** overload with BOTH containers named: `module_inst work@top_tb`'s `vpiNet`, golden **224** / ours **191**. The 1327330 lines are the module's own decompile size, printed twice, not a distance. |
| the 33, BY IDENTITY (question 1) | golden's listing is **`[uvm_pkg's 33][uvm_pkg's 33 again][158 implicit wires]`**. Positions 0–32 are the copy for `import uvm_pkg::*`; positions **33–65 are `adpcm_pkg`'s listing — which IS its clone of `uvm_pkg`'s 33**, because `adpcm_pkg` declares no package-scope data of its own. `golden[0:33] == golden[33:66]` face for face, and OUR pristine listing was `[the first 33][the 158]`. |
| the ORDER question, SETTLED FIRST (question 1) | **THE NET VECTOR IS COMPARED POSITIONALLY AND `VpiName` IS ONE OF THE FIELDS.** `BaseClass::SafeCompare`'s vector overload (`BaseClass.h:200-224`) walks index by index, and `nets::Compare` (generated `nets.cpp`) compares `VpiName` outright — so a permutation of a net listing is **not** judge-invisible in general. r10uvm203's R4 called it "judge-INVISIBLE (no ancestor of `logic_net` compares `VpiName`)"; **that reading is wrong and is corrected here** (`DECODE.r10uvm217.txt` carries all four generated `Compare` bodies). What actually hides a permutation is a DIFFERENT mechanism: `logic_net::Compare`'s **first** line is `if (!context->m_visited.insert(this).second) return r;`, and every implicit wire that some class-method `ref_obj::Actual_group` already reached — `design::Compare` walks `AllClasses` (`design.cpp:27`) before `AllModules` (`:31`) — is already visited by the time the module's vector is walked. § 8 R0 is the one wire that is not. |
| the head after | **SeqDriver ×2: 1327330 → 32 cmp lines, ONE head**, and the head is a single `logic_net` pair: golden `work@top_tb.top_tb` (`testbench.sv:234:24`, the `$dumpvars(0, top_tb)` scope-name mint) at the LAST position of the 224-net vector against our `work@top_tb.this` there. **R0.** |
| the law | **CONFIRMED and decoded to Surelog `file:line`.** `CompileHelper::importPackage`'s Nets arm (`CompileHelper.cpp:183-190`) does `scope->getSignals().push_back(net)` into the IMPORTING scope's own vector, and `CompilePackage::collectObjects_` (`CompilePackage.cpp:150/165`) calls it with `scope = m_package`. A package's signal vector is therefore already ENLARGED before any module imports it; the chain composes to any depth. § 4. |
| the census (question 4) | nine UVM databases × both modes, **16 comparable row-modes**, each scored against **its OWN mode's golden**, golden-vs-golden CALIBRATED FIRST in every row (null in all 16). **SeqDriver ×2: AGREE 140 → 206, ONLY-GOLDEN 66 → 0, ONLY-OURS 0 → 0, BAG-ONLY-OURS 0 → 0 — MOVED-WRONG 0 / AWAY 0.** Every one of the other 14 row-modes is **cell-for-cell identical on the two binaries and byte-identical in its database**. § 6. |
| the a-priori prediction (question 5) | written from PRISTINE databases alone: **4 candidate row-modes over 956 surelog databases (SeqDriver ×2 and MiniAmiq ×2), rows with an OURS-LONGER cell 0**, and **0 candidates over 1358 uhdm2rtlil databases**. MiniAmiq's candidate cell is an `interface_inst`, which this law cannot reach (§ 203's R2), so the predicted MOVER set was **SeqDriver default + testflags and nothing else**. § 7. |
| byte movers | **2 / 956** surelog — `SeqDriver` default + testflags, **exactly the two predicted BY NAME**; attributed ORDER-BLIND at **ADDED 1267 / REMOVED 0** dump lines each, every added line under `work@top_tb`, 33 distinct names, the same set in both modes. **0 / 1358** uhdm2rtlil. `Scoreboard`/default did not flip this run. SELFCHECK controls fire at 955/956 and 1357/1358. § 7. |
| the golden grid (question 6) | **6 arms × 2 views = 12 arm-views, one REAL Surelog golden each, 0 NO-DATABASE, 0 nonzero rcs, golden-vs-golden CALIBRATION null in all 12.** AGREE **270 → 490**, ONLY-GOLDEN **226 → 42**, ONLY-OURS **2 → 2**. Arm A's arities become golden's **exactly** at hop depths 1, 2, 3 and 4; arm B closes **totally** in both views; arm F, the must-stay control, is **identical on the two binaries**. § 5. |
| the ONE-SIDED NAME GATE | **a name golden does not hoist never appears.** `namebag217.py`: over the grid's 12 arm-views the name-only one-sided-OURS total is **4 pristine / 4 patched**, over the boundary's 78 re-scored arm-views **6 / 6**, and **ZERO arm-views gained a name** in either. § 9. |
| gates | goldens **23 PASS / 0 FAIL on BOTH binaries**, `/bin/false` control 0/23; uhdm2rtlil **679 / 50 / 2 in BOTH modes on BOTH binaries**, `ct8rows` PASS ×3, `byteverify` **0/1358**; surelog **475/6 default + 469/6 testflags on both binaries**, `ct8rows` patched-vs-COMMITTED-baseline **0 differing rows over 1588**; wide boundary **LISTED 5526 = PROCESSED 5526, RC_DIFFS 0**, every mover re-scored against a real golden at **TO-GOLDEN 72 / unchanged 6 / AWAY 0**; all 20 protected database pins **SAME**. § 9. |

---

## 1. THE HEAD, AND THE PRISTINE BASELINE, MEASURED FIRST

This pass built its own pristine binary from a clean `48199935` worktree; it came
out **byte-identical** to the main tree's binary at that commit. Before a line
was written: `check_goldens.sh` 23 PASS / 0 FAIL with the `/bin/false` control at
23 FAIL; both uhdm2rtlil sweeps 679/50/2 with `ct8rows` PASS against the
committed baseline; the surelog sweep reproducing the committed status histogram
exactly (475/6 + 469/6).

`rowheads.sh` on that sweep, each row against **its own mode's** golden (a test's
default and testflags goldens are different cache entries — RESUME §9):

```
SeqDriver ×2 1327330/1   ·  SimpleUVM ×2 0  ·  Scoreboard/default 0
MiniAmiq ×2 838/1        ·  BuildUVMPkg ×2 0 ·  Earlgrey_0_1 ×2 0 · Rggen/default 0
```

The SeqDriver head (`head_pris_SeqDriver.*.head60.cmp`) is `module_inst
work@top_tb` (`testbench.sv:210`) with **both containers named** — the VECTOR
arm of `BaseClass::SafeCompare` on a SIZE mismatch (`BaseClass.h:206-212`) —
`Nets()` golden **224** against our **191**.

## 2. QUESTION (1) — THE THIRTY-THREE, BY IDENTITY

`ct217net` prints every instance's `Nets()` and `Variables()` vector **in order**,
one line per element, carrying only the judge-visible face. On golden's
`SeqDriver`/default database (`VECTORS.SeqDriver.r10uvm217.txt`):

```
ARITY|def  |module_inst:work@top_tb:            |nets|224
ARITY|elab |module_inst:work@top_tb:work@top_tb |vars| 66
ARITY|pkg  |package:uvm_pkg:uvm_pkg             |vars| 33
ARITY|pkg  |package:adpcm_pkg:adpcm_pkg         |vars| 33
```

`top_tb` (`testbench.sv:210-213`) writes `import uvm_pkg::*;` **and**
`import adpcm_pkg::*;`, both at MODULE scope, i.e. multiplicity 1 each
(§ `collectMaterializedPkgs`). `adpcm_pkg` (`testbench.sv:10-12`) declares no
package-scope data of its own and wildcard-imports `uvm_pkg` — and golden's
`package adpcm_pkg` lists **33** entries all the same. So golden's def-view
module listing decomposes exactly:

```
[0 .. 32]   uvm_pkg's listing            (for `import uvm_pkg::*`)
[33 .. 65]  adpcm_pkg's listing          (for `import adpcm_pkg::*`) — face for
                                          face THE SAME 33, because adpcm_pkg's
                                          listing IS its clone of uvm_pkg's
[66 .. 223] 158 implicit wires, vpiNetType 1
```

measured, not asserted: `golden[0:33] == golden[33:66]` is **True**, and our
PRISTINE 191 is `[0:33]` followed by the 158 (as a set — see § 3). The two
package listings and the interface's 4 nets were **already exact on both sides**;
the whole 33-net shortfall was the module's copy of `adpcm_pkg`.

The ELABORATED view carries the same shortfall in its own vector: golden's
`Variables()` is **66** — the same 33 twice — and ours was **33**.

## 3. QUESTION (1), SECOND HALF — THE VECTOR-ORDER QUESTION, SETTLED BEFORE THE PATCH

**Order matters, and the field table says so.** `BaseClass::SafeCompare`'s vector
overload (`~/.local/include/uhdm/BaseClass.h:200-224`) compares sizes and then
walks **index by index**; `nets::Compare` (`~/git-repos/UHDM/build/generated/src/
nets.cpp`) compares `VpiName`, `VpiNetType`, `VpiImplicitDecl`, `VpiSigned` and
eleven more scalars; `BaseClass::Compare` compares `VpiType`, `VpiName`,
`VpiDefName`. **A permutation of a named net listing is therefore NOT
judge-invisible**, and r10uvm203's R4 — "no ancestor of `logic_net` compares
`VpiName`, so a permutation of typespec-less netType-1 wires compares EQUAL" —
is **corrected here**. All four generated `Compare` bodies are quoted verbatim in
`DECODE.r10uvm217.txt`.

**What actually hides a permutation is `m_visited`.** `logic_net::Compare`'s
FIRST statement is

```cpp
  if (!context->m_visited.insert(this).second) return r;
```

so a golden net the walk has ALREADY reached — through the `ref_obj::
Actual_group` of some class-method reference, and `design::Compare` walks
`AllClasses` (`design.cpp:27`) before `AllModules` (`:31`) — short-circuits to
0 whatever it is paired with. That is why SimpleUVM, whose implicit block our
census reads at **POSDIFF 157 on BOTH binaries** (§ 6), is nevertheless
`CMP_EQUAL` with **0 heads**.

**Measured on SeqDriver, before the patch existed** (`VECTORS.SeqDriver.
r10uvm217.txt`): golden's implicit block `[66:224]` and ours are the **SAME
MULTISET** (158 = 158, one-sided sets empty both ways) in a **different order**
(158 of 158 positions differ, ours starting `m_name`, golden's
`use_uvm_seeding`). So the prediction written before the patched sweep was:
*the vector's SIZE will match at 224, positions 0–65 will agree, and the head
will move to whichever implicit wire the `m_visited` short-circuit does not
cover.* It did, and there is exactly one: **`top_tb`**, minted for
`$dumpvars(0, top_tb)` at `testbench.sv:234` — a scope name no listing carries,
referenced only from the module's own `initial` process, which
`module_inst::Compare` reaches AFTER `Nets()`. § 8 R0.

## 4. QUESTION (2) — DECODING SURELOG: THE TRANSITIVE CLOSURE ROAD

**There is no closure walk in Surelog. The importing package's REGISTRY is
enlarged, and every later importer copies the enlarged one.**

`CompileHelper::importPackage` (`src/DesignCompile/CompileHelper.cpp:127`) copies
the imported package's registries into `scope`'s own:

| arm | `CompileHelper.cpp` | writes into | duplicates? |
|---|---|---|---|
| Typespecs | `:162-168` | `scope->insertDataType` | map, de-dups |
| **Variables** | `:170-181` | `scope->addVariable(var.second)` → `m_variables` | `std::map<std::string,…>` (`DesignComponent.h:97`) — **de-dups by NAME** |
| **Nets** | `:183-190` | `scope->getSignals().push_back(net)` | **a `std::vector` — ACCUMULATES** |
| Incomplete bindings | `:192-197` | `scope->needLateBinding` | — |

and `CompilePackage::collectObjects_` calls it with **`scope = m_package`**
(`src/DesignCompile/CompilePackage.cpp:150` for the file-local imports and
`:165` for the `paPackage_import_item` reached in the item walk). So a package
that wildcard-imports another ends its own compilation holding that package's
signals in its own signal vector.

**Every listing the judge sees is built from that SIGNAL VECTOR, not from the
name-keyed map** — which is why the copies repeat instead of collapsing:

* the package's own listing — `writePackage` runs
  `orig_nets = pack->getSignals()` (`UhdmWriter.cpp:1292-1301`) and takes its
  `Variables()` from `netlist->variables()`, which
  `NetlistElaboration::elaboratePackages` builds by `elabSignal`-ing
  `pack->getSignals()` (`NetlistElaboration.cpp:115`);
* the module's DEF view — `writeModule` runs
  `writeNets(mod, mod->getSignals(), …)` with `instance == nullptr`, minting a
  fresh `logic_net` per vector ENTRY (`UhdmWriter.cpp:812-830`, `:1458-1461`);
  its `Variables()` line is commented out (`:1468`), which is why golden's
  def-view module has `Variables()` **NULLVEC**;
* the module's ELAB view — `writeElabModule` takes `m->Variables(netlist->
  variables())` (`UhdmWriter.cpp:4076`), and `NetlistElaboration::elab_signals_`
  builds that from `comp->getSignals()` (`NetlistElaboration.cpp:2667`).

**The chain composes.** For a three-package chain `R -> Q -> P`, `Q`'s vector
holds `R`'s entries when `P` imports `Q`, so `P`'s vector holds both, and a
module importing `P` materialises all of them — once per import copy. Grid arm A
measures depths 1, 2, 3 and 4 on real Surelog goldens and golden's module
arities read **3, 5, 6, 7** exactly as that predicts (§ 5).

## 5. QUESTION (3) — DECODING SLANG, AND THE ONE GATED EXTENSION

slang declines nothing here. `collectImportedPkgVars` (`src/EmitHelpers.h`) was
walking the imported package's `members()` and **stopping**:

```cpp
    for (auto& pm : pkg->members())
        if (pm.kind == SymbolKind::Variable) { flush203(pm.location,false); … }
```

A `WildcardImport` member was simply not a case. `emitPackage` (`ParamEmit.cpp`,
`impVars9`) has had the recursive form since r10uvm3 — which is exactly why our
`package adpcm_pkg` listing was **already 33 and already right** while the
module's copy of it was **0**.

The edit makes the two agree, term for term with `impVars9`:

* the per-package body becomes a recursive `listing217(p, seen, root, out)`;
* on a `WildcardImport` member it recurses into the imported package, guarded by
  one `std::set<const PackageSymbol*>` per home package, seeded `{P}` — a cycle
  or a diamond cannot clone twice, which is `impVars9`'s `seen9{&pkg}` exactly;
* the **outermost** hop flushes the hoisted out-of-body constructor locals that
  precede the import ITEM's own source slot before splicing the clone in, and
  the deeper hops do not — again `impVars9`, because the module's copy of `P`
  must be `P`'s listing and not a second opinion about it;
* **the LIFETIME carry is untouched.** § `hoistedLocalKeepsItsLifetime209`'s rule
  lives in `emitPackageVar` and in the integral-typedef arm's
  `ownPkgMember209` test (`ModuleEmit.cpp`), both downstream of this list; the
  transitive entries are `VariableSymbol`s of their HOME package and reach those
  sites unchanged, so a hoisted local still carries its own `vpiAutomatic` and a
  package member still stays unmarked. Grid arm C's `c0_q`/`c0_dyn` cells read
  the same on the deep module as on the one-hop control, on both binaries.
* **the AMBIGUITY FENCE is untouched.** § `importedClassTsRideTheFileUnit206`
  publishes `design->Typespecs()` from the file-unit's DataTypeMap and its
  de-dup-by-object / alphabetically-first-key rule; this pass writes no typespec
  key and no design-level vector. `BuildUVMPkg ×2`, `ClassExtends ×2`,
  `Scoreboard`/default and `SimpleUVM ×2` — every row § 206's predictor named —
  are **byte-identical databases on the two binaries** (§ 7).

### THE LAW

> **§ `transitiveImportRidesTheHoist217`.** What a module materialises for a
> package it wildcard-imports is **that package's OWN listing**, and a package's
> own listing already carries a CLONE of the whole listing of every package
> **it** wildcard-imports — spliced at the import item's source slot, once per
> home package however many roads reach it, to any depth. The module's copy is
> that listing verbatim, repeated once per import copy; it inherits the
> package listing's residues along with its content, because it IS that listing.

## 6. QUESTION (3) — THE GOLDEN GRID

`grid217.sh` + `grid217/`, six arms × two views (`-parse -d coveruhdm
-nobuiltin -nocache`, then again with `-elabuhdm`), one REAL Surelog golden per
arm-view built by the canonical `~/git-repos/Surelog/build/bin/surelog` that
`scripts/verify_golden.py` itself names, every rc recorded, **BOTH binaries'
databases built in every cell**. The per-arm `uhdm-cmp` verdict is RECORDED and
is **NOT** the scorer (r10uvm210's caution: `-nobuiltin` makes golden's
`AllPackages` one entry shorter than ours, so every arm's head is that vector
mismatch). The scorer is the POSITION-KEYED listing census `ct217net` +
`cen217.py`, keyed `<view>|<kind>:<defname>:<instname>|<vector>`, golden-vs-golden
CALIBRATED FIRST (**null in all 12**). Transcript: `GRID.r10uvm217.txt`.

```
-- 12 arm-views   NO-DATABASE 0   CALIB non-null 0   nonzero rcs 0
   PRISTINE  AGREE 270  POSDIFF 174  ONLY-GOLDEN 226  ONLY-OURS 2
   PATCHED   AGREE 490  POSDIFF 138  ONLY-GOLDEN  42  ONLY-OURS 2
```

| arm | what it varies | verdict |
|---|---|---|
| **A** `a_hops` | **THE LAW — HOP DEPTH.** `pa0` (own data) ← `pa1` (own data before AND after its import) ← `pa2` ← `pa3`, and five modules: a one-hop control and importers at depth 2, 3, 4, plus one importing both ends of a chain | golden's module arities are **3 / 5 / 6 / 7 / 7**; pristine reads **3 / 3 / 2 / 2 / 5**, patched reads **3 / 5 / 6 / 7 / 7 — golden's exactly, in BOTH views**, with `BAG-ONLY-GOLDEN 0` and `BAG-ONLY-OURS 0` in every cell: the CONTENT is golden's, name for name and face for face |
| **B** `b_views` | **THE VIEW AND MULTIPLICITY CONJUNCT** — a file-scope import (×2) of a package that itself imports another, plus a module adding a module-scope import of the same package (×3) and one adding a module-scope import of the DEEPER package | **7/28 → 57 AGREE, POSDIFF 0, ONLY-GOLDEN 0, ONLY-OURS 0 — TOTAL closure in both views** |
| **C** `c_kinds` | **WHAT RIDES THE DEEP HOP, BY KIND** — int, string, a typedef'd packed vector, a class handle, the three DYNAMIC containers, the unpacked aggregate both producers decline, and the HOISTED body locals of an out-of-body constructor, reached through one extra hop, against a ONE-HOP CONTROL | the deep module's def cell goes **1/12 → 10/12** and its elab cell **1/11 → 10/11**, and every residue it has left is **the residue the one-hop control shows on BOTH binaries** — the declined `int c0_fixed[4]` (§ 203 R3) and the `vpiAutomatic` face of a package-scope queue/dynamic array (§ 209 R1). The one exception is a NEW residue this arm decoded and named: § 8 R2 |
| **D** `d_importer` | **THE IMPORTER KIND** — the same two-package chain reached from a module, an interface and a program | the MODULE cell CLOSES (4/4, gone from the differing-cell list in both views); the PROGRAM cell agrees on both binaries; the INTERFACE cell is **1/4 on BOTH binaries** — § 203's R2, our hoist is called from the module emitters only. RECORDED, not claimed |
| **E** `e_shapes` | **THE SHAPES THAT COULD DOUBLE OR LOOP** — a diamond (`pe1` and `pe2` both import `pe0`, `pe3` imports both), a module importing both arms of the diamond, and an EXPLICIT single-symbol import mid-chain | `ge_twoarms` **3/7 → 7/7, CLOSED**; `ge_diamond` **2/8 → 6/8**, and the two it still lacks are **`package pe3`'s own two, which are missing on the PRISTINE binary too** (`pkg pe3 nets G=2 O=0`, identical on both binaries); `ge_explicit` **2/3 on both binaries**, mirroring `pkg pe4 G=2 O=1`, identical on both. The module's copy is the package's listing, residues included |
| **F** `f_muststay` | **THE MUST-STAY CONTROL** — § 203's own shape (own data + an out-of-body constructor with a nested `begin`) at multiplicity 2 and 3, with NO transitive import anywhere | **PATCHED IDENTICAL TO PRISTINE**, both views: AGREE 60, POSDIFF 0, ONLY-GOLDEN 0, ONLY-OURS 1 on both. It is correctly **ABSENT** from the wide boundary's moved list |

**THE ORDER RESIDUE ARM A EXPOSES, AND WHY IT IS NOT THIS PASS'S.** Arm A's
POSDIFF rises 32 → 42 while its one-sided sets fall to zero. The reason is
printed on the arm's own PACKAGE cells, which are **identical on the two
binaries**: golden's `package pa1` listing is `[a0_own0, a0_own1, a1_pre,
a1_post]` and ours is `[a1_pre, a0_own0, a0_own1, a1_post]` — Surelog puts the
imported block at the **FRONT** (`CompilePackage.cpp:140-151` runs every
`paPackage_import_item` of the file BEFORE the item walk that collects the
package's own data declarations), while `emitPackage`'s `impVars9` splices it at
the import's SOURCE slot. That is a PACKAGE-listing law, it is wrong on the
pristine binary too, and the module's copy inherits it precisely because the law
above says it must. § 8 R1.

## 7. QUESTION (4) — THE CORPUS CENSUS, AND (5) THE PREDICTION

**The census.** `cenrows217.sh` + `ct217net` + `cen217.py` over nine UVM
databases × both modes — **16 comparable row-modes**, each scored against **that
row's OWN mode's golden**, read out of that row's OWN `cmds.txt`. Two SKIP-NOFILE
row-modes (`Scoreboard`/testflags and `Rggen`/testflags, which have no database
in this workdir) are COUNTED, not dropped. `CENSUS.r10uvm217.txt`.

```
row-mode              CALIB      PRISTINE                    PATCHED                     bytes
SeqDriver   ×2        null       AGREE 140 ONLY-G 66 ONLY-O 0  AGREE 206 ONLY-G 0 ONLY-O 0  MOVED
SimpleUVM   ×2        null       AGREE 190 ONLY-G  0 ONLY-O 0  (identical)                  SAME
Scoreboard  /default  null       AGREE  55 everything else 0   (identical)                  SAME
MiniAmiq    ×2        null       AGREE  66 ONLY-G 66 ONLY-O 0  (identical)                  SAME
BuildUVMPkg ×2        null       AGREE  26 everything else 0   (identical)                  SAME
ApbSlave    ×2        null       AGREE  67 everything else 0   (identical)                  SAME
ClassExtends×2        null       (no listing cells)            (identical)                  SAME
Earlgrey_0_1×2        null       3374 cells, AGREE 32756       (identical)                  SAME
Rggen       /default  null       116 cells, AGREE 1164         (identical)                  SAME
-- ROWS=16 SKIP-NOFILE=2 UNKNOWN-NAME=0
-- MOVED-WRONG 0   AWAY 0   ONLY-OURS 0 before and after on every row
```

`Earlgrey_0_1`'s 3374 calibration cells and 32757 golden-vs-golden agreements are
what make its "identical" mean something. **MiniAmiq's `ONLY-GOLDEN 66` is
unchanged in both directions** — it is § 203's R2, the INTERFACE half
(`work@svaunit_vpi_interface`, golden 71 nets / ours 5), and the sister pass's
row is untouched: its databases are byte-identical on the two binaries.

**The prediction, from PRISTINE databases alone.** `pred217.py` reads OUR
pristine database and asks whether it holds a package whose own listing is
ENLARGED — some other package's whole listing present in it as a bag subset —
because `emitPackage` already emits the transitive clone at package scope. It is
an UPPER BOUND by construction: a database it calls CLEAN cannot move. For every
candidate it then loads that row's OWN golden and classifies the module/interface
listing gap.

```
surelog:     rows scanned=956   CANDIDATES (upper bound)=4   rows with an OURS-LONGER cell=0
  FIRE SeqDriver default   def module nets  G=224 O=191 gap=+33 FITS-CLONE
                           elab module vars G= 66 O= 33 gap=+33 FITS-CLONE
  FIRE SeqDriver testflags  (identical)
  FIRE MiniAmiq  default   defif interface nets G=71 O=5 gap=+66 FITS-CLONE
  FIRE MiniAmiq  testflags  (identical)
uhdm2rtlil:  rows scanned=1358  CANDIDATES=0
```

MiniAmiq's only candidate cell is an `interface_inst`, which this law does not
reach (grid arm D, § 203 R2), so the predicted MOVER set was **SeqDriver default
+ testflags, and nothing else** — and that is exactly the moved set:

```
byteverify surelog:  MOVERS 2 / 956   (SELFCHECK control 955/956)
   ./default/SeqDriver-…/slang.uhdm
   ./testflags/SeqDriver-…/slang.uhdm
byteverify uhdm2rtlil: MOVERS 0 / 1358  (SELFCHECK control 1357/1358)
```

**Attribution, ORDER-BLIND** (both dumps path-normalised and sorted, RESUME §6):
**ADDED 1267 / REMOVED 0** lines per mode, identical line set in the two modes;
**every added line is under `work@top_tb`** (0 added `vpiFullName` lines name
anything else), over **33 distinct names**, and the counted heads of the added
block are `33 × |vpiNet:` (the def view) and `33 × |vpiVariables:` (the elab
view). Nothing was removed anywhere.

## 8. RESIDUES

* **R0 — THE IMPLICIT-WIRE BLOCK'S ORDER, AND THE ONE WIRE THE JUDGE CAN SEE.**
  SeqDriver ×2 now stop at **32 cmp lines, ONE head**: golden's
  `logic_net work@top_tb.top_tb` (`testbench.sv:234:24`, `vpiNetType 1`) at the
  LAST of the 224 net slots against our `work@top_tb.this` there. Golden's and
  our 158-wire implicit block are the **same multiset in a different order**
  (§ 3), but `logic_net::Compare`'s `m_visited` short-circuit covers 157 of them
  — they are reached first through the class-method `ref_obj::Actual_group`
  edges — and the `$dumpvars(0, top_tb)` scope-name mint is the one that is not,
  because nothing in a class body references it. The next head is therefore
  **one object**, and the law it wants is the ORDER in which
  `UhdmWriter::lateBinding` mints (golden appends the module's own
  system-call scope name after the whole forwarded package late-binding list;
  we put it second to last). `head_pat_SeqDriver.*.cmp` carry both logs in full.
* **R1 — A PACKAGE'S IMPORT CLONE BELONGS AT THE FRONT OF ITS LISTING, NOT AT
  THE IMPORT'S SOURCE SLOT.** Grid arm A: golden's `package pa1` reads
  `[a0_own0, a0_own1, a1_pre, a1_post]` where ours reads
  `[a1_pre, a0_own0, a0_own1, a1_post]`, and `pa3` the same way. Surelog imports
  every `paPackage_import_item` of the file BEFORE the item walk collects the
  package's own data declarations (`CompilePackage.cpp:140-151`). It is
  **identical on both binaries** and it is `emitPackage`'s `impVars9`, not this
  function; this pass deliberately did not touch the package side, so that the
  module's copy could not disagree with it and so that no CMP_EQUAL row carrying
  a package listing could move. It costs nothing on the corpus today
  (`adpcm_pkg` and `uvm_pkg` have no own data declarations before their imports).
* **R2 — `bindHoistedClassPropRefs` STOPS ONE HOP SHORT TOO.** Grid arm C,
  measured on a real golden: golden mints the implicit wire `c0_prop` in the
  DEEP module `gc_deep` exactly as it does in the one-hop `gc_near`, and we mint
  it only in `gc_near` — `bindHoistedClassPropRefs` (`ModuleEmit.cpp`) tests
  `cpr.homePkg` against `collectMaterializedPkgs(body)`, which is the DIRECT
  import set. It is a different emitter (the § 107 / § 117 implicit-wire family,
  not the listing), it is invisible on the corpus today (SeqDriver's implicit
  block is already golden's exact multiset), and extending it would change which
  nets get MINTED — so it is named here with its golden, not taken.
* **R3 — THE INTERFACE HALF IS STILL MISSING ENTIRELY.** Grid arm D's `gd_if`
  reads 1 of golden's 4 on BOTH binaries, and MiniAmiq ×2's
  `work@svaunit_vpi_interface` reads 5 of golden's 71 on both.
  `collectImportedPkgVars` is called from the module emitters only. § 203's R2,
  unchanged and untouched — MiniAmiq is the sister pass's row.
* **R4 — `Earlgrey_0_1/testflags`'s informational dump column.** This pass's
  PRISTINE sweep reports it EMPTY where the committed `results/golden_surelog.csv`
  and this pass's PATCHED sweep both report `differ`; the STATUS is `CMP_EQUAL`
  in all three and **the two databases are byte-identical** (`protdb217.sh`,
  md5 `92bf7b7facdc` on both). It is the recorded uhdm-dump timeout flake
  (r10uvm197 / 199 / 201 / 209 / 215 all logged the same cell); `ct8rows`
  patched-vs-COMMITTED-BASELINE reads **0 differing rows over 1588**.
* **R5 — A CORRECTION TO r10uvm203's R4, not a residue of this pass.** "A
  permutation of typespec-less netType-1 wires compares EQUAL because no
  ancestor of `logic_net` compares `VpiName`" is false: `nets::Compare` compares
  `VpiName`. What makes SimpleUVM's 157-position permutation invisible is
  `m_visited`, and the distinction is what predicted this pass's new head
  correctly (§ 3).

## 9. QUESTION (6) — THE GATES, AND THE BOUNDARY

Full transcript in `GATES.r10uvm217.txt`; the wide boundary in
`BOUNDARY.r10uvm217.txt` + `BOUNDARY.movers.r10uvm217.txt` +
`ARMSCORE.r10uvm217.txt` + `FALSEMOVERS.r10uvm217.txt` + `NAMEBAG.r10uvm217.txt`.

| gate | result |
|---|---|
| goldens | **23 PASS / 0 FAIL on BOTH binaries**, `SLANG_UHDM` exported explicitly per binary; `/bin/false` negative control **0 PASS / 23 FAIL** |
| uhdm2rtlil | **679 / 50 / 2 in BOTH modes on BOTH binaries**; `ct8rows` PASS against the committed baseline AND against this pass's own pristine in both modes; **all 2924 `cmds.txt` audited BY BINARY PATH** (1462 pristine-wd → `pris.bin`, 1462 patched-wd → `pat.bin`, one distinct path each) |
| uhdm2rtlil bytes | `byteverify` **MOVERS 0 / 1358**, SELFCHECK control 1357/1358 |
| surelog rows | **475/6 default + 469/6 testflags on BOTH binaries — NO ROW CONVERTED in either direction.** `ct8rows` PATCHED vs the committed `results/golden_surelog.csv`: **0 differing ROWS over 1588**. Patched vs this pass's own pristine: exactly one differing row-SIDE, `Earlgrey_0_1/testflags`, CMP_EQUAL on both, dump column only, byte-identical databases (R4). All 3146 `cmds.txt` audited by binary path |
| surelog bytes | `byteverify` **MOVERS 2 / 956**, SELFCHECK control 955/956 — **SeqDriver default + testflags, the two predicted BY NAME**, attributed ORDER-BLIND at ADDED 1267 / REMOVED 0, all under `work@top_tb` |
| the protected CMP_EQUAL row-modes | `BuildUVMPkg ×2`, `SimpleUVM ×2`, `Earlgrey_0_1 ×2`, `Scoreboard`/default — and, scored with them, `Rggen`/default — **CMP_EQUAL at judge rc = 0 with 0 heads on BOTH binaries, both columns scored explicitly, and NONE of them is a byte mover.** The only column movement anywhere is R4's |
| canaries | surelog vs the committed baseline **ok=52 changed=0**; surelog vs this pass's own pristine ok=51 changed=1 (R4, named); u2r **ok=8 changed=0**; `ctcan2` PASS on both corpora; `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected databases | all **20** name×mode pins **SAME**, including `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, and the two literal pins `SVSwitch 4842211c4030` / `YosysVerx 6ccda350c24a` |
| wide boundary | **LISTED 5526 = PROCESSED 5526**, PRODUCED_DBS 5333, **RC_DIFFS 0**, MOVED_ARMS 39. **Five of this pass's six grid arms are in the moved list — the POSITIVE CONTROL — and `g217_f_muststay.sv` is correctly ABSENT.** |
| every mover re-scored | `armscore217.sh` rebuilt a REAL Surelog golden for **all 39** movers in **BOTH views** — **ARM-VIEWS SCORED 78, NOT-SCORED 0, CALIB non-null 0** — and scored them: **TO-GOLDEN 72, census-unchanged 6, AWAY 0.** Totals AGREE **686 → 1460**, ONLY-GOLDEN **684 → 232**, ONLY-OURS **4 → 4** |
| the ONE-SIDED NAME GATE | `namebag217.py`: name-only one-sided-OURS **4 → 4** over the grid's 12 arm-views and **6 → 6** over the boundary's 78, **0 arm-views gained a name** in either. Not one name golden does not hoist appears anywhere |
| the FLOOR, by name against `BOUNDARY.movers.r10uvm217.txt` | § `oobCtorLocalsRideTheImport203` (`r10uvm203repro`) **0**; § `importedClassTsRideTheFileUnit206` (`r10uvm206repro`) **0**; § `modportNeedsSimplePort215` (`r10uvm215repro`) **0**; sd8–12 **0**. § `hoistedLocalKeepsItsLifetime209` **1** — `grid209/g209_f_pkgpkg.sv`, uvm209's OWN R2 arm and literally this law's shape: AGREE **11 → 35**, ONLY-GOLDEN **21 → 1**, ONLY-OURS **0 → 0**, both views. uvm82–91 **1** — `r10uvm88repro/g88_a1_scope.sv`: AGREE **40 → 54**, ONLY-GOLDEN **10 → 0**, ONLY-OURS **0 → 0**. buvm3–15 **2** — `r10buvm13repro/{a4_clone13,v3_clone13}.sv`: AGREE **3 → 13** and **2 → 6**, ONLY-GOLDEN **4 → 0** and **2 → 0**, everything else 0 |

**THE THREE STATIC-ADDRESS FALSE MOVERS, CONVICTED NOT ASSUMED.**
`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv` and
`r10uvm185repro/grid185/g185_e_kinds.sv` are the three arms whose listing census
is **byte-for-byte identical on the two binaries in both views**. Their whole
database difference is the same pair of 64-bit constants —
**`22744825` / `22743969` pristine against `22740729` / `22739873` patched, each
pair exactly 4096 apart**, the one page by which the patched binary's static
addresses moved (22 589 784 → 22 588 304 bytes) — and **every differing line sits
BELOW the dump's `\_weaklyReferenced:` marker**, which the judge cannot reach
(line 5118 vs marker 4357; 679 vs 646; 2931 vs 2690). Full diffs in
`FALSEMOVERS.r10uvm217.txt`. These are the same three arms and the same two
constants r10uvm215 recorded.

## 10. THE FILES

| file | what it is |
|---|---|
| `ct217net.cpp` | THE INSTRUMENT: every instance's / package's `Nets()` and `Variables()` vector printed **in order**, one line per element, judge-visible face only. Uses the RESTORE HANDLE's design, as `uhdm-cmp` does. |
| `cen217.py` | THE SCORER: the POSITION-KEYED join, with a counted MULTISET face beside it so a MISSING block and a MISORDERED one cannot be confused. |
| `namebag217.py` | the ONE-SIDED **NAME** gate over a tree of census triples (§ 9). |
| `pred217.py` | question (5): the a-priori mover prediction from PRISTINE databases alone (an upper bound by construction). |
| `grid217.sh`, `grid217/` | question (3): the golden grid, six arms × two views, both binaries in every cell. |
| `cenrows217.sh` | question (4): the corpus census over named rows, each against its OWN mode's golden. |
| `DECODE.r10uvm217.txt` | the four generated `Compare` bodies that settle the order question, quoted verbatim. |
| `VECTORS.SeqDriver.r10uvm217.txt` | question (1): the 33 by identity, the two-block decomposition, and the implicit block's multiset-vs-order measurement. |
| `GRID.r10uvm217.txt`, `CENSUS.r10uvm217.txt`, `PREDICT.*.r10uvm217.txt` | the transcripts for §§ 6–7. |
| `GATES.r10uvm217.txt`, `BOUNDARY.r10uvm217.txt`, `BOUNDARY.movers.r10uvm217.txt`, `ARMSCORE.r10uvm217.txt`, `FALSEMOVERS.r10uvm217.txt`, `NAMEBAG.r10uvm217.txt` | question (6). |
| `head_pris_SeqDriver.*.head60.cmp`, `head_pat_SeqDriver.*.cmp` | the head on both binaries (the pristine logs are 1.3 M lines — the module's decompile — so the first 60 lines are kept). |
| `armscore217.sh`, `protdb217.sh`, `bound217.sh`, `scrub217.sh` | the boundary re-score, the protected-database pins, the wide boundary, the fence scrub. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged. |

## 11. HOW TO REPRODUCE

```bash
git worktree add /tmp/wt_r10uvm217 48199935
cd /tmp/wt_r10uvm217 && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 2
cp build/slang-uhdm /tmp/pris && chmod 555 /tmp/pris        # md5 967765e2…
git apply /tmp/r10uvm217.patch && cmake --build build -j 2
cp build/slang-uhdm /tmp/pat && chmod 555 /tmp/pat          # md5 f7077394…
cd tools/probe/r10uvm217repro
g++ -O2 -std=c++17 ct217net.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o ct217net                          # NOT committed: 5.7 MB, seconds to build
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=$PWD/ct217net PY=$PWD/cen217.py \
  bash grid217.sh $PWD/grid217 /tmp/gs /tmp/GRID.txt         # the grid
python3 namebag217.py /tmp/gs                                # the one-sided NAME gate
python3 pred217.py <a PRISTINE sweep workdir> ./ct217net /tmp/PRED.txt
CEN=$PWD/ct217net PY=$PWD/cen217.py \
  bash cenrows217.sh <pristine wd>/sl <patched wd>/sl /tmp/CEN.txt \
       SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg ApbSlave ClassExtends Earlgrey_0_1 Rggen
PRIS=/tmp/pris PATCHED=/tmp/pat bash bound217.sh <a COPY of tools/probe> /tmp/bd
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=$PWD/ct217net PY=$PWD/cen217.py \
  bash armscore217.sh /tmp/bd/MOVERS <that copy> /tmp/bs /tmp/ARMSCORE.txt
python3 namebag217.py /tmp/bs
bash scrub217.sh <any artifact that walked a sweep workdir>   # then canaudit
```

The probe binary is NOT committed (5.7 MB, rebuilds in seconds from the
committed source).
