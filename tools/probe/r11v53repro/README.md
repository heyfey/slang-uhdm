# r11v53 — adversarial verification of r11u53 (FOLDMAP ROAD A: `$bits` of a type parameter)

**VERDICT: ACCEPT WITH FIX.** The implementer's law is right about the cell it
targets and every headline number reproduces bit-for-bit, but the law as
written is stated one notch too wide and **regresses four judge-EQUAL faces on
legal SystemVerilog**, one of which is the corpus witness's own source with the
`import pkg::*` that real designs write beside it. The refusal is now gated on
§ `importedTypeShadowsTypeParam53`; with the gate the corpus behaviour is
**byte-identical** to the implementer's binary (0 movers / 1608 uhdm2rtlil
databases) and all four broken faces are judge-equal again.

Ships as `r11u53.verified.patch`. Surface: `src/EmitHelpers.h` (the gate),
plus the implementer's `src/ExprEmit.cpp` / `src/ParamEmit.cpp` unchanged, plus
`tools/probe/r11u53repro/` and this directory.

---

## 1. What reproduced, independently

Both binaries were configured and built in this verifier's own worktrees at
`e3a249bd` and frozen before any sweep; every `cmds.txt` in every sweep names
the frozen path.

| item | implementer's claim | measured here |
|---|---|---|
| pristine binary md5 | `7ad7754335b99b206c84ce70148edec3` | same, and byte-identical to the main tree at `e3a249bd` |
| patched binary md5 | `603fd453ae8e481417463eada04cabe1` | same |
| head at base, `bits_of_type_param` | golden `sys_func_call ($bits)` 17:39, arg `ref_obj (work@dut.req_t)`; ours `constant UINT:97 vpiSize:64` | identical, both modes, one head (`grep -c '^LHS:'` = 1) |
| residue at base | 20 golden-only / 83 ours-only; `orderblind_diff` 155 default / 153 testflags | identical |
| uhdm2rtlil | 783/21 → 784/20 both modes, one differing row | identical |
| the conversion | `bits_of_type_param` `CMP_NOTEQUAL` → `CMP_EQUAL` both modes | identical |
| u2r byte movers | 6 / 1608, exactly `bits_of_type_param`, `type_param_packed_dim`, `type_param_override_elem_sel` × 2 modes | identical; selfcheck 1607/1608 |
| subset containment | `NOT-PRESENT-BEFORE = 0` on all six | identical |
| golden dumps | `PASS=23 FAIL=0`, `/bin/false` `FAIL=23` | identical |
| grid direction | six arms toward golden, `w3` unchanged, zero away | identical (`r11u53repro/toward53.sh`) |

The producer decode also holds against the pinned Surelog `0445655ee7`:
`compileBits` `src/DesignCompile/CompileExpression.cpp:4686`; `getTypespec`
`:4414`; bare-name `basename` `:4453` (the map says `:4452`); the two-map
lookup `:4541-4544` with ports/signals at `:4546`/`:4553`; the self-upgrade
`isFullySpecified` → `reduce = Reduce::Yes` at `:4754-4755`; the mint at
`:4781`; the `sys_func_call` `else` at `:4803`, its `VpiName("$bits")` at
`:4805` (the report says `:4802`). The ±1 citation drift is cosmetic.
`m_dataTypes` has exactly five doors — `DesignComponent::insertDataType`
(`src/Design/DesignComponent.cpp:103`) called from `compileTypeDef`
(`CompileHelper.cpp:636`), imported class definitions (`:160`), **package
imports (`:168`)**, `DesignComponent::append` (`:100`) and `Package::append`
(`src/Package/Package.cpp:66`). The parameter table is in none of them — and
**`:168` is the door the implementer's law walked past**.

## 2. The break: an imported package type shadows the type parameter's name

`CompileHelper::importPackage` copies the **whole data-type map of every
imported package** into the importing component's map. So when an imported
package exports a type whose name is the module's type parameter's,
`getTypespec` DOES resolve the bare name and `compileBits` FOLDS — while a
SystemVerilog lookup binds the local parameter (a local declaration beats a
wildcard import, IEEE 1800-2017 §26.3). The implementer's predicate answers
only "is this name a type parameter here", so it refuses the fold and emits a
`sys_func_call` where golden minted a constant.

