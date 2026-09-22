# r11u99 — the interface fall-through reaches the design root, and the nested module gets its outer's name

**EIGHT GATED LAWS, TWO FACES, ONE BATCH — the brief's LAW A (pass 96's R1,
the interface that fell through to the module path) and LAW B (pass 96's R2,
the nested module zone), LAW B split into the SIX distinct producer rules it
turned out to be.**

**LAW A — AN INTERFACE IS NOT A CLASS HOME, ON THE MODULE PATH EITHER.
A1 § `caIfaceClassRootAnyIface99`: the design-root class publication is keyed
on `isInterface()`, not on `useInterfacePath`.
A2 § `caIfaceBodyClassNotModuleOwn99`: `emitModuleDef`'s unconditional
body-class push declines on an interface home, symmetric to pass 96's landed
generate-face guard § `caModGenClassNotIfaceHome98V`.
LAW B — A MODULE DECLARED INSIDE A MODULE IS `work@<outer>::<inner>`, IS NOT
AN INSTANTIATION, IS NOT A CLASS HOME, AND IS PUBLISHED ONE LEVEL DEEP.
B1 § `caNestedModDefNameScoped99` — the scoped definition name (and the
name-sorted `uhdmallModules` slot that follows from it).
B2 § `caNestedModDeclNoRefNoInst99` — no def-view `ref_module`, no elaborated
`module_inst`: slang implicitly instantiates a portless, parameterless nested
module and Surelog does not.
B3 § `caNestedModNoClassHome99` — a nested module's def view lists NO classes.
B4 § `caNestedModDeepNoDefView99` — a module nested TWO levels deep gets no
def view at all.
B5 § `caNestedModRefNoActual99` — a written `ref_module` naming a nested
module resolves to NOTHING: its defname is the bare `work@<inner>` while the
definition is filed under `work@<outer>::<inner>`.
B6 § `caNestedModDefParentIsOuter99` — the nested def view is parented on the
OUTER DEF, not on the design.**

Base commit `9002f74a`, pins per `SUPPORT_MATRIX.md` (slang upstream
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 at
`~/git-repos/Surelog/build/bin/surelog` — the canonical golden producer
`scripts/verify_golden.py` names — uhdm2rtlil corpus v0.68).

| binary | md5 | what |
|---|---|---|
| pristine | `534aa1d5c630bc1530e15a30341eb6fa` | built in this pass's OWN worktree at `9002f74a`, `-j 2`, md5 taken separately — **`cmp`-identical to the main tree's `build/slang-uhdm` at `9002f74a` and to the OPS pin**, compared with `cmp`, not assumed |
| law | `d9003cec9637a44d06f9d8daa9a235d6` | this patch |

