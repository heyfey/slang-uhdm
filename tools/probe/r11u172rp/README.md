# r11u172rp: the rp32 and struct-typespec file families, decoded and scratch-verified (analyst pass, measurement only)

**Base.** `2dcbc596` (branch matrix-1.87). Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is
edited by this directory's patch: the laws are delivered as two patch files for the pairs to land
(`law_typeemit.patch` for pair B, `law_exprEmit.patch` for pair A). This directory is the whole deliverable
(`/tmp/r11u172.patch`). The brief also names `tools/probe/r11u172hp/` and "the canonicalisation patch you were given":
no canonicalisation patch was handed to this pass and `tools/uhdm-strictcmp` was not changed (no comparator defect was
found), so the deliverable holds this directory only.

Conventions. Laws are written `law <name>` here, never with the section sign, so `scripts/law_index.py` does not read
this directory as a landed pass; the source comments in the two patch files carry the section signs for the landing.
The four slang-fenced tests are never named (`FENCED_n` in the predictor csv). **No binary, gdb run or script touched a
fenced test's sources, a copy of them or their databases**: the gate sweeps ran every row as the gate mandates; every
driver reads `$FENCED` from RESUME.md and refuses to run without it; the byte comparison ran on hard-link mirrors that
leave the 8 fenced row-mode databases out (`drivers/bvmirror.sh`, `fenced_skipped=8`); gdb ran on this pass's own cases
only.

Binaries, frozen `chmod 555` in `/tmp/r11u172_bin` before any measurement:

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `4c55e61fe41027e54e5ede0899ce3bed` | worktree at 2dcbc596, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` |
| `slang-uhdm.law` | `cd06c3e937c49dbc8714eb82ccc153bc` | 2dcbc596 + `law_typeemit.patch` + `law_exprEmit.patch` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | r11u165map/drivers/strictcmp_x.cpp, the map's record-dump variant (same md5 as map 8's) |

Every `cmds.txt` of both sweeps names its binary: 3273 of 3273 `slang:` lines name `/tmp/r11u172_bin/slang-uhdm`
(pristine sweep `/tmp/r11u172_swP`) and 3273 of 3273 name `/tmp/r11u172_bin/slang-uhdm.law` (law sweep
`/tmp/r11u172_swL`). The shared `/tmp/strict_sweep` the brief points at is dated 2026-09-24 03:31, before the strict flip
(c9e2923c) and the base; its strict cells differ from the committed baselines (rp32 `fullname(6)` there,
`file(46)` in results/golden_uhdm2rtlil.csv), so every measurement here comes from this pass's own sweeps.

## 1. The heads at 2dcbc596, by shape (question 1)

Records are `depth type name defname fullname file line col endline endcol decompile size value consttype`
(`build/uhdm-strictcmp --max 50 --dump-a --dump-b`, A = golden, B = ours); the parent chain is by walk depth
(`drivers/chain.py`). Every rp32 row-mode (alu, bru, mdu, wbu; default and testflags) carries the same four faces;
alu adds the fifth. Full before/after heads for every targeted row-mode: `evidence/rows/`.

**(b) A struct typedef declared in one file and used in another (N0149 package, N0140 ref_typespec, N0143
module_inst), rp32 first field `file(46)`:**

    uhdm2rtlil/default/rp32_r5p_mdu #1157 file
      A: 2 struct_typespec riscv_isa_pkg::isa_t  riscv_isa_i_pkg.sv 417 34 417 39
      B: 2 struct_typespec riscv_isa_pkg::isa_t  riscv_isa_pkg.sv   417 34 417 39
      chain: design < package riscv_isa_i_pkg < struct_typespec
    #3638 (the same object through the dec32 formal): package riscv_isa_i_pkg < function dec32 < io_decl isa
      < ref_typespec < struct_typespec riscv_isa_pkg::isa_t  A riscv_isa_i_pkg.sv / B riscv_isa_pkg.sv, 417:34-417:39
    #13563: design < package riscv_isa_pkg (elaborated listing) < struct_typespec  A riscv_isa_i_pkg.sv / B riscv_isa_pkg.sv

The span is already right (417:34-417:39 is the `isa_t` token of `enc32 (isa_t isa, ...)` in riscv_isa_i_pkg.sv); only
the file is the declaring one. Earlgrey_0_1 carries the same object class through the other mover, the net
declaration's end-only move: `tlul_pkg::tl_h2d_t` golden `xbar_peri.sv 32:11-61:31`, ours `tlul_pkg.sv 32:11-61:31`
(the end is `tl_h2d_t tl_s1n_9_ds_h2d [8];` in xbar_peri.sv), `tl_d2h_t` likewise, `flash_phy_pkg::rd_buf_t` at
flash_phy_rd.sv and `ibex_pkg::pmp_cfg_t` at ibex_core.sv: 6652 file facets on Earlgrey default (N0140 6464, N0143
184, N0149 4; record-level census, `evidence/sweeps/earlgrey_default_facets.txt`).

**(b) The UINT range-bound constant's value (N0092):**

    rp32_r5p_mdu #1358 value   chain: package riscv_isa_i_pkg < ... < typespec_member imm_11_0 < logic_typespec < range
      A: 7 constant riscv_isa_i_pkg.sv 118 34 118 36  00 64 UINT:00 9
      B: 7 constant riscv_isa_i_pkg.sv 118 34 118 36  00 64 UINT:0  9      (`logic [11:00] imm_11_0`)
    UnionCast default #179: A dut.sv 108:34-108:36 00 64 UINT:00 / B UINT:0; 26 (default) and 28 (testflags) objects

**(a) A symbolic bound folded vs kept; a bound operation shared vs copied (N0025 depth + N0033 ours-only copies):**

    rp32_r5p_alu #15963 type (the walk diverges here)
      chain: package riscv_isa_i_pkg (ELABORATED listing) < function imm_i_f < assignment < operation (cast)
        < ref_typespec < logic_typespec imm_t (the cast's clone, own range folded: INT:31) < ref_typespec <in>imm_t
        < logic_typespec riscv_isa_i_pkg::imm_t (the alias target) < range
      A: 10 constant  riscv_isa_i_pkg.sv 144 27 144 29  31 64 INT:31 7
      B: 10 operation riscv_isa_i_pkg.sv 144 27 144 31     (then B 11 constant 32, 11 constant 1: the `32-1` tree)

`riscv_isa_i_pkg.sv:149 imm_i_f = imm_t'($signed({op.imm_11_0}));` The clone reaches, through its typedef alias, the
DEFINITION package's `imm_t` listing (`[32-1:0]` kept symbolic, first view) where golden reaches the ELABORATED
package's listing (`INT:31`, second view: record 14132 in both dumps). The same face in dec32:
`dec32.i_b = imm_b_f(op32_b_t'(op));` reaches the definition listing of the struct `op32_b_t`, whose member `fn3_t`
(`typedef logic [3-1:0] fn3_t`) lists `3-1` where golden's elaborated listing lists `INT:2`. N0025 (a constant where
ours has an operation) and N0033 (the operation subtrees only ours holds) are the SAME objects seen twice: 39 + 39 per
rp32 row, and no copy count differs once the target listing is right (section 2, the copy axis).

