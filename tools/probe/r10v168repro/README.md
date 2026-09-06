# r10v168 — ADVERSARIAL VERIFICATION of r10uvm168 § `enumOriginConstTypeIsTheMemberValue168`

**VERDICT: ACCEPT.** The patch `/tmp/r10uvm168.patch` (md5
`f803460920aafb75612f27516d08ac83`) is correct as written. Every headline
number in the implementer's report reproduces **bit-for-bit** from independent
worktrees and independently built binaries, and 1074 fresh adversarial grid
cells across six new arms found **0 AWAY and 0 MOVED-WRONG** on the field the
law owns. No fix was needed, so the production surface of this patch is
UNCHANGED; this directory adds only verifier evidence.

**MEASUREMENT-ONLY.** slang was not patched. `results/*.csv` were read only.
Nothing was promoted, **NO CORPUS ROW CONVERTED**, `GOLDEN_DEFER` stayed unset,
and the four slang-fenced tests were never dispatched (they are named only in
the env `FENCED=` input to `predict168.py`, never in an artifact here).
**LHS is always golden (Surelog); RHS is always ours.**

| | |
|---|---|
| BASE | `39f286ef` |
| verifier worktrees | `/tmp/wt_v168` (patched), `/tmp/wt_v168pris` (pristine) — both `git worktree add … 39f286ef`, built independently |
| pristine binary | md5 **`5bfd7087944d0a2a32585d54a9bbe1e3`** — the implementer's number, reproduced |
| patched binary | md5 **`123e8379e93105f9091763d030eda09e`** — the implementer's number, reproduced |
| verifier surface | `tools/probe/r10v168repro/` only |

---

## 1. WHAT REPRODUCED BIT-FOR-BIT

