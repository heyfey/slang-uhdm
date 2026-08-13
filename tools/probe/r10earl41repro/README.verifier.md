# r10earl41 — ADVERSARIAL VERIFIER RECORD

**This file is THIS pass's and was written by the INDEPENDENT VERIFIER.**
The implementer deliberately shipped **no** `README.verifier.md` and said so in
`README.md` § 9; that was the right call and nothing has been carried forward
from any earlier pass. Every number below is from binaries **I** built in **my
own** worktrees at the mandated base `19730ce`, and every command is printed.

---

## VERDICT: **PASS (with two recorded findings, neither of which blocks a gate)**

* **All five gates GREEN**, re-run independently end to end.
* **Both of my builds are BIT-IDENTICAL to the implementer's reported md5s**,
  so the whole write-up is anchored to binaries I can reproduce byte for byte.
* **Every headline number reproduces TO THE UNIT** — the grid (0 regressed /
  9 HOLD-OK / 17 moved), F3 (12+16 malformed names → 0), F4 (byte-identical
  dump, −153 B on the isolating probe), the census (BARE_TAIL 24 → 0, qualified
  `var_select` def 4/4 and elab 10/10 EXACT), the multiset distance
  (308889 → 308773, −116, closing to the unit), 144 ADDED / 144 REMOVED,
  74 away-shapes all with `golden = 0` **and** `pristine = 0`, and the Earlgrey
  head byte-identical to `r10earl40repro/r6_nexthead.cmp`.
* **The law's discriminator is CORRECT and I re-derived it**: golden really
  does name the imported-bare cell `A` and the written-qualified cell `q41::A`
  for the *same symbol in the same package through the same import*. The
  "declared in a package" test would have moved the bare cell AWAY.
* **The implementer's refutation of r10earl40's README is CORRECT**, and I
  confirmed its mechanism in the UHDM source, not just in prose (§ 6).

PASS rather than PARTIAL because nothing in the write-up is measurably false in
a way that changes a decision, no gate moves, and the two findings are (V1) an
**overstated completeness claim** about F3 plus the residual defect it leaves
latent, and (V2) a **file-level boundary collision** with a live pass. Both are
recorded below with their commands.

---

## 0. WHAT I BUILT AND RAN (nothing inherited)

```
worktree           base                                       md5(build/slang-uhdm)
/tmp/wt_v41pris    19730ce655fe913bbd12a503d5ef9599e09225f3   d90af4f662bab7e66f24bfe6258a8f9b   git status clean
/tmp/wt_v41        19730ce655fe913bbd12a503d5ef9599e09225f3   0b7bba3fa768a345acb8ab02b6b6ed4c   + /tmp/r10earl41.patch
```

`/tmp/r10earl41.patch` md5 **`8ae1983234f9df8704fe42f9dfc68563`**, `git apply
--check` clean at `19730ce`. `grep -c 'Built target slang_uhdm$'` = **1** and
`grep -icE 'error:'` = **0** on both; both md5s taken in a separate step and
asserted 32-hex. **Both values are BIT-IDENTICAL to the implementer's**, which
is the strongest available answer to "did you measure the binary you think you
measured".

> Note: the repo head has moved on to `ba7d1ef`. I verified at the **mandated
> base `19730ce`**, which is what the patch is cut against.

---

## 1. THE FIVE GATES, RE-RUN

**GATE 1 — BUILD.** Absolute paths, `-j 2`, waited for the link line, md5
asserted separately. Pristine worktree `git status --porcelain` = 0 lines at
`19730ce`. **GREEN.**

**GATE 2 — GOLDENS.** `SLANG_UHDM` exported explicitly (the script silently
defaults it to the main tree):

```
SLANG_UHDM=/tmp/wt_v41/build/slang-uhdm     bash tests/check_goldens.sh | grep -c '^PASS'   -> 23   FAIL 0
SLANG_UHDM=/tmp/wt_v41pris/build/slang-uhdm bash tests/check_goldens.sh | grep -c '^PASS'   -> 23
SLANG_UHDM=/bin/false                       bash tests/check_goldens.sh                      -> 0 PASS / 23 FAIL
```

