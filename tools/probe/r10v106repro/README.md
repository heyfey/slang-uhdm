# r10v106 — adversarial verification of r10uvm106 (§ unsizedBasedParamRhsSize106)

**VERDICT: ACCEPT AS SHIPPED.** No pristine-right → patched-wrong cell was found
on any legal SystemVerilog or Verilog-2001 input, in either view, on any
Compare-visible field. No fix was needed, so no `.verified.patch` is shipped;
`/tmp/r10uvm106.patch` (md5 `8df9ff32b15bb8aee08e52ebf56c3218`) is the
deliverable unchanged.

Everything below was measured in `/tmp/wt_v106` (patched) and `/tmp/wt_v106pris`
(pristine), both fresh worktrees at `e0e27de`, with both binaries rebuilt from
scratch by the verifier and frozen `chmod 555` before any sweep.

## Reproduction of the pass's headline numbers

Both binaries rebuild **bit-for-bit**: pristine `b1c4919c02bf45794c87932d75829197`,
ship `2e2acdf4360432680eadd18077ebe998` — identical to the pass's claims.
Every gate number in `r10uvm106repro/GATES.txt` was reproduced exactly; see
`VGATES.txt`. The patch also applies cleanly on today's HEAD `6c74d2aa`.

`SeqDriver 60 → 29` cmp lines in **both** modes, one head each; the other six
rows unchanged and — the stronger check — **textually** identical head output
(id-/path-normalised diff = 0 lines on all ten unchanged head cells).

## What was attacked

Ten new arms (`b01`..`b10`), .sv and .v, run in DEF and ELAB with rc per cell:

* `b01_bases.sv` — every unsized literal spelling: `'h 'b 'o 'd` in both cases,
  `x`/`z`/`?` digits in every base, underscores, a 60-bit value, the
  `'b0/'b1/'B0/'B1` grammar tokens, and every signed spelling `'sh 'SH 'sb 'so 'sd 'shx`.
* `b02_decl.sv` — 23 declaration shapes against one `'h1a`: plain, `signed`,
  `unsigned`, ranged, signed-ranged, `int integer longint shortint byte bit
  logic reg time real shortreal string`, `logic[3:0]`, `bit signed`, and the
  `localparam` forms.
* `b03_homes.sv` — `$unit`, package, interface (header + body + local), program
  (header + body), module header, module body, generate-**if**, generate-**for**,
  generate-**case**, a named `initial begin`, function-local, task-local, class
  (header + body + local), nested in a top.
* `b04_over.sv` — named / positional / `defparam` overrides, override actuals
  that are unsized (`'hFF`), sized (`32'hFF`), plain (`15`) and `'b0`; a
  parameter passed down through a mid-level module; 1..3 instances.
* `b05_ctx.sv` — the constant reused as a range bound, a cast width, inside a
  concat, a replication, a ternary, unary `-`/`~`, a later parameter's
  initialiser, and a generate condition.
* `b06_import.sv` — wildcard import, explicit-item import, `export`+re-import,
  two importers of one package, a package imported into a package, and the
  package parameter read from a class.
* `b07_deep.sv` — three-level hierarchy, the same parameter name at each level,
  each level overridden three different ways.
* `b08v_v2001.v` — Verilog-2001: non-ANSI and ANSI headers, `defparam`,
  `generate for` with a localparam driving a child override.
* `b09_macro.sv` — literals arriving through macros, multi-declarator lists, an
  escaped identifier, a `'h 1a` with an intra-token space.
* `b10_uvmish.sv` — the UVM_RADIX shape: a package parameter read by classes in
  the same package and imported by a module.

Instruments (all new, written for this verification):

* `v106run.sh` — three-way arm runner (fresh Surelog golden + both frozen
  binaries in one worker, both views, rc per cell, scratch keyed on the relative
  path).
* `v106cen.py` — an **independent** census: span-free, path-free, keyed on
  (root listing edge, FULL scope-name chain, parameter name), multiset
  (Counter) join, over every `param_assign` **and** every `parameter` object.
  Payload = Rhs kind + `vpiSize` + `vpiConstType` + value tag + `vpiDecompile`
  + Rhs typespec SHAPE (`none` / `DANGLING` / `<actual kind>[range]`) + the Lhs
  parameter's typespec shape. `FIELD=<sz|ts|lts|dec|ct|val|kind>` projects the
  payload onto ONE Compare-visible field, so a per-field regression cannot hide
  inside a whole-payload LATERAL.
  Calibrated golden-vs-golden at **0 differing cells** over 365 keys (b01 DEF)
  and 121 keys (b03 ELAB).
* `v106bnd.sh` — the wide boundary, per-FILE and per-DIRECTORY, from a COPY of
  `tools/probe` with no path filter, `.sv` and `.v`, list on fd 3, children
  `</dev/null`, PROCESSED asserted, rc per cell, both views.

## Result of the attack

`VGRID.txt`, `VBOUNDARY.txt`, `VCENSUS.txt`:

* **AWAY_LOST_GOOD = 0** in all 20 arm-view cells, on the whole payload and on
  each of the seven single-field projections.
* Wide boundary: 3337 files × 2 views (LISTED = PROCESSED, `RC_DIFF 0`,
  `ASYM 0`) and 1481 directories × 2 views. 34 per-file movers, **every one a
  parameter arm** of pass 102 / 106 / this verification plus
  `r10earl_repro/h.sv`; all 34 scored three-way against a fresh golden in both
  views with **AWAY_LOST_GOOD = 0** on the whole payload and all seven
  projections. The one directory-level-only mover, `r10uvm88repro`, is
  emitter-NONDETERMINISM (three runs, three hashes, pris == ship inside every
  run). A planted cell in a previously-still file proves the gate can see.
