# r11u175uvm: the UVM families decoded and scratch-verified (analyst pass, measurement only)

**Base.** `e3f14d0a` (branch matrix-1.87; called NEWHEAD below). Nothing under `src/`, `scripts/`, `results/`,
`tests/` or `third_party/` is edited by this directory's patch (`/tmp/r11u175.patch` adds this directory only). The
laws are delivered as two patch files for the pairs to land, each a `git diff` of `src/` against `e3f14d0a`:

| file | ground | files touched | laws |
|---|---|---|---|
| `law_exprstmt.patch` | A (pair r11u169 / r11u174) | `src/StmtEmit.cpp`, `src/ExprEmit.cpp`, `src/ParamEmit.cpp` | importCloneBodyLocalCopies175 (F2), refFullNameThroughNamedExpr175 (F5), doWhileSpansToCloseParen175 (F7) |
| `law_typeemit.patch` | B (pair r11u171 / r11u176) | `src/TaskFuncEmit.cpp` | externProtoFormalsFromPrototype175 (F4) |

Each patch applies clean alone and together on a fresh `e3f14d0a`, and (checked after pass 169 landed during this
pass) alone and together on `31739f79`. Each compiles alone by construction: `law_exprstmt.patch` declares and
defines its two design-final functions inside its own three files; `law_typeemit.patch` is self-contained. Laws are
written `law <name>` in this README (never with the section sign, so `scripts/law_index.py` does not read this
directory as a landed pass); the source comments in the patches carry the section signs for the landing.

Switches (every law droppable alone; one switch for the whole pass):

| switch | law | family |
|---|---|---|
| `R11U175_MULT_OFF` | importCloneBodyLocalCopies175 | F2 |
| `R11U175_FSPAN_OFF` | externProtoFormalsFromPrototype175 | F4 |
| `R11U175_FULLNAME_OFF` | refFullNameThroughNamedExpr175 | F5 |
| `R11U175_ESPAN_OFF` | doWhileSpansToCloseParen175 | F7 |
| `R11U175_TDRELOC_OFF` | (not used: F3 has no law, see F3) | F3 |
| `R11U175_OFF` | all of the above | |

`R11U175_OFF=1` on the law binary writes the pristine bytes: 204 of 204 databases identical (the 43 cases of
`cases/` and the 161 probe cases the laws move; `evidence/switch_all_off.txt`, `drivers/switches.sh`).

## Binaries, frozen `chmod 555` in `/tmp/r11u175_bin` before any measurement

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `d622e6b088b1b2320dc26ba858aac9a2` | the main tree's `build/slang-uhdm` at e3f14d0a; the worktree's own system-deps `-j 2` build (`slang-uhdm.wt`) is byte-identical |
| `slang-uhdm.law10` | `28fcbb00c6cc219bd87e2e277611aa78` | e3f14d0a + both patches (the final law binary; every law measurement below) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's (not changed: no comparator defect found) |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | `tools/probe/r11u165map/drivers/strictcmp_x.cpp`, map 8's record-dump variant (the census) |
| `predict175` | built by `drivers/cc175.sh` | `drivers/predict175.cpp`, the byte-mover predictor |

Every `cmds.txt` of both gate sweeps names its binary: 3273 of 3273 `slang:` lines name `/tmp/r11u175_bin/slang-uhdm`
(pristine sweep `/tmp/r11u175_swP`) and 3273 of 3273 name `/tmp/r11u175_bin/slang-uhdm.law10` (law sweep
`/tmp/r11u175_swL`; same-length workdir names).

**The fence.** The four slang-fenced tests are never named here. The gate sweeps ran every row as the gate mandates;
nothing else touched a fenced test: every driver reads `$FENCED` from RESUME.md and refuses to run without four
names (`drivers/env.sh`); the byte comparison ran on hard-link mirrors that leave the 8 fenced row-mode databases out
(`drivers/bvmirror.sh`, `fenced_skipped=8`); the predictor listed 6647 databases with the 8 fenced ones excluded by
word boundary (`drivers/predict175.sh`); gdb was not used (every rule below was pinned by golden cases, not a debugger).

## 0. The census at NEWHEAD (which families shrank)

