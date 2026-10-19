# r11u411 — the sv-tests campaign's sixth pass on the expression/parameter ground

Implementer pass on base b94cdc04 (passes 401, 402, 404, 403, 406, 405, 408,
407, 410, 409 and 412 landed), ground src/ExprEmit.cpp, src/EmitHelpers.h,
src/StmtEmit.cpp, src/ParamEmit.cpp.  Every law is `§ <name>411` read through
`lawOn(411, "R11U411_<LAW>_OFF")` (src/LawSwitch.h); `R11U411_OFF` drops all of
them; `R11U411_TRACE=<dir>` logs each firing through `lawTrace(411, ...)`.  No
src/R*.h, no getenv, no reader function; the patch touches src/ExprEmit.cpp only
(EmitHelpers.h, StmtEmit.cpp, ParamEmit.cpp, include/ unchanged).

Binaries: pristine 42190a8e4437a04efe2664fc6287574c (the worktree's build at the
base, equal to the main tree's build/slang-uhdm), first law binary
656f9c7606166b7e4f5c885e7cf045b5 (`final`, swept once in full), final law binary
4b88888886ce7960f44f3689389f1dc5 (`final2`: the same source with the two
package-cast laws narrowed to parameter declarations after sweep 1's trace;
the two stages that law reached were rerun alone on it).  The pristine reading
is the master's control sweep at the base (/tmp/intr11u412, its csvs equal to
the committed results/*.csv); no pristine sweep was run.  Every case line
carries the exit code.

## Verdict per targeted row (sv-tests, results/golden_svtests.csv -> the law sweep)

| row | before | after | laws |
|---|---|---|---|
| chapter-8/8.8--typed_constructor.sv | DIFFERENT | **EQUAL** | § typedCtorClassArgNet411 |
| chapter-8/8.8--typed_constructor_param.sv | DIFFERENT | **EQUAL** | § typedCtorClassArgNet411 |
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_router_decoder_dor.sv | DIFFERENT | **STRICT_NOTEQUAL** `differ:fullname(1)` | § enumSubstDecDecompile411 |

Fresh rows (/tmp/r11u411_w2/svtests.csv, identical to sweep 1's):

    chapter-8/8.8--typed_constructor.sv,EQUAL,,equal
    chapter-8/8.8--typed_constructor_param.sv,EQUAL,,equal
    generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_router_decoder_dor.sv,STRICT_NOTEQUAL,differ:fullname(1),differ:fullname(1)

The sv-tests stage reads `regressions=0 conversions=3 changes=0`; status
counts EQUAL 1698 -> 1700, STRICT_NOTEQUAL 96 -> 97, DIFFERENT 146 -> 143,
BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346.

decoder_dor's remaining strict field (decoded, not written): the index `i` of
`cord_markers_pos_p[i]` in a generate-block localparam initializer
(bsg_wormhole_router_decoder_dor.sv 33:57) is named
`work@bsg_wormhole_router_decoder_dor.rof.cord_markers_pos_p.i` in golden and
`...rof.i` by us.  The shape needs more than a name: a generate localparam
reading a parameter's bit (evidence/residue_cases/GS_genlp_selidx_fullname,
gs01/gs02/gs04 NOT_EQUAL on pristine and final alike) also differs in the
select's parent and the elaborated fold, so it stays a residue.

Probe residues of earlier passes this pass closes (tools/probe, not gate cases):

| case | pristine | final |
|---|---|---|
| v11u409repro/cases/VN/vn03 (goal 1) | rc=4 NOT_EQUAL | rc=0 NOT_EQUAL (the value face below) |
| v11u410repro/cases/VP/vp05 (goal 1) | rc=4 NOT_EQUAL | rc=0 **STRICT_EQUAL** |
| v11u409repro/cases/VG/vg03 | rc=0 NOT_EQUAL | rc=0 **STRICT_EQUAL** |
| v11u409repro/cases/VG/vg04 | rc=0 NOT_EQUAL | rc=0 **STRICT_EQUAL** |

## Goal 1 (what upstream slang accepts, slang-uhdm must accept)

- (a) THE TWO PROBE FACES: both exit 0 now.  `parameter e_t P = e_t'(1)` in a
  package (VN/vn03): § pkgEnumCastTargetTs411.  `(i)'(x)` with a genvar i
  (VP/vp05): § genvarCastTgtUnsupTs411, STRICT_EQUAL.  Two more goal-1 shapes
  found and written on the way: a package parameter cast to a simple alias of
  the same package (`typedef int i_t; parameter i_t P = i_t'(3);`, EC/ec06,
  ec08, ec10, exit 4 on pristine): § pkgAliasCastTargetTs411; a member of a
  function call's result (`pk::mk().s`, `mk(4'd3).b`, MC and TC/tc06, exit 4
  "member access base" on pristine): § callResultMemberDropped411.
- (b) BLACK-PARROT: not lifted.  bp_unicore alone on the final law binary with
  the guard on: exit 3 (`basic_string::substr`, the guarded crash) in 12.4 s
  at 834 MB max RSS (the runner row: surelog CRASH -11, slang REJECT 3,
  13.0 s).  No memory-bounded export was found; the six rows stay
  SURELOG_CRASH behind § macroVecLitTokenText403's size guard.
- (c) generated/rsd/rsd.sv: SURELOG_CRASH, not this ground.
- (d) Every SURELOG_ONLY / BOTH_REJECT / SLANG_CRASH row of the baseline was
  read by its detail: none carries an exporter error.  All 75 SURELOG_ONLY
  details are upstream slang diagnostics (`error:` lines); the five rows whose
  detail mentions `slang-uhdm` (generated/uvm-examples/biquad_example.sv,
  uvm_c_stimulus_bl_example.sv, uvm_register_mem_example.sv,
  uvm_register_spi_bl_tb.sv, uvm_tb_build_bl_tb.sv) carry it only in the
  checkout path of the upstream diagnostic `design element does not have a
  time scale defined` in uvm_pkg.sv:28.  None is this ground's.

## Laws (src/ExprEmit.cpp; switch; cases)

- § genvarCastTgtUnsupTs411 — `R11U411_GENVARCAST_OFF`.  A cast whose size is
  a genvar written bare or in parentheses (`i'(x)`, `(i)'(x)`, `((i))'(x)`) in
  a generate body is Surelog's unresolved type name in every view: an
  unsupported_typespec named by the identifier at its own span.  The genvar is
  read from the enclosing loop generate's header (an elaborated generate
  process has no cast-site scope).  The elaborated bind was excluded for
  genvars by § castSizeElabScopeBind57, so the bad size was queued and the
  drain died on `expression kind: Invalid`.  Cases GC/gc01-gc06.
- § pkgEnumCastTargetTs411 — `R11U411_PKGENUMCAST_OFF`.  A package parameter's
  cast to its own package's ENUM typedef (`parameter e_t P = e_t'(1);`) takes
  § pkgTypedefCastTargetTs140's deferred reference onto the listed
  enum_typespec, as the struct and union casts do (golden: operation 67 with a
  ref_typespec onto enum_typespec p::e_t).  Written only inside a parameter
  declaration (the narrowing after sweep 1, below).  Cases EC/ec01-ec05, ec07.
- § pkgAliasCastTargetTs411 — `R11U411_PKGALIASCAST_OFF`.  The same for an
  alias of any other type (`typedef int i_t;`, `typedef logic [3:0] v_t;`):
  the cast binds the package's listed typedef so the export is accepted.
  Golden's target is the alias's named twin (int_typespec `i_t`, logic_typespec
  `v_t`, the object the parameter itself is typed by), which our parameter
  does not have either (residue).  Cases EC/ec06, ec08, ec09 (module control),
  ec10.
- § enumSubstDecDecompile411 — `R11U411_ENUMSUBSTDEC_OFF`.  A qualified
  package enum member written with a sized DECIMAL literal (`P = 3'd0`)
  carries `INT:` with the written text as its decompile; the constant a module
  substitutes for `p::P` reads the value's digits (golden decompile `0`, `3`,
  `5`); hex and binary members keep their written text (ef06's `4'hA`,
  `4'b0101`, unchanged and equal).  Cases EF/ef01-ef08.
- § typedCtorClassArgNet411 — `R11U411_TYPEDCTOR_OFF`.  A typed constructor
  call `C::new`, `C#(...)::new(...)` is to Surelog a call of `new` whose ONE
  argument is the class name read as a value: a ref_obj named by the class
  identifier, spanning the class name with its parameter list, the written
  constructor actuals dropped; in a module process the name resolves to the
  implicit module wire minted at its first reference (vpiNetType 1, through
  mintImplicitNet403), in a package subroutine it stays unbound.  Cases
  TC/tc01-tc06.
- § callResultMemberDropped411 — `R11U411_CALLMEMBER_OFF`.  A member of a
  function call's result (`mk().s`, `pk::mk(x).a`, the function a module,
  $unit or package subroutine, not a class method) is the call alone: the
  func_call with its arguments and its function link, the member dropped; an
  unqualified call spans the whole written member access (golden func_call
  (mk) 7:14-7:24 over `mk(4'd3).b`), a qualified one keeps the qualified-call
  span.  Cases MC/mc01-mc04, TC/tc06.
- § gateGenvarDivShiftFold411 — `R11U411_GATEDIVSHIFT_OFF`.  Pass 409's
  gate-terminal genvar fold extended to a division and a shift over the genvar
  (`a[i/2]`, `y[i<<1]`, `y[i>>1]`): INT once a `/` takes part (as `-` and
  `*`), UINT for a shift at the top whatever its operands hold (`a[i*2>>1]`
  UINT).  Cases GD/gd01-gd05, v11u409 VG/vg03, vg04.
- § gateGenvarParenLeftSpan411 — `R11U411_GATEPARENSPAN_OFF`.  The folded
  constant's span is the top operation's left operand WITH its parentheses
  (`y[(i+2)/2]` 5:15-5:20, `a[(i<<1)+1]` 6:28-6:34), applied to pass 409's
  branch too, when no whitespace sits inside the parentheses.  Cases GD/gd03,
  gd04.

## Grid (tools/probe/r11u411repro/cases, 39 case dirs; evidence/grid_final.txt)

`drivers/grid.sh /tmp/r11u411_bin/pristine /tmp/r11u411_bin/final2 <out>`:
per case pristine and final (exit code, uhdm-cmp lines, dump distance, md5,
strict verdict), R11U411_OFF and the group's own switch against pristine's
bytes.

- 22 cases NOT_EQUAL -> STRICT_EQUAL: GC/gc01-gc03, EF/ef01, ef02, ef06, ef07,
  GD/gd01-gd05, MC/mc01-mc04, TC/tc01-tc06.
- 17 cases exit 4 -> exit 0: EC/ec01, ec02, ec04-ec08, ec10, GC/gc01-gc04,
  MC/mc01-mc04, TC/tc06.
- 8 controls byte-identical: EC/ec03, ec09 (module enum / alias casts, not
  fired), EF/ef03, ef04, ef05, ef08, GC/gc05 (a generate localparam size), gc06.
- Still NOT_EQUAL after the law: EC/ec01-ec08, ec10 (the value face and the
  alias twin, residues below), GC/gc04 (the cast operand in an elaborated
  generate always_comb binds no net in ours; was exit 4).
- Grown by line counts while moving exit 4 -> 0: EC/ec06 (cmp 38 -> 46), ec08
  (76 -> 122), ec10 (76 -> 122): pristine's database there is the partial one
  an exit-4 export leaves; the law's adds the parameter casts and their alias
  references, whose name is the residue (`p::v_t` where golden writes the twin
  `v_t`).
- R11U411_OFF gives pristine's bytes and exit code on 39 of 39; each case's own
  switch on 37, with EC/ec08 needing R11U411_PKGENUMCAST_OFF too (it holds an
  enum and an alias cast) and TC/tc06 R11U411_CALLMEMBER_OFF too
  (`pk::mk().s`).
- The final2 grid is byte-identical to the first law binary's on all 39.

Byte controls on earlier passes' grids: every `dut.sv` under
tools/probe/r11u40*repro, v11u40*repro, r11u41[02]repro and v11u41[02]repro
(1599, fence-filtered; drivers/ctlmd5.sh; evidence/control_cases_md5_pristine_vs_final.txt):
pristine vs final2 the same exit code and bytes on 1595; the 4 movers are the
targeted residues above (VN/vn03, VP/vp05, VG/vg03, VG/vg04).

## Gates (the measurement budget: one full sweep)

Sweep 1, the full five stages on the first law binary (`final`, 656f9c76;
drivers/sweep.sh: the four corpus stages through the worktree's
tests/sweep.sh, the sv-tests stage through the main tree's
scripts/check_svtests.py read-only with the worktree's baseline, a worktree
having no UVM tree; R11U411_TRACE on; evidence/sweep1_law7):

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0 conversions=0
  changes=0.
- surelog: default CMP_EQUAL 480, testflags 474, regressions=0 conversions=0
  changes=0.
- uhdm2rtlil: 803/1/67 in both modes, regressions=0 conversions=0 changes=0;
  canaries ok=16 changed=0, ctcan2 PASS.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  not identical and not excused 0.
- sv-tests: regressions=0 conversions=3 changes=0 (the three rows above).
- byteverify against the master's control /tmp/intr11u412 (same-length
  workdir names): uhdm2rtlil 0 of 1608, downstream 0 of 805, surelog 9 of 962:
  BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM default and testflags and
  Scoreboard default.  The trace named the one law firing there:
  § pkgEnumCastTargetTs411 on `uvm_severity'(UVM_ERROR)` in uvm_pkg's
  `uvm_report` default argument (`int verbosity = (severity ==
  uvm_severity'(UVM_ERROR)) ? ...`, uvm_globals.svh, 147:56 in the MiniAmiq
  row's UVM copy), which the pristine
  path already resolved: MiniAmiq default's dump differs in 2 lines, the
  ref_typespec's actual moving from one enum_typespec copy
  (uvm_pkg::uvm_severity 271:61) to another (352:37), invisible to both
  comparators.  Not a parameter, not the law's shape: THE LAW WAS NARROWED to
  casts written inside a parameter declaration (`final2`).

The narrowed law reached only the surelog and sv-tests stages (sweep 1's
trace: probe 2 firings of § enumSubstDecDecompile411 on
r10vearl99repro/v99_enum and v99_enum2 with path-normalized dumps identical
to the control; uhdm2rtlil and downstream no firing), so those two stages
reran alone on final2 (drivers/rerun.sh; evidence/rerun_final2):

- surelog: default 480, testflags 474, regressions=0 conversions=0 changes=0;
  the csv equal to the control's but for the two LowMem log-path detail
  texts; byteverify 0 of 962 (SELFCHECK 961 of 962 flagged); canaries ok=52
  changed=0; ctcan2 PASS; no law fired.
- sv-tests: regressions=0 conversions=3 changes=0, the csv identical to
  sweep 1's on all 2346 rows; the trace fires only on the three converted
  rows (§ typedCtorClassArgNet411 on the two 8.8 rows,
  § enumSubstDecDecompile411 on decoder_dor).
- the away census: the firing rows not EQUAL are decoder_dor alone, which
  moved DIFFERENT -> STRICT_NOTEQUAL (toward golden).
- the sv-tests databases kept by both this run and the control (261; a
  database embeds its work path, so bytes are compared on path-normalized
  dumps, drivers/svnorm.sh): 259 identical to the control, decoder_dor the
  one mover (the converted row), generated/tnoc/tnoc.sv's dump not completed
  (stopped by its PID after 20 minutes; no law fired on it in the trace).
  The two 8.8 rows are EQUAL and keep no database.
- the binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the
  binary under test, 0 another, 50 hold no slang line (two of them name the
  repository path in a Surelog line); uhdm2rtlil 1740 of 1740; sv-tests 2346
  of 2346.

## Residues (ranked; all wrong on pristine too)

1. The enum-cast VALUE: Surelog folds `e_t'(N)` for a base-less enum to
   `UINT:0` at size 0 in every elaborated listing and at every read
   (EC/ec01, ec02, ec04, ec07, VN/vn03; ec03 in a module, pristine-equal
   bytes); a based enum (`logic [1:0]`) keeps the masked value (ec05).  Our
   value is slang's.  The fold sits in the parameter value and every
   substituted read (ParamEmit and ExprEmit), not one site.
2. The alias twin of a package typedef used as a parameter's type and cast
   target (int_typespec `i_t`, logic_typespec `v_t` with an alias ref onto
   the listed typedef: EC/ec06, ec08, ec10; ec09 in a module the same).
3. decoder_dor's generate-localparam select index name (above) and the
   GS shapes in evidence/residue_cases/GS_genlp_selidx_fullname.
4. GC/gc04: the operand of a genvar cast in an elaborated generate
   `always_comb` stays unbound (golden binds the module net); GC/gc05: a
   parenthesized generate-localparam cast size takes the localparam's own
   int_typespec in golden (ours an integer_typespec).
5. The remaining both-accepted rows heads on this ground, read at the base on
   the kept pairs (evidence/svtests_different_heads_pristine.txt): tnoc
   (golden's 241 artefact), p733 (a defparam override: golden keeps the
   default `size-1` = 0), class_test_51 ($bits in a class parameter),
   p88/p124 (the type-parameter variable initializer size), p148/p184/p334,
   scr1, fx68k; and the probe backlog of passes 401 to 409 not reached.

## Sister-ground faces (reported, not written)

- TypeEmit `emitSyntaxExpr`'s bit_select branch (the `auto* bs =
  s.MakeBit_select()` after the indexed part-select branch, § defGenLhsSelIdx
  ThroughBase257's neighbour): in a DEFINITION-view generate block, a
  ref_module port's high_conn CONCATENATION operand `a[i]` is spanned at its
  index alone in golden (`{a[i], b[i+1]}` 8:19-20 and 8:25-28), where ours
  spans the whole select; a whole-connection select, a unary or binary
  operand and a part-select keep the whole span (evidence/residue_cases/
  PS_sister_defgen_conn_bitsel ps01, ps09-ps12; ps02-ps08 the module-level
  controls, equal).  This is the strict head of SEVEN STRICT_NOTEQUAL sv-tests
  rows: bsg_link_ddr_upstream, bsg_link_ddr_downstream, bsg_channel_tunnel_out,
  bsg_dmc_phy, bsg_crossbar_control_locking_o_by_i, bsg_idiv_iterative and
  bsg_mesh_router (passes 410 and 412 attributed it to ExprEmit's elaborated
  connection; the decoded site is the definition listing's syntax emitter).
  In the same listing a select index naming a parameter (`a[P]`, `a[E]`)
  folds to a constant in golden (ps01, ps10).
- ModuleEmit's elaborated variable listing: an initializer literal is masked
  to the variable's width (`logic a = 3` -> UINT:1, `logic [1:0] c = 7` ->
  UINT:3, `logic [3:0] h = 17` -> UINT:1) and a based literal takes the
  variable's width as its size (`'hFF` and `8'hA5` at size 4), where we keep
  the value and the literal's size (evidence/residue_cases/VT_sister_varinit
  vt01; sv-tests chapter-10/10.4.1--blocking-assignment.sv).  The constant is
  built and sized in ModuleEmit (`c->VpiSize((int32_t)dt->getType()
  .getBitWidth())` in the elaborated variable branch), not by emitExpr.
- TypeEmit's typedef range bounds reading $unit parameters fold to constants
  in golden (generic/typedef/typedef_test_9.sv, `[k:0]` -> UINT:2), and
  p600's `bit [9:1'b1]` typedef range keeps `1'b1` (TypeEmit).

## Process

- One full sweep on the first law binary, then the narrowing of the two
  package-cast laws after its trace showed a byte-only firing in a package
  subroutine's default argument, then the two affected stages (surelog and
  sv-tests) rerun alone on the final binary: the budget's "a narrowed law
  needs the affected stage rerun alone".
- THE IMPLEMENTER'S SLIP: while looking for the fence line it printed one line
  of tools/probe/r11u107repro/canaudit.sh holding the four fenced names (a
  script line, no fenced source, database or command record opened or run);
  the fence list was then written to /tmp/r11u411_fence.txt without printing
  and every tree-wide list (the 17232-file corpus scan, the 1599 control
  cases, the cmds.txt audits) was filtered on it first.
- One edit to src/ExprEmit.cpp landed while the pristine build was compiling
  other translation units; ExprEmit.cpp had already compiled, and the
  pristine md5 equals the main tree's (42190a8e...).
- A pristine runner call on the 81 non-UVM DIFFERENT rows kept the pairs for
  the head reading (cache-served Surelog side); targeted runner calls on the
  law binaries on those rows and on decoder_dor; bp_unicore alone once.
- No other agent's process touched; no sweep overlapped another (pgrep empty
  before each launch).  The path-normalized dump census of the sv-tests
  databases ran after both sweeps had finished and overlapped the sister
  pass r11u414's live sv-tests stage (dump processes only, 3 jobs); its
  tnoc dump was stopped by PID, the sister's processes left alone.
