# r10uvm119 — § memberRandomizeWithIsRecvPath119

**The head.** All NINE comparable UVM row-modes — `SeqDriver`, `SimpleUVM`,
`MiniAmiq`, `BuildUVMPkg` in both modes and `Scoreboard/default` — stood at
**76 cmp lines, ONE head, and the same ONE object** at `7c9d641`.  It is
§ `scopeRandomizeIsBareCall116`'s residue **R0**: uvm-1.2
`src/seq/uvm_sequence_library.svh:777`

```systemverilog
  `uvm_rand_send(seq_or_item)
```

which expands through `src/macros/uvm_sequence_defines.svh:299`

```systemverilog
  if ((__seq == null || !__seq.do_not_randomize) && !SEQ_OR_ITEM.randomize() with CONSTRAINTS ) begin \
```

| side | object |
|---|---|
| LHS (golden) | `hier_path (seq_or_item)` @299:54–**299:85**, elements `ref_obj (seq_or_item)` @299:54–299:65 + `method_func_call (randomize)` with **NO SPAN AT ALL** carrying `vpiWith` → a bare `constraint` parented at the `!` operation |
| RHS (ours) | `hier_path (seq_or_item.randomize)` @299:54–**299:75**, elements `ref_obj (seq_or_item)` + `method_func_call (randomize)` @299:66–**778:9**, and NO constraint anywhere |

Four defects on one object: the path NAME (which `hier_path::Compare` READS — a
TEXT law), the path SPAN, a CORRUPT call span whose end lands 479 lines away in
the macro-argument buffer, and a missing `vpiWith`.

`head_pris_SeqDriver.cmp` / `head_pat_SeqDriver.cmp` are the official
`uhdm-cmp` head before and after; `head_pris_row_*.cmp` / `head_pat_row_*.cmp`
are `rowheads.sh`'s per-row-mode logs.

---

## 1. The decoded Surelog model

`CompileHelper::compileRandomizeCall` (Surelog
`src/DesignCompile/CompileStmt.cpp:3153`) is reached from **two** places.
uvm116 decoded the SCOPE arm (`CompileExpression.cpp:2179`).  **This is the
MEMBER arm, `CompileExpression.cpp:5643`**, and it is taken from *inside* the
dotted-path builder's `while (dotedName)` loop.  Everything about golden's
object falls out of **which branch of that loop the written surface lands in**:

```cpp
while (dotedName) {
  VObjectType dtype = fC->Type(dotedName);
  if (dtype == VObjectType::slStringConst) {
      the_name.append(".").append(fC->SymName(dotedName));   // <-- THE NAME
      …
  } else if (dtype == paSelect || …) { … }
  NodeId lookAhead = fC->Sibling(dotedName);
  if ((fC->Type(dotedName) == paMethod_call_body) ||
      (fC->Type(lookAhead) == paList_of_arguments)) {
      …
      if (fC->Type(randomize_call) == paRandomize_call) {
          fcall = compileRandomizeCall(component, fC, fC->Child(randomize_call),
                                       compileDesign, pexpr);   // NO populateCoreMembers
      } else { … fC->populateCoreMembers(method_name_node, method_name_node, fcall); … }
      elems->push_back(fcall);
      …
      if (fcall != nullptr) fcall->VpiParent(path);
  }
  …
}
…
path->VpiName(the_name);                                        // <-- THE NAME
```

* **`o.randomize(x)` — NO constraint block.** Surelog's ANTLR grammar builds no
  `paRandomize_call` node, so the method name arrives as a plain
  `slStringConst` with a `paList_of_arguments` look-ahead.  The **appending**
  branch runs, `the_name` becomes `o.randomize`, and the ordinary
  `method_func_call` gets its span from `populateCoreMembers`.
  **WE ALREADY EMIT EXACTLY THAT** — arm `g119_b` measures four spellings
  (zero / one / two names and `null`) and the only residues are the path END
  span and a dump-synthesised fullname, neither read by any generated Compare.
  This law must not touch it, and that is what the `inlineConstraints`
  disjunct of the predicate is for.

* **`o.randomize() with { … }` — a constraint block.** The grammar emits
  `paMethod_call_body > paBuilt_in_method_call > paRandomize_call`, whose type
  is **not** `slStringConst`, so the appending branch is **skipped entirely**
  and `the_name` still holds the **RECEIVER ALONE** when `path->VpiName(the_name)`
  runs at the bottom of the loop.  That is the whole naming law.

The other three fields come from `compileRandomizeCall` itself, nine lines
long: it sets `VpiName("randomize")`, the arguments and the `With` and calls
**neither `populateCoreMembers` nor `VpiParent`** — so golden's
`method_func_call` is **SPAN-LESS** (the `VpiParent` it does carry is the
caller's `fcall->VpiParent(path)` tail).  The `With` is
`compileConstraintBlock`'s (`CompileStmt.cpp:3181`) four-line **bare
`constraint`**: no name, no span, no `Constraint_items`, `VpiParent(pexpr)`.
`constraint::Compare` (`UHDM/build/generated/src/constraint.cpp:133`) reads
VpiName, VpiVirtual, VpiAutomatic, VpiAllocScheme, VpiAccessType, Attributes,
VpiIsConstraintEnabled and Constraint_items — every one of them default on
golden's object, so `s.MakeConstraint()` with only `VpiParent` set is
byte-comparable-equal to it.  The hier_path's own span belongs to the path
builder and runs **through the constraint block's `}`**.

### The two questions the brief asked, answered by measurement

**The member form WITHOUT a with-block keeps the DOTTED name** — `g119_b`,
golden and ours both `hier_path (recv_b.randomize)` at every arity.  uvm116's
table left this "hier_path — untouched"; it is untouched because it is already
right.

**The constraint's `VpiParent` is always the SAME object as the hier_path's**
— measured identical in all eight expression positions of `g119_f`
(`operation` under `!`, `begin` for a direct if-condition, `return_stmt` for a
`return`).  So `cons->VpiParent(parent)` at our site is exactly right with no
position rule at all.

---

## 2. § memberRandNullDropsArgsAndWith119 — the one surface that gets neither

`compileRandomizeCall` reads its own first node twice:

```cpp
NodeId With;
if (fC->Type(Identifier_list) == paIdentifier_list) With = fC->Sibling(Identifier_list);
else if (fC->Type(Identifier_list) == paWITH)       With = Identifier_list;
NodeId Constraint_block = fC->Sibling(With);
```

An argument list that is **neither an identifier list nor an immediate `with`**
leaves `With` invalid, `Constraint_block` invalid, and the constraint is never
built — and the `Tf_call_args` guard above it drops the arguments for the same
reason.  The only such surface SystemVerilog allows here is
`o.randomize(null) with { … }`, and golden emits it with **NO `vpiArgument`
and NO `vpiWith`** while KEEPING the receiver-only name and the through-block
span, because that span belongs to the path builder.  Measured on `g119_d`
cell `null_with` (line 34): `hier_path (p_d), line:34:10, endln:34:52`.

## 3. § randWithIdentListIsSuffixPaths116 — the member form's half

uvm116 decoded Surelog's identifier-list quirk on the SCOPE form; it is the
same code and it applies here.  `compileRandomizeCall` hands the whole
`paIdentifier_list` to `compileTfCallArguments`, whose per-SIBLING walk
compiles each name as if the names that FOLLOW it were its dotted trail.  For
`n` written names, argument `k` is

* `k < n-1` — a `hier_path` named `name[k].….name[n-1]`, spanned over
  `name[k]` **alone**, holding one `ref_obj` per name from `k` to `n-1`, of
  which **only the last** carries the path's dotted name as its `VpiFullName`;
* `k == n-1` — a plain `ref_obj`.

Re-measured on the member form at `g119_d` cell `two_names`
(`p_d.randomize(d_alpha, d_beta) with { … }`), where golden's first argument is
`hier_path (d_alpha.d_beta)` spanned 30:24–30:31 — over `d_alpha` alone.  The
written names start at argument **1** here (argument 0 is the receiver), which
is the only difference from the scope-form loop.

## 4. The element fullname regime, and where it parts from uvm116

Golden's receiver elements: **every name but the last is bare, the last carries
no `VpiFullName` at all** and has its scoped text SYNTHESISED by the dump from
the parent chain.  That is Surelog's loop structure showing through, not a
choice: the earlier names are pushed by the `slStringConst` branch, which sets
`ref->VpiFullName(tmpName)` — the bare name, i.e. this emitter's no-fullname
idiom — while the last is pushed by the trailing `paSelect` branch, which sets
none.  Measured on `g119_d` cell `chain_recv`: golden prints `(h_d)` bare and
`(work@outer_d::run_d::q_d)` scoped, in one path.

§ `randWithArgNameIsBare116` needed the same correction and for a decodable
reason: the SCOPE form's `method_func_call` has **no `VpiParent`**, so the dump
has no chain to synthesise from and prints the argument's bare name (golden
`ref_obj: (l_kind)`); the MEMBER form's call **is** parented, so the same unset
field is synthesised **through the receiver-only path name** (golden
`work@outer_d::run_d::p_d::d_alpha`).  We cannot leave the field unset —
`emitExpr` always writes one — so we write the text synthesis produces.
`VpiFullName` is read by no generated Compare (RESUME §9), so this half is
dump fidelity, which is exactly what keeps the census and the boundary diff
honest.

## 5. The fence (five disjuncts, each measured) — and NO TEXT ANCHOR

`UhdmExporter::memberRandomizeWith119` fires only when all of:

1. `call.isSystemCall()` and `getSubroutineName() == "randomize"` — a USER
   function named `randomize` is not a system call (`g119_c`'s `randomize_x`,
   and uvm116's arm E);
2. the emitter's own method `name` is `randomize`;
3. **MEMBER position, POSITIONALLY**: `recv.sourceRange.start() ==
   expr.sourceRange.start()`.  `createSystemCall` (slang
   `CallExpression.cpp:491`) pushes the receiver into the argument buffer ahead
   of the written arguments, so for `o.randomize(…)` argument 0 IS the receiver
   and its range starts where the whole call starts.  This is exactly
   § `scopeRandomizeIsBareCall116`'s disjunct 2 **inverted**: that law owns the
   receiver-less form, this one owns the member form, and the two predicates
   cannot both fire on one call;
4. **no argument is an `AssignmentExpression`** — `ScopeRandomizeFunction::bindArgument`
   (slang `MiscSystemFuncs.cpp:191`) binds `std::randomize`'s arguments with
   `Expression::bindLValue`, `ClassRandomizeFunction`'s are plain `NamedValue`s.
   A second, independent fence on uvm116's residue R1;
5. the call's `RandomizeCallInfo::inlineConstraints` is non-null **and has
   syntax**.  This is the SHAPE DISCRIMINATOR (§1) and the source of the span.

**There is deliberately NO text anchor, and the cost of one was measured.**
Every disjunct above is read off slang's bound AST, and golden's answer is
uniform across every spelling of the shape:

| spelling | arm | golden |
|---|---|---|
| parens-ful `o.randomize() with {…}` | a, d, e, f, g | the law |
| parens-LESS `o.randomize with {…}` | `g119_h` cell 1 | the law — IEEE 1800 A.2.10 makes the argument list optional and the `with` alone is the grammar's trigger, so unlike § `scopeRandomizeIsBareCall116`'s disjunct 5 this law needs **no parens probe at all** |
| SPACED `o . randomize() with {…}` | `g119_h` cell 3 | the law — an `anchorOk77`-style window at `recv.end()+1` reads `. random` and would refuse a cell golden gets right |
| MACRO-EXPANDED | the whole corpus | the law |

A first cut of this law DID carry the anchor, and the measurement is exact:
**BuildUVMPkg (the pp_output, no macros) moved and the other four UVM databases
did not move at all.**  `uvm_rand_send` writes
`!SEQ_OR_ITEM.randomize() with CONSTRAINTS`, and the receiver's source range
ends in the macro-ARGUMENT buffer while the method token lives in the
DEFINITION buffer — arithmetic across that boundary is precisely what corrupted
our pristine span here (`299:66–778:9`).  A window built the same way reads
garbage and refuses.  The refusal that IS kept is on the SPAN, the only thing
still derived from source positions: a constraint bound without syntax answers
FALSE rather than inventing an end.

---

## 6. Arms (`grid119.sh <arm.sv> <pristine> <patched> <workdir>`; both views)

`GRID.txt` — whole-dump diff lines against golden.  `GRID.residues.txt` holds
every residual diff; `GRID.pristine-vs-patched.txt` is the fence's POSITIVE
CONTROL (which arms the law provably does not reach).

```
ARM      VIEW     PRIS    PAT
g119_a   def        56     20    the head's shape, two receivers
g119_a   elab      148     76
g119_b   def        52     52    THE FENCE: member randomize, NO with-block
g119_b   elab      236    236
g119_c   def        25     25    THE FENCE: uvm116's scope form, std::, a user fn named randomize
g119_c   elab       85     85
g119_d   def       137     14    this. / chained h.q. / identifier lists / randomize(null) with
g119_d   elab      215     92
g119_e   def       128     20    what the with-block references, incl. an EMPTY block
g119_e   elab      166     58
g119_f   def       152      8    EIGHT expression positions
g119_f   elab      354     66
g119_g   def       144     36    1/2/3 sites per scope; name case, length, order
g119_g   elab      298    190
g119_h   def       259     75    parens-less+with, indexed receiver, SPACED, chained+ident list, 3 names, module scope
g119_h   elab      773    543
```

`g119_b` and `g119_c` are BYTE-IDENTICAL between the two binaries in both
views, which is what says the fence can be **seen** to hold rather than merely
asserted; every other arm moves.  Arms A, D, E, F are at their floor — the
residue is the pre-existing top-level typespec **ORDER** difference, unrelated
to this law, and every randomize object in them is byte-identical to golden.

**Arm G's non-self-confirming design.** RESUME §9 warns that an arm naming
everything `a_t/b_t/c_t` over `A/B/C` is self-confirming.  `g119_g` therefore
varies receiver spelling (`zzz`, `Bee`, `a`, `q7`, `X`,
`m_long_receiver_name_9`), CASE, LENGTH, ORDER within the scope, and the
NUMBER of sites per scope (one, two, three).

---

## 7. Census, prediction and score

`cen119.py` + `cenall119.sh` + `join119.py` — read off `uhdm-dump` text trees,
so no row can name an object the judge cannot see (uvm97's `AllObjects` trap).
Keys are `<nearest named ancestor>@<START of the object>` — START only, because
golden's path runs through the constraint block's `}` while ours stopped at the
invocation's `)`, and an end-bearing key would refuse to join the two sides of
the very cell being measured.  Never the file (our objects carry an EMPTY
`VpiFile`).  The join is a MULTISET join (the DEF and ELAB views emit the same
site twice).

**Why not uvm116's committed `cen116.py`.**  Its `interesting()` emits a
`hier_path` when *the path's own name* mentions `randomize` — which is exactly
what this pass REMOVES.  Every cell the law touches would silently leave the
census and the totals would read "fewer differing rows" for the wrong reason.
That is uvm109's rule (a pass that REMOVES objects must score one-sided sets),
so `cen119.py` decides from the path's ELEMENTS instead — does it carry a step
named `randomize`? — a property no naming law of ours can change, and the
decision is taken at POP time rather than when the name is read.

`PREDICTION.txt` is written from **pristine databases alone**, before the
patched binary existed: **67 moving paths over 9 cells**, at exactly TWO source
sites per database (`uvm_sequence_library.svh:299` and
`uvm_simple_sequence.svh:204`; `56967`/`56980` in BuildUVMPkg's pp_output),
replicated per package copy and per view.

`score119.py` asserts FIRST that the GOLDEN side of every cell is byte-identical
in the two runs — a scorer that does not re-read golden cannot tell a golden
change from a mover — and it is (9/9).  `SCORE.movers.txt`:

```
---- PARENT-BLIND (the judge's view) ----
BuildUVMPkg.default        TO-GOLDEN=7  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=9  EQUAL-BOTH=16
BuildUVMPkg.testflags      TO-GOLDEN=7  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=9  EQUAL-BOTH=16
MiniAmiq.default           TO-GOLDEN=8  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=26 EQUAL-BOTH=33
MiniAmiq.testflags         TO-GOLDEN=8  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=26 EQUAL-BOTH=33
Scoreboard.default         TO-GOLDEN=7  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=18 EQUAL-BOTH=23
SeqDriver.default          TO-GOLDEN=8  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=23 EQUAL-BOTH=33
SeqDriver.testflags        TO-GOLDEN=8  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=23 EQUAL-BOTH=33
SimpleUVM.default          TO-GOLDEN=7  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=18 EQUAL-BOTH=23
SimpleUVM.testflags        TO-GOLDEN=7  AWAY-GOLDEN=0 STILL-WRONG=0 UNTOUCHED=18 EQUAL-BOTH=23

TOTAL  TO-GOLDEN=67  AWAY-GOLDEN=0  STILL-WRONG=0  UNTOUCHED=170  EQUAL-BOTH=233
```

**AWAY-GOLDEN 0 and STILL-WRONG 0 on all nine cells, and TO-GOLDEN=67 is
exactly the number `PREDICTION.txt` named a priori.**

The scorer also prints a STRICT score, in which constraints are keyed on the
dump's SYNTHESISED fullname — a PARENT-CHAIN reading.  There it reads
AWAY-GOLDEN=4 / STILL-WRONG=4, and those eight rows are **four objects**, one
per database that carries a SECOND package copy (SeqDriver's `adpcm_pkg`,
MiniAmiq's `svaunit_pkg`), differing from golden in `VpiParent` alone —
residue R1 below.  The census was built to say exactly this rather than hide
it, and it did.

`CENSUS.totals.txt` — SimpleUVM, Scoreboard and BuildUVMPkg reach
**GOLD-ONLY 0 / OURS-ONLY 0**, and the constraint POPULATION now matches golden
exactly in every cell (8/8, 6/6, 6/6, 8/8, 4/4) where pristine was short by
5, 3, 3, 5 and 4.

---

## 8. Gates

`GATES.txt` carries the full battery.  In one line: goldens **23/0** with the
`/bin/false` negative control at **0/23**; uhdm2rtlil **679/50/2** with
`ct8rows` PASS in both modes against the committed baseline and against this
pass's own pristine sweep; the surelog corpus **0 differing rows over 1588**
with an IDENTICAL status histogram and **no row converted** (`results/*.csv` is
untouched); `byteverify SELFCHECK=1` **0/1358** on uhdm2rtlil and **9/956** on
surelog, the 9 being exactly the nine UVM row-modes the prediction named;
canaries `ok=52 changed=0` and `ok=8 changed=0`, both `ctcan2` PASS, `canaudit`
**UNCOVERED=0 FENCE-BREACH=0**; every protected database byte-identical with
SVSwitch pinned at `4842211c4030` and YosysVerx at `6ccda350c24a`.

`ATTRIBUTION.txt` — each of the nine movers' ORDER-BLIND (sorted,
path-normalised) whole-dump diff, with every `line:L:C` it mentions checked
against the predicted sites: **OFF-SITE-POSITIONS = 0 on all nine.**  Sorting
is what makes the read valid on `Scoreboard/default`, which is a ~50/50 order
COIN per invocation.

`BOUNDARY.txt` — `bound119.sh` over a COPY of the whole probe tree, no path
filter, arms on fd 3, children `</dev/null`, PROCESSED asserted, scratch keyed
on the RELATIVE path, and a FENCED skip (`fenced119.sh`, which READS the four
names out of `canaudit.sh` rather than spelling them, and whose positive and
negative controls are both exercised).  Three runs:

```
MODE=file VIEW=def    PROCESSED=3696 LISTED=3696 FENCED=0 DIFFER=11 REJECT 139/139
MODE=file VIEW=elab   PROCESSED=3696 LISTED=3696 FENCED=0 DIFFER=11 REJECT 153/153
MODE=dir  VIEW=def    PROCESSED=1544 LISTED=1544 FENCED=0 DIFFER=10 REJECT 123/123
```

Rejects are SYMMETRIC in every run, so nothing became newly rejected or newly
accepted.  Six of the eleven differing arms are this pass's own.  The other
five are attributed:

* **`r10uvm116repro/g116_c.sv`, `r10uvm77repro/v77x1_randwith.sv`,
  `r10v116repro/v116_p.sv`** — each holds a member randomize-WITH cell, i.e.
  this law's own business, and each moves **toward** golden: 140→122, 94→58,
  145→121 in the def view (236→200, 156→84, 261→213 in elab).
* **`r10buvm22repro/g22.sv`** — § `scopeRandomizeIsBareCall116`'s residue R5,
  verbatim: `typedef C22 ka_cls_t[string]` emits its range as an ADDRESS
  (`22429113` → `22433209`, one page apart), deterministic per binary, present
  at `09dec24`, perturbed by ANY change that shifts the image.  Reaches no
  corpus database.
* **`r10v116repro/v116_v.sv`** — residue R5 below.

The five dir-mode-only directories (`r10uvm117repro`, `r10uvm75repro`,
`r10uvm76repro`, `r10v109repro`, `r10v117repro`) contain **no `randomize` at
all**.  Their ORDER-BLIND diff is **0** — no object changed, only the emission
ORDER of the top-level task/func list — and a **PRISTINE-vs-PRISTINE control
run** (the same binary against itself, no code change) flips four of the five.
They are RESUME §9's documented nondeterminism, not this patch.

---

## 9. Residues and R0

* **R0 — the next head, and it is TWO heads.**  Every UVM row-mode's new head
  is one of two objects, neither related to randomize.  `SeqDriver` and
  `MiniAmiq` (50 cmp lines): golden folds `uvm_pkg`'s
  `uvm_revision_string::uvm_revision` to a STRING constant `"UVM.1.2"` at
  `uvm_pkg.sv:34:10` while we emit a `ref_obj` bound to the parameter's
  constant.  `SimpleUVM`, `Scoreboard` and `BuildUVMPkg` (13 cmp lines):
  `LHS: <null>` against a surplus `method_func_call (new)` of ours — a
  one-sided object, so RESUME §9's SafeCompare rule applies (read the owner
  kind's generated `Compare` before naming the field).
* **R1 — the constraint's `VpiParent` in a SECOND package copy.**  In the two
  databases that carry a duplicated UVM package (SeqDriver's `adpcm_pkg`,
  MiniAmiq's `svaunit_pkg`) golden's constraint is parented at the
  `method_func_call` — the shape Surelog's ELABORATOR produces, and the shape
  our own elab re-emit produces on arm A — while ours is parented at the
  enclosing operation in both copies.  ONE object per such database, four in
  all.  `VpiParent` is read by NO generated Compare (RESUME §9), which the
  official judge confirms: the new heads are not constraints.  A blanket switch
  to call-parenting would break the HOME-package copy, where golden really does
  parent at the operation, so this needs its own decode of the hoisted-copy
  regime (`classBodyHomePkg75` is the likely signal) and its own arm.
* **R2 — the member form WITHOUT a with-block: the path END span and the
  argument's synthesised fullname.**  Golden runs the path through the written
  `()` and scopes the argument through the DOTTED path name
  (`work@drv_b::run_b::recv_b.randomize::q_one`); ours stops at the `(` and
  scopes through the enclosing subroutine.  Six source sites per UVM cell.
  PRE-EXISTING, judge-invisible, untouched by this pass (this is uvm116's R3).
* **R3 — an INDEXED receiver.**  `arr[1].randomize() with { … }` (`g119_h`
  cell 2): golden's `bit_select` is named `arr_h`, spans the INDEX token
  (24:16–24:17) and has its scoped fullname synthesised; ours is named
  `arr_h[1]`, spans the base name and sets the fullname explicitly.  The
  hier_path NAME — the only field Compare reads here — already agrees.  Zero
  corpus population.
* **R4 — a module-scope identifier list mints no phantom net.**
  `mod_h.randomize(h_b) with { … }` written in a module (`g119_h` line 44):
  golden's late-binding pool MINTS an implicit `logic_net (work@top_h.h_b)` and
  binds the argument to it; we leave the argument unbound.  This is the
  § `withIterRefBindsHoistNet75` mechanism, not this law's.  Zero corpus
  population.
* **R5 — a PARENTHESISED receiver has no golden at all.**
  `(h_one).randomize() with { … }` (`r10v116repro/v116_v.sv:16`) is **not in
  Surelog's `randomize_call` grammar**: surelog exits rc=3 with 10 SYNTAX
  errors and produces NO database.  The arm was refused before this pass and is
  refused after it; there is no golden object for the cell to be right or wrong
  against.  Zero corpus population.
* **R6 — `std::randomize`** stays § `scopeRandomizeIsBareCall116`'s residue R1,
  fenced out here twice over (positionally and by the `AssignmentExpression`
  test) and byte-identical in `g119_c`.

---

## 10. Files

| file | what |
|---|---|
| `g119_a..h.sv` | the eight arms |
| `grid119.sh` | builds golden + pristine + patched for one arm in BOTH views, every command with its OWN rc in `cmds.txt` |
| `cen119.py` | the streaming member-randomize census over a `uhdm-dump` text tree |
| `cenall119.sh` | runs it over both sides of every named cell of a verify_golden workdir |
| `join119.py` | the MULTISET join of two censuses (uvm116's join, reused unchanged) |
| `pred119.py`, `PREDICTION.txt` | the a-priori mover prediction, from pristine databases only |
| `score119.py`, `SCORE.movers.txt` | the STRICT and PARENT-BLIND TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG score |
| `attrib119.sh`, `ATTRIBUTION.txt` | each mover's ORDER-BLIND diff, classified by SOURCE POSITION |
| `bound119.sh`, `fenced119.sh`, `BOUNDARY.txt` | the wide boundary gate, its fence guard, and the three runs plus the pristine-vs-pristine control |
| `GRID.txt`, `GRID.residues.txt`, `GRID.pristine-vs-patched.txt` | the arm grid, every residual diff, and the fence's positive control |
| `CENSUS.pristine.txt`, `CENSUS.patched.txt`, `CENSUS.totals.txt` | the census, both binaries |
| `GATES.txt` | the full gate battery output |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the official `uhdm-cmp` head before and after, per row-mode |
| `rowheads.sh ct8rows.sh byteverify.sh canaries.sh ctcan2.sh canaudit.sh` | the standing gates, copied |
