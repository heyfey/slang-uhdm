# r10earl29 — ADVERSARIAL VERIFICATION of § concatIdxDecompile29

**VERDICT: PARTIAL.** Every one of the five gates reproduces **number for number** in my own
worktree, from my own build, and the implementer's central claims are all true — including the
two that most needed checking (no conversion; the `Scoreboard` mover is not the law). No cell
that matched golden before the patch stops matching it after: I found **0 over-fires** across
19 arms (the 9 shipped + 10 I built along the axes the shipped grid skipped).

It is not a PASS because the **decoded rendering table is wrong or incomplete in five product
cells**, and two of them make a name **strictly worse than base**: a **string-literal element is
DELETED** (base was one space away from golden), and a **range select over a multi-level element
select** loses its base name (base was one space away from golden). One of the two is a shape the
shipped README explicitly claims is protected by an abstention — the abstention is not on that
code path. **Empirical price today: 0 movers.** Every real carrier of every mis-rendered cell is
`SLANG_REJECT` / `DEFERRED` / not-a-test, so nothing regresses on any measurable row, which is
why this is PARTIAL and not FAIL.

---

## 0. WHAT I RAN, AND THE BASE OF EVERY BINARY I COMPARED

| thing | value |
|---|---|
| verifier patched worktree | `/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl29v` |
| its `git rev-parse HEAD` | `266d3a6649663dc151188b0623e88d9336b7c745` |
| verifier pristine worktree | `/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl29vpris` |
| its `git rev-parse HEAD` | `266d3a6649663dc151188b0623e88d9336b7c745`, `git status --short` **empty** |
| main tree | `f3083f0`, **never written by me** |
| patch md5 | `6635e15f23ecadae0410c400dee1812d` — matches the implementer's exactly |

Both binaries were built by me from an absolute build path, and both base commits were printed and
checked **before** any delta was attributed.

---

## 1. THE FIVE GATES — MINE BESIDE THEIRS

| gate | implementer | **mine** | verdict |
|---|---|---|---|
| 1 baseline md5 (pristine 266d3a6) | `663899bcad3b7696f1d3f9fa972ec085` | `663899bcad3b7696f1d3f9fa972ec085` | **identical**, 32 hex |
| 1 patched md5 | `40ca13d1183a4b10ab52dd809af1f1ca` | `40ca13d1183a4b10ab52dd809af1f1ca` | **bit-for-bit reproducible build** |
| 1 link line | present | `73:[100%] Linking CXX executable slang-uhdm` in both build logs; `grep -ci error:` = 0 | ok |
| 2 goldens | 23 PASS / 0 FAIL | **23 PASS / 0 FAIL** (`rc=0`) | ok |
| 2 negative control | 0 PASS / 23 FAIL | `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** (`rc=1`) | harness has teeth |
| 3 u2r testflags status | 679 / 50 / 2 | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** | ok |
| 3 u2r dump column | 496 / 183 / 52 | **496 match / 183 differ / 52 blank** | ok |
| 3 whole-row judge | 0 differing rows | **0 differing ROWS (0 diff row-sides)**, 731 rows both | ok |
| 4 surelog default | 467 / 13 | **467 CMP_EQUAL / 13 CMP_NOTEQUAL**, 284 SLANG_REJECT, 25 SURELOG_FAIL | ok |
| 4 surelog testflags | 463 / 10 | **463 CMP_EQUAL / 10 CMP_NOTEQUAL**, 286 SLANG_REJECT, 23 SURELOG_FAIL, 3 NO_DATABASE, 1 NO_UHDM, 1 TIMEOUT, 2 UNTRANSLATABLE | ok |
| 4 surelog dump | 225 / 165 | **default 225 match / 242 differ / 327 blank; testflags 165 match / 298 differ / 331 blank** | ok |
| 4 DEFERRED | 5 per mode | **5 per mode** (`GOLDEN_DEFER` untouched): Earlgrey_nexysvideo, Earlgrey_Verilator_01_05_21, Rsd, Xgate, YosysSmallBoom | ok |
| 4 whole-row judge | 0 differing rows | **0 differing ROWS**, 1588 rows both | ok |
| 5 byte verifier u2r | 0 / 679 | **MOVERS: 0 / 679**, PATH_SETS_IDENTICAL, SELFCHECK **678/679**, SELFCHECK1 **= 1** | ok |
| 5 byte verifier surelog | 2 / 953 | **MOVERS: 2 / 953**, SELFCHECK **952/953**, SELFCHECK1 **= 3** | ok |
| 5 mover md5s | Earlgrey patched `a5e4b8d46499` / pristine `21c7884247a2` | **identical prefixes in my sweep** | cross-agent determinism |

Commands (all run from `.claude/worktrees/r10earl29v`, absolute paths elided for width):

```sh
cmake --build .../r10earl29v/build -j 5           # + the pristine twin
md5sum .../r10earl29v/build/slang-uhdm .../r10earl29vpris/build/slang-uhdm   # separate command
SLANG_UHDM=.../r10earl29v/build/slang-uhdm bash tests/check_goldens.sh
SLANG_UHDM=/bin/false bash tests/check_goldens.sh
SLANG_UHDM=... python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
   --out $SP/v_u2r_patched.csv --workdir /tmp/e29v_wd/u2r_pat --jobs 2 --timeout 240
