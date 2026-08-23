# r10uvm105 — § `oobClassTypeParamLocalUnsupported105` — **AN OUT-OF-BODY DEFINITION IS COMPILED IN THE PACKAGE'S SCOPE, SO ITS BODY LOCAL WRITTEN AS THE CLASS'S OWN TYPE PARAMETER NEVER RESOLVES** — the SimpleUVM ×2 / Scoreboard/default 22-line head **CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `50c3880` |
| worktree | `/tmp/wt_r10uvm105` |
| pristine binary | md5 `9bfe3c01602ee7e873484f3974ec8348` — reproduced the main tree's `build/slang-uhdm` at `50c3880` byte for byte — frozen `chmod 555` |
| patched binary | md5 `f238285deb8f75aded1396f9ca6273ae`, frozen `chmod 555` |
| production surface | `src/TaskFuncEmit.cpp` ONLY — one new predicate lambda and one new branch at the subroutine-body-local typespec binding |
| probe surface | `tools/probe/r10uvm105repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **22** | **17** | 1 (a NEW head) |
| **Scoreboard default** | **22** | **29** | 1 (a NEW head, one level DEEPER) |
| SeqDriver default / testflags | 64 | 64 | 1 unchanged (uvm104's row) |
| MiniAmiq default / testflags | 348 | 348 | 1 unchanged |
| BuildUVMPkg default / testflags | 72 | 72 | 1 unchanged |
| Earlgrey_0_1 default / testflags | 46 | 46 | 1 unchanged |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes) | |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine PREDICTED BY NAME | |
| the head's family | 0 of 156 objects agreed | **156 / 156 agree**, 0 AWAY | |

`head_pris_default_SimpleUVM.cmp` is the whole 22-line head uvm103 named R0;
`head_pat_default_SimpleUVM.cmp` (17 lines) and `head_pat_default_Scoreboard.cmp`
(29 lines) are the two NEW ones — **they are different objects**, see §7.

## 1. THE HEAD, CONFIRMED FROM `BaseClass.h` + THE GENERATED `Compare` FIRST

The 22-line head, verbatim from the pristine cmp log:

```
LHS  unsupported_typespec: (REQ)                 @270:3-270:6
       |vpiName:REQ
       |vpiInstance: \_package: uvm_pkg (uvm_pkg::) @28:1-39:11
RHS  class_typespec:                             @270:3-270:6
       |vpiClassDefn: \_class_defn: (uvm_pkg::uvm_sequence_item) @37:1-497:9
```

**THE FIELD IS `VpiType`, and the CARRIER is `ref_typespec::Actual_typespec`.**
Read off both `uhdm-dump`s, not assumed: on both sides the object is the
`vpiActual` of the `ref_typespec` of the variable `param_t`
(`uvm_pkg::uvm_sequencer_param_base::send_request::param_t`), which is the
SINGULAR slot `ref_typespec::Actual_typespec`. `ref_typespec::Compare` therefore
reaches it through the SINGULAR `SafeCompare` overload
(`~/.local/include/uhdm/BaseClass.h:187`) → `BaseClass::Compare`, whose **first**
test is `VpiType`, and that arm sets `m_failedLhs` **and** `m_failedRhs` — which
is exactly the two-sided head printed above. Nothing below `VpiType` is read, so
neither the name `REQ` nor the `vpiInstance` is what the judge stopped on; they
are the payload the LAW has to get right afterwards.

Source: `uvm-1.2 seq/uvm_sequencer_param_base.svh`

```systemverilog
class uvm_sequencer_param_base #(type REQ = uvm_sequence_item,      // :31
                                 type RSP = REQ) extends uvm_sequencer_base;
  …
endclass
// …and, OUT OF THE CLASS BODY, at PACKAGE level:
function void uvm_sequencer_param_base::send_request(                // :267
        uvm_sequence_base sequence_ptr, uvm_sequence_item t, bit rerandomize = 0);
  REQ param_t;                                                       // :270
