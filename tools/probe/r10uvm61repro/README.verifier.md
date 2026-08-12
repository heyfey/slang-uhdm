# r10uvm61 — ADVERSARIAL VERIFIER — **VERDICT: PARTIAL**

**Every number in the implementer's report reproduces exactly**, on binaries I
built myself from the patch whose md5 I verified before use — and both my
binaries are **byte-identical to theirs**. All five gates are green. The head is
genuinely CLEARED on all three target rows and the alarming `42 → 20402` is
genuinely not a regression; I proved that independently rather than accepting the
argument.

**But the stated LAW is REFUTED in one direction by FIVE cells across two arms
the grid never built, and every one of them is an OVER-FIRE** — a wrong constant
where golden *and the pristine binary* both keep the `sys_func_call`. Corpus
price of all five: **ZERO objects across 1 632 databases**, measured with an
instrument whose positive control fires. That is why this is **PARTIAL** — land
it, correct the law next — and not FAIL.

Base **8633a1e**. My worktrees: `.claude/worktrees/r10uvm61vv` (patched),
`.claude/worktrees/r10uvm61vpris` (pristine control),
`.claude/worktrees/r10uvm61vmain` (current main + patch, rebase check). All
`git rev-parse HEAD` printed and checked.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| binary | md5 | mine == implementer's? |
|---|---|---|
| CONTROL pristine 8633a1e | `29223f08cef6b087c932fb9b30a40bba` | **YES** |
| FINAL patched 8633a1e | `e8e672f8151fa7732b08168e6df91811` | **YES** |
| current main `a060719` + patch | `df5eb47eeba811fc5632ba5fcf3b07dd` | (not reported by implementer) |

`git stash` never used. `results/*.csv` READ ONLY. `GOLDEN_DEFER` **UNSET**
(5 DEFERRED both modes, as in baseline). The four slang-fenced tests never
dispatched (`canaudit.sh` FENCE-BREACH=0).

---

## 1. EVERY NUMBER, REPRODUCED INDEPENDENTLY

