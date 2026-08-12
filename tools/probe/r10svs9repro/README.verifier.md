# r10svs9 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PASS.** Every number in the implementer's report reproduces on a
binary I built myself from a FRESH 595c2e3 worktree, and the two binaries I
built are **BYTE-IDENTICAL** to the ones they reported. The conversion claim is
honest (SVSwitch did **not** convert; I re-ran both modes and quote the rows
below). I found **no defect** — four documentation-precision findings (F1–F4),
none of which change behaviour, and **six new favourable results** (N1–N6) from
arms the implementer did not run, one of which materially **bounds the law's
blast radius** in a way their write-up does not claim.

Worktrees: `r10svs9v` (patched), `r10svs9vpris` (pristine control), both created
detached/fresh at 595c2e3 by me. Patch `/tmp/r10svs9.patch`, md5
**`a8351421583453e2aa744be64e39dcb5`** — matches the delivered md5.
`git apply --check` clean on a fresh 595c2e3 **and** on main HEAD `2c7f693`.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours, in every table here.

---

## 1. THE CONVERSION CLAIM — RE-RUN, NOT TAKEN ON TRUST

**I am in the UNCONVERTED world.** `svsgen.sh` drives the harness itself
(`verify_golden.py --corpus surelog --mode both --filter '^SVSwitch$'`) on my
own patched binary:

```
SLANG=/…/r10svs9v/build/slang-uhdm  md5=839408ac5c4c225717bd721cc3042ec3
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

**Dump column value: EMPTY (blank) in both rows** — the row ends `decompile:,,`
with nothing after the last comma. Both rows are **byte-identical** to the
committed authoritative baseline `results/golden_surelog.csv:1304-1305`, which I
read (never wrote):

```
results/golden_surelog.csv:1304:SVSwitch,default,CMP_NOTEQUAL,decompile:,,
results/golden_surelog.csv:1305:SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

SVSwitch instruments, my measurement, pristine → patched:

| instrument | pristine `6ebf930f` | patched `839408ac` | reported |
| --- | --- | --- | --- |
| row, both modes | CMP_NOTEQUAL | CMP_NOTEQUAL | ✓ not a conversion |
| cmp HEAD DEPTH (a SUBTREE, not a distance) | 48 | 17 | ✓ |
| cmp heads (`grep -c ^LHS:`) | 1 | 1 | ✓ ONE head |
| dump content `+/-` | 1934 | 1918 | ✓ |
| `o.dump` lines (golden 25318) | 25708 | 25698 | ✓ |
| both modes identical | yes | yes | ✓ |

**The brief's head is CLEARED.** Pristine head is exactly the brief's target;
patched head is a different cluster (the R1 successor):

```
PRISTINE head            LHS ref_obj: (work@Environment::reset::input_intf) 63:16-63:32
                             |vpiName:input_intf
                             |vpiFullName:work@Environment::reset::input_intf
                         RHS hier_path: (input_intf.clock) 63:16-63:32
PATCHED head             LHS ref_typespec: (work@testcase.env)
                             \_logic_net: (work@testcase.env) 20:13-20:16
                             \_class_typespec: (Environment) 20:1-20:12
                         RHS <null>
```

**The brief's paraphrase is REFUTED, and I confirm the implementer's refutation
from the raw dump**: golden's `vpiName` is **`input_intf`** — the handle ALONE,
not the whole dotted text — only the SPAN is whole, and in a class the object
carries **no `vpiActual`** (there is no such field under it). Coding from the
brief's paraphrase would have moved nothing.

---

## 2. THE FIVE GATES, INDEPENDENTLY

### GATE 1 — BUILD
Configured and built both worktrees myself (`cmake --build build -j 8`), waited
for the link line in each (`[100%] Linking CXX executable slang-uhdm` →
`[100%] Built target slang_uhdm`), `grep -ciE "error:"` = 0 on both logs.

```
839408ac5c4c225717bd721cc3042ec3  r10svs9v/build/slang-uhdm       (patched)
6ebf930f2b58e9b70373d9b9282db381  r10svs9vpris/build/slang-uhdm   (pristine)
```

**Both md5s are 32-hex and BYTE-IDENTICAL to the implementer's reported
binaries** — I md5'd theirs too and they match mine exactly. BASE printed and
grep-checked for each: both `595c2e33df0cf1fecd10ef350092fc3f204df131`; the
pristine worktree's `git status --porcelain` is EMPTY. Law-string control:
`strings | grep -c parensLessEventPathBase9` = **1** patched, **0** pristine.

