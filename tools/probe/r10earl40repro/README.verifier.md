# r10earl40 — ADVERSARIAL VERIFIER RECORD (§ pkgScopedMultiSelVarSelect40)

**This file is THIS pass's and was written by the INDEPENDENT VERIFIER.** It
REPLACES the `README.verifier.md` the implementer shipped inside
`/tmp/r10earl40.patch` (that file was an implementer's self-verification and
said so; a verifier README authored by the implementer is not a verifier
README). Nothing was carried forward from any earlier pass.

**VERDICT: PARTIAL.**

* The **head IS cleared** — proven three independent ways, one of which does not
  depend on `uhdm-cmp`'s walk order at all.
* **All five gates are GREEN**, re-run from my own worktrees and my own builds.
* **Every headline distance number reproduces to the unit**, and my independent
  builds are **bit-identical** to the implementer's.
* PARTIAL because **two headline claims in the write-up are measurably FALSE**
  (F1, F2) and the new code **mints two latent defects that no shipped cell
  covers** (F3, F4). None of the four blocks a gate; all four are cheap to fix.

---

## 0. WHAT I BUILT AND RAN (nothing inherited)

```
worktree          base                                       md5(build/slang-uhdm)
/tmp/wt_v40pris   06d0fcde21386b7a1b0de9615d951613cbd4e85c   bbee9562c6a92d50d76199f32bf20f22   git status clean
/tmp/wt_v40       06d0fcde21386b7a1b0de9615d951613cbd4e85c   cec108c6e20de62bf9cb090c41d59ba6   + /tmp/r10earl40.patch
/tmp/wt_v40head   6e1c27a49fe723402fba356e7c6cc373306b29e2   f7c66c560e321105021f9a000fa41e43   + /tmp/r10earl40.patch
```

`grep -c 'Built target slang_uhdm$'` = 1 and `grep -icE 'error:'` = 0 on all
three. Every harness run below PRINTS the md5 of the binary it used.

**The build is reproducible: my `06d0fcd`+patch md5 `cec108c6…` and my pristine
`bbee9562…` are BIT-IDENTICAL to the implementer's reported values.** That is
the strongest possible answer to "did you measure the binary you think you
measured", and it also confirms the baseline: `bbee9562…` is what r10earl39
recorded as its own PATCHED md5, and `06d0fcd` is earl39.

---

## 1. THE HEAD — CLEARED (reproduced)

```
earl40.sh, Earlgrey_0_1 default, golden = the immutable cache
  PRISTINE  CMP_NOTEQUAL  cmp heads=1 lines=100   o.dump 4655093
  PATCHED   CMP_NOTEQUAL  cmp heads=1 lines=154   o.dump 4655201   (+108)
```

1. **`prim_prince` = 0 and `PRINCE` = 0** in the patched `cmp.log` (8 and 28 in
   the pristine one). The new head is `operation @13:59-18:4` under a
   `param_assign` — a different construct in a different file. The shipped
   witness `r6_nexthead.cmp` is **byte-identical** to my patched `cmp.log`.
2. **Census, span-keyed, both 4.8M/4.6M-line dumps**: our pasted-text `ref_obj`
   population **2 → 0**, at exactly `prim_prince` `106:29-106:82` and
   `142:30-142:100`, with `var_select` on golden's side at both.
3. **Order-independent**: a direct golden-vs-ours SUBTREE diff at `106:29` (does
   not use cmp at all). `vpiName`, the `vpiIndex` `ref_obj k` **with its full
   `work@prim_prince.gen_fwd_pass.prim_cipher_pkg::PRINCE_ROUND_CONST.k`
   string**, `vpiDefName`, `vpiConstantSelect:1`, `vpiOpType:11`, the DOUBLED
   `DataWidth` ref and both constants all match character for character. The
   only deltas are the `var_select`/`part_select` header display strings and
   **two extra `|vpiFullName:` FIELD LINES that golden does not print at all**
   (residue R2 — see F2).

The 100→154 growth is head depth, as stated. Every instrument that is a
distance moves the right way.

---

## 2. EVERY NUMBER, RE-DERIVED