| gate | implementer | **mine** | command |
|---|---|---|---|
| 1 BUILD | link 1 / errors 0 | **rc 0, link 1, errors 0**, both worktrees | `cmake --build build -j 6` |
| 1 md5 | CONTROL `29223f08…`, FINAL `e8e672f8…` | **identical**, asserted in a SEPARATE command, baseline validated 32-hex first | `md5sum …/r10uvm61v{v,pris}/build/slang-uhdm` |
| 1 determinism | 3 runs / 1 hash `83a76e7a…` | **3 runs / 1 hash `83a76e7a569a4951`, 0 NO_OUTPUT** | `detcheck.sh <final> 3 <SimpleUVM argv>` |
| 2 GOLDENS | 23/0 | **rc 0, PASS=23, FAIL=0** | `SLANG_UHDM=<final> ./tests/check_goldens.sh` |
| 2 negative | `/bin/false` 0/23 | **rc 1, PASS=0, FAIL=23** | same, `SLANG_UHDM=/bin/false` |
| 3 u2r testflags | 679/50/2 | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** | `verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2` |
| 3 dump | 496/183/52 | **496 match / 183 differ / 52 blank** | `ct8rows.sh results/gate_uhdm2rtlil.csv` |
| 3 rows | 0 rows | **0 differing ROWS (0 diff row-sides)**; my **PRISTINE** sweep also reproduces the baseline at **0 rows** | `ct8rows.sh` on both CSVs |
| 4 surelog default | 467/13/5/284/25 | **467 / 13 / 5 / 284 / 25** | `verify_golden.py --corpus surelog --mode both --jobs 2` |
| 4 surelog testflags | 463/10/5/286/23 (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM) | **identical, every bucket** | same sweep |
| 4 dump | 225/165 match | **default 225/242/327; testflags 165/298/331** | `ct8rows.sh results/golden_surelog.csv` |
| 4 rows | 0 rows, no conversion | **0 differing ROWS**, pristine sweep likewise; **no conversion** | `ct8rows.sh` |
| 5 u2r bytes | 0/679, SELFCHECK 678/679, SELFCHECK1 1 | **0 / 679 / 678 / 1** | `SELFCHECK=1 SELFCHECK1=1 byteverify.sh` |
| 5 surelog bytes | 7/953, SELFCHECK 952/953, SELFCHECK1 8 | **7 / 953 / 952 / 8, and the SAME seven names** | same |
| 5 per-shape | msdist all IMPROVED, ADDED/REMOVED 190/372 & 220/432, UNATTRIB 0 | **identical on all 7 movers**, every figure | `mv61.sh` |
| heads | 42→20402 ×3, 85→85, 58→58, Scoreboard/testflags SKIP-NOFILE | **all seven rows identical, both binaries measured** | `rowheads.sh` |
| head identity | pristine = briefed `constant @145:55`, patched = `class_defn (uvm_set_get_dap_base)` | **confirmed on all three rows, both binaries** | `head -6 <row>.cmp` |
| census | golden 28 / pristine 54 / final 17 sites, 37 movers | **28 / 54 / 17 / 37 exactly**, by distinct `$bits` SPAN | my own span census |
| c-arm msdist | c1 151→31, c2 53→53, c3 39→30, c4 394→188 | **151→31, 53→53, 39→30, 394→188**, c5 340→325 | `msdist.sh` per arm |
| c2 control | dump byte-identical pris↔pat | **`cmp -s` IDENTICAL** | `cmp -s c2_context_{pris,pat}/o.dump` |
| canaudit | 29 / 0 / 0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0** | `canaudit.sh ./canaries.sh ./ctcan2.sh` |
| ctcan2 | u2r ok=1/6, sl ok=58/1 | **identical, changed=0 absent=0 both** | `EXPECT_UNKNOWN=6/1 ctcan2.sh` |
| canaries | sl 52 ok /7 unknown, u2r 8 ok /25 unknown | **identical** | `canaries.sh` |
| by name | InterfaceModPort, BlackParrotComplex ×2 modes | **`CMP_EQUAL,,,differ` ×4, byte-equal to committed baseline** | `grep -E "^(InterfaceModPort\|BlackParrotComplex),"` |
| hygiene | 2 files, +256/−1, TaskFuncEmit 0 lines, 22 grep hits | **2 files, +256/−1, TaskFuncEmit.cpp 0 diff lines, 22 hits / 2 files, 0 added lines matching `VpiConstType\|covergroup\|clocking`** | `git diff 8633a1e --stat`, greps |

**Binary provenance, grep-checked out of each sweep's own `cmds.txt`:**
`wd_sl_pat` 1523/1523 name `…/r10uvm61vv/build/slang-uhdm`, `wd_sl_pris`
1523/1523 `…/r10uvm61vpris/…`, `wd_u2r_pat` 729/729, `wd_u2r_pris` 729/729.
No cross-contamination.

### 1.1 Two numbers I measured that the report did not

* **The r10uvm60 arms are not merely un-colliding, they are BYTE-IDENTICAL.**
  I ran all **15** arms (`a1`, `b1`–`b7`, `v1`–`v7`) from
  `tools/probe/r10uvm60repro` on my pristine and patched builds. Every one has
  the **same cmp-line count** (0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 151, 36, 0, 64, 0)
  **and our emitted dump is byte-identical between the two binaries on all 15**.
  § tfBodyConstArgNoFormalTs60 / § tfBodyConstArgNeedsEvaldBody60 are untouched
  as behaviour, not just as text.

