# r10uvm50 — the UVM-4 declaration-site law, FOUR laws landed, NO conversion

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order. Every dump excerpt is passed through `sed 's#/home/[^ ,]*/##g'`.

Base **8c14dc7**. Every number below was measured on MY build in MY worktree; the
control build of pristine 8c14dc7 came out `md5 570b867dc631e11b728ee1b058e29fa8`,
**byte-identical to the pass-49 verifier's build of 133f5ee** — pass 49 shipped no
production code, so that identity independently validates the control.

## 0. HEADLINE — honest

* **NONE of the four tests CONVERTED.** All four are still `CMP_NOTEQUAL`
  (Scoreboard/`testflags` still `SLANG_REJECT` at baseline). No row in either
  committed baseline changed. **No CONVERSION to promote.**
* What DID happen: the head moved **twice**, the four tests' cmp output went
  **50 lines → 15 lines** in all seven comparable rows, and the head is now a
  **completely different family** — the class-handle-typedef law is FINISHED as
  far as cmp can see it, and what blocks the four now is an unrelated
  associative-array residue that was ALREADY THERE at 8c14dc7 (proved in §9).
* Four laws, each measured, each with its own witness:
  `classTdTopOnlyShare50`, `classPropNoStampShared50`, `pkgImportClassTdClone50`,
  `classNestedClassTdJoinsPkgGroup50`.

Head census on my binary, `heads.sh` (which counts heads with
`grep -c '^LHS:'` at column 0 and REFUSES to print a number it cannot
substantiate):

| stage | binary md5 | cmp lines (all 7 rows) | heads | head shape |
|---|---|---|---|---|
| 8c14dc7 control | `570b867d` | 50 | 1 | declaration-site mint (`class_typespec (uvm_pool)`) |
| + law 1 | `1284f496` | **17** | 1 | 2 shapes: `uvm_pool::this_type` alias missing (3 tests) / module-listing alias missing (SeqDriver) |
| + law 2 | `4fe763b2` | 17 | 1 | same (law 2 is dump-only) |
| + law 3 | `a7529fd7` | 17 | 1 | ONE shape for all four: `this_type` alias missing |
| + law 4 (final) | `9dd2bba7` | **15** | 1 | assoc-array `vpiIndexTypespec` (NEW family, pre-existing) |

Per-row, final binary (`heads.sh /tmp/r10uvm50_p4_wd`):

```
TEST           MODE      CMPLINES  HEADS HEAD_MD5_IDNORM
BuildUVMPkg    default        15      1 921a513a6a5515c84372a45b6302fdc7
Scoreboard     default        15      1 aff2b0346aa24749f5e18e4dc40a7dfc
SeqDriver      default        15      1 aff2b0346aa24749f5e18e4dc40a7dfc
SimpleUVM      default        15      1 aff2b0346aa24749f5e18e4dc40a7dfc
BuildUVMPkg    testflags      15      1 921a513a6a5515c84372a45b6302fdc7
Scoreboard     testflags       -      - SKIP-NOFILE   (SLANG_REJECT at baseline)
SeqDriver      testflags      15      1 aff2b0346aa24749f5e18e4dc40a7dfc
SimpleUVM      testflags      15      1 aff2b0346aa24749f5e18e4dc40a7dfc
---- measured=7  skipped=1
```

Note the id-normalised md5: **SeqDriver joined Scoreboard and SimpleUVM at law 3**
(it had its own `a693678b` before), so law 3's necessity is visible in the census
itself, not only in the arm.

## 1. Drivers and arms (all committed here)

| asset | what it is |
|---|---|
| `gold.sh` | one arm, golden + ours, dump + cmp. Copied verbatim from `r10uvm49repro` (guards intact: `uhdm-cmp` exits 0 on a MISSING input, so both databases are existence-checked; the slang path + md5 is printed every run). |
| `corpdump.sh` | **new** — dump BOTH sides of one CORPUS test out of a `verify_golden` workdir and cmp them. Written because the arms are not the corpus (see §2). Guards: golden path in `cmds.txt` is a **DIRECTORY**, `golden.uhdm` is appended; both sides existence-checked; heads counted at column 0. |
| `heads.sh`, `uvm4both.sh` | copied from `r10uvm49repro`, unchanged. |
| `csvdiff.py` | **new** — WHOLE-ROW diff (status AND dump) of a sweep CSV against the committed baseline, plus both histograms. Row counts come from the parsed dict, never from `wc -l` (which counts the header). |
| `a1/dut.sv` | pass-49's decider arm, copied so this directory stands alone. |
| `a7/dut.sv` | **new** — THE TRANSITIVE RE-EXPORT (pass-49 §5 / brief trap 4). |

## 2. TRAP 1 RE-MEASURED, AND IT CUTS BOTH WAYS — a7 IS cmp-visible

The brief and `r10uvm49repro` both warn: *"EVERY ARM IS CMP_EQUAL WHILE CARRYING
THE DEFECT … JUDGE EVERY ARM ON `diff -u g.dump o.dump`, NEVER ON cmp.txt."*
Confirmed for `a1` on my own binary — and **refuted as a general statement**:

| arm | 8c14dc7 `cmp rc` | cmp lines | heads |
|---|---|---|---|
| `a1` (module imports the package DIRECTLY) | 0 | 0 | 0 |
| `a7` (module over an INTERMEDIATE package) | **255** | **149** | **1** |

