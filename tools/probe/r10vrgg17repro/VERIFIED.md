# r10vrgg17 — ADVERSARIAL VERIFICATION of r10rgg17 § hpConnElemIdxFold17

**VERDICT: ACCEPT AS SHIPPED.** Every headline number reproduced bit-for-bit
from my own worktrees and my own builds. Nine new adversarial arm cells over
the index / tail / base-kind / position / home / direction / sign axes, in BOTH
views, plus a per-file AND per-directory wide boundary in BOTH views:
**0 pristine-right -> patched-wrong cells.** No production fix was needed, so
the shipped patch is unmodified apart from one STALE COMMENT in the census
instrument (below).

Base commit `f969774`. Worktrees `/tmp/wt_vrgg17` (patched) and
`/tmp/wt_vrgg17pris` (pristine). Binaries frozen at
`/tmp/vrgg17_bin/slang-uhdm-{base,pat}`.

## 1. Bit-for-bit reproduction of the shipped numbers

| claim | shipped | measured here |
|---|---|---|
| base binary md5 | `c140b82036818ac7f5ca2058b47ca85b` | **identical** |
| patched binary md5 | `57d0f4f1daf23cf4f0b27b6e061f7c65` | **identical** |
| goldens base / patched | 23/0 each | 23/0 each |
| goldens `SLANG_UHDM=/bin/false` | 0/23 | 0/23 |
| u2r status (both modes) | 679 / 50 / 2 per mode | 1358 / 100 / 4 over both = same |
| u2r rows vs own base sweep | 0 / 1462 | **0 / 1462** (status AND dump) |
| u2r rows vs committed `gate_uhdm2rtlil.csv` | 0 / 731 | **0 / 731** |
| u2r byte movers | 0 / 1358 | **0 / 1358** (positive control sees 1) |
| surelog status | 936/20/567/48/10/3/2/1/1 | **identical, base and patched** |
| surelog rows vs own base sweep | 0 / 1588 | **0 / 1588** |
| surelog rows vs committed `golden_surelog.csv` | 0 / 1588 | **0 / 1588** |
| surelog byte movers | 2 / 956 | **2 / 956** — `default/Rggen`, `default/Scoreboard` |
| the 20 CMP_NOTEQUAL rows | unchanged set | **identical set, base and patched** |
| Rggen/default head | 194 -> 64 cmp lines, 1 head | **194 -> 64, 1 head** |
| Rggen whole-dump diff | 984 removed / 480 added, 24 hunks | **984 / 480 / 24 hunks** |
| every diff hunk at `block_1.sv:356` | claimed | **528 span-carrying diff lines, ALL `line:356:`; no other file or line appears** |
| Rggen census, all hier_paths | differing 24 -> 0 over 6,525 keys | **FIXED 24, BROKEN 0, STILL-WRONG 103, STILL-RIGHT 6,398, keys 6,525** |
| Rggen census, port actuals only | 24 -> 0 over 77 | **FIXED 24, BROKEN 0, STILL-WRONG 0, STILL-RIGHT 53, keys 77** |
| golden-vs-golden calibration | 6,525 / 6,525, md5 `98176c6e…` | **6,525 / 6,525 identical; fresh `surelog -parse` md5 `98176c6e44638c913a47fd319fa3729f`, byte-identical to the cache** |
| grids g1 / g2 / g3 | 12/0/8/13, 6/0/2/6, 10/0/2/4 | **identical, and identical again in the ELAB view** |
| predicted movers | sl 1, u2r 0 | **sl 1, u2r 0**; reach 25 dbs / 12,445 port hier_paths (sl), 40 / 124 (u2r) |
| cmds.txt audit by binary PATH | 0 wrong-binary, 4 legs | **sl 1523/1573 + 50 no-slang-line; u2r 1458/1462 + 4; 0 other-binary in all four** |
| canaries / ctcan2 / canaudit | changed=0, PASS, audited=29 UNCOVERED=0 | **changed=0 both corpora; ctcan2 PASS/PASS with the documented EXPECT_UNKNOWN; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| byte pins | held | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a`/`73a10e8217e5`, `YosysOldOr` `d68e0796d62c`, `SVSwitch` **`4842211c4030`**, `YosysVerx` **`6ccda350c24a`** — all SAME |

**The 24 sites are byte-identical to golden.** Multiset of every dump line
carrying a `356:` span, ids stripped: golden 221 lines / 41 distinct, patched
221 / 41, **`diff` empty**; base 413 / 37 and differs.

**Head decode independently confirmed from the sources**, not carried forward:
`hier_path::Compare` (`hier_path.cpp:110`) opens with `basetype_t::Compare` ->
`expr::Compare` (`expr.cpp:83`) -> `BaseClass::Compare`
(`UHDM/templates/BaseClass.cpp:163`), which reads **VpiType, VpiName,
VpiDefName** — all three before `Path_elems`. The failing field is the
hier_path's own `VpiName`, exactly as shipped.

**The coin is proved, not asserted, and independently.** Six runs of the
**BASE** binary on `Scoreboard`'s own command line here give
`7e1133fd 7e1133fd 3e1c7201 3e1c7201 3e1c7201 3e1c7201`, and six of the patched
give `3e1c7201 7e1133fd 3e1c7201 3e1c7201 3e1c7201 3e1c7201`. The reported
"mover" `3e1c7201 -> 7e1133fd` is a face the BASE binary produces on its own.

## 2. The adversarial grid (`cells/v1..v9`), BOTH views, scored field-by-field

Scored with a 3-way order-blind comparator over the Compare-visible payload of
every reachable `hier_path` and every `Path_elem` (no fullname, no span in the
payload). Golden rebuilt per cell from `surelog -parse` / `-elabuhdm`.

| cell | axis | FIXED | **BROKEN** | STILL-WRONG | STILL-RIGHT |
|---|---|---|---|---|---|
| v1 | index shape: localparam, `-`, `/`, `%`, `**`, unary minus, based literal, `$clog2`, ternary, `^`, param*param, genvar twice, ips-base param/genvar/arith | 18 | **0** | 18 | 9 |
| v2 | tail shape incl. MEMBER-OF-MEMBER (3 components) and an unpacked member `m[i]` | 6 | **0** | 15 | 0 |
| v3 | POSITION: port vs cont_assign vs always_comb vs `always @(*)` vs function arg vs initial | 2 | **0** | 13 | 3 |
| v4 | HOME: gen-if, gen-case, nested gen, module scope, 3 instances, program present | 27 | **0** | 4 | 5 |
| v5 | BASE KIND: module-instance array, DESCENDING module array, scalar instance, unpacked struct array, 2-D interface array | 6 | **0** | 6 | 7 |
| v6 | FENCE: modport-restricted root, whole-interface port, generic interface port, plain struct root, interface instance named from the parent | — | — | — | **base and patched BYTE-IDENTICAL, both views** |
| v7 | SIGN: negative array bounds, negative ips base | 4 | **0** | 4 | 4 |
| v8 | OUTPUT port actuals (the `inLhs` naming branches), indexed and simple range | 4 | **0** | 0 | 2 |
| v9 | TWO array components in one path | 4 | **0** | 8 | 0 |

Identical scores in the `-elabuhdm` view for every cell.

**The position rule holds exactly (v3).** The identical select text
`arr[6+7*i].value[0+:4]` folds in the PORT CONNECTION (patched matches golden
field for field: `bit_select{arr, INT:6 sz64 ct7}`) and stays symbolic in the
cont_assign, the `always_comb`, the `always @(*)`, the function-call argument
and the `initial` block — where golden also keeps it symbolic and **base and
patched emit the same bytes**.

**Abstentions are clean.** `%`, `**`, `^`, `$clog2`, ternary, 2-D component,
bare parameter/localparam index, unpacked variable array base: patched ==
base in every one. `3'd2+i` folds and matches golden exactly (`INT:2 ct7`),
so the "based literals abstain" line in the shipped README is imprecise —
harmlessly, because the fold it produces is golden's.

