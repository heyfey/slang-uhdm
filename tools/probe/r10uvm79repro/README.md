# r10uvm79 — § hpMidSelIdxDecompiled79 + § hpMidSelIdxAtPath79 + § hpTailElemJoinsByScope79

**BASE 113a511.** Production surface: `src/ExprEmit.cpp` **only** (+209 / −17,
NINE hunks, ALL of them inside the ONE function `emitMixedHierPath`). Probe surface: `tools/probe/r10uvm79repro/`
only.

**Result, up front: the 128-line head shared by SimpleUVM/default,
SimpleUVM/testflags and Scoreboard/default is CLEARED on ALL THREE ROWS**
(128 → **62**, one shared new head object, byte-identical across the three cmps
with ids stripped, `md5 fa1ec44cfeaa10cb18d672982096d40a`). All FOUR defects
pass 78 decoded on that object are fixed and the object is gone from the cmp.
Five gates green. **11 movers, every one predicted from the artifact BEFORE the
build, every moved line attributed, distance to golden strictly DOWN on all
11.** The uhdm2rtlil corpus is an **impossibility proof**: every one of this
pass's five defect detectors reads **0 on both sides in all 679 databases**, and
it moved 0.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and every script here.

**Three attractive generalisations were MEASURED AND REFUTED before any code
moved** (§7). One of them — the one the arms unanimously supported — would have
mis-parented 2 362 golden-correct objects.

---

## 1. THE MECHANISM: two functions in two upstream trees

Everything below is read out of source, then confirmed on the artifact.

### `CompileHelper::decompileHelper` (Surelog, `src/DesignCompile/CompileHelper.cpp:2544`)

The index text a hier_path's NAME carries is **not** the source's raw text. It
is this function applied to the index **object**, and its dispatch is CLOSED —
there is no `else`, so an object it does not know renders as the **empty string**:

| index object | rendering |
|---|---|
| `constant` | `VpiDecompile` |
| `ref_obj` | `VpiName` |
| `operation` | `ExprEval::prettyPrint` |
| `bit_select` | `"[" + (its CONSTANT / REF_OBJ / OPERATION index) + "]"`, and **`""`** for any other index kind |
| `part_select` | `"[l:r]"` |
| `indexed_part_select` | `"[b+:w]"` / `"[b-:w]"` |
| `var_select` | the concatenation of its exprs |
| **anything else** | **`""`** |

The first three rows are what our emitter already did — and that is what
`§ hpMixedIdxPkgFold34` **is**: a package parameter has been folded to a
`constant` by the time Surelog decompiles, a module one is still a `ref_obj`,
so pass 34's fold table and this table are the same table. This pass adds the
select rows and the empty default.

### `BaseClass::ComputeFullName` (UHDM, `templates/BaseClass.cpp:100`)

Walks the parent chain, picks ONE separator for the whole chain from
package/`class_defn` ancestry, and skips a name only for the pairs listed at
lines 126-138 — among them **child `ref_obj` under `bit_select`** and **child
`ref_obj` under `hier_path`**. Our eagerly cached names must agree with it at
every joint. This single rule explains, with no free parameters, why golden
gives a *bare ref_obj* index plain scope (`…::probe::i`) and a *select* index
the path-scoped one (`…::probe::iarr[[i]].f::midx`): the ref_obj is skipped past
the hier_path, the select is not.

r10uvm78's F2 warned that `joinRef` is a TEXTUAL PROXY for this rule and asked
for the proxy question to be settled before widening its use. §7/RF-3 settles it
by measurement, not by argument.

---

## 2. THE LAWS

```
§ hpMidSelIdxDecompiled79    src/ExprEmit.cpp, emitMixedHierPath, 3 renderer sites
§ hpMidSelIdxAtPath79        src/ExprEmit.cpp, emitMixedHierPath, 2 index sites
§ hpTailElemJoinsByScope79   src/ExprEmit.cpp, emitMixedHierPath, 2 fullname sites
```

### § hpMidSelIdxDecompiled79

> In `emitMixedHierPath`, the index text a component select puts into the
> hier_path's NAME (and into that element's own fullname) is `decompileHelper`'s
> rendering of the index OBJECT — the table in §1 — **whenever that component
> select is FOLLOWED BY FURTHER PATH COMPONENTS**. A TRAILING component select
> is untouched.

Measured on golden, arm `c2_idxkind.sv` (`iarr[<idx>].f`), index expression →
hier_path name — nine of its eleven cells (the other two, d8 and d10, vary the
LVALUE-ness and the base position, not the index kind):

| index | golden name | decompileHelper row |
|---|---|---|
| `midx[i]` | `iarr[[i]].f` | bit_select, ref_obj index |
| `midx[midx[i]]` | `iarr[].f` | bit_select, SELECT index → **empty** |
| `i + 1` | `iarr[i + 1].f` | operation (unchanged) |
| `midx[i] + 1` | `iarr[ + 1].f` | operation, select operand (**residue R2**) |
| `2` | `iarr[2].f` | constant (unchanged) |
| `h.idx[i]` | `iarr[].f` | hier_path → **empty** |
| `fn(i)` | `iarr[].f` | func_call → **empty** |
| `pk[3:0]` | `iarr[[3:0]].f` | part_select |
| `iarr2[midx[i]][j]` | `iarr2[[i]][j].f` | per DIMENSION |