| claim | reported | I measured | |
|---|---|---|---|
| dump diff | 2 hunks / 4 removed / 112 added / net +108 | 2 / 4 / 112 / +108 | ✅ |
| the 4 REMOVED lines | the two predicted objects only | the two `ref_obj` headers + their two `vpiName` lines, nothing else | ✅ |
| msdist pristine | 308941 (g-only 238648, o-only 70293) | identical | ✅ |
| msdist patched | 308889 (g-only 238568, o-only 70321) | identical | ✅ |
| improvement | −52 | −52 | ✅ |
| shapes changed | 67 | 67 | ✅ |
| per-shape closure | ΣΙg−oΙ 2644, ΣΙg−pΙ 2592, diff **52** | 2644 / 2592 / **52** | ✅ closes to the unit |
| exact parity | 35 / 67 | 35 / 67 | ✅ |
| shapes moving away | 17 | 17, all at positions where **golden has 0** or we already had a surplus | ✅ (split mis-stated — F7) |
| load-bearing counts | `vpiConstantSelect:1` 263→265 (g 265), `vpiLeftRange:`/`vpiRightRange:` 166→168 (g 168), `vpiOpType:11` 222→225 (g 225), `vpiName:DataWidth` 5→7 (g 7) | all four, **all reach golden parity** | ✅ |
| R1 population | var_select 66/30, part_select 110/84, ref_obj 860/845 | identical on the PATCHED side (pristine is 24 / 78 / 840) | ✅ |

---

## 3. THE FIVE GATES, INDEPENDENTLY

**GATE 1 — BUILD.** Absolute paths, link line waited for, md5 taken in a
separate step, 32 hex, different between binaries, pristine worktree clean at
`06d0fcd`. Plus a THIRD build at current HEAD `6e1c27a` (F0 below). **GREEN.**

**GATE 2 — GOLDENS.** `tests/check_goldens.sh` with `SLANG_UHDM` exported:
**23 PASS / 0 FAIL patched**, **23 PASS / 0 FAIL pristine**, negative control
`SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL**. **GREEN.**

**GATE 3 — uhdm2rtlil**, `--mode both --jobs 2`, own `--out`/`--workdir`,
`GOLDEN_DEFER` unset:
```
default   CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2
testflags CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2
dump (testflags)  496 match / 183 differ / 52 blank
ct8rows vs results/gate_uhdm2rtlil.csv (testflags projection, 731 vs 731): 0 ROWS, 0 row-sides
patched CSV == pristine CSV, byte for byte
```
**GREEN.**

**GATE 4 — surelog**, both modes, `--jobs 2`, the two sweeps run **strictly
sequentially** so the documented `SURELOG_FAIL` detail-row race cannot fire:
```
default   469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED
testflags 465 CMP_EQUAL /  8 CMP_NOTEQUAL / 23 SURELOG_FAIL / 5 DEFERRED
ct8rows vs results/golden_surelog.csv (1588 vs 1588): 0 ROWS, 0 row-sides
dump histograms UNCHANGED: default 325/244/225, testflags 329/300/165
patched CSV == pristine CSV, byte for byte
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,            == baseline
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,, == baseline
```
The target's ROW does not move; its BYTES do. **GREEN.**

**GATE 5 — BYTE VERIFIER**, patched vs the pristine `06d0fcd` **I built**, both
corpora, both modes, both mandatory controls:
```
uhdm2rtlil  1358 == 1358  PATH_SETS_IDENTICAL  MOVERS 0 / 1358
            SELFCHECK=1 -> 1357/1358    SELFCHECK1=1 -> 1
surelog      953 ==  953  PATH_SETS_IDENTICAL  MOVERS 2 /  953
  MOVER ./default/Earlgrey_0_1-71da2fd7  size 49940463 vs 49938801  -> +1662  REAL
  MOVER ./default/Scoreboard-59431470    size 11122522 vs 11122522  -> SAME   flake?
            SELFCHECK=1 ->  952/953     SELFCHECK1=1 -> 3 (1 corrupted + 2 movers)
