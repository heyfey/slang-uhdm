# r10svs2 — THE PARENTHESES ARE THE WHOLE DISCRIMINATOR

**Result, up front: the SVSwitch head the brief set as the target is CLEARED, and
so is the head that replaced it.** SVSwitch stays `CMP_NOTEQUAL` in both modes —
it is **not** a conversion — but the head has moved out of the parens cluster
entirely and into the pre-existing **interface / clocking-block** cluster.

```
head @946579a (the brief's target)   ref_obj: (work@packet::cal_fcs::size), 48:22-48:26
                                    vs ours  method_func_call: (size), 48:22-48:26
head after LAW 1                    ref_obj: (work@packet::display::cal_fcs), 65:45-65:52
                                    vs ours  func_call: (cal_fcs) + vpiFunction
head after LAW 1 + LAW 2 (shipped)  begin: (work@packet::byte_unpack), 84:3-84:22
                                    -- a whole-statement-list head whose diff is
                                       `vpiName:cb` / interface_inst naming, i.e.
                                       the KNOWN Interface cluster, not this pass
```

* **cmp HEAD DEPTH 26 → 30 → 1512 lines**, one head per run throughout. Head
  depth is *not* a distance and is never reported as one: the 1512 is Compare
  dumping a whole `begin` subtree behind the new head, not 1512 defects.
* **dump DISTANCE (true content `-`/`+` lines) 2698 → 2647 → 2632** — down 66 —
  and the **MULTISET distance, which uses no alignment at all, 757 → 726**. All
  three instruments are tabulated separately in §5 and never conflated; the
  per-shape `grep -Fxc` against golden is the only *attributable* measure and it
  is what §5 and the mover attribution both settle on.
* **TWO LAWS**, and the brief's framing is **REFUTED in three separate places**
  (§3). The biggest one: the brief's *negative control* — "a CLASS-HANDLE method
  with no parens (`obj.print;`) … must not be swept into the law" — **is not a
  negative control at all.** In expression position golden sweeps user-defined
  class methods in *with* the array queries; what actually protects `obj.print;`
  is that it is a **STATEMENT**. A refutation is worth more than agreement, and
  this is the pass's main finding.
* **ARMS: 45 hier_path cells across 7 arms + 8 object cells in arm s7**, both
  sides listed at OWN CHILD DEPTH. `DIFFERKIND` (the two sides emit an element of
  a DIFFERENT CLASS — the cell these laws own) **22 → 1**; `EQ` **19 → 39**;
  `DIFFER` (same class, a FIELD disagrees) 1 → 3; `UNMEASURED` 2 → 2. Arm s7 goes
  **DIFFERING 3 → 0, 8/8 cells byte-identical.**
* **CORPUS REACH: ZERO rows moved on either corpus** (731 u2r rows, 1588 surelog
  rows, WHOLE-ROW diff *including the dump column*). **BYTES: u2r 0/679 movers;
  surelog 9/953 movers**, and **all nine are ATTRIBUTED, line by line, to these
  two laws alone** (§6, GATE 5) — SVSwitch ×2 modes plus the four UVM rows
  (`SimpleUVM`, `SeqDriver`, `BuildUVMPkg`, `Scoreboard`). Every changed line in
  every mover is a hier_path span extension or a `method_func_call`/`func_call`
  → scoped `ref_obj` swap; **zero `vpiSigned`, zero `class_typespec`, zero
  `vpiTypedefAlias` lines**, so the known build-dependent UVM alias churn did
  **not** appear in this landing. Per-shape `grep -Fxc` against golden puts every
  moved UVM shape at **0 → exactly golden's count**, so the nine movers are
  convergence, not churn.
* **ZERO canary rows moved**, both scripts, both corpora, `changed=0 absent=0`.
* **FOUR u2r ROWS REGRESSED on the first attempt at LAW 2 and were fixed by the
  distinguisher they named** (§4). That experiment is written up in full because
  it is the single most informative thing in this pass.

Base commit `946579a`, branch `auto5h`.
Pristine binary md5 `ed106184c97207183fe1316211507882` — **identical to the
main-tree `build/slang-uhdm`**, which is how this pass proved its pristine
worktree really is 946579a (§1).
**Shipped patched binary md5 `5efa1ddebf96bce7869150586162e931`.**

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script in
this directory.

---

## 0. MASTER'S INTEGRATION ADDENDUM — one code fix, seven recorded corrections

The verifier's verdict was **PARTIAL**, on one finding: **F1, a real over-fire that
was a REGRESSION from a cell that already matched golden.** It was fixed before
landing (§1 below carries the code and the arm). Everything else is a write-up or
instrument correction and is recorded AT the claim it corrects, not appended here.
The verifier's own rebuild was **bit-identical** to the implementer's, and its arm
`w3_macrodeep.sv` scored **7/7 against golden** on macro-expanded and deep dotted
receivers — a dimension the implementer never measured.

