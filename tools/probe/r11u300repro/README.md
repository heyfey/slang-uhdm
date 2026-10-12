# r11u300 — pass 300, expression/parameter ground: the package-function return fold

Base 142a850e (pass 298). Production surface: src/ExprEmit.cpp, src/StmtEmit.cpp and the new src/R300.h only.
Pristine build md5 44bee4bc45377433566d9695a8897241 (equal to the main tree's build/slang-uhdm at the base);
law build md5 bfc751431b6887cd6400213d3a94a64c. Both binaries were frozen before any measurement.

## Verdict

- **Five probe conversions**, the whole return-fold bucket of the brief's item (1) (pass 298's ranked residue 1),
  each predicted by name in the firing census frozen before the law sweep:
  - r10buvm8repro/v9fold8 `differ:depth(1)` -> EQUAL (fresh row `r10buvm8repro/v9fold8,EQUAL,,equal`)
  - r11v48repro/va8 `differ:depth(1)` -> EQUAL (fresh row `r11v48repro/va8,EQUAL,,equal`)
  - r10uvm52repro/a1 `differ:depth(1)` -> EQUAL (fresh row `r10uvm52repro/a1,EQUAL,,equal`)
  - r10buvm13repro/v3_clone13 `differ:depth(1)` -> EQUAL (fresh row `r10buvm13repro/v3_clone13,EQUAL,,equal`)
  - r10buvm8repro/v3_argts8 `differ:type(1)` -> EQUAL (fresh row `r10buvm8repro/v3_argts8,EQUAL,,equal`)
  - uhdm-cmp reads 0 lines on all five, on both binaries.
- **No corpus row moves:** surelog default 480 + 0 and testflags 474 + 0; uhdm2rtlil 803/1/67 in both modes;
  0 of 2560 corpus databases and 0 of 805 downstream databases move in bytes.
- **Downstream:** 803/66/2/0, the csv byte-identical to results/downstream_uhdm2rtlil.csv (pristine and law).
- **Gate:** probe 3989 EQUAL + 98 STRICT_NOTEQUAL with regressions 0, conversions 5 and changes 0
  (pristine at the base: 3984 + 103, equal to results/golden_probe.csv).

## The law (switch in src/R300.h)

`R11U300_OFF` drops the law and gives pristine's bytes and exit code on 168 of 168 grid case-views.
`R11U300_TRACE=<dir>` logs every firing (`RETSHARE <caller>-><callee>[ reparent]`) and every abstention
(`RETSHARE_ABSTAIN <caller>-><callee> <reason>`) past the package-function test.

**§ pkgRetCallFoldSharesCalleeRet300** — switch `R11U300_RETSHARE_OFF`. ExprEmit's user-call branch of emitExpr
(the site), with the registry written in StmtEmit's return branch (both read through src/R300.h).

- **The shape:** a package function's `return` calling another package function, in the ELABORATED package
  listing (uhdmtopPackages): `function int c(int x); return f(x); endfunction` with `f` = `return a + 1;`.
- **What golden writes:** no func_call. The return's condition is the CALLEE's own return-expression object in that
  same listing, shared (the strict walk and uhdm-dump visit it once; the second reference prints only its header).
  The definition listing (uhdmallPackages) keeps the func_call.
- **The decode** (Surelog under third_party/Surelog/src, UHDM templates/ExprEval.cpp):
  - CompilePackage compiles the elaborated package with Reduce::Yes, and compileStmt's paRETURN branch threads it into
    compileExpression for a direct body statement (the window § pkgRetTopCallArgFormalTs8 already models).
  - CompileExpression's user-call branch (paSubroutine_call) then calls EvalFunc (DesignCompile/EvalFunc.cpp), which
    runs ExprEval::evalFunc. getTaskFunc resolves the callee in the component being compiled: the elaborated
    listing's own function, the wildcard-import clone the importer's listing holds (v3_clone13, RF/g27), or the
    other package's elaborated listing for a qualified call (RF/g14).
  - evalFunc binds each formal to the reduced actual (an unvalued reference stays a reference), evaluates the body,
    and the return branch stores `reduceExpr(E)` as the function's value. When that comes back non-null and
    invalidValue stays false, the func_call is discarded and the result takes its place.
  - reduceExpr's vpiAddOp branch takes its UNSIGNED path when no reduced operand is an INT, string, real or decimal
    constant (an unbased decimal literal is UINT). get_uvalue fails on the unvalued formal and sets only
    invalidValueI, so the add comes back unreduced and VALID: the callee's own operation object.
    The vpiSubOp, vpiMultOp, comparison, bitwise, logical and conditional branches set invalidValue on the same
    operand, so golden keeps the call there (RF/g10 `a * 2`, RF/g15 `a ? 1 : 2`, RF/g19 `a - 1`).
  - A no-argument `$urandom()` / `$random()` comes back as itself (RF/g08, RX/h12, v3_argts8 c2).
  - A DPI import has no body: no return value is recorded and the call stays (v3_argts8 c1).
  - CompileExpression re-parents the operands of its binary and ternary branches, so a shared result under `==`
    or `?:` takes the CALLER's operation as its vpiParent (v3_argts8 c2, RX/h15); a unary operand and a
    system-call argument are not re-parented (RF/g11, RF/g13).
