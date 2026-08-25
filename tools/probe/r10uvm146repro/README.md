# r10uvm146 — § `unitImportHoistsPkgParams146` — **A `$unit` IMPORT MATERIALIZES THE PACKAGE'S PARAMETERS ON THE DESIGN, AND EVERY REFERENCE THAT CAN SEE THE DESIGN READS THAT COPY** — the `UVM_STR_CRC_POLYNOMIAL` head CLEARED on all three row-modes, 0 corpus rows changed

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `59e2cdc` (= UVM pass 144) |
| pristine binary | built from a clean worktree at `59e2cdc`, frozen `chmod 555` before any sweep; its head logs reproduce the brief's head object for object |
| patched binary | frozen `chmod 555` before any sweep |
| production surface | `src/UhdmExporter.cpp` + `include/UhdmExporter.h` ONLY — three static copy helpers, one enumeration block in `exportDesign`, one design-final re-point, one map member |
| probe surface | `tools/probe/r10uvm146repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SimpleUVM default / testflags** | 62 cmp lines, head = golden's `parameter (UVM_STR_CRC_POLYNOMIAL)` on `design (work@top)`, `vpiImported:uvm_pkg`, vs our `constant 32'h04c11db6` | **head CLEARED** — 60 lines on a NEW head object of a different family |
| **Scoreboard default** | 62, the same head | **head CLEARED**, the same new head |
| SeqDriver default / testflags | 6254, 1 head | head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 6222, 1 head | head log **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 174, 1 head | head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 64, 1 head | head logs **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL), byte-identical |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this pass's own pristine sweeps |
| byte movers | — | **3 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the three **PREDICTED BY NAME** from pristine+golden databases before the patched sweep ran |
| the law's design listing | `vpiParameter` **0** / `vpiParamAssign` **0** where golden lists **45 / 45** | **45 / 45**, byte-equal to golden's **IN ORDER**, on all three row-modes |
| the law's binding census | 53 references bound to a folded `constant`(43) / `operation`(10) | **`TO-GOLDEN 51 keys (53 cells) / AWAY-GOLDEN 0 / MOVED-WRONG 0 / ONLY-GOLDEN-CELL 0 / ONLY-OURS-CELL 0`** |
| the law's grid | 7 arms; listing 4 rows of 68; 7 wrong binding cells | listing **68/68 == golden IN ORDER on 7/7 arms**; binding `TO-GOLDEN 5 keys (7 cells) / AWAY 0 / MOVED-WRONG 0`; the negative-control arm's databases **BYTE-IDENTICAL** |
| golden calibration | — | golden-vs-golden residual **0** on every census |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`uvm-1.2 src/base/uvm_misc.svh:368` declares, inside `uvm_pkg`:

```systemverilog
parameter UVM_STR_CRC_POLYNOMIAL = 32'h04c11db6;
```

and `:385` reads it inside the package's own free function `uvm_oneway_hash`:

```systemverilog
crc1 = crc1 ^ UVM_STR_CRC_POLYNOMIAL;
```

```
LHS: parameter: (UVM_STR_CRC_POLYNOMIAL), line:368:11
     |vpiParent: design: (work@top)          |HEX:04c11db6
     |vpiTypespec: ref_typespec -> int_typespec 368:1-368:48
     |vpiName:UVM_STR_CRC_POLYNOMIAL         |vpiImported:uvm_pkg
RHS: constant: , line:368:36, endln:368:48
     |vpiParent: param_assign 368:11-368:48  |vpiDecompile:32'h04c11db6
```

**THE BRIEF'S FRAMING IS HALF REFUTED, AND THE MEASUREMENT IS WHY.** The brief
read this as golden's design-level parameter *"at the judge's slot"* in the
design's `Parameters` listing. It is not that slot. `design::Compare`
(UHDM generated `design.cpp`:272-309) reads `Parameters` TWELFTH, after
`AllPackages` which is SECOND — and the two `m_failed*` halves are set together
only when `BaseClass::Compare` trips on `VpiType` (generated `BaseClass.cpp`
:170-174). The slot is therefore a SINGLE `ref_obj::Actual_group`, reached
through `AllPackages -> uvm_pkg -> ... -> uvm_oneway_hash`:

| | golden | ours (pristine) |
|---|---|---|
| `ref_obj (uvm_pkg::uvm_oneway_hash::UVM_STR_CRC_POLYNOMIAL)` @385:21, `vpiActual` | `parameter (UVM_STR_CRC_POLYNOMIAL)` — the DESIGN-level imported clone | `constant` @368:36 — our `uvm_pkg` param_assign's folded Rhs |

