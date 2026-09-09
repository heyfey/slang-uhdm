# r10uvm227 — § importedFreeCallTakesFirstListingImport227

**A bare call to a package free subroutine binds the copy held by the FIRST
wildcard-imported package, in WRITTEN IMPORT ORDER, whose subroutine listing
carries the name — the home object only when the home is itself listed first.
Instantiation is not a gate and the statement context is not a gate; the only
variable is the written order of the imports.**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted**. `GOLDEN_DEFER` stayed unset. The four slang-fenced
tests were never dispatched by any driver here and are named in no file of this
directory except `canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `a9eaac98` |
| pristine binary | md5 `437d06b01c501a1154f27f095a74a578`, built `-j 2` from this pass's OWN worktree at a clean `a9eaac98` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's `build/slang-uhdm` at that commit** |
| patched binary | md5 `fa1b8da08c9c93ec93b15779ed52ae08`, frozen `chmod 555`. **The deliverable patch applied to a FRESH `a9eaac98` worktree and built there comes out byte-identical to it** — every gate below was run on the binary the patch reproduces. |
| production surface | `include/UhdmExporter.h`, `src/ExprEmit.cpp`, `src/ModuleEmit.cpp` |
| probe surface | `tools/probe/r10uvm227repro/` only |

## THE RESULT, LOUDLY

**MiniAmiq×2 CONVERTS. The ladder bottomed out — the whole test closed.**

```
results/golden_surelog.csv:856  MiniAmiq,default,CMP_NOTEQUAL,decompile:,,
results/golden_surelog.csv:857  MiniAmiq,testflags,CMP_NOTEQUAL,decompile:,,
                    this sweep  MiniAmiq,default,CMP_EQUAL,,,differ
                    this sweep  MiniAmiq,testflags,CMP_EQUAL,,,differ