```

## 2. THE LAW

> **§ `oobClassTypeParamLocalUnsupported105`** — *A subroutine DEFINED OUT OF
> BODY is compiled with the enclosing **PACKAGE** (or `$unit`, or the module) as
> the component, so the class's own type parameters are not on that component's
> lexical chain. Every declaration in it whose written data type is a bare
> identifier naming a **type parameter** falls through Surelog's
> `compileDatastructureTypespec` catch-all to an `unsupported_typespec` carrying
> the **WRITTEN** name, stamped with the component's instance — the DECLARING
> package, and **NOTHING** when the class's home is `$unit` or a module. No late
> binding ever repairs it, because the repair map holds **TYPEDEFS ONLY**.
> § `oobParamClassTypeParamFormalUnsupported31` modelled the FORMAL; this is the
> **BODY LOCAL**, the same catch-all one declaration kind over.*

### DECODED FROM SURELOG, file and line

1. **The component is the PACKAGE.** `CompilePackage.cpp:213` hands `m_package`
   to `CompileHelper::compileFunction` for every `paFunction_declaration` at
   package level — and an out-of-body definition IS one.
   `CompileStmt.cpp:2692`'s `paClass_scope` arm only RENAMES the function
   (`funcName = "cls::meth"`, `CompileStmt.cpp:2695-2697`); the `scope`
   argument, which every `compileVariable` / `compileTypespec` call below it
   uses, stays the package. (uvm97/98's R1 named this same mechanism for a
   TYPEDEF; this is its type-parameter instance.)
2. **The mint.** `CompileHelper::compileDatastructureTypespec`
   (`CompileType.cpp:717`) tries, in order, `component->getDataType(typeName)`,
   `<lib>@<name>`, `<component>::<name>`, `<parentScope>::<name>`, `<name>`, and
   `component->getParameter(typeName)` — a PACKAGE has none of those for `REQ`,
   because `REQ` is a parameter of the CLASS. The catch-all at
   **`CompileType.cpp:1051-1055`** then mints
   `unsupported_typespec` with `VpiName(typeName)` and
   `populateCoreMembers(type, type, tps)` — which is why the object's span is
   the WRITTEN TOKEN, `270:3-270:6`, and not the declaration's.
3. **The instance.** `CompileHelper::compileTypespec`'s tail,
   **`CompileType.cpp:2135-2136`**:
   `if (result && component && !result->Instance()) result->Instance(component->getUhdmInstance());`
   The component is the package → `vpiInstance` = `package uvm_pkg`. A `$unit`
   or module-nested class's component has no uhdm instance → NOTHING (measured,
   arm a2 `uo_t` / `mo_t`).
4. **Why nothing ever repairs it.** `ElaborationStep::bindTypedefs_`
   (`ElaborationStep.cpp:102`) builds a `std::map<std::string, typespec*> specs`
   **from `TypeDef`s only** — every file's, package's, module's, program's and
   class's `getTypeDefMap()` (`ElaborationStep.cpp:110-148`). The repair loops
   (`ElaborationStep.cpp:328-357` for packages, `:359-385` modules, `:387-411`
   classes) take each `unsupported_typespec` in the component's
   `getLateTypedefBinding()` list, look its **bare name** up in `specs`, and
   swap. A **type PARAMETER is never inserted into `specs`**, so the placeholder
   is permanent. The same three lines are why arm a3's `t105` cell RESOLVES:
   `specs` is **DESIGN-WIDE** and keyed by the SIMPLE name, so a typedef in a
   package the class does not even import repairs the placeholder.

## 3. THE GRID — golden's answer for every cell, both views

`grid105.sh <arm.sv> <bin A> <bin B> <workdir> <cen bin>` builds three databases
per view (`def` and `--elabuhdm`/`-elabuhdm`), echoes every command with its own
`rc` into `<workdir>/cmds.txt`, and censuses all six. `GRID.txt` has the cells
verbatim; the decisive ones:

| arm / cell | written | golden (LHS) | ours, pristine |
|---|---|---|---|
| a1 `xo_t` OOB local, own parameter | `T` | **`unsupported_typespec 'T'` @p105** | `class_typespec` |
| a1 `xo_u` OOB local, `type U = T` | `U` | **`unsupported_typespec 'U'` @p105** | `class_typespec` |
| a1 `xo_w` OOB local, `type W = int` | `W` | **`unsupported_typespec 'W'` @p105** | `int_typespec` |
| a1 `to_t`/`so_t`/`zo_t`/`yo_t` OOB local in a task / a `static` method / a `void` method / a method WITH a return type | `T` | **unsupported** | resolved |
| a3 `xo_init` OOB local WITH an initialiser | `XT` | **unsupported** | resolved |
| a3 `wo_1`,`wo_2` two OOB methods, one class | `WT` | **unsupported, ONE OBJECT EACH** | resolved |
| a2 `do_t` OOB local, an INHERITED parameter | `BT` | **unsupported** @q105 | resolved |
| a2 `uo_t` OOB local, class home is `$unit` | `UT` | **unsupported, NO vpiInstance** | resolved |
| a2 `mo_t` OOB local, class home is a MODULE | `MT` | **unsupported, NO vpiInstance** | resolved |
| a1 TOPMOD / corpus `svaunit_pkg` copies | `T`/`REQ` | **unsupported; instance stays the DECLARING package** | resolved |
| a1 `lo_t`, a2 `ib_u` IN-BODY local, same parameter | `T`/`UT` | `class_typespec` — **RESOLVED** | same |
| a1 `xo_td` OOB local, a TYPEDEF OF the parameter | `my_t` | `class_typespec 'my_t'` — **RESOLVED** | same |
| a1 `xo_cls`,`xo_pln`, a2 `po_c`,`po_i` OOB local, plain class / typedef / int | — | RESOLVED | same |
| a2 `vo_v` OOB local whose RANGE names a VALUE parameter | `logic [WID-1:0]` | `logic_typespec` — **RESOLVED** | same |
| **a3 `so_c` OOB local, the package ALSO declares a typedef of that name** | `T105COLLIDE` | **`int_typespec 'T105COLLIDE'` — RESOLVED TO THE TYPEDEF** | `class_typespec` |
| **a3 `to_c` the colliding typedef is in an UNRELATED, UN-IMPORTED package** | `T105FAR` | **`int_typespec 't105other::T105FAR'` — STILL RESOLVED** | `class_typespec` |

The last two rows are why the predicate is **not** "names a type parameter"
alone, and they are the whole reason for the guard in §4.

MEASURED AND LEFT (residues, §7): the ARRAY spellings (a3 `uo_fix`/`uo_q`/
`uo_dyn` — golden puts the placeholder on the ELEMENT `ref_var`, a different
emission site), and the SCOPED spellings (`cv105::VT` as a local, `c105::T` as
an out-of-body RETURN type — the only spelling slang accepts there).

**GOLDEN-VS-GOLDEN CALIBRATION FIRST** (`goldcen105.sh`). Over the five UVM
tests that have both modes, the `default` and `testflags` goldens are two
independent Surelog runs of the same design: **4 of 5 pairs are IDENTICAL** and
Scoreboard differs on **3 rows** (a `TPARAM` pair and one `TOPMOD` `class_var`),
**none of them in this law's family** — so `EXPM_N = 0` for the family and every
golden-vs-ours number below is read against zero expected mismatch. (Over the
WHOLE corpus the same script reports 686/755 pairs differing: for most tests the
`testflags` command line is a DIFFERENT DESIGN. That number calibrates nothing
here and the script says so.)

## 4. THE FIX, AND ITS THREE CONJUNCTS

`src/TaskFuncEmit.cpp`, at the subroutine-body-local `ref_typespec` binding —
the same site § `classScopedTdDeclTsUnsupported11` SITE 1 uses, one branch
earlier. The gate is:

1. `oob` — the definition is one `members()` never yields
   (`isOutOfBody`, the existing test § 31 uses);
2. the declared type is **NOT** an array (fixed / queue / dynamic / associative)
   — golden's placeholder for those lives on the ELEMENT `ref_var`, which is not
   this site;
3. `oobClassTypeParamName31(typeSyntax)` is non-empty — the SHARED § 31
   predicate, unchanged: a `NamedType` whose name is a plain `IdentifierName`
   that `body.find()` answers with a `TypeParameter`;
4. …and the new guard `oobTpLocalShadowedByTd105` is FALSE: no `TypeAlias` of
   that simple name is found on the class's own scope chain, in any PACKAGE, or
   in any COMPILATION UNIT the compilation holds. This mirrors Surelog's
   design-wide `specs` map (§2 point 4) and is what keeps arms a3 `s105` and
   `t105` correct. The walk runs ONLY when the law is about to fire — six sites
   in the whole UVM tree — so it is never a per-declaration cost.

The object minted is an `unsupported_typespec` named with the WRITTEN parameter
name, located at the TYPE SYNTAX (`270:3-270:6`, golden's span), taking
`oobDeclPkg31` — the package the CLASS is declared in, exactly as § 31's formals
take it, so an IMPORTER's copy still reads `@uvm_pkg` and a `$unit`/module home
reads nothing.

**DIRECTION: it changes a KIND and its payload, never a carrier.** The variable's
own class, span, parent, `vpiAutomatic` and full name are untouched — measured
directly: the order-blind whole-dump diff of every mover changes ONLY
`class_typespec`→`unsupported_typespec` lines and their `vpiClassDefn`→
`vpiInstance` children (§6).

## 5. THE FENCE — written from PRISTINE databases only

`fence105.sh <sweep workdir> <cen bin> <out.tsv>` censuses BOTH sides of every
test in a sweep workdir and reports every site where golden holds an
`unsupported_typespec` on a subroutine-BODY LOCAL and we do not, split by the
census's own `TP` lines (every class type-parameter name in the database) into
**HIT** (the law's own family) and **OTHER** (`process`,
`uvm_reg_field_cb_iter`, `sva_info`, … — a different family, left alone).

| corpus | measured | SKIP | OTHER sites | **HIT sites** | **databases that MUST move** |
|---|---|---|---|---|---|
| surelog | 956 | 617 | 220 in 9 DBs | **54** | **9** |
| uhdm2rtlil | 1358 | 104 | 0 | **0** | **0** — the predicted NONE |

The nine, BY NAME (`PREDICTION.fence_pristine_surelog.tsv`):
`{default,testflags}/{SeqDriver,SimpleUVM,MiniAmiq,BuildUVMPkg}` and
`default/Scoreboard`. The six SITES, identical in every one of them:

```
uvm-1.2 seq/uvm_sequencer.svh:164   stop_sequences     REQ t;
                             :207   get_next_item      REQ req_item;
                             :278   item_done          REQ t;
        seq/uvm_sequence_library.svh:754  execute      REQ req_item;
        seq/uvm_sequencer_param_base.svh:270  send_request  REQ param_t;   <- THE HEAD
                                        :351  analysis_write RSP response;
