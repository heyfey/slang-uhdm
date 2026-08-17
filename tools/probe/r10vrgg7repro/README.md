# r10vrgg7 — ADVERSARIAL VERIFICATION of r10rgg7 / § genIfUnvaluedFuncParam7

**VERDICT: the LAW IS RIGHT, the HEADLINE NUMBERS REPRODUCE BIT-FOR-BIT, and the
PREDICATE WAS TOO WIDE IN FOUR PLACES.  Five cells of legal SystemVerilog were
PRISTINE-RIGHT → PATCHED-WRONG; all five are FIXED here.  Ship
`/tmp/r10rgg7.verified.patch`.**

**MEASUREMENT-ONLY directory.** The official `uhdm-cmp` remains the sole
acceptance judge. **BASE `6da448b`.** `results/*.csv` READ-ONLY and untouched;
**Rggen still does NOT pass `uhdm-cmp`** and no corpus row was converted.

---

## 1. REPRODUCTION — every headline number, from my own worktrees

Both binaries were rebuilt from scratch (`-j 2`) in fresh worktrees at
`6da448b`, and their md5s are **bit-identical to the implementer's**:
`base 57a8b410c476677c5d7496851f57e28d`, `pat 636e2cb6f2a0e1e9cc096cf015fe9bed`.
Everything below is my own measurement (`GATES.txt` carries every leg):

| claim | implementer | verifier | verdict |
|---|---|---|---|
| `uhdm-cmp` Rggen/default cmp lines | 85 → 66, 1 head | **85 → 66, 1 head** | REPRODUCED |
| the new head's family | `rggen_adapter_common.sv:55:14` constant vs our `func_call(pre_decode)` | **identical `.cmp`** | REPRODUCED |
| elaborated `rggen_or_reducer` instances | 17 → 13, path-for-path golden's | **17 → 13**, `CENSUS.txt` | REPRODUCED |
| census7 differing keys | 2 → 0, golden-only 0, ours-only 4 → 0 | **2 → 0 / 0 / 4 → 0** | REPRODUCED |
| adapter-mux `g_reduce` subtree | 160 → 8, kind-for-kind golden's | **160 → 8**, kind-for-kind | REPRODUCED |
| golden's `NEXT_N` param_assign Rhs | unfolded `func_call` at all 13, both views | **confirmed, both views** | REPRODUCED |
| u2r | 679/50/2 per mode, 0 differing rows, 0 movers/1358 | **same** | REPRODUCED |
| surelog | 1588 rows, 0 differing rows, 2 movers/956 | **same two: Rggen + Scoreboard** | REPRODUCED |
| the Scoreboard mover is the COIN | asserted from `attrib7.sh` | **RE-MEASURED: 3 runs of the SAME base binary give 2 distinct md5s** | CONFIRMED |
| canary pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **both hit** | REPRODUCED |
| the rule's own witnesses | Scr1SvTests + typedef_param byte-identical | **byte-identical** | REPRODUCED |
| boundary over rgg1-6 + vrgg2-6 | 500 files, 2 movers, both CORRECTIONS | **500 files, PROCESSED=500, 2 movers, both corrections re-measured on REAL SURELOG** | REPRODUCED |
| ladder | rungs 94 → 92 FIXPOINT, one family moves | **94 → 92, `gen_scope\|<rhs-null>\|MISSING-OURS` 2 → 0, and only that** | REPRODUCED (ctladder rebuilt here) |
| firing sites over both corpora | exactly ONE: `rggen_or_reducer.sv:88:9` | **exactly ONE, both modes, both corpora** (`SITES_*.txt`) | REPRODUCED |
| whole-DB object delta | "−314/+10 = **−304**" | **−522 / +0** whole-DB containment objects | **NUMBER CORRECTED — see § 4** |

## 2. THE FIVE CELLS THAT BROKE — PRISTINE-RIGHT → PATCHED-WRONG on legal SV

`gen_grid.py` writes 40 adversarial cells (`cells/<name>/dut.sv`), each measured
against **REAL SURELOG**; `run_grid.sh` + `arms2.py` read WHICH ARM each side
elaborated (by CONTENT — both arms are always named `g_reduce`, exactly Rggen's
shape); `score.py` gives the order-blind FIXED/BROKEN verdict.  `GRID.txt` is the
whole table, `SCORE.txt` the verdict, `ARMS_FULL.txt` the raw per-instance rows.

```
score.py, shipped patch : FIXED 11  OK 15  BROKEN 5  STILL 7   <-- FIVE BROKEN
score.py, after the cuts: FIXED 11  OK 20  BROKEN 0  STILL 7
```

