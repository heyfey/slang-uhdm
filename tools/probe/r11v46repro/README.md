# r11v46 — adversarial verification of r11u46 (`§ signedCastSysFuncCall46`)

Base commit `2bbb8fae`.  Everything below was re-measured from scratch in the
verifier's own worktrees (`/tmp/wt_v11u46` = law, `/tmp/wt_v11u46pris` =
pristine), with the verifier's own frozen binaries and its own workdirs.  No
number was carried forward from the implementer's write-up.

## 1. Binaries reproduce bit-for-bit

| binary | md5 | note |
|---|---|---|
| pristine (2bbb8fae, own build) | `d82adeb552c6e4f42b50568702897292` | byte-identical to the main tree's `build/slang-uhdm` |
| law (2bbb8fae + r11u46.patch)  | `6149b15131bcc9665d0c0ad02d6274d4` | the implementer's md5, reproduced |

Both frozen `chmod 555` at `/tmp/v11u46_{pris,law}.bin` before any sweep.
Every `cmds.txt` in all four u2r workdirs (871 each) names the frozen path;
references to the main-tree binary: **0**.

`git apply --check /tmp/r11u46.patch` rc=0 on a FRESH `2bbb8fae` worktree, and
`git diff 2bbb8fae` in the law worktree reproduces the patch line-for-line
(1781 lines) — the patch is exactly the worktree, nothing hidden, nothing
missing.  `results/*.csv`: 0 hunks.

## 2. The head, re-measured (one head per run, `grep -c '^LHS:'` = 1)

`uhdm-cmp <golden.uhdm> <slang.uhdm>` on the verifier's own pristine
databases, all four rows (`genvar_pow_index` and `arb_idx_cast` × both modes):
**rc=255, 37 cmp lines, 1 head each**, and the four heads are the SAME text
blinded of ids/locations/design name (blinded md5 `0610b1953d97`).  Golden's
def-view `gen_for` condition is a two-operand op 20 whose first operand is
`sys_func_call ($unsigned)` → `ref_obj level` → `vpiActual: int_var`; ours
carries only the `ref_obj NumLevels`.  Full text in
`evidence/HEAD.pristine.genvar_pow_index.testflags.cmp`.

**Instrument trap recorded:** `uhdm-cmp` given a NON-EXISTENT LHS path exits
**rc=0 with zero output** — indistinguishable from "equal".  The first
head run in this verification hit it (the cache file is `golden.uhdm`, not
`surelog.uhdm`) and read a false zero on all four rows.  Every `uhdm-cmp`
zero needs a positive control; here the law's `genvar_pow_index` zero is
controlled by the pristine rows' rc=255 on the identical command line.

## 3. The golden grid — SIX grids, 58 cells, 120 golden shape blocks

Three grids are the implementer's (`grid.sv`, `grid2.sv`, `grid3.sv`,
re-generated here against the pinned Surelog v1.87, `-parse -nobuiltin
-nocache -sv -d uhdm`, rc=0 / 0 FATAL / 0 SYNTAX / 0 ERROR).  Three are the
verifier's own (`grid/grid4.sv`, `grid/grid5.sv`, `grid/grid6.sv`; a fourth,
`grid/grid7.sv`, is the INIT-parent micro-probe of §6).  Both of our binaries
run every grid at rc=0, and every grid was also re-run with the corpus's own
`--nobuiltin` flag.

`grid4.sv` covers the positions grids 1–3 do not: a procedural `always_comb`,
a function body, a procedural `for` bound, a cast over a concatenation, NESTED
casts, an instance-array dimension, a typedef packed range, a struct-member
range, an enum member value, a replication count, a module-level continuous
assign, a qualified package parameter at module level, a gen-case ITEM, a
nested gen_for, an unpacked dimension inside a gen-block, a port packed
dimension, and a gen_if `else if` chain.  `grid5.sv` is the corpus shape at
**1, 2 and 3 instances** with a different override per instance, plus an
interface carrying the same loop three times.  `grid6.sv` drives the two
walkers under nesting: a cast argument mixing a genvar with a package
parameter, a DOUBLE cast, `signed'` on both sides, a cast-as-whole-condition,
an OUTER genvar read inside an INNER loop's cast, a gen_for inside a gen_if, a
cast in init AND condition of a decrementing loop, a genvar shadowing a net
name, and the whole cell instantiated once and as a `[2:0]` module array.

