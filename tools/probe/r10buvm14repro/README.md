# r10buvm14 — § `builtinRecvMultiDimStepIsBitSelectChain14` — **the BuildUVMPkg head cleared, 140 → 29 cmp lines**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `1392d07` |
| worktree | `/tmp/wt_r10buvm14` |
| pristine binary | md5 `003f56f98111aeeb443c4c956b7cd061` |
| patched binary | md5 `560b012a00664b58058cffb07a47a045` |
| production surface | `src/ExprEmit.cpp` ONLY — 207 inserted / 110 deleted, of which **66 added code lines and 34 removed** once re-indentation is discounted (`git diff -w`) |
| probe surface | `tools/probe/r10buvm14repro/` only |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines.  What it does is clear the head buvm13
left as its residue R0.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| cmp lines, default / testflags | **140 / 140** | **29 / 29** |
| head object | `hier_path(m_recur_states[lhs][rhs].exists)@21564:13` — `Path_elems` **3 vs 2** | `io_decl(lhs)@23219:62 < function(uvm_pkg::uvm_cause_effect_link::get_link)`, `RHS <null>` (**R0**) |
| corpus-wide hier_path census, surelog, DISAGREE | 834 | **830** |
| the same, AGREE | 25 069 | **25 073** |

Both modes' cmp logs are byte-identical to each other on both binaries
(`373f66ad06d7` pristine, `26e8f870afc4` patched), and the other **ten** cmp
logs of the seven-row head set are **byte-identical between the two binaries**
(§7).

## 1. THE HEAD, DECODED — **and the brief's `RHS: <null>` is REFUTED by the log itself**

