# r11u307 — module/type ground: nested modules (second bodies, deep stubs, positional udp form), generate-block udp statements, ordered gen-block ports and generate module arrays

Base 7f95336f (pass 305). Six laws in ModuleEmit behind `src/R307.h`. Each law reads its own `R11U307_<LAW>_OFF`
switch; `R11U307_OFF` drops all of them and gives pristine's bytes and exit code on 174 of 174 grid case-views.
`R11U307_TRACE=<dir>` logs every firing (one file per process, `OUT <-o path>` first, then `<law> <detail>`; tags
`NESTREPDEF`, `DEEPSTUB`, `DEEPSTUB_GENARRAY`, `GENMODARR`, `POSUDP_DEF`, `POSUDP_ELAB`, `DEFGENUDP`, `DEFGENORD`;
`DEEPSTUB_PARAM_ABSTAIN` writes nothing).

**THE GATE DOES NOT MOVE.** No probe case, corpus row-mode or downstream database moves in bytes (0 of 4087 probe,
0 of 3365 corpus and downstream), as the frozen firing census predicted: no `tests/probe` case and no corpus row-mode
fires any of the six laws (evidence/predict.txt is empty; positive control below). The pass targets the nested-module
residue and the generate-block instance faces that live under `tools/probe`: **110 earlier probe case-views enter
STRICT_EQUAL outside the gate**, among them every nested-module residue item (1) of the brief named (r11u297repro NM
m01, m02, m03, m04, m06, m07, m08, m09, m10, m12, m05 default; r11u295repro NA n02, n03, n07; v11u297repro VN vn01,
vn02, vn03, vn05, vn06, vn08, vn09, vn10, vn13; v11u295repro VN vn01, vn02 default; v11u298repro VN vn11, vn18 and
vn01's elaborated view; r11u298repro NC/nc08), none leaving.

| row | before (base) | after (law) |
|---|---|---|
| probe | EQUAL 4002 + STRICT_NOTEQUAL 85 | EQUAL 4002 + STRICT_NOTEQUAL 85 (regressions 0, conversions 0, changes 0) |
| surelog | 480 + 0 / 474 + 0 | unchanged (regressions 0, conversions 0, changes 0) |
| uhdm2rtlil | 803/1/67 both modes | unchanged (stamped_gen_param d/t CMP_NOTEQUAL) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | byte-identical to results/downstream_uhdm2rtlil.csv |

## Laws

The shared decode: Surelog files a nested module declaration ONCE, under its direct outer only
(`ResolveSymbols::createFastLookup` in third_party/Surelog/src/DesignCompile/ResolveSymbols.cpp, `StrCat(fullName,
"::", name)`), and elaborates every instance of it against that one definition. slang creates a fresh
`DefinitionSymbol` for a nested declaration in every elaborated body of its outer. Surelog's parser reads an
instantiation statement whose connections are all ordered (two or more, the first a net_lvalue, no parameter
override or a `#(...)` of one or two ordered values) as a `udp_instantiation` (ResolveSymbols.cpp sets
`paUdp_instantiation`; CompileModule.cpp and NetlistElaboration.cpp then compile it as a udp when no module of that
name is found).

**§ nestedDefSecondBodyReadsRep307** (`R11U307_NESTREPDEF_OFF`, ModuleEmit emitInstance). An instance of a nested
module reached from a second (third, ...) body of its outer reads the representative definition: the nested
definition of the same declaration syntax that owns the definition shell. Ours keyed the definition table by the
second body's own DefinitionSymbol, found an empty shell-less entry (pass 297's § nestedDefPortsNeedShell297) and
wrote the instance's content fresh, where golden shares the definition's cont_assign cells, processes and listings
exactly as for a second instance of a file-scope module. Cases NR (26 dirs).

