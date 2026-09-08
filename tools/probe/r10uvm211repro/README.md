# r10uvm211 — § `cloneSharedArrayStructSplitMint211` — **A CLONE DECLARATION WHOSE ARRAY-OF-STRUCT CHAIN IS SHARED WITH A HOME DECLARATION GETS ITS OWN ARRAY, NOT A REFUSAL** — the MiniAmiq ×2 112-line head CLEARED and r10uvm207's R1′ CLOSED corpus-wide

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own `FENCED=` line,
which `predict211.sh` reads at run time so this pass's artifacts never spell
them.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `cd783019` |
| pristine binary | md5 `6fcb25434647c0559ba55ab2f1414bad`, built `-j 2` from this pass's OWN worktree at a clean `cd783019` and frozen `chmod 555` before any sweep |
| patched binary | md5 `9d12c48370243a1e55e81940230713ae`, frozen `chmod 555` |
| production surface | `src/TypeEmit.cpp` ONLY, one new block at the END of the existing `§ cloneStructMemberBareTdAlias207`, **inside its own `if (!pkgImportCloneTfs16.empty())` guard so every fence is literally the same code**. **+288 / −0 lines, one file, no header change, no new exporter state, no new flag, no new member function, no object re-pointed outside the law.** |
| probe surface | `tools/probe/r10uvm211repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head — **RE-MEASURED, not inherited** | The brief said the head OBJECT was **UNKNOWN** at `cd783019` (r10uvm208's predicted successor was refuted when the depth held through two landings), so nothing was assumed. On this pass's own pristine build, **MiniAmiq default and testflags, 112 cmp lines, ONE head each**, identical in both modes, on `ref_typespec: (svaunit_pkg::uvm_reg_map::do_bus_write::accesses::uvm_pkg::uvm_reg_bus_op::addr::uvm_reg_addr_t)` — the **ARRAY-OF-STRUCT MEMBER** kind. That is **r10uvm207's own residue R1′ verbatim**, the cells the struct law named and could not reach. **CLEARED**: both rows go **112 → 50 cmp lines, 1 head**, and the successor object is `ref_obj: (uvm_pkg::UVM_SET)` under a `param_assign` — **the same object kind and name SeqDriver ×2 already head on**, so **four rows now sit behind ONE next head**. |
| SeqDriver | head **object and line count UNCHANGED**, 50 / 1 before and after — it is the enum-fold head, which this pass does not own (the sister pass does). SeqDriver's SIX cells move all the same, and were predicted BY NAME. |
| every other row's head | unchanged, both binaries — SimpleUVM 86 ×2, Scoreboard/default 95, **BuildUVMPkg ×2 0, Earlgrey_0_1 ×2 0, Rggen/default 0** (judge rc=0). |
| corpus rows changed | **0** on uhdm2rtlil (both modes, both columns, against the committed baseline AND against this pass's own pristine sweep). On surelog, over all 1588 rows, **0 differing rows against this pass's own pristine sweep**; against the committed baseline the only movement is the `Earlgrey_0_1` **DUMP COLUMN** in both modes — the `uhdm-dump` timeout under sweep load that r10uvm204, r10uvm205 and r10uvm208 all recorded, present **identically in this pass's own pristine sweep**. **STATUS is `CMP_EQUAL` on both cells on both binaries at judge rc=0**, neither Earlgrey database is a byte mover, and `rowheads` reads 0 lines / 0 heads for both Earlgrey modes on both binaries. **NO ROW WAS CONVERTED.** |
| the five protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `Earlgrey_0_1` ×2, `Rggen,default` — **all five CMP_EQUAL on both binaries, both columns quoted verbatim (§ 7 of `GATES.r10uvm211.txt`), rowheads 0/0 on both, every census mover column 0.** |
| byte movers | **5 / 956** surelog — the FOUR the a-priori prediction named BY NAME from the pristine databases alone (MiniAmiq ×2, SeqDriver ×2), plus the ~50/50 **COIN** (Scoreboard/default), attributed ORDER-BLIND at **zero content lines** in the path-normalised sorted `uhdm-dump` diff. **0 / 1358** uhdm2rtlil. |
| the census (12 row-modes, golden-vs-golden calibrated FIRST on every scored row-mode) | SeqDriver ×2 and MiniAmiq ×2 **TO-GOLDEN 6, AWAY-GOLDEN 0, MOVED-WRONG 0, STILL-WRONG 0** — § 207's residue R1′ of six goes to **zero**. Every other measurable row-mode: every mover column **0**. 0 census keys appeared, 0 vanished, anywhere (`only-golden` 1062 and `only-ours` 472 on MiniAmiq before and after). |
| **the family is CLOSED** | the kind table on MiniAmiq goes **`differ=6` → `differ=0`**: the three rows `bit_typespec chain=.elem.mem:{addr,byte_en,data} g=BARE/BARE o=BARE/QUAL 2` disappear and the 2 already-bare clone cells per member become 4, while the **8 HOME `.elem.mem` cells per member stay `BARE/QUAL` on BOTH sides**, untouched. |
| the grid (9 arms × 2 views, one REAL Surelog golden each, calibrated first) | **AWAY-GOLDEN 0 and MOVED-WRONG 0 in every arm in every view; all 18 golden-vs-golden calibrations read 0.** Arm **A** (the minimised corpus head) goes **112 cmp lines → 37: the head CONVERTS**, and arm **B** (every declaration role) with it. Arms **D** (no import), **E** (explicit import — § 194's fence, residue on purpose), **F** (non-repairable struct), **G** (packed) and **I** (clone-to-clone sharing) are **BYTE-IDENTICAL on both binaries in both views**. |
| the a-priori prediction | `splits>0` on **exactly four row-modes over 948 scanned surelog databases**, 2 splits and 6 cells each, over exactly TWO declarations (`uvm_reg_map::do_bus_read accesses@1993:18` and `do_bus_write accesses@1850:21`) — and on **none of the 1358** uhdm2rtlil ones. Written before the patched sweep existed. |
| the WIDE boundary (5427 arms, both views, both binaries) | `PROCESSED=5427`, `PRODUCED_DBS=5242`, `MOVED_ARMS` **8**, `RC_DIFFS` **0**. Four are this pass's OWN grid arms (the positive control). One is an earlier-pass arm (`§ 207`'s own context arm, which already contained this shape) that moves **TOWARD golden**, 112 → 37 cmp lines with AWAY 0 / MOVED-WRONG 0 and all four moved cells named. Three are the campaign's KNOWN STATIC-ADDRESS FALSE MOVERS, re-proved here on four independent tells. |
| **both halves of the attribution** | § 205 recorded that `uhdm-dump` does not print `vpiTypedefAlias`, so the dump is BLIND to this family's alias moves. This law also MINTS OBJECTS, so both halves are accounted: **OBJECT side +2 `array_typespec` and +2 `ref_typespec` per moved row-mode and NOTHING ELSE** (18 dump lines ADDED, **0 removed**, every one a minted object or its field header, on all four moved row-modes); **ALIAS side 6 cells TO-GOLDEN per row-mode**, census-visible only. The two halves agree on the same number: two splits repairing three members each. |
| goldens | 23 PASS / 0 FAIL on both binaries; `/bin/false` 23 FAIL / 0 PASS (the negative control). |
| what the brief got RIGHT | "the open clone-import faces named in the § 205/207/208 residue lists are the likely candidates but the owner-finder decides." The owner-finder decided: § 207's R1′, and nothing else. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

Nothing was inherited. This pass built its own pristine binary from a clean
`cd783019` worktree, froze it `chmod 555`, and swept both corpora with it
before a line of code was written. `check_goldens.sh` reads 23 PASS / 0 FAIL
with the `/bin/false` negative control at 23 FAIL / 0 PASS; both uhdm2rtlil
sweeps reproduce their baselines exactly (679/50/2); the surelog sweep
reproduces `results/golden_surelog.csv` row for row except the informational
Earlgrey dump-column cell (§ 7).

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         50      1
SeqDriver      testflags       50      1
SimpleUVM      default         86      1
SimpleUVM      testflags       86      1
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
        (svaunit_pkg::uvm_reg_map::do_bus_write::accesses::
         uvm_pkg::uvm_reg_bus_op::addr::uvm_reg_addr_t)
     |vpiName:uvm_reg_addr_t          |vpiInstance: \_package: uvm_pkg
RHS: bit_typespec: (uvm_pkg::uvm_reg_addr_t)
     |vpiName:uvm_pkg::uvm_reg_addr_t |vpiInstance: \_package: svaunit_pkg
```