The brief (carrying buvm13's README forward) recorded this head as
`LHS hier_path … ; RHS <null>` and asked which SINGULAR field could be null on
our side.  **It is not a singular field and there is no null.**  The pristine
cmp log has a full `RHS:` decompile:

```
LHS: hier_path (m_recur_states[lhs][rhs].exists) @21564:13 < operation @21564:12
       Path_elems = bit_select(m_recur_states)[full m_recur_states[lhs]]
                    bit_select(<no vpiName>)  [full m_recur_states[lhs][rhs]]
                    method_func_call(exists)
RHS: hier_path (m_recur_states[lhs][rhs].exists) @21564:13 < operation @21564:12
       Path_elems = ref_obj(m_recur_states[lhs][rhs])
                    method_func_call(exists)
```

Read against `BaseClass.h` that spelling has exactly one producer.
`hier_path::Compare` (`generated/src/hier_path.cpp`) compares
`SafeCompare(lhs, lhs->Path_elems(), rhs, rhs->Path_elems(), …)` **FIRST**, then
`Root_value`, and only then `VpiName`; and the VECTOR overload's SIZE-MISMATCH
arm sets **both** sides to the OWNERS:

```cpp
if ((r = static_cast<int32_t>(lhs->size() - rhs->size())) != 0) {
  context->m_failedLhs = lhs_obj;      // the hier_path
  context->m_failedRhs = rhs_obj;      // the hier_path
```

So the head is a `Path_elems` **SIZE MISMATCH, 3 against 2** — which is why both
sides decompile and why the two names being EQUAL never gets read.  A pass that
had gone hunting for a null singular field would have been looking for something
that is not there.  **The head-decode discipline earns its place here by
CONTRADICTING the brief, not by confirming it.**

## 2. GOLDEN'S SHAPE, AND WHY IT IS NOT A NEW SHAPE

`uvm_pkg.sv:21562-21564` (`uvm_comparer::object_compared`, an out-of-body method)
is a three-rung ladder over one 3-D associative class property
(`recursion_state_e m_recur_states[uvm_object][uvm_object][uvm_recursion_policy_enum];`,
:18702):

| written | golden `Path_elems` | ours, pristine |
|---|---|---|
| `m_recur_states.exists(lhs)` @21562 | `ref_obj(m_recur_states)` , `method_func_call(exists)` | **= golden** |
| `m_recur_states[lhs].exists(rhs)` @21563 | `bit_select(m_recur_states)` full `m_recur_states[lhs]` , `method_func_call` | **= golden** (uvm74) |
| `m_recur_states[lhs][rhs].exists(recursion)` @21564 | `bit_select(m_recur_states)` full `m_recur_states[lhs]` , `bit_select(<unnamed>)` full `m_recur_states[lhs][rhs]` , `method_func_call` | **ONE flat `ref_obj(m_recur_states[lhs][rhs])`** |

The axis is the RECEIVER'S DIMENSION COUNT and nothing else: 0-D and 1-D already
agreed, 2-D did not.

**AND THE 2-D SHAPE IS ONE THIS EMITTER ALREADY SHIPS.**  Four lines further on,
`m_recur_states[lhs][rhs][recursion].state` @21566 — the same property, three
dimensions, **no method call** — is emitted by the plain path builder and is
**BYTE-IDENTICAL to golden on the PRISTINE binary** (a 121-line dump window,
`diff` empty).  Three `bit_select`s, `vpiName` on the first only, and dimension
`k>0` carrying the SPAN OF DIMENSION `k-1`'s INDEX.  The defect was never "we do
not know the shape"; it was that the METHOD-CALL arm could not reach it.

## 3. DECODED FROM THE PRODUCER

`CompileHelper::compileSelectExpression`'s caller at
`CompileExpression.cpp:5586` — the `while (BitSelect)` loop that walks the
SIBLING `bit_select` nodes of one `paSelect`:

```cpp
the_name += "[" + decompileHelper(index) + "]";   // CUMULATIVE
bit_select *select = s.MakeBit_select();
select->VpiName(tmpName);        // the base name…
select->VpiFullName(the_name);   // …and the path THROUGH this dimension
select->VpiIndex(index);
select->VpiParent(path);
elems->push_back(select);
…
tmpName.clear();                 // <-- SO ONLY DIMENSION 0 IS EVER NAMED
BitSelect = fC->Sibling(BitSelect);
```

`tmpName.clear()` at the bottom of the loop is the whole of the "only the first
dimension carries `vpiName`" rule, and `the_name` accumulating one bracket group
per iteration is the whole of the cumulative-fullname rule.  Golden's own bytes
confirm both: the second `bit_select` at 21564 prints
`|vpiFullName:m_recur_states[lhs][rhs]` and **no `|vpiName:` line at all**.

## 4. THE LAW

> **§ builtinRecvMultiDimStepIsBitSelectChain14** — a step of a BUILT-IN METHOD
> call's RECEIVER path written with **N** dimensions is **N `bit_select`
> elements**, not one.  Dimension 0 carries `vpiName` = the base name and the
> span of the base-name token; every later dimension carries an **EMPTY
> `vpiName`** and the span of the PREVIOUS dimension's INDEX; `vpiFullName`
> accumulates one bracket group per dimension; and every index hangs off the
> ENCLOSING HIER_PATH (a constant stays unparented), exactly as uvm74's
> single-dimension rule already said.

### STATED GATE == CODE GATE

**STATED:** the step's TEXT is `<name>` followed by one or more NON-NESTED
bracket groups that TILE the rest of it, **and** the bound tree confirms the
SAME NUMBER of dimensions on that component.  Anything else refuses the whole
receiver path and leaves it the flat `ref_obj` it already was.

**CODE:** `src/ExprEmit.cpp` only.  `builtinRecvStepSelectors74` loses its
`pendMulti` refusal and returns a `RecvStep74` per step (base name, bracket
GROUPS with their offsets, one selector per group); `stepIdxGroups14` is the
text half and is deliberately the TIGHT direction — a nested `[`, an unclosed
group, an empty `[]` or anything after the last `]` all return false.  The
emission site runs uvm74's body once per dimension.

**For a SINGLE dimension the new loop reproduces uvm74's object field for
field** — `cum74` is then exactly the old `dotSoFar74` — which is why 1-D cells
(`m1[a].exists`, `sq[2].len`, `m_streams[name].exists`) are byte-untouched
across both corpora.

### the gates that were REFUTED, each on an arm cell or on the log

| candidate gate | refuted by |
|---|---|
| "the head is a SINGULAR field with `RHS <null>`" (the brief) | §1 — the cmp log carries a full RHS decompile; `hier_path::Compare` reads `Path_elems` FIRST and its size-mismatch arm sets BOTH owners |
| "the `hier_path`'s VpiName differs" | §1 — the two names are EQUAL and `VpiName` is compared AFTER `Path_elems`, so it is never reached |
| "golden names every dimension" | §3 + golden's bytes — dimension 1 has NO `vpiName` line; `tmpName.clear()` is the producer |
| "the fullname is the whole written component on every dimension" | arm a1 L3/L7 — golden's are `m2[a]` then `m2[a][b]` then `m2[a][b][c]` |
| "the law belongs to `.exists` / associative arrays" | arm a1 L4/L5/L6 — `.num`, `.size`, `.first` all take it, and L9/L10 take it on INT-keyed arrays |
| "only the BASE step can be multi-dim" | arm a1 L8 — `hh.mm[a][b].exists` converts, with `hh.mm[a]` / `hh.mm[a][b]` fullnames |
| "a dotted index is the same family" | arm a1 R1 + corpus `m_streams[stream.get_name()].exists` — the `dots` split cuts at the dot INSIDE the index, text and tree then disagree, and the step stays refused (**R1**) |
| "STATEMENT position needs the same fix" | arm a1 S1/S2 — a statement call emits a bare `method_func_call` and NO hier_path; the whole-dump attribution (§6) proves both untouched |

## 5. THE ARM — `a1_dims14.sv`, 17 golden hier_paths, **CONVERTED 8, OVER-FIRE 0**

`grid14.sh` is the three-way cell table (golden / pristine / patched), keyed on
the ELEMENT LIST: every element's KIND, `vpiName` and `vpiFullName` in order.
IDs and addresses appear nowhere.  Surelog and both binaries run in the SAME
directory (buvm8's `bndarms` trap — a UHDM database records the source file's
ABSOLUTE path).

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| L1 | `m0.exists(a)` — 0-D | `ref_obj , call` | = golden | unchanged |
| L2 | `m1[a].exists(b)` — 1-D | `bit_select(m1)[m1[a]] , call` | = golden | unchanged |
| **L3** | `m2[a][b].exists(c)` — **2-D** | `bit_select(m2)[m2[a]] , bit_select()[m2[a][b]] , call` | one flat `ref_obj` | **= golden** |
| L4/L5/L6 | the same 2-D receiver with `.num` / `.size` / `.first` | as L3 | flat | **= golden** |
| L7 | `m3[a][b][c].exists(d)` — **3-D** | THREE `bit_select`s | flat | **= golden** |
| L8 | `hh.mm[a][b].exists(c)` — MID step | `ref_obj(hh) , bit_select(mm)[hh.mm[a]] , bit_select()[hh.mm[a][b]] , call` | `ref_obj(hh) , ref_obj(mm[a][b]) , call` | **= golden** |
| L9 | `q2[1][2].size()` — LITERAL indices | 2 `bit_select`s, unparented constants | flat | **= golden** |
| L10 | `qn[i][j].size()` — VARIABLE indices | 2 `bit_select`s | flat | **= golden** |
| R1 | `m1[hh.s1[a]].size()` — a DOT inside the index | `bit_select(m1)[m1[]]` | 2 broken `ref_obj`s | unchanged — **R1** |
| R2 | `qn[idxarr[i]].size()` — a NESTED bracket | `bit_select(qn)[qn[[i]]]` | flat | unchanged — **R2** |
| R3/R4 | `m0.size()` / `m1[a].num()` | — | = golden | unchanged |
| S1/S2 | `m2[a][b].delete(c);` / `m1[a].delete(b);` — STATEMENT | no hier_path at all | — | untouched (§6) |

**Location-keyed: `CONVERTED=8 OVER-FIRE=0 MOVED-STILL-WRONG=0 residue=3
same=6`.  Name-keyed: `CONVERTED=8 OVER-FIRE=0 MOVED-STILL-WRONG=0`.**

`grid14.sh`'s second keying is the hier_path's own **NAME**, and that is a
CORRECTION made here: the first cut blanked the LOCATION outright, which
collapses a single-file arm into ONE bucket and degenerates the verdict to
`MOVED-STILL-WRONG=1` **whatever happened**.  `VpiName` IS a field
`BaseClass::Compare` reads, so a name-keyed join separates "the same written
path changed shape" from "a different object appeared".

`detcheck.sh`, 3 runs of the patched binary on each arm: **1 distinct hash, 0
NO_OUTPUT** on both.

## 6. THE PREDICTION WAS MADE FIRST — and the byte gate returned exactly it, plus one it EXONERATES

`pred14.sh` read the **956 pristine surelog** and **1358 pristine uhdm2rtlil**
databases and named the movers BEFORE the patched sweeps finished.  The pristine
signature is a `mc=1` hier_path holding a flat `ref_obj` whose name matches
`<ident>` + **two or more** non-nested bracket groups — `stepIdxGroups14`'s text
gate with `N>=2`.  It is stated as an UPPER BOUND, because bytes cannot show
whether the bound TREE will confirm the dimension count.

```
PREDICT 3 …/default/BuildUVMPkg-bf853d43/slang.uhdm
PREDICT 3 …/testflags/BuildUVMPkg-bf853d43/slang.uhdm
-- databases scanned=956   PREDICTED MOVERS (upper bound)=2
-- databases scanned=1358  PREDICTED MOVERS (upper bound)=0        (uhdm2rtlil)
```

The three objects, by name: `m_recur_states[lhs][rhs].exists` @`uvm_pkg.sv`
21564:13 (twice — the DEF and ELAB copies of `uvm_comparer::object_compared`)
and `m_recur_states[rhs][lhs].exists` @18764:13 (`uvm_copier::object_copied`,
one copy).  **Golden holds exactly those three and no others**, with the 3-element
shape.

`byteverify.sh` returned **3 movers / 956** on surelog and **0 / 1358** on
uhdm2rtlil.  `SELFCHECK` 955/956; `SELFCHECK1` reported 4 (the planted
corruption plus the three real movers) and 1 on uhdm2rtlil.

**The third mover is `Scoreboard/default`, it was NOT predicted, and it is NOT
this pass.**  That is the direction the predictor exists to catch, so it was run
down rather than waved past:

* the two dumps have the **same number of lines** and `sort`ed are
  **BYTE-IDENTICAL** — a pure PERMUTATION of three `bit_typespec` objects in a
  top-level listing, 39 deletions against 39 insertions of the same text;
* the hier_path census of the two databases is **identical row for row**;
* **the PRISTINE binary reproduces it on its own.** Four `verify_golden` runs of
  the PRISTINE binary at `--jobs 2` produced **THREE DIFFERENT hashes**
  (`44c0ee47…`, `82ad393e…`, `e13c130b…`, `44c0ee47…`), and all of them — plus
  the patched one — have the **same sorted-dump md5 `f0bb7801f5f1b5fe…`**;
* run SERIALLY out of the test directory, pristine and patched produce ONE hash
  over **6 runs** (`44c0ee47c8e6702e`).

This is `MEMORY.md`'s recorded emitter nondeterminism (SourceLocation compares
across macro buffers flip per run under parallel parse), not a mover.