Both frozen `chmod 555` at immutable paths before any sweep.  Every
`cmds.txt` audited by ABSOLUTE binary path: 3323 per workdir, 3273 `slang:`
invocations, **3273 name the frozen binary that sweep was meant to run and 0
name the main tree's `build/slang-uhdm`**, in each of the two workdirs.
`src/ParamEmit.cpp`, `src/EmitHelpers.h` and `src/ExprEmit.cpp` are UNTOUCHED
(the sister pass's ground).  `results/*.csv` never written.

---

## 1. THE WITNESSES AT `9002f74a`, PER SLOT

`tools/probe/r11v98repro/grid/{v27,v28,v29}`, re-run in this pass's own
worktree with this pass's own binaries.  The judge line counts are quoted
beside the SLOT-KEYED class scores from `r11u98repro/classcell98.py`, which is
the arbiter for every class face (§3).

| arm | cmp lines pris -> law | CELL OK | CELL GOLD-ONLY | CELL OURS-ONLY |
|---|---|---|---|---|
| `v27_ifacenestinst` | 260 -> 539 | 0 -> **1** | 1 -> **0** | 0 -> 0 |
| `v28_ifacenestbody` | 252 -> 514 | 0 -> **2** | 2 -> **0** | 2 -> **0** |
| `v29_modinnerdecl` | 59 -> **0** | 2 -> 2 | 0 -> 0 | 2 -> **0** |

The cells, quoted:

```
v27 pris   CELL-GOLD-ONLY  ROOT|uhdmallClasses[0]=work@Cgen
v28 pris   CELL-GOLD-ONLY  ROOT|uhdmallClasses[0]=work@Abody
           CELL-GOLD-ONLY  ROOT|uhdmallClasses[1]=work@Zbody
           CELL-OURS-ONLY  module_inst:work@outer|vpiClassDefn[0]=work@outer::Abody
           CELL-OURS-ONLY  module_inst:work@outer|vpiClassDefn[1]=work@outer::Zbody
v29 pris   CELL-OURS-ONLY  module_inst:work@innermod|vpiClassDefn[0]=work@innermod::Ainner
           CELL-OURS-ONLY  module_inst:work@innermod|vpiClassDefn[1]=work@innermod::Zinner
```

**v29's other two faults**, which no class scorer sees, read off the dump at
the base: the def view is named `work@innermod` where golden writes
`work@sub::innermod`, and `work@sub` carries a `ref_module work@innermod
(innermod)` golden does not write at all.  A FOURTH, which the first head
masked: our elaborated `work@dut.u_s` carries a `module_inst
work@innermod (work@dut.u_s.innermod)` and golden's carries no `vpiModule`.

**v29 is CONVERTED.**  Its whole dump is now identical to golden's, line for
line, id-normalised — not merely judge-equal: `diff` of the two dumps is the
FILENAME BANNER and nothing else.

**v27 and v28 rise on the judge and that rise is a MASK CASCADE, not a
regression.**  Pass 96's verifier already recorded that `uhdm-cmp` cannot see
this class face because the interface-emitted-as-module KIND divergence masks
it.  Closing the class face removes the mask, and the head moves to that
pre-existing divergence.  The control is `grid/w06_ifacenestnoclass` — the
same non-simple interface with NO CLASS ANYWHERE — which reads **540 cmp
lines on BOTH binaries at the base**, i.e. the whole of v27's 539 and the
bulk of v28's 514.  The whole-dump diff (§3) shows the ONLY objects that
moved are the classes.

---

## 2. THE DECODE, IN THE PINNED SOURCES

### 2a. LAW A — why an interface's classes go to the design root, on EVERY road

`useInterfacePath` is `isInterface() && isSimpleInterfaceBody(body)`
(`src/EmitHelpers.h:2892-2910`), and `isSimpleInterfaceBody` returns FALSE as
soon as the interface holds a CHILD INSTANCE.  Such an interface is emitted by
`emitModuleDef` wearing a `module_inst`.  Pass 96 landed
§ `caIfaceClassIsDesignRoot98` keyed on `useInterfacePath`, so it reached only
the simple shape, and landed § `caModGenClassNotIfaceHome98V` which stops the
WRONG mint on the generate face of the other shape.  Neither adds the RIGHT
object, and neither touches the BODY face.

Golden's road does not consult the interface's contents at all.
`ResolveSymbols::createFastLookup`
(`~/git-repos/Surelog/src/DesignCompile/ResolveSymbols.cpp:79-90`) opens the
file with

```
types      = {module, package, config, udp, INTERFACE, program, class}_declaration
stopPoints = {module, package, program, class}_declaration
```

— an interface is in `types` but **NOT in `stopPoints`**, so
`sl_collect_all` descends straight through it (a generate region is not a stop
point either), reaches every `paClass_declaration` inside, and files each one
through the bare `paClass_declaration` case at `:160-166` as
`StrCat(libName, "@", name)` with a **NULL container**; the interface itself
falls to `default:` at `:203-209`, which builds a `ModuleDefinition` and
collects no classes.  `UhdmWriter` then publishes every containerless class at
the design root (`if (!c->VpiParent()) writeClass(...)`).  Nothing on that
road depends on whether the interface holds a child instance — hence the
widening is exactly `isInterface()`.

### 2b. LAW B — the whole nested-module road is ONE `case`

`createFastLookup`'s `paModule_declaration` case, `ResolveSymbols.cpp:168-201`:

```
ModuleDefinition* mdef = new ModuleDefinition(fd, object, fullName);   // work@sub
addModuleDefinition(fullName, mdef);
subtypes = stopPoints = {paClass_declaration, paModule_declaration};
for (subobject : sl_collect_all(object, subtypes, subtypes)) {
    fullSubName = StrCat(fullName, "::", name);                        // work@sub::innermod
    if (Type(subobject) == paClass_declaration)
        ClassDefinition(name, lib, mdef, ...)  ->  mdef                // the OUTER's class
    else
        addModuleDefinition(fullSubName,
                            new ModuleDefinition(fd, subobject, fullSubName));
}
```

Six consequences, each its own gate:

* **B1 the name.** `work@<outer fullName>::<inner>`.  Measured on
  `w12`/`w13`/`w15`/`w16`/`w18`/`w19`/`w21`/`w28`/`w29`.  The def views are
  published NAME-SORTED by that scoped name, so `work@sub::innermod` follows
  `work@sub` (`w12`), `work@sub::amod` precedes `work@sub::zmod` (`w16`), and
  a file-scope `innermod` sits BESIDE a nested one (`w19`) — an arrangement a
  bare key cannot even represent, since one shadows the other.
* **B2 no ref, no instance.** A declaration is not an instantiation.  slang
  disagrees: `Scope::handleNestedDefinition`
  (`~/git-repos/slang/source/ast/Scope.cpp:1281-1308`) implicitly instantiates
  a portless, parameterless, otherwise-uninstantiated nested module via
  `InstanceSymbol::createDefaultNested`
  (`~/git-repos/slang/source/ast/symbols/InstanceSymbols.cpp:419-444`), which
  FABRICATES a `HierarchicalInstanceSyntax` out of the declaration's own name
  token — which is how `implicitNestedInst99` tells it from a written one
  (same location, same name).  A WRITTEN `innermod u_i ();` keeps its
  `ref_module` and its elaborated copy (`w13`, golden's
  `work@dut.u_s.u_i`), and `handleNestedDefinition` then mints no implicit
  copy (`def->getInstanceCount() > 0`).
* **B3 not a class home.** The outer's sub-walk STOPS at
  `paModule_declaration`, so the inner's classes are never filed on the outer;
  and the inner's own `ModuleDefinition` comes from the bare `else` branch,
  which runs no class walk at all.  Measured: `v29`/`w11`'s golden dump
  contains the strings `Zinner` and `Ainner` **ZERO times**, in any home and
  at the design root.
* **B4 one level only.** The sub-walk is not recursive and the bare `else`
  branch never walks its own subtree, so a doubly-nested module has no
  definition anywhere.  `w14` and `w21` — where the doubly-nested module is
  even EXPLICITLY instantiated — both publish exactly
  `[work@dut, work@sub, work@sub::mid]`.
* **B5 the ref resolves to nothing.** The stub's `vpiDefName` comes off the
  INSTANTIATION TEXT, so it reads `work@innermod`, while the definition is
  filed under `work@sub::innermod`; the writer's lookup misses.  `w13`'s
  golden `ref_module work@innermod (u_i)` carries vpiName + vpiDefName and NO
  `vpiActual`; `w21`'s `ref_module work@deep (u_d)` likewise, there because
  the definition does not exist at all (B4).
* **B6 the parent.** Golden's `work@sub::innermod` reads
  `|vpiParent: \_module_inst: work@sub (work@sub)`.

**The one shape LAW B declines.**  `nestOuterDef99` requires BOTH the inner
and the outer declaration to be a MODULE, because `paModule_declaration` is
the only `createFastLookup` case that runs a sub-walk and
`{paClass_declaration, paModule_declaration}` is the only subtype set it
collects.  Stronger: the pinned Surelog's PARSER REJECTS a nested interface
outright — `interface if_x; logic w; endinterface` inside a module gives
`PA0207 missing 'class' at 'if_x'` — measured on three shapes
(`w22`, `w26`, `w27`, all `golden_rc=3`, and
`tools/probe/r10v223repro/arms/v11_nested_iface`).  There is no golden for the
shape, so this law does not touch it: those arms keep the base binary's bare
`work@if_x` BYTE FOR BYTE.  An earlier build of this patch did move two probe
arms on that shape; the restriction removed both, and the wide boundary
re-run proves it (§6).

---

## 3. THE GOLDEN GRID (`tools/probe/r11u99repro/grid`, 27 arms)

Run with this pass's own binaries; `rr98.sh` regenerates the golden per arm
per tag with the PINNED Surelog and records BOTH rc values.

### 3a. the interface face

| arm | shape | pris | law | CELL OK pris -> law | OURS-ONLY pris -> law |
|---|---|---|---|---|---|
| `w01_ifacenestinst` | child instance + GENERATE class (= `v27`) | 260 | 539 | 0 -> 1 | 0 -> 0 |
| `w02_ifacenestbody` | child instance + BODY classes (= `v28`) | 252 | 514 | 0 -> 2 | 2 -> 0 |
| `w03_ifacenestmixed` | body `Mbody`, gen `Cgen`, body `Abody` — golden's root reads `[Abody, Cgen, Mbody]`, i.e. ONE name-sorted registry across body AND generate | 302 | 623 | 0 -> 3 | 2 -> 0 |
| `w07_twoifacenest` | TWO non-simple interfaces, one class each — golden merges them into one root listing `[Ac, Zc]` | 327 | 674 | 0 -> 2 | 2 -> 0 |
| `w06_ifacenestnoclass` | **THE MASK CONTROL** — non-simple interface, NO class anywhere | 540 | 540 | 0 -> 0 | 0 -> 0 |
| `w05_ifacesimplebody` | **CONTROL** — SIMPLE interface, body classes: already right at the base | **0** | **0** | 2 -> 2 | 0 -> 0 |
| `w08_ifacenestarrclass` | **CONTROL** — a child instance ARRAY is not a child `Instance`, so the interface path still applies: already right | 164 | 164 | 1 -> 1 | 0 -> 0 |
| `w04_ifacenestmodchild` | a MODULE child in an interface: `ours_rc=3` on BOTH binaries — teaches error recovery, not golden | — | — | — | — |

### 3b. the nested-module face

| arm | shape | pris | law |
|---|---|---|---|
| `w11_modinnerdecl` | classes in both (= `v29`) | 59 | **0** |
| `w12_modinnernoclass` | nested module, no classes | 29 | **0** |
| `w13_modinnerinst` | nested module EXPLICITLY instantiated (B2 must NOT fire; B5 must) | 21 | **0** |
| `w14_modinnerdeep` | module nested inside a nested module (B4) | 391 | **0** |
| `w15_modinnercontent` | nested module with a param, a net and a cont_assign | 29 | **0** |
| `w16_modinnertwo` | TWO nested modules, `zmod` before `amod` in source | 84 | **0** |
| `w18_modinnertop` | nested module inside the TOP, outer has its own class | 85 | **0** |
| `w21_moddeepinst` | doubly-nested module EXPLICITLY instantiated (B4 + B5) | 397 | **0** |
| `w25_modinnerclassonly` | nested module whose only content is a class | 29 | **0** |
| `w28_v196nested` | the boundary arm `r10v196repro/arms/v196_x11_nested.sv`, lifted whole with its package | 25 | 25 |
| `w29_v216nested` | the boundary arm `r10v216repro/armsv216K/v216_m_nested_mod.sv` | 205 | **127** |
| `w19_modinnersame` | a nested module whose name also exists at FILE scope | 496 | 438 |
| `w23_modinnerport` | nested module WITH A PORT | 444 | 444 |
| `w24_modinnerparam` | nested module WITH A PARAMETER | 446 | 446 |
| `w20_moddeclgen` | **CONTROL** — an ordinary child instance (a real `ref_module`) | **0** | **0** |
| `w17`, `w22`, `w26`, `w27` | a module in an interface / an interface in a module: `golden_rc=3` on the PINNED Surelog — no golden exists | — | — |

**NINE arms converted to `cmp rc=0`.**  On `w28` the remaining 25 lines are a
pre-existing constant/`vpiDecompile` divergence of that arm, identical on both
binaries; on `w29` the remaining 127 are r10v216's own DPI-export residue.
Both arms' `uhdmallModules` listings now match golden exactly, name and order.
`w19`, `w23`, `w24` are §8's residues.

### 3c. the whole-dump diff, beside the judge

The pass-96 mask-cascade lesson, applied.  `ours.pris.dump` vs `ours.lawx.dump`,
id-normalised:

* `v27` — **one** addition: the design's `uhdmallClasses` gains
  `class_defn (work@Cgen)` with its `int_var`, plus that var's `int_typespec`
  in the weakly-referenced tail.  Nothing else.
* `v28` — the design's `uhdmallClasses` gains `work@Abody` + `work@Zbody`,
  `work@outer`'s `vpiClassDefn` loses `work@outer::Abody` + `work@outer::Zbody`,
  and the two tail `int_typespec`s swap order behind them.  Nothing else.
  Golden's own root entry is shape-identical to what we now write (checked
  field by field: `vpiName:work@Abody`, parent `design`).
