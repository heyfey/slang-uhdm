# r10uvm75 — § withIterRefBindsHoistNet75

**BASE bd4b122.** Production surface: `src/ExprEmit.cpp`, `src/TaskFuncEmit.cpp`,
`include/UhdmExporter.h` (+64 / −5). Probe surface:
`tools/probe/r10uvm75repro/` only.

---

## 1. THE LAW

```
§ withIterRefBindsHoistNet75
```

A **reference to an ARRAY-METHOD `with`-clause ITERATOR**, written inside an
**OUT-OF-BODY class method**, binds an **implicit `logic_net`** on the module
that HOISTS that class's package — the same wire the unresolvable class-property
names already bind (`classPropRefs` / `bindHoistedClassPropRefs`).

Surelog compiles an out-of-body body in the HOME PACKAGE's scope, where the
iterator name — which has no declaration anywhere — resolves to nothing. The
reference falls into the late-binding pool, and the importing module binds it to
a net of that name, MINTING a bare `logic_net` (`vpiNetType:1`, no typespec)
when it declares none.

Four conventions travel with it, and all four are transcribed:

| # | convention | value |
|---|---|---|
| a | **which references** | TWO sites: the **written iterator ARGUMENT** (`arb_sequence_q.find(item)`) and a **bare read of that iterator inside the with-EXPRESSION** (`avail_sequences.find with (item == i)`, `... .find_index(node) with (node == to_node)`) |
| b | **which methods** | **OUT-OF-BODY only.** An in-body method resolves at class scope and golden binds NOTHING (arm `b2_inbody`; corpus cells `uvm_domain::jump` @199 and `uvm_status_container::m_do_cycle_check` @295) |
| c | **which module** | only a module that **HOISTS the class's package**. No importer ⇒ no wire (arm `v75_nohoist`; and the whole **Scoreboard** row, §7 RF-1) |
| d | **one wire per NAME** | minted at the **FIRST** reference's span, then SHARED by every later function and by both sites (`work@top.item` @664:28-32 serves `grant_queued_locks`, `m_choose_next_request` and `m_unlock_req`) |

**Refusal rule.** A `hier_path` ELEMENT that happens to name the iterator
(`item.request`'s leading `item`, `item.process_id.status`'s leading `item`) is
**NOT** a reference for this law: golden leaves it bare AND unscoped, and we
already did. Those elements are built from TEXT by `buildDottedHierPath`; the
law never reaches them.

**Site count: 2 of 2**, both in `src/ExprEmit.cpp`, both under the pre-existing
`inClassBodyEmit` gate. No new binding machinery: both sites push into
`classPropRefs`, and `bindHoistedClassPropRefs` — which already owns the
per-name, first-reference, hoist-gated mint — does the rest.

### STATED GATE == CODE GATE

The prose says *an array-method `with`-clause iterator, referenced from an
out-of-body class method's own body*. The code gate is exactly:

```cpp
// site A — the written iterator ARGUMENT (built from syntax; no symbol)
if (inClassBodyEmit && classBodyHomePkg75)
    classPropRefs.push_back({ia9, std::string(rawText(ar9)), ar9,
                             classBodyHomePkg75});

// site B — a bare read of that iterator inside the with-expression
else if (classBodyHomePkg75 && withIterSyms75.count(&nv.symbol))
    classPropRefs.push_back({ref, std::string(nv.symbol.name),
                             expr.sourceRange, classBodyHomePkg75});
```

with `inClassBodyEmit = oob && classScope && !cloneMode` (unchanged, pre-existing)
and `classBodyHomePkg75` non-null **only** when `inClassBodyEmit` is true.
Site B's `else if` sits inside `if (inClassBodyEmit && !ref->Actual_group())`, so
an already-bound reference is never re-recorded.