The r11u172 census (map 8's analyzer and keys, `drivers/uvmcensus.py` + `drivers/uvmfamilies.py`) re-taken on the
five UVM rows' default databases at NEWHEAD, analyzer tool-verify ok on all five
(`evidence/uvm/families_newhead.txt`, `census_newhead_rank.csv`, `census_newhead_first10.txt`):

| family | at 2dcbc596 (r11u172) | at NEWHEAD e3f14d0a | after this pass's laws |
|---|---|---|---|
| F2 object multiplicity | 47,650 | 48,573 | **23,489** |
| F1 preprocessor location model | 35,866 | **720** (pass 168 landed r11u166) | 720 |
| F4 formal / typespec / bound spans | 19,711 | 19,697 | **3,513** |
| F5 reference full names | 19,445 | 19,445 | **12,516** |
| F6 file facets | 11,817 | 11,817 | 12,376 |
| F7 expression spans outside the pp model | 12,768 | **4,986** (pass 168) | **1,863** |
| F3 typedef relocation spans | 1,045 | 1,045 | 1,095 |
| F8 names | 732 | 732 | 726 |
| F9 value / order / depth | 363 | 363 | 292 |
| **all** | **149,397** (504 clusters) | **107,378** (433) | **56,590** (322) |

Pass 168 shrank F1 (35,866 -> 720) and F7 (12,768 -> 4,986: N0118 5,329 -> 149, N0191 1,540 -> 0); every other
family was unchanged at NEWHEAD. The rows' strict cells at NEWHEAD equal the committed baselines (MiniAmiq
`file(46)`, SeqDriver `file(46)`, SimpleUVM `fullname(62)`, Scoreboard `fullname(62)`, BuildUVMPkg `line(94)`).

The growth of F6 (+559) and F3 (+50) under the laws is confined to MiniAmiq and SeqDriver, the two rows where the F2
law adds the importer clones' missing copies: a copy golden holds and ours did not was counted as one missing
object (F2); present now, it carries the same pre-existing facet error its home object has (N0210 typespec_member
file 3528 -> 4063, N0571/N0630/N0648 ref_typespec full names under typespec_member, N0043 struct span 286 -> 336;
per-row split in `evidence/uvm/census_law_rank.csv`). The order-blind distance falls on every row (section 6).

## F2. Object multiplicity: the importer clones' body locals (ground A) -- LAW

**Heads (NEWHEAD).** N0500 array_var / N0489 class_var / N0501 bit_var under `begin`, N0564 class_var under
`assignment` (15,908 objects, MiniAmiq and SeqDriver only, every one inside a package that wildcard-imports
uvm_pkg: svaunit_pkg, adpcm_pkg):

    MiniAmiq golden #68630  3 begin      svaunit_pkg::uvm_default_factory::print  uvm_factory.svh 1524:3-1524:58
             golden #68631  4 string_var key  ...::print::key                      1523:10-1523:13
             golden #68634  4 class_var  (unnamed) ...::print                      1524:27-1524:49   <- array element
             golden #68637  4 array_var  sorted_override_queues ...                1524:27-1524:49
             ... qs, tmp, id, obj; then #68675 4 foreach_stmt
    ours:    begin -> foreach_stmt directly (the same begin, no variables walked under it)

**Decode.** Surelog compiles a body declaration ONCE and lists the one object three times.
`CompileHelper::compileDataDeclaration` (third_party/Surelog/src/DesignCompile/CompileStmt.cpp:1170, :1198, :1251)
pushes each declared variable -- for an unpacked-array declarator the ELEMENT variable first (`:1198`), then the
array_var (`:1251`) -- onto the enclosing scope's `Variables`, which for a multi-statement subroutine body is the
wrapper `begin` `compileFunction` / `compileTask` mint (`:2488`, `:2050`); the same object is the declaration
assignment's `Lhs`, and `compileFunction` also pushes it onto the function's `Variables` (`:2520`; `:2103` for a
task). In the HOME listing the three lists share one object, so the listener walks it once (under the function).
A wildcard IMPORTER's listing is `UHDM::clone_tree` of that function (`CompileHelper::importPackage`,
third_party/Surelog/src/DesignCompile/CompileHelper.cpp:319-323, `ElaboratorContext(&s, false, true)`), and
`function::DeepClone` / `scope::DeepCopy` (third_party/UHDM/templates/clone_tree.cpp:458-610, the generated
`begin::DeepCopy`) copy each LIST separately: the function's Variables, the begin's Variables and each assignment's
Lhs become three distinct copies, each parented at the clone that lists it -- so golden's importer begin lists
`key, <element of arr>, arr, h, id` as objects distinct from the function's (case `f2/c02_extern_import`: element
copy full name `p2::base::print`, parented at the begin). Class elaboration, module instances, module imports and
in-body methods do not produce distinct begin copies (cases `f2/g01`, `g04`, `g07`, `h01`-`h05` STRICT_EQUAL at
pristine): only the importer's clone does.