**GREEN**, negative control fires.

**GATE 3 — uhdm2rtlil**, `--mode both --jobs 2`, own `--out`/`--workdir`:

```
[default]   731 tests  CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2
[testflags] 731 tests  CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh testflags projection>  (731 vs 731 ROWS)
  ---- WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  testflags dump: base 52 blank / 183 differ / 496 match  ==  fresh 52 / 183 / 496
  PASS: every row byte-identical to the committed baseline
```

**GREEN — 679/50/2 both modes, 496/183/52, 0 rows.**

**GATE 4 — surelog**, `--jobs 2`, **one invocation per mode**, run sequentially
so the documented `SURELOG_FAIL` detail-row race cannot fire; `GOLDEN_DEFER`
left UNSET throughout:

```
[default]   794 tests  CMP_EQUAL 469  CMP_NOTEQUAL 11  SURELOG_FAIL 25  DEFERRED 5   SLANG_REJECT 284
[testflags] 794 tests  CMP_EQUAL 465  CMP_NOTEQUAL  8  SURELOG_FAIL 23  DEFERRED 5   SLANG_REJECT 286
                                      NO_DATABASE 3  NO_UHDM 1  TIMEOUT 1  UNTRANSLATABLE 2
ct8rows.sh results/golden_surelog.csv <both modes concatenated>  (1588 vs 1588 ROWS)
  ---- WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  default   dump: 325 blank / 244 differ / 225 match   (base == fresh)
  testflags dump: 329 blank / 300 differ / 165 match   (base == fresh)
  PASS: every row byte-identical to the committed baseline
```

**GREEN — 469/11 + 465/8, FAIL 25/23, DEFER 5/5, histograms unchanged, 0 rows.**

Independent cross-check: I swept **both** binaries over **both** corpora, and
`diff sl_pat_all.csv sl_pris_all.csv` and `diff u2r_pat.csv u2r_pris.csv` are
**both empty** — every row number above is a property of the code, not of the
machine.

**GATE 5 — BYTE VERIFIER**, `byteverify41.sh`, both corpora, both modes,
patched vs the pristine `19730ce` I built:

```
uhdm2rtlil : patched=1358 pristine=1358  PATH_SETS_IDENTICAL   MOVERS: 0 / 1358
surelog    : patched= 953 pristine= 953  PATH_SETS_IDENTICAL   MOVERS: 2 /  953
  MOVER ./default/Earlgrey_0_1-71da2fd7  patched=db5d5f79efc7  pristine=c2384ffe6132
  MOVER ./default/Scoreboard-59431470    patched=8a2c4827db5b  pristine=9d3fd083f4f1

uhdm2rtlil  SELFCHECK=1 -> 1357 / 1358 flagged      SELFCHECK1=1 -> 1
surelog     SELFCHECK=1 ->  952 /  953 flagged      SELFCHECK1=1 -> 3
```

Both mandatory controls fire on both corpora. The Earlgrey md5s are
**identical to the implementer's reported pair**.

### The two movers, arbitrated by the stated law

```
SIZE  Earlgrey_0_1  patched 49941318  pristine 49940463  -> +855   SIZE DELTA, REAL
      Scoreboard    patched 11122938  pristine 11122938  -> SAME SIZE
```

**3 reps of EACH binary**, `--filter Scoreboard --mode default --jobs 2`, fresh
workdir per rep:

```
pris rep1 9d3fd083f4f172a7   rep2 9d3fd083f4f172a7   rep3 9d3fd083f4f172a7   (11122938 B)
pat  rep1 9d3fd083f4f172a7   rep2 ed015f929da634a6   rep3 9d3fd083f4f172a7   (11122938 B)
```

