# r10svs10 — ASSIGNMENT NEVER MATTERED: THE HEADER FORM WAS CARRYING THE WHOLE LAW

**Verdict, up front: SVSwitch DID NOT CONVERT.** Both rows are unchanged from
the committed baseline, so this pass is read in the **UNCONVERTED world** of
GATE 4 and every gate below is judged against the unconverted expectation:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

The brief's target head — the 17 cmp lines identical in both modes — **is
CLEARED**, and `env` now carries byte-for-byte the link golden has:

```
head @2ee7a58 (the brief's target, 17 cmp lines, IDENTICAL in both modes)
  LHS golden  ref_typespec: (work@testcase.env)
              \_logic_net: (work@testcase.env), line:20:13, endln:20:16
              |vpiActual:
              \_class_typespec: (Environment), line:20:1, endln:20:12
  RHS ours    <null>                     — we emitted the logic_net, not its link.

on the shipped binary — CLEARED.  Ours is now, verbatim:
              \_ref_typespec: (work@testcase.env)
                \_logic_net: (work@testcase.env), line:20:13, endln:20:16
                |vpiActual:
                \_class_typespec: (Environment), line:20:1, endln:20:12
```

* **THE PASS REFUTED ITS OWN BRIEF.** The brief's law-shape said our emitter
  "DROPS the ref_typespec exactly when the variable is ASSIGNED". That is a true
  description of *our* behaviour and a false theory of *golden's*: **golden never
  consults assignment at all.** The discriminator is the module HEADER FORM, and
  a rule for it (`namedTypeNet`) was **already in the producer, three lines
  below**. The fix is therefore a **DELETION**, not an addition (§2).
* **ONE LAW, `§ classHandleWriteKeepsTs10`, and it removes a predicate rather
  than adding one.** Net change: **37 insertions, 35 deletions** — 34 of the
  insertions are the comment recording the measurement.
* **GRID: 122 cells across 4 arms.** **EQ 86 → 105, DIFF 36 → 17**, and **not
  one cell regressed** (§3).
* **FIVE GATES GREEN** (§5) under the UNCONVERTED expectation.
* **MOVERS: 4**, not the 5 the byte verifier printed — `Scoreboard/default` is a
  **proven FALSE MOVER** and the proof is a run, not a citation (§5.5.1).
* **EIGHT REFUTATIONS** (§6), three of them against this pass's own brief,
  producer and census.

Base commit `2ee7a58`, branch `auto5h`.
Pristine binary md5 **`875d3cd6218c135a8fcc6da3c4c3cf19`** (worktree
`/tmp/wt_r10svs10pris`, `git rev-parse` = 2ee7a58 and `git status --porcelain`
empty, both checked).
Shipped binary md5 **`0d674d37edf10aa6178b5163e7f9518f`** (worktree
`/tmp/wt_r10svs10`).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script in
this directory.

---

## 1. THE LAW

### § classHandleWriteKeepsTs10

> **ASSIGNING a class handle does not change its def-view typespec.** A
> class-typed net declared at design-component scope (module, program or
> interface) is typed by exactly the same rules as any other net. The ONE rule
> that removes its def-view `vpiTypespec` is the **non-ANSI-header** rule
> (`namedTypeNet`): a net whose type is written as a BARE identifier, with no
> declaration initializer, in a definition whose header is a non-ANSI port list
> or empty parens. Scope kind, top-ness, class kind, and whether the handle is
> ever written are all irrelevant.

### STATED GATE == CODE GATE

The gate in `src/ModuleEmit.cpp` is, in full, after this pass:

```cpp
if (!it.port && !explicitPortNet && !implicitNet &&
    !namedTypeNet && !typeParamArgNet && !hasBareImplicitType(*it.sym)) {
```

There is **no class-handle clause in it**, which is precisely what the law
above says. The clause this pass removed was `!classHandle`, and the 33 lines
that computed `classHandle` went with it.

### What was there before

```cpp
// A class-handle def net carries a typespec ONLY when the handle is
// never procedurally assigned (bar = new() strips it — OneThis vs OneClass).
bool classHandle = <declared type's canonical kind == ClassType>;
if (classHandle) <...if the type name is a ScopedName, classHandle = false...>;
if (classHandle) {
    bool written = false;
    for (auto& mb : body.members()) {
        if (mb.kind != SymbolKind::ProceduralBlock) continue;
        <visit the block, set written when an AssignmentExpression's
         stripped LHS is a NamedValue naming this symbol>
    }
    if (!written) classHandle = false;
}
```

