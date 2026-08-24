# r10uvm116 — § scopeRandomizeIsBareCall116

**The head.** `Scoreboard/default`, `MiniAmiq/default`, `MiniAmiq/testflags`
each stood at 60 cmp lines, one head, and the head was the same object in all
three: `uvm-1.2 src/seq/uvm_sequence_builtin.svh:196`

```
if (!randomize(l_kind) with { l_kind > l_exhaustive_seq_kind;
  l_kind < max_kind; })
```

| side | object |
|---|---|
| LHS (golden) | `method_func_call (randomize)` @196:10–197:27, `vpiArgument ref_obj (l_kind)` @196:20–196:26, `vpiWith constraint` (no span, parented at the `!` operation) |
| RHS (ours) | `hier_path (l_kind.randomize)` @196:10–196:27, elements `ref_obj (l_kind)` + `method_func_call (randomize)` @196:27–196:36, no constraint anywhere |

The restricted class property `l_kind` had become a RECEIVER.

---

## 1. Why our emitter read a receiver that was never written

slang models the class `randomize` as a **SystemSubroutine**, not a method
symbol: `ClassRandomizeFunction` (slang `source/ast/builtins/MiscSystemFuncs.cpp:117`,
registered by `addSystemMethod(SymbolKind::ClassType, …)` at :461).
`CallExpression::createSystemCall` (slang `source/ast/expressions/CallExpression.cpp:491`)
pushes the receiver — when there IS one — into the argument buffer AHEAD of
the written arguments and always constructs the `CallExpression` with
`thisClass = nullptr`.  So for

* `o.randomize(x)`  → `arguments() = [o, x]`
* `randomize(x)`    → `arguments() = [x]`      ← **no receiver at all**

Our built-in METHOD arm in `ExprEmit.cpp` (`§ scopedBuiltinRecvIsChain1`'s
decode: "a built-in method's receiver hides in `arguments()[0]`") therefore
read `l_kind` as the receiver and built `hier_path (l_kind.randomize)`.
A ZERO-argument scope randomize had no `arguments()[0]` at all and fell
through to `noteUnsupportedAt("system method call: randomize")`, i.e. the whole
test was refused.

## 2. The decoded Surelog model

`CompileHelper::compileRandomizeCall` — Surelog `src/DesignCompile/CompileStmt.cpp:3153`,
reached from `CompileExpression.cpp:2179` (the scope form) and `:5643` (the
member form):

```cpp
method_func_call* func_call = s.MakeMethod_func_call();
func_call->VpiName("randomize");
…                                        // NO populateCoreMembers, NO VpiParent
if (fC->Type(Identifier_list) == VObjectType::paIdentifier_list) {
    VectorOfany* arguments = compileTfCallArguments(
        component, fC, Identifier_list, compileDesign,
        Reduce::No, func_call, nullptr, false);   // instance == nullptr
    func_call->Tf_call_args(arguments);
}
if (Constraint_block)
    if (UHDM::any* cblock = compileConstraintBlock(…, pexpr))
        func_call->With(cblock);
```

and `CompileHelper::compileConstraintBlock` (`CompileStmt.cpp:3181`) is four
lines:

```cpp
UHDM::constraint* cons = s.MakeConstraint();
cons->VpiParent(pexpr);
result = cons;
```

**What the with-constraint IS.**  A BARE `constraint`: no name, no span
(`populateCoreMembers` is never called), no `Constraint_items`, parent =
`pexpr`.  The MiniAmiq head prints it as
`constraint: (uvm_pkg::uvm_exhaustive_sequence::body)` — that is the dump's
SYNTHESISED `vpiFullName` walking up from an EMPTY-named object (RESUME §9's
fullname-synthesis rule), **not** the enclosing method's name stored anywhere
and **not** a reused constraint block.  `constraint::Compare`
(`UHDM/build/generated/src/constraint.cpp:133`) reads VpiName, VpiVirtual,
VpiAutomatic, VpiAllocScheme, VpiAccessType, Attributes,
VpiIsConstraintEnabled and Constraint_items — every one of them default on
golden's object, so `s.MakeConstraint()` with only `VpiParent` set is
byte-comparable-equal to it.

