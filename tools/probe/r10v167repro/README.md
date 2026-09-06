All gates and the full adversarial grid are complete. Final report:

---

# VERDICT: **ACCEPT** — `/tmp/r10uvm167.patch` ships unchanged (no `.verified.patch` needed)

Every headline number reproduced **bit-for-bit** from my own worktrees and my own builds. I found **no pristine-right → patched-wrong cell on legal SV**; the one direction-negative shape I did find is provably not a lost `CMP_EQUAL` (both binaries fail it, at different depths) and is recorded as ranked residue **RV1** below.

## 1. Reproduction — independent, from scratch

| claim | implementer | **my measurement** |
|---|---|---|
| patch md5 | `9dfd0ade51772da89f3ea88a687c4ece` | **same** |
| applies clean on FRESH `11bff799` | yes | **`git apply -3` rc 0, both files "cleanly", 0 conflict markers, `git status` = the 2 production files only** |
| pristine binary md5 | `e4b0ad2eaaa961655ca6db50502e4928` | **same** (built in `/tmp/wt_v167pris`, `-j 2`, frozen `chmod 555` at `/tmp/v167_bin/pris.bin`) |
| patched binary md5 | `4e483ba954976cc5b68a417184b72470` | **same** (built in `/tmp/wt_v167`, frozen at `/tmp/v167_bin/pat.bin`) |
| surface | `src/EmitHelpers.h` +85, `src/ExprEmit.cpp` +47/−16, `tools/probe/r10uvm167repro/` only | **confirmed by `git apply --stat`; no `results/*.csv`, no slang, no stray paths** |
| fences | 0/0/0/0 | **0/0/0/0** (all four names, `canaudit` excluded) |

**Heads, my own sweeps** (`rowheads.sh`, both binaries):

| row-mode | pristine | patched |
|---|---|---|
| SeqDriver default / testflags | **338 / 338** | **50 / 50** |
| SimpleUVM default / testflags | **338 / 338** | **17 / 17** |
| Scoreboard def 95 · MiniAmiq 106×2 · BuildUVMPkg 29×2 · Earlgrey 34×2 · Rggen 0 | — | **all unchanged** |

All **24 committed `head_pris_*/head_pat_*.cmp` artifacts are byte-identical to mine** (modulo object ids). The pristine head is the `method_func_call uvm_report_fatal` at `720:14` `tf_call::Compare:95` vector; the two new R0 heads (`adpcm_pkg::uvm_revision_string` folded-constant `VpiType`, and the `LHS: <null>` `ref_typespec` on `uvm_is_match::s`) are exactly as described.

## 2. Gates — all green, measured by me

