# r10buvm6 — § dollarBoundIsConst6: the `$` queue bound IS AN OBJECT

**Target.** The BuildUVMPkg head at base `94ad375`: 19 cmp lines, BOTH modes,
LHS-has / RHS-null.  At `uvm_pkg.sv:12983`
(`m_override_info.push_back(matched_overrides[$])`) golden gives the
`bit_select` a `vpiIndex` — a `constant` spanning the `$` character alone,
`vpiDecompile:$  vpiSize:1  STRING:$  vpiConstType:10` (`vpiUnboundedConst`).
We emitted **no index object at all**: slang models `$` as an
`UnboundedLiteral`, nothing in `emitExpr`'s dispatch claimed that kind, the
function returned `nullptr`, and every caller reads `nullptr` as "no object".

**The law (one arm of `emitExpr`, `src/ExprEmit.cpp`).**  Surelog has no queue
arm: it compiles `$` as an ORDINARY EXPRESSION and mints the constant above.
So do we now, plus `ExpressionKind::UnboundedLiteral` in `isLiteralExpr`
(`src/EmitHelpers.h`) because `$` *is* one of slang's literal expressions and
the var_select builder's `forceConstParent = isLiteralExpr(idx)` must treat it
the way golden does.  There is **no gate**: position is irrelevant and
parenting is not `$`-specific (below).

## What was measured, and what each measurement refuted

| arm | question | answer |
|---|---|---|
| `v1_dollarpos.sv` | does golden mint the constant in every position? | YES in all 21 `$` arrivals: method-call argument (the corpus shape), `return`, assignment RHS **and LHS** (`q[$] = 7`), `if` condition, `case`, arithmetic operand, `$display` argument, both reads of `q[$] + q[$]`, class method and module `initial` alike; and in every carrier: plain `bit_select` index, hier_path element `bit_select` (`t[$].f`), `var_select` index list (`qq[1][$]`), `part_select` right bound (`q[1:$]`, `q[0:$]`, `{q[0:0], q[1:$]}`) and an OPERAND of an index operation (`q[$-1]`). |
| `v3_parentpolicy.sv` | is the PARENTING `$`-specific? | NO.  In all seven positions where an integer twin exists golden gives the `$` constant EXACTLY the integer's parent — parented under a plain `bit_select` (rvalue and lvalue), a `var_select` and an index `operation`; UNPARENTED under a `part_select` bound and under a hier_path element's `bit_select` — and the PRISTINE binary already reproduced all seven for the integer.  So the arm reuses the emitter's existing constant-parenting predicate instead of inventing one. |
| `v2_dollarexotic.sv` | how far does the blast radius reach? | NOT to the SVA ranges.  `##[1:$]`, `a[*1:$]`, `b[->1:$]` are resolved inside slang's SequenceRange before any expression survives: the census instrument records **zero** `UnboundedLiteral` arrivals for all three, and the arm's only arrival is `qb6[$]` at line 59 — an ordinary select.  The bounded-queue TYPE bound (`int q[$:2]`) never reaches an expression emitter either. |

`dollartab.py <armdir> <arm.sv>` prints, per source (line,col), golden's and our
parent kind for every constant.  The `$` cells, pristine → patched:

| arm | `$` cells | ours ABSENT before | ours ABSENT after |
|---|---:|---:|---:|
| v1_dollarpos | 25 | 22 | **1** |
| v2_dollarexotic | 6 | 6 | **5** |
| v3_parentpolicy | 9 | (n/a — arm added after) | **0** |

and the whole-table DIFFERING count on v1 falls 24 → 3.  Every surviving cell is
a DECLARATION-range family this pass does not claim and did not touch:
`int qq6[2][$]`'s fixed outer dimension, and the bounded-queue type ranges
(`int qb6[$:2]`, `string sb6[$:7]`) where golden has a range and we have none.

## Corpus census — the prediction, written BEFORE the byte gate

`censusrun.sh` replays every corpus test's own SLANG argv against an instrumented
binary (3027 test-modes, both corpora).  `UnboundedLiteral` reaches `emitExpr` in
**ten** test-modes only: BuildUVMPkg (6 hits: `uvm_pkg.sv` 12983:53, 13095:53,
20128:59, × the def and elab views) and SeqDriver / SimpleUVM / Scoreboard
(1 hit each, `uvm-1.2 base/uvm_misc.svh:284:79`) in the modes that build, plus
MiniAmiq (rejected + segfaulting db writer) and testflags/Scoreboard (rejected).
Predicted movers: **7 surelog databases, 0 uhdm2rtlil databases**.  Measured:
exactly that — `/tmp/r10buvm6_prediction.txt` was written first.

Note what the census also says: **no CMP_EQUAL row anywhere contains a `$`
select**, so no passing row's database can be perturbed by this law.

## Files