| cell | condition / initializer | golden | base | shipped | after the cuts |
|---|---|---|---|---|---|
| `s_pkgshadow` | `if (gp::NEXT > 1)` with a *local* unvalued `NEXT` | **if** | if | **else** | if |
| `s_memberdot` | `if (CFG.nxt > 1)` with a *local* unvalued `nxt` | **if** | if | **else** | if |
| `w_bits` | `NEXT = $bits(RAW)`, `RAW` unvalued | **if** | if | **else** | if |
| `w_ternarydead` | `NEXT = (1) ? 8 : RAW` | **if** | if | **else** | if |
| `w_defparam` | `parameter NEXT = <refused call>` + `defparam u0.NEXT = 8;` | **if** | if | **else** | if |

### 2.1 THE MIS-BIND — one cause, two faces

slang parses **`gp::NEXT` and `CFG.nxt` alike** as a `ScopedName` whose RIGHT
child is a bare `IdentifierName`.  `srlgGenIfCondUnvalued` walked every
`IdentifierName` it met and called `look0->lookupName(nm)`, so it looked
`NEXT` / `nxt` up **in the module scope** and bound a DIFFERENT symbol of the
same name.  Isolated to one cause by three variants (`/tmp/vrgg7_diag`):

| variant | member/qualified name | local unvalued param | `[genif7]` firings |
|---|---|---|---|
| `md_a` | `CFG.zzz` | `nxt` | **0** |
| `md_b` | `CFG.nxt` | `nxt` | **2** |
| `md_c` | `CFG.nxt` | `other` | **0** |

so it is the NAME COLLISION, nothing else.  **THE CUT: a `ScopedName` subtree is
never descended.** An argument list is not affected — only the name node itself
is a `ScopedName`, so `pkg::f(RAW)` still reaches `RAW`.  Cost: a
package-qualified read of a genuinely unvalued parameter is missed, which is the
implementer's own already-declared reach residue R4 (and `w_pkgparam_gate`,
which reads an IMPORTED package parameter by its bare name, still fires and
still lands on golden).

### 2.2 THE TRANSITIVE HALF over-reached in two ways

The shipped visitor treats *any* parameter read anywhere in the initializer as
poisoning.  Golden refutes that twice:

* **`$bits` reads a TYPE, not a value.** `NEXT = $bits(RAW)` is VALUED on golden
  (`w_bits`, golden keeps slang's arm).  THE CUT: the arguments of
  `$bits/$size/$high/$low/$left/$right/$increment/$dimensions/$unpacked_dimensions`
  are not descended.  **`w_clog2` is the control that keeps this honest:**
  `NEXT = $clog2(RAW)` DOES consume the value, golden takes the ELSE arm, and it
  still fires.  A cut that swallowed `$clog2` would have been measured wrong.
* **A DEAD TERNARY ARM is not evaluated.** `NEXT = (1) ? 8 : RAW` is VALUED on
  golden (`w_ternarydead`).  THE CUT: `ConditionalExpression::knownSide()` —
  slang has already decided this — selects the live arm; the *conditions* are
  still walked, so a predicate that itself reads an unvalued parameter is not
  constant and falls through to the full walk.

### 2.3 A DEFPARAM TARGET IS OUTSIDE THE CLAIM

With `defparam u0.NEXT = 8;` the value comes from the defparam and golden keeps
slang's arm, but slang hands this predicate the DECLARED initializer (the
refused call) and the shipped patch flipped it.  THE CUT: the NAMES a `defparam`
targets are collected from SYNTAX in `computeCompoundWriteBack`'s existing root
walk (so nothing is resolved and no diagnostic can be minted), and such a
parameter is never claimed.  Keyed on the NAME because the def-view and
instance-view symbols are different objects.  `w_override_val` /
`w_override_unval` are the controls that prove this did not swallow ordinary
parameter-port overrides: golden keeps slang's arm for `.NEXT(8)` over a refused
default, and takes the ELSE arm for `.NEXT(<refused call>)` over a literal
default — **both still correct after the cut**.

**All four cuts are STRICT NARROWINGS: they can only remove a flip, never add
one.**  Measured: `pat -> vfix` is **0 movers over 1358 u2r and 956 surelog
databases**, and the one firing site is unchanged.

## 3. WHAT THE LAW GETS RIGHT — 22 confirmations the verifier adds

The grid confirms the law well beyond the implementer's own cells:

* **the poison source is real and arm-decisive** (`b_poison`), and it does not
  care whether the arms are NAMED (`b_unnamed`);