SLANG_UHDM=... python3 scripts/verify_golden.py --corpus surelog --mode both \
   --out $SP/v_sl_patched.csv --workdir /tmp/e29v_wd/sl_pat  --jobs 2 --timeout 240
bash tools/probe/r10oth8repro/ct8rows.sh results/gate_uhdm2rtlil.csv $SP/v_u2r_patched.csv
bash tools/probe/r10oth8repro/ct8rows.sh results/golden_surelog.csv  $SP/v_sl_patched.csv
SELFCHECK=1 SELFCHECK1=1 bash tools/probe/r10oth6repro/byteverify.sh /tmp/e29v_wd/{u2r_pat,u2r_pris}
SELFCHECK=1 SELFCHECK1=1 bash tools/probe/r10oth6repro/byteverify.sh /tmp/e29v_wd/{sl_pat,sl_pris}
```

**CANARIES, all reproduced exactly:**

```
u2r      EXPECT_UNKNOWN=6 r10oth7repro/ctcan2.sh   -> ok=1  changed=0 absent=0 unknown-patterns=6  PASS
u2r      r10uvm52repro/canaries.sh                 -> ok=8  changed=0 absent=0 unknown-names=25
surelog  EXPECT_UNKNOWN=1 r10oth7repro/ctcan2.sh   -> ok=58 changed=0 absent=0 unknown-patterns=1  PASS
surelog  r10uvm52repro/canaries.sh                 -> ok=52 changed=0 absent=0 unknown-names=7
         r10uvm55repro/canaudit.sh                 -> audited=29 UNCOVERED=0 FENCE-BREACH=0        PASS
