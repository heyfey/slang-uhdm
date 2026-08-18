# r10v63 — ADVERSARIAL VERIFICATION of r10earl63 (§ constCallFoldAdjustSize63)

**VERDICT: ACCEPT.** Every headline number in the implementer's report was
reproduced bit-for-bit from fresh worktrees at `18340d0`, and **not one
pristine-right → patched-wrong cell** was found on any of the ~2,900 keyed
cells this directory measures. **MEASUREMENT ONLY** — the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; `results/*.csv`
untouched; no corpus row converted.

Worktrees `/tmp/wt_v63` (patched) and `/tmp/wt_v63pris` (pristine), both fresh
at `18340d0`, both built `-j 2`, both frozen `chmod 555` at `/tmp/v63_bin/`
BEFORE any sweep; `SLANG_UHDM` exported explicitly per binary and every
`cmds.txt` audited by BINARY PATH.

| | |
|---|---|
| pristine md5 | `453ceefaa6b1d6b1eb8d3ad81d4e0012` — **matches the report** |
| patched md5 | `63fb95ea530aa509f87781a7aa62736c` — **matches the report** |
| patch | 31 files, +2283/−3, `git apply --check` clean on a THIRD fresh `18340d0` |
| production surface | `src/ParamEmit.cpp` only; `results/` untouched; 0 fenced-test mentions outside `canaudit.sh` |

---

## 1. GATES — every leg re-run by the verifier

| leg | verifier's measurement |
|---|---|
| goldens patched / pristine / `/bin/false` | **23-0 / 23-0 / 0-23** |
| u2r testflags + default, patched AND pristine | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, all four sweeps |
| u2r `ct8rows` vs committed baseline, both modes | **PASS, 0 differing rows** |
| u2r `ct8rows` patched vs the verifier's OWN pristine sweep | **PASS, 0 differing rows**, both modes |
| u2r `byteverify SELFCHECK=1` | **MOVERS 0 / 1358**, selfcheck 1357/1358 |
| surelog `--mode both` `ct8rows` vs committed baseline | **PASS, 0 differing rows over 1588** |
| surelog `ct8rows` patched vs the verifier's OWN pristine sweep | **PASS, 0 differing rows** |
| surelog `byteverify SELFCHECK=1` | **MOVERS 2 / 956 — `default/Earlgrey_0_1` + `testflags/Earlgrey_0_1`, exactly the predicted-by-name set** |
| `ArrayExprFuncArg` (the F4 fence's row) | `CMP_EQUAL` in **both** modes, byte-identical to baseline |
| canaries | `ok=52 changed=0` (surelog), `ok=8 changed=0` (u2r) |
| `ctcan2` | `ok=58 changed=0` / `ok=1 changed=0`, both **PASS** |
| `canaudit.sh canaries.sh ctcan2.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| byte pins | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort`/`BlackParrotComplex`/`YosysOldOr` byte-identical, both modes |
| `cmds.txt` audit | u2r 1458/1462 name `/tmp/v63_bin/{pat,pris}` and nothing else (the 4 blanks are the 2 `SURELOG_FAIL` rows × 2 sweeps); surelog 1523/1573 likewise |
| determinism | 6 runs of each binary on `c2_head63.sv` → **one md5 each**; no perf regression (3-run wall time 56 ms patched vs 57 ms pristine) |

### Heads — reproduced object-for-object, id-for-id

`rowheads.sh` on both sweeps: **only `Earlgrey_0_1/testflags` changes depth,
64 → 28.** Every other named row's depth is unchanged; `Earlgrey/default`
stays at 64 lines **on a different object** (the two logs differ, 68 lines).

* earl62's R0 (`prim_ram_1p_adv.sv:32:41`, `work@top_earlgrey.u_ram1p_ram_main`,
  golden `INT:14 / "14" / 32 / ct 7`) is the head in BOTH pristine modes and is
  **GONE from both patched logs**. `HEAD_R0_BEFORE_*.cmp` / `HEAD_R0_AFTER_*.cmp`.
