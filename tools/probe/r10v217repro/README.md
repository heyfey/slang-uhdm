# r10v217 — adversarial verification of r10uvm217 (`§ transitiveImportRidesTheHoist217`)

**VERDICT: ACCEPT-WITH-FIX.** Ship `/tmp/r10uvm217.verified.patch`.

Every headline number in the implementer's report reproduces bit-for-bit on
binaries this verifier built itself (§ 1). The decoded law is right and the
grid backs it. But the submitted patch **loses on legal SystemVerilog that the
pristine `48199935` binary gets exactly right**: a pair of packages that
wildcard-import each other. That is fixed here (§ 3), together with a second,
golden-measured face the patch's own comment claims to handle and does not —
the diamond (§ 4). Both fixes live in the same file the pass already touches,
`src/EmitHelpers.h`, **+72 / −3** on top of the submitted patch, and are
**byte-invisible on both corpora**.

Binaries (all built by this verifier from a FRESH `48199935` worktree,
`cmake -j 2`, md5 taken separately):

| binary | md5 | size |
|---|---|---|
| PRISTINE `48199935` | `967765e2f329aadd3dc15abdb9543676` | 22 589 784 |
| `r10uvm217.patch` as submitted | `f70773944aedb3a96fbb0bc1120c4939` | 22 588 304 |
| `r10uvm217.verified.patch` | `88939f849650eef73a9126345d4a2373` | 22 593 896 |

The first two md5s are **exactly the implementer's**, so this is the same code
they measured, not a lookalike.

---

## 1. Reproduced, bit-for-bit

`/tmp/r10uvm217.patch` (509 480 bytes, md5 `994e79258c47a1baa16a35147584676f`)
applies clean on a fresh `48199935`; production surface is `src/EmitHelpers.h`
ONLY; `results/*.csv` untouched; the four slang-fenced names appear in no
driver (`canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`).

| claim | reproduced |
|---|---|
| goldens | **23/0 on all three binaries**, `SLANG_UHDM=/bin/false` **0/23** |
| u2r | **679/50/2** testflags AND default, on all three binaries; `ct8rows` PASS vs the committed baseline and pris-vs-pat and pat-vs-fix; byteverify **0/1358** in both directions (SELFCHECK 1357/1358); 1462 `cmds.txt` per sweep, **one** distinct binary path each, and it is this verifier's frozen binary |
| surelog rows | **475/6 default + 469/6 testflags** on both of the implementer's binaries — **no row converted** |
| heads | SeqDriver ×2 **1327330/1 → 32/1**; MiniAmiq ×2 838/1 unchanged; SimpleUVM ×2, Scoreboard/default, BuildUVMPkg ×2, Earlgrey ×2, Rggen/default all **0 cmp lines / 0 heads at judge rc = 0 on both binaries** |
| the 33, by identity | golden's def-view `work@top_tb` net vector is **224**; `golden[0:33]` is face-for-face equal to `golden[33:66]` (verified here independently); pristine 191 = 33 + 158, patched 224. Elaborated `Variables()`: golden **66**, pristine **33**, patched **66** |
| SeqDriver listing census | AGREE **140 → 206**, ONLY-GOLDEN **66 → 0**, ONLY-OURS **0 → 0**, CALIB null |
| byte movers, surelog | **SeqDriver default + testflags**, exactly as predicted — plus **Scoreboard/default**, which is the recorded ~50/50 coin: raw dump diff 92 lines, **order-blind diff 0 lines**. SeqDriver: **ADDED 1267 / REMOVED 0** per mode, identical line sets across modes, `33 × \|vpiNet:` and `33 × \|vpiVariables:` |
| protected DBs | 20/20 **SAME**, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, 0 NOFILE |
| canaries | u2r ok=8 changed=0; `ctcan2` PASS ×2 |
| wide boundary | **LISTED 5526 = PROCESSED 5526, RC_DIFFS 0, MOVED_ARMS 39**, `g217_f_muststay.sv` correctly absent |
| ARMSCORE over the 39 | **78 arm-views, NOT-SCORED 0, CALIB non-null 0, TO-GOLDEN 72 / unchanged 6 / AWAY 0**; AGREE **686 → 1460**, ONLY-GOLDEN **684 → 232**, ONLY-OURS **4 → 4**; and no arm-view got worse in ANY component |
| the FLOOR by name | `r10uvm203repro` 0, `r10uvm206repro` 0, `r10uvm215repro` 0, sd8–12 0; `r10uvm209repro` 1 = `grid209/g209_f_pkgpkg.sv`; uvm82–91 1 = `r10uvm88repro/g88_a1_scope.sv`; buvm3–15 2 = `r10buvm13repro/{a4_clone13,v3_clone13}.sv` |
| NAMEBAG over the boundary's 78 | name-only one-sided-OURS **6 → 6**, **0 arm-views gained a name** |
| the § 2 correction to r10uvm203's R4 | **CONFIRMED independently.** `nets::Compare` (generated `nets.cpp`) contains `lhs->VpiName().compare(rhs->VpiName())`, and `logic_net::Compare`'s first statement is `if (!context->m_visited.insert(this).second) return r;` |
| R0 | golden `work@top_tb.top_tb` (`testbench.sv:234:24`) vs ours `work@top_tb.this`, one `logic_net` pair, 32 cmp lines, one head |

