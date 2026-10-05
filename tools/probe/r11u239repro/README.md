# r11u239 — pass 239, the module/type ground (pair B, refill after pass 237)

Base 40f5caf7 (pristine md5 273961bd0118143bb6c037c332f9ff30, slang 12.0.0+545f88b2e). Three laws behind
`src/R239.h` (each `R11U239_<LAW>_OFF`; `R11U239_OFF` drops all three and gives the base's bytes on every case;
`R11U239_TRACE=<dir>` logs every firing). Binaries ([evidence/binaries_md5.txt](evidence/binaries_md5.txt)): pristine
273961bd0118143bb6c037c332f9ff30 (the main tree's md5), law 8978a39fd0ca596fc89560824720d8a4, uhdm-strictcmp
fa6e4f42f252ae0ab69d9845003e71c5, both built in the worktree with the system-deps config and frozen read-only before
any measurement; the law binary reports slang 12.0.0+545f88b2e. Every number below was measured with these two
binaries after the resume (the first run's binaries are not cited).

## Verdict per targeted row

| row-mode | base strict | law strict | first record now |
|---|---|---|---|
| Earlgrey_0_1 default | `differ:fullname(5)` | `differ:col(2)` | #122230 (a ternary package parameter located at its taken branch, flash_phy_pkg.sv 43:53 vs ours 43:28) — ground A |
| Earlgrey_0_1 testflags | `differ:fullname(5)` | `differ:col(2)` | #123704, the same record — ground A |
| Rggen default (not a brief target; its head was on this ground) | `differ:file(3)` (walk diverged) | `differ:line(202)` | #23546, ground A (below) |

No row converts. Earlgrey's three ground-B records (#121994/#123468, #123996, #123586) are cleared; its remaining two
(#122230 and #130430, `range` vs `ref_typespec` at hmac_pkg.sv 26:35, structural) are ground A. Rggen's head
(#23164-#23166) is cleared and the walk now reaches 5117 more golden records (away census: 0 lost); the 202 differing
objects behind it were hidden by the old divergence (pristine holds every one of them, see Residues).

Probe: four conversions STRICT_NOTEQUAL -> EQUAL (r10rgg8repro/cells/h_full, h_modport, h_mp_noports,
r10vrgg8repro/cells/v8_ctx_iface), all § modportArgVarFormalTs239.

## The laws

1. **§ genConnOpSelIdxScope239** (`R11U239_OPSELIDX_OFF`, ModuleEmit `emitDefGenStmts`, `mkOpSelLeaf9`). In a
   generate-scope port connection whose actual is an operation, a select leaf `v[i]` is built by the syntax walk with
   the bit_select named `<inst>.<formal>.v`; its index was named through that doubled scope
   (`...host_req_i.host_rsp_avail.bank`). Golden names a BARE identifier index through the connection's scope
   (`...host_req_i.bank`, Earlgrey #121994 / #123468, #123996); refs inside an operation index (`v[i+1]`, `v[3-i]`) keep
   the doubled scope (OS a03, a06 equal at the base and untouched).
2. **§ genLpSysCallArgName239** (`R11U239_GENLPSYSARG_OFF`, ModuleEmit `emitDefGenStmts`, the generate-scope localparam
   `param_assign`). TypeEmit `emitSyntaxExpr`'s raw-text fallback for a system call's NAME-shaped argument writes no
   full name (right for a generate-scope variable range, GL c02, and kept there); in a generate-scope localparam golden
   names it through the branch (`work@prim_arbiter_tree.gen_normal_case.N`, Earlgrey #123586), as the same name under
   an operation already is (GL b03). The law names the call's identifier arguments at the param_assign site, so
   TypeEmit is untouched. Measured on if/else, for, case and nested blocks, `$clog2`, `$bits` of a net and of a
   typedef, a localparam and a module parameter argument.
3. **§ modportArgVarFormalTs239** (`R11U239_MPARGTS_OFF`, UhdmExporter, design-final in `finish231`).
   `UhdmWriter::writeCont_assign` reduces every continuous assignment's right side and `ExprEval::evalFunc`
   (third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp, "set args") re-points each actual's typespec in place:
   `exparg->Typespec()->Actual_typespec(tps)`. A `port.member` actual through a MODPORT-qualified interface port
   reduces to the port view's io_decl variable, so that variable takes the function's formal typespec whether or not
   the call then folds (Rggen's `pre_decode` folds to `'1`; golden's `u_adapter_common.bus_if.address` types with its
   formal `logic [ADDRESS_WIDTH-1:0]`, rggen_adapter_common.sv 43:5). `writeInstance` writes a module's own
   assignments, then its generate scopes in order, so the LAST call met wins (MA e13, e14, e16-e19, f01-f05). The law
   walks slang's continuous assignments and net-declaration assignments of every instantiated module body (its own,
   then generate blocks recursively) through the operators ExprEval reduces (`+ - * / % & |`, comparisons, `&& ||`,
   shifts, `**`, unary, `?:`, concatenation, replication); an operation holding a plain net or variable read anywhere
   is not reduced (MA e06, e15: a modport member read beside it does not block, e01); a nested call's arguments are
   walked first (x05). Module-local and package functions, named arguments (x04), selects of the member (d06, e10),
   enum and packed-struct members (x03), positional connections (x01), a bound module (x07) all stamp. NOT stamped:
   XOR (e02), an argument expression (e07), always_comb (d04), a generic interface port (d10, x06), an interface
   instance of the same module (d09), an interface body (x09). The instance is found by the path of stored names
   (gen_scope_array names; a gen_scope's own name is not repeated). A formal with no typespec is left alone (evalFunc
   would mint a logic_typespec). Traced `modportArgVarFormalTs239 <inst> <port>.<member> <fn>#<idx>` where the
   typespec moves.

## Cases (tools/probe/r11u239repro/cases, 76; every first line names its law)

OS (genConnOpSelIdxScope239: pass 236's decode g01 g02, a01-a08, x01-x02), GL (genLpSysCallArgName239: pass 236's g03,
b01-b09, c01-c08, x01-x02), MA (modportArgVarFormalTs239: d01-d10, e01-e19, f01-f05, x01-x10; x10 is CRLF with the
argument written through a macro). Grid: every case in both views under six configurations (pristine, law,
`R11U239_OFF`, each switch alone off): 912 lines, every exit code 0 ([evidence/grid/grid.txt](evidence/grid/grid.txt)).

| case | law | default p -> law | elab p -> law |
|---|---|---|---|
| GL/b01 | § genLpSysCallArgName239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| GL/b02 | § genLpSysCallArgName239 | EQ -> EQ | EQ -> EQ |
| GL/b03 | § genLpSysCallArgName239 | EQ -> EQ | EQ -> EQ |
| GL/b04 | § genLpSysCallArgName239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| GL/b05 | § genLpSysCallArgName239 | EQ -> EQ | EQ -> EQ |
| GL/b06 | § genLpSysCallArgName239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| GL/b07 | § genLpSysCallArgName239 | EQ -> EQ | EQ -> EQ |
| GL/b08 | § genLpSysCallArgName239 | stage1 -> stage1 | stage1 -> stage1 |
| GL/b09 | § genLpSysCallArgName239 | EQ -> EQ | EQ -> EQ |
| GL/c01 | § genLpSysCallArgName239 | stage1 -> stage1 | stage1 -> stage1 |
| GL/c02 | § genLpSysCallArgName239 | EQ -> EQ | EQ -> EQ |
| GL/c03 | § genLpSysCallArgName239 | stage1 -> stage1 | EQ -> EQ |
| GL/c04 | § genLpSysCallArgName239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| GL/c05 | § genLpSysCallArgName239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| GL/c06 | § genLpSysCallArgName239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| GL/c07 | § genLpSysCallArgName239 | SNE:fullname -> SNE:file | SNE:fullname -> SNE:file |
| GL/c08 | § genLpSysCallArgName239 | EQ -> EQ | EQ -> EQ |
| GL/g03 | § genLpSysCallArgName239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| GL/x01 | § genLpSysCallArgName239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| GL/x02 | § genLpSysCallArgName239 | stage1 -> stage1 | stage1 -> stage1 |
| MA/d01 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/d02 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/d03 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/d04 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/d05 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/d06 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/d07 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/d08 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/d09 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/d10 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/e01 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e02 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/e03 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e04 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e05 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e06 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e07 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/e08 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e09 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e10 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e11 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e12 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e13 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e14 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e15 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/e16 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e17 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e18 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/e19 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/f01 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/f02 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/f03 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/f04 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/f05 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/x01 | § modportArgVarFormalTs239 | stage1 -> stage1 | stage1 -> stage1 |
| MA/x02 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/x03 | § modportArgVarFormalTs239 | SNE:type -> EQ | SNE:type -> EQ |
| MA/x04 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/x05 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/x06 | § modportArgVarFormalTs239 | EQ -> EQ | EQ -> EQ |
| MA/x07 | § modportArgVarFormalTs239 | SNE:line -> EQ | SNE:line -> EQ |
| MA/x08 | § modportArgVarFormalTs239 | SNE:file -> SNE:file | SNE:file -> SNE:file |
| MA/x09 | § modportArgVarFormalTs239 | stage1 -> stage1 | stage1 -> stage1 |
| MA/x10 | § modportArgVarFormalTs239 | SNE:line -> SNE:line | SNE:line -> SNE:line |
| OS/a01 | § genConnOpSelIdxScope239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| OS/a02 | § genConnOpSelIdxScope239 | stage1 -> stage1 | stage1 -> stage1 |
| OS/a03 | § genConnOpSelIdxScope239 | EQ -> EQ | EQ -> EQ |
| OS/a04 | § genConnOpSelIdxScope239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| OS/a05 | § genConnOpSelIdxScope239 | EQ -> EQ | EQ -> EQ |
| OS/a06 | § genConnOpSelIdxScope239 | EQ -> EQ | EQ -> EQ |
| OS/a07 | § genConnOpSelIdxScope239 | EQ -> EQ | EQ -> EQ |
| OS/a08 | § genConnOpSelIdxScope239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| OS/g01 | § genConnOpSelIdxScope239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| OS/g02 | § genConnOpSelIdxScope239 | SNE:fullname -> EQ | SNE:fullname -> EQ |
| OS/x01 | § genConnOpSelIdxScope239 | stage1 -> stage1 | stage1 -> stage1 |
| OS/x02 | § genConnOpSelIdxScope239 | stage1 -> stage1 | stage1 -> stage1 |

## Measurements

* **Grid** (152 case-views, 912 lines, every line `rc=0`; [evidence/grid/summary.txt](evidence/grid/summary.txt)): pristine -> law 88 STRICT_NOTEQUAL -> STRICT_EQUAL, 50 identical, 14 bytes moved with the
  same verdict (stage-1 cases at the base keep their uhdm-cmp line counts: GL b08 17, GL x02 17, MA x01 264, OS a02
  46/50, OS x01 46/50; GL c07 moves fullname -> file (its next record, an elaborated gen localparam's int_typespec
  with no file in golden, ParamEmit); MA x08 stays `file`), none leaving equality. `R11U239_OFF` = pristine bytes on
  152 of 152. Each switch alone off: OPSELIDX 78 conversions remain, GENLPSYSARG 72, MPARGTS 26. Away census
  (chain-keyed, awaycase.py): 0 lost, 466 toward ([evidence/grid/away.txt](evidence/grid/away.txt)).
* **Downstream on the cases** (dscase.py, 76 cases): IDENTICAL->IDENTICAL 62, EQUIVALENT->EQUIVALENT 9 (+2 rows whose
  differs column parses as `il`), EQUIVALENT->IDENTICAL 1 (MA d07), IDENTICAL->EQUIVALENT 2 (MA e13, e14). Every one
  of the five movers differs only in the ORDER of the RTLIL modules in `_nohier.il` (the sorted files are equal): an
  object-order coin of the plugin, not a value. The downstream lane's own Surelog writes a database strict-equal to
  the law's on e13. Re-measured after the resume: e13 under uhdm2rtlil's own Surelog with the downstream flags
  against the law binary reads `STRICT_EQUAL 301 objects` (pristine `STRICT_NOTEQUAL line`); e13 and e14's law
  `_nohier.il` and d07's pristine one differ from the Surelog lane's raw but not sorted. (The first run also saw
  three unkept variants move the same coin both ways; not re-measured, not cited.)
* **Prediction** frozen at 02:21Z, before the law sweep started ([evidence/census/predicted.txt](evidence/census/predicted.txt), body md5
  7e054738a46345bac3fc481f3f80197f): the law binary's traced firing census over both corpora (filter built from
  $FENCED, not the gate) and fire.py over the 4087 probe cases in both views: Earlgrey_0_1 d/t (OPSELIDX 8 firings,
  GENLPSYSARG 4), Rggen d (MPARGTS), probe r10rgg8repro h_full, h_modport, h_mp_noports, r10vrgg8repro v8_ctx_iface;
  0 uhdm2rtlil databases, hence 0 downstream lanes. The census's own compare: surelog `changes=3`, uhdm2rtlil 0.
* **Gate sweeps** (tests/sweep.sh --jobs 3 from the worktree, SLANG_UHDM the frozen binary; summaries
  [evidence/sweep/sweep_P_summary.txt](evidence/sweep/sweep_P_summary.txt) and
  [evidence/sweep/sweep_L_summary.txt](evidence/sweep/sweep_L_summary.txt)). Pristine: every stage regressions=0
  conversions=0 changes=0, probe EQUAL 3463 + STRICT_NOTEQUAL 624, surelog default 469 + 11, testflags 465 + 9,
  uhdm2rtlil 803 + 0 per mode, downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, rc 0. Law: probe
  **EQUAL 3467 + STRICT_NOTEQUAL 620, regressions=0 conversions=4 changes=0** (the four CONVERSIONS
  `r10rgg8repro/cells/h_full,EQUAL,,equal`, `r10rgg8repro/cells/h_modport,EQUAL,,equal`,
  `r10rgg8repro/cells/h_mp_noports,EQUAL,,equal`, `r10vrgg8repro/cells/v8_ctx_iface,EQUAL,,equal`, each from
  `STRICT_NOTEQUAL differ:line(3|4)`); surelog **regressions=0 conversions=0 changes=3**
  (`Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)`, the same for testflags, and
  `Rggen,default,STRICT_NOTEQUAL,differ:line(202),,differ:line(202)`; Rggen testflags is SURELOG_FAIL on both); uhdm2rtlil
  regressions=0 conversions=0 changes=0 (803 + 0 per mode); downstream 803 / 66 / 2 / 0, verdict diff against the
  pristine sweep 0 lines ([evidence/sweep/downstream_verdict_diff.txt](evidence/sweep/downstream_verdict_diff.txt)),
  rc 0 (the law index is current). uhdm-cmp on the three touched corpus row-modes: 0 lines each; the four probe
  movers read EQUAL.
* **Canaries**: canaries.sh on the law surelog csv ok 50, changed 2 (Earlgrey_0_1 d/t, the predicted changes), absent
  0, unknown 7 (the u2r-only names); on the u2r csv ok 16, changed 0; ctcan2.sh (EXPECT_UNKNOWN=1) surelog ok 58,
  changed 0, PASS; (EXPECT_UNKNOWN=6) u2r ok 2, changed 0, PASS.
* **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1,
  [evidence/sweep/byteverify.txt](evidence/sweep/byteverify.txt)), run on symlink trees of the two sweeps built from
  a path listing filtered by $FENCED first (so no fenced database is opened; byteverify.sh itself has no fence
  check): surelog 3 movers of 952 (Earlgrey_0_1 d/t, Rggen d), uhdm2rtlil 0 of 1608, downstream 0 of 805, probe 4 of
  4087 (the four conversions); identical path sets, the negative control flags every other file. **Every mover was
  predicted by name** (the 7 databases of the frozen prediction, no more, no fewer); no UVM-family coin moved.
* **Away census over the sweeps** (drivers/awayall.py, chain and flat keys,
  [evidence/sweep/away.txt](evidence/sweep/away.txt)): 7 databases differ; chain_lost 0, chain_toward 5147
  (Rggen d 5117, Earlgrey d/t 6 each, the probe movers 4-6), flat_lost 0.
* **Determinism** (drivers/det.sh, three concurrent harness runs per binary on Earlgrey_0_1 and the five UVM rows,
  [evidence/det/det.txt](evidence/det/det.txt)): one hash per row-mode on both binaries (Scoreboard testflags writes
  no database on either); the law's Earlgrey hashes equal its sweep's (535cffbc1d16 / 8ff4d1cc41ba), every UVM hash
  equals pristine's.

## Ground-A and other faces, decoded with call sites (not written)

1. Earlgrey_0_1 #122230 (t #123704): package parameter `WordSelW = WidthMultiple == 1 ? 1 : LsbAddrBit` folds to a
   constant located at the taken branch in golden (43:53-63), ours at the whole ternary (43:28-63): the folded
   package-parameter value's span, ParamEmit.
2. Earlgrey_0_1 #130430 (t #131904): golden `range` at hmac_pkg.sv 26:35 where ours walks a `ref_typespec` (structural,
   ground A per pass 236).
3. Rggen default after the law: #23546 the elaborated `SUB_N_LIST = get_sub_n_list(N)` (rggen_or_reducer.sv 62) — the
   argument constant's typespec is N's own int_typespec (3:13) in golden, the formal's (8:55) in ours: ParamEmit's
   evaluated-call argument stamping (§ evalFuncExecCallArgTs191 family), 3 objects; #26477-#26490 and 40 more fullname
   records: golden's port-view variables `register_if.access` / `.address` of `u_register_common` carry the full
   name of the child connection that first reached them (`...g_decoder[0].u_decoder.i_access.access`), ours the port
   view's own (ModuleEmit port view, a name minted by Surelog's hier-path binding of the child connection; not
   decoded further); 26 constant endcol records at the generate localparam `START_ADDRESS = OFFSET_ADDRESS +
   ADDRESS_WIDTH'(BUS_BYTE_WIDTH * g)` (golden ends at 33:37, ours 33:39); 128 ref_obj col records of
   `rggen_tie_off_unused_signals(...)` macro arguments in block_0.sv (golden 7:24-7:33 for `RIF.read_data`, ours
   7:11-7:23: the preprocessor model, item (7)). Every one of these is present in the pristine database.
4. FuncStructVal d/t depth(1) #7975 / #14765 (N0891): golden lists, under typespec_member `NonIdempotentAddrBase` (and
   `NonIdempotentLength`), its two evaluated values, the cast operations `1024'({64'b0, 64'b0})` (dut.sv 108:30); ours
   lists the member with no value. The field is the member's value (typespec_member Default_value), written only in
   ParamEmit (22 writers; stampEvalFuncLeftovers), never in TypeEmit buildStructTs (it builds the member, not its
   value): ground A, not written.
5. The UVM first records (BuildUVMPkg #77588, Scoreboard #79148: StmtEmit MakeForeach_stmt; SimpleUVM #75572 at the
   § implicitNetMintNoFile131 mint; MiniAmiq/SeqDriver #64612/#64568, the importer-clone loop-variable binding) and
   BlackBePipeInt #24671 (N2471, ParamEmit makeParamTs / drainDefParamTs) are the live sister pass's; no law of this
   pass fires on any of those rows (census), so their bytes are unchanged.
6. GL c07: a gen-scope `localparam int L = N;` elaborated param_assign constant typed by an int_typespec with no file
   in golden, ours at the declaration (ParamEmit elaborated localparam typespec): exposed after § genLpSysCallArgName239
   fixes the record before it.

## Residues, ranked

1. Rggen default: 202 objects (above), none on this ground except the port-view full names (44), whose rule is not
   decoded (a name of the child connection that reaches the variable first).
2. Pass 237's residues (2a)-(2g): not attempted (the member-fold radix rule, the select law's leaves, class-union
   faces, Verilog-mode keyword spans, the keyword-version text scan, FW/FM downstream, pass 235's ca/a02, ui/u07,
   ui/u10, ui/w01). v11u235 vk/k13 (`logic [3:0] r;` in Verilog mode) is stage 1 at the base (uhdm-cmp 58 lines): a
   structural face, not a span.
3. BuildUVMPkg's module/type clusters (N0051, N0974, N0072, N0467, N0043, N0120, N0203, N0264, N0266, N0254): not
   attempted; no law of this pass fires there.
4. Pass 231's and pass 228's residues (items 4 and 5 of the brief): not attempted.
5. § modportArgVarFormalTs239 abstains where evalFunc would MINT a formal typespec (a formal with none) and on interface
   bodies (Surelog's writeElabInterface also reduces assignments; not measured with a modport port inside an
   interface); the order of a module's net-declaration assignments relative to its `assign` statements in Surelog's
   netlist is taken as source order (not measured with two calls split across the two kinds).
6. Known Surelog behaviour (carried): `--elabuhdm` on a `$unit` class specialization used by a module variable
   segfaults in UHDM's elaborator (propagateParamAssign through a class this_type); Surelog -elabuhdm segfaults the
   same way. Surelog also segfaults when a modport port is named like its interface (`bus_if.slave bus_if`, kept out
   of the cases).

## Process

Resume: the first run died at about 22:00 with the worktree edited, the scratch populated and no deliverable. This run
saved the draft's src diff, restored the four base files, built and froze pristine (md5 equal to the main tree's),
re-applied the draft (dropping two unused `#include "R239.h"` lines in TaskFuncEmit.cpp and TypeEmit.cpp), built and
froze the law binary (md5 equal to the draft's law binary), then re-ran the grid, the case downstream lanes, the
firing census, the prediction, both gate sweeps, byteverify, the canaries, both away censuses and the determinism
check. byteverify.sh opens every database under its roots, so it ran on symlink trees built from a $FENCED-filtered
path list (`find ... | grep -vwE`), never on the raw sweep dirs.

Every driver reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh (env.sh); the firing census ran
through the harness with the fence filter; nothing fenced was read, opened or run. One waiting loop of mine used
`pgrep -f` on my own workdir name and was stopped by me (it matched only my own shell). The downstream lanes of the
cases ran one at a time after the pristine sweep's downstream stage had finished. Drivers (copied from pass 237,
renamed): env.sh, case.sh, grid.sh, gridcmp.py, awaycase.py, awayall.py, fire.py, corpus.sh, predict.py, det.sh,
rowhead.sh, dscase.py.
