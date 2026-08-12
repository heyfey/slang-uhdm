# r10earl32 — ADVERSARIAL VERIFICATION of § fcArgPkgParamValueFolds32

**VERDICT: PASS**, with **two landing conditions** (F2/F3, both about the REBASE)
and **three ranked residues** (F1, F4, F5) recorded below.

Everything the implementer reported reproduced **exactly** — not "consistent
with", but byte-for-byte, down to both binaries' md5, every golden count printed
by `mv32.sh`, both byte-verifier md5 prefixes, and all five arms' cell-diff
counts. I built the patch myself on a fresh 981f2e3, built my own pristine
981f2e3, re-ran all five gates, all canaries, the census, the mover attribution,
the multiset distance and the source-derived fence, and then built **five new
arms of my own** in the product space the implementer's grid skips.

Nothing I built refuted the LAW. Two things I built refuted a stated CLAIM about
the law's implementation (F1, F2), and one exposed an unfilled cell of real
corpus reach (F4).

---

## 0. WHAT I BUILT AND WHERE

| worktree | HEAD | contents | binary md5 |
|---|---|---|---|
| `.claude/worktrees/r10earl32vp` | 981f2e3 | **PRISTINE**, mine | `a0ee9da69c335abd511be108d13ebf86` |
| `.claude/worktrees/r10earl32v` | 981f2e3 | + `/tmp/r10earl32.patch` | `64602ae6bd08de389cdd5c4911252109` |
| `.claude/worktrees/r10earl32vr` | **8633a1e** | + the patch, `git apply -3` | `9f4bdf22d6d648600c99aa528983f247` |

Both md5s in rows 1–2 are **the implementer's exact numbers**. The build is
deterministic, so this is the strongest possible corroboration that we compiled
the same source: my `BASELINE=a0ee9da6…` and `FINAL=64602ae6…` were produced on
a different day, in a different worktree, by a different agent.

BASE grep-checked on every binary before use:

```
r10earl32v  HEAD=981f2e35e807a28886a74582926e53ec1160b826   fcArgFold32 in src/ExprEmit.cpp: 3
r10earl32vp HEAD=981f2e35e807a28886a74582926e53ec1160b826   fcArgFold32 in src/ExprEmit.cpp: 0
r10earl32vr HEAD=8633a1e6dc9031e3c13862813864f900c324fdf2   fcArgFold32: 3 + constArgBodyEvald60: 2
```

New arm sources added by me, in this directory:
`v1_esctext.sv`, `v2_pos.sv`, `v3_nosubst.sv`, `v4_more.sv`.

---

## 1. EVERY NUMBER, RE-MEASURED

### GATE 1 — BUILD

```
$ grep -c "Linking CXX executable slang-uhdm" /tmp/e32v_build.log   -> 1
$ grep -icE "error:"                          /tmp/e32v_build.log   -> 0
$ grep -icE "warning:"                        /tmp/e32v_build.log   -> 20   (pristine: 20)
$ md5sum .claude/worktrees/r10earl32v/build/slang-uhdm
  64602ae6bd08de389cdd5c4911252109
$ md5sum .claude/worktrees/r10earl32vp/build/slang-uhdm
  a0ee9da69c335abd511be108d13ebf86     (32 hex, validated; SEPARATE command)
```

The pristine baseline is not asserted, it is **corroborated**: my own pristine
sweeps reproduce **both** committed CSVs at **0 differing rows** —

```
$ bash tools/probe/r10oth8repro/ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/e32vsweep/u2r_pris.csv
  ---- WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)   PASS
$ bash tools/probe/r10oth8repro/ct8rows.sh results/golden_surelog.csv  /tmp/e32vsweep/sl_pris.csv
  ---- WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)   PASS
```

### GATE 2 — GOLDENS (pinned; the harness defaults `SLANG_UHDM` to the MAIN TREE)

