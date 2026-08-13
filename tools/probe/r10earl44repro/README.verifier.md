# r10earl44 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PASS.**

Every number in the implementer's report reproduced **exactly**, from an
independent worktree, an independent build, and independent instrument runs.
The two binaries came out **bit-identical** to the implementer's
(`aa73bb11558ed2222d6aa741071005f1` patched, `86dca24264416ef39ce3932bc9a2b0e0`
pristine), which makes every downstream measurement a genuine re-derivation
rather than a re-reading.

The verifier's own contribution is **§ V1**: the two delivered probes
**confound** the law's discriminator with parameter shape, so neither of them
can actually distinguish the stated law from a simpler wrong one. I built the
de-confounding probe. **The stated law wins, on cells the delivered grid never
contained.**

---

## 0. WHAT I DID, AND ON WHAT

| | |
|---|---|
| base | **`acc7e56`** (fresh worktrees, `git worktree add --detach`), NOT the implementer's trees |
| patched tree | `/tmp/wt_r10earl44v` — `git apply /tmp/r10earl44.patch`, `git status` = `M src/ModuleEmit.cpp` + `?? tools/probe/r10earl44repro/` and nothing else |
| pristine tree | `/tmp/wt_r10earl44vpris` — untouched `acc7e56` |
| patch md5 | `6c0a920b987099efc7480350cae773e5` — matches the delivered value |

```sh
git worktree add --detach /tmp/wt_r10earl44v      acc7e56
git worktree add --detach /tmp/wt_r10earl44vpris  acc7e56
cd /tmp/wt_r10earl44v && git apply --check /tmp/r10earl44.patch && git apply /tmp/r10earl44.patch
```

`git apply --check` is clean on `acc7e56` **and also on the current branch head
`7d7c29f`** — checked in a third throwaway worktree, since `auto5h` has moved
five commits past the brief's base while this pass was in flight. That is a
landing convenience, not a gate.

---

## 1. THE FIVE GATES, RUN INDEPENDENTLY

### GATE 1 — BUILD

```sh
~/.local/bin/cmake -B /tmp/wt_r10earl44v/build -S /tmp/wt_r10earl44v \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local
~/.local/bin/cmake --build /tmp/wt_r10earl44v/build -j 2      # ABSOLUTE path, -j 2
```

| | patched | pristine |
|---|---|---|
| lines matching `error:` | **0** | **0** |
| link line | `[100%] Linking CXX executable slang-uhdm` | same |
| **md5, asserted separately** | **`aa73bb11558ed2222d6aa741071005f1`** | **`86dca24264416ef39ce3932bc9a2b0e0`** |
| base, printed + grep-checked | `acc7e56` | `acc7e56` |

**Both md5s are bit-identical to the implementer's**, produced in different
directories on a different run. Re-asserted unchanged after every later gate.
This is a stronger reproducibility result than the gate asks for: it means the
edit, not the build environment, is the entire delta.

### GATE 2 — GOLDENS

```sh
SLANG_UHDM=/tmp/wt_r10earl44v/build/slang-uhdm ./tests/check_goldens.sh
```

| binary | PASS | FAIL |
|---|---|---|
| patched | **23** | **0** |
| pristine | 23 | 0 |
| `/bin/false` (negative control) | **0** | **23** |

`GOLDEN_DEFER` left UNSET throughout.

### GATE 3 — uhdm2rtlil

```sh
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus uhdm2rtlil \
    --mode testflags --out <own.csv> --workdir <own.wd> --jobs 2
```
`SLANG_UHDM` **exported** for every sweep (`verify_golden.py` silently defaults
it), and the binary each sweep *actually invoked* was read back out of the
sweep's own `cmds.txt`, not assumed — it matched in all 8 sweeps.

| mode | status | dump column |
|---|---|---|
| **testflags** | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** | **496 match / 183 differ / 52 blank** |
| default | 679 / 50 / 2 | 492 match / 187 differ / 52 blank |

