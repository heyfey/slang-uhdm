# r10uvm207 — § `cloneStructMemberBareTdAlias207` — **A WILDCARD-IMPORT CLONE BODY'S DECLARATION OF A PACKAGE STRUCT TYPEDEF GETS ITS OWN COPY OF THE STRUCT, WITH BARE MEMBER ALIASES** — the SeqDriver ×2 112-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own `FENCED=` line,
which `predict207.sh` reads at run time so this pass's artifacts never spell
them.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `3e4de175` |
| pristine binary | md5 `78ed14157d37767daeabd4bd038e56f7`, built `-j 2` from this pass's OWN worktree at a clean `3e4de175` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `56cb758a707445bf15f6ad408caf2f5d`, frozen `chmod 555` |
| production surface | `src/TypeEmit.cpp` ONLY — one new block at the end of the existing `§ importCloneBareTdAlias16`, after § 205's. **+244 / −0 lines, one file, no header change, no new exporter state, no new flag, no new member function.** |
| probe surface | `tools/probe/r10uvm207repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default and testflags, 112 cmp lines / ONE head → 50 / ONE head.** The head object CLEARED and the compare walked on into a different family (§ 8b). |
| every other row's head | **cmp log BYTE-IDENTICAL between the two binaries** — SimpleUVM ×2 4177864 / 4178104, Scoreboard/default 95, **MiniAmiq ×2 112**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 31 / **0**, Rggen/default **0**. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against **this pass's own pristine sweeps** (1588 surelog rows, 731 + 731 uhdm2rtlil rows). Against the committed baseline exactly one row-SIDE differs, `Earlgrey_0_1,testflags` `CMP_EQUAL/differ` → `CMP_EQUAL/`, and this pass's own PRISTINE sweep reads it the same way: the recorded uhdm-dump TIMEOUT under sweep load. **NO ROW WAS CONVERTED.** |
| the four protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `Earlgrey_0_1,testflags`, `Rggen,default` — **CMP_EQUAL on both binaries, rowheads 0 lines / 0 heads on both, every census mover column 0, both columns quoted** (§ 7). |
| byte movers | **5 / 956** surelog — the FOUR the prediction named BY NAME from pristine databases alone, plus Scoreboard/default, the ~50/50 COIN (order-blind dump diff **0 content lines**). **0 / 1358** uhdm2rtlil. |
| the attribution | each of the four law rows: **exactly 50 census cells TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG, 12 STILL-WRONG, 0 keys appeared, 0 keys vanished**. The alias-visible whole-arena multiset gains **9 `ref_typespec` rows and loses none**; the order-blind whole-dump diff is **121 lines, +121 / −0**, every one of them the TWO minted clone struct copies and their nine members. |
| the corpus population | **18 clone-exclusive struct-binding refs carrying 50 repairable member cells per moved row-mode**, over exactly TWO package struct typedefs (`uvm_pkg::uvm_reg_bus_op`, `uvm_pkg::uvm_reg_map_addr_range`), and **none anywhere else in either corpus**. |
| the census (12 row-modes, golden-vs-golden calibrated FIRST on every one, 0 movers on all 12) | SeqDriver ×2 and MiniAmiq ×2 **TO-GOLDEN 50, AWAY-GOLDEN 0, MOVED-WRONG 0, STILL-WRONG 12**. SimpleUVM ×2, Scoreboard/default, **BuildUVMPkg ×2**, **Earlgrey_0_1 ×2**, **Rggen/default**: every mover column **0**. Scoreboard/testflags and Rggen/testflags have no golden and are reported `SKIP-NOFILE`, never silently skipped. |
| the grid (10 arms × 2 views, one REAL Surelog golden each) | **AWAY-GOLDEN 0 and MOVED-WRONG 0 in every arm in every view**, golden-vs-golden calibrated first in every one. Arms **C**, **E** and **H** go **CMP_EQUAL in BOTH views** on the patched binary. Arms **D**, **F** and **G** are **BYTE-IDENTICAL on both binaries in both views**. |
| the a-priori prediction | `strict` non-zero on **exactly four row-modes over 948 scanned surelog databases** — `SeqDriver` ×2 and `MiniAmiq` ×2, 18 refs / 50 cells each — and on **none of the 1358** uhdm2rtlil ones, where the law's WIDE bound is **empty outright**. Written before the patched sweep existed. |
| the must-stay that the brief named | **r10uvm205's SIX shared element cells DID NOT MOVE**, named one by one in `MOVERS.r10uvm207.txt`; MiniAmiq's head is one of them and its uhdm-cmp log is **byte-identical** between the two binaries. |
| goldens | 23 PASS / 0 FAIL on both binaries; `/bin/false` 23 FAIL (the negative control). |
| what the brief got RIGHT and what it needed correcting | The brief's R0 said "a class typespec sits between the reference and the clone subroutine … the clone-reached CLASS MEMBER alias is yours". The head object and the `[t -> t]` vs `[t -> pkg::t]` shape are exactly right. **The object between them is a `struct_typespec`, not a class typespec** (§ 2), and the class reading is not merely a mislabel — its own arm, `g207_g_class`, is **already CMP_EQUAL on both binaries** (§ 8). The brief also framed the repair as "the gated extension or split-mint per the grid": it is **the split-mint, in every single cell** — `ct207ref` reads `MEMBER REFS … MOVE=0` (§ 4). |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `3e4de175` worktree; it came
out **byte-identical** to the main tree's binary at that commit
(`78ed1415…`). `check_goldens.sh` reads 23 PASS / 0 FAIL with the `/bin/false`
negative control at 23 FAIL; the surelog sweep reproduces
`results/golden_surelog.csv` row for row except the one informational
dump-column cell (§ 7); both uhdm2rtlil sweeps reproduce their baselines
exactly. All of that before a line of code was written.

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default        112      1
SeqDriver      testflags      112      1
MiniAmiq       default        112      1
MiniAmiq       testflags      112      1
```

