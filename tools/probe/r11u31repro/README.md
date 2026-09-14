# r11u31 — a written packed dimension on a NAMED element is an array typespec over that element

`§ typeParamNamedElemPackedDim31`.  Base `4110f3de`, branch `matrix-1.87`,
pins as `SUPPORT_MATRIX.md` states them (slang upstream `7d61e0ad1`, UHDM
v1.87, Surelog v1.87, uhdm2rtlil v0.68).

---

## 1. The head, re-measured on this pass's own pristine build

Pristine binary rebuilt from `4110f3de` in this pass's own worktree, md5
`62547ac98ebcfdeb522171dc946d50ad` — byte-identical to the main tree's
`build/slang-uhdm` at the base.  Official `uhdm-cmp`, LHS always golden:

| row | mode | cmp lines | heads |
|---|---|---|---|
| `type_param_packed_dim` | default / testflags | 94 / 94 | 1 / 1 |
| `type_param_override_elem_sel` | default / testflags | 94 / 94 | 1 / 1 |
| `anon_struct_packed_dim` | default / testflags | 64 / 64 | 1 / 1 |
| `type_param_unpacked_port` | default / testflags | 208 / 208 | 1 / 1 |

`type_param_packed_dim/default`, quoted (`evidence/HEAD.pristine.*`):

```
LHS:                                     RHS:
packed_array_typespec: 5:31..5:52        logic_typespec: 5:31..5:52
|vpiParent: type_parameter (work@dut.rt_t)  |vpiParent: type_parameter (work@dut.rt_t)
|vpiRange:
\_range:                                    (nothing else)
  |vpiLeftRange:
  \_operation: 5:42..5:49  vpiOpType:11
    |vpiOperand: ref_obj (work@dut.rt_t.DEPTH)
    |vpiOperand: constant UINT:1 size 64
  |vpiRightRange:
  \_constant: 5:50..5:51  UINT:0 size 64
|vpiElemTypespec:
\_ref_typespec: (work@dut.rt_t.resp_id_t)
  |vpiName:resp_id_t
  |vpiActual: logic_typespec 2:31..2:42
```

`type_param_override_elem_sel/default` is the SAME TEXT line for line once
ids, spans and the designs' own names are blinded (`work@child.rt_t` /
`work@child.rt_t.id_t`, `17:31..17:47`).  Both are the r11u29 triage's K4
witness pair and both re-measure exactly as the triage recorded them.

**Two corrections to the triage's K4, both measured, not argued.**

