# r11u77 — the imported-package holder hoist: the listing is the package's
# SIGNAL vector, and the holder's KIND is golden's, not the declaration's

Base commit `7d0c7bf4`. Pristine binary md5
`963667a2299a360105d9677e3a065959` — built in this pass's own worktree,
`-j 2`, md5 taken separately, and **byte-identical to the main tree's
`build/slang-uhdm` at `7d0c7bf4` and to the OPS pin**, compared not assumed.
Patched binary md5 `c676e58722bcd4bba191cfec84ab6799`. Both frozen
`chmod 555` at immutable paths before any sweep; every `cmds.txt` audited by
binary PATH.

Three laws, three switches, each droppable alone. `results/*.csv` untouched —
read only, never written. **No row converts and no row regresses in either
corpus; the conversion is a grid arm, `y6_hoistconv`.**

---

## 1. THE TWO WITNESSES, RE-MEASURED AT THE BASE (question 1)

Both arms compile on both sides (`golden_rc=0 ours_rc=0`); the goldens are
regenerated per arm by the pinned Surelog v1.87.

```
g2_importshapes  golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=89
xe_impkind       golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=236
```

**`g2_importshapes` `w_net`** (r11u75's residue 1), through the resolving
lister, verbatim:

```
    section          lhs_fullname              GOLDEN actual                                      OURS actual
!!  uhdmtopModules   work@dut.gw[0].w_net      logic_net (work@dut.w_net), line:11:16, endln:11:21   -
```

**`xe_impkind`** (r11v75's residue 2), verbatim — two cells, one MISSING and
one WRONG-KIND:

```
!!  uhdmtopModules   work@dut.gk[0].a_ns   array_var (work@dut.a_ns), line:8:21, endln:8:25    -
!!  uhdmtopModules   work@dut.gk[0].t_ns   struct_net (work@dut.t_ns), line:10:21, endln:10:25  logic_var (work@dut.t_ns), line:10:21, endln:10:25
```

And the LISTING behind those cells, through this pass's shape lister
(`lister77.py`, one row per top-level signal slot) — the holder itself, not
the reference to it:

```
    section          name                 GOLDEN                       OURS
    uhdmtopModules   (work@dut.s_ns)      vpiVariables/logic_var       vpiVariables/logic_var
!!  uhdmtopModules   (work@dut.a_ns)      vpiVariables/array_var       <none>
!!  uhdmtopModules   (work@dut.t_ns)      vpiNet/struct_net            vpiVariables/logic_var
    uhdmtopModules   (work@dut.pkd_ns)    vpiVariables/logic_var       vpiVariables/logic_var
!!  uhdmallModules   (work@dut.a_ns)      vpiNet/logic_net             <none>
```

---

## 2. THE DECODE (question 2)

### 2a. The hoist road, and why a package NET is not on it

`CompileHelper::importPackage` (src/DesignCompile/CompileHelper.cpp:127) has
TWO data arms and both ride the one import:

```
CompileHelper.cpp:171-181   auto& variableSet = def->getVariables();
                            for (auto& var : variableSet) scope->addVariable(var.second);
CompileHelper.cpp:183-190   auto& netSet = def->getSignals();
                            for (auto& net : netSet) scope->getSignals().push_back(net);
```

and **the SIGNAL VECTOR is what both listings the judge reads are built
from**: the def view is `writeNets(mod, mod->getSignals(), …)`
(UhdmWriter.cpp:1458) and the elaborated view's `Variables()`/`Nets()` come
from `NetlistElaboration::elab_ports_nets_`'s pass 1 over that same vector
(NetlistElaboration.cpp:2810-2811 `signals = &comp->getSignals()`;
:3035-3052 hands each entry to `elabSignal`). The variable map is a
name-keyed `std::map` used for VALUES, not for the listing.

Our hoist walks `SymbolKind::Variable` alone (`collectImportedPkgVars`,
src/EmitHelpers.h), so a package NET is invisible to BOTH of our views —
and to our package listing as well (§7 residue 1, one file over).

### 2b. Golden's kind table for a hoisted holder

`NetlistElaboration::elabSignal` (NetlistElaboration.cpp:2050-2780) decides
the ELABORATED kind, in three steps:

1. **net-or-variable from the DECLARATION** (:2074-2092): a net keyword keeps
   `isNet` true; `logic`, `int`, `string`, `bit`, `byte`, `real`, a const and
   a non-static all set it FALSE.
2. **the TYPESPEC OVERRIDES it** (:2133-2160): a `struct_typespec` whose
   members are ALL `logic_typespec` or `struct_typespec` flips `isNet` back to
   **TRUE**, and an `enum` / `bit` / `byte` / `real` / `class` typespec forces
   it FALSE **whatever the declaration said**.
3. **an UNPACKED dimension wraps the result**: a net becomes an `array_net`
   (:2534-2548), a variable an `array_var` (`makeVar_`).

The DEF view is a different writer and a flat one: `writeNets` with
`instance == nullptr` always `s.MakeLogic_net()` (UhdmWriter.cpp:824) and
stamps `getVpiNetType(orig_net->getType())` (:889) — so every hoisted entry
is a plain `logic_net` there, carrying the declaration's WRITTEN BASE KEYWORD
resolved through exactly ONE typedef hop.

---

## 3. THE GOLDEN GRID (question 3)

23 arms, `golden_rc=0 ours_rc=0` on every one; 17 are the pass-73/74/75
CONTROLS carried in verbatim (`b1_bindvis`, `b2_homes`, `b5_walkedge`,
`g1_netkinds`, `g2_importshapes`, `g4_edges`, `v6_ifacepkg`, `v9_hops`,
`w8_unitname`, `xb_arrnet`, `xc_impw`, `xe_impkind`, `xg_genimp`,
`xi_genimp2`, `xj_twoinst`, `xk_order`, `xl_impclimb`). The six new arms:

### 3a. `y1_pkgnetkind` — THE PACKAGE NET, KIND BY KIND (LAW A)

One package, every net keyword and every net TYPE, each with a gen-scope
namesake cell one hop out.

| package declaration | golden DEF view | golden ELAB view | golden BINDS the cell |
|---|---|---|---|
| `wire [31:0] n_plain` | `logic_net` nt=1 | `logic_net` nt=1 | yes |
| `wire n_scalar` | `logic_net` nt=1 | `logic_net` nt=1 | yes |
| `tri [31:0] n_tri` | `logic_net` nt=4 | `logic_net` nt=4 | yes |
| `wand [31:0] n_wand` | `logic_net` nt=2 | `logic_net` nt=2 | yes |
| `supply0 n_sup0` | `logic_net` nt=11 | `logic_net` nt=11 | yes |
| `wire sn_t n_wstruct` | `logic_net` nt=1 | **`struct_net`** nt=1 | yes |
| `wire en_t n_wenum` | `logic_net` nt=1 | **`enum_var`** (a VARIABLE) | yes |
| `wire [7:0] n_arr [0:1]` | `logic_net` nt=1 | **`array_net`** | **NO** |

Pristine lists NONE of the eight in either module view and binds none of the
seven cells. After the patch the whole MODULE listing and all seven bindings
are golden's, and the `array_net` still binds nothing.

### 3b. `y2_pkgvarkind` — THE HOISTED VARIABLE'S KIND (LAW B)

| package declaration | golden ELAB kind | pristine | patched |
|---|---|---|---|
| `logic [15:0] v_plain` | `logic_var` | golden's | golden's |
| `st_t v_struct` (ALL-LOGIC members) | **`struct_net`** | `logic_var` | golden's |
| `si_t v_structi` (an `int` member) | **`struct_var`** | `logic_var` | golden's |
| `sx_t v_structn` (a NESTED struct member) | **`struct_net`** | `logic_var` | golden's |
| `e_t v_enum` | `enum_var` | golden's | golden's |
| `logic [7:0] v_uarr [0:1]` | **`array_var`** | **absent** | golden's |
| `st_t v_sarr [0:1]` | **`array_net`** | **absent** | golden's |
| `logic [1:0][7:0] v_pkd` | `logic_var` | golden's | golden's |
| `int`/`byte`/`bit`/`real`/`string` | their own `*_var` | golden's | golden's |

Golden binds the gen-scope cell for `v_struct`, `v_structi`, `v_structn` and
`v_uarr`, and binds NOTHING for `v_sarr`. All five readings are ours after
the patch.

### 3c. `y3_impshape` — THE IMPORT SHAPES, AND THE TWO NEGATIVES (LAW A)

| row | golden | pristine | patched |
|---|---|---|---|
| `a_net` — wildcard, FOUR import copies (file-level + module-level) | 4 copies listed, cell bound | none | golden's, 4 copies |
| `a_var` — the same package's variable | 4 copies | 4 copies | unchanged |
| `b_net` — the TRANSITIVE hop (`pb` imports `pa`) | listed, bound | none | golden's |
| `c_net` — an EXPLICIT `import pc::c_net` | listed, bound | none | golden's |
| `c_unread` — pc's other net, not named by the item | **not listed** | none | **not listed** |
| `z_net` — a package NOBODY imports | **not listed**, cell unbound | none | **not listed** |
| `unitnet` — a `$unit` NET | **not listed**, cell unbound | none | **not listed** |

GOLDEN WRITES NOTHING ON A MISS, and the law never widens past the measured
import shapes: it rides the copy count, the transitive splice and the
explicit-item filter the variable hoist already has, and adds no reach.

### 3d. `y4_bindreach` — THE KIND TABLE IS NOT THE BIND TABLE

§ genCaLhsArrayNetNeverBinds17's decode (`bindVariable` searches
`Variables()` then `Nets()` and never `Array_nets()`), measured again on the
IMPORT road, with the module-body twins as the in-arm control:

| row | golden holder | golden BINDS | patched |
|---|---|---|---|
| `r_narr` — package `wire [7:0] [0:1]` | `array_net` | **no** | golden's, and no binding |
| `r_varr` — package `logic [7:0] [0:1]` | `array_var` | yes | golden's |
| `r_st` — package struct variable | `struct_net` | yes | golden's |
| `r_net` — package `wire [31:0]` | `logic_net` | yes | golden's |
| `r_var` — package `logic [31:0]` | `logic_var` | yes | unchanged |
| `m_narr`/`m_varr` — the MODULE-BODY twins | `array_net`/`array_var` | no/yes | unchanged |

**The pass-74 binding law serves every one of these cells with NO new binding
code** — proved by construction (this patch adds nothing to
`genCaLhsNamesake74` or to `bindVariable`'s walk; the holder is filed in
`topNets` under the package symbol and the existing lookup finds it) and by
arm (all four newly-bound cells and the one correctly-declined `array_net`).

### 3e. `y5_defnettype` — THE DEF-VIEW `vpiNetType`, SPELLING BY SPELLING (LAW C)

| package declaration | golden | pristine | patched |
|---|---|---|---|
| `logic [15:0]` | 36 | 36 | 36 |
| `reg [15:0]` | **48** | 36 | 48 |
| `integer` | **none** | 36 | none |
| `time` | **none** | 36 | none |
| `bit [15:0]` | none | none | none |
| `typedef logic [3:0] word_t; word_t x` | 36 | 36 | 36 |
| `typedef word_t word2_t; word2_t x` | **none** | 36 | none |
| `typedef logic [1:0][7:0] parr_t; parr_t x` | 36 | 36 | 36 |
| a packed STRUCT typedef | **none** | 36 | none |
| an ENUM typedef | **none** | 36 | none |
| a packed UNION typedef | **none** | 36 | none |
| `wire`/`tri`/`wand`/`wor`/`supply0`/`supply1`/`tri0`/`trireg` | 1/4/2/3/11/10/5/7 | absent | golden's |

The one-hop rule is not an inference: `word2_t`'s own typedef node is a
`NamedType` and `getVpiNetType` has no arm for one, while `word_t`'s is the
written `logic` keyword. The ELAB view of the same arm adds `union_var` for a
packed union (pristine: `logic_var`) and `struct_net` for a packed struct.

### 3f. `y6_hoistconv` — **THE CONVERTING ARM** (`cmp_rc 255 -> 0`)

Every other arm on this ground is MASKED at the package object itself,
because our PACKAGE listing (the `emitPackage` road, one file over — R0)
lists neither a package NET nor an unpacked-array package variable and
stamps the same over-broad net type on a struct/enum/union entry. This arm
uses ONLY the package shapes whose package rows ALREADY agree golden-for-
golden, so the module hoist is the whole remaining difference.

Its ONE pristine head is LAW C's own:

```
LHS: logic_net (work@dut.y_reg) |vpiName:y_reg |vpiNetType:48
RHS: logic_net (work@dut.y_reg) |vpiName:y_reg |vpiNetType:36
```

and after the patch the arm's whole listing — both views, both sections —
is golden's and `uhdm-cmp` returns 0.

### 3g. The CONTROLS

The seventeen carried-in arms are **BYTE-IDENTICAL** between the pristine and
patched binaries on every arm that has no hoisted entry, and the five that do
have one (`g2_importshapes`, `g4_edges`, `v6_ifacepkg`, `w8_unitname`,
`xe_impkind`, `xi_genimp2`, `xl_impclimb`) move only on their named cells.
Arm distance, `gold_only/ours_only` dump lines:

```
arm                gold_only/ours_only[pris]  gold_only/ours_only[patch]
b1_bindvis         9/1                     9/1
b2_homes           86/10                   86/10
b5_walkedge        136/3                   136/3
g1_netkinds        40/2                    40/2
g2_importshapes    209/4                   137/4
g4_edges           274/89                  274/89
v6_ifacepkg        142/5                   142/5
v9_hops            17/3                    17/3
w8_unitname        45/16                   45/16
xb_arrnet          35/41                   35/41
xc_impw            747/13                  747/13
xe_impkind         256/59                  187/12
xg_genimp          19/1                    19/1
xi_genimp2         19/1                    19/1
xj_twoinst         13/1                    13/1
xk_order           12/1                    12/1
xl_impclimb        474/6                   474/6
y1_pkgnetkind      893/7                   462/12
y2_pkgvarkind      373/177                 297/44
y3_impshape        859/28                  433/28
y4_bindreach       578/55                  344/11
y5_defnettype      971/146                 555/33
y6_hoistconv       42/9                    41/5
```

**ONE ARM CONVERTS** (`y6_hoistconv`, `cmp_rc 255 -> 0`) and **ZERO ARMS
REGRESS**: every arm that was `cmp_rc 0` at the base (`b1_bindvis`,
`g1_netkinds`, `v9_hops`, `w8_unitname`, `xj_twoinst`, `xl_impclimb`) is
still 0.

**THE ONE RISING `ours_only` COUNT, ATTRIBUTED LINE BY LINE.**
`y1_pkgnetkind` goes 7 -> 12. The five added lines are, verbatim:

```
1  \_ref_typespec: (work@dut.pn::en_t)          |vpiFullName:work@dut.pn::en_t
1  \_ref_typespec: (work@dut.pn::sn_t.x)        |vpiFullName:work@dut.pn::sn_t.x
1  \_ref_typespec: (work@dut.pn::sn_t.y)        |vpiFullName:work@dut.pn::sn_t.y
2  \_logic_typespec: , line:15:3, endln:15:14   (a NESTED print of the element ts)
```

Not one of them is a compared field: `Compare` reads VpiType/VpiName/
VpiDefName + per-kind fields and **never VpiFullName**, and the nested
`logic_typespec` prints are arena positions under an owner, not top-level
entries of a compared vector — counted golden-vs-ours at the top level of
`uhdmtopModules`, golden has FOUR of that object and we have TWO, so we are
not over-listing there either. The arm's ONE head is unchanged (the package
object of §7 residue 1) on both binaries.

