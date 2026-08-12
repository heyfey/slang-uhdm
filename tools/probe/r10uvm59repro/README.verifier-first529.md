# r10uvm59 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PARTIAL.** The patch is **safe to land unchanged** — I rebuilt it from
a fresh 81b8e0c worktree and every one of the five gates reproduces, several of
them **bit-for-bit**, including the two md5s. But the pass misses the campaign's
own bar on two counts, both of which an adversarial pass exists to catch:

* **F1** — a **measured over-fire in a product cell the grid never builds**: an
  unbound `::` reference in **ASSIGNMENT-TARGET** position. §59 plants the READ
  name/span where the already-landed, already-measured
  § staticScopedLvalueBad48 says golden writes `FIRST::@@BAD_SYMBOL@@` over the
  whole lvalue. **5 lvalue flavours** affected. Priced at **0 corpus rows
  today**, and I prove that with the corpus's only candidate site.
* **F2** — `ADDED=109` is **not the measured number**. The real figure is
  **102** (36 per BuildUVMPkg row, 6 per uvm-1.2 row). The instrument's own
  negative control was counted as data.

Nothing regressed: 0 differing rows in either corpus, 0 over-firing **object**
shapes on all 7 movers, negative control byte-identical. Land it, then fix F1.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

---

## 0. WHAT I BUILT, AND THE BASE OF EVERY BINARY

| worktree | HEAD | binary (absolute BASE) | md5 |
|---|---|---|---|
| `.claude/worktrees/r10uvm59vpris` | `81b8e0c0f3dc63a2aa935fbda8f3196c1d6292f4` | `…/r10uvm59vpris/build/slang-uhdm` | `7922a457a58565ff014f9c440b585eb6` |
| `.claude/worktrees/r10uvm59v` (patch applied) | `81b8e0c0f3dc63a2aa935fbda8f3196c1d6292f4` | `…/r10uvm59v/build/slang-uhdm` | **`167d5696053b4b58b4e85c9cf168fcd5`** |

Both md5s are **byte-identical to the implementer's**, from an independent
configure + build. That is the strongest single result in this report: the
deliverable is bit-reproducible.

```
git apply --check --verbose /tmp/r10uvm59.patch   -> rc=0, 14 files
git diff --numstat 81b8e0c -- include src
   10   0  include/UhdmExporter.h
  106   0  src/ExprEmit.cpp
   16   0  src/UhdmExporter.cpp
md5sum /tmp/r10uvm59.patch = 0aaf6187260bd066bb296708c916dc21   (matches)
```

**ZERO DELETIONS in production.** § typeParamRetIsRefVar58,
§ invalidNewCallFromSyntax55, § classMethodRetNameNoBind56 /
§ retNameNewLhsNoBind56, § staticScopedCall12 and § classPropScopedCallIsRefObj29
are byte-identical in source, so the only behavioural change possible is where a
`return nullptr` became an object. I verified the two insertion points by reading
the arms around them: in `emitExpr` the new arm sits after the child unwrap,
after § droppedCall14 and after § invalidNewCallFromSyntax55 (mutually exclusive
syntax kind) and immediately before `noteUnsupportedAt`; in
`emitClassPropInit29` the arms above it gate on `NewClass` /
`UnbasedUnsizedIntegerLiteral` / concat+patterns, none of which an `Invalid`
initializer can be, and the arm below keeps its `ic.kind == Call` gate, which
`Invalid` can never satisfy. **No interception.**

`grep -rn 'typeParamScopedCallRef59\|invalidScopedNameSyntax59\|invalidScopedCallRef59' include/ src/` → **11 hits, 3 files** (claim reproduced).