1. **The dimension is not written on an OVERRIDE.**  In both witnesses it is
   written on the type parameter's OWN declaration — `localparam type rt_t =
   resp_id_t [DEPTH-1:0]` (line 5) and `localparam type rt_t = id_t
   [DEPTH-1:0]` (line 17).  `type_param_override_elem_sel` does carry an
   override, `child #(.id_t(logic [1:0]))`, but it overrides a DIFFERENT
   parameter and the head sits on `rt_t`'s declaration.  So this face is the
   DECLARATION side, and pass 18/20's default-bound law (`§
   typeParamDefaultBoundNoReduce20`) governs its range bounds — which is why
   golden's bound is the unfolded `DEPTH-1` operation and not a constant.
2. **K4's other two tests are a different producer and did not move.**
   `anon_struct_packed_dim`'s head is an ANONYMOUS PACKED STRUCT on a
   VARIABLE declaration (`struct packed {...} [1:0] content_q, q_n;`, line
   35-38) — no type parameter anywhere in it; `type_param_unpacked_port`'s
   head is a PORT's UNPACKED dimension (`input resp_t in_i [N-1:0]`, line 42)
   and golden builds an `array_typespec` with `vpiArrayType:1`, not a
   `packed_array_typespec`.  Landing this law left both rows byte-identical
   (64 and 208 cmp lines before and after, depth-blind census 0/0/0).  "One
   law covers all four" is REFUTED; K4 is two tests, not four.

---

## 2. The producer, decoded

`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3510-3586`, the
`paTYPE` arm of `compileParameterDeclaration`, with its own comment stating
why it exists:

> `parameter type X = <other type> [msb:lsb]` — a named type carrying a PACKED
> DIMENSION.  The grammar parses this as an EXPRESSION (a `Constant_primary`
> naming the type, with a `Constant_select` holding the range) rather than as
> a data type, so `compileTypespec` sizes it as a plain integer.

So this default never reaches `compileTypespec`'s named-type arm
(`CompileType.cpp:1936-1990`) at all — which matters, because that arm would
NOT have produced this shape: for a `logic_typespec` element it wraps in a
`logic_typespec` (`CompileType.cpp:1949`), never a `packed_array_typespec`.
The dedicated arm builds instead:

* `packed_array_typespec`, span = the whole written `Data_type` node
  (`populateCoreMembers(Data_type, Data_type, pats)`, `:3581`) and no
  `VpiName`; the caller then parents it at the `type_parameter`
  (`tps->VpiParent(p)`, `:3625`);
* exactly **one** `range`, from the FIRST `paConstant_part_select_range`
  found (`:3528-3537` reads one and `break`s), UNLOCATED (no
  `populateCoreMembers` on `rg`), its bounds compiled with `Reduce::No`
  (`:3576-3579`);
* `Elem_typespec` = a `ref_typespec` carrying `VpiName(elemName)` and nothing
  else (`:3569`), whose actual is the element's OWN object — an earlier
  `type_parameter` of the same list first (`:3540-3552` walks `*parameters`
  by name and takes its `Actual_typespec`), else `compileTypespec` of the
  bare name.  The element is deliberately NOT re-parented (`:3583`).

`elemRef->VpiName(elemName)` exists so `elabTypeParameter_` can re-resolve the
element against an overriding instance — which is why the ELABORATED view
carries the same wrapper and only its element differs.

---

## 3. The golden grid — `evidence/GRID.r11u31.txt`

Eleven arms, `gridrun.sh` + `g*.sv`; Surelog `-parse -nobuiltin -nocache`,
ours `--single-unit --nobuiltin`; **every arm records both rcs** (`g7` is
`ourrc=3` — our front end rejects a module-header forward reference to a body
typedef; it teaches error recovery, not golden, and is reported as such).

| arm | written default | golden | ours before | ours after |
|---|---|---|---|---|
| g1 | `logic [3:0]` (keyword) | `logic_typespec` + ranges | **equal (0 cmp lines)** | **equal** |
| g2 | `e_t [3:0]` | `packed_array_typespec` | bare `logic_typespec` | wrapper built; head DEEPENS to the element OBJECT — 68 → 335 cmp lines, see below |
| g3 | `e_t [3:0][1:0]` | `packed_array_typespec`, ONE range `[3:0]` | bare `logic_typespec` | wrapper built; same new head as g2 (68 → 335) |
| g4 | `E [3:0]`, `E` a type param | wrapper, elem = `E`'s own ts | bare | wrapper |
| g5 | `struct packed{..} [3:0]` | wrapper, elem = `struct_typespec` | bare | unchanged |
| g6 | `e_t` (no dim) | shares `e_t`'s object | 17 cmp lines | unchanged |
| g8 | `typedef e_t [3:0] arr_t` | (typedef site) | 36 cmp lines | unchanged |
| g9 | `pk::e_t [3:0]` | **no wrapper — the dim is DROPPED** | matches | unchanged |
| g10 | `e_t [3:0] v;` (variable) | (variable site) | 36 cmp lines | unchanged |
| g12 | `child #(.T(w_t [1:0]))` over `T = e_t [3:0]` | elab actual = bare `logic_typespec (w_t)`, **dim DROPPED** | bare `logic_typespec` | DEF wrapper built, ELAB left bare |

Four of these are load-bearing:

* **g1 is the positive control for agreement.**  A written KEYWORD with dims
  is already equal and MUST stay equal — so the law is gated on the written
  syntax being a NAME, never on the compiled type being a packed array.
* **g3 proves Surelog drops every dimension after the first.**  `e_t
  [3:0][1:0]` and `e_t [3:0]` produce goldens of the same size (314 dump
  lines each) carrying one `[3:0]` range over `e_t`.  We emit one range too.
* **g9 is the measured NEGATIVE control.**  For a PACKAGE-QUALIFIED element
  Surelog's detector never fires (a scoped name puts no `paConstant_select`
  where `:3525` looks) and golden's type parameter keeps the bare
  `logic_typespec (pk::e_t)` with the dimension LOST — 0
  `packed_array_typespec` in the whole golden.  The gate here — the name must
  be an `IdentifierSelectName`, which a `ScopedName` is not — reproduces that
  exactly, and g9 is byte-unchanged across the patch.
* **g12 is the arm that convicted a first cut of this pass.**  Surelog builds
  the wrapper in `compileParameterDeclaration` ALONE; an OVERRIDE replaces the
  actual through the elaboration path, which has no packed-dim detector, so
  the override's own dimension is dropped exactly as g9's is — golden's
  `work@dut.u.T` keeps the bare `logic_typespec (w_t)`.  A first cut that
  built the elab wrapper from the DECLARATION's syntax regardless of binding
  put a `packed_array_typespec` there instead.  No design in either corpus has
  that shape, so every corpus gate was green on that cut and only the wide
  grid caught it; the elab arm now fires only when the parameter's BOUND type
  syntax still IS the declaration default.