`a7` — the cell the brief told me to build first, and no earlier arm covered — is
**cmp-VISIBLE**. That is why the corpus is cmp-visible while `a1` is not: the
transitive re-export takes a different emitter path (§5) whose object does not
pair EQUAL through the container's `vpiTypedef` list, so `m_visited` never
short-circuits.

So the correct rule is **judge every arm on the DUMP, and read `cmp.txt` too when
it is non-empty** — a1 needs the dump, a7 hands you a head. I gated every law on
`diff -u g.dump o.dump` regardless.

`a7`'s content ± line count, i.e. `diff -u g.dump o.dump | grep -c '^[-+]'`
**minus the 2 `diff -u` file-header lines** (the raw count is content+2 — stating
the convention because three passes have not):

| binary | a7 content ± | raw `grep -c` | a7 cmp lines |
|---|---|---|---|
| 8c14dc7 `570b867d` | **207** | 209 | 149 |
| final `9dd2bba7` | **22** | 24 | **0** |

(the 8c14dc7 figure was re-measured on /tmp/r10uvm50_c_a7, not inherited.)  And the 22 that remain are exactly two things: **4 lines** of alias
`vpiFullName` container prefix (§8, `vpiFullName` is not read by
`BaseClass::Compare`) and **18 lines** of ARENA ORDER for two design-level
typespecs (`class_typespec (rh50)` and `int_typespec` at 31:5). `g.dump` and
`o.dump` are the same length (295 lines each) and nothing else differs.

## 3. Corpus-first: everything settled in the brief was RE-CHECKED on the corpus

The brief's §"WHAT IS ALREADY SETTLED" was measured in pass 49 on ARMS. I
re-measured the load-bearing half on the CORPUS with `corpdump.sh`, because the
arms had already proved themselves unfaithful once.

**CONFIRMED — our typedef PUBLICATION already matches golden object-for-object**
in the package-container case. `BuildUVMPkg`, `default`: the 15-line region of
`uvm_pkg`'s `vpiTypedef` entry for `uvm_id_verbosities_array` is **identical
text** on both sides at 8c14dc7 (`g.dump:325177`, `o.dump:325533`), alias,
doubled `uvm_pkg::uvm_pkg::…` fullname, `vpiInstance` and `vpiClassDefn`
included. I did not touch `src/ParamEmit.cpp:19120-19123` (the name-order pick, `std::get<0>(pkgClassTd9[i]) <`);
it is correct.

**REFUTED for the MODULE container.** In `SeqDriver` at 8c14dc7 our listing did
**not** match: every one of our **14** occurrences of that object was
(CORRECTED at integration — the write-up said 18. Golden's 16 is right and POST is
15, so the count has NOT converged: one golden reference is still unmatched.)
`line:31:9, endln:31:31` with two `vpiParameter` + two `vpiParamAssign` and **no
`vpiTypedefAlias`**, against golden's 16 occurrences at `line:29:9, endln:29:17`
with the alias and no parameters:

```
$ grep -o "class_typespec: (uvm_pkg::uvm_id_verbosities_array), line:[0-9]*:[0-9]*, endln:[0-9]*:[0-9]*" o.dump | sort | uniq -c
     18 class_typespec: (uvm_pkg::uvm_id_verbosities_array), line:31:9, endln:31:31
$ ... g.dump ...
     16 class_typespec: (uvm_pkg::uvm_id_verbosities_array), line:29:9, endln:29:17
```

**"The publication work is DONE. Do not redo it" is true for BuildUVMPkg and
FALSE for SeqDriver.** That is law 3, and it is a whole law the brief ruled out
of scope. A law that only ever saw one spelling had an unmeasured half.

## 4. LAW 1 — `classTdTopOnlyShare50` (`src/TypeEmit.cpp:835`)

**Direction: REPLACE — point at the existing object, do not mint.**

**Predicate.** In `makeTypespec`, after the `typedefTs` share arm: declared type
is a `TypeAlias`, `!bypassTypedefShare`, `arrayElemLeaf(declared type)`'s
canonical kind is `ClassType`, and `pkgTopTypedefTs` has a non-null entry for it
whose `UhdmType() == UHDM::uhdmclass_typespec`. Return that entry.

**Why the miss existed, exactly** (this is the fact the whole pass turns on, and
it is a one-line mechanism nobody had stated): the class-handle typedef arm in
`emitPackage` is `else if (topView) {` — `src/ParamEmit.cpp:18999`, the arm that
fills `pkgClassTd9` at `:19027` (`pkgClassTd9.push_back`) — so a class-handle typedef is registered in
`pkgTopTypedefTs` **only** (`src/ParamEmit.cpp:19100`, `pkgTopTypedefTs[&ta] = ts;`) and **never** in
`typedefTs` (`:19098`, `typedefTs[&ta] = ts;`, is the `!topView` half, which this arm cannot reach). The
share arm at `src/TypeEmit.cpp:804` keys the WHOLE lookup on `typedefTs` and only
consults `pkgTopTypedefTs` **inside** that hit, so every class-handle typedef fell
through to the class-handle MINT at `src/TypeEmit.cpp:960` (`auto* cts = s.MakeClass_typespec();`, whose `cts->VpiName(ct0.name)` at `:1052` is what put the GENERIC CLASS name on the declaration).

**Witness (corpus, BuildUVMPkg `default`, the single head at 8c14dc7).** Source
is `uvm_pkg.sv:30483` — and CORRECTED at integration: BuildUVMPkg compiles
**1800.2-2017-1.0**, so pp 30483 is `1800.2-2017-1.0/src/base/uvm_report_handler.svh:68`
and pp 30449 is its line 34 (the typedef trio at 34/35/36). uvm-1.2's line 62 and
its trio at 29/30/31 belong to the OTHER THREE tests. Do not mix the two UVM
versions' line numbers
`uvm_id_verbosities_array id_verbosities;`:

| | LHS golden | RHS ours (8c14dc7) |
|---|---|---|
| object | `class_typespec (uvm_pkg::uvm_id_verbosities_array)` **id:186109** | `class_typespec (uvm_pool)` id:179584 |
| span | `line:30449:9, endln:30449:17` | `line:30483:3, endln:30483:27` |
| vpiParent | `package uvm_pkg` | `class_var (uvm_pkg::uvm_report_handler::id_verbosities)` |
| vpiTypedefAlias | `ref_typespec -> class_typespec (uvm_pkg::uvm_id_actions_array)` id:186106 | absent |
| vpiInstance | `package uvm_pkg` | absent |

id **186109 is the very object in `uvm_pkg`'s own `vpiTypedef` list** — golden
reaches it 6 times in `g.dump`, ours reached its listing object only 2 times,
because our declaration sites all minted their own. Second witness, one level of
containment down and in the SAME test: `severity_id_verbosities` (an ASSOCIATIVE
array of the same typedef) — golden's `vpiReg class_var` also points at id 186109
(`g.dump:795662`).

**Arm witness (a1, `class_var (p49a::holder49::hz)` -> `vpiTypespec ->
ref_typespec -> vpiActual`):**

| | golden | ours 8c14dc7 | ours final |
|---|---|---|---|
| | `class_typespec (p49a::zzz_first_t), line:16:11, endln:16:15` | `class_typespec (gc49), line:19:5, endln:19:16` | **golden's object** |

`a1`'s content ± went **46 → 6** (raw `grep -c` 48 → 8), `g.dump` and `o.dump`
both 240 lines, and the **only** remaining 6 lines are the alias-ref
`vpiFullName` (`work@a1_top.p49a::zzz_first_t` vs our
`p49a::p49a::zzz_first_t`) — residue R3. Everything else in a1 is EXACT.

**HOW THE GATE WAS PROVED NECESSARY.** Not by the arm (a1 is `cmp lines=0` both
before and after — trap 1 in the flesh). By the CORPUS: with law 1 alone the
seven comparable rows went from **50 cmp lines to 17** and the head moved off this
pair entirely. A fix that reached nothing would have left 50.

## 5. LAW 2 — `classPropNoStampShared50` (`src/UhdmExporter.cpp:3953-3970`, `for (auto& pc : pendingClassPropTs)`)

**Direction: GUARD (suppress a stamp).** This is the shared-mutation hazard the
brief warned about (trap 2), and it **fired for real the moment law 1 landed** —
it is not a hypothetical and it was not in the region the brief predicted
(`ParamEmit:19155-19160`), it was 4000 lines away in the class-property write
phase:

```cpp
    for (auto& pc : pendingClassPropTs) {
        auto* ts = makeTypespec(*pc.sym);
        pc.rt->Actual_typespec(ts);
        if (ts)
            ts->VpiParent(pc.var);      // <-- unconditional at 8c14dc7
    }
```

**Measured regression** (`corpdump.sh /tmp/r10uvm50_p1_wd default SeqDriver`,
binary `1284f496`, law 1 in and law 2 out) — SeqDriver's `work@top_tb` listing
entry:

| | 8c14dc7 | law 1 only | golden |
|---|---|---|---|
| `vpiParent` of `class_typespec (uvm_pkg::uvm_id_verbosities_array)` | `module_inst work@top_tb` | **`class_var (uvm_pkg::uvm_report_handler::id_verbosities)`** | `module_inst work@top_tb` |

One class property re-parented the whole design's listing object. **Gate:**
`isSharedAliasTs(pc.sym->getDeclaredType()->getType(), ts)` — POINTER IDENTITY
through the registry (`src/UhdmExporter.cpp:1094` `bool UhdmExporter::isSharedAliasTs`, declared
`include/UhdmExporter.h`, **grep `bool isSharedAliasTs`** — the line number is
TREE-DEPENDENT and all three figures quoted for it have differed: 3098 at
8c14dc7, 3110 in the verifier's tree (8c14dc7+this patch), **3130 in the
integrated tree** which also carries r10oth3's +22 lines in that header. This is
precisely why a citation needs a SYMBOL beside it), never a canonical kind,
because `typedef int
myint` is a `PredefinedIntegerType` canonically and walks any kind guard.
Verified fixed on binary `4fe763b2`: the parent is `module_inst work@top_tb`
again. This law is **dump-only** (cmp does not read vpiParent here): the head md5s
were byte-identical across `1284f496` and `4fe763b2`, which is exactly why it had
to be caught in the dump.

## 6. LAW 3 — `pkgImportClassTdClone50`

Greppable sites, all four tagged `§ pkgImportClassTdClone50` in the code:
`src/ParamEmit.cpp:16986` (the `pkgImportClassTd50` declaration), `:17356` (the
CLASS-HANDLE clone SHAPE, inside the `else` that mints `cl8`), `:17413`
(`pkgImportClassTd50.push_back`, collected in BOTH views), `:17679` (the
`continue` that made this law necessary) and `:19152-19223` (the base/alias
resolution).

**Direction: RESHAPE + ADD.** The law the brief said was already done.

**Mechanism, TRACED not guessed.** I built a temporary `R10UVM50_TRACE`
instrumentation (removed from the shipped patch) printing every
`pkgTopTypedefTs` write in `emitPackage`. On `a1` it printed the two expected
class-handle entries; on `a7` it printed **nothing**, and the second trace pass
showed why:

```
R10UVM50 loop pkg=p50u top=1 td=aaa_v_t impByPkg=1
R10UVM50 share17604 pkg=p50u td=aaa_v_t clone=1 uhdm=2058 line=18:11-18:29
R10UVM50 loop pkg=p50u top=1 td=zzz_a_t impByPkg=1
R10UVM50 share17604 pkg=p50u td=zzz_a_t clone=1 uhdm=2058 line=19:11-19:29
```

`src/ParamEmit.cpp:17673` (`if (topView && pkgImportedByPkg.count(&pkg))`) hands
the TOP view the **import clone** and `continue`s, so the class-handle arm at
`:18999` (`else if (topView) {`) is never reached for a re-exported typedef. The
clone is built at
`src/ParamEmit.cpp:17341` by a plain `cl8 = makeTypespec(ta8, tSyn8);` +
`setLoc(cl8, tSyn8->sourceRange())`, which is why it carries the whole
`gc50#(string, int)` span and the specialization's `vpiParameter`/`vpiParamAssign`.

**The law.** A class-handle import clone must be built in the class-handle
LISTING shape: span = the GENERIC CLASS NAME TOKEN, `vpiParameter` and
`vpiParamAssign` EMPTY, and (for every non-base member of the generic-class
group) the base's span plus a `vpiTypedefAlias` ref to the base. Base pick and
grouping key are pass-49's laws, RE-MEASURED here on a7 (see the table).

**Arm a7 table, BOTH sides of every cell:**

| cell | LHS golden | RHS 8c14dc7 | RHS final |
|---|---|---|---|
| `p50u::aaa_v_t` (line 18, name-FIRST) span | `18:11, endln:18:15` (`gc50`, 4 chars) | `18:11, endln:18:29` (whole `gc50#(string, int)`) | `18:11, endln:18:15` |
| `p50u::aaa_v_t` vpiParameter / vpiParamAssign | none / none | 2 / 2 | **none / none** |
| `p50u::zzz_a_t` (line 19, name-LAST) span | `18:11, endln:18:15` — the BASE's | `19:11, endln:19:29` — its OWN | `18:11, endln:18:15` |
| `p50u::zzz_a_t` vpiTypedefAlias | `ref_typespec -> class_typespec (p50u::aaa_v_t)` | **absent** | present, target correct |
| that ref's vpiFullName | `work@a7_top.p50u::zzz_a_t` | (no ref) | `p50u::zzz_a_t` — **residue R3** |
| `p50u::rh50::id_v` declaration `vpiActual` | `class_typespec (p50u::aaa_v_t), 18:11-18:15` | `class_typespec (gc50), 22:5-22:16` | golden's object (law 1) |
| golden's `vpiInstance` on the clone | `package p50m` — the **INTERMEDIATE**, confirming pass-49 §5 | `package p50m` (already right) | unchanged |

**Base pick RE-CONFIRMED, not inherited:** a7's source order is `aaa_v_t` (18)
then `zzz_a_t` (19) and golden's base is `aaa_v_t` — consistent with name-first
and with source-first, so a7 alone does not decide it; I rely on pass-49's `a3`
(source order fully reversed) for the discrimination and I did NOT touch the
name-order comparison. **Grouping key = the generic class** (pass-49 `a4`), which
is why the code keys on `leaf->as<ClassType>().genericClass` and not on the
specialization.

**Mint ordering.** The group is `stable_sort`ed by **(file, line, col)** before the
base pick, so it can never depend on first-hit order.

**Shared-object discipline.** The clone is cached in `pkgImportCloneTs` and walked
again by the second package view and by every other importer, so: the span copy is
idempotent, and the alias is added **only when `Typedef_alias()` is absent** —
otherwise a second view would hang a duplicate `ref_typespec` child on a shared
object.

**HOW THE GATE WAS PROVED NECESSARY.** Two independent ways. (a) The arm: a7 went
`cmp rc=255 / 149 lines / 1 head` → `rc=0 / 0 lines / 0 heads`, dump content ±
100 → 16. (b) The corpus: **SeqDriver's id-normalised head md5 changed from
`a693678bbc56b232` to `aff2b0346aa24749`, joining Scoreboard and SimpleUVM** —
before law 3 SeqDriver failed on its OWN shape (missing module-listing alias,
`LHS ref_typespec (work@top_tb.uvm_pkg::uvm_id_verbosities_array)` vs
`RHS <null>`), after it fails on the same shape as the other three.

## 7. LAW 4 — `classNestedClassTdJoinsPkgGroup50` (`include/UhdmExporter.h:2941` `classTdGroupBase50;`, published `src/ParamEmit.cpp:19130` and `:19188` `classTdGroupBase50[k9] =`, consumed `src/UhdmExporter.cpp:1931` `auto* gcN50`)

**Direction: ADD (join an existing group).**

**Predicate.** In `buildClassTypedefTs`'s `ClassType` arm: the target's
`genericClass` has an entry in `classTdGroupBase50` (the base object the
PACKAGE-level class-handle group already resolved, published by both resolution
passes) and that base is not this object. Then copy the base's
line/col/endline/endcol/file, take the base's `vpiInstance` if this object has
none, and add a `vpiTypedefAlias` ref (fullname `clsName::name`) to the base.

**Witness — this was the SINGLE head of all seven comparable rows after law 3.**
`uvm_pool`'s own `typedef uvm_pool #(KEY,T) this_type;`
(CORRECTED at integration: `this_type` is **1800.2 `uvm_pool.svh:40`** = pp 14277;
uvm-1.2's `this_type` is line **39**, and uvm-1.2 line 37 is
`const static string type_name = "uvm_pool";`):

