# r10svs6 — § fixedClassPropIsArrayVar6

**THE SVSwitch `class_defn (work@Environment)` HEAD IS CLEARED, BOTH MODES.**
`SVSwitch` did **NOT** convert: both rows stay
`SVSwitch,{default,testflags},CMP_NOTEQUAL,decompile:,,` byte-identical to
`results/golden_surelog.csv`, and **no `results/*.csv` was touched by this pass**.
What moved is the head: `cmp HEAD DEPTH` went from **8542 lines to 13**, and the
new head is a different object in a different file.

```
BEFORE (pristine 80892a3, both modes)        AFTER (patched, both modes)
LHS:                                         LHS:
decompile:                                   decompile:
class_defn: (work@Environment), id:6,        method_func_call: (new), id:2099
  ... 8542 lines ...                         |vpiParent:
                                             \_assignment: , id:2096, line:30:1, endln:30:24
cmp HEAD DEPTH=8542  heads=1                 |vpiName:new
                                             RHS: <null>
                                             cmp HEAD DEPTH=13  heads=1
```

The new head is `third_party/tests/SVSwitch/Coverage.sv:30`,
`switch_coverage = new();` inside `function new`: golden's `assignment` carries a
`vpiRhs -> method_func_call (new)` and ours carries no Rhs at all.  That is the
§ invalidNewCallFromSyntax55 family (pass 55: "slang refuses to bind `x = new()`
twice over and we were silently dropping the call"), NOT this law — it is the
next head, handed over decoded.

**THE MEASUREMENT THAT SAYS THE HEAD IS REALLY GONE**, and not merely reordered:
the whole `class_defn (work@Environment)` region of the two dumps is now
**194 lines on both sides differing in exactly ONE line**:

```
--- golden                                          +++ ours
-        \_class_typespec: (Receiver), line:20:3, endln:20:11
+        \_class_typespec: (Receiver)
```

That one line is residue **R3** below (a class-handle ELEMENT's `class_typespec`
carries no span and no parent on our side).  It does not gate `class_defn` —
`class_typespec::Compare` does not read the location — which is why the head
cleared past it.

---

## 1. THE LAW

### § fixedClassPropIsArrayVar6

**NAME AS IN THE CODE**, at five comment sites, all greppable:

| site | file | what it says |
| --- | --- | --- |
| the ARM | `src/UhdmExporter.cpp`, `emitClassDefn` (grep `§ fixedClassPropIsArrayVar6 — a FIXED-SIZE`) | the whole law + the three gate clauses + why not `emitArrayVar` |
| the ELEMENT/KIND line | same file (grep `the element is the INNERMOST one`) | `vpiArrayType:1` and the innermost element |
| the SIZE line | same file (grep `vpiSize is the ELEMENT COUNT`) | 4 / 8 / 1 with the arm cells |
| the RANGE line | same file (grep `one .vpiRange. per WRITTEN dimension`) | why `buildUnpackedRanges` is reused |
| the ELEMENT FACTORY | same file (grep `§ fixedClassPropIsArrayVar6, THE ELEMENT FACTORY`) | vif / chandle / shortreal / real |
| the INITIALIZER half | same file (grep `§ fixedClassPropIsArrayVar6, THE INITIALIZER HALF`) | array pattern parented at the ELEMENT var |

plus two shared helpers named in the same scheme: `§ fixedUnpackedCount6`
(`src/TypeEmit.cpp`) and the FOURTH call site of `§ arrayVarSignedWritten8`
(`src/UhdmExporter.cpp`, the ADD half, whose comment r10svs6 extended).

**THE LAW, exactly.** A CLASS PROPERTY whose canonical type is a
`FixedSizeUnpackedArrayType` is an `array_var` parented at the `class_defn` and
listed in `vpiVariables`, carrying

* `vpiName` / `vpiFullName` (`<class fullname>::<prop>`) and the NAME-TOKEN span,
* `vpiSize` = the ELEMENT COUNT (§ fixedUnpackedCount6: product of the dim
  widths, a PARAM-sized dim contributing 1),
* `vpiArrayType:1`,
* `vpiRandType` 1 / 2 / 3 for unqualified / `rand` / `randc`, with
  `vpiIsRandomized:1` on the latter two,
* `vpiVisibility` 1 / 2 / 3 for public / `protected` / `local`,
* `vpiAutomatic:1` unless the property is `static`,
* `vpiConstantVariable:1` when the property is `const`,
* `vpiSigned:1` iff § arrayVarSignedWritten8 holds **as written**,
* one `vpiRange` per WRITTEN dimension, spanned at the whole `[l:r]` for a range
  dim and at the SIZE TOKEN alone for a `[N]` dim,
* `vpiTypespec` -> `ref_typespec` -> a BARE `array_typespec`,
* `vpiReg` -> the ELEMENT variable: its own var class, the property's fullname,
  the NAME-TOKEN span, NO `vpiName`, NO `vpiSigned`, and the element typespec —
  except for a VIRTUAL INTERFACE / `chandle` / `shortreal` element, which carry
  NO `vpiTypespec` at all,
* and an ARRAY-PATTERN initializer as a `vpiExpr` operation PARENTED AT THE
  ELEMENT VAR and referenced by both the `array_var` and the element.

**GATE — three clauses, each measured (STATED GATE == CODE GATE):**

| clause | in code | why it is necessary (the cell that proves it) |
| --- | --- | --- |
| (1) canonical kind is `FixedSizeUnpackedArrayType` | `ct.kind == SymbolKind::FixedSizeUnpackedArrayType` | the arm it joins already owns dynamic/queue/assoc |
| (2) the property's OWN type is not a typedef NAME | `cp.getType().kind != SymbolKind::TypeAlias` | `typedef byte barr_t[4]; barr_t x;` is a DIFFERENT golden object: no `vpiSize`, no `vpiArrayType`, no `vpiRandType`, no range, no `vpiReg`, and a NAMED `array_typespec (barr_t)` (cell `c25_wholetd`; the module twin `m25_wholetd` over-fires on all five TODAY and is r10oth8's own open residue) |
| (3) the INNERMOST element is not dynamic/queue/assoc | the `switch` over `in6->getCanonicalType().kind` | `int x[4][]` is golden `vpiArrayType:2` with NO range and NO element var — the UNSIZED dim's kind wins wherever it sits (cells `c06_fixdyn`, `c08_fixq`, `c09_fixassoc`, and `c07_dynfix` / `c10_qfix` from the other side) |

