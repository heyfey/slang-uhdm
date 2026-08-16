# r10uvm74 — ADVERSARIAL VERIFIER REPORT

## VERDICT

**PARTIAL on the SHIPPED patch** (`/tmp/r10uvm74.patch`, md5
`0cd4ac8d3bc0992c91e99b93e6977b4c`). **PASS on the re-cut**
`/tmp/r10uvm74.verified.patch`.

The law is real, the head is genuinely cleared on all three target rows, and
**every number in the implementer's report reproduces exactly** — both binary
md5s bit-for-bit on builds I configured and ran myself, all five gates, the
design-wide census (400/414, 47 → 0), the seven movers with every REMOVED /
ADDED / size-delta figure, all three canary drivers, the mover prediction, and
the head depths. The law also **generalises past every cell the implementer
measured**: I populated nine product cells his four arms left empty and the
patch is =golden on six of them.

Two things stop it being a clean PASS, and one of them would have landed:

* **F2 (over-fire, latent).** The stated sub-law *"an INTEGER-LITERAL index is
  a BARE constant … NO `vpiParent` at all"* is **not the code gate**. The code
  tests the RAW TEXT for bare decimal digits, so every literal not spelled that
  way — `sq[4'd2]`, `sq['h2]`, `sq[ 2 ]` — falls to the `emitExpr` branch and
  gets a constant **parented at the `hier_path`**, which golden does not have.
  **STATED GATE != CODE GATE**, on this pass's own sub-law. Three measured
  cells, **zero corpus witnesses**, so it breaks no gate and would have shipped
  as a latent defect. **FIXED and re-verified below.**
* **F1 (scope over-claim).** *"Site 1 of 1"* is true of the `hier_path`
  builder and **false of the defect**. The identical name-and-span defect lives
  at a second site — the STATEMENT form's `mfc->Prefix(pr)` — with **6 witnesses
  in SimpleUVM/default alone**, unchanged before and after. Not a regression;
  ranked **R1**.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours, everywhere in this file.

---

## 0. WHAT I BUILT, AND THE ANCHORS

Applied to a **FRESH `61d5e36`** (`git worktree add --detach`), not to the
implementer's tree. `61d5e36` was main's head when I started; two passes landed
while I measured (`c31af36` r10earl45, `e07cb9c` r10sd5/SeqDriver-5) and **both
the shipped patch and my re-cut still `git apply --check` clean against
`e07cb9c`** — the two live passes named in my brief have landed without
colliding, as §0's hunk-separation predicted.

**One consequence to flag for whoever lands this:** `e07cb9c` reports SeqDriver
`1416141 -> 43`. My SeqDriver figures below (`1416141 -> 1417051`) are measured
against `61d5e36`, where that wall was still standing; they are a subtree print
size, not a distance, and they will not reproduce on top of `e07cb9c`. Every
other row (SimpleUVM, Scoreboard, BuildUVMPkg) is unaffected.

| worktree | base | content | md5 of `build/slang-uhdm` |
|---|---|---|---|
| `/tmp/wt_v74pris` | `61d5e36` | pristine (`git status --porcelain` **empty** except my own `bld.log`/`cfg.log`) | **`98b4d0a565ccbd8054182fccba9b3c2d`** |
| `/tmp/wt_v74p` | `61d5e36` | + SHIPPED patch | **`1104e3cfde7e5406226e92ea0de7f78e`** |
| `/tmp/wt_v74ref` | `61d5e36` | + patch + my F2/F3 fix | **`d38affdad5f4b2a93cd74426cd103fa1`** |

**Both claimed md5s reproduced bit for bit** on an independent
configure + build (`-j 2`, `[100%] Linking CXX executable slang-uhdm` →
`[100%] Built target slang_uhdm` read **before** any md5; md5s asserted in a
separate command; all 32-hex; `grep -c 'error:'` = 0 in every build log). Every
base was printed **and** grep-checked against
`^61d5e3628e75a42ee83f4dbfa793e55713aad3d6$`.

`git stash` never used. `results/*.csv` only ever READ. slang never patched.
`GOLDEN_DEFER` echoed `[UNSET]` at every sweep launch and `SLANG_UHDM` was
exported explicitly for every harness invocation. Sweeps `--jobs 2`, own
`--out`/`--workdir` under `/tmp/v74s`.

### Patch hygiene

`git apply --numstat` on a pristine `61d5e36`:

