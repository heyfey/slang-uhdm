# r10oth6 — the virtual-interface shape

**Result, up front: SVSwitch did NOT convert. It stays `CMP_NOTEQUAL` in both
modes. What it did was collapse from 2880 cmp lines to 361 in BOTH modes, and
its head moved off `class_defn (work@Driver)` entirely — the missing property is
gone and the new head is a DIFFERENT cluster (`class_typespec (mailbox)` with
`RHS: <null>` on its `vpiClassDefn`). THREE laws (plus one narrow sub-law),
all measured on both sides of the 79 `vtab.sh` cells across two arms plus the
8 typespec positions of §3.1. Corpus reach: SIX databases moved bytes (SVSwitch, SeqDriver,
SimpleUVM × both modes), ZERO rows changed status or dump on either corpus, and
ZERO of the 37 named canaries moved (66 rows).**
*(Verifier: the byte-mover reading is 6 OR 7 depending on the run — Scoreboard's
known nondeterminism can add a seventh. See the correction block in §4.2.
Canaries independently re-checked at 119 rows / 0 moved.)*

**The master's model was RIGHT and I confirm it: golden emits a virtual
interface class property as a bare `logic_var`.** ~~Two of the master's NUMBERS
are REFUTED (§6): the reach figures 135/24 and "SVSwitch 4".~~
*(STRUCK BY THE VERIFIER. "SVSwitch 4" → 10 is a genuine correction and it
reproduces. The 135/24 reach figures are NOT refuted: §6 counts a strict
SUPERSET of what the master counted, so 512 ≥ 135 and 39 ≥ 24 are consistent and
both can be right. Downgraded to "different measurement" in §6.)*

