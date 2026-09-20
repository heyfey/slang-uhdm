# r11v67 — ADVERSARIAL VERIFICATION of § `aliasBindSimpleType67` (three laws, one batch)

Base `12c6de50` (matrix-1.87). Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`, the golden producer),
uhdm2rtlil v0.68. Three binaries, each frozen `555` before any sweep:

| binary | md5 |
|---|---|
| pristine (my own worktree build at `12c6de50`) | `40563d03c6a4c68ed7192f6bd5657f5e` — **the OPS pin** |
| the implementer's law, as shipped in `/tmp/r11u67.patch` | `92000bd6492e4dc376c4650aaad1675a` — **reproduced bit-for-bit** |
| the law **plus** this verification's fence | `86ff3c2bde71e08ca72788e0cbb859c1` |

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's
report reproduces, with two arithmetic corrections (§1). The law as shipped
also reads **seven measured golden cells wrong on legal SystemVerilog, four of
them cells our PRISTINE emission already had right** — AWAY-GOLDEN, invisible
to both corpora and therefore invisible to the pass's own census. The fence in
§3 removes all seven and keeps every TO-GOLDEN cell of the shipped law.

---

## 1. WHAT REPRODUCED, AND THE TWO NUMBERS THAT DID NOT

Reproduced bit-for-bit:

* pristine md5 = the OPS pin `40563d03c6a4c68ed7192f6bd5657f5e`; the law
  rebuilt from `/tmp/r11u67.patch` on a FRESH `12c6de50` worktree =
  `92000bd6492e4dc376c4650aaad1675a`, the reported md5;
* the four target cells at the base, golden / pristine: v2 `wnod` 36/0, v8
  `d15` 36/0, va `m9.wd` + `m10.wd` 36/0 (LAW A); v8 `d16` 0/36 (LAW B); v4
  `ifa.gw` 36/1 and `ifa.gd` 36/2 (LAW C);
* the implementer's own five-arm grid on MY binaries, cell for cell:
  g1 8 / g2 4 / g3 8 / g4 0 / g5 0 **TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG**;
* the `r11v65repro` control grid on MY binaries, cell for cell identical to
  the shipped `evidence/GRID.v65control.score.txt`, including the eight
  pass-64 decline cells (`v8` d05/d06/d08–d12, `v9` m1–m4/m7–m8, `va`
  m9–m13 `x`) at golden 0 / pristine 0 / law 0;
* u2r **787 / 17 / 67 in both modes**, every row byte-identical to
  `results/golden_uhdm2rtlil.csv` and `results/gate_uhdm2rtlil.csv`;
* `byteverify SELFCHECK=1` on uhdm2rtlil: **MOVERS 0 / 1608**, selfcheck
  1607/1608 — the corpus really is untouched on this face;
* goldens 23/0 with the law and 0/23 under `SLANG_UHDM=/bin/false`;
* every `cmds.txt` audited BY BINARY PATH: u2r 1742 per side and surelog
  1581 per side name only the frozen `/tmp/v11u67_{pris,law}.bin`.

**Correction 1 — the control-grid score is 7, not 9.** The shipped
`evidence/GRID.v65control.score.txt` sums to `v2` 1 + `v4` 2 + `v8` 2 + `va` 2
= **7 TO-GOLDEN**, and the seven named cells in the README's own prose are
exactly those seven. My re-run of the same grid on my own binaries produces
that file line for line. The README's "TO-GOLDEN 9" is an arithmetic slip.

**Correction 2 — the batch total is 27, not 29.** 20 (the g-grid, which does
sum to 20) + 7. AWAY-GOLDEN 0 and MOVED-WRONG 0 are unaffected.

---

## 2. WHAT BROKE — THE `$unit` SCOPED-TARGET TYPEDEF IS BOUND, AND THE WALK IS NOT TWO LEVELS

`aliasHomeNeverRebound67` declares every `Package`- or `CompilationUnit`-homed
typedef-over-a-name a permanent `DummyType`, and `aliasBind67` stops after two
hops. Both are refuted by real v1.87 goldens.

Fifteen verifier arms, one file each, `surelog -parse -nobuiltin -nocache -sv`
**rc=0 and 0 `[ERR` on every dispatched arm**, both our binaries rc=0 —
`evidence/ARMS.rc.txt`.

### (a) `wb_scoped` — a typedef written over a SCOPED name, by home

| cell | declaration | home of the typedef | golden | pristine | shipped law |
|---|---|---|---|---|---|
| y01 | `uq_t y01;`  (`typedef pk::cv_t uq_t;`) | `$unit` | **36** | **36** | **0 AWAY** |
| y02 | `wire uq_t y02;` | `$unit` | **36** | **36** | **1 AWAY** |
| y03 | `uqr_t y03;` (`typedef pk::cr_t uqr_t;`) | `$unit` | **48** | **48** | **0 AWAY** |
| y04 | `wire uqr_t y04;` | `$unit` | **48** | 36 | **1 MOVED-WRONG** |
| y09/y10 | `uqd_t` (`typedef pk::cv_t [1:0] uqd_t;`) | `$unit` | 36 | 0 | 0 |
| y05 | `uq2_t y05;` (over `pk::cv2_t`, itself a dummy) | `$unit` | 0 | 36 | 0 |
| y07 | `uqw_t y07;` (over `pk::cw_t`, itself a dummy) | `$unit` | 0 | 36 | 0 |
| y20/y22/y24 | `pb::bq_t` etc., the PACKAGE-homed scoped twin | package | **0** | 36/48 | 0 |
| d17 (`w4_depth`) | `ub_t` (`typedef ua_t ub_t;`), unqualified twin | `$unit` | **0** | 36 | 0 |

`y01` against `d17` is the decisive pair: the same home, the same shape, and
the answer decided by whether the name the typedef was written over is
SCOPED. `y01` against `y20` is the second: the same written form, the answer
decided by the home. `y05`/`y07` show the chain still matters — a `$unit`
typedef over a scoped name that is ITSELF a dummy stays 0.

### (b) `wd_locunit` — a MODULE-LOCAL typedef one hop above that

| cell | declaration | golden | pristine | shipped law |
|---|---|---|---|---|
| c01 | `m1_t c01;` (`typedef uq_t m1_t;`, `uq_t` = `typedef pk::cv_t uq_t;`) | **36** | **36** | **0 AWAY** |
| c02 | `wire m1_t c02;` | **36** | **36** | **1 AWAY** |
| c03 | `m2_t c03;` (the `reg` twin) | **48** | **48** | **0 AWAY** |
| c04 | `wire m2_t c04;` | **48** | 36 | **1 MOVED-WRONG** |
| c05/c06 | `m3_t` over a `$unit` SimpleType | 36 | 36 | 36 |
| c07/c08 | `m4_t` over the UNQUALIFIED `$unit` alias `ub_t` | 0 / 1 | 36 / 36 | **0 / 1** |

`c07` is the control the fence must not break: the same module-local shape,
the same `$unit` home one level down, and golden 0 because that alias's own
target was unqualified.

### (c) `wc3` — the same defect on the interface road (LAW C)

`wire uq_t s01` / `wire uqr_t s03` in an INSTANTIATED interface read golden
**36** / **48**; pristine 1 / 1; the shipped law leaves both at 1 (STILL-WRONG
rather than AWAY, because pristine was wrong there too). The interface-homed
twin `wire iq_t s04` (`typedef pk::cv_t iq_t;` inside the interface) is a
TO-GOLDEN the shipped law already wins, 1 → 36.

---

## 3. THE FENCE

`src/EmitHelpers.h`, two edits inside the shipped § `aliasBindSimpleType67`:

1. `aliasHomeNeverRebound67` keeps `Package` as a permanent dummy home, and
   keeps `$unit` as one **only when the name the typedef was written over is
   unqualified**. A `$unit` typedef over a `pkg::T` is bound like a
   module-local one. The `arrays03` witness (`typedef reg8_t [0:3]
   reg2dim1_t;` at `$unit`) is unqualified and keeps the shipped answer.
2. `aliasBind67`'s two-level unroll becomes a WALK. Each hop: a target that is
   not an alias answers that alias's base keyword; a never-rebound home
   answers `Dummy`; otherwise the walk steps to the target. The shipped law's
   ORDER guard is kept exactly where it was — when the next alias lives in the
   SAME scope and is itself written over a name, which `DataType` was bound
   depends on the name-sorted `bindTypedefs_` order, so the walk answers
   `Unknown` and leaves the shape to the landed code (R-ORDER). The walk can
   therefore cross a scope boundary but never a same-scope dummy.

Nothing else in the patch is touched. `ModuleEmit.cpp` is unchanged from the
implementer's version; the module def road, the interface def road and the
port-view bare net all read the corrected helper.

---

## 4. THE SCORE, WITH THE FENCE

Three grids, 35 arms, scored by net identity (view × scope × name × net kind)
against each arm's own golden — `evidence/GRID.fence.score.txt` against
`evidence/GRID.shipped.score.txt`:

| grid | shipped law | with the fence |
|---|---|---|
| my 20 arms (`grid/`) | TO-GOLDEN 69, **AWAY 8, MOVED-WRONG 2** | **TO-GOLDEN 77, AWAY 0, MOVED-WRONG 0** |
| the implementer's 5 (`r11u67repro/grid`) | 20 / 0 / 0 | **20 / 0 / 0** |
| the pass-64 control (`r11v65repro/grid`) | 7 / 0 / 0 | **7 / 0 / 0** |
| **total** | 96 / 8 / 2 | **104 / 0 / 0** |

The fence keeps every TO-GOLDEN cell of the shipped law, removes all ten
regressions, and adds eight cells the shipped law left STILL-WRONG:
`wb` y09/y10 (`typedef pk::cv_t [1:0] uqd_t;` at `$unit`, 0 → 36),
`wc2` z03/z04 (the same shape alone in its own file),
`wc3` s01/s03 (`wire uq_t` / `wire uqr_t` in an INSTANTIATED interface,
1 → 36 / 48), and `wd` c02/c04 beyond the AWAY repair.

Arms that could NOT be dispatched, each recorded rather than scored:
`w9a`, `w9_homescalar`, `wc1`, `wc_scoped2`, `we_order3` — **Surelog v1.87
SEGFAULTS (rc=139)** on a generate block that declares a net through a local
typedef, on `typedef pk::cv_t uq_t; typedef uq_t uq3_t;` at `$unit`, and on a
three-deep local chain whose names sort against the bind order. Both our
binaries return rc=0 on all five. `v7_decl` keeps its documented rc=4 fence.

Blast-radius controls that did NOT move, on either binary: type parameters in
every written form (`w8_tparam`, 0 moved cells), generate-scope nets (`w9c`),
the rare net keywords `supply0` / `supply1` / `tri0` / `tri1` / `triand` /
`trior` / `uwire` over a vector typedef (`w1` k30–k38, golden 36 = pristine 36
= fence 36 in the def view), and the explicitly SCOPED declaration
`wire pk::cv_t k24` (golden 0, both binaries 1 — pre-existing).

---

## 5. RE-RUNNING

```bash
bash vrun65.sh <binary> pris          # golden + a binary per arm, BOTH rcs
bash vrun65.sh <other-binary> law
bash vscore65.sh                      # golden vs pris vs law, per net identity
python3 cells.py grid/<arm> pris law   # one line per net, all three sides
python3 nettype65.py <a-uhdm-dump>     # the SHAPE LISTER (from r11v65repro)
```

`GRID=<dir>` selects the arm set; the three control grids are
`tools/probe/r11v65repro/grid` (pass 64), `tools/probe/r11u67repro/grid` (the
implementer's) and this directory's `grid`.

---

## 6. RESIDUES THIS VERIFICATION ADDS, RANKED

1. **R-V67-FENCE64** — the pass-64 element-reach fence OVER-DECLINES when the
   element alias is PACKAGE-homed but the typedef carrying it is
   module-local: `typedef pk::cv_t [1:0] mw_t; mw_t g16 [2];` reads golden
   **36**, ours 0 (`w7_guard` g16). The `aliasBind67` walk already answers 36
   for the dimension-LESS twin (`mw_t g02`, a TO-GOLDEN of this batch); the
   unpacked road is still on the empirical fence. Ranked first because the
   decoded bind rule now supplies the fence pass 64 had to guess.
2. **R-V67-SCOPEDNET** — a written `pkg::T` DECLARATION keeps our net keyword
   where golden stamps nothing: `wire pk::cv_t k24` golden 0, both binaries 1
   (`w1_pkgkw` k24). Pre-existing, one line from `netTypeFor`'s scoped arm.
3. **R-V67-ELABKW** — the ELAB view of a rare net keyword over a vector
   typedef: `supply0/supply1/tri0/tri1/triand/trior/uwire <tdef> x` read
   golden 11/10/5/6/8/9/13 and ours 36 in the ELABORATED view (`w1` k30–k38,
   `w2` n14–n16). Nine measured cells, pre-existing, and the def view is
   already right on all of them.
4. **R-V67-ELABPORT** — an ANSI port with a net keyword over a vector typedef
   reads golden 36 in the ELAB view and ours 1 (`w5_port` p04/p05/p08/p22/p23,
   five cells). The DEF view is a TO-GOLDEN of this batch; the elaborated road
   does not consult the def-view arm.
5. **R-V67-SLCRASH** — Surelog v1.87 SEGFAULTS (rc=139) on three shapes this
   face needs to characterize: a generate block declaring a net through a
   local typedef, `typedef pk::cv_t uq_t; typedef uq_t uq3_t;` at `$unit`, and
   a three-deep local chain whose names sort against the bind order. Our
   binaries return rc=0 on all three, so those cells have NO ORACLE — the
   `Unknown` answer the ORDER guard gives them is the safe reading, and the
   walk keeps it.
6. The implementer's own residues stand as written: R-KWDUMMY (`wire pw_t` /
   `wire uw_t` / `wand pw_t`, golden 1/1/2, ours 0, re-measured here as
   `w7_guard` g13/g14), R-ORDER, R1 (r10v225, `ifu.q05` golden 0 ours 36,
   re-measured here as `w2_ifacekw`), R-V2.

**R0 for the next pass on this face: R-V67-FENCE64** — one measured cell, the
rule already decoded, and the dimension-less twin already landed.
