# r11u305 — module/type ground: positional modport actuals, interface unsized and fill cells, scoped wire typedef ends, non-ANSI interface port views and scoped simple-typedef members

Base 6efe8882 (pass 303). Nine laws in ModuleEmit and TypeEmit behind `src/R305.h`. Each law reads its own
`R11U305_<LAW>_OFF` switch; `R11U305_OFF` drops all of them and gives pristine's bytes and exit code on 236 of 236
grid case-views. `R11U305_TRACE=<dir>` logs the firings (one file per process, `OUT <-o path>` first, then
`<law> <detail>`; `IFUNSIZED305_ABSTAIN` names the unsized law's abstentions, `IFUNSIZED305_CLONE` and
`IFPLAINLHS305_BIND` the drain and binding steps of the interface laws).

**FIVE PROBE CONVERSIONS**, no change, no regression. No corpus row changes status or strict column, and no corpus or
downstream database moves in bytes (0 of 3365, predicted by the frozen firing census: no corpus row-mode fires).

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| r11u1repro/grid2 | `differ:col(2)` | **EQUAL** | § udpPosModportPathAtSel305 |
| r11v1repro/vA | `differ:col(2)` | **EQUAL** | § udpPosModportPathAtSel305 |
| r10earl53repro/v2_v53 | `differ:endline(1)` | **EQUAL** | § wireScopedTdEndAtType305 |
| r11u93repro/grid/pb19_modportview | `differ:line(14)` | **EQUAL** | § pvHdrPortDeclNetFirst305 with § pvHdrPortAtPortDecl305 |
| v11u93b107repro/brk/q04_pkg_member | `differ:name(2)` | **EQUAL** | § scopedSimpleTdMemberBindsListing305 |
| probe | EQUAL 3992 + STRICT_NOTEQUAL 95 | **EQUAL 3997 + STRICT_NOTEQUAL 90** | regressions 0, conversions 5, changes 0 |
| surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

