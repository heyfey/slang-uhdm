# r11u110 — the override element of a packed-array type-parameter typespec (cluster C's last typespec-ground head)

Base `751362a0`. Pins as in `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 `0445655ee7`, uhdm2rtlil v0.68.

Production surface: `src/UhdmExporter.cpp` (law 1) and `src/TypeEmit.cpp` (the face-2 laws).
The four fenced files (`ModuleEmit.cpp`, `ExprEmit.cpp`, `EmitHelpers.h`, `ParamEmit.cpp`)
and `results/*.csv` are untouched.

| binary | md5 |
|---|---|
| pristine (this worktree, `-j 2`) | `1dae94065a1ba3fe44c9b50007752e64` (the OPS pin) |
| law | `53761406d096e3b700d440e9ca1fd67f`. A fresh `751362a0` tree plus this patch rebuilds to the same md5. |

## Outcome

| row | base lines/heads | law lines/heads | next head |
|---|---|---|---|
| uhdm2rtlil `type_param_override_elem_sel`, both modes | 47/1 | **0/0: CONVERTS** | none |

**CONVERSION.** The committed rows are

```
type_param_override_elem_sel,default,CMP_NOTEQUAL,decompile:,,
type_param_override_elem_sel,testflags,CMP_NOTEQUAL,decompile:,,
```

(`results/golden_uhdm2rtlil.csv` rows 793 and 1664; `results/gate_uhdm2rtlil.csv` row 793 is
the testflags one). The law sweep reads

```
type_param_override_elem_sel,default,CMP_EQUAL,,,differ
type_param_override_elem_sel,testflags,CMP_EQUAL,,,differ
```

`results/*.csv` is untouched. The master promotes the rows.

## Q1: the head at 751362a0 (official `uhdm-cmp`, LHS = golden)

47 lines, 1 head (`evidence/HEADS.txt`):

* LHS: `logic_typespec` id 106 at 32:17-32:28 — the override `logic [1:0]`, range
  `UINT:1`/`UINT:0` size 64 at 32:24/32:26.
* RHS: `<null>`.

This is the vector overload's owner form: golden's element carries a `vpiRange` vector, ours
carries none. Our element is the definition's default `logic` (15:31). The owner is the
element of the `packed_array_typespec` bound to the elaborated port `work@dut.u.rt_i`
(`vpiTypedef`).

## Q2: decode (Surelog v1.87) and our site

**Golden object** (`evidence/WHO_golden_target.txt`, pointer identity):

* The port `u.rt_i` typedef is a `packed_array_typespec` id 110 at 17:31. It is parented at the
  DEFINITION's `type_parameter rt_t` id 12, its range vector is the definition's original one,
  and its element ref `id_t` (fullname `work@child.rt_t.id_t`) points at id 106. Id 106 is a
  parentless clone of the override (32:17), a distinct object from the instance
  `type_parameter id_t`'s own override object (id 104).
* The variable `u.rt_i` (a `packed_array_var`, pass 107) points at yet another rebuilt array,
  id 123 (element id 119, again a clone at 32:17).
* The definition's `rt_t` and the definition's port both end at id 129 (the last rebind).

So each object is a per-call rebuild: fresh array and fresh element clone, the range vector
and the parent shared with the definition object. It is neither the definition object nor a
share of the instance's `id_t` object.

**Producer:**

* `NetlistElaboration::elaborate_` calls `elab_parameters_` (NetlistElaboration.cpp:735)
  before `elab_ports_nets_` (:737).
* The type-parameter loop (:199-202) runs `elabTypeParameter_` on every definition type
  parameter. Its tail (ElaborationStep.cpp:1716-1757) re-points the definition's
  `type_parameter` at a new array. The array's element is `bindTypespec`'s clone
  (CompileType.cpp:667-714).
* The port writer (NetlistElaboration.cpp:2862-2884) compiles `rt_t` with the instance.
  `compileTypespec` falls to the definition's parameter list (CompileType.cpp:1995-2006) and
  returns that type_parameter's current actual, uncloned. That actual is the array just
  minted for this instance.
* `bindTypespec`'s loop (:672) climbs the whole instance chain without stopping. The
  OUTERMOST instance that overrides a type parameter of that name BY NAME wins (grid e36, e37,
  e42, e43). An ordered type override registers nothing (grid e31, e33-e35).

**Our site.** The elaborated port writers share `typeParamDefaultTs`, the definition's
original array: the child road at ModuleEmit.cpp:16055 and the top road at :28373. Both are
FENCED. The law is therefore a post-pass in our ground, `src/UhdmExporter.cpp`
(`rebindElabPortTypeParam110`). It runs just before pass 105's `rebindTypeParamElem107`, and
re-points only the ports whose ref still reads the original array.

## Q3: grids (`evidence/GRIDS.txt`; golden-vs-golden calibration 87 new arms, 0 nonzero, `calib110.sh`)

* `grid/e1` (51 arms). The override × default grid:
  * defaults: scalar, packed, struct, typedef;
  * overrides: vector, 2-state, signed, struct, enum, union, module, `$unit` and package
    typedefs (logic / bit / int / scalar / enum / struct / union);
  * placement: two instances with different or equal overrides, override-then-default,
    generate if/for, instance array, nested, pass-through, three-level;
  * parameter shape: chained array parameter, non-local `parameter type`, the array
    parameter itself overridden, top-module shape;
  * ports: written dims on the port, two ports, output, non-ANSI;
  * override form: ordered overrides, a same-named parent override, interface port (control).
* `grid/f2` (19 arms). Face-2 initialiser, interface, unpacked-element and attribute arms.
* `grid/m2` (17 arms). Multi-dim and union package-member arms.
* Controls, re-run on both binaries: `r11u108repro/grid` (83), `v11u108repro/brk` (54),
  `r11u107repro/grid` (55), `v11u93b107repro/brk` (47).

## Q4: the laws, each droppable alone (`evidence/SWITCH.txt`)

| law | file | switch | owns |
|---|---|---|---|
| § tpElemRebindElabPort110 | UhdmExporter.cpp | `R11U110_PORT_OFF` | 62 arms |
| § tpPackedArrayTsVarInit110 | TypeEmit.cpp `makeVar` | `R11U110_INIT_OFF` | 5 arms |
| § tpPackedArrayElemReg110 | TypeEmit.cpp `emitArrayVar` | `R11U110_ELEMREG_OFF` | 4 arms |
| § tpPackedArrayTsVarAttr110 | TypeEmit.cpp `emitTypeParamArrayVar` | `R11U110_ATTR_OFF` | 2 arms |
| § defPkgMemberTdOfNamedSharesMulti110 | TypeEmit.cpp `buildStructTs` | `R11U110_PKGTDMULTI_OFF` | 5 arms |

`R11U110_OFF=1` drops all five laws. Checked over 325 arms:

* With `R11U110_OFF=1`, every arm is byte-identical to pristine.
* 78 arms move. Each one is owned by exactly one switch: that switch alone restores pristine,
  and every other switch leaves the law bytes. No arm moves partially.

Gates of law 1:

* The instance did not override the array parameter (its copy keeps the element name).
* The binding is read from the outermost chain instance with a NAMED override of the
  element's name. The names come from the slang instantiation syntax (`ovr110`).
* CHAIN: an element naming another rebindable array parameter abstains. `getParameterMap()`
  is name-ordered, so golden's port reads a stale array (e18).
* PACKAGE-VECTOR: a `pkg::` logic/bit/int binding abstains. Golden's clone is named `w_t`
  where ours is `pk::w_t` (e21, e46, e48, e51, e52). Struct, union and enum fire (e45, e47,
  e53, r06).
* The law mints only when the binding differs judge-visibly from the default element.

Face-2 laws:

* INIT covers a body declaration with a LITERAL initializer only.
* ELEMREG fires when the element's written type is the type-parameter alias whose elaborated
  typespec is a `packed_array_typespec`.
* ATTR applies the verifier's DataDeclaration gate to the written-dims cell.
* MULTI applies to ≥2 packed dims, on pass 107's gates.

## Q5: census and prediction (`evidence/CENSUS.txt`, `evidence/PREDICT.txt`, written before the law sweep finished)

* **`cen110`** (golden first; the target row is the positive control). The shape exists only
  in:
  * `type_param_override_elem_sel`, both modes. The golden element is at 32:17, ours at
    15:31, so the row moves.
  * `type_param_packed_dim`, both modes. It is a top module, the law does not fire, and the
    row stays byte-identical at CMP_EQUAL.
* **`cenv110`** (face-2 variable kinds). Golden and our counts are equal on every row. The
  only exception is Tnoc, which is SLANG_REJECT.
* **`cenmrun110`** (package-member bindings). Only `stamped_gen_param`, which is pass 107's R0
  element, not the multi-dim shape.
* **Predicted movers:** `type_param_override_elem_sel`, default and testflags. Nothing else
  but the UVM class.

## Q6: gates

* **Goldens:** 23/0. The `/bin/false` control gives 0/23.
* **uhdm2rtlil, both modes:** the row-join against the committed baselines differs only in
  the two conversion rows. byteverify (SELFCHECK) gives MOVERS 2/1608, exactly the predicted
  pair.
* **Surelog, `--mode both`:** statuses are identical to the baseline and to pristine.
  * Row-join differences are environment only: the LowMem log path, and the Earlgrey dump
    column that was blank on the pristine draw.
  * byteverify gives 4/960 movers: MiniAmiq and SeqDriver, both modes. Each is the documented
    4-line `UINT`/`vpiDecompile` line-number class (order-blind dump diff = 4 lines), and all
    stay CMP_EQUAL.
* **Canaries:** `canaries.sh` gives ok=52 and ok=8 (changed 0). `ctcan2.sh` PASS on both.
  `canaudit.sh` PASS.
* **Protected databases (law = pristine):**

  | database | md5 |
  |---|---|
  | SVSwitch, both modes | `4842211c4030` |
  | YosysVerx, both modes | `6ccda350c24a` |
  | InterfaceModPort | `59a365f3ce2c` |
  | Earlgrey_0_1, testflags | `59d0ee6d10c3` |
  | Earlgrey_0_1, default | `8bdf25272e08` |

  BlackParrotComplex and YosysOldOr are also identical to pristine.
* **The ten conversion rows** stay CMP_EQUAL. `type_param_packed_dim` is byte-identical.
* **Per cell, by name key** (`cell110`: PORT/VAR/TPAR by instance path; `evidence/CELLS.txt`):
  * 95 cells are TO-GOLDEN, with AWAY 0 and MOVED-WRONG 0.
  * 5 package-member bindings (cellm108) are BINDING TO-GOLDEN. Their element sits on pass
    107's R0 listing object, the same class as pass 107.
* **Whole-dump distance** (`evidence/DIST.txt`): it does not increase on any mover arm except
  the four multi-dim member arms (+1/+5). The cause is the same as pass 107 face 2: the
  pristine member-span copy matched lines of golden's element subtree by coincidence, and the
  R0 listing object has no element.
* **Wide boundary** (`bnd110.sh`, `evidence/BOUNDARY.txt`): 8982 committed probe sources,
  PROCESSED = LISTED, 0 RCDIFF, 31 movers.
  * 28 are the four control grids' movers, already scored per cell.
  * 3 are the known layout-tail arms (g22, l154_noenum, g185_e_kinds). Each differs only in
    the weaklyReferenced tail constant, and `layoutproof154.sh` reports LAYOUTPROOF OK.
* **Gates in full:** `evidence/GATES.txt`.

## Residues (ranked)

* **R0 (fenced, ParamEmit).** `stamped_gen_param` 17/1 (pass 107's R0). The same element-less
  `pkg::T` listing object is now the next head of grid m2 n01/n02 and brk c13 (17/1).
* **R1 (fenced, ModuleEmit), the interface road.** The shape does not reach the law in an
  interface instance (e41 port + var, b03, f2 i04/i19). The interface var's typespec is a flat
  logic_typespec: `sharedTypespec` at ModuleEmit.cpp:41220. Kind-only fixing was measured
  MOVED-WRONG, so it is refused.
* **R2 (fenced, ModuleEmit), initialisers.**
  * A PORT default (b23, b24, f2 i20) is re-folded by the caller at ModuleEmit.cpp:12916-12934.
    Ours is `UINT:90` / `UINT:0` where golden keeps `8'h5a` / `'0`.
  * A NON-LITERAL body initializer (f2 i22) gets no vpiExpr from the caller.
  * The written-dims initialised cell (r11u108 f5a22) is still dropped by the factory's
    written-dims half.
* **R3 (our ground, a separate face).** The package-vector binding name. Golden binds a clone
  named `w_t`; our instance copy binds the listing `pk::w_t`. TPAR/VAR `rt_t` are NE at base on
  e21, e46, e48, e51 and e52, and law 1 abstains there (the PACKAGE-VECTOR gate).
* **R4 (Surelog quirk, grid only).** The OUTERMOST-ancestor binding also reaches the instance's
  own `rt_t` copy and variable. On e36, e37, e42 and e43 the port is TO-GOLDEN, but TPAR/VAR
  stay NE (base NE). The instance copy is built by `namedElemPackedDimTs31(forElab)`, called
  from the fenced ParamEmit.cpp:21609.
* **R5.**
  * The union member (brk c14): golden INVERTS the struct law. The DEF listing keeps the
    member-span wrapper and the TOP listing binds `pkg::T`. The next head sits in the package
    parameter's union clone. A TOP-listing copy was measured and reverted.
  * The non-ANSI body-declared type parameter (brk b05): the header-only syntax read, at the
    fenced ParamEmit.cpp:21560-21610.
  * k12: the package listing (fenced).

## Tools

| tool | what it does |
|---|---|
| `grid110.sh` | Arm driver (copy of grid108.sh); records rc. |
| `calib110.sh` | Golden-vs-golden calibration. |
| `cell110.cpp` / `score110.sh` | Per-cell scorer and TO-GOLDEN/AWAY/MOVED-WRONG tally. |
| `dist110.sh` | cmp count plus order-blind whole-dump distance. |
| `sw110.sh` | Switch identities. |
| `cen110.cpp` / `cenrun110.sh` | Law-1 census. |
| `cenv110.cpp` / `cenvrun110.sh` | Face-2 variable census. |
| `cenmrun110.sh` | Runs r11u108's cenm108 over a sweep. |
| `bnd110.sh` | Wide boundary. |