---

## 4. THE THREE LAWS, GATED (question 4)

All three are in `src/ModuleEmit.cpp`; `src/EmitHelpers.h` carries the
listing's one new output and `include/UhdmExporter.h` one member
declaration. **`ParamEmit.cpp` is not touched at all** — it is
`__LINE__`-sensitive and the sister pass's ground.

**§ caImportedPkgNetHoist77** (`R11U77_PKGNET_OFF=1`) — the hoisted listing
is the package's SIGNAL vector: a `SymbolKind::Net` member rides it at its
own source slot, through the SAME copy count, transitive splice
(§ transitiveImportRidesTheHoist217) and explicit-import filter the variable
half already has. Its def-view entry is a plain `logic_net` carrying the net
KEYWORD's vpi code; its elaborated entry takes the kind table below. Fences:
that listing and nothing else — a package nobody imports, a `$unit` name and
an unnamed sibling of an explicit import are not consulted (`y3_impshape`),
and no binding code is touched.

**§ caImportedPkgHoistKindTable77** (`R11U77_HOISTKIND_OFF=1`) — the
elaborated holder's kind is `elabSignal`'s, not the declaration's: a packed
struct whose members are all logic/struct is a `struct_net`, any other packed
struct a `struct_var`, a packed union takes `emitPackageVar`'s own kind
(`union_var`), an enum-typed NET likewise (`enum_var`), and a fixed-size
unpacked array is an `array_var` — or an `array_net` when it is a net or an
all-logic-struct element. Fences: the two remaining unpacked aggregates
(`UnpackedStruct`, `UnpackedUnion`) stay OUT of the listing exactly as
before; the shapes we already agree on never reach this table; and the BIND
table is left alone, so an `array_net` holder is materialised and still binds
nothing (`y4_bindreach`).

