# r11u433 — the expression/parameter ground, sv-tests campaign pass 433

Base c0096a9a (pass 434 landed). Ground: src/ExprEmit.cpp, src/StmtEmit.cpp
(src/EmitHelpers.h and src/ParamEmit.cpp unchanged). Four laws, each behind its
own switch read through src/LawSwitch.h (`lawOn(433, ...)`); `R11U433_OFF`
drops all four; `R11U433_TRACE=<dir>` logs every firing and abstention through
`lawTrace(433, ...)`. No src/R*.h, no getenv, no reader function, no header
change.

| law | switch | file |
|---|---|---|
| § connOpUnitParamFold433 | R11U433_UNITOPFOLD_OFF | ExprEmit |
| § connIdxUnitParamFold433 | R11U433_UNITIDXFOLD_OFF | ExprEmit |
| § genCaConstRhsWhole433 | R11U433_GENCAWHOLE_OFF | ExprEmit |
| § classRetFillUnsized433 | R11U433_CLSRETFILL_OFF | StmtEmit |

## Verdict

THE ONE SV-TESTS CONVERSION: generated/fx68k/fx68k.sv DIFFERENT -> STRICT_NOTEQUAL
(uhdm-cmp now equal), through § connOpUnitParamFold433 (one firing, OP_SBCD in
work@fx68k.excUnit.alu's `.bAdd((oper != OP_SBCD))`). The fresh csv row:

    generated/fx68k/fx68k.sv,STRICT_NOTEQUAL,differ:fullname(4),differ:fullname(4)

Its last strict field is the sister's ground (below: ModuleEmit
§ caUnsizedRhsClonePerInst193's `!plainLhs` gate, fx68k.sv 1815/1816
`assign isLineA = lineBmap[ 'hA];`). Every corpus gate is unchanged, no
corpus row, probe case or other sv-tests row moves a byte.

Binaries: pristine 3da951e1eb1969ab5fc9812f41f9725a (the main tree's build at
the base, frozen at /tmp/r11u433_bin/pristine, equal to the worktree's first
build); the swept law binary law8 f01e55adf0e3849e5a9b3aababb3e252; the FINAL
binary law15 176987a0ec5eb022e3721d0ad84fe503 (the patch). law15 differs from
law8 only in the system-call legs of § genCaConstRhsWhole433 (the
definition-folded `$bits` leg, narrowed on the grid after the sweep: see
Process); none of those legs fires on any sweep input (the sweep trace holds
no leg 1 or leg 2 firing at all, its only leg 2 entries are abstentions on
`$bits(blk1.w)`-style dotted arguments in GenScopeHierPath2 and
named_genblk_cascade), and the targeted reruns below read law15's databases
identical to the sweep's.

### The sweep (tests/sweep.sh --jobs 3, all five stages, law8, trace on)

drivers/fullsweep.sh, workdir /tmp/r11u433sw1 (same length as the master's
control /tmp/intr11u434), started 03:00:39 after three quiet readings,
evidence/fullsweep_law8.log:

| stage | reading | against the master's control csv |
|---|---|---|
| probe | EQUAL 4019 + STRICT_NOTEQUAL 68 of 4087, regressions=0 conversions=0 changes=0 | identical |
| surelog | default CMP_EQUAL 480, testflags 474, regressions=0 conversions=0 changes=0 | identical but the two LowMem log-path texts |
| uhdm2rtlil | 803 / 1 / 67 in both modes, regressions=0 conversions=0 changes=0 | identical |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not identical and not excused 0 | identical |
| svtests | EQUAL 1903, STRICT_NOTEQUAL 1, DIFFERENT 36, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=1 changes=0 | the fx68k row alone |

- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) law8 sweep
  against /tmp/intr11u434: surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream
  0 of 805 movers, path sets identical, self-checks 961/962, 1607/1608,
  804/805 (evidence/byteverify_law8.txt); the 4087 probe databases identical
  by path-normalized dump (drivers/bytecmp.sh, 4087 SAMEDUMP; a positive
  control of two different databases reads MOVER). The UVM coin rows did not
  flip in this draw.
- canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil), both
  ctcan2 checks PASS (evidence/canaries_law8.txt).
