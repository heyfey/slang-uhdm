# v11u426 — adversarial verification of r11u426 (module/type ground, pass 426)

Base 8dc2a0acb.  Implementer's patch /tmp/r11u426.patch (md5
ffabb04d590d3816821b3fb7ef7f400c) applied clean on a fresh worktree at the
base.  **Verdict: CONFIRMED, no production refinement.**  This patch carries
the implementer's four source files (src/TypeEmit.cpp, src/UhdmExporter.cpp,
src/TaskFuncEmit.cpp, src/ModuleEmit.cpp) byte-identical, plus this directory
and the regenerated tests/LAWS.md.  No fresh case on legal SV found a place
where pristine was right and the law is wrong.

## Binaries (frozen before any measurement)
- law: rebuilt once in /tmp/wt_v11u426 (`-j 2`, SYSTEM_DEPS), frozen at
  /tmp/v11u426_bin/law, md5 afc4313dcda1982a869079fe4ae93484.  This equals
  the implementer's law6.  It reports slang 12.0.0+545f88b2e and UHDM 1.87.
- pristine: no pristine build, as the budget asks.  The implementer's frozen
  base build was copied to /tmp/v11u426_bin/pristine (md5
  c623a2128527ff4453411543a280fc43, the brief's main-tree md5) and used only
  for case runs.  The pristine corpus reading is the master's control sweep
  /tmp/intr11u424.  Its probe, downstream and svtests csvs are byte-equal to
  the committed results at the base.  Its surelog and uhdm2rtlil csvs differ
  only in row order and source-path text, not in status.

## The one sweep (law binary; drivers/fullsweep.sh; evidence/fullsweep_law.log)
The four corpus stages ran from the worktree with `tests/sweep.sh --jobs 3
--workdir /tmp/v11u426law`.  The sv-tests stage ran through the main tree's
scripts/check_svtests.py, read-only, with the baseline at the worktree's
results/golden_svtests.csv.  scripts/ is unchanged between the base and the
main tree's HEAD.  R11U426_TRACE was on for the whole sweep.

| stage | result |
|---|---|
| probe | EQUAL 4018 + STRICT_NOTEQUAL 69; regressions=0 conversions=0 changes=0; csv identical to the control |
| surelog | default CMP_EQUAL 480, testflags 474; 0/0/0; csv equal to the control except the two LowMem log-path texts |
| uhdm2rtlil | 803 / 1 / 67 in both modes; 0/0/0; csv identical to the control |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0; csv identical to the control |
| sv-tests | regressions=0 **conversions=2** changes=0: EQUAL 1882, STRICT_NOTEQUAL 2, DIFFERENT 56, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346 |

The corpus stage exited 0; the law index was regenerated before launch.

sv-tests conversions (evidence/svtests_law_vs_control.diff; these are the only
two lines that differ from the control csv):
- generic/typedef/typedef_test_9.sv: `DIFFERENT,decompile:,` -> `EQUAL,,equal`,
  through § unitTdBoundUnitParamFold426.
- generated/hdlconv_std2017/hdlconvertor_std2017_p179.sv:
  `DIFFERENT,decompile:,` -> `EQUAL,,equal`, through
  § namedTypeLocalTfItemOutsideClass426.

The sv-tests csv is byte-identical to the implementer's
(/tmp/r11u426wd/svtests.csv) on all 2346 rows.  Both rows were also rerun
alone with scripts/svtests/svtests_matrix.py on both binaries
(evidence/rows_pristine.csv, rows_law.csv).
- Pristine reads NOT_EQUAL stage1 on both.  On typedef_test_9 golden has a
  constant where ours has `ref_obj my_array_t::k` (19:28).  On p179 golden
  lists `class_var xtnd1` on the function where ours lists it under a begin.
- Law reads EQUAL / equal on both.

Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law workdir
against the control /tmp/intr11u424; evidence/byteverify_law_vs_control.txt):
surelog 0 of 962 (selfcheck 961/962), uhdm2rtlil 0 of 1608 (1607/1608) and
downstream 0 of 805 (804/805).  No corpus byte mover, as predicted.

Canaries: canaries.sh ok=52 changed=0 (surelog) and ok=16 changed=0
(uhdm2rtlil).  ctcan2.sh PASS on both: EXPECT_UNKNOWN=1 gives ok=58 and
EXPECT_UNKNOWN=6 gives ok=2.

