# r10uvm78 — § everyPartSelIsConstSel78 + § partSelBoundPrefixJoinsByScope78

**BASE 5adb330.** Production surface: `src/ExprEmit.cpp` **only**
(+46 / −118 — this pass DELETES more than it adds). Probe surface:
`tools/probe/r10uvm78repro/` only.

**Result, up front: the 142-line head shared by SimpleUVM/default,
SimpleUVM/testflags and Scoreboard/default is CLEARED on ALL THREE ROWS**
(142 → **128**, one shared new head object, byte-identical across the three
cmps with ids stripped). Pass 77's residues **R2 and R3 are not merely fixed on
the head object — they are ZERO across BOTH ENTIRE CORPORA** on the patched
build: `d2objs=0 d3objs=0` over 22 491 + 875 select objects. Five gates green,
**8 movers, every one predicted by the census BEFORE the build and every moved
line attributed to these two laws alone**, all 8 strictly closer to golden.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

**One attractive generalisation of the law was MEASURED AND REFUTED before any
code moved (§7/RF-1), and a third site of the same joint family was found,
measured at 1 585 objects, and DELIBERATELY LEFT ALONE (§8/R5) — it touches a
canary.**

---

## 1. THE LAWS

```
§ everyPartSelIsConstSel78            src/ExprEmit.cpp, 12 sites
§ partSelBoundPrefixJoinsByScope78    src/ExprEmit.cpp, SITES 1-2
```

### § everyPartSelIsConstSel78  (pass 77's residue R2)

> **Every `part_select` and every `indexed_part_select` carries
> `vpiConstantSelect:1`, unconditionally.** The flag records the GRAMMAR
> production the select came from (`constant_range` / `constant_indexed_range`),
> not any evaluation of its bounds. A select with a variable end is still
> `vpiConstantSelect:1`.

This is not inferred from the corpus, it is read out of Surelog:

```
Surelog/src/DesignCompile/CompileExpression.cpp
  4235:  UHDM::part_select *part_select = s.MakePart_select();
  4256:  part_select->VpiConstantSelect(true);          <- no condition
  4260:  UHDM::indexed_part_select *part_select = s.MakeIndexed_part_select();
  4281:  part_select->VpiConstantSelect(true);          <- no condition
```

`compilePartSelectRange` is the **only** function in the whole of Surelog that
calls `MakePart_select` or `MakeIndexed_part_select` (`grep -rn` over
`Surelog/src/` returns exactly those two lines), and neither call is guarded.

**And it is confirmed empirically on 268 787 golden objects:** the census
instrument reports `d2objs=0` for GOLD over **267 461** select objects on the
surelog corpus and **1 326** on uhdm2rtlil. Not one golden part-select anywhere
in either corpus lacks the flag.

**What our gates were, and why they read false.** Twelve sites in `ExprEmit.cpp`
evaluated the bounds. Two different rules had accreted:

| arm | old gate | where it came from |
|---|---|---|
| SIMPLE `[a:b]` | **both ends** must `tryEval` | original |
| INDEXED `[a +: w]` | **the width** must `tryEval` | `§ hierSelConstWidthSuffices17` (r10earl17) |

r10earl17 had already walked half this road — it widened one site from
"both ends" to "constant width suffices" because `tl_i.a_data[8*i+:8]` read
false where golden reads true, and that was the head of four AllModules
entries. **Its direction was right and its measurement stands; it stopped one
step short of "there is no gate at all."** The 10 sites in `TypeEmit.cpp` and
`ModuleEmit.cpp` were already unconditional and are untouched by this patch.

**Where the corpus actually feels it, and why the population is so small.** IEEE
1800 requires a packed or unpacked array range to be a `constant_expression`, so
a SIMPLE `[a:b]` with a variable end is legal **only on a queue or dynamic
array**, and an indexed part-select's WIDTH must be constant, full stop. The
whole corpus population of R2 is therefore **two queue names**:

```
uvm_sequencer_base.svh:681   arb_sequence_q[0:b-1]     `uvm_sequence_request arb_sequence_q[$]`
uvm_sequencer_base.svh:694   arb_sequence_q[...]
uvm_pkg.sv:82821/83040/83087 abstractions[0:local_size__-1]   `string abstractions[$]`
```

and the INDEXED arm's gate could never fire on legal SystemVerilog at all —
which arm `c3_constsel.sv` establishes cell by cell.

### § partSelBoundPrefixJoinsByScope78  (pass 77's residue R3)

> A bound expression nested under a (indexed_)part-select is re-scoped through
> the select's own base name — the "doubled" part-select prefix. **That joint is
> a SCOPE JOIN and takes the enclosing scope's separator regime**: `::` in a
> package or class scope, `.` in a module or generate scope. It is
> `joinRef(prefix, name)`, never a hard `"."`.

The source of truth is UHDM, not a corpus pattern.
`UHDM/templates/BaseClass.cpp:100 ComputeFullName()` walks the parent chain
collecting names and then joins **the whole chain with ONE separator**:

```cpp
if ((parent_type == uhdmpackage) || (parent_type == uhdmclass_defn))
    column = true;
...
if (index > 0) fullName += column ? "::" : ".";
```

So a name computed lazily inside a class method is `::` at *every* joint — and
our eagerly cached names must agree at every joint. `joinRef` (`EmitHelpers.h`)
already decides exactly this question from the prefix it is handed; the two
`basePfx` lines simply were not asking it.

**The change is a NO-OP wherever the old code was right.** `joinRef` returns
`prefix + "." + name` unless the prefix's first `::` precedes its first `.`.
Every module and generate-scope prefix begins `work@<module>`, so it has no
`::` before its first `.` and comes back byte-identical. Only class- and
package-scoped prefixes move. That is not an argument — the corpus census
measured the firing set at **170 objects in 8 databases** before the build, and
the byte verifier then found exactly those 8 databases and no others.

### STATED GATE == CODE GATE

| prose | code |
|---|---|
| every part_select | 12 × `ps->VpiConstantSelect(true);` with **no enclosing `if`** — verify with `grep -n 'MakePart_select\|MakeIndexed_part_select\|VpiConstantSelect' src/ExprEmit.cpp` and read the indentation: every flag line sits at the same depth as its `Make…()` |
| unconditionally | the `ASTContext` / `tryEval` blocks that computed `constSel`, `constSelIdx17`, `widthConst` and `widthConst9` are **DELETED**, not left dangling — there is no variable left to re-gate on |
| the doubled bound prefix | `std::string basePfx = joinRef(prefix, nv.symbol.name);` ×2 |
| the enclosing scope's regime | `joinRef`, unchanged, its four documented cells intact |

There is no condition in the code absent from the prose and none in the prose
absent from the code — **and that is a RUN, not a sentence.**
`ct78gate.py <src/ExprEmit.cpp>` walks the file, pairs every construction site
with the nearest following flag line, and asserts they sit at the SAME
indentation (in this file's style that is true iff no block was opened between
them), then asserts 0 hard-joined and exactly 2 `joinRef`-joined `basePfx`
lines. It has a real negative control:

```
patched   src/ExprEmit.cpp    12/12 unconditional, 2/2 scope-joined  -> PASS, exit 0
pristine  src/ExprEmit.cpp    12 GUARDED, 2 hard-joined basePfx      -> FAIL, exit 5
patched   src/TypeEmit.cpp     7/7  unconditional                    -> PASS, exit 0
patched   src/ModuleEmit.cpp   3/3  unconditional                    -> PASS, exit 0
```

The last two lines are how the claim "the other 10 sites were already
unconditional and are untouched" is checked rather than asserted. An audit that
finds zero construction sites exits 4 rather than reporting success, and the
`basePfx` half is SKIPPED by filename outside `ExprEmit.cpp` — a guard that
fires where it does not apply is worse than no guard.

---

## 2. THE INSTRUMENT, AND WHY IT IS NOT A DUMP GREP

