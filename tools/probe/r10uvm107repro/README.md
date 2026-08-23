# r10uvm107 — § `oobRefVarLocalHoistNet107` — **A `ref_var` DECLARATION IS INVISIBLE TO SURELOG'S LATE BINDER, SO A REFERENCE TO ONE MINTS AN IMPLICIT WIRE IN THE HOISTING MODULE** — the SimpleUVM ×2 head **CLEARED**, and uvm105's R-B (Scoreboard/default) with it

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `6c74d2a` |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY — one new depth counter, one new predicate, one new branch at the § `refVarLocalWindowBinds5` bind gate |
| probe surface | `tools/probe/r10uvm107repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **17** | **17** | 1 — a **NEW** head, a different object (see §7 R0) |
| **Scoreboard default** | **29** | **42** | 1 — a **NEW** head, one level DEEPER (uvm105's R-B cleared) |
| SeqDriver default / testflags | 60 | 60 | 1 unchanged |
| MiniAmiq default / testflags | 348 | 348 | 1 unchanged |
| BuildUVMPkg default / testflags | 32 | 32 | 1 unchanged |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes) | |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil | |
| the head's family, nine UVM databases | 0 of 38 cells agreed | **38 / 38 agree**, **0 AWAY**, 0 still-different | |
| the golden GRID (arm a1, both views) | 10 / 17 cells agreed | **17 / 17**, 0 away | |

## 1. THE HEAD, CONFIRMED FROM `BaseClass.h` + THE GENERATED `Compare` FIRST

The 17-line head, verbatim from the pristine cmp log
(`head_pris_default_SimpleUVM.cmp`):

```
LHS  logic_net: (work@top.param_t)  @290:27-290:34
       |vpiParent: \_module_inst: work@top  (SimpleUVM/testbench.sv:44:1-71:10)
       |vpiName:param_t   |vpiFullName:work@top.param_t   |vpiNetType:1
RHS  <null>
```

**THE FIELD IS `ref_obj::Actual_group`, NOT `module_inst::Nets`** — read off both
`uhdm-dump`s, not assumed. `module_inst::Nets` is a VECTOR, and the vector
`SafeCompare` overload (`~/.local/include/uhdm/BaseClass.h:202-224`) names BOTH
CONTAINERS on a size mismatch and the OWNER on a null-vs-nonempty; this head
names the NET ITSELF with `RHS: <null>`, which is the SINGULAR overload's
`lhs != nullptr && rhs == nullptr` arm (`BaseClass.h:187-193`). The carrier is
golden's `ref_obj (…::send_request::param_t)` @290:27 in the **`uhdmtopPackages`**
copy of `uvm_pkg`, whose `vpiActual` is that net; ours carries none. `design::
Compare` (`~/git-repos/UHDM/build/generated/src/design.cpp:296-302`) walks
`AllPackages` **then** `TopPackages` **then** `AllModules`, which is why the
reference is reached before the module's net list.

Source: `uvm-1.2 seq/uvm_sequencer_param_base.svh`

```systemverilog
function void uvm_sequencer_param_base::send_request(               // :267 (OUT OF BODY)
        uvm_sequence_base sequence_ptr, uvm_sequence_item t, bit rerandomize = 0);
  REQ param_t;                                                      // :270  <- uvm105's unsupported_typespec
  …
  if ($cast(param_t, t)) begin                                      // :281  -> golden binds the ref_var
    …
    m_last_req_push_front(param_t);                                 // :290  -> golden binds THE WIRE
  end
  …
  if (m_req_fifo.try_put(param_t) != 1) begin                       // :297  -> golden binds THE WIRE
