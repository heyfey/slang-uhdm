# r10uvm175 — § `withRecvIndexedStepIsBitSelect175` — **AN INDEXED STEP OF A `with`-CLAUSE RECEIVER PATH IS A `bit_select`, EXACTLY AS IT IS WITHOUT THE CLAUSE** — the MiniAmiq ×2 40-line head CLEARED (40 → 29)

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**
and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `a0a33bb3` |
| pristine binary | md5 `9853d69d43a9cf87884b368be6f16c7f`, built from this pass's OWN worktree at a clean `a0a33bb3` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary | md5 `b49636170347560e90432e4e18a11f3b`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` — ONE gate expression (`idxSteps74`) and its decode, inside the built-in method arm's path builder.  Nothing else. |
| probe surface | `tools/probe/r10uvm175repro/` only |
| docs | `RESUME.md` §3b — the MiniAmiq row, refreshed with the head this landing produced (it rides with the code, per the standing direction) |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **MiniAmiq default and testflags, 40 cmp lines, ONE head each — CLEARED.**  40 → **29**; the head OBJECT changed (`bit_select`/`ref_obj` @233:24 → an unbound `ref_obj::Actual_group` @94:29, §10).  The two modes' cmp logs stay byte-identical to each other (md5 `dcb32643befb` → `d10e1669eb7a`). |
| every other row's head | cmp log **BYTE-IDENTICAL** — SeqDriver ×2, SimpleUVM ×2, Scoreboard, BuildUVMPkg ×2, Earlgrey_0_1 ×2, Rggen. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against the committed baselines AND this pass's own pristine sweep. |
| byte movers | **3 / 956** surelog — 2 **PREDICTED BY NAME before the patched sweep ran** and 1 the documented Scoreboard/default COIN (0 lines in the order-blind diff).  **0 / 1358** uhdm2rtlil, also predicted. |
| the corpus population | ONE cell per row-mode, `svaunit_immediate_assertion_info.svh:233` — and the whole-corpus face census proves it is the only one (see the table below). |
| the face census (956 surelog row-databases, both sides) | golden `withpaths=324 SUBSCRIPTED-REFOBJ=0 BITSEL=2 PLAIN=322`; ours PRISTINE `SUBSCRIPTED-REFOBJ=2 BITSEL=0 PLAIN=322`; ours PATCHED **identical to golden**.  FACEDIFF rows 2 → **0**.  uhdm2rtlil holds **zero** `with`-form paths at all. |
| the census (nine UVM row-modes, EVERY `hier_path`) | MiniAmiq ×2 **TOGOLD 1**, AWAY **0**, MOVEDWRONG **0**; every other row unchanged cell for cell, one-sided sets included. |
| the grids (6 arms × 2 views, 116 golden cells calibrated 0 DIFF) | **TOGOLD 76, AWAY 0, MOVEDWRONG 2, STILLWRONG 4** on the full shape; **TOGOLD 78, AWAY 0, MOVEDWRONG 0, STILLWRONG 0** on the fields a generated `Compare` actually reads.  **Four arm-views reach CMP_EQUAL.** |
| the WIDE boundary (4848 sources × 2 views) | `LISTED=4848 PROCESSED=4848 MOVED=14 ASYMMETRIC=0` — 12 are this pass's own arms and **2 are r10uvm74's `v74_edge.sv`, whose ONE moved cell is that pass's own declared residue R2, moving TOGOLD in both views.** |
| the FLOOR | r10uvm172, r10uvm124, r10uvm89, r10uvm77-79, r10uvm82-91, r10buvm3-15, r10sd8-12: **not one of their arms moved.** |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `a0a33bb3` worktree; it
came out **byte-identical to the main tree's `build/slang-uhdm`**
(`9853d69d…`), and its own 956-row surelog sweep reproduced the committed
baseline **row for row** (`ct8rows` PASS, 0 differing rows, status AND dump
column, against `results/golden_surelog.csv` and against the `a0a33bb3`
control).  `rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
MiniAmiq       default         40      1
MiniAmiq       testflags       40      1     (the two cmp logs BYTE-IDENTICAL, md5 dcb32643befb…)
```

which is r10uvm172's R0 to the byte.  The site,
`svaunit/sv/svaunit_immediate_assertion_info.svh:233`, inside
`svaunit_immediate_assertion_info::get_checks`:

```systemverilog
   virtual function svaunit_immediate_assertion_info get_checks(string a_test_name);
      foreach(checks_details[details_index]) begin
         check_index = checks_details[details_index].tests_names.find_index() with (item == a_test_name);
//                     ^col 24     ^38 ^39      ^52 ^54       ^65 ^66     ^76
```

### THE JUDGE, DECODED WITH THE OWNER-FINDER FIRST

`ct175own.cpp` (the both-sides-present form, taken from r10uvm172's
`ct172own.cpp` with `hier_path::Path_elems` and `bit_select::VpiIndex` added to
its field table).  Full output in `OWNER.r10uvm175.txt`:

```
HEAD LHS = bit_select(checks_details)@233:24-233:38#255810
HEAD RHS = ref_obj(checks_details[details_index])@233:24-233:53#187429
HEAD KINDS: LHS=bit_select RHS=ref_obj
            (DIFFERENT KIND -> BaseClass::Compare's VpiType line failed FIRST;
             no field beyond it was read)

OWNER PAIR  hier_path(checks_details[details_index].tests_names)@233:24-233:105  (BOTH SIDES)
    hier_path::Path_elems    LHS=3      RHS=3
        [0] LHS=bit_select(checks_details)@233:24-233:38   RHS=ref_obj(checks_details[details_index])@233:24-233:53
        [1] LHS=ref_obj(tests_names)@233:54-233:65         RHS=ref_obj(tests_names)@233:54-233:65
        [2] LHS=method_func_call(find_index)@233:66-233:76 RHS=method_func_call(find_index)@233:66-233:76

REFERENCE SCAN  golden hier_path(...)@233:24-233:105
                edge vpiType=700 (vector index 0)
                ours   hier_path(...)@233:24-233:105 -> vector present size 3,
                       [0] = ref_obj(checks_details[details_index])@233:24-233:53
```

**Both element lists are three long and nothing is missing on either side.**
The `Path_elems` VECTOR (relation 700) matches in size, so the vector overload
descends and compares element 0 against element 0; those two objects have
DIFFERENT `UhdmType`, so `BaseClass::Compare`'s very first line fails and no
per-kind field is read.  Elements [1] and [2] are already identical face for
face, span for span — **this head is one element wide.**

(The parent-chain probe reports `class_defn` and `function` as `no-repro` /
`NO COUNTERPART`: the ordinary `m_visited` cascade plus the fact that our
`function(get_checks)` carries a different span, both of which the descent
routes around by starting from the deepest reproducing pair.)

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

Everything below is `CompileHelper::compileComplexFuncCall`,
`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:5039`, and its ONE
`while (dotedName)` loop at `:5498-5692`.  The parse it walks was dumped with
`surelog -d ast` and is quoted here node by node.

For `checks_details[details_index].tests_names.find_index() with (item == a_test_name)`
the `name` node is `checks_details` and its sibling chain is

```
u<72> StringConst  checks_details            l<10:23> el<10:37>
u<76> Constant_expression (the index)        l<10:38> el<10:44>   -> child u<75> Constant_primary
u<77> StringConst  tests_names               l<10:46> el<10:57>
u<79> Select       (EMPTY: child u<78> Bit_select with NO child)  l<10:57>
u<95> Method_call_body -> u<94> Built_in_method_call -> u<93> Array_manipulation_call
                       -> u<81> Array_method_name -> u<80> find_index
                       -> u<82> List_of_arguments (empty)
                       -> u<92> Expression  (the `with` condition)
```

and the loop walks it in four turns:

1. **`dotedName` = the index node.**  `paConstant_expression` is one of the four
   types that enter the SELECT branch (`:5513-5516`).  `Expression` is set to
   `dotedName` itself (`:5528-5530`) and the final `else if (Expression)` arm
   (`:5578-5595`) runs:

   ```cpp
   if (expr *index = (expr *)compileExpression(component, fC, Expression,
                                               compileDesign, reduce, path,   // <- parented at the PATH
                                               instance, muteErrors)) {
     the_name += "[" + decompileHelper(index) + "]";
     bit_select *select = s.MakeBit_select();
     select->VpiName(tmpName);           // the BASE NAME alone
     select->VpiFullName(the_name);      // the CUMULATIVE written text
     select->VpiIndex(index);
     select->VpiParent(path);
     fC->populateCoreMembers(name, name, select);   // the span of the PREVIOUS name node
     elems->push_back(select);
   }
   ```

   `tmpName` is still `checks_details`, `the_name` becomes
   `checks_details[details_index]`, and `populateCoreMembers(name, name, …)`
   with `name` still the ROOT name node gives the span **23–37, the base name
   alone, ending before the `[`**.  Then `tmpName.clear()` and, because the
   node type is not `paSelect`, `break`.  At the bottom of the turn
   `name = dotedName` — which is why a MIDDLE step's `bit_select` gets the span
   of the name node BEFORE it, exactly the convention this emitter's
   `nmStart0` walk already implements (§ `builtinRecvIndexedStepIsBitSelect74`
   arm b2).

2. **`dotedName` = `tests_names`.**  `slStringConst`; `tmpName` is empty so
   nothing is pushed; `tmpName = "tests_names"`, `the_name += ".tests_names"`.

3. **`dotedName` = the EMPTY `Select`.**  Its `Bit_select` child has no child of
   its own, so every arm falls through to the trailing `else` (`:5591-5597`):
   a plain `ref_obj` named `tests_names`, spanned on the PREVIOUS name node
   (46–57), and with **no `VpiFullName` set at all** — the dump synthesises the
   scoped one from the parent chain (RESUME.md §9).

