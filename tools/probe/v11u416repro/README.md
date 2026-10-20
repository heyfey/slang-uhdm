# v11u416: adversarial verification of r11u416 (module/type ground, sv-tests pass 416)

Base 2416fd57b. The implementer's patch /tmp/r11u416.patch applies clean on a
fresh 2416fd57b worktree (/tmp/wt_v11u416). VERDICT: CONFIRMED, no break found,
no production change by the verifier. Every headline number of the
implementer reproduces bit for bit.

## Binaries (frozen before any measurement)

- Law: rebuilt once from the patch in /tmp/wt_v11u416 (`cmake --build -j 2`),
  md5 18f76dd113d0725710277d4ac13ad9c5, equal to the implementer's
  /tmp/r11u416_bin/l7. Frozen at /tmp/v11u416_bin/law.
- Pristine: the main tree's build at the base, md5
  66df7ded979fc01d27731b8d95a31e10, frozen at /tmp/v11u416_bin/pristine. No
  pristine build and no pristine sweep (the budget): the pristine reading is
  the master's control sweep /tmp/intr11u414.
- No verified binary: no refinement was needed, so the five stages ran once.

## No-header audit

The added source lines hold no getenv, no envSet, no #include, no src/R*.h
and no reader function; the five law switches read through `lawOn(416, ...)`,
the firings through `lawTrace(416, ...)` / `lawTraceOn(416)`. Only
src/TypeEmit.cpp, src/ModuleEmit.cpp and src/UhdmExporter.cpp change; none of
the sister's four files. `scripts/law_index.py --check` reads current on the
implementer's patch alone.

## The one sweep on the law binary (tests/sweep.sh --jobs 3, workdir /tmp/v11u416sw1)

The four corpus stages from the worktree; the sv-tests stage through the main
tree's scripts/check_svtests.py (read-only, at the base: a worktree has no UVM
tree) with `--baseline` the worktree's results/golden_svtests.csv. No trace
set (the implementer's sweep was traced, so the equal csvs below also show the
trace leaves the output alone). The corpus stages exited 1 only on the law
index, stale because this repro dir's cases were already in the tree when the
sweep started (tests/LAWS.md is regenerated in the verified patch). The
machine was quiet at launch (the sister r11u413's sweep had finished).

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, `regressions=0
  conversions=0 changes=0`; the csv byte-identical to the control's and to the
  implementer's; 4087 of 4087 databases STRICT_EQUAL control against law
  (evidence/probe_control_vs_law.txt).
- surelog: default 480 + 0 (CMP_NOTEQUAL 4), testflags 474 + 0, `0/0/0`; the
  csv differs from the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes, `0/0/0`; csv byte-identical to the
  control's.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  not identical and not excused 0; csv byte-identical to the control's.
- svtests: EQUAL 1803, STRICT_NOTEQUAL 6, DIFFERENT 131, SURELOG_ONLY 75,
  BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  `regressions=0 conversions=91 changes=1`. The csv is byte-identical (sorted)
  to the implementer's evidence/svtests_law.csv on all 2346 rows and the
  CONVERSION / CHANGE list is line-identical.
- byteverify against the master's control (SELFCHECK=1, same-length
  workdirs): surelog 0 of 962 (selfcheck 961 of 962), uhdm2rtlil 0 of 1608
  (1607), downstream 0 of 805 (804) (evidence/byteverify.txt). No mover, so
  nothing to predict or attribute in the corpora.
- canaries: `ok=52 changed=0` (surelog), `ok=16 changed=0` (uhdm2rtlil);
  ctcan2 PASS with EXPECT_UNKNOWN=1 (ok=58) and EXPECT_UNKNOWN=6 (ok=2).