**§ caImportedPkgDefNetType77** (`R11U77_DEFNT_OFF=1`) — the def-view hoisted
net's `vpiNetType` is the declaration's WRITTEN BASE KEYWORD through exactly
ONE typedef hop (`logic` 36, `reg` 48, everything else none), replacing "a
four-state INTEGRAL declaration is stamped 36", which a packed struct, a
packed union and an enum all satisfy and golden stamps none of.

**`R11U77_OFF=1` reproduces the pristine database BYTE FOR BYTE on all 23
arms** (0 of 23 differing, path-normalised and sorted). Each switch drops its
own law alone, measured as the normalised dump distance from the PRISTINE and
from the PATCHED database:

| switch | arms that revert to PRISTINE | every other arm |
|---|---|---|
| `PKGNET_OFF` | `y1` 0, `y3` 0, `g2` 0 (`y4` 296->128, `y5` 545->193: the net entries only) | unchanged from patched |
| `HOISTKIND_OFF` | `y3` 0, `g2` 0, `y6` 0-from-patched (`xe` 128->1, `y2` 311->4: the LAW C line stays) | unchanged from patched |
| `DEFNT_OFF` | `y6` 0, `xe` 0-from-patched, `y1`/`y3`/`y4` 0-from-patched | unchanged from patched |