**The main tree is clean of this law.** `grep -c` for all three symbols in the
main tree's `include/UhdmExporter.h`, `src/ExprEmit.cpp`, `src/UhdmExporter.cpp`
= **0/0/0**; its current modifications carry `thisPathSelectErased4` (4 hits in
`ExprEmit.cpp`, 1 in the header) — r10svs4's, as disclosed. The implementer's
claim that the main-tree binary equalled the control is no longer checkable (a
concurrent agent has rebuilt it to `2e9d37d3a78a57b4010043cc2abebbca`), and it
does not matter: my own pristine build of 81b8e0c reproduces `7922a457…`.

---

## 1. FIRST LINE — **BuildUVMPkg did NOT convert.** Confirmed.

Both rows, from **my own** sweep `/tmp/r10uvm59vfy/sl_final.csv`:

```
BuildUVMPkg,default,CMP_NOTEQUAL,decompile:,,
BuildUVMPkg,testflags,CMP_NOTEQUAL,decompile:,,
```

Byte-identical to `results/golden_surelog.csv` **lines 170-171** and to my
**pristine** sweep. The conversion-adjusted gate numbers do not apply; the
scoreboard stands at **467/13 + 463/10**.

The **head cleared and advanced** on both rows — measured by me with
`uhdm-cmp golden ours`:

| row | pristine | FINAL |
|---|---|---|
| BuildUVMPkg default | 15 cmp lines, 1 head | **58 cmp lines, 1 head** |
| BuildUVMPkg testflags | 15 cmp lines, 1 head | **58 cmp lines, 1 head** |

Old head (`RHS: <null>`, `ref_obj …::__deferred_init::Tregistry::get`,
`line:14104:24, endln:14104:35`) — **gone**. New head is a **different law's**,
exactly as filed under R1:

```
LHS golden  ref_obj: (uvm_pkg::uvm_registry_common::__deferred_init::uvm_pkg::uvm_deferred_init), line:14107:7, endln:14107:16
RHS ours    hier_path: (uvm_pkg::uvm_deferred_init.push_back), line:14107:7, endln:14107:50
```

**The brief's weakest link: CONFIRMED, not refuted.** `RHS: <null>` was a
genuinely missing object. I re-measured it independently: `line:14096` /
`line:14104` object census and the `vpiRhs` field census both reproduce, and the
pp-source column arithmetic checks to the character —
`     Tregistry rgtry = Tregistry::get();` puts `Tregistry::` at cols 24-34 with
`get` starting at col **35**, which is golden's `endln:14104:35`.

---

## 2. THE FIVE GATES, REPRODUCED INDEPENDENTLY

### GATE 1 — BUILD
`link lines = 1`, `' error:' = 0` in each build log; both worktree HEADs
`81b8e0c0f3dc…`; md5s asserted in a command separate from the build (§0). **PASS.**

### GATE 2 — GOLDENS
```
SLANG_UHDM=<FINAL>  bash tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false bash tests/check_goldens.sh rc=1  PASS=0   FAIL=23
```
**PASS**, both directions.

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own out/workdir
```
731 tests   CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2
dump column match 496   differ 183   blank 52
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh>  -> 0 differing ROWS (0 diff row-sides)
```
Every figure matches. My **pristine** sweep also reads 0 differing ROWS against
the committed baseline, which is what makes gate 5 meaningful. **PASS.**

### GATE 4 — surelog, `--mode both --jobs 2`
```
default    CMP_EQUAL 467  CMP_NOTEQUAL 13  DEFERRED 5  SLANG_REJECT 284  SURELOG_FAIL 25
testflags  CMP_EQUAL 463  CMP_NOTEQUAL 10  DEFERRED 5  SLANG_REJECT 286  SURELOG_FAIL 23
           NO_DATABASE 3  UNTRANSLATABLE 2  TIMEOUT 1  NO_UHDM 1
dump  default 225 match / 242 differ / 327 blank ; testflags 165 / 298 / 331
ct8rows.sh results/golden_surelog.csv <fresh>  -> 0 differing ROWS (0 diff row-sides)
```
Every figure matches, dump histograms included. Pristine sweep: 0 differing ROWS
too. `GOLDEN_DEFER` default → 5 DEFERRED both modes, as in the baseline. **PASS.**

