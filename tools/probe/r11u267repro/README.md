# r11u267: pass 267, the module/type ground (Earlgrey_0_1's module-ground records)

Base 7d6db9ca. Four laws in `src/ModuleEmit.cpp` behind `src/R267.h`. Each law has its own `R11U267_<LAW>_OFF`
switch, `R11U267_OFF` drops all four, and `R11U267_TRACE=<dir>` logs every firing. No corpus row converts. Four
probe cases convert, every one predicted by name before the law sweep. Earlgrey_0_1 loses every record of the brief's
item (1) that sits on this ground. The rest of those records are decoded to the sister ground (ParamEmit) or to a
shape that could not be reproduced.

| row-mode | base strict | law sweep row | what moved |
|---|---|---|---|
| Earlgrey_0_1 default | `differ:file(19)` | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:file(210),,differ:file(210)` | #600811 / #600816 / #729363 / #816151 / #816152 cleared. Pristine's walk diverged at #816152 (ours held 5 more objects), and the law's walk no longer diverges: it runs to the end of the design (objects 2173209 on both sides). It now lists 210 records. The first record #395727 is unchanged and on the sister ground. The away census reads 0 lost, both flat and chain-keyed |
| Earlgrey_0_1 testflags | `differ:fullname(20)` | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(18),,differ:fullname(18)` | #530951 / #530956 cleared; first record #446024 unchanged (sister ground) |

Probe conversions (each STRICT_NOTEQUAL -> EQUAL in the law sweep; results/ untouched):

    CONVERSION r10earl107repro/g1_home107 STRICT_NOTEQUAL differ:line(4) -> EQUAL       (§ pkgQualPatConnSpan267)
    CONVERSION r10earl78repro/a3_wide78 STRICT_NOTEQUAL differ:fullname(8) -> EQUAL     (§ genCaReplParentBoundLhs267)
    CONVERSION r10v78repro/v6_ndecl78 STRICT_NOTEQUAL differ:fullname(2) -> EQUAL       (§ genCaReplParentBoundLhs267)
    CONVERSION r10v78repro/v7_pre78 STRICT_NOTEQUAL differ:fullname(2) -> EQUAL         (§ genCaReplParentBoundLhs267)

## The laws

All four sites are in `src/ModuleEmit.cpp` and are found by their § token.

