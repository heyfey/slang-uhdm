# v11u491 — adversarial verification of r11u491 (expression/parameter ground, pass 491)

Base 8b8f04bc (pass 489). Implementer's patch /tmp/r11u491.patch (src/ParamEmit.cpp, tests/LAWS.md,
tools/probe/r11u491repro). Verified patch /tmp/r11u491.verified.patch = the implementer's patch +
one refinement in src/ParamEmit.cpp (§ ovRefUnszBasedFormCopy491v) + this folder + tests/LAWS.md
regenerated. No other src file, no include/, no header, no src/R*.h, no getenv: the refinement is
read through fixOn(491, "R11V491_REFFORM_OFF") from src/LawSwitch.h, R11V491_OFF drops it.

## Verdict

ONE BREAK, FIXED. § ovUnsizedBasedActualForm491 moved legal SV that upstream slang accepts away from
golden: when the overridden parameter is passed on as a bare-name actual to a child instance
(`s #(.X(A))` or `s #(A)` inside `m #(.A('h5))`), the child's elaborated X constant left the INT
re-pass branch (§ elabOvRefIntConst, which kept it shared with a continuous assignment reading X)
for the bare-reference UINT branch: UINT:5 at size 32, parented at the param_assign, plus a second
constant and int_typespec for the continuous assignment. Golden copies A's own Value: HEX:5 'h5
(BIN:101 'b101, HEX:Ab 'hAb), shared at the reader's width.
- VC/vc02, VP/vp01, VP/vp07, VP/vp08: dump distance 14 -> 26 and downstream IDENTICAL -> EQUIVALENT
  (evidence/break_vc02_law_nohier.diff: golden `parameter \X 8'00000101`, law `parameter \X 5`);
  VP/vp09 (typed child X) distance 14 -> 44; VP/vp06 12 -> 26 with uhdm-cmp 36 -> 64.
- The fix (below) puts them at: vc02, vp06, vp07, vp08, vp09 STRICT_EQUAL and downstream
  IDENTICAL; vp01 at distance 2 (the BIN decompile face below), downstream IDENTICAL.

The implementer's other numbers reproduce bit for bit: law binary md5 893ef1acb254b59c6de222ae0bb14cb8
(rebuilt from the patch, equal to its law10), the 197-dir grid field for field on both binaries
(pristine STRICT_EQUAL 34 / NOT_EQUAL 163, law 170 / 27, every exit code 0, no uhdm-cmp count or dump
distance growing), its downstream grid (pristine IDENTICAL 125 / EQUIVALENT 72, law 181 / 16), its
switch claim (R11U491_OFF = pristine bytes on all 197), its sweep (0 regressions in all five stages,
every csv equal to the control) and its trace (only abstainDefault on ParameterWithUnderscoreValue
and ParameterWithUnderscoreValueDivided). No sv-tests row, corpus row or probe case moves on either
binary.

## Binaries (frozen in /tmp/v11u491_bin)