**STATED GATE == CODE GATE, and NO CLAUSE READS SOURCE TEXT.**  All three clauses
are AST-kind tests (`ct.kind`, `cp.getType().kind`, and the kind of the innermost
element after descending the fixed dims); nothing in this law greps, spells or
matches source characters, so the escaped-identifier / macro-spelling hazard that
bit r10svs5's SITE 2 cannot reach it.  The two clauses that DECLINE are executed
and still decline on the patched binary — the arm logs report exactly
`1 class property type: FixedSizeUnpackedArrayType` for `b2` (that is
`c25_wholetd`, clause 2) and `1 class property type: FixedSizeUnpackedArrayType` +
`1 class array property element` for `b3` (the hybrids, clause 3), and **zero**
such notes for `b1`, `b4` and `b5`.

**WITNESSES**, both read IN FULL from the pristine dumps before a line was
written (`/tmp/svs6/svs_pris/default.cmp.txt`, lines 23-75 and 76-152):

```
Environemnt.sv:17  virtual output_interface.OP output_intf[4] ;
  array_var (work@Environment::output_intf) @17:31-17:42
    vpiSize:4  vpiArrayType:1  vpiRandType:1  vpiVisibility:1  vpiAutomatic:1
    vpiTypespec -> ref_typespec (fullname work@Environment::output_intf)
                     -> array_typespec (BARE: no name, no span, no element ts)
    vpiRange -> range @17:43-17:44 { left = UINT:0 (unlocated, size 64, ct 9),
                right = operation opType 11 @17:43-17:44 (UINT:4 @17:43-17:44, INT:1) }
    vpiReg -> logic_var (work@Environment::output_intf) @17:31-17:42
                { vpiParent -> the array_var, vpiFullName only — NO vpiName,
                  NO vpiTypespec }
Environemnt.sv:20  Receiver rcvr[4];
  ...identical shape, and vpiReg -> class_var -> ref_typespec ->
     class_typespec (Receiver) @20:3-20:11
```

**DECODED, NOT TRANSCRIBED — the brief's `vpiRandType:1` question.** Both
witnesses carry `vpiRandType:1` and NEITHER is written `rand`.  Arm b4 answers
it: `1` is `vpiNotRand`, the DEFAULT stamp on every array_var, and a written
`rand` moves it to **2** (`c01_rand`) and `randc` to **3** (`c02_randc`), each
adding `vpiIsRandomized:1`.  So the witnesses' `1` is the absence of `rand`, not
evidence of it, and the code keeps the existing `else av->VpiRandType(1)`.

---

## 2. WHY NOT ROUTE THE CLASS ARM THROUGH `emitArrayVar` — REFUTED BY MEASUREMENT