**The PATCHED binary produces the PRISTINE binary's exact md5 in 2 of 3 reps,
and a third value in the other** — at a constant size. `Scoreboard` is a FLAKE
by both halves of the stated test (size-delta 0, and the two binaries' output
sets overlap), and it is the documented emitter nondeterminism, not this patch.
My `pat rep2` value `ed015f92…` is one of the three the implementer recorded for
the *pristine* binary, which is about as direct a proof of binary-independence
as this instrument can give.

**The one REAL mover in 2311 databases is `Earlgrey_0_1/default` — the target.**

---

## 2. F3 AND F4 — THE TWO BRIEF-MANDATED FIXES, PROVEN

### F3 (`§ qualSelBaseNoWhitespace41`) — REPRODUCED

`arm41.sh a1_earl41.sv`, malformed identifiers (whitespace inside a qualified
name), counted over the whole dump:

| dump | `vpiName`/`vpiDefName` malformed | `vpiFullName` malformed |
|---|---|---|
| GOLDEN | 0 | 0 |
| PRISTINE | **12** | **16** |
| PATCHED | **0** | **0** |

The child witness the write-up names reproduces exactly:

```
pristine  work@a1_earl41.gb.q41::A .g      (count 2)
patched   work@a1_earl41.gb.q41::A.g       (count 14, the space form now 0)
```

All four whitespace placements (`q41 ::A`, `q41:: A`, `q41 :: A`, `q41::A `)
move to golden's `q41::A`. **See finding V1 for what this fix does NOT cover.**

### F4 (`§ selChainDecideBeforeMint41`) — REPRODUCED

I first established that **`.uhdm` byte sizes are workdir-path-length
dependent** (the absolute numbers in `README.md` § 5 are not reproducible as
absolutes — see V3), so I ran **both binaries through the SAME directory path**
`/tmp/v41_orphWD`:

```
                        dump md5 (sed 1d)                    bytes
v41_bare    PRIS  692f189e009aeca74e768963785e84f8           13559
            PAT   692f189e009aeca74e768963785e84f8   IDENTICAL  13406   -153
v41_orphan  PRIS  ...                                        12683
            PAT   ... (dump moves: qualified base)            12572   -111
v41_ctrl    PRIS/PAT  (no abstain; dump moves by the naming law) 12918 -> 12943  +25
```

**`v41_bare` is the proof: a BYTE-IDENTICAL uhdm-dump and 153 fewer bytes.**
The control that never abstains *grows* (+25) by the naming law alone, so the
qualified probe's −111 is a net of two effects and not the measurement.

I also ran **earl40's own probe**, which the brief names: `v40_orphan.sv`
12683 → 12572 with its dump moving only by the qualification of `r40::A` (24
lines, all `A` → `r40::A`). earl40's recorded absolutes (12569 / 12701) are at a
different base and a different workdir path and are not comparable as absolutes;
the isolating `v41_bare` case is the sound instrument and it is clean.

**Code review of the pre-scan**: the loop's `else` arm returned `nullptr`, and
the pre-scan returns `nullptr` for exactly the complement of
`{BitSelect, SimpleRangeSelect}` — so the returned VALUE is unchanged for every
input and only the arena minting is removed. I checked that `emitSyntaxExpr` has
**no** `refCollector` or deferred-bind side effects (`grep -n refCollector
src/TypeEmit.cpp` → 0 hits), so nothing observable is lost by not walking the
children. **The equivalence is exact.**

---

## 3. THE GRID, RE-COMPUTED WITH MY OWN INSTRUMENT