SeqDriver's head (`head_pris_SeqDriver.*.cmp`):

```
LHS: bit_typespec: (uvm_reg_addr_t), line:73:10, endln:73:31
     |vpiParent: \_ref_typespec:
        (adpcm_pkg::uvm_reg_map::m_set_mem_offset::range::uvm_pkg::uvm_reg_map_addr_range::min::uvm_reg_addr_t)
     |vpiName:uvm_reg_addr_t          |vpiInstance: \_package: uvm_pkg
RHS: bit_typespec: (uvm_pkg::uvm_reg_addr_t), line:73:10, endln:73:31
     |vpiParent: \_module_inst: work@top_tb
     |vpiName:uvm_pkg::uvm_reg_addr_t |vpiInstance: \_package: adpcm_pkg
```

MiniAmiq's head is a DIFFERENT object — one of r10uvm205's six shared element
refs (`svaunit_pkg::uvm_reg_map::m_set_reg_offset::addrs::uvm_reg_addr_t`), its
R1 — and this pass does not touch it.

---

## 2. THE EDGE — WHICH OBJECT, AND IN WHICH ROLE

`ct207own --chain=range --sub=m_set_mem_offset --members`, on the pristine pair,
walks DOWN from the clone body local the head's `vpiParent` names:

```
GOLD DECL struct_var range@963:38  owner=adpcm_pkg|-|uvm_reg_map::m_set_mem_offset
  ref -> struct_typespec[uvm_pkg::uvm_reg_map_addr_range] inst=uvm_pkg
  struct_typespec parents: < ref_typespec: < struct_var:range < ...   (a PER-DECLARATION copy)
    member min@409:18     bit_typespec[uvm_reg_addr_t -> uvm_reg_addr_t]
    member max@410:18     bit_typespec[uvm_reg_addr_t -> uvm_reg_addr_t]
    member stride@411:16  int_typespec[ -> <noalias>]

OURS DECL struct_var range@963:38  owner=adpcm_pkg|-|uvm_reg_map::m_set_mem_offset
  ref -> struct_typespec[uvm_pkg::uvm_reg_map_addr_range] inst=adpcm_pkg
  struct_typespec parents: < module_inst:work@top_tb < design                  (ONE SHARED object)
    member min@409:18     bit_typespec[uvm_reg_addr_t -> uvm_pkg::uvm_reg_addr_t]
    member max@410:18     bit_typespec[uvm_reg_addr_t -> uvm_pkg::uvm_reg_addr_t]
    member stride@411:16  int_typespec[ -> <noalias>]
```