**The `with` block is the SHAPE DISCRIMINATOR.**  Surelog's ANTLR grammar only
produces a `paRandomize_call` node in front of a constraint block; without one
the call falls through to the ordinary `compileTfCall`.  Measured on one
golden database (MiniAmiq, uvm-1.2) and reproduced on arms A/B/G/H:

| written | golden object |
|---|---|
| `randomize(x) with { … }` | `method_func_call (randomize)`, **no VpiParent**, args, `vpiWith constraint`, span from the `randomize` token THROUGH the constraint block's `}` |
| `randomize(x)` , `randomize()` , `randomize(null)` | plain `func_call (randomize)`, VpiParent set, args, span over the written invocation |
| `o.randomize() with { … }` | `hier_path` named after the RECEIVER ALONE, holding the method_func_call + its constraint — **not this pass** (residue R0) |
| `o.randomize(x)` , `o.randomize()` | `hier_path (o.randomize)` — unchanged by this pass |
| `std::randomize(a,b)` | a bare `ref_obj` named `std::randomize` (Surelog garbage) — **not this pass** (residue R1) |

## 3. § randWithIdentListIsSuffixPaths116 — Surelog's identifier-list quirk

`compileRandomizeCall` hands the whole `paIdentifier_list` to
`compileTfCallArguments`, whose per-SIBLING walk compiles each name as if the
names that FOLLOW it were its dotted trail.  Decoded on **arm H** at two,
three and four names; for `n` names argument `k` is

* `k < n-1` — a `hier_path` named `name[k].….name[n-1]`, spanned over
  `name[k]` ALONE, holding one `ref_obj` per name from `k` to `n-1`, of which
  ONLY THE LAST carries the path's dotted name as its `VpiFullName`
  (Surelog's `if (!tmpName.empty()) ref->VpiFullName(the_name)` tail,
  `CompileExpression.cpp:5697`);
* `k == n-1` — a plain `ref_obj`.

`randomize(a,b,c)` **without** a `with` gets three plain `ref_obj`s: the quirk
is the identifier-list arm's alone.  At `n == 1` the rule degenerates to "one
ref_obj", which is the entire corpus population (all three
`uvm_sequence_builtin.svh` sites take one name), so this half is measured by
the arms, never by the rows.

## 4. § randWithArgNameIsBare116

`compileTfCallArguments(…, Reduce::No, func_call, **nullptr**, false)` passes a
NULL instance, so the with-form's argument `ref_obj` carries the BARE written
name where the with-LESS `func_call`'s carries the fully scoped one.  Measured
on the head itself: golden `ref_obj: (l_kind)` at 196:20 against our first
cut's `ref_obj: (uvm_pkg::uvm_exhaustive_sequence::body::l_kind)`.  Written
with this emitter's standing no-fullname idiom `VpiFullName(VpiName())`; an
EMPTY prefix is NOT the same thing and was refuted — `joinRef("", n)` spells
`.n`, which made arm A read `ref_obj (.k_alpha)`.

## 5. The fence (three disjuncts, each measured)

`UhdmExporter::scopeRandomizeCall116` fires only when all of:

1. `call.isSystemCall()` and `getSubroutineName() == "randomize"`;
2. `arguments().empty() || arguments()[0]->sourceRange.start() != expr.sourceRange.start()`
   — the MEMBER form's argument 0 IS the receiver and therefore starts where
   the whole call starts.  POSITIONAL, so a macro-remapped receiver cannot
   fool it;
3. no argument is an `AssignmentExpression` — `ScopeRandomizeFunction::bindArgument`
   (slang `MiscSystemFuncs.cpp:191`) binds `std::randomize`'s arguments with
   `Expression::bindLValue`; `ClassRandomizeFunction`'s are plain `NamedValue`s;
4. `rawText` at the call's own start really spells `randomize` — which also
   excludes a zero-argument `std::randomize()` and any surface this emitter
   cannot read back;
5. `methodParensWritten77` reads PARENS-FUL at that span.