The object is the **alias target of the `addr` member of the package struct
typedef `uvm_pkg::uvm_reg_bus_op`**, reached from the WILDCARD-IMPORT CLONE body
`svaunit_pkg`'s copy of the out-of-body class method `uvm_reg_map::do_bus_write`
through its block local `uvm_reg_bus_op accesses[$]`. `typespec::Compare` walks
`Typedef_alias` before `Instance`, which is why the head is the TARGET and not
the member's own typespec — the member's own name is already bare on both sides.

That is **r10uvm207's own residue R1′, verbatim**:

> **R1′ — the SHARED ARRAY-OF-STRUCT holder (6 cells per moved row-mode).** Our
> emitter hands ONE `array_typespec` of `uvm_reg_bus_op` to a clone body's
> `accesses` declaration and to a HOME body's, in the ELABORATED listing only
> (`uvm_reg_map::do_bus_read` @1993 and `do_bus_write` @1850). Its
> `Elem_typespec` ref therefore has owner mask 3 and the law refuses it — the
> same shape as R1 one link further, and closing it needs the same array-side
> SPLIT.

uvm-1.2 is the source:

```systemverilog
// reg/uvm_reg_item.svh:255-313
typedef struct {
  uvm_access_e kind;   uvm_reg_addr_t addr;   uvm_reg_data_t data;
  int n_bits;          uvm_reg_byte_en_t byte_en;   uvm_status_e status;
} uvm_reg_bus_op;

// reg/uvm_reg_map.svh:1850 (do_bus_write) and :1993 (do_bus_read)
  uvm_reg_bus_op accesses[$];
// … walked by `foreach (accesses[i])` at :1924 and :2060
```