**Law importCloneBodyLocalCopies175** (`R11U175_MULT_OFF`, StmtEmit.cpp + a design-final hook at the head of
`drainPaNameCopySrc38` in ParamEmit.cpp). In an importer clone (`pkgImportCloneEmit`, both halves) the wrapper
begin's `Variables` and every declaration assignment's `Lhs` (the subroutine body's and a written block's) are
COPIES of the listed objects made with Surelog's own call (`UHDM::clone_tree`, `ElaboratorContext(&s, false, true)`,
typespecs uniquified), the element copy named by the begin. The copies are made DESIGN-FINAL: a copy made while the
body is emitted missed later drains (a null class_defn link on SeqDriver's `uvm_seed_map` handle, a folded range
bound, both uhdm-cmp differences, measured and fixed by moving the copy to the drain).

**Grid** (`cases/f2`, 15 cases x both producers): converts `g06_init_decl_import` (with F4); `c02`, `g05`, `g08`
lose their walk divergence and keep one residue each (R-F2a below); controls `c01`, `g01`, `g04`, `g07`, `h01`-`h05`
unchanged EQUAL; `h06`, `h07` (a FREE package function imported into a package) are NOT_EQUAL at the judge before
and after (a different, pre-existing difference; not modelled). Switch matrix: `evidence/grid_switch_matrix.txt`.

**Census.** N0500 4,681 -> 0, N0489 4,539 -> 0, N0501 3,058 -> 0, N0564 3,630 -> 30. **Rows:** MiniAmiq,
SeqDriver (both modes; strict `file(46)` -> `file(43)` together with F4/F5/F7). **Probe:** 6 conversions involve it.

**Residue (F2, 23,489).** N0151 ref_typespec under parameter 3,810 / N0262 constant under param_assign 2,814 /
N0182 typespec_member 1,924 (the import-parameter copies, ground B, `importParamCopy82` /
`classImportParamStamped82` / `cloneStructMemberBareTdAlias207`: not decoded this pass); N0134 array_typespec
3,110 + N0408 ours-only unsupported_typespec 1,526 + the F5 twins N0490/N0491 (below): the importer clone's foreach
loop variable -- golden reaches, from the clone's loop variable, an object that carries the HOME package's full
name and a resolved index typespec, where ours mints the § cloneLoopVarShared37 placeholder
(StmtEmit.cpp `declLoopVar`, the `pkgImportCloneEmit || uninstIfaceSubBody218` branch); R-F2a: the element
ref_typespec inside the FUNCTION-level list's array typespec of an importer clone (golden names it by the array,
ours leaves it unnamed; `c02` #50), ours emits that list fresh with a shared typespec (pre-existing, 1 object per
array local per clone view).

## F4. Formal / typespec / bound spans: the extern prototype listing (ground B) -- LAW

**Heads (NEWHEAD).** N0093 io_decl under function 4,607 / N0156 under task 1,949 (908 of 909 MiniAmiq ones in a
class_defn listing), and their subtrees: N0069 string_typespec 1,739, N0111 constant under io_decl 1,980, N0094
constant under range 550, most of N0072 class_typespec / N0039 int_typespec:

    MiniAmiq #146777 io_decl name  golden 76:31-76:35 (uvm_component.svh: `extern function new (string name, ...)`)
                                   ours   1728:37-1728:41 (the out-of-body definition)

**Decode.** The class body's listing of an `extern` method is the PROTOTYPE compile:
`CompileHelper::compileFunctionPrototype` / `compileTaskPrototype` (CompileStmt.cpp:2631 / :2587) run
`compileTfPortList` over the prototype's own port list (`:2711` / `:2619`), and the definition's later
`compileFunction` finds that object already populated and returns (`if (func->Io_decls() || func->Variables() ||
func->Stmt()) return true;`, `:2374`; `:2006` for a task). So every io_decl of the class-body listing, its default
constant, its typespec and range bounds, and the function's return variable (compiled from the prototype's
`Function_data_type`) sit at the PROTOTYPE's tokens; a constructor prototype's return class_var is never located
(0:0, no file). The package's `C::m` definition listing keeps the definition's formals. Ours built the class-body
listing from the definition's SubroutineSymbol (TaskFuncEmit.cpp, "the formals and return type are the same objects
the prototype declares").

