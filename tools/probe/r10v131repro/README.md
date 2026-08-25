# r10v131 — adversarial verification of r10uvm131 (§ parBlockJoinTailAfterFirstItem131)

The verifier's report, verbatim (paths under /tmp were its scratch; its own arms
and tools are copied beside this file by the master at landing).

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10uvm131.patch` is correct, complete, and every headline number reproduces bit-for-bit on my own build. No pristine-right→patched-wrong cell was found on any legal SV I could construct, so no `.verified.patch` is needed — ship the implementer's patch unchanged.

## 1. Reproduction — every headline number, my own binaries

| claim | implementer | measured by me |
|---|---|---|
| pristine md5 | `165b0bc396978d7f67d30949dc7b2ec2` | **same** (`/tmp/v131_bin/pris`, `chmod 555`) |
| patched md5 | `ecc9954c33ac51609eb177cb9c02ef2b` | **same** (`/tmp/v131_bin/pat`, `chmod 555`) |
| goldens | 23/0 each binary, `/bin/false` 0/23 | **same** |
| MiniAmiq head | 294 → **80**, both modes | **same**; all other heads unchanged (SeqDriver 17, SimpleUVM 64, Scoreboard/def 64, BuildUVMPkg 60, Earlgrey 90/150, Rggen 0) |
| committed head logs | `head_pris_*` / `head_pat_*_MiniAmiq.cmp` | reproduce **line-for-line** (ids normalised) |
| surelog | def 471 EQ/10 NE, tf 466 EQ/9 NE | **same**, histograms identical pristine↔patched |
| u2r | 679/50/2 both modes | **same** |
| `ct8rows` | 0 differing rows | **PASS** on all five comparisons (baseline & pristine, status **and** dump), 1588 sl + 731×2 u2r rows |
| u2r byteverify | MOVERS 0/1358 | **same**, `PATH_SETS_IDENTICAL`, SELFCHECK 1357/1358 |
| sl byteverify | MOVERS 11/956 | **same 11 databases, same names** |
| a-priori prediction | CAN-MOVE 11 sl / 0 u2r | I re-ran `pred131.sh` on my pristine workdir: **11 / 0, CEN-FAIL 0** — the predicted set equals the measured mover set exactly |
| cmds.txt audit | 1523 sl / 1458 u2r | **same counts**, and **every** file names the frozen binary; zero main-tree leakage |
| canaries | sl `ok=52 changed=0`, u2r `ok=8 changed=0`, ctcan2 PASS×2 | **same** |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, three byte-identical | **all hold, both modes** |
| fence audit | `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **same**; patch itself: 0 fenced names outside `canaudit.sh` |
| apply | clean on fresh 8304a60 | `git apply --check` **rc 0** on a fresh worktree; surface = `src/StmtEmit.cpp` + `tools/probe/r10uvm131repro/`, **0 files outside** |