So the object between the reference and the subroutine is a **`struct_typespec`**
— `uvm_reg_model.svh:408-412` declares `uvm_reg_map_addr_range` as a `typedef
struct packed` — and the head's link is its `typespec_member` `min`. The member
typespec's own `VpiName` is already BARE and already agrees; the pair the judge
stops on is its `Typedef_alias` TARGET, `typespec::Compare` walking
`Typedef_alias` before `Instance`. That is
§ `cloneBodyBareTdAlias180`'s exact repair shape, one STRUCT-MEMBER link down.

**THE KIND TABLE** (`KINDTABLE.r10uvm207.txt`, SeqDriver/default, every cell of
every declaration chain, both writers). Pristine — the whole disagreement of the
two writers over this population, nine rows:

```
bit_typespec chain=.elem              g=BARE/BARE o=BARE/QUAL    6   (r10uvm205's R1)
bit_typespec chain=.elem.mem:addr     g=BARE/BARE o=BARE/QUAL    4
bit_typespec chain=.elem.mem:byte_en  g=BARE/BARE o=BARE/QUAL    4
bit_typespec chain=.elem.mem:data     g=BARE/BARE o=BARE/QUAL    4
bit_typespec chain=.mem:addr          g=BARE/BARE o=BARE/QUAL   12
bit_typespec chain=.mem:byte_en       g=BARE/BARE o=BARE/QUAL   12
bit_typespec chain=.mem:data          g=BARE/BARE o=BARE/QUAL   12
bit_typespec chain=.mem:max           g=BARE/BARE o=BARE/QUAL    4
bit_typespec chain=.mem:min           g=BARE/BARE o=BARE/QUAL    4
TOTAL agree=5517 differ=62 only-golden=1062 only-ours=472
```

Patched — the `.mem` family is gone entirely and the `.elem.mem` family is down
to the two shared array holders:

```
bit_typespec chain=.elem              g=BARE/BARE o=BARE/QUAL    6   (untouched, as required)
bit_typespec chain=.elem.mem:addr     g=BARE/BARE o=BARE/QUAL    2
bit_typespec chain=.elem.mem:byte_en  g=BARE/BARE o=BARE/QUAL    2
bit_typespec chain=.elem.mem:data     g=BARE/BARE o=BARE/QUAL    2
TOTAL agree=5567 differ=12 only-golden=1062 only-ours=472
```

`only-golden` and `only-ours` are IDENTICAL before and after: **0 keys appeared,
0 vanished**, so nothing changed shape anywhere.

---

## 3. THE SHARING, MEASURED BY WHOLE-DATABASE IDENTITY, BEFORE ANY PLAN

`ct207cen --decide` groups every DIFFERING cell by the identity of the HOLDER
object its ref hangs off and lists every declaration that reaches that holder:

```
DECIDE SUMMARY hot-holders=8 PURE(all reaches differ)=0 MIXED(some reach agrees)=8
```

**Every holder is MIXED.** Six are the `array_typespec` holders of r10uvm205's
R1; two are this family's struct typespecs. Our
`struct_typespec uvm_pkg::uvm_reg_map_addr_range` is reached by **eleven**
declarations — two in the clone `adpcm_pkg` and **nine in the home `uvm_pkg`
whose cells AGREE with golden today and must stay QUALIFIED** (all eleven named
in `DECODE.r10uvm207.txt` §2). `uvm_pkg::uvm_reg_bus_op`'s holder carries
`differ=48 agree=88`.

`ct207ref` says the same from the other side, on the same database:

```
MEMBER REFS BY VERDICT:          MOVE=0   REFUSE-SHARED=5  HOME=5
STRUCT-BINDING REFS BY VERDICT:  MOVE=22  REFUSE-SHARED=2  HOME=28
```

