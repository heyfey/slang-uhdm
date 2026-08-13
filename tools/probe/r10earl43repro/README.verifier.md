# r10earl43 — ADVERSARIAL VERIFIER REPORT

## VERDICT: **PASS**

Every number in the implementer's report reproduces, on binaries I built myself
from a fresh `5fa6b49` worktree — including **both md5s, bit for bit**. Five
gates green independently. The head clears 46 → 30 and the new head is
byte-identical to the committed witness. One real byte mover in 2 311
databases, and it is the target.

Ten numbered findings follow. **None of them is a defect in the emitted UHDM.**
The two that matter are (F-2) a SECOND byte mover appeared in my gate-5 run and
I proved by construction that it is emitter nondeterminism, not the patch, and
(F-3) the LAW as prosed is FALSE for a generate-scope connection — golden sides
with the CODE, not with the prose, so the code is right and the sentence needs a
qualifier before anyone builds on it.

---

## 0. WHAT I DID, AND ON WHAT

| | |
|---|---|
| applied to | **a FRESH `5fa6b49`** worktree `/tmp/wt_v43pat` (`git worktree add --detach`), `git apply --check` clean, then `git apply` |
| pristine | **`5fa6b49`**, worktree `/tmp/wt_v43pris`, built by me |
| also tested | the patch `git apply --check`s clean on **current HEAD `38f308e`** too (F-7) |
| build | `~/.local/bin/cmake -S <wt> -B <wt>/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local` then `cmake --build <wt>/build -j 2`, absolute paths, sequential |

```
git -C /tmp/wt_v43pris rev-parse HEAD | grep -q '^5fa6b496ff8bf2fea7badcda0396a413e20e346e$'   -> BASE_GREPCHECK_OK
git -C /tmp/wt_v43pat  rev-parse HEAD | grep -q '^5fa6b496ff8bf2fea7badcda0396a413e20e346e$'   -> BASE_GREPCHECK_OK
git -C /tmp/wt_v43pat  status --porcelain  ->  M src/ModuleEmit.cpp  +  ?? tools/probe/r10earl43repro/   (nothing else tracked)
```

**My binaries:**

```
PRISTINE  /tmp/wt_v43pris/build/slang-uhdm   288e337ff8a9489571ea256059e53a8d
PATCHED   /tmp/wt_v43pat/build/slang-uhdm    f376ff682605be375e5eb5ce46568791
```

Both **identical to the implementer's**. The build is byte-reproducible on this
machine, which removes the whole class of "was that really the binary you
describe" doubt from the rest of this report. `grep -ciE "error:" build.log` = 0
on both; `Linking CXX executable slang-uhdm` reached on both; binary mtime
(16:12:53) > `src/ModuleEmit.cpp` mtime (16:06:41).

Every binary path used below was printed and md5'd by the harness script itself
on every invocation (`earl43.sh` / `arm43.sh` print `BINARY … md5=…`), and every
sweep's binary was read back out of its own `cmds.txt`, never assumed.

---

## 1. THE HEAD — REPRODUCED

```
cd tools/probe/r10earl43repro
SLANG_UHDM=/tmp/wt_v43pris/build/slang-uhdm ./earl43.sh /tmp/v43_earl_pris
SLANG_UHDM=/tmp/wt_v43pat/build/slang-uhdm  ./earl43.sh /tmp/v43_earl_pat
```

```
PRISTINE  CMP_NOTEQUAL  cmp heads=1 lines=46   o.dump lines=4655195   md5 db70c71278dd…  size 49941318
PATCHED   CMP_NOTEQUAL  cmp heads=1 lines=30   o.dump lines=4655204   md5 d3dcad27f75b…  size 49941384
```

* `diff tools/probe/r10earl42repro/r6_nexthead42.cmp /tmp/v43_earl_pris/cmp.log`
  → **empty**. The pristine head is byte-identical to the committed witness, so
  the pass stood on the base the brief describes. **46 lines.**