Every early return is CONSERVATIVE, so nothing that converges today can
regress through the predicate.

### § parensLessScopeRandomizeIsRefObj116 — disjunct 5, and what found it

slang binds `r = randomize;` and `r = randomize();` to the SAME
`CallExpression`.  Surelog does not, and the difference is only in what was
WRITTEN.  Measured on `r10svs2repro/w4_classbuiltin.sv` (carried again as
`r10uvm77repro/v77w4_classbuiltin.sv`) — the same golden
§ classMethodParensLessStepIsRefObj77 was decoded from:

```
line 15  r  = randomize;         golden: ref_obj (work@w4::f::randomize) @15:10-15:19
line 16  r  = r + randomize();   golden: func_call (randomize)           @16:14-16:25
```

The first cut of this law minted a `func_call` for line 15 as well — a
MOVED-WRONG cell **on an earlier pass's arm**, invisible to every corpus gate
(no corpus source writes a parens-less receiver-less randomize) and caught
ONLY by the wide boundary gate over a copy of the whole probe tree.  With the
gate in place that arm moves at exactly ONE object, line 16's, and that object
is byte-identical to golden's.

`methodParensWritten77` already accepts a following `with`
(§ parensProbeSkipsTriviaAndWith77), which is exactly right: `randomize with
{ … }` IS a `randomize_call` in Surelog's grammar and must keep firing.  Arm I
measures the whole surface — parens-less, parens-ful, parens-less + `with`,
parens after a block comment, parens on the NEXT LINE, and parens-ful with a
name.

## 6. Arms (`grid116.sh <arm> <pristine> <patched> <workdir>`; both views)

`GRID.txt` — whole-dump diff lines against golden (the constant 4 is the
`Restored design` header line, i.e. BYTE-IDENTICAL):

```
ARM      VIEW      PRIS      PAT
g116_a   def         56        4     scope randomize + with, twice (the head's shape)
g116_a   elab       183       83
g116_b   def         70        4     scope randomize, NO with: 2 args / 0 args / 1 arg
g116_b   elab       213        4
g116_c   def        131      131     MEMBER form x3 + std::randomize x2  — THE FENCE
g116_c   elab       245      245
g116_d   def         66       21     while / ternary / void'() positions
g116_d   elab       171       81
g116_e   def          4        4     a user function NAMED randomize      — THE FENCE
g116_e   elab        46       46
g116_f   def        142       26     five expression positions of the with-form
g116_f   elab       245       83
g116_g   def        106        4     with-block over a local, the arg, a property, inside{}
g116_g   elab       156       53
g116_h   def        314        4     identifier lists of 2/3/4 names, and randomize(null)
g116_h   elab       712      163
g116_i   def         64       14     the PARENS-LESS surface (six spellings)
g116_i   elab       161       21
```

`g116_b` and `g116_h` were **SLANG_REJECT on the pristine binary** (the
zero-argument form); both are byte-identical to golden now.

`GRID.residues.txt` holds every residual diff.  The DEF-view residues that
remain, all with ZERO corpus population:

* **R2 — `g116_f` cells `two` and `five`.**  When the with-form randomize is
  the DIRECT if-condition, or an operand under a ternary, golden's
  `method_func_call` DOES carry a VpiParent and its argument IS scoped — the
  opposite of the regime this law models.  The two regimes correlate exactly
  (parentless+bare vs parented+scoped).  100% of the corpus population is
  `if (!randomize(x) with {…})`, the parentless+bare regime, which arms A, F/`one`,
  F/`three`, F/`four`, G and H all reproduce byte-for-byte.
* **R4 — `g116_d` cell `void'(randomize(x) with {…})`.**  Surelog REJECTS it
  (`[ERR:CP0332] Function "%exobj" is not defined for variable "this"`) and
  emits an UNNAMED `func_call`.  The cell was wrong before this pass and is
  wrong after it, differently; it is a design golden itself errors on.
* The ELAB-view residues are the elaborator re-parenting and re-scoping every
  such object; our elab view is produced by a different phase and is out of
  this law's reach.  Every arm's elab distance still FELL.

