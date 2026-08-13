# r10sd2 — § instanceIsNeverAClassDefn2, and the SeqDriver package head ANATOMISED

**The brief's law is FALSE and this pass proves it with a cell-for-cell census.**
The SeqDriver head is **not** a design package-vector divergence of any kind: our
`design.uhdmallPackages` and `design.uhdmtopPackages` are **byte-for-byte identical
to golden's — same size, same order, same names, same spans, same per-entry vector
NULL-ness — on ALL FOUR UVM designs in BOTH modes** (7 live rows). Had I coded to
the brief I would have changed package-vector emission that is already exactly
right.

What the head actually is has been read out of `Compare` itself, not inferred:
it is the **singular** `SafeCompare(lhs=nullptr, rhs)` arm, the RHS is our
**TopPackages** copy of `uvm_pkg` (pointer-verified against both vectors), the
only relation in these databases that can hold a `package` is **`vpiInstance`**,
and the divergence sits inside the subtree of golden
`class_typespec@199:3-199:20` (`uvm_globals.svh`) → `class_defn(uvm_coreservice_t)`.
The exact slot is **not** closed here and is ranked R1 with the instrument that
will close it.

**This pass ships ZERO production change.** The delivered binary's md5 is
**identical** to the pristine binary's, so "0 movers" is not a measurement, it is
an identity — and every gate is green by construction and was still run.

| | |
|---|---|
| BASE | `6e1c27a` (printed and grep-checked in both worktrees) |
| worktrees | `/tmp/wt_r10sd2` (delivered), `/tmp/wt_r10sd2pris` (pristine control) |
| delivered binary | md5 `f1fee994fffdfc1e2d7883d791e1621f` |
| pristine binary | md5 `f1fee994fffdfc1e2d7883d791e1621f` — **the same 32 hex** |
| patch | `/tmp/r10sd2.patch`, md5 in §10 |
| production files touched | **NONE** |
| probe files added | `tools/probe/r10sd2repro/` only |

---

## 1. THE LAW

> **§ instanceIsNeverAClassDefn2** — Surelog's `vpiInstance` names a **scope that
> can hold an instance**: a `package` (either view), a `module_inst`, an
> `interface_inst`, or the `design`. It **NEVER** names a `class_defn`. Measured
> across every UVM database in the corpus, both modes: golden = **0**
> occurrences, ours = **203 … 428** per design.

This is a **measured fact about golden**, stated in greppable form and shipped
**unfixed on purpose** (§7). It is *not* the head — that is proved by mutation in
§4.4, not asserted.

### 1.1 Population, whole-database, both sides

`ct2view.cpp` classifies every `vpiInstance` by *which object* it names, keeping
the two package VIEWS apart (`ALL:` = `uhdmallPackages` copy, `vpiTop=0`;
`TOP:` = `uhdmtopPackages` copy, `vpiTop=1`). Golden's `class_defn` column is
**identically zero in all four designs**:

| state | SeqDriver G | SeqDriver O | SimpleUVM G | SimpleUVM O | Scoreboard G | Scoreboard O | BuildUVMPkg G | BuildUVMPkg O |
|---|---|---|---|---|---|---|---|---|
| `<null>` | 34299 | 32039 | 23319 | 23515 | 23023 | 23513 | 22767 | 23872 |
| `ALL:uvm_pkg` | 3489 | 3375 | 3455 | 3268 | 3455 | 3268 | 3613 | 3413 |
| `TOP:uvm_pkg` | 11290 | 6712 | 4059 | 3309 | 4004 | 3309 | 4081 | 3446 |
| `ALL:adpcm_pkg` | 1052 | 1544 | — | — | — | — | — | — |
| `TOP:adpcm_pkg` | 929 | 1403 | — | — | — | — | — | — |
| `OTHER:design()` | — | — | 34 | 35 | 34 | 35 | — | — |
| **`OTHER:class_defn(*)`** | **0** | **428** | **0** | **214** | **0** | **214** | **0** | **203** |

The `class_defn` column spreads over **19 distinct class names**
(`uvm_mem` 80, `uvm_reg` 68, `uvm_vreg` 52, `uvm_reg_map` 48, `uvm_reg_field` 36,
`uvm_vreg_field` 32, `uvm_phase` 20, `uvm_reg_file` 20, `uvm_mem_mam` 12,
`uvm_transaction` 12, `uvm_component`/`uvm_packer`/`uvm_printer` 8 each, and
`uvm_mem_region`/`uvm_reg_block`/`uvm_sequence_library`/`uvm_table_printer`/
`uvm_tlm_generic_payload`/`uvm_tree_printer` 4 each — SeqDriver figures).
`typespec::Compare` reads `Instance()`, so these slots are **cmp-visible**, and
the owner is always a `typespec` (`variables` = 0, `task_func` = 0 — measured).