Binary audit, fence-filtered: every slang line of the surelog cmds.txt files
names /tmp/v11u426_bin/law, 1523 of 1573; the other 50 hold only a Surelog
line.  uhdm2rtlil: 1740 of 1740.  sv-tests: the stage's cmds.txt name the law
binary.

Trace census (evidence/trace_census.txt): no corpus row and no probe case fires
any law of this pass.  The positive control is 23 sv-tests rows that do fire:
- p179: § namedTypeLocalTfItemOutsideClass426, 3 firings.
- typedef_test_9: § unitTdBoundUnitParamFold426, 2 firings.
- **21** generated/uvm-examples rows: § enumLitArithImportCloneFolds426.  17
  of them are DIFFERENT and 4 are SLANG_ONLY (uvm_overriding, uvm_slave_agent,
  uvm_slave_agent_multi_seq_item, uvm_wait_for_signal).

The implementer's summary says "20 uvm-examples rows (16 DIFFERENT, 4
SLANG_ONLY)".  Its own evidence/trace_census.txt lists 21, which is what this
sweep reads: a counting slip in the summary only.

Away census on those 21 rows (evidence/away_census_cmp_lines.txt): uhdm-cmp
line counts against the cached golden are identical between the control
database and the law database on all 17 DIFFERENT rows (for example
uvm_messaging_example 2142426 -> 2142426).  On the 4 SLANG_ONLY rows the
count of all of ours is unchanged too.

On uvm_messaging_example the law changes, against the control, only the
re-listed enum constants:
- `INT:65536 / 1<<16`, `INT:131072 / 1<<17` and `INT:262144 / 1<<18` become
  `UINT:… / <digits>`.
- After the law, golden holds 0 `1<<16` decompiles and ours 0; before, ours
  held 5.

The distance measures disagree, so both are reported:
- The multiset distance of the path-normalized dumps to golden falls
  137513 -> 137453 lines (toward golden).
- A plain `diff` line count rises 373655 -> 374357.  That is diff-alignment
  noise on a 1.9M-line dump.
- The implementer's 379191 -> 378037 is a different normalization and was
  not reproduced bit for bit.

§ ifcProcCallArgNoTs424's new trace was checked by its own positive control.
On tools/probe/r11u424repro/cases/IA/ia04 with R11U424_TRACE set, it logs one
`ifcProcCallArgNoTs424` line (next to `ifcConcAssertListed424`), and the
database is byte-identical to pristine's.

## The implementer's grid, reproduced (evidence/grid_impl_repro.txt)
All 54 case dirs, rerun with this pass's drivers and a fresh golden cache,
match the implementer's evidence/grid_law6.txt on every field except the md5.
Matching fields: exit code, uhdm-cmp line count, strict verdict, R11U426_OFF ==
pristine and the own-switch result.  The md5s differ only because the
databases carry the worktree path.

That gives:
- 37 NOT_EQUAL -> STRICT_EQUAL and 1 STRICT_NOTEQUAL -> STRICT_EQUAL.
- 4 exit 4 -> STRICT_EQUAL and 1 exit 4 -> STRICT_NOTEQUAL.
- 1 NOT_EQUAL -> STRICT_NOTEQUAL and 6 controls byte-identical.
- 4 unequal on both binaries: CV/cv18 dump distance 26 -> 19, AC/ac04 still
  exit 4 with distance 129 -> 52, and UR/ur08 and AC/ac05 byte-identical.
- R11U426_OFF gives pristine on 54 of 54.  The own switch gives pristine on
  52; ac06 and ur21 also need the bound law's switch.

## Attack grid (72 fresh case dirs; evidence/grid_attack.txt, dumpdist_attack.txt)
Every case is accepted by upstream slang (~/.local/bin/slang dut.sv
--single-unit).  One draft, a task prototype mismatch, was rejected by slang
and deleted.  Every golden reads Surelog `[ERROR] : 0`.  Goldens were built
with Surelog v1.87 `-parse -nobuiltin -nocache -sv` (drivers/run1.sh, keyed
on the full path after tools/probe/).  "dd" is the path-normalized uhdm-dump
diff line count against golden (drivers/dd.sh).

