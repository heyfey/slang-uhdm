# r11u200dec: map 11's ground-B heads and families decoded and scratch-verified (analyst pass, measurement only)

**Base.** `a015c911` (branch matrix-1.87, the r11u199 verification). Every measurement here is at `a015c911`. Pass
198 (pair A, `cffb131f`: `src/ExprEmit.cpp` and `src/EmitHelpers.h` only; ibex_pmp d/t converted, arb_idx_cast d/t
`endcol(17)` -> `endcol(3)`) landed while this pass was finishing, after the law sweep; r11u196 (pair B) had not landed
at the end. No ground-B file moved, so law_typeemit.patch needs no rebase; both law patches and this directory's patch
still apply clean on `cffb131f` (`git apply --check`, measured), but the composition of law_exprstmt.patch with pass
198's ExprEmit laws is NOT measured here: the pair that lands it re-runs the gates on its HEAD. Nothing under `src/`,
`scripts/`, `results/`, `tests/` or `third_party/` is edited by this directory. The laws are delivered as two patch
files for the pairs to land:

* [law_typeemit.patch](law_typeemit.patch): ground B (`src/TypeEmit.cpp`, `src/TaskFuncEmit.cpp`,
  `src/ModuleEmit.cpp`, `src/UhdmExporter.cpp`), nine laws and the ground-B halves of two more;
* [law_exprstmt.patch](law_exprstmt.patch): ground A (`src/ExprEmit.cpp`, `src/ParamEmit.cpp`), the ground-A
  halves the joint rows needed: one law and the ground-A halves of two more.

Each patch applies clean on a fresh `a015c911` alone and both apply together (`git apply --check`, section 9). Each
builds alone: ground A carries its own copy of the switch helper, so neither patch needs the other to link. Law
names are written `law <name>` in this README so `scripts/law_index.py` does not read this directory as a pass; the
patches carry the section-sign names the landing needs.

**The map this pass works.** [r11u197map](../r11u197map/README.md) (map 11, at `4a65840e`). Passes 193 and 195 and
the verification r11u199 landed after it. Every targeted row was re-measured at `a015c911` before it was worked,
from the r11u199 landing sweep `/tmp/intr11u199` (read-only) and this pass's own pristine sweep.

**The fence.** No fenced row is `STRICT_NOTEQUAL` at `a015c911`, so no fenced database was opened by an analysis
driver. Every driver that reads a corpus source or database takes the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and refuses them by word boundary, fail closed: `env.sh`, `case.sh`,
`rowrun.sh`, `det.sh`, `dscase.py`, `census.sh` (run with `--filter` built from the fence), `bvmirror.sh` (the byte
comparison ran on hard-link mirrors that leave the 8 fenced row-mode databases out), `uvmdist.sh`,
`attribution.sh` (its filter lists the 63 predicted mover tests and was checked against the fence when written).
The gate sweeps dispatched every row, as the gate requires. No binary, gdb run or script touched a fenced test's
sources or databases outside those sweeps; a grep of this directory for the four names reads 0.

## 0. Verdicts per cluster family

