# r10v198 — ADVERSARIAL VERIFICATION of r10uvm198 — **ACCEPT WITH FIX**

**MEASUREMENT-ONLY probes.** The official `uhdm-cmp`
(`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py` are the
only judges of every number here. slang was **NOT** patched; `results/*.csv`
were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW CONVERTED**;
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `f7a77143` (the verifier's own fresh worktrees) |
| pristine | md5 `a2733a6622a01308a82a434a9e747d5e` — built by the verifier, **byte-identical to the implementer's claim and to the master's frozen pristine** |
| implementer's patched | md5 `ca837653759ad48756a9288c316d75d3` — **byte-identical to the implementer's claim** |
| VERIFIED (shipped) | md5 `45c9dbce0ba3388284e78b4635bc267e` — the implementer's patch plus § `clsScopedTdLocalCloneIsClassMethodOnly198v` |
| verdict | **ACCEPT WITH FIX** — the law and the head are real and reproduce bit-for-bit; one clause was too wide and wrote 9 AWAY-GOLDEN cells on legal SV in the ELABORATED view |

---

## 1. WHAT REPRODUCED BIT-FOR-BIT

Every headline number was re-measured from the verifier's own build, its own
frozen binaries and its own sweeps.

| claim | verifier's measurement |
|---|---|
| pristine md5 `a2733a66…` | **identical** |
| patched md5 `ca837653…` | **identical** |
| the head: SeqDriver ×2 and MiniAmiq ×2, **198 → 33 cmp lines, ONE head** | **identical**, on the verifier's own sweeps (pristine 198/198/198/198, verified 33/33/33/33) |
| SimpleUVM 62 ×2, Scoreboard/default 95, Earlgrey/default 56, BuildUVMPkg ×2 / Earlgrey/tf / Rggen/default CMP_EQUAL at rc=0 | **identical, before and after** |
| goldens 23 PASS / 0 FAIL on both binaries, `/bin/false` 23 FAIL | **identical** (and 23/0 on the verified binary too) |
| u2r: 0 differing rows, byteverify **0 / 1358** | **identical** |
| surelog: **0 differing rows vs own pristine**; vs the committed baseline exactly one row-side, `Earlgrey_0_1,testflags CMP_EQUAL/differ → CMP_EQUAL/`, **present identically in the verifier's own PRISTINE sweep** | **identical** — a uhdm-dump timeout of the DUMP column under sweep load, not a model change; status stays CMP_EQUAL; no row converted |
| byte movers **5 / 956**: the four PREDICTED BY NAME plus Scoreboard/default | **identical.** The coin's order-blind attribution is even cleaner than reported: with the workdir path normalised and both dumps sorted the diff is **0 lines**, so the byte difference is pure listing order |
| census, nine UVM row-modes, golden-vs-golden calibrated first (all columns 0) | **identical**: SeqDriver ×2 / MiniAmiq ×2 **TO-GOLDEN 4, AWAY-GOLDEN 0, MOVED-WRONG 0**; SimpleUVM ×2, Scoreboard/default, BuildUVMPkg ×2 all columns 0 |
| the a-priori prediction: `strict` non-zero on exactly four row-modes of the surelog corpus, none of 1358 u2r | **identical** (re-read from the committed `PREDICT.*` files and matched against the observed movers) |
| SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical | **PINS HELD**, both modes |
| the four protected CMP_EQUAL rows keep CMP_EQUAL with byte-identical databases | **identical** |
| R0, the next head | **identical**: `LHS: <null>` above our folded `constant` (`vpiDecompile:115199`, `INT:115199`, `vpiSize:32`, `vpiConstType:7`) at `410:30-410:60` under `param_assign@410:11-410:62`, `ref_typespec(adpcm_pkg) -> int_typespec` |

`GATES.r10v198.txt` carries all of it, command by command, including the
`cmds.txt` binary audit: the **only** `slang:` binary named anywhere in the
verifier's pristine sweep is `/tmp/v198_pris.bin` and in its verified sweep
`/tmp/v198_fix.bin`.

---

## 2. THE BREAK — § `clsScopedTdLocalCloneIsClassMethodOnly198v`

> `importCopyTsInst` is **three** clone drivers, not one. Only
> `ParamEmit.cpp:23646` clones an out-of-body CLASS METHOD — the construct this
> law was decoded on. `:20962` and `:21044` clone an imported package **FREE
> SUBROUTINE**, and there our emitter hands the SAME typespec to the copy that
> lands under the importing PACKAGE and to the copies that land under a
> `class_defn` or a `module_inst`. Golden degrades only the first kind. Firing
> on a free subroutine therefore writes the placeholder into cells golden keeps
> RESOLVED.

**The arm.** `arms198v/v198_5_imports.sv` writes `AditV5::clsStV5 scopedV5;`
(and a block-item twin) in the package FREE function `quarryV5::freeV5`, and
has that function cloned three ways — `import quarryV5::freeV5;` in one
package, `import quarryV5::*;` in another, and a module that imports the same
package. One real Surelog golden, both views:

```
ELAB, golden
  function:freeV5 < package:raceV5             TS=unsupported_typespec:AditV5::clsStV5:INST=package:quarryV5
  function:freeV5 < class_defn:FlumeV5 < package:raceV5   TS=struct_typespec:clsStV5:INST=-      <-- RESOLVED
  function:freeV5 < class_defn:OwnV5   < package:sluiceV5 TS=struct_typespec:clsStV5:INST=-      <-- RESOLVED
  function:freeV5 < module_inst:work@topV5                TS=struct_typespec:clsStV5:INST=-      <-- RESOLVED
ELAB, pristine   every one of the three RESOLVED  (RIGHT)
ELAB, patched    every one of the three unsupported_typespec:AditV5::clsStV5:INST=package:quarryV5  (WRONG)
```

`score198.py` over the whole arm: **AWAY-GOLDEN 9** in the elaborated view
(3 declarations × 3 clone contexts), against TO-GOLDEN 9 — a wash in count and
a failure of the landing bar, which is AWAY-GOLDEN **0**.

The class-method half of the very same arm is **right**: `clsStV5 tfClsV5` and
`blkClsV5`, declared in the out-of-body method `AditV5::winzeV5`, degrade under
`package:raceV5` and stay resolved under `class_defn:FlumeV5` and
`module_inst:work@topV5` — because there the package-listing clone and the
class/module copies are separate objects from separate drivers. That contrast
is what names the gate.

**The fix** (two lines, one per site, each carrying the measurement):

```
-   importCopyTsInst ? clsScopedTdLocalName198(fmv) : std::string{}
+   (importCopyTsInst && pkgClassTfClone) ? clsScopedTdLocalName198(fmv) : std::string{}
```

`pkgClassTfClone` is set by `ParamEmit.cpp:23646` and by nothing the
free-subroutine drivers do; `ParamEmit.cpp:23244`'s own-class pass sets it with
`importCopyTsInst` NULL, so the **conjunction** is exactly the imported
class-method clone. After the fix arm 5 reads **TO-GOLDEN 3, AWAY-GOLDEN 0,
MOVED-WRONG 0** in both views, and every other arm is unchanged.

**The fix is corpus-invisible.** Re-run from the tests' own source
directories, the implementer's binary and the verified binary produce
**byte-identical** databases on both moving tests (SeqDriver
`22a4ba6ff1e87e9c3deeff00cebf40e0`, MiniAmiq `fa86bbdb9482fd7ae7bdee0aa6b9ec59`
for BOTH binaries), so every corpus number above holds verbatim for the shipped
patch.

---

## 3. THE ARMS THAT DID **NOT** BREAK IT

Six arms, one real Surelog golden each, both views, every rc recorded
(`ARMS.r10v198.txt`). Scores are on the VERIFIED binary; the implementer's
binary is in the same file for comparison.

| arm | what it attacks | def | elab |
|---|---|---|---|
| 1 `v198_1_shadow` | a class-scope typedef whose name is ALSO a package-scope typedef of the same package (Surelog's `compileVariable` finds it in the PACKAGE data-type map and never degrades) | TO-GOLDEN 3, AWAY 0, **MOVED-WRONG 6** (residue R1) | 3 / 0 / **6** |
| 2 `v198_2_kinds` | enum, packed union, string, int, packed vector, real, alias-of-a-package-typedef, class-handle typedef and alias-of-a-class-typedef, each with a package-scope control of the SAME kind in the SAME cloned body | TO-GOLDEN 26, AWAY 0, WRONG 0 | 26 / 0 / 0 |
| 3 `v198_3_scopes` | a NESTED class, a PARAMETERISED class, a typedef INHERITED from a base class in ANOTHER package, and a THREE-package transitive import chain | 14 / 0 / 0 | 14 / 0 / 0 |
| 4 `v198_4_sites` | the RETURN type and the FORMALS (§ 36's cells) beside a static local, an automatic local, an initialised local, an ARRAY (the stated fence), a named begin, a for body, a while body, a case item, both `if` arms, a `fork` arm and a `foreach` body (the corpus head's own shape) | 17 / 0 / 0 | 17 / 0 / 0 |
| 5 `v198_5_imports` | the OTHER two clone drivers, an importing package's OWN out-of-body class method, and a MODULE importer | 3 / 0 / 0 | 3 / 0 / 0 |
| 6 `v198_6_nestctl` | arm 3 with every class-scope typedef local removed — nothing can reach either site | both binaries **BYTE-IDENTICAL**; all columns 0 | 0 / 0 / 0 |

Three of those deserve naming.

* **§ 36's FORMALS move NOTHING.** Scored on their own (`--rows=IO`) across
  every arm and both views: **TO-GOLDEN 0, AWAY-GOLDEN 0, MOVED-WRONG 0**. The
  law stays out of the neighbouring law's territory in every case it was
  offered.
* **The home listings stay resolved.** `sluiceV5`'s OWN out-of-body method
  `OwnV5::ownMethodV5` reads `struct_typespec:ownStV5:INST=-` in golden, in
  pristine and in the verified binary, in every view and under every parent.
* **The nested-class head is pre-existing.** Arm 3's def cmp count goes 62 →
  1068 — the head OBJECT changes from `unsupported_typespec(outStV3)` (which
  the law clears) to a `class_defn(midP3::OuterV3)` whose `vpiInternalScope`
  lists the nested class. Arm 6, the same file with every reachable local
  deleted, produces the **same** 706-line class_defn head on BOTH binaries with
  **byte-identical databases** — so that head is a pre-existing residue that
  the fix merely unmasks, not a regression.

---

## 4. THE WIDE BOUNDARY

`LISTED=5226 PROCESSED=5226 PRODUCED_DBS=5041 RC_DIFFS=0 MOVED_ARMS=11`
(`BOUNDARY.r10v198.txt`), pristine vs the VERIFIED binary, over a copy of the
whole probe tree.

* **5** are this pass's own `grid198/g198_*.sv` — the positive control.
* **3** are arms the law legitimately touches — `r10buvm9repro/w4v_imports.sv`
  and two `r10v181repro` arms. Rebuilt against their own goldens: TO-GOLDEN
  2 / 2 / 2 def and 4 / 2 / 2 elab, **AWAY-GOLDEN 0, MOVED-WRONG 0**, IO all
  zero, and the cmp line count UNCHANGED in both views.
* **3** are the KNOWN static-address false mover — `r10buvm22repro/g22.sv`,
  `r10uvm154repro/l154_noenum.sv` and `r10uvm185repro/grid185/g185_e_kinds.sv`.
  Every moving byte is ONE address-derived constant on the range of a
  class-scoped associative-array typedef, `22650617 → 22654713`, **exactly 4096
  apart** — the pair `l154_noenum.sv` was committed to demonstrate — and every
  diff line sits **BELOW `\_weaklyReferenced:`**, which the judge cannot reach.
  Pristine is deterministic on all three (five runs, one md5 each), so this is
  binary LAYOUT and not a coin; the census reads every mover column 0 and the
  cmp line count is unchanged. It moves for this binary and not for the
  implementer's only because the two link layouts differ, which is why the
  implementer counted 8 arms and this run counts 11.

No arm of § `classScopedTdImportCopyUnsupported36`, uvm170 (or either of its
fences), uvm183, uvm195, uvm181-194, uvm82-91, buvm3-15 or sd8-12 moved.

---

## 5. RANKED RESIDUES

* **R1 — THE SHADOWED NAME (the one thing left wrong that pristine had less
  wrong).** When the enclosing package declares a typedef of the SAME NAME as
  the class-scope one, Surelog's `compileVariable` resolves it out of the
  PACKAGE data-type map, never registers a late binding, and golden reads a
  RESOLVED `struct_typespec quarryV1::shadeStV1 @quarryV1` **in the clone as
  well as in the home** (arm 1, every cell). Pristine reads
  `struct_typespec shadeStV1 INST=-` — the wrong name and the wrong instance
  but the RIGHT KIND; the patch reads `unsupported_typespec shadeStV1
  @quarryV1`, which fails `Compare` one field EARLIER, at `VpiType`. The cell
  is NOTEQUAL either way, the arm's cmp line count and head are UNCHANGED
  (56/56 def, 60/60 elab), and no CMP_EQUAL row can flip through it (golden's
  name is package-qualified, so our resolved form never matched it either) —
  which is why it is reported and not fenced. The fence, if it is ever wanted,
  is one lookup: decline the BARE spelling when the class's own package
  declares a type of that name. Six cells, both views, unmoved by the fix.
* **R2 — the free-subroutine clone's own degradation, now unclaimed.** Golden
  DOES degrade the package-listing copy of a free subroutine's class-scope
  typedef local (arm 5, `<package:raceV5>` / `<package:sluiceV5>`, both views).
  The fix declines the whole construct because our emitter cannot separate that
  copy from the class/module copies that golden keeps resolved — they share the
  typespec. Closing it is a SHARING law (give the free-subroutine clone its own
  typespec objects first), not a widening of this one. 9 cells def, 12 elab.
* **R3 — the nested-class `class_defn` head** unmasked by arm 3: golden's
  `midP3::OuterV3` and ours disagree on the internal-scope listing of a nested
  class. Pre-existing, both binaries, 706 lines on arm 6.
* **R4 — the implementer's own R1–R4 stand as written** (the ARRAY fence, the
  clone's package-typedef instance, the home-view union/string kind residues,
  the three-segment spelling), all re-observed unmoved on both binaries.

---

## 6. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm198repro
g++ -O2 -std=c++17 ct198cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct198cen

# every verifier arm, one real Surelog golden each, BOTH views, BOTH binaries
for a in ../r10v198repro/arms198v/v198_*.sv; do
  CEN=/tmp/ct198cen bash grid198.sh "$a" <PRISTINE> <VERIFIED> /tmp/w_$(basename $a .sv)
done
python3 score198.py /tmp/w_v198_5_imports/cen.g.elab.txt \
                    /tmp/w_v198_5_imports/cen.a.elab.txt \
                    /tmp/w_v198_5_imports/cen.b.elab.txt --show   # AWAY-GOLDEN 0 after the fix
python3 score198.py <g> <a> <b> --rows=IO                          # § 36's formals: all columns 0

# the wide boundary, over a COPY of the probe tree
PRIS=<PRISTINE> PATCHED=<VERIFIED> bash bound198.sh <copy of tools/probe> /tmp/bnd

# the corpus census and the heads, from two completed sweep workdirs
CEN=/tmp/ct198cen bash cen198.sh <pristine workdir> <verified workdir> /tmp/cen
bash ../r10uvm67repro/rowheads.sh <workdir> /tmp/heads SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
```
