# v11u411 — adversarial verification of r11u411 (expression/parameter ground, sixth sv-tests pass)

Verifier pass on base b94cdc04, implementer patch /tmp/r11u411.patch (md5
b479ab0ef22047edc306b63b3523d6f4), verified patch /tmp/r11u411.verified.patch.
Ground src/ExprEmit.cpp, src/EmitHelpers.h, src/StmtEmit.cpp, src/ParamEmit.cpp;
this pass touches src/ExprEmit.cpp only.  Every refinement is `§ <name>411v`
read through `fixOn(411, "R11V411_<X>_OFF")` (src/LawSwitch.h); `R11V411_OFF`
gives the law's bytes on every case dir; `R11U411_OFF` gives pristine's bytes
on every case dir (the refinements sit inside the laws' branches).  No src/R*.h,
no getenv, no reader function, no LawState.h section.

VERDICT: the implementer's headline reproduces bit for bit; ONE BREAK found by
fresh cases on legal SV (a typed constructor inside a PROGRAM minting a wire
golden does not have: VT/vt01, vt10, vt11 moving AWAY from golden, uhdm-cmp
25 -> 654, 32 -> 378, 25 -> 374 lines) and fixed behind its own switch; three
more faces of the laws' own shapes found where the law stops short or writes
a wrong text, written behind their own switches.  None of the four
refinements fires on any corpus row, probe case or sv-tests row (trace), so
every sweep csv and every corpus database of the verified binary equals the
law binary's.

## Binaries (evidence/binaries_md5.txt)

- pristine 42190a8e4437a04efe2664fc6287574c: the main tree's build/slang-uhdm
  frozen (no pristine build, no pristine sweep: the pristine reading is the
  master's control /tmp/intr11u412).
- law 4b88888886ce7960f44f3689389f1dc5: rebuilt once from the implementer's
  patch on a fresh b94cdc04 worktree, EQUAL to the implementer's `final2`.
- verified 91430e8d41d50b5bb4445fae97e61b69: the law plus the four
  refinements below.  (An intermediate verified build a712db31... lacked the
  value half of § enumSubstDecLeadZero411v; it was used only on the case
  grids and never swept: the process note below.)

## sv-tests rows (results/golden_svtests.csv -> law sweep -> verified sweep)

| row | before | law | verified | law |
|---|---|---|---|---|
| chapter-8/8.8--typed_constructor.sv | DIFFERENT | EQUAL | EQUAL | § typedCtorClassArgNet411 |
| chapter-8/8.8--typed_constructor_param.sv | DIFFERENT | EQUAL | EQUAL | § typedCtorClassArgNet411 |
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_router_decoder_dor.sv | DIFFERENT | STRICT_NOTEQUAL differ:fullname(1) | the same | § enumSubstDecDecompile411 |

Both sweeps: `regressions=0 conversions=3 changes=0`; EQUAL 1700,
STRICT_NOTEQUAL 97, DIFFERENT 143, BOTH_REJECT 303, SURELOG_ONLY 75,
SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346.  The law sweep's
svtests.csv is byte-identical to the implementer's (/tmp/r11u411_w2) and to
the verified sweep's.  Fresh rows:

    chapter-8/8.8--typed_constructor.sv,EQUAL,,equal
    chapter-8/8.8--typed_constructor_param.sv,EQUAL,,equal
    generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_router_decoder_dor.sv,STRICT_NOTEQUAL,differ:fullname(1),differ:fullname(1)

The kept sv-tests databases of the law sweep against the control,
path-normalized dumps (drivers/svnorm.sh): 259 of 261 identical, decoder_dor
the one mover (the converted row), generated/tnoc/tnoc.sv skipped (its dump
does not finish in 10 minutes; no law fires on it in the trace).  The two 8.8
rows are EQUAL and keep no database.

## Refinements (src/ExprEmit.cpp; switch; cases)

- § typedCtorNotProgram411v — `R11V411_CTORPROG_OFF`.  THE BREAK.  Inside a
  PROGRAM Surelog mints no implicit wire for the class name of a typed
  constructor: golden lists the argument ref_obj (`work@top.C`) with no
  vpiActual and no net under the program.  The law minted
  `logic_net work@top.C` (vpiNetType 1) under the program and bound it, so
  the program cases moved away from golden (pristine -> law uhdm-cmp 25 ->
  654, 32 -> 378, 25 -> 374 lines; dump distance 22 -> 25 on vt01).  The
  refinement writes the ref_obj unbound there (the rule of
  § assertLocalNetNotProgram407v).  VT/vt01, vt10, vt11 -> STRICT_EQUAL.
- § enumSubstDecLeadZero411v — `R11V411_DECZERO_OFF`.  The substituted
  constant reads the VALUE's digits: a member written with leading zeros
  (`8'd007`, `8'd010`) is `7` and `10` in golden, decompile and value
  (`INT:7`), where the law wrote the decompile `007` and kept the value
  `INT:007` (strict field value).  VF/vf05, vf07 NOT_EQUAL -> STRICT_EQUAL.
- § gateGenvarModFold411v — `R11V411_GATEMOD_OFF`.  A MODULO over the genvar
  in a gate, udp or switch terminal (`a[i%2]`, `y[(i+1)%4]`, `a[i%3+1]`,
  `a[2*i%5]`) folds as the division does: golden INT at the top operation's
  left operand; the law left the operation.  VD/vd01, vd07 NOT_EQUAL ->
  STRICT_EQUAL; vd09 NOT_EQUAL -> STRICT_NOTEQUAL col (the residue below).
- § gateGenvarParenWsSpan411v — `R11V411_PARENWS_OFF`.  With whitespace
  inside the parentheses of the folded left operand (`y[( i+1)*2]`,
  `a[(i+1 )+1]`, `y[(  i )+1]`, `a[( (i+1))*2]`) golden still spans the whole
  parenthesized operand, whitespace included (5:15-5:21 over `( i+1)`); the
  law abstained and kept the inner span.  VD/vd04, vd08 STRICT_NOTEQUAL col
  -> STRICT_EQUAL.  Macro locations abstain.

Each refinement's own switch gives the law's bytes on the cases it moves
(10 of 10); `R11V411_OFF` the law's bytes on 47 of 47 attack case dirs and 39
of 39 of the implementer's; `R11U411_OFF` pristine's bytes on 47 of 47 and 39
of 39 (evidence/grid_attack_switches.txt, grid_impl_switches_verified.txt).

## The implementer's grid reproduced (evidence/grid_impl_reproduced.txt)

39 of 39 case dirs: the same exit code, uhdm-cmp line count and strict
verdict on pristine and on the law binary as evidence/grid_final.txt of
r11u411repro (only the dump-distance count of GC/gc06, identical on both
binaries, differs by the case path); R11U411_OFF pristine's bytes on 39 of
39, each case's own switch on 37 with EC/ec08 and TC/tc06 needing the second
switch as the implementer says.  The verified binary writes the law's bytes on
all 39.

## Attack grid (cases/, 47 case dirs in VD, VE, VF, VG, VM, VT;
evidence/grid_attack_PLV.txt; drivers/case.sh, drivers/vgrid.sh)

Each line carries the exit code, uhdm-cmp lines, dump distance, md5 and the
strict verdict for pristine (P), law (L) and verified (V).  Pristine -> verified:

- 17 NOT_EQUAL -> STRICT_EQUAL, 8 exit 4 NOT_EQUAL -> exit 0 STRICT_EQUAL,
  3 STRICT_NOTEQUAL -> STRICT_EQUAL, 1 NOT_EQUAL -> STRICT_NOTEQUAL (vd09),
  4 exit 4 -> exit 0 still NOT_EQUAL, 9 NOT_EQUAL on both, 1 exit 4 on both
  (VM/vm04), 4 STRICT_EQUAL controls byte-identical.
- No case leaves an equal status, no exit code worsens.  Away census on the
  13 still-unequal cases: all closer or at pristine's bytes except VE/ve04
  (dump 156 -> 182, cmp 76 -> 122), whose pristine side is the partial
  database of an exit-4 export (the alias-twin residue of EC/ec06, ec08,
  ec10).
- By face (cases, first line the law):
  - genvar cast (§ genvarCastTgtUnsupTs411): VG/vg01 (`genvar i;` declared
    outside the loop), vg02 (nested loops, inner and outer genvar), vg03 (in an
    if-generate inside the loop, `((i))'(x)`) exit 4 -> STRICT_EQUAL; vg04 (an
    interface) exit 4 -> exit 0 NOT_EQUAL on the interface generate listing
    (golden a named_begin `work@ifc.g`, ours a begin: not this law); vg05
    (generate localparam and module localparam sizes) and vg06 (`(i+1)'(x)`)
    controls byte-identical.
  - package enum and alias casts (§ pkgEnumCastTargetTs411,
    § pkgAliasCastTargetTs411): VE/ve02 (`int'(e_t'(1)) + 1`) exit 4 ->
    STRICT_EQUAL; ve01 (based enum, localparam) exit 4 -> exit 0 NOT_EQUAL
    (the enum-cast value residue); ve04 (logic alias, two parameters) exit 4
    -> exit 0 NOT_EQUAL (the alias twin); ve03 (a package function's
    localparam), ve05 (a class parameter in a package), ve06 (an alias of a
    struct, the struct path), ve07 (a cast to another package's alias), ve08
    (no cast, control) byte-identical; ve03 DIVERGENT downstream on all three
    binaries (pristine too).
  - enum substitution decompile (§ enumSubstDecDecompile411): VF/vf02 (int
    enum with 32'b, 32'h and 'd members) NOT_EQUAL -> STRICT_EQUAL; vf01
    control byte-identical; vf03 (`-4'sd3`, a BIN value: not fired), vf04
    (case items and a parameter default), vf06 (generate scope) closer and
    still NOT_EQUAL on other fields; vf05, vf07 the refinement above.
  - typed constructor (§ typedCtorClassArgNet411): VT/vt02 (in a module task),
    vt03 ($unit class method), vt04 (module function), vt07 (generate block),
    vt08 (a class declared in the module), vt09 (`C#(.T(byte))::new(1)`,
    `C#(int)::new(2)`) NOT_EQUAL -> STRICT_EQUAL; vt05 (`pk::C::new`, the
    law abstains on a scoped class name) byte-identical; vt06 (an interface)
    29 -> 17 cmp lines, golden mints the wire `work@top.u.C` under the
    interface instance where we mint none (residue); vt01, vt10, vt11 the
    program break above.
  - call result member (§ callResultMemberDropped411): VM/vm01 (module
    function returning a struct, cont-assign), vm02 (package function,
    always_comb), vm03 ($unit function returning a class), vm05 ($unit
    function, two reads) exit 4 -> STRICT_EQUAL; vm06 (`u.mk(x).a` through an
    interface instance) exit 4 -> exit 0 NOT_EQUAL (golden a hier_path
    holding a method_func_call spanning 10:14-10:23, ours 10:14-10:21 with no
    actual); vm04 (`C::mk().s`, a static class method: the law excludes
    class subroutines) exit 4 on all three binaries: a goal-1 face left.
  - gate genvar division and shift (§ gateGenvarDivShiftFold411,
    § gateGenvarParenLeftSpan411): VD/vd02 (`(i<<1)-1`, `i/2+1`,
    `(i-4)/2+4`), vd03 (`(i+1)*2`, `((i+1))+1`, `(i)+2`: pass 409's operators
    under the paren span), vd05 (`i<<1<<1`, `i*4>>1`, `16/(i+1)-1`), vd06 (a
    udp and a tranif1) -> STRICT_EQUAL; vd01, vd04, vd07, vd08, vd09 the
    refinements above.
- Downstream (drivers/ds.py, evidence/downstream_attack.txt) on the 32
  class-free cases: 31 IDENTICAL on pristine, law and verified, VE/ve03
  DIVERGENT on all three; no verdict moves.

## Gates (evidence/sweep_*.txt; drivers/sweep.sh: the four corpus stages
through the worktree's tests/sweep.sh --jobs 3, the sv-tests stage through
the main tree's scripts/check_svtests.py read-only with the worktree's
baseline, a worktree having no UVM tree)

One five-stage sweep on the law binary (/tmp/v11u411_wL) and one on the
verified binary (/tmp/v11u411_wV), the machine quiet before each
(no sweep, runner or check process live):

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0
  conversions=0 changes=0 on both; the 4087 law databases against the
  control by path-normalized dump 4087 of 4087 identical (a positive control:
  v99_enum against v99_enum2 reads 4067 changed lines); the verified
  databases byte-identical to the law's on 4087 of 4087.
- surelog: default CMP_EQUAL 480, testflags 474, regressions=0
  conversions=0 changes=0 on both; the csv equal to the control's but for the
  two LowMem log-path detail texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0 on both.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 on
  both; not identical and not excused 0.
- sv-tests: 0 / 3 / 0 on both, as above.
- byteverify (evidence/byteverify.txt), each sweep against the control: 0
  of 962 surelog, 0 of 1608 uhdm2rtlil, 0 of 805 downstream (SELFCHECK 961,
  1607 and 804 flagged); verified against law 0 everywhere.  So the
  implementer's first-sweep surelog movers (the 9 UVM databases from
  `uvm_severity'(UVM_ERROR)`) are gone on the narrowed law, as it says.
- trace census (evidence/trace_census.txt): on both sweeps the laws fire on
  5 databases only, the probe cases r10vearl99repro v99_enum and v99_enum2
  (§ enumSubstDecDecompile411 on `6'd1`, `6'd3`, bytes identical to the
  control) and the three converted sv-tests rows; NO refinement fires on any
  sweep database.  Positive control: the four attack cases VT/vt01, VD/vd01,
  vd04, VF/vf07 run under R11U411_TRACE log every refinement and law.
- canaries ok=52 changed=0 (surelog csv) and ok=16 changed=0 (uhdm2rtlil csv)
  on both sweeps; EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 ctcan2 PASS on both.
- binary audit (evidence/audit.txt, fence-filtered first): surelog 1523 of
  1573 cmds.txt name the binary under test, 0 another, 50 hold no slang line
  (2 of them name the repository path in a Surelog line only); uhdm2rtlil
  1740 of 1740; sv-tests 2346 of 2346; the same on both sweeps.

## Byte controls on earlier grids (drivers/ctl.sh,
evidence/control_cases_law_vs_verified.txt)