The full ledger is `SWITCHES.r11u77.txt`. The residuals are named, not
rounded: every line by which a single-switch run differs from the patched
database is a `|vpiNetType:` line and nothing else —
`y2` 3, `y5` 7×`36`+1×`48`, `y6` 4×`36`+1×`48`, `xe` 0 — which is LAW C's
whole byte surface, and it is why `xe_impkind` under `HOISTKIND_OFF` sits ONE
line from pristine rather than zero.

---

## 5. THE CENSUS AND THE PREDICTION (question 5)

`cellcen77.py` replays the harness's OWN discovery and its OWN slang argv
(`verify_golden.discover_*` / `translate` / `location_args`), runs the frozen
patched binary with `R11U71_CELLDBG=1 R11U74_CELLDBG=1 R11U75_CELLDBG=1
R11U77_CELLDBG=1`, and writes one row per cell that reaches ANY of the five
sites — the DECLINED cells included. Every invocation's rc is recorded. The
four slang-fenced names are read off `canaudit.sh`'s own `FENCED=` line and
never dispatched.

This pass's two rows are the hoist itself, one per hoisted ENTRY:

* `R11U77DEFNT name=… net=… pre=… post=… SAME|MOVED` — the def-view listing,
  carrying BOTH net types, the pre-77 rule's and the new one's, computed in
  the same run. `MOVED` is therefore the pristine-vs-patched delta named a
  priori, entry by entry, without a second binary.
