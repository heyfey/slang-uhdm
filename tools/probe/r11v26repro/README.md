# r11v26 — the adversarial verification of r11u26, and the ONE gate it needed

Base `822420d0` (matrix-1.87).  Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.
Everything here is measurement-only; the judge is the official `uhdm-cmp`
through `scripts/verify_golden.py`, and `results/*.csv` IS NOT EDITED.

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number in the implementer's
report reproduces bit for bit on binaries this verifier built from a fresh
apply — the eight conversions, the six byte-identical controls, `u2r MOVERS
0 / 1608`, the L2 detector's `scanned=1608 flagged=22 errors=0` and
`scanned=960 flagged=15 errors=0 skipped-not-ours=3`, and every canary pin.
But the new FLATTEN trigger fired on four faces the implementer's grid does
not carry, and on all four it moved a cell the PRISTINE binary had exactly
right AWAY from golden.  One gate — § patParamPatElem26v — refuses those four
and costs nothing: all eighteen implementer arms are unchanged, head for head
and cell for cell.

---

## 1. What was reproduced (the implementer's own numbers, re-measured)

Built both binaries from a fresh `822420d0` worktree with the patch applied by
`git apply -3` (0 conflicts, 0 `<<<<<<<` markers, whole output read — the
`| head` that truncates it also SIGPIPEs `git apply` into rolling the whole
thing back and printing nothing, which is how this run first read "applied
cleanly, nothing modified").

| | value |
|---|---|
| pristine md5 | `66dc9cdb3437a4d220daef493a145fdd` — byte-identical to the main tree at `822420d0` |
| patched md5 (implementer's patch, unmodified) | `e5f9fcb4100c84bb23d0c44444feb511` — the implementer's own value |
| patched md5 (with this verifier's gate) | `71e62107417b63d827c7451ff22f34cb` |
| goldens, all three binaries | 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL |

The eighteen implementer arms, re-run with this verifier's own frozen
binaries: `m1 m2 m4 m6 m7 m12 m13 m15` each **1 head → 0 heads, CMP_EQUAL**;
`m3` 1/36 → 1/18, `m5` 1/36 → 1/32, `m8` 1/36 → 1/32, `m9` 1/13 → 1/13;
`m10 m11 m14 m16 n10 n11` byte-identical on the two binaries.  Every arm
`slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.  The per-arm directional census
reproduces the implementer's table cell for cell — **its TO column sums to 59,
not the 61 the prose says**; the per-arm numbers are right and the total is an
arithmetic slip.

The share proof reproduces exactly.  On `m12`, golden's `topPkg`: `pk.UU`
`rhs#9 … ts#12 parent#13` and `pk::c_t.u` `val#17 operands=constant#18,#19
ts#20 parent#13`.  Distinct objects, one shared parent: **golden CLONES**, and
it clones the `ref_typespec` too.

---

## 2. THE FINDING — a pattern ELEMENT that is itself a pattern

`ExprEval::getValue` (UHDM v1.87 `templates/ExprEval.cpp:337-347`) runs
`flattenPatternAssignments` only inside
`if (const ref_typespec *rt = op->Typespec())`.  Surelog types the elaborated
pattern operation exactly when every element reduces to a CONSTANT.  The
implementer's gate reads `k0 == StructuredAssignmentPattern`, which is a proxy
for that and lets four faces through.  Thirteen arms, one per row, `pk::UU`
read whole by the same builder in every one, `PA topPkg pk.UU` read by
`idcen26`:

| arm | the pattern | golden |
|---|---|---|
| `m1` | `'{a: 11, b: 22}` | FLAT, `ts(pk::in_t)` |
| `m13` | `'{a: 64'd11, b: 64'd22}`, 128 bits | FLAT |
| `m15` | `'{a: E1, b: E2}`, enum constants | FLAT |
| `v12` | `'{default: 0, a: 11}` | FLAT |
| `v13` | `'{a: {2{16'd1}}, b: 22}` — replication OPERATOR | FLAT |
| `v15` | `'{a: 32'd1, b: 3}`, `a` a packed UNION | FLAT |
| `v17` | `'{a: UA, b: 3}`, `UA` a union param valued `32'd1` | FLAT |
| `v16` | `'{a: 64'd5, b: 3}`, `a` a nested STRUCT member | FLAT |
| `v18` | `'{a: 64'd5, b: 3}`, `a` a PACKED-ARRAY member | FLAT |
| **`v4`** | `'{a: '{x: 1, y: 2}, b: 3}` | **TAGGED, NO typespec** |
| **`v11`** | `'{p: 5, q: '{x: 1, y: 2}}` — last element | **TAGGED, NO typespec** |
| **`v14`** | `'{a: '{32'd1, 32'd2}, b: 3}`, packed-array member | **TAGGED, NO typespec** |
| **`v10`** | `'{a: NA, b: 3}`, `NA` a parameter whose OWN value is a pattern | **TAGGED, NO typespec** |

`v16`/`v18` against `v4`/`v14` settle that the distinguisher is the ELEMENT and
not the member's type; `v17` against `v10` settles that a reference is fine
unless what it names is itself a pattern.  On all four bold rows the
implementer's binary rewrote `PA topPkg pk.UU` from
`operands=tagged_pattern,tagged_pattern ts#-1` — which is golden, and which the
PRISTINE binary emits — to `operands=constant,constant ts(pk::in_t)`.  Measured
`AWAY=1` on each by `dircen26.py`.  In these four arms the move is shadowed by
a pre-existing DEF-listing head, so `uhdm-cmp` line counts do not change; the
cell census is what sees it.

**THE GATE (`§ patParamPatElem26v`, `src/ParamEmit.cpp`, and the declaration in
`include/UhdmExporter.h`).**  The new trigger additionally refuses a resolved
pattern with an element that is itself an assignment pattern, literally or
through a parameter whose own value is one (bounded walk, depth 8, through
`bareParamRef`).  It touches nothing else.

---

## 3. The adversarial grid — 19 arms, every one `slrc=0 [ERROR] : 0`

`grid.sh` (the implementer's, run with `G=` pointed here).  Directional census
by `dircen26.py` over `idcen26`, calibrated golden-vs-golden-vs-golden
(`SAME=30 TO=0 AWAY=0 MW=0 SW=0`).  With the gate in place:

| arm | face | pris → patched heads | census |
|---|---|---|---|
| `v1` | builder + `UU` in the package, the HOLDER parameter in a module through a wildcard import | 1/36 → 1/5 | TO=3 AWAY=0 |
| `v2` | TWO members written from the SAME pattern parameter | 1/36 → **0, CMP_EQUAL** | TO=7 AWAY=0 |
| `v3` | a PACKED-ARRAY pattern parameter read whole (the flatten half cannot fire; the clone can) | 1/32 → 1/8 | TO=0 MW=3 (R1) |
| `v4` | a NESTED pattern literal element | 1/86 → 1/86 | **BYTE-IDENTICAL to pristine** |
| `v5` | BOTH flat triggers at once, 128 bits — idempotence | 1/36 → 1/8 | TO=4 AWAY=0 |
| `v6` | a builder the recognizer REJECTS (an `if` in the body) | 1/36 → 1/14 | TO=4 AWAY=0 |
| `v7` | SYMBOLIC member dim + a builder read | 1/36 → 1/36 | **BYTE-IDENTICAL** |
| `v8` | an overridable holder, actually overridden — the view split | 1/5 → 1/5 | **BYTE-IDENTICAL** |
| `v9` | SELECTIVITY: two pattern parameters, the builder reads ONE | 1/36 → **0, CMP_EQUAL** | TO=4 AWAY=0 |
| `v10` | a pattern-valued parameter as an ELEMENT | 1/60 → 1/60 | **BYTE-IDENTICAL to pristine** |
| `v11` | the nested pattern in the LAST element | 1/86 → 1/86 | **BYTE-IDENTICAL to pristine** |
| `v12` | a `default:` element | 1/36 → **0, CMP_EQUAL** | TO=4 AWAY=0 |
| `v13` | a replication-OPERATOR element | 1/43 → **0, CMP_EQUAL** | TO=4 AWAY=0 |
| `v14` | a packed-array member with a pattern element | 1/65 → 1/65 | **BYTE-IDENTICAL to pristine** |
| `v15` | a packed-UNION member | 1/36 → **0, CMP_EQUAL** | TO=4 AWAY=0 |
| `v16` | a nested-STRUCT member with a LITERAL element | 1/36 → 1/32 | TO=4 AWAY=0 |
| `v17` | a union member reached through a constant-valued parameter | 1/25 → 1/25 | TO=4 AWAY=0 |
| `v18` | a packed-ARRAY member with a LITERAL element | 1/36 → 1/32 | TO=4 AWAY=0 |
| `v19` | a pattern element PLUS a member select, so the landed member-select rule flattens on BOTH binaries | 1/60 → 1/60 | TO=0 MW=3, AWAY=0 |

**AWAY-GOLDEN 0 over all 19 arms and all 18 implementer arms.**  `v19` is the
one arm where the drain's clone installs a flat operation over golden's tagged
one; the pristine binary put a re-encoded UINT there, so it is a MOVED-WRONG
and never an AWAY.

Six arms are the CONTROLS that must stay byte-identical to pristine and do:
`v4`, `v7`, `v8`, `v10`, `v11`, `v14`.

---

## 4. Corpus gates, measured on this verifier's own sweeps

Three sweeps, `--jobs 2`, each with `SLANG_UHDM` exported explicitly and every
`cmds.txt` audited by BINARY PATH (3273 rows per side, and the only
`slang-uhdm` path in any of them is that side's frozen binary).

| gate | result |
|---|---|
| u2r scoreboard, both modes, all three binaries | 768 CMP_EQUAL / 36 CMP_NOTEQUAL / 67 SLANG_REJECT |
| surelog scoreboard, all three binaries | 469/14 default + 465/12 testflags — the committed baseline |
| `ct8rows` u2r testflags vs `results/gate_uhdm2rtlil.csv` | PASS, every row byte-identical |
| `ct8rows` u2r both modes, patched vs this verifier's pristine | PASS in each mode |
| `ct8rows` surelog, patched vs this verifier's pristine | 2 differing rows: `LowMemLib`/tf and `LowMemPkg`/tf, differing ONLY in the workdir path inside a `SURELOG_FAIL` detail string.  0 status moves, 0 dump-column moves |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1608**, selfcheck 1607/1608, path sets identical |
| `byteverify SELFCHECK=1` surelog | MOVERS 5 / 960 — `MiniAmiq`×2, `SeqDriver`×2, `SimpleUVM`/default.  All five in the proven UVM coin family, all five named a priori by L2 |
| coin attribution, ORDER-BLIND (`coin.sh`) | every one of the five: **exactly 4 lines**, one `UINT:<n>` plus its `vpiDecompile:<n>` — the line-number class — and the sign runs BOTH ways across the five, which a law mover cannot do |
| coin POSITIVE CONTROL | the PRISTINE binary re-invoked on `MiniAmiq`/default four times produced four MORE distinct databases (`f3ebd05dffc0`, `362b2c62ac07`, `be006437dd8c`, `e742846ba60d`), none equal to each other, to the sweep's pristine `c3d6214e92f1`, or to the patched `e9183812b66f`.  Six distinct hashes of one source, five of them pristine |
| HARD byte pins | `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a`, both modes, every binary |
| STATUS pins | `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex e3e354129d5a` / `73a10e8217e5`, `YosysOldOr d68e0796d62c` — byte-identical across binaries |
| `Earlgrey_0_1` | `CMP_EQUAL` both modes, database byte-identical across binaries (`8bdf25272e08…` default, `59d0ee6d10c3…` testflags).  Its DUMP COLUMN read BLANK on this verifier's PRISTINE **and** patched sweeps where the committed baseline carries `differ` — the same coin the implementer saw, landing the other way, and landing the SAME way on both binaries |
| `canaries.sh` | u2r ok=8 changed=0; surelog ok=51 changed=1 — the one change is `Earlgrey_0_1`/tf's dump column, and it is **identically changed on the PRISTINE sweep** |
| `ctcan2.sh` | PASS both corpora (surelog ok=58 changed=0, u2r ok=1 changed=0) |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched, line for line (measured=12, SKIP-NOFILE=2 as expected) |
| L2 detector re-run on this verifier's PRISTINE workdirs | u2r `scanned=1608 flagged=22 errors=0`; surelog `scanned=960 flagged=15 errors=0 skipped-not-ours=3` — the implementer's exact readings |
| fence (the four slang-fenced tests) | 0 hits in the production diff, 0 in either repro directory, no driver dispatches them |
| `results/*.csv` | UNTOUCHED |

---

## 5. Residues this verification adds

* **R1 — a PACKED-ARRAY pattern parameter's leftover typespec (`v3`).**  With
  `pa_t = logic [1:0][31:0]` and `c.u = PA`, golden's leftover carries
  `ts(pa_t)` and the clone's carries an unnamed one; `uhdm-cmp` drops from 32
  to 8 lines and the remaining head is that typespec.  The clone copies
  `VpiName`/`VpiFullName`/`Actual_typespec` off the source op's ref, so the
  source op's own ref is the thing that is unnamed here.
* **R2 — golden mints a SEPARATE leftover object per elaborated listing.**  On
  `m12` golden's `topPkg` leftover is `val#17` and its `topMod` leftover
  `val#32`; ours is one object shared across all three listings, and golden
  also mints a fresh `ref_typespec` (`ts#20`) where ours reuses the source
  op's.  No generated `Compare` reads `VpiParent` and both typespec refs
  resolve to `pk::in_t`, so the judge calls `m12` EQUAL — this is a hygiene
  residue, not a defect.
* **R3 — the cross-scope direction the trigger cannot reach (`v1`).**  Builder
  and pattern parameter in the package, the HOLDER parameter in a module
  reading through a wildcard import: `evalFuncWholeReads26` scans the
  PARAMETER's own parent scope for a builder-initialized parameter and finds
  none, so the flatten never fires; golden flattens anyway.  The leftover half
  still lands (1/36 → 1/5).  The predicate needs the reader side, not the
  holder side, to close it.
* **R4 — a builder outside the recognizer's subset (`v6`).**  One `if` in the
  body and the whole law stands down while the producer evaluates the function
  regardless; 1/36 → 1/14 says most of the gap is elsewhere, but the arm is the
  ready-made witness for widening the recognizer.

## 6. Files

| file | what it is |
|---|---|
| `v1`–`v19` | the adversarial arms (§3).  `v4`, `v7`, `v8`, `v10`, `v11`, `v14` are the CONTROLS and must stay byte-identical to pristine |
| `grid.sh` | the implementer's grid runner, carried so this directory runs standalone (`G=` points here) |
| `coin.sh` | ORDER-BLIND attribution of one surelog byte mover: path- and id-normalised, sorted `uhdm-dump`s |
| `dirdump.sh` | the raw-dump directional census (added/removed lines scored against golden's own multiset); coarser than `dircen26.py` and kept as its cross-check |