`withIterSyms75` is filled from `CallExpression::SystemCallInfo::getIteratorInfo()
.second` — **the iterator symbol itself**, never the symbol KIND. That is
load-bearing: slang gives a **`foreach` loop variable the same
`SymbolKind::Iterator`**, and golden nets none (arm `b4_foreach`). A rule written
on the kind would have minted a `fv` wire that golden does not have.

There is no third condition in the code that is absent from the prose, and none
in the prose that is absent from the code. The module half (c) and the
first-reference/sharing half (d) are enforced by `bindHoistedClassPropRefs`,
which this pass did not touch.

---

## 2. CENSUS FIRST — SimpleUVM (default), design-wide, span-keyed, BOTH SIDES

### 2.1 The population: every `method_func_call` carrying `vpiWith`

`ct75cen.py`, keyed by `(method name, method span)`.

| measure | golden | ours pristine | ours patched |
|---|---|---|---|
| with-clause `method_func_call` prints | 21 | 18 | 18 |
| unique keys | 13 | 10 | 10 |
| keys with **no** written iterator arg | 1 | 1 | 1 |
| keys whose arg is **BOUND** | **7** | **0** | **7** |
| keys whose arg is **UNBOUND** | 5 | 9 | 2 |
| **per-key ARG-BINDING disagreements** | — | **7** | **0** |

The 3 golden-only keys are `randomize() with {...}` constraint calls (87/97/196)
that we do not emit at all — a different family, untouched, residue **R4**.

### 2.2 The cells: every ref named `item` / `node`, both sides

`ct75cells.py`, keyed by `(decompile, span)`, a one-sided key printing `ABSENT`
and COUNTING as a disagreement.

| measure | pristine | patched |
|---|---|---|
| total keys (union of both sides) | 84 | 84 |
| **disagreeing** | **20** | **8** |
| …of which are **this law's** | **12** | **0** |
| …of which are pre-existing other families | 8 | 8 |

**The 12, cell for cell** (LHS is always golden; all bind `logic_net` in golden
and nothing in pristine):

| # | site | cell | method | form | golden actual |
|---|---|---|---|---|---|
| 1 | A | `find(item)` @664:28 | `uvm_sequencer_base::grant_queued_locks` | OOB | `work@top.item` @664:28 |
| 2 | A | `find_first_index(item)` @677:39 | `grant_queued_locks` | OOB | `work@top.item` @664:28 |
| 3 | A | `find_first_index(item)` @1212:33 | `uvm_sequencer_base::m_unlock_req` | OOB | `work@top.item` @664:28 |
| 4 | B | `find with (item == i)` @859:52 | `uvm_sequencer_base::m_choose_next_request` | OOB | `work@top.item` @664:28 |
| 5 | A | `find_index(node)` @1922:44 | `uvm_phase::sync` | OOB | `work@top.node` @1922:44 |
| 6 | B | `with (node == to_node)` @1922:56 | `uvm_phase::sync` | OOB | `work@top.node` @1922:44 |
| 7 | A | `find_index(node)` @1923:44 | `uvm_phase::sync` | OOB | `work@top.node` @1922:44 |
| 8 | B | `with (node == from_node)` @1923:56 | `uvm_phase::sync` | OOB | `work@top.node` @1922:44 |
| 9 | A | `find_index(node)` @1970:44 | `uvm_phase::unsync` | OOB | `work@top.node` @1922:44 |
| 10 | B | `with (node == to_node)` @1970:56 | `uvm_phase::unsync` | OOB | `work@top.node` @1922:44 |
| 11 | A | `find_index(node)` @1971:44 | `uvm_phase::unsync` | OOB | `work@top.node` @1922:44 |
| 12 | B | `with (node == from_node)` @1971:56 | `uvm_phase::unsync` | OOB | `work@top.node` @1922:44 |

**All 12 AGREE after the patch**, including the two NET objects themselves:

```
golden   logic_net (work@top.item)  line:664:28  endln:664:32
patched  logic_net (work@top.item)  line:664:28  endln:664:32
golden   logic_net (work@top.node)  line:1922:44 endln:1922:48
patched  logic_net (work@top.node)  line:1922:44 endln:1922:48
```