**Attribution of the two REAL movers** (`attr14.sh`, whole-dump, path-normalised,
BuildUVMPkg/default): 6 deletions, 68 insertions; **source lines touched:
`21564` (16), `18764` (8), `21558` (2), `21557` (2) and NOTHING ELSE**; object
kinds touched: `hier_path`, `bit_select`, `ref_obj`, `io_decl` and their
`vpiName`/`vpiFullName`/`vpiParent`/`vpiIndex`/`vpiActual` lines.  21557/21558
are the two `io_decl`s the new index refs now BIND to — golden binds them too.

## 7. THE GATES, EACH IN ONE LINE

1. **Builds.** pristine `003f56f98111aeeb443c4c956b7cd061`, patched
   `560b012a00664b58058cffb07a47a045`, `-j 2`, md5 taken separately.
2. **Goldens.** patched **23 PASS / 0 FAIL**, pristine **23 / 0**,
   `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (`SLANG_UHDM` exported
   explicitly to each).
3. **uhdm2rtlil.** `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in both
   modes on both binaries.  `ct14rows` **0 differing ROWS** — testflags against
   the committed `results/gate_uhdm2rtlil.csv` (731 rows, which is testflags
   only), and patched-vs-pristine over all **1462** rows for the default half
   that CSV does not carry.  Dump histograms identical.
