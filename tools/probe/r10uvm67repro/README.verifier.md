# r10uvm67 — § retLocalPkgRangeBind67 — ADVERSARIAL VERIFICATION

**VERDICT: PASS.**

An independent adversarial verifier rebuilt both binaries from the delivered
patch in its own worktrees, re-ran all five gates, and reproduced **every
number the implementer reported**, including both binary md5s bit-for-bit. The
head is cleared on all three target rows; the whole-design grid shows exactly
one cell moving per design and it is the witness cell; there are **0 SAME→DIFF
transitions anywhere** and **0 empty-product cells changed at whole-design
level**.

This document **replaces** the implementer's own `README.verifier.md`, which
correctly stated that no verifier had run and enumerated six unverified attack
surfaces. **All six were attacked. None produced a defect.** Two of them turn
out to be closed by construction, and the proofs are recorded in §4.

Nothing in the patch was changed by this verification: the delivered production
diff stands as shipped.

| | |
|---|---|
| verifier worktrees | `/tmp/wt_v67` (patched), `/tmp/wt_v67pris` (pristine control) |
| BASE of both | `00b7fda089084e42ca7c51e4e0231aeba8d11fb8`, printed and grep-checked in each |
| patch verified | `/tmp/r10uvm67.patch`, md5 `cbfcec77b11157fd1010d71bff40fdbb` |
| patched binary | md5 `906ced1ada00852a2bcd3ad4bda18ec0` — **identical to the implementer's** |
| pristine binary | md5 `28a566eb8d342b653f0ce68ebe0518ac` — **identical to the implementer's** |
| new instruments | `v3_boundary.sv` (this pass's arm, §4), plus verifier-local `trans.py` / `empty.py` |

---

## 1. PATCH HYGIENE — GREEN

**1.1 Applies clean to a fresh `00b7fda` AND to current head.** Head has moved
past the implementer's `97f6f90` to **`73dc976`** (`r10svs15` then `r10yoo1`
landed). The patch applies clean to both.

```sh
git apply --check --verbose /tmp/r10uvm67.patch          # on 73dc976 -> exit 0
#   include/UhdmExporter.h  hunk #1 succeeded at 3253 (offset 28 lines)
#   src/ModuleEmit.cpp      hunk #1 succeeded at 20807 (offset 18 lines)
#   src/TypeEmit.cpp        clean
```

**1.2 No collision with the "live" passes.** The brief lists `r10svs14` and
`r10earl37` as live; both, plus `r10svs15`, are in fact **already landed** in
`00b7fda..73dc976` and all three touch the same two files. The apply-check
above is over their landed text, so the collision question is settled
empirically, not by inspection.

```sh
git log --oneline 00b7fda..73dc976 -- include/UhdmExporter.h src/ModuleEmit.cpp src/TypeEmit.cpp
#   97f6f90 r10svs15   49475c9 r10earl37   a27a874 r10svs14
```

**1.3 Round-trips to the delivered md5, byte for byte.**

```sh
cd /tmp/wt_v67 && git add -A tools/probe/r10uvm67repro
git diff HEAD --binary -- include src tools/probe/r10uvm67repro > /tmp/v67_roundtrip.patch
# md5 cbfcec77b11157fd1010d71bff40fdbb == delivered;  diff of the two patches: IDENTICAL
```

**1.4 Scope clean.** Every path in the patch is one of the three production
files or `tools/probe/r10uvm67repro/`. Zero paths under `results/`, `tests/`,
or any third-party tree. `results/*.csv` were only read by this verification.

**1.5 `README.verifier.md` was THIS pass's.** The shipped file has its own md5
(`6a4042426a18575e80b50b77c8d16add`), distinct from `r10uvm66repro`'s
(`a945967f…`) and `r10uvm65repro`'s (`bb138c13…`); it names `r10uvm67` four
times and its single mention of `r10uvm66` is the sentence explaining that
pass-66's document was deliberately **not** carried forward. Hygiene as
required — and unusually, the shipped document's self-assessment was accurate
in every particular this verification checked.

