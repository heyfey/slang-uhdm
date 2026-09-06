# r10v165 — the ADVERSARIAL VERIFICATION of r10uvm165 (§ `droppedCallArgTakesTheOrdinaryWindow165`) — **ACCEPT-WITH-FIX (documentation only; the binary is byte-identical)**

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**
and **NO CORPUS ROW WAS CONVERTED**. `GOLDEN_DEFER` stayed unset. The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b9d5c606` |
| verifier's PRISTINE binary | md5 `ac0350d07c685ac10b106abce26ec554` — built by the VERIFIER from its own fresh `b9d5c606` worktree, frozen `chmod 555` before any sweep |
| verifier's PATCHED binary | md5 `8bac95ba55a581dfcc3c903251686479` — the implementer's patch applied to another fresh `b9d5c606` worktree and rebuilt there. **Both md5s reproduce the implementer's headline numbers BIT FOR BIT.** |
| after this verifier's edits | still `8bac95ba55a581dfcc3c903251686479` — the fix is COMMENT-ONLY, so every measurement below stands unchanged for the `.verified.patch` |
| verdict | **ACCEPT-WITH-FIX** — no behavioural defect was found; one sentence of the pass's own law text was measurably wrong and is corrected |

## READ THIS FIRST

| | |
|---|---|
| AWAY cells (pristine-right → patched-wrong) | **ZERO**, over 5 adversarial arms x 2 views (118 cell identities), the whole `BuildUVMPkg` corpus row (16 096 argument identities), and `r10uvm59repro/a1_witness.sv`. |
| the corpus row, independently censused | **exactly ONE cell moves, TOWARD**: `ref_obj alias_name @14098:35`, golden BARE, pristine `BOUND->io_decl(alias_name)@14091:46`, patched BARE. 86 pre-existing disagreements unmoved; distance 158 → 156. |
| the head | `BuildUVMPkg` default and testflags, **29 / 1 head → 60 / 1 head**, the two logs byte-identical, and byte-identical to the implementer's committed `head_{pris,pat}_BuildUVMPkg.*.cmp`. |
| byte movers | **2 / 956** surelog (both predicted, both BuildUVMPkg; the Scoreboard coin happened to land the same way this run) and **0 / 1358** uhdm2rtlil. Each moved database's order-blind dump diff is **exactly 2 lines, both removals**. |
| gates | goldens 23/0 patched, 23/0 pristine, `/bin/false` 0/23; u2r 679/50/2 both modes and **0 differing rows**; surelog 1588 rows, **0 differing rows**, histograms cell-for-cell identical; canaries ok=52 / ok=8 changed=0; ctcan2 PASS x2; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`. |
| wide boundary | LISTED=PROCESSED=**4682**, MOVED_ARMS=**8**, RC_DIFFS=**0** — 3 of the pass's arms, 4 of this verifier's arms (the positive control), and `r10uvm59repro/a1_witness.sv`. **`g165_a_sep.sv` did not move**; no uvm161 / uvm164 / buvm / uvm77-91 / sd8-12 arm moved; `v161_d_break.sv` unmoved. |

---

## 1. WHAT WAS REPRODUCED, BIT FOR BIT

Both binaries were rebuilt by this verifier from its own fresh `b9d5c606`
worktrees (`cmake -j 2`, md5 taken separately) and frozen at
`/tmp/v165_bin/{pris,pat}.bin` **before any sweep**. Every `cmds.txt` in all
four sweeps was audited by BINARY PATH: 1523 + 1523 + 1458 + 1458 invocations,
**zero** naming any binary other than the frozen pair. `GATES.r10v165.txt`
carries the full transcripts.

The implementer's `29 / 1 head → 60 / 1 head`, the two logs byte-identical, the
R0 constant (`uvm_pkg.sv:8504`, golden `INT:3 / vpiConstType:7` vs ours
`UINT:3 / vpiConstType:9`), the 2-line order-blind attribution, the u2r
`679/50/2`, the surelog histograms (default `CMP_NOTEQUAL 10`, testflags `9`)
and every canary pin all reproduced without a discrepancy.

---

## 2. THE ATTACK: FIVE ARMS THE PASS DID NOT WRITE