**One number does NOT reproduce, and it is a flake, not a mover.** The report
says "`ct8rows` patched-vs-committed-baseline = 0 differing rows over 1588". In
this verifier's run it is **1 differing ROW**: `Earlgrey_0_1,testflags`, status
`CMP_EQUAL` on both sides, **informational dump column only**, `differ` in the
committed baseline and in this verifier's pristine sweep, empty in the patched
one — the opposite direction from the implementer's run, which is what a flake
looks like. Proof it is not the emitter: the two databases are **byte-identical**
(`md5 92bf7b7facdcf4fca15d5710960e8c64` under both binaries, both modes), and
`Earlgrey_0_1` is not a byte mover. This is the pass's own R4 and it flips on
either binary; the master should expect the row-side either way.

---

## 2. What the law gets right, on this verifier's own arms

Seven new arms (`arms/`), each scored against ONE REAL Surelog golden in BOTH
views by the position-keyed listing census, golden-vs-golden CALIBRATION first,
every rc recorded. `arms/v217_f_fileunit.sv` originally carried a
`package p; import p::*;` shape; slang rejects it (`error: package cannot import
itself`), so that shape is documented in the arm rather than measured — an arm
whose compile fails teaches error recovery.

| arm | face | pristine → r10uvm217 |
|---|---|---|
| `v217_b_muststay` | leaf package, direct-only importer, orphan package, no-import module | AGREE 13, ONLY-GOLDEN 0 — **cell-for-cell IDENTICAL on both binaries. Nothing over-hoists.** |
| `v217_c_contested` | the same name in two packages across the hop; a name shadowed by the importer | AGREE **15 → 35**, ONLY-GOLDEN **12 → 0** — **CLOSED** |
| `v217_f_fileunit` | file-unit import (×2 copies) of a chain; two roads to one package | ONLY-GOLDEN **40 → 6** |
| `v217_e_lifetime` | § 209 lifetimes on a transitive copy: a written `static` and an automatic local hoisted out of an out-of-body ctor, in a package reached only transitively | ONLY-GOLDEN **11 → 1**; the `static`/automatic bits ride correctly |
| `v217_d_fence` | § 203's shape fence at the transitive hop: packed struct, unpacked struct, fixed unpacked array, dyn/queue/assoc | the fence behaves at the hop **exactly as it does at a direct import** — the same two shapes are dropped, the same faces are wrong, on both binaries |
| `v217_a_diamond` | root diamond, mid diamond, deep chain over a diamond | ONLY-GOLDEN **35 → 13** — improved but **NOT closed**, see § 4 |
| `v217_g_cycle` | mutual package imports | **REGRESSION**, see § 3 |

---

## 3. THE REGRESSION — a cycle edge hoists a name golden does not have

`arms/v217_g_cycle.sv` (measurements verbatim in `CYCLE.r10v217.txt`):

```systemverilog
package pz1;  import pz2::*;  int z1_v;  endpackage
package pz2;  import pz1::*;  int z2_v;  endpackage
module  mz;   import pz1::*;  logic mz_clk;  endmodule
```

Legal SV: slang exits **0**, Surelog reports **0 errors / 0 fatals**.

| `module mz` | def-view `Nets()` | elaborated `Variables()` |
|---|---|---|
| **GOLDEN** | `[z1_v, mz_clk]` (2) | `[z1_v, mz_clk]` (2) |
| PRISTINE `48199935` | `[z1_v, mz_clk]` (2) — **exactly golden** | `[z1_v, mz_clk]` (2) — **exactly golden** |
| `r10uvm217.patch` | `[z2_v, z1_v, mz_clk]` (3) — **`z2_v` is a name golden does not hoist** | `[z2_v, z1_v, mz_clk]` (3) |
| **`.verified.patch`** | `[z1_v, mz_clk]` (2) — **golden restored** | `[z1_v, mz_clk]` (2) |

