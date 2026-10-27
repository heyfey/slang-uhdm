# v11u439 — adversarial verification of r11u439 (expression/parameter ground, pass 439)

Base db1d84d3 (pass 437). Implementer's patch /tmp/r11u439.patch (md5
2819b185a1a9f86d0a226e4e6f49eade) applied clean on a fresh worktree
(/tmp/wt_v11u439). Verdict: **one break found and fixed** (§ uninstProgIncDecBinds439v,
ExprEmit, switch R11V439_INCDEC_OFF); the five laws otherwise reproduce and hold.
Deliverable /tmp/r11u439.verified.patch.

## Binaries (frozen before any measurement)

| name | path | md5 |
|---|---|---|
| pristine | /tmp/v11u439_bin/pristine (the implementer's frozen base build, not rebuilt) | 24441d076ca367d92ef9d24c2ea0f9a4 |
| law (rebuilt once from the patch) | /tmp/v11u439_bin/law | e41a0fda1c966879a1f3164b9604df62 = the implementer's law7 |
| verified (one refinement) | /tmp/v11u439_bin/verified | d26edd165cdee2bed1061b4ddc493311 |

All three report slang 12.0.0+545f88b2e. Pristine readings for the gates are
the master's control /tmp/intr11u437 (no pristine sweep).

## The break: § uninstProgIncDecBinds439v (ExprEmit; R11V439_INCDEC_OFF)

Found by the earlier-case census below: tools/probe/r10vbuvm21repro/v2home.sv
(the program `vpg2`, `function void gf_inc(int s); garr[s]++; endfunction`)
moved further from golden on the law (dump distance 282 -> 284): golden
binds the index `s` to `io_decl (s)` 66:28, pristine bound it, the law left it
bare. Reduced: VI/vi01 (`function void f1(int s); garr[s]++; endfunction` in an
uninstantiated program) STRICT_EQUAL on pristine, NOT_EQUAL on the law
(uhdm-cmp 29 lines): **pristine right, law wrong on legal SV**.

Decode (golden, VI/vi01 to vi13): Surelog's `paInc_or_dec_expression` branch hands
the enclosing scope to compileExpression as pexpr, so the eager bindVariable
binds every formal and local in a statement-position ++/-- operand even where
nothing else in the body binds (the fact § incDecStmtOperandBinds21 encodes
for class methods). In an uninstantiated program, measured: `garr[s]++`,
`s++`, `cnt++` (task local), `++garr[s2]`, `garr[s][s2]++`, `garr[s+1]--`
(compound index), `garr[g(s)]++`, through a `begin`, a named begin and a `fork`
all BOUND; `garr[k]++` and `garr[k+1]--` over an initial block's unnamed-block
local `k` BOUND; `x = garr[s]++` (expression position), an `if` body and a
`repeat` body, a program member (`x++`, `garr[x]++`, `v++`) and a named-block
local (`garr[m]++` in `begin : nb2 int m;`) BARE. The laws raise
suppressRefActual over these bodies and the § 218 window does not cover an
inc/dec operand, so they lost the binding.

Refinement: while the operand of a statement-position ++/-- is emitted (the
§ 21 token: outside a control body), a reference reaching the
suppressRefActual branch whose symbol is a formal, a subroutine local or an
unnamed-block local of a program in `uninstProgDefs` binds its netMap object
(file-static depth incDecProgDepth439v and predicate incDecProgSym439v at the
top of ExprEmit; the bind sits beside § 218's in that branch; lawTrace(439,
"uninstProgIncDecBinds439v", ...)). Reached only inside the two program laws'
emission, so R11U439_OFF still gives pristine's bytes. The same face in an
UNINSTANTIATED INTERFACE (VI/vi07, vi08: golden binds, pristine and law leave
bare) is pre-existing and left alone (residue).

VI grid (exit codes 0 on all three binaries, Surelog 0): vi01 pristine
STRICT_EQUAL, law NOT_EQUAL, verified STRICT_EQUAL; vi04, vi09, vi12 to
STRICT_EQUAL on the verified binary (law NOT_EQUAL); vi05, vi11, vi13
NOT_EQUAL on all three with the verified dump 15 lines from golden, exactly
the sister's program-net listing of a subroutine local (below); vi02, vi03,
vi06, vi10 controls STRICT_EQUAL on law and verified; vi07, vi08 (interface)
byte-identical on all three.

## Reproduction of the implementer's numbers

- Law build md5 = law7. Grid: the 65 case dirs rerun on pristine and law,
  every line equal to evidence/grid_final.tsv on exit code, uhdm-cmp count,
  dump distance and strict verdict (md5 differs only by the work path).
- Switches: R11U439_OFF gives pristine's bytes on 65 of 65; each case's own
  switch on 57 (the 8 pairs as claimed).
