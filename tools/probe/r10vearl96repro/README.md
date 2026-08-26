# r10vearl96 — the adversarial verification of r10earl96

**VERDICT: ACCEPT WITH FIX.**  The pass's head, model and every headline number
reproduce bit for bit on independently built binaries.  One purpose-built arm
convicts the law of over-applying: the arm it guards has **two** triggers and
golden treats them differently.  The shipped patch takes the clone-flavoured
bare alias target on BOTH, which turns a cell that was RIGHT on pristine WRONG
on a legal SystemVerilog shape.  The fix is one expression; it keeps every gain
the pass measured, costs the head nothing, and leaves both corpora
byte-identical to the as-shipped binary.

BASE `a8876a8`, branch `auto5h`.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; everything
in this directory is MEASUREMENT ONLY.

---

## 1. What reproduced

Built from scratch in two fresh worktrees at `a8876a8`, `-j 2`, md5 taken
separately, both frozen `chmod 555`:

| binary | md5 | implementer reported |
|---|---|---|
| pristine | `3b10fa70b3a173555c65691389636d01` | `3b10fa70b3a1` ✔ |
| as-shipped | `786defd3edcb54ee1561cc03b0e9c206` | `786defd3edcb` ✔ |

Everything below was then re-measured, never carried forward:

* the head — `Earlgrey_0_1` both modes, ONE head each, ONE shared object;
  `rowheads` 112/112 pristine → **31 default / 54 testflags** patched, 1 head
  each, every other row family unmoved.
* the head DECODE, read out of the generated Compare and the writer, not from
  the pass: `typespec::Compare` reads `VpiName` first (line 88 of
  `~/git-repos/UHDM/build/generated/src/typespec.cpp`), then `Typedef_alias`
  (93), then `Instance` (94); `UhdmWriter::writeDataTypes`
  (`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:775`, the qualifier at
  :790‑794) prefixes `pkg::` IN PLACE on the shared object and ONLY under
  `if (parent->UhdmType() == uhdmpackage)`.  Both confirmed.
* the two R0 heads, read off the patched databases: default is an `LHS: <null>`
  against a surplus `logic_var fifo_wptr` in gen_scope
  `…u_msg_fifo.gen_normal_fifo` (hmac.sv:58); testflags is an `int_typespec` at
  `prim_packer.sv:31` where golden carries `vpiSigned:1` and we carry none.
* the grids: g1 30→26, g2 10→0, g3 8→4, g4 10→0, g5 11→7, both views, one-sided
  sets byte-identical.