* `v29` — our dump becomes golden's dump.

And `gold` vs `ours` on the law binary: `w11` **0** diff lines, `w14` 0,
`w18` 0, `w21` 0.  `w20` and `w05` keep 6 and 70 dump-diff lines respectively
— IDENTICAL counts on both binaries, i.e. pre-existing and not this pass's.

---

## 4. THE GATES

Eight switches, each droppable alone, plus the master and the trace.

| switch | face | grid total (30 arms) |
|---|---|---|
| — (pristine binary) | — | **5156** |
| — (law binary, all on) | — | 5587 |
| `R11U99_OFF=1` | all eight | **5156** — EXACTLY the pristine total |
| `R11U99_IFACEROOT_OFF=1` | A1 | 3837 |
| `R11U99_IFACEBODY_OFF=1` | A2 | 5763 |
| `R11U99_NESTNAME_OFF=1` | B1 | 6115 |
| `R11U99_NESTIMPL_OFF=1` | B2 | 5968 |
| `R11U99_NESTCLASS_OFF=1` | B3 | 5747 |
| `R11U99_NESTDEEP_OFF=1` | B4 | 6223 |
| `R11U99_NESTACTUAL_OFF=1` | B5 | 5608 |
| `R11U99_NESTPARENT_OFF=1` | B6 | 5587 — see below |
| `R11U99_NETDBG=1` | the four traces, OUTSIDE every gate | — |