Totals, pristine -> law:
- 27 NOT_EQUAL -> STRICT_EQUAL.
- 2 NOT_EQUAL -> STRICT_NOTEQUAL.
- 1 exit 4 -> STRICT_NOTEQUAL.
- 8 exit 4 -> exit 0 NOT_EQUAL, every one closer by dd.
- 1 exit 4 on both.
- 2 STRICT_EQUAL controls, byte-identical.
- 31 NOT_EQUAL on both: 7 byte-identical, 23 closer by dd, and VN/vn05 at
  dd 101 -> 102 (see below).

R11U426_OFF restores pristine's bytes and exit code on 72 of 72.  Each case's
own switch restores pristine on 71; VA/va06 also needs the bound law's switch,
since its `[k]` reads a `$unit` parameter.

**No case went from right on pristine to wrong on the law.**

Downstream, on the 105 class-free case dirs (evidence/downstream_cases_*.txt
and downstream_cases_batch2.txt; uhdm2rtlil's own Surelog in the Surelog
lane):
- In the implementer's 38 (it counts 36): UR/ur05 and AC/ac03 go
  EQUIVALENT -> IDENTICAL.
- In this pass's 67:
  - EQUIVALENT -> IDENTICAL: va01, va02, va04, va06, va08, va11, vb01, vb04,
    vb05, vb14, vb17, vb24, vb25 and vn14.
  - STATUS_DIFF -> IDENTICAL: va07 and va10.
  - STATUS_DIFF on both: vb23.
- Every other case stays IDENTICAL.  None got worse.

### Per law (case dirs under cases/, each first line `// § <law>`)

**§ unitTdBoundUnitParamFold426** (R11U426_UNITTDBOUND_OFF; cases VB vb01-vb28):
- To STRICT_EQUAL (13): vb01 (`parameter int k`), vb02 (`k+1`), vb03
  (`k*2-1`), vb04 (a `logic [3:0]` parameter in a packed and an unpacked
  bound), vb05 (`j = k + 1`), vb10 (`[0:k-3]`, negative), vb14 (`int unsigned`
  in a packed and an unpacked bound), vb17 (`j-k`, `k+j`), vb20 (`int k` in
  `k+1`), vb21 (`k+k`, `k*k`) and vb25 (`int signed` plus `bit [7:0]`, packed
  and unpacked `[k:j]`).
