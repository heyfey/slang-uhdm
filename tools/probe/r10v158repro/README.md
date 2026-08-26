# r10v158repro — adversarial verification of r10uvm158 (§ badBlockKeepsItsScope158)

Assembled at the master from the verifier's scratch (its arms, instruments, measurement files and head logs);
the verifier shipped no patch (verdict ACCEPT AS SHIPPED). The text below is the verifier's final report, verbatim.

---

# VERDICT: **ACCEPT AS SHIPPED**. No regression found on any face I could construct; every headline number reproduced bit-for-bit from my own build. No `.verified.patch` is needed.

## 1. Reproduction — independent, from scratch

Fresh worktrees `/tmp/wt_v158pris` + `/tmp/wt_v158` at `1f9906a`, both configured and built myself (`-j 2`, Release, gcc-toolset-14), then frozen `chmod 555` at `/tmp/v158_bin/{pris,pat}.bin`.

| | implementer claimed | I measured |
|---|---|---|
| pristine binary md5 | `100987bc8d76f2052aa842d7c65c5110` | **identical** |
| patched binary md5 | `5c39f2b244f69d171cfaa3353e8fdf63` | **identical** |

Both md5s reproduced **from a from-scratch build of the patched source** (I destroyed and rebuilt `/tmp/wt_v158/build` after an early mishap of my own, so the patched binary is a true clean-tree build). Patch applies clean on a fresh `1f9906a` — checked **three** times, 0 conflict markers, `git status` = 2 modified + the one probe dir.