Fresh law-sweep probe rows (evidence/sweep_L.txt, the run's probe.csv): `r11u1repro/grid2,EQUAL,,equal`,
`r11v1repro/vA,EQUAL,,equal`, `r10earl53repro/v2_v53,EQUAL,,equal`, `r11u93repro/grid/pb19_modportview,EQUAL,,equal`,
`v11u93b107repro/brk/q04_pkg_member,EQUAL,,equal`. All five also read STRICT_EQUAL in the `-elabuhdm` view except
grid2's (col -> depth: the first record moves from #402 to #643, an older param_assign face, lost 0 and chain away 0).

Outside the gate (evidence/controls_summary.txt) the interface laws convert the pass 303 residues r11u303repro IF
i03_split and i06_bareuntaken (both views) and i08_plainlhs (default view), v11u303repro VI vi06_fillboth,
vi08_vecbit and vi10_paramfromparent (both views), the earlier v11u193repro UC uc06_iface and uc22_tn_iface and
r11u118repro/grid/g1/p29_iface (both views); the port-view laws convert r11u293repro PV/pv06_header_ctl and
v11u293repro VI/vi09_modport_view (both views): 21 case-views entering STRICT_EQUAL, none leaving.

## Laws

**§ udpPosModportPathAtSel305** (`R11U305_UDPMPPATH_OFF`, ModuleEmit, the elaborated interface port's modport-qualified
High_conn). An ordered connection list whose first terminal is a net lvalue is a `udp_instantiation` to Surelog's
parser (§ udpFormNetLvalueFirst176's decode), so its FIRST terminal `u_df.mp` is a `Net_lvalue`:
`Ps_or_hierarchical_identifier u_df` followed by a `Constant_select` holding the StringConst `mp`.
NetlistElaboration's udp-terminal binding calls `isSelected`, which reads the StringConst's sibling (the empty
`Constant_bit_select`) as a selection, and compiles the terminal through `compileSelectExpression`'s StringConst
branch: the root `ref_obj` is located at the select's FIRST node (`populateCoreMembers(Bit_select, Bit_select, r1)`,
the `mp` token) and the field `ref_obj` stores no full name (`VpiFullName(field_name)`). Golden probe
`r11u1repro/grid2` `a1 (u_df.mp, o[1])`: `u_df` at 21:23-21:25, `mp` unnamed; ours `u_df` at its own token
21:18-21:22 and `mp` `work@top.a1.q.mp`. A later terminal is an Expression compiled like a named actual (grid PM
p02_second equal on both binaries), and a single-terminal list is a module_instantiation (p15_onlyconn). Two
components without blanks or selects only (`u . mp` and `ua[1].mp` are stage 1 on both binaries). Cases PM (16).

**§ ifCaUnsizedRhsClonePerInst305** (`R11U305_IFUNSIZED_OFF`, ModuleEmit emitInterfaceInstance, the copy built by
the module drain `unsizedRhsCloneDrain193`). The interface twin of § caUnsizedRhsClonePerInst193. The interface
body's cells go through the same `UhdmWriter::writeCont_assign` (§ caIfaceBodyCaFolds83's decode), whose fourth leg
clones a cell no earlier leg cloned or simplified when its Rhs holds an unsized constant anywhere
(`DetectUnsizedConstant`): `clone_tree(assign, ElaboratorContext(&s, false, true))`, `VpiParent(m)`, a whole copy
whose references read the instance's chain. Golden `assign arr[0] = (P) ? {2{sig}} : '0;` with P = 1: each
interface instance lists its own cell (`work@top.b0.P`, `work@top.b0.sig`, `work@top.b0.arr`) where ours shared the
definition's (`work@bus_t2.*`), so a second instance listed nothing of its own (uhdm-cmp stage 1 at the base). The
copy is taken BEFORE the definition's references are bound: golden's definition cell binds `sig` to the FIRST
instance's variable (as ours does), the first instance's copy carries no `vpiActual` on any reference and a later
instance's copy carries the definition's binding (`work@top.b1.sig` -> `work@top.b0.sig`); the drain drops a copy's
binding to a variable of its own instance. The module leg's gates (a select or concatenation Lhs, no cast Rhs, no
named delay), and the law stands aside on a Rhs of constants alone that slang evaluates (writeCont_assign's reduce
leg clones with the folded constant, which this law does not build: grid IU u16 to u19, `'1 & 8'h0f`, `'0 | P`,
`P ? 8'h3 : '0`, keep pristine's bytes at stage 1; a draft cloning them grew u18_el's and u19_el's uhdm-cmp line
counts 32 -> 58 and 33 -> 74, and a second draft abstaining on any evaluable Rhs gave up v11u303repro VI/vi08_vecbit
`(P) ? sig : '0`, which golden clones whole: the producer reduces operands first, so a Rhs reading a signal is not
reduced). Cases IS, IU.

**§ ifTernFillSplitPerInst305** (`R11U305_IFSPLITFILL_OFF`, also off with `R11U305_IFUNSIZED_OFF`; ModuleEmit, the
§ ifCaTernFillArmKept303 gate). Pass 303 restricted the interface fill law to definitions whose EVERY instance
selects the same fill branch, because a split definition kept the definition's cell shared by the other instances
(r11u303repro IF i03_split). Under § ifCaUnsizedRhsClonePerInst305 no instance shares it (the fill branch is itself
an unsized constant, so every other instance clones the whole cell), and golden folds each fill instance on its own:
i03_split b0 (P = 0) the `'0` BIN:0 clone, b1 (P = 1) the whole ternary with `work@top.b1.*` names. The law lifts
the restriction where the unsized leg applies. Cases IS s02-s04 (with the control i03_split).