- To STRICT_NOTEQUAL (2):
  - vb22 reads endcol.  The difference is the `$unit` parameter's own `-2`
    span (2:15-16 against ours 2:15-17), already wrong on pristine; the law's
    folded bound is right.
  - vb24 reads file(8): a `$unit` parameter declared in an INCLUDED file.  The
    folded bound (a clone of the parameter's value) keeps the include file's
    VpiFile (inc.svh), where golden writes the use file (dut.sv) at the same
    line and column.  The cause: cloneUnitParamRhs copies the file and setLoc
    only stamps an empty file.  Pristine was NOT_EQUAL stage1 here, so this is
    not a break.  It is a law-written wrong field and is filed as residue 1.
- Closer but unequal: vb07 (a packed bound in a typedef that also has
  unpacked dims), vb11 (parenthesized packed `(W)` with ports), vb12 (the
  parenthesized size form `[(k)]`, which the law does not reach: golden
  constant at 3:33-34 size 32 with the typespec, ours 3:32-35 size 64), vb16,
  vb18 (alias of a packed typedef), vb23 (`[0:k-1]` port, downstream
  STATUS_DIFF on both), vb26, vb27 (an element typedef plus a per-variable
  `[k:0]`) and vb28 (the size form `[k-1]`).
- Byte-identical, not reached: vb06 (`[k-1:0]` packed, STRICT_EQUAL control),
  vb08 (a packed struct member bound), vb09 (an enum base `logic [k:0]`), vb13
  (a module typedef over a `$unit` parameter), vb15 (a packed union member)
  and vb19 (the parameter in another command-line file: the law abstains, as
  stated).

**§ unitFixedArrTdAliasClone426** (R11U426_UNITARRTDALIAS_OFF; cases VA
va01-va11), the goal-1 shape:
- 9 of 11 go from exit 4 to exit 0, every one closer by dd:
  - va04 (a `$unit` function argument typed by the alias) reads
    STRICT_NOTEQUAL line.  Golden binds a per-use array_typespec at the
    argument, 4:18-22, where ours binds the shared clone at 2:9-21.
  - va01 (a module port), va02 (multi-dim `[2][3]`), va03 (a struct member),
    va06 (a `[k]` bound), va07 and va10 (always_comb and cont_assign uses),
    va08 (two aliases) and va11 (an unpacked array of the alias) read NOT_EQUAL.
- va05 (the alias declared in a module) and va09 (the alias of a package
  array typedef, still exit 4) are not reached, byte-identical.
- Downstream: va07 and va10 go STATUS_DIFF -> IDENTICAL; va01, va02, va04,
  va06, va08 and va11 go EQUIVALENT -> IDENTICAL.

**§ namedTypeLocalTfItemOutsideClass426** (R11U426_NAMEDTFITEM_OFF; cases VN
vn01-vn21, vn23):
- To STRICT_EQUAL (16), each with the path-normalized dump at the header
  line alone, so vpiAutomatic agrees with golden too: vn02 (`p::box_t`), vn03
  (an unpacked array of a struct typedef), vn04 (a function with a body
  `input`), vn06 (synthesizable swap, downstream IDENTICAL), vn07 (`function
  static`), vn08 (two declarators plus a builtin local), vn09 (an imported
  typedef), vn12 (enum and enum array locals), vn13 (a `$unit` function with an
  initialized class local), vn14 (a module task with body ports, downstream
  EQUIVALENT -> IDENTICAL), vn15 (a module typedef in an automatic function),
  vn16 (an interface instantiated twice with a modport import), vn17 (a child
  module instantiated twice), vn18 (a function and a task with body ports),
  vn19 (an enum-returning function in always_ff) and vn23 (a module function
  with a class local).
- Closer, NOT_EQUAL:
  - vn01: a type-parameter-typed local `T x;`, dd 26 -> 19.
  - vn10: an interface generate-for function, dd 32 -> 25.
  - vn21: a `$unit` OUT-OF-BODY class method, uhdm-cmp 58 -> 31 and dd
    44 -> 37.  Golden places that local at its data type with vpiAutomatic
    under the function, which is the law's model, so the law reaching this
    class method is right.
- Unchanged: vn11 (a local of a named begin block, a STRICT_EQUAL control) and
  vn20 (a module-scope out-of-body class method, byte-identical).
- vn05 (a `$unit` task with a body `input` and a class local) moves dd
  101 -> 102 at the same uhdm-cmp count (60).  Golden lists NO `task t` at all
  (its call is a func_call); the changed cells (the local's span, its parent
  and vpiAutomatic) sit inside an object golden does not have, so this is not
  movement away from a golden cell.  The face is the `$unit` task listing,
  wrong on pristine too.

**§ enumLitArithImportCloneFolds426** (R11U426_ENUMCLONEFOLD_OFF; cases VE
ve01-ve11):
- Every enum constant the law changes now reads exactly golden's cells: the
  value, decompile and size lines vanish from the dump diff.  This covers
  - `logic [7:0]` with `1<<3`, an implicit successor and `2*3` (ve01);
  - `bit [31:0]` with `1<<31` (ve02);
  - `bit [63:0]` with `1<<40` and `64'd1 << 33` (ve03);
  - `7 - 9` (ve04);
  - `export p::*` (ve05);
  - `A << 1` beside `1<<4` (ve06);
  - `4'h1 << 2` and `16'hff >> 2` (ve07);
  - two importing packages (ve08);
  - `1 + 2 + 3`, `(10 - 3)` and `2 * (3 + 1)` (ve09);
  - `bit signed [15:0]` (ve10);
  - `logic [2:0]` with `3'd1 << 1` and `1+1+1+1` (ve11).
- All 11 stay NOT_EQUAL at the same uhdm-cmp head (36 lines; 184 on ve08; ve09
  36 -> 32).  That head is the DEFINITION listing's pairing (golden `1 << 31`
  size 95 against ours), which is § enumConstLitArithRender188's listing and
  not this law's clone.
- dd falls on all 11: 18 -> 6, 8 -> 2, 10 -> 2, 22 -> 16, 8 -> 2, 18 -> 12,
  18 -> 6, 8 -> 2, 22 -> 14, 20 -> 14, 18 -> 6.