| | LHS golden (BuildUVMPkg) | RHS after law 3 |
|---|---|---|
| object | `class_typespec (this_type)` id:186335 | `class_typespec (this_type)` |
| span | `line:30449:9, endln:30449:17` — the PACKAGE base's | `line:14277:11, endln:14277:19` — its own |
| vpiParent | `class_defn (uvm_pkg::uvm_pool)` | `class_var (uvm_pkg::uvm_pool::m_global_pool)` |
| vpiTypedefAlias | `ref_typespec (uvm_pkg::uvm_pool::this_type) -> class_typespec (uvm_pkg::uvm_id_actions_array)` id:186106 | **absent — cmp printed `RHS: <null>`** |
| vpiInstance | `package uvm_pkg` | absent |

So a class-NESTED class-handle typedef joins the SAME generic-class group as the
PACKAGE-level ones and clones the base the PACKAGE pass already picked.

**REFUTATION recorded — the merged-name-sort model is WRONG.** If the group were
re-sorted over the merged set, `this_type` would be the base (`t` < `u` beats
`uvm_id_actions_array`) and golden would give `uvm_id_*` the alias. Golden does
the opposite. The operative rule is **the package pass resolves the base first
and the class-nested typedef aliases into it** — which is why the code publishes
`classTdGroupBase50` from the package pass and only READS it in
`buildClassTypedefTs`.

**HOW THE GATE WAS PROVED NECESSARY.** The corpus, exact md5s as measured:

| stage | BuildUVMPkg head md5 | Scoreboard / SeqDriver / SimpleUVM head md5 | cmp lines |
|---|---|---|---|
| after law 3 | `b85e9ceba04560bfd5f304d4beb26925` | `31464805c71f540a959b2a8ee5fc5591` (all three) | 17 |
| after law 4 | `921a513a6a5515c84372a45b6302fdc7` | `aff2b0346aa24749f5e18e4dc40a7dfc` (all three) | **15** |

Every head md5 changed and every row lost 2 cmp lines, so the arm ran and reached
the corpus. The decisive fact is that the head is now a **different UHDM family
entirely** (§9) — the `this_type` pair no longer differs.

## 8. Container-prefix rule — NOT attempted, and NOT counted as progress

Brief trap 3 / pass-49 §5. Golden's alias-ref `vpiFullName` is CONTAINER PREFIX +
a joiner set by the container KIND (`package` → none, `module_inst` → `.`,
`class_defn` → `::`) + the package-qualified name. Ours is `prefix + prefix + …`
at `src/ParamEmit.cpp:19147` (`art9->VpiFullName(prefix + prefix + …)`), right only for the package case — and for law 3's
import clones I set the ref's fullname to the clone's own `VpiName()`
(`p50u::zzz_a_t` where golden has `work@a7_top.p50u::zzz_a_t`), because the
container at clone-build time is the importing PACKAGE while the container that
finally lists the clone is the MODULE. **`BaseClass::Compare` does not read
`VpiFullName`**, so none of this is cmp-visible; it is DUMP_MATCH phase-3 work and
it is residue R3, HONESTLY NOT DONE.

## 9. Where the head is NOW, and PROOF it is pre-existing

All seven rows, one head, `LHS: <null>` / RHS an EXTRA object:

```
RHS:
ref_typespec: , id:49922
|vpiParent:
\_array_typespec: , id:49919
|vpiActual:
\_int_typespec: , id:49921, line:42:20, endln:42:23
```

Source: uvm-1.2 `base/uvm_pool.svh:42`, `protected T pool[KEY];` — an
ASSOCIATIVE array whose INDEX is the class's own **type parameter** `KEY`.
Golden's `array_typespec` for `uvm_pkg::uvm_pool::pool` (`g.dump:808878`) has
**no `vpiIndexTypespec` at all**; ours resolves `KEY` and emits a
`vpiIndexTypespec -> int_typespec` at the `KEY` token (`42:20-42:23`).

**PRE-EXISTING, proved:** the same object is in the 8c14dc7 database.
`grep -c "int_typespec: , line:42:20, endln:42:23"` gives **2** in the baseline
SimpleUVM `o.dump` (`/tmp/r10uvm50_c_su`) and **2** in the final one — same count,
same shape. My laws did not create it; they un-masked it by removing the four
earlier differences that `uhdm-cmp` reported first.

## 10. RANKED RESIDUE — most reachable first

**R1. `assocTdIndexIsTypeParam` — assoc-array index typespec when the index is a
TYPE PARAMETER. DIRECTION: SUPPRESS. Depth: shallow (one predicate at the
array_typespec builder). RANK 1 — it is the LIVE head of all seven comparable UVM
rows and the only thing between this pass and four conversions.**
Law: `protected T pool[KEY];` inside a parameterized class gets NO
`vpiIndexTypespec` in golden — Surelog's class-body `compileTypespec` does not
resolve a type-parameter index, while we resolve `KEY` to `int` and emit one.
Golden `g.dump:808878` (`array_typespec` bare, `vpiRange` marker only) vs ours
(`vpiIndexTypespec -> int_typespec 42:20-42:23`). PRE-EXISTING at 8c14dc7 (§9).
Do NOT gate this on the arms — none of a1/a7 has a type-parameter-indexed assoc
array; build that arm (`class C #(type KEY=int, type T=int); protected T p[KEY];`)
first, and expect it to be cmp-visible because the head IS this pair today.