**Verifier's own additions: residues R7 (law C's span ignores the interface's
`#(...)` parameters — 26 sites, latent) and R8 (a nested `virtual class` does not
set the outer class's `vpiVirtual` — pre-existing), each with a shipped cell.**

Base commit `ea457fb`, branch `auto5h`.
Direction convention, used here and in every note comment the patch adds:
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.

Binaries. Every figure below names the one that produced it.
* pristine `ea457fb` — md5 **`3479e2d10a75171848cf3aa83498d65a`**, kept at
  `/tmp/r10oth6_pristine_slang-uhdm` so no rebuild could ever race a sweep.
* patched, FINAL — md5 **`2ce72eec181f1fe1268a063d8aa901bb`**.
* one intermediate is named where it matters: `b521f6af177d2fe5416adb61eabf07d5`
  (laws A + B only, before law C).
The md5 was printed BEFORE and AFTER every sweep and never changed within one.

---

## 0. THE TARGET, RE-MEASURED FROM SCRATCH — the master's model is CONFIRMED

Order-of-work item A was "read golden's `logic_var (work@Driver::input_intf)`
object IN FULL first — every field". Done, on the pristine binary. Golden's
object, verbatim from `uhdm-cmp` on the SVSwitch `default` cell:

```
\_logic_var: (work@Driver::input_intf), id:3674, line:13:29, endln:13:39
  |vpiParent:
  \_class_defn: (work@Driver), id:2, ...
  |vpiName:input_intf
  |vpiFullName:work@Driver::input_intf
  |vpiAutomatic:1
  |vpiVisibility:1
```

**Five fields and a span. NO `vpiTypespec` AT ALL** — the master's guess that
"that is a much cheaper object to produce than an interface reference" is
exactly right, and the absence of the typespec is load-bearing (§1, second
half). Ours had NO object there; the listing's first entry was the next
declaration, `class_var (work@Driver::drvr2sb)` at 14:9.

### WHY we skipped it — confirmed in the code before writing anything

`src/UhdmExporter.cpp`, `UhdmExporter::emitClassDefn` (grep
`class property type: `): `makeVar` declines a `VirtualInterfaceType`, no
struct/union arm catches it, and the property hits
`noteUnsupportedAt("class property type: " + ...); continue;`. Running the
pristine binary on the arm prints it:

```
slang-uhdm: unsupported constructs encountered:
  class property type: VirtualInterfaceType
```

So it was a **silent `continue` behind a noteUnsupported**, not a naming or an
ordering bug. The master proved the same thing from the dumps; I proved it from
the emitter, and the two agree.

### WHY golden produces a `logic_var` — transcribed from Surelog, not guessed

Surelog does not model virtual interfaces at all; there is no `VIRTUAL_INTERFACE`
anywhere in `~/git-repos/Surelog/src`. The chain, each step greppable:

1. `CompileHelper::compileDataDeclaration` (`CompileHelper.cpp`, grep
   `paVIRTUAL`) steps PAST the `virtual` keyword —
   `if (fC->Type(intVec_TypeReg) == VObjectType::paVIRTUAL) intVec_TypeReg = fC->Sibling(intVec_TypeReg);`
   — so the `Signal`'s type is the interface-name `slStringConst`.
2. `TestbenchElaboration::bindProperties_` (grep `bindProperties_`) compiles a
   typespec from that node and calls `ElaborationStep::makeVar_`.
3. `makeVar_` (grep `any* ElaborationStep::makeVar_`) finds no `DataType` arm and
   no typespec arm, falls off the end of its `subnettype` switch into its
   `// default type (fallback)` arm: `logic_var* logicv = s.MakeLogic_var();`
   with null packed ranges and **no typespec**.
4. The tail of `makeVar_` then stamps `VpiAutomatic(!isStatic)` and
   `VpiVisibility(...)` on whatever `obj` came out — which is why the object
   still reads like a normal property.

---

## 1. LAW A — `§ virtualIfacePropIsBareLogicVar6`

`src/UhdmExporter.cpp`, two hunks inside `UhdmExporter::emitClassDefn`
(grep the `§` name; the mint sits immediately before the
`noteUnsupportedAt("class property type: ...")` bail, the typespec suppression
immediately before the `pendingClassPropTs.push_back` tail).

**DIRECTION: ADD a missing object** (plus a SUPPRESSION of the ref_typespec the
generic tail would otherwise attach).

**THE PREDICATE.** `!v && ct.kind == SymbolKind::VirtualInterfaceType`, where
`ct` is the property's **CANONICAL** type. Then `v = s.MakeLogic_var()` and the
existing common tail supplies name / fullname / parent / declarator-name span /
`vpiAutomatic` / `vpiVisibility` unchanged.

**Why CANONICAL and not the written type — proved by cell `k6_typedef`:**
`typedef virtual w_if.IP wif_t; class k6_typedef; wif_t vi; ...` — golden's
`logic_var (work@k6_typedef::vi)` is byte-identical to the inline spelling's.
Gating on the written syntax would have missed it; the pristine binary printed
`typedef target: VirtualInterfaceType` for exactly that cell.

**Why the ref_typespec SUPPRESSION is NECESSARY, not cosmetic.** The generic
tail pushes a `ref_typespec` onto `pendingClassPropTs`, which the write phase
then fills. `variables::Compare` reads `vpiTypespec`, so a property carrying one
where golden carries none is a cmp difference on its own — and it is visible in
the dump as an extra `|vpiTypespec:` edge plus an extra design-listing object.
With the suppression, all **14** virtual-interface property objects in arm v1
(and `k6` / `k8` / `k9` in arm v2) read **exactly the same fields on both
sides** — five for the plain ones, six for `c11_init` which adds `vpiExpr`.

**Four written spellings are ONE cell in golden** (`c1`..`c4`), which answers
the brief's warning that the majority spelling is not the witness spelling:
there is no second half here, the object does not depend on the spelling at all.

### 1.1 ARM v1 — `v1_vifprop.sv`, BOTH SIDES OF EVERY CELL

Read with `viarm.sh` + `vtab.sh` on the PRISTINE binary `3479e2d1…` and the
FINAL binary `2ce72eec…`, same file both times.
`UNMEASURED` = the object does not exist on that side at all.

| cell | source | golden (LHS) | ours BEFORE (RHS) | ours AFTER |
|---|---|---|---|---|
| `c1_modport` | `virtual v_if.IP vi;` | `logic_var` 16:20-16:22, name/fullname/**automatic 1**/**vis 1**, NO typespec | **UNMEASURED** | identical ✓ |
| `c2_bare` | `virtual v_if vi;` (**the majority spelling**) | `logic_var` 22:17-22:19, same five fields | **UNMEASURED** | identical ✓ |
| `c3_kw` | `virtual interface v_if vi;` | `logic_var` 28:27-28:29, same | **UNMEASURED** | identical ✓ |
| `c4_kwmodport` | `virtual interface v_if.IP vi;` | `logic_var` 34:30-34:32, same | **UNMEASURED** | identical ✓ |
| `c5_two` | two properties, same iface type | **TWO** `logic_var`s 40:20 / 41:20, **nothing shared** | both UNMEASURED | both, unshared ✓ |
| `c6_argonly` | ctor arg only, no property | CONTROL: **no variable at all** | equal | unchanged ✓ |
| `c7_both` | property **and** ctor arg (SVSwitch's shape) | `logic_var` 55:20-55:22 for the PROPERTY only | UNMEASURED | identical ✓ |
| `c8_quals` | `local` / `protected` / `static` | vis **3** / vis **2** / **no vpiAutomatic**, vis 1 | all three UNMEASURED | all three identical ✓ |
| `c9_twodecl` | `virtual v_if.IP vx, vy;` | TWO `logic_var`s, 72:20 and **72:24** | both UNMEASURED | both identical ✓ |
| `c10_arr` | `virtual v_if.IP va[4];` | an **`array_var`** (vpiSize 4, bare `array_typespec`, unelaborated range, `vpiReg` logic_var) | UNMEASURED | **still UNMEASURED — residue R2** |
| `c11_init` | `virtual v_if.IP vi = null;` | `logic_var` + `vpiExpr` = `vpiNullConst` | UNMEASURED | identical ✓ (law A′) |
| `c12_order` | `int pre_i;` BEFORE the property | listing order is **DECLARATION order**: pre_i, vi, after | vi UNMEASURED | order correct ✓ |
| `m1` module var | `virtual v_if.IP mvi;` at module scope | a `logic_net`, **absent from the ELAB view** | present in BOTH views | typespec fixed (law C); **ELAB presence is residue R3** |

`vtab.sh` over the property keys: **17 cells, 17 differing (pristine) → 17
cells, 3 differing (final)**, and all 3 survivors are the one `c10_arr` object
(`array_var` + its `ref_typespec` + its `array_typespec`).

### 1.2 LAW A′ — `§ virtualIfaceNullInitIsClassParented6`

Same site, inside the property-initializer whitelist.
**DIRECTION: ADD.** `virtual v_if.IP vi = null;` rides a constant with
`vpiConstType:11` (`vpiNullConst`, `sv_vpi_user.h:270`), `vpiSize:64`,
`vpiDecompile:0`, `UINT:0` — and **its `vpiParent` is the CLASS_DEFN, not the
variable**.

That is not a slip and I did not guess it: `bindProperties_` builds the
initializer with `exp->VpiParent(defn)`, and the ONLY `makeVar_` arm that does
not re-parent is the fallback arm — the one this property lands in. So the gate
is `vifProp6 && NullLiteral`, **not** `NullLiteral`: a `null` initializer on any
other property kind reaches a re-parenting arm and is left alone. Witness cell
`c11_init`, both sides, both binaries.

---

## 2. LAW B — `§ classDefnVirtualFromVirtualIfaceDecl6`

`src/UhdmExporter.cpp`: the predicate `hasVirtualIfaceSyntax6` immediately above
`emitClassDefn`, the use at the `cls.isAbstract` site inside it.

**DIRECTION: ADD a field.** `cd->VpiVirtual(true)` when the class body writes a
`virtual <iface>` type anywhere — even though the class is not abstract.

**WHY IT IS NECESSARY, and it is the reason law A alone would not have moved the
head far.** `class_defn::Compare`
(`UHDM/build/generated/src/class_defn.cpp`, grep `lhs->VpiVirtual()`) reads
`vpiVirtual` **immediately after** the `scope` base — i.e. immediately after the
`vpiVariables` listing law A fixes. Without law B the SVSwitch head would have
moved exactly one field along and stayed on `class_defn (work@Driver)`.

**THE GATE, transcribed not guessed.** Surelog's rule is literally
`if (fC->sl_collect(id, VObjectType::paVIRTUAL)) defn->VpiVirtual(true);`
(`CompileClass.cpp`, grep `defn->VpiVirtual`), and `sl_collect` recurses the
whole subtree (`FileContent.cpp`, grep `NodeId FileContent::sl_collect`). The
grammar emits a standalone `paVIRTUAL` node in `VIRTUAL? CLASS` and in
`VIRTUAL INTERFACE? interface_identifier` (`SV3_1aParser.g4:266`, `:886`,
`:1346`). Our equivalent is a walk of the class declaration's SYNTAX subtree for
`SyntaxKind::VirtualInterfaceType`.

**A REFUTATION I had to measure rather than reason about.**
`method_qualifier: VIRTUAL # MethodQualifier_Virtual` (`SV3_1aParser.g4:612`)
also contains the token `VIRTUAL`. If that produced a `paVIRTUAL` node, EVERY
UVM class with a virtual method would carry `vpiVirtual:1` and this law would be
enormous — and my syntax walk would under-fire on all of them. **Measured: cell
`k3_virtmethod` (a plain class whose only `virtual` is `virtual function int
f()`) reads vpiVirtual ABSENT on BOTH sides.** The labelled alternative does not
mint the node. The law stays narrow.

**MY FIRST SCAN OF THIS WAS WRONG AND SAID THE OPPOSITE.** My first per-class
`vpiVirtual` scanner attributed a field to whichever `class_defn` header it had
seen last, including the back-reference headers printed under `vpiParent`, and
reported `k3_virtmethod = True`. The corrected scanner keys on the DEFINITION
header's indent. **The superseded reading — "a virtual method sets vpiVirtual" —
is WRONG; do not carry it forward.**

**`pure virtual` is UNMEASURABLE here and I say so rather than claim it.**
`pure_virtual_qualifier: PURE VIRTUAL` (`:576`) can only appear in a `virtual
class` (already true) or in an `interface class` — and golden emits **no
`class_defn` at all** for an interface class (cell `k10_ifclass`, §5 R5). So
this half has no observable cell. By analogy with `k3_virtmethod` it should not
fire, and the implementation does not fire on it.

### 2.1 ARM v2 — `v2_virtualkw.sv`, BOTH SIDES OF EVERY CELL

| cell | source | golden (LHS) | ours BEFORE | ours AFTER |
|---|---|---|---|---|
| `k1_plain` | class, no `virtual` anywhere | **CONTROL: ABSENT** | ABSENT | unchanged ✓ |
| `k2_virtclass` | `virtual class` | `vpiVirtual:1` | already 1 | unchanged ✓ |
| `k3_virtmethod` | plain class, `virtual function` | **CONTROL: ABSENT** | ABSENT | **still ABSENT** ✓ |
| `k4_purevirt` | `virtual class` + `pure virtual` | 1 (from `virtual class`) | already 1 | unchanged ✓ |
| `k5_localvif` | plain class, vif LOCAL VAR in a method body | **1** | ABSENT | 1 ✓ |
| `k6_typedef` | property via a typedef written **OUTSIDE** the class | **CONTROL: ABSENT** | ABSENT | **still ABSENT** ✓ |
| `k7_taskarg` | plain class, vif TASK argument | **1** | ABSENT | 1 ✓ |
| `k8_svswitch` | SVSwitch's shape verbatim | **1** | ABSENT | 1 ✓ |
| `k9_pkg::k9_cls` | vif property, class in a PACKAGE | **1** | ABSENT | 1 ✓ |
| `k10_ifclass` | `interface class`, `pure virtual` method | **no class_defn at all** | a class_defn | unchanged — residue R5 |
| `k11_innertypedef` | vif typedef written **INSIDE** the class | **1** | ABSENT | 1 ✓ |

`vtab.sh` over arm v2: **62 cells, 15 differing (pristine) → 62 cells, 7
differing (final)**. All 7 survivors are outside this pass's shape: 4 are the
`k10_ifclass` control (R5), 1 is the `vpiTypedef` edge (R4), 2 are the
PRE-EXISTING `k3`/`k4` function `endln` spans (golden ends a method header at
the header, we end it at `endfunction`) — present identically on the pristine
binary and untouched here.

---

## 3. LAW C — `§ virtualIfaceTsIsInterfaceTs6`

`src/TypeEmit.cpp`, first block of `UhdmExporter::makeTypespec` (grep the `§`
name). **DIRECTION: REPLACE.**

A WRITTEN `virtual <iface>[.<modport>]` type is an **`interface_typespec`**
carrying `vpiName = <iface>` and NOTHING else, spanned over
`<iface>[.<modport>]`. We minted a loc-only `logic_typespec` spanning the WHOLE
written type INCLUDING the `virtual` keyword.

**THE SPAN RULE, and one half of it was NOT the obvious one.**
* start = the interface NAME token, **not** the `virtual` and **not** the
  `interface` keyword. Cells `mvk` / `mvkm` (`virtual interface v_if mvk;`,
  col 3 = `virtual`, col 11 = `interface`, col 21 = `v_if`) read golden
  **103:21** — so the explicit-keyword spelling does NOT push the start. I added
  those two cells precisely because that half was unmeasured, and they confirm
  the rule rather than refute it.
* end = the MODPORT's end when there is one, the name's end when there is not:
  `48:24-48:31` for `v_if.IP` vs `100:11-100:15` for a bare `v_if`.

**NOT SHARED.** Golden mints one object per DECLARATION: the v1 design-level
typespec listing carries four separate `interface_typespec (v_if)` at 48:24,
57:24, 99:11 and 100:11. The implementation mints per call, matching.

**GATE: the WRITTEN syntax must be `SyntaxKind::VirtualInterfaceType`.** A
TYPEDEF'd spelling is deliberately left alone — golden's object there is the
typedef's own (§5 R4) and this pass did not measure the variable-side half. That
is a deliberate narrowing, not an oversight.

### 3.1 ARM — BOTH SIDES

| position | source | golden (LHS) | ours BEFORE | ours AFTER |
|---|---|---|---|---|
| function formal | `function new(virtual v_if.IP vin)` | `interface_typespec (v_if)` **48:24-48:31** | `logic_typespec` 48:16-48:31 | identical ✓ |
| function formal, 2nd class | same, `c7_both` | `(v_if)` 57:24-57:31 | `logic_typespec` 57:16 | identical ✓ |
| TASK formal | `task t(virtual w_if.IP vin)` | `(w_if)` 53:18-53:25 | `logic_typespec` 53:10 | identical ✓ |
| method-body LOCAL | `virtual w_if.IP lv;` inside a function | `(w_if)` 38:13-38:20 | `logic_typespec` 38:5 | identical ✓ |
| module var, modport | `virtual v_if.IP mvi;` | `(v_if)` 99:11-99:18 | `logic_typespec` 99:3 | identical ✓ |
| module var, BARE | `virtual v_if mvb;` | `(v_if)` 100:11-100:15 | `logic_typespec` 100:3 | identical ✓ |
| module var, `interface` kw | `virtual interface v_if mvk;` | `(v_if)` **103:21**-103:25 | `logic_typespec` 103:3 | identical ✓ |
| module var, kw + modport | `virtual interface v_if.IP mvkm;` | `(v_if)` **104:21**-104:28 | `logic_typespec` 104:3 | identical ✓ |

`vtab.sh` on the `v_if` typespec key: **1 cell, 1 differing (pristine) → 1 cell,
0 differing (final)**.

---

## 4. GATES — all five, on the FINAL binary `2ce72eec181f1fe1268a063d8aa901bb`

1. **Build** — `cmake --build build -j 3` in this worktree: exit 0. The md5
   differs from the pristine control `3479e2d1…`, asserted before every gate
   below, so nothing here was measured against a stale binary.
2. **Goldens** — `bash tests/check_goldens.sh` with `SLANG_UHDM` exported to this
   worktree's build: **PASS 23 / FAIL 0**. Negative control
   `SLANG_UHDM=/bin/false`: **PASS 0 / FAIL 23**, so the
   `verify_golden.py:52` / `check_goldens.sh:5` main-tree default is not what
   got measured.
3. **uhdm2rtlil, `testflags`, `--jobs 2`, own `--out`, own `--workdir`** —
   **731 rows** (the committed CSV is 732 LINES including its header):
   **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, dump
   **496 match / 183 differ / 52 blank**. Whole-row diff against
   `results/gate_uhdm2rtlil.csv`, status *and* dump column: **0 lines.**
   `default` was NOT run (no committed baseline) and nothing here implies it was.
4. **surelog, `--mode both`, `--jobs 2`, own `--out`, own `--workdir`** —
   **1588 rows** (CSV 1589 LINES): `default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL**
   / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL, dump **match 225**;
   `testflags` **463 CMP_EQUAL / 10 CMP_NOTEQUAL** / 5 DEFERRED / 286
   SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT
   / 1 NO_UHDM, dump **match 165**. Every cell equals the `ea457fb` baseline and
   **the dump match counts did not fall**. Whole-row diff against
   `results/golden_surelog.csv`: **0 lines.**
5. **BYTE VERIFIER on BOTH corpora** — see §4.2.

**POSITIVE CONTROL ON THE HARNESS ITSELF.** The PRISTINE binary was swept the
same way into its own workdirs and reproduced BOTH committed baseline CSVs
exactly (0-line diffs on both). So the zero-row-change reading above is a real
measurement, not a driver that cannot see its probe.

The known `Google,testflags` golden-side environment flake shows as `TIMEOUT` in
BOTH sweeps and in the committed baseline — named, not filtered, not promoted.
`results/golden_surelog.csv`'s `LowMemPkg,testflags` row embeds an absolute
SESSION-SCRATCHPAD path; it reproduced identically here (row diff empty), so the
judge is sound. Not "fixed", per the standing instruction. Neither committed CSV
was rebuilt, edited, or included in the patch.

### 4.1 CANARIES — spot-checked BY NAME, all 37 (66 rows)

Every named canary's `(status, dump)` was compared cell by cell against the
committed baselines: **0 rows moved, 0 canary names with no row.** Including the
two live conversions `InterfaceModPort` (CMP_EQUAL/differ, both modes) and
`BlackParrotComplex` (CMP_EQUAL/differ, both modes); the four rows regressed by
over-fires in recent passes — `TypespecExpr` (match/differ), `ClogCast`
(match/match), `2DFunctionArg` (match), `PartSelect4` (differ/differ) — all at
baseline; and `Earlgrey_0_1` (CMP_NOTEQUAL / SLANG_REJECT), `LowMemPkg` default
(CMP_EQUAL/match). The four slang-fenced tests `UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam` were never dispatched.

### 4.2 BYTE VERIFIER — this is where the reach is

`byteverify.sh <patched-workdir> <pristine-workdir>`, both corpora, both with
`SELFCHECK=1 SELFCHECK1=1`.

| corpus | databases | path sets | movers | all-vs-one control | ONE-corruption control |
|---|---|---|---|---|---|
| uhdm2rtlil | 679 / 679 | IDENTICAL | **0** | 678 / 679 flagged | **1** ✓ |
| surelog | 953 / 953 | IDENTICAL | **6 real (+1 flake, see below)** | 952 / 953 flagged | **7** = 6 real + 1 ✓ |

> **CORRECTION BY THE r10oth6 VERIFIER — the surelog mover count is NOT
> run-to-run reproducible, and the flat "6" above nearly cost the next reader a
> false regression.** The verifier's sweep of the SAME two binaries reported
> **7** movers and `SELFCHECK1`=**8**, the extra one being
> `./default/Scoreboard-59431470/slang.uhdm`. That is the Scoreboard
> nondeterminism the brief and r10oth5's README C7 both name, NOT a law effect.
> **Settled by re-running Scoreboard 4x per binary** (`vsbflake.sh`
> method, default mode, md5 of each database):
> patched `7adc18e16775, 2e97c21d927c, 7adc18e16775, 7adc18e16775`;
> pristine `7adc18e16775, 7adc18e16775, 2e97c21d927c, 7adc18e16775`.
> **BOTH binaries emit BOTH md5s**, so Scoreboard is not a mover — but it will
> appear as one in roughly a quarter of sweeps. Expect **6 or 7**; only a mover
> that is NOT Scoreboard is news. The row below saying Scoreboard is "not a
> mover" is correct as a conclusion; it was not reproducible as a raw reading.

The `SELFCHECK1` control is new this pass and is the one the brief asked for: it
copies the pristine tree, flips one byte in exactly one database, and requires
the comparator to report exactly one extra mover. It does.

**EVERY MOVER EXPLAINED.** All six are the same three tests × two modes:

| mover | law A `logic_var`+ | law B `vpiVirtual`+ | law C `interface_typespec`+ / `logic_typespec`− | row before → after |
|---|---|---|---|---|
| `SVSwitch` (both modes) | **4** | **3** | **10 / 10** | CMP_NOTEQUAL → CMP_NOTEQUAL (no change) |
| `SeqDriver` (both modes) | **1** | **2** | 0 / 0 | CMP_NOTEQUAL → CMP_NOTEQUAL |
| `SimpleUVM` (both modes) | **1** | **1** | 0 / 0 | CMP_NOTEQUAL → CMP_NOTEQUAL |
| `Scoreboard` | 0 | 0 | 0 / 0 | **not a mover** — it has no virtual interface, exactly as the brief predicted |

Counted by `vmints.sh`, which diffs OUR pristine dump against OUR patched dump
(both sides ours — this is not a golden comparison), strips the dump's first
line, and prints `UNMEASURED` for a cell it cannot resolve (verified: a bogus
cell name prints UNMEASURED and exits 3). **This is the proof the code ran and
the count of the mint sites.** SVSwitch's 4 + 3 + 5 objects (the 10/10 typespec
figure counts each object's two dump appearances) is exactly the hand count of
its sources: 5 virtual-interface properties of which 1 is the ARRAY residue R2,
3 classes containing one, 5 constructor formals.

### 4.3 HEADS BEFORE AND AFTER — the four UVM-family tests, both modes

LHS is golden, RHS is ours.

| test | mode | pristine lines / head | FINAL lines / head |
|---|---|---|---|
| **SVSwitch** | default | **2880** / `class_defn (work@Driver)` | **361** / `class_defn (work@mailbox)`, `RHS: <null>` |
| **SVSwitch** | testflags | **2880** / `class_defn (work@Driver)` | **361** / `class_defn (work@mailbox)`, `RHS: <null>` |
| SeqDriver | default | 29 / `io_decl (key)` id 52862, `LHS: <null>` | **29 / the SAME object, same ids — UNCHANGED** |
| SeqDriver | testflags | 29 / same | 29 / same |
| SimpleUVM | default | 29 / `io_decl (key)` id 49982, `LHS: <null>` | **29 / the SAME object, same ids — UNCHANGED** |
| SimpleUVM | testflags | 29 / same | 29 / same |
| Scoreboard | default | 29 / `io_decl (key)` | 29 / same (not a mover at all) |
| Scoreboard | testflags | SLANG_REJECT | SLANG_REJECT — **UNMEASURED**, no golden cell |
| BuildUVMPkg | both | 17 / `ref_typespec (uvm_pkg::uvm_pool::type_id)` | 17 / same |

**SeqDriver and SimpleUVM moved BYTES but not their heads**, and that is
information the other slot needs: their heads sit on an unrelated
`uvm_pkg::uvm_pool::get` `io_decl` that golden does not emit at all, so this
pass's laws are behind that head, not in front of it. Neither converted; neither
regressed.

**SVSwitch's new head, decoded.** Golden's io_decl `mailbox drvr2sb`
(`Driver.sv:18`) carries `class_typespec (mailbox)` → `vpiClassDefn` →
`class_defn (work@mailbox)`. **Ours carries the `class_typespec (mailbox)` with
its `vpiName` but with NO `vpiClassDefn` edge at all** — hence `RHS: <null>`.
Immediately beside it in the same dump is the MIRROR-IMAGE defect on a different
class: golden's `class_typespec (packet)` at `Driver.sv:32` has BOTH `vpiName`
and `vpiClassDefn`; ours has the `vpiClassDefn` but NO `vpiName`. Two halves of
one cluster, neither of them this pass's shape. Ranked R1.

**A METHOD WARNING ABOUT THAT HEAD.** `class_defn (work@Environment)` sorts
BEFORE `work@mailbox` in the `uhdmallClasses` listing and STILL carries a real
difference (residue R2, its `output_intf[4]`), yet uhdm-cmp reports mailbox as
the head. That is `Compare`'s `m_visited` short-circuit
(`if (!context->m_visited.insert(this).second) return r;`) — Environment was
already visited through another edge. **Do not read this pass's head as proof
that everything sorting before it is equal.**

---

## 5. RANKED RESIDUE — most reachable first

**R1 — `class_typespec`'s two half-missing edges. DIRECTION: ADD (both halves).
Depth: medium. THIS IS SVSWITCH'S CURRENT HEAD.**
A `class_typespec` for a BUILTIN class (`mailbox`) has `vpiName` but no
`vpiClassDefn` on our side; a `class_typespec` for a user class reached as a
method-body local (`packet`, `Driver.sv:32`) has `vpiClassDefn` but no
`vpiName`. Golden has both fields in both cases. Reach: every `mailbox` /
`semaphore` / `process` handle and every class-typed method local — SVSwitch
alone shows four sites in its first 40 dump-diff lines. Not this pass's shape;
untouched.

**R2 — an UNPACKED ARRAY of virtual interfaces. DIRECTION: ADD. Depth: shallow
but a DIFFERENT object. Reach: 12 declarations corpus-wide (my count, §6), one
of them SVSwitch's `Environment.output_intf[4]`. HONESTLY NOT DONE.**
Golden's shape is fully measured in cell `c10_arr` and I am recording it so the
next pass does not have to re-measure: an `array_var` at the declarator-name
span with `vpiSize:4`, a ref to a **BARE `array_typespec` carrying no fields at
all**, `vpiAutomatic:1 vpiRandType:1 vpiVisibility:1 vpiArrayType:1`, a
`vpiRange` spanned at `[4]` whose LeftRange is a LOCATION-LESS `UINT:0` size-64
constant and whose RightRange is an **UNREDUCED `vpiOpType:11` operation** over
(`UINT:4` size 64 at the `[4]` span, LOCATION-LESS `INT:1` size 64), and a
`vpiReg` `logic_var` at the declarator-name span carrying **`vpiFullName` but NO
`vpiName`** (Surelog's `(obj)->VpiName("")`, `ElaborationStep.cpp`). I did not
implement it because 12 sites did not justify opening the general
fixed-unpacked-array class-property path in the last stretch of the pass.

**R3 — a module-scope virtual-interface variable is ABSENT from golden's ELAB
view. DIRECTION: DELETE (from `uhdmtopModules` only). Depth: shallow. Reach:
small.** Golden's DEF view (`uhdmallModules`) carries the `logic_net`; its ELAB
view (`uhdmtopModules`) does NOT. We carry it in both. Both views quoted
separately, cells `mvi`/`mvb`/`mvk`/`mvkm`. A related sub-cell: golden's
`interface_typespec` for a module net has **no `vpiParent`**, ours has
`vpiParent = the logic_net`; typespec parents are back-references and are not
read by `Compare`, so this is a dump difference only.

**R4 — `typedef virtual <iface>.<mp> <name>;` publishes an
`interface_typespec` on its scope's `vpiTypedef`. DIRECTION: ADD. Depth:
shallow. Reach: small.** Golden, cell `k11_innertypedef`:
`class_defn ... |vpiTypedef: \_interface_typespec: (inner_t), line:85:19,
endln:85:26, |vpiName:inner_t` — named after the TYPEDEF, spanned over
`w_if.IP`. At DESIGN scope (cell `wif_t`, arm v2 line 44) the same object also
carries `|vpiInstance: design`. We emit nothing. Law C deliberately does not
touch the typedef spelling.

**R5 — an `interface class` gets NO `class_defn` in golden. DIRECTION: DELETE.
Depth: unknown. Reach: unmeasured (my only cell is one I wrote).** Cell
`k10_ifclass`: golden emits no `class_defn`, no method, no return var, no
typespec; we emit all four. PRE-EXISTING — it is visible on the pristine binary
too and this pass did not change it. It also blocks the `pure virtual` half of
law B (§2).

**R7 — law C's span IGNORES `VirtualInterfaceTypeSyntax::parameters`.
DIRECTION: REPLACE (the end token). Depth: shallow. Reach: 26 written
`virtual <iface> #(` sites across both corpora. FOUND BY THE r10oth6 VERIFIER;
LATENT — it moves no row and no byte today.** Measured on the verifier's arm
`v3_paramvif.sv` at MODULE scope (the only position law C runs in for a virtual
interface — law A pushes a class PROPERTY and `continue`s before any
ref_typespec is built, which is why the class-property half of that arm reads
`DUMP_MATCH`):

| source | golden | ours | verdict |
|---|---|---|---|
| `virtual p_if #(.W(4))     pm1;` | `37:11-37:24` | `37:11-37:15` | ours TOO NARROW — drops `#(...)` |
| `virtual p_if #(.W(4)).IP  pm2;` | `38:11-38:24` | `38:11-38:27` | ours TOO WIDE — golden stops at the parameters and EXCLUDES `.IP` |

So golden's end token is **`parameters.end` if parameters, else `modport.end` if
modport, else `name.end`** — not the two-way choice law C implements. The
no-parameter halves are correct and measured (arm v1 `mvi`/`mvb`/`mvk`/`mvkm`,
all byte-equal to golden). Recorded in `src/TypeEmit.cpp` at the law itself.

**R8 — a NESTED `virtual class` does not set the OUTER class's `vpiVirtual`.
DIRECTION: ADD. Depth: shallow. Reach: narrow (63 `virtual class` spellings
corpus-wide, only those nested INSIDE another class are affected). FOUND BY THE
r10oth6 VERIFIER; PRE-EXISTING, not a regression of this pass.** Golden's rule
is `sl_collect(classId, paVIRTUAL)` over the whole subtree, which also matches
the `VIRTUAL? CLASS` production; law B's `hasVirtualIfaceSyntax6` matches only
`VirtualInterfaceType`. Cell `v4_nestedvirt.sv`: `work@x1_outer` golden **1** /
ours **ABSENT**, with the control `x2_outer` (nested class NOT virtual) reading
ABSENT on both sides and `x1_inner` reading 1 on both. The law-B comment in
`src/UhdmExporter.cpp` used to claim the two predicates were "the same
predicate"; that sentence is now STRUCK at its source.

**R6 — the two PRE-EXISTING `function` `endln` spans (`k3`, `k4`). DIRECTION:
REPLACE. Depth: unknown. PRE-EXISTING, identical on the pristine binary.**
Golden ends a method at its HEADER (`22:3-22:10`, `30:3-30:15`); we end it at
`endfunction` (`22:3-24:14`, `30:3-30:33`). Named here only so a reader of the
arm table does not mistake it for a mover of this pass.

---

## 6. REFUTATIONS OF THE BRIEF — two numbers, both re-measured

Per the standing law "RE-MEASURE, DO NOT INHERIT A NUMBER, including every
number in this brief".

**~~REFUTED~~ → DIFFERENT MEASUREMENT: "135 virtual-interface class properties,
of which 24 carry a modport selector".** *(Downgraded from "REFUTED" by the
r10oth6 verifier: the master counted class PROPERTIES; the count below counts
properties AND formals AND locals AND module variables, which is a strict
SUPERSET. 512 ≥ 135 and 39 ≥ 24 are both consistent, so nothing here shows the
master's figure to be wrong — the two numbers measure different things and can
both be right. The 512/39 figures themselves reproduce exactly.)* My count,
`vreach.sh` (shipped), which uses the
`grep -rhoE ... | wc -l` form the master identified as the one that works:
**512 WRITTEN virtual-interface declarations across both corpora — 21 in
`Surelog/tests`, 485 in `Surelog/third_party/tests`, 6 in `uhdm2rtlil/test` — of
which 39 are modport-selected.** My definition is broader than the master's on
purpose and is stated in the script: it counts every WRITTEN
`virtual [interface] <name>[.<mp>] <ident>` that is not `virtual
class/function/task/protected/local/static/pure`, i.e. properties AND formals
AND method locals AND module variables, since all three laws key off the same
spelling. Top tests: Google 134, Opentitan 95, Ibex 61, Ariane2024 25, ariane 23.
The number is an upper bound to the extent a match can fall inside a comment;
`vreach.sh` prints a per-test breakdown so any cell can be hand-checked.

**REFUTED: "Per comparable test: SVSwitch 4".** Hand-verified, all ten lines
listed by `grep -rn`: **SVSwitch has 10 sites** — 5 class properties
(`Driver.sv:13`, `Receiver.sv:14`, `Environemnt.sv:15,16,17`, the last being the
array `output_intf[4]`) and 5 constructor formals (`Driver.sv:18`,
`Receiver.sv:18`, `Environemnt.sv:25,26,27`, the last an array). The `vmints.sh`
mint counts (4 `logic_var`s, 5 typespec objects) reproduce that split exactly,
which is the sanity-check the brief demanded before ranking on a count.

**CONFIRMED: `Scoreboard` 0 and `BuildUVMPkg` 0.** Neither is a byte mover.
**CONFIRMED: `SeqDriver` and `SimpleUVM` contain the shape** — 1 property each,
both now emitted.
**CONFIRMED: the uhdm2rtlil corpus cannot be hurt by this shape** — 0 byte
movers in 679 databases.

---

## 7. ASSETS SHIPPED (every one of them cited above exists here)

| file | what it does |
|---|---|
| `v1_vifprop.sv` | arm 1 — 12 class-property spellings + 4 module-variable spellings |
| `v2_virtualkw.sv` | arm 2 — 11 cells bounding law B, plus the package / typedef / task-arg positions |
| `viarm.sh` | arm driver. `SLANG_UHDM` has NO DEFAULT; strips the dump's first line on BOTH sides; guards both uhdm-cmp inputs; the JUDGE is `diff -u g.dump o.dump`, not `PASS_CMP` |
| `vtab.sh` | joins the two sides into one table per `(kind, fullname)`, printing `UNMEASURED(no such object on this side)` where a side has none. **Known limitation, stated because a silent one is worse: objects that share a kind AND a fullname collapse into one key** (the four `interface_typespec (v_if)` are one row) — read `d.diff` for per-span cells |
| `vmints.sh` | counts MINT SITES per law by diffing OUR pristine dump against OUR patched dump; prints `UNMEASURED` for an unresolvable cell (exit 3) |
| `vreach.sh` | corpus reach counter, with the per-test breakdown that makes it hand-checkable |
| `byteverify.sh` | r10oth4's, plus the new `SELFCHECK1` single-corruption control |
| `caform.py` | r10oth5's DEF/REF flattener, carried forward unchanged (byte-identical — verified) |
| `v3_paramvif.sv` | VERIFIER-ADDED arm 3 — the parameterised spelling law C's span never saw (residue R7) |
| `v4_nestedvirt.sv` | VERIFIER-ADDED arm 4 — the nested `virtual class` law B's predicate never saw (residue R8) |

Every arm cell's comment was checked against its own source line before this file
was written.

---

## 8. INDEPENDENT VERIFIER'S AUDIT (r10oth6)

Everything below was re-measured from scratch on a fresh worktree at `ea457fb`
with the patch applied, against a pristine control built in the same tree.
Binaries: patched `2ce72eec181f1fe1268a063d8aa901bb`, pristine
`3479e2d10a75171848cf3aa83498d65a` — both reproduce the implementer's md5s
exactly, and the pristine build is bit-identical to the main-tree binary.

**REPRODUCED, all five gates.** Goldens 23 PASS / 0 FAIL with `/bin/false`
giving 0 PASS / 23 FAIL. uhdm2rtlil 731 rows 679/50/2, dump 496/183/52, whole-row
diff vs the committed CSV **0 lines**. surelog 1588 rows, default 467 CMP_EQUAL /
13 CMP_NOTEQUAL dump-match 225, testflags 463 / 10 dump-match 165, whole-row diff
**0 lines**; match counts did not fall. Byte verifier both corpora with both
controls. **The pristine binary reproduced BOTH committed CSVs exactly**, so the
zero-change readings are live measurements. Canaries: **119 rows compared by
name, 0 moved, 0 canary names with no row**. The four slang-fenced tests appear
in the corpus sweep exactly as they do in the committed baseline (all
`CMP_NOTEQUAL`, unchanged) and were not dispatched individually.

**THE CENTRAL QUESTION.** SVSwitch did **NOT** convert — `CMP_NOTEQUAL` in both
modes, **361** cmp lines (from **2880**), head now `class_defn (work@mailbox)`
with `RHS: <null>`. All reproduced independently.

**THE MODEL IS CONFIRMED ON THE DUMP, NOT ON CMP.** Golden's object and ours are
byte-identical *and land at the same dump line numbers (54 and 58)*, i.e. the
mint lands FIRST as the ordering rule requires:
`\_logic_var: (work@Driver::input_intf), line:13:29, endln:13:39` with
parent / vpiName / vpiFullName / `vpiAutomatic:1` / `vpiVisibility:1` and **no
vpiTypespec**. The pristine dump has no such object at all.

**A NUMBER THE CMP COLLAPSE DOES NOT MEAN.** cmp fell 2880 → 361, but the
whole-design **dump** distance fell only **2761 → 2713** true content lines
(48 lines). uhdm-cmp's report length is a head-depth measure, not a distance;
quoting the collapse without the dump figure overstates the move by ~50x.

**PRODUCER TRANSCRIPTION VERIFIED IN SURELOG'S SOURCE.**
`ElaborationStep.cpp` `// default type (fallback)` does mint a bare `logic_var`
and does `var->Expr(assignExp)` with no re-parent; `CompileClass.cpp`
`if (fC->sl_collect(id, VObjectType::paVIRTUAL)) defn->VpiVirtual(true)`; and
`FileContent.cpp` `NodeId FileContent::sl_collect` is genuinely recursive.

**LAW B VERIFIED CELL BY CELL AND ON THE REAL CORPUS.** Arm v2: all ten cells
match golden, the only delta being the pre-existing R5. On SVSwitch itself the
whole per-class `vpiVirtual` table is identical to golden — including
`work@packet`, which has FOUR `virtual function` declarations and reads ABSENT on
both sides. That is real-corpus proof (not just an arm) that the narrow
predicate is right, and it confirms the implementer's self-refutation of his
first scanner.

**THE MASTER'S "UNMEASURED MAJORITY HALF" DOES NOT EXIST HERE.** `c2_bare`
(`virtual v_if vi;`, no modport) is byte-identical to golden, and law C's four
module spellings all carry golden's exact spans — including `mvk` at column 21,
hand-verified against the source text, which confirms the explicit `interface`
keyword is outside the span.

**CORRECTIONS APPLIED AT VERIFICATION (V1-V5).**

**V1 — a production comment contradicted itself and was refuted by measurement.**
`hasVirtualIfaceSyntax6` claimed a `VirtualInterfaceType` walk is "the same
predicate" as Surelog's `sl_collect(paVIRTUAL)` while its own previous sentence
named the counterexample. Struck at source; filed as **R8** with a new cell.

**V2 — `viarm.sh`'s `content=` was inflated by EXACTLY 2** on every non-empty
diff: `grep -c '^[-+]'` also counts `diff -u`'s own `---`/`+++` header. Stripping
the dump's first line does not fix this — they are two different traps.
Measured: 2715 raw vs 2713 real. Fixed in `viarm.sh` and in `vmints.sh`.

**V3 — `vreach.sh`'s self-check comment contradicted its own output.** It said
"SVSwitch must read 4"; the script prints 10, and README §6 refutes 4. That is
the master's inherited property-only number left standing inside the instrument
that disproves it. Corrected to "SVSwitch must read 10, Scoreboard 0".

**V4 — the surelog byte-mover count is not run-to-run reproducible.** See the
correction block in §4.2. Expect 6 or 7; only a non-Scoreboard mover is news.

**V5 — `vmints.sh` printed a line count where the write-ups quote an object
count** (`interface_typespec+=10` vs "5 typespecs"). §4.2 already explained it;
the tool now labels the column and prints both.

**NOT DEFECTS — checked and cleared.** Every cited asset exists and runs;
`vtab.sh` and `vmints.sh` both bite their UNMEASURED controls (exit 3);
`caform.py` is byte-identical to r10oth5's as claimed; residue number **R4** is
consistent across the code comment, this README and the pass report (no repeat of
the r10oth5 C2 three-numbers-for-one-residue failure); R2's recorded `array_var`
shape is correct line by line; R3's "no `vpiParent` on golden's side" sub-claim
is correct; the SeqDriver / SimpleUVM heads are byte-identical before and after
with the same object ids (52862 / 49982) and `LHS: <null>`; BuildUVMPkg 17 lines
unchanged; and the ordering churn left in arm v1's typespec listing is
PRE-EXISTING (the same hunks appear in the pristine diff), not a new over-fire.
