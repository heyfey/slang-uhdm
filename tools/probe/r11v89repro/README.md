# r11v89 — adversarial verification of r11u89 (three faces of the module route's store)

**VERDICT: ACCEPT.  Every headline number reproduces bit-for-bit on binaries
this verifier built itself; seven new adversarial arms on real Surelog v1.87
goldens score `AWAY=0 MOVED-WRONG=0`; each of the three laws is droppable
alone, proved with three independently built binaries.**

Base `55af075f`, pins per `SUPPORT_MATRIX.md`.  Worktrees `/tmp/wt_v11u89`
(patched) and `/tmp/wt_v11u89pris` (pristine), binaries frozen `chmod 555`.

| binary | md5 | note |
|---|---|---|
| pristine | `9096140bb63d1d277f5b060b2f5a5b58` | the value the ops brief pins |
| law (fresh worktree + the deliverable patch) | `422938349d8030e68b7704e2faf448a5` | `ParamEmit.cpp` is `__LINE__`-sensitive; this is the check, not an assumption |
| pad control (pristine + `volatile char v89pad[16384]`, no law code) | `c4a484192327925526aab67766dc81a9` | the page-class positive control |

## 1. The producer, re-read at the pin

Every line r11u89 cites was checked against the pinned sources, and the two
that carry LAW A were the ones worth checking:

* `DesignElaboration.cpp:2576-2587` is as quoted — `value->setTypespec(cts ? cts : ts)`
  and `valueRange(value, ts, cts ? cts : ts, …)`, with the `:2562` fill-in
  `if (c->Typespec() == nullptr) c->Typespec(ref(ts))` ahead of it.
* `CompileHelper.cpp:5548-5583` takes `isSigned` off the **third** argument and
  ends `val->setSigned(isSigned)`.
* `CompileExpression.cpp:3032-3040` hangs the bare signed `int_typespec` under
  **`if (sval->isSigned())`** — i.e. on the INNER store's own signedness, which
  is exactly the predicate the new recursion computes.  The landed §-block's
  looser phrase ("the mint always makes a bare `int_typespec`") is what would
  have made the law wrong; the guarded source is what makes it right.
* slang `ParameterBuilder.cpp:249` adds `InitializerOverridden` for the
  hierarchy/config initializer only, and the `overrideNode` arm at `:281-292`
  is reached AFTER that, so `isOverridden()` is FALSE for a defparam and for a
  `-G` override alike.  LAW C's defparam fence is structural, as claimed.

## 2. The seven adversarial arms (real Surelog v1.87, `slrc=0 ourrc=0 slerr=0`)

| arm | what it attacks | score |
|---|---|---|
| `x1_ifgen89` | the OTHER two homes `red87HopHomeIsInstance87` accepts — an INTERFACE body, an `if` generate block and a `for` generate block, LAW A and LAW B in each | `TO=15 AWAY=0` |
| `x2_wide89` | LAW B's VALUE edges: 2^63-1, 2^63, 2^64-1, 2^64, a 66-bit octal, a 66-bit zero, and a wide PORT parameter overridden and defaulted | `TO=34 AWAY=0 STILL=8` |
| `x3_ovred89` | LAW C's shapes w5 has not: an override inside a GENERATE block, an INTERFACE's port parameter, a `'h` override wider than the word, a zero, an unsized `0` | `TO=35 AWAY=0` |
| `x4_chned89` | LAW A's chain edges: an inner initialised by an OPERATION, by `$clog2`, by a PACKAGE hop, and an eleven-deep chain across the `depth89 < 8` cap | `TO=14 AWAY=0 WRONG2=2` |
| `x5_pkgchn89` | census89's WID89 blind spot: a MODULE-homed hop whose digits arrive from a PACKAGE-homed 96-bit literal | `TO=14 AWAY=0` |
| `x6_widecast89` | LAW B through `signed'`/`$signed`/`$unsigned`, which `red86HopName86` reads through, on hops wider than the word | `TO=4 AWAY=0 WRONG2=6` |
| `x7_outkind89` | LAW A's recursion returns before the OUTER's kind is read: `byte`, `shortint`, `integer`, `longint`, an implicit declaration carrying only a dimension, a typedef of an UNSIGNED vector | `TO=12 AWAY=0` |