4. **`dotedName` = `Method_call_body`.**  The built-in arm (`:5612-5675`) mints
   the `method_func_call`, names it `find_index`, spans it on the method name
   node (58–68), compiles the empty argument list — and only THEN, at
   `:5665-5672`, reaches the clause:

   ```cpp
   if (with_conditions_node) {
     if (expr *with_conditions = (expr *)compileExpression(
             component, fC, with_conditions_node, compileDesign, reduce,
             pexpr, instance, muteErrors))     // <- pexpr, the STATEMENT, not the path
       fcall->With(with_conditions);
   }
   ```

**THE `with` CLAUSE IS COMPILED AFTER EVERY ELEMENT ALREADY EXISTS, AND THE
ELEMENT BUILDER NEVER READS IT.**  There is no gate on it anywhere in the
loop — not on the `bit_select` arm, not on its name, not on its span, not on
its index.  The only thing the clause changes is what `the_name` finally
becomes (the method name is never appended, because it is appended only in the
`slStringConst` branch) and where the path's span ends.  Both of those we
already reproduce.

That is the whole law: **r10uvm74's `!withExpr9` fence has no counterpart in
Surelog.**  That pass wrote it as an honest refusal — its README residue **R2**
says *"a `with`-clause over an INDEXED receiver: no measured cell exists …
needs its own arm before any code touches the combination"* — and this pass is
that arm.

### THE ONE DECLINE, ALSO MEASURED

A receiver rooted at an **implicit class handle** (`this.q[i]…`,
`super.q[i]…`) never reaches this builder: `this`/`super` is
`paImplicit_class_handle`, a different Surelog road, and golden's object there
is a DIFFERENT SHAPE — measured, not assumed:

```
source   cut = this.decks[cursor].knots.find_index() with (item == wanted);
golden   hier_path (this.decks.knots) @27:13-27:72     3 elements
             ref_obj(this)  @27:18-27:23
             ref_obj(decks) @27:18-27:23      <- the SUBSCRIPT IS DROPPED
             ref_obj(knots) @27:32-27:37      <- and so is the method element
ours     hier_path (this.decks[cursor].knots)          4 elements
```

Golden's element there is a **`ref_obj`**, so turning ours into a `bit_select`
would be a move AWAY.  The two sides already disagree in `Path_elems` SIZE
(3 vs 4), where the vector overload sets both containers and **no element field
is ever read** (RESUME.md §9) — so the whole cell belongs to the `this.`/
`super.` family (r10uvm84/85), not to this one.  The gate declines it, and arm
E cells `s_thisrecv` / `s_superrecv` hold it byte-identical to pristine.  The
same arm's `s_nowiththis` cell records that r10uvm74's law DOES already fire on
that spelling without a clause (residue R3 below): this pass leaves that
exactly as it found it.

---

## 3. THE LAW, AND THE PRODUCTION SURFACE

> **§ `withRecvIndexedStepIsBitSelect175`.**  A step of a built-in method
> call's receiver path that is written with an index is a `bit_select` — named
> for the BASE name, with the cumulative written text as its fullname, its
> compiled index as `vpiIndex` parented at the `hier_path`, and a span that
> stops before the `[` — **whether or not the call carries a `with` clause**,
> because Surelog builds both forms in one loop and compiles the clause only
> after every element exists.
>
> **THE FENCE IS THE TREE, NOT THE TEXT** (unchanged from r10uvm74): the
> re-shape fires only where `builtinRecvStepSelectors74` has confirmed the text
> split COMPONENT FOR COMPONENT and DIMENSION FOR DIMENSION against the
> receiver slang bound.
>
> **THE ONE DECLINE:** a receiver rooted at `this`/`super`, which is Surelog's
> `paImplicit_class_handle` road and a different object entirely.

The whole behavioural change, `src/ExprEmit.cpp` (the decode above rides with
it as a comment):

```cpp
-   bool idxSteps74 = !withExpr9 && stepOk23;
+   bool implicitRoot175 =
+       !dots.empty() && (dots[0] == "this" || dots[0] == "super");
+   bool idxSteps74 =
+       stepOk23 && (!withExpr9 || !implicitRoot175);
```

`!withExpr9` short-circuits, so **every no-`with` cell keeps r10uvm74's answer
bit for bit** — which is what the 953 byte-identical surelog databases and the
untouched `g175_c_tail` / `g175_f_fence` control cells assert.

Everything else the shape needs was already in the emitter and is REUSED, not
re-written: the `bit_select` minting loop, the multi-dimension chain
(§ `builtinRecvMultiDimStepIsBitSelectChain14` — one `bit_select` per written
dimension, only dimension 0 named, dimension k taking dimension k−1's index
span), the bare-constant integer-literal index (size 64, `UINT`, no
`vpiParent`), the `emitExpr` index that binds its own `vpiActual`, the
parent rule on the RESULT KIND, and § `dottedIdxRecvFromSyntax23`'s decompiled
fullname.  Arm B measures each of them on golden under the clause and finds
them all unchanged by it.

### STATED GATE == CODE GATE

