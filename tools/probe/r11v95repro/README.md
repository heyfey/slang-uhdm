# r11v95 — the adversarial verification of r11u95, and the three faces it moved wrong

**VERDICT: ACCEPT WITH FIX.**  Every headline number in the implementer's
report reproduces bit-for-bit on binaries this verifier built itself, and the
three laws are real and correctly decoded.  Thirty-one fresh adversarial arms
on real v1.87 goldens found **three faces the patch listed WRONG**, all three
of them cases where the PRISTINE listing was right at the cell the patch moved:

| # | face | pristine | r11u95 | verified |
|---|---|---|---|---|
| 1 | a subroutine flattened over a name the program already carries — golden lists ONE, we wrote TWO (`x8_proggendupname`, `x27_proggendupfirst`) | 14 / 85 | **113 / 113** | **14 / 0** |
| 2 | the elaborated listing's ORDER against an imported package subroutine (`x12_proggenimportfn`, `x26_progimportbodyfn`) | ORDER-DIFF 0 | **ORDER-DIFF 1** | **0** |
| 3 | the class listing sorted by SPAN where golden keys it by NAME (`x25_proggenmixedorder`, `x29_progclasstwogen`) | 317 / 102 | **46 / 46** | **0 / 0** |

The fixes are in `src/ModuleEmit.cpp`, inside the r11u95 gates, each droppable
alone, and they change NOTHING on the implementer's 35-arm grid (the switch
ledger reads `171` and `R11U95_OFF=1` reads `1936` on the verified binary,
exactly as it does on the implementer's).

Base commit `5a20468f`, pins per `SUPPORT_MATRIX.md`.

| binary | md5 | what |
|---|---|---|
| pristine | `8b04ca25ae24cab79525249c4e5390a5` | built in THIS verifier's own worktree at `5a20468f`; `cmp`-identical to the main tree's `build/slang-uhdm` and to the OPS pin |
| r11u95 (as submitted) | `e24c5248b9db1698182192bfe6f857ad` | `/tmp/r11u95.patch` applied to a fresh `5a20468f` — **the implementer's md5, reproduced exactly** |
| verified | `5c47cc5d5d728350c90ed2a9b075bd31` | `/tmp/r11u95.verified.patch` |

---

## 1. WHAT REPRODUCED, BIT FOR BIT

* **Q1, the witnesses at `5a20468f`.**  `v4_proggeninit` 57, `v5_proggentask`
  64, `v7_progforzero` 56, `v11_progclass` 57; set-wise `CONV=12/20/11/13`
  with `AWAY=0` on each; all four **CONVERTED to 0**, and the other 11
  databases of the r11v93 grid are `cmp`-identical to pristine.
* **The 35-arm grid.**  pristine **1936** -> law **171**, arm for arm
  (57/43/64/57/108/108/133/57/65/65/57/57/56/78/56/70/56/144/57/72/109/135,
  ten controls at 0, `c4` 133, `c8` 29, `c10` 70).  22 converted, 3 unchanged
  and unclaimed.
* **The switch ledger.**  `R11U95_OFF=1` 1936, PROGPROC 1129, PROGTF 776,
  PROGCLASS 372, PROGTFINST 1147, GENZERO 487 — and the INERTNESS proof:
  with `R11U95_OFF=1` the law binary's database is byte-identical to the
  pristine binary's on **35/35** arms.
* **The r11u93 neighbour grid.**  53/53 databases `cmp`-identical; only
  `n11_ansistr` 113 and `pa9_proggenparam` 72 are nonzero, on both binaries.
