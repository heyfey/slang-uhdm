# r10uvm77 — § classMethodParensLessStepIsRefObj77

**BASE 024b1b5.** Production surface: `src/ExprEmit.cpp` + one declaration in
`include/UhdmExporter.h` (+165 / −7). Probe surface:
`tools/probe/r10uvm77repro/` only.

**Result, up front: the 26-line head shared by SimpleUVM default, SimpleUVM
testflags and Scoreboard default is CLEARED on ALL THREE ROWS.** It advanced 17
source lines further into the same function, from
`uvm_sequencer_base.svh:664:87` to `681:23`, and the new head is a
*different family* (`part_select` / `vpiConstantSelect`) with two named
residues. Five gates green, zero canary rows moved, **4 movers on the surelog
corpus and every changed line attributed to this law alone.**

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

**Two of the brief's own premises are REFUTED by measurement (§7), and so is a
STATED LAW of the boundary owner r10svs2 (its F3).** Both refutations were
found before any code moved and both changed what got written.

---

## 1. THE LAW

```
§ classMethodParensLessStepIsRefObj77      src/ExprEmit.cpp, SITES 1-3
§ parensProbeIsTheGate77                   why it is neither expr.syntax nor expr.sourceRange
```

### § classMethodParensLessStepIsRefObj77

> A **CLASS METHOD** reference — built-in (`process::status`) or user-declared —
> written as the **TRAILING step of a dotted path** and **WITHOUT an argument
> list**, is not a call to Surelog. The enclosing `hier_path`'s **LAST PATH
> ELEMENT is a `ref_obj`** named for the method, carrying the ordinary
> **§ prefix-scoped `vpiFullName`**. The identical reference **WITH parentheses
> — even EMPTY parentheses — keeps a `method_func_call` element and no
> fullname.**

This is r10svs2's `§ parensLessCallIsPathRefObj` at its **second spelling**.
r10svs2 owns the SYSTEM-call form (`data.size`, `s.len`, `q.pop_front`), where
slang's `expr.sourceRange` **collapses onto the receiver alone** and that
collapse *is* the gate. A real class-method call collapses nothing: slang binds
an ordinary `CallExpression` spanning the whole dotted text, so r10svs2's gate
can never fire and every such step stayed a `method_func_call` — which is why
this head survived 76 passes with the machinery already named.

**Three conventions travel with it, and all three are MEASURED:**

| # | convention | evidence |
|---|---|---|
| a | the trailing element's `vpiFullName` is the ordinary `joinRef(prefix, name)` | arm c2: `work@top77c2.withloc.status` / `…noloc.status` / `work@top77c2.status` — one function, one function without, and module scope. The corpus agrees: `uvm_pkg::uvm_sequencer_base::grant_queued_locks::status` |
| b | **the SPAN of neither the path nor the element changes** | pristine and patched put the `hier_path` at `664:71-664:93` and the element at `664:87-664:93`; **golden puts them at exactly the same two places.** This law swaps a CLASS and adds a FULLNAME and touches nothing else |
| c | **parens-ful is untouched, including EMPTY parens** | arms c1 p2, c2 L2/N2, c3 U2, c4 e2/e4; and the 23 SimpleUVM cells named in §7/RF-2 |

**Refusal rules, both measured rather than assumed:**

* **STATEMENT position never reaches the law.** `p.status;` is emitted by an
  earlier arm as a flat `method_func_call` with an unbound prefix, and golden
  agrees byte for byte — arm c3 cells S1/S2, both sides, before and after.
