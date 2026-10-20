# v11u420 — adversarial verification of r11u420 (module/type ground, pass 420)

Verdict: **VERIFIED, no production refinement.** The verified patch carries the
implementer's two source files (src/ModuleEmit.cpp, src/UhdmExporter.cpp)
byte-identical. It adds this directory, the regenerated tests/LAWS.md, and one
corrected sentence in tools/probe/r11u420repro/README.md (see "Corrections").
There is no § ...420v law and no R11V420 switch.

## Binaries

- Pristine: the implementer's frozen base build, md5
  a66aad5a9b59d95c047a890e200e636b. That equals the expected base binary, so no
  pristine build was made, per the budget.
- Law: rebuilt once in /tmp/wt_v11u420 from /tmp/r11u420.patch on a fresh
  ff652a33 (cmake -j 2), md5 862f7c5f9460bda30054b8b0c71def1e. That equals the
  implementer's final binary. It is frozen at /tmp/v11u420_bin/law.
- The patch applies cleanly on a fresh ff652a33.
- `python3 scripts/law_index.py --check` reads "law index current" on the
  implementer's patch alone.
- No-header audit of the added lines: no src/R*.h, no getenv, no reader
  function. All 13 switches go through `lawOn(420, "R11U420_<LAW>_OFF")`.

## One full five-stage sweep on the law binary

The sweep is drivers/runsweep.sh. It waits for three quiet readings first.
Its first launch never started a stage: the wait loop matched its own
command line, so I stopped it by its PID and relaunched it with the pattern
fixed. The corpus stages ran from the worktree. The sv-tests stage ran
through the main tree's scripts/check_svtests.py, read-only, with
`--baseline` set to the base golden. Evidence: evidence/sweep_corpus.log and
evidence/sweep_svtests.log.

**Corpus stages**

| stage | result | regressions / conversions / changes |
|---|---|---|
| probe | EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087; csv byte-identical to the control /tmp/intr11u418/probe.csv | 0 / 0 / 0 |
| surelog | default CMP_EQUAL 480, testflags 474; csv equal to the control except the two LowMem log-path texts (environment) | 0 / 0 / 0 |
| uhdm2rtlil | 803 / 1 / 67 in both modes; csv byte-identical to the control | 0 / 0 / 0 |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; csv byte-identical to the control | — |

- The corpus run exits 1 only on the law-index staleness that this
  directory's new cases cause. It is regenerated in the verified patch.
- **byteverify** against the master's control (SELFCHECK=1): surelog 0 of
  962, uhdm2rtlil 0 of 1608, downstream 0 of 805. The self-checks flag 961,
  1607 and 804 (evidence/byteverify.txt).
- **Canaries:** ok=52 on surelog and ok=16 on uhdm2rtlil, 0 changed.
  - ctcan2 with EXPECT_UNKNOWN=1 on surelog: ok=58, PASS.
  - ctcan2 with EXPECT_UNKNOWN=6 on uhdm2rtlil: ok=2, PASS.
- **Binary audit** of cmds.txt, fence-filtered: surelog 1523 of 1573 name
  /tmp/v11u420_bin/law; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.
- **Trace census** (R11U420_TRACE on the whole sweep):
  - § clockedSeqEventSpanBare420 fires on SequenceInst default and testflags.
  - § pkgLateTsNetCapture420 fires on the probe case
    r10v148repro/v148_g_corpus.
  - Nothing fires in uhdm2rtlil or downstream.
  - Both firings leave the databases byte-identical, as byteverify and the
    probe csv show. This reproduces the implementer's census.

**sv-tests stage:** regressions=0, conversions=18, changes=0.

- EQUAL 1840, STRICT_NOTEQUAL 11, DIFFERENT 89, SURELOG_ONLY 75, BOTH_REJECT
  303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, of 2346.
- The csv is byte-identical to the implementer's /tmp/r11u420_sw/svtests.csv
  on all 2346 rows. It differs from the control only in the 18 converted rows.