```
165  1  src/ExprEmit.cpp            <- production, the ONLY production file
430  0  tools/probe/r10uvm74repro/README.md
... 15 more files, ALL under tools/probe/r10uvm74repro/
```

**No `README.verifier.md` in the shipped patch** (it is mine — this file).
Nothing outside `src/ExprEmit.cpp` + `tools/probe/r10uvm74repro/`. No probe
script writes to `results/` (only `ct8rows.sh` READS the two committed
baselines), none touches `GOLDEN_DEFER`, and `ct74arm.sh` gives `SLANG_UHDM`
**no default** (`${SLANG_UHDM:?}`).

**Live-pass collision: NONE.** `/tmp/wt_r10sd5` modifies `src/ModuleEmit.cpp`
only. `/tmp/wt_r10earl45` modifies `src/ExprEmit.cpp` at hunks
`@@ -14511 / -14524 / -14613 / -14621`; this patch's hunks are at `@@ -4275`
and `@@ -12093` — separated by ~2 400 lines, no textual overlap.

---

## 1. FINDINGS

### F1 — "SITE 1 of 1" is true of the BUILDER and FALSE of the DEFECT: a second, corpus-witnessed site

The README's b3 row for `c_stmt` reads *"no hier_path on either side —
unchanged — `§ deepRecvCall11` statement form builds none"*. That sentence is
true and it hides a disagreement, because the statement form does not build a
`hier_path` — it builds a `method_func_call` with a `Prefix` `ref_obj`, and
**that prefix carries the identical name-and-span defect this pass exists to
fix**:

```bash
# b3_context.sv line 33:  sq[i].itoa(3);
grep -n 'line:33:' /tmp/v74s/arm_b3_context_fin/{g,o}.dump
```
```
GOLDEN  \_ref_obj: (work@b3::user::f::sq),    line:33:7, endln:33:9     <- BASE NAME, span stops before the [
OURS    \_ref_obj: (work@b3::user::f::sq[i]), line:33:7, endln:33:12    <- whole written text, span through the ]
```

Neither `ct74cen.py` (it requires `vpiParent` = `hier_path`) nor
`ct74cells.sh` (it matches the literal text `(sq[i]), line:` which golden never
prints, because the prefix carries a SCOPED fullname) can see this cell. My own
census of `method_func_call` → `vpiPrefix` on **SimpleUVM/default**, joined on
start position:

```
golden prefixes whose text contains '[' : 0
ours (pristine) : 6      ours (patched) : 6      <- UNCHANGED by this pass
shared prefix positions 1528, DISAGREE 8, of which INDEXED 6:
  @919:13   LHS m_inst_override_queues        RHS m_inst_override_queues[obj]
  @1119:3   LHS m_inst_override_queues        RHS m_inst_override_queues[original_type]
  @1162:5   LHS m_inst_override_queues        RHS m_inst_override_queues[original_type]
  @1176:7   LHS m_inst_override_name_queues   RHS m_inst_override_name_queues[original_type_name]
  @1387:10  LHS m_inst_override_queues        RHS m_inst_override_queues[rtype]
  @2674:4   LHS m_streams                     RHS m_streams[stream        <- TRUNCATED, see below
```

The last one is worse than a span: the receiver text has a **dot inside the
index**, the naive `'.'` split of `recvText` cuts it in half, and we emit a
`ref_obj` literally named `m_streams[stream`. Golden emits `m_streams`.

**Not a regression** — 6 before, 6 after, byte-identical — and correctly out of
scope for a pass whose law is about `hier_path` steps. But *"Site 1 of 1"* as a
statement about the defect family is refuted, and the b3 table should say
`c_stmt DISAGREES on both binaries` rather than `unchanged`. Ranked **R1**.

**Command:** `ct74arm.sh b3_context.sv`, then the prefix census in §3.

---

### F2 — OVER-FIRE, and the one that would have landed: the constant-index sub-law's STATED GATE is not its CODE GATE

The README's sub-law for convention (c):

> an **integer-literal** index is a bare hand-built `constant` (size 64, `UINT`,
> **no `vpiParent`**) … **Every other** index goes through `emitExpr`.

The code gate:

```cpp
if (!idx74.empty() &&
    idx74.find_first_not_of("0123456789") == std::string::npos) { /* hand-built, UNPARENTED */ }
else { ... emitExpr ...; ((UHDM::any*)ix74)->VpiParent(hp); }   // <- ALWAYS parents
```

