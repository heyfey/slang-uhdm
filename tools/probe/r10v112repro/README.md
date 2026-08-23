# r10v112 — ADVERSARIAL VERIFICATION of r10uvm112
## § `classTdCloneSpecOverridesOwnArgs112` — **VERDICT: ACCEPT AS SHIPPED**

Independent worktrees at `d4d4642`, both binaries rebuilt from source by the
verifier, every headline number re-measured, every `cmds.txt` audited by binary
path, twenty new adversarial arms written against purpose-built Surelog golden.

---

## 1. Bit-for-bit reproduction

| quantity | implementer | verifier | |
|---|---|---|---|
| patch md5 | `29ea7ca23722d24977d3efcf70ba3d82` | same | ✓ |
| pristine binary md5 | `af17c942bc7afeaaf6a78678eadcafcd` | same | ✓ |
| patched binary md5 | `231b37ef82337f352d35919add9a9a10` | same | ✓ |
| goldens patched / pristine / `/bin/false` | 23-0 / 23-0 / 0-23 | same | ✓ |
| u2r testflags + default | 679 / 50 / 2 each | same | ✓ |
| surelog status histogram | 471+466 EQ, 10+9 NE, 283+284 REJ, 25+23 SF, 5+5 DEF, 3 NODB, 2 UNTR, 1 TMO, 1 NOUHDM | same, cell for cell | ✓ |
| `ct8rows` u2r (baseline AND own control, tf AND def) | PASS | PASS | ✓ |
| `ct8rows` surelog 1588 rows (baseline AND own control) | PASS | PASS | ✓ |
| `byteverify` u2r | MOVERS 0 / 1358 | 0/679 + 0/679, selfcheck 678/679 each | ✓ |
| `byteverify` surelog | MOVERS 4 / 956 | **5 / 956** — see §2 | ~ |
| heads SeqDriver | 32 → 62, head OBJECT changed | same; the four committed `head_*.cmp` files are **byte-identical** to my own measurement, ids included | ✓ |
| heads MiniAmiq / SimpleUVM / Scoreboard / BuildUVMPkg / Earlgrey / Rggen | 348 / 42 / 42 / 42 / 36 / 0 | same; MiniAmiq's head cmp is byte-identical pristine-vs-patched | ✓ |
| census SeqDriver | TO-GOLDEN 3 / AWAY 0 / STILL-WRONG 0 / STILL-RIGHT 167 | same, from an INDEPENDENTLY WRITTEN comparator (`v112cen.py`) | ✓ |
| census MiniAmiq | TO-GOLDEN 10 / AWAY 0 / STILL-WRONG 0 / STILL-RIGHT 168 | same, both modes | ✓ |
| `pred112.py` on MY pristine dumps | 13 cells | 3 (SeqDriver) + 10 (MiniAmiq) = 13 | ✓ |
| canaries sl / u2r, ctcan2 ×2, canaudit | 52-0 / 8-0, PASS, 29/0/0 | same | ✓ |
| protected DBs | InterfaceModPort, BlackParrotComplex, YosysOldOr identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | all confirmed, both modes | ✓ |
| `results/*.csv` | untouched | confirmed: the patch contains no `results/` hunk | ✓ |
| fence | four fenced tests named nowhere | confirmed by `awk` over the patch and by `canaudit` | ✓ |

All 1523 surelog and 1458 u2r `cmds.txt` that invoke slang name the frozen
binary and nothing else; the 50 + 4 that name none are the rows where slang is
never invoked (`SURELOG_FAIL` and friends).  No `cmds.txt` anywhere names a
main-tree binary.

---

## 2. The fifth mover: Scoreboard/default is a COIN, and it flipped for me

`byteverify` gave me **5** movers where the implementer got 4.  The fifth is
`default/Scoreboard-59431470`, the documented ~50/50 `vpiTaskFunc` ORDER coin.
Attributed order-blind, as the law requires:

```
default/Scoreboard-59431470   unsorted=92   SORTED=0     <- pure ORDER, no content
default/SeqDriver-32af76aa    unsorted=24   SORTED=24    <- real
testflags/SeqDriver-32af76aa  unsorted=24   SORTED=24    <- real
default/MiniAmiq-544c7f61     unsorted=80   SORTED=80    <- real
testflags/MiniAmiq-544c7f61   unsorted=80   SORTED=80    <- real
```

So the CONTENT movers are 4 database-modes, exactly the a-priori prediction.
The implementer's "Scoreboard's coin did not flip" was true of their run and is
not a property of the patch; a verifier must not read a quiet coin as evidence.

