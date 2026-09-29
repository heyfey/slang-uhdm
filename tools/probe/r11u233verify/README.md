# r11u233: second adversarial verification of passes 228 and 227 — BREAKS FOUND in three laws of pass 228 (and one v11u228 refinement) and one law of pass 227, all on legal SV where pristine was right; five refinements delivered as `/tmp/r11u233_fix.patch` (not in this directory)

**Base** `aba8c391` (branch matrix-1.87): pass 228 + v11u228 landed at `cd4fd02a` (module/type ground), pass 227 + v11u227
at `9c9c11d6` (expression/parameter ground), map 15 at `aba8c391`. The live pairs r11u231 and r11u232 did not land while
this pass ran; their worktrees were not touched. This directory measures only: no file under `src/`, `scripts/`,
`tests/`, `results/` or `third_party/` is edited by it, and it holds no patch file. The refinements proven here are in
`/tmp/r11u233_fix.patch`, a git diff against `aba8c391` of `src/TypeEmit.cpp`, `src/ModuleEmit.cpp`, `src/ParamEmit.cpp`,
`uhdm_main.cpp` and a new header `src/R233.h`, each law behind its own switch, `R11V233_OFF` dropping all five. A probe
case is called a case. The four slang-fenced tests are never named here: every driver reads them from the `FENCED=` line
of `tools/probe/r11u107repro/canaudit.sh` (drivers/env.sh) and fails closed.

The law index (`tests/LAWS.md`) reads stale while this directory is untracked (its cases name laws in their first
lines); the integration regenerates it, as `e0d6957c` did for r11u229. Every sweep of this pass exits 1 on that notice
alone; every stage reads 0 regressions.

## 0. Verdict

**Five breaks on legal SV where pristine was right (51 of 346 fresh case-views), each fixed by a refinement that
moves 0 records away from pristine on it:**

| # | law (landing) | shape | cases (both views) | golden-agreeing records lost, law vs pristine (chain-keyed) | refinement (switch) |
|---|---|---|---|---|---|
| 1 | § memberInitReducedRootFolds228 with § memberRootFoldShapes228v (228) | the struct parameter's root READS a struct parameter (`B + 0`, `B \| 0`, `{B}`, `'{x: int'(B)}`, whatever B's shape), reads a member of a struct parameter whose root keeps (`'{x: B.x}` with B a cast, two hops, an int localparam `W = B.x` read as `'{x: W}`), holds a cast to a struct type below the root (`{info_t'(16)}`, `({info_t'(16)})`), holds a unary plus (`'{x: +16}`), or is a multi-operand concatenation holding an arithmetic (`{16'd0, 32'd20 - 32'd4}`): golden keeps `Info.x` (or the unreduced value) where the law folds `INT:15` | M m23 m24 m29 m32 m35; J j01 j02 j03 j05 j06 j07 j08 j09 j10 j17 j19 j21 j22 j33 (38 case-views) | 7 per parse view, 13 per elaborated view (2 and 2 for the unary-plus and member-arithmetic shapes): 402 | § memberRootNoStructReadFolds233v (`R11V233_ROOTREAD_OFF`) |
| 2 | § memberRootOwnInstance228v (v11u228) with § memberInitReducedRootFolds228 | a CHILD's range read through its own parameter overridden by the parent's member localparam (`sub #(.Depth(N))`, `N = Info.x` in `mid`), two `mid` instances untyped then cast: the root is bound in the FIRST `mid` instance, so the cast instance's child folds where golden keeps `Info.x` (the stale-scope face v11u228 fixed one level down, and listed as a residue it believed was a miss) | X x04 x07 x08 x09 (8 case-views; x07 with equal member values, x08 three levels, x09 through a generate block) | 12-14 per view: 108 (with 3-4 toward each, which the fix keeps) | § memberRootAncestorInstance233v (`R11V233_ROOTANC_OFF`) |
| 3 | § parseViewSizeExprEval228 (228) | the `$size` operand's dimension reads a package parameter computed from a FORWARD package reference (`bit [3:0][p1::S.x:0] c` with `S = '{x: p2::E1}` and p2 declared after p1): golden cannot size it and keeps `$size(c, 2)`; ours binds the reference and folds | X x03 (parse view) | 11 (the call, its argument and the net) | § pvSizeFwdPkgDimDeclines233v (`R11V233_PVSIZEFWD_OFF`) |
| 4 | § sizeBitNetIsVar228 (228) | a packed dimension over a TYPEDEF'D BIT VECTOR on a bit net (`typedef bit [1:0] b2_t; input b2_t [3:0] pp`): golden reads `$size(pp, 2)` as 2 (the base's count was 2), ExprEval over ours reads 1 | B b07 (both views); b09 b11 move between two wrong values | 1 per view | § sizeBitNetAliasVecDeclines233v (`R11V233_BITNETALIAS_OFF`) |
| 5 | § pkgPatFuncBodyLeftoverNoParent227 (227) | the package pattern parameter written as a TYPED pattern (`localparam in_t UU = in_t'{a: 11, b: 22};`) read whole in the evaluated function: golden keeps the listing operation's parented `ref_typespec pk`, the law unparented it | P p09 (both views) | 1 per view | § pkgPatTypedKeepsParent233v (`R11V233_PATTYPED_OFF`) |

No crash: **every one of the 2628 grid runs exits 0** except the two runs with v11u228's own refinement switched off
(`R11V228_PVSIZEDYN_OFF`: S/s06 `logic [3:0] fq [2][3][$]`, rc 139, the crash v11u228 cured; 0 with it on); the 652 fix
runs exit 0. None of the breaks changes a gate row or a downstream verdict (sections 4 and 6): they sit on shapes no
corpus row, probe case or downstream lane holds (the firing census of the fix reads 0 firings over all of them, with a
positive control firing all five names).