**R2. `classNestedClassTdGroupWithoutPkgAnchor` — a class-nested class-handle
typedef whose generic class has NO package-level typedef. DIRECTION: ADD. Depth:
medium. RANK 2.** Golden still aliases it: `uvm_pool::type_id`
(`typedef uvm_object_registry#(...) type_id;` at `uvm_pkg.sv:14284`) carries
`line:26247:12, endln:26247:31` and a `vpiTypedefAlias`, i.e. a base at 26247 that
is a DIFFERENT class's `type_id`. Note 26247 is **not** the lowest line among the
`type_id` typedefs (uvm_pool's own is 14284) and all group members share the name
`type_id`, so **neither source order nor name order can pick this base** — the
unmeasured half is Surelog's class COMPILE order (the design's class list is
sorted by SHORT class name, `src/UhdmExporter.cpp:3906-3908`, the "Surelog compiles builtin.sv before the user sources" comment). MEASURE THAT
before writing code. My law 4 deliberately does nothing here (no
`classTdGroupBase50` entry ⇒ no alias), which is why it is residue and not a
silent wrong answer.

**R2b. `classTdGroupBaseOrdering` — `buildClassTypedefTs` reached BEFORE the
packages. DIRECTION: DEFER. Depth: shallow. RANK 2b (bundle with R2).**
`classTdGroupBase50` is published by `emitPackage`, but
`src/TypeEmit.cpp:795`'s ON-DEMAND `buildClassTypedefTs` call (the forward
class-nested-typedef path) can run earlier, in which case the map is empty and
law 4 adds nothing. That is a MISSED case, never a wrong one, and it did not fire
in any of the four UVM tests (their heads all moved). The fix is a
`pendingClassTdAlias50` fixup drained after both package views, exactly like
`pendingAliasChainTgt` at `src/UhdmExporter.cpp:3941`.

**R3. `containerPrefixJoiner` — alias-ref `vpiFullName` = container prefix +
kind-dependent joiner + package-qualified name. DIRECTION: REPLACE. Depth:
shallow per site, THREE sites. RANK 3, and it is NOT convertible work** —
`BaseClass::Compare` never reads `VpiFullName`, so this is DUMP_MATCH only. Sites:
`src/ParamEmit.cpp:19147` (`prefix + prefix + …`, right only for a package
container) and my new `art50->VpiFullName(cts50->VpiName())` at `src/ParamEmit.cpp:19217`, plus law 4's `clsName + "::" + name` (which happens to match golden
for BuildUVMPkg). Joiners: `package` → none, `module_inst` → `.`, `class_defn` →
`::` (pass-49 §5, 3 of the 7 rows are the class case). Blocker: at clone-build
time the container is the importing PACKAGE, not the module that lists it, so this
needs a fixup at the module-import listing (`src/ModuleEmit.cpp:4455` (`ets->Typedef_alias()->VpiFullName(scopedName)`) already
re-scopes alias fullnames for other typespec kinds — start there).

**R4. arena ORDER of design-level typespecs. DIRECTION: REORDER. Depth: unknown.
RANK 4.** a7's final dump differs from golden only in the alias fullname and in
the position of two design-level typespecs (`class_typespec (rh50)` and an
`int_typespec`). Not cmp-visible in a7 (`cmp rc=0`). Cheap to characterise from
a7 alone.

## 11. Gates — every one, with the numbers I measured

Binary md5 printed BEFORE and AFTER every sweep; **no rebuild happened while a
sweep was running** (the two build md5s straddling each sweep are identical in
every log).

**The gated binary IS the shipped source.** The line citations in the code
comments were corrected after the last gating build; the rebuild that followed
came out `9dd2bba781f25cd7e0ca3551f5e15715` — **the same md5**, so every gate
below was run on a binary byte-identical to the one this patch produces. `git
stash` was never used (the two entries in `git stash list` belong to other
worktrees and predate this pass), and the patch was verified to apply to a
pristine `git archive 8c14dc7` tree with `git apply --check` (16 files, no error).

