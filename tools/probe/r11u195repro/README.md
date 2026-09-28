# r11u195 — the expression/parameter ground: the r11u191 decode's three ground-A laws landed and refined (the evaluator reduces only the operators its switch lists), a function-computed struct parameter's pattern listed with a bare reference, a process read on a net base kept in its dotted form, a package pattern member read located at the member's value, a parenthesized pattern member spanned with its parentheses; 2 row-modes and 7 probe cases converted

**Base.** `b6344400` (branch matrix-1.87, pass 192). Worktree `/tmp/wt_r11u195`, system-deps config, `-j 2` (`-j 1` while
another agent's build was running). Ground A only: `src/ExprEmit.cpp`, `src/ParamEmit.cpp` (no `EmitHelpers.h` or
`StmtEmit.cpp` change was needed). Nothing under `results/`, `tests/` (but the regenerated `tests/LAWS.md`) or
`third_party/` is edited. The sister pass r11u193 (module/type ground) had not landed; none of its files is touched.

**The fence.** Every driver here that reads a corpus source or database takes the four names from the `FENCED=` line
of `tools/probe/r11u107repro/canaudit.sh` and refuses them fail-closed (`drivers/env.sh`; `rowhead.sh`, `obrow.sh`
refuse a fenced name; `census.sh` runs the corpora with a `--filter` built from the fence; `bvmirror.sh` leaves the 8
fenced row-mode databases out of the byte comparison: `fenced_skipped=8`). The gate sweeps dispatched every row, as
the gate requires; their csv verdicts are the only fenced facts cited (all unchanged). A grep of this directory for
the four names reads 0.

## 0. Verdicts

| row / face | before (b6344400) | after | law |
|---|---|---|---|
| **StructParamPatternInitCast default** | `STRICT_NOTEQUAL differ:fullname(3)` | **`CMP_EQUAL`** | § funcCfgPatOpRefBare195 |
| **StructParamPatternInitCast testflags** | `STRICT_NOTEQUAL differ:fullname(3)` | **`CMP_EQUAL`** | § funcCfgPatOpRefBare195 |
| Earlgrey_0_1 d/t | `differ:col(91)` | `differ:fullname(82)` | § pkgFoldAtLeadingLeaf191 (the first record) + § procNetMidSelDotted195 (the `reg2hw.key[i].q` family); section 5 |
| MiniAmiq d/t | `differ:file(27)` | `differ:file(25)` | § idxCallPathAtDots191 |
| SeqDriver d/t | `differ:file(26)` | `differ:file(24)` | § idxCallPathAtDots191 |
| SimpleUVM d/t, Scoreboard d | `differ:fullname(54)` | `differ:fullname(52)` | § idxCallPathAtDots191 |
| Scr1SvTests d/t | `differ:type(1)` | `differ:endcol(29)` | § evalFuncExecCallArgTs191 |
| probe r10fiot_repro/a9 | `STRICT_NOTEQUAL differ:type(1)` | **EQUAL** | § evalFuncExecCallArgTs191 |
| probe r10earl62repro/g1_earl62, g2_earl62 | `differ:col(1)`, `differ:col(2)` | **EQUAL** | § tagPatParenSpan195 |
| probe r11u109repro/grid/f1/c01_x64, c02_x3, c03_x8, c05_x3sub | `differ:fullname(3)` | **EQUAL** | § funcCfgPatOpRefBare195 |
| probe r11u109repro/grid/f1/c04_x64cast, c06_x64plain | `differ:fullname(5)` | `differ:value(2)` | § funcCfgPatOpRefBare195 (the next face is an ExprEval value, section 7) |
| probe r11u26repro/m12 | `differ:line(5)` | `differ:fullname(4)` | § pkgPatMemberReadAtValue195 (its first record gone, the other four unchanged) |

The fresh rows (not written to `results/`):

    StructParamPatternInitCast,default,CMP_EQUAL,,,equal       (baseline STRICT_NOTEQUAL differ:fullname(3))
    StructParamPatternInitCast,testflags,CMP_EQUAL,,,equal     (baseline STRICT_NOTEQUAL differ:fullname(3))
    r10earl62repro/g1_earl62,EQUAL,,equal                      (baseline STRICT_NOTEQUAL differ:col(1))
    r10earl62repro/g2_earl62,EQUAL,,equal                      (baseline STRICT_NOTEQUAL differ:col(2))
    r10fiot_repro/a9,EQUAL,,equal                              (baseline STRICT_NOTEQUAL differ:type(1))
    r11u109repro/grid/f1/c01_x64,EQUAL,,equal                  (baseline STRICT_NOTEQUAL differ:fullname(3))
    r11u109repro/grid/f1/c02_x3,EQUAL,,equal                   (idem)
    r11u109repro/grid/f1/c03_x8,EQUAL,,equal                   (idem)
    r11u109repro/grid/f1/c05_x3sub,EQUAL,,equal                (idem)

Totals of the law sweep against the committed baselines: **surelog regressions=0 conversions=2 changes=11; uhdm2rtlil
regressions=0 conversions=0 changes=0; probe regressions=0 conversions=7 changes=3; downstream 803 IDENTICAL / 66
SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, `downstream.csv` byte-identical to the pristine sweep's**. 17 of 2560
corpus databases and 10 of 4087 probe databases move, every one predicted by name by the frozen firing census
(section 4); 0 of 805 downstream-lane databases move.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u195_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `6d53eebe71a2327f4e3c89a48c6886a4` | the worktree at `b6344400`: byte-identical to the main tree's `build/slang-uhdm` |
| `law191.bin` | `46b90eb7a30d7d40b02fa8f4d8eaaa00` | `b6344400` + `tools/probe/r11u191dec/law_exprstmt.patch` as written (it applies clean, textually unchanged) |
| `law.bin` | `041d66a5a7d67c73ec5c0caa93837941` | the first full draft (its census, section 4, read 4 probe + 2 surelog regressions) |
| `lawF.bin` | `e94ce8e2d3fe4146a9bd3cb619244c53` | the draft with the evaluator gate of § funcCfgPatOpRefBare195 (census + a full law sweep `/tmp/r11u195_swL`, identical verdicts to the final one) |
| **`lawG.bin`** | **`6e9366b66a6caf3d348dbb935ef02652`** | **THE DELIVERED SOURCES** (`/tmp/r11u195.patch` applied to a fresh `b6344400` rebuilds it, section 9) |
| `law1..law16.bin` | | development steps |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages, `SLANG_UHDM` exported, same-length workdirs): `/tmp/r11u195_swP`
(pristine) and `/tmp/r11u195_swG` (lawG; `/tmp/r11u195_swL` is the same sweep of `lawF.bin`, every stage verdict
identical). `cmds.txt` audit: swP 3273 of 3273 `slang:` lines name `/tmp/r11u195_bin/pris.bin`, swG 3273 of 3273
`/tmp/r11u195_bin/lawG.bin` (swL 3273 of 3273 `lawF.bin`). The pristine sweep reproduces the
baselines exactly: `probe.csv` byte-identical to `results/golden_probe.csv` (EQUAL 3155 / STRICT_NOTEQUAL 932),
surelog and uhdm2rtlil `regressions=0 conversions=0 changes=0` (480/3 + 474/3; 803/1/67 both modes), downstream 803 /
66 / 2 / 0. The law sweep exits 1 for one reason only, `law index STALE: tests/LAWS.md` (the new `§` names in the
sources); the patch carries the regenerated `tests/LAWS.md` (`python3 scripts/law_index.py --check` reads 0 on the
patched tree).

