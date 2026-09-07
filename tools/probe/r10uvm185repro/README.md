# r10uvm185 — § `externProtoRetVarKindIsPrototypeCompile185` — **AN `extern` CLASS METHOD'S PROTOTYPE LISTING COMPILES ITS RETURN VARIABLE FROM THE PROTOTYPE, IN THE CLASS** — the BuildUVMPkg ×2 52-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list — the wide boundary compiles `tools/probe`
arms exclusively and dispatches no corpus test at all.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b71d5feb` |
| pristine binary | md5 `bc09e77cf8fd251285c06f6f0b54a5bc`, built from this pass's OWN worktree at a clean `b71d5feb` and frozen `chmod 555` before any sweep — **byte-identical to the master's own pristine at that commit** |
| patched binary | md5 `888a51d91d62274dde0c4843f008c488`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` (the law, the four terms and the golden tables that convict each of them), `src/TaskFuncEmit.cpp` (the one call-site substitution at the return-variable site) |
| probe surface | `tools/probe/r10uvm185repro/` only |
| docs | `RESUME.md` §3b — the BuildUVMPkg row, refreshed with the head this landing produced (it rides with the code, per the standing direction) |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **BuildUVMPkg default and testflags, 52 cmp lines, ONE head each → 48**. The two modes' databases are BYTE-IDENTICAL before (`5c6a62b63407…`) and after (`bbf172cd412b…`), and so are the two cmp logs (`14154829ad19…`). A cmp line count is the HEAD OBJECT'S decompile size (RESUME.md §7); `uhdm-cmp` prints it to stdout AND stderr, which is why `rowheads.sh`'s figure is twice the 24 lines one stream carries. |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines, against the master's controls at `b71d5feb`, AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **3 / 956** surelog: BuildUVMPkg default and testflags (**both PREDICTED BY NAME before the patched sweep ran**, from the 956 PRISTINE databases alone) plus `default/Scoreboard`, which is RESUME.md §9's ~50/50 COIN and is PROVEN here to be one on the PRISTINE binary alone (§7). **0 / 1358** uhdm2rtlil, also predicted (0 candidate rows over all 1358 pristine databases). |
| the census (nine UVM DBs × both modes) | 45 910 `function` cells joined golden-vs-ours on the decoded face. On the PROTOTYPE arm: **KIND-DIFF 2 → 0**, AGREE 4914 **unchanged**, and no cell moved AWAY or MOVED-WRONG. The DEFINITION/in-body arm (37 682 AGREE) is untouched to the cell. |
| the grid (5 arms, both views) | 848 cells: **TOWARD 104, AWAY 0, MOVED-WRONG 0**, AGREE 634, STAY-BAD 12 (the R2 array row this law declines), plus 24/74 one-sided keys that are a PRE-EXISTING naming/listing residue identical on both binaries (§6.3). |
| the WIDE boundary (5022 arms, both views) | `LISTED=5022 PROCESSED=5022`, **RC_DIFFS 0**, MOVED_ARMS **19** (4 of them this pass's own — the positive control). EVERY moved arm is scored against GOLDEN: **AWAY 0, MOVED-WRONG 0**, and every moved cell in the whole tree is a `stmt=0` PROTOTYPE listing's return variable — the exact population the law names. |
| the FLOOR (uvm170's arms and BOTH fences, uvm181/182/183's arms, uvm82-91) | **byte-identical under both binaries** — absent from the boundary's moved list entirely. buvm3-15 and sd8-12 DO move (buvm9's three arms, sd10/11/12's `g7_return_var.sv` and `v5_oob_extern.sv`), and every moved cell in them is TOWARD golden; `g7_return_var.sv` is the arm the law was DECODED from. §8.1. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `b71d5feb` worktree; it
came out **byte-identical to the master's frozen pristine**
(`bc09e77cf8fd251285c06f6f0b54a5bc`), and its own 956-row surelog sweep and
1358-row uhdm2rtlil sweeps reproduced the committed baselines **row for row**
(`ct8rows` 0 differing rows, status AND dump column, against
`results/golden_surelog.csv`, `results/gate_uhdm2rtlil.csv` and the master's
three control CSVs at `b71d5feb`). Every `cmds.txt` in both sweeps names this
pass's own frozen binary (1523 surelog + 1458 uhdm2rtlil rows, audited by
PATH).

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         29      1
SeqDriver      testflags       29      1
SimpleUVM      default     664681      1
SimpleUVM      testflags   664681      1
Scoreboard     default         95      1
MiniAmiq       default         29      1
MiniAmiq       testflags       29      1
BuildUVMPkg    default         52      1     <- THIS PASS
BuildUVMPkg    testflags       52      1     <- THIS PASS  (same database)
Earlgrey_0_1   default         31      1
Earlgrey_0_1   testflags      364      1
Rggen          default          0      0
```

The head object, both modes:

```
uvm_pkg.sv:19055   extern virtual function uvm_policy::recursion_state_e object_printed(…);
uvm_pkg.sv:20364   function uvm_policy::recursion_state_e uvm_printer::object_printed(…);
uvm_pkg.sv:18219   typedef enum { NEVER, STARTED, FINISHED } recursion_state_e;   (inside class uvm_policy)