| gate | result |
|---|---|
| 1. `cmake --build build -j 3` (my worktree) | rc 0, final md5 `9dd2bba781f25cd7e0ca3551f5e15715` |
| 2. 23 goldens, `SLANG_UHDM` exported to MY build | **PASS 23 / FAIL 0** |
| 2b. negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** — the harness really is using the exported binary |
| 3. uhdm2rtlil, `--mode testflags --jobs 2`, own `--out` | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; `csvdiff.py` vs `results/gate_uhdm2rtlil.csv`: **ROW DIFFS 0** |
| 4. surelog, `--mode both --jobs 2`, own `--out` | `default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL**, `testflags` **463 / 10**; totals 930 CMP_EQUAL / 23 CMP_NOTEQUAL / 570 SLANG_REJECT / 48 SURELOG_FAIL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM; dump **390 match** (225 default + 165 testflags) / 540 differ / 658 blank; `csvdiff.py` vs `results/golden_surelog.csv`: **ROW DIFFS 0**. No `Google,testflags` flake appeared this run (it would have shown as a row diff; there were none). |
| 5. byte verifier, BOTH corpora, same workdir path | see §12 |

Gate 4's histogram is byte-for-byte the brief's stated baseline (467/13 default,
463/10 testflags, dump match 225/165), so the match counts did not fall.

**Canaries, spot-checked INDIVIDUALLY BY NAME** (`canaries.sh`, which prints
ABSENT and counts it when a name matches no row, so a typo cannot read as green):

* surelog corpus, **34 canary rows, `changed=0 absent=0`**. The two live, fragile
  conversions are intact: `InterfaceModPort` `CMP_EQUAL/differ` both modes,
  `BlackParrotComplex` `CMP_EQUAL/differ` both modes — identical to
  `results/golden_surelog.csv`.
* uhdm2rtlil corpus, **8 canary rows, `changed=0 absent=0`**.
* whole families diffed as blocks: `Black*` **34 rows IDENTICAL**,
  `EvalFunc`+`ParamFile` **18 rows IDENTICAL**.
* the four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) were never dispatched.

## 12. GATE 5 — BYTE VERIFIER, BOTH CORPORA, and EVERY mover explained

**The main-tree binary is NOT a usable 8c14dc7 control in this pass.** At the
start of the pass `/home/heyfey/git-repos/slang-uhdm/build/slang-uhdm` was
`570b867d…` (= my own control build); by gate time the other slot had rebuilt it
to `fd1d6d7cbf3e6ba0139768f08a9ef469`. So the HEAD binary was rebuilt HERE from
`git checkout 8c14dc7 -- src/ParamEmit.cpp src/TypeEmit.cpp src/UhdmExporter.cpp
include/UhdmExporter.h`, which reproduced **`570b867dc631e11b728ee1b058e29fa8`
exactly** — the same md5 as my first control build and as the pass-49 verifier's
133f5ee build. My edits were copied aside and copied back (**never `git stash`**),
and `git diff 8c14dc7` after the restore is **byte-identical** to the patch
generated before it.

This pass runs the verifier BACKWARDS: the POST manifests were taken from the
gate-3/gate-4 sweeps that already existed, then the HEAD binary was run into the
**SAME workdir paths** and its manifests taken. Same comparison, two fewer full
sweeps. The HEAD halves reproduced the committed baselines exactly (surelog
467/13 + 463/10, u2r 679/50/2), which independently validates them as controls.

| corpus | databases paired | identical | DIFFER |
|---|---|---|---|
| uhdm2rtlil (`testflags`) | 679 | **679** | **0** |
| surelog (`both`) | 953 | 936 | **17** |

The 17: `default/Scoreboard` (**NOT EVIDENCE** — pass 41 measured Scoreboard's
`default` database as nondeterministic on EVERY binary; the recorded macro-buffer
`SourceLocation` flake) plus **16 = 8 tests × 2 modes**. Four of the eight are the
targets. The other four are all law 2 (`classPropNoStampShared50`) and each is
explained below with the object that moved, measured with `explainmover.sh`
(HEAD-vs-POST dump diff, content ± = raw `grep -c '^[-+]'` minus the 2 `diff -u`
header lines) and checked against golden:

| test | content ± | the object that moved | HEAD parent | POST parent | golden | verdict |
|---|---|---|---|---|---|---|
| `ClassParamAsParam` | 4 | `class_typespec (rsrc_t) 9:10-9:18` | `class_var (work@resource_db::rsrc)` | `class_defn (work@resource_db)` | `class_defn (work@resource_db)` | **IMPROVEMENT — now exact** |
| `ClassTypeParam` | 4 | `class_typespec (rsrc_t) 9:10-9:22` | `class_var (work@uvm_resource_db::rsrc)` | `class_defn (work@uvm_resource_db)` | `class_defn (work@uvm_resource_db)` | **IMPROVEMENT — now exact** |
| `SimpleConstraint` | 4 | `enum_typespec (pkt_type) 2:1` | `enum_var (…frame_t::ptype)` | `design (unnamed)` | `design (unnamed)` | **IMPROVEMENT** (golden's SPAN still differs — separate pre-existing residue) |
| `SVSwitch` | 6 | `enum_typespec (fcs_kind_t) 13:1` and `(length_kind_t) 14:1` | `enum_var (work@packet::fcs_kind)` / `(…length_kind)` | `design (work@top)` (both) | `design (work@top)` | **IMPROVEMENT — now exact, 2 objects** |
| `ApbSlave` | 4 | `enum_typespec (svunit_pkg::boolean_t) 36:3` | `enum_var (svunit_pkg::svunit_base::success)` | `module_inst work@apb_slave_unit_test` | `package svunit_pkg` | **NEUTRAL** — both sides differ from golden; suppressing the class-property stamp lets a PRE-EXISTING module-listing stamp win instead. Residue R5. |

`ApbSlave`, `ClassParamAsParam`, `ClassTypeParam` and `SimpleConstraint` are
`CMP_EQUAL` before AND after (their `cmp rc=0` was re-measured on the post binary,
`corpdump.sh`), `SVSwitch` is `CMP_NOTEQUAL` before and after with its head
unchanged, and all ten rows are byte-identical to the committed baseline in the
CSV (`ROW DIFFS 0`).

**R5. `sharedTdParentLastWriter` — which container may stamp a shared typedef
object's `vpiParent`. DIRECTION: RESTRICT. Depth: medium. RANK 5.** `ApbSlave`
shows that suppressing the class-property stamp (law 2) is necessary but not
sufficient: golden parents the shared object at its HOME PACKAGE, while a MODULE
import listing still stamps it on our side. The same § sharedAliasNoStamp41 audit
that law 2 did for `pendingClassPropTs` has to be repeated for the module-listing
stamp. This is dump-only (`ApbSlave` is `CMP_EQUAL` both ways).

`results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv` were **read only,
never rebuilt, edited or included**. Their row counts come from the parsed dict
(731 and 1588), never from `wc -l` (732 and 1589 with the header).

## 13. The canary NAME LIST that `canaries.sh` covers

Every name the brief asked for: `InterfaceModPort`, `BlackParrotComplex`,
`InterfaceBinding`, `InterfaceModExp`, `BindHierPath`, `EnumConcat`, `LowMemPkg`
(`default` only — `testflags` is `SURELOG_FAIL` at baseline and the driver reports
that row too), `paramod_genscope_child`, `issue326_packed_mem`,
`assignment-pattern`, `hier_path`, `MultirangesStartNotFromZero`,
`genscope_cells`, `genvar_loop_decl_3`, `ClassExtends`, `FuncStruct`,
`FuncStructVal`, `FuncIoTypespec`, `Scr1SvTests`, `BasicOh`, `Earlgrey_0_1`,
`YosysOldOr`, `YosysBigSimReed`, `YosysOldOpen`, plus the `EvalFunc`/`ParamFile`
families and the `Black*` family diffed as whole blocks (§11). Results in §11: 34
+ 8 canary rows, `changed=0 absent=0`, and the two block diffs empty.
`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` were never
dispatched.


## Corrections and additions applied at integration by the master

Each was re-measured before applying; where the verifier's own correction was also
wrong, the truth is recorded instead of either figure.

1. **R3 has THREE wrong sites, not two — a REFUTED claim.** The write-up said law
   4's `clsName + "::" + name` "happens to match golden for BuildUVMPkg". It does
   not: ours is `vpiFullName:uvm_pool::this_type`, golden is
   `vpiFullName:uvm_pkg::uvm_pool::this_type`. The container-prefix rule applies
   there too.
2. **Occurrence count 18 -> 14** (corrected in place above). Golden 16, POST 15 —
   NOT converged, one golden reference still unmatched.
3. **UVM-version mix-ups corrected in place** (BuildUVMPkg is 1800.2-2017-1.0; the
   other three are uvm-1.2). Mixing the two versions' line numbers is a recurring
   error in this cluster's write-ups.
4. **Byte-verifier accounting.** "17 = Scoreboard (NOT EVIDENCE) + 8 tests x 2
   modes, four of the eight are targets" is wrong twice over. Scoreboard **IS**
   target #4 and its database is an EXPECTED mover (head md5 `8b6c8091` ->
   `aff2b034`); only three of the eight are non-Scoreboard targets. The correct
   split is **7 TARGET ROWS + 10 COLLATERAL ROWS**. `bvcompare.sh`'s
   `[NOT EVIDENCE]` label is misleading for Scoreboard and should read "TARGET,
   and also known-nondeterministic — usable as neither clean evidence nor a clean
   pass".
5. **THE +2 CONTENT-LINE BIAS — a SYSTEMATIC instrument defect, now FIXED in code.**
   `gold.sh`, `corpdump.sh` and `explainmover.sh` compared dumps whose FIRST LINE
   is the DATABASE PATH, which always differs, so it contributes one `-` and one
   `+`. Reporting `grep -c '^[-+]'` minus 2 (subtracting only the `---`/`+++`
   headers) therefore over-counted content by EXACTLY 2. The master verified it on
   a real arm: raw 48, raw-2 = 46, TRUE content = 44. All four affected drivers
   (including `r10uvm49repro/gold.sh`) now pipe both dumps through `sed '1d'`, the
   same thing `tests/check_goldens.sh:13` already does; re-running a1 with the
   fixed driver drops its dump line counts by exactly 1 each, confirming it.
   **Every pre-fix "content +/-N" figure in this campaign is N-2**, including
   pass-49's residue table and r10oth2's R8. The same bias rides in
   `grep -cE '^[-+][^-+]'`, since the path lines match that pattern too.
6. **Line citations.** `topView && pkgImportedByPkg.count(&pkg)` is **17673**
   (write-up said 17679; the `continue` is 17688), the class-handle clone gate
   `cl8->UhdmType() == uhdmclass_typespec` is **17378** (said 17356; its NOTE is
   17357-17377), and `pkgImportClassTd50.push_back` at **17413** is exact — all
   confirmed by me with grep. The `isSharedAliasTs` figure is tree-dependent, see
   above. The removed-instrumentation trace tags (`share17604`, `share17672`) read
   like citations and disagree with each other and with the site — their numbers
   are dropped.
7. **Stale headers**: `heads.sh` and `uvm4both.sh` still name `r10uvm49`, and
   `uvm4both.sh` uses `--jobs 4` where the campaign standard is 2 while sibling
   worktrees are live.
8. **Pass-49 leftover**: `r10uvm49repro/README.verifier.md` calls a1 "a 38-line
   file"; `wc -l` says **29**.

### R6 — NEW RESIDUE the pass did not record (found by the verifier, DIRECTION RESTRICT)
`classTdGroupBase50` is **last-writer-wins across `emitPackage` calls with two
publishers storing DIFFERENT objects for the same generic-class key** — the
defining package's own listing object versus an IMPORTING package's clone. In the
transitive case the clone wins, so SeqDriver's `uvm_callbacks::this_type` now
carries `vpiInstance: package adpcm_pkg` where golden has `package uvm_pkg`. Span,
parent and alias target are all EXACTLY golden. At 8c14dc7 the object had NO
`vpiInstance` at all, so this is not a regression in any measured metric
(dump-only, cmp-blind, whole-dump distance still fell) — but it is a WRONG value
where there was previously an ABSENT one, which is a different thing from progress.
Suggested name `classTdGroupBaseIsDefiningPkg`: publish only if absent, or prefer
the `pkgClassTd9` object over an import clone.
