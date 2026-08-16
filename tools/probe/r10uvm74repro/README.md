# r10uvm74 — § builtinRecvIndexedStepIsBitSelect74

**BASE 61d5e36.** Production surface: `src/ExprEmit.cpp` only (+165 / −1).
Probe surface: `tools/probe/r10uvm74repro/` only.

---

## 1. THE LAW

```
§ builtinRecvIndexedStepIsBitSelect74
```

A step of a **built-in method call's RECEIVER path** that is **written with an
index** — `arb_sequence_q[i].request.name()`, `split_val[2].len()`,
`m_streams[name].exists(...)` — is a **`bit_select`** in golden, not a
`ref_obj`. Four conventions travel with it, and all four are transcribed:

| # | convention | golden | ours (before) |
|---|---|---|---|
| a | `vpiName` | the **BASE NAME ALONE** (`arb_sequence_q`) | the whole written component (`arb_sequence_q[i]`) |
| b | `vpiFullName` | the **CUMULATIVE dotted path** through this step (`mq[i]` at the base, `m.lq[i]` / `mq[i].lq[j]` at a middle step) | same as the name |
| c | `vpiIndex` | a child expression, **parented at the enclosing `hier_path`**, not at the `bit_select` | **no index child at all** |
| d | span | **the BASE NAME ALONE** — it ends *before* the `[` | ran through the closing `]` |

Sub-law for (c): an **integer-literal** index is a bare hand-built `constant`
(size 64, `UINT`, **no `vpiParent`**) — the same shape `buildDottedHierPath`'s
own constant-index arm writes. **Every other** index goes through `emitExpr`,
so it binds its `vpiActual` the way golden binds it, and a **compound** index
doubles its operands' fullnames through the hier display while a bare-name
index does not.

**Refusal rule.** The text split (`dots`) still decides the elements; the tree
walk only supplies the index *expression*. `builtinRecvStepSelectors74` returns
`false` — leaving every element the plain `ref_obj` it already was — unless the
bound tree agrees with the text split **component for component**. A
disagreement means text and tree describe different things (a dot inside an
index, a multi-dimensional select, a collapsed virtual-interface scope), and
there the pre-existing shape is the safe one.

**Site count: 1 of 1.** The `with`-clause form is deliberately fenced out by
`!withExpr9` — see residue **R2**.

### STATED GATE == CODE GATE

The prose above says *indexed step of a built-in method call receiver, text and
tree agreeing, no `with` clause*. The code gate is exactly:

```cpp
bool idxSteps74 = !withExpr9 && builtinRecvStepSelectors74(*recv, dots, stepSel74);
...
const Expression* sel74 = idxSteps74 ? stepSel74[k74] : nullptr;
if (sel74) { /* bit_select */ }
```

`stepSel74[k74]` is non-null for exactly the steps the **text** wrote with one
index **and** the bound tree confirms. No third condition exists in the code
that is absent from the prose, and none in the prose that is absent from the
code.

---

## 2. CENSUS FIRST — SimpleUVM (default), design-wide, span-keyed, BOTH SIDES

Population = every object whose decompiled text is a single indexed component
(`base[idx]`, one bracket pair) sitting **directly under a `hier_path`**.

Key is `(text, START line:col)` and **not** the whole span: the whole point of
this pass is that the two sides disagree about the END column, so a key
carrying the end would never join the sides and would read green while
measuring nothing.

| measure | pristine | patched |
|---|---|---|
| LHS (golden) indexed hier_path steps | **400** | **400** |
| RHS (ours) | **414** | **414** |
| shared keys | 332 | **340** (+8) |
| **DISAGREEING shared keys** | **47** | **0** |
| LHS-only keys | 68 | 60 |
| RHS-only keys | 82 | 74 |

**The population count is IDENTICAL before and after (400 / 414).** This law
changes an object's KIND and its END column — never its existence, never its
start. That invariant is the census's own control and it holds.

The **+8 shared** is the eight **middle-step** cells: our fullname was
`queue[i]` where golden's is `qc.queue[i]`, so they could not join as keys at
all. Once the fullname became cumulative they joined *and* agreed. (A first
cut of this census forbade the dot in the step text and under-counted the
population by exactly these eight, reporting them as one-sided noise instead of
as disagreements.)

### The 47, shape by shape

Every one had the identical shape pair:

```
LHS ('bit_select', 'idx=1', 'endcol=N')   RHS ('ref_obj', 'idx=0', 'endcol=N+k')
```