```

(BuildUVMPkg names them at its `pp_output` line numbers 53993 / 54074 / 54356 /
54397 / 54468 / 56929.)

## 6. THE GATE BATTERY

See `GATES.txt` for the whole battery with its numbers, the `cmds.txt` binary
audit, the four boundary runs and the order-blind mover attribution.

## 7. RESIDUES, named for the queue

**R0 — THE NEW HEAD of SimpleUVM ×2 (17 lines).** An IMPLICIT NET golden mints
in the TOP MODULE for a name the out-of-body body could not bind:

```
LHS  logic_net: (work@top.param_t)  @290:27-290:34
       |vpiParent: \_module_inst: work@top
       |vpiName:param_t   |vpiFullName:work@top.param_t   |vpiNetType:1
RHS  <null>
```

`uvm_sequencer_param_base.svh:290` is `m_last_req_push_front(param_t);`, inside
the very `send_request` this pass just fixed. Surelog compiled that body in the
PACKAGE's scope, so the ARGUMENT `param_t` fell through to the module-level late
binding, which minted an implicit wire **in `work@top`** — the same family
§ `fnLocalParamRangeNet` already models for a range bound. This is the direct
knock-on of § 105's own mechanism and is the natural next head: one object, one
`logic_net`, `RHS: <null>` (the SINGULAR `SafeCompare` mirror — golden's
`module_inst::Nets` vector holds an element ours does not).

**R-B — the NEW head of Scoreboard/default (29 lines), one level DEEPER.** With
the typespec now equal, `Compare` descends and finds the variable itself:

```
LHS  <null>
RHS  ref_var: (…::send_request::param_t) @270:7-270:14
       |vpiParent: \_begin: (…::send_request) @272:3-274:6
