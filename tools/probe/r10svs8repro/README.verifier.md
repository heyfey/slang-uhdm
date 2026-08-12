# r10svs8 — ADVERSARIAL VERIFIER — § covergroupBuiltinCall8

## VERDICT: **PASS**

Every published number reproduced **independently**, from my own worktrees and
my own builds — including both binary md5s **bit for bit**. Ten previously
**empty product cells** were filled and every one of them passes. Two
**write-up defects** and one **new pre-existing residue** were found; none
touches the law, the gate, or any gate number. The implementer's one stated
**"honest limit" (merged behaviour with r10uvm61) is CLOSED by me** with a
built, swept and byte-verified merge.

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)`.

### My binaries — printed and grep-checked, never inherited

| role | worktree | `git rev-parse HEAD` | `git status` | md5 |
|---|---|---|---|---|
| CONTROL | `.claude/worktrees/r10svs8vvpris` | `a060719294b588fdfc85918775a5ad49603dd569` | porcelain **EMPTY** | `365219cb664f4498d52c9aa68f605ba7` |
| FINAL | `.claude/worktrees/r10svs8vv` | `a060719294b588fdfc85918775a5ad49603dd569` | `M src/ExprEmit.cpp` + `?? tools/probe/r10svs8repro/` | `4e5d371eddeaf9bdbc1ce08bd73019a0` |
| MERGED | `.claude/worktrees/r10svs8vv61` | `75bfb7e3abe769746b16f1ae9a3082aea5c35bb6` | `M src/ExprEmit.cpp` + `?? tools/probe/r10svs8repro/` | `6ebf930f2b58e9b70373d9b9282db381` |
| MERGED-PRISTINE | `.claude/worktrees/r10svs8vv61p` | `75bfb7e3abe769746b16f1ae9a3082aea5c35bb6` | porcelain **EMPTY** | `5cf09f5121afbb14a66eacfc84bd859b` |

Both a060719 md5s are **identical to the implementer's**, from a fresh
`git worktree add --detach a060719` + `cmake -DCMAKE_BUILD_TYPE=Release` +
`cmake --build`, link line waited for, md5 asserted separately, 32 hex.
My MERGED-PRISTINE md5 also equals the current main-tree `build/slang-uhdm`
(`5cf09f51…`), which corroborates the implementer's TIMING NOTE.
`results/*.csv` was **read only**; `git status --porcelain results/` = 0 lines
in every worktree. `git stash` was never used.

---

## 1. FINDINGS

### F1 — REPRODUCED, EXACTLY (no finding against the pass)

Every headline number reproduced. Commands and results in §2. The strongest
single cross-check: my SVSwitch databases carry the **same md5 prefixes** the
implementer reported — patched `e77036f7f80e`, pristine `119237c36e21` — in
**both** modes, from sweeps I ran with binaries I built.

### F2 — THE IMPLEMENTER'S "HONEST LIMIT" IS CLOSED: the MERGE is gated

They wrote: *"my binaries are from a060719, so the merged behaviour is not
gated by me — re-run the byte verifier on the merge."* I did.

```
$ git worktree add --detach .claude/worktrees/r10svs8vv61  75bfb7e
$ cd .claude/worktrees/r10svs8vv61 && git apply /tmp/r10svs8.patch   # clean
$ cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 6
  [100%] Linking CXX executable slang-uhdm     md5 6ebf930f2b58e9b70373d9b9282db381
$ git worktree add --detach .claude/worktrees/r10svs8vv61p 75bfb7e   # pristine, porcelain EMPTY
                                               md5 5cf09f5121afbb14a66eacfc84bd859b
```

| merged gate | result |
|---|---|
| surelog row gate vs `results/golden_surelog.csv` | **0 differing ROWS**, both status and dump histograms identical (467/13 default, 463/10 testflags) |
| u2r row gate vs `results/gate_uhdm2rtlil.csv` | **0 differing ROWS**, 679/50/2, dump 52/183/496 |
| byte verifier surelog, MERGED vs MERGED-PRISTINE | **the same two SVSwitch rows**, `e77036f7f80e` vs `119237c36e21` — the *identical* md5 pair as at a060719 — plus the Scoreboard flake (F7). SELFCHECK 952/953, SELFCHECK1 4=3+1 |
| byte verifier u2r, MERGED vs MERGED-PRISTINE | **MOVERS 0 / 679**, SELFCHECK 678/679, SELFCHECK1 1 |
| merged SVSwitch cmp head, both modes | **heads=1, 48 lines** — same as a060719+patch |
| `cmp` of the merged SVSwitch database against the a060719+patch one | **BYTE-IDENTICAL** |

**The merged SVSwitch database is byte-identical to the a060719+patch one**, so
r10uvm61 provably contributes nothing to this test and the merge is exactly the
union of the two laws. **No collision. Land order does not matter.**

### F3 — WHY EXACTLY TWO ROWS MOVED, established by construction and not by luck

The implementer proved *which* rows moved. They did not show *why no others
could*. I did:

```
$ cd ~/git-repos/Surelog
$ grep -rlE '\.(sample|set_inst_name|get_inst_coverage) *\(' tests third_party/tests \
      --include='*.sv' --include='*.v' --include='*.svh' | xargs -r grep -l covergroup \
  | sed -E 's#^(tests|third_party/tests)/([^/]+)/.*#\2#' | sort -u
Checker  Ibex  IbexGoogle  Opentitan  SVSwitch  wav-lpddr-hw
```

Cross-referenced against the committed baseline: **Checker, Ibex, IbexGoogle
and Opentitan are all `SLANG_REJECT` in both modes** (slang never compiles them,
so the emitter never runs), and `wav-lpddr-hw`'s row is `Lpddr` =
**`SURELOG_FAIL` in both modes** (no golden exists to compare against).
`CrossFunc` / `Covergroup` / `CrossItem` / `UnitClass` contain covergroups but
**no built-in call** (`CrossFunc` is `CMP_EQUAL` and unmoved; the other three are
`SLANG_REJECT`). **SVSwitch is the only reachable call site in the whole
corpus** — 2 movers is the complete and only possible answer.

### F4 — TEN EMPTY PRODUCT CELLS, filled; every one PASSES

The grid crosses {built-in} × {context} × {args} but leaves the **receiver-shape
axis** uncrossed with args, and never writes an element-select or a formal as
the receiver. I wrote three new arms (`v1_product.sv`, `v2_pkg.sv`,
`v3_refargs.sv`, all in this directory) and ran them on **both** binaries.

| cell | source | golden | CONTROL | FINAL |
|---|---|---|---|---|
| **V1** ARRAY receiver `cva8[0].sample();` | v1:29 | `method_func_call (sample) 29:13-29:19`, prefix `ref_obj (work@v1.cva8) 29:5-29:9` — **the index is DROPPED by golden** | **NOTHING** | **EQ** |
| **V2** task-FORMAL receiver `c8.sample();` | v1:33 | `mfc (sample) 33:8-33:14`, prefix `ref_obj (work@v1.tf8.c8)` | NOTHING | **EQ** |
| **V3** DEEP receiver **WITH ARGS** `h8.cgi8.sample(3);` | v1:58 | `mfc (cgi8) 58:10-58:14`, prefix `h8`, **the actual `3` DROPPED** | NOTHING | **EQ** |
| **V4** THIS receiver **WITH ARGS** `this.cgi8.sample(3);` | v1:45 | `mfc (this) 45:12-45:16`, STRING-constant prefix, **and the actual `3` KEPT** as `vpiArgument constant 45:24-45:25` | NOTHING | **EQ** |
| **V5** THREE-deep `o8.h8.cgi8.sample(3);` | v1:68 | `mfc (h8) 68:10-68:12`, prefix `o8`, tail dropped | NOTHING | **EQ** |
| **V6** built-in in a class whose ctor constructs it | v1:82 | `mfc (sample) 82:12-82:18` | NOTHING | **EQ** |
| **V7** `void'(cgk8.get_coverage());` STATEMENT-position function | v1:85 | `mfc (get_coverage) 85:18-85:30` | NOTHING | **EQ** |
| **V8** `this.cgi8.start();` built-in × this-receiver | v1:48 | `mfc (this) 48:12-48:16` | NOTHING | **EQ** |
| **W1** PACKAGE-QUALIFIED receiver `pk8::cgh8.sample();` | v2:30 | the whole call **collapses to `ref_obj (…pk8::cgh8)`** — golden emits no call | same shape | **byte-identical to CONTROL** (the arm's pre-existing `isPkgQualifiedVarRef` early return; **UNMOVED**) |
| **W2** the same on a CLASS handle — IN-LAW | v2:34 | idem | idem | idem |

**V3 vs V4 is the sharpest new evidence for the implementer's refutation of the
brief**: golden **keeps** the actual on the `this`-rooted form and **drops** it
on the deep-receiver form. Only the class-method arm implements that split; a
fresh flat `<recv>.<method>` arm cannot produce either object.

Whole-arm numbers:

```
v1_product   MULTISET DISTANCE to golden   CONTROL 160 -> FINAL 24
             sorted-multiset residue = 4 pre-existing declaration shapes only
             (bit_select 28:5-28:12, logic_typespec vs unsupported_typespec 25:3,
              unsupported_typespec 32:12-32:19) -- every one BYTE-IDENTICAL in
              the CONTROL o.dump, so none of them is this law's
             every call line in d.diff appears on BOTH sides -> pure ORDERING
v2_pkg       ours FINAL vs ours CONTROL: 0 diff lines  (the risky early-return
             path is provably UNMOVED)
```

**No over-fire found in any of the ten cells.**

### F5 — NEW RESIDUE, unreported: the hier_path-call ARGUMENT's `vpiFullName`

`v3_refargs.sv` fills the last args-axis cell: `get_coverage`/`get_inst_coverage`
carry two `ref int` formals with defaults (slang `CoverSymbols.cpp`
`addBuiltInMethods`), so they can be called **with actuals in EXPRESSION
position** — a shape the grid never writes (a2 tests `sample`'s actuals in
STATEMENT position; a3 tests `get_coverage` with NO actuals).

```
$ diff <(sort g.dump) <(sort o.dump)          # FINAL, /tmp/v8_fin_v3
<  \_ref_obj: (work@v3::cov3v::x1_8::cgx8.get_coverage::cb8), line:32:30, endln:32:33
>  \_ref_obj: (work@v3::cov3v::x1_8::cb8),                    line:32:30, endln:32:33
```

Golden scopes the actual's `vpiFullName` **through the call path**
(`…::x1_8::cgx8.get_coverage::cb8`); ours scopes it by the enclosing task only.
Four `ref_obj` lines + four `vpiFullName` lines = **8 of v3's 16 residual dump
lines**.

**PROVED PRE-EXISTING, not this law's:** the CONTROL binary emits the identical
short fullnames (this shape was already reached by the pre-existing hier_path
path). What the patch *did* do here is an improvement the implementer did not
claim: the hier_path span went `32:29 → 32:39 = golden` and `36:34 → 36:44 =
golden` via § callParenSpan11, and X3 `set_inst_name(s8)` went from **absent** to
**EQ**. Arm v3 overall: **MULTISET DISTANCE 45 → 16, `PASS_CMP` heads=0**.
Ranked **R5** below.

### F6 — TWO WRITE-UP DEFECTS (no effect on the law or any gate number)

1. **README §2.3 misattributes arm a2's residual.** It says the 26 residual dump
   lines are *"all of it the pre-existing `class property type: CovergroupType`
   declaration residue"*. **Measured: arm a2's MULTISET DISTANCE is 0** —
   `diff <(sort g.dump) <(sort o.dump)` prints **0 lines**. The residual is
   **pure ORDERING** of a `class_typespec` / `hier_path` / `int_typespec` block,
   not a missing declaration. (The `unsupported: class property type:
   CovergroupType` line is a **slang.log** line, not a dump line — the two were
   conflated.) The a2 verdict `PASS_CMP` is correct.
2. **README §2.5 reports arm a4 as `PASS_CMP, heads=0` and stops there.** True,
   but a4 also carries a **42-line dump residual** that is never characterised.
   I read it: ordering **plus two span defects on the module-scope covergroup
   instance declaration** — `unsupported_typespec: (cgm8)` endln golden `20:17`
   vs ours `20:18`, and `logic_var: (work@a4.cm8)` endln golden `20:17` vs ours
   `20:11`. **Both are byte-identical on the CONTROL binary**, so they are
   pre-existing and not this law's — but they were unreported. Ranked **R6**.

### F7 — THE SCOREBOARD FLAKE **DID** APPEAR IN MY RUN; the count is 3/953, the attribution is still 2

The implementer reported `MOVERS: 2 / 953` and *"Scoreboard flake did not
appear"*. In my sweep it **did**:

```
MOVER ./default/Scoreboard-59431470/slang.uhdm  patched=0353c8b7d3ea pristine=59e1310d070c
MOVER ./default/SVSwitch-db796243/slang.uhdm    patched=e77036f7f80e pristine=119237c36e21
MOVER ./testflags/SVSwitch-db796243/slang.uhdm  patched=e77036f7f80e pristine=119237c36e21
MOVERS: 3 / 953
```

Per the standing rule I **repped before attributing** — 3 reps per binary,
`--filter Scoreboard --mode default`:

```
rep1 FINAL 0353c8b7d3ea   rep1 CONTROL 0353c8b7d3ea   <- the two are EQUAL here
rep2 FINAL 0353c8b7d3ea   rep2 CONTROL 59e1310d070c
rep3 FINAL 0353c8b7d3ea   rep3 CONTROL 59e1310d070c
```

**The SAME pristine a060719 binary produced two different databases**, and on
rep1 patched == pristine. The same is true on the merged pair (6 reps produced
four distinct values across the two binaries, and rep2 gave merged == pristine).
**Scoreboard/default is not attributable to this patch.**

*The correction is to the CLAIM, not the pass:* "2 / 953" is a run-dependent
count. The reproducible statement is **"2 attributable movers + the known
Scoreboard/default flake, which appears or not per run"**. SELFCHECK1 correctly
read `4 = 3 real + 1 corrupted` in my run, which is the control behaving.

### F8 — NO COLLISION with § covergroupNewCall7 (r10svs7)

All seven `tools/probe/r10svs7repro` arms re-run on **both** my binaries:

```
arm             CONTROL                                   FINAL
a1_witness      heads=1 lines=162  DUMP content=326       heads=1 lines=162  content=326
a2_args         heads=1 lines=266  content=368            heads=1 lines=266  content=368
a3_context      heads=1 lines=41   content=170            heads=1 lines=41   content=170
a4_escaped      heads=1 lines=162  content=174            heads=1 lines=162  content=174
v1_defaultargs  heads=1 lines=796  content=84             heads=1 lines=796  content=84
v2_places       heads=1 lines=426  content=317            heads=1 lines=426  content=317
v3_lhsforms     heads=1 lines=326  content=160            heads=1 lines=326  content=160
```

**Identical on every arm.** r10svs7 owns `NewCovergroup`; this pass owns `Call`.
Disjoint.

### F9 — PATCH HYGIENE: clean

```
$ git apply --check /tmp/r10svs8.patch            # on a FRESH a060719 -> OK
$ git apply --check /tmp/r10svs8.patch            # on 75bfb7e         -> OK
$ grep '^+++ b/' /tmp/r10svs8.patch | grep -vE 'src/ExprEmit.cpp|tools/probe/r10svs8repro/'
  (nothing)
$ git apply --numstat /tmp/r10svs8.patch | head -1
  89	1	src/ExprEmit.cpp
$ git diff a060719 -- src/ | md5sum        917c52420a85edd06447664b16082fdc
$ git diff        -- src/ | md5sum         917c52420a85edd06447664b16082fdc   # my worktree == the patch
$ md5sum /tmp/r10svs8.patch                e76ad2e9b0bfb504a2ce540cf3d3b491   # as delivered
```

No `results/*.csv`, no other `src/` file, **no `getenv`/debug residue in
`src/`** (the `getenv` strings in the patch are README prose; the `printf`s are
inside the repro shell scripts). r10uvm61's hunks in the same file are at
`@@ -1160`, `@@ -11366`, `@@ -11383`; mine at `@@ -383`, `@@ -9173`. Disjoint, and
`git diff a060719 75bfb7e -- results/` is **EMPTY**, so both row gates used the
correct committed baselines.

### F10 — STATED GATE == CODE GATE, and the predicate's coverage claim is TRUE

```cpp
static bool covergroupBuiltinCall8(const slang::ast::SubroutineSymbol& sub) {
    const slang::ast::Scope* psc = sub.getParentScope();
    return psc && psc->asSymbol().kind == slang::ast::SymbolKind::CovergroupBody;
}
...
if (auto psc0 = sub.getParentScope();
    psc0 &&
    (psc0->asSymbol().kind == SymbolKind::ClassType ||
     covergroupBuiltinCall8(sub)) &&
    call.thisClass()) {
```

Parenthesisation is explicit and correct; the two scope kinds are disjoint;
`call.thisClass()` is unchanged. **No name, no syntax, no source text is read**,
so the escaped-identifier rule is satisfied *at the gate* — and I confirmed the
consequence *at the arm*: a5 G1 `\cg.esc8 .sample();` yields
`vpiName:cg.esc8` byte-equal to golden, dot intact.

I checked the exhaustiveness claim **against slang itself**, not against the
write-up (`/home/heyfey/git-repos/slang/source/ast/symbols/CoverSymbols.cpp`):

* `:129-155` `addBuiltInMethods(scope, isCovergroup)` adds exactly
  `set_inst_name` (covergroup only), `get_coverage` (+`MethodFlags::Static`),
  `get_inst_coverage`, `start`, `stop`;
* `:195` the `CovergroupBodySymbol` **constructor** calls it with `true`;
* `:247-248` `sample` is added separately by `CovergroupType::fromSyntax` on the
  **same body**;
* `:779` and `:926` call it with `false` on `CoverpointSymbol` and
  `CoverCrossSymbol`, whose scope kinds are `Coverpoint` / `CoverCross`.

So a `CovergroupBody` scope contains **exactly those six subroutines and no
others** — the predicate is neither over- nor under-inclusive, and E7's
Coverpoint abstain is structural, not accidental. **`CoverCross` remains
un-gridded** (R4).

---

## 2. THE FIVE GATES, RE-RUN INDEPENDENTLY

### GATE 1 — BUILD
See the table at the top. **Both a060719 md5s reproduce the implementer's
exactly**, from fresh worktrees; `rev-parse HEAD` printed and grep-checked for
every binary; link line waited for; md5 asserted separately.

### GATE 2 — GOLDENS
```
SLANG_UHDM=<FINAL>    tests/check_goldens.sh   exit 0   PASS=23  FAIL=0
SLANG_UHDM=/bin/false tests/check_goldens.sh   exit 1   PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`, own `--out`/`--workdir`
```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/v8_u2r_fin.csv
  731 ROWS both sides;  WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  DUMP histogram  base: 52 / 183 differ / 496 match   fresh: IDENTICAL
  PASS
```

### GATE 4 — surelog, BOTH modes, `--jobs 2`
```
[default]   794 tests  CMP_EQUAL: 467  CMP_NOTEQUAL: 13  DEFERRED: 5
                       SLANG_REJECT: 284  SURELOG_FAIL: 25
[testflags] 794 tests  CMP_EQUAL: 463  CMP_NOTEQUAL: 10  DEFERRED: 5
                       SLANG_REJECT: 286  SURELOG_FAIL: 23  NO_DATABASE: 3
                       NO_UHDM: 1  TIMEOUT: 1  UNTRANSLATABLE: 2
ct8rows.sh results/golden_surelog.csv /tmp/v8_sl_fin.csv
  1588 ROWS both sides;  WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  DUMP histograms  default 242 differ / 225 match ; testflags 298 differ / 165 match
                   IDENTICAL to the committed baseline in BOTH modes
  PASS
```
**SVSwitch stayed `CMP_NOTEQUAL` in both modes**, quoted from my fresh CSV and
byte-equal to `results/golden_surelog.csv`:
```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```
No `results/*.csv` was edited by me or by the pass
(`git status --porcelain results/` = 0 lines).

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs the PRISTINE a060719 I built
```
surelog   : patched=953 pristine=953   PATH_SETS_IDENTICAL
            MOVER ./default/SVSwitch-db796243/slang.uhdm    e77036f7f80e vs 119237c36e21
            MOVER ./testflags/SVSwitch-db796243/slang.uhdm  e77036f7f80e vs 119237c36e21
            MOVER ./default/Scoreboard-59431470/…           <- FLAKE, proved by rep (F7)
            MOVERS: 3 / 953   (2 attributable + 1 flake)
            SELFCHECK 952/953 [PASS]   SELFCHECK1 4 = 3 + 1 [PASS]
uhdm2rtlil: patched=679 pristine=679   PATH_SETS_IDENTICAL
            MOVERS: 0 / 679
            SELFCHECK 678/679 [PASS]   SELFCHECK1 1 = 0 + 1 [PASS]
```

**MOVERS PER SHAPE — multiset, ADDED and REMOVED separately, identical in BOTH
modes** (`msmovers.sh <golden> <pristine> <patched>`):
```
MULTISET distance to GOLDEN  PRISTINE: golden-only 507  ours-only 886  TOTAL 1393
MULTISET distance to GOLDEN  PATCHED : golden-only 497  ours-only 887  TOTAL 1384

OBJECT lines:
  ADDED +1  \_begin: (work@coverage::sample), line:36:1, endln:36:26
  ADDED +1  \_method_func_call: (sample), line:36:17, endln:36:23   (two depths)
  ADDED +1  \_method_func_call: (sample), line:36:17, endln:36:23
  ADDED +1  \_ref_obj: (work@coverage::sample::switch_coverage), line:36:1, endln:36:16
  REMOVED   (none)
BARE FIELD lines (non-attributable): |vpiFullName |vpiName x2 |vpiParent x2 |vpiPrefix |vpiStmt
```
**4 object lines ADDED, 0 REMOVED; every one of them is an object golden HAS.**

**THE HEAD, re-measured by me, both modes:**
```
CONTROL : heads=1  158 lines   LHS begin: (work@coverage::sample), id:2104, 36:1-36:26
FINAL   : heads=1   48 lines   LHS ref_obj: (work@Environment::reset::input_intf),
                                   id:1680, 63:16-63:32
                               RHS hier_path: (input_intf.clock), id:2417, 63:16-63:32
MERGED  : heads=1   48 lines   (identical)
```
`grep -c '^LHS:'` = **1** on every run — ONE head per run, as the law requires.

### CANARIES — all re-run by me
```
ctcan2.sh  golden_surelog.csv   /tmp/v8_sl_fin.csv   EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown=1  PASS
ctcan2.sh  gate_uhdm2rtlil.csv  /tmp/v8_u2r_fin.csv  EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown=6  PASS
canaries.sh /tmp/v8_sl_fin.csv  golden_surelog.csv   -> ok=52 changed=0 absent=0 unknown-names=7
canaries.sh /tmp/v8_u2r_fin.csv gate_uhdm2rtlil.csv  -> ok=8  changed=0 absent=0 unknown-names=25
canaudit.sh canaries.sh ctcan2.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
  (UnsignedParam / HierPathEval / FileLocalParam / TopParam: "not dispatched by any driver")

BY NAME, quoted from my fresh CSV vs the committed baseline:
  InterfaceModPort    default/testflags  CMP_EQUAL,,,differ     == baseline
  BlackParrotComplex  default/testflags  CMP_EQUAL,,,differ     == baseline
  SVSwitch            default/testflags  CMP_NOTEQUAL,decompile:,,  == baseline
```

---

## 3. THE GRID, RE-EXECUTED — per-arm MULTISET distance, CONTROL → FINAL

Measured with `msdist.sh` (the whitespace-correct version shipped in this
directory), on my own two binaries:

| arm | CONTROL | FINAL | what the FINAL residue actually is |
|---|---|---|---|
| a1_witness | 33 | **0** | nothing — sorted-diff **0 lines**; the surviving `cmp` head is child ORDER only. **Implementer's claim reproduced.** |
| a2_args | 99 | **0** | nothing — **ORDERING only** (see F6.1: the README calls this a declaration residue; it is not) |
| a3_builtins | 67 | **8** | E7 Coverpoint `hier_path` span `60:34` vs golden `60:36`, ×4 depths — the ABSTAIN control, exactly as designed (R4) |
| a4_context | 61 | **6** | two module-scope covergroup **declaration** spans, **both byte-identical on the CONTROL** (F6.2, R6) |
| a5_escaped | 22 | **12** | escaped-receiver spans, constant **+5** columns; names byte-EQ incl. the dot (R3) |
| a6_escinlaw | 24 | **24** | **UNCHANGED — the attribution arm works.** `ours FINAL` vs `ours CONTROL` = **0 diff lines**; the CONTROL already shows `mfc (touch) 32:20-32:25` golden vs `32:15-32:20` ours for a plain CLASS handle. **R3 is PRE-EXISTING; the implementer's attribution is CORRECT.** |
| v1_product *(mine)* | 160 | **24** | pre-existing declaration shapes only; all 8 call cells EQ (F4) |
| v2_pkg *(mine)* | — | — | FINAL vs CONTROL **0 diff lines** (F4) |
| v3_refargs *(mine)* | 45 | **16** | 8 lines = the new R5 argument-fullname residue, pre-existing; 8 = ordering (F5) |

E4's span improvement is confirmed on my binaries (`48:29` CONTROL →
`48:31` = golden FINAL), and E7 correctly does **not** move.

---

## 4. RANKED RESIDUES (mine — the implementer's list, corrected and extended)

| # | residue | status | evidence |
|---|---|---|---|
| **R1** | **SVSwitch head 3 — `Environemnt.sv:63`, `@(input_intf.clock)`**: golden one `ref_obj (work@Environment::reset::input_intf)` 63:16-63:32, ours a two-element `hier_path (input_intf.clock)` at the same span. **48 cmp lines = the WHOLE remaining head, 1 head, identical in both modes and on the merged binary.** | **CONFIRMED by me**, agreed rank 1 — SVSwitch converts on this if nothing hides behind it | `/tmp/v8_cmp_fin_{default,testflags}.log`, `/tmp/v8_cmp_mrg_*.log` |
| **R2** | class PROPERTY of a named covergroup type dropped (`unsupported: class property type: CovergroupType`) — the one unsupported line every arm prints. Inherited from r10svs7 R3. | confirmed, unchanged | every arm's `slang.log` |
| **R3** | escaped-receiver `method_func_call`/prefix spans, constant **+5**, names byte-EQ | **PRE-EXISTING — attribution INDEPENDENTLY CONFIRMED** on the CONTROL binary via arm a6; a6 FINAL vs CONTROL = 0 diff lines | a5 G1/G2 + a6 H1/H2 |
| **R4** | Coverpoint `get_coverage()` keeps the short `hier_path` span `60:34` vs golden `60:36`, because `Coverpoint` is deliberately outside the gate. **CoverCross was never gridded**, so widening the predicate must be measured on its own arm first. | confirmed, cheap next pass | a3 E4 (fixed) vs E7 (unchanged) |
| **R5** | **NEW (mine).** A covergroup built-in called in **EXPRESSION position WITH actuals** gets argument `ref_obj`s whose `vpiFullName` is **not scoped through the call path**: golden `…::x1_8::cgx8.get_coverage::cb8`, ours `…::x1_8::cb8`. 8 dump lines. **PROVED PRE-EXISTING** (identical on CONTROL). Not in the corpus. | new; owner = hier_path-call argument naming | `v3_refargs.sv` X1/X2, `/tmp/v8_{ctl,fin}_v3` |
| **R6** | **NEW (mine).** Module-scope covergroup **instance declaration** spans: `unsupported_typespec: (cgm8)` endln golden `20:17` vs ours `20:18`, and `logic_var: (work@a4.cm8)` endln golden `20:17` vs ours `20:11`. **PROVED PRE-EXISTING** on the CONTROL. Unreported by the pass. | new; owner = covergroup-instance declaration emission | arm a4, `/tmp/v8_ctl_a4_context/o.dump` |
| **R7** | Surelog keeps only the LAST statement of a class CONSTRUCTOR body (r10svs7 §2.1). My `v1_product.sv` obeys it (one statement per `new`). | recorded | — |
| **R8** | `class_defn` child ORDER differs from golden on several arms (a1 a2 a4 v1) at MULTISET distance 0 — a pre-existing arm artefact, not a corpus behaviour. | recorded | sorted-diff = 0 lines |
| **R9** | **Scoreboard/default nondeterminism.** Not a residue of this law but of the measurement: the same binary produces different databases across runs. Any pass whose mover count is quoted without a rep is quoting a coin flip. | recorded (F7) | 6 reps, 2 binaries, ≥2 values each |

---

## 5. WHAT I RAN

New arms added by this verification (this directory):
`v1_product.sv` (8 receiver-shape × args cells), `v2_pkg.sv` (the
package-qualified early-return cell), `v3_refargs.sv` (ref actuals on a
built-in). Drivers are the pass's own `ct8arm.sh` / `ct8cell.sh` / `msdist.sh` /
`msmovers.sh` / `ct8rows.sh` / `byteverify.sh` / `ctcan2.sh` / `canaries.sh` /
`canaudit.sh`, unmodified.

Sweeps: 6 (`surelog --mode both` × {FINAL, CONTROL, MERGED, MERGED-PRISTINE},
`uhdm2rtlil --mode testflags` × the same four, plus 12 `--filter Scoreboard`
reps), all `--jobs 2` with their own `--out` and `--workdir`. `GOLDEN_DEFER`
never set. **All `/tmp` sweep and arm workdirs deleted after measurement**; the
four worktrees are left in place so every number above is re-checkable.

None of the four SLANG-FENCED names (UnsignedParam, HierPathEval,
FileLocalParam, TopParam) was dispatched by any driver — asserted by
`canaudit.sh` (`FENCE-BREACH=0`), not by a sentence.

---

## 6. BOTTOM LINE

**PASS — land it.** The executable change is one predicate and one `||`; the law
is right, the gate reads a scope kind and no name, the abstain control is
structural rather than accidental, the two attributable movers are the target and
are **exhaustive by construction**, and the merge with r10uvm61 is now gated and
byte-identical on the target. Two write-up corrections (F6) and one new
pre-existing residue (F5, R5) should be folded into the commit record; neither
changes a single gate number.