## 2. Switches (every law droppable alone; `R11U195_OFF` drops the whole pass, the r11u191 laws included)

| switch | law | file | what it restores |
|---|---|---|---|
| `R11U191_HPENDCOL_OFF` | § idxCallPathAtDots191 | ExprEmit.cpp | pristine |
| `R11U191_EARLCOL_OFF` | § pkgFoldAtLeadingLeaf191 | ParamEmit.cpp | pristine |
| `R11U191_EVALTS_OFF` | § evalFuncExecCallArgTs191 (with its refinement) | ExprEmit.cpp | pristine |
| `R11U195_EVALOP_OFF` | § evalFuncOpReduceGate195 (refines § evalFuncExecCallArgTs191) | ExprEmit.cpp | the r11u191 law as written (`law191.bin`'s bytes) |
| `R11U195_FUNCCFGPAT_OFF` | § funcCfgPatOpRefBare195 | ParamEmit.cpp | pristine |
| `R11U195_PROCNETSEL_OFF` | § procNetMidSelDotted195 | ExprEmit.cpp | pristine |
| `R11U195_PATMEMLOC_OFF` | § pkgPatMemberReadAtValue195 | ParamEmit.cpp | pristine |
| `R11U195_TPPAREN_OFF` | § tagPatParenSpan195 | ExprEmit.cpp | pristine |
| `R11U191_OFF` | the three r11u191 laws (their own switch, as the decode delivered it) | | |
| `R11U195_OFF` | every law of this pass, the r11u191 three included (the r11u191 switch helpers read it too) | | pristine |

`R11U191_TRACE=<dir>` / `R11U195_TRACE=<dir>`: one file per process and translation unit (`<pid>.EX`, `.PE`, `.EX195`,
`.PE195`), first line `OUT <-o path>`, then one law name per firing, on the branch that changes a field (for
§ evalFuncOpReduceGate195: where it declines what the r11u191 law would have stamped).

Measured ([evidence/switchcheck.txt](evidence/switchcheck.txt), `drivers/switchcheck.sh`, each switch alone on its
own grid, `lawG.bin`): every switch restores the bytes it names on every case of its grid (A 6/6, B 5/5, C 5/5, G
20/20 against `law191.bin`, S 30/30, K 17/17, T 10/10, P 12/13: P/p02 `D:(8)` also fires § tagPatParenSpan195).
`R11U195_OFF=1` alone: pristine bytes on all 106 grid cases ([evidence/off_alone_grid.txt](evidence/off_alone_grid.txt)),
and on the 17 corpus movers 10 byte-identical and 7 (BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d) with
0 or 4 order-blind dump lines, the 4 being the known UVM `UINT`/`vpiDecompile` value coin of the pristine binary
itself (`|UINT:1115` / `|UINT:1151`, ...; [evidence/offcheck.txt](evidence/offcheck.txt)).

## 3. The laws

### 3.0 The r11u191 decode's ground-A laws, rebased and re-verified

`tools/probe/r11u191dec/law_exprstmt.patch` (written at `a1c89c1a`) applies clean and textually unchanged on
`b6344400`; pass 192's edits in the same files do not overlap it. The three laws keep their statements, sites and
switches (the decode's README, sections 3a1, 3b1 and 3c2, holds the Surelog decode):

* **§ idxCallPathAtDots191** (`R11U191_HPENDCOL_OFF`, ExprEmit, a wrapper at the top of `emitExpr`): a method call
  written in the index of a select that a `.` continues, or in a range select's bound / an indexed range's width, is
  a `Subroutine_call` of Surelog's constant grammar: every path component but the call sits zero-width at the dot after
  it, and the path takes the first name's span.
* **§ pkgFoldAtLeadingLeaf191** (`R11U191_EARLCOL_OFF`, ParamEmit, the generic param_assign tail, package scope): a
  folded package-parameter constant located at the whole initializer moves to its leading leaf (the taken branch of a
  constant ternary, then the first operand of a binary operation; parentheses are no node).
* **§ evalFuncExecCallArgTs191** (`R11U191_EVALTS_OFF`, ExprEmit, beside `stampCond48`): ExprEval::evalFunc stamps the
  formal's typespec on the part-select and indexed-part-select actuals of the calls a continuous assignment's module
  function executes (the first call only when the outer argument is not constant).

Re-verification ([evidence/r11u191_grid_lawF.tsv](evidence/r11u191_grid_lawF.tsv)): the decode's own cases reproduce
at `b6344400` with `lawF.bin` exactly as the decode measured them (E/e01, H/h01 h04 h05 h07 h09 h10, V/v01 v02 v04
convert; E/e02 H/h02 H/h08 H/h11 Y/y01 controls byte-identical; H/h03 `endcol(7) -> col(2)`, H/h06 `endcol(3) ->
col(1)` as the decode's residues 3 and 7). Fresh cases, 2-6 per law (cases A, B, C):

* § idxCallPathAtDots191: A/a01 (a call index with a NAME argument, lvalue and rvalue: the composition with
  § trailIdxCallArgNamesByPath187 and § hpIdxCallNameSpan184), A/a03 (a range select and an indexed range in a task,
  inside a concatenation), A/a05 (as a call argument and in a return), A/a06 (module scope, an `initial` block) convert;
  A/a02 (a two-level receiver path; a select in the receiver `arr[i].c.get_name()`, which the law declines) moves
  `endcol(9) -> endcol(3)`; A/a04 (a plain select, a call inside `$clog2`, `this.`, a select receiver) byte-identical.
* § pkgFoldAtLeadingLeaf191: B/b02 (the folded parameters as part-select bounds through a wildcard import: the
  composition with § psBoundPaOwnerName192) and B/b03 (a macro-born ternary and leaf, read through `p::`) convert;
  B/b01 and B/b05 are judge-unequal on other faces and every package param_assign right side now carries golden's
  span there (the multiset of `param_assign => constant` spans equals golden's, where pristine's did not); B/b04
  (a plain sum, a module parameter) byte-identical.
* § evalFuncExecCallArgTs191: C/c01 **broke** (legal SV where pristine was right: `r = r ^ g(x[i*2+:2])` in a for
  loop, golden bare, the law stamped it: EQUAL -> `type(1)`), and C/c02 (`return g(lv[2:0]) | g(lv[5:3]);` after
  `lv = x;`) stayed `type(1)` with only the first call stamped where golden stamps both; both are fixed by
  § evalFuncOpReduceGate195 below (C/c01 EQUAL again, C/c02 converts). C/c03 (the same function called by a constant
  and by a non-constant continuous assignment) is judge-unequal on a value face and moves toward golden (order-blind
  22 -> 8); C/c05 (nested calls) judge-unequal and byte-identical; C/c04 (a package function, a call behind an `if`)
  byte-identical.

### 3.1 § evalFuncOpReduceGate195 (`R11U195_EVALOP_OFF`, ExprEmit; refines § evalFuncExecCallArgTs191)

**The break.** C/c01 above and its eight variants G/g07 g09 g11 g12 g13 g14 g15 g19 read EQUAL on the pristine binary
and `type(1)` with the r11u191 law (the law stamps an actual golden leaves bare).

**Decode.** UHDM `ExprEval::reduceExpr` (templates/ExprEval.cpp, the operation branch) reduces an operation's
operands — and so runs `evalFunc` on a user call written there — only for the operator kinds its switch lists: `+ -
* / %`, `& |`, `== != < <= > >=`, `&& ||`, the four shifts, `**`, the unary `+ - ~ ! & | ^ ~& ~| ~^`, `?:`,
concatenation, replication and the cast; `^`, `~^`, `===`, `!==`, the wildcard equalities and the implications fall
through the switch and the operation comes back unreduced, its call never evaluated (G/g07 `r ^ g(...)`, g11 `r =
r ^ g(x[1:0])`, g19 `g(...) === 1'b1`). And before the switch, an operand that is a NAME whose value `getValue`
cannot find (an unassigned local) sets `constantOperands = false`: nothing is reduced (G/g15 `t + g(...)` with `t`
unassigned, golden bare; G/g17 `t = x[0]; r = t + g(...)`, golden stamped).

And a non-constant run does not stop at the first CALL but at the first STATEMENT that meets one: `reduceExpr`
reduces both operands of `|` or `+` before it looks at `invalidValue`, so every call its operators reach in that
expression is evaluated (C/c02 and G/g21 `g(x[1:0]) + g(x[3:2])`: both stamped), while a concatenation is reduced
operand by operand up to the first unreducible one (G/g24 `|{g(..), g(..)}`: the first only) and a ternary evaluates
its taken branch (G/g22: the condition's call only).

**Law.** The r11u191 walk meets a statement's first call only when every expression above it inside the statement is
one of those operators (a conversion, a conditional, a concatenation or replication; the statement's own plain
assignment), and no direct name operand of a binary operation on the way is a local not assigned so far (a for
loop's own variables, a declaration with an initializer and an assignment count). Otherwise the walk stops there
(abstains) and nothing after it is stamped. When the run stops at that statement (a non-constant argument), every
other call of the same expression reached through the listed binary and unary operators only (no ternary,
concatenation, replication or call argument on the way) is met too.

**Grid** (cases/G, the c01 variants g06-g20 and g21-g25; `pris / law191 / lawG`): the 9 breaks read EQUAL again
(C/c01, G/g07 g09 g11 g12 g13 g14 g15 g19; G/g23 two calls under an XOR stays EQUAL), the r11u191 conversions are kept
(G/g06 g08 g10 g17 g18 g20 g22 g24 convert from `type(1)`), C/c02, G/g21 and G/g25 (a later statement after the
stopping one) convert; G/g16 (an XOR statement followed by a second call) stays `type(1)` as on pristine: golden runs
on after the unreduced XOR and stamps the second call, but stops after a case equality (g19): the continuation after
an unreduced operation is not modelled, the walk abstains (residue R3).

**Rows.** None in the corpora or the probe set (the census reads 0 firings there): the refinement keeps the
r11u191 law's measured rows (Scr1SvTests d/t, probe a9) and removes a break no gate case carried.

### 3.2 § funcCfgPatOpRefBare195 (`R11U195_FUNCCFGPAT_OFF`, ParamEmit; StructParamPatternInitCast d/t)

**Head** (pass 192's R3; `drivers/rowhead.sh`, the pristine sweep's databases):

    #324 fullname  ref_typespec  golden ''                          ours 'work@StructParamPatternInitCast'
    #327 fullname  ref_typespec  golden '...INT.S_SW'               ours 'work@StructParamPatternInitCast.S_SW'
    #333 fullname  ref_typespec  golden '...INT.M_SW'               ours '...M_SW'

the elaborated `INT` param_assign's pattern operation (`localparam it_t INT = '{S_SW: ..., M_SW: ...}` with `it_t` a
struct whose members are `logic [Cfg.XLEN-1:0]`, `Cfg = cfg_pkg::build_config(cfg_pkg::Base)`): golden's operation
holds an UNPARENTED `ref_typespec` (no full name) whose struct copy is parented at a `ref_typespec` named
`work@StructParamPatternInitCast.INT`, so the members' references are named through the parameter; ours parented the
reference at the operation (`mintParamOpClones` stamps `syntaxRefPrefix`, the module) and named the members at the
module.

**Decode.** NetlistElaboration.cpp (`elabParamAssign`'s regular-parameter loop, the `vpiAssignmentPatternOp` branch):
`rhs = clone_tree(instance->getComplexValue(paramName))` when the instance holds a complex value, then
`expandPatternAssignment(ts, ...)` with `ts` the parameter's own typespec. The complex value exists when Surelog could
not size the struct while it compiled the module: its member ranges read a struct-valued parameter that a constant
function computes. The grid pins the distinguisher on golden (cases/S): unparented when the struct's ranges read such
a parameter directly (s01 = the corpus test, s02, s09 a literal pattern, s11 a typedef, s24 a wildcard import), through
another parameter (s15 `X = Cfg.XLEN`), through a package parameter a function computes (s16 `Def = mk(8)`), in a
child instance (s17) and at depth 2 with two instances (s21), macro-born (s23); PARENTED (pristine right) when `Cfg` is
a literal pattern (s13) or a package pattern reference (s06), an `int` parameter a function computes (s14), the struct
does not read `Cfg` (s03, s10, s12), the pattern nests a pattern (s27 `'{I: '{S: 1}, M: 3}`; a nested struct TYPE with a
flat pattern, s28, is unparented), and when the function's body is one ExprEval cannot carry to a value (probe
`r11u109repro/grid/f1/b01`-`b04`: `r.Flag = (c.NrRules > 0) && (c.Length > 0)` over a 1024-bit member; the corpus
twin StructParamFuncBodyFieldCompare) — the first draft of the law claimed those and the first census read
`b01`-`b04` and StructParamFuncBodyFieldCompare d/t `EQUAL -> fullname(1)` (section 4): the delivered law carries the
evaluator gate below.

**Law.** An elaborated MODULE packed-struct parameter (not overridden) listed by the flat op75 walk whose pattern is
flat, and whose struct member dimensions read — directly, through parameters or through package parameters — a
struct-valued parameter initialized by a user function call (not overridden) whose body is local declarations,
member assignments from a formal, a formal's member, a literal or `+ - * / % << >>` of those within 64 bits, and
`return <local>;`: the pattern's `ref_typespec` gets no parent and no full name, its struct copy is parented at the
parameter's own `ref_typespec`, and the copy's member references are named through the parameter (the
§ importPatOpCloneParamNamed163 prefix). Both sites: `mintParamOpClones` and `patchParamTypespecs`' fallback.

**Grid** (cases/S, 30 cases): 11 convert (s01 s02 s09 s11 s15 s16 s17 s21 s23 s24 s30); 17 byte-identical: the
controls s03 s05 s06 s10 s12 s13 s14, the declines s27 (a nested pattern) and s29 (the 1024-bit body), and the
judge-unequal s04 s07 s08, s18 / s19 (instance overrides), s22 / s25 / s26 (a generate-scope localparam, an interface,
an unpacked struct); s20 (a header type parameter, judge-unequal on another face) and s28 move with the order-blind
distance to golden falling (61 -> 48, 159 -> 144).
**Rows:** StructParamPatternInitCast d/t convert; probe f1 c01 c02 c03 c05 convert, c04 c06 move `fullname(5) ->
value(2)` (their next record is ExprEval's value of the `Cfg.XLEN'(1)` cast: residue R6).

### 3.3 § procNetMidSelDotted195 (`R11U195_PROCNETSEL_OFF`, ExprEmit `emitMixedHierPath`; Earlgrey N0941 / N0061)

**Head** (Earlgrey_0_1 after § pkgFoldAtLeadingLeaf191; aes_core.sv 109, `key_init[i] = reg2hw.key[i].q;` in an
`always_comb` for loop):

    #60978 fullname  bit_select key  golden 'reg2hw.key[i]' 109:31-34    ours 'work@aes_core.key_init_get.reg2hw.key[i].q.key' 109:35-36

**Decode.** Reproduced in K/k01 / k02: the same rvalue in a continuous assignment and on a `var` port (a VARIABLE
base) already reads golden's simple dotted form at the member name with an unparented index constant (the branch
"an rvalue element-select on a struct VARIABLE member array that is followed by a further member" — Surelog keeps
`t.my_array[0]` in a process and in a cont-assign); a NET base (a struct input port, `reg2hw` in aes_core) in a
process fell to the "PROCESS-context and IFACE-PORT-based rvalues" branch (the doubled lazy name at the index). Golden
reads the dotted form for the net base too (k01 k02 k04 `always_ff`, `if` condition, `initial`; k07 a for loop).

**Law.** The variable branch also takes a NET base in a process for a mid-path select, unless the path is written
inside the brackets of another path's select (K/k12 `reg2hw.key[idx[reg2hw.key[0].qe]].q`: golden names the inner
select through the parents with a member+index span, a form neither branch writes, the law declines); inside a plain
array's brackets it holds (k14 `cnt[reg2hw.key[1].qe]++`).

**Grid** (cases/K, 17): 8 convert (k01 k02 k04 k07 k14 k15 `regs[1].key[2].q` two-level, k16 two mid selects, k17
macro-born from an included header), k12 `fullname(14) -> col(10)` (the outer path fixed, the nested one declined),
controls byte-identical: k05 (a `var` port), k06 (a function body), k09 (a trailing select), k10 (an interface port),
k11 (processes in one- and two-level for-generates, where golden already agrees); k03 / k08 / k13 judge-unequal on
other faces, their order-blind distance falls (58 -> 46, 31 -> 19, 33 -> 29).
**Rows:** Earlgrey_0_1 d/t (8 firings each; section 5).

### 3.4 § pkgPatMemberReadAtValue195 (`R11U195_PATMEMLOC_OFF`, ParamEmit; pass 192's R4)

**Head** (pass 178's z04, r11v178's u08 u09): `localparam int W = B.D;` with `B = '{A:2, D:8}` in the same package:
the folded constant golden 4:33-34 (the member's VALUE `8`), ours 5:22-25 (the read).

**Decode.** Surelog reduces `B.D` to the member's value object, which it located when it compiled the pattern; the
value's own location follows the fold rule of § pkgFoldAtLeadingLeaf191 (cases/P: `(8)` -> the literal inside, p02;
`L + 1` -> `L`, p04; `B.D + 1` -> `B.D`, u09; a cast keeps its whole span `8'(7)`, p07).

**Law.** A package parameter whose initializer is a member read of a parameter holding a structured assignment
pattern, folded to a constant located at the whole read, is located at that member's value (parentheses stripped,
then first operands of binary operations), its file taken from the value (setLoc keeps a stamped file: the law clears
it first, so a pattern in another root file lends its file, P/p13). A ternary value, `default:` and positional
patterns and a module scope are not claimed.

**Grid** (cases/P, 13; and the tools/probe cases it names): z04, u08 (macro read), P/p01 p04 p07 p09 (a macro value
from an included header) convert; p02 `col(2) -> EQUAL` together with § tagPatParenSpan195; u09 `line(2) -> line(1)`
(its other record is the member read inside another pattern, `C = '{A:B.A}`: the op75 flat walk, residue R5); p03 p05
p08 p10 p12 p13 are judge-unequal on other faces and every package param_assign right side carries golden's span
after the law; p06 (a ternary value) and p11 (module scope) byte-identical.
**Rows:** probe r11u26repro/m12 `line(5) -> fullname(4)` (its first record, `AA = UU.a`, gone; the four others
unchanged).

### 3.5 § tagPatParenSpan195 (`R11U195_TPPAREN_OFF`, ExprEmit, the three member / index setter sites)

**Head.** `'{A:2, D:(8)}`: golden's `tagged_pattern` spans `(8)` (4:33-36), ours the value (4:34-35). slang keeps the
value's range without the parentheses but hands the `ParenthesizedExpression` as its syntax.

**Law.** A member or index setter's `tagged_pattern` whose value is written in parentheses spans the outermost pair
(`((2))` the outer one, `(4'd2 + 4'd1)`); the key `tagKey177f` recorded stays the value's. A `default:` setter is not
claimed (T/t05, judge-unequal).

**Grid** (cases/T, 10): t03 (a process, an operation value), t04 (an index setter), t06 (a module localparam), t08 (a
macro-born parenthesized value from an included header, and `\`PAR(4'd1)`), t09 (double parentheses beside a
`default:`) convert; t10 (a parenthesized nested pattern) `col(6) -> file(4)` (the tagged patterns fixed; the nested
pattern's member tags are unlocated: residue R7); t01 t02 t07 judge-unequal, order-blind distance falling (22 -> 16,
28 -> 16, 20 -> 14).
**Rows:** probe r10earl62repro/g1_earl62, g2_earl62 convert; BlackBePipeInt d/t bytes (2 firings each, beyond its
first record: order-blind distance 31841 -> 31837 and 31886 -> 31882).

## 4. The gates (`tests/sweep.sh --jobs 3`, all four stages, against the committed baselines at `b6344400`)

| gate | pristine `6d53eebe71a2` (`/tmp/r11u195_swP`) | law `6e9366b66a6c` (`/tmp/r11u195_swG`) |
|---|---|---|
| (1) build | = the main tree's build (md5 above) | `b6344400` + this patch |
| (2) probe vs golden_probe.csv | EQUAL 3155 / STRICT_NOTEQUAL 932, `probe.csv` byte-identical to the baseline | EQUAL **3162** / 925: `regressions=0 conversions=7 changes=3` |
| (3) surelog vs golden_surelog.csv | `regressions=0 conversions=0 changes=0` (460+20 / 456+18 judge-equal) | `regressions=0` **`conversions=2`** `changes=11`; judge-equal 461+19 / 457+17 (480 / 474 unchanged) |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `regressions=0 conversions=0 changes=0` (792+11 both modes) | `regressions=0 conversions=0 changes=0` |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; `downstream.csv` byte-identical to the pristine sweep's; 0 of 805 downstream-lane databases move |
| (5) uhdm-cmp | – | every mover keeps its judge status: the 17 corpus movers read CMP_EQUAL / STRICT_NOTEQUAL and the 10 probe movers EQUAL / STRICT_NOTEQUAL in the fresh csvs (quoted in [evidence/sweeps/movers_rows.txt](evidence/sweeps/movers_rows.txt)) |
| (6) byteverify (`SELFCHECK=1`, fence-free mirrors `fenced_skipped=8`) | | **17 / 2560 movers, every one PREDICTED by name** (0 moved-not-predicted, 0 predicted-not-moved); SELFCHECK 2559 / 2560 flagged ([evidence/sweeps/byteverify.txt](evidence/sweeps/byteverify.txt)) |
| probe movers | | **10 / 4087, every one predicted** (0 / 0) |
| canaries ([evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)) | surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 `EXPECT_UNKNOWN=1` / `=6` PASS | surelog ok=43 changed=9 (exactly the 9 canary rows among the 11 changes: all but MiniAmiq d/t), uhdm2rtlil ok=16 changed=0, both ctcan2 PASS |

Both sweeps exit 1 for one reason only, `law index STALE: tests/LAWS.md`, which the regenerated file in this patch
clears.

**The prediction** ([evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt), frozen `chmod 444`
before the law sweep). `drivers/census.sh` runs the law binary over every corpus row-mode but the fenced four (the
`--filter` built from the fence) and every probe case with `R11U191_TRACE` / `R11U195_TRACE` set; `drivers/censum.py`
lists every database a law fired on. It names 17 corpus row-modes and 10 probe cases; the byte comparison of the
sweeps moves exactly those. Per law, where it fires: § idxCallPathAtDots191 BuildUVMPkg d/t (9), MiniAmiq d/t (22),
SeqDriver d/t (21), SimpleUVM d/t (11), Scoreboard d (11); § pkgFoldAtLeadingLeaf191 Earlgrey d/t (1);
§ evalFuncExecCallArgTs191 Earlgrey d/t (2), Scr1SvTests d/t (1), probe a9 (3); § procNetMidSelDotted195 Earlgrey d/t
(8); § funcCfgPatOpRefBare195 StructParamPatternInitCast d/t, probe f1 c01-c06; § tagPatParenSpan195 BlackBePipeInt
d/t (2), probe earl62 g1 (1) g2 (2); § pkgPatMemberReadAtValue195 probe m12 (1); § evalFuncOpReduceGate195 nowhere
(grid only). The uhdm2rtlil corpus and the downstream lanes fire nothing.

**The census caught the first draft's breaks** (`/tmp/r11u195_cen0`, `law.bin`): probe `r11u109repro/grid/f1/b01`-`b04`
EQUAL -> `fullname(1)` and surelog StructParamFuncBodyFieldCompare d/t CMP_EQUAL -> `fullname(1)` —
§ funcCfgPatOpRefBare195 claimed a struct parameter whose function body ExprEval cannot carry to a value (a 1024-bit
member compare). The evaluator gate (section 3.2) fixed all six before any gate sweep; a second census (`lawF.bin`)
and a third (`lawG.bin`, identical prediction) read 0 regressions.

## 5. Attribution of every change

| row-mode / case | change | law, by the firing census and the per-law switch |
|---|---|---|
| StructParamPatternInitCast d/t | CONVERT | § funcCfgPatOpRefBare195 (the only law firing; `R11U195_FUNCCFGPAT_OFF=1` restores `fullname(3)`: S/s01 is the test's text) |
| Earlgrey_0_1 d/t | `col(91) -> fullname(82)` | Earlgrey default with each law off alone ([evidence/attrib_earlgrey_lawF.txt](evidence/attrib_earlgrey_lawF.txt), `drivers/attrib_earlgrey.sh`): all on `fullname(82)`; `R11U195_PROCNETSEL_OFF=1` `fullname(90)` (8 records: the `reg2hw.key[i].q` / `iv[i]` / `data_in[i]` / `data_out[i]` family); `R11U191_EARLCOL_OFF=1` `col(83)` (the first record, flash_phy_pkg.sv 43); `R11U191_EVALTS_OFF=1` `fullname(82)` (bytes only). 91 = 82 + 8 + 1 |
| MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d | count −2 each | § idxCallPathAtDots191 (the only law firing there); the same deltas as the decode's lawA |
| Scr1SvTests d/t | `type(1) -> endcol(29)` | § evalFuncExecCallArgTs191 (the only law firing) |
| BlackBePipeInt d/t, BuildUVMPkg d/t | bytes, cell unchanged | § tagPatParenSpan195 (order-blind 31841 -> 31837, 31886 -> 31882) and § idxCallPathAtDots191 (2071 -> 2035): beyond their first records |
| probe a9 | CONVERT | § evalFuncExecCallArgTs191 |
| probe earl62 g1 / g2 | CONVERT | § tagPatParenSpan195 |
| probe f1 c01 c02 c03 c05 | CONVERT | § funcCfgPatOpRefBare195 |
| probe f1 c04 c06 | `fullname(5) -> value(2)` | § funcCfgPatOpRefBare195: the three name records gone, the walk reaches the cast value (residue R6) |
| probe m12 | `line(5) -> fullname(4)` | § pkgPatMemberReadAtValue195: record #214 gone, the four fullname records unchanged |

No count grows on a still-failing row.

## 6. The UVM rows: order-blind distance ([evidence/uvmdist.txt](evidence/uvmdist.txt), `drivers/uvmdist.sh`)

| row | pristine | law | delta |
|---|---|---|---|
| MiniAmiq d / t | 16071 | 15963 | −108 |
| SeqDriver d / t | 12461 | 12337 | −124 |
| SimpleUVM d / t | 5070 | 4986 | −84 |
| Scoreboard d | 3877 | 3813 | −64 |
| BuildUVMPkg d / t | 2071 | 2035 | −36 |
| ApbSlave d / t | 0 | 0 | 0 |
| SVSwitch d / t | 102 | 102 | 0 |

Every UVM row falls by exactly the decode's law_exprstmt-alone delta (r11u191dec section 6: −108 / −124 / −84 / −64 /
−36): the whole move is § idxCallPathAtDots191's. The moved rows' first records after the pass
([evidence/heads/](evidence/heads/), `drivers/rowhead.sh` on the final sweep): MiniAmiq `#899` the `uvm_severity`
enum_typespec's file (golden uvm_globals.svh 271, ours uvm_object_globals.svh 242: a typedef-file face, ground B),
SeqDriver `#1677` the `uvm_bitstream_t` logic_typespec's file (ground B), SimpleUVM / Scoreboard `#458` / `#466` the
`UVM_MACRO_NUMFLAGS` ref_typespec full name (golden bare, ours `uvm_pkg::` qualified: residue R2), BuildUVMPkg `#2834`
the formal-default reference name (the sister's law formalDefaultNamedThroughFormal191, TaskFuncEmit), Earlgrey_0_1
`#90097` (section 8), Scr1SvTests `#30855` a range constant's end column (scr1_arch_description.svh 211:13-15 golden,
-17 ours: map 10's N0448, ground B), BlackBePipeInt `#66` (N0923, residue R10).

## 7. Ranked residues (what is left on this ground, and why)

1. **R1 — references inside a method call's operation arguments on a path (the UVM F5 family, N0175 / N0217 /
   N0220, map 10's largest open UVM cluster)**, decoded, not landed: r11u191dec's M/m01 `x = c.f(n, i + 1);` — golden
   names `i` `work@D::g::c.f::i` (no stored full name: UHDM ComputeFullName runs ref_obj -> operation ->
   method_func_call -> hier_path `c.f`), ours stores the scope name `work@D::g::i`; the DIRECT argument `n` already
   reads the path name in ours. `s.substr(i, args[i].len() - 1)`: the `i` inside a nested path in an operation
   argument reads `...::s.substr::i`. Site: ExprEmit's class-method call on a path (the argument loop after
   § writtenCallArgs16 in the `call.thisClass()` branch), with `builtinMethodArgNames154` (EmitHelpers.h), which does the
   rename for BUILT-IN methods only, as the model; the nested-path case needs the inner path's names to skip through
   the inner hier_path (not decoded).
2. **R2 — the UVM first records**: `UVM_MACRO_*` / `UVM_LINE_WIDTH` ref_typespec full names (golden bare, ours
   `uvm_pkg::` qualified; ParamEmit `makeParamTs`' reference name for package parameters read inside the package,
   N0682), then the ground-B heads above.
3. **R3 — § evalFuncOpReduceGate195's abstain**: after an unreduced operation golden's run continues through an XOR
   statement (G/g16: the next call stamped) but stops after a case equality (G/g19); the walk abstains at either (no
   corpus row carries it).
4. **R4 — § procNetMidSelDotted195's nested path** (K/k12): a path inside another path's index names its mid select
   through the parents with a member+index span (`work@top.reg2hw.key[].q.idx.reg2hw.key[0].qe.key`, 8:31-37) — a
   third form; declined.
5. **R5 — § pkgPatMemberReadAtValue195's other site**: a member read inside ANOTHER pattern (`C = '{A:B.A, ...}`,
   r11v178 u09 #98: golden at B's member value 4:28-29, ours the read 5:28-31) is the op75 flat operand walk, not the
   param_assign tail; and module-scope reads (P/p11) are judge-unequal.
6. **R6 — ExprEval value faces behind the conversions**: probe f1 c04 / c06 `value(2)` (the folded `Cfg.XLEN'(1)`
   cast value), C/c03 (`UINT` vs `BIN` of a folded constant call), r11u191's R4 (`$signed(12'h800)` -> `UINT:0`).
7. **R7 — § tagPatParenSpan195's nested pattern** (T/t10): a parenthesized nested pattern's member tags
   (`string_typespec a`) are unlocated in ours, golden 5:27-28; and the `default:` setter (T/t05, judge-unequal).
8. **R8 — § funcCfgPatOpRefBare195's limits**: interface parameters (S/s25), a generate-scope localparam (S/s22), a
   header type parameter (S/s20: moves toward golden, judge-unequal on another face), instance overrides (S/s18 / s19,
   judge-unequal), and function bodies outside the modelled shape (branches, loops, wide values: declined, s29).
9. **R9 — § idxCallPathAtDots191's residues** (unchanged from the decode): a select component in the receiver
   (A/a02 `arr[i].c.get_name()`: golden places the path at the select and `c` zero-width at its dot), the property path
   (H/h03), the spaced dot (H/h06: ExprEmit's receiver-call builders compute the name as `receiver end + 1`), the plain
   select's span (H/h02 / h08).
10. **R10 — carried from passes 184 / 187 / 192, not reached**: anon_struct_packed_dim's 4 N0820 records (the nested
    generate-scope path index `tq[gi].is_page[2-gx][0:0]`, ExprEmit `trailSelIdxNames133`; the row needs the sister's
    39 N0014 records), FuncStructVal / FuncStructValSimple (the `INT:N` constant-function leftovers), InterfArrayBind d
    (needs ModuleEmit), a8_orphan's port connections, BlackBePipeInt's N0923 (per-use copies of the cast-width
    typespec, ParamEmit `stampParenCastWidthTs` / `claimParenCastWidthOwner`: an identity family, not minted).

## 8. Sister-ground faces met on the way (call sites and laws; not edited here)

* **Earlgrey_0_1's next head after this pass** (`#90097`, alert_handler.sv 148, `.class_en_i(reg2hw_wrap.class_en[k])`
  in `gen_classes`): a port connection's trailing select in a for-generate instance. Reproduced in 12 lines
  ([evidence/residue/Q](evidence/residue/Q): q01 genvar index, q05 if-generate, q06 for-generate with a constant index;
  q03 module scope EQUAL): golden's bit_select is the lazy chain name through the port
  (`work@top.gen_classes.i_accu.class_en_i.reg2hw_wrap.class_en[k].class_en`) at the index span; ours (a) in the
  DEFINITION view writes the short dotted form at the member span — the generate block's instance connections are
  emitted by TypeEmit's `emitSyntaxExpr` (ModuleEmit's definition generate emission calls it) — and (b) in the
  ELABORATED view freezes the lazy name before the instance is parented at the generate scope
  (`work@top.i_accu.class_en_i...`, the scope missing): ModuleEmit's port connection of a generate-scope instance.
  Ground B.