```

`rowheads.sh`: **1392014 cmp lines / 1 head / cmp rc=255 -> 0 cmp lines / 0
heads / cmp rc=0**, both modes. `ct227own`'s `design::Compare` on the whole
design reads **r=0**. `results/*.csv` were **NOT EDITED** — the promotion is the
master's to make.

---

## 1. THE QUESTIONS, ANSWERED IN ORDER

### (1) RE-MEASURED FIRST, on this pass's own pristine build

Before a line was written, on this pass's own `a9eaac98` build, with the
frozen binary named in every `cmds.txt`:

```
TEST           MODE      CMPLINES  HEADS NOTE
MiniAmiq       default    1392014      1 cmp rc=255
MiniAmiq       testflags  1392014      1 cmp rc=255
```

`ct227field` (r10uvm226's `ct226field`, copied verbatim) reads
`Process golden=1 ours=1 <-- DISAGREES`, and `ct227inner` (r10uvm226's
`ct226inner`, copied verbatim) names the failing element exactly as r10uvm226's
R0 recorded it:

```
ELEMENT[0] golden_type=2178 ours_type=2178 r=1 <-- DISAGREES
  failedLhs(golden) type=2060 name=cs  uvm-1.2/src/base/uvm_globals.svh 136:21..136:23
  failedRhs(ours)   <null>
```

**THE EXACT ADDRESS OF THE FAILING ELEMENT.** `ct227own` re-takes the head on
the `Process()` element pair in a fresh `CompareContext` (the design-level walk
names the CONTAINER — the vector overload sets both sides — so the cmp log
cannot say which object it was) and then scans EVERY golden edge that lands on
it with the generated, kind-agnostic `GetByVpiType`, so no field is named by
hand and none can be missed by omission:

```
HEAD LHS(golden) = class_var(cs)@136:21-136:23#22335
HEAD RHS(ours)   = <null>
HEAD LHS parent chain:
    < begin()@136:3-136:24#22328
    < function(uvm_report_enabled)@133:1-140:12#783
    < package(uvm_pkg)@28:1-39:11#1
    < design
OWNER: golden ref_obj(cs)@138:9-138:11 (inside hier_path `cs.get_root`),
       edge vpiType=700 (vpiActual), SINGULAR
```

so the failing edge is `ref_obj::Actual_group` on the `cs` of `cs.get_root()`
at `uvm_globals.svh:138:9`, and the owner is a copy of `uvm_report_enabled`.

**THE `vpiFunction` TARGET'S IDENTITY, BOTH SIDES — and it is the whole
answer.** Exactly ONE call to `uvm_report_enabled` in either database is hosted
by the interface, and the two sides point it at DIFFERENT copies:

```
GOLDEN  func_call(uvm_report_enabled)@114:10-114:57
          callee = function(uvm_report_enabled)@133:1-140:12#141642
          < begin < begin < initial < interface_inst()@25:1-647:13 < design
          #141642 is held by package(svaunit_pkg)#325     <- TopPackages
OURS    func_call(uvm_report_enabled)@114:10-114:57
          callee = function(uvm_report_enabled)@133:1-140:12#7804
          < begin < begin < initial < interface_inst()@25:1-647:13 < design
          #7804  is held by package(uvm_pkg)#6093         <- TopPackages
```

**THE FUNCTION BODY'S FULL BOTH-SIDES SHAPE, PER VIEW — and it already MATCHED.**
`ct227own`'s reference listing gives every reference in every copy of the free
function on both sides. The shapes are identical producer to producer; what
differs is only which copy the interface reaches:

| copy, by owning package | 137:3 `cs` | 138:3 `top` | 138:9 `cs` | 139:10 `top` | 139:33/43/52 |
|---|---|---|---|---|---|
| uvm_pkg (both views), **golden and ours alike** | BOUND | BOUND | **BARE** | **BARE** | io_decls |
| svaunit_pkg (both views), **golden and ours alike** | BOUND | BOUND | **BOUND** | **BOUND** | class_var `top` |

Golden's interface reaches the svaunit_pkg copy, whose `138:9 cs` IS bound;
ours reaches a uvm_pkg copy, whose `138:9 cs` is bare — and the SINGULAR
`SafeCompare` (`BaseClass.h:191-193`) then prints golden's `class_var cs` with
`RHS: <null>`. **Our clone BODIES were already right; only the ROUTE was wrong.**

### (2) THE TOPOLOGY, SETTLED FIRST — it is a per-package CLONE topology, and ours already matches golden's

`ct227pkg` reads the two databases' package sets. Six `uvm_report_enabled`
objects on each side, in the same shape:

```
                       GOLDEN                       OURS
TopPackages   builtin, uvm_pkg#1(58 tfs),      builtin, uvm_pkg#6093(58 tfs),
              svaunit_pkg#325(894 tfs)         svaunit_pkg#181518(894 tfs)
AllPackages   builtin, uvm_pkg#59749(894),     builtin, uvm_pkg#163(894),
              svaunit_pkg#183449(894)          svaunit_pkg#3074(894)
free-fn copies  uvm_pkg x2, svaunit_pkg x2       uvm_pkg x2, svaunit_pkg x2
class methods   uvm_report_object, uvm_sequence_item — 1 each, both sides
```

Both sides route the interface's call into a **TopPackages** copy, so the VIEW
is not the variable either. It is the PACKAGE: `svaunit_pkg` (golden) against
`uvm_pkg` (ours). That is why this is a routing law and not a clone-building or
a listing law.

### (3) THE PRODUCER, DECODED FROM SURELOG SOURCE

`CompileHelper::getTaskFunc`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:349-405`) resolves
a written call name in this order:

1. a name holding `::` is treated as `package::func` and resolved in that
   package — the branch our `boundClone` law already mirrors;
2. `while (comp)` — the CURRENT component and its parent scopes, linear-scanning
   `comp->getTask_funcs()`;
3. the component's own `FileContent`s;
4. **`getFuncFromPackage` (`:327-347`)** — `for (Package *pack :
   component->getAccessPackages())`, scanning **each access package's OWN
   `getTask_funcs()` listing IN ORDER** and returning the FIRST match, recursing
   into that package's own access packages only when it does not match.

Step 4 is the whole law. A wildcard import COPIES the entire transitive
subroutine listing into the importing package (§ collectPkgTfListing — our own
landed law, and Surelog's: `svaunit_pkg` carries 894 task_funcs where `uvm_pkg`
declares 58), so the scan STOPS at an importer whenever the importer is written
first, and the callee is the **importer's copy**. `svaunit_vpi_interface.sv:25-26`
writes

```systemverilog
interface svaunit_vpi_interface();
   import svaunit_pkg::*;
   import uvm_pkg::*;
```

— `svaunit_pkg` first — and the `` `uvm_info `` macro at line 101 expands to the
bare `uvm_report_enabled(...)` at `uvm_message_defines.svh:114:10`. Golden takes
`svaunit_pkg`'s copy. Nothing here is a shared-vs-clone question: both copies
exist in both databases and both are reachable; the resolver simply stops at the
first listing.

### (4) THE GOLDEN GRID — free-function locals × caller holders × contexts × views

`grid227.sh` over `grid227/`, twelve arms, every arm's `rc` recorded on BOTH
sides, `LISTED == PROCESSED` asserted, the arm list read on fd 3 with children
`</dev/null`, scratch keyed on the arm's relative path. Every arm builds the
same two packages: `p1` DEFINES `int f(int)` with a LOCAL (so the two copies are
distinguishable exactly as `cs` makes them distinguishable), and `p2`
wildcard-imports `p1`, so `p2` LISTS a copy.

| arm | holder | imports written | GOLDEN | pristine | patched |
|---|---|---|---|---|---|
| a1_iface_uninst | UNINSTANTIATED interface | `p2` then `p1` | **p2** | p1 | **p2** |
| a2_iface_inst | the SAME interface, INSTANTIATED | `p2` then `p1` | **p2** | p1 | **p2** |
| a3_module | module | `p2` then `p1` | **p2** | p1 | **p2** |
| a10_ctxs | interface, `initial` / `always_comb` / cont-assign / function body | `p2` then `p1` | **p2** ×4 | p1 ×4 | **p2** ×4 |
| a5_order_p1first | interface, ORDER REVERSED | `p1` then `p2` | **p1** | p1 | **p1** |
| a7_only_p1 | interface, the control | `p1` only | **p1** | p1 | **p1** |
| a4_pkg_holder | a call in package `p3`'s OWN body | `p2` then `p1` | p3's own | p3's own | p3's own |
| a12_p2_own_body | a call in package `p2b`'s OWN body | `p1` | p2b's own | p2b's own | p2b's own |
| a9_class_holder | a class METHOD inside package `p3` | `p2` then `p1` | **p2** | p3's own | p3's own (R1) |
| a6_only_p2, a8_qual_p2, a11_three_hops | — | — | golden compiles | **slang rc=3** | **slang rc=3** |

Read off the grid:

* **THE VARIABLE IS THE WRITTEN ORDER.** a1 and a5 differ in nothing but the
  order of two import statements and golden answers differently.
* **INSTANTIATION IS NOT A GATE** (a2 == a1) and **CONTEXT IS NOT A GATE**
  (a10's four contexts agree).
* **THE HOME'S OWN IMPORT ENDS THE SCAN** (a5, a7). This is the clause that
  keeps the law from degenerating into "always prefer a clone", which a5
  refutes outright — and it is the reason the whole uhdm2rtlil corpus does not
  move.
* **A PACKAGE'S OWN BODY IS THE OTHER LAW'S** (a4, a12): golden binds the
  holder package's own copy there, which we already do
  (§ collectPkgTfListing), and this pass's slot is never set during package
  emission, so those arms cannot move.
* **THREE ARMS TEACH ERROR RECOVERY, NOT GOLDEN** (a6, a8, a11, `slang_rc=3`,
  printed LOUDLY by the driver): they reach `f` ONLY through `p2`, and the LRM
  does not re-export a wildcard import, so slang rejects what Surelog accepts.
  They are recorded, not used. MiniAmiq is unaffected because its interface
  also writes `import uvm_pkg::*` — slang resolves the SYMBOL through the home
  and only the UHDM copy the call points at was ever in question.

**THE HOLDER LISTING FOLLOWS THE SAME LAW, and it is the second half of the
fix.** Golden's a1/a3 holder `Task_funcs` hold EXACTLY ONE entry and it is the
copy the call binds. Pristine listed TWO (the copy the import group already
materialized, plus a second push of the home object from the call site). With
the call-site registration switched to the resolved object, every one of a1,
a2, a3, a5, a10 now matches golden's holder listing in count AND identity.

### (5) WHERE SLANG DROPPED IT, AND THE GATED LAW

`src/ExprEmit.cpp`, the `CallExpression` arm. The pristine emitter consulted the
importer's copy (`importCopyFunc`, keyed `{importing package, home subroutine}`)
ONLY for a call carrying a WRITTEN `P::` qualifier; a BARE call always took
`siTf`, the home object out of `subMap` — which `emitPackage` deliberately
RESTORES at the end of each package view
(`src/ParamEmit.cpp:23363-23368`), so the importer's copy was unreachable from
any module or interface body.

The law adds one lookup, `firstImportListingClone227`, and changes ONLY THE
LINK:

* the scan walks the call site's own body scope members in written order,
  taking `SymbolKind::WildcardImport` entries — the same idiom `emitPackage`
  uses to build the copies;
* it STOPS and answers "home" the moment the home package itself is the import
  (a5, a7);
* otherwise it answers `importCopyFunc[{that package, &sub}]` for the first
  importer that has one;
* it sits BELOW the written-qualifier law and ABOVE the home object, so a
  qualified call is untouched;
* it changes **no name, no anchor and no `qualPkgCall18`** — golden's bare call
  keeps its bare `vpiName` and its whole-expression span, which the MiniAmiq
  head and grid a1 both confirm;
* the resolved object, not the home, is what the call registers in
  `importedTfCalls`, which is what collapses the holder listing to golden's one
  entry.

**THE WINDOW'S BOUNDARY IS SETTLED BY A DEDICATED, SAVE/RESTORED SCOPE.**
`currentScope` could not be used: `emitInstance` never sets it, so an elaborated
instance's content is emitted against whatever DEFINITION was compiled last
(earl57's 834 failed binds), and reading an import list off a stale scope would
re-route a call against a sibling module's imports. `callImportScope227` is set
— with an RAII guard, so nesting cannot leak — at the four places the emitter
really has the holder body in hand: `emitModuleDef`, `emitInstance`,
`emitInterfaceDef` and `emitInterfaceInstance`. It is **never set during package
emission**, and the helper additionally refuses while `curPkgEmitSym` is live,
so a4/a12/a9 cannot move. A null slot means "no redirect" and the pristine
binding stands, which is why the surface of this law is exactly the four
holders the grid measured.

### (6) THE CENSUS, PREDICTED FIRST — and the u2r zero PROVEN with a positive control

`ct227pred` + `predict227.sh` ran over EVERY database of the PRISTINE sweeps —
956 surelog, 1358 uhdm2rtlil, `LISTED == PROCESSED` on both — **before the
patched sweeps were started**, on the necessary conditions the law needs
(a package free subroutine that TWO packages list at the same span, and a BARE
call to it inside a module or interface holder):

```
surelog     CANDIDATES 12 / 956    (Earlgrey_0_1, FuncCase, FuncStruct,
                                    MiniAmiq, SeqDriver, SimpleUVM — each x2 modes)
uhdm2rtlil  CANDIDATES 16 / 1358   (for_break, ImportedFunctionCallAsInstantiated…GenFor,
                                    ImportedFunctionCallInModuleAndSubmodule,
                                    ImportedFunctionUsesAnotherFunction, rp32_r5p_alu,
                                    rp32_r5p_wbu, rsp_gen_minimal, simple_package — x2)
```

`byteverify.sh SELFCHECK=1` against this pass's own pristine sweeps then read

```
surelog     MOVERS 2 / 956    ./default/MiniAmiq-544c7f61  ./testflags/MiniAmiq-544c7f61
uhdm2rtlil  MOVERS 0 / 1358
```

Both mover sets are a SUBSET of the prediction, and both selfchecks flag
n−1 of n (the comparator can see).

**THE u2r ZERO IS NOT "THE LAW CANNOT REACH A MODULE".** Two independent
positive controls say so. First, the SAME patched binary MOVES grid arm
`a3_module` — a plain module holder, the u2r shape —
`5ba46d33…` → `eb58bdce…`, route `p1` → `p2`, toward golden. Second, the cell
census reads all 18 u2r candidate cells **already agreeing with golden on the
pristine binary**: every one of those designs writes exactly ONE wildcard
import and it is the HOME package, so the a5/a7 clause ends the scan. The zero
has a decoded reason, not an absence of evidence.

**THE CELL CENSUS** (`ct227cen` + `cen227.py`), golden vs pristine vs patched,
over every predicted candidate, with golden-vs-golden CALIBRATED FIRST on every
row (all-AGREE, no exceptions — the key is the holder `VpiDefName`, the call
name and the call's START line:col; the call's `VpiFile` is EMPTY on our side
and its END column differs by producer, so neither is in the key):

```
surelog     AGREE 231  TO-GOLDEN 4  AWAY-GOLDEN 0  MOVED-WRONG 0  STILL-WRONG 1
uhdm2rtlil  AGREE  18  TO-GOLDEN 0  AWAY-GOLDEN 0  MOVED-WRONG 0  STILL-WRONG 0
```

The four TO-GOLDEN cells are MiniAmiq's two calls in two modes:

```
work@svaunit_vpi_interface|uvm_report_enabled|114:10
    golden={svaunit_pkg @133:1-140:12} pristine={uvm_pkg …} patched={svaunit_pkg …}
work@svaunit_vpi_interface|uvm_report_info|115:8
    golden={svaunit_pkg @173:1-186:12} pristine={uvm_pkg …} patched={svaunit_pkg …}
```

The single STILL-WRONG is Earlgrey_0_1/testflags `work@hmac|conv_endian|135:33`,
golden 8 copies against our 16 — a PRE-EXISTING multiplicity difference with the
SAME package on both sides, identical on both binaries, and the row stays
CMP_EQUAL rc=0. It is recorded as R2, not dressed up.

### (7) THE CONVERSION, AND EVERY GATE

`GATES.r10uvm227.txt` carries all ten gates as run. In one line: goldens 23/0
with the `/bin/false` negative control 0/23; uhdm2rtlil 679/50/2 both modes with
`ct8rows` PASS against the committed gate AND against this pass's own pristine
sweeps; surelog `ct8rows` shows exactly THREE differing rows — the two MiniAmiq
CONVERSIONS quoted above and Earlgrey_0_1/testflags' DUMP COLUMN, whose database
is proven byte-identical; byteverify 2/956 and 0/1358, every mover predicted BY
NAME; the nine converted CMP_EQUAL row-modes all still read 0 lines / 0 heads /
**rc=0** (scored explicitly, both columns); canaudit `audited=29 UNCOVERED=0
FENCE-BREACH=0`; `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` held, and
InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical.

**After this pass every remaining surelog `CMP_NOTEQUAL` row-mode is one of the
four slang-fenced tests.** The addressable surelog NE set is empty.

---

## 2. THE WIDE BOUNDARY

`bound227.sh` over a COPY of the WHOLE probe tree, subdirectories included, both
views, every rc recorded: **LISTED 5663 PROCESSED 5663 MOVED_ARMS 18 RC_DIFFS 0**.
`bscore227.sh` re-scored every moved arm against a FRESH Surelog with the
official `uhdm-cmp` AND an order-blind dump distance, and with a DETERMINISM
control (the pristine binary run twice per arm — this pass's own grid arm
`a4_pkg_holder` produced THREE different md5s from three pristine runs, so an
md5 move is not by itself proof of a real mover):

```
TO-GOLDEN 10   SAME 6   AWAY-GOLDEN 0   NONDET-VIEWS 0   NO-GOLDEN 1
```

The ten TO-GOLDEN views are five arm files, and every one of them is the law
verbatim — the callee's owner package moves from the home to the first-listing
importer and the duplicate holder listing entry disappears:

| arm | cmp lines pristine -> patched | order-blind distance | what moved |
|---|---|---|---|
| r10uvm127repro/g127_c_import.sv | 7762 -> 7746 (def), 9710 -> 9078 (elab) | 682->670, 2297->2131 | `Ravelin::` -> `Sundial::` copies |
| r10uvm204repro/grid204/g204_b_ctx.sv | 11446 -> 11438, 15776 -> 15150 | 658->652, 4149->3993 | `quarryB204::` -> `sluiceB204::` |
| r10uvm31repro/t41a/dut.sv | 6838 -> 6830, 8102 -> 8014 | 1152->1146, 1904->1858 | `p31u::` -> `p31a::` |
| r10uvm31repro/t41b/dut.sv | 29392 -> 29360, 32404 -> 32052 | 4210->4186, 5775->5623 | `p31v::` -> `p31a::` (golden spells `p31a::v_lit` 7 times) |
| r10v186repro/v186_d_listing.sv | 22932 -> 22924, 29808 -> 28494 | 2565->2559, 7215->6823 | `Echinus186v::` -> `Fillet186v::` |

The six SAME views are **three known FALSE MOVERS** — `r10buvm22repro/g22.sv`,
`r10uvm154repro/l154_noenum.sv`, `r10uvm185repro/grid185/g185_e_kinds.sv` — and
the tell is exact: with the workdir path normalised, their ONLY differing dump
lines are `UINT:`/`vpiDecompile:` values that moved by **exactly 4096, one
page** (`22781689 -> 22785785`, `22780833 -> 22784929`); non-address differing
lines: **0** in all six views. That is the static-address false mover this
campaign has re-proved before, and the census reads zero movement in them.

The one NO-GOLDEN is `r10v124repro/v124_5_import.sv`: Surelog itself exits 4 on
it, so it teaches error recovery, not golden.

**NOT ONE arm of the must-stay floor moved** — none of r10uvm226 / 225 / 224 /
223 / 222 / 221 / 220 / 218 / 216, none of uvm82-91, none of buvm3-15, none of
sd8-12.

---

## 3. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct227own.cpp` | the owner-finder for a SINGULAR head whose VALUE is on the golden side, plus the topology reader (every matching function object with its parent chain, io_decls, Variables, Stmt), every reference in those bodies with what it binds, and every call with the callee it points at |
| `ct227pkg.cpp` | the package topology reader — TopPackages / AllPackages, every `package` object and the copy of a named function it holds |
| `ct227route.cpp` | the callee-route reader for ONE database: package listings, holder listings, and every call with its holder chain and callee owner |
| `ct227field.cpp`, `ct227inner.cpp` | r10uvm226's `ct226field` / `ct226inner`, copied verbatim so the head reading is the SAME instrument across the two passes |
| `ct227pred.cpp`, `predict227.sh` | the a-priori mover predictor, run over PRISTINE databases only, before the patched sweeps |
| `ct227cen.cpp`, `cen227.py`, `cenrun227.sh` | the cell census and its multiset join (Counters, never a last-writer dict) with a golden-vs-golden calibration on every row |
| `grid227/`, `grid227.sh`, `gscore227.sh` | the golden grid and its official-`uhdm-cmp` scorer, which reads databases BOTH binaries actually built |
| `bound227.sh`, `bscore227.sh` | the wide boundary and its re-scorer, with the per-arm determinism control |
| `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the shared gates, current generation |
| `GATES.*`, `GRID.*`, `BOUNDARY.*`, `BOUNDARY.score.*`, `CENSUS.*`, `PREDICT.*`, `BYTEVERIFY.*`, `HEADFIELD.*` | the recorded readings |

Build each `.cpp` per its own header comment; every driver takes the golden path
out of the workdir's own `cmds.txt` or names the canonical Surelog
`scripts/verify_golden.py` names.

---

## 4. RESIDUES

* **R0 — THE UVM CHAIN'S LAST WORKABLE ROW IS CLOSED; THE FAMILY'S NEXT FACE IS
  THE CLASS-METHOD HOLDER (grid arm `a9_class_holder`).** MiniAmiq×2 compares
  EQUAL and `design::Compare` reads r=0, so there is no successor head in it.
  The law's own grid names the one square still wrong: a call written in a
  CLASS METHOD inside a package that wildcard-imports another package binds, in
  golden, the FIRST IMPORTED PACKAGE's copy (`p2`), where we bind the enclosing
  package's own copy (`p3`) — the same resolver rule reached through
  `getFuncFromPackage`'s `component = the class`, whose own and whose parent's
  listings do not yet carry the name. Deliberately NOT taken here: it fires
  during package emission, where § collectPkgTfListing's landed law owns the
  `subMap` slot, so it needs its own grid and its own a-priori census. It costs
  ZERO corpus cells today — no corpus row moves on it — which is exactly why it
  is a residue and not this pass's work.
* **R1 — THREE LEGAL-SHAPE ARMS ARE SLANG REJECTS, AND THE LRM IS ON SLANG'S
  SIDE.** `a6_only_p2`, `a8_qual_p2` and `a11_three_hops` reach `f` only through
  a package that wildcard-imported it, which SystemVerilog does not re-export;
  slang exits 3 where Surelog compiles. Every one of them is a shape Surelog
  accepts and we cannot, so the law above can never be measured on them. Not a
  defect of this pass — recorded so the next reader does not mistake the rc for
  a regression.
* **R2 — Earlgrey_0_1/testflags LISTS `work@hmac|conv_endian|135:33` TWICE AS
  OFTEN AS GOLDEN** (16 cells against 8; default reads 165 cells on both sides,
  testflags 165 golden against 173 ours). Identical on the pristine and the
  patched binary, the SAME package on both sides, and the row is CMP_EQUAL rc=0
  — a multiplicity residue of the testflags elaboration, not a routing one.
* **R3 — THE HOLDER LISTING AND THE CALL ARE ONE LAW, AND ONLY THE HOLDER HALF
  IS PROVEN AT SCALE.** Golden's holder `Task_funcs` carry exactly the copy the
  call resolves to; the fix makes the call-site registration agree, and grid
  a1/a2/a3/a5/a10 match golden in count and identity. What is NOT measured is a
  holder that lists a subroutine NOTHING calls — the import group's own
  materialization pass still lists it, and whether golden lists the home or the
  importer's copy there is untested.
* **R-S (carried, re-confirmed) — an UNINSTANTIATED INTERFACE WITH A PORT LIST
  segfaults both binaries.** Every interface arm here is written `interface
  ifc();` with EMPTY parens for that reason. No corpus row reaches the crashing
  shape.
