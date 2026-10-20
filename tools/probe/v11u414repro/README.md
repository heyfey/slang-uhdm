# v11u414 — adversarial verification of r11u414 (module/type ground, sv-tests pass 414)

Base b94cdc046 (pass 412). Implementer patch /tmp/r11u414.patch applied clean on
a fresh worktree (/tmp/wt_v11u414; one whitespace warning, a blank line at the
end of a README). Pristine reading = the master's control sweep /tmp/intr11u412
(no pristine sweep run here); pristine binary = the main tree's build at the base
(md5 42190a8e4437a04efe2664fc6287574c, frozen /tmp/v11u414_bin/pris).
Law binary rebuilt once from the patch: md5 8a94273621ee38e1d6dda1fc9f6c4018,
EQUAL to the implementer's /tmp/r11u414_bin/law (frozen /tmp/v11u414_bin/law).
Verified binary: md5 565d1c303e0a972a4f760ee14d919044 (frozen
/tmp/v11u414_bin/ver2). All three link slang 12.0.0+545f88b2e.

## Verdict

The implementer's 12 laws hold on every gate: no corpus row, probe case,
downstream row or sv-tests row regresses, and the 12 sv-tests conversions
reproduce row for row. The fresh-case attack found ONE law that breaks legal SV
that pristine got right, § clsTdArgAliasTwin414, and one law that writes the
wrong object on a shape it does not describe, § unitFwdTypedefTwin414. Both are
refined here behind their own switches:

| refinement | file | switch | statement |
|---|---|---|---|
| § tdArgTwinOwnScope414v | TaskFuncEmit (inside § clsTdArgAliasTwin414) | R11V414_ARGTWINSCOPE_OFF | the formal's twin is written only when the typedef is declared in the subroutine's OWN class or module, the type is written as a plain name, the subroutine is not a DPI import and no DPI export item naming it precedes its definition; otherwise golden binds the typedef's own object (or, for a scoped `C::i_t`, an unsupported_typespec not written here) |
| § fwdClassFirstAbstain414v | UhdmExporter (inside § unitFwdTypedefTwin414) | R11V414_FWDCLASSFIRST_OFF | a bare `typedef C;` that names a CLASS also counts as a forward typedef; when it comes first, golden's listed twin is the class_typespec C at the forward declaration and the later `typedef t;` adds nothing, so the law abstains (it listed a clone of t) |

