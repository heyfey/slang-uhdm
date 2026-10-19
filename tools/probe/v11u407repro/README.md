# v11u407 — adversarial verification of r11u407

Verifier of r11u407 (the sv-tests campaign's fourth pass on the
expression/parameter ground) on base 83aee5dc.  Worktree /tmp/wt_v11u407 with
/tmp/r11u407.patch applied (clean apply), scratch /tmp/v11u407_*.

VERDICT: the implementer's numbers reproduce bit for bit, but the attack grid
found ONE BREAK on legal SV where pristine was right (a module PARAMETER of the
local variable's name: VL/vl09, vl13, vl17 STRICT_EQUAL on pristine,
NOT_EQUAL under the law) and three moves away from golden on cells already
wrong on pristine (a program's local variable, an `@seq` inside a generate
block, a select of a package parameter).  Four refinements fix them, each
behind its own switch read through src/LawSwitch.h (fixOn(407, ...)), and
`R11V407_OFF` gives the law's bytes on all 98 case dirs.  The verified patch is
/tmp/r11u407.verified.patch.  The implementer's 36 cases give the same bytes
on the law and the verified binary.

## Binaries (frozen before any measurement)

| binary | md5 | path |
|---|---|---|
| pristine (the main tree's build at the base) | 8d0c5ea76c7f7aa73467f92a108b3527 | /tmp/v11u407_bin/pristine |
| law, rebuilt here from the patch | df7fcedb34229ff10ae18b610a33a2c3 (equal to the implementer's) | /tmp/v11u407_bin/law.bin |
| verified (final) | 6708455a6be99f4208485b259a1695b2 | /tmp/v11u407_bin/ver.bin |

An intermediate verified build (872ad2fe659caf66f5fad55cbd619bcc,
/tmp/v11u407_bin/ver1.bin) also counted a bare `generate`/`endgenerate` region
as a generate block; VE/ve11 showed golden binds there, so the final build
leaves it out.  ver1 was measured on the grid and downstream only.  The
binaries link slang 12.0.0+545f88b2e.  Per the measurement budget, the pristine
reading is the master's control /tmp/intr11u405: no pristine binary was built
and no pristine sweep was run.

## Reproduction of the implementer's claims (law binary)

One four-stage corpus sweep (`tests/sweep.sh --jobs 3 --workdir
/tmp/v11u407_lawd`, law index current at launch) plus the sv-tests stage.  The
worktree has no sv-tests sibling or UVM tree, so the sv-tests stage ran through
the main tree's scripts/check_svtests.py (read-only) with
`--baseline <worktree>/results/golden_svtests.csv`, the base's baseline.

* probe: EQUAL 4018 + STRICT_NOTEQUAL 69, regressions=0 conversions=0 changes=0; the csv is identical to the control's.
* surelog: default 480 CMP_EQUAL, testflags 474, 0/0/0.  The csv differs
  from the control only on the LowMemLib and LowMemPkg testflags log-path
  detail (environment).  Tnoc d/t stay CMP_NOTEQUAL with the same detail.
* uhdm2rtlil: 803/1/67 in both modes, 0/0/0, csv identical.
* downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not identical and not excused 0, csv identical.
* sv-tests: EQUAL 1615, STRICT_NOTEQUAL 13, DIFFERENT 312, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346,
  regressions=0, conversions=3, changes=0.  The three conversions are
  chapter-16/16.10--sequence-local-var.sv, its -fail twin and
  chapter-9/9.4.2.4--event_sequence.sv, each DIFFERENT -> EQUAL.  The csv
  is identical to the implementer's /tmp/r11u407_wd/svtests.csv on all 2346
  rows.
* byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law workdir vs /tmp/intr11u405):
  * surelog 2 of 962 (Tnoc default and testflags);
  * uhdm2rtlil 0 of 1608;
  * downstream 0 of 805;
  * the self-checks flag 961/962, 1607/1608 and 804/805.
* trace census (R11U407_TRACE): the corpus stages fire only on Tnoc default and
  testflags (pkgRetBitSelParamFold407 x6, pkgRetEnumOperandFold407 x3 each).
  The sv-tests stage fires on 9 rows (the implementer wrote 10; the row list is
  the same):
  * seqEventCtrlRefDecl407: 9.4.2.4.
  * assertLocalVarImplicitNet407:
    * 16.10 sequence-local-var and its -fail twin;
    * property-local-var and its -fail twin;
    * the -uvm rows of property-local-var and sequence-local-var;
    * 16.11 sequence-subroutine-uvm.
  * pkgRetBitSelParamFold407 x6 and pkgRetEnumOperandFold407 x3: tnoc.
* canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); ctcan2 PASS on both csvs (EXPECT_UNKNOWN=1 / 6).
* binary audit: 3323 cmds.txt, 3315 after the fence filter; 3265 name
  /tmp/v11u407_bin/law.bin, 50 hold no slang line, 0 name another binary.