* **Gates.**  goldens 23 PASS / 0 FAIL, `/bin/false` 0/23; u2r **788/16/67**
  in BOTH modes, every row-join PASS (against `results/gate_uhdm2rtlil.csv`,
  against both mode halves of `results/golden_uhdm2rtlil.csv` and against this
  verifier's own pristine sweeps); surelog **474/9 default + 469/8 testflags**
  on both binaries, identical histograms.

---

## 2. THE THREE FACES THE PATCH MOVED WRONG, AND THE FIXES

### 2a. § `caProgFlatTfNameKeyed95V` — the task/func registry is NAME-KEYED

`x8_proggendupname` (body `f_dup`@3:3, generate-block `f_dup`@6:7) and
`x27_proggendupfirst` (the same two, generate FIRST) both show golden listing
**ONE** `vpiTaskFunc`, never two — and the survivor carries the FIRST
declaration's SPAN with the LAST declaration's BODY (x8: span 3:3, `return 7`;
x27: span 5:7, `return 3`), which is a name-keyed map recompiled in place.
r11u95 appended the flattened copy unconditionally and so **wrote an object
golden lacks** — the break class the OPS names — taking x8 from 14 to 113 cmp
lines with SUBTREE OURS-ONLY 0 -> 2.

The NET face is the OPPOSITE and stays exactly as r11u93 landed it: the signal
list is a vector and does NOT dedupe (`pa13_progcollide` lists `w_dup` twice,
`pa12_progsamearm` lists both arms' `w_both`).  **The flattening is PER KIND.**

The fix skips a flattened subroutine whose name the program already carries
(and never mints it, using `emitTaskFuncs`'s own `onlySub` arm).  x8 returns to
the pristine reading of 14 (the body-value half is residue R5 below); x27
CONVERTS to **0**.

### 2b. § `caProgElabTfSrcOrder95V` — one source-ordered vector, import included

`x26_progimportbodyfn` is the decoder: golden's program lists
`pk::f_pkg`@3:3, `f_body`@7:3, `f_gen`@10:7 — ONE vector in source order across
the imported group and the program's own.  `emitImportArtifacts` is the LAST
writer of that vector (it appends the import at the very end of
`emitInstance`), so once r11u95 widened the shared def listing the flattened
subroutine jumped AHEAD of the import: SUBTREE `ORDER-DIFF` 0 -> 1 on both
holders of both arms, where pristine's shorter listing was a correct PREFIX of
golden's.  The fix re-sorts that vector by span once, after
`emitImportArtifacts`, and only for a program that actually flattened a
subroutine.  `ORDER-DIFF` returns to 0; the arms' remaining cmp lines are the
DEF view's missing import (residue R3, pre-existing — pristine misses it too).

### 2c. § `caProgClassListNameKeyed95V` — the class listing is name-keyed

`x29_progclasstwogen` (gen `Cg1`@5:7, body `Cbody`@8:3, gen `Cg2`@11:7) reads
golden **[Cbody, Cg1, Cg2]**, and `x25_proggenmixedorder` (gen `Ctwo`@9:7, body
`Cthree`@15:3) reads golden **[Cthree, Ctwo]** — NAME order, not span order.
r11u95's class face sorted by span, which put the generate-block class at
element 0 where golden has the body's.  `x28_progclassorder` (Ca@3, gen Cb@6,
Cc@9) is the arm where the two orders AGREE and a span sort passes, which is
why the implementer's grid did not catch it.  The fix sorts by name inside the
same `R11U95_PROGCLASS_OFF` gate; x25 and x29 CONVERT to **0**.

The same name-keying is visible with NO generate construct at all, on the
PROGRAM and the MODULE home alike (`x30_progclassnames`, `x31_modclassnames`:
golden lists `Aclass` before `Zclass` though `Zclass` is declared first — 46
cmp lines each on the PRISTINE binary).  That wider listing is NOT touched
here: it reaches the corpus and belongs to a pass that can measure it.  **R1.**

---

## 3. THE VERIFIED BINARY, MEASURED

* **My 31-arm grid** (every golden regenerated per arm by the pinned Surelog
  v1.87, both rc values recorded): pristine **2941** -> verified **932**.
  Against PRISTINE: **21 arms CONVERTED to 0**, 3 controls at 0 on both, 5
  unchanged (`x2` 64, `x8` 14, `x17` 318, `x30` 46, `x31` 46), and 2 whose
  judge PRINT is longer while every arbiter improves (`x12`, `x26`, §2b).
  Against r11u95: the two arms it regressed (`x8` 113 -> 14, `x27` 113 -> 0)
  and the two its class sort mis-ordered (`x25` 46 -> 0, `x29` 46 -> 0).
  Set-wise over the grid: **CONV=407, AWAY=0**.
  SUBTREE (this pass's vectors) pristine `MATCH=33 GOLD-ONLY=80 OURS-ONLY=7`
  -> verified `MATCH=107 GOLD-ONLY=6 OURS-ONLY=4 ORDER-DIFF=1`, against
  r11u95's `MATCH=109 GOLD-ONLY=4 OURS-ONLY=6 ORDER-DIFF=3`: the two OURS-ONLY
  entries the dedupe removes are objects golden does not have, and the two
  ORDER-DIFFs are the ones §2b and §2c close.
* **The switch ledger on MY grid**: pristine 2941, verified 932,
  `R11U95_OFF=1` **2941 exactly**, `R11U95V_TFDEDUPE_OFF=1` 1144,
  `R11U95V_TFELABORD_OFF=1` 932 (judge-line-neutral, byte-visible on x12/x26
  alone), `R11U95_PROGCLASS_OFF=1` 1856, `R11U95_PROGTF_OFF=1` 2170.  With
  `R11U95_OFF=1` the verified binary's databases are byte-identical to
  pristine's on **30/30** buildable arms.
* **Neighbours**: r11u93 grid 53/53 `cmp`-identical to pristine; r11v93 grid —
  exactly the four witnesses move, the other 11/11 identical.

---

## 4. HOW TO RE-RUN

```bash
H=tools/probe/r11v95repro
GRID=$H/grid bash tools/probe/r11u95repro/rr95.sh <binary> <tag>     # 31 arms, both rc values
python3 tools/probe/r11u95repro/subtree95.py <gold.dump> <ours.dump> --rows
python3 tools/probe/r11u95repro/setaway95.py <g.pris> <o.pris> <g.new> <o.new>
python3 $H/srcscan95v.py <dir> …      # the WIDER source census (bare generates too)
bash    $H/bnd95v.sh <pristine> <patched> <outdir> tools/probe   # the wide boundary
R11U95V_TFDEDUPE_OFF=1 / R11U95V_TFELABORD_OFF=1 / R11U95_PROGCLASS_OFF=1 <binary> …
```

---

## 5. THE GATES ON THE VERIFIED BINARY (`5c47cc5d5d728350c90ed2a9b075bd31`)

Four sweeps, this verifier's own workdirs (`slpv`/`slvf`/`u2pv`/`u2vf`, same-
length tags), every `cmds.txt` audited by absolute binary PATH (1581+1581
surelog, 1742+1742 u2r; the only `slang:` path in each is the frozen binary the
sweep was meant to run).

1. **BUILD** — pristine `8b04ca25ae24cab79525249c4e5390a5`, `cmp`-identical to
   the main tree at `5a20468f`; r11u95 as submitted
   `e24c5248b9db1698182192bfe6f857ad` (the implementer's md5, reproduced);
   verified `5c47cc5d5d728350c90ed2a9b075bd31`, rebuilt from a FRESH `5a20468f`
   + `/tmp/r11u95.verified.patch`.
2. **GOLDENS** — 23 PASS / 0 FAIL on all three binaries; `/bin/false` 0 PASS /
   23 FAIL (negative control).
3. **uhdm2rtlil, BOTH MODES** — 788 CMP_EQUAL / 16 CMP_NOTEQUAL / 67
   SLANG_REJECT in each, every row-join PASS against
   `results/gate_uhdm2rtlil.csv`, against BOTH mode halves of
   `results/golden_uhdm2rtlil.csv`, and against this verifier's own pristine
   sweeps.  **No row moved.**
4. **surelog, `--mode both`** — 474/9 default + 469/8 testflags on all three
   binaries, histograms identical.  Against this verifier's own pristine sweep
   exactly the two `LowMemLib`/`LowMemPkg` rows whose `detail` embeds the
   workdir path (`SURELOG_FAIL` on both sides) plus `Earlgrey_0_1`'s DUMP
   COLUMN, which reads blank in whichever mode drew the `uhdm-dump` timeout —
   default on this sweep, testflags on the pristine one, STATUS `CMP_EQUAL` in
   both and the DATABASE byte-identical to the OPS pins.
5. **BYTEVERIFY `SELFCHECK=1`** — u2r **0 / 1608**; surelog **5 / 960**, all
   five in the UVM family (`MiniAmiq` x2, `SeqDriver` x2, `SimpleUVM`) and all
   five the documented per-invocation draw, attributed THREE ways: order-blind
   payload is exactly 4 lines, every one a `UINT:`/`vpiDecompile:` pair in an
   `array_typespec`'s synthesized right range (r11u95's residue R2 site);
   re-run SEQUENTIALLY from the corpus directory the VERIFIED binary writes the
   PRISTINE md5 (`SimpleUVM` d4f8cd018f2d on both, law-ON and `R11U95_OFF=1`
   alike); and the PRISTINE binary disagrees WITH ITSELF across consecutive
   runs of the same argv (`MiniAmiq` c052aa13e5d3 / a47f97cb3810, `SeqDriver`
   c0f9dab4ff2e / e4ef218438f1), none of them its own sweep md5.  The r11u95
   sweep moved a DIFFERENT subset (it drew `Scoreboard` and not `SeqDriver`/tf)
   — which is the coin, printed twice.
6. **CANARIES** — `canaries.sh` surelog ok=52 changed=0 against this verifier's
   own pristine sweep for r11u95 (ok=50 changed=2 for the verified binary, both
   being Earlgrey's dump column, which reads `differ` on one sweep and blank on
   the other with the STATUS unmoved); u2r ok=8 changed=0; `ctcan2.sh` PASS on
   both corpora; `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0.  Every
   protected database SAME on all three binaries: `SVSwitch 4842211c4030`,
   `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`,
   `BlackParrotComplex e3e354129d5a`/`73a10e8217e5`, `YosysOldOr d68e0796d62c`,
   `Earlgrey_0_1 8bdf25272e08` (default) / `59d0ee6d10c3` (testflags).  All
   seven conversion rows CMP_EQUAL in both modes, byte-identical to the
   committed CSV.
7. **FENCES** — `git diff 5a20468f -- src include` carries 0 occurrences of any
   of the four slang-fenced names; neither probe directory mentions one outside
   `canaudit.sh`'s own `FENCED=` line; no driver dispatches one;
   `results/*.csv` never written; `src/ParamEmit.cpp`, `src/EmitHelpers.h` and
   `src/ExprEmit.cpp` untouched.

## 6. THE WIDE ARM BOUNDARY

`bnd95v.sh` compiled **every one of the 4294 directories under `tools/probe`
that holds a `.sv`/`.v`** with the pristine and the verified binary on
identical argv and compared the databases byte for byte:
`listed=4294 processed=4294 moved=104 rc-or-db-anomalies=0`, `PROCESSED==LISTED`.

All 104 attributed, none unexplained:

| n | class | how it was proved |
|---|---|---|
| 91 | THE LAW | `R11U95_NETDBG=1` names a site AND `R11U95_OFF=1` reproduces the PRISTINE database byte for byte |
| 2 | law-gated, untraced | `R11U95_OFF=1` reverts; normalised dumps identical (ids/order only) |
| 8 | COIN | the PRISTINE binary disagrees with ITSELF over three consecutive runs (`r10uvm117repro` e63be9b6b6 / e04adfa526 / e63be9b6b6) |
| 3 | r11u95's residue R2 | `bignum` payload in an `array_typespec` range; `R11U95_OFF=1` does NOT revert it (`r10buvm22repro`, `r10uvm154repro`, `r10uvm185repro/grid185`) |

Measured against golden (regenerated per arm by the pinned Surelog), over the
102 movers that produce a golden: **BETTER 47, SAME 53, WORSE 2** — and the two
are this verifier's own `x12`/`x26`, whose judge PRINT grows while every
arbiter improves (§2b, residue R3).

## 7. RESIDUES (ranked)

1. **R0 — THE PARAMETER HALF, FENCED** (r11u95's R0, unchanged):
   `a20_proggenparam` 72 cmp lines on all three binaries.  Golden's program
   carries the generate block's `vpiParameter` + `param_assign`; the program's
   parameter vector is `emitParameters` in `src/ParamEmit.cpp`, the sister
   pass's ground.  Corpus-invisible.
2. **R1 — THE CLASS LISTING IS NAME-KEYED EVERYWHERE, NOT ONLY WHEN FLATTENED.**
   `x30_progclassnames` (program) and `x31_modclassnames` (module) declare
   `Zclass` then `Aclass` with NO generate construct anywhere: golden lists
   `Aclass` first, we list `Zclass` first — 46 cmp lines each, identical on all
   three binaries.  This one REACHES THE CORPUS (every class-bearing module,
   program and package), so it is named, not landed.  The next pass's R0
   candidate: sort every `Class_defns` listing by name and measure.
3. **R2 — A MODULE HOME FLATTENS ITS GENERATE BLOCK'S CLASSES, AND AN
   INTERFACE HOME PUBLISHES ONE AT THE DESIGN ROOT** (r11u95's R1, widened):
   `c10_modgenclass` 70 and `c8_modfinalgen` 29 as reported, plus
   `x17_ifacegentask` **318** — an interface whose generate block holds a class
   publishes it as `work@C` under the design's `uhdmallClasses` in golden and
   not in ours.  All identical on all three binaries.
4. **R3 — THE DEF VIEW DOES NOT LIST AN IMPORTED PACKAGE SUBROUTINE.**
   `x12_proggenimportfn` 203 and `x26_progimportbodyfn` 241: golden's DEF
   program lists `pk::f_pkg` beside the program's own subroutines; we list it
   only on the ELAB view.  PRE-EXISTING (pristine lists it in neither view);
   after §2b the elaborated listing matches golden exactly and this is the only
   surviving `GOLD-ONLY` entry on either arm.
5. **R4 — A CONCURRENT ASSERTION IN A PROGRAM'S GENERATE BLOCK.**
   `x2_proggenassert` 64 cmp lines, identical on all three binaries: the def
   road claims concurrent assertions before the flattening and the elab road
   skips them, so a `assert property` written inside a program's generate block
   is listed by neither view.  Corpus-invisible.
6. **R5 — the name-keyed registry keeps the FIRST declaration's SPAN and the
   LAST declaration's BODY** (`x8_proggendupname` 14 lines: golden's single
   `f_dup`@3:3 returns 7, the SECOND declaration's body; ours returns 3).  The
   dedupe in §2a keeps the first object as golden does; recompiling its body
   from the last declaration is a separate face.
7. **`a20`/`n11_ansistr`/`pa9_proggenparam` and the pass 82–93 residues stand
   unmoved**: the r11u93 grid is 53/53 `cmp`-identical between pristine and the
   verified binary.
