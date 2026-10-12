# r11u295 — module/type ground: escaped-identifier name spans, raw span ends through the line model, the nested module array's scoped name, dynamic and associative struct-member spans

Base 2baa2091 (pass 293). Four laws behind `src/R295.h`, three in ModuleEmit (one with a site in UhdmExporter) and
one in TypeEmit. Each law reads its own `R11U295_<LAW>_OFF` switch. `R11U295_OFF` drops all four and gives
pristine's bytes on 128 of 128 grid case-views. `R11U295_TRACE=<dir>` logs every firing that writes (one file per
process, `OUT <-o path>` first).

**FIVE PROBE CONVERSIONS**, no probe change, no regression. No corpus database moves in bytes (0 of 2560
fence-filtered corpus databases, 0 of 805 downstream slang-lane databases), so no corpus row changes status or
strict column.

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| r10earl54repro/v3_v54 | `endcol(5)` | **EQUAL** | § escNameSpanSites295 |
| v11u110repro/brk/v3/a36_escaped_inst_name | `endcol(1)` | **EQUAL** | § escNameSpanSites295 |
| r10v223repro/arms/v5_escaped | `endcol(2)` | **EQUAL** | § rawEndLineModel295 |
| v11u93repro/grid/b07_rv2arr | `fullname(1)` | **EQUAL** | § nestedModArrayScopedName295 |
| r10earl29repro/v10_str | `endcol(4)` | **EQUAL** | § dynAssocMemberSpanToDim295 |
| probe | EQUAL 3941 + STRICT_NOTEQUAL 146 | **EQUAL 3946 + STRICT_NOTEQUAL 141** | regressions 0, changes 0 |
| surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

All five conversions are STRICT_EQUAL in the elaborated view too (`EL=1`, evidence/probe_movers.txt).

## Law 1 — § escNameSpanSites295 (switch `R11U295_ESCNAMESPAN_OFF`, ModuleEmit + one UhdmExporter site)

**The face.** slang's symbol name for an escaped identifier `\u.x ` is `u.x`: no backslash, no blank. Eight sites
wrote a name span by hand as `location + name.size()`, which ends one column inside the lexeme, so
§ escIdPpColumnShift146's clamp (a token end inside the escaped lexeme's blank run reads the column after the run)
never saw it. Golden `child \u.x (...)` ref_module 4:9-4:18, ours 4:9-4:16; two blanks golden 4:9-4:20; the
named-connection LowConn at `.\a.p (a)` golden 4:19-4:28, ours -26; `child \u.arr [1:0]` module_array 4:9-4:20,
ours -18.

**The decode.** Surelog's preprocessor writes the lexeme `\` + name + blanks back as `#~@` + the text without its first
and last character + `#~@` (SV3_1aPpTreeShapeListener::enterEscaped_identifier, EscapeSequence in
CommonListenerHelper.h), and the parser's Escaped_identifier token spans that whole output: the name, every blank but
the last, and both markers, i.e. the column after the blank run on the output line. `UhdmExporter::nameSpan` already
models that span and every net, port and variable reaches it through setLocNamed.

**The law.** The hand-written sites take `nameSpan` (an `ESC_NAME_SPAN295` macro in ModuleEmit; the trace fires only
where the span differs): the instance's ref_module stub (resolved, `ref_module`, and uninstantiated,
`ref_module_uninst`), the module_array (`module_array`), the named-connection LowConn ref_obj at the formal's name
(`lowconn_port`, `lowconn_iface`, `lowconn_iface9`, `lowconn_portview`), the assertion property_decl
(`property_decl`) and, in UhdmExporter, the `$unit` parameter (`unit_parameter`). A location in a macro expansion keeps
the hand-written span.

Cases (each first line `// § escNameSpanSites295`): cases/ES e01_inst_one_space, e02_inst_two_spaces,
e03_formal_named, e04_formal_positional (control: positional, no named formal), e05_iface_inst, e06_gen_block (control:
the generate-block route already spans through nameSpan), e07_inst_array, e08_params, e09_two_on_line,
e10_esc_module_and_inst, e11_program, e12_three_levels, e13_plain_ctl (control), e14_iface_port_named,
e15_ifc_array_inst, e16_hdr_line_esc, e17_crlf (CRLF file), e18_unit_param, e19_property, e23_iface_named_formal,
e24_iface_inst_child, e25_uninst_parent (no firing: the stub of an uninstantiated parent does not reach the site).
Three shapes have no golden and were dropped: an escaped identifier ended by a TAB, by a newline, and inside a macro
argument (`\u.mac )`) all fail Surelog's parser with syntax errors.

## Law 2 — § rawEndLineModel295 (switch `R11U295_RAWEND_OFF`, ModuleEmit)