Both figures identical on patched and pristine; `diff` of the sorted pat/pris
CSVs **empty in BOTH modes**.

`ct8rows.sh results/gate_uhdm2rtlil.csv <fresh>`:
```
baseline: 732 lines = 731 ROWS      fresh: 732 lines = 731 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```
Both histograms unchanged. **0 rows.**

### GATE 4 — surelog corpus, BOTH modes

Eight sweeps total, **strictly sequential**, `--jobs 2`, one `verify_golden.py`
per (corpus, mode, binary), so the documented SURELOG_FAIL detail-row race under
concurrent sweeps cannot fire.

| mode | CMP_EQUAL | CMP_NOTEQUAL | SURELOG_FAIL | DEFERRED | total |
|---|---|---|---|---|---|
| **default** | **469** | **11** | **25** | **5** | 794 |
| **testflags** | **465** | **8** | **23** | **5** | 794 |

Identical on both binaries; sorted pat-vs-pris CSV `diff` **empty** in both
modes. `ct8rows.sh` vs the committed `results/golden_surelog.csv`: **0
differing ROWS**, both per-mode STATUS and DUMP histograms unchanged.

The target's own rows are byte-identical to the committed baseline — **its ROW
does not move, its BYTES do**:
```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
```

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs PRISTINE

```sh
SELFCHECK=1 SELFCHECK1=1 ./byteverify44.sh <pat_workdir> <pris_workdir>
```

| corpus | databases | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil default | 679 | **0** | 678/679 | 1 |
| uhdm2rtlil testflags | 679 | **0** | 678/679 | 1 |
| **surelog default** | **480** | **1** — `Earlgrey_0_1` | 479/480 | **2** |
| surelog testflags | 473 | **0** | 472/473 | 1 |
| **TOTAL** | **2311** | **1** | | |