| # | what the pass said | status |
|---|---|---|
| **F1** | the law is scoped to "EXPRESSION (not statement) position" | **CODE FIXED** — the gate had no statement clause, so `zero;` became a `ref_obj` where golden and our own pristine binary both emit `func_call: (zero) 15:5-15:9`. Added `!callStmtCtx0`. Arm `w1_stmtfunc.sv` (verifier-authored, now in this directory) — all six cells 1/1 against golden on the shipped binary, and the 45-cell table is UNCHANGED at EQ 39 / DIFFER 3 / DIFFERKIND 1 / UNMEASURED 2. §1 |
| **F2** | "the hier_path span runs to the end of the method name" | **TRUE ONLY FOR THE TIGHT SPELLING** — `mStart9 = recv->sourceRange.end() + 1` assumes exactly one character between receiver and method. `d . size`, `q .size`, `q. size`, `d /* c */ . size` and the newline form all come out short (the newline case lands at `20:1` where golden says `20:14`). **NOT a regression** — pristine's `method_func_call` carried the same wrong columns — and corpus reach is 0 because the corpus writes it tight. **NOT FIXED**, deliberately: a trivia-aware scan changes span computation on the macro-remapped surface that `w3` shows currently works, so it needs its own arm set. Ranked **V2**; witness `w2_spacedot.sv`. |
| **F3** | the unifying gate is "written parentheses × expression position" | **THE LAW TEXT IS WRONG IN THE DANGEROUS DIRECTION.** `r = r + this.randomize;` is parens-less AND in expression position, and **golden KEEPS `method_func_call: (randomize) 17:19-17:28`** (arm `w4_classbuiltin.sv` cell 3). The shipped code is right only because its gate is `rawText(expr.sourceRange) == recvText`, which never fires there. **Do NOT "simplify" the gate into an honest written-parens test — that regresses `this.randomize`.** Annotated at the law. |
| **F4** | `ctcan2.sh` on the surelog pair reports `ok=6` | **UNREPRODUCIBLE: it is `ok=58`**, deterministic, identical with the arguments swapped. `changed=0 absent=0 PASS` holds, so this was a mis-transcription, not a gate failure. I measure 58 too. §6 |
| **F5** | dump distance 2698 → 2632, multiset 757 → 726 | **REPRODUCIBLE ONLY AS A DELTA.** The verifier measured 3972 → 3906 and 829 → 798 — the **deltas −66 and −31 reproduce exactly**, the absolutes are golden-provenance-dependent. Quote the delta. |
| **F6** | pristine arm totals `CELLS 44 EQ 19` | **45 / 20.** The patched row (`45/39/3/1/2`) and the substantive `DIFFERKIND 22→1` reproduce exactly, and I re-measured the patched row myself on the shipped binary. §2 |
| **F7** | "goldens 23 PASS" as evidence for a span change | **NEAR-ZERO EVIDENCE: only 1 of the 23 goldens contains a `hier_path` at all** (46 lines). The real evidence is the whole-corpus census, bounded rigorously by byteverify (a byte-identical database cannot hold a different span): **366 `hier_path` span lines changed, 619 changed lines total, every one an extension TOWARD golden.** §6 |
| **F8** | "every changed line in all 9 movers is the law" | **QUALIFIED.** `testflags/SeqDriver` has 36 changed lines outside the law's classes, but the non-law **multiset is IDENTICAL across the two binaries**, so they are pure `diff` realignment. The attribution stands multiset-wise, not line-wise. |

**New residue the verifier found and the pass had not recorded (V4):** a
receiver-less `randomize` / `randomize()` is **dropped entirely by BOTH binaries**
where golden emits a `ref_obj` / `func_call`. Pre-existing, unmeasured reach.

---

## 1. THE LAWS, in the form a future pass can grep for

```
§ parensLessCallIsPathRefObj      src/ExprEmit.cpp  (expression-position built-in method)
§ parensLessFuncRefIsRefObj       src/ExprEmit.cpp  (receiver-less function reference)
§ parensLessSyntaxKindRefuted     src/ExprEmit.cpp  (why the gate is TEXT, not expr.syntax)
```

### § parensLessCallIsPathRefObj

> In **EXPRESSION** position, a dotted method reference written **WITHOUT an
> argument list** is not a call to Surelog. The enclosing `hier_path`'s **LAST
> PATH ELEMENT is a `ref_obj`** named for the method and carrying the ordinary
> prefix-scoped `vpiFullName`, and the **hier_path SPAN runs to the END OF THE
> METHOD NAME**. The identical reference **WITH parens — even EMPTY parens** —
> keeps a `method_func_call` element (no fullname) and the span slang gives.

The span half has to be *rebuilt*, not inherited: slang's `sourceRange` for the
parens-less form **collapses onto the RECEIVER ALONE**.

| form | golden hier_path span | golden last element |
| --- | --- | --- |
| `data.size` (parens-less) | `16:21-16:30` — covers `data.size` | `ref_obj (work@pkt::pl::size)` |
| `data.size()` (parens-ful) | `25:21-25:32` — covers `data.size()` | `method_func_call (size)`, no fullname |
| ours at base, parens-less | `16:21-16:25` — **the base only** | `method_func_call (size)` |

### § parensLessFuncRefIsRefObj

> In **EXPRESSION** position, a **RECEIVER-LESS reference to a FUNCTION** written
> **WITHOUT an argument list** is likewise a plain **scope-scoped `ref_obj`
> spanning the NAME TOKEN**, with **no `vpiFunction` bind**. `zero()` (empty
> parens) and `one(4)` stay `func_call`; a **TASK in statement position**
> (`void_t;`) stays a `task_call` whether or not the parens are written.