**Stronger than the line total**: with `R11U99_OFF=1` the law binary
reproduces the PRISTINE DATABASE **byte for byte on 28/28 buildable arms** of
this grid (the two skipped are `w04` and `w17`, which compile-reject on both
binaries) and on **all 168 buildable arms of the five control grids**, and it
reproduces every control grid's pristine cmp TOTAL exactly (§5).

Every byte comparison in this report was taken on files written ONCE by the
binary that is being measured.  A `-o` rewrite over a LONGER database from an
earlier build leaves a stale 107-byte tail that `cmp` reports as a mover and
`uhdm-dump` cannot see (the two decode identically, ids included) — the
partially-written-dump class of RESUME §9, at database granularity.  The grid
and control-grid `.uhdm` files were deleted before the final runs for exactly
that reason; the sweep workdirs were built fresh per binary; and both binaries
are 40/40 byte-deterministic on the two arms where the artifact first showed
(`w13`, `w21`).

**B6 is judge-invisible and that is not a defect.** No generated `Compare`
reads `VpiParent` (RESUME §9), so the grid total cannot move; the gate is
proven live by the DUMP instead.  `R11U99_NESTPARENT_OFF=1` on
`w12_modinnernoclass` changes exactly ONE line against the shipped binary:

```
-   \_module_inst: work@sub (work@sub), file:dut.sv, line:2:1, endln:7:10
+   \_design: (work@dut)
```

