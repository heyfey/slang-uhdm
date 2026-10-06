# r11u263: pass 263, the module/type ground (Rggen #92960, Earlgrey_0_1 #620047 and #658559)

Base 1f47482c (pass 261). Pristine binary md5 b0c95d2f65aad0c43fb701cb46377cbd (identical to the main tree's build),
law binary md5 d8ef7bf328195229d48798f1f00aa11b, both linking slang 12.0.0+545f88b2e, both frozen under scratch
before any measurement. Four laws in `src/ModuleEmit.cpp` behind `src/R263.h`. Each law reads its own
`R11U263_<LAW>_OFF` switch. `R11U263_OFF` drops all four and gives pristine bytes on every case-view of the grid
(92 of 92). `R11U263_TRACE=<dir>` logs every firing.

## Verdict per targeted row

| row-mode | base (pristine sweep) | law sweep (fresh csv row) | first record |
|---|---|---|---|
| **Rggen default** | `Rggen,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | **`Rggen,default,CMP_EQUAL,,,equal`** | **CONVERTED.** #92960 cleared (§ genLpArrRangeFirst263), then #210025 (§ genIfacePortActualInst263); uhdm-strictcmp reads `STRICT_EQUAL 314498 objects` and uhdm-cmp 0 lines |
| Earlgrey_0_1 default | `differ:fullname(36)` | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(21),,differ:fullname(21)` | first record #233633 unchanged (sister ground); #620047 to #620111 and the #658559 cont_assign order cleared |
| Earlgrey_0_1 testflags | `differ:fullname(4)` | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(4),,differ:fullname(4)` | unchanged count; the bytes move, 3 records toward golden and 0 away. The walk diverges at #403326 before the moved records. All four records are on the sister ground |

**Rggen default.** Before (evidence/rggen_default_pristine_records.txt):

    #92960 type   A: range          block_0.sv 1811:46-47     (localparam bit [1:0] INITIAL_VALUE[4] in g_bit_field_2.g[j])
                  B: ref_typespec   <in>

The record behind it, which a binary with § genLpArrRangeFirst263 alone reads
(evidence/rggen_default_genlprange_only_records.txt):

    #210025 depth A: 8 interface_inst register_15_bus_if work@rggen.u_block_0.register_15_bus_if rggen.sv 149:0
                  B: 7 ref_obj        work@rggen.u_block_0.g_register_15.u_register.bus_if  block_0.sv 2299:8-14
    objects 314498 vs 314469 (golden's 29-object port-view subtree under the high-conn ref_obj)

After both laws, uhdm-strictcmp reads `STRICT_EQUAL 314498 objects` (evidence/rggen_default_law_records.txt). The
away census reads chain away=0 toward=109.

**Earlgrey_0_1 default.** Before (evidence/earlgrey_default_pristine_records.txt), the records on this ground are:

    #620047 .. #620111 fullname (9)  A: ref_obj N work@tlul_socket_1n.N   B: work@top_earlgrey.u_spi_device.u_reg.u_socket.N
    #658559 line ... #658579 depth   A: cont_assign tlul_err_resp.sv 40:10   B: 38:10   (the walk diverges)

After (evidence/earlgrey_default_law_records.txt), both are cleared:

    #233633 #233638 #395727 #464077 #600811 #600816   (unchanged, sister ground)
    #726217 #726221 #726225 #727777 #727781 #727785 #729363 #730573 #730577 #814099 #814102 #814108 #814111 #816151
                                                      (reached now, wrong on pristine too: the away census reads 0)

The away census: chain away=0 toward=14; flat dist 868 -> 175, lost 0.

Each law's share, with the law binary and one switch off (evidence/earlgrey_switches.txt):
- `R11U263_DOTOPRHS_OFF` reads fullname(27): the nine #620047 records cleared, the walk still diverging at #658559.
- `R11U263_DOTSELBASE_OFF` reads fullname(16): the nine records stand and the walk diverges earlier, at #670253.
- Both laws read fullname(21) because the walk now runs to #816151.
- Testflags reads (4) under every configuration.


## The laws

### § genLpArrRangeFirst263 (`R11U263_GENLPRANGE_OFF`)

ModuleEmit, the generate-scope parameter listing's unpacked-array branch (§ genLpUnpackedArray).

- The face: Rggen default #92960 (block_0.sv 1811,
  `localparam bit [1:0] INITIAL_VALUE[4] = '{2'h0, 2'h1, 2'h2, 2'h3};` inside `g_bit_field_2.g[j]`). Golden lists a
  `range` (1811:46-47) under the param_assign Rhs's array_typespec; ours listed the element `ref_typespec` there.
- The cause: ours built the array_typespec with the parameter's own `vpiRange` vector shared into it
  (`makeUnpackedArrayParamTs(ps, afull9, up, prng9)`). The strict walk re-expands a typespec at every reference but
  never re-lists an object it has already visited outside a typespec. The parameter's own range is visited under the
  parameter, so the walk listed no range under the typespec at the param_assign's reference. In the elaborated view
  (`--elabuhdm`) UHDM's clone gave the typespec its own ranges but kept the shared bound expressions, so the bounds
  were missing the same way.
- The law: the gen-scope array_typespec gets its own ranges, built exactly as the parameter's are (same dim-fold
  owner), with `sharedRanges = nullptr`. This is the generate-scope twin of § impArrParamTsOwnRanges242.