### GATE 5 — BYTE VERIFIER vs my own pristine 81b8e0c build
```
uhdm2rtlil : PATH_SETS_IDENTICAL (679)  MOVERS 0 / 679   SELFCHECK 678/679  SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953)  MOVERS 7 / 953   SELFCHECK 952/953  SELFCHECK1 = 8
```
The 7 movers are **name-for-name** the claimed set:
`{SimpleUVM, BuildUVMPkg, SeqDriver} x {default, testflags}` + `Scoreboard,default`.
**PASS.**

### CANARIES
```
ctcan2.sh  EXPECT_UNKNOWN=6  u2r      ok=1  changed=0 absent=0 unknown-patterns=6  rc=0
ctcan2.sh  EXPECT_UNKNOWN=1  surelog  ok=58 changed=0 absent=0 unknown-patterns=1  rc=0
r10uvm52repro/canaries.sh   u2r      ok=8  changed=0 absent=0 unknown-names=25
r10uvm52repro/canaries.sh   surelog  ok=52 changed=0 absent=0 unknown-names=7
r10uvm55repro/canaudit.sh   audited=29  UNCOVERED=0  FENCE-BREACH=0
```
BY NAME on the surelog csv: `InterfaceModPort` OK CMP_EQUAL/differ both modes;
`BlackParrotComplex` OK CMP_EQUAL/differ both modes; `SVSwitch` OK CMP_NOTEQUAL
both modes; `Earlgrey_0_1` OK CMP_NOTEQUAL/SLANG_REJECT; `ClassTypeParam` and
`ClassParamAsParam` OK CMP_EQUAL/differ both modes.

### MOVERS — my own instrument, not `mv58.sh`
`vmv59.py` (written from scratch; object-header multiset **and** raw-line multiset,
so the bare-field-line artefact cannot be blamed on an owner) over all 7 movers:

| mover | ADDED | REMOVED | OVER-FIRE objects (new) | UNDER-FIRE objects (new) |
|---|---|---|---|---|
| BuildUVMPkg default | 36 | **0** | **0** | 2 |
| BuildUVMPkg testflags | 36 | **0** | **0** | 2 |
| SimpleUVM default / testflags | 6 / 6 | 0 / 0 | 0 / 0 | 0 / 0 |
| Scoreboard default | 6 | 0 | 0 | 0 |
| SeqDriver default / testflags | 6 / 6 | 0 / 0 | 0 / 0 | 0 / 0 |

**0 REMOVED and 0 over-firing object shapes anywhere — the core claim holds.**
The 2 UNDER-FIRE are `method_func_call (set_type_override_by_type)@14073:13-38`
and its `set_inst_override_by_type` twin, each **3 → 4 against golden's 5**:
movement *toward* golden, not a regression. Every added object shape has
golden count == ours count; the added bare field lines
(`|vpiRhs:`, `|vpiName:…`, `|vpiParent:`, `|vpiArgument:`, `|vpiFullName:…`) are
flagged UNATTRIBUTABLE by construction rather than blamed.

`msdist.sh` @7c7eaa6 (md5 `7c0d46b5da124cfe37d27eddc95eb7e7`, = `git show 7c7eaa6:`)
on BuildUVMPkg:

| | pristine | FINAL |
|---|---|---|
| golden-only line instances | 53726 | **53703** |
| ours-only line instances | 28649 | 28662 |
| **MULTISET DISTANCE** | **82375** | **82365** |
| dump lines (golden 1101386) | 1076309 | 1076345 |

Exact match to the README.

---

## 3. THE GRID, RE-MEASURED — and every number does reproduce

Both binaries, `cells59.py`, subject-name filter
`'::(get|getn|sprop|create_by_type|eget|pf59)\b'`:

| arm | claimed | I measure | arm cmp (pris → FINAL) |
|---|---|---|---|
| `a2_position` (13 positions) | 13 → 0 | **13 → 0** | 15/1 → 108/1 |
| `a3_scope` | 3 → 2 | **3 → 2** | 15/1 → **rc=0, 0 lines, 0 heads** |
| `a4_bind` (9 bindings) | 7 → 1 | **7 → 1** | 3746/1 → 3818/1 |
| `v1_elab` | 1 → 0 | **1 → 0** | 15/1 → 244/1 |
| `v2_lonedecl` | 3 → 2 | **3 → 2** | 124/1 → 124/1 |
| `v3_negctl` | identical | **identical** | 562/1 → 562/1 |

Cell for cell on a2 FINAL, all 13 positions equal to golden, including the two
load-bearing drops: **P5** `Tcreator::create_by_type(Tregistry::get(), nm)` →
ONE `ref_obj p59a2::w59::p5::Tcreator::create_by_type`@66:21-31, golden 1 / ours
1, inner call **gone in golden too**; **P12** class-property init →
`ref_obj p59a2::w59::m_prop::Tregistry::get`@108:24-35, golden 1 / ours 1;
**P8** no-parens `Tregistry::sprop`@83:21-32; **P9** args dropped
`Tregistry::getn`@89:21-32. On a3 FINAL the only two remaining cells are the
`extern59::eget` prototype/definition `int_var` duplication (pass 58's residue,
pre-existing in both binaries) and **`a3_scope` is now fully CMP EQUAL**.

**Negative control byte-identity confirmed**: `v3_negctl` `ours.uhdm` md5 equal
before and after (`8a01af0119f49699f910f0b41fca73b7` in my output tree — the
README's `9c35…` differs only because a UHDM database embeds its own absolute
path; the load-bearing statement, pristine == FINAL, and `cmp -s` on the dumps,
both hold), and its cell table is identical on both binaries.

**R8 verified pre-existing**: `hier_path (factory.note)@43:7-19` reads
**pristine 3 / FINAL 3** (golden 0); the sibling `method_func_call (note)@43:15-19`
goes 2 → 3 toward golden's 4. Unchanged shape, as claimed.

**Site 14096 verified a non-mover**: objects at `line:14096` — golden **7**,
pristine **0**, FINAL **0**. The prediction made before measuring was right.

**§ typeParamRetIsRefVar58 boundary verified**:
`ref_var (…__deferred_init::rgtry), line:14104:16, endln:14104:21` reads
**golden 4 / pristine 4 / FINAL 4**.

**NOTE (F3):** the README's grid figures are only reproducible with that
subject-name filter, which it states for `v3` alone. With `cells59.py`'s
**default** pattern the same arms read a2 **19 → 4**, a4 **15 → 9**, v1 **2 → 1**,
v2 **6 → 5** — the residuals being pre-existing residues the filter excludes.
Every delta is the claimed delta except a2 (-15 vs -13). Not a defect in the law;
a reproducibility gap in the record.

---

## 4. EMPTY PRODUCT CELLS I BUILT — the hunt, and what it found

Four new arms, both binaries, in this directory:
`w1_lvalue.sv`, `w2_scopekind.sv` + `w2b_scopekind.sv`, `w3_lvflavour.sv`,
`w4_constctx.sv`, plus the instrument `vmv59.py`.

### F1 — **THE MISSING CLAUSE IS lvalue POSITION.** Confirmed over-fire.

`a2_position` enumerates thirteen positions and **every one of them is a READ**.
The position it never builds is the **ASSIGNMENT TARGET**, and that position has
a different golden shape which is *already landed and already measured*:
§ staticScopedLvalueBad48 (`ExprEmit.cpp` ~692) —
`FIRST::@@BAD_SYMBOL@@` spanning the **whole written lvalue**, on t67d H1/H3,
t67a C9, t67b D7/E5. § staticScopedRef12 routes to it with
`if (inLhs && assignTargetParent48(parent))` at `ExprEmit.cpp` ~3921.
**§ typeParamScopedCallRef59's gate has no such conjunct.**