The test is on the **raw source text**, so it recognises a bare decimal and
nothing else. Golden's discriminator is the **result kind**. Measured on
`v74_edge2.sv` (mine), both binaries:

| cell | written | golden index | SHIPPED patch | re-cut |
|---|---|---|---|---|
| `x_based` | `sq[4'd2]` | `constant` size 4 DEC:2 constType 1, **no parent** | same **but `vpiParent -> hier_path`** | **= golden, byte for byte** |
| `x_hexlit` | `sq['h2]` | `constant` size -1 HEX:2 constType 5, **no parent** | same **+ `vpiParent`** | **= golden, byte for byte** |
| `x_trailsp` | `sq[2 ]` | `constant` size 64 UINT:2, **no parent** | same **+ `vpiParent`** | parent removed (fullname residue stays, R3) |
| `x_plainlit` | `sq[3]` | hand-built arm | = golden | = golden |
| `k_expr`, `x_ternary` | `sq[j + 1]`, `sq[i ? 0 : 1]` | `operation`, **parented at the `hier_path`** | = golden | = golden |
| `k_param`, `k_loopvar` | `sq[P]`, `sq[i]` | `ref_obj`, **parented at the `hier_path`** | = golden | = golden |

So golden's rule is: **the index is parented at the `hier_path` for every kind
EXCEPT a `constant`, which is unparented.** The shipped code implements that
only for indices spelled in bare decimal.

**Corpus reachability: ZERO.** I scanned all four moving databases for the
defective shape (a `bit_select` whose `vpiIndex` is a `constant` carrying a
`vpiParent -> hier_path`) and found **0** in
`default/{SimpleUVM,Scoreboard,BuildUVMPkg,SeqDriver}`. It breaks no gate; it
would have shipped as a latent defect against the pass's own prose. This is the
same class as r10uvm73's `VpiSize(64)` finding.

**The fix** (3 semantic lines, `src/ExprEmit.cpp`, inside the same branch):

```cpp
((UHDM::any*)ix74)->VpiParent(
    ix74->UhdmType() == UHDM::uhdmconstant ? nullptr : (UHDM::BaseClass*)hp);
```

Both idioms (`UhdmType() == UHDM::uhdmconstant`, `VpiParent(nullptr)`) are
already used elsewhere in this codebase. It touches **only the index object's
parent field**, so it cannot disturb an operation's operands. The alternative —
`suppressConstParent` around the `emitExpr` call, as `deepRecvCall11` does at
line ~10331 — was rejected because the explicit `VpiParent(hp)` line would
re-add the parent anyway and the flag reaches operand constants too.

**Command:**
`SLANG_UHDM=… ct74arm.sh v74_edge2.sv` then `ct74cells.sh <wd> "sq[4'd2]" "sq['h2]" 'sq[2 ]'`.

---

### F3 — `ct74predict.py`'s docstring states an invariant its own run refutes

The script says it is **"EXACT, NOT HEURISTIC"**, that after the patch **"NO
SUCH OBJECT EXISTS"**, and that a database moves **"IF AND ONLY IF"** it prints
one. Run the same predicate on the **PATCHED** corpus:

```bash
python3 ct74predict.py /tmp/v74s/wd_sl_p --jobs 3
# PREDICT_MOVE default/Rggen-50ccbd70/slang.uhdm  prints=24
# ---- PREDICTION: 1 databases / 953 CAN move, 24 flagged PRINTS
```

The class declared extinct survives, 24 prints of one object:
`ref_obj (register_if[6+7*i+6]) @356:42-62` — an interface-array step from a
DIFFERENT builder. The README's RF-4 gets this right in prose ("an upper bound
on reachability"); **the instrument's own text was never corrected**, and this
campaign's standing law is STATED == CODE *including in the notes* — the rule
the implementer himself applied twice this pass (the stale `Expect 7`, the
mislabelled `c_with`). **Docstring corrected in the re-cut**; the predicate is
unchanged, so `8 databases / 902 prints / DUMP_FAIL=0` on the pristine corpus
still reproduces exactly.

---

### F4 — "head byte-identical" is imprecise on BuildUVMPkg and false on SeqDriver