So **a member ref can never be re-pointed, in any cell of this family**. The
object that CAN move is the ref that BINDS THE STRUCT — a declaration's own
`Typespec()` or an array's `Elem_typespec` — re-pointed onto a CLONE COPY of the
struct. This pass is a **split-mint**, not a re-point, and the measurement said
so before a line of code was written.

---

## 4. DECODE — SURELOG, AND WHY EVERY EXISTING WALK MISSES

`DECODE.r10uvm207.txt` carries the quoted source. In one paragraph:
`UhdmWriter::writeDataTypes` (`UhdmWriter.cpp:775-796`) applies the `p::t`
prefix **IN PLACE** while it walks the component's OWN `datatypeMap`;
`CompileHelper::importPackage` (`CompileHelper.cpp:299-330`) `clone_tree`s the
imported subroutine into the IMPORTER at COMPILE time, before that walk. So
nothing inside a clone body is ever the object that got prefixed, at any DEPTH
and in any ROLE — a struct member included, and (arm H) even when the member's
struct comes from a package the importer never imports.

Our four existing walks all stop short: § 16's two loops rebind the
DECLARATION's own `Typespec()` (which binds an `array_typespec` or a
`struct_typespec` — no listing object, no alias, `listingOf` returns null);
§ 180's listener returns the moment `any_cast<const typespec*>(cs[i])` succeeds;
§ 205's declaration walk descends `Elem_typespec` / `Index_typespec` only.

---

## 5. THE LAW

```
§ cloneStructMemberBareTdAlias207
    A wildcard-import CLONE body's declaration of a package STRUCT typedef binds
    its OWN copy of the struct, whose members' alias chains are bare, exactly as
    § 16 bares the declaration's own and § 205 bares an array element's.

    Reached by descending the typespec chain from every declaration whose
    innermost enclosing object is a clone subroutine — `array_typespec` /
    `packed_array_typespec` `Elem_typespec` and `Index_typespec`, and a
    `struct_typespec`'s `Members()` — and re-pointing every ref that BINDS a
    struct with a repairable member onto a clone copy of that struct, minted
    once per struct, in CONTENT order, whose repairable members carry the bare
    copies § 16's own `cloneCopyOf` already makes.

    THE EXCLUSIVITY GUARD.  A ref that any NON-clone declaration also reaches is
    REFUSED.  One `ref_typespec` cannot carry two names, and golden keeps the
    home body's cell QUALIFIED.

    A MEMBER REF IS NEVER RE-POINTED.  It belongs to the struct, and every
    struct in the corpus population is shared with a home declaration.
```

Three fences are § 16's own, restated so that this walk cannot exceed it:

* **the class fence** — the climb from a declaration stops at `class_defn`,
  `package`, `module_inst` or `design`, so a class PROPERTY is refused exactly as
  `CloneBodyTdRebind180` refuses it;
* **the return-variable exception** — a clone function's RETURN variable keeps
  the HOME's QUALIFIED target (r10uvm169's `g169_a_import`, r10v169's
  `v169_i_multi`), so it counts as a NON-clone owner and a ref it shares can
  never move;
* **the wildcard gate** — the whole block is inside
  `if (!pkgImportCloneTfs16.empty())` and every declaration is tested against
  that registry, which § 194 populates for WILDCARD clones only.

**NO NAME IS WRITTEN.** Objects are copied and links re-pointed; every name on
a copy is the source object's own. The recorded naming dead end (RESUME.md §9)
forbids a uniform `pkg::` requalification; this is its opposite.

**MINT ORDER IS CONTENT ORDER, NEVER ARENA ORDER.** The struct copies are minted
in a pre-pass sorted on `(name, kind, file, line:col, instance name)`, so the
object ids they take cannot depend on allocation addresses. Measured: the
patched binary run three times on SeqDriver/default's own command line produces
a BYTE-IDENTICAL database each time, and the same md5 the sweep recorded
(`70d074f2ff6e…`, `GATES.r10uvm207.txt` §10).