* **THE REBASE.** Both live passes named in my brief have since **landed on
  main**: `6498102` r10earl32 (§ fcArgPkgParamValueFolds32) and `a060719`
  r10svs7 (§ covergroupNewCall7) — and r10earl32 edits the **same `bitsKeep`
  region** of `emitExpr` (main's `src/ExprEmit.cpp:11319–11369`). The patch
  `git apply --check`s cleanly onto `a060719`, and I built **main + patch**
  (`df5eb47eeba811fc5632ba5fcf3b07dd`, rc 0 / 1 link / 0 errors) and re-measured:
  **goldens 23/0**; arms `c1_scope`, `c4_edge`, `v1_pkgparam`, `v4_type`,
  `v7_pkgts` all **byte-identical** to their 8633a1e+patch dumps; and the three
  target rows still read **20402 / 1 head** with the **same `class_defn
  (uvm_set_get_dap_base)` head identity**. The rebase is behaviourally free.

---

## 2. THE `42 → 20402` STORY — INDEPENDENTLY PROVED, NOT ACCEPTED

The implementer's argument is sound and I did not take it on trust.

* **Head identity, both binaries, all three rows.** Pristine head is the briefed
  `constant: , id:132727/132739/132997, line:145:55, endln:145:70` parented on
  `method_func_call: (print_field_int)`. Patched head is
  `class_defn: (uvm_pkg::uvm_set_get_dap_base) … line:32:9, endln:82:32`.
  **Cleared, not renumbered.**

* **The new head was NOT created by the patch.** Multiset of every dump line
  naming `uvm_set_get_dap_base`, over the id-stripped dumps:

  ```
  SimpleUVM/default   OUR-pristine md5 8896d4ff953a882aff8bc06916c50474   86 lines
                      OUR-patched  md5 8896d4ff953a882aff8bc06916c50474   86 lines
                      GOLDEN                                             86 lines
    multiset distance golden <-> PRISTINE : 22
    multiset distance golden <-> PATCHED  : 22
    multiset distance PRISTINE <-> PATCHED:  0
  ```
  Identical figures for `Scoreboard/default`. **The divergence at the new head
  was already present in the pristine database and was merely masked by the
  briefed head.** (My md5 differs from the implementer's `6f436766…` only
  because mine is taken over the id-stripped dumps; the equality
  pristine == patched, which is the claim, holds either way.)

* **Whole-dump multiset distance to golden IMPROVES** on all seven movers, which
  I re-ran myself (§1).

---

## 3. FINDINGS — the law is REFUTED in one direction by five cells

Every finding below is a cell **the grid never built**, measured on my own
binaries, with golden and the pristine binary as the two controls.

### F1 — OVER-FIRE: a width that depends on a **PACKAGE** parameter folds, and golden keeps it. FOUR cells.

`c4_edge.sv` tests widths that depend on a **class** parameter. It never tests a
**package** parameter. The predicate rejects only class parameters
(`readsClassParam61` walks up from the parameter's own scope and returns `false`
the moment it meets a `Package`), and `r9DimsLiteral`'s inner walk answers
`SymbolKind::Package -> true` ("resolved"). So a package-parameter width sails
straight through the gate.

```
$ arm61.sh v1_pkgparam.sv … ; foldgrid.sh /tmp/v61v/arms/v1_pkgparam_pat
LINE | GOLDEN          | OURS (PATCHED)                    | VERDICT
28   | SYMBOLIC $bits  | CONST val=UINT:6 sz=64 ct=9 ts=-  | DIFFER   <-- OVER-FIRE
29   | SYMBOLIC $bits  | CONST val=UINT:7 sz=64 ct=9 ts=-  | DIFFER   <-- OVER-FIRE
41   | SYMBOLIC $bits  | CONST val=UINT:13 sz=64 ct=9 ts=- | DIFFER   <-- OVER-FIRE
   ... and the PRISTINE binary is SYMBOLIC on all three, i.e. it was RIGHT.
```
Confirmed from the raw dumps, not from `foldgrid`:
```
GOLDEN : \_sys_func_call: ($bits), line:28:11, endln:28:22
           \_ref_obj: (v1_pkg::pk_c::r1::m_pw)
OURS   : \_constant: , line:28:11, endln:28:22   |vpiDecompile:6 |vpiSize:64 |UINT:6 |vpiConstType:9
```

**`v7_pkgts.sv` then sharpens the boundary to a clean, implementable rule.**
Same class, seven properties, only the *spelling* of the width differs:

| line | property | golden | ours (patched) | |
|---|---|---|---|---|
| 27 | `logic [PW-1:0] m_direct` (pkg param, inline) | **KEEPS** | folds UINT:6 | **OVER-FIRE** |
| 28 | `pkg_dep_t m_pkgtd` — **package** typedef of `logic [PW-1:0]` | **FOLDS** UINT:6 | folds UINT:6 | ✓ |
| 29 | `cls_dep_t m_clstd` — **class**-declared typedef of `logic [PW-1:0]` | **KEEPS** | folds UINT:6 | **OVER-FIRE** |
| 30 | `pkg_st_t m_pkgst` — **package** packed struct, pkg-param field | **FOLDS** UINT:8 | folds UINT:8 | ✓ |
| 31 | `logic [PW:0] m_noarith` (no arithmetic) | **KEEPS** | folds UINT:7 | **OVER-FIRE** |
| 32 | `logic [LW-1:0] m_vialp` (via a pkg **localparam** of PW) | **KEEPS** | folds UINT:6 | **OVER-FIRE** |
| 33 | `logic [3:0] m_fix` control | FOLDS UINT:4 | folds UINT:4 | ✓ |

**THE CORRECTED LAW.** Surelog refuses the fold whenever a *parameter name is
reachable from syntax written INSIDE THE CLASS BODY* — the property's own
dimension, or a typedef the class itself declares — **regardless of where that
parameter is declared**. It folds when the width arrives through a type declared
**outside** the class (package typedef, package packed struct), because the
package's typespec is already resolved when the class is compiled. That is the
same `unitResolves` / `bodyResolves` idiom the campaign already uses, with the
axis being **where the SYNTAX lives**, not where the PARAMETER lives — which is
exactly the distinction `readsClassParam61`'s parent-scope walk inverts.

*Concrete fix for the next pass*: in `readsClassParam61`, drop the parent-scope
walk and return `true` for any `Parameter`/`TypeParameter`/`Specparam`; in
`typeReadsClassParam61`, walk **only** alias links whose `getParentScope()` is
inside the class (rows 28/30 prove a package alias must still fold).

### F2 — OVER-FIRE: `time`. ONE cell.

`c4_edge` covers `string` and `real` (both correctly excluded by `isIntegral()`).
It never covers `time`, which **is** integral in slang (64 bits) — so it passes
the gate and we emit a constant golden does not have.

```
$ foldgrid.sh /tmp/v61v/arms/v4_type_pat        # line 47 = `o = $bits(m_tm);`
47 | SYMBOLIC $bits | CONST val=UINT:64 sz=64 ct=9 ts=- | DIFFER   <-- OVER-FIRE
   (PRISTINE: SYMBOLIC — right.  Control line 52, `integer`: golden FOLDS UINT:32, we fold UINT:32 ✓)
$ grep -n "line:47:11" …/v4_type_pat/g.dump
1023:  \_sys_func_call: ($bits), line:47:11, endln:47:22
```

The `v4_type` grid also decodes the **real family**, which corrects residue R3
from "I cannot derive Surelog's 32" to a measured rule:

```
real      -> golden FOLDS UINT:32   (c4 line 115)
shortreal -> golden FOLDS UINT:32   (v4 line 48)
realtime  -> golden KEEPS           (v4 line 49)
time      -> golden KEEPS           (v4 line 47)
```
The two Surelog keeps are exactly the two spellings the LRM defines as aliases
of another type (`realtime`≡`real`, `time`≡`bit[63:0]`) — a testable hypothesis
for whoever implements R3, and the reason R3 is smaller than reported.

### F3 — UNDER-FIRE: two `currentSubSym` contexts. TWO cells (safe direction).

The predicate opens with `if (!currentSubSym) return false;`, and `currentSubSym`
is set/restored only around a subroutine **body** emit
(`src/TaskFuncEmit.cpp:5072/5260`). I built `v3_nonsub.sv` to find both the
leak (an over-fire risk) and the gaps. **There is no leak** — every class-scoped
context that folds does so correctly. Two contexts under-fire:

```
$ foldgrid.sh /tmp/v61v/arms/v3_nonsub_pat 18 20 27 29 37 38 46 48 50 58
18  property initialiser  `int m_init = $bits(m_a);`      golden UINT:5  ours UINT:5   SAME ✓
27  CONSTRAINT block      `m_r < $bits(m_w)`              golden UINT:6  ours UINT:6   SAME ✓
46  unpacked-dim bound    `logic m_arr[$bits(m_v)]`       golden CONST   ours CONST    SAME ✓
58  never-CALLED method                                   golden UINT:8  ours UINT:8   SAME ✓
37  method DEFAULT ARGUMENT `f_d(int x = $bits(m_d))`     golden UINT:7  ours SYMBOLIC DIFFER  <-- under-fire
48  class LOCALPARAM init `localparam int LPB = $bits(m_v);` golden CONST ours SYMBOLIC DIFFER <-- under-fire
```
Under-fires, so strictly safe; filed as R7 below.

### F4 — the `UNATTRIB = 0` column is much weaker than it reads. METHODOLOGY.

`mv61.sh`'s `FOLDRE` is the whole basis of the report's headline claim
("**289 shapes moved, 0 of them unexplainable**"). I measured the measurer:

```
distinct dump-line shapes in SimpleUVM/default patched : 349510
shapes that MATCH FOLDRE (i.e. would score UNATTRIB=0) : 218908   ->  62.63%
```
A regex that "explains" 62.6 % of every line in the database is close to an
unfalsifiable test. It is not *wholly* vacuous — `int_typespec` and `class_defn`
lines match it **0** times, which is what makes it able to distinguish the R1
family — but "0 unattributable" should be read as weak corroboration, not proof.

**So I built the decisive measurement the report is missing** (`ofcensus.py`):
for each side, the set of `$bits` calls **kept symbolic**, keyed by span and
argument fullname; an over-fire is then exactly a key that *golden keeps AND the
pristine binary kept AND the patched binary no longer has*.

```
                     golden   pristine   patched | NEW OVER-FIRES
SimpleUVM/default        56        109        34 |  0
SimpleUVM/testflags      56        109        34 |  0
Scoreboard/default       56        109        34 |  0
SeqDriver/default        70        123        48 |  0
SeqDriver/testflags      70        123        48 |  0
BuildUVMPkg/default     114        128        40 |  0
BuildUVMPkg/testflags   114        128        40 |  0
```
By distinct SPAN, which also corroborates the report's census exactly:
```
SimpleUVM/default : golden=28  pristine-ours=54  patched-ours=17  newly folded=37  over-fires=0
BuildUVMPkg/default: golden=60 pristine-ours=64  patched-ours=20  newly folded=44  over-fires=0
```

**POSITIVE CONTROL for that instrument** — an over-fire census that reports 0
because it cannot see anything is the failure that reads as perfection, so I ran
it on the three arms whose over-fires I already know by hand:

```
arm v1_pkgparam : 3 known over-fires -> census reports m_pw, m_plw, m_ex        ✓
arm v7_pkgts    : 4 known over-fires -> census reports m_direct, m_clstd,
                                        m_noarith, m_vialp                     ✓
arm v4_type     : 1 known over-fire  -> census reports m_tm                     ✓
arm c5_select   : 0 over-fires, 24 under-fires (the R2 family)                  ✓
```
The instrument fires. **The corpus price of F1 + F2 is therefore ZERO objects
across all 1 632 databases — measured, not argued.** That is what makes this
PARTIAL rather than FAIL.

### F5 — the report's own refutations, checked. ALL THREE HOLD.

* **"`$bits` is the only member of the family that folds"** — CONFIRMED on my
  build. `c3_sibling` patched grid: `$size` ×2, `$clog2`, `$high`, `$low`,
  `$left`, `$right`, `$countones`, `$dimensions`, `$unpacked_dimensions`,
  `$increment`, `$isunknown` — **SYMBOLIC on both sides, 11/11 SAME**. The only
  differing cell is line 24, `$typename(m_pk).len()`, ABSENT on our side in the
  **pristine** dump too (pre-existing).
* **"not view-split"** — I did not re-derive this; the `arm61e.sh` evidence
  stands and nothing I measured contradicts it.
* **"~87 objects" is wrong; the truth is 54 sites → 37 movers"** — CONFIRMED
  exactly by my independent span census (28 / 54 / 17 / 37).
* **`c1_scope` has ZERO differing cells** — CONFIRMED (12 rows, all SAME).
* **`c4_edge`'s only residue is `real`** — CONFIRMED (7 rows shown, 6 SAME,
  line 115 `real` DIFFER).