I did not take `cells41.py`'s verdicts; I re-derived them from the three dumps
with my own comparator (key = `(cell, view)`, value = the select-family
`vpiName` of the assignment's RHS root):

```
0 REGRESSED   9 HOLD-OK   17 MOVED->GOLDEN   2 STILL-OFF   0 EMPTY-PRODUCT
```

which is the headline claim exactly. **I specifically hunted EMPTY PRODUCT
CELLS and found none**: all 19 cells produce a select object on the golden side,
and the two views are genuinely distinguishable. The module-level cells have no
ELAB row **on either side** (golden's elaborated top carries no RHS at those
spans), so `README.md` § 2b's omission of them is honest rather than selective.

The two `STILL-OFF` rows are the declared residues and nothing else:
`c_mpr_pkg_rng` (R1′, golden `p41::C` vs ours `C`) and `c_gca_pkg_bidx` DEF
(R3, the `+:`/`-:` abstain).

**The discriminator, re-derived from golden alone** — this is the load-bearing
cell and it is real:

```
golden  c_mpr_imp_blit   A[1][DW-1:0]        var_select vpiName: A        (+ vpiFullName work@a1_earl41.A)
golden  c_mpr_impq_blit  q41::A[1][DW-1:0]   var_select vpiName: q41::A   (no vpiFullName at all)
```

Same parameter, same package, same import, same construct. **The written
spelling is the whole gate.** A home-package test would have moved
`c_mpr_imp_blit` away from golden.

I also confirmed golden stores **no** `vpiFullName` on a qualified select while
we store one — the residue R2 the write-up ranks, visible in every patched cell.

---

## 4. BOUNDARIES AND FENCED ARMS

| arm | pristine vs patched |
|---|---|
| `r10earl38repro` chain (`bnd_a1_chain.sv`) | **DUMP BYTE-IDENTICAL**, `cmp.log` identical |
| `r10earl38repro` fence (`bnd_a2_fence.sv`) | **DUMP BYTE-IDENTICAL**, `cmp.log` identical |
| `r10earl39repro` argts (`bnd_a1_argts.sv`) | **DUMP BYTE-IDENTICAL**, `cmp.log` identical |

**earl40's own grid `a1_sel40.sv`**, re-run on both binaries and scored two
ways:

```
name-keyed       0 REGRESSED  28 HOLD-OK  11 MOVED->GOLDEN  12 STILL-OFF
full-signature   0 REGRESSED   9 HOLD-OK  16 MOVED(partial) 26 STILL-OFF
```

**`0 REGRESSED` under BOTH instruments**, and the rows that move are exactly the
cells earl40 named as its residue R1. Its `cmp.log` differs from pristine only
in two object ids (`id:1830` → `id:1826`) — the head itself is unchanged.
`v40_overfire.sv`: malformed whitespace names **7 → 0** (golden 0).

**Live-pass boundaries.** `src/ExprEmit.cpp` and `src/TypeEmit.cpp` are free as
the brief expected. **`src/EmitHelpers.h` is NOT** — see finding V2.

---

## 5. THE CORPUS RESULT, RE-MEASURED FROM MY OWN DUMPS

Earlgrey, `uhdm-dump | sed 1d`, golden from the cache entry the sweep itself
names (`~/.cache/slang-uhdm-goldens/00d4794526e44dc553f3`):

```
                     golden-only   ours-only   MULTISET DISTANCE
golden vs PRISTINE      238568        70321          308889
golden vs PATCHED       238510        70263          308773      improvement -116
dump lines 4 655 201 -> 4 655 201  (UNCHANGED)
```

Per-shape, added and removed separately, vs golden, by multiset:

```
changed shapes            202
REMOVED instances         144        ADDED instances  144
SUM|g-o| over changed     202        SUM|g-p|          86        difference 116  == the msdist delta
shapes at EXACT parity    128 / 202
shapes moving TOWARD      128        shapes moving AWAY  74
   of the 74 AWAY shapes: golden count > 0 ->  0        pristine count > 0 ->  0
```

**Not one line moved away from golden at a position where golden has one.**
The 74 are new display strings that replaced 74 old display strings golden also
lacks (residue R2). Every number above is the implementer's, to the unit.

**Census, span-keyed, both sides, view-separated** (`census41.py`):

```
Q1  qualified stored vpiName        golden   PRISTINE   PATCHED
def   var_select                       4        2          4     EXACT
def   part_select                      7        2          4     (3 = R1')
elab  var_select                      10        0         10     EXACT
elab  part_select                     11        0         10     (1 = R1')
Q2  BARE_TAIL(R1)  24 -> 0 ;  MATCH def 4+4, elab 10+10
```

**The falsifiable half of the prediction survived**: `var_select` landed on
`4` and `10`, not `5` or `11`, so **SITE 2 fired zero times in Earlgrey** —
exactly as predicted from the pristine dumps before any code was written.

**THE HEAD IS UNCHANGED.** `uhdm-cmp golden slang.uhdm`:

```
pristine cmp.log 154 lines   patched cmp.log 154 lines   BYTE-IDENTICAL to each other
patched cmp.log == r10earl40repro/r6_nexthead.cmp        BYTE-IDENTICAL
first divergence: operation, id:194130, line:13:59, endln:18:4   (the param_assign concat reorder)
grep -c 'PRINCE|prim_prince' in the head -> 0
```

---

## 6. CANARIES

```
canaries.sh  u2r (testflags projection) : ok=8  changed=0 absent=0 unknown-names=25
canaries.sh  SL                          : ok=52 changed=0 absent=0 unknown-names=7
ctcan2.sh    u2r EXPECT_UNKNOWN=6        : ok=1  changed=0 unknown-patterns=6   PASS  rc=0
ctcan2.sh    SL  EXPECT_UNKNOWN=1        : ok=58 changed=0 unknown-patterns=1   PASS  rc=0
canaudit.sh                              : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS  rc=0
```

All eight PROTECTED genscope canaries plus `InterfaceModPort` and
`BlackParrotComplex` are **row-IDENTICAL by name** to the committed baseline,
and — a stronger statement the byte verifier supplies — **byte-identical**:
u2r has 0 movers at all, and in surelog the only two moving databases are
Earlgrey and the Scoreboard flake. I checked the two refutation witnesses
explicitly:

```
SVSwitch  [default] BYTE-IDENTICAL   [testflags] BYTE-IDENTICAL
OneThis   [default] BYTE-IDENTICAL   [testflags] BYTE-IDENTICAL
```

so the final 4-cell `joinRef` rule really does put both wrong repairs' victims
back at pristine.

**The implementer's refutation of r10earl40's README R2 is CORRECT, and I
confirmed the mechanism in the UHDM source rather than in prose.** `var_select`
is a `ref_obj`, and `build/generated/src/ref_obj.cpp`:

```cpp
std::string_view ref_obj::VpiFullName() const {
  if (!vpiFullName_) {
    const std::string fullName = ComputeFullName();
    if (!fullName.empty()) const_cast<ref_obj*>(this)->VpiFullName(fullName);
  }
  return serializer_->GetSymbol(vpiFullName_);
}
```

A getter READ freezes the field, and `src/ModuleEmit.cpp` performs exactly such
reads (`std::string sf9(bs->VpiFullName())` at 17191, `ip->` at 17200, `ps->` at
17214). Clearing `syntaxRefPrefix` prevents the WRITE, not the FREEZE. earl40's
"not a stored field mismatch" is wrong and this pass corrects it correctly.

---

## 7. FINDINGS

### V1 — **F3 is NOT "the whole fix", and the write-up says it is.** (latent, no gate moves)

`§ qualSelBaseNoWhitespace41` strips whitespace from a base **sliced out of the
written source text**. A COMMENT is trivia too, and it is not stripped. Probe
`v41v_comment.sv` (shipped here), four cells, golden names all four `q41::A`:

```
cell            written                         GOLDEN    PRISTINE          PATCHED
c_k0 CONTROL    q41::A[g][DW-1:0]               q41::A    q41::A            q41::A
c_k1            q41::/*x*/A[g][DW-1:0]          q41::A    q41::/*x*/A       q41::/*x*/A     <- NOT FIXED
c_k2            q41::A/*y*/[g][DW-1:0]          q41::A    q41::A/*y*/       q41::A/*y*/     <- NOT FIXED
c_k3            q41:: // z \n A[g][DW-1:0]      q41::A    "q41:: // z\nA"   q41:://zA       <- NOT FIXED
```

```
grep -cE '\|vpi(Name|DefName|FullName):.*q41(:: | ::|::A )' cmt_{pris,pat}.dump   ->  7  ->  0
grep -cE '\|vpi(Name|DefName|FullName):.*q41::.*(/\*|//)'   cmt_{pris,pat}.dump   -> 21  -> 21
```

Cell `c_k3` is the sharp one: **pristine minted a vpiName containing a NEWLINE**
(the dump prints it across two lines), and the patch turns it into the
single-line but still wrong `q41:://zA` — the identifier is now silently glued
to a line comment. That is not a regression (both are malformed and golden has
neither), but it is a *new* malformed string, and it lands in the same field the
pass exists to fix.

**The correct fix was already named in the record this pass was closing.**
r10earl40's verifier wrote: *"One-line fix: right-trim, or better, build the
base from the LEFT node's text plus `isn40->identifier.valueText()` instead of
slicing `raw`."* The second form makes the whole class impossible; the textual
strip that was chosen only narrows it. The code comment's claim —
*"Whitespace inside a qualified base is never significant … so STRIPPING IT ALL
is the whole fix"* — is **false as written**, and the README repeats it.

*Not a gate issue*: zero corpus occurrences, no row and no byte moves.
**Recommended for the next pass in this family, together with R1′** — both live
in the same builder and the symbol-rebuilt base is what R1′ needs anyway.

### V2 — **Boundary collision: `src/EmitHelpers.h` is a LIVE PASS's file.** (process, not correctness)

The standing brief says *"Live passes: r10uvm70 (TaskFuncEmit/**EmitHelpers**),
r10sd3 (ParamEmit/TaskFuncEmit). ExprEmit/TypeEmit expected free — collision =
report."* This patch edits `src/EmitHelpers.h` (`joinRef`, ~line 1383).

```
/tmp/wt_r10uvm70 $ git status --porcelain
 M src/EmitHelpers.h        <- r10uvm70 also edits this file
 M src/ModuleEmit.cpp
 M src/TaskFuncEmit.cpp
```

I diffed the two edits: **r10uvm70 touches lines ~2075–2240**
(`implicitRetWrittenSigning70`, `makeReturnVar`), r10earl41 touches ~1383
(`joinRef`). **No textual overlap and no semantic interaction**, so the two
patches should merge cleanly — but the collision is real and the brief asks for
it to be reported, so it is reported. It is worth flagging to whoever lands
second that `joinRef` has **73 call sites** across `ExprEmit.cpp` (51),
`StmtEmit.cpp` (21) and `EmitHelpers.h` (1); its rule change is the widest-blast
edit in this patch and the byte verifier is the only instrument that covers it
(and does: 0 u2r movers, and `SVSwitch`/`OneThis` back at pristine).

### V3 — **Three reported numbers are not reproducible as absolutes.** (documentation)

`.uhdm` file sizes embed the absolute source path, so `README.md` § 5's
`13579 → 13424 (−155)`, `12703 → 12590` and `12938 → 12961 (+23)` are
workdir-dependent. In my directory the same runs give `13559 → 13406 (−153)`,
`12683 → 12572` and `12918 → 12943 (+25)`. `orphan41.sh` takes the outdir as
`$1` and does not normalise it, so a reader who reruns it in another directory
will not match the table. **The finding, the sign and the mechanism all
reproduce**; only the absolute byte counts do not. The script should either
compare both binaries through one fixed path (what I did) or print the path
length alongside the size.

### Minor bookkeeping (not findings)

* `README.md` § 2b says *"0 REGRESSED, 5 HOLD-OK, 9 DEF + 8 ELAB moved"* while
  the headline says 9 HOLD-OK / 17 moved. My independent count is
  **9 HOLD-OK / 17 moved / 2 still-off**, i.e. the headline is right and § 2b's
  HOLD-OK number is not.
* The a1_sel40 boundary numbers (*"11 HOLD-OK / 16 moved"*) are
  instrument-dependent; I get 28/11 name-keyed and 9/16 full-signature. The
  load-bearing half — **0 REGRESSED** — holds under both.
* *"its trailing-space names 2 → 0"* on `v40_overfire`: I measure **7 → 0**
  with a regex that also covers `vpiFullName`. Same direction, wider than
  claimed.

---

## 8. RANKED RESIDUES (verifier's ranking)

1. **R1′ — the SINGLE-selector package select, NAME and SPAN.** Golden:
   `part_select vpiName p41::C` anchored **at the selector** (`72:38-72:44`);
   ours: `C` spanning the whole written expression (`72:31-72:45`). Corpus
   population **3 def + 1 elab** (`prim_prince` 59:55, `dm::ResumeAddress`
   273:67, `dm::HaltAddress` 471:75) — these are the entire remaining
   `WE_HAVE_NOTHING` census class. The single `bit_select` form is already
   correct (`c_mpr_pkg_one` → `p41::B` on both sides), so the fix is
   part_select-only. **Top-ranked, and it should be landed together with V1**:
   both want the base rebuilt from symbols instead of sliced from text.
2. **V1 — comments in a qualified base still leak into `vpiName`** (§ 7).
   Cheap, latent, and in the same builder as R1′.
3. **R2 — the stored `vpiFullName` on a qualified select.** Golden stores none;
   we store one, frozen by the `ref_obj::VpiFullName()` getter read in
   `ModuleEmit.cpp` (mechanism confirmed above). It is the whole of the 74
   away-shapes and the reason no grid cell reaches full byte parity. Needs its
   own census because the read is in a shared pass.
4. **R3 — the `+:`/`-:` DEF-view abstain** (earl40's). F4 stopped it leaking
   bytes; the DEF view still falls back to a pasted-text `ref_obj`
   (`c_gca_pkg_bidx`), while its ELAB twin is now correct. Golden's answer is
   fully decoded in earl40's arm.
5. **R4 — a scope-rooted path takes `.` where golden takes `::`.** Two
   witnesses, both left alone deliberately: `aes_pkg::aes_circ_byte_shift.in::s`
   and `work@Receiver::start.bytes::size` (`SVSwitch`). Different emitter,
   self-contained.
6. **R5 — the elab fold population**, 122/29/17/1, identical pristine and
   patched; a constant-folding law, not a naming one.
7. **R6 — the Earlgrey head**, `param_assign` concat reorder at `13:59-18:4`,
   untouched and byte-identical to the carried witness.

---

## 9. WHAT I SHIPPED HERE

* **this file** — the verifier record for THIS pass.
* `v41v_overfire.sv` — my over-fire arm: shapes the 19-cell grid does not
  cover (package **variable** written qualified, LHS use, **port high-conn**,
  inside a **function**, a **class static through a package** — where the
  predicate must *not* fire — a qualified base **inside an index**, the
  no-trailing-range SITE-2 shape, a `+:` on a qualified base, and the imported
  bare control). Golden qualifies every written-qualified cell and leaves the
  imported-bare one bare; **the patch moves every one of them toward golden and
  over-fires on none.** Measured:

  ```
  grep -cE '\|vpi(Name|DefName):pv41::A$'   golden 16   patched 16      EXACT
  select vpiName at 59:20 (imported, bare)  golden  V   patched  V      CONTROL HOLDS
  select vpiName at 42 (class static via a package)  neither side emits one
  ```

  Cell for cell — function body 37:11, qualified base inside an index 46:20,
  no-trailing-range SITE 2 50:20, `+:` on a qualified base 55:21, port
  high-conn 33:26 in **both** views — the patched name equals golden's on every
  one. The class-static cell confirms the `SymbolKind::Package` guard: a member
  whose parent scope is a CLASS never reaches the predicate.
* `v41v_comment.sv` — the probe behind finding V1.

Both arms run with the shipped `arm41.sh`; `SLANG_UHDM` has no default and its
md5 is printed on every run.

Sweep workdirs (`/tmp/r10earl41v/wd_*`) were deleted after the byte verifier
and the Earlgrey dumps were taken.