**Law externProtoFormalsFromPrototype175** (`R11U175_FSPAN_OFF`, TaskFuncEmit.cpp): with `protoOf` set, the io_decl
loop iterates `MethodPrototypeSymbol::getArguments()` (same count guard), the return type syntax is the prototype's
`FunctionPrototypeSyntax::returnType` (`retTypeSyn175`, every use in the return block), and the constructor's return
var takes no location.

**Grid** (`cases/f4`, 10 cases): converts `a01_func_default`, `a02_task`, `a03_ctor`, `a04_class_formal`,
`a05_ranges`, `a09_multiline` (+ `f2/g02_extern_pkg`, `f2/g06` with F2); `a08_static_typedef` 19 -> 14 objects
(the rest is F3 + F5-under-F3), `a10_param_class` 8 -> 3 (the type parameter's shared typespec relocated by the
prototype formal: a last-writer rule like F3); `a06_default_proto_only` and `a07_module_class` are NOT_EQUAL at the
judge before and after (golden's definition carries no default where ours inherits the prototype's; a module-scope
extern class -- both pre-existing, not modelled).

**Census.** N0093 4,607 -> 0, N0156 1,949 -> 0, N0069 1,739 -> 0, N0111 1,980 -> 0, N0094 550 -> 0, N0118 149 -> 0
(the io_decl default operations), N0072 3,968 -> 1,051, N0039 2,315 -> 1,231. **Rows:** ApbSlave (both modes;
strict cell `depth(1)` unchanged, order-blind 88 -> 12), BuildUVMPkg, MiniAmiq, Scoreboard, SeqDriver, SimpleUVM.
**Probe:** 59 of the 75 conversions involve it (54 alone).

**Residue (F4, 3,513).** N0072 / N0039 remain where the typespec is a TYPE PARAMETER's or a class typedef's shared
object relocated by its last formal writer (`a10_param_class`: `type T = int` read at the prototype's `T` token
3:30, ours `int` at the specialization 10:10) -- the F3 last-writer mechanism on a type parameter; N0165 range under
io_decl (`assocIoRange9`), not decoded.

## F5. Reference full names (ground A) -- LAW (three shapes) + decode (loop variables)

**Heads (NEWHEAD).**

    N0174 ref_obj under io_decl:          golden uvm_pkg::uvm_report_info::verbosity::UVM_MEDIUM
                                          ours   uvm_pkg::uvm_report_info::UVM_MEDIUM
    N0095 ref_obj under method_func_call: golden uvm_pkg::uvm_default_factory::create_object_by_name::wrapper.create_object::name
                                          ours   uvm_pkg::uvm_default_factory::create_object_by_name::name
    N0052 ref_obj under bit_select:       golden uvm_pkg::uvm_create_random_seed::seed_map.seed_table[type_id]::type_id

**Decode.** Surelog sets no vpiFullName on these references (CompileExpression.cpp sets one only for special
spellings: `$root`, package-scoped names, the select branches); the reader synthesises it from the vpiParent chain
(UHDM `BaseClass::ComputeFullName`, third_party/Surelog/third_party/UHDM/templates/BaseClass.cpp:100): every named
ancestor except a call, and except the hier_path / bit_select a reference sits DIRECTLY in; `::` once a package or
class is on the chain. So a formal's default reads through the io_decl, a call argument through the hier_path the
call ends, a select index through the hier_path the select ends. Measured positions (`f5/e07_bitsel_positions`):
the name goes through the path only when the select / call is the hier_path's LAST element (`m.w[k]` -> `...::m.w[k]::k`;
`ms[i].w[0]` -> `...::i`, `m.lfs[j].v` -> `...::j`); LocalScopeHierPath's middle select
`path.slices[j].spath` confirms it in the default mode, and reads the chain name under `-elabuhdm` (testflags: R-F5a).

**Law refFullNameThroughNamedExpr175** (`R11U175_FULLNAME_OFF`, ExprEmit.cpp + the ParamEmit design-final hook): a
ref_obj inside a function/task that is an io_decl's default (the io_decl read as its parent; ours leaves the default
unparented), or the argument of a method_func_call / the index of a bit_select that is its hier_path's LAST element,
takes UHDM's chain name when ours's name is that name with the ancestors dropped (same root, same leaf). Not in a
module / generate scope (probe `r10earl_repro/tj` measured golden `work@tj.gen_a[0].k`: the first cut regressed it,
this fence restores it).