`R11V414_OFF` drops both refinements (the law's bytes on every case dir);
`R11U414_OFF` still drops the whole pass (pristine's bytes on every case dir).

THE BREAKS (fresh cases, legal SV, upstream slang accepts every one):

- § clsTdArgAliasTwin414 wrote the twin for typedefs that golden binds directly.
  It moved FIVE STRICT_EQUAL cases off equality:
  - VA/va13: an inherited typedef (`class D extends B; function void f(i_t a);`,
    i_t declared in B). STRICT_EQUAL -> STRICT_NOTEQUAL line.
  - VA/va14 and va21: a DPI import formal typed by a module typedef
    (`import "DPI-C" function void dpi_f(i_t a);`, and the task form).
    STRICT_EQUAL -> STRICT_NOTEQUAL line.
  - VA/va20: a nested class's method typed by the enclosing class's typedef.
    STRICT_EQUAL -> NOT_EQUAL (17 uhdm-cmp lines).
  - VA/va22: a module function named by an `export "DPI-C" function f;` item
    written BEFORE it. STRICT_EQUAL -> STRICT_NOTEQUAL line. The same function
    with the export written AFTER it (va29) does take golden's twin, and that
    case is NOT_EQUAL on all three binaries for another reason (the
    function listing order).

  It also moved two NOT_EQUAL cases away:
  - VI/vi05: another class's typedef written `D::T`. dump 24 -> 34, uhdm-cmp
    22 -> 32.
  - VA/va19: the class's own typedef written scoped (`C::i_t`), where golden
    writes an unsupported_typespec `C::i_t`. uhdm-cmp 22 -> 32.

  Verified:
  - va13, va14, va20, va21, va22 are STRICT_EQUAL again.
  - va25, va26, va30, va31 go NOT_EQUAL -> STRICT_EQUAL (the law had only made
    them STRICT_NOTEQUAL: one formal right, the inherited, DPI or exported one
    wrong).
  - va19 and vi05 are back at pristine's bytes.
  - The implementer's TA cases and class_member_test_9 keep the law's bytes
    (an out-of-body definition's parent scope is its class, va23).
- § unitFwdTypedefTwin414 searched only the TypeAlias forward declarations.
  - VF/vf15 (`typedef C; class C #(...); typedef t; typedef byte t;`): the
    first bare forward typedef is the class's, and golden lists a
    class_typespec C twin at 2:9. The law listed a byte_typespec t twin
    instead. uhdm-cmp went 498 -> 52, but the normalized dump went 11 -> 16
    lines away, with a wrong object kind and name in golden's slot.
  - Verified: vf15 and vf05 (`typedef c; class c;`) are at pristine's bytes;
    writing the class twin is a residue.

## Reproduction of the implementer's claims

- Patch surface: src/TypeEmit.cpp, src/ModuleEmit.cpp, src/UhdmExporter.cpp,
  src/TaskFuncEmit.cpp, tests/LAWS.md, tools/probe/r11u414repro/ (nothing under
  results/ or third_party/, no src/R*.h, no getenv, no reader function).
  - 12 law switches through `lawOn(414, ...)`: R11U414_VARINITMASK_OFF,
    _CLASSARRELEM_OFF, _CHANDLEPROP_OFF, _CLSWILDCARDIDX_OFF, _FWDTDTWIN_OFF,
    _ARGALIASTWIN_OFF, _IFCLSARG_OFF, _REALTIME_OFF, _MEMBERDEFAULT_OFF,
    _ARRSTRINIT_OFF, _CLSPROPBINOP_OFF and _RANDMEMBER_OFF.
  - 14 lawTrace(414, ...) sites. The realtime typespec sites in makeTypespec
    and bareElemTypespec carry no trace.
- No-header audit (verified patch): no src/R*.h and no getenv in the added
  lines. The two refinement switches read through `fixOn(414, ...)` in
  src/LawSwitch.h.
- Grid: the implementer's case dirs were rerun with this verifier's binaries
  and golden cache (/tmp/v11u414_impl). Every line matches the implementer's
  evidence/grid.txt (pristine and law, exit code, uhdm-cmp count, strict
  verdict).
  - R11U414_OFF restores pristine's bytes and exit code on 60 of 60, and each
    group's own switch does too.
  - The verified binary writes the law's bytes on all 60.
  - CORRECTION: there are 60 case dirs, not 62. The grid is 45 NOT_EQUAL ->
    STRICT_EQUAL, 4 equal controls (FT/ft05, TA/ta07, WC/wc04, VM/vm06) and
    11 NOT_EQUAL on both. The README said 62 and 47; the verified patch
    corrects it.
- CORRECTION, the law index: 14 of the implementer's cases named a law that
  does not exist on their first line. CI/ci01 to ci03 named
  `classConstPropInit414` and FT/ft01 to ft11 named `unitFwdTypedefAlias414`;
  they now read § classPropBinOpInit414 and § unitFwdTypedefTwin414, and
  tests/LAWS.md is regenerated.
- The law sweep (one full five-stage sweep on the law binary, the machine
  quiet, workdir /tmp/v11u414_wL, R11U414_TRACE set; the four corpus stages
  through the worktree's tests/sweep.sh --jobs 3, the sv-tests stage through
  the main tree's scripts/check_svtests.py read-only, since a worktree has no
  UVM tree):
  - probe: EQUAL 4018 + STRICT_NOTEQUAL 69, 0/0/0; csv identical to the
    control.
  - surelog: default 480 / testflags 474 CMP_EQUAL, 0/0/0; the csv differs
    from the control only in the two LowMem log-path detail texts.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0; csv identical.
  - downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0
    DIVERGENT; csv identical.
  - sv-tests: regressions=0 conversions=12 changes=0; EQUAL 1710,
    STRICT_NOTEQUAL 96, DIFFERENT 134, BOTH_REJECT 303, SURELOG_ONLY 75,
    SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1. The csv is byte-identical to
    the implementer's /tmp/r11u414_sw/svtests.csv, and the same 12 rows
    differ from the control.
  - byteverify against /tmp/intr11u412 (SELFCHECK=1, same-length roots):
    surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805; the
    selfcheck flags n-1 of n each (evidence/byteverify_law.txt).
  - canaries ok=52 / ok=16 changed=0; ctcan2 PASS on both (ok=58 with 1
    unknown, ok=2 with 6 unknown).
  - binary audit, fence-filtered by word (evidence/audit_law.txt):
    - surelog: 1523 of 1573 cmds.txt name the law binary, 0 another, 50 hold
      no slang line. 48 are Surelog-only rows; the CoresSweRV and
      CoresSweRVMP default rows match `slang-uhdm` only in the UVM path.
    - uhdm2rtlil: 1742 of 1742.
    - sv-tests: 2346 of 2346.
    - On the uhdm2rtlil count: two uhdm2rtlil paths hold a fenced name as a
      SUBSTRING but not as a word. tests/FENCED.md says such a longer name is
      a different test, so the implementer's 1742 is right and pass 412's
      verifier's 1740 removed two unfenced rows.
  - trace census: 12 trace files, all sv-tests rows, exactly the 12
    conversions with the law the implementer names on each
    (evidence/trace_census_law.txt). The corpus stages fire nothing; the
    sv-tests firings in the same sweep are the positive control.
    § structMemberDefault414 fires on no sv-tests row (it converts none; its
    target row default-value.sv stays DIFFERENT).
- The realtime prediction (the untraced makeTypespec site): a fence-filtered
  grep of all 2346 sv-tests sources finds the realtime keyword in 4 files.
  - chapter-6/6.12--realtime.sv is the conversion.
  - 20.3 and 20.4 use only `$realtime` and stay EQUAL.
  - 5.6.2--keyword_realtime is a should_fail BOTH_REJECT.
  - The bundled UVM library uses only the `$realtime` system call, never the
    type; the corpus rows were checked by the implementer (Tnoc's tvip
    interfaces) and byteverify reads 0 movers.

## The verified sweep

One full five-stage sweep on the verified binary (md5
565d1c303e0a972a4f760ee14d919044, workdir /tmp/v11u414_wV, R11U414_TRACE set),
run the same way as the law sweep. The verified sweep started on a quiet
machine after the master's pass 411 integration sweep ended.

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69, 0/0/0. The csv is identical to the
  control and to the law sweep.
- surelog: 480 + 0 / 474 + 0, 0/0/0. The csv differs from the control and from
  the law sweep only in the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0. downstream: 803 / 66 / 2 / 0.
  Both csvs are identical to the control.
- byteverify (SELFCHECK=1): verified against law and verified against the
  control both read surelog 0 of 962, uhdm2rtlil 0 of 1608 and downstream 0 of
  805 (evidence/byteverify_verified.txt).
- canaries ok=52 / ok=16 changed=0; both ctcan2 checks PASS.
- binary audit (evidence/audit_verified.txt):
  - surelog: 1523 of 1573 name the verified binary, 0 another, 50 with no
    slang line.
  - uhdm2rtlil: 1742 of 1742.
  - sv-tests: 2346 of 2346.
- trace census: the same 12 rows and laws as the law sweep. The refinements
  abstain on no sv-tests row: class_member_test_9's out-of-body formal still
  takes the twin.
- sv-tests:
  - The csv is BYTE-IDENTICAL to the law sweep's (and so to the
    implementer's).
  - Against the base golden (results/golden_svtests.csv at b94cdc046, the
    comparison of scripts/check_svtests.py applied to the written csv): 0
    regressions, 12 conversions, 0 changes
    (evidence/svtests_verified_vs_base_golden.txt).
  - The stage itself printed `regressions=3`. That reading is NOT a
    regression of this pass. Pass 411 (c64f995fd) landed in the main checkout
    while this sweep ran, and the stage reads the main tree's
    results/golden_svtests.csv, which pass 411 had just promoted:
    - chapter-8/8.8--typed_constructor.sv and 8.8--typed_constructor_param.sv,
      DIFFERENT -> EQUAL
    - generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_router_decoder_dor.sv,
      DIFFERENT -> STRICT_NOTEQUAL
    A binary built at b94cdc046 does not carry pass 411's ExprEmit laws, so
    it reads DIFFERENT there, exactly as the law sweep and the control did
    (evidence/svtests_stage_verified_vs_main_c64f995fd.txt). Pass 411 touches
    ExprEmit, ParamEmit, StmtEmit and EmitHelpers.h, and this patch touches
    none of them.
- Kept sv-tests databases (evidence/svtests_kept_strict_compare.txt): the 251
  databases both sweeps keep read STRICT_EQUAL under uhdm-strictcmp, law vs
  verified on 250, and on tnoc the raw walk reads STRICT_EQUAL at 2603030
  objects (uhdm-cmp 0 lines). The control vs the law reads the same on all 251.
  So the refinements move no sv-tests database and the law moves none outside
  its 12 conversions. (Byte comparison is meaningless here: the databases
  embed the sweep directory, and the packed encoding defeats a same-length
  path substitution.)

## Attack grid (cases/, 187 case dirs in 12 groups; drivers/grid.sh, vgrid.sh)

Every case's first line names the law it attacks. Upstream slang
(~/.local/bin/slang --single-unit) accepts every case. Six drafts that slang
rejects were dropped before counting: vb01, vb02, vb04 and vb10 (string into a
non-byte array), and vq01 and vq03 (rand in a packed struct or union).

Golden is Surelog v1.87 `-parse -nobuiltin -nocache -sv dut.sv`, cached per
case text under /tmp/v11u414_gold. Every exit code is recorded in the grid
lines.

Evidence files:
- evidence/grid.txt: round 1 and the VA distinguisher rounds, pristine and law.
- evidence/grid_round2.txt: round 2.
- evidence/vgrid.txt: verified, R11V414_OFF against the law's bytes, and
  R11U414_OFF against pristine's bytes.
- evidence/refinement_switches.txt: each refinement's own switch.
- evidence/away_*.txt: dump distance.
- evidence/downstream_cases.txt: downstream verdicts.

| group | law attacked | cases |
|---|---|---|
| VV | § varInitUintMask414 | vv01-vv22 (signed, int, bit, nets, multi-declarator, interface, generate, byte/shortint, operation, signed net, per-instance width, integer/64-bit, based, typedef, assign controls, output-port default, packed struct, packed array, tri/wand, program, var/unsigned, enum controls) |
| VR | § realtimeVarIsTime414 | vr01-vr18 (function/task formals, class property, parameters, ports, typedef, struct member, initialized, package, interface, generate, queue/dynamic, $unit typedef, procedural, class methods, cast, package function, fixed arrays) |
| VC | § classArrElemVar414 | vc01-vc17 (dynamic/queue, 2-D, package, generate, parameterized, interface class, class property, interface, initializer, two instances, associative, typedef'd array, typedef'd class, p::C, P #(), function local, program) |
| VH | § classChandlePropNoTs414 | vh01-vh06 (= null, static/local, package, array/queue, parameterized, typedef) |
| VW | § classWildcardIdxRefTs414 | vw01-vw06 (vector element, static/local, package, type parameter, method local, mixed) |
| VF | § unitFwdTypedefTwin414 | vf01-vf17 (struct, enum, vector, two forwards, class forward, alias of alias, union, unpacked array, unpacked struct, two names, `typedef struct t;`, string, package + $unit, repeated, parameterized class first, forward after definition, vector used twice) |
| VA | § clsTdArgAliasTwin414 | va01-va31 (task, module function, unsigned atoms, scalar bit, interface, directions, generate scope, logic controls, real/shortreal/time, default value, implicit second formal, parameterized class, inherited, DPI import, program, integer/longint/shortint, two module task formals, static/virtual, own scoped C::i_t, nested class, DPI task, DPI export before/after, out-of-body, interface class prototype, inherited + own, DPI + function, other class D::T in a module, interface and module same name) |
| VI | § ifaceClsScopedArgUnsup414 | vi01-vi11 (task, module function, ref/output, module return, NON-interface class control, struct typedef, pure virtual + implementation, package, input + implicit, return + task, out-of-body) |
| VS | § structMemberDefault414 | vs01-vs16 ($unit, package, based literals, class property, two declarators, unary minus, anonymous struct, overflow, nested, 'h10, function local, union, class-scope, x/z, two variables and an array, two instances) |
| VB | § arrStringInitAtElem414 | vb03, vb05-vb09, vb11-vb16 (generate, package, class, interface, shorter string, two instances, ascending, byte unsigned, dynamic, two declarators, empty, longer string) |
| VP | § classPropBinOpInit414 | vp01-vp24 (property operand, vector, static/const, nested, comparison, shift/power, based, parameter, longint/byte, package, unsigned/divide, logical/bitwise, $bits, enum operand, rand/local, real/string controls, unary operand, chained, overflow, statics, packed struct, unsized based, inherited, array pattern) |
| VQ | § structRandMemberVoid414 | vq02, vq04-vq09 (randc, package, class-scope, module-only, two declarators, package struct used by a class, rand second member) |

Pristine -> law -> verified (SE STRICT_EQUAL, SN STRICT_NOTEQUAL, NE NOT_EQUAL,
X4 exit 4 on all):

| transition | cases |
|---|---|
| NE -> SE -> SE | 116 |
| NE -> SN -> SE | 4 (va25, va26, va30, va31: verified) |
| SE -> SN -> SE | 4 (va13, va14, va21, va22: THE BREAK, fixed) |
| SE -> NE -> SE | 1 (va20: THE BREAK, fixed) |
| NE -> SN -> SN | 3 (vi08, vv17, vc15) |
| SE -> SE -> SE | 12 equal controls |
| SN -> SN -> SN | 1 (vc12) |
| NE -> NE -> NE | 43 |
| X4 -> X4 -> X4 | 3 (vh04, vh06, vc13: goal-1 faces, below) |

Pristine -> verified: 120 NOT_EQUAL -> STRICT_EQUAL, 3 NOT_EQUAL ->
STRICT_NOTEQUAL. No case leaves an equal status, and no exit code changes.

- Away census, normalized dump lines to golden on the 50 cases not
  STRICT_EQUAL under the verified binary: 29 toward, 21 at the same distance,
  0 away.
- Some cases grow in uhdm-cmp lines while their head moves later in the walk:
  vr04, vr05, vr11, vr13, vp14, vq04 and vq08. Each reads toward golden by
  dump.
- R11U414_OFF restores pristine's bytes and exit code on 187 of 187.
- Each group's own law switch restores pristine's bytes on 185 of 187. The
  other two need a second law's switch:
  - VI/vi05 also needs R11U414_ARGALIASTWIN_OFF; under the verified binary
    the twin no longer fires there.
  - VA/va24 also needs R11U414_IFCLSARG_OFF, for its `ic::T` implementation
    formal.
- R11V414_OFF gives the law's bytes on 187 of 187.
- Each refinement's own switch gives the law's bytes on the 13 cases it moves.

Downstream (scripts/downstream_uhdm2rtlil.py one(), the 92 class-free case
dirs, pristine -> law -> verified): 81 IDENTICAL on all three, 2 EQUIVALENT on
all three, and 9 EQUIVALENT -> IDENTICAL -> IDENTICAL (vb03, vb07, vq06, vr01,
vr04, vr06, vr08, vr09, vr18). None is worse.

## Residues (ranked; all wrong on pristine too, none moved away)

1. GOAL-1 FACES ON THIS GROUND (exit 4 where upstream slang accepts; pristine
   the same):
   - VH/vh04, a class property array of chandle `chandle h[2]; chandle q[$];`:
     `unsupported constructs: class array property element`.
   - VH/vh06, a class property typed by `typedef chandle ch_t;`:
     `typedef target: CHandleType`.
   - VC/vc13, a module typedef of a class handle used in an array,
     `typedef C c_t; c_t arr[2];`: `typedef target: ClassType`.
   No sv-tests row holds these shapes; the 75 SURELOG_ONLY rows are unchanged
   and all carry upstream slang diagnostics.
2. The formal twin's own residues:
   - A scoped own-class typedef `C::i_t`: golden writes an
     unsupported_typespec named `C::i_t` spanning the name (VA/va19).
   - An export written after its function (va29): the function listing order
     is wrong on all binaries.
   - A typedef in a generate scope (va07).
   - real, shortreal and time typedefs in a class (va09).
   - The implementer's TA/ta03, ta04 and ta05.
3. A bare forward typedef of a class first: golden lists a class_typespec twin
   at the forward declaration (VF/vf05, vf15).
   - Package and module-scope forward typedefs (vf13, ft08).
   - A forward typedef after its definition (vf16) or used twice (vf17):
     toward golden, not equal.
4. § varInitUintMask414 not reached:
   - interface and generate-scope variables (vv06, vv07)
   - program variables (vv20)
   - `logic unsigned` and `var logic` (vv21)
   - output-port defaults (vv16)
   - the anonymous packed struct's struct_typespec end column (vv17, endcol)
5. realtime:
   - parameters (vr03)
   - generate-scope variables (vr10)
   - typedefs of realtime (vr05, vr13)
   - realtime queues and dynamic arrays (vr11)
   - class method returns (vr15)
   - port connections (vr04: golden lists no elaborated variable for the
     port)
   All are toward golden or unchanged.
6. The class-property binary-op initializer: comparisons (vp05), unsized based
   operands (vp22), overflow (vp19), enum operands (vp14), real and string
   (vp16).
7. `rand` struct members:
   - a randc member and a class-scope struct, where golden's UH0700
     unsupported expression is not written (vq02, vq05)
   - a package struct (vq04, vq08)
   - two declarators (vq07)
   - a rand second member (vq09)
8. String initializers of byte arrays in a generate block, package or class
   (vb03, vb05, vb06), and dynamic byte arrays (vb13).
9. Struct member defaults: unary minus (vs06), unions (vs12), parameters and
   operations (the implementer's SD/sd01, sd02).
10. Class handle arrays:
    - typed by an interface class (vc06)
    - with an initializer (vc09)
    - as a function local (vc16)
    - `P #()`, where the class_typespec ends at the name in golden (vc15,
      endcol)
    - a typedef of an unpacked class array (vc12, type)
11. The return variable span of a package class method returning `ic::T`
    (vi08, line).
12. The implementer's residues (its README items 1-10) stand as written.

## Sister-ground faces (reported, not written)

The implementer's list stands:
- ExprEmit/StmtEmit:
  - 8.12 shallow copy
  - `q = {}`
  - out-of-body reference naming
  - the 8.8 typed-constructor wire
- EmitHelpers makeReturnVar / StmtEmit: realtime returns and locals.
- ParamEmit: class_test_49.

No new sister-ground face was found by this grid.

## Process

- Machine use:
  - The law sweep started after the sister verifier v11u411's sweep ended.
  - The verified sweep started after the master's pass 411 integration
    sweep ended.
  - The grid runs (single-process, small cases) and two -j 2 rebuilds of one
    translation unit each ran while the sister verifier's corpus and sv-tests
    stages were live. The 92-case downstream run (three concurrent one()
    loops) overlapped the first minute of the master's integration sweep.
- Builds: the law binary once, then two verified builds (the second adds the
  forward-typedef refinement found by the round-2 grid).
- Sweeps: one full sweep on the law binary and one on the final verified
  binary, which is the budget's allowance for a refinement.
- No other agent's process was touched. Once, my own pkill matched only its
  own shell (a v11u414-only pattern).
- THE FENCE SLIP: while looking for the fence line, a `sed -n 10,30p` of
  tests/FENCED.md printed its header table, which spells the four names, to
  this terminal. No fenced source, database or command record was opened or
  run. The list was then read from tools/probe/r11u107repro/canaudit.sh into
  a file without printing, and every tree-wide list (the sv-tests grep, the
  cmds.txt audit) was filtered on it by word first.
- The implementer's r11u414repro README and 14 case first lines are corrected
  in place, as stated above.