* `diff tools/probe/r10earl43repro/r6_nexthead43.cmp /tmp/v43_earl_pat/cmp.log`
  → **empty**. The new 30-line head witness is exactly what the patched binary
  produces.
* `+9` dump lines, `+66` serialized bytes, both as reported.

---

## 2. THE CENSUS — ALL SIX PREDICTIONS LAND (INDEPENDENTLY)

```
uhdm-dump <golden cache>/golden.uhdm | sed 1d > /tmp/v43_earl_g.dump      (4823448 lines)
python3 census43.py /tmp/v43_earl_g.dump /tmp/v43_earl_{pris,pat}/o.dump
./msdist.sh /tmp/v43_earl_g.dump /tmp/v43_earl_{pris,pat}/o.dump
```

| | PRISTINE | PATCHED | REPORTED | PREDICTED |
|---|---|---|---|---|
| port `vpiHighConn` actuals joined, golden-only / ours-only | 31439 / 0 / 0 | 31439 / 0 / 0 | same | — |
| golden `constant` → ours `ref_obj` | **1** | **0** | 1 → 0 | 0 |
| golden `constant` → ours `constant` | **4391** | **4392** | 4391 → 4392 | 4392 |
| golden `constant` → ours `operation` | **2** | **2** | 2 → 2 | 2 |
| `allModules` ours `constant` | 1998 | **1999** (= golden's) | — | — |
| `allModules` ours `ref_obj` | 7374 | **7373** (= golden's) | 7374 → 7373 | 7373 |
| `allModules` `param_assign`+ts, ours | **0** | **1** (= golden's 1) | 0 → 1 | 1 |
| `o.dump` lines | 4655195 | 4655204 | same | +9 |
| golden-only line instances | 238510 | 238500 | same | — |
| ours-only line instances | 70257 | 70256 | same | — |
| **MULTISET DISTANCE** | **308767** | **308756** | same | −11 |

**Per-shape multiset of the two OURS dumps, ADDED and REMOVED separately** (my
own run, `sort | uniq -c` keyed on the VERBATIM line, indentation intact):

```
TOTAL ADDED 13   TOTAL REMOVED 4
```

— object-for-object the thirteen/four shapes the report lists, in a
4 655 204-line dump. **One object changed.** The `\_param_assign: , line:9:27,
endln:9:67` line inside that block is our PRE-EXISTING end-column defect and the
report says so itself; see F-10.

---

## 3. THE GRID — REPRODUCED, AND **ZERO NEW NON-MATCHES**

```
./arm43.sh a1_earl43.sv   ;  ./arm43.sh v43_overfire.sv     (both binaries)
python3 grid43.py <g.dump> <o.dump>
```

| arm | PRISTINE | PATCHED | reported |
|---|---|---|---|
| `a1_earl43.sv` | ROWS 61, NON-MATCH **12** | NON-MATCH **5** | 12 → 5 ✔ |
| `a1_earl43.sv` `cmp.log` | 46 lines | **28** lines | 46 → 28 ✔ |
| `v43_overfire.sv` | ROWS 18, NON-MATCH **6** | NON-MATCH **3** | 6 → 3 ✔ |

I did not take the counts on trust: I diffed the SETS of non-matching keys.

```
comm -13 <non-match keys pristine> <non-match keys patched>   ->  EMPTY, both arms
```

**No cell that matched before the patch fails after it.** The cells that moved
are exactly `u_c1 u_deep u_c11 u_c5 u_c6 u_c10 u_c15` and `Q_PLAIN Q_STR
Q_REAL`; the ones that stayed put are exactly the controls.

**The two under-fire controls hold, verbatim from my own patched grid:**

```
MATCH  allModules work@sink43 (u_e1)  (p_i)   G/O: ref_obj @44:25-44:31 work@mix43.u_e1.p_i.E1_OWN
MATCH  allModules work@sink43 (u_e7)  (p_i)   G/O: ref_obj @50:25-50:40 work@mix43.u_e7.p_i.E7_OWN_FROM_PKG
MATCH  allModules work@sinkst43 (u_e2) (p_i)  G/O: ref_obj @45:25-45:33 …Q_STRUCT
MATCH  allModules work@sinkar43 (u_e3) (p_i)  G/O: ref_obj @46:25-46:30 …Q_ARR
```

`E1_OWN` is `localparam logic [31:0] = 32'h00008000` — the package parameter's
exact type and value, in the same module, under a wildcard import. It does not
fold, on either side. The per-SYMBOL gate is the right gate.

**And the `stripImplicitConv` claim is confirmed by measurement, not by the
counterfactual binary I cannot rebuild.** My PRISTINE grid shows `u_c5` / `u_c6`
/ `u_c10` / `u_c15` as `constant … ts:- par=-` — the value already correct, the
typespec and parent both missing. A bare-`NamedValue` gate would have left
exactly those four half-right while clearing the Earlgrey head, i.e. it would
have looked finished. The report's account of its own first build is consistent
with what the pristine binary actually emits.

---

## 4. THE FIVE GATES, RUN BY ME

### GATE 1 — BUILD

Above. Absolute path, `-j 2`, link line reached, 0 `error:`, md5s asserted
SEPARATELY (32 hex each) and re-asserted after every gate.

### GATE 2 — GOLDENS

```
SLANG_UHDM=/tmp/wt_v43pat/build/slang-uhdm bash tests/check_goldens.sh   ->  PASS=23 FAIL=0  rc=0
SLANG_UHDM=/bin/false                      bash tests/check_goldens.sh   ->  PASS=0  FAIL=23 rc=1
```

### GATE 3 — uhdm2rtlil, testflags

One `verify_golden.py` invocation per binary (`--mode both`, `--jobs 2`, own
`--out`/`--workdir`), `GOLDEN_DEFER` asserted UNSET by the driver, `SLANG_UHDM`
exported, and each sweep's binary read back out of its own `cmds.txt`.

```
[testflags] 731 tests   CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2      -> 679/50/2
dump column: 496 match / 183 differ / 52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh testflags rows>
    baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
    ---- WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
    PASS: every row byte-identical to the committed baseline
diff <(sort v43_u2r_pat.csv) <(sort v43_u2r_pris.csv)   ->  IDENTICAL (both modes, 1462 rows)
```

### GATE 4 — surelog, BOTH modes, one invocation per mode per binary, sequential

```
[default]   794 tests  CMP_EQUAL 469  CMP_NOTEQUAL 11  SURELOG_FAIL 25  DEFERRED 5  SLANG_REJECT 284   -> 469/11
[testflags] 794 tests  CMP_EQUAL 465  CMP_NOTEQUAL  8  SURELOG_FAIL 23  DEFERRED 5  SLANG_REJECT 286   -> 465/8
```

```
ct8rows.sh results/golden_surelog.csv <fresh default+testflags, header once>
    baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
    ---- WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
    STATUS histograms  base == fresh, both modes
    DUMP   histograms  base == fresh   (default 325 blank/244 differ/225 match ;
                                        testflags 329/300/165)
    PASS: every row byte-identical to the committed baseline
diff <(sort v43_sl_pat.csv) <(sort v43_sl_pris.csv)  ->  IDENTICAL
```

### GATE 5 — BYTE VERIFIER, BOTH corpora, BOTH modes, vs MY pristine

`SELFCHECK=1 SELFCHECK1=1` on every run.

```
uhdm2rtlil (both modes)   databases 1358 / 1358   PATH_SETS_IDENTICAL   MOVERS 0 / 1358
                          SELFCHECK 1357/1358     SELFCHECK1 = 1
surelog default            databases  480 /  480  PATH_SETS_IDENTICAL   MOVERS 2 /  480
   MOVER ./default/Earlgrey_0_1-71da2fd7   patched d3dcad27f75b  pristine db70c71278dd
   MOVER ./default/Scoreboard-59431470     patched 9c8a8b7bf8ba  pristine f92eb58f4bd0
                          SELFCHECK  479/480     SELFCHECK1 = 3  (corrupted + the two)
surelog testflags          databases  473 /  473  PATH_SETS_IDENTICAL   MOVERS 0 /  473
                          SELFCHECK  472/473     SELFCHECK1 = 1
```

**2 311 databases, 2 movers, ONE of them real and it is the target.** The other
is Scoreboard and I proved it is a flake rather than asserting it — F-2.

The target's mover: `SIZE 49941384 vs 49941318 = +66, NONZERO → real by the
stated rule`, and the two md5s are the SAME two my own `earl43.sh` runs produced
from an unrelated working directory:

```
d3dcad27f75b…  /tmp/v43_wd_sl_d_pat/default/Earlgrey_0_1-71da2fd7/slang.uhdm
d3dcad27f75b…  /tmp/v43_earl_pat/slang.uhdm
db70c71278dd…  /tmp/v43_wd_sl_d_pris/default/Earlgrey_0_1-71da2fd7/slang.uhdm
db70c71278dd…  /tmp/v43_earl_pris/slang.uhdm
```

---

## 5. CANARIES — RUN BY ME

```
canaries.sh  u2r testflags vs committed  : ok=8  changed=0 absent=0 unknown-names=25   rc=0
canaries.sh  SL  both modes  vs committed: ok=52 changed=0 absent=0 unknown-names=7    rc=0
ctcan2.sh    u2r  EXPECT_UNKNOWN=6       : ok=1  changed=0 absent=0 unknown-patterns=6 PASS
ctcan2.sh    SL   EXPECT_UNKNOWN=1       : ok=58 changed=0 absent=0 unknown-patterns=1 PASS
canaudit.sh                              : audited=29 UNCOVERED=0 FENCE-BREACH=0       PASS
```

**Both `ctcan2` guards exercised, on BOTH corpora**, not assumed:
`EXPECT_UNKNOWN=0` exits **6** on the u2r csv and **6** on the SL csv, so an
unaccounted unmatched pattern can never read as green.

**Named databases, BYTE-COMPARED not row-compared** (their rows are
`CMP_EQUAL`+`differ`, i.e. blind to bytes):

```
InterfaceModPort    default BYTE-IDENTICAL   testflags BYTE-IDENTICAL
BlackParrotComplex  default BYTE-IDENTICAL   testflags BYTE-IDENTICAL
YosysOldOr          default BYTE-IDENTICAL   testflags BYTE-IDENTICAL
SVSwitch            default BYTE-IDENTICAL   testflags BYTE-IDENTICAL
```

Rows by name vs the committed baselines: all four IDENTICAL both modes, and

```
Earlgrey_0_1 default   CMP_NOTEQUAL,decompile:        IDENTICAL   (its ROW does not move, its BYTES do)
Earlgrey_0_1 testflags SLANG_REJECT,reqfifo_rdata.error  IDENTICAL
```

Genscope canaries by name, u2r testflags, fresh vs committed — all IDENTICAL:
`gen_test9 genvar_loop_decl_2 genvar_loop_decl_3 paramod_genscope_child
genscope_cells gen_test4 indexed_partsel_array EnumConcat`.

**Prior-pass arms, both binaries, run by me — every one byte-for-byte
unchanged by the patch:**

| arm | pristine | patched |
|---|---|---|
| `r10earl42 a1_earl42.sv` | head 32, content 1883 | **head 32, content 1883** |
| `r10earl42 v42_overfire.sv` | PASS_CMP, content 348 | **PASS_CMP, content 348** |
| `r10earl41 a1_earl41 / v41v_overfire / v41v_comment / v41_orphan` | 30 / 44 / 0 / 104 | **30 / 44 / 0 / 104** |
| `r10earl40 a1_sel40 / v40_overfire / v40_orphan / bnd_a1_argts / bnd_a1_chain / bnd_a2_fence` | 78 / 30 / 104 / 17 / 0 / 17 | **identical** |

Earlgrey `vpiReordered`: golden **0**, pristine **0**, patched **0** —
§ `importedConcatNoMdimReorder42` holds.

**PRODUCTION DIFF IS A PURE INSERTION.** In the `src/ModuleEmit.cpp` hunk the
only line beginning with `-` is the `--- a/src/ModuleEmit.cpp` header:
`git apply --numstat` reports `1786 added, 0 deleted`. No existing line is
modified, and the inserted block's tail (`defRefModConn = false; rports->
push_back(p); continue;`) is an exact replication of the loop's own tail, so the
`continue` skips no field the other arms set.

---

## 6. THE HUNT FOR EMPTY PRODUCT CELLS

Two new probe files, eight cells the pass's own two probes do not carry.

`v43_h1_order.sv` — **EMISSION ORDER.** `pkgParamConst` is populated while the
PACKAGE's def view is emitted; if a module's def listing ran first the arm would
silently not fire. Package declared LAST in the file:

```
pristine  cmp heads=1 lines=46
patched   PASS_CMP  cmp heads=0 lines=0        <- no order dependence; hypothesis REFUTED
```

`v43_h2_cells.sv` — ROWS 34, **NON-MATCH 10 → 4, and `comm -13` of the
non-match key sets is EMPTY**: no new non-match.

| cell | what it probes | golden | patched |
|---|---|---|---|
| `u_untp` | package **UNTYPED `parameter`** | const `11` + ts + parent | ✔ MATCH |
| `u_time` | package **`time`** param | const + ts(`time_typespec`) + parent | ✔ MATCH |
| `u_mac` | reference through a MACRO expanding to the **BARE** name | const + ts + parent | ✔ MATCH |
| `u_macs` | MACRO expanding to the **SCOPED** name | bare const | `ref_obj` — the `::` gate HOLDS, no over-fire; residue R1 family |
| `u_twice1/2` | the **SAME** pkg param connected TWICE in one module | const + ts + parent, both | ✔ MATCH both |
| `u_pm` | enclosing module is **PARAMETERIZED** (`midh2 #(MW)`) | const + ts(`work@midh2`) + parent | ✔ MATCH |
| `u_gen` | connection inside a **GENERATE block** | **`ref_obj`** | **`ref_obj` ✔ MATCH** — see F-3 |

`rawText` reads a macro range back through `getFullyOriginalRange` to the macro
BODY, which is why `u_mac` folds and `u_macs` does not — the text gate is doing
the right thing for the right reason.

**EMPTY PRODUCT: NOT FOUND, but the shape is latent.** Across all eight new
cells every minted `ref_typespec` got an actual — the h2 per-shape multiset adds
`5 × \_ref_typespec: (work@toph2)` + `1 × (work@midh2)` and `6 × |vpiActual:`.
The two unexercised half-object paths are F-4 and F-5.

---

## 7. NUMBERED FINDINGS

**F-1 — CONFIRMATION (strongest available).** My independent builds of
`5fa6b49` and `5fa6b49 + patch` produced md5 `288e337ff8a9489571ea256059e53a8d`
and `f376ff682605be375e5eb5ce46568791`, **identical to the implementer's**.
Command: `cmake -S <wt> -B <wt>/build -DCMAKE_BUILD_TYPE=Release
-DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build <wt>/build -j 2 && md5sum
<wt>/build/slang-uhdm`. Every subsequent number is therefore a measurement on a
binary whose identity is proved, not asserted.

**F-2 — MATERIAL, and it CLOSES an open caveat in the report. My gate-5 surelog
run had TWO movers, and I proved the second is emitter nondeterminism rather
than asserting it.** The implementer reported `MOVERS 1/953` and wrote that
`Scoreboard`'s absence "is luck of the run". My run drew the other card:
`MOVER ./default/Scoreboard-59431470 patched=9c8a8b7bf8ba pristine=f92eb58f4bd0`.
Proof by construction, same command line the sweep used, from the test's own
directory:

```
PRISTINE  x3 :  b78dc8dde46e9449…  b78dc8dde46e9449…  f92eb58f4bd0b20a…
PATCHED   x4 :  b78dc8dde46e9449…  f92eb58f4bd0b20a…  afc9f35ef0007e96…  f92eb58f4bd0b20a…
```

The PRISTINE binary ALONE emits two distinct databases, and the md5 the byte
verifier attributed to "pristine" (`f92eb58f4bd0`) is emitted by the PATCHED
binary too. The two binaries' output sets overlap; there is no direction to the
"change". This is the documented `SourceLocation`-across-macro-buffers
nondeterminism under parallel parse, it is a property of `Scoreboard`, and it is
**not attributable to this pass**. **Real mover count stays 1 in 2 311.** For the
next pass: `Scoreboard` cannot be used as a byte canary without repeated runs.

**F-3 — THE STATED LAW IS FALSE FOR A GENERATE-SCOPE CONNECTION; golden agrees
with the CODE, not with the prose.** § 0 says "in the DEF listing, a port
connection whose actual is a BARE reference to a PACKAGE parameter is
SUBSTITUTED". New cell `v43_h2_cells.sv` `u_gen` is a port connection in the DEF
listing whose actual is a bare reference to a package parameter, inside
`if (1) begin : g_blk`, and golden does **not** substitute it:

```
MATCH  allModules work@leafh2 (u_gen) (p_i)
   G: ref_obj @56:27-56:35 work@toph2.g_blk.u_gen.p_i.H2_PLAIN ts:- par=port
   O: ref_obj @56:27-56:35 work@toph2.g_blk.u_gen.p_i.H2_PLAIN ts:- par=port
```

We agree with golden, but **for a structural reason rather than an intended
one**: `emitModuleDefPorts` iterates `body.members()`, which does not contain
gen-scope children, and a gen-scope child's DEF-view `ref_module` ports are built
by a separate SYNTAX-driven loop (`src/ModuleEmit.cpp` ≈ 25410, `MakeRef_module`
under `hinst->connections`). Nothing in the law says the fold stops at a
generate boundary. A later pass that "unified the two loops" on the strength of
the stated law would over-fire on every gen-scope connection in OpenTitan.
**Recommended wording: `… a port connection ON A ref_module BUILT FROM A DIRECT
MEMBER INSTANTIATION …`, with `u_gen` cited as the measured boundary.** No
change to the code is needed or wanted.

**F-4 — LATENT EMPTY PRODUCT: the `ref_typespec` is minted before its actual is
known.** `src/ModuleEmit.cpp`:

```cpp
auto* rt43 = s.MakeRef_typespec();
rt43->VpiFullName(prefix);
rt43->VpiParent(c43);
if (auto poIt43 = pkgParamObj.find(psym43);
    poIt43 != pkgParamObj.end() && poIt43->second->Typespec())
    rt43->Actual_typespec(poIt43->second->Typespec()->Actual_typespec());
c43->Typespec(rt43);
```

If the guard is ever false the object still lands: a `ref_typespec` carrying a
`vpiFullName` and **no `vpiActual`** — a shape golden never prints for this cell.
I could not make it trip in eight new cells (untyped `parameter`, `time`, macro,
scoped macro, doubled, paramod-enclosing, gen-scope, package-declared-last) plus
the pass's own sixteen, so it is **latent, not live**. The safe shape is to
resolve the typespec FIRST and skip the whole fold — or at minimum skip the
`ref_typespec` — when it is absent, rather than emit a half-object. Not a reason
to hold the patch.

**F-5 — LATENT, same class.** `c43->VpiParent((UHDM::BaseClass*)pkc43->
VpiParent())` is unguarded. A `pkgParamConst` constant whose own parent were
null would give the folded constant NO `vpiParent`, where golden always prints
the package `param_assign`. Unexercised in 2 311 databases and six probe files.

**F-6 — REPORT ARITHMETIC.** The DELIVERABLE line says "+1766 lines". The patch
is **+1786**: `git apply --numstat /tmp/r10earl43.patch | awk '{a+=$1;d+=$2}
END{print a,d}'` → `1786 0`. md5 `b4f1470225966385d87acfb0061d8e49`, 93 606
bytes and 15 files are all correct. Cosmetic; stated because a write-up's
numbers are the campaign's ledger.

**F-7 — THE REPORTED COLLISION DOES NOT EXIST AS LANDED, and the boundary is
stronger than reported.** The report flags `r10uvm71` and `r10buvm2` as sharing
`ModuleEmit.cpp`. As landed at HEAD they do not:

```
git diff 5fa6b49 38f308e -- src/ModuleEmit.cpp          -> EMPTY
git diff --stat 5fa6b49 38f308e -- src/                 -> EmitHelpers.h, TaskFuncEmit.cpp, UhdmExporter.cpp
cd <worktree at 38f308e> && git apply --check /tmp/r10earl43.patch  -> clean
```

The patch applies cleanly to **current HEAD `38f308e`** as well as to `5fa6b49`.
Reporting the possible collision was correct practice; the outcome is negative.
ParamEmit.cpp is untouched, so `§ importedConcatNoMdimReorder42`,
`§ caTernOperandRead1`, `§ psBoundPkgParamTs31` / `§ stampFoldedPkgParamTs` /
`makeParamTs`, and `§ fcArgPkgParamValueFolds32` / `aggregateAbstain34` are all
out of reach by file, and the arm evidence in § 5 shows it empirically.

**F-8 — INSTRUMENT CAVEAT, will bite the next verifier.** `canaudit.sh`'s
fence-breach scan excludes only `/README.md$` and itself. A `README.verifier.md`
in the same directory that spells out the four SLANG-FENCED test names is read as
a **FENCE-BREACH** and exits 6. This document therefore refers to them without
naming them, and `canaudit.sh ./canaries.sh ./ctcan2.sh` runs green
(`audited=29 UNCOVERED=0 FENCE-BREACH=0`) with this file present. Carried-forward
defect, not this pass's.

**F-9 — INSTRUMENT CAVEAT.** `grid43.py` writes `out[rec['key']] = rec` with key
`(section, instance-name, port-name)`. Two module defs in `allModules` with a
same-named child collapse to ONE row, silently — the row disappears without the
`GOLDEN_ONLY`/`OURS_ONLY` report the docstring promises. Harmless here (all
probe instance names are unique, and both sides' row counts agree), but the
instrument is weaker than its own header claims. `census43.py` has the same
overwrite, but its key carries the port SPAN, and both sides independently tally
31439 with a 31439-key join and zero one-sided keys, so it is sound as used.

**F-10 — R4 CONFIRMED AND QUANTIFIED, and the pass adds one occurrence.**

```
golden   param_assign  9:27-9:66  x15 ;  9:27-9:67  x0
ours PRISTINE          9:27-9:67  x13
ours PATCHED           9:27-9:67  x14
tl_main_pkg.sv:9 is 67 characters long
```

Our end column is the exclusive one, golden's is the last character's.
Pre-existing, disclosed by the implementer, invisible to `uhdm-cmp` (which does
not follow `vpiParent` — which is why the head advances past this very object),
and now visible inside the head's own subtree. The pass adds the 14th
occurrence because the folded constant back-references that `param_assign`.

---

## 8. RANKED RESIDUES (verifier's list)

**R1 — THE NEW 30-LINE HEAD, `top_earlgrey.sv:628:26`, the SCOPED written
form.** Confirmed verbatim against `r6_nexthead43.cmp` and reproduced in THREE
probes now (`a1_earl43` `u_c2`, `v43_overfire` `u_e8`, and my `v43_h2_cells`
`u_macs` — the same cell reached through a macro, which proves the `::` gate is
textual and holds through macro expansion). Golden's answer is shape-dependent:
scalar → BARE constant (no parent, no ts); aggregate → `ref_obj` with `vpiName` =
the QUALIFIED name, NO `vpiFullName`, `vpiActual` bound to the `parameter`, and
the span of the qualified name only (`628:26-628:38` vs our `628:26-628:65`).
Three defects in one cell, fully decoded. Highest value.

**R2 — package ENUM-TYPED parameters** (`v43_overfire` `u_e6`). Golden folds to
`constant 1`, size 2, ConstType 7, parent + `enum_typespec` ref; we keep a
`ref_obj`. Out of § 0's reach by construction (the package's own Rhs is a
`ref_obj` to the `enum_const`, so it never enters `pkgParamConst`). Zero
Earlgrey population — do not spend an Earlgrey pass on it.

**R3 — NEW, found by this verification: a MACRO-WRITTEN package-parameter actual
loses its written BASE and its `vpiParent` in the ELABORATED view.** Minimal
separating pair, ONE module, `v43_h2_cells.sv`:

```
u_twice1   .p_i (H2_PLAIN)    topModules  G: constant 32'h00008000 par=port   O: same          MATCH
u_mac      .p_i (`H2_BARE)    topModules  G: constant 32'h00008000 par=port   O: constant 32768 par=-   DIFFER
            (`define H2_BARE H2_PLAIN)
```

Two defects in one cell (decompile base, and the missing port parent), present
identically on BOTH binaries, and orthogonal to this pass. `u_time` shows a
third elab shape: golden prints `5000000` for a `time` package parameter where we
print no `vpiDecompile` at all. Earlgrey is macro-dense; this family is worth a
census.

**R4 — the two elab `constant → operation` cells.** Confirmed by my census:
`work@top_earlgrey.u_alert_handler.i_ping_timer` `wait_cyc_mask_i` @87:27-87:51
and `work@top_earlgrey.u_flash_ctrl.u_to_prog_fifo` `rdata_i` @137:18-137:30.
Identical on both binaries. Probe cell `a1_earl43` `u_c7`.

**R5 — our package `param_assign` end column, one too high.** F-10. Costs
multiset distance, invisible to `uhdm-cmp`, and now appears in the head's own
subtree.

**R6 — two probe-only elab cells.** `a1_earl43` `u_c13` (POSITIONAL pkg-param
connection: golden keeps a `ref_obj`, we fold — a PRE-EXISTING elab OVER-fire,
present on the pristine binary) and `u_c8`'s `z_o` span one column high after a
literal written `32'h 00008000`.

**R7 — NOT A RESIDUE, recorded so nobody spends a pass on it.** The gen-scope
def connection (`v43_h2_cells` `u_gen`) MATCHES golden today. F-3.

**R8 — golden-only 238 500 still dwarfs ours-only 70 256.** Earlgrey's remaining
308 756 is overwhelmingly things golden HAS that we do not emit. Unchanged as a
conclusion; this pass moved 11 of it.

---

## 9. FILES ADDED BY THE VERIFIER

| file | what it is |
|---|---|
| `README.verifier.md` | this document |
| `v43_h1_order.sv` | the EMISSION-ORDER probe (package declared LAST) — hypothesis refuted, `PASS_CMP` |
| `v43_h2_cells.sv` | the 8-cell EMPTY-PRODUCT / OVER-FIRE hunt (untyped `parameter`, `time`, macro-bare, macro-scoped, doubled connection, paramod-enclosing module, generate scope) — source of F-3 and R3 |

Both run with the pass's own `arm43.sh` / `grid43.py`, unmodified.