Three of the six members carry the § 180 repair shape (a BARE own name with a
QUALIFIED alias target): `addr`, `data`, `byte_en`. **Two declarations × three
members = the SIX cells this pass owns.**

The declaration-chain census's whole remaining disagreement on MiniAmiq at the
base is those six cells and nothing else (`ct211cen --kinds`):

```
DIFFER BY KIND x CHAIN x SHAPE:
  bit_typespec chain=.elem.mem:addr    g=BARE/BARE/uvm_pkg o=BARE/QUAL/uvm_pkg  2
  bit_typespec chain=.elem.mem:byte_en g=BARE/BARE/uvm_pkg o=BARE/QUAL/uvm_pkg  2
  bit_typespec chain=.elem.mem:data    g=BARE/BARE/uvm_pkg o=BARE/QUAL/uvm_pkg  2
TOTAL agree=5743 differ=6 only-golden=1062 only-ours=472
```

---

## 2. THE SHARING, BY IDENTITY — GOLDEN'S ARITY IS THE SPECIFICATION

`ct211own --prof` counts, for every link of a declaration's typespec chain, HOW
MANY DECLARATIONS in the whole database reach that exact object. Producer-
private addresses group objects WITHIN one database only; they are never printed
and never keyed on. MiniAmiq/default, `accesses@1850`:

```
GOLD  clone listing (svaunit_pkg, BOTH views)
    .              ref arity=1   array_typespec  arity=1
    .elem          ref arity=1   struct_typespec arity=1
    .elem.mem:addr bit_typespec arity=1  [uvm_reg_addr_t -> uvm_reg_addr_t]
GOLD  home listing (uvm_pkg, elaborated)
    .              ref arity=1   array_typespec  arity=3
    .elem          ref arity=3   struct_typespec arity=18
    .elem.mem:addr bit_typespec arity=8  [uvm_reg_addr_t -> uvm_pkg::uvm_reg_addr_t]
OURS  clone listing (svaunit_pkg, ELABORATED — the head)
    .              ref arity=1   array_typespec  arity=2
    .elem          ref arity=2   struct_typespec arity=20
    .elem.mem:addr bit_typespec  [uvm_reg_addr_t -> uvm_pkg::uvm_reg_addr_t]
OURS  clone listing (svaunit_pkg, DEF view — already repaired by § 207)
    .              ref arity=1   array_typespec  arity=1
    .elem          ref arity=1   struct_typespec arity=14 (§ 207's clone copy)
    .elem.mem:addr bit_typespec  [uvm_reg_addr_t -> uvm_reg_addr_t]
```

**Golden gives the CLONE DECLARATION its own array, its own element ref and its
own struct copy — one object per declaration, every member BARE — while the
home's cells share a different object whose members stay QUALIFIED.** We hand
ONE array to both worlds, so a RE-POINT is impossible and a SPLIT is the only
repair that can leave the home cell alone. Two columns decide it and both were
measured before a line of code was written: golden's clone arity is **1**, and
**our clone declaration's OWN `ref_typespec` reads arity 1** on both cells, which
is what makes the split possible at all.

`ct211own --who` names the co-owner, so the sharing is an identity fact and not
an inference:

```
WHO[OURS] TOP[2] svaunit_pkg | uvm_reg_map::do_bus_write | d1 | accesses@1850
  .   array_typespec  n=2
    <- TOP[1] uvm_pkg     | uvm_reg_map | do_bus_write | d4 | accesses@1924
    <- TOP[2] svaunit_pkg | uvm_reg_map::do_bus_write   | d1 | accesses@1850
```

The second owner is the **HOME body's `foreach` REFERENCE VARIABLE at :1924** —
the same shape § 205's R1 had one link down. **That fact designed the grid.** The
first cut of arm A had no `foreach`, so the clone's array was unshared, § 207
re-pointed it and the arm AGREED without ever testing the law; it was rewritten
(RESUME.md §9 — *an arm agreeing is not an arm testing*), and the rewritten arm
reproduces the corpus head exactly.

---

## 3. THE DECODE

`DECODE.r10uvm211.txt` carries it in full, with the Surelog sources read out
rather than remembered:

* `CompileHelper::importPackage` (`src/DesignCompile/CompileHelper.cpp`, the
  `task_func` loop at :300-330) **deep-copies** each imported subroutine into the
  IMPORTING scope at COMPILE time, `if (inPackage)`, with
  `UHDM::clone_tree((any*)func, &elaboratorContext)`. A deep copy is exactly
  golden's arity of 1: every declaration in the cloned body gets its own array
  typespec, its own element ref and its own struct copy.
* `UhdmWriter::writeDataTypes` (`src/DesignCompile/UhdmWriter.cpp`:775-796)
  applies the `p::t` prefix **IN PLACE** while the HOME package's own
  `datatypeMap` walk runs. The clone was made BEFORE that walk, so **nothing
  inside a clone body is ever the object that got prefixed** — at any depth and
  in any role, an array element's struct member included. The rule has not
  changed since § 16; only the link has.
* The `object_name` filter three lines above the clone is why a NAMED import is
  cloned too, and why arm E's residue stands on purpose: § 194's committed fence
  makes `pkgImportCloneTfs16` WILDCARD-ONLY.