**§ ifCaPlainLhsNoVarBind305** (`R11U305_IFPLAINLHS_OFF`, ModuleEmit). writeCont_assign's first route (a whole-name
Lhs bound by `bindVariable`, an operation Rhs cloned and reduced) never runs in an interface: `bindVariable`'s switch
has no `interface_inst` case (the decode § caStructParamIfaceSharesPaOperand289 records), so a whole-name Lhs cell
goes down the same later legs a select Lhs does: the reduce leg folds a taken fill branch (golden
r11u303repro/cases/IF/i08_plainlhs `w = (P) ? {8{sig}} : '0` with P = 0: an elaborated cell `work@top.bi.w` = the
`'0` constant at 5:31-5:33, ours none, uhdm-cmp stage 1 at the base) and the unsized leg clones the whole cell. The
fill and unsized laws take a whole-name Lhs too; the reduce leg's copy is a clone_tree of the definition's cell, so a
later instance's Lhs reference carries the definition Lhs's binding (the FIRST instance's variable, grid IU
u04_plain_ones: b1's `work@top.b1.w` -> `vpiActual work@top.b0.w`, b0's none). Cases IU u01-u04.

**§ wireScopedTdEndAtType305** (`R11U305_WIRESCOPEDEND_OFF`, ModuleEmit materializeDefNetTs, the § tdNetEnd134
lambda). A NET declaration written with a package-scoped type (`wire pk::sa_t sn;`) is compiled by
`compileNetDeclaration`'s non-StringConst branch: the Data_type child (`pk::sa_t`, a Class_scope) becomes the net
type and the Data_type node itself the Signal's packed dimension, the slot writeNets' end-only populate reads when the
declaration has no unpacked dimension. The shared typedef's END (and file) moves to the end of the written type name,
the last net written winning (golden probe r10earl53repro/v2_v53 `wire pv2_v53::sa_t sn;`: `sa_t` 4:11-32:21, ours
its own 4:11-4:58). A bare or imported type name takes the StringConst branch (no packed dimension; grid WN w02 and
w05 stage 1 on both binaries), a `var` / data declaration is not a net (w03, w15), an initializer abstains (w07
stage 1 on both binaries). Macro type, include header (the file moves), CRLF and two modules measured. Cases WN (21).

**§ pvHdrPortDeclNetFirst305** (`R11U305_PVHDRPORTDECL_OFF`, ModuleEmit, the modport port view's io_decl net of an
interface header port). A header port of a NON-ANSI interface whose port declaration (`output [31:0] o;`) is
written ABOVE its body declaration (`wire [31:0] o = 32'd12;`) has two Signals in the producer, the port
declaration's first (§ caIfacePortDeclNetMint93), and the modport view's net is that first one: golden probe
r11u93repro/grid/pb19_modportview locates `work@dut.u_s.m.mp.o.o` at the port declaration's name 3:17 with the port
declaration's own `[31:0]` typespec (3:10-3:16, § ifacePortDeclTsAtPortDecl205's object); ours at the body
declaration 5:15 with `wire [31:0]` 5:3-5:14. Cases PV v01, v04, v07.

**§ pvHdrBodyFirstNdaCell305** (`R11U305_PVBODYFIRSTNDA_OFF`, ModuleEmit, the § portViewNdaNetCellParent293 gate).
§ portViewNdaNetCellParent293 stands a header port aside because its port declaration's Signal comes first; when the
BODY declaration is written first (`wire [31:0] o = 32'd12;` above `output [31:0] o;`), the body's net is the first
Signal and the modport view's net is it, parented at its unlisted net-declaration cell with no stored full name and
its ref_typespec named `o` (grid PV v02_bodyfirst; ours `work@dut.u_s.m.mp.o.o`). Case PV v02.