and the shipped side is golden's.

---

## 5. THE CONTROL GRIDS

The pass-96 pair's grids and their two predecessors, run on both binaries.

| grid | arms | pris | law | databases `cmp`-identical | movers |
|---|---|---|---|---|---|
| r11u98 | 20 | 159 | 159 | **20/20** | none |
| r11v98 | 31 | 1247 | 1729 | 27/30 | `v27`, `v28`, `v29` — THIS PASS'S OWN WITNESSES, and nothing else |
| r11u95 | 35 | 72 | 72 | **35/35** | none |
| r11v95 | 31 | 522 | 522 | **30/30** | none |
| r11u93 | 55 | 185 | 185 | **53/53** | none |

The unbuildable arms (`r11v98/v02_ifacechild`, `r11v95/x1_proggenalways`,
`r11u93/pa10_proggenmod`, `r11u93/pb18_ifnodecl`) read `ours_rc=3` on BOTH
binaries — pre-existing rejects, identical, not movers.

**The landed four class laws and the verifier guard are untouched**:
§ `caClassListNameKeyed98`, § `caModGenBlockClassIsModuleOwn98`,
§ `caIfaceClassIsDesignRoot98`, § `caDefGenBlockKeepsFinal98` and
§ `caModGenClassNotIfaceHome98V` all still read their committed totals above,
and `R11U98_*` remain droppable.

### 5a. the SLOT-KEYED arbiter, and its positive control

`cellmove99.py` differences `classcell98.py`'s slot scores across the two dump
pairs, PER CELL and PER SUBTREE ENTRY:

| grid | arms | CELL MOVED-WRONG | CELL GAINED | SUB AWAY | SUB GAINED |
|---|---|---|---|---|---|
| this pass's grid | 30 | **0** | 11 | **0** | 11 |
| r11u98 | 20 | **0** | 0 | **0** | 0 |
| r11v98 | 31 | **0** | 3 | **0** | 3 |
| r11u95 | 35 | **0** | 0 | **0** | 0 |
| r11v95 | 31 | **0** | 0 | **0** | 0 |
| r11u93 | 55 | **0** | 0 | **0** | 0 |

**MOVED-WRONG 0 / AWAY 0 over 202 arms**, and the scorer is proved able to see
one: re-scored against the law binary run with `R11U98_CLASSKEY_OFF=1` — which
drops pass 96's LANDED name-keyed listing, a genuine pristine-right ->
patched-wrong move — it reports **CELL MOVED-WRONG=17** on the r11u98 grid,
naming each cell (`g6_modclasscase vpiClassDefn[0] gold=work@sub::A_cls
ours=work@sub::b_cls`, and 16 more).

---

## 6. THE WIDE BOUNDARY

`bnd98.sh` over the WHOLE `tools/probe` tree: every directory holding a source
is one arm, both binaries compile it with identical argv, the DATABASES are
compared byte for byte.  Subdirectory arms included, the list read on fd 3,
children on `/dev/null`.

```
BOUNDARY listed=4347 processed=4347 moved=16 rc-or-db-anomalies=0
PROCESSED==LISTED
```

Every one of the 16 attributed, by name, three ways (a same-binary repeat, an
`R11U99_OFF=1` re-run, and the order-blind dump class):