- Law sweep (/tmp/v11u439_LW, tests/sweep.sh --jobs 3 for probe, surelog,
  uhdm2rtlil, downstream from the worktree, svtests through the main tree's
  scripts/check_svtests.py with --baseline the worktree's
  results/golden_svtests.csv; scripts/ and tests/sweep.sh identical between
  db1d84d3 and HEAD): probe EQUAL=4023 STRICT_NOTEQUAL=64, 0/0/0; surelog
  480 / 474, 0/0/0; uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream
  IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2; sv-tests EQUAL=1908
  STRICT_NOTEQUAL=0 DIFFERENT=32 BOTH_REJECT=303 SURELOG_ONLY=75 SLANG_ONLY=19
  SURELOG_CRASH=8 TIMEOUT=1, 0/0/0. Every csv equal to the implementer's and
  to the control (surelog differing only in the two LowMem log-path texts).
  The corpus run exited 1 only on the law index (stale because this
  directory's cases were added; regenerated).
- byteverify (SELFCHECK=1) law against /tmp/intr11u437: 0 of 962, 0 of 1608,
  0 of 805 movers, self-checks 961, 1607, 804 flagged; the 4087 probe
  databases identical by path-normalized dump (positive control: two
  different databases 785 lines apart).
- Canaries ok=52 and ok=16 changed=0; ctcan2 PASS with EXPECT_UNKNOWN=1 and 6.
- Binary audit (fence-filtered): surelog 1523 of 1573 cmds records name the
  law binary, the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740;
  sv-tests 2346 of 2346.
- Trace census: uninstProgBodyAsUninstIface439 and
  uninstProgSubBodyAsUninstIface439 on SimpleConstraint default and testflags
  and the 9 named probe databases; the skip laws and
  § loopVarReadBindsModuleDecl439 nowhere. Same set as the implementer's.
  A fence-filtered scan of 22078 corpus, probe and sv-tests sources finds no
  leading or trailing empty foreach slot.

## Attack grid (cases/, 76 case dirs: VP 23, VL 22, VS 18, VI 13)

Every case accepted by upstream slang (~/.local/bin/slang dut.sv
--single-unit), Surelog exit 0 on all, every exit code 0 and equal on the
three binaries (evidence/grid_attack.tsv: p, l, v columns). Pristine ->
verified: 55 to STRICT_EQUAL, 13 NOT_EQUAL on both and closer by dump
distance, 6 byte-identical residues, 2 byte-identical STRICT_EQUAL (VL/vl03,
and VI/vi01 which the law broke), none further. Law -> verified moves only
VI/vi01, vi04, vi05, vi09, vi11, vi12, vi13.

- VP (program laws): for-loop variables, function calls and returns, package
  and $unit variables, parameters and functions, enum and struct members,
  fork/repeat/while/final, task formals and locals, a static function local,
  a port event control, case/if, a named-block local, selects and $bits, a
  continuous assign beside the body, an assertion, event trigger/wait/delay,
  a struct-member foreach, a leading skip in a program task, two programs
  with one instantiated, a program inside a module (byte-identical, a
  different face), a class in a program; also `--top prg` (Surelog `-top prg`
  still does not elaborate the program: law STRICT_EQUAL, pristine NOT_EQUAL;
  run outside the grid in /tmp/v11u439_top).
- VL (§ loopVarReadBindsModuleDecl439): an output port, a later declaration,
  event, real, wire with an assign, parameterized instances, always_comb,
  final, nested foreach, a module task's local, a named block, a class
  method beside a module variable, an instantiated program; the `with`
  iterators of find, find_index, sort and sum(x) beside a module `item`/`x`
  variable (to STRICT_EQUAL except vl20, closer: golden also binds the sum
  argument's declaration ref). Abstaining shapes byte-identical: an
  instantiated interface (vl01: golden binds the interface's int_var, ours
  writes none on all binaries), a typedef (vl06), an interface port (vl08), a
  function (vl03, equal).
- VS (skip laws): module function, package class method, dynamic and
  associative arrays, `[, j, ]`, `[, , , l, ]`, two loops, nested loops
  with a named outer and both leading skips, two instances, an instantiated
  program, always_comb, task, uninstantiated program, class method, an
  uninstantiated interface.
- Switches (drivers/vswitches.sh over all 141 case dirs, both grids): on the
  verified binary R11U439_OFF gives pristine's bytes, R11V439_OFF and
  R11V439_INCDEC_OFF give the law's bytes, 141 of 141. On the law binary
  (drivers/switches.sh) R11U439_OFF gives pristine's on the 63 non-VI attack
  cases, each case's own switch on 57, the other 6 restored by the pair.
- Downstream (drivers/dsgrid.py, the 31 class-, program- and interface-free
  attack cases): IDENTICAL on pristine and verified for all 31.

## Earlier-case census (drivers/census.sh, movers.sh)

1427 fence-filtered sources under tools/probe holding `foreach` or `program`
(1077 dut.sv plus 350 other .sv files; this pass's dirs excluded;
evidence/census_paths.txt), each run alone by both binaries into one output
path. Pristine -> law: exit codes equal everywhere; 131 movers, each judged
against a fresh Surelog golden (evidence/census_movers_judged.tsv): 40 to
STRICT_EQUAL, 88 closer by dump distance, 2 with no golden (r11u162verify tds
t01, t07: Surelog exit 3), **1 further: r10vbuvm21repro/v2home.sv 282 -> 284,
the break above**. Law -> verified: 1 mover, v2home.sv, its verified dump
identical to pristine's (evidence/census_law_verified.tsv).

## Verified sweep (/tmp/v11u439_VF, the same five stages)

PREDICTED before the sweep (evidence/prediction_verified.txt): the fix
fires nowhere (the law sweep's program-law databases hold no
statement-position ++/-- over a formal or local), no csv or byte moves
against the law sweep.

Read: probe EQUAL=4023 STRICT_NOTEQUAL=64, 0/0/0; surelog 480 / 474, 0/0/0;
uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream IDENTICAL=803
SLANG_REJECT=66 EQUIVALENT=2; sv-tests EQUAL=1908 STRICT_NOTEQUAL=0
DIFFERENT=32 BOTH_REJECT=303 SURELOG_ONLY=75 SLANG_ONLY=19 SURELOG_CRASH=8
TIMEOUT=1, 0/0/0 (corpora rc 0, law index current). Every csv equal to the
law sweep's and to the control's (surelog only the two LowMem log paths).
byteverify (SELFCHECK=1) verified against law and against /tmp/intr11u437:
0 of 962, 0 of 1608, 0 of 805 movers both ways, self-checks 961, 1607, 804;
the 4087 probe databases identical to the control by path-normalized dump.
Canaries ok=52 and ok=16 changed=0, both ctcan2 PASS. Binary audit:
surelog 1523 of 1573 records name the verified binary (the other 50 a
Surelog line only), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346. Trace:
the same 11 databases as the law sweep, the fix firing in none (positive
control: a traced run of VI/vi01 logs `uninstProgIncDecBinds439v s`).

## Goal 1

Nothing on this ground. The 75 SURELOG_ONLY rows carry no exporter message
(grep -ciE 'unsupported|slang-uhdm:' over their details: 0). Probe shapes on
the verified binary: v11u415 VT/vt03 slang 0, pristine 0, verified 0;
v11u413 VC/vc04 and VI/vi06 slang 0, pristine 4, verified 4 (Surelog rejects
all three, golden has no shape). bp_unicore measured alone on the verified binary
(drivers/memrun.py over the sweep's own command line, quiet machine): exit 3
(`basic_string::substr` under pass 403's size guard) in 13.8 s at 818 MB; no
memory-bounded export, the guard stands. generated/rsd/rsd.sv stays
SURELOG_CRASH.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The same inc/dec binding face in an UNINSTANTIATED INTERFACE (VI/vi07,
   vi08): golden binds `s` in `garr[s]++`, pristine, law and verified leave
   it bare (the § 218 window lacks the inc/dec operand); the fix is fenced to
   programs.
2. An instantiated program's foreach (UP/up19, VP/vp09, VS/vs09): golden
   array_var loop variable bound by the reads.
3. A loop variable named like a port or a named-block local (VL/vl02, LM/lm11):
   golden's loop variable a ref_var over the declaration's typespec.
4. Loop variables the walk abstains on: an instantiated interface's member
   (VL/vl01), a typedef (vl06), an interface port (vl08); the declaration
   ref of a `with` argument (vl20).
5. A program nested in a module (VP/vp08): golden folds it into the module.
6. The implementer's residues (generate-block and package-function foreach,
   a parameter of the loop variable's name) and the carried lists of pass 437
   and earlier.

## Sister-ground faces (reported, not written)

- Program net listing (ModuleEmit's program road with TaskFuncEmit's locals):
  golden lists a task or function local of an uninstantiated program as a
  program logic_net (VP/vp06, vp07, vp20, VI/vi05, vi11, vi13; the
  implementer's up12, up15), and does NOT list a for-loop's declared variable
  `for (int k ...)` in an initial, which ours lists as `logic_net work@prg.k`
  on all binaries (VP/vp01).
- An unpacked `[N]` dimension's range located at the whole bracket and folded
  where golden spans the size token and writes `N-1` (VS/vs03 `int d[][3]`,
  vs16 `logic [7:0] m [int][4]`; TypeEmit's range builder, the implementer's
  ls25).

## Process

- One law build (equal to law7) and one verified build; no pristine build.
  Two sweeps: the law binary and the verified binary (production changed).
- The fence list read by a program into /tmp/v11u439_fenced.txt and never
  printed; every tree-wide list filtered on it before a file was opened; no
  fenced test named, opened or run.
- Slips, none affecting a measurement: the earlier-case census (pristine
  and law, single sequential case runs) was launched while the sister
  r11u442's pristine sv-tests runner was live (my quiet check printed it and
  I did not gate on it); its rows compare exit codes and bytes, not timing,
  and no case timed out. The sister's sweep started its probe stage about
  18:28, the minute my verified corpora stages ended (18:28:06); my verified
  sv-tests stage waited for three quiet readings after the sister's.