and the span delta `k` is **exactly `len("[" + index_text + "]")`**:

| delta | keys | example |
|---|---|---|
| +3 | 45 | `m_argv[i]` (1-char index) |
| +6 | 1 | `m_streams[name]` (4-char index) |
| +7 | 1 | `m_type_overrides[index]` (5-char index) |

That is the span law (d) proven arithmetically over the whole population, not
inferred from one cell.

---

## 3. THE GRID — cell for cell, four arms, LHS is ALWAYS golden

Arm status (`ct74arm.sh`, both binaries):

| arm | pristine | patched |
|---|---|---|
| `b1_idxkind` | CMP_FAIL (head 38 lines) | **PASS_CMP (0 heads)** |
| `b2_position` | CMP_FAIL (head 38 lines) | **PASS_CMP (0 heads)** |
| `b3_context` | CMP_FAIL (330) | CMP_FAIL (330) — **same head**, unrelated law |
| `b4_foldidx` | CMP_FAIL (70) | CMP_FAIL (70) — **same head**, residue R1 |

### b1 — INDEX KIND (7 cells): 0/7 → **7/7 AGREE**

| cell | golden | ours pristine | ours patched |
|---|---|---|---|
| `sq[i]` loop var | `bit_select 32:21-23 sq/sq[i] ref_obj` | `ref_obj 32:21-26 sq[i]/sq[i] NOINDEX` | **= golden** |
| `sq[2]` literal | `bit_select 35:18-20 sq/sq[2] constant` | `ref_obj 35:18-23 … NOINDEX` | **= golden** |
| `sq[0]` literal-0 | `bit_select 36:18-20 sq/sq[0] constant` | `ref_obj 36:18-23 … NOINDEX` | **= golden** |
| `sq[P]` param ref | `bit_select 37:18-20 sq/sq[P] ref_obj` | `ref_obj 37:18-23 … NOINDEX` | **= golden** |
| `sq[j + 1]` compound | `bit_select 38:18-20 sq/sq[j + 1] operation` | `ref_obj 38:18-27 … NOINDEX` | **= golden** |
| `saa[key]` string key | `bit_select 39:18-21 saa/saa[key] ref_obj` | `ref_obj 39:18-26 … NOINDEX` | **= golden** |
| `cq[0]` class queue | `bit_select 47:14-16 cq/cq[0] constant` | `ref_obj 47:14-19 … NOINDEX` | **= golden** |

### b2 — STEP POSITION (4 cells): 0/4 → **4/4 AGREE**

| cell | golden name/fullname | note |
|---|---|---|
| `mq[i]` base | `mq` / `mq[i]` | the head's own position |
| `m.lq[i]` middle | `lq` / **`m.lq[i]`** | fullname is CUMULATIVE |
| `mq[i].lq[j]` both | `lq` / **`mq[i].lq[j]`** | two indices, one path |
| `m.sq[i]` last | `sq` / **`m.sq[i]`** | index on the final receiver step |

Pristine printed `-` for the middle/last cells: we emitted a flat `ref_obj`
named `lq[i]`, so no object carried that text at all. That is the same
eight-cell blind spot the census names.

### b3 — CONTEXT (2 changed cells): 0/2 → **2/2 AGREE**, neighbours untouched

| line | cell | pristine | patched |
|---|---|---|---|
| 33 `sq[i].itoa(3);` | c_stmt | **no hier_path on either side** | unchanged — `§ deepRecvCall11` statement form builds none |
| 41 `iq[i].s.len()` | c_deeprecv | `ref_obj` | **`bit_select` = golden** |
| 43 `sq[i].len` | c_parenless | `ref_obj` | **`bit_select` = golden** |
| 45 `iq[i].getv()` | c_user | already `bit_select` | unchanged |
| 47, 48 `iq[i].v`, `iq[i].s` | c_read | already `bit_select` | unchanged |

Two cells changed; four were already right and stayed right. `§
parensLessCallIsPathRefObj` (r10svs2) governs the **last** element (the method
name) and is not disturbed — the indexed **base** is a different position.

### b4 — FOLDABLE INDEX (5 cells): 0/5 → **3/5 AGREE**, 2 = residue R1