```

## 2. THE LAW

> **§ `oobRefVarLocalHoistNet107`** — *A `ref_var` DECLARATION is invisible to
> Surelog's late binder. Every scope arm of `UhdmWriter::lateBinding` skips a
> candidate whose object is a `ref_var`, so a reference to such a local that
> reached the late-binding pool can never bind its own declaration: it falls
> through to the MODULE-LEVEL search, and when nothing there answers either
> Surelog MINTS AN IMPLICIT WIRE in the module being written and binds the
> reference to it. Which references reach the pool is exactly what
> § `refVarLocalWindowBinds5` already models — plus the ONE cell that law's own
> residue R1 names, a CLASS-RECEIVER call in EXPRESSION position.*

### DECODED FROM SURELOG, file and line

1. **The skip.** `UhdmWriter::lateBinding`
   (`src/DesignCompile/UhdmWriter.cpp:3294`) walks the reference's `VpiParent`
   chain. In the `uhdmfunction` arm (`:3383`, `:3394`), the `uhdmtask` arm
   (`:3446`, `:3456`), the `uhdmbegin` arm (`:3554`), and the `named_begin` /
   `fork_stmt` / `named_fork` / package-`Variables()` arms, every candidate is
   filtered by the same line:
   `if (decl->UhdmType() == uhdmref_var) continue;`
   A `ref_var` local can therefore NEVER be the answer.
2. **The mint.** With the walk exhausted and the module-level search
   (nets, array_nets, variables, param_assigns, parameters, property/sequence
   decls, typespecs, file typedef enums, design parameters, `mod->getValue`)
   empty too, `UhdmWriter.cpp:3982-4004` makes a `logic_net`, names it after the
   unbound token, parents it at the module, stamps it with the REFERENCE's span
   (`net->VpiLineNo(ref->VpiLineNo())` … `VpiEndColumnNo`) and
   `VpiNetType(getVpiNetType(elem->m_defaultNetType))` — `1` (`vpiWire`) for the
   default net type — pushes it onto `inst->Nets()` and does
   `ref->Actual_group(net)`.
3. **Which module.** `lateBinding(s, mod, m)` runs over `mod->getLateBinding()`,
   and a module INHERITS the whole unbound-reference list of every package it
   imports: `CompileHelper::importPackage` copies it wholesale
   (`src/DesignCompile/CompileHelper.cpp:190-193`, the "Incomplete bindings"
   block), and `CompileModule.cpp:571-581` feeds every `paPackage_import_item`
   **IN THE FILE** — a FILE-SCOPE `import uvm_pkg::*;` included, which is
   SimpleUVM's spelling — to that call for the module. This is the same pool our
   § `classPropRefs` / § `withIterRefBindsHoistNet75` /
   § `classEnumConstBindsHoistNet76` already model, one symbol class wider.
4. **ONCE per reference.** `lateBinding`'s first line is
   `if (ref->Actual_group()) continue;` and the ref objects are SHARED, so the
   FIRST module written that cannot bind a given reference mints the only wire
   for it. Arm a3 measures that directly (§3, residue R-MULTI).
5. **Why the `= new` lvalue is different.**
   `CompileHelper::compileBlockingAssignment`'s `= new …` arm
   (`src/DesignCompile/CompileHelper.cpp:4533-4557`) hands `compileExpression` a
   `paHierarchical_identifier` node, so THAT lvalue is built as a **hier_path**
   around the reference — and a hier_path element binds nothing. Every other
   assignment lvalue is a plain `ref_obj` and does take the wire.

## 3. THE GRID — golden's answer for every cell, both views

`grid107.sh <arm.sv> <bin A> <bin B> <workdir> <cen bin>` builds three databases
per view (`def` and `--elabuhdm`/`-elabuhdm`), echoes every command with its own
`rc` into `<workdir>/cmds.txt`, and censuses all six. `GRID.txt` has the cells
verbatim; the decisive ones (arm a1, the ELABPKG listing — the copy a module
hoists):

| arm a1 cell | written | golden | ours, pristine | ours, patched |
|---|---|---|---|---|
| `oob_userarg` 47:16 `plain_take(v)` stmt, depth 0 | receiver-less user call arg | **ref_var** | ref_var | ref_var |
| `oob_recvarg` 52:12 `s.take(v)` stmt, depth 0 | CLASS-RECEIVER call arg | **ref_var** | ref_var | ref_var |
| `oob_builtinarg` 66:18 `qv.push_back(v)` stmt | BUILT-IN method arg | **ref_var** | ref_var | ref_var |
| `oob_sysarg` 71:15 / 73:16 | `$cast` / `!$cast` arg, depth 0 | **ref_var** | ref_var | ref_var |
| `oob_cond` 93:9 `if (v == null)` | condition operand | **ref_var** | ref_var | ref_var |
| **`oob_recvexpr` 57:15 / 59:15 `if (s.ask(v) == 0)`** | CLASS-RECEIVER call arg, EXPRESSION position | **logic_net** | ref_var | **logic_net** |
| **`oob_recvexpr` 60:14 `s.take(v)` one block deeper** | | **logic_net** | — | **logic_net** |
| **`oob_deep` 80:18 / 81:14** | the SAME two calls, one control body deeper | **logic_net** | — | **logic_net** |
| **`oob_asg` 87:5 / 88:13** | assignment LHS and RHS, depth 0 | **logic_net** | — | **logic_net** |
| `oob_recvcall` 99:11 `v.m(1)` | the local AS THE RECEIVER | — | — | — |
| `oob_ret` 104:12 `return v.fld` | hier_path element | — | — | — |
| `ct_userarg` 109:16 / 110:12 | the CONTROL: a RESOLVABLE local type, identical positions | class_var | class_var | class_var |

**17 of 17 cells agree with golden after the patch, 10 of 17 before; 0 away.**
Both views (`def` and `elab`) give the same table.

`g107_a2.sv` is the NEGATIVE control for the hoisting shape: an out-of-body
method whose only references are receiver-less call arguments at depth 0 (golden
`ref_var`) in a package imported at FILE scope by one module, at BODY scope by
another, and not at all by a third — the pristine and patched databases are
BYTE-IDENTICAL for it, and golden mints no wire either.

`g107_a3.sv` is the OWNER grid: the same reference one control body deeper, with
THREE importing modules (two of them TOPS, one a child instance) and one module
that imports nothing. **Golden mints `e1` and `t1` in `work@childmod107` ALONE**
— §2 point 4's "once per reference" — while we mint them in all three importing
modules. That is the PRE-EXISTING behaviour of the shared hoisted-net pool (the
same arm shows `anchor` and `base107`, § `classPropRefs`' own names, minted in
all three by the PRISTINE binary against golden's one), so this law inherits it
rather than introducing it; residue R-MULTI, **zero corpus reach** (§6 measures
SimpleUVM's and SeqDriver's wire multiplicities as byte-equal to golden's).

**GOLDEN-VS-GOLDEN CALIBRATION FIRST** (`goldcen107.sh`, a verbatim copy of
uvm105's). Over the five UVM tests that have both modes the `default` and
`testflags` goldens are two independent Surelog runs of the same design; four of
five pairs are identical and Scoreboard differs on three rows, none in this
law's family — so `EXPM_N = 0` for the family and every golden-vs-ours number
here is read against zero expected mismatch.

## 4. THE FIX, AND ITS FIVE CONJUNCTS

`src/ExprEmit.cpp`, at the § `refVarLocalWindowBinds5` bind gate — the same
site, one branch earlier. The reference is handed to the hoisted-net pool
(`classPropRefs`, whose binder `bindHoistedClassPropRefs` mints the wire in the
def-view module at the FIRST reference's span) when ALL of:

1. `inClassBodyEmit && classBodyHomePkg75` — an OUT-OF-BODY method body of a
   PACKAGE class, the only body a module hoists;
2. the emitted DECLARATION OBJECT is a `ref_var` (§2 point 1's own test — read
   off the object, never off the written type);
3. it is a plain subroutine/statement-block LOCAL of kind `Variable`, and not
   the function RETURN name (§ 5's conjuncts, unchanged);
4. `!bind5` — § `refVarLocalWindowBinds5` refused to bind it — **OR** the new
   `recvUserMethodArgDepth107 > 0`, the ONE-NAME-RECEIVER class-method call in
   EXPRESSION position, which is § 5's own documented residue R1;
5. …and the `= new` FENCE is clear: the reference is not (inside) the LEFT side
   of a written assignment whose RIGHT side is a `new` construction (§2 point 5).

`recvUserMethodArgDepth107` is raised at EXACTLY ONE site — the
`!callStmtCtx0 && recv0.kind == NamedValue` arm that renders a two-element
`hier_path` over the receiver ref and a `method_func_call`. Arm a1 reads all
four call spellings off ONE golden and only that one moves (§3).

**DIRECTION: it changes a BINDING and nothing else.** No object is created,
renamed, respanned or reparented except the implicit `logic_net` the pool mints,
which takes golden's own name, span, parent and `vpiNetType` — measured by the
order-blind whole-dump attribution in §6.

## 5. THE FENCE AND THE PREDICTION — written from PRISTINE databases only

`fence107.sh <sweep workdir> <cen bin> <out.tsv>` censuses BOTH sides of every
test in a sweep workdir and reports every reference where golden carries a
`logic_net` vpiActual, ours does not, and the name is a `ref_var` LOCAL of that
same owner in OUR OWN database. Those are the sites the law MUST move.

| corpus | measured | SKIP | OTHER sites | **HIT sites** | **databases that MUST move** |
|---|---|---|---|---|---|
| surelog | 956 | 617 | 27174 | **28** | **4** |
| uhdm2rtlil | 1358 | 104 | 8 | **0** | **0** — the predicted NONE |

The four, BY NAME: `{default,testflags}/{SimpleUVM,SeqDriver}`. The seven SITES,
identical in each:

```
uvm-1.2 seq/uvm_sequencer.svh:171:31        stop_sequences   m_req_fifo.try_get(t)
                             :284:26        item_done        m_req_fifo.try_get(t)
        seq/uvm_sequencer_param_base.svh:290:27  send_request m_last_req_push_front(param_t)   <- THE HEAD
                                        :297:26  send_request m_req_fifo.try_put(param_t)
        seq/uvm_sequence_library.svh:764:17 execute          !$cast(req_item, obj)
        base/uvm_component.svh:3411:35      m_set_cl_verb    m_time_settings.push_back(setting)
                              :3425:44      m_set_cl_verb    m_verbosity_settings.push_back(setting)