The brief asked whether the class-property emission can route through the
existing module-scope `emitArrayVar`.  **It cannot, and the reason is 10 measured
cells, not taste.**  `emitArrayVar`'s element decode is `int_var` for every
predefined integer and `logic_var` for everything non-integral, which is WRONG
against golden for ten MODULE cells that are wrong TODAY and would have been
imported wholesale into the class arm:

| module cell | golden element | ours (pristine AND patched — unchanged) |
| --- | --- | --- |
| `m03_byte`, `m04_byteu` | `byte_var` | `int_var` |
| `m05_shint` | `short_int_var` | `int_var` |
| `m06_lgint` | `long_int_var` | `int_var` |
| `m15_real` | `real_var` | `logic_var` |
| `m16_sreal` | `short_real_var` (+ NO typespec) | `logic_var` (+ a `short_real_typespec`) |
| `m17_string` | `string_var` | `logic_var` |
| `m21_ustruct` | `struct_var` | `logic_var` |
| `m22_hand`, `m02_hndarr` | `class_var` | `logic_var` |
| `m24_btd` | `byte_var` + `byte_typespec (b_t)` | `int_var` + a fresh `byte_typespec` |

The CLASS element factory (`classElemVar` / `classAssocElemVar`, extended here by
`classFixedElemVar6`) is right for every one of them.  So the parts REUSED from
the module arm are exactly the two that ARE right at both scopes —
`§ fixedUnpackedCount6` and `buildUnpackedRanges` — and nothing else.  This is
r10oth9's residue **R5** widened from 2 cells to 10 and left where it is.

**The extraction is behaviour-neutral, and that is measured, not asserted:** all
**38** module-twin cells across the five arms produce BYTE-IDENTICAL extractor
output on the pristine and the patched binary (17 EQ, 18 DIFFER, 3 UNMEASURED,
every field string equal).

---

## 3. THE GRID, CELL FOR CELL

105 cells over five arms (67 class + 38 module).  `G:` columns are GOLDEN's
reading; the last two columns are our verdict before and after.