| row | raw `diff` sides | id-stripped diff | reading |
|---|---|---|---|
| `BuildUVMPkg` default/testflags | 8 | **0** | **id renumbering only** — semantically identical, but not "byte-identical" |
| `SeqDriver` default/testflags | 923 602 | **1 790** | head OBJECT line identical (`LHS: <null>` / `RHS: package uvm_pkg … id:6040`), printed SUBTREE is not |

SeqDriver is exactly what the standing law predicts — *vector-form `<null>`
prints the CONTAINER* — and the README's own SeqDriver note explains it. The
BuildUVMPkg row does not, and there "byte-identical" is simply the wrong word
for "differs in eight `id:` fields". The 1 790 id-stripped SeqDriver lines are
all in the right direction (`ref_obj (cbq[i]) 426:91-97` →
`bit_select (cbq[i]) 426:91-94` + index).

**Command:** `diff <(sed -E 's/id:[0-9]+/id:N/g' A) <(sed -E 's/id:[0-9]+/id:N/g' B)`.

---

### F5 — convention (b) is a TEXT transcription; golden's `vpiFullName` is a DECOMPILE

The law says `vpiFullName` = *the cumulative dotted **written** path*. That
coincides with golden on the whole corpus population, and diverges on four
measured cells beyond the admitted R1:

| written | golden `vpiFullName` | ours (both patches) |
|---|---|---|
| `sq[p4::PK]`, `sq[PK]` | `sq[2]` (folded) | `sq[p4::PK]`, `sq[PK]` — README R1 |
| `sq[fidx(i)]` | **`sq[]`** — brackets EMPTIED | `sq[fidx(i)]` |
| `sq[int'(i)]` | **`sq[]`** | `sq[int'(i)]` |
| `sq[ 2 ]`, `sq[2 ]` | `sq[2]` (whitespace normalised) | `sq[ 2 ]`, `sq[2 ]` |
| `sq[ih.k]` (helper REFUSES) | `sq[]` with a `hier_path` index | two garbage `ref_obj`s `sq[ih` / `k]` (pre-existing) |

Golden is decompiling the **bound index expression** and emitting empty
brackets for the kinds it will not inline. **None of these is a regression** —
pristine is worse in every one, and on `sq[fidx(i)]` / `sq[int'(i)]` the patch
gets kind, span and index-kind exactly right and only the fullname wrong. But
the law as stated is over-broad, and the next pass in this family should be
written against the decompile, not against the text. Ranked **R3**.

---

### F6 — R2 is not "no measured cell exists": the cell exists, and golden's answer is now known

The README fences the `with`-clause form out with `!withExpr9` and records R2 as
*"no measured cell exists"*. `v74_edge.sv` line 73,
`r = mq[i].iq.sum() with (item);`:

```
GOLDEN  \_bit_select: (mq[i]), line:73:11, endln:73:13
          |vpiName:mq  |vpiIndex: \_ref_obj: (…::w::i) 73:14-15, vpiParent -> hier_path
        \_ref_obj: (work@v74_edge::user::w::iq)     <- the PLAIN element IS scoped
OURS    \_ref_obj: (work@v74_edge::user::w::mq[i]), line:73:11, endln:73:16   (both binaries)
```

Golden wants **this exact law** under `with` too, with one extra rule: the
`bit_select`'s fullname is **UNSCOPED** (`mq[i]`) while the plain elements take
the with-regime's scoped fullname. The fence is the right call — the extra rule
was unmodelled — but R2 must be restated from *"no cell exists"* to *"the cell
exists, golden's shape is known, one extra fullname rule to transcribe."*
Ranked **R2**.

---

### F7 — the census and the cells table cannot see convention (c); when you look, the pass is right and a 189-cell neighbour is wrong

`ct74cen.py` records only *whether* a `vpiIndex` exists; `ct74cells.sh` prints
only its KIND. Neither can see the index's **PARENT**, which is convention (c)
and the whole of F2. I wrote `v74idxparent.py` (same key, so the tables join)
and ran it on SimpleUVM/default:

| | pristine | patched |
|---|---|---|
| agreeing `('ref_obj','hier_path')` | 94 | **141** (+47) |
| agreeing `('constant','NONE')` | 1 | **9** (+8) |
| **disagreeing** | **189** | **189** — IDENTICAL |

**Every one of the 55 cells this law converts lands with the correct index
parent** (+47 and +8 are exactly the 47 disagreeing and 8 middle-step keys the
census reports). That is convention (c) proven, which no shipped instrument did.