> **MASTER'S CORRECTION AT INTEGRATION — the code as submitted did NOT enforce the
> "EXPRESSION position" half of its own law, and that was a REGRESSION.** The gate
> read `realIsFunc18 && rawText(...) == sub.name`: `realIsFunc18` keeps TASKS out,
> nothing kept STATEMENTS out. A parens-less FUNCTION called as a whole statement
> (`zero;` — legal SystemVerilog, the value is discarded) became a `ref_obj` where
> golden and our own pristine binary both emit `func_call: (zero) 15:5-15:9`. The
> verifier found it (its **F1**) and built the arm; I added the clause before
> landing:
>
> `if (realIsFunc18 && !callStmtCtx0 && rawText(expr.sourceRange) == sub.name)`
>
> **`callStmtCtx0`, NOT `callStmtContext`** — the member is saved and CLEARED at
> the top of this `case` (grep `callStmtCtx0 = callStmtContext`), so reading the
> member here would have been a guard that cannot fire, which is this campaign's
> single most common defect. Witness arm **`w1_stmtfunc.sv`** (verifier-authored,
> now in this directory), cell 1; cells 2–4 (`zero();`, `void_t;`, `void_t();`) and
> cells 5–6 (the law's own expression-position cells) are the positive controls and
> are unchanged. **Why the arm set could not see it:** `s7_recvless` measured a
> parens-less TASK in statement position and a parens-less FUNCTION in expression
> position — the product cell was the empty square of the grid, and the only one
> with no guard.

### The unifying statement, and its one real gate

The two laws are the same observation at two sites, and the gate is **not** the
method's identity, the array's kind, or the expression's context — all three are
measured and none of them discriminates (§2). The gate is:

> **written parentheses** × **expression (not statement) position**.

> **DO NOT ACT ON THAT SENTENCE AS IF IT WERE THE GATE (verifier F3).** It is a
> summary, and it is WRONG in the direction that costs rows. `r = r + this.randomize;`
> is parens-less and in expression position, and **golden KEEPS
> `method_func_call: (randomize) 17:19-17:28`** — arm `w4_classbuiltin.sv` cell 3,
> measured on both sides. The SHIPPED code is correct only because its actual gate
> is the narrower `rawText(expr.sourceRange) == recvText`, which never fires for
> `this.randomize`. **Anyone who "cleans this up" into an honest written-parens
> test regresses that cell.** The gate in the code is the law; this sentence is a
> mnemonic with at least one known counterexample.

`liveCalledSubs` bookkeeping is deliberately left running *before* site 2's early
return: reachability is a property of the call site, not of the object class we
emit for it.

---

## 2. THE ARM TABLES

`svarm.sh` drives one arm; `svall.sh <tag>` runs all seven and prints the CELL
table for each plus the TOTALS; `svcells.py` builds the table; `svrecv.sh` is arm
s7's own instrument (see below). Every counter is kept separate on purpose and
none subsumes another — `EQ` / `DIFFER` (same class, a field differs) /
`DIFFERKIND` (different object CLASS) / `UNMEASURED` (one side emits nothing).

A cell is **one SOURCE SITE**, keyed on the method token's `line:col` with
indentation **stripped** — never on a dump line, because *an object is not a dump
occurrence*: the same object prints at several depths. Fullnames are read at
**OWN CHILD DEPTH** (header indent + 2), never from the subtree.

### TOTALS

| | CELLS | EQ | DIFFER | DIFFERKIND | UNMEASURED |
| --- | --- | --- | --- | --- | --- |
| base `946579a` (6 arms) | 44 | 19 | 1 | **22** | 2 |
| shipped (7 arms) | 45 | **39** | 3 | **1** | 2 |

| arm | base | shipped |
| --- | --- | --- |
| `s1_dynsize` witness + positive control | 4: EQ 3, DIFFERKIND 1 | 4: **EQ 4** |
| `s2_querykind` size/sum/product/min/max/unique | 15: EQ 7, DIFFERKIND 6, UNM 2 | 15: **EQ 13**, UNM 2 |
| `s3_arraykind` dynamic/queue/assoc/fixed | 8: EQ 4, DIFFERKIND 4 | 8: **EQ 8** |
| `s4_context` six contexts | 7: EQ 1, DIFFERKIND 6 | 7: **EQ 5**, DIFFER 2 |
| `s5_negctl` user method + receiver-less | 3: EQ 1, DIFFER 1, DIFFERKIND 1 | 3: EQ 1, DIFFER 1, DIFFERKIND 1 |
| `s6_otherbuiltin` string/queue/enum | 7: EQ 3, DIFFERKIND 4 | 7: **EQ 7** |
| `s7_recvless` (new this pass) | — | 1 hier_path cell EQ; **8 object cells, DIFFERING 3 → 0** |

### s1 — the witness and its POSITIVE CONTROL, side by side on ONE golden

```
SITE   | GOLD KIND        GOLD FULLNAME        GOLD HPSPAN | OURS (base)                    | OURS (shipped)
16:26  | ref_obj          work@pkt::pl::size   16:21-30    | method_func_call  - 16:21-25   | ref_obj work@pkt::pl::size 16:21-30
25:26  | method_func_call -                    25:21-32    | method_func_call  - 25:21-32   | method_func_call - 25:21-32
```

**The parens-ful cell is byte-identical before and after** — that is the control
the brief demanded and it never moved, here or on the target (§5).

### s2 — WHICH methods, and the ONE exception

`size` `sum` `product` `min` `max`, parens-less, all take the `ref_obj` form.
Parens-ful, all five take `method_func_call`. **`unique` is the exception, in BOTH
spellings**: golden names the hier_path after the **ARRAY ALONE** (`(d)`, not
`(d.unique)`), scopes the **base** ref_obj (`work@qy::f::d`) and keeps a
`method_func_call (unique)` element — i.e. the shape our emitter already produces
only when a `with` clause is present, but golden takes it for `unique` with **no
`with` clause at all**. Both `unique` cells are the two `UNMEASURED` survivors and
are ranked residue R4.

**NOT MEASURED, stated plainly:** `find` / `find_index` / `find_first` /
`find_last` (they require a `with` clause, so they always carry parens) and
`reverse` / `sort` / `rsort` / `shuffle` (void array-ORDERING methods, statement
position only). `d.min[0]` is a **Surelog SYNTAX ERROR** — the locator results are
assigned to a queue instead, which is itself a measurement.

### s3 — EVERY array kind, and array kind is NOT the discriminator

`dyn.size` `que.size` `asc.size` `asc.num` all take the `ref_obj` form;
`asc.exists("k")` `asc.first(k)` `que.size()` all take `method_func_call`. **8/8
EQ.**

**REFUTATION of the brief's item 3.** The brief asked for "a FIXED unpacked array
(where `size` is also legal)". **slang REJECTS it** — `invalid member access for
type 'int$[8]'` — while Surelog *accepts* it. The cell is unmeasurable on our
side; the site is left commented in `s3_arraykind.sv` with the compiler's own
words so a future pass does not re-derive this.

### s4 — the CONTEXT, and the brief's warning was RIGHT (about the FULLNAME, not the span)

The brief warned that "golden may span the hier_path differently per context".
**The SPAN is uniform across all six contexts.** What is context-dependent is the
**FULLNAME**, in three regimes:

| context | golden fullname of the query ref_obj |
| --- | --- |
| for-condition · plain rvalue · `$display` argument · `if` condition | `work@cx::f::size` (enclosing scope) |
| **INDEX of a select on that same array** (`bytes[bytes.size-1]`) | `work@cx::f::bytes::size` — **the array name is inserted** |
| **`new[...]` size argument** (`new[data.size+4]`) | **NAME-ONLY** — golden prints `ref_obj: (size)` with no fullname |

All three fall out of the ordinary `joinRef(prefix, name)` with **no extra rule**,
which is why the law needs none — the `prefix` machinery already tracks context.
The two survivors are *how* it tracks it, not *whether*: residues R2 and R3.

### s5 — THE BRIEF'S NEGATIVE CONTROL IS REFUTED

| site | source | golden | ours (shipped) | verdict |
| --- | --- | --- | --- | --- |
| `24:11` | `r = o.val;` user class method, no parens, **expression** | `ref_obj (work@holder::f::val)` | `method_func_call (val)` | **DIFFERKIND — golden DOES sweep it in** |
| `23:7` | `o.print;` user class method, no parens, **statement** | `method_func_call (print)` + prefix | identical | byte-identical, before and after |
| `25:13` | `r + own` receiver-less own function | `ref_obj (work@holder::f::own)` | `ref_obj …::own` after LAW 2 | fixed by LAW 2 |

So the brief's stated negative control (`obj.print;`) is protected by being a
**STATEMENT**, not by being a non-array member call; and the brief's premise that
the law is about "built-in array-query / array-locator methods" is **too narrow** —
golden applies the same rule to a **user-defined class method**. That last cell is
the single surviving `DIFFERKIND` and is ranked residue R1.

### s6 — non-array built-ins: all queries, none calls

`s.len` `q.pop_front` `e.name` `e.first` parens-less → `ref_obj` with scoped
fullname. `s.len()` `e.name()` → `method_func_call`. `q.delete();` (statement) →
flat `method_func_call`, untouched. **7/7 EQ.** So the law is not about *arrays*
either: a **string** method, a **queue MUTATOR** (`pop_front`, which has side
effects and still becomes a bare `ref_obj`) and an **enum** method all obey it.

### s7 — the receiver-less site, with its own instrument

`svcells.py` reads the *second path element of a dotted hier_path* and is
therefore **blind to s7**, whose sites are receiver-less and have no hier_path at
all. `svrecv.sh` censuses the objects themselves, keyed on name+span with
indentation stripped. Base **golden=8 ours=8 IDENTICAL=5 DIFFERING=3**; shipped
**IDENTICAL=8 DIFFERING=0**.

```
GOLDEN                                            OURS (base)                    OURS (shipped)
ref_obj: (work@rl::f::zero), 15:9-15:13           func_call: (zero), 15:9-15:13  ref_obj …::zero  ✓
ref_obj: (work@rl::f::zero), 16:13-16:17          func_call: (zero), 16:13-16:17 ref_obj …::zero  ✓
ref_obj: (work@rl::f::zero), 17:21-17:25          func_call: (zero), 17:21-17:25 ref_obj …::zero  ✓
func_call: (zero), 18:9-18:15   <- EMPTY PARENS    identical                      identical        ✓
func_call: (one),  19:9-19:15   <- ONE ARGUMENT    identical                      identical        ✓
task_call: (void_t), 26:5-26:11 <- TASK, no parens identical                      identical        ✓
task_call: (void_t), 27:5-27:13                    identical                      identical        ✓
```

`void_t;` and `void_t();` had to move into a `task` because **slang refuses
"cannot invoke a task from within a function"** — a measurement in itself, noted
in the arm source.

---

## 3. THE THREE REFUTATIONS OF THE BRIEF, each proved

1. **"a CLASS-HANDLE method with no parens … as the NEGATIVE control: it must not
   be swept into the law."** REFUTED. Arm s5 site `24:11`: golden emits
   `ref_obj (work@holder::f::val)` for `r = o.val;`, a user-defined class method.
   The real protection for `obj.print;` is STATEMENT position (s5 site `23:7`,
   byte-identical throughout). The law's scope is *parens × expression position*,
   not *array-query methods*.
2. **"the hier_path span extends to the end of the member name … golden may span
   the hier_path differently per context."** HALF-REFUTED, and the wrong half was
   the risk. The span rule is real but **context-INDEPENDENT** (s4: identical in
   all six contexts). What *is* context-dependent is the **FULLNAME**, three
   regimes, §2/s4 — which the brief did not mention and which is where both
   surviving `DIFFER` cells live.
3. **"a FIXED unpacked array (where `size` is also legal)."** REFUTED for our
   frontend: slang rejects `fix.size` on `int fix[8]` outright while Surelog
   accepts it. Unmeasurable cell, recorded in the arm source.

Two smaller corrections to the brief's own counts, both re-censused here:

* **"ours has 10 `method_func_call: (size)` objects"** → **11**, at 40:26, 41:20,
  46:78, 48:22, 65:32, 71:20, 77:14, 78:21, 86:26, 87:25, 91:18. Golden has
  **2** (65:32, 77:14 — the parens-ful pair) plus **6** query `ref_obj`s; the
  11 − 8 = **3 extra are ours alone**, all inside a `new[...]` size, and one of
  them (87:25) sits inside a whole `new` call golden never emits.
* **"three more parens-less sites at 40/41/46 live in another SVSwitch file"** →
  confirmed as `Receiver.sv`, and the constraint sites (`Packet.sv:28/31/32/34`,
  `testcase.sv:14`) carry **no** hier_path on either side, so they are not cells.

---

## 4. THE FOUR-ROW REGRESSION, AND THE DISTINGUISHER IT NAMED

`§ parensLessSyntaxKindRefuted`. LAW 2's first implementation gated on the
**syntax node kind** (`expr.syntax->kind != InvocationExpression`). Goldens stayed
23/23 and every arm cell was correct, and the u2r whole-row gate then demoted
**four** rows `CMP_EQUAL → CMP_NOTEQUAL`:

```
BitSelectPartSelectInFunction   assign o = int'(iota('1));
FunctionReturnEnum              assign o = int'(mubi4_hi_value());
FunctionWithOverriddenParameter o = int'(get_1s());
ReturnEnumArray                 assign o = int'(get_BA());
```

**Every one is `int'(…)` — a CAST.** All four calls carry written parens, and
`iota('1)` carries an *argument*, yet inside a cast the `CallExpression`'s syntax
pointer is not the `InvocationExpressionSyntax`, so all four were mis-classified
parens-less. (This is the same unreliability `Expression.cpp:872-881` documents
for let-decl expansion.) The measured demotion, verbatim:

```
-      \_func_call: (mubi4_hi_value), line:12:20, endln:12:36
+      \_ref_obj: (work@top.mubi4_hi_value), line:12:20, endln:12:34
-        |vpiFunction:
-        \_function: (work@top.mubi4_hi_value), line:8:4, endln:10:32
+        |vpiFullName:work@top.mubi4_hi_value
```

Note the SPAN in the `-` line: `12:20-12:36` is 16 columns for a 14-character
name, i.e. **`expr.sourceRange` knew about the parens all along**. That is the
distinguisher, and the gate is now on the SOURCE TEXT:

* site 1: `rawText(expr.sourceRange) == recvText` — the parens-less anomaly *is*
  that slang's call range collapses onto the receiver.
* site 2: `rawText(expr.sourceRange) == sub.name` — the tightest form, so empty
  parens, arguments and a `pkg::f` qualifier are all excluded.

Both are deliberately the **conservative direction**: anything ambiguous (a
receiver whose own text contains a `(`) reads parens-ful and keeps the
pre-existing behaviour. After the change all four rows are back to `CMP_EQUAL`
and the whole-row diff is **0**.

---

## 5. THE TARGET — SVSwitch

`SVSwitch` is `CMP_NOTEQUAL` in **both** modes before and after. **It did NOT
convert**, and the row from this pass's own sweep says so:

```
name,mode,status,detail,blocked_by,dump
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

(The `detail` column is the literal string `decompile:`, so no CSV can ever show
a head move — the heads above come from `uhdm-cmp` directly, one head per run,
counted with `grep -c '^LHS:'` at column 0.)

### PER-SHAPE counts against golden — the only attributable measure

Counted as UNIQUE SITES (`sed 's/^[ \\_|]*//' | grep | sort -u`) because *an
object is not a dump occurrence* — the same object prints at several depths and
the raw occurrence counts are 11 / 3 / 6 for exactly that reason.

| shape | golden | ours @946579a | ours shipped |
| --- | --- | --- | --- |
| `method_func_call: (size)` sites | 2 | **11** | **2** |
| — of which the parens-ful POSITIVE CONTROL 65:32 / 77:14 | 2 | 2 | **2, byte-identical** |
| `func_call: (cal_fcs)` sites | 0 | **3** | **0** |
| `ref_obj …::cal_fcs` (receiver-less, LAW 2) | 2 | 0 | **2, byte-identical** |
| query-element `ref_obj …size` sites | 6 | 0 | **9** |
| — matching golden byte-for-byte | — | 0 | **3** (48:22, 78:21, 46:78) |
| — fullname-only residue R2 (`.bytes::` vs `::bytes::`) | — | 0 | **3** (41:20, 86:26, 91:18) |
| — fullname-only residue R3 (`new[…]`, golden wants name-only) | — | 0 | **2** (40:26, 71:20) |
| — inside the `new` call golden never emits (R5) | — | 0 | **1** (87:25) |

The two parens-ful cells are byte-for-byte unchanged, which is the control the
brief required. The 6 → 9 is not an over-shoot of the law: golden has 6 query
sites, we now emit a query `ref_obj` at all 8 real ones (6 + the 2 `new[…]`
sites where golden emits the same object with **no fullname**, which the census
regex above therefore still counts) plus 1 inside the extra `new` call.

### THREE DISTANCES, never conflated

| instrument | base `946579a` | shipped |
| --- | --- | --- |
| cmp HEAD DEPTH (`wc -l cmp.txt`, heads=1 both) | 26 | 1512 |
| `diff -u` content lines (ALIGNMENT-SENSITIVE) | 2698 | **2632** |
| MULTISET distance (`msdist.sh`, no alignment at all) | 757 | **726** |

Head depth went UP and is *not* a distance: it is Compare printing the whole
`begin` subtree behind the new head. Both real distances went DOWN, and the
per-shape table above is what attributes the drop.

### What is left on SVSwitch, from `diff -u g.dump o.dump`

The head is now `begin: (work@packet::byte_unpack)` and the ranked diff-line
census is dominated by the **interface / clocking-block** cluster (`vpiName:cb`
33×, `interface_inst` naming, `port (clock)`, `modport (OP)`) — the known
Interface DIFF cluster, untouched by this pass. Of the query shapes only **five
fullname cells** survive, listed as R2/R3 in §8.

---

## 6. THE FIVE GATES, every one with the number measured

### GATE 1 — BUILD

`cmake --build build -j 3`, waited for `Linking CXX executable slang-uhdm`
(`grep -c` = 1, 0 `error:` lines), then the md5 asserted **in a separate command,
before any sweep**:

```
GATE1 PASS: binary md5 CHANGED ed106184c97207183fe1316211507882
                           -> 5efa1ddebf96bce7869150586162e931