LHS golden  enum_var  () @19055:27-19055:56   vpiTypespec -> ref_typespec -> enum_typespec(recursion_state_e)@18219:1
RHS ours    class_var () @20364:10-20364:39   vpiTypespec -> ref_typespec -> enum_typespec(recursion_state_e)@18219:1
```

Both sides point at **the same `enum_typespec`**, carry the same full name and
the same parent `function`. The ONLY compared difference is the object's
**UhdmType**, which fails inside `BaseClass::Compare`'s VpiType line. The spans
differ too and are NOT compared (RESUME.md §9) — that is R1.

## 2. DECODING THE JUDGE FIRST — `ct185own`, ON BOTH MODES

`ct185own.cpp` links the SAME generated `Compare` the judge does. Beyond
r10uvm170's owner chain / referrer index / ablation it answers the three
questions this brief demands, by replaying `task_func::Compare`'s **own** field
order (transcribed from
`~/git-repos/UHDM/build/generated/src/{task_func,function}.cpp`) over the owner
pair. Full output: `LADDERS.r10uvm185.txt`.

**(1) THE FAILING EDGE AND ITS OWNER CHAIN.** The head is parentless-free: its
sole referrer, on both sides, is its own owner through **`task_func::Return`**:

```
GOLDEN  REF .Return  rel1  function(object_printed)@uvm_pkg.sv:19055:3-19055:9 #146489
                             < class_defn(uvm_printer)@18932:9-19282:9
                             < package(uvm_pkg)@7351:1-83263:11  < design
OURS    REF .Return  rel1  function(object_printed)@:19055:3-19055:9 #52135
                             < class_defn(uvm_printer)@18932:9-19282:9
                             < package(uvm_pkg)@7351:1-83263:11  < design
        REFERRERS=1 on each side
```

The owner's span `19055:3-19055:9` is the **`extern` keyword**, on BOTH sides:
this `function` object is the CLASS-BODY PROTOTYPE listing, not the definition.

**(2) EVERY SIBLING EDGE ON THE SAME OWNER.** All 22 compared fields of that
`function`, both sides, in the judge's order — VpiType, VpiName, VpiDefName,
VpiMethod, VpiAccessType, VpiVisibility, VpiVirtual, VpiAutomatic, the four DPI
properties, Left_range, Right_range, **Return**, Class_defn, Io_decls, Stmt,
Instance, VpiSigned, VpiSize, VpiFuncType — agree except `Return`. (The tool
also flags `Io_decls` when each element is re-compared in a FRESH
`CompareContext`; under the judge's own shared `m_visited` it passes, which the
ablation below proves.)

**(3) THE NEXT TWO FIELDS IN THE JUDGE'S ORDER** after `Return` are
`Class_defn` (null on both sides) and `Io_decls` (2 elements on both sides), and
then `Stmt`, `Instance`, `VpiSigned`, `VpiSize`, `VpiFuncType`. So the ladder
past this head does not stay on this owner — and the ABLATION (seed the golden
head into a fresh context's `m_visited`, re-run the OFFICIAL `design::Compare`)
confirms it, identically in both modes:

```
ABLATION  NEXT LHS(golden) = int_typespec(UVM_FILE)@uvm_pkg.sv:8459:9-8459:12
          NEXT RHS(ours)   = int_typespec()@:8461:11-8461:19
          VERDICT: THE HEAD MOVED (this object was the whole head)