* **The R2 select value grid** — I spot-checked all ten rows of `c5_select`
  against golden and every value in the report's table is right (`m_pk[2]`→8,
  `m_pk[3:0]`→8, `m_pk[i+:2]`→8, `m_arr[i]`→4, `m_arr[1]`→4, `m_parr[i]`→32,
  `m_s.a`→4, `m_sarr[i].b`→SYMBOLIC, `m_q[i]`→32, `m_dyn[i]`→32). A future pass
  can trust that table.

### F6 — the Scoreboard flake is worse than "bistable", and still not this patch.

Reproduced independently, 3 runs per binary, on the sweep's own argv:

```
PRISTINE 29223f08…  3d9ff7aeaa4cccd3 / e9f7838a91990919 / e9f7838a91990919   distinct=2  bytes 11136761 (all 3)
PATCHED  e8e672f8…  5964f67505239096 / 74b373659c6d45eb / 74b373659c6d45eb   distinct=2  bytes 11133612 (all 3)
```
Both binaries flake, so the attribution "pre-existing, not this patch" stands,
and byte SIZE is stable within each binary with the same deterministic
**3 149-byte** delta the report gives. **But** my patched run produced
`5964f675…`, a hash the implementer never saw (they report `74b37365` /
`913223a3`). Across the two sessions `Scoreboard/default` has now shown **at
least three** distinct outputs from one binary, so it is **multi-stable, not
bistable** — worth correcting in the campaign memory before someone treats a
2-run reading as conclusive.