**WHAT THE COPY KEEPS.** `struct_typespec::Compare` reads (through
`typespec::Compare`) VpiName, Typedef_alias and Instance, then VpiPacked, then
Members, then Resolution_func. The copy takes the SOURCE's value for every one
of those except Members, where only the repairable members' typespec refs change
— so the only compare-visible difference between the copy and the object it
replaces is the alias target the law exists to move. Instance is copied from the
source ON PURPOSE: golden's clone copy carries the HOME package there where our
shared object carries the importer, and the judge does not stop on it (the
package objects are already in `m_visited`), so leaving it as it is keeps the
status quo instead of making a second, unmeasured change.

---

## 6. THE CORPUS CENSUS — 12 ROW-MODES, GOLDEN-VS-GOLDEN CALIBRATED FIRST

`CENSUS.r10uvm207.txt` in full. Every row-mode's calibration (the same golden on
both sides) reads **TO-GOLDEN 0 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / STILL-WRONG 0**
before any score is believed.

| row-mode | TO-GOLDEN | AWAY | MOVED-WRONG | STILL-WRONG | AGREE |
|---|---|---|---|---|---|
| SeqDriver default | **50** | 0 | 0 | 12 | 5517 |
| SeqDriver testflags | **50** | 0 | 0 | 12 | 5517 |
| MiniAmiq default | **50** | 0 | 0 | 12 | 5687 |
| MiniAmiq testflags | **50** | 0 | 0 | 12 | 5687 |
| SimpleUVM ×2 | 0 | 0 | 0 | 0 | 3974 |
| Scoreboard default | 0 | 0 | 0 | 0 | 3989 |
| BuildUVMPkg ×2 | 0 | 0 | 0 | 0 | 3735 |
| Earlgrey_0_1 default | 0 | 0 | 0 | 0 | 446 |
| Earlgrey_0_1 testflags | 0 | 0 | 0 | 0 | 532 |
| Rggen default | 0 | 0 | 0 | 0 | 4 |

Scoreboard/testflags and Rggen/testflags have no golden and are reported
`SKIP-NOFILE`. On every row-mode the number of census KEYS is identical before
and after — 0 appeared, 0 vanished.

**The 12 STILL-WRONG, named** (`MOVERS.r10uvm207.txt`): six are r10uvm205's R1
shared ELEMENT refs (`Xinit_address_mapX addrs@1603`, `do_bus_read addrs@1983`,
`do_bus_write addrs@1839`, `get_physical_addresses local_addr@1408`,
`get_physical_addresses sys_addr@1472`, `m_set_reg_offset addrs@758`, all in the
ELABORATED listing) — **the brief's must-stay cells, and they did not move**;
six are this pass's own new residue R1′ (`do_bus_read accesses@1993` and
`do_bus_write accesses@1850`, three members each), where the ARRAY typespec that
holds the struct is itself shared with a home declaration so its
`Elem_typespec` ref cannot be re-pointed either.

---

## 7. THE GATES

Full battery with every number in `GATES.r10uvm207.txt`. In one line: goldens
23/0 on both binaries with the `/bin/false` control at 23 FAIL; every `cmds.txt`
in all four sweeps audited by BINARY PATH (1523 + 1458 invocations per binary, 0
main-tree); uhdm2rtlil 679/50/2 in both modes with `ct8rows` 0 differing rows
against the committed baseline AND against this pass's own pristine sweep, and
`byteverify` 0/1358; surelog `ct8rows` **0 differing rows against this pass's own
pristine sweep** over all 1588 rows and one informational DUMP-COLUMN cell
against the committed baseline that the PRISTINE sweep shows too;
`byteverify SELFCHECK=1` 5/956 surelog, every mover named and attributed;
canaries `ok=51 changed=1` against the committed baseline (the flake row only)
and `ok=52 changed=0` against this pass's own pristine sweep, `ok=8 changed=0`
uhdm2rtlil; `ctcan2` PASS on both corpora; `canaudit` PASS (audited=29,
UNCOVERED=0, FENCE-BREACH=0); SVSwitch `4842211c4030` and YosysVerx
`6ccda350c24a` **PINS HELD**; InterfaceModPort, BlackParrotComplex and
YosysOldOr byte-identical; all 12 pins SAME.

**The four protected CMP_EQUAL row-modes, both columns, scored explicitly:**

