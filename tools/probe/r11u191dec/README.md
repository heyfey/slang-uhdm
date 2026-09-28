# r11u191dec: map 10's shared and structural clusters decoded and scratch-verified (analyst pass, measurement only)

**Base.** `a1c89c1a` (branch matrix-1.87, pass 187), HEAD of the branch for the whole pass. Nothing under `src/`,
`scripts/`, `results/`, `tests/` or `third_party/` is edited by this patch; the laws are delivered as two patch files
for the pairs to land:

* [law_exprstmt.patch](law_exprstmt.patch) — ground A (`src/ExprEmit.cpp`, `src/ParamEmit.cpp`): three laws;
* [law_typeemit.patch](law_typeemit.patch) — ground B (`src/TaskFuncEmit.cpp`, `src/ModuleEmit.cpp`,
  `src/TypeEmit.cpp`): seven laws.

Both apply clean on a fresh `a1c89c1a`, alone and together (`git apply --check`, measured), and were measured alone
and together (section 5). Law names are written `law name` in the patches only; this README names them `law <name>` so
`scripts/law_index.py` does not read this directory as a pass.

**The map this pass works.** [r11u189map](../r11u189map/README.md) (map 10, at `2b97649e`). Passes 184, 186, 187 and
the verification r11u190 landed after it; every cluster was re-measured at `a1c89c1a` before it was worked (section 2).

**The fence.** No fenced row is `STRICT_NOTEQUAL` at `a1c89c1a` (the strict job list, `drivers/jobs.py`:
`fenced_skipped=0`), so no fenced database was ever opened by an analysis driver. Every driver that reads a corpus
source or database takes the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and refuses
them by word boundary, fail closed (`drivers/env.sh`, `drivers/common.py fenced()`): `jobs.py`, `first10.py`,
`clcount.py`, `census.sh` (run with `--filter` built from the fence), `bvmirror.sh` (the byte comparison ran on
hard-link mirrors that leave the 8 fenced row-mode databases out: `fenced_skipped=8`), `uvmdist.sh`, `coin.sh`,
`case.sh`, `dscase.py`, `attribution.sh`. The gate sweeps dispatched every row, as the gate requires. No binary, gdb
run or script touched a fenced test's sources or databases outside those sweeps; a grep of this directory for the four
names reads 0.

## 0. Verdicts per cluster family

