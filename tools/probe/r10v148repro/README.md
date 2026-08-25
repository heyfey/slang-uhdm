# r10v148 — ADVERSARIAL VERIFICATION of r10uvm148 § `tfItemLocalLosesToPkgVar148`

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10uvm148.patch` (md5 `67bfec5401ee415593a095b06b3e3ef8`,
5183 lines) applies cleanly on a FRESH `ac10a363`, every headline number
reproduces bit-for-bit on binaries this verifier built itself, and seven
purpose-built adversarial arms — none of them the implementer's — record
**RIGHT→WRONG 0 and AWAY 0 in every arm, every view, every column**.

**MEASUREMENT-ONLY directory.** Nothing here judges. The official `uhdm-cmp`
and `scripts/verify_golden.py` are the authorities. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; `GOLDEN_DEFER` stayed unset; **no row was
converted**; the four slang-fenced tests were never dispatched.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `ac10a363` |
| worktrees | `/tmp/wt_v148pris` (pristine), `/tmp/wt_v148` (patched) — both fresh at `ac10a363` |
| pristine binary | md5 `f9cc51e81b15783ef0dec1ccc7bb4e4c` — **identical to the implementer's** |
| patched binary | md5 `32c95d791e27b7ad28c1cfa43e8d0c9b` — **identical to the implementer's** |
| both frozen | `chmod 555` copies under `/tmp/v148_bin/` BEFORE any sweep; every `cmds.txt` audited by binary PATH |

---

## 1. The head, re-measured on this verifier's own pristine build

`head_pris_default_SeqDriver.cmp` is **byte-identical** to the committed
`tools/probe/r10uvm145repro/head_pat_default_SeqDriver.cmp`: 62 lines, one
`^LHS:`, LHS `class_var (uvm_pkg::cs)` @1731:21 with `vpiVisibility:1`, RHS
`class_var (uvm_pkg::uvm_component::m_set_cl_verb::cs)` @3385:3 without it.
`VpiName` and `VpiAutomatic` agree on both sides and `VpiFullName` is not read,
so **`vpiVisibility` is the field that fails** — the implementer's framing,
verified off the log rather than carried forward.

After the patch: `head_pat_default_SeqDriver.cmp` = **36 lines, one `^LHS:`, a
NEW object** — `uvm_component.svh:3436` `m_time_settings.sort() with (...)`,
golden a `func_call` named after the QUEUE, ours a `method_func_call (sort)`
with the queue as `vpiPrefix`. `head_pat_default_MiniAmiq.cmp` is the same
object. **The head cleared on four row-modes.**

## 2. Surelog decode, read line by line and confirmed

* `UhdmWriter::lateBinding` (`UhdmWriter.cpp:3294`) skips any ref that is
  already bound (`if (ref->Actual_group()) continue;` :3296).
* its `uhdmfunction` arm (:3369-3428) runs `Return`-name → `Io_decls()` →
  `Variables()` → `Parameters()` → `Instance()`'s `Variables()` (guarded
  `uhdmpackage`) **with no early exit between the blocks**, testing
  `if (ref->Actual_group()) break;` only at the END: the package listing is the
  LAST WRITER. The `uhdmtask` arm (:3434-3470) is the same walk without
  `Parameters()`.
* `CompileHelper::bindVariable` (`CompileStmt.cpp:3089`) — the EARLY binder —
  checks a `function`/`task` scope's `Variables()` **before** its `Io_decls()`
  and recurses on `scope->VpiParent()` (`:3150`); it never reaches a package.
* `paSeq_block` (`CompileStmt.cpp:335`) **and `paPar_block` (`:430`)** BOTH run
  `scope->VpiParent(pstmt);` **before** the loop that compiles their children,
  while `compileConditionalStmt` (`:1326-1350`) compiles both branches with the
  `if_stmt`/`if_else` as `pstmt` while that object's own `VpiParent` is still
  null. **A `fork` therefore does not break the early-bound chain and a
  conditional/loop does** — which is exactly what the patch's removal of
  `SyntaxKind::ParallelBlockStatement` from `condPredEarlyBound81` encodes.

## 3. The arms — SEVEN, all written by this verifier

Driver `varms148.sh` (subdirectory arms, list on fd 3, children `</dev/null`,
`PROCESSED` asserted, scratch keyed on the RELATIVE path, every rc recorded);
scorer is the pass's own `score148.py` (multiset join, spans in keys only, the
DEF/ELAB view out of the key). `LISTED=6 PROCESSED=6 PROCESSED-ASSERT-OK`,
`rc_sl=0 rc_pris=0 rc_pat=0 rc_cen_*=0` on every arm and view.

| arm | what it varies | def-view BSK/BVIS |
|---|---|---|
| **A** `v148_a_role.sv` | production × ROLE: LVALUE, READ, `$display` ARG, INDEX, `$cast` target, method RECEIVER, `foreach` target, `if` predicate, the return-name function; function and task, both productions | **WRONG→RIGHT 32**, R→W 0 |
| **B** `v148_b_shadow.sv` | what is shadowed: package variable / class PROPERTY / package PARAMETER / TYPEDEF name / module variable / `$unit` variable; in-body vs out-of-body method | **WRONG→RIGHT 6**, R→W 0 |
| **C** `v148_c_home.sv` | homes: package free fn+task, package class in-body + out-of-body fn+task, `$unit` class, module class, module fn+task, program, interface, a WILDCARD-IMPORT copy, 3 module instances | **WRONG→RIGHT 20**, R→W 0 |
| **D** `v148_d_kind.sv` | `static` vs `automatic`, an INITIALISED TF-ITEM local, a nested-`begin` local, a body local read from inside a nested block, one name in two methods, a NESTED class, an out-of-body method of the outer class | **WRONG→RIGHT 28**, R→W 0 |
| **E** `v148_e_early.sv` | the early-bound ladder ×2 halves (TF-ITEM LOCAL and FORMAL): depth 0, one `begin`, `fork/join`, `fork/join` without `begin`, `join_any`, `join_none`, NAMED fork, fork under a loop, loop under a fork, plain LVALUE/READ under a fork, `case` condition at depth 0 and under a fork, immediate assertion at depth 0 and under a fork | **WRONG→RIGHT 46**, R→W 0 |
| **F** `v148_f_edge.sv` | for-loop ITERATOR, `foreach` loop variable, an initialiser reading another shadowed local, a package variable declared AFTER the subroutine, an EXPLICIT single-name import, `output`/`inout` formals beside a body local, unpacked-array/string/struct locals, a virtual method (in-body + out-of-body), a DEFAULT-ARGUMENT expression, a local named after its function | **WRONG→RIGHT 19**, R→W 0 |
| **G** `v148_g_corpus.sv` | the CORPUS SHAPE minimised (50 lines): out-of-body paren-less package-class method, class-handle body locals shadowing package variables, a receiver hier_path, an `if` predicate at BODY TOP LEVEL beside the SAME name's `if` predicate nested in a `foreach` | 10 of 12 cells pristine-WRONG → **12/12 golden exactly** |

**Totals over A–F, def view: `WRONG→RIGHT 151`, `RIGHT→WRONG 0`, `AWAY 0`.**
`ROLE`/`PROD`/`LOC`/`BKIND` are unchanged everywhere; the one-sided ROWSET
counts are IDENTICAL pristine and patched in every arm.

### Golden facts these arms establish (measured, not assumed)

1. **A fork is not a breaker.** Arm E, TF-ITEM half: golden keeps the LOCAL under
   `fork/join` (with and without an inner `begin`), `join_any`, `join_none` and a
   NAMED fork, for an `if` predicate, a `case` condition and an immediate
   assertion — and takes the PACKAGE the moment a LOOP stands anywhere in the
   chain (fork-under-loop and loop-under-fork both). The FORMAL half of the same
   ladder splits identically (`io_decl` under a fork, `package` under a loop).
   The pristine binary was WRONG on 4 formal cells there; the patch takes them
   **WRONG→RIGHT**. This is a genuine, golden-backed correction inside § 81's
   own population.
2. **Arm G reproduces the corpus's own split on a 50-line file**: the same name
   `apex_v7` keeps its LOCAL in an `if` predicate at body top level (37:9) and
   takes the PACKAGE in an `if` predicate nested inside a `foreach` (39:11) —
   the `top` @3432:14 vs @3410:48 pair of `uvm_component.svh`, isolated.
3. **The fences hold, and golden says so**: a CLASS PROPERTY shadow keeps the
   local (arm B `prop_v2` → `function`); an IN-BODY class method binds NOTHING
   (arms B and C, golden `BKIND=none`); a `$unit`-scope class method binds
   nothing (arm C); MODULE / INTERFACE subroutines keep the local (arm C);
   BLOCK-ITEM locals keep the local under EVERY shape including under a loop
   (arms A–F); a nested-`begin` local keeps its binding under both productions
   (arm D); a for-loop iterator and a `foreach` loop variable keep theirs (arm F,
   read off the dumps — they fall outside the census population).
4. **The wildcard-import three-way split** (§ 81 arm c8) reproduces on arm C in
   one file: `v3_pkg`'s own subroutine → `v3_pkg::shr_v3`; the COPY of that
   subroutine inside the importing `v3b_pkg` → keeps the LOCAL; `v3b_pkg`'s OWN
   subroutine seeing the CLONE → the package. Patched matches all three.
5. **The ELAB view is a different regime, and golden proves it**: in arm B's
   elaborated database golden itself binds the LOCAL (`function`) where its
   def-view database binds the package — both our binaries already agree, and
   all seven arms' elab views are RIGHT→RIGHT with zero movement.

## 4. Gates — all re-run by this verifier, all green

| gate | result |
|---|---|
| (1) build both `-j 2`, md5 separately | pris `f9cc51e8…`, pat `32c95d79…` — **both identical to the implementer's**; frozen `chmod 555` before any sweep |
| (2) goldens | pristine **23 PASS / 0 FAIL**, patched **23 PASS / 0 FAIL** (`SLANG_UHDM` exported explicitly per binary); negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| (3) u2r both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL — both modes, both binaries; `ct8rows` vs `results/gate_uhdm2rtlil.csv` **PASS**, vs own pristine tf **PASS**, vs own pristine def **PASS** |
| (4) surelog `--mode both` | default 471/283/25/10/5 and testflags 466/284/23/9/5/3/2/1/1 — identical for both binaries; `ct8rows` vs `results/golden_surelog.csv` **PASS**, vs own pristine **PASS** — **0 differing rows over 1588**, **NO row converted**, `results/*.csv` never written |
| (5) byteverify `SELFCHECK=1` | u2r **MOVERS 0 / 1358**, surelog **MOVERS 9 / 956**, `PATH_SETS_IDENTICAL` both, SELFCHECK 1357/1358 and 955/956 flagged |
| binary-path audit | every `cmds.txt`: 1458/1458 u2r and 1523/1523 surelog name the intended frozen binary; **zero** name the main-tree binary |
| canaries | surelog `ok=52 changed=0 absent=0`; u2r `ok=8 changed=0 absent=0`; `ctcan2` PASS ×2; `canaudit.sh canaries.sh ctcan2.sh` **PASS audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical both modes; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** |

## 5. Prediction, then measurement — done independently

`vpred148.py` over the census of **all 956 PRISTINE surelog databases**
(`PROCESSED=956`, every rc 0), keyed only on
`PROD=TFITEM ∧ LOC=FUNC ∧ PKGV=1 ∧ BSK∈{function,task}`, names **exactly nine
databases**: SeqDriver df+tf, MiniAmiq df+tf, SimpleUVM df+tf, BuildUVMPkg
df+tf, Scoreboard/default. The same predictor over **all 1358 PRISTINE
uhdm2rtlil databases** (`PROCESSED=1358`, every rc 0) names **PRED_DBS=0**.
`byteverify` then measured **MOVERS 9 / 956 — the same nine, by name — and
0 / 1358 on uhdm2rtlil**.

Each mover moves by **exactly 12 order-blind, path- and `id:`-normalised dump
lines**, every one a `vpiActual` rebind inside `m_set_cl_verb`:
`2× cs → uvm_pkg::cs` and `4× top → uvm_pkg::top`. **Scoreboard/default — the
~50/50 coin — was attributed this way and shows those 12 lines and nothing
else.**

Depth-keyed census on the nine, golden vs pristine vs patched:
**`BSK` and `BVIS` WRONG→RIGHT 6, RIGHT→WRONG 0, AWAY 0 on every database**
(54 cells); `ROLE`/`PROD`/`LOC`/`BKIND` untouched; one-sided ROWSET counts
identical pristine→patched. SeqDriver/default's TF-ITEM face:
**golden 18 `function` / 6 `package` / 8 unbound; pristine 24 / 0 / 8; patched
18 / 6 / 8 — golden exactly.** The 8 unbound stayed unbound, which is the
`!bound` guard measured rather than argued.

The FORK half has **no corpus population**: over the nine goldens, every
`FORK=1 ∧ PKGV=1` cell agrees between golden and patched (the only key
mismatches are macro-buffer span shifts that are identical on both binaries).

## 6. Boundary

* **Committed control arms** — 130 sources from `r10uvm145 / r10v145 / r10uvm143 /
  r10v143 / r10uvm107 / r10v107 / r10uvm88 / r10uvm98 / r10v98 / r10uvm81 /
  r10v81 / r10uvm139 / r10uvm109 / r10uvm113 / r10uvm67 / r10uvm9e / r10buvm14 /
  r10uvm89`, both views: **MOVED 0, RC-MISMATCH 0** (`vbound148.sh`).
  Positive control `CTRL=1`: **258 flagged** — the gate can see.
* **Wide** — every committed probe-arm source in the tree, **4243 files × 2
  views**, two halves: **MOVED 11, RC-MISMATCH 0**, and all eleven are THIS
  PASS's own arms in the DEF view (5 `r10uvm148repro/g148_*.sv` + 6
  `r10v148repro/v148_*.sv`). **No earlier pass's arm moved a byte.**
  Positive control on `vwide148.sh`: **120/120 flagged**.
* `BYTE-ONLY 4` — three of this verifier's own arms plus one, whose ELAB
  `.uhdm` FILES differ in bytes while their `uhdm-dump` output is **identical
  line for line**. Recorded, and reported as BYTE-ONLY rather than MOVED,
  because it is invisible to the judge. Worth knowing for any future
  byteverify reading: a byte mover is not always a dump mover.

## 7. Residues this verification found (ranked)

* **R-A (new, ranked first): an EXPLICIT single-name import is not cloned.**
  Arm F `imp_tf_v6`: golden's `import v6a_pkg::imported_v6;` materialises
  `v6_pkg::imported_v6` in the IMPORTING package's `Variables()` and the
  TF-ITEM local loses to it; **we emit no such clone at all**, so the law has
  nothing to displace and we keep the local. 2 cells, `WRONG→WRONG` on both
  binaries — a MISSING-OBJECT law (the explicit-import twin of the wildcard
  clone), not a binding bug, and outside this pass by construction. Corpus
  incidence: none of the 9 mover databases; not measured corpus-wide.
* **R-B (confirms the implementer's R2): a PROGRAM subroutine's reference is
  BARE in golden.** Arm C `pgfn_tf_v3` @97:5: golden `BKIND=none`, we bind the
  local. 1 cell ×1 listing, `WRONG→WRONG`, unmoved by the patch.
* **R-C: a virtual in-body method's `task_func` SPAN.** Arm F `vm_tf_v6`:
  golden spans the NAME (`100:5-100:12`), we span the whole body
  (`100:5-103:16`). Pre-existing, identical on both binaries, span-only.
* **R-D: `stv_v6.a` (a struct-member select on a shadowed local).** Golden
  carries a `hier_path` element ref_obj named `stv_v6`; we carry none. 2 cells
  ONLY-GOLDEN, identical on both binaries.
* **R-E: a DEFAULT-ARGUMENT expression's reference has no `vpiParent` on our
  side** (arm F `dflt_v6` @87:36, `ROLE=NOPARENT` vs golden `READ`). Identical
  on both binaries.
* **R-F (confirms the implementer's R3/R4):** Surelog's database carries no
  `$unit` variable for the walk, so the `$unit` shadow face is empty; and the
  ELAB regime is a separate law whose regression test is these arms' elab views.

## 8. Files

`v148_a_role.sv` … `v148_g_corpus.sv` (the seven arms), `varms148.sh` (arm
driver), `vbound148.sh` / `vwide148.sh` (boundary gates, both with a positive
control), `vpred148.py` (a-priori mover prediction from pristine databases),
`vshow148.py` (cell viewer), `ARMS_ABCDE.txt` / `ARMS_F.txt` (scored arm logs),
`head_pris_default_SeqDriver.cmp` (62 lines, = uvm145's committed R0),
`head_pat_default_SeqDriver.cmp` / `head_pat_default_MiniAmiq.cmp` (36 lines,
the new head).