```
                           committed baseline        pristine            patched
BuildUVMPkg,default        CMP_EQUAL,,,differ        (same)              (same)
BuildUVMPkg,testflags      CMP_EQUAL,,,differ        (same)              (same)
Earlgrey_0_1,testflags     CMP_EQUAL,,,differ        CMP_EQUAL,,,        CMP_EQUAL,,,
Rggen,default              CMP_EQUAL,,,differ        (same)              (same)
```

All four stay `CMP_EQUAL`, and the patched value equals THIS PASS'S PRISTINE
value on every one of the eight cells.

---

## 8. THE GRID — 10 arms × 2 views, one REAL Surelog golden each

`grid207.sh` builds the golden and BOTH binaries' databases in BOTH views, echoes
every command AND ITS BINARY PATH into `cmds.txt`, records every rc (an rc=139
segfault must never read as a result) and NAMES a missing database. Full output:
`GRIDS.r10uvm207.txt`. Golden-vs-golden calibration ran first in every arm in
every view and read 0 in every column. **AWAY-GOLDEN 0 and MOVED-WRONG 0 in
every arm in every view.**

| arm | what it decides | def | elab |
|---|---|---|---|
| **A** `g207_a_struct` | THE KIND TABLE — `bit`/`logic`/`int`/`byte`/`integer`/`shortint`/`longint` package typedefs as MEMBERS of an unpacked struct, a PACKED struct, and a third struct, in a clone body | TO-GOLDEN 18 | TO-GOLDEN 36 |
| **B** `g207_b_ctx` | THE CONTEXTS — FORMAL (`io_decl`), subroutine local, `begin` block local, `for`-body local, class-METHOD local and formal, and an ARRAY OF the struct (`.elem.mem`) | TO-GOLDEN 30, STILL-WRONG 2; cmp **3234 → 37** | TO-GOLDEN 44, STILL-WRONG 4; cmp **3634 → 112** |
| **C** `g207_c_share` | **THE SHARING CONTROL** — one struct typedef declared by a HOME body local AND by the cloned body, the corpus's decisive shape | TO-GOLDEN 8; **CMP_EQUAL** (112 → 0) | TO-GOLDEN 16; **CMP_EQUAL** (112 → 0) |
| **D** `g207_d_noimport` | THE CONTROL — an EXPLICIT `import p::f;`, which § 194's wildcard-only registry must never see | **BYTE-IDENTICAL**, STILL-WRONG 4 (R3) | **BYTE-IDENTICAL**, STILL-WRONG 8 |
| **E** `g207_e_head` | THE MINIMISED CORPUS HEAD — `typedef struct { t min; t max; int stride; }` declared in an OUT-OF-BODY class method, wildcard-imported | TO-GOLDEN 4; **CMP_EQUAL** (1036 → 0) | TO-GOLDEN 8; **CMP_EQUAL** (1130 → 0) |
| **F** `g207_f_home` | THE HOME MUST-STAY — the declaring package with no clone anywhere | **BYTE-IDENTICAL**, all 20 cells AGREE, cmp 0 lines | **BYTE-IDENTICAL**, all 38 AGREE |
| **G** `g207_g_class` | THE CLASS-PROPERTY QUESTION the brief asked — a clone body local of CLASS type whose property is a package scalar typedef | **BYTE-IDENTICAL**, cmp **0 lines on BOTH binaries** — nothing to fix | **BYTE-IDENTICAL**, cmp 0 |
| **H** `g207_h_foreign` | **IS THE MEMBER'S STRUCT ITSELF IMPORTED?** — a struct from a THIRD package the importer never imports, beside one from the imported package | TO-GOLDEN 6; **CMP_EQUAL** (112 → 0) | TO-GOLDEN 12; **CMP_EQUAL** (112 → 0) |
| **I** `g207_i_retseg` | the RECORDED PRE-EXISTING SEGFAULT — a struct-typed function RETURN variable in a clone | TO-GOLDEN 8; cmp 112 → 27 | **rc=139 on BOTH binaries** (R2) |
| **J** `g207_j_nest` | a NESTED struct and a struct inside an array inside a struct — the guard on the copy walk's recursion | TO-GOLDEN 8 | TO-GOLDEN 16 |