*(I ran each corpus as two per-mode comparisons rather than one merged root;
coverage is identical — 2311 databases, the implementer's own total — and the
"every file vs one fixed file" control accordingly reads n−1 per mode. Every
`SELFCHECK1` equals `1 + the real movers in that mode`, exactly as that
control's message says to expect.)*

**MOVER RULE APPLIED PER MOVER.**

* **`Earlgrey_0_1/default`: patched 49940578 B, pristine 49941384 B → −806 B.
  NONZERO, therefore REAL**, and the per-shape multiset (§ 2) accounts for it
  object-for-object. The mover's md5 prefixes came out
  `patched=115906084178 pristine=d3dcad27f75b` — **digit-for-digit the
  implementer's values**.
* **`Scoreboard/default` DID NOT MOVE AT ALL IN MY SWEEP.** See finding **V6**:
  this is independent confirmation of the implementer's nondeterminism
  arbitration, obtained by the strongest possible route — the flake simply did
  not recur.

**ONE REAL MOVER IN 2311 DATABASES, and it is the target.**

**PROTECTED canaries, DATABASES compared BY NAME** (their rows are
`CMP_EQUAL`+`differ`, i.e. blind to byte changes):

```
InterfaceModPort   BlackParrotComplex   YosysOldOr   SVSwitch    -> BYTE-IDENTICAL, both modes
gen_test9  genvar_loop_decl_2  genvar_loop_decl_3  paramod_genscope_child
genscope_cells  gen_test4  indexed_partsel_array  EnumConcat     -> ALL 8 BYTE-IDENTICAL
```

**CANARY SCRIPTS**
```
canaries.sh  u2r : rows ok=8  changed=0 absent=0 unknown-names=25
canaries.sh  SL  : rows ok=52 changed=0 absent=0 unknown-names=7
ctcan2.sh u2r EXPECT_UNKNOWN=6 : ok=1  changed=0 absent=0 unknown-patterns=6  PASS (exit 0)
ctcan2.sh SL  EXPECT_UNKNOWN=1 : ok=58 changed=0 absent=0 unknown-patterns=1  PASS (exit 0)
canaudit.sh  : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
```
Both `ctcan2` runs take the COMMITTED baseline as their FIRST argument and are
mode-matched. **Guard exercised on BOTH corpora**: re-running each with
`EXPECT_UNKNOWN=0` exits **6**.

---

## 2. THE TARGET AND THE MOVERS — REPRODUCED NUMBER FOR NUMBER

### The head

```sh
SLANG_UHDM=<bin> ./earl44.sh <outdir>
```

| | pristine | patched |
|---|---|---|
| `cmp.log` | **30 lines** | **186 lines** |
| head object | `ref_obj (pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT)` @628:26 | `operation` @`prim_keccak.sv:52:5` |
| `o.dump` lines | **4655204** | **4655214** (+10) |
| database size | 49941384 | 49940578 (**−806**) |

* The pristine `cmp.log` is **byte-identical to the committed
  `tools/probe/r10earl43repro/r6_nexthead43.cmp`** — the base is the one the
  brief describes.
* The patched `cmp.log` is **byte-identical to the delivered
  `r6_nexthead44.cmp`**.
* **The head is CLEARED, not merely reordered**: `grep -c
  'LC_PINMUX_STRAP_REQ_DEFAULT' cmp.log` = **0** and `grep -c '628:26'` = **0**
  in the patched cmp.

### The census — all six pre-registered predictions land

`census44.py <golden.dump> <o.dump>`, run by me on both binaries:

| | PRISTINE | PATCHED | predicted |
|---|---|---|---|
| Q3 head signature `SPAN NAME(G-qualified) FULLNAME(G-none) ACTUAL(G-only)` | **10** | **0** (absent) | 0 |
| Q3 cells with ANY field divergence | **2661** | **2651** | 2651 |
| Q4 ours qualified high-conn actuals | **0** | **10**, in golden's own bucket `allModules / ref_obj / nofull / act` | 10 |
| Q2 `golden ref_obj -> ours ref_obj` | 17202 | 17202 (whole table byte-identical) | unchanged |
| `o.dump` lines | 4655204 | 4655214 | +10 |
| MULTISET DISTANCE | **308756** | **308686** (−70) | −70 |

`msdist.sh`: golden-only `238500 → 238460`, ours-only `70256 → 70226`.
**Every one of these is the implementer's number to the digit.** I took each
reading only after the producing process had *exited* — the race the
implementer documents (a `549515` reading off a half-written dump) is real and
I avoided it the same way.

### Per-shape multiset of the two OURS dumps, ADDED and REMOVED separately

```
ADDED   shapes=31 instances=40
REMOVED shapes=30 instances=30
NET=+10
```
`31 = 1 + 3×10`, `30 = 3×10`. I listed every shape: the ADDED set is exactly
ten `|vpiActual:` instances, ten `\_ref_obj: (pkg::NAME)` lines, ten
`|vpiName:pkg::NAME` lines and ten `\_parameter: (pkg::NAME)` lines; the REMOVED
set is exactly the ten instance-scoped `\_ref_obj:`/`|vpiFullName:`/`|vpiName:`
triples. **Ten objects, and nothing else, in a 4.65-million-line dump.**

### The grids

| grid | rows | non-MATCH pris → pat | flips | **regressions** |
|---|---|---|---|---|
| `a1_earl44` | **99** | **28 → 19** | 9 | **0** |
| `v44_overfire` | **28** | **11 → 8** | 3 | **0** |
| `a1_earl43` (grid43.py) | **61** | **5 → 4** | 1 (`u_c2`) | **0** |
| `v43_overfire` (grid43.py) | **18** | **3 → 2** | 1 (`u_e8`) | **0** |
| `v44x_deconf` (**mine**) | 20 | **13 → 6** | 7 | **0** |

The nine `a1_earl44` flips are exactly `u_q1 u_q6 u_q7 u_q8 u_q9 u_q17 u_ni1
u_ni2 u_deep`; the three `v44_overfire` flips are exactly `u_e0 u_e3 u_e5`. The
bare controls `u_b1 u_b2 u_b3 u_e1 u_e2 u_e4 u_e6` and the class cells
`u_e11 u_e12` do not appear in any verdict diff — **they did not move**.

**The § 43 boundary the brief demanded holds, and its two moving rows are
exactly the brief's named witnesses `u_c2` and `u_e8`** — § 43's own residue R1,
now golden-exact.

---

## 3. FINDINGS

### V1 — THE DELIVERED PROBES CONFOUND THE LAW'S DISCRIMINATOR WITH PARAMETER SHAPE. *(method gap; the law SURVIVES)*

This is the one thing the implementer's evidence did not establish.

The law says the split is **constness** — `pkgParamConst` (arm 1, fold to a bare
constant) vs `paramDefRhsIsOp` (arm 2, keep a qualified `ref_obj`). But in
**both** delivered probes:

* every cell that lands in **arm 1** is a **SCALAR** (`PK_LOGIC32`, `PK_INT`,
  `PK_UNTYPED`, `PK_PARAM16`, `PK_TDEF`, `PK_STR`, `PK_REAL`; `Q_PLAIN`);
* every cell that lands in **arm 2** is an **AGGREGATE** (`PK_STRUCT`,
  `PK_STRUCTP`, `PK_ARR`; `Q_STRUCT`, `Q_ARR`).

The two properties are perfectly correlated across all 127 grid rows, so
`a1_earl44` and `v44_overfire` are **equally consistent with a different, wrong
law** — "scalars fold, aggregates stay symbolic" — which would key on
`getType()`, not on the two maps. A grid that cannot separate the stated rule
from a plausible rival is not evidence for the stated rule.

**THE DE-CONFOUNDING EXPERIMENT** — `v44x_deconf.sv` (added by me), the two
cells that break the correlation in opposite directions:

```systemverilog
localparam logic [15:0] PK_CAT = {8'h aa, 8'h bb};   // SCALAR    + operation Rhs
localparam logic [15:0] PK_REP = {2{8'h cd}};        // SCALAR    + operation Rhs
localparam sx_t         PK_STC = 16'h aabb;          // AGGREGATE + constant  Rhs
```

```sh
SLANG_UHDM=<bin> ./arm44.sh v44x_deconf.sv <wd>
python3 grid44.py <wd>/g.dump <wd>/o.dump
```

**RESULT — the stated law is right and the shape rival is REFUTED TWICE:**

| cell | what it is | GOLDEN | law predicts | shape-rival predicts |
|---|---|---|---|---|
| `u_x1` | **SCALAR** `logic[15:0]`, concat Rhs | **qualified `ref_obj`** `x44::PK_CAT`, no full, act→`parameter`, **qualifier span** `65:20-65:25` | arm 2 ✔ | fold ✘ |
| `u_x2` | **SCALAR**, replication Rhs | same | arm 2 ✔ | fold ✘ |
| `u_x3` | **AGGREGATE** packed struct, constant Rhs | **BARE constant** `16'haabb`, **no parent, no ts** | arm 1 ✔ | ref survives ✘ |

All three are **MATCH** on the patched binary and **DIFFER** on pristine. The
law's predicate is genuinely `pkgParamConst` / `paramDefRhsIsOp`, it is *not* a
proxy for shape, and it now has cells that prove it. **This strengthens the
pass; it does not weaken it.** The gap was in the probe, not the code.

### V2 — THREE EMPTY PRODUCT CELLS FILLED; ALL THREE MATCH

The delivered grid leaves three product cells of the arm-2 axis genuinely
unmeasured. I filled them; all three land on golden.

1. **arm 2 × a formal that FORCES AN IMPLICIT CONVERSION** (`u_x4`, a 16-bit
   struct param into a `logic[31:0]` formal). This mattered because **§ 44's
   gate reads the RAW `expr` (`expr->kind == NamedValue`) while § 43's gate
   reads `stripImplicitConv(*expr)`** — and § 43's own comment says that reading
   only the bare `NamedValue` left four `a1_earl43` cells half-right. Every
   aggregate cell in `a1_earl44` is wired to an exactly-matching formal, so a
   conversion never wraps an arm-2 actual there and the asymmetry is untested.
   **Result: `u_x4` is MATCH on BOTH binaries.** The mechanism is the one the
   implementer already documented for the class cells `u_e11`/`u_e12`: when a
   conversion wraps, the DEF loop's `NamedValue` short-circuit is *not* taken
   and the connection routes to `emitExpr`, where § staticScopedRef12 already
   emits the qualified ref correctly. **The § 43/§ 44 asymmetry is therefore
   harmless, and now measured rather than assumed.**
2. **arm 2 × POSITIONAL** (`u_x5`). `a1_earl44`'s only positional cell `u_q16`
   is a scalar and its row reads "*no def-view port either side*" — it measured
   **nothing**. Mine does produce a def-view port on both sides: **MATCH**.
3. **arm 2 × a CONCAT Rhs rather than an assignment pattern** (`u_x6`) — every
   arm-2 cell in the delivered probes is an assignment pattern: **MATCH**.

`v44x_deconf` whole grid **20 rows, 13 → 6 non-MATCH, 7 flips, 0 regressions**,
and **ZERO `topModules` rows moved** — the implementer's R-4 ("the ELAB view was
never broken") holds on my new cells too. In particular `u_x6`'s elab cell,
which *looks* like an arm-2 leak into the elab view, is **byte-identical on both
binaries** — it is `emitExpr`'s pre-existing § staticScopedRef12 output, not a
leak.

### V3 — STATED GATE is a (safe) UNDER-DESCRIPTION of CODE GATE

The README's gate table gives arm 1 as `pkgParamConst.find(psym44) != end()`.
The code is:
```cpp
if (cit44 != pkgParamConst.end() && cit44->second) {
```
The extra `&& cit44->second` is not stated. It can only make the arm fire
*less*, and it is unreachable in practice (`pkgParamConst[&member]` is assigned
only under `rhs->UhdmType() == UHDM::uhdmconstant`, so the mapped value is never
null). **Not a defect** — recorded because "STATED GATE == CODE GATE" is a
standing law and this is the one character where they differ.

### V4 — GRATUITOUS NULL-CHECK ASYMMETRY BETWEEN THE TWO ARMS

Arm 1 null-checks its mapped value (`cit44->second`); arm 2 does not
(`poit44->second` is passed straight to `Actual_group`). Unreachable today —
`pkgParamObj[&member] = up` with `up = s.MakeParameter()` is never null — so
there is **no bug**, but the asymmetry is unmotivated and a future map change
would break the arms differently. One-word fix if anyone touches this block.

### V5 — LATENT: the arm-2 span builds a `SourceRange` across two locations with no same-buffer assertion

```cpp
setLoc(r44, SourceRange(expr->sourceRange.start(),
                        sn44.right->sourceRange().start()));
```
Nothing asserts the two `SourceLocation`s share a buffer. The campaign's own
`emitter-nondeterminism` memory records that `SourceLocation` comparisons
*across macro buffers* flip per run, so a macro-split scoped name
(`` `SOME_PKG::``P ``) could yield a malformed span. **Earlgrey population is
zero** — all ten cells landed byte-exact and byte-deterministically — so this is
latent only, and it is the *pre-existing* idiom of § staticScopedCall12 rather
than something this pass invented. Ranked last.

### V6 — THE `Scoreboard` "MOVER" DID NOT REPRODUCE. The arbitration was right.

The mover rule says a ZERO size delta proves nothing, so the implementer's
second mover needed arbitration, and I did not take theirs on trust. I got a
stronger answer than a re-arbitration:

**In my sweep `Scoreboard` is not a mover at all.** My surelog-default byte
comparison reports **`MOVERS: 1 / 480`** and names only `Earlgrey_0_1`. The
implementer's run flagged `Scoreboard` at an identical file size of 11122776 B;
mine produced byte-identical databases for it from the two binaries.

A difference that appears in one run of a pair of binaries and vanishes in
another run of the *same* pair is nondeterminism by definition. This is exactly
the documented emitter nondeterminism (`SourceLocation` compares across macro
buffers flip per run under parallel parse — and `Scoreboard` is a UVM test, the
`vpiTaskFunc`/`uvm_pkg` typedef-ordering family). **The implementer's
arbitration was correct, and the flake's non-recurrence is the cleanest
possible confirmation of it.**

Note the contrast that makes this sound rather than lucky: **`Earlgrey_0_1` is
byte-deterministic** — its mover md5s reproduced digit-for-digit across two
independent binaries and two independent sweeps.

### V7 — THE HEADLINE CORRECTION IS REAL (independently confirmed)

The pass's most interesting product is its self-correction: "golden has no
`vpiFullName`" must be spelled `VpiFullName(name)`, not "leave it unset". I
confirmed the mechanism in UHDM's own generated source rather than taking the
quotation:

`/home/heyfey/git-repos/UHDM/build/generated/src/ref_obj.cpp:43`
```cpp
std::string_view ref_obj::VpiFullName() const {
  if (!vpiFullName_) {
    const std::string fullName = ComputeFullName();
    if (!fullName.empty()) {
      const_cast<ref_obj*>(this)->VpiFullName(fullName);
    }
  }
```
It **manufactures and caches** a full name from the parent chain when the field
is unset. The correction is sound and generalises: any future "golden prints no
fullname on a `ref_obj`" cell needs the same idiom.

### V8 — PATCH HYGIENE: CLEAN

* Files touched: **`src/ModuleEmit.cpp` and `tools/probe/r10earl44repro/` only** —
  `grep '^diff --git' | grep -v <allowed>` returns nothing.
* `src/ModuleEmit.cpp`: **`127 insertions(+), 0 deletions(-)`** — verified by
  `git apply --numstat`. **Not one existing line modified**, no member added.
* Modes sane: 8 × `100755` (the `.sh` drivers), 6 × `100644`.
* `README.verifier.md` correctly **absent** from the delivered patch (the single
  textual hit is § 8's sentence saying so). This file is the verifier's.
* `results/*.csv` untouched; no `git stash`; `GOLDEN_DEFER` unset.

### V9 — LIVE-PASS BOUNDARIES: NO COLLISION

* **`r10sd4`** (the co-ordination the brief demanded): its worktree
  `/tmp/wt_r10sd4` currently shows `git diff --stat` = **`src/TaskFuncEmit.cpp |
  38 ++...`, one file** — it does **not** touch `ModuleEmit.cpp` at all.
  **The implementer's "no collision to report" is CORRECT, and I checked it
  against the live tree rather than accepting the claim.**
* **`r10uvm72`** works in `ExprEmit`/`TaskFuncEmit` — untouched here.
* **§ 43** — its own grids re-run on both binaries, above: **0 regressions**.
* **§ pkgWrittenQualSelBase41** — `u_q19` (`p44::PK_ARR[0]`) is a `bit_select`,
  the gate requires `NamedValue`, and the cell is unmoved on both binaries.
* **§ staticScopedRef12** — `u_e11`/`u_e12` unmoved; the gate requires the
  symbol's parent scope to be a **Package**.
* **The naming-context memory** is honoured: the law qualifies a name in ONE
  syntactic position, and every qualified probe cell has a bare twin that
  provably does not move with it.

### V10 — REFUTATION R-4 IS OVERSTATED, AND IT HIDES AN UNREPORTED RESIDUE WITH A **NONZERO** EARLGREY POPULATION

The implementer's R-4 says *"the ELAB view was, once again, never broken"*,
supported by the sentence *"every scoped cell's `topModules` row already MATCHED
golden on the pristine binary (`u_q1`, `u_q6`, `u_q10`, `u_q11`, `u_q12`,
`u_q13`, `u_q15`)"*.

**That list is all seven SCALAR cells. It omits every AGGREGATE cell — and the
aggregate cells' elab rows do NOT match, on either binary.**

```sh
grep -E '^(MATCH|DIFFER) +topModules' <a1_earl44 grid, both binaries>
```
`u_q7`, `u_q8`, `u_q9`, `u_deep`, `u_ni2` — the elab `p_i` row is **DIFFER on
pristine AND on patched**:

```
DIFFER  topModules  work@leafst44 (work@top44.u_q7)  (p_i)
    G: operation @44:42-44:63   <-- the PARAMETER's own Rhs, inside the package
    O: operation @104:25-104:39 <-- the written CONNECTION
```

My `v44x_deconf` probe reproduces it independently (`u_x5`, `u_x7`: golden
`@47:36-47:57`, ours at the connection), so it is a property of the shape, not
of one file.

**What is actually true — and what the boundary claim needs — is the weaker
statement: NO elab cell MOVED.** That I confirm completely: zero `topModules`
flips and zero `topModules` regressions in all five grids, and the design-wide
census shows no `topModules` cell moved. The pass is safe. But "never broken"
is not the same claim as "did not move", and the difference is a residue the
report does not carry.

**AND IT REACHES EARLGREY.** Filtering the census's 375-cell `SPAN` family for
the ten head instances finds **three** — and they are elab twins of the very
cells this pass just fixed in the DEF view:

```
work@clkmgr (work@top_earlgrey.u_clkmgr)  port (dft_i)
    G: operation @15:41-17:4      <-- CLK_DFT_DEFAULT's Rhs in clkmgr_pkg
    O: operation @746:14-746:41   <-- the connection in top_earlgrey.sv
work@clkmgr (work@top_earlgrey.u_clkmgr)  port (status_i)
work@pinmux (work@top_earlgrey.u_pinmux)  port (lc_pinmux_strap_i)
```

`lc_pinmux_strap_i` is **the head's own port**. So the ten cells this pass
repairs in `allModules` have a parallel, still-open span defect in
`topModules`, with an Earlgrey population of **3**.

**This outranks R1–R4 on the implementer's own criterion**: those are all
Earlgrey-population **0**, this is **3**, it is the direct elab twin of the law
just landed, and it already has seven probe cells (`u_q7 u_q8 u_q9 u_deep
u_ni2` + my `u_x5 u_x7`). I rank it **R1′** below.

---

## 4. RANKED RESIDUES (verifier's ranking)

I re-derived every "Earlgrey population" claim from **my own** patched census
rather than accepting it. **I have re-ranked: the implementer's R1–R4 all have
Earlgrey population ZERO, while the residue their R-4 conceals has population
THREE, so it goes first.**

* **R1′ (NEW, verifier) — the ELAB TWIN of § 44: golden spans the PARAMETER's
  own Rhs, we span the written CONNECTION.** Finding **V10**. Same ten port
  connections this pass just fixed in `allModules`, still wrong in
  `topModules` — including the head's own port `lc_pinmux_strap_i`.
  **Earlgrey population 3** (`u_clkmgr.dft_i`, `u_clkmgr.status_i`,
  `u_pinmux.lc_pinmux_strap_i`), inside the census's 375-cell `SPAN` family.
  Probe population 7 and already written: `a1_earl44` `u_q7 u_q8 u_q9 u_deep
  u_ni2`, `v44x_deconf` `u_x5 u_x7`. Pre-existing on both binaries; it did not
  move, so it is a residue and not a regression. **Highest value on the
  report's own criterion — it is the only one of these with a nonzero
  population, and the grid to measure it already exists.**
* **R1 — qualified NON-parameter conns** (pkg VARIABLE `u_q21`/`u_e9`, CLASS
  localparam `u_e13`): qualified name + qualifier span but **fullname KEPT** and
  actual → the package's `logic_var`. **Earlgrey pop 0 CONFIRMED** — census Q4
  shows golden's entire qualified high-conn population is 10 cells, all
  `nofull`+`act`, i.e. all parameters; there is no `full` bucket at all. The pkg-var
  span is wrong in the ELAB view too, so `isPkgQualifiedVarRef`'s `setLoc` is one
  site for both views. **Highest value: 3 cells, 1 probe, a span rule already
  implemented twice elsewhere.**
* **R2 — the ENUM value source**, two cells wide (enum-TYPED param `u_q12`/`u_e7`,
  enum CONSTANT `u_q13`/`u_e8`). Provably outside this gate: the enum-typed
  param's def Rhs is a `ref_obj` to the `enum_const` so it is in **neither** map,
  and an enum constant is not a `Parameter` symbol. **Earlgrey pop 0 CONFIRMED**
  — no `golden constant -> ours ref_obj` pairing exists in census Q2. New datum
  worth keeping: **the scoped fold wants a BARE constant where § 43's bare fold
  wants parent + ts** — one value source, two shapes.
* **R3 — scoped STRING/REAL folds take the value-substituted decompile**
  (`zz`, `1.500000`) not the def constant (`"zz"`, `1.5`). **Earlgrey pop 0
  CONFIRMED** — no `DECOMPILE` signature survives in census Q3.
* **R4 — qualified SELECT / MEMBER-ACCESS actuals keep a synthesized fullname**
  (`u_q19` `bit_select`, `u_q18` `hier_path`). Same one-line fix shape as V7.
* **R5 — the 10 `FULLNAME`-only ELAB cells**, now the largest exactly-characterised
  port-connection family. Verified from my census Q6: golden's `part_select`
  fullname doubles through instance AND port
  (`...gen_bufs[0].i_rd_buf.addr_i.addr_i`) where ours stops at the gen block
  (`...gen_bufs[0].addr_i`). 8 × `flash_phy_rd_buffers` + 2 × `prim_flash`.
* **R6 — the 1 `ACTUALKIND` cell**: `work@prim_arbiter_ppc` `data_i`, golden binds
  a `struct_net`, we bind an `array_net`. Verified verbatim in my census.
* **R7 — § 43's `u_e5`**: pkg `real` bare fold has `vpiSize:64`, golden `32`.
  Pre-existing on both binaries, invisible to `grid43.py`.
* **R8 — golden-only 238460 still dwarfs ours-only 70226.** The remaining
  308686 is overwhelmingly *things golden emits that we do not* (`TS(G-only)`
  alone is 2124 cells), not things we emit wrongly.
* **V4 / V5** (above) are code-hygiene residues, ranked below all of these.

---

## 5. NEXT HEAD

`r6_nexthead44.cmp` reproduced **byte-identically** from my own patched build:
186 lines, `prim_keccak.sv:52:5`, an assignment-pattern `operation` (op75).
Golden carries `vpiSize:32` we lack, and **re-parents its operand constants onto
the enclosing per-row operations** while ours parent onto the operation that
holds them. Two defects, different family, not a port connection.

---

## 6. FILES ADDED BY THE VERIFIER

| file | what it is |
|---|---|
| `README.verifier.md` | this report |
| `v44x_deconf.sv` | the **de-confounding probe** (§ V1) — the SCALAR-with-operation-Rhs and AGGREGATE-with-constant-Rhs cells that separate the stated law from the shape rival, plus the three empty product cells of § V2 |

Deliverable re-cut as **`/tmp/r10earl44.verified.patch`** (`src/ModuleEmit.cpp`
+127 and `tools/probe/r10earl44repro/` only, `git apply --check` clean on a
pristine `acc7e56`). Its md5 is stated in the verifier's return message rather
than here — a patch cannot contain its own hash. It is the implementer's patch
plus these two files: the
`src/ModuleEmit.cpp` hunk is **byte-identical** to the delivered one — asserted
by `diff` of the two patches' production hunks. **I found nothing in the
production code to correct.**

All verifier sweep workdirs (`/tmp/r10earl44v_wd_*`) and scratch worktrees
deleted.