`ct146own.cpp` proves it by masking: seeding the 45 golden design-level
`vpiImported` parameters into a fresh `CompareContext::m_visited` and re-running
the OFFICIAL `design::Compare` moves the head to
`array_typespec` vs `string_typespec` on `uvm_cmdline_parsed_arg_t.args`, and
that is EXACTLY the head the patched binary reads (`head_pat_*.cmp`).

**Why the design listing still has to be built.** The judge never reaches
`design->Parameters()` in these rows — but golden binds the reference to an
object that lives there, and `parameter::Compare`'s LAST field is
`VpiImported`, which only that copy carries. Building the listing is what
creates the object the binding needs, and it is what Surelog does.

## 2. THE DECODED MODEL — three Surelog sites, all cited

**(a) `CompileHelper::importPackage`, CompileHelper.cpp:199-241** — for every
entry of the imported package's `getParameterMap()`:

```cpp
Parameter* orig = param.second;
...
any* pclone = UHDM::clone_tree(p, &elaboratorContext);
if (pclone->UhdmType() == uhdmtype_parameter) {
  type_parameter* the_p = (type_parameter*)pclone;
  the_p->VpiImported(pack_name);          // :221
} else {
  parameter* the_p = (parameter*)pclone;
  the_p->VpiImported(pack_name);          // :229
}
parameters->push_back(pclone);            // scope->getParameters()
```

`getParameterMap()` is a **`std::map` keyed by NAME**, so this listing comes out
in **ASCII NAME ORDER**, not declaration order — and it carries **type
parameters in the same vector** as value parameters.

**(b) the same function, :242-277 ("Regular parameter")** — a SECOND, disjoint
object set: `clone_tree` of each `param_assign` in the package's own
`getParamAssignVec()` order, pushed onto `scope->getParam_assigns()`, with the
clone's `Lhs` stamped `VpiImported` at :274. It never pushes onto
`getParameters()` (the local `parameters` there is a documented dead store).

**(c) `UhdmWriter`, :4886-4910** hoists the FileContent's two vectors onto the
design and REPARENTS every entry (`tf->VpiParent(d)`).

**(d) `UhdmWriter::lateBinding`, :3359-3370** walks `ref->VpiParent()` UPWARD
and binds by name out of `design->Parameters()` the moment the walk reaches the
design — and that walk runs **BEFORE** the package rule at :3814-3822 that
hands a reference its `param_assign`'s **Rhs**:

```cpp
if (m && m->Param_assigns()) {
  for (auto p : *m->Param_assigns()) {
    if (lhs->VpiName() == name) {
      // Do not bind blindly here, let the uhdmelab do this correctly
      // Unless we are in a package
      if (m && m->UhdmType() == uhdmpackage) ref->Actual_group(p->Rhs());
```