- All 18 go DIFFERENT -> EQUAL:
  - chapter-16:
    - 16.2: assert, assert0, assert-final, assume
    - 16.7: sequence, sequence-and, sequence-and-range, sequence-or
    - 16.10: property-local-var, sequence-local-var
    - 16.11: sequence-subroutine
    - 16.12: property, property-prec
    - 16.13: sequence-multiclock
    - 16.14: assume-property
  - chapter-5/5.10-structure-replication.sv
  - chapter-8/8.24--out_of_block_methods.sv
  - generated/hdlconv_std2017/hdlconvertor_std2017_p488.sv
- The laws fire on 151 sv-tests rows: 102 EQUAL (18 of them the conversions),
  36 DIFFERENT, 8 STRICT_NOTEQUAL and 5 SLANG_ONLY. This is the implementer's
  set.

**Away census** (drivers/away.sh) over the 49 firing rows that are not EQUAL:
47 toward and 2 away, identical line for line to the implementer's
evidence/away_census.txt.

- The two away rows are generated/easyUVM/top and
  uvm-examples/uvm_many_to_one, each one line away (502824 -> 502825 and
  802843 -> 802844).
- On easyUVM/top the control-vs-law dump diff is a single line,
  `\_array_typespec:` in the weakly-referenced tail. Golden lists 227 such
  tail lines, the control 168 and the law 167. The tail is outside the design
  walk: uhdm-cmp reads 659635 lines on both binaries, and the row is
  DIFFERENT on both.
- This is not a design object moving away, and it is not a break.

**Determinism:** three concurrent draws per row, all in one working
directory, give one hash in 3 of 3 for each row:
- chapter-16/16.2--assert-uvm.sv (the loop-variable capture and its minted
  wire)
- 16.10--property-local-var-uvm.sv (the $unit wire order and the
  continuous-assignment initializer)
- chapter-8/8.24--out_of_block_methods.sv

A first draw used three different working directories. It read three
hashes, but only because each database records the path of the working
directory's builtin.sv. It is not a determinism finding.

## The implementer's grid, reproduced

Driver: drivers/grid.sh. Evidence: evidence/impl_grid_reproduced.txt.

- All 84 case dirs reproduce line for line: exit code, uhdm-cmp line count
  and strict verdict.
  - 55 go to STRICT_EQUAL: 47 from NOT_EQUAL and 8 from STRICT_NOTEQUAL.
  - 18 STRICT_EQUAL controls are kept.
  - 11 are unequal on both binaries.
- R11U420_OFF restores pristine's bytes and exit code on 84 of 84.
- Each case's own switch restores them on 69. The other 15 are SA and SQ
  cases where the and/or, parenthesis and property laws, or the pair and
  clocking laws, fire together.

## Earlier-pass census

drivers/census.sh, evidence/earlier_pass_census.txt.

**Scope:** all 2463 fence-filtered case dirs of passes 401 to 418 (r11u and
v11u). The path list was filtered on the fence list before any file was
opened. Each dir ran on both binaries.

- 2447 are byte-identical with the same exit code.
- 16 move bytes, none moves exit code, and none moves away from golden:

| result | cases |
|---|---|
| NOT_EQUAL -> STRICT_EQUAL | r11u402 OM/om03_module_class (§ modOutOfBodyMethodIsModuleTf420), r11u402 US/us04_init, v11u403 VI/vi06_assoc_array, v11u406 VQ/vq10_or_concat, vq22_prop_conseq_leading_two_ctl |
| NOT_EQUAL -> STRICT_NOTEQUAL (line) | r11u410 OT/ot03, r11u412 OR/or05 |
| NOT_EQUAL and closer | r11u412 US/us04 (cmp 824 -> 28), v11u412 VN/vn02 (cmp 30 -> 17) |
| still unequal, one dump line closer | r11u403 FE/fe05, v11u403 VI/vi02 |
| STRICT_EQUAL on both, one weakly-referenced array_typespec fewer in the tail | r11u403 FE/fe01, fe03, v11u403 VI/vi01, vi03, vi04 |

