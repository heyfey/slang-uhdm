# r10oth7 — the `class_typespec` two-half cluster

**Result, up front: SVSwitch did NOT convert. It stays `CMP_NOTEQUAL` in both
modes.** What moved:

* **cmp lines 361 → 132** in both modes (a HEAD-DEPTH measure).
* **dump distance 2713 → 2697 true content lines** (a DISTANCE measure, `sed 1d`
  on both dumps, `diff -u`'s own `---`/`+++` header excluded). Sixteen lines.
* **the head moved off the `class_typespec` cluster entirely.** It is now
  `array_var (work@packet::data)` — `rand byte data[];` at `Packet.sv:23` — where
  golden puts `vpiSigned:1` on the **`array_var`** and ours puts it on the
  `vpiReg` `byte_var` instead. Ranked **R1**, and it is a ONE-FIELD PLACEMENT
  law, the most reachable residue this pass leaves.
* **BOTH halves of the target cluster are CLOSED on SVSwitch**, measured field by
  field: `class_typespec` objects carrying `vpiClassDefn` 22 → **32 of 32**
  (golden 35 of 35), objects carrying `vpiName` 20 → **24** (golden 27), and the
  two half-missing populations `NAME_ONLY` **10 → 0** and `neither` **0 → 0**.
  `DEFN_ONLY` is **8 on both sides**, which is golden's own shape, not a residue.

**TWO LAWS** (one of them with a narrowing sub-clause), measured on both sides of
**44 arm cells** across four arms (17 + 10 + 11 + 6) plus the SVSwitch corpus
census.
**Corpus reach: ZERO rows changed status or dump on either corpus** — whole-row
diffs against both committed baselines are 0 differing rows (731 and 1588 rows).
**ZERO canary rows moved**, counted as ROWS because a name count cannot be
checked: `canaries.sh` compared **52** surelog + **8** uhdm2rtlil rows and
`ctcan2.sh` a further **58** + **1**, all `changed=0 absent=0`. (An earlier draft
said "37 named canaries"; that number was neither measured nor checkable, and
auditing it is what exposed §4.2.1's missing-guard defect.) **The byte movers are
listed and explained in §5.**

Base commit `4595f95`, branch `auto5h`.
Direction convention, used here and in every NOTE comment the patch adds:
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.

Binaries. Every figure below names the one that produced it.
* pristine `4595f95` — md5 **`cc516659aa8b64758dfefb3fc71ede3e`**, kept at
  `/tmp/r10oth7_pristine_slang-uhdm` so no rebuild could race a sweep.
* intermediate, laws A+B without law A's narrowing — md5
  **`a892689fea067d3e996b3f219dd7ae4c`**. Named where a figure came from it.
* patched, FINAL — md5 **`69bbc29e0467bd878e37dd3a4fb265a5`**.
The md5 was printed BEFORE and AFTER every sweep and never changed within one.

---

## 0. THE CENSUS, RE-MEASURED FROM SCRATCH — the master's model is CONFIRMED,
## two of the master's NUMBERS are REFUTED

Order-of-work item A was "confirm my census yourself". Done, on the pristine
binary, with `ctcount.sh` (shipped). **The master's central claim is right: the
head is a missing scalar POINTER, not a missing OBJECT.** Our
`class_defn (work@mailbox)` exists and is byte-identical to golden's, including
its synthesized `builtin.sv` span `1:3-27:11`; the ten `class_typespec (mailbox)`
objects around it simply had no `vpiClassDefn` edge.

**WHAT uhdm-dump ACTUALLY PRINTS, and why the master's counts are doubled.**
uhdm-dump prints a typespec's OWN fields only where the object is listed as a
DEFINITION — in these databases that is the trailing `\_weaklyReferenced:` block
at indent 0. Every other appearance is a `vpiActual` back-reference that prints
the header line ALONE, with no `vpiName` and no `vpiClassDefn`. So a bare
`grep -c 'class_typespec: (mailbox)'` counts each object TWICE and cannot see
either field at all. `ctcount.sh` reads only the definition listing.

| census cell | master's brief | MY MEASUREMENT (pristine binary) | verdict |
|---|---|---|---|
| `class_defn: (work@mailbox)` dump lines | golden 20 / ours 10 | golden 20 / ours 10 | **CONFIRMED** |
| `class_typespec: (mailbox)` dump lines | golden 20 / ours 20 | golden 20 / ours 20 | **CONFIRMED** (= 10 OBJECTS each) |
| `class_typespec: (packet)` dump lines | golden 18 / ours 10 | golden 18 / ours 10 | **CONFIRMED** |
| mailbox typespecs carrying `vpiClassDefn` | golden 10 / **ours 4** | golden **11** (10 named + 1 unnamed) / **ours 1** | **REFUTED** |
| packet typespecs carrying `vpiName` | golden 9 / ours 5 | golden 9 / ours 5 | **CONFIRMED exactly** |
| "the mailbox typespec LACKS the edge in 6 of 10 places" | 6 of 10 | **10 of 10** | **REFUTED** |

The second refutation matters for the model, not just the arithmetic: it is not a
*sometimes* failure that needs a positional distinguisher, it is a *total*
failure of one lookup. Ours carried exactly ONE mailbox `vpiClassDefn` — the
unnamed typespec that belongs to `builtin.sv`'s OWN `function new` return, which
resolves inside `builtin.sv` and never needed the bridge.

**The `packet` half is confirmed to the object.** Golden 9 named + 0 unnamed;
ours 5 named + **4 unnamed**, and those four are exactly
`Driver.sv:32`, `Receiver.sv:31` and `Scoreboard.sv:25` (twice) —
`packet pkt;` declared in a class TASK BODY. 5 + 4 = 9 = golden's 9, so no
object is missing; only the field is.

---

## 1. WHY THESE TWO CLASSES AND NOT OTHERS — answered BEFORE any code

The master's hypothesis was "built-in versus user-declared". **It is right for
half A and it is the WRONG FRAME for half B**, and both halves needed an arm.

### 1.1 Half A — `mailbox`: the answer is TWO UNRELATED SYMBOLS, ONE SHORT NAME

Transcribed from slang's source, not guessed.
`slang/source/ast/builtins/StdPackage.cpp` (grep `allocGenericClass("mailbox"`)
builds `mailbox` as a **`GenericClassDefSymbol` with a `T` type parameter inside
slang's compiler-synthesized `std` package**, at `SourceLocation::NoLocation`.
So `mailbox drvr2sb;` in `Driver.sv` binds to a *specialization of that generic*
— a symbol that appears in **no compilation unit**, which is why
`classDefnMap` / `genericDefnMap` (both fed only from
`comp.getCompilationUnits()` and package members) can never contain it.

Meanwhile the `class_defn` we emit for the name `mailbox` comes from the
**injected `share/builtin.sv` text** (`uhdm_main.cpp`, grep
`kBuiltinSvText`) — a plain, NON-parameterized `class mailbox;` parsed as its own
compilation unit so its spans match Surelog's synthesized file. `semaphore` and
`process` are the same story.

So the two objects are unrelated symbols that happen to share a short name, and
the SHORT NAME is the only bridge that exists. That is law A.

Surelog has no such split — it compiles `builtin.sv` into ordinary design-level
`ClassDefinition`s and finds them by name — which is exactly why golden carries
the edge in every position.

### 1.2 Half B — `packet`: NOT "user versus built-in". THE FRAME IS THE CLASS'S HOME DESIGN COMPONENT

`packet` is a user class and it loses its NAME, so "user-declared" cannot be the
distinguisher. The shipped rule was an **over-wide suppression**: a comment in
`src/TypeEmit.cpp` claimed "a CLASS-METHOD body local is unnamed the same way,
**wherever its class lives**". That "wherever" is **REFUTED** (§3), and the
sentence is now STRUCK at its source rather than left to mislead.

The producer, transcribed from
`Surelog/src/DesignCompile/CompileType.cpp`:
* `CompileHelper::compileVariable` first tries
  `component->getDataType(typeName)`; when that hits, the variable's typespec is
  the one `compileTypespec` built, and `compileDatastructureTypespec`'s
  `ClassDefinition` arm (grep `ref->VpiName(typeName)`) gives it **BOTH**
  `Class_defn` and `VpiName`.
* when it MISSES, the next arm is the GLOBAL
  `design->getClassDefinition(typeName)` lookup (grep
  `design->getClassDefinition(typeName)`), which mints a class_typespec with
  `Class_defn` and **NO `VpiName`**.

Both halves of the cluster are therefore the same producer mechanism read from
two different ends — a missing field on our side either way.

---

## 2. LAW A — `§ builtinClassTsLinksBuiltinFileDefn7`

**Sites, each with a greppable symbol** (line numbers are measurements and are
tree-dependent; the `§` names are not):
* `include/UhdmExporter.h` — the map `builtinFileDefnByName` and the predicate
  `isBuiltinStdClass`.
* `src/UhdmExporter.cpp` — the fallback inside `UhdmExporter::classDefnFor`; the
  definition of `isBuiltinStdClass`; the index write inside the `AllClasses`
  block's `emitOne` lambda (grep `fromBuiltinFile`).
* `src/TypeEmit.cpp` — the NARROWING, `builtinStmtScopeNoLink0`, and the naming
  half, `builtinLocalUnnamed0`.

**DIRECTION: ADD an EDGE** (plus one SUPPRESSION of a name and one SUPPRESSION of
the edge itself, both measured — see below).

**THE PREDICATE.** `classDefnFor` already tries the specialization symbol and
then the generic. It now also tries, last:
`!builtinFileDefnByName.empty() && isBuiltinStdClass(ct)` →
`builtinFileDefnByName[ct.name]`.
`isBuiltinStdClass` walks the class's parent scopes and stops at the first
`Package` (true iff it is named `std`), `CompilationUnit` or `InstanceBody`
(false). It keys on the class's HOME, never on its name, so a user class called
`mailbox` — which necessarily has a compilation-unit, package or instance home —
is rejected. The index is written ONLY from the injected `builtin.sv` unit, so it
is EMPTY under `--nobuiltin` and the law cannot fire there at all.

**WHY IT IS NECESSARY, not cosmetic.** `class_typespec::Compare` reads
`vpiClassDefn`, and the missing scalar POINTER is what printed as
`RHS: <null>` on the POINTEE — `BaseClass.h`'s scalar `SafeCompare` sets
`m_failedLhs` to the pointee and leaves `m_failedRhs` null, so a missing POINTER
reads exactly like a missing OBJECT. That was SVSwitch's whole head.

**MINT COUNT — the proof the code ran** (`ctmints.sh`, both sides OURS):
on SVSwitch `default` and `testflags` alike, `withClassDefn` **22 → 32**, i.e.
**+10 edges**, and the hand count of SVSwitch's written `mailbox` declarations is
**exactly 10** — SIX class properties plus FOUR constructor formals, every one
listed in §7. The two numbers cross-check each other and `ctreach.sh` ASSERTS the
10 rather than inheriting it.

### 2.1 ARM `c1_builtins.sv` — BOTH SIDES OF EVERY CELL

Read with `ctarm.sh` + `ctcount.sh` + `ctweak.sh` on the PRISTINE binary
`cc516659…` and the FINAL binary, same file both times.
`UNMEASURED` = no object of that kind exists on that side at all.
Every cell's comment was checked against its own source line.

| cell | source | position | golden (LHS) | ours BEFORE (RHS) | ours AFTER |
|---|---|---|---|---|---|
| `a1_mb` | `mailbox a1_mb;` | class property | name `mailbox` + **defn `work@mailbox`** | name, **NO defn** | identical ✓ |
| `a2_sem` | `semaphore a2_sem;` | class property | name + defn `work@semaphore` | name, no defn | identical ✓ |
| `a3_proc` | `process a3_proc;` | class property | name + defn `work@process` | name, no defn | identical ✓ |
| `a4_mbi` | `mailbox #(int) a4_mbi;` | class property | name + defn, span **30:3-30:10**, **NO vpiParameter** | **NEITHER field**, span 30:3-**30:17**, 2 type_parameters | defn ✓; span + params **residue R3** |
| `a5_user` | `u_cls a5_user;` | class property | name + defn | equal | unchanged ✓ CONTROL |
| `a6_alias` | `u_alias_t a6_alias;` | class property via TYPEDEF | shared typedef ts `(u_alias_t)` at 22:9 | **byte-identical** | unchanged ✓ CONTROL |
| `a7_par` | `u_par #(int) a7_par;` | class property, param'd USER class | name + params + defn, span 36:3-**36:8** | same, span 36:3-**36:15** | span **residue R3** |
| `a8_pkg` | `pk::p_cls a8_pkg;` | class property, PACKAGE class | name `pk::p_cls` + defn | equal | unchanged ✓ CONTROL |
| `a9_mb` | `function new(mailbox a9_mb, …)` | method FORMAL | name + defn | name, **no defn** | identical ✓ |
| `a10_user` | same formal list | method FORMAL | name + defn | equal | unchanged ✓ |
| `a11_pkg` | same formal list | method FORMAL | name + defn | equal | unchanged ✓ |
| `a12_mb` | `mailbox a12_mb;` in `task t()` | class-method LOCAL | **UNNAMED** + defn | UNNAMED, no defn | **UNNAMED + defn ✓** (law A's naming half) |
| `a13_user` | `u_cls a13_user;` in `task t()` | class-method LOCAL | **NAMED `u_cls`** + defn | **UNNAMED** + defn | **NAMED ✓** (law B) |
| `a14_pkg` | `pk::p_cls a14_pkg;` in `task t()` | class-method LOCAL | name `pk::p_cls` + defn | equal (scoped-name branch) | unchanged ✓ |
| `a15_mb` | `mailbox a15_mb;` | MODULE scope | name + defn | name, **no defn** | identical ✓ |
| `a16_user` | `u_cls a16_user;` | MODULE scope | name + defn | equal | unchanged ✓ |
| `a17_holder` | `holder a17_holder;` | MODULE scope | name + defn | equal | unchanged ✓ |

`ctcount.sh` over the arm: **`NAME_ONLY` 10 → 0**, **`neither` 1 → 0**,
`withClassDefn` **13 → 20 of 20**, and the whole arm's dump distance
**127 → 108** content lines. All 4 remaining named-cell deltas are the R3 spans
and the R2 object-count residue, both named in §6 and neither this pass's shape.

### 2.2 LAW A's NARROWING — `builtinStmtScopeNoLink0`, and an ARM FOUND IT

A built-in handle declared as a local of a subroutine or statement block that is
**NOT inside a class** is, in golden, an **`unsupported_typespec`**, not a
class_typespec: cells `d5` (package function), `d10` (module function), `d11`
(initial block) of `c3_bounds.sv`. Golden's object there carries `vpiName` and
`vpiInstance` and **nothing else**, and our object already carries exactly those
two — so adding law A's edge would put our object one field FURTHER from
golden's, not closer.

**MEASURED, not reasoned**, all three readings on arm `c3_bounds`'s dump distance:
pristine **96** content lines → intermediate binary `a892689f…` (law A with no
narrowing) **102**, i.e. the edge made the arm SIX LINES WORSE → FINAL binary
`69bbc29e…` **94**, i.e. two lines BETTER than pristine, which is cell `d13`
gaining its edge with the three R4 cells held flat. Transcribed: Surelog's
statement-scope `compileTypespec` falls through to its catch-all, which mints an
`unsupported_typespec` carrying the written name and no class_defn at all. The
remaining wrong KIND is **residue R4**.

---

## 3. LAW B — `§ classMethodLocalNameFollowsHomeComponent7`

`src/TypeEmit.cpp`, the `class_typespec` block of `UhdmExporter::makeTypespec`
(grep the `§` name; the predicate pieces are `homeComp0`, `nested0`,
`inClassBody0`, `localSameComp0`).

**DIRECTION: ADD a NAME, by NARROWING an over-wide suppression.**

**THE PREDICATE, in one sentence.** A class-typed variable declared inside a
subroutine or statement block is UNNAMED iff the class's **HOME DESIGN
COMPONENT** equals the declaration's — where a design component is a `Package`
or an `InstanceBody`, **`$unit` is NOT a component**, and a **class is
TRANSPARENT** (you walk through it to its own component).

The last clause is the whole change: `§ localClassTsUnnamed15` already
implemented this test, but its walk STOPPED at the enclosing `ClassType`, so
every class-method local fell to the separate blanket rule instead.

**THE STRUCK CLAIM.** `src/TypeEmit.cpp` used to say a class-method body local is
unnamed "**wherever its class lives**", citing
`package pk; class C; class D; function void f(); C m2;`. That witness is real
and still reads UNNAMED on both sides — it is cells `b2` / `e2'` — but it is the
SAME-COMPONENT case, not a class-method case. The generalisation is REFUTED by
six cells (`b5`, `b6`, `b8`, `b9`, `a13_user`, `e1`, `e3`). The sentence is
struck at source; do not carry it forward.

**WHY IT GATES.** `class_typespec::Compare` reads `vpiName` as well as
`vpiClassDefn`, so fixing only law A would have walked the head from the mailbox
edge onto the packet name and gained nothing — the master's warning, confirmed:
the intermediate binary's SVSwitch cmp is 132 lines with BOTH halves in, and the
`packet` name accounts for 4 of the 14 field deltas the census closed.

### 3.1 ARM `c2_localname.sv` — the naming rule, BOTH SIDES

| cell | source | class home | decl's class home | golden (LHS) | ours BEFORE | ours AFTER |
|---|---|---|---|---|---|---|
| `b2` | `b2_target v;` in `pb::b2_user::t` | package `pb` | package `pb` | **UNNAMED** + defn | UNNAMED ✓ | unchanged ✓ |
| `b3` | `b3_inner v;` in its OUTER class's task | class in `pb` | package `pb` | **no class_typespec at all** (golden mints a `ref_var`) | UNNAMED | unchanged — **UNMEASURED**, residue R5 |
| `b4` | `b4_self v;` (the enclosing class itself) | package `pb` | package `pb` | **UNNAMED** + defn | UNNAMED ✓ | unchanged ✓ |
| `b5` | `b1_target v;` in `b5_user::t` | **$unit** | **$unit** | **NAMED `b1_target`** | **UNNAMED** | **NAMED ✓** |
| `b6` | same, one `begin` DEEPER | $unit | $unit | **NAMED** | UNNAMED | **NAMED ✓** |
| `b7` | `function b1_target t3();` RETURN type | $unit | $unit | **NAMED** | UNNAMED | **still UNNAMED — residue R6** |
| `b8` | `b1_target r;` beside that return | $unit | $unit | **NAMED** | UNNAMED | **NAMED ✓** |
| `b9` | `b2_target v;` IMPORTED into $unit | package `pb` | **$unit** | **NAMED `b2_target`** | UNNAMED | **NAMED ✓** |
| `b10` | `b10_inmod v;` in `m2_top::b11_user::t` | module `m2_top` | module `m2_top` | **UNNAMED** + defn | UNNAMED ✓ | unchanged ✓ |
| `b11` | `b11_user u;` at module scope | module | — (not nested) | NAMED, **2 objects** | NAMED, 1 object | object count = residue R2 |

`ctcount.sh` over the arm: `withName` **1 → 5** of golden's 7 and `DEFN_ONLY`
12 → 8 (golden 6); the two `withName` survivors are `b7` (R6) and `b11`'s second
object (R2). Arm dump distance **113 → 93** content lines.

### 3.2 ARM `c4_crosscomp.sv` — the CROSS-COMPONENT half, i.e. exactly where the new rule DISAGREES with the old one

This arm exists because "a law that only ever saw one spelling has an unmeasured
half": arm `c2` covers same-component and $unit-vs-$unit, this one covers two
REAL and DIFFERENT components.

| cell | source | class home | decl's class home | golden (LHS) | ours BEFORE | ours AFTER |
|---|---|---|---|---|---|---|
| `e1` | `f0_unit v;` in `m4_top::h1_user::t` | **$unit** | **module `m4_top`** | **NAMED `f0_unit`** | **UNNAMED** | **NAMED ✓** |
| `e2` | a package class method whose local is a $unit class | — | — | **UNMEASURABLE**: slang and the LRM both reject "cannot reference compilation unit item from within a package". Recorded, not claimed. |
| `e2'` | `f1_pkgcls v;` in `pf::f2_user::t` | package `pf` | package `pf` | UNNAMED + defn | UNNAMED ✓ | unchanged ✓ CONTROL |
| `e3` | `f1_pkgcls v;` in `pg::g1_user::t`, imported from `pf` | package **`pf`** | package **`pg`** | **NAMED `f1_pkgcls`** | **UNNAMED** | **NAMED ✓** |
| `e4` | `pf::f1_pkgcls w;` in `m4_top::h1_user::t2` | package `pf` | module `m4_top` | NAMED `pf::f1_pkgcls` | equal (scoped branch) | unchanged ✓ |
| `e6` | `g2_base v;` in `pg::g3_ext::t` (a SUBCLASS's method) | package `pg` | package `pg` | UNNAMED + defn | UNNAMED ✓ | unchanged ✓ CONTROL |

**All six cells match golden after the patch.** `ctcount.sh`: `withName` 5 of
golden's 6 and `NAME_ONLY` 0 on both sides, the one survivor being `h1_user`'s
second object (R2). Arm dump distance **93 → 83** content lines.

### 3.3 ARM `c3_bounds.sv` — the boundaries the two walks must not cross

The new rule walks the CLASS side up through nesting and the DECLARATION side up
through its class. Both walks touch positions arm `c2` never saw, so each got a
cell. This arm is also where law A's narrowing was found.

| cell | source | position | golden (LHS) | ours BEFORE | ours AFTER |
|---|---|---|---|---|---|
| `d2` | `d1_outer::d1_inner v;` in another class of the same package | class-method local, SCOPED | **no class_typespec at all** | NAMED + defn | unchanged — residue R5 |
| `d4` | `d3_plain a;` in `pd::d4_pkgfunc` | PACKAGE FUNCTION local | UNNAMED + defn | UNNAMED ✓ | unchanged ✓ CONTROL |
| `d5` | `mailbox b;` in `pd::d4_pkgfunc` | PACKAGE FUNCTION local | **`unsupported_typespec` (mailbox)**, name + vpiInstance | class_typespec, name + vpiInstance | **unchanged** (law A's narrowing) — residue R4 |
| `d8` | `d7_outer::d7_inner a;` in a module function | MODULE FUNCTION local, SCOPED | **no class_typespec at all** | NAMED + defn | unchanged — residue R5 |
| `d9` | `d0_target b;` in a module function | MODULE FUNCTION local | NAMED + defn | equal | unchanged ✓ CONTROL |
| `d10` | `mailbox c;` in a module function | MODULE FUNCTION local | **`unsupported_typespec`** | class_typespec, name only | **unchanged** — R4 |
| `d11` | `mailbox d;` in an `initial` block | STATEMENT-BLOCK local | **`unsupported_typespec`** | class_typespec, name only | **unchanged** — R4 |
| `d12` | `d0_target e;` in an `initial` block | STATEMENT-BLOCK local | NAMED + defn | equal | unchanged ✓ CONTROL |
| `d13` | `mailbox f;` at module scope | MODULE scope | name + **defn** | name, **no defn** | **identical ✓** (law A) |
| `d14` | `d0_target g;` at module scope | MODULE scope | name + defn | equal | unchanged ✓ CONTROL |
| `d6` | `pe::e1_far v;` in a $unit class's task | class-method local, SCOPED, other package | name + defn | equal | unchanged ✓ CONTROL |

Arm dump distance **96 → 94** content lines (and **102** on the intermediate
binary, §2.2): the five CONTROL cells and the two R5 cells are untouched, `d13`
is fixed (−2), and the R4 cells are held flat by the narrowing.
`ctcount.sh` on the final binary: ours 16 objects / golden 12, `NAME_ONLY` **4**
— and those four ARE the R4 objects (`d5` appears twice, in the package's def and
elab views, plus `d10` and `d11`), which is the cross-check that the narrowing
fired exactly where it was aimed and nowhere else.

---

## 4. GATES — all five, on the FINAL binary `69bbc29e0467bd878e37dd3a4fb265a5`

1. **Build** — `cmake --build build -j 3` in this worktree: exit 0, link
   completed. The md5 differs from the pristine control
   `cc516659aa8b64758dfefb3fc71ede3e`, asserted with `md5sum` before every gate
   below, so nothing here was measured against a stale binary.
2. **Goldens** — `bash tests/check_goldens.sh` with `SLANG_UHDM` exported to
   THIS worktree's build: **23 PASS / 0 FAIL**. Negative control
   `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL**, so the main-tree default in
   `scripts/verify_golden.py` / `tests/check_goldens.sh` is not what got
   measured.
3. **uhdm2rtlil, `testflags`, `--jobs 2`, own `--out`, own `--workdir`** —
   see §4.1.
4. **surelog, `--mode both`, `--jobs 2`, own `--out`, own `--workdir`** —
   see §4.1.
5. **BYTE VERIFIER on BOTH corpora, with both controls** — §5.

Neither committed CSV was rebuilt, edited, or included in the patch.

### 4.1 ROW GATES — `ctrows.sh`, whole-row diff against the COMMITTED baselines

| corpus / mode | rows | statuses | dump column | whole-row diff vs the COMMITTED CSV |
|---|---|---|---|---|
| **uhdm2rtlil `testflags`** | **731** (the CSV is 732 LINES; the header is not a row) | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | **496 match / 183 differ / 52 blank** | **0 differing rows** |
| **surelog `default`** | **794** | 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL | **match 225** / 242 differ / 327 blank | **0** |
| **surelog `testflags`** | **794** | 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM | **match 165** / 298 differ / 331 blank | **0** |

surelog total **1588 rows** (CSV 1589 LINES). Every cell equals the `4595f95`
baseline and **the dump match counts did NOT fall** (225 and 165, unchanged).
The known `Google,testflags` golden-side environment flake shows as `TIMEOUT` in
both sweeps and in the committed baseline — named, not filtered, not promoted.
`results/golden_surelog.csv`'s `LowMemPkg,testflags` row embeds an absolute
SESSION-SCRATCHPAD path; it reproduced identically here (that row diffs empty), so
the judge is sound. Not "fixed", per the standing instruction.

**POSITIVE CONTROL ON THE HARNESS ITSELF.** The PRISTINE binary was swept the
same way into its own workdirs and reproduced BOTH committed baseline CSVs
exactly (0-line whole-row diffs on both). So the zero-row-change reading above is
a live measurement, not a driver that cannot see its probe.

**NEGATIVE CONTROL ON `ctrows.sh`.** One status cell in a copy of the fresh CSV
was flipped `CMP_EQUAL` → `CMP_NOTEQUAL`; the script reported **2 differing rows**
(the `<` and the `>` of that one row) and named the test. It is not blind.

### 4.2 CANARIES — `tools/probe/r10uvm52repro/canaries.sh`, and BOTH its controls exercised

| CSV checked | rows compared BY NAME | changed | absent | UNKNOWN-NAME |
|---|---|---|---|---|
| surelog (final) | **52** | **0** | 0 | **7** — exactly the seven u2r-only names |
| uhdm2rtlil (final) | **8** | **0** | 0 | 25 — the surelog-only names |

Both live conversions are at baseline: `InterfaceModPort` CMP_EQUAL/differ in both
modes and `BlackParrotComplex` CMP_EQUAL/differ in both modes. So are
`Earlgrey_0_1`, `LowMemPkg` default, and every member of the UVM family
(`SVSwitch`, `SimpleUVM`, `SeqDriver`, `BuildUVMPkg`, `Scoreboard` — the last
`CMP_NOTEQUAL` default / `SLANG_REJECT` testflags).

**BOTH NEGATIVE CONTROLS RUN, because a cited guard that does not bite is worse
than no guard:**
* injecting `ZZZ_TYPO_NOT_A_TEST` into `NAMES` printed
  `ZZZ_TYPO_NOT_A_TEST … UNKNOWN-NAME` and raised `unknown-names` **7 → 8**.
* flipping SVSwitch's `default` status in a copy of the fresh CSV printed
  `SVSwitch default CHANGED CMP_NOTEQUAL/ -> CMP_EQUAL/` and
  `ok=51 changed=1`.

### 4.2.1 A CITED GUARD THAT COULD NOT SEE ITS SUBJECT — **this pass committed the
### campaign's own trap, and the sentence above is the CORRECTED one**

An earlier draft of §4.2 read "So are the four rows regressed by over-fires in
recent passes (`TypespecExpr`, `ClogCast`, `2DFunctionArg`, `PartSelect4`)" — and
cited `canaries.sh` for it. **`canaries.sh` does not carry any of those four
names.** Its `NAMES` list holds 33 names; a name it does not carry is never
looked up, so it can never be reported as `CHANGED`, and the citation was
therefore evidence of nothing. The claim was struck from §4.2 above rather than
left standing with a bad citation.

It was found by AUDITING the guard's list instead of trusting the citation:
`grep -nE 'TypespecExpr|ClogCast|2DFunctionArg|PartSelect4' canaries.sh` returns
**one** line, and that line is the row holding `YosysOldOr YosysBigSimReed
YosysOldOpen` — i.e. none of the four.

**THE GAP IS WIDER THAN THOSE FOUR.** Auditing every canary the campaign brief
names against `NAMES` leaves:

| brief-named canary | in `canaries.sh`? |
|---|---|
| `TypespecExpr`, `ClogCast`, `2DFunctionArg`, `PartSelect4` | **NO** |
| the `EvalFunc` family (5 tests) | **NO** |
| the `ParamFile` family (4 tests) | **NO** |
| the `Black*` family (17 tests) | **only `BlackParrotComplex`** |
| everything else the brief names | yes |

**THE FIX IS AN INSTRUMENT, NOT A SENTENCE**: `ctcan2.sh` (shipped) checks exactly
that gap — the four exact names plus the three families by prefix — comparing the
WHOLE ROW (status **and** the dump column, because a dump-column-only regression
moves no status). It is supplementary: run BOTH scripts, neither supersedes the
other.

| CSV checked | rows compared | changed | absent | unknown-patterns | verdict |
|---|---|---|---|---|---|
| surelog (final) | **58** | **0** | 0 | 1 = `2DFunctionArg`, u2r-only | **PASS** |
| uhdm2rtlil (final) | **1** | **0** | 0 | 6 = the 3 surelog-only names + 3 families | **PASS** |

So the struck claim's CONTENT turns out to be true — all four rows are
byte-identical to the baseline, `TypespecExpr` CMP_EQUAL/match+differ, `ClogCast`
CMP_EQUAL/match+match, `PartSelect4` CMP_EQUAL/differ+differ, `2DFunctionArg`
CMP_EQUAL/match — but it is now true *on evidence*. The two unknown-pattern
counts were MEASURED, not assumed, and `EXPECT_UNKNOWN` makes the caller state
them so an unmatched pattern is neither silently tolerated nor silently fatal.

**THREE CONTROLS RUN ON `ctcan2.sh` ITSELF:**
* POSITIVE, both corpora: `EXPECT_UNKNOWN=1` on surelog → `ok=58 changed=0
  absent=0 unknown-patterns=1`, **exit 0**; `EXPECT_UNKNOWN=6` on uhdm2rtlil →
  `ok=1 … unknown-patterns=6`, **exit 0**.
* NEGATIVE (typo): `ZZZ_TYPO_NOT_A_TEST` injected into `EXACT` → printed
  `UNKNOWN-PATTERN`, count 1 → **2**, `FAIL: unknown-patterns=2 but
  EXPECT_UNKNOWN=1`, **exit 6**.
* NEGATIVE (dump column only, the case a status-only check cannot see): flipping
  `BlackConst,default` from `,,differ` to `,,match` in a CSV copy → `BlackConst
  default CHANGED CMP_EQUAL/differ -> CMP_EQUAL/match`, `changed=1`, **exit 5**.

The four slang-fenced tests `UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam` were never dispatched individually; they appear in the corpus sweep
exactly as in the committed baseline.

---

## 5. BYTE VERIFIER — where the reach is

`tools/probe/r10oth6repro/byteverify.sh <patched-workdir> <pristine-workdir>`,
both corpora, both with `SELFCHECK=1 SELFCHECK1=1`.

| corpus | databases | path sets | movers | all-vs-one control | ONE-corruption control |
|---|---|---|---|---|---|
| uhdm2rtlil | 679 / 679 | IDENTICAL | **0** | 678 / 679 flagged | **1** ✓ |
| surelog | 953 / 953 | IDENTICAL | **9** | 952 / 953 flagged | **10** = 9 + 1 ✓ |

### 5.1 EVERY MOVER EXPLAINED — `ctexplain.sh` / `ctmints.sh`, both sides OURS

| mover | law A: `withClassDefn` | law B: `withName` | `neither` (no name, no defn) | row before → after |
|---|---|---|---|---|
| `SVSwitch` default + testflags | 22 → **32** (+10) | 20 → **24** (+4) | 0 → 0 | CMP_NOTEQUAL → CMP_NOTEQUAL |
| `SeqDriver` default + testflags | 8804 → **8847** (+43) | 4668 → **4670** (+2) | 94 → **63** | CMP_NOTEQUAL → CMP_NOTEQUAL |
| `SimpleUVM` default + testflags | 6184 → **6221** (+37) | 3472 → 3472 (0) | 46 → **21** | CMP_NOTEQUAL → CMP_NOTEQUAL |
| `BuildUVMPkg` default + testflags | 6350 → **6392** (+42) | 3551 → 3551 (0) | 57 → **27** | CMP_NOTEQUAL → CMP_NOTEQUAL |
| `Scoreboard` default only | 6148 → **6185** (+37) | 3426 → 3426 (0) | 50 → **25** | CMP_NOTEQUAL → CMP_NOTEQUAL |

`Scoreboard` `testflags` is `SLANG_REJECT`, so it has no database and prints
**UNMEASURED** rather than being silently dropped.

**`Scoreboard` IS A REAL MOVER THIS PASS, and I checked that against its known
nondeterminism rather than assuming either way.** r10oth6 recorded Scoreboard as
"not a mover" for the virtual-interface shape and warned that its `default`
database flips md5 on EVERY binary, so a flat count reads as a regression.
`ctflake.sh Scoreboard <pristine> <final> 4 default` (shipped):
pristine `d03a7926a225, 29162a82e25a, d03a7926a225, d03a7926a225`;
final `3db54b897da2, 472c430da8d4, 3db54b897da2, 472c430da8d4`.
**The two md5 SETS are DISJOINT**, so the mover is real; the nondeterminism is
present on BOTH binaries (two md5s each) and neither creates nor hides it. The
+37 `vpiClassDefn` edges are the law effect — UVM uses `semaphore` and `process`.

`BuildUVMPkg` is likewise a NEW mover relative to r10oth6, for the same reason,
and its `ref_typespec (uvm_pkg::uvm_pool::type_id)` head is UNCHANGED at 17 cmp
lines.

### 5.2 THE ONE PLACE A DISTANCE ROSE — reported, measured, and explained

`ctheads.sh` (shipped) prints the head AND the dump distance for each mover, and
two of them got LONGER dump diffs:

| mover | mode | dump content BEFORE → AFTER | head BEFORE → AFTER |
|---|---|---|---|
| SVSwitch | both | **2713 → 2697** | `class_defn (work@mailbox)` → `array_var (work@packet::data)` |
| SeqDriver | both | **529898 → 528476** | unchanged (81 cmp lines) |
| SimpleUVM | default | 248318 → 248316 | unchanged (81 cmp lines) |
| SimpleUVM | testflags | 248322 → **248332 (+10)** | unchanged |
| BuildUVMPkg | both | 183349 → **183385 (+36)** | unchanged (17 cmp lines) |
| Scoreboard | default | 239097 → 239091 | unchanged (81 cmp lines) |

**IT IS NOT A FLAKE.** `ctflake.sh SimpleUVM … 3 testflags` gives
`b3371f27e3d5` three times on the pristine binary and `d91864d16757` three times
on the final one — that database is DETERMINISTIC, so the +10 is a real change.

**IT IS OUR OBJECT SURPLUS, and the FIELD census proves the fields went the right
way.** Measured against golden directly (not own-vs-own):

| test | golden objects | ours objects | golden `neither` | ours `neither` before → after | ours `NAME_ONLY` before → after (golden 0) |
|---|---|---|---|---|---|
| SimpleUVM testflags | 5740 | **6244** (+504) | **21** | 46 → **21** — EXACTLY golden's | 14 → **2** |
| BuildUVMPkg default | 5748 | **6421** (+673) | **27** | 57 → **27** — EXACTLY golden's | 14 → **2** |

Every field count moves TOWARD golden and two of them land exactly on it. The
line count nevertheless rises because we carry 504 / 673 class_typespec objects
golden does not have at all, so a correctly-added field lands partly on surplus
objects and each such field is a `+` line in the diff. That is **residue R2**
showing up as a cost of R2, not a defect of this pass's laws — and the honest way
to read it is that the DUMP LINE COUNT is confounded by a surplus-object residue
while the FIELD CENSUS is not.

**Zero rows moved on either corpus, and no head regressed anywhere.**

---

## 6. RANKED RESIDUE — most reachable first, ONE consistent number per residue

**R1 — `vpiSigned` sits on the `array_var`, not on its `vpiReg` element var, for a
DYNAMIC-ARRAY / QUEUE / ASSOC CLASS PROPERTY. DIRECTION: MOVE one field (ADD on
the array_var, DELETE on the reg). Depth: SHALLOW — the rule is ALREADY
IMPLEMENTED AND MEASURED elsewhere in this tree. THIS IS SVSWITCH'S CURRENT
HEAD.**
Golden's `array_var (work@packet::data)` (`rand byte data[];`, `Packet.sv:23`)
carries `|vpiSigned:1` and its `vpiReg` `byte_var` does NOT; ours is the exact
mirror image. `src/TypeEmit.cpp` already does this for the module-scope shape —
grep the comment **`Signedness rides the ARRAY here, not the element (measured)`**,
which sets `av->VpiSigned(true)` and `reg->VpiSigned(false)`. The class-property
arm is `UhdmExporter::emitClassDefn`'s dynamic/queue/assoc block (grep
`class array property element`, the `s.MakeArray_var()` just below it), and it
sets neither: the signedness arrives on the element from `makeReturnVar` and is
never moved. Reach: every `rand byte/int/shortint/… x[]` class property; SVSwitch
has one and it is the head. **Not attempted here** — it is not in this pass's
shape and it needs its own arm grid over the four integer kinds × array kinds
before it can be trusted, plus a re-sweep.

**R2 — we emit MORE `class_typespec` objects than golden. DIRECTION: DELETE (or,
more likely, golden mints one per VIEW and we share). Depth: unknown. Reach:
LARGE — 504 surplus objects on SimpleUVM, 673 on BuildUVMPkg, 3 on SVSwitch.**
On SVSwitch the surplus is the mirror image: golden has **35** objects and we have
**32**, missing a SECOND `Environment`, a SECOND `small_packet` and the one
`Receiver` at `20:3`. On UVM the sign flips and we have hundreds MORE. Both look
like the same underlying question — how many objects a class handle gets across
the def and elab views — and it is what makes the raw dump LINE count an
unreliable judge for this cluster (§5.2). Measure golden's per-view minting before
touching anything.

**R3 — a WRITTEN `#(...)` extends OUR `class_typespec` span; golden's stops at the
class NAME. DIRECTION: REPLACE (the end token). Depth: shallow. Reach: every
`C #(...) h;` handle. LATENT for rows; it moves bytes.** Arm `c1_builtins`:
`mailbox #(int) a4_mbi;` golden **30:3-30:10**, ours **30:3-30:17**;
`u_par #(int) a7_par;` golden **36:3-36:8**, ours **36:3-36:15**. A SECOND,
separate half rides the same cell: golden's built-in `mailbox #(int)` typespec
carries **NO `vpiParameter` / `vpiParamAssign` at all** (Surelog's `builtin.sv`
`mailbox` is not parameterized) while ours carries two `type_parameter`s and their
`param_assign`s. **NOT TOUCHED, deliberately: span changes are this campaign's
over-fire class and this one needs a full arm grid** — recorded so the next pass
inherits the measurement, not the guess.

**R4 — a BUILT-IN handle declared as a local of a subroutine or statement block
OUTSIDE a class is an `unsupported_typespec` in golden, a `class_typespec` in
ours. DIRECTION: REPLACE the object KIND. Depth: medium (it changes an object's
class). Reach: 4 objects in arm `c3_bounds`; UNMEASURED in the corpus.**
Cells `d5` / `d10` / `d11`. Golden's object carries `vpiName` and `vpiInstance`
and nothing else, and after law A's narrowing (§2.2) ours carries exactly those
two — so the ONLY remaining difference is the kind. That is why the narrowing
exists and why this residue is now one field away rather than two.

**R5 — a NESTED class reached as a subroutine local gets NO `class_typespec` in
golden; we emit one. DIRECTION: DELETE. Depth: unknown. Reach: 2 objects in arm
`c3_bounds` plus 1 in `c2_localname`; UNMEASURED in the corpus. PRE-EXISTING —
identical on the pristine binary.** Cells `d2` (`d1_outer::d1_inner v;` in a
package), `d8` (the same in a module) and `b3` (`b3_inner v;` inside its own outer
class, bare name). Golden mints a **`ref_var`** for `b3` instead of a
`class_var`, i.e. it does not resolve the type at all. Named here only so a reader
of the arm tables does not mistake it for a mover of this pass.

**R6 — a class METHOD's class-handle RETURN typespec is anonymous in ours;
golden names it when the home components differ. DIRECTION: ADD a name. Depth:
shallow (it is law B's predicate at a second site). Reach: every class method
returning a class handle — which is most of UVM, so it is the RISKIEST of these.**
Arm `c2_localname` cell `b7`: `function b1_target t3();` in a $unit class →
golden `class_typespec (b1_target)` at `54:12`, ours anonymous. The site is
`src/TaskFuncEmit.cpp` (grep the comment
`A CLASS-HANDLE return: an ANONYMOUS class_typespec at the return-type token`),
and that comment's "anonymous" is CORRECT for the same-component case it was
measured on — a `uvm_pkg` method returning a `uvm_pkg` class — which is exactly
what the home-component law predicts. **Deliberately not done here**: it would
change return typespecs across the whole UVM corpus and it earns nothing on the
target (SVSwitch has no class-typed method return — verified by grep). Do it with
its own arm grid and its own sweep.

**R7 — A POINTER ENTRY, NOT A RESIDUE OF ITS OWN. Read the labels inside it in
`r10oth6`'s NUMBERING, which is a DIFFERENT NAMESPACE from this file's R1-R8 —
r10oth6's R3 is not this file's R3.** The brief's rule is one consistent number
per residue, so nothing below is renumbered into this file's space; it is cited
where it was defined. All of it is UNTOUCHED by this pass and none of it was
re-measured, so every figure stands exactly as `r10oth6repro/README.md` records
it. In r10oth6's numbering: the array
of virtual interfaces (12 sites, ADD), the module-scope virtual-interface net
absent from golden's ELAB view (DELETE), `typedef virtual <iface> t;` publishing a
`vpiTypedef` interface_typespec (ADD), golden emitting no `class_defn` for an
`interface class` (declared UNMEASURABLE), law C's span ignoring
`VirtualInterfaceTypeSyntax::parameters` (26 sites, LATENT, left unfixed as the
over-fire class), and the nested `virtual class` `vpiVirtual` (pre-existing).

**THE BRIEF'S ITEM D — r10oth6's R3 and R4 as cheap follow-ons — WAS DECLINED, and
it is a decision, not an omission.** Item D conditions them on clean gates, and
the gates ARE clean, so the condition was met and the answer is still no. The
reason is that "cheap" prices the edit and not the evidence: every one of the five
gates would have to be re-run, i.e. another pair of ~40-minute corpus sweeps plus
a fresh byte-verifier pass on both corpora, and the patch would then be judged on
whichever half of it was measured last. This pass already moved the target's head
across two clusters and closed both halves of the named cluster; a third,
unrelated shape bolted on afterwards is how this campaign has previously shipped
an over-fire that only one of the five gates could see. **R3 and R4 are left with
their directions and their site counts recorded so the next pass starts from a
measurement rather than a guess** — which is the cheap part actually being
delivered. The brief's R7 (the `parameters` span, 26 sites) and R5 (`interface
class`, declared unmeasurable) were likewise not touched, exactly as instructed.

**R8 — 2 to 4 `NAME_ONLY` `class_typespec (process)` objects survive in every UVM
database, and they are SURPLUS objects, i.e. R2 wearing a different hat.
DIRECTION: ADD an edge (or DELETE the object). Depth: unknown. Reach: 2 on
SimpleUVM / BuildUVMPkg / Scoreboard, 4 on SeqDriver, 0 on SVSwitch.**
Measured with `ctcount.sh`'s breakdown, golden vs ours on BuildUVMPkg: golden has
**8** `class_typespec (process)` objects and ALL EIGHT carry the edge; ours has
**those same 8 with the edge plus 2 MORE with no edge**. Golden has no
`name=process defn=-` object at all, so the residue is two objects we mint and
golden does not, that consequently never reached `drainPendingExtends`. Best next
lead: they are minted after the drain, or at one of the twelve
`MakeClass_typespec` sites that never push to `pendingClassTsLink`.

**A METHOD NOTE FROM FINDING R8, because it nearly went into this file as a
false list.** My first extractor for these objects post-processed
`ctweak.sh`'s `grep -A4` output in python and reported ~150 `NAME_ONLY` objects,
flatly contradicting `ctcount.sh`'s 2. `ctcount.sh` was right: the `-A4` text
includes INDENTED reference appearances and truncates a block at four lines, so a
`vpiParent` sub-block hides the `vpiClassDefn` that follows it. **A broken counter
reports a closed head — and here it nearly reported an open one.** The discarded
number is recorded rather than quietly dropped, and `ctweak.sh`'s own header now
says its output is for reading, not for counting.

---

## 7. THE SVSwitch HAND COUNTS THE NUMBERS CROSS-CHECK AGAINST

SVSwitch's TEN written `mailbox` declarations, all listed so the reach figure is
hand-checkable:

| # | site | position |
|---|---|---|
| 1 | `Driver.sv:14` `mailbox drvr2sb;` | class property |
| 2 | `Driver.sv:18` `…,mailbox drvr2sb)` | ctor formal |
| 3 | `Receiver.sv:15` `mailbox rcvr2sb;` | class property |
| 4 | `Receiver.sv:18` `…,mailbox rcvr2sb)` | ctor formal |
| 5 | `Environemnt.sv:22` `mailbox drvr2sb ;` | class property |
| 6 | `Environemnt.sv:23` `mailbox rcvr2sb ;` | class property |
| 7 | `Scoreboard.sv:14` `mailbox drvr2sb;` | class property |
| 8 | `Scoreboard.sv:15` `mailbox rcvr2sb;` | class property |
| 9 | `Scoreboard.sv:18` `new(mailbox drvr2sb,…)` | ctor formal |
| 10 | `Scoreboard.sv:18` `…,mailbox rcvr2sb)` | ctor formal |

Six properties + four formals = ten, and the SVSwitch dump carries exactly TEN
named `mailbox` class_typespec definitions, so the source count and the dump
count cross-check each other. `ctreach.sh` ASSERTS `-eq 10` and exits 4
otherwise; its first draft read 9 because its terminator class omitted `)` and so
missed the second formal on a shared line, and 7 before that because it also
missed the first. **The instrument now carries the number it proves, not one it
inherited.**

The four class-method-local `packet` sites law B names:
`Driver.sv:32`, `Receiver.sv:31`, `Scoreboard.sv:25` (twice).

**CORPUS REACH** (`ctreach.sh`, shipped, per-test breakdown printed, PCRE
zero-width assertions on both ends so two declarations on one line both count):
**60 written built-in-class declarations** across both corpora — **10** in
`Surelog/tests`, **50** in `Surelog/third_party/tests`, **0** in
`uhdm2rtlil/test`. Top tests by FILE count: Opentitan 7, Google 7,
XilinxUnisimLibrary 5, Ibex 5, ariane 5, SVSwitch 4, AmiqEth 4. **The zero on
`uhdm2rtlil` is exactly why that corpus has 0 byte movers** — the reach counter
and the byte verifier agree, which is the cross-check that neither is broken.

Law B's reach is reported as an **UPPER BOUND** on purpose: deciding a cell needs
the two HOME COMPONENTS, which grep cannot see. The bound is **7185 class
declarations** (243 + 6935 + 7), and the per-cell verdicts live in the arm tables
and in the mint counts of §5.1, not in a headline number.

---

## 8. ASSETS SHIPPED (every one cited above exists here and was run)

| file | what it does |
|---|---|
| `ctarm.sh` | arm driver. `SLANG_UHDM` has NO DEFAULT; strips uhdm-dump's first line on BOTH sides; guards both uhdm-cmp inputs; the JUDGE is `diff -u g.dump o.dump`, not `PASS_CMP`. **Runs with builtins ON** — r10oth6's `viarm.sh` used `-nobuiltin`, which deletes `mailbox`/`semaphore`/`process` from both sides and cannot see half A at all. `NOBUILTIN=1` restores the old behaviour as a control |
| `ctdump.sh` | one (golden, ours) pair → cmp lines (labelled HEAD DEPTH) **and** dump content lines (labelled DISTANCE). Fatal on a missing input, because uhdm-cmp exits 0 on one |
| `ctcount.sh` | the field census: class_typespec objects, `withName`, `withClassDefn`, and the two half-missing populations, per side, from the `\_weaklyReferenced:` DEFINITION listing. REFUSES a dump that still has line 1. Carries a PARTITION SELF-CHECK that exits 4 if the four buckets do not sum to the total |
| `cttab.py` | the same census joined into one row per `(name, loc)` cell, printing `UNMEASURED(no such object on this side)` where a side has none. **Stated limitation:** two objects sharing a name AND a span collapse into one row — read `d.diff` for those |
| `ctweak.sh` | prints one side's `\_weaklyReferenced:` class_typespec definitions with their own fields; `UNMEASURED` + exit 3 when a dump has no such section. **Its header says FOR READING, NOT FOR COUNTING** and names the exact wrong number a counting use produced (§6 R8) |
| `ctexplain.sh` | runs `ctmints.sh` over every mover the byte verifier named, so §5.1 attributes each one to a law instead of asserting that it could. A mode with no database on one side prints UNMEASURED |
| `ctheads.sh` | the before/after HEAD table: cmp lines (HEAD DEPTH), dump content (DISTANCE) and the head object, per side. Reads each golden out of the workdir's own `cmds.txt`, so no golden path is ever guessed. **A bare test name is GLOBBED to `verify_golden.py`'s hashed `<Test>-<hash>` workdir** — see §8.2, that was a shipped defect |
| `ctcan2.sh` | the SUPPLEMENTARY canary check: the four exact names and three families the brief names but `canaries.sh` does NOT carry (§4.2.1). Compares the WHOLE ROW, status **and** dump column. `EXPECT_UNKNOWN` forces the caller to state the measured cross-corpus unmatched count (1 surelog / 6 u2r) so an unmatched pattern is never silently green |
| `ctflake.sh` | runs ONE test N times per binary and prints each database's md5, so a known-nondeterministic mover (Scoreboard) can be SETTLED rather than excused. Used for Scoreboard (4×, disjoint sets → real mover) and SimpleUVM testflags (3×, identical → deterministic) |
| `ctmints.sh` | MINT-SITE counter: diffs OUR pristine dump against OUR patched dump (both sides ours, not a golden comparison) and reports the census delta as OBJECT counts AND the raw LINE counts, each labelled |
| `ctrows.sh` | the row gate: whole-row diff vs the committed baseline plus per-mode status and dump histograms; prints ROWS, not lines, and says the header is not a row |
| `ctreach.sh` | corpus reach with a per-test breakdown, and a self-check asserting SVSwitch `-eq 10` |
| `c1_builtins.sv` | arm 1 — 17 cells, built-in vs user vs typedef vs parameterised vs package class in five positions |
| `c2_localname.sv` | arm 2 — 10 cells bounding the naming rule |
| `c3_bounds.sv` | arm 3 — 11 boundary cells, including the three that forced law A's narrowing |
| `c4_crosscomp.sv` | arm 4 — the 6 cross-component cells where the new rule disagrees with the old one |

The byte verifier is `tools/probe/r10oth6repro/byteverify.sh`, reused unchanged
(both `SELFCHECK` and `SELFCHECK1` exercised); the canary script is
`tools/probe/r10uvm52repro/canaries.sh`, reused unchanged with both of its
controls exercised. Neither is copied here — one instrument, one location.

### 8.1 EVERY GUARD I CITE, AND THE CONTROL I ACTUALLY RAN FOR IT

"A cited guard that does not exist can never read as green" — so each row below is
a control that was executed, with the number it produced.

| guard | negative control | POSITIVE control after tightening |
|---|---|---|
| `ctdump.sh` missing-input guard (uhdm-cmp exits 0 on one) | `/nonexistent.uhdm` → `FATAL: missing golden`, **exit 9** | real pair → the 361/2713 baseline reading |
| `ctmints.sh` missing-input guard | `/nope.uhdm` → **exit 9** | five real movers measured in §5.1 |
| **`ctcount.sh` / `ctweak.sh` / `cttab.py` line-1 guard — THIS ONE DID NOT BITE AT FIRST** | raw dump → `REFUSED`, **exit 8 / 8 / 8**. Before the fix it was **silently accepted**: the guard tested `endswith('.uhdm')` / `'\.uhdm$'`, and uhdm-dump's line 1 is `<path>.uhdm: Restored design Pre-Elab:`, so the path is not at the end of the line | stripped dumps → **exit 0** on all three, same numbers as before the fix |
| `ctcount.sh` PARTITION self-check (the four buckets must sum to the object total) | a copy with one bucket double-counted → `SELFCHECK FAIL: partition 35 != total 62`, **exit 4**. **Its exit propagation was ALSO broken at first** — `echo "$(one …)" \|\| exit 4` takes echo's status — and running this control is what found it | real dumps → **exit 0** |
| `ctweak.sh` / `cttab.py` UNMEASURED | a dump with no `\_weaklyReferenced:` section → `UNMEASURED`, **exit 3** on both | real dumps → exit 0 |
| `ctreach.sh` SVSwitch self-check | first draft printed **7**, second **9**, both `SELF-CHECK FAILED` **exit 4**; the ERE separator class was consuming the character the next match needed | PCRE version prints **10**, exit 0 |
| `ctrows.sh` row gate | one flipped status cell → **2 differing rows**, test named | the real CSVs → **0 differing rows** on both corpora |
| `canaries.sh` UNKNOWN-NAME | `ZZZ_TYPO_NOT_A_TEST` injected → printed, `unknown-names` 7 → **8** | the real CSV → 7 (the u2r-only names), `ok=52 changed=0` |
| `canaries.sh` CHANGED | SVSwitch status flipped in a CSV copy → `CHANGED CMP_NOTEQUAL/ -> CMP_EQUAL/`, `changed=1` | the real CSV → `changed=0` |
| `byteverify.sh` `SELFCHECK` | 678/679 and 952/953 flagged | 0 and 9 movers |
| `byteverify.sh` `SELFCHECK1` | one corrupted byte → **1** and **10** (= 9 real + 1) | as above |
| goldens harness | `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** | this worktree's build → **23 PASS / 0 FAIL** |
| **`canaries.sh` COVERAGE — audited, and it did NOT cover what §4.2 cited it for** | `grep` for the four brief-named canaries in its `NAMES` → **no match**; the citation was struck (§4.2.1) | `ctcan2.sh` written to cover the audited gap → **PASS on both corpora** |
| `ctcan2.sh` `EXPECT_UNKNOWN` | typo'd pattern → count 1 → **2**, `FAIL … but EXPECT_UNKNOWN=1`, **exit 6** | both corpora at their measured counts → **exit 0** |
| `ctcan2.sh` whole-row (dump column too) | `BlackConst` dump column `differ` → `match` → `CHANGED`, `changed=1`, **exit 5** | the real CSVs → `changed=0` |
| **`ctheads.sh` test-name resolution — ALSO A SHIPPED DEFECT** | `ZZZ_TYPO_NOT_A_TEST` → **`NO-SUCH-TEST`**, distinct from `UNMEASURED` | bare `SVSwitch` → the 361/2713 → 132/2697 table; hashed `SVSwitch-db796243` → identical |

**FIVE of my own instruments were wrong before these controls ran** — the line-1
guard, `ctcount.sh`'s exit propagation, `ctreach.sh`'s regex, and (found at
integration, §8.2) `ctheads.sh`'s test-name resolution plus the `canaries.sh`
citation that `ctcan2.sh` now replaces. One throwaway extractor was wrong too
(§6 R8). Every one was caught by running the control rather than by citing it.

### 8.2 THE TWO DEFECTS FOUND AT INTEGRATION, AFTER §§1-7 WERE ALREADY WRITTEN

Both were found by re-running this pass's own measurements from scratch on the
committed tree rather than re-reading the write-up. Recorded because the campaign
keeps paying for exactly these two shapes.

**(1) `ctheads.sh` printed `UNMEASURED` for a caller mistake.** `verify_golden.py`
names each workdir `<Test>-<hash>`, so the obvious `ctheads.sh <pri> <fin>
SVSwitch` found no `cmds.txt` and printed `UNMEASURED (no cmds.txt)` for all four
cells. **`UNMEASURED` is the word this campaign reserves for "the database does
not exist", so a caller mistake wore the costume of a measurement that could not
be taken** — and a reader would have concluded SVSwitch had no database. The name
is now globbed to its hashed directory and the two real failures are reported
DIFFERENTLY, `NO-SUCH-TEST` and `AMBIGUOUS`, neither of which can be misread as
`UNMEASURED`. Both controls in the §8.1 table.

**(2) §4.2 cited `canaries.sh` for four names it does not carry** — the campaign's
"a cited guard that does not exist" trap, committed by this pass. Full account,
the audit that found it, the wider gap it exposed, and the `ctcan2.sh` that closes
it: **§4.2.1**. The struck sentence is gone from §4.2, not merely annotated.

---

## 9. INDEPENDENT RE-VERIFICATION OF THIS WRITE-UP, ON THE COMMITTED TREE

Every headline figure below was re-measured from scratch against the committed
tree and the two committed baselines, on the FINAL binary
`69bbc29e0467bd878e37dd3a4fb265a5`, which was confirmed to POSTDATE all three
edited sources (binary 10:27:45; `TypeEmit.cpp` 10:23:08 the newest source) — so
the stale-binary trap is answered by TIMESTAMP ORDER, not just by exporting a
path.

| figure | §  claim | re-measured | verdict |
|---|---|---|---|
| SVSwitch row, both modes | CMP_NOTEQUAL → CMP_NOTEQUAL | `CMP_NOTEQUAL` on both binaries, both modes | **CONFIRMED — did NOT convert** |
| SVSwitch cmp lines | 361 → 132 | 361 → 132, both modes | **CONFIRMED** |
| SVSwitch dump content | 2713 → 2697 | 2713 → 2697, both modes | **CONFIRMED** |
| SVSwitch head after | `array_var (work@packet::data)` | `array_var: (work@packet::data), id:3774, line:23:11, endln:23:15` | **CONFIRMED** |
| census: mailbox edge | ours 10 of 10 missing → 10 of 10 present | `name=mailbox defn=-` ×10 → `name=mailbox defn=work@mailbox` ×10 | **CONFIRMED; the brief's "6 of 10" REFUTED again** |
| census: packet name | ours 5 named + 4 unnamed → 9 named (golden 9) | exactly that | **CONFIRMED** |
| census totals | `withClassDefn` 22→32 of 32, `withName` 20→24, `NAME_ONLY` 10→0, `DEFN_ONLY` 12→8 | identical, and `DEFN_ONLY` lands on golden's **8** | **CONFIRMED** |
| goldens | 23 PASS / 0 FAIL | 23 / 0; `/bin/false` → 0 / 23 | **CONFIRMED** |
| row gate, uhdm2rtlil | 731 rows, 0 differing | 731 rows, **0** differing row-lines | **CONFIRMED** |
| row gate, surelog | 1588 rows, 0 differing | 1588 rows, **0** differing row-lines | **CONFIRMED** |
| byte verifier, uhdm2rtlil | 679/679, paths identical, 0 movers | identical, **0** | **CONFIRMED** |
| byte verifier, surelog | 953/953, paths identical, 9 movers | identical, **9**, and they are exactly the 5 named tests (4 × both modes + Scoreboard default) | **CONFIRMED** |
| byteverify controls | `SELFCHECK` 678/679; `SELFCHECK1` 1 and 10 | 678/679; **1** on u2r, **10** on surelog | **CONFIRMED** |
| canaries | `ok=52 changed=0 absent=0 unknown=7` | identical; u2r `ok=8 changed=0 unknown=25` | **CONFIRMED** |
| cross-campaign ordering | preserved | `pkgImportCloneLastWriter32` → `lawSCopyHomeInstance36` adjacent; `classInheritsContainerImports23` → `modulePublishesPackageClasses45` → `thisImplicitNetBoth38` last; `hierCallArgTakesBase39` a § marker inside `cloneStmtHomeVarRef17`'s block | **CONFIRMED untouched** |

The independent row judge was itself controlled: flipping one `SVSwitch,default`
status cell in a CSV copy made it report **2 differing row-lines** (the `<` and
the `>`) and name the test, while the untouched uhdm2rtlil side stayed at 0.

**Scoreboard's nondeterminism re-checked in passing.** This run's `default` md5s
were `pristine=29162a82e25a` / `patched=472c430da8d4`; both are members of the
sets §5.1 recorded from 4 runs each (`{d03a7926a225, 29162a82e25a}` and
`{3db54b897da2, 472c430da8d4}`). The sets are still disjoint, so the mover is
still real and the flake still spans both binaries.

**Nothing in §§1-7 was changed by this re-verification** except the two integration
defects in §8.2 and the §4.2 sentence they invalidated.