**1.6 uvm66 / uvm65 arms hold.** Those passes' probe directories are untouched
by this patch (§1.4), and the corpus rows they converted are byte-identical to
the committed baseline (§3, 0 differing ROWS over all 1588 surelog and 731 u2r
rows).

---

## 2. STATED GATE == CODE GATE — GREEN

**2.1 `retLocalDefView67` is 1 decl, 1 consumer, 1 setter, exactly as stated.**

```sh
grep -rn "retLocalDefView67" include/ src/     # 5 mentions total
#   include/UhdmExporter.h:3238   declaration
#   src/ModuleEmit.cpp:20839      the only setter  (+20835/20844 save+restore)
#   src/TypeEmit.cpp:11053        the only consumer
```

**2.2 Gate 1 of 2 is as described.** In `drainFuncRet`'s `if (!ts)` block:
`sub.getParentScope()->kind == Package` · `retTopView67 = pf.inst ∈ pkgTopMap` ·
sets `tfTypeScope` / `retLocalDefView67` / `syntaxRefSep="::"`, all three saved
and restored around the one `makeTypespec` call. Gate 2 of 2 is one new leading
branch in the S3 arm reading `pkgParamDefRhsDefView17`. No other behavior is
declared and none was found.

**2.3 `pkgParamDefRhsDefView17` really is the map the top pass cannot
overwrite.** Its sole write site is guarded `inPackage && !topView`
(`src/ParamEmit.cpp:12336`), so it holds the DEF-view Rhs permanently. The
stated reason for reading it is therefore correct.

**2.4 The `retTopView67` membership test is a transcription of existing
practice, with an extra guard.** It is byte-for-byte the `topPf1` test 160 lines
above it in the same function (same `pkgTopMap`, same `(UHDM::instance*)` cast
of a `UHDM::package*`), plus an `if (pf.inst)` guard that `topPf1` does not
have. It introduces no cast or comparison pattern that was not already load-
bearing in this file.

---

## 3. THE FIVE GATES, RUN INDEPENDENTLY — ALL GREEN

### GATE 1 — BUILD

Both binaries built by this verifier at `-j2`, link line read before any md5,
md5s asserted in separate commands and matched against `^[0-9a-f]{32}$`.

```sh
grep -E "Linking CXX executable|Built target" /tmp/v67_build3.log
#   Linking CXX executable slang-uhdm / Built target slang_uhdm
grep -cE "error:" ...        # 0 in both
md5sum /tmp/wt_v67/build/slang-uhdm      # 906ced1ada00852a2bcd3ad4bda18ec0
md5sum /tmp/wt_v67pris/build/slang-uhdm  # 28a566eb8d342b653f0ce68ebe0518ac
```

Both md5s are **identical to the implementer's**, from independent worktrees and
an independent configure — a bit-for-bit reproduction of the shipped artifact.
Binary sizes 21 411 120 (patched) / 21 407 280 (pristine).

> **Ops note, confirming the implementer's warning.** My first attempt ran two
> `-j3` builds concurrently and **both were OOM-killed** — `c++: fatal error:
> Killed signal terminated program cc1plus`, which `grep -c "error:"` *does*
> catch, but only because that message happens to contain `error:`. The machine
> was carrying ~15 other agents' compilers at 14 GB. Read `free` first; a build
> at 77 % (`Built target slang_uhdm_obj_lib`) with no `Built target slang_uhdm`
> **has not linked** and its binary is stale.

### GATE 2 — GOLDENS

```sh
SLANG_UHDM=/tmp/wt_v67/build/slang-uhdm ./tests/check_goldens.sh   # PASS 23  FAIL 0
SLANG_UHDM=/bin/false                   ./tests/check_goldens.sh   # PASS  0  FAIL 23
```

> **Trap re-confirmed:** `check_goldens.sh` defaults `SLANG_UHDM` to the
> **main-tree** binary. My own first invocation omitted it and therefore
> measured the wrong build. `SLANG_UHDM=` is not optional. The implementer set
> it correctly.