**The face.** An end written straight from slang's SourceManager (`sm->getLineNumber / getColumnNumber` of the end
location) skips the line model setLoc applies to every other column, so a span ending after an escaped identifier, a
squeezed based literal (`8'h 5`, § ppBasedLitWsAfter166) or a one-line macro call on its line reads the source
column where golden reads Surelog's preprocessed one; an end in a macro expansion read column 0 of the macro buffer.
Golden `int \v.a = 1;` imported into a module: the copy's int_typespec 3:3-3:19, ours 3:3-3:15; `logic [7:0] \n.y =
8'h3;` the definition net's typespec 3:3-3:30, ours -26; `logic [`W-1:0] nz = `INIT;` 5:3-5:26, ours 5:3-5:0;
`logic [7:0] vs = 8'h 5;` imported, the end after the squeeze.

**The decode.** Surelog's parser reads the preprocessor's output line, and the end-only re-stamps of the definition
and import-copy nets' typespecs (UhdmWriter::writeNets' `populateCoreMembers(InvalidNodeId, end)` and
compileTypespec's declarator end, the § defNetEndOnlyLoc130 / § importNetTsToInitEnd183 / § importNetTsDimEnd275
decodes) are positions in that output like any other.

**The law.** `SET_END295(obj, start, end, site)` writes the end through setLoc (the start written back untouched) at
the sites IMPINIT (§ importNetTsToInitEnd183), IMPDIM (§ importNetTsDimEnd275), DEFNETINIT, DEFNETFIRST and DEFNETELEM
(materializeDefNetTs' end-only writes). The two import-copy stretches, which skipped a macro-expanded end
altogether, now take it (IMPINITMAC, IMPDIMMAC: golden `logic [7:0] vz = `INIT;` imported, 4:3-4:24, ours the type
alone 4:3-4:14). The § netEndCol171 fallback for a declaration touching a paste keeps its raw reading (that law's own
decision). TypeEmit's struct-member fixed-size end (the § queueMemberSpanToDim212 note keeps it raw) is not touched.

Cases (each first line `// § rawEndLineModel295`): cases/ER r01_imp_init_mod, r02_imp_init_ifc, r03_imp_arr,
r04_def_net_arr (control), r05_def_net_init, r06_struct_member_arr (stage 1, unmoved), r07_two_decls (control),
r08_port_arr (moved by law 1: an escaped formal in a named connection), r09_imp_plain_ctl (control),
r10_pkg_struct_member (control), r11_macro_on_line_def, r12_macro_on_line_imp, r13_based_squeeze, r14_strlit_shift
(stage 1, unmoved), r15_esc_imp_arr_ifc, r16_esc_def_net_wire_init (control), r17_esc_two_on_line, r18_macro_init_imp,
r19_macro_whole_decl, r20_macro_multiline, r21_macro_dim_imp, r22_macro_arg_init, r23_macro_init_def_int.

## Law 3 — § nestedModArrayScopedName295 (switch `R11U295_NESTARRNAME_OFF`, ModuleEmit emitModuleArray)

**The face.** `module bmod; module innermod ...; innermod u_i [1:0] (...)`: golden's elaborated module_array under
work@dut.u_b reads full name `work@bmod::innermod`, ours `work@innermod`. The definition view's module_array reads the
bare `work@innermod` in golden (a first draft scoping both views moved the definition-view record away: n01 read
`work@outer::inner` against golden's `work@inner`; restricted before delivery).

**The decode.** Surelog files a module declared inside another module as `work@<outer>::<inner>`
(§ caNestedModDefNameScoped99) and the elaborated instance's module_array takes the full name of the definition it
instantiates; the definition view's array, like the ref_module stub's defname (§ caNestedModRefNoActual99), keeps the
instantiation text.

**The law.** In the elaborated call (the one passing the element list `modElems`), the module_array's full name is
`"work@" + defScopedName99(def)`.

Cases (each first line `// § nestedModArrayScopedName295`): cases/NA n01_nested_unique, n02_two_levels (rc=139 on
both binaries, below), n03_nested_in_gen (stage 1, unmoved), n04_toplevel_ctl (control), n05_dup_names,
n06_nested_two_insts, n07_outer_twice (rc=139 on both binaries, below).

## Law 4 — § dynAssocMemberSpanToDim295 (switch `R11U295_DYNMEMSPAN_OFF`, TypeEmit struct builder)

**The face.** `typedef struct {logic [7:0] m[string];} sq_t;`: golden's typespec_member m 12:31-12:40, ours the name
12:31-12:32.

**The decode.** buildTypespecMember locates every member at its Variable_decl_assignment, whose extent runs through
the variable dimension whatever its kind (the § queueMemberSpanToDim212 decode, which extended only the queue form and
left the dynamic and associative forms unclaimed because its grid read them at stage 1).

**The law.** A member whose canonical type is a dynamic or associative array takes the queue form's road:
`setLoc(member, [name, last dimension end])`, through the line model.

Cases (each first line `// § dynAssocMemberSpanToDim295`): cases/DM d01_mod_assoc_str, d02_mod_assoc_int, d03_mod_dyn
(stage 1, moved toward), d04_mod_assoc_wild, d05_pkg_assoc, d06_pkg_dyn (stage 1, moved toward), d07_class_assoc
(stage 1, moved toward), d08_unit_dyn (stage 1, moved toward), d09_macro_member, d10_fixed_queue_ctl (control),
d11_multiline_dim, d12_two_dims. The stage-1 head of the dynamic shapes is golden's `unsupported_expr` for a `[]`
member dimension (a Surelog quirk, not copied).

## Measurements (final law binary c8c36f21, pristine 4d4a234d = the main tree's build at the base, byte-identical)

Both binaries frozen read-only under the pass's scratch before any measurement; uhdm-strictcmp fa6e4f42 from the
worktree build. Every case-view line carries its exit code (evidence/grid.txt, controls.txt).

- **Grid** (drivers/grid.sh through a parallel wrapper; gridsum295.py): 64 case dirs, 128 case-views in ES, ER, NA and
  DM, each on P, L, OFF and the law with each switch off: 96 moving, 70 entering STRICT_EQUAL, 0 leaving, 0 exit-code
  changes; `R11U295_OFF` restores pristine's bytes on 128 of 128; every mover restored by exactly one switch
  (ESCNAMESPAN 38, RAWEND 30, DYNMEMSPAN 22, NESTARRNAME 6) (evidence/grid_summary.txt).
- **Away census** (drivers/awaycv.sh: away.py order-blind + awaychain.py chain-keyed) over all 96 grid movers: lost 0,
  chain away 0, 225 records toward golden (evidence/grid_away.txt). Positive control (binaries swapped) on 8 movers
  across the four families: away 1 to 8 on 8 of 8 (evidence/grid_away_poscontrol.txt).
- **Byte controls** (drivers/controls.sh, fence-filtered path lists) over 17 earlier repro dirs (r11u130, r11u146,
  v11u146, r11u171, r11u183dec, r11u212, v11u212, r11u224, v11u224, r11u231, r11u275, v11u275, r11u99, r11u293,
  v11u293, r11u291, v11u291): 1447 case dirs, 2894 case-views, 10 moving, 6 entering STRICT_EQUAL
  (r11u171repro/cases/K/k12_stringified_neighbour d/e under RAWEND; v11u146repro/cases/esc/x2_inst d/e and
  v11u291repro/cases/VT/vt14_escaped_inst d/e under ESCNAMESPAN), 4 moving at stage 1 (r11u212repro/cases/QM/q02 d/e
  under DYNMEMSPAN, toward 6 each; v11u146repro/cases/esc/x11_hier d/e under ESCNAMESPAN, toward 1 each), 0 leaving,
  0 exit-code changes, lost 0 and chain away 0 on all 10 (evidence/controls.txt, controls_away.txt).
- **Firing census** frozen before the law sweep (drivers/tracecensus.sh under `R11U295_TRACE`, the fence filter on
  every harness call): exactly the 5 probe databases, 0 Surelog and 0 uhdm2rtlil row-modes (evidence/predict.txt).
- **Gate sweeps** (tests/sweep.sh --jobs 3, probe + surelog + uhdm2rtlil; evidence/sweep_P.log, sweep_L.log):
  pristine probe 3941 + 146, regressions 0; law probe **3946 + 141, regressions 0, conversions 5, changes 0** (the
  five above); surelog default 480 / testflags 474 CMP_EQUAL with 0 STRICT_NOTEQUAL and regressions 0, conversions 0,
  changes 0 on both binaries; uhdm2rtlil 803/1/67 in both modes with 0/0/0. Both sweeps exited 1 on the law-index
  check alone (this pass's cases are new until scripts/law_index.py runs, which it does last).
- **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors, drivers/bvmirror.sh,
  same-length workdir names): MOVERS 0 / 2560, PATH_SETS_IDENTICAL, SELFCHECK 2559 / 2560 (the known artefact)
  (evidence/byteverify_corpus.txt); probe databases 5 of 4087 moving, exactly the predicted five
  (evidence/byteverify_probe.txt); away census on all ten probe case-views of the five: lost 0, chain away 0, toward
  1 to 5 (evidence/probe_movers_away.txt).
- **Downstream** (scripts/downstream_uhdm2rtlil.py --jobs 3, run one at a time): pristine and law both 803 IDENTICAL /
  66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict diff 0, 0 of 805 fence-filtered slang-lane databases moving
  in bytes (evidence/downstream_law.csv).
- **Canaries**: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 surelog PASS,
  EXPECT_UNKNOWN=6 uhdm2rtlil PASS (the sweep csv holds both modes).
- **Binary-path audit**: 3273 of 3323 cmds.txt in each sweep name that sweep's own binary, the other 50 carry no
  slang line, none names the other binary (evidence/binary_audit.txt).
- **Determinism** (drivers/det.sh): three concurrent draws per row-mode of the law binary on Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, one hash per row-mode, each equal to both sweeps' hash
  (Scoreboard and Rggen testflags write no database) (evidence/determinism.txt).
- uhdm-cmp reads 0 lines on every touched probe case in both views; no corpus row is touched.

## Residues (ranked; all wrong on pristine too)

1. **The nested-module crash** (cases/NA n02_two_levels, a two-level nested module with an instance array, and
   n07_outer_twice, an outer module with a nested module array instantiated twice): exit 139 on pristine and law, in
   `UhdmExporter::emitPorts` called from `emitModuleDefPorts` under `emitInstance` (release backtrace; a debug build
   was not made). ModuleEmit, this ground; the next law here.
2. **The positional modport actual** (probe r11u1repro/grid2, r11v1repro/vA, col(2)): a positional connection
   `m (u_df.mp, ...)` gives golden's hier_path a first element `u_df` located at the modport token `mp` and leaves the
   `mp` element without a stored full name, where the named form `.q(u_df.mp)` keeps both as ours writes them. The
   writer in Surelog's ordered-connection road (NetlistElaboration high-conn and compileComplexFuncCall) was not
   pinned; ModuleEmit's port high-conn, this ground.
3. **The elaborated module_array bound naming** (probe r10earl104repro/vb4_instarr fullname(1)): the elaborated
   array's `X[0]` bound keeps the stored `work@vb4_instarr.u_ia.X` where golden stores none (the elaborated range is
   unparented); every fresh shape of an `X[0]` bound read stage 1 on pristine (uhdm-cmp 26 to 111 lines) so no grid
   could gate a law; ModuleEmit emitModuleArray's mkBound.
4. **Escaped identifiers at stage 1** (ES e05, e14, e15, e18, e23: interface instances, interface ports and a $unit
   parameter with escaped names; each moved toward golden, 1 or 2 records): the stage-1 heads are elsewhere (the
   hierarchical reference `\i.f .d`, the $unit parameter's typespec reference) and were not decoded.
5. **The dynamic struct member's `unsupported_expr`** (DM d03, d06, d07, d08 and r11u212repro QM/q02): golden writes
   an `unsupported_expr` for a `[]` member dimension (a Surelog quirk; following it would copy a defect).
6. **Raw ends left raw**: TypeEmit's struct and union fixed-size member ends and `structTypedefUseEnd`'s stretch, and
   ModuleEmit's § netEndCol171 paste fallback, still read SourceManager columns; ER r06 (an escaped struct member with
   an unpacked dimension) is stage 1 and could not gate them.
7. The rest of the base residue as pass 293 classified it (tools/probe/r11u293repro/evidence/residue_first_records_base.tsv):
   141 probe cases, by first field fullname 51, line 17, type 14, depth 11, file 11, endcol 9, col 8, name 7,
   endline 6, value 4, count 2, decompile 1; the brief's items (2) to (7) beyond the above were not attempted.

**Sister-ground faces seen on the way (reported, not written):** the parameter-evaluation int typespec of an
interface array element's param_assign (r10rgg3repro/f1_noovr_arr_recvp file(3): golden unlocated where a sibling
parameter reads the parameter, ParamEmit); the wildcard-import clone locals named after the explicit importer
(r10uvm122repro/g122_f_clone, r10v122repro/q6clone; the clone family); the case_item location in class functions
(r10uvm158repro/g158_a_shape, r10v158repro/v158_d, StmtEmit); the cast typespec locations (r10uvm59repro/c05_cast,
r10vrgg9repro/cells/v_pred_cast, ExprEmit).

## Process

- The implementer read the fence fail-closed (drivers/env.sh reads the FENCED= line of r11u107repro/canaudit.sh),
  never spelled it, filtered every path list before opening any file (the byteverify mirrors, the probe and
  downstream byte compares, the controls), ran gdb only on a fresh case copy (NA/n07), read or ran nothing fenced,
  and did not write the main tree.
- **SLIP, no effect:** one background waiter used `pgrep -f` with a pattern that matched its own command line; it was
  stopped by its own task id before it listed or signalled anything and replaced by a log-based waiter.
- **SLIP, no effect:** the copied drivers lost their executable bits, so the first byte-control run printed
  "Permission denied" for every case and wrote nothing; the bits were restored and the controls rerun in full. The
  copied C++ drivers had their copy-note line written with `#`; fixed to `//` before strictcmp_x was built.
- The predictor (the firing census) was frozen after the last law and before the law sweep.
</content>
</invoke>