**The fixed binary** (`fix3.bin`, `1ed1fbc425479dc756e7d78a8c1ebdae`) against pristine (both landings off) on the 346
fresh case-views: **0 records lost, 221 toward** (chain-keyed); against HEAD: 1 lost (X/x03's `$size(b)`, a toward-move
of the law the forward-package decline gives back: pristine's bytes) and 447 toward; the reversed control reads 447
lost. `R11V233_OFF` writes HEAD's bytes on 326 of 326 case-views that write a database. On 1938 case-views of the 14
landed grids of passes 216-229 (drivers/bytectl.sh) fix3 writes HEAD's bytes on every one.

**Everything else holds:** § fwdPkgRefClassScopeSpan227, § fwdPkgRefConstSlotWhole227v, § newArrayPartSelStripped227,
§ parseViewSizeExprEval228 outside the forward shape, § pvSizeNoElemDeclines228v, § memberRootOwnInstance228v inside
one definition and § memberRootFoldShapes228v's decoded shapes move nothing away on the fresh cases (section 1).

**Composition** (section 2): every change each landing claimed is its own (pass 227: FuncStructVal d/t and the twenty
N0003 probe cases, all strict SUBSETs; pass 228: none), CANCEL 0 at status and at byte level over 7452 databases, 0
downstream lanes moving; pass 228's laws fire on no corpus row-mode, no probe case and no downstream lane.
`R11V226_IDORDER_OFF` still returns the MiniAmiq coin: dropping § refChainDrainIdOrder227 lost nothing.

**Determinism** (section 5): one hash per row-mode in every draw at the base (3 draws x 11 row-modes; 12 draws on
MiniAmiq d/t and Scoreboard d), 16 of 16 on each of five cases firing § pvSizeNoElemDeclines228v.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u233_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `law.bin` | `8d6b76685739e0fcb064eb0fee37399f` | `/tmp/wt_r11u233` at `aba8c391`, system-deps config, `-j 2`: equal to the main tree's `build/slang-uhdm` |
| `fix1.bin` | `4b9b6546379548b9341527e908a59cb8` | draft: refinements 1 and 4 (grid only) |
| `fix2.bin` | `f70a8c1f3ef42da9b62c8cc7757b5aac` | draft: + 2, 3, 5 (grid only; it moved X/x02 one record away: section 3.1) |
| **`fix3.bin`** | **`1ed1fbc425479dc756e7d78a8c1ebdae`** | **the final: `aba8c391` + `/tmp/r11u233_fix.patch` (md5 `d7639234ac8e0d5d437a76a315886b28`); the patch applied to a fresh `aba8c391` worktree rebuilds it byte for byte (section 3.3)** |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build, equal to the main tree's |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's raw-name variant (tools/probe/r11u222map/drivers/cc.sh), the md5 the earlier passes cite |
| `retvars` | - | tools/probe/r11u229verify/drivers/tool/retvars.cpp (residue count) |

States on `law.bin` (drivers/laws.py, read from the sources at `aba8c391`): ON (no switch); OFF_<law> (the law's own
switch; every refinement of a named law is scored too); OFFL227 = `R11U227_OFF` (drops pass 227's three laws and
§ fwdPkgRefConstSlotWhole227v); OFFL228 = `R11U228_OFF` (drops pass 228's three laws and, inside their sites, v11u228's
three refinements); ALLOFF = both (the bytes before both landings); IMPL = `R11V227_OFF R11V228_OFF` (the two passes'
laws as their implementers delivered them).

Sweeps (`tests/sweep.sh --jobs 3`, every stage, 16-character workdirs, drivers/sweep.sh): `/tmp/r11u233_wON` (HEAD, with
`R11U227_TRACE` and `R11U228_TRACE`: the firing census; its bytes equal the untraced integration sweep's, section 2),
`_w27` (`R11U227_OFF`), `_w28` (`R11U228_OFF`), `_wNO` (both), `_wFC` (fix3 with `R11V233_TRACE`: the fix's census),
`_wFX` (fix3, the fix's gate). Every `slang:` line of every sweep's 3273 corpus `cmds.txt` names that sweep's binary.

## 2. The fresh grid: 173 cases, 346 case-views, every line with its exit code ([evidence/grid/](evidence/grid/))

drivers/grid.py (r11u229's, the states above) ran every case in both views; drivers/caseaway.py and awaypair.py scored
every state against HEAD and against pristine on the gate comparator's own records (uhdm-strictcmp self-walk, so stage-1
pairs are walked too), chain-keyed (the record with its ancestor chain) and flat. Goldens were built with the pinned
Surelog per case text (`-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 [-elabuhdm]`, cached by the md5 of the case
files under `/tmp/r11u233_g`). Nearly every member-root case is stage 1 on both binaries (pass 228's residue 1: golden's
`int` stamp on the elaborated `param_assign` constants), so the uhdm-cmp axis moves only as the first uhdm-cmp head:
on every break of that family the law's range becomes the FIRST uhdm-cmp difference (90/94 cmp lines where pristine's
head is the 17-line stamp), and the record census decides. The per-case-view table (fired laws, exit codes of HEAD /
pristine / fix, the judge status of each, the three record censuses, the verdict) is
[evidence/grid/grid_table.md](evidence/grid/grid_table.md).

| family | law(s) | cases | case-views | fired at HEAD | TOWARD | BREAK | UNFIRED | bytes only | no golden |
|---|---|---|---|---|---|---|---|---|---|
| M | § memberInitReducedRootFolds228, § memberRootFoldShapes228v, § memberRootOwnInstance228v | 40 | 80 | 64 | 42 | **10** | 26 | 2 | 0 |
| J | the same (the break shapes and their boundary, in v11u228 FM f03's form) | 32 | 64 | 64 | 36 | **28** | 0 | 0 | 0 |
| S | § parseViewSizeExprEval228, § pvSizeNoElemDeclines228v | 25 | 50 | 17 | 14 | 0 | 29 | 1 | 6 |
| B | § sizeBitNetIsVar228 (with the parse-view law) | 12 | 24 | 17 | 11 | **2** | 7 | 4 | 0 |
| F | § fwdPkgRefClassScopeSpan227, § fwdPkgRefConstSlotWhole227v | 36 | 72 | 12 | 8 | 0 | 62 | 2 | 0 |
| P | § pkgPatFuncBodyLeftoverNoParent227 | 12 | 24 | 10 | 6 | **2** | 14 | 2 | 0 |
| N | § newArrayPartSelStripped227 | 7 | 14 | 7 | 7 | 0 | 7 | 0 | 0 |
| X | the cross-ground pairs | 9 | 18 | 14 | 5 | **9** | 4 | 0 | 0 |
| **total** | | **173** | **346** | | **129** | **51** | **149** | **11** | **6** |

Exit codes over the 2628 grid runs (ON, trace, every OFF state, OFFL, ALLOFF, IMPL): 2626 rc 0; 2 rc 139, both
S/s06 under v11u228's own refinement switched off. Every no-golden case-view is S s06 / s08 / s21 (Surelog writes no
database for `logic [3:0] fq [2][3][$]`, a typedef'd unpacked array `arr_t a`, and a fixed-then-queue operand in an
interface), exit code 0 on every state.

### 2.1 The member-root laws (M, J; § memberInitReducedRootFolds228 and its two refinements)

* **Held** (TOWARD, 0 lost): three instances of one definition with an untyped pattern, a plain integer and a cast in
  all six orders (m01-m06: 2 toward each view), a cast default with an untyped first instance (m07), an array of
  instances beside a cast instance (m08), generate-for instances with one override expression selecting an untyped
  pattern at i==0 and a cast otherwise (m09), override chains across two and three parent levels through STRUCT
  parameters (m10 m11), defparam overrides (m12, bytes only), a localparam chain onto the member (m14), a root in a
  package (m19 untyped: toward; m20 cast: unfired), concatenations with replications (m21), untyped patterns whose
  members are constant function calls, conditionals of int casts, system calls, replicated concatenations (m22 m26 m27
  m30), shifts of names (m33), a package struct constant read by member (m39), two untyped instances with a cast
  default (m40); J: `'{x: B.x}` with B untyped (j04), `{int'(16)}` (j14), `'{x: C.y}` of another struct type (j15),
  `(B)` (j18), two hops ending untyped (j20), `{16'd0, W}`, `'{x: 8 + 8}`, size casts, parentheses, conditionals and a
  unary minus inside concatenations, a single-operand concatenation of a subtraction, `'{x: W}` with `W = 8 + 8`
  (j23-j32), `-(-16)` (j12), the int localparam of an int cast (j11).
* **Unfired** (a miss, not a break): a function-call root (m13, `memLeftInitCall`'s refusal), members two and three
  deep (m15 m16), an unpacked struct parameter (m17), the size cast by a parameter width (m25), `$clog2(...) + 0` (m28),
  `'1` (m34), a real literal (m36), the signal in a generate block or the root a localparam of a generate block (m37 m38).
* **The refinement against the implementer's law** (`R11V228_ROOTSHAPE_OFF`): on m18 (`SEL ? B : cast` with B
  untyped), m28 and m34 the implementer's fold was 1 record toward golden and § memberRootFoldShapes228v keeps pristine's
  bytes: misses of the refinement, not breaks (0 lost against pristine).
* **BREAK 1** (38 case-views, table of section 0): the record census names the records exactly: the `operation`
  `Info.x - 1` (6:11-6:14), its `hier_path Info.x` and the path's `ref_typespec <in>Info.x` chain (7 records in the
  parse view, 13 in the elaborated view, where the instance tree repeats them), and for the unary-plus and
  member-arithmetic shapes the unreduced `operation (N - 1)` with golden's `+16` operand (2 records). Downstream every
  one is IDENTICAL on both binaries (the folded and the symbolic bound give the same width): a judge- and strict-axis
  break only.

### 2.2 The parse-view `$size` laws (S, B)

* **Held**: one-dimensional dynamic, queue and associative operands (s01), dynamic-, queue- and associative-then-fixed
  and fixed-then-associative operands (s02-s05: every exit code 0; the call stays where ExprEval cannot size it),
  typedef'd elements and 2-D packed typedefs (s07 s09), a parameter and an expression as the dimension argument (s10:
  DIVERGENT -> IDENTICAL downstream), real/enum/struct elements (s12), reg elements and a signed narrow target
  (s13 s14), net arrays (s16), chandle and event arrays (s17), a shadowing local in a generate block (s18), a child
  parameter of the operand's name (s19), a signed 2-D operand (s20), string and byte arrays (s22), a 3-D mixed operand at
  each dimension (s23), packed unions (s24), a package typedef'd operand (s25): 14 toward, 0 lost.
* **A wrong value, not a break** (s11, a genvar as the dimension argument in a generate-for, `$size(m, i)` of `logic
  [3:0] m [5][6]`): golden's walker reads 5, 6 and 4; pristine keeps the three calls; the law writes 56 for each (ExprEval
  over ours cannot reduce the genvar, so its generic handler answers). No golden-agreeing record is lost (the calls were
  not golden's either) and the verdict is DIVERGENT on both binaries with different netlists: a residue of the law
  (section 7).
* **The law leaves the variable initializer and the assign statement** (s15): only the net declaration's call is
  replaced (`$size` calls golden 2, pristine 2, HEAD 1); the other two bytes do not move.
* **§ sizeBitNetIsVar228**: ANSI and typedef'd bit net ports, both argument forms (b01 b02 b08), a typedef'd scalar bit
  element (b10: golden 1 and 1, HEAD 1 and 1, pristine 4 and 2), a bit net of an interface and in a child's generate
  block (b05): toward. Unfired: unpacked bit ports (b04), `input var bit` (b06), a logic typedef (b12), one-dimensional
  bit nets (b03: § ndaSizeQueryFold216's one-dimensional cell answers first).
* **BREAK 4**: a packed dimension over a typedef'd bit VECTOR (net-declaration constants golden / HEAD / pristine):
  b07 `b2_t [3:0]` 2,2 / 1,1 / 4,2 (the second constant moved away, both views); b09 `typedef b2_t [3:0] b8_t` 8,8 /
  4,4 / 4,2 and b11 `b2_t [3:0][2:0]` 2,2 / 1,1 / 4,3 (both wrong on both binaries). ExprEval over our typespec is not
  ExprEval over golden's there. Downstream b07 b09 b11 are EQUIVALENT on every binary (the slang lane's netlist is the
  same bytes with and without the law).

### 2.3 The forward-reference laws (F; § fwdPkgRefClassScopeSpan227, § fwdPkgRefConstSlotWhole227v)

Every constant slot a package can hold was written, in a subroutine body and in expression positions: a localparam, a
local variable's packed and unpacked dimensions, the return type's range, enum member values of a function-local
typedef, case items and case-inside ranges, `#p2::K` / `#(p2::K)` delays and `@p2::ev` / `@(p2::ev)` events in a task,
`$bits` type-argument dimensions, streaming slice sizes, default arguments, package variable initializers, size casts,
loop, repeat and while bounds, nested calls, part-select bounds, indexed widths and replication counts inside a body, a
typedef'd vector and a cast to it, `C && p2::E1 ? 3 : 4`, dimension bounds and enum values of package typedefs, and
inside a pattern member: `$bits(logic [p2::K-1:0])`, `p2::K'(5)`, `inside {[p2::E1:p2::E3]}`, `$size(p2::W, p2::E1)`,
a streaming slice, parentheses, a constant ternary, a cast to the later package's enum, `$clog2(p2::K) + $bits(p2::W)`;
plus the spaced form `p2 :: E1`, three packages in a chain, a package referenced both forward and backward, a class in
the later package, the later package in an included file, a macro carrying the reference into a pattern member,
part-select bounds and a replication count, and a module parameter (control). **No break**: 0 lost on 72 case-views; the
laws fire on 12 case-views: f10 f21 f25 f29 move toward in both views (8), f33 (a constant ternary with both branches forward, inside a pattern member) moves bytes in both views with no golden-agreeing record gained or lost, f14 is § fwdPkgRefConstSlotWhole227v declining (pristine bytes); in every constant slot ours folds the forward
reference where golden keeps it (stage 1 on both binaries, the law unfired: pass 227's residue 3), so the law cannot
reach those slots. § fwdPkgRefConstSlotWhole227v fires on the macro-carried constant slots (f14, 3 per view) and keeps
golden's whole name. The spaced form and the included later package decline (unfired; residues).

### 2.4 § pkgPatFuncBodyLeftoverNoParent227 (P)

Held (0 lost): read whole in a function also read by a task (p04), by a class method (p05), by two localparams (p06):
toward; inside an if and a loop (p07): bytes only. Unfired (a correct decline or a miss, 0 lost): nested calls `inner()` (p01), a
default argument `mk(in_t x = UU)` (p02), read whole and by member (p03), another package's function (p08), a
positional pattern (p10), a local copy (p11), a module parameter default calling the function (p12). **BREAK 5**: the
typed pattern (p09).

### 2.5 § newArrayPartSelStripped227 (N)

Part-select bounds that are constant function calls, parameters, a parameter's bit select, other selects as the indexed
base, `this.` members, two part selects in an operation and in a concatenation, function locals, system calls: 7 of 7
parse views toward (84 records), every `--elabuhdm` view unfired. n03's MIXED reading on the index-aligned walk is an
unmasking: the bit_select `PA` in `v[PA[1]:0]` carried a wrong full name and column at the base; the law fixes the
name and the column residue (ours 11:19-20, golden 11:16-21) surfaces (0 chain-keyed records lost).

### 2.6 The cross-ground pairs (X)

* § memberInitReducedRootFolds228 with § pkgPatFuncBodyLeftoverNoParent227, a struct parameter whose root is a package
  pattern read whole by an evaluated function (x01) and the member of the function's result (x02): both laws fire, the
  pair moves 2-3 records toward per view, 0 lost.
* § parseViewSizeExprEval228 with § fwdPkgRefClassScopeSpan227 (x03): the forward law moves its record toward; the
  `$size` law **BREAKS** (3).
* § memberRootOwnInstance228v with § initHierFillKept225 / § fillSymbolicRootOnly225v on two instances (x04 untyped then
  cast: **BREAK 2**; x05 cast then untyped: pass 228 unfired, the fill law toward; x06 a parenthesized cast beside an
  untyped root: § fillSymbolicRootOnly225v alone moves 1 record away in the parse view, pass 225's own residue
  "§ fillSymbolicRootOnly225v's syntax test does not read through parentheses", not a law of these landings).

## 3. The fix (`/tmp/r11u233_fix.patch`, delivered for integration; not in this directory)

### 3.1 The refinements (each droppable alone; `R11V233_OFF` drops all five; `R11V233_TRACE=<dir>` names every firing)

| § law | switch | site | rule |
|---|---|---|---|
| memberRootNoStructReadFolds233v | `R11V233_ROOTREAD_OFF` | TypeEmit `resolveMemberInit`, after § memberRootFoldShapes228v's shape test | the root (after the chain and the selected branch) keeps the base's substitution when, below it, a struct parameter is read as a whole value, a member is read of a struct parameter whose own root would keep (recursively; a function-built base folds, x02), an explicit cast targets a struct or union, a unary plus appears, or a concatenation of two or more operands holds an arithmetic operand; a non-struct parameter read below the root is followed into its initializer (j17) |
| memberRootAncestorInstance233v | `R11V233_ROOTANC_OFF` (inside `R11V228_ROOTINST_OFF`) | the same site, beside § memberRootOwnInstance228v | a root in another definition than the signal's is read in the instance of that definition that encloses the signal's own instance (walking `parentInstance` up), not in the first instance |
| pvSizeFwdPkgDimDeclines233v | `R11V233_PVSIZEFWD_OFF` | uhdm_main, inside § parseViewSizeExprEval228 | an operand whose dimensions (ranges of the array and of the element typespecs) read a package-qualified name of a package that holds a reference to a package declared later in the same file keeps the call; the package set is computed once, lazily, only when a candidate call is reached, reading names and parents only |
| sizeBitNetAliasVecDeclines233v | `R11V233_BITNETALIAS_OFF` | ModuleEmit `rqSizePlan216`, § sizeBitNetIsVar228's test | a bit net whose packed element chain passes through a typedef'd packed vector keeps the base's count |
| pkgPatTypedKeepsParent233v | `R11V233_PATTYPED_OFF` | ParamEmit, § pkgPatFuncBodyLeftoverNoParent227's read set | a package parameter written as a typed pattern is not in the law's read set (a registry beside § pkgPatReadTsNoParent131's) |

Draft history: fix2 (the first form of the first rule) declined x02's `'{x: pk::C.u.x, y: 0}` with `C = mk()`, moving
one toward-record of the law away (1 lost per view against HEAD); fix3 lets a member of a function-built struct
parameter fold.

### 3.2 The fix on the grids

* Fresh grid (evidence/grid/away_pris_fix.txt, away_law_fix.txt, fix/fixrun_*.txt): fix3 against pristine 0 lost / 221
  toward; against HEAD 1 lost / 447 toward (X/x03's `$size(b)`: pristine's call, a toward-move of the law given back
  by the conservative package-level decline); reversed control 447 lost. On the 42 break case-views of breaks 1, 4
  and 5 fix3 writes pristine's bytes; on X x04 x07 x08 x09 it keeps the law's 3-4 toward-records and drops its 12-14
  away (0 lost against pristine); on X x03 it drops the `$size` fold and keeps § fwdPkgRefClassScopeSpan227's toward
  record (1 toward against pristine); on x05 x06 the ancestor rule adds 2 toward per view. `R11V233_OFF` = HEAD's bytes on
  326 of 326 case-views with a database; all 652 fix runs rc 0.
* Landed grids (evidence/fix/bytectl_law_fix3.txt, drivers/bytectl.sh): every case directory under tools/probe of
  r11u216repro, r11u219repro, v11u219repro, v11u223repro, r11u224repro, v11u224repro, r11u225repro, v11u225repro,
  r11u226verify, r11u227repro, v11u227repro, r11u228repro, v11u228repro, r11u229verify: **1938 case-views, 0 moved, 0
  exit codes differing** (four v11u224 LX case-views exit 3 on both binaries).
* Downstream (evidence/downstream/): on the 64 fresh X/P/N/F cases the verdicts of pristine, HEAD and fix3 are equal
  (17 DIVERGENT, 9 EQUIVALENT, 23 IDENTICAL, 15 STATUS_DIFF; X/x03's slang lane moves with the law and back with fix3);
  on the 136 cases of section 4.1 fix3 reads the verdict HEAD reads on every one (evidence/downstream/ds_fix3.txt).

### 3.3 The fix's gates

| gate | HEAD (`/tmp/r11u233_wON`) | fix3 census (`/tmp/r11u233_wFC`, `R11V233_TRACE`) | **fix3 gate (`/tmp/r11u233_wFX`)** |
|---|---|---|---|
| (1) binaries | `8d6b7668...` = the main tree's | `1ed1fbc4...` | **`1ed1fbc425479dc756e7d78a8c1ebdae`; the patch applied to a fresh `aba8c391` worktree (`/tmp/wt_r11u233rb`, `-j 2`) rebuilds it byte for byte** |
| `slang:` lines of the corpus `cmds.txt` | 3273 of 3273 name law.bin | 3273 name fix3.bin | 3273 of 3273 name fix3.bin |
| (2) probe vs results/golden_probe.csv | 0 / 0 / 0 (EQUAL 3453, STRICT_NOTEQUAL 634) | 0 / 0 / 0 | **regressions=0 conversions=0 changes=0**, the csv byte-identical to results/golden_probe.csv |
| (3) surelog vs results/golden_surelog.csv | 0 / 0 / 0 (930 CMP_EQUAL + 24 STRICT_NOTEQUAL) | 0 / 0 / 0 | **0 / 0 / 0** (default CMP_EQUAL 467 + STRICT_NOTEQUAL 13, testflags 463 + 11) |
| (3) uhdm2rtlil vs results/golden_uhdm2rtlil.csv | 0 / 0 / 0 (1602 + 4) | 0 / 0 / 0 | **0 / 0 / 0** (801 + 2 per mode) |
| (4) downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0 | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, "not identical and not excused=0"**, the csv identical to HEAD's |
| sweep exit | 0 (run before this directory held cases) | 1: the law-index notice alone | 1: the law-index notice alone |
| csv against HEAD, row by row | | | probe 0, uhdm2rtlil 0, surelog 2 (LowMemLib and LowMemPkg testflags: the SURELOG_FAIL detail carries the workdir path: environment) |

* **(5)** No gate row changes status or strict cell, so no touched row: uhdm-cmp stays at 0 lines on every judge-equal row.
* **(6) The mover prediction, frozen before the gate sweep** ([evidence/census/](evidence/census/), drivers/fixsweeps.sh
  and predict233.py): the census sweep wrote **0 trace files** over every probe case, both corpora in both modes and
  every downstream lane (the gate dispatched every row as it mandates; no fenced database was read); the positive control
  (the same binary and variable on J/j01, B/b07, P/p09, X/x03, X/x04) fires all five names
  ([positive_control.txt](evidence/census/positive_control.txt): memberRootAncestorInstance233v 2,
  memberRootNoStructReadFolds233v 1, pkgPatTypedKeepsParent233v 1, pvSizeFwdPkgDimDeclines233v 2,
  sizeBitNetAliasVecDeclines233v 2). predict_fix.txt (0 databases) md5 `981cc0057bb7fc3fce4012758d71e8c2`, frozen
  2026-09-29T14:55:33Z with fix3's md5 in predict_fix.stamp, before the gate sweep's first run: **prediction 0 movers
  against HEAD besides the known coins.**
* **byteverify** (tools/probe/r11v75repro/byteverify.sh, `SELFCHECK=1`, on hard-link mirrors without the 8 fenced
  databases, drivers/bvmirror.sh): fix3 against HEAD **PATH_SETS_IDENTICAL (2560), MOVERS 0 / 2560** (SELFCHECK 2559 /
  2560 flagged: every file against one fixed file); **probe 0 of 4087**; downstream csv identical. The prediction is met;
  no UVM coin drew another hash ([byteverify_fix_vs_head.txt](evidence/fix/byteverify_fix_vs_head.txt)).
* **Canaries** on the fix csvs: canaries.sh surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0 (the unknown names are
  the other corpus's canaries); `EXPECT_UNKNOWN=1 ctcan2.sh results/golden_surelog.csv` PASS, `EXPECT_UNKNOWN=6 ctcan2.sh
  results/golden_uhdm2rtlil.csv` PASS; the same on the HEAD sweep.
* **Allocation**: the five refinements allocate only on their firing paths (trace strings, the lazily computed package
  set of the parse-view decline, which runs only when a candidate `$size` call is reached), and none fires on a gate
  database; the HEAD sweep's UVM rows keep their hashes under fix3.

## 4. Downstream ([evidence/downstream/](evidence/downstream/), drivers/dscases.py: the gate's own `one()`, a fresh golden cache `/tmp/r11u233_dsgc`)

### 4.1 Pass 228's 26 DIVERGENT -> IDENTICAL and FR d13 DIVERGENT -> EQUIVALENT, at the base

All 27, `R11U228_OFF` -> HEAD: **26 DIVERGENT -> IDENTICAL with the slang lane's `_nohier.il` byte-identical to the
Surelog lane's** (md5 per case in ds_on.txt: MR m14, PS p01-p07 p11 p12, v11u219 S s01c s08, v11u223 S s01-s06,
v11u228 FB b01-b04, FS s02 s03 s05 s08), and **FR d13 DIVERGENT -> EQUIVALENT** (`il` differs, the netlists proven
equivalent). With the 109 fresh M/J/B/S cases (136 cases): pristine -> HEAD 38 DIVERGENT -> IDENTICAL, 1 DIVERGENT ->
EQUIVALENT, 6 DIVERGENT on both, 21 EQUIVALENT and 67 IDENTICAL on both, 3 SURELOG_FAIL; **none leaves IDENTICAL**.

### 4.2 Pass 227's fresh cases

The 118 cases of r11u227repro (FW PL NP) and v11u227repro (BF BP BN): `R11U227_OFF` -> HEAD **every verdict and every
slang-lane `_nohier.il` unchanged** (98 IDENTICAL, 5 EQUIVALENT, 3 DIVERGENT, 12 STATUS_DIFF on both).

### 4.3 Map 15's 38 DIVERGENT faces

The firing census over the 38 cases in both views (drivers/firecases.sh, `R11U227_TRACE`, `R11U228_TRACE`,
[fire_map15div.txt](evidence/downstream/fire_map15div.txt)): **a law of these two passes touches 2**:
v11u219repro S s01c_assoc_inner and s08_bit_packed2d (§ parseViewSizeExprEval228, parse view), which read IDENTICAL at
HEAD (pass 228's own conversions); the other 36 fire no law of passes 227 and 228 and read DIVERGENT at HEAD, as at
`97343175`: r11u173verify hw w12 w13, r11u185verify PU u06 and UD u04, r11u199verify C c06 and X x06, r11u204verify V191
rp2 and X x5, r11u205dec B3 b05 b07, D5 d01 d03, TP t12, r11u215repro R r07, r11u216repro NQ n11, r11u220repro SL s47,
r11u221verify I i02 i06, NP p08, Q q02 q11, X x02, v11u202repro PP p05, v11u206repro A a12, v11u219repro E e07 and S
s06_contassign_untouched, v11u220repro K k01 k06 k08 and T t19.

## 5. Composition ([evidence/compose/](evidence/compose/))

### 5.1 The firing census, the base's gate

The HEAD sweep with both traces (`/tmp/r11u233_wON`): probe 0 / 0 / 0 (EQUAL 3453, STRICT_NOTEQUAL 634), surelog 0 / 0
/ 0 (930 CMP_EQUAL + 24 STRICT_NOTEQUAL), uhdm2rtlil 0 / 0 / 0 (1602 + 4), downstream 803 IDENTICAL / 66 SLANG_REJECT / 2
EQUIVALENT / 0 DIVERGENT, exit 0. **22 trace files** ([head_firing_census.txt](evidence/census/head_firing_census.txt)):
§ pkgPatFuncBodyLeftoverNoParent227 on exactly the twenty N0003 probe cases (r11u24repro n3 n12; r11u26repro m6 m8 m9
m13 m15; r11u28repro a4 a5 (twice) a6 a7 a13 a16; r11v26repro v2 v9 v12 v13 v15 v16 v18) and
§ fwdPkgRefClassScopeSpan227 twice on each FuncStructVal mode; **pass 228: 0 trace files** over every corpus row-mode,
every probe case and every downstream lane (positive control: the same variables fire every law of pass 228 on the grid,
the `FIRED` lines of section 2). The trace is byte-neutral: byteverify of this sweep against the untraced integration
sweep `/tmp/intr11u227` (the same binary) reads MOVERS 0 / 2560 (PATH_SETS_IDENTICAL; SELFCHECK 2559 / 2560 flagged).

### 5.2 Each landing off alone and both together

| sweep | probe | surelog | uhdm2rtlil | downstream | corpus byte movers vs HEAD (byteverify, 2560) | probe byte movers (4087) |
|---|---|---|---|---|---|---|
| `R11U227_OFF` | 0 reg / 0 conv / 20 changes | 0 / 0 / 2 | 0 / 0 / 0 | 803 / 66 / 2 / 0, csv identical to HEAD's | 2: FuncStructVal d, t | 20: the N0003 cases |
| `R11U228_OFF` | 0 / 0 / 0 | 0 / 0 / 0 | 0 / 0 / 0 | the same | **0** | **0** |
| both off | 0 / 0 / 20 | 0 / 0 / 2 | 0 / 0 / 0 | the same | 2 (the same) | 20 (the same) |

drivers/compose.py (status level): conversions 0 in every stage; the 22 changes are all OWN227; **CANCEL 0**.
drivers/bytecancel.py (byte level over 7452 databases: probe, both corpora, every downstream slang lane): OWN227 22
(probe 20, FuncStructVal d t), SAME 7430, **CANCEL 0, JOINT 0, 0 lanes moving**. Each landing's movers are its own
claim exactly: pass 227 FuncStructVal d/t and the twenty cases; pass 228 none. The cross-ground pairs are measured on the
X cases (section 2.6).

### 5.3 The dropped duplicate § refChainDrainIdOrder227

`R11V226_IDORDER_OFF` on MiniAmiq (6 draws per mode, 3 concurrent, drivers/det.sh with a wrapper binary): default 2
hashes (`48699d65` x1, `f8ac73f8` x5), testflags 2 (`c31175d9` x5, `62214489` x1), none HEAD's `7d6c076f`; the uhdm-dump
of a switched-off draw equals HEAD's line for line (1,959,029 lines; only the header naming the file differs). HEAD draws
one hash in 12 of 12 per mode. § fullNameDrainIdOrder226v is the cure and no other switch is needed: with pass 227 off
no UVM database moves (5.2).

### 5.4 The changes: record dumps ([unmask_227.txt](evidence/compose/unmask_227.txt), drivers/unmask2.py)

Pass 227 off -> HEAD, every changed row re-read record by record: **all 22 SUBSET** (every HEAD record is one the
switched-off database had; 0 new): FuncStructVal d `endcol(7)` -> `file(5)` (the two #747-family records gone; the head
is #4782, the INSTR_PER_FETCH constant golden locates at 618:22-45 and ours leaves location-less), t `endcol(10)` ->
`file(9)` (head #7129, the same constant); the twenty probe cases each lose the listing's `ref_typespec pk` record (#153
... #518) and head at the module listing's leftover copy (`<in>pk::c_t.u`, `<in>pk::nw_t.un`, `<in>pk::k_t.n`,
`<in>pk::c_t.p`): 16 `fullname(5)` -> `(4)`, 3 `(9)` -> `(8)`, a13 `(3)` -> `(2)`, a5 `(10)` -> `(8)`. v11u227 checked
the same at `ac0dda58`.

### 5.5 The away census over the full corpora ([away_landings/](evidence/compose/away_landings/), drivers/awaylandings.sh + awayall.py)

Both keys (chain-keyed, and flat with the position-aware in-place pairing of map 14), both record forms (the gate's
canonical records and strictcmp_x's raw full names), each landing's single-off sweep against HEAD:

| landing | canonical: chain lost / toward, flat lost / toward (unpaired) | raw: the same | reversed control |
|---|---|---|---|
| 227 | 0 / 25, 0 / 25 (0) | 0 / 25, 0 / 25 (0) | 25 lost, 25 flat unpaired |
| 228 | 0 / 0 (no database moves) | 0 / 0 | 0 (nothing to reverse: the instrument's positive control is the grid census of section 2, which reads the breaks) |
| both | 0 / 25, 0 / 25 (0) | 0 / 25 | 25 lost |

## 6. Determinism ([evidence/det/](evidence/det/))

drivers/det.sh (the harness's command line and cwd from the HEAD sweep, draws concurrent, at most 3 at once):

| row-mode | 3 draws at the base | 12 draws |
|---|---|---|
| Earlgrey_0_1 d / t | `ede36385c330` x3 / `260e88febe42` x3 | |
| MiniAmiq d / t | `7d6c076f4328` x3 / x3 | `7d6c076f4328` 12 / 12, 12 / 12 |
| SeqDriver d / t | `a3349e9731b2` x3 / `248ae493bf34` x3 | |
| SimpleUVM d / t | `83c1a233ad99` x3 / `61cbfaab4940` x3 | |
| Scoreboard d | `dbb7fce68eb4` x3 | `dbb7fce68eb4` 12 / 12 |
| BuildUVMPkg d / t | `6a6d62e38946` x3 / x3 | |

Every draw equals the HEAD sweep's database and exits 0 (Scoreboard t is SLANG_REJECT by baseline). Map 15's reading
(one hash everywhere) holds.

**§ pvSizeNoElemDeclines228v** (ExprEval allocating in the serializer): 16 concurrent draws on each of five cases where
it fires (drivers/det16case.sh, R11U228_TRACE on the first draw): v11u219 S s01_dyn_inner, s01b_queue_inner, v11u223 S
s10_dyn_queue_decline, v11u228 FS s10 and s12: **one hash in 16 of 16 on each, every exit code 0**. The law fires on no
corpus or probe database (section 5.1), so it cannot make one nondeterministic.

## 7. The residues at the base

| pass | residue (its README's rank) | at `aba8c391` |
|---|---|---|
| 227 | 1 FuncStructVal #4782 (N2472 / N2473), then N0980, N1946, N0891 | **stands**: FuncStructVal d `file(5)` #4782, t `file(9)` #7129 (5.4) |
| 227 | 2 N0003's module-listing leftover copies; m4 a2 v5 v6 unreached | **stands**: the twenty cases head at `<in>pk::...`; m4 and a2 `fullname(39)`, v5 and v6 `fullname(2)` |
| 227 | 3 the spaced `p2 :: E1`; the forward shapes ours folds | **stands**: F f09's spaced forms decline; every constant-slot shape of section 2.3 is stage 1 with the law unfired |
| v11u227 | pre-dot index, size casts, `C && p2::E1 ? a : b`, bf32 | size casts (f28, f19) stage 1 unfired: **stand**; the condition shape (f25) is reached through its pattern member, not the condition |
| v11u227 | Scoreboard d's svunit coin | **cured** (§ unitImportFileOrder229v): 12 of 12 draws one hash |
| 228 | 1 the 598 minted clone return variables | **stands**: MiniAmiq d and t each hold 788 function-parented variables neither a Return() nor listed (map 15 / r11u229: 788, of which 710 minted), 0 unreferenced return-like (tools/retvars) |
| 228 | 2 the `int` stamp on the elaborated param_assign constants | **stands**: the uhdm-cmp head of every untyped-pattern member case (the 17-line head of M/J, e.g. J j13) |
| 228 | 3 `'0`, `'z`, net-declaration `'1` onto a substituted width | **stands** for o05 and o19 (EQUIVALENT); o12 reads IDENTICAL at the base; o21 (two member widths) EQUIVALENT |
| v11u228 | 2 root shapes left to the base: a selected side that is a struct parameter; a root in another instance's generate or package scope; an override chain across two instances of the parent | the first **stands** (m18: the implementer's fold was right by 1 record); the second **stands** (m37 m38 unfired); the third was a BREAK in one order (section 0, #2) and a miss in the other, **fixed** by § memberRootAncestorInstance233v (x05 x06: 2 toward per view) |
| 228 (new) | § parseViewSizeExprEval228 with a genvar dimension argument | **new residue** (S/s11): 56 where golden reads 5, 6, 4; pristine kept the calls; DIVERGENT on both |
| v11u228 | 3 `$size` shapes left: package-qualified operand, modport member, parameter operand, an expression around the call, assign statement and variable initializer | **stand** (s15: the initializer and the assign statement keep their bytes) |

Target rows at the base: FuncStructVal d/t `file(5)` / `file(9)`, struct_param_func_config d/t `fullname(5)`,
cfg_func_width_loop d/t `line(3)`, BlackBePipeInt d/t `type(1)`, MiniAmiq and SeqDriver d/t `line(2)`, SimpleUVM d/t
`file(36)`, Scoreboard d `file(12)`, BuildUVMPkg d/t `line(14)`, Earlgrey_0_1 d/t `fullname(19)`.

## 8. Fence and process ([evidence/audit/](evidence/audit/))

drivers/fenceaudit.py (static) and fencecheck.sh (the env.sh of each directory sourced in a bare shell, with the tool
variables, and beside a canaudit.sh whose FENCED= line holds two dummy names):

* **No driver of the four directories reads a fenced source or database**; no file in them names a fenced test (0 files;
  the positive control, a planted name, is found).
* **Fence read and fail-closed.** r11u227repro, r11u228repro and v11u228repro env.sh read the FENCED= line themselves
  and refuse two names (rc 1) and a bare shell (r11u227: `${VAR:?}` aborts the shell; r11u228/v11u228: rc 1 on the
  tool check); census.sh of r11u227/r11u228/v11u228 and r11u227's dscensus.py read canaudit.sh themselves; every other
  shell driver sources its env.sh or checks four names. **v11u227repro has no env.sh**: its drivers take `$FENCED`
  from the caller; bytectl.sh, awaymov.py and dscase.py refuse unless it holds four names, but **case.sh checks only
  that `$FENCED` is non-empty** (`[ -n "$FENCED" ]`), so a one-name list passes it. **No fence check at all**:
  v11u227 recaway.py, r11u228/v11u228 awaycase.py and flatexplain.py, v11u228 gridsum.py (readers of case stores and
  record files the caller hands them) and r11u228/v11u228 udump.sh (dumps any database path it is handed).
  r11u227's uvmdist.sh reads the fence through r11u211map's common.py and fails closed.
* **Predictions frozen with an md5 and a time stamp**: pass 227 yes (predict_final.stamp: `8532dbcb...`,
  2026-09-29T11:35:38Z, law7.bin's md5); v11u227 yes (predict_fix.stamp, 12:30:36Z); v11u228 yes
  (prediction_frozen.txt, 08:29:47-04:00, fix3's md5, the empty prediction's md5); **pass 228 no time stamp**:
  prediction.txt is empty (md5 `d41d8cd9...`) and nothing records when it was frozen.
* **First lines**: every packaged case names its law in its first line and the counts match the READMEs (r11u227 FW 22,
  PL 12, NP 20; v11u227 BF 37 with 10 naming § fwdPkgRefConstSlotWhole227v, BP 12, BN 15; r11u228 MR 17, PS 12; v11u228
  FM 14, FS 12, FB 4, FR 23). One mismatch: **v11u228 FS/s10** is one of the two fresh crash cases of
  § pvSizeNoElemDeclines228v the README names, but its first line names only § parseViewSizeExprEval228 (s12 names both).
* **Tool guards** (a variable run as a command without `[ -x ]`): r11u227repro case.sh (`$SURELOG`, `$UHDM_CMP`,
  `$STRICT_CMP` and the binary argument), r11u227repro det16.sh (the binary argument `$BIN`, run through `eval`);
  v11u227 case.sh guards through an `eval`/`[ -x ]` loop (the static audit's regex misses it; read by hand: guarded).
  Python drivers pass tools as argv (an unset variable raises). r11u228/v11u228 udump.sh call uhdm-dump by a literal
  path after `[ -x ]`.
* **No patch file** in the four directories.
* **Hard-coded scratch paths** (what a re-run needs): r11u228repro env.sh `B=${B:-/tmp/r11u228_bin}` (the frozen
  binaries), case.sh `S=${S:-/tmp/r11u228_s}` (golden and case store), awayall.py `/tmp/r11u228_awaycache` (record cache,
  or `$S`); v11u228repro env.sh `B=${B:-/tmp/v11u228_bin}`, case.sh `S=${S:-/tmp/v11u228_s}`; r11u227repro and
  v11u227repro take `$B` and `$S` from the caller (no default), so each needs the binaries directory and a scratch root
  exported.
* **This pass**: every driver sources drivers/env.sh (fails closed on the fence and on every tool variable) or checks
  four names; the binary arguments of case.sh, det.sh, det16case.sh, firecases.sh, fixrun.sh and bytectl.sh are checked
  with `[ -x ]` before use; no comparison ran with the main checkout as the current directory; no process was killed.
  **Process slips**: (1) one `ps` listing taken to see what the sweep was running printed ANOTHER agent's census
  command line whose filter argument holds the fenced names (nothing of this pass ran on fenced sources; no file holds
  the names; later listings were filtered to this pass's own paths); (2) one grep over this pass's own case list spelled
  the four names as its pattern instead of `$FENCE_RE` (a scan of a scratch list of unfenced case paths, 0 hits; no
  binary or script ran on a fenced source or database); (3) drivers/det.sh was edited (a concurrency cap) while its
  first run executed; that run's loop had already been parsed and printed all 11 row-modes, then bash reported a syntax
  error reading the edited file's last line (evidence/det/det_base3.txt keeps the 11 lines). Scratch: 11 GB under /tmp/r11u233_* and the three worktrees /tmp/wt_r11u233, /tmp/wt_r11u233fix, /tmp/wt_r11u233rb (the golden cache ~/.cache/slang-uhdm-goldens is shared).

## 9. Files

* `cases/`: M (40, the member-root laws), J (32, the break shapes and their decoded boundary in FM f03's form), S (25,
  the parse-view `$size` laws), B (12, § sizeBitNetIsVar228), F (36, the forward-reference laws), P (12,
  § pkgPatFuncBodyLeftoverNoParent227), N (7, § newArrayPartSelStripped227), X (9, the cross-ground pairs); every
  case's first line names its laws; drivers/mkcases_*.py write them.
* `drivers/`: env.sh, laws.py, case.sh, grid.py, gridall.sh, caseaway.py, awaypair.py, fixrun.sh, gridsum233.py,
  recs.sh, dscases.py, firecases.sh, bytectl.sh, sweep.sh, census.sh, fixsweeps.sh, predict233.py, compose.py,
  bytecancel.py, unmask2.py, awayall.py, awaylandings.sh, bvmirror.sh, det.sh, det16case.sh, fenceaudit.py,
  fencecheck.sh (copied from r11u229verify, v11u227repro and r11u222map where each header says so).
* `evidence/`: grid (raw grid output per family, the censuses, grid_table.md), fix (fix runs, the landed-grid byte
  control), census (the HEAD firing census, the fix's frozen prediction, stamp and positive control), compose, sweeps
  (logs and csvs without any line naming a fenced test), downstream, det, audit, residues.
