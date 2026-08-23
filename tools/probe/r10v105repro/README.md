# r10v105 — ADVERSARIAL VERIFICATION of r10uvm105 (§ `oobClassTypeParamLocalUnsupported105`)

**VERDICT: ACCEPT AS SHIPPED.** Every headline number in the implementer's
report was rebuilt from scratch and reproduced bit-for-bit; no
pristine-right → patched-wrong cell was found on any legal SV written here.

**MEASUREMENT ONLY.** The official `uhdm-cmp` and `scripts/verify_golden.py` are
the judges. slang was NOT patched; `results/*.csv` were READ ONLY; NO ROW WAS
CONVERTED. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

## What was rebuilt, not trusted

| | |
|---|---|
| BASE | `50c3880`, two fresh worktrees (patched / pristine) |
| pristine md5 | `9bfe3c01602ee7e873484f3974ec8348` (matches the implementer's) |
| patched md5 | `f238285deb8f75aded1396f9ca6273ae` (matches the implementer's) |
| binaries | frozen `chmod 555`, own paths; every `cmds.txt` in all four sweep workdirs (1573 + 1462 files) names exactly one slang binary and it is the frozen one |

Gates: goldens 23/0 for BOTH binaries and 0/23 for `/bin/false`; uhdm2rtlil both
modes 0 differing rows and byteverify **MOVERS 0 / 1358**; surelog `--mode both`
**0 differing rows over 1588** with the status histogram unchanged
(default 471 EQ / 10 NE, testflags 466 EQ / 9 NE) and byteverify
**MOVERS 9 / 956**, exactly the nine the fence PREDICTED BY NAME from pristine
databases alone (54 HIT sites / 9 databases on surelog, **0** on uhdm2rtlil).
Order-blind attribution of all nine: 108 (216) changed lines each, only
`class_typespec`→`unsupported_typespec` and `vpiClassDefn`→`vpiInstance`, naming
only the six fence source lines. Heads: SimpleUVM ×2 **22 → 17**,
Scoreboard/default **22 → 29**, SeqDriver 64, MiniAmiq 348, BuildUVMPkg 72,
Earlgrey 46 unchanged, Rggen still CMP_EQUAL. Canaries 52/0 and 8/0, both
`ctcan2` PASS, `canaudit` PASS, all five protected databases byte-identical
(SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`).

Boundary, a COPY of the whole probe tree, `.sv` and `.v`, no path filter, both
views × both modes: `PROCESSED == LISTED` (3288/3288, 1475/1475), no asymmetric
reject, DIFFER 6 / 6 / 5 / 6 — the same six units the implementer named, plus
`r10uvm88repro` in one `dir` run, PROVED to be the pre-existing `vpiTaskFunc`
list-order coin (pristine differs from itself run to run; the sorted,
id-stripped, path-normalised pristine-vs-patched diff is **0 lines** in three
paired runs, and the same holds for `r10uvm75repro` / `r10uvm76repro`).
`r10buvm22repro/g22.sv` reproduced exactly: `UINT:22235321`/`22234465` pristine
vs `22239417`/`22238561` patched, both **`Builtins::Instance + 1337` / `+ 481`**
in their own binary — a raw pointer written into a constant's value, deterministic
per binary, with no typespec line in that arm's diff.

## The arms this verification ADDS (`score_v105.py`, both views, scored against golden)

`score_v105.py <golden.tsv> <pristine.tsv> <patched.tsv>` joins the
`r10uvm105cen` census per (VIEW, SITE, OOB, CLS, OWNER, LC, NM) with the
Compare-visible payload (kind, name, instance) as a **set**, so golden's ELAB
copy COUNT (residue R-M) cannot masquerade as a payload move.

| arm | what it asks | AWAY |
|---|---|---|
| `v105_b1.sv` | struct- / enum- / typedef-defaulted parameters; virtual, protected and local out-of-body methods; a PARAMETERISED typedef of the parameter; three specialisations | **0** |
| `v105_b2.sv` | the colliding typedef in a MODULE, an INTERFACE and ANOTHER CLASS — places the guard does not walk | **0** |
| `v105_b3.sv` | interface / program / nested-class homes; nested-block and for-loop-body locals | **0** |
| `v105_b4.sv` | the parameter USED: `new()`, `$cast`, a cast, a static method, a constraint, a covergroup, a formal, `T::inner_t` | **0** |
| `v105_b5.sv` | a `$unit` class against a FAR package typedef; an out-of-body CONSTRUCTOR; a typedef declared AFTER the class; an exported/imported copy | **0** |
| `v105_b6.sv` | a virtual class; a body-local `typedef` SHADOWING the parameter name; three parameters in one task | **0** |

Re-scored independently: the implementer's own `g105_a1/a2/a3`, and the two
legal-SV boundary units `r10uvm58repro/a6_extern.sv` and
`r10uvm87repro/v87_a3_oob.sv` — **AWAY 0** on all five.

## What the arms MEASURED that the pass did not model (residues)

1. **The guard is UNDER-inclusive** (`v105_b2.sv`). Surelog's
   `ElaborationStep::bindTypedefs_` `specs` map is filled from EVERY component's
   typedef map — file contents, packages, modules, programs **and classes**
   (`ElaborationStep.cpp:110-148`) — and the package repair loop
   (`:328-357`) looks a placeholder's BARE name up in it. A typedef of the
   parameter's simple name in a MODULE, an INTERFACE or ANOTHER CLASS therefore
   repairs golden's placeholder (`int_typespec 'CMOD_B2'` / `'CIFC_B2'` /
   `'CCLS_B2'`), while `oobTpLocalShadowedByTd105` walks only the class's scope
   chain, `getPackages()` and `getCompilationUnits()` — so § 105 fires and we
   emit `unsupported_typespec`. NOT a regression: pristine emitted a
   `class_typespec` there and was equally wrong; `VpiType` differs from golden
   either way.
2. **The guard is OVER-inclusive for a `$unit` home** (`v105_b5.sv`, `uo_far`).
   The three repair loops iterate PACKAGE / MODULE / CLASS definitions'
   late-binding lists; a `$unit`-homed out-of-body definition's component is in
   NONE of them, so golden does **not** repair it (`unsupported_typespec
   'UB5FAR'`, no instance) even though a far package declares that typedef —
   but the guard's package walk suppresses § 105 there. A missed hit, not a
   regression. Together with (1) this is a two-sided refinement and needs its own
   measured pass.
3. **A nested CLASS name written in an out-of-body body degrades too**
   (`v105_b3.sv`, `xo_in`): golden gives `unsupported_typespec 'inner_b3'`
   @`pn_b3` where we resolve. The law's mechanism is wider than type parameters —
   it is *any* name the package's lexical chain cannot answer.
4. **The for-loop-body local** joins § 105's R-BLK: `BT loop_b;` inside a
   `for` in an out-of-body definition degrades in golden exactly like a
   nested-block local.
5. **The out-of-body CONSTRUCTOR local** (`v105_b5.sv`, `ctor_l`): golden emits
   NOTHING for it (§ `qualifiedCtorLosesPortListAndBody27` — the constructor
   loses its body), we emit the variable either way, and § 105 now stamps that
   already-EXTRA object. Benign; the object was extra before.
6. **Interface- and program-homed classes**: golden degrades their out-of-body
   locals with NO `vpiInstance`; we emit nothing at all at those sites
   (pre-existing MISS).

## Files

```
README.md            this verification
v105_b1..b6.sv       the six adversarial arms
score_v105.py        the view-general, multiplicity-separated scorer
SCORE.*.txt          its output for all eleven arms scored
```