`w1_lvalue.sv`, cells `(kind, fullname, span)` with multiplicities:

| cell | source | golden | pristine | **FINAL** |
|---|---|---|---|---|
| W1 bare assign | `T::sprop = 3;` | `ref_obj T::@@BAD_SYMBOL@@`@31:7-15 = 1 | 0 | 0 — and **ours invents `T::sprop`@31:7-10 = 1** |
| W3 select lvalue | `T::sbits[1] = 1'b1;` | `T::@@BAD_SYMBOL@@`@44:7-18 = 1 | 0 | 0 — **`T::sbits`@44:7-10 = 1** |
| W5 chain lvalue | `T::inst.field = 3;` | `T::@@BAD_SYMBOL@@`@56:7-20 = 1 | 0 | 0 — **`T::inst`@56:7-10 = 1** |
| W6 read control | `int y = T::sprop;` | `T::sprop`@63:15-18 = 1 | 0 | **= golden** |

Differing cells on this arm: **8 → 10.** One converted, **three regressed** —
the only arm in this pass whose cell count gets worse. The cmp head shows it as
plainly as it can be shown:

```
LHS golden  ref_obj: (p59w1::gw1::w1::T::@@BAD_SYMBOL@@), line:31:7, endln:31:15   |vpiName:T::@@BAD_SYMBOL@@
RHS pristine  <null>
RHS FINAL   ref_obj: (p59w1::gw1::w1::T::sprop),          line:31:7, endln:31:10   |vpiName:T::sprop
```

`vpiName` **and** span are both wrong, and `vpiName` is what `BaseClass::Compare`
reads. `w3_lvflavour.sv` prices the reach at **five** lvalue flavours:

| cell | source | golden object | FINAL |
|---|---|---|---|
| X5 compound assign | `T::sprop += 1;` | `ref_obj T::@@BAD_SYMBOL@@`@49:7-15 | **invents `T::sprop`@49:7-10** |
| X6 increment | `T::sprop++;` | `ref_obj T`@55:7-15 — **name is the FIRST SEGMENT ALONE** | **invents `T::sprop`@55:7-10** |
| X7 concat lvalue | `{m_i, T::sprop} = 2;` | `ref_obj T`@61:13-16 + `ref_obj m_i`@61:8-11 | absent in BOTH — pre-existing concat drop (their R5), unchanged |
| X1 case expr, X2 `$display` arg, X3 ternary, X4 **output argument**, X8 read | | | **all = golden** |

X4 is worth naming: an output argument is an lvalue that is *not* an assignment's
`Lhs`, and golden takes the **READ** form there (`T::sprop`@43:12-15) — exactly
what § staticScopedLvalueBad48's `assignTargetParent48` gate predicts, and §59
already agrees. So the missing conjunct is precisely `assignTargetParent48`, not
"lvalue-ness". Arm total: **10 → 6** differing cells (5 conversions, 2 new
over-fires).

**PRICED AT 0 CORPUS ROWS TODAY, and here is the proof rather than an assertion.**
The corpus's only candidate is `uvm_callback.svh:556` →
pp `uvm_pkg.sv:27097` `super_type::m_typename = tname;` inside
`class uvm_callbacks #(type T=uvm_object, type CB=uvm_callback)` with
`typedef uvm_typed_callbacks#(T) super_type;`. Because `T` defaults to
`uvm_object`, `uvm_typed_callbacks#(uvm_object)` really has `m_typename` and
**slang binds it**, so § staticScopedRef12 + § staticScopedLvalueBad48 own it:
objects at `line:27097` = **golden 5 / pristine 5 / FINAL 5**, and
`ref_obj (…m_register_pair::super_type::@@BAD_SYMBOL@@)@27097:5-27` is present
and identical in all three. Whole-database `BAD_SYMBOL` line census:
**golden 21 / pristine 21 / FINAL 21.** A source census of all UVM trees for
`^\s*\w+::\w+\s*(=|\+=|-=|\*=|/=|\+\+|--)` finds 26 sites, every one of them
concrete or bound. Consistent with gate 5: **0 over-firing object shapes**.