So inside a `$unit`-imported package **every reference whose chain reaches the
design names the design's stamped copy**, and the package's folded value is
only reached when the walk never gets there. Our emitter had only the
package rule (`ExprEmit.cpp` "Package-function bodies keep a ref bound to the
param's def-view constant").

### The gate, and the shape that REFUTES the naive version

Two golden shapes split, and the split is the law's own test:

| chain from the `ref_obj` | golden binds |
|---|---|
| `operation > param_assign > package > design` (a package parameter's own initialiser) | the design copy |
| `func_call/assignment > begin > function > package > design` (a package function body) | the design copy |
| `... > function > class_defn > package > design` (a class method in the package) | the design copy |
| `range > logic_typespec > package > design` (the PACKAGE typedef `uvm_bitstream_t`'s `[UVM_STREAMBITS-1:0]`) | the design copy |
| **`range > logic_typespec > ref_typespec > logic_var > ...`** (uvm_string_to_bits's own `logic [UVM_LARGE_STRING-1:0]` local) | **the package's folded value** |
| **chain that never reaches a scope at all** | **the package's folded value** |

A DECLARATION's own typespec was resolved when the declaration compiled and
never went on the component's late-binding pool. The implemented gate is
therefore *reaches the design **without passing through a `ref_typespec`***, and
on golden SimpleUVM it splits the 59 candidate references **exactly 53 / 6**.

### The copy is compare-blind, and the field table proves it

`FIELDS.r10uvm146.txt`: over all 45 names, golden's DESIGN entry, golden's
`uvm_pkg` DEF entry and golden's `uvm_pkg` ELAB entry agree on **every field
`parameter::Compare` reads** (VpiDecompile, VpiSize, Typespec, VpiConstType,
VpiSigned, Expr, Ranges, Left/Right_range, VpiLocalParam, VpiName) and differ
only in `VpiImported`, the LAST field it reads. `VpiValue` is **not** compared
(generated `expr.cpp`:83-103). Ours match golden's package entries exactly.
A copy that SHARES every child pointer therefore cannot move any earlier field —
the same proof obligation § `classImportParamStamped82` discharges class-side.

The **param_assign** half is NOT view-blind: golden's design entries equal the
**ELABORATED** package listing (25 of 45 rows differ from the DEF listing —
`UVM_MACRO_EXTRAS = (1<<UVM_MACRO_NUMFLAGS)` is an `operation` in the def view
and a folded `constant` in the elab view and on the design).

## 3. THE GRID — seven arms, and two of them can only convict

`arm146.sh` builds Surelog golden + pristine + patched per arm; every child gets
`</dev/null`, the file list is read on fd 3, PROCESSED is asserted against
LISTED, scratch is keyed on the RELATIVE path, every rc is recorded, and the
binaries are printed so the run can be audited by path.

| arm | what it varies | golden listing | patched |
|---|---|---|---|
| `g146_a_forms` | wildcard / explicit-one-of-two / wildcard **and** explicit of the same package / a module-scope import that must NOT hoist | 8 params + 8 assigns | **identical, in order** |
| `g146_b_kinds` | untyped literal / typed / string / expression-of-others / localparam / **type parameter** / unreferenced, plus the unit's OWN parameter before and after the import | 9 params (one a `type_parameter`) + 8 assigns | **identical, in order** |
| `g146_c_owners` | the same package imported by a module, a program, a nested package and a class's container — and NOWHERE at `$unit` | **0 / 0** | **0 / 0, and both databases BYTE-IDENTICAL to pristine** |
| `g146_d_multi` | one package imported twice, another once, three instances of a leaf module | 5 + 5 | **identical, in order** |
| `g146_e_ordering` | the same package three times, interleaved with a second, plus a type-parameter-only package | 7 + 6 | **identical, in order** |
| `g146_f_binds` | the four reference shapes above, positive AND negative | 3 + 3 | **identical**; 5 cells TO-GOLDEN, the 2 negative cells UNMOVED |
| `g146_g_dup` | the same wildcard written three times | 3 + 3 | **identical, in order** |

Two things the grid REFUTED and the implementation then had to model:

* arm B refuted "only `parameter`": golden lists the **`type_parameter`** in the
  same sorted vector (and gives it no `param_assign`);
* arm D/G refuted the symbol-driven enumeration: **slang COLLAPSES** two
  identical `import p::*;` statements in one scope into ONE
  `WildcardImportSymbol`, Surelog does not. The import list is now read off the
  compilation unit's **syntax**, one entry per `PackageImportItem`.

Arm B also SETTLED the ordering question the corpus could not: the compilation
unit's **own** parameters come FIRST, then the imported ones sorted — which is
`FunctorCompileFileContentDecl` (declarations, CompileFileContent.cpp:39)
running before `FunctorCompileFileContent` (imports, :81-88).

`GRID.r10uvm146.txt` has the scorer output; `ARMS.r10uvm146.txt` the driver's.

## 4. THE CENSUS — depth-keyed, multiset, golden-calibrated

`ct146cen.cpp` emits one row per `ref_obj` whose name the design listing carries,
keyed **name x line:col x parent-chain** and valued by the ACTUAL's kind, plus
the listing itself in order. `score146.py` joins them as MULTISETS (a
last-writer dict would drop the rows this family has by construction: the same
name is listed by two package views, and by two import statements in arms D/G).

```
[SimpleUVM_default]    GOLDCAL 0   LISTING 0 -> 90 == golden IN ORDER
                       BINDING TO-GOLDEN 51 / AWAY-GOLDEN 0 / STILL-WRONG 1 /
                               MOVED-WRONG 0 / ONLY-GOLDEN-CELL 0 / ONLY-OURS-CELL 0
[SimpleUVM_testflags]  identical
[Scoreboard_default]   identical
```

The single STILL-WRONG key is **pre-existing and unchanged**
(`UVM_STREAMBITS@49:23` under an unparented `range > logic_typespec` chain:
golden carries 12 such dangling references, we carry 11 — pristine 11, patched
11). Both one-sided sets are **0**, so nothing was added where golden has none.

Corpus-wide, `ct146sum` was run over **every** golden database reachable from
this pass's own pristine workdir (2,974 distinct files behind 2,981 rows): only
**31** carry a design-level imported listing, and of those only the three target
row-modes produce a comparable database.

## 5. GATES — all green

`GATES.r10uvm146.txt` has every number. Headlines: goldens 23/0 (and 0/23 for
the `/bin/false` negative control); u2r 679/50/2 both modes with 0 differing
rows and **0/1358** byte movers; surelog 956 databases with **0 differing rows**
against the committed baseline AND against this pass's own pristine sweep and
**3/956** byte movers, all three predicted by name; canaries `ok=52 changed=0`
and `ok=8 changed=0`; both `ctcan2` PASS; `canaudit` `audited=29 UNCOVERED=0
FENCE-BREACH=0`; SVSwitch pinned at `4842211c4030` and YosysVerx at
`6ccda350c24a`.

## 6. BOUNDARY — 4,186 arms, 17 movers, all named

`bound146.sh` over a COPY of the whole committed `tools/probe` tree, top level
AND subdirectories, both views: `LISTED=4186 PROCESSED=4186 PRODUCED_DBS=4039
MOVED_ARMS=17 RC_DIFFS=0`.

* **6** are this pass's own `g146_*.sv` — the POSITIVE CONTROL. `g146_c_owners.sv`,
  the NEGATIVE control, is byte-identical and correctly absent.
* **10** earlier-pass arms had `design->Parameters()` EMPTY where their own fresh
  golden lists 1, 2 or 7 IMPORTED entries; the patched binary now lists EXACTLY
  golden's count in BOTH views. `r10earl31repro/v2_edge.sv`'s def-view cmp drops
  **64 -> 36** (its head clears). The arms whose ELAB cmp line count rises rise
  on a head object that CHANGED — their listings now equal golden's and their
  def-view head logs are unchanged.
* **1**, `r10buvm22repro/g22.sv`, has **no `$unit` import at all** and its design
  listing is 0 on golden, pristine and patched alike. What moved is three
  ALREADY-WRONG cells — the range bound of a class-scope ASSOCIATIVE array
  typespec, where golden writes `constant STRING:associative` and we write
  `operation(vpiSubOp, N, 1)`. **N is a raw pointer into the binary's own static
  data**: both binaries are NON-PIE, the last RW LOAD segment moves
  `0x156be70 -> 0x156de70` and the cell moves `0x1577eb9 -> 0x1579eb9`, the same
  `0x2000`. The arm's uhdm-cmp head log is BYTE-IDENTICAL and no corpus database
  carries the shape. Recorded as R2.

## 7. RESIDUES

* **R0 (the next head, all three rows).** `uvm_component.svh:1701-1704`
  `typedef struct { string arg; string args[$]; int unsigned used; }
  uvm_cmdline_parsed_arg_t;` — golden gives the `typespec_member (args)` an
  `array_typespec` (range `0 : $`, `vpiElemTypespec -> string_typespec`); we give
  it the bare `string_typespec` (the ELEMENT type). A QUEUE-TYPED STRUCT MEMBER
  loses its array typespec. 60 cmp lines, 1 head, identical object on
  SimpleUVM/default+testflags and Scoreboard/default.
* **R1.** `design->Typespecs()` is 123 on golden and 89 on ours on SimpleUVM (125 vs 91 on Scoreboard) in these three
  rows — the imported package TYPEDEFS the same `$unit` import materializes
  (`importPackage` :162-169 `scope->insertDataType`). It sits at field NINE of
  `design::Compare`, ahead of `Parameters`, so it is the head the moment the
  `AllPackages` subtree agrees. Same family, next step.
* **R2.** A class-scope associative-array typespec's range bound leaks a raw
  pointer as a `vpiUIntConst` (see 6). Different family; no corpus row.
* **R3.** A pre-existing multiplicity residue on unparented `range >
  logic_typespec` reference chains (golden 12, ours 11 for `UVM_STREAMBITS`;
  golden 2, ours 1 for `K_str`/`B_S` in the grid). Unchanged by this pass.

## 8. FILES

| file | what |
|---|---|
| `ct146own.cpp` | next-head predictor: masks the design-level `vpiImported` parameter set into a fresh `m_visited` and re-runs the OFFICIAL `design::Compare` |
| `ct146cen.cpp` | the census: design listing + every `ref_obj` of a listed name, with its ACTUAL kind, its reaches-the-design flag and its parent chain |
| `ct146fld.cpp` | the field table: exactly the fields `parameter::Compare` reads, DESIGN vs both package views |
| `ct146sum.cpp` | one-line design-listing summary (used to scan all 2,974 goldens) |
| `score146.py` | the multiset scorer (TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / MOVED-WRONG / one-sided sets), golden-calibrated |
| `arm146.sh` | the grid driver | 
| `bound146.sh` | the boundary gate |
| `refact146.awk` | dump-level `vpiActual` record extractor (the first, dump-only census) |
| `g146_*.sv` | the seven grid arms |
| `head_pris_*.cmp` / `head_pat_*.cmp` | the head logs, pristine and patched, for the rows whose logs are small |
| `BIGHEADS.r10uvm146.txt` | SeqDriver and MiniAmiq, both modes: their head object at this BASE decompiles to ~6,250 lines each, so they are stored as md5 PAIRS (the byte-identity claim) plus an excerpt; `rowheads.sh` reproduces them in full |
| `PREDICT` / `MOVERS` / `CENSUS` / `GRID` / `ARMS` / `FIELDS` / `GATES` / `BOUNDARY` / `DUMPDIFF` | the evidence |