- Golden writes nothing new: the range objects already exist in golden; the law only stops sharing ours.

### § genIfacePortActualInst263 (`R11U263_GENIFPORT_OFF`)

ModuleEmit, the elaborated child port's interface high-conn (`ifaceInstMap` branch, the PASSTHROUGH lookup).

- The face: Rggen default #210025, exposed once #92960 clears. Inside `g_register_15` of block_0,
  `rggen_external_register u_register (.bus_if(register_15_bus_if))` passes block_0's own interface port down.
  Golden's high-conn ref_obj binds the enclosing instance's port view, `work@rggen.u_block_0.register_15_bus_if`
  (rggen.sv 149:0, an interface_inst nobody else lists, so the walk expands its 29 objects there). Ours bound the
  outer interface instance `work@rggen.register_15_bus_if`, already visited.
- The cause: the module-body passthrough rule (bind the enclosing module's port view and name the port) looked the
  actual up with `inst.getParentScope()->find(...)`. For a child inside a generate block that scope is the generate
  block, so the port was never found.
- The law: when that lookup finds nothing, climb the generate blocks (GenerateBlock / GenerateBlockArray) to the
  instance body and take the name there when it is an interface port with a port view. The ref_obj then binds that
  port view and is named by the port, as the module-body passthrough already does.
- With differently named actuals (top `bif b()`, port `b15`) the same face is a uhdm-cmp difference: ours named the
  ref_obj `b`, golden `b15` (I/i01). The law converts it.

### § dottedLhsElemSelShares263 (`R11U263_DOTSELBASE_OFF`)

ModuleEmit, the elaborated cont_assign's sharing decision (the `dottedLhs` test).

- The face: Earlgrey default #620047 to #620111, nine records in `tlul_socket_1n` (`assign tl_u_o[N].a_valid =
  ...` and its eight siblings, tl_u_o an unpacked array of `tlul_pkg::tl_h2d_t`). Golden's elaborated listing keeps
  the definition's own cont_assign, so the index reads `work@tlul_socket_1n.N`. Ours wrote a fresh copy per instance
  and named the index by the instance (`work@top_earlgrey.u_spi_device.u_reg.u_socket.N`).
- The cause: the base walk under the dotted-Lhs rule stepped only through member accesses. A member path rooted at a
  select (`tl_u_o[N].a_valid`, the hier_path's first element a bit_select) never reached a NamedValue, so the rule
  read it as a variable-backed dotted Lhs and minted the fresh copy.
- Golden's rule (Surelog `UhdmWriter::writeCont_assign`): a cont_assign whose Lhs is not a ref_obj is cloned only
  when its Rhs reduces to a constant (the `reduceExpr` branch), or in the typespec-driven pattern branch.
- The law: the walk also steps through element and range selects. When it did, the decision is the constant test
  alone: a non-constant Rhs (slang `tryEval` fails) keeps the shared def cont_assign, whatever backs the array (net
  or variable). A constant Rhs (an enum constant, a parameter, a cast of one) is left as before, a fresh copy
  (T/t10, t18). The net-base test is skipped for a select-rooted path, so the law's firing is its only change.

### § dottedLhsVarOpRhsShares263 (`R11U263_DOTOPRHS_OFF`)

Same site, the member path rooted at a variable.

- The face: Earlgrey default #658559 onward, the cont_assign order of a second `tlul_err_resp` instance. Golden walks
  only that instance's literal-Rhs copies (tlul_err_resp.sv 40, 42, 43, 46, 47), its operation-Rhs cont_assigns
  being the shared def objects already walked. Ours re-listed fresh copies of 38, 39 and 45
  (`assign tl_h_o.a_ready = ~err_rsp_pending & ...` on an output struct port).
- The law: a dotted Lhs on a variable base (no select) with a non-constant Rhs keeps the shared def cont_assign.
  Constant Rhs shapes keep the base's fresh copy.
- The base's comment ("literals, operations and constant references all re-emit fresh") was measured on constant
  operands. A non-constant operation is shared in golden: T/t13 `s.a_valid = a & b`, t20 (conditional), t22 (cast
  of a concatenation), t24 (function call).

## Grid (cases/, every case's first line names its law)

46 case dirs in both views (92 case-views). drivers/grid.sh runs 7 configurations: pristine, law, law +
`R11U263_OFF`, and the law with each of the four switches off. That is 644 lines, every one `rc=0`
(evidence/grid.txt, evidence/gridsum.txt).

- `R11U263_OFF` gives pristine's bytes on 92 of 92. Every mover is moved by exactly its own law's switch.
- 70 case-views move. 27 enter STRICT_EQUAL and none leave. 12 uhdm-cmp line counts change, all on cases that go
  stage 1 -> equal or shrink.

| dir | law | shapes | result |
|---|---|---|---|
| R/r01 to r10 | § genLpArrRangeFirst263 | `bit [1:0] X[4]` in a for-generate inside an if-generate (the Rggen shape, r01); `logic [7:0] T[0:3]` in an if-generate (r02); `int` / typedef / 2-D / struct / parameter-sized elements (r03, r04, r06, r07, r08); a for-generate nested two deep (r09); unused in an if-generate (r10); the module-level twin control (r05) | r01, r02, r09 enter STRICT_EQUAL in both views. r05 is unchanged. r03, r04, r06, r07, r08, r10 move but stay stage 1 on both binaries: the definition-view face, residue 2 |
| I/i01 to i15 | § genIfacePortActualInst263 | modport port, different names (i01) and the same name (i03, the Rggen shape); the non-generate control (i02); positional connection in nested generates (i04); case-generate (i05); plain port (i06); generic port (i07); program child (i08); modport-qualified actual (i09); a generate-local instance shadowing the port (i10); two levels of generate passthrough (i11); two ports, one used outside the generate (i12); spaces in the actual (i13); interface child (i14); a bind beside it (i15) | i01, i06, i08, i11, i13 go stage 1 -> STRICT_EQUAL (i06's elaborated view -> fullname). i03, i05, i12 move and stay equal. i02, i09, i10 are unchanged. i04, i07, i15 move toward golden and stay stage 1. i14 is unchanged (residue 4) |
| T/t04c to t24 | § dottedLhsElemSelShares263, § dottedLhsVarOpRhsShares263 | select-rooted member Lhs over an anonymous-struct net array (t04c), a package-struct variable array (t05, the Earlgrey shape), constant index (t07), nested member (t08), generate loop (t09), expression index (t14), two-dimensional root (t12), packed root (t06), `wire` array (t16, t17); constant Rhs controls: literal / enum (t10), parameter (t11), cast of a parameter (t18), plain signal (t15), enum on a variable (t19); variable-rooted operation (t13), conditional (t20), pattern (t21), cast of a concatenation (t22), select-rooted pattern (t23), function call (t24) | t04c, t05, t07, t08, t09, t13, t14, t20, t22, t23, t24 enter STRICT_EQUAL. t07's elaborated view also enters. t10, t11, t15, t17, t19, t21 are unchanged. t12 and t18 move toward golden (fewer objects) |

The away census over the 70 movers (drivers/awayall.sh, evidence/grid_away.txt) reads 0 lost on 66. The other 4
are dump-text counts on elaborated-view cases whose pristine side fails stage 1:

- i08_el, i11_el and i13_el: the law reads STRICT_EQUAL, so every strict record equals golden's. The lost lines
  are uhdm-dump print artifacts. The port-view interface_inst is now reached through the ref_obj, so the dump no
  longer prints its `param_assign` / `modport` lines in the top-level unreferenced section where pristine and golden
  print them.
- i07_el (generic port): stage 1 on both binaries; 2 lines of the same kind.

Downstream on the cases (drivers/dscases.py, evidence/ds_cases.txt, 36 dirs measured before t17 to t24, i14 and
i15 existed): no case leaves IDENTICAL. i01, i04, i06, i11 and i13 go EQUIVALENT -> IDENTICAL; i10, i12, r07, r08
and t06 stay EQUIVALENT on both binaries.


## Byte controls

19 earlier repro dirs, 1287 cases, 2574 case-views on pristine and law (evidence/controls.txt,
controls_summary.txt). The dirs are pass 118's and 119's (r11u118, r11v11u118, r11u119), pass 120's, 124's and 131's
with their verifiers (r11u120, r11v120, r11u124, r11v124, r11u131, r11v131), and the recent module/type ground
(r11u261, v11u261, r11u259, v11u259, r11u257, v11u257, r11u256, v11u256, r11u242, r11u221verify).

- 2 moving, 0 entering STRICT_EQUAL, 0 leaving. No exit code and no uhdm-cmp line count changes.
- The two movers are v11u261 VD/vd04_iface_port_child in both views: `mid (bus b)` passes its port into
  `if (1) begin : g leaf l (.b(b)); end`. They are STRICT_EQUAL on both binaries; the same name in both scopes
  hides the binding from the walk, as in I/i03. `R11U263_GENIFPORT_OFF` alone restores pristine's bytes, and the
  record away census reads 0 lost (evidence/controls_attribution.txt).
- A first control run against the withdrawn law binary (see Process) was discarded.


## Firing census (predictor), frozen before the law sweep

evidence/predict_frozen.txt (md5 207a6af2ac541e288ebbc3a7e50fe6aa) comes from drivers/tracecensus.sh: the law
binary under `R11U263_TRACE` over the 4087 probe cases and both corpora in both modes, with the filter built from
`$FENCED`. It names 12 databases:

| database | laws fired |
|---|---|
| probe r10earl_repro/tj | dottedLhsVarOpRhsShares263:1 |
| surelog Earlgrey_0_1 d / t | dottedLhsElemSelShares263:91, dottedLhsVarOpRhsShares263:130 |
| surelog Rggen d | genIfacePortActualInst263:1, genLpArrRangeFirst263:16 |
| surelog Scr1SvTests d / t | dottedLhsVarOpRhsShares263:3 |
| uhdm2rtlil PackedArray, TypedefPackedDimensions, TypedefVariableDimensions d / t | dottedLhsElemSelShares263:4 |

The law sweep's movers are exactly the predicted ones:

- **Corpus.** byteverify over fence-filtered hard-link mirrors reads MOVERS 11 / 2560, PATH_SETS_IDENTICAL,
  SELFCHECK 2559 / 2560 (evidence/byteverify_corpus.txt; 8 fenced paths skipped unread).
  - The 11 are the predicted corpus databases.
  - Scr1SvTests d/t is a known failure, `differ:type(1)` on both binaries. Its strict record multisets are
    unchanged (chain away 0, toward 0); its dump loses 57 lines, dump distance to golden 874 -> 817 with 0 lost.
  - The six uhdm2rtlil movers stay strict-equal. Their dumps lose 58 to 66 lines (the fresh copies golden does not
    hold), dump distance 62-71 -> 4-5 with 0 lost (evidence/byteverify_dumpdiff.txt).
- **Probe.** 1 / 4087 moves (r10earl_repro/tj, predicted), EQUAL on both binaries (evidence/probe_byte_movers.txt).
- **Downstream.** No verdict moves. The three uhdm2rtlil movers read IDENTICAL on both binaries when run alone
  (PackedArray, TypedefPackedDimensions, TypedefVariableDimensions).


## Gates (law binary, from the worktree, `SLANG_UHDM` exported)

1. **Builds.** pristine b0c95d2f65aad0c43fb701cb46377cbd (equal to main), law d8ef7bf328195229d48798f1f00aa11b.
   Binary-path audit: 3265 of 3315 fence-filtered cmds.txt per sweep name that sweep's frozen binary. The other 50
   carry no slang line, and none names another binary (evidence/binaudit.txt).
2. **probe.** `EQUAL=3566 STRICT_NOTEQUAL=521`, `regressions=0 conversions=0 changes=0` on both sweeps.
3. **surelog.** Law: `regressions=0 conversions=1 changes=1`.
   - **CONVERSION Rggen default `differ:type(1) -> CMP_EQUAL`**, fresh row `Rggen,default,CMP_EQUAL,,,equal`.
   - CHANGE Earlgrey_0_1 default `differ:fullname(36) -> differ:fullname(21) [fullname -15]`. The first record
     #233633 is unchanged; the away census reads 0 lost.
   - Pristine reproduces the baseline exactly: 0/0/0 in all three stages (evidence/sweeps/*_P_vs_baseline.txt).
   - uhdm2rtlil: `regressions=0 conversions=0 changes=0`, 1606 of 1606 strict-equal.
   - Against pristine, the law csvs differ only in the Earlgrey_0_1 default and Rggen default rows and the LowMem
     workdir path (evidence/sweeps/*_P_vs_L_rows.txt).
4. **downstream.** `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)` on both binaries. The verdict diff is 0
   against pristine and against results/downstream_uhdm2rtlil.csv. No downstream row is targeted.
5. **uhdm-cmp.** 0 lines on Rggen default and on Earlgrey_0_1 default and testflags (rc 0), and on the probe mover.
6. **byteverify.** See the census above. The chain-keyed away census on all 11 corpus movers reads away=0
   (evidence/away_corpus_chain.txt: Earlgrey d toward 14, t toward 3, Rggen d toward 109, the rest 0 / 0). The
   flat census also reads 0 lost on all 11 (evidence/away_corpus_flat.txt).
7. **Canaries.** surelog ok=51 changed=1 (Earlgrey d, targeted; Rggen is not a canary row); uhdm2rtlil ok=16
   changed=0; ctcan2 surelog (EXPECT_UNKNOWN=1) PASS; ctcan2 uhdm2rtlil (EXPECT_UNKNOWN=6) PASS
   (evidence/canaries.txt).
8. **Determinism.** drivers/det.sh ran three concurrent harness draws of the law binary on Earlgrey_0_1, MiniAmiq,
   SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes (evidence/det_law.txt).
   - Every row-mode reads one hash in 3 of 3, equal to the law sweep's.
   - Scoreboard testflags has no database, as at the base; Rggen testflags is SURELOG_FAIL.
   - The UVM rows' hashes equal pristine's: no law fires there.
9. **`R11U263_OFF`.** With the law binary it gives pristine's bytes on the three targeted corpus databases (Rggen d,
   Earlgrey d/t, evidence/off_corpus_rows.txt) and on all 92 grid case-views.
10. **Law index.** `scripts/law_index.py` regenerated; `--check` reads current.


## Residues, ranked

All of these are wrong on pristine too.

1. **Earlgrey_0_1 default, the records the walk reaches once #658559 clears.** The law sweep's record list is in
   evidence/earlgrey_default_law_records.txt; the chain-keyed away census reads 0 lost.
   - #726217, #727777, #730573 `file` (this ground or ParamEmit; writer not located). An overridden parameter's
     elaborated param_assign keeps the child's default constant (flash_erase_ctrl.sv 9:25-27,
     `parameter int AddrW = 10`). Golden binds its ref_typespec to the child's own `int` (9:13-16); ours binds the
     package parameter's `int` (flash_ctrl_pkg.sv 18:14-17, `localparam int AddrW = BankW + PageW + WordW`). A
     two-package reduction with `$clog2` localparams did not reproduce it.
   - #729363 `fullname`: a ref_typespec golden names `work@top_earlgrey.u_flash_ctrl`, ours unnamed (not decoded).
   - #816151 / #816152 (this ground, not decoded): sha2's port `output sha_word_t [7:0] digest`. Golden's elaborated
     net typespec is the typedef's own named `logic_typespec hmac_pkg::sha_word_t`, carrying a range read from the
     preceding port's `[63:0]` (sha2.sv 26:16-22). Ours is an anonymous logic_typespec at sha2.sv 27:10-26. A
     one-file reduction fails stage 1 on unrelated faces first (golden sizes `digest = '0` as 32 bits).