and in the corpus, all four firing shapes' golden targets were read off the
golden databases **before the build** (§3).

### § hpMidSelIdxAtPath79

> The same MID-PATH component select, when its index is **itself a SELECT**,
> hangs that index off the **HIER_PATH**, spans it over the index's **whole
> source text**, and scopes it — and everything nested under it — through
> `joinRef(prefix, <the hier_path's name>)`.

Golden, arm `c1_nestedidx.sv` cell c1, the corpus head shape verbatim:

```
hier_path   arb_sequence_q[[i]].sequence_ptr                    17:20-17:67
 bit_select arb_sequence_q       full=arb_sequence_q[[i]]       17:20-17:34
  bit_select avail_sequences     parent=HIER_PATH               17:35-17:53
     full=work@seqr::m_choose_next_request::arb_sequence_q[[i]].sequence_ptr::avail_sequences
   ref_obj  i                    parent=the inner bit_select    17:51-17:52
     full=work@seqr::m_choose_next_request::arb_sequence_q[[i]].sequence_ptr::i
 ref_obj    sequence_ptr         full=work@seqr::m_choose_next_request::sequence_ptr
```

and the MODULE-scope twin (cell c6) is the same object graph with `.` at every
joint — which is exactly what `joinRef` decides from the prefix.

**Why the gate is "the index is a SELECT" and not "the index is non-trivial":**
ComputeFullName skips a hier_path parent for a `ref_obj` child, so a bare
ref_obj index is CORRECT at plain scope. Widening to operations and calls is
REFUTED at §7/RF-2 for the parenting half and left as residues R2/R3.

**Why the gate is "MID-PATH":** §7/RF-1. Golden parents a trailing select's
index at the bit_select in **2 362 objects across 70 databases**.

### § hpTailElemJoinsByScope79

> The joint between the ENCLOSING SCOPE and a hier_path's TRAILING path element
> is `joinRef(prefix, name)`, never a hard `"."`.

This is the THIRD site of the joint family: r10uvm77 fixed the trailing-step
refs, r10uvm78 the doubled part-select prefixes, this one the hier-path tail.
Golden, arm c1 cells c1/c2/c3 — three separate paths in one class method, all
three `work@seqr::m_choose_next_request::sequence_ptr`; module twin c6
`work@top.sequence_ptr`.

r10uvm78's RF-1 ("a `.` in a `::` scope is always wrong" — FALSE, golden writes
768 of them) is not repealed here, it is **navigated by census**: golden's 768
live in exactly TWO databases (SimpleVMM — SLANG_REJECT for us, no database at
all — and Ariane2024), and in BOTH our side has **ZERO**; while in all ELEVEN
databases where our side has one, golden has **ZERO**. The two populations are
DISJOINT, measured before the build. See §7/RF-3.

### STATED GATE == CODE GATE

| prose | code |
|---|---|
| the renderer is `decompileHelper` | `idxDecompile79`, whose non-`mid` arm returns the OLD renderer unchanged as its FIRST statement |
| whenever the select is followed by further components | `bool mid79` defined TWICE, `i + 1 < comps.size()` and `!lastMember` — the same predicate in the two loops' terms |
| the name AND the element's own fullname | 3 call sites `idxDecompile79(*…, mid79)`, and **0** surviving `idxText34(*…sel…)` name-building calls |
| when its index is itself a SELECT | `selIdx79` / `selIdx79b`, both `mid79 && (ElementSelect \|\| RangeSelect)` and nothing else |
| hangs off the hier_path, spanning its whole text | 2 sites `VpiParent(hp); setLoc((UHDM::any*)ix, …sourceRange);` |
| scoped through the path name | 2 sites `selIdx79? ? joinRef(prefix, dotted) : prefix` |
| the tail joint is joinRef | **0** `VpiFullName(prefix + "." + comp.name)`, exactly **2** `VpiFullName(joinRef(prefix, comp.name))` |