CHAIN 1..4   the same family, three more `UVM_FILE` parameters
```

That prediction is exactly what the patched binary produced (§5) — R0 below.

## 3. DECODING SURELOG — WHY GOLDEN HAS **TWO** RETURN VARIABLES

An `extern` class method is compiled **TWICE**, and the two compiles are given
different components and different syntax nodes.

* `src/DesignCompile/CompileClass.cpp:526-577`, the `paMethod_prototype` arm:
  `m_helper.compileFunction(m_class, fC, fC->Child(id), …)`. The component is
  **`m_class`** and the node is the PROTOTYPE's own `Class_method`.
* `CompileHelper::compileFunction` (`CompileStmt.cpp:2384-2412`) then reads
  `Return_data_type` **out of that node** and calls
  `compileVariable(component, fC, Return_data_type, …)`.
* `compileVariable`'s `paClass_scope` arm (`CompileType.cpp:554-624`) rebuilds
  one key, `<container>::<the one written segment>`, looks the typedef up,
  and hands its typespec to `getSimpleVarFromTypespec`
  (`CompileType.cpp:78-248`) — the table that turns an `enum_typespec` into an
  `enum_var`, a `struct_typespec` into a `struct_var`, an `array_typespec` into
  an `array_var`, a `class_typespec` into a `class_var`. When nothing is found
  the arm ends at `if (var == nullptr) var = s.MakeClass_var();`.
* The OUT-OF-BODY DEFINITION is a **second, separate** `compileFunction` over
  the definition node, with the definition's own (differently written) return
  type. That is the compile
  § `classTdLocalVarKindFollowsCompileOrder10`'s `ctx.outOfBody` term already
  models, and this pass does not touch it.

**The golden proof, on the arm the shipped law 10 was written against**
(`tools/probe/r10sd12repro/grid10/g7_return_var.sv`) — golden emits BOTH
objects, and they DISAGREE WITH EACH OTHER:

```
extern function aholder::arec_t r_ext_early();   (prototype, line 36)
function aholder::arec_t muser::r_ext_early();   (definition, line 40)
  golden PROTOTYPE listing  function@36:5-36:11  Return struct_var@36:21   <- RESOLVED
  golden DEFINITION listing function@40:3-40:61  Return class_var @40:12   <- not
extern function orec_t r_ext_own();              (prototype, line 37)
function muser::orec_t muser::r_ext_own();       (definition, line 41)
  golden PROTOTYPE listing  function@37:5-37:11  Return struct_var@37:21
  golden DEFINITION listing function@41:3-41:61  Return class_var @41:12