2. **The generate-localparam unpacked array in the definition view, non-logic elements** (§ genLpUnpackedArray's
   `unpkLp9` admits only `logic` / `reg` keyword types). A `bit` (R/r10), `int` (r03), typedef (r04, r07),
   two-dimensional (r06) or parameter-sized (r08) element gets an int_typespec where golden writes the array's
   shape. This is a uhdm-cmp difference on every case, so no corpus row has it.
3. **§ dottedLhsElemSelShares263 shapes still differing.**
   - T/t11: a parameter Rhs on a select-rooted path. Golden re-compiles it and names the index
     `work@top.u_a.tl_u_o[N].a_valid.N`; ours names it `work@top.u_a.N`.
   - T/t12: a two-dimensional select root, endcol(5).
   - T/t06: a packed-array root, and t16 / t17: a `wire` struct array. These are uhdm-cmp differences on both
     binaries.
4. **§ genIfacePortActualInst263 shapes.**
   - I/i14: an interface child inside the generate block (`wrap_if w(.p(b15))`) takes another path; the law does
     not fire, and the case is a uhdm-cmp difference on both binaries.
   - I/i07: a generic interface port; the law moves it toward golden, but stage 1 still differs.
   - I/i09: a modport-qualified actual `b15.master`; the lookup reads the whole text, so the law does not fire.
   - I/i04 and i06_el: closer to golden, still differing.
