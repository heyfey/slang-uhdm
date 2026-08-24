# r10v81 — the adversarial verification of r10earl81 (§ connBitSelIdxModParamFold81)

**VERDICT: ACCEPT.** The production surface is unchanged from the implementer's
patch; nothing was fixed because nothing broke. This directory is the evidence.

Everything below was measured from **my own** worktrees at 9ac2763
(`/tmp/wt_v81` patched, `/tmp/wt_v81pris` pristine), **my own** builds, **my
own** sweeps and **my own** instruments. `results/*.csv` was READ ONLY and no row
was converted; `GOLDEN_DEFER` was never set; both binaries were frozen `chmod
555` before any sweep and every `cmds.txt` was audited by binary PATH.

## 1. Every headline number reproduces bit-for-bit

* Both binaries rebuild to the implementer's exact md5s (`b815e9f5…` /
  `a2f44649…`), and the patch applies clean on two fresh 9ac2763 worktrees with
  an md5-identical production diff.
* All four committed head logs (`HEAD_{BEFORE,AFTER}_{default,testflags}.cmp`)
  reproduce **md5-identical**. Earlgrey default 32 → 36 cmp lines, testflags
  36 → 36, one head each, every other row unchanged — and the two AFTER logs are
  the same file, so the def/tf asymmetry really is gone.
* `byteverify SELFCHECK=1`: surelog **MOVERS 2 / 956** — exactly the two
  PREDICTED Earlgrey databases, with the same four md5s the implementer
  reported; uhdm2rtlil **MOVERS 0 / 1358**. My run did not even see the
  `Scoreboard/default` third mover, which is the cleanest possible confirmation
  that it was the documented coin and not the law.
* Whole-row corpus gates: **0 differing rows / 1588** surelog and **0 / 731**
  uhdm2rtlil, dump column included, on BOTH binaries against the committed
  baselines. Full detail in `GATES_V81.txt`.

## 2. What I tried to break, and what happened

`GRID_V81.txt` is the table; the eight arms are here as `.sv`. The attack that
mattered:

**The `+TS` question.** `GRID_G2.txt` folds only `int unsigned`, `bit [3:0]` and
untyped OVERRIDDEN cells, while its measured `ref_typespec`-presence rule (golden
stamps one on the SIGNED-`int_typespec` sub-case) comes from the NON-overridden
population. If that rule also reached the overridden fold, the shipped law —
which attaches no typespec, ever — would be wrong at every signed-typed cell.
`v1_sign81.sv` puts an OVERRIDDEN bare decimal behind **ten** declared types
(`int`, `integer`, `byte`, `signed [7:0]`, `logic [7:0]`, `bit [3:0]`,
`int unsigned`, untyped, `shortint`, `longint`). **Golden folds all ten to
`UINT:<v>` size 64 ct 9 with NO typespec**, and patched matches all ten exactly.
The declared type stops mattering the moment the parameter is overridden —
precisely what "no `adjustSize` on the `collectParams_` override path" predicts,
now measured on ten types instead of three. The law survives.

**The span traps** (`v4_macro81.sv`). `isOverriddenParam` is a SPAN comparison
and the gate reads the actual's RAW TEXT, so a DEFAULT written through a macro
was the obvious way to make the law fire on a non-overridden parameter and write
64 where golden writes 32. It does not fire: `rawText` maps a macro range back to
its definition site and `isOverriddenParam` compares ORIGINAL locations, so the
macro-written default still reads NOT-overridden and stays a `ref_obj` (golden:
size **32**). An override written THROUGH a macro folds correctly, including the
`007` spelling.

**The `-G` / `-P` command-line override** (`v5_cli81.sv`). slang binds `-G` like
an instantiation override, so `isOverriddenParam` says TRUE and the shipped law
does not consult `cliOverridden` — which exists in ParamEmit.cpp *because*
Surelog's cmdline path is a different one. Measured against Surelog `-PN=2`:
golden folds to `UINT:2` size 64 and patched matches. Not a break.

**Homes, shapes and value edges.** Nested generate, instance arrays, program
instances, positional `#(4)`, concatenations, casts, inout actuals, replications,
a parameter shadowing a package parameter of the same name, `0`, `0000002`,
`65535` and an actual with embedded whitespace and a comment: **all fold to
golden exactly**. Zero AWAY-GOLDEN and zero MOVED-WRONG anywhere.

**The neighbouring laws.** `v7_enum81.sv` puts a module enum constant, a PACKAGE
enum constant (§ elabConnEnumConstFold66), a `$bits` index and a `bind`-created
instance's connection in the same position: **zero moved**. `v3_shape81.sv` and
g1's part-select / indexed-part-select slots — § genScopeConnPsDirectBoundKeepsRef71's
KEEPS-REF face — **zero moved**, in every home and both views.