```

**Scoreboard arbitrated harder than asked, with 4 reps of the UNMODIFIED
PRISTINE binary:**
```
rep1 8efa3d8a2906fbf1423ab22961840118   11122522
rep2 8debd9be587250b612576ad452fb918d   11122522
rep3 c7d29a6824a9f65a503d2ea24912eecf   11122522
rep4 8efa3d8a2906fbf1423ab22961840118   11122522
```
Three distinct md5s at a constant size from one unmodified binary — and the set
`{8efa3d8a, 8debd9be, c7d29a68}` is EXACTLY the implementer's. **A stronger
independent proof fell out of my run:** my byte verifier printed
`patched=8debd9be5872 pristine=4fb87c934262` where the implementer's printed
`patched=4fb87c934262 pristine=8debd9be5872` — **the same two digests with the
sides swapped**, which no real mover can do. Scoreboard is the documented
emitter nondeterminism. **One real mover in 2311 databases, and it is the named
target. GREEN.**

---

## 4. CANARIES AND FENCES

```
canaries.sh  u2r (testflags projection) : ok=8  changed=0 absent=0 unknown=25
canaries.sh  SL                         : ok=52 changed=0 absent=0 unknown=7
ctcan2.sh    u2r EXPECT_UNKNOWN=6       : ok=1  changed=0 absent=0 unknown=6   PASS
ctcan2.sh    SL  EXPECT_UNKNOWN=1       : ok=58 changed=0 absent=0 unknown=1   PASS
canaudit.sh                             : audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS
```
(Feeding the *both-modes* u2r CSV against the *testflags-only* baseline prints
`absent=8` / `absent=1` and `FAIL`; that is an input-projection artifact of
mine, not a mover. With the projection the numbers are the implementer's
exactly.)

**PROTECTED genscope canaries, BY NAME in my fresh CSV — all byte-identical to
`results/gate_uhdm2rtlil.csv`:** `gen_test9`, `genvar_loop_decl_2`,
`genvar_loop_decl_3`, `paramod_genscope_child`, `genscope_cells`. **Adjacency:**
`indexed_partsel_array` and `gen_test4` and `EnumConcat` identical.
**BY NAME per corpus:** `InterfaceModPort` and `BlackParrotComplex` — 2 rows
each in `golden_surelog.csv`, identical; 0 rows in `gate_uhdm2rtlil.csv`
(vacuous there, stated).

**The three fenced boundary arms, run with BOTH binaries:**
```
r10earl38 a1_chain  § genChainBranchScopeThreads38   PASS_CMP both, DUMP_DIFF 178/10 both
r10earl38 a2_fence  earl38 residue R3                17/17 both,   DUMP_DIFF 989/68 both
r10earl39 a1_argts  § defGenProcArgNoFormalTs39      17/17 both,   DUMP_DIFF 306/21 both  == earl39's value
```
`o.dump` **byte-identical** between the two binaries for all three after workdir
normalisation, and `cmp.log` identical for all three. § genScopeBareArgKeepsRef33,
§ hpMixedIdxPkgFold34, § genChainBranchScopeThreads38 and
§ defGenProcArgNoFormalTs39 all hold.

**Live-pass collision:** `r10uvm68` (`a5d5533`) touches `EmitHelpers.h`,
`ModuleEmit.cpp`, `StmtEmit.cpp`, `TaskFuncEmit.cpp` — no overlap.
`r10sd1` (`6e1c27a`) touches **`include/UhdmExporter.h`, the same file** — but a
disjoint region; `git apply --check` is clean on HEAD, and F0 below builds and
runs it. `results/` is untouched (`git status --porcelain results/` = 0 lines).
**NO COLLISION.**

---

## 5. NUMBERED FINDINGS

### F0 (positive) — HEAD apply is real, not `--check`-deep
`git apply` to a fresh `6e1c27a` worktree, full build (**0 errors**, md5
`f7c66c560e321105021f9a000fa41e43`), Earlgrey re-run: `cmp heads=1 lines=154`,
`prim_prince` = **0**. Same first line of `cmp.log` as the `06d0fcd` build.
```
git worktree add --detach /tmp/wt_v40head 6e1c27a && cd /tmp/wt_v40head && git apply /tmp/r10earl40.patch
SLANG_UHDM=/tmp/wt_v40head/build/slang-uhdm ./earl40.sh /tmp/v40scratch/head --nodump
```

### F0b (positive) — the OVER-FIRE HUNT came back clean where it matters
My own probe (`v40_overfire.sv`, not shipped by the implementer) crosses the
three axes the new gate could mis-claim. Run with both binaries through
`arm40.sh` + `cells40.py`:

| probe cell | shape | pris→pat | verdict |
|---|---|---|---|
| `c_dot` | `u_if.arr[g][DW-1:0]` — **DOTTED hierarchical base**, 2 selectors | **UNCHANGED**, `HOLD-OK` vs golden | **NO OVER-FIRE.** The new gate sits inside the pre-existing `parts.size() < 2 && raw.find("::") != npos` guard, so a name containing `.` can never reach it. This is the one over-fire I predicted from reading the code (`raw.find('[')` would have sliced `blk` out of `blk[0].sub.x[i][j]`) and it is structurally impossible. |
| `c_nest` | `q40::A[q40::B[g][1:0]][DW-1:0]` — a qualified multi-select **inside an index** | ref_obj → `var_select`, inner index gets its **OWN** base `q40::B` | the consume-on-entry `swap` discipline is now **MEASURED**, not just asserted in a comment |
| `c_three` | `q40::C[g][1][DW-1:0]` — **three** selectors | ref_obj → `var_select`, 3 `vpiIndex`, kind == golden's | scope generalises past two |
| `c_locidx` | bare local base (control) | `HOLD-OK` | control fires |

### F1 — **MATERIAL / REPORTING.** The grid's `MOVED` is **0**, not 11.
The report says "**11 structure movers** … **9 HOLD-OK, 0 REGRESSED**". Those
last two numbers are quoted verbatim from `grid40.py`'s TOTALS line. That same
line reads:
```
TOTALS: cells=51 MOVED=0 HOLD-OK=9 REGRESSED=0 STILL-DIFF=42
```
`grid40.py` defines `MOVED` as *golden == patched*. **ZERO arm cells reach
golden**, because in every moved cell our `var_select`/`part_select` carries a
`vpiFullName` golden does not have and (in ELAB) a bare base name. Substituting
a hand count for `MOVED` while quoting `HOLD-OK`/`REGRESSED` from the same
printed line reads as "11 cells now match golden", which is false.
What is TRUE and what the landing message should say instead:
* **11 grid ROWS changed** pristine→patched, all in the DEF view;
* of those, **9 changed KIND** `ref_obj` → `var_select`, and in all 9 the
  patched KIND equals golden's KIND;
* the other **2** (`c_gca_pkg_bk_rlit`, `c_gca_pkg_blit_rlit`) changed *inside*
  a concat, so the row's top-level kind stays `operation`;
* **9 HOLD-OK, 0 REGRESSED, 42 STILL-DIFF** — those are correct.
```
python3 grid40.py g.cells o.cells p.cells | tail -1
```

### F2 — **MATERIAL / REFUTATION.** "Storing nothing reproduces both" is FALSE on the very cell cited as the counter-example.
§ 3 of the README refutes the brief by pointing at two cells of identical source
shape and claiming both are reproduced by storing nothing. The Earlgrey cell is
(I verified it character for character). **The arm cell is not.** At
`a1_sel40.sv:76:32` — the arm's exact twin of the head:
```
GOLDEN  var_select{vpiName=p40::ARR40}                                   <- NO vpiFullName at all
          vpiIndex=ref_obj{vpiName=k, vpiFullName=p40::ARR40::p40::ARR40::k}
          ...vpiOperand=ref_obj{vpiName=DataWidth, vpiFullName=p40::ARR40::p40::ARR40::p40::ARR40::DataWidth}
