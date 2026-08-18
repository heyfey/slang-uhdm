# r10vrgg16 — ADVERSARIAL VERIFICATION of r10rgg16 (`§ ifacePortViewActualScopeGate16`)

**VERDICT: ACCEPT AS SHIPPED.**  Every headline number reproduced bit-for-bit
from my own worktrees and my own binaries — including both md5s.  A
purpose-built 14-cell attack grid (connection form × port form × actual
spelling × home × arrays × bind × nesting × 1..3 instances), run in **both**
views (`default` and `--elabuhdm`), produces **0 BROKEN cells**, and a
per-file **and** per-directory wide boundary over a copy of the whole
`tools/probe` tree, also in both views, finds **0 asymmetries** and exactly
one non-cell mover, which is verified TO GOLDEN.  **No production edit was
needed**, so `/tmp/r10rgg16.verified.patch` carries the implementer's
`src/ModuleEmit.cpp` change UNCHANGED and adds only this evidence directory.

**MEASUREMENT-ONLY directory.**  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` (md5 `2ad8015175758e918de1789b86ef1ea5`,
identical to `~/.local/bin/uhdm-cmp`) remains the sole acceptance judge.

Worktrees `/tmp/wt_vrgg16pris` (5723484) and `/tmp/wt_vrgg16`
(5723484 + `/tmp/r10rgg16.patch`), scratch `/tmp/vrgg16_*`.
Frozen binaries (`chmod 555`): base `2d41c4ca7ca6140f25d751004fca13cd`,
patched `1a26bbc9c08bd1fa45695b2a3a013305` — **both identical to the
implementer's**, so the build is reproducible and the two reports measure the
same object.

## 1. The head decode, redone from the PRISTINE cmp log by me

I re-derived it from source before reading the implementer's framing:

* `BaseClass.h` **vector** `SafeCompare`: the arm
  `(lhs == nullptr) && (rhs != nullptr) && !rhs->empty()` sets **only**
  `context->m_failedRhs = rhs_obj` — and `rhs_obj` is the **OWNER**, not the
  slot.  The SINGULAR overload's mirror sets `m_failedRhs = rhs`, the VALUE.
  Both print `LHS: <null>`.
* `interface_inst::Compare` never mentions `Param_assigns`; it reaches it
  through `scope::Compare`, which does
  `SafeCompare(lhs, lhs->Param_assigns(), rhs, rhs->Param_assigns(), context)`.
  So a null-vs-non-empty `Param_assigns` names the `interface_inst`.
* My own `uhdm-cmp` run on my own base sweep: **683 lines, 1 head**, and its
  first 342 lines (the stderr half) are **byte-identical** to the
  implementer's `HEAD_R0_BEFORE_default_Rggen.cmp`.  After: **194 lines,
  1 head**, stderr half byte-identical to `HEAD_R0_AFTER_*`.
* **The object is NOT spurious.**  My independent census reports **806 keys on
  golden and 806 on ours**, and the head object
  `work@rggen.u_block_0.g_register_15.u_register.bus_if` is present on BOTH
  sides with `par=4 mp=1 var=8`; only `pa` differs (golden 0, base 4).
  **r10rgg16's correction of r10rgg15's decode is CONFIRMED.**

## 2. The instruments I built (independent of the implementer's)

* `vcensus16.cpp` — a VIEW-GENERAL `interface_inst` census.  Differences that
  matter versus `pvcensus16.cpp`: it also walks **programs, module arrays and
  interface arrays**; it does **not** dedup row text (a `sort -u` hides a
  MULTIPLICITY change, which is the exact shape of a vector-size head — object
  identity is deduped, row text is not); and the payload carries the
  `param_assign` **contents** (lhs name, rhs kind, decompiled rhs, the
  `vpiOverriden` stamp) and the parameter list, plus `tf`/`cb`/`port` counts.
  All of these are fields `scope::Compare` / `instance::Compare` actually read.
  **No span, no file/line, no fullname-only key.**
* `vscore16.py` — a **multiset** three-way join (a last-writer dict drops rows).
  Slots are STILL-RIGHT / FIXED / BROKEN / STILL-WRONG / CHANGED-WRONG.
* `vcorpuscensus16.py` — the same census over every workdir in a whole sweep.
* `vboundary16.sh` — the wide boundary, per-FILE and per-DIRECTORY, in BOTH
  views, list on fd 3, children `</dev/null`, PROCESSED asserted, rc per cell,
  uncompilable counted, asymmetries loud, banner line dropped.
* `vcell16.sh` — one cell: surelog `-parse` + slang `--single-unit` + uhdm-cmp.

**Calibration first.**  A fresh `surelog -parse` of the Rggen line into my own
`GOLDEN_CACHE` produced a database **byte-identical** to the cached golden
(md5 `98176c6e44638c913a47fd319fa3729f` both) and the census of the two is
**806 / 806 identical, 0 differing**.  Negative control: golden vs PRISTINE
ours is **1 differing key of 806** — the instrument is not blind.

## 3. THE ATTACK GRID — 14 cells, both views, 0 BROKEN

`GRID_SCORES.txt` has the table; `cells/v*/dut.sv` the sources.  What each cell
attacks and what it found:

| cell | attack | result |
|---|---|---|
| v1 | connection FORM: named / `.p` shorthand / POSITIONAL, module vs gen scope | **FIXED 2, BROKEN 0 — and v1 is now FULLY golden on `pa`.** Positional already dropped through the `posModportPortView9` arm on both binaries. |
| v2 | **GENERIC** interface port (`interface p`) and PLAIN port | 0 BROKEN, 0 FIXED. Golden **keeps** `pa=2` on a generic port at module scope and emits **no object at all** for one in a gen scope; we do the opposite on both binaries. Pre-existing, untouched → **R-V1**. |
| v3 | interface-ARRAY port (`ifc.mp p[2]`), instance array of children | 0 BROKEN. Pre-existing missing objects only. |
| v4 | interface-in-interface (the `nestedIfaceView` call site) | 0 BROKEN. Pre-existing `port` count and missing nested views. |
| v5 | modport with `import` task/function + a **clocking block** | **FIXED 1, BROKEN 0.** The richer interface_inst (tf/cb vectors) does not confuse the gate. |
| v6 | homes: **gen-case**, two-deep gen-for, per-iteration actual | **FIXED 5, BROKEN 0** — the largest single-cell gain. |
| v7 | **program** with an interface port, two-deep gen-if | **FIXED 1, BROKEN 0.** |
| v8 | multiplicity: 1..3 children; a child with TWO interface ports, one actual IN scope and one OUT, **in both orders** | **FIXED 3, BROKEN 0.** This is the cell that tests the gate's `break` — it keys on the CONNECTION, not on port position, and both orders score right. |
| v9 | MULTI-parameterized def × plain/modport × module/gen | **FIXED 2, BROKEN 0**, STILL-WRONG 3 = exactly the implementer's declared **R-N1**. |
| v10 | **parenthesized** actual `(inst)`, passthrough at two levels | **FIXED 2, BROKEN 0**, STILL-WRONG 1 → **R-V2** below. |
| v11 | the **`.*` wildcard** connection (invisible to `findConnSyntax`) | 0 BROKEN, 0 FIXED, and **fully golden**: the earlier positional drop-all arm already handles `.*`, so the gate's declining costs nothing. |
| v12 | instance arrays as the HOME (module scope and gen-for) | 0 BROKEN. Exposes **R-V3**: we emit NO elaborated port views at all for an instance array inside a gen-for. |
| v13 | a **parameterized** interface nested in another interface, fed from a gen scope | 0 BROKEN; the one CHANGED-WRONG is `pa 1 → 0 = golden` with a pre-existing `port` residue. |
| v14 | **bind** of an interface-port-bearing module into a gen scope, hierarchical actual `top.inst` | **FIXED 2, BROKEN 0.** |

Totals over 28 cell-views: **BROKEN 0**, FIXED 33, CHANGED-WRONG 5 (every one
of them `pa` moving TO GOLDEN with an unrelated pre-existing field still off),
STILL-WRONG 68, STILL-RIGHT 172.

I also re-ran the implementer's own `cells/g1..g5` on MY binaries with MY
comparator: DEF views aggregate to **FIXED 10, BROKEN 0, STILL-WRONG 1,
STILL-RIGHT 31** — *exactly* the implementer's `GRID_SCORES.txt`.

## 4. What I could NOT break

* No `pristine-right → patched-wrong` cell exists in 28 cell-views.
* The gate only ever removes; every arm below it is reached unchanged on a hit.
* `.*`, positional and unparsable actuals all DECLINE, and in every measured
  shape an EARLIER arm already produced golden's answer there.
* The `InstanceArray` walk-past is currently **unreachable as a behaviour
  change**: at module scope it gives the same answer with or without the walk,
  and inside a gen scope we emit no such port views at all (R-V3).  It is
  harmless, but it is untested by construction — noted, not scored.

## 5. Residues I measured (ranked), beyond the implementer's R0/R-A..R-N2

* **R-V1 — the GENERIC interface port (`interface p`) family.**  `cells/v2`:
  golden gives a module-scope generic port view `par=2 pa=2` (the home view's
  numbers) where we give `par=4 pa=0` (the plain-port shape), and golden emits
  **no interface_inst at all** for a generic port inside a gen scope where we
  emit one.  Both binaries identical; zero corpus reach measured.
* **R-V2 — Surelog's actual-name extraction does NOT unwrap parentheses.**
  `cells/v10`: `leaf l1 (.p((inst)))` at MODULE scope has golden `pa=0`, while
  `.p(inst.mp)` right next to it has `pa=2`.  The patch's
  `ParenthesizedExpression` unwrap therefore models Surelog too *generously*:
  the gate declines where golden drops.  **Direction-safe** (it can only leave
  a pre-existing `pa` in place, never remove one golden keeps), zero corpus
  reach, and it is a one-line narrowing if a later pass wants it.
* **R-V3 — an instance ARRAY inside a generate block emits nothing.**
  `cells/v12`: golden has `work@top.gf[0].a3[0]`, `…a3[0].p`, … ; our dump has
  only `work@top.gf[0].finst` and `work@top.gf[0].i`.  8 golden-only keys in
  one 20-line cell.  Pre-existing, unrelated to this pass, and far larger than
  anything the gate touches.
* **R-V4 — MiniAmiq's `work@svaunit_vpi_interface` parameter VALUES.**  My
  corpus census (payload richer than the implementer's) reports 2 more
  differing databases than theirs: `default+testflags/MiniAmiq`, where
  `pa=90` on both sides but `vpiValue` is EMPTY on ~30 of our parameters and
  `uvm_revision` reads `UVM-1.2` against golden's `UVM.1.2`.  **This does not
  contradict the implementer's claim** — their statement was about `pa`, and
  no `pa` mismatch remains anywhere in either corpus after the patch.

## 6. Reproduce

```
g++ -std=c++20 -O1 vcensus16.cpp -o /tmp/vrgg16_vcensus \
    -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
    $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
bash vcell16.sh $PWD/cells/v6 /tmp/vrgg16_bin/base    .base
bash vcell16.sh $PWD/cells/v6 /tmp/vrgg16_bin/patched .pat  --elabuhdm
python3 vscore16.py cells/v6/cen_gold.txt cells/v6/cen_base.txt cells/v6/cen_pat.txt --rows
bash vboundary16.sh <probe-copy> <out> file elab
python3 vcorpuscensus16.py <sweep-workdir> <label> <out.txt>
```