Read as a claim about golden it says: *golden strips an assigned class handle's
def-view typespec*. §3 shows golden does no such thing, in any scope, at any
top-ness, for any class kind.

---

## 2. WHY THIS WAS INVISIBLE, AND WHERE THE REAL RULE ALREADY WAS

The strip cited two goldens, `OneThis` and `OneClass`. Both are `module top`.
`OneClass` declares two class handles and assigns neither; golden keeps their
typespecs. `OneThis` declares two and assigns both with `new()`; golden strips
them. Assignment is the only difference **between those two tests**, so it looks
like the discriminator — and every cell either test can offer is consistent with
it.

But `OneThis`'s module is

```systemverilog
module top(a, o);
input a;
output o;
```

a **NON-ANSI PORT LIST**, and `OneClass`'s is `module top(output [3:0] b);`, an
ANSI one. That is a *second* difference the pair also confounds, and the rule
for it was already sitting three lines below the strip:

```cpp
// In a NON-ANSI-HEADER module ... Surelog fails to resolve a BARE typedef NAME
// while writing the definition's nets, so such a net carries NO def-view
// typespec.  ...and so does any declaration WITH an initializer.
bool namedTypeNet = ...;
```

`foo bar;` in `OneThis` is a bare `IdentifierName` with no initializer in a
non-ANSI-header module. **`namedTypeNet` strips it on its own.** The
class-handle strip was redundant everywhere it was right and wrong everywhere
else, and the way to tell the two apart is to vary assignment WITHIN a fixed
header form — which neither cited golden does and arm `c2_header.sv` does
twelve times.

---

## 3. THE GRID, CELL FOR CELL

Read by `ctsread.py`, which walks the dump's **indent column** and descends only
into fields that are NOT `vpiParent` — necessary because the net being measured
is reprinted inside its own `ref_typespec`'s subtree as a back-pointer, so a
`grep` for `class_typespec` under a net double-counts and a `grep` for
`ref_typespec` finds a sibling's. Cells are keyed by **(declaring scope, name,
source span, object kind)**, span-keyed on BOTH sides.

Cell VALUES: `TS(<class>)@<span>` = `vpiTypespec -> ref_typespec -> vpiActual
class_typespec`; `NONE` = no `vpiTypespec` at all; `TS?(<kind>)` = a chain
ending in something else.

### 3.1 `c1_scopetop.sv` — SCOPE KIND x TOP-NESS (the confound OneThis hides)

Every scope gets an ASSIGNED handle and a NEVER-ASSIGNED control.

```
cell  scope                       assigned?   GOLDEN        PRISTINE   SHIPPED
a1    TOP module (OneThis shape)  new()       TS(K)         NONE       TS(K)   ->EQ
a2    TOP module                  never       TS(K)         TS(K)      TS(K)     EQ
b1    non-top module              new()       TS(K)         NONE       TS(K)   ->EQ
b2    non-top module              never       TS(K)         TS(K)      TS(K)     EQ
c1    non-top program (SVSwitch)  new()       TS(K)         NONE       TS(K)   ->EQ
c2    non-top program            never        TS(K)         TS(K)      TS(K)     EQ
d1    TOP program                 new()       TS(K)         NONE       TS(K)   ->EQ
d2    TOP program                 never       TS(K)         TS(K)      TS(K)     EQ
e1    interface                   new()       TS(K)         TS(K)      TS(K)     EQ
e2    interface                   never       TS(K)         TS(K)      TS(K)     EQ
                                      cells 23   EQ 19 -> 23   DIFF 4 -> 0
```

**Golden's answer is TS(K) in all ten cells.** Scope kind is REFUTED as a
discriminator; top-ness is REFUTED; and `e1` shows the interface path never ran
the strip at all (it emits nets through a different producer), so the interface
cells were already right for the wrong reason.

### 3.2 `c2_header.sv` — HEADER FORM x ASSIGNMENT (the decisive arm)