* Real targets: 68 keys to golden, **0 away**; all 16 LATERAL keys opened by
  hand and every one is "Rhs fully at golden, Lhs parameter unchanged"
  (uvm102's R1).
* Whole-dump directional attribution: the ONLY lines the patch **adds** are
  `|vpiSize:-1` and the minted reference's own four lines. Everything else is a
  removal of the ex-actual `int_typespec`s, their ranges and bounds, the
  `vpiActual` edges and the dropped references. Scoreboard/default — the coin —
  is attributed ORDER-BLIND (112 lines, all the law's).

## The fences, re-measured on golden (they are all load-bearing)

* **signed-based literals fenced entirely** — CORRECT and NECESSARY. In
  `a8_toponly.sv`'s DEF listing golden gives `'sh1a` / `'sb101` / `'sd13`
  `vpiSize -1` **with a real `int_typespec`**, and pristine ALREADY matches
  there; applying the typespec half would have turned four right cells into
  DANGLING. In the elaborated copy golden re-sizes them to 32 (and drops the
  `s` from the decompile), which the pass also leaves alone.
* **`'b0/'b1/'B0/'B1`** — CORRECT. Golden's size for them is 0 in the declaring
  package listing (elided by `uhdm-dump`), 2 in an import copy and 1 in the
  elaborated instance — never −1, always a real `int_typespec`. 40 such cells
  measured across `b01`, 0 regressions.
* **typed / ranged declarations** — `b02_decl.sv`'s 23 shapes: 0 AWAY, and the
  typed rows are untouched.
* **a folded default** — `b04`/`b07`: an overridden parameter whose elaborated
  Rhs folded to `4` / `10` / `11` is left exactly where pristine put it.

## Ranked residues found by this verification (all pre-existing; none is a regression)

1. **R-genscope106** — a generate-block localparam (`if` / `for` / `case`) is
   not reached at all. `b03_homes.sv`: in the DEF listing golden's Lhs parameter
   has no typespec and ours does; in the elaborated listing golden has
   `vpiSize -1` + no typespec and ours has 32 + `int_typespec`. 5 cells per view
   in one small arm. This is the largest single family the pass leaves behind
   and it is strictly additive to the pass's own R1-import.
2. **R-decsize106** — the drain's re-read is over-conservative for `'d`. Our
   emitter already renders `parameter R = 'd7` as `7` / `INT:7` /
   `vpiConstType 7` — exactly golden's rendering — so the drain's "still looks
   like an unsized based literal" guard skips it and the size stays 32 where
   golden has −1. This is the NEW head of `b04_over.sv` and `b08v_v2001.v`
   after the patch. The distinguisher has to be recorded at record time (the
   declaration was a decimal-based literal AND was not overridden), because by
   drain time a `'d7` and a folded override are textually identical.
3. **R-class106** (the pass named it) — class parameters bypass `emitParameters`
   entirely: `b03_cls`'s `C_HDR` / `C_BODY` / `C_LOC` keep
   `ref_typespec -> int_typespec` where golden has the dangling reference.
   Confirmed in both views.
4. **R-sgnpkg106** — signed unsized literals in a package's TOP listing: golden
   `vpiSize -1`, ours 32 (3 of the 4 `A_S` cells in `b06_import.sv`). The
   signed fence is right about the ELABORATED copy and about the DEF module
   listing; the package TOP listing is a third case nobody has modelled.
5. **R-ovsize106** (the pass named it) — an overridden untyped parameter's
   elaborated Rhs: golden keeps the override LITERAL (`'h4`, −1, no typespec),
   we fold to `4` / 32 / `int_typespec`. 11 cells in `b07_deep.sv` per view.
   A `localparam LP = P;` that inherits such a value is the same residue seen
   one hop later (`b07_top/m0 LP`: golden −1, ours 32) and is invisible to any
   record predicate keyed on the initialiser's syntax.
6. **R-namedbegin106** — a localparam in a named `initial begin` block:
   golden `'h68` / `vpiSize -1`, ours `104` / `UINT` / `vpiSize 64`
   (`b03_homes.sv`, both views).
7. **R-func106** (the pass named it) — golden is not self-consistent about the
   function-local Rhs reference; the pass takes "none", which moves
   `b03_homes`'s and `a3_homes`'s cell TO golden and leaves
   `r10v102repro/c03_func.sv`'s wrong-differently. Verified as a LATERAL, never
   a regression, in both views.
8. **R0** (the pass's, and the next head) — `@waiter.trigger;` at uvm-1.2
   `src/base/uvm_config_db.svh:294`: the head is golden's `class_var waiter`
   (declared at :273) as LHS with `RHS: <null>`, which is the SINGULAR
   `SafeCompare` shape; `ref_obj::Compare` reads `Actual_group` through exactly
   that call (`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:150`), after
   VpiName / VpiDefName / VpiGeneric all match. 29 cmp lines, both modes.

## Files

`VGATES.txt` (every gate reproduced), `VGRID.txt` (the ten arms × two views),
`VBOUNDARY.txt` (both boundary halves, the positive control, the movers and
their three-way scores), `VCENSUS.txt` (the real-target census and the
order-blind whole-dump attribution), `v106run.sh`, `v106cen.py`, `v106bnd.sh`,
`b01_bases.sv` .. `b10_uvmish.sv`, and copies of `canaries.sh` / `ctcan2.sh` /
`canaudit.sh` so the canary audit runs from this directory too.