| `c01_vifarr` | b1_witness | 4 | 1 | 1 | 1 | 1 | - | 1 | logic_var | -NOTS- | UNMEASURED | **EQ** |
| `c02_hndarr` | b1_witness | 4 | 1 | 1 | 1 | 1 | - | 1 | class_var | class_typespec(Recv) | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |
| `c03_vifsc` | b1_witness | - | - | - | 1 | 1 | - | 0 | - | - | EQ | **EQ** |
| `c04_hndsc` | b1_witness | - | - | - | 1 | 1 | - | 0 | - | - | EQ | **EQ** |
| `c05_intarr` | b1_witness | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c01_int` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c02_intu` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c03_byte` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | byte_var | byte_typespec | UNMEASURED | **EQ** |
| `c04_byteu` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | byte_var | byte_typespec | UNMEASURED | **EQ** |
| `c05_shint` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | short_int_var | short_int_typespec | UNMEASURED | **EQ** |
| `c06_lgint` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | long_int_var | long_int_typespec | UNMEASURED | **EQ** |
| `c07_integer` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | integer_var | integer_typespec | UNMEASURED | **EQ** |
| `c08_time` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | time_var | time_typespec | UNMEASURED | **EQ** |
| `c09_bit` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | bit_var | bit_typespec | UNMEASURED | **EQ** |
| `c10_logic` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | logic_var | logic_typespec | UNMEASURED | **EQ** |
| `c11_reg` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | logic_var | logic_typespec | UNMEASURED | **EQ** |
| `c12_bitv` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | bit_var | bit_typespec | UNMEASURED | **EQ** |
| `c13_bitsv` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | bit_var | bit_typespec | UNMEASURED | **DIFFER[elemtssigned]** |
| `c14_logsv` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | logic_var | logic_typespec | UNMEASURED | **DIFFER[elemtssigned]** |
| `c15_real` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | real_var | real_typespec | UNMEASURED | **EQ** |
| `c16_sreal` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | short_real_var | -NOTS- | UNMEASURED | **EQ** |
| `c17_string` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | string_var | string_typespec | UNMEASURED | **EQ** |
| `c18_enum` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | enum_var | enum_typespec(e_t) | UNMEASURED | **DIFFER[elemtsspan]** |
| `c19_senum` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | enum_var | enum_typespec(se_t) | UNMEASURED | **DIFFER[elemtsspan]** |
| `c20_pstruct` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | struct_var | struct_typespec(ps_t) | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |
| `c21_ustruct` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | struct_var | struct_typespec(us_t) | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |
| `c22_hand` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | class_var | class_typespec(Hand) | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |
| `c23_chandle` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | chandle_var | -NOTS- | UNMEASURED | **EQ** |
| `c24_btd` | b2_elemkind | 4 | 1 | 1 | 1 | 1 | - | 1 | byte_var | byte_typespec(b_t) | UNMEASURED | **DIFFER[elemtsact+elemtsspan]** |
| `c25_wholetd` | b2_elemkind | - | - | - | 1 | 1 | - | 0 | - | - | UNMEASURED | **UNMEASURED** |
| `c01_size` | b3_arraykind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c02_rng03` | b3_arraykind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c03_rng30` | b3_arraykind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c04_rng14` | b3_arraykind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c05_2d` | b3_arraykind | 8 | 1 | 1 | 1 | 1 | 1 | 2 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c06_fixdyn` | b3_arraykind | 4 | 2 | 1 | 1 | 1 | 1 | 0 | - | - | UNMEASURED | **UNMEASURED** |
| `c07_dynfix` | b3_arraykind | 4 | 2 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **UNMEASURED** |
| `c08_fixq` | b3_arraykind | 4 | 4 | 1 | 1 | 1 | 1 | 0 | - | - | UNMEASURED | **UNMEASURED** |
| `c09_fixassoc` | b3_arraykind | 4 | 3 | 1 | 1 | 1 | 1 | 0 | int_var | int_typespec | UNMEASURED | **UNMEASURED** |
| `c10_qfix` | b3_arraykind | 4 | 4 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **UNMEASURED** |
| `c11_paramsz` | b3_arraykind | 1 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c12_lit` | b3_arraykind | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c01_rand` | b4_qual | 4 | 1 | 2 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c02_randc` | b4_qual | 4 | 1 | 3 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c03_static` | b4_qual | 4 | 1 | 1 | 1 | - | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c04_local` | b4_qual | 4 | 1 | 1 | 3 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c05_prot` | b4_qual | 4 | 1 | 1 | 2 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c06_const` | b4_qual | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c07_statloc` | b4_qual | 4 | 1 | 1 | 3 | - | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c08_randloc` | b4_qual | 4 | 1 | 2 | 3 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c09_locstat` | b4_qual | 4 | 1 | 1 | 3 | - | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c10_protrand` | b4_qual | 4 | 1 | 2 | 2 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c11_initpat` | b4_qual | 4 | 1 | 1 | 1 | 1 | 1 | 1 | int_var | int_typespec | UNMEASURED | **EQ** |
| `c12_randhand` | b4_qual | 4 | 1 | 2 | 1 | 1 | - | 1 | class_var | class_typespec(Hand4) | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |
| `c13_randtp` | b4_qual | 4 | 1 | 2 | 1 | 1 | - | 1 | int_var | int_typespec | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |
| `c14_loctp` | b4_qual | 4 | 1 | 1 | 3 | 1 | - | 1 | int_var | int_typespec | UNMEASURED | **DIFFER[elemtsspan]** |
| `c15_constq` | b4_qual | 1 | 4 | 1 | 1 | 1 | 1 | 0 | int_var | int_typespec | EQ | **EQ** |
| `c16_constdyn` | b4_qual | 1 | 2 | 1 | 1 | 1 | 1 | 0 | int_var | int_typespec | EQ | **EQ** |
| `c01_vifmp` | b5_vif | 4 | 1 | 1 | 1 | 1 | - | 1 | logic_var | -NOTS- | UNMEASURED | **EQ** |
| `c02_vifbare` | b5_vif | 4 | 1 | 1 | 1 | 1 | - | 1 | logic_var | -NOTS- | UNMEASURED | **EQ** |
| `c03_vifkw` | b5_vif | 4 | 1 | 1 | 1 | 1 | - | 1 | logic_var | -NOTS- | UNMEASURED | **EQ** |
| `c04_vifkwmp` | b5_vif | 4 | 1 | 1 | 1 | 1 | - | 1 | logic_var | -NOTS- | UNMEASURED | **EQ** |
| `c05_viftd` | b5_vif | 4 | 1 | 1 | 1 | 1 | - | 1 | logic_var | -NOTS- | UNMEASURED | **EQ** |
| `c06_vif2d` | b5_vif | 8 | 1 | 1 | 1 | 1 | - | 2 | logic_var | -NOTS- | UNMEASURED | **EQ** |
| `c07_hnd` | b5_vif | 4 | 1 | 1 | 1 | 1 | - | 1 | class_var | class_typespec(H5) | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |
| `c08_hnd2d` | b5_vif | 8 | 1 | 1 | 1 | 1 | - | 2 | class_var | class_typespec(H5) | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |
| `c09_tphnd` | b5_vif | 4 | 1 | 1 | 1 | 1 | - | 1 | class_var | class_typespec(H5) | UNMEASURED | **DIFFER[elemtsspan+elemtsparent]** |