The same run exposes a **189-cell residue that is four times the size of the
population this pass fixed** (189 vs 47), unchanged before and after:

```
184  LHS ('ref_obj','hier_path')   RHS ('ref_obj','bit_select')
  3  LHS ('constant','NONE')       RHS ('constant','bit_select')
  2  LHS ('operation','hier_path') RHS ('operation','bit_select')
   e.g. fields[k] @100:16, m_tbl[i] @107:14, m_default_sequences[phase] @115:68
```

These are ordinary READS (`emitMixedHierPath`), where we parent the index at
the `bit_select` and golden parents it at the `hier_path` — **the same
convention (c), one builder over**. Ranked **R-TOP**: it is the largest fully
decoded residue this verification found.

---

### F8 — an instrument trap I hit myself, recorded so the next verifier does not

My first boundary comparison reported **all 24 neighbouring arms CHANGED**. They
had not: `uhdm-dump` prints the absolute source path in every `file:` and
`vpiRefFile:` field, and my two workdirs were `…_pris` and `…_fin`, so the
driver was measuring **its own scaffolding**. Normalising the workdir path
turned 24 CHANGED into **24 IDENTICAL**. `sed 1d` removes the database path on
line 1 and nothing else. A driver that reads its own directory names must never
read as red, exactly as one that matches nothing must never read as green.

---

## 2. EVERY NUMBER, REPRODUCED — THE FIVE GATES ON BINARIES I BUILT

### Gate 1 — BUILD

Both trees configured and built at absolute paths, `-j 2`, link line reached
before any measurement, `error:` count 0, md5s asserted separately and 32-hex,
both bases printed AND grep-checked. **Both implementer md5s reproduced bit for
bit** (§0). Pristine tree carries no source modification.

### Gate 2 — GOLDENS

| binary | PASS | FAIL |
|---|---|---|
| shipped patch | **23** | **0** |
| re-cut | **23** | **0** |
| `SLANG_UHDM=/bin/false` | **0** | **23** |

The negative control proves the harness reads the binary under test.
`SLANG_UHDM` exported explicitly in every run.

### Gate 3 — uhdm2rtlil (`--jobs 2`)

I ran `--mode both` (a **superset** of the committed testflags-only baseline).

| | shipped | re-cut | baseline |
|---|---|---|---|
| CMP_EQUAL / SLANG_REJECT / SURELOG_FAIL (each mode) | 679 / 50 / 2 | 679 / 50 / 2 | 679 / 50 / 2 |
| dump match / differ / blank (testflags) | 496 / 183 / 52 | 496 / 183 / 52 | 496 / 183 / 52 |
| `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` | **0 differing ROWS** over 731 | **0** | — |

Status **and** dump histograms identical baseline → fresh, both binaries.

### Gate 4 — surelog, both modes (`--jobs 2`)

| mode | CMP_EQUAL | CMP_NOTEQUAL | SURELOG_FAIL | DEFERRED |
|---|---|---|---|---|
| default (shipped, re-cut, **and pristine**) | **469** | **11** | **25** | **5** |
| testflags (shipped, re-cut, **and pristine**) | **465** | **8** | **23** | **5** |

`ct8rows.sh` vs `results/golden_surelog.csv`: **0 differing ROWS over 1588**,
both binaries. Per-mode status and dump histograms identical.
(The `testflags` tail — `NO_DATABASE 3, UNTRANSLATABLE 2, TIMEOUT 1, NO_UHDM 1`
— is present in the committed baseline and in the PRISTINE run too, so it is
background, not this pass.)

### Gate 5 — BYTE VERIFIER, both corpora, both modes, vs my own pristine build

| corpus | paths | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil (both modes) | **1358** | **0** | 1357 / 1358 | **1** |
| surelog (both modes) | 953 | **7** | 952 / 953 | **8** = 7 + 1 |

`PATH_SETS_IDENTICAL` on all four comparisons. Identical for the re-cut. The
seven movers are exactly the seven named. **Census prediction ran FIRST on the
pristine artifacts**: `8 databases / 953 CAN move, 902 flagged PRINTS,
DUMP_FAIL=0` — reproduced exactly; 7 moved; the over-fire is `default/Rggen`
(§F3).

### Movers, per-shape by MULTISET — every figure reproduced