**The fix, with the trap in it.** Add to `invalidScopedCallRef59` (or ahead of
its call site) the same two lines § staticScopedRef12 uses:
`if (inLhs && assignTargetParent48(parent)) return scopedLvalueBadRef48(…)`.
**But `scopedLvalueBadRef48` spans `whole.sourceRange`, and an `Invalid`
expression's `sourceRange` is EMPTY** (the README's own decode says so) — it must
take `e.syntax->sourceRange()`. I checked that this is right on all four measured
cells: golden's whole-lvalue spans 31:7-15, 44:7-18, 56:7-20, 49:7-15 are exactly
the syntax ranges. And X6 shows the lvalue law itself has **at least two
sub-shapes** (`T::@@BAD_SYMBOL@@` for assign/compound-assign, bare `T` for
increment and concat-element), so this needs its own arm set — which is why I
report it rather than demand it in this pass. **One head per run** is respected.

### F4 — three over-fire hypotheses of mine, REFUTED, and the refutation strengthens the law

I predicted §59 would over-fire on SCOPE KIND, because its gate keys on the
syntax and a3 S5 shows golden keeps a **`func_call` with its arguments** for a
package qualifier. It does not, and the reason is a measurement:
**only lookups through a type parameter are deferred by slang.** Everything else
is a hard error that rejects the design and can never reach the `Invalid` arm:

```
p59w2::pf59(1, 2, 3)     error: too many arguments for 'pf59'; expected 2 but 3 were provided
p59w2::pf59(1,2,3);      (same, STATEMENT position)
impl59::sget2(T::junk)   error: no member named 'sget2' in class 'impl59'
ifc59::iget()            error: call to non-static member function without object handle
p59a3::Tregistry::get()  error: no member named 'Tregistry' in package 'p59a3'   (their S6)
```

That closes the **interface-class** cell the review brief named: an interface
class cannot hold a static method, so the scope kind is unreachable by
construction, not merely untested.

And where the **callee resolves but an ARGUMENT does not** — the one cell that
does compile — slang still produces a `Call`, so golden's `func_call` survives
and §59 correctly fills in only the argument. `w2b_scopekind.sv`, **11 → 6**
differing cells: `func_call p59w2b::pf59`@46:13-19 golden 3 / pristine 2 /
FINAL 3 (expression position) and @58:7-13 likewise (**statement** position);
the six survivors are pre-existing `ifc59` interface-class emission residues,
identical on both binaries. The campaign's twice-burned statement-position axis
is clean here.

### F5 — call site 2's package guard is absent but slang-guarded

§ classPropScopedCallIsRefObj29 documents *"Only a CLASS scope degrades; a package
qualifier keeps the call (t39b `q39b::qf39(4)`)"*. The new call site in
`emitClassPropInit29` carries **no qualifier test** and would degrade a package
initializer too. Unreachable for F4's reason (a package-qualified initializer
that fails to bind is a hard error; one whose argument fails stays a `Call`).
It is guarded by slang, not by the code — worth a comment, not a patch.

### F6 — constant context clean; **no r10earl30 collision**

`w4_constctx.sv`: **12 → 9** differing cells. The conversion is the **case-item**
cell (`T::CV` as a case label, objects at line 30: golden 7 / pristine 6 /
FINAL 7). The localparam cells C1/C2 are a **pre-existing empty-prefix bug** in
the `param_assign` path — ours emits `ref_obj (T::CV)`@18:25-30 where golden has
`ref_obj (p59w4::gw4::T::CV)` — and it hits the **CONCRETE** control
`hasval59::LP` identically, byte-identical pristine vs FINAL. No constant is
created, folded or re-typed by this pass. (Also recorded: a class `static const`
is not a constant expression to slang, which is why C2 had to use a localparam.)

---

## 5. THE NUMBER THAT IS WRONG

