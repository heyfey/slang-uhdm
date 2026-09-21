# r11v71 — ADVERSARIAL VERIFICATION of r11u71 (§ caStructParamGenScopeShareCut71)

Base `d2fe2435`. Pristine `ed42e95baf0385529f25f139e2eb32d2` (the OPS pin,
rebuilt from scratch in this verifier's own worktree). Implementer's binary
`8218fa497f10cd0ce05add9441e162ab`. This verifier's shipped binary
`0aeedd2aa3f6ee66f83922bc991fa7fd` (the implementer's patch plus § the
INSTANCE-ARRAY HOP below).

**VERDICT: ACCEPT-WITH-FIX.** Every headline number reproduced bit for bit.
No cell anywhere in 42 arms goes pristine-right → patched-wrong. One golden
divergence the patch leaves on the table is fixed here, measured, gated by the
patch's own `R11U71_NS_OFF`.

---

## 1. Reproduced, independently

| claim | implementer | this verifier |
|---|---|---|
| pristine md5 | `ed42e95b…` | `ed42e95b…` ✓ (= OPS pin) |
| patched md5 | `8218fa49…` | `8218fa49…` ✓ |
| goldens | 23 PASS / 0 FAIL, `/bin/false` 0/23 | ✓ both binaries |
| u2r both modes | `787/17/67`, rows PASS | ✓ PASS vs `d2fe2435`'s CSVs AND vs own pristine |
| surelog | `474/9` + `469/8` | ✓ identical on both binaries |
| u2r byte movers | 0 / 1608 | ✓ 0 / 1608, comparator self-check 1607/1608 |
| surelog byte movers | 4 / 960, all UVM | 3 / 960, all UVM (a different draw of the same coin) |
| u2r site census | 5588 cells, 3658 / 234 / 1696 | ✓ 5588, 3658 / 234 / 1696 |
| surelog site census | 28136 cells, 5002 / 7572 / 15562 | ✓ 28136, 5000+2 / 7572 / 15560+2 |
| cells where the law FIRES | 0 / 0 | ✓ **`sps=1` count is ZERO in both corpora** |
| `R11U71_OFF=1` = pristine bytes | 34 arms | ✓ **42 arms, byte-identical** |

The base did move: the main tree is at `9637b9fd` (pass 69), which rewrote
`typed_named_pattern` in both `results/` CSVs. Every join here is against
`d2fe2435`'s own committed CSVs. `results/*.csv` untouched; no row CONVERTS.

---

## 2. THE PRODUCER SITE — the patch's law is right, its citation is not

`r11u71repro/README.md` §2 and the § comment quote
`UhdmWriter.cpp:2121-2176` and conclude "the producer substitutes on every
cell". **The quoted block cannot support that conclusion**: its `reduceExpr`
and its `adjustSize` (`:2156`) both sit inside `if (var)`, i.e. inside
`bindVariable`'s name hit, and inside `if (rhs->UhdmType() == uhdmoperation)`
and `if (cloned == false)`.

The site that actually runs for these cells is **`UhdmWriter.cpp:2245-2281`**,
the `if (simplified == false)` arm, quoted from the pinned Surelog
`0445655ee7`:

```cpp
      if (simplified == false) {
        bool invalidValue = false;
        …
        any* res = m_helper.reduceExpr((expr*)rhs, invalidValue, mod, …);  // :2257
        if (invalidValue == false) {
          if (res && (res->UhdmType() == uhdmconstant)) {
            if (cloned == false) {
              assign = (cont_assign*)UHDM::clone_tree(assign, …);          // :2269
              assign->VpiParent(m);
              lhs = assign->Lhs();
              cloned = true;
              res = m_helper.adjustSize(tps, mod, …, (constant*)res, true);// :2274
              res->VpiParent(assign);
            }
            assign->Rhs((constant*)res);                                   // :2280
```

Three facts follow, and all three are what the grid measures:

1. **`:2257` is NOT gated on `bindVariable`.** The reduce — the substitution —
   runs for every cont_assign the earlier arms did not already simplify. *That*
   is why the pass-68 "share" premise is refuted, and the implementer's
   conclusion stands.
2. **`:2274` reads `tps`**, which `:2110` initialises from the **Lhs ref's own
   typespec** and `:2168-2172` overwrites with `bindVariable`'s hit. A
   gen-scope cont_assign's Lhs `ref_obj` carries NO typespec in golden
   (verified in golden's own dump on `w9`, `n5`, `x6`, `x8`), so with no name
   hit `tps` is null and `adjustSize` returns at once. The implementer's rule —
   "size = the name hit's declaration, else the member width" — is therefore
   correct, and the `:2168-2172` citation IS the right one *for the width*.
3. **`:2269` clones and re-reads `lhs`**, so the substituted cell's Lhs ref is a
   clone outside `getLateBinding()` — the implementer's LAW A explanation,
   confirmed.

The correction matters because the § comment is the deliverable: as written it
quotes a block whose own reduce is `if (var)`-gated, which reads as
"no name hit ⇒ no substitution" — the opposite of the law.

### 2a. The delay fence exists but is unreachable through a parameter delay

`:2100` sets `cloned = true` when `assign->Delay()` is a `ref_obj`, which by
`:2267` would skip `adjustSize` while `:2280` still installs the constant. Arm
`x2_delayclone` puts a `ref_obj` delay on a namesake cell and golden **still**
re-sizes (`UINT:44 vpiSize:8`, the same as the delay-free control `gp_ns`):
after elaboration a parameter delay is no longer a `ref_obj` in the netlist
cont_assign. The fence is real in the source and not reachable by this shape —
recorded, not modelled. (`x2`'s own head is a DEF-view delay `ref_obj` golden
carries and we do not; byte-identical pristine, patched and fixed.)

---

## 3. THE FIX — § the INSTANCE-ARRAY HOP

`genCaSubstAdjustW71`'s walk climbs `GenerateBlock` / `GenerateBlockArray` and
hops `InstanceBody → parentInstance->getParentScope()`. For an instance that is
a member of an **instance array** that parent scope is the
`InstanceArraySymbol`, which matched neither arm, so the walk **broke** and the
namesake was never found. `bindVariable` crosses it: an array has no case in
its switch either, so its `default:` recurses through `scope->VpiParent()`.

Measured on golden, arm **`x8_instarray`** — one leaf holding a gen-local `anc`
shadowed by dut's 5-bit body namesake, instantiated once singly and once as
`u_arr[0:1]`:

| cell | golden | pristine | r11u71 | r11v71 |
|---|---|---|---|---|
| `u_one.g.anc` | `UINT:12 sz=5` | `UINT:300 sz=32` | `UINT:12 sz=5` | `UINT:12 sz=5` |
| `u_arr[0].g.anc` | `UINT:12 sz=5` | `UINT:300 sz=32` | `UINT:300 sz=32` | `UINT:12 sz=5` |
| `u_arr[1].g.anc` | `UINT:12 sz=5` | `UINT:300 sz=32` | `UINT:300 sz=32` | `UINT:12 sz=5` |

Arm **`x6_ifacedeep`** is the interface twin (`u_arr[1].gi.inbody`, golden 9
bits from the instantiating module) and **CONVERTS** under the fix:
`cmp_rc 255 → 0`. All 12 `x8` cells match golden after the fix; that arm's
remaining head is an unrelated instance-array port concat, byte-identical on
all three binaries.

The hop needs no gate of its own — it is inside the namesake walk, so
`R11U71_NS_OFF=1` drops it with the rest. Surface: three lines plus the
comment, in the function the patch already adds.

---

## 4. THE ADVERSARIAL GRID — 8 new arms on top of the pass's 34

Every arm `golden_rc=0 ours_rc=0` (no arm teaches error recovery).

| arm | what it pushes | PRIS | r11u71 | r11v71 |
|---|---|---|---|---|
| `x1_typedhomes` | 9 namesake DECLARATION TYPES: packed struct, enum, signed, real, time, unpacked array, int, shortint, byte | 255 | 255 | 255 |
| `x2_delayclone` | a `ref_obj` delay on a namesake cell, ×4 | 255 | 255 | 255 |
| `x3_nofold` | Rhs shapes elaboration may leave unfolded: nested member, whole inner struct, X/Z member, member+1, bit-select, part-select | 255 | 255 | 255 |
| `x4_genarray` | a for-generate ARRAY, per-iteration namesake, ancestor gen-local target | 255 | 255 | 255 |
| `x5_perinst` | one module text instantiated at two namesake widths; an ancestor-GEN namesake that must NOT be found | 255 | 255 | 255 |
| `x6_ifacedeep` | interface in a gen block, interface ARRAY, namesake in the module body vs in the instantiating gen block | 255 | 255 | **0** |
| `x7_oddhomes` | namesakes that are an INSTANCE, a function, a typedef, a genvar, an implicit net | 255 | **0** | **0** |
| `x8_instarray` | the instance-array hop (§3) | 255 | 255 | 255 (all 12 cells match) |

**Converting arms, whole grid: 9** — `w9_sharehead`, `w10_sharesize`,
`v2_ancnamesake`, `v7_ifacemix`, `v10_arraysel`, `n3_ifacegrid`, `n5_declkind`,
`x7_oddhomes` (verifier), `x6_ifacedeep` (verifier, fix only).

**Cell-level regression scan, the instrument that decides:** for all 42 arms,
the set of differing cells (resolving lister, `NOSPAN=1`) under pristine and
under each shipped binary, joined by key. **Newly-differing cells: 0** for the
implementer's binary and 0 for the fixed one. No arm's differing count rose.

### 4a. Gate droppability (official `uhdm-cmp` rc, fixed binary)

| arm | PRIS | FIX | `_OFF` | `_NS_OFF` | `_IF_OFF` |
|---|---|---|---|---|---|
| `w9_sharehead` | 255 | 0 | 255 | 0 | 0 |
| `w10_sharesize` | 255 | 0 | 255 | 0 | 0 |
| `n5_declkind` | 255 | 0 | 255 | 0 | 0 |
| `x7_oddhomes` | 255 | 0 | 255 | 0 | 0 |
| `v2_ancnamesake` | 255 | 0 | 255 | 255 | 0 |
| `n3_ifacegrid` | 255 | 0 | 255 | 255 | 255 |
| `v7_ifacemix` | 255 | 0 | 255 | 255 | 255 |
| `x6_ifacedeep` | 255 | 0 | 255 | 255 | 255 |

`R11U71_OFF=1` on the shipped binary reproduces the pristine database **byte
for byte on all 42 arms**.

---

## 5. CENSUS — both corpora, both modes, a priori, with a positive control

Site census (`cellcen71.py`, the harness's own discovery and argv, the four
fenced names parsed out of `canaudit.sh`'s `FENCED=` and skipped — verified, 4
names):

| profile | uhdm2rtlil | surelog |
|---|---|---|
| **cells where the predicate fires (`sps=1`)** | **0** | **0** |
| `spsAny=1` with the gates declining | 0 | 0 |
| gen-local half (cut opens it) | 3658 | 5000 (+2 iface) |
| pass-68 half | 234 | 7572 |
| `plainLhs=0` | 1696 | 15562 |
| **cells reaching the site** | **5588** | **28136** |

`sps` is ZERO on every one of the 33 724 cells: the struct-parameter
substitution predicate matches no generate-scope `cont_assign` in either
corpus, so **neither gate, nor the namesake width, nor the instance-array hop
can move a corpus row. A-priori mover set: 0 tests, both corpora, both modes**
— stated before the byte gate, and the byte gate agreed.

**Positive control** (the census zero is not blindness): the same driver over
this pass's own grid reports firing cells by name — `n2_bindhomes` 8 cells
(4 newly fired), `x6_ifacedeep` 16 (all newly fired), `x8_instarray` 3 with
`adjw` moving `0 → 5` under the fix.

**Named blind spots, not dropped.** `Tnoc` (both modes) segfaults under the
probe's argv on the **pristine binary too** — a pre-existing hidden segfault of
the class §9 names, recorded as `SLANG_REJECT` by the harness on both sides, 0
cells enumerated. `Rggen/testflags` exits `-11` after emission: it traces the
same 4549 cells as its clean `default` run, so its census is complete. Three
`rp32_*` u2r rows segfault and are already `SLANG_REJECT` in both sweeps.

---

## 6. GATES (fixed binary unless stated)

1. builds: pristine `ed42e95b…` = the OPS pin; implementer `8218fa49…`;
   shipped `0aeedd2a…`. Built `-j 2`, md5 separately, all three frozen `555`
   before any sweep.
2. goldens `23 PASS / 0 FAIL` on all three binaries; `SLANG_UHDM=/bin/false`
   `0 PASS / 23 FAIL`.
3. u2r both modes on all three binaries: rows PASS vs `d2fe2435`'s
   `gate_uhdm2rtlil.csv` (testflags) and vs `golden_uhdm2rtlil.csv` filtered to
   `default`, and PASS vs own pristine. Byte movers **0 / 1608** for both the
   implementer's and the fixed binary; comparator self-check 1607/1608.
4. surelog `--mode both`: `474/9` default + `469/8` testflags on all three.
   Whole-row joins vs pristine: default **0 differing rows**; testflags 2 rows
   (`LowMemLib`, `LowMemPkg`) whose `SURELOG_FAIL` detail string embeds the
   workdir path. Vs the committed baseline, additionally `Earlgrey_0_1` both
   modes with a blank dump column — a `uhdm-dump` timeout draw under load, on
   the PRISTINE sweep as well; its DATABASE pins hold exactly
   (`8bdf25272e08` default, `59d0ee6d10c3` testflags).
5. byteverify surelog, implementer's binary: 3 movers / 960 —
   `default/MiniAmiq`, `testflags/MiniAmiq`, `testflags/SeqDriver`, each
   differing by **exactly 4 order-blind lines**, one `UINT:` + `vpiDecompile:`
   pair carrying a line number. **Positive control:** the PRISTINE binary alone,
   5 runs, gives **4 distinct hashes** on `MiniAmiq/default` and **5 distinct
   hashes** on `SeqDriver/testflags`, none equal to either sweep's — the
   documented UVM coin, not the law.
6. canaries `u2r ok=8 changed=0`; surelog `ok=50 changed=2`, both changes the
   `Earlgrey_0_1` dump column, identical on the pristine sweep. `ctcan2` PASS
   both corpora. `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`. `rowheads`
   0 lines / 0 heads for SeqDriver, SimpleUVM, Scoreboard, MiniAmiq,
   BuildUVMPkg, Earlgrey_0_1 (both modes); `Rggen/default` at its baseline
   64/1. Hard pins byte-identical on every binary: SVSwitch `4842211c4030`,
   YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
   BlackParrotComplex, YosysOldOr.
7. every `cmds.txt` audited by binary PATH: 1581 surelog + 1742 u2r per sweep,
   **exactly one exporter path per sweep** and it is the frozen one; the 51
   surelog files without it invoke no exporter at all (same 51 on both).

**SCORE: MOVED-WRONG 0, AWAY-GOLDEN 0**, both corpora, both mode columns.
Corpus: 0 rows CONVERT / ADVANCE / REGRESS — the census's own prediction.

---

## 7. RESIDUES (ranked)

- **R1 — the namesake Lhs binding** (the implementer's R1, confirmed
  independently). Golden points a namesake cell's Lhs `ref_obj` at the
  module-body namesake (`:2166 ref->Actual_group(var)`); we carry none.
  Measured on `x4_genarray`: all three `gl[i].ns` refs carry
  `vpiActual -> logic_var (work@dut.ns)` in golden and none in ours — **in the
  PRISTINE dump as well as the patched one**. Pre-existing and unmoved; it
  became `x4`'s head only because the object ahead of it was fixed.
  Population: 3658 u2r + 5002 surelog `genLocal=1` cells — a wider law, its own
  pass.
- **R2 — the package-imported namesake** (`w8_unitname` `gp`): golden re-sizes
  to the imported signal's 16 bits, binding a module-level `logic_var` Surelog
  materialises for the import; `slang::ast::Scope::find` returns `nullptr` for
  an `ExplicitImport`. Declined and recorded by the implementer; confirmed here
  — `w8`'s head moved from a binding residue to this size residue, and the
  three gen cells all moved from `hier_path` (pristine) to golden's constant
  shape.
- **R3 — an UNPACKED-ARRAY namesake** (`x1_typedhomes` `g_ua`): golden's
  `adjustSize` with an unpacked-array typespec emits `UINT:0` (the VALUE is
  zeroed, not just the width); `caLhsAdjustBindSymW71` returns 0 for
  non-integral, so the member value stands. **Identical in pristine** — not a
  regression, an unmodelled cell. One arm, odd shape; record.
- **R4 — the Rhs shapes elaboration folds and we do not** (`x3_nofold`):
  `CFG.n + 1` (golden `INT:301 sz=64`), `CFG.n[3]` (`BIN:1`), `CFG.n[7:4]`
  (`UINT:300 sz=64`). Unmoved by this pass; a different predicate's ground
  (`caStructParamSetter55` accepts only a whole-member setter).
- **R5 — the DEF-view delay `ref_obj`** (`x2_delayclone`'s head): golden
  carries a delay ref on the uninstantiated cont_assign, we carry none.
  Byte-identical on all three binaries.
- **R6 — r11u69's R1/R2/R3 stand unmoved**, and the lister's `SHARED-AMBIG`
  rows (golden shares one constant object where we mint one per cell with the
  same fields — invisible to the judge, `Compare` reads no `VpiParent`).

**R0 — NEXT.** Unchanged from the implementer's: the gen-scope substitution is
the producer's rule end to end, so the next road-E cell is r11u69's R2 —
§ `caAsmMemberSliceFold`'s function-built struct parameter extended to the
generate-scope listing — then r11u69's R1. R1 above (the namesake Lhs binding)
is the widest single remaining law on this ground and is measurable today.