Every arm is scored by this verifier's OWN instruments — `vcen165.py` parses
`uhdm-dump` text into an indentation tree and records, for every argument of
every call, **the TARGET of its `vpiActual`** (`kind(name)@line:col`), not
merely its presence. That distinction decided the pass (§4). `vscore165.py`
joins golden / pristine / patched as MULTISETS on the cell identity.

| arm | what it throws at the gate | def | elab |
|---|---|---|---|
| **A** `v165_a_carriers.sv` | every control carrier the pass's arms did not spell — `case` item, `case default`, `casez`, `casex`, `unique if`, `priority if`, an `else if` CHAIN and its final `else`, a NAMED block inside an `if`, a `fork` arm inside an `if`, `forever`, `do-while`, `repeat`, `while`, `for`, `foreach` — plus a top-level plain `begin`, plus the **distinguisher pair** the brief asked for: ONE method carrying the SAME call with the SAME formal at d0, d1, d2 and d3 | 26 idents, **22 TOWARD, 0 AWAY**, distance **44 → 0** | 26 idents, **21 TOWARD, 0 AWAY**, distance **42 → 0** |
| **B** `v165_b_shadow.sv` | the SYMBOL side: a block local that SHADOWS a formal; § 57's unnamed-block local at the same depth; an argument that is an EXPRESSION or an INDEXED use; 1 / 2 / 3 actuals of mixed kinds; a for-loop iterator | 30 idents, **9 TOWARD, 0 AWAY, 2 SIDEWAYS**, distance **30 → 12** | 30 idents, **2 TOWARD, 0 AWAY, 2 SIDEWAYS**, distance **20 → 16** |
| **C** `v165_c_homes.sv` | the HOMES: an OUT-OF-BODY definition at d0..d3 (static and non-static), a `$unit` generic class at d0..d3, a MODULE-homed generic class, a constructor, a static method, a virtual method, a task, the `this.` / chained `a.b.c` / `C::m` receiver faces, and a **MODULE-scope function control** whose arguments must stay golden-bound at d0/d1/d2 | 27 idents, **7 TOWARD, 0 AWAY**, distance **19 → 5** | 32 idents, **4 TOWARD, 0 AWAY, 1 SIDEWAYS**, distance **35 → 25** |
| **D** `v165_d_idxrecv.sv` | § `droppedIdxRecvCall26`'s SUBSCRIPTED receiver at d0..d3 over a fixed array, a queue and an associative array, with a CONSTANT and a VARIABLE index, in an `else`, a `case` item and a `foreach` body, plus the EXPRESSION-position twin | 22 idents, **13 TOWARD, 0 AWAY**, distance **26 → 0** | 22 idents, **12 TOWARD, 0 AWAY**, distance **32 → 8** |
| **E** `v165_e_assert.sv` | the carriers that are NOT among `CtrlBody28`'s ten raise sites, and therefore must KEEP binding: an immediate `assert`'s PASS and FAIL action blocks (the § `assertCondIsAClassMethodWindow161` neighbourhood), `assume`, a `wait` statement, an event control, and `fork…join` / `join_any` / `join_none` | 13 idents, **1 TOWARD, 0 AWAY**, distance **2 → 0** | 13 idents, **1 TOWARD, 0 AWAY**, distance **2 → 0** |

**Arms A and D reach golden EXACTLY** — 0 differing lines against the Surelog
golden in both views. **No arm produced a single AWAY cell.**

Three results are worth naming individually.

* **The distinguisher pair (arm A `p0`/`p1`/`p2`/`p3`).** One in-body class
  method, one receiver, one formal, four depths. Golden: `p0` BOUND, `p1`/`p2`/
  `p3` BARE. Pristine: all four BOUND. Patched: golden's pattern exactly. No
  rule other than depth produces that.
* **`else if` and the final `else`.** Golden leaves both BARE; the patched gate
  agrees. `CtrlBody28`'s `if_else` arm declares its guard OUTSIDE the
  `ifTrue`/`ifFalse` pair (`StmtEmit.cpp` ~:4177), so the else column is
  covered — measured, not read off the source.
* **The module-function control.** `vmod_c::mfn` calls `mhelp(knob)` at d0, d1
  and d2. Golden, pristine and patched all bind `io_decl(knob)@150:25` /
  `io_decl(cogs)@150:35` at every depth: `curSubClassScope9` keeps the ordinary
  path out of reach, exactly as the law claims.