```
cell  header form                        assigned?  GOLDEN         PRIS   SHIP
f1    module f;            (none)        new()      TS(K)          NONE   TS(K) ->EQ
f2    module f;            (none)        never      TS(K)          TS(K)  TS(K)   EQ
g1    module g();          (empty parens)new()      NONE           NONE   NONE    EQ
g2    module g();          (empty parens)never      NONE           NONE   NONE    EQ
h1    module h(a); input a;(NON-ANSI)    new()      NONE           NONE   NONE    EQ
h2    module h(a); input a;(NON-ANSI)    never      NONE           NONE   NONE    EQ
i1    module i(input logic a); (ANSI)    new()      TS(K)          NONE   TS(K) ->EQ
i2    module i(input logic a); (ANSI)    never      TS(K)          TS(K)  TS(K)   EQ
j1    NON-ANSI, `pk::SK`  (scoped name)  new()      TS(pk::SK)     same   same    EQ
j2    NON-ANSI, `pk::SK`  (scoped name)  never      TS(pk::SK)     same   same    EQ
j3    NON-ANSI, `K_t`     (typedef'd)    new()      NONE           NONE   NONE    EQ
j4    NON-ANSI, `K_t`     (typedef'd)    never      NONE           NONE   NONE    EQ
k1    NON-ANSI, `K k1 = new();`(decl-init)         span-only DIFF, see R4
k2    NON-ANSI                           never      NONE           NONE   NONE    EQ
                                      cells 42   EQ 37 -> 39   DIFF 5 -> 3
```

**`h1` vs `h2` is the whole argument.** In OneThis's own header form golden
answers `NONE` for the ASSIGNED handle *and* for the unassigned one. If
assignment were the discriminator, `h2` would carry a typespec. It does not.
And `i1` vs `i2`: in an ANSI header golden answers `TS(K)` for both. Assignment
moves nothing; the header form moves everything.

`j1/j2` and `j3/j4` also settle the removed ScopedName carve-out: a scoped name
keeps its typespec in a non-ANSI header (golden `TS(pk::SK)`) while a typedef'd
bare name loses it (`NONE`) — exactly `namedTypeNet`'s own distinction, needing
no class-handle clause of its own.

### 3.3 `c3_kinds.sv` — assignment FORMS, class KINDS, declarators, escaped names

All in headerless modules, so `namedTypeNet` never fires and the removed strip
is the only rule under test.

```
axis (a) ASSIGNMENT FORM        GOLDEN            PRIS    SHIP
n1   assigned in `initial`      TS(K)             NONE    TS(K)  ->EQ
n2   assigned in `always`       TS(K)             NONE    TS(K)  ->EQ
n3   assigned in a TASK body    TS(K)             TS(K)   TS(K)    EQ   <- see R5/§6.5
n4   assigned in a FUNCTION body TS(K)            TS(K)   TS(K)    EQ   <- see R5/§6.5
n5   passed as an OUTPUT arg    TS(K)             NONE    TS(K)  ->EQ
n6   assigned from another handle TS(K)           NONE    TS(K)  ->EQ
n7   only READ, never written   TS(K)             TS(K)   TS(K)    EQ
n8   written from another handle TS(K)            NONE    TS(K)  ->EQ
n9   declaration initializer    TS(K)@31:3-31:15  span    span     DIFF (R4)
n10  never mentioned            TS(K)             TS(K)   TS(K)    EQ

axis (c)/(d) CLASS KIND, all ASSIGNED
q1   plain                      TS(K)             NONE    TS(K)  ->EQ
q2   parameterized `P#(2)`      TS(P)@48:3-48:4   NONE    @48:3-48:8  DIFF (R2)
q3   derived `extends K`        TS(D)             NONE    TS(D)  ->EQ
q4   virtual class handle       TS(V)             NONE    TS(V)  ->EQ
q5   INTERFACE class            TS?(unsupported)  NONE    TS(IC)     DIFF (R3)
q6   typedef'd `K_t`            TS(K_t)@18:9      NONE    TS(K_t)->EQ
q7   typedef'd parameterized    TS(P3_t)@19:9-10  NONE    @19:9-19:14 DIFF (R2)
q8   scoped `pq::QK`            TS(pq::QK)        same    same     EQ
q9   implementing class         TS(Impl)          NONE    TS(Impl)->EQ

axis (f) MULTIPLE DECLARATORS   `K r1, r2, r3;`  r1,r2 assigned, r3 not
r1   assigned                   TS(K)@65:3-65:4   NONE    TS(K)  ->EQ
r2   assigned                   TS(K)@65:3-65:4   NONE    TS(K)  ->EQ
r3   NEVER assigned             TS(K)@65:3-65:4   TS(K)   TS(K)    EQ

