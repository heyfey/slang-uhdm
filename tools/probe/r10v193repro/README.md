# r10v193 — ADVERSARIAL VERIFICATION of r10uvm193, § `cloneArrayRecvArgMintsElemVar193`

**VERDICT: ACCEPT.** Every headline number of the pass reproduces bit-for-bit
from fresh worktrees and independently built binaries, and four new arms
covering nine faces the pass's own grid does not reach found **no
pristine-right → patched-wrong cell on any legal SystemVerilog**. The
production surface is UNCHANGED by this verifier; this directory is evidence
only.

**MEASUREMENT ONLY.** Nothing here is an acceptance judge. `uhdm-cmp` and
`scripts/verify_golden.py` are the authorities. **LHS is ALWAYS golden
(Surelog); RHS is ALWAYS ours**, everywhere below. slang was NOT patched,
`results/*.csv` were READ ONLY, no row was converted, `GOLDEN_DEFER` stayed
unset, and the four slang-fenced tests were never dispatched and are not
spelled in this directory.

| | |
|---|---|
| BASE | `9c358cda` |
| pristine binary, rebuilt here | md5 `d5a59dbbef4563591865e0da88492e57` — the pass's claim, EXACT |
| patched binary, rebuilt here from the patch on a FRESH `9c358cda` | md5 `95ea482622bc432f0f2460e6739a6ad6` — the pass's claim, EXACT |
| verifier surface | `tools/probe/r10v193repro/` only |

`GATES.r10v193.txt` carries all ten gates. `GRID.r10v193.txt`,
`CENSUS.r10v193.txt`, `MOVERS.r10v193.txt`, `BOUNDARY.r10v193.txt`,
`PREDICT.*.r10v193.txt` and the eight `head_*.v193.cmp` files are the raw
outputs.

---

## 1. What reproduced, and how independently

Both worktrees were created fresh at `9c358cda`; the patch was applied with
`git apply -3` (two production files, cleanly, zero conflict markers, zero
stray files); both binaries were built here at `-j 2` and frozen `chmod 555`
before a single sweep ran; `SLANG_UHDM` was exported explicitly per binary and
every `cmds.txt` in all four workdirs was audited by BINARY PATH.

* **Both md5s are exact.** A patch that rebuilds to the very binary its numbers
  were measured on is the strongest single check available, and it holds.
* corpus: surelog `937/567/48/19/10/3/2/1/1`, uhdm2rtlil `679/50/2` in both
  modes, on BOTH binaries; `ct8rows` **0 differing ROWS over 1588** against the
  committed `results/golden_surelog.csv` and against this verifier's own
  pristine sweep, **status histogram AND dump-column histogram**.
* **byte movers 4/956 and 0/1358, with the same six hashes** the pass named
  (`0f90d144a575`, `ec361b2b9f92`, `c7d27b71e110`, `3b159c20cfc2`,
  `46bb51af242f`, `8585bcabf6f2`), and the a-priori predictor run on this
  verifier's OWN pristine sweep names **exactly those four rows, 10 cells each**
  (`LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4 CELLS=40`) before any
  patched database is read. Attribution: 144 order-blind lines per mover,
  **4 out / 140 in**, no `UNEXPECTED-MOVER`.
* heads **58 → 29** on SeqDriver ×2 and MiniAmiq ×2, ONE `^LHS:` throughout,
  every other named row unchanged; the new head is the `LHS: <null>` mirror
  `ref_var (uvm_pkg::uvm_root::run_test::phase_runner_proc) @411:11-411:28`
  under `begin @403:3-403:51`, `unsupported_typespec (process) @411:3-411:10`
  — R0 as written.
* the pass's own grid reproduces cell for cell: arm A **6/6**, B **10/10**,
  C **18/18**, D **2/2** TOWARD, **AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0 /
  orphan mints 0** in every arm and both views, calibrated golden-vs-golden at
  every column 0 first; arm C's DEF view goes `uhdm-cmp` rc=255 → **rc=0**.
* corpus census, the four movers: **TOWARD 10 / AWAY 0 / MOVED-WRONG 0 /
  ONLY-OURS-MOVED 0**, golden 10 mints / pristine 0 / patched 10,
  **orphan mints 0 on all three sides** — the mint identity is exact, never a
  duplicate where golden holds one.