- On fe03 the line diff reads 20 -> 21, but the multiset distance to golden
  is 10 -> 9 (toward). Golden lists 3 tail array_typespecs, pristine 5 and
  the law 4.
- The capture there is the importing top's copy of the package variable q,
  with the same content.

## Attack grid: 124 fresh case dirs

drivers/grid.sh, evidence/attack_grid.txt. The cases are in VA, VC, VF, VO,
VP, VS, VT and VU. Upstream slang (~/.local/bin/slang dut.sv --single-unit)
accepts every one. One drafted shape, a module holding an out-of-body method
instantiated twice, was rejected by upstream slang and dropped.

| pristine -> law | cases |
|---|---|
| NOT_EQUAL -> STRICT_EQUAL | 49 |
| STRICT_NOTEQUAL -> STRICT_EQUAL | 15 |
| NOT_EQUAL -> STRICT_NOTEQUAL | 3 (VA/va04 col, VA/va05 fullname, VS/vs34 col) |
| STRICT_EQUAL kept (byte-identical) | 11 |
| STRICT_NOTEQUAL kept | 3 (vc08 and va06 byte-identical; vc10 from 2 differing objects to 1) |
| NOT_EQUAL on both | 43 |

- Of the 43 still NOT_EQUAL: 29 are toward golden by uhdm-cmp count or dump
  distance, 11 are at pristine's bytes, and 3 sit at the same dump distance
  (see below).
- Every exit code is unchanged: 122 exit 0 on both, and VS/vs06 and vs32 exit
  4 on both (a repetition `(a ##1 b)[*2]` and first_match(...): 'unsupported
  shape', not this pass's).
- R11U420_OFF restores pristine's bytes and exit code on 124 of 124. Each
  case's own switch restores them on 111. The other 13 are VS cases where the
  and/or, parenthesis or property law co-fires with the case's law.
- **Downstream** on the 96 class- and package-free cases (drivers/ds.py,
  evidence/downstream_{pristine,law}.txt): 19 EQUIVALENT -> IDENTICAL, 10
  DIVERGENT -> IDENTICAL, none worse.
- The three NOT_EQUAL cases at the same dump distance:
  - VS/vs12 (inline cover property) and vs23 (cover sequence): only the
    operation's type moves (79 -> 26, 80 -> 27), where golden builds a
    different shape.
  - VU/vu06: the $unit wire moved past a later sequence-local wire. The
    order reads k, l, cnt against golden's l, cnt, k, two pairs wrong as on
    pristine. This is the implementer's UL/ul09 residue, not a break.

**No pristine-right -> law-wrong case was found** on legal SV:
- No probe case or corpus row leaves EQUAL.
- No downstream verdict worsens.
- No strict cell moves away.
- No sv-tests row regresses.

So no production change was made.

### Cases by law

| law | cases |
|---|---|
| § ansiNoDirNetPortUntyped420 | VP vp01-vp16 |
| § contAssignVarInitRhsShared420 | VC vc01-vc15 |
| § pkgLateTsNetCapture420 | VF vf01-vf05, vf07-vf11 |
| § pkgLateTsLoopVarCapture420 | VF vf06, vf12, vf13 |
| § seqAndOrLogOp420 | VS vs01-vs03, vs05, vs12, vs13, vs18, vs23, vs24, vs30, vs32, vs33 |
| § propAndOrUnparented420 | VS vs04, vs14, vs15, vs20, vs21, vs28, vs34 |
| § assertBinParenSpanInner420 | VS vs06, vs17, vs27 |
| § seqLeadDelayPairUnary420 | VS vs07-vs09, vs19, vs25, vs26, vs35 |
| § clockedSeqEventSpanBare420 | VS vs10, vs11, vs16, vs22, vs29, vs31, vs36 |
| § modOutOfBodyMethodIsModuleTf420 | VO vo01-vo03, vo05-vo16 |
| § unpackedStructVarPosInit420 | VT vt01-vt15 |
| § arrayBcastConcatActual420 | VA va01-va08 |
| § unitVarNetSourceOrder420 | VU vu01-vu06 |