```

Our pristine binary put the DEFINITION's answer on BOTH objects
(`class_var@40:12` / `class_var@41:12`), because the emitter asked law 10 about
the out-of-body `SubroutineSymbol` in both listings. r10sd10's README already
recorded the visible half of this as its R4 ("golden emits a return variable at
the PROTOTYPE span of an `extern` method and we emit only one at the definition
span") and called it a missing-object defect; it is a **wrong-symbol** defect,
and the KIND is the half the judge reads.

**The corpus's own distinguisher, on the same construct.** `uvm_comparer::
object_compared` (uvm_pkg.sv:20982) is the identical shape — an `extern virtual`
method of a `uvm_pkg` class returning `uvm_policy::recursion_state_e` — and
golden's PROTOTYPE listing for it is a **`class_var`**, not an `enum_var`.
Law 10's ORDER term is what separates them: `uvm_policy` sorts BEFORE
`uvm_printer` and AFTER `uvm_comparer`. So the corpus itself carries a
MUST-STAY-AWAY cell for this law, and the law answers it correctly by
construction (§4).

### 3.1 THE 1800.2 CORPUS'S OWN COMPILE PATH

This row's golden is the **1800.2-2017-1.0 `pp_output`** tree
(`Surelog/third_party/UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv`, one
pre-processed file, `--single-unit`), NOT the uvm-1.2 include tree the
SeqDriver / SimpleUVM / Scoreboard / MiniAmiq rows use — which is why the same
construct sits at `19055` here and nowhere in those. The committed 1800.2
decodes this extends are `r10buvm22repro`'s (the unpacked-array typedef return,
whose `g22.sv` this pass re-scores in §8), `r10buvm9repro`'s class-scope alias
arms, and `r10uvm170repro`'s (the `export "DPI-C"` cast, whose head this row
sat behind). Both trees carry the same class-nested typedef shapes; the
difference is only which of them a given row's sources reach.

## 4. DECODING SLANG — OUR EMISSION, AND THE ONE SUBSTITUTION

`src/TaskFuncEmit.cpp` builds the class-body prototype listing on the
`protoOf` path (`~2903`): it walks the class's `MethodPrototypeSymbol`s, and for
each one whose implementation is out of body it runs the ordinary subroutine
path **over the DEFINITION's `SubroutineSymbol`** and stops before the body.
The return-variable site (`~3662`) therefore asked
`classTdLocalVarKind10(sub)` about the definition — whose `outOfBlockIndex` is
non-zero and whose written return type is the SCOPED out-of-body spelling.

The law is one substitution: in that listing, ask the **`MethodPrototypeSymbol`**.
`Symbol::getDeclaredType()` returns `MethodPrototypeSymbol::declaredReturnType`
(slang `source/ast/Symbol.cpp:73`), so the predicate then reads the PROTOTYPE's
own written spelling, and `tdDeclCtx10` walking from the prototype finds the
class with `outOfBody` false — exactly Surelog's `m_class` compile.

Three further terms were added because the GRID convicted the one-term form;
each is stated with the golden cells that convict it in `src/EmitHelpers.h`:

| term | what it says | convicting golden cells |
|---|---|---|
| 1 | ask the prototype, not the definition | `g7` `r_ext_early` / `r_ext_own`; the head |
| 2 | DECLINE a dynamic / queue / associative typedef (golden `array_var`, our factory `logic_var`) — hand the listing back to the shipped chain | `g22.sv` `po_q_int` (bare), `g185_e_kinds.sv` `k_dyn`/`k_q`/`k_assoc`, `g185_a_context.sv` `e_own_q` (bare) |
| 3 | a SCOPED spelling of a NAMED-BASE typedef is `class_var` (`bindTypedefs_` has not run) | `k_alias`, `k_xalias`, `k_cls`, `e_alias_scoped`, `e_early_alias` |
| 4 | a BARE spelling of a NAMED-BASE typedef is `ref_var` (§177's `CompileType.cpp:421` fallthrough, with the CLASS as the compiling component) | `e_own_alias`, `w6v_clsalias.sv` `f3`, `g22.sv` `po_tdcls`/`po_q_cls`/`po_f_cls` |

Terms 2-4 are gated to ONE population — a return type that is a typedef OWNED
BY A CLASS. Without that gate `g185_b_notmove.sv` `b_pkgalias` (a PACKAGE-level
`typedef pkg_enum pkg_alias;`) moved AWAY from golden's `enum_var`; the grid
caught it.

## 5. THE HEAD AFTER — AND R0

```
BuildUVMPkg default and testflags, 48 cmp lines, ONE head each,
the two databases and the two cmp logs BYTE-IDENTICAL (md5 14154829ad19…)

uvm_pkg.sv:8459  typedef int UVM_FILE;
uvm_pkg.sv:8461  parameter UVM_FILE UVM_STDIN  = 32'h8000_0000;

LHS golden  int_typespec (UVM_FILE) @8459:9-8459:12    |vpiName:UVM_FILE  |vpiSigned:1
            |vpiTypedefAlias -> ref_typespec(uvm_pkg::UVM_STDIN::UVM_FILE)
                              -> int_typespec(uvm_pkg::UVM_FILE)@8459:9
            |vpiInstance -> package uvm_pkg
RHS ours    int_typespec ()         @8461:11-8461:19   |vpiSigned:1
            no vpiName, NO Typedef_alias
            |vpiInstance -> package uvm_pkg