**§ pvHdrPortAtPortDecl305** (`R11U305_PVPORTLOC_OFF`, ModuleEmit, the port view's header ports). A PORT view lists no
port-declaration mint (§ caIfacePortDeclNetMint93 is a home-view object), but its port and Low_conn take the port
declaration's place all the same, as the home view's copyLoc93 has it (golden pb19 `work@dut.u_s.m.o` at 3:17, the
`output [31:0] o;` name, ours the header list's `o` 2:16), and the Low_conn binds the modport io_decl's net (golden
`vpiActual work@dut.u_s.m.mp.o.o`), where ours minted a bare net at the header token; a port the modport does not
expose keeps its bare net, located at the port declaration (PV v13_notinmp: golden 4:16, ours 2:19). Only a header
port with a written port declaration. Cases PV (14).

**§ scopedSimpleTdMemberBindsListing305** (`R11U305_SCOPEDTDMEM_OFF`, TypeEmit buildStructTs and buildUnionTs, with
LAW S skipping the member). A struct or union member written with a PACKAGE-SCOPED name of a typedef of a built-in
type (`pk::w_t a;`, `typedef logic [2:0] w_t;` in a package) binds that package's typedef object itself, named
`pk::w_t`: the Class_scope lookup reaches the package's TypeDef, whose typespec the package compile already set,
and compileDatastructureTypespec's TypeDef branch returns it (`result = parent_tpd->getTypespec()`, CompileType.cpp),
where an unscoped name reaches the SimpleType branch's clone-with-alias (the pristine road, jeras_union's
`reg_addr_t rs1`, kept). Golden grid TQ: member `a` -> `pk::w_t` at the package's 2:21-2:32 with its range in a
module typedef, a union, an unpacked member dimension (the element), an inline struct variable, a class, an
interface, a nested struct, a port typed by another package's struct, a type-parameter and a localparam type
default, logic, bit, int and signed typedefs; ours a `w_t` copy with Typedef_alias -> `pk::w_t` (LAW S's bare
member copy, now skipped for these members). Outside the package's own definition listing the binding is the
ELABORATED package's twin (s23_paramwidth: `[W-1:0]` folded `INT:2`). A member with its own packed dimension
(`pk::w_t [1:0] a`, golden drops the dimension and binds `pk::w_t`: a Surelog defect, not copied), an enum or
aggregate typedef, a typedef of a named type (s17_tdchain, unchanged and equal), a cast clone tree and a struct
parameter's per-parameter clone stand aside (golden TQ s15_param: that copy's member is a `w_t` clone with Instance pk,
the pristine road; a draft binding the listing there read chain away 4 on both views and was refined before
delivery).
Converts probe v11u93b107repro/brk/q04_pkg_member. Cases TQ (34).

## Grid (cases/; drivers/grid.sh, every line with its exit code; evidence/grid.txt, grid_summary.txt, grid_pairs.txt)

118 case dirs in both views, 236 case-views: PM 16, IS 9, IU 20, WN 21, PV 18, TQ 34 (each case names its law in its
first line). Configurations P (pristine), L (law), OFF (law + R11U305_OFF) and the law with each of the nine switches
off.

- 160 case-views moving, **134 entering STRICT_EQUAL, 0 leaving**, 0 exit-code changes (every line rc=0 except the
  four case-views Surelog rejects on every configuration: TQ/s25_cast rc=4 and WN/w12_delay rc=3, kept as written),
  OFF equal to P in bytes and exit code on 236 of 236.
- Attribution (the switch whose `_OFF` alone gives P's bytes): SCOPEDTDMEM 46, IFUNSIZED 26, WIRESCOPEDEND 24,
  UDPMPPATH 18, IFPLAINLHS 4, PVPORTLOC 4, IFUNSIZED or IFPLAINLHS 8 (a whole-name Lhs: either switch restores), and
  30 PV case-views that need a pair or a triple (grid_pairs.txt): PVHDRPORTDECL + PVPORTLOC 28,
  PVHDRPORTDECL + PVBODYFIRSTNDA + PVPORTLOC 2 (v02_bodyfirst). Every switch moves bytes on its own
  (grid_switch_effect.txt: the case-views whose bytes leave the law's when the switch alone is off: SCOPEDTDMEM 46,
  IFUNSIZED 34, PVPORTLOC 34, PVHDRPORTDECL 30, WIRESCOPEDEND 24, UDPMPPATH 18, IFPLAINLHS 12, IFSPLITFILL 8 (IS
  s02-s04 and IU u03 return to the split `type` face), PVBODYFIRSTNDA 2).
- Per family (moving / entering STRICT_EQUAL of the case-views): PM 18 / 14 of 32, IS 10 / 10 of 18, IU 28 / 26 of 40,
  WN 24 / 14 of 42, PV 34 / 28 of 36, TQ 46 / 42 of 68.
- Away census (drivers/awaycv.sh, order-blind and chain-keyed) on all 160 movers: **lost 0 and chain away 0 on every
  one, 1845 chain records toward golden** (evidence/grid_away.txt). Positive control (binaries swapped) on 12 sampled
  movers: away on 12 of 12 (grid_away_poscontrol.txt).
- uhdm-cmp line counts: every mover's count falls or stays (IS and IU stage-1 views 31 or 33 -> 0; IU u01_el and u03_el
  33 -> 28 at stage 1, residue 1); none grows.
