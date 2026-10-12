# r11u297 — module/type ground: the initializer in a data declaration's dimension slot (shared typespec end and elaborated signal span), and the nested-definition port phase that crashed

Base f85b3457 (pass 295). Three laws in ModuleEmit behind `src/R297.h`. Each law reads its own
`R11U297_<LAW>_OFF` switch. `R11U297_OFF` drops all three and gives pristine's bytes on 126 of 126 grid case-views
(exit code included). `R11U297_TRACE=<dir>` logs every firing (one file per process, `OUT <-o path>` first).

**TWO PROBE CONVERSIONS AND ONE SHRINKING CHANGE**, no regression. **THE THREE NESTED-MODULE CASES THAT CRASHED EVERY
BINARY WITH EXIT 139 NOW WRITE A DATABASE** (r11u295repro NA/n02_two_levels and n07_outer_twice, v11u295repro
VN/vn02_outer_in_genfor, the first item of the brief; 6 of their 6 case-views, `vn02_outer_in_genfor` elaborated
STRICT_EQUAL at 335 objects). No corpus or downstream database moves in bytes (0 of 3365 fence-filtered databases),
so no corpus row changes status or strict column.

| target (probe, default view = the gate) | before (base) | after (law) | laws |
|---|---|---|---|
| r11u32repro/k9b | `differ:endline(4)` | **EQUAL** | § varDeclInitMovesSharedTsEnd297 + § varDeclInitElabSpan297 |
| v11u110repro/brk/v1/b06_const_init | `differ:endline(4)` | **EQUAL** | § varDeclInitMovesSharedTsEnd297 |
| r11u110repro/grid/f2/i16_var_kw_init | `differ:endline(9)` | `differ:fullname(5)` (CHANGE, 4 records toward golden, away 0) | § varDeclInitMovesSharedTsEnd297 |
| probe | EQUAL 3952 + STRICT_NOTEQUAL 135 | **EQUAL 3954 + STRICT_NOTEQUAL 133** | regressions 0, conversions 2, changes 1 |
| surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

The fresh law-sweep probe rows: `r11u32repro/k9b,EQUAL,,equal`, `v11u110repro/brk/v1/b06_const_init,EQUAL,,equal`,
`r11u110repro/grid/f2/i16_var_kw_init,STRICT_NOTEQUAL,differ:fullname(5),differ:fullname(5)`.

## The decode shared by laws 1 and 2

Surelog parses a body declaration whose type is a bare name, `t_t x = 8'h1;`, as a `Net_declaration` (the
`net_type_identifier list_of_net_decl_assignments` production), and the same declaration written with a `var`,
`const` or `static` qualifier, `var t_t x = 8'h1;`, as a `Data_declaration` (measured with `-d ast`: `Var_type`
followed by `Variable_impl_declaration`). `CompileHelper::compileDataDeclaration` (CompileHelper.cpp:2380-2381)
builds that Signal with `unpackedDimension = fC->Sibling(signal)`, and for a declarator with an initializer and no
unpacked dimension the sibling of the name is the initializer's `Expression`. Two writers read the slot:

- `UhdmWriter::writeNets` (UhdmWriter.cpp:868-882): `dimensions = getUnpackedDimension(); if (!dimensions)
  dimensions = getPackedDimension(); if (dimensions) fC->populateCoreMembers(InvalidNodeId, dimensions, ts);`, the
  end-only populate § defNetEndOnlyLoc130 and § defNetTypedefEndWrite134 model, moves the END and FILE of the
  typespec the definition net binds, a struct, union or enum typedef's own object (TypeDef::getTypespec, no clone)
  or a type parameter's default object, to the initializer's end. The last declarator written wins (v10, v11, v28:
  a later bare-name declaration does not write; v27: a later qualified one does).
- `NetlistElaboration::elabSignal` (NetlistElaboration.cpp:2757-2762): `if (unpackedDimension)
  populateCoreMembers(id, unpackedDimension, obj)` spans the elaborated signal from its name to the initializer's
  end. writeCont_assign's clone_tree copies that net into the net-declaration cell's Lhs, so the cell's Lhs carries
  the same span.