* the gates: goldens 23/0 (0/23 on `/bin/false`), u2r 679/50/2 both modes,
  surelog 471/466 equal and 10/9 NE, `ct8rows` PASS everywhere, byteverify
  u2r 0/1358 and surelog 2/956 (both Earlgrey, SELFCHECK 1357/1358 and
  955/956), canaries 52/8 changed=0, ctcan2 PASS ×2, canaudit
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`, all five byte pins.
* the corpus census, re-run three-sided (golden / pristine / candidate) over
  EVERY database of both corpora: surelog **RIGHT→WRONG 0, WRONG→RIGHT 32**
  (16 in each Earlgrey mode and nothing else in 956 databases); uhdm2rtlil
  **0 / 0 over 1358**.

`GATES.r10vearl96.txt` carries the raw numbers.

---

## 2. What broke — § the concat half of the arm

The guarded site (`ParamEmit.cpp` ~13124) is entered on **two** conditions:

```cpp
if (unpackedArrayTs9 || unpArrConcatTs9) { … }
```

`unpackedArrayTs9` is an **assignment pattern** (`vpiAssignmentPatternOp` /
`vpiMultiAssignmentPatternOp`); `unpArrConcatTs9` is a **concatenation**
(`vpiConcatOp`).  They are mutually exclusive — a UHDM operation has one
`VpiOpType` — and each already carries `!inPackage` in its own definition
(`ParamEmit.cpp:12874` and `:12984`).  So the shipped condition

```cpp
importedParamElemClone16 = !inPackage;      // as shipped
```

is a **tautology at this site**: `!inPackage` cannot be false here.  The law is
"always", and the guard the pass's comment defends ("a PACKAGE view is
excluded") was never doing any work.

`v7_concat96.sv` puts the two shapes side by side in one module, one imported
typedef, one span.  Golden's elaborated instances read:

| position | init | golden alias target |
|---|---|---|
| `pa[WPAT].rhs>r>e>r` (module's own, wildcard import) | `'{…}` | `x_t -> x_t` **bare** |
| `pa[WCAT].rhs>r>e>r` (module's own, wildcard import) | `{…}` | `x_t -> p7x96::x_t` **QUALIFIED** |
| `pa[EPAT].rhs>r>e>r` (module's own, explicit import) | `'{…}` | `x_t -> x_t` bare |
| `pa[ECAT].rhs>r>e>r` (module's own, explicit import) | `{…}` | `x_t -> p7x96::x_t` **QUALIFIED** |
| `pa[PKGPAT].rhs>r>e>r` (materialized import copy) | `'{…}` | `x_t -> x_t` bare |
| `pa[PKGCAT].rhs>r>e>r` (materialized import copy) | `{…}` | `x_t -> x_t` bare |

**The pattern half does not split on the import; the concat half does** — the
concat half obeys exactly the rule the Lhs already obeys
(`§ importElemBareTdAlias`: the clone copy only on a MATERIALIZED IMPORT row).
The as-shipped patch hands the bare copy to `WCAT`/`ECAT` too, and those two
cells were RIGHT on pristine.

Reproduced on three independent arms and both views:

* `v5_kinds96` — `localparam v_t LCAT [2] = { 32'h31, 32'h32 };`
  RIGHT→WRONG **2**;
* `v7_concat96` — the grid above, RIGHT→WRONG **4**;
* `v8_ops96` — the same shape inside an **interface** (`ICAT`) and a
  **submodule** (`SCAT`), RIGHT→WRONG **4**;
* `v9_catmat96` — an interface, a leaf module and the middle of a three-deep
  chain, each declaring its own concat parameter beside a materialized import
  of the package's, RIGHT→WRONG **6** (and MOVED-WRONG 12→0 with the fix).

All sixteen rows — eight distinct cells per view — are `pristine == golden`,
`as-shipped != golden`.  They are
invisible to every corpus gate: the as-shipped and the fixed binary produce
**byte-identical databases over all 2314 databases of both corpora**
(byteverify MOVERS 0/956 and 0/1358 between them).

---

## 3. The fix

```cpp
bool savedIpc96 = importedParamElemClone16;
importedParamElemClone16 = unpackedArrayTs9 || (isImported && !inPackage);
```

`unpackedArrayTs9` is the pattern arm — unconditional, exactly what the pass
measured on `g5_neg96`'s `LOCARR`/`PKGARR` rows.  `isImported && !inPackage` is
the concat arm — the same predicate `§ importElemBareTdAlias` uses one screen
up (`ParamEmit.cpp:4897`), and `isImported` is already in scope at this site
(`structRefSubstOp9`, ~:13037, reads it).  Nothing else changes: no new object,
no new spelling, no parenting change.

Result, every arm and both views: **RIGHT→WRONG 0** and the WRONG→RIGHT count
UNCHANGED from the as-shipped patch on every arm — the fix is strictly
dominant.  `v5` 65→**49** (as-shipped 51), `v7` 17→**9** (13), `v8` 14→**2**
(6), everything else identical.

---

## 4. Boundaries

`vwide2_96.sh` runs the wide boundary with **two** instruments, because the
pass itself noted that `uhdm-dump` ABBREVIATES an already-visited typespec, so
an alias TARGET's name is invisible in a dump diff while `typespec::Compare`
reads it.  Over every `.sv`/`.v` under `tools/probe` at any depth, both views,
list on fd 3, children `</dev/null`:

```
PROCESSED=4333 (= LISTED)
dump_identical 8306   dump_DIFFERING  8   no_output 352
cen_identical  8286   cen_DIFFERING  28
rc symmetric side for side:  0 7951/7951   3 338/338   4 363/363   139 14/14
```

The 8 dump-differing view-cells are g1, g2, `r10earl_repro/te.sv` and
`v1_names96`.  The 28 census-differing ones are the five pass arms, `te.sv` and
the eight verifier arms — **every one a purpose-built arm of this law's
family**, and ten of the fourteen files show up ONLY in the census column.
Nothing outside the law's population differs anywhere in the probe tree.

`te.sv` (the arm r10earl16 built for the sibling law) goes MOVED-WRONG 5→1 in
both views with both one-sided sets unchanged and RIGHT→WRONG 0.

---

## 5. Reproducing

```
g++ -O2 -std=c++17 <ct96cen|pa96|ts96>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <name>
```

* `arm96.sh <arm.sv> <outdir>` (env `PRISTINE_BIN PATCHED_BIN CEN96`) — build
  the golden and both sides, run the official `uhdm-cmp` per side, census both.
* `reg96.py <golden.cen> <pris.cen> <cand.cen>` — the per-KEY multiset
  intersection with golden, pristine vs candidate.  This is the instrument that
  names a RIGHT→WRONG; a bucket total can hide one behind a gain.
* `vcen3_96.sh <pristine-workdir> <candidate-workdir> <out-prefix>`
  (env `CEN96 REG96`) — the same join over every database of a sweep.
* `vwide2_96.sh <filelist> <out-prefix>` (env `PATCHED_BIN PRISTINE_BIN
  PROBE_ROOT CEN96`) — the two-instrument wide boundary.