```

`pred107.sh` is the MOVER predictor, also written from pristine databases and
from OUR SIDE ALONE: a database can only move if it holds a reference that names
a `ref_var` local of an OUT-OF-BODY task/func, currently carries `NONE` or the
declaration, and is not a hier_path element. It names **11** surelog databases —
the nine UVM ones plus `{default,testflags}/ApbSlave` (2 sites each) — and
**0** uhdm2rtlil databases. The measured movers are the **nine UVM databases**,
a subset; ApbSlave's two sites are receiver-less depth-0 call arguments, which
§3's grid says golden binds to the declaration, and they did not move.

## 6. THE GATE BATTERY

See `GATES.txt` for the whole battery with its numbers, the `cmds.txt` binary
audit, the boundary runs and the order-blind mover attribution.

## 7. RESIDUES, named for the queue

**R0 — THE NEW HEAD of SimpleUVM x2 (17 lines).** The SINGULAR MIRROR of the one
this pass cleared: an implicit wire OURS mints and golden does not.

```
LHS  <null>
RHS  logic_net: (work@top.rsp_export)  @228:3-228:13
       |vpiParent: \_module_inst: work@top
       |vpiName:rsp_export   |vpiFullName:work@top.rsp_export   |vpiNetType:1
```

`uvm_sequencer_param_base.svh:228` is the class PROPERTY declaration
`uvm_analysis_export #(RSP) rsp_export;`, and the reference that mints our wire
is the BASE of a `hier_path` (`rsp_export.<something>`). The name-and-span-keyed
join of the two SimpleUVM/default databases (§3's instrument, run over the whole
listing) counts **16 such cells**: `event_pool` @1800:3, `hdl_paths_pool` @230:4
/ @266:5 / @956:4 / @1971:5, `m_atomic` @1178:4, `m_end_node` @817:5,
`m_hdl_paths_pool` @951:4 / @1183:4 / @1355:5 / @2150:5, `m_req_fifo` @231:3,
`mam` @984:7, `rsp_export` @228:3, `seq_item_export` @152:3,
`sqr_rsp_analysis_fifo` @229:3 — every one of them `golden=NONE ours=logic_net`
with `parent=hier_path`. So the law to decode is the COMPLEMENT of § 76 /
§ classPropRefs: **a class property named as the BASE OF A HIER_PATH inside an
out-of-body method body does NOT join Surelog's late-binding pool**, because
`compileComplexFuncCall` builds the path's first element as a bare name-only
`ref_obj` and never registers it. Our § classPropRefs pool takes it anyway. One
predicate, 16 cells, and it is the head of BOTH SimpleUVM rows. PRE-EXISTING —
the pristine binary mints all sixteen; this pass only uncovered it.