| database | REMOVED | ADDED | size delta |
|---|---|---|---|
| default/SimpleUVM | 196 | 970 | **+6936** |
| testflags/SimpleUVM | 196 | 970 | **+6950** |
| default/Scoreboard | 196 | 970 | **+6911** |
| default+testflags/BuildUVMPkg | 216 | 1054 | **+7585** |
| default/SeqDriver | 368 | 1956 | **+13569** |
| testflags/SeqDriver | 368 | 1956 | **+13580** |

All identical for the re-cut. **Every size delta nonzero ⇒ every mover real**
(a zero delta would have proven nothing). The removed shapes are exactly the
flat steps (`|vpiName:args[i]` ×20, `m_override_info[i]` ×18, `queue[i]` ×16,
`split_val[2]` ×12, …, `arb_sequence_q[i]` ×4) and the added shapes are the
`bit_select`s, their index children and the re-prints — no unexpected class.

### The census — reproduced key for key

| | pristine | patched | re-cut |
|---|---|---|---|
| golden / ours indexed `hier_path` steps | 400 / 414 | **400 / 414** | 400 / 414 |
| shared | 332 | **340** | 340 |
| **DISAGREEING** | **47** | **0** | **0** |
| LHS-only / RHS-only | 68 / 82 | 60 / 74 | 60 / 74 |

The span arithmetic reproduces too: 45 pairs at `+3`, one at `+6`
(`endcol 45 → 51`, `m_streams[name]`), one at `+7` (`endcol 54 → 61`,
`m_type_overrides[index]`) — `len("[" + index + "]")` exactly, over the whole
population.

### The heads — reproduced, and the old head verified GONE

| row | pristine | shipped | re-cut |
|---|---|---|---|
| SimpleUVM default | 42 | **17** | **17** |
| SimpleUVM testflags | 42 | **17** | **17** |
| Scoreboard default | 42 | **26** | **26** |
| BuildUVMPkg both | 94 | 94 | 94 |
| SeqDriver both | 1416141 | 1417051 | 1417051 |

The pristine head is character-for-character the brief's target
(`bit_select (arb_sequence_q[i]) 554:32-554:46`, `vpiName:arb_sequence_q`,
`vpiIndex -> ref_obj i 554:47-48` parented at the `hier_path`, `vpiActual ->
int_var @552:27`, RHS `ref_obj … 554:32-554:49`). It is **gone**. The new heads
are the README's R4 verbatim (`logic_net (work@top.item) @664:28` with RHS
`<null>`; `ref_obj (…grant_queued_locks::status) @664:87` vs our
`method_func_call`). All five head `.cmp` files are **byte-identical between the
shipped patch and the re-cut**.

### Canaries — reproduced

| check | result |
|---|---|
| `canaries.sh` vs surelog baseline | ok=52 changed=**0** absent=0 unknown-names=8 |
| `canaries.sh` vs u2r baseline | ok=9 changed=**0** absent=0 unknown-names=25 |
| `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` | ok=58 changed=**0** — PASS |
| `ctcan2.sh` u2r `EXPECT_UNKNOWN=6` | ok=1 changed=**0** — PASS |
| `canaudit.sh` | audited=**31** UNCOVERED=**0** FENCE-BREACH=**0** |

BY NAME, row text compared against the committed baselines:
`indexed_partsel_array,testflags,CMP_EQUAL,,,match` ✓ ·
`hier_path,testflags,CMP_EQUAL,,,differ` ✓ ·
`InterfaceModPort,{default,testflags},CMP_EQUAL,,,differ` ✓ ·
`BlackParrotComplex,{default,testflags},CMP_EQUAL,,,differ` ✓. The corrected
`Expect 8 / 25` note matches the printed counts. `UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam` dispatched by **no** driver.

### The one re-cut-vs-shipped byte difference, run down rather than summarised

`byteverify.sh` re-cut vs shipped: **1 mover, `default/Scoreboard`** (u2r: 0).
Per-shape by multiset: **`REMOVED=0 ADDED=0`, size delta `0`** — the noise
floor, which by the standing MOVER RULE proves nothing. Positionally it is a
**46-line block MOVE** of `|vpiTaskFunc:` entries within one vector, identical
content, identical line count (1 096 230 both). It is **deterministic per
binary** (shipped → `584daff9…` on both a full sweep and a filtered rerun;
re-cut → `70f16e80…` on both), so it is code-layout-sensitive container
ordering, not run-to-run noise. It cannot be F2's doing: the F2 shape has
**0 occurrences design-wide** in all four moving databases. Every downstream
measurement is unaffected — Scoreboard's CSV row, its `uhdm-cmp` head (26
lines, **byte-identical** to the shipped patch's) and its mover per-shape table
are all identical.