`GRID.txt` positive control: `g116_c` and `g116_e` are unchanged to the byte,
which is what says the fence can be seen to hold rather than merely asserted.

## 7. Census

`cenall116.sh` + `cen116.py` + `join116.py` — the randomize census over the
NINE UVM cells (SeqDriver×2, SimpleUVM×2, Scoreboard/default, MiniAmiq×2,
BuildUVMPkg×2; Scoreboard/testflags has no golden), read off `uhdm-dump` text
trees so no row can name an object the judge cannot see (uvm97's AllObjects
trap).  Keys are `<nearest named ancestor>@<START of the object>` — START
only, because golden's call runs through the constraint block's `}` while ours
stopped at the invocation's `)` and an end-bearing key would refuse to join
the two sides of the very cell being measured.  Never the file (our objects
carry an EMPTY VpiFile).  The join is a MULTISET join (the DEF and ELAB views
emit the same site twice).

A `constraint` has no name and no span and its nearest named ancestor is the
call named `randomize`, so the plain key would collapse EVERY constraint in a
database into one cell; the key for those rows is the constraint's SYNTHESISED
fullname instead.  That is a parent-chain reading, which is what it should be:
if our parenting of a constraint ever stopped matching golden's, the two sides
would stop joining and the census would SAY so rather than hide it.

Pristine (`CENSUS.pristine.txt`), patched (`CENSUS.patched.txt`), totals
(`CENSUS.totals.txt`):

```
                          AGREE  DIFFER  GOLD-ONLY  OURS-ONLY
SeqDriver     pristine       46      10         24         32
              patched        60      10         10         10
SimpleUVM     pristine       26       6         16         20
              patched        36       6          6          6
Scoreboard    pristine       26       6         16         20
              patched        36       6          6          6
MiniAmiq      pristine       47      11         24         32
              patched        61      11         10         10
BuildUVMPkg   pristine       22       3         12         16
              patched        26       3          8          8
SimpleConstraint  pristine    2       2          0          0
              patched         2       2          0          0     <- unchanged
```

Every DIFFER that remains is the member-form hier_path END SPAN, which no
generated Compare reads (RESUME §9: never VpiFile/line/col) — residue R3.

`score116.py` classifies every (FORM, KEY) cell across the two runs, asserting
first that the GOLDEN side is identical in both (a scorer that does not re-read
golden cannot tell a golden change from a mover).  `SCORE.movers.txt`:

```
SeqDriver.default          TO-GOLDEN=21 AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=20 EQUAL-BOTH=20
SeqDriver.testflags        TO-GOLDEN=21 AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=20 EQUAL-BOTH=20
SimpleUVM.default          TO-GOLDEN=17 AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=14 EQUAL-BOTH=16
SimpleUVM.testflags        TO-GOLDEN=17 AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=14 EQUAL-BOTH=16
Scoreboard.default         TO-GOLDEN=17 AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=14 EQUAL-BOTH=16
MiniAmiq.default           TO-GOLDEN=21 AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=21 EQUAL-BOTH=21
MiniAmiq.testflags         TO-GOLDEN=21 AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=21 EQUAL-BOTH=21
BuildUVMPkg.default        TO-GOLDEN=6  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=9  EQUAL-BOTH=13
BuildUVMPkg.testflags      TO-GOLDEN=6  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=9  EQUAL-BOTH=13
SimpleConstraint.default   TO-GOLDEN=0  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=2  EQUAL-BOTH=2
SimpleConstraint.testflags TO-GOLDEN=0  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=2  EQUAL-BOTH=2
```

AWAY-GOLDEN 0 and STILL-WRONG 0 on all eleven cells: every cell this pass moved
became EQUAL to golden, and nothing that was equal stopped being equal.

## 8. Residues and R0