---

## 4. THE LAW

§ `cloneSharedArrayStructSplitMint211`, one block at the **END** of the existing
§ `cloneStructMemberBareTdAlias207`, **inside its own
`if (!pkgImportCloneTfs16.empty())` guard**, so every fence is literally the same
code and the two laws share one gate:

> **A CLONE DECLARATION WHOSE ARRAY CHAIN IS SHARED WITH A HOME DECLARATION GETS
> ITS OWN ARRAY AND ITS OWN ELEMENT REFERENCE, POINTING AT THE STRUCT COPY THE
> CLONE MACHINERY ALREADY MINTS — THE SHARED ARRAY, WITH ITS QUALIFIED MEMBERS,
> IS LEFT TO THE HOME OWNER THAT ALSO HOLDS IT.**

**THE GUARDS, all of them § 207's own, restated rather than re-invented:**

* the **DECLARATION'S OWN ref must be clone-EXCLUSIVE** (`own207` mask 1) — the
  same exclusivity rule one link up, and the reason the home's cells cannot
  follow the clone's;
* the **class fence** and the **return-variable exception** are `declTf207` and
  the `Return()` test, reused verbatim (§ 16's measured exception from
  r10uvm169);
* the **wildcard gate** is the enclosing `pkgImportCloneTfs16` test;
* **only a link § 207 ITSELF refused may move** — mask EXACTLY 3 *and* present in
  `sref207` — so a link § 207 already re-pointed is never touched and the law is
  **idempotent** (arm I is the control for this);
* and one of its own: **a candidate whose CONTENT KEY is not unique is refused
  outright**, so the mint order can never fall back on arena order.

**WHAT IS COPIED.** Every field the generated `Compare` reads: `array_typespec`
— VpiArrayType, Ranges, Left_expr, Right_expr, Index_typespec, Elem_typespec,
Resolution_func, plus `typespec`'s VpiName / Typedef_alias / Instance;
`packed_array_typespec` — VpiVector, Ranges, Left_expr, Right_expr,
Elem_typespec, Typespec, Resolution_func and the same three; `ref_typespec` —
VpiName, VpiDefName, Actual_typespec. **ONLY THE ELEMENT LINK CHANGES**, and it
changes onto the struct copy § 207 already mints, so **no NAME is written
anywhere** — the recorded naming-is-context-dependent dead end is not
approached.

**MINT ORDER IS CONTENT ORDER**: candidates are sorted on (package, class,
subroutine, block depth, role, name@line:col, kind) before a single object is
made, so the ids the fresh objects take cannot depend on allocation addresses.

---

## 5. THE GOLDEN GRID — `GRIDS.r10uvm211.txt`

Nine arms, ONE REAL Surelog golden each, both views kept separate,
golden-vs-golden calibrated first in every arm and every view (**all 18
calibrations read 0**).

| ARM | what it tests | def A→B | elab A→B | bytes |
|---|---|---|---|---|
| **A** | the MINIMISED CORPUS HEAD (foreach-shared) | 37→37 | **112 → 37: CONVERTS** | DIFF |
| **B** | EVERY declaration role, each foreach-shared | 37→37 | **112 → 37: CONVERTS** | DIFF |
| **C** | HOME + CLONE side by side (the must-stay control) | 1746→1746 | 2178→2178 | DIFF |
| **D** | NO import at all (the gate never opens) | 0/0h | 0/0h | **IDENTICAL** |
| **E** | EXPLICIT (named) import — § 194's fence | 614→614 | 758→758 | **IDENTICAL** |
| **F** | array of a NON-REPAIRABLE struct | 506→506 | 650→650 | **IDENTICAL** |
| **G** | PACKED array of a PACKED struct | 38→38 | 38→38 | **IDENTICAL** |
| **H** | struct from a THIRD package the importer never imports | 1210→1210 | 1306→1306 | DIFF |
| **I** | CLONE-TO-CLONE sharing (mask 1 — § 207 still owns it) | 922→922 | 1210→1210 | **IDENTICAL** |

