# r10buvm8 — ADVERSARIAL VERIFICATION (`§ pkgRetTopCallArgFormalTs8`)

**VERDICT: ACCEPTED WITH TWO LAW CORRECTIONS SHIPPED BY THE VERIFIER.**
Every headline number in the implementer's report reproduces BIT-FOR-BIT on
binaries this verifier built itself. The law as SHIPPED, however, is WRONG on
two shapes of legal SystemVerilog, one of which turns a **CMP_EQUAL arm into
CMP_NOTEQUAL** (`vfwdts8.sv`). Both were found golden-vs-golden, both are fixed
here, and the fixed binary is the deliverable
(`/tmp/r10buvm8.verified.patch`, binary md5 `ecbf78e882cc635b135f74d7f537fdac`).

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours. BASE `e2f318c`.

| binary | md5 | built where |
|---|---|---|
| pristine `e2f318c` | `929164ae7d13974af4b1453bc7ce02f5` | `/tmp/wt_vbuvm8pris`, `-j 2` |
| implementer's patch, applied to my own fresh `e2f318c` | `79f054da8aafb48c875d696d94108430` | `/tmp/wt_vbuvm8` — **identical to the implementer's** |
| **VERIFIED** (`+` the two corrections) | `ecbf78e882cc635b135f74d7f537fdac` | reproduced from the patch alone in a THIRD fresh `e2f318c` worktree (`/tmp/wt_vbuvm8fresh`) |

## 1. THE TWO BREAKS

Both were found by writing arms whose CELLS DISAGREE (an arm that agrees is not
an arm that tests), measuring GOLDEN first, and only then reading our two
binaries. Numbers below are from `vgrid8.sh` with `PATCHED=` the IMPLEMENTER's
binary — i.e. they are the shipped patch's own readings.

### 1.1 `§ pkgRetCalleeDeclaredFirst8v` — a FORWARD-declared callee is BARE

`ExprEval::evalFunc` returns immediately when `getTaskFunc(name, inst)` misses,
and when Surelog compiles a package function's body only the subroutines
declared EARLIER in that package are registered. Golden therefore leaves the
actuals of a call to a LATER-declared callee bare, even though `vpiFunction` is
filled in by a later binding pass (so OUR `linked4` sees a bound callee).

| arm | shipped patch | verified |
|---|---|---|
| `vfwdts8.sv` (forward callee, formals of a PACKAGE TYPEDEF type) | **pristine CMP_EQUAL → CMP_NOTEQUAL**, 2 objects golden does not have | CMP_EQUAL, 0 MOVED-AWAY |
| `v4order8.sv` (order matrix: before / self-recursive / mutual / forward) | 6 MOVED-AWAY cells (`o4g`, `o4f2`, `late_cal`) | 0 MOVED-AWAY, arm goes CMP_NOTEQUAL → **CMP_EQUAL** |

Measured golden-vs-golden on `v4order8.sv`, where every callee reaches a DPI
import so the FOLD is never the fence and declaration order is the only
variable: callee BEFORE caller → STAMPED; callee == caller (recursion) →
STAMPED; callee AFTER caller → **BARE**. Declaration order is read as the SCOPE
MEMBER INDEX, never as a SourceLocation (uvm_pkg declares half its subroutines
inside macros, and the campaign's emitter-nondeterminism note forbids ordering
by location). Cross-scope callees are deliberately left alone — another
package's function is compiled before the importer, and `vxpkg8.sv` /
`v7misc8.sv`'s `qp7::qf` are golden-STAMPED and stay stamped.

### 1.2 `§ pkgRetArgTsFormalNameShadow8v` — an actual that SHADOWS an earlier formal

`evalFunc` reduces actual *i* against a map that ALREADY binds the callee
formals at positions < *i*. An actual that is a BARE NAME equal to an earlier
formal's name therefore reduces to **THAT EARLIER ARGUMENT OBJECT**, and formal
*i*'s typespec is written THERE — leaving actual *i* BARE. Measured
golden-vs-golden (`v11coll8.sv`, `v12coll8.sv`, `vshadowcells8/`):

| callee formals ← actuals | golden |
|---|---|
| `(a,b)` ← `(a,a)` | arg0 carries formal **b**'s ts, arg1 **BARE** |
| `(a,b)` ← `(b,a)` | arg0 carries formal **b**'s ts, arg1 **BARE** |
| `(a,b,c)` ← `(a,a,a)` | arg0 carries formal **c**, args 1-2 **BARE** |
| `(a,b,c,d)` ← `(a,a,a,a)` | arg0 only; args 1-3 **BARE** |
| `(a,b,c,d)` ← `(d,c,b,a)` | args 0,1 stamped; args 2,3 **BARE** |
| `(a,b)` ← `(a+1,a)` | arg0 carries formal **b**, arg1 **BARE** |
| `(b,a)` ← `(a,a)` | POSITIONAL, both stamped |
| `(a,b)` ← `(b,b)` | POSITIONAL (a LATER formal name is not in the map yet) |
| `(a,b=7)` ← `(a)` | the ONE written actual stamped; the omitted default is not an argument |
| `(a,b)` ← `(1,a)` | pos0 constant stamped, pos1 **BARE** |
| `(ref a,b)` ← `(t,a)` | pos0 stamped, pos1 **BARE** |