| claim | implementer | verifier (independent build + sweep) |
|---|---|---|
| pristine binary md5 | `5bfd7087…e1e3` | **same** |
| patched binary md5 | `123e8379…a09e` | **same** |
| goldens | 23/0, `/bin/false` 0/23 | **same**, both binaries |
| BuildUVMPkg head | 60 → 106 cmp lines, ONE head, both modes byte-identical | **same** |
| pristine head log md5 | `5315640cf76c3304a75dece1884b10c6` | **same** |
| patched head log md5 | `bc812ae88196732fccc89625149c9abc` | **same** |
| every other row | SeqDriver/SimpleUVM 338, Scoreboard/default 95, MiniAmiq 106, Earlgrey 31/50, Rggen CMP_EQUAL | **same** |
| BuildUVMPkg dump diff | exactly two lines | **exactly two lines** of 1 077 633 |
| surelog byte movers | the two PREDICTED BuildUVMPkg rows (+ the Scoreboard coin) | **2/956**, exactly those two; the coin did not flip on this run |
| u2r byte movers | 0/1358 | **0/1358** |
| census param_assign ct-diff | 2 → 0 over 38 378 | **2 → 0**, agree 38378→38380, other-diff 30→30, only-golden 5836→5836, only-ours 6089→6089 |
| census whole-design constants | +2 agreeing / −2 one-sided per side | **both 756943→756945, only-golden 400962→400960, only-ours 211087→211085** |
| u2r census | 0 → 0 over 67 122 | **0 → 0 over 67 122** |
| grid (implementer's 4 arms, 825 cells) | ct 124 T / 0 A / 0 MW; rest 14 T / 0 / 0; arm D 252 unmoved | **ct 42+40+42+0 = 124 T / 0 A / 0 MW; rest 2+0+12+0 = 14 T / 0 / 0; arm D unmoved** |
| FLOOR (r10uvm159 + r10earl104, 20 arms) | 0/0/0 every arm | **0/0/0 every arm**, same ONLY-GOLDEN/ONLY-OURS counts |
| wide boundary | 4721 arms, PROCESSED==LISTED, RC_DIFFS 0, MOVED_ARMS 14 | **4726 arms** (4721 + this directory's six, one of which must not move), **PROCESSED==LISTED==4726, RC_DIFFS 0, MOVED_ARMS 18** = 14 + the four of mine that carry the law's population |
| other passes' moved arms | 22 cells, all TOWARD | **22 cells across the same nine arms, all TOWARD, 0 AWAY, 0 MOVED-WRONG in all three projections** |
| r10uvm154's address residue | binary-image-driven, below `\_weaklyReferenced:` | **confirmed**: pristine `22548185`, patched `22556409`, and the PATCHED binary with `R10E168_OFF=1` also prints `22556409`; both constants sit below `\_weaklyReferenced:`; `uhdm-cmp` logs on `g22.sv` are **BYTE-IDENTICAL** under both binaries, one head |
| ct168own ablation | const type was the whole head; NEXT head `unsupported_typespec(uvm_severity)` | **byte-identical output**, every id and count |
| judge decode | `constant::Compare` reads exactly `VpiConstType` | **confirmed at `~/git-repos/UHDM/build/generated/src/constant.cpp:57-71`** |
| Surelog decode | `CompileHelper.cpp:809-871` auto member → `Value::Type::Integer`; `fromVpiValue` matrix | **confirmed by reading both** |
| a-priori prediction | only `arm=AUTO` firings in either corpus are the two BuildUVMPkg rows | **re-run independently: surelog 6 firings = AUTO×2 (BuildUVMPkg ×2) + BIN×4 pre-existing; u2r 8 firings, ALL pre-existing, ZERO new-arm** |
| gates | all green, no row converted | **all green: ct8rows PASS ×5, 0 differing rows over 1588, histograms identical cell-for-cell, canaries ok=52/ok=8 changed=0, ctcan2 PASS×2, canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`** |

Two small corrections to the write-up, neither affecting a number:
* the u2r prediction's pre-existing firings are `arm=HEX` (8 of them), not
  `arm=BIN`; the substance — zero new-arm firings, zero movers — is intact.
* `uhdm-cmp` on `r10buvm22repro/g22.sv` reads **1719** lines / 1 head here (the
  report says 3438 = 2×1719); the load-bearing fact, that the two binaries'
  cmp logs are **byte-identical**, holds.

## 2. THE ADVERSARIAL GRID — SIX NEW ARMS, 1074 CELLS, ZERO AWAY

Written from the brief's face list, not from the implementer's arms; no name,
order, width or number is shared with `g168_*.sv`.

| arm | face | cells | `ct` (the owned field) | `rest` | negative controls |
|---|---|---|---|---|---|
| `v1_width168.sv` | enum BASE width 1,2,7,8,9,31,32,33,63,64,96,128; signed vs unsigned vs a TYPEDEF'd base (`bit[7:0]`, `logic signed[7:0]`, `int`); values AT the width boundary (2³¹, 2³², 2⁶³, all-ones, wrap-to-zero); an auto member directly after a hex / binary / octal member | 132 | **48 T / 0 A / 0 MW** | 4 T / 0 / 0 | — |
| `v2_path168.sv` | HOW the parameter reaches the member: direct, 1/2/3 parameter hops, parenthesised, `int'()`/`8'()`/nested/`signed'()`/`unsigned'()` casts, `+ − * −x |` folds, concat, ternary, `pkg::` scoped, wildcard-imported; × the parameter's own type (enum typedef, `int`, `integer`, `byte`, `shortint`, `longint`, `bit`, `bit[3:0]`, `logic[7:0]`, `bit signed[15:0]`, `bit[63:0]`, `logic signed[63:0]`, untyped); `parameter` vs `localparam`; string / real / shortreal / realtime controls | 204 | **58 T / 0 A / 0 MW** | 0 / 0 / 0 | — |
| `v3_home168.sv` | HOMES: package, package-importing-package, `$unit`, interface, module (own / wildcard-import / explicit-import copies), a child instance's parameter ACTUAL, flat and nested generate scopes, a genvar loop, a class in a package, a class in a module, a function scope | 274 | **32 T / 0 A / 0 MW** | 10 T / 0 / 0 | — |
| `v4_neg168.sv` | NEGATIVE CONTROLS: literals of every base and sign, `'z`/`'1`, string/real/time, parameter chains that never reach an enum, packed struct / unpacked array / typedef'd parameters, an enum reached only through a cast or an operation, module-LOCAL parameters, two `specparam`s | 112 | **0 / 0 / 0** | 0 / 0 / 0 | **nothing moved at all, in any projection** |
| `v5_form168.sv` | THE AWAY HUNT — every written member form `fromVpiValue` switches on that arm A did not spell: UNSIZED `'d`/`'o`/`'b`/`'h`; SIGNED `8'sd`/`8'sh`/`8'so`/`8'sb`; underscore-separated digits; UPPER-CASE `'D`/`'H`/`'O`/`'B`; the `SCAL:` path (`1'bz`, `1'bx`, `4'b1z0x`); members initialised from another parameter, from an arithmetic over an earlier member, from a cast, from a negative literal, from a parenthesised literal; and the auto member after each | 160 | **50 T / 0 A / 0 MW** | 6 T / 0 / 0 | — |
| `v6_inst168.sv` | INSTANCE COUNT: the same package parameters read through 1, 2 and 3 instances of one module, plus three generate-loop replications | 192 | **32 T / 0 A / 0 MW** | 24 T / 0 / 0 | — |
| | | **1074** | **220 TOWARD / 0 AWAY / 0 MOVED-WRONG** | 44 T / 0 / 0 | |

The eight `full`-column MOVED-WRONG cells (6 in v1, 2 in v6) are **not**
regressions and are the reason the scorer has three columns: in every one the
const type moved TOWARD golden while a PRE-EXISTING `vpiSize`/`vpiDecompile`
disagreement stayed exactly where it was on both binaries. They are named in §4.

## 3. WHAT I TRIED TO BREAK AND COULD NOT

* **The AUTO arm has no `litInit168` guard** — it fires on *any* member with no
  written initializer, whatever precedes it. I read
  `CompileHelper::compileTypeDef`'s enum arm
  (`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:819-871`) and the
  fallback is unconditional: `value == nullptr` → `value->set(val,
  Value::Type::Integer, baseSize)`. Measured on auto members following a hex,
  a binary, an octal, a based-decimal, an unsized-decimal, a negative, a cast
  and an arithmetic member — golden is `vpiIntConst` in every one. No AWAY.
* **The octal overflow guard** `ov > (~0ull >> 3)` is exactly tight for 64
  bits: `64'o1777777777777777777777` recodes to `UINT:18446744073709551615`,
  matching golden's decompile and const type (v1 cell `w_w64_oct`).
* **Values ≥ 2⁶³.** The `INT:` re-prefix writes `INT:9223372036854775808`, which
  **UHDM's own value storage renders back as `INT:0`** — and golden reads
  `INT:0` there too, so ours moves *toward* golden on `VpiValue` as well. This
  is a UHDM round-trip property, not a slang-uhdm one: the pristine binary's
  `enum_const` at the same site already prints `INT:0`. Verified with
  `R10E168_DBG=1`, which shows the correct string being written.
* **`paramOriginBaseRecode` cannot lose a cell.** Its walk `break`s the moment
  the chain reaches a non-`ParameterSymbol`, so it returned false on every
  enum-landing chain before this pass; the three new arms can only take cells
  it never had. Read and confirmed at `src/ParamEmit.cpp:19915-19972`.
* **No new AST forcing.** `evSym->getInitializer()` is the same call the
  pristine code made, and the call site is gated on `topView`, so the DEF-phase
  Heisenbug (RESUME §9) is not in reach.
* **Casts really do break the chain in golden.** `int'()`, `8'()`, `signed'()`,
  `unsigned'()` and a nested cast all read `vpiUIntConst` on the golden side —
  the law declines on all five, correctly (v2 v221–v225).
* **1/2/3 instances agree cell-for-cell** (v6): the recode is per parameter, not
  per emission.

## 4. RESIDUES I MEASURED THAT THE IMPLEMENTER DID NOT NAME

None is a regression; each is identical on both binaries. Ranked by how many
judged fields they touch.

1. **R-sepcase — the PRE-EXISTING hex/binary arm keeps the source's `_`
   separators and base CASE, and up-cases hex digits; golden does none of
   these.** `16'HaB_cD` → ours `HEX:AB_CD`, decompile `16'HaB_cD`; golden
   `HEX:aBcD`, decompile `16'haBcD`. Same for `8'sh1F` (ours keeps the `s`),
   `16'B1010_0101…`, `128'h1234_5678_…`. **`VpiDecompile` IS judged**, so
   these are live NE cells. They sit in the very function this pass edits
   (`enumOriginHexRecode`), and the sibling `paramOriginBaseRecode` already
   calls `stripSep` — the asymmetry is the bug. v1 `w_w64_hex`/`w_w128_hx`,
   v5 `f_sh`/`f_sb`/`f_uch`/`f_ucb`. **The best next candidate on this site.**
2. **R-genscope-ct** — a generate-scope or `$unit` localparam folded from an
   auto-numbered enum member keeps ct 9 where golden has ct 7. The
   `(inPackage || isImported)` gate excludes them by construction. v3
   `h_gen_auto`/`h_nest_auto`/`h_loop_int`/`h_unit_auto`, v6 `g_rep[*].g_bdec`.
   0 corpus cells today.
3. **R-defviewoct** — in a module's DEFINITION listing an octal-member copy
   keeps `OCT:` / ct 4 while golden has `UINT:` / ct 9; the `topView` gate
   keeps this law to the elaborated view. v6 `work@Cantle_two.i_oct`.
4. **R-addfold is WIDER than reported.** The implementer named `ENUM + 1`.
   Measured here, golden also reads ct 7 (and we ct 9) for `signed'(MEMBER)`,
   `unsigned'(MEMBER)`, a TERNARY over members, and `MEMBER | 0` — v2
   `cst_sgn`/`cst_uns`/`ar_tern`/`ar_add`, v4 `n_op`.
5. **The report's "an ARITHMETIC member stays unsigned" is only sometimes
   true**, and the implementer's `litInit168` guard is therefore a deliberate
   *under*-approximation rather than an exact model. Cell v5 `f_mref`
   (`SIRIH_B = SIRIH_A + 8'd1`) reads golden ct **7** and ours 9 — a MISS the
   guard creates. Cell a30 (`KELP_STEP = KELP_BASE + 4`) reads golden ct 9,
   where declining is right. Which way it goes is decided by the reduced
   constant's own `VpiValue` prefix, which the guard cannot see from the AST.
   Conservative is the right call here (it is what keeps AWAY at 0), but the
   model sentence should say *declines on arithmetic members* rather than
   *golden stays unsigned*.
6. **R-wide64dec** — at |value| ≥ 2⁶³ the folded constant's `VpiDecompile`
   stays the unsigned decimal while golden re-renders the signed/masked one
   (v1 `w_w32_aut` golden `-2147483647`, `w_w64_aut` golden `1`). Pre-existing
   and unmoved; `VpiDecompile` is judged, so these are live NE cells.
7. Confirmed as stated by the implementer: **R-uintmask**, **R-untypedsize**
   (v2 `p_untyped`: golden ct 7 size 32, ours ct 9 size 64 — the `typedParam`
   gate keeps the law off it deliberately), **R-defmodsize** (the eight `full`
   MOVED-WRONG cells here), **R-xzenum** (v5 `f_scz`/`f_scx`/`f_mxz`: golden
   folds `BIN:z`/`BIN:X`/`BIN:1z0x`, we keep a `ref_obj`), **R-addrbound**.

An unrelated pre-existing gap found while writing the arms and recorded so the
next pass does not rediscover it: **a NAMED-TYPE cast in a package parameter
initializer (`bosk_e'(X)`, `dozen_v_t'(X)`) makes slang-uhdm bail with
`expression kind: Invalid` on BOTH binaries at BASE `39f286ef`.**

## 5. NITS IN THE PRODUCTION CODE (none blocking)

* `off168` is `getenv("R10E168_OFF") != nullptr`, so `R10E168_OFF=0` also
  disables the law, while `dbg168` correctly treats `"0"` as off. Every
  document says `=1`, so nothing measured here is affected.
* the `ctBefore168`/`vBefore168`/`dBefore168` snapshot is taken unconditionally
  (three `std::string` constructions) even when `R10E168_DBG` is unset. It runs
  only for constants whose chain already landed on an enum member, so the cost
  is bounded; the comment's own "`getenv` in a per-parameter loop is not free"
  argument applies to it too.

## 6. FILES HERE

| file | what it is |
|---|---|
| `v1_width168.sv` … `v6_inst168.sv` | the six adversarial arms of §2 |
| `GRID.r10v168.txt` | all three projections for all six arms |
| `FLOOR.r10v168.txt` | the verifier's own run of `floor168.sh` over this pass's arms + r10uvm159's + r10earl104's 20 committed arms |
| `BOUNDARY.r10v168.txt` | the verifier's own 4726-arm boundary walk and its MOVERS list |
| `ATTRIB.r10v168.txt` | all three projections for every non-control moved arm |
| `GATES.r10v168.txt` | every gate number re-measured, with the cmds.txt audit and the a-priori prediction |

Instruments used are the implementer's, run against the verifier's own frozen
binaries: `grid168.sh`, `score168.sh`, `cen168.py`, `ct168cen.cpp`,
`ct168own.cpp`, `floor168.sh`, `bound168.sh`, `predict168.py`, plus the standard
battery (`ct8rows.sh`, `byteverify.sh`, `rowheads.sh`, `canaries.sh`,
`ctcan2.sh`, `canaudit.sh`).