* **Out-of-body at four depths (arm C `O0..O3`).** Golden BINDS all of them and
  both binaries keep binding them. A depth-only gate would have stripped
  `O1`/`O2`/`O3`; `!curSubOob9` is load-bearing and correct.

`v165_e_assert.sv` was written after the boundary copy was taken, so it is not
among the 4682 arms; it was scored directly and is committed here.

---

## 3. THE ONE THING A CARELESS ARM DESIGN WOULD HAVE BROKEN

An arm that DECLARES a specialization of the generic class (`Bins #(int) b1;`)
does not test this law at all: slang then elaborates that specialization,
REPORTS the type errors, and **rejects the whole file (rc=3)** — no database on
either side. The dropped-call path exists only for the UN-INSTANTIATED generic
body, where slang suppresses its diagnostics, which is the corpus's own shape
(`uvm_registry_common`'s default specialization). Two of this verifier's arms
had to be rewritten for that reason and the note is left in both files so the
next reader does not repeat it.

---

## 4. THE FIX — § `shadowedBlockLocal165v` (DOCUMENTATION, NOT BEHAVIOUR)

Arm B is the only arm that made the patched binary look worse than the pristine
one, and it is the reason the census had to read the vpiActual's **TARGET**.

```systemverilog
26      function void shadow_fn(string wick, int knob);
27         m_sink.stow(wick);                  // s_top   d0
28         if (flap) begin
29            string wick;                     // SHADOWS the formal
30            wick = "inner";
31            m_sink.stow(wick);               // s_shad  d1
32         end
```

A presence-only census reads cell `s_shad` as `G=BOUND / pris=BOUND /
pat=BARE` — an **AWAY**, i.e. a regression. The dump says otherwise:

```
golden    |vpiActual: \_string_var: (vpk_b::Shadow::shadow_fn::wick), line:29:20   <- the BLOCK LOCAL
pristine  |vpiActual: \_io_decl:    (wick),                           line:26:38   <- the FORMAL
patched   (no vpiActual)
```

`ref_obj::Compare` reads `Actual_group`, so the pristine cell was **already
wrong** — it bound a different object. The patch replaces one wrong value with
a missing one: **SIDEWAYS on the judge, never AWAY.** With the target-aware
census, arm B has 0 AWAY and its distance to golden falls 30 → 12 (def).

What this proves about the pass's own text: the committed README asserted that
§ 57's carve-out *"cannot reach this position… `currentSubSym->find` … never a
block local."* **The mechanism half of that sentence is false.** `find`
resolves in the SUBROUTINE's scope, so it misses a block local *whose name is
unique* (cells `b_blk` d1 and `b_blk0` d0: golden BOUND, **both binaries
BARE** — a residue neither owns), but it SUCCEEDS whenever the block local
shadows an outer name, and the pristine binary did emit a `vpiActual` there.
The pass's CONCLUSION survives intact — nothing golden had right was taken
away — but the reason it survives is that the pristine cell was wrong, not that
the position is unreachable.

**The fix, both comment-only:**

1. `include/UhdmExporter.h` — a `VERIFIER NOTE (r10v165, §
   shadowedBlockLocal165v)` under the law, recording the reachable case, the
   measured cells, and the instruction that a future pass implementing § 57
   here must bind the BLOCK's symbol rather than whatever `find` returns.
2. `tools/probe/r10uvm165repro/README.md` § 3 — the false sentence replaced by
   the measured one.

Rebuilt after both edits, the binary is **still
`8bac95ba55a581dfcc3c903251686479`**, so no measurement in this directory or in
`r10uvm165repro/` needs re-taking.

---

## 5. WHAT THE VERIFIER CONFIRMS ABOUT THE LAW ITSELF

* **The refutation is real.** `g165_a_sep.sv` did not move in a 4682-arm
  boundary run under either binary, and arm A reproduces golden cell-for-cell
  on both binaries at every receiver face — the ordinary path never had a
  missing window. The head was a RECOVERY-path defect.
* **Each conjunct earns its place.** `ctrlBodyDepth28 > 0`: arm A's four-depth
  pair and its fifteen carriers. `!curSubOob9`: arm C `O0..O3` and `OS2`, which
  a depth-only gate would have stripped. `curSubClassScope9`: inert as claimed,
  and the module-function control shows why it must be there anyway.
* **The second site is owed.** Arm D moves 13 cells at the subscripted
  receiver, all TOWARD, and reaches golden exactly in the def view; gating only
  `emitDroppedCall14` would have left every one of them wrong.
* **The expression-position arms are untouched**, measured on arm D's `x_rhs0`,
  `x_cond0`, `x_rhs1`, `x_ret1` and arm B's `x_expr*` / `x_idx*` (which produce
  no cell at all on either side — § `droppedCall14`'s shape test rejects an
  operand that is not a plain identifier or a plain dotted pair).