Shipped patch: `v11coll8` 3 MOVED-AWAY, `v8twice8` 1, `vshadowcells8/v21_s7` 2 —
extra `ref_typespec` objects golden does not have, and the stamp landing on the
WRONG object. Verified: every one of those cells matches golden and the arms go
CMP_NOTEQUAL → **CMP_EQUAL**. `v10rep8.sv` is the control that separates
"repeated actual" from "shadowing": its callee formals are `p0,p1,p2` (no
collision) and it is clean under BOTH binaries.

## 2. EVERY HEADLINE NUMBER, RE-MEASURED

| claim | implementer | verifier |
|---|---|---|
| ladder calibration (golden vs golden) | 0 rungs / 183 142 objects | **0 rungs, stop=FIXPOINT, 183 142 objects** |
| ladder rungs, BuildUVMPkg, fixpoint | 251 → 248 | **251 → 248** |
| `ref_typespec\|<rhs-null>\|MISSING-OURS` family | 8 → 5 | **8 → 5** |
| rung-list diff by LHS object | `#4528`,`#4531`,`#1480` removed, 0 added | **exactly those three removed, 0 added** |
| new rung 1 | `<null>`/`package(uvm_pkg)#2`, bisected to `enum_typespec(recursion_state_e)@18219` | **identical, and it IS pristine's rung 3** |
| our object count | — | 180 603 → **180 606** (the 3 new ref_typespecs) |
| BuildUVMPkg `uhdm-cmp` | 17 → 645 165 lines, heads 1 → 1 | **17 → 645 165, 1 → 1** |
| goldens | 23 PASS, `/bin/false` 0 | **23 PASS / 0 FAIL; `/bin/false` 0** |
| uhdm2rtlil both modes | 679 / 50 / 2 | **679 / 50 / 2**, `ct8rows` pristine-vs-verified **0 differing rows over 1 462** |
| Surelog `--mode both` | 0 differing rows / 1 588 vs committed | **0 differing rows over 1 588** vs `results/golden_surelog.csv` AND vs the pristine sweep (status AND dump column) |
| byteverify surelog | 10 / 953 movers | **10 / 953, the same ten names**; controls 952/953 and 11 |
| byteverify u2r | 2 / 1 358 | **2 / 1 358** (`NestedCallsOfTheSameFunction` ×2); controls 1357/1358 and 3 |
| FIVE-ROW WALL, cmp LOGS byte-compared | SimpleUVM 1405511, SeqDriver 1450011, Scoreboard 1399779, Earlgrey 34, EvalFunc 0 | **all BYTE-IDENTICAL at exactly those line counts**, heads 1→1 / 0→0 |
| canaries | surelog ok=52 changed=0, u2r ok=16 changed=0 | **same** |
| ctcan2 / canaudit | 58 + 2 ok, changed=0, EXPECT_UNKNOWN 1/6; audited=29 UNCOVERED=0 FENCE-BREACH=0 | **same, self-tests firing** |
| pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **identical on both binaries, both modes** (raw database md5) |
| boundary arms | 99 IDENTICAL, 0 MOVED | **99 IDENTICAL** + **sd9's 44 grid arms and earl52's 7 = 51 more, 0 MOVED** (150 total) |
| determinism | 1 distinct hash / 3 runs | **1 / 3, 0 NO_OUTPUT** (on the shadow arms, the newly reachable path) |
| committed `golden_uhdm2rtlil.csv` staleness | 2 rows, PRISTINE too | **CONFIRMED**: `ParameterSizeOfInstance`, `paramod_genscope_child` read `differ` there and `match` on a fresh PRISTINE sweep; `results/gate_uhdm2rtlil.csv` already says `match`. Nothing promoted; `results/*.csv` untouched. |

The verified binary moves EXACTLY the same 12 databases as the shipped one, and
on the movers the two binaries' databases are byte-identical (`SAME` for
BuildUVMPkg, EvalFunc, NestedCallsOfTheSameFunction, Earlgrey_0_1, Scoreboard,
SeqDriver, SimpleUVM) — the two corrections are arm-visible and corpus-neutral,
which is why every corpus number above is unchanged by them.

## 3. THE ARM SWEEP (`vreall8.sh`)