- binary audit: 5609 of 5659 fence-filtered command records name
  /tmp/r11u433_bin/law8, the other 50 hold only a Surelog line.
- trace census (evidence/trace_census_sweep.txt): the laws fire on one
  database that changes, fx68k (§ connOpUnitParamFold433, 1 firing). The
  literal branch of § genCaConstRhsWhole433 traces on 13 corpus databases
  (GenScopeHierPath, IndexedSelectHex, InsideOp, MultiConcatValueSize,
  StringRange in both modes; BitSelectOfParameterPassedToSubmodule and its
  two GenFor twins, GenIfInside,
  SubmoduleInGenScopeWithGenScopeParametrizedByParameterFromTopModule,
  const_func in both uhdm2rtlil modes and downstream) and on the probe case
  r10rggen7repro/t5, writing no byte: ModuleEmit's own size adjustment of a
  generate-scope literal re-writes the same size after it (byteverify 0
  movers, probe 4087 SAMEDUMP). § classRetFillUnsized433,
  § connIdxUnitParamFold433 and the operation and call branches fire on no
  sweep database.
- final binary, targeted reruns: law15 on those 13 rows (both modes, 26
  databases) reads CMP_EQUAL / strict equal and every database identical to
  the sweep's by path-normalized dump; law15 on fx68k reads the same row and
  the same database; law15 against pristine on all 4087 probe cases at one
  path: 4087 byte-identical with the same exit code
  (evidence/probe_law15_vs_pristine.txt).

### Goal 1

Nothing on this ground: all 75 SURELOG_ONLY rows carry an upstream slang
front-end diagnostic (no exporter `unsupported` message; the messages are
slang's: undeclared identifier, unknown module, redefinition, time scale and
the like). C::mk().arr[1], u.mk(x).a[2] and this.mk().inner.s stay as
pass 417 left them (Surelog rejects them; not forced). black-parrot:
bp_unicore measured alone with law15 and the size guard on: exit 3 in 12.7 s
at 791 MB (the substr error behind the guard); no memory-bounded export,
§ macroVecLitTokenText403's guard stays. rsd stays SURELOG_CRASH.

## The laws

### § connOpUnitParamFold433 and § connIdxUnitParamFold433 (fx68k)

The head of generated/fx68k/fx68k.sv at the base (uhdm-cmp, golden left):

    constant 172:19-172:26 parent operation 172:11-172:26  UINT:6 size 64 vpiUIntConst
    ref_obj (work@fx68k.excUnit.alu.aluCorf.bAdd.OP_SBCD) -> parameter OP_SBCD

fx68kAlu.sv 172: `aluCorf aluCorf(.bAdd( (oper != OP_SBCD) ), ...)`, where
`OP_SBCD = 6` is a compilation-unit localparam (fx68kAlu.sv 17). Surelog's
`NetlistElaboration::high_conn_` compiles an elaborated port actual with
`Reduce::Yes`; the identifier branch's `getValue` hands back the parameter's Value
and mints a constant at the reference. Pass 431's
§ connOperandNonOvParamFold431 / § connBitSelIdxNonOvParamFold431 copy a
module parameter's elaborated param_assign constant and abstain on a $unit
parameter (no `elabParamPa` entry). The forms golden writes for a $unit
parameter, measured on cases/UG (one case per declaration, each with a bare
actual `.a(S)`, an operand `.a(x + S)` and an index `.a(x[S])`) and cases/UC:

| declaration | golden operand / index constant |
|---|---|
| `localparam S = 2;` (untyped, unbased decimals, also `2+3`) | UINT:2 size 64 vpiUIntConst |
| `localparam S = -2;` | INT:-2 size 64 vpiIntConst |
| `parameter int S = 7;`, `localparam integer S = 5;`, `bit [2:0] S = 3` | UINT:<v> at the type's width |
| `localparam S = 4'd3;`, `32'd4`, `[3:0] S = 4'd9` | INT:<v> at the literal's width, decompile `<v>` |
| `localparam S = 'h1F;`, `logic [7:0] S = 8'hA5`, `3'b101` | the literal: decompile as written, HEX/BIN/OCT digits, its width (-1 unsized) |