## 3. Wide boundary — per-FILE and per-DIRECTORY, BOTH views

Over a COPY of the WHOLE `tools/probe` tree (taken from the main tree, so it is
wider than the shipped run), no path filter, `.sv` and `.v`, file list on fd 3,
children `</dev/null`, PROCESSED asserted, rc recorded per cell, the four
slang-fenced tests never dispatched:

```
PER-FILE view=plain LISTED=3175 PROCESSED=3175 identical=3044 MOVERS=4 uncompilable=127 asymmetries=0
PER-DIR  view=plain LISTED=1440 PROCESSED=1440 identical=1315 MOVERS=4 uncompilable=121 asymmetries=0
PER-FILE view=elab  LISTED=3175 PROCESSED=3175 identical=3034 MOVERS=4 uncompilable=137 asymmetries=0
PER-DIR  view=elab  LISTED=1440 PROCESSED=1440 identical=1310 MOVERS=4 uncompilable=126 asymmetries=0
```

The same 4 movers in all four passes: three are this pass's own grid cells
(the POSITIVE CONTROL — the gate can see), the fourth is
`r10buvm22repro/g22.sv`.

**`g22.sv` re-decoded independently and the shipped decode CONFIRMED, with a
stronger argument than the shipped one.** The delta is 3 constants
(`22186169`/`22185313` -> `22202553`/`22201697`, deterministic per binary over
3 runs each) produced by `buildUnpackedArrayTypedefTs`
(`src/TypeEmit.cpp:10345`) doing `ct.as<FixedSizeUnpackedArrayType>()`
UNCHECKED and then reading `fua.range` for `typedef C22 ka_cls_t[string];`
(an `AssociativeArrayType`) — pre-existing UB, untouched by the patch.
**`g22.sv` contains ZERO module instantiations and ZERO port connections**, so
the § 17 arm cannot execute in that file at all; the shift is allocation
history, not the law.