4. **surelog.** `470+11+5+283+25` default and `466+9+5+3+1+284+23+1+2`
   testflags, identical on both binaries; `ct14rows` **0 differing ROWS over
   1588** against the committed `results/golden_surelog.csv`.  **NO ROW
   CONVERTED**; nothing promoted; `results/*.csv` never written.
5. **Bytes.** surelog **3 / 956** (the 2 PREDICTED + the exonerated
   nondeterminism artefact), uhdm2rtlil **0 / 1358**; `SELFCHECK` 955/956 and
   1357/1358; `SELFCHECK1` 4 and 1.
6. **Canaries.** `canaries.sh` surelog **ok=52 changed=0 absent=0** against the
   committed baseline AND against pristine; u2r **ok=8** (testflags/committed)
   and **ok=16** (all rows/pristine), changed=0 in every run.  `ctcan2.sh`
   **ok=58 changed=0** (surelog) and **ok=2 changed=0** (u2r).  `canaudit.sh`
   **29 audited, 0 UNCOVERED, 0 FENCE-BREACH**, both self-tests live.
7. **Pins.** `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
   `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex e3e354129d5a` /
   `73a10e8217e5`, `YosysOldOr d68e0796d62c` — byte-identical on both binaries
   in both modes.
8. **The seven-row head set.** heads `1 -> 1` everywhere; ten of the twelve cmp
   logs **byte-identical between the binaries**; only BuildUVMPkg's two moved,
   `140 -> 29`, and its two modes are byte-identical to each other on both
   binaries.  `SeqDriver/SimpleUVM/Scoreboard/MiniAmiq` stay 89,
   `Earlgrey_0_1` 9743 / 33, `Rggen` 66.
9. **The BOUNDARY GATE.** `bndsub14.sh` over **LISTED=2311 PROCESSED=2311** arm
   sources found anywhere under `tools/probe/` (subdirectories included; the
   list travels on fd 3 and every child gets `</dev/null`):
   **IDENTICAL=2189 MOVED=2 REJECT-BOTH=120 ONE-SIDE=0**.  The two MOVED are my
   own `a1_dims14` and — **the gate earning its keep** —
   `r10uvm74repro/v74_edge.sv`, whose cell is literally commented
   `// e_multidim: TWO index groups on one component`, uvm74's own explicit
   REFUSAL cell.  Its grid: `CONVERTED=1 OVER-FIRE=0`,
   `qq[i][j].len` going flat-`ref_obj` → golden's two `bit_select`s.
   **The boundary gate's moved arm moves TOWARD golden.**