**Grid** (`cases/f5`): converts `e01`, `e02`, `e03`, `e05`; `e07` unchanged (controls); `e04` is F3; `e06` is the
loop-variable decode below. **Census.** N0095 4,901 -> 0, N0174 1,241 -> 0, N0052 714 -> 0, N0175 1,060 -> 1,060
(middle selects: golden's `args[i].substr::i` under hier_path `args[i].len` is a reference object SHARED by two
paths in golden -- its first parent names it; not modelled). **Rows:** BuildUVMPkg, MiniAmiq, Scoreboard, SeqDriver,
SimpleUVM, SVSwitch (both modes; `fullname(11)` -> `file(9)`, order-blind 127 -> 123). **Probe:** 11 conversions
involve it.

**Decode, no law: N0490 / N0491 (foreach loop variables in importer clones, 3,043).** Golden `uvm_pkg::uvm_has_wildcard::i`
under svaunit_pkg's clone, ours `svaunit_pkg::...`: Surelog's foreach branch mints the loop ref_var and queues it for
`lateTypedefBinding` (CompileStmt.cpp:563); the name read from the clone is the HOME object's (a clone copies a name
the home already computed, `*clone = *this` in every DeepClone), and the object reached carries a resolved index
typespec (the F2 N0134 twin). Ours reaches the § cloneLoopVarShared37 placeholder (StmtEmit.cpp, ground A). Which
home object golden binds (the def-view `C::m` entry or the class_defn method) was not separated: reported with the
count and the call site, no law.

## F7. Expression spans outside the location model (ground A) -- re-measured + LAW

**N0118 / N0191 at NEWHEAD.** N0191 is 0 at NEWHEAD (pass 168). N0118 is 149 (5,329 at 2dcbc596): constants under
an operation under a class prototype's io_decl default (`int item_priority = -1` in `wait_for_grant`), cleared by
the F4 law (149 -> 0).

**What remained, decoded.** The largest F7 cluster was the do-while span (N0159 285 + N0221 113):

    MiniAmiq do_while  golden uvm_factory.svh 1628:5-1640:37 (`do begin ... end while(m_type_names.next(key));`)
                       ours   1628:5-1628:7 (the `do` keyword)

golden spans from `do` to the condition's closing parenthesis (the end column is the `)` itself), for every body
shape and home (`cases/f7` d1-d5: module initial, module / package function, class method, begin and single
statement bodies).

**Law doWhileSpansToCloseParen175** (`R11U175_ESPAN_OFF`, StmtEmit.cpp `StatementKind::DoWhileLoop`, same-buffer
only). **Grid:** d1-d5 all convert. **Census:** N0159 285 -> 0, N0221 113 -> 0. **Rows:** the four UVM rows +
BuildUVMPkg. **Probe:** 5 conversions involve it.

**Residue (F7, 1,863).** N0326 method_func_call end 224 (uvm_callback_defines.svh macro body: golden ends at the
call's line, ours one line later -- the pp model's territory), N0160 foreach ref_var end 182 (`foreach (this.in_use[i])`:
golden ends after `this`), N0119 bit_select 173 (`x[idx] = new`: golden locates the select at its index expression),
N0224 / N0001 ref_obj columns under hier_path; each ground A, not decoded this pass.

## F3. Typedef relocation spans (ground B) -- DECODED, NO LAW

**Head.** BuildUVMPkg's first ten records at NEWHEAD and under the laws (N0080 x2 struct, N0075 x8 enum), and now
the first ten of MiniAmiq and SeqDriver too (N0144 / N0239 / N0210: the same relocation reaching another file):

    BuildUVMPkg #909 enum_typespec uvm_pkg::uvm_check_e  golden 79053:35-79053:46   ours 60837:4-60840:18
    MiniAmiq    #573 enum_typespec uvm_pkg::uvm_check_e  golden uvm_reg_block.svh 1671:35-1671:46
                                                         ours   uvm_reg_model.svh 180:4-183:18