Arm **H** is the one that fixed the law's SHAPE. Golden bares
`p207c_x::sx207`'s members inside `p207a_x`'s clone even though `p207b_x`
imports only `p207a_x`. **The law is about the CLONE BODY, not about whether the
member's type is itself imported** — a law gated on "the member's struct is
imported" would have left arm H wrong, and the brief's second grid question is
answered `in general`, not `only when imported`.

Arm **G** REFUTES the brief's framing rather than confirming it: the class
reading of r10uvm205's R0 names a population that is already equal.

---

## 8b. WHAT THE PATCHED CORPUS HEAD IS — R0

SeqDriver ×2 go **112 → 50 cmp lines**, the head object CLEARED, and the compare
walks on into a family of a different kind entirely (`head_pat_SeqDriver.*.cmp`):

```
LHS: ref_obj: (uvm_pkg::UVM_SET), line:217:31, endln:217:38
     |vpiParent: \_param_assign: , line:217:11, endln:217:38
     |vpiName:UVM_SET   |vpiFullName:uvm_pkg::UVM_SET
     |vpiActual: \_operation: , line:216:31, endln:216:48
RHS: constant: , line:217:31, endln:217:38
     |vpiParent: \_param_assign: , line:217:11, endln:217:38
     |vpiDecompile:131078 |vpiSize:32 |UINT:131078 |vpiConstType:9
     |vpiTypespec: \_ref_typespec: (uvm_pkg) -> int_typespec
```

**R0 — THE NEXT HEAD is a PARAM_ASSIGN RHS FOLD.** uvm-1.2
`base/uvm_object_globals.svh:216-217` gives a parameter whose RHS names an ENUM
CONSTANT of the same package; golden keeps a `ref_obj` to it whose `vpiActual`
is the defining `operation`, and we FOLD the whole thing to a `constant`
131078. That is a different family from every clone-import law: the decision is
whether a package parameter's elaborated RHS keeps its symbolic reference, and
the r10earl "elaborated Rhs typespec folds its range bound" line of work
(1bde8f99) is the nearest relative. Decide it on a golden grid over
`parameter X = ENUM_CONST;` and `parameter X = <expr of enum consts>;` in a
package, in both views, BEFORE any code.

MiniAmiq ×2 keep their pristine head at 112 lines with a **byte-identical cmp
log**: it is one of r10uvm205's six shared element refs (R1), which needs the
split-mint the array side has not had yet — the exact successor r10uvm205 named
and which is deliberately not attempted here.

---

## 9. RESIDUES

* **R1 — the SIX SHARED ELEMENT REFS are untouched, on purpose.** r10uvm205's
  R1, MiniAmiq's head. This law's exclusivity guard refuses them exactly as
  § 205's did; they are named one by one in `MOVERS.r10uvm207.txt` and their
  census cells read STILL-WRONG before and after with an identical payload.
* **R1′ — the SHARED ARRAY-OF-STRUCT holder (6 cells per moved row-mode).** Our
  emitter hands ONE `array_typespec` of `uvm_reg_bus_op` to a clone body's
  `accesses` declaration and to a HOME body's, in the ELABORATED listing only
  (`uvm_reg_map::do_bus_read` @1993 and `do_bus_write` @1850). Its
  `Elem_typespec` ref therefore has owner mask 3 and the law refuses it — the
  same shape as R1 one link further, and closing it needs the same array-side
  SPLIT.
* **R2 — a PRE-EXISTING SEGFAULT, recorded with a minimal reproducer.** A
  function whose RETURN TYPE is a package STRUCT typedef, cloned into a wildcard
  importer, makes our emitter exit **139 in the ELABORATED view at BASE
  `3e4de175`** — on the PRISTINE binary, before this pass's patch, and with the
  SAME rc on the patched one. `grid207/g207_i_retseg.sv` is the four-line
  reproducer. `verify_golden.py` records such an exit as `SLANG_REJECT` wearing
  the last stderr warning (RESUME.md §9), so it is pinned as an arm rather than
  hidden inside arm B, which is why arm B does not contain that shape.
