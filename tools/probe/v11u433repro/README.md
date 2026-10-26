# v11u433 — adversarial verification of r11u433 (expression/parameter ground)

Base c0096a9a (pass 434 landed). Implementer's patch /tmp/r11u433.patch: four
laws in src/ExprEmit.cpp and src/StmtEmit.cpp (§ connOpUnitParamFold433,
§ connIdxUnitParamFold433, § genCaConstRhsWhole433, § classRetFillUnsized433).
VERDICT: the four laws stand, with FIVE verifier refinements, all in
src/ExprEmit.cpp, each behind its own switch read through src/LawSwitch.h
(`fixOn(433, "R11V433_<X>_OFF")`; `R11V433_OFF` drops all five and gives the
law's bytes). Three of them fix BREAKS where pristine was right and the law
wrong on legal SV (one downstream IDENTICAL -> DIVERGENT, two IDENTICAL ->
EQUIVALENT, one strict location cell moved away from golden, uhdm-cmp 32 -> 84
and 17 -> 80 lines); the other two finish the unit-parameter fold's literal
forms and remove orphan constants. No src/R*.h, no getenv, no reader
function, no header change; StmtEmit, ParamEmit, EmitHelpers.h, the sister's
four files, include/ and uhdm_main.cpp unchanged by the verifier.

| refinement | switch | kind |
|---|---|---|
| § unitParamPlainEval433v | R11V433_UNITEVAL_OFF | THE FIRST BREAK (downstream) |
| § genCaBitsSelectKeeps433v | R11V433_GENBITSSEL_OFF | THE SECOND BREAK (uhdm-cmp and downstream) |
| § genCaBitsMemberDefFold433v | R11V433_GENBITSMEMBER_OFF | THE THIRD BREAK (strict location cell) |
| § unitParamLitForm433v | R11V433_UNITLIT_OFF | toward golden (and the plugin reads OCT:<d> as x) |
| § unitParamNoOrphan433v | R11V433_UNITORPHAN_OFF | byte hygiene |

## The breaks and the refinements

### § unitParamPlainEval433v (THE FIRST BREAK)

§ connOpUnitParamFold433 wrote an untyped $unit parameter's VALUE from
slang's constant: slang wraps an unbased decimal above 2^31-1 to a signed
32-bit value and truncates one above 2^32. `localparam S = 3000000000;` read in
`.a(x + S)` became INT:-1294967296 size 64; the downstream plugin reads it as
64'hFFFFFFFF_B2D05E00 where golden's UINT:3000000000 reads 64'h00000000_B2D05E00
(case VU/vu23: downstream IDENTICAL on pristine -> EQUIVALENT with nohier, il
and synth differing on the law; pristine kept the ref_obj and the plugin read
the parameter). Golden (Surelog's ExprEval over the initializer as written,
cases VU/vu13, vu21, vu23, vu25, vu15):

    localparam S = 3000000000      UINT:3000000000 size 64   (law INT:-1294967296)
    localparam S = 4294967296      UINT:4294967296 size 64   (law UINT:0)
    localparam S = 3000000000 + 1  UINT:3000000001           (law INT:-1294967295)
    localparam S = 2147483648      UINT:2147483648           (law INT:-2147483648)
    localparam S = 2*3, 7/2, 10-3, (2+3)*2   INT:6, INT:3, INT:7, INT:10   (law UINT)
    localparam S = 2 > 1           BIN:1 size 1 decompile 1'b1  (law UINT:1 size 64)
    localparam int S = 2*3         INT:6 size 32              (law UINT:6)
    localparam int S = -3          INT:-3 size 32             (law abstained)
    localparam bit [63:0] S = 4294967296   UINT:4294967296 size 64  (law UINT:0)
    localparam int S = 2 > 1       INT:-1 (a Surelog artefact: abstain)

The fix evaluates the initializer's syntax with the law's own ExprEval table
(gcApply433: an unbased decimal UINT size 64 read from its digits, `-` `*` `/`
`%` INT size 64, a comparison BIN size 1) and writes that value and kind; a
typed parameter takes the kind at the type's width and abstains on a
comparison, a negative value in an unsigned type and a value the type cannot
hold; an operator outside the table abstains (pristine's bytes).

### § genCaBitsSelectKeeps433v (THE SECOND BREAK)

§ genCaConstRhsWhole433's call leg folded `$bits` / `$size` of a bit or range
select with slang's evaluator. Golden keeps the sys_func_call there (Surelog's
reduceExpr does not fold a call over a select), exactly as pristine writes it:
case VW/vw41 (`$bits(x[3:0])`, `$bits(x[1])`, `$bits(pk[1])`, `$bits(m[0])` in
an `if` generate body; uhdm-cmp 32 lines on pristine -> 84 on the law), VW/vw44
(`$bits(x[1]) + 1`, `$size(x[3:0])`, `$bits(pk[0]) * 2`; uhdm-cmp 17 -> 80,
downstream IDENTICAL -> DIVERGENT on the law), VW/vw43 (`$bits(q[0])`). The fix
abstains on a select argument in both the whole-call leg and the slang-tree
reducer (gcSlang433), returning pristine's object; vw44 reads pristine's bytes
again, downstream IDENTICAL.

### § genCaBitsMemberDefFold433v (THE THIRD BREAK)

`$bits(s.b)` of a member whose type reads no name is folded by the definition
compile, so golden's elaborated constant keeps the call's LOCATION (and its
cont_assign parent and the Lhs size). Pristine had the location right (and the
size wrong); the law's call leg wrote it unlocated: case VW/vw30 NOT_EQUAL ->
STRICT_NOTEQUAL file on the law, one location cell moving away from golden
(also VW/vw42, a gen-local struct). A member whose type reads a parameter,
`logic [W-1:0] a`, is not folded at all and golden keeps the call (VW/vw43,
two instances, W = 5 and the default; the law folded it). The fix: a member
access argument whose struct member declaration reads no name joins the
definition-folded `$bits` road of the law (leg 3 resizes the located constant,
leg 4 builds it at the call's span); one that reads a name, or a member under
`$size` / `$clog2`, abstains (pristine's call). vw30, vw42 and vw43 read
STRICT_EQUAL.

### § unitParamLitForm433v

Golden writes an octal $unit literal as its value (`3'o5` UINT:5 size 3
decompile 5, `'o17` UINT:15, `12'o7_7` UINT:63 size 12) and a hex or binary
literal's decompile with the base lowercased and the underscores dropped
(`8'hA_5` -> 8'hA5, `'b1_01` -> 'b101, `8'HFF` -> 8'hFF, `4'B1010` -> 4'b1010):
cases VU/vu20, vu22, vu24. The law wrote OCT:<digits>, which the downstream
plugin reads as x (VU/vu24 IDENTICAL on pristine -> EQUIVALENT on the law, its
constant 64'...0x), and kept the written spelling in the decompile.

### § unitParamNoOrphan433v

The law made its constant before its abstentions and left it in the database
unreferenced when it then abstained (a signed `4'sd3`, an x / z literal, a
typed negative): bytes moved with the dump identical (VU/vu26: pristine 7807
bytes, law 7871). The constant is now made after every abstention.

## Reproduction of the implementer's numbers

Binaries (frozen, read-only): pristine /tmp/v11u433_bin/pristine
3da951e1eb1969ab5fc9812f41f9725a (the main tree's build at the base; no pristine
build and no pristine sweep, the pristine reading the master's control
/tmp/intr11u434); LAW /tmp/v11u433_bin/law 176987a0ec5eb022e3721d0ad84fe503,
built once in /tmp/wt_v11u433 from the patch on a fresh c0096a9a (a clean
apply), EQUAL to the implementer's law15; VERIFIED /tmp/v11u433_bin/ver3
256107fb9c98995fc2a29f7dfe33d198. Both link slang 12.0.0+545f88b2e.

### The law sweep (the first full five-stage reading of law15)

drivers/fullsweep.sh, workdir /tmp/v11u433sw1 (same length as the control),
started 04:03 after three quiet readings, evidence/fullsweep_law.log:

| stage | reading |
|---|---|
| probe | EQUAL 4019 + STRICT_NOTEQUAL 68 of 4087, regressions=0 conversions=0 changes=0, csv identical to the control |
| surelog | 480 + 474 CMP_EQUAL, 0/0/0, csv identical to the control but the two LowMem log-path texts |
| uhdm2rtlil | 803 / 1 / 67 in both modes, 0/0/0, csv identical |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; csv identical |
| svtests | EQUAL 1903, STRICT_NOTEQUAL 1, DIFFERENT 36, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions=0 conversions=1 changes=0; the csv identical to the implementer's on all 2346 rows and to the control but the fx68k row |

    generated/fx68k/fx68k.sv,STRICT_NOTEQUAL,differ:fullname(4),differ:fullname(4)

- byteverify (SELFCHECK=1) law against /tmp/intr11u434: 0 of 962, 0 of 1608,
  0 of 805, path sets identical, self-checks 961/962, 1607/1608, 804/805; the
  4087 probe databases SAMEDUMP by path-normalized dump with a positive control
  that moves (evidence/byteverify_law_vs_control.txt,
  probe_dump_law_vs_control.txt).
- canaries ok=52 changed=0 and ok=16 changed=0, ctcan2 PASS on both
  (evidence/canaries_law.txt).
- binary audit (the fence-filtered command records): 5609 of 5659 name
  /tmp/v11u433_bin/law, the other 50 hold only a Surelog line.
- trace census: § connOpUnitParamFold433 fires once (fx68k, OP_SBCD UINT:6);
  § genCaConstRhsWhole433's literal leg traces on the implementer's 13 corpus
  databases and the probe case r10rggen7repro/t5 writing no byte; no other
  firing (25972 abstentions, 14 of them in the call leg).
- fx68k's last strict field, reproduced with the kept golden: four fullnames
  at fx68k.sv 1815/1816 (`work@fx68k.uaddrDecode.lineBmap` in golden,
  `work@uaddrDecode.lineBmap` in ours), the per-instance clone of a
  module-level cont_assign with an unsized-constant index (ModuleEmit
  § caUnsizedRhsClonePerInst193, the sister's ground, as reported).

### The implementer's grid and census

- the 94 case dirs of tools/probe/r11u433repro on all three binaries
  (evidence/grid_r11u433_cases.txt): every exit code 0; the implementer's
  readings reproduced (55 to STRICT_EQUAL, 2 to STRICT_NOTEQUAL, 21 unequal on
  both, 16 controls); R11U433_OFF gives pristine's bytes on 94 of 94; the
  case's own switch on 82, the 12 UC/UG operand-and-index cases needing both
  unit switches; R11V433_OFF gives the law's bytes on 94 of 94 and the
  VERIFIED binary writes the law's bytes on all 94 (no refinement fires there).
- downstream on its 79 class-free cases: 4 EQUIVALENT -> IDENTICAL (uc01,
  uc02, uc04, uc05), gc06 DIVERGENT on both, none worse
  (evidence/downstream_grid_r11u433_cases.txt).
- the earlier-pass census over the implementer's 4838 fence-filtered case dirs
  (passes 401 to 434, evidence included) on all three binaries
  (evidence/earlier_pass_census.txt): exit codes equal on all three
  (4811 exit 0, 19 exit 4, 8 exit 3 with no database); pristine -> law exactly
  the implementer's 49 movers, judged against golden: 46 to STRICT_EQUAL and
  3 closer (r11u423's residue gb03 54 -> 33 uhdm-cmp lines, v11u424's VP/vp06
  and v11u434's VB/vb13 closer by dump distance); law -> VERIFIED 0 movers
  (evidence/earlier_pass_movers_judged.txt).

## The attack grid

98 fresh case dirs in VD, VI, VR, VU and VW (every one accepted by upstream
slang with `--single-unit`; every exit code 0 on all three binaries;
evidence/grid_v11u433.txt, drivers/grid.sh, the switch table
drivers/switches.txt). Each case's first line names its law.

| group | law | shapes |
|---|---|---|
| VD (6) | § genCaConstRhsWhole433 | a delay `#D` with a parameter, `#1`, `#(D)` (Surelog's writeCont_assign skips the reduce for a ref_obj delay: golden folds the same constant, the law right; the remaining difference is our missing generate-scope delay, pristine too) |
| VW (45) | § genCaConstRhsWhole433, the select and member refinements | Lhs kinds (typedef, packed struct, integer, byte, signed, output port, reversed range, 1-bit, non-ANSI port, a net declared after the block, nested-block Lhs, select and concatenation Lhs), Rhs shapes (`**`, `%`, `~`, `&&`, `!=`, `<<`, shifts of sums, unary minus, typed and based-literal parameters, overrides, a 64-bit Lhs, 3000000000, literals `-1` `~0` `'hFF` `'1`, `$bits` of struct / member / select / unpacked array, `$size`, `$clog2` of an operation), contexts (case generate, else branch, for generate, interface, nested if, block localparam, a ternary) |
| VU (26) | § connOpUnitParamFold433 and the unit refinements | comparison, typed byte / logic signed / int unsigned / shortint / integer, `1'b1`, `'hF`, `4'hA`, binary with underscores, octal, ternary branch, nested operations, a genvar loop, an interface instance, a module parameter shadowing, a cast, 64-bit values, a function argument, `$unit::S`, unary minus, a concatenation, a module twin read |
| VI (8) | § connIdxUnitParamFold433 | `x[S+1]`, `x[S:0]`, `x[S][1]`, based literals, a generate loop, `$signed(x[S])`, two instances, a struct member select |
| VR (13) | § classRetFillUnsized433 | bit, int, a package class, a parameterized class, a nested class, if / else returns, 'x and 'z, a module function and a $unit function beside it, a static method in a module class, an interface class implementation, a struct and a 1-bit return, a class inside an interface, a local variable assigned '1 |

pristine -> law -> VERIFIED: 48 NOT_EQUAL -> STRICT_EQUAL -> STRICT_EQUAL; 7
NOT_EQUAL on pristine and the law -> STRICT_EQUAL on the verified binary
(VU/vu13, vu20, vu22, vu23, vu24, VW/vw41, vw43); 2 NOT_EQUAL -> STRICT_NOTEQUAL
file -> STRICT_EQUAL (VW/vw30, vw42); VU/vu15 NOT_EQUAL -> NOT_EQUAL ->
STRICT_NOTEQUAL endcol (the $unit parameter's own `-3` span, not this pass's);
VU/vu08 STRICT_NOTEQUAL depth on both (the $unit typespec order); 33 NOT_EQUAL
on all three (VW/vw44 back at pristine's bytes, the others closer or
unchanged); 6 controls kept (5 STRICT_EQUAL, VI/vi02 STRICT_NOTEQUAL fullname).
By dump distance (evidence/dist_v11u433.txt) the VERIFIED binary is never
further from golden than pristine on any case; the LAW was further on VW/vw41
(25 -> 110 unsorted), vw43 (62 -> 118) and vw44 (9 -> 104).

Switches: R11U433_OFF gives pristine's bytes and exit code on 98 of 98;
R11V433_OFF gives the law's bytes on 98 of 98; each law's own switch gives
pristine's bytes on its cases; each refinement's own switch gives the law's
bytes on its cases but five that co-fire a second refinement (VW/vw41 and vw43
select + member, VU/vu24 literal form + evaluation, vu26 and vu15 orphan +
evaluation), where the two switches together give the law's bytes (checked on
all five) and R11V433_OFF does too.

Downstream on the 85 class-free cases (VD, VI, VU, VW;
evidence/downstream_grid_v11u433.txt): pristine -> law -> VERIFIED, the law
moved three away from IDENTICAL (VU/vu23 and vu24 -> EQUIVALENT, VW/vw44 ->
DIVERGENT), the VERIFIED binary none: 11 move to IDENTICAL (VU/vu02, vu05,
vu06, vu07, vu08, vu13, vu19, vu20, vu21, vu22, VW/vw24 DIVERGENT -> IDENTICAL),
none worse than pristine.

## The verified sweep

drivers/fullsweep.sh on the VERIFIED binary, workdir /tmp/v11u433sw2, after
three quiet readings (evidence/fullsweep_verified.log): every stage reads what
the law sweep read: probe 4019 + 68 with 0/0/0, surelog 480 + 474 with 0/0/0,
uhdm2rtlil 803 / 1 / 67 in both modes with 0/0/0, downstream 803 / 66 / 2 / 0,
sv-tests EQUAL 1903, STRICT_NOTEQUAL 1, DIFFERENT 36, BOTH_REJECT 303,
SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 with
regressions=0 conversions=1 (fx68k, the same row) changes=0. The five csvs
are identical to the law sweep's but the two LowMem log-path texts.
byteverify VERIFIED against the law sweep and against the control: 0 of 962,
0 of 1608, 0 of 805 (self-checks 961/962, 1607/1608, 804/805;
evidence/byteverify_verified.txt); the 4087 probe databases byte-identical to
the law sweep's; the kept sv-tests databases identical to the law sweep's by
path-normalized dump (57 of 58; the 58th, tnoc, whose dump the 900 s timeout cuts, differs in exactly one byte, the workdir name inside builtin.sv's path), fx68k's included. Canaries ok=52
and ok=16, ctcan2 PASS on both (evidence/canaries_verified.txt). Binary audit:
5609 of 5659 fence-filtered command records name /tmp/v11u433_bin/ver3, the
other 50 hold only a Surelog line. The trace reads exactly the law sweep's
census (fx68k's one firing, the literal leg on the 13 databases and t5, no
refinement abstention or firing on any sweep input). So no refinement reaches
a corpus row, a probe case or an sv-tests row: they act on the attack cases
alone.

## Goal 1

Reproduced: all 75 SURELOG_ONLY rows of the law sweep carry an upstream slang
front-end diagnostic (no exporter message; one detail holds the repository
path in a UVM time-scale diagnostic). bp_unicore measured alone with the
verified binary and the size guard on: exit 3 (the substr error behind
§ macroVecLitTokenText403's guard) in 14.6 s at 774 MB; no memory-bounded
export, the guard stays. rsd stays SURELOG_CRASH. Every attack case exits 0 on
all three binaries; no exit-code mover anywhere (grids, census, sweeps).

## Residues (ranked; all wrong on pristine too, none moved away by the verified binary)

1. § genCaConstRhsWhole433 on a module parameter whose initializer is an
   operation ExprEval types INT (`localparam L = 2*3; assign y = L + 1;` golden
   INT:7, ours UINT:7: VW/vw26; a based-decimal parameter `W = 4'd2`, golden
   INT:3, VW/vw10; an override `.W(4'd4)`, VW/vw11): the emitted tree's
   parameter leaves carry the emitter's UINT, the kind golden takes from the
   parameter's own Value. Closer than pristine (which kept the operation).
2. The definition-folded `$bits` constant's cont_assign parent (golden parented,
   ours not, VW/vw42 y2): judge- and strict-invisible.
3. The generate-scope cont_assign's delay `#D` / `#1` missing on our side
   (VD/vd01 to vd06; ModuleEmit's generate-scope emission: sister ground).
4. `assign y = 'hFF;` in a generate body: golden size 8 (the Lhs), ours -1
   (VW/vw45).
5. The unit fold's remaining shapes: `.a(S + 1)` whole constant (VU/vu01,
   golden reduces whole), a genvar loop (vu09), an interface instance (vu10), a
   cast `4'(S)` (vu12), a function argument (vu14), `$unit::S` (vu16), `-S + x`
   (vu17), `S[3:0]` in a concatenation (vu18); index shapes `x[S+1]` (VI/vi01),
   `x[S][1]` (vi03), `s.f[S]` (vi08).
6. Class return: a module function's and a $unit function's `return '1;` in
   golden's definition listing stay unsized where ours sizes them (VR/vr07,
   vr11; § retUnbasedSizing's ground, outside this law).
7. The implementer's ranked residues and sister-ground faces stand as its
   README lists them (fx68k's last face: ModuleEmit
   § caUnsizedRhsClonePerInst193's `!plainLhs` gate).

## Sister-ground faces (reported, not written)

- the generate-scope cont_assign delay (VD cases): ModuleEmit's generate-scope
  continuous assignment emission writes no vpiDelay.
- the implementer's list stands (ModuleEmit § caUnsizedRhsClonePerInst193,
  emitInstance's bare $unit actual, the $unit parameter's ref_typespec in
  UhdmExporter, emitGenScopes' genvar folds, TypeEmit makeBoundConst).

## Process

- Worktrees /tmp/wt_v11u433 (law, then verified) and /tmp/wt_v11u433pris
  (unused: no pristine build, per the budget). Builds -j 2. The law built once
  (equal to law15). OVER THE BUILD BUDGET by two intermediate verified builds,
  used on case runs only and never swept: ver (cb8351f9, the three unit
  refinements alone, before the select and member breaks were found), ver2
  (3bdc8e20, the member classifier reading the field's declared type, which
  carries no type syntax, so every member abstained; found on VW/vw30 before
  any sweep and replaced by the struct member declaration's syntax); the final
  verified build ver3 (256107fb).
- Sweeps: one full five-stage sweep on the law binary, one on the verified
  binary; no stage rerun.
- Slips, none affecting a measurement: the law build and the first pristine
  case runs ran while the sister v11u436's sweep
  wrapper was live but idle (its quiet loop matching its own command line, no
  stage process running); my attack-case runs, the downstream grids and the
  earlier-pass census ran beside my own law sweep or between my two sweeps,
  never beside the sister's stages; my first downstream grid call used
  relative case paths after the driver changed directory, so it ran nothing
  (FileNotFoundError on every case) and was rerun with absolute paths, the
  main tree checked clean afterwards; one verified build failed to compile
  and was fixed before any run.
- The fence list was read from tools/probe/r11u107repro/canaudit.sh into
  /tmp/v11u433_scr/fenced.txt by a program without printing it; every
  tree-wide list (the census list, the command-record audit, the probe
  database compare) was filtered on it first. No other agent's process
  touched; no fenced test named, opened or run.
- The standing word rule: nothing to rewrite in this README, the drivers or
  the added source lines.

## Drivers

drivers/run1.sh (one case: golden cached per case text, ours, uhdm-cmp,
uhdm-strictcmp), grid.sh (pristine / law / verified and the switches),
dsgrid.sh (downstream verdict), epcensus3.sh (the three-binary census),
dd.sh, dist.sh, rhs.py (dump diff, distance, generate-scope Rhs listing),
bcmp.py, bytecmp.sh (path-normalized dump compare), fullsweep.sh.