24 arms, **483 cells**, `PRISTINE` vs `VERIFIED`:
**257 CONVERTED, 0 REGRESSION, 2 MOVED-AWAY** (both the R4 fold residue below),
14 arms go CMP_NOTEQUAL → CMP_EQUAL. Coverage: arg kind × position (ref_obj,
constant, string literal, operation, concat, bit/part/indexed select, cast,
struct, enum, real, queue, hier_path, func_call), formal direction (input,
`output`, `inout`, `ref`, defaulted, non-ANSI), call kind (DPI import, plain SV,
foldable, system, method, cross-package, recursive, forward), body shape
(single-statement, declaration prologue, nested named block, `begin`/`end`
fence, if/for/while/do/case/fork fences, assignment RHS, task body, class
method inline and out-of-body, module function), and the two new sub-laws above.

## 4. RESIDUES, RANKED (all measured; none is a regression)

| # | residue | direction | measured price |
|---|---|---|---|
| R4 | callee whose body FOLDS in golden: golden has no object at all, we keep the call AND now stamp its actuals | **we move AWAY from golden** — the only such cells in 483 | 2 arm cells (`v7misc8` 11:51, `v9fold8` 5:50). `v9fold8` stays CMP_EQUAL on both binaries but its dump distance grows 15 → 22 lines. **Corpus price 0**: any corpus instance would be a byte mover, and all 12 movers are attributed to CONVERTED / REPOINTED / RESIDUE. |
| R8 | a `func_call` ACTUAL is STAMPED by golden (`v7misc8` 12:45 `f2(f2(a,1),2)`, and the census cell is **12 TS / 0 noTS**) — we leave it bare. **This refutes the implementer's README**, which claims "a func_call actual takes nothing" from one arm cell while its own census says the opposite | we UNDER-stamp | 1 arm cell; the arg AFTER a func_call arg is stamped by golden and by us, so the window is not truncated |
| R7 | a DPI import declared AFTER the caller is STAMPED by golden (`v20ord8` 13:55/13:58) — the new decl-order fence over-fires for import callees, whose registration is not source-ordered like an SV function's | we UNDER-stamp | 2 arm cells; the SV-function forward case (`c_late2`→`sv_late`) is golden-BARE and correct. This is the next pass's distinguisher: **callee has no body** vs SV function. |
| R1 | string LITERAL on a string formal (`vshadowcells8/v21_s4` 10:47) — `!strFormalConst` still guards the arm | UNDER-stamp | census cell empty over 3 657 goldens; arm stays CMP_NOTEQUAL identically on both binaries |
| R2 | NAMED-argument call (`v7misc8` 9:48/9:55) — `!namedArgs9`, another pass's measured law | UNDER-stamp | buvm4's laws HOLD: no named-arg cell moves on any binary |
| R3 | wildcard-import clone listing (SeqDriver `adpcm_pkg`, 2 objects) | UNDER-stamp | SeqDriver's cmp log is byte-identical |
| R6 | class-method top-level return (census 156 TS / 822 noTS, mixed) | fenced out | `voob8.sv` (out-of-body method, where `pkgScopeInst` is non-null) stays BARE on both binaries — the fence does NOT leak |
| R9 | **Surelog SEGFAULTS** on `return f2(f2(a,1), a)` — a nested call at position 0 with a name-shadowed actual at position 1 (`vshadowcells8/v21_s9.sv`, rc=139, no database) | UNMEASURABLE cell | our binaries BOTH emit without crashing; no golden can exist, so no corpus test can contain this shape with a golden. Recorded, not guessed at. |

## 5. FILES ADDED BY THE VERIFIER

`VERIFY.md` (this file) · `vgrid8.sh` (three-way golden/pristine/patched cell
grid, SAME-CWD — a UHDM database records the source's absolute path) ·
`vcen8.cpp` (census that also reports each stamped actual's `Instance()`
identity class, the field `grid8.sh` cannot see) · `vreall8.sh` (the whole arm
sweep) · `vwall8.sh` (the FIVE-ROW WALL: official `uhdm-cmp` against each
mover's own golden with BOTH binaries, logs byte-compared) · `vbnd8.sh`
(boundary gate, verifier-prefixed workdirs) · `vsweeps8.sh` · arms
`vfwd8 vfwdts8 voob8 vxpkg8 v4order8 v5a8 v5b8 v5kinds8 v6ctx8 v7misc8 v8twice8
v9fold8 v10rep8 v11coll8 v12coll8 v20ord8 v21shadow8 v22body8` +
`vshadowcells8/v21_s1..s9`.

### reproduce
```sh
PRISTINE=<e2f318c bin> PATCHED=<verified bin> ./vreall8.sh          # 24 arms
PRISTINE=... PATCHED=... ./vgrid8.sh v4order8.sv                    # one arm
PRISTINE=... PATCHED=... ./vbnd8.sh ../r10earl53repro ../r10sd9repro/grid9 ...
./vwall8.sh "<patched wd>::default/SimpleUVM-1dc93a62"              # the wall
ctladder <golden.uhdm> <ours.uhdm>            # 251 pristine / 248 verified
```