`r10uvm78cen.cpp` opens a `.uhdm` with UHDM's own `Serializer` and walks
`Serializer::AllObjects()`. Three reasons that beats grepping `uhdm-dump`:

* **it sees objects a dump cannot.** A dump prints what some parent points at;
  `AllObjects()` is every object the serializer holds.
* **it reads the FIELD, not the rendering.** `VpiConstantSelect()` is a bool;
  the dump only prints it when true, so "absent" and "false" are the same text.
* **it counts each object ONCE.** The dump reprints an object at every
  reference, and a shape census over dump text silently multiplies.

Five detectors, and it prints a `TOTALS` line **always**, including on
`RESTORE_FAIL` — a run that reached nothing must never read as perfection.

| id | what it flags |
|---|---|
| **D2** | a select whose `vpiConstantSelect` is false (residue R2) |
| **D3** | a select whose own fullname ends `::<base>` while a bound ref under it begins `<scope>.<base>` (residue R3) |
| **D4** | a select whose OWN fullname ends `.<base>` in a `::`-first scope |
| **D5** | the same joint one family over: a `bit_select` with an OPERATION index (residue R5) |
| `R10UVM78_LIST=1` | the RAW joint inventory, no predicate — so a claim about golden is READ OFF the artifact, not inferred from a detector |

---

## 3. THE CENSUS — an EXACT prediction, made before the patched build existed

Run with `ct78cen.sh` over the **pristine** sweep workdirs, both sides.

| corpus | side | select objects | D2 | D3 | D4 | D5 |
|---|---|---|---|---|---|---|
| surelog (both modes, 953 db) | **GOLD** | **267 461** | **0** | **0** | 28 | **0** |
| surelog | OURS | 22 491 | **34** (7 db) | **170** (8 db) | 4 | 1 585 (10 db) |
| uhdm2rtlil (testflags, 679 db) | **GOLD** | **1 326** | **0** | **0** | 0 | **0** |
| uhdm2rtlil | OURS | 875 | **0** | **0** | 0 | **0** |

**The uhdm2rtlil line is an IMPOSSIBILITY PROOF for that whole corpus**: not one
of its 679 databases carries a select with either defect, so no database there
can move. It did not.

**PREDICT_MOVE, per database** (union of D2 and D3):

| database | D2 objs | D3 objs | predicted | MOVED |
|---|---|---|---|---|
| default/BuildUVMPkg | 3 | 17 | YES | **YES** |
| testflags/BuildUVMPkg | 3 | 17 | YES | **YES** |
| default/Scoreboard | 4 | 16 | YES | **YES** |
| default/SeqDriver | 8 | 32 | YES | **YES** |
| testflags/SeqDriver | 8 | 32 | YES | **YES** |
| default/SimpleUVM | 4 | 16 | YES | **YES** |
| testflags/SimpleUVM | 4 | 16 | YES | **YES** |
| **default/Earlgrey_0_1** | **0** | **24** | YES | **YES** |
| every other database, both corpora | 0 | 0 | NO | **no** |

**8 predicted, 8 measured, 0 unpredicted, 0 flagged-but-inert.** The prediction
is EXACT, not an envelope — and it even predicts the per-database magnitude: the
D2 object counts 4 / 4 / 3 / 8 / 0 are precisely the `|vpiConstantSelect:1`
multiplicity deltas the movers show (§5).

**On the PATCHED build the census reads `d2objs=0 d3objs=0` on BOTH corpora**,
with `sel` unchanged at 22 491 / 875 — the laws add no objects and remove none.

---

## 4. THE FIVE GATES

### Gate 1 — BUILD

Both trees configured and built at ABSOLUTE paths with `-j 2`; the link line was
reached in both before any measurement (`[100%] Linking CXX executable
slang-uhdm`). md5 asserted **separately** from the build exit, both 32-hex and
different from each other:

```
54198774ff82b6420692f76233c66207  /tmp/wt_r10uvm78/build/slang-uhdm       (patched)
926c2251f503efc9b39884e42b5e0e80  /tmp/wt_r10uvm78pris/build/slang-uhdm   (pristine)
```