The prose says *indexed step of a built-in method call receiver, text and tree
agreeing, and — when there is a `with` clause — not rooted at `this`/`super`*.
The code gate is `stepOk23 && (!withExpr9 || !implicitRoot175)` and nothing
else.  There is no third condition in the code that is absent from the prose,
and none in the prose that is absent from the code.

---

## 4. THE GRIDS — six arms, Surelog golden + both binaries, BOTH views

`grid175.sh` builds one Surelog golden and both binaries' databases per arm in
each view, records EVERY rc, keys each arm's scratch on its RELATIVE path,
reads the file list on fd 3 with children `</dev/null`, and asserts
PROCESSED == LISTED.  `cells175.py` lists ONE ROW PER `hier_path` — key
`(start line:col, path VpiName)`, value the ORDERED element-shape vector — and
`score175.py` joins them as a MULTISET, comparing the SET of vectors at each
key and never the multiplicity (r10uvm170 residue R6).  Names inside the arms
are deliberately unlike the arm letters and unlike each other, so an agreeing
cell cannot be an artefact of the naming scheme.

**CALIBRATION FIRST** (`calib175.sh`, `CALIB.r10uvm175.txt`): each arm's
Surelog golden built TWICE in two different directories and scored against
itself — **116 cells over the twelve arm-views, 0 DIFF, 0 one-sided.**