| file | what it is |
|---|---|
| `v1_dollarpos.sv`, `v2_dollarexotic.sv`, `v3_parentpolicy.sv` | the three arms |
| `ct6arm.sh` | arm driver (LHS golden, RHS ours) |
| `dollartab.py` | the constant-parenting table — the arms' verdict |
| `censusrun.sh`, `maketsv.py` | corpus-wide census driver (argv replay, no Surelog) |
| `stripdollar.py` | removes whole `$` CONSTANT BLOCKS from a dump |
| `attrib6.sh` | per-mover attribution: DIFFLINES / DOLLAR / RESIDUE, RESIDUE must be 0 |
| `bound6.sh` | boundary check over the 63 protected neighbour arms |
| `detsweep6.sh` | pristine-vs-pristine sweep of the two residue rows |
| `seqpair6.sh` | sequential two-binary pair + order-blind multiset compare |
| `byteverify.sh`, `sweeps.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh`, `detcheck.sh`, `msdist.sh`, `pop.py` | carried-forward gate instruments |

## The two RESIDUE movers, named

`attrib6.sh` clears five of the seven movers outright (RESIDUE 0: the entire
change is `$` constants).  Two carry more: `default/Scoreboard` and
`testflags/SeqDriver`.  Both were run down:

* **It is a pure PERMUTATION.**  After `stripdollar.py`, the two dumps are
  identical as **line multisets** (`sort | cmp`) on both rows — zero content
  lines added, removed or altered; only the position of two entries (a package
  `int_typespec UVM_FILE` / `logic_typespec uvm_integral_t` pair; on Scoreboard a
  block of `vpiTaskFunc` entries).
* **`default/Scoreboard` reproduces it PRISTINE-vs-PRISTINE** (`detsweep6.sh`:
  the same binary swept twice into two workdirs produces two different
  databases).  For that row the emitter's own run-to-run order is the cause.
* **`testflags/SeqDriver` is deterministic per binary** (`detcheck.sh`: pristine
  4/4 identical, patched 3/3 identical, and each matches its sweep database
  byte-for-byte), so there the permutation is a deterministic downstream
  consequence of minting one extra object: `seqpair6.sh` reproduces it with the
  two binaries run back-to-back, one `$` constant (8 dump lines at
  `uvm_misc.svh:284:79`) plus three permutation hunks 455k lines later.
* **It is invisible to the judge.**  `uhdm-cmp`'s cmp.log is BYTE-IDENTICAL
  pristine vs patched for SeqDriver (both modes), SimpleUVM (both modes) and
  Scoreboard (default) — the five-row wall's 1450011 / 1405511 / 1399779 cmp
  lines hold exactly — and every row of both corpora is byte-identical to the
  committed baselines.  Only BuildUVMPkg's cmp moved, which is the point of the
  pass.

---

## VERIFIER ADDENDUM (r10buvm6 adversarial verification) — § dollarBoundNotFolded6v