---

## 3. WHAT I COULD NOT BREAK — NINE EMPTY PRODUCT CELLS POPULATED

`v74_edge.sv` and `v74_edge2.sv` (mine) fill the product the four shipped arms
left empty: index KIND × step POSITION, the refusal paths, and the contexts.
Both binaries, `ct74cells.sh`:

| cell | written | pristine | **shipped / re-cut** |
|---|---|---|---|
| `p_litmid` | `m.sq[2]` — literal on a MIDDLE step | ✗ `ref_obj` | **=golden** |
| `p_cpdmid` | `m.sq[j + 1]` — compound on a MIDDLE step | ✗ | **=golden** |
| `p_litboth` | `mq[0].sq[1]` — literal base AND literal middle | ✗ | **=golden** |
| `p_last` | `m.sq[i]` | ✗ | **=golden** |
| `x_based` | `sq[4'd2]` | ✗ | shipped: parent over-fire → **re-cut =golden** |
| `x_hexlit` | `sq['h2]` | ✗ | shipped: parent over-fire → **re-cut =golden** |
| `x_ternary` | `sq[i ? 0 : 1]` | ✗ | **=golden** |
| `p_usermeth_idx` | `mq[i].lq[j].getl()` — USER method, `§ deepRecvCall11` | =golden | **unchanged** |
| `p_deepmethod` | `mq[i].l.s.len()` | ✗ | **=golden** |

**The refusal rule holds where it should.** `qq[i][j]` (multi-dimensional),
`sq[ih.k]` (dot inside the index) and `sq[fidx(i)]`-style paths whose text and
tree disagree all leave the pre-existing `ref_obj` untouched, byte for byte.
I could not construct a case where `comps.size() == dots.size()` while a dot
sits inside an index: every such dot adds to `dots` and not to `comps`, so the
size check refuses first — the refusal is structural, not incidental.

**Two cells where the patch changes an unmeasured shape and golden does not
endorse the change** (neither is a regression; pristine is wrong in both):

* `this.sq[i].len()` — the helper accepts and emits
  `bit_select (this.sq[i])` name `sq` span 26:16-18, where golden emits a plain
  `ref_obj (sq)` 26:16-18 with **no index at all** (Surelog collapses the
  `this.`). Pristine had `ref_obj (sq[i])` 26:16-21. The patch trades a wrong
  name+span for a wrong kind+fullname. **0 `this.`-prefixed `bit_select`s exist
  in SimpleUVM on either side**, so it is unreached. Ranked **R4**.
