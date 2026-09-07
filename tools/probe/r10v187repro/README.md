# r10v187 — ADVERSARIAL VERIFICATION of r10uvm187 § `pkgScalarTdParamDefDefer187`

**VERDICT: ACCEPT.** Every headline number in the implementer's report was
reproduced bit-for-bit from independently built binaries, in this verifier's
own worktrees, with `SLANG_UHDM` exported explicitly per binary and every
`cmds.txt` audited by binary PATH. Fifteen new adversarial arms (606 census
cells over both views) found **no shape on which the pristine binary is right
and the patched binary is wrong** — on the judge, `AWAY-GOLDEN 0` and
`CHANGED-STILL-WRONG 0`. The production surface is **unchanged** by this
verifier; the only edits shipped here are probe-only.

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** slang was NOT patched,
`results/*.csv` were READ ONLY, no row was converted, `GOLDEN_DEFER` stayed
unset, and the four slang-fenced tests were never dispatched (they appear only
inside `canaudit.sh`'s own fence list).

| | |
|---|---|
| BASE | `362dcfa0` |
| pristine binary | md5 `8b1777950b91feef705565e6f16e8b0a`, built by this verifier from a clean `362dcfa0` worktree — **byte-identical to the implementer's pristine AND to the main tree's own binary**, so the build is reproducible |
| patched binary | md5 `b15c4f042d5928e133f3bde9806352c4` — **identical to the implementer's**, from an independent build of the same patch (`/tmp/r10uvm187.patch`, md5 `efaf74e01648c08fe03d4583b7ddf366`, applied clean with `git apply -3` on a fresh `362dcfa0`) |
| both frozen | `chmod 555` copies BEFORE any sweep |

---

## 1. EVERY HEADLINE NUMBER, REPRODUCED INDEPENDENTLY

| claim | implementer | this verifier |
|---|---|---|
| pristine / patched md5 | `8b177795…` / `b15c4f04…` | **identical** |
| goldens patched / pristine / `/bin/false` | 23-0 / 23-0 / 0-23 | **identical** |
| u2r testflags status | 679 / 50 / 2 | **identical**, and default too |
| u2r ct8rows vs committed + vs own pristine | PASS, 0 rows | **identical**, both modes |
| surelog `--mode both` histogram | 471/283/25/10/5 · 466/284/23/9/5/3/2/1/1 | **identical**, 1588 rows |
| surelog ct8rows vs committed + vs own pristine | PASS, 0 rows | **identical**, NO ROW CONVERTED |
| byteverify u2r | MOVERS 0 / 1358 | **identical** (selfcheck 1357/1358) |
| byteverify surelog | MOVERS 3 / 956 | **MOVERS 2 / 956** — `BuildUVMPkg` ×2 with the SAME md5s (`bbf172cd412b` → `3e9b187f5f57`). The implementer's third mover, `Scoreboard/default`, **did not flip on this run**, which is the coin law's own prediction and an independent confirmation that it was the coin and not the law |
| predicted movers, surelog pristine | SCANNED 1573, SKIP 617, CELLS 6, BuildUVMPkg only | **identical**, the six cells are `UVM_STDIN`/`UVM_STDOUT`/`UVM_STDERR` at `8461:20`/`8462:20`/`8463:20` × 2 modes |
| predicted movers, u2r pristine | SCANNED 1462, SKIP 104, CELLS 0 | **identical** |
| the same scan on the PATCHED sweeps | 0 in both corpora | **identical** — the face is closed corpus-wide |
| heads | BuildUVMPkg 48→36 both modes, everything else unchanged | **identical**; the other ten cmp logs are **byte-identical between binaries**, and the BuildUVMPkg cmp md5s are `df87bde51760` (pristine) → `7f92233e04ae` (patched), both modes, exactly as claimed |
| census, nine UVM (test,mode) pairs | BuildUVMPkg 79→82, FACE 3→0; the rest unchanged | **identical** |
| residue family scan | surelog 8 cells → 2, u2r 4 → 4 | **identical** (`ParamSubstituteComplex` DEFMOD ×2, `typedef_package` ELABPKG ×4) |
| canaries / ctcan2 / canaudit | 52-0, 8-0, PASS ×2, audited=29 UNCOVERED=0 FENCE-BREACH=0 | **identical** |
| protected DBs | all SAME, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **identical** |
| boundary | LISTED 5052 = PROCESSED 5052, PRODUCED 4892, MOVED 5, RC_DIFFS 0 | **identical**, same five arms |
| must-stay floor | 13 named dirs, movers 0 | **identical**, with the same arm counts (earl111 6, uvm185 5, uvm170 5, uvm181/182/183/184 4/4/6/2, uvm82 7, uvm91 5, buvm3 4, buvm15 9, sd8 37, sd12 108) |
| grid | 231 cells, 99 → 122, TO-GOLDEN 23 / AWAY 0 / STILL-WRONG 0 | **reproduced**: re-running the seven committed arms through an independent driver gives exactly 2× the implementer's per-arm cells (this driver scores the def-run and the elab-run separately) and exactly 2× their TO-GOLDEN — 5/4/7/0/0/4 on the six own arms and 3 on `r10buvm18repro/grid18.sv`, **AWAY 0, CHANGED-STILL-WRONG 0** on every one |

`R0` was read out of this verifier's own patched cmp log and is exactly as
reported — `enum_const (UVM_DEEP)` at `uvm_pkg.sv:7932`, golden
`vpiDecompile:1 << 16` / `UINT:65536` / `vpiSize:80` against our `1<<16` /
`INT:65536` / `64`. The field order was re-derived from the generated sources
rather than taken on trust: `enum_const::Compare` calls `expr::Compare` first
(`~/git-repos/UHDM/build/generated/src/enum_const.cpp`,
`.../expr.cpp`), and `expr::Compare` reads `VpiDecompile` **before** `VpiSize`.
The decompile string is therefore the first failing field, as claimed.

---

## 2. BREAKING THE LAW — fifteen new arms, 606 cells, both views

`arms187/*.sv`, driven by `grid187v.sh` (golden + both binaries, both views,
every rc recorded) and scored by the implementer's own `score187.py`.

| arm | what it attacks | cells | TO-GOLDEN | AWAY | STILL-WRONG |
|---|---|---|---|---|---|
| `v187_a_pkgimport` | a package that WILDCARD-imports and one that EXPLICITLY imports another package's scalar-typedef'd parameters, plus a foreign typedef named bare inside a package | 84 | 6 | 0 | 0 |
| `v187_b_multiassign` | several `Param_assignment`s on ONE declaration (`parameter m_i_t M_A = 1, M_B = 2, M_C = 3;`) | 68 | 16 | 0 | 0 |
| `v187_c_signing` | `int unsigned` / `int signed` / `byte unsigned` / `byte signed` / `bit signed` typedefs | 52 | 8 | 0 | **4 (span only — see §3)** |
| `v187_d_order` | names, case (`A` vs `a`), digits, very long names, a typedef named like a parameter, and interleaved declaration order | 68 | 16 | 0 | 0 |
| `v187_e_nested` | the deferred parameter used as a later typedef's RANGE BOUND, beside enum/struct siblings and a package-class localparam | 46 | 4 | 0 | 0 |
| `v187_f_specparam` | `specparam` + module localparam + a module's own scalar typedef | 12 | 2 | 0 | 0 |
| `v187_g_typeparam` | a package parameter whose declared type is a **type parameter** (a `TypeAlias` homed in the package that is NOT a typedef declaration) | 36 | 2 | 0 | 0 |
| `v187_h_uninst` | a package NEVER imported (DEF listing only), one reached only by a qualified reference, and a six-parameter FAN-OUT on one typedef | 32 | 14 | 0 | 0 |
| `v187_i_signedonly` | the `int signed` face reduced until it is the head | 8 | 0 | 0 | **2 (span only)** |
| `v187_j_clones` | typedef'd parameters IN CLONES: a parameterized module instantiated three ways, a parameterized class specialized twice | 34 | 4 | 0 | 0 |
| `v187_k_ranged` | ranged (vector) typedefs beside scalar ones, incl. a vector typedef bounded by a deferred parameter | 52 | 6 | 0 | 0 |
| `v187_l_dupnames` | the SAME typedef name in two packages, a CROSS-package chained typedef, and a file with no module at all | 20 | 6 | 0 | 0 |
| `v187_m_unit` | a `$unit`-scope typedef (residue R3) beside a package one | 12 | 2 | 0 | 0 |
| `v187_n_consumers` | the deferred parameter CONSUMED by everything in its package — later typedef bound, enum base, struct member, function return width, class parameter default, unpacked-array size — and by a module expression | 48 | 4 | **2 (`nsh` only — see §3)** | 0 |
| `v187_o_dims` | packed dims WRITTEN on a scalar typedef name (`parameter o_b1_t [3:0] P`), plus interface and program homes | 34 | 4 | 0 | 0 |
| **total** | | **606** | **94** | **2** | **6** |

**On the fields the judge actually reads** — `jproj187v.py` projects each
census value onto kind, `VpiName`, the alias target's kind and `VpiName`,
`Ranges`, `VpiSigned` and `Instance`, and drops `@span`, `apar` and `nsh` —
the same 606 cells plus the implementer's 462 score

> **1068 cells, TO-GOLDEN 146, AWAY-GOLDEN 0, CHANGED-STILL-WRONG 0,
> ONE-SIDED-KEY 0.**

The projection is not a convenience: `BaseClass::Compare`
(`~/git-repos/UHDM/build/generated/src/BaseClass.cpp`) reads
**`VpiType`, `VpiName`, `VpiDefName` and nothing else** — no generated
`Compare` reads `VpiLineNo`/`VpiColumnNo`, `VpiParent`, or any sharing
fan-out.

A whole-dump **order-blind** three-way score (`dump3v187.sh`: id-stripped,
path-normalised, sorted; TOWARD = golden lines patched gained, AWAY = golden
lines patched lost) over all 22 arms × 2 views reads **AWAY = 0** everywhere.
The single apparent `AWAY=2` on `grid187.sv` was run down and is an artifact of
that instrument, not of the patch: the line
`\_int_typespec: , line:24:14, endln:24:17` belongs to **`builtin.sv`**
(`mailbox::try_peek`'s return type), which the dump prints without a file, so
it collides with `grid187.sv:24`. Golden holds **2** copies of that line,
pristine held **5**, and the patched database holds **2** — patched matches
golden's count exactly.

---

## 3. THE TWO MEASURED DIFFERENCES, AND WHY NEITHER IS A DEFECT

**(a) `int signed` / `byte signed` clones carry a WIDER SPAN than golden's.**
For `typedef int signed s_is_t;` golden anchors the per-declaration clone on the
`int` token alone (`4:11-4:14`); ours spans `int signed` (`4:11-4:21`). The
name, the alias, the alias target's name, the signedness and the ranges all
agree. `v187_i_signedonly` reduces the shape until it IS the head: pristine
`48` cmp lines with the `i_is_t` clone as the head object, patched with that
head **CLEARED** (the head moves to an unrelated pre-existing constant-width
residue). So on the judge these four cells are TO-GOLDEN, not still-wrong; the
span is dump-only. **Residue R-V1.**

**(b) a consumed package parameter's clone gains one sharer.** In
`v187_n_consumers`, `localparam int MN2 = Q_W + Q_B;` inside a module gives the
`Q_W` operand's constant a `vpiTypespec`. Golden points it at a separate
`int_typespec` **named `q_i_t`**; before the patch ours pointed at an
**anonymous** `int_typespec`; after the patch it points at the package's own
bare-named clone — **also named `q_i_t`**. The `ref_typespec` `Compare` reads
`VpiName`, `VpiDefName` and `Actual_typespec`, so that edge went from unequal
to equal: this is a second TO-GOLDEN move that the census's `nsh` column
mislabels as AWAY because our object is shared where golden's is copied — and
no generated `Compare` reads a sharing fan-out. This is the same shape as the
implementer's own R4. **Residue R-V2.**

Neither is a shape on which the pristine binary was right and the patched one
is wrong, so nothing in the production surface was changed.

---

## 4. THE PREDICATE, READ AGAINST ITS OWN GATES

`pkgScalarTdParamDefDefer187` gates on: the declared type is a `TypeAlias`
homed in a package; that package is the parameter's own home; the reference is
WRITTEN bare; the alias is not an alias-of-alias; the canonical type is
`int` / `byte` / scalar `bit`. Three gaps between it and
§ `pkgParamBareTdNamedClone18` (which additionally demands `typedParam` and
`ownPkgListing18`) were probed for a fall-through into `drainDefParamTs`'s
fresh-clone path:

* **a re-listed IMPORT COPY in another package** (`v187_a_pkgimport`) — the
  predicate DOES fire (the parameter's home and the typedef's home are the same
  origin package), the share shortcuts ARE blocked, and § 18 then declines
  because `syntaxRefPrefix` names the LISTING package. Measured: our answer is
  byte-for-byte what pristine produced (`WRONG-KEPT`, 0 changed cells). Golden
  mints a bare-named clone parented at the `ref_typespec` there; that face is
  untouched by this pass and belongs to the R2 module/import-copy family.
* **a TYPE PARAMETER's alias** (`v187_g_typeparam`) — `parameter type G_T = int;
  parameter G_T G_P = 1;` is a package-homed `TypeAlias` that is not a typedef
  declaration, so the predicate fires and § 18 declines (no `typedefTs` entry).
  Measured: `G_P` / `G_Q` / `G_LP` all `WRONG-KEPT`, head object unchanged, cmp
  count unchanged at 40/40.
* **`$unit`** (`v187_m_unit`) — rc=4 on BOTH binaries
  (`unsupported constructs: typedef target: PredefinedIntegerType`), confirming
  the implementer's R3; the package half of the same file still moves
  TO-GOLDEN.

The patched binary is deterministic across repeated runs (three `def` runs and
three `elab` runs of `grid187.sv` produce two md5s, one per view).

---

## 5. WHAT THIS VERIFIER CHANGED (probe surface only)

1. `tools/probe/r10uvm187repro/resid187.sh` hard-coded
   `CEN=/tmp/r10uvm187_wd/ct187cen` — a session-ephemeral scratch path. Every
   other script in that directory takes `CEN` from the environment. On any
   machine without that scratch, the census binary is absent, both `"$CEN"`
   calls fail into `2>/dev/null`, the join reads nothing and the scan prints
   `-- residue cells: 0`: a driver that reached NOTHING reading green — the
   exact failure class this campaign's own guards exist for, and a breach of
   the standing rule that drivers must not hard-code a pass's paths. Fixed to
   `CEN=${CEN:?…}` with an `-x` guard and `SCANNED` / `JOINED` / `SKIP`
   counters that abort when the scan joins nothing. Re-run with the fix, it
   reproduces the reported numbers exactly (`SCANNED=1573 JOINED=956 SKIP=617`;
   8 residue cells pristine → 2 patched).
2. This directory: the fifteen adversarial arms, the arm driver
   (`grid187v.sh`), the judge-visible census projection (`jproj187v.py`), the
   order-blind three-way dump scorer (`dump3v187.sh`) and the referrer-naming
   tool (`ctv187refs.cpp`, which attributes an `nsh` delta to a named object).

Production files are **untouched by this verifier** — `src/ParamEmit.cpp` and
`include/UhdmExporter.h` are byte-identical to the implementer's patch, so
every gate above stands for the shipped `.verified.patch`.

**Not fixed, reported instead:** the pass ships no grid driver, so
`GRIDS.r10uvm187.txt` cannot be regenerated from the committed directory the
way `r10uvm180repro/grid180.sh` and `r10uvm181repro/grid181.sh` allow for their
passes. `grid187v.sh` here is a working stand-in.

---

## 6. RESIDUES THIS VERIFIER ADDS

* **R-V1** — a `<kind> signed` / `<kind> unsigned` typedef's per-declaration
  clone is anchored on the whole type syntax where golden anchors it on the
  base-type keyword alone (`4:11-4:21` vs `4:11-4:14`). Judge-invisible (no
  generated `Compare` reads line/col); 0 corpus cells measured.
* **R-V2** — a package parameter consumed in a module expression: golden gives
  the operand constant its own named `int_typespec`, we share the package
  clone. Both are named, so the judge is satisfied; the difference is a sharing
  fan-out, the same family as the implementer's R4.
* **R-V3** — the re-listed import copy of a scalar-typedef'd package parameter
  in ANOTHER package (`v187_a_pkgimport`, `pb187::A_P` / `pc187::A_P`): golden
  mints a bare-named clone parented at the `ref_typespec`; we emit an anonymous
  typespec at the parameter's own span. Unchanged by this pass, 0 corpus cells
  in either corpus, and the natural companion to R2.

## 7. THE FILES

| file | what it is |
|---|---|
| `arms187/v187_*.sv` | the fifteen adversarial arms (see §2) |
| `grid187v.sh` | the arm driver: golden + both binaries, both views, every rc recorded into `cmds.txt` with the binary PATH |
| `jproj187v.py` | projects a `ct187cen` value onto ONLY the fields a generated `Compare` reads |
| `dump3v187.sh` | order-blind three-way whole-dump score (TOWARD / AWAY / NOISE) |
| `ctv187refs.cpp` | lists the REFERRERS of every typespec with a given `VpiName`, so a sharer-count delta can be attributed |