### F7 — three cells that CANNOT EXIST, recorded so nobody rebuilds them.

* `$unit`-parameter width **inside a package**: slang rejects, *"cannot
  reference compilation unit item from within a package"*. Moved to `v6_unit.sv`
  as a class in a **module**, where it is legal — and there golden **KEEPS** and
  we **KEEP** (`v6` cmp = **0 lines, fully equal** on the patched binary vs 38 on
  the pristine). The `unitResolves=false` choice is correct and now measured.
* `$bits(<chandle>)`, `$bits(<event>)`: slang rejects, *"invalid argument type
  to system function"*.

---

## 4. GATE-BY-GATE, ON MY BUILD

**GATE 1** rc 0 / 1 link line / 0 ` error:` in both worktrees; both HEADs print
`8633a1e6dc9031e3c13862813864f900c324fdf2`; baseline validated as 32 hex before
use; md5 asserted in a separate command; determinism 3/1/0.
**GATE 2** 23/0; `/bin/false` 0/23 (rc 1).
**GATE 3** 679/50/2; dump 496/183/52; **0 differing ROWS**, pristine sweep too.
**GATE 4** 467/13/5/284/25 and 463/10/5/286/23 (+3/2/1/1); dump histograms
identical in both modes; **0 differing ROWS**, pristine sweep too; **no
conversion**, as the brief predicted.
**GATE 5** u2r 0/679 (SELFCHECK 678/679, SELFCHECK1 1); surelog 7/953, the same
seven names (SELFCHECK 952/953, SELFCHECK1 8); per-shape all IMPROVED,
ADDED/REMOVED separate, UNATTRIB 0 — plus my own stronger over-fire census at
**0 / 7 movers**.
**CANARIES** canaudit 29/0/0; ctcan2 u2r ok=1 changed=0 absent=0 unknown=6, sl
ok=58 changed=0 absent=0 unknown=1; canaries sl 52 ok, u2r 8 ok, changed=0;
InterfaceModPort and BlackParrotComplex byte-equal to the committed baseline in
both modes.