### GATE 3 — u2r, `--jobs 2`, own `--out`/`--workdir`

731 rows per mode. **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in both
modes**; testflags dump column **496 match / 183 differ / 52 blank** — every
figure as reported.

```sh
bash ct8rows.sh results/gate_uhdm2rtlil.csv <my testflags rows>
#   0 differing ROWS (0 diff row-sides); status and dump histograms identical
#   PASS: every row byte-identical to the committed baseline
diff <(sort u2r_patched.csv) <(sort u2r_pris.csv)    # IDENTICAL
```

### GATE 4 — surelog, both modes, `--jobs 2`

1588 rows. **default 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED**;
**testflags 463 / 10 / 5 DEFERRED**. `GOLDEN_DEFER` `[UNSET]`.

```sh
bash ct8rows.sh <results/golden_surelog.csv @00b7fda> sl_patched.csv
#   0 differing ROWS; all four histograms (status x mode, dump x mode) identical
diff <(sort sl_patched.csv) <(sort sl_pris.csv)      # IDENTICAL — 0 differing ROWS
```

The baseline had to be taken **at `00b7fda`** (`git show 00b7fda:results/…`),
not at head: `r10svs15` and `r10yoo1` have since promoted the suite to 469/11
and 465/8. The single `testflags TIMEOUT` row is present in the **committed
baseline** too, so it is pre-existing and not contention from my sweeps.

### GATE 5 — BYTE VERIFIER, both corpora, both controls

```sh
SELFCHECK=1 SELFCHECK1=1 bash byteverify.sh <patched wd> <pristine wd>
```

| corpus | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|
| surelog | **7 / 953** | 952 / 953 | 8 = 7 + 1 |
| u2r | **0 / 1358** | 1357 / 1358 | 1 |

Path sets identical on both. The 7 movers are **exactly** the 7 named:
`default/{BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM}` +
`testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}`.

---

## 4. THE SIX UNVERIFIED ATTACK SURFACES — ALL ATTACKED, NONE DEFECTIVE

The implementer's own `README.verifier.md` §2.3–§2.6 named these. New arm
`v3_boundary.sv` plus four reduced cells (`c1_foreign`, `c2_td`, `c3_iface`,
`c5_clone`) were written for them.

**4.1 The `$unit` parameter and `$unit` enum-constant surfaces are UNREACHABLE
BY LANGUAGE RULE — closed by construction.** Setting `tfTypeScope` changes
`bindScope` for the `unitParamMap` and `enumConstMap` arms
(`src/TypeEmit.cpp:11079`, `:11138`), which looked like the widest exposure in
the patch. It cannot be reached: a package may not name a compilation-unit item.

```
v3_boundary.sv:30:16: error: cannot reference compilation unit item from within a package
```

Since the pass's gate is Package-only, no package-homed subroutine's range can
ever resolve to a `$unit` param or `$unit` enum. Surface closed — and closed by
the *language*, not by the gate's luck.

**4.2 The foreign-package fold branch is DEAD in the drain — proved with the
shipped trace, not by argument.** `pkgTsParam9`/`pkgTsForeign9`
(`src/TypeEmit.cpp:10876`) is gated `curPkgEmitSym && !tfTypeScope`, so setting
`tfTypeScope` would *disable* it — the one place the patch could have silently
removed a fold. It cannot: `curPkgEmitSym` is restored to null before
`drainFuncRet` runs. `R10UVM67_REFDBG=1` shows it directly:

```
DBG67 name=C5_W … bound=operation tfTs=1 curPkg=c5pkg …   <- emitTaskFuncs (pre-existing)
DBG67 name=C5_W … bound=constant  tfTs=1 curPkg=c5pkg …
DBG67 name=C5_W … bound=operation tfTs=1 curPkg=-     …   <- the DRAIN: curPkg NULL
DBG67 name=C5_W … bound=constant  tfTs=1 curPkg=-     …
```

`curPkg=-` on both drain lines. The branch was already unreachable there. The
same four lines also show the def/elab discrimination working: **one
`operation`, one `constant`**, which is the law's central claim.