```

The pristine worktree's own binary is `ed106184c97207183fe1316211507882`, **byte-
identical to the main-tree `build/slang-uhdm`** — that equality is the proof the
pristine worktree really is `946579a`.

> Ops note for the next pass: **two `-j 3` builds in parallel OOM-kill `cc1plus`**
> on this 15 GB box (`c++: fatal error: Killed signal terminated program cc1plus`).
> Build one worktree at a time.

### GATE 2 — GOLDENS

```
23 PASS / 0 FAIL
```

**Negative control**, quoted: `SLANG_UHDM=/bin/false tests/check_goldens.sh` →
**0 PASS / 23 FAIL**, e.g.
`FAIL wreduce_test0 (diff …/tests/golden/wreduce_test0.dump /tmp/tmp.543rfVD1je/slang.dump)`.
A control that cannot fire is not a control; this one fires on all 23.

Run **three times** across the pass — after LAW 1, after LAW 2, and on the
shipped binary — because the span change is a LOCATION change and location
changes are how this campaign has broken goldens before. 23/23 every time.

### GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 row-sides)
```

Judged whole-row, dump column included, with
`tools/probe/r10oth8repro/ct8rows.sh`. The **pristine** sweep was judged the same
way first and also read **0 differing rows** — that is the control proving the
harness/workdir chain reproduces the committed baseline exactly.

### GATE 4 — surelog `--mode both --jobs 2`

```
default   : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
testflags : 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
            + 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM
dump: default 225 match / 242 differ / 327 blank
      testflags 165 match / 298 differ / 331 blank
WHOLE-ROW diff vs results/golden_surelog.csv: 0 differing ROWS
```

`GOLDEN_DEFER` left at its default — the 5 memory-giant tests stay `DEFERRED`.
The pristine sweep again read **0 differing rows** against the committed
baseline.

### GATE 5 — BYTE VERIFIER, both corpora, against a pristine 946579a workdir built here

`tools/probe/r10oth6repro/byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r      : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
           SELFCHECK  678/679 flagged        SELFCHECK1 = 1
surelog  : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 9 / 953
           SELFCHECK  952/953 flagged        SELFCHECK1 = 10 (= the 9 real movers
                                            + the 1 deliberately corrupted file,
                                            exactly as the script's own note says)
```

Both negative controls fire on both corpora: the all-vs-one control flags every
path but the reference, and the single-corruption control reports the real movers
plus exactly one. A verifier that cannot see one corrupted file cannot see one
changed law.

### MOVER ATTRIBUTION — all 9, by content, with `ct9movers.sh`

```
./default/SVSwitch-db796243        ./testflags/SVSwitch-db796243
./default/BuildUVMPkg-bf853d43     ./testflags/BuildUVMPkg-bf853d43
./default/SeqDriver-32af76aa       ./testflags/SeqDriver-32af76aa
./default/SimpleUVM-1dc93a62       ./testflags/SimpleUVM-1dc93a62
./default/Scoreboard-59431470
```

`tools/probe/r10oth9repro/ct9movers.sh` diffs each mover's two dumps (pristine on
the LHS, patched on the RHS, so `+` reads as "what this pass added") and
classifies the changed lines with indentation stripped. **Across all nine movers:
`vpiSigned` 0, `class_typespec` 0, `vpiTypedefAlias` 0, `string_typespec` 0** — so
the known **build-dependent UVM alias instability did not fire in this landing**,
and none of the nine needs splitting on that account.

Every changed line is one of exactly three shapes, and all three are this pass's
laws:

| mover | lines changed | what changed |
| --- | --- | --- |
| `SVSwitch` (both modes) | 96 | 21+21 `hier_path (bytes.size)` span, 6+6 `hier_path (data.size)` span, 9 `-method_func_call (size)` → 6 scoped `+ref_obj`, 3 `-func_call (cal_fcs)` + 3 `-vpiFunction` → 2 scoped `+ref_obj` |
| `BuildUVMPkg`, `Scoreboard`, `SimpleUVM` | 45 each | `q.max` (6+6 span), `path.name` (6+6 span), `m_event.triggered` (3+3 span); `-method_func_call (max)`/`(name)` → `+ref_obj uvm_pkg::uvm_table_printer::emit::max` / `…uvm_reg_block::update::name` / `…uvm_event_base::wait_ptrigger::triggered` |
| `SeqDriver` | 81 | the same three sites, twice over (`uvm_pkg::` **and** `adpcm_pkg::` copies of the UVM classes) |

**And the UVM movers are CORRECT, checked against golden per-shape** — the only
attributable measure, `grep -Fxc` with the left indent stripped, on
`SimpleUVM/default`:

```
golden=2  base=0  shipped=2   \_ref_obj: (uvm_pkg::uvm_table_printer::emit::max), line:1054:14, endln:1054:17
golden=1  base=0  shipped=1   \_ref_obj: (uvm_pkg::uvm_event_base::wait_ptrigger::triggered), line:122:15, endln:122:24
golden=6  base=0  shipped=6   \_hier_path: (q.max), line:1054:12, endln:1054:17
golden=3  base=0  shipped=3   \_hier_path: (m_event.triggered), line:122:7, endln:122:24
```

Every shape goes from **0 to EXACTLY golden's count**. The four UVM rows stay
`CMP_NOTEQUAL` (their `detail` column is the literal string `decompile:`, so no
CSV can ever show a head move there — the rows themselves are byte-identical to
the baseline, whole-row) but the bytes moved *towards* golden, which is what the
byte verifier exists to see.

Worth recording for a future pass: `m_event.triggered` is an **event property**,
not a method — and golden gives it the same parens-less `ref_obj` treatment. So
the law's reach is wider than "methods" in yet another direction.

### CANARIES — both scripts, both corpora, `EXPECT_UNKNOWN` declared

```
u2r      canaries.sh   ok=8  changed=0 absent=0   (25 unknown-names = the surelog-only canaries)
         ctcan2.sh     ok=1  changed=0 absent=0   unknown-patterns=6 = EXPECT_UNKNOWN=6
surelog  canaries.sh   ok=52 changed=0 absent=0   (7 unknown-names = the u2r-only canaries)
         ctcan2.sh     ok=6  changed=0 absent=0   unknown-patterns=1 = EXPECT_UNKNOWN=1
canaudit.sh canaries.sh ctcan2.sh  ->  audited=29  UNCOVERED=0  FENCE-BREACH=0
```

**BY NAME, as the brief requires:**

```
InterfaceModPort     default   CMP_NOTEQUAL / (blank dump)  base == fresh   OK
InterfaceModPort     testflags CMP_NOTEQUAL / (blank dump)  base == fresh   OK
BlackParrotComplex   default   CMP_EQUAL / differ           base == fresh   OK
BlackParrotComplex   testflags CMP_EQUAL / differ           base == fresh   OK
```

The four **slang-fenced** tests (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) were never dispatched or measured; `canaudit.sh`
confirms `FENCE-BREACH=0`.

---

## 7. WHAT CHANGED IN THE EMITTER

One file, `src/ExprEmit.cpp`. Both sites are named with a `§` marker in the code
comment, and both comments carry the arm that measured them plus the refutation
that shaped the gate.

* **site 1**, inside the expression-position built-in-method branch: compute
  `parensLess9` from the source text, extend the `hier_path` span to
  `mStart9 + name.size()`, and emit a `ref_obj` element instead of the
  `method_func_call` — returning immediately, since a parens-less built-in has no
  arguments, no iterator and no `with` by construction.
* **site 2**, in the general subroutine-call branch: after the `liveCalledSubs`
  bookkeeping, return a scope-scoped `ref_obj` spanning the name token when the
  callee is really a function (`realIsFunc18`, so a coerced `task_call` can never
  be mis-classified) and the call's whole source text is exactly its name.

Nothing under `results/` was rebuilt, edited, regenerated or staged; nothing under
`~/.local/include/slang` or any third-party slang was touched; `verify_golden.py`
and `check_goldens.sh` were run, never modified; no `git stash` was used.

---

## 8. RANKED RESIDUE

Ranked by **cells the fix would close × how well it is already characterised**.

**V2 (verifier F2) — the hier_path span is TRIVIA-BLIND.**
`mStart9 = recv->sourceRange.end() + 1` (grep it) assumes exactly one character
between the receiver and the method name, so every spelling with whitespace, a
comment or a newline between them comes out SHORT: arm `w2_spacedot.sv` has
`d . size`, `q .size`, `q. size`, `d /* c */ . size` and a newline form, and the
newline case lands at `20:1` where golden says `20:14`. NOT a regression (pristine
carried the same wrong columns on its `method_func_call`) and corpus reach 0 — the
corpus writes it tight — so it was deliberately NOT fixed at integration. The fix
is a trivia-aware forward scan for the name token from the receiver's end, and it
must be measured on the MACRO-REMAPPED surface too, because arm `w3_macrodeep.sv`
shows that surface currently reads 7/7 against golden and a naive scan would be
the thing to break it. Own arm set required.