* the wide boundary, re-run here over this verifier's own worktree:
  `LISTED=5147 FENCED_SKIPPED=0 PROCESSED=5147 MOVED=28 NO_OUTPUT_PAIRS=394
  PROCESSED-ASSERT-OK`, and the MOVED set is the pass's 20 arm-views plus this
  verifier's own 8. **Nothing else in 5147 arm files moved.**

Two bookkeeping notes, neither a defect:

* the pass's boundary says `LISTED=5160` because its `ROOT` was a copy of the
  **main tree's** `tools/probe`, two commits ahead of the BASE; that arm set is
  a superset of this one and its MOVED set is the same 20.
* `head_pris_*.cmp` / `head_pat_*.cmp` hold the FIRST of `uhdm-cmp`'s two
  identical `decompile:` blocks per side (15 lines of 29, 29 of 58). The object,
  the span, the parent and even the `id:` numbers match this verifier's own
  capture exactly; only the repeated block is absent.

---

## 2. THE PRODUCER, read independently — and one correction to the write-up

`~/git-repos/UHDM/templates/clone_tree.cpp:119-186` was read here rather than
taken from the pass. The quoted branch is verbatim and the decode is right:
`method_func_call::DeepClone` reads `phier->Path_elems()->back()` as the
receiver, and for an argument `any_cast<ref_obj*>` accepts and whose `override`
test passes, an `array_var` receiver hands it `clone_tree(arr->Variables()
->front())` renamed after the argument and parented at the HOME call, while
every other receiver hands it the receiver — § `cloneBuiltinMethodArgBindsReceiver184`.

Reading the UHDM class hierarchy pins the producer's two gates exactly, and
this is where the shipped drain is not congruent with it:

```
ref_obj : simple_expr          bit_select, part_select,
                               indexed_part_select, var_select : ref_obj
ref_var : variables            hier_path : simple_expr
```

so `any_cast<ref_obj*>` accepts `ref_obj` **and its four subclasses**, and
refuses `ref_var` and `hier_path`. The shipped drain accepts `ref_obj`,
`bit_select` and **`ref_var`**, and refuses `part_select`,
`indexed_part_select` and `var_select`:

* **narrower on three subclasses** — a STILL-WRONG, never an AWAY, and arm B
  measures a live instance (below, R-V1);
* **wider on `ref_var`** — the only shape in the patch that could in principle
  fire where golden does not. It is unreachable: `MakeRef_var` appears **zero**
  times in `src/ExprEmit.cpp`, the only file that builds `hier_path`
  `Path_elems`, so no `ref_var` is ever a path element. Recorded as R-V2.

The pass's own claim that `ElaboratorListener::bindAny` is not the producer is
also correct: `bindAny` dereferences a hit to an EXISTING object and cannot
mint.

---

## 3. THE FOUR VERIFIER ARMS — nine faces the pass's grid does not reach

Every arm is CALIBRATED golden-vs-golden-vs-golden first (every column 0 but
UNTOUCHED). Full numbers in `GRID.r10v193.txt`.

| arm | view | TOWARD | AWAY | MOVED-WRONG | ONLY-OURS-MOVED |
|---|---|---|---|---|---|
| A `gv193_a_elemkind.sv` | def / elab | **20 / 20** | **0** | **0** | **0** |
| B `gv193_b_recvface.sv` | def / elab | **6 / 6** | **0** | **0** | **0** |
| C `gv193_c_pushface.sv` | def / elab | **18 / 18** (**20 / 20** CTX-blind) | **0** | **0** | **0** (2 key artifacts, §4) |
| D `gv193_d_listing.sv` | def / elab | **8 / 8** | **0** | **0** | **0** |

### Arm A — the MINT's ELEMENT KIND, and the shared-vector question

`mintArrayElemVar193` is `*clone = *src`, which copies **owned vectors by
pointer**: `struct_var`/`union_var` carry `Variables` and `Var_bits`, and
`bit_var`/`logic_var` carry `Ranges` and `Var_bits`, of which the shipped code
re-vectors only `Ranges`. Arm A puts every one of those kinds at the element of
an array receiver. Result: **all ten kinds — `struct_var`, `union_var`,
`logic_var`, `bit_var`, `enum_var`, `real_var`, `string_var`, `class_var`,
`byte_var`, `int_var` — take golden's mint exactly**, and a block-for-block
`uhdm-dump` comparison of each mint against golden's own says **MATCH on all
eight kinds present in both dumps**, modulo only the listing prefix (R3). The
sharing never materialises: neither Surelog nor this emitter populates
`Variables`/`Var_bits` on the element variable of an array declaration, and
`Ranges` live on the TYPESPEC, not on the variable — so the re-vectoring is
defensive and the un-re-vectored `Var_bits` is unreached. `int nest[int][int]`
(A9) resolves its element to an `int_var`, so the six REFUSED kinds are not
reached from an associative-array-of-arrays either.