**R-C — the NEW head of Scoreboard/default (42 lines), TWO levels deeper.**
uvm105's R-B (`RHS: ref_var …::send_request::param_t`, ours carrying an actual
golden does not) is CLEARED by this law — that head was `ref_obj::Actual_group`
at 297:26 / 284:26, and the fence's own table says golden holds NOTHING there in
Scoreboard (no module of that design hoists `uvm_pkg`). With it gone `Compare`
descends to a constant-fold cell that has nothing to do with this family:

```
LHS  constant: @529:23-529:24  |vpiDecompile:-1 |vpiSize:64 |INT:-1 |vpiConstType:7
RHS  operation: @529:23-529:25 |vpiOpType:1 |vpiOperand: constant UINT:1 @529:24
```

golden FOLDS the written `-1` into one signed INT constant where we keep a unary
MINUS operation over `1`. A different law (§ unary-minus literal folding), and
the count grew 29 -> 42 because the new head prints more lines: a MASK REMOVAL,
not a regression — §6's order-blind attribution proves the ONLY objects that
changed in that database are the two references and the wires.

**R-MULTI — the wire is minted ONCE PER REFERENCE, in the FIRST module that
cannot bind it.** `UhdmWriter::lateBinding`'s own first line
(`if (ref->Actual_group()) continue;`) plus SHARED ref objects mean exactly one
module gets the wire. Arm a3 measures it: golden mints `e1`/`t1` in
`work@childmod107` ALONE, we mint them in all three importing modules. This is
the PRE-EXISTING behaviour of the shared hoisted-net pool
(`bindHoistedClassPropRefs` binds per module) — the same arm shows § classProp-
Refs' own `anchor` / `base107` minted in all three by the PRISTINE binary — so it
is inherited, not introduced. **Zero corpus reach**: SimpleUVM's and SeqDriver's
wire multiplicities are byte-equal to golden's (§6), because each has exactly one
importing module. A pass that fixes it must move § classPropRefs / § 75 / § 76
together with this law.