5. **The brief's other items, not attempted:**
   - D/d08 and G/g06 (an interface in a generate block sharing its definition's cont_assign objects; the
     interface-child part-select actual).
   - Pass 261's residue list (vc01, vc04, vc07, vc15, C/c02, Q/q05, q08, va08, A/a06, va16, vg06, vg08, vd09,
     va01_el, A/a10) and the seven first-match pointer-keyed loops.
   - Pass 259's residues (M/m02, vm12, L l01 and l03 to l05, vm06, vm13, vm14, vm01, v208_f_io).
   - Items (4) to (7).


## Sister-ground faces (decoded, call sites; not written)

| record | face | call site |
|---|---|---|
| Earlgrey d #233633 / #233638 | the folded parameter's ref_typespec named after the select (`work@rstmgr_ctrl.rst_req_i`) where golden names the module | ExprEmit § shadowedImportParamFold, its call to pkgBoundValueConst9 |
| Earlgrey d #395727 | a gen-scope cont_assign's comparison operand `WB_INSTR_OTHER` (header-imported package enum) binds a fresh enum_const without a location; golden binds the located package constant (ibex_pkg.sv 179:3-17) | ExprEmit's NamedValue enum binding under `inGenScopeCaRhs`, the enumConstMap clone mints of § genCaEnumBindsSelectOnly22. Reproduced in one file: decode/E/e01, `STRICT_NOTEQUAL file` at #274 in the default view, equal in the elaborated view |
| Earlgrey d #464077 | an overridden header parameter as an indexed-part-select width in an if-generate; golden names the owning instance (`u_ram1p_ram_main`), ours the instantiating scope | ExprEmit emitExpr / stampFoldedPkgParamTs (pass 256's G/g23) |
| Earlgrey d #600811 / #600816 | a fill constant's ref_typespec; golden leaves it unnamed, ours names the gen scope (`...i_prim_ram_2p_async_adv.gen_secded`) | ExprEmit, the whole-right-side replication fold in a generate scope (pass 256) |
| Earlgrey d #814099 / #814102 (reached after the laws) | an indexed part select's width constant in `u_packer.gen_stored_in`; golden names its ref_typespec `work@top_earlgrey.u_hmac.u_packer`, ours `work@top_earlgrey.u_hmac` | ExprEmit § genIpsBoundOwner256's family |
| Earlgrey t #216212, #235310 / #235315, #403326 | the `::` form on a compound assignment; § shadowedImportParamFold; the elaborated cast-target struct shared where golden holds a per-use copy | ExprEmit (pass 261's decode/E/e01) |
| MiniAmiq / SeqDriver #121302 / #121260 / #121272 | the struct-index foreach in a copy | StmtEmit § cloneLoopVarHomeObject183 |
| BlackBePipeInt #331795 / #331692 | the import-copy Rhs | ParamEmit |