**§ nestedDeepInstStub307** (`R11U307_DEEPSTUB_OFF`, ModuleEmit emitInstance, emitModuleArray, emitGenScopes). An
instance of a module nested two or more levels deep, or of a nested module instantiated inside a generate block,
finds no definition in Surelog's DesignElaboration and is written as Surelog writes any instance of an unknown
module: the header (name, full name, the scoped definition name `work@a_m::b_m::c_m`, or the generate scope's
`work@dut.u_o.g0::inner` inside a generate block, the instantiation's span, no definition file or line), no nets, no
content, no children, and one port per WRITTEN connection in written order: a named one named and located at the
formal name, an ordered one unnamed and located at its actual, each carrying only its HighConn (an empty `()` the
vpiNullOp at the closing parenthesis, `.*` nothing at all, an interface actual a ref_obj bound to the interface
instance, select full names on the stub instance); an array element carries no port and the module_array lists no
element; an array inside a generate block lists each element under the gen_scope. A parameter override abstains
(`DEEPSTUB_PARAM_ABSTAIN`: Surelog's unresolved-instance parameter road is not modelled). Cases ND (19 dirs).

**§ nestedPosInstUdp307** (`R11U307_POSUDP_OFF`, ModuleEmit emitGates and emitInstance). A nested module instantiated
with ordered connections only in the udp grammar's shape is a udp: the definition view compiles it as a udp (the
BARE definition name, terminals at the written actuals, term 0 the output, references named through the udp); the
elaborated view, for a module nested one level in its outer's own body, writes the scoped definition name and the
terminal list NetlistElaboration writes, one terminal per definition port located at the port's declaration then
one per written actual, every one carrying the actual of its position (the statement's FIRST instance's actuals for
every instance of the statement), an input terminal's bit select located at its index, a one-literal `#(N)` the
udp's unparented delay. An empty slot or anything but one unsized decimal literal in `#(...)` is not modelled and
abstains. Cases NP (14 dirs).

**§ defGenUdpFormNoStmt307** (`R11U307_DEFGENUDP_OFF`, ModuleEmit emitDefGenStmts). A generate-block statement in
the udp grammar's shape leaves NO statement in the definition view of the generate block: the definition-view
generate compile collects module instantiations only (golden NG/g01_filescope_genif and NP/p05_in_gen_block list an
empty named_begin); instance arrays and a delay2 `#(...)` included. Cases NG (11 of 16 dirs).

**§ defGenOrderedConnPorts307** (`R11U307_DEFGENORD_OFF`, ModuleEmit emitDefGenStmts). An ORDERED connection of a
generate-block child the definition view keeps (one actual, or a first actual that is no net_lvalue) is an anonymous
port located at the actual, its HighConn the actual: a reference named through the instance
(`work@outer.g.u_in.y`), any other expression as the definition view writes it, a bit select located at its index.
The syntax-driven path skipped every ordered connection and left the port list empty. Cases NG/g05, g10, g14, g15,
v11u303repro VT/vt03_positional.

**§ genScopeModArrayElems307** (`R11U307_GENMODARR_OFF`, ModuleEmit emitGenScopes). Any MODULE array written in a
generate block: the elaborated gen_scope lists each element, fully elaborated, under vpiModule exactly as it lists a
single child, element names concatenating every dimension's index; the definition-view statement keeps its
module_array. Ours wrote no element, leaving the elements missing from the elaborated view and the element module's
definition without its port phase. Cases GA (12 dirs).

## Grid (cases/; drivers/grid.sh, every line with its exit code; evidence/grid.txt, grid_summary.txt, grid_pairs.txt, grid_table.txt)

87 case dirs in GA, ND, NG, NP and NR, both views: 174 case-views, every line rc=0 on every configuration.

- **145 moving, 137 entering STRICT_EQUAL, 0 leaving**, no exit-code change; `R11U307_OFF` equal to pristine in bytes
  and exit code on 174 of 174.
- Attribution: restored by exactly one switch NESTREPDEF 35, DEEPSTUB 32, GENMODARR 20, POSUDP 15, DEFGENORD 8; the
  other 35 by a pair or triple (evidence/grid_pairs.txt): DEFGENUDP+DEFGENORD 18 (the NG udp-form statements, where
  the ordered-port law would write ports for the statement the udp law drops), DEFGENUDP+DEFGENORD+GENMODARR 4,
  DEEPSTUB+DEFGENUDP+DEFGENORD 4, DEEPSTUB+POSUDP 2, NESTREPDEF+DEEPSTUB 4, NESTREPDEF+POSUDP 3.
- Away census (drivers/awaycv.sh, order-blind away.py and chain-keyed awaychain.py; evidence/away.txt): lost 0 and
  chain away 0 on all 145 movers, 2367 records toward golden. Positive control (binaries swapped,
  evidence/away_poscontrol.txt): away on 12 of 12.
- Still not STRICT_EQUAL on the law (13 case-views): GA/a11_iface_port default (stage 1, uhdm-cmp 181 -> 625 with
  the elaborated view entering STRICT_EQUAL; the walk now diverges at a later top-level object, chain away 0, 50
  toward), ND/d07_param_ovr d/e (the parameter-override abstention, unmoved), ND/d15_iface_actual d/e (stage 1 at the
  nested definition listing's interface instance, 314 lines on both), NG/g05_concat_first d/e (`differ:line(2)`, a
  ref_obj `work@dut.u1.g.u_in.o`), NP/p03_concat_const d/e (a concatenation with a constant first actual is no udp
  statement, unmoved), NR/r04_inner_typedef d/e (golden's nested definition lists no typedef), NR/r21_nested_program
  d/e (a program nested in a module, unmoved).
- Byte movers that stay STRICT_EQUAL: NR/r14_inner_struct_param default.
- Downstream (drivers/dscases.py, evidence/downstream_{P,L}.txt): 19 STATUS_DIFF -> IDENTICAL, 2 EQUIVALENT ->
  IDENTICAL (a09, a11), 65 IDENTICAL on both, NR/r21_nested_program STATUS_DIFF on both; none worse.

## Gates (worktree at 7f95336f, SLANG_UHDM exported per binary)

- Binaries frozen before any measurement: pristine `f2536746...` (equal to the main tree's build at the base), law
  `8628ba87...`, both linking slang 12.0.0+545f88b2e.
- Firing census (drivers/tracecensus.sh, frozen before the law sweep, evidence/predict.txt, census_*.log): the law
  binary under `R11U307_TRACE` over the 4087 probe cases and both corpora in both modes with the fence filter: 0 trace
  files, 0 predicted movers. Positive control: the same binary on r11u297repro NM/m01_outer_twice writes
  `NESTREPDEF inst work@dut.u_p.u_i`; the harness passes the environment through (no `env=` in verify_golden.py or
  check_probe.py).
- Pristine sweep (evidence/sweep_P.txt) and the full law sweep (evidence/sweep_L.txt), `tests/sweep.sh --jobs 3`,
  each exiting 1 on the law-index check alone: probe EQUAL 4002 + STRICT_NOTEQUAL 85, regressions 0, conversions 0,
  changes 0; surelog default 480 + 0, testflags 474 + 0, regressions 0, conversions 0, changes 0; uhdm2rtlil 803/1/67
  in both modes, 0/0/0; downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not identical and not excused 0.
- Row-by-row csv diff law vs pristine (evidence/gates.txt): probe, uhdm2rtlil and downstream identical; surelog only
  the LowMemLib and LowMemPkg detail text (the workdir path). Downstream csv byte-identical to the committed one.
- byteverify on fence-filtered mirrors (drivers/bvmirror.sh): 0 of 3365 corpus and downstream databases moving
  (SELFCHECK 3363 of 3365, the known twin); the 4087 probe databases compared byte for byte: 0 moving.
- Canaries: surelog ok=52 and uhdm2rtlil ok=16, changed 0; ctcan2 PASS on both csvs.
- Binary-path audit: 3323 cmds.txt per sweep, 3273 naming the sweep's own binary, 0 naming the other; the other 50
  run no slang.
- Determinism (drivers/det.sh, three concurrent draws of the law binary, evidence/determinism.txt): one hash per
  row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, each equal to the law
  sweep's and the pristine sweep's.
- uhdm-cmp: every corpus row and probe case keeps its status; no gate database moved.

## Controls

- Firing scan (drivers/firescan.sh, evidence/firescan_*.txt): 25951 fence-filtered `tools/probe` dirs (path list
  filtered before any file was opened); 163 fire, 76 of them this pass's own and 87 earlier dirs. Exit codes: 382
  nonzero on the law, each equal on pristine (one 139, v11u112repro/grid/brk2/k/m07_hdr_enum_default, crashing on
  pristine too).
- The 87 earlier firing dirs in both views (evidence/controls_firing*.txt): 174 case-views, **166 moving, 110 entering
  STRICT_EQUAL, 0 leaving**, 0 exit-code changes; lost 0 on all 166, chain away 0 on 165 with 3632 records toward
  golden. The one chain-away reading is r10vrgg16repro/cells/v12 default (stage 1, 1836 uhdm-cmp lines on both,
  chain away 6, flat away 0, 320 toward): § genScopeModArrayElems307 now lists the gen-for `child a3 [2]` elements
  that golden lists, and their interface port binds `work@top.gf[0].finst` itself where golden binds the col-0 tail
  duplicate (`line:20:0`), so the walk first reaches finst through the element instead of at the gen_scope. The same
  binding is wrong on pristine at module scope (`child a1 [2] (.p(inst))`, golden `line:15:0`, ours the
  instance): an instance-array element's interface actual not taking the tail duplicate, reported as a residue. 16
  control case-views grow their uhdm-cmp line count while staying at stage 1, each with chain away 0 (the head moves
  later: d8_gen_iface_array and v4f_gen_chain 55 -> 207, the ref_module ports now written and the walk reaching the
  interface module_array; a4_gen and m4_gen, p13/p15 iface view, IA/i07, vm08_genblk, PG/p03_prog_in_generate
  35 -> 963 default with the elaborated view entering STRICT_EQUAL).
- Byte controls over passes 118, 119, 120, 124, 131, 303 and 305 (drivers/controls.sh r11u118repro r11v11u118repro
  r11u119repro r11u120repro r11v120repro r11u124repro r11v124repro r11u131repro r11v131repro r11u305repro
  v11u305repro r11u303repro v11u303repro; evidence/controls_earlier.txt): 2386 case-views, 8 moving, every one a
  firing-scan dir (r11u303repro MA/m07_genblk, r11u305repro PM/p05_ingen and v11u303repro VT/vt03_positional entering
  STRICT_EQUAL in both views; VM/vm08_genblk at stage 1 on both), 0 exit-code changes.

## Residues (ranked; all wrong on pristine too)

1. An instance-array element's interface actual binding the interface instance where golden binds its col-0 tail
   duplicate (r10vrgg16repro/cells/v12, module scope and generate scope; ModuleEmit emitModuleArray / emitInstance
   port binding, the ifaceTailDup map not consulted for array elements).
2. The nested definition listings: a typedef inside a nested module (NR/r04_inner_typedef, golden lists none), an
   interface instance inside a module nested two levels deep (ND/d15_iface_actual), a program nested in a module
   (NR/r21_nested_program; downstream STATUS_DIFF on both).
3. The deep stub's parameter road (ND/d07_param_ovr: golden's unresolved-instance param_assign with its constant at
   column 0).
4. Positional shapes the udp laws do not reach: a concatenation with a constant first actual (NP/p03_concat_const),
   the definition-view generate twin's ref_obj line (NG/g05_concat_first `differ:line(2)`).
5. GA/a11_iface_port default (module array with an interface port in a generate block, stage 1 at a later object).
6. Controls at stage 1 still: v11u298repro VN/vn01 default, vn17, r11u298repro NC/nc18, r11u99repro w28_v196nested,
   v11u252repro VS/vs11_gen_inst_depth, v11u267repro VD/vd07, v11u263repro VG/vg01, v11u268repro VQ/vq04,
   r10vrgg16repro cells v3 and v12, r10vrgg14repro/cells/v4, r11u185verify X/x06, r11u205dec GS/g06,
   r11u161gen gp/d01 (all moved toward golden or unmoved, chain away 0 except v12); the strict-only leftovers
   r10vrgg14repro/cells/v10 (col), r10vrgg16repro/cells/v1 elaborated (depth), r11u162verify naa/a05 (col),
   r11u171repro G/g07 and r11u239repro OS/x02 default (fullname), v11u110repro v1/a03_genfor_instarray (fullname),
   v11u263repro VG/vg07 elaborated (depth).

Sister-ground faces: none reached by these laws (no ExprEmit, ParamEmit or StmtEmit site written or read here).

## Process

Pass 307 was resumed after its first implementer stopped when the master's process ended; every number above was
measured on the final frozen law binary (built from the worktree as delivered) after the resume: grid, away census,
pairs, firing census, law sweep (the earlier cut sweep discarded), byteverify, canaries, binary audit, determinism,
downstream, firing scan and both control sets. The fence was read fail-closed by every driver from
tools/probe/r11u107repro/canaudit.sh, every path list filtered before any file was opened; no other agent's process
was touched and nothing was written outside the worktree and the pass's own scratch. One process listing used a
pattern that matched its own shell (listing only, nothing killed). Every sweep exited 1 on the law-index check alone.