**R-P — the `process` family, uvm105's own R-P, still open and still ranked.**
Golden mints a wire for `process phase_runner_proc` (`uvm_root.svh:502:5`) and
`process m_reg_process` (`uvm_reg.svh:2977:4 / :2980:10 / :2983:18`), and we
carry a `class_var` there: the local is not a `ref_var` on our side at all,
because § 105's unsupported-typespec law does not reach a `process`-typed local.
5 cells in SimpleUVM alone; 220 sites over the nine databases in the OTHER family
uvm105's fence reported. Fix that declaration first and THIS law picks the
references up for free.

**R-NONREFVAR — the same wire for a local that is NOT a `ref_var`.** golden also
mints `sz` @488:15 / @509:14, `n` @1427:25 / @1491:22, `addr` @1491:44,
`local_addr` @1467:39, `select_rand` @673:26, `select_randc` @691:26 and
`uvm_phase` @1722:82 in SimpleUVM's `work@top`, where the declaration is an
`int_var` / `bit_var` / `array_var` on BOTH sides. Those references reach
Surelog's late-binding pool for a reason this law does not model (they are
`new(...)`/`randomize()` arguments and foreach-scope reads), and the `ref_var`
gate deliberately excludes them. 9 cells, all `golden=logic_net ours=NONE`,
zero risk either way.