```
$ SLANG_UHDM=<my patched build> ./tests/check_goldens.sh   rc=0  PASS=23 FAIL=0
$ SLANG_UHDM=/bin/false         ./tests/check_goldens.sh   rc=1  PASS=0  FAIL=23
$ echo "[${GOLDEN_DEFER:-UNSET}]"                          [UNSET]
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, my own `--out`/`--workdir`

```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
dump  testflags  496 match / 183 differ / 52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv  ->  0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both --jobs 2`

```
[default]   794 tests  CMP_EQUAL:467  SLANG_REJECT:284  SURELOG_FAIL:25  CMP_NOTEQUAL:13  DEFERRED:5
[testflags] 794 tests  CMP_EQUAL:463  SLANG_REJECT:286  SURELOG_FAIL:23  CMP_NOTEQUAL:10  DEFERRED:5
                       NO_DATABASE:3  UNTRANSLATABLE:2  TIMEOUT:1  NO_UHDM:1
dump  default   225 match / 242 differ / 327 blank
      testflags 165 match / 298 differ / 331 blank
ct8rows.sh results/golden_surelog.csv  ->  0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

**`Earlgrey_0_1/default` does NOT convert — CONFIRMED INDEPENDENTLY.** `default`
is **467/13**, not 468/12. The row, both sides:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,            <- my fresh patched sweep
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,            <- results/golden_surelog.csv
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,, <- both, unchanged
```

`results/*.csv` were read only, by me and (per the patch's file list) by the
implementer.

### GATE 5 — BYTE VERIFIER, both corpora, vs MY OWN pristine 981f2e3

```
$ SELFCHECK=1 SELFCHECK1=1 byteverify.sh /tmp/e32vsweep/wd_u2r_p /tmp/e32vsweep/wd_u2r_pris
  PATH_SETS_IDENTICAL (679 paths)      MOVERS: 0 / 679
  SELFCHECK 678 / 679 flagged          SELFCHECK1 = 1

$ SELFCHECK=1 SELFCHECK1=1 byteverify.sh /tmp/e32vsweep/wd_sl_p  /tmp/e32vsweep/wd_sl_pris
  PATH_SETS_IDENTICAL (953 paths)
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
        patched=dcc8b974f5a1  pristine=813a083a29dd
  MOVERS: 1 / 953                      SELFCHECK 952 / 953 flagged   SELFCHECK1 = 2
```

**Both md5 prefixes are the implementer's exact strings.** One mover in 1632
databases. Because every other CMP_NOTEQUAL database is **byte-identical**, no
other row's cmp head can have moved in either direction — the "no head got
deeper" claim is not a spot check here, it is a whole-corpus consequence.

### THE HEAD — CLEARED, re-run by me

```
$ uhdm-cmp ~/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm slang.uhdm
LHS:
decompile:
hier_path: (region_cfgs[8].base.q), id:83554, line:315:10, endln:315:21
|vpiParent:  \_cont_assign: , line:315:10, endln:315:44
|vpiActual:  \_bit_select: (region_cfgs[8]) ...
```

`dm_mem.sv` is gone from the head entirely; the new head is `flash_ctrl.sv:315`,
exactly the implementer's R2. cmp output 154 lines.

### THE CENSUS — 8 → 0, re-run on my own dumps

```
BEFORE (golden vs my pristine)                    AFTER (golden vs my patched)
func_call golden=ref_obj  ours=ref_obj    234     234
func_call golden=constant ours=constant    70      78
func_call golden=constant ours=ref_obj      8       -        <== gone
...                                       (all other cells identical)
joined disagreements: 8                            0
golden-only arg slots 6 ; ours-only arg slots 6    6 ; 6     (unchanged, pre-existing)
```

### THE MOVERS — per shape, by MULTISET, both fabricated controls firing

`VERBOSE=1 SELFCHECK=1 mv32.sh g.dump o_pris.dump o_patched.dump` reproduced the
implementer's block **line for line**, including every golden count:

```
== ADDED instances=41 over 13 shapes; REMOVED instances=33 over 12 shapes
  ADDED   x1 golden=1 ok  \_constant: , line:365:75, endln:365:87    (and 375/378/386/408/416/419/429)
  ADDED   x8 golden=23     ok  |HEX:380                <- bare field line, ABSORBER
  ADDED   x8 golden=17877  ok  |vpiConstType:5         <- ABSORBER
  ADDED   x8 golden=19     ok  |vpiDecompile:12'h380   <- ABSORBER
  ADDED   x8 golden=1222   ok  |vpiSize:12             <- ABSORBER
  ADDED   x1 golden=0 OVER-FIRE  \_FABRICATED_SHAPE_r10earl31        <- CONTROL, correct
  REMOVED x1 golden=0 ours_after=0 ok  \_ref_obj: (dm::DataAddr), line:365:75, endln:365:79  (x8 sites)
  REMOVED x8 golden=8 ours_after=8 ok  \_parameter: (dm::DataAddr), line:34:27
  REMOVED x8 golden=233938 ours_after=222253 UNDER-FIRE |vpiActual:  <- ABSORBER, named
  REMOVED x8 golden=0 ours_after=0 ok  |vpiName:dm::DataAddr
  REMOVED x1 golden=0 ours_after=0 ok  \_FABRICATED_REMOVED_r10earl31 <- CONTROL, correct
  ADDED  : 12 covered, 1 OVER-FIRE ; REMOVED: 11 correct, 1 UNDER-FIRE
```

**There is no `ref_typespec` line anywhere in the delta**, added or removed —
which is the implementer's own proof that § psBoundPkgParamTs31 (r10earl31) does
not fire here. Confirmed on my dumps: brief question (e) answered, boundary
clean.

### MULTISET DISTANCE and the FENCE

```
BEFORE  golden-only 239070  ours-only 70509  MULTISET DISTANCE 309579   o lines 4654887
AFTER   golden-only 239036  ours-only 70483  MULTISET DISTANCE 309519   o lines 4654895  (-60, +8)
        (golden 4823448 lines both times)

pred32.sh   u2r 1886 files A=11 B=83 -> 69 dirs
            sltests 824 files A=29 B=104 -> 118 dirs
            sl3rd 11776 files A=542 B=2090 -> 39 dirs
  grep -ri earlgrey /tmp/e32/pred_*.txt  ->  pred_sl3rd.txt:Earlgrey_0_1
```

The one measured mover is **inside** the source-derived fence, computed before
any sweep was read. The fence is falsifiable and it was not falsified.

### THE ARMS — all five cell-diff counts reproduced

| arm | cells | diffs BEFORE (my pristine) | diffs AFTER (my patched) | claimed |
|---|---|---|---|---|
| `a1_kind` | 29 | 11 | **6** | 29 / 11 / 6 ✓ |
| `a2_type` | 16 | 10 | **0** | 16 / 10 / 0 ✓ |
| `a3_ctx` | 10 | 7 | **1** | 10 / 7 / 1 ✓ |
| `a4_text` | 9 | 9 | **9** | 9 / 9 / 9 ✓ |
| `a5_init` | 14 | 9 | **7** | 14 / 9 / 7 ✓ |

### CANARIES

```
ctcan2.sh EXPECT_UNKNOWN=6  u2r      ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh EXPECT_UNKNOWN=1  surelog  ok=58 changed=0 absent=0 unknown-patterns=1  PASS
tools/probe/r10uvm52repro/canaries.sh  u2r      ok=8  changed=0 absent=0 unknown-names=25
tools/probe/r10uvm52repro/canaries.sh  surelog  ok=52 changed=0 absent=0 unknown-names=7
canaudit.sh <canaries.sh> <ctcan2.sh>  audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
  UnsignedParam / HierPathEval / FileLocalParam / TopParam: not dispatched by any driver (OK)
```

BY NAME, every row byte-identical to `results/golden_surelog.csv`:
`InterfaceModPort`, `BlackParrotComplex`, `SVSwitch`, `FuncStructVal`,
`FuncStructValSimple`, `Earlgrey_0_1` (both modes).

### THE IMPLEMENTER'S OWN REFUTATION (b), RE-RUN AS A COUNTERFACTUAL

The one claim no gate output could confirm was that `aggregateToo` is
load-bearing. I built it: on the **rebased** tree I replaced `if (!aggregateToo)`
with `if (true)` in `paramDefRhsIsOp`, rebuilt (md5 `778294bd0457…`) and swept:

```
FuncStructVal,default,CMP_NOTEQUAL,decompile:,,
FuncStructVal,testflags,CMP_NOTEQUAL,decompile:,,
FuncStructValSimple,default,CMP_NOTEQUAL,decompile:,,
FuncStructValSimple,testflags,CMP_NOTEQUAL,decompile:,,
```

**Four rows demote.** The reported regression is real, the fix is necessary, and
it is not an artifact of the base (it reproduces on top of r10uvm60 too). The
worktree was restored immediately afterwards.

---

## 2. PATCH HYGIENE AND BOUNDARIES

```
15 files: include/UhdmExporter.h, src/ExprEmit.cpp, src/ParamEmit.cpp,
          tools/probe/r10earl32repro/{README.md,a1..a5.sv,argref32.py,arm32.sh,
                                      cells32.py,census32.py,mv32.sh,pred32.sh}
harness / results/*.csv touched: 0 files
git apply --check on a FRESH 981f2e3 worktree: rc=0, clean          <- confirmed
md5 /tmp/r10earl32.patch: 329ab8ab46a6e2f242f0eeffdff93fb9           <- confirmed
```

On the **added production lines only** (`git diff -U0 | grep '^+'`):

| grep | hits | boundary |
|---|---|---|
| `VpiConstType` | **0** | r10earl30 (vpiConstType on folded constants) — untouched |
| `MakeRef_obj` | **0** | no new ref_obj minted anywhere |
| `MakeRef_typespec` | **0** | no ref_typespec **allocated** in the diff |
| `GOLDEN_DEFER` | 0 | unset throughout |

Non-comment added production lines: **38**, all quoted in §3 below. The third
`src/ExprEmit.cpp` hunk (`@@ -10543`) is **comment-only** — I diffed it and it
contains no code change.

**One nuance the "0 MakeRef_typespec" line must not be allowed to hide**: the
patch *does* reach a `ref_typespec`-**attaching** helper at a new position —
`stampFoldedPkgParamTs(c, nv.symbol, prefix, declTsOnly=true)` in the BARE
branch of § fcArgFoldParent32. That helper is pre-existing and this is its
seventh call site. It is **not** r10earl31 territory (psBoundPkgParamTs31 owns
`ref_typespec` on **part-select-bound** folded constants, and its walk cannot
leave a `func_call` — proved by the empty ref_typespec delta above), but it is
the mechanism that F2 below rides on, so it deserves to be named rather than
counted as zero.

**Live-agent collisions**: `r10svs6` (fixed-size unpacked-array class
properties) and `r10uvm60` (macro-continuation constants in
`uvm_report_error`). The patch creates no class member and touches no macro
machinery; all 23 goldens and both UVM canary sets are byte-unchanged. But
r10uvm60 **has since landed** and that produces F2 and F3.

---

## 3. STATED GATE == CODE GATE — checked line by line

```cpp
const bool fcArgPos32 =
    parent && (parent->UhdmType() == UHDM::uhdmfunc_call ||
               parent->UhdmType() == UHDM::uhdmtask_call);
const bool fcArgFold32 =
    fcArgPos32 &&
    !patParamNoFold(nv.symbol.as<ParameterSymbol>()) &&
    !paramDefRhsIsOp(nv.symbol.as<ParameterSymbol>(), /*aggregateToo=*/true);
