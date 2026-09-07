# r10v188 — ADVERSARIAL VERIFICATION OF r10uvm188 (§ `enumConstLitArithRender188`)

**Verdict: ACCEPT-WITH-FIX.** The implementer's law is right about the render
and right about the definition listing's size, and every headline number they
reported reproduces **bit for bit**. One clause of the law — the ELABORATED
listing's `VpiSize` — was **refuted by seven new shapes against a real Surelog
golden**, and it is a **compared** field. This directory carries the arms that
refuted it, the corrected rule, and the re-run battery.

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge. The official
`uhdm-cmp` and `scripts/verify_golden.py` are the authorities. slang was **NOT**
patched; `results/*.csv` were **READ ONLY**; **no row was converted**;
`GOLDEN_DEFER` stayed unset; the four slang-fenced tests were never dispatched
and are not named in any file here.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `4bf4d571` |
| pristine binary | `b15c4f042d5928e133f3bde9806352c4` — built by the verifier in a fresh worktree, **identical to the implementer's** |
| implementer's patched binary | `68c7dfe93c50cdb63be7e224a1c935f0` — rebuilt by the verifier from `/tmp/r10uvm188.patch`, **identical to the implementer's** |
| verifier's fixed binary | `5b4e62c7477a64cf89591108d4ca695c` |
| the fix | `src/TypeEmit.cpp`: one new `SrlgLitArith::anyShift` field, propagated through the binary arm, and the folded-listing `VpiSize` ternary; `topShift` (now dead) removed. Nothing else. |

---

## 1. What reproduced, exactly

Every one of these was re-measured from the verifier's own worktrees, own
binaries, own sweeps and own workdirs; no number was carried forward.

| claim | reproduced |
|---|---|
| pristine and patched binary md5 | **yes, both** |
| goldens 23 PASS / 0 FAIL, `/bin/false` 0/23 | yes (and 23/0 for the fix) |
| u2r testflags 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | yes |
| u2r both modes, 0 differing rows | yes |
| surelog `--mode both`, **0 differing rows over 1588**, status AND dump column, no conversion | yes |
| byteverify surelog **2 / 956**, both `BuildUVMPkg`; u2r **0 / 1358** | yes |
| `BuildUVMPkg` **36 → 33** cmp lines, ONE head, both modes byte-identical | yes |
| the other twelve head-set cmp logs byte-identical | yes |
| head cmp logs md5 `7f92233e04ae` (pristine) / `492bbfad6a5e` (patched) | yes, byte-identical to the committed evidence |
| grid: 192 cells, **TO-GOLDEN 118 / AWAY 0 / CHANGED-STILL-WRONG 0** | yes, arm for arm (18/6, 88/60, 34/16, 52/36) |
| corpus census 34910 cells, TO-GOLDEN 6 / AWAY 0 / CSW 0 / WRONG-KEPT 862 | yes, and the golden census is byte-identical across all three sweeps |
| boundary LISTED=PROCESSED, **12 moved arms**, RC_DIFFS 0 | yes (5077/5077 here — this directory adds six arms of its own) |
| the 5 law-moved arms, TO-GOLDEN 2 / AWAY 0 each | yes, all five |
| canaries ok=52 / ok=8 changed=0, ctcan2 PASS ×2, canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | yes |
| InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | yes |
| **R2** — a `.bss` address in the database | **yes, independently** (§ 4) |

Every `cmds.txt` in all six sweeps was audited by binary PATH: 1523 frozen-binary
invocations per surelog sweep, 1458 per u2r sweep, **0** `build/slang-uhdm`.

---

## 2. WHAT BROKE — the folded listing's `VpiSize`

The implementer's rule for the ELABORATED listing was

> size **64** when the OUTERMOST operator is a SHIFT; otherwise the same
> modelled size the definition listing carries, with 0 published as −1.

`arms/v188_f_fold.sv` puts fourteen shapes with a **narrow** modelled size in one
package against one real Surelog golden. Seven of them refute that rule:

| shape | definition SZ (modelled) | golden FOLDED SZ | implementer's rule | corrected rule |
|---|---|---|---|---|
| `4'hF * 4'h3` | 4 | **64** | 4 ✘ | 64 ✔ |
| `4'hC - 4'h2` | 4 | **64** | 4 ✘ | 64 ✔ |
| `4'hC / 4'h2` | 4 | **64** | 4 ✘ | 64 ✔ |
| `'h6 * 'h3` | 0 | **64** | −1 ✘ | 64 ✔ |
| `'h9 - 'h2` | 0 | **64** | −1 ✘ | 64 ✔ |
| `3'h1 + 3'h1 * 3'h3` | 3 | **64** | 3 ✘ | 64 ✔ |
| `(1 << 2) + 3'h1` | 66 | **64** | 66 ✘ | 64 ✔ |
| `4'h5 + 4'h3` | 4 | **4** | 4 ✔ | 4 ✔ |
| `3'h2 + 3'h1` | 3 | **3** | 3 ✔ | 3 ✔ |
| `'h9 + 'h2` | 0 | **−1** | −1 ✔ | −1 ✔ |
| `8'h2 << 3` | 11 | **64** | 64 ✔ | 64 ✔ |

**THE CORRECTED LAW.** The folded listing carries the modelled size **only for a
PURE `+` TREE**; every other shape folds at **64**. Equivalently, in the patch's
own terms: 64 when `anyShift || anySubMulDiv`, else the modelled size with 0
published as the unsized marker −1. `anySubMulDiv` is exactly the discriminator
the folded ENCODING already used (`INT:` vs `UINT:`), so the two now agree: a
reduction that goes signed lands in a 64-bit `int`, and so does one that goes
through a shift. `anyShift` had to be added because it is a shift **anywhere**
in the tree, not the outermost operator — `(1 << 2) + 3'h1` and
`3'h1 + (1 << 4)` both fold at 64 while their top operator is `+`.

The implementer's own four arms never contained a narrow-width `- * /`, which is
why 192 cells scored `AWAY-GOLDEN 0` and the clause went unrefuted.

**Cost of the defect, measured on the JUDGED fields** (`VpiDecompile` + `VpiSize`
— read out of `~/git-repos/UHDM/build/generated/src/{enum_const,expr}.cpp`, not
guessed; `VpiValue` is read by NO generated Compare on an `enum_const`):

| arm | implementer's binary | verifier's fix |
|---|---|---|
| `arms/v188_f_fold.sv` | TO-GOLDEN 8, **CHANGED-STILL-WRONG 22** | TO-GOLDEN **30**, CSW **0** |
| `arms/v188_e_edge.sv` | TO-GOLDEN 34, **CHANGED-STILL-WRONG 4** | TO-GOLDEN **38**, CSW **0** |
| the other eight arms | 0 AWAY / 0 CSW | unchanged |

Every one of the 26 cells is the folded listing's `VpiSize` going from a
golden-correct 64 to a wrong narrow number.

---

## 3. WHAT SURVIVED THE ATTACK

Seven arms, each against one real Surelog golden, both views, every rc recorded.
On the JUDGED fields the fixed binary scores **AWAY-GOLDEN 0 and
CHANGED-STILL-WRONG 0 on all ten arms** (`GRIDS.r10v188.txt`).