§ connOpUnitParamFold433: an operand of an operation in an ELABORATED port
High_conn reading a $unit parameter is that constant, parented at the
operation and located at the read (ExprEmit, inside pass 431's operand gate:
the whole-constant operation and genvar abstentions of § connOpGenvarAbstain431v
stand). § connIdxUnitParamFold433: the same for a bit-select index, parented at
the bit_select (ExprEmit, after § connBitSelIdxNonOvParamFold431). Abstentions:
a `$unit::P` read, a typed parameter whose literal width differs from the
type, a signed or x / z literal, an initializer reading a name, enum, real and
string types, a negative typed value. The bare actual `.a(S)` is ModuleEmit's
(sister ground, reported below).

### § genCaConstRhsWhole433 (the generate-body constant Rhs)

UhdmWriter::writeCont_assign (Surelog v1.87, src/DesignCompile/UhdmWriter.cpp)
reduces an ELABORATED generate-scope cont_assign's Rhs with
`m_helper.reduceExpr` (UHDM ExprEval::reduceExpr) and installs a constant it
returns: in the clone-and-reduce leg (a whole-name Lhs `bindVariable` finds,
an operation Rhs) the new constant is unparented; in the reduce leg (any
other Rhs) it is parented at the cont_assign; both are unlocated unless the
Rhs was already a constant, and `adjustSize` re-sizes it to the Lhs typespec
when one is found (a UINT masked, an INT resized, a BIN kept when it fits).
`bindVariable` stops at an interface (no adjust there) and a select or
concatenation Lhs carries no typespec (no adjust, ExprEval's own size).
ExprEval's encodings (ExprEval.cpp reduceExpr / reduceCompOp): `+` UINT (INT
when an operand is vpiIntConst or vpiDecConst) at the wider operand's size;
`- * / %` INT size 64; unary `-` INT at the operand's size; `<< >> & | && ||`
UINT size 64; `~` UINT at the operand's size, masked; comparisons BIN:0/1
size 1; a genvar, $bits / $size / $clog2 and an unbased decimal UINT size 64.

The law intercepts the whole Rhs of the elaborated generate-scope
continuous assignment (`inGenScopeCaRhs`, the parent the cont_assign, the Rhs
syntax the assignment's right side) and reduces either the emitted tree
(constants and operations only) or, when the emitter already folded or kept a
call or a genvar, the slang tree with the leaf rules above (a not-overridden
untyped module or generate-block parameter with an unbased-decimal initializer
reads UINT size 32, as the emitter's own operand fold writes it). Golden
cells (golden left of the arrow, pristine right), cases/GR (`if (W <= 4)`
blocks, a module-level twin as control):

    assign y = $bits(x);   UINT:5 size 32 unlocated, parented   <- UINT:5 size 64 located
    assign y = W + 1;      UINT:3 size 32 unlocated, unparented <- the operation
    assign y = $bits(x)-1; INT:4 size 32                         <- the operation
    assign y = -W;         INT:-2 size 32                        <- the operation
    assign y = $clog2(W);  UINT:1 size 32 parented               <- sys_func_call
    assign y = 5;          the literal, size 32, located         <- size 64

One system call is folded earlier, by the definition compile: `$bits` of a
parameter, or of a name declared in the very generate block that holds the
assignment (not typed by a genvar). reduceExpr then returns that LOCATED
constant, so the law keeps (or, where our emitter kept the call, builds) it at
the call's span and only re-sizes it (golden: the r11u429 cases GB/gb03 and
gb06, cases/GF gf04, gf05; a name of an enclosing block, gb04 and gf06, a
genvar-typed one, gf08, `$size(q)` and `$clog2(P)`, gf10 and GR/gr05, stay
unlocated).

cases/GL (14 Rhs shapes x 6 Lhs kinds: 32-bit net, 4-bit net, logic var, int,
bit select, part select), cases/GC (a child under two overrides, an interface,
nested and else branches, a generate case, a block localparam, a package
parameter, `$bits` of a type, a variable, a gen-local Lhs, an unpacked-array
element, a concatenation Lhs, `%` and `~`, literals, a 64-bit Lhs), cases/GV
(genvars, `$clog2` under an operation), cases/GF (the r11u434 case BD/bd02 and
the r11u429 cases GB/gb01, gb02). Abstentions: a ternary's selected branch (the
Rhs syntax is not the assignment's right side), a gen-local whole-name Lhs, an
unpacked or wider-than-64-bit Lhs, a leaf that is not a sized x / z-free
constant, a call or a genvar, `$bits` of a type (golden's UINT:1 there is a
Surelog artefact: cases GC/gc06, DIVERGENT downstream on both binaries).

### § classRetFillUnsized433 (a class method's `return '0;`)

§ retUnbasedSizing (StmtEmit) sizes an unbased-unsized return literal to the
function's return type (a module function: `return '1;` in `function logic
[3:0] f()` reads BIN:1111 size 4) and keeps the raw literal in a package
function. Golden keeps the raw literal (`'0`/`'1`, BIN, size -1) in a CLASS
method too, in the class body or out of it, whatever the return type: cases/TR
(tr01 is the r11u432 case TP/tp03 `function C::T C::g(); return '0;`; a
`logic [3:0]` return in a $unit class, a package class, a class inside a
module, an out-of-body typedef return C::w_t, a virtual and a static method).
The law skips the sizing when the subroutine's parent scope is a class.