**(a) A sys_func_call as an operand (N0049), rp32_r5p_alu only (both modes):**

    #40065 endcol  chain: module_inst work@r5p_alu (definition view) < gen_if_else < begin < gen_if_else
        < named_begin gen_shf < cont_assign < operation (the XLEN' cast) < operation (>>>) < sys_func_call $signed
      A: 11 sys_func_call $signed r5p_alu.sv 297 28 297 35
      B: 11 sys_func_call $signed r5p_alu.sv 297 28 297 44      (`XLEN'($signed(shf_ext) >>> shf_amm)`)

**The definition view vs the elaborated view.** The cast face is elaborated-view only (the definition package's cast
already reaches the symbolic listing in both producers); the `$signed` face is definition-view only (the elaborated
emitter already writes the name span: ExprEmit's `kNameOnlyFuncs`); the file and value faces are view-blind (one shared
object; every listing of it).

**Other rows the clusters carry.**
* cfg_func_width_loop d/t (N0025/N0033, first field `line(3)`): a different shape. The elaborated `M` param_assign's
  constant is typed by the package function FORMAL's clone (`maxw(mask_t cfg)`, golden `mask_t 27:40-27:46` with its
  own folded `INT:2`), where ours types it with a fresh `mask_t` at the typedef (16:11-16:25, `NF-1` kept). Golden
  shares the formal's typespec because Surelog's constant evaluator binds the actual to the formal while it folds
  `q::maxw(M)` in the port ranges (the evaluator-stamp family, ExprEmit/ParamEmit ground A). Not this pass's law;
  residue R1.