---

## 5. RANKED RESIDUES (mine, merged with the implementer's)

| # | residue | evidence | note |
|---|---|---|---|
| **R1** | **the newly-exposed head** `class_defn (uvm_set_get_dap_base)` — `function` end-columns, `int_typespec` spans, `vpiParent` `work@env` | region multiset distance to golden **22**, identical pris↔pat | the implementer's ranking is right; highest-value next target on this row |
| **R2** | `$bits(<own property>[i])` — the SELECT extension, 6 objects in SimpleUVM | `c5_select`, 24 under-fires, 0 over-fires | value grid verified row-by-row; safe to implement from the table |
| **F1** | **package-parameter widths OVER-FIRE (4 cells)** | `v1_pkgparam.sv`, `v7_pkgts.sv` | **corpus price 0**, but the law as stated is wrong; corrected rule + concrete fix in §3 |
| **F2** | **`time` OVER-FIRES to UINT:64 (1 cell)** | `v4_type.sv` line 47 | **corpus price 0**; one-clause fix (exclude `time`/`realtime`) |
| **R3′** | the real family, now decoded: `real`→32, `shortreal`→32, `realtime`/`time`→keep | `c4` 115, `v4` 47–49 | smaller and more actionable than reported |
| **R4** | 17 `$bits(<TYPE>)` objects absent from `uvm_packer`/`uvm_reg_block` | identical 17 absent from the **pristine** dump | pre-existing, confirmed |
| **F3/R7** | under-fire in a method **default-argument value** and a **class localparam initialiser** | `v3_nonsub.sv` 37, 48 | safe direction; two more cells for the same predicate |
| **R5/R6** | `$typename(x).len()` dropped; `logic [$bits(v)-1:0]` bound | `c3` 24, `c2` 57 | pre-existing; `c2`'s dump is byte-identical pris↔pat, confirmed |
| **F4** | `mv61.sh`'s `UNATTRIB` regex covers 62.6 % of all shapes | measured | use `ofcensus.py` (added here) as the real over-fire gate in future passes |
| **F6** | `Scoreboard/default` is **multi-stable (≥3 states)**, not bistable | 3 reps × 2 binaries, plus the implementer's 2 | correct the campaign memory |