* `R11U77HOIST name=… net=… kind=…` — the elaborated listing, `kind=0`
  meaning "the pre-77 road decides and nothing moves".

**THE TRACE IS DATABASE-NEUTRAL, PROVED:** the same arm run with and without
`R11U77_CELLDBG=1` on the same binary gives the byte-identical `.uhdm`
(`y5_defnettype`, md5 `47c5f2612bd5a08326227cc741a6905d` both ways).

| corpus | arms | trace rows | `R11U69CELL` | `R11U74BIND` | `R11U77DEFNT` | `R11U77HOIST` |
|---|---|---|---|---|---|---|
| uhdm2rtlil | 871 x 2 modes | 9480 | 5588 | 3892 | **0** | **0** |
| surelog | 798 x 2 modes | 41398 | 28136 | 12574 | **410** | **278** |

* **uhdm2rtlil: the hoisted listing is EMPTY in the whole corpus, both
  modes** — not one module or interface there imports a package that declares
  any data at all. The pass cannot touch a byte of it.
* **surelog: 410 def-view entries and 278 elaborated ones, and every single
  one is UNMOVED** — `MOVED` count **0 of 410**, and `kind=0` on **278 of
  278** with `net=1` on **0 of 410**. The eleven (test, mode) pairs that have
  a hoisted listing at all are `ApbSlave`, `MiniAmiq`, `PackageNet`,
  `Scoreboard/default`, `SeqDriver`, `SimpleUVM` — the documented hoist
  population — and no package in either corpus declares a NET, a packed
  struct/union variable or an unpacked-array variable that this listing
  carries.

**THE CENSUS ZERO HAS A POSITIVE CONTROL** (a census zero needs one). The
same trace on the grid arms names moved entries, and distinguishes "present"
from "moved" exactly as the corpus reading does:

```
arm                defnt  MOVED  net=1  hoist  kind!=0
y1_pkgnetkind        8      8      8      8      8
y2_pkgvarkind       13      5      0     13      5
y3_impshape         10      6      6     10      6
y4_bindreach         5      4      2      5      4
y5_defnettype       19     15      8     19     10
y6_hoistconv         8      4      0      8      0
xe_impkind           4      2      0      4      2
g2_importshapes      4      1      1      4      1
g4_edges             2      0      0      2      0     <- present, UNMOVED
v6_ifacepkg          1      0      0      1      0     <- present, UNMOVED
w8_unitname          1      0      0      1      0     <- present, UNMOVED
xi_genimp2           2      0      0      2      0     <- present, UNMOVED
xl_impclimb          1      0      0      1      0     <- present, UNMOVED
```

`rc != 0` arms are recorded and carry no blind spot; a compile that fails
emits nothing and the sweep has no database for it — it teaches error
recovery, not golden.

**PREDICTED MOVER SET, WRITTEN BEFORE THE PATCHED SWEEPS: NOTHING. Zero
databases in either corpus, either mode.** Not "probably nothing" — the
instrument names all 688 hoisted entries the corpora contain and reads every
one of them SAME/kind=0.

---

## 6. THE GATES (question 6)

### 6a. Build and binaries

```
pristine  963667a2299a360105d9677e3a065959   == main tree @7d0c7bf4 == the OPS pin
patched   c676e58722bcd4bba191cfec84ab6799
```

Built `-j 2`, md5s taken separately, both frozen `chmod 555` before any
sweep.

### 6b. Goldens

```
patched    PASS 23   FAIL 0
pristine   PASS 23   FAIL 0
/bin/false PASS 0    FAIL 23        (negative control)
```

### 6c. uhdm2rtlil, both modes

```
788 CMP_EQUAL / 16 CMP_NOTEQUAL / 67 SLANG_REJECT   patched default
788 / 16 / 67                                       patched testflags
788 / 16 / 67                                       pristine default
788 / 16 / 67                                       pristine testflags
```

the committed baseline exactly.

```
testflags vs results/gate_uhdm2rtlil.csv        PASS: every row byte-identical
testflags vs this pass's own pristine sweep     PASS: every row byte-identical
default   vs this pass's own pristine sweep     PASS: every row byte-identical
both modes vs results/golden_uhdm2rtlil.csv     0 of 1742 rows differing
```

**`byteverify SELFCHECK=1`, patched vs this pass's own pristine workdir:**

```
databases: patched=1608 pristine=1608
PATH_SETS_IDENTICAL (1608 paths)
MOVERS: 0 / 1608
SELFCHECK (every file vs one fixed file): 1607 / 1608 flagged
```

**MOVERS 0 — the predicted set exactly.** The comparator's negative control
fires on 1607 of 1608, so a zero here is a reading and not a broken
instrument.

### 6d. surelog, `--mode both`

```
                 pristine          patched
default    CMP_EQUAL 474 / NE 9   CMP_EQUAL 474 / NE 9
testflags  CMP_EQUAL 469 / NE 8   CMP_EQUAL 469 / NE 8
```

the committed baseline exactly, on both binaries, and every other status
bucket identical too (5 DEFERRED, 285/286 SLANG_REJECT, 25/23 SURELOG_FAIL,
3 NO_DATABASE, 1 NO_UHDM, 1 TIMEOUT, 2 UNTRANSLATABLE).

**Whole-row join vs `results/golden_surelog.csv`: 3 of 1596 rows differ,
every one ENVIRONMENT, and every one present on the PRISTINE binary too.**

```
Earlgrey_0_1/testflags   committed  CMP_EQUAL,,,differ   ours  CMP_EQUAL,,,
LowMemLib/testflags      SURELOG_FAIL "... Creating log file <WORKDIR>/..."
LowMemPkg/testflags      SURELOG_FAIL "... Creating log file <WORKDIR>/..."
```

— the documented `uhdm-dump` timeout draw blanking the DUMP COLUMN under
load (the STATUS stays `CMP_EQUAL`; the DATABASE byte pins of §6e are the
real gate), and the workdir path carried inside a `SURELOG_FAIL` string. The
pristine sweep draws the same three, with the blank falling on
`Earlgrey_0_1/default` instead — which is the draw, not a difference between
the binaries: all four Earlgrey rows are `CMP_EQUAL` on both.