10. **The corpus-wide hier_path census** (`cenall14.sh`, every database of a
    sweep workdir, each test's golden read from its OWN `cmds.txt`, SKIP counted
    and the header count asserted against the joins reported):

| | surelog (956 joined, 617 SKIP) | | uhdm2rtlil (1358 joined, 104 SKIP) | |
|---|---|---|---|---|
| | pristine | patched | pristine | patched |
| AGREE | 25 069 | **25 073** | 3 154 | 3 154 |
| **DISAGREE** | **834** | **830** | 48 | 48 |
| ARITY-DIFF | 21 932 | 21 932 | 40 | 40 |
| MISSING-OURS | 2 799 | 2 799 | 42 | 42 |
| EXTRA-OURS | 37 757 | 37 757 | 48 | 48 |

**−4 DISAGREE, +4 AGREE, every other class unchanged, and uhdm2rtlil frozen.**
Four keys: `21564:13` and `18764:13` in each of BuildUVMPkg's two databases.
Nothing anywhere went backwards.

**CALIBRATION FIRST, golden against golden** (BuildUVMPkg): `rows 7742 / keys
4578 / AGREE 4578 / DISAGREE 0 / ARITY-DIFF 0 / MISSING 0 / EXTRA 0`.  A join
that cannot report zero on identical inputs cannot report 4 on different ones.

### the census's own measured trap

The FIRST run of `cenjoin14.py` reported `AGREE=0 MISSING=7322 EXTRA=7405` on
two databases that agree about almost everything, for **two** reasons, both
fixed and both recorded in the tool:

* **our `hier_path`s carry an EMPTY `VpiFile`** while Surelog's carry the source
  path, so the file half of the key was `""` on every one of our rows.  The file
  is now inherited from the nearest ANCESTOR that has one.
* **the two producers label the same object's VIEW differently** —
  `uvm_pkg.sv:8620:9` climbs to a `TopPackage` in Surelog's database (`ELAB`)
  and to an `AllPackages` copy in ours (`DEF`) — while the TOTALS agree exactly
  (2821/2822 `DEF`, 4912/4912 `ELAB`).  The view is therefore in neither the key
  nor the value; the DEF and ELAB copies land in ONE bucket and the MULTISET
  compare separates them by CONTENT, which is the field the judge can see.
  (buvm13 hit the MIRROR IMAGE of this trap: there the view had to be taken from
  the OWNER.)

## 8. RESIDUES, each measured and left deliberately