### 3.1 totals

| arm | cells | EQ | DIFFER | UNMEASURED |
| --- | --- | --- | --- | --- |
| `b1_witness` | 8 | 6 | 2 | 0 |
| `b2_elemkind` | 50 | 22 | 24 | 4 |
| `b3_arraykind` | 20 | 14 | 1 | 5 |
| `b4_qual` | 18 | 15 | 3 | 0 |
| `b5_vif` | 9 | 6 | 3 | 0 |
| **total** | **105** | **63** | **33** | **9** |

The pristine binary on the SAME 105 cells reads **EQ=21 DIFFER=18
UNMEASURED=66**.  The transition, per cell:

| transition | class cells | module cells |
| --- | --- | --- |
| UNMEASURED -> EQ | **42** | 0 |
| UNMEASURED -> DIFFER | 15 | 0 |
| UNMEASURED -> UNMEASURED | 6 | 3 |
| EQ -> EQ | 4 | 17 |
| DIFFER -> DIFFER | 0 | 18 |

**Nothing regressed: there is no EQ -> DIFFER and no EQ -> UNMEASURED cell in the
table**, and every one of the 15 UNMEASURED -> DIFFER cells is a cell where we
now emit the object and one FIELD of its element typespec still disagrees — a
strictly smaller reading than "we emit nothing".

### 3.2 the element-kind grid, read as a law

* **§ arrayVarSignedWritten8 fires AS WRITTEN at this scope, unchanged.**
  `vpiSigned:1` on `c01_int`, `c03_byte`, `c05_shint`, `c06_lgint`,
  `c07_integer`, `c13_bitsv`, `c14_logsv`; ABSENT on every unsigned atom,
  `time`, bare `bit`/`logic`/`reg`, unsigned vector, `real`, `shortreal`,
  `string`, the enum AND the SIGNED-enum typedef `c19_senum`, packed and unpacked
  struct, class handle, `chandle`, and the typedef'd element `c24_btd`.  Clause
  (a) (typedef) and clause (b) (kind list) are both live here.  The brief's
  prediction that the § 8 gates "apply AS WRITTEN" is CONFIRMED, and the
  predicate needed no change to serve its fourth call site.
