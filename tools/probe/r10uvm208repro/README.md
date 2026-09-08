# r10uvm208 — § `cloneSharedArrayElemSplitMint208` — **A CLONE DECLARATION SHARING ITS ELEMENT CHAIN WITH A HOME DECLARATION GETS ITS OWN COPY, NOT A RE-POINT** — the MiniAmiq ×2 112-line head CLEARED and r10uvm205's R1 CLOSED corpus-wide

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own `FENCED=` line,
which `predict208.sh` reads at run time so this pass's artifacts never spell
them.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f3a3fcf0` |
| pristine binary | md5 `61d817dba1aa2bbe6cdd2be4e165b818`, built `-j 2` from this pass's OWN worktree at a clean `f3a3fcf0` and frozen `chmod 555` before any sweep |
| patched binary | md5 `0cd3924b8afdc086884ece90b4d3d82a`, frozen `chmod 555` |
| production surface | `src/TypeEmit.cpp` ONLY, one new block at the END of the existing `§ cloneArrayElemBareTdAlias205`, **inside its own `if (!pkgImportCloneTfs16.empty())` guard so every fence is literally the same code**. **+272 / −0 lines, one file, no header change, no new exporter state, no new flag, no new member function, no object re-pointed outside the law.** |
| probe surface | `tools/probe/r10uvm208repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **MiniAmiq default and testflags, 112 cmp lines, ONE head each** at the base commit, on the SHARED element reference `ref_typespec: (svaunit_pkg::uvm_reg_map::m_set_reg_offset::addrs::uvm_reg_addr_t)`. **CLEARED**: after the law both rows still read 112 / 1 head and the head **OBJECT** is a different one — `…m_set_mem_offset::range::uvm_pkg::uvm_reg_map_addr_range::min::uvm_reg_addr_t`, the CLASS-MEMBER kind, i.e. **the object SeqDriver ×2 already heads on**, so two rows now sit behind ONE next head. The line count is unchanged because a cmp line count is the HEAD OBJECT'S DECOMPILE SIZE (RESUME.md §7) and the successor is another use of the same 64-bit `bit_typespec`; both objects are quoted in full in `head_pris_MiniAmiq.*.cmp` / `head_pat_MiniAmiq.*.cmp`. |
| SeqDriver | head **object UNCHANGED**, before and after — it is the class-member head, which this pass does not own. SeqDriver's SIX shared cells move all the same, and were predicted BY NAME. |
| every other row's head | unchanged, both binaries — SimpleUVM 4177864 / 4178104, Scoreboard/default 95, **BuildUVMPkg ×2 0, Earlgrey_0_1 ×2 0, Rggen/default 0** (judge rc=0). |
| corpus rows changed | **0** on uhdm2rtlil (both modes, both columns, against the committed baseline AND against this pass's own pristine sweep). On surelog, over all 1588 rows, the ONLY movement is the `Earlgrey_0_1` **DUMP COLUMN**, in both directions across the two sweeps — the `uhdm-dump` timeout under sweep load that r10uvm204 and r10uvm205 both recorded. **STATUS is `CMP_EQUAL` on every one of those cells on both binaries**, neither Earlgrey database is a byte mover, and `rowheads` reads 0 lines / 0 heads for both Earlgrey modes on both binaries. **NO ROW WAS CONVERTED.** |
| the five protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `Earlgrey_0_1` ×2, `Rggen,default` — **all five CMP_EQUAL on both binaries, both columns scored explicitly (§ 7), rowheads 0/0 on both, every census mover column 0.** |
| byte movers | **4 / 956** surelog — EXACTLY the four the a-priori prediction named BY NAME from the pristine databases alone (MiniAmiq ×2, SeqDriver ×2); the ~50/50 COIN (Scoreboard/default) sat out. **0 / 1358** uhdm2rtlil. |
| the census (12 tests × 2 modes, golden-vs-golden calibrated FIRST on every scored row-mode) | SeqDriver ×2 and MiniAmiq ×2 **TO-GOLDEN 6, AWAY-GOLDEN 0, MOVED-WRONG 0, STILL-WRONG 0** — § 205's residue of six goes to **zero**. Every other measurable row-mode: every mover column **0**. 0 census keys appeared, 0 vanished, anywhere. |
| **the family is CLOSED** | the kind table over 5451 compared cells on MiniAmiq goes **`differ=6` → `differ=0`**: the row `bit_typespec chain=.elem g=BARE/BARE o=BARE/QUAL 6` disappears and the 20 already-bare clone cells become 26, while the **55 HOME `.elem` cells stay `BARE/QUAL` on BOTH sides**, untouched. |
| the grid (7 arms × 2 views, one REAL Surelog golden each, calibrated first) | **AWAY-GOLDEN 0 and MOVED-WRONG 0 in every arm in every view.** Arm **E** (the minimised corpus head) goes **112 cmp lines → 0 lines / 0 heads: the arm CONVERTS.** Arms **D** (home-only) and **F** (explicit import) are **BYTE-IDENTICAL on both binaries in both views**. |
| the a-priori prediction | `shared>0` on **exactly four row-modes over 948 scanned surelog databases**, 6 cells and 6 splits each, one typedef (`uvm_pkg::uvm_reg_addr_t`) — and on **none of the 1358** uhdm2rtlil ones. Written before the patched sweep existed. |
| the WIDE boundary (5358 arms, both views, both binaries) | `PROCESSED=5358`, `MOVED_ARMS` **10**, `RC_DIFFS` **0**. Five are this pass's OWN grid arms (the positive control). Two are earlier-pass arms that move **TOWARD golden** with AWAY 0 / MOVED-WRONG 0 and identical cmp line counts and head objects. Three are the campaign's KNOWN STATIC-ADDRESS FALSE MOVERS, re-proved here on four independent tells (§ 9). |
| **both halves of the attribution** | § 205 recorded that `uhdm-dump` does not print `vpiTypedefAlias`, so the dump is BLIND to this family's alias moves. § 208 is the first law in the family that also MINTS OBJECTS, so both halves are accounted: **OBJECT side +6 `array_typespec` and +6 `ref_typespec` per moved row-mode and NOTHING ELSE** (`ct208obj`; 54 dump lines ADDED, 0 removed, every one a minted object or its field header); **ALIAS side 6 cells TO-GOLDEN per row-mode**, census-visible only. The two halves agree on the same number: six splits. |
| goldens | 23 PASS / 0 FAIL on both binaries; `/bin/false` 23 FAIL (the negative control). |
| what the brief got RIGHT | "§ 205 refused six shared element references because re-pointing the shared object would move home cells; the law is a SPLIT-MINT giving the clone declaration its own copy." Confirmed on golden's own arity, and the one column that makes it possible — the clone declaration's OWN `ref_typespec` reads `outer=1` on all six — was measured before a line of code was written. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `f3a3fcf0` worktree, froze
it `chmod 555`, and swept both corpora with it before a line of code was
written. `check_goldens.sh` reads 23 PASS / 0 FAIL with the `/bin/false`
negative control at 23 FAIL; the surelog sweep reproduces
`results/golden_surelog.csv` row for row except one informational dump-column
cell (§ 7); both uhdm2rtlil sweeps reproduce their baselines exactly, 679/50/2.

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default        112      1
SeqDriver      testflags      112      1
SimpleUVM      default    4177864      1
SimpleUVM      testflags  4178104      1
Scoreboard     default         95      1
MiniAmiq       default        112      1
MiniAmiq       testflags      112      1
BuildUVMPkg    default          0      0   (judge rc=0)
BuildUVMPkg    testflags        0      0
Earlgrey_0_1   default          0      0
Earlgrey_0_1   testflags        0      0
Rggen          default          0      0
-- measured=12  SKIP-NOFILE=2  UNKNOWN-NAME=0
```

MiniAmiq's head (`head_pris_MiniAmiq.*.cmp`, identical in both modes) is

```
LHS: bit_typespec: (uvm_reg_addr_t), line:73:10, endln:73:31
     |vpiParent: \_ref_typespec:
        (svaunit_pkg::uvm_reg_map::m_set_reg_offset::addrs::uvm_reg_addr_t)
     |vpiName:uvm_reg_addr_t          |vpiInstance: \_package: uvm_pkg
RHS: bit_typespec: (uvm_pkg::uvm_reg_addr_t)
     |vpiName:uvm_pkg::uvm_reg_addr_t |vpiInstance: \_package: svaunit_pkg
```

— **one of the six shared element references r10uvm205 named as its R1 and
refused**, and after § 205 landed those six are the whole remaining
disagreement of this census on MiniAmiq:

```
DIFFER BY KIND x CHAIN x SHAPE:
  bit_typespec chain=.elem g=BARE/BARE/uvm_pkg o=BARE/QUAL/uvm_pkg   6
TOTAL agree=5445 differ=6 only-golden=1011 only-ours=468
```

SeqDriver's head is the CLASS-MEMBER object
(`…m_set_mem_offset::range::uvm_pkg::uvm_reg_map_addr_range::min::uvm_reg_addr_t`),
a different family; the two passes in flight do not collide at the head.

uvm-1.2 `reg/uvm_reg_map.svh:742-760` is the head's source:

```systemverilog
function void uvm_reg_map::m_set_reg_offset(uvm_reg rg,
                                            uvm_reg_addr_t offset,
                                            bit unmapped);
   ...
   begin
      uvm_reg_addr_t   addrs[];          // <-- the head's declaration
      ...
            foreach (addrs[i]) begin
               uvm_reg_addr_t addr = addrs[i];
```

a dynamic array of the package typedef declared inside a `begin` block of an
out-of-body class method and walked by `foreach`.

---

## 2. THE EDGE — GOLDEN'S IDENTITY SHAPE ON THE HEAD CELL AND ON ALL SIX

`DECODE.r10uvm208.txt` carries this in full. `ct208cen --prof` counts, per
declaration chain cell, **how many DISTINCT DECLARATIONS reach each object on
it** — the declaration's own `ref_typespec` (`outer`), the `array_typespec`
(`arr`), the element `ref_typespec` (`elemref`), the element `typespec`
(`elemts`). Producer-private pointers are used only to compute those counts and
the co-owner sets; **no pointer is ever printed and never keyed on.**

MiniAmiq/default, the six cells, GOLDEN first:

```
GOLD  Xinit_address_mapX      d4 addrs@1603:23       outer=1 arr=1 elemref=1 elemts=1  [uvm_reg_addr_t -> uvm_reg_addr_t]
GOLD  do_bus_read             d1 addrs@1983:18       outer=1 arr=1 elemref=1 elemts=1  [uvm_reg_addr_t -> uvm_reg_addr_t]
GOLD  do_bus_write            d1 addrs@1839:22       outer=1 arr=1 elemref=1 elemts=1  [uvm_reg_addr_t -> uvm_reg_addr_t]
GOLD  get_physical_addresses  d1 local_addr@1408:20  outer=1 arr=1 elemref=1 elemts=1  [uvm_reg_addr_t -> uvm_reg_addr_t]
GOLD  get_physical_addresses  d2 sys_addr@1472:23    outer=1 arr=1 elemref=1 elemts=1  [uvm_reg_addr_t -> uvm_reg_addr_t]
GOLD  m_set_reg_offset        d2 addrs@758:24        outer=1 arr=1 elemref=1 elemts=1  [uvm_reg_addr_t -> uvm_reg_addr_t]

OURS  Xinit_address_mapX      d4 addrs@1603:23       outer=1 arr=2 elemref=2 elemts=4
OURS  do_bus_read             d1 addrs@1983:18       outer=1 arr=4 elemref=4 elemts=8
OURS  do_bus_write            d1 addrs@1839:22       outer=1 arr=4 elemref=4 elemts=8
OURS  get_physical_addresses  d1 local_addr@1408:20  outer=1 arr=6 elemref=6 elemts=12
OURS  get_physical_addresses  d2 sys_addr@1472:23    outer=1 arr=2 elemref=2 elemts=4
OURS  m_set_reg_offset        d2 addrs@758:24        outer=1 arr=2 elemref=2 elemts=4
```

**GOLDEN'S ARITY IS ONE CHAIN PER CLONE DECLARATION on every one of the six —
`arr=1 elemref=1`, alias BARE. So the answer to "two objects or one" is TWO on
golden's side: a clone-own chain and a separate home chain. Ours is ONE object
doing both jobs, and it can only carry one name.**

The `own=` column names the co-owners of the widest one, in producer-neutral
declaration keys:

```
TOP[1] uvm_pkg | uvm_reg_map | get_physical_addresses | d3 | var | local_addr@1483:16
TOP[1] uvm_pkg | uvm_reg_map | get_physical_addresses | d4 | var | local_addr@1433:22
TOP[1] uvm_pkg | uvm_reg_map | get_physical_addresses | d4 | var | local_addr@1438:22
TOP[1] uvm_pkg | uvm_reg_map | get_physical_addresses | d4 | var | local_addr@1444:22
TOP[1] uvm_pkg | uvm_reg_map | get_physical_addresses | d4 | var | local_addr@1449:22
TOP[2] svaunit_pkg | - | uvm_reg_map::get_physical_addresses | d1 | var | local_addr@1408:20
```

Five HOME declarations in `uvm_pkg` and one clone declaration in `svaunit_pkg`,
one object between them. Those five home cells read QUALIFIED on **both** sides
and are the must-stay floor — which is exactly why § 205 refused the re-point.

**AND THE COLUMN THAT MAKES THE SPLIT POSSIBLE: `outer=1` ON ALL SIX.** The
clone declaration's OWN `ref_typespec` is unshared, so it can be handed a
different chain without touching any home declaration's binding. That was
measured before any code was written.

**THE KIND TABLE** (`KINDTABLE.r10uvm208.txt`, MiniAmiq/default, every cell of
every declaration chain, both writers), `.elem` rows:

```
                                                              PRISTINE  PATCHED
bit_typespec .elem  g=BARE/BARE/uvm_pkg  o=BARE/BARE/uvm_pkg      20       26
bit_typespec .elem  g=BARE/BARE/uvm_pkg  o=BARE/QUAL/uvm_pkg       6        0   <-- CLOSED
bit_typespec .elem  g=BARE/QUAL/uvm_pkg  o=BARE/QUAL/uvm_pkg      55       55   <-- THE HOME, UNMOVED
bit_typespec .elem  g=NONAME/NOALIAS     o=NONAME/NOALIAS         16       16
int/integer  .elem  (every row agrees, both shapes)               66       66
TOTAL  agree 5445 differ 6  ->  agree 5451 differ 0
       only-golden 1011 only-ours 468 (IDENTICAL before and after)
```

---

## 3. DECODE — SURELOG: WHY GOLDEN'S ARITY IS ONE PER DECLARATION

`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:127` `importPackage()`
clones each imported subroutine into the IMPORTER at COMPILE time:

```cpp
// CompileHelper.cpp:320-325
if (inPackage) {
  ElaboratorContext elaboratorContext(&s, false, /*mute errors*/ true);
  task_func* clone =
      (task_func*)UHDM::clone_tree((any*)func, &elaboratorContext);
  sfuncs->push_back(clone);
} else {
  sfuncs->push_back(func);
}
```

and `clone_tree` is UHDM's generated **DEEP** clone. For the object at the head
of this family:

```cpp
// ~/git-repos/UHDM/build/generated/src/array_typespec.cpp:100-106
array_typespec* array_typespec::DeepClone(BaseClass* parent,
                                          CloneContext* context) const {
  array_typespec* const clone = context->m_serializer->MakeArray_typespec();
  ... DeepCopy(clone, parent, context); return clone; }
// :94-95
if (auto obj = Index_typespec()) clone->Index_typespec(obj->DeepClone(clone, context));
if (auto obj = Elem_typespec()) clone->Elem_typespec(obj->DeepClone(clone, context));
```

A **fresh `array_typespec` and a fresh `Elem_typespec` ref per cloned body** —
that is precisely golden's `arr=1 elemref=1`, and it shares no object with the
home's chain.

The NAMING rule is § 205's, unchanged: `UhdmWriter::writeDataTypes`
(`UhdmWriter.cpp:775`, applying the `p::t` prefix IN PLACE at `:787-793` while
it walks the component's OWN `datatypeMap`, called from `:994` a class, `:1189`
a package, `:1447`/`:1670` a module) never sees a clone body's objects, because
`importPackage` cloned them long before. So the clone's deep copy keeps a BARE
alias target at any depth and in any role, and the home's listing object is the
one that gets prefixed.

**Two producers, one picture: golden's clone chain is a DEEP COPY (bare); ours
is a MEMO shared with the home (qualified). The repair is not a re-point, it is
a SPLIT — give the clone declaration its own copy, exactly as `clone_tree`
does.**

---

## 4. DECODE — SLANG-UHDM: WHERE THE SHARED OBJECT ARISES, AND WHERE THE SPLIT HOOKS INTO § 205's DESCENT

Our emitter memoises the element chain **per element TYPE, not per
declaration** — which is why one `array_typespec` serves five `local_addr`
declarations at four different source lines in `uvm_pkg` AND the clone body's
`local_addr` in `svaunit_pkg`. The sharing is in the **ELABORATED** listings; in
the DEF listings the clone's chain is already clone-exclusive (§ 205's owner
mask 1), which is why § 205's re-point already carries the DEF view and § 208
changes nothing there.

The hook is the **END of § 205's own block**, inside the same
`if (!pkgImportCloneTfs16.empty())` guard, so every inherited fence is literally
the same code rather than a restatement of it:

* `declTf205` — the climb from a declaration to its innermost enclosing
  subroutine, stopping at `class_defn` / `package` / `module_inst` / `design`.
  **THE CLASS FENCE**, unchanged: a class PROPERTY is refused, exactly as
  `CloneBodyTdRebind180` refuses it.
* the `Return()` test — § 16's measured **RETURN-VARIABLE EXCEPTION**
  (r10uvm169's `g169_a_import`, r10v169's `v169_i_multi`): a clone function's
  return variable keeps the HOME's QUALIFIED target, so it counts as a NON-clone
  owner and a chain it shares can never be split.
* `pkgImportCloneTfs16` — § 194's committed **WILDCARD-ONLY** gate. An EXPLICIT
  `import p::f;` clone is left alone on purpose (§ 205's R3; arm F is
  BYTE-IDENTICAL).
* `owner205` — § 205's own mask, read to find the refs it refused (mask 3).

and the split adds **ONE guard of its own, the same exclusivity rule one link
up**:

* `outer208` — the owner mask on the **DECLARATION'S OWN** `ref_typespec`. Only
  mask 1 (clone-exclusive) may be re-pointed. `--prof` measures `outer=1` on all
  six corpus cells, so the guard admits them, and it would refuse a shape where
  a home declaration and a clone declaration shared even that link.

**WHAT IS COPIED** — every field the generated `Compare` reads, and nothing
changes but the element link:

| kind | fields the copy carries |
|---|---|
| `typespec::Compare` | VpiName, Typedef_alias, Instance |
| `array_typespec::Compare` | + VpiArrayType, Ranges, Left_expr, Right_expr, Index_typespec, Elem_typespec, Resolution_func |
| `packed_array_typespec::Compare` | + VpiVector, Ranges, Left_expr, Right_expr, Elem_typespec, Typespec, Resolution_func |
| `ref_typespec::Compare` | VpiName, VpiDefName, Actual_typespec |

**NO NAME IS WRITTEN.** The element link is re-pointed onto the copy
`cloneCopyOf` **already** mints for § 205's own re-points — which the object
accounting confirms: **zero** new `bit_typespec` on every moved row, only the
six array shells and the six element refs.

**MINT ORDER IS CONTENT ORDER, NEVER ARENA ORDER.** Candidates are sorted on
(package, class, subroutine, block depth, role, name@line:col, kind) before a
single object is made, and **a candidate whose content key REPEATS is refused
outright** rather than ordered by arena position. Three independent runs of the
patched binary on MiniAmiq/default's own command line into the same output path
produce a byte-identical database (`a0cb3060f486d00fda574822bca45781` ×3).

### Why not the two other shapes of fix (both refuted on measurement)

* **Re-point the shared ref anyway.** That is what § 205 refused, and the `own=`
  column above is the reason: five HOME cells hang off the same object and
  golden keeps every one QUALIFIED. Arm D (home only, no clone anywhere) is
  BYTE-IDENTICAL on both binaries in both views precisely because nothing in the
  home world is touched.
* **Stop memoising — mint one chain per declaration everywhere, as golden
  does.** Out of scope by measurement, not taste: it would re-mint the HOME
  chains too, changing thousands of objects on every corpus row for a difference
  **no generated `Compare` reads** (none reads `VpiParent`, and the shells agree
  in every compared field). § 205's R4 recorded the same asymmetry and left it
  standing. The split changes exactly the six chains the judge scores: +6
  `array_typespec` and +6 `ref_typespec` per moved row-mode, measured.

---

## 5. THE LAW

```
§ cloneSharedArrayElemSplitMint208
    Where § cloneArrayElemBareTdAlias205 REFUSED an array element reference
    because a HOME declaration reaches it too, the clone DECLARATION is given
    its OWN copy of the chain instead: a fresh array-shaped typespec carrying
    every compared field of the shared one, and a fresh element ref bound to
    the clone copy § 16's `cloneCopyOf` already mints.  The declaration's own
    ref is re-pointed at the fresh chain; THE SHARED OBJECT, AND WITH IT EVERY
    HOME CELL, IS LEFT EXACTLY AS IT WAS.

    Golden's arity is the spec: `clone_tree` DEEP-clones an imported body, so
    golden holds one chain per clone declaration (`arr=1 elemref=1`, alias
    BARE) beside the home's shared, qualified one.

    THE EXCLUSIVITY GUARD, one link up.  Only a declaration whose OWN
    `ref_typespec` is clone-exclusive may be re-pointed.
    THE DETERMINISM GUARD.  A candidate whose content key is not unique is
    refused, so the mint order can never fall back on arena order.
```

---

## 6. THE CORPUS CENSUS — 12 TESTS × 2 MODES, GOLDEN-VS-GOLDEN CALIBRATED FIRST

`CENSUS.r10uvm208.txt` in full, with all 24 moved cells named. Every scored
row-mode's calibration (the same golden on both sides) reads TO-GOLDEN 0 /
AWAY-GOLDEN 0 / MOVED-WRONG 0 / STILL-WRONG 0 before any score is believed.

| row-mode | TO-GOLDEN | AWAY | MOVED-WRONG | STILL-WRONG | AGREE |
|---|---|---|---|---|---|
| SeqDriver default | **6** | 0 | 0 | **0** | 5275 |
| SeqDriver testflags | **6** | 0 | 0 | **0** | 5275 |
| MiniAmiq default | **6** | 0 | 0 | **0** | 5445 |
| MiniAmiq testflags | **6** | 0 | 0 | **0** | 5445 |
| SimpleUVM ×2 | 0 | 0 | 0 | 0 | 3789 |
| Scoreboard default | 0 | 0 | 0 | 0 | 3804 |
| **BuildUVMPkg ×2** | 0 | 0 | 0 | 0 | 3595 |
| **Earlgrey_0_1 default** | 0 | 0 | 0 | 0 | 446 |
| **Earlgrey_0_1 testflags** | 0 | 0 | 0 | 0 | 532 |
| **Rggen default** | 0 | 0 | 0 | 0 | 4 |

`Scoreboard,testflags`, `Rggen,testflags` and the ten `AmiqEth` /
`AmiqSimpleTestSuite` / `UnitAmiqEth` / `UVMNestedSeq` / `UVMSwitch` row-modes
have no golden in the cache and are reported `SKIP-NOFILE`, never silently
skipped. On every scored row-mode the number of census KEYS is identical before
and after — 0 appeared, 0 vanished.

**§ 205's residue of six goes to zero on all four law rows.** The 24 moved cells
are exactly the six § 205 named as R1, in each of the four row-modes:

```
uvm_reg_map::Xinit_address_mapX     d4 addrs@1603:23
uvm_reg_map::do_bus_read            d1 addrs@1983:18
uvm_reg_map::do_bus_write           d1 addrs@1839:22
uvm_reg_map::get_physical_addresses d1 local_addr@1408:20
uvm_reg_map::get_physical_addresses d2 sys_addr@1472:23
uvm_reg_map::m_set_reg_offset       d2 addrs@758:24
```

each going `[uvm_reg_addr_t -> uvm_pkg::uvm_reg_addr_t]` →
`[uvm_reg_addr_t -> uvm_reg_addr_t]` = golden's value.

---

## 7. THE GATES

Full battery with every number in `GATES.r10uvm208.txt`. In one line: goldens
23/0 on both binaries with the `/bin/false` control at 23 FAIL; every `cmds.txt`
in all four sweeps and all 13 grid arms audited by BINARY PATH (surelog 1523
invocations per binary, u2r 1458, grid 28 each, **0** naming the main tree or
the other binary); uhdm2rtlil 679/50/2 in both modes with `ct8rows` 0 differing
rows against the committed baseline AND against this pass's own pristine sweep;
surelog 473/8 + 468/7 identical on both binaries with `ct8rows` reporting only
the `Earlgrey_0_1` dump-column flake; `byteverify SELFCHECK=1` 4/956 surelog and
0/1358 uhdm2rtlil, every mover named and attributed on BOTH halves; canaries
`ok=50 changed=2` surelog (the two changed cells ARE the Earlgrey dump-column
flake) and `ok=8 changed=0` uhdm2rtlil; `ctcan2` PASS on both corpora;
`canaudit` PASS (audited=29, UNCOVERED=0, FENCE-BREACH=0); SVSwitch
`4842211c4030` and YosysVerx `6ccda350c24a` **PINS HELD**; InterfaceModPort,
BlackParrotComplex and YosysOldOr byte-identical in both modes.

**The five protected CMP_EQUAL row-modes, both columns, scored explicitly:**

```
                          committed baseline    pristine              patched
BuildUVMPkg,default       CMP_EQUAL,,,differ    CMP_EQUAL,,,differ    CMP_EQUAL,,,differ
BuildUVMPkg,testflags     CMP_EQUAL,,,differ    CMP_EQUAL,,,differ    CMP_EQUAL,,,differ
Earlgrey_0_1,default      CMP_EQUAL,,,          CMP_EQUAL,,,          CMP_EQUAL,,,differ
Earlgrey_0_1,testflags    CMP_EQUAL,,,differ    CMP_EQUAL,,,          CMP_EQUAL,,,differ
Rggen,default             CMP_EQUAL,,,differ    CMP_EQUAL,,,differ    CMP_EQUAL,,,differ
```

All five stay `CMP_EQUAL`. The only movement in those ten cells is the
`Earlgrey_0_1` DUMP COLUMN, and it moves in BOTH directions across this pass's
two sweeps — the `uhdm-dump` timeout under sweep load r10uvm204 and r10uvm205
both recorded. Independently: neither Earlgrey database is one of the four byte
movers, and `rowheads` reads 0 lines / 0 heads (judge rc=0) for both Earlgrey
modes on both binaries. **NO ROW WAS CONVERTED IN EITHER DIRECTION.**

---

## 8. THE GRID — 7 arms × 2 views, one REAL Surelog golden each

`grid208.sh` builds the golden and BOTH binaries' databases in BOTH views,
echoes every command AND ITS BINARY PATH into `cmds.txt`, records every rc (an
rc=139 segfault must never read as a result) and NAMES a missing database. Full
output: `GRIDS.r10uvm208.txt`. Golden-vs-golden calibration ran first in every
arm in every view and read 0 in every column. No nonzero rc anywhere.

| arm | what it decides | def view | elab view |
|---|---|---|---|
| **A** `g208_a_faces` | THE SIX FACES — a `foreach`-walked array of a package typedef at every context the six occupy (subroutine level, `begin`, loop body, `foreach` body, nested `begin` inside a `foreach`, a second home body of the same type), with a second scalar kind alongside so a wrong kind cannot ride along | TO-GOLDEN 7, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 | TO-GOLDEN 10, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 |
| **B** `g208_b_twoclone` | TWO CLONES of the same body — and a body the home never `foreach`es, whose chain the two clones share ALONE. The first must split (mask 3), the second must NOT (mask 1 is § 205's re-point, not this law's) | TO-GOLDEN 1, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 | TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 |
| **C** `g208_c_three` | THREE IMPORTERS plus a home-side `foreach` — the widest sharing the corpus has an analogue of | TO-GOLDEN 1, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 | TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 |
| **D** `g208_d_home` | THE HOME-ONLY CONTROL — the declaring package with a module importing it directly, so no clone exists and no mask can read 1 | **BYTE-IDENTICAL** on both binaries; all 26 def / 40 elab cells AGREE | **BYTE-IDENTICAL** |
| **E** `g208_e_head` | THE MINIMISED CORPUS HEAD — a 64-bit package typedef, one class with an out-of-body method whose block-local is that array walked by `foreach`, one wildcard importer. Pristine head is `ref_typespec: (p208b_e::M208::m_set_reg_offset208::addrs208::uvm_reg_addr208_t)` at **112 cmp lines / 1 head**, the corpus head's exact shape AND exact line count | pristine 112 → patched **0 lines / 0 heads: CONVERTS**; TO-GOLDEN 1, AWAY 0, MW 0, SW 0 | pristine 112 → patched **0 / 0: CONVERTS**; TO-GOLDEN 1, AWAY 0, MW 0, SW 0 |
| **F** `g208_f_explicit` | THE EXPLICIT-IMPORT CONTROL, § 194's committed wildcard-only fence (§ 205's R3, left standing on purpose) | **BYTE-IDENTICAL**; STILL-WRONG 8 unchanged | **BYTE-IDENTICAL**; STILL-WRONG 12 unchanged |
| **G** `g208_g_fences` | THE THREE INHERITED FENCES beside a positive control in one file: class property, function RETURN variable, and a typedef'd-array-return declaration | TO-GOLDEN 1, AWAY 0, MW 0, STILL-WRONG 2 | TO-GOLDEN 2, AWAY 0, MW 0, STILL-WRONG 4 |

Arm G's STILL-WRONG cells are `got208`, a variable of a **typedef'd array
type** whose element typespec our emitter leaves unnamed and unaliased
(`('bit_typespec','','-')` against golden's `('bit_typespec','bt208','bt208')`)
— that is § 205's **R2**, reproduced here and correctly refused by both laws;
`listingOf` returns null there. The function RETURN variable's own cells and
its `body208` local's cells are **identical between the two binaries**, so the
r10uvm169 exception holds under the split.

### Arm E — the head arm, before and after

```
PRISTINE, elab:  112 cmp lines, 1 head
  LHS: bit_typespec: (uvm_reg_addr208_t)
       |vpiParent: \_ref_typespec:
          (p208b_e::M208::m_set_reg_offset208::addrs208::uvm_reg_addr208_t)
       |vpiName:uvm_reg_addr208_t   |vpiInstance: \_package: p208a_e
  RHS: bit_typespec: (p208a_e::uvm_reg_addr208_t)
       |vpiName:p208a_e::uvm_reg_addr208_t  |vpiInstance: \_package: p208b_e

PATCHED, elab and def:  0 cmp lines, 0 heads, judge rc=0.  CMP_EQUAL.
```

---

## 9. THE WIDE BOUNDARY — 5358 arms, both views, both binaries

`BOUNDARY.r10uvm208.txt` in full.
`LISTED=5358 PROCESSED=5358 PRODUCED_DBS=5173 MOVED_ARMS=10 RC_DIFFS=0`.

* **FIVE** are this pass's own grid arms — the POSITIVE CONTROL. A gate that
  reported zero over them could not see. (Arms D and F are byte-identical and
  correctly do not appear.)
* **TWO** are earlier-pass arms that move because they are the shapes this law
  closes, each re-measured against a REAL Surelog golden in both views with the
  calibration first:
  `r10uvm205repro/grid205/g205_c_share.sv` (§ 205's own reproduction of R1) —
  TO-GOLDEN 1 def / 2 elab, AWAY 0, MOVED-WRONG 0, **STILL-WRONG 1/2 → 0/0**,
  cmp lines and head objects IDENTICAL, +1 array_typespec +1 ref_typespec per
  view; and `r10v205repro/grid/v205_l_reuse.sv` (the § 205 verifier's reuse arm)
  — TO-GOLDEN 2 def / 4 elab, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0, cmp lines
  and head objects IDENTICAL, +2/+2 per view.
* **THREE** are the campaign's known STATIC-ADDRESS FALSE MOVERS
  (`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
  `r10uvm185repro/grid185/g185_e_kinds.sv`). This pass **re-proves** that
  identification on four independent tells rather than asserting it:
  the OFFICIAL `uhdm-cmp` output is **byte-identical** between the two binaries
  in both views (3438/3438, 17/17, 92/92 — same head object, same every line);
  `ct208obj` reports **no object-count change of any kind**, so the law never
  fired on them; the census reads TO-GOLDEN 0 / AWAY 0 / MOVED-WRONG 0 with an
  unchanged STILL-WRONG; and each binary is deterministic on its own (three runs
  each, one md5). The one differing thing is a single constant,
  `|UINT:22671097` → `|UINT:22683385`, **delta 12288 = exactly three 4096-byte
  pages**, while the patched binary is 16576 bytes larger. `l154_noenum.sv` is
  the campaign's own committed LAYOUT PROOF source and says so in its header.