* **R0 — THE NEW HEAD, and it is fully decoded.**
  `io_decl(lhs)@23219:62 < function(uvm_pkg::uvm_cause_effect_link::get_link)`,
  `RHS: <null>` — this time a genuine SINGULAR `SafeCompare`, and the only
  singular field in the walk whose value can be an `io_decl` is
  `ref_obj::Actual_group()` (buvm13 §1).  The site is
  **`get_link.set(lhs, rhs);` @uvm_pkg.sv:23233**: a
  **§ `retNameRecvCollapse69`** collapsed call — the receiver names the enclosing
  function's own return variable, so both producers emit
  `func_call(get_link)` carrying the METHOD's arguments — and **golden BINDS
  those arguments to the enclosing subroutine's formals**
  (`vpiActual -> io_decl(lhs)` / `io_decl(rhs)`) where **we leave them BARE**.
  Our whole `function(uvm_cause_effect_link::get_link)` DEF-view subtree is
  otherwise byte-identical to golden (126-line dump window, `diff` empty).
  A BIND-WINDOW family, sibling to buvm13's `§ classArgBind12` — the collapsed
  arm at `ExprEmit.cpp` `retNameRecvCollapse69` emits its arguments with no
  window open.
* **R1 — a DOT INSIDE THE INDEX.**  `m_streams[stream.get_name()].exists`
  (uvm_pkg 40585/40594) and `m_children[child.get_name()].get_type_name`
  (39721).  The `dots` split cuts `recvText` at the dot inside the index, so the
  text says two components where the tree says one and the whole path stays
  refused: our elements are `ref_obj(m_streams[stream)` and
  `ref_obj(get_name()])`.  Golden's is ONE `bit_select` whose fullname is
  `m_streams[]` — **the index renders EMPTY** because a `method_func_call` has no
  `decompileHelper` row (uvm89's closed dispatch).  Fixing it needs BOTH a
  bracket-aware receiver split AND uvm89's name renderer, i.e. two laws; this
  pass does neither and leaves the cells bit-for-bit as it found them (arm a1
  R1 is the witness).  **4 keys per UVM row.**
* **R2 — a NESTED bracket in the index** (`qn[idxarr[i]].size`).  Refused
  identically by uvm74's gate and by `stepIdxGroups14`; golden renders
  `qn[[i]]`.  Deliberately unchanged.
* **R3 — the `with`-clause element FULLNAME.**  `from_node.m_sync.find_index`
  (uvm_pkg 34865/34866/34933/34934): golden leaves the FIRST element name-only
  (`from_node`) and scopes only the second; we scope both.  `VpiFullName` is NOT
  a field `Compare` reads, so this is dump-only.  **8 rows on BuildUVMPkg.**
* **R4 — `randomize` with a constraint block.**  `seq_or_item.randomize` (56967,
  56980): golden names the hier_path after the RECEIVER ALONE and scopes the
  element, exactly as it treats an array `with` clause; we name it
  `seq_or_item.randomize`.  `VpiName` IS cmp-visible.  **4 rows.**
* **R5 — `ExprEval::prettyPrint` SPACING**, uvm89's R1, untouched: golden
  `fields[fld_idx - 1].get_lsb_pos`, ours `fields[fld_idx-1]…`.  **20 rows on
  BuildUVMPkg — the biggest remaining `mc=1` family** and a name-text pass of its
  own.
* **R6 — the METHOD ARGUMENT's own fullname.**  Golden scopes a built-in
  method's argument through the receiver path
  (`…::object_compared::m_recur_states[lhs][rhs].exists::recursion`); we write
  `…::object_compared::recursion`.  Present identically at the 0-D and 1-D rungs
  that already compare EQUAL, so it is pre-existing, dump-only, and not this
  family.

## 9. REPRODUCING

```sh
./build14.sh                                        # the census instrument
./sweeps14.sh <bin> surelog    <out.csv> <workdir>  # one sweep, --jobs 2
./ct14rows.sh <baseline.csv> <fresh.csv>            # the ROW gate
./pred14.sh   <pristine workdir>                    # movers, from PRISTINE bytes
./byteverify.sh <patched wd> <pristine wd>          # SELFCHECK=1 SELFCHECK1=1
./attr14.sh   <pristine.uhdm> <patched.uhdm>        # whole-dump attribution
PRISTINE=… PATCHED=… ./grid14.sh a1_dims14.sv       # the arm
./cenall14.sh <workdir> <tag>                       # corpus-wide census
python3 cenjoin14.py <g.cen> <o.cen> --only-mc --sites
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
                                BuildUVMPkg Earlgrey_0_1 Rggen
find <repo>/tools/probe -name '*.sv' | sort |
  PRISTINE=… PATCHED=… ./bndsub14.sh                # the BOUNDARY gate
bash canaudit.sh canaries.sh ctcan2.sh
./detcheck.sh <bin> 3 a1_dims14.sv
```