Fifteen arms, `grid/x1`–`x15`, all `golden_rc=0 ours_rc=0` on real v1.87
goldens (`evidence/RC.*.txt`, `evidence/TOWARD.txt`, `evidence/VIEWS.txt`).
**SIX faces break; the fix restores every one cell-for-cell, in both views:**

| arm | judge at base | r11u53 | verified fix |
|---|---|---|---|
| `x1_import_shadow_same` module-header `import pk::*`, colliding name, equal widths | **`cmp_rc=0`, 0 heads** | `CMP_NOTEQUAL` | **`cmp_rc=0`** |
| `x9_unit_import_shadow` the import at COMPILATION-UNIT scope | **`cmp_rc=0`** | `CMP_NOTEQUAL` | **`cmp_rc=0`** |
| `x10_iface_import_shadow` the same face in an INTERFACE | **`cmp_rc=0`** | `CMP_NOTEQUAL` | **`cmp_rc=0`** |
| `x11_realistic_cva6` the corpus witness's own source + `import pk::*` | **`cmp_rc=0`** | `CMP_NOTEQUAL` | **`cmp_rc=0`** |
| `x15_import_chain` the name arrives through a CHAIN of wildcard imports | **`cmp_rc=0`** | `CMP_NOTEQUAL` | **`cmp_rc=0`** |
| `x13_pkg_import_shadow` the face inside a PACKAGE (head masked; residue 58 → 76 → 58) | cells EXACT | ELAB cell wrong | cells EXACT |
| `x12_import_noshadow` an import that does NOT collide — the control | `CMP_NOTEQUAL` | toward golden | toward golden |
| `x14_import_value_notype` the imported colliding name is a VALUE, not a type | `CMP_NOTEQUAL` | — | — (see R6) |

`x13` is the one the `cmp_rc` column cannot see: golden's package compiles
DEF-keep / ELAB-fold, **pristine matched golden exactly in both views**, and
r11u53 kept the call in the ELAB one. `x15` is the one that made the depth-2
recursion necessary. `evidence/VIEWS.txt` carries all eight side-by-side.

`x11` is the decisive one and it is not contrived: `bits_of_type_param` names
its type parameter exactly as the package typedef it defaults to
(`parameter type req_t = pk::req_t`), which is CVA6's own shape. Add the
`import pk::*` and the answer INVERTS — `evidence/HEAD.x11.txt`:

```
### GOLDEN vs IMPLEMENTER PATCH — the regression head
LHS: constant: line:15:39 |vpiDecompile:97 |vpiSize:64 |UINT:97      <- GOLDEN FOLDS
RHS: sys_func_call: ($bits), line:15:39, |vpiArgument: ref_obj (work@dut.req_t)
### GOLDEN vs PRISTINE e3a249bd   rc=0
### GOLDEN vs VERIFIED FIX        rc=0
```

Without the import golden keeps the call and we minted the constant; with the
import golden mints the constant and the unfixed law emits the call. Same
source, same parameter, mirrored answers — which is the proof that the gate is
the DATA-TYPE MAP, not the syntax alone.