if (fcArgPos32 && !fcArgFold32) {   /* the pre-existing carve-out, unchanged */ }
```

Two conditions, exactly as stated: a **direct-parent** kind test and an
**initialiser-shape** test. No context flag, no view test, no import test, no
text test in the gate. Verified further:

* `.as<ParameterSymbol>()` is safe — the enclosing block is guarded at
  `src/ExprEmit.cpp:4434` by `nv.symbol.kind == SymbolKind::Parameter`.
* `paramDefRhsIsOp(ps, true)` is a strict **superset** of `paramDefRhsIsOp(ps)`
  (the flag only *skips* an early `return false`), so `fcArgFold32` implies
  `!paramDefRhsIsOp(psym)` and the later `paramRhsDefView && paramDefRhsIsOp`
  arm can never contradict it. No logical hole.
* the **two** `::` text tests are, as claimed, in the carve-out body and in
  § fcArgFoldParent32 — **and one of them is wrong on a spelling the standing
  law requires (F1)**.
* `paramDefRhsIsOp`'s new default argument leaves the two older call sites
  byte-identical — confirmed by reading the diff and by GATE 3/4 being 0 rows.

---

## 4. NUMBERED FINDINGS

### F1 — the `::` TEXT TEST MIS-READS A BARE ESCAPED IDENTIFIER WHOSE NAME CONTAINS `::`
**Severity: gate defect, byte residue, 0 corpus reach. The implementer's claim
that both text tests "were measured against macro-written and escaped-identifier
cells" is REFUTED for the one spelling that matters.**

`a4_text.sv`'s own header says it out loud — *"an ESCAPED identifier can contain
any character at all, including the ':' a name test would key on"* — and then
`a4` only builds `\p@x`, which has no colons. I built the missing cell
(`v1_esctext.sv`).

```
$ SLANG_UHDM=<patched> ./arm32.sh v1_esctext.sv /tmp/e32v_arm_v1
$ python3 cells32.py /tmp/e32v_arm_v1/g.dump /tmp/e32v_arm_v1/o.dump
arg@   | GOLDEN                                              | OURS
22:18  | constant 22:18-22:34 12'h380 p=func_call            | constant 22:18-22:29 p=func_call        v1a QUALIFIED   ok
28:18  | constant 28:18-28:28 12'h380 p=param_assign         | constant 28:18-28:23 p=func_call  <==   v1b BARE        WRONG PARENT
29:18  | constant 29:18-29:26 12'h381 p=param_assign         | constant 29:18-29:21 p=param_assign     v1c CONTROL     ok
```

v1b is `mf(\a::b )` read **bare** after `import m32v::*`, where the package
declares `localparam logic [11:0] \a::b = 12'h380;`. There is no package
qualifier at all, but `rawText(...).find("::")` finds one, so
§ fcArgFoldParent32 takes its QUALIFIED branch and parents the constant at the
**call**, where golden parents it at the package `param_assign`. The control v1c
(`\pl`, escaped, no colons) is **correct**, which isolates the cause to the
colons in the name and nothing else.