`ct79gate.py <src/ExprEmit.cpp>` asserts every row of that table, reading CODE
(comments are stripped first — a guard that greps its own write-up is this
campaign's oldest trap). It has a real negative control:

```
patched   src/ExprEmit.cpp   -> PASS, exit 0
pristine  src/ExprEmit.cpp   -> FAIL, exit 5, all ten rows named
```

An audit that finds no `emitMixedHierPath` exits 4 rather than reporting
success. One row of it was WRITTEN WRONG AND CAUGHT BY ITS OWN RUN: counting
the bare string `joinRef(prefix, dotted)` read 3, because a THIRD one predates
this pass at `ExprEmit.cpp:12616` (a method-call receiver prefix). The check now
counts only the `selIdx79`-gated ones — an off-by-one in a guard that would have
been "adjusted" silently is instead recorded here.

---

## 3. THE CENSUS — an EXACT prediction, made before the patched build existed

`r10uvm79cen.cpp` opens a `.uhdm` with UHDM's own `Serializer` and walks
`Serializer::AllObjects()`. Three reasons that beats grepping `uhdm-dump`: it
sees objects a dump cannot (a dump prints what some parent points at); it reads
the FIELD, not the rendering; and it counts each object ONCE (the dump reprints
an object at every reference, so a shape census over dump text multiplies).
It prints a `TOTALS` line **always**, including on `RESTORE_FAIL`.

| id | what it flags |
|---|---|
| **E1** | a hier_path NAME carrying an index group that is not decompile-shaped |
| **E2** | a NON-TRIVIAL path-element index whose `vpiParent` is not the hier_path |
| **E3** | a NAMED DESCENDANT of such an index whose fullname misses the path name |
| **E4** | a path-element `ref_obj` whose fullname joins its last step with `.` in a `::`-first scope |
| **E5** | a SELECT index anchored at its own inner index (the span proxy) |
| **E6** | the NAMING law's exact firing SET (mid-path select, index not constant/ref/operation) |
| **E7** | the STRUCTURAL law's exact firing SET (mid-path select, index is a select) |
| `R10UVM79_LIST=1` | the raw index inventory, no predicate |
| `R10UVM79_NAMES=1` | one row per hier_path name, for the golden JOIN (`ct79names.py`) |

**GOLDEN FIRST, as calibration — and it caught a broken detector.** E1's
predicate originally flagged a `(` and **fired on golden 70 times** across 13
databases (`dmi_req_i.addr[$clog2(5'h8) - 1:0]`, where the index is a
part_select whose bound is an operation, which prettyPrint renders in full). A
detector that fires on golden is a broken detector; the paren test was removed
and the miss it costs (a bare call index) is documented in the source.

| corpus | side | hier_paths | idxs | E1 | E2 | E3 | E4 | E5 | E6 | E7 |
|---|---|---|---|---|---|---|---|---|---|---|
| surelog (both modes, 953 db) | **GOLD** | 867 008 | 157 155 | **0** | 2 362 | 149 | 768 | 12 | 972 | 213 |
| surelog | OURS | 92 300 | 16 814 | **72** | 429 | 304 | **2 423** | **18** | 54 | 18 |
| uhdm2rtlil (testflags, 679 db) | **GOLD** | 6 826 | 3 333 | **0** | 10 | **0** | **0** | **0** | **0** | **0** |
| uhdm2rtlil | OURS | 3 943 | 3 219 | **0** | 3 | **0** | **0** | **0** | **0** | **0** |

**The uhdm2rtlil line is an IMPOSSIBILITY PROOF for that whole corpus**: E1, E3,
E4, E5, E6 and E7 are all zero on both sides in all 679 databases, and its three
E2 objects are OPERATION indices, which no law here touches. No database there
can move. **It did not.**

**The firing sets, per shape, with golden's target READ OFF GOLDEN first:**

| shape (ours) | golden | objects | dbs |
|---|---|---|---|
| `arb_sequence_q[avail_sequences[i]].sequence_ptr` | `arb_sequence_q[[i]].sequence_ptr` | 18 | 7 |
| `m_inst_override_name_queues[obj.get_type_name].queue` | `m_inst_override_name_queues[].queue` | 14 | 7 |
| `m_regs_info[f.get_parent].offset` | `m_regs_info[].offset` | 4 | 2 |
| `m_children[child.get_name()].get_type_name` | `m_children[].get_type_name` | 18 | 7 |

The first three are `emitMixedHierPath`'s (a select followed by a FIELD); the
fourth's tail is a parenless METHOD CALL and is built elsewhere — predicted NOT
to move, and it did not (**residue R4**).

**PREDICT_MOVE, per database:**

| database | E6 | E7 | E4 | predicted | MOVED |
|---|---|---|---|---|---|
| default/SeqDriver, testflags/SeqDriver | 12 | 4 | 545 | YES | **YES** |
| default/SimpleUVM, testflags/SimpleUVM | 6 | 2 | 279 | YES | **YES** |
| default/Scoreboard | 6 | 2 | 279 | YES | **YES** |
| default/BuildUVMPkg, testflags/BuildUVMPkg | 6 | 2 | 245 | YES | **YES** |
| default+testflags/ClassVar | 0 | 0 | 1 / 2 | YES (joint only) | **YES** |
| default+testflags/LocalScopeHierPath | 0 | 0 | 1 / 2 | YES (joint only) | **YES** |
| every other database, BOTH corpora | 0 | 0 | 0 | NO | **no** |

**11 predicted, 11 measured, 0 unpredicted, 0 flagged-but-inert.**

**On the PATCHED build**, with `hp` and `idxs` unchanged at 92 300 / 16 814 —
the laws create no object and destroy none:

| | E1 | E2 | E3 | E4 | E5 |
|---|---|---|---|---|---|
| surelog OURS, pristine | 72 | 429 | 304 | 2 423 | 18 |
| surelog OURS, **patched** | **54** | **411** | **286** | **9** | **0** |
| uhdm2rtlil OURS, patched | 0 | 3 | 0 | 0 | 0 |

**E5 is RETIRED corpus-wide.** E4 falls 2 423 → **9**, and the 9 are two named
families (§8 R5). E1's residual 54 is exactly the TRAILING `top_map.m_regs_by_offset[info.addr[i]]`
family the law deliberately excludes (residue R1) — every one of the 18
`arb_sequence_q` objects is gone.

---

## 4. THE FIVE GATES

### Gate 1 — BUILD

Both trees configured and built at ABSOLUTE paths with `-j 2`; the link line was
reached in both (`[100%] Linking CXX executable slang-uhdm`). md5 asserted
**separately** from the build exit, both 32-hex and different from each other:

```
2e436f39c00bceacfe5bfcb6c7d0203c  /tmp/wt_r10uvm79/build/slang-uhdm       (patched)
eacd60adb66c45ccdf5db8cb56596955  /tmp/wt_r10uvm79pris/build/slang-uhdm   (pristine)
```

**The patch reproduces that binary EXACTLY.** `/tmp/r10uvm79.patch` was applied
to a THIRD, fresh `113a511` worktree (`git apply --check` clean first),
configured and built `-j 2` from scratch, and its `slang-uhdm` came out
`2e436f39c00bceacfe5bfcb6c7d0203c` — byte-identical to the one every gate below
was run with. The pristine tree's `git status --porcelain` is **EMPTY**; the
main-tree binary is NOT cited as corroboration (r10uvm77 F5).

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

### Gate 5 — BYTE VERIFIER, both corpora, vs the PRISTINE 113a511 build

`SELFCHECK=1 SELFCHECK1=1`, `PATH_SETS_IDENTICAL` on both.

| corpus | paths | movers | `SELFCHECK` | `SELFCHECK1` |
|---|---|---|---|---|
| uhdm2rtlil | 679 | **0** | 678 / 679 | **1** = 0 real + 1 corrupted |
| surelog | 953 | **11** | 952 / 953 | **12** = 11 real + 1 corrupted |

`SELFCHECK1` returning exactly `real + 1` is the proof the comparator can see ONE
changed database; on uhdm2rtlil, where the prediction was 0 and the measurement
was 0, `SELFCHECK1 = 1` is what separates "nothing moved" from "the verifier saw
nothing."

---

## 5. THE MOVERS — all 11, by MULTISET, then against GOLDEN

`mv79.sh` — id-stripped, whitespace-stripped, `sed 1d` (the dump's first line
embeds the workdir path), ADDED and REMOVED as **separate** multisets.
`mvclass79.py` then attributes every moved line to one of the three laws, using
ONLY the rewrites the laws authorise (a one-separator flip; one of the four
index-group rewrites the census read off golden; a re-scope through the path
text; a changed `line:`). **A line no authorised rewrite can reach is
UNATTRIBUTED and fails the run.**

| database | size delta | REMOVED / ADDED shapes | JOINT | NAME | SCOPE | SPAN | MULT | **UNATTRIBUTED** | dist. to golden |
|---|---|---|---|---|---|---|---|---|---|
| default/SimpleUVM | −1 275 | 273 / 248 | 441 | 16 | 4 | 2 | 58 | **0** | 228 173 → **227 077** |
| testflags/SimpleUVM | −1 383 | 273 / 248 | 441 | 16 | 4 | 2 | 58 | **0** | 228 171 → **227 089** |
| default/Scoreboard | −1 885 | 273 / 248 | 441 | 16 | 4 | 2 | 58 | **0** | 219 955 → **218 243** |
| default/SeqDriver | −2 740 | 514 / 467 | 843 | 16 | 8 | 4 | 110 | **0** | 502 756 → **500 648** |
| testflags/SeqDriver | −2 740 | 514 / 467 | 843 | 16 | 8 | 4 | 110 | **0** | 502 756 → **500 648** |
| default/BuildUVMPkg | −2 084 | 272 / 243 | 427 | 16 | 4 | 2 | 66 | **0** | 160 510 → **159 550** |
| testflags/BuildUVMPkg | −2 084 | 272 / 243 | 427 | 16 | 4 | 2 | 66 | **0** | 160 510 → **159 550** |
| default/ClassVar | +1 | 2 / 2 | 4 | — | — | — | — | **0** | 28 → **24** |
| testflags/ClassVar | +1 | 2 / 2 | 4 | — | — | — | — | **0** | 74 → **66** |
| default/LocalScopeHierPath | +1 | 2 / 2 | 4 | — | — | — | — | **0** | 41 → **37** |
| testflags/LocalScopeHierPath | +1 | 2 / 2 | 4 | — | — | — | — | **0** | 102 → **94** |

**Every size delta is NONZERO — by the MOVER RULE each is a proven real change**
(a zero delta would have proven nothing; the per-shape analysis is the authority
either way). **Distance to golden STRICTLY DECREASED on all 11.**

The four small movers are the tail joint alone, and golden confirms the target
directly: `check_reg.spath` → `check_reg::spath`, and golden holds
`check_reg::spath` ×2 in both databases.

### Attribution: every moved shape counted in GOLDEN (`mvgold79.sh`)

`grep -Fxc` (FIXED string, WHOLE line — a fullname is a substring of longer
fullnames and a substring count would silently inflate). **2 400 shape rows
across the movers; 2 281 land on golden's count exactly. The 119 that do not
fall into THREE named families and NONE is a regression:**

| family | rows | what it is |
|---|---|---|
| golden has NEITHER spelling | 71 | `g=0 pris=0 pat=N`, and the removed separator-twin is `g=0` too — golden does not build that object at all (e.g. it folds `m_uvm_applied_cl_action[i].used` to a plain ref of the whole array). The PRISTINE shape was equally not-golden. |
| the TEXT is golden's, the COUNT differs | 44 | `g>0 pat>0` — the dump reprints an object at every reference and the two sides hold different reference counts. Pre-existing. |
| SeqDriver's `adpcm_pkg::` second copy | 4 | SeqDriver compiles `uvm_pkg` twice under two names; the `uvm_pkg::` twin of each of these four reaches golden EXACTLY (`g=4 pris=0 pat=4`, `g=2 pris=0 pat=2`). Pre-existing package-naming difference. |

The head shape's own four objects are the cleanest rows in the file:

```
g=4 pris=0 pat=4  bit_select (…::arb_sequence_q[[i]].sequence_ptr::avail_sequences) 791:37-791:55
g=2 pris=0 pat=2  ref_obj    (…::arb_sequence_q[[i]].sequence_ptr::i)               791:53-791:54
g=2 pris=0 pat=2  |vpiFullName:…::arb_sequence_q[[i]].sequence_ptr::avail_sequences
g=2 pris=0 pat=2  |vpiFullName:…::arb_sequence_q[[i]].sequence_ptr::i
```

golden's count reached exactly, from zero.

---

## 6. THE TARGET ROWS — the head

`rowheads.sh` (heads counted with `grep -c '^LHS:'` anchored at column 0; a
missing side prints SKIP-NOFILE and is COUNTED).

| row | pristine | patched | head OBJECT before | head OBJECT after | verdict |
|---|---|---|---|---|---|
| **SimpleUVM default** | 128 / 1 | **62 / 1** | `hier_path arb_sequence_q[…].sequence_ptr` @791:22 | `int_var k` @**919:35** | **CLEARED, ADVANCED** |
| **SimpleUVM testflags** | 128 / 1 | **62 / 1** | same | same | **CLEARED, ADVANCED** |
| **Scoreboard default** | 128 / 1 | **62 / 1** | same | same | **CLEARED, ADVANCED** |
| Scoreboard testflags | SKIP-NOFILE | SKIP-NOFILE | — | — | SLANG_REJECT, counted |
| SeqDriver default/testflags | 56 / 1 | **56 / 1** | `class_var access_record` | *unchanged* | **PROTECTED** |
| BuildUVMPkg default/testflags | 94 / 1 | **94 / 1** | `struct_typespec m_uvm_factory_type_pair_t` | *unchanged* | **PROTECTED** |
| ClassVar, LocalScopeHierPath, ApbSlave, SVSwitch, both modes | 0 / 0 | 0 / 0 | PASS_CMP | PASS_CMP | unchanged |

**The head this pass was sent to kill is GONE on all THREE rows**, the line
count went **DOWN** (128 → 62), and the three patched cmps are still **one
shared head object**, byte-identical to each other with ids stripped
(`md5 fa1ec44cfeaa10cb18d672982096d40a`). The two rows the brief protected by
name — SeqDriver's 56-line head and BuildUVMPkg's 94-line head — are unchanged
in count AND in head object.

### R0 — the NEW head, decoded

```
uvm_sequencer_base.svh:919:   automatic int k = i;
LHS int_var: (uvm_pkg::uvm_sequencer_base::m_wait_for_available_sequence::k)  919:35-919:36
RHS int_var: (uvm_pkg::uvm_sequencer_base::m_wait_for_available_sequence::k)  919:35-919:36
```

Same class, same span, same name, same fullname, same typespec, same parent.
Diffing the two halves gives **exactly ONE** difference:

```
< |vpiAutomatic:1        <- golden
>                        <- ours: the property is absent
```

A **fork-body `automatic` lifetime declaration** whose `vpiAutomatic` we do not
set. One property, one line, one object — and it stands one line above the very
construct this pass fixed (`arb_sequence_q[is_relevant_entries[k]].sequence_ptr`
at 920). This is the smallest head this ladder has produced on these rows.

---

## 7. REFUTATIONS — all three measured, and all three changed what got written

### RF-1 — "a select's index hangs off the hier_path." **FALSE in 2 362 golden objects.**

Every one of the twenty cells in arms `c1` and `c2` says the index hangs off the
path, and the head shape does too. The generalisation is nevertheless FALSE:
detector E2, run on GOLDEN before the fix, reports **2 362 objects in 70
databases** where golden parents a non-trivial index at the BIT_SELECT
(1 256 operations, 967 hier_paths, 89 bit_selects, 49 func_calls, 1 part_select).

The discriminator is **trailing vs mid-path**, and it is visible inside the arms
themselves once you look: arm `c2` cell d6's INNER path `h.idx[i]` — a TRAILING
select, sitting inside an index — parents its own index at its bit_select in
GOLDEN, while every mid-path cell in the same file parents at the path. Golden's
twelve SimpleUVM E2 objects are all trailing (uvm_reg_map 771/772/773,
uvm_objection 696/712/715, …), and OUR side already agrees with golden on every
one of them.

Had the law been widened on the strength of its twenty supporting cells, this
pass would have mis-parented 2 362 objects that were already right.

### RF-2 — "the trailing sites are the same law, just unfixed." **FALSE — golden is not even self-consistent there.**

The obvious next step is to apply the naming law to trailing selects too; the
corpus population is 54 objects, three times the head's. `uvm_reg_map.svh`
refutes it in three consecutive lines:

```
771  if (top_map.m_regs_by_offset[info.addr[i]] == rg)      golden: top_map.m_regs_by_offset
772     top_map.m_regs_by_offset[info.addr[i]] =            golden: top_map.m_regs_by_offset[]
773       top_map.m_regs_by_offset_wo[info.addr[i]];        golden: top_map.m_regs_by_offset_wo
```

Same index expression, same array, three lines apart: the LVALUE gets `[]` and
the two RVALUES get **no brackets at all**. That is a different Surelog code
path with its own rules, and no single rewrite of ours can produce all three.
It is left standing as **residue R1**, with its population measured.

### RF-3 — "joinRef is a textual proxy, so widening its use is unsafe" (r10uvm78 F2). **Settled by census, not by argument.**

`joinRef` decides `::` vs `.` from the PREFIX; ComputeFullName decides it from
package/`class_defn` ancestry, and r10uvm78's RF-1 found 768 golden objects
where the two disagree. The proxy question is therefore real. It is settled
here by measuring the OVERLAP rather than the rule:

| | golden E4 | ours E4 |
|---|---|---|
| SimpleVMM default+testflags | 764 | **0** (SLANG_REJECT — we build no database at all) |
| Ariane2024 default | 4 | **0** |
| SeqDriver / SimpleUVM / Scoreboard / BuildUVMPkg ×7 | **0** | 2 417 |
| ClassVar / LocalScopeHierPath ×4 | **0** | 6 |
| everything else, both corpora | 0 | 0 |

The two populations are **disjoint**. `joinRef` can only turn a `.` into a `::`,
so it cannot reach a database where we hold none — and in every database where
we do, golden holds zero. The byte verifier then found exactly those 11
databases and no others.

---

## 8. RANKED RESIDUES

**R0 — the `automatic` lifetime property.** `int_var` for a fork-body
`automatic int k = i;` (uvm_sequencer_base.svh:919:35) missing `|vpiAutomatic:1`.
**The new head of all three target rows, 62 lines, ONE property.** By far the
cheapest head this ladder has been handed.

**R1 (measured) — the TRAILING select's name.** 54 objects, one source family
(`top_map.m_regs_by_offset[info.addr[i]]` ×3 sites × 7 databases). Golden's
targets are `top_map.m_regs_by_offset`, `top_map.m_regs_by_offset[]` and
`top_map.m_regs_by_offset_wo` for the SAME index expression on three consecutive
lines (RF-2) — a second Surelog site that needs its own characterisation before
anything is written.

**R2 (measured) — `ExprEval::prettyPrint`'s own closed dispatch.** decompileHelper's
OPERATION row recurses into prettyPrint, which drops a select operand exactly
the way the bit_select row does: golden renders `iarr[midx[i] + 1].f` as
`iarr[ + 1].f` (arm c2 cell d4). **Corpus population of a mid-path
select-inside-operation index: ZERO**, which is why it is not implemented — but
it is the same law one level down and it will matter the moment a corpus grows
one.

**R3 (measured) — the OPERATION and CALL index parent/scope.** Golden parents a
mid-path operation or func_call index at the hier_path too, and scopes its
operands through the path (arm c2 cells d3/d4/d7; `sram_otp_key_o[2 - 2].nonce`
in u2r's `ExpressionInIndex`). Excluded here because the SELECT gate is what the
census could prove disjoint from RF-1's 2 362 golden objects. Residual
E2/E3 after this pass: 411 / 286.

**R4 (measured) — the METHOD-TAIL hier_path builder.**
`m_children[child.get_name()].get_type_name` → golden `m_children[].get_type_name`,
**18 objects in 7 databases**. Same naming law, different builder (the parenless
method-call path, ExprEmit ~10476/10548). Predicted not to move, and did not.

**R5 (measured) — the 9 surviving E4 objects.** Two families:
`uvm_pkg::uvm_component_name_check_visitor::end_v.compiled_regex` (5) and
`uvm_pkg::uvm_reg_map::do_bus_access.rw.value[idx][i0 * 8+:8].value[idx]` (4,
which is r10uvm78's R8 unchanged). Not `emitMixedHierPath`'s sites.

**R6 — r10uvm78's R5, the BIT-SELECT INDEX joint at `ExprEmit.cpp:13636`,
still FENCED and still untouched.** `idxPrefix = prefix + "." + name`. This
pass's arm c1 cells c4/c5 (`marr[midx[i]]`, `marr[midx[midx[i]]]`) reproduce it
exactly: golden `…::marr::midx`, ours `…m_choose_next_request.marr::midx`. It
reaches SVSwitch, a canary; `git diff` shows line 13636 unmodified.

**R7 — the innermost index ref's `vpiActual`.** Our ref_obj for the head's `i`
carries `|vpiActual: int_var` and golden's does not (arm c1, one line). Present
identically in both binaries; unrelated to these laws.

---

## 9. CANARIES AND BOUNDARIES

* `canaries.sh` (surelog) **ok=52 changed=0 absent=0**, unknown-names=8 (the
  expected u2r-only count); (u2r) **ok=9 changed=0 absent=0**, unknown-names=25.
* `ctcan2.sh` `EXPECT_UNKNOWN=1` (surelog) **ok=58 changed=0 absent=0**;
  `EXPECT_UNKNOWN=6` (u2r) **ok=1 changed=0 absent=0**. Both PASS.
* `canaudit.sh` **audited=31 UNCOVERED=0 FENCE-BREACH=0** — every brief-protected
  name is carried by a script that RUNS here, and none of the four slang-fenced
  names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) is
  dispatched by any driver in this directory.
* The four named canaries plus ApbSlave checked **BY DATABASE, byte for byte**,
  both modes: `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`,
  `SVSwitch`, `ApbSlave` — **all 10 BYTE-IDENTICAL**. (The byte verifier's 11
  movers independently exclude them.)
* **BOUNDARIES.** Every arm the brief fences, run on BOTH binaries:
  r10uvm78's `c1_classpsel` `c2_idxpsel` `c3_constsel` `v2_pkg` `v3_clsinmod`
  `v8_qual` `v9_local` `v11_bounds` — **8/8 pris→pat BYTE-IDENTICAL**;
  r10uvm77's `c1_builtin` `c2_local` `c3_kind` `c4_edge` `v77w4` `v77x1` `v77x2`
  `v77x3` `v77x4` — **9/9 BYTE-IDENTICAL**; the sd9/sd10 grid cells —
  **16 compared, 0 moved**. No cell outside this pass's laws moved.

---

## 10. ARMS

`PAT=<patched> PRI=<pristine> ct79arm.sh <arm.sv>` — golden and BOTH binaries in
ONE scratch dir, so the absolute-path lines `uhdm-dump` prints for Surelog's
synthesized `builtin.sv` are identical across all three reads.

| arm | what it isolates | pristine | patched |
|---|---|---|---|
| `c1_nestedidx.sv` | THE HEAD's shape verbatim, plus a queue/array pair, a plain-index control, the two R6 plain-select cells, and a MODULE-scope twin | 1 head, 186 dump-line sides from golden, `e1=3 e2=3 e3=3 e4=3 e5=3` | 1 head, **102** sides, **`e1=0 e2=0 e3=0 e4=0 e5=0`** |
| `c2_idxkind.sv` | the WHOLE index-kind lattice: depth-2, depth-3, operation, operation-with-select, constant, member-chain, call, LVALUE, multi-dim, MEMBER-select, part-select | 1 head, 344 sides, `e1=8 e2=10 e3=11 e4=10 e5=3` | 1 head, **144** sides, `e1=1 e2=3 e3=4` **`e4=0 e5=0`** |

Golden's census on both arms is `e1=e2=e3=e4=e5=0` with the SAME `hp/elems/idxs`
counts as ours — the law restated as a measurement, on both sides. `c2`'s
residual `e1=1` is cell d4 and `e2/e3` are cells d3/d4/d7: **residues R2 and R3,
by name, and nothing else**. TEN of `c2`'s ELEVEN cells now carry golden's
hier_path name byte for byte; the eleventh is d4.

The MODULE-scope cells (c1 c6/c7) are the load-bearing half of the joint law:
golden writes `work@top.marr2[[j]].sequence_ptr.midx2` there, so `joinRef` must
return the OLD `.` outside a `::` scope — which is why 679 module-scoped u2r
databases are byte-identical.

---

## 11. FILES

| file | role |
|---|---|
| `r10uvm79cen.cpp` | the census instrument — E1…E7 + `R10UVM79_LIST` / `R10UVM79_NAMES` |
| `build79.sh` | builds it to `/tmp/r10uvm79cen` |
| `ct79cen.sh` | runs it over a WHOLE verify_golden workdir, both sides |
| `ct79names.py` | JOINS golden and our hier_path NAMES and reports every disagreement |
| `ct79arm.sh` | arm driver: golden + BOTH binaries in ONE scratch dir |
| `ct79gate.py` | STATED GATE == CODE GATE (PASS on patched, exit 5 on pristine) |
| `mv79.sh` | per-shape MULTISET content analysis of the movers |
| `mvclass79.py` | attributes every moved line to one law; UNATTRIBUTED fails the run |
| `mvgold79.sh` | attribution: every moved shape counted in golden / pristine / patched |
| `c1_nestedidx.sv` `c2_idxkind.sv` | the arms |
| `rowheads.sh` `ct8rows.sh` `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the standing gate instruments, carried forward unmodified |

---

## 12. VERIFIER PASS — TWO CODE FIXES LANDED BEFORE SHIPPING

The adversarial verifier rebuilt BOTH binaries from `/tmp/r10uvm79.patch` on a
fresh 113a511 and reproduced every headline number bit for bit (md5
`2e436f39c00bceacfe5bfcb6c7d0203c` / `eacd60adb66c45ccdf5db8cb56596955`,
23/0 goldens + 0/23 with `/bin/false`, 0 differing rows on both corpora,
0 + 11 byte movers with the 11 size deltas exact, census 54/411/286/9/0 with
E5 retired, heads 128 -> 62 on all three rows, three cmps one shared object
`fa1ec44cfeaa10cb18d672982096d40a`, 17/17 uvm77+uvm78 arms byte-identical).

Six NEW arms (`v79v1`…`v79v6`) then drove the laws through spellings the pass's
own two arms do not reach, judged **PER SOURCE LINE** by `v79arm.sh` /
`v79perline.py` so that a per-cell regression cannot hide inside a smaller
whole-file total.  Two cells came back wrong and BOTH are fixed here.

### V-F1 — `§ hpMidSelIdxSelectIsBitSelectV79` (renderer)

`idxDecompile79` dispatched on the slang expression KIND, so every
`ElementSelect` took the `bit_select` arm.  But decompileHelper dispatches on
the UHDM OBJECT, and only a select over a PLAIN IDENTIFIER is a `bit_select`;
a select written over a MEMBER ACCESS is a **hier_path**, a row decompileHelper
does not have -> the EMPTY STRING.  MEASURED on golden:

| written | golden | unfixed | fixed |
|---|---|---|---|
| `iarr[h.idx[i]].f` (this pass's own `c2` d6) | `iarr[].f` | `iarr[[i]].f` | `iarr[].f` |
| `iarr[this.midx[i]].f` | `iarr[].f` | `iarr[[i]].f` | `iarr[].f` |
| `iarr[s.idx[i]].f` | `iarr[].f` | `iarr[[i]].f` | `iarr[].f` |
| `iarr[s2[j].idx[i]].f` | `iarr[].f` | `iarr[[i]].f` | `iarr[].f` |
| `iarr[bidx[i]].f` (INHERITED member — the control) | `iarr[[i]].f` | `iarr[[i]].f` | `iarr[[i]].f` |

So `c2`'s score is **NINE of eleven** cells name-exact before this fix, not ten:
d4 (residue R2) *and* d6.  With the fix it is **TEN**.  Only the NAME is
corrected — golden DOES hang such an index off the hier_path, so
§ hpMidSelIdxAtPath79's structural half is deliberately left alone.

### V-F2 — `§ hpMidSelIdxAtPathRvalueOnlyV79` (SITE 2 post-pass)

At SITE 2 the "index at the path" half is an RVALUE rule.  Golden, one class
method, the same member select two lines apart:

```
rvalue   r = h.arr[midx[i]].f;    bit_select midx  parent = the HIER_PATH
LVALUE       h.arr[midx[i]].f = 4; bit_select midx  parent = the MEMBER BIT_SELECT
```

The unfixed post-pass reparented the LVALUE index at the hier_path, and the
**PRISTINE 113a511 build was RIGHT on that field** — the one pristine-right ->
patched-wrong cell the whole battery found.  Gating the post-pass on `!inLhs`
restores golden's parent and keeps the name the law does fix.  SITE 1 is
untouched: golden parents the index at the path for the LVALUE base select too
(`iarr[midx[i]].f = 3`, `iq[midx[i]].f = 5` — byte-exact either way).

### Both fixes are CORPUS-INERT, and that is measured, not argued

Census E7 (the structural firing set) is 18 objects in 7 databases and every one
is the SAME shape, `arb_sequence_q[avail_sequences[i]].sequence_ptr` — a BASE
select with a plain-identifier index.  So neither fix can reach the corpus, and
the byte verifier confirms it: **fixed vs patched = 0 content movers on both
corpora** (679 u2r paths 0 movers; 953 surelog paths, the single flagged
`default/Scoreboard` has `sizedelta=0 REMOVED=0 ADDED=0` and is the KNOWN
Scoreboard/default nondeterminism — 12 solo re-runs, 6 per binary, produced BOTH
md5s from BOTH binaries).  Fixed vs pristine reproduces the SAME 11 movers,
10 of them md5-identical to the unfixed patched build.

### Residues this pass leaves (verifier-ranked, all corpus population ZERO)

* **V-R1 — the NESTED joint.**  § hpMidSelIdxAtPath79 says the index is scoped
  "and everything nested under it"; the code gets the FIRST level right and the
  next level still hard-joins.  `iarr[midx[midx[i]]].f`: golden
  `…::iarr[].f::midx::i`, ours `…::iarr[].f.midx::i`.  Same for a `part_select`
  or a call ARGUMENT under the index.  It lives in the generic bit_select
  prefix chaining, OUTSIDE `emitMixedHierPath`, so it is not this pass's surface.
* **V-R2 — the QUALIFIED-base select index.**  `iarr[pk4::pidx[i]].f` and
  `iarr[deep::stat[i]].f`: golden writes `iarr[pk4::pidx].f` / `iarr[deep::stat].f`
  (the qualified NAME, no brackets — Surelog never builds the select).  Ours
  keeps `[i]`.  Unchanged by both fixes and no worse than pristine.
* **V-R3 — the CAST index.**  `iarr[int'(i)].f` -> golden `iarr[].f`; ours
  renders the cast text.  `rendersAsItself` returns true for
  `ExpressionKind::Conversion`; golden's prettyPrint has no cast row.
* **V-R4 — R2 confirmed on two more spellings**: `l[i ? midx[j] : k].f` ->
  golden `l[i ?  : k].f`, and `iarr[-midx[i]].f` -> golden `iarr[-].f`.

### Verifier files

| file | role |
|---|---|
| `v79arm.sh` | golden + BOTH binaries in ONE scratch dir, judged per source line |
| `v79perline.py` | the PER-CELL regression detector: prints `**WORSE**` per source line |
| `v79v1_idxkind.sv` | 16 index kinds incl. cast, ternary, system call, concat, pkg param, part/indexed-part, bit-select-of-call, bit-select-of-partsel |
| `v79v2_recv.sv` | receivers: queue, dynamic, assoc[int], assoc[string], multi-dim (each dim), MEMBER select, and every one again as an LVALUE |
| `v79v3_scope.sv` | package / interface / module / generate / task scope |
| `v79v4_base.sv` | the SELECT's own base: `this.`, `pkg::`, `cls::`, inherited, member-chain, select-then-member-then-select, depth-4 |
| `v79v5_deep.sv` | two selects in one path, both dims, ternary-with-select, select-with-ternary, LVALUE, module nested struct |
| `v79v6_ca.sv` | continuous assign, `always_comb`, `always @*`, procedural lvalue, generate cont-assign, `foreach` index |