| arm | axis | full-shape | judge-visible |
|---|---|---|---|
| `g175_a_pos` | POSITION: index on component 0 / 1 / both / neither / one-component / last / four-deep | 5 TOGOLD, 3 SAME_AGREE (×2 views) | same |
| `g175_b_idx` | INDEX KINDS: literal, bare name, `i+1`, string key, enum constant, package localparam, a CALL, two dimensions, dynamic, fixed, none | 9 TOGOLD, 1 SAME_AGREE, 1 G-ONLY + 1 O-ONLY (residue R1) | same |
| `g175_c_tail` | TAIL: `find_index` `find` `find_first` `find_first_index` `min` `max` `unique` `sum` `sort`, the same receiver with NO clause, a USER method, `randomize with {}` | 8 TOGOLD, 2 SAME_AGREE, 2 STILLWRONG | 8 TOGOLD, **4 SAME_AGREE** |
| `g175_d_home` | HOMES/SLOTS: in-body method, out-of-body method, package free function, module `initial`, module `always`, module function, call ARGUMENT, `if` condition, rvalue, `foreach` body | 10 TOGOLD, 2 SAME_AGREE | same |
| `g175_e_sel` | SELECT SHAPES + ROOTS: 1-dim, 2-dim, dotted index, `this.`, `super.`, fixed array, part select, indexed part select, and the no-clause `this.` control | 3 TOGOLD, 1 MOVEDWRONG, 4 G-ONLY + 3 O-ONLY | **4 TOGOLD**, 4 G-ONLY + 3 O-ONLY |
| `g175_f_fence` | MULTIPLICITY + neighbours: no-select receiver, package-scoped root, virtual-interface root, two STATEMENT-position cells (§124's law), the same call written three times, two ordinary indexed READs | 3 TOGOLD, 4 SAME_AGREE | same |

**Totals: TOGOLD 76 / AWAY 0 / MOVEDWRONG 2 / STILLWRONG 4 on the full shape;
TOGOLD 78 / AWAY 0 / MOVEDWRONG 0 / STILLWRONG 0 on the judge-visible fields.**
The two columns are printed side by side by the driver and both are in
`GRID.r10uvm175.txt`; nothing is hidden behind the second one.  What separates
them is exactly three named cells, and each is a span or a `vpiParent` — fields
NO generated `Compare` reads (RESUME.md §9):

* `g175_c_tail` `t_user` (`holds[berth].heft()`, a USER method): golden parents
  the index at the `hier_path`, we parent it at the `bit_select`.  **Identical
  before and after this patch** — § `deepRecvCall11`'s cell, not this law's.
* `g175_c_tail` `t_rand` (`holds[berth].randomize() with { … }`): golden gives
  the `bit_select` the INDEX's span and parents the index at the `bit_select`.
  **Identical before and after** — § `memberRandomizeWithIsRecvPath119`'s cell;
  `withExpr9` is null there, so the gate expression cannot have touched it.
* `g175_e_sel` `s_dotidx` (`decks[helper.nail()]`): kind, VpiName, span and the
  index's own kind and VpiName ALL become golden's; only the nested index
  path's END column differs (golden 31:19-31:25, ours 31:19-31:32).  Pristine
  had the wrong kind, the wrong name, no index child at all, and no nested path
  object; the `31:19|helper.nail` key it now shares with golden did not even
  exist on our side before.

**No cell moved AWAY from golden in any arm, in either view, in either column.**

**The official judge on the same arms** (uhdm-cmp, pristine → patched, cmp
lines / head count; `--nobuiltin` on both producers so the arms are comparable):

```
g175_a_pos    def   40/1 ->   0/0   CMP_EQUAL
g175_a_pos    elab  48/1 ->   0/0   CMP_EQUAL
g175_c_tail   def   40/1 ->   0/0   CMP_EQUAL
g175_c_tail   elab  48/1 ->   0/0   CMP_EQUAL
g175_d_home   def   44/1 ->  29/1   head OBJECT changed -> io_decl(lane) @18:29 (out-of-body io_decl family)
g175_d_home   elab  44/1 ->  17/1   ditto
g175_b_idx    def   40/1 -> 188/1   head OBJECT changed -> hier_path(casks[].labels) @34:15 (residue R1)
g175_b_idx    elab  44/1 -> 212/1   ditto
g175_e_sel    def   40/1 -> 134/1   head OBJECT changed -> hier_path(this.decks.knots) @33:13 (the DECLINE)
g175_e_sel    elab  48/1 -> 154/1   ditto
g175_f_fence  def  135/1 -> 135/1   head UNCHANGED (package foxtrot_quay) — the arm's own background
g175_f_fence  elab 135/1 -> 135/1   ditto
```

Four arm-views reach **CMP_EQUAL**.  On the three that do not, the pristine
head was THIS LAW's own cell and the new head is a DIFFERENT OBJECT owned by
another family — a cmp line count going UP with a CHANGED head object is the
new head's decompile size (RESUME.md §7).

**RC census.**  BOTH BINARIES exit `rc=0` on all twelve arm-views, and the
`uhdm-dump` of every database exits `0`.  **Surelog** exits `4` on ten of the
twelve while STILL WRITING THE DATABASE, on its own checkers, and the
diagnostics are themselves evidence of the law — it type-checks the name it has
ALREADY split off the subscript, and it resolves the path it has ALREADY named
without one:

```
[ERR:CP0332] g175_c_tail.sv:37:7  Function "%exobj" is not defined for variable "holds.weights"
[ERR:CP0332] g175_f_fence.sv:30:7 Function "push_back" is not defined for variable "shelves.words"
[ERR:UH0725] g175_a_pos.elab:27:18 Unresolved hierarchical reference "rows[seat].stalk[slot].tagset"
[ERR:UH0725] g175_e_sel.elab:29:13 Unresolved hierarchical reference "slab[1][cursor].knots"
[ERR:CP0333] g175_d_home.sv:21:7  Undefined system task/function "$display"   (-nobuiltin)
```

Recorded, not hidden; every one of those cells is in the database and is
scored.

---

## 5. THE CORPUS FACE CENSUS — every `with`-form path, both sides, both corpora

`ct175cen --wface` classifies every `hier_path` whose LAST element is a
`method_func_call` carrying a `vpiWith` (that IS the array-locator `with`
form — Surelog puts the clause there and so do we) by what its non-last
elements look like.  `wface175.sh` runs it over a whole `verify_golden`
workdir, reading each row's golden out of that row's OWN `cmds.txt`.

```
-- WFACE surelog/PRISTINE   rows=956  SKIP=617
   GOLDEN withpaths=324 this_super=0 SUBSCRIPTED-REFOBJ=0 BITSEL=2 PLAIN=322
   OURS   withpaths=324 this_super=0 SUBSCRIPTED-REFOBJ=2 BITSEL=0 PLAIN=322
   FACEDIFF rows: default/MiniAmiq-544c7f61, testflags/MiniAmiq-544c7f61   (and NO others)

-- WFACE surelog/PATCHED    rows=956  SKIP=617
   GOLDEN withpaths=324 this_super=0 SUBSCRIPTED-REFOBJ=0 BITSEL=2 PLAIN=322
   OURS   withpaths=324 this_super=0 SUBSCRIPTED-REFOBJ=0 BITSEL=2 PLAIN=322
   FACEDIFF rows: NONE

-- WFACE uhdm2rtlil/PRISTINE  rows=1358  SKIP=104
   GOLDEN withpaths=0   OURS withpaths=0
```

Three facts fall straight out of it:

1. **Golden's rule is uniform over the whole corpus** — in 324 `with`-form
   paths golden writes a text-subscripted `ref_obj` **zero** times, and both of
   its indexed cells are `bit_select`s.  The grids say the same thing cell by
   cell; this says it corpus-wide.
2. **The `with`-path POPULATION is identical on both sides and before and
   after** (324 = 324 = 324).  This law changes an element's KIND and its END
   column — never a path's existence.  That invariant is the census's own
   control and it holds.
3. **uhdm2rtlil cannot reach the law at all** (zero `with`-form paths in
   1358 databases), which is why its mover count is 0 and had to be.

---

## 6. THE UVM CENSUS — nine row-modes, EVERY `hier_path`, not just the law's face

`cen175.sh` + `ct175cen` + `score175.py`, `CENSUS.r10uvm175.txt`.  The key is
`(path start line:col, path VpiName)` — invariant under the law by
construction, so the whole moving part is on the value side; the home chain is
evidence, never a key.

```
                        PRISTINE                      PATCHED
SeqDriver    def/tf     AGREE 3863  DIFF 502          SAME_AGREE 3863  STILLWRONG 502
SimpleUVM    def/tf     AGREE 3974  DIFF 371          SAME_AGREE 3974  STILLWRONG 371
Scoreboard   def        AGREE 3987  DIFF 371          SAME_AGREE 3987  STILLWRONG 371
MiniAmiq     def/tf     AGREE 4023  DIFF 588          SAME_AGREE 4023  STILLWRONG 587  TOGOLD 1
BuildUVMPkg  def/tf     AGREE 4280  DIFF 407          SAME_AGREE 4280  STILLWRONG 407
   (one-sided sets identical on every row, before and after)
```

**TOGOLD 1 per MiniAmiq row-mode — AWAY 0, MOVED-WRONG 0**, over EVERY
`hier_path` in nine UVM databases, not merely over the law's own face.  The
moved cell, printed by the scorer:

```
TOGOLD  L233:24|checks_details[details_index].tests_names
    G: bit_select|checks_details|233:24-233:38|idx=ref_obj@233:39-233:52^hier_path;
       ref_obj|tests_names|233:54-233:65|idx=-;method_func_call|find_index|233:66-233:76|idx=-
    O: bit_select|checks_details|233:24-233:38|idx=ref_obj@233:39-233:52^hier_path;
       ref_obj|tests_names|233:54-233:65|idx=-;method_func_call|find_index|233:66-233:76|idx=-
```

identical to golden field for field and span for span.  The ~500 `STILLWRONG`
paths per row are the untouched background of other families (macro location
attribution, `this.`-rooted paths, naming residues); they are unchanged cell
for cell and are what makes "only this law's cell moved" a measurement rather
than an assertion.

---

## 7. THE A-PRIORI MOVER PREDICTION, AND THE MOVERS

`predict175.sh` + `ct175cen --pred`, run on the PRISTINE databases and their
goldens ALONE, **before** the patched sweep.  The predicate is a deliberate
SUPERSET of the law's site — it lists every `with`-form path holding a
text-subscripted `ref_obj` element and not rooted at `this`/`super`, ignoring
the tree agreement only slang can see — so a row printing nothing here CANNOT
move:

```
CAND 1 default/MiniAmiq-544c7f61/slang.uhdm
CAND 1 testflags/MiniAmiq-544c7f61/slang.uhdm
-- PREDICT surelog     scanned=956   SKIP=0  ROWS-WITH-CANDIDATES=2
-- PREDICT uhdm2rtlil  scanned=1358  SKIP=0  ROWS-WITH-CANDIDATES=0
```

**Byte movers, surelog: `MOVERS 3 / 956`, SELFCHECK 955/956.**

```
MOVER ./default/MiniAmiq-544c7f61/slang.uhdm     PREDICTED
MOVER ./testflags/MiniAmiq-544c7f61/slang.uhdm   PREDICTED
MOVER ./default/Scoreboard-59431470/slang.uhdm   NOT predicted — THE COIN
```

**Scoreboard/default is the documented ~50/50 COIN** (RESUME.md §9: the
`svunit_pkg` `vpiTaskFunc` list ORDER flip under slang's parallel parse).
Attributed the only sound way, ORDER-BLIND: both dumps workdir-normalised,
`id:`-stripped and SORTED — **0 differing lines**.  Its cmp log is byte-identical
before and after (md5 `a545f4d99e6c`), and the census above reports it unchanged
cell for cell.

**Byte movers, uhdm2rtlil: `0 / 1358`**, SELFCHECK 1357/1358 — as both the
predictor and the face census said it had to be.

**MiniAmiq attribution** (same order-blind method): **12 lines, ONE cell, and
nothing else** —

```
+ bit_select: (checks_details[details_index]) 233:24-233:38
      |vpiName:checks_details
      |vpiFullName:checks_details[details_index]
      |vpiIndex -> ref_obj (…::get_checks::details_index) 233:39-233:52, parented at the hier_path
- ref_obj: (…::get_checks::checks_details[details_index]) 233:24-233:53
      |vpiName:checks_details[details_index]
```

The other 953 surelog databases are byte-identical under the two binaries, so
no cell in them can have moved — byteverify is the stronger test and it reports
zero.

---

## 8. HEADS — every row of `rowheads.sh`, both sweeps

The cmp LOGS are md5-compared, not merely their line counts.

```
                   pristine      patched
SeqDriver    def     33 / 1  ->   33 / 1    log BYTE-IDENTICAL
SeqDriver    tf      33 / 1  ->   33 / 1    log BYTE-IDENTICAL
SimpleUVM  def/tf    40 / 1  ->   40 / 1    logs BYTE-IDENTICAL
Scoreboard   def     95 / 1  ->   95 / 1    log BYTE-IDENTICAL (the coin did not move it)
MiniAmiq   def/tf    40 / 1  ->   29 / 1    HEAD CLEARED; head OBJECT changed (233:24 -> 94:29)
BuildUVMPkg def/tf   52 / 1  ->   52 / 1    logs BYTE-IDENTICAL
Earlgrey_0_1 def     31 / 1  ->   31 / 1    log BYTE-IDENTICAL
Earlgrey_0_1 tf     122 / 1  -> 122 / 1     log BYTE-IDENTICAL
Rggen        def      0 / 0  ->    0 / 0    CMP_EQUAL
```

`SKIP-NOFILE` on Scoreboard/testflags and Rggen/testflags is expected (those
rows have no golden).  The old head, `bit_select (checks_details)` @233:24, is
GONE from the cmp log (`grep -c` = 0).

---

## 9. THE BOUNDARIES

**The WIDE boundary** (`bound175.sh`, reused verbatim from r10buvm30 via
r10uvm120/124): every `.sv`/`.v` under a COPY of `tools/probe`, both binaries,
DEF and ELAB, fd-3 list, children `</dev/null`, PROCESSED asserted, subdirectory
arms included.

```
LISTED=4848 FENCED_SKIPPED=0 PROCESSED=4848 MOVED=14 NO_OUTPUT_PAIRS=378
PROCESSED-ASSERT-OK          ASYMMETRIC_OUTPUT: 0
```

Twelve of the fourteen are this pass's own six arms in two views.  **The other
two are `r10uvm74repro/v74_edge.sv`, def and elab** — and that is the best
possible reading, because `v74_edge.sv:73` is

```systemverilog
    // ---- R2: a `with` clause over an INDEXED receiver (fenced OUT) ----
    function void w(int i);
      r = mq[i].iq.sum() with (item);
    endfunction
```

the cell r10uvm74 wrote down as its own unreachable residue.  Re-measured
against its OWN Surelog golden in both views (`FLOOR.r10uvm175.txt`):

```
v74_edge.def   G-ONLY=2  O-ONLY=2  SAME_AGREE=8  STILLWRONG=2  TOGOLD=1
v74_edge.elab  G-ONLY=2  O-ONLY=2  SAME_AGREE=7  STILLWRONG=3  TOGOLD=1

TOGOLD  73:11|mq[i].iq
    G: bit_select|mq|73:11-73:13|idx=ref_obj@73:14-73:15^hier_path;ref_obj|iq|73:17-73:19|idx=-;method_func_call|sum|73:20-73:23|idx=-
    O: (identical)
```

**The one moved cell is that residue, and it moves TOGOLD.**  Every other cell
in the arm — the refusal cells `e_multidim`, `e_dotidx`, `e_callidx`, the empty
product cells `p_litmid`, `p_cpdmid`, `p_litboth`, `p_spacelit`,
`p_parenless_mid`, `p_deepmethod`, `p_usermeth_idx` and the statement-form
`c_stmt` cells — is `SAME_AGREE` or `STILLWRONG`: unchanged.

**The named boundaries.**  Not one arm of r10uvm172, r10uvm124, r10uvm89
(`hpTrailSelIdxDecompiled89`, `rendersAsItself89`, `selGroup89`, the
ElementSelect chain arm and the boundary mover `v81h_lvbase`), r10uvm77-79,
r10buvm14 (`builtinRecvMultiDimStepIsBitSelectChain14`), r10uvm84/85,
r10uvm82-91, r10buvm3-15 or r10sd8-12 moved — they are all inside the 4848 and
all silent.  The two neighbouring laws whose cells this arm set deliberately
contains, § `selRecvStmtCallBareNames124` (arm F `f_stmt`/`f_stmt2`) and
§ `memberRandomizeWithIsRecvPath119` (arm C `t_rand`), are byte-identical.

**The 378 `NO_OUTPUT_PAIRS`** are arm-views where NEITHER binary produced a
database (32 of them symmetric segfaults, the rest deliberate reject arms);
`ASYMMETRIC_OUTPUT` — one side producing and the other not — is **0**, which is
the reading that would have convicted a crash introduced here.

---

## 10. R0 — THE NEXT HEAD ON THIS ROW

**MiniAmiq default and testflags, 29 cmp lines, ONE head each, the two logs
BYTE-IDENTICAL** (md5 `d10e1669eb7a`).  Decoded with the same owner-finder
(`OWNER.next.r10uvm175.txt`):

```
HEAD LHS = io_decl(a_test_name)@91:51-91:62      HEAD RHS = <null>
```

which is BaseClass.h's SINGULAR `SafeCompare` naming the VALUE — so the failing
edge is a singular relation holding golden's `io_decl` and holding nothing on
ours.  The REFERENCE SCAN names it without any walk at all:

```
golden ref_obj(a_test_name)@94:29-94:40
    edge vpiType=700 (singular)              <- ref_obj::Actual_group
    ours   ref_obj(a_test_name)@94:29-94:40 -> singular <null>
```

Site, `svaunit/sv/svaunit_vpi_wrapper.svh:91-95`:

```systemverilog
   virtual function void set_test_name_vpi(string a_test_name);   // 91
      test_name = a_test_name;                                    // 92
                                                                  // 93
      vpi_vif.set_test_name(a_test_name);                         // 94  <- col 29
   endfunction                                                    // 95
```

**An ARGUMENT of a call through a VIRTUAL INTERFACE handle does not bind its
`vpiActual` to the enclosing subroutine's `io_decl`.**  Our `io_decl` object
itself EXISTS (the scan shows our `ref_typespec` pointing at it) and the
identical name one line earlier, at `92`, is not the head — so this is a
binding-window defect at the virtual-interface call, not a missing declaration.
It is the `ref_obj::Actual_group` family r10buvm13/15 decoded
(`RHS: <null>` on a singular), and the natural instrument is the same
`ct175own.cpp` reference scan plus buvm13/15's argument-binding arms.

---

## 11. RESIDUES, ranked

* **R1 — an index whose text is a CALL, in the PATH NAME.**  Golden's
  `decompileHelper` has no row for a `func_call` or a `hier_path`, so a path
  written `casks[pick()].labels` is NAMED `casks[].labels` in golden and
  `casks[pick()].labels` by us (arm B cells `i_call`, arm E `s_dotidx` is the
  DOTTED half that § `dottedIdxRecvFromSyntax23` already gates and gets right).
  This law makes the ELEMENT right there — kind, VpiName and span all become
  golden's — and leaves the PATH NAME alone; it is § 23's residue R-Q, one
  field wide, and it is arm B's remaining G-ONLY/O-ONLY pair and arm B's new
  cmp head.  **Zero corpus cells** in either corpus.
* **R2 — the nested index path's SPAN.**  With a dotted index the compiled
  index is itself a `hier_path`; golden spans it over its FIRST name only
  (`helper`, 31:19-31:25) and gives that path's own leading `ref_obj` a
  degenerate 31:25-31:25 span, while ours spans the written text
  (31:19-31:32).  Kind and every VpiName agree; spans are read by no generated
  `Compare`.  Arm E `s_dotidx`, **zero corpus cells**.
* **R3 — r10uvm74's law already fires on a `this.`-rooted receiver WITHOUT a
  clause.**  Arm E `s_nowiththis` records it: golden's
  `this.decks.knots.size` path drops the subscript and we emit
  `bit_select|decks` with an index.  That is r10uvm74's pre-existing answer,
  byte-identical before and after this patch, and correcting it means changing
  r10uvm74's own arms — the FLOOR.  It belongs with the `this.`/`super.` family
  (r10uvm84/85), which owns the whole shape.
* **R4 — the `vpiParent` of an index under a USER-method receiver** (arm C
  `t_user`): golden parents it at the `hier_path`, we at the `bit_select`.
  § `deepRecvCall11`'s cell; unchanged here; `VpiParent` is read by no
  generated `Compare` (RESUME.md §9), so it is dump fidelity only.
* **R5 — the `randomize with { … }` member form's `bit_select` span** (arm C
  `t_rand`): golden gives the `bit_select` the INDEX's span and parents the
  index at the `bit_select`.  § `memberRandomizeWithIsRecvPath119`'s cell;
  `withExpr9` is null there so this gate cannot reach it; unchanged.
* **R6 — a `with`-form path in STATEMENT position with a VOID array method**
  (arm C `t_sort`, `holds[berth].weights.sort() with (item);`): golden builds
  no `hier_path` at all for it — that spelling goes down `compileTfCall`, the
  § `selRecvStmtCallBareNames124` road.  Recorded so the census's silence there
  is a measurement, not a gap.

---

## 12. FILES

| file | role |
|---|---|
| `g175_a_pos.sv` | arm A — POSITION of the subscript in the receiver chain |
| `g175_b_idx.sv` | arm B — INDEX KINDS |
| `g175_c_tail.sv` | arm C — the locator METHOD, plus the two neighbouring laws' cells |
| `g175_d_home.sv` | arm D — HOMES and expression SLOTS |
| `g175_e_sel.sv` | arm E — SELECT SHAPES and the `this.`/`super.` ROOTS (the DECLINE) |
| `g175_f_fence.sv` | arm F — MULTIPLICITY, other roots, statement-position twins |
| `grid175.sh` | the arm driver — golden + both binaries, both views, every rc, the official judge on each arm |
| `calib175.sh` | golden-vs-golden CALIBRATION of the census instrument |
| `cells175.py` | the element-shape vector of every `hier_path` in a `uhdm-dump` |
| `score175.py` | the multiset join and the two scoring columns (`--judge`) |
| `ct175cen.cpp` | the census (`Serializer::AllObjects`), `--pred` and `--wface` |
| `ct175own.cpp` | THE OWNER-FINDER — the judge decode, both sides present |
| `cen175.sh` | the corpus census over a `verify_golden` workdir |
| `wface175.sh` | the LAW'S FACE counted over a whole workdir, both sides |
| `predict175.sh` | the A-PRIORI mover prediction from pristine databases alone |
| `bound175.sh` | the WIDE boundary gate |
| `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the gates |
| `GATES/CENSUS/GRID/CALIB/BOUNDARY/FLOOR/MOVERS/PREDICT/WFACE/OWNER*.txt` | the evidence |
| `head_pris_default_MiniAmiq.cmp`, `head_pat_default_MiniAmiq.cmp` | the head, before and after |