Every dut.sv under tools/probe/r11u40*repro, v11u40*repro, r11u41[012]repro
and v11u41[02]repro, fence-filtered (1655 case dirs): the verified binary's
exit code and bytes equal the law binary's on 1655 of 1655, so no refinement
reaches an earlier pass's case (pass 409's GV gate cases and pass 407's
program cases among them).  The implementer's own pristine-vs-law census on
the same trees (1599, 4 targeted movers) is not repeated.

## Goal 1 checked

- VN/vn03 and VP/vp05 exit 0 on the law and verified binaries (the
  implementer's control-case table; the law's own GC and EC cases above).
- black-parrot, rsd and the 75 SURELOG_ONLY details: not re-measured beyond
  the sweep (every SURELOG_ONLY row stays, no row leaves an accepting
  status).
- A goal-1 face left on this ground: a member of a STATIC CLASS METHOD's
  result, `C::mk().s` (VM/vm04), exits 4 `member access base` on every
  binary; the law excludes class subroutines.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The implementer's residues stand: the enum-cast value (UINT:0 at size 0
   in golden; VE/ve01), the package alias twin (VE/ve04 with EC/ec06, ec08,
   ec10), decoder_dor's generate-localparam select index full name, GC/gc04
   and gc05.
2. `C::mk().s` (VM/vm04, goal 1, exit 4) and `u.mk(x).a` through an
   interface instance (VM/vm06, the hier_path's method_func_call actual and
   span).
