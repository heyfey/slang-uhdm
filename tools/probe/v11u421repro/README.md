# v11u421: adversarial verification of r11u421 (pass 421, expression/parameter ground)

Base d0d46b5ca. Implementer's patch /tmp/r11u421.patch (md5
90dcb0b7f3cde04d8fd13c7a21563a86) applied clean on a fresh worktree.

Binaries, frozen before any measurement (every cmds.txt audited by path):

- pristine = the main tree's build/slang-uhdm, md5 2e1233784f8120b172b1a2bf12fded1f
  (the master's control sweep /tmp/intr11u419 is the pristine reading; no
  pristine build and no pristine sweep, per the measurement budget);
- law = rebuilt from the patch, md5 22d95ce83451d22560ae8990578e4ff7, EQUAL
  to the implementer's /tmp/r11u421_law.bin;
- verified = law + one refinement in src/ParamEmit.cpp, md5
  0620ec3fde41ca631002651bc458f79a.

## Verdict

THE BREAK, fixed: § bitsDefNoFoldNoTs421 asks srlgBitsFoldArg about EVERY
`$bits` argument, but srlgBitsFoldArg only judges names, selects, member
accesses and type arguments; for a CONCATENATION it answers "no fold" while
Surelog folds it. `localparam W = $bits({a, b});` over fixed-width ports
went from STRICT_EQUAL (pristine) to NOT_EQUAL at 17 uhdm-cmp lines (law):
golden writes the folded UINT with the declaration's int_typespec, the law
removed the typespec. Five fresh cases broke this way (VB/vb03, vb18, vb19,
vb25, vb26) and two more moved away from golden (vb17, vb28: dump distance
10 -> 44 and 18 -> 52).

The fix is § bitsConcatLastResolvesAbstain421v (src/ParamEmit.cpp, inside
the law's block; switch `R11V421_BITSCONCAT_OFF` through
`fixOn(421, ...)`). Surelog's compileBits (CompileExpression.cpp,
paConcatenation branch) walks the elements of a concatenation. For each one it
calls getTypespec, and the first fully specified element promotes the
compile to Reduce::Yes. The call folds when the LAST element resolves to a
signal's typespec and the compile was promoted. Golden on the fresh cases
confirms this:

| case | argument | golden |
|---|---|---|
| vb03 | `{a, b}` | fold + int_typespec |
| vb17 | `{w, b}` (w of parameter width) | fold UINT:4, b's bits only |
| vb26 | `{a, w}` | fold |
| vb28 | `{4'b0, a}` | fold |
| vb29 | `{a[1], b[2:0]}` | fold |
| vb15 | `{a, 4'b0}` | keeps the call, no typespec |
| vb16 | `{2{a}}` | keeps the call, no typespec |
| vb27 | `{w, v}` (both of parameter width) | keeps the call, no typespec |
| vb30 | `{a, w_p}` (a parameter last) | keeps the call, no typespec |

The refinement abstains on a concatenation whose last operand is rooted in a
net or variable and that has an operand srlgBitsFoldArg folds. Every other
argument kind keeps the implementer's law. The law is right on literals,
calls, operations, casts, conditionals and unary operators: golden keeps the
call there with no typespec (vb01, vb02, vb11, vb13, vb20, vb21, vb22,
vb24).

The other three laws held: no fresh case on legal SV where pristine was right
and the law wrong.

## Sweeps (one each on law and verified, tests/sweep.sh --jobs 3; the sv-tests stage through the main tree's scripts/check_svtests.py read-only with --baseline the worktree's results/golden_svtests.csv, since a worktree has no UVM tree; machine quiet before each launch)

Law sweep, /tmp/v11u421law (evidence/sweep_law.log):

- probe: 0/0/0, and the csv is byte-identical to the control (EQUAL 4018,
  STRICT_NOTEQUAL 69).
- surelog: 0/0/0. The csv differs from the control only in the two LowMem
  log-path texts.
- uhdm2rtlil: 0/0/0, csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  csv identical to the control.
- sv-tests: regressions=0, conversions=3, changes=0. EQUAL 1851 -> 1854,
  STRICT_NOTEQUAL 3 -> 2, DIFFERENT 86 -> 84; BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346. The
  csv is byte-identical to the implementer's on all 2346 rows.

Verified sweep, /tmp/v11u421ver (evidence/sweep_verified.log): every csv is
byte-identical to the law sweep's, except the surelog csv's two LowMem
log-path texts. The same 3 conversions:

    chapter-16/16.17--expect-uvm.sv,EQUAL,,equal
    generated/basejump/bsg_noc_BaseJumpSTL_bsg_ready_and_link_async_to_wormhole.sv,EQUAL,,equal
    generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_concentrator_out.sv,EQUAL,,equal

Measurements on both sweeps:

- byteverify, SELFCHECK=1 (evidence/byteverify.txt): law against the control
  0 of 962, 0 of 1608 and 0 of 805. Verified against the control and against
  the law, 0 / 0 / 0 each. The self-checks flagged 961, 1607 and 804.
- Canaries: ok=52 and ok=16; ctcan2 ok=58 PASS (EXPECT_UNKNOWN=1) and ok=2
  PASS (EXPECT_UNKNOWN=6).
- Binary audit, fence-filtered, the same on both binaries: surelog 1523 of
  1573 (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740,
  sv-tests 2346 of 2346.
- Trace census (evidence/trace_census.txt): firings on 10 sv-tests rows only,
  as the implementer reported: the 3 conversions, bsg_tag_trace_replay and
  the 6 black-parrot rows (§ hpTrailIpsSysArgNames421, 72 `$bits` and one
  `$clog2` firing). § bitsConcatLastResolvesAbstain421v fires on no corpus
  row, probe case or sv-tests row.
- Kept sv-tests databases, law against verified (107, with the workdir path
  normalized): 105 identical. The other 2 are the uvm_use_models_pipelined_get_put
  and uvm_test_init draws, both DIFFERENT on both binaries. This is a
  PRE-EXISTING run-to-run coin: concurrent draws on pipelined_get_put give two
  hashes on pristine (1 of 4 draws), on law (2 of 7) and on verified (2 of 7)
  (evidence/determinism.txt). Neither the law nor the refinement causes it,
  and neither row's status moves.

## Grids

All grid runs go through drivers/case.sh: golden from Surelog v1.87, then
uhdm-cmp, uhdm-strictcmp and dump distance; each grid line carries the exit
code. drivers/grid3.sh runs pristine, law and verified, then checks four
things: R11U421_OFF gives pristine's bytes and exit code, R11V421_OFF gives
the law's, each group's own switch gives pristine's, and (VP only) the switch
pair R11U421_PISYSBS_OFF plus R11U421_BITSDEFNOFOLD_OFF does too, since
`$bits(P[1])` fires both laws.

- **Implementer's 39 grid case dirs:** reproduced line for line on exit code,
  uhdm-cmp count and strict verdict. Law and verified bytes are equal on 39
  of 39.
- **Fresh case dirs, 62, all accepted by upstream slang, all exit 0 on every
  binary.** Three more cases were written and dropped because upstream slang
  rejects them.
  - Overall: verified equals law on 53. The other 9 are the refinement's
    cases. R11U421_OFF restores pristine on 62 of 62, R11V421_OFF restores the
    law on 62 of 62, and each group's own switch restores pristine on 62 of 62.
  - **VE** (expect, § expectActionBlockStmts421): 12 cases.
    - 7 NOT_EQUAL -> STRICT_EQUAL: an else-only null pass action, if/else as
      the action, empty blocks, an interface, two instances, a class task, and
      fork/join.
    - 5 still NOT_EQUAL on other faces, which the law cannot reach:
      - ve06 `##[1:2]`: dump distance 37 -> 24.
      - ve10, a genvar delay in a generate loop: 74 -> 20.
      - ve11, a program (references unbound): 28 -> 12.
      - ve13, a property instance: 38 -> 18.
      - ve05, labeled actions `lp: n = 1; else le: n = 2;`: uhdm-cmp 98 -> 98.
        The pass action is now written and both actions sit in golden's
        slots. The dump distance grows 60 -> 76 only because the newly
        written pass action carries the standing labeled-statement face
        (golden's labeled assignment, our named_begin): pass 415's residue
        for labeled non-call statements, not this law.
  - **VH** (§ hpTrailIpsSysArgNames421): 9 cases.
    - vh01 `h.cid[0+:$clog2(N)+1]` STRICT_NOTEQUAL fullname -> STRICT_EQUAL.
    - vh02, vh03, vh05, vh07 and vh10 move bytes at the same uhdm-cmp head.
      Dump distance is the same or closer: vh05 45 -> 41, the others equal.
      The reference is now named through the path, but the select's own name
      renders the `$clog2(N)` width or base, where golden renders it empty:
      `work@top.h.cid[0+:].cid.N`. This is the implementer's residue 2, the
      same distance as pristine.
    - vh04 (a written path), vh06 (`$size`) and vh08 (`p::N`) keep pristine's
      bytes.
  - **VP** (§ paramInitSysArgBitSelAtIndex421): 10 cases. 8 move toward
    golden, 2 keep pristine's bytes. None is equal on either binary; the
    heads are other faces: golden's `$bits(P[1])` value and the packed
    parameter's typespec, the implementer's residue 5.
  - **VB** (§ bitsDefNoFoldNoTs421 and the refinement): 31 cases.
    - The break and its fix: vb03, vb17, vb18, vb19, vb25, vb26, vb28, vb29
      and vb31 sit at pristine's bytes on the verified binary. vb03, vb18,
      vb19, vb25, vb26 and vb31 are STRICT_EQUAL.
    - vb08 NOT_EQUAL -> STRICT_EQUAL: two instances of a struct whose width
      reads a parameter.
    - 17 still NOT_EQUAL and toward golden by dump distance. The pairs read
      pristine -> verified:

      | cases | dump distance |
      |---|---|
      | vb01, vb02, vb05 | 79 -> 52, 61 -> 29, 40 -> 19 |
      | vb06, vb09, vb10 | 49 -> 22, 41 -> 14, 33 -> 6 |
      | vb11, vb12, vb13 | 54 -> 36, 43 -> 25, 61 -> 29 |
      | vb15, vb16, vb20 | 72 -> 40, 85 -> 53, 49 -> 22 |
      | vb21, vb22, vb24 | 93 -> 66, 83 -> 51, 57 -> 30 |
      | vb27, vb30 | 74 -> 42, 84 -> 52 |

      The uhdm-cmp count grows on several of them (17 -> 28 to 128) because
      the head moves later in the walk. The parameter's typespec is gone, as
      in golden. The next head is the definition listing's `$bits(...)` call,
      which golden keeps and the expression emitter folds (ExprEmit's bitsKeep
      gate judges only names, selects and type arguments).
    - The remaining cases keep pristine's bytes.
- **Downstream:** verdicts on all 101 case dirs (the 39 plus the 62) are the
  same on all three binaries: 77 IDENTICAL, 6 EQUIVALENT, 18 DIVERGENT. None
  is worse. The 18 DIVERGENT are VB and VP `$bits`/`$clog2` parameter cases driving
  an output: vb01, vb06, vb11, vb14, vb16, vb20-24, vb28, vb29, vp02, vp03,
  vp05, vp06, vp08 and vp10. Surelog's own folded value differs there (for
  example UINT:0 for `$bits(a + b)`). They are DIVERGENT on pristine too. The
  6 EQUIVALENT are HS/hs01-03, hs05, VB/vb05 and vb12
  (evidence/downstream.txt).
- **Earlier-pass census:** law against verified over the 2908 fence-filtered
  case dirs of tools/probe/{r,v}11u400repro to 420repro gives 2908 of 2908
  the same exit code and bytes (evidence/earlier_census_law_vs_verified.txt).
  The 8 dirs without a database exit nonzero on both.

## Corrections to the implementer's deliverable

- The seven EX case files named a law that does not exist on their first line
  (an earlier draft name of the expect law), so tests/CASES.csv
  could not attribute them. They are renamed to § expectActionBlockStmts421
  and tests/LAWS.md is regenerated.
- The implementer's account of § bitsDefNoFoldNoTs421, "the predicate the
  expression emitter keeps the sys_func_call on", holds only for the
  argument kinds srlgBitsFoldArg judges. The emitter folds a concatenation
  by its old rule, and so does Surelog when the last element resolves.

## Residues (ranked; all wrong on pristine too, none moved away by uhdm-cmp)

1. The definition listing's `$bits(<literal | call | operation | cast |
   conditional | unary | concatenation ending in a literal or parameter>)`.
   Golden keeps the sys_func_call; ExprEmit's bitsKeep gate folds it, since it
   judges only names, selects and type arguments. The VB cases above are the
   next head, after the typespec this pass removed. Writer: ExprEmit's
   `$bits` branch, this ground.
2. The select name of a dotted path's trailing indexed part-select whose
   whole width or base is a system call. Golden renders it empty
   (`h.cid[0+:].cid.N`, `h.len[-:2]`); ours renders `$clog2(N)` (VH/vh02,
   vh07, vh10; the implementer's HS/hs01-04, hs09).
3. Labeled expect actions: pass 415's labeled-statement residue (VE/ve05).
4. The expect shapes the law does not reach: a `##[1:2]` range in the
   property (ve06), a genvar delay in a generate loop (ve10), an expect in a
   program (ve11), a property instance as the expect's property (ve13).
5. VP: golden's own `$bits(P[1])` value and the packed parameter's default
   typespec (the implementer's PB residue).
6. The implementer's remaining residues and sister-ground faces stand as it
   listed them. Confirmed: 16.12 property-interface and its -prec twin have
   their head at ModuleEmit emitInterfaceInstance's process loop, where an
   interface's concurrent assertion is wrapped in an always (the sister's
   face).

## Process

Pristine came from the master's control; the law binary was built once and
the verified binary once; there was one sweep each. The fence list was read
into a file by a program and never printed, and every tree-wide list (the
earlier-pass census, the binary audit) was filtered on it before any file
was opened. No other agent's process was touched, and every launch followed
a quiet pgrep reading.

The sweep's first run skipped the sv-tests stage because the worktree has no
sv-tests sibling. The stage was then run alone through the main tree's
check_svtests.py, as the implementer did. Every scratch path is absolute,
under /tmp/v11u421_*.