**The patch reproduces that binary EXACTLY.** `/tmp/r10uvm78.patch` was applied
to a THIRD, fresh `5adb330` worktree (`git apply --check` clean first),
configured and built `-j 2` from scratch, and its `slang-uhdm` came out
`54198774ff82b6420692f76233c66207` — byte-identical to the one every gate above
was run with.

Both worktrees `rev-parse HEAD` = `5adb330a889d1de3b450fcd66cbd105825c3ffad`;
the pristine tree's `git status --porcelain` is **EMPTY**. (r10uvm77's verifier
F5 is heeded: the main-tree binary is NOT cited as corroboration — it is a tree
this pass does not control.) Every sweep's `cmds.txt` was grep-checked for the
binary it actually ran.

### Gate 2 — GOLDENS

`SLANG_UHDM` **exported explicitly** (`check_goldens.sh` silently defaults it to
the main-tree binary):

* patched binary: **23 PASS / 0 FAIL**
* `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the harness genuinely reads
  the binary under test.

### Gate 3 — uhdm2rtlil corpus (`--mode testflags`, `--jobs 2`)

| | pristine (judged FIRST) | patched |
|---|---|---|
| status | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | **identical** |
| dump | 496 match / 183 differ / 52 blank | **identical** |
| `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` | 0 ROWS (0 row-sides) / 731 | **0 ROWS (0 row-sides)** |

### Gate 4 — surelog corpus, both modes (`--jobs 2`)

| mode | CMP_EQUAL | CMP_NOTEQUAL | SURELOG_FAIL | DEFERRED |
|---|---|---|---|---|
| default | **469** | **11** | **25** | **5** |
| testflags | **465** | **8** | **23** | **5** |

`ct8rows.sh` vs `results/golden_surelog.csv`: **0 differing ROWS (0 row-sides)**
over 1 588, **patched AND pristine**. Per-mode STATUS *and* dump-column
histograms identical baseline → fresh (default `225 match / 244 differ / 325`;
testflags `165 / 300 / 329`).

### Gate 5 — BYTE VERIFIER, both corpora, vs the PRISTINE 5adb330 build

`SELFCHECK=1 SELFCHECK1=1`, `PATH_SETS_IDENTICAL` on both.

| corpus | paths | movers | `SELFCHECK` | `SELFCHECK1` |
|---|---|---|---|---|
| uhdm2rtlil | 679 | **0** | 678 / 679 | **1** = 0 real + 1 corrupted |
| surelog | 953 | **8** | 952 / 953 | **9** = 8 real + 1 corrupted |

`SELFCHECK1` returning exactly `real + 1` is the proof the comparator can see ONE
changed database; on uhdm2rtlil, where the prediction was 0 and the measurement
was 0, `SELFCHECK1 = 1` is what separates "nothing moved" from "the verifier saw
nothing."

---

## 5. THE MOVERS — all 8, by MULTISET, then against GOLDEN

`mv78.sh` — id-stripped (`, id:N`), whitespace-stripped, `sed 1d` (the dump's
first line embeds the workdir path), ADDED and REMOVED as **separate**
multisets.

| database | size delta | REMOVED shapes | ADDED shapes | `vpiConstantSelect:1` | dist. to golden |
|---|---|---|---|---|---|
| default/SimpleUVM | **+5** | 14 | 14 | 46 → **50** (+4) | 136 133 → **136 065** |
| testflags/SimpleUVM | **+7** | 14 | 14 | 46 → **50** (+4) | 136 129 → **136 061** |
| default/Scoreboard | **+7** | 14 | 14 | 46 → **50** (+4) | 126 261 → **126 193** |
| default/BuildUVMPkg | **+67** | 17 | 18 | 84 → **87** (+3) | 75 395 → **75 324** |
| testflags/BuildUVMPkg | **+67** | 17 | 18 | 84 → **87** (+3) | 75 395 → **75 324** |
| default/SeqDriver | **+10** | 27 | 27 | 87 → **95** (+8) | 338 970 → **338 834** |
| testflags/SeqDriver | **+10** | 27 | 27 | 87 → **95** (+8) | 338 970 → **338 834** |
| default/Earlgrey_0_1 | **+5** | 25 | 25 | unchanged (+0) | 277 934 → **277 854** |

**Every size delta is NONZERO — by the MOVER RULE each is a proven real change**
(a zero delta would have proven nothing; the authority is the per-shape analysis
either way). **Distance to golden STRICTLY DECREASED on all 8.**

**Only two kinds of line moved, in all eight databases:**

1. a fullname/`ref_obj`/`bit_select` shape whose text differs from its twin by
   exactly one character — `.` → `::` — at **the identical span**, and
2. the `|vpiConstantSelect:1` line's **multiplicity**.

No span changed. No class changed. No object was created or destroyed. The
per-database `vpiConstantSelect` delta equals the D2 census count exactly.

### Attribution: every moved shape counted in GOLDEN (`mvgold78.sh`)

`grep -Fxc` (FIXED string, WHOLE line — a fullname is a substring of longer
fullnames and a substring count would silently inflate) against the normalised
golden dump. **303 shape rows across the 8 movers; 291 land on golden's count
exactly. The 12 that do not are two named families and NEITHER is a
regression** — in both, the PRISTINE shape was equally not-golden:

| family | rows | what it is | direction |
|---|---|---|---|
| Earlgrey `prince_shiftrows_*` / `sbox4_*` | 8 | `g=0 pris=0 pat=N`. The NAME is now golden's, but these cells also differ on the **span** (golden 73:38 / 331:44 vs our 73:39 / 331:45) and, for `sbox4`, on an EARLIER joint (`sbox4_32bit.sbox4` where golden writes `sbox4_32bit::sbox4` — a nested-FUNCTION prefix built elsewhere). Both are pre-existing and untouched | 3 defects → **2** |
| BuildUVMPkg `abstractions::local_index__` | 4 | `g=2 pris=0 pat=1`. TWO objects carry this fullname: the part-select bound at 83087:36 (**fixed**) and a `bit_select` index at 83089:89, which is residue **R5** and a different code site | 2 wrong → **1** |

Everything else in the eight movers is `golden 0 / pristine N / patched 0` for a
removed shape and `golden N / pristine 0 / patched N` for an added one.

---

## 6. THE TARGET ROWS — the head

`rowheads.sh` (heads counted with `grep -c '^LHS:'` anchored at column 0; a
missing side prints SKIP-NOFILE and is COUNTED).

| row | pristine | patched | head OBJECT before | head OBJECT after | verdict |
|---|---|---|---|---|---|
| **SimpleUVM default** | 142 / 1 | **128 / 1** | `part_select arb_sequence_q` @681:23 | `hier_path arb_sequence_q[…].sequence_ptr` @**791:22** | **CLEARED, ADVANCED** |
| **SimpleUVM testflags** | 142 / 1 | **128 / 1** | same | same | **CLEARED, ADVANCED** |
| **Scoreboard default** | 142 / 1 | **128 / 1** | same | same | **CLEARED, ADVANCED** |
| Scoreboard testflags | SKIP-NOFILE | SKIP-NOFILE | — | — | SLANG_REJECT, counted |
| SeqDriver default/testflags | 1 422 695 / 1 | **1 422 699 / 1** | `LHS: <null>` = the whole `uvm_pkg` container | *same object* | **+4 = the 4 new flag lines, exactly** |
| BuildUVMPkg default/testflags | 94 / 1 | **94 / 1** | `struct_typespec` | *unchanged* | cmp **id-stripped delta = 0** |
| Earlgrey_0_1 default | 66 / 1 | **66 / 1** | — | *unchanged* | cmp **id-stripped delta = 0** |
| ApbSlave, SVSwitch, both modes | 0 / 0 | 0 / 0 | PASS_CMP | PASS_CMP | unchanged |

**The head this pass was sent to kill is GONE on all THREE rows**, the line count
went **DOWN** (142 → 128, unlike pass 77's 26 → 142), and the three patched cmps
are still **one shared head object** — byte-identical to each other with ids
stripped (`md5 d6eadc1c8cca573c4a9e9b09355aac79` for all three).

The SeqDriver arithmetic is exact and worth stating: its head is the standing
**vector-form `<null>` prints the CONTAINER** case, so its cmp is our whole
package. `1 422 695 → 1 422 699` is `+4`, and the id-stripped cmp delta is 68
lines = 34 changed × 2 print views, of which 4 are the new
`|vpiConstantSelect:1` and 30 are `.` → `::` renames at identical spans. **Zero
lines outside the two laws.**

### R0 — the NEW head, decoded

```
uvm_sequencer_base.svh:791:  if (is_blocked(arb_sequence_q[avail_sequences[i]].sequence_ptr) == 0) begin
LHS hier_path: (arb_sequence_q[[i]].sequence_ptr),                 791:22-791:69
RHS hier_path: (arb_sequence_q[avail_sequences[i]].sequence_ptr),  791:22-791:69
```

Same class, same span. Diffing the two halves gives **FOUR** defects on this one
object — a NESTED SELECT AS AN INDEX, a family this ladder has not touched:

1. **the decompiled index text.** Golden renders the inner select as
   `arb_sequence_q[[i]]` — it drops the inner select's BASE name and keeps only
   its index — and that string is the `hier_path`'s `vpiName` and its
   `bit_select`'s `vpiFullName`. We render `arb_sequence_q[avail_sequences[i]]`.
2. **the inner `bit_select`'s span and parent.** Golden puts it at
   **791:37–791:55** (the whole `avail_sequences[i]` text) with the `hier_path`
   as its parent; we put it at 791:53–791:54 (just the `i`) under the OUTER
   `bit_select`.
3. **the nested refs' scoping.** Golden scopes `avail_sequences` and `i` through
   the whole hier-path text
   (`…m_choose_next_request::arb_sequence_q[[i]].sequence_ptr::avail_sequences`);
   we leave them at plain function scope.
4. **`sequence_ptr`'s fullname joint** — golden
   `…m_choose_next_request::sequence_ptr`, ours
   `…m_choose_next_request.sequence_ptr`. **A `.` for a `::` again**, and this
   is a THIRD spelling of the joint family: neither the part-select bound joint
   (R3, fixed here) nor the bit-select index joint (R5), but the HIER-PATH
   ELEMENT joint.

Defect 4 makes the joint family the highest-value target on the ladder: three
independent sites, one law, and one of them now standing at the head.

---

## 7. REFUTATIONS — measured, and both changed what got written

### RF-1 — "the `.` in a `::` scope is always wrong." **FALSE. Golden does it 28 times.**

The obvious generalisation of R3 is "any cached fullname whose scope is
`::`-first must join with `::`." Detector **D4** was written to test exactly
that, and run on golden BEFORE the fix:

```
D4 GOLD/default/SimpleVMM  part_select bit_conv @619:4  full=vmm_channel::Xrecord_to_fileX.bit_conv
… 28 such objects across SimpleVMM default+testflags
```

Golden itself writes `vmm_channel::Xrecord_to_fileX**.**bit_conv`. The
generalisation is false, and the four `.`-joined select fullnames our emitter
writes (`baseFull + "." + bnm41`, `dblFull`, …) are **left exactly as they
were.** Had the law been widened on the strength of its own plausibility, this
pass would have broken a converged shape to fix a shape that was already right.

D4 stays in the shipped instrument, at 4 for us and 28 for golden, precisely so
the next pass cannot re-derive the false version.

### RF-2 — "the indexed arm's gate is the one that fires." **FALSE — it can never fire on legal SV.**

`§ hierSelConstWidthSuffices17`'s "constant width suffices" reads as though it
were the loose gate and the SIMPLE arm's "both ends" the strict one. In fact an
indexed part-select's WIDTH is a `constant_expression` in IEEE 1800 and slang
REJECTS a variable one (`c3_constsel.sv` was first written with a `v[3 -: n]`
cell and slang refused the file: *"reference to non-constant variable 'n' is not
allowed in a constant expression"*). **The entire corpus D2 population is SIMPLE
part_selects, all five of them on QUEUES** — the one shape whose range is
allowed to be non-constant at all. The census says so directly: every D2 line
names `part_select`, none names `indexed_part_select`.

### RF-3 — the brief's expectation that "the three target rows will very likely NOT clear." **They cleared, and the line count went DOWN.**

142 → 128 on all three. The brief's reasoning ("142 lines is the whole subtree
under the head; removing 2 defects may just advance the head again") was sound
and the head DID advance 110 source lines — but the new head's subtree is
*smaller*, so the count fell. Head depth is not a distance in either direction;
the distance figures in §5 are.

---

## 8. RANKED RESIDUES

**R0 — the NESTED SELECT AS AN INDEX**, `arb_sequence_q[avail_sequences[i]]` at
uvm_sequencer_base.svh:791:22. The new shared head of all three target rows, 128
lines, four defects decoded in §6. Its defect 4 is a joint-family cell.

**R5 (new, MEASURED) — the BIT-SELECT INDEX joint, `ExprEmit.cpp:13636`.**
Exactly R3's defect one family over:

```cpp
if (stripImplicitConv(es.selector()).kind != ExpressionKind::NamedValue) {
    idxPrefix = prefix + "." + std::string(nv.symbol.name);   // <- joinRef
```

Witness, golden-confirmed: `abstractions[local_index__ + 1]`, uvm_pkg.sv
83089:89 — golden
`uvm_pkg::uvm_reg_mem_hdl_paths_seq::__m_uvm_execute_field_op::abstractions::local_index__`,
ours `…__m_uvm_execute_field_op.abstractions::local_index__`. **Population
measured: 1 585 objects in 10 databases** (SeqDriver 357 ×2, SimpleUVM 193 ×2,
Scoreboard 193, BuildUVMPkg 131 ×2, Earlgrey_0_1 26, **SVSwitch 2**), against
**0** in golden. **It is left alone on purpose**: it is 9× the population of
R2+R3 together, it needs its own census and its own five gates, and it reaches
**SVSwitch — a named canary this pass must not move.** Detector D5 ships so the
next pass starts from the artifact.

**R6 — the nested-FUNCTION prefix joint.** `prim_cipher_pkg::sbox4_32bit.sbox4`
where golden writes `sbox4_32bit::sbox4` (Earlgrey, `sbox4_32bit`/`sbox4_64bit`).
A function-inside-function prefix built by `joinPath` upstream of everything
this pass touched. 4 objects.

**R7 — the Earlgrey select spans.** `prince_shiftrows_*` at 73:39 / 83:39 where
golden reads 73:38 / 83:38, and `sbox4_*` at 331:45 / 340:45 where golden reads
331:44 / 340:44. A consistent off-by-one at the select's start. 8 objects,
pre-existing, unchanged by this pass.

**R8 — the `do_bus_access` doubled select fullname** (BuildUVMPkg 77065:10):
ours `uvm_pkg::uvm_reg_map::do_bus_access.rw.value[idx][i0 * 8+:8].value[idx]`
vs golden `uvm_pkg::uvm_reg_map::do_bus_access::rw.value[idx][i0 * 8+:8]`. Two
independent defects (the leading joint AND a spurious doubled `.value[idx]`
tail). This is the ONE cell our D4 detector flags, and it is flagged for the
right reason — it is **not** the SimpleVMM shape RF-1 protects.

**R1 / R4 / R9 / R10** — carried over from pass 77's list unchanged; **R2 and R3
are RETIRED**, corpus-wide, measured on the patched build.

---

## 9. CANARIES

* `canaries.sh` (surelog) **ok=52 changed=0 absent=0**, unknown-names=8 (the
  expected u2r-only count); (u2r) **ok=9 changed=0 absent=0**, unknown-names=25.
* `ctcan2.sh` `EXPECT_UNKNOWN=1` (surelog) **ok=58 changed=0**; `EXPECT_UNKNOWN=6`
  (u2r) **ok=1 changed=0**. Both PASS.
* `canaudit.sh` **audited=31 UNCOVERED=0 FENCE-BREACH=0** — every brief-protected
  name is carried by a script that RUNS here, and none of the four slang-fenced
  names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) is
  dispatched by any driver in this directory.
* The four named canaries plus ApbSlave checked **BY DATABASE, byte for byte**,
  both modes: `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`,
  `SVSwitch`, `ApbSlave` — **all 10 BYTE-IDENTICAL**. (The byte verifier's 8
  movers independently exclude them.)

---

## 10. ARMS

`PAT=<patched> PRI=<pristine> ct78arm.sh <arm.sv>` — golden and BOTH binaries in
ONE scratch dir, so the absolute-path lines `uhdm-dump` prints for Surelog's
synthesized `builtin.sv` are identical across all three reads.

| arm | what it isolates | pristine | patched |
|---|---|---|---|
| `c1_classpsel.sv` | THE HEAD's shape: a class-property QUEUE slice with a variable end, plus a constant-end control and a MODULE-scope control | CMP_FAIL, 1 head, 36 dump-line sides from golden, `d2=2 d3=1` | **PASS_CMP, 0 heads**, 30 sides, `d2=0 d3=0` |
| `c2_idxpsel.sv` | the INDEXED form in a class method AND in a PACKAGE FUNCTION (the Earlgrey shape), plus a module control | CMP_FAIL, 1 head, 38 sides, `d3=3` | CMP_FAIL, 1 head, **26** sides, `d3=0` |
| `c3_constsel.sv` | the whole LEGAL bound lattice for `vpiConstantSelect` | CMP_FAIL, 1 head, 10 sides, `d2=2` | **PASS_CMP, 0 heads**, 8 sides, `d2=0` |

`c1` and `c3` go all the way to `PASS_CMP` — uhdm-cmp equality with golden.
Golden's census on all three arms is `d2=0 d3=0 d4=0 d5=0` (sel = 3 / 6 / 10),
and the PATCHED census is `d2=0 d3=0 d4=0 d5=0` on all three with the SAME sel
counts — the law restated as a measurement, on both sides. `c2` keeps a residual head that is a `bit_var` /
`array_var` typespec disagreement on `bit m_bits[1024]`, entirely unrelated to
either law and present identically in both binaries; its pris→pat delta is
**12 dump-line sides = 6 changed lines, every one of them `.` → `::`**.

The module-scope controls (`c1` p3, `c2` i3, `c3` s1/s2/s5/s6) are the
load-bearing half: they establish that `joinRef` returns the OLD string outside
a `::` scope, so the fix cannot reach any module-scoped design — which is why
the u2r corpus, 679 databases of module-scoped RTL, is byte-identical.

---

## 11. FILES

| file | role |
|---|---|
| `r10uvm78cen.cpp` | the census instrument — D2/D3/D4/D5 + `R10UVM78_LIST` raw joint inventory |
| `build78.sh` | builds it to `/tmp/r10uvm78cen` |
| `ct78cen.sh` | runs it over a WHOLE verify_golden workdir, both sides |
| `ct78arm.sh` | arm driver: golden + BOTH binaries in ONE scratch dir |
| `ct78gate.py` | STATED GATE == CODE GATE, mechanically (PASS on patched, exit 5 on pristine) |
| `mv78.sh` | per-shape MULTISET content analysis of the movers |
| `mvgold78.sh` | attribution: every moved shape counted in golden / pristine / patched |
| `c1_classpsel.sv` `c2_idxpsel.sv` `c3_constsel.sv` | the arms |
| `rowheads.sh` `ct8rows.sh` `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the standing gate instruments, carried forward unmodified |