Surface audit: `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `tools/probe/r10uvm158repro/` (51 files) — **0** `results/*.csv` hunks, **0** fence-name mentions outside `canaudit.sh`'s own list, `GOLDEN_DEFER` unset, slang untouched. The shipped instruments `byteverify.sh` / `canaries.sh` / `ctcan2.sh` / `rowheads.sh` are **byte-identical** to their canonical originals; `ct8rows.sh` is byte-identical to `tools/probe/r10oth8repro/ct8rows.sh` and `canaudit.sh` to `tools/probe/r10sd4repro/canaudit.sh` — no tampered judge. `predsweep158.sh`/`scoreall158.sh` `rm -rf` only their own pass-prefixed `mktemp -d`.

**Every `cmds.txt` audited by binary PATH**: u2r `1458/1458 → /tmp/v158_bin/{pris,pat}.bin`, surelog `1523/1523 → the frozen binary`, **0** hits on any main-tree binary.

## 2. The gates (all mine, all green)

| gate | result |
|---|---|
| goldens | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0/23** |
| u2r both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** on both binaries; `ct8rows` **0 differing rows** vs the committed baseline and vs my own pristine, both modes; byteverify **MOVERS 0/1358**, SELFCHECK 1357/1358 |
| surelog `--mode both` | status histograms **identical** pristine↔patched (`CMP_NOTEQUAL` **10 default + 9 testflags**, unchanged); `ct8rows` **0 differing rows over 1588** vs `results/golden_surelog.csv` *and* vs my own pristine (whole row, dump column included) |
| byte movers, surelog | **9 / 956** |
| canaries | `ok=52 changed=0` (sl), `ok=8 changed=0` (u2r); `ctcan2` PASS ×2; `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical both modes; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** on their pins |
| **NO ROW CONVERTED** | confirmed — `results/*.csv` read only |

## 3. Prediction made before the patched sweep existed — reproduced

I wrote my own predictor (`/tmp/v158_scr/v158pred.sh` + `v158pred2.py`, set-semantics per `(owner, span)`, not the implementer's) and ran it on the **pristine** databases only:

```
surelog    : rows=1573 SKIP-NOFILE=617 toward=13 away=0   (comparable = 956)
uhdm2rtlil : rows=1462 SKIP-NOFILE=104 toward=0  away=0
```

Same **13 cells**, same owners and spans, same **9 databases** — SeqDriver ×2, SimpleUVM ×2, Scoreboard/default, MiniAmiq ×2, BuildUVMPkg ×2. `byteverify` then named **exactly those 9**. **0 unpredicted movers, 0 predicted non-movers.**

My predictor also ran the *name* half of the law (`golden names the block, we do not`): **0 hits over all 956 comparable databases** — the named-block face is corpus-unreachable today, which matters for residue R-A below.

## 4. Heads — bit-for-bit

`rowheads.sh` on my own two sweeps:

| row | pristine | patched |
|---|---|---|
| **SimpleUVM def/tf, Scoreboard/default** | **163**, 1 head, `LHS: begin … / RHS: <null>` | **67**, 1 head, `operation` opType 33 with `hier_path[ref_obj t, method_func_call get_type_name]` |
| SeqDriver def/tf | 22, 1 | 22, 1 — **same object**, only a serializer id shifts `184635→184638` |
| MiniAmiq / BuildUVMPkg / Earlgrey / Rggen | 106 / 1371 / 31,36 / 0 | **byte-identical head logs** |

All **24** shipped `head_{pris,pat}_*.cmp` files reproduce id-blind against my sweeps.

**Head field decoded independently.** Our pristine database *does* carry the `begin` at `118:26-122:8` with `NSTMTS=2` and `NVARS=-1` (NULL vector) — so the printed head cannot be `if_stmt::Vpi_stmt`; it is `scope::Variables`, the VECTOR overload, RHS null, owner = the `begin`. The implementer's decode is right.

**Law verified against slang source, not the write-up.** `Statement.cpp:307` returns before `:353 result->blockSymbol = &block`, and only for `SequentialBlockStatement`/`ParallelBlockStatement` (the other `bindBlock` arms link the symbol *before* `badStmt`). `BlockStatement::fromSyntax` has exactly **two** callers and only `bindBlock` passes `addInitializers=true`; `VariableDeclStatement` has **exactly one construction site in all of slang** (`Statement.cpp:399`, inside `bindScopeInitializers`), and `BlockSymbols.cpp:52` sets `context.scope = this` before the call. So the recovered scope is *provably* the symbol the early return dropped — not a heuristic.

## 5. Attribution — order-blind, my own

Path-normalised, id-stripped, sorted whole-dump diff on all 9 movers:

```
SeqDriver/SimpleUVM/Scoreboard/MiniAmiq (each mode)  ADDED=15  DELETED=0
BuildUVMPkg (each mode)                             ADDED=90  DELETED=0
```

**Zero deletions anywhere.** All 90 BuildUVMPkg lines are variable-listing lines. The three BuildUVMPkg cells land *exactly* on golden including statement counts:

```
uvm_registry_common::set_type_alias 14094:63-14100:9
   G (2 vars factory:class_var,rgtry:ref_var / 3 stmts)
   A (-1 / 1)  ->  B (2 / 3)   == golden
```

Corpus census over the 9 movers with **my** scorer: **13 BLK TOWARD + 15 DECL TOWARD, WRONG 0, AWAY 0, RESHAPE 0, ONLY-A 0.**

## 6. Breaking the law — 13 arms of my own, plus the shipped 6

My arms (`/tmp/v158_scr/arms/`, names deliberately unlike the implementer's) cover every face the brief lists: default int / class / struct / enum, a typedef of the parameter, unpacked-array and queue of the parameter type, override by a specialization, two specializations of one class, initializer, read-before-write, 0/1/2/3 locals, else arm, case arm, fork arm, while/for/do-while/foreach bodies, named block with and without locals, block-scope localparam, static / task / out-of-body / constructor homes, `$unit`/package/interface/program/module homes, 1-vs-3 module instances, non-parameterized controls — each with an accepted twin. Scored with an **independent scorer** whose BLK key is `(owner, span)` with **kind and name in the payload** (the shipped `score158.py` puts kind in the key, so a `begin→named_begin` regression could hide there as ONLY-A + AWAY; in mine it cannot).

**20 arm-databases × both views, golden vs pristine vs patched:**

```
BLK   RIGHT 67  TOWARD 93  WRONG 0  AWAY 2*  RESHAPE-FARTHER 0  ONLY-A 8*
DECL  RIGHT 434 TOWARD 126 WRONG 0  AWAY 0   RESHAPE-FARTHER 13**
```

\* The 8 ONLY-A and 2 AWAY are **key moves, not inventions**: each pairs with a TOWARD/RESHAPE-CLOSER at golden's own key carrying golden's exact payload (e.g. `named_begin mark1` `1/1/kk1:ref_var` matched exactly). No cell exists in the patched DB that exists in neither golden nor pristine.

\*\* Every RESHAPE-FARTHER is "was absent, is now present with a **pre-existing** residue". I proved this rather than assuming it: arm `v158_i.sv` puts a rejected block and an **accepted twin** with the same declaration in the **same database** for each face. The payloads are byte-identical —
`Tbad_cls/boat` **B** = `('class_var','class_typespec','-')` = `Tok_cls/boat` **A=B**; likewise enum (`enum_typespec '-'`) and struct (`bit_typespec`, both sides). Same for the shipped arm: `allBad158`'s four cells equal `allOk158`'s four. **The recovery lists exactly what the accepted twin lists; it introduces no new residue.**

**The three contamination traps all hold** (`v158_h.sv`, `v158_k.sv`):
- named outer with **no** locals holding a rejected inner **with** locals → inner is a plain `begin` with `ic2:ref_var`, **not** stamped `edge2`; outer stays unnamed (A==B). The unsound child-scope-parent recovery did not happen.
- outer **with** locals holding a bare inner → inner gets nothing, outer gets exactly its own two.
- **shadowing** (`mf0` declared in both) → each block lists only its own.
- foreach/for implicit wrappers: A==B, untouched.

`r10uvm59repro/a1_witness.sv` (the one earlier-pass arm that moves) re-measured: **BLK TOWARD 1** landing exactly on golden's `factory:class_var,rgtry:ref_var` / 3 stmts, **DECL TOWARD 2, WRONG 0, AWAY 0.** Under the official judge its elab view goes **CMP_NOTEQUAL → rc=0 (EQUAL)**; my arms `v158_d.sv` and `v158_i.sv` also go to **rc=0** on both views.

**Arms whose cmp line count *grew* are masking cascades, not regressions** — verified, not assumed. `v158_g` 75→3624: the patched head is the `design` object. Deleting the package class from the arm makes **pristine and patched print the identical 2976-line design head**, so it is pre-existing R5 that the shallower block head had been masking.

## 7. Wide boundary — my own run

`bound158.sh` over a copy of the whole probe tree plus my 13 arms:

```
LISTED=4429  PROCESSED=4429  PRODUCED_DBS=4282  MOVED_ARMS=16  RC_DIFFS=0
```

16 movers = 6 (the pass's own `g158_*.sv`, positive control) + 9 (mine) + 1 (`r10uvm59repro/a1_witness.sv`, shown TOWARD above). 2023 subdirectory arms reached with per-relative-path keys (`r10uvm33repro`'s three `dut.sv` got three distinct dirs). 28 segfault lines = **14 arms that segfault in the elab view on BOTH binaries, perfectly paired** → `RC_DIFFS=0`, pre-existing.

Named must-stay controls, **byte-identical databases in both views, 0 moved**: `r10uvm155repro` 5, `r10v155repro` 9, `r10uvm145repro` 5, `r10v145repro` 8, `r10uvm141repro` 3, `r10v141repro` 4, `r10uvm139repro` 5, `r10uvm151repro` 5, `r10uvm146repro` 7, `r10uvm113repro` 4, `r10uvm114repro` 8, `r10uvm89repro` 2, `r10buvm14repro` 1, `r10uvm77repro` 9, `r10uvm84repro` 23, `r10uvm85repro` 23.

**`r10vrgg3repro/xi_iface_param_type/dut.sv` did NOT move in my run** — the implementer's flake call is right, and I can strengthen it: the arm has **0 statement blocks and 0 processes**, so `recoverBadBlockScope158` is unreachable on it; and under matched CPU load, **120 runs each, pristine outliers = 1, patched outliers = 1** (a `|vpiSigned:1` that appears and disappears). It is a genuinely nondeterministic arm on *both* binaries, not a patch effect.

## 8. Findings the implementer's evidence did not carry (ranked)

**R-A — NEW, judge-read, not in the shipped README.** A **recovered named block gets its name and its locals but NOT its `vpiEndLabel`.** `bindBlock`'s early return also drops `bs.syntax`, so § `endBlockLabelAllOwners62`'s syntax read cannot run. `VpiEndLabel` **is** read by the judge — `~/git-repos/UHDM/build/generated/src/named_begin.cpp:105` and `named_fork.cpp:111`. It is the *only* judge-read field left on those cells: the head diff on `v158_e`/`v158_h`/`v158_j` is exactly `|vpiEndLabel:mark1` / `outer2` / `tagA4` present on golden, absent on ours. **Not a regression** — pristine emitted an unnamed `begin`, which fails `BaseClass::Compare`'s VpiType test first — and **corpus-unreachable** (name-half prediction = 0/956). But it means the named half of § `badBlockKeepsItsScope158` is only *partially* closed, and the shipped grid could not see it because the census payload carries no end label. The handle for a future pass is `blkSym158->getSyntax()`; the *obvious* route, re-deriving `bss131` from the symbol, is the change an earlier pass's wide boundary already convicted as a regression (`r10v103repro/arms/v103_b2.sv`, quoted in `StmtEmit.cpp`'s own comment) — do not take it.

**R-B — NEW, dump-only.** A recovered **named fork** anchors at the LABEL span (`17:14-17:19`) while its accepted twin anchors at the whole block (`17:7-20:19`, = golden), same reason as R-A (`bss131` null → the else branch). Judge never reads a span. This is R1's family, one face wider than recorded.

**R-C — ops, worth recording for the next verifier.** `tools/probe/r10vrgg3repro/xi_iface_param_type/dut.sv` is nondeterministic at ~1/120 under load on **both** binaries. Any byte-identity boundary gate will flag it spuriously; the refutation is the one above, not a re-run.

**R-D — cosmetic.** `src/StmtEmit.cpp:41` still says *"A block with no blockSymbol pushes nothing (there is nothing to key on)"*. A recovered block now **does** push a `BlkCtrl57` key. The comment is stale.

**R-E — the one un-routed read.** `src/ModuleEmit.cpp:25329` still reads `pbBody.as<BlockStatement>().blockSymbol` raw for the concurrent-assertion label. Unreachable today (a bad block arrives there as `StatementKind::Invalid`, not `Block`, so the branch is not taken), but it is the only `blockSymbol` read in the tree that does not go through the handle.

**R1–R5 as shipped: all re-measured, all confirmed** — R1 span loss (`noLocal5`, `namedZero1`, `zero1`, `sibs2` all at `0:0-0:0`, A==B); R2 no-locals block keeps neither label nor scope (`namedZero1` → golden `named_begin mark2` is ONLY-G, unchanged); R3 out-of-body `int_typespec` vs golden `unsupported_typespec RR` (accepted twin `outOk` scores identically — inherited); R4 typedef-of-parameter `int_var` vs `ref_var` (twin identical); R5 generic class in module/interface/program not emitted (`v158_g.sv` `Inif6`/`Inpg6`/`Inmd6` ONLY-G on both binaries).

**R0 confirmed as stated**: SimpleUVM ×2 + Scoreboard/default, **67 lines, 1 head**, the concatenation `operation` (opType 33) whose middle operand is `hier_path[ref_obj t, method_func_call get_type_name]`, reproduced by `g158_f_witness.sv` at exactly 163 → 67 with the same two head objects.

## 9. Evidence

Frozen binaries `/tmp/v158_bin/{pris,pat}.bin`; sweeps `/tmp/v158_wd_pris`, `/tmp/v158_wd_pat`; my arms `/tmp/v158_scr/arms/*.sv` (13); instruments `/tmp/v158_scr/{v158grid.sh,v158score.py,v158pred.sh,v158pred2.py}`; measurements `/tmp/v158_scr/{PRED.sl.tsv,PRED.u2r.tsv,CENSUS.txt,DUMPDIFF.txt,BOUND.LISTED,BOUND.MOVERS,GRID.summary.txt}`; head logs `/tmp/v158_scr/heads_{pris,pat}/`. Boundary arm tree and dump scratch pruned after recording (`/tmp` at 12%).