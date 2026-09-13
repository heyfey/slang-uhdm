# r11v17 — the adversarial verification of r11u17, and the cast-operand fence it needed

Base commit `76c8a58b`. Two fresh worktrees of my own (`/tmp/wt_v11u17pris`,
`/tmp/wt_v11u17`), both binaries built `-j 2` from source and frozen at
immutable paths before any sweep. Everything here is measurement-only; the
judge is the official `uhdm-cmp` through `scripts/verify_golden.py`.
`results/*.csv` ARE NOT EDITED BY THIS PASS.

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's
report reproduces bit-for-bit, including both binary md5s. One
**pristine-right → patched-wrong** cell survived their gates, on a LANDED
pass's own verifier arm; I isolated it to five minimal arms, fixed it in
`src/ExprEmit.cpp` (§ `sysCallCastArgKeepsBind17v`), and re-ran the whole
battery. The fix is corpus-invisible (0 movers against the law binary over
1608 u2r databases) — the WIDE boundary alone convicts it.

## 1. Reproduced bit-for-bit

| gate | claimed | my measurement |
|---|---|---|
| pristine md5 | `5bbb42c0fbc7e2c76e95e6f70464d0ae` | **identical** (my own build at `76c8a58b`) |
| law md5 | `34374b757fe4a886cfd472ab3a0d403b` | **identical** (fresh `76c8a58b` + `/tmp/r11u17.patch`) |
| `git apply --check` on FRESH `76c8a58b` | rc 0 | rc 0 |
| u2r pristine | 759 / 45 / 67 both modes | 759 / 45 / 67 both modes |
| u2r law | 761 / 43 / 67 both modes | 761 / 43 / 67 both modes |
| converted rows | `ibex_multdiv_fast`, `genscope_module_ctx_reset` | **the same two, and only those two**, in both modes |
| u2r byteverify | 6 movers of 1608 | 6 movers of 1608, same md5s, self-check 1607/1608 |
| `cmds.txt` audit | 1742 + 1742 | 1742 + 1742, one binary path each, no main-tree leak |
| goldens | 23/0, `/bin/false` 0/23 | 23/0 on BOTH binaries, `/bin/false` 0/23 |
| the 41-arm grid | every arm `golden_rc=0 ours_rc=0` | 41 of 41, verified |

### THE HEADS, re-measured on my own pristine build against the golden the sweep itself used

    ibex_alu                  LHS: <null> / array_net work@ibex_alu.imd_val_d_o @ 24:29      51 cmp lines
    ibex_multdiv_fast         LHS: <null> / logic_var work@ibex_multdiv_fast.sign_a @ 54:16  15 cmp lines
    genscope_module_ctx_reset LHS: <null> / logic_net  work@…ctx_reset.in_i @ 24:30          15 cmp lines

Under the law `ibex_multdiv_fast` and `genscope_module_ctx_reset` read
`uhdm-cmp` **rc 0**, and `ibex_alu`'s head MOVES to `constant 2'd0` at
`1312:34`, 29 cmp lines — the R0 assignment-pattern fold, exactly as reported.

### Two of the implementer's corrections, independently confirmed

* **The brief's R2 framing was stale.** `mult3_sign_a = sign_a;` at `:192` and
  `:222` is inside `gen_mult_single_cycle` (`ibex_multdiv_fast.sv:140`), the
  arm the elaboration discards. Every moved cell is at `:278` and `:380`,
  inside `gen_mult_fast` (`:264`) — `assign mac_res_signed = $signed({sign_a,
  mult_op_a}) * … ;` It is a CONTINUOUS ASSIGNMENT, not a process.
* **The brief's "second family" is a definition-view artefact.** In the
  elaborated listing golden's `ibex_alu.sv:269` Rhs is a `constant` at
  `269:74` and `:275`'s a `constant` at `275:79` — golden folds the
  `RV32B != RV32BNone` ternaries exactly as we do. The symbolic `operation`
  the brief cites lives in the tail the judge does not walk.

### The producer decode, read at the pin

Both laws follow from source I read myself at Surelog `0445655ee7` (v1.87):

* `CompileHelper::bindVariable` (`src/DesignCompile/CompileStmt.cpp:3095`) —
  its `uhdmmodule_inst` case searches `Variables()` then `Nets()` and nothing
  else. `Array_nets()` is never reached. LAW 1 confirmed.
* `UhdmWriter::writeCont_assign` (`src/DesignCompile/UhdmWriter.cpp:2118`) —
  `if (var) { if (rhs is uhdmoperation) { if (cloned == false) { clone_tree;
  reduceExpr; assign->Rhs(rhstmp) } ref->Actual_group(var); } }`. LAW 2
  confirmed.

## 2. THE DEFECT — § genCaSysCallArgBinds22 was narrowed too far

The patch adds `!caBoundLhsOpRhs17` to the landed
§ `genCaSysCallArgBinds22` re-bind in `ExprEmit.cpp`. That narrowing is
right for a CONCAT or an OPERATION argument and **wrong for a CAST operand**.

Measured, every arm `golden_rc=0 ours_rc=0`, verdicts off `refcen.py` over the
judge-reachable elaborated section — a BOUND module Lhs and an OPERATION Rhs
in a generate scope in every row:

| arm | the `$signed` argument | golden | pristine | r11u17 | + this fix |
|---|---|---|---|---|---|
| `w02` | `W'(m_var)`, child instance | **BINDS** | right | **WRONG** | right |
| `w05` | `W'(m_var)`, TOP module | **BINDS** | right | **WRONG** | right |
| `w06` | `idf(W'(m)) ^ W'($signed(m)) ^ $signed(W'(m))` | **BINDS** the third | right | **WRONG** | right |
| `w08` | `W'(m_var) + 8'd2` (cast one level down) | **BINDS** | right | **WRONG** | right |
| `w09` | `{1'b0, W'(m_var)}` (cast one level down) | **BINDS** | right | **WRONG** | right |
| `w03` | `{sg, m_var}` — no cast | bare | wrong | right | right |
| `w07` | `m_var + 8'd2` — no cast | bare | wrong | right | right |
| `w04` | `m_var` — a bare argument | bare | right | right | right |