**4.3 The `§ pkgTdCloneRefNoBind18` fence HELD — measured, and the pass is
totally inert there.** A package function whose return type *is* a package
typedef whose own range names a parameter (`c2_td.sv`): the pristine and
patched **dumps are byte-identical**. The inherited `!tdCloneRefNoBind18` guard
is doing its job.

```sh
cmp -s c2_td.pris.dump c2_td.pat.dump   # IDENTICAL
# grid unchanged: DIFF -> DIFF, G=NULL,NULL,operation,operation  O=NULL,NULL,operation
```
Arm a2's own `m11` cell (`A2_LARGE@93:16`) independently corroborates: DIFF
before, DIFF after, byte-identical actuals.

**4.4 The wildcard-import CLONE body — the `pf.inst == nullptr` case of §2.4 —
HELPS, and matches golden exactly.** This is the entry whose `pkgScope` is
false at the push site, so `retTopView67` is forced false and
`retLocalDefView67` forced true. `c5_clone.sv` measures it:

```
PRISTINE  DIFF  ('C5_W','8:16-8:20')  G=const,const,op,op  O=NULL,NULL,const,op
PATCHED   SAME  ('C5_W','8:16-8:20')  G=const,const,op,op  O=const,const,op,op
per-cell transitions: DIFF->SAME 1 ; SAME->non-SAME 0
```

**4.5 `syntaxRefSep = "::"` is genuinely cmp-invisible — confirmed from UHDM's
generated source, as requested.** `ref_obj::Compare` compares `VpiType`,
`VpiName`, `VpiDefName`, `VpiGeneric`, `SafeCompare(Actual_group)`,
`VpiStructMember` — and **not** `VpiFullName`. No class in the inheritance chain
does either.

```sh
grep -n -A40 "ref_obj::Compare" ~/git-repos/UHDM/build/generated/src/ref_obj.cpp
for c in simple_expr expr any BaseClass; do grep -c VpiFullName src/$c.cpp; done   # 0 0 0 0
```

The separator change is therefore dump-only — and it moves **toward** golden,
not merely sideways:

```
GOLDEN   vpiFullName:a2pkg::a2_to_bits::a2_to_bits::A2_LARGE
PRISTINE vpiFullName:a2pkg::a2_to_bits::a2_to_bits.A2_LARGE     <- ours, dot
PATCHED  vpiFullName:a2pkg::a2_to_bits::a2_to_bits::A2_LARGE    <- now golden's text
```

**4.6 Interface- and program-scope subroutines: program is fine; the interface
shape SEGFAULTS IDENTICALLY ON BOTH BINARIES.** A standalone interface holding
a function whose return-type range names an interface parameter crashes
`slang-uhdm`. **Pristine `rc=139`, patched `rc=139`** — pre-existing, not a
regression, and out of this pass's scope (the gate is Package-only, so the
patch never runs there). Recorded as a new campaign finding in §6.

```sh
/tmp/wt_v67pris/build/slang-uhdm c3_iface.sv -o x.uhdm   # Segmentation fault (139)
/tmp/wt_v67/build/slang-uhdm     c3_iface.sv -o x.uhdm   # Segmentation fault (139)
```

---

## 5. THE MEASUREMENTS, REPRODUCED

### 5.1 The head — cleared on all three rows

LHS always golden. `uhdm-cmp <golden> <ours>` on my own two builds:

| row | PRISTINE | PATCHED |
|---|---|---|
| `default/SimpleUVM` | 33 lines, head `constant@410:30-410:60`, `RHS: <null>` | **58 lines, head `int_var …m_set_attribute::file@1038:18`** |
| `testflags/SimpleUVM` | 33, same head | **58, same new head** |
| `default/Scoreboard` | 33, same head (id 23108) | **58, same new head** |

The brief's description of the head object is confirmed byte-for-byte
(`vpiDecompile 115199`, `vpiSize 32`, `INT:115199`, `vpiConstType 7`,
`ref_typespec (uvm_pkg)` → `int_typespec @410:1-410:62`) — **and so is the
implementer's refutation of the brief's reading of it**: `RHS: <null>` is
`SafeCompare(lhs, nullptr)` reporting the object a dangling `ref_obj` should
have pointed at, which is why the fix is in the reference and not in any
typespec-minting owner the brief fenced.