| gate | result |
|---|---|
| goldens, `SLANG_UHDM` exported per binary | pris **23 PASS / 0 FAIL**, pat **23 / 0**; `/bin/false` **0 PASS / 23 FAIL** |
| uhdm2rtlil, both modes, both binaries | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** ×4 |
| `ct8rows` u2r (committed baseline ×2, pris-vs-pat tf, pris-vs-pat def) | **PASS ×4 — 0 differing ROWS**, status *and* dump column |
| surelog `--mode both` (956 DBs each) | pristine histogram = committed baseline exactly (`CMP_NOTEQUAL` 10 def / 9 tf); **`ct8rows` vs committed baseline PASS for the PATCHED sweep too — 0 differing ROWS. NO ROW CONVERTED.** `results/*.csv` never written |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1358**, SELFCHECK 1357/1358 |
| `byteverify SELFCHECK=1` surelog | **MOVERS 7 / 956**, SELFCHECK 955/956 — `default/{MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}` + `testflags/{MiniAmiq,SeqDriver,SimpleUVM}`, **exactly the predicted set, by name, nothing else** |
| mover attribution, ORDER-BLIND (sorted, path- and id-normalised dumps) | **every mover: 30 differing lines, 30 deletions, 0 additions**, all four constants `236:33 ""`, `237:37 0` (on `uvm_report_fatal@720:14`) and `171:36 ""`, `172:39 0` (on `uvm_report_warning@725:14`). Nothing outside the law. `default/Scoreboard` (the coin) also 30 lines of 1,100,372 — the flip did not land |
| canaries / ctcan2 / canaudit | `ok=52 changed=0`, `ok=8 changed=0`; ctcan2 **PASS ×2**; `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME**; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** — pins hold |
| `cmds.txt` audit BY BINARY PATH | surelog 1573 files, 1523 slang lines, **only `/tmp/v167_bin/{pris,pat}.bin`**; u2r 1462 files, 1458 lines, same. **leak = 0** on all four sweeps. No `rc=139` masquerade (SLANG_REJECT counts identical to baseline) |
| **WIDE BOUNDARY** (my own driver, fd-3 list, `</dev/null`, rel-path scratch, rc recorded) | **`LISTED=4689 PROCESSED=4689 PRODUCED_DBS=9050 MOVED_ARMS=8 (=4 arms × 2 views) RC_DIFFS=0`** |

**Boundary detail.** The four moved arms are `g167_a_shell`, `g167_b_spell`, `g167_c_homes` (the pass's own positive control — the gate can see) and the one foreign arm `r10v103repro/arms/v103_c5_slots.sv`, which I re-judged: **176 (def) / 208 (elab) → 0, CMP_EQUAL in both views.** `g167_d_decline` is byte-identical, as designed. Must-stay controls all **listed and unmoved**: `r10uvm161repro` (4 arms), `r10uvm164repro` (4), `r10uvm166repro` (5), `r10uvm89repro` (2), `r10buvm14repro` (1), `r10uvm84repro` (23), `r10sd8repro` (37). *(`r10uvm165repro` does not exist at `11bff799` — that pass has not landed under that name; nothing to control.)*

I also independently reproduced the implementer's own arm-judge table exactly: `a_shell` 210/218→**38**, `b_spell` 88/166→**0**, `c_homes` 120/128→**17**, `d_decline` 0→0.

## 3. Breaking the law — my own 12-arm grid (`/tmp/v167_arms/v[A-L]_*.sv`)

Built independently, every arm with a Surelog golden in **both views**, scored as a **multiset census of direct `vpiArgument` counts per call-object occurrence**, with the `\_weaklyReferenced:` tail cut off first (it is unreachable to the judge, and it manufactured two phantom AWAY cells before I cut it — a trap worth recording).

Faces covered: written-argument-textually-identical-to-its-default · named out of order · middle default reached by later named *and* later positional · all-defaulted / empty parens · written-but-empty slot · paren-less task call · zero-formal calls · constructor with defaults · `super.new` · `this.` / `super.` method calls · static `Class::m()` · hierarchical calls · interface method calls · virtual method through a **base** handle · DPI import · system tf (no-default control) · the same callee written-full and defaulted in **one** method. Homes: package class · in-class bare · module · interface · program · **compilation unit** · generate process. Two independent shell mechanisms (generic-class `T::nm` and `nosuch::val` in an uninstantiated generate branch). 1–3 instances. Both views.

**Score, identical in DEF and ELAB: `TOWARD 39 · AWAY 3 · MOVED-OTHER 3`.**

Judge on the arms: `vA_meth` 80/96→**0**, `vB_bare` 88/88→**0**, `vD_kinds` 80/96→**0**, `vL_this` 104/112→80/96, `vF_gen`/`vI_inh` 36/36 with 4–6 TOWARD cells each.

Two arms tested **nothing** and I say so: `vC_homes` and `vE_hier` put the class in a module/interface/program, and **our emitter emits no class declared inside a module, interface or program at all** (15 and 11 `OURS={}` residue cells) — an arm agreeing is not an arm testing. I rebuilt those homes class-free (`vG`, `vH`, `vJ`, `vK`) and that is where the one negative shape surfaced.

The 3 `MOVED-OTHER` cells are objects **golden has none of**: the `::`-scoped static call in a shell (the implementer's declared R1 abstain — golden emits a bare `ref_obj`, no call) and two interface-generate-process `method_func_call`s we mint where golden has a `func_call`. Neither has a golden vector to move away from.

## 4. Ranked residues

**RV1 — the one AWAY shape, and why it is not a regression.** A **shelled, receiver-less, NAMED call that skips a middle formal, to a COMPILATION-UNIT (`$unit`) function, inside a DEF-view generate process** — where our `linked4` is false (`defGenProcessEmit`, `ExprEmit.cpp:22113`) so § `namedTfArgsFormalSlots4` does not fire. Golden lists **3** (one slot per formal); pristine listed **3** (the bound list); patched lists **2** (the written count). Minimal isolation is `/tmp/v167_arms/vK_min.sv`, and the judge settles it:

- **pristine head = the ELEMENT mismatch** — golden's placeholder `constant INT:0 vpiConstType:7` vs our default clone `UINT:0 vpiConstType:9` (`constant::Compare:66` reads `VpiConstType`). **32 cmp lines, NOTEQUAL.**
- **patched head = the VECTOR SIZE mismatch.** 96 cmp lines, NOTEQUAL.

Same verdict, different depth — **no `CMP_EQUAL` can be lost by this shape**, and belt-and-braces: `func_call::Compare:77` also compares `Function()`, which golden has here and we never emit in a def-gen-process call. The decisive control is `/tmp/v167_arms/vH_named.sv`: the **CLEAN twin of the same call also answers 2** on both binaries, so the patch is exactly consistent with its stated law ("identical to what it would have answered had slang not wrapped the call"). This is an **unmasking** of a pre-existing § `defGenCallNoBind` / § `namedTfArgsFormalSlots4` gap (golden resolves a `$unit` function there and not a module-local one — `gm167` golden 2, `uf167` golden 3, same position), not a defect of § `shellCallKeepsItsSyntax167`. Its trigger also needs a name that does not exist, in an uninstantiated branch — not legal SV. The **legal-SV** twin of the other `linked4==false` gate (`inheritedNoBind9`: a bare NAMED call to an inherited base-class method, `/tmp/v167_arms/vI_inh.sv`) is **5 TOWARD, 0 AWAY** — golden trims there too.

**RV2** — classes declared inside a module / interface / program are not emitted at all (`vC_homes` 15 cells, `vE_hier` 11 cells, `OURS={}`); those homes are untestable for any call law until that is fixed. Pre-existing, unrelated, unchanged by this patch.

**RV3** — an interface generate process mints a `method_func_call` where golden has a `func_call` (`vG_nocls` 36:50 / 37:37). Pre-existing shape divergence; the patch only moved its argument count from 3 to golden's 2.

RV4–RV7 = the implementer's own R1 (`::`-scoped static call abstain, reproduced as my one ORPHAN), R2 (`super.`'s missing `constant` prefix), R3 (elab copy count), R5 (`$warning` in `testflags/Earlgrey_0_1`) — all confirmed unchanged.

## 5. Code review of the law itself

`callInvocation167` is textually equivalent to the expression it replaces whenever `call.syntax` is set, so nothing off the shell can move — and `g167_d_decline` plus 949/956 + 1358/1358 byte-identical databases prove it empirically. The RAII guard is armed at the single unwrap site keyed on the **exact child pointer**, saves/restores unconditionally, and is inert when the shell's syntax is not an invocation. Re-entrancy is safe: `grep -rn 'std::thread|#pragma omp|std::async|jthread|ThreadPool' src/ include/ uhdm_main.cpp` is **empty** — the emitter is single-threaded; slang's parallelism is parse-only.

I specifically hunted for an out-of-range read, since `bindArgs` sets `bad` **without breaking** on `TooManyArguments` / `ArgDoesNotExist` (so the written count can exceed `arguments().size()`) and **breaks early** on `TooFewArguments` (so it can be smaller). All five readers are safe: `writtenArgs16` clamps with `std::min`; `ExprEmit.cpp:22320`'s loop is bounded by `call.arguments()` with `argIdx >= nWritten9 → break`; `writtenFormalIdx4` rejects on `f >= formals.size() || f >= nbound`; `namedTfSlots4`/`emptyArgSlots24` size from the formal list. No OOB, no crash on any arg-count-mismatch shell I could construct.

Probe hygiene is clean: every script `mktemp`s under a pass-prefixed `/tmp/r10uvm167_*` name and `rm -rf`s only that; no hard-coded foreign-pass paths, no shared-scratch deletion, no fenced names.

## 6. Notes for the integrator

- **Main has moved past this patch's base.** `11bff799` → main is now `39f286ef` (UVM pass 165 landed mid-verification; the implementer's note said `cd1e4c0a`). I verified apply + build + gates **on `11bff799` only**, as briefed. Re-run `git apply -3` and the build on the current head before committing.
- Untracked stray `heads_patc` sits in the **main tree root** (present before this session, gitignored so `git status --short` stays quiet). Not from this pass; worth removing.
- Controls kept for you: `/tmp/v167_bin/{pris,pat}.bin` (frozen 555), `/tmp/v167_wd/{sl_pris,sl_pat,u2r_pris,u2r_pat}` + the 6 CSVs, `/tmp/v167_heads_{pris,pat}`, `/tmp/v167_wd_grid` (13 judged arms), `/tmp/v167_bnd/{list,moved,rcdiff}.txt`, arms at `/tmp/v167_arms/v[A-L]_*.sv`, drivers `/tmp/v167_{grid,bound,attrib}.sh`, `/tmp/v167_{argcen,score,resid}.py`. Disk after cleanup: 858 G free on `/tmp`.