| arms | verdict |
|---|---|
| `r11v98repro/grid/{v27,v28,v29}` | **THE LAWS** — this pass's own witnesses (§1) |
| `r10v196repro/arms`, `r10v216repro/armsv216K` | **THE LAWS** — each holds a real nested MODULE declaration (`xOuter::xInner`, `v216_mod_m::v216_inner_m`); `R11U99_OFF=1` reproduces pristine byte for byte.  Both lifted into this grid as `w28`/`w29` and measured against a REAL golden: the `uhdmallModules` names and order become golden's exactly (§3b) |
| `r10uvm196repro/grid196`, `r10uvm203repro/grid203` | **NONDETERMINISM** — six runs of the SAME pristine binary give TWO distinct hashes each (5 + 1).  The scoreboard coin, RESUME §9 |
| `r10uvm117repro`, `r10uvm130repro`, `r10v109repro`, `r10v117repro`, `r10v130repro`, `r10v209repro/arms` | **NONDETERMINISM** — `SELF-NONDET` (pristine vs pristine differ) AND `R11U99_OFF=1` does not reproduce pristine |
| `r10buvm22repro`, `r10uvm154repro`, `r10uvm185repro/grid185` | **r11u95's residue R2, unreachable by any gate** — the order-blind delta is the 8-digit `UINT`/`vpiDecompile` payload just above each binary's own image size: `23367777`/`23368633` for the pristine binary (23 345 752 bytes) against `23372033`/`23372889` for this one (23 351 984 bytes).  **Exactly the three arms r11u95's and r11u98's READMEs name** |

The two nested-INTERFACE arms that an earlier build of this patch moved
(`r10v223repro/arms/v11_nested_iface`, `r10v216repro/armsv216`) do **not**
appear: the `DefinitionKind::Module` restriction (§2b) removed them, and this
boundary is the re-run that proves it.

---

## 7. THE GATES THE BRIEF REQUIRES

1. **Both binaries built, md5s taken separately.** Pristine
   `534aa1d5c630bc1530e15a30341eb6fa` — `cmp`-identical to the main tree's
   `build/slang-uhdm` at `9002f74a` and to the OPS pin.  Law
   `d9003cec9637a44d06f9d8daa9a235d6`.  **Reproduced from the deliverable**:
   the patch applies to a FRESH `9002f74a` worktree with `git apply --check`
   rc=0 and `git apply` rc=0 (2 `M` + 33 `A`, no conflicts, no fuzz) and
   rebuilds to `d9003cec9637a44d06f9d8daa9a235d6` bit for bit.  The patch
   surface is `src/ModuleEmit.cpp`, `src/UhdmExporter.cpp` and
   `tools/probe/r11u99repro/` — nothing else.
2. **Goldens** `23 PASS / 0 FAIL` on the law binary; negative control
   `SLANG_UHDM=/bin/false` -> `23 FAIL / 0 PASS`.
3. **uhdm2rtlil, both modes.** Row-join law vs pristine and law vs the
   committed `results/golden_uhdm2rtlil.csv` (which holds BOTH modes):
   **PASS, every row byte-identical**.  Status census identical on all three:
   `default 788 EQ / 83 NE`, `testflags 788 EQ / 83 NE`.  (`ct8rows` against
   `results/gate_uhdm2rtlil.csv` reports ATTENTION for the PRISTINE binary
   too — that CSV is TESTFLAGS ONLY and a both-modes sweep has 871 unmatched
   `default` rows.  Not a mover; the like-for-like join is the one above.)
4. **Surelog, both modes.** Status join vs the committed
   `results/golden_surelog.csv`: **0 differences for the law binary, 0 for the
   pristine binary, 0 between them**.  `default 474 EQ / 324 NE`,
   `testflags 469 EQ / 329 NE` — exactly the `9002f74a` baseline.  The only
   whole-row difference between the two sweeps is `Earlgrey_0_1`'s DUMP COLUMN
   (`` vs `differ`), which the OPS brief records as a `uhdm-dump` timeout draw
   and whose DATABASE byte pins are identical (below); the law sweep is the
   one that agrees with the committed CSV.
5. **byteverify `SELFCHECK=1`** against this pass's own pristine workdirs:
   `PATH_SETS_IDENTICAL (2568 paths)`, `MOVERS: 4 / 2568`,
   `SELFCHECK 2567 / 2568 flagged`.

   **The four movers were PREDICTED to be none, and every one is attributed.**
   `default/MiniAmiq`, `default/SeqDriver`, `testflags/MiniAmiq`,
   `testflags/SeqDriver` — all four order-blind deltas are the documented
   4-line `UINT`/`vpiDecompile` line-number pair of the UVM family, with ZERO
   `class_defn`, `module_inst`, `ref_module` or name lines among them.
   **Positive control**: the SAME law binary run TWICE over that family
   produces 4 self-movers of the identical class (`MiniAmiq` default
   `UINT:821`/`UINT:953`, `SeqDriver` both modes), so the family is
   per-invocation nondeterministic and these are that draw.  **All seven
   conversion rows stay CMP_EQUAL in both modes**: `BuildUVMPkg`, `MiniAmiq`,
   `SeqDriver`, `SimpleUVM`, `Earlgrey_0_1`, `InterfaceModPort` and
   `Scoreboard`/default — `Scoreboard`/testflags reads `SLANG_REJECT` exactly
   as `results/golden_surelog.csv` records it.