* jeras_union d/t: the rp32 faces (the design embeds the same riscv packages): N0025 12, N0033 12, N0092 44.
* the UVM rows (N0025 220 objects: SimpleUVM 120, Scoreboard 80, BuildUVMPkg 20): `uvm_reg_addr_t`
  (`` typedef bit [`UVM_REG_ADDR_WIDTH-1:0] ``) reached through class members and arrays of uvm_pkg's classes, alias
  target the definition listing; residue R2.

## 2. The decode (question 2)

Surelog sources under third_party/Surelog/src (v1.87, 0445655e).

**FILE.** `FileContent::populateCoreMembers` (Design/FileContent.cpp:674) writes vpiFile on EVERY call: the start
node's file when it has a start node, else the end node's file, else the FileContent's own. Every span Surelog moves
therefore moves the file with it:
* `CompileHelper::compileTfPortList` (DesignCompile/CompileStmt.cpp:1809) runs `populateCoreMembers(type, type, ts)`
  on the typespec `compileTypespec` returned for an ANSI argument's written type, which for an aggregate typedef name
  is the typedef's own object: the object takes the formal's span AND the formal's file, the last compiled formal
  winning. Pinned with gdb on the pinned binary on case `F/f01_pkgfn_arg` (a_pkg.sv declares `s_t`, b_pkg.sv's
  `f(s_t v)` uses it): the `UHDM::struct_typespec` object is written by `compileTypespec` (start=end=5), then
  `compileTypeDef` (31), then twice by `compileTfPortList` (16, b_pkg.sv's FileContent), one per package compile
  (`evidence/gdb/f01_populateCoreMembers.txt`).
* `UhdmWriter::writeNets` (DesignCompile/UhdmWriter.cpp:881) runs `populateCoreMembers(InvalidNodeId, dimensions,
  ts)` for a net with unpacked dimensions: no start node, so the END node's file. Pinned on `F/f02_pkg_unpacked_net`:
  `PCM start=0 end=41 obj=struct_typespec` from `writeNets` (`evidence/gdb/f02_populateCoreMembers.txt`).

Ours: the movers write through `UhdmExporter::setLoc` (src/UhdmExporter.cpp:2259), which fills vpiFile only when it
is EMPTY (line 2270), or write the end alone: emitPackage's formal last-writer loop (src/ParamEmit.cpp:33091,
`setLoc(sh9, tsy9->sourceRange())`) and the `pendingPkgTsStretch` end stretch (src/UhdmExporter.cpp:9782). Two movers
already write the file and agree with the decode: law tfArgTypedefLastWriter146 (enum formals, UhdmExporter) and law
defNetTypedefEndWrite134 (`tdNetEnd134`, ModuleEmit). **The pin in map 8 (buildStructTs < emitPackage) names the
mint, not the writer**: the fix site is the movers, as map 8's audit rule warns (read the first caller outside the
mint's file; check the post-passes).

**VALUE.** `compileConst` (DesignCompile/CompileExpression.cpp:467, the `slIntConst` branch): "Do not evaluate the
constant, keep it as in the source text": an unsized decimal gets `"UINT:" + text` with only `_` removed (and `#`),
decompile the same text. `compileRanges` with `Reduce::Yes` (CompileExpression.cpp:3963) calls `reduceExpr` on a
bound that is already a constant and keeps it. So a packed bound written `00` lists `UINT:00`; ours evaluated it
(`makeBoundConst`, `"UINT:" + std::to_string(value)`). Golden does evaluate on other paths (the unpacked dimension, an
unpacked-array typedef's element range: `decompile 00, UINT:0`, cases V/v09, v13-v15); those are reached through other
emitters of ours and are judge-level residues already (section 5).

**DEPTH (and COPY).** `FunctorCompilePackage::operator()` (DesignCompile/CompilePackage.cpp:60) compiles every
package twice: the elaborated package with `Reduce::Yes` (listed in `uhdmtopPackages`) and the un-elaborated one
(`getUnElabPackage()`) with `Reduce::No` (`uhdmallPackages`). Each compile resolves a typedef name in its own
package's DataType table, so a cast written in a subroutine of the typedef's own package reaches, in the elaborated
package, the elaborated (folded) listing, and in the definition package the symbolic one. Ours already follows this for
formals and return variables (TaskFuncEmit binds `pkgTopTypedefTs` in the elaborated view); the cast branch (src/ExprEmit.cpp,
`cts = typedefTs[expr.type]`) always bound the definition listing. **There is no separate copy rule**: golden holds no
extra or fewer copies here; N0033's "ours-only operation under range" objects are the definition listing's operation
trees that the wrong alias target makes the walk expand at the use site (the comparator canonicalises typespec
identity). One law clears both clusters (39 + 39 per rp32 row, 12 + 12 on jeras_union), so no `R11U172_COPY_OFF`
switch exists.

**SPAN.** `compileExpression`'s `paSystem_task_names` branch (CompileExpression.cpp:2432) builds `$signed` / `$unsigned`
as a plain sys_func_call and leaves its location to the end of compileExpression (CompileExpression.cpp:3681:
`populateCoreMembers(child, child, result)` with `child` the System_task_names node = the name token only). Ours:
the bound emitter already writes the name span for them (ExprEmit `kNameOnlyFuncs`); the syntax-view emitter
(src/TypeEmit.cpp, `emitSyntaxExpr`'s invocation branch) wrote the whole call unless inside a cast size. The measured grid
(14 cells, section 3) finds golden writing the name span in every syntax-view position; `signed'(x)` (a
SignedCastExpression, a different branch) keeps its whole span in golden.

## 3. The grid (question 3)

52 cases in `cases/{D,F,S,V}/` (a `files` list where the case has more than `dut.sv`), goldens from the pinned Surelog
with the probe arguments (`-parse -nobuiltin -nocache -sv <files> -mt 0 -mp 0`), ours `<files> --single-unit
--nobuiltin` (`drivers/case.sh`, own content-keyed golden cache `/tmp/r11u172_gold`). `evidence/grid.txt` holds every
verdict with both binaries.

| axis | cells | pristine strict-equal | law strict-equal | converted | controls (unchanged verdict) |
|---|---|---|---|---|---|
| D (cast in a home-package subroutine, elaborated view) | 10 | 3 | 8 | d01 logic, d03 enum, d05 union, d08 nested casts, d10 task | d02 struct (equal both; identity-only move), d04 bit, d06 module function, d07 imported typedef (judge-NE), d09 param bound (judge-NE) |
| F (a typedef object moved into another file) | 12 | 3 | 9 | f01 pkg formal, f02 net unpacked dim, f07 two formals in two files (last writer), f09 two modules' nets (last writer), f10 formal then net (end wins), f12 `$unit` typedef + module function formal | f04 same file, f08 same file, f11 enum net; f03 union formal and f05 enum formal (judge-NE); f06 include-file typedef: file(27) -> file(18), the members' include-file facet stays (residue R3) |
| S (`$signed`/`$unsigned` in the syntax view) | 14 | 1 | 10 | s01 cast operand, s02 plain, s03 under an operation, s04 `$unsigned`, s05 gen-for body, s08 nested, s11 gen-if condition, s12 def-view net range bound, s13 gen-for condition | s10 module assign (equal both), s06 `$clog2`, s07 concatenation, s09 `signed'`, s14 (judge-NE; s07 and s14 cmp heads show the parent span now equal to golden's) |
| V (a bound written as a decimal literal) | 16 | 0 | 7 | v01 pkg struct member, v02 module net, v06 elaborated param range, v07 function arg, v08 module typedef, v10 module struct, v16 port range | v11 value records cleared, `decompile` residue elsewhere; v04 sized, v05 hex, v12 expression literal, v03 underscore, v09/v13/v14/v15 unpacked shapes (judge-NE, section 5) |
| **all** | **52** | **7** | **34** | **27** | every judge-NE control reads the same uhdm-cmp text on both binaries (ids stripped), except s14/s07 whose printed parent span moved to golden's |

Order-blind dump distance of the judge-NE cells that moved bytes (`drivers/obdist.sh`): d09 4 -> 4, f03 14 -> 14,
v03 20 -> 20, v13 32 -> 32, v15 34 -> 34, s14 51 -> 43, s07 18 -> 14: nothing moves away.

**Switch matrix** (`drivers/switches.sh`, `evidence/switches.txt`): on every one of the 52 cases `R11U172_OFF=1`
reproduces the pristine bytes, and each axis switch alone restores exactly its own axis's cases (VALUE_OFF the V
movers, FILE_OFF the F movers, DEPTH_OFF the D movers, SPAN_OFF the S movers) and no other.

## 4. The laws (question 4), one per axis

`law_typeemit.patch` (src/TypeEmit.cpp only; pair B) and `law_exprEmit.patch` (src/ExprEmit.cpp only; pair A). Each
applies clean on a fresh 2dcbc596 and on 45b8e774 (pass 167, landed after the base; `git apply --cached --check`);
neither needs the other (no shared symbol; the switch matrix shows the axes independent). R11U172_OFF drops all four.

| axis | law | file | switch | rule |
|---|---|---|---|---|
| FILE | `law tdMoveCarriesFile172` | TypeEmit.cpp, a design-final block at the end of `pkgImportCloneLastWriter32` (already called design-final, after every mover) | `R11U172_FILE_OFF` | a package / module / `$unit` struct, union or enum typedef object whose START is not its declaration's takes the file of the subroutine formal type token of the same type name that starts there (or, if its end then moved on, the declarator that ends there); one whose END alone moved takes the file of the declarator of that type name that ends there; the last writer in syntax-tree order when two files share the position |
| VALUE | `law boundLitWrittenDigits172` | TypeEmit.cpp `makeBoundConst` | `R11U172_VALUE_OFF` | a bound written as an unsized decimal literal lists `UINT:` + its written digits (`_` removed) when they evaluate to the bound's value |
| DEPTH | `law pkgFnCastTopListing172` | ExprEmit.cpp, the named-typedef cast branch | `R11U172_DEPTH_OFF` | in the elaborated package, a cast written in a subroutine of the typedef's own package targets `pkgTopTypedefTs` (the elaborated listing); the logic clone keeps its own range and its vpiInstance and aliases that listing |
| SPAN | `law sysSignNameSpanSyntax172` | TypeEmit.cpp `emitSyntaxExpr` (invocation branch) | `R11U172_SPAN_OFF` | `$signed` / `$unsigned` take the name-token span in every syntax-view position |

The FILE law is written TypeEmit-only, as the brief requires, by re-deriving the writer position design-final. The
one-line alternative at the writers is for whoever lands it: `ts->VpiFile(fullFilePath(tsy9->sourceRange().start()))`
after src/ParamEmit.cpp:33091 (ground A) and the end's file at the `pendingPkgTsStretch` end write
(src/UhdmExporter.cpp:9782, ground B), as law tfArgTypedefLastWriter146 and law defNetTypedefEndWrite134 already do.

## 5. Measurements (gates)

| gate | result |
|---|---|
| (1) build | pristine `4c55e61f` = main tree; law `cd06c3e9` |
| (2) probe vs golden_probe.csv | pristine: EQUAL 2647 / STRICT_NOTEQUAL 1440, regressions 0, conversions 0, changes 0. **Law: EQUAL 2660 / STRICT_NOTEQUAL 1427, regressions 0, conversions 13, changes 5** (below) |
| (3) surelog + uhdm2rtlil vs golden_*.csv | pristine: regressions 0 conversions 0 changes 0 in both. **Law: surelog regressions 0, conversions 0, changes 4; uhdm2rtlil regressions 0, conversions 8, changes 4** (below). Judge-equal scoreboards unchanged: surelog 480/3 + 474/3, uhdm2rtlil 803/1 both modes |
| (4) downstream | both sweeps IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, not excused 0; the law csv equals the pristine csv on every column of all 871 rows and results/downstream_uhdm2rtlil.csv on every verdict. Targeted rows: `rp32_r5p_alu,IDENTICAL,OK,OK,1332,1332,,` `rp32_r5p_bru,IDENTICAL,OK,OK,174,174,,` `rp32_r5p_mdu,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `rp32_r5p_wbu,IDENTICAL,OK,OK,320,320,,` (also jeras_union, ibex_multdiv_fast, cfg_func_width_loop IDENTICAL). No row moves |
| (5) uhdm-cmp | 0 lines on every touched row, both binaries (32 of 32 in `evidence/rows/`); every mover stays judge-equal in the sweep csvs |
| (6) byteverify | fence-clean mirrors (2560 of 2568 row-mode databases, `fenced_skipped=8`), SELFCHECK 2559/2560 flagged: **21 corpus movers**, all attributed below; probe databases: **25 movers of 4087** |
| canaries | canaries.sh uhdm2rtlil ok=16 changed=0; surelog ok=50 changed=2 (Earlgrey_0_1 d/t `line(1686) -> line(1611)`, a predicted FILE+SPAN mover); ctcan2 `EXPECT_UNKNOWN=1` surelog PASS (ok=58), `EXPECT_UNKNOWN=6` uhdm2rtlil PASS (ok=2) |
| landed-law byte controls | pass 118/119 grids (tools/probe/r11u118repro, r11v11u118repro, r11u119repro): 190 cases, 0 byte movers. Boundary over every tools/probe case: 14 movers of 8288, all this pass's laws, none away (section 5c) |

Both sweeps exit rc=1 on `law index STALE` alone (a clean 2dcbc596 reads the same; map 8 recorded it).

**Conversions, quoted from the fresh csv (NOT written to results/):**

    rp32_r5p_alu,default,CMP_EQUAL,,,equal       was STRICT_NOTEQUAL differ:file(46)
    rp32_r5p_alu,testflags,CMP_EQUAL,,,equal
    rp32_r5p_bru,default,CMP_EQUAL,,,equal
    rp32_r5p_bru,testflags,CMP_EQUAL,,,equal
    rp32_r5p_mdu,default,CMP_EQUAL,,,equal
    rp32_r5p_mdu,testflags,CMP_EQUAL,,,equal
    rp32_r5p_wbu,default,CMP_EQUAL,,,equal
    rp32_r5p_wbu,testflags,CMP_EQUAL,,,equal

Probe conversions (13, all SPAN): r10earl_repro/qf22, r11u17repro/grid/{c07_lhsmod_sysfunc_genlocal, c08_multdiv_shape,
c24_multdiv_onesigned, c25_unsignedlhs_signedop, c26_child_multdiv_modlhs, c27_child_multdiv_genlocallhs},
r11u25repro/grid/q15_ctl_mul, r11v17repro/grid/{w03_syscall_concatarg_op, w04_syscall_barearg_op,
w07_syscall_addop_arg_op, w08_syscall_castinop_arg, w09_syscall_castinconcat_arg}.

Changes (every one fewer objects, toward golden; record-level census `drivers/moverfacets.sh`, map 8's analyzer):

| row / case | strict cell | record-level facets (pristine -> law), clusters up |
|---|---|---|
| Earlgrey_0_1 d/t | `line(1686) -> line(1611)` | 24787 -> 18121 (default): N0140 6464 -> 0, N0143 184 -> 0, N0149 4 -> 0, N0049 12 -> 0, sys_func_call endcol under cont_assign 2 -> 0; 0 up |
| UnionCast d / t | `value(26) -> file(2)`, `value(28) -> file(2)` | 26 -> 2 / 28 -> 2 (N0092 gone); left: N0430, the union's empty file (pair B's named UnionCast item) |
| ibex_multdiv_fast d/t | `endcol(26) -> file(11)` | 37 -> 22 (N0049 12 -> 0, sys_func_call under cont_assign 3 -> 0); left: 11 enum_const locations |
| jeras_union d/t | `fullname(54) -> fullname(77)` | 219 -> 77: the pristine walk DIVERGED at the N0025 face, so the strict count stopped there; the law walk is complete. N0092 44, N0025 12, N0033 12 and 70 full-name facets gone; left: 60 range constants without a file, 15 full names, N0430 2; 0 up |
| probe v59v2_earl59, g3_rhs98, grid7, a01_gf_signed, a20_gf_unsigned_W | endcol -> the next face | each one sys_func_call endcol facet fewer (3->2, 5->4, 2->1, 3->2, 3->2) |

**5a. Movers, attributed** (`evidence/sweeps/*_attribution.txt`: each mover re-run with one axis switch at a time; the
switch that restores the pristine bytes names the law):

| mover | law(s) |
|---|---|
| rp32_r5p_{bru,mdu,wbu} d/t | FILE + VALUE + DEPTH (each switch alone leaves a partial database) |
| rp32_r5p_alu d/t | FILE + VALUE + DEPTH + SPAN |
| jeras_union d/t | VALUE + DEPTH |
| UnionCast d/t | VALUE |
| ibex_multdiv_fast d/t | SPAN |
| Earlgrey_0_1 d/t | FILE + SPAN (byte-deterministic: a switch-free re-run reproduces the law bytes) |
| MiniAmiq d/t, SeqDriver d/t, SimpleUVM t | the UVM `UINT`/`vpiDecompile` order coin: path-normalised order-blind uhdm-dump diff = the 4 known lines (`UINT:1451`/`UINT:750` and their decompiles) plus the header path, `evidence/sweeps/uvm_coin_*.txt` |
| probe: 18 cases | SPAN (the 13 conversions and 5 changes) |
| probe: r10buvm8repro/{v4order8, vfwdts8, vxpkg8}, r10uvm123repro/g123_c_otherpkg, r10v180repro/{v180_a_share, v180_e_ret, v180_i_inst} | DEPTH. Statuses unchanged; record-level facets unchanged except g123_c_otherpkg 10 -> 8 (its N0025 + N0033 pair gone): the cast now targets the elaborated listing, which for literal bounds lists what the definition listing lists (an identity move toward golden's object, invisible to the canonicalising comparator) |

**5b. The prediction** (`drivers/predict.py` on the PRISTINE databases only: uhdm-dump for VALUE / SPAN / DEPTH, the
golden-vs-pristine strict record dumps for FILE; `evidence/predict/predict_pristine.csv`). It predicts a superset: 153
rows (DEPTH 107, SPAN 38, VALUE 24, FILE 16), and **every one of the 46 movers is predicted** (41 by their own laws, the
5 UVM coin movers by DEPTH's over-approximation). Disclosure: the predictor was launched before the law sweep, died at
row 2361 on a missing dump file (a judge-NE pair writes no record dump), and was completed, resumable, after the
byteverify had run; its inputs are the pristine databases alone, so its output does not depend on the law run.

**5c. Boundary** (`drivers/boundary.sh`): every `tools/probe/**/dut.sv` except this pass's, exported by both binaries
(`dut.sv --single-unit --nobuiltin`, children on `</dev/null`), databases compared byte for byte, fenced paths refused.
**listed 8288, processed 8288: 8191 SAME, 14 MOVER, 83 NODB** (no database from either binary: the same 3 segfaults and
the same rejections on both). The 14 movers are the positive control that the instrument sees, and every one is this
pass's (`evidence/sweeps/boundary_movers.txt`: each judged against its pinned-Surelog golden with both binaries, the
single switch that restores the pristine bytes, and the order-blind dump distance):

| law | movers | verdict pristine -> law | order-blind distance |
|---|---|---|---|
| SPAN | r11u153verify/cases/lpb/l01_sysfunc_parent, r11v17repro/grid/{va14, va15, w02, w05, w06}, v11u115repro/grid/f1/{a02, a19}, f3/c06 | judge-NE both (same cmp text) | down 4-8 each (30->26, 19->15, 21->17, 28->24, 28->24, 40->32, 200->196, 200->196, 64->60) |
| DEPTH | r11u146repro/grid/fa/f6, r11u153verify/cases/fa/g03_output_arg (STRICT_EQUAL both), r11v140repro/tdc/t07_pkg_func (judge-NE both, same cmp text) | unchanged | unchanged (identity move) |
| FILE | v11u134repro/grid/td16 (`file(26) -> file(18)`: the struct's file right, the include-file members stay, R3), r11v42repro/grid42v/v10 (judge-NE both, same cmp text) | toward golden / unchanged | 28 -> 28, 39 -> 39 |

Nothing moves away from golden anywhere in the boundary.

## 6. What is left, and why (ranked)

* **R1, cfg_func_width_loop d/t (N0025/N0033 second shape, 3 objects):** golden types the elaborated parameter's
  constant with the package function formal's clone (`maxw(mask_t cfg)`), bound while Surelog's evaluator folds
  `q::maxw(M)`; ours mints a typedef clone. The evaluator-stamp family (ground A); needs the formal-binding model, not
  a listing choice.
* **R2, the UVM N0025 (220 objects in 3 rows):** `uvm_reg_addr_t`'s alias target from class members and arrays of
  uvm_pkg's classes. Likely the DEPTH rule reaching class scope (the class body belongs to the elaborated package);
  ungridded here, left for a brief with a class-in-package grid.
* **R3, include-file typedef members (f06; UVM N0210, 3528 objects):** golden files a member declared in an included
  header at the including file; the r11u166 location model's territory (law ppOutputFile166), live in pair B r11u168.
* **R4, bounds golden evaluates:** unpacked dimensions and unpacked-array typedef element ranges read `UINT:0` with
  decompile `00` in golden, and `1_5` decompiles as `15` (v03, v09, v13-v15); judge-level decompile residues on other
  emitters (ours writes decompile `0` there), untouched.
* **R5, the rows' next faces:** jeras_union (60 range constants with no file, 15 full names), UnionCast and jeras_union
  N0430 (the union's file, pair B's named item), ibex_multdiv_fast (11 enum_const locations), Earlgrey_0_1 (18121
  facets: the include line model, full names, macro spans).

## 7. The UVM census (question c)

Pristine 2dcbc596 databases of MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg (default; the testflags
rows carry the same counts), record-level with map 8's analyzer and keys (`strictcmp_x` dumps, `analyze.py`; its
tool-verify reads ok on all 9 row-modes), joined to map 8's cluster_index.csv (`drivers/uvmcensus.py`,
`drivers/uvmfamilies.py`; `evidence/uvm/`). The laws of this pass do not change these rows (their only byte change is
the order coin), so the census is also the census after the laws.

**The first ten differing records** (walk order): MiniAmiq, SeqDriver, SimpleUVM and Scoreboard all start at #23-#32
with ten `include_file_info` lines (N0064, the include line model: golden `uvm_pkg.sv 9217:12` where ours says
`9207:12`, the offsets growing to 15954 vs 15739): covered by the r11u166 decode (map 8 measured N0064 14 -> 1 row-modes
under it), which pair B r11u168 lands first. BuildUVMPkg starts at #873-#1031 with the package aggregate typedefs'
own spans (N0080 x2 struct, N0075 x8 enum: golden `uvm_pkg::uvm_check_e 79053:35-79053:46`, ours the declaration
60837:4-60840:18): the typedef last-writer relocation reaching class-method formals of uvm_pkg, the branch law
tfArgTypedefLastWriter146 declines; OPEN (F3 below).

**Families ranked by objects across the five rows** (149397 objects in 504 clusters):

| rank | family | objects | BuildUVMPkg | MiniAmiq | Scoreboard | SeqDriver | SimpleUVM | clusters | top clusters (ground, site, nearest law) | coverage |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | F2 object multiplicity (golden holds copies ours does not, or the reverse) | 47650 | 211 | 27216 | 1114 | 17815 | 1294 | 98 | N0500/N0489/N0564/N0501 class-method locals in clone bodies (A, StmtEmit emitStmt < TaskFuncEmit, law thisSuperNewAssignNoStmt3); N0151/N0262 import parameter copies (B, ModuleEmit importParamCopy82, law classImportParamStamped82); N0134 array_typespec copies (A, StmtEmit foreachAssocIdxAliasTs22) | OPEN; MiniAmiq/SeqDriver carry 94% |
| 2 | F1 preprocessor location model (macro bodies, include lines) | 35866 | 0 | 9939 | 6415 | 11516 | 7996 | 77 | N0292 constants under calls, N0296/N0297 hier_path spans, N0310/N0298 (A, ExprEmit/StmtEmit macro-argument sites) | the r11u166 decode (MEASURED in map 8), live in pair B r11u168 |
| 3 | F4 subroutine formal / typespec / bound spans | 19711 | 4091 | 3899 | 3854 | 4004 | 3863 | 37 | N0093/N0156 io_decl spans (B, TaskFuncEmit, law classScopedTdDeclTsUnsupported11); N0072 class_typespec, N0039 int_typespec, N0069 string_typespec spans (B, TypeEmit makeTypespec); N0111 constants under io_decl (A) | OPEN (map 8 routed N0093/N0156/N0069 to r11u164 optimistically; pass 164 left them) |
| 4 | F5 reference full names | 19445 | 1085 | 7649 | 1803 | 5957 | 2951 | 150 | N0095/N0174/N0175 (A, ExprEmit, law staticScopedLvalueBad48), N0490/N0491 foreach loop vars (A, StmtEmit cloneLoopVarShared37), N2400/N2401 (r11u157 R3) | OPEN |
| 5 | F7 expression / statement spans outside the pp model | 12768 | 786 | 3254 | 2240 | 3718 | 2770 | 77 | N0118 (A, ExprEmit emitBadConcatOperand160), N0191, N0081 (B, TaskFuncEmit assocIoRange9), N0157/N0104 class method locals (B) | OPEN |
| 6 | F6 file facets | 11817 | 139 | 3240 | 2191 | 3564 | 2683 | 40 | N0121 enum_typespec other-file+span (B, buildEnumTs, law pkgTdCloneRefNoBind18); N0210 typespec_member other-file (B, the include-file member, R3); N0123 (A, makeParamTs) | N0210: r11u166 territory; the rest OPEN. This pass's FILE law does not fire on them (UVM bytes unchanged) |
| 7 | F3 typedef relocation spans | 1045 | 769 | 91 | 41 | 92 | 52 | 5 | N0266, N0075, N0080 (B, buildEnumTs / buildStructTs < emitPackage), N0043 | OPEN: BuildUVMPkg's first ten |
| 8 | F8 names | 732 | 166 | 151 | 136 | 143 | 136 | 5 | N0103 class_typespec name (B, makeTypespec, law arrayElemTdClone42) | OPEN |
| 9 | F9 value / order / depth | 363 | 22 | 50 | 87 | 27 | 177 | 15 | N0025 220 (R2) | OPEN |

Per family, the eight largest clusters with ground, map 8 coverage and site are in `evidence/uvm/familiesP.txt`; every
cluster with its per-row objects in `evidence/uvm/censusP_rank.csv`.

## 8. Files

* `law_typeemit.patch`, `law_exprEmit.patch`: the laws (git diffs of src/ vs 2dcbc596).
* `cases/{D,F,S,V}/`: the grid (52 cases).
* `drivers/`: `env.sh` (the pins, FENCED from RESUME.md, fail closed), `case.sh` (a case against its golden),
  `gridrun.sh`, `switches.sh`, `rerow.sh` (a corpus row with a given binary, from a sweep's cmds.txt), `chain.py`
  (parent chains of strict records), `obdist.sh` (order-blind dump distance), `moverfacets.sh` (record-level mover
  census with map 8's analyzer), `predict.py` (the mover predictor), `bvmirror.sh` (fence-clean mirrors),
  `boundary.sh`, `uvmcensus.py`, `uvmfamilies.py`.
* `evidence/`: `grid.txt`, `switches.txt`, `rows/` (before/after heads of every targeted row-mode), `sweeps/` (both
  sweep summaries, byteverify, attributions, mover facets, Earlgrey and jeras_union censuses, UVM coin diffs,
  boundary), `predict/`, `gdb/`, `uvm/`.