## Residues found (all wrong on pristine too; ranked)

1. **§ ansiNoDirNetPortUntyped420 after a port with a direction.**
   - Cases: VP/vp01 `input logic a, wire [3:0] b`, vp08 `input a, wire
     [3:0] b, c`, vp09 `output y, wire [1:0] b`, vp16.
   - Golden gives the direction-less net port the PREVIOUS port's type: its
     logic_typespec (vp01: 2:18-2:23, the `logic` of a), and net type 36 in
     vp01. The law drops the typespec. Pristine wrote the port's own
     `[3:0]` typespec.
   - Neither is right. The law is closer by uhdm-cmp (32 -> 30, 30 -> 17)
     and turns downstream EQUIVALENT into IDENTICAL, because golden's
     inherited type is 1 bit wide.
   - The face for the next pass on this ground: a direction-less port
     inherits the previous port's direction AND typespec.
2. **The law does not reach some shapes** (pristine's bytes or closer):
   - § ansiNoDirNetPortUntyped420 on interface headers (VP/vp14) and on
     instances inside a generate block (vp07).
   - § unpackedStructVarPosInit420 in interfaces (VT/vt13) and generate
     blocks (vt04).
   - § contAssignVarInitRhsShared420 inside a generate block (VC/vc08).
   - § arrayBcastConcatActual420 on positional connections (VA/va03) and in
     generate blocks (va06).
   - § pkgLateTsNetCapture420 on class-property foreach in a package class
     whose importing module holds only a variable (VF/vf05), multi-dimension
     foreach (vf04), and module arrays (vf07).
3. **The late-bound wire order beyond the $unit wire:** VU/vu06 (two
   assertion locals around the $unit reference) and vu05 (two $unit
   variables). This is the implementer's UL/ul09 and ul10.
4. **Smaller remaining faces:**
   - Out-of-body constructors and methods returning the class type are closer
     but unequal (VO/vo09 cmp 332 -> 115, vo16 332 -> 17). this.x (vo12) is
     at 17.
   - Mixed-member unpacked struct patterns: VT/vt01, vt09, vt12, vt15 at 28.
   - VC/vc12: two assignments, one reading `c + 1`.
5. **The implementer's residues stand as listed in its README:**
   - 16.12 property-interface ×2 and 16.17 expect (the sister's).
   - FN/fn09, utd-sv, UL/ul09 and ul10, CR/cr07 and cr08, ST/st03 and st07.
   - IA/ia03, the goal-1 replication connection.

## Corrections to the implementer's report

- Its README said the uhdm-cmp line counts were unchanged on every firing
  row except utd-sv. Its own away census shows three more:
  - 16.12--property-interface-uvm and -prec-uvm: 116 -> 659513.
  - 16.17--expect-uvm: 116 -> 217.
- On all three the head moved LATER in the walk, and the multiset distance
  reads toward:
  - 16.12: from the topPackages uvm_pkg foreach typespec (golden 64:11) to
    the interface_inst's import parameter copies in allInterfaces,
    ParamEmit's face.
  - 16.17: to the expect statement's action block in topModules, StmtEmit's
    face.
- UHDM's design Compare walks allPackages, topPackages, allClasses,
  allInterfaces, ..., topModules, in that order.
- The growth is allowed under caution (c). The sentence is corrected in
  tools/probe/r11u420repro/README.md.

## Process

- One law build (-j 2) and one full five-stage sweep, on a quiet machine. No
  pristine build, no pristine sweep and no refinement, so no second sweep.
- Grids, downstream runs, the earlier-pass census and the determinism draws
  ran only after the sweep had ended.
- The fence list was read by a program from canaudit.sh's FENCED= line into
  /tmp/v11u420_fenced.txt and was never printed. Every tree-wide list was
  filtered on it before any file was opened. No fenced test was named, opened
  or run.
- My slip, which affected no measurement: the sweep launcher's first wait
  loop matched its own command line. I stopped it by its own PID before any
  stage started.
- No other agent's process was touched.