The verifier reproduced every headline number of this pass from its own two
worktrees (`/tmp/wt_vbuvm6{,pris}`, both at `94ad375`, both binaries built here:
pristine md5 `022b318d600b46d369250a96c87ae6fe`, patched
`80ce96ccfa0f4379078ffa65171ebdcc` — identical to the implementer's), and then
found ONE **pristine-right → patched-wrong** regression on legal SV and fixed it.

### The regression, and the arm that names it — `v4_seltrackdollar.sv`

`§ dollarBoundIsConst6` turns a `$` part-select bound into an OBJECT.
`endSelTrack` (`src/StmtEmit.cpp`) carries a carve-out that keeps a
whole-written variable's ref bound to its NET when the first select of that
variable is a part_select **whose left bound is a folded constant**
(`multiple_blocking_gate`).  A `$` left bound used to be `nullptr`, so the
carve-out did not fire; after the pass it is a `constant` and the carve-out
fires, leaving the whole-write ref on the `logic_net` where golden — and the
PRISTINE binary — put the `part_select`.

`v4_seltrackdollar.sv` is a 7-cell grid of "written whole AND written through a
select" (read with `selbind.py`, which prints each ref's `vpiActual` kind):

| cell | first select | GOLDEN | pristine | patched (as shipped) | patched + fix |
|---|---|---|---|---|---|
| s1 `a1` | `a1[$:0]` | `part_select` | **`part_select`** | **`logic_net`** ← regression | **`part_select`** |
| s2 `a2` | `a2[0:$]` | `part_select` | `logic_net` | `logic_net` | `logic_net` |
| s3 `a3` | `a3[$]` (bit) | `bit_select` | `bit_select` | `bit_select` | `bit_select` |
| s4 `a4` | `a4[1:0]` | `part_select` | `logic_net` | `logic_net` | `logic_net` |
| s5 `a5` | `a5[$-1:0]` | `part_select` | `part_select` | `part_select` | `part_select` |
| s6 `v1` | `v1[3:0]` packed | `part_select` | `logic_net` | `logic_net` | `logic_net` |
| s7 `a6` | nested block | `logic_net` | `logic_net` | `logic_net` | `logic_net` |

On the shipped patch this defect is the **cmp head** of the arm (uhdm-cmp:
golden `part_select` vs ours `logic_net`); with the fix the arm's only remaining
disagreements are s2/s4/s6 — the ORDINARY folded-bound carve-out family that the
pristine binary gets wrong too and that `multiple_blocking_gate` pins.  The fix
is therefore exactly one clause: **an unbounded (`$`) left bound is not a folded
bound.**

### `v5_hierpathparent.sv` — the hier_path parenting the v3 arm missed (residue, NOT fixed)

`v3_parentpolicy.sv` tested 7 positions.  Two more disagree with golden — in
opposite directions — and both are "absent → present with the wrong parent"
(never pristine-right→patched-wrong), and uhdm-cmp passes the arm either way:

| cell | shape | GOLDEN parent | ours (patched) |
|---|---|---|---|
| c3 | `ih.t[$].f` — handle-qualified, NON-terminal select | UNPARENTED | `bit_select` |
| c5 | `t[$-1].f` — bare, NON-terminal, index OPERATION | `operation` | UNPARENTED |

Terminal selects (`ih.q[$]`, `mh.lh.q[$]`) and bare non-terminal ones
(`t[$].f`, `t[$].s.f`, `h[$].v`) all match golden.

### What the verifier ALSO measured

* 39 + 26 + 3 purpose-built `$` cells (every select spelling `[$] [$-1] [$-3]
  [0:$] [$:0] [1:$] [$:1] [idx+:$] [$-:2] [$+1] [$*2] [($)] [$][$] [$-1:$]
  [$:$]`, queue/dynamic/assoc/fixed receivers, lvalue and rvalue, hier_paths,
  XMR `u1.q[$]`, foreach, with-clause, `q[q[$]]`, ternary index, casts,
  assertions, tasks/forks, class params, unbounded parameters, SVA `##[1:$]`
  `[*1:$]` `[->1:$]` `[=1:$]`, constraints `inside {[1:$]}`, covergroup bins):
  **0 regressions**, ~60 cells converted to golden, and after `stripdollar.py`
  the pristine-vs-patched dumps are **byte-identical on every cell** except the
  one `v4` cell above.
* slang REJECTS `d[$]` / `a[string][$]` / `fx[4][$]` / `sub #($)` /
  `q[$] <= x` ("unbounded literal '$' not allowed here" / nonblocking to a
  dynamic element) — those spellings cannot reach the arm at all.
* SVA unbounded ranges: **zero** arrivals confirmed (golden mints 4 `$`
  constants under `range`/`vpiRightRange`, we mint none, before and after).
* The boundary check was widened from 63 arms to **all 413 `.sv` arms** of
  `r10buvm3/4/5`, `r10sd8..12`, `r10uvm77..81` (grids included): `MOVED=0
  RESIDUE=0 NO_DB=4` (the 4 are rejected by BOTH binaries), with three of the
  verifier's own arms as the positive control.
* The two "RESIDUE movers" (`default/Scoreboard`, `testflags/SeqDriver`) of the
  implementer's report **did not reproduce**: in the verifier's sweeps all 7
  movers are `DIFFLINES 48/8, DOLLAR 24/4, RESIDUE 0` — pure additions, no
  removed line, no permutation.  The permutation is run-to-run nondeterminism,
  not a deterministic consequence of minting the object.
* `parameter int P = $` (unbounded parameter): the pass mints the constant and
  the head advances, but golden's ELAB view of that constant is `vpiSize:32
  vpiConstType:6` with a `vpiTypespec`, where we emit `vpiSize:1
  vpiConstType:10` and no typespec — a separate, untouched family.

### The fix's own gates (all re-run with the fixed binary, md5 `735095cf3faba835ad2c2a7a6a98fa91`)

goldens 23/0 (and 0/23 with `/bin/false`); uhdm2rtlil 679/50/2 per mode with
`ct8rows` **0 differing rows / 1462** vs pristine; surelog 469/11/284/25/5 and
465/8/286/23/5 with `ct8rows` **0 differing rows / 1588** vs the committed
`golden_surelog.csv`; byteverify **7 movers / 953** (the predicted set, same
md5s) with `SELFCHECK 952/953` and `SELFCHECK1 8`, attribution RESIDUE 0 on all
7; **fixed-vs-shipped byteverify: 0 movers over 953 + 1358 databases**, so the
fix is byte-invisible to both corpora; five-row wall 1450011 / 1405511 /
1399779 cmp-log byte-identical; canaries 66 + 60 rows, 0 changed; SVSwitch pinned
`4842211c4030`; ladder (official `design::Compare`, calibration 0 rungs on
183142 objects) **259 → 253** rungs, the rung-list diff exactly the six `$`
constants removed, **zero added**.