### GATE 2 — GOLDENS
`SLANG_UHDM=<patched> ./tests/check_goldens.sh | grep -c '^PASS'` → **23**,
`grep '^FAIL'` → none. Negative control `SLANG_UHDM=/bin/false` → **0**.

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`
```
CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
dump histogram   496 match   183 differ   52 (blank)
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 row-sides)
PRISTINE control: 0 differing ROWS
```

### GATE 4 — surelog, BOTH modes, `--jobs 2` — **UNCONVERTED expectation**
```
[default]   CMP_EQUAL 467   CMP_NOTEQUAL 13   DEFERRED 5  SLANG_REJECT 284  SURELOG_FAIL 25
[testflags] CMP_EQUAL 463   CMP_NOTEQUAL 10   DEFERRED 5  SLANG_REJECT 286  SURELOG_FAIL 23
                            (+ NO_DATABASE 3, NO_UHDM 1, TIMEOUT 1, UNTRANSLATABLE 2)
ALL FOUR histograms (status × 2 modes, dump × 2 modes) IDENTICAL to baseline
WHOLE-ROW diff vs results/golden_surelog.csv: 0 differing ROWS (0 row-sides)
PRISTINE control: 0 differing ROWS
```
`467/13 + 463/10`, histograms unchanged, **0 rows** — the UNCONVERTED
expectation, met exactly. The whole-corpus row identity is itself independent
proof that SVSwitch did not convert and that nothing else moved either.

### GATE 5 — BYTE VERIFIER, both corpora, `SELFCHECK=1 SELFCHECK1=1`
```
uhdm2rtlil : PATH_SETS_IDENTICAL (679)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged   SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953)   MOVERS: 9 / 953
             SELFCHECK 952/953 flagged   SELFCHECK1 = 10  (9 real + 1 corrupted)
```
Both negative controls fire on both corpora. The **9 movers are exactly the 9
reported files**: `SVSwitch` ×2, `BuildUVMPkg` ×2, `SeqDriver` ×2, `SimpleUVM`
×2, `Scoreboard/default` ×1. `Scoreboard/testflags` is SLANG_REJECT (no
database) — which is why the count is 9 and not 10, confirmed in the CSV.

**Per-shape, by MULTISET, ADDED and REMOVED separately.** Every mover is ONE law
shape, and I checked every ADDED shape's count against **golden**:

```
SVSwitch (the target)                                    golden  pristine  shipped
  ADDED    ref_obj (work@Environment::reset::input_intf) 63:16-63:32   1    0    1
  REMOVED  hier_path (input_intf.clock)                  63:16-63:32   0    3    0
  REMOVED  ref_obj (input_intf)                          63:16-63:26   0    1    0
  REMOVED  ref_obj (work@…::clock)                       63:27-63:32   0    1    0

SimpleUVM / SeqDriver / BuildUVMPkg / Scoreboard (one UVM-library line)
  ADDED    ref_obj (uvm_pkg::uvm_config_db::wait_modified::waiter)     1    0    1
  REMOVED  hier_path (waiter.trigger) + its two elements               0   3/1/1 0