```

We list `param_t` in the body `begin`'s variables; golden's `begin` does not hold
it. This is a MASK REMOVAL, not a regression — the same declaration, compared one
level deeper than the pristine binary ever reached (RESUME §9: masks cascade, the
count is a lower bound), and the order-blind attribution in §6 proves that the
ONLY objects that changed in that database are the twelve typespecs.

**R-ARR — the ARRAY spelling of this very law.** `UT uo_fix[4]` / `[$]` / `[]`
out of body: golden's `array_typespec` is equal on both sides, but the ELEMENT
`ref_var` beneath it carries `unsupported_typespec 'UT'` where ours carries a
`class_typespec` (arm a3 `u105c`, both views, all three dimension kinds).
FENCED OUT of this pass by conjunct 2 because the element var is a different
emission site. **Zero corpus reach** (the fence found no such site in either
corpus).

**R-SCOPED — the `c::T` spelling.** An out-of-body local written
`cv105::VT` (a3) and an out-of-body RETURN type written `c105::T` (a1 — the only
spelling slang accepts there, it rejects the bare `T`): golden degrades both to
an `unsupported_typespec` NAMED WITH THE WRITTEN TEXT (`'cv105::VT'`,
`'c105::T'`) at the package; we already carry the right NAME on the local and
emit a `class_typespec` for both. Only the KIND is left. Measured in both views,
**zero corpus reach**.

**R-INH — an INHERITED type parameter written IN BODY.** `deri105::dmeth_ib`'s
`BT di_t;` (a2): golden emits `unsupported_typespec 'BT'` with **NO
vpiInstance** — § `baseClassTypeParamFormalUnsupported34`'s shape, one
declaration kind wider (that law owns the FORMAL). Surelog itself reports
`[ERR:CP0317] Undefined type "BT"` on this cell and still emits. Pre-existing,
untouched by this pass, **zero corpus reach**.

**R-BLK — an out-of-body NESTED-BLOCK local.** `begin REQ l_oob2; … end`
inside an out-of-body definition (boundary arm `r10uvm87repro/v87_a3_oob.sv:17`):
golden degrades it EXACTLY like a top-level body local
(`unsupported_typespec 'REQ'` @p87x), and we still emit a `class_typespec`.
Our block-item declarations are emitted at a different site, which this
branch does not reach. **Zero corpus reach** — all six UVM sites are
top-level function locals.

**R-PTR — a RAW POINTER in a constant's value, not this law at all.** Boundary
arm `r10buvm22repro/g22.sv:70/71`, the ASSOCIATIVE-array typedef
`typedef C22 ka_cls_t[string];`: the range's operand constant carries
`UINT:22235321` in the pristine binary and `UINT:22239417` in the patched one.
`nm` resolves BOTH to the SAME static object at the SAME offset —
`slang::ast::builtins::Builtins::Instance + 1337` in each binary — because both
binaries are non-PIE and the patched one's `.bss` sits one page higher. The
values are deterministic across repeated runs of each binary, and that arm's
whole diff contains NO typespec line, so § 105 did not fire there. An emitter
bug worth its own pass, and a warning for every future boundary run: g22.sv is
LAYOUT-SENSITIVE.

**R-P — the `process` family.** Golden leaves a local typed by the built-in
class `process` an `unsupported_typespec 'process'` @uvm_pkg (in-body AND
out-of-body: `uvm_process_report_message` at `uvm_misc.svh:262`,
`uvm_component::m_apply_verbosity_settings:3612`, `uvm_reg::XatomicX:2976`,
`uvm_root::run_test:411`); we emit a `class_typespec`. 220 sites over the same 9
databases are in this OTHER family the fence reports (with
`uvm_reg_field_cb_iter`, `uvm_cmdline_parsed_arg_t`, `m_verbosity_setting`,
`sva_info`, `index`, …). A ranked, corpus-visible cluster, and the biggest thing
left in the LOCAL-typespec family.

**R-COLLIDE — the typedef collision, our side.** Arm a3 `so_c`/`to_c`: where a
typedef of the parameter's simple name exists, golden binds THAT TYPEDEF's
typespec (`int_typespec 'T105COLLIDE'` / `'t105other::T105FAR'`); the guard now
correctly keeps § 105 off those cells, but we still emit a `class_typespec` for
the parameter's default instead of the typedef. Pre-existing, zero corpus reach.

**R-M — the ELAB/import copy COUNT.** Golden's MiniAmiq and SeqDriver hold SIX
copies of each of the six sites (uvm_pkg DEF + ELAB, and two importer copies of
each) where we hold FOUR; the twelve `MISS` rows per database in §6's census
table are exactly that. A pre-existing multiplicity family (uvm103's R-M), not
this law's — every copy we DO emit now agrees.

## 8. FILES

```
README.md                       this file (the decoded law)
GATES.txt                       the whole gate battery with its numbers
GRID.txt                        the golden grid, both views, cell by cell
PREDICTION.txt                  the fence, written from PRISTINE databases only
PREDICTION.fence_pristine_surelog.tsv      54 HIT sites / 9 databases
PREDICTION.fence_pristine_uhdm2rtlil.tsv   no HIT row — the predicted NONE
head_pris_default_SimpleUVM.cmp the whole 22-line head this pass cleared
head_pat_default_SimpleUVM.cmp  the whole NEW 17-line one           (R0)
head_pat_default_Scoreboard.cmp the whole NEW 29-line one           (R-B)
g105_a1.sv                      the site x spelling grid, package class
g105_a2.sv                      the HOMES ($unit / module / package) + inheritance
g105_a3.sv                      THE DISCRIMINATORS (typedef collision, arrays,
                                scoped spellings, per-declaration identity)
r10uvm105cen.cpp                the declaration-typespec census (+ the TP lines)
join105.py                      the whole-census multiset join
unsup105.py                     the unsupported-typespec half, AGREE/KIND/NAME/
                                INST/MISS/EXTRA per (SITE, OOB, VIEW)
build105.sh                     builds a probe from THIS directory
grid105.sh                      builds a grid arm's 3 databases in BOTH views
fence105.sh                     the fence over a sweep workdir
goldcen105.sh                   golden-vs-golden calibration
attrib105.sh                    the ORDER-BLIND mover attribution
bound105.sh                     the boundary gate (a verbatim copy of bound23.sh)
byteverify.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh ct8rows.sh
                                the standing gate instruments, copied so this
                                directory can re-run its own battery
```
