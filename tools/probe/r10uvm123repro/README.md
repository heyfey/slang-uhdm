# r10uvm123 — § `castPkgVecTdBareViewClone123` — **THE TARGET OF A CAST TO A PACKAGE RANGED `bit`/`logic` TYPEDEF IS A PER-USE CLONE, AND THE VIEW DECIDES WHICH LISTING OBJECT IT IS MADE OF** — the SimpleUVM ×2 / Scoreboard-default / BuildUVMPkg ×2 **148-line head CLEARED**

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS
ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `7bfb970` |
| pristine binary | reproduced the main tree's `build/slang-uhdm` at `7bfb970` BYTE FOR BYTE (md5 `94786b24b692c0fbd46e1fefacfb715a`), frozen `chmod 555` before any sweep |
| patched binary | md5 `1c0f7d3c9a5a42edbee112912da29d98`, frozen `chmod 555` |
| production surface | `include/UhdmExporter.h` (the law + the record), `src/ExprEmit.cpp` (the recording site, in the cast arm), `src/TypeEmit.cpp` (the design-final pass), `src/UhdmExporter.cpp` (one call) |
| probe surface | `tools/probe/r10uvm123repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **148** | **98** | 1 — a **NEW HEAD, a different object and a different family** |
| **Scoreboard default** | **148** | **98** | 1 — the same new head |
| **BuildUVMPkg default / testflags** | **148** | **98** | 1 — the same new head |
| SeqDriver default / testflags | 58 | 58 | 1 unchanged, head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 58 | 58 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 58 | 58 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes | |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine PREDICTED BY NAME from the PRISTINE databases before the patched sweep ran | |
| direction, all 9 movers | — | **TO-GOLDEN 6 / AWAY-GOLDEN 0** per row | |
| the cast-site family, SimpleUVM | 6 differing cells | **0** | |

`head_pris_*_*.cmp` are the whole 148-line pristine heads; `head_pat_*_*.cmp`
are the new ones.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduces the master's head log
for SimpleUVM/default **line for line** (ids aside), and BuildUVMPkg carries the
SAME head object at its own file/line (1800.2 `pp_output`).

```
LHS (golden)                                    RHS (ours)
bit_typespec (uvm_reg_cvr_t)  @105:10-105:22    bit_typespec (uvm_pkg::uvm_reg_cvr_t) @105:10-105:22
|vpiName: uvm_reg_cvr_t                         |vpiName: uvm_pkg::uvm_reg_cvr_t
|vpiTypedefAlias:                               |vpiParent: package uvm_pkg
\_ref_typespec (uvm_reg_cvr_t)                  |vpiInstance: package uvm_pkg
  |vpiActual:                                   |vpiRange -> range
  \_bit_typespec (uvm_pkg::uvm_reg_cvr_t)         |vpiLeftRange:
|vpiInstance: package uvm_pkg                     \_operation vpiOpType:11
|vpiRange -> range                                   UINT:32 , UINT:1
  |vpiLeftRange: constant INT:31 ct=7
```

`uvm-1.2 reg/uvm_reg_model.svh:105` is
``typedef  bit [`UVM_REG_CVR_WIDTH-1:0]  uvm_reg_cvr_t ;``, the macro expanding
to `32`.

### The object is NOT the package listing — the package listings AGREE

