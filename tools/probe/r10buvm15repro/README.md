# r10buvm15 — § `retNameRecvCollapseArgsBindLikeBody15` — **the BuildUVMPkg head cleared again, and the collapsed-call family CLOSED corpus-wide (15 → 0)**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `07e10c5` |
| worktree | `/tmp/wt_r10buvm15` |
| pristine binary | md5 `3c8e1854c5bf883d0c654e04d0d01725` |
| patched binary | md5 `63c283b1f9e48c408bb7d9d6fa31f3b8` |
| production surface | `src/ExprEmit.cpp` ONLY — 2 code sites (a `ClassArgBind12` scope around each of the two § 69 argument loops) plus the header decode |
| probe surface | `tools/probe/r10buvm15repro/` only |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS`.  What it does is clear buvm14's residue R0 and close the whole
collapsed-call argument family across both corpora.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| BuildUVMPkg cmp lines, default / testflags | **29 / 29** | **31 / 31** (a DIFFERENT, deeper head) |
| head object | `io_decl(lhs)@23219:62 < function(…::get_link)`, `RHS <null>` | `LHS <null>` / `int_var(…get_packed_bytes::sz)` (**R0**) |
| collapsed-call census, surelog corpus, DISAGREE | **15** | **0** |
| the same, AGREE | 167 | **182** |
| whole-call census, DISAGREE | 284 | **269** (−15, exactly the family) |

Both modes' cmp logs are byte-identical to each other on both binaries
(`26e8f870afc4` pristine, `faea62de3d4b` patched), and the other **ten** cmp
logs of the seven-row head set are **byte-identical between the two binaries**.

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG — the brief's framing CONFIRMED

buvm14's README warned that buvm13's `RHS: <null>` framing had been carried
forward wrongly.  **This time the log really does say `<null>`**, and it was
read out of `/tmp/r10buvm15_heads_pris/BuildUVMPkg.default.cmp` before any code
was written, not taken from the brief:

```
LHS:
decompile:
io_decl: (lhs), id:125009, line:23219:62, endln:23219:65
|vpiParent:
\_function: (uvm_pkg::uvm_cause_effect_link::get_link), id:125004, line:23219:4, …
…
RHS: <null>
```

`BaseClass.h`'s SINGULAR `SafeCompare` has exactly one arm that prints this
shape:

```cpp
} else if ((lhs != nullptr) && (rhs == nullptr)) {
  context->m_failedLhs = lhs;      // the VALUE, not the owner
  return 1;
```

so the head is a **singular field whose golden value is an `io_decl` and whose
value on our side is null** — and the generated `ref_obj::Compare` has exactly
one such field, `SafeCompare(lhs->Actual_group(), rhs->Actual_group(), …)`,
compared after `VpiName`/`VpiDefName`/`VpiGeneric`.  (The VECTOR overload's
size-mismatch arm sets both sides to the OWNERS, which is what buvm14's head
was; this one is not that.)  The owner was then located by name in the two
databases: the argument `ref_obj(lhs)` under `func_call(get_link)` at
`uvm_pkg.sv:23233`, i.e. `get_link.set(lhs, rhs);` — a § `retNameRecvCollapse69`
COLLAPSED call.

## 2. THE LAW, AND WHY IT IS NOT A NEW GATE

Collapsing the call was only half the shape.  Both § 69 arms built the
`func_call` and then emitted the METHOD's arguments with **no
§ `classArgBind12` window open**, so every argument ref inside an IN-BODY class
method came out BARE.

**Decoded from the producer, not guessed.**  Surelog's `compileTfCall`
(`CompileHelper.cpp:4135`) resolves the dotted invocation by its FIRST
identifier, `getTaskFunc(name)` lands on the FUNCTION, and the argument list is
then compiled with the FUNC_CALL as `pexpr`:

```cpp
if (VectorOfany* arguments =
        compileTfCallArguments(component, fC, argListNode, compileDesign,
                               Reduce::No, call, nullptr, false)) {
```

`CompileHelper::bindVariable` (`CompileStmt.cpp:3089`) walks that `pexpr`'s
`VpiParent` chain and, on reaching `uhdmfunction` / `uhdmtask` / `uhdmbegin`,
matches `Variables()` then `Io_decls()` **by name**.  A collapsed call's
arguments therefore sit in **exactly the same bind window** as an ordinary
call's — the window this emitter already models as § `classArgBind12`.  Nothing
about the collapse is special, so the fix adds **no new gate**: it opens the
window that every other call-argument site already opens.

## 3. THE GRID, MEASURED ON PURPOSE-BUILT GOLDEN

`a1_collargs15.sv` (33 golden calls) and `a2_collbuiltin15.sv` (17) walk the
axes the brief named.  `grid15.sh` prints golden / pristine / patched per site.

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| c10 / c30 | collapsed, FORMAL args, depth 0, non-static **and** `static` | `io_decl` | bare | **`io_decl`** |
| c11 / c31 | collapsed, BODY LOCAL | `int_var` | bare | **`int_var`** |
| c40 | collapsed, UNNAMED-BLOCK local at the same ctrl depth (§ 57 / § 64) | `int_var` | bare | **`int_var`** |
| c14 | the argument is itself a CALL — the NESTED call's own argument | `io_decl` | bare | **`io_decl`** |
| c12 | collapsed, a CLASS PROPERTY | bare | bare | bare |
| c13 | collapsed, a PACKAGE variable (§ `pkgVarBindsOnlyThroughInstance88`) | bare | bare | bare |
| **c19 / c32** | **the SAME collapsed call inside an `if`-begin** | **bare** | bare | **bare** |
| c16 / c17 / c20 / c41 | the UNCOLLAPSED controls in the same bodies | bound / bare as before | = golden | = golden |
| c01 / c02 | a PACKAGE free function (`si=1`) | bound | bound | bound |
| c60 / c61 | an OUT-OF-BODY method (§ 69 gate (b): no collapse) | bound | bound | bound |
| d10-d21 | the same axes on the BUILT-IN arm (`<ret>.push_back(f)`) | as above | bare | **converted** |

`-- same=16 CONVERTED=7` on a1 and `-- same=9 CONVERTED=4` on a2:
**0 OVER-FIRE, 0 MOVED-STILL-WRONG on both.**

**c19 / c32 / d15 are the DISCRIMINATOR.**  A law written as "a collapsed call's
arguments always bind" over-fires there, and the corpus population that would
have caught it is real: `uvm_tr_database.svh:157` `open_stream.m_do_open(this,
scope, type_name);` and `uvm_tr_stream.svh:343`
`open_recorder.m_do_open(this, m_time, type_name);` — both nested inside
`if (…) begin`, both **BARE in golden**.  They stay bare because
§ `controlBodyNoBind28` is a separate disjunct the window does not lift for a
FORMAL: `blkLocalSameCtrlDepth57` admits only block/subroutine LOCALS
(`sym.kind == SymbolKind::Variable`), and a `FormalArgument` is refused at its
first test.

`a1`'s first cut also carried a cell that **tested nothing**: `qq15.push_back(qf)`
was written to exercise the BUILT-IN collapse arm, but its receiver is a class
PROPERTY, so the call never collapses and the cell read `same` for the wrong
reason.  `a2_collbuiltin15.sv` exists because that was caught — SITE 2 has four
CONVERTED cells of its own and would otherwise have shipped unmeasured.

## 4. THE CENSUS, AND THE MOVER PREDICTION MADE BEFORE THE SWEEP

`r10buvm15cen.cpp` reads a `.uhdm` out of `Serializer::AllObjects()` (never dump
TEXT) and prints one row per `tf_call` inside a subroutine body: the call's
`file|line:col`, kind, name, the enclosing subroutine's identity, whether it
carries a `vpiInstance`, and **every argument's kind, name and `Actual_group`**.
`cenall15.sh` runs it over every database in a `verify_golden` workdir on BOTH
sides; `cenjoin15.py` multiset-joins them.  The VIEW is deliberately not in the
key (buvm14's measured decision) and the file is inherited from the nearest
ancestor that has one (our expression nodes carry an empty `VpiFile`).

Corpus-wide over the **956** surelog databases and **731** u2r databases, the
collapsed-call family disagreed in **15 rows and nowhere else**, and the
prediction was written to `/tmp/r10buvm15_prediction.txt` **before** the patched
sweep ran:

| database | sites |
|---|---|
| `default`+`testflags` `BuildUVMPkg` | `uvm_pkg.sv` 23131:7 / 23233:7 / 23335:7 `get_link(lhs, rhs)` **and** 55541:5 `create_item(l_sequencer)` |
| `default`+`testflags` `MiniAmiq` / `SeqDriver` / `SimpleUVM` | `uvm_sequence_base.svh:946:5` `create_item(l_sequencer)` |
| `default` `Scoreboard` | the same (`testflags/Scoreboard` is `SLANG_REJECT`: no database) |

**u2r: ZERO predicted.**  All 18 of its collapsed-call rows already agreed, and
every one is an ordinary RECURSIVE call in a MODULE or PACKAGE function
(`si=1`), which never enters § `classMethodNoBind`'s silence.

`byteverify.sh` then reported **exactly those 9 databases and no others** out of
956, and **0 / 1358** on u2r.

**A NOTE ON `coll=1`.**  The census flag is a SUPERSET: it marks any `func_call`
whose callee is the enclosing function, which includes ordinary RECURSION
(`traverse`, `m_raise`, `accept`, `do_block`, `find_override_by_name`, `sync`).
That is deliberate — those rows are the census's own control, they already agree
on both sides, and they are emitted by the ordinary user-call path, which has
always opened the window.  Reading them as § 69 sites would have mis-attributed
the family; reading the SOURCE at each site is what separates them.

## 5. ATTRIBUTION — every mover named, to the LINE

`uhdm-dump` diff, pristine → patched, per mover:

| database | dump diff sides | content |
|---|---|---|
| `BuildUVMPkg` (both modes, byte-identical to each other) | **14** (+ the workdir path line) | 7 × `\|vpiActual: \_io_decl:` — `lhs`+`rhs` at the three `get_link` sites, `l_sequencer` at `create_item` |
| `MiniAmiq`, `SeqDriver`, `SimpleUVM` (both modes) | **2** each | `\|vpiActual: \_io_decl: (l_sequencer), line:940:71` |
| `default/Scoreboard` | 96 raw | **2** after `sort` — the other 94 sides are the KNOWN `vpiTaskFunc` ORDER COIN, and the SORTED dumps differ by exactly the same 2 predicted lines |

The Scoreboard row is the campaign's documented ~50/50 coin, attributed
ORDER-BLIND as the measurement laws require.

## 6. THE GATES

| gate | result |
|---|---|
| 1 build both, md5 | `3c8e1854c5bf883d0c654e04d0d01725` pristine / `63c283b1f9e48c408bb7d9d6fa31f3b8` patched.  The header decode in § 2-3 was added AFTER the first patched build and the REBUILD produced a **byte-identical binary**, so every number here is the shipped source's. |
| 2 goldens | patched **23 PASS / 0 FAIL**, pristine 23/0, and `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (the negative control) |
| 3 u2r, `--mode both` | **0 differing ROWS** vs the pristine baseline; 679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL` in **both** modes; dump column unmoved |
| 4 surelog, `--mode both` | **0 differing ROWS** vs the COMMITTED `results/golden_surelog.csv`, over all **1588** rows, status AND dump.  **No row converted.** |
| 5 byteverify | 9 / 956 surelog, **all 9 predicted BY NAME first**; 0 / 1358 u2r; `SELFCHECK` 955/956, `SELFCHECK1` **exactly 1** on the 0-mover tree |
| canaries | `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0`; `canaries.sh` `ok=52 changed=0` (surelog) and `ok=16 changed=0` (u2r); `ctcan2.sh` `ok=58 changed=0` / `ok=2 changed=0`.  `SVSwitch` `4842211c4030` and `YosysVerx` `6ccda350c24a` hit exactly; `InterfaceModPort`/`BlackParrotComplex`/`YosysOldOr` byte-identical. |
| determinism | `detcheck.sh` 3 runs on the BuildUVMPkg input: **1 distinct hash** |

**A PRE-EXISTING BASELINE DRIFT, REPORTED NOT HIDDEN.**  On the PRISTINE binary
at BASE `07e10c5`, `results/golden_uhdm2rtlil.csv` already disagrees with a
fresh sweep on two names — `ParameterSizeOfInstance` and
`paramod_genscope_child`, both modes, dump column `differ` → `match` — plus the
`detail` column's absolute-vs-relative path spelling on the `SLANG_REJECT` rows.
That drift is **not this pass's**; gate 3 is therefore measured against the
pristine sweep taken first in this same worktree, and `results/*.csv` were not
touched.

## 7. R0 — THE NEW HEAD, DECODED, AND IT IS NOT A REGRESSION

```
LHS: <null>
RHS: int_var: (uvm_pkg::uvm_packer::get_packed_bytes::sz), id:42264, line:22227:8
```

Read against `BaseClass.h` this is the singular arm's MIRROR
(`lhs == nullptr && rhs != nullptr` → `m_failedRhs = rhs`), so **ours carries a
singular field golden leaves null**.  Located by name: `uvm_pkg.sv:22232`
`stream = new[sz];` inside the OUT-OF-BODY `function void
uvm_packer::get_packed_bytes(ref byte unsigned stream[])`.  The dynamic-array
`new[…]` size argument is emitted by us as

```
\_ref_obj: (sz), line:22232:17
  |vpiParent: \_method_func_call: (new), line:22232:13
  |vpiName:sz
  |vpiActual: \_int_var: (…get_packed_bytes::sz)
```

and golden's carries **no `vpiActual` at all** — the only `sz` reference in that
body golden leaves bare (`22229:4` and `22234:16` are bound on both sides and
agree).  Ours mentions the `int_var` 12 times to golden's 10; the two extra
mentions are exactly this argument's actual, in the DEF and ELAB copies.

**It is not a regression.**  The pristine dump carries the identical 12 mentions
and the identical `|vpiActual:` under `method_func_call: (new)`; the pristine →
patched dump diff for `BuildUVMPkg` is **14 lines, all of them `io_decl`
actuals**.  R0 was simply MASKED by the head this pass cleared.

## 8. RESIDUES THIS PASS MEASURED AND DID NOT TOUCH

* **§ `deepRecvCall11`'s corpus population is not zero.**  buvm-era notes call a
  chained receiver whose first segment is the return name (`n_chain.inner.touch(n)`)
  a zero-population residue.  The census finds **8 rows** of it in `MiniAmiq`:
  `svaunit_immediate_assertion_details.svh` 155/159/163 `copy` and
  `svaunit_immediate_assertion_info.svh:230` `get_checks.checks_details.delete();`
  — golden emits an ARGUMENT-LESS `func_call` named for the return variable and
  we emit nothing there.
* **File attribution.**  26 `ARITY` keys and all 26 asymmetric keys in the
  collapsed-call join are one residue: golden attributes `uvm_object_value_str`
  to `uvm_misc.svh` where we attribute it to `uvm_pkg.sv` / `svaunit_pkg.sv` /
  `testbench.sv`.  None of them carries a bindable `ref_obj` argument, which is
  why none moved.

## 9. FILES

| file | what it is |
|---|---|
| `r10buvm15cen.cpp` / `build15.sh` | the CALL/argument-bind census instrument |
| `cenall15.sh` / `cenjoin15.py` | corpus-wide census + multiset join |
| `a1_collargs15.sv` / `a2_collbuiltin15.sv` / `grid15.sh` | the arms and the three-way cell table |
| `sweeps15.sh` / `ct15rows.sh` | the sweep driver and the whole-row gate |
| `byteverify.sh` / `rowheads.sh` / `detcheck.sh` | mover attribution, head measurement, determinism |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary battery and its audit |
