# r10buvm21 — § `incDecStmtOperandBinds21` — **an increment/decrement STATEMENT binds its operand's simple names, inside the very in-body class method where everything else stays bare**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `e5eb5af` |
| worktree | `/tmp/wt_r10buvm21` |
| pristine binary | md5 `9cb73f6c03626b09747a2bee794514c9` (reproduced the main tree's byte-for-byte at pass start), frozen `chmod 555` at `/tmp/r10buvm21_bin/pristine.bin` |
| patched binary | md5 `15cb901fe573c114ed7f5ec336049af2`, frozen at `/tmp/r10buvm21_bin/pat.bin` |
| production surface | `include/UhdmExporter.h` (state + the decode), `src/StmtEmit.cpp` (the statement-position token, 24 lines), `src/ExprEmit.cpp` (the eligible-set walk, the symbol predicate and ONE new disjunct in the reference gate) |
| probe surface | `tools/probe/r10buvm21repro/` only |
| deliverable | `/tmp/r10buvm21.patch`, applies clean on a FRESH `e5eb5af` |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass** — and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines in both corpora and both modes.  What it
does is clear the head buvm20 handed over (R0) and open a bind window that no
previous law had: the increment/decrement STATEMENT.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines (`2>&1`), default / testflags | **29 / 29** | **52 / 52** |
| `BuildUVMPkg` cmp lines (stderr only) | 15 / 15 | 26 / 26 |
| `BuildUVMPkg` cmp md5 (`2>&1`), both modes | `6e1067f47e20fd6cf7dd7509fb3eb99e` (the brief's pin, hit exactly) | `f21a1042bba06220ee5c1e4f49ff24f4` |
| head object | `io_decl (severity)` vs `<null>` — a `ref_obj::Actual_group` bind gap | `ref_var` vs `logic_var` on a queue-typedef'd function RETURN variable (**R0**) |
| formal/local reference census, `BuildUVMPkg` (44 945 cells) | — | **CONVERTED 1, OVER-FIRE 0, MSW 0**, same 42 424, residue 2 520 |
| the golden GRID (`g21.sv` + `g21b.sv` + `g21c.sv`, 194 cells) | — | **CONVERTED 42, OVER-FIRE 0, MSW 0, residue 0** |

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

`/tmp/r10buvm21_wd/pris.default.cmp` (29 lines `2>&1`, md5
`6e1067f47e20fd6cf7dd7509fb3eb99e`, `grep -c '^LHS:'` = 1):

```
LHS:
io_decl: (severity), id:129936, line:30000:50, endln:30000:58
|vpiParent:  \_function: (uvm_pkg::uvm_default_report_server::incr_severity_count), id:129935
|vpiDirection:1
|vpiName:severity
|vpiTypedef:  \_ref_typespec: (…::incr_severity_count::severity), id:129937
                |vpiActual: \_enum_typespec: (uvm_pkg::uvm_severity), id:2737
RHS: <null>
```

`LHS` set with `RHS: <null>` is `BaseClass.h:190`'s SINGULAR arm
(`lhs != nullptr && rhs == nullptr`, `m_failedLhs` only), so it names a VALUE,
not a container.  `ref_obj::Compare`
(`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:150`) has exactly ONE
singular `SafeCompare` — `Actual_group()` — and that is where it is.  Read
straight out of the two dumps rather than inferred:

```
golden   |vpiIndex: \_ref_obj: (…::incr_severity_count::severity) @30001:22
             |vpiParent: \_bit_select: (…::m_severity_count)
             |vpiActual: \_io_decl: (severity) @30000:50      <-- the head
ours     |vpiIndex: \_ref_obj: (…::incr_severity_count::severity) @30001:22
             |vpiParent: \_bit_select: (…::m_severity_count)
                                                              <-- no vpiActual
```

### THE BRIEF'S THREE CANDIDATES, AND WHICH ONE IT IS

The brief asked whether the distinguisher is the POSITION (a bit-select index),
the CARRIER (the `++`) or the ARRAY KIND (assoc-by-enum).  **Golden answers in
the same class, three functions apart** — `uvm_pkg.sv:29988/29994/30000`, the
same associative array, the same formal name, the same in-body method home:

| site | text | golden |
|---|---|---|
| `get_severity_count` | `return m_severity_count[severity];` | **BARE** |
| `set_severity_count` | `m_severity_count[severity] = count < 0 ? 0 : count;` | **BARE** |
| `incr_severity_count` | `m_severity_count[severity]++;` | **BOUND** |

So it is neither the position nor the array kind: it is **the CARRIER**.  And it
is not simply "`++`" either — `incr_id_count` (`uvm_pkg.sv:30043`) writes the
identical `if (m_id_count.exists(id)) m_id_count[id]++;` and golden leaves it
BARE, while `uvm_reg_block::new` (`uvm_pkg.sv:78244`) writes that same `if`
shape and golden BINDS it.  The two differ only in the method's HOME
(in-body class method vs OUT-OF-BODY definition), which is § `classMethodNoBind`
already; inside the in-body home the discriminator is whether the `++` is
reached WITHOUT a control statement.

## 2. THE LAW

> **§ `incDecStmtOperandBinds21`** — an **increment/decrement STATEMENT** binds
> the SIMPLE NAMES of its operand to their `io_decl` / body-local variable, in
> the very bodies where § `classMethodNoBind` and § `unitSubNoBind9` otherwise
> silence every reference: an **IN-BODY class method** (a class homed in a
> package, a module or `$unit`) and a **`$unit`-scope subroutine**.
>
> The window is exactly:
> * the carrier is an inc/dec **statement** (`vpiPostIncOp`/`vpiPreIncOp`/
>   `vpiPostDecOp`/`vpiPreDecOp`), never an inc/dec in expression position
>   (`r = a[s]++;` is golden-bare);
> * the chain from it up to the subroutine passes only through BLOCK scopes —
>   `begin`, `begin : label`, `fork` — and through **no** control statement
>   (`if` / `while` / `for` / `repeat` / `forever` / `do-while` / `case` item);
> * the bound names are the whole operand when it is a plain name, and the
>   plain-name INDEX of each `ElementSelect` step of a select **whose base is a
>   plain name** — never the base itself, never a compound index, never a
>   member path, never an indexed part-select;
> * the symbol must be a FORMAL or a subroutine-scope local **not declared in a
>   NAMED block** — a class property and an enum constant stay bare.
>
> Everything else about the site is IRRELEVANT, measured: the array kind
> (assoc-by-enum / -int / -string, queue, dynamic, fixed, 2-D), the formal's
> direction (`input`/`output`/`inout`/`ref`), `static` / `virtual` / task vs
> function, and the number of dimensions (a 2-D `prop_2d[s][t]++` binds BOTH
> indices).

## 3. DECODED FROM SURELOG (read, not guessed)

`CompileHelper::bindVariable`
(`~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp:3089`) is the EAGER
binder.  It takes the `pexpr` the reference is being built under and walks it up
its `VpiParent` chain, inspecting only `uhdmfunction` / `uhdmtask` / `uhdmbegin`
/ `uhdmmodule_inst` scopes and reading their `Variables()` then `Io_decls()`:

```cpp
    case uhdmfunction: { function* lscope = (function*)scope;
      if (lscope->Variables()) for (auto var : *lscope->Variables())
          if (var->VpiName() == name) return var;
      if (lscope->Io_decls())  for (auto var : *lscope->Io_decls())
          if (var->VpiName() == name) return var;
      break; }
    ...
    default: break;
  }
  return bindVariable(component, scope->VpiParent(), name, compileDesign);
```

and **every UHDM statement node gets its own `VpiParent` only at the END of
`CompileHelper::compileStmt`** (`stmt->VpiParent(pstmt);`, CompileStmt.cpp:1084)
— i.e. AFTER its children have been compiled.  `compileConditionalStmt`
(CompileStmt.cpp:1304) makes its `if_stmt` / `if_else` and calls `compileStmt`
on the branch with `cond_stmt` as `pstmt` **without ever setting
`cond_stmt->VpiParent`**, so from inside an `if` arm the walk hits a NULL parent
one step up and finds nothing.  The same is true of an assignment's lhs/rhs, a
`return` operand and a call argument — each interposes a node that is not yet
parented.

The ONE statement form that interposes NOTHING is the inc/dec statement:

```cpp
    case VObjectType::paInc_or_dec_expression: {
      stmt = compileExpression(component, fC, the_stmt, compileDesign,
                               Reduce::No, pstmt, instance);
      break; }
```

(`CompileStmt.cpp:222`) — `pstmt`, the ENCLOSING scope object (the `function`,
or the `begin`/`named_begin`/`fork` that already carries its own parent), is
handed straight through as `pexpr`, so `bindVariable` reaches the subroutine and
binds.  When the eager bind fails the reference is pushed on the component's
LATE list (`component->needLateBinding(ref)`), and for an IN-BODY class method
that list is **never processed**: `UhdmWriter.cpp:1067`'s
`lateBinding(s, classDef, c)` is COMMENTED OUT.  An OUT-OF-BODY method and a
package free function are compiled with the PACKAGE as `component`, whose list
IS processed (`UhdmWriter.cpp:1304`), which is why they bind in every carrier —
and why `seed_map.count[type_id]++` in the package free function
`uvm_create_random_seed` binds its index through a MEMBER-path base while the
same shape in an in-body class method does not.

## 4. THE GOLDEN GRID (`g21.sv`, `g21b.sv`, `g21c.sv` + `grid21.sh` + `cen3.py`)

Three Surelog runs, `ALLREFS=1 r10buvm21cen` on each of the three databases
(golden / pristine / patched), joined as a MULTISET by
(view, owner subroutine, node kind, name, ancestor shape).  194 cells:
**CONVERTED 42, OVER-FIRE 0, MOVED-STILL-WRONG 0, residue 0.**

`g21.sv` — HOME x CARRIER x ARRAY KIND x DIRECTION (98 cells, 17 CONVERTED):

| cell | golden |
|---|---|
| in-body `aa_enum[s]++` (sole body statement) | **BOUND** (the head's shape) |
| in-body `--`, prefix `++`, `int`/`string`-keyed assoc, queue, dynamic, fixed | **BOUND** |
| in-body `output` / `inout` / `ref` formal, `static`, `virtual`, TASK | **BOUND** |
| in-body `begin aa[s]++; end`, two `++` statements (implicit begin) | **BOUND** |
| in-body `s++` (a bare formal, no select) | **BOUND** |
| in-body `if (…) aa[s]++;`, `for (…) aa[s]++;` | bare |
| in-body `aa[s] += 1`, `aa[s] = 1`, `return aa[s]`, `$display(aa[s])` | bare |
| package free fn / OOB method / module fn — EVERY carrier incl. `if` | **BOUND** (already ours) |

`g21b.sv` — the CONTROL-CARRIER and HOME boundary (62 cells, 15 CONVERTED):

| carrier between the `++` and the subroutine | golden |
|---|---|
| nothing / `begin` / `begin begin` / `begin : lbl` / `fork…join` | **BOUND** |
| `if` / `while` / `repeat` / `forever` / `case` item / `do…while` / `for` | bare |
| home = class in a PACKAGE / in a MODULE / at `$unit` | **BOUND** in all three |
| a `$unit` FREE function (`uf_inc`, `uf_inc_loc`) | **BOUND** |
| a NAMED-block local (`begin : nb int nbl; nbl++;`) | bare (the formal in the same block still binds) |
| an inc/dec in EXPRESSION position (`r = aa[s]++;`) | bare |
| an indexed part-select base (`pvec[s+:2]++`) | bare |

`g21c.sv` — the OPERAND SHAPE: which object inside the operand takes an actual
(34 cells, 10 CONVERTED):

| cell | golden |
|---|---|
| the plain-name INDEX (`prop_arr[s]++`, `st_arr[s]++`, `fa[s]++`, `la[s]++`) | **BOUND** |
| a local variable used as index (`prop_arr[lv]++`) | **BOUND** (`enum_var`) |
| the scalar operand when it is a LOCAL (`lc++`) | **BOUND** (`int_var`) |
| BOTH indices of a 2-D select (`prop_2d[s][t]++` -> `var_select`) | **BOUND** |
| the select BASE — even a body local (`la`) or a formal (`fa`) | bare |
| a class PROPERTY as the scalar operand (`prop_sc++`) | bare |
| an ENUM CONSTANT index (`prop_arr[EA]++`) | bare |
| a COMPOUND index (`prop_arr[ce21'(s)]++`) | bare |
| a member path (`prop_st.a++`, `marr[s].a++`) | bare |
| **an index on a MEMBER-PATH base (`hnd.h_arr[s]++`)** | **bare** — see § 6 |

## 5. THE CORPUS CENSUS (`r10buvm21cen`, `ALLREFS=1`, `BuildUVMPkg`)

One row per NAMED reference (`ref_obj` / `bit_select` / `ref_var`) inside a
subroutine body, keyed (view, owner subroutine fullname, node kind,
`name@line:col`, ancestor-kind shape with `operation` carrying its
`vpiOpType` and the parent's SLOT), valued `kind(name)` of its `Actual_group`
or `BARE`.  Multiset join, three ways:

```
-- CELLS 44945  same 42424  CONVERTED 1  OVER-FIRE 0  MOVED-STILL-WRONG 0  residue 2520
CONVERTED  ELABPKG|uvm_pkg::uvm_default_report_server::incr_severity_count
           |ref_obj|severity@30001:22|bit_select:IDX<operation#62:OP0
           G=io_decl(severity)  O=BARE  P=io_decl(severity)
```

The FORMAL-only run of the same census (default off) is the one that found the
head without being told where to look: over the whole `BuildUVMPkg` database it
reported **exactly ONE key where golden BINDS and we do not** — this one — plus
three where WE bind and golden does not (residue **R2**) and 179 shape-only keys
where both sides are BARE.

### THE MOVER SET, PREDICTED BY NAME FIRST

`r10buvm21pred` + `predict21.sh` read ONLY the GOLDEN databases (independent of
both our binaries) and count, per (test, mode), the cells whose golden carries
the law's shape in a home our emitter is SILENT in.  Run on the PRISTINE sweep
workdirs before the patched sweep was looked at:

```
surelog:  44 (test,mode) pairs over 22 tests, 533 cells
          AmiqEth AmiqSimpleTestSuite ApbSlave BuildOVMPkg BuildUVMPkg
          CoresSweRV CoresSweRVMP Driver Ibex IbexGoogle MiniAmiq Monitor
          Opentitan OVMSwitch Scoreboard SeqDriver SimpleClass1 SimpleInterface
          SimpleOVM SimpleUVM UnitAmiqEth UVMNestedSeq UVMSwitch
u2r:      0 tests, 0 cells   <- THE FENCE: no u2r row can move at all
```

Of those 22, exactly ONE is a `CMP_EQUAL` row — **`ApbSlave`** (both modes, a
brief-protected CANARY) — and it was checked FIRST, by hand, with the official
judge: `uhdm-cmp golden ApbSlave/slang.uhdm` is **0 lines (EQUAL)** on the
patched binary, and its database does not move at all.  The other 21 are
`SLANG_REJECT` / `SURELOG_FAIL` in both modes or already `CMP_NOTEQUAL`.

`byteverify SELFCHECK=1` reports **`MOVERS: 9 / 956`**:

```
BuildUVMPkg x2   MiniAmiq x2   SeqDriver x2   SimpleUVM x2   Scoreboard/default
```

every one of them inside the predicted set, **zero unpredicted movers**, and all
nine already `CMP_NOTEQUAL` rows — **no `CMP_EQUAL` row moved in either
corpus.**  `Scoreboard/default` is the known ~50/50 COIN, so it was not taken on
trust: its ORDER-BLIND diff (both dumps sorted, workdir paths and the uhdm-dump
banner normalised) is **2 lines and they carry `|vpiActual:`** — the law's own
lines — so it is a REAL mover.  All nine give the same signature, 0 removed / 2
added:

```
>             |vpiActual:
>             \_io_decl: (severity), line:458:50, endln:458:58
```

(uvm-1.2 `uvm_report_server.svh:458`, `incr_severity_count` — the same source
construct as the 1800.2 head, in the other UVM tree).

## 6. THE OVER-FIRE THE GRID CAUGHT, AND THE GATE THAT FIXED IT

The FIRST cut of this law walked the operand's `ElementSelect` chain and marked
every simple-name index, without asking what the chain's BASE was.  Arm `g21c`
cell `s_objidx` — `hnd.h_arr[s]++;` inside an in-body class method, where `hnd`
is a class handle PROPERTY — is a measured **PRISTINE-RIGHT -> patched-WRONG**
cell of that version:

```
G  ref_obj s @37:55  bit_select:IDX<hier_path<operation#62:OP0   BARE
O  ref_obj s @37:55  bit_select:IDX<hier_path<operation#62:OP0   BARE   <- GOLDEN
P  ref_obj s @37:55  bit_select:IDX<hier_path<operation#62:OP0   io_decl(s)  <- WRONG
```

A member-path base serialises as a `hier_path`, and Surelog builds its index
through `compileSelectExpression` under a `pexpr` that is the path node rather
than the enclosing scope, so the eager bind fails and the class's never-run late
list swallows it.  **The same text in a PACKAGE free function DOES bind** —
uvm-1.2 `uvm_create_random_seed`'s `seed_map.count[type_id]++`
(`uvm_pkg.sv:8694`, golden `io_decl(type_id)`, and ours already binds it) —
because there the late list IS processed; so the discriminator is the home, and
this window must not claim it.  The gate is one line, measured, not hedged:

```cpp
    if (cur21->kind != ExpressionKind::NamedValue)
        incDecBindElig21.clear();   // the select BASE must be a plain name
```

After it: 194 grid cells, 42 CONVERTED, **OVER-FIRE 0**.

## 7. THE GATES (all run in this worktree, both binaries frozen `chmod 555`)

| gate | result |
|---|---|
| 1. build both, md5 | pristine `9cb73f6c03626b09747a2bee794514c9` (BYTE-IDENTICAL to the main tree's binary at `e5eb5af`), patched `15cb901fe573c114ed7f5ec336049af2` |
| 2. goldens | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` -> **23 FAIL / 0 PASS** (negative control), `SLANG_UHDM` exported per binary |
| 3. u2r testflags vs committed `gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** (679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`) |
| 3. u2r testflags + default, patched vs the PRISTINE sweep taken first here | **PASS, 0 differing rows** both modes, status AND dump |
| 4. surelog `--mode both` vs committed `results/golden_surelog.csv` | **PASS, 0 differing rows over 1588**, status AND dump.  **NO ROW CONVERTED.** |
| 4. surelog patched vs the PRISTINE sweep | **PASS, 0 differing rows** |
| 5. byteverify `SELFCHECK=1`, u2r | `MOVERS: 0 / 1358`, selfcheck 1357/1358, PATH_SETS_IDENTICAL |
| 5. byteverify `SELFCHECK=1`, surelog | `MOVERS: 9 / 956`, all 9 predicted BY NAME first; selfcheck 955/956 |
| canaries | `canaries.sh` `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2.sh` PASS on both; `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` **byte-identical** both modes; `SVSwitch` `4842211c4030`; `YosysVerx` `6ccda350c24a` |
| heads (`rowheads.sh`, 7 rows x 2 modes) | 12 measured, 1 head each; only `BuildUVMPkg` changed (29 -> 52 lines); the other **ten cmp logs are byte-identical** between the two binaries (`cmp -s` on the raw logs) |
| boundary | `PROCESSED=2951 == LISTED=2951`, rejects symmetric (128 == 128, no asymmetric reject), **DIFFER=4** |

The PRISTINE sweep is byte-identical to both committed baselines, so there is no
drift to report this pass.  Every `cmds.txt` in all four sweep workdirs names
exactly one slang binary (`/tmp/r10buvm21_bin/pristine.bin` or
`/tmp/r10buvm21_bin/pat.bin`) — audited by PATH, not by the string
`slang-uhdm`.

### THE BOUNDARY'S FOURTH ARM IS A CONVERSION, NOT A BREACH

Three of the four differing arms are this pass's own (`g21.sv`, `g21b.sv`,
`g21c.sv` — its positive control, proof the gate can see).  The fourth is
`tools/probe/r10buvm7repro/v1_lvincdecshape.sv`, buvm7's own inc/dec LVALUE
SHAPE arm, and it was re-measured against GOLDEN before being accepted:

```
-- CELLS 44  same 37  CONVERTED 2  OVER-FIRE 0  MOVED-STILL-WRONG 0  residue 5
CONVERTED  p7::holder7::f1 ref_obj index  bit_select:IDX<operation#62:OP0<begin   (`iq[index]++`)
CONVERTED  p7::holder7::f1 ref_obj index  operation#62:OP0<begin                  (`index++`)
```

Both cells are golden `int_var(p7::holder7::f1::index)`, both were BARE in the
pristine binary and are golden in the patched one; every one of that arm's
COLLAPSE cells (§ `lvIncDecSelMemberCollapse7`) and its `hier_path` cells is
untouched.  Every other bind-window law in the tree
(§ `classArgBind12`, § `retNameRecvCollapseArgsBindLikeBody15`,
§ `collArgNamedBlkLocalNoBind15`, § `controlBodyNoBind28`,
§ `blkLocalSameCtrlDepthArgBinds57/64`, § `pkgVarBindsOnlyThroughInstance88`,
§ `formalDefaultBindsLikeBody13`, § `classInBodyRecvCallArgNoBind52`,
§ `superNewFormalBinds28`, § `newArrayArgNoBind16`,
§ `foreachElabLoopVarAnyKindBinds17`, § `pkgParamBareTdNamedClone18`,
§ `foreachArraySelfSelectAssignDropsTs19`, § `pkgClassOobRetNameBareClone20`,
buvm3-20, uvm82-95, sd8-12) is proved untouched by the other 2947 arms, in the
default view, not argued.

## 8. RESIDUES

**R0 — THE NEW HEAD (`BuildUVMPkg`, both modes, 52 cmp lines `2>&1` / 26 on
stderr, md5 `f21a1042bba06220ee5c1e4f49ff24f4`, 1 head).**

```
LHS: ref_var:   (uvm_pkg::uvm_report_message_element_container::get_elements), id:164670, 28181:20
     |vpiParent: \_function: (…::get_elements), id:164668
     |vpiTypespec: \_ref_typespec: … |vpiActual: \_array_typespec: (queue_of_element), id:186408
RHS: logic_var: (uvm_pkg::uvm_report_message_element_container::get_elements), id:90109, 28181:20
     |vpiParent: \_function: (…::get_elements), id:90108
     |vpiTypespec: \_ref_typespec: … |vpiActual: \_array_typespec: (queue_of_element), id:90110
```

BOTH sides are set and both are objects, so this is NEITHER `<null>` arm: it is
`BaseClass.h`'s two-object path, and the field that differs FIRST is the
object's own **`VpiType`** — `BaseClass::Compare`
(`~/git-repos/UHDM/build/generated/src/BaseClass.cpp:170`) tests
`VpiType() - rhs->VpiType()` BEFORE `VpiName` and before any per-kind field, and
`vpiRefVar` is not `vpiLogicVar`.  The `ref_typespec` / `array_typespec` payload
underneath already AGREES, name included, so nothing below the kind is even
looked at.  The site is

```
uvm_pkg.sv:28180  typedef uvm_report_message_element_base queue_of_element[$];
uvm_pkg.sv:28181  virtual function queue_of_element get_elements();
uvm_pkg.sv:28182    return elements;
```

— the FUNCTION RETURN VARIABLE of a virtual in-body class method whose return
type is a **typedef'd QUEUE** (an unpacked `array_typespec`).  Golden mints a
`ref_var` there and we mint a `logic_var`; § `typeParamRetIsRefVar58`
(`makeReturnVar`, `TaskFuncEmit.cpp`) already reshapes exactly this object for a
TYPE-PARAMETER return, so the next pass's question is whether the same reshape
is owed to an unpacked-array/queue typedef return, and in which views.  **It is
not a regression**: the pristine and patched `BuildUVMPkg` dumps differ by
**0 removed / 2 added lines**, both of them this law's `|vpiActual: io_decl`;
R0 was simply MASKED by the head this pass cleared.

**R1 — the 20 `WE-BIND / GOLDEN-BARE` cells of `BuildUVMPkg`, PRE-EXISTING and
untouched** (identical in both binaries — the three-way census scores them
`residue`, never `OVER-FIRE`).  Four families: a `class_var` static/process
handle written on an assignment LHS (`uvm_reg::XatomicX`'s `m_reg_process`,
`uvm_root::run_test`'s `phase_runner_proc`, `uvm_process_report_message`'s `p`,
`uvm_component::m_set_cl_msg_args`'s `p_`), a formal inside a nested `if`
(`uvm_registry_common::set_type_alias`, `uvm_report_handler::format_action`), a
TYPE-PARAMETER name used as a call argument (`send_request`'s `param_t`,
`item_done`'s `t`) and a `hier_path` operand (`uvm_objection::wait_for`'s
`obj`).  None is this law's window.

**R2 — the 8 `GOLDEN-BIND / WE-BARE` cells that REMAIN on `BuildUVMPkg`**, the
natural queue after this head:
`uvm_root::new`'s `clp` (assignment LHS, a class handle — DEF and ELAB),
`uvm_packer::unpack_string`'s self-reference inside a `while` body (golden binds
it to a `bit_select`, ×2), `uvm_config_db::wait_modified`'s `waiter` and
`uvm_sequence_base::wait_for_relevant`'s `e` (both `event_control` operands),
`uvm_reg_map::unregister`'s `q` and `uvm_registry_common::create`'s `msg` (call
arguments of a body local).

**R3 — the shapes this law deliberately does NOT claim**, each measured
golden-BARE and left bare: an inc/dec in expression position, under any control
statement, on a member path, on a compound index, on an indexed part-select
base, on a class property, on an enum-constant index, and on a NAMED-block
local.  And the one measured golden-BOUND shape it does not claim: an index on a
MEMBER-PATH base in a PACKAGE-homed subroutine already binds in ours, so there
is nothing to add there (§ 6).

## 9. THE INSTRUMENTS

| file | what it is |
|---|---|
| `r10buvm21cen.cpp` / `build21.sh` | the reference-bind census: one row per named reference inside a subroutine body, keyed (view, owner, node kind, name@loc, ANCESTOR-KIND SHAPE with `vpiOpType` and the parent's SLOT), valued `Actual_group` as `kind(name)`.  `ALLREFS=1` widens it from formals to every named reference (locals, class properties) — the axis this law needs. |
| `cen3.py` | the three-way multiset join (golden / pristine / patched) with the CONVERTED / OVER-FIRE / MOVED-STILL-WRONG / residue verdicts; `--noloc` drops the location from the key (our `bit_select` spans the INDEX where golden spans the whole select — a span is not a field `Compare` reads) |
| `g21.sv` / `g21b.sv` / `g21c.sv` / `grid21.sh` | the golden grid of § 4 and its three-way verdicts |
| `r10buvm21pred.cpp` / `predict21.sh` | the a-priori mover prediction, from the GOLDEN databases only |
| `sweeps21.sh` | both corpora, both modes, ONE named binary, into a workdir this pass owns (cmds.txt audited by PATH) |
| `bound21.sh` | the boundary gate: every `.sv` under `tools/probe` (subdirectories by construction), both binaries, fd-3 arm list, children `</dev/null`, PROCESSED asserted, banner normalised |
| `dumpdiff21.sh` | the whole-dump and ORDER-BLIND diffs of one test's two databases, workdir path and banner normalised (the Scoreboard coin) |
| `byteverify.sh` / `canaries.sh` / `ctcan2.sh` / `canaudit.sh` / `rowheads.sh` | carried forward unchanged from `r10buvm20repro` |