**This is not a regression** — pristine emits `ref_obj … p=func_call` on the same
cell, so the parent was already wrong and the object KIND is now right (net
improvement, cmp head depth 48 → 17 on this arm). And `vpiParent` is not a
`Compare` field. But the standing law says *"if any gate reads names or raw text,
test ESCAPED identifiers"*, and on the one escaped spelling that interacts with
the test, the answer is wrong. The same defect exists in the **pre-existing**
carve-out body's copy of the test, so a fix belongs to both.

*Command*: `./arm32.sh v1_esctext.sv` then `cells32.py g.dump o.dump`, both
binaries.

### F2 — THE PASS CREATES A **WRONG OBJECT** IN A CLASS-METHOD BODY — already neutralised by r10uvm60, which landed AFTER this base
**Severity: HIGH at the stated base 981f2e3; ZERO once rebased. Falsifies the
README's "an absent object, never a wrong one".**

`v2_pos.sv` cell w12: a **class method body** (`m32wc::cx`) calling
`cm(m32w::P)` — another package's parameter, so `ownPkgClassMethod47` does not
catch it, and the new fold reaches `emitCall`'s pre-existing `currentTf`
typespec stamper for the first time.

```
                              GOLDEN                     OURS @981f2e3+patch
v2 @77:15  cm  func_call  |  constant 12'h380 ts=<bare>  |  constant 12'h380
                                                            ts=ref_typespec(work@m32wc::cx)
                                                               ->logic_typespec@75:38-75:43   <== DIFF
           (pristine 981f2e3: ref_obj, no ts)
```

