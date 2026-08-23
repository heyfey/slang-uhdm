# r10vbuvm29 — adversarial verification of r10buvm29 (`§ castOverStreamKeepsCast29`)

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10buvm29.patch`'s production hunk is
correct; no pristine-right → patched-wrong cell was found on legal
SystemVerilog, so no fix was needed and the production surface is unchanged.

**MEASUREMENT ONLY.** Nothing here is an acceptance judge — the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` (through `scripts/verify_golden.py`) is.
slang was **NOT** patched, `results/*.csv` were **READ ONLY**, **nothing was
promoted** and **no corpus row was converted**.

| | |
|---|---|
| BASE | `d71c34e` |
| worktrees | `/tmp/wt_vbuvm29pris` (pristine), `/tmp/wt_vbuvm29` (patched) |
| pristine binary | md5 `c0544c563e6f68b1f43072e5d4db5476` — **reproduces the implementer's exactly** |
| patched binary | md5 `3f5cdd274ec4e3bead38f22eb6d08085` — **reproduces the implementer's exactly** |
| arms | 22 arm-views, three-way, both views; **14 go PRISTINE-FAIL → PATCHED-PASS the official `uhdm-cmp`, 0 go the other way** |
| controls | `gv29_d_controls` + `gv29_g_tdname` (~45 control cells) are **whole-dump byte-identical between the binaries in both views** |
| boundary | `LISTED=3388 PROCESSED=3388 MOVED=25 NO_OUTPUT_PAIRS=276`, PROCESSED-ASSERT-OK, depth-blind AWAY-GOLDEN 0 on every scored mover |

`VERIFIED.r10buvm29.txt` is the full record: rebuild, the whole gate battery
re-run from my own sweeps, the head re-decoded from my own pristine cmp log
against the generated `expr::Compare`/`operation::Compare` sources, the fence
re-found by an independent source grep, the arm table, the boundary, and the
residues.

## What the verification corrected in the implementer's report

1. **The mover count is 4/956, not 2/956.** `default/SeqDriver` and
   `testflags/SeqDriver` also move and were predicted by nobody. Attributed and
   cleared here: deterministic (13 pristine runs, serial and under 6-way load,
   all `54bc7331e8bc`; 7 patched runs all `d56268425141`), a **pure arena-order
   flip** of `bit_typespec (uvm_reg_data_t)` and `bit_typespec
   (uvm_reg_addr_t)` — the **sorted dumps are byte-identical** — with the
   CAST/STREAM census unchanged, the head cmp logs byte-identical in both modes
   and the rows byte-identical. Judge-invisible; golden's own order is the
   patched one.
2. **The canary counts are `ok=56` / `ok=9`, not `52` / `8`**, with the
   `canaries.sh` this pass shipped, in either argument order. `changed=0
   absent=0` throughout, so the gate holds.
3. Four of the 84 `BuildUVMPkg` diff sides name the target enum typespec's own
   declaration span (`:57531`, `:57558`), not `:58249`/`:58284`. Cosmetic.

## The arms

`gv29_a_shapes` (stream shapes: with-range, nested stream, parameter and
typedef'd slice sizes, queue, `this.`-qualified property, width-matched fixed
source) · `gv29_b_positions` (cont-assign, port actual, case expression AND
case item, ternary, for-init, while, `$display` arg, named arg, **default
formal value**, `'{default:}`, foreach) · `gv29_c_homes` (interface, program,
static class method, class in a module, generate-if, generate-for, always_ff,
final) · **`gv29_d_controls`** (the negative arm: casts over concat /
replication / call / part-select / bit-select / literal / array element /
nested cast / enum / packed struct, bare streams in eight carriers **including
streaming assignment targets**, `signed'`/`unsigned'`, `$cast`) ·
`gv29_e_targets` (packed union, 2-D packed vector, signed vector typedef,
cross-package scoped enum, `longint`, `time`) · `gv29_f_macro` (the head's real
provenance — the cast text comes from a `` `define `` macro body, in a
parameterized class, out-of-block method, three instances) · **`gv29_g_tdname`**
(the control that proves R-CASTTDNAME pre-existing) · `gv29_h_genident` (the
DEF-view generate-block bare-identifier cast target road) ·
`gv29_i1`/`gv29_i2`/`gv29_i3` (1, 2 and 3 instances — the patched cast-node
count matches golden exactly in both views).

## The instruments

* `vthree29.sh` — three-way arm runner (golden / pristine / patched), one view
  per invocation, **rc recorded for every invocation** (`verify_golden.py`
  hides rc=139 segfaults as `SLANG_REJECT`; an arm must not).
* `vrunall29.sh` — both views per arm plus the whole-dump pristine-vs-patched
  delta and the three-way score.
* `vnorm29.py` — **view-general** three-way comparator over normalised
  `uhdm-dump` text as a **multiset**. It drops object ids, absolute paths and
  `line:col` spans — exactly the fields no generated `Compare` reads — and
  reports TO-GOLDEN / **AWAY-GOLDEN** / STILL. `--nodepth` drops the
  indentation depth from the key too, which is **mandatory** when a patch adds
  a WRAPPER node: a depth-keyed run reports the whole shifted subtree as
  AWAY-GOLDEN (it did, three times here, every one a false alarm).
* `vbound29.sh` — the wide boundary, `.sv` AND `.v`, no path filter,
  subdirectories included, fd-3 list, children `</dev/null`, rc per cell,
  PROCESSED asserted, sharded so 3388 files × 2 views × 2 binaries finish in
  bounded time.