**Whole-row join vs this pass's OWN pristine sweep: 4 of 1596 rows differ** —
the two `LowMem*` path strings and the two Earlgrey DUMP-column sides of that
one draw. No status changes anywhere.

**`byteverify SELFCHECK=1`, patched vs this pass's own pristine workdir:**

```
databases: patched=960 pristine=960
PATH_SETS_IDENTICAL (960 paths)
MOVER ./default/MiniAmiq-544c7f61/slang.uhdm
MOVER ./default/SeqDriver-32af76aa/slang.uhdm
MOVER ./default/SimpleUVM-1dc93a62/slang.uhdm
MOVER ./testflags/MiniAmiq-544c7f61/slang.uhdm
MOVER ./testflags/SeqDriver-32af76aa/slang.uhdm
MOVERS: 5 / 960
SELFCHECK (every file vs one fixed file): 959 / 960 flagged
```

**FIVE MOVERS, ALL UVM FAMILY, AND EVERY ONE IS THE DOCUMENTED
PRISTINE-NONDETERMINISM CLASS — attributed, not assumed.** Each database's
order-blind, path-normalised, id-stripped whole-dump diff is **EXACTLY FOUR
LINES, and every one of them a `UINT:<n>` + `vpiDecompile:<n>` pair**:

```
default/MiniAmiq     UINT:0    <-> UINT:1098   vpiDecompile:0    <-> :1098
default/SeqDriver    UINT:744  <-> UINT:1064   vpiDecompile:744  <-> :1064
default/SimpleUVM    UINT:0    <-> UINT:996    vpiDecompile:0    <-> :996
testflags/MiniAmiq   UINT:1343 <-> UINT:869    vpiDecompile:1343 <-> :869
testflags/SeqDriver  UINT:1198 <-> UINT:1231   vpiDecompile:1198 <-> :1231
```

That is the UVM macro-buffer line-number class exactly as the standing ops
note describes it. **No `vpiNetType`, no `vpiActual`, no hoisted object and
no listing line among them** — not one line of any of this pass's three laws.
Their rows stay `CMP_EQUAL`: `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`,
`SimpleUVM` `CMP_EQUAL` in both modes on the committed baseline, on the
pristine binary and on the patched one, and `Scoreboard`
`CMP_EQUAL`/`SLANG_REJECT` unchanged.

An INDEPENDENT confirmation of the census sits in this list: `ApbSlave`,
`PackageNet` and `Scoreboard` carry hoisted entries too (§5) and are **not
movers at all**, so the three tests that did move are the three the
nondeterminism class names and not the three the hoist touches.

`rowheads.sh` on the patched workdir: **12 measured, 11 of them `0 0 cmp
rc=0`**; `Rggen/default` reads `64 1 cmp rc=255`, which is its committed
`CMP_NOTEQUAL` row unchanged. `SKIP-NOFILE` 2 (`Scoreboard/testflags` +
`Rggen/testflags`, expected), `UNKNOWN-NAME` 0.

### 6e. Canaries

**Canary DATABASE byte pins, patched vs this pass's own pristine — ALL SAME,
and every one the OPS pin verbatim:**

```
SVSwitch            default/testflags  4842211c4030   (OPS HARD pin)
YosysVerx           default/testflags  6ccda350c24a   (OPS HARD pin)
InterfaceModPort    default/testflags  59a365f3ce2c   (OPS pin)
YosysOldOr          default/testflags  d68e0796d62c
BlackParrotComplex  default e3e354129d5a  testflags 73a10e8217e5
Earlgrey_0_1        default 8bdf25272e08  testflags 59d0ee6d10c3   (OPS pins)
```

**CSV canaries:**

```
canaries.sh  surelog, patched vs OWN PRISTINE      ok=50 changed=2 absent=0
                                                    (both Earlgrey_0_1, the
                                                     DUMP-column draw; STATUS
                                                     CMP_EQUAL on all four)
canaries.sh  surelog, patched vs committed         ok=51 changed=1 absent=0
                                                    (Earlgrey_0_1/testflags,
                                                     same draw)
canaries.sh  u2r,     patched vs committed gate    ok=8  changed=0 absent=0
ctcan2       surelog  EXPECT_UNKNOWN=1             ok=58 changed=0  PASS
ctcan2       u2r      EXPECT_UNKNOWN=6             ok=1  changed=0  PASS
canaudit.sh  canaries.sh ctcan2.sh                 audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS
```

No fenced name appears anywhere in the patch outside `canaudit.sh`'s own
`FENCED=` line: the four names grep to **0** occurrences in
`git diff 7d0c7bf4` over the production surface and to **0 files** in this
directory.