* **the CONDITION is false, not the identifier zero**, through three more
  indirections the brief asked for: `RAW - 1 > 0`, `RAW != 1`, `!(RAW <= 1)`
  (`w_indirect_*`) — all three take the ELSE arm on golden;
* **`$clog2` of an unvalued parameter is unvalued** (`w_clog2`);
* **two parameters, only one unvaluable**: `(N > 1) || (RAW > 1)` with `N = 8`
  takes the ELSE arm on golden (`w_or`) — the invalid operand poisons the whole
  condition even under `||`; and `(N < 0) && (RAW > 1)` agrees with slang
  (`w_andfalse`);
* **an override actual that is a refused call** propagates (`w_override_unval`);
* **an IMPORTED package parameter** whose initializer is a refused call fires
  once the cost gate is open (`w_pkgparam_gate`);
* **an `else if` chain falls all the way through** (`x_elseif`: golden `c_mark`);
* **an else-less chain emits NO gen_scope_array** (`x_noelse`);
* **recursion 1..4 deep** is unharmed when the condition is valued
  (`r_valued_d1..d4`, 4 controls) and collapses to golden's single instance when
  it is not (`r_unval_d2`, `r_unval_d4`);
* **13 controls hold on both binaries**: literal, folding call, `$clog2(8)`, a
  folding call written straight into the condition, a multidim-packed parameter
  whose function folds, an unvalued parameter merely PRESENT but unread
  (`c_unread` — the cheapest way this could have been a blunt instrument, and it
  is not), a genvar condition inside a generate-for, and a gen-scope-local
  VALUED parameter shadowing an outer unvalued one (`s_genshadow`).

## 4. NUMBERS I COULD NOT REPRODUCE

**"whole DB −314/+10 = −304".**  A containment-only object census of the whole
Rggen dump (`dbcensus.py`, plus a `dumptree` walk) measures **−522 objects and
+0** base → pat.  `−304` is exactly `2 × (160 − 8)`, i.e. the TWO adapter muxes'
`g_reduce` subtree delta, which DOES reproduce — so the figure is a **region
number labelled as a whole-database number**, not a wrong conclusion.  The
direction and the landing are right and are what matters: every kind that moves
moves TOWARD golden, and six of them land EXACTLY on golden's count
(`always 374→370=370`, `gen_scope 4412→4408=4408`, `gen_scope_array` likewise,
`module_inst 665→661=661`, `port 5908→5900=5900`, `logic_var 19640→19632=19632`).
The DEF section is byte-for-byte unchanged (21058 objects, every kind equal), so
"DEF untouched" holds.

## 5. RANKED RESIDUES — measured here, NOT claimed and NOT built on

* **R1 — THE CHAIN WALK TRUSTS SLANG'S VERDICT FOR ARMS AFTER A MISEVALUATED
  ONE, and golden does not.**  `x_mixed_chain`:
  `if (RAW>1) A else if (N>1) B else C` with `RAW` unvalued and `N = 8`.
  Golden takes **B**; the pristine base takes A; the patch takes **C**.  The
  cause is in the PRE-EXISTING `genIfUnitMisevalFalse` walk: the second arm's
  `inst9` comes from slang's own `isUninstantiated`, which is meaningless once an
  EARLIER condition has been re-decided, so a later arm that golden re-evaluates
  to TRUE is skipped and the chain falls to the `else`.  **NOT FIXED HERE:
  closing it means evaluating conditions ourselves inside a function whose
  witnesses include the `Scr1SvTests` canary, which is exactly the kind of
  change a verifier must not make on the way out.**  Base and patch are both
  wrong here, so it is not a regression — it is the highest-value next pass.
* **R2 — A MISEVAL-TAKEN ARM EMITS NEITHER ITS CHILD MODULE INSTANCES NOR ITS
  NESTED GENERATE CHAIN.**  Two faces, both measured:
  `r_unval_d2` / `r_unval_d4` — golden's taken else arm contains
  `leaf u_leaf (...)` and golden emits it (`LEAF=1`); we emit the arm with
  `LEAF=0`.  `x_nested` — golden's taken else arm holds a nested
  `if (N>1)/else` and golden emits `b_mark`; we emit the outer gen_scope with
  **no marks at all**.  Same cause: `emitBlock` on an uninstantiated
  `GenerateBlockSymbol` walks members whose children slang also flagged
  uninstantiated, and the nested chain then has `anyInst9 == false` so the rule
  declines to re-decide it.  PRE-EXISTING in § `genIfUnitMisevalFalse`; newly
  reachable.  Rggen's else arm holds only an `always_comb`, which is why the
  target row is unaffected.