| cell | golden | patched | verdict |
|---|---|---|---|
| `sq[MK]` module localparam | `bit_select … sq/sq[MK] ref_obj` | identical | **AGREE** |
| `sq[E1]` enum constant | `bit_select … sq/sq[E1] ref_obj` | identical | **AGREE** |
| `sq[1 + 1]` foldable expr | `bit_select … sq/sq[1 + 1] operation` | identical | **AGREE** |
| `sq[p4::PK]` pkg param, qualified | golden prints **`sq[2]`** (folded) | `sq/sq[p4::PK] constant` | DISAGREE — R1 |
| `sq[PK]` pkg param, imported | golden prints **`sq[2]`** (folded) | `sq/sq[PK] constant` | DISAGREE — R1 |

---

## 4. THE FIVE GATES

### Gate 1 — BUILD

Both trees built at absolute paths with `-j 2`; **the link line was reached**
(`[100%] Built target slang_uhdm`) before any measurement. md5 asserted
**separately**, both 32-hex, and asserted **different** from each other:

```
1104e3cfde7e5406226e92ea0de7f78e  /tmp/wt_r10uvm74/build/slang-uhdm       (patched)
98b4d0a565ccbd8054182fccba9b3c2d  /tmp/wt_r10uvm74pris/build/slang-uhdm   (pristine)
```

Both worktrees `rev-parse HEAD` = `61d5e3628e75a42ee83f4dbfa793e55713aad3d6`.
The pristine tree is **`git status --porcelain` EMPTY** — it is genuinely
BASE 61d5e36 and not a stale or half-reverted build.

### Gate 2 — GOLDENS

Run with `SLANG_UHDM` **exported explicitly** (`check_goldens.sh` and
`verify_golden.py` both silently default it to the main-tree binary):

* patched binary: **23 PASS / 0 FAIL**
* `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the harness is genuinely
  reading the binary under test.

### Gate 3 — uhdm2rtlil corpus (`--jobs 2`)

| | value |
|---|---|
| status | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** |
| dump | **496 match / 183 differ / 52 blank** |
| `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` | **0 differing ROWS (0 row-sides)** over 731 rows |

Whole-row diff, dump column included. Histograms identical baseline → fresh.

### Gate 4 — surelog corpus, both modes (`--jobs 2`)

| mode | CMP_EQUAL | CMP_NOTEQUAL | SURELOG_FAIL | DEFERRED |
|---|---|---|---|---|
| default | **469** | **11** | **25** | **5** |
| testflags | **465** | **8** | **23** | **5** |

`ct8rows.sh` vs `results/golden_surelog.csv`: **0 differing ROWS** over 1588
rows. Per-mode STATUS **and** dump-column histograms identical baseline →
fresh.

### Gate 5 — BYTE VERIFIER, both corpora, both modes, vs the PRISTINE 61d5e36 build

**Census prediction FIRST** (artifact-based, run before the sweeps):
8 databases *can* move on surelog (902 flagged prints, `DUMP_FAIL=0`);
**0 databases can move on uhdm2rtlil**.

| corpus | paths | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil | 679 | **0** | 678 / 679 | **1** |
| surelog | 953 | **7** | 952 / 953 | **8** = 7 real + 1 corrupted |

`PATH_SETS_IDENTICAL` on both. `SELFCHECK1` returning exactly `real + 1` is
the proof the comparator can see one changed law.

Prediction held as an envelope: 8 predicted, **7 moved**. The one predicted
non-mover is `default/Rggen-50ccbd70` — its indexed hier_path steps are not
built-in-method-call receivers, so this law's single site never fires there.
The prediction is an upper bound on *reachability*, not a claim of change.

#### Movers, per-shape by MULTISET (whitespace-stripped, sorted, `sed 1d` both)

| database | REMOVED | ADDED | size delta |
|---|---|---|---|
| default/SimpleUVM | 196 | 970 | **+6936** |
| testflags/SimpleUVM | 196 | 970 | **+6950** |
| default/Scoreboard | 196 | 970 | **+6911** |
| default/BuildUVMPkg | 216 | 1054 | **+7585** |
| testflags/BuildUVMPkg | 216 | 1054 | **+7585** |
| default/SeqDriver | 368 | 1956 | **+13569** |
| testflags/SeqDriver | 368 | 1956 | **+13580** |

**Every size delta is NONZERO — by the MOVER RULE each is a proven real
change.** (A zero delta would have proven nothing.) The ADDED shapes are
`bit_select` + the `ref_obj`/`constant`/`operation` index children and their
`hier_path` re-prints; the REMOVED shapes are the flat `ref_obj` steps they
replace.

---

## 5. THE THREE TARGET ROWS — the head

Measured with `rowheads.sh` (heads counted with `grep -c '^LHS:'` anchored at
column 0; a missing side prints SKIP-NOFILE and is COUNTED).

| row | pristine | patched | verdict |
|---|---|---|---|
| **SimpleUVM default** | 42 lines / 1 head | **17 / 1** | **CLEARED** |
| **SimpleUVM testflags** | 42 / 1 | **17 / 1** | **CLEARED** |
| **Scoreboard default** | 42 / 1 | **26 / 1** | **CLEARED** |
| BuildUVMPkg (both) | 94 / 1 | 94 / 1 | head byte-identical — no regression |
| SeqDriver (both) | 1416141 / 1 | 1417051 / 1 | head byte-identical — see note |

The old head on all three target rows was:

```
bit_select: (arb_sequence_q[i]), line:554:32, endln:554:46
|vpiName:arb_sequence_q   |vpiFullName:arb_sequence_q[i]
|vpiIndex: \_ref_obj: (…::do_print::i), line:554:47, endln:554:48
           |vpiParent: \_hier_path: (arb_sequence_q[i].request.name)