---

## 6. VERDICT

**PARTIAL — land it.**

The code is safe: five gates green, both corpora at 0 differing rows, byte
movers confined to the seven predicted UVM databases, all seven improving
against golden, zero new over-fires anywhere in 1 632 databases under an
instrument whose positive control fires, no collision with r10uvm60 (15 arms
byte-identical), and a clean rebase onto current main with the target rows and
head identity unchanged.

The **law** as written in `§ bitsOwnClassPropFold61` is **wrong in one
direction**: it says the fold is blocked by *parameter-dependent widths* when
what golden actually blocks on is *a parameter name reachable from syntax
written inside the class body*. Four cells prove the difference (package
parameter inline, class typedef over a package parameter, package parameter
without arithmetic, package parameter via a package localparam) and a fifth
(`time`) shows the value arm's `isIntegral()` is one type too wide. All five are
over-fires — the direction that emits a wrong constant — and all five happen to
cost nothing on today's corpora. They will not stay free: the next pass to widen
this predicate, or the next corpus with a package-parameterised class property,
walks straight into them. Correct the law in the follow-up, with `v1_pkgparam.sv`,
`v7_pkgts.sv` and `v4_type.sv` as the regression arms.

**Files added by this verification** (all under `tools/probe/r10uvm61repro/`):
`v1_pkgparam.sv`, `v2_kind.sv`, `v3_nonsub.sv`, `v4_type.sv`, `v5_adjacent.sv`,
`v6_unit.sv`, `v7_pkgts.sv`, `ofcensus.py`, and this file.