**And the four NEGATIVE cells in the same census stayed NONE on both sides** —
they are what fixes the gate:

| cell | method | form | golden | ours (both builds) |
|---|---|---|---|---|
| `phases.find(item)` @199:26 | `uvm_domain::jump` | **IN-BODY** | NONE | NONE |
| `m_uvm_cycle_scopes.find_first(item)` @295:57 | `uvm_status_container::m_do_cycle_check` | **IN-BODY** | NONE | NONE |
| `with (item == scope)` @295:69 | same, site B | **IN-BODY** | NONE | NONE |
| `item` inside `hier_path (item.request)` @664:40 etc. | — | hier_path ELEMENT | NONE | NONE |

The in-body pair is the ONLY thing separating cells 1–12 from cells that must
not move: the source text of `uvm_domain::jump`'s call is the same shape as
`grant_queued_locks`'s, in the same package, in the same design, reaching the
same module.

### 2.3 The module's Nets vector, by NAME

`ct75nets.py` over `work@top` (`|vpiNet:` entries, both sides, in order):

| | golden | pristine | patched |
|---|---|---|---|
| `work@top` nets | 235 | 210 | **212** (+2 = `item`, `node`) |
| golden-only NAMES | — | 34 | 32 |

The +2 are exactly this law's two wires, at golden's spans. The remaining 32
golden-only names belong to other implicit-wire families (class-scope enum
constants, `this`, `count`, …) — residues **R1/R3**, untouched.

---

## 3. THE GRID — cell for cell, five arms, LHS is ALWAYS golden

Arm status (`ct75arm.sh`, both binaries). The arms' own heads are a pre-existing
`class_defn` divergence unrelated to this law; they are **byte-identical before
and after** and are reported as background, never as this law's business.

| arm | pristine | patched | dump content-diff |
|---|---|---|---|
| `b1_oob` | CMP_FAIL (head 1468) | CMP_FAIL (head 1480) — same head object | 66 → **46** |
| `b2_inbody` | **PASS_CMP** | **PASS_CMP** | 54 → 54 (unchanged) |
| `b3_share` | CMP_FAIL (2232) | CMP_FAIL (2248) — same head object | 90 → **68** |
| `b4_foreach` | CMP_FAIL (1440) | CMP_FAIL (1444) — same head object | 57 → **48** |
| `v75_nohoist` | **PASS_CMP** | **PASS_CMP** | 44 → 44 (unchanged) |

### b1 — OUT-OF-BODY, the positive arm (4 cells): 1/4 → **4/4 AGREE**

| cell | golden | ours pristine | ours patched |
|---|---|---|---|
| `a_arg` `q.find(item)` @19:17 | `logic_net work@top75a.item` | NONE | **= golden** |
| `h_elem` `item.req` @19:29 | NONE | NONE | NONE (untouched) |
| `a_arg` `iq.find_index(node)` @20:24 | `logic_net work@top75a.node` | NONE | **= golden** |
| `b_bare` `with (node == k)` @20:36 | `logic_net work@top75a.node` | NONE | **= golden** |

Nets: golden 4 / pristine **2** / patched **4** — names, spans AND ORDER
identical to golden.

### b2 — IN-BODY, the gate's negative (4 cells): 4/4 AGREE → **4/4 AGREE**

Byte-for-byte b1 with the method written inside the class. Golden mints **no**
`item`/`node` wire at all, and neither build does. **This arm is the reason the
law says OOB.** Had the gate been "an unresolved with-iterator", these four
cells would have moved and this arm would have gone `PASS_CMP → CMP_FAIL`.

### b3 — SHARING (6 cells): 2/6 → **6/6 AGREE**

Two OOB methods; `f1` and `f2` both write `item`, `f2` also introduces `node`.