| family | map 11 clusters | the rule golden follows (decoded) | law, switch, ground | rows it moves (both modes) | cases |
|---|---|---|---|---|---|
| (a) signing keyword span | **N0056** (UVM first open record), int_types' N0852 N1137 N1147 N1150 N1155 | Surelog's typespec for a builtin type is `compileBuiltinTypespec`'s: a bit/logic/reg ends at its `signed` keyword but never at `unsigned`; an integer atom ends at `unsigned` but never at `signed`. Three contexts override it: an ANSI subroutine formal (compileTfPortList re-populates the typespec at the Data_type node: whole `int signed`), a function's RETURN VARIABLE (compileVariable ends with `populateCoreMembers(declarationId)` on the Data_type node: whole `int signed`, `bit unsigned`) and nothing else. The return TYPESPEC, a non-ANSI formal and a generate-block variable take the builtin rule | law `tfSigningSpanFollowsCompilePath200`, `R11U200_SIGNSPAN_OFF`, B (TypeEmit makeTypespec, TaskFuncEmit return variable, ModuleEmit generate-block variables) | int_types: 16 endcol records gone; UVM rows: the `uvm_packer::get_bit` head gone (MiniAmiq `file(25)` -> `file(24)` alone) | S: 9 of 16 converted (s14 by (a')) |
| (a') int_types' fullname face | **N0912** (132 objects) | a definition-view generate-block variable's initializer that is not a constant stays PARENTED at the assignment, so its references read the branch chain (`work@top.x`, `work@s14.g1.x`); only a constant root is left unparented | law `defGenInitRhsKeepsParent200`, `R11U200_GENINIT_OFF`, B (ModuleEmit) | **int_types d/t CONVERT** (with (a)) | V: 4 of 4, S/s14 |
| (c) SVSwitch | **N1011**, N0526, N0954, N0958, N1010, N1019, N1020 (+ the endline face, + N0007) | an interface-ARRAY port's element views (NetlistElaboration's modport-port branch, one `elab_interface_` per element) get NO stored full name: in a PROGRAM the unowned array makes the chain `<formal>.<element>` (`output_intf.output_intf[0]`); the element's modport binds a header port to the element's own variable, it mints no doubled net | law `ifaceArrPortElemViewNamedByArray200`, `R11U200_IFARRNAME_OFF`, B (ModuleEmit) | with (c') and the B half alone: SVSwitch fullname(13) -> fullname(2) | I: 8 converted of 14 (2 equal already) |
| (c') SVSwitch endline | (in N1010 / N1019 at map 11) | an IMPLICIT data type is an empty parse node whose end Surelog reads off the whitespace token before the name: end line = the line that token starts on, end column = its start column + its length, newline and indentation included (rtl.sv 2:6-1:479) | law `implicitTsEndCrossesLineBreak200`, `R11U200_IMPLEND_OFF`, B (TypeEmit) | SVSwitch the 3 endline records; UnitElabBlock moves (section 5) | L: 2 of 2 moved, 2 controls |
| (c'') SVSwitch's last two records | **N0007** (ground A) | a paren-less built-in `bytes.size` in a `new[...]` size is a hier_path whose trailing ref_obj golden leaves unnamed like every reference under the unparented `new` call | law `newArrayArgPathElemsStripped200`, `R11U200_NEWARRHP_OFF`, **A** (ExprEmit) | with (c)+(c'): **SVSwitch d/t CONVERT** | N: 2 of 2 |
| (d) Scr1SvTests | **N1139** and the port face | (1) writeNets' end-only populate moves the NET's typespec: a port typespec whose definition net carries none keeps the whole `logic [N_IF-1:0] [W_ID-1:0]` span; (2) a bound or $unit initializer Surelog REDUCED is populated at the ROOT operation's LEFT OPERAND node, one level, parentheses kept (`[\`SCR1_XLEN-1:0]` at `32`, `(M << S) \| RVI \| RVC \| RVM` at `(M << S) \| RVI \| RVC`) | laws `defPortPackedTsKeepsWholeSpan200` (`R11U200_PORTPACKED_OFF`, B ModuleEmit) and `unitBoundFoldAtLeftOperand200` (`R11U200_UNITFOLD_OFF` + `R11U200_FOLDDEPTH_OFF` A ParamEmit, `R11U200_UNITINIT_OFF` B UhdmExporter) | Scr1SvTests d/t `endcol(29)` -> `type(1)` (one structural record left, decoded in section 3d) | M: 4 of 4, U: 2 of 2 |
| (e) cfg_func_width_loop | N0025 N0033 N0133 N0263 N0487 (+A: N0754 N0794) | decoded, **no law**: golden's elaborated `assign o = q::maxw(M)` is the SHARED definition cont_assign (the evaluator cannot reduce `maxw`), and the parameter M's value constant carries the evaluator-stamped formal typespec (maxw's `mask_t cfg`, 27:40) | the fold decision sits in ModuleEmit's emitContAssigns where r11u196 lands law evalFuncCastMemberKeepsCall191 now; the stamp in ParamEmit (A) | - | section 3e |
| (e) struct_param_func_config | N0028 N0552 N0761 N0817 | decoded, **no law**: the struct copy the evaluator built is named through the instance where the chain's value was evaluated (`work@top.p::cfg_t.u`, not `work@top.u_m.u_c.Cfg.p::cfg_t.u`); the names sit in ParamEmit's makeParamTs (ground A, `memberScope`) and the copies are shared across instances | report | - | P: 5 (0 converted) |
| (f) r11u194 N1: the class-in-module crash | (probe/residue only) | a parameterized class declared in a module body is a GenericClassDefSymbol slang never listed as a module class: no class_defn, the specialization's class_typespec had no vpiClassDefn and a param_assign with a null Lhs; UHDM's `propagateParamAssign` (`--elabuhdm`) and the uhdm2rtlil plugin dereferenced the null. Surelog lists it from its default specialization, and a specialization of a module-local class is found by the second `getClassDefinition` probe (`<component>::<name>`): Name + Class_defn, no parameters | law `modGenericClassListedAtDefault200`, `R11U200_CLASSCRASH_OFF`, B (ModuleEmit listing, TypeEmit typespec) | none in the corpora | K: 3 converted from NOT_EQUAL, z01 converted; **--elabuhdm rc 139 -> 0 on 5 of 5 crashing cases; downstream CRASH -> IDENTICAL on 4, EQUIVALENT on x01** |
| (f) the UVM rows' first structural record | (MiniAmiq #10106, depth) | a return written as a TYPEDEF name of a class binds the typedef's own listed class_typespec, as a class property of that type already does; a late-bound `ref_var` return keeps the return token's span | law `classTdRetSharesTypedefTs200`, `R11U200_CLASSTDRET_OFF`, B (TaskFuncEmit) | the UVM walks no longer diverge at `get_event_pool` | T: 4 of 6 |
| (g) r11u199 N1 | (stage 1) | the operation rule for positional actuals is the udp-instantiation rule's shadow: a list is a udp_instantiation only when its FIRST terminal is a net lvalue | law `posOpConnKeepsRefModule200`, `R11U200_POSREFMOD_OFF`, B (ModuleEmit) | none in the corpora | Q: 6 converted from NOT_EQUAL + r01, c03 |
| (g) r11u199 N7 (DIVERGENT downstream) | (stage 1) | Surelog keeps every `$bits` call inside a generate block, a single-select argument too, and writes that argument as a part_select; ours folded it to the root width (32 where the plugin reads 5) | law `genBlockBitsKeepsSelect200`, `R11U200_GENBITS_OFF`, **A** (ExprEmit, elaborated) + B (TypeEmit, definition listing) | none in the corpora (HierPathPackedStruct fires, unmoved) | B: b01 b04 converted; **w8, b01, b03, b04, b05 DIVERGENT -> IDENTICAL**; r11u199 w1 w2 w8 converted |

Totals (the full gate sweep of both patches, section 5): **probe `regressions=0 conversions=14 changes=13`; surelog
`regressions=0 conversions=2 (SVSwitch d/t) changes=16`; uhdm2rtlil `regressions=0 conversions=2 (int_types d/t)
changes=0`; downstream 803 / 66 / 2 / 0, the csv byte-identical to the pristine sweep's**; 20 of 2560 corpus databases
move, every one predicted by name before the sweep; grid 47 of 88 cases converted, 0 regressed, `R11U200_OFF=1`
byte-identical to pristine on all 88.

## 1. Switches (every law droppable alone; one switch for the whole pass)

| switch | law | file (ground) | family |
|---|---|---|---|
| `R11U200_SIGNSPAN_OFF` | tfSigningSpanFollowsCompilePath200 | TypeEmit.cpp, TaskFuncEmit.cpp, ModuleEmit.cpp (B) | (a) |
| `R11U200_GENINIT_OFF` | defGenInitRhsKeepsParent200 | ModuleEmit.cpp (B) | (a') |
| `R11U200_IFARRNAME_OFF` | ifaceArrPortElemViewNamedByArray200 | ModuleEmit.cpp (B) | (c) |
| `R11U200_IMPLEND_OFF` | implicitTsEndCrossesLineBreak200 | TypeEmit.cpp (B) | (c') |
| `R11U200_NEWARRHP_OFF` | newArrayArgPathElemsStripped200 | ExprEmit.cpp (A) | (c'') |
| `R11U200_PORTPACKED_OFF` | defPortPackedTsKeepsWholeSpan200 | ModuleEmit.cpp (B) | (d) |
| `R11U200_UNITFOLD_OFF` | unitBoundFoldAtLeftOperand200, the $unit bound | ParamEmit.cpp (A) | (d) |
| `R11U200_FOLDDEPTH_OFF` | unitBoundFoldAtLeftOperand200, one level in a package bound | ParamEmit.cpp (A) | (d) |
| `R11U200_UNITINIT_OFF` | unitBoundFoldAtLeftOperand200, a $unit initializer | UhdmExporter.cpp (B) | (d) |
| `R11U200_CLASSCRASH_OFF` | modGenericClassListedAtDefault200 | ModuleEmit.cpp, TypeEmit.cpp (B) | (f) N1 |
| `R11U200_CLASSTDRET_OFF` | classTdRetSharesTypedefTs200 | TaskFuncEmit.cpp (B) | (f) UVM |
| `R11U200_POSREFMOD_OFF` | posOpConnKeepsRefModule200 | ModuleEmit.cpp (B) | (g) N1 |
| `R11U200_GENBITS_OFF` | genBlockBitsKeepsSelect200 | ExprEmit.cpp (A), TypeEmit.cpp (B) | (g) N7 |
| `R11U200_OFF` | all of them | | |

`R11U200_TRACE=<dir>` writes one file per process and unit (`<pid>.200` for ground B, `<pid>.200E` ExprEmit,
`<pid>.200P` ParamEmit; first line `OUT <-o database>`, then `<law> <detail>` per firing): the census below. Every
trace line fires on a superset of the moves (the port-packed law traces every port entry it reaches, one- or
multi-dimensional). `R11U200_OFF=1` on the law binary writes the pristine bytes on all 88 grid cases
([evidence/grid.tsv](evidence/grid.tsv), last column).

## 2. Binaries (frozen `chmod 555` in `/tmp/r11u200_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `a7d318bf253b9e9a1dc424ca5bcf1548` | worktree `/tmp/wt_r11u200` at `a015c911`, system-deps config, `-j 2`: byte-identical to the main tree's `build/slang-uhdm` |
| `slang-uhdm.law` | `a064681e88e3b9ae10cbecf8b57b1bda` | `a015c911` + both patches (rebuilt from the restored sources after the alone builds: the same md5) |
| `slang-uhdm.lawA` | `6c89262b92b68c43f23631552436e504` | `a015c911` + law_exprstmt.patch alone |
| `slang-uhdm.lawB` | `f6a447a7760082151021bbf79844267f` | `a015c911` + law_typeemit.patch alone |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` (not edited: no comparator defect was found) |

The `slang-uhdm.w*` files beside them are the intermediate scratch builds the decode ran on, and `old1/` holds the
first law binary (`270ec592`, section 5: its generate-`$bits` test regressed HierPathPackedStruct); no gate number
reads them.

## 3. The decodes

### 3a. The signing keyword (N0056 and int_types)

Heads at the base: MiniAmiq `#8753 bit_typespec uvm_packer.svh 603:10-603:13` (golden) against `603:10-603:22`
(ours) for `function bit unsigned uvm_packer::get_bit`; int_types 16 `endcol` records: `logic_typespec 3:9-3:12`
against `3:9-3:21` (`reg unsigned` in the `TEST` macro), and `integer_var 11:28-11:42` against `11:28-11:35`
(`function automatic integer signed f`, the return variable).

Surelog, `CompileType.cpp`:
* `compileBuiltinTypespec` (`fC->populateCoreMembers(type, isSigned ? sign : type, var)` for logic / reg / bit,
  `isSigned ? type : sign` for the five integer atoms): a vector ends at `signed` and never at `unsigned`; an atom
  (signed by default) ends at `unsigned` and never at `signed`;
* `compileVariable` builds the return variable (`CompileStmt.cpp` compileFunction -> `compileVariable(component,
  fC, Return_data_type, ...)`) and ends with `if (result->VpiLineNo() == 0) fC->populateCoreMembers(declarationId,
  declarationId, result)`: the atom variables carry no location of their own, so the variable spans the WHOLE
  Data_type node (`int signed`, `bit unsigned`) while its typespec keeps the builtin end;
* `compileTfPortList` (`CompileStmt.cpp`) re-populates an ANSI formal's typespec at the Data_type node
  (`fC->populateCoreMembers(type, type, ts)`): the whole `int signed`; the non-ANSI `compileTfPortDecl` does not.

The grid ([cases/S](cases/S), 16 cases; the table per context is in [evidence/signspan.txt](evidence/signspan.txt)):

| context | golden typespec | golden variable | ours before |
|---|---|---|---|
| module / class / package variable, function local, typedef | builtin rule | the declarator | agreed |
| function return (module, package, class, `extern` prototype and out-of-body body, non-ANSI `function automatic typ f;`) | builtin rule | whole data type | typespec kept `unsigned` (r11u137 had read the return as a formal); atom variable took the typespec's span |
| ANSI formal (function or task) | whole data type | - | trimmed `signed` off an atom |
| non-ANSI formal (`input bit unsigned a;` in the body) | builtin rule | - | kept `unsigned` |
| generate-block variable, both views | builtin rule | - | kept `unsigned` (ModuleEmit's two generate-variable sites use `trimTypeSigning` only) |
| a macro argument type (`` `D(bit unsigned, n)``, int_types' multi-line `TEST`) | the same rules on the expanded text | | the same faults |

Law `tfSigningSpanFollowsCompilePath200` carries exactly that table; r11u137's `tfSig137` exemption is narrowed to the
ANSI formal (`ansiFormal200`: a declarator under a `FunctionPort`). Converted: S s02 s03 s07 s09 s11 s12 s13 s15 s16,
r11u137's own bt13 moves from `endcol` to its next record (a kept call, cluster N0133). Left: s01 s04 s08 (stage 1:
golden marks a `bit signed` / `logic signed` VARIABLE `vpiSigned`, ours does not — judge-visible, no corpus row
carries it), s06 (a one-line macro body: Surelog attributes the whole expansion to the invocation line; a
macro-location face, not signing).

### 3a'. int_types' fullname face (N0912, 132 objects)

Head: `ref_obj x` in `logic [127:0] a = x;` inside `if (1) begin ... end` in the definition listing: golden
`work@top.x`, ours no full name. Golden's dump shows the initializer PARENTED at the assignment (`|vpiParent:
\_assignment`), full name stored through the chain (`work@s14.g1.x` in a named block, `work@top.x` in an unnamed one
whose begin carries `work@top`); only a constant initializer is unparented (the rule ModuleEmit's gen-block
declaration emitter already had, applied to every root). Grid [cases/V](cases/V): a reference, a part select, an
operation, a concatenation, `$bits(x)`, nested blocks, a gen-for and a gen-case branch: 4 of 4 converted (S/s14 too).
Two neighbours measured and left: a reference to a MODULE PORT from such an initializer (golden's ref_obj has no
vpiActual, ours binds: stage 1), and a reference to a module PARAMETER (golden keeps the ref_obj in the elaborated
scope, ours folds: stage 1).

**int_types d/t convert** with (a) and (a') (fresh rows in section 5).

### 3c. SVSwitch (N1011 family, the endline face, N0007)

Heads at the base: `#3380 interface_inst output_intf[0]`, golden full name `output_intf.output_intf[0]`, ours
`work@top.TC.output_intf[0]`, then its variables and typespec references (`output_intf.output_intf[0].clock`), then
`#3398 depth`: golden `port clock` where ours had an extra `logic_net ...OP.clock.clock` under the modport's
`io_decl clock`.

Surelog, `NetlistElaboration.cpp`: the modport-port branch (`if (ModPort* orig_modport = sig->getModPort())`) builds,
for a formal with unpacked dimensions, an `interface_array` named by the formal and, per element, a `ModuleInstance`
named `o[i]` handed to `elab_modport_` -> `elab_interface_`, whose `interface_inst` gets `VpiName` only (`//
sm->VpiFullName(??);`) and is parented at the array; the port's low-conn `ref_obj` stores
`instance->getFullPathName() + "." + sig`. `elab_interface_`'s modport loop binds each modport signal with
`bind_net_(interf_instance, sigName)`: for a header port that is the element's own port VARIABLE, left parented at
the interface_inst by `setParentNoOverride` (so the dump does not re-expand it under the io_decl). In a PROGRAM the
wrapper is unowned (law progPortIfaceArrayUnowned13), so every chain-computed name reads `<formal>.<element>...`; in
a module the wrapper is owned and golden's names already agreed with ours. Grid [cases/I](cases/I) (program and
module owners, named and positional, `[N]` and `[1:0]`, a scalar port beside an array, depth 2 through a module,
a module passing its array port down): 10 of 14 converted; i05 / i10 (generic `interface o[2]`) were already equal;
i03 / i04 / i07 / i11 are stage-1 faces of their own (an `o[1].d[0]` read in an assign, a non-modport array port's
typespec, a single-element actual `oa[1]`), identical in both binaries.

The endline face (`logic_typespec rtl.sv 2:6-1:479` against ours `2:6-2:6` for the split port `input  \n
read_0;`): the implicit data type is an empty node whose end is the whitespace token's start column plus the token's
length on the token's START line (`input` ends at 1:471, the trivia `  \n     ` is 8 characters: 1:479). On one line
the sum is the name's own column, so only a line break moves. Grid [cases/L](cases/L): l01 (three shapes) and l04
(tabs) converted, l02 (dims: the typespec spans the dims) and l03 (net keyword anchor) controls unchanged.

SVSwitch's last two records (`ref_obj size` in `bytes = new[bytes.size + 1](bytes)`, golden unnamed): cluster N0007,
ground A. The existing `stripRefFullNames11` strip under the unparented `new` call did not descend into a hier_path's
elements. Grid [cases/N](cases/N): both converted (a class method and a module initial block; the same `size` outside
`new[...]` keeps its name in both).

### 3d. Scr1SvTests (N1139 and the port face)

At the base the row reads `endcol(29)`: 16 port typespecs of `scr1_memory_tb_axi` (`input logic [N_IF-1:0]
[W_ID-1:0] awid`, golden 29:12-29:39, ours 29:12-29:28) and 13 reduced constants.

* Ports: ModuleEmit `materializeDefNetTs` truncates a multi-dimensional packed definition NET typespec to its first
  dimension (writeNets' end-only populate, measured by an earlier pass for nets); the pending entry for a PORT whose
  definition net carries no typespec of its own (golden `work@sub.b` bare) reached the same branch and truncated the
  port's typespec. Law `defPortPackedTsKeepsWholeSpan200` adds the port fence law defNetTypedefEndWrite134 already
  carries. Grid [cases/M](cases/M): m03 m05 m07 m08 converted (ANSI, non-ANSI, `wire` ports, a body net beside the
  port keeps its truncation), m01 m02 m04 m06 controls unchanged.
* Reduced constants: `localparam [\`SCR1_XLEN-1:0]` (a $unit parameter's bound, golden `211:13-211:15` on the macro
  text `32`, ours the whole `32-1`), and the $unit initializers `(M << S) | RVI | RVC | RVM` (golden
  118:47-125:63) and `A + B + C` (golden 19:54-20:77). Surelog populates what it reduced at the ROOT operation's LEFT
  OPERAND node, one level, parentheses kept. ParamEmit located a package bound at the leftmost LEAF (too deep for
  `2*4-1` and `1+2+3`: grid U/u05, golden `2*4` / `1+2`) and a $unit bound at the whole expression; UhdmExporter
  located a $unit initializer at the leftmost leaf. Grid [cases/U](cases/U): u01 u05 converted, u03 u04 controls,
  u02 u06 stage-1 faces of their own.
* Left: ONE structural record, `#48892 type` at scr1_pipe_ifu.sv 607 (`assign ifu2imem_cmd_o = SCR1_MEM_CMD_RD;`):
  golden SHARES the definition cont_assign and its right side is a ref_obj bound to an IMPLICIT `logic_net
  work@scr1_pipe_ifu.SCR1_MEM_CMD_RD` (no file); ours folds the enum constant (`1'b0`). The constant is declared by a
  `$unit` typedef enum in `scr1_memif.svh`, include-guarded, and Surelog's per-file compilation units leave it
  unresolved in this file (an implicit net, a Surelog binding defect that changes nothing downstream here: the
  value is 0 either way). No law: following it means inventing an unresolved-name net for a name slang resolves.

### 3e. The joint rows' B halves

**cfg_func_width_loop** (`line(3)` at the base, 3 records, walk diverged): the first record is the parameter M's
value constant `3'b101` whose ref_typespec golden points at a `logic_typespec mask_t` located at 27:40-27:46 — the
FORMAL `mask_t cfg` of `q::maxw`: UHDM `ExprEval::evalFunc` binds every actual (`exparg->Typespec(<formal
typespec>)`) and the actual here is the SHARED param_assign constant, reached through `logic [q::maxw(M)-1:0] a`.
Ours builds a parameter-type copy at the typedef (16:11-16:25) whose range keeps `NF-1` (hence N0025 / N0033 behind
it). The elaborated `assign o = q::maxw(M)` is golden's SHARED definition cont_assign (the func_call kept: maxw's
body reaches `fwidth`'s `unsigned'(2 ** (ENC[i].e - 1) - 1) + ENC[i].m`, a member read of a packed-array-of-struct
PACKAGE localparam that `reduceExpr` cannot evaluate), ours a fresh folded `UINT:10` (N0133 / N0487). The stamp is
ParamEmit's (ground A: which parameter reads the evaluator reaches, the model pass 195 built for call arguments),
the fold decision is ModuleEmit emitContAssigns' where pair B r11u196 is landing law evalFuncCastMemberKeepsCall191
(its cast and member rules must extend to a package localparam's member read inside a callee reached through a
`for` / `if`). Reported with the call sites instead of a law, to avoid colliding with r11u196's landing.

**struct_param_func_config** (`fullname(5)`): the struct copy the evaluator built (`typespec_member` values
annotated) is named through the instance where the override chain's value was evaluated: golden
`work@top.p::cfg_t.u` in the child's definition listing, ours `work@top.u_c.Cfg.p::cfg_t.u` (and
`work@top.u_m.u_c.Cfg...` two levels down). Grid [cases/P](cases/P): g01 (the test's shape) and g04 (two levels)
reproduce, g02 (`.Cfg(p::C)` written at the instantiation) agrees already, g05 (no child) has a different
`golden-only constant copies` face (N0045, ground A). The name is ParamEmit `makeParamTs`'s `memberScope`
(`syntaxRefPrefix + "." + alias`, ground A) and the golden multiset holds five differently named copies of
`cfg_t.u` (the evaluator mutates shared objects: last writer wins); no law.

### 3f. r11u194 N1 (the class-in-module crash) and the UVM first structural record

N1: `module sub; class box #(type E = int); E v; endclass box #(byte) b; endmodule`. `--elabuhdm` segfaults in
`UHDM::propagateParamAssign` (`gdb` backtrace on the pristine binary over this directory's case:
`ElaboratorListener::enterAny` -> `enterVariables` -> `propagateParamAssign(pass, cctps->Class_defn())` with a
null class_defn), and the uhdm2rtlil plugin crashes on the definition-view database. The module listing collected
`SymbolKind::ClassType` members only; a parameterized class is a `GenericClassDefSymbol`. Golden: `work@sub` lists
`class_defn work@sub::box` compiled from the default specialization (`type_parameter E` -> int, `int_var v`), and the
specialization's `class_typespec box` carries Name + Class_defn and nothing else (Surelog's second
`getClassDefinition` probe, `<component>::<typeName>`, hits the module's own registry key). The law lists the
default specialization (the package listing's own call, `getDefaultSpecialization(body)`) and suppresses the
typespec's parameters for a specialization of a module-local generic. Grid [cases/K](cases/K): k01 k03 k07 and
r11u194's z01 converted (NOT_EQUAL -> EQUAL), k05 control; k02 (= r11u194 x01, a module type parameter feeding the
class), k04 (a PACKAGE class specialized at module scope: golden names it `p::box` spanning `p::`), k06 and k08
(value parameters in the class body) keep stage-1 faces of their own. **`--elabuhdm` rc 139 -> 0 on k01 k02 k03 k08
z01** (5 of 5); downstream (the gate's `one()`, [evidence/downstream/](evidence/downstream/)): **CRASH -> IDENTICAL**
on z01 k01 k03 k08, **CRASH -> EQUIVALENT** (nohier only) on k02.

r11u194 N2 (a class typespec ending after its parameter list) is the same Surelog probe seen at k04: a module-scope
`p::box #(byte) b;` is golden `class_typespec p::box` spanning `p::` (7:3-7:6) with no parameters, ours `p::box
#(byte)` spanning the whole. Not written: the module-scope package-generic branch is law classPkgGenericSpecListing53's
`!declInInstance53` fence (golden splits there on the initializer), which needs its own grid.

The UVM rows' first STRUCTURAL record (after the file-order heads pair B owns: N0144, N0327) was MiniAmiq `#10106
name` / `#10107 depth`: `function uvm_event_pool get_event_pool()` (uvm_transaction.svh 520), golden
`class_typespec uvm_pkg::uvm_event_pool` at the typedef (uvm_pool.svh 344:9-344:31), ours an anonymous mint at the
return token, after which the walk diverged. TaskFuncEmit's class-handle return branch never asked for the typedef's
listed object that makeTypespec shares for a property of the same type. Grid [cases/T](cases/T): t01 t02 t03 t04
converted (package typedef of a specialization, of the bare class, an out-of-body body, a class-scope typedef whose
return is the late-bound `ref_var` that keeps the return token's span); t05 (a module function returning
`p::c_t`: golden `class_var`, ours `ref_var`) and t06 (a package function) keep stage-1 faces of their own. On the
UVM rows the walk now runs past `get_event_pool` (the strict cells' counts grow because more records are reached:
section 8 gives the order-blind distances).

### 3g. r11u199's residues on this ground

* **N1** (a positional actual that is an operation drops the ref_module): law `posOpConnKeepsRefModule200`. Surelog
  reads an ordered list as a `udp_instantiation` only when the FIRST terminal is a net lvalue; ModuleEmit's
  operation rule (from `uut(clk, a && b, ...)`, udp-shaped) fired on every list holding an operation. Grid
  [cases/Q](cases/Q): an operation, a unary, a conditional or a literal first, an operation later behind a literal,
  a `#(2)` override, an empty later terminal: q01 q03-q07 converted from NOT_EQUAL; q02 (lvalue first) and q08
  (concatenation first: a net lvalue) keep no ref_module in both; r11u199's R/r01 and C/c03 converted.
* **N7** (`$bits(x[W:0])` as a whole for-generate right side, DIVERGENT): law `genBlockBitsKeepsSelect200`; the
  residue R-GENFOLD law genBlockBitsNoLeftmostFold27v's verifier recorded. Surelog lane `connect \z 5` (correct), ours
  `connect \z 32`: ours folded the select to the ROOT width (the `compileBits` quirk Surelog applies only where it
  folds), in both views. Grid [cases/B](cases/B): b01 (package bound) and b04 (literal) converted, b03 (a module
  parameter bound: golden's elaborated part select binds the param_assign constant, stage 1) and b05 (gen-if:
  `fullname(1)`) left; b02 (outside a generate block) is the control (both lanes fold 32: a Surelog defect we follow,
  IDENTICAL downstream). **Downstream: w8 b01 b03 b04 b05 DIVERGENT -> IDENTICAL**; r11u199's w1 (`$unsigned(x[W:0])`)
  and w2 (`$signed(...)`), the N8 faces, converted too.
* **N6** (casts in an array net's initializer, c06, DIVERGENT): decoded, no law. The first differing object is
  `$signed` (from `signed'(7'(r))`, CompileExpression's `paCast` branch builds a sys_func_call with no typespec) whose
  golden elaborated copy carries a ref_typespec to the NET's typespec (`wire signed [6:0] v`, 6:3-6:20): the
  downstream plugin sizes the call from it (Surelog lane 7 bits, ours 1). The stamp belongs to the elaborated
  net-declaration assignment emission (ModuleEmit, the writeCont_assign sizing family of law elabCaConstLhsSized191);
  not landed here.
* **N5** (an enum-typed type-parameter port written by a cast, x06, DIVERGENT): a **Surelog defect**. The Surelog
  lane writes `module \sub` unparameterized with `so` 1 bit wide; ours `\sub$typaram_3_3` with `so` 3 bits, which is
  what the source means (`T = e_t`, `logic [2:0]`). Following golden would make our netlist wrong; no law.
* **N3** (a `logic` variable initializer outside the net-declaration law, fullname): not reached this pass; the
  definition-view generate-block initializer (3a') is a different site (the module body declaration path).
* **N4** (a fill conditional in a generate loop or on a member target): not reached this pass.
* **N2** (a class-scoped `K::V` bound spanning only `K::`, endcol): ground A. Law pkgQualBoundSpanQualifier192 is
  already gated on a PACKAGE scope; the `K::` span of the class-scoped ref_obj comes from another ExprEmit site (the
  ScopedName reference branch), golden spans the whole `K::V` (13:17-13:21). Reported, not written.
* **N9** (a nested interface declaration Surelog's parser rejects): report only (no golden).

## 4. The grid ([evidence/grid.tsv](evidence/grid.tsv), [drivers/grid.sh](drivers/grid.sh))

86 cases in 12 families, judged the way `scripts/check_probe.py` judges (`dut.sv --single-unit --nobuiltin`,
uhdm-cmp, then uhdm-strictcmp), goldens from the pinned Surelog (cached per text in `/tmp/r11u200_gold`):

| family | what | cases | EQUAL pristine | EQUAL lawA | EQUAL lawB | EQUAL both | converted by both | regressed |
|---|---|---|---|---|---|---|---|---|
| B | `$bits` in generate bodies (+ b06/b07 condition / loop-header controls) | 7 | 1 | 1 | 1 | 3 | b01 b04 | 0 |
| I | interface-array ports | 14 | 2 | 2 | 10 | 10 | i01 i02 i06 i08 i09 i12 i13 i14 | 0 |
| K | classes in module bodies | 8 | 1 | 1 | 4 | 4 | k01 k03 k07 | 0 |
| L | split-line implicit port types | 4 | 2 | 2 | 4 | 4 | l01 l04 | 0 |
| M | multi-dimensional packed ports | 8 | 4 | 4 | 8 | 8 | m03 m05 m07 m08 | 0 |
| N | `new[...]` sizes | 2 | 0 | 2 | 0 | 2 | n01 n02 | 0 |
| P | evaluator struct copies (decode only) | 5 | 1 | 1 | 1 | 1 | - | 0 |
| Q | positional actuals | 8 | 2 | 2 | 8 | 8 | q01 q03 q04 q05 q06 q07 | 0 |
| S | the signing keyword | 16 | 2 | 2 | 12 | 12 | s02 s03 s07 s09 s11 s12 s13 s14 s15 s16 | 0 |
| T | class typedef returns | 6 | 0 | 0 | 4 | 4 | t01 t02 t03 t04 | 0 |
| U | reduced bounds and $unit initializers | 6 | 2 | 4 | 2 | 4 | u01 u05 | 0 |
| V | generate-block initializers | 4 | 0 | 0 | 4 | 4 | v01 v02 v03 v04 | 0 |
| **all** | | **88** | 17 | 21 | 58 | **64** | **47** | **0** |

Outside this directory, the evidence cases of earlier passes the laws reach: r11u194verify Z/z01 (NOT_EQUAL ->
EQUAL), r11u199verify R/r01 and C/c03 (NOT_EQUAL -> EQUAL), W/w1, W/w2, W/w8 (NOT_EQUAL -> EQUAL), r11u137repro
bt13 (`endcol` -> its next record, a kept call). The B family's b06 (a gen-if condition `$bits(x[4:0]) != 5`) and
b07 (a gen-for stop expression) are the controls of the generate-body test: stage 1 in every binary for faces of
their own and byte-identical to pristine under the final law binary; the first law binary moved both (section 5).

`R11U200_OFF=1` on the law binary: 88 of 88 byte-identical to the pristine binary's database.

## 5. The gates of the law sweep

The full `tests/sweep.sh --jobs 3 --workdir /tmp/r11u200_sL` with the law binary (`SLANG_UHDM` exported; all 3273
`slang:` lines of its `cmds.txt` files name `/tmp/r11u200_bin/slang-uhdm.law`), against the committed baselines, beside
this pass's own pristine sweep `/tmp/r11u200_sP` (the same two workdir-name lengths; its csvs equal the committed
baselines: `regressions=0 conversions=0 changes=0` in all three stages, its `probe.csv` byte-identical to
`results/golden_probe.csv`, downstream 803 / 66 / 2 / 0). Both sweeps exit 1 for one reason only, `law index STALE:
tests/LAWS.md`, which the main tree at `a015c911` reads too (`python3 scripts/law_index.py --check`, rc 1).
Summaries: [evidence/sweeps/sweep_law.txt](evidence/sweeps/sweep_law.txt),
[sweep_pristine.txt](evidence/sweeps/sweep_pristine.txt).

| gate | pristine `a7d318bf` | law `a064681e` |
|---|---|---|
| (1) build | = the main tree's build | `a015c911` + both patches |
| (2) probe vs golden_probe.csv | EQUAL 3306 / 781 | **EQUAL 3320 / 767: `regressions=0 conversions=14 changes=13`** |
| (3) surelog vs golden_surelog.csv | = baseline | **`regressions=0 conversions=2 changes=16`**; judge-equal 462+18=480 default, 458+16=474 testflags, CMP_NOTEQUAL 3 / 3 (unchanged) |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | = baseline | **`regressions=0 conversions=2 changes=0`**; 794+9=803 per mode, CMP_NOTEQUAL 1 (unchanged) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **the same; the csv byte-identical to the pristine sweep's** |
| (5) uhdm-cmp | | every corpus row keeps its judge status (the histograms above); every probe case stays uhdm-cmp EQUAL (the probe stage fails on any that does not) |
| (6) byteverify (SELFCHECK=1, fence-free mirrors) | | **20 / 2560 movers, every one PREDICTED by name** (section 6) |
| canaries ([evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)) | surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS | surelog ok=39 changed=13 (exactly the 13 canary rows among the changes below); uhdm2rtlil ok=16 changed=0; ctcan2 PASS both |

**The four row-mode conversions** (fresh rows of `/tmp/r11u200_sL`, NOT written to `results/`):

    SVSwitch,default,CMP_EQUAL,,,equal       was differ:fullname(13)   laws ifaceArrPortElemViewNamedByArray200 + implicitTsEndCrossesLineBreak200 + newArrayArgPathElemsStripped200 (A)
    SVSwitch,testflags,CMP_EQUAL,,,equal     was differ:fullname(13)
    int_types,default,CMP_EQUAL,,,equal      was differ:fullname(82)   laws tfSigningSpanFollowsCompilePath200 + defGenInitRhsKeepsParent200 (uhdm2rtlil)
    int_types,testflags,CMP_EQUAL,,,equal    was differ:fullname(82)

The 16 surelog changes (each row stays judge-equal; the order-blind distance to golden falls on every one, section 8):

    Scr1SvTests d/t      differ:endcol(29)   -> differ:type(1)       port packed span, reduced-bound location (one structural record left: section 3d)
    UnitElabBlock d/t    differ:endline(13/12) -> differ:file(2/1)   the implicit type end across a line break; left: an implicit net's empty file
    Earlgrey_0_1 d/t     differ:fullname(82) -> differ:endcol(80)    port packed span (the fullname heads are passed)
    Rggen d              differ:endcol(144)  -> differ:defname(142)  port packed span (2 endcol records gone; the defname records were behind them)
    MiniAmiq d/t         differ:file(25)     -> differ:file(102)     signing span + class typedef return: the walk now runs past get_event_pool
    SeqDriver d/t        differ:file(24)     -> differ:file(96)
    SimpleUVM d/t        differ:fullname(52) -> differ:fullname(126)
    Scoreboard d         differ:fullname(52) -> differ:fullname(134)
    BuildUVMPkg d/t      differ:fullname(20) -> differ:fullname(33)

The UVM strict counts grow because the comparator reaches more records before the walk diverges; they are not
comparable across a change that removes a divergence (RESUME section 9, ladder facts). The arbiter is the order-blind
distance, which falls on all of them.

The 14 probe conversions: r10earl109repro/g6_carrier109, r10rgg6repro/cells/{genfor_p2_n4, one_p2_n2, one_p2_n4,
one_p2_n4 _2ts, rec_p2_n4, two_p2_n4}_yes_typed_param (port packed span), r10svs11repro/v3_arr, r10svs2repro/s4_context,
r10svs3repro/a1_newlhs (interface-array names, `new[...]` sizes), r10uvm70repro/a1_ret (signing span),
r10uvm97repro/g97_a1_selftd, g97_a4_plainclass, r10v97repro/v97_c1_mixedgroup (class typedef returns). The 13 probe
changes: twelve r10rgg6repro cells `endcol(n)` -> `line(n-1)` (the port span fixed, the next record exposed) and
r10v78repro/v6_ndecl78 `fullname(3)` -> `fullname(2)`.

**The first law binary regressed a corpus row, found by the gate and fixed.** Its generate-block `$bits` test counted
a generate construct's CONDITION as inside the block: HierPathPackedStruct d/t (`if ($bits(a.pair[0]) != 42)`, a
gen-if condition golden folds) went CMP_EQUAL -> CMP_NOTEQUAL. Its firing census had predicted the row
(`genBlockBitsKeepsSelect200:1`). The law now tests the generate BODY (`genBody200`: the block or else-branch of a
gen-if, a gen-for's block, a gen-case item's clause, a generate region or begin-end block); the row reads STRICT_EQUAL
in both modes again, cases B/b06 and b07 were added as controls, and the census and the whole gate sweep were re-run
from scratch on the final binary (the numbers above). The first sweep's summary is kept:
[evidence/sweeps/sweep1_first_law_binary.txt](evidence/sweeps/sweep1_first_law_binary.txt).

## 6. Movers, predicted by name

The firing census ([drivers/census.sh](drivers/census.sh), [censum.py](drivers/censum.py)): the law binary with
`R11U200_TRACE` over every corpus row-mode but the four fenced ones (`--filter` built from `$FENCED`) and every probe
case, BEFORE the law sweep; its summary [evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt)
(121 corpus row-modes and 152 probe cases) was frozen `chmod 444` at the time in
[frozen_at.txt](evidence/census/frozen_at.txt), before the law sweep started.

The byte comparison ([evidence/sweeps/byteverify.txt](evidence/sweeps/byteverify.txt)) ran on hard-link mirrors of both
sweeps that leave the 8 fenced row-mode databases out (`mirrored=2560 fenced_skipped=8` on both): `PATH_SETS_IDENTICAL
(2560 paths)`, `SELFCHECK 2559 / 2560 flagged`, **`MOVERS: 20 / 2560`**:

    surelog d/t: BuildUVMPkg Earlgrey_0_1 MiniAmiq Scr1SvTests SeqDriver SimpleUVM SVSwitch UnitElabBlock
    surelog d: Rggen Scoreboard
    uhdm2rtlil d/t: int_types

**20 of 20 movers predicted by name; 0 moved-not-predicted.** 101 predicted-not-moved: the census traces a superset
(the port-packed law traces every port entry it reaches, one-dimensional ones included, and the signing law traces
every return / formal it re-spans even where the old span agreed); among them cfg_func_width_loop and
struct_param_func_config (the port law fires on single-dimensional ports) and the rp32 / iface / param rows. Every
mover is a strict CHANGE or CONVERSION of section 5 except none: all 20 appear there. The UVM coin rows (MiniAmiq,
SeqDriver, SimpleUVM, Scoreboard) move by the laws, not by their coin: section 8's order-blind distances fall by
83-98 records on each, and their coin (below) is the same in both binaries.

## 7. Downstream

The gate's downstream stage on the law binary: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the
`downstream.csv` byte-identical to the pristine sweep's: **no row moves**, and the two converted uhdm2rtlil rows
(int_types d/t) were IDENTICAL already.

The cases, with the gate's own `one()` ([drivers/dscase.py](drivers/dscase.py), fresh `GOLDEN_CACHE`,
[evidence/downstream/cases.txt](evidence/downstream/cases.txt)):

| case | pristine | law |
|---|---|---|
| r11u194 Z/z01, K/k01, K/k03, K/k08 | STATUS_DIFF (slang lane **CRASH**) | **IDENTICAL** |
| K/k02 (= r11u194 X/x01) | STATUS_DIFF (CRASH) | **EQUIVALENT** (nohier) |
| r11u199 W/w8, B/b01, b03, b04, b05 | **DIVERGENT** (ours `connect \z 32`, Surelog lane 5) | **IDENTICAL** |
| r11u199 C/c06 | DIVERGENT | DIVERGENT (N6, decoded in 3g) |
| r11u199 X/x06 | DIVERGENT | DIVERGENT (N5: the Surelog lane is the wrong netlist) |

## 8. Determinism and the UVM rows

**Determinism** ([drivers/det.sh](drivers/det.sh), each binary three times CONCURRENTLY per row-mode with the
reference sweep's command line and cwd; [evidence/determinism/](evidence/determinism/)):

| row-mode | pristine: distinct hashes (of 3) | law: distinct hashes (of 3) |
|---|---|---|
| Earlgrey_0_1 default | **1** | **1** |
| Earlgrey_0_1 testflags | **1** | **1** |
| MiniAmiq d / t | 3 / 3 | 3 / 3 |
| SeqDriver d / t | 3 / 3 | 3 / 3 |
| SimpleUVM d / t | 3 / 1 | 1 / 1 |
| Scoreboard d | 2 | 2 |
| BuildUVMPkg d / t | 1 / 2 | 1 / 1 |

The UVM hashes are the one-constant value coin map 11 recorded at HEAD (closed by r11u191's law
queueRetTwinDynShape191, which r11u196 is landing) plus the svunit order draw: the order-blind line counts between
runs are the same in both binaries (MiniAmiq / SeqDriver 6, SimpleUVM / Scoreboard / BuildUVMPkg 2 or 0,
[orderblind_pairs.txt](evidence/determinism/orderblind_pairs.txt); read the first `0/` there as the counter's
initial value). **No law adds a coin; Earlgrey_0_1 stays one-valued per mode.**

**Order-blind distance to golden** (ours-not-in-golden strict records, depth dropped;
[drivers/uvmdist.sh](drivers/uvmdist.sh), [obdist.sh](drivers/obdist.sh),
[evidence/sweeps/orderblind_distance.txt](evidence/sweeps/orderblind_distance.txt)), pristine sweep -> law sweep:

| row-mode | pristine | law | |
|---|---|---|---|
| MiniAmiq d/t | 7089 | 6991 | -98 |
| SeqDriver d/t | 5739 | 5647 | -92 |
| SimpleUVM d/t | 2537 | 2453 | -84 |
| Scoreboard d | 1918 | 1835 | -83 |
| BuildUVMPkg d/t | 1018 | 916 | -102 |
| Earlgrey_0_1 d / t | 6729 / 6296 | 6725 / 6292 | -4 / -4 |
| Rggen d | 4521 | 4519 | -2 |
| Scr1SvTests d/t | 145 | 117 | -28 |
| UnitElabBlock d / t | 13 / 12 | 2 / 1 | -11 / -11 |
| SVSwitch d/t | 57 | **0** | converted |
| int_types d/t | 82 | **0** | converted |

(The UVM family census of r11u175uvm, `uvmcensus.py`, needs map 11's analyzer output per sweep; it was not re-run:
the distance above is its order-blind total.)

## 9. Each patch alone

Each binary built from `a015c911` + one patch ([drivers/attribution.sh](drivers/attribution.sh): the probe stage in
full, the corpus stages filtered to the 62 tests of the prediction; [evidence/sweeps/attribution_lawA/](evidence/sweeps/attribution_lawA/),
[attribution_lawB/](evidence/sweeps/attribution_lawB/); 58 of 58 `cmds.txt` name the binary under test):

| stage | law_exprstmt alone (lawA, `6c89262b`) | law_typeemit alone (lawB, `f6a447a7`) | both (law) |
|---|---|---|---|
| probe | 2 conversions (the `new[...]` cells), 0 changes, 0 regressions | 12 conversions, 13 changes, 0 regressions | 14 / 13 / 0 |
| surelog | 4 changes: SVSwitch d/t `fullname(13)` -> `endline(11)`, Scr1SvTests d/t `endcol(29)` -> `endcol(19)` | 18 changes (the 14 of section 5 but SVSwitch and Scr1SvTests, plus SVSwitch d/t -> `fullname(2)`, Scr1SvTests d/t -> `endcol(11)`) | 2 conversions (SVSwitch d/t), 16 changes |
| uhdm2rtlil | 0 | **2 conversions (int_types d/t)** | 2 |
| grid (88) | 4 EQUAL more | 41 | 47 |

SVSwitch converts only with both (ground B's names and span, ground A's `new[...]` names); Scr1SvTests' `type(1)`
needs both too (the port span is B, the bound location A and B). Everything else is one patch's. Both apply clean on
a fresh `a015c911`, alone and in either order (`git apply --check` in a fresh worktree of `a015c911`).

## 10. Residues, ranked

Ranked by the rows they hold (the fail list after both patches, section 5), then by downstream weight.

1. **The UVM rows** (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg; 9 row-modes). After both patches the
   first records are still pair B's file-order heads (MiniAmiq `#899 enum_typespec uvm_severity` file N0144, the
   `uvm_bitstream_t` writer order N0327) and pair A's `space.substr::i` names (a method call's receiver scoping the
   argument references, ground A); the first STRUCTURAL divergence moved past `get_event_pool`
   (law classTdRetSharesTypedefTs200), so the strict counts grow while the order-blind distance (section 8) shrinks.
   Not attempted this pass: N0067 / N0068 (a function return's class_typespec file and span), N0180, N0158, N0177,
   N0184, N0188, N0423, N0117, N0120, N0213, N0230, N0232, N0254-N0256 (each 9 row-modes, none alone).
2. **Scr1SvTests d/t** `type(1)`: the single structural record left is Surelog's unresolved `$unit` enum constant
   (`SCR1_MEM_CMD_RD` -> an implicit `logic_net` with no file, the definition cont_assign shared): a Surelog binding
   defect across per-file compilation units; following it means inventing a net slang does not have. Rows convert
   only with a model of which `$unit` names Surelog's file units leave unresolved (UhdmExporter / ModuleEmit).
3. **cfg_func_width_loop d/t** `line(3)`: the evaluator's formal-typespec stamp on a parameter actual (ParamEmit,
   ground A) and the kept `q::maxw(M)` call (ModuleEmit emitContAssigns: r11u196's law
   evalFuncCastMemberKeepsCall191 must learn a package localparam's member read reached through a callee's `for` /
   `if`). Sites and the golden objects: section 3e.
4. **struct_param_func_config d/t** `fullname(5)`: the evaluator's struct copy named through the chain root
   (ParamEmit makeParamTs `memberScope`, ground A; golden holds five differently named copies of `cfg_t.u`).
5. **r11u199 N6** (c06, DIVERGENT): the elaborated `$signed` (from `signed'(...)`) takes the net's typespec in
   golden; ModuleEmit's net-declaration-assignment emission. **N5** (x06, DIVERGENT) is a Surelog defect (the
   reference netlist is the wrong one). **N2** (`K::V` bound spanning `K::`, ground A, another ExprEmit site than law
   pkgQualBoundSpanQualifier192), **N3**, **N4**: not reached. **N8** faces w1 / w2 converted here.
6. The signing grid's judge-visible face: golden marks a `bit signed` / `logic signed` / `reg signed` VARIABLE
   `vpiSigned` (s01, s04, s08 stage 1), ours does not; no corpus row carries it.
7. The class-in-module neighbours: k02 (a module type parameter feeding the class), k04 (r11u194's N2: a
   package generic specialized at module scope, golden `p::box` spanning `p::`), k06 / k08 (value parameters in a
   module-local generic's body).
8. The interface-array neighbours: i03 (an element member read `o[1].d[0]` in an assign), i04 / i11 (a non-modport
   array port's typespec), i07 (a single element `oa[1]` as the actual): all stage 1, identical in both binaries.
9. The generate-block initializer neighbours: a module-port reference (golden unbound) and a module-parameter
   reference (golden keeps the ref_obj) in a generate-block variable's initializer, stage 1.


## 11. Files

* [law_typeemit.patch](law_typeemit.patch), [law_exprstmt.patch](law_exprstmt.patch): the laws (git diffs of `src/`
  against `a015c911`).
* [cases/](cases/): B (generate `$bits`), I (interface-array ports), K (classes in modules), L (split-line implicit
  ports), M (multi-dimensional packed ports), N (`new[...]` sizes), P (evaluator struct copies), Q (positional
  actuals), S (signing keyword), T (class typedef returns), U (reduced bounds), V (generate-block initializers).
* [drivers/](drivers/): `env.sh` (pins + fence), `case.sh` (judge one case), `grid.sh`, `rowrun.sh` (re-run one
  corpus row-mode of the reference sweep), `spantab.py` (order-blind span table of two dumps), `dscase.py` (the
  downstream gate's `one()` on a case), `census.sh` + `censum.py` (the firing census), `bvmirror.sh`, `det.sh`,
  `uvmdist.sh`, `attribution.sh`.
* [evidence/](evidence/): `grid.tsv`, `signspan.txt`, `census/` (the frozen prediction, the attribution filter),
  `sweeps/` (the gate summaries, the movers, canaries), `downstream/`, `determinism/`.