**Is § tfArgTypedefLastWriter146's decline a Surelog rule or ours? OURS.** Its comment says "a struct typedef and a
method of a class inside a package (the UVM enums) do not move it"; the grid (`cases/f3`, pinned Surelog) says both
move: an in-body class-method formal moves an enum typedef (`t1` 4:37, `t2` with a default), a STRUCT typedef too
(`t5` 4:23); with two classes the name-sorted-LAST class's formal wins (`t3`: `zeta` declared first wins over
`alpha`, the order of Surelog's class multimap); a package-level subroutine written after the class wins over the
class (`t6` 7:20); an extern method's package-level DEFINITION wins over its prototype (`t4` 6:29 in the package
listing). The UVM head agrees: `uvm_check_e` lands on `uvm_reg_block::mirror`'s definition formal
(uvm_reg_block.svh:1671, the last out-of-body writer in include order), not on any in-class prototype. Measured
split still open: `f4/a08_static_typedef` reads the definition (7:37) in the DEF package view and the prototype
(5:47) in the elaborated view, while `t4` reads the definition in the one differing listing.

**Rule (golden follows).** The package aggregate typedef object's span is rewritten by every subroutine formal
typed by the bare typedef name, in compile order -- class bodies first, classes in name order, then the package's
own items in source order (out-of-body definitions included) -- and the last writer wins; the view split above is
the one open term.

**Why no law.** The law must extend 146's writer walk across containers (146 fences to ONE container so that source
order is compile order) with the class-name order and the view split, over uvm_pkg's whole include tree; the view
split is not decoded, and a wrong order moves the typedef to a wrong formal in every UVM row. Count: F3 1,095
objects (BuildUVMPkg 769); site: UhdmExporter.cpp § tfArgTypedefLastWriter146 (ground B, `typedefTs` writer walk),
TypeEmit buildEnumTs / buildStructTs.

## Measurements (gates)

Full `tests/sweep.sh --jobs 3` of both binaries from the worktree, against the committed e3f14d0a baselines
(`evidence/sweep_pristine.log`, `evidence/sweep_law.log`):

| stage | pristine `d622e6b0` | law `28fcbb00` |
|---|---|---|
| probe | regressions=0 conversions=0 changes=0; EQUAL 2697 / STRICT_NOTEQUAL 1390 | regressions=0 **conversions=75** changes=73; EQUAL **2772** / STRICT_NOTEQUAL 1315 |
| surelog (both modes) | 0 / 0 / 0 | regressions=0 conversions=0 **changes=11** (below) |
| uhdm2rtlil (both modes) | 0 / 0 / 0 | 0 / 0 / 0 |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 | **identical csv**, 803 / 66 / 2 / 0; 805 slang-lane databases byte-identical to pristine, 0 movers |

Both sweeps print `law index STALE` first: `scripts/law_index.py --check` reads the section-sign names the laws add
to `src/` (the worktree held the laws while both sweeps ran); the landing regenerates `tests/LAWS.md`.

The 11 surelog changes (every one predicted, section 5):

    BuildUVMPkg default/testflags  differ:line(94)     -> differ:line(69)
    MiniAmiq    default/testflags  differ:file(46)     -> differ:file(43)
    SeqDriver   default/testflags  differ:file(46)     -> differ:file(43)
    SimpleUVM   default/testflags  differ:fullname(62) -> differ:fullname(59)
    Scoreboard  default            differ:fullname(62) -> differ:fullname(59)   (testflags: SLANG_REJECT, unchanged)
    SVSwitch    default/testflags  differ:fullname(11) -> differ:file(9)

No corpus row converts (the UVM rows keep other families). The other rows the brief lists are unchanged
(Scr1SvTests, CovMacro, ApbSlave `depth(1)`, Earlgrey_0_1, ibex_pmp). Canaries (`evidence/canaries.txt`):
`canaries.sh` surelog ok=43 changed=9 (exactly the 9 claimed rows above; pristine ok=52 changed=0), uhdm2rtlil
ok=16 changed=0; `ctcan2.sh` surelog PASS (EXPECT_UNKNOWN=1), uhdm2rtlil PASS (EXPECT_UNKNOWN=6). Grid and probe
conversions by switch: `evidence/grid_switch_matrix.txt`, `evidence/probe_conversions_by_switch.txt` (FSPAN alone
54, FULLNAME alone 9, ESPAN alone 3, MULT alone 3, pairs 6).

## 5. Byte movers, predicted by name first