The bare-name form keeps the typedef's own end and the name span (grid v03, v31 and pass 134's td03 / td07 / td20,
pass 119's c_import_* rows): § defNetTypedefEndWrite134's note that an initialized declaration keeps the typedef's end
was measured on that form only. A package-qualified type (`pk::t_t x = ...`) is a Data_declaration
without any qualifier, as pass 119's § scopedPkgTypeDeclSpan119 already models for the span; law 1 takes it too
(v29 elaborated view). The predicate is `dataDeclInitEnd297` in ModuleEmit: a Declarator with an initializer and no
unpacked dimension whose DataDeclarationSyntax carries a `var`, `const` or `static` modifier (law 1 also a written
package scope); it returns the initializer expression's end. An unpacked dimension keeps the dimension in the slot
(v13 stage 1 on both binaries, untouched).

## Law 1 — § varDeclInitMovesSharedTsEnd297 (switch `R11U297_VARINITTSEND_OFF`, ModuleEmit materializeDefNetTs)

**The face.** `typedef struct packed {...} t_t; var t_t b_init = '0;` golden's typedef t_t reads 53:11-54:22 in every
listing (the end of `'0`), ours 53:11-53:58 (k9b, 2 of its 4 records). `localparam type rt_t = id_t [3:0]; const
rt_t x = 8'h5a;` golden's packed_array_typespec reads 3:28-5:23, ours 3:28-3:38 (b06, all 4 records; i16 5 of 9).

**The law.** At the two writeNets sites materializeDefNetTs models: `tdNetEnd134` (the named struct, union or enum
typedef the definition net binds; scoped package names included) and the type-parameter default branch of
§ defNetTypeParamDefault137, the end (and file) goes to the initializer's end when no dimension wrote it.

## Law 2 — § varDeclInitElabSpan297 (switch `R11U297_VARINITSPAN_OFF`, ModuleEmit, three sites)

**The face.** k9b's elaborated `struct_net b_init` and its net-declaration cell Lhs: golden 54:11-54:22, ours
54:11-54:17 (its other 2 records). `import pk::*; var e_t s = B;` golden enum_var 7:11-7:16, ours 7:11-7:12 (v26, the
only record).

**The law.** The elaborated signal of the qualified data declaration takes `regNetSpan` (the declarator: the name
through the initializer) at the struct_net pattern-or-literal branch (which spans the name for a local typedef), at the
makeVar branch (enum_var and the other variables) and at the fresh net-declaration cell Lhs for a struct_net.

Laws 1 and 2 act together on most cases of the grid (both switches restore pristine's bytes only together there,
R11U297_OFF on every one); the cases where one law alone writes are attributed below.

## Law 3 — § nestedDefPortsNeedShell297 (switch `R11U297_NESTNOSHELL_OFF`, ModuleEmit emitModuleDefPorts)

**The face.** Every binary exited 139 (a null `DefInfo::mod` dereferenced in emitPorts, decoded with a debug build's
backtrace: `emitPorts` <- `emitModuleDefPorts` <- `emitInstance` <- `emitInstance` <- `exportDesign`) on any nested
module reached from a SECOND body of its outer (outer instantiated twice, `m01`; outer inside a for-generate,
`m05`; arrays or not) and on any module nested two levels deep (`m02`, `m03`, `m08`, `m09`). Surelog writes a
database for all of them.

**The decode.** slang mints a fresh DefinitionSymbol for a nested module declaration in every elaborated body of
its outer (`Compilation::createDefinition`; the § caNestedModPortedDefShell101 comment records it), and r11u99's
§ caNestedModDeepNoDefView99 drops a depth-2 definition from the table, so emitInstance's `!filled` branch reached a
definition with no shell. Golden lists the nested definition once (the representative body's, filled by its own
instance) and no definition at all for the deep one, while every elaborated instance is written in full.

**The law.** The port phase of a definition with no shell writes nothing and returns. MEASURED: the trace also fires
on 13 probe cases and MiniAmiq d/t, where the old port phase ran on a null shell (interface definitions, nested
interfaces, an outer instantiated twice whose nested module has no ports) and wrote nothing either: 0 of them move
in bytes (probe and corpus byteverify below).

