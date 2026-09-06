# r10vearl109 — ADVERSARIAL VERIFICATION of r10earl109 § `elabPortBoundIntParamTs109`

**VERDICT: ACCEPT WITH FIX.**  Every headline number in
`tools/probe/r10earl109repro/README.md` reproduced bit-for-bit on binaries this
verifier built itself.  One defect was found by a face none of the pass's six
arms carries — the arm overwrote the constant's **encoding** while fixing its
**size** — and is fixed here.  Deliverable
`/tmp/r10earl109.verified.patch`.

Everything in this directory is **MEASUREMENT ONLY**; the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
**LHS is ALWAYS golden.**

* BASE COMMIT `644e74ee`, branch `auto5h`.  Fresh worktrees `/tmp/wt_v109`
  (patched) and `/tmp/wt_v109pris` (pristine), scratch `/tmp/v109_*`.
  `results/*.csv` READ ONLY, no row converted; `GOLDEN_DEFER` unset; the four
  slang-fenced tests never dispatched (`FENCED_REMOVED=0` over 4891 files).

---

## 1. THE PASS'S NUMBERS, REPRODUCED (not read off the report)

Built both binaries from scratch in my own worktrees, `-j 2`, 0 errors:

| binary | md5 | implementer claimed |
|---|---|---|
| pristine `644e74ee` | `4240036c187c394c758e629799b3bd1c` | same |
| `/tmp/r10earl109.patch` applied `git apply -3` to a FRESH `644e74ee` worktree | `0cc21f5211296045f6c32efe344fd9a9` | same |