### 5.2 The new head is PRE-EXISTING — the check their §3 asked for first

Their doc asked a verifier to confirm the promotion directly rather than by
re-reading the head, because `m_visited` makes head identity order-dependent. I
did it on the object itself, in the **pristine** database:

```
GOLDEN   819738..819749   int_var … m_set_attribute::file @1038:18   (no vpiSigned line)
PRISTINE 812940..812953   … identical block PLUS  |vpiSigned:1       <- the divergence
```

The two blocks differ by exactly that one line, in the **control** binary's own
output. And `variables::Compare` does read `VpiSigned`, so the divergence is
Compare-visible, not dump-cosmetic. Residue 1 is pre-existing and this pass did
not create it.

### 5.3 Arm a2 — cell for cell

TABLE B: **SAME 2→7, DIFF 6→1, UNMEASURED 3→3.** Per-cell transitions, not
counts:

```
DIFF -> SAME  ('A2_LARGE','40:16-40:24')   m01 the witness shape
DIFF -> SAME  ('A2_LARGE','77:16-77:24')   m08 expression bound
DIFF -> SAME  ('A2_LIT',  '50:16-50:22')   m03 literal-init twin
DIFF -> SAME  ('A2_LOCAL','55:16-55:24')   m04 localparam twin
DIFF -> SAME  ('A2_TYPED','60:16-60:24')   m05 typed twin
SAME->non-SAME (REGRESSIONS): 0
```

m01 moved `{NULL,NULL,const,op}` → `{const,const,op,op}` = golden's multiset,
exactly as claimed. m02 (argument range) and m06 (body-local) were already SAME
and stayed SAME. m11 stayed DIFF (§4.3).

### 5.4 Whole design — one cell each, and it is the witness

| test | SAME | DIFF | the cell that moved |
|---|---|---|---|
| SimpleUVM | 7 → **8** | 6 → **5** | `('UVM_LARGE_STRING','421:16-421:32')` |
| BuildUVMPkg | 13 → **14** | 3 → **2** | `('UVM_LARGE_STRING','9755:16-9755:32')` |
| SeqDriver | 4 → **5** | 9 → **8** | `('UVM_LARGE_STRING','421:16-421:32')` |
| Scoreboard | 9 → **10** | 4 → **3** | `('UVM_LARGE_STRING','421:16-421:32')` |

**`SAME→non-SAME` regressions: 0 in all four.** Every other cell held its
status. OVER-FIRE 0 confirmed per object, not by count — counts alone can hide
one regression paired with two gains, so transitions were computed per key.

The implementer's summary omitted Scoreboard from this table; measured, it also
moves 1 cell DIFF→SAME. The accounting **understates** by one design.

### 5.5 Movers — per shape, ADDED and REMOVED never netted

All four default movers, identical shape in each (BuildUVMPkg at its
single-unit line offsets):

```
ADDED   total=8      REMOVED total=4
  +2  |vpiActual:                                       -2  \_ref_obj: (…uvm_string_to_bits.UVM_LARGE_STRING)
  +2  \_ref_obj: (…uvm_string_to_bits::UVM_LARGE_STRING) -2  |vpiFullName:…uvm_string_to_bits.UVM_LARGE_STRING
  +2  |vpiFullName:…uvm_string_to_bits::UVM_LARGE_STRING
  +1  \_operation: , line:410:30, endln:410:62          <- the DEF view
  +1  \_constant:  , line:410:30, endln:410:60          <- the ELAB view
```

The **4 REMOVED are a RENAME, not a deletion** — the same two objects, `.` → `::`
(§4.5). And the added texts land at **exactly golden's count**:

```
                                                    GOLDEN  PRISTINE  PATCHED
  …uvm_string_to_bits::UVM_LARGE_STRING), 421:16       2        0         2
  vpiFullName:…uvm_string_to_bits::UVM_LARGE_STRING    2        0         2
  …uvm_string_to_bits.UVM_LARGE_STRING  (the dot form) 0        4         0
```

Exactly **one** `operation` and **one** `constant` added — the two views binding
different objects, which is the law's core assertion, visible in the shapes.

### 5.6 Distance to golden — all 7 movers, all toward golden

Multiset distance, LHS always golden:

| mover | pristine | patched | GAIN |
|---|---|---|---|
| `default/BuildUVMPkg` | 80345 | 80337 | **8** |
| `default/Scoreboard` | 134025 | 134013 | **12** |
| `default/SeqDriver` | 366876 | 366866 | **10** |
| `default/SimpleUVM` | 143692 | 143680 | **12** |
| `testflags/BuildUVMPkg` | 80345 | 80337 | **8** |
| `testflags/SeqDriver` | 366876 | 366866 | **10** |
| `testflags/SimpleUVM` | 143688 | 143676 | **12** |

`8 / 12 / 10 / 12 / 8 / 10 / 12` — the implementer's sequence exactly, including
the `80345 → 80337` figure quoted in their table.

### 5.7 Multi-stability — and a new proof that the chosen metric is sound

`detcheck.sh`, Scoreboard, **4 reps per binary**:

```
PRISTINE  4 runs, 3 distinct db hashes, ALL at 11 122 260 bytes
PATCHED   4 runs, 2 distinct db hashes, ALL at 11 122 279 bytes
                                            delta = +19 B   <- exactly as reported
```

Size stable within each binary ⇒ the multiple hashes are the pre-existing flake;
the **+19 B is real and in the ADD direction**. The patched binary is if
anything *less* variable than the control (2 hashes vs 3).

> The implementer's *absolute* sizes (11 122 503 / 11 122 522) differ from mine
> (11 122 260 / 11 122 279) because **the workdir path is embedded in the
> database** — the campaign's own `file:<workdir>` normalisation rule. Absolute
> byte counts are not reproducible across workdirs; **the +19 B delta is**, and
> it is the figure that carries the claim.

**New result — the flake is a PURE REORDERING, so every multiset number above
is flake-immune.** Three pristine runs of Scoreboard gave three different
*dump* hashes at identical line counts, yet:

```
r1 vs r2 : multiset distance = 0   (ADDED 0 / REMOVED 0)
r2 vs r3 : multiset distance = 0
r1 vs r3 : multiset distance = 0
```

This matters for reading GATE 5 honestly: **hash comparison is not flake-immune,
so byteverify's "7 movers" is an upper bound**, while the multiset and per-cell
instruments are exact. That is why all 7 were additionally confirmed by shape
(§5.5), by grid transition (§5.4) and by size (+19 B, where the flake is
size-preserving) — three independent confirmations, none of which relies on the
database hash. The 7 are real.

### 5.8 Canaries

```
canaries.sh  surelog  ok=52 changed=0 absent=0 unknown-names=7
canaries.sh  u2r      ok= 8 changed=0 absent=0 unknown-names=25
ctcan2.sh  EXPECT_UNKNOWN=1 (surelog, baseline FIRST)  ok=58 changed=0  PASS
ctcan2.sh  EXPECT_UNKNOWN=6 (u2r,     baseline FIRST)  ok= 1 changed=0  PASS
canaudit.sh                       audited=29  UNCOVERED=0  FENCE-BREACH=0
```

`InterfaceModPort`, `BlackParrotComplex`, `SimpleConstraint`, `SVSwitch`,
`ApbSlave`, `SeqDriver`, `BuildUVMPkg`, `SimpleUVM`, `Scoreboard` checked BY
NAME in both modes: all 18 rows `== baseline`. The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched
by no canary driver and their corpus rows are byte-identical to the baseline.

---

## 6. EMPTY PRODUCT CELLS — THE HUNT, AND THE ONE FINDING