We hang a `ref_typespec` named after the enclosing **method** on a constant
golden leaves bare. That is precisely the defect class the README's R1 says it
refused to ship ("Left bare: an absent object, never a wrong one") — the pass
does not ship the *formal-ts law*, but the *fold* reaches an existing stamper in
a context nobody measured, and the wrong object appears anyway. `a1_kind` c12
measured only a **module** function body and generalised.

**It is already fixed upstream.** r10uvm60's § tfBodyConstArgNoFormalTs60 (landed
at `8633a1e`, i.e. **after** this pass's base) gates exactly this stamp on
`subBodyEvaluated60` and names "a class method nothing evaluates" as its own
corpus head. I built the combination to prove it rather than assume it:

```
$ git worktree add --detach .claude/worktrees/r10earl32vr 8633a1e
$ git apply -3 /tmp/r10earl32.patch            # 0 conflict markers
$ cmake --build build -j4                      # md5 9f4bdf22d6d648600c99aa528983f247
$ python3 cells32.py /tmp/e32vr_arm_v2_pos/{g,o}.dump
v2 @77:15  | constant 12'h380 p=func_call ts=<bare> | constant 12'h380 p=func_call ts=<bare>   (no DIFF)
```

**LANDING CONDITION**: this patch must be rebased onto ≥ `8633a1e` before it
lands. Landing it on 981f2e3 alone would ship a wrong object.