```

**Every ADDED shape: golden 1 / pristine 0 / shipped 1. Every REMOVED shape:
golden 0.** That is the strongest form of the claim — we now emit exactly what
golden has and no longer emit what golden lacks. Multiset distance to golden
**improved in every mover**: SVSwitch 1384→1368, BuildUVMPkg 81273→81261,
SeqDriver 367784→367776, SimpleUVM 144580→144572. All are −10 dump lines.

I verified the UVM citation: the line is `@waiter.trigger;` at
`Surelog/third_party/UVM/1800.2-2017-1.0/src/base/uvm_config_db.svh:289`, as
stated (the dump's `line:294` is the post-preprocessing numbering).

**The Scoreboard/default MULTI-STABLE flake, EXECUTED not cited.** 3 fresh reps
through the harness:
```
rep1 size=11133375 md5=8e7bc11d047e
rep2 size=11133375 md5=6f1d12360102
rep3 size=11133375 md5=a45b2431aaa1     pristine size=11133612
```
**Three different md5s, ONE size** — the hash is worthless there, exactly as the
implementer said, and the attribution rests on size + content. Content check:
the per-shape diff of that database against pristine is the **same single law
shape** and nothing else.

### CANARIES
```
u2r     canaries.sh  ok=8  changed=0 absent=0     ctcan2 EXPECT_UNKNOWN=6  ok=1  PASS
surelog canaries.sh  ok=52 changed=0 absent=0     ctcan2 EXPECT_UNKNOWN=1  ok=58 PASS
canaudit audited=29  UNCOVERED=0  FENCE-BREACH=0
InterfaceModPort   default/testflags  CMP_EQUAL/differ   (BY NAME)
BlackParrotComplex default/testflags  CMP_EQUAL/differ   (BY NAME)
```
No dispatch of UnsignedParam / HierPathEval / FileLocalParam / TopParam (canaudit
asserts no driver mentions them: all four "not dispatched by any driver (OK)").

---

## 3. COLLISIONS — RE-RUN, NOT REASONED ABOUT

**§ vifClockingPathComponent5 (r10svs5) — NO COLLISION.** I re-ran **all ten** of
its arms (`a1_kinds a2_handles a3_vifshape a4_base a5_guards v1_direction
v2_spelling v3_handle v4_site2 v5_nested`) on BOTH binaries. Every arm is
**byte-identical** pristine vs patched — same cmp verdict, same head count, same
head depth, same dump-content figure:

```
a1_kinds     CMP_FAIL heads=1 lines=388 content=24     IDENTICAL
a2_handles   CMP_FAIL heads=1 lines=552 content=140    IDENTICAL
a3_vifshape  CMP_FAIL heads=1 lines=110 content=82     IDENTICAL
a4_base      CMP_FAIL heads=1 lines=90  content=387    IDENTICAL
a5_guards    CMP_FAIL heads=1 lines=74  content=35     IDENTICAL
v1_direction CMP_FAIL heads=1 lines=13  content=27     IDENTICAL
v2_spelling  CMP_FAIL heads=1 lines=74  content=292    IDENTICAL
v3_handle    CMP_FAIL heads=1 lines=74  content=388    IDENTICAL
v4_site2     CMP_FAIL heads=1 lines=132 content=81     IDENTICAL
v5_nested    CMP_FAIL heads=1 lines=120 content=250    IDENTICAL
```
The brief's decode question is settled from the source, and I re-read it:
`Surelog/third_party/tests/SVSwitch/interface.sv` declares
`interface input_interface(input bit clock)` with `clocking cb@(posedge clock)`
and `modport IP(clocking cb, output reset, input clock)`. **`.clock` is a PLAIN
SIGNAL** (the interface's own input port, re-exposed by the modport); the
clocking block is `cb`. The implementer's decode is correct and the brief's
collision warning is **refuted**.

**§ covergroupBuiltinCall8 / § covergroupNewCall7 — NO COLLISION.** All nine
r10svs8 arms (`a1_witness a2_args a3_builtins a4_context a5_escaped a6_escinlaw
v1_product v2_pkg v3_refargs`) re-run on both binaries: **byte-identical**,
including the three that PASS_CMP (a2, a3, a4, v3 — heads=0) which would be the
first to break.

**The naming-context-dependent DEAD-END.** The law does **not** uniformly rewrite
dotted base-ref names: it is gated to one grammar production (see N1), and every
non-event-control read of the same path is untouched. Goldens 23/23 and both
whole-row gates at 0 differing rows are the executable protection. See F2 on
`RefPkgParamInEnum`.

**Live passes.** `r10earl33` is landed in main HEAD `2c7f693` and touches only
`src/ExprEmit.cpp` (`git diff --stat 595c2e3..2c7f693` over the four emitter
files); this patch touches only `src/StmtEmit.cpp` + `include/UhdmExporter.h`.
**`git apply --check /tmp/r10svs9.patch` is clean on `2c7f693`**, so the merge
is textually free. `r10uvm62` is still live; its footprint is not assessable
here, but this law's footprint is two files and one function
(`emitEventExpr`'s `EdgeKind::None` arm), which is the minimum surface for a
collision to be checked against.

---

## 4. PATCH HYGIENE

`git apply --stat`: 23 files, **2100 insertions, 0 deletions** — production is
`include/UhdmExporter.h` (+17) and `src/StmtEmit.cpp` (+113); everything else is
`tools/probe/r10svs9repro/`. **No `results/*.csv` touched**, no other production
file touched, nothing outside the two allowed paths. One predicate
(`UhdmExporter::parensLessEventPathBase9`), **one call site** — I grepped: the
`§ parensLessEventPathBaseRef9` tag appears in exactly the declaration, the
definition and the sole call site. The emitted object uses
`setLoc(r9, sec.expr.sourceRange)` — **the same range the hier_path it replaces
already carried**, so the law provably never moves a span; I confirmed this
directly in the escaped-identifier arm, where our span disagrees with golden by
**exactly the same 4 columns** before and after the change.

---

## 5. EMPTY PRODUCT CELLS — MY OWN ARMS

A dotted-name rewrite is this campaign's highest-risk law family, so I built four
arms of my own rather than re-reading the implementer's grid. They live at
`tools/probe/r10svs9repro/v1_ctxclock.sv`, `v2_prefix.sv`, `v3_esc.sv`,
`v4_more.sv` in the `r10svs9v` worktree.

### N1 — THE BLAST RADIUS IS BOUNDED BY THE GRAMMAR (the implementer does not claim this)

`emitEventExpr` has **SEVEN** call sites, not one: `StmtEmit.cpp:937` (the
statement/always event control — the only one the implementer's grid measures),
`ModuleEmit.cpp:1402, 21029, 21034, 21162, 21244, 21396`, and
`ExprEmit.cpp:16574, 16583, 16752`. The predicate reads only the `TimingControl`,
so it fires at **all** of them. That is the obvious way this law could reach
un-measured ground, so I tested every other context **in isolation** (one tiny
file each, so no cascading parse error can mask a result):

| context | call site | Surelog |
| --- | --- | --- |
| `clocking cb2 @ u_if.clock;` | 21162 / 21244 | **SYNTAX ERROR** (4) |
| `clocking cb2 @ u_if.clock;` (empty body) | 21162 / 21244 | **SYNTAX ERROR** (2) |
| `property p1; @ u_if.clock …; endproperty` | 21029 / 21034 | **SYNTAX ERROR** (2) |
| `assert property (@ u_if.clock …)` inline | 21029 | **SYNTAX ERROR** (1) |
| `covergroup cg @ u_if.clock;` | covergroup path | **SYNTAX ERROR** (3) |
| `$rose(x, @ u_if.clock)` | ExprEmit 16752 | **SYNTAX ERROR** (4) |

**Controls, same scaffolding, to prove the rejection is the parens-less DOTTED
form and not my file:** `clocking cb2 @(u_if.clock);`, `property p1; @(u_if.clock)
…`, `covergroup cg @(u_if.clock);` and `clocking cb2 @ lc;` (undotted) **all
parse with 0 syntax errors and produce a UHDM database.**

So the parens-less dotted event is admissible **only** in the procedural
event-control production — the one context the grid measures. In any design
Surelog can also parse, the other six call sites can never carry this shape.
That bounds the law's blast radius by the grammar itself, and it is a stronger
safety statement than "the arms are green".

### N2 — THE FULLNAME FAMILY (arm `v2_prefix.sv`), 5 cells the grid never reaches

The law mints `vpiFullName` as `joinRef(prefix, base)`, and every grid cell has
the base declared directly in the scope whose prefix is in flight. These do not:

| cell | base | golden fullname | patched |
| --- | --- | --- | --- |
| m1 | package var via **wildcard import** | `work@top.pst` | **exact**, R2 only |
| m2 | **interface PORT** of a module | `work@sub.p` | **exact**, R2 only |
| m3 | inside a **named generate block** | `work@top.g.gst` | **EQ** |
| m4 | **static class property**, static method | `work@top::C::t::sst` | **EQ** |
| m5 | declared **inside the interface** | `work@in_if.ist` | **exact**, R2 only |

`ecread.py`: **EQ 4 → 6, DIFF 5 → 3, not one cell worse.** m1 is the cell I
expected to break the law — I predicted golden would name a wildcard-imported
package variable `work@pk::pst`. **My own hypothesis is REFUTED**: golden
localizes it to `work@top.pst`, and the law happens to be right.

### N3 — THE REST OF THE PRODUCT (arm `v4_more.sv`), 7 more cells

| cell | shape | golden | patched |
| --- | --- | --- | --- |
| n1 | `always_ff @ u_if.clock` | `ref_obj(u_if\|work@top.u_if)` | exact, R2 only |
| n3 | **base is a GENERATE BLOCK NAME**: `@ g.gst` | `ref_obj(g\|work@top.g)` | exact, R2 only |
| n4 | 3 components from a genblock: `@ g.gst.f` | `ref_obj(g\|work@top.g)@45:14-45:21` | exact, R2 only |
| n5 | inside an **unnamed** begin/end | `work@top.st` | exact, R2 only |
| n7 | inside **fork/join** | `work@top.st` | exact, R2 only |
| n8 | inside a **NAMED nested block** `nb` | `work@top.nb.st` | exact, R2 only |
| n6 | **program** scope | `ref_obj(pst\|work@pgm.pst)` | **EQ** |

`ecread.py`: **EQ 3 → 4, not one cell worse.** n3/n4 matter: the collapsed
ref_obj is named for a **SCOPE** rather than a variable and golden agrees. n8
was my second-highest suspicion (a named block inserts itself into the prefix)
and the law lands on `work@top.nb.st` exactly.

Two cells could not be measured and are recorded rather than smoothed over:
`always_latch @ u_if.clock` (slang: "statements that pass time are not allowed in
this context") and `@ \this .clock` (slang binds escaped `\this` as the `this`
KEYWORD: "no member named 'clock' in 'C'").

### N4 — THE ESCAPED-IDENTIFIER HAZARD (arm `v3_esc.sv`)

The standing ops rule says a dotted-name law is exactly where an escaped
identifier containing a dot bites. It does, and the token-based reading answers
it — including a spelling the implementer did not test:

```
e1  @ \esc.h .clock    golden ref_obj(esc.h | work@C::e1::esc.h) @30:18-30:35
                       ours   ref_obj(esc.h | work@C::e1::esc.h) @30:18-30:31
e4  @ \a::b .clock     golden ref_obj(a::b  | work@C::e4::a::b)  @34:18-34:34
                       ours   ref_obj(a::b  | work@C::e4::a::b)  @34:18-34:30
```

**Kind, name and fullname converge on golden in both.** e4 is the new one: an
escaped base whose **text contains `::`**. Clause (3) rejects a `::` separator —
but it reads the **syntax token**, and `\a::b` is ONE identifier token, so the
law correctly does **not** decline, and **golden collapses it too**. A
text-scanning implementation would have wrongly declined here and wrongly split
`\esc.h` there. The residual in both is the span, short by exactly 4 columns —
and the **parenthesized twins show the same 4-column gap on both binaries**
(e1p: ours `31:19-31:32` vs golden `31:19-31:36`), which proves it is the
pre-existing escaped-identifier span defect (R3), symmetric and untouched.

### N5 — R2 IS BROADER THAN "MODULE-SCOPE"

The implementer calls R2 "module-scope `vpiActual`". My arms show the real rule:
golden's collapsed ref_obj binds a `vpiActual` in **every design-component
scope** — module, `always_ff`, interface interior, interface port, generate
block, named block, unnamed block, fork/join, package-imported base — and binds
**none** in a **class** (the witness) or a **program** (n6), which is why those
two go fully EQ. Restating R2 that way is what tells a future pass where the
missing field has to come from.

### N6 — NO UNDER-FIRE: THE CENSUS RECONCILED TO THE MOVERS

I ran the implementer's `census.sh` myself: **84 hits** (0 + 28 + 56 + 0 across
the four roots) against **9 movers**. Reconciled, every one:

* the 12 `reed_solomon_decoder` hits are **false positives** — the email address
  `semiconductors@varkongroup.com` in a comment header (the census documents
  that it over-collects);
* the genuine non-mover hits are in tests with **no database**: `UVMSwitch`
  (`Driver.sv:67 repeat (4) @ input_intf.clock;`) and `OVMSwitch` (same line) are
  **SLANG_REJECT**, `Monitor` (`design.sv:32 @_if.cb;`) is **SLANG_REJECT**;
* the `vmm-1.1.1a` bulk is not compiled by any corpus test, and GATE 5 covers all
  953 databases, so anything it reached would have shown as a mover.

So the law fires everywhere it can and nowhere it should not. The implementer
recorded their census's UVM-root omission honestly but did not reconcile the
hits to the movers; this closes it.

---

## 6. FINDINGS

**F1 — clause (2) of the predicate is UNREACHABLE dead code, and the grid's
"executed by" cell for it is vacuous.** The call site sits inside the
`case EdgeKind::None:` arm, and the `sec.iffCondition && sec.edge == EdgeKind::None`
case returns earlier in the same function (StmtEmit.cpp, the `outer9` iff
wrapper). So at the call site `sec.edge` is *always* `None` and `sec.iffCondition`
is *always* null: `if (sec.edge != EdgeKind::None || sec.iffCondition) return nullptr;`
can never be taken. The README's table says it is "executed by a1 c7
`@(posedge vif.clock)`", but a1 c7 fails clause (1) first — which the README
itself parenthetically admits. Under the standing law "every cited guard
EXECUTED", that row is executed by **nothing**. I also confirmed the guarded
spelling is unspellable at all: `always @ u_if.clock iff en` is a **Surelog
syntax error (2)** *and* a slang error ("expected statement"). **Impact: none on
behaviour** — it is a defensive assertion, the implementer labels it "an
ASSERTION, not a filter", and I would leave the code alone. The grid table
overstates by one row.

**F2 — `RefPkgParamInEnum`, the brief's named dead-end protection, is not
executable at this base.** It appears in **neither** corpus CSV
(`/tmp/v9_sur_patched.csv`, `/tmp/v9_u2r_patched.csv`), is **not** among the 23
goldens (`tests/golden/` — I listed all 23), and `grep -rl` finds it in neither
corpus tree. The dead-end protection that actually ran is: goldens **23/23**,
both whole-row gates at **0 differing rows**, and the 52 + 58 canary rows. Worth
correcting in the standing brief so a future pass does not cite a guard that
cannot fire.

**F3 — the `golden-only +1` in three UVM movers is an indentation artefact, not a
lost match.** SimpleUVM's golden-only instance count goes 93120 → 93121 (SeqDriver
265475 → 265476) while ours-only drops by 9. It reads like we un-matched a golden
line. It is not: `msmovers.sh` keys on the **whole dump line including leading
indentation**, so the same `|vpiName:waiter` at two different depths is two keys
(visible in the output, which lists `|vpiName:waiter` as both ADDED and REMOVED —
impossible for one key). Net multiset distance **improves** in all four. No
action; recorded so the next reader does not re-derive it as a regression.

**F4 — the implementer's a2 arm is honestly reported as EQ 8 → 8, and I confirm
it.** The five R2 cells go from the **wrong object kind** (a 2-element hier_path
where golden has a ref_obj) to right kind + right name + right fullname + right
span, differing only by golden's extra `vpiActual`. Strictly closer, still not
EQ. My own arms reproduce exactly this pattern in eight more cells. No cell in
any arm, theirs or mine, got worse.

---

## 7. RANKED RESIDUES

**R1 — the successor head (the SVSwitch blocker), localization VERIFIED.** I ran
`b5_newassign.sv` myself. A class-typed net at design-component scope loses its
`ref_typespec → class_typespec` on our side **iff it is ASSIGNED**:

```
                          golden ts   ours ts
  r1  never assigned          1          1     <- keeps it
  r2  = new()                 1          0     <- loses it
  r3  = new(7)                1          0     <- loses it
  r4  = r2 (another handle)   1          0     <- loses it
```
SVSwitch's `env` and `spkt` are both assigned (`testcase.sv:26-27`), which is
exactly the patched head. The discriminator is **assignment**, not program scope,
not instantiation, not `extends`/`constraint`. This is a wide law and correctly
was **not** widened into this pass. **Highest value next target.**

**R2 — the missing `vpiActual` on the collapsed ref_obj.** Restated per N5:
golden binds an actual in every design-component scope, none in a class or a
program. Currently zero live carriers (no corpus row depends on it), 13+ arm
cells right in kind/name/fullname/span and short exactly one field.

**R3 — escaped-identifier span**, pre-existing, symmetric across both spellings
and both binaries, 4 columns in both `\esc.h` and `\a::b`. Untouched by this law.

**R4 — `@(pk::pev)` golden span truncation**, pre-existing, declines cleanly.

**R5 — `@ this.a.b`**: the law declines (keyword spine); golden's parenthesized
twin is defective (a bare `constant`), so there is nothing safe to imitate.

**R6 — `@ $root.a.b`**: golden names the element *after* `$root`, which needs a
different base rule than "leftmost identifier".

**R7 (new, mine) — two cells are unmeasurable on our side at all**:
`always_latch @ a.b` and `@ \this .a` are rejected by slang before any emission.
Not defects; recorded so a future pass does not spend a cycle on them.

---

## 8. WHAT I DID NOT DO

I did not re-derive the implementer's 42-cell grid cell-for-cell; I built four
independent arms (28 measured cells) that attack the law from angles their grid
does not cover, on the principle that reproducing their own instrument proves
less than a new one. Where our instruments overlap (the r10svs5 and r10svs8 arm
suites, the census, `b5_newassign`, the SVSwitch pair, all five gates, both
canary scripts, the Scoreboard flake) I re-ran theirs verbatim on my own
binaries and every figure matched.

Sweep workdirs (`/tmp/v9_*`) deleted. My worktrees `r10svs9v` / `r10svs9vpris`
are left in place for the MASTER; `results/*.csv` were read only, never written.