## Process

- **The withdrawn law binary.** The first law binary (md5 3ded9abc6ad46a605f90595949912053) ran the net-base test
  before § dottedLhsElemSelShares263's constant test. So a select-rooted path over a net array with a constant Rhs
  became shared without the law's trace firing: an untraced branch, and wrong against golden (T/t18's elaborated
  view went STRICT_EQUAL -> fullname).
  - Found while reviewing the trace coverage before the law sweep had finished its surelog stage.
  - The law sweep (this pass's processes only, each pid's command line checked for the pass's workdir), its census
    and its control run were stopped and their outputs deleted unread.
  - The fix: a select-rooted path skips the net-base test, so the constant test alone decides and the trace covers
    every changed decision.
  - The binary was refrozen (d8ef7bf3...) and the census, grid, controls and law sweep rerun from scratch. The
    frozen prediction is identical, line for line, to the withdrawn binary's.
- **A slip.** While stopping that control run, one `pgrep -f` pattern matched this agent's own shell and ended it
  (exit 144). Only this pass's control processes were signalled; nothing else was affected.
- Earlier draft laws: § dottedLhsElemSelShares263 first only walked the selects into the existing net-base test.
  It moved t04c but not Earlgrey, whose tl_u_o is an array_var. It was reworked before any binary was frozen. A
  draft without the constant test moved T/t10 away from golden (its enum-constant cont_assign is a fresh copy in
  golden); the constant test was added before freezing.
- The fence: every corpus run went through the harness with the filter built from `$FENCED` (census) or the gate
  sweeps themselves; every case path list is filtered by `$FENCED` before use. No fenced source or database was
  read, dispatched or decoded.
- The decode case for Earlgrey #395727 sits under decode/E/e01 and names the sister law in its first line. Two
  reductions that did not reproduce their records (#726217, #816151) were deleted and are not delivered.
- No process of another agent was listed or signalled; `free -g` stayed above 6 GB available, builds ran at `-j 2`.


## Files

- `src/R263.h`: the switches and the trace.
- `src/ModuleEmit.cpp`: the four laws, each under its `§` name.
- `tools/probe/r11u263repro/cases/{R,I,T}`: 46 case dirs; every dut.sv names its law in its first line.
- `tools/probe/r11u263repro/decode/E/e01`: Earlgrey #395727, sister ground.
- `tools/probe/r11u263repro/drivers/`: copied from r11u261repro, retargeted to R11U263. det.sh adds Rggen to its
  row list.
- `tools/probe/r11u263repro/evidence/`: grid, controls, census, byteverify, away censuses, sweeps, record dumps,
  canaries, det.
- `tests/LAWS.md`: regenerated.