* **R0-default** is exactly as `PREDICT_R0.txt` names it: golden `constant
  id:989528` at `72:53-72:58`, owner
  `work@top_earlgrey.u_flash_eflash.i_bank_sequence_fifo.gen_normal_fifo`,
  `INT:2 ct 7` vs ours `id:250058 UINT:2 ct 9`; decompile, size and the whole
  typespec chain agree — `constant::Compare` fails on `VpiConstType` alone.
* **R0-testflags** likewise: golden `id:308999` at `128:32-128:33`,
  `UINT:0 / 64 / ct 9` vs ours `id:255901 INT:0 ct 7` — the OPPOSITE direction.

---

## 2. THE VERIFIER'S OWN GRID — 8 arms, both views, 1,292 keyed cells

`v1..v8_*.sv` are written to BREAK the law, not to confirm it: every declared
type slang accepts (incl. the shapes fence F3's TEXT claims are excluded),
every statement kind and return type, every declaration home, override state,
the argument-shape fence, and an evaluator-stress arm.

Scored 3-way (golden / pristine / patched) on the SLOT key
`(DEF|ELAB, owner, line:col, param)` as a **multiset**, payload = the four
fields `constant::Compare` reads (`v63score.py`), and independently
FIELD-BY-FIELD (`v63field.py`).

| arm | what it attacks | cells (×2 views) | TO-GOLDEN | **AWAY-GOLDEN** |
|---|---|---|---|---|
| `v1_types` | 28 declared types incl. packed struct/union, `time`, 2-D packed, >64-bit, typedef'd, enum-cast, untyped, ranged-untyped | 232 | 132 | **0** |
| `v2_bodies` | 45 body shapes × 11 statement kinds × 8 return types, on `int`, `logic[15:0]` and `bit[7:0]` targets | 544 | 318 | **0** |
| `v3_homes` | port-list / body / gen-if / gen-for / gen-case / nested gen / package / **interface** / `$unit` | 130 | 42 | **0** |
| `v4_values` | negatives, >32-bit, >64-bit, X/Z, real, string, enum, typedef'd returns | 132 | 44 | **0** |
| `v5_argfence` | the F4 argument fence: literal / param / unpacked array / packed array / packed struct / string / real / enum / no-arg / mixed | 72 | 12 | **0** |
| `v6_class` | class + parameterised class + package neighbours | 16 | 4 | **0** |
| `v7_over` | override state: defaulted / literal-overridden / const-call-overridden / parent-driven, 4 instances | 70 | 38 | **0** |
| `v8_hard` | recursion, deep nesting, static locals, sign-extended shift, >64-bit intermediates, 4-return bodies | 96 | 42 | **0** |
| **total** | | **1,292** | **632** | **0** |

**FIELD-LEVEL (the measurement that can see a partial regression):**

```
REGRESSIONS  kind=0  VpiDecompile=0  VpiSize=0  VpiConstType=6
FIXES        kind=0  VpiDecompile=542  VpiSize=220  VpiConstType=504
```

The 6 `VpiConstType` regressions are 3 distinct cells × 2 views
(`v2 i_bsel`, `v4 n_w80tr` ×2) and every one of them is **JUDGE-INVISIBLE**:
in all three, pristine's `VpiDecompile` was ALREADY wrong, and `expr::Compare`
reads `VpiDecompile` **before** `VpiSize`, `Typespec` and (in
`constant::Compare`) `VpiConstType` — the comparison fails at the same earlier
field before and after. No cell loses a field the judge can reach.

Two findings the grid produced that the implementer's grids did not:

* **packed `struct`/`union` targets DO enter the shipped branch** (they are
  `isIntegral() && !isEnum()`), the fence-F3 COMMENT notwithstanding — and
  golden AGREES: `c_sp8` / `c_up8` are `INT:14 vpiSize 8` in golden and are
  **TO-GOLDEN** under the patch. The code is right, the comment is wrong (see
  §4, finding D1).
* the **INTERFACE home** works (`if_tern` / `if_sub` / `if_vt` all TO-GOLDEN) —
  it was never named in the implementer's report.

---

## 3. BOUNDARY — recursive per-file AND per-directory, movers SCORED against golden

`vwide63.sh` over **every** `.sv` under `tools/probe` at any depth
(list on fd 3, children `</dev/null`, `PROCESSED` asserted == LISTED):

```
per-file        PROCESSED=2836 == LISTED   identical=5342  DIFFERING=68  no_output=262
                signal rows: patched=8  pristine=8   (SYMMETRIC — pre-existing rc=139)
per-directory   PROCESSED=1336 == LISTED   identical=2389  DIFFERING=44  no_output=239
                signal rows: patched=5  pristine=5   (SYMMETRIC)
```

Every mover then re-run through Surelog + both binaries and **scored against
GOLDEN** with the verifier's own object-keyed scorer:

| boundary | movers | cells | TO-GOLDEN | **AWAY-GOLDEN** | MOVED-WRONG | field regressions |
|---|---|---|---|---|---|---|
| per-file | 34 arms | 699 | 110 | **0** | 65 | **kind 0 / dec 0 / sz 0 / ct 0** |
| per-directory | 22 dirs | 479 | 32 | **0** | 53 | **kind 0 / dec 0 / sz 0 / ct 0** |

**All 34 + 22 movers are in the law's own family** (`rgg1/2/6/7`, `rggen8/9`,
`vrgg2/5/6/7`, `oth3`, `earl63`'s own arms). The brief-protected families are
**byte-identical in BOTH boundaries**: `r10rgg5/8/9/10/11repro`,
`r10vrgg11repro`, `r10earl61repro`, `r10earl62repro`, `r10v62repro`, and
**every `uvm` / `buvm` / `vuvm` directory — 0 differing arms**.

`r10uvm88repro`, which the implementer listed as a per-directory mover and then
refuted as the known `vpiTaskFunc` order coin, is **identical** in the
verifier's run — independent confirmation that it was the coin and not a mover.

**rgg11's PORTTABLE grids re-generated and swept.** `gen_grid11.py` was re-run
(192 + 324 = 516 cells, grid A and grid B) and both binaries compared over all
of them, both views: see `BOUNDARY_rgg11grid.tally`.

---

## 4. FINDINGS (none blocking)

**D1 — the F3 fence comment misdescribes the shipped code.** `src/ParamEmit.cpp`
says *"(F3) enums, structs and > 64-bit targets are excluded"*, but the guard is
`isIntegral() && !isEnum() && bitWidth <= 64` — a **packed struct or union IS
integral** and DOES take the new arm. That is the CORRECT behaviour (golden
agrees, §2), so this is a comment defect only. **Do not edit it before
landing**: the file's md5-reproducibility is a headline claim of this pass and a
comment edit would invalidate it. Fold the correction into the next pass that
touches the arm.

**D2 — `ASTContext::tryEval` is diagnostic-free and cache-local.**
`source/ast/ASTContext.cpp:280` shows `tryEval` constructs a LOCAL `EvalContext`
and does **not** call `reportAllDiags()` (unlike `evalInteger`'s helper), so the
added `cx63.tryEval(icc9)` cannot leak diagnostics into the compilation or
persist a cache. Recursive and runaway-recursive bodies return an invalid
`ConstantValue` and fall back to `iv9` — measured, not assumed (`v8_hard`
`f_fact` is TO-GOLDEN, the three pre-existing `r10vrgg8repro/cells/v8_recurse*`
segfaults are SYMMETRIC on both binaries).

## 5. RANKED RESIDUES the verifier measured (all NEW, all beyond `PREDICT_R0.txt`)

| # | residue | evidence | cells |
|---|---|---|---|
| **V-R1** | **the producer must follow the EXECUTED return, not the LAST syntactic one.** `constCallProducer63` visits the body and keeps the last `return`/return-var assignment it sees. Golden follows the branch that RAN: `b_ifel` = `if (v>2) return v-1; else return v+1;` is golden `INT` in the two instances that take `v-1` and `UINT` in the one that takes `v+1`; we write `UINT` in all three. The consequence is visible in the DIGITS too — `bit[7:0] h_mret8 = f_manyret(2000)` is golden `INT:1999` at `vpiSize 8` (INT keeps the digits) while our UINT classification MASKS to `207`. | `v2_bodies` `i_ifel`/`i_case`/`i_two`, `v8_hard` `h_mret`/`h_mret8` | 12 |
| **V-R2** | **the producer must chase a LOCAL VARIABLE.** `integer r; r = v - 1; return r;` — golden takes the `-` arm (`INT`), we see a `NamedValue` return and fall to the `UINT` default. Same root as V-R1, different carrier. | `v2_bodies` `i_loc` (3 instances) | 3 |
| **V-R3** | **F4 is drawn wider than the ablation requires.** The implementer's OWN `abl_a`/`abl_b` table names the discriminator as an **unreduced const-call-produced** unpacked-array actual; F4 rejects *every* non-integral actual. Golden wants the new arm's `INT` shape for a `string` actual (`a_str` golden `INT:3`, ours `BIN`), a `real` actual (`a_rl` `INT:3`), and a LITERAL unpacked-array actual (`a_arrl`/`a_twol`/`b_arrl` golden `INT:2`). Safe and conservative — it is what keeps `ArrayExprFuncArg` `CMP_EQUAL` — but it leaves cells on the table. | `v5_argfence` | 10 |
| **V-R4** | **the producer's width caps at 64.** `width63()` returns 0 above 64 bits, so an 80-bit concat body falls to the `UINT` default: `int n_w80tr = f_w80()` is golden `BIN` 80 digits at `vpiSize 80`, ours `UINT:85` at 32. The mirror case is the >64-bit TARGET, fenced out entirely: `logic [99:0] c_l100` golden `INT:14 vpiSize 100`, ours `vpiSize 64`. | `v4_values` `n_w80tr`, `v1_types` `c_l100` | 6 |
| **V-R5** | **a const-call used as an OVERRIDE ACTUAL** (`s_ov #(.P_TERN(vb7(512)))`) keeps the old `UINT` arm — golden `INT:9`/`INT:8`. A different emitter arm owns the override actual. | `v7_over` `u3` | 2 |
| **V-R6** | **the PACKAGE home** (`!inPackage`): `localparam logic [15:0] pk_vt = pvb(16384)` is golden `INT:14 vpiSize 16`, ours `UINT:14 vpiSize 32`. (`int`-typed package localparams are already right through another arm.) | `v3_homes` `pk_vt` | 1 |

Independently CONFIRMED from `PREDICT_R0.txt`: **R2** (gen-scope homes — 21 of
my cells, `gi_*`/`gf_*`/`gc_*`/`gi2_*`, byte-still under the patch) and **R3**
(ranged-untyped — `c_ranged` golden `INT`, ours `UINT`).

## 6. FILES

| file | what |
|---|---|
| `v1..v8_*.sv` | the eight adversarial arms (types / bodies / homes / values / argument fence / class / override / evaluator stress) |
| `v63run.sh` | one arm → Surelog golden + PRISTINE + PATCHED → three `pacen63` censuses |
| `v63score.py` | 3-way MULTISET join on the Compare-visible slot, TO-GOLDEN / AWAY-GOLDEN buckets |
| `v63field.py` | FIELD-BY-FIELD regression counter (kind / VpiDecompile / VpiSize / VpiConstType) — the instrument that proves the 3 `ct` flips are judge-invisible |
| `v63arms.sh` | scores a boundary mover list against golden (fd-3 list, children `</dev/null`, `PROCESSED` asserted); `MODE=dir` for the per-directory shape |
| `GRID_SCORES.txt`, `GRID_FIELDS.txt` | the 16 view-arm rows behind §2 |
| `BOUNDARY_wide.*`, `BOUNDARY_dir.*` | tallies, mover lists and rc>128 signal rows for both boundaries |
| `BOUNDARY_*_MOVERS_SCORED.txt`, `BOUNDARY_*_MOVERS_FIELDS.txt` | every mover scored AND field-scored against golden |
| `BOUNDARY_rgg11grid.*` | the re-generated rgg11 PORTTABLE grid A+B sweep |
| `HEAD_R0_{BEFORE,AFTER}_{default,testflags}.cmp` | the four `uhdm-cmp` heads behind §1 |

`pacen63` (the census reader) is the implementer's, rebuilt by the verifier
from `tools/probe/r10earl63repro/pacen63.cpp` and audited line by line: it
prints exactly the fields `constant::Compare` reads, plus `VpiValue` for
diagnosis only.