`pkgls114.cpp` (uvm114's instrument, REUSED) prints both producers' package
typedef listings and they agree object for object, in both views:

```
GOLDEN  ALLPKG uvm_pkg  bit_typespec 'uvm_pkg::uvm_reg_cvr_t'  L=OP11
        TOPPKG uvm_pkg  bit_typespec 'uvm_pkg::uvm_reg_cvr_t'  L=C{INT:31,ct=7}
OURS    ALLPKG uvm_pkg  bit_typespec 'uvm_pkg::uvm_reg_cvr_t'  L=OP11
        TOPPKG uvm_pkg  bit_typespec 'uvm_pkg::uvm_reg_cvr_t'  L=C{INT:31,ct=7}
```

`ctx123.cpp` names the walk position instead, by printing every `ref_typespec`
that points at the head object together with ITS parent chain:

```
GOLDEN  bit_typespec#46381 (uvm_reg_cvr_t)   UNPARENTED, alias -> #28165 (the TOPPKG listing)
  <- ref_typespec#46386 full=uvm_pkg::uvm_mem::set_coverage
     design/package#1(uvm_pkg)/class_defn(uvm_mem)/function(set_coverage)
       /begin/operation{op14}@1406:8/operation{op67}@1406:17
OURS    bit_typespec#652 (uvm_pkg::uvm_reg_cvr_t)  = the ALLPKG listing object
  <- ref_typespec#28964 full=uvm_pkg::uvm_mem::set_coverage
     design/package#3056(uvm_pkg)/class_defn(uvm_mem)/function(set_coverage)
       /begin/operation{op14}@1406:8/operation{op67}@1406:17
```

`op67` is `vpiCastOp`. `uvm_mem.svh:1406` is
``if (is_on == uvm_reg_cvr_t'(UVM_NO_COVERAGE)) begin``. **The head is a CAST
TARGET**, and ours is the package's DEF listing object where golden's is a
per-use clone of the ELABORATED one.

---

## 2. THE DECODED MODEL

### Where the clone comes from

`CompileExpression.cpp:2676` (`paCast` / `paConstant_cast`) compiles the cast's
target with

```c++
if (UHDM::typespec* tps = compileTypespec(component, fC, Simple_type,
                                          compileDesign, reduce, operation, ...)) {
  ...
  operation->Typespec()->Actual_typespec(tps);
```

For a BARE identifier that reaches `compileDatastructureTypespec`'s `SimpleType`
arm (`CompileType.cpp:882-896`):

```c++
} else if (const SimpleType* sit = datatype_cast<const SimpleType*>(dt)) {
  result = sit->getTypespec();
  if (parent_tpd && result) {
    if (typespec* new_result = any_cast<typespec*>(UHDM::clone_tree(result, ...))) {
      if (new_result->Typedef_alias() == nullptr) { ... }
      new_result->Typedef_alias()->Actual_typespec(result);
      result = new_result;
```

— a `clone_tree` copy with a `Typedef_alias` back at the object it was made of.

### Why the clone's name is BARE and the listing's is qualified

`UhdmWriter::writeDataTypes` (`UhdmWriter.cpp:789-796`) qualifies the LISTING
object **in place**, at write time, long after every clone was taken:

```c++
if (parent->UhdmType() == uhdmpackage) {
  if (tps && (tps->VpiName().find("::") == std::string::npos)) {
    const std::string newName = StrCat(parent->VpiName(), "::", tps->VpiName());
    tps->VpiName(newName);
```

So the clone keeps the name the typedef had at clone time (`uvm_reg_cvr_t`) and
the alias target ends up carrying `uvm_pkg::uvm_reg_cvr_t`. Nothing special-
cases the clone; it simply is not in any package's `datatypeMap`.

### Why the BOUND is view-dependent

`FunctorCompilePackage` (`CompilePackage.cpp:63/68`) compiles every package
TWICE — the elaborated `Package` with `Reduce::Yes` and its `getUnElabPackage()`
twin with `Reduce::No` — so a package vector typedef has TWO typespecs, one with
the bound's operation tree and one with the folded constant (uvm114 / buvm30's
decode; `compileRanges`, `CompileExpression.cpp:4006-4025`). The cast is
re-compiled per view, and `compileTypespec` clones whatever the typedef's
`getTypespec()` holds in THAT compile. Measured on golden, in this order of
generality:

| where the cast is written | object cloned | bound |
|---|---|---|
| the typedef's OWN home package, **un-elaborated** view | the DEF listing | **symbolic** |
| the typedef's own home package, elaborated view | the TOP listing | folded |
| a CLASS declared in that package (in-body and out-of-body method) | the TOP listing | folded |
| ANOTHER package's subroutine, either view | the TOP listing | folded |
| a WILDCARD-IMPORT CLONE of a home subroutine, either view | the TOP listing | folded |
| a module / interface subroutine, a module-declared class's method, module scope | the TOP listing | folded |

### The clone's `vpiInstance` is the TYPEDEF'S HOME package

…in the view it was cloned from — **never** the last package to LIST the object.
`cast123.cpp` with `CAST123_IDS=1`, on `g123_c_otherpkg.sv` (`cedar123_b` imports
`cedar123_a`), golden:

```
ALLPKG op@10:10 cone_BT L=OP11        alias=cedar123_a::cone_BT inst=package#78 (AllPackages[cedar123_a])
ALLPKG op@20:10 cone_BT L=C{INT:5}    alias=cedar123_a::cone_BT inst=package#1  (TopPackages[cedar123_a])
TOPPKG op@10:10 cone_BT L=C{INT:5}    alias=cedar123_a::cone_BT inst=package#1
```

and `g123_e_twopkg.sv` reads the same for a class in the IMPORTING package.
That is why this pass keeps its OWN copy memo instead of LAW S's: LAW S's copy
inherits the LISTING object's instance, which an importer's listing pass has
already moved (§ `pkgImportAggCloneLastWriter32`'s rule for the listing object).
Binding LAW S's shared copy moved that field AWAY from golden on arms C and E —
caught by the arm score before any sweep ran, and fixed by the private memo.

### § `castPkgVecTdBareViewClone123`

> The target typespec of an explicit cast whose target is written as a **BARE
> identifier** naming a package **`bit`/`logic` typedef with a packed range** is
> a per-use `clone_tree` copy: BARE typedef name, a `Typedef_alias`
> `ref_typespec` back to the package's LISTING object, and the range bounds and
> `vpiInstance` of the listing object OF THE VIEW THE CAST SITE LIVES IN — the
> un-elaborated one only inside the typedef's OWN home package's def view (never
> in an import clone), the ELABORATED one everywhere else. The clone's
> `vpiInstance` is the typedef's HOME package in that same view.

### FIVE FENCES, each a refusal to move a cell this pass did not measure

1. **Only a `vpiCastOp`'s own target typespec** is recorded.
2. **Only `bit_typespec` / `logic_typespec` WITH a non-empty range vector.** An
   ENUM, STRUCT or PACKED-ARRAY cast target keeps the listing object, which is
   what golden binds there — `g123_f_kinds.sv` reads all five kinds off one
   golden and the enum/struct cells already agreed; 35 enum cast cells in
   SimpleUVM alone agree today and are left untouched.
3. **Only a BARE written target.** `b29::v_td'(x)` resolves through the
   package's type table and golden binds the LISTING object itself, qualified
   and unaliased, while `v_td'(x)` in the SAME method gets the clone. Measured
   on TWO independent goldens: `r10buvm29repro/g29_b_targets.sv` (an earlier
   pass's arm, which holds both spellings of one typedef) and this pass's own
   `g123_g_scoped.sv`. **Without this fence the pass moved g29_b's scoped cell
   AWAY from golden** — the wide boundary is what caught it.
4. **Only a ref that still names a listing object** of that typedef, so a clone
   another law already minted (ExprEmit's own module-scope / home-package-
   subroutine / `$unit` arm) is that law's answer.
5. **Same `UhdmType`, same range-vector LENGTH** between the listing object
   installed and the one replaced.

---

## 3. THE CHANGE

Four production edits, no new file:

* `include/UhdmExporter.h` — the law, `CastPkgTdSite123`, the recorded site
  vector and the private copy memo.
* `src/ExprEmit.cpp` (the `ConversionExpression` cast arm, at the shared
  `rt->Actual_typespec(cts)` wrap) — RECORD `(ref_typespec, typedef symbol,
  home package, defView)`. Only the emission site knows the view: `defView` is
  `home == curPkgEmitSym && !pkgImportCloneEmit && (currentSubSym ?
  pkgDefViewBody9 : !pkgEmitTopView)`, and `pkgDefViewBody9` is exactly
  "un-elaborated package view" for a subroutine body, class-method clones
  included (§ 9's own definition).
* `src/TypeEmit.cpp` — `castPkgTdCloneViewTs123()`, the design-final re-point.
* `src/UhdmExporter.cpp` — one call, immediately after `bareScalarTypedefVarTs()`
  (LAW S) so the two alias passes that follow treat a cast copy exactly as they
  treat a variable's.

`R10U123_CASTTDDBG=1` prints the recorded count and one line per re-point.

---

## 4. GRIDS

`arm123.sh` builds one arm with Surelog (golden) and with BOTH frozen binaries,
in BOTH views, censuses each with `cast123` and scores with the OFFICIAL
`uhdm-cmp`. Scores in `ARMS.r10uvm123.txt`; every arm is NON-INCREASING:

| arm | topology | pristine | patched |
|---|---|---|---|
| `g123_a_clsmethod.sv` | a package class's in-body AND out-of-body methods cast bit / logic / plain-bound / enum typedefs of their own package | 18 | **0** |
| `g123_b_modsub.sv` | module SCOPE and a module SUBROUTINE cast an imported bit and logic typedef | 9 | 3 |
| `g123_c_otherpkg.sv` | the home package's function AND a second package's function (import clones) | 20 | 8 |
| `g123_d_modclass.sv` | a class declared in a MODULE, and an INTERFACE subroutine | 8 | **0** |
| `g123_e_twopkg.sv` | two packages, the second wildcard-imports the first; classes in both | 14 | 4 |
| `g123_f_kinds.sv` | the KIND grid: bit / packed-array-of-typedef / enum / packed struct / plain-bound logic | 6 | 2 |
| `g123_g_scoped.sv` | ONE typedef cast BARE and PACKAGE-SCOPED in the same method (fence 3) | 4 | **0** |

and the four earlier-pass arms the wide boundary flagged, re-measured against
their own goldens: `r10buvm29repro/g29_b_targets` 2 → **0**,
`r10v118repro/v118_a3_written_fences` 8 → 4,
`r10vbuvm29repro/gv29_e_targets` 6 → 2,
`r10vbuvm29repro/gv29_g_tdname` 4 → **0**.

---

## 5. GATES

All green. **NO row converted, nothing promoted, `results/*.csv` untouched.**
`GATES.r10uvm123.txt` carries the battery verbatim; the headlines:

* goldens **23 / 0** (pristine AND patched); `SLANG_UHDM=/bin/false` **0 / 23**.
* uhdm2rtlil **679 / 50 / 2** in both modes; `ct8rows` **0 differing rows**
  against the committed baseline and against this pass's own pristine CSVs;
  byteverify **MOVERS 0 / 1358**.
* surelog `--mode both`: **471/283/25/10/5** (default) and
  **466/284/23/9/5/3/2/1/1** (testflags) — every histogram identical to this
  pass's own pristine sweep; `ct8rows` **0 differing rows over 1588** against
  `results/golden_surelog.csv`.
* byteverify **MOVERS 9 / 956**, every one PREDICTED BY NAME
  (`PREDICT.r10uvm123.txt`, computed from the PRISTINE databases alone by
  `pred123.sh` before the patched sweep ran), attributed order-blind row by row
  (`MOVERS.r10uvm123.txt`, `ATTR.r10uvm123.txt`) and scored for DIRECTION
  (`SCORE.r10uvm123.txt`: **TO-GOLDEN 6 / AWAY-GOLDEN 0** in all nine).
* canaries **ok=52 / ok=8, changed=0**; `ctcan2` PASS on both corpora;
  `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**; the five protected
  databases byte-identical, `SVSwitch 4842211c4030` and
  `YosysVerx 6ccda350c24a` pinned.
* **wide boundary**: 3746 arms × 2 views × 2 binaries, PROCESSED asserted,
  **7176 identical / 22 DIFFERING**. Fourteen are this pass's own arms (the
  POSITIVE CONTROL that the gate can see this law); the other eight are the four
  earlier-pass arms above, each re-measured against golden and NON-INCREASING.
  All 28 `rc=139` cells occur on BOTH binaries (14 arms × 2).

### Attribution of one mover, order-blind (SimpleUVM/default)

`removed=6 added=45`: six cast bindings move off the package listing object, and
three new clone objects appear (one per distinct listing object — `uvm_reg_cvr_t`
DEF, `uvm_reg_cvr_t` TOP, `uvm_reg_data_t` TOP), each contributing exactly one
`vpiName` / `vpiFullName` / `vpiTypedefAlias` / `vpiActual` / `vpiInstance` /
`vpiRange` / `vpiParent` line. Nothing else in either database moved.

### The new head (all five row-modes)

`uvm_mem.svh:1664` — `value_s[value_s.len()-1]`: a `bit_select` whose
`vpiIndex` is `vpiOpType:11` over a `hier_path (value_s.len)` and `UINT:1`.
Golden's `hier_path` carries two `vpiActual`s (a `ref_obj` and a
`method_func_call`); see `head_pat_default_SimpleUVM.cmp`.

---

## 6. RESIDUES

* **R1 — the wildcard-import CLONE body's alias target.** Golden gives a cast
  clone inside a wildcard-import subroutine clone a BARE alias target
  (`alias=cone_BT`, a copy of a copy) where we give the qualified listing
  object. That is § `importCloneBareTdAlias16`'s law, whose walk reaches only a
  clone `task_func`'s `Io_decls` and `Variables` — not its statement tree, so a
  cast binding inside the body is out of its reach. Two of SeqDriver's and
  MiniAmiq's six moved cells stop one field short of golden for this reason
  (they still move TOWARD it: name and bound become golden's, and the alias goes
  from ABSENT to present-but-one-level-off). Witnesses:
  `g123_c_otherpkg.sv` @10:10/@11:10 and `g123_e_twopkg.sv`. **Extending
  `importCloneBareTdAlias16` to the recorded cast refs whose site carried
  `pkgImportCloneEmit` would close it in about four lines** — deliberately not
  done here, because it would move cells in two more databases than this head
  needs.

* **R2 — ExprEmit's OWN cast clone keeps the DEF view's symbolic bound.** The
  pre-existing arm (module scope / home-package subroutine / `$unit`, `logic`
  only) mints its clone with `tfContext = homePkgSub0 ? !pkgTopEmit : !homeUnit0`
  and so leaves the bound symbolic where golden folds — visible on
  `g123_b_modsub.sv` @15:16 (golden folds `C{INT:8}`, we write `OP11`) and on
  `g123_c_otherpkg.sv` @11:10's clone-body cell. Identical on the pristine and
  the patched binary; fence 4 keeps this pass off those refs on purpose, because
  the fold rule there is that arm's to fix, not this one's.

* **R3 — a packed-array cast target is the WRONG KIND.** `g123_f_kinds.sv`
  @19:13: golden binds a `packed_array_typespec` (`L=C{UINT:3}`, with an alias
  to an unnamed typespec); we emit a rangeless `bit_typespec` named
  `fir123_pkg::FIR_WORD_T`. A different defect entirely — fence 2 keeps this
  pass away from it. Zero corpus witnesses.

* **R4 — the ENUM cast target's `vpiInstance`.** `g123_e_twopkg.sv` @29:11:
  golden names the IMPORTING package, we name the home one. That is
  § `pkgImportAggCloneLastWriter32`'s family for an enum import clone;
  identical on both binaries.

* **R5 — the per-use clone COUNT.** Golden mints one clone per USE, we share one
  per listing object (SimpleUVM: `cen123`'s GOLD-ONLY 563 / OURS-ONLY 198,
  unchanged by this pass). uvm114's residue R3, invisible to the judge — no
  generated `Compare` reads `VpiParent` and every shared object carries the same
  Compare-visible fields.

* **R6 — our enum-cast operations have no package ancestor.** `cast123`'s view
  column reads `OTHER` for eight SimpleUVM enum cast sites where golden reads
  `ALLPKG`/`TOPPKG`; the PAYLOADS are identical. A parenting residue only, and
  the reason this pass reads the view off the EMISSION SITE (`pkgDefViewBody9`)
  rather than off a parent walk.

---

## 7. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it measures |
|---|---|
| `cast123.cpp` | every `vpiCastOp` whose target is a named package typespec: the view (`TopPackages` / `AllPackages` / module), the op span, and the target's judge-visible fields (kind, name, both bounds, alias target name, instance). The oracle for this family. |
| `cen123.cpp` + `join123.py` | the WIDE use-site census: every `ref_typespec` naming a package vector/array typedef, keyed by its parent chain (kinds+names+spans, NO ids) and joined as MULTISETS. |
| `ctx123.cpp` | the head decoder: full parent chain with ids, fold state, `Typedef_alias`, `vpiInstance`, and every `ref_typespec` that points at an object with ITS chain. |
| `pred123.sh` | the A-PRIORI mover predictor: a database moves iff it holds a cast whose target is a ranged bit/logic typespec wearing a package-qualified name. |
| `score123.py` | the DIRECTION score, golden vs pristine vs patched, over the cast census. |
| `attr123.sh` | order-blind whole-dump attribution of one mover. |
| `arm123.sh` | one arm, Surelog + both frozen binaries, both views, census + official cmp. |
| `vwide123.sh` | the wide boundary (list on fd 3, children `</dev/null`, PROCESSED asserted, rc per cell). |
| `owner114.cpp`, `pkgls114.cpp`, `tdclone114.cpp` | uvm114's instruments, REUSED unchanged. |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standing gates. |