- binary audit, fence-filtered (the fence list read by a program from
  canaudit.sh's FENCED= line into a file, never printed): surelog 1523 of 1573
  cmds.txt name /tmp/v11u416_bin/law, 48 hold no slang line, the other 2 name
  slang only in the UVM checkout path; uhdm2rtlil 1740 of 1740; sv-tests 2346
  of 2346, none holding a fenced name.

The fresh rows of the CHANGE and three of the conversions:

    control: generated/basejump/bsg_noc_BaseJumpSTL_bsg_mesh_router.sv,STRICT_NOTEQUAL,differ:col(2),differ:col(2)
    law:     generated/basejump/bsg_noc_BaseJumpSTL_bsg_mesh_router.sv,STRICT_NOTEQUAL,differ:col(1),differ:col(1)
    law:     chapter-18/18.13.1--urandom_1.sv,EQUAL,,equal
    law:     chapter-5/5.6.4--compiler-directives-debug-line.sv,EQUAL,,equal
    law:     generated/basejump/bsg_misc_BaseJumpSTL_bsg_lfsr.sv,EQUAL,,equal

mesh_router moves toward golden: its strict records are 4 lines from
golden's on the control and 2 on the law (sorted record multiset).

## Away census on the sv-tests databases both sweeps kept

158 rows kept a database in both the control and the law workdir (the 91
converted rows are EQUAL now and keep none).

- The 6 judge-equal rows (the STRICT_NOTEQUAL residues): strict records
  identical control against law on 5, mesh_router toward golden (4 -> 2).
- The 152 NOT_EQUAL rows: uhdm-dump line multiset, restricted to the lines
  whose count differs control against law, distance to golden on each side
  (evidence/away_svtests.txt): 77 byte-equal dumps, 69 TOWARD golden (every
  moved line the `begin` of `m_uvm_field_op_begin` at
  uvm_object_defines.svh:804, now 804:39 / 804:37 for COMPARE / PRINT), 5 at
  the same distance and 0 away. The 5 (18.5.11 static-constraint-blocks_1,
  uvm_overriding, uvm_slave_agent, uvm_slave_agent_multi_seq_item,
  uvm_wait_for_signal) move the same 10 begin lines inside
  uvm_reg_mem_hdl_paths_seq, a class those rows' goldens do not hold at all
  (0 dump lines), so no side is nearer. generated/tnoc/tnoc reads TOWARD on
  97541 changed lines, an artefact of its dumps hitting the 1200 s timeout at
  different points: uhdm-cmp control against law reads 0 lines on it, its
  status is DIFFERENT `decompile:` on both, and no law fires there (the
  implementer's trace census).
- uhdm-cmp line counts golden-vs-control and golden-vs-law are equal on all
  158 kept rows (evidence/away_svtests_cmp.txt).

## Grid: the implementer's 37 case dirs reproduced

drivers/grid.sh over tools/probe/r11u416repro/cases with the frozen binaries
reproduces every line of the implementer's evidence/grid.txt (exit code,
uhdm-cmp line count, strict verdict, R11U416_OFF and each group's own switch
restoring pristine's bytes and exit code) on 37 of 37
(evidence/grid_impl_reproduced.txt); only the md5 column differs, because
VpiFile carries the worktree's absolute case path.

## Attack grid: 67 fresh case dirs in VD, VG, VL, VO and VP

Every case accepted by upstream slang (~/.local/bin/slang --single-unit),
first line `// § <law>`. Golden: Surelog v1.87 `-parse -nobuiltin -nocache
-sv`, cached per case text under /tmp/v11u416_scr/gold. drivers/run1.sh,
drivers/grid.sh (pristine, law, R11U416_OFF=1, the group's own switch),
drivers/away.sh (uhdm-dump multiset distance), drivers/ds.sh (downstream
`ds.one`). evidence/grid_attack.txt carries every line with its exit code.

Totals, pristine -> law (every exit code 0 on both):

- 35 STRICT_NOTEQUAL -> STRICT_EQUAL.
- 15 STRICT_EQUAL controls byte-identical.
- 3 STRICT_NOTEQUAL on both, moved toward golden (vd06 142 -> 138, vd13
  108 -> 96 with the first field moving from col to depth, vl03 52 -> 32 dump
  lines from golden); 1 STRICT_NOTEQUAL byte-identical (vp13).
- 9 NOT_EQUAL on both, moved: 6 toward golden by dump multiset (vd01, vd14,
  vd16, vg03, vg09, vl07) and 3 at the same multiset distance with the
  design's subroutine listing order moved to golden's (vo03, vo07, vo12;
  evidence/vo_design_listing_order.txt); 4 NOT_EQUAL byte-identical.
- No case leaves an equal status, no exit code changes, none moves away.
- R11U416_OFF restores pristine's bytes and exit code on 67 of 67; each
  group's own switch on 67 of 67.
- Downstream (uhdm2rtlil lanes) on the 64 class-free cases
  (evidence/downstream_{pristine,law}.txt): 5 EQUIVALENT -> IDENTICAL (vl01,
  vl02, vl03, vl08, vl09), the rest the same
  verdict on both binaries (vd01, vd14, vo03, vo07 EQUIVALENT; vl07
  DIVERGENT on both, the `__LINE__` value below); none worse.

Per law:

| group | law | cases | pristine -> law |
|---|---|---|---|
| VD | § defGenConnSelAtIndex416 | vd01 a call argument in a concatenation, vd02 a select index holding a select, vd03 a ternary, vd04 a unary in a binary, vd05 a two-dimension select, vd06 a struct member select, vd07 streaming, vd08 nested loops, vd09 a literal cast, vd10 an indexed part-select (control), vd11 signed'(), vd12 concatenations in a binary, vd13 a parameter-array index, vd14 a call in a binary, vd15 a select inside a part-select base, vd16 a parameter vector bit in a concatenation, vd17 a ternary in a concatenation, vd18 a reduction of a select in a concatenation | vd02, vd05, vd09, vd11, vd12, vd15, vd17, vd18 STRICT_EQUAL; vd03, vd04, vd08 STRICT_EQUAL controls unchanged; vd06, vd13 STRICT_NOTEQUAL toward; vd01, vd14, vd16 NOT_EQUAL toward; vd07, vd10 NOT_EQUAL unchanged |
| VG | § genCaseItemProcNoFull416 | vg01 nested named blocks with locals, vg02 always_ff, vg03 a case-generate inside a named for, vg04 struct member writes, vg05 a for-loop variable, vg06 a named event trigger, vg07 the matching item unlabelled, vg08 two processes in an unnamed begin, vg09 a task call with a local, vg10 an assign plus a process, vg11 a named fork, vg12 a static local, vg13 an immediate assertion with $error, vg14 a hierarchical call | 12 STRICT_NOTEQUAL fullname -> STRICT_EQUAL; vg10 STRICT_EQUAL control unchanged; vg03, vg09 NOT_EQUAL toward golden (the law fires in vg03 too: the case-generate inside the for loop's definition view has an empty branch prefix) |
| VL | § lineDirectiveIgnored416 | vl01 a `line inside an included file, vl02 two directives, vl03 a macro use after the directive, vl04 a package class, vl05 `__LINE__` with no directive (control), vl06 a directive in an inactive `ifdef (control), vl07 `__LINE__` after a directive, vl08 a function and a generate loop, vl09 a directive between two modules | vl01, vl02, vl04, vl08, vl09 STRICT_EQUAL; vl05, vl06 controls unchanged; vl03 toward (a macro expansion's objects keep the directive's line); vl07 NOT_EQUAL toward (golden `__LINE__` reads 91 after `line 90 where slang's value is 90: a value, pristine too) |
| VO | § unitImportTfSourceOrder416 | vo01 an explicit import, vo02 a function before and after the import, vo03 a task before the import, vo04 an unused package function, vo05 two packages in one import, vo06 a DPI import between, vo07 a package that imports another, vo08 a module-scope import (control), vo09 two own functions after, vo10 a class and a function, vo11 an out-of-body method, vo12 a $unit function shadowing a package one | vo02, vo04, vo05, vo06, vo09, vo10 STRICT_EQUAL; vo08 control unchanged; vo03, vo07, vo12 NOT_EQUAL with the listing order now golden's; vo01, vo11 NOT_EQUAL unchanged (the law abstains) |
| VP | § pasteBlankLedStartWritten416 | vp01 prefix X with OP of 1 to 6, vp02 an assignment after the blank, vp03 two pastes on one line, vp04 begin then a statement, vp05 a call argument, vp06 a statement after the `;`, vp07 a case label, vp08 a module-scope assign, vp09 a parenthesized condition, vp10 a suffix paste, vp11 a long FLAG actual (UVM shape), vp12 a tab before begin, vp13 a large shift with tokens after the blank, vp14 a large shift with begin and a statement | vp01, vp03, vp11, vp12, vp14 STRICT_EQUAL; vp02, vp04 to vp10 STRICT_EQUAL controls unchanged; vp13 STRICT_NOTEQUAL endcol unchanged (pristine residue) |

## Residues (all wrong on pristine too, none moved away)

1. The 6 STRICT_NOTEQUAL sv-tests rows and the 131 DIFFERENT rows as the
   implementer lists them (its README, Residues).
2. Line directive: objects built from a macro expansion written after a
   `` `line `` keep slang's directive-mapped line (vl03); golden's
   `` `__LINE__ `` after `` `line N `` reads N+1 where slang's is N (vl07, a
   constant value: ExprEmit or the preprocessor value, not this ground's
   writer).
3. Design subroutine listing: an explicitly imported package function
   (`import p::pf;`) is listed by golden before the $unit function and not
   at all by us (vo01); a $unit function shadowing a wildcard-imported name
   is not listed by golden (vo12); an out-of-body class method at $unit
   (vo11, the law abstains). vo03 and vo07 still NOT_EQUAL for other reasons.
4. Definition-view connection selects: a call argument (vd01, vd14), a
   parameter vector bit (vd16), streaming (vd07) and indexed part-selects
   (vd10) NOT_EQUAL first elsewhere; vd06's struct member select full name;
   vd13's elaborated parameter-array index (a constant where golden keeps the
   select).
5. Paste: vp13's end column (the run model), as the implementer's pb04 and
   pb05.
6. The implementer's goal-1 probe shapes (vh04, vh06, vc13, vy02, vu02, aq09)
   and the carried backlog of passes 402 to 414, not reached.

## Sister-ground faces (reported, not written)

The implementer's three stand as written (DC/dc13 `W'(x[i])` exit 4 in
ExprEmit's cast-size re-bind; mesh_router's generate localparam select in
ParamEmit; gc08's folded assertion operand in ExprEmit), plus vl07's
`` `__LINE__ `` value after a `` `line `` directive (golden N+1; the
constant's value, ExprEmit).

## Process

- One law build (equal to the implementer's), one five-stage sweep, no
  pristine build or sweep, no second sweep (no refinement).
- The attack grid's first batch and the implementer's grid ran one process at
  a time while the sister r11u413's sv-tests stage was still live (its last
  ~270 rows); the law build (-j 2) overlapped it too. The sweep itself waited
  for a quiet machine (pgrep empty).
- A slip with no effect on any measurement: a first try of the second attack
  batch went through symlinked case dirs, so its OFF / own-switch columns
  compared missing files; it was discarded and rerun on the real dirs
  (evidence/grid_attack.txt holds the rerun).
- The fence list was read by a program into a file and never printed; no
  fenced test was named, opened or run. Only this pass's own processes were
  started or stopped. Scratch: /tmp/v11u416_*.