1. **§ caFoldParentUnboundLhs267**, switch `R11U267_CAFOLDPARENT_OFF`, at the module home of the elaborated
   cont_assign fold, `emitContAssigns`, after the general `tryFoldConst` fold.
   - Surelog's `UhdmWriter::writeCont_assign` (UhdmWriter.cpp:2090) folds an operation Rhs in one of two branches, and
     `CompileHelper::bindVariable` (CompileStmt.cpp:3089) decides which.
   - A `ref_obj` Lhs that binds by name takes the first branch: `reduceExpr`, `adjustSize`, then `assign->Rhs(rhstmp)`,
     with no parent set.
   - Any other Lhs takes the `simplified == false` branch, which ends in `res->VpiParent(assign)`. Such a Lhs is a
     member path (`hier_path`), a select, a concat, or a reference that binds nothing.
   - Ours left the module-home fold unparented for every Lhs. The parent becomes visible through the replication
     fold's `word size` int_typespec reference, whose full name is computed from the parent chain.
   - Golden Earlgrey flash_ctrl `assign region_cfgs[MpRegions].size.q = {AllPagesW{1'b1}}` names it
     `work@top_earlgrey.u_flash_ctrl` (#729363), and ours left it unnamed.
   - The law parents the folded constant at the cont_assign when the Lhs is not a plain name and the Rhs is not a
     bare name. A bare-name Rhs keeps the older single-parameterization rule.
2. **§ genCaReplParentBoundLhs267**, switch `R11U267_GENREPLPARENT_OFF`, at the gen-scope home,
   § genCaReplWholeFold78's mint.
   - This is the same fence as law 1. From a gen_scope, `bindVariable` walks out to the enclosing module, so a Lhs
     that names a module net, variable or port binds, and its fold stays unparented.
   - § genCaReplWholeFold78 parented it unconditionally. Golden Earlgrey gen_secded
     `assign a_wmask_d = {TotalWidth{1'b1}}` leaves the reference unnamed, and ours named the gen scope
     (#600811 / #600816 default, #530951 / #530956 testflags).
   - The law parents only when the Lhs does not bind by name, which is the helper `caLhsBindsByName267`. A gen-local,
     interface-body, member-path or select Lhs keeps the parent.
3. **§ typedefDimNetDropsDims267**, switch `R11U267_TDDIMNET_OFF`. It has three homes: the module instance's net
   emission in `emitInstance`, `emitInterfaceInstance`'s net, and the modport clone of an interface header port. All
   three use the helper `typedefDimNetTs267`.
   - In Surelog's `NetlistElaboration::elabSignal` (NetlistElaboration.cpp:2216-2237), net branch, the data type is a
     DummyType whose typespec is a logic_typespec. The logic_net's reference binds that typespec, which is the
     typedef's. The packed dimensions are compiled but never attached (`// logicn->Ranges(packedDimensions);` is
     commented out).
   - So `output sha_word_t [7:0] digest` elaborates with `logic_typespec hmac_pkg::sha_word_t`, range [31:0]
     (#816151 / #816152, the object-count divergence of the pristine walk).
   - The port and the definition view keep the full packed typespec.
   - The law binds the elaborated net's reference to the typedef's object, which our packed typespec's element
     reference already holds. It applies only to a written `<4-state integral typedef> [packed dims]` declaration.
4. **§ pkgQualPatConnSpan267**, switch `R11U267_QUALPATCONN_OFF`, at the port-connection substitution of a
   package-parameter struct pattern (`emitInstance`, the `pkgParamObj` pattern branch).
   - That branch re-anchored the substituted pattern operation at the reference span.
   - For a package-qualified reference (`pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT`), golden keeps the parameter
     initializer's span instead (pinmux_pkg.sv 26:58-28:4). Ours had the package's file with the use site's line,
     pinmux_pkg.sv 628:26-65.
   - A positional connection reads the qualifier alone (`pp::`), which is the span the qualified port-actual reference
     already uses.
   - A bare imported name keeps the reference span (Q/q02, unchanged).
   - These records appear only once laws 1 to 3 let the walk reach them: Earlgrey default's pinmux, pwrmgr, rstmgr
     and clkmgr port actuals, 10 records in the walk the other laws expose.

## Grid (evidence/grid.txt, gridsum.txt, grid_away.txt)

drivers/grid.sh runs 78 case dirs in both views on 7 configurations: pristine, law, `R11U267_OFF`, and each switch
off. That gives 156 case-views and 1092 lines, and every line reads rc=0.
- `R11U267_OFF` gives pristine's bytes on 156 of 156 case-views.
- 78 case-views move, 48 enter STRICT_EQUAL and none leave. Each mover is moved by exactly one switch: CAFOLDPARENT 16,
  GENREPLPARENT 12, QUALPATCONN 12, TDDIMNET 38.
- The uhdm-cmp line count changes on C/c03 in both views (32 -> 36). That case is stage 1 on both binaries, on an
  unrelated value-encoding face, and the 4 extra lines print the constant's new parent.
- Away census on all 78 movers:
  - Where both sides pass stage 1, the record census reads 0 lost.
  - Among the stage-1 case-views (T/t01, t04, t06, t07, t08, t12, C/c03_el), the dump-line census reads lost dump
    lines. Every one is the uhdm-dump repeat elision: the shared typedef object is now printed in full under the net
    instead of under the port, with the same lines at a different indentation. Every one of these case-views loses
    distance, for example t06 37 -> 5 and t07 34 -> 2.
- Downstream on the 78 case dirs (evidence/ds_cases.txt):
  - P/p14 and T/t03 go DIVERGENT -> IDENTICAL. These are the interface homes of law 3; the plugin reads the net's width.
  - No case leaves IDENTICAL. The law reads 64 IDENTICAL and 14 EQUIVALENT, against pristine's 62 / 14 / 2.

| cases | law | what they cover |
|---|---|---|
| R/r01, r02, r04, r10, r18, r22 | § caFoldParentUnboundLhs267 | replication Rhs on a member path: package or local count, literal count, qualified count, nested replication, a whole member. All enter STRICT_EQUAL in both views |
| R/r03, r06, r07, r16, r17 | § caFoldParentUnboundLhs267 | controls: a plain-name Lhs stays unparented (r03, r06, r07, r17 unchanged). r16 is a literal concat on a member path, which moves in bytes and stays STRICT_EQUAL |
| R/r05, r11 to r15, C/c01 to c05 | § caFoldParentUnboundLhs267 | stage 1 on both binaries on other faces: the fold on a select Lhs (golden folds, ours keeps the operation), value encodings, a variable-rooted member path, interface bodies, comma-list assigns |
| R/r08, r21, G/g04 to g07 | § genCaReplParentBoundLhs267 | gen-if and gen-for blocks onto a module port, a wire, a module variable, a macro-written replication and a CRLF file. All enter STRICT_EQUAL except g04's default view, which is stage 1 on both binaries |
| R/r09, r19, r20, G/g01 to g03, g08 | § genCaReplParentBoundLhs267 | controls that keep the parent: a member path, a part select, a gen-local net, an interface gen scope and an implicit net are unchanged. g08 is an X element, which golden folds in Surelog's own casing (stage 1 on both) |
| P/p01 to p05, p12, p14, T/t02, t03, t09, t13, t14 | § typedefDimNetDropsDims267 | input, output and positional ports; with and without a preceding ranged port; a scalar logic typedef; interface and modport ports; CRLF; a child in a generate block; a non-ANSI port. All enter STRICT_EQUAL |
| P/p04, p07, p09, p10, p11, p13, p15, T/t01, t04 to t08, t10 to t12 | § typedefDimNetDropsDims267 | stage 1 on both binaries on other faces: a program port, a `pkg::` qualified type, a $unit typedef, signed typedefs, a header included in two modules, a macro-written port, a body `wire`, unpacked dims, a parameter-sized dim, a bit typedef, a typedef of a typedef, a `var` port. The movers among them lose distance, with only the print-elision lines lost |
| P/p06 | § typedefDimNetDropsDims267 | control: the typedef without packed dims, unchanged |
| Q/q01, q03, q05 to q09 | § pkgQualPatConnSpan267 | named and positional qualified actuals, spacing, interface, generate, nested pattern, parenthesised actual. q01 and q03 enter STRICT_EQUAL. q05 moves toward golden (its remaining record is a def-view ref_obj endcol, pass 131's qualifier face). q06 to q09 are stage 1 on both |
| Q/q02, q04 | § pkgQualPatConnSpan267 | controls: a bare imported name is unchanged; q04 is a positional bare actual, stage 1 on both |
| O/o01 to o05, o07 | § shadowedImportParamFold | the decode of #726217 (sister ground, below), unchanged by this pass |

## Gates (measured at base 7d6db9ca)

1. **Build.**
   - Pristine `5a63fea69f27c2454a177981f83d37c9`, the main tree's md5.
   - Law `028869c3ae32f7c2f9ca51fbfdf7f580`, rebuilt from the patch to the same md5.
   - Three earlier law binaries were withdrawn before any gate sweep: law 4 was added after the first freeze, its
     syntax climb was fixed after the second, and the modport home was added after the third. Each time, the census
     and the grid were stopped by their own process ids (only this pass's processes, each command line checked),
     their outputs were deleted unread, and both were rerun from scratch on the final binary.
2. **Probe.** EQUAL 3570 + STRICT_NOTEQUAL 517, regressions=0, with the 4 conversions above.
3. **Corpora.**
   - surelog: 942 + 12 judge-equal, regressions=0, conversions=0, changes=2 (the two Earlgrey rows, both predicted).
   - uhdm2rtlil: 1606 + 0, no change.
   - Pristine's own sweep reads the baselines exactly: probe 3566 / 521, surelog 0 changes, u2r 0 changes.
4. **Downstream.** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on both binaries, with a csv
   identical to pristine's. 0 of 805 slang-lane databases move (evidence/downstream_bytes.txt).
5. **uhdm-cmp.** 0 lines and rc 0 on Earlgrey_0_1 default and testflags (evidence/uhdmcmp_rows.txt).
6. **byteverify.** It ran on fence-filtered hard-link mirrors (drivers/bvmirror.sh; 8 fenced databases skipped
   unread), with SELFCHECK 2559 / 2560.
   - Corpus: 2 of 2560 move, Earlgrey_0_1 d/t.
   - Probe: 4 of 4087 move, the four conversions.
   - Every mover was named in the firing census frozen before the law sweep (evidence/predict_frozen.txt: exactly
     these six databases, 0 uhdm2rtlil firings). The census is its own positive control, since the trace fires
     through both harnesses.
7. **Canaries.**
   - surelog ok=50 changed=2 (the Earlgrey rows).
   - uhdm2rtlil ok=16.
   - Both ctcan2 checks PASS (evidence/canaries.txt).
8. **Binary-path audit.** On both sweeps, 3265 of 3315 fence-filtered cmds.txt name that sweep's own binary. The
   other 50 carry no slang line.
9. **Away census on the corpus movers.**
   - Record census, evidence/away_corpus_flat.txt: Earlgrey default dist 171 -> 154, lost 0. Testflags 586 -> 569,
     lost 0.
   - Chain-keyed census, evidence/away_corpus_chain.txt: 0 away and 17 toward on both.
10. **Determinism.** drivers/det.sh ran three concurrent draws of the law binary on Earlgrey_0_1, MiniAmiq,
    SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. Each row-mode reads one hash, equal to the sweep's
    (evidence/det_law.txt; Scoreboard and Rggen testflags have no database).
11. **Byte controls** (evidence/controls.txt, controls_summary.txt). They cover 19 earlier repro dirs: r11u118,
    r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u256, v11u256, r11u260, v11u260,
    r11u261, v11u261, r11u263, v11u263, r11u265 and v11u265. That is 2606 case-views on both binaries, and 0 move.

Both sweeps exit 1 on the law-index staleness check alone, because the case files existed before
`tests/LAWS.md` was regenerated. The index is current in the patch.

## Decoded faces on the sister ground (report only; ParamEmit / ExprEmit are the live pass's)

- **#726217 / #727777 / #730573 (Earlgrey default), and #1444107 and its kin, which the walk now reaches.**
  - The face: a child parameter overridden at an instance, where the child body wildcard-imports a package that
    declares a parameter of the same name. Golden's elaborated param_assign constant binds the child's own `int`;
    ours binds the package parameter's.
  - The writer is ParamEmit `drainShareDefParamTs`, in its `pendingShareDefParamTs` loop. The loop scans the
    definition module's `Parameters()` by name and takes the FIRST match. The materialized import copy (`VpiImported`
    set) is listed before the module's own parameter, so the import copy wins. The `defParamTs` lambda in
    `patchParamTypespecs` has the same first-match shape.
  - Reproduced as O/o01, o02, o04, o05 in both views. The distinguisher pair is o03, no body import, and o07, no
    override.
  - Pinned with a watchpoint on the reference's actual: the write is in `drainShareDefParamTs`.
  - Confirmed on a scratch-only binary that skips `VpiImported` copies in that loop: o01, o02, o04 and o05 all read
    STRICT_EQUAL (o01's elaborated view too). The scratch binary is not in the patch, and ParamEmit is restored and
    untouched.
- **#395727** is the enum constant without a file (ExprEmit, § genCaEnumBindsSelectOnly22's sites).
- **#464077** and the 4 `u_packer` / 2 `u_usbdev.u_memory_2p` records are ExprEmit's stampFoldedPkgParamTs and
  § genIpsBoundOwner256 family.
- **The 145 xbar records the walk now reaches** are in the same family: `tlul_socket_m1` indexed-part-select width
  constants named by the generate scope or the instance, 58 `gen_idrouting` and 87 `a_source`, plus their 29 endcol
  records.
- **15 `ref_obj k` records** (`assign reg2hw_wrap.alert_en[k] = ...` in a generate loop): golden names the index
  through the written path (`...gen_alert_en_class[0].reg2hw_wrap.alert_en[k].k`), ours by scope. The writer is
  ExprEmit's hier_path select-index naming (`ir->VpiFullName(prefix + "." + varIdx)`). This is also R/r20's default
  view.
- **#1488054 and the usbdev twin**: an `int_typespec` golden writes without a file, ours located at its localparam.
  Not decoded.
- **Testflags #446024 and #604623 to #604631**, as the brief lists them.

## Residues on this ground, ranked

1. **Earlgrey testflags #580520 to #594077** (`reg2hw.mp_region_cfg[0].en.q` under a port actual, the member's
   struct copy named through `work@flash_ctrl_reg_top`). Not reproduced. Three reductions were tried and deleted:
   a named struct, anonymous member structs with a qualified port type, and three levels with prim_subreg-like
   children. All were STRICT_EQUAL in both views. In those reductions the member `ref_obj`s carry no actual, where
   Earlgrey's bind the typespec_member.
2. **The select-Lhs fold** (R/r11 to r14): golden folds a replication on a part, bit, indexed or concat Lhs, and ours
   keeps the operation. This is uhdm-cmp stage 1, so no corpus row has it.
3. **Law 3's open shapes**, all stage 1 on both binaries: a bit typedef (Surelog's `bit_var` branch, P/p10), a typedef
   of a typedef (p11), a program port (T/t01), a `var` port (p15), a `pkg::` qualified port type (t04, p04).
4. **pass 265, 263, 261 and earlier residues (brief items (2) to (5))**, including #136655 (MiniAmiq / SeqDriver
   type-parameter rebind): not attempted.

## Process

- Every corpus reader ran with the fence filter from `$FENCED`:
  - the census through the harness with the fence filter;
  - byteverify on fence-filtered mirrors;
  - the binary audit and the downstream byte check on filtered path lists;
  - rowhead, awaycorp and awaychain on Earlgrey only.
- One early Earlgrey source lookup piped a `find` path list through a filter that spelled the four fenced names
  instead of reading `$FENCED`. It ran over the Earlgrey tree only, matched nothing, and opened no fenced file.
  Every later filter reads `$FENCED`.
- One early waiter used `pgrep -f` with a pattern that matched its own command and never ended. It was stopped by
  its own task id, and later waiters bracket their patterns.
- No process was signalled other than this pass's own census and grid runs. Each was found by a bracketed pattern
  on this pass's paths, with its command line checked first.

## Files

- `cases/` holds 78 case dirs, each first line naming its law.
- `drivers/` holds case.sh, grid.sh, gridsum.py, controls.sh, ctlsum.py, tracecensus.sh, bvmirror.sh, rowhead.sh,
  det.sh, the away census drivers, dscases.py and the strictcmp_x variant, all copied from r11u265repro.
- `evidence/` holds the measurements named above.
