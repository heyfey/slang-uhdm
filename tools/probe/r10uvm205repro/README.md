# r10uvm205 — § `cloneArrayElemBareTdAlias205` — **A WILDCARD-IMPORT CLONE BODY'S ARRAY-OF-PACKAGE-TYPEDEF DECLARATION BARES ITS ELEMENT TYPESPEC'S ALIAS TOO** — the SeqDriver ×2 and MiniAmiq ×2 112-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own `FENCED=` line,
which `predict205.sh` reads at run time so this pass's artifacts never spell
them.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `450b7a24` |
| pristine binary | md5 `505cad23a156a75a6da1a3fd69b64617`, built `-j 2` from this pass's OWN worktree at a clean `450b7a24` and frozen `chmod 555` before any sweep |
| patched binary | md5 `2bd808c3610a262f520fde0d2af277d4`, frozen `chmod 555` |
| production surface | `src/TypeEmit.cpp` ONLY — one new block at the end of the existing `§ importCloneBareTdAlias16`. **+137 / −0 lines, one file, no header change, no new exporter state, no new flag, no new member function, no object re-pointed outside the law.** |
| probe surface | `tools/probe/r10uvm205repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default and testflags, 112 cmp lines, ONE head each; MiniAmiq default and testflags, 112, ONE head each** — ONE object in all four row-modes before (§ 1) and a DIFFERENT object after, in fact TWO different ones (§ 8). The line count is unchanged because a cmp line count is the HEAD OBJECT'S DECOMPILE SIZE (RESUME.md §7) and the object that replaces it is another use of the same 64-bit `bit_typespec`; the OBJECT is what moved, and § 8 quotes both. |
| every other row's head | unchanged, both binaries — SimpleUVM ×2 1327654, Scoreboard/default 95, BuildUVMPkg ×2 **0**, Earlgrey_0_1 386 / **0**, Rggen/default **0**. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against the **committed baselines** (1588 surelog rows, 731 + 731 uhdm2rtlil rows). Against this pass's own pristine sweep exactly one row-SIDE differs, `Earlgrey_0_1,testflags` `CMP_EQUAL/` → `CMP_EQUAL/differ` — the DUMP COLUMN only, the uhdm-dump timeout r10uvm204 recorded in the other direction, and the PATCHED value is the committed baseline's. **NO ROW WAS CONVERTED.** |
| the four protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `Earlgrey_0_1,testflags`, `Rggen,default` — **CMP_EQUAL on both binaries, rowheads 0 lines / 0 heads on both, and every census mover column 0** (§ 7, § 6). |
| byte movers | **5 / 956** surelog — the FOUR the prediction named BY NAME from the pristine databases alone, plus Scoreboard/default, the ~50/50 COIN. **0 / 1358** uhdm2rtlil. |
| the attribution | each of the four law rows: **exactly 20 census cells changed, 0 keys appeared, 0 keys vanished**, and every one of the 80 changed cells is the same edit — the element typespec's `Typedef_alias` target going `uvm_pkg::uvm_reg_addr_t` → `uvm_reg_addr_t`, which is golden's value. Scoreboard/default: **0** cells changed, order-blind dump diff **0** content lines. |
| **the dump is BLIND here** | `uhdm-dump` does not print `vpiTypedefAlias`. On grid arm E the sorted, path-normalised whole-dump diff between the two databases reads **two lines, both the dump's own filename header**, across a change `uhdm-cmp` scores from 112 cmp lines to 1192. The campaign's usual order-blind dump attribution cannot see this family at all; `ct205cen` (which reads `Typedef_alias`) and its `--arena` whole-database form are the attribution instruments, and this is written down because a null dump diff here would otherwise read as "nothing moved". |
| the corpus population | **13 declarations × 2 package views = 26 clone `.elem` cells per moved row-mode, of which 20 move and 6 are refused** (R1), and **none anywhere else in either corpus**. |
| the census (12 row-modes, golden-vs-golden calibrated FIRST on every one, 0 movers on all 12) | SeqDriver ×2 and MiniAmiq ×2 **TO-GOLDEN 20, AWAY-GOLDEN 0, MOVED-WRONG 0, STILL-WRONG 6**. SimpleUVM ×2, Scoreboard/default, **BuildUVMPkg ×2**, **Earlgrey_0_1 ×2**, **Rggen/default**: every mover column **0**. Scoreboard/testflags and Rggen/testflags have no golden and are reported `SKIP-NOFILE`, never silently skipped. |
| the grid (6 arms × 2 views, one REAL Surelog golden each) | **AWAY-GOLDEN 0 and MOVED-WRONG 0 in every arm in every view**, golden-vs-golden calibrated first in every one. Arm **D** (the explicit-import control) and arm **F** (the home-only control) are **BYTE-IDENTICAL on both binaries in both views**. Arm **E**, the minimised head, goes **112 cmp lines → 1192** as its head object clears and the compare walks on into a different family. |
| the a-priori prediction | `strict` non-zero on **exactly four row-modes over 948 scanned surelog databases** — `SeqDriver` ×2 and `MiniAmiq` ×2, 20 cells each, one typedef (`uvm_pkg::uvm_reg_addr_t`) — and on **none of the 1358** uhdm2rtlil ones. Written before the patched sweep existed. |
| the WIDE boundary (5327 arms, both views, both binaries) | `MOVED_ARMS` **9**, `RC_DIFFS` **0**. Four are this pass's OWN grid arms (the positive control). The five earlier-pass arms were each re-measured against a REAL Surelog golden in both views: **AWAY-GOLDEN 0, MOVED-WRONG 0**, two move TOWARD golden, three move no compared cell at all, and all five keep **IDENTICAL `uhdm-cmp` line counts and head objects**. Every protected family — § 204, § 202, § 198, § 16, § 180, § 194, § 169, uvm82–91, buvm3–15, sd8–12 — has **0 movers**. |
| goldens | 23 PASS / 0 FAIL on both binaries; `/bin/false` 23 FAIL (the negative control). |
| what the brief got RIGHT and what it needed correcting | The brief's R0 said "golden's clone-reached `bit_typespec` name is BARE where ours is package-qualified; VpiName alone fails". The *pair the judge stops on* is exactly that. But the object is not a declaration's own typespec: it is the **`Typedef_alias` TARGET one level below an ARRAY ELEMENT typespec**. Our element typespec's own `VpiName` is already BARE and already agrees — LAW S made it — and `typespec::Compare` walks `Typedef_alias` before `Instance`, so the failure surfaces on the target. § 2. The brief also asked for "§ 16's window one kind wider"; widening § 180's LISTENER is **not** the right instrument and § 4 says why. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `450b7a24` worktree, froze
it `chmod 555`, and swept both corpora with it before a line of code was
written. `check_goldens.sh` reads 23 PASS / 0 FAIL with the `/bin/false`
negative control at 23 FAIL; the surelog sweep reproduces
`results/golden_surelog.csv` row for row except one informational dump-column
cell (§ 7); both uhdm2rtlil sweeps reproduce their baselines exactly.

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default        112      1
SeqDriver      testflags      112      1
MiniAmiq       default        112      1
MiniAmiq       testflags      112      1
```