* **A `this`-ROOTED path is FENCED OUT.** Golden *does* want a `ref_obj` there
  too (§7/RF-3, which refutes r10svs2's F3), but every element of a
  `this`-rooted path is **NAME-ONLY** in golden rather than scope-joined, and
  our own `this` element still carries the wrong span. Firing would trade one
  wrong field for another on a cell that stays wrong. Residue **R1**.

**Site count: 3.** All three are the places our emitter builds a `hier_path`
for a method call in EXPRESSION position:

| site | what it handles | corpus cell |
|---|---|---|
| 1 | slang-SYSTEM method (receiver in `call.arguments()[0]`, `thisClass()` null) | `o.randomize` (arm c3 U4). **No corpus cell reaches this site** — every corpus mover is a declared class method, `uvm_port_base::size()` included |
| 2 | class method, **DEEP or INDEXED receiver** (`deepRecv11`) | **the head**: `item.process_id.status` @664:71, `arb_sequence_q[i].process_id.status` @755/756, `maps[j].get_full_name` |
| 3 | class method, **one-name receiver** (`recv0` a `NamedValue`) | `cb_.get_inst_id`, `seq_item_port.size` (both BuildUVMPkg) |

### STATED GATE == CODE GATE

The prose says *a class method, trailing step of a dotted path, no written
argument list, expression position, not `this`-rooted*. The code gate at sites
2 and 3 is exactly:

```cpp
if (writtenArgs16(call).empty() && !methodParensWritten77(mNm11, sub.name)) {
    auto* rq11 = s.MakeRef_obj();
    rq11->VpiName(sub.name);
    rq11->VpiFullName(joinRef(prefix, std::string(sub.name)));
    rq11->VpiParent(hp11);
    setLoc(rq11, mNm11);          // the SAME span the method_func_call had
    elems11->push_back(rq11);
    hp11->Path_elems(elems11);
    return hp11;
}
```

and at site 1:

```cpp
bool parensLess9 =
    !withExpr9 &&
    (rawText(expr.sourceRange) == recvText ||         // r10svs2's arm, UNCHANGED
     (dots[0] != "this" && call.arguments().size() == 1 &&
      !methodParensWritten77(SourceRange(mStart9, mStart9 + name.size()), name)));
```

Term by term:

| prose | code |
|---|---|
| a class method | the enclosing `case` arm the site sits in |
| trailing step of a dotted path | `elems*` is the path element vector; this is its last `push_back` |
| **no written argument list** | `writtenArgs16(call).empty()` / `call.arguments().size() == 1` |
| **written WITHOUT parentheses** | `!methodParensWritten77(...)` |
| expression position | `!callStmtCtx0` on the enclosing `if` at sites 2 and 3; the `stmtCtx` early return at site 1 |
| not `this`-rooted | the pre-existing `if (thisRoot11) { … }` block **returns unconditionally** on all three of its arms, so sites 2 and 3 are UNREACHABLE for a `this` receiver — checked in the code, not assumed. At site 1, where `randomize` arrives with a null `thisClass()`, the explicit `dots[0] != "this"` |
| the ordinary prefix-scoped fullname | `joinRef(prefix, sub.name)` |

There is no fourth condition in the code that is absent from the prose and none
in the prose absent from the code. The pre-existing `classRecvCallHp39.insert`
at site 3 is deliberately **not** reached on the parens-less path: it exists so
a design-final pass can hand the call's ARGUMENTS the base's actual, and the
parens-less form has no arguments by construction.

### § parensProbeIsTheGate77 — and the two gates that are MEASURED WRONG

```cpp
bool UhdmExporter::methodParensWritten77(SourceRange nameRng, std::string_view nm) {
    if (nm.empty() || nameRng.start() == SourceLocation::NoLocation) return true;
    if (rawText(nameRng) != nm) return true;              // ANCHOR
    auto at = nameRng.end();
    std::string tail;
    for (size_t w = 64;; w /= 2) {
        tail = rawText(SourceRange(at, at + w));
        if (!tail.empty() || w <= 1) break;
    }
    auto p = tail.find_first_not_of(" \t\r\n");
    return p == std::string::npos || tail[p] == '(';
}
```

The probe reads the `(` **out of the source buffer**, scanning forward past
whitespace from the end of the method-name token. It is not a stylistic choice.
**Both obvious alternatives were tried or measured and both are wrong:**

1. **`expr.syntax->kind != InvocationExpression`** — r10svs2's
   `§ parensLessSyntaxKindRefuted`: reads false-positive inside a CAST and cost
   that pass four u2r rows. Not retried here; recorded so nobody retries it.
2. **`rawText(expr.sourceRange) == recvText + "." + name`** — the obvious
   generalisation of r10svs2's own gate. **THIS PASS BUILT IT, BUILT THE BINARY,
   AND THE CENSUS CAUGHT IT BEFORE IT LANDED.** For a class method slang often
   binds the `CallExpression` from the **member-access** syntax rather than the
   invocation, so `expr.sourceRange` excludes the argument list entirely:

   ```
   (cntxt.get_depth())              uvm_config_db.svh:203   range 203:63-203:78 == "cntxt.get_depth"
   return (m_sequencer.num_sequences());  uvm_sequence_base.svh:1266  range 1266:13-1266:38
   comp.uvm_report_fatal("GET_CFG_TYPE_FAIL", …)  uvm_utils.svh:720   range 720:9-720:30
   ```

   All three are written WITH parentheses, golden emits `method_func_call` for
   all three, and **we already agree with golden on all three**. A text-equality
   gate fires on every one. SimpleUVM carries **23 such cells against this law's
   3** — it would have broken 23 correct cells to fix 3, on every UVM database,
   and **Gate 4 would still have printed `0 differing ROWS`** because SimpleUVM
   is `CMP_NOTEQUAL` in the baseline either way. The row gate cannot see this
   class of error; the cell census can, and did.

The probe **refuses rather than guesses**, in the conservative direction
(anything ambiguous reads PARENS-FUL and keeps the pre-existing shape):

* `anchorOk` — the window must actually spell the method name. A spaced or
  macro-remapped spelling (`q . size`) fails it. That is r10svs2's F2 residue
  and it stays open, deliberately.
* an empty read or a buffer end reads PARENS-FUL.
* a leading comment starts with `/`, never `(`, so `x.m /*c*/ + 1` reads
  PARENS-LESS — correct. The one form it gets wrong is `x.m /*c*/ ()`; stated
  plainly, unmeasured in either corpus, residue **R5**.

---

## 2. CENSUS FIRST — SimpleUVM (default), design-wide, BOTH SIDES, span-keyed

`ct77cen.py` censuses the **TRAILING element of every dotted `hier_path`**, on
both sides, keyed by `(hier_path decompile name, hier_path START line:col)`.
The key carries the START and not the whole span: the two sides can disagree
about the END, and a key carrying the end would never join them — it would read
green while measuring nothing (r10uvm74's lesson). The value is a **MULTISET**
of `CLASS|fullname|span`, because Surelog prints an out-of-body method body
twice (package listing + module HOIST copy). A key present on only one side
prints `ABSENT` and **counts as a disagreement**.

### 2.1 The whole design, by TRAILING-ELEMENT CLASS

| | golden | ours pristine | ours patched |
|---|---|---|---|
| `hier_path` keys | 4438 | 4599 | 4599 |
| trailing `method_func_call` | 4261 | 4281 | **4274** |
| trailing `ref_obj` | 2952 | 3065 | **3072** |
| trailing `bit_select` | 306 | 305 | 305 |
| trailing `indexed_part_select` | 5 | 6 | 6 |
| **disagreeing keys (union 4832)** | — | **938** | **935** |

The population count is IDENTICAL before and after (4599 keys, 4832 union).
This law changes an object's CLASS and adds one FULLNAME — never its existence,
never its span. That invariant is the census's own control and it holds.

### 2.2 The disagreement SHAPES, and the law's entire population

| golden class → ours class | pristine | patched |
|---|---|---|
| **`ref_obj` → `method_func_call`** | **3** | **0** |
| `ref_obj` → `ref_obj` (fullname/span) | 303 | 303 |
| `ABSENT` → `method_func_call` | 283 | 282 |
| `ABSENT` → `ref_obj` | 95 | 96 |
| `method_func_call` → `ABSENT` | 195 | 195 |
| everything else | 59 | 59 |

**Three keys. That is the whole joinable population of this law in SimpleUVM,
and all three closed.** Every other shape is unchanged to the key.

| # | cell | method | golden | pristine | patched |
|---|---|---|---|---|---|
| 1 | `item.process_id.status` @664:71 | `grant_queued_locks` | `ref_obj uvm_pkg::uvm_sequencer_base::grant_queued_locks::status` @664:87 | `method_func_call (status)` | **= golden** |
| 2 | `arb_sequence_q[i].process_id.status` @755:11 | `m_choose_next_request` | `ref_obj …::m_choose_next_request::status` @755:40 | `method_func_call` | **= golden** |
| 3 | `arb_sequence_q[i].process_id.status` @756:11 | `m_choose_next_request` | `ref_obj …::m_choose_next_request::status` @756:40 | `method_func_call` | **= golden** |

### 2.3 The FOURTH cell — a real parens-less USER method in UVM

One more key moved, and it is the one that proves the law is not about
`process::status`:

```
maps[j].get_full_name  @143:82   G=ABSENT
                                 pristine  O=method_func_call (get_full_name)  @143:90
                                 patched   O=ref_obj (uvm_pkg::uvm_reg_shared_access_seq::body::get_full_name) @143:90
```

Source: `uvm_reg_mem_shared_access_seq.svh:143`,

```systemverilog
   rg.get_full_name(), maps[j].get_full_name), UVM_LOW);
```

— a **UVM typo**: the neighbouring 20 occurrences all write `()`, this one does
not. Golden's key is `ABSENT` only because the two sides put this `uvm_info`
macro body on different LINES (golden 116, ours 143 — a pre-existing macro-span
divergence, residue **R4**), so the key cannot join. **The OBJECT joins
perfectly:** the string
`uvm_reg_shared_access_seq::body::get_full_name` appears **twice in golden,
ZERO times in our pristine, and twice in our patched** — the same class, the
same fullname, the same two print views.

### 2.4 CORPUS REACH — every parens-less cell the two corpora contain

The byte gate (§4/Gate 5) found the whole population across both corpora, and it
is **eight source sites in three UVM trees, plus zero in all 679 uhdm2rtlil
databases**:

| site | source | kind |
|---|---|---|
| `uvm_sequencer_base.svh:664` `item.process_id.status` | uvm-1.2 + 1800.2 | built-in, deep receiver, inside a `with` |
| `uvm_sequencer_base.svh:755` `arb_sequence_q[i].process_id.status` | both | built-in, **indexed** receiver |
| `uvm_sequencer_base.svh:756` same | both | built-in, indexed receiver |
| `uvm_reg_mem_shared_access_seq.svh:143/147` `maps[j].get_full_name` | both | **USER method**, a UVM typo |
| `uvm_callback` `cb_.get_inst_id` (1800.2 pp line 27525) | 1800.2 only | USER method **inside a `with` clause** |
| `seq_item_port.size<1` (1800.2 pp line 51006) | 1800.2 only | **built-in `size`**, followed by `<` |

`SVSwitch` and `SimpleConstraint` are the predictor's two flagged non-movers —
both write EMPTY PARENS, which the artifact cannot see and the probe can.

### 2.5 The NEGATIVE cells in the same census — every one stays put

| cell | why golden keeps the call | ours (both builds) |
|---|---|---|
| `(cntxt.get_depth())` @203, `(m_sequencer.num_sequences())` @1266 | **EMPTY PARENS written** | `method_func_call` |
| `comp.uvm_report_fatal(…)` @720, `comp.uvm_report_warning(…)` @725, `id_v_ary.get(…)`, `rbs.read(…)`, `ri.read(…)`, `rit.read(…)`, `riu.read(…)` | **arguments written** | `method_func_call` |
| `alloc.randomize()`, `m_seq.randomize()` ×2, `param_t.randomize()`, `seq.randomize()`, `t.randomize()` | parens written | `method_func_call` |
| `gp.is_response_ok()`, `param_sequencer.get_current_item()`, `rm.get_severity()`, `report_message.get_action()`, `m_modified_report_message.get_action()`, `comp.before_export.write(…)` | parens written | `method_func_call` |

**23 cells that a text-equality gate would have broken.** They are the reason
§1's probe reads the source buffer.

---

## 3. THE GRID — cell for cell, five arms, LHS is ALWAYS golden

`ct77arm.sh` drives one arm (both tools, one scratch dir each, `sed 1d` on both
dumps); `ct77cells.py` builds the CELL table. A **CELL is ONE SOURCE SITE**,
keyed on the METHOD TOKEN's `line:col` — never on a dump line, because *an
object is not a dump occurrence*: the same object prints at several depths.
Fullnames are read at **OWN CHILD DEPTH**, never from the subtree.
`EQ` / `DIFFER` (same class, a field differs) / `DIFFERKIND` (different object
CLASS — the cell this law owns) / `UNMEASURED` (one side emits nothing).

### TOTALS

| arm | pristine | patched | arm status |
|---|---|---|---|
| `c1_builtin` — the corpus shape reduced | 5: EQ 2, **DIFFERKIND 3** | 5: **EQ 5** | CMP_FAIL 26 → 17; dump content-diff 30 → **21** |
| `c2_local` — the BINDING half, 2×2 | 5: EQ 2, **DIFFERKIND 3** | 5: **EQ 5** | CMP_FAIL → **PASS_CMP**, **DUMP_MATCH** |
| `c3_kind` — callee kinds + the `this` fence | 10: EQ 2, DIFFERKIND 4, UNM 4 | 10: **EQ 4**, DIFFERKIND 2, UNM 4 | dump 62 → **59** |
| `c4_edge` — other built-ins, indexed/deep, regimes | 8: EQ 4, DIFFER 1, **DIFFERKIND 3** | 8: **EQ 7**, DIFFER 1 | dump 22 → **13** |
| `v77w4_classbuiltin` — **r10svs2's OWN arm**, verbatim | 7: EQ 5, DIFFERKIND 1, UNM 1 | 7: EQ 5, DIFFERKIND 1, UNM 1 | **`cmp -s` on the two dumps: BYTE-IDENTICAL** |

Every row above was re-measured with both binaries run in the **SAME scratch
directory**, because uhdm-dump prints the absolute path of Surelog's synthesized
`builtin.sv` and two runs in two directories differ on 40 lines that have nothing
to do with the patch. A "byte-identical" claim made across two scratch dirs is
not a measurement, and the first cut of this table made exactly that mistake.

**`c2_local` goes to `PASS_CMP` + `DUMP_MATCH` — the whole arm is byte-identical
to golden.** That is the strongest single cell in the pass: an entire database,
built by both tools, identical.

### c1 — the corpus shape, and the parens-ful POSITIVE CONTROL beside it

```
SITE   HIER_PATH                GOLDEN                            OURS (pristine)      OURS (patched)
26:11  p.status                 ref_obj work@top77c1.f77.status   method_func_call     ref_obj …f77.status  ✓
30:11  p.status()               method_func_call status           method_func_call     method_func_call     ✓ untouched
33:11  p.status                 ref_obj work@top77c1.f77.status   method_func_call     ref_obj …f77.status  ✓
37:14  arb.find(item) with (…)  method_func_call find             method_func_call     method_func_call     ✓ untouched
37:47  item.process_id.status   ref_obj work@top77c1.f77.status   method_func_call     ref_obj …f77.status  ✓
```

Site `37:47` is `uvm_sequencer_base.svh:664` name for name, inside a `with`
clause on an array-locator method, and site `37:14` is that locator itself —
**the enclosing `with` call is byte-identical before and after**, so the law
reaches the inner step without disturbing the outer one.

### c2 — THE BINDING HALF, and the brief's premise REFUTED

The brief asserts golden's `ref_obj` "scopes to the FUNCTION-LOCAL `status`
@grant_queued_locks" and asks to "decode whether the binding requires a
same-named local in scope". The 2×2 answers it:

| site | context | local named `status` in scope? | golden |
|---|---|---|---|
| 18:11 | `withloc`, parens-less | **YES** (`int status;`) | `ref_obj work@top77c2.withloc.status` |
| 20:11 | `withloc`, parens-ful | YES | `method_func_call (status)` |
| 29:11 | `noloc`, parens-less | **NO** | `ref_obj work@top77c2.noloc.status` |
| 31:11 | `noloc`, parens-ful | NO | `method_func_call (status)` |
| 38:11 | module `initial`, parens-less | NO, and no function either | `ref_obj work@top77c2.status` |

**The local is irrelevant.** Golden emits the identical shape with and without
it and names it after whatever scope encloses the reference — the ordinary
`joinRef(prefix, name)`, no extra rule. The discriminator down every column is
the parentheses and nothing else. **And `grant_queued_locks` has no local named
`status` at all** (its locals are `q`, `idx`, `leading_lock_reqs`,
`blocked_seqs`, `not_blocked_seqs`, `q1`, `b`, `i`, `item`), nor does
`m_choose_next_request` (`i`, `temp`, `avail_sequence_count`,
`sum_priority_val`, `avail_sequences`, `highest_sequences`, `highest_pri`,
`s`) — so all three corpus cells are the `noloc` row.

### c3 — WHICH callee kinds, and the `this` FENCE

| site | source | golden | ours (patched) | verdict |
|---|---|---|---|---|
| 31:11 | `o.meth` — **USER class method**, parens-less | `ref_obj work@top77c3.f.meth` | **= golden** | **EQ** (r10svs2's residue R1, closed) |
| 32:15 | `o.meth()` | `method_func_call meth` | identical | EQ, untouched |
| 33:15 | `o.prop` — plain property | `ref_obj …f.prop` | identical | EQ, untouched |
| 34:15 | `o.randomize` — **built-in class method through a HANDLE** | `ref_obj …f.randomize` | **= golden** | **EQ** |
| 16:14, 20:18 | `this.randomize` | `ref_obj (randomize)`, **NAME-ONLY** | `method_func_call` | **DIFFERKIND — FENCED, residue R1** |
| 18:18, 19:18 | `this.meth`, `this.prop` | `ref_obj (meth)` / `(prop)`, name-only | ours emits **no element at all** | UNMEASURED, pre-existing |
| 39:7, 41:7 | `p.status;` / `p.status();` — **STATEMENT** | flat `method_func_call` + prefix | identical | byte-identical, before and after |

`o.randomize` is the cell that kills "randomize is special": through a handle it
obeys the law like any other method. Only the `this.` ROOT is different, and it
is different in its **naming regime**, not in its class.

### c4 — the EDGES

| site | source | golden | patched |
|---|---|---|---|
| 27:11 | `p.get_randstate` — another `process` built-in | `ref_obj …f.get_randstate` | **= golden** |
| 29:11 | `p.get_randstate()` | `method_func_call` | untouched |
| 32:11 | `q.size` — **r10svs2's SYSTEM-call regime** | `ref_obj …f.size` | **already correct at base, untouched** |
| 34:15 | `q.size()` | `method_func_call` | untouched |
| 36:17 | `parr[2].status` — **INDEXED receiver step** | `ref_obj …f.status` | **= golden**, and r10uvm74's `bit_select` step is unchanged |
| 39:18 | `o.in.pid.status` — **THREE-name receiver** | `ref_obj …f.status` | **= golden** |
| 42:21 | `dyn[dyn.size-1]` — array-scoped fullname regime | `ref_obj …f.dyn.size` | already correct, untouched |
| 44:19 | `new[dyn.size+4]` — NAME-ONLY regime | `ref_obj (size)` | `ref_obj …f.size` — **DIFFER, r10svs2's residue, unchanged by this pass** |

Cells 32/34/42/44 are the r10svs2 system-call regime and **none of them moved**:
that arm of the gate is byte-identical.

### v77w4 — r10svs2's OWN arm, run verbatim, BYTE-IDENTICAL

`w4_classbuiltin.sv` copied unchanged from `tools/probe/r10svs2repro`. All seven
cells identical before and after — the proof the `this` fence really is inert
and that the locator-with-`with` forms (`q.find_index with`, `q.find with`,
`q.find_first with`, `q.sum with`) are untouched by `!withExpr9`.

---

## 4. THE FIVE GATES

### Gate 1 — BUILD

Both trees configured and built at ABSOLUTE paths with `-j 2`; **the link line
was reached** in both before any measurement:

```
[100%] Linking CXX executable slang-uhdm
[100%] Built target slang_uhdm
```

md5 asserted **separately**, both 32-hex, and **different** from each other:

```
ffa7d00fb5a07ab1c6fca7639b2719fe  /tmp/wt_r10uvm77/build/slang-uhdm       (patched)
a72eeb765b73c70687aaa58f1f3cca89  /tmp/wt_r10uvm77pris/build/slang-uhdm   (pristine)
```

Both worktrees `rev-parse HEAD` = `024b1b5221a060ac95510ce6dd6f806940840070`.
The pristine tree's `git status --porcelain` is **EMPTY** — genuinely BASE
024b1b5, not a stale or half-reverted build — and its binary is **md5-identical
to the main-tree `build/slang-uhdm`**, which is the independent confirmation
that the pristine worktree really is the base commit. The patched tree's
porcelain is `M include/UhdmExporter.h`, `M src/ExprEmit.cpp` and the untracked
probe directory, and nothing else.

Every sweep's `cmds.txt` was grep-checked for the binary it actually ran, e.g.
`slang:   /tmp/wt_r10uvm77/build/slang-uhdm`.

### Gate 2 — GOLDENS

Run with `SLANG_UHDM` **exported explicitly** (`check_goldens.sh` and
`verify_golden.py` both silently default it to the main-tree binary):

* patched binary: **23 PASS / 0 FAIL**
* `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the harness genuinely reads
  the binary under test.

### Gate 3 — uhdm2rtlil corpus (`--mode testflags`, `--jobs 2`)

| | patched | pristine (control) |
|---|---|---|
| status | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** | identical |
| dump | **496 match / 183 differ / 52 blank** | identical |
| `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` | **0 differing ROWS (0 row-sides)** over 731 rows | 0 / 0 |

Whole-row diff, dump column included, mode-matched to the baseline. The
pristine sweep was run through the same gate **first**, so the baseline is
proven reachable on this machine before the patched result is credited.

### Gate 4 — surelog corpus, both modes (`--jobs 2`)

| mode | CMP_EQUAL | CMP_NOTEQUAL | SURELOG_FAIL | DEFERRED |
|---|---|---|---|---|
| default | **469** | **11** | **25** | **5** |
| testflags | **465** | **8** | **23** | **5** |

`ct8rows.sh` vs `results/golden_surelog.csv`: **0 differing ROWS (0 row-sides)**
over 1588 rows, **patched AND pristine**. Per-mode STATUS *and* dump-column
histograms identical baseline → fresh (default `225 match / 244 differ / 325`;
testflags `165 / 300 / 329`).

### Gate 5 — BYTE VERIFIER, both corpora, both modes, vs the PRISTINE 024b1b5 build

**Census prediction FIRST** (`ct77predict.py`, artifact-based, run on the
PRISTINE workdirs before either comparison):

| corpus | databases | `PREDICT_MOVE` | `DUMP_FAIL` |
|---|---|---|---|
| uhdm2rtlil (testflags) | 679 | **0** | 0 |
| surelog (both modes) | 953 | **11** | 0 |

```
PREDICT_MOVE default/BuildUVMPkg-bf853d43     parensLessSteps=18   <- MOVED
PREDICT_MOVE default/SVSwitch-db796243        parensLessSteps=1    <- did not move
PREDICT_MOVE default/Scoreboard-59431470      parensLessSteps=17   <- MOVED
PREDICT_MOVE default/SeqDriver-32af76aa       parensLessSteps=17   <- MOVED
PREDICT_MOVE default/SimpleConstraint-7fb819e9 parensLessSteps=2   <- did not move
PREDICT_MOVE default/SimpleUVM-1dc93a62       parensLessSteps=17   <- MOVED
… + the four testflags twins (Scoreboard testflags is SLANG_REJECT, no database)
```

**The uhdm2rtlil prediction is EXACT and it is an IMPOSSIBILITY PROOF for that
whole corpus**: not one of its 679 databases carries an argument-less trailing
`method_func_call` whose path ends where it ends, so no database there can reach
any of the three sites. **The surelog prediction is a loose envelope and says
so** (§8/R8): the artifact cannot see EMPTY PARENS, so `SVSwitch` and
`SimpleConstraint` are flagged and correctly do not move. A flagged non-mover is
EXPECTED; **an unflagged mover would be a FINDING, and there was none.**

| corpus | paths | movers | `SELFCHECK` | `SELFCHECK1` |
|---|---|---|---|---|
| uhdm2rtlil | 679 | **0** | 678 / 679 | **1** = 0 real + 1 corrupted |
| surelog | 953 | **7** | 952 / 953 | **8** = 7 real + 1 corrupted |

`PATH_SETS_IDENTICAL` on both. `SELFCHECK1` returning exactly `real + 1` is the
proof the comparator can see ONE changed database; on uhdm2rtlil, where the
prediction was 0 and the measurement was 0, `SELFCHECK1 = 1` is what separates
"nothing moved" from "the verifier saw nothing".

#### Movers, per-shape by MULTISET (`mv77.sh`; whitespace-stripped, sorted, `sed 1d` both)

| database | REMOVED | ADDED | size delta |
|---|---|---|---|
| default/BuildUVMPkg | 9 | 18 | **+694** |
| testflags/BuildUVMPkg | 9 | 18 | **+694** |
| default/SeqDriver | 13 | 26 | **+517** |
| testflags/SeqDriver | 13 | 26 | **+519** |
| default/SimpleUVM | 7 | 14 | **+174** |
| testflags/SimpleUVM | 7 | 14 | **+192** |
| default/Scoreboard | 7 | 14 | **+296** |

**Every size delta is NONZERO — by the MOVER RULE each is a proven real change.**
(A zero delta would have proven nothing.) The `ADDED = 2 x REMOVED` ratio is the
law's own arithmetic: one `method_func_call` line out, one `ref_obj` line **and**
one `|vpiFullName:` line in. Every removed shape is a `\_method_func_call:` and
every added shape is a `\_ref_obj:` or a `|vpiFullName:` — **not one line of any
other kind moved in any of the seven databases.**

#### Attribution: every moved shape grep-checked AGAINST GOLDEN (`mvgold77.sh`)

For each moved shape, `grep -Fxc` counts it in golden / pristine / patched.
**99 shape rows across the 7 movers. 90 are exactly golden's count. The 9 that
are not are two named families, and NEITHER is a regression:**

| family | rows | what it is |
|---|---|---|
| `ref_obj (…uvm_reg_shared_access_seq::body::get_full_name) @143:90` | 5 | golden emits **the same object with the same fullname** but at line 116 (BuildUVMPkg: 81874) — residue **R4**, the pre-existing macro-span divergence. The `\|vpiFullName:` row for it matches golden's count EXACTLY (1/1) in all 5. Our pristine had the wrong-CLASS object at the same wrong coordinate |
| `ref_obj (adpcm_pkg::…grant_queued_locks::status) @664:87` | 2+2 | SeqDriver only. Golden's second (`adpcm_pkg`) view names it **`adpcm_pkg::uvm_sequencer_base::grant_queued_locks::arb_sequence_q::status`** — with the queried ARRAY inserted, which is r10svs2's s4 "array-scoped" fullname regime, in the second view only. New residue **R9** |

The arithmetic at that one span makes the direction unambiguous: golden has
**4 objects** at `664:87` in SeqDriver (2 `uvm_pkg`-named, 2
`arb_sequence_q`-scoped); pristine had 4, **all of the wrong CLASS**; patched has
4, **2 byte-identical to golden and 2 off by one prefix segment.** The distance
strictly decreased.

Every one of the six `method_func_call` shapes BuildUVMPkg removed goes
`golden 0 / pristine N / patched 0`, and every one of its six `ref_obj` shapes
goes `golden N / pristine 0 / patched N` — **all 17 of its rows exactly golden**,
including the two cells only BuildUVMPkg reaches. Those two are worth naming,
because they are the law's whole KIND range in one database — read straight out
of `UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv`:

```
27525:  unique_callbacks_to_append = callbacks_to_append.unique( cb_ ) with ( cb_.get_inst_id );
51006:      if(seq_item_port.size<1)
81874:      rg.get_full_name(), maps[j].get_full_name), UVM_LOW, …
```

a **USER method inside a `with` clause**, a **built-in `size` followed
immediately by `<`** (the probe scans for `(`, finds `<`, and is right), and the
same `get_full_name` typo the uvm-1.2 tree carries. All three go
`golden N / pristine 0 / patched N`.

---

## 5. THE TARGET ROWS — the head

Measured with `rowheads.sh` (heads counted with `grep -c '^LHS:'` anchored at
column 0; a missing side prints SKIP-NOFILE and is COUNTED).

| row | pristine | patched | head OBJECT before | head OBJECT after | verdict |
|---|---|---|---|---|---|
| **SimpleUVM default** | 26 / 1 | 142 / 1 | `ref_obj (…grant_queued_locks::status)` @664:87 vs `method_func_call (status)` | `part_select arb_sequence_q` @681:23 | **CLEARED, ADVANCED** |
| **SimpleUVM testflags** | 26 / 1 | 142 / 1 | same | same | **CLEARED, ADVANCED** |
| **Scoreboard default** | 26 / 1 | 142 / 1 | same | same | **CLEARED, ADVANCED** |
| Scoreboard testflags | SKIP-NOFILE | SKIP-NOFILE | — | — | SLANG_REJECT, counted |
| SeqDriver default/testflags | 1422687 / 1 | 1422695 / 1 | `LHS: <null>` vs the whole `uvm_pkg` container | *same object* | +8 lines = the law's own |
| BuildUVMPkg default/testflags | 94 / 1 | 94 / 1 | `struct_typespec` | *unchanged* | cmp **BYTE-IDENTICAL** |
| ApbSlave, SVSwitch, both modes | 0 / 0 | 0 / 0 | PASS_CMP | PASS_CMP | unchanged |

**The 26-line head this pass was sent to kill is GONE on all THREE rows** — no
`status` object appears in any of the three cmps any more — and the three
patched cmps are still **one shared head object**, byte-identical to each other
with ids stripped, in both modes.

**Say the new number plainly: 26 → 142. The line count went UP, and that is an
advance, not a regression.** The head is `SafeCompare`'s first disagreement and
its `m_visited` short-circuit hides everything behind it, so a *deeper* object
standing at the head prints a *bigger* subtree. Head depth is never a distance
and is never reported as one.

### The NEW head, and its two residues, decoded

```
uvm_sequencer_base.svh:681:  leading_lock_reqs = arb_sequence_q[0:b-1];
LHS part_select: arb_sequence_q (…grant_queued_locks::arb_sequence_q), 681:23-681:44
RHS part_select: arb_sequence_q (…grant_queued_locks::arb_sequence_q), 681:23-681:44
```

Same class, same name, same span. Diffing the two halves of the cmp gives
**exactly two defects**, both new to the ladder and both named as residues:

1. golden carries `|vpiConstantSelect:1`, we carry nothing (residue **R2**);
2. the index reference's fullname is
   `…grant_queued_locks::arb_sequence_q::b` in golden and
   `…grant_queued_locks.arb_sequence_q::b` in ours — **a `.` where golden
   writes `::`**, a joinRef separator-regime bug (residue **R3**).

The head advanced 17 source lines within the SAME function and left the
hier_path family entirely.

### SeqDriver — the whole cmp delta is this law, line by line

SeqDriver's head is the standing **vector-form `<null>` prints the CONTAINER**
case: golden's side is `<null>` for the whole `uvm_pkg` vector, so ours prints
the entire package (1.42M lines). With object ids stripped
(`sed -E 's/, id:[0-9]+//g'`) the pristine→patched delta is **24 lines, 12
removed and 12 added, and every one is this law**:

```
-  2x \_method_func_call: (status), 664:87       +  2x \_ref_obj: (…grant_queued_locks::status), 664:87
-  2x \_method_func_call: (status), 755:40       +  2x \_ref_obj: (…m_choose_next_request::status), 755:40
-  2x \_method_func_call: (status), 756:40       +  2x \_ref_obj: (…m_choose_next_request::status), 756:40
-  2x \_method_func_call: (get_full_name), 143:90 + 2x \_ref_obj: (…uvm_reg_shared_access_seq::body::get_full_name), 143:90
                                                 +  8x |vpiFullName:…
```

Four cells × two print views, plus the eight fullname lines the swap adds:
`1422687 → 1422695` is `+8`, exactly the fullnames. **Zero lines outside the
law.**

---

## 6. CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `results/gate_uhdm2rtlil.csv` | ok=9 changed=**0** absent=0, unknown-names=25 (the printed expectation) |
| `canaries.sh` vs `results/golden_surelog.csv` | ok=52 changed=**0** absent=0, unknown-names=8 (the printed expectation) |
| `canaudit.sh canaries.sh ctcan2.sh` | audited=31 **UNCOVERED=0 FENCE-BREACH=0** |
| `ctcan2.sh` u2r, baseline FIRST, `EXPECT_UNKNOWN=6` | ok=1 changed=**0**, unknown-patterns=6 — PASS |
| `ctcan2.sh` surelog, baseline FIRST, `EXPECT_UNKNOWN=1` | ok=58 changed=**0**, unknown-patterns=1 — PASS |

`canaries.sh` here is r10uvm76's copy (md5 `af8ae95a524d26cf66bfd158b03a1d07`),
which is r10uvm52's list **plus** `indexed_partsel_array`; the original
`r10uvm52repro/canaries.sh` is md5 `e1f84a84bf5d3823d07ee81d7e6d0ef8` and its
NAMES list is a strict subset. Said out loud because "I ran the canary script"
is worthless without knowing which list ran.

Brief-protected names checked **BY NAME** against the committed baseline, row
for row, with `diff`: `InterfaceModPort` (`CMP_EQUAL/differ` ×2),
`BlackParrotComplex` (`CMP_EQUAL/differ` ×2), `SVSwitch`
(`CMP_EQUAL/differ` ×2 — r10svs2's row, now equal), `ApbSlave`, `SimpleUVM`,
`Scoreboard`, `SeqDriver`, `BuildUVMPkg` — **all 16 rows byte-identical** to
`results/golden_surelog.csv`. The four SLANG-FENCED names (`UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched by **no** driver
here, asserted by `canaudit.sh` rather than by inspection.

---

## 7. REFUTATIONS — stated plainly

**RF-1. The brief's BINDING premise is FALSE: golden's `ref_obj` does NOT
require a same-named local in scope, and `grant_queued_locks` has no local named
`status` at all.** The brief says "golden's ref_obj fullname scopes to the
FUNCTION-LOCAL `status` @grant_queued_locks" and asks to "census cells with NO
same-named local: does golden still emit ref_obj, and named what?". It does,
and it names it after the enclosing scope — arm `c2_local`'s 2×2 measures the
present/absent × parens/no-parens grid on one golden and the answer is uniform,
and **all three corpus cells are themselves in the no-local case**
(`uvm_sequencer_base.svh` 660-706 and 740-… declare no `status`). Had the law
been written on the brief's premise it would have needed a symbol lookup that
does nothing, and the third corpus cell family (`maps[j].get_full_name`, §2.3)
would have been missed entirely.

**RF-2. `rawText(expr.sourceRange) == recvText + "." + name` — the obvious
generalisation of the boundary owner's own gate — IS WRONG, and the census
caught it after the binary was built.** Three shapes in SimpleUVM alone make
slang's `CallExpression` range exclude the argument list: a parenthesized call
`(cntxt.get_depth())`, a parenthesized return `return (m_sequencer.num_sequences());`,
and a plain argument-bearing call `comp.uvm_report_fatal("…", …)`. 23 cells,
all correct at base, all would have flipped. **This is the same failure mode as
`§ parensLessSyntaxKindRefuted` at a different syntax node**, and it is why the
shipped gate reads the `(` out of the buffer. See §1.

**RF-3. r10svs2's F3 IS REFUTED, on r10svs2's own arm, with r10svs2's own
spelling.** F3 states: "`r = r + this.randomize;` is parens-less AND in
expression position, and **golden KEEPS `method_func_call: (randomize)
17:19-17:28`** … Do NOT 'simplify' the gate into an honest written-parens test —
that regresses `this.randomize`." Running
`tools/probe/r10svs2repro/w4_classbuiltin.sv` unchanged through both tools at
024b1b5:

```
GOLDEN  \_ref_obj: (randomize), line:17:19, endln:17:28     <- a REF_OBJ, name-only
OURS    \_method_func_call: (randomize), line:17:19, endln:17:28
```

The `method_func_call: (randomize) 17:19-17:28` that F3 quotes is **OURS, the
RHS** — the direction was read backwards. Golden wants a `ref_obj` there too.
So the stated reason not to widen the gate does not exist. **This pass still
fences `this` out**, but for a *different and measured* reason: every element of
a `this`-rooted path is NAME-ONLY in golden (`(randomize)`, `(meth)`, `(prop)`
— arm c3 cells 16:14, 18:18, 19:18), not `joinRef`-scoped, and our own `this`
element carries the wrong span, so firing would swap one wrong field for
another on a cell that stays wrong. Residue **R1** now carries the *correct*
reason and the two conventions a future pass must transcribe.

**RF-4. The brief's framing "this head is r10svs2's family at a hier_path
TRAILING step on a BUILT-IN (process::status)" is too narrow in one direction
and too wide in another.** Too narrow: the law reaches **USER-declared class
methods** identically (arm c3 `o.meth`, and the corpus's own
`maps[j].get_full_name`), which is r10svs2's residue R1 closed as a side effect.
Too wide: it is not r10svs2's *code* at all — r10svs2's gate is
`expr.sourceRange == recvText`, which is a property of how slang models SYSTEM
calls and can never fire on a class method. Two spellings of one law at three
separate emitter sites.

**RF-5. `p.status;` in STATEMENT position is protected by an EARLIER arm, not
by anything this law does.** Arm c3 cells S1/S2 are byte-identical on both sides
before and after. This is worth stating because r10svs2's F1 was exactly this
defect at its own site 2 — a statement-position hole in a parens law — and the
shape of the mistake is the same one every time.

**RF-6. The `with`-clause outer call is NOT touched, and that had to be
checked.** The corpus head sits INSIDE
`arb_sequence_q.find(item) with (… item.process_id.status …)`. Site 1's
`!withExpr9` keeps the OUTER locator on its own regime (named after the array
alone, spanned through the `with`'s `)`), while the INNER step goes through
site 2. Arm c1 measures both in one statement: site `37:14` (the locator) is
byte-identical before and after, site `37:47` (the inner step) converts.

---

## 8. RANKED RESIDUES

**R1 — the `this`-ROOTED path regime (the fence this pass installed).** Golden
emits a **name-only `ref_obj`** for `this.randomize`, `this.meth` and
`this.prop`; we emit a `method_func_call` for the first, **nothing at all** for
the second and third, and our `this` element carries the receiver's span where
golden carries the MEMBER's (`17:14-17:18` vs golden `17:19-17:28`). Three
conventions, all measured in arm c3 and in r10svs2's `w4`. *Highest-ranked: it
is the only DIFFERKIND this pass's own arms still carry, the shapes are already
written down, and UVM's TLM ports are generated from `this.`-rooted forms
(r10uvm73's `§ thisRecvCall11` note records +2011 elements from getting it
wrong once).*

**R2 — `vpiConstantSelect` on a `part_select` (HALF THE NEW HEAD).** Golden's
`arb_sequence_q[0:b-1]` @681:23 carries `|vpiConstantSelect:1`; we carry
nothing. Whether the flag is about the RANGE being constant-foldable (`b` is a
local `int`, so it is not) or about the select being written with a colon is
the question to settle first.

**R3 — the `joinRef` separator regime (THE OTHER HALF OF THE NEW HEAD).**
Golden names the index reference
`uvm_pkg::uvm_sequencer_base::grant_queued_locks::arb_sequence_q::b`; we name it
`…grant_queued_locks.arb_sequence_q::b` — **a `.` where golden writes `::`**,
at exactly one joint. Since the two residues share one object, R2 and R3 are one
pass.

**R4 — the macro-span divergence that keeps §2.3's fourth cell unjoinable.**
Golden puts `uvm_reg_mem_shared_access_seq`'s `uvm_info` macro bodies at
`116:58` where we put them at `143:82`. The OBJECTS agree exactly; only the
line/col do. Pre-existing, untouched by this pass, and it is the reason a
design-wide span-keyed census reports 195 `method_func_call → ABSENT` and 283
`ABSENT → method_func_call` shapes that are mostly the same objects at different
coordinates.

**R5 — the probe's one known blind spot: `x.m /*comment*/ ()`.** A comment
between the method name and its parentheses starts with `/`, so the probe reads
PARENS-LESS and would fire wrongly. Neither corpus contains the form; named
rather than discovered later. The neighbouring blind spot — `q . size`, spaces
around the dot — is refused by `anchorOk` and is r10svs2's F2 residue, still
open.

**R6 — r10svs2's `new[…]` NAME-ONLY fullname regime.** Arm c4 cell 44:19:
golden prints `ref_obj: (size)` with no fullname inside a `new[…]` size
argument, we print `…f.size`. Pre-existing, unchanged, and now the only
`DIFFER` left in c4.

**R7 — the receiver-less `randomize` dropped by BOTH binaries.** r10svs2's V4,
reproduced here as `v77w4` cell 18:19 (`UNMEASURED`): golden emits an object at
`18:19` and neither of our builds emits anything. Unmeasured reach, unchanged.

**R9 — the SECOND-VIEW fullname regime on SeqDriver's `adpcm_pkg` copy.**
Golden names the `664:87` step
`adpcm_pkg::uvm_sequencer_base::grant_queued_locks::arb_sequence_q::status` in
the `adpcm_pkg` view and `uvm_pkg::uvm_sequencer_base::grant_queued_locks::status`
in the `uvm_pkg` view — **the queried ARRAY is inserted into the prefix in the
second view only.** That is r10svs2's s4 "array-scoped fullname" regime showing
up per-VIEW rather than per-context, and it is the only place this pass's output
is off by one prefix segment. Not a regression (pristine had the wrong CLASS at
the same four slots) and not this law's business — it is `prefix` machinery.
`m_choose_next_request`'s two cells, which are NOT inside a `with` on the array,
match golden exactly in both views, which is the separating pair.

**R8 — the surelog predictor's looseness.** The artifact cannot see EMPTY
PARENS, so `ct77predict.py` flags every argument-less trailing
`method_func_call` whose span ends with its path — 26 candidates in SimpleUVM
against 4 real ones. A sharper predicate would have to read the SOURCE, which
the dump does not name. Named so the next pass does not mistake a loose envelope
for a tight one. On uhdm2rtlil the count is **0 of 679**, which is a genuine
impossibility proof for that whole corpus rather than an estimate.

---

## 9. FILES

| file | role |
|---|---|
| `c1_builtin.sv` | arm: the CORPUS SHAPE reduced — parens-less `process::status` as a trailing step, incl. the `with`-clause form and the parens-ful control |
| `c2_local.sv` | arm: THE BINDING HALF — same-named local present / absent × parens / no parens, plus module scope |
| `c3_kind.sv` | arm: callee KINDS (user method, property, `randomize`) + the `this` fence + STATEMENT position |
| `c4_edge.sv` | arm: other `process` built-ins, r10svs2's system-call regime, indexed and deep receivers, both fullname regimes |
| `v77w4_classbuiltin.sv` | arm: **r10svs2's own `w4_classbuiltin.sv`, copied verbatim** — the boundary owner's regression control, and the source of RF-3 |
| `ct77arm.sh` | arm driver — golden + ours + cmp + dump-diff, one scratch dir per arm |
| `ct77cells.py` | THE CELL TABLE — trailing element per SOURCE SITE, both sides, EQ/DIFFER/DIFFERKIND/UNMEASURED |
| `ct77cen.py` | design-wide TRAILING-ELEMENT census by MULTISET, both sides, span-keyed |
| `ct77predict.py` | artifact-based mover PREDICTION, run on the PRISTINE workdirs before the sweeps |
| `byteverify.sh` | Gate 5, with `SELFCHECK` + `SELFCHECK1` negative controls |
| `mv77.sh` | per-shape MULTISET content analysis of every mover, with size deltas |
| `mvgold77.sh` | the ATTRIBUTION: every moved shape `grep -Fxc`'d against GOLDEN, golden/pristine/patched triple per shape |
| `rowheads.sh` | per-row cmp head count for a NAMED subset of a workdir |
| `ct8rows.sh` | THE ROW GATE — whole-row diff vs the committed baseline + histograms |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary set and the audit that proves the set covers the brief |