```

It is **gone**. The new heads are elsewhere entirely (§7, R4).

**SeqDriver's line growth is not a regression.** Its head is `LHS: <null>` with
RHS the whole `uvm_pkg` **package** — a vector-form `<null>` prints the
CONTAINER, so the line count is a subtree print size, not a distance. The head
object is byte-identical before and after; the +910 lines are this law's new
`bit_select` objects printing inside that container.

---

## 6. CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `results/gate_uhdm2rtlil.csv` | ok=9 changed=**0** absent=0, unknown-names=25 (expected) |
| `canaries.sh` vs `results/golden_surelog.csv` | ok=52 changed=**0** absent=0, unknown-names=8 (expected) |
| `canaudit.sh` | audited=31 **UNCOVERED=0 FENCE-BREACH=0** |
| `ctcan2.sh` u2r, `EXPECT_UNKNOWN=6` | ok=1 changed=**0**, unknown-patterns=6 — PASS |
| `ctcan2.sh` surelog, `EXPECT_UNKNOWN=1` | ok=58 changed=**0**, unknown-patterns=1 — PASS |

Brief-protected names checked **BY NAME**: `InterfaceModPort` OK,
`BlackParrotComplex` OK, `indexed_partsel_array` OK (`CMP_EQUAL/match`),
`hier_path` OK. The four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) are dispatched by **no** driver here.

### Two instrument defects FIXED before landing (the 14th and 15th)

1. **`canaries.sh` printed a STALE expectation.** This pass added
   `indexed_partsel_array` (u2r-only) to `NAMES`, which raises the SURELOG-csv
   unknown count from 7 to 8 — but the note still said "Expect 7". A reader
   checking the printed 8 against a text saying 7 cannot tell a new canary from
   a typo. Corrected to 8 / 25, with the reason inline. **STATED == CODE,
   including in the notes.**
2. **`b3_context.sv` mislabelled its cell.** Line 41 was commented `c_with —
   with-clause over an indexed receiver`, but the line carries **no `with`
   clause at all**. Citing it as the with-clause cell would have been this
   campaign's own "cited guard that does not exist" trap — and would have made
   residue R2 read as covered when it is not. Relabelled `c_deeprecv`, with the
   genuine with-form (`c_withreal`, plain receiver) named as the reason R2
   stands open.

---

## 7. REFUTATIONS — stated plainly

**RF-1. The brief's span reading was WRONG, and it is the load-bearing one.**
The brief says the golden span "ends at the `]`". It does not. Measured
character-exactly against `uvm-1.2/src/seq/uvm_sequencer_base.svh:554`:

```
cols 32..45  (golden span 32-46, end-EXCLUSIVE) = [arb_sequence_q]
cols 32..48  (OUR span 32-49)                   = [arb_sequence_q[i]]
our EXTRA 3 chars (cols 46..48)                 = [[i]]
cols 47..47  (golden index span 47-48)          = [i]
```

Golden's span is the **BASE NAME ALONE** and ends **before the `[`**. Had the
law been coded to the brief's reading, all 47 cells would have been emitted
three columns too long and the head would not have cleared.

**RF-2. The brief's guess at our three extra characters was WRONG.** It
proposed `.re` (i.e. that we were spanning into the next step). We were not:
the extra chars are exactly `[i]` — the index text with its brackets. Confirmed
across the whole population, where the delta is `len("[" + index + "]")` for
every one of the 47 (45×+3, 1×+6 `m_streams[name]`, 1×+7
`m_type_overrides[index]`).

**RF-3. "The population is likely >> 1 — every `queue[i].field` walk in uvm."**
Half right, and the wrong half matters. The population *is* large — 400 golden
indexed hier_path steps in SimpleUVM alone. But only **47** were wrong. Every
ordinary `queue[i].field` **read** already went through `emitMixedHierPath`
correctly (b3 cells c_read, already `bit_select` in pristine). The broken
family was **only** the built-in-method-call receiver path. A fix scoped to
"every indexed hier_path step" would have rewritten 353 already-correct
objects.

**RF-4. The census prediction over-fired by one and that is correct
behaviour.** 8 databases predicted movable, 7 moved. `Rggen` is reachable by
the *census population* but not by the *law's site*. Reported, not hidden.

**RF-5. Golden's constant-folding of an index is SCOPE-dependent** (b4). A
**package**-scoped localparam index folds — golden prints `sq[2]` for both
`sq[p4::PK]` and `sq[PK]`. A **module** localparam (`sq[MK]`), an **enum
constant** (`sq[E1]`) and a **foldable expression** (`sq[1 + 1]`) do **not**
fold. This is the same context-dependence the campaign already recorded for
genvar-vs-localparam CA folding. **Neither corpus reaches it** — b4 exists
precisely to make "no folded-constant index reaches this builder" a
measurement rather than a hope, and the answer is that the *arm* reaches it and
the *corpora* do not.

---

## 8. RANKED RESIDUES

**R1 — package-localparam index fold (2 b4 cells, 0 corpus rows).** Golden
folds a package-scoped localparam index into the fullname (`sq[2]`); we keep
the written text (`sq[p4::PK]`). Kind, span and index-kind are already correct
— only `vpiFullName` differs. Unreached by both corpora (u2r 0 movers, surelog
0 row changes). *Highest-ranked because it is fully decoded and one field
wide.*

**R2 — `with`-clause over an INDEXED receiver: no measured cell exists.**
Fenced out by `!withExpr9`. That arm names its `hier_path` after the array
alone and scopes every element's fullname, so combining it with this law is
unmodelled. `b3`'s `c_withreal` is on a **plain** receiver and therefore does
not cover it. *Needs its own arm before any code touches the combination.*

**R3 — macro-position residue: 60 LHS-only / 74 RHS-only keys.** Both sides now
emit `('bit_select', 'idx=1', …)`; the keys fail to join because the
`(line, col)` differ — uvm-1.2's `uvm_field_*` macro bodies get different
location attribution between Surelog's preprocessed output and ours. The
400/414 population gap is **constant before and after**, so this law neither
created nor destroyed anything here. Belongs to the location-attribution
family, not to this one.

**R4 — the new heads, two different next-layer laws.**
*SimpleUVM (both modes):* `LHS logic_net (work@top.item) @664:28` parented at
`module_inst work@top` — a net golden emits and we do not.
*Scoreboard (default):* `LHS ref_obj (…::grant_queued_locks::status) @664:87`
inside `hier_path (item.process_id.status)` — a hier_path step naming residue.
These are **different** heads on the two rows and want separate passes.

**R5 — arms b3/b4 still CMP_FAIL on pre-existing unrelated heads.** b3's head
is `class_defn work@b3::agg` (the `q.sum() with (item)` array-manipulation
law); b4's is unchanged at 70 lines. Both heads are **byte-identical** before
and after this patch — they are the arms' own background, not this law's
business.

---

## 9. FILES

| file | role |
|---|---|
| `b1_idxkind.sv` | arm: index KIND (7 cells) |
| `b2_position.sv` | arm: step POSITION in the path (4 cells) |
| `b3_context.sv` | arm: neighbouring CONTEXTS that must not move |
| `b4_foldidx.sv` | arm: indices that might FOLD (residue R1) |
| `ct74arm.sh` | arm driver — golden + ours + cmp + dump-diff |
| `ct74cells.sh` | per-CELL table; prints kind **and** span **and** index-child kind |
| `ct74cen.py` | design-wide CENSUS, span-keyed, both sides |
| `ct74predict.py` | artifact-based mover PREDICTION, run before the sweeps |
| `byteverify.sh` | Gate 5, with `SELFCHECK` + `SELFCHECK1` negative controls |
| `mv74.sh` | per-shape mover analysis by MULTISET |
| `rowheads.sh` | head depth for named rows |
| `ct8rows.sh` | whole-ROW gate vs the committed baselines |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | canaries + the audit of the canaries |