3. The typed constructor in an INTERFACE (VT/vt06: golden mints
   `logic_net work@top.u.C` under the interface instance; the implicit-net
   module is not set in interfaces, the same face as pass 407's VL/vl02) and
   a scoped class name `pk::C::new` (VT/vt05, the law abstains).
4. A gate terminal whose whole index is parenthesized (`a[(i % 3)]`, VD/vd09):
   golden spans the bit_select from the opening parenthesis to the closing
   bracket (5:23-5:30), ours 5:24-5:29 (the select's span, not the fold's).
5. `-4'sd3` enum members (VF/vf03: golden INT:-3 and decompile -3 where we
   keep BIN:1101 and `-4'sd3`), the case-item parent and the parameter
   default typespec in VF/vf04, the generate-scope net typespec in VF/vf06.
6. The interface generate listing of VG/vg04 (golden a named_begin
   `work@ifc.g` holding the cont_assign; ModuleEmit's ground).

## Sister-ground faces (reported, not written)

- ModuleEmit: the interface generate-for listing of a cont_assign (VG/vg04:
  golden `named_begin work@ifc.g`, ours `begin work@ifc`).
- The implementer's three (TypeEmit's definition-view bit_select in a
  ref_module port concatenation, ModuleEmit's elaborated variable
  initializer width, TypeEmit's typedef range bounds) were not re-decoded.

## Process

- Builds: the law binary once (equal to the implementer's), then the
  verified binary; ONE MORE INCREMENTAL BUILD than the budget's two: the
  first verified build (a712db31...) wrote the leading-zero decompile but
  kept the value `INT:007`, which the strict comparator read on VF/vf05 and
  vf07, so the value half was added and the binary rebuilt before any sweep.
  Sweeps: two (law, verified), both on a quiet machine.
- The fence list was read into a file without printing it
  (/tmp/v11u411_fence.txt, equal to the implementer's) and every tree-wide
  list was filtered on it first; no fenced test named, opened or run.
- The sister pass r11u414's processes (its tnoc dumps) were seen live and left
  alone; nothing of mine overlapped a sweep of another pass.
- Nothing written outside /tmp/wt_v11u411, /tmp/wt_v11u411pris (unused,
  never built) and /tmp/v11u411_*.