Both frozen `chmod 555` at `/tmp/v109_pris.bin` and `/tmp/v109_pat.bin`
**before any sweep**; every `cmds.txt` audited by BINARY PATH — 1523 slang
lines per surelog workdir, **0 naming the main-tree binary, 0 naming any
worktree `build/`**.  Fence check on the patch (the four names read out of
`r10earl109repro/canaudit.sh`'s own `FENCED=` line, never spelled here):
**0 / 0 / 0 / 0**.  Patch
surface: `include/UhdmExporter.h`, `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`RESUME.md` §3b and `tools/probe/r10earl109repro/` only.  0 conflict markers.

| claim | reproduced |
|---|---|
| head BEFORE `Earlgrey_0_1/testflags` **48 / 1** | **48 / 1**, and my cmp log is **byte-identical** to the committed `HEAD_BEFORE_Earlgrey_testflags.cmp` |
| head AFTER **176 / 1**, a `hier_path` `Path_elems` head at `xbar_main.sv:97:7` | **176 / 1**, byte-identical to `HEAD_AFTER_Earlgrey_testflags.cmp` |
| the failing field is `VpiSize` 32 vs 64, then a missing `Typespec` | read out of the log myself: golden `vpiSize:32` + `ref_typespec`→`int_typespec`, ours `vpiSize:64` and no typespec; `vpiDecompile:6`, `UINT:6`, `vpiConstType:9` equal on both sides |
| every OTHER row's head log byte-identical | 11 of 12 head logs byte-identical (SeqDriver 33, SimpleUVM 52, Scoreboard/default 95, MiniAmiq 29, BuildUVMPkg 52, Rggen/default 0, **Earlgrey/default 31 — byte-identical although its database moved**); only Earlgrey/testflags changed |
| surelog `byteverify` MOVERS = 2 predicted + the Scoreboard coin | my run: **MOVERS 2 / 956** (the coin did not flip that run) — `./default/Earlgrey_0_1`, `./testflags/Earlgrey_0_1`, `PATH_SETS_IDENTICAL` |
| u2r MOVERS 0 / 1358 | **0 / 1358** |
| Earlgrey attributed at 10 lines each, order-blind, one cell | BOTH modes **unsorted 10, order-blind 10**, and all ten are that one cell: `vpiSize:64`→`:32` plus the `constant`/`ref_typespec`/`int_typespec`/`vpiSigned:1`/`vpiTypespec`/`vpiActual`/`vpiParent` chain at `line:54:17 endln:54:21` (`ATTRIB_Earlgrey_default.diff`) |
| Scoreboard/default = the coin | **92 lines unsorted, 0 ORDER-BLIND** — exactly the documented `vpiTaskFunc` flip |
| wide boundary `LISTED=PROCESSED=4891`, `FENCED_REMOVED=0`, `DIFFERING=20`, rc symmetric | reproduced exactly, with the SAME 20 cells and the SAME rc histogram: `A: 0×9013 3×364 4×389 139×16`, `B` identical |
| `g22.sv` / `l154_noenum.sv` are a layout artifact, not the law | verified independently: the only content line differs at dump line **196**, BELOW `\_weaklyReferenced:` at line **163**, and the two values are **4096** apart (22589177 vs 22593273); `uhdm-cmp` reads `g22` 3438/1 → 3438/1 and `l154_noenum` 17/1 → 17/1 |
| `g5_enc82.sv` TO-GOLDEN 4, `vq.sv` TO-GOLDEN 1, AWAY 0 | reproduced per view: `g5_enc82` **4 / 0 / 0**, `vq` **1 / 0 / 0** |
| the six pass arms score TO-GOLDEN 30 / AWAY 0 / STILL 0, ONLY-GOLDEN 8 / ONLY-OURS 8 | reproduced **exactly**, and `g1` / `g2` / `g6` go to **0 cmp lines / 0 heads** in both views |

---

## 2. THE DEFECT — an axis the pass's arms do not carry

The pass's six arms initialise every admitted `int` parameter with a plain
decimal literal or with `$clog2(...)`.  `analyzeParamEnc`
(`src/ParamEmit.cpp:20060`) marks **neither**, so `paramIntEnc` was empty for
every cell the grid measured, and the arm's hard-coded `vpiUIntConst` /
`UINT:<digits>` was never contradicted.

`vA_enc109.sv` supplies the missing axis: an `int` localparam per
`paramIntEnc` FORM, on an elaborated port, in a STALE-scope module (`u_s`,
which instantiates a leaf so `currentScope` has moved on) and in a HOME module
(`u_h`, no child, so `currentScope` is still right) **side by side**, both
views.

| written init | pristine | r10earl109 as shipped | golden |
|---|---|---|---|
| `MaxB/8` (`/`) HOME `b_div_i` | sz 64, `INT:8`, **ct 7** | sz 32, `UINT:8`, **ct 9** | sz 32, `INT:8`, **ct 7**, ts SIGNED |
| `MaxB%58` (`%`) HOME `b_mod_i` | sz 64, `INT:6`, ct 7 | sz 32, `UINT:6`, ct 9 | sz 32, `INT:6`, ct 7, ts SIGNED |
| `2**3` (signed `**`) HOME `b_pow_i` | sz 64, `INT:8`, ct 7 | sz 32, `UINT:8`, ct 9 | sz 32, `INT:8`, ct 7, ts SIGNED |
| `MaxB-58` (`X-1` form) HOME `b_sub_i` | sz 64, `INT:6`, ct 7 | sz 32, `UINT:6`, ct 9 | sz 32, `INT:6`, ct 7, ts SIGNED |
| `2 - 3` → **−1** (`vC_carr109` `c_neg_i`) | sz 64, `UINT:-1`, ct 9 | sz 32, `UINT:-1`, ct 9 | sz 32, `INT:-1`, ct 7, ts SIGNED |

`constant::Compare` **reads `VpiConstType`** (it is field 7 of the pass's own
decode table), so the four HOME rows are a RIGHT field overwritten with a
WRONG one.  No database flips — the size failed first in every one of those
cells, so neither binary is EQUAL there — but the cell moves from one wrong
shape to a differently wrong one, which is precisely the MOVED-WRONG the law's
own based-literal clause exists to refuse.  The negative row is the same bug
wearing a different hat: `2 - 3` is the SUBTRACT form `analyzeParamEnc` marks.

Score on `vA`+`vB`+`vC`, both views, r10earl109 as shipped:
**TO-GOLDEN 96 / AWAY-GOLDEN 0 / STILL-WRONG 28** (`SCORE_firstrev.txt`).

### THE FIX (minimal, in the arm only)

```
  bool ie109 = false;
  if (auto iet109 = paramIntEnc.find(ip109); iet109 != paramIntEnc.end())
      ie109 = iet109->second;
  c->VpiSize((int32_t)ip109->getType().getBitWidth());
  c->VpiConstType(ie109 ? vpiIntConst : vpiUIntConst);
  c->VpiValue((ie109 ? "INT:" : "UINT:") + digits);
```

**Only the SIZE and the ts ref are this law's.**  The `INT`/ct 7 vs `UINT`/ct 9
pick belongs to § `defNetBoundPkgIntEnc`, which reads exactly this map at
`src/TypeEmit.cpp` ~501 for a package parameter's bound; the arm now asks the
same question of the parameter its own scope lookup resolved.

Fixed binary md5 `2b8ea97563f2f1860c8872777dfc260e`, frozen at
`/tmp/v109_fix.bin` before any sweep.

---

## 3. THE ARMS (`vA`–`vD`, both views, six modules, four instance counts)

| arm | axis |
|---|---|
| `vA_enc109` | the five `paramIntEnc` FORMS (`/`, `%`, signed `**`, `X-1`, `*`) as an elaborated port's bare bound, once in a STALE-scope module and once in a HOME module — the arm that convicted the encoding clobber |
| `vB_inst109` | **THREE INSTANCES** of one definition with different overrides (`#(16)`, `#(256)`, DEFAULT — the § `boundOverriddenParamWidth24` trap of a default instance whose sibling is overridden), plus a FOURTH one level DEEPER under a wrapper; each names the same `localparam int PktC = $clog2(MaxC)` whose value differs per instance; the same parameter on the LEFT, on the RIGHT and as **BOTH bounds of one range** |
| `vC_carr109` | carriers and values: a NON-overridden top-level `parameter int` (the pass's `g3` has only an OVERRIDDEN one), a NEGATIVE folded bound, a multi-digit value, 2-D packed with the law's bound OUTER and INNER, packed+UNPACKED, `output`, `inout`, a `var` port, a package NAMED-TYPEDEF port, and child instances inside a **generate-IF** and a **generate-FOR** |
| `vD_alias109` | type SPELLINGS that canonicalise to `int` without being the keyword: a `typedef int`, an `enum` whose base is `int`, plus an INTERFACE port carrying the law's written bound |

Scores with the FIXED binary (`SCORE_fixed.txt`), per view × 4 arms:

```
TOTAL  BOTH-SAME 502  TO-GOLDEN 124  AWAY-GOLDEN 0  STILL-WRONG 4  UNMOVED-WRONG 114
       vA 8/0/2   vB 16/0/0   vC 36/0/0   vD 2/0/0        (per view)
```

versus **96 / 0 / 28** for the same three arms as shipped: the fix converts 24
cells and removes 24 MOVED-WRONGs.  **AWAY-GOLDEN is 0 in every arm, both
binaries** — the pass introduces no regression on any face tried.

What the arms SETTLED, each measured rather than assumed:

* **Per-instance is real.** `vB`'s three instances fold `PktC` at 4, 8 and 6
  respectively, each at size 32 with the bare signed ts ref: `internal->
  getParentScope()` is per-instance by construction, and the deeper fourth
  instance behaves identically.  16 TO-GOLDEN per view, 0 AWAY.
* **A typedef-of-`int` IS admitted and golden agrees** (`vD` `d_td_i`
  TO-GOLDEN): golden gives a `typedef int` parameter's port bound the same
  size 32 + signed `int_typespec` a bare `int` gets, so the gate's
  "non-`ImplicitType` type syntax" test is the right shape of test.
* **An ENUM-typed parameter is correctly refused** (`vD` `d_en_i`: golden has
  NO ts ref there and both binaries agree — the canonical-type test excludes
  it before the type-syntax test is reached).
* **Generate scopes are not special.** A child instance inside `if`/`for`
  gets the same fold as one in the module body (`vC` `u_g.g_if.u_gi`,
  `g_for[0..1].u_gf`), because the gate asks about the PARAMETER's scope
  (`InstanceBody`), not the instance's.
* **Every carrier golden gives the payload, we now give** — `input`,
  `output`, `inout`, `var`, both dimensions of a 2-D packed type, the packed
  half of a packed+unpacked declaration.
* **The nested build does not leak.** A port typed by a package named typedef
  builds its typespec recursively under the same flag; both binaries leave it
  UNMOVED (`vC` `u_t.u_td.d_i`) — a pre-existing residue of another family,
  untouched.

---

## 4. GATES, all on the FIXED binary

| gate | result |
|---|---|
| build, md5 | pristine `4240036c187c394c758e629799b3bd1c`, as-shipped `0cc21f5211296045f6c32efe344fd9a9`, fixed `2b8ea97563f2f1860c8872777dfc260e`; 0 compile errors |
| goldens | **23 PASS / 0 FAIL** (fixed) and 23/0 (pristine); negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| u2r status both modes | CMP_EQUAL **679** / SLANG_REJECT **50** / SURELOG_FAIL **2**, both modes, unchanged from pristine |
| surelog histogram | default 471/283/25/10/5, testflags 466/284/23/9/5/3/2/1/1 — **identical to pristine**, so no rc=139 hid as a SLANG_REJECT |
| `ct8rows` ×5 | surelog vs committed baseline **PASS**; surelog vs own pristine **PASS**; u2r tf vs committed **PASS**; u2r tf and def vs own pristine **PASS**.  **NO ROW CONVERTED**, `results/*.csv` untouched |
| `byteverify SELFCHECK=1` surelog, fixed vs pristine | **MOVERS 3 / 956** = the 2 predicted Earlgrey + the Scoreboard/default coin; `PATH_SETS_IDENTICAL`, selfcheck 955/956 |
| `byteverify` surelog, **fixed vs as-shipped** | **MOVERS 1 / 956 — only the Scoreboard coin.**  The two Earlgrey databases are BYTE-IDENTICAL between the two patched binaries: the encoding fix touches ZERO corpus cells, because the head's `localparam int PktW = $clog2(...)` is a system call `analyzeParamEnc` does not mark |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1358** |
| attribution | `Earlgrey/default` **and** `Earlgrey/testflags` each 10 lines unsorted, **10 order-blind**, all one cell (`ATTRIB_Earlgrey_{default,testflags}.diff`); `Scoreboard/default` 92 unsorted, **0 order-blind** (the coin) |
| heads | 11 of 12 byte-identical; only `Earlgrey_0_1/testflags` **48 → 176, one head** |
| canaries | surelog `ok=52 changed=0 absent=0`; u2r `ok=8 changed=0 absent=0` |
| `ctcan2` | PASS (surelog `EXPECT_UNKNOWN=1`) and PASS (u2r `EXPECT_UNKNOWN=6`) |
| `canaudit.sh canaries.sh ctcan2.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| protected pins | all **10 SAME**: InterfaceModPort `59a365f3ce2c`, BlackParrotComplex, YosysOldOr, **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** |
| wide boundary | `LISTED=PROCESSED=4891  FENCED_REMOVED=0  identical=9382  DIFFERING=20  no_output=380`; rc by side symmetric (`0×9013 3×364 4×389 139×16` on BOTH), ASYMMETRY 0 — the **same 20 cells** as the as-shipped run, so the fix adds no boundary motion |

---

## 5. RESIDUES the verification named

* **R6 (NEW, PRE-EXISTING — not this pass's).** `analyzeParamEnc` marks `/`,
  `%`, a signed `**` and the `X-1` SUBTRACT form, but **not `*` and not `+`**.
  `localparam int M = 3 * 2` reads golden `INT:6` / ct 7 while BOTH binaries
  write `UINT:6` / ct 9 (`vA_enc109` `b_mul_i`, `a_mul_i` — the only 4
  STILL-WRONG cells left in the arms, and pristine is wrong there too).  That
  is § `defNetBoundPkgIntEnc`'s own encoding rule, reachable from the package
  bound builder and the net builder as well as this arm; ZERO corpus cells
  today.  Its own pass.
* **The pass's own R1–R5 stand as written** and were re-measured here: the
  non-`int` net encodings (R1), their port mirrors (R2), the instance-array
  element port that `sharedTypespec` supplies before the call site (R3), the
  struct member bound golden keeps symbolic (R4), and our duplicate elaborated
  `port` object (R5).
* **R0 stands**: `Earlgrey_0_1/testflags` 176 lines, one head — the
  `hier_path` `Path_elems` size mismatch at `xbar_main.sv:97:7`.  Log
  committed here as `HEAD_AFTER_Earlgrey_testflags.cmp` as well.

---

## 6. FILE MAP

| file | what it is |
|---|---|
| `vA_enc109.sv` … `vD_alias109.sv`, `TOPS.txt` | the four adversarial arms; drive them with `r10earl109repro/grid109.sh` (`ARM_DIR=` this directory) |
| `SCORE_firstrev.txt` | `score109.py` on `vA`/`vB`/`vC` with the patch AS SHIPPED — the 28 STILL-WRONG cells, the defect in full |
| `SCORE_fixed.txt` | the same arms plus `vD` with the FIXED binary — 124 / 0 / 4 |
| `SCORE_passarms_fixed.txt` | the pass's own six arms re-scored with the FIXED binary — 30 / 0 / 0, unchanged |
| `SCORE_boundaryarms_fixed.txt` | `r10earl82repro/g5_enc82.sv` and `r10earl_repro/vq.sv` re-judged against their own goldens with the FIXED binary — 4 / 0 / 0 and 1 / 0 / 0 |
| `BOUNDARY_WIDE.{tally,rc_by_side,diff}` | the wide boundary on the FIXED binary |
| `ATTRIB_Earlgrey_{default,testflags}.diff` | the order-blind whole-dump attribution of both Earlgrey movers — ten lines each, one cell each |
| `HEAD_{BEFORE,AFTER}_Earlgrey_testflags.cmp` | the head logs this verifier measured (byte-identical to the pass's own) |