## 4. Findings — ranked residues the shipped write-up does not name

* **R-V1 — a path with TWO array components HALF-FOLDS** (`cells/v9`).
  `h[1+2*i].s[1+2*j].value[0+:4]` -> golden `h[1].s[1].value[0+:4]`,
  patched `h[1+2*i].s[1].value[0+:4]`, base `h[1+2*i].s[1+2*j].value[0+:4]`.
  Only the INNERMOST array component folds. Cause: `slotFor17`'s upward walk
  starts at the referenced value and stops at the first enclosing
  `InstanceBody`; an `InstanceBodySymbol`'s parent scope is not the
  instantiating scope, so the OUTER instance array is unreachable from it.
  **Not a regression** — patched matches golden on strictly MORE fields than
  base and on no fewer (E1 goes right, E0 and E2 unchanged, the name gets
  closer). ZERO corpus reach.
* **R-V2 — a NEGATIVE array slot can never fold** (`cells/v7`).
  `sif neg[-4:4]()` with `neg[-4+i]`: golden `INT:-3` / `INT:-2`, both sides
  abstain. Cause: `slotOf17`/`slotFor17` return `-1` as the NOT-FOUND sentinel
  and the caller gates on `if (v17 < 0) continue;`, so a legitimate negative
  slot is indistinguishable from failure. One-line fix shape: return
  `std::optional<long long>`. ZERO corpus reach.
* **R-V3 — the ips BASE does not fold a bare PARAMETER** (`cells/v1` L21).
  `arr[6+7*i].value[P+:4]`: golden `arr[6].value[2+:4]` with the base at the
  parameter's OWN size (`UINT:2 sz32 ct9` — r10rgg11's declaration-constant
  copy); patched folds the element and leaves the base `R{P}`. Base was wrong
  too. This is the shipped R-B/rgg14 law in the ips-base position.
* **R-V4 — the shipped § 17 NAME override collapses a pre-existing render
  branch.** When `anyFold17` is set, the new `selText` block replaces all three
  pre-existing branches, including
  `else if (stripImplicitConv(rs.left()).kind == NamedValue) selText =
  selName(rawText(expr.sourceRange));`. Measured on `cells/v1` L21 the result
  is CLOSER to golden, so nothing regresses today, but the branch is now
  unreachable whenever any component folds and that is not written down.
* **STALE COMMENT (fixed here).** `hpcensus17.cpp:18` still says
  "Objects are enumerated from `Serializer::AllObjects()`", which the file's own
  lines 127-133 and the shipped README explicitly CORRECT — population is
  `UhdmListener::listenDesign`. Comment-only, corrected in this patch.
* **Two shipped canary counts are slice-dependent, not wrong.** `GATES.txt`
  reports `canaries.sh uhdm2rtlil ok=8` and `ctcan2 uhdm2rtlil ok=1`; against a
  BOTH-MODES u2r baseline the same scripts give `ok=16` and `ok=2`, with
  `changed=0` either way. The shipped numbers came from the testflags-only
  committed slice.

## 5. What this verification does NOT claim

It does not claim Rggen passes. Rggen/default remains `CMP_NOTEQUAL` on R0
(`block_1.sv:33:59`, golden `UINT:64` decompile `"64"` sz 7 vs ours `UINT:0`
decompile `"-64"` — confirmed verbatim from my own patched database, and the
failing field is `VpiDecompile` inside `expr::Compare`, before `VpiSize`).
`results/*.csv` was READ ONLY on every leg of this verification.

## 6. Instruments in this directory

```
runarm.sh      one arm cell, BOTH views, golden + base + patched, md5 per side
score3.py      the 3-way order-blind hier_path scorer (prints B as well as G and P;
               the shipped score17.py prints only G and P, which hides WHY a cell moved)
vcmp.py        a whole-dump view-general line-multiset comparator (ids/paths/spans normalised)
boundary.sh    the wide boundary: per-FILE and per-DIR, both views, fd-3 list,
               children </dev/null, PROCESSED asserted, rc per cell, fenced skip
gates.sh       the four sweep legs against MY OWN pinned binaries and workdirs
rows.py        differing-row counter, status AND dump
byteverify.py  per-database md5 mover set, with an external positive control
cells/v1..v9   the adversarial arms (§ 2)
```