- Downstream (drivers/dscases.py on both binaries, 118 dirs; evidence/downstream_cases.txt, downstream_summary.txt): no
  verdict worse; 6 improve (IS s02, s03, s04, IU u01, u03 EQUIVALENT -> IDENTICAL; IU u04 DIVERGENT -> IDENTICAL);
  106 IDENTICAL, 7 EQUIVALENT, 2 DIVERGENT, 1 STATUS_DIFF and 2 SURELOG_FAIL on the law binary, each the pristine
  verdict for the 112 unchanged dirs.

## Gates (worktree at 6efe8882, SLANG_UHDM exported per binary)

- Builds: pristine 0679e3cb (equal to the main tree's build/slang-uhdm), law 27389a5a; both frozen read-only before
  any measurement; slang 12.0.0+545f88b2e. Two law binaries were frozen earlier and replaced, each with the grid,
  census and sweep rerun in full on the next one (Process).
- Firing census frozen before the law sweep (drivers/tracecensus.sh over the probe and both corpora in both modes,
  fence-filtered; evidence/predict.txt): exactly 5 probe databases (the five conversions) and **0 corpus row-modes**.
  Byte movers in the sweeps: probe exactly those 5 (byteverify_probe.txt), corpus and downstream 0.
- Law sweep `tests/sweep.sh --jobs 3` (evidence/sweep_L.txt; pristine sweep_P.txt): probe EQUAL 3997 +
  STRICT_NOTEQUAL 90, regressions 0, conversions 5, changes 0; surelog default 480 + 0, testflags 474 + 0, 0/0/0;
  uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0, the csv
  byte-identical to results/downstream_uhdm2rtlil.csv. Both sweeps exit 1 on the law-index check alone (tests/LAWS.md
  regenerated in the patch).
- Strict column, whole csvs row by row against the pristine sweep (evidence/csv_diff.txt): probe exactly the five rows;
  surelog only the LowMemLib / LowMemPkg testflags detail text (the workdir path); uhdm2rtlil and downstream 0 rows.
- Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered hard-link mirrors of the two
  same-length workdirs: **0 of 3365** corpus and downstream databases move (SELFCHECK 3363 of 3365, the known twin;
  evidence/byteverify_corpus.txt), as predicted; the UVM family coin read the same bytes on both sweeps.
- Away census on the five probe movers in both views: lost 0 and chain away 0 on all ten case-views, 138 chain records
  toward golden (evidence/probe_movers_away.txt).
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6).
- Binary-path audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary, the other 50 run no slang
  (evidence/canaries_audit.txt).