An "empty product cell" is agreement that costs nothing: one side has no object
at the key (`-NOOBJ-`), or both sides are unbound (`NULL` vs `NULL`).
`ct67cells.py` is honest here by construction — a key present on one side only
is `UNMEASURED` and never counted as `SAME` — but `BOTH-DANGLING` keys *are*
counted `SAME`, so the SAME totals need reading.

**6.1 At whole-design level, 0 empty-product cells were changed by the patch.**
SimpleUVM has 7 of them (6 BOTH-DANGLING, 1 OURS-HAS-NO-OBJECT at
`uvm_phase@593:86`); **all 7 untouched**. The single `UNMEASURED` cell in each
of the four designs is untouched (§5.4 transitions: `UNMEASURED→UNMEASURED 1`).

**6.2 But `SAME=8` on SimpleUVM overstates substantive agreement: 6 of those 8
are BOTH-DANGLING.** Only 2 SAME cells are agreements on an actual binding —
and the cell this pass created is one of them. The pass's win is real and it is
one of only two substantive agreements on that design. Worth stating plainly so
the number is not read as "8 bindings agree".

**6.3 Arm a2's three empty-product cells are all untouched, and the
implementer identified them correctly.** `m12@103:16` (module-scope twin:
golden `-NOOBJ-`, ours `NULL,NULL`) — **correctly refused**, binding it would
mint agreement with nothing, exactly as their write-up says. `m09@82:8` (ours
`-NOOBJ-`) and `m10@86:18` (golden `-NOOBJ-`, ours already binds a constant — a
pre-existing over-bind) are both untouched and both disclosed in their residue 6.

**6.4 FINDING — one empty-product cell IS changed by the patch, in a shape arm
a2 does not contain: a range bound naming an IMPORTED FOREIGN package's
parameter.** Arm a2 has no foreign-package cell; my `c1_foreign.sv` adds one.

```
('V3O_W','8:16-8:21')   GOLDEN = -NOOBJ-          (golden emits no ref there at all)
                        PRISTINE = NULL,NULL,constant,constant
                        PATCHED  = constant,constant,constant,operation
```

The patch converts two dangling refs into bindings **in a cell where golden has
no counterpart object** — the same "agreement with nothing" hazard the
implementer correctly refused for the module-scope twin, occurring unnoticed
here because the arm had no cell for it.

**It is not a defect, and it is not a regression.** Measured both ways:

```
cmp head:  PRISTINE 46 lines, head constant@8:16  |  PATCHED 46 lines, head constant@8:16   (IDENTICAL)
multiset distance to golden:  208 -> 204   (improves by 4)
same-package control in the same file ('V3P_W','14:16'):  DIFF -> SAME
```

cmp-neutral, dump-favourable, and the same-package control in the same file
moves DIFF→SAME. So: a **scope gap in the arm, not a bug in the law** — the law
fires on an imported foreign parameter as well as an own-package one, which
nothing in the pass claims and nothing in the corpus punishes. It belongs on
the residue list (§7.6) as the next question in this family, and it is the one
item this verification adds that the pass did not already know.

---

## 7. RESIDUES, RANKED (verifier's own ranking)

1. **The new head, all three rows (58 lines): `int_var …m_set_attribute::file@1038:18`
   carries `vpiSigned:1`, golden does not — PRE-EXISTING.** Proved on the control
   binary's own dump, one line apart from golden's block, and `variables::Compare`
   reads the field (§5.2). This is the next head on these rows and it is a
   *signedness* law, unrelated to range binding.
2. **`design.Parameters` / `Param_assigns` NULL vs golden 45 each; `module_inst
   work@top` 0 vs 90; our `class_defn work@env` shares the package's objects
   where golden clones.** The `$unit`-import materialisation. **NOT independently
   reproduced** — the implementer flagged it as their own triage and I did not
   re-derive it; my spot check is only *direction*-consistent (golden 5 vs ours 7
   `parameter: (uvm_pkg::UVM_LARGE_STRING)` prints, i.e. a share/clone
   multiplicity difference). Largest item left; treat the 45/90 figures as
   unverified.