**The whole 54-arm grid (r11u89's 47 + these seven), scored per cell on all
five fields: `TO=273 AWAY=0 STILL=207 WRONG2=10 EQ=844 SHAPE=9 MWRONG=0 UNPAIR=17`.**
The 47-arm subset is byte-identical to the committed `GRID89.score`, TOTAL line
included.

**The scorer's own positive control, per arm** (`SWAPCTL89v.score`): swapping the
two tags turns every TO into AWAY **and** MOVED-WRONG on all ten arms that
move — `w3 24`, `w5 42`, `w9 42`, `x1 15`, `x2 34`, `x3 35`, `x4 16`, `x5 14`,
`x6 10`, `x7 12`.  `AWAY=0` is a measurement on every one of them.

**What the arms taught, beyond confirming the three laws.**

* The signedness really is read off the RHS: six OUTER declared kinds that
  `valueRange`'s own LHS switch does not name — including `byte`, `longint` and
  a typedef of an UNSIGNED vector — are all golden `/S` through a signed chain,
  and the law reaches every one (`x7`).
* LAW B's refusal boundary coincides with golden's own overflow: at 2^63, at
  2^64-1, at 2^64 and on a 66-bit octal, golden's `parseInt64` fails and it
  writes `INT:0` / `UINT:0` with the digits LOST, while the law refuses the leaf
  and keeps `DEC:`/`OCT:` (`x2`).  Eight STILL cells, no AWAY — r11u89's R2
  measured at four more points.
* The home gate generalises: an interface body and both generate-block forms
  take the module road, and so does a hop whose digits came from a package
  (`x1`, `x5`).

## 3. The three laws are droppable alone (`DROPONE89v.score`)

Three further binaries were built from the patch with exactly one law reverted:

| binary | `w3` (LAW A) | `w9` (LAW B) | `w5` (LAW C) |
|---|---|---|---|
| full patch | TO=24 | TO=42 | TO=42 |
| LAW A reverted | **TO=0** | TO=42 | TO=42 |
| LAW B reverted | TO=24 | **TO=0** | TO=42 |
| LAW C reverted | TO=24 | TO=42 | **TO=0** |

`AWAY=0` and `MWRONG=0` in every cell of every row.  The laws are disjoint by
construction as well as by measurement: LAW A fires only on a NOT-overridden
hop and LAW C only on an overridden one, so LAW A's typespec write can never
close LAW C's `c87->Typespec()` gate.

## 4. The gates, re-run

1. **Build** `-j 2`, md5 separately, both frozen.  Pristine md5 equals the
   ops-pinned `9096140bb63d…`; the deliverable patch on a FRESH `55af075f`
   worktree links to `422938349d80…` byte for byte.
2. **Goldens** 23 PASS / 0 FAIL on the law binary; `SLANG_UHDM=/bin/false`
   gives 0 PASS / 23 FAIL.
3. **uhdm2rtlil** `788 / 16 / 67` on each of four sweeps; the 1742-row both-mode
   join against `results/golden_uhdm2rtlil.csv` is `DIFF=0` on BOTH binaries;
   the testflags gate reads `PASS: every row byte-identical`.
4. **Surelog `--mode both`, both binaries** `474/9` + `469/8`; the per-mode
   STATUS histogram is identical baseline → fresh; four rows differ and the
   PRISTINE sweep draws the SAME four (`Earlgrey_0_1` ×2 dump column, status
   `CMP_EQUAL` and the database md5 unmoved; `LowMemLib`/`LowMemPkg` testflags
   `SURELOG_FAIL` with the workdir path inside the detail string).  A
   `uhdm-dump` of `YosysOpenSparc` held a core for minutes beside this sweep
   too — the documented draw, reproduced on both sides.
5. **byteverify**, both corpora in one workdir pair (`pris`/`lawv`):
   `PATH_SETS_IDENTICAL (2568)`, `MOVERS 4 / 2568`, `SELFCHECK 2567/2568`.  All
   four are the UVM coin (`MiniAmiq` ×2, `SeqDriver`, `Scoreboard`), attributed
   ORDER-BLIND on path-normalised sorted dumps: each moves at most ONE
   `UINT`/`vpiDecompile` pair holding a line number (`1496↔1518`, `0↔1470`,
   `1097↔1453`) and `Scoreboard`/default moves zero; **0 `vpiSize`, 0
   `Typespec`, 0 `vpiConstType` lines in any of them**.  r11u89 drew SIX movers
   with different numbers — which is what a coin does.  COIN CONTROL: the
   PRISTINE binary alone, five runs of MiniAmiq's own invocation in one
   directory, gives five distinct databases (`4caf15285de1`, `e0fdf487a388`,
   `bd29a56aeeb0`, `8826fb229240`, `a540f4ae8eb6`).
6. **Canaries** surelog `ok=50 changed=2` (the two `Earlgrey_0_1` dump-column
   cells, the same two on pristine), u2r `ok=8 changed=0`; `ctcan2` PASS on both
   corpora; `canaudit` PASS `audited=29 UNCOVERED=0 FENCE-BREACH=0`.  Every
   protected database at its pin on the LAW binary: SVSwitch `4842211c4030`,
   YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1
   `8bdf25272e08`/`59d0ee6d10c3`, BlackParrotComplex `e3e354129d5a`/`73a10e8217e5`,
   YosysOldOr `d68e0796d62c` both modes.
7. **Conversion rows** BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
   ParamOverloading, Earlgrey_0_1 — `measured=13 SKIP-NOFILE=1 UNKNOWN-NAME=0`,
   every measured row `0` cmp lines / `0` heads.
8. **Census** over the three pinned corpora reproduces r11u89's file EXACTLY
   (`AGREE89 15154  OVR89 17  SGN87 4  UNR87 270`, `CHN89 0`, `WID89 0`), and
   `--selftest` PASSes.  The classifier also sights every moving cell of all
   seven verifier arms, interface and generate homes included.  All five
   a-priori names are `SURELOG_FAIL` / `DEFERRED` / `SLANG_REJECT` in both modes
   and produce ZERO databases — the empty mover prediction stands.
9. **Wide boundary**, every `*.sv` under `tools/probe` of the patched tree:
   `arms=7993 SAME=7769 DIFFERS=12 NODB=212`, `NODB` with `prc != lrc` = 0
   (208 × rc=3, 4 × rc=139) — identical to r11u89's, the twelve names included.
   On all nine pass cells every REMOVED line is a `vpiSize`, a `vpiConstType`,
   a `vpiDecompile` or a value line; `UNEXPLAINED-REMOVALS=0`, everything else
   ADD-only.  The three page-class arms move an address-derived `UINT` by
   exactly 4096; the 16 KB pad control moves the same three by exactly 16384
   with NO law code.
10. `results/*.csv` untouched, `ModuleEmit.cpp` untouched, the four fenced
    names appear 0 times in the patch and no test of theirs was dispatched.

## 5. Residues this verification adds

* **RV89-1 — LAW A's cap and the landed const-type readers' cap are one apart.**
  At chain depth 9 (`x4` `H8`) the recursion still fires while our own
  const-type walk has already stopped, so the cell reaches golden's typespec
  and keeps a `UINT:` where golden writes `INT:` — the pass's only new
  half-golden class, two cells, corpus-invisible.  At depth 10+ the law
  declines outright.  Pristine is wrong on those cells too: nothing moved away.
* **RV89-2 — R4 now extends past the word boundary.**  `signed'(YW)` over a
  96-bit hop is golden `96@7 INT:12` with a `logic_typespec/S`; LAW B takes the
  `ct`/`v`/`d` triple to golden and leaves the typespec, exactly as the landed
  narrow-cast face already does (`x6`, six cells).  The two halves must move
  together and they are r11u81's ground, not this pass's.
* **RV89-3 — census89's `WID89` does not sight a package-fed chain.**  The
  classifier asks `not inpkg` at the LITERAL, while LAW B's gate reads the
  IMMEDIATE hop's home, so `module: X = pkg::PW96` is invisible to the census
  and visible to the law (`x5`).  Golden agrees with the law there, so the hole
  hides a TO and not a regression — but the a-priori mover set is not a strict
  superset on that axis, and byteverify is what covers it.
* **RV89-4 — one landed comment is now stale.**  `src/ParamEmit.cpp:16533`
  still reads "past 64 bits there is no simple Value and the clone answers, so
  the law stops at the word boundary".  Both cells it cites (`m5_bnd86` op5/op6)
  are PACKAGE-homed, so its measurements stand, but the generalisation is what
  LAW B replaced.  A one-line edit at landing; nothing executable depends on it.

## 6. Reproducing

```bash
git worktree add /tmp/wt_v11u89pris 55af075f
git worktree add /tmp/wt_v11u89     55af075f && (cd /tmp/wt_v11u89 && git apply -3 /tmp/r11u89.patch)
for d in /tmp/wt_v11u89pris /tmp/wt_v11u89; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
    -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done
G=/tmp/v11u89_g && mkdir -p $G/grid && R=/tmp/wt_v11u89/tools/probe
cp $R/r11u86repro/run66.sh $R/r11u87repro/{ts87probe.cpp,score87v.py,join87.py} $G/
cp $R/r11v89repro/grid/*.sv $R/r11u89repro/grid/*.sv $R/r11u87repro/grid/*.sv \
   $R/r11u86repro/grid/*.sv $R/r11v86repro/grid/*.sv $R/r11u81repro/grid/*.sv \
   $R/r11v81repro/grid/*.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts87probe.cpp -o ts87probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/\.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wt_v11u89pris/build/slang-uhdm   # SAME-LENGTH
  bash $G/run66.sh $G/grid/$a.sv lawv /tmp/wt_v11u89/build/slang-uhdm       # TAGS
done                                   # every arm must read slrc=0 ourrc=0 slerr=0
TS87PROBE=$G/ts87probe python3 $G/score87v.py $G/grid pris lawv
#   TO=273 AWAY=0 WRONG2=10 MWRONG=0   (the 47-arm subset = the committed GRID89.score)
# the scorer's positive control, per arm — TO must become AWAY+MWRONG:
#   cp -r o_<arm>_lawv o_<arm>_swpA; cp -r o_<arm>_pris o_<arm>_swpB
#   python3 score87v.py grid swpA swpB <arm>
# DROPPABLE ALONE: three more worktrees, each with ONE law reverted, then score
#   the five w* arms against pris — only that law's arm loses its TO cells.
# the corpora, per binary, workdir names the SAME LENGTH (pris / lawv):
#   verify_golden.py --corpus uhdm2rtlil --mode {testflags,default} --jobs 3
#   verify_golden.py --corpus surelog    --mode both               --jobs 3
#   join87.py results/golden_uhdm2rtlil.csv <tf.csv> <def.csv>      # DIFF=0
#   ct8rows.sh results/golden_surelog.csv <sl.csv>                  # the four env rows
#   SELFCHECK=1 r11u86repro/byteverify.sh <lawv wd> <pris wd>
# the wide boundary, every *.sv under tools/probe:
#   (cd /tmp/wt_v11u89/tools/probe && find . -name '*.sv' | sed 's|^\./||' | sort > armlist)
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wt_v11u89/tools/probe BND_OUT=/tmp/v11u89_bnd \
#     xargs -P 2 -n 1 bash r11u86repro/bnd72.sh < armlist
# the page-class control: a FOURTH build, pristine + `volatile char v89pad[16384]`
#   appended to uhdm_main.cpp and NO law code, must move the same three arms by
#   +16384 where the law binary moves them by +4096.
```

Evidence: `evidence/{GRID89v.score,SWAPCTL89v.score,DROPONE89v.score,CELLS89v.txt,BOUNDARY89v.summary}`.
