# r10v78 — adversarial verification of r10earl78 (§ genCaReplWholeFold78)

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10earl78.patch` is unchanged and no
`.verified.patch` exists — nothing needed fixing. This directory is
**MEASUREMENT ONLY**; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
sole judge. BASE `b8bf669`. `results/*.csv` was READ ONLY and is untouched;
**no row was converted**.

Every headline number of the pass reproduced bit-for-bit in fresh worktrees
with binaries this verifier built and froze itself — see `GATES_V78.txt`,
including both build md5s (`33c79971…` pristine, `ed52e2ea…` patched),
`679/50/2` u2r in all four sweeps, **0 differing rows on both corpora**
(status AND dump column, against the committed baselines AND my own pristine),
byte movers `0/1358` and `2/956`, and the head going **90 → 36 in both modes,
one head each**, with the two AFTER logs byte-identical to each other and to
the pass's committed `HEAD_AFTER_*.cmp`.

---

## 1. Breaking the law — 9 purpose-built arms, 0 AWAY-GOLDEN

`runarm_v78.sh` builds each arm with Surelog (golden) and with BOTH frozen
binaries in BOTH views (`default` and `--elabuhdm`), **records the rc of every
producer**, and censuses all five databases with the pass's own `cacen78`.
`score78.py` (the pass's judge-fields-only 3-way scorer) adjudicates. Span
PRESENCE is scored **separately**, because golden's folded constant here is
LOC-LESS.

| arm | what it attacks |
|---|---|
| `v1_elem78.sv` | the ELEMENT and COUNT ladder: `8'hFF` (hex), `3'o7` (oct), `8'd5` (dec), a param ref, `1'sb1` (signed), `2'(1'b1)` (a cast), `{1{1'b1}}`, `$clog2`, a PACKAGE-parameter count, `{2000{…}}`, a non-constant element, a const-init var element, a replication as ONE operand of a wider op, and a HEX element clamped 32→8. Every row appears TWICE — once assigned from a gen scope to a MODULE-BODY signal (the head's pairing), once in the module body itself |
| `v2_lhs78.sv` | the Lhs ladder — 19 Lhs shapes × 3 instances: module-body var / net / signed / `int` / `byte` / `bit` / enum / packed struct, output PORT, inout PORT, part-select, bit-select, unpacked-array element, CONCAT Lhs, gen-LOCAL var and net, an implicit gen net, an INTERFACE signal via `hier_path`, and a **gen-local declaration that SHADOWS a module-body name** |
| `v3_refuse78.sv` | shapes slang's `tryEval` CAN fold but Surelog's `reduceExpr` might not: const-function counts, `$bits`, package enum members, package localparams, an enum CAST element, shift / power / ternary / sum counts, an unpacked-array-param element, a unary-minus element |
| `v4_delay78.sv` | the DELAY fence (`assign #DLY` with DLY a **parameter**, a literal delay, no delay, a parenthesised param delay) and the HOMES: gen-for ×3, gen-case, a **three-deep** gen nest, an INTERFACE gen scope, a PROGRAM gen scope, an INSTANCE ARRAY |
| `v5_act78.sv` | INSTANCE ACTUALS carrying replications (the `ReplicationPassedToInstance` blocker) as a measured fence, plus every refused shape: X, Z, concat-of-replication, ZERO-count-in-concat, nested replications, concat of two replications, and an already-literal Rhs |
| `v6_ndecl78.sv` | NET-DECLARATION ASSIGNMENTS in a gen scope, a variable initialiser, an interface instantiated INSIDE the gen scope with a `hier_path` Lhs |
| `v7_pre78.sv` | PREEMPTION: replication Rhs shapes that LATER `emitGenScopes` arms would have handled (the never-written const-init module-var fold, the const-call fold, the unpacked-param select) |
| `v8_spec78.sv` | five PARAMETER SPECIALIZATIONS of one definition (natural 3/6/6/65/64 against targets 4/4/10/10/10) — the clamp and the `>64` bail per specialization |
| `v9_rc78.sv` | the rc probe (see §5) |

**`ARM_SCORES.txt`, 22 scored readings across 8 arms plus the three
earlier-pass arms the boundary flags: `AWAY-GOLDEN` is 0 EVERYWHERE.**

Stronger still — with the span dropped from the key, **every arm's distance to
golden strictly DECREASES and never increases**:

```
arm            golden-vs-PRISTINE   golden-vs-PATCHED
v1_elem78              26                    6
v2_lhs78              110                   12
v3_refuse78            26                    2
v4_delay78             56                    0   <- 100 % golden-equal
v5_act78               12                   10
v6_ndecl78              6                    0
v7_pre78                4                    0
v8_spec78              20                    0   <- 100 % golden-equal
r10v68repro (dir)      76                   72
```

### What the arms established that the pass had not measured

* **Golden folds a gen-scope replication in EVERY Lhs shape** — including a
  part-select, a bit-select, an unpacked-array element, a CONCAT Lhs and a
  `hier_path` into an interface — so `writeCont_assign`'s
  `lhs->UhdmType() == uhdmref_obj` gate is NOT the producer here; only the
  CLAMP follows the Lhs. Consequence: **pristine is wrong on every gen-scope
  replication cell golden folds, so an AWAY-GOLDEN is structurally impossible
  for the shapes this law reaches** — measured, not argued.
* **The DELAY hypothesis is REFUTED.** `UhdmWriter::writeCont_assign` skips its
  reduce block when the delay is a `ref_obj` (`if (cloned == false)`), which
  predicted an unfolded golden for `assign #DLY x = {N{1'b1}}`. Golden folds it
  anyway (`v4` D1) — further proof the gen-scope fold does not come from that
  function.
* **Net-decl-assigns are structurally out of reach.** `wire [3:0] w = {TW{1'b1}};`
  in a gen scope keeps the operation — and keeps `ref:TW` UNFOLDED — in golden
  AND in both binaries. The new arm sits in `emitGenScopes`'s
  `ContinuousAssign` member loop; net-decl-assigns are built earlier into
  `ndaCas` (ModuleEmit ~14373) and never enter it.
* **No preemption.** The arm is placed before `constCallFold` and before the
  never-written-const-init-var fold; `tryFoldConst` returns null on exactly the
  shapes those later arms want, so each still fires (`v7` P1/P2 unchanged,
  P3/P4 TO-GOLDEN).
* **Specializations do not leak** (`v8`: 10/10 TO-GOLDEN across five parameter
  sets, including 65 surviving and 64 clamping to 10).
* **Span presence matches golden on every constant we emit** — all LOC-LESS,
  in every arm; the only span-presence differences are cells where golden folds
  and we deliberately refuse.

---

## 2. Independent census on the real target

`cacen78` + `tscen78` on Earlgrey's own databases, both modes, calibrated
golden-vs-golden FIRST (0 differing of 20,582; golden re-read byte-identical):

| | TO-GOLDEN | AWAY | MOVED-WRONG | STILL-WRONG |
|---|---:|---:|---:|---:|
| cont_assigns, default | **2** | **0** | **0** | 113 |
| cont_assigns, testflags | **2** | **0** | **0** | 84 |

The whole-design EXPRESSION census (162,259 / 160,030 cells, every operand
depth) changes exactly **6 multiset entries per mode**, all at
`prim_ram_2p_async_adv` `CA_L171:12` / `CA_L172:12`; golden-matching cells
**+2** in each mode. The 4,158 DEF-section cont_assign rows are **0 differing**
— the fold is ELAB-only on the real target too.

---

## 3. The corpus fence, re-hunted from my own pristine sweeps

`replfence78` over **all 2,314 pristine databases** reproduces the pass exactly:
`DATABASES_SCANNED=2314`, `GEN_REPL_DATABASES=2`, `GEN_REPL_CELLS=6`,
`MOD_REPL_CELLS=68`, `GEN_CAST_CELLS=277` (`FENCE_*.tally`,
`FENCE_GEN_CELLS.txt`). The third gen cell — `ibex_multdiv_fast.sv:174`
`{16{signed_mult & imd_val_q_i[33]}}`, a `part_select(accum)` Lhs — is the live
fence and does **not** move; golden keeps its operation too. After the patch
`GEN_REPL_CELLS` falls 6 → 2 and all 68 `MOD` control cells are byte-identical.

---

## 4. Boundaries — mine are WIDER than the pass's

Both run with the two frozen binaries over a COPY of `tools/probe`, **`.sv` AND
`.v`**, **no path filter**, the list read on **fd 3**, all children
`</dev/null`, `PROCESSED` asserted, **rc recorded for every cell**, dumps
workdir-normalised before the byte compare.

```
WIDE  PROCESSED=3561 (== LISTED 3561; 3493 .sv + 68 .v)  identical=6822
      DIFFERING=12  no_output=288
      rc PER CELL IDENTICAL BETWEEN BINARIES: 0 asymmetric cells of 14,244
DIR   PROCESSED=1519 (== LISTED 1519)  identical=2773  DIFFERING=11
      no_output=254;  signals 12 rc=139, 6 A + 6 B on the same six units
FENCED= (empty) -- the four fenced names match 0 paths and 0 directories
```

The 12 WIDE cells are **6 files × 2 views**: this pass's three arms, plus
`r10earl_repro/pf19.sv` (2 cells), `r10earl_repro/x.sv` (1) and
`r10v68repro/v1_pos68.sv` (2) — each re-measured against its own Surelog golden
here: **TO-GOLDEN 2 / 1 / 2, AWAY 0, MOVED-WRONG 0**. Compiled as a whole
directory, `r10v68repro` scores **TO-GOLDEN=2 AWAY=0 MOVED-WRONG=0
STILL-WRONG=39** (all 39 pre-existing and identical on both binaries).

**Every earlier-law arm directory named in the brief is byte-identical between
the binaries** — `r10earl61…77repro`, `r10rgg14/16/18repro`, `r10v69/75/77repro`
all show `wide_diffs=0`; only `r10v68repro` moves, and it moves to golden.

The four DIR units `r10uvm75/76/88repro` and `r10v109repro` are the documented
`vpiTaskFunc` ORDER COIN, proved twice (`BOUNDARY_DIR_ATTRIB.txt`,
`COIN_CONTROL.txt`): their A-vs-B **sorted** diffs are 0 while the raw diffs are
4–20, and **three consecutive invocations of the PRISTINE binary alone** over
`r10uvm76repro` give three different dump hashes with a sorted diff of 0 between
them.

---

## 5. One measured behaviour the pass did not report

Folding the whole Rhs can REMOVE an unsupported node from emission, and
`slang-uhdm` reports unsupported constructs with **rc=4**. `v9_rc78.sv`:

```systemverilog
if (N > 0) begin : g9
  assign r_a = {N{f9(1)[0]}};      // an element select of a call result
end
```

→ **pristine `rc=4`** ("unsupported constructs encountered: element select
base"), **patched `rc=0`**. The direction is strictly toward MORE databases
produced, never fewer; the corpus shows zero status movement
(`SLANG_REJECT` 50/50 on u2r, 283/284 on surelog) and the wide boundary shows
**0 rc asymmetry over 14,244 invocations**, so the reach today is nil — but an
`rc` flip is exactly the kind of thing `verify_golden.py` records as a status,
so it is recorded here.

---

## 6. Ranked residues (all MOVED-WRONG, none an AWAY-GOLDEN, all zero corpus reach)

**V1 — the SHADOWED-NAME clamp.** Surelog's `bindVariable` searches the
enclosing `module_inst` **BY NAME**; `caLhsAdjustSize68` decides by SCOPE. When
a gen-local declaration shadows a module-body name of the same width, golden
clamps (it binds the module-body one) and we do not. `v2_lhs78.sv` L17,
3 instances: golden `BIN:111111 sz 4`, ours `sz 6`. A fix must make the helper
name-based, and the helper is SHARED with the landed § `genvarWholeCaRhsFold68`,
so it needs its own census — correctly deferred.

**V2 — the producer's `n > 1000` clamp.** `ExprEval.cpp`'s `vpiMultiConcatOp`
arm caps the repeat count at 1000. `{2000{1'b1}}` gives golden 1000 digits at
`vpiSize 1000`; we emit 2000 at 2000. Pre-existing in the already-landed
MODULE-BODY twin (`v1` M10 is wrong on both binaries), so a gen-only fix would
split the two homes.

**V3 — a CAST element reduces at 64 bits.** `{N{e3_t'(4'h5)}}`: golden's
element reduces to a 64-wide constant (3 × 64 digits); ours is 3 × 4. Same
family as the pass's R1 (the gen-scope size cast, 277 corpus cells).

**V4 — the judge-invisible `int_typespec` `VpiValue`** (the producer's "word
size"). The pass's R4, and its scoring decision is CORRECT: `int_typespec::Compare`
(`UHDM/build/generated/src/int_typespec.cpp:97`) reads `Cast_to_expr`,
`VpiSigned`, `Ranges` and — through `typespec::Compare` — `VpiName`,
`Typedef_alias`, `Instance`, and **never `VpiValue`**; `constant::Compare` reads
only `VpiConstType` plus `expr::Compare`'s `VpiDecompile` / `VpiSize` /
`Typespec` and `BaseClass::Compare`'s `VpiType` / `VpiName` / `VpiDefName` —
**`VpiValue` is not a judge field for a constant either**. Dropping the `tsval`
column was right.

**V5 — gen-scope folds the law does NOT reach**, all pre-existing and identical
on both binaries: X/Z elements (golden folds with Surelog's own casing
`BIN:XXXXXX` / `BIN:zzzzzz`), a concat containing a replication, a zero-count
replication inside a concat, a concat of two replications, and a replication
used as ONE OPERAND of a wider operation (golden folds `{4{1'b1}} | 32'h0`
whole to `UINT:15 sz 32`; the module-body twin already does, the gen scope does
not).

---

## 7. Instruments in this directory

* `v1…v9_*.sv` — the nine arms.
* `runarm_v78.sh` — one arm, Surelog + BOTH frozen binaries in BOTH views, rc
  of every producer RECORDED, `cacen78` census of all five databases.
* `vwide_v78.sh` / `vdir_v78.sh` — the boundaries (`.sv` AND `.v`, fd-3 list,
  children `</dev/null`, PROCESSED asserted, per-cell rc log).
* `GATES_V78.txt` — the verifier's own gate run, every number.
* `ARM_SCORES.txt`, `ARM_LEDGER.txt` — the scored readings and the moved /
  refused cells in full.
* `BOUNDARY_WIDE.*`, `BOUNDARY_DIR.*`, `BOUNDARY_DIR_ATTRIB.txt`,
  `COIN_CONTROL.txt` — the boundary tallies, diffs, signals and the two
  independent order-coin proofs.
* `FENCE_*.tally`, `FENCE_GEN_CELLS.txt` — the corpus fence scan, re-run from
  my own pristine sweeps.