**Why golden looks like that.** Surelog's `CompileHelper::importPackage`
(`CompileHelper.cpp:182-188`) appends the imported component's **whole signal
vector as it stands at that moment** — `for (auto& net : def->getSignals())
scope->getSignals().push_back(net);` — and packages are compiled in declaration
order. When pz1 was compiled, pz2's vector was still empty, so golden's `pz1`
lists **only** `z1_v`; by the time pz2 is compiled, pz1 is complete, so golden's
`pz2` lists `[z1_v, z2_v]`. There is no de-duplication anywhere; a `seen` set is
simply not the mechanism.

**The fix**, in `collectImportedPkgVars`: an import edge `p -> q` whose target
`q` wildcard-imports its way **back** to `p` contributes nothing. In the
first-declared direction that is exactly golden; in the other direction it
under-lists the way the pre-217 code already did, so **it can never invent a
name**. On an acyclic import graph — every arm in `tools/probe` and every
database in both corpora — the predicate is false everywhere and the rule is a
no-op, which the gates in § 5 confirm.

The implementer's gate could not have caught this: their NAMEBAG name-gate is
sound and reads 0 gained names, but no arm in the committed tree contains a
package import cycle. The arm is added here.

**A three-package cycle, four importers** (`arms/v217_h_cycle3.sv`,
`CYCLE3.r10v217.txt`; `qa -> qc -> qb -> qa`, Surelog rc 0 / `[ERROR] : 0`, all
three binaries rc 0) confirms the declaration-order model outright — golden is
`vec[qa]=[qa_v]`, `vec[qb]=[qa_v,qb_v]`, `vec[qc]=[qa_v,qb_v,qc_v]`, and the
four modules read `[qa_v]`, `[qa_v,qb_v]`, `[qa_v,qb_v,qc_v]`,
`[qa_v,qa_v,qb_v]` plus their own clock:

| module | GOLDEN | PRISTINE | r10uvm217 | `.verified` |
|---|---|---|---|---|
| `m3a` (imports qa) | 2 | **2 — golden** | **4: invents `qb_v` AND `qc_v`** | **2 — golden** |
| `m3b` | 3 | 2 | 4: invents `qc_v` | 2 |
| `m3c` | 4 | 2 | 4 (accidentally golden) | 2 |
| `mboth` (imports qa AND qb) | 4 | 3 | **7: three invented entries** | 3 |

The fix gives up r10uvm217's accidental win on `m3c` to buy the hard property:
**it can only ever omit, never invent.** Closing the omission needs the
declaration-order model of R1/R2, which is a `ParamEmit.cpp` change and outside
this surface.

---

## 4. THE STATED LAW WAS NOT IMPLEMENTED — the diamond

The submitted patch's own comment says *"one `seen` set per home package keeps a
cycle (or a diamond) from cloning twice. The two listings MUST agree: a module's
copy of P is P's listing."* Measured on real goldens
(`DIAMOND.r10v217.txt`), **golden de-duplicates nothing and the two listings do
not agree**:

| | GOLDEN | `emitPackage` (both binaries) | `r10uvm217.patch`'s module copy | `.verified.patch` |
|---|---|---|---|---|
| `package pd3` (imports pd1+pd2, both import pd0) | 7 | **7** | — | — |
| `module vd_root` (imports pd3 only) | **8** `[d0_v d0_s d1_v d0_v d0_s d2_v d3_v clk]` | — | **6** (one `[d0_v d0_s]` missing) | **8 — golden exactly** |
| `module vd_mid` (imports pd6) | **6** | — | **5** | **6 — golden exactly** |
| `package pd7` (diamond one hop down) | 6 | **5** — a PRE-EXISTING `emitPackage` residue, both binaries | — | — |
| `module vd_deep` | 7 | — | 6 | 6 (now equal to `emitPackage`'s pd7) |

The cause is one line: the submitted patch builds `std::set<const
PackageSymbol*> seen217{pkg}` **once per home package**, while `emitPackage`'s
`impVars9` builds a **fresh `seen9{&pkg}` for every root-level import item**
(`ParamEmit.cpp` ~23079). The fix makes the two identical, term for term. The
same gap is visible in the implementer's OWN committed evidence:
`GRID.r10uvm217.txt` records `module_inst work@ge_diamond` at `G=8 O=6
BAG-G=2` on the patched binary, in both views — a **module** residue that the
report attributes to "`package pe3`'s own" (pe3's own residue is a separate
`G=2 O=0` **nets** cell, and pe3's **vars** listing already agrees with golden
at 7 on both binaries).

**A/B of the two patched binaries over all 13 arms × 2 views**
(`GRID.all13.pat_vs_fix.txt`; 26 arm-views, 0 NO-DATABASE, 0 nonzero rcs, CALIB
null in all 26):

| arm | r10uvm217 | .verified |
|---|---|---|
| `g217_e_shapes` (the pass's own diamond arm) | AGREE 35, ONLY-GOLDEN 9 | AGREE **45**, ONLY-GOLDEN **5** |
| `v217_a_diamond` | AGREE 41, ONLY-GOLDEN 13 | AGREE **59**, ONLY-GOLDEN **7** |
| `v217_f_fileunit` | AGREE 63, ONLY-GOLDEN 6, POSDIFF 4 | AGREE **71**, ONLY-GOLDEN **2**, POSDIFF **0** |
| `v217_g_cycle` | AGREE 2, ONLY-**OURS** 3 | AGREE **6**, ONLY-OURS **1** |
| `g217_a_hops`, `g217_b_views`, `g217_c_kinds`, `g217_d_importer`, `g217_f_muststay`, `v217_b_muststay`, `v217_c_contested`, `v217_d_fence`, `v217_e_lifetime` | — | **cell-for-cell identical** |

**No cell in any arm-view got worse, and ONLY-OURS never grew.**

---

## 5. Gates on `.verified.patch`

| gate | result |
|---|---|
| build | clean at `-j 2`, 0 errors; md5 `88939f849650eef73a9126345d4a2373` taken separately |
| goldens | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0/23** |
| u2r | **679/50/2** both modes; `ct8rows` **PASS** vs the committed baseline AND vs the r10uvm217 sweep in both modes; byteverify vs r10uvm217 **MOVERS 0 / 1358** (SELFCHECK 1357/1358); 1462 `cmds.txt`, one distinct path, and it is the frozen fixed binary |
| surelog | **475/6 default + 469/6 testflags — no row converted.** `ct8rows` vs the committed `results/golden_surelog.csv`: **0 differing ROWS over 1588 — PASS**; vs this verifier's pristine sweep: **0 differing rows**. 1573 `cmds.txt`, one distinct path |
| surelog byte movers | **1 / 956 vs the r10uvm217 sweep — `Scoreboard/default` only**, and its order-blind dump diff is **0 lines** (raw 170): the recorded coin. **SeqDriver's databases are BYTE-IDENTICAL** between the r10uvm217 binary and the fixed one, in both modes. vs pristine: the same 3 movers, with SeqDriver's two hashes identical to r10uvm217's and Scoreboard's being the coin again |
| heads | SeqDriver ×2 **32/1**, MiniAmiq ×2 838/1, all seven protected row-modes 0 cmp lines / 0 heads at judge rc = 0 |
| protected DBs | 20/20 **SAME**, 0 NOFILE |
| canaries | surelog **ok=52 changed=0** (the Earlgrey flake did not fire in this run), u2r **ok=8 changed=0**, `ctcan2` PASS ×2, `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` after `scrub217.sh` over every artifact here |
| boundary | **LISTED 5526 = PROCESSED 5526, RC_DIFFS 0, MOVED_ARMS 7**; scored against real goldens: **14 arm-views, NOT-SCORED 0, CALIB non-null 0, TO-GOLDEN 8 / unchanged 6 / AWAY 0**; NAMEBAG **0 → 0, 0 arm-views gained a name**. The 6 "unchanged" are the byte-only false-mover class (`g22.sv` — rc 4 on both binaries, `l154_noenum.sv`, `g185_e_kinds.sv`): identical listing censuses, and the whole difference is the 64-bit constants `22744825`/`22740729` plus the dump header, every changed line **below** the `\_weaklyReferenced:` marker. Details in `BOUNDARY.r10v217.txt` |
| the FLOOR under the fix | `r10uvm203repro` 0, `r10uvm206repro` 0, `r10uvm209repro` 0, `r10uvm215repro` 0, sd8–12 0, uvm82–91 0, buvm3–15 0 — the fix moves none of them |
| grid | § 4's A/B: only the diamond / two-roads / cycle arms move, and every one moves TOWARD golden |

The one arm the fix moves that is worth naming: `r10v124repro/v124_5_import.sv`
(`module Cell; import Echoed::*; import Origin::*;` where `Echoed` imports and
re-exports `Origin`). Golden's def-view `Cell` net vector is
`[Bench, Bench, Mirror, Bench, rt]`; the r10uvm217 binary emits
`[Bench, Mirror, Bench, rt]` — one short, the diamond again — and the fixed
binary emits **golden's five, name for name and position for position**. (The
per-face `array_typespec(Origin::Coil)` vs `short_int_typespec()` residue on
those entries is the queue/assoc typespec shape, identical at the direct hop on
all three binaries, and not this law. Surelog itself exits 4 on this arm with
`[ERROR] : 1` for the `export Origin::*`, so the rc is recorded rather than
leaned on.)

---

## 6. Residues, ranked (all measured, none asserted)

* **R0 (unchanged, and still the next law) — the implicit-wire block's ORDER.**
  SeqDriver's remaining head is a single `logic_net` pair at the last of the
  224 slots: golden `work@top_tb.top_tb` (`testbench.sv:234:24`, the
  `$dumpvars(0, top_tb)` scope-name mint) against our `work@top_tb.this`. The
  census reads `POSDIFF=158` with `BAG-ONLY-GOLDEN=0` — the implicit block is
  the same multiset in a different order, and 157 of the 158 are hidden by
  `logic_net::Compare`'s `m_visited` guard. The next law is the order in which
  `UhdmWriter::lateBinding` mints. **One object.**

* **R1 — the import clone belongs at the FRONT of a package's listing, not at
  the import item's source slot.** `CompilePackage::collectObjects_`
  (`CompilePackage.cpp:143-153`) runs `importPackage` over **every**
  `paPackage_import_item` before it walks the items. Measured here on
  `arms/v217_e_lifetime.sv`: golden's `module vl_hop` elaborated listing is
  `[l0_pre l0_auto l0_static l0_vec l0_post l1_pre l1_post l1_auto l1_static
  clk]` — pl0's whole listing FIRST, ahead of pl1's own `l1_pre`, which is
  declared BEFORE the import. Ours (both patched binaries) puts `l1_pre` first.
  Same multiset, wrong order, so the cell is `MISORDERED` — and by § 1's own
  correction (`nets::Compare` reads `VpiName`) that IS judge-visible. This now
  affects **every module copy**, not just the package listing, so it is a
  bigger residue after this pass than before it. Fixing it means fixing
  `emitPackage`'s `impVars9` and `collectImportedPkgVars` together, in one
  change, or the two listings diverge again.

* **R2 — `emitPackage` still de-duplicates one hop down, and on a cycle.**
  `package pd7` reads 6 in golden and **5** on both binaries (`impVars9`'s
  `seen9` is shared across a whole root-item subtree); `package pz1` reads
  `[z1_v]` in golden and `[z2_v, z1_v]` on all three binaries. Both are
  pre-existing, both are outside this pass's surface (`ParamEmit.cpp`), and
  both are what keeps `vd_deep` at 6/7 after the fix. The single change that
  closes R1 and R2 at once is to compute one memoised `vec[P]` per package —
  imports first, in declaration order — and have both emitters read it.

* **R3 — an EXPLICIT (single-symbol) import inside a package also rides.**
  Measured on the pass's own `g217_e_shapes.sv`: `package pe4;  import
  pe0::e0_v;` — golden's `pe4` listing is `[e0_v, e4_v]` and golden's `module
  ge_explicit` lists `[e0_v, e4_v, clk]`; ours lists `[e4_v]` / `[e4_v, clk]`
  on **all three** binaries. Not a regression, not claimed by the report's
  residue list, and one hop from this law.

* **R4 — the transitive hop MULTIPLIES the direct hop's known residues.**
  `arms/v217_d_fence.sv`: `module vf_direct` (direct import) already carries 4
  one-sided-OURS faces on the pristine binary — a packed-struct member that
  golden lists as a `struct_net` in `Nets()` and we list as a `logic_var` in
  `Variables()`, plus two `vpiAutomatic` bits on dynamic containers. After the
  patch `module vf_hop` (transitive) carries **the same 4**, which is why the
  arm's `BAG-ONLY-OURS` goes 8 → 12 and NAMEBAG reports `f0_packed` as
  "gained a name" in two arm-views. Correct behaviour for the law — the copy
  inherits the listing's residues — but it means each of those pre-existing
  residues is now worth more.

* **R5 — the INTERFACE half is still missing entirely** (§ 203 R2): the pass's
  `g217_d_importer`'s `gd_if` cell reads `1/4` on all three binaries and
  MiniAmiq's `work@svaunit_vpi_interface` is untouched.
  `collectImportedPkgVars` is called only from the module emitters
  (`ModuleEmit.cpp:771` and `:8958`).

* **R6 — `Earlgrey_0_1/testflags`'s informational dump column** flips on either
  binary between runs; the databases are byte-identical. Documented in § 1.