* **struct_param_func_config d/t** `fullname(5)`: the struct member references of a function-computed parameter named
  through `u_c.Cfg` in ours, bare in golden (`TypeEmit.cpp buildStructTs`, map 10's N0817, law
  structMemberWrittenQueueArrayTs149's site).
* **BuildUVMPkg d/t** `fullname(20)`: the sister's law formalDefaultNamedThroughFormal191 (TaskFuncEmit).
* **const_cast_signext d/t** `type(1)`: the sister's law evalFuncCastMemberKeepsCall191 (ModuleEmit). Composition with
  § evalFuncExecCallArgTs191: the two predicates meet on continuous assignments whose right side is a module function;
  § evalFuncExecCallArgTs191 stamps only the part-select actuals of calls the body EXECUTES, law evalFuncCastMemberKeepsCall191
  decides whether the outer call folds at all; r11u191 measured the pair additive at `a1c89c1a`. Not measurable here
  (pass 193 has not landed).

## 9. Files, and how to reproduce

- The patch `/tmp/r11u195.patch` = `git diff b6344400` of `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, this directory and
  the regenerated `tests/LAWS.md`; it applies clean on a fresh `b6344400` and rebuilds `lawG.bin` byte for byte
  (measured: a fresh worktree `/tmp/wt_r11u195v` at `b6344400`, `git apply --check` clean, the build's md5
  `6e9366b66a6caf3d348dbb935ef02652`, `python3 scripts/law_index.py --check` current).
- `cases/<letter>/<case>/dut.sv` (106 cases; `args` lists several root files; every case names its law in its first
  line): A, B, C (fresh cases of the three r11u191 laws), G (§ evalFuncOpReduceGate195), S (§ funcCfgPatOpRefBare195),
  K (§ procNetMidSelDotted195), P (§ pkgPatMemberReadAtValue195), T (§ tagPatParenSpan195).
- `drivers/`: `env.sh` (pins, `$FENCED` fail-closed), `case.sh` (one case the way check_probe does, goldens cached per
  text md5 under `/tmp/r11u195_gold`), `judge.sh` (several binaries side by side, `=` marks bytes equal to the previous
  column), `grid.sh` (+ `OFFCHECK=1`), `switchcheck.sh` (each switch alone on its grid), `obdist.sh` (order-blind dump
  distance of a case), `rowhead.sh` / `obrow.sh` (a corpus row-mode's strict records / order-blind distance, fenced
  names refused), `census.sh` + `censum.py` (the firing census = the prediction), `bvmirror.sh` (the fence-free mirror
  for `tools/probe/r11v75repro/byteverify.sh`), `uvmdist.sh`, `attrib_earlgrey.sh`.
- `evidence/`: `grid.tsv` (+ `grid_orderblind.txt`, `off_alone_grid.txt`, `switchcheck.txt`), `r11u191_grid_lawF.tsv`
  (the decode's own cases), `census/` (the frozen prediction, the prediction check, the draft census that caught the
  breaks), `sweeps/` (both sweep summaries, byteverify, canaries, the movers' fresh rows, order-blind rows),
  `offcheck.txt`, `attrib_earlgrey_lawF.txt`, `uvmdist.txt`, `orderblind_rows.txt`, `heads/` (the moved rows' first
  records after the pass), `residue/Q` (Earlgrey's next head, the sister's ground).

Reproduce: build `b6344400` and `b6344400` + the patch (system-deps config, `-j 2`), freeze them as
`/tmp/r11u195_bin/{pris,lawG}.bin`, `bash drivers/grid.sh` (OFFCHECK=1), `SLANG_UHDM=<law> bash drivers/census.sh <wd>
<trace dir> <prefix>`, then `tests/sweep.sh --jobs 3 --workdir <wd>` once per binary.

## 10. The grid (106 cases; 46 converted, 0 regressed, 106 of 106 pristine with the pass switched off)

| case | law (named in the case's first line) | pristine | law | `R11U191_OFF=1 R11U195_OFF=1` |
|---|---|---|---|---|
| [A/a01](cases/A/a01/dut.sv) | § idxCallPathAtDots191 — fresh: a call index with a name argument (composition with trailIdxCallArgNamesByPath187), lvalue and rvalue | STRICT_NOTEQUAL:endcol(2) | EQUAL | pristine |
| [A/a02](cases/A/a02/dut.sv) | § idxCallPathAtDots191 — fresh: a two-level receiver path and a spaced continuation, inside an if and a foreach | STRICT_NOTEQUAL:endcol(9) | STRICT_NOTEQUAL:endcol(3) | pristine |
| [A/a03](cases/A/a03/dut.sv) | § idxCallPathAtDots191 — fresh: a range select and an indexed range over method calls, in a task and a nested operation | STRICT_NOTEQUAL:endcol(10) | EQUAL | pristine |
| [A/a04](cases/A/a04/dut.sv) | § idxCallPathAtDots191 — fresh controls: a plain select, a call inside a call argument, this. and a method call on a select | NOT_EQUAL | NOT_EQUAL | pristine |
| [A/a05](cases/A/a05/dut.sv) | § idxCallPathAtDots191 — fresh: a method call index in a continued select used as a call argument and in a return | STRICT_NOTEQUAL:endcol(6) | EQUAL | pristine |
| [A/a06](cases/A/a06/dut.sv) | § idxCallPathAtDots191 — fresh: the call index in a module-level class handle's continued select, in an initial block | STRICT_NOTEQUAL:endcol(8) | EQUAL | pristine |
| [B/b01](cases/B/b01/dut.sv) | § pkgFoldAtLeadingLeaf191 — fresh: taken branches that are a parenthesized sum, a product with a parenthesized right operand, a nested ternary | NOT_EQUAL | NOT_EQUAL | pristine |
| [B/b02](cases/B/b02/dut.sv) | § pkgFoldAtLeadingLeaf191 — fresh: the folded package parameters used as part-select bounds through a wildcard import (composition with psBoundPaOwnerName192) | STRICT_NOTEQUAL:col(2) | EQUAL | pristine |
| [B/b03](cases/B/b03/dut.sv) | § pkgFoldAtLeadingLeaf191 — fresh: a macro-born ternary and a macro-born leaf in a package, read through a qualified name | STRICT_NOTEQUAL:col(2) | EQUAL | pristine |
| [B/b04](cases/B/b04/dut.sv) | § pkgFoldAtLeadingLeaf191 — fresh controls: a ternary on a non-constant-foldable condition shape, a module parameter, an unparenthesized plain sum | NOT_EQUAL | NOT_EQUAL | pristine |
| [B/b05](cases/B/b05/dut.sv) | § pkgFoldAtLeadingLeaf191 — fresh: typed and untyped package parameters with the leaf a literal, an unsized literal and a parameter | NOT_EQUAL | NOT_EQUAL | pristine |
| [C/c01](cases/C/c01/dut.sv) | § evalFuncExecCallArgTs191 — fresh: indexed part-select actuals in a constant-bound for loop, a non-constant call (the first call met only) | EQUAL | EQUAL | pristine |
| [C/c02](cases/C/c02/dut.sv) | § evalFuncExecCallArgTs191 — fresh: a local's part select after a plain statement, two calls in one expression, a non-constant call | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [C/c03](cases/C/c03/dut.sv) | § evalFuncExecCallArgTs191 — fresh: the same function called by a constant and by a non-constant continuous assignment | NOT_EQUAL | NOT_EQUAL | pristine |
| [C/c04](cases/C/c04/dut.sv) | § evalFuncExecCallArgTs191 — fresh controls: a package function (the law abstains), a call behind an if, a reference actual | EQUAL | EQUAL | pristine |
| [C/c05](cases/C/c05/dut.sv) | § evalFuncExecCallArgTs191 — fresh: nested calls (the inner call's actual evaluated first) and an indexed part select with a descending width | NOT_EQUAL | NOT_EQUAL | pristine |
| [G/g06](cases/G/g06/dut.sv) | § evalFuncOpReduceGate195 | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g07](cases/G/g07/dut.sv) | § evalFuncOpReduceGate195 | EQUAL | EQUAL | pristine |
| [G/g08](cases/G/g08/dut.sv) | § evalFuncOpReduceGate195 | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g09](cases/G/g09/dut.sv) | § evalFuncOpReduceGate195 | EQUAL | EQUAL | pristine |
| [G/g10](cases/G/g10/dut.sv) | § evalFuncOpReduceGate195 | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g11](cases/G/g11/dut.sv) | § evalFuncOpReduceGate195 | EQUAL | EQUAL | pristine |
| [G/g12](cases/G/g12/dut.sv) | § evalFuncOpReduceGate195 | EQUAL | EQUAL | pristine |
| [G/g13](cases/G/g13/dut.sv) | § evalFuncOpReduceGate195 | EQUAL | EQUAL | pristine |
| [G/g14](cases/G/g14/dut.sv) | § evalFuncOpReduceGate195 | EQUAL | EQUAL | pristine |
| [G/g15](cases/G/g15/dut.sv) | § evalFuncOpReduceGate195 | EQUAL | EQUAL | pristine |
| [G/g16](cases/G/g16/dut.sv) | § evalFuncOpReduceGate195 | STRICT_NOTEQUAL:type(1) | STRICT_NOTEQUAL:type(1) | pristine |
| [G/g17](cases/G/g17/dut.sv) | § evalFuncOpReduceGate195 | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g18](cases/G/g18/dut.sv) | § evalFuncOpReduceGate195 | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g19](cases/G/g19/dut.sv) | § evalFuncOpReduceGate195 | EQUAL | EQUAL | pristine |
| [G/g20](cases/G/g20/dut.sv) | § evalFuncOpReduceGate195 | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g21](cases/G/g21/dut.sv) | § evalFuncOpReduceGate195 — every call of the stopping statement under + is evaluated | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g22](cases/G/g22/dut.sv) | § evalFuncOpReduceGate195 — the second call behind a ternary | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g23](cases/G/g23/dut.sv) | § evalFuncOpReduceGate195 — two calls under an XOR: neither evaluated | EQUAL | EQUAL | pristine |
| [G/g24](cases/G/g24/dut.sv) | § evalFuncOpReduceGate195 — two calls in a concatenation | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [G/g25](cases/G/g25/dut.sv) | § evalFuncOpReduceGate195 — a later statement after the stopping one | STRICT_NOTEQUAL:type(1) | EQUAL | pristine |
| [K/k01](cases/K/k01/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(4) | EQUAL | pristine |
| [K/k02](cases/K/k02/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(2) | EQUAL | pristine |
| [K/k03](cases/K/k03/dut.sv) | § procNetMidSelDotted195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [K/k04](cases/K/k04/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(6) | EQUAL | pristine |
| [K/k05](cases/K/k05/dut.sv) | § procNetMidSelDotted195 | EQUAL | EQUAL | pristine |
| [K/k06](cases/K/k06/dut.sv) | § procNetMidSelDotted195 | EQUAL | EQUAL | pristine |
| [K/k07](cases/K/k07/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(2) | EQUAL | pristine |
| [K/k08](cases/K/k08/dut.sv) | § procNetMidSelDotted195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [K/k09](cases/K/k09/dut.sv) | § procNetMidSelDotted195 | EQUAL | EQUAL | pristine |
| [K/k10](cases/K/k10/dut.sv) | § procNetMidSelDotted195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [K/k11](cases/K/k11/dut.sv) | § procNetMidSelDotted195 | EQUAL | EQUAL | pristine |
| [K/k12](cases/K/k12/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(14) | STRICT_NOTEQUAL:col(10) | pristine |
| [K/k13](cases/K/k13/dut.sv) | § procNetMidSelDotted195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [K/k14](cases/K/k14/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(6) | EQUAL | pristine |
| [K/k15](cases/K/k15/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(2) | EQUAL | pristine |
| [K/k16](cases/K/k16/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(8) | EQUAL | pristine |
| [K/k17](cases/K/k17/dut.sv) | § procNetMidSelDotted195 | STRICT_NOTEQUAL:fullname(2) | EQUAL | pristine |
| [P/p01](cases/P/p01/dut.sv) | § pkgPatMemberReadAtValue195 | STRICT_NOTEQUAL:line(1) | EQUAL | pristine |
| [P/p02](cases/P/p02/dut.sv) | § pkgPatMemberReadAtValue195 | STRICT_NOTEQUAL:col(2) | EQUAL | pristine |
| [P/p03](cases/P/p03/dut.sv) | § pkgPatMemberReadAtValue195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [P/p04](cases/P/p04/dut.sv) | § pkgPatMemberReadAtValue195 | STRICT_NOTEQUAL:line(1) | EQUAL | pristine |
| [P/p05](cases/P/p05/dut.sv) | § pkgPatMemberReadAtValue195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [P/p06](cases/P/p06/dut.sv) | § pkgPatMemberReadAtValue195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [P/p07](cases/P/p07/dut.sv) | § pkgPatMemberReadAtValue195 | STRICT_NOTEQUAL:line(1) | EQUAL | pristine |
| [P/p08](cases/P/p08/dut.sv) | § pkgPatMemberReadAtValue195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [P/p09](cases/P/p09/dut.sv) | § pkgPatMemberReadAtValue195 | STRICT_NOTEQUAL:line(1) | EQUAL | pristine |
| [P/p10](cases/P/p10/dut.sv) | § pkgPatMemberReadAtValue195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [P/p11](cases/P/p11/dut.sv) | § pkgPatMemberReadAtValue195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [P/p12](cases/P/p12/dut.sv) | § pkgPatMemberReadAtValue195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [P/p13](cases/P/p13/dut.sv) | § pkgPatMemberReadAtValue195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s01](cases/S/s01/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(3) | EQUAL | pristine |
| [S/s02](cases/S/s02/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(3) | EQUAL | pristine |
| [S/s03](cases/S/s03/dut.sv) | § funcCfgPatOpRefBare195 | EQUAL | EQUAL | pristine |
| [S/s04](cases/S/s04/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s05](cases/S/s05/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:line(2) | STRICT_NOTEQUAL:line(2) | pristine |
| [S/s06](cases/S/s06/dut.sv) | § funcCfgPatOpRefBare195 | EQUAL | EQUAL | pristine |
| [S/s07](cases/S/s07/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s08](cases/S/s08/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s09](cases/S/s09/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(3) | EQUAL | pristine |
| [S/s10](cases/S/s10/dut.sv) | § funcCfgPatOpRefBare195 | EQUAL | EQUAL | pristine |
| [S/s11](cases/S/s11/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(1) | EQUAL | pristine |
| [S/s12](cases/S/s12/dut.sv) | § funcCfgPatOpRefBare195 | EQUAL | EQUAL | pristine |
| [S/s13](cases/S/s13/dut.sv) | § funcCfgPatOpRefBare195 | EQUAL | EQUAL | pristine |
| [S/s14](cases/S/s14/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:line(1) | STRICT_NOTEQUAL:line(1) | pristine |
| [S/s15](cases/S/s15/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(3) | EQUAL | pristine |
| [S/s16](cases/S/s16/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(3) | EQUAL | pristine |
| [S/s17](cases/S/s17/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(3) | EQUAL | pristine |
| [S/s18](cases/S/s18/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s19](cases/S/s19/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s20](cases/S/s20/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s21](cases/S/s21/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(6) | EQUAL | pristine |
| [S/s22](cases/S/s22/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s23](cases/S/s23/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(3) | EQUAL | pristine |
| [S/s24](cases/S/s24/dut.sv) | § funcCfgPatOpRefBare195 | STRICT_NOTEQUAL:fullname(1) | EQUAL | pristine |
| [S/s25](cases/S/s25/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s26](cases/S/s26/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s27](cases/S/s27/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s28](cases/S/s28/dut.sv) | § funcCfgPatOpRefBare195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s29](cases/S/s29/dut.sv) | § funcCfgPatOpRefBare195 — the evaluator gate, a member computed from a 1024-bit member (declines) | NOT_EQUAL | NOT_EQUAL | pristine |
| [S/s30](cases/S/s30/dut.sv) | § funcCfgPatOpRefBare195 — the evaluator gate, a member computed by an operation (the model declines) | STRICT_NOTEQUAL:fullname(3) | EQUAL | pristine |
| [T/t01](cases/T/t01/dut.sv) | § tagPatParenSpan195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [T/t02](cases/T/t02/dut.sv) | § tagPatParenSpan195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [T/t03](cases/T/t03/dut.sv) | § tagPatParenSpan195 | STRICT_NOTEQUAL:col(4) | EQUAL | pristine |
| [T/t04](cases/T/t04/dut.sv) | § tagPatParenSpan195 | STRICT_NOTEQUAL:col(2) | EQUAL | pristine |
| [T/t05](cases/T/t05/dut.sv) | § tagPatParenSpan195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [T/t06](cases/T/t06/dut.sv) | § tagPatParenSpan195 | STRICT_NOTEQUAL:col(1) | EQUAL | pristine |
| [T/t07](cases/T/t07/dut.sv) | § tagPatParenSpan195 | NOT_EQUAL | NOT_EQUAL | pristine |
| [T/t08](cases/T/t08/dut.sv) | § tagPatParenSpan195 | STRICT_NOTEQUAL:col(2) | EQUAL | pristine |
| [T/t09](cases/T/t09/dut.sv) | § tagPatParenSpan195 | STRICT_NOTEQUAL:col(4) | EQUAL | pristine |
| [T/t10](cases/T/t10/dut.sv) | § tagPatParenSpan195 | STRICT_NOTEQUAL:col(6) | STRICT_NOTEQUAL:file(4) | pristine |