- **The gates** (each one a measured boundary; everything else abstains and keeps the call, pristine's bytes):
  - The caller is a package function (no class method, no clone body) emitted in the elaborated listing, the call
    inside § pkgRetTopCallArgFormalTs8's window (`pkgRetTopExpr8`).
  - The callee is a package function (no DPI import, no method, not the caller itself), declared EARLIER in the same
    package (§ pkgRetCalleeDeclFirst8v: RF/g05 keeps the call) or in another package.
  - Every written actual is a bare reference to a formal or a non-const local variable of the caller (RF/g25,
    RX/h37 with an initializer, RS/s24 in a named block). A positional call that stops early leaves the formal
    unset and still shares (RF/g17, RX/h02). A call written with a named or an empty argument that omits one
    abstains: compileTfCallArguments fills the slot with an unlocated INT:0 constant, the add then takes its signed
    path and EvalFunc is invalid (RS/s11, golden keeps the call). Constant and parameter actuals fold to a
    constant (RF/g04, RX/h06): not modelled.
  - The callee body is exactly one `return` (a begin/end around it counts: RF/g07) whose expression is an add of
    the callee's own formals and unbased decimal literals with at least one formal (kind 1), or a no-argument
    $urandom/$random (kind 2).
  - The call sits directly under the return, or under operations and system calls up to it. A binary or ternary
    parent re-parents the result; that is written only for kind 2 (no references). A kind-1 result under a binary
    or ternary parent abstains: golden's late binding then resolves the formals' names from the caller's scope and
    loses the binding (RF/g02, RF/g12, RF/g22, RF/g24, RX/h13 read act=- in golden; uhdm-cmp stage 1 on both
    binaries, not modelled).
  - The callee's registry entry must exist (it was emitted earlier in this listing, or in its home listing for a
    qualified call into another package) and be of the expected kind.
- **Reach:** the corpus census fires nowhere: 17 abstentions on 13 row-modes (11 surelog, 2 uhdm2rtlil) (evidence/census_corpus_details.txt),
  each on a callee golden keeps as a call: uvm_bitstream_to_string, aes_mul2 and _clog2 have several statements
  or a non-add return, and aes_mul4 passes a call as an argument.

## Cases (tools/probe/r11u300repro/cases, every file's first line `// § pkgRetCallFoldSharesCalleeRet300`)

84 case dirs, both views (168 case-views), every grid line with its exit code (evidence/grid.txt):

- **RF** (25, the decode grid: § pkgRetCallFoldSharesCalleeRet300): g01_plus, g02_cmp, g03_ident, g04_const,
  g05_fwd, g06_twostmt, g07_beginend, g08_sys, g09_param, g10_nested, g11_unary, g12_tern, g13_syscall,
  g14_xpkg, g15_ternbody, g17_default, g19_chain, g20_lit, g22_mixed, g23_bitsel, g24_twocall, g25_local,
  g26_automatic, g27_import, g28_retvoid_task.
- **RX** (33, the boundary grid: § pkgRetCallFoldSharesCalleeRet300): named calls (h01), defaults (h02), an output
  formal (h03), a package variable actual (h05), a parameter actual (h06), macro-born callee and call (h07, h08),
  an out-of-body class method (h09), literal first (h10), the same actual twice (h11), $random (h12), a compare
  (h13), unary minus and ternary around a $urandom callee (h14, h15), a module function (h16), qualified and
  wildcard-imported calls side by side (h17), a based literal (h18), a class static (h22), the caller's return
  inside begin/end or an if (h23, h24), callee locals and package-variable operands (h27, h28), two callers (h30),
  typedef, unsigned and vector types (h31, h33, h34), an explicit import (h32), a bit-select actual (h35), const
  and initialized locals (h36, h37), an interface function calling the package (h38), an unused package (h39), a
  task caller (h40).
- **RS** (26, the constant slots and contexts: § pkgRetCallFoldSharesCalleeRet300): a bit-select index (s01), a
  replication (s02), a package parameter default and a dimension bound (s03, s05), an indexed part-select base
  (s04), pure virtual and extern prototypes above and below the caller (s06, s07), a class specialization beside
  the call (s09), implicit nets (s10), a named call with an omitted default (s11), a call as another call's
  argument (s12), a this. path (s13), a for-generate module (s14), cast, concatenation and inside contexts
  (s15, s16, s17), an empty slot (s18), parentheses (s19), a forward package (s20), real (s21), recursion (s22;
  Surelog crashes in -elabuhdm, no e golden), a nested add (s23), a named-block local (s24), two packages with one
  function name (s25), string actuals under `==` and `&&` (s26), a void caller (s27).