- Determinism (drivers/det.sh, three concurrent draws per row-mode on the law binary): Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen default and every testflags row-mode with a database read one
  hash each, every hash equal to the law sweep's (evidence/determinism.txt).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` before any case is opened; evidence/controls*):
  28 earlier repro dirs (r11u303, v11u303, r11u193, v11u193, r11u83, r11v83, r11u289, v11u289, r11u93, r11v93,
  r11u293, v11u293, r11u108, v11u108, r11u111, v11u111, r11u134, r11u297, v11u297, r11u200dec, r11u176, r11u155,
  r11u183dec, r11u118, r11v11u118, r11u119, r11u88, r11u85): 3676 case-views, **34 moving, 21 entering STRICT_EQUAL,
  0 leaving**, 0 exit-code changes, 18 uhdm-cmp line counts falling and none growing; lost 0 and chain away 0 on all 34
  with 259 records toward golden (controls_away.txt); every mover attributed (controls_attrib.txt): IFUNSIZED 16
  (r11u303 IF i03_split, i06_bareuntaken; v11u193 UC uc06_iface, uc22_tn_iface; v11u303 VI vi02, vi08, vi10, vi13),
  IFUNSIZED or IFPLAINLHS 2 (r11u118 p29_iface), IFUNSIZED or IFSPLITFILL 2 (vi06_fillboth), IFPLAINLHS 2 (i08_plainlhs),
  UDPMPPATH 2 (r11u176 PG/g16_generic_mpconn_pos_two, stage 1 unchanged count), SCOPEDTDMEM 2 (v11u111
  x24_otherpkg_member_q, stage 1, 126 -> 17 lines), PVPORTLOC 2 (v11u293 vi24_modport_import_func, stage 1 unchanged
  count), the PVHDRPORTDECL + PVPORTLOC pair 6 (r11u293 pv06_header_ctl, v11u293 vi09_modport_view and
  vi21_gen_iface_modport, the last at the same first field with chain away 0).

## Residues (ranked; all wrong on pristine too unless stated)

1. **The interface elaborated view of a whole-name Lhs fill** (grid IU u01_plain_fill_el, u03_plain_split_el; r11u303repro
   IF i08_plainlhs_el): stage 1 on both binaries. Golden's `-elabuhdm` cell reads the `'0` constant with vpiSize 8 where
   ours keeps -1: UHDM's elaborator re-sizes the constant assigned to a whole-name variable, and the object golden
   lists is the definition's own `'0` re-parented by the reduce leg (`res->VpiParent(assign)`), so the definition
   listing's copy changes size with it. Not written (the default view, the gate, is STRICT_EQUAL on all four).
2. **The interface cells the reduce leg folds to a constant** (grid IU u16_constop_plain, u17_constop_sel,
   u18_paramop, u19_tern_constarms: an operation over constants with an unsized literal, `'0 | P`, `P ? 8'h3 : '0`):
   stage 1 on both binaries; golden clones the cell with the folded constant (writeCont_assign's reduce leg),
   ours shares the definition's cell. § ifCaUnsizedRhsClonePerInst305 stands aside on them (slang evaluates the Rhs).
   The next interface law: transcribe the reduce leg's clone for interface cells (the module side has it in
   § caFoldedRhsShares* / the elab cont_assign folds).
3. **v11u303repro VI vi02_partsel and vi13_paramidx** (the fill law's open shapes: a part select of an unpacked element
   `arr[0][3:0]`, a parameter index `arr[K]`): `type` on both binaries in the default view; the elaborated view moved
   stage 1 -> type under § ifCaUnsizedRhsClonePerInst305 (the first record the fill constant golden folds).
4. **The positional modport actual shapes the law does not reach** (grid PM): an interface-array element `ua[1].mp`
   (p04), the instance inside a generate block (p05), two interfaces of one definition (p06), a spaced `u . mp` (p08),
   an interface child (p10) and a module instantiation whose later terminal is `u.mp` (p03): stage 1 on both binaries,
   each on another face (the ref_module / port listing).