OURS    var_select{vpiName=p40::ARR40, vpiFullName=work@a1_sel40.gen_f40.p40::ARR40}
          vpiIndex=ref_obj{vpiName=k, vpiFullName=work@a1_sel40.gen_f40.p40::ARR40.k}
          ...vpiOperand=ref_obj{vpiName=DataWidth, vpiFullName=work@a1_sel40.gen_f40.p40::ARR40.p40::ARR40.DataWidth}
```
Different scope, different separator, and golden prints **no `vpiFullName` line
at all** on the `var_select`/`part_select` while we print one. So the brief's
"select-scoped `::`" convention is REAL and is **still unreproduced**; what is
refuted is only the narrower instruction to *transcribe a literal string* (that
would indeed have hard-coded the wrong one for Earlgrey). The honest headline
is: **storing nothing reproduces the EARLGREY parent chain; the arm's
`::`-joined chain is NOT reproduced and is the true, generalised residue R2.**
Design-wide this is visible as `var_select ::=1` golden 66 / ours 30 and
`part_select ::=1` golden 110 / ours 84 — the same 66-object class the head
belongs to.
```
grep -E '^c_gca_pkg_bk_rsym +DEF' g.cells p.cells
```

### F3 — **NEW DEFECT (latent).** Source whitespace leaks into `vpiName`.
`qualSelBase40 = raw.substr(0, lb40)` slices the **written source text**, so any
whitespace between the qualified base and its first selector becomes part of the
identifier. Probe `c_ws`, `q40::A [g] [DW-1:0]`:
```
|vpiName:q40::A                                     <- TRAILING SPACE
\_var_select: (work@v40_overfire.gb.q40::A ), line:26:19, endln:26:38
  |vpiFullName:work@v40_overfire.gb.q40::A .g       <- and it propagates to every child