`drivers/predict175.cpp` read every PRISTINE database (6647 listed, 8 fenced excluded) BEFORE the law sweep's corpus
stages ran and named the databases each law can move (`evidence/predict_pristine.txt`): 13 corpus row-modes and 174
probe databases. `byteverify.sh` (tools/probe/r11v75repro, SELFCHECK=1: 2559 / 2560 flagged, path sets identical)
on the fence-free mirrors: **13 / 2560 movers, exactly the 13 predicted** (ApbSlave x2, BuildUVMPkg x2, MiniAmiq
x2, Scoreboard default, SeqDriver x2, SimpleUVM x2, SVSwitch x2; `evidence/byteverify_corpus.txt`). Probe: 161
movers, all 161 predicted, 13 predicted did not move (the predictor over-approximates;
`evidence/probe_movers_vs_predicted.txt`). The UVM order coin did not show (Scoreboard/default is a predicted mover
anyway). Every mover moves TOWARD golden order-blind: the 148 probe CHANGE / CONVERSION lines 148 TOWARD, 0 SAME,
0 AWAY (`evidence/probe_movers_orderblind.tsv`), the corpus rows below.

## 6. UVM order-blind distance to golden (records, depth dropped; `drivers/uvmdist.sh`, `drivers/obrows.sh`)

| row-mode | pristine ours-not-golden + golden-not-ours | law |
|---|---|---|
| MiniAmiq default / testflags | 16,872 + 38,449 = 55,321 | 12,565 + 19,412 = **31,977** |
| SeqDriver default / testflags | 15,772 + 29,119 = 44,891 | 11,024 + 14,551 = **25,575** |
| SimpleUVM default / testflags | 10,672 + 11,396 = 22,068 | 5,393 + 6,117 = **11,510** |
| Scoreboard default | 9,306 + 10,010 = 19,316 | 4,276 + 4,980 = **9,256** |
| BuildUVMPkg default / testflags | 7,393 + 7,440 = 14,833 | 2,571 + 2,618 = **5,189** |
| ApbSlave default / testflags | 46 + 42 = 88 | 8 + 4 = **12** |
| SVSwitch default / testflags | 74 + 53 = 127 | 72 + 51 = **123** |

## 7. What is left, ranked (objects in the five UVM rows under the laws, `evidence/uvm/families_law.txt`)

1. **F2 23,489** -- import-parameter copies N0151 / N0262 / N0182 (8,548, ground B, not decoded); the importer
   clone's foreach loop variable N0134 / N0408 (4,636, ground A, decoded in part: F5 above).
2. **F5 12,516** -- N0490 / N0491 loop-variable full names (3,043, decoded, no law), N0175 shared middle-select
   references (1,060), N0682 package-parameter ref_typespec names (Scoreboard / SimpleUVM's first ten), the rest in
   `census_law_rank.csv`.
3. **F6 12,376** -- file facets (N0121 / N0144 / N0210: the F3 relocation reaching another file, plus include-file
   members).
4. **F4 3,513** -- type-parameter / class-typedef typespec last writers (N0072 1,051, N0039 1,231).
5. **F7 1,863**, **F3 1,095** (decoded above; the head of BuildUVMPkg, MiniAmiq and SeqDriver), F8 726, F1 720, F9 292.

## 8. Files

- `law_exprstmt.patch`, `law_typeemit.patch`: the laws (src diffs vs e3f14d0a).
- `cases/{f2,f3,f4,f5,f7}/<case>/dut.sv`: 43 single-file cases, judged against the pinned Surelog with
  `drivers/case.sh` (golden cache keyed by content under `/tmp/r11u175_gold`).
- `drivers/`: `env.sh` (pins, `$FENCED` from RESUME.md), `case.sh`, `gridrun.sh` (switch matrix), `switches.sh`
  (R11U175_OFF = pristine bytes), `uvmrun.sh` / `uvmcensus_sweep.sh` / `uvmcensus.py` / `uvmfamilies.py` (census),
  `uvmdist.sh` (order-blind UVM distance, `rev` added), `obrows.sh` / `obprobe.py` / `obcase.sh` (order-blind
  direction per mover), `predict175.cpp` / `predict175.sh` / `cc175.sh` (mover predictor), `bvmirror.sh` (fence-free
  byte-verify mirrors), `chain.py`.
- `evidence/`: the census before / after (`uvm/`), sweeps, canaries, byte-verify, predictions, mover directions,
  switch matrix, conversions by switch.