- pristine: frozen copy of the base build, md5 91613eefa1398fab14ca1024d1a9f64a (no pristine build,
  no pristine sweep; the pristine sweep reading is the master's control /tmp/intr11u489)
- law: rebuilt once from /tmp/r11u491.patch, md5 893ef1acb254b59c6de222ae0bb14cb8 (= implementer's
  law10), slang 12.0.0+545f88b2e
- verified: md5 19244d6a8718ba582e17e7c1f00d280d, slang 12.0.0+545f88b2e (the one verified build)

## The refinement

§ ovRefUnszBasedFormCopy491v (R11V491_REFFORM_OFF; cases VP, VC/vc02). Decoded on 45 Surelog
databases (child X default x parent A declaration x actual 'h5 / 'b101 / 'hAb, in
/tmp/v11u491_dec, summarised here): golden's child X is A's Value copied as is (HEX:5 'h5,
BIN:101 'b101, HEX:Ab 'hAb, whatever A's declaration: untyped, sized default or logic [7:0]), sized
by X's own declaration: int X 32, logic [7:0] X 8, untyped X = 1 (unsized decimal) 32, untyped
X = 4'd1 -1; a continuous assignment reading X whole shares it at the left side's width (8).
The fix: in the child's emitParameters, an overridden param_assign whose written actual is a bare
name (through parentheses, named or ordered) resolving in the instantiating scope to a parameter
whose elaborated constant § ovUnsizedBasedActualForm491 wrote as HEX or BIN (a side set filled by
the law) copies value, decompile and const type, with that size; the copy joins the set so a
further re-pass follows (VP/vp26 grandchild STRICT_EQUAL). Abstains: a defparam on X, any other
actual shape, a source the law did not write ('o5 and 'd5 already reach the existing UINT and INT
branches: VP/vp02, vp03 STRICT_EQUAL on the law binary), an untyped X with any other default (VP/vp27,
X = 'h1, bytes unchanged). The set is empty unless the law fired, so the refinement cannot fire
where the law does not.

## Attack grid (cases/, 269 dirs in VT, VA, VO, VN, VB, VS, VC, VP; every first line names its law)

Every case accepted by upstream slang (~/.local/bin/slang --single-unit, real exit code, a
negative control reading 1); every exit code 0 on all three binaries.

| group | law attacked | dirs | pristine SE | law SE | verified SE |
|---|---|---|---|---|---|
| VT | bitNegTypedOperandSize491 | 56 | 8 | 51 | 51 |
| VA | ovUnsizedBasedActualForm491 | 41 | 0 | 24 | 24 |
| VO | ovSizedActualMoreBases491 | 31 | 4 | 23 | 23 |
| VN | bitNegBareNameActual491 | 27 | 1 | 21 | 21 |
| VB | unboundedDepBesideDefparam491 | 21 | 5 | 14 | 14 |
| VS | unboundedSubSize64_491 | 22 | 2 | 16 | 16 |
| VC | contexts (shared readers, re-pass, two instances, generate, interface, enum, typedef) | 34 | 0 | 17 | 18 |
| VP | re-pass of a re-valued parameter to a child | 37 | 0 | 14 | 26 |
| all | | 269 | 20 | 180 | 193 |

(SE = STRICT_EQUAL; the rest NOT_EQUAL, no STRICT_NOTEQUAL.) Downstream (drivers/ds.py, the
harness's one()): pristine IDENTICAL 129 / EQUIVALENT 139 / DIVERGENT 1, law 227 / 42 / 0 with FOUR
dirs leaving IDENTICAL (vc02, vp01, vp07, vp08: the break), verified 233 / 36 / 0 with none leaving
IDENTICAL (pristine -> verified: 103 EQUIVALENT -> IDENTICAL, 1 DIVERGENT -> IDENTICAL).
Pristine -> verified on the strict axis: no STRICT_EQUAL lost, no dump distance growing; three
uhdm-cmp counts grow with the head moved later (VP/vp20 36 -> 64, vp21 36 -> 64, VS/vs20 36 -> 58,
dump distance 16 -> 10, 34 -> 8, 18 -> 16: the first difference moves from the re-valued B in the
parent to the child's copy of B, or to the interface fold).

## Switch tables (evidence/switch_*.txt; 466 dirs = the implementer's 197 + these 269)

- verified with R11U491_OFF = pristine bytes and exit code on 466 of 466 (the refinement needs the
  law's set, so the pass switch drops it too); law with R11U491_OFF the same, 466 of 466
- verified with R11V491_OFF, or with R11V491_REFFORM_OFF alone = law bytes on 466 of 466
- law, each of the seven switches alone: every one of the 369 pristine -> law movers is touched by at
  least one switch (BITNEGTYPED 134, OVUNSZFORM 103, OVSIZEDMORE 54, BITNEGBARENAME 38, SUBSIZE64 32,
  DEPBESIDEDP 28, BITNEGUNSZACT 18 dirs), none unattributed; one dir touched without being a mover:
  r11u491 SS/ss06 (R11U491_SUBSIZE64_OFF alone moves its bytes because § unboundedDepBesideDefparam491
  then writes B, the two laws together giving pristine's bytes: an interaction the implementer's
  switch table, which lists movers only, does not show)
- law -> verified: 16 dirs move, all toward golden (vc02, vp01, vp04 to vp09, vp14, vp26, vp28 to
  vp32, vp36), 13 of them to STRICT_EQUAL; the implementer's 197 dirs byte-identical on both

## Sweeps (one five-stage tests/sweep.sh --jobs 3 on the law binary, one on the verified binary)

Each launched by drivers/v11u491_runswp.sh after its own quiet check; the four corpus stages from
the worktree, the sv-tests stage from the main tree (the worktree's UVM folder is empty), exiting 1
on the main tree's stale law index alone. R11U491_TRACE on in both.

- law /tmp/v11u491swp: probe EQUAL 4026 + STRICT_NOTEQUAL 61, surelog 480 + 474, uhdm2rtlil
  803/1/67 both modes, each regressions=0 conversions=0 changes=0; downstream 803 IDENTICAL / 66
  SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, 0 not excused; sv-tests EQUAL 1937, DIFFERENT 3,
  SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, regressions=0
  conversions=0 changes=0; every csv equal to the control /tmp/intr11u489 row for row after
  workdir normalisation (0 diff lines in all five)
- verified /tmp/v11u491swv: every corpus stage the same, every csv equal to the law sweep's; sv-tests
  regressions=0 conversions=0 changes=1: generated/rsd/rsd.sv SURELOG_CRASH -> TIMEOUT, a load
  artefact (no law and no refinement fires on rsd: the trace holds no rsd line), rerun as that row
  alone on the verified binary: SURELOG_CRASH, regressions=0 changes=0
  (evidence/svtests_rsd_rerun_verified.log)
- byteverify, SELFCHECK=1, per corpus: law vs control and verified vs control and verified vs law
  each 0 of 962 (surelog), 0 of 1608 (uhdm2rtlil), 0 of 805 (downstream), negative controls 961,
  1607, 804 flagged; over the whole workdir 24 kept sv-tests databases differ by bytes, the
  workdir name embedded in them (evidence/svtests_movers_normalised.txt: 17 of them dump-identical after
  workdir normalisation, the 7 large ones not dumped, none touched by a law per the trace)
- trace: both sweeps hold only § ovUnsizedBasedActualForm491 abstainDefault on
  ParameterWithUnderscoreValue and ParameterWithUnderscoreValueDivided (uhdm2rtlil both modes,
  downstream), the implementer's prediction; the refinement never fires in a sweep process
- canaries ok=52 and ok=16, both ctcan2 checks PASS, on both sweeps
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the binary under test (the other
  50 hold only a Surelog line; two of them, CoresSweRV and CoresSweRVMP, mention the repo path
  slang-uhdm in a UVM source path), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346, on both sweeps

## Away census (evidence/away_census.txt)

The implementer's 19237 tools/probe dirs whose sources hold "param" (its list, filtered on the fence
list before any file was opened; a planted fenced path dropped as the positive control), each run on
pristine, law and verified (drivers/away.sh): no exit code moves on any binary; pristine -> law
exactly the implementer's 21 byte movers, judged against fresh Surelog goldens
(evidence/away_movers_judged.txt): 17 NOT_EQUAL -> STRICT_EQUAL (r11u487 BR/br13, r11u489 NB/nb20,
v11u489 VN/vn21, vn27, vn30 to vn32, vn34 to vn39, VO/vo03, vo15, VS/vs07, VU/vu39), 3 closer at the
same verdict (br14 dump distance 14 -> 6, v11u421 VP/vp10 uhdm-cmp 52 -> 36 and 16 -> 10,
r10rgg4repro/h4_unsized_based 169 -> 165), v11u232 FX/fx04 with the same dump; law -> verified 0
movers (no earlier probe case re-passes a parameter the law rewrites; the refinement's positive
controls are VC/vc02 and the VP cases above).

## Goal 1

g1a C::mk().arr[1] and g1b u.mk(x).a[2] (r11u423 residue cases) exit 4 on pristine, law and
verified, 0 in upstream slang; v11u415 VT/vt03 this.mk().inner.s exits 0 on all and in upstream
slang; Surelog rejects all three, so there is no golden shape. bp_unicore alone on the verified binary with the size guard
on (its own sv-tests command line): exit 3 in 14.3 s at 814 MB max RSS (evidence/bp_unicore.txt),
no memory-bounded export, the guard stays. None of the 75 SURELOG_ONLY rows moves on either sweep.

## Findings that are not breaks

1. The implementer's switch table lists movers only; r11u491 SS/ss06 shows the SUBSIZE64 /
   DEPBESIDEDP interaction above (each law still droppable; the pair restores pristine).
2. § ovUnsizedBasedActualForm491's size rule for an untyped A with a sized default (-1) is measured
   on decimal defaults only (OA, 4'd4); with a hex default `parameter A = 8'hF` golden reads 8
   (VA/va20) and the law abstains there because our constant carries a typespec, so nothing moves.
3. A BIN constant shared by a continuous assignment reading it whole keeps a bare decompile 101
   where golden keeps 'b101 (VA/va09 untyped A with .A('B101), VP/vp01 its re-pass): the
   reader's resize of the shared constant (ModuleEmit's continuous-assignment sharing, the
   sister's ground), closer than pristine on both (26 -> 2, 14 -> 2).
4. A child's copy of a re-valued dependent B keeps slang's value (VP/vp20 251 where golden 11;
   VP/vp21 written as UINT:0 with the decompile -6 where golden UINT:4294967290 and pristine
   INT:-6): the elaborated override branches copy slang's value, not the re-valued constant; closer
   by distance, the head later.

## Residues (all wrong on pristine too; none moved away on the verified binary; distances in evidence/attack_grid_*.txt)

- the implementer's list (README of r11u491repro), reproduced
- § ovUnsizedBasedActualForm491 not reached: a signed typed A with 'hFF (VA/va12), a hex sized
  default (va20, finding 2), shortint with 'hFFFFF (va22), a string A (va23), a generate-if over A
  (va31), two instances with different actuals and a generate-loop instance (va34, va36; ours UINT
  at size 32 from the older uniquified path), one overridden and one default instance (VC/vc04),
  an interface instance (va37), a defparam over the actual (va38), B = A with .B('h5) (va39), a
  type-parameter typed A (va40, a range face), a genvar loop bound (vc05); closer but not equal:
  'hAb over a sized default (va07), the BIN decompile (va09, finding 3), 'b0 (va15), a net
  initializer (va28), an int A read through localparam B = A (va29), logic [A:0] (va32), A + 1
  under logic [7:0] (vc06), {A} (vc10)
- re-pass shapes § ovRefUnszBasedFormCopy491v does not reach: a localparam hop (VP/vp11, closer), a
  generate-block child (vp12), a defparam c.X = A or u.c.X (vp13, vp33, closer), an interface
  child (vp14, closer), X = 'h1 default (vp27, abstains), a child parameter defaulting to another
  (vp36, closer); the re-valued dependents passed down (vp20, vp21, vp22: finding 4)
- § ovSizedActualMoreBases491: 12'o7777 (VO/vo09, closer), more than 16 digits (vo17), A + 1 over
  4'sb1010 (vo24, closer), ~A over 4'sd3 (vo26), logic [A:0] (vo27), B = A over 4'sb1010 (vo28),
  two instances with different actuals (vo30), an interface instance (vo31), B = A default with a
  4'b actual (VC/vc16), a genvar loop bound (vc15)
- § bitNegBareNameActual491: Q-hop with a sized literal (VN/vn09), P = 3 + 2 (vn15), P overridden
  in the parent (vn20), a generate-loop instance (vn21), an imported package P (vn23), P defparam'd
  (vn26, closer), two instances .A(P) and .A(P+0) (VC/vc31, closer), P = 'h5 (vc33, closer)
- § unboundedDepBesideDefparam491: B read as an operand (VB/vb07, vc22, the elaborated fold face),
  a conditional (vb09), -A (vb13), a value at or above 2^31 (vb16, abstains by design), a range
  wire [B:0] (vb17), a defparam from another module (vb20), a generate-block dependent (vb21), ~B
  (vc24)
- § unboundedSubSize64_491: a conditional holding the subtraction (VS/vs06), a defparam on A
  (vs12), ~B (vs16, vc29), the interface fold (vs20), a generate-block localparam (vs21), a package
  localparam (vs22), {B} (vc28), two instances (vc30)
- § bitNegTypedOperandSize491: integer A = 16'b0100 (VT/vt13, closer), B + 1 (vt41), C = B (vt43,
  vc19), an interface (vt48), a generate-block B (vt54), a type-parameter typed A (VC/vc17, closer),
  an enum A (vc18, by design)

## Sister-ground faces (reported, not written)

- ModuleEmit's continuous-assignment sharing rewriting a shared BIN constant's decompile to bare
  digits (VA/va09, VP/vp01)
- ModuleEmit's interface continuous-assignment fold (VS/vs20, as pass 489's nb24)

## Process

Within the budget: no pristine build, no pristine sweep; one law build (md5 equal to the
implementer's), one verified build, one five-stage sweep on each; the sv-tests stage rerun for one
row (rsd) alone for a load artefact. Slips: my first quiet-wait loop spelled the gate patterns in
its own command line and would have matched itself; I stopped it by its task id before it gated
anything and launched every sweep through the script (whose command line holds no pattern). The
rsd row rerun was launched while the pattern check counted two shells, both quiet-wait shells and
no sweep or runner. The fence list was read into a file by a program and never printed; the census
list and every cmds.txt list were filtered on it before any file was opened (a planted fenced path
dropped as the positive control), and this folder scans clean. No other agent's process was touched.
