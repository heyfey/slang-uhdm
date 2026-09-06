# r10uvm170 — § `dpiExportedPkgSubBareOwnTdUnsupported170` — **AN `export "DPI-C"` WRITTEN ABOVE A PACKAGE SUBROUTINE COMPILES ITS BODY ONE COLLECT-PASS EARLY** — the MiniAmiq ×2 and BuildUVMPkg ×2 106-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `143df9df` |
| pristine binary | md5 `9793b8253cc81350201a215044061a4f`, built from this pass's OWN worktree at a clean `143df9df` and frozen `chmod 555` before any sweep — **byte-identical to the master's own pristine at that commit** |
| patched binary | md5 `a66b73e36dedd997fb0e7bdc649b2711`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` (the gate, in the `CastExpression` arm of the `Conversion` case), `src/TaskFuncEmit.cpp` (the detector `dpiExportPrecedesDef170` + the one flag assignment), `include/UhdmExporter.h` (the flag, the memo and the decoded law) |
| probe surface | `tools/probe/r10uvm170repro/` only |
| docs | `RESUME.md` §3b — the MiniAmiq and BuildUVMPkg rows, refreshed with the heads this landing produced (they ride with the code, per the standing direction) |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **MiniAmiq default and testflags, 106 cmp lines, ONE head each → 40**; **BuildUVMPkg default and testflags, 106 → 52**. In both families the two modes' logs are BYTE-IDENTICAL before and after. A cmp line count is the HEAD OBJECT'S decompile size (RESUME.md §7). |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **9 / 956** surelog — **all nine PREDICTED BY NAME before the patched sweep ran**, from the 956 PRISTINE databases and their goldens alone (`predict170.py`, §5). **0 / 1358** uhdm2rtlil. |
| the corpus population | ONE construct, `uvm_severity'(severity)` at `uvm_globals.svh:168:15` (uvm-1.2) = `uvm_pkg.sv:9584:15` (1800.2 `pp_output`), inside `uvm_pkg`'s `export "DPI-C" function m__uvm_report_dpi;`. **26 package-copy cells over the nine UVM row-modes: agreeing with golden 4 → 22.** |
| the census (nine UVM DBs × both modes) | 326 cast-target cells: **DEGRADE-TOWARD 5, MUST-STAY-AWAY 0, MOVED-WRONG 4, untouched 317** (the 4 are the SeqDriver/SimpleUVM copy split, R1 below). |
| the grid (5 arms, both views) | 155 cast sites. On the field the law owns (the target typespec's kind+name): **TOWARD 10, AWAY 0, MOVED-WRONG 0**. On the COPY-COUNT projection, which the law must not touch: **TOWARD 0, AWAY 0, MOVED-WRONG 0**. Arm D (no `export "DPI"` anywhere, every spelling and site) moved **nothing at all**. |
| the FLOOR (every committed arm of uvm157, §83, §88, uvm151, uvm168 and 4700 more) | **byte-identical under both binaries** — they are not among the wide boundary's 8 moved arms. |
| the WIDE boundary (4768 arms, both views) | `LISTED=4768 PROCESSED=4768 PRODUCED_DBS=4611`, **RC_DIFFS 0, MOVED_ARMS 8**: **4 are this pass's own arms** (the positive control), 2 are r10uvm154's already-decoded ADDRESS-DERIVED layout residue, and 2 are pure SERIALISATION ORDER — all four non-own arms attributed in §8. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

The master rotated its controls out from under this pass mid-run
(`/tmp/ctl_wd_sl_143df9df` became `/tmp/ctl_wd_sl_3d549e59`), which is exactly
why the standing rules demand an own pinned workdir. This pass built its own
pristine binary from a clean `143df9df` worktree, and it came out
**byte-identical to the master's frozen pristine** (`9793b825…`); its own
956-row surelog sweep reproduced the committed baseline **row for row**
(`ct8rows` 0 differing rows, status AND dump column).

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
MiniAmiq       default        106      1
MiniAmiq       testflags      106      1     (logs byte-identical, md5 9d30f6d6…)
BuildUVMPkg    default        106      1
BuildUVMPkg    testflags      106      1     (logs byte-identical, md5 bc812ae8…)
```

Both heads are the SAME object shape:

```
LHS: unsupported_typespec: (uvm_severity), line:168:15, endln:168:27   [9584:15 on BuildUVMPkg]
     |vpiName:uvm_severity
     |vpiInstance: \_package: uvm_pkg
RHS: enum_typespec: (uvm_pkg::uvm_severity), line:242:1, endln:248:16  [8049:1 on BuildUVMPkg]
     |vpiName:uvm_pkg::uvm_severity  |vpiBaseTypespec -> bit_typespec
     |vpiEnumConst: UVM_INFO/UVM_WARNING/UVM_ERROR/UVM_FATAL
```

Golden's object carries **no `file:` field**; `typespec::Compare` reads neither
the file nor the span, so the compared fields are the **UhdmType** (which fails
first, inside `BaseClass::Compare`'s `VpiType` line) and then `VpiName`,
`Typedef_alias`, `Instance`.

## 2. DECODING THE JUDGE FIRST — `ct170own`, ON BOTH HEADS

`ct170own.cpp` links the SAME generated `Compare` the judge does. It prints the
owner chain of each side, the REFERRER INDEX (every object+FIELD that points at
that side, using the committed `r10ladder1repro/ctfields.inc` field order), and
then ABLATES by seeding the golden head into a fresh `CompareContext`'s
`m_visited` — the LHS-keyed early-out every generated `Compare` opens with —
and re-running the OFFICIAL `design::Compare`.

**One gate covers both heads, and the owner-finder is what proves it.** The
golden head is PARENTLESS on both rows; its ONE referrer is a `ref_typespec`
whose owner chain is identical in shape:

```
MiniAmiq    REF .Actual_typespec  ref_typespec#808
              < operation()@uvm_globals.svh:168:15-168:38          (the vpiCastOp)
              < func_call(uvm_report)@uvm_globals.svh:168:4-168:79
              < function(m__uvm_report_dpi)@uvm_globals.svh:161:1-161:43
              < package(uvm_pkg)  < design
BuildUVMPkg REF .Actual_typespec  ref_typespec#481
              < operation()@uvm_pkg.sv:9584:15-9584:38             (the vpiCastOp)
              < func_call(uvm_report)@uvm_pkg.sv:9584:4-9584:79
              < function(m__uvm_report_dpi)@uvm_pkg.sv:9577:1-9577:43
              < package(uvm_pkg)  < design
```

Same construct, same edge: the **cast target of `uvm_severity'(severity)`**,
the sole statement of `m__uvm_report_dpi`. The two spans differ only because
one corpus reads the uvm-1.2 include tree and the other the 1800.2 `pp_output`.

Note the `function`'s own span: `161:1-161:43` / `9577:1-9577:43` is the span of
the **`export "DPI-C" function m__uvm_report_dpi;` line**, not of the definition
below it. That is the first fingerprint of the mechanism §3 decodes: the
`UHDM::function` object the body was written into was minted by
`compileFunctionPrototype` from the EXPORT node.

The ablation moves the judge off the family completely, on both rows, and
`--maskall` (every golden `unsupported_typespec` masked at once — 2556 on
MiniAmiq, 1108 on BuildUVMPkg) lands on the SAME next head, which proves this
one object is the whole head and no other placeholder is behind it:

```
MiniAmiq     mask-head → func_call(copy)@svaunit_immediate_assertion_details.svh:155:10
             maskall   → the same object
BuildUVMPkg  mask-head → enum_var()@uvm_pkg.sv:19055:27
             maskall   → the same object
```

Both predictions were then confirmed by the OFFICIAL judge on the patched
databases (§9).

## 3. DECODING SURELOG — THE BAIL MATRIX

### 3.1 The mechanism

`CompilePackage::compile` walks the package's item list **three times**
(`~/git-repos/Surelog/src/DesignCompile/CompilePackage.cpp:105-108`):

```
collectObjects_(CollectType::FUNCTION);     // imports, DPI items, functions/tasks
collectObjects_(CollectType::DEFINITION);   // TYPEDEFS, parameters, functions/tasks again
collectObjects_(CollectType::OTHER);        // classes, …
```

`paFunction_declaration` / `paTask_declaration` run in the FIRST TWO — the
source itself says so (`:207-217`, *"Called twice, placeholder first, then
definition"*) — and `CompileHelper::compileFunction`
(`CompileStmt.cpp:2352-2367`) is what makes that work:

```cpp
UHDM::function* func = nullptr;
for (auto f : *component->getTask_funcs()) if (f->VpiName() == name) { func = …; break; }
if (func == nullptr) {                 // FIRST visit: placeholder, and RETURN
    func = s.MakeFunction(); func->VpiName(name); task_funcs->push_back(func); return true;
}
if (func->Io_decls() || func->Variables() || func->Stmt()) return true;
…                                      // SECOND visit: header AND BODY
```

So an ordinary package function's body is compiled in the **DEFINITION** pass —
after the package's typedefs have been collected.

`paDpi_import_export` runs in the **FUNCTION** pass (`:288-306`), and
`CompileHelper::compileFunctionPrototype` (`CompileStmt.cpp:2625-2640`)
**pushes a NAMED `UHDM::function` into that very same `getTask_funcs()`
vector**. When the export is written ABOVE the definition, the definition's
FIRST visit therefore finds a function of that name, skips the placeholder
return, and **compiles the whole body in the FUNCTION pass** — before a single
typedef of that package exists in `component`'s `m_dataTypes`.

A bare type name in that body then reaches
`CompileHelper::compileDatastructureTypespec`
(`CompileType.cpp:717-1062`, entered from the `slStringConst` arm at `:1922`),
misses `component->getDataType(typeName)` at `:725`, misses every class /
parameter / port fallback, and falls out of the tail at `:1053-1062` as

```cpp
unsupported_typespec* tps = s.MakeUnsupported_typespec();
tps->VpiName(typeName);                       // the WRITTEN spelling
fC->populateCoreMembers(type, type, tps);     // the type NAME token's span
```

### 3.2 The matrix, measured on real Surelog goldens

Every cell below is a golden built by `~/git-repos/Surelog/build/bin/surelog`
on this directory's arms (`grid170.sh` records every rc).

| axis | cell | golden |
|---|---|---|
| **order** | `export` ABOVE the definition | **unsupported** (`g170_c_home.sv` f01) |
| | `export` BELOW the definition | resolves (g01) |
| | a different name exported | resolves (h02) |
| **spelling** | bare `ea_t`, declared in THIS package | **unsupported** (`a_spell` a01) |
| | `pa170::ea_t` | resolves (a04) |
| | bare, WILDCARD-imported `fa_t` | resolves (a05) |
| | bare, EXPLICITLY imported `fb_t` | resolves (a06) |
| | `fa170::fa_t` (foreign, scoped) | resolves (a07) |
| | a type KEYWORD (`byte'`) / a size cast (`4'`) | resolves (a09/a10) |
| **type kind** | `typedef enum …` | **unsupported** (`e_kinds` x01) |
| | `typedef struct packed …` | **unsupported** (x02) |
| | `typedef union packed …` | **unsupported** (x03) |
| | `typedef logic [7:0]` / `bit [7:0]` / `int` / `byte` | resolves (x04-x07) |
| | `typedef t_enum t_alias_enum;` (typedef OF a typedef) | **resolves** (x08) |
| | `typedef t_struct t_alias_struct;` | **resolves** (x09) |
| | `typedef logic [3:0][7:0]` | resolves (x11) |
| **site** | cast target | **unsupported** (`b_site` c06/c07/c08/c11) |
| | subroutine local / block local / formal / return type | **unsupported** in golden, and this law does NOT own them — R2 |
| | package variable, class property, in-body class method | resolves (e01-e03) |
| **home** | same package | **unsupported** |
| | foreign package (scoped or imported) | resolves |
| | `$unit` | not reachable from a package (slang and the LRM reject it); the module cells i03/j03 resolve |
| **scope** | PACKAGE subroutine | **unsupported** |
| | MODULE subroutine (`mod_c170.fmod_c`) | resolves (i01) |
| | INTERFACE subroutine (`if_c170.fif_c`) | resolves (k01) |
| | class method inside the package | resolves (h03) |

The **type-kind** row is the one that fenced the law and it was NOT predicted:
inside the very same exported body a `typedef logic [7:0] t_vecl;` resolves and
`typedef t_enum t_alias_enum;` resolves even though its canonical type IS an
enum. The two answers part company in `compileDatastructureTypespec`'s
`while (dt)` loop (`CompileType.cpp:850-900`), which `break`s on
`en->getTypespec()` / `st->getTypespec()` / `un->getTypespec()` — null at
FUNCTION-pass time — while a `TypeDef` whose own `getTypespec()` is already set
returns it and a `SimpleType` reaches its own arm. The first cut of this law
read the CANONICAL type and produced a MOVED-WRONG on `t_vecl` and an AWAY on
`lb_t`; the fence now reads the **written target of the typedef declaration**,
and both went to zero.

### 3.3 The `vpiInstance` rule, extending §83 / §88

Golden stamps **`vpiInstance` = a `package uvm_pkg` object** on every one of the
four MiniAmiq placeholders, including the two that live in `svaunit_pkg`'s
wildcard-import clone — the same "the placeholder carries the stamp the
resolved typespec would" shape § `scopedTdUnsupTsHomePkgInstance83` decoded, and
the same home-package-instance link § `pkgVarBindsOnlyThroughInstance88` reads
through. This law stamps `pkgScopeInst` (falling back to
`homePkgInstOf(*expr.type)`), which is the pointer the sibling size-cast rule
twelve lines below already uses, so the two cannot drift.

**The judge cannot see WHICH `uvm_pkg` object it is, and that is proved rather
than assumed.** `SafeCompare(golden_inst, our_inst, ctx)` calls
`package::Compare`, whose first line is `m_visited.insert(this)` keyed on the
**LHS** — golden's package, which is already in the visited set because the walk
is *inside* it. Only a NULL on our side could fail. Measured: after the patch
the judge steps clean off the family on both rows (§9), and `--chain=10` on the
patched MiniAmiq database shows no Instance-shaped head in the next six rungs.
The exact-copy table is recorded as R3.

## 4. DECODING SLANG — THE RESOLUTION SITE AND THE GATE

`ConversionExpression`'s `CastExpression` arm (`src/ExprEmit.cpp`) already had
this exact object for a different reason: the DEF-view generate-block rule mints
`unsupported_typespec` named by `rawText(cesyn.left->sourceRange())`. This law
is a second disjunct on that same `if`, so ONE object shape serves both.

The detector is `UhdmExporter::dpiExportPrecedesDef170`
(`src/TaskFuncEmit.cpp`). It reads the **item index inside the package
declaration's own member list**, not a `SourceLocation`: Surelog's bail is
produced by the ORDER of `collectObjects_`'s single walk over that same list,
and a raw `SourceLocation` compare across macro / include buffers is not a
stable order (RESUME.md §9, "Emitter nondeterminism"). The per-package index
maps are memoised in `dpiExpOrder170`.

The flag `dpiExportPkgHome170` is set beside `inBodyClassMethod88`, from the
SUBROUTINE's own declaring scope — **not** from the package being emitted — so a
wildcard-import CLONE re-emitted into another package keeps the same answer.
That is required, not cosmetic: golden degrades `svaunit_pkg`'s and
`adpcm_pkg`'s clone copies too.

The gate then fires only when the cast target is
* a bare `IdentifierName`,
* whose `expr.type` is a `TypeAlias`
* whose `getParentScope()` IS that DPI home package, and
* whose TypedefDeclaration's written target is `EnumType` / `StructType` /
  `UnionType`.

Nothing else in the file changed; `defGenProcessEmit`'s answer is untouched
(arm D and the 4700-arm boundary prove it).

## 5. THE A-PRIORI PREDICTION — MADE FIRST, FROM PRISTINE DATABASES ONLY

`predict170.py` never opens the patched binary or its databases. It walks all
**956** rows of the pristine sweep, reads each row's OWN `cmds.txt` for the
golden cache path, and names every cast site where golden holds an
`unsupported_typespec` with an UNSCOPED name and we hold something else, gated
to the pristine object kinds this law can convert (`enum_/struct_/union_
typespec`). It asserts a nonzero comparable-row count, because a predictor that
reaches nothing must never read as "no movers".

```
comparable rows=956   predicted moving rows=9   cells=9   EXCLUDED candidate cells=39
  MOVER default/BuildUVMPkg   default/MiniAmiq   default/Scoreboard
        default/SeqDriver     default/SimpleUVM
        testflags/BuildUVMPkg testflags/MiniAmiq testflags/SeqDriver testflags/SimpleUVM
```

The byte gate returned **exactly those nine and nothing else** (9 / 956;
0 / 1358 on uhdm2rtlil). The 39 EXCLUDED cells are Earlgrey's and Rggen's
size-cast-by-a-parameter-name family (`AttrDw`, `NWD`, `N_ESC_SEV`,
`wkup_mode_e`) — a DIFFERENT family this law must not touch, and the byte gate
proves it did not: Earlgrey's databases are byte-identical under both binaries
and its heads are unchanged at 31 / 26.

## 6. THE CORPUS CENSUS — NINE UVM DBs × BOTH MODES, BOTH COLUMNS

`cenrun170.sh` + `join170.py`, keyed on the LINE:COL span with the FILE
STRIPPED (our objects carry an empty `vpiFile`, Surelog's carry the path — a
key that includes the file joins nothing), value = the MULTISET of
(UhdmType, VpiName) at that span:

```
rows=9  cells=326
  DEGRADE-TOWARD   5     (golden unsupported, pristine resolved, patched == golden)
  TOWARD-OTHER     0
  MUST-STAY-AWAY   0     <-- the reverse column: NOT ONE golden-RESOLVED site went unsupported
  MOVED-WRONG      4     (the SeqDriver/SimpleUVM copy split — R1)
  untouched      317
```

`copies170.sh` joins each cast row's owner-package `UhdmId` against the
database's own `AllPackages` / `TopPackages` listing, which is the only way to
say WHICH COPY agreed (a corpus database holds both views in one file):

| row-mode(s) | package copies | golden `unsupported` | ours BEFORE | ours AFTER |
|---|---|---|---|---|
| BuildUVMPkg ×2 | uvm_pkg ALL + TOP | 2 / 2 | 0 / 2 | **2 / 2** |
| MiniAmiq ×2 | uvm_pkg ALL+TOP, svaunit_pkg ALL+TOP | 4 / 4 | 0 / 4 | **4 / 4** |
| Scoreboard / default | uvm_pkg ALL + TOP | 2 / 2 | 0 / 2 | **2 / 2** |
| SeqDriver ×2 | uvm_pkg ALL+TOP, adpcm_pkg ALL+TOP | 3 / 4 (TOP uvm_pkg RESOLVES) | 1 / 4 | **3 / 4** |
| SimpleUVM ×2 | uvm_pkg ALL + TOP | 1 / 2 (TOP uvm_pkg RESOLVES) | 1 / 2 | **1 / 2** |
| **total** | **26** | **22** | **4** | **22** |

The reverse (must-stay) column corpus-wide is stronger than a census: the byte
gate proves **947 of 956 surelog databases and all 1358 uhdm2rtlil databases
are byte-identical** under the two binaries, so no cast cell in any of them can
have moved at all.

## 7. THE GRID — 5 ARMS, BOTH VIEWS, ONE REAL SURELOG GOLDEN EACH

`grid170.sh` builds one Surelog golden and both frozen binaries' databases in
both views and records every rc; `score170.py` scores three projections per cast
site (the `set` of (kind,name) — the field this law owns; the COPY COUNT, which
it must not touch; and the exact multiset).

| arm | axis | sites | set: TOWARD / AWAY / MOVED-WRONG | cnt: TOWARD / AWAY / MOVED-WRONG |
|---|---|---|---|---|
| `g170_a_spell.sv` | spellings × the corpus site, with a non-exported twin per cell | 40 | **2 / 0 / 0** | 0 / 0 / 0 |
| `g170_b_site.sv` | sites inside an exported function AND task, with twins | 16 | **3 / 0 / 0** | 0 / 0 / 0 |
| `g170_c_home.sv` | export ABOVE vs BELOW, homes, package / module / interface / class | 28 | **2 / 0 / 0** | 0 / 0 / 0 |
| `g170_e_kinds.sv` | the TYPE-KIND axis (enum/struct/union/vector/builtin/alias-of-alias) | 44 | **3 / 0 / 0** | 0 / 0 / 0 |
| `g170_d_notmove.sv` | **NEGATIVE CONTROL** — no `export "DPI"` anywhere, every spelling and site | 27 | **0 / 0 / 0** | 0 / 0 / 0 |

Arm D also did not appear in the wide boundary's moved list — it is byte-
identical under both binaries in both views.

Two arm-construction facts worth keeping, both of which cost a re-cut:
* an ENUM is not a valid DPI return or argument type and slang rejects it, so
  arm B's return/formal cells are written with a same-package 1-bit alias
  (`typedef bit lb_t;` — a packed vector is not a valid DPI **return** either)
  and a packed alias for the arguments;
* a `$unit` typedef **cannot be referenced from inside a package** (slang and
  the LRM), so the `$unit` home cells live in the module scope of arm C.

## 8. THE WIDE BOUNDARY — 4768 ARMS, BOTH VIEWS

Run from a COPY of the whole `tools/probe` tree so no path filter can hide an
arm; subdirectory arms included; the file list read on fd 3, children
`</dev/null`, `PROCESSED` asserted against `LISTED`, scratch keyed on the
RELATIVE path.

```
LISTED=4768  PROCESSED=4768  PRODUCED_DBS=4611  MOVED_ARMS=8  RC_DIFFS=0
```

| moved arm | verdict |
|---|---|
| `r10uvm170repro/g170_a_spell.sv`, `_b_site.sv`, `_c_home.sv`, `_e_kinds.sv` | **this pass's own arms — the POSITIVE CONTROL** (a gate that reported zero over them could not see). Scored against real goldens in §7: 10 TOWARD, 0 AWAY, 0 MOVED-WRONG. |
| `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv` | **R-addrbound**, r10uvm154's already-decoded ADDRESS-DERIVED residue, re-confirmed here to the digit: the class-scoped `typedef <T> name[string]` range bound reads `22556409` under the pristine binary and `22564601` under the patched one, against a **9 000-byte binary growth** (22 357 608 → 22 366 608). uvm168 measured the same constant at `22548185 → 22556409` across its own 8 992-byte growth — this pass's PRISTINE value is uvm168's PATCHED value, which is the signature of a binary-image-driven number and not of any law. |
| `r10uvm36repro/t48a/dut.sv` | **SERIALISATION ONLY**: same file size, **8 bytes** differ (two value swaps and one count), the `uhdm-dump` output is **BYTE-IDENTICAL**, and `uhdm-cmp` between the two databases reports **0 lines / 0 heads**. The arm contains no `export "DPI"`, so the law's flag is null throughout it. |
| `r10v123repro/v123_c_kinds.sv` | **ORDER ONLY**: 74 dump lines move, but the SORTED dumps are byte-identical (md5 `6baef723a962` on both) — the same typespec objects listed in a different order — and `uhdm-cmp` between the two databases reports **0 lines / 0 heads**. No `export "DPI"` in the arm. |

Every committed arm of the passes the brief names as the must-stay floor —
uvm157, § `scopedTdUnsupTsHomePkgInstance83`, § `pkgVarBindsOnlyThroughInstance88`,
uvm151, uvm168 — is byte-identical under both binaries in both views: **TOWARD 0,
AWAY 0, MOVED-WRONG 0**, because none of them is in the moved list at all.

## 9. THE GATES, IN ONE LINE EACH

* Build: pristine `9793b8253cc81350201a215044061a4f` (byte-identical to the
  master's own frozen pristine at `143df9df`), patched
  `a66b73e36dedd997fb0e7bdc649b2711`. **The patch applied to a FRESH
  `143df9df` worktree and rebuilt there produces the BYTE-IDENTICAL binary,
  same md5** — the patch IS the artifact every number here was measured on —
  and its 23/23 goldens were re-run from that worktree too.
* Goldens: **23 PASS / 0 FAIL** patched, **23 / 0** pristine,
  **0 PASS / 23 FAIL** with `SLANG_UHDM=/bin/false` (the negative control),
  `SLANG_UHDM` exported explicitly to each binary.
* uhdm2rtlil: **679 / 50 / 2** both modes both binaries; `ct8rows` **0 differing
  rows** against the committed `results/gate_uhdm2rtlil.csv` AND against this
  pass's own pristine sweep, in BOTH modes, status AND dump column;
  `byteverify SELFCHECK=1` **0 movers / 1358**, `PATH_SETS_IDENTICAL`.
* surelog: default `471 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 283
  SLANG_REJECT / 25 SURELOG_FAIL`, testflags `466 / 9 / 5 / 3 NO_DATABASE /
  1 NO_UHDM / 284 / 23 / 1 TIMEOUT / 2 UNTRANSLATABLE` — **identical to this
  pass's own pristine sweep cell for cell**; `ct8rows` **0 differing rows over
  1588**, **NO ROW CONVERTED**.
* Bytes: **9 movers / 956**, exactly the nine `predict170.py` named from
  pristine databases before the patched binary existed; `SELFCHECK` 955/956.
* Attribution (`attrib170.sh`, workdir-normalised, id-stripped, ORDER-BLIND):
  every one of the nine rows' sorted dump diff contains **only** this law's own
  lines — `\_enum_typespec: (uvm_pkg::uvm_severity)` out,
  `\_unsupported_typespec: (uvm_severity), line:168:15` +
  `|vpiName:uvm_severity` + `|vpiInstance:` + its package in. **Scoreboard/
  default is the known ~50/50 COIN and contributed 0 extra order-blind lines
  this run.**
* Canaries: `canaries.sh` **ok=52 changed=0** (surelog) and **ok=8 changed=0**
  (u2r); `ctcan2.sh` PASS with `EXPECT_UNKNOWN=1` and `=6`; `canaudit.sh`
  **29 audited, 0 UNCOVERED, 0 FENCE-BREACH**.
* Byte pins: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
  InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical to the
  pristine sweep, in both modes.
* Heads after (`rowheads.sh`): MiniAmiq **40 / 40**, BuildUVMPkg **52 / 52**
  (each family's two modes byte-identical); SeqDriver **50 / 50**, SimpleUVM
  **17 / 17**, Scoreboard/default **95**, Earlgrey **31 / 26**, Rggen/default
  CMP_EQUAL — all unchanged, and their head LOGS differ from pristine only in
  `id:` numbers, which shift because the law mints one extra object per site.

## 10. R0 — THE NEXT HEADS ON THE TWO ROWS

**MiniAmiq default and testflags, 40 cmp lines, ONE head each, the two logs
BYTE-IDENTICAL** (md5 `51bb4610415f…`):

```
svaunit_immediate_assertion_details.svh:155  copy.tests_names.push_back(tests_names[index]);
LHS golden  func_call (copy)              @155:10-155:56   |vpiFunction -> function(copy)@149:4
RHS ours    method_func_call (tests_names)@155:15-155:26
site: svaunit_pkg::svaunit_immediate_assertion_details::copy, inside a foreach body
```
Golden models the whole statement expression as ONE `func_call` named for the
object handle; we build the method-call chain. A different `UhdmType`, so
`BaseClass::Compare`'s `VpiType` line fails first.

**BuildUVMPkg default and testflags, 52 cmp lines, ONE head each, the two logs
BYTE-IDENTICAL** (md5 `ddc90caa664d…`):

```
uvm_pkg.sv:19055  extern virtual function uvm_policy::recursion_state_e object_printed(…);
uvm_pkg.sv:20364  function uvm_policy::recursion_state_e uvm_printer::object_printed(…);
LHS golden  enum_var  (uvm_pkg::uvm_printer::object_printed) @19055:27-19055:56
            |vpiTypespec -> ref_typespec -> enum_typespec(recursion_state_e)@18219:1
RHS ours    class_var ()                                     @20364:10-20364:39
```
The RETURN VARIABLE of an EXTERN class method whose return type is another
class's scoped enum typedef: golden builds it at the PROTOTYPE's span as an
`enum_var` resolved to `uvm_policy::recursion_state_e`; we build it at the
OUT-OF-BODY DEFINITION's span as a `class_var`. Kind, span and typespec all
differ; the kind fails first.

## 11. RESIDUES

* **R1 — the SeqDriver / SimpleUVM COPY SPLIT (first-ranked).** Golden itself is
  not uniform at this site: on **SeqDriver** and **SimpleUVM** the ELABORATED
  (`TopPackages`) copy of `uvm_pkg` **RESOLVES** the cast while its `AllPackages`
  copy and every wildcard-import clone degrade; on **MiniAmiq**, **Scoreboard**
  and **BuildUVMPkg** every copy degrades. The distinguisher is a property of
  the DESIGN, not of the site, and it is not any of the obvious ones: all five
  have a `TopPackages` copy; Scoreboard, SimpleUVM and SeqDriver all have a top
  module; SeqDriver and MiniAmiq both have a package that wildcard-imports
  `uvm_pkg` yet split the other way. It is Surelog's own
  `ElaborationStep` typespec-swap ordering, which no slang-visible fact models.
  This law degrades every copy, so **4 copy-cells over 4 row-modes move AWAY**
  (SeqDriver ×2, SimpleUVM ×2) while 18 move TOWARD; the net over the nine UVM
  row-modes is 4 → 22 agreeing of 26. The cells are named, and they are
  invisible to the judge today: **SeqDriver stays at 50 cmp lines and SimpleUVM
  at 17, both modes, on the same head objects** — the head logs differ from
  pristine only in `id:` numbers. Anyone who finds the design-level
  distinguisher can add it as a second conjunct and take those four back.
* **R2 — the OTHER SITES inside an exported subroutine.** Golden degrades the
  return type, the formals, the subroutine locals and the statement-block
  locals of such a body too (`g170_b_site.sv` c01-c05, c09-c10, and
  `e3`-class cells `15:12`, `15:22`, `17:5`, `21:5`, `23:7`). This law owns
  the **cast target only** — those sites are emitted from the shared
  declaration-typespec machinery several other laws depend on (§83's `uts11`
  among them), and there are **0 corpus cells** at any of them:
  `m__uvm_report_dpi` is `void` with only builtin formals. The cells exist and
  are measured; the generalisation is not made.
* **R3 — WHICH `uvm_pkg` object the placeholder points at.** Golden's four
  MiniAmiq placeholders point at `uvm_pkg` **TOP** three times and `uvm_pkg`
  **ALL** once (the ALL-view copy of the home package points at the ALL-view
  package; every other copy, clones included, points at TOP). We point at the
  package being emitted (`pkgScopeInst`) — the same pointer for the two
  home-package copies, `svaunit_pkg` for the two clones. No compared field can
  see it (§3.3's `m_visited` argument, plus the measured `--chain=10`), and
  matching golden exactly would need Surelog's clone-stamp ordering. Recorded,
  not modelled.
* **R4 — the SPELLING of the resolved sibling.** Inside an exported body golden
  names the typespecs it DOES resolve with the SCOPED form (`pe170::t_vecl`)
  where the same cast in the non-exported twin is named bare (`t_vecl`), and our
  spelling follows neither consistently (`g170_e_kinds.sv` 27:16, 28:16, 33:16,
  44:16; `g170_b_site.sv` 48:12). Present identically on both binaries; a
  separate naming family.
* **R5 — the corpus's OTHER `unsupported_typespec` cast family**, the 39 cells
  `predict170.py` EXCLUDED: Earlgrey's and Rggen's **size cast by a parameter
  name** (`AttrDw'(…)`, `NWD'(…)`, `N_ESC_SEV'(…)`), where golden holds an
  `unsupported_typespec` and we hold an `int_typespec` in one view and the
  placeholder in the other. Different mechanism, different site; untouched
  here (Earlgrey's databases are byte-identical under both binaries).
* **R6 — the package-body COPY COUNT.** At every one of these spans golden
  emits 4 copies where we emit 6 (arms A, C, E). Identical on both binaries;
  the `cnt` projection of `score170.py` is where it is judged, and it is
  `TOWARD 0 / AWAY 0 / MOVED-WRONG 0`.

## 12. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct170own.cpp` | the OWNER-FINDER + judge decoder for a both-sides-present, DIFFERENT-KIND head: owner chains, the referrer index (via the committed `r10ladder1repro/ctfields.inc`), the `m_visited` ABLATION, `--maskall` (the whole `unsupported_typespec` family at once) and `--chain=N`. |
| `ct170cen.cpp` | the census reader: `--casts` (every `vpiCastOp` operation with its target typespec kind/name and its enclosing subroutine and owning scope **with the scope's UhdmId**, so the DEF and ELAB copies can be told apart), `--unsup` (every `unsupported_typespec` with its `Instance`), `--tsrefs`. |
| `grid170.sh` / `score170.py` | one Surelog golden + both binaries × both views per arm, every rc recorded; the three-projection scorer (`set` / `cnt` / `ms`). |
| `cenrun170.sh` / `join170.py` | the corpus census over a sweep workdir pair, with the DEGRADE-TOWARD and MUST-STAY-AWAY columns. |
| `copies170.sh` | the PER-COPY tally: joins each cast row's owner-package id against `AllPackages`/`TopPackages`, which is the granularity R1 is stated at. |
| `predict170.py` | the A-PRIORI mover prediction, from PRISTINE databases and goldens only; asserts a nonzero comparable-row count. |
| `attrib170.sh` | mover attribution: workdir-normalised, `id:`-stripped, plain AND order-blind dump diffs (the Scoreboard coin can only be read order-blind). |
| `bound170.sh` / `wide170.sh` | the wide boundary gate over a COPY of the probe tree. |
| `g170_a_spell.sv` … `g170_e_kinds.sv` | the five grid arms (§7). |
| `pk170.cpp` | the `AllPackages` / `TopPackages` listing, used by `copies170.sh`. |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the standard gate battery, copied unchanged. |

## 13. REPRODUCING

```sh
g++ -O2 -std=c++17 ct170own.cpp -I ~/.local/include -I ../r10ladder1repro \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct170own
g++ -O2 -std=c++17 ct170cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct170cen
g++ -O2 -std=c++17 pk170.cpp    -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/pk170

# the head, decoded
/tmp/ct170own <golden.uhdm> <ours.uhdm> --refs --maskall --chain=10

# the grid
CT170CEN=/tmp/ct170cen ./grid170.sh g170_e_kinds.sv <pristine> <patched> <wd>
python3 score170.py <wd> e_kinds [--all]

# the a-priori prediction (PRISTINE ONLY) and the census
python3 predict170.py <pristine-workdir> /tmp/ct170cen
CT170CEN=/tmp/ct170cen ./cenrun170.sh <pris-wd> <pat-wd> <out> 'SeqDriver|SimpleUVM|Scoreboard|MiniAmiq|BuildUVMPkg'
python3 join170.py <out>
CT170CEN=/tmp/ct170cen PK170=/tmp/pk170 ./copies170.sh <pat-wd> 'MiniAmiq|SeqDriver' ':(168|9584):15'

# attribution and the boundary
./attrib170.sh <pris-wd> <pat-wd> <out> 'SeqDriver|SimpleUVM|Scoreboard|MiniAmiq|BuildUVMPkg'
PRIS=<pristine> PATCHED=<patched> ./bound170.sh <copy-of-tools/probe> <out>
bash canaudit.sh canaries.sh ctcan2.sh
```