The six carried gate scripts in the probe dir (`ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `rowheads.sh`, `canaudit.sh`) are **byte-identical** to their committed originals — no tampering. No `results/*.csv` touched; no row converted.

I also independently confirmed the Surelog model in `~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp`: `paPar_block` at :380, `NodeId tempItem = fC->Sibling(item);` at :398 (one node past the first item), `item = fC->Sibling(item);` at :458 before the join-keyword test — versus `paSeq_block`'s `tempItem = item` at :306 and its own `populateCoreMembers(labelId, labelId, scope)` at :336. And the "the slStringConst re-populate does not reach a `named_fork`" claim is **provable, not assumed**: that arm casts to `atomic_stmt*`/`concurrent_assertions*`, while `named_fork final : public scope` (`~/.local/include/uhdm/named_fork.h:41`) — the cast fails, so no label-token re-stamp.

## 2. Breaking the law — 11 adversarial arms, 427 fork cells, 0 regressions

I wrote my own arms and my own scorer keyed on `KIND|NAME|NSTMT|PATH` — **`ENDLBL` deliberately left out of the key** so an end-label regression scores `RIGHT->WRONG` instead of hiding as `AWAY` (the one real blind spot in the shipped `score131.py`, whose key includes `ENDLBL`).

Faces covered: `join`/`join_any`/`join_none` × unnamed / `fork : lbl` / `lbl : fork` × with and without `join : lbl` × single-statement body / `begin` body / two parallel begins / 4-deep nested forks / nested empty fork as sole child / three sibling empty forks / `disable fork` / `wait fork` / body that disables its own label / fork in a `for`, `while`, `repeat`, `do-while`, `case` item, generate block / class task, class function, class `new()`, free package task, interface task, module `initial`, `always`, `always_ff`, `final`, `program` / label colliding with a variable name in another scope / 1, 2 and 3 instances / DEF and ELAB.

```
427 fork cells (11 arms x 2 views)
JOIN   : WRONG->RIGHT 176   RIGHT->RIGHT 247   RIGHT->WRONG 0   WRONG->WRONG 0
ENDLBL : WRONG->RIGHT  71   RIGHT->RIGHT 352   RIGHT->WRONG 0   WRONG->WRONG 0
SPAN   : WRONG->RIGHT 305   RIGHT->RIGHT 118   RIGHT->WRONG 0   WRONG->WRONG 0
ONLY-OURS 0   AWAY 0   ONLY-GOLDEN 4 (residue R1 below)
```

Stronger than the report claims: on **every** arm×view the patched fork census is **byte-identical to golden's** — kind, name, end label, join type, stmt/var counts, span and parent path — the two uninstantiated-interface cells of R1 excepted.

**The sharpest cell I found, and the gate survives it.** `fork ; join_none` — a fork whose only item is a null statement. Golden gives `fork_stmt JOIN=1 NSTMT=0`, and `fork : kA ; join_none : kA` gives `named_fork JOIN=1 ENDLBL=kA NSTMT=0`. A gate keyed on the *emitted* statement list (`Stmts()` empty) would have wiped the join type and the end label on 13 such cells; the shipped gate is keyed on the **syntax item list** (`src/StmtEmit.cpp:1910`, `!bss131 || !bss131->items.empty()`), which is the right variable, and all 13 come out identical to golden. Same for `fork localparam int LPA = 3; join_none`, `fork typedef int t_ka; join_none`, `fork begin end join_none`.

I also re-scored the implementer's own five arms with my ENDLBL-scoring key: the 9 `AWAY`/`ONLY-OURS` pairs their scorer reports are exactly the end-label key changes, all `WRONG->RIGHT`, and golden-vs-patched is IDENTICAL on all ten arm cells.

## 3. Wide boundary — 3840 files, 12× the implementer's

`xargs` dispatched all **3840** committed probe `.sv`/`.svh` (verified: dispatch count 3840) × 2 views = 7680 compile pairs, pristine and patched, whole `uhdm-dump` diffed path-normalised.

```
MOVED 10   BREACH 0   rc-mismatch 0   NODB 288 (both binaries, identical)
```

Only 5 files move: `r10uvm62repro/{c2_neighbours,c3_edge}.sv`, `r10uvm80repro/{v1_scopes80,v7_forknoinit80}.sv`, `r10v100repro/v100_b4_scopes.sv`. I compiled all 10 moved cells under Surelog and scored them: **JOIN 20 WRONG→RIGHT, SPAN 21 WRONG→RIGHT, ENDLBL all RIGHT→RIGHT, RIGHT→WRONG 0** — including uvm62's `c3_edge`, the `§ endBlockLabelAllOwners62` boundary, whose end labels are untouched.

**Must-stay controls hold**: uvm121, uvm122, uvm127, v127 and v103 arms did **not** move — verified twice, once by my wide sweep and once by running the shipped `bound131.sh` over those directories with `GOLD=1 CTRL=1` (`LISTED=43 PROCESSED=43 MOVED-CELLS=8 BREACH=0 PROCESSED-ASSERT-OK POSITIVE-CONTROL-OK BOUNDARY-PASS`; the 8 are uvm62/uvm80 only).

## 4. Corpus census and mover attribution

Nine UVM DB-modes, 466 fork cells, key joins perfectly (0 ONLY-GOLDEN / 0 ONLY-OURS / 0 AWAY):
`JOIN: WRONG→RIGHT 35, RIGHT→RIGHT 431, RIGHT→WRONG 0` and `SPAN: WRONG→RIGHT 35`.
After the patch the fork census of **every one of the nine databases is byte-identical to golden's** (pristine differed by 6–10 lines each).

Order-blind whole-dump attribution on all six moving corpus databases: `MiniAmiq 27`, `SeqDriver 27`, `Scoreboard 17`, `SimpleUVM 17`, `BuildUVMPkg 17`, `UnitElabBlock 6` differing lines — **0 unclaimed on every one**. `UnitElabBlock` stays `CMP_EQUAL`; its dump column was already `differ` before and after, which is why `ct8rows` sees nothing.

## 5. Findings against the report (ranked)

1. **One number in the README is a mislabeled aggregate, not a false claim.** §2 says the census scores "SPAN 38 WRONG→RIGHT". The nine named UVM DB-modes in that table (466 cells) measure **SPAN 35**; the missing 3 are `UnitElabBlock`'s `named_fork` span cells (1 default + 2 testflags), which are movers but are not rows of that table. The `JOIN 35` figure is exact. SPAN is dump-only, so nothing gated depends on it — but the census table and the sentence under it should agree. *Fix: change "SPAN 38" to "SPAN 35 over the nine table rows (38 counting UnitElabBlock's three)".* I did not edit the patch for this.
2. `score131.py`'s key includes `ENDLBL`, so an end-label regression scores as `AWAY`, not `RIGHT->WRONG`. `bound131.sh`'s `GOLD=1` check only fails on `RIGHT->WRONG`/`WRONG->WRONG`/patched-only keys — an `AWAY` would pass it. Harmless here (I re-scored everything with `ENDLBL` outside the key and found nothing), but the instrument is one notch weaker than the report implies.
3. `arms131.sh`/`bound131.sh` `rm -rf "$WD"` on a defaulted `/tmp/r10uvm131_{arms,bound}`. Own-pass-prefixed and overridable via `WD=`, so within the rules; noting it only because the standing rules name the pattern.

## 6. Residues, ranked

1. **Forks inside an uninstantiated `interface` are absent from our database entirely.** Arm J's `ifaceNamed`/`ifaceEmpty` in `interface Ijb`: golden mentions them 7 times, our dump 0 — while `interface_inst` itself is emitted twice. Pristine and patched identical, so unrelated to this law, but it is a real emission gap the fork census can only see from outside the corpus. Not a fork head; an interface-body-emission head.
2. **The span law is measured only on syntax-bearing forks.** The `v103_b2` class-method fork reaches the emitter span-less; golden gives it no span either, so nothing moves, but nothing is proved.
3. **`fork … join : lbl` on an unnamed fork is unreachable.** I confirmed slang errors `trailing name not allowed on previously unnamed block`, so Surelog's no-name-with-an-end-label `named_fork` shape can never be produced by us.
4. **288 of 7680 probe file×view pairs produce no database on either binary** (14 of them identical segfaults). The boundary is blind there — pre-existing, unchanged.
5. **`Scoreboard/default` remains the ~50/50 coin.** This run's order-blind diff happened to be 100% fork-shaped; the coin can still move bytes on its own and must keep being attributed order-blind.

## 7. R0 confirmed

The new MiniAmiq head (80 cmp lines, 1 head) is exactly what the report names: `uvm_phase.svh:1730`, `get_predecessors_for_successors`'s `foreach (m_successors[succ])` loop-variable slot — golden `ref_var(successors)` with a `ref_typespec` → `array_typespec` at `1724:15`, ours a `hier_path`. A `foreach`/`Variables()` head, not a fork head.

Evidence lives at `/tmp/v131_wd` (both sweeps), `/tmp/v131_gridwd{,2,3,4,5}` (my arms), `/tmp/v131_moved` (boundary movers scored against golden), `/tmp/v131_cen` (UVM census), `/tmp/v131_bound.log` (3840-file boundary), `/tmp/v131_heads_{pris,pat}` (head logs). Worktrees `/tmp/wt_v131` (patched) and `/tmp/wt_v131pris` left in place; scratch pruned, disk 11%.