both under  parameter(uvm_pkg::UVM_STDIN)@8461:20-8461:29
```

A PARAMETER whose declared type is a package-level scalar typedef: golden mints
a per-parameter clone of the typedef's typespec, NAMED for the typedef, ANCHORED
at the typedef's own span, and links it back with `Typedef_alias`; we build an
anonymous typespec at the parameter's own span with no alias. `VpiName` fails
first (`BaseClass::Compare`). The chain shows at least three more `UVM_STDOUT` /
`UVM_STDERR` / … parameters of the same family behind it.

## 6. THE GRID — `ct185grid.sh` + `score185.py`, BOTH VIEWS

Full output: `GRIDS.r10uvm185.txt`. The CELL is one `function` object keyed on
(`vpiFullName`, the function's START `line:col`, `hasStmt`, parent) — the START
agrees on both sides for every object of this face and the END does not (golden
ends a prototype listing at the method name); the FIELD is the `Return`
variable's variable class, which is what the judge reads through
`task_func::Compare`'s `Return` edge.

| arm | view | AGREE | TOWARD | AWAY | MOVED-WRONG | STAY-BAD |
|---|---|---|---|---|---|---|
| `g185_a_context` (the CONTEXT and SPELLING axes) | plain | 47 | 9 | 0 | 0 | 1 |
| | elab | 94 | 18 | 0 | 0 | 2 |
| `g185_b_notmove` (what the law must not touch) | plain | 57 | 0 | 0 | 0 | 0 |
| | elab | 111 | 0 | 0 | 0 | 0 |
| `g185_c_reach` ($unit / module / nested-class reach) | plain | 13 | 5 | 0 | 0 | 0 |
| | elab | 27 | 12 | 0 | 0 | 0 |
| `g185_d_views` (DEF / ELAB / wildcard-import clone) | plain | 28 | 3 | 0 | 0 | 0 |
| | elab | 56 | 6 | 0 | 0 | 0 |
| `g185_e_kinds` (every class `getSimpleVarFromTypespec` can build) | plain | 67 | 17 | 0 | 0 | 3 |
| | elab | 134 | 34 | 0 | 0 | 6 |
| **total** | | **634** | **104** | **0** | **0** | **12** |

### 6.1 The arms are built so that AGREEING is not the same as UNTESTED

Every arm carries BOTH directions of law 10's ORDER term (an owner class sorting
BEFORE and one sorting AFTER the declaring class), both spellings (bare and
scoped) of the same typedef, and in-body twins of every extern cell. The
negative controls — `e_late_rec` / `e_late_enum` / `k_late_*`, whose owner sorts
AFTER — must stay `class_var` on BOTH listings, and they do.

### 6.2 `g185_b_notmove` is the arm that says what the law does NOT own

57 cells per view, ZERO moved: builtin and keyword returns, an implicit return,
a written `signed` return, an inline enum, package-level typedefs (struct, enum,
vector), a package NAMED-BASE alias (§ `ownNamedAliasRetIsRefVar177`'s own
shape), an unpacked-array package typedef (§ `namedBaseUnpackedTdRetVar22`'s), a
class-handle return, an `extern` TASK prototype and an `extern` constructor
prototype. An inline packed STRUCT return is deliberately not a cell: slang
refuses the shape ("return type … does not match … declared in its prototype"),
so our emitter can never be asked. A class-scoped `typedef chandle` is not a
cell either: it SEGFAULTS the golden Surelog outright (rc=139 on a five-line
reduction), so neither side can be scored.

### 6.3 The one-sided keys in `g185_c_reach` are a PRE-EXISTING residue

Golden names a `$unit`-level or module-level class's method
`u_user185::c_unit_sibling` where we name it
`work@u_user185::c_unit_sibling`, so those keys do not join; and in the
elaborated view we emit MORE listings of a module-homed class's method than
golden does. Both are identical on the PRISTINE and the PATCHED binary (the
`PRIS=` and `PAT=` columns of every one-sided row are the same value except
where the row's own key group also carries the TOWARD cells), so no verdict is
hidden inside them. They belong to the naming family, not to this law.

## 7. THE MOVERS — PREDICTED BY NAME, THEN ATTRIBUTED

`predict185.sh` scanned all **956 pristine surelog databases and all 1358
pristine uhdm2rtlil databases** and opened NO GOLDEN (a golden-derived
prediction would be blind to a cell that moves AWAY from an answer that already
agreed). Its predicate is a provable over-approximation: this law can only
change a return variable that (1) belongs to a class-body PROTOTYPE listing,
(2) is TODAY a `class_var` or a `ref_var` — the only two classes the shipped
law 10 hands back when it does not resolve — and (3) whose typespec is not
itself a `class_typespec`.

```
surelog     SCANNED=956   CANDIDATE_ROWS=13  CANDIDATE_DBS=9
uhdm2rtlil  SCANNED=1358  CANDIDATE_ROWS=0   CANDIDATE_DBS=0
```

The 13 rows (`PREDICT.r10uvm185.txt`) are `uvm_printer::object_printed` and
`uvm_comparer::object_printed`'s sibling `uvm_comparer::object_compared` on
BuildUVMPkg ×2, plus `uvm_set_get_dap_base::get` on five row-modes (a TYPE
PARAMETER return, § `typeParamRetIsRefVar58`'s cell, which this law leaves at
`Resolved` and does not touch).

The measured movers:

```
surelog     MOVERS 3 / 956   PATH_SETS_IDENTICAL, SELFCHECK 955/956
  ./default/BuildUVMPkg    patched=bbf172cd412b pristine=5c6a62b63407   <- PREDICTED
  ./testflags/BuildUVMPkg  patched=bbf172cd412b pristine=5c6a62b63407   <- PREDICTED
  ./default/Scoreboard     patched=0d80f8f5d07e pristine=c09f5e4b3e5b   <- THE COIN