So `reduceExpr`'s rebuild drops the actuals it walks through but NOT a cast's
operand. The key is the reference's IMMEDIATE parent, not the argument's own
kind: `w08` and `w09` nest the cast one level inside the argument and golden
still binds. **The same fact is already a landed law thirty lines below in the
same file**, for the gen-scope PROCESS window: *"a ref that is the OPERAND of
a size-cast op (op 67) binds even for module-level signals (Surelog
re-elaborates the cast)"* (`ExprEmit.cpp`, the `vpiCastOp` arm). The
cont-assign window simply never carried it.

**THE CELL THAT CONVICTS IT IN THE TREE**:
`tools/probe/r10v94repro/v2_kind94.sv:40`

    assign o8 = idf(W'(m_var)) ^ W'($signed(m_var)) ^ $signed(W'(m_var));

golden binds only the `m_var` at `40:66` (the one under `$signed(cast)`) and
leaves `40:24` and `40:45` bare. Pristine matched golden there; r11u17 broke
it — **2 → 3 differing ref keys of 50**. That file is the committed verifier
arm of a LANDED pass (r10v94).

**THE FIX** (`src/ExprEmit.cpp`, § `sysCallCastArgKeepsBind17v`) adds one
disjunct, `(!caBoundLhsOpRhs17 || castArg17v)`, where `castArg17v` is "the
ref's UHDM parent is an `operation` whose `VpiOpType()` is `vpiCastOp`". It
can only RE-ENABLE a bind the base binary already made, so it cannot reach a
cell outside the new law's own population. With it, `v2_kind94.sv` reads
**delta 0 against pristine** and its census is back at 2 of 50.

## 3. THE ADVERSARIAL GRID — 31 arms, every arm `golden_rc=0 ours_rc=0`

`grid/` carries one `dut.sv` per arm; `run.sh <binary> <tag>` records BOTH
rcs, the head count and the cmp line count; `armcen.sh <tag>` prints the
`refcen.py` verdict over the judge-reachable elaborated section. Every verdict
below is read off the census, never off the cmp rc. `GRIDV.r11v17.txt` is the
three-column table (pristine / r11u17 / r11u17+fix).

Axes swept beyond the implementer's 41: a PARAMETER-named and a LITERAL delay;
`inside`; a USER FUNCTION CALL inside the operation Rhs; a HIERARCHICAL
reference; a STRUCT MEMBER select; a module PARAMETER operand; an INTERFACE
gen scope (both laws); a nested for-in-if; an `always_comb` driver; a
module-scope (non-generate) array-net Lhs; a gen-if ELSE arm; a CHILD-instance
gen scope; an explicit `wire` unpacked array; an unpacked array of a packed
STRUCT; a CONCATENATION Lhs; two cont-assigns in one block in both orders; and
the eight `$system`-call argument shapes above.

**14 arms convert; 0 arms regress under the fixed binary.** Under r11u17
alone, 5 arms regress — the five in §2.

### The arms that PROVE the landed laws and the converted rows stay

* `va15` — a GEN-LOCAL Lhs with `$signed({sa,oa}) * …`: § genCaSysCallArgBinds22's
  own population, byte-unchanged on all three binaries.
* `va16` / `va17` — a bound-Lhs assign and a gen-local-Lhs assign in ONE block,
  in both orders: the gen-local one keeps its binding, so `caBoundLhsOpRhs17`
  does not leak across assignments.
* `va10` — an `always_comb` driver writing the module-level name: untouched
  (LAW 2 is a cont_assign law).
* `va11` / `va12` — the MODULE-scope and the INTERFACE array-net Lhs: untouched
  (LAW 1's `DefinitionKind::Module` + gen-scope fences hold).

## 4. THE WIDE BOUNDARY — 771 files, `PROCESSED == LISTED`

`bnd17v.sh` is my own runner (fd-3 file list, children `</dev/null`,
workdir/id/filename normalisation, ORDER-BLIND sorted comparison). The list is
every `.sv` under `tools/probe` that contains an `assign` AND a generate block
(726 files) — a net fifteen times wider than the implementer's 48 — plus all
44 `r11u15repro/grid` arms, `q{d,e,f}22.sv`, `v2_seltrack.sv` and my own 31.

**POSITIVE CONTROL**: run over a known mover and a known non-mover it reads
`MOVED=1`, `norm_delta=2` on the first and silent on the second.

**Under r11u17: 24 movers, and ONE of them moves AWAY from golden** —
`r10v94repro/v2_kind94.sv` (§2). The other 9 landed-pass movers all move
TOWARD golden, scored by building the REAL v1.87 golden for each file and
running the census against it (`bndattr17v.sh`):

    r10earl49repro/v4_v49.sv      1 -> 0 of 12      r10earl_repro/pq20.sv    5 -> 0 of 25
    r10earl50repro/h3_earl50.sv   3 -> 2 of 22      r10earl_repro/ps20.sv    1 -> 0 of 11
    r10earl50repro/v4_v49.sv      1 -> 0 of 12      r10earl_repro/qb25.sv    2 -> 0 of 64
    r10earl59repro/a1_earl59.sv   5 -> 0 of 58      r10earl_repro/qd22.sv    1 -> 0 of 23
    r10earl94repro/g4_pool94.sv   9 -> 8 of 122

**Under r11u17 + the fix: 23 movers, AWAY-GOLDEN 0 / MOVED-WRONG 0.**
`v2_kind94.sv` leaves the list entirely (delta 0 against pristine). Nothing is
ADDED in any database in either direction; every moved line is a removed
`vpiActual`. The 4 `NODB` files fail with rc 3 on BOTH binaries (error
recovery, not golden).

**All 44 of `r11u15repro/grid`'s arms compiled on both binaries and are
byte-identical** — the two landed binding laws' witnesses are untouched, as
are `qe22.sv`, `qf22.sv` and `v2_seltrack.sv` (delta 0 each). R5 confirmed.

## 5. RESIDUES I MEASURED THAT ARE NOT IN THE IMPLEMENTER'S LIST

All wrong at PRISTINE and unchanged by the patch — residues, not regressions.

* **`va06` — the INTERFACE generate-scope cont-assign.** `bindVariable` has no
  `uhdminterface_inst` case, so it recurses past the interface into the parent
  module and finds nothing; golden leaves the Rhs reference bare and we bind
  it. 1 differing key of 9 on all three binaries. The brief named this face;
  the patch correctly does not claim it.
* **`va18` — a CONCATENATION Lhs.** `lhs->UhdmType() == uhdmref_obj` is false,
  so the writer neither clones nor binds, and golden leaves the module-level
  `mx`/`my` bare where we bind both. 2 of 8.
* **`va16`/`va17` — the per-reference vs per-assignment face, restated.** With
  a GEN-LOCAL Lhs, golden binds a gen-local Rhs reference and leaves a
  MODULE-level one bare in the SAME assignment; our opener is per-assignment.
  This is r11u15's own `b15`/`b16` residue, reproduced on new arms.
* **`va11` — the module-scope (non-generate) array-net Lhs.** 3 of 5 on all
  three binaries: the R2 face, correctly left to a later pass.

## 6. Instruments

* `refcen.py` / `refall.py` / `armcen.sh` / `run.sh` — copied byte-for-byte
  from `r11u17repro` (themselves r11u15's), so the two passes are scored by
  the same instrument.
* `bnd17v.sh` — my own wide boundary runner (§4), fd-3 list,
  `PROCESSED == LISTED`, order-blind, with a positive control.
* `bndattr17v.sh` — builds the REAL v1.87 golden for one moved file and prints
  the census verdict for pristine and for the patched binary, so every
  boundary mover's DIRECTION is measured, not argued.
* `GRIDV.r11v17.txt` — the three-column arm table.
* The r10uvm221 battery was verified byte-identical to the canonical copies
  before use (`byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`,
  `canaudit.sh`, `rowheads.sh` — all six md5-identical).

## 7. GATES — all green on the FIXED binary

Two binaries of my own, built `-j 2`, md5s taken separately, frozen `chmod 555`
before any sweep: pristine `5bbb42c0fbc7e2c76e95e6f70464d0ae` (= the
OPS-stated main-tree md5 at `76c8a58b`), r11u17 as delivered
`34374b757fe4a886cfd472ab3a0d403b`, r11u17 + this fix
`1b5e1fc6be427cfab6ee6e443fbe4b1f`. `/tmp/r11u17.verified.patch` applied to a
THIRD fresh `76c8a58b` worktree and rebuilt reproduces that last md5 exactly.

1. `tests/check_goldens.sh` — 23 PASS / 0 FAIL on ALL THREE binaries;
   `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL.
2. **u2r, both modes**: pristine 759 / 45 / 67, fixed **761 / 43 / 67**.
   `ct8rows` names exactly `genscope_module_ctx_reset` and
   `ibex_multdiv_fast` in each mode and nothing else; my own pristine sweep
   reads `PASS: every row byte-identical to the committed baseline` in both.
3. **surelog, both modes**: 468 / 15 default and 464 / 13 testflags on BOTH
   binaries, **zero status differences row for row**. `ct8rows` names only the
   two `SURELOG_FAIL` WORKDIR-PATH artefacts (`LowMemLib`, `LowMemPkg`,
   testflags) that my PRISTINE sweep produces against the same baseline.
4. `cmds.txt` audited BY BINARY PATH: u2r 1742 + 1742, surelog 1531 + 1531 —
   one and only one of `/tmp/v11u17_bin/{pris,fix}.bin` per workdir, no
   main-tree binary anywhere.
5. **byteverify `SELFCHECK=1` against my own pristine workdirs.**
   u2r: **6 movers of 1608** (self-check 1607/1608), the three predicted rows
   × 2 modes, order-blind delta 2 / 2 / 14 lines, every line a REMOVED
   `vpiActual`, **nothing ADDED in any database, AWAY-GOLDEN 0**. Against the
   r11u17 binary the fix reads **0 movers of 1608** — it is corpus-invisible.
   surelog: **3 movers of 960**, all the proven UVM coin: `MiniAmiq` both
   modes and `Scoreboard`/default. Two convictions, neither a count:
   `pred17.py` flags ZERO cells in each of those pristine databases, and the
   order-blind deltas are `Scoreboard` **0 lines** (a pure ORDER flip) and
   `MiniAmiq` 4 lines that are one constant's `UINT`/`vpiDecompile` — drawing
   542 → 0 in default and 0 → 1327 in testflags, **opposite directions in the
   two modes**, which no law can do and a per-run draw must. Pinned by NAME
   and CLASS; the count is not pinned.
6. `canaries.sh` ok=52 changed=0 (surelog) and ok=8 changed=0 (u2r);
   `ctcan2.sh` PASS on both corpora; `canaudit.sh` audited=29 UNCOVERED=0
   FENCE-BREACH=0; `rowheads.sh` byte-identical on both binaries
   (measured=12, SKIP-NOFILE=2, UNKNOWN-NAME=0).
7. Protected databases byte-SAME in BOTH modes: **`SVSwitch 4842211c4030`**,
   **`YosysVerx 6ccda350c24a`**, `InterfaceModPort 59a365f3ce2c`,
   `BlackParrotComplex e3e354129d5a` / `73a10e8217e5`, `YosysOldOr
   d68e0796d62c`.
8. The two corpus censuses, judge-reachable elaborated section:
   `ibex_alu` 1 → **0** differing ref keys of 203; `ibex_multdiv_fast`
   18 → **11** of 148, and the row is CMP_EQUAL with all eleven still there —
   they are the `enum_const` LINE INFO no generated `Compare` reads (R4).

## 8. Notes for the integrator

* The implementer's `gates.sh` reads the DEFAULT-mode u2r baseline from the
  hard-coded MAIN-TREE path `/home/heyfey/git-repos/slang-uhdm/results/
  golden_uhdm2rtlil.csv` instead of `$R/results/…`. The main tree has since
  moved to `3343dab6`, whose baseline already reads 761/43, so a re-run of
  that script today would silently compare against the wrong base. I used my
  own comparand cut from the repro worktree at `76c8a58b`. The rest of the
  driver set is `${VAR:-default}`-clean and touches no shared scratch.
* The scoreboard edit is deliberately outside the briefed surface. The
  implementer's arithmetic is right: on top of `3343dab6` (which already moved
  u2r to 761/43), these two DISJOINT conversions take both u2r modes to
  **763 CMP_EQUAL / 41 CMP_NOTEQUAL of 804 runnable (94.9%)**; the surelog
  lines do not move.
