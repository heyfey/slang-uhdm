# r11u193: the module/type ground, pair B (refill after pass 188): cast leaves and port-typed cast names in connection actuals, nested-definition chain names, the fill-literal ternary branch and the unsized-constant clone, and the compile order of a package typedef's outside move

Base `6ab9f4fb` (branch matrix-1.87, pass 188). Files of the ground touched: `src/ModuleEmit.cpp` and
`src/UhdmExporter.cpp` (`src/TypeEmit.cpp`, `src/TaskFuncEmit.cpp` and `uhdm_main.cpp` needed nothing). No line of the
sister's files (`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`), of `include/`,
`scripts/`, `results/`, `tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated
(`python3 scripts/law_index.py`).

**r11u191 had not landed at the start** (`tools/probe/r11u191dec` absent), so its clusters (the UVM heads N0228 / N0215 /
N0229, Earlgrey's N1082, BlackBePipeInt's N0923, const_cast_signext, the Scr1SvTests `type(1)` rows, the unsized
package-parameter fold, the UVM queue-range confusion, r11u190's three findings) were left to it; none was touched.

**The fence.** The four slang-fenced tests are written `FENCED=` here and never spelled. Every driver that reads corpus
sources or databases (`drivers/env.sh` and everything that sources it: `case.sh`, `row.sh`, `rowrun.sh`, `grid.sh`,
`predict.sh`, `bvmirror.sh`, `offcheck.sh`, `switches.sh`, `ob.sh`, `rowdist.sh`; `probeheads.py` and `probesub.py` read
the same line themselves; `uvmdist.sh` needs `$FENCED` exported) takes the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed. The predictor skipped the 8 fenced row-mode databases
(`fenced_skipped=8`), the byte comparison ran on hard-link mirrors that leave them out (`fenced_skipped=8`). No fenced
test was run, read or decoded outside the gate sweeps, which dispatch every row themselves; their csv verdicts are the
only fenced facts cited (none moved). gdb was not used.

**Switches.** Every law reads its own `R11U193_<LAW>_OFF` through `r11u193Law` (`UhdmExporter.cpp`, beside
`r11u188Law`); `R11U193_OFF=1` drops all of them. `R11U193_TRACE=<dir>` names every firing (one file per process,
`<dir>/<pid>.193`, first line `OUT <-o path>`, then `<law> <detail>`); unset, nothing is written (the trace run's bytes
equal the sweep's on Earlgrey_0_1 d/t and Rggen d).

| switch | law | file |
|---|---|---|
| `R11U193_CASTLEAF_OFF` | § castOperandLeafElab193 | ModuleEmit.cpp (`emitInstance` connection walk, `emitContAssigns` net-declaration branch) |
| `R11U193_CASTTSNAME_OFF` | § connCastTsNamedByPort193 | ModuleEmit.cpp (`emitInstance` connection walk) |
| `R11U193_SYSARGDEF_OFF` | § connSysCallArgDefNet193 | ModuleEmit.cpp (`emitInstance` connection walk) |
| `R11U193_TERNFILL_OFF` | § caTernFillArmKept193 | ModuleEmit.cpp (`emitContAssigns`, the § srlgCondOpInstValueTernFold9 decision) |
| `R11U193_UNSIZEDCLONE_OFF` | § caUnsizedRhsClonePerInst193 | ModuleEmit.cpp (recorded at the shared slot, `unsizedRhsCloneDrain193`), UhdmExporter.cpp (the drain call) |
| `R11U193_NESTNAME_OFF` | § nestedDefChainName193 | UhdmExporter.cpp (`exportDesign`, design-final) |
| `R11U193_COPYORDER_OFF` | § tfArgOutsideCopyOrder193 | UhdmExporter.cpp (the § tfArgQualOutsideWriter176 mover) |

`R11U193_OFF=1` on the law binary gives the pristine bytes on all 4087 `tests/probe` databases and on all 65 case
directories of this pass ([evidence/offcheck.txt](evidence/offcheck.txt): probe same=4087 differ=0, cases same=65
differ=0). Each switch alone moves only its own law's cases ([evidence/switches.txt](evidence/switches.txt)).

## 1. Binaries (frozen `chmod 555` in `$R193_BIN` = `/tmp/r11u193_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `b912028331d23cb17d13344cd2b44d46` | the main tree's `build/slang-uhdm` at 6ab9f4fb |
| `pris_wt.bin` | `b912028331d23cb17d13344cd2b44d46` | the worktree's system-deps build of 6ab9f4fb (byte-identical) |
| `law.bin` | `338c91ba3c4fde91e5d8843fbb209013` | the patch (the worktree's `build/slang-uhdm` from the delivered sources; `law2.bin` is the same file) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

(`d1` .. `d15` are development builds.) The delivered patch applied to a fresh `6ab9f4fb` worktree (`git apply`, no
warning) builds byte-identical to `law.bin` (`338c91ba…`), and `law_index.py --check` reads current there. Sweeps: `drivers/sweep.sh <bin> <workdir>` = `tests/sweep.sh --jobs 3` with the
pins exported, same-length workdirs `/tmp/r11u193_sw{P,F}` (P pristine, F the law binary, all four stages; an
intermediate `swL` of `d11`, before § tfArgOutsideCopyOrder193, read the same corpus and probe verdicts but ibex_pmp's).
Every corpus `cmds.txt` of swP names `pris.bin` (3273 of 3273 `slang:` lines), every one of swF names `law2.bin`
(3273 of 3273).

## 2. The laws

### 2.1 § castOperandLeafElab193 (`R11U193_CASTLEAF_OFF`) and § connCastTsNamedByPort193 (`R11U193_CASTTSNAME_OFF`) — map N0023, rsp_gen_minimal d/t

**Face** (rsp_gen_minimal, both modes, the whole fail list of the row):

    #1802 fullname
      A: 5 ref_typespec   work@dut.u_rsp_gen.data_i            (the cast `57'(rsp)` in the elaborated `.data_i` actual)
      B: 5 ref_typespec   work@dut
    #1805 depth
      A: 4 ref_obj data_i ...                                  (golden's `rsp` names the already-listed elaborated struct_var)
      B: 6 logic_net rsp  work@dut.rsp                         (ours named the definition's logic_net, listed again)

**Decode.** `CompileExpression.cpp` `case paCast` compiles the cast's operand with `compileExpression(component, fC,
Expression, ..., nullptr, instance)`: no parent expression and the instance, wherever the cast sits. So on the rule of
§ connLeftmostLeafElab139 (the one leaf reached through left operands, ternary conditions and bit-select indices binds
the instance; every other reference goes to the definition's late binding), the leaf of EVERY cast's operand binds the
parent instance's object, in a udp-shaped list too (grid s09, r12). The typespec reference the `paCast` branch mints is
unnamed, so its full name is the parent chain's: the child instance's path and the formal, at any depth of the actual.

**Laws.** (castOperandLeafElab193) the leaves are found on the slang tree (an explicit `ConversionExpression`, `T'(x)`
and `signed'(x)`), matched by start position in the emitted actual, kept on (or re-pointed to) the parent instance's
object, and restored after § connExprBindsNet (whose leading-identifier test reads only the actual's start); the
net-declaration branch (`wire w = 7'(r);`, cases r11, r17) runs the § ndaLeftmostLeafElab139 chain from each cast's operand.
(connCastTsNamedByPort193) a `vpiCastOp` operation's typespec reference in the elaborated actual is named
`<child instance path>.<formal>`. Not modelled: an interface instance's connection (s12: `emitInterfaceInstance` never
runs the § connLeftmostLeafElab139 walk; unchanged).

### 2.2 § connSysCallArgDefNet193 (`R11U193_SYSARGDEF_OFF`)

A system call compiles its arguments under the call, so they follow § connLeftmostLeafElab139 like an operator's
non-leading operands: named `<parent>.<instance>.<formal>.<name>` and bound to the parent definition's object, unless the
argument is a cast's leaf (`signed'(r)` is a `$signed` sys_func_call in both databases: the instance's object). Golden
r15 `.d($signed(r))`: `work@dut.u.d.r` -> the definition's logic_net (ours: `work@dut.r` -> the elaborated variable);
r08 `signed'(r)`: `work@dut.u.d.r` -> the elaborated variable. A whole-actual system call enters the walk too.

### 2.3 § caTernFillArmKept193 (`R11U193_TERNFILL_OFF`) — 22 probe cases of the r10rgg9 grid

**Face** (r10rgg9repro/cells/a_u0 and 21 more, `differ:file(1)`):

    #69 file
      A: 4 constant   dut.sv 8:36-8:38  '0  -1  BIN:0  3
      B: 4 constant   (no location)      0  64  INT:0  7

**Decode.** The pinned producer's reducer (UHDM c7562484, `ExprEval::reduceExpr`, the `vpiConditionOp` branch) hands an
unbased unsized fill literal taken branch (`'0 '1 'x 'z`, a constant of vpiSize -1) back unchanged ("must keep its fill
identity"), so `writeCont_assign` installs the branch's own constant object. § srlgCondOpInstValueTernFold9 transcribed the
older reducer (a loc-less `INT:<v>`, measured on a pre-v1.87 Surelog). The installed object is the NETLIST's own
constant, so every instance folding to it holds that one object (parented at the last): golden p_three lists it under
`u_a` and not under `u_c`. **Law**: the fill taken branch is emitted as the branch expression (located, its own encoding),
shared by every instance of the definition folding to it.

### 2.4 § caUnsizedRhsClonePerInst193 (`R11U193_UNSIZEDCLONE_OFF`) — the r10rgg9 grid's kept ternaries

**Face** (p_ov01 and 9 more, `fullname(3)`): the elaborated kept ternary `(P) ? {2{sig}} : '0` at `.P(1)` names its
references `work@top.u_a.P`, `work@top.u_a.sig`, `work@top.u_a.arr` in golden, `work@m.*` (the shared definition
object) in ours.

**Decode.** `UhdmWriter::writeCont_assign`'s fourth leg: an elaborated cont_assign no earlier leg cloned or simplified
is still cloned (`clone_tree`, `ElaboratorContext(&s, false, true)`, parented at the instance) when its Rhs holds a
constant of vpiSize -1 anywhere (`DetectUnsizedConstant`). The copy is whole (its Rhs objects are fresh, where the cast
leg § castRhsClonePerInst176 re-shares the operands) and nothing names it. **Law**: at the shared slot of a select or
concatenation Lhs (not a cast Rhs, not a delay reference), a Rhs holding an unsized constant is recorded and cloned
design-final with the cast leg; the names the emitter derived from the definition's path are dropped so they read the
instance chain; a stored spelling of Surelog's own (the path element `p[0].v`, cells r11u115 grid/i w01) rides the
clone as `clone_tree` copies it.

### 2.5 § nestedDefChainName193 (`R11U193_NESTNAME_OFF`) — 113 probe conversions of the r11u99..r11u105 nested-module grids (pass 98's residue 3)

**Face**: `logic_net r`: golden `work@sub.work@sub::innermod.r`, ours `work@sub::innermod.r` (98 cases' first record);
typespec references, low-conn and assignment references (`work@sub::innermod::r`), parameters, subroutines alike.

**Decode.** Surelog writes no full name on a nested definition's objects, so the reader synthesizes it
(`BaseClass::ComputeFullName`: every ancestor's name, or its definition name when it has none, joined by `.`), and the
nested definition's module_inst is parented at the outer definition. **Law** (design-final): the nets, variables,
references, typespec references, parameters, hier paths and scopes a nested definition owns (its first design-unit
ancestor, no class or package between) whose stored name starts with the definition's name take the outer chain in
front, and every `::` in the rest reads `.`; a typespec reference named exactly the definition takes the chain too.

### 2.6 § tfArgOutsideCopyOrder193 (`R11U193_COPYORDER_OFF`) — map N0219, ibex_pmp d/t

**Face** (ibex_pmp `file(5)`): golden `ibex_pkg::PmpCfgRst`'s element typespec reads the MOVED `pmp_cfg_t` (ibex_pmp.sv
114:47, the `perm_check_wrapper` formal) while the three `work@ibex_pmp.PmpCfgRst` import copies read the declaration
(ibex_pkg.sv 433:11); ours the reverse.

**Decode.** Surelog compiles the packages (both views) first, then the modules in the definition map's NAME order
(`compileMT_<..., ModuleNameModuleDefinitionMap, FunctorCompileModule>`), then the programs. The move
(§ tfArgQualOutsideWriter176) is `populateCoreMembers` on the elaborated package's own typedef object at the writer's
compile: (a) every reference the elaborated package compiled holds that object (its parameters' elements read moved);
(b) an importer's copy of a package parameter is a `clone_tree` taken when the importer compiles, so a copy in a unit
compiled no later than the writer (a package, the writer itself, a module whose name sorts at or before the writer's)
keeps the declaration span, one compiled later reads moved (golden PM p02 `aaa` writes before `dut` imports: moved; p03
`zzz` after: unmoved). **Law**, after the move: (a) the top package's references to the definition twin take the moved
object; (b) the import copies' references (a parameter located inside the package, in id order) take the twin when the
copy's unit compiles no later than the writer; an array element typespec the copy shares with a later elaboration clone
(the elaborated param_assign's pattern operation, golden reads moved there) gets an array typespec of its own. Three
concurrent runs of the law binary on ibex_pmp and the law sweep give one hash.

## 3. Grids (every case judged by `drivers/case.sh`, golden per text; [evidence/grid.txt](evidence/grid.txt))

| grid | law (first line of every case) | cases | pristine strict-equal | law strict-equal |
|---|---|---|---|---|
| `cases/CL` r01-r18, s01-s16 | § castOperandLeafElab193 (r08, r15, r16, s14: § connSysCallArgDefNet193); every connection cast also § connCastTsNamedByPort193 | 33 | 2 (r02, s11) | 30 |
| `cases/NN` n01-n10 | § nestedDefChainName193 | 9 | 0 | 9 |
| `cases/TF` t01-t05 | § caTernFillArmKept193 (t01, t05 also § caUnsizedRhsClonePerInst193) | 5 | 0 | 5 |
| `cases/UC` u01-u07 | § caUnsizedRhsClonePerInst193 (u05 gen-scope, u07 sized: controls) | 7 | 2 | 7 |
| `cases/PM` p01-p11 | § tfArgOutsideCopyOrder193 | 11 | 0 | 9 |

The five not equal read the same on both binaries: CL/r18 (`wire w = signed'(r)`, stage 1, 17 cmp lines both), CL/s13
(`7'(r + P)`, stage 1, 46 lines both), PM/p07 (a package importer, stage 1, 180 lines both), PM/p09 (an enum typedef
array parameter, stage 1, 32 lines both), CL/s12 (an interface instance's cast: not modelled, `fullname(2)` both).
Shapes covered: casts in left / right / nested / ternary positions, nested casts, selects and part-selects in casts,
concatenations, a port of the parent, positional, udp-shaped, generate scopes (s08, r10), parameterized children (s15),
two levels (s16), net-declaration casts (r11, r17, s11 non-ANSI); nested definitions deep, with functions, parameters,
instances, non-ANSI ports, always blocks, generate blocks, tasks and named blocks, a top holding the nested definition;
fill branches `'0 '1 'x`, nested conditionals, three same instances, a true branch; unsized fill and based literals under
selects, concatenations, part-selects, in generate scopes, per-instance widths; writers in the importer, before and
after it by name, in an interface, a program, inside a macro body, two importers, two files.

## 4. Gates

1. **Build**: pristine worktree build = main tree (`b912028331d2...`); law build `338c91ba3c4f...`.
2. **Probe** (`tests/sweep.sh --corpus probe` inside the full sweep): `regressions=0 conversions=143 changes=9`,
   EQUAL 3137 -> **3280**, STRICT_NOTEQUAL 950 -> 807 ([evidence/probe_compare_law.txt](evidence/probe_compare_law.txt)).
   Every conversion and change is attributed by an `R11U193_TRACE` run of its case
   ([evidence/probe_conversions_by_law.txt](evidence/probe_conversions_by_law.txt)): 113 § nestedDefChainName193,
   17 § caTernFillArmKept193, 5 § caUnsizedRhsClonePerInst193, 5 both of those, 1 § connSysCallArgDefNet193,
   1 § connCastTsNamedByPort193 (r10earl_repro/ug), 1 § castOperandLeafElab193 + § connCastTsNamedByPort193
   (r11u110repro/grid/e1/e45_pkg_enum_ovr); the § connSysCallArgDefNet193 one is r10scr13repro/t2. The nine
   CHANGE rows all shrink on their first field or unmask a pre-existing record: r10earl31repro/v5_hier `endcol(6) -> (5)`
   and r10vbuvm29repro/gv29_b_positions `fullname(3) -> (2)` (connCastTsNamedByPort193); r11u105 k40, k42 and r11v105 v13,
   v22 `fullname(9) -> (7)`, v11u93 b07 `(8) -> (1)`, b09e `(19) -> (2)` (nestedDefChainName193); r10rgg9 l_concat
   `file(2) -> depth(1)` (caTernFillArmKept193: the first record cleared, the walk's pre-existing divergence at the
   concatenation Lhs `{a1, b1}` is next, the same `#85 depth` record at the base).
3. **Corpora**: surelog `regressions=0 conversions=0 changes=0`; uhdm2rtlil `regressions=0 conversions=2 changes=2`:
   * **CONVERSION rsp_gen_minimal, both modes** — fresh rows `rsp_gen_minimal,default,CMP_EQUAL,,,equal` and
     `rsp_gen_minimal,testflags,CMP_EQUAL,,,equal` (was `STRICT_NOTEQUAL differ:fullname(2)`); results/ untouched.
   * CHANGE ibex_pmp d/t `differ:file(5) -> differ:type(1)`: § tfArgOutsideCopyOrder193 cleared the five file records;
     the one left is `#13972 type` (golden ref_typespec `work@ibex_pmp.g_access_check[0].g_regions[0].region_basic_perm_check`,
     ours ref_obj `c` at ibex_pmp.sv 227:83), the record the pristine walk already diverged at (the sister's face, §6).
4. **Downstream**: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`, every row
   its baseline verdict; rsp_gen_minimal, ibex_pmp, genvar_loop_decl_2, tern_fill_literal IDENTICAL.
5. **uhdm-cmp** 0 lines on every touched row (rsp_gen_minimal, ibex_pmp, genvar_loop_decl_2, Rggen d, Earlgrey d/t keep
   their judge-equal status) and every probe case (probe `regressions=0` includes the judge).
6. **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fenced-free mirrors,
   [evidence/byteverify.txt](evidence/byteverify.txt)): PATH_SETS_IDENTICAL 2560, SELFCHECK 2559 / 2560, **MOVERS 16**:
   * law firings (trace census, [evidence/trace_census_surelog_movers.txt](evidence/trace_census_surelog_movers.txt)):
     rsp_gen_minimal d/t (CONN), ibex_pmp d/t (COPY), genvar_loop_decl_2 d/t (2 × caUnsizedRhsClonePerInst193, strict
     equal before and after, distance 0 -> 0), Rggen d (3 caTernFillArmKept193 + 49 caUnsizedRhsClonePerInst193:
     `endcol(144)` both, order-blind distance 4539 -> 4521, miss 6788 -> 6250), Earlgrey_0_1 d/t (16
     connCastTsNamedByPort193 + 2 caUnsizedRhsClonePerInst193: `col(98)` both, distance 6784 -> 6776 / 6349 -> 6341);
   * no law fires (trace empty) on the UVM movers: MiniAmiq d/t, SeqDriver t, SimpleUVM d = the known 4-line
     `UINT`/`vpiDecompile` coin (order-blind 4 lines each); Scoreboard d order only (0 lines); BuildUVMPkg d/t order only
     (0 lines): the pristine binary alone writes both of its hashes, the law sweep's is one of them
     ([evidence/distances.txt](evidence/distances.txt)).
   **Prediction** ([evidence/predict_before_sweep.txt](evidence/predict_before_sweep.txt), `drivers/predict.cpp` on the
   pristine databases, before the law sweep): the five triggers CONN / NDA / NEST / TFILL / UCLONE named Earlgrey, Rggen,
   rsp_gen_minimal, genvar_loop_decl_2 among their upper-bound rows. **ibex_pmp was not predicted**: the COPY trigger
   (a top package listing a typespec located outside it) was added after § tfArgOutsideCopyOrder193 joined the patch and
   after the law sweep was read ([evidence/predict_with_copy_trigger.txt](evidence/predict_with_copy_trigger.txt): it
   names ibex_pmp and 69 more upper-bound row-modes, none of which moved). Every mover is attributed.
7. **Canaries**: `canaries.sh` uhdm2rtlil `ok=16 changed=0`; surelog `ok=50 changed=2` = Earlgrey_0_1 d/t
   `col(91) -> col(98)` against the committed baseline, which the PRISTINE sweep reads too (`col(98)`, the Earlgrey
   dump-column environment draw). `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil
   PASS.
8. **UVM order-blind distances** (`drivers/uvmdist.sh`): unchanged, MiniAmiq 7143, SeqDriver 5801, SimpleUVM 2579,
   Scoreboard 1950, BuildUVMPkg 1036 (both sweeps, both modes).
9. `tests/sweep.sh` exits 1 in both sweeps for one reason: `law index STALE: tests/LAWS.md`, read on the worktree whose
   sources carried the new laws (the pristine sweep ran from the same worktree); the patch includes the regenerated
   `tests/LAWS.md` and `python3 scripts/law_index.py --check` reads current.

## 5. What the brief's items read at the base, and what was not attempted

* (1) ibex_pmp: the ModuleEmit / ParamEmit split of the brief does not hold: both the package element and the module
  copies are ParamEmit's emission, and the mover that decides which reads moved is UhdmExporter's
  § tfArgQualOutsideWriter176 (this ground); landed there (§2.6). rsp_gen_minimal: converted (§2.1).
  arb_idx_cast (`endcol(17)`), OutputSize (`line(8)`), const_cast_signext (`type(1)`, r11u191's), N0039's probe cases,
  N0072, N0051, N0031 / N0042, ClassTypeParam, UnitElabBlock: not attempted. LogicTypespec, InterfaceModPort: not
  measured beyond their unchanged csv rows.
* (2)-(3) pass 188 / 184 / 187 residues: not attempted, except the unsized-literal clone leg of item (3), which
  § caUnsizedRhsClonePerInst193 lands for a select / concatenation Lhs (the whole-Rhs unsized literal onto a plain or
  typed Lhs, pass 181's u02 / u08, is a different leg and stays).
* (4) the UVM / Earlgrey rows: no law fires on the UVM rows; their distances are unchanged (above).

## 6. Residues, ranked, with the ground that owns each

1. **ibex_pmp d/t `type(1)`** — `#13972`, a generate-scope `var_select` typespec in the elaborated
   `region_basic_perm_check` call argument (golden a ref_typespec named by the path, ours a bare `ref_obj c`): ExprEmit
   `emitExpr` (the sister's ground), the last record of the row.
2. **The generate-scope substituted package parameter's typespec name** (22 probe cases, r11u115 grid r/f, r/k, x and
   v11u115 grid f1: `{W{1'b0}}` inside `g[0]`, golden `work@top`, ours `work@top.g[0]`): the constant's typespec
   reference is written by the expression emitter (not pinned here; most likely ExprEmit's imported-parameter
   substitution).
3. **An interface instance's cast actual** (CL/s12, `ifc u (.d(7'(r)))`): ModuleEmit `emitInterfaceInstance` runs no
   § connLeftmostLeafElab139 walk; golden names the cast typespec `work@dut.u.d` and the operand `work@dut.u.d.r`.
4. **r10rgg9 c_iface_body, c_paraminit** (`type(1)`, unchanged) and **l_concat** (`depth(1)`, the concatenation Lhs
   `{a1, b1}` of an elaborated fill-folded assignment: golden lists the definition nets under it).
5. **v11u93 b07 / b09e, r11u105 k40 / k42, r11v105 v13 / v22**: the nested-definition names left after
   § nestedDefChainName193 (a nested module_array `work@bmod::innermod`, program instances).
6. Stage-1 shapes met by the grids on both binaries: `wire w = signed'(r)` (r18), a cast of a parameter sum in a
   connection (s13), a package importing a package whose typedef an outside writer moves (p07), an enum typedef array
   parameter (p09).

## 7. Files

* `cases/{CL,NN,TF,UC,PM}/*/dut.sv` (p08 also `pk.svh`): the grids; each case names its law on its first line.
* `drivers/`: `env.sh` (pins, fence), `case.sh`, `grid.sh`, `row.sh`, `rowrun.sh`, `sweep.sh`, `probeheads.py` (first
  strict record of every probe case of a sweep), `probesub.py` (judge a case list as check_probe does), `predict.cpp` +
  `predict.sh` (the pristine-database predictor), `bvmirror.sh`, `offcheck.sh`, `switches.sh`, `ob.sh`, `rowdist.sh`,
  `uvmdist.sh`, `tsrefs.cpp` / `objrefs.cpp` (object identity of typespecs and references), `cc.sh`.
* `evidence/`: the sweep logs, compares, byteverify, predictions, trace census, conversions by law, grid, offcheck,
  switches, canaries, distances.