### 6f. Binary path audit

```
u2r pristine       1742 / 1742 cmds.txt name <PRISTINE-BIN>   other-tree binaries: 0
u2r patched        1742 / 1742 cmds.txt name <PATCHED-BIN>    other-tree binaries: 0
surelog pristine   1531 / 1581 cmds.txt name <PRISTINE-BIN>   other-tree binaries: 0
surelog patched    1531 / 1581 cmds.txt name <PATCHED-BIN>    other-tree binaries: 0
```

The other 50 are Surelog-side failures that never invoked an exporter (their
`cmds.txt` carries the `surelog:` line alone). No `cmds.txt` in any of the
four workdirs names a main-tree or another worktree's binary.

### 6g. Score

**MOVED-WRONG 0. AWAY-GOLDEN 0.** Both corpora, both mode columns.

* uhdm2rtlil: **0 movers of 1608 databases**, both modes — the census's
  prediction met exactly, with a 1607/1608 negative control.
* surelog: **5 movers of 960**, every one attributed to the documented UVM
  macro-buffer line-number class by its own 4-line order-blind diff, none of
  them a line of any law here, and every one of those rows still `CMP_EQUAL`.
* Grid: 23 arms. **1 CONVERTS** (`y6_hoistconv`, `cmp_rc 255 -> 0`),
  **0 REGRESS**, and the only rising `ours_only` count (`y1` 7 -> 12) is five
  lines of `VpiFullName` strings and nested typespec print positions, none of
  them a compared field.
* Scoreboard, both corpora, both modes: **unchanged**, 474/9 + 469/8 and
  788/16/67 x 2.
* `results/*.csv` untouched — read only, never written.

---

## 7. RESIDUES (ranked)

1. **The PACKAGE'S OWN listing still misses its nets and its unpacked-array
   variables, and stamps the same over-broad def net type** — `y1`'s eight
   `pn::n_*` nets, `y2`'s `pk::v_uarr`/`pk::v_sarr`, `pk::v_structi`
   (golden `struct_var`, ours `logic_net`), and `py::y_struct`'s
   `vpiNetType:36` where golden writes none. That listing is
   `emitPackage`'s (`src/ParamEmit.cpp`), which is `__LINE__`-sensitive and
   the sister pass's ground, so this pass does not touch it — and it is the
   ONE head masking every arm on this ground except `y6_hoistconv`. **R0.**

2. **A `$unit`-scope NET is still no namesake home** — golden lists none and
   binds none (`y3_impshape` `unitnet`), and neither do we. Recorded as
   measured-agreement, not as a gap.

3. The pass-75/74/73 residue set stands unmoved and byte-identical: the
   gen-scope parameter's `UINT` encoding, the `func_call` leftover argument,
   r11u69's R1 `g_sh`, the interface def-view gen-scope statements,
   `v4_lhsshape`'s concat actuals, and `xh_ancpath`'s hierarchical module
   base over-fold.

**R0 — NEXT.** Residue 1 is the whole remaining difference on every arm this
pass measured: the package's own listing has to build from the same signal
vector the module hoist now builds from, with the same kind table and the
same one-hop net-type rule. It is one law in one function (`emitPackage`'s
own listing loop) and it converts `y1`, `y2`, `y3`, `y4`, `y5` and `xe` —
six arms whose module halves are already golden's.

---

## 8. HOW TO RE-RUN

```bash
GRID=<this dir>/grid bash rr77.sh <binary> <tag>        # golden + ours + cmp per arm, every rc recorded
GRID=<this dir>/grid bash sw77.sh <binary> <tag>        # the switch ledger: distance from pristine/patched
GRID=<this dir>/grid python3 score77.py pris patch      # gold-only / ours-only dump distance per arm
DIFF=1 python3 calist77.py <gold.dump> <ours.dump>      # the RESOLVING LISTER: one row per cont_assign
DIFF=1 python3 lister77.py <gold.dump> <ours.dump>      # the SHAPE LISTER: one row per signal slot
python3 cellcen77.py <repo> <corpus> <binary> <out.tsv> # the site census, declined entries included
```

`rr77.sh` regenerates the golden with the pinned Surelog per arm per tag and
records `golden_rc` and `ours_rc` for every arm; an arm whose compile fails
teaches error recovery, not golden. No corpus test is ever dispatched from
here — every arm is its own `dut.sv`, and the four slang-fenced names appear
in no driver.