## Grid (tools/probe/r11u297repro/cases; drivers/grid.sh, every line with its exit code)

63 case dirs in both views, 126 case-views: VI (51, laws 1 and 2: `v*` named for § varDeclInitMovesSharedTsEnd297,
`w*` for § varDeclInitElabSpan297, controls `*_ctl`) and NM (12, § nestedDefPortsNeedShell297). Configurations P
(pristine), L (law), OFF (law + `R11U297_OFF=1`) and the law with each switch off.

- 82 case-views moving, **46 entering STRICT_EQUAL, 0 leaving**, 20 exit-code changes (all 139 -> 0, NM), OFF equal
  to P in bytes and exit code on 126 of 126.
- Attribution: NESTNOSHELL alone 20, VARINITTSEND alone 14 (v15, v16, v17, v23, v29, v35, v36), VARINITSPAN alone 10
  (v06, v26, w08, w09, w10), both laws together 38 (v01, v02, v05, v07, v08, v10, v11, v12, v14, v18, v19, v20, v24,
  v25, v27, v28, v37, v38, v39: R11U297_OFF restores each).
- Away census (drivers/awaycv.sh: order-blind away.py and chain-keyed awaychain.py) on the 62 VI movers: lost 0 and
  chain away 0 on every one, 319 records toward golden; positive control (binaries swapped) away 1 to 12 on 8 of 8
  (evidence/grid_away.txt, grid_away_poscontrol.txt). Stage-1 movers (v06, v07, v14 default, v17, v20, v29 default,
  v36, w08, w10) keep their uhdm-cmp line count on both binaries.
