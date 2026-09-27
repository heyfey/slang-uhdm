# r11u183dec: map 9's shared clusters decoded and scratch-verified (analyst pass, measurement only)

**Base.** `80a1c2af` (branch matrix-1.87, pass 178; called NEWHEAD below). The main tree moved to `804e3b75`
(pass 176, ground B: TypeEmit / ModuleEmit / UhdmExporter / TaskFuncEmit) while this pass ran; the worktree base was
kept. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited by this directory's patch
(`/tmp/r11u183.patch` adds this directory only). The laws are delivered as two patch files for the pairs to land,
each a `git diff` of `src/` against `80a1c2af`:

| file | ground | files touched | laws |
|---|---|---|---|
| `law_exprstmt.patch` | A | `src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp` | 8 (below) |
| `law_typeemit.patch` | B | `src/TypeEmit.cpp`, `src/TaskFuncEmit.cpp`, `src/ModuleEmit.cpp`, `src/UhdmExporter.cpp` | 13 (below) |

Both apply clean alone and together on a fresh `80a1c2af` (`git apply --cached --check` on a read-tree index). On
`804e3b75`, `law_exprstmt.patch` applies clean; `law_typeemit.patch` applies except ONE hunk: the TypeEmit.cpp
prologue (the switch/trace helpers inserted after `namespace slang_uhdm {`), whose context pass 176 changed (it added
the `r11u176Law` / `trace176` declarations there). Every other hunk of the four ground-B files applies with offsets
(ModuleEmit +312..+542, TaskFuncEmit +8): pair B rebases by re-inserting that prologue
(`evidence/law_typeemit_rebased_on_804e3b75.patch` is that rebase, measured in section 7). Each patch compiles alone
(built: `slang-uhdm.lawHA` = A alone, `slang-uhdm.lawJB` = B alone). Laws are written `law <name>` in this README
(never with the section sign, so `scripts/law_index.py` does not read this directory as a landed pass); the source
comments in the patches carry the section signs for the landing. Landing this directory needs `tests/LAWS.md`
regenerated (`python3 scripts/law_index.py`: it indexes every `tools/probe/*/**/*.sv` case); every sweep below
reports `law index STALE` and exits 1 for that reason alone (the worktree's `src/` carries the unlanded laws), which is
why every `SWEEPRC` below reads 1 with `regressions=0` in every stage.

**Instrumentation carried by the patches** (the pairs may drop it at landing): every law calls `tr183XX("<law>")`
when it fires; with `R11U183_TRACE=<dir>` each process writes `<dir>/<pid>.<unit>` (first line `OUT <-o path>`, then
one law name per firing). Unset, nothing is written and the bytes are the law's.

## 1. Switches (every law droppable alone; one switch for the whole pass)

| switch | family (brief item) | laws |
|---|---|---|
| `R11U183_RANGEFILE_OFF` | (a) range constant file / span | assocPromotedBoundAtBracket183, pkgParamFoldOwnTs183, pkgParamElabCaSharesDefFold183, aliasFoldBoundFile183 |
| `R11U183_TSSPAN_OFF` | (b) typespec-copy spans | classPropElemClassTsAtType183 (+`R11U183_PROPELEM_OFF`), foreachAssocLoopVarIdxTs183 (+`R11U183_FEIDX_OFF`), typeParamUseSharesOwnTs183 (+`R11U183_TYPEPARAM_OFF`), paramAggTdLastWriter183 (+`R11U183_PARAMAGG_OFF`), importNetTsToInitEnd183 (+`R11U183_IMPNETTS_OFF`, family h's last head) |
| `R11U183_IFARR_OFF` | (c) size-dimension spans | ifaceArrPortSizeDimAtExpr183, blockSizeDimEndsAtExpr183 |
| `R11U183_UARANGE_OFF` | (d) assoc array typespec shared by foreach | foreachAssocLocalSharesDeclTs183 |
| `R11U183_PATHSPAN_OFF` | (e) path-component spans | macroIfacePathTokSpans183, macroPathTokSpans183, withClauseCloseParenEnd183 |
| `R11U183_BITTSNAME_OFF` | (f) bit typedef alias name | memberBareTdAliasNamedByUse183 |
| `R11U183_UVMCOPY_OFF` | (g) UVM copies and clone naming | classImportParamOwnRefs183 (+`R11U183_IMPCOPY_OFF`), cloneLoopVarHomeObject183 (+`R11U183_CLONELV_OFF`) |
| `R11U183_DEPTH_OFF` | (h) ApbSlave depth | defCloneRefsBindDefListing183 |
| `R11U183_ALIASNAME_OFF` | (a) jeras_union / rp32 alias-of-typedef name (N0938) | aliasOfTdSharedKeepsModName183 |
| `R11U183_OFF` | all of the above | |

`R11U183_OFF=1` on the final law binary writes the pristine bytes: 4234 of 4234 databases identical (every
`tests/probe` case and every case of `cases/`; `drivers/offcheck.sh`, `evidence/switch_all_off.txt`).

## 2. Binaries, frozen `chmod 555` in `/tmp/r11u183_bin` before any measurement

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `3f7b4f737b6020424bc0f734eb0ff64a` | pristine: the worktree's system-deps `-j 2` build of 80a1c2af, = the required `3f7b4f737b60` |
| `slang-uhdm.lawJ` | `532883c0b0b8d1beffedbf3c223f2346` | 80a1c2af + both patches: THE FINAL LAW BINARY (= the worktree's `build/slang-uhdm` rebuilt from the delivered sources) |
| `slang-uhdm.lawHA` | `19a61271093bc2ad98c3cbbb9b422e15` | 80a1c2af + `law_exprstmt.patch` alone (the ground-A patch did not change after it was built) |
| `slang-uhdm.lawJB` | `6534e49f96b9ea8458cc6bc31d2be9be` | 80a1c2af + `law_typeemit.patch` alone |
| `slang-uhdm.c804c` | `a0a474604367dc685c9c2d19a14d1d3d` | the main tree's head 804e3b75 + both patches (the one TypeEmit prologue hunk re-inserted by hand), section 7 |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's (not edited: no comparator defect found) |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | map 9's record-dump variant (`r11u179map/drivers/strictcmp_x.cpp`), the analyzer's input |
| `slang-uhdm.g1` | `0aff6beef9106c20775375e2095d1de6` | pristine with `-g1`, gdb pins on this pass's own cases only |

Earlier law binaries of this pass (`law`, `lawA`, `lawB`, `law2`..`law5`, `lawF*`, `lawG*`, `lawH`, `lawI*`, `c804`,
`c804b`) are the refinement history (section 6); every number below is measured with `lawJ` / `lawHA` / `lawJB`
unless a row says otherwise.

**The fence.** The four slang-fenced tests are never named here. The gate sweeps ran every row as the gate mandates;
nothing else touched a fenced test: every driver reads the names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and refuses to run without four (`drivers/env.sh`, `case.sh`, `row.sh`,
`rowdist.sh`, `onerow.sh`, `census.sh`, `bvmirror.sh`, `uvmdist.sh`, the map's `jobs.py` / `common.fenced()`); the
firing census ran `verify_golden.py --filter '^(?!(<fenced>)$)'` (3265 `slang:` lines, none fenced); the byte
comparison ran on hard-link mirrors that leave the fenced row-mode databases out (`drivers/bvmirror.sh`); gdb ran
only on this pass's own cases (`drivers/pin.sh` refuses any other directory). The predicted-mover list and every
evidence file grep 0 for each fenced name.

## 3. The questions, per cluster family

Each family below answers the brief's questions in order: (1) the heads, (2) the decode (Surelog source cited), (3)
the grid (`cases/<family letter>/`, goldens from the pinned Surelog v1.87 `-parse -nobuiltin -nocache -sv dut.sv`,
judged with `drivers/case.sh` exactly as `scripts/check_probe.py` does), (4) the law and its measurement, (5) what is
left and why. Cluster numbers are map 9's (`tools/probe/r11u179map/cluster_index.csv`), counted with map 9's
analyzer (`r11u179map/drivers/analyze.py` on `strictcmp_x` record dumps of every STRICT_NOTEQUAL corpus row-mode of a
sweep, both modes; `drivers/clus.py`): "pristine" is the analysis of the pristine sweep (97 row-modes), "law" the
analysis of the final law sweep (section 4). The UVM family view (map 9's `uvmcensus9.sh`, the five UVM rows'
default databases) is in section 5.

### 3a. Range constants: N0031 + N0042 (file empty / zero span under a range), with N0938 (switches `R11U183_RANGEFILE_OFF`, `R11U183_ALIASNAME_OFF`)

**Heads (pristine).** N0031 15 row-modes / 496 objects, N0042 13 / 376 (the same objects: a bound constant of a
`range` that golden files and spans and ours leaves `file=''`, `0:0-0:0`). Three shapes, by the chain above the range:
the UVM class-scoped ASSOCIATIVE dimension keyed by a class or typedef name (`bit m[e]`, `uvm_queue m_qs[w]`: 193 of
the UVM objects), the elaborated read of a PACKAGE parameter (ParameterFromPkgInNestedModule,
ParameterFromPkgOnParameterPortList: `parameter logic [7:0][3:0] X` in `p`, read in a module), and the folded bound of
an alias-of-typedef (`typedef imm_i_t imm_l_t`, jeras_union, which also carries N0938: the alias's full name).

**Decode.**
- Associative dimension. Surelog's `CompileHelper::compileRanges` (third_party/Surelog/src/DesignCompile/
  CompileExpression.cpp:3963) has two branches: the keyword form (`[string]`, `[int]`, `paAssociative_dimension`) leaves
  both marker constants unlocated (ours agrees); the REDUCE branch (CompileExpression.cpp:4120-4148), taken when the
  index is a NAME that `compileTypespec` resolves in the elaborated listing, builds `UINT:0` / `STRING:associative`
  and calls `fC->populateCoreMembers(Packed_dimension, Packed_dimension, c)` then `c->VpiEndColumnNo(Column + 1)`:
  both constants and the range are filed and spanned at the `[` token, one column wide. The map's framing ("a
  class-scoped or nested typedef") is the owner chain, not the cause; the cause is the promoted name index.
- Package parameter read. `CompileHelper::getObject` (CompileExpression.cpp:125) copies the declaration constant to
  the reference; `CompileHelper::setRange` (CompileHelper.cpp:5587, the loc-less `logic_typespec` + range clone) runs
  only when the enclosing instance holds a value for the name, which a package parameter never is. And the
  elaborated cont_assign's clone keeps that constant: UHDM `constant::DeepClone` (third_party/Surelog/third_party/
  UHDM/templates/clone_tree.cpp:230) returns `this` for a sized constant outside `uniquifyTypespec`. So the
  elaborated Rhs IS the definition's constant, with the parameter's declared typespec (declaration span, every
  range, located bounds); its reference takes the instance's full name (elaboration writes it last).
- Alias fold. The alias's bound is the target typedef's own constant copied by clone_tree (every location field,
  the FILE included), and the shared alias object keeps the module-scoped name `emitPackage` gave it (golden
  jeras_union `work@test_union.riscv_isa_pkg::imm_l_t` at all four listings).

**Laws.** law assocPromotedBoundAtBracket183 (TaskFuncEmit `makeAssocArrayVar`, B): a NAME index the listing
promotes locates both marker constants at the `[` (one column). law pkgParamFoldOwnTs183 (ModuleEmit
`emitTopPorts`, B): a package parameter's def-compiled constant keeps its declared typespec (no loc-less bare
clone). law pkgParamElabCaSharesDefFold183 (ModuleEmit `emitContAssigns`, B): the elaborated cont_assign's Rhs is
the definition's constant (sized, non-UINT). law aliasFoldBoundFile183 (ParamEmit `emitPackage`, A): the fold keeps
the anchor's file. law aliasOfTdSharedKeepsModName183 (ModuleEmit `emitImportArtifacts`, B): only a per-member
vector clone is re-scoped at the member; the one shared alias-of-typedef object keeps its module-scoped name.

**Grid** (`cases/a`, 52 cases incl. controls): converts a01 a07 a14 (package parameter), b01 c08 c14 c15 c19 c20
(promoted assoc index), e02 (alias fold + name); c17 d01 e03 improve (order-blind 12 -> 4, 7 -> 5, 43 -> 19) and
stay STRICT; a03 a06 a12 (module parameters, an `int` package parameter), b02-b04 b06-b08, c01-c06 c11 c12 are
EQUAL controls and stay EQUAL; b05 c07 c16 r02 stay STRICT unchanged; a02 a04 a05 a08-a11 a13 c09 c13 c18 d02 e01
e04 r01 r03 r04 are judge-unequal at pristine and stay so; c10 is a slang failure in both.

**Rows.** CONVERTED: ParameterFromPkgInNestedModule and ParameterFromPkgOnParameterPortList (uhdm2rtlil, both modes,
`STRICT_NOTEQUAL differ:fullname(7) -> CMP_EQUAL`), jeras_union (uhdm2rtlil, both modes,
`differ:fullname(75) -> CMP_EQUAL`; needs both patches: A alone reads `fullname(15)`, B alone `file(60)`). Fresh
rows: `ParameterFromPkgInNestedModule,default,CMP_EQUAL,,,equal`, `jeras_union,default,CMP_EQUAL,,,equal` (and the
testflags twins). N0031 15 -> 9 row-modes, 496 -> 16 objects; N0042 13 -> 9, 376 -> 16.

**Residue (16 objects, 9 UVM row-modes).** One shape: a class-scoped QUEUE typedef (`typedef T queue_of_element[$];`
uvm_report_message.svh:337, `typedef TYPE types_t[$];` uvm_misc.svh:642) reached through a function's ref_var:
golden's range and its `$` bound are filed and spanned at the `$` token (337:60-61), ours bracketed (59-62) with an
unlocated constant (N0128's other half, same objects). Call site: `UhdmExporter::operator()` near law
classNestedClassTdGroupNoAnchor54 (UhdmExporter.cpp). Not matched: no small case of the shape is judge-equal
at pristine (`cases/a` r01 r03 r04: the class-scoped queue typedef's array_var listing differs in structure; r02,
a type-parameter element, stops at an unrelated `type` head first), so no grid could gate a law; reported with the
count and the call site.

### 3b. Typespec-copy spans: N0043, N0067 / N0068, N0072 / N0103, N0039 (switch `R11U183_TSSPAN_OFF`)

**Heads (pristine).** N0067 / N0068 13 row-modes / 842 objects each (a class_typespec under a ref_typespec, ours
unfiled and zero-spanned: the element of a class-property array `svunit_testsuite list_of_suites[$]`, and the loop
variable of a foreach over an associative array keyed by a class); N0072 / N0103 13 / 7176 and 11 / 1307 (a
class_typespec spanned at the wrong place / unnamed: a method-body local written with a class TYPE PARAMETER, e.g.
ArrayMethodIterator `CB cb;` under `class uvm_callbacks #(type CB = uvm_callback)`, golden `uvm_callback`
10:50-10:62 where ours minted an unnamed class_typespec at the use 14:3); N0039 12 / 4213 (int_typespec spans under
a ref_typespec: formal typedefs relocated); N0043 14 / 745 (a struct_typespec copy spanned at the typedef
declaration where golden reads the LAST subroutine formal written with the type).

**Decode, per typespec kind and container.**
- A typespec object is never "copied with a span of its own choosing": golden's ref_typespec binds either the
  object `compileTypespec` MINTS for the written type at that node (filed and spanned at the TYPE TOKEN of the
  declaration: class-property array elements, CompileType.cpp), or a SHARED object whose span is whatever its last
  writer set. The writers: `compileTfPortList` (CompileHelper.cpp:413) calls `populateCoreMembers(type, type, ts)`
  on the shared typedef object for every subroutine formal (Design/FileContent.cpp:674), so the typedef's one
  object is spanned at the LAST formal in compile order and every listing that binds it reads that span.
- Foreach loop variables: `getSimpleVarFromTypespec` (CompileType.cpp:78) on an array_typespec with an
  `Index_typespec` recurses into the INDEX's actual typespec (CompileType.cpp:219-224): the loop variable of a foreach
  over an associative array is a variable of the declaration's own index typespec OBJECT (class_var over
  `class_typespec (e)` filed at the index, string/int at the index).
- Type parameters: inside a parameterized class, `CompileType` resolves a type-parameter name to the parameter and
  hands back ITS typespec (the default's, named for the default class, spanned at the default token).
- Parameters: a module parameter typed by a module-local packed aggregate typedef lists the typedef's ONE object
  (the module's Typespecs entry); the landed law modAggTfArgLastWriter155 already relocates that object to the last
  formal writer, but `makeParamTs` (ParamEmit) built a separate copy at the declaration for the ELABORATED listing
  (gdb pin on `cases/b/s01`: `buildStructTs` < `makeParamTs` < `patchParamTypespecs` < `emitTopPorts`).

**Laws.** law classPropElemClassTsAtType183 (UhdmExporter `classElemVar`, B; `+R11U183_PROPELEM_OFF`): the class
element of a class-property array is filed and spanned at the written type token. law foreachAssocLoopVarIdxTs183
(StmtEmit `emitStmt` foreach branch, A, and its registration in UhdmExporter `emitAssocDims`, B;
`+R11U183_FEIDX_OFF`): the loop variable takes the declaration's own index typespec object. law
typeParamUseSharesOwnTs183 (TypeEmit `makeTypespec` + the registry in UhdmExporter `emitClassParameters`, B;
`+R11U183_TYPEPARAM_OFF`): a method-body local written with a class-handle type parameter's name binds the
parameter's own typespec, gated to in-body methods of a class none of whose formals is written with any of its type
parameters (a formal would relocate the object: grid t05). law paramAggTdLastWriter183 (ParamEmit `makeParamTs`, A;
`+R11U183_PARAMAGG_OFF`): a parameter typed by a module- or package-local aggregate typedef copies the listed
typedef object's location (the relocated one).

**Grid** (`cases/b`, 15; `cases/d`, 14): converts b/t01 t03 t06 (type parameter), u01-u03 (property element),
d/f01 f02 f06 f09 f10 f11 f13 f14 (foreach loop variable; f01 needs both patches); s01 moves from `line(3)` to the
unrelated `type(1)` (the elaborated cont_assign's folded function call, the next head), s02 (no formal) is the
control and stays EQUAL, s04 (a package formal writer) is already relocated at pristine and keeps its unrelated
`type(1)` head; t02 t04 t05 t07 t08 stay STRICT (t05: the formal-writer relocation the law declines; t07 `col(2) -> col(1)`,
t08 unchanged: the second type parameter defaulting to the first).

**Rows.** CONVERTED: ArrayMethodIterator (surelog, both modes, `differ:name(6)` / `name(16)` -> `CMP_EQUAL`; fresh
`ArrayMethodIterator,default,CMP_EQUAL,,,equal`; needs both patches: A alone `name(5)`, B alone `endcol(1)`).
IMPROVED, not converted: SVSwitch (both modes, `differ:file(9) -> differ:col(8)`), ApbSlave (with family h),
const_cast_signext (u2r, both modes, `differ:line(5) -> differ:type(1)`: every struct_typespec now at the last
formal 19:42-46; the next head is the folded `sext(OP_F)` call golden keeps as a func_call), struct_param_func_config
(u2r, both modes, `differ:line(8) -> differ:fullname(5)`). Cluster counts: N0067 / N0068 13 -> 9 row-modes, 842 ->
450 objects each; N0072 7176 -> 6723; N0103 1307 -> 1259; N0043 14 -> 10 row-modes, 745 -> 717; N0039 4213 -> 4273
(+60: exposure, objects the depth law newly aligns; order-blind distance of every row still falls).

**Residue.** N0072 / N0039 / N0043's UVM faces are the typedef-relocation family F3/F4: the shared typedef object is
spanned at its last FORMAL writer inside class methods and at typespec_member uses (BuildUVMPkg
`m_uvm_factory_type_pair_t` golden 11947:40-65 at a struct member's type token, 13427:55-80 at an io_decl), which
pass 176 (landed on the main tree at `804e3b75`, after this base: "the typedef relocation to class-method formals
completed") models; its interaction with these copies must be re-measured on top of it. N0039's properties are
relocated by the ElaborationStep pass (not decoded here).

### 3c. Size-dimension spans: N0127 / N0128 (switch `R11U183_IFARR_OFF`)

**Heads.** N0127 10 row-modes / 45 objects (an array_typespec whose end column is one past golden's), N0128 10 / 18
(its range's columns); 79 and 69 probe cases (every r10rgg3 / r10rgg4 / r10vrgg3 / r10vrgg4 / r11u115 interface-array
port case).

**Decode.** A SIZE dimension (`p[3]`, `p[N]`, `int q[5]`) is compiled from its `constant_expression` node, not the
bracketed `unpacked_dimension`: the range spans the expression alone and the array_typespec ends where the
expression ends. The RANGE form (`[0:2]`, `[7:0]`) keeps the bracketed span (grid c/i13: a block-local `logic
idx [7:0]` stays EQUAL with the bracket).

**Laws.** law ifaceArrPortSizeDimAtExpr183 (ModuleEmit `makeIfaceArrayPortTs` and the elaborated range in
`emitInstance`, B): an interface-array port's size dimension. law blockSizeDimEndsAtExpr183 (StmtEmit, the
block-item fixed-size array branch, A): a BLOCK-local `int q[5]` (inside `begin ... end`); the function-level and
module-level forms were already right (grid c/i10, i11 EQUAL at pristine).

**Grid** (`cases/c`, 14): converts i01 i06 (interface array ports, B), i08 i09 i12 (block locals in a class method,
a module function and an always_comb, A); i03 moves `endcol(6) -> fullname(2)`; i02 i04 i05 i10 i11 i13 are EQUAL
controls; i07 i14 judge-unequal at pristine.

**Rows.** No row-mode converts alone (the UVM rows carry many clusters). N0127 10 -> 0 row-modes (45 -> 0 objects:
every UVM `int q[5]` block local); N0128 10 -> 9 (18 -> 16). Probe: 60 of the 132 probe conversions fire this law
(every interface-array receiver case of r10rgg3 / r10rgg4 / r10vrgg3 / r10vrgg4 / r11u115, r10rggen7 t4), 4 fire
the block-local law.

**Residue.** N0128's 16 objects are the class-scoped queue typedef range of family (a) (same objects).

### 3d. The associative array typespec a foreach binds: N0142 (switch `R11U183_UARANGE_OFF`)

**Heads.** N0142 12 row-modes / 190 objects: golden lists a `range` (with its bound constants, index and element
references) under an array_typespec where ours lists none. Two faces: the UVM subroutine-local ASSOCIATIVE array
walked by a foreach (golden's ref_var `predecessors` in `uvm_phase::get_adjacent_predecessor_nodes` binds the
declaration's own array_typespec, uvm_pkg.sv 34544:8-31; ours minted a bare rangeless array_typespec in the drain's
fallback), and the unpacked-array PARAMETER of Earlgrey / Rggen (`parameter logic [31:0] InitHash [8]`, the map's
`makeUnpackedArrayParamTs` framing).

**Decode.** The foreach's array reference binds the declaration's typespec OBJECT (as the landed queue branch does), so
it carries every range the declaration compiled; a listing that promoted a NAME index (family a) compiled that
dimension differently, so only a listing that compiled EVERY dimension associatively shares it (grid d/f01).

**Law.** law foreachAssocLocalSharesDeclTs183 (TaskFuncEmit `makeAssocArrayVar`, B): an all-associative local
registers its own array_typespec as the object a foreach over it binds.

**Grid** (`cases/d`): part of f01 f02 f06 f09-f11 f13 (with family b's loop-variable law).

**Rows.** N0142 12 -> 3 row-modes, 190 -> 32 objects (the UVM face cleared). **Residue (32 objects):** the
Earlgrey_0_1 (both modes) and Rggen (default) unpacked-array parameter face: golden materialises 5 objects (range
+ bounds) under the parameter's array_typespec per listing where ours shares the declaration's. Not decoded to a
law: no small case of `parameter logic [31:0] P [N] = '{...}` reproduces it judge-equal (call site ParamEmit
`makeUnpackedArrayParamTs` near law pkgParamTsRef).

### 3e. Path-component spans: N0001, N0061, N0097 (switch `R11U183_PATHSPAN_OFF`)

**Heads.** N0001 14 row-modes / 1941 objects (a hier_path component ref_obj's columns), N0061 12 / 1362 (a
bit_select's columns in a mixed path), N0097 11 / 85 (an array-method call's end column). Rggen carries most
(`` `tie(RIF) `` expanding `RIF.read_data[__i]`).

**Decode.** Every component of a dotted path is spanned at ITS OWN TOKEN, and a selected component's bit_select
from that token through its closing bracket. Inside a macro expansion the path's TEXT offsets are not source
offsets: the base arrives through a macro ARGUMENT (its token in the argument's buffer) and every member is in the
macro BODY buffer, so `exprStart + offset` runs off the argument's buffer (ours 16:30 through the call site's line,
golden 16:30-16:39, the expanded text's columns). The array-method `with ( ... )` clause spans through the clause's
own `)` token (golden ArrayMethodIterator `with ( cb_.get_inst_id )` 19:32-19:90, ours 19:89).

**Laws.** law macroIfacePathTokSpans183 (ExprEmit `emitExpr`, the interface-path branches near law
parensLessCallIsPathRefObj / hpMidSelIdxDecompiled79, A): the first member's own token and the leaf member's token
through its closing bracket, read from the path's SYNTAX (a left-nested `.` ScopedName chain: one token per
component, valid across buffers). law macroPathTokSpans183 (TypeEmit `emitSyntaxExpr`, B): inside a macro
expansion each component's offsets are read inside that component's own name syntax. law
withClauseCloseParenEnd183 (ExprEmit, A).

**Grid** (`cases/e`, 17 incl. controls): converts q05 q06 (macro interface paths), w02 (with clause); q01-q03 q07
p03-p05 p07 p08 EQUAL controls; p01 p02 p06 (an inc/dec operand with a trailing select, below) stay STRICT.

**Rows.** N0001 1941 -> 721 objects (Rggen 522 left), N0061 1362 -> 142, N0097 85 -> 75. Rggen stays STRICT
(`fullname`, other clusters).

**Residue, decoded (grid e/p06, no law).** An inc/dec operand is compiled through the Variable_lvalue branch, so a
TRAILING element select there takes the LVALUE span: golden `count[type_id]++` bit_select 5:5-5:19 (name through
`]`), ours 5:11-5:18 (the index); `seed_map.count[type_id]++` golden ref_obj `seed_map` at the MEMBER token 11:14-19
and the bit_select 11:14-28, ours 11:5-13 and 11:20-27 (BuildUVMPkg `seed_map.count[type_id]++` 8694, SeqDriver's
`param_t.set_transaction_id(sequence_ptr.m_next_transaction_id++)`). The landed law incDecMemberPathIsLvalue124
covers the select-less member path (grid p07 p08 EQUAL); the select face belongs at the plain-select span decision
in ExprEmit `emitExpr` (the `inLhs || inParamInit || firstPos147` choice) and in `emitMixedHierPath`'s keep178v branch
(ground A). Other residue: Rggen's non-macro components (522 objects), BuildUVMPkg's nested select inside a select
index (`top_map.m_regs_by_offset[info.addr[i]]`, golden `info` 75446:46-50 one column left of the token) and the
streaming concatenation operand (`{ >> { rw_access.data }}`, golden ref_obj at the base token 16-25 where ours
reads the member).

### 3f. The bit typedef alias name: N0164 (switch `R11U183_BITTSNAME_OFF`)

**Heads.** N0164 9 row-modes / 209 objects: the Typedef_alias reference of a bit_typespec copy under a struct
member is named bare (`uvm_reg_byte_en_t`) where golden names it through the member
(`uvm_pkg::uvm_pkg::uvm_reg_bus_op::byte_en::uvm_reg_byte_en_t`).

**Decode.** Surelog copies the typedef PER MEMBER and names the copy's alias reference `<member reference full
name><sep><alias>`, the separator following the member reference's scope: `::` in a package listing, `.` in an
importing INSTANCE's listing (`work@top.p::op_t.byte_en.be_t`; MiniAmiq `work@svaunit_vpi_interface.uvm_pkg::
uvm_reg_bus_op.addr.uvm_reg_addr_t`).

**Law.** law memberBareTdAliasNamedByUse183 (TypeEmit `bareScalarTypedefVarTs`, B): the member gets its own copy
(copy vs share is outside the strict contract) whose alias reference is named through the member.

**Grid** (`cases/f`, 10): converts g01-g04 (package listing) and g08 g10 (module importer, the `.` separator);
g05 g07 EQUAL controls; g06 g09 judge-unequal at pristine.

**Rows.** N0164 9 -> 5 row-modes, 209 -> 172 objects (MiniAmiq 30, Scoreboard 72, SeqDriver 20 left). **Residue:** MiniAmiq / SeqDriver formals and variables of
class methods (`svaunit_pkg::uvm_reg_field::predict::be::uvm_reg_byte_en_t`): a formal's typespec copy named through
the FORMAL, a different writer (the io_decl branch, not the typespec_member branch this law reaches); and SimpleUVM's 179
references whose MEMBER reference name is already wrong at pristine (golden `work@env::uvm_pkg::uvm_reg_bus_op::addr`,
ours `work@top.uvm_pkg::uvm_reg_bus_op.addr`: the member reference is named in the last writer's class context).

### 3g. The UVM F2 / F5 remainders: import-parameter copies and clone loop variables (switch `R11U183_UVMCOPY_OFF`)

**Heads (pristine).** N0151 7 row-modes / 3451 objects (golden-only ref_typespec under an imported class
parameter copy), N0262 7 / 1800 (golden-only constant under the copy's param_assign), N0182 5 / 790 (golden-only
typespec_members under an imported struct copy), N0490 / N0491 4 / 3046 and 3040 (a clone's loop variable and its
typespec reference named with the IMPORTER's package, `svaunit_pkg::uvm_has_wildcard::i` for golden
`uvm_pkg::uvm_has_wildcard::i`), N0408 6 / 3052 (ours-only unsupported_typespec under that loop variable), N0134 4 /
1540 (golden-only array_typespec there), N0175 9 / 2098 (a middle-select index reference's full name).

**Decode.**
- Import-parameter copies: the importer's class-parameter entry is a whole `clone_tree` of the home listing entry,
  so its typespec REFERENCE is the copy's own object named by the copy (`s::d1::A`), and the ASSIGN branch's right-hand
  constant is the clone's own too, its typespec reference named by the CLASS (`s::d1`). The typespec itself stays
  shared (canonical). An UNSIZED based literal (`'hf000000`) is cloned from the parameter's UN-adjusted compile
  (golden vpiSize -1, a typespec reference with no actual): not modelled.
- Clone loop variables: every clone view binds ONE object, the HOME package's own compile of the loop variable: it
  carries the HOME name and the typespec the home listing's `lateTypedefBinding` (UhdmWriter.cpp:2576) resolved for
  the ITERATED array: a string formal's string_typespec, a subroutine-local array's array_typespec, and for an
  ASSOCIATIVE array the declaration's INDEX typespec (`getSimpleVarFromTypespec`, CompileType.cpp:219-224: golden
  `class_typespec (w)` at the property's index for `q m_qs[w]`, uvm_default_factory::print's
  `foreach (m_inst_override_queues[i])`); an array the home cannot resolve keeps the placeholder.

**Laws.** law classImportParamOwnRefs183 (ModuleEmit `importParamCopy82` / `importPaCopy82`, B;
`+R11U183_IMPCOPY_OFF`). law cloneLoopVarHomeObject183 (StmtEmit, the `cloneLoopVarShared37` mint, A;
`+R11U183_CLONELV_OFF`): the home name, and the resolved typespec (the index for an associative array, measured on
class / string / int indices only).

**Grid** (`cases/g`, 9): converts k02 (string formal), k04 (queue formal), k07 (class-keyed property in an
out-of-body method; needs both patches: the property registration is ground B); k01 `depth(1) -> line(1)`
(order-blind 44 -> 2); k06 k08 k09 improve order-blind (23 -> 13, 23 -> 9, 33 -> 17) and stay STRICT; k03 k05 as
at pristine.

**Rows.** N0151 7 -> 3 row-modes, 3451 -> 171; N0262 1800 -> 160; N0490 3046 -> 6; N0491 3040 -> 0; N0408 3052 ->
962; N0134 1540 -> 840. The UVM rows' order-blind distance: section 5.

**Residue.** N0151 / N0262: the unsized based literal copy (MiniAmiq `svaunit_concurrent_assertion_details`) and
Scoreboard / SimpleUVM's copies read through `parameter < ref_obj < func_call` (171 objects). N0408 / N0134: a
STRUCT-keyed associative array (UVM `m_mems_by_offset[uvm_reg_map_addr_range]`: binding the index struct_typespec
makes uhdm-cmp unequal, golden lists a struct copy without our elaborated member references, so the law excludes
it) and a class-property FIXED or DYNAMIC array (grid k09: golden binds an unlocated array_typespec; ours has no
object for a class property's array typespec to share). The clone's RETURN variable of an out-of-body class method
keeps the importer's name (grid k08: golden `int_var u::fct::print`, ours `s::fct::print`; call site ParamEmit
`emitImportedPkgClassMethodClones`, where `pkgImportCloneHomePkg` is null for class-method clones). N0182 is pass
176's (landed on the main tree after this base: `cloneStructMemberBareTdAlias207`'s face); N0175 is pass 178's
(the base's) residue, not decoded here: golden names the index reference through the method-call path
(`uvm_pkg::uvm_root::m_do_factory_settings::args[i].substr::i`), ours through the subroutine scope.

### 3h. ApbSlave's depth(1): N0289 (switch `R11U183_DEPTH_OFF`)

**Heads.** ApbSlave both modes `differ:depth(1)`: map 8's svunit_pkg #372 divergence, the walk descending into a
`string_var` (N0289, ours-only) under the ref_obj `svunit_version` read by `svunit_testrunner::report`.

**Decode.** The package's class-method clones of the DEFINITION listing are emitted during the TOP pass (the
class_defns exist only then), so the package-variable map still held the TOP listing's objects. Surelog compiles the
clone in the definition package: its reference binds THAT listing's variable, the definition package's own
string_var, which the walk has visited before the method (so golden lists no copy there); ours bound the elaborated
one and the walk descended into it.

**Law.** law defCloneRefsBindDefListing183 (ParamEmit `emitPackageClassMethodClones`, A): while the definition
listing's clones are emitted, the package-variable map points at the definition listing's variables (restored
after).

**Grid** (`cases/h`, 16): converts h05 h06 h08 h10 h11 h12 h15; h01-h04 h13 h14 EQUAL controls; h07 h16
judge-unequal and h09 a slang failure at pristine, unchanged.

**Rows.** ApbSlave both modes `differ:depth(1) -> differ:file(36)` at this base: the walk no longer diverges
(index-aligned walk: pristine diverged at record 372, the law's walk never does), order-blind distance 88 -> 76
(`drivers/uvmdist.sh`). N0289 7 -> 4 row-modes (15 -> 12 objects: MiniAmiq / SeqDriver `values` / `args`
string_var under `hier_path(values.size)` and a `delete` call, the same binding in an importer's clone, not
modelled).

**What was left on ApbSlave, and its last head decoded.** The fresh strict head at this base is the extern methods
of `svunit_base` listed at their out-of-body definition (`io_decl name` 59:34, golden the prototype's 43:30; the
class_var of `new` filed where golden is unlocated): exactly pass 176's extern-prototype law, landed on the main tree
after this base. Composed with it (section 7) the next and last head was two objects: the module's re-created
typespec of an imported package variable (`logic_net svunit_version` in `apb_slave_unit_test`), golden
`string_typespec` 29:9-29:92 where ours read 29:9-29:15. Grid h11-h13 decode it: when the package variable has an
INITIALIZER, the importing module's re-created typespec (CompileHelper::importPackage copies the package's signal
into the module and the typespec is re-compiled there) runs from the type token to the END of the initializer
(`const string ver = "v1.0 long text";` 2:9-2:38, `string ver = "v1.0";` 2:3-2:22, `int cnt = 3;` 3:3-3:14,
`int cnt = f();` 3:3-3:16); without one it is the type token alone (h13, EQUAL at pristine), and a CLASS handle's
typespec is always the class name's token (h14 `c h = null;` 3:3-3:4: compileTypespec's own mint for the name; the
first draft of this law extended it and the order-blind check caught the one probe case of the shape,
r10uvm226repro/grid226/a11_nested). law importNetTsToInitEnd183 (ModuleEmit
`emitImportedPkgVarNets`, the non-typedef branch, B; switch `R11U183_TSSPAN_OFF` / `R11U183_IMPNETTS_OFF`) converts h11
h12 h15 (16 of the 132 probe conversions fire it), and ApbSlave reads STRICT_EQUAL (uhdm-cmp rc 0, 3678 objects) in both modes on the composed binary.

## 4. The gate sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs)

Every `cmds.txt` names its binary: 3273 of 3273 `slang:` lines name the sweep's binary in each of `/tmp/r11u183_swP`
(pristine), `/tmp/r11u183_swU` (lawJ, both patches), `/tmp/r11u183_swR` (lawHA, A alone), `/tmp/r11u183_swV` (lawJB,
B alone). `GOLDEN_DEFER` unset; the harness reports `golden cache: 3273 of 3323 runs served from the cache` in every
sweep, the pristine one included. Logs (progress lines dropped): `evidence/sweeps/sweep_{P,U,R,V}.log`.

| stage | pristine (swP) | both patches (swU, lawJ) | A alone (swR) | B alone (swV) |
|---|---|---|---|---|
| probe EQUAL / STRICT_NOTEQUAL of 4087 | 2814 / 1273 | **2946 / 1141** | 2821 / 1266 | 2936 / 1151 |
| probe vs golden_probe.csv | reg 0 conv 0 chg 0 | **reg 0 conv 132 chg 102** | reg 0 conv 7 chg 14 | reg 0 conv 122 chg 93 |
| surelog vs golden_surelog.csv | reg 0 conv 0 chg 0 | **reg 0 conv 2 chg 13** | reg 0 conv 0 chg 11 | reg 0 conv 0 chg 13 |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | reg 0 conv 0 chg 0 | **reg 0 conv 6 chg 4** | reg 0 conv 0 chg 6 | reg 0 conv 4 chg 2 |
| downstream (871) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **803 / 66 / 2 / 0** | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0 |

(`only-fresh=0 only-committed=0` in every comparison; the corpus status histograms are unchanged except the
converted rows: surelog default 450 -> 451 CMP_EQUAL, testflags 447 -> 448; uhdm2rtlil 783 -> 786 both modes.)

**Corpus row-modes, both patches (lawJ), quoted from the fresh sweep's comparison.**

- CONVERTED (surelog): `ArrayMethodIterator default STRICT_NOTEQUAL differ:name(6) -> CMP_EQUAL`,
  `ArrayMethodIterator testflags STRICT_NOTEQUAL differ:name(16) -> CMP_EQUAL` (families 3b + 3e); fresh row
  `ArrayMethodIterator,default,CMP_EQUAL,,,equal`.
- CONVERTED (uhdm2rtlil): `ParameterFromPkgInNestedModule` default / testflags `differ:fullname(7) -> CMP_EQUAL`,
  `ParameterFromPkgOnParameterPortList` default / testflags `differ:fullname(7) -> CMP_EQUAL` (family 3a),
  `jeras_union` default / testflags `differ:fullname(75) -> CMP_EQUAL` (family 3a + N0938); fresh rows
  `ParameterFromPkgInNestedModule,default,CMP_EQUAL,,,equal`, `jeras_union,testflags,CMP_EQUAL,,,equal`.
- CHANGED, every one an improvement (order-blind distance down, or the walk no longer diverging earlier):
  ApbSlave d/t `depth(1) -> file(36)` (walk divergence gone; 88 -> 76), SVSwitch d/t `file(9) -> col(8)` (123 ->
  119), BuildUVMPkg d/t `line(69) -> line(68)` (13143 -> 12663), MiniAmiq d/t `file(26) -> file(74)` (36021 ->
  26247), SeqDriver d/t `file(26) -> file(74)` (29571 / 29573 -> 23251), SimpleUVM d/t and Scoreboard d
  `fullname(42) -> fullname(102)` (17226 -> 16036, 15462 -> 14427), const_cast_signext d/t `line(5) -> type(1)`
  (20 -> 12), struct_param_func_config d/t `line(8) -> fullname(5)` (158 -> 138). The strict COUNT grows on the four
  UVM rows because the walk now diverges later (index-aligned walk: MiniAmiq record 2450 -> 10107, SeqDriver 2433 ->
  10090, SimpleUVM 2484 -> 10177, Scoreboard 2492 -> 10185; `drivers/divergence.py`,
  `evidence/sweeps/walk_divergence.txt`): more objects are compared before the walk stops, not more objects wrong.
- Per ground: A alone converts nothing on the corpora (ArrayMethodIterator `name(6) -> name(5)`, jeras_union
  `fullname(75) -> fullname(15)`); B alone converts the two ParameterFromPkg rows (4 row-modes); ArrayMethodIterator
  and jeras_union need BOTH patches.

**Probe.** 132 conversions and 102 changes, 0 regressions; every one of the 234 moved cases is BETTER (229) or SAME
(5: r10uvm207repro g207_c_share / g207_e_head / g207_f_home / g207_h_foreign, r10uvm211repro g211_d_noimport, whose
strict counts fall with the order-blind distance unchanged: walk-order and depth only) by the order-blind distance
against its golden (`drivers/chgdist.py`, `evidence/probe_change_obdist.txt`); 0 WORSE. By family (the laws that
fire on each converted case, `evidence/probe_movers_laws.tsv`; a case may fire several): ifaceArrPortSizeDimAtExpr183
60, classPropElemClassTsAtType183 31, importNetTsToInitEnd183 16, foreachAssocLoopVarIdxTs183 13,
defCloneRefsBindDefListing183 10, classImportParamOwnRefs183 9, pkgParamElabCaSharesDefFold183 4,
foreachAssocLocalSharesDeclTs183 4, blockSizeDimEndsAtExpr183 4, memberBareTdAliasNamedByUse183 2,
assocPromotedBoundAtBracket183 2, withClauseCloseParenEnd183 1, typeParamUseSharesOwnTs183 1,
paramAggTdLastWriter183 1. A alone converts 7 (r10uvm57repro b2_shape / v1_prodcell, r10uvm80repro c2_autokinds /
v5_edges80, r10uvm88repro g88_a2_bound, r10v152repro v152_e_pos, r11u14repro c10), B alone 122, both 132:
r10uvm151repro/g151_a_body, r10uvm21repro/t and r10uvm21repro/t32b_t need both. The probe strict histogram:
`depth` 103 -> 32, `endcol` 194 -> 109, `file` 110 -> 71, `line` 229 -> 289 (the depth and file heads moving on to
their next field).

**Downstream.** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT in all four sweeps; no verdict of the
871 differs from `results/downstream_uhdm2rtlil.csv`. Fresh rows of every uhdm2rtlil row the laws move or fire on:
`ParameterFromPkgInNestedModule,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `ParameterFromPkgOnParameterPortList,IDENTICAL,
NO_GATES,NO_GATES,0,0,,`, `jeras_union,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `const_cast_signext,IDENTICAL,NO_GATES,
NO_GATES,0,0,,`, `struct_param_func_config,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `struct_param_pattern_packing,
IDENTICAL,OK,OK,51,51,,`, `rp32_r5p_alu,IDENTICAL,OK,OK,1332,1332,,`, `rp32_r5p_bru,IDENTICAL,OK,OK,174,174,,`,
`rp32_r5p_mdu,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `rp32_r5p_wbu,IDENTICAL,OK,OK,320,320,,`,
`ibex_wb_stage,IDENTICAL,OK,OK,101,101,,`. No row moves away from IDENTICAL.

**uhdm-cmp.** Every corpus row-mode keeps its status (0 regressions in both corpora); every probe case stays
uhdm-cmp EQUAL (the fresh probe csv holds 2946 EQUAL + 1141 STRICT_NOTEQUAL and nothing else; a judge-unequal case
would read NOT_EQUAL); every grid case keeps its pristine uhdm-cmp verdict (27 NOT_EQUAL / 2 SLANG_FAIL in every
column, `evidence/grid.tsv`).

**Byte movers, predicted by name first.** The firing census (`drivers/census.sh`: the law binary with
`R11U183_TRACE` over both corpora, both modes, `--filter` excluding the four fenced names; 3265 `slang:` lines)
predicted 46 row-modes (`evidence/census/predicted_movers.txt`, frozen `chmod 444` before the law sweep ran;
`evidence/census/census_law.txt` lists the laws per row). `tools/probe/r11v75repro/byteverify.sh` with
`SELFCHECK=1` on fence-free hard-link mirrors of swU and swP (2560 databases each, 8 fenced skipped; path sets
identical; self-check 2559 of 2560 flagged): 42 movers (`evidence/sweeps/movers.txt`), every one predicted; 0
moved-not-predicted; 4 predicted-not-moved (ibex_wb_stage d/t: macroPathTokSpans183 fires with an identical
location; struct_param_pattern_packing d/t: paramAggTdLastWriter183 fires on a copy that is not serialized). The
42: ApbSlave, ArrayMethodIterator, BuildUVMPkg, Earlgrey_0_1, LargeValue2Struct, MiniAmiq, SeqDriver, SimpleUVM,
StructUnsizedVal, SVSwitch, UnionCast (surelog, both modes), Rggen, Scoreboard (surelog default; Rggen testflags is
SURELOG_FAIL and Scoreboard testflags SLANG_REJECT in the baseline and in both sweeps), const_cast_signext,
jeras_union, ParameterFromPkgInNestedModule, ParameterFromPkgOnParameterPortList, rp32_r5p_alu, rp32_r5p_bru,
rp32_r5p_mdu, rp32_r5p_wbu, struct_param_func_config (uhdm2rtlil, both modes). Attributed: the UVM family and
SVSwitch / ApbSlave / BuildUVMPkg / ArrayMethodIterator to the laws their census line names; Earlgrey_0_1,
LargeValue2Struct, StructUnsizedVal, UnionCast and rp32_r5p_* to aliasOfTdSharedKeepsModName183 alone. Those nine
rows' strict cells and uhdm-dump output are identical pristine vs law (the renamed shared alias reference is
reached by neither walk; checked on UnionCast and rp32_r5p_alu: record dumps and dumps identical), their downstream
verdicts IDENTICAL. The UVM 0-or-4-line UINT / vpiDecompile order coin shows as md5 differences between runs of one
binary on BuildUVMPkg / Scoreboard / SimpleUVM (same order-blind distance), never as a status.

**Canaries** (`evidence/sweeps/canaries.txt`): `canaries.sh` on the surelog csv: ok=41 changed=11 (exactly 11 of the
changed row-modes above: SVSwitch, ApbSlave, SimpleUVM, SeqDriver, BuildUVMPkg both modes, Scoreboard default), 7
unknown names (the u2r-only canaries, as expected); on the uhdm2rtlil csv: ok=16 changed=0; `EXPECT_UNKNOWN=1
ctcan2.sh` surelog PASS (ok=58); `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.

**Whole-pass switch.** `R11U183_OFF=1` on lawJ: 4234 of 4234 databases byte-identical to the pristine binary's
(every tests/probe case + every case of `cases/`; `evidence/switch_all_off.txt`).

## 5. The UVM rows: order-blind distance and the family census

Order-blind distance to golden (`drivers/uvmdist.sh`: uhdm-strictcmp record multisets, depth dropped; dist + rev),
pristine swP -> law swU, both modes (`evidence/sweeps/uvmdist_pristine_law.txt`):

| row | pristine | law |
|---|---|---|
| MiniAmiq | 36,021 | **26,247** |
| SeqDriver | 29,571 / 29,573 | **23,251** |
| SimpleUVM | 17,226 | **16,036** |
| Scoreboard (default) | 15,462 | **14,427** |
| BuildUVMPkg | 13,143 | **12,663** |
| ApbSlave | 88 | **76** |
| SVSwitch | 123 | **119** |

Per switch, each set alone on the law binary (`drivers/attribution.sh`, `evidence/attribution_lawJ.txt`, default
mode, every moved row): no switch lowers the distance of any row (no law is net adverse on any row). The shares
(distance added by dropping the law), MiniAmiq: UVMCOPY 9,234 (IMPCOPY 3,548, CLONELV 5,686), TSSPAN 1,100, FEIDX
946, RANGEFILE 172, PROPELEM 126, UARANGE 95, IMPNETTS 24, DEPTH 23, IFARR 14; SeqDriver: UVMCOPY 5,258 (CLONELV 3,782,
IMPCOPY 1,476), TSSPAN 1,356, FEIDX 1,214, RANGEFILE 212, UARANGE 163, PROPELEM 114; BuildUVMPkg: TSSPAN 364, FEIDX 240,
PROPELEM 118, UARANGE 89, RANGEFILE 44, DEPTH 15; ApbSlave: TSSPAN 8 (PROPELEM 4, IMPNETTS 4), DEPTH 4. (Order-blind
distance does not see a full-name change on an in-copy reference: the comparator prints those as `<in>name`;
BITTSNAME's gains are measured by the census below.)

The family census (map 9's `uvmcensus9.sh` over the analyzer's jsonl, the five UVM rows' default databases;
`evidence/uvm_families_pristine.txt`, `evidence/uvm_families_law.txt`):

| family | pristine | law |
|---|---|---|
| F2 object multiplicity | 23,489 | **11,866** |
| F4 formal / typespec / bound spans | 19,711 | **18,960** |
| F5 reference full names | 12,480 | **9,481** |
| F6 file facets | 8,306 | **7,508** |
| F7 expression / statement spans | 4,632 | 4,628 |
| F3 typedef relocation spans | 1,095 | 1,095 |
| F8 names | 726 | 790 |
| F1 preprocessor location model | 720 | 720 |
| F9 value / order / depth | 292 | 292 |
| all | 71,451 | **55,340** |

Keys that GREW (`drivers/cengrow.py`, `evidence/uvm_census_grow_shrink.txt`; net -16,111: 495 grown, 16,606
shrunk): SimpleUVM 179 alias references (law memberBareTdAliasNamedByUse183 names them through a member reference
whose own name is wrong at pristine: family 3f's residue); N0100 +126 and N0039 +30 (BuildUVMPkg formal typespec
spans newly aligned by the depth and associative-typespec laws: exposure, the row's distance falls); N0507 +80
(MiniAmiq / SeqDriver: the clone loop variable's resolved typespec named `uvm_reg_addr_t` where golden spells
`uvm_pkg::uvm_reg_addr_t`); N0594 / N0616 +22, N0051 +15, N0164 +13, N0219 +10 and five keys of 2-6 (small
exposures, not attributed alone). The analyzer's alignment has its own coin on Scoreboard: an earlier run of the
same laws read 379 + 379 `get_name` objects "golden-only / ours-only elsewhere" there (the same functions paired at
another position), the final run does not.

The cluster census over every STRICT_NOTEQUAL corpus row-mode (map 9's analyzer, 97 -> 89 row-modes;
`evidence/cluster_census.txt`):

| cluster | row-modes | objects |
|---|---|---|
| N0001 | 14 -> 14 | 1,941 -> 721 |
| N0031 | 15 -> 9 | 496 -> 16 |
| N0042 | 13 -> 9 | 376 -> 16 |
| N0043 | 14 -> 10 | 745 -> 717 |
| N0061 | 12 -> 11 | 1,362 -> 142 |
| N0067 / N0068 | 13 -> 9 | 842 -> 450 each |
| N0072 | 13 -> 11 | 7,176 -> 6,723 |
| N0103 | 11 -> 9 | 1,307 -> 1,259 |
| N0039 | 12 -> 12 | 4,213 -> 4,273 |
| N0097 | 11 -> 9 | 85 -> 75 |
| N0127 | 10 -> **0** | 45 -> 0 |
| N0128 | 10 -> 9 | 18 -> 16 |
| N0142 | 12 -> 3 | 190 -> 32 |
| N0164 | 9 -> 5 | 209 -> 172 |
| N0151 | 7 -> 3 | 3,451 -> 171 |
| N0262 | 7 -> 7 | 1,800 -> 160 |
| N0182 | 5 -> 5 | 790 -> 790 |
| N0175 | 9 -> 9 | 2,098 -> 2,098 |
| N0490 | 4 -> 4 | 3,046 -> 6 |
| N0491 | 4 -> **0** | 3,040 -> 0 |
| N0408 | 6 -> 6 | 3,052 -> 962 |
| N0134 | 4 -> 4 | 1,540 -> 840 |
| N0289 | 7 -> 4 | 15 -> 12 |
| N0938 | 2 -> **0** | 30 -> 0 |

## 6. Refinement history (why the delivered laws differ from this pass's first draft)

A first attempt of this pass (killed at an API limit) left a law set whose binary (`slang-uhdm.law`, md5
`17d2dd26...`) this pass rebuilt from the worktree sources (byte-identical) and re-swept (`/tmp/r11u183_swF`:
probe 2924 EQUAL, 110 conversions / 100 changes / 0 regressions; surelog 2 conversions / 11 changes; uhdm2rtlil 6 /
0; downstream 803 / 66 / 2 / 0: every number of that draft reproduced). The re-audit then found two sub-shapes where
that draft was ADVERSE, invisible to the strict first-field counts and to the order-blind distance of whole rows but
plain in the analyzer's census (MiniAmiq / SeqDriver grew 500 `depth|class_typespec` + 125 `depth|string_typespec`
+ 1,474 ours-only array_typespec + 420 golden-only array_typespec objects; items 1 and 2), and three laws were
added (items 3-5):

1. law cloneLoopVarHomeObject183 bound the WHOLE array_typespec of a class-property associative array (registered
   by the foreach law's ground-B half) where golden binds the INDEX typespec (grid g/k07, g/k08): refined to take the
   index for class / string / int indices; a struct index made uhdm-cmp unequal on MiniAmiq / SeqDriver (the
   `uvm_reg_map_addr_range` key), so it keeps the placeholder (MiniAmiq 26,404 -> 26,285, SeqDriver 23,375 ->
   23,289 order-blind; F9 1,097 -> 292).
2. law memberBareTdAliasNamedByUse183 joined `::` in every listing; an importing instance's listing joins with `.`
   (grid f/g08, f/g10; MiniAmiq / SeqDriver's 421 `fullname|tok:.->::` objects removed, F5 9,902 -> 9,403).
3. NEW law paramAggTdLastWriter183 (family b, N0043's module / package face; const_cast_signext and
   struct_param_func_config improve).
4. NEW law blockSizeDimEndsAtExpr183 (family c, N0127's block-local face; N0127 cleared on every row).
5. NEW law importNetTsToInitEnd183 (family h: ApbSlave's last head once composed with pass 176, found by the
   composition sweep of section 7 and decoded on grid h11-h13). Its first draft (`lawI`) also extended a CLASS
   handle's typespec; the order-blind check of its sweep read ONE probe case worse (r10uvm226repro/grid226/
   a11_nested, 2 -> 4: `c226n top226n = c226n::get226();`), grid h14 confirmed golden keeps the class name's token,
   and the final law excludes class_typespecs (a11_nested byte-identical to pristine again).

Probe conversions: the draft 110, after (1)+(2) 111 (`/tmp/r11u183_swG`), after (3)+(4) 116 (`/tmp/r11u183_swQ`),
after (5) 132 (`/tmp/r11u183_swU`, the final law sweep).

Every gate above is measured on the final binaries only (lawJ, lawHA, lawJB).

## 7. Composition with the main tree's head (804e3b75, pass 176)

The main tree moved to `804e3b75` (pass 176, ground B) during this pass. To tell the pairs how the laws compose,
the main head was exported (`git archive 804e3b75`, no worktree), both patches applied (A clean; B with its one
prologue hunk re-inserted by hand), built with the system-deps `-j 2` config (`slang-uhdm.c804c`, md5
`a0a474604367dc685c9c2d19a14d1d3d`) and put through the full gate from that tree against ITS baselines
(`results/golden_*.csv` at 804e3b75; `/tmp/r11u183_swE`, 3273 of 3273 `slang:` lines naming the composed binary;
`evidence/sweeps/sweep_E.log`). The patches as applied there are `evidence/law_exprstmt_on_804e3b75.patch` and
`evidence/law_typeemit_rebased_on_804e3b75.patch` (the same changed lines as the delivered patches, sorted
line-multiset identical; `git apply --cached --check` clean on a read-tree index of 804e3b75).

| stage | composed on 804e3b75 vs its baselines |
|---|---|
| probe | EQUAL 3017 / STRICT_NOTEQUAL 1070 of 4087; regressions 0, conversions 137, changes 97 |
| surelog | regressions 0, **conversions 4**: `ApbSlave default STRICT_NOTEQUAL differ:depth(1) -> CMP_EQUAL`, `ApbSlave testflags STRICT_NOTEQUAL differ:depth(1) -> CMP_EQUAL`, ArrayMethodIterator d/t `name(6)` / `name(16) -> CMP_EQUAL`; changes 11 (BuildUVMPkg d/t `fullname(24) -> col(23)`, MiniAmiq d/t `fullname(9) -> file(44)`, SVSwitch d/t `file(16) -> col(14)`, SeqDriver d/t `fullname(8) -> col(43)`, SimpleUVM d/t and Scoreboard d `fullname(24) -> fullname(71)`) |
| uhdm2rtlil | regressions 0, conversions 6 (ParameterFromPkgInNestedModule, ParameterFromPkgOnParameterPortList, jeras_union, both modes), changes 4 (const_cast_signext, struct_param_func_config, both modes) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT |

**ApbSlave converts in both modes once these laws sit on pass 176** (its extern-prototype law clears the head
family 3h left, law importNetTsToInitEnd183 the last two objects). The composition adds no regression in any stage.
The corpus change lines there were not re-judged order-blind against a pristine 804e3b75 sweep (none was run); at
this pass's base every one of them is an improvement (section 4).


## 8. Ranked residues (after both patches; objects over every STRICT corpus row-mode, map 9's analyzer)

| rank | clusters (objects) | what is left | ground / owner |
|---|---|---|---|
| 1 | N0072 6,723, N0039 4,273, N0043 717 (F3/F4) | the shared typedef object spanned at its LAST formal writer inside class methods and at typespec_member uses (BuildUVMPkg `m_uvm_factory_type_pair_t`); int/class typespecs of class formals | B; pass 176 (on 804e3b75) models the class-method formal writers: re-measure these on top of it |
| 2 | N0175 2,098 | a middle select's index reference named through the method-call path (`...::args[i].substr::i`) | A (pass 178's residue) |
| 3 | N0408 962, N0134 840 | clone loop variables over a STRUCT-keyed associative array and over a class-property fixed / dynamic array (grid g/k09) | A (+ a B registration of the property's array typespec) |
| 4 | N0182 790 | imported struct copies' members | B, pass 176 |
| 5 | N0001 721, N0061 142 | Rggen's non-macro components (522); inc/dec operands with a trailing select take the lvalue span (decoded, grid e/p06); a select nested in a select index; the streaming-concatenation operand | A |
| 6 | N0151 171, N0262 160 | the unsized based literal's un-adjusted copy; Scoreboard / SimpleUVM parameter reads under func_call | B |
| 7 | N0164 172 (+ SimpleUVM 179 alias references) | a formal's typedef copy named through the FORMAL (the io_decl branch); a member reference named in the last writer's class context | B |
| 8 | N0507 80 | a clone loop variable's resolved index typespec spelled bare where golden package-qualifies it | A |
| 9 | N0142 32 | Earlgrey / Rggen unpacked-array parameter ranges (golden materialises 5 objects per listing) | A (ParamEmit `makeUnpackedArrayParamTs`) |
| 10 | N0031 / N0042 / N0128 16 | a class-scoped QUEUE typedef's `$` bound and range at the `$` token (grid a/r01-r04 judge-unequal) | B (UhdmExporter operator() near classNestedClassTdGroupNoAnchor54) |
| 11 | N0289 12 | the importer clone's reads of the home package's variables (MiniAmiq / SeqDriver `values`, `args`) | A |
| 12 | grid g/k08 | an out-of-body class method's clone RETURN variable keeps the importer's name | A (ParamEmit `emitImportedPkgClassMethodClones`) |

## 9. Files

- `law_exprstmt.patch`, `law_typeemit.patch`: the laws (section 3), `git diff` of `src/` vs 80a1c2af; the
  worktree's `build/slang-uhdm` from both = `slang-uhdm.lawJ`. `evidence/law_exprstmt_on_804e3b75.patch` and
  `evidence/law_typeemit_rebased_on_804e3b75.patch`: the same changed lines rebased on the main tree's head (section
  7), both `git apply --check` clean there.
- `cases/<a..h>/<case>/dut.sv`: 147 cases (the grid: pristine 47 EQUAL, both patches 95, A alone 57, B alone 74;
  `evidence/grid.tsv`, per-case order-blind distance `evidence/grid_obdist.tsv`: 52 better, 66 same, 0 worse, 29 without
  records (judge-unequal or slang failure at pristine)), one directory per family letter of the brief; goldens from
  the pinned Surelog, cached by text md5 in `/tmp/r11u183_gold`.
- `drivers/`: `env.sh` (pins + fence), `case.sh` (judge one case as check_probe does, keep every artifact),
  `grid.sh` (the grid over pristine / lawJ / lawHA / lawJB; `GRIDBINS` overrides), `casefire.sh` (which laws fire on
  each case), `offcheck.sh` (the whole-pass switch byte check), `census.sh` + `censum.py` (the firing census = the
  mover prediction), `bvmirror.sh` (fence-free mirrors for byteverify), `chgdist.py` (order-blind distance of every
  probe mover), `divergence.py` (where the strict walk diverges), `rowdist.sh` + `attribution.sh` (per-switch
  order-blind attribution on corpus rows), `mkrow.sh` + `attrcensus.sh` (per-switch analyzer census of one row),
  `cengrow.py` (census keys that grew / shrank), `uvmdist.sh`, `obdist.py`, `clus.py` + `shapes.py` (map 9's
  cluster ids over the analyzer jsonl), `row.sh` / `onerow.sh` (one corpus row's records / verdict), `pin.sh` +
  `pinrec.sh` (gdb pin of one of OUR objects to its mint; this pass's cases only).
- `evidence/`: `grid.tsv`, `grid_obdist.tsv`, `case_firings.tsv`, `switch_all_off.txt`,
  `probe_change_obdist.txt`, `probe_movers_laws.tsv`, `attribution_lawJ.txt`, `attribution_census_keys.txt` (lawH),
  `cluster_census.txt`, `uvm_families_{pristine,law}.txt`, `uvm_census_grow_shrink.txt`, `census/` (the prediction
  and the per-row firing census), `sweeps/` (the four sweep logs, byteverify, movers, uvmdist, canaries, walk
  divergence).