### F2 — `ADDED=109` is the instrument plus its own negative control

Independent multiset measurement (`vmv59.py`, and confirmed by the raw dump line
deltas, which must equal ADDED when REMOVED=0):

| | README | measured |
|---|---|---|
| ADDED, BuildUVMPkg per row | 37 | **36** (1076345 − 1076309) |
| ADDED, uvm-1.2 per row | 7 | **6** (e.g. SimpleUVM 1100377 − 1100371) |
| **ADDED total** | **109** | **102** = 36x2 + 6x5 |
| REMOVED total | 0 | **0** ✓ |

Cause, read off the source: `tools/probe/r10uvm58repro/mv58.sh` **line 70**
appends the fabricated SELFCHECK shape with count 1 to `$key.added`, and **line
71** sums `na` from that same file. With `SELFCHECK=1` every mover's ADDED is
inflated by exactly 1 → **+7**, and 102 + 7 = 109. The implementer subtracted the
injection from the OVER-FIRE count ("9 = 7 fabricated + 2 real") but **not** from
ADDED. The substantive claims are unaffected — 0 REMOVED and 0 over-firing object
shapes both reproduce — but a stated measurement was not the measured number,
which is the trap the campaign's own laws name. Future passes must run `mv58.sh`
**twice** (with and without `SELFCHECK`) and quote the un-instrumented totals.

---

## 6. FINDINGS, NUMBERED, EACH WITH ITS COMMAND

| # | severity | finding | command |
|---|---|---|---|
| **F1** | **HIGH (latent, 0 rows)** | §59 has no `inLhs && assignTargetParent48` conjunct, so an unbound `::` reference in assignment-target position takes the READ name/span where § staticScopedLvalueBad48 measured `FIRST::@@BAD_SYMBOL@@` over the whole lvalue. 5 flavours; `w1_lvalue` cells 8→10 (net worse). Unreachable in both corpora today (pp 27097 binds; BAD_SYMBOL census 21/21/21) | `bash arm59.sh w1_lvalue.sv <out> <bin>` then `python3 cells59.py <out>/g.dump <out>/o.dump '::'`; `bash arm59.sh w3_lvflavour.sv …` |
| **F2** | MEDIUM | `ADDED=109` includes 7 SELFCHECK injections; real ADDED = **102** (36/36/6/6/6/6/6), REMOVED = 0 | `python3 vmv59.py <g.dump> <pris.dump> <final.dump>` per mover; `sed -n '66,74p' tools/probe/r10uvm58repro/mv58.sh` |
| **F3** | LOW | the grid tables' cell counts need an undocumented subject-name filter; the default `cells59.py` pattern gives a2 19→4, a4 15→9, v1 2→1, v2 6→5 | `python3 cells59.py …` with and without `'::(get\|getn\|sprop\|create_by_type\|eget\|pf59)\b'` |
| **F4** | INFO (strengthens the law) | my SCOPE-KIND over-fire hypotheses are refuted: arity errors, missing concrete members, interface-class qualifiers and missing package members are slang **hard errors**, unreachable; an unbound ARGUMENT under a resolving package callee keeps golden's `func_call` and §59 fills only the argument (11→6) | `bash arm59.sh w2_scopekind.sv …` (rejects, quoted); `bash arm59.sh w2b_scopekind.sv …` |
| **F5** | INFO | call site 2 in `emitClassPropInit29` lacks § classPropScopedCallIsRefObj29's documented "package qualifier keeps the call" test; unreachable for F4's reason | read `src/UhdmExporter.cpp` ~608-640 |
| **F6** | INFO | constant context clean, no r10earl30 collision; the localparam prefix mismatch is pre-existing and concrete-symmetric | `bash arm59.sh w4_constctx.sv …` |

---

## 7. RANKED RESIDUES (mine, after re-measurement)