5. **The scoped member shapes left alone** (grid TQ): `pk::w_t [1:0] a` (s05, golden binds `pk::w_t` and drops the
   member's own dimension: a Surelog defect, report only), a struct parameter value `'{a: 3'd5, ...}` (s15, stage 1 on
   another face, chain toward 12), a named import `import pk::w_t;` (s18), a function-local typedef (s24) and an imported
   type-parameter default (t05), all stage 1 on both binaries; a cross-package struct whose member typedef has a
   parameter-dependent width (s26: the package's own listing keeps the symbolic `W-1` where golden folds it; stage 1
   on both binaries).
6. **The wire-typedef shapes at stage 1 on both binaries** (grid WN): `wire sa_t sn;` with an imported or local typedef
   (w02, w05), a scoped union, enum or vector (w11, w08, w10), a comma list (w13), `tri` (w17), a generate block (w18),
   an interface (w09), a scoped type with an unpacked dimension (w04) or an initializer (w07): the producer's
   StringConst-branch nets and the typed-net writer are another face.
7. **The modport port view of a generic port** (grid PV v08_generic: `fullname`, golden names the Low_conn
   `work@dut.u_s.u_if.mp.o` through the connection) and a header port with no body declaration (v05_hdronly) and the
   ANSI control (v15) at stage 1 on both binaries.
8. **Sister-ground faces found on the way (reported, not written):**
   - the subroutine body's implicit `begin` counts a TYPEDEF as an item: Surelog anchors the wrapper at the body's
     SECOND item counting typedefs (golden `function void c::g(); typedef ...; st_t v; v = 0;` begin at `st_t v;`,
     `int a; typedef ...; st_t v;` at the typedef, ours skips typedefs): probe r10uvm213repro/g213_i_scopedtd
     `line(2)`; the anchor sits in StmtEmit's statement-list branch (`items9[1]`), the sister's; scratch grid (10 class,
     package and module shapes, the module-function ones stage 1 on another face) not committed;
   - the package-level `si_t a [0:1]` / `en_t a [0:1]` variable (array_var) moving the typedef's end only in the
     elaborated package listing (probe r11v77repro/grid/vh_arrelem `endline(6)`): the package net listing, ParamEmit;
   - the uninstantiated interface's foreach over a parameter array (probe r10uvm220repro/grid220/a1_uninst_if
     `file(2)`): StmtEmit § uninstIfaceForeachHdrUnresolved220's array_typespec;
   - b3 / n4 (the struct-valued function fold, ParamEmit) and v13_v54 (a bound instance's connection reference bound
     to the top's port, ExprEmit naming).
9. The brief's items (2) to (7) beyond the above not attempted: the nested modules (r11u297repro NM: m01 reads
   `type` in the elaborated view and stage 1 in the default view on the base), the type-parameter element names (e18,
   b18, b21, i16, k13_anon_enum), the q2::row_t alias family (x36, x40, y31: three different faces), v41v_comment,
   v59v2_earl59, g13, v5_home, l_concat, e05 and the per-pass residue lists.

## Process

Every driver reads `$FENCED` fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line (drivers/env.sh);
every corpus path list was filtered before any file was opened; no fenced name is spelled in a file of this pass. No
other agent's process was listed or signalled; the main tree was not written (worktree /tmp/wt_r11u305, scratch
/tmp/r11u305_*). **The implementer's slips, no effect on any number:** (1) a Monitor wait was written with
`pgrep -f` on a driver path its own command line contained (a self-matching wait); it was stopped by its own task id
at once and every later wait read a marker file. (2) One `ps` listing filtered to this pass's census printed that
census's own `verify_golden.py --filter` argument, which carries the fenced names; no fenced source or database was
read. (3) Two law binaries were frozen before the final one: the first moved TQ/s15_param chain away 4 (the struct
parameter clone, refined by `!structCloneMemberRefParent`), found by the grid's away census before the law sweep; its
census was stopped by its own task id and its grid pair run killed by pid after the pid's command line was checked to be
this pass's; the second abstained on every constant-evaluable interface cell and gave up vi08_vecbit, found by the byte
controls after a complete law sweep (that sweep read the same gate numbers as the final one); the grid, census, law
sweep, byteverify, controls, determinism and downstream cases were all rerun in full on the final binary 27389a5a,
whose census output equals the earlier one byte for byte. The sweeps exit 1 on the law-index check alone.

Files: cases/{PM,IS,IU,WN,PV,TQ} (118 dirs; WN/w21_header carries its pk.svh), drivers/ (copied from r11u303repro;
grid.sh's switch list, gridpairs.sh rewritten for nine switches, gridsum305.py, tracecensus.sh's trace variable renamed
for this pass), evidence/.