I also checked the reverse risk — that r10uvm60's new gate might *remove* a ts
that r10earl32's `a1_kind` c12 depends on. It does not: `a1_kind` is **cell-for-
cell identical** between the base build and the rebased build (all 29 rows, 6
diffs, same 6). c12 (@70:19) keeps its correct `ref_typespec(work@k32a.outer)`
in both.

*Commands*: `./arm32.sh v2_pos.sv` on `r10earl32v` and on `r10earl32vr`;
`cells32.py` on each.

### F3 — THE DELIVERABLE DOES NOT APPLY TO CURRENT MAIN; THE CONFLICT IS IN EXACTLY THE CODE F2 NEEDS
**Severity: mechanical, but it must not be resolved carelessly.**

```
$ cd <fresh 981f2e3 worktree> && git apply --check /tmp/r10earl32.patch   -> rc=0, clean
$ cd <fresh 8633a1e worktree> && git apply --check /tmp/r10earl32.patch
  error: patch failed: src/ExprEmit.cpp:10543
  error: src/ExprEmit.cpp: patch does not apply
```

The failing hunk is r10earl32's **comment-only** R1 note, whose context lines
(`… constArgBodyEvald60 && !intFormal))` / `(!paramRef || elabParamArgFold) &&`)
are the very lines r10uvm60 rewrote at `@@ -10532,6 +10532,32` and
`@@ -10541,7 +10567,7`. `git apply -3` merges it cleanly (0 conflict markers,
both laws present) and the result builds and measures green, so the resolution
is trivial — but an integrator who resolves it by *dropping* r10earl32's R1 note
loses the measured discriminator, and one who resolves it by *reverting*
uvm60's `constArgBodyEvald60` re-opens F2. Resolve as `-3` does: keep both.

### F4 — AN ELABORATED GENERATE BLOCK DOES NOT FOLD, AND GOLDEN DOES
**Severity: MISS (not a regression), real corpus reach, best next target after R1.**

`a3_ctx` measured the **def-view** generate process (g3 bare / g4 qualified) and
a **nested** generate scope (g5). It never built the ordinary case: a
**top-level elaborated generate body**. I did (`v4_more.sv`):