---

## 6. RESIDUES THE VERIFIER NAMES (none owned by this pass)

| tag | what it is | evidence |
|---|---|---|
| **R-blklocal** | golden BINDS a call argument that names a variable declared in an UNNAMED statement block, at depth 1 AND at depth 0 (§§ 57/64); the dropped path binds neither, because `currentSubSym->find` resolves in the subroutine's scope | arm B `b_blk` (d1) and `b_blk0` (d0): golden `BOUND->string_var`, pristine BARE, patched BARE |
| **R-shadowtarget** | when such a block local SHADOWS an outer name, `find` returns the OUTER symbol; any future implementation here must bind the block's own symbol | arm B `s_shad`, `s_shad2` (§4) |
| **R-modcls** | a generic class homed in a MODULE: golden emits the body and binds at d0, we emit **no cells at all** | arm C `M0`/`M1`/`M2`: golden 1 (def) / 3 (elab) cells each, ours zero, identical before and after |
| **R-namedblk** | `if (…) begin : nm` inside a generic class body: golden emits a `named_begin` carrying the label, we emit a plain `begin` — this is the head arm A falls back to after its own is cleared, and it is byte-identical under both binaries | arm A def head after the patch; `named_begin` count golden 2 / pristine 0 / patched 0 |
| **R-thisrecv** | `this.<prop>.m(x)` produces no argument cell on our side in either view | arm C `R_this0`/`R_this1` |
| **R-idxelab** | in the ELAB view a subscripted receiver's argument binds `int_var(m_fix)` where golden binds `int_var(wick)` at the same span | arm D elab `53:32`, `54:30`, `58:35`, `59:36`; identical on both binaries |

`R-blklocal` is the one with a corpus face: `r10uvm59repro/a1_witness.sv`'s
`rgtry` cell is golden `BOUND->ref_var(rgtry)` and BARE on both binaries. It is
**not** live on the corpus row itself — in `uvm_pkg.sv` golden leaves
`rgtry@14098:46` BARE and so do we, before and after.

---

## 7. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `vgrid165.sh` | the verifier's arm driver: Surelog + BOTH binaries, BOTH views, every command echoed WITH ITS BINARY PATH into `cmds.txt`, every rc recorded (no rc=139 may read as a result), workdir from argv, nothing hard-coded outside it. |
| `vcen165.py` | the verifier's OWN argument census, written from the dump text and not from any of the pass's instruments. Records the **TARGET** of each `vpiActual`, skips `vpiParent` back-reference subtrees, and keys on name + span + owning call. |
| `vscore165.py` | the multiset cell scorer: TOWARD / **AWAY** / SIDEWAYS / STILL-WRONG / OK, with the per-key distance printed for every non-OK identity. |
| `v165_a_carriers.sv` | arm A — every control carrier plus the four-depth distinguisher pair. |
| `v165_b_shadow.sv` | arm B — the shadowed block local, § 57's carve-out, argument shapes and arity. |
| `v165_c_homes.sv` | arm C — out-of-body, `$unit`, module-homed, the four method flavours, the receiver faces, and the module-function control. |
| `v165_d_idxrecv.sv` | arm D — the subscripted receiver across depths, containers, index kinds and carriers. |
| `v165_e_assert.sv` | arm E — the non-raising carriers (assert/assume action blocks, wait, event control, all three fork joins). |
| `GRID.r10v165.txt` | every scored cell of every arm, both views, plus `a1_witness.sv` and the whole `BuildUVMPkg` corpus row. |
| `GATES.r10v165.txt` | the nine gates, end to end, with the transcripts. |
| `BOUNDARY.r10v165.txt` | the 4682-arm boundary movers. |
| `v165head_{pris,pat}_BuildUVMPkg.default.cmp` | the verifier's own head logs, byte-identical to the implementer's. |