The moved lines are exactly the predicted cells and nothing else:
SeqDriver `adpcm_sequencer / adpcm_test -> adpcm_driver` and
`adpcm_tx_seq -> adpcm_seq_item`; MiniAmiq six `-> svaunit_base_sequence` and
four `-> svaunit_base`, including `svaunit_sequence_test`, whose own emission
sits at the **`m_uvm_component_registry_param` macro (line 483)** and which
still joins the **line-468** group — the single cell that refutes the
macro-location hypothesis, re-measured here.

---

## 3. Breaking the law: 18 new arm sources / 20 arm runs, golden-judged, BOTH views

`run_v112.sh` builds golden (Surelog), pristine and patched for each arm in
both views, records **rc per cell**, and judges each side with the **official
`uhdm-cmp`** (LHS always golden).  Scratch is keyed on the relative source
path.  Eleven of the new arms convert FAIL → PASS (and the pass's own four do
too); **not one arm regresses.**

| arm | shape | pristine | patched | golden's own answer |
|---|---|---|---|---|
| `g1_asciiedge` | ASCII order, ci-order and source order ALL disagree: `Zed1`(0x5A) `_und1`(0x5F) `aab1`(0x61), source `aab1,_und1,Zed1` | **FAIL** 32 | **PASS** | all three bind Q to **`Zed1`** — the ASCII-first key, not source-first, not ci-first |
| `g2_digits` | `c2`, `c2a`, `c10` — ASCII vs numeric order disagree | **FAIL** 32 | **PASS** | **`c10`** (ASCII), refuting numeric order |
| `g3_fiveclasses` | FIVE members, source order scrambled | **FAIL** 32 | **PASS** | **`Alpha3`** |
| `g5_oneline` | two members whose whole declarations share ONE source line | **FAIL** 32 | **PASS** | **`Ab5`**, not the leftmost `za5` |
| `g10_twomacros` | the MiniAmiq shape without UVM: TWO different macros, one with a `_param`-style single argument, interleaved over four classes | **FAIL** 32 | **PASS** | **`Aa10`** for all four — ONE group across two macro lines |
| `g12_twoinclass` | TWO typedefs of the generic inside ONE class + one in another | **FAIL** 32 | **PASS** | **`Ab12`** — the tie inside one owner breaks on the TYPEDEF NAME (`t12a` < `t12b`) |
| `g13_includetwice` | the same class text `` `include ``d into two packages (identical spans) + a third | **FAIL** 32 | **PASS** | **`inner13`** from `Ap13one` |
| `g14_macroparamclass` | one macro line expanded for a PLAIN class, a PARAMETERIZED class and a third class | FAIL 32 | FAIL 274, head OBJECT changed | every comparable binding matches golden (`Aa14`), incl. the parameterized member; new head is §5's pre-existing family |
| `g18_arity` | base passes ONE argument, clones pass TWO | **FAIL** 32 | **PASS** | the clone's extra `"mm18"` VANISHES — the copy walks the BASE's formals |
| `g19_builtin` | actuals are UNNAMED BUILTIN typespecs (`byte`/`shortint`/`longint`) | **FAIL** 24 | **PASS** | all three bind Q to **`byte`** — the law is NOT class-specific |
| `sub7` orderA | group split over THREE files / TWO packages | **FAIL** 32 | **PASS** | **`Mid7`** |
| `sub7` orderB | the SAME sources, the two use-files in the OPPOSITE command-line order | **FAIL** 32 | **PASS** | **`Mid7` again** — the base does NOT follow file or command order |
| `g9_instances` | the group with 0 / 1 / 3 instances of its members | FAIL 32 | FAIL 326, head OBJECT changed | 2 cells TO-GOLDEN, 0 away; new head is §5's pre-existing family |
| `g4_qualified` | the generic named with an explicit `pkg::` qualifier, no wildcard import | PASS | PASS | golden emits **no specialization at all** — the probe hits, so there is nothing to clone |
| `g15_twopkg_two` | two same-named member classes in two packages | PASS | PASS | agrees |
| `g8_paramclass` | the base is a PARAMETERIZED class whose argument names its own type parameter | FAIL 95/117 | FAIL 95/117, `cmp` byte-identical | pre-existing, untouched |
| `g6_baseplain` | the ASCII-first member carries NO `#()` at all | FAIL 95/117 | FAIL 95/117, `cmp` byte-identical | **residue R2** below |
| `g11_moduleunit` | the same specializations at MODULE scope | slang rejects, both binaries identically | same | the overwrite correctly never reaches module-scope typedefs |
| `g16_pkganchor` | PACKAGE-scope anchor + class-nested clone with a different argument | FAIL 85 | FAIL 85, `cmp` byte-identical | **residue R1** below |
| `g17_pkgpair` | TWO PACKAGE-scope typedefs of one generic, different arguments | FAIL 85 | FAIL 85, `cmp` byte-identical | **residue R1** below |
| `a6/a7/a9/sub5/a8/a10` (the pass's own) | re-run here | a6/a7/a9/sub5 FAIL 32 | **PASS** | a8, a10 PASS on both sides |

**Golden determinism.** `g1` was rebuilt three times end to end: golden md5
`dad5a887d4b3` and patched md5 `803ed0d0f838` on every run.  The base pick is
not a race, and it is stable across Surelog rebuilds of the same sources.

**`a10` re-measured.** Golden has ONE `shared10` object at the base's span
`11:20-11:42` (6 references); pristine has TWO (`11:20` and `14:20`); patched
has ONE at `11:20`.  The implementer's self-correction is exactly right.

---

## 4. Wide boundary from a CLEAN tree — only SIX files in all of `tools/probe` move

`bnd112.sh` over a COPY of `tools/probe` with no path filter, `.sv` and `.v`,
recursive, both views, rc per cell, list on fd 3, children `</dev/null`,
PROCESSED asserted.

```
MODE=file  LISTED=3469 PROCESSED=3469 MOVED=12  RC_PAIRS=6938 RC_DIFF=0 ASYM=0  PROCESSED-ASSERT-OK
MODE=dir   LISTED=1505 PROCESSED=1505 MOVED=12  RC_PAIRS=3010 RC_DIFF=0 ASYM=0  PROCESSED-ASSERT-OK
```

The 12 per-file cells are **6 files × 2 views**:

* four are this pass's own arms (`a6`, `a7`, `a9`, `a10`);
* `r10sd1repro/grid/b22_foreign_two.sv` — re-measured against golden:
  `pb::wb::tidb::T` `wb` → `ub`, **TO-GOLDEN 1 / AWAY 0**, both views;
* `r10uvm54repro/a1/dut.sv` — re-measured against golden, and the three cells
  land on golden's **kind AND span** exactly:

  | pristine | patched | golden |
  |---|---|---|
  | `int_typespec @71:18` | `byte_typespec @77:18-77:22` | `byte_typespec @77:18-77:22` |
  | `int_typespec @83:18` | `short_int_typespec @84:18-84:26` | `short_int_typespec @84:18-84:26` |
  | `byte_typespec @98:18` | `int_typespec @91:18-91:21` | `int_typespec @91:18-91:21` |

  Golden contains **no** `byte@98`, `int@71` or `int@83` at all.  `VpiType` is
  the first field every generated `Compare` reads, so these are judge-visible.

The per-directory half adds only `r10uvm112repro` + its `sub5/`, the same
`r10uvm54repro/a1`, and three directories whose cells report `sorted=0`.

**Nothing else in the tree moves.**  Every committed arm of uvm89 / 92 / 94 /
95 / 97 / 98 / 99 / 100 / 101 / 104 / 106 / 108 / 110, buvm3–15 / 23 / 24 / 28 /
57 / 64 / 88, sd8–12, rgg18, the YosysOldSpi and vpiListOp precedents and every
`this.`/`super.`, hier_path, delay-control, event-control, typedef, class-
typespec and method-call arm is **byte-identical between the two binaries in
both views**.  `RC_DIFF=0` proves the pre-existing segfaults occur identically
on both binaries.

### The `sorted=0` directories: proved to be per-run nondeterminism

`r10uvm75repro`, `r10uvm76repro`, `r10v109repro` report `sorted=0`.  The
implementer wrote that hand re-runs give byte-identical dumps.  **They do not** —
and the truth is a stronger proof of the same conclusion.  Running the SAME
binary twice on those directories:

```
r10uvm75repro  pris-run1 vs pris-run2  unsorted=12  sorted=0
r10uvm76repro  pris-run1 vs pris-run2  unsorted=14  sorted=0
r10v109repro   pris-run1 vs pris-run2  unsorted=18  sorted=0
```

The four `.uhdm` md5s (pris×2, ship×2) are four different values in each
directory.  These directories are order-nondeterministic per invocation, so the
cross-binary `sorted=0` is that same phenomenon and carries no content.

### Reproducibility note on the committed boundary counts

`BOUNDARY.txt` records `LISTED=3486 / MOVED=28` (file) and `1523 / 27` (dir).
From a CLEAN checkout the counts are `3469 / 12` and `1505 / 12`.  The
difference is disclosed in `BOUNDARY.txt` itself: the implementer's copy of
`tools/probe` still held their arms' `run/…/slpp_all/lib/work/` Surelog
scratch (17 extra files, 8 extra moved cells), plus one extra `sorted=0`
directory from the same coin as §2.  No accounting error — but the committed
numbers cannot be reproduced from the tree, and `3469 / 12` is the figure a
future operator will measure.

---

## 5. Ranked residues (all measured; none is a regression)

**R1 — the law is only half applied: the PACKAGE side still refuses.**
`copyClassTdSpecParams1`'s second call site (§ `classNestedClassTdJoinsPkgGroup50`,
`src/UhdmExporter.cpp` ~3695) keeps `overwrite1 = false`, and the package-level
clone loops in `src/ParamEmit.cpp` (~21598, ~21656) copy span and alias but
never touch the specialization at all.  Two purpose-built arms show golden does
collapse there too:

* `g16_pkganchor` — package-scope `typedef B16 #(kk16,…) pkg_id16;` anchors the
  group and a class-nested `typedef B16 #(mm16,…) t16;` joins it.  Golden binds
  BOTH to `kk16` and contains **no `mm16` typespec at all**; we emit `mm16`.
* `g17_pkgpair` — two package-scope typedefs, `zid17` and `aid17`.  Golden binds
  the group to `aa17` (the name-first member's argument); **we emit no class
  actual at either**, so the whole specialization is missing.

Both are byte-identical on the two binaries (dump diff 0 after normalising the
file-name line), so this pass neither creates nor worsens them — but it is the
same law, and it is the cheapest next cell.

**R2 — a base with no `#()` should erase its clones' arguments, and does not.**
`g6_baseplain`: the ASCII-first member is `typedef B6 t6;`.  Golden emits NO
class specialization anywhere in that group; we keep each clone's own `bbb6` /
`ccc6`.  The guard `!base->Parameters()` returns early, so the "total clone"
stops short of the empty case.  Head is `LHS: <null>`, identical on both
binaries.  (`g8_paramclass` is the same shape with a parameterized base.)

**R3 — the module's `vpiTypedef` list is missing the imported class typedef.**
This is what surfaces as the NEW head on `g9`, `g14` and `b22` the moment the
binding clears.  Golden's `module_inst work@…` lists the wildcard-imported
package's `class_typespec` among its `vpiTypedef` entries; we list only the
`import_typespec`.  A missing REACHABLE object is comparable, so this is the
residue most likely to become a corpus head next.  Pre-existing: it is present
in the pristine dumps too, merely masked.

**R4 — golden's extra per-group `type_parameter`** carrying the generic's own
default (`uvm_object` / `uvm_component`; `baseb` in b22; `int` in `uvm54/a1`).
Measured here at **60 of SeqDriver's 171 keys and 10 of MiniAmiq's**: under
strict set EQUALITY every group cell scores wrong on BOTH binaries, which is
why `v112cen.py` scores the binding by CONTAINMENT and says so in its header.
Confirms the implementer's residue (2) and quantifies it.

**R5 — the macro-stringification span** (uvm104) and **R6 — the base's
synthesized `vpiFullName`** (a parenting residue).  Neither is read by any
generated `Compare`.  R6 is what produces the `ONLY` rows in every census here
and it is why `score112.py`, which keys on that fullname, cannot see the base
cell; `v112cen.py` inherits the same limit and reports those keys explicitly
rather than silently dropping them.

---

## 6. Corrections to the implementer's write-up

1. **`byteverify` MOVERS is 4 CONTENT movers, not "4 / 956" as an invariant.**
   Scoreboard/default flipped its coin in my run; the honest statement is
   "4 content movers, plus the Scoreboard coin when it lands", attributed
   order-blind.
2. **The `sorted=0` directories are NOT byte-stable under hand re-runs.**
   The same binary produces different bytes twice; the multiset is what is
   stable.  Conclusion unchanged, evidence corrected.
3. **The committed boundary counts include the implementer's own Surelog
   scratch.**  Clean-tree figures are 3469 / 12 and 1505 / 12.
4. **README §1's "ours is 21"** is the span of the *driver's own* expansion,
   not of the head's RHS, whose span is `468:35-468:59` (24).  Span is not
   compared; noted only so a future reader does not chase the arithmetic.
5. `pred112.py`'s own stated blind spot (moves where both sides carry the same
   name, as in `a10`) is real and correctly disclosed; `v112cen.py` shares it.
   The corpus-wide authority is `byteverify`, and it is sufficient.

None of these changes the verdict.

---

## 7. Files

* `run_v112.sh` — arm driver: golden + pristine + patched, both views, rc per
  cell, judged by the OFFICIAL `uhdm-cmp`.
* `v112cen.py` — owner-keyed, span-free, order-blind census with a
  Compare-visible payload `(typespec KIND, typespec NAME)`; handles UNNAMED
  builtin actuals (keying on parenthesised names alone made the `uvm54/a1`
  cells invisible); scores by containment because of R4.
* `grid/g1…g19` + `sub7/` — the adversarial arms above (18 sources, 20 runs:
  `sub7` is compiled twice with the use-files in opposite command-line order).