| arm | what it attacks | result |
|---|---|---|
| `v188_a_render.sv` | all six operators, four spacings of `+`, redundant parentheses in four positions, three-level nesting, `1 << 2 << 3` | **the whole arm compares EQUAL: 36 cmp lines / 1 head → 0 lines / 0 heads** |
| `v188_b_lits.sv` | hex case (`FF`/`ff`/`Ff`), `'d`/`'b`/`'o`, leading zeros, digit separators, unsized based, a SIGNED tick, `%`, unary minus, a shift past the operand width | judged 0 AWAY / 0 CSW; the residual census failures are **`VpiValue` only** |
| `v188_c_bases.sv` | six shapes × **ten** bases (none, `int`, `int unsigned`, `byte`, `shortint`, `longint`, `bit[23:0]`, `logic[7:0]`, `bit signed[15:0]`, a typedef) | **the whole arm compares EQUAL** — "the base plays no part" holds under every base |
| `v188_d_scopes.sv` | `$unit`, package, class-in-package, module, interface, function-local, generate block, import clone, and the reference sites | every home matches golden **including `VpiValue`**; the `$unit` fence is harmless (its compared fields already matched) |
| `v188_e_edge.sv` | shift magnitudes 1/31/32/62, `>>` past the width, unsized based in every operand position, mixed widths | 0 AWAY / 0 CSW after the fix |
| `v188_f_fold.sv` | the folded listing's size — **the arm that refuted the law** | 0 AWAY / 0 CSW after the fix |
| `v188_g_macro.sv` | a MACRO-expanded leaf, a macro that is the whole expression, `_` inside a based literal, a leaf under a cast, a 20-digit decimal, interior whitespace in a literal | macro leaves render correctly (`1 << \`W` → `1 << 4` at 68, golden's number); the cast and the 20-digit decimal ABSTAIN and keep the pristine row |

The abstain guards do what they claim: a cast operand, a decimal past 19 digits,
a `%`, a unary minus and a signed tick all leave the constant exactly as the
pristine binary writes it, and the `agree188` value check catches the case where
slang truncates a literal that Surelog does not.

---

## 4. R2 — a `.bss` ADDRESS IN THE DATABASE (reproduced independently)

Three probe arms (`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
`r10uvm185repro/grid185/g185_e_kinds.sv`) move under BOTH patches with zero
enum-constant census movement. Their entire path-normalised dump diff is one
number, on the range of an ASSOCIATIVE dimension:

```
- |vpiDecompile:22613753      (0x1590EF9)
+ |vpiDecompile:22621945      (0x1592EF9)
```

`readelf -hW` reports `Type: EXEC` (non-PIE) for both binaries and `readelf -SW`
puts both values at the **same offset `0x14B9` inside `.bss`** (`0x158fa40` vs
`0x1591a40`; `.bss` moved by exactly `0x2000`). The static address of a `.bss`
object is being emitted as a `UINT` constant. Pre-existing, zero corpus rows,
and it makes every boundary gate in this campaign report three spurious movers
on any patch that moves a page. **Worth its own pass.**

---

## 5. RESIDUES the verifier is NOT fixing (ranked)

1. **The folded listing's `VpiValue` encoding on a `'d`-based leaf.** Golden
   folds `8'd10 + 4` and `'d5 + 3` to `INT:`, while every `'h`/`'b`/plain-decimal
   sum folds `UINT:` — `anySubMulDiv` does not predict it. `VpiValue` is read by
   NO generated Compare on an `enum_const`, so this is **dump-only** and cannot
   move the judge; it is the whole of `arms/v188_b_lits.sv`'s residual census
   failure (AWAY-GOLDEN 2, CHANGED-STILL-WRONG 4 in the full census, 0 and 0 in
   the judged one).
2. **A negative modelled size abstains where golden publishes it.**
   `8'hFF >> 9` has modelled size −1 and golden's definition listing carries
   `SZ=-1`; the patch's `a188.size >= 0` guard makes it abstain, so the row stays
   wrong. Not a regression — a missed cell the law could take.
3. **R1, the reference sites.** A folded `constant` that inherits an enum
   constant's fields takes the corrected DEFINITION render where golden re-folds:
   for `F_R0 = F_REFSRC` (`1 << 6`) golden gives `64`/64/`UINT`, pristine gave
   `1 << 6`/**64**/`INT`/ConstType 7 and the patch gives `1 << 6`/**70**/`UINT`/
   ConstType 9. `constant::Compare` reads `VpiDecompile`, `VpiSize`, `Typespec`
   and `VpiConstType` — so the patch fixes one compared field (`VpiConstType`)
   and breaks another (`VpiSize`); it is a wash, still NOTEQUAL either way, and
   **zero corpus cells** (byteverify: the only moved databases are BuildUVMPkg
   ×2). A `constant` law, not this one.
4. **Our function-local enum's `enum_typespec` carries no name** where golden
   names it `d_fn_e` (`arms/v188_d_scopes.sv`, the 12 ONE-SIDED-KEYs). The
   constants' own DEC/SZ/VAL all match golden. Pre-existing, untouched.
5. **R3/R4 as the implementer wrote them** (the abstained operator shapes;
   the 862 listing-multiplicity residues) — re-measured and unchanged.

---

## 6. THE FILES

| file | what it is |
|---|---|
| `arms/v188_a_render.sv` … `v188_g_macro.sv` | the seven adversarial arms (§ 3) |
| `scorejudged188.py` | `score188.py` restricted to the fields the generated Compares read |
| `GATES.r10v188.txt` | the whole battery, three binaries, with the cmds.txt audit |
| `GRIDS.r10v188.txt` | every arm, both scorers, both binaries |
| `BOUNDARY.r10v188.txt` | the wide gate run twice; the identical mover sets; the `.bss` arithmetic |
| `CENSUS.r10v188.txt` | the corpus census, golden-vs-golden first |

Re-run with `r10uvm188repro`'s own drivers:

```sh
CEN=<ct188cen> ../r10uvm188repro/grid188.sh arms/v188_f_fold.sv <pris> <patched> <wd>
python3 ../r10uvm188repro/score188.py <wd>/g.cen <wd>/a.cen <wd>/b.cen --only-moved
python3 scorejudged188.py            <wd>/g.cen <wd>/a.cen <wd>/b.cen
PRIS=… PATCHED=… ../r10uvm188repro/bound188.sh <copy of tools/probe> <outdir>
```