| cell | golden | patched |
|---|---|---|
| `f1` `item` @16:16 | `work@top75c.item` (**minted here**) | **= golden** |
| `f2` `item` @22:17 | `work@top75c.item` (**the same wire**) | **= golden** |
| `f2` `node` arg @23:24 | `work@top75c.node` (minted here) | **= golden** |
| `f2` `node` bare @23:36 | `work@top75c.node` | **= golden** |

Nets: golden 4 / pristine 2 / patched **4**, `item` @16:16 and `node` @23:24 —
**one wire per name, at the first reference**, measured rather than assumed.

### b4 — THE KIND TRAP (4 cells): 3/4 → **4/4 AGREE**

One OOB method holding BOTH a with-iterator (`item`) and a `foreach` loop
variable (`fv`) — the same `SymbolKind::Iterator` in slang.

| cell | golden | patched |
|---|---|---|
| `q.find(item)` @16:16 | `logic_net work@top75d.item` | **= golden** |
| `foreach (iq[fv])` @17:17 | NONE | NONE |
| `iq[fv]` read @18:18 | `int_var …f3::fv` | `int_var …f3::fv` |

Nets: golden **3** (`c`, `r`, `item` — **no `fv`**) / patched **3**, identical.

### v75 — NO HOIST (4 cells): 4/4 AGREE → **4/4 AGREE**

The package is compiled but no module imports it. Golden binds nothing; both
builds bind nothing; `PASS_CMP` on both. This is Scoreboard's shape, reduced.

---

## 4. THE FIVE GATES

### Gate 1 — BUILD

Both trees configured and built at ABSOLUTE paths with `-j 2`; **the link line
was reached** (`[100%] Built target slang_uhdm`) before any measurement. md5
asserted **separately**, both 32-hex, and **different** from each other:

```
daa1e43880aaefb321072807a687abcb  /tmp/wt_r10uvm75/build/slang-uhdm       (patched)
e641888879aa9127aef922b2ad2dda2f  /tmp/wt_r10uvm75pris/build/slang-uhdm   (pristine)
```

Both worktrees `rev-parse HEAD` = `bd4b122066a310aad661c6258cc50a18be9308e2`.
The pristine tree is **`git status --porcelain` EMPTY** — genuinely BASE
bd4b122, not a stale or half-reverted build.

### Gate 2 — GOLDENS

Run with `SLANG_UHDM` **exported explicitly** (`check_goldens.sh` and
`verify_golden.py` both silently default it to the main-tree binary):