## 3. The one structural side effect, and why it is not a defect

Folding the index leaves our elaborated view with one more `bit_select` COPY per
folded cell in some designs. In **Earlgrey — the only place in either corpus
where the law fires — this moves us TOWARD golden**: testflags golden carries 3
copies, pristine 2, patched 3. In the synthetic arms golden carries 2 and patched
3. It is not judge-visible: no generated `Compare` reads `VpiParent` or counts an
object's parents, and the **official `uhdm-cmp` on `g3_norm81.sv` is byte-identical
before and after** (same head, 2286 lines both). Recorded in `CENSUS_EARLGREY.txt`
so the next pass is not surprised by it.

## 4. The census and the boundaries

`CENSUS_EARLGREY.txt` — my own whole-database identity census (`vall81.cpp`, a
direct `.uhdm` reader; Earlgrey's `uhdm-dump` is >1 GB) keyed on the parent chain
with a **no-span, Compare-visible** payload: **TO-GOLDEN 16 / AWAY-GOLDEN 0 /
MOVED-WRONG 0** in BOTH modes, whole database and select-slot census alike. The
16 keys are 8 socket instances × 2 ports carrying **eight different override
values (2, 2, 2, 3, 4, 8, 12, 13)**, each landing on golden exactly. The family
is **closed**: after the patch, ZERO elaborated port-High_conn bit-select indices
name a parameter in either mode (300 → 268 `ref_obj` cells, of which 264 are the
DEF-listing rows fence (a) protects and 4 name a `logic_net`/`logic_var`).

`BOUNDARY_V81.txt` — WIDE `LISTED=3662 PROCESSED=3662 DIFFERING=8` (`.sv` **and**
`.v`, which the implementer's 3594-file walk omitted; the same eight cells and no
others) and PER-DIRECTORY `LISTED=1538 PROCESSED=1538 DIFFERING=14`. Every mover
convicted by two controls; `r10earl81repro` is the only one where disabling the
law reproduces pristine byte-exactly. All 26 named precedent repro directories are
byte-identical in both views. Every rc=139 site appears on both sides.

## 5. Residues this verification adds (they are REFUSALS, not regressions)

| | residue | measured |
|---|---|---|
| V1 | **an INTERFACE instance's port High_conn** | golden folds the index, we keep the `ref_obj` (`v2_home81.sv` `uIf`) |
| V2 | **a `defparam` override** | golden folds, we keep the `ref_obj`; `isOverriddenParam` is true but the actual is not reached as an IntegerLiteral (`v2_home81.sv` `uDef`) |
| V3 | **a HIERARCHICAL actual** `us.sw[N]` | the index lives under a `hier_path`, which this call site never reaches (`v3_shape81.sv` `uHier`) |
| V4 | **the indexed-part-select BASE at a port High_conn** | golden folds `w[N +: 4]`'s base to a constant, we keep the ref — the ips face of the same read (`v3_shape81.sv` `uIps`, g1 `uJ`) |
| V5 | **an override-only parameter** (declared with NO default) | `paramDefaultSyn` returns null so `isOverriddenParam` is false and the gate abstains; golden folds (`v4_macro81.sv` `uRQ`) |
| V6 | **the elaborated assignment-pattern High_conn** | golden emits NO member values in its elaborated `tagged_pattern`s while we emit the whole pattern — pre-existing, unrelated to this law, and it makes any pattern-carrying port cell unscoreable (`v8_shape2_81.sv` `uPat`) |

Zero of V1–V6 exist in either corpus, and every one of them is identical in the
pristine and the patched database.

## 6. Instruments (all measurement-only; they read databases and dispatch nothing)

| file | what it is |
|---|---|
| `vall81.cpp` | WHOLE-DATABASE identity census, direct `.uhdm` reader, parent-chain key, **no span**, Compare-visible payload |
| `vscore81.py` | 3-way scorer, SET semantics by default (`SETMODE=0` for multisets), reports TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-* |
| `varm81.sh` | one arm: Surelog golden + both frozen binaries + the `R10E81_OFF=1` neutral, both views, rc printed for every cell |
| `vwide_v81.sh` | the WIDE boundary — `.sv` and `.v`, any depth, fd-3 list, children `</dev/null`, rc per cell, PROCESSED asserted, fenced names skipped-and-listed |
| `vdir_v81.sh` | the PER-DIRECTORY boundary, same discipline, whole directory as one unit |
| `vattr_dir81.sh` | attributes one differing directory with TWO controls: same-binary repeat and law-disabled |
| `v1…v8_*.sv` | the eight adversarial arms |