`OTHER:design()` is the control that keeps the law honest: golden **does** point
`vpiInstance` at the `design` object (34 times on SimpleUVM), so the law is not
"only true instances" — it is specifically **never a `class_defn`**.

---

## 2. STATED GATE == CODE GATE

**There is no code gate.** No production file is touched; `git diff 6e1c27a --
include src` is empty and the delivered binary's md5 equals the pristine
binary's. The law in §1 is a finding, and §7 R2 names the candidate emission
sites so the next pass does not have to re-grep for them:

```sh
grep -rn -F "(UHDM::instance*)" src/ include/ | wc -l     # 100+ C-style casts
# the ones that can put a NON-instance there, from the same grep:
#   src/UhdmExporter.cpp:4872, 4906    ts->Instance((UHDM::instance*)(BaseClass*)d)   # the DESIGN — golden does this too
#   src/ParamEmit.cpp:12912, 12915     hi9 = (UHDM::instance*)tit9->second           # typedef-home map
#   src/ParamEmit.cpp:14858, 14870     clB->Instance((UHDM::instance*)pkgDefMap[...])
#   src/TaskFuncEmit.cpp:3453-3455     cl->Instance((UHDM::instance*)ci0)            # PROPAGATES, does not mint
```

The cast is the mechanism: `Instance()` takes `instance*`, a `class_defn` is not
one, and a C-style cast makes the compiler agree.

---

## 3. THE BRIEF'S LAW, REFUTED — the census it asked for, run

The brief: *"OUR design object lists `uvm_pkg` in a package vector position where
golden lists FEWER packages (or different order — a missing EARLIER sibling
shifts every later slot; census the WHOLE vector on both sides FIRST, by name,
before assuming surplus-at-end)."*

The census was run first, as instructed, on **both** vectors, **both** package
names, **both** modes, **all four** designs (`ct2pkgv.cpp`):

```
default/BuildUVMPkg    PACKAGE VECTORS IDENTICAL (6 lines)
default/Scoreboard     PACKAGE VECTORS IDENTICAL (8 lines)
default/SeqDriver      PACKAGE VECTORS IDENTICAL (8 lines)
default/SimpleUVM      PACKAGE VECTORS IDENTICAL (6 lines)
testflags/BuildUVMPkg  PACKAGE VECTORS IDENTICAL (6 lines)
testflags/SeqDriver    PACKAGE VECTORS IDENTICAL (8 lines)
testflags/SimpleUVM    PACKAGE VECTORS IDENTICAL (6 lines)
(testflags/Scoreboard is SLANG_REJECT at baseline — no database, correctly skipped)
```

Cell for cell for SeqDriver, both sides:

| vector | idx | name | span | `vpiTop` | `Class_defns` | `Typespecs` | `Task_funcs` | G == O |
|---|---|---|---|---|---|---|---|---|
| `AllPackages` (size 3) | 0 | `builtin` | 0:0 | 0 | NULL | NULL | NULL | ✅ |
| | 1 | `uvm_pkg` | uvm_pkg.sv 28:1-39:11 | 0 | **NULL** | 46 | 894 | ✅ |
| | 2 | `adpcm_pkg` | testbench.sv 10:1-207:22 | 0 | NULL | 124 | 894 | ✅ |
| `TopPackages` (size 3) | 0 | `builtin` | 0:0 | 1 | 5 | NULL | NULL | ✅ |
| | 1 | `uvm_pkg` | uvm_pkg.sv 28:1-39:11 | 1 | **323** | 89 | 58 | ✅ |
| | 2 | `adpcm_pkg` | testbench.sv 10:1-207:22 | 1 | 5 | 124 | 894 | ✅ |

**Every one of the brief's questions, answered:**

1. *"WHICH vector of design does uhdm-dump print here (`uhdmallPackages` vs
   `uhdmtopPackages`)?"* — **BOTH.** Surelog emits every package **twice**, as
   two distinct objects: the *def* view in `uhdmallPackages` (`vpiTop=0`,
   `Class_defns` NULL) and the *elaborated* view in `uhdmtopPackages`
   (`vpiTop=1`, `Class_defns=323`). Six package objects exist in the SeqDriver
   database on **each** side (`ct2pkgv` + the object enumeration in §4.2). Any
   reasoning that treats "the uvm_pkg object" as singular is wrong before it
   starts.
2. *"What is each side's FULL package list in that vector for SeqDriver?"* — the
   table above; identical.