- Not reached (wrong on both): a unary minus `-(1<<2)` (ve04, golden
  `INT:-4`).

## Residues (ranked; every one wrong on pristine too)
1. § unitTdBoundUnitParamFold426's folded bound keeps the parameter's VpiFile
   when the `$unit` parameter is declared in an included file (VB/vb24,
   STRICT_NOTEQUAL file(8)).  Golden stamps the use site's file.  The fix is
   to stamp `fullFilePath(<bound>.start())` on the clone before setLoc, at the
   law's three clone sites in TypeEmit.  It was not written: it fires on no
   corpus, probe or sv-tests row, and it is not a break.
2. The `$unit` parameter fold not reached:
   - a parenthesized size form `[(k)]` (vb12);
   - a packed bound in a typedef that also has unpacked dims (vb07);
   - packed struct, union and enum-base bounds (vb08, vb15, vb09);
   - a module typedef over a `$unit` parameter (vb13; ur08 is the module
     parameter case);
   - a parameter in another command-line file (vb19);
   - the `[0:k-1]` port (vb23, downstream STATUS_DIFF on both).
3. The fixed-array alias: per-use argument typespecs (va04), a module-scope
   alias (va05), a package array typedef alias still exiting 4 (va09) and the
   implementer's ac04 and ac05.
4. The named-type local: the `$unit` task listing golden omits (vn05), the
   type-parameter local (vn01), interface generate-scope functions (vn10), a
   module-scope out-of-body class method (vn20) and the program face (cv18).
5. The enum: the definition listing's pairing on a package enum re-listed by
   an importing package (the 36-line head on every VE case), and a unary
   minus initializer in the clone (ve04).
6. The implementer's ranked residues, not re-measured here beyond the
   uhdm-cmp counts: the 16 uvm-examples rows (on uvm_messaging_example the
   uhdm-cmp head object reads the uvm_pkg package pair on both binaries), the
   4 testbenches rows (ParamEmit at this base, the sister's), and the carried
   backlog.

## Sister-ground faces
None new from this verification.  The enum definition-listing pairing in
residue 5 is TypeEmit's § enumConstLitArithRender188, which is this ground's.

## Process
- Fence: the list was read from canaudit.sh's FENCED= line by a program into
  /tmp/v11u426_fenced.txt and never printed.  The fence check printed only the
  entries' lengths and a byte compare with the sister's file.  Every
  cmds.txt listing was filtered on it before opening.  byteverify's `find`
  runs over this pass's sweep workdir and the control dir only, where no
  fenced test is dispatched.  No fenced test was named, opened or run.
- Budget: one law build (equal to law6), no pristine build, one full
  five-stage sweep on the law binary, byteverify once against the control.
  No refinement, so no second sweep.
- Slips, none affecting a measurement:
  1. The two-row svtests_matrix runs (p179 and typedef_test_9, on pristine and
     law; 4 slang-uhdm runs with Surelog cached) were launched while the
     sister r11u425's corpus sweep was live.  The pre-launch pgrep printed its
     processes, but the launch did not wait on it.
  2. The first downstream case batch ran beside a sister `ds.one` case
     process; that was not a sweep.  Every later step waited for a quiet
     pgrep.
  3. The first golden-error check matched Surelog's `[ERROR] : 0` summary.  It
     was redone on the counts: 123 goldens, all 0 errors and 0 fatals.
- No other agent's process was touched.  Every scratch file is under
  /tmp/v11u426_* by absolute path.

## Files
- cases/{VA,VB,VE,VN}/<case>/dut.sv: 72 case dirs (vb19 has a.sv plus FILES;
  vb24 has inc.svh).
- drivers/: run1.sh (golden plus ours plus uhdm-cmp plus strict, keyed on the
  full path after tools/probe/), grid.sh, dd.sh, ds.py (downstream per case
  dir), fullsweep.sh (sources /tmp/v11u426_env.sh: the brief's tool
  exports), switches.txt.
- evidence/: fullsweep_law.log, byteverify_law_vs_control.txt,
  svtests_law_vs_control.diff, rows_{pristine,law}.csv, trace_census.txt,
  away_census_cmp_lines.txt, grid_impl_repro.txt, grid_attack.txt,
  dumpdist_attack.txt, downstream_cases_{pristine,law,batch2}.txt.