* black-parrot: bp_unicore alone (runner + its own slang command, guard on).
  The verified binary exits 3 in 18.2 s at 820 MB max RSS with pristine's
  substr message.  This agrees with the implementer's 17.4 s / 822 MB.  The
  guard stays.
* implementer's grid: its 36 case dirs re-run under drivers/grid.sh on the
  three binaries (evidence/grid_r11u407_cases.txt).  The implementer's grid
  reproduces line for line: 20 NOT_EQUAL -> STRICT_EQUAL, 6 STRICT_EQUAL
  controls, 10 NOT_EQUAL on both, every exit 0.  Each group's switch and
  R11U407_OFF restore pristine on 36 of 36.  The verified binary's bytes equal
  the law's on 36 of 36.

## The break and the refinements

| refinement | switch | site | cases | what golden writes |
|---|---|---|---|---|
| § assertLocalNetParamNameKeep407v | R11V407_LVPARAM_OFF | ExprEmit, the guard of § assertLocalVarImplicitNet407 | VL/vl09, vl13, vl17 | THE BREAK.  When the module declares a PARAMETER (`parameter int x`, `localparam logic [7:0] x`, `localparam x`) of the local variable's name, golden leaves the ref_obj (`work@top.seq.x`) unbound and mints no wire.  Pristine wrote exactly that (STRICT_EQUAL); the law minted `logic_net work@top.x` beside the parameter (NOT_EQUAL).  The law now abstains.  A module net or variable of the name (vl01 logic, vl03 int, vl08 reg, vl12 real, vl14 struct, vl15 event, vl16 typedef'd int) is the net golden binds, as the law does |
| § assertLocalNetNotProgram407v | R11V407_LVPROG_OFF | ExprEmit, same guard | VL/vl06 (sequence), vl10 (property) | inside a PROGRAM golden lists the ref_obj unbound and mints no net; the law minted `logic_net work@prg.x`.  The law abstains there (pristine's bytes) |
| § seqEvGenRefUnbound407v | R11V407_SEQEVGEN_OFF | StmtEmit emitEventExpr, inside § seqEventCtrlRefDecl407 | VE/ve02, ve09, ve12 (-> STRICT_EQUAL), ve03, ve10 (toward); ve11 the control | an `@seq` written inside a generate BLOCK (if, case or loop generate; found by the syntax parent chain) is a ref_obj with NO vpiActual, both in the definition view and in the elaborated gen scope.  The law bound the definition view's ref to the module's sequence_decl, and in the gen scope wrote no condition.  A bare generate/endgenerate region is not a scope: golden binds there as at module level (ve11, verified == law) |
| § pkgRetBsParamTargetKeep407v | R11V407_BSTARGET_OFF | StmtEmit Return, `bsFold407` | VB/vb04 | a select OF a package parameter (`MASK[RB]`) is reduced by golden as a whole to one constant (`1'b1`).  The law rewrote only its index and listed an int_typespec copy golden does not hold (dump distance 39 -> 41).  The select keeps its index ref_obj (distance 28; `x[RB]` in the same return still folds) |

Each refinement's movers are restored to the law's bytes by its own switch
(drivers/fixoff.sh), and R11V407_OFF gives the law's bytes and exit code on 98
of 98 case dirs (36 implementer + 62 verifier).  The refinements fire on no
corpus row, probe case or sv-tests row (verified sweep below).

## Attack grid (tools/probe/v11u407repro/cases, drivers/grid.sh, evidence/grid.txt)

62 fresh case dirs in VB, VE, VF, VL, VT, VX.  Every case exits 0 on all three
binaries, and every case's first line names its law.  Each case's own law
switch, and R11U407_OFF, restore pristine's bytes and exit code on 62 of 62.
The verdicts below are pristine -> law -> verified; `dist` is the normalised
dump distance to golden.

| group | law | cases |
|---|---|---|
| VL | § assertLocalVarImplicitNet407 | vl01, vl03, vl05, vl07, vl08, vl11, vl12, vl14, vl15, vl16 NOT_EQUAL -> STRICT_EQUAL (module wire of the same name declared after the sequence, int/reg/real/struct/event/typedef variables of the name, a sequence with a formal plus a second sequence, a local reused twice, an always-embedded assert, two modules each with a local x); vl09, vl13, vl17 STRICT_EQUAL -> NOT_EQUAL -> STRICT_EQUAL (THE BREAK, fixed); vl06, vl10 (program) 157 -> 166 -> 157 and 185 -> 194 -> 185 (away, fixed to pristine's bytes); vl02 (interface) and vl04 (generate block) unchanged: the law does not reach them, golden mints the net in the interface instance |
| VE | § seqEventCtrlRefDecl407 | ve04 (`@(seq or posedge clk)`), ve05 (sequence declared after the use), ve07 (`always @s1`, `always @(s2)`) -> STRICT_EQUAL on law and verified; ve02, ve09, ve12 -> STRICT_EQUAL on verified only (law bound a def-view ref golden leaves unbound); ve03, ve10 toward (58 -> 58 -> 46, 66 -> 54 -> 46: the gen-scope sequence listing is the sister's); ve11 toward on both (49 -> 41); ve08 (intra-assignment `y = @seq 1`) STRICT_EQUAL control unchanged; ve01 (a formal with a default: the law abstains) and ve06 (interface) unchanged |
| VF | § pkgRetEnumOperandFold407 | vf01 (inside), vf02 (concat), vf03 (negative INT enum), vf04 (enum of an imported package), vf06 (ternary), vf08 (x digit in an enum value), vf09 (class method + package function), vf11 (return in a begin block, return after a statement), vf12 (70-bit enum, unqualified call) -> STRICT_EQUAL; vf05 (an enum as a call argument), vf07 (a cast and a fully constant operand), vf10 (unary minus) toward: golden reduces whole constant subexpressions (Reduce::Yes), the law only the enum leaves |
| VB | § pkgRetBitSelParamFold407 | vb03 (computed init `3 + 2`), vb07 (signed logic and shortint parameters), vb09 (`parameter`, and a localparam computed from it) -> STRICT_EQUAL; vb05 (an imported package's parameter beside the own one), vb06 (a function argument shadowing the parameter, a local variable's select), vb08 (an unpacked-array argument) toward; vb04 away on the law (39 -> 41) and toward on verified (28); vb01 (untyped `3'd5`) and vb02 (`bit [7:0]` with a hex literal) unchanged: the law abstains on non-UINT/INT/DEC constants (residue) |
| VX | § typedParamXzLitSize407 | vx02 (`bit [3:0] = 2'bx1`, `integer = 4'bxxxx` fixed; `logic [3:0] = 8'hxz` a HEX literal, abstained: golden 8, ours 4), vx03 (interface), vx04 (localparam, generate-block localparam), vx06 (`logic [7:0] = 4'hx`, `int = 1'sbx`) toward; vx01 (overrides `2'b10`, `3'b1x1`: the law does not fire, golden 3 where we write 32), vx05 (defparam), vx07 (package and class parameters) unchanged |
| VT | § tpCastOverrideKeepsDefault407 | vt01 (default naming another parameter, both overridden), vt02 (override equal in text to the default), vt03 (shortint/byte overrides into an int value parameter), vt04 (a struct override), vt05 (an interface) all move the cast typespec to golden's header default.  They stay NOT_EQUAL on parameter D's own typespec (the implementer's TD residue).  vt01 and vt04 grow in dump distance (100 -> 108, 208 -> 227) only in the unreferenced typespec tail; their cast cell moves to golden's span and shape, and vt01 goes EQUIVALENT -> IDENTICAL downstream |

Downstream (scripts/downstream_uhdm2rtlil.py `one`, fresh GOLDEN_CACHE) on all
98 case dirs (they are class-free):
* pristine -> law: 16 improve (14 EQUIVALENT -> IDENTICAL, VF/vf10
  STATUS_DIFF -> IDENTICAL, VX/vx02 DIVERGENT -> EQUIVALENT), none worse;
* law -> verified: the same verdict on all 97 shared cases; VE/ve12 is
  IDENTICAL on all three binaries.

## Verified binary: the full gate (one five-stage sweep, workdir /tmp/v11u407_verd)

The sweep ran on a quiet machine after the master's pass 408 integration
sweep ended; the law index was current at launch.  The sv-tests stage ran as
on the law binary.  It reads:

* probe: EQUAL 4018 + STRICT_NOTEQUAL 69, regressions=0 conversions=0 changes=0.
* surelog: 480 + 0 / 474 + 0, 0/0/0.
* uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
* downstream: 803/66/2/0, not identical and not excused 0.
* sv-tests: EQUAL 1615, STRICT_NOTEQUAL 13, DIFFERENT 312, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346,
  regressions=0, conversions=3 (the same three rows), changes=0.

PREDICTED BY NAME before the sweep: no refinement can fire on a corpus row.
The law trace shows assertLocalVarImplicitNet407 and seqEventCtrlRefDecl407
firing on no corpus row, and Tnoc's six bit-select folds index function
arguments, not parameters.  On the sv-tests rows, none of the 9 firing rows
holds a program, a generate-block `@seq` or a module parameter named like a
local variable.

The prediction holds:
* byteverify verified vs law: 0 of 962, 0 of 1608, 0 of 805 (self-checks
  961, 1607, 804);
* the probe, surelog, uhdm2rtlil and downstream csvs are identical to the law
  sweep's;
* the sv-tests csv is identical on all 2346 rows;
* the trace shows the same laws on the same rows and no refinement firing.

Checks on the verified sweep:
* canaries: ok=52, ok=16; ctcan2 PASS on both csvs;
* binary audit: 3315 fence-filtered cmds.txt, of which 3265 name
  /tmp/v11u407_bin/ver.bin, 0 another binary and 50 hold no slang line.

## Law-index fix

The implementer's 12 EF case dirs named `§ pkgFnEnumRefFold407` on their first
line, a law that does not exist, so tests/LAWS.md attributed them to nothing.
The first lines now read `§ pkgRetEnumOperandFold407`, and the index is
regenerated.

## Residues (ranked; all wrong on pristine too, none moved away on the verified binary)

1. Return-window folds, partial: golden reduces whole constant subexpressions
   in a package function's direct return (Reduce::Yes): `g(A)` call results
   (vf05), cast-of-constant comparisons (vf07), `-B` (vf10) and `MASK[RB]`
   (vb04).  The laws fold only enum leaves and parameter indexes.  Constants
   that are not UINT, INT or DEC (vb01 `3'd5` untyped, vb02 hex) are not
   folded.
2. The local-variable wire in interfaces (vl02: golden mints it in the
   interface instance) and in generate blocks (vl04).  The law does not reach
   these, because the sequence listing there is the sister's.
3. `@seq` with the sequence declared inside a generate block (ve03, ve10:
   golden binds the elaborated gen scope's ref to a gen-scope sequence_decl we
   do not list; sister's listing).  Also `@seq` inside an interface (ve06) and
   with a defaulted formal (ve01).
4. x/z typed parameters: a HEX/OCT literal (vx02 pl), an overriding literal
   (vx01: golden keeps the override's width), the residues xz02 and xz04 of the
   implementer.
5. tpCastOverrideKeepsDefault407: parameter D's own typespec in the overriding
   instance (all VT and TD cases).
6. The implementer's residue list (tnoc 333:14, 16.10 property listing,
   SE/se04, se06, EF/ef11, BS/bs04, class_test_51) and the not-reached lists
   of passes 405, 403 and 401 stand.

## Sister-ground faces (reported, not written)

* ModuleEmit: the sequence listing in generate blocks and interfaces.  These
  are VE/ve03, ve06, ve10 and VL/vl02, vl04.
* ModuleEmit: a bare generate region's gen_region listing of an initial block
  (VE/ve11: golden lists a gen_region holding the initial with an unbound ref).
* ModuleEmit: a program's sequence listed under the definition where golden
  lists it under the program instance only (VL/vl06, vl10).
* Unchanged from the implementer's list: the property_decl variable listing,
  task bodies emitted before the sequence listing, the variable-initializer
  chain, `bit signed`, macro-declared struct `$bits`, parenthesized cast names
  in generate blocks, the class listings and the $unit parameters.

## Process

* No other agent's process was touched, and no fenced test was named, opened
  or run.  The cmds audit built its path list first and filtered it on the
  canaudit FENCED line before opening a file.
* The master's pass 408 integration sweep (/tmp/intr11u408) was running when
  the verified sweep was ready.  The verified sweep waited for it by PID.
* An early waiter used a pgrep pattern; it ended at once and was replaced by a
  wait on the master's PID.
* The first verified build failed to compile (a syntax ParentRef deduced
  through `auto*`) and produced no binary.
* The verified binary was built while the law sweep's corpus stages ran
  (nice, -j 2).  No TIMEOUT or load-related change appeared in that sweep.
* VL/vl03's first draft (`int x = 0;` as a sequence local) is rejected by
  Surelog's parser.  It was replaced by a module `int x` variable before
  counting.