1. **R1 — BuildUVMPkg's new head**, both modes: a package-variable `::`-rooted
   chain whose tail is a **built-in** queue method
   (`uvm_pkg::uvm_deferred_init.push_back(rgtry)`). Golden ONE
   `ref_obj`@14107:7-16; ours a `hier_path`@14107:7-50 with two `vpiActual`
   children. Quoted in §1. Highest value: it is the head on 2 of 7 UVM row-modes.
2. **F1's lvalue clause** — the only *correctness* debt this pass creates. 0 rows
   today, 5 measured cells, and the fix has a known trap (empty
   `Invalid::sourceRange`) plus at least two golden sub-shapes.
3. **R2/R4** — nested-`begin` and lone-`VariableDeclaration` bodies dropped
   wholesale. Verified as the blocker on corpus site 14096 (golden 7 objects,
   ours 0, unchanged) and independent of the qualifier (the concrete
   `uvm_factory::get()` is lost too).
4. **R3** — a chain rooted at a `::` **call** (`base59::get().inst(2)`); same
   family as R1, concrete flavour; `scopedChainDropBase48` needs a `NamedValue`
   root.
5. **R5** — a concatenation with one unbindable operand loses **all** operands;
   independently reproduced at `w3` X7 (golden 2 objects, ours 0, both binaries).
6. **R8** — statement-position call whose argument is unbound takes the
   expression shape; verified pre-existing (`hier_path` 3/3).
7. **R6/R7/R9** — `type T` with no default → no `class_defn`; extern
   prototype/definition return-var duplication (the 2 residual a3 cells);
   per-type-parameter shared typespec, invisible to uhdm-cmp.
8. **NEW: the localparam `param_assign` prefix bug** (F6) — ours emits an
   unprefixed `ref_obj (T::CV)` / `(hasval59::LP)` where golden prefixes with the
   class path. Concrete and type-param alike; not owned by any current pass.

---

## 8. BOUNDARIES — no collision

* **§ typeParamRetIsRefVar58** — untouched; its `ref_var` at 14104:16-21 reads
  golden 4 / pristine 4 / FINAL 4.
* **§ invalidNewCallFromSyntax55** — untouched, mutually exclusive syntax kind,
  and §59 is ordered strictly after it (read in the source).
* **§ classMethodRetNameNoBind56 / § retNameNewLhsNoBind56** — untouched; 0
  deletions in production means their text is byte-identical, and neither names
  an `Invalid` expression.
* **§ staticScopedCall12 / § staticScopedRef12 / § classPropScopedCallIsRefObj29**
  — extended around, not rewritten; a3 S1/S3/S4 and v3 confirm their cells
  unchanged.
* **§ staticScopedLvalueBad48** — **NOT respected in the unbound case: F1.** This
  is the one boundary the pass crosses, and it crosses it in a cell neither
  corpus contains.
* **r10svs4** (SVSwitch hier_path index-presence) — untouched; `SVSwitch` OK
  CMP_NOTEQUAL both modes; 0 hits for `thisPathSelectErased4` in the patch.
* **r10earl30** (vpiConstType on folded constants) — untouched; `Earlgrey_0_1` OK;
  F6 shows no constant is created or modified.

---

## 9. FILES ADDED BY THIS VERIFICATION

In `/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10uvm59v/tools/probe/r10uvm59repro/`:
`README.verifier.md` (this file), `w1_lvalue.sv`, `w2_scopekind.sv`,
`w2b_scopekind.sv`, `w3_lvflavour.sv`, `w4_constctx.sv`, `vmv59.py`.
Reused unchanged: `arm59.sh`, `cells59.py`, `r10oth6repro/byteverify.sh`,
`r10oth7repro/ctcan2.sh`, `r10oth8repro/ct8rows.sh`,
`r10uvm52repro/canaries.sh`, `r10uvm55repro/{msdist.sh,canaudit.sh}`.
`results/*.csv`, `scripts/verify_golden.py` and `tests/check_goldens.sh` were
**read only**. `git stash` never used. Sweep workdirs deleted.