**g2 and g3's 68 → 335 cmp lines, decoded (added by the adversarial verifier,
`evidence/VERIFIER.r11v31.txt`).**  The count is not a distance: the head moved
PAST the whole wrapper — ranges, bounds, the named element ref all compare
equal — and landed on the element OBJECT, where `uhdm-cmp` prints
`LHS: <null> / RHS:` the whole design because `typespec::Compare` reads
`Instance()` through the SINGULAR `SafeCompare` and the value on our side is
the design.  Measured object identity: golden's design-level `e_t`
(`design::Typespecs[0]`) is `logic_typespec` id 9 with `vpiInstance = design`,
and the wrapper's element is a SEPARATE `logic_typespec` id 47 with
`Instance` NULL and no `Typedef_alias` — Surelog MINTS it at
`CompileHelper.cpp:3554` (`elemTs = compileTypespec(elemNameId …)`) whenever
the name is not an earlier type parameter.  Ours points the element ref at the
ONE shared object (`typedefTs`), which carries `vpiInstance`.  So the rule
"else the bare name's own object, i.e. the typedef's shared typespec" holds for
the TYPE-PARAMETER element (the corpus witnesses, `:3544`) and is REFUTED for
the TYPEDEF element: golden does not share there, it mints.  No corpus row
takes that branch (all four movers are the type-parameter form), the arm was
not-equal before and is not-equal after, and the order-blind whole-dump
distance still falls (140 → 130 on g2's shape) — it is recorded as residue R1a
below, not as a regression.

---

## 4. The change

`src/TypeEmit.cpp` — new `UhdmExporter::namedElemPackedDimTs31`, called from
`makeTypeParamDefaultTs` (def view) and from the type-parameter loop in
`src/ParamEmit.cpp` (elab view).  It returns null — leaving every existing
typespec exactly as it was — unless ALL of:

* the written default syntax is a `NamedType` whose name is an
  `IdentifierSelectName` (a keyword type and a `ScopedName` are both out: g1,
  g9),
* that name carries at least one `SimpleRangeSelect` selector,
* the compiled type is a `PackedArrayType`, and
* the element NAME resolves to an object we have already built — an earlier
  type parameter of this list (`typeParamDefaultTs` in the def view,
  `typeParamElabTs` in the elab view, mirroring Surelog's own two-step) or a
  typedef (`typedefTs`),

and, in the ELAB view only, the parameter's bound type syntax must still BE
the declaration default (`tps.targetType.getTypeSyntax() == wsyn31`) — an
OVERRIDE gets no wrapper at all, which is grid arm g12.

Bounds go through the pass-20 `typeParamDefaultBound20` rule unchanged, so
this pass adds NO new bound policy and pass 18/20's witnesses are untouched.

---

## 5. Gates (all green)

1. **Build.**  Pristine rebuilt at `4110f3de`: md5
   `62547ac98ebcfdeb522171dc946d50ad`, byte-identical to the main tree's
   binary at the base.  Patched builds clean at `-j 2`, 0 errors.  Both
   binaries frozen at immutable paths before any sweep, and every `cmds.txt`
   in every workdir audited by BINARY PATH (not the string `slang-uhdm`,
   which also matches the golden cache): uhdm2rtlil 1742/1742 pristine and
   1742/1742 patched, surelog 1531/1531 and 1531/1531, 8/8 in the focused
   four-test sweeps.
2. **Goldens.**  `tests/check_goldens.sh` with the patched binary: 23 PASS /
   0 FAIL.  Negative control `SLANG_UHDM=/bin/false`: 0 PASS / 23 FAIL.
3. **uhdm2rtlil, both modes.**  Patched 768 / 36 / 67 in each mode, the
   committed baseline exactly.  `ct8rows.sh` whole-row diff (dump column
   included) against `results/gate_uhdm2rtlil.csv`, against
   `results/golden_uhdm2rtlil.csv` (both modes), and against this pass's own
   pristine sweep: **PASS, every row byte-identical.  No row moved.**
4. **Surelog suite, both modes.**  Patched 469/14 default and 465/12
   testflags — the committed baseline exactly.  Against this pass's own
   pristine sweep exactly two rows differ, `LowMemLib/testflags` and
   `LowMemPkg/testflags`, both `SURELOG_FAIL` and differing ONLY in the
   workdir path inside Surelog's own log message in the detail column.
   Against the committed baseline those two plus `Earlgrey_0_1/testflags`
   reading `CMP_EQUAL/<empty dump column>` where the baseline reads
   `CMP_EQUAL/differ` — and THE PRISTINE SWEEP READS THE SAME, so it is this
   machine's `uhdm-dump` timeout on a very large database, not the patch; the
   status pin holds and the database is byte-identical to pristine.
5. **Byte verifier.**  `SELFCHECK=1 byteverify.sh` patched vs this pass's own
   pristine workdirs.  uhdm2rtlil: **4 movers / 1608**, all four predicted BY
   NAME (comparator negative control 1607/1608).  Surelog: **6 movers / 960**,
   all six the pinned UVM coin names — `MiniAmiq`, `Scoreboard`, `SeqDriver`,
   `SimpleUVM` — attributed ORDER-BLIND to `Scoreboard/default` 0 lines (a
   pure order flip) and 4 lines each for the rest, every one a `UINT:<N>` with
   its matching `vpiDecompile:<N>`: the line-number class, zero law lines
   (`evidence/COIN.r11u31.txt`).  The positive control is that the PRISTINE
   binary alone gives six different `MiniAmiq/default` databases in six runs
   with the same 4-line class; the COUNT is a per-run draw (an earlier build
   of this same patch drew 3 movers, this one 6), so the CLASS is the
   signature.
6. **Canaries.**  `SVSwitch` `4842211c4030` and `YosysVerx` `6ccda350c24a`
   hold in both modes; `InterfaceModPort` `59a365f3ce2c`,
   `BlackParrotComplex`, `YosysOldOr` and `Earlgrey_0_1`
   (`8bdf25272e08` / `59d0ee6d10c3`) are byte-identical patched vs pristine.
   `canaries.sh` u2r ok=8 changed=0; surelog ok=51 changed=1, the one being
   Earlgrey's empty dump column, which the pristine sweep reads identically.
   `ctcan2.sh` PASS on both corpora; `canaudit.sh` audited=29 UNCOVERED=0
   FENCE-BREACH=0 PASS.  Full log: `evidence/GATES.r11u31.txt`.

### The mover set, predicted BY NAME before the patched sweep

`evidence/PREDICT.r11u31.txt`.  `scan_typeparamdim.pl` reads the SOURCES of
both corpora (comments stripped, newline-tolerant, the twelve built-in type
keywords excluded because a written keyword is arm g1 and g1 is equal) and
finds five hits in the world:

* `type_param_packed_dim`, `type_param_override_elem_sel` — the two witnesses;
* `cva6_equiv` (two files) — NOT a discovered corpus row (no `dut.sv` /
  `project.f` at its top), so it is in no results CSV and can move nothing;
* `ClassScope` — `SLANG_REJECT` in both modes at the base (`dut.sv:64:5`),
  so it builds no database to move.

The scanner's positive control is that it finds the two designs whose heads
were measured by hand, so a zero elsewhere is a reading and not a blind spot.
**Predicted: 4 databases.  Measured: exactly those 4, and nothing else.**

### Every mover moves TOWARD golden

`togold.sh` / `togold_depthblind.sh` — a multiset census of normalised
`uhdm-dump` lines over (golden, pristine-ours, patched-ours):

| row | mode | cmp lines | TO-GOLDEN | REGRESSED | AWAY-GOLDEN |
|---|---|---|---|---|---|
| `type_param_packed_dim` | default | 94 → 47 | 73 | **0** | 12 |
| `type_param_packed_dim` | testflags | 94 → 47 | 73 | **0** | 12 |
| `type_param_override_elem_sel` | default | 94 → 47 | 75 | **0** | 10 |
| `type_param_override_elem_sel` | testflags | 94 → 47 | 75 | **0** | 10 |

(depth-blind figures; the order-blind whole-dump distance to golden falls
199 → 143 and 210 → 170, both modes.)  Two positive controls run beside it: a
row nothing touched reads 0/0/0, and swapping the two arms turns the same
numbers into `REGRESSED 73` / `REGRESSED 75`, so the census has a sign.

**The AWAY-GOLDEN residue, named line by line** (`awaylist.sh`,
`evidence/CENSUS.r11u31.txt`): every one of the 10-12 lines is one extra COPY
of an object golden also has — the `DEPTH-1` operation, its `ref_obj
(work@dut.rt_t.DEPTH)`, its two bound constants and the `range`.  Surelog
SHARES one `range` object across its three `packed_array_typespec`s (the def
one, the elab one, and the one parented at `packed_array_var rt_i`), so
`uhdm-dump` abbreviates the repeats; we build one per site, so each prints in
full.  No generated `Compare` reads `VpiParent` and none counts objects, so
the difference is invisible to the judge; it is the campaign's "clone, never
share" rule showing in the printer, not a new divergence.  No AWAY line names
an object or a field golden lacks.

---

## 6. Residues

**R0 — the chained type parameter's default must BORROW the named
parameter's object, not mint a fresh one.**  This is the new head of
`type_param_packed_dim` in both modes, quoted in
`evidence/HEAD.patched.type_param_packed_dim.default.cmp`: golden's element
actual is `logic_typespec 2:31..2:42` carrying `range [1:0]` — `id_t`'s OWN
object, because `parameter type resp_id_t = id_t` borrows it — while ours is
a fresh unranged `logic_typespec 3:32..3:36`, so the head is a null `Ranges`
vector on our side.  Surelog does this at
`CompileHelper.cpp:3589-3612`, the arm right below this pass's: "`parameter
type A = B` where B is ANOTHER type parameter of the same list … resolve the
chain directly against that list", and its `borrowed_tps` is pointed at
WITHOUT re-parenting (`:3621-3624`).  Our `makeTypeParamDefaultTs` reaches its
`dt.kind == TypeAlias` arm, finds nothing in `typedefTs` (a type parameter is
not a typedef), and falls through to minting.  This is also the standing
`port_chained_type_param` face that r11v29 ejected from K4 — the same
producer arm, so R0 closes both.

**R1 — an ELAB type parameter bound by an override written as a keyword type
with packed dims loses the dims.**  The new head of
`type_param_override_elem_sel`, both modes: golden's `work@dut.u.id_t` actual
is `logic_typespec 32:17..32:28` with `range 32:23..32:28` `[1:0]` from
`child #(.id_t(logic [1:0]))`; ours is the same object AT THE SAME SPAN with
a null `Ranges`.  The span is already right, so the gap is the range alone.

**R1a — a TYPEDEF element is MINTED by golden, not shared** (verifier finding,
§3 and `evidence/VERIFIER.r11v31.txt`).  `parameter type T = e_t [3:0]` with
`e_t` a typedef: golden's wrapper element is a fresh `logic_typespec` with
`Instance` NULL, ours is the design-level typedef object carrying
`vpiInstance` — and `typespec::Compare` READS `Instance`, so it is
judge-visible.  Surelog mints it at `CompileHelper.cpp:3554`.  The corpus is
blind to this (every corpus hit is the type-parameter element, `:3544`), so it
is grid-only evidence: arms g2, g3 and the verifier's v02/v06/v07/v09/v10/v11/
v14/v15/v19.  The same object choice is what the struct and enum element arms
show, so the fix is a MINT for the non-type-parameter element, not a special
case for `logic`.

**R1b — the law does not fire outside a module HEADER.**  Golden builds the
same wrapper for a `parameter type` with a written dim declared in a PACKAGE,
in a module BODY, and in a CLASS; we build none, because the def-view default
syntax is read only from `ModuleDeclarationSyntax::header->parameters`.
Measured, unchanged by this pass, verifier arms v08 (package, golden 8
`packed_array_typespec`, ours 0), v17 (module body, 10 vs 0), v16 (class, 5 vs
0).

**R2 — K4's other two rows are separate producers, each with its own head**
(§1): `anon_struct_packed_dim` (anonymous packed struct on a VARIABLE
declaration; golden `packed_array_typespec` with an unnamed elem ref to a
`struct_typespec`, ours a bare `logic_typespec` that has lost the struct
entirely) and `type_param_unpacked_port` (a PORT's unpacked dimension; golden
`array_typespec` with `vpiArrayType:1`).  Neither moved here and neither is
reachable from this law.

**R3 — `pk::e_t [3:0]` drops its dimension in golden (g9) and we already
match.**  Recorded so a later pass does not "fix" it: reproducing Surelog's
loss is the correct behaviour under these pins.

---

## 7. Files

* `gridrun.sh`, `g1.sv` … `g12.sv` — the golden grid (§3).
* `scan_typeparamdim.pl` — the mover predictor (§5).
* `togold.sh`, `togold_depthblind.sh`, `awaylist.sh` — the TO-GOLDEN /
  AWAY-GOLDEN census and its line-by-line listing.
* `fulldiff.sh` — order-blind whole-dump diff of one workdir row.
* `byteverify.sh`, `ct8rows.sh`, `rowheads.sh`, `canaries.sh`, `ctcan2.sh`,
  `canaudit.sh` — the standing gates, carried unmodified.
* `evidence/` — heads before and after, the grid, the prediction, the census,
  the coin attribution, the gate log.