**Canaries.** `canaries.sh` **ok=52 changed=0 absent=0** on surelog and
**ok=16 changed=0 absent=0** on uhdm2rtlil; `ctcan2.sh` **PASS** on both;
`canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0`.  Protected databases,
law vs pristine, byte for byte:

```
SVSwitch           4842211c4030  both modes  (the HARD pin)
YosysVerx          6ccda350c24a  both modes  (the HARD pin)
InterfaceModPort   59a365f3ce2c  both modes  (watched byte-for-byte)
Earlgrey_0_1       8bdf25272e08 default / 59d0ee6d10c3 testflags  (the pins)
BlackParrotComplex e3e354129d5a default / 73a10e8217e5 testflags  SAME
YosysOldOr         d68e0796d62c  both modes                       SAME
```

---

## 8. THE CENSUS — ZERO, EXPLAINED AND CONTROLLED

`cellcen99.py` replays the harness's OWN `discover_*` / `translate` /
`location_args` (so a site cannot be missed because a driver spelled a flag
differently) and runs the LAW binary with `R11U99_NETDBG=1` and
`R11U98_NETDBG=1` over every test of both corpora in both modes.  The
predictor is the union of

* `R11U99NESTDEF` — the superset for ALL SIX of LAW B (every nested module
  definition, with its depth),
* `R11U99BODYCLASS ... iface=1` — LAW A2's population, and
* `R11U98MODGENCLASS ... iface=1` — the LANDED pass-96 trace, whose `iface=1`
  arm is exactly LAW A1's generate face.

LAW A1's own site reads those same two populations, so the union is complete.

| corpus | arms dispatched | nestDef | nestRef | nestInst | bodyClass iface=1 | bodyClass nested=1 | genClass iface=1 | PREDICTED MOVERS |
|---|---|---|---|---|---|---|---|---|
| surelog | 1576 + 3 seeds | 0 + 2 | 0 + 2 | 0 + 2 | 0 + 4 | 0 + 4 | 0 + 2 | **NONE** (the 3 seeds only) |
| uhdm2rtlil | 1742 + 3 seeds | 0 + 2 | 0 + 2 | 0 + 2 | 0 + 4 | 0 + 4 | 0 + 2 | **NONE** (the 3 seeds only) |

**THE ZERO IS CONTROLLED.** Three grid arms are SPLICED INTO THE TEST SET as
`--seed` positive controls and dispatched exactly like a corpus test; each
comes back flagged by exactly the law it exercises:

```
#SEED:w01_ifacenestinst   LAWA1-IFACEGEN
#SEED:w02_ifacenestbody   LAWA2-IFACEBODY
#SEED:w11_modinnerdecl    LAWB-NESTDEF, LAWB2-NESTINST, LAWB2-NESTREF, LAWB3-NESTCLASS
```

**THE GAP IS EXPLAINED, NOT ASSERTED.** Three arms per corpus read `rc=-11`
under the census driver's `-o /dev/null` replay — `Rggen`/testflags and `Tnoc`
in both modes on surelog, `rp32_r5p_degu_soc_top`/`rp32_r5p_mouse_soc_top`/
`rp32_soc_vfriendly` testflags on uhdm2rtlil.  Every one of them is
`SURELOG_FAIL` or `SLANG_REJECT` in the committed CSVs and in both of this
pass's sweeps, so **there is no database for them to move** — the pass-96
lesson, re-measured.  Neither corpus's sources contain a class inside an
interface that falls through to the module path, nor a module declared inside
a module, at all.

The census prediction and the sweeps agree: **zero corpus movers, both
corpora, both modes**, and the four byteverify movers are the family the OPS
brief declares pristine-nondeterministic.

---

## 9. RESIDUES (ranked)

1. **A NESTED MODULE WITH A PORT OR A PARAMETER GETS NO DEF VIEW AT ALL.**
   `w23_modinnerport` 444 and `w24_modinnerparam` 446, identical on both
   binaries.  `Scope::handleNestedDefinition` declines to instantiate a nested
   module that has ports or parameters (`Scope.cpp:1283-1299`), so it never
   reaches `collectDefs` and we publish nothing; golden publishes
   `work@sub::innermod` with its full content.  The fix is a `createDefault`
   mint of the kind `emitPackageClasses` and the unreferenced-def path already
   take — a MINT, with its own arena consequences to measure, and the biggest
   single nested-zone win left.  CORPUS-INVISIBLE (§8).  **R0.**
2. **A NESTED MODULE WHOSE NAME COLLIDES WITH A FILE-SCOPE MODULE.**
   `w19_modinnersame` 496 -> 438: golden publishes `work@innermod` AND
   `work@sub::innermod`; slang resolves the nested declaration's name to the
   FILE-SCOPE definition, so only one `InstanceSymbol` ever reaches `defs` and
   the nested def view is simply absent.  LAW B1's re-keying makes the two
   representable — the collection, not the key, is what is still missing.
   Pre-existing, improved, not closed.  CORPUS-INVISIBLE.