## Measurements

1. **Grid** (drivers/gridall.sh, evidence/grid.txt, grid_summary.txt): 168 case-views.
   - 76 moving, 66 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.
   - `R11U300_OFF` and `R11U300_RETSHARE_OFF` each equal to pristine on 168 of 168 (every mover restored by the one switch).
   - The non-entering movers: RX/h32 d/e and RS/s05 d/e and RS/s14 d (stage 1 elsewhere on both binaries, the
     TOP listing now equal to golden's), RX/h38 d `depth -> type` (the walk now reaches #101, the module's
     `assign r = i.g(1)` folded to INT:2 where golden keeps the hier_path: ModuleEmit's cont_assign call fold,
     the sister's), RX/h38 e, RS/s25 d/e (d: the TOP listing of `d` equal to golden's shape, `c` stage 1 on the
     re-parented references), RS/s14 e (uhdm-cmp 90 -> 46).
2. **Away census** (drivers/awaygrid.sh, chain-keyed, evidence/grid_away.txt): chain away 0 on all 76 movers,
   204 records toward golden. Positive control (binaries swapped, evidence/away_poscontrol.txt): away on 10 of 10
   sampled. In the default view a converted case reads away 0 toward 0: golden's walk skips the shared object,
   so the strict verdict STRICT_EQUAL is the evidence there.
3. **Downstream on the grid movers** (drivers/dscases.py, evidence/downstream_cases.txt, 38 dirs):
   29 DIVERGENT -> IDENTICAL, RX/h14 EQUIVALENT -> IDENTICAL, 5 IDENTICAL on both, RS/s14, RS/s25 and RX/h38
   DIVERGENT on both binaries; none worse.
4. **Byte controls** (drivers/ctlsel.sh, evidence/control_dirs.txt, controls.txt, controls_summary.txt):
   958 case dirs, 1916 case-views: the mandated controls (r11u118repro, r11v11u118repro, r11u119repro,
   r11u120repro, r11v120repro, r11u124repro, r11v124repro, r11u131repro, r11v131repro) plus pass 298's grids
   (r11u298repro, v11u298repro) plus 124 trigger-selected dirs (a package and a `return <name>(` in the case,
   the path list filtered by $FENCED before any file was opened). 0 moving, 0 exit-code or uhdm-cmp line
   changes. Positive control (evidence/controls_poscontrol.txt): the same driver on three of this pass's
   cases flags the movers.
5. **Firing census** (drivers/tracecensus.sh, evidence/predict.txt, frozen before the law sweep): the probe and
   both corpora in both modes, filtered by $FENCED. RETSHARE fires on exactly five databases, the five probe
   conversions; every other line is an abstention (34 probe cases, 11 surelog row-modes, 2 uhdm2rtlil row-modes).
6. **Gate sweeps** (tests/sweep.sh --jobs 3, workdirs /tmp/r11u300_wdP and /tmp/r11u300_wdL; evidence/sweep_P.log, sweep_L.log):
   - Pristine: probe 3984 + 103, surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 both modes, downstream
     803/66/2/0; regressions 0 everywhere.
   - Law: probe 3989 + 98 with the five conversions and changes 0; surelog and uhdm2rtlil regressions 0,
     conversions 0, changes 0; downstream 803/66/2/0, not identical and not excused 0.
   - Row-by-row csv diff law vs pristine: only the five probe rows and the LowMem detail text (workdir path).
   - Both sweeps exit 1 on the law-index check alone (the new case files); the patch carries the regenerated tests/LAWS.md.
7. **Byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors from
   drivers/mirror.sh, mirror names of equal length):
   - Corpus 0 of 2560 databases moving (8 fenced paths skipped by name).
   - Downstream 0 of 805.
   - Probe (a direct cmp of the 4087 probe databases): exactly the 5 predicted.
   - SELFCHECK reads 2559 of 2560 (and 804 of 805). The self-check compares every database against ONE fixed
     database of the other side; that fixed path's own twin is byte-identical when nothing moves, so it is the one
     file not flagged. This is the known artefact, not a mover.
8. **Canaries:** canaries.sh surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2.sh PASS on both
   (EXPECT_UNKNOWN=1 surelog, EXPECT_UNKNOWN=6 uhdm2rtlil, both modes in the csv).
9. **Binary-path audit** (drivers/audit.sh): surelog own=1523 other=0 noslang=50 (8 fenced skipped by name),
   uhdm2rtlil own=1742 other=0, for both sweeps.