| # | cluster (map 10) | the rule golden follows (decoded) | law, switch, ground | rows it moves | cases |
|---|---|---|---|---|---|
| a1 | **N0228** + **N0224** (the UVM rows' first open record: `hier_path` endcol under `bit_select`, its first `ref_obj` col) | a select that a member access CONTINUES, or a range select, is a `constant_bit_select` / `constant_range` in Surelog's grammar; a method call written in its index parses as `Subroutine_call(obj, Constant_bit_select, …)` with EMPTY selects zero-width at the dots, and `compileComplexFuncCall` locates each component `ref_obj` at the node it has already advanced to (the empty select after it) and the path at the first name | law `idxCallPathAtDots191`, `R11U191_HPENDCOL_OFF`, A (ExprEmit) | MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d: first record gone, strict count −2 each; N0228 0 left in every UVM row | H: 6 converted (h01 h04 h05 h07 h09 h10), 3 controls |
| a2 | **N0215** + **N0229** (reference full names in a formal's default value) | Surelog compiles a formal's default with the `io_decl` as parent and stores no full name, so ComputeFullName runs through the formal: `uvm_pkg::uvm_report::verbosity::severity` | law `formalDefaultNamedThroughFormal191`, `R11U191_REFFULL_OFF`, B (TaskFuncEmit: the call site hands the scope) | BuildUVMPkg d/t `fullname(20) -> line(11)`; N0215 / N0229 0 left in BuildUVMPkg, SimpleUVM, Scoreboard | F: 6 converted |
| b1 | **N1082** (Earlgrey_0_1's first record, `flash_phy_pkg.sv` 43) | a folded package-parameter initializer is located at its LEADING LEAF: a constant-condition ternary reduces the taken branch only, a binary operation sits at its first operand | law `pkgFoldAtLeadingLeaf191`, `R11U191_EARLCOL_OFF`, A (ParamEmit) | Earlgrey_0_1 d/t `col(102) -> fullname(101)` | E: e01 converted |
| b2 | **N0923** (BlackBePipeInt's first record, 49 records) | golden holds a per-use COPY of the parenthesized-cast width typespec; ours shares one object whose `Cast_to_expr` ref law parenCastWidthRefModuleCopy binds to the module copy | **no law** (identity family: needs per-use copies) | – | B/b01 |
| c1 | **const_cast_signext** `type(1)` (N0133 + N0487) | `ExprEval::evalFunc` cannot reduce a body with a cast to a logic / reg / byte / packed-aggregate target (the `vpiCastOp` branch folds int, longint, shortint, bit, integer size casts and enums only) nor a packed-struct member read of a formal (non-pattern actual), a local or a module parameter; the call is kept | law `evalFuncCastMemberKeepsCall191`, `R11U191_CONSTCALL_OFF`, B (ModuleEmit, the fold decision of emitContAssigns) | **const_cast_signext d/t CONVERT** (STRICT_NOTEQUAL `type(1)` -> CMP_EQUAL), downstream IDENTICAL | C: fold/keep decisions match golden on 18 calls |
| c2 | **Scr1SvTests** `type(1)` (N0965) | evalFunc binds every actual (stamping the formal's typespec on what `reduceExpr` returns) then executes the body: an unreducible part-select actual is the SOURCE object, mutated; a non-constant call runs to its first inner call only | law `evalFuncExecCallArgTs191`, `R11U191_EVALTS_OFF`, A (ExprEmit) | Scr1SvTests d/t `type(1) -> endcol(29)` (the structural head gone) | V: 3 converted; probe r10fiot_repro/a9 converts |
| d | pass 186's **P-case** face | writeCont_assign's `adjustSize(<LHS typespec>, c, uniquify)` sizes the elaborated constant to the LHS: UINT cloned and sized (grow or shrink), BIN truncated if wider, HEX / OCT / INT sized IN PLACE on the shared definition constant (last instance wins) | law `elabCaConstLhsSized191`, `R11U191_UNSIZEDPKG_OFF`, B (ModuleEmit emitContAssigns: the fold is built there, not in ExprEmit) | none (the face is judge-unequal: no corpus row carries it) | U: 12 converted from NOT_EQUAL |
| e | TypeParameterAsPortTypeWithEnum (+OfParametrizedWidth) | already closed by pass 184 (law tpEnumCopyAtTypedef184: both rows CMP_EQUAL at the base; Y/y01 STRICT_EQUAL, `R11U184_TPENUM_OFF=1` reproduces the face) | no law needed | – | Y/y01 |
| f | the UVM **value coin** (r11u190 N9) | the queue typedef's return twin was built by `buildUnpackedArrayTypedefTs`, which reads its alias through `as<FixedSizeUnpackedArrayType>()` — a QueueType's padding bytes | law `queueRetTwinDynShape191`, `R11U191_QUEUERANGE_OFF`, B (TaskFuncEmit) — a defect fix | none judged (the twin is outside both comparators); MiniAmiq / SeqDriver both modes: 3 of 3 concurrent runs one md5 (pristine 3 distinct) | Q: q01 q05 move, q02-q04 controls |
| g1 | r11u190 **N1**: enum parent left at an instance | writeModule / writeInterface write the shared enum's parent from the DEFINITION | law `enumDefOwnerNotInstance191`, `R11U191_ENUMPARENT_OFF`, B (ModuleEmit drain) | bytes only (vpiParent): fires on 115 of the 123 corpus movers (104 move by it alone), 0 strict cell or RTLIL byte moves | N: 5 cases to 0 order-blind lines |
| g2 | r11u190 **N2**: header typedef, both definitions write | Surelog moves each DesignComponent's own TypeDef object: the key is (declaration, definition) | law `modAggClonePerDefKey191`, `R11U191_HDRTD_OFF`, B (TypeEmit drain) | none in the corpora | G/g01 converted |
| g3 | r11u190 **N5**: split port redeclared `real` | the port declaration keeps its implicit logic_typespec (the floating twin of law splitPortIntRedeclLogicTs180) | law `splitPortRealRedeclLogicTs191`, `R11U191_REALPORT_OFF`, B (TypeEmit makeTypespec) | none in the corpora | R: r01 r03 converted, r04 control |

Totals (the full gate sweep of both patches, section 4): **surelog regressions=0 conversions=0 changes=13; uhdm2rtlil
regressions=0 conversions=2 (const_cast_signext d/t) changes=0; probe regressions=0 conversions=2 (r10fiot_repro/a9,
v11u114repro/grid/set3/g13) changes=2; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the
csv byte-identical to the pristine sweep's**; 123 of 2560 corpus databases move, every one predicted by name before
the sweep; grid 31 of 69 cases converted, 0 regressed, `R11U191_OFF=1` byte-identical to pristine on all 69.

## 1. Switches (every law droppable alone; one switch for the whole pass)

| switch | law | file (ground) | cluster |
|---|---|---|---|
| `R11U191_HPENDCOL_OFF` | idxCallPathAtDots191 | ExprEmit.cpp (A) | N0228 + N0224 |
| `R11U191_EVALTS_OFF` | evalFuncExecCallArgTs191 | ExprEmit.cpp (A) | N0965 (Scr1SvTests) |
| `R11U191_EARLCOL_OFF` | pkgFoldAtLeadingLeaf191 | ParamEmit.cpp (A) | N1082 (Earlgrey_0_1) |
| `R11U191_REFFULL_OFF` | formalDefaultNamedThroughFormal191 | TaskFuncEmit.cpp (B) | N0215 + N0229 |
| `R11U191_QUEUERANGE_OFF` | queueRetTwinDynShape191 | TaskFuncEmit.cpp (B) | the UVM value coin |
| `R11U191_UNSIZEDPKG_OFF` | elabCaConstLhsSized191 | ModuleEmit.cpp (B) | pass 186's P cases |
| `R11U191_CONSTCALL_OFF` | evalFuncCastMemberKeepsCall191 | ModuleEmit.cpp (B) | const_cast_signext (N0133 + N0487) |
| `R11U191_ENUMPARENT_OFF` | enumDefOwnerNotInstance191 | ModuleEmit.cpp (B) | r11u190 N1 |
| `R11U191_HDRTD_OFF` | modAggClonePerDefKey191 | TypeEmit.cpp (B) | r11u190 N2 |
| `R11U191_REALPORT_OFF` | splitPortRealRedeclLogicTs191 | TypeEmit.cpp (B) | r11u190 N5 |
| `R11U191_OFF` | all of them | | |

`R11U191_BBPI_OFF` and `R11U191_TPENUMLOC_OFF` name no law (b2: an identity family; e: closed by pass 184).
`R11U191_TRACE=<dir>` writes one file per process (`<pid>.<unit>`: first line the `-o` database, then one law name per
firing): the census below. `R11U191_OFF=1` on the law binary writes the pristine bytes on all 69 grid cases
([evidence/grid/grid.tsv](evidence/grid/grid.tsv), last column).

## 2. Binaries (frozen `chmod 555` in `/tmp/r11u191_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `5e6e8c2d6edf06661ab60336dad2f0cf` | worktree `/tmp/wt_r11u191` at `a1c89c1a`, system-deps config, `-j 2`: byte-identical to the main tree's `build/slang-uhdm` |
| `slang-uhdm.law` | `4bd52735e9e8a74f5281db85f1032ee4` | `a1c89c1a` + both patches |
| `slang-uhdm.lawA` | `52abe7e8aecdba537638b15ec9bfe102` | `a1c89c1a` + law_exprstmt.patch alone |
| `slang-uhdm.lawB` | `f6c03876217b592453f90c95968159ed` | `a1c89c1a` + law_typeemit.patch alone |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` (not edited: no comparator defect was found) |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | `drivers/strictcmp_x.cpp` built by `drivers/cc.sh` (maps 7-10's variant, the record dumps) |

The pristine reference is this pass's own sweep `/tmp/r11u191_swP` of the pristine binary: its three stage csvs equal
the committed baselines (probe.csv byte-identical to `results/golden_probe.csv`; surelog and uhdm2rtlil
`regressions=0 conversions=0 changes=0`; downstream 803 / 66 / 2 / 0), 3273 of 3323 `cmds.txt` name
`/tmp/r11u191_bin/slang-uhdm` and the other 50 are SURELOG_FAIL rows with no slang line. Both sweeps exit 1 for one
reason only, `law index STALE: tests/LAWS.md`, which the main tree at `a1c89c1a` reads too
(`python3 scripts/law_index.py --check`, rc 1, measured in the main tree).

## 3. The questions, per cluster family

Heads at `a1c89c1a`: `drivers/jobs.py` over the pass-187 landing sweep (`/tmp/intr11u187`, read-only; its csvs are the
committed baselines) lists 68 STRICT_NOTEQUAL row-modes, `strictcmp_x --max 50 --dump-a --dump-b` on each, map 10's
analyzer (`drivers/analyze.py`, unchanged) and `drivers/first10.py` (each row's first differing records with map 10's
cluster id via `common.rekey` + `r11u189map/cluster_index.csv`): [evidence/heads/](evidence/heads/). The
`/tmp/strict_sweep` the brief names is from 2026-09-24 (MiniAmiq `line(145)`), not `a1c89c1a`; it was not used.

### 3a1. N0228 + N0224 — a method-call path in a constant-grammar select index (law idxCallPathAtDots191)

**Heads.** The first open records of the UVM rows after pass 186 are the pair at uvm_factory.svh 911
`m_inst_override_queues[obj].queue = m_inst_override_name_queues[obj.get_type_name()].queue;`:

    #3490 span hier_path 'obj.get_type_name'  golden 911:72-911:75  ours 911:72-911:91   (N0228)
    #3491 span ref_obj   'obj'                golden 911:75-911:75  ours 911:72-911:75   (N0224)

(MiniAmiq; SeqDriver #3473/#3474; the other shapes: `m_children[child.get_name()]`, `m_streams[stream.get_name()]
.exists`, `m_regs_info[f.get_parent()].offset`.) N0228 counts 9-25 records per UVM row, N0224 9-31
([evidence/uvm/cluster_counts.tsv](evidence/uvm/cluster_counts.tsv)).

**Decode.** Surelog's `-d ast` of the case (cases/H/h03) reads the index of `m[obj.nxt.get_type_name()].queue` as

    Constant_expression > Constant_primary > Subroutine_call(obj l<10:11> el<10:14>,
        Constant_bit_select l<10:14> el<10:14>, nxt, Constant_bit_select l<10:18> el<10:18>, get_type_name, List_of_arguments)

and the same index of a plain `q = m[obj.get_type_name()]` as `Select > Bit_select > Expression > Complex_func_call(obj,
get_type_name, …)` with no empty selects. The SV grammar's hierarchical identifier is `{ identifier
constant_bit_select . } identifier`, and a range select's `part_select_range` is a `constant_range` (an indexed range's
width a constant expression): the index there is a constant_expression, and a method call in it is a `Subroutine_call`
whose names are separated by EMPTY `Constant_bit_select` nodes located zero-width at the dots. `compileExpression`'s
`paSubroutine_call` branch (CompileExpression.cpp:3208, `Select` is a `paConstant_bit_select`) calls
`compileExpression(obj)` -> `compileComplexFuncCall` (CompileExpression.cpp:5062); its hier-path loop pushes a
component's `ref_obj` when it meets the NEXT name and locates it with `fC->populateCoreMembers(name, name, ref)` — and
`name` has already been advanced to the previous node, the empty select (`name = dotedName;`, :5715). So every
component but the call sits at `(dot, dot)`; the method call keeps its name token; the hier_path takes the location
of the Subroutine_call's first child (the first name).

**Law** (ExprEmit, a wrapper at the top of `emitExpr`): a user `Call` whose syntax is an `InvocationExpression`
standing (through operators only) in (a) the index of a select that a `.` continues (slang: an `IdentifierSelectName`
on the left of a `ScopedName` with a `.` separator, or an `ElementSelectExpression` on a `MemberAccessExpression`'s
left) or (b) a `SimpleRangeSelect` bound or an indexed range's width is emitted as before; when the result is a
`hier_path` of `ref_obj` components ending in a `method_func_call`, the path's span becomes its first component's, and
each non-last component is re-located zero-width at the dot after it (from the syntax's separators). Anything else
declines (another call, a member access or a select between the call and the select; a select component in the
receiver; a `this` receiver).

**Grid** (cases/H, 11 cases): h01 (lvalue-continued rvalue), h04 (module task), h05 (on the left of `=`), h07 (an
`if` condition, a `$sformatf` argument, `.get_v()` continuing), h09 (`q[q.size() - 1].get_st()`, nested in an operation:
svaunit_concurrent_assertion_info.svh 133), h10 (`q[b:q.size()-1]` and `q[b+:q.size()]`: uvm_sequencer_base.svh 694)
convert to STRICT_EQUAL; controls h02 / h08 (plain select, call argument, literal index: pristine face `bit_select`
endcol unchanged) and h11 (an indexed range's BASE, a call inside another call's argument: EQUAL both) do not move;
h03 moves `endcol(7) -> col(2)` (its property path `m[obj.nm].queue` is the residue below), h06 `endcol(3) -> col(1)`.

**Rows.** N0228 0 left in every UVM row (was 9-25), N0224 3-6 left (was 9-31)
([evidence/uvm/cluster_counts.tsv](evidence/uvm/cluster_counts.tsv)). Strict cells: MiniAmiq d/t `file(27) -> file(25)`,
SeqDriver d/t `file(26) -> file(24)`, SimpleUVM d/t and Scoreboard d `fullname(54) -> fullname(52)`; order-blind
distance section 6.

**Left, and why.** (1) A PROPERTY path in such an index (`m[obj.nm].queue`, h03 line 9): golden locates `obj` at
`nm`'s span (15-17) and stores no full name on `nm` (it parses `Constant_primary(obj, Constant_select(nm,
Constant_bit_select))`, another branch of the same loop); not modelled. (2) The method-call name after a spaced dot
(`obj . get_type_name()`, h06): ours computes the name span as `receiver end + 1` (ExprEmit's receiver-call builders)
where golden reads the token — a pre-existing arithmetic, not this law. (3) The residual N0224 records are `ref_obj`s
of paths in `with` clauses and svaunit clones (MiniAmiq 6). (4) h02 / h08: the PLAIN select `q = m[obj.f()]` reads
golden `bit_select` 8:11-8:30 (the index's span) where ours ends at the method name: another face.

### 3a2. N0215 + N0229 — names inside a formal's default value (law formalDefaultNamedThroughFormal191)

**Heads.** BuildUVMPkg's first nine records (uvm_globals.svh 144, `int verbosity = (severity ==
uvm_severity'(UVM_ERROR)) ? UVM_LOW : …`): `ref_obj severity` golden `uvm_pkg::uvm_report::verbosity::severity`, ours
`uvm_pkg::uvm_report::severity` (N0215); the cast's `ref_typespec` golden `uvm_pkg::uvm_report::verbosity`, ours
`uvm_pkg::uvm_report` (N0229).

**Decode.** `CompileHelper::compileTfPortList` compiles a formal's default with the `io_decl` as the parent and no
pexpr (the existing law formalDefaultBindsLikeBody13 header cites it), and stores no full name on what it builds, so
UHDM's generated `VpiFullName()` falls back to `BaseClass::ComputeFullName` (UHDM templates/BaseClass.cpp:100), which
walks the parent chain `ref_obj -> operation(s) -> io_decl -> function -> package`: the formal's name is a component
(package or class: `::`; a module: `.` — `work@top.f.b.a`). A reference that is the whole default (`int d = base`)
already read the chained name on the pristine binary (f02).

**Law** (TaskFuncEmit, both default-value sites: the defined subroutine's formals and the pure virtual prototype's):
the scope handed to `emitExpr` for a default value that is not a literal and not a lone name is `joinRef(<subroutine
full name>, <formal name>)` instead of the subroutine's full name. A literal or a lone name keeps the pristine scope
(the lone name already reads the chained name, and changing its scope only reorders the symbol table: r10buvm13 a7_dpi13
and r10uvm88 v88_b4_nonsub moved bytes with 0 order-blind lines in the first draft, section 7). **Ground note:** the
names are minted by ExprEmit, but the scope is chosen at the TaskFuncEmit call site, so the law is ground B.

**Grid** (cases/F, 8 cases): f01 (package function, the UVM shape with enum casts), f02 (class method and task,
in-body: the binding is withheld there, the names still chain), f03 (module function and task), f05 (`$bits(a) + 1`,
a concatenation of formals), f06 (package task with a ternary over an enum, an interface function), f07 (literal, lone
name and unary defaults: only the unary one moves) convert to STRICT_EQUAL; f04 (out-of-body class method under
`$unit`, pure virtual prototype) and f08 (enum cast of a class typedef) stay stage-1 NOT_EQUAL for other faces, and
every full name the law touches reads golden's (f04: `work@B::pv::b::a`, `work@C::pv::b::a`; f08
`work@C::m::z::a`, `work@C::m::z::B`).

**Rows.** BuildUVMPkg d/t `fullname(20) -> line(11)` (its whole first-nine-record family gone); N0215 / N0229 0 left in
BuildUVMPkg, SimpleUVM and Scoreboard; MiniAmiq 76 -> 27 and SeqDriver 74 -> 18 (N0215).

**Left, and why.** The MiniAmiq / SeqDriver remainder of N0215 are not formal defaults: `m_rows[i + 1].level` (the
index of a select inside a path is named through the path and the SELECT: `…::m_rows[i + 1].level::m_rows::i`), and
references inside `arr.find(item) with (…)` clauses named through the receiver (`…::arb_sequence_q::S`): both are
the parenting family below (section 8, R1).

### 3b1. N1082 — Earlgrey_0_1's first record (law pkgFoldAtLeadingLeaf191)

**Head.** `#26470 span constant '' golden 43:53-43:63 ours 43:28-43:63 < param_assign < package(flash_phy_pkg)`:
`parameter int WordSelW = WidthMultiple == 1 ? 1 : LsbAddrBit;`. The object family is the package DEFINITION listing's
param_assign constant (`design > allPackages`); its twin in the elaborated package listing already agreed with golden
(ParamEmit's existing taken-branch fold, law impCondFoldKeepsTs's note). Pass 180's claim holds: the 102 records at the
base are a subset of the old 436, and this is their first.

**Decode.** The package parameter is compiled with `Reduce::Yes`; `ExprEval::reduceExpr`'s `vpiConditionOp` branch
(UHDM templates/ExprEval.cpp) reduces the condition and then ONLY the taken operand, and the constant takes the
location of the node it was reduced from. The grid pins the location rule on golden: the taken branch's LEADING LEAF — a
reference (`L` 5:34-35), a literal (`7` 6:30-31), the first operand of a binary operation (`L + 1` -> `L` 7:34-35,
`2 * L` -> `2` 9:30-31), through nested ternaries (8:41-42) and parentheses (`(L)` -> `L`).

**Law** (ParamEmit, the generic param_assign tail, package scope only): a folded constant located at the whole
initializer (or at its parenthesized span) is re-located at the leading leaf of the chain (taken ternary branches, then
first operands of binary operations; parentheses stripped). A constant located anywhere else is left alone.

**Grid** (cases/E): e01 (package S / T / U) converts; e02 (module parameters: a separate `file` face, no move); e03
(stage 1 for a value face: golden `INT:4` / ours `UINT:4` on `2 * L`) has every ternary constant at golden's leaf;
`B = (L)` alone stays at 7:21-24 in ours (a parenthesized lone reference folds on another ParamEmit path).

**Rows.** Earlgrey_0_1 d/t `col(102) -> fullname(101)`: the head record gone; one N1082 record is left, the
elaborated MODULE copy of the same parameter (`#122230 param_assign < module_inst`), which the package-only law does
not claim. Earlgrey's remaining 101 records start at N0941 / N0061 (`reg2hw.key[i].q` bit_select names and spans,
ExprEmit, section 8).

### 3b2. N0923 — BlackBePipeInt's first record (no law)

**Head.** 49 records per mode, all `ref_obj 'dev_addr_width_gp'` under an `int_typespec` (the width expression of
`(dev_addr_width_gp)'('h0_c???)`, bp_common_addr_pkgdef.svh): golden reads NO full name and no `vpiActual` child in
the walk, ours `work@bp_be_pipe_int.dev_addr_width_gp.dev_addr_width_gp` with its actual the module's import copy of
the parameter.

**Decode.** Case B/b01 (golden dump): Surelog's `int_typespec` 3:3-3:36 exists once per USE (under the package
parameter, under each module copy `work@top.dev_addr_width_gp`, `work@top.dev_match_gp`, …), each with its own
`vpiExpr -> ref_obj` whose actual is the package parameter; ours shares ONE typespec object, and law parenCastWidthRef
ModuleCopy (ParamEmit `stampParenCastWidthTs` / `claimParenCastWidthOwner`) points its single ref at the importing
module's copy — right for the module's uses, wrong at the package's own. **Not landable here**: matching it needs a
per-use copy of the typespec (the identity family GOLDEN_EQUIVALENCE.md canonicalises), 49 records per mode, sites
`stampParenCastWidthTs` / `claimParenCastWidthOwner` (ParamEmit.cpp).

### 3c1. const_cast_signext `type(1)` — which constant calls a continuous assignment keeps (law evalFuncCastMemberKeepsCall191)

**Head.** `#602/-1 struct func_call 'sext' golden 2 objs` (and `sext`, `uext`, `szc`): golden keeps the four
`func_call`s in the elaborated cont_assigns where ours folds them.

**Decode.** The producer is the one law evalFuncSelectKeepsCall148 decoded (ModuleEmit): `UhdmWriter::writeCont_assign`
reduces a whole-RHS user call through `ExprEval::reduceExpr` -> `evalFunc`, and only a constant result replaces the
Rhs. Two more body shapes never reduce:

* **C, a cast.** ExprEval's `case vpiCastOp` folds a target typespec of kind int, long_int, bit, short_int,
  integer (the size cast `N'(…)`, also a constant-expression width) and enum; for any other typespec (a logic / reg
  typedef `imm_t'(…)`, byte, a packed struct or union) `result` stays null;
* **M, a member read** of a packed struct whose base is a formal bound to a non-pattern actual, a function local or a
  module parameter (the hier_path reduction never lands on a constant). A formal bound to a literal assignment
  pattern FOLDS (c03 `h1('{a:4'd1, b:4'd2})`), left alone.

Measured on golden, grid cases/C (18 calls): c01 `8'(x)` fold, `op.f` of a struct formal keep, `$signed(x)` fold,
`imm_t'(x)` keep, `x[7:0]` fold; c02 `int'` fold, `e_t'` (enum) fold, `b8_t'` (bit vector typedef) fold, `byte'`
keep, `l8_t'` (logic typedef) keep, `s_t'` (packed struct) keep, `integer'` fold; c03 member reads keep but the
literal-pattern actual; c04 a cast behind a branch not taken folds (the body is executed), a cast in an operation keeps.

**Law** (ModuleEmit, beside the 148 predicate, both sites: `emitContAssigns` and the generate-scope cont_assign
emitter): a straight-line callee body containing a C or M shape joins `evalKeep148` — every fold branch declines and the
definition cont_assign share takes the row (the existing path; GOLDEN WRITES NOTHING ON A MISS). A typedef name
written as the cast's left side parses as an expression in slang; it is a type cast when the name looks up to a type.

**Grid.** The fold/keep decision matches golden on all 18 calls (`drivers/rhskinds.py`); c01, c02, c04 stay stage-1
NOT_EQUAL for ExprEval VALUE faces of the folded calls (golden `$signed(12'h800)` folds to `UINT:0`; `int'(x)` gives
`UINT` where ours says `INT`), c03 moves `type(1) -> file(1)` (the literal-pattern fold's location: golden 9:32-36).

**Rows.** **const_cast_signext d/t CONVERT**:

    const_cast_signext,default,CMP_EQUAL,,,equal       (baseline STRICT_NOTEQUAL differ:type(1))
    const_cast_signext,testflags,CMP_EQUAL,,,equal     (baseline STRICT_NOTEQUAL differ:type(1))

downstream IDENTICAL (its RTLIL is byte-identical to the pristine lane's). The census names four more tests the
predicate fires on, both modes: ibex_pmp (8 firings) and rsp_gen_minimal move bytes but read 0 order-blind dump lines
against pristine (the enum-parent law's parent-only move of a top module, whose instance and definition print alike),
func_struct_repro, nested_cast_repro and union_param_repro do not move at all (their calls were already kept by an
earlier guard: fired, no byte).

### 3c2. Scr1SvTests `type(1)` — the formal typespec evalFunc stamps (law evalFuncExecCallArgTs191)

**Head.** `#16033 struct ref_typespec golden 5 objs < indexed_part_select(din) < func_call(scr1_search_one_2) <
assignment` (scr1_ipic.sv 116, inside `scr1_search_one_16`, called by `assign irr_priority = scr1_search_one_16(
irq_req_v);`).

**Decode.** `ExprEval::evalFunc` binds each actual: `if (expr* exparg = reduceExpr(ioexp, …)) {
exparg->Typespec(<new ref_typespec>)->Actual_typespec(<the formal's typespec>) }`, then executes the body. A call met
while executing is evaluated the same way. `reduceExpr` hands a formal or local REFERENCE back as its bound value, so
the stamp lands on the value (the source ref stays bare: r10fiot a9 x3 / x5); an unreducible PART SELECT or INDEXED
PART SELECT is handed back as ITSELF — the source object of the function body — and is mutated in place. With a
non-constant argument the first inner call's own body cannot reduce (`|d` on the unreduced select), evalFunc returns
invalid, and the outer run stops: only the FIRST call met is stamped (v01: `t = g(x[1:0])` stamped, `u = g(x[3:2])`
bare; v02 the Scr1 loop). With constant arguments the body completes and every call met is stamped (v03).

**Law** (ExprEmit, beside the existing formal-ts stamp condition `stampCond48`): for a MODULE function called as the
whole right side of a continuous assignment of its own module, the calls of its body's executed prefix are walked
with law evalReachedCallees's taint model (a controlling expression that reads a formal, an outside signal or a tainted
local stops the walk; plain statements and constant-bound for loops do not); non-constant arguments stamp the first
call met only, constant ones every call met. Only part-select and indexed-part-select actuals are stamped (the
measured kinds). Branches and other statements stop the walk (abstain).

**Grid** (cases/V): v01, v02, v04 (= tests/probe r10fiot_repro/a9, the purpose-built grid of that family: its
`lv[3:1]` after `lv[3:0] = a;` and `a[3:1]` are stamped, refs and the unfoldable-if branch are not) convert; v03 (all
constant) stamps both calls as golden and stays stage-1 for a value face (`UINT:1` vs `BIN:1`). The first draft of the
law stamped reference actuals and stopped at any non-call statement: the census caught three regressions
(const_fold_func d/t, r10uvm60 b6_reached, r10fiot a9 -> NOT_EQUAL) and the delivered law is the refined one (section
7).

**Rows.** Scr1SvTests d/t `type(1) -> endcol(29)`: the structural head is gone; the walk now runs on to map 10's
N0448 (`SCR1_SIM_PRINT_ADDR` range constant, TypeEmit) and N0040 (port logic_typespec ends); 29 records exposed.
Probe `r10fiot_repro/a9` converts (STRICT_NOTEQUAL `type(1)` -> EQUAL).

### 3d. Pass 186's P cases — the elaborated constant sized to the LHS (law elabCaConstLhsSized191)

**Face.** pass 186 R6 (P/p01-p03, p05-p08): golden's elaborated cont_assign constant has `vpiSize` 32 where ours has
the parameter's width; judge-UNEQUAL (uhdm-cmp reads vpiSize).

**Decode.** Not ExprEmit: the constant is built in ModuleEmit's `emitContAssigns` (typed-parameter fold, and the
shared definition constant of law pkgParamElabCaSharesDefFold183). Surelog: `UhdmWriter::writeCont_assign`
(UhdmWriter.cpp:2255-2280) reduces the Rhs and calls `CompileHelper::adjustSize(tps, …, c, /*uniquify=*/true)` with
`tps` the LHS variable's typespec (CompileHelper.cpp:4065-4247): `size = Bits(LHS)` for every const type but
`vpiDecConst`; UINT: cloned, masked, `VpiSize(size)` (grow or shrink); BIN: its own-typespec branch keeps
`min(orig, size)` and truncates the bits in place when wider; everything else (HEX, OCT, INT): `c->VpiSize(size)` IN
PLACE and NOT cloned. The object is the definition's reference constant (clone_tree keeps a sized constant), so the
definition view shows the resized object and, with two instances of different LHS width, the last one wins (u09).
The "32" of the brief is the `int` LHS of p01 / p06 / p08.

**Law** (ModuleEmit, the typed-parameter fold; only a plain variable LHS: a select's typespec is null and adjustSize
returns unchanged): the shared definition constant takes the LHS width in place (HEX / OCT / INT; BIN truncated when
wider, with golden's bare-bits decompile); a freshly built UINT / INT fold grows to the LHS width.

**Grid** (cases/U, 18 cases): u01 (HEX into 8 bits), u02 (into 64), u05 (BIN and unsized HEX into 16), u06 / u07
(module-local parameters), u09 (two instances, W=8 then W=32: 32), u10 (an uninstantiated reader: a top, sized),
u11 (BIN truncated to `0101`, OCT into `int`), p01, p03, p06, p08 convert from NOT_EQUAL; u03 / u04 controls stay
EQUAL; u08 (negative int: a param_assign operation face), p02 (`p::X` scoped: golden `INT:200` 32 from the package
Value, another compile path), p05 (range face), p07 (a computed default kept as an operation) stay NOT_EQUAL for
other faces. Downstream: every U case reads the same verdict pristine and law (IDENTICAL or EQUIVALENT; u08 DIVERGENT in both
states; [evidence/downstream/](evidence/downstream/)).

**Rows.** None (no corpus row carries the judge-unequal face).

### 3e. TypeParameterAsPortTypeWithEnum (+OfParametrizedWidth) — closed before this pass

Both rows are CMP_EQUAL at `a1c89c1a` in both modes (pass 184's law tpEnumCopyAtTypedef184, "the type-parameter enum
copy located at its typedef"). Case Y/y01 (pass 186's R1 reproduction) is STRICT_EQUAL on the pristine binary and reads
`file` with `R11U184_TPENUM_OFF=1` (golden `enum_typespec enum_foo_e 9:3-11:16`, ours unlocated): the face is held by
that law. No law here.

### 3f. The UVM value coin (law queueRetTwinDynShape191, a defect fix)

**Site.** TaskFuncEmit's unpacked-array typedef return branch (`retBase` an `array_typespec`) called
`buildUnpackedArrayTypedefTs(*retAlias, …, /*cloneForm=*/true)`, which reads `ta.targetType…as<Fixed
SizeUnpackedArrayType>()` — for `typedef TYPE types_t[$]` (uvm_misc.svh 642, `find_all`'s return) a `QueueType`:
`range.left` reads `maxBound`, `range.right` the four padding bytes after it. The two other callers
(UhdmExporter's class typedef listing, TypeEmit's module-body route) guard on `FixedSizeUnpackedArrayType`.

**Fix.** A non-fixed-size alias builds the twin with `buildDynContainerTypedefTs` — the listing's own shape (`UINT:0 ..
STRING:$` at the `$` token for a queue, `STRING:unsized` / `STRING:associative` markers) — then names it and links its
`Typedef_alias` as before.

**Measured** ([evidence/determinism/coin_miniamiq_seqdriver.txt](evidence/determinism/coin_miniamiq_seqdriver.txt),
`drivers/coin.sh`: three CONCURRENT runs per binary, the sweep's command line and cwd): pristine MiniAmiq d 3 distinct
md5s (right bound `UINT:1144` / `1257` / `1092`), MiniAmiq t 3 (`961` / `1307` / `1376`), SeqDriver d 2 (`0`, `978`, `0`),
SeqDriver t 3 (`589` / `910` / `0`); law **one md5 per row-mode, 3 of 3** (the twin's bound `STRING:$`). Neither
comparator reads the twin (no strict cell moves on it); the UVM rows' strict record count drops by 2 (the twin's
element typespec objects). Q cases: q01 / q05 (class queue typedefs) move bytes, q02-q04 (package dynamic array,
module associative array, fixed-size control) are byte-identical: those routes never reached this branch.

### 3g. The r11u190 new findings (ModuleEmit / TypeEmit, ground B)

* **N1 (law enumDefOwnerNotInstance191, `R11U191_ENUMPARENT_OFF`).** law enumImpDefOwner180v's drain kept a parent
  "already of the winning definition" and skipped an object whose parent IS the winner's recorded owner — when the
  winner is also the last definition emitted, that owner is its ELABORATED instance (the instance's
  emitImportArtifacts records the last write). The law hands any instance of the winning definition to the
  definition's own object (design AllModules / AllInterfaces). vpiParent only. Cases N (copies of r11u190 E/e01,
  e03, e04, e06, e07, e08, e12): order-blind dump distance to golden 2 / 2 / 2 / 4 / 2 -> 0 on e03, e06, e07, e08,
  e12, e04 31 -> 29, e01 0 -> 0 ([evidence/grid/orderblind_N_G_Q.tsv](evidence/grid/orderblind_N_G_Q.tsv)). Corpus:
  the widest-firing law (it fires on 115 of the 123 corpus movers, 104 of them move by it alone: every ibex / rp32 u2r row, BlackBePipeInt, the UVM rows, …), none of them
  on a strict cell or an RTLIL byte.
* **N2 (law modAggClonePerDefKey191, `R11U191_HDRTD_OFF`).** law modAggCloneOwnDefOnly180v declines a move whose
  declaration key holds two declarations. Golden (r11u190 G/g01): each definition's clones take THAT definition's
  formal span (Surelog moves each DesignComponent's own TypeDef object and clones per definition). The law keys the
  move on (declaration, definition): the clones whose parent chain reaches an instance of the listing's definition;
  unknown owners keep the decline. G/g01 converts (order-blind 86 -> 0). No corpus row fires.
* **N5 (law splitPortRealRedeclLogicTs191, `R11U191_REALPORT_OFF`).** A data-typeless split port redeclared `real` /
  `shortreal` / `realtime`: the port keeps its implicit `logic_typespec` at the declarator (law splitPortIntRedecl
  LogicTs180's rule, which sat after the floating-type return in `makeTypespec`). R/r01 (r11u190's case) and r03
  convert; r04 (a ranged split port) control; r02 stays NOT_EQUAL (golden types a `realtime` variable `time_var`).
  Downstream: r01 stays DIVERGENT in both states (r11u190 measured it DIVERGENT in every state; not decoded further).

## 4. The gate sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs)

`/tmp/r11u191_swP` (pristine) and `/tmp/r11u191_swL` (both patches), each with `SLANG_UHDM` exported; every
`cmds.txt` audited by binary path: 3273 of 3273 slang lines name `/tmp/r11u191_bin/slang-uhdm` resp.
`/tmp/r11u191_bin/slang-uhdm.law` ([evidence/sweeps/](evidence/sweeps/)). Baselines: the worktree's `results/` at
`a1c89c1a`.

| gate | pristine `5e6e8c2d6edf` | law `cc4a7d347228` |
|---|---|---|
| (1) build | = the main tree's build | `a1c89c1a` + both patches; lawA / lawB each alone (section 2) |
| (2) probe vs golden_probe.csv | EQUAL 3039 / STRICT_NOTEQUAL 1048; probe.csv byte-identical to the baseline | EQUAL **3041** / 1046: `regressions=0 conversions=2 changes=2` |
| (3) surelog vs golden_surelog.csv | `regressions=0 conversions=0 changes=0` (480/3 + 474/3 judge-equal) | `regressions=0 conversions=0 changes=13`; judge-equal histograms unchanged |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `regressions=0 conversions=0 changes=0` (803/1/67) | `regressions=0` **`conversions=2`** `changes=0` |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; `downstream.csv` byte-identical to the pristine sweep's; 35 downstream databases move, 0 of their RTLIL / netlist files change ([evidence/downstream/downstream_db_movers.txt](evidence/downstream/downstream_db_movers.txt)) |
| (5) uhdm-cmp | – | every corpus row keeps its judge status (the fresh csvs hold the baseline CMP_NOTEQUAL rows only); every probe case uhdm-cmp EQUAL (the csv holds EQUAL / STRICT_NOTEQUAL only) |
| (6) byteverify (SELFCHECK=1, fence-free mirrors) | | **123 / 2560 movers, every one PREDICTED by name** by the firing census run before the law sweep ([evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt), frozen `chmod 444`): 0 moved-not-predicted, 8 predicted-not-moved; SELFCHECK 2559 / 2560 flagged |
| canaries ([evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)) | surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS | surelog ok=41 changed=11 (exactly the 11 canary rows among the 13 changes: all but MiniAmiq d/t); uhdm2rtlil ok=16 changed=0; ctcan2 PASS both |

Both sweeps exit 1 for the stale law index alone (section 2).

**The conversions** (fresh rows, NOT written to results/):

    const_cast_signext,default,CMP_EQUAL,,,equal          was STRICT_NOTEQUAL differ:type(1)
    const_cast_signext,testflags,CMP_EQUAL,,,equal        was STRICT_NOTEQUAL differ:type(1)
    probe r10fiot_repro/a9                 EQUAL          was STRICT_NOTEQUAL differ:type(1)   (law evalFuncExecCallArgTs191)
    probe v11u114repro/grid/set3/g13       EQUAL          was STRICT_NOTEQUAL differ:type(1)   (law evalFuncCastMemberKeepsCall191)

**The changes** (every row stays judge-equal; the first field moves off the head this pass works, or the count falls):

    BuildUVMPkg d/t    differ:fullname(20) -> differ:line(11)       law formalDefaultNamedThroughFormal191 (lawB alone: the same)
    Earlgrey_0_1 d/t   differ:col(102)     -> differ:fullname(101)  law pkgFoldAtLeadingLeaf191 (lawA alone: the same)
    MiniAmiq d/t       differ:file(27)     -> differ:file(25)       law idxCallPathAtDots191 (lawA alone: the same)
    SeqDriver d/t      differ:file(26)     -> differ:file(24)       law idxCallPathAtDots191
    SimpleUVM d/t      differ:fullname(54) -> differ:fullname(52)   law idxCallPathAtDots191
    Scoreboard d       differ:fullname(54) -> differ:fullname(52)   law idxCallPathAtDots191
    Scr1SvTests d/t    differ:type(1)      -> differ:endcol(29)     law evalFuncExecCallArgTs191 (lawA alone: the same)
    probe r10vbuvm29repro/gv29_b_positions   differ:fullname(3) -> differ:fullname(1)   law formalDefaultNamedThroughFormal191
    probe r11u108repro/grid/f4/c12_const_fold differ:file(5)    -> differ:file(4)       law evalFuncCastMemberKeepsCall191

**The movers and the prediction** ([evidence/sweeps/prediction_check.txt](evidence/sweeps/prediction_check.txt)). The
census (`drivers/census.sh`: the law binary over every corpus row-mode but the fenced four, `--filter` from the fence,
and every probe case, `R11U191_TRACE`; summarised by `drivers/censum.py`) names 131 corpus row-modes; 123 move. The 8
that fire and do not move: EnumInPackage d/t (law enumDefOwnerNotInstance191 fires, a later drain writes the same
parent), func_struct_repro, nested_cast_repro, union_param_repro d/t (law evalFuncCastMemberKeepsCall191 fires on
calls an earlier guard already kept). Per law, rows moved where it fired: enumDefOwnerNotInstance191 115 (104 by it
alone: every ibex / rp32 / ParameterPassed* u2r row, BlackBePipeInt, the UVM rows …, all 0 strict and 0 RTLIL
change), formalDefaultNamedThroughFormal191 9, idxCallPathAtDots191 9, queueRetTwinDynShape191 9,
evalFuncCastMemberKeepsCall191 6, evalFuncExecCallArgTs191 4, pkgFoldAtLeadingLeaf191 2. Probe databases: 204 of
4087 move, 226 predicted, 0 moved-not-predicted (22 fire without moving: 16 cast-keep firings on calls an earlier guard
kept, 6 enum-parent firings).

**The one switch.** `R11U191_OFF=1` on the law binary: byte-identical to pristine on all 69 grid cases, and on the
125 corpus row-modes of the 61 moving tests ([evidence/sweeps/off_switch_moved_rows.txt](evidence/sweeps/off_switch_moved_rows.txt)):
119 byte-identical, 6 differ in bytes with 0 order-blind dump lines each — MiniAmiq d/t, SeqDriver d/t, SimpleUVM d,
Scoreboard d, the known coin rows of the pristine binary itself (map 10 section 2; the value coin this pass closes is
still live with the switch off).

## 5. Per patch, and the composition

`drivers/attribution.sh` (each single-patch binary: the probe stage in full, the corpus stages filtered to the 61
tests the census names; [evidence/sweeps/attribution_lawA.txt](evidence/sweeps/attribution_lawA.txt),
[attribution_lawB.txt](evidence/sweeps/attribution_lawB.txt)):

| stage | law_exprstmt alone (lawA) | law_typeemit alone (lawB) | both (law) |
|---|---|---|---|
| probe | 1 conversion (a9), 0 changes, 0 regressions | 1 conversion (g13), 2 changes, 0 regressions | 2 / 2 / 0 |
| surelog | 11 changes (Earlgrey d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d, Scr1SvTests d/t), 0 regressions | 2 changes (BuildUVMPkg d/t), 0 regressions | 13 / 0 |
| uhdm2rtlil | 0 changes | 2 conversions (const_cast_signext d/t) | 2 / 0 |
| grid (69 cases) | 10 converted (E/e01, H ×6, V ×3) | 21 converted (F ×6, G, R ×2, U ×12) | 31 converted, 0 regressed |
| UVM order-blind distance | section 6 | section 6 | section 6 |

The two patches touch disjoint laws and disjoint files; every measure of the pair equals the sum of the parts (no
row, case or distance reads an interaction). Both apply clean on `a1c89c1a` and also — textually, measured with
`git apply --check` only — on `6ab9f4fb7` (pass 188, which landed while this pass ran; the composition with it is not
measured here).

## 6. The UVM rows: order-blind distance and the family census

[evidence/uvm/uvmdist.tsv](evidence/uvm/uvmdist.tsv) (`drivers/uvmdist.sh`, from r11u189map):

| row | pristine | law_exprstmt alone | law_typeemit alone | both | delta |
|---|---|---|---|---|---|
| MiniAmiq d / t | 16749 | 16641 | 16621 | 16513 | −236 |
| SeqDriver d / t | 13139 | 13015 | 12993 | 12869 | −270 |
| SimpleUVM d / t | 5748 | 5664 | 5638 | 5554 | −194 |
| Scoreboard d | 4563 | 4499 | 4471 | 4407 | −156 |
| BuildUVMPkg d / t | 2787 | 2751 | 2715 | 2679 | −108 |
| SVSwitch d / t | 102 | 102 | 102 | 102 | 0 |

Every row falls, additively. The family census (`drivers/uvmfam.sh` = r11u175's uvmcensus.py + uvmfamilies.py with
map 8's key table, over the five rows' default databases; [evidence/uvm/families_pristine.txt](evidence/uvm/families_pristine.txt),
[families_law.txt](evidence/uvm/families_law.txt)): 30724 -> 29634 objects; F5 reference full names 10231 -> 9544, F7
expression spans 1399 -> 1182, F6 file facets 3105 -> 2945, F9 292 -> 283, F2 11870 -> 11862, F4 2403 -> 2394 (the
analyzer's alignment shifts with the walk; the order-blind distance above is the robust measure). Targeted clusters
([evidence/uvm/cluster_counts.tsv](evidence/uvm/cluster_counts.tsv)): N0228 and N0224 0 in every UVM row (were
9-25 / 9-31), N0215 and N0229 0 in BuildUVMPkg, SimpleUVM, Scoreboard (MiniAmiq N0215 76 -> 27, SeqDriver 74 -> 18),
N1082 2 -> 1 (Earlgrey), N0965 2 -> 0 (Scr1SvTests), N0923 49 -> 49 (BlackBePipeInt, no law).

**New first records** ([evidence/heads/first10_uvm_law.txt](evidence/heads/first10_uvm_law.txt),
[first10_other_law.txt](evidence/heads/first10_other_law.txt)): MiniAmiq N0144 (`uvm_severity` enum file) then N0327
(ground B, unchanged); SeqDriver N0327; SimpleUVM / Scoreboard N0682 (`UVM_MACRO_*` ref_typespec names, ground A);
BuildUVMPkg N0039 (`uvm_action` int_typespec span) then N0189, N0217; Earlgrey_0_1 N0941 + N0061 (`reg2hw.key[i].q`
bit_select name and span); Scr1SvTests N0448 then N0040; BlackBePipeInt N0923.

## 7. Refinement history (why the delivered laws differ from their first drafts)

* **law evalFuncExecCallArgTs191**: the first draft stamped every reference-kind actual (refArg) of the first call and
  stopped at any statement that was not a call. The census (before any gate sweep) read three regressions:
  uhdm2rtlil const_fold_func d/t CMP_EQUAL -> CMP_NOTEQUAL (`help = flip(inp)`: a formal REFERENCE actual reduces to
  its value, the source ref stays bare), probe r10uvm60repro/b6_reached EQUAL -> NOT_EQUAL (`return r5_inner(x)`, the
  same), probe r10fiot_repro/a9 STRICT_NOTEQUAL -> NOT_EQUAL. a9 is r10fiot's purpose-built grid of exactly this
  family: its golden stamps `lv[3:1]` after `lv[3:0] = a;` (the run does not stop at a plain statement) and never a
  reference. The delivered law stamps part / indexed-part selects only and walks with law evalReachedCallees's taint
  model; a9 converts.
* **law idxCallPathAtDots191**: the first draft claimed only a call that IS the whole index of a continued select;
  the law census left N0224 at 3-6 per UVM row (`sva_details[sva_details.size() - 1].get_…`, `q[b:q.size()-1]`). The
  delivered law climbs the index's operators and claims range bounds (constant_range) and indexed-range widths; h09,
  h10 convert, h11 (an indexed range's base, a call inside another call's argument) stays a control.
* **law formalDefaultNamedThroughFormal191**: the first draft handed the formal's scope to every default value; the
  probe byte comparison read two databases moving with no law traced and 0 order-blind lines (r10buvm13 a7_dpi13 `b
  = a`, r10uvm88 v88_b4_nonsub `a = n4`: lone-name defaults whose chained name is unchanged, only the symbol table
  order). The delivered law leaves literal and lone-name defaults on the pristine scope, and the probe prediction is
  exact.

## 8. Ranked residues (what is left, and why)

1. **R1 — reference names through a method-call path and through an index's select** (F5, the largest open family on
   the UVM rows: N0175 1060 objects, N0217, N0220, N0192, N0196, N0199, N0183): golden `…::args[i].substr::i`,
   `…::m_rows[i + 1].level::m_rows::i`, `…::c.f::i` (grid cases/M m01: `c.f(n, i + 1)` names `i` through `c.f`, the
   direct argument `n` already agrees). Golden stores no full name on these; UHDM ComputeFullName derives them from
   the PARENT chain, and golden's chain differs from ours (the index's `bit_select` parented at the enclosing
   expression, not at the inner path). A parenting law on ExprEmit's receiver-call and mixed-path builders, with
   law trailIdxNestedNames187's rename walk as the model; not attempted here.
2. **R2 — BlackBePipeInt N0923** (49 records per mode): per-use typespec copies of the parenthesized cast width
   (section 3b2); identity family.
3. **R3 — the property path in a constant-grammar index** (`m[obj.nm].queue`, h03): golden locates `obj` at `nm`'s
   span and stores no name on `nm`.
4. **R4 — ExprEval value faces of folded calls and parameters** (c01, c02, c04, e03, v03): golden folds
   `$signed(12'h800)` to `UINT:0`, `int'(x)` to `UINT`, `2 * L` to `INT` — stage-1 faces of ExprEval's arithmetic, not
   of the fold decision this pass transcribes.
5. **R5 — Earlgrey's remaining N1082 record**: the elaborated MODULE copy of the same parameter (`param_assign <
   module_inst`), which the package-only law does not claim; and `(L)` alone (e03 B) folds on another ParamEmit path.
6. **R6 — pass 186's P cases left**: p02 (`p::X` read through the package Value: golden `INT:200` size 32), p05, p07,
   u08 (a negative int: a param_assign face).
7. **R7 — the method name after a spaced dot** (`obj . f()`, h06): ExprEmit computes the name span as `receiver end + 1`.
8. **R8 — `realtime` redeclaration** (r02): golden types the variable `time_var`.
9. **R9 — the plain select of a method-call index** (`q = m[obj.f()]`, h02 / h08): golden's `bit_select` spans the
   index expression (8:11-8:30).

## 9. Files

- [law_exprstmt.patch](law_exprstmt.patch) (ExprEmit.cpp, ParamEmit.cpp), [law_typeemit.patch](law_typeemit.patch)
  (TaskFuncEmit.cpp, ModuleEmit.cpp, TypeEmit.cpp): git diffs of `src/` vs `a1c89c1a`.
- `cases/<letter>/<case>/dut.sv` (69 cases; `args` / `files` list several root files; the copies of earlier passes'
  cases keep their first line with `law` in place of the section sign): B (N0923), C (const calls), E (N1082), F
  (N0215 / N0229), G (r11u190 N2), H (N0228 / N0224), M (residue R1), N (r11u190 N1), Q (the queue twin), R (r11u190
  N5), U (pass 186's P face), V (N0965), Y (e).
- `drivers/`: `env.sh` (pins, `$FENCED`, fail closed), `case.sh` (one case the way check_probe does, goldens cached
  per content md5), `grid.sh` (+ `OFFCHECK=1`), `obcase.sh` (order-blind distance of a case), `census.sh` +
  `censum.py` (the prediction), `jobs.py`, `analyze.py`, `common.py`, `strictcmp_x.cpp` + `cc.sh` (map 10's), `first10.py`,
  `clcount.py`, `uvmfam.sh` (+ r11u175's uvmcensus.py / uvmfamilies.py), `uvmdist.sh`, `bvmirror.sh`,
  `attribution.sh`, `coin.sh`, `dscase.py` (the gate's own `one()` on cases), `carhs.py`, `rhskinds.py`.
- `evidence/`: `census/predicted_movers.txt` (frozen), `sweeps/` (both sweeps' summaries, byteverify, the
  prediction check, canaries, the per-patch attribution, the OFF check), `grid/` (the grid, the order-blind table),
  `heads/` (first records before and after), `uvm/` (distances, families, cluster counts), `downstream/` (cases pristine
  vs law: 41 of 41 the same verdict; the downstream database movers), `determinism/` (the coin).