Every protected family reads 0 movers: § 204, § 202, § 198, § 194, § 193,
§ 190, § 180, § 169, § 16, **earl122 (the fresh conversion)**, earl121,
uvm82-91 (133 arms), buvm3-15, sd8-12 (464 arms, subdirectories included).

---

## 10. RESIDUES

* **R0 — THE NEXT HEAD for MiniAmiq ×2 is now the CLASS-MEMBER kind**, the same
  object SeqDriver ×2 already heads on:
  `ref_typespec: (<importer>::uvm_reg_map::m_set_mem_offset::range::uvm_pkg::uvm_reg_map_addr_range::min::uvm_reg_addr_t)`
  — a `class_typespec` between the ref and the subroutine, which
  `CloneBodyTdRebind180`'s climb refuses on purpose. **Two rows now sit behind
  ONE next head**, which is r10uvm205's own R0 and the head r10uvm207 was
  dispatched on. Decide FIRST, on a golden grid, whether golden bares a
  clone-reached class member in general or only when the member's class is
  itself imported; RESUME.md §9's warning that naming is CONTEXT-DEPENDENT and a
  uniform requalification is a known dead end applies.
* **R1 — the UNNAMED element typespec** (§ 205's R2, unchanged). A FIXED-SIZE
  unpacked array and a typedef'd-array declaration give OUR element typespec no
  name and no alias where golden gives it the typedef. `listingOf` returns null,
  so both laws correctly refuse it. Reproduced in arm G (`got208`, 2 def / 4
  elab cells) and in § 205's arm A, unmoved on both binaries. It belongs to an
  element-typespec MINTING family.
* **R2 — the EXPLICIT-import clone** (§ 205's R3, unchanged). Golden bares a
  named import's clone chain too; `pkgImportCloneTfs16` is WILDCARD-ONLY by
  § 194's committed fence, so arm F is BYTE-IDENTICAL on both binaries and the
  residue stands on purpose.
* **R3 — golden mints per declaration, we still memoise per typedef** (§ 205's
  R4, narrowed). This law makes the clone's chain per-declaration where the
  judge scores it, and leaves the memo everywhere else. Invisible to the judge
  (no generated `Compare` reads `VpiParent`, and the shells agree in every
  compared field); arms D and F confirm it, and § 4 records why closing it
  wholesale is out of scope.
* **R4 — the INSTRUMENT FACT, extended.** § 205 recorded that `uhdm-dump` does
  not print `vpiTypedefAlias`, so the sorted whole-dump diff is blind to this
  family's ALIAS moves. § 208 adds the other half: this law MINTS OBJECTS, and
  those ARE dump-visible. Any future pass here must account for BOTH — the
  census (`ct208cen`) for the alias half, `ct208obj` and the sorted dump for the
  object half — and must expect the dump to show ONLY the minted objects and NOT
  ONE LINE of the alias change. On MiniAmiq/default that is 54 lines added, 0
  removed, against 6 alias cells the judge scores.
* **R5 — the STATIC-ADDRESS FALSE MOVER is alive and page-granular.** Three
  committed arms carry a constant that bakes a static address; it moved by
  exactly three 4096-byte pages here because the binary grew 16576 bytes. The
  four tells that identify it (byte-identical `uhdm-cmp` output, zero
  object-count change, zero census movement, per-binary determinism) are all
  cheap and are recorded in § 9 so the next operator does not re-derive them.
* **R6 — the census is stricter than the judge** (§ 205's R6, unchanged). Its
  keys carry the listing tag, class, subroutine, block depth and declaration
  span, so a shape difference reads as a one-sided key (`only-golden 1011 /
  only-ours 468` on MiniAmiq) even where the judge is satisfied. Those counts are
  IDENTICAL before and after — 0 keys appeared, 0 vanished — and the columns
  that decide a pass, AWAY-GOLDEN and MOVED-WRONG, are 0 on every row-mode and
  every arm.

---

## 11. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm208repro
g++ -O2 -std=c++17 ct208cen.cpp  -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct208cen
g++ -O2 -std=c++17 ct208pred.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct208pred
g++ -O2 -std=c++17 ct208obj.cpp  -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct208obj

# THE EDGE — golden's ARITY on the six cells (the decode of record)
/tmp/ct208cen <golden.uhdm> <ours.uhdm> --prof --name=uvm_reg_addr_t
/tmp/ct208cen <golden.uhdm> <ours.uhdm> --kinds        # the kind table
/tmp/ct208cen <golden.uhdm> <ours.uhdm> --share        # object sharing by listing
/tmp/ct208cen <golden.uhdm> <ours.uhdm> --raw          # one line per cell, for score208.py

# the grid (one real Surelog golden per arm, both views, both binaries)
for a in grid208/g208_*.sv; do
  CEN=/tmp/ct208cen bash grid208.sh "$a" <PRISTINE> <PATCHED> /tmp/w_$(basename $a .sv)
done
# and the BOUNDARY FLOOR — r10uvm205's own six arms, run verbatim by the same driver
for a in ../r10uvm205repro/grid205/g205_*.sv; do
  CEN=/tmp/ct208cen bash grid208.sh "$a" <PRISTINE> <PATCHED> /tmp/w205_$(basename $a .sv)
done

# the a-priori prediction, from a completed PRISTINE sweep workdir
PRED=/tmp/ct208pred bash predict208.sh <pristine workdir> /tmp/pred.txt

# the corpus census (golden-vs-golden calibrated first on every row-mode)
CEN=/tmp/ct208cen bash cen208.sh <pristine wd> <patched wd> /tmp/cen \
    SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg AmiqEth \
    AmiqSimpleTestSuite UnitAmiqEth UVMNestedSeq UVMSwitch Earlgrey_0_1 Rggen

# THE OBJECT HALF of the attribution (the census cannot see it; the dump can)
/tmp/ct208obj <pristine.uhdm> P > /tmp/p.txt
/tmp/ct208obj <patched.uhdm>  Q > /tmp/q.txt   # then diff the per-kind counts
# and the ALIAS HALF (the dump cannot see it; the census can)
/tmp/ct208cen <pristine.uhdm> <patched.uhdm> --arena | sort

# the WIDE boundary, from a COPY of the probe tree
PRIS=<pristine> PATCHED=<patched> bash bound208.sh <copy of tools/probe> /tmp/bound

# the guards
bash canaudit.sh canaries.sh ctcan2.sh
```