* patched binary: **23 PASS / 0 FAIL**
* `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the harness genuinely reads
  the binary under test.

### Gate 3 — uhdm2rtlil corpus (`--mode testflags`, `--jobs 2`)

| | value |
|---|---|
| status | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** |
| dump | **496 match / 183 differ / 52 blank** |
| `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` | **0 differing ROWS (0 row-sides)** over 731 rows |

Whole-row diff, dump column included. Both histograms identical baseline → fresh.

**An instrument defect caught here (the 16th).** The first u2r sweep of this
pass ran `--mode default` and `ct8rows.sh` printed **1462 differing ROWS**. The
rows had not moved: `results/gate_uhdm2rtlil.csv` is a **testflags** baseline, so
every row failed to join on the mode column and each was reported once as
REMOVED and once as ADDED. The script's own per-mode histogram made it
diagnosable in one read (`default base:` empty, `testflags fresh:` empty). The
run was redone in the mode the baseline is in. **A gate compared against a
baseline in a different mode reports total failure and measures nothing** — the
mirror image of a green reading that measures nothing. (The default-mode sweep
was run for BOTH binaries before the mode error was noticed, and its two dump
histograms are identical — `492 match / 187 differ / 52` on each — so it stands
as an extra, unplanned no-movement control in a mode the gate does not require.)

### Gate 4 — surelog corpus, both modes (`--jobs 2`)

| mode | CMP_EQUAL | CMP_NOTEQUAL | SURELOG_FAIL | DEFERRED |
|---|---|---|---|---|
| default | **469** | **11** | **25** | **5** |
| testflags | **465** | **8** | **23** | **5** |

`ct8rows.sh` vs `results/golden_surelog.csv`: **0 differing ROWS (0 row-sides)**
over 1588 rows. Per-mode STATUS **and** dump-column histograms identical
baseline → fresh (default `225 match / 244 differ / 325 blank`; testflags
`165 / 300 / 329`).

### Gate 5 — BYTE VERIFIER, both corpora, both modes, vs the PRISTINE bd4b122 build

**Census prediction FIRST** (`ct75predict.py`, artifact-based, run on the
PRISTINE workdir before the comparison):

| corpus | databases that CAN move | with-clause calls | DUMP_FAIL |
|---|---|---|---|
| uhdm2rtlil (testflags) | **0** of 679 | 0 | 0 |
| surelog (both modes) | **11** of 953 | 181 | 0 |

The 11: `SimpleUVM` ×2, `SeqDriver` ×2, `BuildUVMPkg` ×2, `Scoreboard` ×1,
`ApbSlave` ×2, `ArrayMethodIterator` ×2.

| corpus | paths | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil | 679 | **0** | 678 / 679 | **1** = 0 real + 1 corrupted |
| surelog | 953 | **4** | 952 / 953 | **5** = 4 real + 1 corrupted |

`PATH_SETS_IDENTICAL` on both. `SELFCHECK1` returning exactly `real + 1` is the
proof the comparator can see one changed law; on uhdm2rtlil, where the
prediction was **0** and the measurement was **0**, `SELFCHECK1 = 1` is what
separates "nothing moved" from "the verifier saw nothing".

**Prediction held as an envelope: 11 predicted, 4 moved.** The 7 predicted
non-movers are the law's two unmodelled-by-the-artifact gates doing their job:
`Scoreboard` and `BuildUVMPkg` compile uvm_pkg but no module of theirs hoists it
(RF-1); `ApbSlave` and `ArrayMethodIterator` have `with` clauses in bodies that
are not out-of-body class methods. Reported, not hidden.

#### Movers, per-shape by MULTISET (whitespace-stripped, sorted, `sed 1d` both)

| database | REMOVED | ADDED | size delta |
|---|---|---|---|
| default/SimpleUVM | **0** | 38 | **+279** |
| testflags/SimpleUVM | **0** | 38 | **+285** |
| default/SeqDriver | **0** | 38 | **+315** |
| testflags/SeqDriver | **0** | 38 | **+317** |

**Every size delta is NONZERO — by the MOVER RULE each is a proven real
change.** (A zero delta would have proven nothing.) `REMOVED=0` on all four
makes this a **PURE ADDITION**: nothing that existed was rewritten. The 38
added shapes are, identically in every database:

```
 12  |vpiActual:                     <- the 12 bindings (§2.2's cells 1-12)
  9  \_logic_net: line:1922:44       <- the `node` wire, printed per binding
  5  \_logic_net: line:664:28        <- the `item` wire, printed per binding
  2  |vpiNet:  +  2 \_module_inst:   <- the two Nets entries
  2  |vpiParent:  2 |vpiNetType:1
  1  |vpiName:item   1 |vpiFullName:work@top.item
  1  |vpiName:node   1 |vpiFullName:work@top.node
```

SeqDriver's module is `work@top_tb` (testbench.sv:210) and its two wires are
`work@top_tb.item` / `work@top_tb.node` at the SAME uvm spans — the law
reproduces on a second design with a different top, and SeqDriver's cmp head is
**byte-identical** before and after (43 lines, unchanged).

---

## 5. THE TARGET ROWS — the head

Measured with `rowheads.sh` (heads counted with `grep -c '^LHS:'` anchored at
column 0; a missing side prints SKIP-NOFILE and is COUNTED).

| row | pristine | patched | head OBJECT before | head OBJECT after | verdict |
|---|---|---|---|---|---|
| **SimpleUVM default** | 17 / 1 | 17 / 1 | `logic_net (work@top.item) @664:28` | `logic_net (work@top.SEQ_TYPE_LOCK) @664:54` | **ADVANCED** |
| **SimpleUVM testflags** | 17 / 1 | 17 / 1 | `logic_net (work@top.item) @664:28` | `logic_net (work@top.SEQ_TYPE_LOCK) @664:54` | **ADVANCED** |
| **Scoreboard default** | 26 / 1 | 26 / 1 | `ref_obj (…grant_queued_locks::status) @664:87` | *unchanged, cmp byte-identical* | not owned — RF-1 |
| Scoreboard testflags | SKIP-NOFILE | SKIP-NOFILE | — | — | SLANG_REJECT, counted |

**Say the line count plainly: it did not fall.** The head this pass was sent to
kill is GONE — `work@top.item` no longer appears in either SimpleUVM cmp — and
the object standing at the head now is a **different object of the same shape**:
golden's very next implicit wire, `work@top.SEQ_TYPE_LOCK` (golden id 197767 =
`item`'s 197766 **+ 1**), on the ref at `uvm_sequencer_base.svh:664:54`. Both
sides print the same 17 lines because both heads are one `logic_net` against
`<null>`. **A stable line count here is not a stable head**, and reporting "17 →
17, no progress" would have been the false reading.

The new head is the **class-scope ENUM CONSTANT** half of LAW C, which
`src/ExprEmit.cpp`'s own comment already names as a ranked residue ("The
implicit-net half is NOT implemented"). It is a different name family with a
different gate — residue **R1**, explicitly ONE HEAD AWAY and deliberately not
taken in this pass.

---

## 6. CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `results/gate_uhdm2rtlil.csv` | ok=9 changed=**0** absent=0, unknown-names=25 (the printed expectation) |
| `canaries.sh` vs `results/golden_surelog.csv` | ok=52 changed=**0** absent=0, unknown-names=8 (the printed expectation) |
| `canaudit.sh` | audited=31 **UNCOVERED=0 FENCE-BREACH=0** |
| `ctcan2.sh` u2r, `EXPECT_UNKNOWN=6` | ok=1 changed=**0**, unknown-patterns=6 — PASS |
| `ctcan2.sh` surelog, `EXPECT_UNKNOWN=1` | ok=58 changed=**0**, unknown-patterns=1 — PASS |

Brief-protected names checked **BY NAME** against the committed baseline, row
for row: `InterfaceModPort` (`CMP_EQUAL/differ` ×2) OK, `BlackParrotComplex`
(`CMP_EQUAL/differ` ×2) OK, and the four UVM rows this pass touches or could
have touched — `SimpleUVM`, `Scoreboard`, `SeqDriver`, `BuildUVMPkg` — all
byte-identical to `results/golden_surelog.csv`. The four SLANG-FENCED names
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched
by **no** driver here (asserted by `canaudit.sh`, not by inspection).

**Boundary check, by measurement.** The r10uvm74 arms (`b1_idxkind`,
`b2_position`, `b3_context`, `b4_foldidx`) and `§ builtinRecvIndexedStepIsBit
Select74` itself sit in the SAME builder this pass edits. Their protection here
is the `!withExpr9` fence they already carry (this pass adds no code on the
non-with path at all) plus Gate 3/4's 0-row result and Gate 5's `REMOVED=0`:
**no pre-existing object was rewritten anywhere in either corpus.**
`§ inheritedNameBindsPkgFn72` owns unqualified-CALL binding; this pass binds a
ref_obj's `vpiActual` and creates no call.

---

## 7. REFUTATIONS — stated plainly

**RF-1. The brief's "Scoreboard, IF the same law owns it" — IT DOES NOT, and
the census says so before any code was written.** Scoreboard's head is
`ref_obj (…grant_queued_locks::status)` vs our `method_func_call (status)` at
**664:87** — the parens-less-call family (`§ parensLessCallIsPathRefObj`), not an
implicit wire. And this law provably cannot own it: in **Scoreboard's golden**,
`ct75cen.py` reports **argBOUND=0 of 12** with-clause keys — golden binds
**nothing**, including at the very same `664:28` cell it binds in SimpleUVM.
The discriminator is the module: SimpleUVM's `testbench.sv` opens with
`import uvm_pkg::*;`, Scoreboard's with `import svunit_pkg::*;`, so nothing in
Scoreboard hoists `uvm_pkg`'s class bodies and there is no module to mint into.
Scoreboard's golden top DOES carry 10 implicit wires — all from **svunit_pkg**.
Its cmp is **byte-identical** before and after this patch.

**RF-2. The brief's mechanism reading was WRONG in the direction that would
have cost the most.** The brief calls the net "an implicit net minted on
work@top from a CLASS-METHOD body identifier … Surelog-bizarre", and asks
whether Surelog's implicit-net rules for "unresolved names in module-context
macro expansions" are responsible. There is no macro anywhere near it:
`uvm_sequencer_base.svh:664` is plain source. The wire is minted by the
**module hoist of an out-of-body method**, and this repository **already
implements that exact mechanism** (`classPropRefs` /
`bindHoistedClassPropRefs`, with `ApbSlave`'s `success`/`error_count`/`running`/
`test_count` as its measured witnesses). The whole pass is two `push_back`s into
a list that already existed. Chasing "Surelog's implicit-net rules" would have
built a second, parallel minting path with its own span and ordering bugs.

**RF-3. The brief's census instruction was RIGHT and its stated expectation was
WRONG.** It says "Vector-form `<null>` prints the CONTAINER — census work@top's
Nets vector BY NAME both sides FIRST", implying the head is a Nets-vector
mismatch. The Nets vectors DO mismatch badly (golden 235, ours 210) — and that
is **not** the head. The head is a **singular** `vpiActual`: golden's iterator-arg
`ref_obj` at 664:28 binds the wire and ours bound nothing, which is exactly the
`SafeCompare(singular, rhs=null)` shape (`LHS` = the object, `RHS: <null>`). The
census was run anyway and paid for itself twice: it produced the +2 control
(210 → 212, at golden's spans) and it showed that the 23 remaining golden-only
net names are other families, so "close the net gap" would have been the wrong
target.

**RF-4. "SymbolKind::Iterator" is NOT the gate, and a rule written on it
over-fires.** slang models a **`foreach` loop variable** with the same
`SymbolKind::Iterator` as an array-method `with` iterator. Arm `b4_foreach`
puts both in one out-of-body method: golden mints `item` and does **not** mint
`fv`. The gate is therefore membership in `withIterSyms75`, populated from
`getIteratorInfo().second` at the call site. (The pre-existing arm at
`ExprEmit.cpp:8167` does test the KIND — but it is guarded by
`implicitNetModule`, which is null during class-body emission, which is why it
never fired here and why this pass did not extend it.)

**RF-5. The `with`-clause form is NOT uniformly a blind spot.** r10uvm74's
residue R2 fenced the with-clause form out of the indexed-step law for want of a
measured cell. This pass measures the with-clause form thoroughly — and finds
that on the BINDING axis it is not special at all: the iterator argument obeys
the same hoisted-wire rule every other unresolvable out-of-body name obeys.
R2 remains open on its own axis (fullname/span of indexed steps under a with),
which this pass did not touch.

**RF-6. The predictor over-fires by construction and says so.** `ct75predict.py`
flags any database printing a `with`-clause call. It cannot see the OOB half or
the hoist half, both of which are real gates with measured negatives (`b2`,
`v75_nohoist`). A flagged non-mover is EXPECTED; an unflagged mover is a
FINDING.

---

## 8. RANKED RESIDUES

**R1 — the class-scope ENUM CONSTANT implicit wire (THE NEW HEAD, both
SimpleUVM rows).** Golden binds `ref_obj (…::SEQ_TYPE_LOCK)` @664:54 to
`logic_net (work@top.SEQ_TYPE_LOCK)` @664:54; we leave it unbound. Same
mechanism, same module, same statement — different NAME FAMILY: a class-scope
enum constant read from an out-of-body method. `src/ExprEmit.cpp` already
documents it ("The implicit-net half is NOT implemented"). Golden's work@top
carries `SEQ_TYPE_LOCK` (4 bindings) and `SEQ_TYPE_REQ` (3). *Highest-ranked: it
is literally the next object in the same expression, and the mechanism is the
one this pass just used.*

**R2 — the other 32 golden-only `work@top` net names.** `this` (35 bindings),
`count` (20), `m_sequencer_id` (5), `uvm_phase`, `param_t`, `phase_runner_proc`,
`req_item`, `top`, `p`, `sz`, `t`, … Several are duplicated in golden's vector
(`bld`, `common`, `cs`, `error_str`, `val`, `uvm_random_seed_table_lookup` appear
TWICE), which this pass's one-per-name model does not explain — that duplication
needs its own decode before any code moves.

**R3 — implicit-wire SPAN disagreement on 392 shared bindings.** Both sides bind
a wire of the right name, but golden's wire was minted at a different FIRST
reference than ours (`this`: golden @902:36, ours @152:45; `m_parent`: golden
@1001:10, ours @1925:11). This is a mint-ORDER law about `classPropRefs`'
emission order, entirely pre-existing, and **unchanged by this pass** — this
pass's own two wires land at golden's spans exactly.

**R4 — `randomize() with {...}` calls we do not emit (3 keys, 87/97/196).**
Golden prints them as `method_func_call` + `vpiWith`; we print no such object.
Different family (constraint blocks); named here because they are the only
golden-only keys in this pass's population census.

**R5 — Scoreboard's `status` head (26 lines).** `ref_obj` vs
`method_func_call` on the last element of `item.process_id.status`, in a design
where SimpleUVM gets it right. The parens-less-call family, NOT this law
(RF-1). *Its own pass, and its distinguisher is a design-level one worth
finding: the identical uvm source line emits two different shapes in two tests.*

**R6 — the arms' background head.** `b1`/`b3`/`b4` all still CMP_FAIL on a
`class_defn (p75x::c75)` head that is **byte-identical** before and after. It is
the arms' own unrelated background (a class_defn field this repo does not yet
match), not this law's business.

---

## 9. FILES

| file | role |
|---|---|
| `b1_oob.sv` | arm: OUT-OF-BODY, the positive (4 cells) |
| `b2_inbody.sv` | arm: IN-BODY, the gate's negative — same code, same names |
| `b3_share.sv` | arm: one wire per NAME, minted at the FIRST reference |
| `b4_foreach.sv` | arm: the `SymbolKind::Iterator` trap (`foreach` var must NOT be netted) |
| `v75_nohoist.sv` | arm: package compiled but never imported — Scoreboard's shape |
| `ct75arm.sh` | arm driver — golden + ours + cmp + dump-diff |
| `ct75cells.py` | per-CELL table: ref, parent kind, and vpiActual, BOTH sides |
| `ct75cen.py` | design-wide with-clause POPULATION census, both sides |
| `ct75nets.py` | module Nets-vector census by NAME, both sides, with ORDER |
| `ct75predict.py` | artifact-based mover PREDICTION, run before the sweeps |
| `byteverify.sh` | Gate 5, with `SELFCHECK` + `SELFCHECK1` negative controls |
| `mv75.sh` | per-shape mover analysis by MULTISET |
| `rowheads.sh` | head depth for named rows |
| `ct8rows.sh` | whole-ROW gate vs the committed baselines |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | canaries + the audit of the canaries |
