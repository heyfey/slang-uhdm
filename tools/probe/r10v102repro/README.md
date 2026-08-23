# r10v102 — adversarial verification of r10uvm102 (§ implicitUnsizedBasedNoTs102)

Verifier worktrees `wt_v102` (ship) and `wt_v102pris` (pristine), both at base
`ecdded75`.  Both binaries built here, `-j 2`, Release:

    pristine  9ae62f2d6a19f72cf5cb259847914b9a   (== the master's control binary)
    ship      4e1d739b21bf097f2c21e66889b765b6   (== the implementer's claimed MD5)

Reproduced bit-for-bit from a clean apply of the patch onto a fresh `ecdded75`
worktree, so the build is deterministic and the shipped binary is the one the
gates below measure.  Both binaries were frozen (`chmod 555` copies) before any
sweep, and every `cmds.txt` was audited by binary PATH.

VERDICT: **ACCEPT (no fix needed).**  No pristine-right -> patched-wrong cell
was found on any legal SystemVerilog shape.  What the pass claims is right; what
it fences off is NOT what golden does — those fences are residues, not laws (see
§ Residues).

---

## 1. The head, decoded here (not carried forward)

`uhdm-cmp` head, SeqDriver, PRISTINE, both modes (`head_before_SeqDriver_*.cmp`):

    LHS: <null>
    RHS:
    decompile:
    ref_typespec: (uvm_pkg::UVM_ALL_ON), id:6116
    |vpiParent:
    \_parameter: (uvm_pkg::UVM_ALL_ON), id:6115, line:181:11, endln:181:21
    |vpiFullName:uvm_pkg::UVM_ALL_ON
    |vpiActual:
    \_int_typespec: , id:6120, line:181:1, endln:181:46

LHS is golden.  `LHS: <null>` with a full RHS is the SINGULAR `SafeCompare`
overload naming OUR value: the field is `expr::Typespec` inherited by
`parameter` (`~/.local/include/uhdm/expr.h:70`), reached from
`parameter::Compare` -> `simple_expr` -> `expr::Compare`
(`~/git-repos/UHDM/build/generated/src/expr.cpp:100`).  Golden carries NO
declaration typespec on the parameter; we carried a `ref_typespec` ->
`int_typespec`.

The declaration is `uvm-1.2/src/base/uvm_object_globals.svh:181`:

    parameter UVM_ALL_ON      = 'b000000101010101;

untyped, unranged, unsigned, non-overridden, initialised by an UNSIZED binary
literal.  Confirmed at the source by a fresh two-binary dump on a one-line
module (`a01_basic.sv`): golden emits the parameter with no `vpiTypespec`
child, pristine emits `ref_typespec -> int_typespec`.

---

## 2. Gates (all re-run here, nothing carried forward)

| gate | result |
|---|---|
| build both, md5s | pristine `9ae62f2d…`, ship `4e1d739b…` (claimed MD5 reproduced) |
| `check_goldens.sh` (SLANG_UHDM=ship) | PASS=23 FAIL=0 |
| negative control (`SLANG_UHDM=/bin/false`) | PASS=0 FAIL=23 |
| `cmds.txt` audit, surelog | 1573 files, 1523 `slang:` lines, **all** `/tmp/v102_bin/ship.bin` |
| `cmds.txt` audit, uhdm2rtlil | 1462 files, 1458 `slang:` lines, **all** `/tmp/v102_bin/ship.bin` |
| surelog rows | 1588; `ct8rows` vs `results/golden_surelog.csv` **PASS** (0 differing rows, status AND dump); vs the `ecdded75` control **PASS** |
| uhdm2rtlil testflags | 731 rows; vs `results/gate_uhdm2rtlil.csv` **PASS**; vs control **PASS** |
| uhdm2rtlil default | 731 rows; vs control **PASS** |
| **no conversion claimed and none observed** | the 10/9 CMP_NOTEQUAL rows are unchanged |
| surelog byte movers | **9 / 956**, every one PREDICTED BY NAME before the sweep (§3) |
| uhdm2rtlil byte movers | **0 / 1358**, `SELFCHECK` 1357/1358 flagged |
| canaries (surelog / u2r tf / u2r def) | ok=56 / 9 / 9, **changed=0 absent=0** |
| ctcan2 (surelog / u2r tf / u2r def) | ok=58 / 1 / 1, **changed=0**, PASS |
| canaudit | audited=29 **UNCOVERED=0 FENCE-BREACH=0** PASS |
| named pins | **SAME=10 MOVED=0** — InterfaceModPort, BlackParrotComplex, YosysOldOr byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| fence check on the patch | the four brief-fenced test names — 0 hits each |
| patch collateral | surface is `src/ParamEmit.cpp` + `tools/probe/r10uvm102repro/` only; no `results/*.csv` edit; the shipped driver hard-codes no other pass's paths and has no `rm -rf` on shared scratch |

Status histograms (both reproduced exactly):

    surelog default   CMP_EQUAL 471  CMP_NOTEQUAL 10  SLANG_REJECT 283  SURELOG_FAIL 25  DEFERRED 5
    surelog testflags CMP_EQUAL 466  CMP_NOTEQUAL  9  SLANG_REJECT 284  SURELOG_FAIL 23  DEFERRED 5
                      NO_DATABASE 3  UNTRANSLATABLE 2  TIMEOUT 1  NO_UHDM 1
    u2r default/testflags  CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2   (each)

Official protected heads (`rowheads.sh`), pristine -> ship:

    SeqDriver     17 -> 64   both modes, ONE head each
    SimpleUVM    108 -> 108  MiniAmiq 348 -> 348   BuildUVMPkg 72 -> 72
    Scoreboard   108 -> 108 (default; testflags has no database)
    Earlgrey_0_1  46 -> 46   Rggen 0 -> 0 (default; testflags has no database)

Every unchanged head was also checked TEXTUALLY (id-normalised diff of the cmp
output): all nine are byte-identical to pristine.  A head COUNT that holds is
not proof the head held.

---

## 3. A-priori mover prediction (made from pristine state, before the sweep)

The predicate can only fire on an untyped, unranged parameter whose default is
an unsized based literal.  Grepping the whole Surelog corpus for that
declaration shape names 16 files; grepping the uhdm2rtlil corpus names **none**
(its single candidate, `rp32/hamster/r5p_hamster.sv:44`
`logic [32-1:0] PC0 = 'h0000_0000`, is both typed and ranged).  Intersecting the
16 files with the tests that actually COMPILE them (read out of each control
`cmds.txt`, not guessed) predicts exactly nine databases:

    default:   BuildUVMPkg  MiniAmiq  Scoreboard  SeqDriver  SimpleUVM
    testflags: BuildUVMPkg  MiniAmiq             SeqDriver  SimpleUVM

`byteverify.sh` then reported exactly those nine and no others.  The
black-parrot / ariane / NyuziProcessor / OVM files carrying the same shape are
reachable only from `SLANG_REJECT` / `SURELOG_FAIL` rows or through `+incdir+`
without being included, which is why `BlackParrotComplex` (a canary) is
untouched.

Mover ATTRIBUTION (path- and id-normalised, SORTED whole-dump diff, so
order-blind — `attr102.sh`): every changed line in all nine is the removal of a
`ref_typespec -> int_typespec` from one of four package parameters,

    uvm_pkg::UVM_ALL_ON  UVM_DEFAULT  UVM_FLAGS_ON   (uvm_object_globals.svh:180-182)
    uvm_pkg::UVM_RADIX                               (uvm_object_globals.svh:99)

plus the `int_typespec`'s own `range` / bound constants, plus a small GAIN of
top-level `\_ref_typespec:` lines in the dump's `weaklyReferenced` tail (the
`prt` object is still minted, only not attached) — unreachable to the judge.
`Scoreboard/default` is the ~50/50 coin; its order-blind diff is 88 lines and
ALL of them are the law's, so its byte move is attributed, not assumed.

---

## 4. Adversarial grid — 21 arms x 2 views (`ARMS.txt`, `*.sv`, `run102.sh`, `score102.py`)

Each arm builds a FRESH Surelog golden and runs BOTH frozen binaries in the same
worker, in DEF (`-parse`) and ELAB (`-parse -elabuhdm`) views, recording rc per
cell.  Scoring is a view-general MULTISET comparator: payload = parameter
`VpiName` + typespec presence/kind (+ local/signed/value tag), and `param_assign`
Lhs name + Rhs constant `vpiDecompile`/`vpiSize`/`vpiConstType`/value/typespec.
**No span, no file, no parent** — order-blind and depth-blind.  `PROJ=ts`
projects onto the declaration-typespec axis this pass claims.

Result over all 42 cells: `err_ship <= err_pris` everywhere, and
**AWAY_GOLDEN = 0 on the typespec axis in every single cell**.

Shapes measured (all in both views):

* unsized `'b` / `'o` / `'h` — MOVED to golden (a01, b07, c01, c04, d02, e02, g102)
* unsized SIGNED-based `'sb` / `'sh` / `'so` — **also golden-agreeing and also
  moved** (b01).  The README's "explicit signing … retains previous behavior"
  is about the DECLARATION keyword; the literal's own `s` base is correctly
  ignored, and golden confirms that is right.
* unsized DECIMAL `'d` / `'sd` — untouched, and already correct (b01, b07)
* unknown-valued `'bx` `'bz` `'hx` `'hz` `'ox` — BYTE-IDENTICAL; they never
  reach the new predicate because `wantTs` is already false for them
  (`(!unknownDefault || sizedBasedInit)`).  The claimed fence is real.
* SIZED `3'b101` `8'h1a` `6'o17` `5'd13` `4'sb0101` `3'bx` — BYTE-IDENTICAL,
  err 0 on both binaries (b03).  The fence that matters most holds exactly.
* plain decimal, `-'h1`, `'h1 + 1`, `{'h1,'h2}`, string, real, `10ns`,
  `'0 '1 'x 'z`, parameter reference, `int'('h1a)` — BYTE-IDENTICAL (b04, b05)
* parenthesised `('h1a)` — moved to golden (b05); slang strips the parens and
  golden agrees
* typed / ranged / explicitly signed / unsigned declarations — BYTE-IDENTICAL (b06)
* `localparam` vs `parameter` — both move, `vpiLocalParam` preserved (b07)
* homes: package, interface, program, `$unit`, module header, module body —
  all move to golden (c01, c04, e05)
* 1..3 instances of the same child — all four copies move (d02)
* MACRO-expanded literals (`` `define MB 'b101 ``) — move to golden (e02); the
  raw-text scan sees through the macro
* the CAST-SIZE interaction (`parameter W = 'h8; … W'(3)`) — moves to golden and
  the cast keeps its own typespec (e01, err 8 -> 0)
* the implementer's own `g102.sv` — 42 traversal-visible parameter objects to
  golden per view, **0 away**, and **not one `param_assign` Rhs payload key
  changed** (their "53 RHS objects untouched" claim reproduces)
* the implementer's own `g102_neg.sv` — BYTE-IDENTICAL in both views (their
  negative fence reproduces) …but see §5: half of that "negative" arm is a
  residue, not a fence.

---

## 5. Residues — where golden does NOT agree with the pass's fences

Measured, both views, `PROJ=ts`, golden-vs-ship:

| shape | arm | golden | ship | verdict |
|---|---|---|---|---|
| function-local `localparam NF = 'b101` | c03, g102_neg | TS none | TS int_typespec | residue (the `!funcScope` guard is not a law) |
| OVERRIDDEN parameter (`#(.P('hF))`, positional, `defparam`) | d01, e04, e05, g102_neg | TS none on **every** copy incl. the defaulted ones | TS kept on the copies slang marks overridden | residue (the `!overridden` guard is not a law) |
| CLASS parameter / class-body localparam | c02, e03 | TS none | TS int_typespec | residue (untouched by the pass) |
| generate-block / `if`-block localparam | c01 | TS none | TS int_typespec | residue (untouched by the pass) |

The implementer's README states these "retain their previous behavior", which is
true of the code but reads as if golden wanted them kept.  It does not: golden
drops the declaration typespec there too.  They are INCOMPLETENESS, never
regression — pristine was wrong in the same cells by the same amount — so they
do not block the landing, but they are the cheapest next parameter work.

Unrelated residues surfaced by the same arms (pre-existing, both binaries):
`'hx` / `'ox` / `'hz` parameters carry the value tag `BIN` where golden carries
`HEX` / `OCT` (b02), and the DEF/ELAB `param_assign` Rhs constant of an unsized
based literal still differs from golden in `vpiSize` (-1 vs 32) and in its own
typespec ref (a01, b02) — the surface the pass deliberately did not touch.

---

## 6. Wide boundary (`bnd102.sh`) — built here, not reused

Source universe = a COPY of the whole `tools/probe` tree with **no path
filter**, plus this pass's `r10uvm102repro` and this verifier's arms: **3267
`.sv`/`.v` files in 1472 directories**, of which **1841 live in
SUBDIRECTORIES** (sd8-12 keep 347 arms there; rgg18 keeps both of its arms
there).  Each arm runs BOTH frozen binaries in DEF and ELAB, source list read on
**fd 3**, every child `</dev/null`, scratch keyed on the RELATIVE path,
`PROCESSED` asserted against `LISTED`, and rc recorded per cell.

    per-FILE       LISTED=3267 PROCESSED=3267  PROCESSED_ASSERT OK
                   IDENTICAL=6246 MOVED=20 NO_OUTPUT=268 RC_DIFF=0 ASYM=0
    per-DIRECTORY  LISTED=1472 PROCESSED=1472  PROCESSED_ASSERT OK
                   IDENTICAL=2691 MOVED=4 NO_OUTPUT=249 RC_DIFF=0 ASYM=0

Movers, per file (20 cells): `r10earl_repro/h.sv` and `r10uvm102repro/g102.sv`
and eight of this verifier's own positive arms — **no mover outside positive
sources**, in either view.  Per directory the only movers are
`r10uvm102repro` and the verifier's arm directory.  (Unlike the implementer's
run this one found NO order-only movers in `r10buvm9repro`, `r10uvm75repro`,
`r10uvm76repro`: this boundary is serial, uses `--single-unit` — the shape the
harness's default mode actually uses — and builds both sides in the same worker,
so it has no stale-dump or parallelism artefact to explain away.)

`r10earl_repro/h.sv` is the ONE pre-existing probe source in 3267 that the law
touches, and it is an arm that TESTS rather than merely agrees: its untyped
`PU = 'h3` / `MU = 'h3` move (4 objects per view, TS-axis error 8 -> 0, 0 away)
while its ten `logic [7:0]` / `int` / `logic [15:0]` siblings in the same file
are controls and do not move.

Named boundaries all byte-identical in both views, with their sources actually
reached (recursive counts): uvm97 (5), uvm98 (6), uvm89 (2), uvm77/78/79
(9/8/8), buvm14 (1), buvm3 (4), buvm15 (9), uvm82 (7), uvm91 (5), uvm84/85
(23/23), earl46/67/68 (4/3/3), rgg18 (2, both in a subdirectory), sd8-12
(37/44/68/90/108, all in subdirectories).  The verifier's own moving arms are
the positive control proving the gate can see a change.

---

## 7. R0 — the next SeqDriver head, decoded and committed

`head_after_SeqDriver_default.cmp` / `head_after_SeqDriver_testflags.cmp` (the
same object in both modes, 64 cmp lines, one head):

    LHS (golden):  constant, vpiDecompile:"UVM.1.2"  vpiSize:56  STRING:UVM.1.2
                   vpiTypespec -> ref_typespec (adpcm_pkg::adpcm_driver) -> string_typespec
    RHS (ours):    constant, vpiDecompile:"UVM-1.2"  vpiSize:56  STRING:UVM-1.2
                   vpiTypespec -> ref_typespec (uvm_pkg)             -> string_typespec

Owner: the `param_assign` Rhs of `uvm_pkg::uvm_revision`,
`uvm-1.2/src/base/uvm_version.svh:31`

    parameter string uvm_revision = `UVM_VERSION_STRING;

The failing FIELD is `expr::VpiDecompile` — the FIRST field `expr::Compare`
reads (`expr.cpp:90`), before `VpiSize` and before it would ever recurse into
the typespec.  So this head is NOT about the typespec and NOT about the
`vpiFullName` on the ref (no generated `Compare` reads `VpiFullName`); it is a
**preprocessor stringification difference**.  `UVM_VERSION_STRING` is

    `define UVM_VERSION_STRING `"`UVM_NAME``-```UVM_MAJOR_REV``.```UVM_MINOR_REV```"

(macros/uvm_version_defines.svh:96) and Surelog's stringifying preprocessor
renders the `` ``-``` `` join as `.`, producing `UVM.1.2`, where we render the
source's `-` and produce `UVM-1.2`.  Reproducing golden means reproducing
Surelog's `` `" `` / `` `` `` token-paste handling for this shape — a
preprocessor law, not a ParamEmit law.  The implementer's README called this
"the imported class string constant at the next depth"; the object is the string
constant, but the distinguisher is the macro-pasted TEXT.

R1 (from §5): the four fences that are not laws — function-local, overridden,
class, and generate-block parameters all want the declaration typespec dropped
too; each is a strictly-additive extension of the same predicate.
R2 (from §5): the `param_assign` Rhs of an unsized based literal (`vpiSize`
-1 vs 32, and its own typespec ref) — the surface this pass deliberately left.
R3: unknown-valued based parameters carry `BIN` where golden carries `HEX`/`OCT`.

---

## 8. Corrections to the implementer's report

* `GATES.txt` canary numbers (`Surelog ok=56`, `uhdm2rtlil ok=18`,
  supplementary `58/2`) reproduce only with `r10uvm100repro/canaries.sh` and
  with the two uhdm2rtlil modes SUMMED; with `r10uvm52repro/canaries.sh` (the
  copy RESUME §6 names) the same sweep reads `ok=52` / `ok=8`.  Every
  arrangement gives `changed=0 absent=0`, so the gate is green either way — but
  the numbers are script-dependent and should say which copy produced them.
* `GATES.txt` "Canary audit: audited=33": no `canaudit.sh` copy in the tree
  reports 33 for this run; the newest reports **audited=29**, with
  `UNCOVERED=0 FENCE-BREACH=0` (the assertions that matter) intact.
* `GRID.txt` "38 parameter objects per view to golden": this verifier's
  traversal counts **42** on `g102.sv` (9 distinct parameter names).  Different
  instruments, same direction and same zero AWAY count; the claim is not wrong,
  it is instrument-specific and the README does not say which instrument.
* `README.md` "unknown-valued literals … retain their previous behavior" is
  true but under-explained: they never reach the new predicate at all, because
  `wantTs` is already false for a width-indeterminate unknown init.
* `README.md` "function-local parameters, and overridden parameters retain
  their previous behavior" — measured against golden, this is a residue, not a
  fence (§5).  `g102_neg.sv` is therefore half a negative control (signed
  keyword, written range, `'bx`) and half an un-cleared residue (`NF`, `P`).