* **R3 — the EXPLICIT-import clone.** `CompileHelper::importPackage`'s
  `object_name` filter clones a named import too, and golden bares that clone's
  struct members exactly as it bares a wildcard clone's (arm D, 4 def / 8 elab
  cells `gold=[t -> t]` against `ours=[t -> p::t]`). `pkgImportCloneTfs16` is
  WILDCARD-ONLY by § 194's committed fence, so arm D is BYTE-IDENTICAL on both
  binaries and the residue is left standing on purpose. It is now recorded by
  TWO passes (r10uvm205 R3 and this one) and is worth a pass of its own.
* **R4 — golden mints per declaration, we memoise per struct.** Golden's clone
  struct copies are one object per declaration; ours is one per struct, shared
  by every clone declaration. Invisible to the judge (no generated `Compare`
  reads `VpiParent`), and arms C, E and H — which go CMP_EQUAL — confirm it.
* **R5 — `uhdm-dump` still cannot see the ALIAS half of this family.** It does
  not print `vpiTypedefAlias`. Here the dump DOES see the other half — the two
  minted struct copies and their nine members, 121 lines, +121 / −0 — but a
  future pass in this family that only RE-POINTS an alias will again read 0 dump
  lines across a real change. `ct207cen` / `ct207cen --arena` are the
  attribution instruments; the arena view gains **9 `ref_typespec` rows and
  loses none**, which is the alias-visible half of the same edit.
* **R6 — the census is stricter than the judge.** Its keys carry the listing tag,
  the class, the subroutine, the block depth and the declaration span, so a shape
  difference between the two writers reads as a one-sided key
  (`only-golden 1062 / only-ours 472` on SeqDriver) even where the judge is
  satisfied. Those counts are IDENTICAL before and after, and the columns that
  decide a pass, `AWAY-GOLDEN` and `MOVED-WRONG`, are 0 on every row-mode and
  every arm.
* **R7 — a class PROPERTY of struct type is not in the census key set.**
  `ct207cen` keys declarations inside package SUBROUTINE bodies, so a class
  property (arm B's `prop207`) contributes no cell. Arm B's uhdm-cmp line count
  falling 3234 → 37 covers it end to end, but a future pass that wants the class
  property population sized needs the census key widened first.

---

## 10. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm207repro
for t in cen own pred ref; do
  g++ -O2 -std=c++17 ct207$t.cpp -I ~/.local/include \
      -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct207$t
done

# THE EDGE and THE SHARING (the decode of record)
/tmp/ct207own <golden.uhdm> <ours.uhdm> --chain=range --sub=m_set_mem_offset --members
/tmp/ct207own <golden.uhdm> <ours.uhdm> --share

# THE KIND TABLE and THE DECISION TABLE (re-point or split?)
/tmp/ct207cen <golden.uhdm> <ours.uhdm> --kinds
/tmp/ct207cen <golden.uhdm> <ours.uhdm> --decide
/tmp/ct207cen <golden.uhdm> <ours.uhdm> --holders

# WHAT THE LAW'S PREDICATE ADMITS AND REFUSES, on OUR database
/tmp/ct207ref <ours.uhdm> [--list] [--name=uvm_reg_bus_op]

# the grid (one real Surelog golden per arm, both views, both binaries)
for a in grid207/g207_*.sv; do
  CEN=/tmp/ct207cen bash grid207.sh "$a" <PRISTINE> <PATCHED> /tmp/w_$(basename $a .sv)
done

# the a-priori prediction, from a completed PRISTINE sweep workdir
PRED=/tmp/ct207pred bash predict207.sh <pristine workdir> /tmp/pred.txt

# the corpus census over the UVM row-modes (golden-vs-golden calibrated first)
CEN=/tmp/ct207cen bash cen207.sh <pristine wd> <patched wd> /tmp/cen

# the ORDER-BLIND, ALIAS-VISIBLE whole-database attribution
/tmp/ct207cen <pristine.uhdm> <patched.uhdm> --arena | sort   # then diff the two sides

# the WIDE boundary, from a COPY of the probe tree
PRIS=<pristine> PATCHED=<patched> bash bound207.sh <copy of tools/probe> /tmp/bound

# the guards
bash canaudit.sh canaries.sh ctcan2.sh
```