```
                                   GOLDEN                       OURS (pristine AND patched — IDENTICAL)
30:19  mf  for-generate body   |  constant 12'h380 p=func_call | ref_obj p4::P p=func_call   <== DIFF
30:31  mf  same, BARE          |  ref_obj work@m4gen.gblk.P    | ref_obj work@m4gen.gblk.P       ok
35:19  mf  if-generate body    |  constant 12'h380 p=func_call | ref_obj p4::P p=func_call   <== DIFF
```

A **qualified** `pk::P` call argument inside `for (genvar …) begin … assign …
mf(p4::P)` and inside `if (1) begin … end` keeps the ref on both sides of this
patch. The bare sibling at 30:31 is correct (the gen no-fold laws own it). So
a3 g4's answer — "qualified reads in a generate context fold" — holds for the
**def-view process** and does **not** generalise to the **elaborated generate
cont-assign**, which is the shape every real generate loop in Earlgrey and
BlackParrot is written in. Two of the arm's eleven cells, and the only two the
patch leaves untouched among the qualified reads.

This is the highest-reach unfilled cell I found; it belongs above R3–R7 in the
residue ranking.

*Command*: `./arm32.sh v4_more.sv` on both binaries; `cells32.py` on each.

### F5 — `method_func_call` / `method_task_call` ARE NOT IN THE GATE, AND THE CLASS CELL IS MEASURABLE AFTER ALL
**Severity: pre-existing residue; corrects §3.2 c9's "UNMEASURABLE".**

```
84:15  new  method_func_call  | constant 12'h380 p=method_func_call | constant 12'h380 p=<none>  <== DIFF
85:16  cm   method_func_call  | constant 12'h380 p=method_func_call | constant 12'h380 p=<none>  <== DIFF
```

Identical before and after — pre-existing, the same class as R7. But `a1_kind`
c9 recorded the class-method cell as **UNMEASURABLE** because it used a *static*
method (`kc::sm(...)`, which Surelog does not emit as a call). A **non-static**
method call and a **constructor** call both produce a real `method_func_call`
with a folded constant argument, and golden parents that constant **at the
call**. So the cell is measurable, golden's policy there is the same as for
`func_call`, and the stated law's call-kind list ("func_call/task_call") is
narrower than golden's. Nothing regressed; the gate simply does not reach two
call kinds where the same parenting rule applies.

### F6 — THE LAW GENERALISES CLEANLY EVERYWHERE ELSE I COULD TAKE IT (no defect)
Recorded because a verifier that only reports faults mis-prices the pass. Every
one of these is a cell the implementer's grid does not contain, and every one is
**exact** (kind, span, `vpiParent`) after the patch and **wrong** (a `ref_obj`)
before it:

| new cell | file | result |
|---|---|---|
| NAMED argument `mf(.v(pk::P))` | v2 @35:60 | **exact, ts bare like golden** |
| a DEFAULTED formal skipped at the call | v2 @38:18 | exact (ts = R1) |
| a call in a FUNCTION's DEFAULT ARGUMENT | v2 @37:21 | exact (ts = R1) |
| `initial` block | v2 @44:13 | **exact** |
| `always_ff` | v2 @47:14 | **exact** |
| a FOR-loop body | v2 @52:20 | **exact** |
| a CASE selector | v2 @55:14 | **exact** |
| an immediate `assert` | v2 @61:16 | **exact** |
| a `const ref` formal (control) | v2 @66:14 | ref both sides, unchanged ✓ |
| inside an **INTERFACE** | v4 @46:18 | **exact** (was a ref) |
| init = TERNARY | v4 @52:17 | folds; only R3 encoding (`12'h381` vs `897`) |
| init = `$clog2()` | v4 @53:17 | **exact value 9** |
| init = unsized `'1` | v4 @54:17 | **exact value 4095** |
| `int unsigned` parameter | v4 @55:17 | **exact value 7** |
| init = param-of-own-package | v4 @56:17 | **exact, decompile matches** |
| init = CROSS-PACKAGE chain | v4 @57:17 | folds; only R3 encoding |
| `-disable-feature=parametersubstitution` | v3 x1/x2 | **both exact**; golden folds under the flag too and the `noParamSubst` fall-through arm is not reached |