### Arm B — the RECEIVER FACE and the MUST-STAY FLOOR, scored in one census

* **B7, § `cloneBuiltinMethodArgBindsReceiver184`'s STRING half MUST STAY.** In
  the `Quayside_v193` clone listing, `rode_v193.substr(1, lug_v193)` reads
  `act=string_var(rode_v193)@95:12` — THE RECEIVER — on **golden, pristine and
  patched alike, in BOTH views**. Unmoved.
* **B8, § `retNameArgKeepsReturnVar184v` MUST HOLD.** `rode_v193.getc
  (b8_retname_v193)`, the free function's own return name as a string
  receiver's argument, reads `act=int_var()@105:22` — the RETURN VARIABLE, not
  the receiver — on all three sides, both views. Unmoved.
* **B2** a QUEUE ELEMENT receiver through a `bit_select` calling a USER-DEFINED
  method (the corpus's `regs[j].get_address(this)` shape) takes golden's
  `class_var` mint. **B9** the seam between the two halves — a STRING ARRAY
  ELEMENT receiver, where § 184's site gate passes on `type->isString()` and its
  recorder refuses the `bit_select` — takes this law's mint, and both halves
  never write one cell.
* **B3** a plain class handle and **B4** a call-result receiver do not move.
* **B1** is the measured instance of the narrowing: `string grid_v193[2][3]` with
  `grid_v193[0][1].substr(...)` gives a **`var_select`** receiver, golden's DEF
  clone mints a `string_var` and we do not — **STILL-WRONG, identical on both
  binaries, never an AWAY** (R-V1).

### Arm C — the `pushVar` half, where the pass's first cut regressed

* **C2** the same name written BEFORE and AFTER the call keeps its own
  declaration on golden and on both binaries — the containment fix (`e->
  VpiParent() == n`) holds, and the AWAY the pass recorded in §5 of its README
  does not come back.
* **C1** is the producer's OWN cited example, `gear_v193.unique(cb_v193) with
  (cb_v193.get_id_v193())`: golden gives the argument AND the `with`-clause
  reference the same `class_var` mint, and patched matches both.
* **C4** a DOTTED later argument whose member is named like the mint
  (`two_v193(pin_v193, one_v193.pin_v193)`): golden rebinds that `hier_path`
  member to the mint too, and so do we — the widest reach the push has, and it
  is golden's own.
* **C5** the same name at argument 0 and argument 1 and **C6** a later argument
  that is an OPERATION over it both match golden. **C3** a nested call as the
  argument is refused on both sides. **C7** a call with no arguments has nothing
  to mint.
* the DEF census counts **golden 14 mints / pristine 0 / patched 14, orphan 0**
  — no duplicate, no shortfall.

### Arm D — the LISTING AXIS

One golden holds six listing faces at once. **The HOME package body does not
move** (`Berth_v193/DEF` and `/ELAB`, golden and both binaries identical); a
package **never imported anywhere** does not move; **two** wildcard importers of
one body both mint (8 TOWARD = 2 listings × 2 subroutines × 2 views); and the
**explicit single-item import** (`import P::fn;`) mints in golden and not in
ours — R1 as the pass wrote it, a STILL-WRONG with **corpus incidence zero**.

---

## 4. Two scoring artifacts worth carrying forward

* **`ONLY-OURS-MOVED 2` in arm C is a KEY artifact, not a regression.** The
  census key carries a CTX column, and golden marks a reference inside a `with`
  clause `CALLARG` where we mark it `PLAIN`, a shape difference that predates
  this pass. Re-keyed CTX-blind (`score193ctx.py --noctx`) the same two rows
  score **TOWARD**, and the arm reads **TOWARD 20 / AWAY 0 / MOVED-WRONG 0 /
  ONLY-OURS-MOVED 0** in both views. The value on those rows is *byte-equal to
  golden's*. Run both keyings and report both, as `score193.py`'s own
  `--noface` note already advises for the FACE column.
* **the arms' `-elabuhdm` view now leaves ORPHAN MINTS** (arm C elab: golden 0,
  pristine 1, patched 3; arm B elab: golden 0, pristine 2, patched 4). UHDM's
  own elaborator re-runs this producer under that flag and re-binds the
  argument to ITS mint, orphaning ours. Judge-invisible — `design::Compare`
  never walks an object no edge lands on — and **corpus incidence zero**,
  because no corpus row carries `-elabuhdm`. This is the pass's R4 with its
  object-population consequence named. (Recorded as R-V3.)

---

## 5. RESIDUES this verifier adds (all measured, none an AWAY)

* **R-V1 — the three refused `ref_obj` SUBCLASS receivers.** The producer
  accepts `part_select`, `indexed_part_select` and `var_select` receivers
  (they are `ref_obj`s) and the drain refuses them. Arm B's `b1_varsel_v193`
  is a live instance: golden's DEF clone mints, we keep the declaration, on both
  binaries. `src/ExprEmit.cpp` pushes all three kinds into `Path_elems`
  (`elems->push_back(vs/ps/ips)`), so the face is reachable. Corpus incidence:
  zero (the predictor names no such cell in 956 + 1358 databases).
* **R-V2 — the `ref_var` receiver widening.** The drain accepts a `ref_var`
  path element as a receiver; the producer's `any_cast<ref_obj*>` does not,
  because `ref_var` derives from `variables`. Unreachable today: `MakeRef_var`
  appears zero times in `src/ExprEmit.cpp`. Worth deleting the day anyone makes
  it reachable, since it is the one branch that could fire where golden does
  not.
* **R-V3 — orphan mints under `-elabuhdm`,** §4 above.
* **R-V4 — § 184 under-fires on NON-STRING, NON-ARRAY receivers.** Arm B's
  `b3_handle_v193` shows golden binding a user-defined method's argument to a
  plain **class-handle** receiver — the producer's `else` branch, which is
  § 184's law — while our § 184 site gates on `stripImplicitConv(*recv).type->
  isString()`. Not this pass's (both binaries agree there, and in this arm we
  happen to match golden anyway through the ordinary binding), but it is the
  same block, and anyone widening § 184 should read the producer's `else`
  rather than the string fence.
* **R-V5 — `Var_bits` is not re-vectored** in `mintArrayElemVar193` where
  `Ranges` is (`struct_var`, `union_var`, `bit_var`, `logic_var`). Unreached in
  the corpus and in arm A, where no element variable carries one. Cosmetic
  today; it is the same class of hazard the `Ranges` copy was written for.

The pass's own R0-R6 all stand as written; R5 (the static-address false mover)
was re-decoded here and its entire diff on all three arms is `vpiDecompile` /
`UINT` constants shifted by exactly **8192** (`22634233 → 22642425`,
`22633377 → 22641569`).

---

## 6. REPRODUCING

```sh
g++ -O2 -std=c++17 ../r10uvm193repro/ct193arg.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct193arg

for a in a_elemkind b_recvface c_pushface d_listing; do
  CT193=./ct193arg ../r10uvm193repro/grid193.sh gv193_$a.sv \
        <pris.bin> <pat.bin> <wd_$a>
  python3 ../r10uvm193repro/score193.py <wd_$a>/cen.g.def.txt \
        <wd_$a>/cen.a.def.txt <wd_$a>/cen.b.def.txt -v
  python3 ./score193ctx.py     <wd_$a>/cen.g.def.txt \
        <wd_$a>/cen.a.def.txt <wd_$a>/cen.b.def.txt --noctx -v
done

# the three arms that hold this law's own cells, re-scored on their OWN golden
for a in ../r10uvm184repro/g184_b_kinds.sv ../r10v184repro/gv184_d_recvmeth.sv \
         ../r10uvm39repro/t55b/dut.sv; do
  CT193=./ct193arg ../r10uvm193repro/grid193.sh $a <pris.bin> <pat.bin> <wd>
done
# -> TOWARD 4 / AWAY 0 / MOVED-WRONG 0 in both views on each, same head object
#    and same cmp line count (146/154, 42/42, 20/20) on both binaries.
```