axis (h) ESCAPED NAMES
\esc.one  assigned              TS(K)             NONE    TS(K)  ->EQ
\esc.two  never                 span-only DIFF, PRE-EXISTING (R5)
                                      cells 57   EQ 30 -> 43   DIFF 27 -> 14
```

`r1/r2/r3` also answers grid item (f) directly: golden gives **all three
declarators of one declaration** the same `class_typespec` at the shared type
span, and the strip had been removing it per-declarator.

### 3.4 `c0_onethis.sv` — the producer's own citation, re-run

A verbatim copy of `uhdm2rtlil/test/OneThis/dut.sv`, the golden the deleted
strip cited.

```
PRISTINE : PASS_CMP  cmp heads=0  DUMP_MATCH
SHIPPED  : PASS_CMP  cmp heads=0  DUMP_MATCH
```

**The citation survives the deletion, unchanged, byte for byte.** Golden's
`work@top.bar` / `work@top.baz` def-view `logic_net`s carry no typespec on
either binary, because `namedTypeNet` strips them — and their elab `class_var`
twins carry `TS(foo)` on both, as golden does.

### 3.5 Totals

```
             cells   EQ pristine -> shipped   DIFF pristine -> shipped
c1              23         19 -> 23                  4 -> 0
c2              42         37 -> 39                  5 -> 3
c3              57         30 -> 43                 27 -> 14
              -----      -----------              ----------
              122         86 -> 105                36 -> 17
```

**Not one cell regressed**: every cell EQ on the pristine binary is EQ on the
shipped one. Every remaining DIFF is ranked in §7, and each is either
pre-existing on both binaries (R4, R5) or a defect the law **made visible** by
creating the object that carries it (R2, R3) — a `class_typespec` cannot have a
wrong span until it exists.

---

## 4. THE PRODUCER

`src/ModuleEmit.cpp`, the def-view net listing in `emitModuleDef`. The gate
decides whether a net gets a `ref_typespec` whose actual is filled in later by
`materializeDefNetTs` (Surelog's write-phase arena order). Deleting a clause
from that gate lets the affected nets take **the identical path** the
never-assigned ones already took — which is why the converged cells land
byte-exact rather than approximately: `a2`, `f2`, `i2`, `r3` were already EQ
through this path before the pass, and the newly admitted cells join them.

**No typespec-retention rule near `§ classPropNoStampShared50` is disturbed.**
That law owns `class_typespec` PARENT policy for **class PROPERTIES**, applied
from the `pendingClassPropTs` queue in `UhdmExporter.cpp` under a
pointer-identity guard (`isSharedAliasTs`). This pass touches neither that queue
nor any `VpiParent` call: the parents of the objects it admits are set by
`materializeDefNetTs` and by the `rt->VpiParent(n)` two lines below the gate,
both untouched. Verified on the dump rather than argued: on a cell that was EQ
before the pass (`c1` d2) and one that converged (`c1` d1), the emitted
`ref_typespec`'s `vpiParent` is the declaring `logic_net` and the
`class_typespec` prints identically to golden's.

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

```
/tmp/wt_r10svs10                    (shipped)
[100%] Linking CXX executable slang-uhdm      <- the link line, waited for
[100%] Built target slang_uhdm
SHIP_RC=0     compiler errors: 0
md5(build/slang-uhdm) = 0d674d37edf10aa6178b5163e7f9518f   (32 hex, asserted separately)

/tmp/wt_r10svs10pris                (pristine, built here, NOT reused)
git rev-parse HEAD  = 2ee7a58e8baa07d589428d4b6239afb5d84f379a
git status --porcelain = <empty>
[100%] Linking CXX executable slang-uhdm
PRIS_RC=0
md5(build/slang-uhdm) = 875d3cd6218c135a8fcc6da3c4c3cf19   (32 hex, asserted separately)
```

**THE BASE MARKER IS BEHAVIOURAL, AND HERE IS WHY.** Every prior pass in this
campaign pinned its binaries with `strings | grep -c <lawName>`, which works
because those passes ADDED a named function. **This pass is a DELETION and adds
no symbol**, so that instrument is unavailable and saying "grep returned 0 on
both" would be a guard that does not guard. The substitute is stronger, because
it tests the law itself rather than a name:

```
SOURCE   grep -c classHandleWriteKeepsTs10 src/ModuleEmit.cpp
           shipped worktree = 1     pristine worktree = 0