**The law, restated.** `compileBits` folds iff `getTypespec` resolves the
argument, and for a bare name `getTypespec` reaches exactly the component's
data-type map (its own typedefs, its imported classes, **and every imported
package's types**) and its ports and signals. A type parameter is in none of
those — *unless an import has put its NAME there*. The resolved type is never
consulted (the V5 cell `parameter type TB = logic [9:0]` resolves fully and
golden still keeps the call).

## 3. The fix

`src/EmitHelpers.h`, § `importedTypeShadowsTypeParam53`: `pkgExportsType53` /
`wildcardImportedType53` ask whether a wildcard-imported package exports a type
under the bare name; `typeParamAliasType53` refuses the fold only when it does
not. The scope chain is climbed because the import may sit in the module
header, in the interface header, or at compilation-unit scope (`x9` — golden
folds for all three); a package's own wildcard imports are followed to depth 2
because `Package::append` carries them into its map too (`x15` — golden folds
through the chain). The shadow must be a TYPE: `isType()` rejects a colliding
VALUE parameter, which is not in Surelog's data-type map either (`x14`).
Explicit imports need no arm: `import pk::TP;` beside a local
`parameter type TP` is a name conflict, not legal SV.

Cost: the predicate is reached only from `srlgBitsFoldArg`'s `DataType` branch
and `bitsOfTypeParamInit53`, and only after the argument has already resolved
to a type-parameter alias.

## 4. What the fix does NOT change

A-priori prediction from `evidence/CENSUS.txt`: **no file in either corpus that
calls `$bits()` on a type-parameter name carries a wildcard package import**
(uhdm2rtlil: `bits_of_type_param`, `type_param_packed_dim`,
`type_param_override_elem_sel`, `param_type_logic_width` — all 0; Surelog:
`ClassScope`, the two `Ariane2024` collected files, the four `id_queue*`,
`Verilator/t_type_param` — all 0). So the gate cannot fire in either corpus and
the verified binary must be byte-identical to the implementer's.

MEASURED: `byteverify SELFCHECK=1` verified-fix vs implementer-patched,
uhdm2rtlil, **MOVERS 0 / 1608** (selfcheck 1607/1608); the law's own grid
(`r11u53repro/toward53.sh`) scores identically under both binaries. Surelog
likewise (`evidence/GATES.surelog.txt`).

## 5. Census, with its positive control beside it

`evidence/SHAPES.txt` (`r11u53repro/shape53.sh`) — the census zeros are
genuine, not unreached: `param_type_logic_width` and `cva6_struct_param_field`
both carry `type_parameter` objects on BOTH sides (TP 2/2 DEF, 4/4 and 3/4
ELAB) and read `Kg=Kours=0`, i.e. the row is in the counter's reach and the
construct-with-`$bits` is absent. `bits_of_type_param` moves `Kours` 0→2 (DEF)
and 0→4 (ELAB) to meet golden exactly. The other two witnesses keep
`KEEP-COUNT-DIFFERS` in ELAB only (2 of 4) — that is R2 below, not a miss.

## 6. Residues, ranked

* **R1 (was the implementer's R2) — the elaborated half is whole-Rhs only.**
  `$bits(<type param>)` inside a surviving operation keeps the call in the DEF
  view and is still folded in the ELAB one. Measured on `w7_bits_inexpr`
  site 21:23: golden `operation`+`sys_func_call` in BOTH views, ours
  `operation`+`sys_func_call` in DEF and a bare `constant` in ELAB. This is
  what holds `type_param_packed_dim` and `type_param_override_elem_sel` at
  `KEEP-COUNT-DIFFERS` 2-of-4 and is road A's next step.
* **R2 — GENERATE-BLOCK localparams are out of both halves' reach**
  (`grid/x4_genblock_lptype`, `UNCHANGED` under both patched binaries). In the
  DEF view we keep BOTH the type-parameter cell and the `$bits(pk::req_t)`
  CONTROL that golden folds; in the ELAB view we fold both where golden keeps
  the type-parameter one. A pre-existing gen-scope divergence on this road,
  untouched by the pass — its own cell.
* **R3 — the W3 cell** (a module-local typedef whose target is a
  package-scoped name: golden KEEPS in DEF, FOLDS in ELAB). Measured and
  deliberately unwritten by the implementer; `w1` site 26:23 and
  `w3_typedef_view` reproduce it.
* **R4 — a typedef OF a type parameter** (`grid/x5_typedef_of_tp`): both sides
  fold, and the arm moves toward golden, but the arm's residue is large for
  other reasons; not this road's cell.
* **R5 — a class body's localparam emits no object on our side** in either
  binary (`w6_bits_pkgscope` sites 16:25/17:25 read `MISSING`,
  `grid/x7_pkg_class_tp` `UNCHANGED`). Pre-existing.
* **R6 — a wildcard-imported VALUE colliding with the type parameter's name**
  (`grid/x14_import_value_notype`): golden KEEPS in DEF and FOLDS in ELAB to
  `UINT:32` — the width of the imported `parameter int`, not of the local type
  parameter's 97-bit struct. The producer binds the bare name to the imported
  VALUE in the elaborated compile only. Both binaries are `CMP_NOTEQUAL` here,
  so this is a residue and not a regression; the arm's order-blind residue
  moves 98 → 102 because a kept call costs more lines than a folded constant,
  with the same count of wrong cells (2) on both sides. Its own cell, unwritten.

## 7. Re-running

```bash
bash run.sh   <binary> base|impl|fix          # golden + one binary, rc for both, per arm
bash toward.sh                                # order-blind residue per arm, per binary tag
bash cells.sh <arm> <tag> <line:col> ...      # which object sits at a source site
```
Run artifacts are `.gitignore`d; the distilled readings are in `evidence/`.