10. **Determinism** (drivers/det.sh, evidence/determinism.txt): three concurrent draws on the law binary per row-mode
    on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. One hash per row-mode,
    each equal to the law sweep's database (Scoreboard/testflags and Rggen/testflags write no database, as at the base).
11. **Elaborated view of the five conversions:** v9fold8 e NOT_EQUAL stage 1 (cmp 90) -> STRICT_EQUAL,
    v3_argts8 e NOT_EQUAL stage 1 (cmp 58) -> STRICT_EQUAL, va8 e and a1 e depth -> STRICT_EQUAL,
    v3_clone13 e stays at depth (the default argument's io_decl / ref_typespec, residue 6).

## Residues, ranked (all wrong on pristine too)

1. **A shared result with references under a binary or ternary operator** (RF/g02, g12, g22, g24, RX/h13, RS/s25's
   `c`). Golden re-parents the callee's operation at the caller's operation, and its late binding resolves the
   formals' names from the caller's scope, so `a` loses its binding (act=- in evidence/golden_decode.txt) and the
   callee's own listing shows the same object. uhdm-cmp stage 1 on both binaries. The law abstains. A model needs
   the late-binding lookup by name from the new parent chain.
2. **Multi-statement callee bodies.** Golden shares for `t = a; return t + 1;` (RF/g06) and a body with a local
   declaration (RX/h27), but keeps the call for uvm_bitstream_to_string, aes_mul2 and _clog2 in the corpus.
   The split needs evalStmt's model per statement kind (foreach, if, loops). Abstained.
3. **Callee return shapes outside the add and the no-argument random:** a literal (`return 5;`, RF/g20: golden
   shares the constant for an int return; a logic return gets a resized clone), a bit-select (RF/g23), the identity
   `return a` (RF/g03: golden substitutes the caller's ACTUAL object, still parented at the discarded func_call),
   a nested add `1 + 2 + a` (RS/s23).
4. **Actuals outside formals and locals:** a package variable (RX/h05), a bit-select (RX/h35), an output formal
   (RX/h03), and a package variable as the callee's operand (RX/h28). Golden shares in each; the law abstains.
   Constant and parameter actuals fold to a fresh constant located at the call (RF/g04, RX/h06: uhdm-cmp stage 1
   on both binaries).
5. **The omitted named or empty argument placeholder** (RS/s11, RS/s18): golden's call carries an unlocated INT:0
   constant for the omitted slot (uhdm-cmp stage 1 on both binaries); we write nothing there. ExprEmit's call
   arguments, not attempted.
6. **The elaborated view of v3_clone13:** depth at the default argument b's io_decl and ref_typespec
   (outside the gate, pristine wrong too).
7. **A package parameter operand in a TOP-listing return** (RF/g09 `return a + K`): golden folds K to its constant
   in the elaborated listing (uhdm-cmp stage 1 on both binaries). The § 169 / § 30 window family on this ground,
   not attempted.
8. **The brief's other items not attempted.** r11u117repro/grid/g1/t12 was looked at again: the hier_path's full
   name face is the first record, but the dump also differs in the package typedef `typedef ut_e [0:2] row_t`
   (golden packed_array_typespec with its range, ours a logic_typespec with an element typespec: TypeEmit
   makeTypespec, the sister's). So unparenting the path alone reaches that face, as pass 292 measured.
   The rest of items (2) to (7) were not attempted.

## Sister-ground faces (reported, not written)

- **RX/h38:** `assign r = i.g(1)` (an interface function calling the package) is folded to INT:2 in the module's
  cont_assign where golden keeps the hier_path call (ModuleEmit emitContAssigns, the call-fold face the brief
  lists).
- **t12:** the package typedef of a typedef with packed dimensions (TypeEmit makeTypespec).

## Process

- **Fence:** every driver reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh (drivers/env.sh).
  Every path list was filtered before any file was opened (mirror.sh, audit.sh, ctlsel.sh, the trigger selection,
  the probe and downstream byte comparisons). No fenced source or database was read, and no binary ran on one
  outside the gate sweeps.
- **The implementer's slips, no effect on any number:**
  - A first draft census ran on a law binary without the named or empty argument abstention. The grid found
    RS/s11 (uhdm-cmp 17 -> 114) on that draft. I stopped that census by its own process group, after checking
    that the group's command line named this pass's binary and workdir. The census was then rerun in full on the
    final frozen binary before the law sweep.
  - That process listing printed my own census process's `--filter` argument, which spells the fenced names.
    No fenced source or database was read.
  - No other agent's process was listed by name or signalled. The main tree was not written.
- **Drivers:** copied from tools/probe/r11u298repro/drivers. New ones: ctlsel.sh (controls over a list of dirs),
  retids.cpp + cc_retids.sh + rettree.sh (the return-expression trees with UhdmIds and parents of both
  listings, the decode instrument).