* **R0 — the MEMBER form carrying a constraint block.**
  `seq_or_item.randomize() with {…}` (`uvm_sequence_library.svh:299`) and
  `item.randomize() with {…}` (`uvm_simple_sequence.svh:204`), both inside UVM
  macro expansions.  Golden names the enclosing `hier_path` after the
  RECEIVER ALONE (`seq_or_item`, not `seq_or_item.randomize`) — and hier_path
  `VpiName` IS read by Compare — and hangs the same bare `constraint` off a
  SPANLESS `method_func_call`.  Ours keeps `seq_or_item.randomize` and drops
  the constraint; our method_func_call's span (`299:66–778:9`) shows the
  macro surface this needs to survive.  This is the SAME `withExpr9` naming
  regime the array-locator `with` already has in this arm, reached from
  `RandomizeCallInfo::inlineConstraints` instead of `getIteratorInfo()`.
  4 GOLD-ONLY + 4 OURS-ONLY census groups per UVM cell.
* **R1 — `std::randomize`.**  Golden emits a bare `ref_obj` named
  `std::randomize` for `st = std::randomize(a,b)`, and for
  `std::randomize(a) with {…}` a `ref_obj` named `std` bound to a PHANTOM
  `logic_net work@top_c.std` (arm C cells c4/c5).  A separate Surelog head.
  Zero comparable corpus population: every corpus source that spells
  `std::randomize` is already SLANG_REJECT/SURELOG_FAIL/DEFERRED for an
  unrelated, earlier reason (AmiqEth, CoresSweRV, CoresSweRVMP,
  Earlgrey_Verilator_01_05_21, Google, IbexGoogle).
* **R2** — the parented+scoped with-form regime (§6).
* **R3** — the member form's hier_path END span (golden runs through the
  written `()`, ours stops at the `(`); 6 source sites per UVM cell plus both
  SimpleConstraint sites.  Judge-invisible.
* **R4** — `void'(randomize(x) with {…})`, which Surelog itself errors on (§6).
* **R5** — a PRE-EXISTING defect this pass's boundary gate DISCOVERED and did
  not cause.  `r10buvm22repro/g22.sv:70` `typedef C22 ka_cls_t[string];` emits
  its range as `[0 : <N> - 1]` where `N` is an ADDRESS: 22408601 (0x155ed99)
  on the pristine binary, 22412697 (0x155fd99) on the patched one — one page
  apart, deterministic per binary across repeated runs, and present at
  09dec24.  Any code change that shifts the image perturbs it.  It reaches NO
  corpus database (byteverify: 0/1358 on uhdm2rtlil, and all 9 surelog movers
  are this law's, predicted by name), so it is out of this pass's scope and is
  logged here for whoever takes the associative-array range emission next.
* **R6** — the parens-LESS receiver-less `randomize` (arm I cell 1, w4 line
  15).  Golden makes it a `ref_obj` named `randomize` with the enclosing
  method's scoped fullname; we emit nothing at all and note it unsupported.
  Unchanged by this pass (the fence's disjunct 5 keeps it on the pristine
  path); a one-object law of its own.

## 9. Files

| file | what |
|---|---|
| `g116_a..i.sv` | the nine arms |
| `grid116.sh` | builds golden+pristine+patched for one arm in BOTH views, every command with its OWN rc in `cmds.txt` |
| `cen116.py` | the streaming randomize census over a `uhdm-dump` text tree |
| `cenall116.sh` | runs it over both sides of every named cell of a verify_golden workdir |
| `join116.py` | the MULTISET join of two censuses |
| `PREDICTION.txt` | the mover prediction, written from pristine databases only |
| `GRID.txt`, `GRID.residues.txt` | the arm grid and every residual diff |
| `CENSUS.pristine.txt`, `CENSUS.patched.txt`, `CENSUS.totals.txt` | the census, both binaries |
| `score116.py`, `SCORE.movers.txt` | the TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG score |
| `GATES.txt` | the full gate battery output |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the head before and after |
| `bound116.sh` | the wide boundary gate (a COPY of the whole probe tree, no path filter, arms on fd 3, PROCESSED asserted) |
| `BOUNDARY.txt` | its three runs |
| `rowheads.sh ct8rows.sh byteverify.sh canaries.sh ctcan2.sh canaudit.sh` | the standing gates, copied |