uhdm2rtlil  MOVERS 0 / 1358  PATH_SETS_IDENTICAL, SELFCHECK 1357/1358
```

**BuildUVMPkg is attributed to the cell.** The path-normalised whole-dump diff
is **4 lines — ONE object**, printed twice by `uhdm-dump` (once under the
function, once as the `ref_typespec`'s parent back-reference):

```
< \_class_var: (uvm_pkg::uvm_printer::object_printed), line:20364:10, endln:20364:39
> \_enum_var:  (uvm_pkg::uvm_printer::object_printed), line:20364:10, endln:20364:39
```

`uvm_comparer::object_compared`, the predicted candidate on the same row, did
NOT move — golden wants `class_var` there and the ORDER term keeps it.

**Scoreboard/default is the COIN, and this pass proves it rather than citing
it.** Order-blind: the two dumps are 1 100 380 lines each, the ORDERED diff is
**92 lines** and the SORTED diff is **0** — RESUME.md §9's exact signature
(svunit_pkg `vpiTaskFunc` list order flip, ~92 dump lines). And four
harness runs of the **PRISTINE** binary alone produce BOTH hashes:

```
run 1  0d80f8f5d07e   run 2  c09f5e4b3e5b   run 3  0d80f8f5d07e   run 4  c09f5e4b3e5b
```

i.e. the "patched" Scoreboard hash is one the pristine binary produces on its
own. Not this law. Scoreboard also has ZERO candidate rows that this law can
move (`uvm_set_get_dap_base::get`, a `ref_var` it declines).

## 8. THE BOUNDARY

`wide185.sh` (r10uvm170's `wide170.sh`, carried forward) compiles **every `.sv`
and `.v` under a COPY of `tools/probe` at ANY depth** — top level and
subdirectories — in BOTH views, with both frozen binaries, and byte-compares the
workdir-normalised dumps. The file list is read on fd 3, children get
`</dev/null`, and PROCESSED is asserted against LISTED. Byte identity is
strictly stronger than a cmp-line count.

```
LISTED=5022   PROCESSED=5022   identical=9624   DIFFERING=38   no_output=382
rc over 20088 compiles: rc=0 18546  rc=3 732  rc=4 778  rc=139 32
RC_DIFFS=0 — every (arm, view) has the SAME rc on both binaries, the 32
            pre-existing Surelog-independent segfaults included
MOVED ARMS: 19 (38 arm-views), FOUR of them this pass's own grid arms
            (the POSITIVE CONTROL: a boundary that reports zero over them
             cannot see)