* A MACRO-written call (`` `CALLLEN(sq, i) ``) emits **nothing at all** on our
  side — the assignment has no RHS — in **both** binaries, because `recvText`
  is empty for a macro-expanded range and the whole builder is skipped. Golden
  emits the full `hier_path` + `bit_select`. Pre-existing, untouched; it is part
  of what R5's LHS-only keys are made of.

**Boundary arms: 32 arms across 6 neighbouring passes, our-side dumps
BYTE-IDENTICAL pristine vs patched** (after normalising the workdir path, §F8):
`r10svs2repro` s1–s7 + w1/w2/w4 (10 — the parens-less law shares this exact
builder; its 4 PASS_CMP stay PASS and its 3 CMP_FAIL keep the identical head
depth 68 / 26 / 15), `r10buvm1repro` a1–a5 + v1/v3/v4 (8, the `::` receiver
chains), `r10uvm73repro` a1/a3/a4/v5 (4), `r10uvm72repro` a1/a2/v2 (3),
`r10uvm71repro` a1/a3 (2), `r10earl40repro` a1/bnd_a1_chain/v40_overfire (3),
`r10earl41repro` a1/v41v_overfire (2). **0 changed.**

**The four shipped arms reproduce cell for cell**: b1 `agree=0 → 7`,
b2 `0 → 4` (+3 UNKNOWN-CELL, our pristine-only texts that correctly vanish),
b3 `0 → 2`, b4 `0 → 3` with the 3 R1/fold cells still disagreeing. b1/b2 go
`CMP_FAIL(38) → PASS_CMP(0)`; b3 (330) and b4 (70) keep byte-identical
pre-existing heads. Two reconciliations of counting, not of measurement: the
README's "b4 5 cells, 3/5" is 3 AGREE / 3 DISAGREE over **6 cell TEXTS** (golden
prints `sq[2]` for two source lines that we print as `sq[p4::PK]` / `sq[PK]`),
and b1's seven cells include line 33's `sq[i]` merged into line 32's by text.

---

## 4. RANKED RESIDUES

**R-TOP — 189 index-parent cells in the ORDINARY-READ builder (F7).** The same
convention (c) this pass transcribes correctly, violated in
`emitMixedHierPath`: our index parents at the `bit_select`, golden's at the
`hier_path`. 189 cells in SimpleUVM/default alone — **four times** the 47 this
pass fixed — fully decoded, one field wide, identical before and after. It is
sitting under the new heads.

**R1 — the statement-form second site (F1).** 6 SimpleUVM/default cells,
`method_func_call` → `Prefix`: golden gives the base name with a base-only span
and **no index**; we give the whole written text, and where the index contains a
dot we give a truncated garbage name (`m_streams[stream`). Needs its own arm and
census — golden's shape there is a `ref_obj`, **not** a `bit_select`, so it is a
neighbouring law and not an extension of this one.

**R2 — `with` clause over an INDEXED receiver (F6).** The cell exists and
golden's shape is known: the same `bit_select`, with the fullname **UNSCOPED**
while every plain element keeps the with-regime's scoped fullname. One extra
rule to transcribe; currently fenced out by `!withExpr9`.

**R3 — `vpiFullName` is a DECOMPILE, not the written text (F5).** `sq[]` for a
call or cast index, whitespace normalised, package-localparam folded
(the README's R1). Four arm cells; **0 corpus rows**. The whole family should be
re-based on the decompile in one pass rather than patched field by field.

**R4 — `this.`-prefixed indexed receiver.** Golden drops the index entirely;
we now emit a `bit_select` with a `this.`-prefixed fullname. Unreached in the
corpus (0 cells in SimpleUVM). Needs a cell before any code touches it.

**R5 — macro-position residue: 60 LHS-only / 74 RHS-only census keys.** Both
sides now emit `bit_select`; the keys fail to join on `(line, col)`. Part of it
is now explained: a builtin call written **entirely inside a macro** emits
nothing on our side at all (§3), because `recvText` is empty for a macro-expanded
range. Location-attribution family, unchanged by this pass (the 400/414 gap is
constant before and after).

**R6 — the new heads.** SimpleUVM (both modes): `LHS logic_net (work@top.item)
@664:28` under `module_inst work@top`, RHS `<null>` — a net golden emits and we
do not. Scoreboard default: golden `ref_obj (…::grant_queued_locks::status)
@664:87` vs our `method_func_call` inside `hier_path (item.process_id.status)` —
a parens-less-call shape in `§ parensLessCallIsPathRefObj`'s family, pre-existing
and merely newly exposed.

**R7 — b3/b4 arm heads.** Byte-identical before and after; the arms' own
background (`q.sum() with (item)` and the fold), not this law's business.

---

## 5. THE DELIVERABLE

`/tmp/r10uvm74.verified.patch` — the shipped patch **plus**:

1. `src/ExprEmit.cpp`: the F2 parent rule moved from the index's **spelling** to
   its **result kind** (+21 / −1 against the shipped patch, all inside the same
   `else` branch).
2. `tools/probe/r10uvm74repro/ct74predict.py`: the F3 docstring corrected from
   an IFF to an upper bound, naming the measured counterexample. Predicate
   unchanged.
3. `tools/probe/r10uvm74repro/v74_edge.sv`, `v74_edge2.sv`, `v74idxparent.py`:
   the verifier's arms and the convention-(c) instrument.
4. This file.

Re-verified end to end on `/tmp/wt_v74ref` (md5 `d38affdad5f4b2a93cd74426cd103fa1`):
goldens 23/0, u2r 679/50/2 with 0 differing rows, surelog 469/11 + 465/8 with 0
differing rows, byte verifier 0/1358 and 7/953 with both negative controls,
census 47 → 0, all three heads cleared to 17/17/26, all canaries at baseline.

**Sweep workdirs deleted.** Worktrees `/tmp/wt_v74pris`, `/tmp/wt_v74p` and
`/tmp/wt_v74ref` retained with their binaries.