* **§ arrayElemTsSignedParented9 EXTENDS to fixed arrays** — golden's element
  typespec for an integer atom carries `vpiSigned` (RESOLVED signedness: `1` for
  `int`/`byte`/…, absent for `int unsigned`) AND `vpiParent` -> its own element
  var, and the existing `predefIntTypespec` arm in the shared code produces
  exactly that (cells `c01_int`…`c08_time` all EQ, `c24_btd` keeps golden's
  `elemtssigned=1` through the typedef).  Its DELIBERATELY-UNSHIPPED half is
  still unshipped and still visible: `c13_bitsv` / `c14_logsv` read golden `1`
  against our absent (residue R4 — r10oth9's R1).
* **The virtual-interface element is § virtualIfacePropIsBareLogicVar6 one level
  down**: a bare `logic_var` with NO typespec, and ALL FIVE written spellings
  plus the 2-D case are ONE cell (`c01_vifmp`, `c02_vifbare`, `c03_vifkw`,
  `c04_vifkwmp`, `c05_viftd`, `c06_vif2d` — all EQ).
* **`chandle` -> `chandle_var` and `shortreal` -> `short_real_var`, both with NO
  typespec; `real` -> `real_var` WITH a `real_typespec`** at the type keyword
  (`c23_chandle`, `c16_sreal`, `c15_real`, all EQ).
* **The class-handle element** is a `class_var` -> `class_typespec (<Class>)`,
  and for a TYPE-PARAMETER element the parameter RESOLVES (`c09_tphnd`,
  `c13_randtp`: golden's element is the concrete `class_var` / `int_var`),
  which is § typeParamRetIsRefVar58's class-property rule holding for fixed
  arrays too.
* **Qualifiers**: `static` removes `vpiAutomatic` (and only that);
  `local` -> `vpiVisibility:3`, `protected` -> `2`; the combinations compose
  (`c07_statloc`, `c08_randloc`, `c09_locstat`, `c10_protrand` all EQ).

---

## 4. REFUTATIONS

**R-1. The brief's "golden stamps vpiRandType:1 on both witnesses and neither is
written `rand` — decode that" is decoded: there is nothing to decode in the
object.**  `1` is `vpiNotRand`, the default; see §1.  A pass that had
transcribed "witness has vpiRandType:1" into a constant would have broken
`c01_rand`/`c02_randc`.

**R-2. The census OVER-PREDICTED the blast radius by two orders of magnitude,
and the correction is recorded rather than hidden.**  `census6.py` finds **198**
fixed-dim and **962** ambiguous-dim class-property-looking declarations across
`Surelog/tests`, `Surelog/third_party/tests`, **`Surelog/third_party/UVM`** and
`uhdm2rtlil/test`, with 77 + 785 of them attributed to the UVM library that the
four UVM tests compile.  The measured mover set is **SVSwitch only**.  Two
reasons, both verified:
* nearly every census hit is in a test whose row is `SLANG_REJECT` (Opentitan,
  Tnoc, Ibex, IbexGoogle, Google, UVMSwitch, SimpleClass, SplitFile, UnitClass,
  AmiqEth, OVMSwitch, ForeachClass, ThisHier … all of them), or in a directory
  with no row at all (`rggen`, `ariane`, `wav-lpddr-hw`);
* the UVM bucket is a TEXT-SCAN ARTEFACT: the file the tests actually compile
  (`third_party/UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv`) contains **ZERO**
  fixed-size unpacked-array class properties.  Running the pristine binary on it
  by hand reports exactly one unsupported construct, `expression kind:
  UnboundedLiteral`, and **no** `class property type: FixedSizeUnpackedArray…`
  note at all.  The census's UVM hits are lines like `return m_policy_stack[0];`
  that the declaration regex matches.
  **The honest instrument for "is the law's site reached" is the emitter's own
  unsupported note, not a source grep** — that is the lesson to carry.

**R-3. The Scoreboard byte mover is NOT this law, and it is proved, not
argued.**  The verifier reported 3 movers: `SVSwitch/default`,
`SVSwitch/testflags` and `Scoreboard/default`.  Scoreboard is the test r10oth9's
F2 recorded as nondeterministic on EVERY binary.  Re-running it three times on
each binary through the harness:

```
PRISTINE reps: 2a00057d2d6c…  2a00057d2d6c…  2a00057d2d6c…
PATCHED  reps: 98c00c393991…  2a00057d2d6c…  2a00057d2d6c…
sweep         : patched=2a00057d2d6c…   pristine=98c00c393991…
```

BOTH binaries produce BOTH md5s, and the sweep simply caught opposite variants.
**Attributable movers: 2** (SVSwitch, both modes).  The row is `CMP_NOTEQUAL`
before and after either way.

**R-4. A correction to this pass's own in-flight code.**  `classFixedElemVar6`
was first written with a `bool& noTypespec6` out-parameter to tell the caller to
skip the typespec.  It was redundant AND a second way to say the same thing: the
three no-typespec kinds are returned with no `ref_typespec` attached, and the
caller's shared line is already `if (auto* rrt = reg->Typespec(); rrt && …)`.
The parameter was removed before the first build and the reason is written at the
function.

**R-5. `vpiConstantVariable` on an ARRAY property was NOT assumed from the scalar
arm — it was measured on BOTH halves of the shared arm.**  The stamp sits in code
that now serves fixed AND dynamic/queue/assoc properties, so `const` cells were
added for a QUEUE and a DYNAMIC array (`c15_constq`, `c16_constdyn`) and golden
stamps `vpiConstantVariable:1` on both.  Those two cells were EQ before this pass
and are EQ after it.

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

```
/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs6
[100%] Linking CXX executable slang-uhdm        <- the link line, waited for
[100%] Built target slang_uhdm
md5(build/slang-uhdm) = 32d3d947ba25f42e18069d741b35aebe     (32 hex, asserted separately)
find src include -newer build/slang-uhdm  ->  empty

PRISTINE worktree r10svs6pris, clean at 80892a3 (git rev-parse HEAD =
80892a311f7a82cf60c722571604bd7f93112b69, git status --porcelain empty):
md5 = 7067d4c913176c204f89fc7106cea65d
```

### GATE 2 — GOLDENS

```
SLANG_UHDM=<patched> tests/check_goldens.sh  ->  23 PASS / 0 FAIL
SLANG_UHDM=/bin/false tests/check_goldens.sh ->   0 PASS / 23 FAIL   (control fires)
```

### GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
ct6rows.sh vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep, judged the same way: 0 differing ROWS
```

### GATE 4 — surelog `--mode both --jobs 2` (`GOLDEN_DEFER` left UNSET)

```
default  : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
testflags: 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
           + 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM
dump: default 225 match / 242 differ / 327 blank
      testflags 165 match / 298 differ / 331 blank
ct6rows.sh vs results/golden_surelog.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep: 0 differing ROWS
```

**SVSwitch did NOT convert** — both rows stay `CMP_NOTEQUAL`, byte-identical to
the committed baseline, so the "SVSwitch converts" branch of the brief's gate 4
does not apply and no `results/*.csv` was edited.

### GATE 5 — BYTE VERIFIER, both corpora, vs a PRISTINE 80892a3 built here

`byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 3 / 953
          SELFCHECK 952/953 flagged        SELFCHECK1 = 4  (3 movers + 1 corruption)
          -> SVSwitch/default, SVSwitch/testflags, and Scoreboard/default;
             Scoreboard is the KNOWN FLAKE and is refuted in R-3 above.
             ATTRIBUTABLE MOVERS: 2.
```

**PER-SHAPE MOVER ATTRIBUTION, by MULTISET, vs GOLDEN** (`msmovers.sh`,
`msdist.sh` @7c7eaa6 — the whitespace-fixed one, md5
`7c0d46b5da124cfe37d27eddc95eb7e7`), on `SVSwitch/default`
(`testflags` is byte-identical to it on both binaries):

```
MULTISET DISTANCE to golden : pristine 1485  ->  patched 1402      (-83, TOWARD golden)
  golden-only line instances: 618 -> 517      ours-only: 867 -> 885
ADDED (absent in pristine): 32     REMOVED (absent in patched): 0   [reported SEPARATELY]
shapes whose count moved   : 67    CONVERGED=56  DIVERGED=9  LATERAL=2
```

The 32 ADDED shapes are the new objects, and they are the law:
`\_array_var: (work@Environment::output_intf)` and `…::rcvr` (G=3 P=0 A=3 each),
`|vpiSize:4`, `|vpiArrayType:1`, `|vpiRandType:1`, the two `vpiFullName` lines,
`\_range: , line:17:43…` and `line:20:17…` — every one of them CONVERGED
(golden has exactly the count we now have).  The 9 DIVERGED shapes are
DUMP-OCCURRENCE recounts of lines the new objects re-print under more parents
(`|vpiParent:`, `|vpiTypespec:`, `|vpiVariables:`, `|vpiVisibility:1`,
`|vpiName:output_intf`) plus the ONE real residue,
`\_class_typespec: (Receiver)` in its SPANLESS spelling (G=0 P=0 A=1, twice —
residue R3).  **The brief's prediction that adding objects shifts serializer ids
and moves shapes wherever the shape lives is confirmed, and the ids are not part
of any cmp verdict.**

### 5.6 CANARIES

```
u2r      canaries.sh  ok=9   changed=0 absent=0   (28 unknown-names = surelog-only canaries)
         ctcan2.sh    ok=1   changed=0 absent=0   unknown-patterns=6 = EXPECT_UNKNOWN=6
surelog  canaries.sh  ok=58  changed=0 absent=0   (8 unknown-names = u2r-only canaries)
         ctcan2.sh    ok=58  changed=0 absent=0   unknown-patterns=1 = EXPECT_UNKNOWN=1
canaudit.sh canaries.sh ctcan2.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0
```

(`ok=9`/`ok=58` are the numbers this script's own header records as RE-MEASURED
for its pass-53 name list; the brief's `ok=8`/`ok=52` are r10svs5's older list.)

**BY NAME, as the brief requires:**

```
InterfaceModPort    default   CMP_EQUAL / differ   == committed baseline   OK
InterfaceModPort    testflags CMP_EQUAL / differ   == committed baseline   OK
BlackParrotComplex  default   CMP_EQUAL / differ   == committed baseline   OK
BlackParrotComplex  testflags CMP_EQUAL / differ   == committed baseline   OK
```

The four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) were never dispatched; `canaudit.sh` reports `FENCE-BREACH=0`.

---

## 6. RANKED RESIDUES

**R1 — the WHOLE-ARRAY TYPEDEF property emits nothing at all (1 cell,
deliberately).**  `typedef byte barr_t[4]; barr_t x;` (`c25_wholetd`) is gated
OUT by clause (2) and still reads `-NOOBJ-` on our side.  Golden's object is
five fields smaller than the one this arm builds and carries a NAMED
`array_typespec (barr_t)`; the module twin `m25_wholetd` builds the WRONG one
today (`size+atype+rand+tsact+elem+…`, 12 differing keys), which is r10oth8's own
open residue.  Ranked first because it is the only shape this pass could have
converted and chose not to: shipping the full builder there was a MEASURED
over-fire.

**R2 — the FIXED/UNSIZED HYBRIDS emit nothing (5 cells).**  `c06_fixdyn`,
`c07_dynfix`, `c08_fixq`, `c09_fixassoc`, `c10_qfix`.  Golden's `vpiArrayType` is
the UNSIZED dim's kind (2/2/4/3/4) with `vpiSize` = the fixed dims' product, a
range only when a FIXED dim survives, and an element var only for the
dyn/assoc/queue forms.  We drop them today for a reason that is now visible in
the code: the dyn arm's `classAssocElemVar` gets a FIXED-ARRAY element type and
returns null.  A one-arm pass could take these five cells next.

**R3 — a class-handle ELEMENT's `class_typespec` has NO span and NO parent
(7 cells, and THE ONE LINE left in the SVSwitch witness region).**  `c02_hndarr`,
`c22_hand`, `c07_hnd`, `c08_hnd2d`, `c09_tphnd`, `c12_randhand` and the unpacked/
packed struct pair `c20_pstruct`/`c21_ustruct` read
`elemtsspan=- elemtsparent=-` against golden's type-name span and element-var
parent.  The producer is `classElemVar`'s ClassType arm (+ `pendingClassTsLink`)
and `sharedAliasTs`, which serve the DYNAMIC arm too, so fixing it needs the
dynamic-array arm table this pass did not build.  It does NOT gate `class_defn`
(measured: the head cleared past it).

**R4 — a SIGNED `bit`/`logic` element typespec has no `vpiSigned` (2 cells).**
`c13_bitsv`, `c14_logsv` — r10oth9's residue R1 verbatim, at a different scope.
Its producer is `makeTypespec`'s scalar/packed arm, shared with module scope;
r10oth9 deliberately did not ship it and neither does this pass.

**R5 — the SHARED-typedef element typespec is the LAST-LISTER's, and its span is
golden's merged one (4 cells).**  `c18_enum`, `c19_senum`, `c14_loctp` and
(with R3) `c20_pstruct`/`c21_ustruct`: golden's `enum_typespec (e_t)` spans
`8:1-65:18` — the typedef's line to the LAST declaration that listed it — where
ours spans the typedef alone.  This is r10oth9's R2 (`vpiParent` is the
last-lister) seen through the span; a per-declaration object cannot reproduce it.

**R6 — the typedef'd ELEMENT gets a fresh typespec instead of the typedef's
named one (1 cell).**  `c24_btd`: golden `byte_typespec (b_t) @12:9-12:13`, ours
a bare `byte_typespec @43:3-43:6`.  Same family as R5.

**R7 — the NEXT SVSwitch HEAD, already decoded (1 test, not this cluster).**
`Coverage.sv:30 switch_coverage = new();` — golden's `assignment` carries
`vpiRhs -> method_func_call (new)`, ours carries none.  § invalidNewCallFromSyntax55's
family.  Quoted in full at the top of this file so the next pass starts from the
measured head.

---

## 7. WHAT IS IN THIS DIRECTORY

| file | what it is |
| --- | --- |
| `b1_witness.sv` | THE TWO SVSwitch WITNESSES standalone + their already-converged scalar controls + module twins |
| `b2_elemkind.sv` | 25 element kinds x class + module twin — atoms signed/unsigned, `time`, scalars, vectors, `real`/`shortreal`, `string`, enum, SIGNED-enum typedef, packed/unpacked struct, class handle, `chandle`, typedef'd element, whole-array typedef |
| `b3_arraykind.sv` | the DIMENSION grid: `[N]`, `[0:3]`, `[3:0]`, `[1:4]`, 2-D, param-sized, and the five FIXED/UNSIZED hybrids |
| `b4_qual.sv` | `rand`/`randc`/`static`/`local`/`protected`/`const` and their combinations, the init-pattern cells, a parameterized class, and the const QUEUE/DYNAMIC controls |
| `b5_vif.sv` | the virtual-interface element in all five spellings + 2-D, and the class-handle / type-parameter-handle elements |
| `ct6arm.sh` | one arm through both tools (carried from r10oth9repro/ct9arm.sh) |
| `ct6cells.py` | THE CELL EXTRACTOR — the WHOLE array_var object, its ranges, its typespec chain and its element, at own child depth, richest occurrence |
| `ct6all.sh` | every arm + the four-way totals |
| `ct6rows.sh` | the WHOLE-ROW csv gate (carried from r10oth8repro/ct8rows.sh) |
| `census6.py` | the source census, incl. `third_party/UVM` — and the instrument whose OVER-prediction is refuted in R-2 |
| `svsgen.sh` | regenerate the SVSwitch pair for BOTH modes through the harness itself |
| `msdist.sh`, `msmovers.sh`, `mvdump.sh` | multiset dump distance / per-shape mover attribution / three-way dump capture |
| `byteverify.sh` | the byte verifier with both negative controls |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary drivers and the audit that proves every protected name is carried |

Every number in this document is produced by one of those scripts or by a command
quoted beside it.  Nothing here is a recollection.