```

**Every moved arm is then scored AGAINST GOLDEN** by `attrib185.sh`, because
movement without a golden column proves nothing about direction. Full output:
`BOUNDARY.r10uvm185.txt`.

| moved arm | plain | elab |
|---|---|---|
| `r10buvm22repro/g22.sv` | TOWARD 3, STAY-BAD 5 | TOWARD 6, STAY-BAD 13 |
| `r10buvm9repro/v1inst9.sv` | TOWARD 1 | TOWARD 2 |
| `r10buvm9repro/w3v_homes.sv` | TOWARD 2 | TOWARD 5 |
| `r10buvm9repro/w6v_clsalias.sv` | TOWARD 1 | TOWARD 2 |
| `r10sd10/11/12repro/grid10/g7_return_var.sv` | TOWARD 2, STAY-BAD 1 (each) | TOWARD 4, STAY-BAD 2 (each) |
| `r10sd10/11/12repro/vgrid10/v5_oob_extern.sv` | TOWARD 1 (each) | TOWARD 2 (each) |
| `r10uvm138repro/g138_c_homes.sv` | TOWARD 1 | TOWARD 2 |
| `r10uvm177repro/g177_a_alias.sv` | TOWARD 2 | TOWARD 4 |
| `r10v138repro/v5_homes.sv` | TOWARD 1 | TOWARD 2 |
| `r10v177repro/v177_4_cls.sv` | TOWARD 2, STAY-BAD 1 | TOWARD 4, STAY-BAD 2 |
| `r10v97repro/v97_c7_usesites.sv` | TOWARD 1 | TOWARD 2 |
| this pass's own four `grid185/*.sv` | TOWARD 34 | TOWARD 70 |
| **all 19 arms, both views** | **AWAY 0** | **MOVED-WRONG 0** |

**AND EVERY MOVED CELL IN THE WHOLE TREE IS A `stmt=0` PROTOTYPE LISTING'S
RETURN VARIABLE** — the exact population the law names. Not one cell with
`stmt=1` (a definition listing or an in-body method) moved anywhere, in either
view, on any arm. The moved cells, by name:

```
p22::K22::po_tdcls / po_tdstruct / po_f_cls        (buvm22, the 1800.2 unpacked-td arm)
p9::a2::f2                                         (buvm9  v1inst9)
work@ucl::h , work@w3m::mcl::h                     (buvm9  w3v_homes)
w6p::w6k::f3                                       (buvm9  w6v_clsalias)
px::muser::r_ext_early / r_ext_own                 (sd10/11/12 g7 — the decode's own table)
v5p::CA::oob_cls                                   (sd10/11/12 v5_oob_extern)
p138c1::c138c::oob_cls                             (uvm138 g138_c_homes)
zpk177::Kls177::q_oob_clsalias / r_oob_clsdirect   (uvm177 g177_a_alias)
genp9::Box9::boxOob , genp9::Deck9::deckClsVia     (v138 v5_homes)
px5::auser5::retown                                (v177 v177_4_cls)
p97c7::base97c7::f_oob                             (v97 v97_c7_usesites)
+ this pass's own grid185 cells
```

### 8.1 THE MUST-STAY FLOOR, SCORED IN BOTH COLUMNS

| protected set | moved? | verdict |
|---|---|---|
| **r10uvm170's arms and BOTH fences** (`g170_a_spell` … `g170_e_kinds`, the `dpiExportedPkgSubBareOwnTdUnsupported170` import-replay memo and forward-typedef fences) | **NO** — byte-identical under both binaries in both views | intact |
| **r10uvm181, 182, 183's arms** (clone-binding, minted-call, clone-foreach) | **NO** | intact |
| **r10uvm82-91's arms** | **NO** | intact |
| **buvm3-15** | `r10buvm9repro`'s three arms move | every moved cell is a prototype-listing return variable and every one is **TOWARD golden**: AWAY 0, MOVED-WRONG 0 |
| **sd8-12** | `grid10/g7_return_var.sv` and `vgrid10/v5_oob_extern.sv` move in sd10, sd11 and sd12 | same: **TOWARD only**. `g7_return_var.sv` is the arm whose golden columns the law was DECODED from (§3), so its movement is the law landing on the cells it was written for |

`r10uvm170repro` and the three most recent UVM passes' arms are not merely
"unmoved by inspection" — they are absent from the wide boundary's 19-arm moved
list, which is a byte comparison of every one of their files in both views.

## 9. RESIDUES

* **R1 — the PROTOTYPE-SPAN half of the same law (first-ranked).** Golden also
  anchors the prototype listing's return variable at the PROTOTYPE's own
  return-type span (`19055:27`, `36:21`) where we keep the definition's
  (`20364:10`, `40:12`). The census measures this family at **3298 cells over
  the nine UVM row-modes** against this law's 2 — every `extern` method with a
  written return type has one. NO generated `Compare` reads a line or a column
  (RESUME.md §9), so not one of those 3298 cells is visible to the judge, while
  moving them would move thousands of corpus bytes and could not be predicted
  cell-by-cell. Recorded, measured, and deliberately not made. Anyone taking it
  must re-anchor `returnTypeSyntax(sub)` at the prototype for this listing only
  and predict the movers from the same census.
* **R2 — the ARRAY row this law declines.** A class-owned DYNAMIC / QUEUE /
  ASSOCIATIVE typedef returned from an `extern` prototype is golden's
  `array_var`; our return-var factory has no model for it and would build a
  `logic_var`, so term 2 declines and the cell keeps the pristine `class_var`.
  Twelve grid cells (`k_dyn`, `k_q`, `k_assoc`, `e_own_q`, both views) and
  `r10buvm22repro/g22.sv` `po_q_int`. **ZERO corpus population.**
* **R3 — `pq_cls_t`-shaped returns: a PACKAGE unpacked-array typedef named from
  an `extern` prototype.** `g22.sv` `po_pq_cls` is golden `ref_var` and ours
  `class_var` on the prototype listing. The typedef is owned by the PACKAGE, so
  it falls outside this law's population gate and is untouched here; it is
  § `namedBaseUnpackedTdRetVar22`'s neighbourhood. Measured, not moved.
* **R4 — the shadow gate is inherited, not re-measured.** Term 4 calls
  § `ownNamedAliasNameIsNotShadowing177v` unchanged. Its seven convicting cells
  live in `tools/probe/r10v177repro/v177_6_shadow.sv` and were re-run here only
  as boundary arms (byte-identical). A class-scoped named-base typedef whose
  name is ALSO import-visible is therefore decided by § 177's measurement and
  not by a fresh one.
* **R6 — the `class_var` STAY-BAD cells the boundary re-measured.**
  `g22.sv` carries 5 (plain) / 13 (elab) prototype cells where golden and ours
  already disagreed and still do — the PACKAGE-owned unpacked-array typedefs
  (`po_pq_cls`), the queue row R2 declines, and the parameterised-class arm
  § `typeParamRetIsRefVar58` owns; `g7_return_var.sv` carries 1/2 and
  `v177_4_cls.sv` 1/2. None of them moved. They are named in
  `BOUNDARY.r10uvm185.txt` so the next pass can pick them up rather than
  rediscover them.
* **R5 — `g185_c_reach`'s one-sided keys**: golden's `u_user185::…` against our
  `work@u_user185::…` naming, and a listing-count difference for a module-homed
  class's methods in the elaborated view. Identical on both binaries; the
  naming family, not this law (§6.3).

## 10. THE FILES

| file | what it is |
|---|---|
| `ct185own.cpp` | the JUDGE DECODER: owner chain, referrer index, the owner's WHOLE compared-field table in the judge's order (failing field + the next two marked), ablation, chain |
| `ct185cen.cpp` | the CENSUS probe: one row per `function` — full name, span, hasStmt, parent, Return kind, Return span, Return typespec |
| `cen185.sh` | runs `ct185cen` over a sweep's rows, golden AND ours, reading each row's golden out of its OWN `cmds.txt` |
| `join185.py` | the MULTISET join of that face, split PROTO vs OTHER, KIND-DIFF / SPAN-DIFF / AGREE / one-sided |
| `predict185.sh` | the mover prediction from PRISTINE databases alone; opens no golden |
| `ct185grid.sh`, `score185.py` | the grid driver and its golden/pristine/patched scorer |
| `grid185/*.sv` | the five arms |
| `wide185.sh`, `bound185.sh` | the wide and targeted boundary gates (carried forward from r10uvm170repro) |
| `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `rowheads.sh` | the standing gate instruments, carried forward unchanged |
| `LADDERS/CENSUS/GRIDS/PREDICT/GATES/BOUNDARY.r10uvm185.txt` | the recorded outputs |