```

`InterfaceModPort` and `BlackParrotComplex` **by name**, surelog, both modes:
`CMP_EQUAL,,,differ` in baseline and in my fresh CSV, unchanged. Neither has a u2r row.
The four slang-fenced names were dispatched by nothing.

### Patch hygiene — checked before and after

```
git apply --stat /tmp/r10earl29.patch
  include/UhdmExporter.h | 64 ++, src/ExprEmit.cpp | 268 ++, tools/probe/r10earl29repro/* (12 files)
  14 files changed, 1309 insertions(+), 9 deletions(-)
git status --short results/ scripts/ tests/    ->  EMPTY, before and after the patch and after all sweeps
git diff 266d3a6 --name-only                   ->  include/UhdmExporter.h, src/ExprEmit.cpp
```

No `results/*.csv`, no harness (`scripts/verify_golden.py`, `tests/check_goldens.sh`), no slang
header. `include/UhdmExporter.h` is inside the stated emitter scope. Applies cleanly to a fresh
`266d3a6`. `results/` was read only.

### No collision with the two live passes

`concatIdxText` appears 6 times in `src/ExprEmit.cpp` = 1 definition + **5 call sites**, and the
gate lives inside the function, so the gate is literally identical at all five. The only
`sourceRange` uses the diff adds are `rawText(...)` **reads** — the patch sets no object span, so
it cannot touch **r10svs3**'s function-object SPAN policy; and `makeReturnVar` / return-variable
code is absent from the diff, so it cannot touch **r10uvm58**. Territory respected: every edit is
inside hier_path name synthesis.

---

## 2. THE CLAIMS THAT MATTERED MOST — INDEPENDENTLY CONFIRMED

### 2a. NO CONVERSION (confirmed; nothing to promote)

```
results/golden_surelog.csv   Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
                             Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
my PRISTINE sweep            Earlgrey_0_1,default,CMP_NOTEQUAL,...   testflags,SLANG_REJECT,...
my PATCHED  sweep            Earlgrey_0_1,default,CMP_NOTEQUAL,...   testflags,SLANG_REJECT,...
```

Both modes, from my own sweeps: **unchanged**. The implementer's "does NOT convert" is correct and
they were right not to quote a converted row.

### 2b. The head cleared 228 → 36, and the new head is PRE-EXISTING

`uhdm-cmp golden.uhdm ours.uhdm`, one head per run, `grep -c '^LHS:'` = 1 in both:

```
BASE    (266d3a6)  lines=228  heads=1   first divergence = the hier_path NAME
PATCHED            lines= 36  heads=1   first divergence = constant vpiConstType 7 (golden) vs 9 (ours)
                                        at dm_csrs.sv 389:36-389:50, vpiSize:3 INT:0
```

Proof the new head is not the patch's: the **base** binary's own dump at that span already reads
`|vpiConstType:9` with identical `vpiSize:3` / `INT:0`, and `grep -cE "vpiConstType|389:"` over the
28 changed lines = **0**. REFUTATION 4 of the brief ("the single remaining head") stands: one head
is a property of `uhdm-cmp`, not of the design.

### 2c. Mover attribution — ADDED and REMOVED separately, keyed on nothing

I re-did the attribution from scratch, taking **every** changed line rather than keying on a kind
(the failure mode the brief names):

```
diff base-ours patched-ours   ->  28 changed sides, 4 hunks, 10 distinct added / 10 distinct removed
ADDED   : each grep -Fxc against golden.dump  ->  10/10 PRESENT   (counts 1 or 2)   0 findings
REMOVED : each grep -Fxc against golden.dump  ->  10/10 ABSENT                      0 findings
```

Three shapes, two source occurrences (`dm_csrs.sv:309` **and `:422`**), exactly as claimed:
`\_hier_path: (...)` header, `\_bit_select: (work@...)` header, and the `|vpiName:` /
`|vpiFullName:` field lines.

### 2d. `VpiFullName` is compared nowhere (confirmed)

```
cd ~/git-repos/UHDM && grep -rn "VpiFullName().compare" build/generated/src/ | wc -l   ->  0
build/generated/src/hier_path.cpp:120:  if ((r = lhs->VpiName().compare(rhs->VpiName())) != 0)
bit_select::Compare  ->  basetype_t::Compare, VpiConstantSelect, SafeCompare(VpiIndex)   (no name)
BaseClass::Compare   ->  VpiType(), VpiName().compare, VpiDefName().compare
```

The sole gating field is the `hier_path`'s `VpiName`. The `bit_select` fullname change is a real
byte mover and can never be a cmp head.

### 2e. `Scoreboard` is per-run nondeterminism — CONFIRMED AND STRENGTHENED

The implementer showed one *unpatched* binary producing three databases. I got a **stronger**
result: **both** binaries produce **both** values, so the value sets overlap and no md5 can be
attributed to either binary.

```
                       run1              run2              run3              run4
pristine 266d3a6   efa9bf85d1d051f8  efa9bf85d1d051f8  efa9bf85d1d051f8  4fc00091d5205811
patched            efa9bf85d1d051f8  4fc00091d5205811  4fc00091d5205811  efa9bf85d1d051f8
```

(six byte-identical invocations of the same argv in the test's own directory; my *sweep* produced
yet another pair — pristine `efa9bf85d1d0`, patched `c1f14e1c1d5e` — so ≥3 classes exist.)
`uhdm-cmp` calls the variants **equal** (`PASS_CMP` pristine-run1 vs pristine-run4, and
pristine-run1 vs patched-run2). Both dumps are **1 097 053** lines and, sorted, `cmp`-identical:
**a pure permutation**, 92 changed sides in 2 hunks, kinds `|vpiTaskFunc:` / `\_function:` /
`\_task:` only, and `grep -c '\[{'` over the changed lines = **0**. `Scoreboard` contains no
concat-indexed select at all. **Not this law.** The implementer was also right to withdraw the
citation of the *alias-population-build-dependent* memory (refuted by r10det1 `35f3677`) and rest
the claim on direct measurement.

### 2f. The census (predicted movers) — confirmed independently

```
u2r, member select with a concat index                      -> 0 hits, 0 files
u2r, ANY select with a concat index                         -> asym_ram_sdp_read_wider, asym_ram_sdp_write_wider
   both CMP_EQUAL + match, and their slang.uhdm are BYTE-IDENTICAL base vs patched
surelog, the hier shape                                     -> 18 files / 10 test dirs
   Opentitan SLANG_REJECT · Earlgrey_Verilator_0_1 SLANG_REJECT · NyuziProcessor SLANG_REJECT
   IncompTitan SLANG_REJECT · AzadiRTL SLANG_REJECT · Ariane2024 SLANG_REJECT/NO_DATABASE
   Earlgrey_nexysvideo DEFERRED · Earlgrey_Verilator_01_05_21 DEFERRED · ariane not a test
   Earlgrey_0_1 default CMP_NOTEQUAL  <-- the only measurable carrier
```

Predicted exactly one mover; got exactly one (plus the nondeterministic `Scoreboard`).
Minor imprecision only: 18 carrier files, not 14, and `Ariane2024/testflags` is `NO_DATABASE`
rather than `SLANG_REJECT`. Same test set, same conclusion.

### 2g. The shipped grid re-measured from scratch

Running **both** binaries over the 9 shipped arms and pairing cells **span-keyed** against the same
golden (`cells.py`), then diffing the per-cell verdicts base → patched:

```
hier_path NAME cells, patched:  72 total   EQ=67   DIFFER=5     <-- the implementer's exact numbers
per-cell transitions, all kinds, 9 arms:  FIXED=96  OVER-FIRE=0  changed-still-wrong=3  unchanged-still-wrong=25
a3_plain (plain non-hier select)  : ours BYTE-IDENTICAL base vs patched (path-normalised)
a6_noconcat (the over-fire control): ours BYTE-IDENTICAL base vs patched (path-normalised)
```

The 5 residual DIFFERs are exactly as claimed — 4 non-concat indices (out of territory: `[rq.addr]`,
`[k+1]`, `[m[1][2]]`, `[w[2]]`) and 1 measured abstention (`{1'b1, PP}` → golden `{1'b1,2'd1}`).
The 3 "changed-still-wrong" cells in the shipped arms all have the **bracket text now correct** and
fail on a pre-existing span (R5) or parent-prefix (R3) difference.

---

## 3. THE OVER-FIRE HUNT — 10 NEW ARMS ALONG THE AXES THE GRID SKIPPED

The brief says the dangerous axis for a NAME law is CONTEXT, and that five passes running shipped
exactly one over-fire each in a product cell. I built the cells the shipped grid does not contain:
`v1_scope` (package/class-qualified names), `v2_sel` (select shapes under a range select),
`v3_lit` (constant spellings), `v4_ctx2` (macro / function body / task body / cross-instance),
`v5_gen` + `v6_genvar` (generate + genvar), `v7_lval` (the INDIRECT name site — `dotted` is also
passed as the name PREFIX for the index's own sub-objects), `v8_sites2` (event control, case
expression, port connection, call argument), `v9_scoped` (scoped pkg param with no import anywhere),
`v10_str` (string-literal element). All ten are committed beside the shipped arms and run with the
same `arm.sh` / `cells.py`.

```
my 10 arms:  hier_path cells=35  EQ=23  DIFFER=12
transitions, all kinds:  FIXED=41  OVER-FIRE=0  changed-still-wrong=18  unchanged-still-wrong=36
```

**OVER-FIRE = 0 across all 19 arms.** No cell that matched golden before the patch stops matching
after it — the strict over-fire the brief predicted is **not** present.

Cells the shipped law gets RIGHT that no shipped cell covered (worth recording, they are the law's
real reach): wildcard-imported pkg enum literal; three-level element select; single-level element
select with a **non-constant** index; element select on a **member**; uppercase-base constant
`4'HA`; unbased-unsized `'0`; signed base `2'sd1`; **function body**; **task body**;
**macro-expanded index** (base leaked the macro FORMAL `{1'b1, a}` — the patch fixes that);
genvar-indexed element select; per-iteration `localparam` (kept by name, so the genvar-fold memory
does **not** reach it); bare genvar bit-select `gi[0]` → EMPTY; event control; case expression;
port connection; call argument; and the **LVALUE indirect site** — golden's inner ref_obj is
`work@v7_lval.t.autoexecprogbuf[{1'b1,kb}].autoexecprogbuf.kb`, i.e. golden uses the *decompiled*
bracket in the inner object's prefix too, and patched matches it byte-for-byte where base did not.

---

## 4. FINDINGS — most severe first

Every finding below is a **cell where the patch changes the name and does not land on golden**. All
five have **0 movers today**; the severity ordering is by how wrong the shipped *law* is and whether
a real corpus carrier exists.

### F1 — A STRING-LITERAL element is DELETED, and the README's stated abstention is not on this path. Named real carrier.

```
SRC        always_comb o1 = q.m[{"a_chan_", s}];        (v10_str.sv)
GOLDEN     q.m[{"a_chan_",s}]                          <-- golden RENDERS the literal, with quotes
BASE-OURS  q.m[{"a_chan_", s}]                          <-- ONE character from golden (the space)
PATCH-OURS q.m[{,s}]                                    <-- the literal is GONE
           bit_select fullname likewise: work@v10_str.q.m[{,s}].m  vs golden ...[{"a_chan_",s}].m
```

Command: `REPRO=... PAT=... PRIS=... vgrid.sh v10_str.sv` then
`deltacells.py v10 /tmp/e29v_grid/v10_str.cells.{base,pat}`.

The shipped README says this shape is safe because *"the string-literal kind falls through to
`default: return false`"*. It does not: the whole index **succeeds** with an empty element, so the
literal reaches one of the four arms that `return true` without appending. By elimination
(`HierarchicalValue`, `MemberAccess`, non-system `Call` are impossible for a literal) it is
**`case ExpressionKind::Conversion: return true`** — i.e. a conversion that `stripImplicitConv`
does not strip because `isImplicit()` is false for a **propagated** conversion. The comment on that
arm calls it "EXPLICIT after the implicit strip", which is the wrong model: a non-`Implicit`
conversion is not necessarily an explicit cast. **This is the real hazard of the whole design** —
any element slang wraps in a propagated conversion silently renders as the empty string.

Carriers, all `SLANG_REJECT` today, so 0 movers:
`Opentitan/hw/ip/tlul/generic_dv/env/xbar_env.sv:79,81,85,87`
(`scoreboard.item_fifos[{"a_chan_", xbar_hosts[i].host_name}]`) would take this exact change. The
`gpio`/`rv_timer` scoreboard lines (`cov.sticky_intr_cov[{"...", $sformatf("%0d", each_bit)}]`) are
protected — but by the **multi-argument system-call** guard, not by the string guard the README
credits.

### F2 — A RANGE SELECT over a multi-level element select loses its base name, and this cell is strictly WORSE than base.

```
SRC        o1 = q.autoexecprogbuf[{1'b1, m[1][3:0]}];   (v2_sel.sv, m is logic [1:0][3:0])
GOLDEN     q.autoexecprogbuf[{1'b1,m[1][3:0]}]          <-- rendered IN FULL
BASE-OURS  q.autoexecprogbuf[{1'b1, m[1][3:0]}]         <-- ONE character from golden (the space)
PATCH-OURS q.autoexecprogbuf[{1'b1,3:0}]                <-- `m[1]` dropped
```

Mechanism, and it is a one-line predicate bug: `selBaseInfo()` sets `simpleBase` from the *bottom*
of the chain (`cur->kind == NamedValue`) and **counts levels only for `ElementSelect`**, so the
`RangeSelect` arm cannot tell `w[3:0]` (golden: range alone) from `m[1][3:0]` (golden: full).
Golden's own distinction is visible in the shipped grid: a **multi-level element select renders in
full** (a1 o9), so a range select *over* one plainly does too. The correct gate is
`simpleBase && elemLevels == 0`.

### F3 — a SIXTH hier_path name site is not patched, so the law is applied inconsistently in our own database. Named real carrier.

```
SRC        assign o4 = u.q2.autoexecprogbuf[{1'b1, k[0]}];   (v4_ctx2.sv, CROSS-INSTANCE prefix)
GOLDEN     u.q2.autoexecprogbuf[{1'b1,}]
BASE-OURS  u.q2.autoexecprogbuf[{1'b1, k[0]}]
PATCH-OURS u.q2.autoexecprogbuf[{1'b1, k[0]}]                <-- UNCHANGED: the law never fires here
```

The shipped README states the four `b1` site families "now render byte-exactly as golden" and that
the law is applied "where golden applies it and **NOWHERE ELSE**". `b1` contains no
cross-instance case, so it cannot see this site. Real carrier, `SLANG_REJECT` today:
`Opentitan`-adjacent `NyuziProcessor/hardware/testbench/soc_tb.sv:377` —
`nyuzi.l2_cache.l2_cache_read_stage.sram_l2_data.data[{way, set}]` is exactly this shape.
Under-fire, not over-fire: nothing regresses, but the law is incomplete and the claim is too strong.

### F4 — a PACKAGE-SCOPED name renders as the bare identifier where golden renders its VALUE, and the abstention that hides this is DESIGN-GLOBAL.

```
v9_scoped (NO import anywhere in the design)
SRC        o1 = q.autoexecprogbuf[{1'b1, pkw::WP, k[0]}];   GOLDEN {1'b1,1,}   PATCH {1'b1,WP,}
SRC        o2 = q.autoexecprogbuf[{1'b1, pkw::WE1, k[0]}];  GOLDEN {1'b1,1,}   PATCH {1'b1,WE1,}
v1_scope  (a SECOND module in the same file does `import pkv::*`)
SRC        o1 = q.autoexecprogbuf[{1'b1, pkv::SP}];         GOLDEN {1'b1,1}    PATCH unchanged (abstained)
SRC        o2 = q.autoexecprogbuf[{1'b1, pkv::SE1}];        GOLDEN {1'b1,1}    PATCH {1'b1,SE1}
```

Two separate defects in one cell:

1. `sym.name` **drops the `pkg::` qualifier**, and golden does not render the identifier at all —
   it renders the **value**. (Contrast the wildcard-imported case, where golden *does* render the
   name `SE1`: whether the qualifier is written changes golden's rendering, so one rule cannot serve
   both.) Campaign memory's `naming-context-dependent` dead-end note is about exactly this.
2. The abstention `importedParamDefTs.count(&sym)` is keyed on a **whole-design** map populated by
   `ParamEmit.cpp:12953` when *some* scope wildcard-imports the package. `v1_scope` and `v9_scoped`
   differ only in whether **another module** imports, and the same source line renders differently.
   The gate is not use-site-local, so this cell's behaviour is a property of the rest of the design.

Enum literals are not in that map at all, so no abstention protects them. 0 movers today, but this
is the residue closest to live work: the **new Earlgrey head (R4) is itself a folded package enum
literal**, and Earlgrey/Opentitan use `dm::` scoped names everywhere.

### F5 — the shipped table row "constant → its own spelling" is false: golden strips digit-separator underscores.

```
SRC  {1'b1, 4'd1_0, k[0]}     GOLDEN {1'b1,4'd10,}    PATCH {1'b1,4'd1_0,}
SRC  {1'b1, 4'b10_10, k[0]}   GOLDEN {1'b1,4'b1010,}  PATCH {1'b1,4'b10_10,}
```

Uppercase base and digits *are* preserved (`4'HA` → `4'HA`, and `'0`, `2'sd1` round-trip), so golden
is not fully re-printing from the value — it re-prints the token with `_` removed. Copying
`rawText` is therefore right in 3 of the 5 constant cells I measured and wrong in 2. Same class of
defect as F1: the *method* (copy source text) is not the mechanism (decompile the tree).

### F6 — an INDEXED PART SELECT element is rendered from raw bracket text instead of recursively, so a non-constant offset survives where golden drops it.

```
SRC  {1'b1, w[k[0]+:2]}   GOLDEN {1'b1,+:2}   BASE {1'b1, w[k[0]+:2]}   PATCH {1'b1,k[0]+:2}
```

Golden's `+:` rendering is `R(offset) +: R(width)` recursively — `k[0]` is a single-level bit select
and so renders EMPTY, leaving the bare `+:2`. `lastBracketBody(rawText(...))` cannot express that.
Patched is closer to golden than base, so this one is an improvement in degree, but it is not the
decoded rule. It matters for the future because the **one** real non-Earlgrey carrier of a
concat-indexed select in the corpus is exactly an indexed part select over a concatenation
(`ariane` / `Ariane2024`: `mem_rtrn_i.data[{cl_offset_q,3'b0} +: N]`), which today the top-level gate
correctly leaves alone.

### F7 — bookkeeping imprecisions in the shipped write-up (no behavioural impact)

* "surelog corpus: 14 files carry the shape" — I count **18** files across the same 10 test dirs.
* `Ariane2024/testflags` is `NO_DATABASE`, not `SLANG_REJECT`.
* "Grid: 72 hier_path NAME cells, 67 EQ, 5 DIFFER" is exact; the *arm-level* numbers in §3 of the
  shipped README are cell counts over all tracked kinds, which is easy to misread as name cells.

---

## 5. RANKED RESIDUE LIST (mine, merged with the implementer's)

Ranked by **wrongness of the shipped law × reachability**, not by proximity.

| # | residue | evidence | price today |
|---|---|---|---|
| **V1** | the `Conversion` arm renders **any** non-`Implicit` conversion as EMPTY — string literals today, any propagated conversion tomorrow (F1) | `v10_str` | 0 movers; 4 named `SLANG_REJECT` lines |
| **V2** | `selBaseInfo.simpleBase` ignores `elemLevels` on the `RangeSelect` arm → `m[1][3:0]` loses its base (F2) | `v2_sel` o1 | 0 movers |
| **V3** | the 6th hier_path name site (cross-instance hier prefix) is unpatched (F3) | `v4_ctx2` o4 | 0 movers; `NyuziProcessor` soc_tb.sv:377 |
| **V4** | package-**scoped** names: qualifier dropped, golden renders the VALUE; and the abstention is design-global (F4) | `v1_scope`, `v9_scoped` | 0 movers; adjacent to R4 |
| **V5** | constants: golden strips `_` (F5) | `v3_lit` o2/o5 | 0 movers |
| **V6** | indexed part select rendered from raw text, not recursion (F6) | `v2_sel` o5 | 0 movers; `ariane` shape is gate-excluded |
| R1 | bracket-DROP for a non-concatenation index (`[rq.addr]`, `[w[2]]`, `[m[1][2]]` → no brackets at all) — out of territory, mechanism decoded | a6 o3, b2 o1/o2 | 4 grid cells |
| R1b | `[k+1]` → golden `[k + 1]`: the *non-concat* path still lacks the operator spacing the concat path now has | a6 o4 | pre-existing |
| R2 | wildcard-imported pkg param element → golden's sized literal `2'd1` (clean, detected abstention) | b3 o1 | 1 grid cell |
| R3 | inner-index-object `VpiFullName` parent policy: golden prefixes with the enclosing bit_select (`...[{1'b1,}].autoexecprogbuf.k`), we emit `work@mod.k`; we already do it for `part_select` | a1/a2/b1/b2/v7/v8 | ~12 cells, cmp-invisible |
| R4 | `vpiConstType` 7-vs-9 on a folded package enum literal — **the new Earlgrey_0_1/default head**, pre-existing, unowned | §2b | the blocker on this row |
| R5 | inner-index-object SPANS (golden spans `k[0]`, we span `k`) — borders r10svs3's SPAN policy, untouched | b1, 8 MISSING cells | pre-existing |
| R6 | inner index objects we do not emit at all (golden's `ref_obj ...autoexecprogbuf.kb`) | `v7_lval`, 2 MISSING | pre-existing |
| R7 | `Scoreboard` per-run output instability — an INSTRUMENT defect: the byte verifier has a blind spot on that one test (§2e) | 8 runs, 2 binaries | costs verifier precision |

---

## 6. WHY PARTIAL AND NOT PASS OR FAIL

* **Not FAIL.** All five gates reproduce exactly; 0 differing rows on both corpora; 0 movers on
  u2r; the one real mover is fully attributed with 0 findings in both directions; goldens 23/0 with
  a working negative control; every canary green; no regression on any measurable row; no
  territory collision; `results/` and the harness untouched; the patch is a reproducible build
  (`40ca13d1…` from an independent worktree).
* **Not PASS.** The brief's standard is "the rule you ship must be the rule the grid shows, cell for
  cell". Six product cells say otherwise, and two of them (F1, F2) move a name from **one character
  away from golden** to a **deletion**. One of those two is claimed protected in the shipped README
  by an abstention that is not on that code path — the exact "cited guard that does not exist"
  failure this campaign keeps paying for. F1 and F2 are both one-predicate fixes (`Conversion` →
  abstain unless the cast is genuinely explicit; `simpleBase && elemLevels == 0` on the RangeSelect
  arm) and would make the shipped law match every cell I could measure.

**Recommendation:** land it — the empirical price is zero and the Earlgrey head genuinely clears —
but land F1 and F2 as one-line follow-ups first, or record them in the commit message as known
wrong cells with their arms named, because a future pass that widens this gate will inherit them.
