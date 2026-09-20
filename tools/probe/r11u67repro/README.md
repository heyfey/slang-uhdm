# r11u67 — § `aliasBindSimpleType67`

**A DEF-VIEW NET TYPE IS THE *BOUND* DataType OF THE WRITTEN TYPEDEF — ITS OWN
BASE KEYWORD (`logic` → 36, `reg` → 48) WHEN SURELOG REBOUND IT TO A
`SimpleType`, AND NOTHING THE REWRITE PRODUCES WHEN THE CHAIN STOPS AT A
`DummyType`. A PACKAGE OR `$unit` TYPEDEF WRITTEN OVER A NAMED TYPE IS NEVER
REBOUND. ON AN INSTANTIATED INTERFACE THE SAME REWRITE OUTRANKS THE NET
KEYWORD, EXACTLY AS IT DOES IN A MODULE.**

Base `12c6de50` (matrix-1.87). Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`, the golden producer),
uhdm2rtlil v0.68. Two binaries, both frozen `555` before any sweep:

| binary | md5 |
|---|---|
| pristine (my own worktree build at `12c6de50`) | `40563d03c6a4c68ed7192f6bd5657f5e` — **the OPS pin, byte-identical to the main tree** |
| the three laws | `92000bd6492e4dc376c4650aaad1675a` |

Every `cmds.txt` in every sweep was audited by binary PATH: 1742 u2r + 1531
surelog name `/tmp/r11u67_pris.bin` on the pristine side and
`/tmp/r11u67_law.bin` on the law side, and nothing else.

**THE PASS IS GRID-ONLY, AND THAT WAS PREDICTED BEFORE THE LAW WAS WRITTEN.**
The census over BOTH corpora at the base reads **`NT-DIFF = 0` on all 155 446
golden net keys** — there is no corpus net whose `vpiNetType` we get wrong
today, so no row could CONVERT and no row could ADVANCE on this field. The
prediction was therefore **ZERO byte movers**: `byteverify` measured **0 / 1608**
on uhdm2rtlil and **4 / 960** on surelog, and all four are the documented UVM
coin (§4). `results/*.csv` is UNTOUCHED and nothing in it needs promoting:
**u2r stays 787/17/67 in both modes, surelog stays 474/9 + 469/8.** The three
laws are scored on the grid: **TO-GOLDEN 29, AWAY-GOLDEN 0, MOVED-WRONG 0**,
with the eight pass-64 decline cells byte-identical.

---

## 1. THE PRODUCER, DECODED — ONE RULE BEHIND ALL THREE LAWS

Pass 64 read the rewrite (`ElaborationStep.cpp:1487-1500`: a signal whose
written type resolves to a `DataType` whose **actual** category is
`SIMPLE_TYPEDEF` has `Signal::m_type` rewritten to that typedef's own base
`VObjectType`, which `UhdmWriter.cpp:891` / `:572` then stamp as 36 / 48) and
fenced it empirically with "module-local, one hop". This pass reads **where
that `DataType` comes from**, and the fence turns out to be a shadow of two
mechanisms:

**(1) A typedef written over a NAMED type is compiled to a `DummyType`, and
its typespec is built eagerly ONLY in a package or a `$unit`.**
`CompileHelper.cpp:877-905`:

```cpp
DummyType* dummy = new DummyType(fC, type_name, stype);
newTypeDef->setDataType(dummy);
newTypeDef->setDefinition(dummy);
// Don't create the typespec here, … except for packages and FileContent
if ((reduce == Reduce::Yes) &&
    ((valuedcomponenti_cast<Package*>(scope) ||
      valuedcomponenti_cast<FileContent*>(scope)))) { … dummy->setTypespec(…); }
```

A typedef written over a BUILT-IN takes the other branch and is a `SimpleType`
(`:1057`), category `SIMPLE_TYPEDEF`, carrying `fC->Type(stype)` — the base
keyword itself.

**(2) `bindTypedefs_` rebinds only the dummies that have NO typespec.**
`ElaborationStep.cpp:102-190`:

```cpp
if (noTypespec == true) {
  if (prevDef && prevDef->getCategory() == DataType::Category::DUMMY) {
    const DataType* def = bindTypeDef_(typd, comp, …);
    if (def && (typd != def)) { typd->setDefinition(def);
                                typd->setDataType((DataType*)def); …
```

So a **package or `$unit`** typedef over a named type keeps its `DummyType`
forever, `getActual()` stops there, `cat != SIMPLE_TYPEDEF`, and the rewrite
never fires: the signal keeps what was WRITTEN — the net keyword when one was
written, and nothing at all for a bare named type. A **module-local** one is
rebound to its target's OWN `DataType`, so a chain `w_t → v_t → logic` ends at
`v_t`'s `SimpleType(paIntVec_TypeLogic)` and stamps 36.

### The ORDER caveat — and the pass-64 "self-contradicting golden cell",
### decoded

`bindTypedefs_` walks each scope's `getTypeDefMap()`, which is **name-sorted**,
and binds to the target's `DataType` *as it stands at that moment*. A
module-local typedef whose target is another module-local typedef over a named
type therefore answers **36 when the target's name sorts first and 0 when it
sorts second**. Measured, one file, rc=0, 0 `[ERR`, identical shape and
identical textual order in both cells ([grid/g4_order](grid/g4_order/dut.sv)):

| cell | declaration | golden |
|---|---|---|
| `ordm.x` / `ordi1.x` | `typedef p_t aq_t; typedef aq_t zb_t [2]; zb_t x;` | **36** |
| `ordm.y` / `ordi0.y` | `typedef p_t zq_t; typedef zq_t ab_t [2]; ab_t y;` | **0** |

That is the whole of the cell pass 64 recorded as *"one cell where golden
contradicts itself"* (v2 `warr` = 36 against v8 `d06` / v9 `m1` = 0): `wa_t`
sorts after `w_t`, `lc_t` sorts before `lw_t`. **It is not a contradiction, it
is the bind order.** This pass does NOT model the sort order — the helper
answers `Unknown` for that chain and leaves the shape exactly as the landed
code had it (R-ORDER below). In the direct `typedef z_t m_t;` form Surelog
additionally *errors* on the later-sorting target (`[ERR:CP0317] Undefined
type`), which is the same mechanism showing its teeth.

---

## 2. THE THREE LAWS, AND WHAT EACH ONE MOVES

Each law is a separate `§ aliasBindSimpleType67` clause behind its own grid arm
and can be dropped alone.

### LAW A — `src/ModuleEmit.cpp`, the def net loop's `aliasOfAlias0` guard

The guard's own witness, uhdm2rtlil `arrays03`, declares `typedef reg8_t [0:3]
reg2dim1_t;` **at `$unit` scope**: never rebound, so golden stamps nothing. The
guard read only the SHAPE and zeroed the module-local twin too. It now zeroes
only what the chain leaves at a `DummyType`:

```cpp
aliasOfAlias0 = tt0.kind == SymbolKind::PackedArrayType &&
                tt0.as<PackedArrayType>().elementType.kind == SymbolKind::TypeAlias &&
                aliasBindNetType67(*it.sym) == 0;
```

with the answer itself coming from the new def-view clause at the top of
`netTypeFor` (36 / 48). `arrays03`'s shape is re-measured verbatim in
[grid/g5_unit](grid/g5_unit/dut.sv): every cell SAME-OK on both binaries,
`pcktest4.in` = 0 on both sides.

### LAW B — `src/EmitHelpers.h`, the dimension-less arms of `netTypeFor`

A `DummyType` chain must not be stamped. The clause sets a `dummyChain67` flag
which (a) skips the def-view module-local alias arm and (b) makes the
`NamedType` tail return 0 instead of `vpiNet`/`vpiReg`. A net that WROTE a
keyword still returns its keyword from the net-kind switch above, which is what
golden does (`wire pv2_t a17` = 1 on both sides).

### LAW C — `src/ModuleEmit.cpp`, the interface def road

That road called `netTypeFor` with **no def-view flag**, so the net keyword won
there. On an INSTANTIATED interface golden runs the same rewrite as in a
module; on the UNINSTANTIATED twin it runs no elaboration at all and the
keyword stands (the r10v225 R1 gate, re-measured here on `ifu`):

```cpp
int32_t ifnt65 = netTypeFor(*it.sym);
if (ifaceInstantiated225) {
    if (int32_t b67 = aliasBindNetType67(*it.sym)) ifnt65 = b67;
    else if (int32_t u65 = unpackedAliasNetType65(*it.sym)) ifnt65 = u65;
}
```

The `else if` is the dimensioned half: pass 64's clause was reached only when
`ifnt65` was already 0, so `wire v_t n5 [2]` kept its keyword.

---

## 3. THE GOLDEN GRID — five arms, `surelog -parse -nobuiltin -nocache -sv`
## rc=0 and 0 `[ERR` on every one, both binaries rc=0

Scored by net identity (view × scope × name × net kind) against each arm's own
golden — [evidence/GRID.g.score.txt](evidence/GRID.g.score.txt),
[evidence/ARMS.rc.pris.txt](evidence/ARMS.rc.pris.txt),
[evidence/ARMS.rc.law.txt](evidence/ARMS.rc.law.txt):

| arm | TO-GOLDEN | AWAY | MOVED-WRONG | STILL-WRONG |
|---|---|---|---|---|
| g1_lawA | 8 | 0 | 0 | 3 |
| g2_lawB | 4 | 0 | 0 | 1 |
| g3_lawC | 8 | 0 | 0 | 1 |
| g4_order | 0 | 0 | 0 | 2 |
| g5_unit | 0 | 0 | 0 | 0 |

### (a) `g1_lawA` — the dimension-less stamp path: chain × keyword × home

| cell | declaration | golden | pristine | law |
|---|---|---|---|---|
| a1 | `w_t a1;` (`typedef v_t [1:0] w_t`) LOCAL | 36 | **0** | **36** |
| a2 / a3 | `wire w_t a2;` / `wand w_t a3;` | 36 | **0** | **36** |
| a4 | `rw_t a4;` (`typedef r_t [1:0] rw_t`, `reg`) | **48** | **0** | **48** |
| a12 / a13 | `wire rw_t a12;` / `wire r_t a13;` | **48** | 0 / **36** | **48** |
| a5 | `bw_t a5;` (`bit` chain) | 0 | 0 | 0 |
| a6 / a18 | `v2_t a6;` / `wire v2_t a18;` | 36 | 36 | 36 |
| a7 | `w_t a7 [2];` (pass-64 ground) | 36 | 36 | 36 |
| a8 / a9 | `pw_t a8;` PACKAGE / `uw_t a9;` `$unit` | 0 | 0 | 0 |
| a10 / a11 | `pv2_t a10;` / `uv2_t a11;` alias-of-alias | 0 | **36** | **0** |
| a17 / a20 | `wire pv2_t a17;` / `wire uv_t a20;` | 1 / 36 | 1 / 36 | 1 / 36 |
| pin | `input uw_t pin` (ANSI port, `$unit`) | 0 | 0 | 0 |

`a4` against `a1` is the reg/logic split the fence never reached; `a2`/`a3`
against `a17` is the keyword split: the keyword LOSES to a rebound chain and
WINS over a dummy one.

### (b) `g2_lawB` — the home of the alias, and of the alias BELOW it

| cell | declaration | golden | pristine | law |
|---|---|---|---|---|
| e1 / e4 / e7 | `cv_t e1;` / `cr_t e4;` / `uv_t e7;` (SIMPLE, package/$unit) | 36 / 48 / 36 | same | same |
| e2 / e5 / e8 | `cv2_t e2;` / `cr2_t e5;` / `uv2_t e8;` (DUMMY) | 0 | **36 / 48 / 36** | **0** |
| e3 | `cw_t e3;` PACKAGE packed-array-of-alias | 0 | 0 | 0 |
| e6 | `pk::cv_t e6;` SCOPED | 0 | 0 | 0 |
| f1 | `typedef cv_t l1_t; l1_t f1;` LOCAL over a package SIMPLE | 36 | 36 | 36 |
| f2 | `typedef cv2_t l2_t; l2_t f2;` LOCAL over a package DUMMY | 0 | **36** | **0** |

`f1` against `f2` is the decisive pair: the same local typedef, the same home,
and the answer decided one level DOWN by whether the package alias it names was
itself written over a built-in.

### (c) `g3_lawC` — the interface road, instantiated against uninstantiated

| cell | declaration (in `ifx`, INSTANTIATED) | golden | pristine | law |
|---|---|---|---|---|
| n1–n4 | `wire`/`wand`/`wor`/`tri` `v_t nX;` | 36 | **1 / 2 / 3 / 4** | **36** |
| n5 / n6 | `wire v_t n5 [2];` / `wand v_t n6 [2];` | 36 | **1 / 2** | **36** |
| n7 | `wire r_t n7;` | **48** | **1** | **48** |
| n8 | `wire w_t n8;` (packed-array-of-alias) | 36 | **1** | **36** |
| n0 / n9 / n10 | `v_t n0;` / `wire logic [1:0] n9;` / `wand … n10;` | 36 / 1 / 2 | same | same |
| q1–q5 | the same declarations in the UNINSTANTIATED `ifu` | 1 / 2 / 1 / 1 / 1 | same | **same** |

The `ifu` column is the control: the instantiation gate holds, and not one
uninstantiated cell moves.

### (d) The pass-64 controls, re-run cell for cell

The whole `r11v65repro` grid (10 arms) was re-run on both binaries —
[evidence/GRID.v65control.score.txt](evidence/GRID.v65control.score.txt).
**TO-GOLDEN 9, AWAY-GOLDEN 0, MOVED-WRONG 0**, and the eight measured decline
cells the pass-64 fence exists to protect (`v8` d05/d06/d08–d12, `v9` m1–m4 /
m7–m8, `va` m9–m13 `x`) are byte-identical: golden 0, pristine 0, law 0. The
nine that move are this pass's own: `v2 wnod`, `v8 d15`, `va m9.wd`/`m10.wd`
(LAW A, 0 → 36), `v8 d16` (LAW B, 36 → 0), `v4 ifa.gw`/`ifa.gd` (LAW C, 1/2 →
36). `v2 warr` and `v2 sel` stay STILL-WRONG, as fenced.

---

## 4. THE CENSUS — GOLDEN-vs-GOLDEN FIRST, THEN THE MOVERS BY NAME

Instrument: `tools/probe/r11u65repro/netcen65.cpp --join`, one line per net
object reachable from the design root, keyed on view × scope path × net name ×
net UHDM kind, carrying the compare-visible `VpiNetType`. It reads databases
only. [evidence/CENSUS.base.txt](evidence/CENSUS.base.txt):

| corpus | arms | golden keys | ours keys | MATCH | **NT-DIFF** | ONLY-GOLDEN |
|---|---|---|---|---|---|---|
| uhdm2rtlil (both modes) | 1608 | 21 352 | 21 332 | 21 332 | **0** | 20 |
| surelog (both modes) | 960 | 134 094 | 134 088 | 134 088 | **0** | 6 |

**POSITIVE CONTROL** ([evidence/CENSUS.positive-control.txt](evidence/CENSUS.positive-control.txt)):
the same instrument on the grid databases reports **11 NT-DIFF** on `g1_lawA`
golden-vs-pristine (falling to 3 after the law) and **9** on `g3_lawC` (falling
to 1). The corpus zero is a measured zero, not a blind one.

So the mover set was predicted BY NAME before the law sweep: **the empty set,
in both corpora and both modes.** `byteverify` with `SELFCHECK=1` against my
own pristine workdirs measured **0 / 1608** on uhdm2rtlil, and on surelog
**4 / 960** — every one of them inside the documented pristine-nondeterministic
UVM family, and every one the documented **0-or-4-line UINT/vpiDecompile**
line-number class, with **no `vpiNetType` line in any of them**
([evidence/MOVERS.attribution.txt](evidence/MOVERS.attribution.txt)):

```
./default/MiniAmiq-544c7f61     4 order-blind lines   UINT/vpiDecompile 1429 <-> 1508
./default/SimpleUVM-1dc93a62    4 order-blind lines   UINT/vpiDecompile 1439 <-> 0
./testflags/MiniAmiq-544c7f61   4 order-blind lines   UINT/vpiDecompile  544 <-> 1086
./testflags/SeqDriver-32af76aa  4 order-blind lines   UINT/vpiDecompile 1323 <-> 0
```

**THE COIN CONTROL, run rather than asserted:** the SAME PRISTINE BINARY run
four more times on `MiniAmiq/default` produced **four different databases**
(`9827091daf11`, `6c45425e13cb`, `4896eaf4dd33`, `01cd64284fc6`), none of them
equal to the sweep's own pristine database — and the pristine-vs-pristine
order-blind diff is the SAME `UINT`/`vpiDecompile` pair, with zero
`vpiNetType` lines. Every UVM-family row and `Earlgrey_0_1` still reads **0 cmp
lines / 0 heads / `cmp rc=0`** through the official `uhdm-cmp` on the law
binary, in both modes.

**THE SAME CENSUS AFTER THE LAW reads `NT-DIFF = 0` again, cell for cell**
([evidence/CENSUS.law.txt](evidence/CENSUS.law.txt)) — AWAY-GOLDEN 0 stated by
an instrument independent of `byteverify`.

---

## 5. THE GATES

All green, every one measured against my OWN pristine sweeps —
[evidence/GATES.txt](evidence/GATES.txt) carries the readings verbatim:
goldens 23/0 with the law binary and 0/23 under `SLANG_UHDM=/bin/false`; both
u2r row-joins and the surelog row-join PASS with the only differing rows quoted
(`LowMemLib`/`LowMemPkg`, whose `detail` column embeds the workdir path, and
`Earlgrey_0_1`'s dump column, where it is MY PRISTINE side that drew blank and
the law side that matches the committed baseline `,,differ`); canaries
`ok=52`/`ok=8` changed=0, both `ctcan2` PASS, `canaudit` audited=29 UNCOVERED=0
FENCE-BREACH=0; and every protected database byte-identical, `SVSwitch`
`4842211c4030` and `YosysVerx` `6ccda350c24a` included.

---

## 6. RESIDUES

* **R-ORDER** — `typedef aq_t zb_t [2]; zb_t x;` where the target sorts FIRST:
  golden 36, ours 0 (`g4_order` `ordm.x`/`ordi1.x`, and `v2 warr`). The rule is
  decoded (§1) but not modelled: it would make our net type depend on the
  alphabetical order of the typedef names in the scope. STILL-WRONG, pristine
  and law identical.
* **R-KWDUMMY** — `wire pw_t a15;` / `wire uw_t a16;` / `wand pw_t a19;`:
  golden keeps the NET KEYWORD (1 / 1 / 2) over a never-rebound chain, we print
  0, because the `aliasOfAlias0` guard zeroes the whole shape. The one-line
  correction is to let the guard fire only when no net keyword was WRITTEN
  (a `NetDeclaration` in the syntax parent chain, which `arrays03`'s ANSI port
  does not have) — deliberately NOT taken in this batch, since it is a fourth
  law with no corpus witness. STILL-WRONG, pristine and law identical.
* **R-SLANG** — `wire bw_t x;` over a two-state (`bit`) chain: golden stamps 1,
  slang REJECTS the declaration outright (*"not a valid type for a net"*). The
  cell is commented out of `g1_lawA` rather than dispatched.
* **R1 (r10v225)** — `uv_t q0;` in an UNINSTANTIATED interface: golden 0, ours
  36. Pre-existing, untouched, and the reason LAW C is gated on instantiation.
* **R-V2 (pass 64)** — `v_t [1:0] sel [2];` golden 36, ours 0: the written form
  is an `IdentifierSelectName` over a `PackedArrayType`, not an alias.

**R0 for the next pass on this face: R-KWDUMMY** — three measured cells, one
gated line, and the guard's own corpus witness already re-measured in
`grid/g5_unit`.

---

## 7. RE-RUNNING

```bash
bash run67.sh <binary> pris          # golden + a binary per arm, BOTH rcs
bash run67.sh <other-binary> law
bash score67.sh                      # golden vs pris vs law, per net identity
python3 cells67.py grid/g1_lawA pris law     # one line per net, all three sides
# the census (build netcen65 from tools/probe/r11u65repro/netcen65.cpp first):
bash ../r11u65repro/census65.sh join <workdir>   # NT-DIFF rows BY NAME
```