The `v3` result matters on its own: the fall-through now passes a call argument
through three arms that each return a differently-shaped `ref_obj`
(`pkgElabSymOperands`, `noParamSubst && paramSubstRefused`, the
`patParamNoFold` arm). I built the only one of the three that a corpus mode can
switch on (`parametersubstitution` is one of the two `IMPLEMENTED_FEATURES` at
`scripts/verify_golden.py:269`) and it does not fire. No hidden ref-shape change.

---

## 5. RANKED RESIDUES (mine, merged with the implementer's)

1. **R1 (implementer) — the FORMAL's typespec on a folded actual.** 14 measured
   cells, plus 5 of my own (`v2` @37/@38, `v4` @52–@57 partially, `a1` 48/50/86/87/99).
   Discriminator already measured; still the highest-value next arm.
2. **F4 — the ELABORATED GENERATE BODY does not fold a qualified pkg-param call
   argument.** Two cells; the shape that dominates real RTL. *I rank this above
   the implementer's R3–R7.*
3. **R2 — the row's new head**, `flash_ctrl.sv:315` `hier_path
   (region_cfgs[8].base.q)`. Confirmed by my own `uhdm-cmp` run.
4. **R3 — decompile encoding of a folded param whose init is not a literal.**
   Confirmed independently on two *new* shapes (ternary init `12'h381` vs `897`;
   cross-package chain `12'h380` vs `896`) — and note that an *arithmetic* init
   (`P + 12'h1`) matches golden exactly, so the discriminator is finer than
   "non-literal init".
5. **F1 — escaped identifier containing `::` mis-parents the folded constant.**
   Byte residue, 0 corpus reach, but a stated-gate defect under the standing law.
6. **F5 / R7 — `vpiParent` on `method_func_call` and `sys_func_call` folded
   arguments.** Pre-existing, wide, cheap.
7. **R4** cross-package package-init call argument (doubled `c32b::c32::P`),
   **R5** escaped-identifier span, **R6** value kinds the fold cannot express
   (unknown bits, string, real, struct literal). All confirmed as declared.

---

## 6. WHAT I COULD NOT VERIFY

* The implementer's report of a **flake** (`AssignBitsCallToSubmoduleParameter` /
  `AssignSizeOfVar` reported `SLANG_REJECT` under four concurrent sweeps). I ran
  every sweep serially and never saw it; both tests are `CMP_EQUAL` in all four
  of my sweeps. The flake is neither confirmed nor contradicted — recorded as the
  implementer recorded it.
* `a4_text`'s **escaped PACKAGE name** cell, recorded as UNMEASURABLE (Surelog
  aborts). I did not re-attempt it.

---

## 7. VERDICT

**PASS.** The law is real, the gate in the code is the gate in the README, the
blast radius is one database and eight objects, and every one of those objects
lands on golden one-for-one in both directions. Twenty-one cells I built from
scratch — across call kinds, argument positions, procedural containers,
interfaces, generate blocks, initialiser shapes and a feature flag — moved toward
golden or did not move at all. Not one moved away.

**Land it, with two conditions:**

1. **Rebase onto ≥ `8633a1e` (F2/F3)** — `git apply -3` and keep both laws. On
   981f2e3 alone the pass ships a wrong `ref_typespec` in class-method bodies;
   r10uvm60 already fixes it, and the rebased build is green on every arm.
2. **Record F1 and F4 in the residue list** before the next pass picks this
   position up. F4 in particular is worth more than three of the residues that
   are ranked above it in the implementer's README.

*Sweep workdirs (`/tmp/e32vsweep/wd_*`), dump scratch (`/tmp/e32cen`) and all arm
scratch dirs were deleted after measurement.*