BEHAVIOUR arm c1, cell b1 (work@msub.b1, a non-top module's assigned handle)
           shipped  = TS(K)@34:3-34:4          pristine = NONE
```

Both were run on every binary these gates quote.

### GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped> tests/check_goldens.sh   ->  23 PASS / 0 FAIL
SLANG_UHDM=/bin/false tests/check_goldens.sh  ->   0 PASS / 23 FAIL   (control fires)
```

Stated honestly: the 23 goldens contain no design-scope class handle at all, so
they prove this law did not break the unrelated corpus; **they cannot confirm
it.** The instrument that confirms it is §3 and GATE 5.

### GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep, judged the same way:   0 differing ROWS
```

### GATE 4 — surelog `--mode both --jobs 2` (`GOLDEN_DEFER` left UNSET)

**UNCONVERTED WORLD**, and the expectation is met exactly:

```
default   : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
testflags : 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / ...
dump histograms: UNCHANGED in both modes
   default    327 blank / 242 differ / 225 match   (baseline: identical)
   testflags  331 blank / 298 differ / 165 match   (baseline: identical)
WHOLE-ROW diff vs results/golden_surelog.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep: 0 differing ROWS
```

No `results/*.csv` was touched by this pass.

#### 5.4.1 The SVSwitch instruments, reported separately and never conflated

```
                                    PRISTINE      SHIPPED
cmp HEAD DEPTH (NOT a distance)        17          2680
dump content +/-                     1918          1912
MULTISET DISTANCE (resync-immune)    1368          1354
o.dump lines                        25698         25720   (golden 25318)
```

**The head depth went UP and that is not a regression.** Compare dumps the whole
subtree rooted at its first mismatch, so depth is a property of *which object*
mismatches, not of how far apart the databases are. The two instruments that are
distances both IMPROVED. The successor head is the `module_inst: work@top`
listing, and it is **PRE-EXISTING, merely unmasked** — proven, not asserted:

```
diff <(work@top listing, pristine o.dump) <(work@top listing, shipped o.dump)
   -> IDENTICAL
every changed object line in SVSwitch, pristine -> shipped:
   +2 class_typespec   +2 logic_net   +2 ref_typespec   (nothing else)
```

Nothing in `work@top` moved, so nothing this pass did could have created the
head that now sits there.

### GATE 5 — BYTE VERIFIER, both corpora, vs a PRISTINE 2ee7a58 built here

`byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 5 / 953
          SELFCHECK 952/953 flagged        SELFCHECK1 = 6  (= 5 movers + 1 corrupted)

  ./default/SVSwitch      ./testflags/SVSwitch      <- law content
  ./default/SimpleUVM     ./testflags/SimpleUVM     <- law content
  ./default/Scoreboard                              <- FALSE MOVER, see 5.5.1
```

**4 real movers**, all law content and nothing else.

### 5.5 MOVERS PER SHAPE, BY MULTISET

`sed 1d` on every dump; ADDED and REMOVED counted **separately** and never
netted; every ADDED shape checked against **GOLDEN's own count**, which is the
only test that says a mover is a CONVERGENCE.

**SVSwitch** (identical in both modes), OUR side, pristine → shipped. There are
**no REMOVED shapes at all** — this law only adds:

```
                                                          GOLD PRIS SHIP
ADDED +1  \_ref_typespec: (work@testcase.env)                1    0    1
ADDED +1  \_ref_typespec: (work@testcase.spkt)               1    0    1
ADDED +1  \_class_typespec: (Environment), 20:1-20:12        1    0    1   (ref_typespec child depth)
ADDED +1  \_class_typespec: (Environment), 20:1-20:12        2    1    2   (tail depth)
ADDED +1  \_class_typespec: (small_packet), 21:1-21:13       1    0    1
ADDED +1  \_class_typespec: (small_packet), 21:1-21:13       2    1    2
ADDED +1  \_logic_net: (work@testcase.env), 20:13-20:16      1    0    1   (vpiParent reprint)
ADDED +1  \_logic_net: (work@testcase.spkt), 21:14-21:18     1    0    1
ADDED +1  \_class_defn: (work@Environment) ...               3    2    3   (vpiClassDefn reprint)
ADDED +1  \_class_defn: (work@small_packet) ...              3    2    3
```

**Every one of the ten object shapes lands on golden's count EXACTLY**
(shipped == golden on all ten; pristine short by exactly the amount added).
There is no eleventh shape, no relocation and no net-zero pairing.

The bare `|vpiTypespec:` / `|vpiActual:` field lines each gained +2, and at the
indent where the law works golden has them (`|vpiTypespec:` gold 138 / pris 144
/ ship 146 is an *indent bucket*, and `msdist` keeps indentation verbatim so the
same field at another depth is a different key). Across ALL indents we are still
**below** golden on `vpiParent` (3798 golden / 3862 ours) and above it on
`vpiTypespec` (355 / 370) by a **pre-existing** margin of 13 that this pass
moved to 15 by adding the 2 golden also has. Those field lines are the
"NON-ATTRIBUTABLE absorbers" `msmovers.sh` lists and does not count; the object
lines are the evidence.

Distance accounting closes exactly: golden-only line instances 494 → 476
(**−18** = the 10 object lines + 4 name/fullname + 2 `vpiName` + 2
`vpiClassDefn`), ours-only 874 → 878 (**+4** = the 2 `vpiTypespec` + 2
`vpiActual` indent-bucket instances), net **1368 → 1354**.

**SimpleUVM** — a carrier this pass's brief did not name, found by the verifier.
`testbench.sv:47` is `env environment;` in a headerless `module top`, assigned
in the initial block: one site, same law, same shape, identical in both modes:

```
                                                          GOLD PRIS SHIP
ADDED +1  \_ref_typespec: (work@top.environment)             2    1    2
ADDED +1  \_class_typespec: (env), 47:3-47:6                 2    1    2
ADDED +1  \_class_typespec: (env), 47:3-47:6                 2    1    2
ADDED +1  \_logic_net: (work@top.environment), 47:7-47:18    1    0    1
ADDED +1  \_class_defn: (work@env) ...                       3    2    3
   MULTISET DISTANCE 144521 -> 144512 (-9)      no REMOVED shapes
```

**Every ADDED shape lands on golden's count EXACTLY**, in both modes.

#### 5.5.1 `Scoreboard/default` — THE KNOWN FLAKE, EXECUTED, AND A FALSE MOVER

The ops rules name this row MULTI-STABLE and require a 3-rep plus a size delta
before attributing anything to it. Run on BOTH binaries, from the test's own
source directory:

```
ship  rep1 md5=1df12766ef220dae bytes=11133439
ship  rep2 md5=7cfa3a5678771ac2 bytes=11133439
ship  rep3 md5=c64f2fe81fec90ad bytes=11133439
pris  rep1 md5=c64f2fe81fec90ad bytes=11133439    <-- the SHIPPED rep3 hash
pris  rep2 md5=4da8d507fa6559eb bytes=11133439
pris  rep3 md5=4da8d507fa6559eb bytes=11133439
```

**THREE HASHES ON THE SHIPPED BINARY, ONE SIZE ON ALL SIX, AND THE TWO BINARIES'
HASH SETS INTERSECT** — `c64f2fe81fec90ad` is produced by both. The byte
verifier happened to sample `c64f2fe8` for "patched" and `4da8d507` for
"pristine" and called it a mover; the reverse sampling was equally available.
Content, measured rather than inferred:

```
MULTISET DISTANCE  pristine rep2  vs  shipped rep1 :  0   (1095679 lines both)
MULTISET DISTANCE  shipped  rep1  vs  shipped rep3 :  0   (same-binary control)
```

**Zero content difference across binaries, and the same zero within one binary.**
`Scoreboard/default` carries none of this law and is a FALSE MOVER. Note the
contrast with r10svs9, where the same row was a REAL mover: there it showed a
**−237 byte size delta**; here the size is identical to the byte on all six runs.
The size delta is what separates the two cases, which is exactly why the ops
rule demands it.

### 5.6 CANARIES

```
surelog  canaries.sh  ok=52  changed=0  absent=0   unknown-names=7  (expected 7)
         ctcan2.sh    ok=58  changed=0  absent=0   unknown-patterns=1  EXPECT_UNKNOWN=1
u2r      canaries.sh  ok=8   changed=0  absent=0   unknown-names=25 (expected 25)
         ctcan2.sh    ok=1   changed=0  absent=0   unknown-patterns=6  EXPECT_UNKNOWN=6
canaudit.sh  audited=29  UNCOVERED=0  FENCE-BREACH=0
```

Baseline passed FIRST and the fresh CSV mode-matched, per the ops rule. The two
canaries the rules require BY NAME, checked by name before any aggregate:

```
InterfaceModPort    baseline default/testflags  CMP_EQUAL,,,differ   fresh IDENTICAL
BlackParrotComplex  baseline default/testflags  CMP_EQUAL,,,differ   fresh IDENTICAL
```

`canaudit` also re-confirms the four SLANG-FENCED names (`UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched by no driver here.

---

## 6. REFUTATIONS

**6.1 THE BRIEF'S LAW-SHAPE, REFUTED.** The brief said golden "carries
ref_typespec -> class_typespec ALWAYS" (true) and that ours "DROPS it exactly
when the variable is ASSIGNED" (true of ours) — and directed the pass to find
"WHERE our emitter drops it… an initializer-driven path that never attaches the
pending typespec". There is no such path. The drop is a **deliberate predicate
that models assignment on purpose**, and the thing to fix was not a missing
attachment but a false theory of golden. Cells: `c2` h1/h2 and i1/i2.

**6.2 SCOPE KIND, REFUTED.** Module, program and interface all keep the link in
golden, assigned or not (`c1` a/b/c/d/e). The brief's seed observation that
SVSwitch's site is in a `program` is a coincidence of the witness.

**6.3 TOP-NESS, REFUTED.** Top module, non-top module, top program and non-top
program all keep it (`c1` a1/b1/d1/c1). This was the confound most likely to
survive c1's first reading — OneThis's `top` is a TOP module and SVSwitch's
`testcase` is a NON-TOP program — and the arm crossed it deliberately.

**6.4 THE PRODUCER'S OWN CITATION, REFUTED as evidence for the strip.**
"OneThis vs OneClass" does not support the rule it was cited for: `OneThis`
still `DUMP_MATCH`es with the strip deleted (§3.4), because `namedTypeNet`
covers it. A citation that survives the deletion of the thing it cites was never
evidence for it.

**6.5 THE STRIP WAS INCOHERENT ON ITS OWN TERMS.** It scanned only
`ProceduralBlock` members of the body, so `n3` and `n4` — handles assigned by
`n3 = new()` inside a **task** and a **function** — kept their typespecs while
`n1`, the same assignment in an `initial`, lost its. Two cells that its own
stated rule ("never procedurally assigned") puts on the same side landed on
opposite sides. Those two cells were EQ on the pristine binary **for the wrong
reason**, and they are EQ on the shipped binary for the right one.

**6.6 THE ScopedName CARVE-OUT WAS DEAD WEIGHT.** It existed only to undo the
strip. With the strip gone, `c2` j1/j2 and `c3` q8 keep `TS(pk::SK)` with no
clause of their own, and `c2` j3/j4 show a bare typedef'd name in the same
module still losing it — `namedTypeNet` draws that line unaided.

**6.7 THIS PASS'S OWN CENSUS OVER-COUNTED, and the byte verifier corrected it.**
`census.sh` predicts carriers from the pristine side alone: a def-view net with
no `vpiTypespec` whose elab twin is a `class_var`. On u2r it named **1** carrier
— `testflags/OneThis`, 2 nets — and the verifier found **0 movers**. The
predicate does not model clause (d), `namedTypeNet`, so it flags exactly the
nets that rule protects, and it matches elab twins by name TAIL, which is loose.

On the SURELOG corpus **the census was NOT completed and its number must not be
quoted**: it re-dumps 953 databases, several of them 1.1M dump lines, and it was
still in the `C`s when this pass closed. Its first four hits are recorded for
what they are — a demonstration of the over-count, not a result:

```
CARRIER  default/ApbSlave           nets=8     <- did NOT move
CARRIER  default/ArrayMethodIterator nets=2    <- did NOT move
CARRIER  default/BuildUVMPkg        nets=229   <- did NOT move
CARRIER  default/ClassVar           nets=1     <- did NOT move
```

Four "carriers" in the first fraction of the corpus, **zero of them movers**.
**It is an UPPER BOUND, not a prediction**, and it is
recorded as such rather than dressed up: the byte verifier is the authority and
the census's only real service here was naming `OneThis` — the very database the
non-ANSI rule was claimed to protect, which then demonstrably did not move.
r10svs9's census UNDER-counted by omitting a corpus root; this one OVER-counts
by omitting a clause. Same lesson from the opposite side: **a census is only as
good as the predicate it names, and only the verifier settles it.**

**6.8 `Scoreboard/default` REFUTED as a mover** — §5.5.1, on three instruments
(intersecting hash sets, identical size, multiset distance 0).

---

## 7. RESIDUES, RANKED

**R1 — THE SVSwitch SUCCESSOR HEAD, `module_inst: work@top`, 2680 cmp lines,
identical in both modes.** Pre-existing and proven untouched by this pass
(§5.4.1). It is the next target on this row and it is *large*, which after two
passes of small heads is a real change of character: SVSwitch's remaining
distance is 1354 and this head sits at the top of the design's own listing.
Worth a pass that first asks whether the 2680 lines are one defect or a
first-mismatch that Compare simply reports from a high root — the head-is-a-
SUBTREE law says depth is not a size.

**R2 — the PARAMETERIZED class name's `class_typespec` span. 2 cells, and NEWLY
VISIBLE.** `c3` q2: golden spans `48:3-48:4` (the class NAME only, `P`), ours
`48:3-48:8` (the whole `P#(2)`); q7 shows the same at a typedef site
(`19:9-19:10` vs `19:9-19:14`). This is a *span* law about where a
parameterized class reference ends, and it could not be seen before this pass
because the object did not exist. Highest-ranked of the newly-visible residues:
it is a clean two-cell arm, and parameterized class handles at design scope are
the shape UVM testbenches are built from.

**R3 — INTERFACE-class handles: golden emits `unsupported_typespec`, we now emit
`class_typespec`. 1 cell, NEWLY VISIBLE.** `c3` q5 (`IC ic;` where `IC` is an
`interface class`). Golden declines to type it; we type it. Before this pass we
emitted nothing and were wrong differently. Narrow, and needs its own
measurement of what else Surelog routes to `unsupported_typespec`.

**R4 — the DECLARATION-INITIALIZER `class_typespec` span. PRE-EXISTING,
unchanged on both binaries.** `c2` k1 and `c3` n9: for `K k1 = new();` golden's
`class_typespec` spans the WHOLE declaration including the initializer
(`67:3-67:15`), ours the type name alone (`67:3-67:4`). Identical on pristine and
shipped, so this law neither caused nor touched it. It also explains why the
elab `class_var` twin's span differs in the same cells.

**R5 — the ESCAPED-IDENTIFIER declarator span. PRE-EXISTING and symmetric.**
`c3` `\esc.two `: golden `68:20-68:33`, ours `68:16-68:29` — four columns, the
same gap r10svs9 recorded as its R3, on both binaries, in a law that touches no
spans.

**R6 — arena ORDER in the `weaklyReferenced` tail.** `c1`'s residual dump diff
(44 content lines) is entirely `hier_path` objects sitting at different
positions relative to the `class_typespec` objects this pass adds. `cmp heads=0`
on that arm — uhdm-cmp is order-insensitive here — and no object's content
differs. Lowest rank: it costs nothing today and the campaign has already
established that arena order does not reach the comparator.

---

## 8. FILES

```
README.md          this record
svs10arm.sh        one arm: Surelog + ours + dumps + cmp, in its own scratch dir
svsgen.sh          the SVSwitch pair, both modes, through the harness itself
ctsread.py         the grid reader: every class-handle signal's typespec chain,
                   span-keyed, indent-walked so vpiParent back-pointers are not
                   counted.  `--all` prints EQ cells too.
census.sh          the carrier census, both corpora (an UPPER BOUND -- see 6.7)
ctscensus.py       its per-database counter, reusing ctsread's walk
c0_onethis.sv      the producer's own citation, re-run against the deletion
c1_scopetop.sv     scope kind x top-ness      (both REFUTED)
c2_header.sv       header form x assignment   (THE DECISIVE ARM)
c3_kinds.sv        assignment forms, class kinds, declarators, escaped names
byteverify.sh ct8rows.sh canaries.sh ctcan2.sh canaudit.sh msdist.sh msmovers.sh
                   the gate + canary harness, carried from r10svs9repro unchanged
```