and all four are the same object (`head_pris_*.cmp`; MiniAmiq's importer is
`svaunit_pkg` where SeqDriver's is `adpcm_pkg`, and that is the only
difference):

```
LHS: bit_typespec: (uvm_reg_addr_t), line:73:10, endln:73:31
     |vpiParent: \_ref_typespec: (adpcm_pkg::uvm_reg::get_address::addr::uvm_reg_addr_t)
     |vpiName:uvm_reg_addr_t
     |vpiInstance: \_package: uvm_pkg
     |vpiRange: \_range: 73:23-73:31  (63 downto 0)
RHS: bit_typespec: (uvm_pkg::uvm_reg_addr_t), line:73:10, endln:73:31
     |vpiParent: \_module_inst: work@top_tb
     |vpiName:uvm_pkg::uvm_reg_addr_t
     |vpiInstance: \_package: adpcm_pkg
     |vpiRange: \_range: 73:23-73:31  (63 downto 0)
```

uvm-1.2 `reg/uvm_reg_model.svh:73` is
``typedef bit unsigned [`UVM_REG_ADDR_WIDTH-1:0] uvm_reg_addr_t;`` and
`reg/uvm_reg.svh:1767-1771` is

```systemverilog
function uvm_reg_addr_t uvm_reg::get_address(uvm_reg_map map = null);
   uvm_reg_addr_t  addr[];
   void'(get_addresses(map,addr));
   return addr[0];
endfunction
```

`addr` is a DYNAMIC ARRAY, so the typedef is bound one link below an
`array_typespec`.

---

## 2. THE EDGE — WHICH OBJECT, AND IN WHICH ROLE

The head's LHS is parented at a `ref_typespec` whose synthesised full name is
`adpcm_pkg::uvm_reg::get_address::addr::uvm_reg_addr_t`, i.e. a ref hanging off
the clone body local `addr`. `ct205cen` keys every declaration in every package
subroutine body — at any block depth, in a class method or a free subroutine
alike — and then walks the WHOLE TYPESPEC CHAIN below it, through
`array_typespec` / `packed_array_typespec` `Elem_typespec` and `Index_typespec`
links, recording the two names `typespec::Compare` reads first plus the
`Instance` name. On SeqDriver/default the cell at that declaration reads:

```
key   ALL[2] adpcm_pkg | uvm_reg::get_address | d1 | var | addr@1768:20 | .elem
gold  bit_typespec[uvm_reg_addr_t -> uvm_reg_addr_t]        elem inst=uvm_pkg  alias-target inst=uvm_pkg
ours  bit_typespec[uvm_reg_addr_t -> uvm_pkg::uvm_reg_addr_t] elem inst=uvm_pkg  alias-target inst=adpcm_pkg
```

So **the element typespec's own `VpiName` is BARE and already agrees**; the pair
the judge stops on is its `Typedef_alias` TARGET one level down —
`typespec::Compare` walks `Typedef_alias` before `Instance` (RESUME.md §9), and
`BaseClass::Compare` reads `VpiName` first, which is why the head prints as a
name mismatch on a `bit_typespec`. Our target is the import-clone listing object
(qualified, `vpiInstance` the importer); golden's is a bare per-declaration copy
instanced at the HOME package. That is **§ `cloneBodyBareTdAlias180`'s exact
repair shape, one array link down** — `gold=[t -> t]` against
`ours=[t -> uvm_pkg::t]`.

**THE KIND TABLE** (`KINDTABLE.r10uvm205.txt`, SeqDriver/default, every cell of
every declaration chain, both writers). Pristine:

```
KIND x CHAIN x (gold name/alias/inst) x (our name/alias/inst)                COUNT
bit_typespec     chain=.      g=BARE/BARE/uvm_pkg     o=BARE/BARE/uvm_pkg      378
bit_typespec     chain=.      g=BARE/QUAL/uvm_pkg     o=BARE/QUAL/uvm_pkg      521
bit_typespec     chain=.elem  g=BARE/BARE/uvm_pkg     o=BARE/QUAL/uvm_pkg       26   <-- THE HEAD'S FAMILY
bit_typespec     chain=.elem  g=BARE/QUAL/uvm_pkg     o=BARE/QUAL/uvm_pkg       55   <-- THE HOME, MUST NOT MOVE
bit_typespec     chain=.elem  g=NONAME/NOALIAS        o=NONAME/NOALIAS          16
int_typespec     chain=.elem  g=NONAME/NOALIAS        o=NONAME/NOALIAS          49   (3 rows, differing only in the vpiInstance column, which the payload does not carry)
integer_typespec chain=.elem  g=NONAME/NOALIAS        o=NONAME/NOALIAS           8
… logic/byte/long_int/int at chain=. : every row agrees, both shapes
TOTAL agree=5255 differ=26 only-golden=1011 only-ours=468
(the full 40-row table, with the vpiInstance column, is KINDTABLE.r10uvm205.txt)
```

**The whole disagreement of the two writers over this population is ONE row**:
26 cells, all `bit_typespec`, all at `.elem`, all in the clone package, all
`[t -> t]` against `[t -> uvm_pkg::t]`. The 94 HOME `.elem` cells of the same
typedefs are `[t -> uvm_pkg::t]` on BOTH sides and are the must-stay floor. The
34 clone `.elem` cells that already agree are all UNNAMED element typespecs,
which carry no listing object and no alias at all.

Which kinds § 16 already bares and which still read qualified is the same table
read down the `chain` column: at `chain=.` (the declaration's own typespec) the
two writers agree on every kind in the LAW-S set; at `chain=.elem` they agree on
every kind except the one that has a name.

---

## 3. DECODE — SURELOG

`DECODE.r10uvm205.txt` carries the quoted source. In one paragraph:

* `~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:775` `writeDataTypes()`
  applies the `p::t` prefix **IN PLACE** (`:787-793`, `tps->VpiName(newName)`)
  while it walks **the package's OWN `datatypeMap`**, and its three call sites
  (`:994` a class, `:1189` a package, `:1447`/`:1670` a module) each hand it that
  component's own map.
* `~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:127` `importPackage()`
  `clone_tree`s the imported subroutine into the IMPORTER at COMPILE time
  (`:321-325`), long before that walk.

So nothing inside a clone body is ever the object that got prefixed — **at any
DEPTH and in any ROLE**. An array element typespec is one link deeper than the
declaration's own typespec and the rule does not change there. That is exactly
what the corpus shows and exactly what six arms show against a real golden.

Note the `object_name` filter at `:306-308` / `:312-314`: an EXPLICIT
`import p::f;` clones too, and golden bares that clone's chain as well (arm D
measures it). Our registry `pkgImportCloneTfs16` is WILDCARD-ONLY — the
committed fence of § 194 — so arm D stays BYTE-IDENTICAL here on purpose (R3).

---

## 4. DECODE — SLANG-UHDM, AND WHY ALL THREE EXISTING WALKS MISS

`src/TypeEmit.cpp` § `importCloneBareTdAlias16` reaches a clone body's typespec
refs by three routes:

* the clone `task_func`'s own `Io_decls()` vector;
* its own `Variables()` vector;
* § `cloneBodyBareTdAlias180`'s `UhdmListener`, for a block-local (which hangs
  off a `begin`/`fork`/loop scope, not the subroutine) and for an expression's
  typespec (which hangs off no listing at all).

The first two call `rebind` on the DECLARATION's own `Typespec()`. For
`uvm_reg_addr_t addr[]` that ref binds an `array_typespec`, which is no listing
object and carries no alias, so `listingOf` returns null and the rebind is a
no-op. The third refuses one step earlier — its climb is

```cpp
for (int i = (int)cs.size() - 2; i >= 0; --i) {
    const UHDM::UHDM_OBJECT_TYPE k = cs[i]->UhdmType();
    if (k == UHDM::uhdmfunction || k == UHDM::uhdmtask) { … return; }
    if (k == UHDM::uhdmclass_defn ||
        any_cast<const UHDM::typespec*>(cs[i]))
        return;                     // <-- the array_typespec stops it here
}
```

`ct205ref` re-implements that climb verbatim and counts what each branch decides
on our own pristine SeqDriver/default database. Of the refs whose bound typespec
carries LAW S's bare name and a still-QUALIFIED alias target — § 180's repair
shape — the verdicts are:

```
verdict         widened      enclosing pkg   holder        count
BAIL-ARRAYTS    -> TF        adpcm_pkg       array_var       34
BAIL-ARRAYTS    -> TF        adpcm_pkg       ref_var          6
BAIL-ARRAYTS    -> TF        uvm_pkg         array_var       13   (the HOME; must not move)
BAIL-ARRAYTS    -> BAIL-CLASS adpcm_pkg      array_var        3   (a class PROPERTY; still refused)
BAIL-CLASS      -> BAIL-CLASS adpcm_pkg      bit/int/logic_var 22 (the class-member window; R0)
BAIL-TS         -> BAIL-TS   both            enum/logic ts,
                                             typespec_member 18
TF              (already rebound by § 180)                   751
TF-RETURNVAR    (§ 16's measured exception)                  135
```

**WHY THIS PASS DOES NOT WIDEN THAT LISTENER.** `UhdmListener`'s `visited` set
hands each callback whichever containment path reached the object FIRST — on
SeqDriver that is a 90-step walk through 40 unrelated classes, and the stack
root is `uvm_pkg` for every ref no matter whose body it is in. It therefore sees
**one** owner per ref and cannot tell that a ref has another. Ours must: of the
26 clone `.elem` refs, **6 are also reached from a HOME body's declaration**, and
golden keeps every one of those home cells QUALIFIED. A widened listener would
have flipped those six home cells AWAY from golden on a traversal-order lottery.
`variables` and `io_decl` objects ARE parented on both sides, so the law walks
DECLARATIONS with a plain `VpiParent` climb instead, and no callstack ambiguity
arises at all.

---

## 5. THE LAW

```
§ cloneArrayElemBareTdAlias205
    A wildcard-import CLONE body's declaration written as an ARRAY of a package
    scalar typedef bares its ELEMENT typespec's alias chain, exactly as § 16
    bares the declaration's own.  Reached by descending the typespec chain from
    every declaration whose innermost enclosing object is a clone subroutine —
    `array_typespec` / `packed_array_typespec`, `Elem_typespec` and
    `Index_typespec` — and re-pointing each ref BELOW an array link onto the
    clone copy § 16's own `cloneCopyOf` already mints.

    THE EXCLUSIVITY GUARD.  A ref that any NON-clone declaration also reaches is
    REFUSED.  One `ref_typespec` cannot carry two names, and golden keeps the
    home body's cell QUALIFIED.
```

Three fences are § 16's own, restated so that this walk cannot exceed it:

* **the class fence** — the climb from a declaration stops at `class_defn`,
  `package`, `module_inst` or `design`, so a class PROPERTY is refused exactly as
  `CloneBodyTdRebind180` refuses it (3 such refs on SeqDriver, unmoved);
* **the return-variable exception** — a clone function's RETURN variable keeps
  the HOME's QUALIFIED target (r10uvm169's `g169_a_import`, r10v169's
  `v169_i_multi`), so it counts as a NON-clone owner and a ref it shares can
  never move;
* **the wildcard gate** — the whole block is inside
  `if (!pkgImportCloneTfs16.empty())` and every declaration is tested against
  that registry, which § 194 populates for WILDCARD clones only.

**NO NAME IS WRITTEN.** Only a LINK is re-pointed, and only onto a copy the
pre-existing clone machinery mints. The recorded naming dead end (RESUME.md §9)
forbids a uniform `pkg::` requalification; this is its opposite, and the
`RefPkgParamInEnum` golden it protects is one of the 23 that pass on both
binaries.

**MINT ORDER IS CONTENT ORDER, NEVER ARENA ORDER.** The copies are minted in a
pre-pass sorted on `(name, kind, file, line:col, instance name)` so the object
ids they take cannot depend on allocation addresses.

---

## 6. THE CORPUS CENSUS — 12 ROW-MODES, GOLDEN-VS-GOLDEN CALIBRATED FIRST

`CENSUS.r10uvm205.txt` in full. Every row-mode's calibration (the same golden on
both sides) reads **TO-GOLDEN 0 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / STILL-WRONG 0**
before any score is believed.

| row-mode | TO-GOLDEN | AWAY | MOVED-WRONG | STILL-WRONG | AGREE |
|---|---|---|---|---|---|
| SeqDriver default | **20** | 0 | 0 | 6 | 5255 |
| SeqDriver testflags | **20** | 0 | 0 | 6 | 5255 |
| MiniAmiq default | **20** | 0 | 0 | 6 | 5425 |
| MiniAmiq testflags | **20** | 0 | 0 | 6 | 5425 |
| SimpleUVM ×2 | 0 | 0 | 0 | 0 | 3789 |
| Scoreboard default | 0 | 0 | 0 | 0 | 3804 |
| BuildUVMPkg ×2 | 0 | 0 | 0 | 0 | 3595 |
| Earlgrey_0_1 default | 0 | 0 | 0 | 0 | 446 |
| Earlgrey_0_1 testflags | 0 | 0 | 0 | 0 | 532 |
| Rggen default | 0 | 0 | 0 | 0 | 4 |

Scoreboard/testflags and Rggen/testflags have no golden and are reported
`SKIP-NOFILE`. On every row-mode the number of census KEYS is identical before
and after — 0 appeared, 0 vanished — so nothing changed shape anywhere.

---

## 7. THE GATES

Full battery with every number in `GATES.r10uvm205.txt`. In one line: goldens
23/0 on both binaries with the `/bin/false` control at 23 FAIL; every `cmds.txt`
in all four sweeps audited by BINARY PATH (1523 + 1458 invocations per binary, 0
main-tree); uhdm2rtlil 679/50/2 in both modes with `ct8rows` 0 differing rows
against the committed baseline AND against this pass's own pristine sweep;
surelog `ct8rows` **0 differing rows against the committed baseline** over all
1588 rows, and one informational DUMP-COLUMN cell against this pass's own
pristine sweep; `byteverify SELFCHECK=1` 5/956 surelog and 0/1358 uhdm2rtlil,
every mover named and attributed; canaries `ok=52 changed=0` surelog and
`ok=8 changed=0` uhdm2rtlil; `ctcan2` PASS on both corpora; `canaudit` PASS
(audited=29, UNCOVERED=0, FENCE-BREACH=0); SVSwitch `4842211c4030` and YosysVerx
`6ccda350c24a` **PINS HELD**; InterfaceModPort, BlackParrotComplex and YosysOldOr
byte-identical.

**The four protected CMP_EQUAL row-modes, both columns, scored explicitly:**

```
                           committed baseline        pristine            patched
BuildUVMPkg,default        CMP_EQUAL,,,differ        (same)              (same)
BuildUVMPkg,testflags      CMP_EQUAL,,,differ        (same)              (same)
Earlgrey_0_1,testflags     CMP_EQUAL,,,differ        CMP_EQUAL,,,        CMP_EQUAL,,,differ
Rggen,default              CMP_EQUAL,,,differ        (same)              (same)
```

All four stay `CMP_EQUAL`; the patched sweep matches the COMMITTED BASELINE on
every one of the eight cells. `Earlgrey_0_1,testflags`'s dump column read empty
in this pass's PRISTINE sweep and `differ` in its PATCHED one — the uhdm-dump
timeout under sweep load, in the opposite direction to the one r10uvm204
recorded, with the STATUS `CMP_EQUAL` throughout and `rowheads` 0 lines / 0
heads on both binaries.

---

## 8. THE GRID — 6 arms × 2 views, one REAL Surelog golden each

`grid205.sh` builds the golden and BOTH binaries' databases in BOTH views,
echoes every command AND ITS BINARY PATH into `cmds.txt`, records every rc (an
rc=139 segfault must never read as a result) and NAMES a missing database. Full
output: `GRIDS.r10uvm205.txt`. Golden-vs-golden calibration ran first in every
arm in every view and read 0 in every column.

| arm | what it decides | def view | elab view |
|---|---|---|---|
| **A** `g205_a_kinds` | the KIND TABLE — `bit`/`logic`/`int`/`byte`/`integer`/`shortint`/`longint` package typedefs, plus a packed-array, an enum, a struct and a class typedef, each as the ELEMENT of a dynamic array, a queue and a fixed-size array, in a free clone body and in a clone CLASS METHOD, with a class PROPERTY alongside | TO-GOLDEN 22, AWAY 0, MOVED-WRONG 0 | TO-GOLDEN 44, AWAY 0, MOVED-WRONG 0 |
| **B** `g205_b_ctx` | the CONTEXTS — subroutine level, `begin` block, `for` body, `foreach` body, FORMAL, function RETURN variable, class PROPERTY | TO-GOLDEN 12, AWAY 0, MOVED-WRONG 0 | TO-GOLDEN 16, AWAY 0, MOVED-WRONG 0 |
| **C** `g205_c_share` | THE SHARING CONTROL — `bt205 addrs205[$]` walked by `foreach`, the `uvm_reg_map::do_bus_read` shape that makes our emitter hand a declaration and a foreach reference variable ONE element ref | TO-GOLDEN 1, AWAY 0, MOVED-WRONG 0, **STILL-WRONG 1** — R1 reproduced exactly, in the ELAB listing only | TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0, STILL-WRONG 2 |
| **D** `g205_d_noimport` | THE CONTROL — an EXPLICIT `import p::f;`, which § 194's wildcard-only registry must never see | **BYTE-IDENTICAL** on both binaries | **BYTE-IDENTICAL** |
| **E** `g205_e_head` | the MINIMISED CORPUS HEAD — `typedef bit [63:0] t`, a class with an OUT-OF-BODY method whose only local is `t addr[];`, wildcard-imported | pristine head is that `bit_typespec` at **112 cmp lines**, the corpus head's exact shape; patched **1192** with a DIFFERENT head object; TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 | TO-GOLDEN 4, AWAY 0, MOVED-WRONG 0 |
| **F** `g205_f_home` | THE HOME MUST-STAY — the declaring package with no clone anywhere | **BYTE-IDENTICAL**, all 16 cells AGREE | **BYTE-IDENTICAL**, all 24 cells AGREE |

Arm E's patched head is the pair `package p205a_h` (golden) against
`package p205b_h` (ours) — the two producers list packages in a different order
in the design vector. That is a package-listing family, not this one; the arm's
old head cleared and the compare walked on.

---

## 8b. WHAT THE PATCHED CORPUS HEAD IS — R0

All four row-modes still read 112 cmp lines and ONE head, and in all four the
head OBJECT changed. SeqDriver ×2 and MiniAmiq ×2 now head on **two different**
objects (`head_pat_*.cmp`):

**SeqDriver ×2 — R0, the CLASS-MEMBER window:**

```
LHS: bit_typespec: (uvm_reg_addr_t), line:73:10, endln:73:31
     |vpiParent: \_ref_typespec:
        (adpcm_pkg::uvm_reg_map::m_set_mem_offset::range::uvm_pkg::uvm_reg_map_addr_range::min::uvm_reg_addr_t)
     |vpiName:uvm_reg_addr_t          |vpiInstance: \_package: uvm_pkg
RHS: bit_typespec: (uvm_pkg::uvm_reg_addr_t)   |vpiInstance: \_package: adpcm_pkg
```

**R0 — THE NEXT HEAD is § 16's OTHER refused kind: the CLASS MEMBER.** The ref
is reached from a clone body local (`range`, of class type
`uvm_reg_map_addr_range`) through that class's MEMBER `min` — a `class_typespec`
between the ref and the subroutine, which
`CloneBodyTdRebind180`'s `if (k == uhdmclass_defn || any_cast<const typespec*>(cs[i])) return;`
refuses on purpose ("those objects belong to the class world both producers
reach by other routes, and § 16 must not follow a `class_typespec` into one").
`ct205ref` sizes that population on SeqDriver: **22 refs of the repair shape in
the clone package** (`BAIL-CLASS`, holders `bit_var` 13 / `int_var` 7 /
`logic_var` 2) against **1 in the home**. Start from `ct205ref`'s verdict table
and `ct205cen`'s chain census — the census will need a `.member` link beside
`.elem` — and decide FIRST, on a golden grid, whether golden bares a clone-
reached class member in general or only when the member's class is itself
imported. **Read RESUME.md §9's warning first: naming is CONTEXT-DEPENDENT and a
uniform requalification fix is a known dead end.**

**MiniAmiq ×2 — R1, the shared element ref:**

```
LHS: bit_typespec: (uvm_reg_addr_t)
     |vpiParent: \_ref_typespec: (svaunit_pkg::uvm_reg_map::m_set_reg_offset::addrs::uvm_reg_addr_t)
```

That is one of the six cells this law deliberately refuses (§ 9, R1).

---

## 9. RESIDUES

* **R1 — the SHARED element ref (6 cells per moved row-mode; MiniAmiq's new
  head).** Our emitter hands ONE `.elem` `ref_typespec` to a clone body's
  declaration and to a HOME body's declaration or `foreach` reference variable,
  in the ELABORATED listing only. Golden mints one per declaration and keeps the
  home's alias target QUALIFIED, so the ref cannot carry both names and the law
  refuses it. Named in full in `MOVERS.r10uvm205.txt`; they are
  `uvm_reg_map::{Xinit_address_mapX, do_bus_read, do_bus_write,
  get_physical_addresses ×2, m_set_reg_offset}`. Arm C reproduces it against a
  real golden. Closing it needs a SPLIT — a fresh `array_typespec` and element
  ref for the clone declaration, whose own `Typespec()` ref is unshared in all 26
  cells — which is a mint, not a re-point, and deliberately not attempted here.
* **R2 — an UNNAMED element typespec.** A FIXED-SIZE unpacked array
  (`bt205 lf205[4]`) and a typedef'd array RETURN type
  (`typedef bt205 arr205[]`) give OUR element typespec no name and no alias at
  all where golden gives it the typedef (arm A `lf205`, arm B `fret205::rv205`;
  4 and 4 cells). `listingOf` returns null there, so this law correctly refuses
  them; they belong to an element-typespec MINTING family. Unmoved, on both
  binaries.
* **R3 — the EXPLICIT-import clone.** `CompileHelper::importPackage`'s
  `object_name` filter clones a named import too, and golden bares that clone's
  chain exactly as it bares a wildcard clone's (arm D, 6 def / 10 elab cells
  `gold=[t -> t]` against `ours=[t -> p::t]`). `pkgImportCloneTfs16` is
  WILDCARD-ONLY by § 194's committed fence, so arm D is BYTE-IDENTICAL on both
  binaries and the residue is left standing on purpose.
* **R4 — golden mints per declaration, we memoise per typedef.** Golden's clone
  copies are one object per declaration; ours is one memoised copy shared by
  every clone use. Invisible to the judge (no generated `Compare` reads
  `VpiParent`, and the objects agree in every compared field), and arm E and arm
  F both confirm it. Deliberately not changed.
* **R5 — `uhdm-dump` cannot see this family.** It does not print
  `vpiTypedefAlias`, so a sorted whole-dump diff reads 0 content lines across a
  change the judge scores from 112 cmp lines to 1192 (arm E). Any future pass in
  this family must attribute with `ct205cen` / `ct205cen --arena`, never with the
  dump. This is a residue of the INSTRUMENTS, and it is the one most likely to
  mislead the next operator.
* **R6 — the census is stricter than the judge.** Its keys carry the listing tag,
  the class, the subroutine, the block depth and the declaration span, so a
  shape difference between the two writers reads as a one-sided key
  (`only-golden 1011 / only-ours 468` on SeqDriver) even where the judge is
  satisfied. Those counts are IDENTICAL before and after — 0 keys appeared, 0
  vanished — and the columns that decide a pass, `AWAY-GOLDEN` and
  `MOVED-WRONG`, are 0 on every row-mode and every arm.

---

## 10. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm205repro
g++ -O2 -std=c++17 ct205cen.cpp  -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct205cen
g++ -O2 -std=c++17 ct205ref.cpp  -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct205ref
g++ -O2 -std=c++17 ct205pred.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct205pred

# THE EDGE and THE KIND TABLE, on the head's own row (the decode of record)
/tmp/ct205cen <golden.uhdm> <ours.uhdm> --kinds          # kind x chain x shape
/tmp/ct205cen <golden.uhdm> <ours.uhdm> --name=uvm_reg_addr_t
/tmp/ct205cen <golden.uhdm> <ours.uhdm> --share          # object sharing across listings
/tmp/ct205cen <golden.uhdm> <ours.uhdm> --raw            # one line per cell, for score205.py

# WHAT § 16's OWN LISTENER PREDICATE ADMITS AND REFUSES, on OUR database
/tmp/ct205ref <ours.uhdm> --wide [--list] [--edge=uvm_reg_addr_t]

# the grid (one real Surelog golden per arm, both views, both binaries)
for a in grid205/g205_*.sv; do
  CEN=/tmp/ct205cen bash grid205.sh "$a" <PRISTINE> <PATCHED> /tmp/w_$(basename $a .sv)
done

# the a-priori prediction, from a completed PRISTINE sweep workdir
PRED=/tmp/ct205pred bash predict205.sh <pristine workdir> /tmp/pred.txt

# the corpus census over the UVM row-modes (golden-vs-golden calibrated first)
CEN=/tmp/ct205cen bash cen205.sh <pristine wd> <patched wd> /tmp/cen

# the ORDER-BLIND, ALIAS-VISIBLE whole-database attribution (the dump is blind)
/tmp/ct205cen <pristine.uhdm> <patched.uhdm> --arena | sort   # then diff the two sides

# the WIDE boundary, from a COPY of the probe tree
PRIS=<pristine> PATCHED=<patched> bash bound205.sh <copy of tools/probe> /tmp/bound

# the guards
bash canaudit.sh canaries.sh ctcan2.sh
```