**R-CTOR — a CONSTRUCTOR body local.** Boundary arm
`r10uvm87repro/v87_a3_oob.sv:29:5`, `function o87::new(REQ a); REQ l_ctor;
l_ctor = a;`: golden binds a **`logic_var` named `p87x::l_ctor` in the PACKAGE**
(not a module wire at all), the pristine binary binds nothing and the patched one
binds the module wire. Neither is golden; the cell is OTHER, not AWAY, and it is
the only such cell in the whole 3347-arm boundary. A constructor-specific leak,
its own law, **zero corpus reach** (the nine UVM databases score 38 to-golden and
0 away over 464k reference cells).

**R-ELABMULT — the ELAB copy COUNT.** Boundary arm `r10buvm9repro/w4v_imports.sv`
run with `--elabuhdm`: golden holds THREE `ref_var`-bound copies of the reference
at 36:53 where we hold ONE, so our single copy flipping from `NONE` to the wire
is neither to-golden nor away. uvm103/uvm105's R-M multiplicity family, untouched
here.

**R-DEFCOPY — the DEF listing's half.** In Scoreboard the ELABPKG copy of
`send_request` now matches golden (`NONE`), while the DEFPKG copy still carries
the `ref_var` golden does not. `inClassBodyEmit` is false for that copy by
construction, so the law cannot reach it. Pre-existing, one cell per site,
not cmp-visible today (the DEF listing compares equal before the reference).

## 8. FILES

```
README.md                       this file (the decoded law)
GATES.txt                       the whole gate battery with its numbers
GRID.txt                        the golden grid, both views, cell by cell
SCORE.uvm9.txt                  TO-GOLDEN/AWAY/STILL over the nine UVM databases
PREDICTION.txt                  the fence + the mover predictor, from PRISTINE only
PREDICTION.fence_pristine_*.tsv the fence rows (HIT in full, OTHER sampled)
PREDICTION.pred_pristine_*.tsv  the mover predictor's candidate rows
BOUND.{file,dir}.{def,elab}.txt the four boundary runs
ATTRIB.file.{def,elab}.txt      the boundary arms attributed against a fresh golden
ATTRIB.movers.txt               the order-blind attribution of the nine byte movers
head_pris_default_SimpleUVM.cmp the whole 17-line head this pass cleared
head_pat_default_SimpleUVM.cmp  the whole NEW 17-line one            (R0)
head_pat_default_Scoreboard.cmp the whole NEW 42-line one            (R-C)
g107_a1.sv                      the REFERENCE-POSITION grid (13 positions + controls)
g107_a2.sv                      the hoisting-shape NEGATIVE control (file/body/no import)
g107_a3.sv                      the OWNER grid (three importing modules, two tops)
r10uvm107cen.cpp                the reference-actual census (+ the RV lines)
score107.py                     TO-GOLDEN / AWAY / STILL multiset scorer
build107.sh                     builds a probe from THIS directory
grid107.sh                      builds a grid arm's 3 databases in BOTH views
fence107.sh                     the fence over a sweep workdir
pred107.sh                      the mover predictor over a sweep workdir
attrib107.sh                    boundary-arm attribution against a fresh golden
bound107.sh                     the boundary gate (a verbatim copy of bound23.sh)
goldcen107.sh                   golden-vs-golden calibration
byteverify.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh ct8rows.sh
                                the standing gate instruments, copied so this
                                directory can re-run its own battery
```