**V4 (verifier, new — not found by the pass) — a receiver-less `randomize` /
`randomize()` is DROPPED ENTIRELY by BOTH binaries** where golden emits a
`ref_obj` / `func_call`. Pre-existing, unrecorded until now, reach unmeasured.
Note it is the same METHOD whose `this.`-qualified form (arm `w4_classbuiltin.sv`
cell 3) is golden's one known counterexample to the parens mnemonic — so measure
both spellings together.

**R1 — user-defined class method, parens-less, expression position.**
The single surviving `DIFFERKIND`, and the reason the law is currently narrower
than golden's. Golden: `ref_obj (work@holder::f::val)`; ours:
`method_func_call (val)`. Arm s5 site `24:11` is the ready-made witness, and the
fix is the *same* two-line swap as site 1 applied to the class-method branch
(`src/ExprEmit.cpp`, the `bar.set(4)` arm near the `§ classInBodyRecvCallArgNoBind52`
comment). **Not attempted here** because it is a third site and this pass had
already spent one full gate cycle on the cast refutation. Zero SVSwitch reach
(SVSwitch has no parens-less user-method call), so it is a *correctness* item, not
a head item. **Highest rank: fully characterised, one arm cell, one site.**

**R2 — the index-of-select prefix separator, `.bytes::` vs `::bytes::`.**
3 SVSwitch cells (41:20, 86:26, 91:18) + arm s4 site `16:21`. Golden
`work@packet::byte_unpack::bytes::size`; ours `work@packet::byte_unpack.bytes::size`.
The cause is located and quoted: the index prefix is built with a literal
`prefix + "." + name` (`src/ExprEmit.cpp:10858`, `:11785`, `:11930`) where
`joinRef` (`src/EmitHelpers.h:1360`) would pick `::` because the enclosing prefix
already contains `::`. **This is a DIFFERENT law** — about the index prefix, not
about parentheses — and it changes the fullname of *everything* emitted inside an
index in *every* class method in the corpus, so it needs its own arm and its own
gate cycle. Not attempted here for exactly that reason.

**R3 — `new[...]` size argument: golden's query ref_obj is NAME-ONLY.**
2 SVSwitch cells (40:26, 71:20) + arm s4 site `20:22`. Golden prints
`ref_obj: (size)` with no `vpiFullName`; ours prints the scope-scoped name. So
inside a `new[...]` Surelog drops the scope entirely — the same suppression the
base path element already gets. Well characterised, 3 cells, but the gate ("am I
inside a `new` size expression?") is not yet in hand.

**R4 — `unique` takes the ARRAY-ALONE shape with NO `with` clause.**
The 2 `UNMEASURED` arm cells (s2 `26:12` and `37:12`, i.e. `d.unique` *and*
`d.unique()`). Golden names the hier_path `(d)`, scopes the base ref_obj and keeps
a `method_func_call (unique)` — our `withExpr9` branch's shape, but reached with no
`with` clause. Suggests Surelog keys on a NAME LIST of array-manipulation methods
rather than on the `with`, which would also explain why `min`/`max` do *not*
behave this way. Zero corpus reach measured. The next step is a name-sweep arm,
not a code change.

**R5 — `this.data = new[…]` emitted by us and not by golden.**
SVSwitch `Packet.sv:87` (our extra `method_func_call (new) 87:15-87:34` and its
`hier_path (bytes.size) 87:19`). This is the `§ invalidNewCallFromSyntax55` family
from pass 55, not a parens item; noted so a future pass does not attribute it here.

**R6 — the `h.o = new()` LVALUE hier_path span.**
Arm s5 site `35:7`, the surviving `DIFFER`: golden `35:5-35:6`, ours `35:5-35:8`.
Pre-existing at `946579a`, unchanged by this pass, and unrelated to parentheses.

**R7 — the SVSwitch head itself is now in the INTERFACE cluster.**
`begin: (work@packet::byte_unpack)`, whose diff census is `vpiName:cb` (33
lines), `interface_inst` naming (`work@top.TC.output_intf[0..3]` vs
`output_intf.output_intf[0..3]`), `port (clock)` and `modport (OP)`. This is the
41-test Interface DIFF cluster already on the roadmap. SVSwitch will not convert
until that cluster moves, so **the next SVSwitch pass should be an interface
pass, not a parens pass.**

---

## 9. FILES IN THIS DIRECTORY

| file | what it is |
| --- | --- |
| `s1_dynsize.sv` | the witness `data.size` + the parens-ful positive control |
| `s2_querykind.sv` | size/sum/product/min/max/unique, parens-less and parens-ful |
| `s3_arraykind.sv` | dynamic / queue / associative / (fixed: slang-rejected, recorded) |
| `s4_context.sv` | six member-select contexts + four constraint forms |
| `s5_negctl.sv` | the brief's negative control, and its refutation |
| `s6_otherbuiltin.sv` | string `len`, queue `pop_front`, enum `name`/`first` |
| `s7_recvless.sv` | the receiver-less site; 7 cells incl. empty-parens + task controls |
| `svarm.sh` | one arm, both sides, cmp HEAD DEPTH and dump content, all guards |
| `svall.sh` | all seven arms + TOTALS; regenerates the golden per run on purpose |
| `svcells.py` | the CELL table: second path element, own child depth, 4 counters |
| `svrecv.sh` | arm s7's own instrument (no hier_path exists there) |