Two scorers, both calibrated golden-vs-golden to zero on every grid:

* `gridread.py` (the implementer's) — counts `$signed`/`$unsigned` calls per
  source cell per view.  It is a COUNT lister: it cannot see a wrong shape.
* `vshape.py` (the verifier's) — extracts each call's WHOLE sub-block
  (arguments, binding, spans, parent back-ref), id-blind, and compares the two
  multisets.  This is what catches a right-count/wrong-shape cell.
* `vdiff.py` — order-blind, id-blind whole-dump distance sectioned DEF / ELAB /
  weaklyReferenced TAIL (the tail is judge-unreachable and is not scored).

| grid | cells | pristine wrong | law wrong | law-wrong cells that were ALREADY wrong in pristine |
|---|---|---|---|---|
| grid.sv  | 15 | 13 | **0** | — |
| grid2.sv |  6 |  5 | **0** | — |
| grid3.sv |  6 |  4 | **1** | 1 / 1 |
| grid4.sv | 19 | 11 | **2** | 2 / 2 |
| grid5.sv |  3 |  3 | **0** | — |
| grid6.sv |  9 |  9 | **0** | — |
| total    | 58 | 45 | **3** | **3 / 3** |

**No cell is pristine-right and law-wrong.**  Every law-wrong cell is one
pristine got wrong too, on the bound (elaborated) path this pass does not
touch.

Shape blocks (`vshape.py`), pristine → law, per grid:

* the law is purely ADDITIVE — across all six grids the pristine→law block
  delta is +85 / −1, and the single removed block is `grid.sv:31`'s explicit
  `$unsigned(e)` call, which the law REPLACED with the same call now carrying
  the `vpiActual: int_var` binding golden has (`bindGenvar` learned the
  argument vector).  That is a fix, not a loss.
* golden-only blocks fall 95 → 15; ours-only blocks go 7 → 11.  The four
  ADDED ours-only blocks are the residues V1–V3 of §6 (V1 twice) — every one of
  them in a field no generated `Compare` reads (`VpiParent`, `VpiFullName`, and
  a PARENT object's end span).
* golden writes NOTHING, and the law writes nothing, in exactly two places:
  a loop inside an explicit `generate … endgenerate` region (grid.sv row O —
  the landed placeholder law) and a parameter OVERRIDE actual (grid3 row V).
  **Both landed witnesses stay.**  `int'(f)` is untouched on both sides.
* there is not one EXTRA-OURS cell anywhere in 58 cells: the law never writes a
  call where golden has none.

With the corpus's `--nobuiltin` flag the whole-dump distance to golden falls
`grid.sv` 237 → 79 and `grid6.sv` 199 → 32; the residual lines in grid6 are
unrelated pre-existing families (an imported package parameter we do not
declare, module-array port spans, unconnected-port ref spans) plus the single
V1 line.

## 4. The corpus, re-measured

**uhdm2rtlil, both modes, verifier's own sweeps.**  My PRISTINE sweep
reproduces the committed baselines with **zero differing rows** in both modes
(`diff` against `results/gate_uhdm2rtlil.csv` and the default half of
`results/golden_uhdm2rtlil.csv` is empty).  The LAW sweep differs in **exactly
one row per mode**:

```
< genvar_pow_index,testflags,CMP_NOTEQUAL,decompile:,,
> genvar_pow_index,testflags,CMP_EQUAL,,,match
< genvar_pow_index,default,CMP_NOTEQUAL,decompile:,,
> genvar_pow_index,default,CMP_EQUAL,,,match
```

781/23/67 → **782/22/67 in both modes**.  With the law binary
`genvar_pow_index` reads **0 heads / rc=0** under the official judge in both
modes, and its order-blind whole-dump distance to golden is **zero** — the
only residual lines are `uhdm-dump`'s own banner naming the input file.

`arb_idx_cast` ADVANCES only, as predicted: still 1 head, both modes, but the
head MOVED (cmp lines 37 → 23) onto the elaborated gen-scope localparam fold
(R0 below), and its order-blind distance to golden falls by exactly 13.

**Byte census, u2r (`byteverify.sh`, `SELFCHECK=1` live on every run).**

```
testflags  PATH_SETS_IDENTICAL (804)  MOVERS 2/804  SELFCHECK 803/804
default    PATH_SETS_IDENTICAL (804)  MOVERS 2/804  SELFCHECK 803/804
    arb_idx_cast, genvar_pow_index  — and nothing else, in either mode
```

Both movers were PREDICTED BY NAME before the sweep by the verifier's own
independent a-priori scan (resolve each row's slang command line against the
row's own source dir, grep for `(un)?signed\s*'\s*\(`): **871 rows scanned,
UNRESOLVED-FILES 0, 5 candidates** — `arb_idx_cast`, `cfg_func_width_loop`,
`genvar_pow_index`, `ibex_compressed_decoder`, `static_cast_simple` — which is
the implementer's list exactly.  The three that did NOT move carry their casts
in a function body or a module-level continuous assign, i.e. on the bound path.

The move itself is measured, not asserted: for BOTH movers, in BOTH modes, the
pristine→law order-blind database delta is exactly **+13 lines, 0 removed**,
every line part of the `$unsigned(level)` subtree, DEF view only, ELAB
untouched.  For `arb_idx_cast` the distance to golden falls by exactly 13 for
those 13 added lines, so **all 13 moved TOWARD golden**: MOVED-WRONG 0, AWAY 0.

## 5. Gates

Goldens 23 PASS / 0 FAIL with the law binary, 0 PASS / 23 FAIL with
`SLANG_UHDM=/bin/false`, 23 PASS with the pristine binary.

**Surelog suite, `--mode both`, both binaries, the verifier's own sweeps.**  My
PRISTINE sweep reproduces the committed baseline category for category (474/9
default, 469/8 testflags); my LAW sweep scores the SAME.  Law vs my pristine,
row by row: **two rows differ and both differ only in the workdir path quoted
inside a SURELOG_FAIL detail string** (`LowMemLib`, `LowMemPkg`, testflags).
In particular **`YosysOpenSparc/default` reads `SLANG_REJECT` in my law sweep —
the committed value.  The implementer's one anomalous `SURELOG_FAIL` on that
row does not reproduce**, which confirms their CPU-contention attribution.
Against the committed CSV the law adds only `Earlgrey_0_1`'s blank DUMP column
in both modes, and that reads blank in MY OWN PRISTINE too.

**Surelog byte census: 6 movers / 960, not the implementer's 3 — and all six
are the UVM coin**, attributed, not asserted: `MiniAmiq` ×2, `SeqDriver` ×2,
`SimpleUVM`, `Scoreboard`.  `Scoreboard/default`'s order-blind distance is
**0 lines** (a pure order flip — bytes differ, content identical); the other
five are **exactly 4 lines each**, every line one half of a line-number
attribute (`UINT:<n>` + `vpiDecompile:<n>`).  POSITIVE CONTROL: the PRISTINE
binary ALONE, run three times on `MiniAmiq/default`'s own command line,
produced THREE DIFFERENT databases, none of them the pristine sweep's own —
**four distinct pristine hashes for one fixed binary** — with the identical
4-line signature between them.  REACHABILITY: the whole `third_party/UVM` +
svunit tree contains **zero** signing casts, and a census-zero positive control
(the same scan on `genvar_pow_index`) reports 1.  `rowheads.sh` on the law
workdir reads 0 cmp lines / 0 heads / rc=0 for `SeqDriver`, `SimpleUVM`,
`Scoreboard`, `MiniAmiq`, `BuildUVMPkg` and `Earlgrey_0_1` in both modes.

**Canaries and pins.**  `canaries.sh` surelog law-vs-committed ok=50 changed=2
(the two are `Earlgrey_0_1`'s blank dump column), law-vs-MY-PRISTINE **ok=52
changed=0**; u2r ok=8 changed=0 both ways.  `ctcan2.sh` PASS on both corpora.
`canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0.  Every byte pin the OPS
brief names reproduces in my own sweeps and is byte-identical law-vs-pristine
in BOTH modes: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
InterfaceModPort `59a365f3ce2c`, BlackParrotComplex, YosysOldOr, and
Earlgrey_0_1 (default `8bdf25272e08`, testflags `59d0ee6d10c3`).

MOVED-WRONG 0, AWAY 0.  Full text in `evidence/GATES.r11v46.txt` and
`evidence/CENSUS.uvm-coin.r11v46.txt`.

## 5b. One hygiene fix carried by `/tmp/r11u46.verified.patch`

The four FENCED= row names were never dispatched (`canaudit` FENCE-BREACH=0),
but the implementer's `evidence/GATES.r11u46.txt` SPELLED all four on one line,
which makes the integrator's own §6 fence check read `1 1 1 1` instead of
`0 0 0 0` and stop the landing at its first gate.  The verified patch rewrites
that single line — an evidence-text edit only, no production surface, no
rebuild.  The check then reads `0 0 0 0`.

## 6. Residues the verification adds (all judge-invisible, none a regression)

* **V1 — the `gen_for` INIT RHS parent rule is over-broad, and it is
  PRE-EXISTING.**  `grid7.sv` puts seven init RHS kinds side by side.  Golden
  unparents ONLY a bare literal constant; a `ref_obj`, an `operation`, a folded
  package-parameter constant and a `sys_func_call` all carry
  `vpiParent: assignment`.  Our emitter unparents ALL of them
  (`ModuleEmit.cpp`, `((UHDM::expr*)initRhs9)->VpiParent(nullptr); // SL:
  unparented`): pristine gets 5 of 7 wrong, and the law inherits the rule for
  one further object kind (6 of 7).  Reproduced twice (`grid.sv:41`,
  `grid6.sv:52`).  Correcting it is its OWN pass — it would move every gen_for
  init in the corpus — and it is invisible to the judge, since no generated
  `Compare` reads `VpiParent`.  Evidence: `evidence/INITPARENT.{golden,pristine,law}.txt`.
* **V2 — a cast argument inside a gen-block bit-select index gets the wrong
  synthesized `VpiFullName`** (`grid2.sv:34`: golden `work@grid2.g_t.tnet.t`,
  ours `work@grid2.g_t.t`).  The dump synthesizes the name from the parent
  chain, so this is the known parenting-residue family, not a naming bug.
* **V3 — the def-view `func_call` end span** (`grid3.sv:36`: golden
  `endln:36:39` at the call name, ours `endln:36:53` at the closing paren).
  Pre-existing on the `func_call` arm; the new argument merely exposes it.  The
  same over-spanning appears on the EXPLICIT `$unsigned(x)` system call
  (`grid.sv:31`, `grid7.sv:38`) on both binaries; the SIGNING cast's own span
  is exact.

## 7. Reproducing

```bash
# a grid, both producers, calibration first
cd <grid dir>
surelog -parse -nobuiltin -nocache -sv -d uhdm gridN.sv     # -> slpp_all/surelog.uhdm
$PRIS gridN.sv --single-unit --nobuiltin -o pris.uhdm
$LAW  gridN.sv --single-unit --nobuiltin -o law.uhdm
uhdm-dump slpp_all/surelog.uhdm > g.raw; uhdm-dump law.uhdm > l.raw
python3 vshape.py g.raw g.raw | head -1     # CALIBRATION: golden-only 0 ours-only 0
python3 vshape.py g.raw l.raw               # the shapes
python3 vshape.py p.raw l.raw               # what the LAW changed (golden-only = removed)
python3 vdiff.py  g.raw l.raw               # whole-dump, sectioned DEF/ELAB/TAIL
python3 initparent.py g.raw                 # the gen_for INIT parent rule, by RHS kind
```