3. **Elab-view `parameter uvm_pkg::UVM_LARGE_STRING` value encoding —
   REPRODUCED.** Golden `|INT:115199`, ours `|UINT:115199`. The object next
   door to the brief's, one field wide, and the smallest well-defined item on
   the list.
4. **`design.Typespecs` 123 vs 89** — the typedef half of residue 2; not
   independently reproduced.
5. **Three more range-bound families**, unchanged by this pass and confirmed
   still DIFF: `UVM_HDL_MAX_WIDTH@50:16` (golden binds the *parameter* object,
   not its Rhs), `UVM_STREAMBITS@49:23`, `uvm_phase@1722/1896/1946`. These share
   one open question with §7.6.
6. **NEW (§6.4): when the range bound names an IMPORTED FOREIGN package's
   parameter, golden emits no ref at all and we now emit four bound ones.**
   cmp-neutral, distance-favourable, arm-only. Together with residue 5 this is
   the single open question in the family: *when does Surelog bind a range ref
   to the `parameter` OBJECT, when to its Rhs, and when does it emit no ref at
   all?* Arm `c1_foreign.sv` is the cell to work from.
7. **NEW: `slang-uhdm` SEGFAULTS on an interface holding a function whose
   return-type range names an interface parameter** (`c3_iface.sv`, rc=139).
   **Identical on pristine and patched** — pre-existing, out of scope here, but
   it is a crash and nothing in the corpus covers it. Worth its own pass.
8. Arm-only range-bound families still open: package-var (`m09`),
   package-typedef (`m11`, fenced by design), class-method (`m10`, a
   pre-existing over-bind where golden has no object).
9. `|vpiActual:` 272 instances short on SimpleUVM at that indent; and the four
   package-view `param_assign` families and the import-materialised span rule
   from arm a1 — all the implementer's triage, not re-derived here.

---

## 8. WHAT THIS VERIFICATION DID NOT DO

Stated plainly, so the next reader does not over-credit this document.

1. **Residues 2, 4 and 9 were not independently reproduced.** They are the
   implementer's triage, carried forward with their provenance marked. My only
   check on residue 2 was a direction-consistent print count.
2. **Arm a1 (`a1_pkgparamts.sv`) was not re-gridded.** The pass's a1 claims
   (package view 31 SAME / 5 DIFF with both witness cells SAME;
   import-materialised view 7/29) are unverified here. a2 — the arm the law
   actually turns on — was verified cell for cell.
3. **No third build at current head `73dc976`.** The patch was proved to *apply*
   clean there (§1.1) and the three landed passes' regions were shown not to
   conflict, but the gates were run at `00b7fda`, where the implementer's
   numbers live, so that they could be compared like for like. A landing gate at
   head is still worth one build.
4. **The `folded` diagnostic mode was not swept** (`--mode both`, per the gate
   definition).
5. My sweep workdirs are **deleted** (2.2 GB); `results/*.csv` were only ever
   read.

---

## 9. BOTTOM LINE

Every number in the implementer's report that this verification could check —
both binary md5s, all five gates, the head on three rows, the arm grid cell for
cell, the whole-design grid, the 7 movers by name, ADDED 8 / REMOVED 4 per
mover, the three-way counts, all 7 distance gains, the +19 B delta, and every
canary — **reproduced exactly**. Two figures were found to be *understatements*
(Scoreboard's whole-design cell was omitted from their table; their absolute
dump sizes are workdir-dependent while the delta they rest on is not).

All six attack surfaces their own document flagged were exercised. Two are
closed by construction (§4.1, §4.2), one fence is measurably inert (§4.3), one
suspected mis-fire is instead a gain (§4.4), the cmp-invisibility claim is
confirmed from UHDM source (§4.5), and the last uncovered a **pre-existing
segfault unrelated to the patch** (§4.6).

The one thing this verification adds is §6.4: the law also fires on an imported
**foreign**-package parameter, in a cell where golden emits no object. It is
cmp-neutral and distance-favourable, so it changes no verdict — but it is a
genuine gap in the arm's coverage and it is the natural next question in this
family.

**PASS.** Land it.