- Downstream (drivers/dscases.py, both binaries): 32 cases improve and none worsens: v01, v02, v05, v06, v08, v10,
  v11, v12, v14, v19, v20, v24, v25, v26, v27, v28, v37, v38, v39, w08, w09, w10 EQUIVALENT -> IDENTICAL (the plugin's
  src attribute reads the variable's span) and m01 to m10 SLANG_REJECT -> IDENTICAL (evidence/downstream_cases.txt).
- Entering STRICT_EQUAL by case: v01, v02, v05, v08, v10, v11, v12, v16, v18, v19, v23, v24, v25, v26, v27, v28, v35,
  v37, v38, v39, w09 in both views; v14 and v29 in the elaborated view; NM m05 and m06 in the elaborated view.

| case (law named in its first line) | P default / elab | L default / elab |
|---|---|---|
| VI/v01_mod_struct_var `var t_t x = '0` (§ varDeclInitMovesSharedTsEnd297) | endline / endline | EQUAL / EQUAL |
| VI/v02_mod_struct_const (same) | endline / endline | EQUAL / EQUAL |
| VI/v03_mod_struct_nokw_ctl bare `t_t x = '0` (same) | EQUAL / EQUAL | unmoved |
| VI/v04_mod_struct_var_noinit_ctl (same) | EQUAL / EQUAL | unmoved |
| VI/v05_mod_enum_var (same) | endline / endline | EQUAL / EQUAL |
| VI/v06_mod_vec_var vector typedef (same) | stage 1 / stage 1 | stage 1, 1 record toward |
| VI/v07_pkg_struct_scoped_var (same) | stage 1 / stage 1 | stage 1, toward 5 / 3 |
| VI/v08_pkg_struct_import_var (same) | endline / endline | EQUAL / EQUAL |
| VI/v09_pkg_vec_scoped_var (same) | name / name | unmoved (§ defNetScopedPkgVecTdShares134's face) |
| VI/v10_two_decls_last, v11_two_lines_last, v12_init_then_noinit (same) | endline | EQUAL |
| VI/v13_unpacked_and_init (same) | stage 1 | unmoved |
| VI/v14_tp_struct_var (same) | stage 1 / endline | stage 1 / EQUAL |
| VI/v15_tp_packedarr_var (same) | endline / endline | fullname / fullname (the i16 face) |
| VI/v16_tp_vec_var (same) | endline / endline | EQUAL / EQUAL |
| VI/v17_iface_struct_var (same) | stage 1 | stage 1, toward 6 |
| VI/v18_child_twice, v19_static_kw (same) | endline | EQUAL |
| VI/v20_multiline_init (same) | stage 1 | stage 1, toward 7 / 5 |
| VI/v21_var_logic_ctl, v22_gen_block_var (same) | stage 1 | unmoved |
| VI/v23_program_var, v24_macro_init, v25_unit_typedef (same) | endline | EQUAL |
| VI/v26_enum_imported (same) | endcol | EQUAL |
| VI/v27_const_after_var, v28_nokw_after_var (same) | endline | EQUAL |
| VI/v29_pkg_struct_scoped_nokw (same) | stage 1 / endline | stage 1 / EQUAL |
| VI/v30 to v34 (packed-dim bare name, bare enum, scoped vector, scoped enum with and without var) (same) | EQUAL | unmoved |
| VI/v35_iface_enum_var (same) | endline | EQUAL |
| VI/v36_tp_enum_var (same) | stage 1 | stage 1 |
| VI/v37_crlf, v38_two_files_hdr (file), v39_macro_decl (same) | endline / file | EQUAL |
| VI/w01 to w07, w11, w12 (var / const / static over int, logic, bit, string, real; bare int; no initializer) (§ varDeclInitElabSpan297) | EQUAL or stage 1 | unmoved |
| VI/w08_var_vec_td, w10_var_class (same) | stage 1 | stage 1, toward 1 |
| VI/w09_const_enum_imp (same) | endcol | EQUAL |
| NM/m01 to m10 (§ nestedDefPortsNeedShell297) | exit 139 | written: m05 depth / EQUAL, m06 stage 1 / EQUAL, m07 count / count, m01 and m04 stage 1 / type, m02, m03, m08, m09, m10 stage 1 / stage 1 |
| NM/m11_inner_twice_once_ctl, m12_outer_twice_nested_portless (same) | EQUAL / stage 1 | unmoved |

## Gates (worktree at f85b3457, SLANG_UHDM exported per binary)

1. Builds: pristine `d3fc0099b42d8c498d08d3f19970782f` (equal to the main tree's build), law
   `5169a64e5a38e8dabd7f40d233dc589d`, both frozen read-only before any measurement; slang 12.0.0+545f88b2e.
2. `tests/sweep.sh --corpus probe` (inside the full sweep): pristine EQUAL 3952 + 135 (byte-identical csv to
   results/golden_probe.csv), law **EQUAL 3954 + 133, regressions=0 conversions=2 changes=1** (above).
3. surelog: CMP_EQUAL 480 / 474 (default / testflags), regressions 0, conversions 0, changes 0 on both binaries;
   uhdm2rtlil 803/1/67 both modes, 0/0/0.
4. downstream: EQUIVALENT 2, IDENTICAL 803, SLANG_REJECT 66 of 871 on both binaries, the two csvs and the committed
   baseline identical.
5. uhdm-cmp 0 lines on every touched probe case (the three movers) and corpus row (none moves).
6. byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered mirrors of both sweeps
   (drivers/bvmirror.sh): **MOVERS 0 / 3365** (surelog, uhdm2rtlil and downstream slang lanes), path sets identical,
   SELFCHECK 3363 of 3365 (the known twin). Probe: exactly 3 of 4087 databases move, the three predicted by name.
   The firing census (drivers/tracecensus.sh, frozen before the law sweep, evidence/predict.txt, 28 lines) named
   k9b, b06 and i16, and over-predicted where a trace fires on bytes the base already writes: VARINITSPAN on
   ApbSlave d/t, ClogCast d/t, Earlgrey_0_1 d/t and r10imex_repro/t3, VARINITTSEND on TypedefAliasInPackage d/t and
   typedef_package d/t, NESTNOSHELL on MiniAmiq d/t and 13 probe cases; none of them moves.
7. Away census on the probe movers: lost 0, chain away 0, toward 7 (k9b), 4 (i16), 4 (b06); positive control away 7,
   4, 4. With no corpus mover, the corpus away census is empty by construction.
8. Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both
   (EXPECT_UNKNOWN=1 surelog, EXPECT_UNKNOWN=6 uhdm2rtlil).
9. Binary-path audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary, the other 50 carry no
   `slang:` line, on both sweeps.
10. Determinism (drivers/det.sh, three concurrent draws): one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver,
    SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes (Scoreboard and Rggen testflags write none), each
    equal to the law sweep's.
11. Both sweeps exited 1 on the law-index check alone (tests/LAWS.md regenerated in the patch).

## Byte controls (drivers/controls.sh, both views, pristine vs law)

15 earlier repro dirs (r11u99, r11u101, r11u103, r11u119, r11u134, r11u137, r11u144, r11u152, v11u152, r11u160,
r11u170verify, r11u271, r11u275, r11u295, v11u295), 1123 case dirs, 2246 case-views: **20 moving, 8 entering
STRICT_EQUAL, 0 leaving**; 6 exit-code changes, all 139 -> 0: r11u295repro NA/n02_two_levels and n07_outer_twice and
v11u295repro VN/vn02_outer_in_genfor in both views (vn02 elaborated STRICT_EQUAL 335, n07 elaborated type, the rest
stage 1). The 14 others: r11u275repro TV/tv03_var_kw_ctl and tv04_const_ctl (pass 275's own var / const controls,
endline -> EQUAL in both views), r11u119repro g1 a10_pkgstruct_lit, c_scoped_struct_fill and c_scoped_struct_lit
(elaborated endline -> EQUAL, default stage 1 moving toward), c_scoped_struct_concat and c_scoped_structvar_lit
(stage 1, toward 2 to 3). Away census on the 14: lost 0, chain away 0, 52 records toward golden
(evidence/controls_away.txt). uhdm-cmp line counts unchanged on every stage-1 mover.

## Residues, ranked

1. The nested-module shapes the crash fix opens (NM): an outer reached a second time elaborates its nested
   instance's contents against the second body's own definition (m01 elaborated `type` at the second instance's
   `assign r = 1'b1`, golden a ref_obj where ours folds the constant; m04, m06, m12 default stage 1, m05 default
   `depth`): the fix is to read the representative body's DefInfo for the per-body twin (ModuleEmit emitInstance).
   The depth-2 definitions (m02, m03, m08, m09) are stage 1 where golden has no definition for c_m but our
   elaborated instance lists objects golden puts elsewhere; m10 a nested module with internal nets reached twice.
2. i16_var_kw_init and VI/v15 (`differ:fullname(5)`): with the move in place golden's elaborated variable shares the
   rebuilt type-parameter array (the § tpElemRebindDefView107 object, element reference named work@dut.x.id_t)
   while ours gives the elaborated variable its own unmoved copy; UhdmExporter rebindTypeParamElem107's ground.
3. The data-declaration shapes still at stage 1 on both binaries: a vector typedef (v06, w08), `var logic` (v21),
   a package-qualified struct with `var` (v07) or without (v29 default), an interface struct (v17), a type parameter
   struct or enum (v14 default, v36), a multi-line pattern (v20), a generate block (v22), an unpacked dimension with
   an initializer (v13), a class handle (w10).
4. The probe residue as classified at the base (evidence would repeat pass 293's residue_first_records_base.tsv):
   133 cases, the module/type faces listed in the brief's item (1) standing (the positional modport actual grid2 / vA,
   the package-function formal typedef listing vxpkg8 / t42a / a6_type / v62e_bind, the struct-valued function fold
   n11 / v15 / v2_kindns on the expression ground, the count(0) g99_a2_proc / g99_a9_fence extra Lhs net under the
   def-view cont_assign).

Sister-ground faces (reported, not written): the struct-valued function fold's member names (r11u24repro n11,
r11v21repro v15, ParamEmit), the folded-constant spans p1_pos115, a1_axis121, v4_ops, c9_litarith_noovr, a3_inst66,
k11_logic_param_range (ExprEmit / ParamEmit).

## Process

The implementer started the pristine build twice into one build tree (the first background shell kept running
after its wrapper returned), so the second build failed; the first one finished and its binary matched the main
tree's md5. The fence was read fail-closed from tools/probe/r11u107repro/canaudit.sh and never spelled; every path
list was filtered before any file was opened; no fenced source or database was read; gdb ran only on the fresh case
`/tmp` copy; no other agent's process was listed or signalled; the main tree was not written.