Scores (`score211.py`, the `.elem.mem` chain filter is this face's path):

* **A** TO-GOLDEN 2 def / 4 elab, **B** 4 / 6, **C** 4 / 8, **H** 2 / 4;
* **AWAY-GOLDEN 0 and MOVED-WRONG 0 in EVERY arm in EVERY view**;
* **E** STILL-WRONG 8 def / 16 elab — the § 194 wildcard fence, **residue on
  purpose**, and the arm is byte-identical on both binaries, which is the proof
  the fence held;
* **D, F, G, I** move nothing at all.

What the arms decide:

* **C** is the decisive one: the HOME body's own array-of-struct declaration,
  with its own `foreach`, sits beside the clone-reached one. The clone's cells go
  TO-GOLDEN and **not one home cell moves** — AWAY-GOLDEN 0 in both views. That
  is the whole difference between a split and a re-point.
* **H** answers the face's own question: golden bares a clone-reached
  array-of-struct member **even when the struct's own package is not the imported
  one**, so the law is about the **CLONE BODY**, not about which package declares
  the element's type. It is r10uvm207 arm H's finding, one link over.
* **I** is the idempotence control: two clone declarations sharing ONE array
  between themselves carry mask 1, § 207's re-point still owns them, and the
  split never fires — byte-identical on both binaries.
* **G** is honest: golden and ours produce no comparable `.elem.mem` cell for a
  packed array of a packed struct on this arm (the census reads one-sided keys
  only), so the `packed_array_typespec` branch of the mint is written and
  guarded but **is not exercised by any arm or by either corpus**. It is
  recorded as such rather than claimed as tested.

---

## 6. THE CORPUS CENSUS — `CENSUS.r10uvm211.txt`

Twelve row-modes, golden-vs-golden **calibrated first on every one of them**
(every calibration reads 0 in every column):

```
SeqDriver    default   TO-GOLDEN 6  AWAY 0  MOVED-WRONG 0  STILL-WRONG 0  AGREE 5573
SeqDriver    testflags TO-GOLDEN 6  AWAY 0  MOVED-WRONG 0  STILL-WRONG 0  AGREE 5573
MiniAmiq     default   TO-GOLDEN 6  AWAY 0  MOVED-WRONG 0  STILL-WRONG 0  AGREE 5743
MiniAmiq     testflags TO-GOLDEN 6  AWAY 0  MOVED-WRONG 0  STILL-WRONG 0  AGREE 5743
SimpleUVM    ×2        every mover column 0
Scoreboard   default   every mover column 0
BuildUVMPkg  ×2        every mover column 0
Earlgrey_0_1 ×2        every mover column 0
Rggen        default   every mover column 0
```

`only-golden` and `only-ours` are unchanged on every row-mode (MiniAmiq
1062 / 472 before and after), so **0 census keys appeared and 0 vanished
anywhere**.

**The family is CLOSED.** The kind table (`KINDTABLE.r10uvm211.txt`),
MiniAmiq/default:

```
PRISTINE  differ = 6   (.elem.mem:addr 2, .elem.mem:byte_en 2, .elem.mem:data 2)
PATCHED   differ = 0   only-golden 1062  only-ours 472  (both unchanged)
```

and the shape table shows the home side untouched — per member, the 2 clone
cells become bare (2 already-bare → 4) while the **8 HOME cells stay
`BARE/QUAL` on BOTH sides**:

```
PRISTINE  .elem.mem:addr  g=BARE/BARE o=BARE/BARE 2   g=BARE/BARE o=BARE/QUAL 2   g=BARE/QUAL o=BARE/QUAL 8
PATCHED   .elem.mem:addr  g=BARE/BARE o=BARE/BARE 4                               g=BARE/QUAL o=BARE/QUAL 8
```

**BOTH HALVES OF THE ATTRIBUTION.** r10uvm205 recorded that `uhdm-dump` does not
print `vpiTypedefAlias`, so the order-blind dump diff can only see the OBJECT
half of this family. On all four moved row-modes the dump reads **18 lines
ADDED, 0 removed**, and every added line is a minted object or its field header:

```
2 \_array_typespec: , line:1850:21, endln:1850:31
2 \_array_typespec: , line:1993:18, endln:1993:28
2 \_ref_typespec:
2 \_struct_typespec: (uvm_pkg::uvm_reg_bus_op), line:257:9, endln:313:2
2 |vpiElemTypespec:   2 |vpiActual:   2 |vpiParent:   2 |vpiRange:
1 \_range: , line:1850:30…   1 \_range: , line:1993:27…
```

— two fresh arrays and two fresh element refs per row-mode, pointing at the
struct copy that already existed. The ALIAS half is the census's 6 cells. The
two halves agree on the same number: **two splits repairing three members each.**

---

## 7. THE GATES — `GATES.r10uvm211.txt`

Full battery with every number there. In one line: goldens 23/0 on both binaries
with the `/bin/false` control at 23 FAIL; every `cmds.txt` in all four sweeps
audited BY BINARY PATH (1523 + 1523 surelog invocations, 1458 + 1458 uhdm2rtlil,
**0 main-tree**, **0 rc=139**); uhdm2rtlil 679/50/2 in both modes with `ct8rows`
0 differing rows against the committed baseline AND against this pass's own
pristine sweep, and `byteverify` **0 / 1358**; surelog 473/8 + 468/7 with
`ct8rows` **0 differing rows against this pass's own pristine sweep** and only
the informational Earlgrey dump-column cell against the committed baseline;
`byteverify` **5 / 956** = the four predicted BY NAME plus the coin, which is
attributed order-blind at **zero content lines**; `rowheads` MiniAmiq 112 → 50
with a new head object and everything else unchanged; canaries ok=52 changed=0
against this pass's own pristine and ok=8 changed=0 on uhdm2rtlil; `ctcan2` PASS
on both corpora; `canaudit` audited=29 UNCOVERED=0 **FENCE-BREACH=0**; all 10
pinned databases byte-identical, with `SVSwitch` at `4842211c4030` and
`YosysVerx` at `6ccda350c24a` — the committed pins.

---

## 8. THE WIDE BOUNDARY — `BOUNDARY.r10uvm211.txt`

`LISTED=5427 PROCESSED=5427 PRODUCED_DBS=5242 MOVED_ARMS=8 RC_DIFFS=0`.
`PROCESSED == LISTED`, so the gate reached every arm, subdirectories included;
`PRODUCED_DBS` is what convicts a green-on-nothing run. The eight movers are
attributed one by one there: four are this pass's own grid arms (the positive
control), one is § 207's own context arm moving TOWARD golden with every moved
cell named, and three are the campaign's known STATIC-ADDRESS FALSE MOVERS,
re-proved on four independent tells — byte-identical official `uhdm-cmp` output,
no object-count change, a census reading 0 in every mover column with unchanged
STILL-WRONG, and three-runs-one-md5 determinism per binary — with the single
differing constant moving by **16384 bytes = exactly four 4096-byte pages** while
the patched binary is 20840 bytes larger.