3. *"…and for the OTHER UVM tests, where this may or may not diverge?"* —
   identical on all of them too.
4. *"Why is SeqDriver the only row with this head? Maybe it is not — the others'
   cmp may just fail EARLIER."* — **the brief's own alternative is the right
   one.** Measured heads, pristine `6e1c27a`, mode-matched goldens (§5.1): the
   other rows fail earlier, on entirely unrelated shapes.
5. *"What is golden's membership rule (packages with elaborated content? only
   packages named in a `$unit` import? source order?)"* — **none of those
   conditions matter**: the arm grid (§6) shows every declared package reaches
   **both** vectors in **source-declaration order**, whether it is unused (`p1`),
   imported-but-unused (`p2`), imported-and-used (`p3`), `$unit`-imported (`p4`)
   or shadowed by a later declaration (`p5`, where the never-imported `p5b`
   precedes the imported `p5a` because it is declared first). `builtin` is always
   index 0. **We reproduce this rule exactly in all 6 arms, both vectors.**

---

## 4. WHAT THE HEAD ACTUALLY IS — read out of `Compare`, four instruments deep

### 4.1 The arm

`BaseClass.h:186-224` has four arms that can print `LHS: <null>`:

```cpp
// SINGULAR
} else if ((lhs == nullptr) && (rhs != nullptr)) {
    context->m_failedRhs = rhs;        // the CHILD
    return -1;
// VECTOR
} else if ((lhs == nullptr) && (rhs != nullptr) && !rhs->empty()) {
    context->m_failedRhs = rhs_obj;    // the CONTAINER
    return -1;
```