3. **THE NESTED DEF VIEW'S OBJECT FULLNAMES.** Golden synthesises a nested
   module's net fullname as `work@sub.work@sub::innermod.r`; we write
   `work@sub::innermod.r`.  `VpiFullName` is never read by any generated
   `Compare` (RESUME §9), so every affected arm reads `cmp rc=0` and only the
   dump shows it (`w12` 79 lines, `w15` 125, `w13` 24).  Recorded, not fixed:
   it is a display convention, and changing it would touch every net, var and
   typespec under a nested def.
4. **AN INTERFACE THAT FALLS THROUGH TO THE MODULE PATH IS STILL A
   `module_inst`.** `w06_ifacenestnoclass` reads **540 cmp lines on both
   binaries with no class anywhere**: golden lists such an interface under
   `uhdmallInterfaces` as an `interface_inst` and we list it under
   `uhdmallModules` as a `module_inst`.  That is the divergence this pass's
   LAW A UNMASKED on `v27`/`v28`/`w03`/`w07`, and closing it means teaching
   `isSimpleInterfaceBody` to admit a child instance — a whole pass, and the
   next one this family wants.  **R1.**
5. **A MODULE/PROGRAM HOME DOES NOT LIST ITS PARAMETERIZED CLASSES** —
   r11u98's and r11v98's R0, untouched and unmoved: `g9_modclassparam` 159 and
   `v07_modgenparamclass` 91, both binaries.  Still the recorded
   def-phase-specialization Heisenbug road, still FENCED per the brief.
6. **THE r11u95 / r11v95 RESIDUES, unmoved and re-measured**:
   `a20_proggenparam` 72 (`src/ParamEmit.cpp` — the SISTER PASS'S GROUND, not
   touched here); `x12_proggenimportfn` 203 + `x26_progimportbodyfn` 241;
   `x2_proggenassert` 64; `x8_proggendupname` 14.  And r11u95's residue R2,
   the image-size `UINT`, which no gate can reach (§6).
7. **A PROGRAM DEF STILL BUILDS GENERATE PLACEHOLDERS NOBODY CAN REACH** —
   r11u98's R4, unchanged.

---

## 10. HOW TO RE-RUN

```bash
GRID=tools/probe/r11u99repro/grid bash tools/probe/r11u98repro/rr98.sh <binary> <tag>
GRID=tools/probe/r11u98repro/grid bash tools/probe/r11u98repro/rr98.sh <binary> <tag>   # the controls
GRID=tools/probe/r11v98repro/grid bash tools/probe/r11u98repro/rr98.sh <binary> <tag>
GRID=tools/probe/r11u95repro/grid bash tools/probe/r11u98repro/rr98.sh <binary> <tag>
GRID=tools/probe/r11v95repro/grid bash tools/probe/r11u98repro/rr98.sh <binary> <tag>
GRID=tools/probe/r11u93repro/grid bash tools/probe/r11u98repro/rr98.sh <binary> <tag>
python3 tools/probe/r11u98repro/classcell98.py <gold.dump> <ours.dump> --rows
python3 tools/probe/r11u99repro/cellmove99.py <arm-dir> ...       # the slot-keyed arbiter
python3 tools/probe/r11u99repro/cellcen99.py <repo> <corpus> <LAW binary> <out.tsv> \
        --seed tools/probe/r11u99repro/grid/w11_modinnerdecl \
        --seed tools/probe/r11u99repro/grid/w02_ifacenestbody \
        --seed tools/probe/r11u99repro/grid/w01_ifacenestinst
bash tools/probe/r11u98repro/bnd98.sh <pristine> <law> <outdir> tools/probe
R11U99_OFF=1 / R11U99_IFACEROOT_OFF=1 / R11U99_IFACEBODY_OFF=1 /
R11U99_NESTNAME_OFF=1 / R11U99_NESTIMPL_OFF=1 / R11U99_NESTCLASS_OFF=1 /
R11U99_NESTDEEP_OFF=1 / R11U99_NESTACTUAL_OFF=1 / R11U99_NESTPARENT_OFF=1 /
R11U99_NETDBG=1  <binary> …
```

`cellmove99.py` needs BOTH dump pairs per arm (`gold.pris.dump`,
`ours.pris.dump`, `gold.lawx.dump`, `ours.lawx.dump`) — run `rr98.sh` twice,
tags `pris` and `lawx`.  **The census MUST be run with the LAW binary**: the
trace lines live in the patch, so a census run on the base binary reads zero
for the trivial reason that there is no trace at all.  `R11U99_OFF=1` beside
`R11U99_NETDBG=1` gives the population with the laws dropped.