Every protected family reads 0 movers: § 208's arms and its mask, § 207's other
arms, § 205's arms and its guard, § 204, § 202 and its fence, § 198, § 194,
§ 193, § 190, § 180, § 169, § 16, earl122, earl121, uvm82-91, buvm3-15, sd8-12.

---

## 9. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct211own.cpp` | the OWNER-FINDER and ARITY PROFILE for this face: `--prof` (per-link declaration arity on both sides), `--who` (the co-owner list), `--face` (the split-vs-re-point decision table) |
| `ct211cen.cpp` | the declaration-chain census through the ARRAY and the STRUCT MEMBER (r10uvm207repro/ct207cen.cpp, unchanged in behaviour, carried here so the probe surface is self-contained) |
| `ct211pred.cpp` / `predict211.sh` | the A-PRIORI mover predictor: reads ONE pristine database and names the split set from the database alone |
| `ct211obj.cpp` | the object-side accounting instrument (per-kind object population) |
| `score211.py` | the census scorer (TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG) |
| `grid211.sh` + `grid211/` | the nine golden-grid arms and their driver |
| `cen211.sh` | the corpus census driver |
| `bound211.sh` | the wide boundary gate |
| `rowheads.sh` `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the campaign's committed gate scripts, carried unchanged |
| `head_pris_*.cmp` / `head_pat_*.cmp` | the head objects, quoted in full, before and after |
| `DECODE` `GRIDS` `CENSUS` `KINDTABLE` `BOUNDARY` `GATES` `MOVERS` `PREDICT.*` | the evidence |

---

## 10. RESIDUES

* **R0 — THE NEXT HEAD for MiniAmiq ×2 is the ENUM-FOLD kind**, and it is
  **the same object SeqDriver ×2 already heads on**:
  `ref_obj: (uvm_pkg::UVM_SET)` under a `param_assign` at line 217:31, whose
  `vpiActual` is an `operation`, where WE hold a folded `constant` `UINT:131078`
  — golden keeps the reference unfolded and we fold it. **Four rows now sit behind ONE next head** (50 cmp
  lines each), which is the head the sister pass in flight is dispatched on. The
  clone-import declaration-chain family that ran from § 16 through § 180, § 194,
  § 205, § 207 and § 208 is **CLOSED**: the kind table's `differ` column is 0.
* **R1 — the UNNAMED element typespec** (§ 205's R2 / § 208's R1, unchanged). A
  FIXED-SIZE unpacked array and a typedef'd-array declaration give OUR element
  typespec no name and no alias where golden gives it the typedef; `listingOf`
  returns null so every law in the family correctly refuses it. It belongs to an
  element-typespec MINTING family and is untouched here.
* **R2 — the EXPLICIT-import clone** (§ 205's R3, § 207's R3, § 208's R2,
  unchanged). Golden bares a named import's clone chain too, at this link as at
  every other one; `pkgImportCloneTfs16` is WILDCARD-ONLY by § 194's committed
  fence, so arm E is BYTE-IDENTICAL on both binaries with STILL-WRONG 8 def /
  16 elab and the residue stands ON PURPOSE. Three passes have now recorded it;
  it is worth a pass of its own.
* **R3 — golden mints per declaration, we still memoise.** Golden's clone struct
  copies and clone arrays are one object per DECLARATION (arity 1 everywhere);
  ours are one per struct and one per split declaration, so our clone copy reads
  arity 14 where golden reads 1. Invisible to the judge — no generated `Compare`
  reads `VpiParent`, and the shells agree in every compared field — and arms D,
  E, F, G and I confirm the asymmetry costs nothing.
* **R4 — the `packed_array_typespec` branch is UNEXERCISED.** The mint handles it
  and the guards cover it, but neither corpus nor arm G produces a comparable
  cell through a packed array of a packed struct. It is written, not tested, and
  is recorded that way rather than claimed.
* **R5 — the page-granular FALSE MOVER and its four tells**, re-proved here on
  three arms (§ 8). A named boundary arm can move on nothing but a binary that
  grew a page; zero census movement is the tell.
* **R6 — the census reads stricter than the judge.** Its keys carry the listing
  tag, the class, the subroutine, the block depth and the declaration span, so a
  shape the judge never reaches can still show as a one-sided key. `only-golden`
  and `only-ours` are reported unchanged rather than netted away.