`ct2design.cpp` (uvm67's, reused) puts the head at `design.AllPackages[1]`,
`r=-1`, `rhs=package(uvm_pkg)`, `m_failedLhs` **unset**. Two readings survive
that print; both were tested, not argued:

* **VECTOR arm ruled OUT.** `ct2pkgv.cpp` censuses every one of the 25 vectors
  `package::Compare` walks (scope's 17, then instance's 8) on every package
  object, distinguishing **NULL from empty**. All identical (§3). And seeding
  `CompareContext::m_visited` with **each of golden's six package objects in
  turn** leaves the head byte-identical — if the container were a package,
  suppressing it would remove the failing call.
* **SINGULAR arm CONFIRMED**, and the RHS is a specific object:
  `m_failedRhs` is **pointer-equal to our `TopPackages` copy** of `uvm_pkg`, not
  the `AllPackages` one. So some object's singular slot is NULL in golden and
  holds our **elaborated-view** `uvm_pkg` in ours.

### 4.2 Which relation can even hold a package

`ct2ptr.cpp` walks every object in each database out of `Serializer::AllObjects()`
and probes all **154** relations the VPI layer exposes (`ct2rels.inc`, generated
from `vpi_visitor.cpp`). In both databases, the set of relations that ever hold a
`package` has exactly **one** member: **`vpiInstance`**. Owners and counts:

```
owner . relation                    GOLDEN   OURS    DELTA
bit_typespec . vpiInstance            2924   1035    -1889
string_typespec . vpiInstance         3361   2470     -891
int_typespec . vpiInstance            2376   1707     -669
unsupported_typespec . vpiInstance    1145    483     -662
enum_typespec . vpiInstance            420     42     -378
class_typespec . vpiInstance          2080   2032      -48
function . vpiInstance                1574   1574       0
task . vpiInstance                     214    214       0
… (11 more shapes, all typespecs)
```

We are **short** almost everywhere and long in exactly three tiny shapes
(`chandle_typespec` +2, `long_int_typespec` +2, `real_typespec` +2). The head is
therefore a **specific slot**, not a systematic over-stamp.

### 4.3 Where it is — bisection by SUPPRESSION

Three localizers were built and two of them are **wrong for this head**; both are
kept, with their failure written into their own headers, because the next pass
will otherwise rebuild them:

* `ct2find.cpp` — descend, keeping any child whose own `Compare` reproduces the
  signature, fresh context each time. **WRONG**: `param_assign → parameter →
  ref_typespec → int_typespec → vpiInstance → uvm_pkg` is a **cycle**, so with a
  fresh context *every* child reproduces and the walk chases the cycle. It
  reported `int_typespec@47:11`, whose `Instance()` is `uvm_pkg` on **both**
  sides — a false positive, checked and discarded.
* `ct2slot.cpp` — mirror walk with a shared visited set, alphabetical relation
  order. **WRONG past the first divergence**: the two walks pair up different
  objects and the census reads 20 689 "shapes" of pure noise (its own top hit,
  `function . vpiInstance -> package(uvm_pkg)` ×3100, was tested in §4.4 and is
  **not** the head).
* `ct2owner.cpp` — **the one that works.** Every generated `Compare` opens with
  `if (!context->m_visited.insert(this).second) return 0;`, keyed on the **LHS**
  object, so pre-seeding a golden pointer makes the *real* `Compare` treat that
  object as equal wherever it is reached from. That is a suppression operator
  that **removes** a comparison without **adding** one, and ddmin over the golden
  object set then converges:

```
golden objects with a NULL singular Instance(): 34299
suppressing all of them REMOVES the head
  narrowed to 17150 … 8575 … 4287 … 2144 … 1072 … 536 … 268 … 134 … 67 … 33 … 16 … 8 … 4 … 2 … 1
>>> class_typespec@199:3-199:20  file=uvm_globals.svh
>>> with it suppressed, the next failure is
    lhs=int_typespec(uvm_action)@272:9-272:12  rhs=int_typespec@67:3-67:13
=== DESCENT BY SUPPRESSION ===
[0] class_typespec@199:3-199:20  -> .vpiClassDefn
[1] class_defn(uvm_coreservice_t)@49:9-113:9
```

`uvm_globals.svh:199` is `  uvm_coreservice_t cs;` inside
`function void uvm_report_warning(...)`. So **every path from the design to the
defect passes through that one class_typespec**, and through its
`class_defn(uvm_coreservice_t)`.

Excluding that chokepoint and re-running ddmin **stalls at 34 candidates** — all
34 are `class_typespec` objects with `Instance()==NULL`, in `uvm_comparer.svh`,
`uvm_component.svh`, `uvm_pair.svh`, `uvm_object_defines.svh`,
`uvm_cmdline_processor.svh`, `uvm_policies.svh`. Spot-checked spans
(`343:5-343:13`, `344:5-344:22`, `365:5-365:13`, `199:3-199:20`,
`uvm_object|286:40-286:50`) are `<null>` on **both** sides, so they are
**parallel paths**, not the slot: past the chokepoint the defect is reachable by
≥ 2 disjoint routes and single-object suppression cannot separate them. Closing
that last step needs a **set-valued** ddmin (R1).

### 4.4 Two hypotheses killed by mutation, not by argument

`ct2mut.cpp` nulls a field on our in-memory copy and re-runs the whole-design
`Compare`. Nothing is written to disk.

1. **"It's the `class_defn`-valued `vpiInstance` (§1)."** Nulling **all 428**
   of them: head **byte-identical** (`r=-1 lhs=<null> rhs=package(uvm_pkg)`),
   and the restore control returns the baseline exactly. **The §1 law is real
   and is NOT the head.**
2. **"Null our `vpiInstance` per owner type and see which one owns it."**
   Nulling `bit_typespec` (1085), `class_typespec` (2163), `string_typespec`
   (3008), `enum_typespec` (78) or `logic_typespec` (146) **flips the arm** to
   `r=1 LHS=package(uvm_pkg) RHS=<null>`. That is the instrument **introducing an
   earlier failure**, not removing one — which is precisely why a
   null-mutation bisect converges on "the first typespec in traversal order"
   (`bit_typespec@26:1-26:4`, the actual of `uvm_pkg.Variables[0]`, whose
   `Instance` is `uvm_pkg` on **both** sides). Recorded because it looks like a
   result and is not one.

### 4.5 The one refutation this pass owes its predecessor

`r10sd1`'s residue R1 states the head is *"**not** a `vpiInstance` divergence
(checked: 0 typespecs where golden is null and ours is `uvm_pkg`)"*. **That is
refuted.** `vpiInstance` is the *only* relation in these databases that can hold a
package at all (§4.2), so the head can be nothing else. The earlier check missed
it because a span+name key **collapses duplicates**: Surelog emits one copy of
every package-homed object **per package view**, ten `bit_typespec@26:1-26:4`
objects share one key in golden and six in ours, and a census that keeps one
value per key cannot see a population imbalance among them. `ct2view.cpp` keeps
the whole **multiset** per key for exactly this reason.

A second, cheaper trap in the same family, measured here: **our emission leaves
`VpiFile` EMPTY on nearly every object** while Surelog fills it. A file-keyed
census of the two databases shares **35 keys out of 20 397** and reads as "no
divergence at all". `VpiFile` is read by no `Compare` body, so dropping it from
the key is both necessary and faithful.

---

## 5. THE MEASUREMENTS

### 5.1 Row heads, pristine `6e1c27a`, mode-matched goldens

LHS always golden. Each row read against **its own** `cmds.txt` golden — the
default and testflags goldens are different cache entries and crossing them
fabricates a 6.8 M-line head (sd1's recorded ops trap; not repeated here).

| row | cmp lines | head LHS | head RHS |
|---|---|---|---|
| `default/SeqDriver` | **1414861** | `<null>` | `package uvm_pkg (uvm_pkg::) id:6032` |
| `testflags/SeqDriver` | **1414861** | `<null>` | `package uvm_pkg (uvm_pkg::) id:6044` |
| `default/SimpleUVM` | 112 | `func_call (open_recorder) @343:13-343:61` | `method_func_call (m_do_open) @343:27-343:36` |
| `testflags/SimpleUVM` | 112 | same | same |
| `default/Scoreboard` | 112 | same | same |
| `default/BuildUVMPkg` | 58 | `ref_obj (uvm_pkg::uvm_registry_common::__deferred_init::uvm_pkg::uvm_deferred_init)` | `hier_path (uvm_pkg::uvm_deferred_init.push_back) @14107:7` |
| `testflags/BuildUVMPkg` | 58 | same | same |

Every head is `grep -c '^LHS:' == 1`; the 1 414 861 is **subtree size**, not
distance. `testflags/Scoreboard` is `SLANG_REJECT` at baseline and produces no
database.

Note for the record: the brief describes the other three rows as sitting on
pass-67's `int_var … vpiSigned` head at 58 lines. **They have moved** — uvm68
landed in between — and SimpleUVM/Scoreboard are now at 112 on a
`func_call`/`method_func_call` shape. Any pass quoting the brief's numbers
without re-measuring will mis-read its own baseline.

### 5.2 Movers — ZERO, and by identity rather than by measurement

The delivered worktree changes no production file, so the two binaries are the
**same 32 hex** (`f1fee994fffdfc1e2d7883d791e1621f`). The census prediction was
therefore "0 movers, and any difference observed is a flake", made before the
sweeps. Confirmed:

```
byteverify  uhdm2rtlil  B vs A   : MOVERS 0 / 1358
byteverify  surelog     B vs A   : MOVERS 1 / 953  -> ./default/Scoreboard-59431470/slang.uhdm
CSVs, B vs A, both corpora       : IDENTICAL
default/SeqDriver, A vs B        : BYTE-IDENTICAL (17960936 bytes)
testflags/SeqDriver, A vs B      : BYTE-IDENTICAL (17961341 bytes)
```

The single "mover" is `default/Scoreboard` and it is **the known flake**, now
demonstrated in the strongest possible form: **both sides of this comparison came
from the same binary**, so a real difference is impossible. By the standing
multi-stability law the discriminator is SIZE, and the size is equal:

```
A: 11122738 bytes    B: 11122738 bytes    hashes da1eeb8b9000 / 4e325679f075
```

This independently reproduces `r10sd1`'s verifier finding F2 (Scoreboard is
hash-unstable on every binary, the campaign's known `SourceLocation`/macro-buffer
nondeterminism) and extends it: it is not binary-dependent at all.

`msdist` to golden, `default/SeqDriver`, recorded as the next pass's baseline
(dumps `sed 1d`-stripped on both sides, ADDED and REMOVED never netted):

```
golden dump lines 1970508   ours dump lines 1807412
golden-only line instances   264498
ours-only   line instances   101402
MULTISET DISTANCE            365900
```

For comparison, sd1 recorded 365888 against its own patched binary at `df0cdae`;
the +12 is the corpus moving underneath (uvm68 and sd1 both landed since), not a
change made here — this pass's two binaries are the same file.

---

## 6. THE GRID — golden's design package-vector membership rule, cell for cell

`ct2grid.sh` over `grid/p*.sv`, pristine binary, LHS always golden.

| cell | package use | golden `AllPackages` | golden `TopPackages` | OURS == golden? | arm cmp head |
|---|---|---|---|---|---|
| `p1_declared_unused` | declared, never imported, never used | `builtin, p1a` | `builtin, p1a` | **SAME** | `PASS_CMP`, `DUMP_MATCH` |
| `p2_imported_only` | wildcard-imported, no name used | `builtin, p2a` | `builtin, p2a` | **SAME** | `PASS_CMP`, `DUMP_MATCH` |
| `p3_imported_used` | imported + function/typedef used | `builtin, p3a` | `builtin, p3a` | **SAME** | `PASS_CMP`, dump 12 |
| `p4_unit_import` | **`$unit`-scope** `import p4a::*` | `builtin, p4a` | `builtin, p4a` | **SAME** | `LHS: module_inst work@top` / `RHS: <null>`, 353 |
| `p5_two_pkgs` | `p5b` declared first & unused, `p5a` imported | `builtin, p5b, p5a` | `builtin, p5b, p5a` | **SAME** | `LHS: package p5a` / `RHS: <null>`, 91 |
| `p6_class_in_pkg` | package holding a class + method | `builtin, p6a` | `builtin, p6a` | **SAME** | `LHS: function (p6a::c6::get)` / `RHS: <null>`, 130 |

**Six cells, twelve vectors, zero divergence.** Membership is **every declared
package, in source-declaration order, in BOTH vectors**, with `builtin` at index
0 — independent of import, of use, and of `$unit`. `p5` proves the order is
DECLARATION order and not use order: `p5b`, which nothing imports, precedes the
imported `p5a` on both sides.

The three failing cells' heads are **not** package-vector heads and are new
arm-level witnesses (§7 R4/R5): `p5`'s is `LHS: package p5a` / `RHS: <null>` —
the *mirror* arm, golden holding something on a package that we do not — and it
is the smallest reproducer of a package-valued head in this directory (91 cmp
lines against SeqDriver's 1.4 M).

---

## 7. RESIDUES, RANKED

1. **R1 — the SeqDriver head, both rows, 1 414 861 lines. LOCALIZED, NOT
   CLOSED.** Everything above narrows it to: a **singular `vpiInstance`** slot,
   NULL in golden, holding our **`TopPackages`** copy of `uvm_pkg` in ours,
   inside `class_defn(uvm_coreservice_t)@49:9-113:9`, reachable only through
   `class_typespec@199:3-199:20` (`uvm_globals.svh`) but by ≥ 2 disjoint routes
   below it. **The instrument to finish it is a set-valued ddmin** over the 34
   `class_typespec` chokepoints in §4.3 (suppress pairs/triples, not singletons)
   — `ct2owner.cpp` already carries the operator and the pool; only the
   subset-search needs widening. Largest item left on these two rows.
2. **R2 — § instanceIsNeverAClassDefn2 (§1): 428 / 214 / 214 / 203 `vpiInstance`
   slots naming a `class_defn`, against golden's ZERO, in all four UVM
   designs.** Real, cmp-visible, owner always a `typespec`, and proved **not**
   the head (§4.4). Deliberately unfixed: the emission sites live in
   `src/ParamEmit.cpp` and `src/TaskFuncEmit.cpp` (§2), `TaskFuncEmit.cpp` is
   inside live pass `r10uvm69`'s file set, and a 428-slot change with no measured
   row gain is blast radius, not progress. The census that will score the fix is
   `ct2view.cpp`, one line of output.
3. **R3 — the `TOP:` view is where our `vpiInstance` deficit lives.**
   `TOP:uvm_pkg` is 11290 golden vs 6712 ours on SeqDriver (−4578) and −750 /
   −695 / −635 on the other three, while `ALL:uvm_pkg` is only −114 / −187 /
   −187 / −200. Meanwhile `adpcm_pkg` runs **long** on both views (+492 / +474).
   One mechanism — which package VIEW an emitted typespec is stamped with —
   plausibly explains R1 as well, since the head's RHS is precisely a `TOP:`
   object. Cheapest next survey after R1.
4. **R4 — `p5_two_pkgs`: `LHS: package p5a` / `RHS: <null>`, 91 cmp lines.**
   A 12-line reproducer of a package-valued head, the *mirror* arm of R1
   (golden holds something on a package that we do not). Two packages, one
   imported. Ready-made and orders of magnitude cheaper than SeqDriver.
5. **R5 — `p4_unit_import`: `LHS: module_inst work@top` / `RHS: <null>`, 353 cmp
   lines, dump 294.** The `$unit`-import shape SeqDriver's `testbench.sv:1` uses;
   same family as uvm67's residue 2 (`$unit`-import materialisation onto the
   DESIGN object), now with a six-line witness.
6. **R6 — `p6_class_in_pkg`: `LHS: function (p6a::c6::get)` / `RHS: <null>`,
   130 cmp lines, dump 5.** A package class method. Smallest cell in the grid by
   dump distance and it sits in exactly the `class_typespec → class_defn →
   task_func` region the head's chokepoint occupies.
7. **R7 — `VpiFile` is EMPTY on nearly every object we emit.** cmp-invisible (no
   `Compare` body reads it) and dump-visible, but its real cost is to
   *instruments*: any census keyed on file shares 35 of 20 397 keys and reads
   green. It cost this pass one wrong census and it cost sd1 residue R1 (§4.5).
8. **R8 — `default/Scoreboard` is hash-unstable with the SAME binary on both
   sides** (§5.2). Any future pass that reads a Scoreboard byte difference as
   evidence must read the SIZE. Reproduces and strengthens sd1-verifier F2.
9. **R9 — the other three UVM rows' heads have moved since the brief was
   written** (§5.1): SimpleUVM/Scoreboard are now 112 on
   `func_call`/`method_func_call @343`, BuildUVMPkg 58 on
   `ref_obj`/`hier_path @14107`. Both are unrelated to packages and neither is
   touched here.

---

## 8. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct2pkgv.cpp` | the design's package VECTORS, per entry, with every vector `package::Compare` walks and **NULL distinguished from empty** (`-1` vs `0`). The instrument that refuted the brief. |
| `ct2design.cpp` | uvm67's design-field comparator, reused unchanged: which design FIELD fails, at which element. |
| `ct2pkgcmp.cpp` | descend into one package pair, field by field, element by element, fresh context per element. Shows the head's *reach*; §4.3 explains why fresh contexts cannot show its *location*. |
| `ct2ptr.cpp` | whole-database census of every singular slot holding a named package, over all 154 VPI relations. Proves `vpiInstance` is the only one. |
| `ct2view.cpp` | **view-aware, multiset** `vpiInstance` census: `ALL:` vs `TOP:` package copies kept apart, whole multiset per span key. The §1 law's scoreboard. |
| `ct2owner.cpp` | ddmin over golden objects using `m_visited` as a suppression operator, then descent by suppression. The only localizer that is sound for this head. |
| `ct2mut.cpp` | in-memory mutation probe (null `vpiInstance` by owner type, bisect within a type) with a restore control. Killed two hypotheses; its own failure mode is documented in its header. |
| `ct2find.cpp` | **kept as the record of a WRONG method** — fresh-context descent, defeated by the `vpiInstance` cycle. Header says so. |
| `ct2slot.cpp` | **kept as the record of a second WRONG method** — mirror walk whose relation order is not `Compare`'s, so it misaligns and reports noise. Header says so. |
| `ct2inst.cpp` | first-generation `vpiInstance` census (null vs non-null, one value per key). Superseded by `ct2view.cpp`; kept because its blind spot *is* sd1 R1's blind spot. |
| `ct2rels.inc` | the 154 VPI relation constants the visitor uses, `vpiParent` deliberately removed. |
| `ct2arm.sh` / `ct2grid.sh` | single-arm and grid drivers (LHS always golden, `sed 1d`, missing-input guards, per-arm scratch dir). |
| `grid/p1…p6.sv` | the six package-use cells. |
| `byteverify.sh` `manifest.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `msdist.sh` `rowheads.sh` `dumptree.py` `census.py` `slots.py` `cells.py` | carried forward from `r10sd1repro` unchanged. |

---

## 9. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, link line waited for, md5 asserted separately, 32-hex baseline | `/tmp/wt_r10sd2` and `/tmp/wt_r10sd2pris`, both `BASE 6e1c27a…` grep-checked (`rev-parse \| grep -c` = 1), both `errors: 0`, both `Linking CXX executable slang-uhdm`; **delivered md5 `f1fee994fffdfc1e2d7883d791e1621f` == pristine md5 `f1fee994fffdfc1e2d7883d791e1621f`** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | testflags j2 679/50/2, dump 496/183/52, ct8rows 0 rows | default **679 / 50 / 2**, testflags **679 / 50 / 2**; dump histogram **52 / 183 differ / 496 match**, base == fresh; `ct8rows` **0 differing ROWS**, `PASS: every row byte-identical` |
| **4 surelog** | both j2 469/11 + 465/8 (FAIL 25/23, DEFER 5/5), histograms unchanged, 0 rows | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM); `ct8rows` **0 differing ROWS**, all **4 dump histograms identical** |
| **5 BYTE VERIFIER** | both corpora, both modes, vs PRISTINE built here, `SELFCHECK=1 SELFCHECK1=1`, movers per-shape by multiset, ADDED/REMOVED separate, census-predict first | u2r **0 / 1358 movers**, `PATH_SETS_IDENTICAL`, SELFCHECK **1357/1358**, SELFCHECK1 **1**; surelog **1 / 953**, `PATH_SETS_IDENTICAL`, SELFCHECK **952/953**, SELFCHECK1 **2** (= 1 + the flake). The single mover is `default/Scoreboard`, **same size 11122738 both sides, same binary both sides** → flake by the standing law (§5.2). Prediction "0 real movers" was made from the md5 identity **before** the sweeps. Per-shape mover analysis is vacuous by construction and is not fabricated. |

`GOLDEN_DEFER` was `[UNSET]` in every sweep (printed). All sweeps `--jobs 2` with
private `--out`/`--workdir`. `results/*.csv` were READ ONLY. No `git stash`.

**CANARIES**

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names **7** (the documented u2r-only names) |
| `canaries.sh` u2r | at baseline | **ok=8 changed=0 absent=0**, unknown-names **25** (documented) |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, baseline FIRST, mode-matched | **ok=58 changed=0 absent=0 unknown-patterns=1**, PASS |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, PASS |
| `canaudit.sh` | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, PASS |
| fenced names | dispatched by no driver | `UnsignedParam` `HierPathEval` `FileLocalParam` `TopParam` — **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex` **by name** | at baseline | both `OK` in `canaries.sh`'s per-row listing, both corpora |

**EMPTY PRODUCT HUNT — clean (0 vacuous cells).** Every grid cell carries at
least **two** package objects per vector on the thinner side (`builtin` plus the
cell's own package; `p5` carries three), so no `SAME` verdict in §6 is agreement
that costs nothing. No cell `SURELOG_FAIL`s: all six produce both a golden and an
ours database.

**PATCH HYGIENE.** `/tmp/r10sd2.patch` applies clean to a fresh `6e1c27a`
(`git apply --check` rc=0), reproduces `tools/probe/r10sd2repro/` byte-for-byte,
and leaves exactly **1** porcelain entry (the probe directory). `git diff 6e1c27a
-- include src` is **empty**.

**GATE-3 trap, re-encoded:** `results/gate_uhdm2rtlil.csv` holds **testflags rows
only**; the fresh both-modes CSV is filtered to testflags before `ct8rows.sh`
sees it, or all 731 default rows read as ADDED.

**BOUNDARIES.** `§ classTdSpecParamsForeignHome1`'s `UhdmExporter.cpp ~2682`
gates are untouched (no production file is touched at all), so its b1–b28 grid
holds by construction. Live passes `r10uvm69` (`TaskFuncEmit.cpp` territory) and
`r10earl40` (`ExprEmit.cpp`): **file-set intersection with this pass is empty** —
this pass's file set is `tools/probe/r10sd2repro/` only. **No collision.**

---

## 10. THE PATCH

`/tmp/r10sd2.patch` — `git diff` vs `6e1c27a`, `tools/probe/r10sd2repro/` only.
**No production file appears in it.** Reproducible with:

```sh
cd /tmp/wt_r10sd2 && git add -A tools/probe/r10sd2repro
git diff 6e1c27a --binary -- include src tools/probe/r10sd2repro > /tmp/r10sd2.patch
md5sum /tmp/r10sd2.patch
```

---

## 11. REFUTATIONS, STATED PLAINLY

1. **The brief's law — "our design object lists `uvm_pkg` in a package vector
   position where golden lists FEWER packages, or a different order" — is
   FALSE.** Both vectors are identical on every UVM row in both modes, and the
   arm grid shows we reproduce golden's membership rule in all six cells.
   Implementing the brief would have edited correct code.
2. **The brief's framing "the design-level package vector ENDED" is refuted
   twice over**: the vectors are the same size, and seeding every golden package
   object into `m_visited` leaves the head unchanged, which rules the vector arm
   out mechanically.
3. **sd1 residue R1's "not a `vpiInstance` divergence" is REFUTED** (§4.5).
   `vpiInstance` is the only relation in these databases that can hold a package.
   The earlier check was defeated by span-key collapse across package views.
4. **"`RHS: <null>` / `LHS: <null>` names a slot, so read the printed object's
   parent chain" — insufficient here.** The printed object is our `TopPackages`
   `uvm_pkg`, whose parent is the design; the *defect* is two files and several
   hundred lines away inside `uvm_globals.svh`/`uvm_coreservice_t`. Only
   suppression found it.
5. **"Bisect by nulling our side" is unsound for a `LHS:<null>` head** (§4.4.2):
   nulling introduces an earlier `RHS:<null>` failure, so the bisect converges on
   the first typespec in traversal order and looks like a result.
6. **"A fresh `CompareContext` per candidate child localizes the head" is
   unsound** (§4.3): `vpiInstance` closes a cycle back to the package, so every
   child reproduces.
7. **The brief's "SimpleUVM/Scoreboard/BuildUVMPkg all import `uvm_pkg` too, so
   why is SeqDriver the only row with this head?" answers itself** — they fail
   EARLIER, on shapes that have nothing to do with packages, and their heads are
   no longer the ones the brief quotes (§5.1, R9).
8. **`ct2slot.cpp`'s top finding, `function . vpiInstance -> package(uvm_pkg)`
   ×3100, is an artefact of its own misalignment.** Suppressing **all** golden
   `task_func` objects with a NULL `Instance()` does **not** remove the head, so
   the owner is not a `task_func`. Reported because the number is large and
   convincing and wrong.