## Grid

94 case dirs in ten groups (evidence/grid_law15.txt; drivers/grid.sh: the
case's law from its first line, pristine and law readings with exit code,
uhdm-cmp line count and strict verdict, R11U433_OFF and the case's own switch
against pristine's bytes and exit code). Every exit code 0 on both binaries.

| group | law | cases | pristine -> law15 |
|---|---|---|---|
| UC | § connOpUnitParamFold433, § connIdxUnitParamFold433 (uc07) | 8 | uc01, uc02, uc03, uc05, uc07 NOT_EQUAL -> STRICT_EQUAL; uc04, uc06, uc08 NOT_EQUAL on both, closer (dist 42->32, 12->2, 98->60) |
| UG | the same, one declaration form per case | 12 | ug03, ug06, ug09, ug10, ug12 NOT_EQUAL -> STRICT_EQUAL; ug01, 02, 04, 05, 07, 08, 11 NOT_EQUAL on both, closer (their remaining difference the bare actual, the sister's) |
| GR | § genCaConstRhsWhole433 (Rhs shapes, a module-level twin as control) | 14 | 8 NOT_EQUAL -> STRICT_EQUAL, 6 STRICT_EQUAL controls byte-identical |
| GL | the same (Lhs kinds x Rhs shapes) | 15 | gl01 to gl14 NOT_EQUAL -> STRICT_EQUAL; gl15 (pass 430's VR/vr41, a gen-for Rhs folded in ModuleEmit) unchanged |
| GC | the same (contexts) | 12 | gc01, 02, 04, 07, 08, 09, 11, 12 -> STRICT_EQUAL; gc10 -> STRICT_NOTEQUAL col (the concatenation Lhs span, sister); gc03 closer (55->2, the nested Lhs actual, sister); gc05 closer (59->12, head in the definition view); gc06 unchanged ($bits of a type) |
| GF | the same ($bits / $size / $clog2 faces, the r11u434 and r11u429 residues) | 10 | gf01 to gf06, gf08, gf10 NOT_EQUAL -> STRICT_EQUAL; gf07 (interface) and gf09 STRICT_EQUAL controls byte-identical |
| GV | the same (genvars) | 4 | gv03 -> STRICT_EQUAL; gv01 closer (50->12); gv02, gv04 unchanged (ModuleEmit emitGenScopes' genvar fold, sister) |
| TR | § classRetFillUnsized433 | 9 | tr01, 04, 05, 07, 08, 09 NOT_EQUAL -> STRICT_EQUAL; tr02 -> STRICT_NOTEQUAL line (typespec location, sister); tr06 closer (11->5); tr03 (a module function, the law does not apply) unchanged |
| HX | residue (sister ground: § caUnsizedRhsClonePerInst193 with a whole-name Lhs) | 4 | STRICT_NOTEQUAL on both, byte-identical |
| FC | residues of passes 431 and 432 (concatenation arguments; ModuleEmit emitContAssigns and the elaborated call fold) | 6 | byte-identical (fc01, fc02 NOT_EQUAL, fc03 to fc06 STRICT_NOTEQUAL type) |

Totals: 55 NOT_EQUAL -> STRICT_EQUAL, 2 NOT_EQUAL -> STRICT_NOTEQUAL, 21
NOT_EQUAL on both (none further from golden by sorted dump distance,
evidence/grid_residue_dist.txt), 16 controls byte-identical. R11U433_OFF
gives pristine's bytes and exit code on 94 of 94; each case's own switch on
82, the 12 others (uc06 and the 11 UG cases with an operand and an index
read) needing R11U433_UNITOPFOLD_OFF and R11U433_UNITIDXFOLD_OFF together,
which give pristine's bytes on all 12.

Downstream (drivers/dsgrid.sh, 79 class-free cases, evidence/downstream_grid.txt):
uc01, uc02, uc04, uc05 EQUIVALENT -> IDENTICAL, ug07 EQUIVALENT with its il
difference gone, none worse; gc06 DIVERGENT on both binaries (golden's $bits
of a type); 68 IDENTICAL on both.

### The earlier-pass census

law15 against pristine on the 4838 fence-filtered case dirs of
tools/probe/r11u401repro to r11u434repro and v11u401repro to v11u434repro
(drivers/epcensus.sh, evidence/earlier_pass_census.txt): 4781 byte-identical
with the same exit code, 8 exit 3 on both with no database, 49 movers, every
one toward golden (evidence/earlier_pass_movers.txt): 46 to STRICT_EQUAL
(44 from NOT_EQUAL: pass 429's GB/gb01 to gb06, gb12 to gb14, pass 434's
BD/bd02, bd05, bd08, bd09, bd11, bd13 to bd15, bd17, bd18, bd21, bd22, bd25,
bd27, v11u434's VB/vb02 to vb05, vb07, vb12, vb14, vb16, vb17, vb23 to vb26,
v11u429's VB/vb21, pass 423's residue cases gb02, gb06, pass 428's residue
case BB/bb06, pass 412's OR/or03, pass 431's UB/ub26, pass 432's TP/tp03,
v11u432's VT/vt01; 2 from STRICT_NOTEQUAL: BD/bd23, VB/vb08) and 3 NOT_EQUAL
closer (pass 423's residue gb03 54 -> 33 uhdm-cmp lines, dump distance
25 -> 2; v11u424's VP/vp06 131 -> 125; v11u434's VB/vb13 44 -> 19, its
uhdm-cmp count 66 -> 70 only because its head moved later, from
`$clog2($size(x))` to `$signed($bits(x))`, a call the law does not fold).

## Prediction (by name, before the sweep)

Made on law8 before the sweep and matched by it exactly:

- a scan of all 7509 fence-filtered pristine databases of the master's
  control /tmp/intr11u434 (drivers/gcscan.py: elaborated generate-scope
  cont_assigns whose Rhs is an all-constant operation, an unparented located
  constant, or a $bits / $size / $clog2 call; evidence/scan_candidates_pristine.txt)
  named 121 probe cases and 31 corpus databases (Earlgrey_0_1 testflags with
  1134 candidate sites, UnpackPort, StringRange, int_types,
  named_genblk_cascade, GenScopeHierPath and others); targeted law8 runs of
  those corpus rows with the trace read CMP_EQUAL / strict equal on all of
  them, the trace naming only the literal branch's same-size rewrite;
- all 4087 probe cases run with law8 against pristine at one path: 4087
  byte-identical, same exit code, the trace naming only r10rggen7repro/t5;
- a fence-filtered source scan of the 2346 sv-tests rows (a generate
  construct beside `assign`, a parameter outside every module, package,
  interface or class, a class `return '0;`) named 405 rows, run with law8 by
  the runner (evidence/prediction_svtests_candidates.txt,
  prediction_svtests_rows.csv): one status move, fx68k DIFFERENT ->
  STRICT_NOTEQUAL differ:fullname(4), and the trace firing on fx68k alone;
- the UVM library's class `return '0;` (uvm_reg_field.svh) does not reach
  § classRetFillUnsized433's sizing branch: SimpleUVM default traced with no
  firing and its database dump-identical to pristine's.

Exit-code movers predicted: none (every grid, census and probe run reads the
same exit code on both binaries).

## Residues (ranked) and sister-ground faces

### Sister-ground faces (ground B; reported with their call sites, not written)

1. fx68k's last strict field, and the next conversion: Surelog's
   `UhdmWriter::writeCont_assign` clones an elaborated cont_assign per
   instance when nothing earlier simplified or cloned it and its Rhs holds a
   constant of size -1 (`DetectUnsizedConstant`), whatever the Lhs, so the
   clone's references read the instance path (golden
   `work@fx68k.uaddrDecode.lineBmap` for fx68k.sv 1815 `assign isLineA =
   lineBmap[ 'hA];`, ours `work@uaddrDecode.lineBmap`). ModuleEmit
   § caUnsizedRhsClonePerInst193 models that leg for a select or
   concatenation Lhs only (`!plainLhs`). cases/HX hx01 to hx03 (`'hA`, `'d5`,
   `'o7` STRICT_NOTEQUAL fullname; `'b1` equal, Surelog sizes it), hx04 (a
   net-declaration assignment and a process beside it). With it fx68k reads
   EQUAL.
2. the bare $unit-parameter port actual `.a(S)` (ModuleEmit emitInstance,
   the direct constant mint): golden writes the $unit Value, UINT size 64 for
   an untyped unbased decimal and INT:<v> at the literal width with decompile
   `<v>` for a based decimal, where ours writes size 32 and `4'd3` DEC:3
   (cases UG ug01, 02, 04, 05, 07, 11, UC uc06; downstream EQUIVALENT nohier);
3. a typed and ranged $unit parameter's own ref_typespec (UhdmExporter, the
   unitParamMap emission at the design's parameter listing): UC/uc04,
   UG/ug04, ug08 head;
4. generate-for bodies whose Rhs reads the genvar (`p[i*8+:8] = i + 1`,
   `-i`, `i * 3`, pass 430's VR/vr41 `-a`): ModuleEmit emitGenScopes folds
   them itself (the § genvarWholeCaRhsFold68 region) at the Lhs width, where
   golden's reduceExpr gives UINT size 64 parented for a select Lhs, INT for
   `*` and unary `-` (GV gv01's second assign, gv02, gv04, GL/gl15);
5. the Lhs reference of a bound assignment in a NESTED generate block lacks
   the actual Surelog's clone leg binds (GC/gc03, ModuleEmit's Lhs emission);
   the concatenation Lhs operation span (GC/gc10, col); a part-select Lhs's
   range constants parented at the part_select in golden (GF/gf10, judge- and
   strict-invisible);
6. the elaborated module-level fold of a function call over a literal
   concatenation, golden BIN:0010 where ours UINT:2 (ModuleEmit
   emitContAssigns; FC fc01, fc02; passes 431's FA/fa16 and 432's FA/fa20),
   and over parameter-only concatenations (fc03 to fc06, type);
7. a port range bound written negative, `input [255:-8] x`: golden INT:-8
   vpiIntConst, ours decompile -8 with UINT:0 (TypeEmit makeBoundConst);
8. the definition listing's generate-scope instance connection
   `(oper != OP_B)` written as a raw-text ref_obj (UC/uc08's head, TypeEmit
   emitSyntaxExpr); the class typespec location on TR/tr02 and the
   unsupported_typespec of a variable typed by a class type parameter
   (TR/tr06).

### On this ground, not written (ranked)

1. § genCaConstRhsWhole433's abstentions: `$signed($bits(x))` and other calls
   outside $bits / $size / $clog2 (VB/vb13's next head: golden INT:15 with a
   signed logic_typespec), a parameter leaf that is typed, overridden or
   initialized by anything but unbased decimals inside a call-bearing tree,
   dotted `$bits(blk.w)` (GenScopeHierPath2, equal today), gen-local Lhs;
2. `$bits` of a type (golden UINT:1, a Surelog artefact, DIVERGENT downstream:
   GC/gc06);
3. a module net shadowing a $unit parameter read whole by an elaborated
   continuous assignment, golden folding the $unit value (pass 431's UB/ub18,
   ub22, ub23, VB/vb12): a Surelog misbinding at writeCont_assign's reduce;
4. p733's defparam from a second top module, which Surelog does not apply
   (its values, the typespec ranges and the listing order move together over
   ParamEmit, TypeEmit and ModuleEmit); tnoc's 333:14 head (Surelog's
   function evaluation writing back into a constant);
5. the carried lists of passes 431 (the connection shapes ec05, ec06, ec12,
   ec20, ec26, vc04, vc09, vc14, vc15, vc20, the `'{default:0}` array
   parameter, TP/tp13, ub15), 429, 427, 425, 423, 421, 419, 417, 415, 413,
   411, 409, 407, 405, 403 and 401 as their READMEs list them, minus what this
   pass cleared: pass 429's GB/gb01 to gb08, gb12 to gb14, VB/vb21; pass 434's
   reported BD/bd02 face (and bd01's select); pass 432's TP/tp03; pass 431's
   UB/ub26 ($unit parameter in a connection index).

## Process

- Worktree /tmp/wt_r11u433 at c0096a9a, built with -j 2; the first build
  equal to the main tree's pristine (3da951e1...). No pristine sweep (the
  pristine reading is the master's control /tmp/intr11u434); intermediate
  binaries law1 to law14 on case runs, the probe and earlier-pass censuses
  and targeted runner calls only; ONE full five-stage sweep, on law8.
- After the sweep the grid's def-fold cases (pass 429's GB/gb03, gb04, gb06,
  v11u434's VB/vb16, cases/GF gf04 to gf10) showed the system-call leg
  writing an unlocated constant where the definition compile had already
  folded `$bits` of a parameter or of a name declared in the assignment's own
  generate block (golden located); law9 to law15 narrowed that leg ($bits
  only, same block only, genvar-typed declarations excluded). The change
  reaches only calls the sweep trace shows never fired, so no stage was
  rerun as a whole: the targeted reruns above (13 corpus rows, fx68k, all
  4087 probe cases, the 4838-dir earlier-pass census) read law15 identical
  to law8 on every sweep input and the census mover set unchanged.
- Slips, none affecting a measurement: (1) my targeted surelog runner call on
  Earlgrey_0_1 and eleven small rows (law4, the prediction) ran from 01:47
  to 01:49 while the sister r11u436's single-row runner on
  apb_protocol_monitor was live (my process check printed it and did not
  wait); (2) my probe prediction batch on law8 was launched at 01:55 while
  the sister's first full sweep (r11u436sw1) had just started its probe
  stage; I stopped it by its PIDs after about one minute (840 of 4087 cases
  done) and reran the rest after three quiet readings; (3) my downstream
  case grid (72 cases, two binaries) ran until 02:39 beside the
  sister's second sweep (r11u436sw2), whose corpus stages my process check
  printed; my own sweep waited for three quiet readings and overlapped
  nothing. One background waiter used a self-matching `pgrep -f` and was
  stopped by its task id and replaced by a PID wait.
- The fence list was read from tools/probe/r11u107repro/canaudit.sh's
  FENCED= line into /tmp/r11u433_scratch/fenced.txt by a program without
  printing it; every tree-wide list (the database scan, the probe and
  earlier-pass censuses, the sv-tests source scan, the binary audit, the
  byteverify of the probe tree) was filtered on it before a file was opened.
  No other agent's process was touched; no fenced test named, opened or run.
- The standing word rule: nothing to rewrite in this README, the drivers or
  the added source lines.

## Drivers

- drivers/run1.sh, grid.sh, head.sh, cdiff.sh, dist.sh, ndiff.sh: case runs
  (golden cached per case text under /tmp/r11u433_scr/gold), the grid with
  R11U433_OFF and each case's own switch (drivers/switches.txt).
- drivers/genca.py: the elaborated generate-scope cont_assign Rhs heads of a
  dump; drivers/gcscan.py: the candidate scan over pristine databases.
- drivers/probecmp.sh: law against pristine bytes and exit code per
  tests/probe case, with the trace.
- drivers/dsgrid.sh: downstream verdict per case; drivers/fullsweep.sh: the
  one five-stage sweep; drivers/quiet.sh, quiet3.sh: wait for a quiet machine.
