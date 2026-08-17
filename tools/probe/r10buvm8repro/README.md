# r10buvm8 — § pkgRetTopCallArgFormalTs8 (+ § pkgRetTopArgTsElabTwin8)

**BASE `e2f318c`.** Production surface: `src/ExprEmit.cpp` (2 hunks in the ONE
user-function-call arm of `emitExpr`), `src/StmtEmit.cpp` (1 hunk in the ONE
`StatementKind::Return` arm), `include/UhdmExporter.h` (1 member + its
mechanism note). Probe surface: `tools/probe/r10buvm8repro/` only.
**127 inserted lines, 5 deleted**, comments included.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and every script here.

**Result, up front.** BuildUVMPkg **still reads `CMP_NOTEQUAL` in both modes —
this pass does NOT make it pass.** What it does is CLEAR THE HEAD (R0) on both
modes and expose the next one, which is a pre-existing defect two rungs deeper
(§7). The
ladder (the official `design::Compare` run to fixpoint; calibration 0 rungs on
183 142 golden objects) falls **251 → 248 rungs**, the rung-list diff is
EXACTLY the three `ref_typespec|<rhs-null>|MISSING-OURS` rungs removed and
**zero added**, and the official `uhdm-cmp` head ADVANCES from pristine's rung 1
to pristine's rung 3. Five gates green. **12 movers over 2 311 databases, every
one PREDICTED BY NAME before a single byte was compared**, every one attributed:
55 new `ref_typespec` objects (all of them landing on golden's own), 8 corrected
`vpiActual` pointers, **0 objects moved away from golden, 0 lines lost.**

---

## 1. THE HEAD (R0 of this pass)

`uvm_pkg.sv:9737`, inside `function bit uvm_is_match (string expr, string str)`:

```systemverilog
9734: function bit uvm_is_match (string expr, string str);
9735:   string s;
9736:   s = uvm_glob_to_re(expr);
9737:   return (uvm_re_match(s, str) == 0);
```

```
LHS(golden) ref_typespec: (uvm_pkg::uvm_is_match::s), id:4528
            |vpiParent: ref_obj (uvm_pkg::uvm_is_match::s) 9737:24-9737:25
            |vpiActual: string_typespec  7652:50-7652:56
RHS(ours)   <null>
```

`7652:50-7652:56` is the `string` keyword of the **CALLEE FORMAL** `re` in
`import "DPI-C" context function int uvm_re_match(string re, string str);`.

## 2. THE MECHANISM — read out of Surelog + UHDM, then measured

Four source facts compose into the law. None of them is a guess.

1. **`CompilePackage.cpp`, `FunctorCompilePackage::operator()`** compiles a
   package **TWICE**: the elaborated `Package` with `Reduce::Yes`, then
   `m_package->getUnElabPackage()` with `Reduce::No`.
   `UhdmWriter.cpp:4925/4956` puts the first in `design.TopPackages` and the
   second in `AllPackages`. A **class** and a **module** are compiled once.
2. **`CompileStmt.cpp`, `case paRETURN`** passes the INHERITED `reduce` into
   `compileExpression`. It is the only arm in that switch that does: every
   nested construct hardcodes `Reduce::No` — `paSeq_block` (line 351, so an
   EXPLICIT `begin`/`end` around a function body CLOSES the window),
   `paIF`/`paCASE`/`paWHILE`/`paDO`/`paFOR`/`fork`, and every assignment RHS
   through `compileBlockingAssignment`. `compileFunction`'s multi-statement
   body (`CompileStmt.cpp` ~2481) synthesises a `begin` and compiles each
   top-level statement with the inherited `reduce`, so ONE synthetic `begin`
   between the return and the function is still inside the window.
3. **`CompileExpression.cpp` ~3245**, the user-function-call arm:
   ```cpp
   VectorOfany *args = compileTfCallArguments(...);
   if (reduce == Reduce::Yes) result = EvalFunc(func, args, ...);
   if (result == nullptr || invalidValue == true) { fcall->Tf_call_args(args); result = fcall; }
   ```
4. **`UHDM/templates/ExprEval.cpp`, `evalFunc`'s "set args" loop (~5861)**:
   ```cpp
   typespec *tps = io->Typespec()->Actual_typespec();
   expr *ioexp = (expr *)args->at(index);
   if (expr *exparg = reduceExpr(ioexp, ...)) {
       if (exparg->Typespec() == nullptr) { ...make ref_typespec...; exparg->Typespec(crt); }
       exparg->Typespec()->Actual_typespec(tps);
   }
   ```
   The stamp is a **SIDE EFFECT that happens BEFORE the body is evaluated**, and
   `tps` is the formal's **own typespec object, SHARED, not cloned**. If the body
   then folds, the whole call is replaced by the constant and the stamped
   actuals leave the tree with it; if it cannot fold (a DPI import has no body at
   all), the call survives carrying them. `evalFunc` returns immediately when
   `getTaskFunc(name, inst)` finds no callee — an UNRESOLVED call is never
   stamped.

`UhdmAdjuster`'s `leaveReturn_stmt`/`leaveOperation`, which reduce the same
expressions, are **NOT** the mechanism here: `UhdmWriter.cpp:5188` runs the
adjuster only under `getElabUhdm()`, and BuildUVMPkg is `-parse`.

### The sharing is MEASURED, not assumed

`ref_typespec::Compare` reads `VpiName` + `VpiDefName` + `Actual_typespec`, so
the identity of the actual is the whole cmp-visible content. On BuildUVMPkg
golden:

| | arg's `vpiActual` id | the ELAB listing's io_decl typespec | the DEF twin |
|---|---|---|---|
| `uvm_re_match` formal 0 | **428** | 428 (tf #423, TopPackages) | 60263 (tf #60258) |
| `uvm_re_match` formal 1 | **431** | 431 | 60266 |
| `uvm_dpi_get_next_arg_c` formal 0 | **389** | 389 (tf #384) | 60224 |

## 3. THE LAWS

```
§ pkgRetTopCallArgFormalTs8   src/ExprEmit.cpp emitExpr (the func-call arm) + src/StmtEmit.cpp (Return arm)
§ pkgRetTopArgTsElabTwin8     src/ExprEmit.cpp, the same arm's typespec resolution
```

> **§ pkgRetTopCallArgFormalTs8** — In the **ELABORATED package listing only**
> (`design.TopPackages`, never `AllPackages`), a `func_call` **whose callee is
> bound** and which is reached from the expression of a `return` that is a
> **DIRECT statement of a PACKAGE-scope function's body** — the function's own
> `Stmt`, or a member of the synthetic `begin` a multi-statement body gets, and
> **not** inside any `if`/`for`/`while`/`do`/`case`/`fork`/explicit `begin` —
> gives EACH of its actuals a `vpiTypespec` → a fresh, EMPTY-named
> `ref_typespec` whose `vpiActual` is the **callee formal's own typespec object,
> positionally matched and SHARED**.
> Reach descends through operations, ternaries and other calls' ARGUMENT
> positions (a `$signed(dpi(x))` in a top-level return still stamps `x`).
> A `hier_path` actual takes nothing (`reduceExpr` returns nullptr for one, so
> `evalFunc`'s `if (expr* exparg = ...)` never runs); a `func_call` actual takes
> nothing either, though ITS OWN actuals do, one level down.
> A **class method** and a **module function** take nothing.
>
> **§ pkgRetTopArgTsElabTwin8** — and inside that window the shared typespec
> comes from the callee's **ELABORATED twin** (`pkgElabSubTf`), not from the
> def-listing object `siTf` deliberately holds during a package's own emission.

**Why the reachability model already in the file is the wrong one here.**
`argCtxOk`'s `currentTf` branch gates the package-body stamp on
`pkgBodyEvald9` — "called as a cont-assign rhs, or from a parameter
initialiser". That is right for a CONSTANT actual in an arbitrary body
(§ tfBodyConstArgNoFormalTs60) and wrong for this window: `CompilePackage`
compiles the WHOLE elaborated package with `Reduce::Yes`, so the stamp lands on
functions nothing evaluates. `uvm_is_match` is exactly that — no cont-assign and
no parameter ever reaches it. The law is therefore ONE NEW DISJUNCT of
`argCtxOk`, not a relaxation of the old one.

## 4. THE CORPUS CENSUS — GOLDEN-VS-GOLDEN, BEFORE ANY CODE

`gcensus8.sh` + `r10buvm8cen` over **3 657 golden databases** (every cache
entry, `.tmp*` duplicates skipped, 0 timeouts): **4 176 484 `tf_call` arguments,
of which 14 476 carry a typespec at all** — 0.35 %. This is a NARROW family and
the census is what says so. Every argument is classified by view / reach /
owner-scope / callee-boundness. The law's cell and its neighbours:

| cell | arg kind | TS | noTS |
|---|---|---|---|
| `func_call ELABPKG/RETTOP/PKGFN/**BOUND**` | ref_obj | **905** | **8** |
| | operation | 12 | 0 |
| | func_call | 12 | 0 |
| | hier_path | 0 | 25 |
| | constant | 0 | 0 |
| `func_call ELABPKG/RETTOP/PKGFN/UNBOUND` | ref_obj | 0 | 1 768 |
| | constant | 0 | 196 |
| | hier_path | 0 | 68 |
| `func_call DEFPKG/RETTOP/PKGFN/BOUND` | ref_obj | 432 | 677 |
| `func_call DEFPKG/RETTOP/PKGFN/UNBOUND` | ref_obj | 0 | 4 148 |
| `sys_func_call */RETTOP/*` | any | 0 | 42 |
| `func_call ELABPKG/RETTOP/**CLSFN**/BOUND` | ref_obj | 156 | 822 |
| `func_call NOPKG/RETTOP/**MODFN**/BOUND` | ref_obj | 93 | 0 |

Three things this bought, each of which changed the code:

* **BOUNDNESS is the discriminator, and it is clean.** One golden (uvm-1.2's
  `uvm_pkg`, cache `2175746050c0a188d7cc`) splits 61 stamped / 132 bare inside
  ONE listing purely on it. That is `getTaskFunc` failing inside `evalFunc`, and
  it is why the emitter gate carries `linked4`.
* **`hier_path` is 0/25** — the exclusion is measured, not inferred from one arm.
* **8 golden-bare exceptions** (4 caches × 2 objects, all
  `ovm_is_match(m_field, to)` in `ovm_config.sv`) are the ONE cell the law
  over-claims. None of them is in either sweep's database set, so the corpus
  price is **0**: `predict8.sh` over all 953 surelog + 1 358 u2r pristine
  databases names 10 + 2 candidates and no OVM row among them.

## 5. THE GRID — golden vs PRISTINE vs PATCHED

`grid8.sh` joins the three databases on (line:col, callee, formal position) and
folds a def/elab twin pair into one cell printed as the SET of the two views'
answers, so `-+TS` means "bare in the def listing, stamped in the elab one" —
golden's shape — and a view-only stamp can never read as a whole-cell one.

| arm | cells | CONVERTED | golden-has-no-object | residue |
|---|---|---|---|---|
| `v1_argts8.sv` (context × arg-kind × call-kind) | 51 | **24** | 4 | 1 |
| `v2_argts8.sv` (fence cells: scopes, formals, named args) | 47 | **22** | 4 | 2 |
| `v3_argts8.sv` (the DPI-vs-fold question) | 20 | **16** | 1 | 0 |

Cells worth naming, with the source line:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| v1 a1a `return (dpi_ctx_i(s, str) == 0)` | THE HEAD SHAPE | `-+TS` | `-` | **`-+TS`** |
| v1 a2a `return dpi_pln_s(init)` (single-stmt body) | | `-+TS` | `-` | **`-+TS`** |
| v1 a3a/a3b `r = dpi(...)`, `b = (dpi(...) == 0)` | assignment RHS | `-` | `-` | `-` |
| v1 a3c/a3d `if (dpi(...) == 0)`, `if (dpi(...))` | if condition | `-` | `-` | `-` |
| v1 a4a two operation levels · a5a bare call | | `-+TS` | `-` | **`-+TS`** |
| v1 a6a `return (sv_i(s, str) == 0)` | callee FOLDS | golden has **no elab object** | `-` | `-+TS` (§6 R4) |
| v1 a8a `dpi_ctx_i("lit", str)` | string literal on a string formal | `-+TS` | `-` | `-` (**R1**) |
| v1 a8b/a8c/a8e/a8g concat · queue elem · `k+1` · logic→int | | `-+TS` | `-` | **`-+TS`** |
| v1 a8d/a8f `c.cs`, `sv.a` | **hier_path** actual | `-` | `-` | `-` |
| v1 a9a/a9c `dpi_pln_v(expr);` · a10a `c.m_i(...)` · a10b `$sformatf` | statement / method / sys | `-` | `-` | `-` |
| v1 a12a void-returning enclosing function | assignment RHS | `-` | `-` | `-` |
| v2 b2a/b2b case cond / case item · b3a-c while/for/do | | `-` | `-` | `-` |
| v2 b4a ternary in a return · b5b two calls in one return | | `-+TS` | `-` | **`-+TS`** |
| v2 b5a `dpi_i(idn(s), t)` | inner call as actual | outer `-`, inner's `s` `-+TS` | `-` | outer `-`, inner **`-+TS`** |
| v2 b6a return inside `if`+`for` | | `-` | `-` | `-` |
| v2 b7a return inside a CLASS METHOD | | `-` | `-` | `-` |
| v2 b8a return inside a MODULE function | | `-` | `-` | `-` |
| v2 b10a-b13a typedef'd / struct / **output** / real formals | | `-+TS` | `-` | **`-+TS`** |
| v2 b15a `dpi_i(.re(s), .str(t))` | NAMED args | `-+TS` | `-` | `-` (**R2**) |
| v3 c1a `nofold_dpi` · c3a `nofold_q` | **non-DPI** callee that cannot fold | `-+TS` | `-` | **`-+TS`** |
| v3 c5a body wrapped in EXPLICIT `begin`/`end` | | `-` | `-` | `-` |
| v3 c7a `return $signed(dpi_i(s,t))` | through a sys call | `-+TS` | `-` | **`-+TS`** |
| v3 c9a `ref` formal actual · c10a same callee twice | | `-+TS` | `-` | **`-+TS`** |

`v3` is the arm that **REFUTED the DPI fence.** Every non-DPI callee in v1/v2
had FOLDED, which makes "DPI import" and "the fold failed" indistinguishable
there; `c1a`'s `nofold_dpi` (a plain SV package function whose body is itself a
DPI call) and `c3a`'s `nofold_q` are stamped by golden exactly like a DPI
import. The fence is the FOLD, not the import.

## 6. RESIDUES, each measured and left deliberately

* **R1 — a CONSTANT actual on a STRING formal** (v1 a8a). Golden stamps; we do
  not, because the shipped `!strFormalConst` fence (`FuncArgsByName`) still
  guards the arm. **Corpus price 0**: the golden census finds the
  `constant` sub-cell of `ELABPKG/RETTOP/PKGFN/BOUND` **empty** (0 TS, 0 noTS)
  across 3 657 databases.
* **R2 — a NAMED-argument call** (v2 b15a). Golden stamps; the shipped
  `!namedArgs9` fence (§ EvalFuncNamed, a measured law in its own right) still
  guards the arm, and narrowing another pass's law on one arm cell is not this
  pass's business.
* **R3 — a wildcard-import CLONE listing.** SeqDriver's `adpcm_pkg`
  wildcard-imports `uvm_pkg`; golden's clone carries the stamp in BOTH of its
  views because it is a `clone_tree` of already-stamped ELAB objects, and our
  clone of the class-method-shaped copy stays bare (2 objects per SeqDriver
  database, verdict `RESIDUE` in `attrib8.sh`). Ours does gain the 7 stamps in
  the clone's package-function-shaped copy.
* **R4 — a callee whose body FOLDS.** Golden replaces the whole call with a
  constant in the elab listing, so its actuals are not there at all; we keep the
  call (a pre-existing difference in the constant-function-folding family) and
  now stamp its actuals. The object was ALREADY extra, so its distance to
  golden does not change — and **the corpus contains zero instances**:
  `attrib8.sh` reports no `NOGOLDEN` verdict on any of the 12 movers. It is
  visible only on the arms (v1 a6a/a10c, v2 b1a/b1b, v3 c2a — 9 cells).
* **R5 — the 8 `ovm_is_match` golden-bare objects** of §4, corpus price 0.
* **R6 — a CLASS METHOD's top-level return.** The census cell is MIXED
  (156 TS / 822 noTS) and no discriminator was found for it, so the law fences
  it out on `pkgScopeInst` and the 156 stay bare. Within ONE golden the split is
  visible object by object (uvm-1.2's `uvm_printer::adjust_name` stamps its
  `uvm_leaf_scope(id, scope_separator)` actuals, six sibling cells in the same
  listing do not), which is what a missing distinguisher looks like — the next
  pass on this family starts there. A `MODULE` function's top-level return is
  NOT a residue: its cell is 93 TS / 0 noTS and those 93 are already produced by
  the shipped module-context law (whose own gate is "the body was REACHED" —
  v2's `b8a`, reached only from an `initial`, is golden-bare and stays bare).

## 7. WHY BuildUVMPkg's cmp LINE COUNT GREW — the head ADVANCED

`uhdm-cmp` prints ONE head, and its LINE COUNT IS HEAD PRINT SIZE, NEVER A
DISTANCE. BuildUVMPkg goes 17 lines → 645 165 lines, still `grep -c '^LHS:'` = 1,
and the ladder proves the direction:

| | pristine | patched |
|---|---|---|
| ladder rungs (fixpoint) | **251** | **248** |
| `ref_typespec\|<rhs-null>\|MISSING-OURS` family | **8** | **5** |
| rung-list diff (by LHS object) | — | exactly `#4528`, `#4531`, `#1480` removed, **0 added** |
| rung 1 | `ref_typespec#4528` (9737:24 `s`) | `<null>` / `package(uvm_pkg)#2` |
| rung 2 | `ref_typespec#4531` (9737:27 `str`) | ... |
| rung 3 | `<null>` / `package(uvm_pkg)#2` | = patched rung 1 |

Patched rung 1 **is** pristine rung 3, referrer-bisected to the same object
(`enum_typespec(recursion_state_e)@18219`). That rung is a PRE-EXISTING defect
this pass does not touch: 12 typespecs inside our elaborated `uvm_pkg` carry
`vpiInstance` → the DEF package where golden's carry the elab one or none
(`m_verbosity_setting` and `uvm_cmdline_parsed_arg_t` are golden-NULL, hence the
`LHS: <null>`). It was masked by the two ref_typespec rungs and prints the whole
package. **The remaining 5 rungs of the brief's 8-rung family are the
`bit_typespec` sub-family** (`uvm_field_flag_t` ×4, `uvm_reg_cvr_t` ×1) — a
different shape, correctly untouched.

The 8 rungs of the family, enumerated on the pristine ladder, for the record:

| rung | object | shape |
|---|---|---|
| 1 | `ref_typespec#4528` < `ref_obj(s)` 9737:24 < `func_call(uvm_re_match)` | **this pass** |
| 2 | `ref_typespec#4531` < `ref_obj(str)` 9737:27 < `func_call(uvm_re_match)` | **this pass** |
| 86 | `ref_typespec#1480` < `ref_obj(init)` 7594:33 < `func_call(uvm_dpi_get_next_arg_c)` | **this pass** |
| 11, 56, 143, 144 | `bit_typespec(uvm_field_flag_t)` 7859:9 | not this family |
| 142 | `bit_typespec(uvm_reg_cvr_t)` 60757:10 | not this family |

## 8. THE FIVE GATES

| # | gate | result |
|---|---|---|
| 1 | build BOTH binaries, `-j 2`, md5 separately | pristine `929164ae7d13974af4b1453bc7ce02f5` (rebuilt from a second `e2f318c` worktree to the SAME md5, so the build is deterministic and the pristine side is not a stale artefact), patched `79f054da8aafb48c875d696d94108430`. **The patch is then applied to a THIRD, untouched `e2f318c` worktree and built from scratch: md5 `79f054da8aafb48c875d696d94108430` — the deliverable reproduces the binary every reading above was taken with, bit for bit.** |
| 2 | `tests/check_goldens.sh` + negative control | **23** PASS; `SLANG_UHDM=/bin/false` → **0** PASS |
| 3 | uhdm2rtlil, both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in each mode; `ct8rows.sh` pristine-vs-patched = **0 differing rows** over 1 462 |
| 4 | Surelog suite, `--mode both` | `ct8rows.sh` vs the COMMITTED `results/golden_surelog.csv` = **0 differing rows** over 1 588, status AND dump column; same against the pristine sweep |
| 5 | `byteverify.sh SELFCHECK=1 SELFCHECK1=1` | **10 / 953** surelog + **2 / 1 358** u2r movers, ALL PREDICTED BY NAME first; controls 952/953 and 11 |

Two ops notes that belong in the record rather than in a footnote:

* The committed `results/golden_uhdm2rtlil.csv` disagrees with a fresh sweep on
  **2 rows** (`ParameterSizeOfInstance`, `paramod_genscope_child`, dump column
  `differ` → `match`, both modes). Those 2 rows differ **on the PRISTINE binary
  too**, so the committed baseline is stale for them at `e2f318c` and this pass
  did not cause it. `results/*.csv` is READ-ONLY here and nothing was promoted.
* `allsweeps8.sh` grew an **empty-workdir guard** after it bit: the binary check
  is a `grep -v` over the workdir's `cmds.txt` files, an empty workdir makes it
  find nothing, and it printed "VERIFIED" for a sweep that had died with
  `missing tool`. A guard that passes on nothing is worse than no guard.
  `bndarms8.sh` grew the same class of fix: its first version ran the two
  binaries in two different CWDs and reported **100 % movers with heads 0/0 on
  both sides**, because a UHDM database records the source file's absolute path.

## 9. THE 12 MOVERS, predicted then attributed

`predict8.sh` reads the law's cell straight out of each PRISTINE database and
names the candidates. Run on the u2r tree first as a control it named 2 over
1 358 and the byte verifier then found exactly those 2. On the surelog tree it
named 10 over 953 and the byte verifier found exactly those 10 — zero
unpredicted, zero missed.

| test | mode | net dump lines | verdicts (`attrib8.sh`) |
|---|---|---|---|
| BuildUVMPkg | default, testflags | +21 (3 stamps) | CONVERTED 3 |
| Scoreboard | default | +49 (7) | CONVERTED 7 |
| SimpleUVM | default, testflags | +49 (7) | CONVERTED 7 |
| SeqDriver | default, testflags | +98 (14: 7 in `uvm_pkg`, 7 in the `adpcm_pkg` clone) | CONVERTED 7, RESIDUE 2 (R3) |
| Earlgrey_0_1 | default | **0** | REPOINTED 2 (`prim_cipher_pkg::aes_mul2`) |
| EvalFunc | default, testflags | **0** | REPOINTED 1 (`prim_util_pkg::_clog2`), stays CMP_EQUAL |
| NestedCallsOfTheSameFunction (u2r) | default, testflags | **0** | REPOINTED 2 (`my_pkg::aes_mul2`), stays CMP_EQUAL, dump stays golden-IDENTICAL |

`CONVERTED` = golden TS, pristine bare, patched TS, and the actual's ROLE (which
task_func's io_decl owns it, at which formal position) matches golden's.
`REPOINTED` = all three stamped, our actual's role CORRECTED from the def
listing's io_decl to the elab one — **invisible to any dump** (both copies print
the same `file:line`) and the reason `§ pkgRetTopArgTsElabTwin8` needed its own
name. **No mover carries an `EXTRA` verdict.** Earlgrey_0_1's whole
`uhdm-dump` output is **byte-identical** before and after, which is also the
strongest available statement that earl53's `§ connPathRootTs53` family did not
move; SeqDriver's 38 deleted dump lines are a pure BLOCK MOVE (every deleted
line reappears among the added ones; net `+98`, nothing lost).

**The FIVE-ROW WALL holds, byte-for-byte.** Four of the five rows' databases
move, so the wall was re-measured the only way that means anything — a BYTE
comparison of the cmp LOGS themselves:

```
SimpleUVM  default   1405511 lines   BYTE-IDENTICAL
SimpleUVM  testflags 1405511 lines   BYTE-IDENTICAL
SeqDriver  default   1450011 lines   BYTE-IDENTICAL
SeqDriver  testflags 1450011 lines   BYTE-IDENTICAL
Scoreboard default   1399779 lines   BYTE-IDENTICAL
Earlgrey_0_1 default      34 lines   BYTE-IDENTICAL
EvalFunc   default/testflags 0 lines BYTE-IDENTICAL (CMP_EQUAL both)
```

Head counts, pristine → patched, for every mover: BuildUVMPkg 1 → 1 (object
advanced, §7); SimpleUVM 1 → 1, SeqDriver 1 → 1, Scoreboard 1 → 1,
Earlgrey_0_1 1 → 1 with identical cmp line counts (their heads are earlier in
the walk than this family); EvalFunc 0 → 0.

## 10. THE BOUNDARY GATE

`bndarms8.sh` compiles **every arm source of every adjacent pass** with BOTH
binaries in the SAME directory and byte-compares:

```
r10earl53repro  7 arms   IDENTICAL
r10buvm7repro  17 arms   IDENTICAL
r10uvm77..82   56 arms   IDENTICAL
r10buvm3..6    19 arms   IDENTICAL   (a3_overfire, a1_namedargs, a2_kindgrid included)
-- arms IDENTICAL=75+24 MOVED=0 REJECT-BOTH=0
```

99 arms, byte-identical.

The canary battery, all pristine-vs-patched:

* `canaries.sh` — surelog `ok=52 changed=0 absent=0`, u2r `ok=16 changed=0`.
* `ctcan2.sh` (the SUPPLEMENTARY list `canaries.sh` cannot see) — surelog
  `ok=58 changed=0` with `EXPECT_UNKNOWN=1`, u2r `ok=2 changed=0` with
  `EXPECT_UNKNOWN=6`, both PASS.
* `canaudit.sh canaries.sh ctcan2.sh` — `audited=29 UNCOVERED=0
  FENCE-BREACH=0`, and its two self-tests fire, so "every brief-protected name
  is checked" is a RUN and not a sentence. The four slang-fenced names are
  dispatched by no driver here.
* the pinned md5s hold: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
  InterfaceModPort `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`,
  YosysOldOr `d68e0796d62c` — every one identical to pristine in both modes.

Determinism (`detcheck.sh`, 3 runs each on `v1_argts8.sv` and
`a1_earl53.sv`): **1 distinct hash, 0 NO_OUTPUT**.

## 11. FILES

| file | what |
|---|---|
| `r10buvm8cen.cpp`, `build8.sh` | the census instrument: every `tf_call` argument out of `Serializer::AllObjects()` with its typespec, its actual's identity, its ancestor chain and its CELL (view / reach / owner / boundness); plus every `task_func`'s `io_decls` so "shared vs cloned" is measured |
| `gcensus8.sh` | the instrument over every golden cache entry (`.tmp*` skipped, per-file timeout, timeouts COUNTED) |
| `predict8.sh` | names the movers from the PRISTINE databases, before any byte comparison |
| `attrib8.sh` | the golden ↔ pristine ↔ patched join for ONE mover, with the four verdicts |
| `arm8.sh`, `grid8.sh` | one arm; the three-way grid table |
| `v1_argts8.sv`, `v2_argts8.sv`, `v3_argts8.sv` | the 118 grid cells |
| `bndarms8.sh` | the boundary gate over the adjacent passes' arms |
| `allsweeps8.sh`, `sweeps.sh`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `canaudit.sh`, `ctcan2.sh`, `rowheads.sh`, `detcheck.sh` | the gates |

### reproduce

```sh
./build8.sh
./gcensus8.sh /tmp/gcells.txt                        # the golden-vs-golden census
PRISTINE=<e2f318c bin> PATCHED=<patched bin> ./grid8.sh v1_argts8.sv
./allsweeps8.sh                                      # the four sweeps, one at a time, --jobs 2
./predict8.sh <pristine surelog workdir>             # predict FIRST
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh <patched wd> <pristine wd>
./attrib8.sh <patched wd> <pristine wd> default/BuildUVMPkg-*/slang.uhdm
PRISTINE=... PATCHED=... ./bndarms8.sh ../r10earl53repro ../r10buvm7repro
```

The ladder is `tools/probe/r10ladder1repro/ctladder.cpp`, built with the line in
that directory's README and run `<golden> <ours>`; `--calib` on this pass's
golden gives **0 rungs on 183 142 objects**.