* **R3 — THE REACH GAP THE IMPLEMENTER DECLARED (their R4) IS REAL, MEASURED.**
  `w_pkgparam_nogate`: a PACKAGE parameter whose initializer is a refused call,
  read by a generate-if, in a design where no module parameter calls a function —
  the `funcParamCallSeen9` cost gate never opens and we keep slang's arm where
  **golden takes the else**.  Same for a `$unit`-scope parameter
  (`w_unitparam`), which the existing `unitParamNoValue` machinery also misses.
  Two named cells for a future pass; widening the gate needs its own boundary run.
* **R4 — CASE-GENERATE and GENERATE-FOR are not modelled for this source.**
  `x_casegen` (`case (RAW) 8: A default: B` — golden takes `default`),
  `x_genfor` (`for (gi = 0; gi < RAW; gi++)` — golden emits NO gen_scope_array at
  all, we emit 8), and `x_genfor_body` (a generate-if inside a generate-for
  BODY never reaches the rule at all, because the only `GenIfPick` consumer sits
  in `emitGenScopes`, which runs at instance-body level only).  Three cells.
* **R5 — the implementer's own R1/R2/R3/R5 stand as filed** (the `addup(RAW)`
  VALUE face, rgg6's 13 other-view typespec'd `func_call`s, gen-scope localparam
  chains, the two span-only typespec residues).  Untouched here.
* **R6 — A FENCE BREACH IN THE SITESCAN DRIVER, FOUND AND CLOSED HERE.**
  `r10rgg7repro/sitescan.py` walks the WHOLE corpus and therefore DISPATCHED the
  four slang-fenced rows; my own run's `SITES_sl_default.txt` then SPELLED TWO OF
  THEM as `NORUN` lines.  Both halves are fixed: the driver now carries an
  explicit `FENCED` set (skipped and COUNTED, and the summary line reports
  `FENCED=n`), and the two names are REDACTED from the artifact.  Nothing is lost
  by the fence: each of those rows produces no database on either binary, so no
  firing site can hide behind it.  `canaudit.sh canaries.sh ctcan2.sh` re-run
  after the edit: audited=29 UNCOVERED=0 FENCE-BREACH=0.
* **R7 — sitescan coverage caveat.**  338 / 313 surelog rows and 230 / 123 u2r
  rows are NORUN (slang produces no database), so no firing site in them was
  OBSERVED.  A row with no database cannot move, so this bounds the claim
  without weakening the gate.

## 6. FILES

| file | what it is |
|---|---|
| `gen_grid.py` | writes all 40 adversarial cells |
| `run_grid.sh` | REAL SURELOG + any number of slang binaries per cell; NODB/NOSLANG printed and COUNTED |
| `arms2.py` | WHICH ARM each database elaborated, per instance and view, arm decided by CONTENT; exits 3 on a dump with no instance |
| `score.py` | the order-blind FIXED/BROKEN/STILL/OK verdict; a one-sided key is MISSING-KEY, never OK |
| `dbcensus.py` | whole-dump SECTIONED (DEF/ELAB/TAIL) + DEPTH-KEYED object census with per-kind deltas |
| `boundary.sh` | the boundary comparator: fd-3 file list, children `</dev/null`, **PROCESSED asserted against the list length** |
| `dumptree.py` | the shared indent-tree parser (containment edges only), carried from `r10rgg7repro` |
| `GRID.txt`, `SCORE.txt`, `ARMS_FULL.txt` | the measured grid, the verdict, the raw rows |
| `GATES.txt` | every gate leg, every mover named and attributed |
| `CENSUS.txt` | census7 / subtree7 / dbcensus for golden, base and patched |
| `BOUNDARY.txt`, `BOUNDARY_POSCONTROL.txt` | the boundary run and its positive control |
| `SITES_*.txt` | every firing site over both corpora, both modes, from the vfix binary |
| `HEAD_{BEFORE,AFTER}_default_Rggen.cmp` | the official `uhdm-cmp` head, both sides |
| `LADDER_{BEFORE,AFTER}_default_Rggen.txt` | the measurement-only ladder, both sides |
| `PREDICT_MOVERS.txt` | the mover prediction, filed BEFORE the vfix sweeps ran |

Reproduce:

```sh
python3 gen_grid.py
./run_grid.sh /tmp/g <base-bin> base <pat-bin> pat <vfix-bin> vfix
python3 score.py /tmp/g pat vfix
./boundary.sh /tmp/B <base-bin> <vfix-bin> vfix -- ../r10rgg[1-6]repro ../r10vrgg[2-6]repro
```