golden: q40::A
```
Zero occurrences in Earlgrey (both target spans are whitespace-free) and no gate
moves, so this is latent — but it is a *new* malformed identifier the patch
mints, and a1_sel40's 30 cells contain no whitespace axis so nothing shipped
covers it. One-line fix: right-trim, or better, build the base from the LEFT
node's text plus `isn40->identifier.valueText()` instead of slicing `raw`.
```
SLANG_UHDM=<pat> ./arm40.sh v40_overfire.sv <wd> ; grep -n 'vpiName:q40::A ' <wd>/o.dump
```

### F4 — **NEW DEFECT (latent).** The ABSTAIN path leaks ORPHANS into the database.
The report says the `+:`/`-:` abstention leaves "an unchanged wrong object,
never a half-built one". That is true of the returned TREE and false of the
SERIALIZED BYTES: the delegate creates `var_select` + `exprVec` + index children
and only *then* returns `nullptr` on the indexed-range selector; those objects
stay in the arena and are written to the `.uhdm`. Minimal probe (`v40_orphan.sv`,
one cell, `r40::A[g][DW-1 -: 4]`):
```
pristine  slang.uhdm 12569 bytes    o.dump 1228 lines   var_select 3
patched   slang.uhdm 12701 bytes    o.dump 1228 lines   var_select 3     -> +132 bytes, DUMP IDENTICAL
bare-base control (locv[g][DW-1 -: 4]) : 13625 vs 13622 = the 3-byte workdir-path delta only
```
Invisible to `uhdm-dump` and to `uhdm-cmp`; visible to `byteverify.sh` — which
is exactly the instrument that will attribute it to whichever pass runs next.
No corpus test hits the shape (byte verifier: 1 real mover in 2311). Fix with
the rest of R3 by extending the selector loop, or by pre-checking the selector
kinds before minting `vs`.

### F5 — **INSTRUMENT.** `cells40.py`'s view key misses top-level gen-ifs.
`view = 'ELAB' if re.search(r'\[\d+\]', full) else 'DEF'` only detects gen-**for**
elaboration. A top-level `gen_t40` block's def listing and its elaborated scope
collapse onto ONE `DEF` row — visible as two signatures on a single row for
`c_gift_pkg_blit_rsym` and `c_gift_pkg_nosel`. This is precisely the collapse
the file's own docstring names as "r10earl32's own instrument defect".

### F6 — **DOC.** `census40.py`: "Golden never writes such a name" is false.
Golden writes **10** `ref_obj` whose `vpiName` contains both `::` and `[` — the
elaborated index refs at `prim_prince` `106:65` and `142:83`, where the `[` comes
from `gen_fwd_pass[1]` in the *fullname*, not from a select. The filter is a
heuristic that happens to be exact on OUR side only. It does not weaken the
census (golden's kind at our two spans really is `var_select`, checked), but the
shape-tally row `ref_obj ::=1 [=1` goes 10/2 → 10/0, i.e. that row's deficit
*grows*, and the write-up does not say so.

### F7 — **DOC.** The 17 "away" shapes split 12 / 5, not 13 / 4.
`|vpiConstType:9` appears at TWO indents and both moved. R2 display names = 12,
anonymous design-wide labels = 5. Total 17 is right, and the substantive claim
("no line moved away at a position where golden has one") **holds**: all 12 R2
shapes have golden count 0, and all 5 anonymous ones were already in surplus
before the patch.

### F8 — **DOC.** § 2a's table.
"11 cells change kind from the pasted-text `ref_obj` to golden's `var_select`" —
9 change kind (see F1). Two rows in that same 11-row table
(`c_gca_pkg_bidx`, `c_gca_pkg_bidxa`) did not change at all; they are correctly
labelled ABSTAINED in the verdict column but are still counted in the "11".

---

## 6. EMPTY PRODUCT CELLS — HUNTED, NONE FOUND

All **30 declared `c_*` cells** in `a1_sel40.sv` produce at least one grid row,
and **0 of the 51 rows** are missing from any of the three sides (golden /
pristine / patched). No cell is silently absent, so no "HOLD-OK" in this grid is
vacuous.
```
declared cells 30 ; cells with >=1 row 30 ; declared-but-no-row NONE ; row-but-not-declared NONE
rows where a side produced NOTHING: 0
```
The gap in the grid is not an empty cell, it is a **missing axis**: source
whitespace (F3) and the abstain path's arena cost (F4).

---

## 7. RANKED RESIDUES (verifier's ranking)

1. **R1 — the ELABORATED twin names the base BARE** (`emitExpr`). Confirmed:
   `var_select` 66/30, `part_select` 110/84, `ref_obj` 860/845 on the patched
   side. The other half of this head's own family; correctly top-ranked.
2. **R2 (restated per F2) — the whole select-scope NAMING law is unreproduced,
   not just "two display lines".** Golden stores *no* `vpiFullName` on a
   qualified `var_select`/`part_select` and joins its index refs with `::`
   through the select base; we print a computed `work@…`-joined one. `uhdm-cmp`
   does not compare it — the head is genuinely cleared — but `msdist` does, and
   12 of the 17 away-shapes are this.
3. **F3 — whitespace leak into `vpiName`.** One-line fix; do it before it
   reaches a corpus test.
4. **F4 — orphan objects serialized on the abstain path.** Fold into R3.
5. **R3 — `+:`/`-:` on a package base abstains.** Confirmed at
   `c_gca_pkg_bidx`/`bidxa`; absent from Earlgrey.
6. **R4 — single-selector package select**, golden anchors AT THE SELECTOR
   (`a1_sel40` 95:43-95:44, 99:42-99:45). Confirmed; zero Earlgrey occurrences,
   so the law's "two or more selectors" boundary is genuinely MEASURED.
7. **R5 — golden constant-folds package-param selects in the elaborated view.**
   Confirmed at `c_gca_pkg_bonly_k`/`bonly_lit`/`ronly`.
8. **R6 — the new head**: operand reordering in a `param_assign` concat at
   `13:59-18:4`. The shipped `r6_nexthead.cmp` is byte-identical to my run.

---

## 8. WHAT MUST CHANGE BEFORE LANDING

1. Correct the grid sentence (F1): say **"11 rows changed, 9 changed kind to
   golden's, 9 HOLD-OK, 0 REGRESSED, 0 reach golden"** — never "11 movers"
   alongside a `MOVED=0` TOTALS line.
2. Correct the refutation (F2): the brief's `::` convention is real and
   unreproduced; only "transcribe a literal string" is refuted.
3. Fix or record F3 (trailing whitespace in the minted base name).
4. Record F4 in R3 (the abstain path serializes orphans).

None of these is a gate failure. The patch is landable once the write-up stops
claiming more than it measured.

---

*Verifier worktrees `/tmp/wt_v40`, `/tmp/wt_v40pris`, `/tmp/wt_v40head`;
scratch `/tmp/v40scratch`. Sweep workdirs `/tmp/v40_wd_*` deleted after the byte
verifier ran. `results/*.csv` read-only throughout; no `git stash` was run.*
