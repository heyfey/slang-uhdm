# r11u79 — the package's own listing: the same signal vector, split by
# `elabSignal`, written by two different writers

Base commit `15ff66f6`. Pristine binary md5
`c56e3f2c141ee7e9a6bb41c9d4e38f8c` — built in this pass's own worktree,
`-j 2`, md5 taken separately, and **byte-identical to the main tree's
`build/slang-uhdm` at `15ff66f6` and to the OPS pin**, compared not assumed.
Patched binary md5 `67a6075c5d761d74bd4a28b0d0cf0b6b`. Both frozen `chmod 555` at immutable
paths before any sweep; every `cmds.txt` audited by binary PATH.

Three laws, three switches, each droppable alone. `results/*.csv` untouched —
read only, never written. **No corpus row converts and none regresses in
either corpus; the conversions are grid arms — EIGHT of them.**

This is pass 77's R0, named by both its reports as the single head masking
`y1`-`y5`, `xe` and `va`-`vi`. It is the PACKAGE-SIDE TWIN of
§ caImportedPkgNetHoist77 / § caImportedPkgHoistKindTable77 /
§ caImportedPkgDefNetType77: the same signal vector, the same kind table and
the same one-hop net-type rule, one function over. It is NOT the same object
shape — the module's elaborated view wraps a net in a `struct_net` /
`array_net`, the package's never does.

---

## 1. THE SEVEN WITNESSES, RE-MEASURED AT THE BASE (question 1)

Every arm compiles on both sides (`golden_rc=0 ours_rc=0`); goldens are
regenerated per arm by the pinned Surelog v1.87.

```
y1_pkgnetkind     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=192
y2_pkgvarkind     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=712
y3_impshape       golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=37
xe_impkind        golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=236
va_netstructkinds golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=247
vb_unpackedfaces  golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=430
vi_defnt          golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=600
```

**All seven heads are THE PACKAGE OBJECT ITSELF**, verbatim off
`cmp.pris.err` (the vector overload printing both containers on a
`Variables()` / `Nets()` size mismatch):

```
y1  package: pn (pn::), line:9:1, endln:20:11
y2  package: pk (pk::), line:8:1, endln:26:11
y3  package: pa (pa::), line:7:1, endln:10:11
xe  package: pv (pv::), line:6:1, endln:12:11
va  package: pn (pn::), line:6:1, endln:17:11
vb  package: pu (pu::), line:6:1, endln:17:11
vi  package: pd (pd::), line:4:1, endln:24:11
```

and the listing behind `y2`'s, through this pass's package-section scorer
(`pkgscore79.py`, one row per entry of `p->Variables()` / `p->Nets()`),
verbatim:

```
    section           name                GOLDEN                        OURS
!!  uhdmallPackages   (pk::v_sarr)        vpiNet/logic_net              <none>
!!  uhdmallPackages   (pk::v_structi)     vpiVariables/struct_var       vpiNet/logic_net
!!  uhdmallPackages   (pk::v_uarr)        vpiVariables/array_var        <none>
```

Across the 38 arms the base reads **498 golden package-listing rows against
264 of ours, 295 cells disagreeing**.

---

## 2. THE DECODE (question 2)

### 2a. Where golden's package listing comes from — the SAME signal vector

`NetlistElaboration::elaboratePackages`
(Surelog `src/DesignCompile/NetlistElaboration.cpp:100-134`) runs over BOTH
package views and hands every entry of `pack->getSignals()` to the SAME
`elabSignal` the module side rides:

```
NetlistElaboration.cpp:107   for (Package* pack : {p->getUnElabPackage(), p})
NetlistElaboration.cpp:117   for (Signal* sig : pack->getSignals())
NetlistElaboration.cpp:118     if (!elabSignal(sig, nullptr, nullptr, nullptr,
                                               netlist, pack, "", false, ...))
NetlistElaboration.cpp:121       notSignals.insert(sig);
NetlistElaboration.cpp:124-129   ... erase(itr) from pack->getSignals()
```

`elabSignal` has ONE return, `return isNet;` (:2778). So the split is exact:
**a signal that reads as a VARIABLE is pushed onto `netlist->variables()` and
ERASED from `getSignals()`; the survivors stay in the signal vector.**

`UhdmWriter::writePackage` (`UhdmWriter.cpp:1180`) then writes the two
vectors with two DIFFERENT writers:

```
UhdmWriter.cpp:1281   p->Variables(netlist->variables());      <- elabSignal's objects
UhdmWriter.cpp:1298   writeNets(pack, pack->getSignals(), p, dest_nets, s,
                               signalBaseMap, netMap, portMap, nullptr);
```

and `writeNets` with `instance == nullptr` is the FLAT def-view writer:
`dest_net = s.MakeLogic_net()` (:822) stamped
`getVpiNetType(orig_net->getType())` (:891), with no array wrapper of any
kind — its `array_net` arm is gated on an `interface_inst` parent (:899).

**That is the whole shape of the answer.** A package NET is a plain
`logic_net` however it was declared, unpacked dimensions dropped; a package
VARIABLE is whatever `elabSignal` built. Measured, `y1_pkgnetkind`'s eight
package nets are eight flat `logic_net`s in both views and `wire [7:0] n_arr
[0:1]` is one of them — no `array_net`, no dimension.

### 2b. Our `emitPackage` before this pass

`emitPackage`'s listing loop (`src/ParamEmit.cpp`) walked
`SymbolKind::Variable` alone and split it with a written-type rule of its
own — "an integral non-enum `TypeAlias`, or an anonymous packed aggregate,
is a net". That rule is right for eleven measured spellings and wrong for
six, and the walk never saw a `SymbolKind::Net` member at all;
`emitPackageVar` then dropped every fixed-size unpacked array and every
unpacked struct/union outright.

---

## 3. THE GOLDEN GRID (question 3)

38 arms, `golden_rc=0 ours_rc=0` on every one. 32 are CONTROLS carried in
verbatim from `tools/probe/r11u77repro/grid` (23) and
`tools/probe/r11v77repro/grid` (9) — the pass-77 module-side arms, which is
what the standing brief asks for. Six are new:
`z3_pkgtdnet`, `z4_pkgdefnt`, `z5_pkgunpacked`, `z6_pkgconv`,
`z7_pkgimpclone`, `z8_pkgqual` (`z6` is the converting arm).

Every table below is golden's reading, PACKAGE SECTION scored, and every
one of them is ours after the patch.

### 3a. `z3_pkgtdnet` — THE NET/VARIABLE DISCRIMINATOR (LAW B)

| package declaration | golden | pre-79 |
|---|---|---|
| `typedef logic [3:0] word_t; word_t t_word` | `logic_net` | same |
| `typedef word_t word2_t; word2_t t_word2` | `logic_net` | same |
| `typedef reg [3:0] rg_t; rg_t t_reg` | `logic_net` | same |
| `typedef bit [3:0] bt_t; bt_t t_bit` | **`bit_var`** | `logic_net` |
| `typedef struct packed {logic,logic} st_t; st_t t_st` | `logic_net` | same |
| `typedef struct packed {int,logic} si_t; si_t t_si` | **`struct_var`** | `logic_net` |
| `typedef union packed {...} un_t; un_t t_un` | `logic_net` | same |
| `typedef enum ... en_t; en_t t_en` | `enum_var` | same |
| `typedef logic [1:0][7:0] parr_t; parr_t t_parr` | `logic_net` | same |
| `typedef int int_t; int_t t_int` | `logic_net` | same |
| `struct packed {logic,logic} t_anon` (ANONYMOUS) | `logic_net` | same |
| `struct packed {int,logic} t_anonsi` | **`struct_var`** | `logic_net` |
| `union packed {...} t_anonu` (ANONYMOUS) | **`union_var`** | `logic_net` |
| `typedef struct {logic,byte} us_t; us_t t_us` | **`struct_var`** | **absent** |
| `typedef struct {logic,logic} usl_t; usl_t t_usl` | **`logic_net`** | **absent** |
| `typedef union {logic,byte} uu_t; uu_t t_uu` | **`logic_net`** | **absent** |
| `typedef union {logic,logic} uul_t; uul_t t_uul` | **`logic_net`** | **absent** |
| `struct {logic,logic} t_anonus` (ANON unpacked) | **`logic_net`** | **absent** |

36 rows over both views, **MISMATCH 0** after the patch.

The reading is `elabSignal`'s, transcribed: (1) a NET KEYWORD or a written
TYPE IDENTIFIER keeps `isNet`, a builtin keyword spelling drops it; (2) the
typespec overrides — a struct's member test (`logic`/`struct` only), and an
`enum`/`bit`/`byte`/`real`/`class` typespec forces FALSE whatever the
declaration said; a UNION and a packed ARRAY have NO arm and keep (1)'s
answer. The union split is not an exception invented here: it falls straight
out of "no arm", because the typedef'd spelling enters (1) as a net and the
anonymous one does not.

### 3b. `z4_pkgdefnt` — THE `vpiNetType`, AND IT IS NOT THE SAME IN THE TWO VIEWS (LAW C)

| package declaration | DEF view | ELAB view |
|---|---|---|
| `wire` / `tri` / `wand` / `wor` | 1 / 4 / 2 / 3 | same |
| `tri0` / `tri1` / `trireg` / `triand` / `trior` | 5 / 6 / 7 / 8 / 9 | same |
| `supply1` / `supply0` / `uwire` | 10 / 11 / 13 | same |
| `wire signed [7:0]` | 1 | 1 |
| `wire logic [7:0]` | 1 | 1 |
| `wand integer` | **none** | **none** |
| `wire st_t` / `wire un_t` | 1 | 1 |
| `wire w_t` (a ONE-HOP typedef) | 1 | **36** |
| `wire w2_t` (a typedef of it) | 1 | 1 |
| `w_t x` (no net keyword) | none | **36** |
| `rg_t x` (`typedef reg [3:0]`) | none | **48** |
| `parr_t x` / a typedef'd unpacked array | none | **36** |
| `w2_t x` / `st_t x` / `un_t x` / `int_t x` / an anon struct | none | none |
| `logic` / `reg` / `integer` / `time` / `bit` / `var logic` / `const logic` | (a VARIABLE, no net type) | same |

31 declarations, 62 rows over both views, **MISMATCH 0** after the patch.
Pre-79 we stamped `vpiNet` (36) on EVERY entry of the listing and only in
the elaborated view — wrong in both directions, and the def view's net
keywords were simply absent.

The two views differ because they hold DIFFERENT Signal objects and only the
elaborated one has been through `ElaborationStep`'s type rewrite
(`ElaborationStep.cpp:1489-1500`): when the declaration's type NAME resolves
to a `SIMPLE_TYPEDEF` whose own written type is `logic` / `reg` / `wire`,
the signal's type is REPLACED by that keyword. Exactly one hop — a typedef
of a typedef is not a SIMPLE_TYPEDEF target, which is why `w2_t` falls back
to the keyword and `word2_t` to nothing. The def-view value is
`compileNetDeclaration`'s (`CompileHelper.cpp:2096-2206`): the NET KEYWORD,
unless a BUILTIN data-type keyword other than `logic` stands between it and
the name — the source's own comment is `"wire logic" is "wire"` (:2174-2181)
— in which case that keyword answers `getVpiNetType` instead and answers 0
for every keyword the table has no arm for.

### 3c. `z5_pkgunpacked` — THE UNPACKED DECLARATION, ELEMENT BY ELEMENT (LAW A + B)

| package declaration | golden DEF | golden ELAB | pre-79 |
|---|---|---|---|
| `logic [7:0] u_vlog [0:1]` | `array_var` auto=1 size=1 elem `logic_var` | size=2 | **absent** |
| `wire [7:0] u_nlog [0:1]` | `logic_net` nt=1 | same | **absent** |
| `sl_t u_vsl [0:1]` (all-logic struct) | `logic_net` | same | **absent** |
| `wire sl_t u_nsl [0:1]` | `logic_net` nt=1 | same | **absent** |
| `si_t u_vsi [0:1]` (an `int` member) | `array_var` auto=0 elem `struct_var` | size=2 | **absent** |
| `wire si_t u_nsi [0:1]` | `array_var` auto=0 elem `struct_var` | size=2 | **absent** |
| `un_t u_vun [0:1]` / `wire un_t u_nun [0:1]` | `logic_net` / `logic_net` nt=1 | same | **absent** |
| `en_t u_ven [0:1]` / `wire en_t u_nen [0:1]` | `array_var` auto=0 elem `enum_var` | size=2 | **absent** |
| `int u_vint [0:1]` | `array_var` auto=1 **vpiSigned=1** elem `int_var` | size=2 | **absent** |
| `bit [7:0] u_vbit [0:1]` | `array_var` auto=1 elem `bit_var` | size=2 | **absent** |
| `real u_vreal [0:1]` / `string u_vstr [0:1]` | `array_var` auto=1 elem `real_var`/`string_var` | size=2 | **absent** |
| `logic [7:0] u_2d [0:1][0:2]` | `array_var` size=1 | **size=6, FLATTENED** | **absent** |
| `logic [7:0] u_sh [2]` | `array_var` size=1 | size=2 | **absent** |
| `arr_t u_td` (a TYPEDEF'd unpacked array) | `logic_net` | `logic_net` **nt=36** | **absent** |
| `logic [7:0] u_dyn []` / `u_q [$]` / `u_as [string]` | `array_var` auto=1 size=1 | same | present |

40 rows over both views; **MISMATCH 4**, and all four are the
dynamic-container lifetime residue of §5 R1, which is PRE-79 and untouched
here.

Three readings in that table are compared cells that cost a measurement
each: `vpiAutomatic` is § packageVarAutomaticIsDataDeclShape26's rule
(keyword spellings automatic, a bare type IDENTIFIER not) **plus a NET
KEYWORD always static**, because `compileNetDeclaration` calls
`sig->setStatic()` unconditionally; `vpiSize` is 1 in the def view and the
FLATTENED element count in the elaborated one; and `vpiSigned` rides the
HOLDER, not the element — golden's `int u_vint [0:1]` reads `vpiSigned:1` on
the `array_var` and nothing on its `int_var` child.

### 3d. `z7_pkgimpclone` — THE IMPORT CLONE CARRIES THE SIGNAL VECTOR TOO (LAW A)

| row | golden | pre-79 | patched |
|---|---|---|---|
| `pb` lists `pa`'s `a_net` (a wildcard import) | `logic_net` nt=1 | absent | golden's |
| `pb` lists `pa`'s `a_uarr` | `array_var` | absent | golden's |
| `pb` lists `pa`'s `a_struct` / `a_var` | `logic_net` / `logic_var` | same | unchanged |
| `pc` lists BOTH hops (`pc`->`pb`->`pa`) | all six | the two variables | golden's |
| `pe` (an EXPLICIT `import pa::a_net`) | `a_net` + `a_var` + `e_net` | **absent** | **absent** |

40 rows, MISMATCH 4 — the explicit-import clone, which is a PRE-79 gap for
the variable half as well (§5 R2) and is left measured, not half-built.

### 3e. `z8_pkgqual` — THE QUALIFIERS AND THE NEGATIVES

`const` / `var` / `static` / plain / `wire` in front of the SAME struct
typedef all read `logic_net` in golden: the qualifier is not the
discriminator, the typespec is. `const logic` / `var logic` / `static logic`
keep their pre-79 readings exactly. And GOLDEN WRITES NOTHING for a typedef
alone, a `parameter`, a `localparam`, a subroutine, an `event` — neither do
we, before or after. 28 rows, MISMATCH 0.

### 3f. `z6_pkgconv` — **THE CONVERTING ARM** (`cmp_rc 255 -> 0`)

Every other arm on this ground carries a module that IMPORTS the package, so
its residue mixes the package listing with the module hoist. This one does
not: `dut` never imports `pz`, so the package's own listing is the whole
difference. It exercises LAW A (a net, a `wand`, a `supply0`, an unpacked
array), LAW B (an all-logic struct against an `int`-member struct) and
LAW C (a one-hop typedef, a struct, a plain `logic`) and returns 0.

### 3g. THE CONTROLS, AND THE ARM LEDGER

```
arm                gold_only/ours_only[pris]  gold_only/ours_only[patch]
b1_bindvis         9/1                     9/1                   
b2_homes           86/10                   86/10                 
b5_walkedge        136/3                   136/3                 
g1_netkinds        40/2                    40/2                  
g2_importshapes    137/4                   63/4                  
g4_edges           274/89                  274/89                
v6_ifacepkg        142/5                   142/5                 
v9_hops            17/3                    17/3                  
va_netstructkinds  153/25                  39/23                 
vb_unpackedfaces   1373/25                 623/35                
vc_netkw           395/4                   31/10                 
vd_structmem       67/56                   43/33                 
ve_ifacenet        416/9                   197/11                
vf_collide         97/10                   24/10                 
vg_constauto       200/33                  174/32                
vh_arrelem         1092/52                 382/72                
vi_defnt           151/59                  129/63                
w8_unitname        45/16                   45/16                 
xb_arrnet          35/41                   35/41                 
xc_impw            747/13                  747/13                
xe_impkind         187/12                  42/14                 
xg_genimp          19/1                    19/1                  
xi_genimp2         19/1                    19/1                  
xj_twoinst         13/1                    13/1                  
xk_order           12/1                    12/1                  
xl_impclimb        474/6                   474/6                 
y1_pkgnetkind      462/12                  50/20                 
y2_pkgvarkind      297/44                  124/44                
y3_impshape        433/28                  67/106                
y4_bindreach       344/11                  57/19                 
y5_defnettype      555/33                  52/39                 
y6_hoistconv       41/5                    41/5                  
z3_pkgtdnet        1391/70                 572/86                
z4_pkgdefnt        1155/43                 96/87                 
z5_pkgunpacked     2430/77                 867/106               
z6_pkgconv         349/7                   13/1                  
z7_pkgimpclone     1289/7                  330/7                 
z8_pkgqual         361/71                  335/68
```

**EIGHT ARMS CONVERT** (`cmp_rc 255 -> 0`): `va_netstructkinds`,
`vd_structmem`, `vf_collide`, `xe_impkind`, `y1_pkgnetkind`,
`y2_pkgvarkind`, `y4_bindreach` and the new `z6_pkgconv`. **ZERO ARMS
REGRESS**: every arm that was `cmp_rc 0` at the base (`b1_bindvis`,
`g1_netkinds`, `v9_hops`, `w8_unitname`, `xj_twoinst`, `xl_impclimb`,
`y6_hoistconv`) is still 0.

**THE OBJECT-BLOCK REGRESSION SCAN IS CLEAN.** For all 38 arms x 6 dump
sections, every top-level object block was span-normalised and diffed
golden-vs-ours on BOTH binaries (`shapecmp79.py`):
**228 sections scanned, 0 blocks that matched golden on the pristine binary
differ on the patched one, and 353 blocks that differed on the pristine one
now match.** Nothing pristine-right becomes patched-wrong anywhere in this
grid.

**THE RISING `ours_only` COUNTS, ATTRIBUTED.** Several arms' `ours_only`
rises while `gold_only` collapses. Every added line is one of three classes,
counted line by line: a NESTED PRINT of a typespec the new entry refers to
(the dump prints a shared typespec once per referrer — arena positions under
an owner, not top-level entries of a compared vector), a `vpiFullName`
string, or a `vpiRange`/`constant` child of a newly written `array_var`.
None of them is a compared field that golden lacks — which the seven
conversions and the 0-newly-wrong block scan both confirm independently.

---

## 4. THE THREE LAWS, GATED (question 4)

All three are in `src/ParamEmit.cpp` (`__LINE__`-sensitive, and its 30
`__LINE__` uses feed ONE stderr debug print behind `dbg9` — `wb.why()`,
:31459 — and reach no database byte); `include/UhdmExporter.h` carries one
member declaration. **`src/ModuleEmit.cpp` is not touched at all** — it is
the sister pass's ground.

**§ caPkgListingIsTheSignalVector79** (`R11U79_PKGNET_OFF=1`) — the
package's own listing is the package's SIGNAL VECTOR: a `SymbolKind::Net`
member rides the walk at its own source slot, in the package's own listing
and in every wildcard-import clone of it, and a FIXED-SIZE unpacked array
variable is written as `makeVar_`'s `array_var` (the element type's own
variable kind in `vpiReg`, the declarator's ranges, `vpiArrayType` 1,
`vpiRandType` 1, `vpiVisibility` 1, size 1 in the def view and FLATTENED in
the elaborated one, the element's signedness on the HOLDER). Fences: that
listing and nothing else — an EXPLICIT import clone is still not built
(measured, `z7`), the dynamic containers keep their own road untouched, and
a shape with no written declarator dimension is declined rather than
mis-shaped.

**§ caPkgListingKindTable79** (`R11U79_KIND_OFF=1`) — which vector an entry
lands in is `elabSignal`'s two decisions, not our written-type rule: the
declaration, then the typespec OVERRIDING it, read on the ELEMENT for an
unpacked array. It also mints the two variable kinds the pre-79 road could
not build — a `struct_var` for any struct the member test drops (packed or
unpacked, typedef'd or anonymous) and a `union_var` for an ANONYMOUS packed
union — and stamps a NET-declared holder STATIC. Fences: the PACKAGE's own
listing only (`stampTsInstance`, this function's standing discriminator
between its two callers), so the importing MODULE's hoist keeps the answer
§ caImportedPkgHoistKindTable77 and r11v77's `ArraySkip` measured into it;
the shapes we already agree on never reach the new arms.

**§ caPkgListingNetTypeIsPerView79** (`R11U79_NT_OFF=1`) — the package net's
`vpiNetType` is the DEF view's net keyword (displaced by a non-`logic`
builtin data-type keyword, which then answers the table itself) and the ELAB
view's one-hop SIMPLE_TYPEDEF rewrite on top of it, replacing "vpiNet (36)
on every entry, elaborated view only".

**`R11U79_OFF=1` reproduces the pristine database BYTE FOR BYTE on all 38
arms** (0 differing lines, path-normalised and sorted, on every one). Each
switch drops its own law alone; the full ledger is `SWITCHES.r11u79.txt`.
Read as distance from PRISTINE / from PATCHED:

| switch | arms it returns to PRISTINE | what it leaves |
|---|---|---|
| `PKGNET_OFF` | `g2_importshapes`, `vc_netkw`, `y1_pkgnetkind`, `y3_impshape` — the four whose whole difference was the nets | LAWS B and C still acting on the entries that remain (up to 1548 lines from the patched reading) |
| `KIND_OFF` | none outright; `vi_defnt` 4 and `vd_structmem` 5 lines from pristine — the two whose whole difference was the kind table | the nets and array_vars LAW A lists (up to 482 lines from patched) |
| `NT_OFF` | none; `vg_constauto` and `z8_pkgqual` 27 lines from pristine | every arm within 1-56 lines of the PATCHED reading |

Sixteen arms have no package data declaration at all and read
`vs_pristine=0 vs_patched=0` under every switch, which is the ledger's own
in-place control: a switch that moved one of them would be reaching outside
this ground.

**The residuals are named, not rounded:** every line by which an `NT_OFF`
run differs from the patched database is a `|vpiNetType:` line and nothing
else — `z4` 35/21, `y5` 16/11, `y1` 14/7, `z5` 6/5, `z3` 1/10 (patched-only /
NT_OFF-only) — which is LAW C's whole byte surface.

---

## 5. THE CENSUS AND THE PREDICTION (question 5)

`pkgcen79.py` replays the harness's OWN discovery and its OWN slang argv
(`verify_golden.discover_*` / `translate` / `location_args`), runs the frozen
patched binary with `R11U79_CELLDBG=1`, and writes one row per entry that
reaches the package listing — the DECLINED ones included. Every invocation's
rc is recorded. The four slang-fenced names are read off `canaudit.sh`'s own
`FENCED=` line and never dispatched.

TWO trace rows, and between them no listed object is unnamed:

* `R11U79LIST name=… view=… sym=… pre=… now=… vk=… nt=… ntpre=… SAME|MOVED`
  — one per entry of the source-ordered walk, carrying BOTH answers (the
  pre-79 road's and this pass's) computed in the same run on the same
  binary, so a corpus mover is named a priori without a second binary.
* `R11U79VAR name=… own=… sym=… vk=… predrop=… SAME|MOVED` — one per entry
  reaching `emitPackageVar`, which closes the blind spot: a HOISTED
  out-of-body constructor local and every entry of an import clone's flush
  never pass the walk's lambda, and those are exactly the UVM family's 33.

`MOVED` OVER-predicts by design (a `StructVar`/`UnionVar`/`ArrayVar` mint
counts as moved even where the pre-79 road happened to build the same
class): a predicted mover that does not move costs nothing, an unpredicted
one convicts the law.

| corpus | arms | LIST rows | LIST MOVED | VAR rows | VAR MOVED |
|---|---|---|---|---|---|
| uhdm2rtlil | 871 x 2 modes | 0 | 0 | 0 | 0 |
| surelog | 798 x 2 modes | 660 | **0** | 1118 | **0** |

* **uhdm2rtlil: the package listing is EMPTY in the whole corpus, both
  modes.** 1742 invocations, not one package-listing entry. Checked against
  the corpus text and not only the trace: 161 of the 871 tests declare a
  package, and every one of those packages holds typedefs and parameters
  only — `BitsCallOnStructMember`, `UnionParameter`, `StructPackedOutput`
  and `cs_registers` were read by hand, source and trace side by side.
* **surelog: 660 + 1118 rows over exactly thirteen (test, mode)
  populations over seven tests** — `ApbSlave`, `BuildUVMPkg`, `MiniAmiq`, `PackageNet`,
  `Scoreboard`, `SeqDriver`, `SimpleUVM` — **and every single one reads
  SAME**.

**THE CENSUS ZERO HAS A POSITIVE CONTROL** (a census zero needs one). The
SAME trace on the grid arms, where the moved entries are known by name,
separates present-and-moved from present-and-unmoved exactly as the corpus
reading does (`POSCTRL.r11u79.txt`, `pcen79.sh`):

```
arm                    list listMOVED    var varMOVED
b1_bindvis                0      0      0      0
b2_homes                  0      0      0      0
b5_walkedge               0      0      0      0
g1_netkinds               0      0      0      0
g2_importshapes          10      2     11      0
g4_edges                  2      0      4      0
v6_ifacepkg               2      0      3      0
v9_hops                   0      0      0      0
va_netstructkinds        12     11      8      4
vb_unpackedfaces         14     14     10     10
vc_netkw                 10     10      0      0
vd_structmem             10      8      6      6
ve_ifacenet               8      5      5      2
vf_collide                6      3      3      0
vg_constauto              8      5      0      0
vh_arrelem               20     20     10     10
vi_defnt                 28      4     29      0
w8_unitname               2      0      3      0
xb_arrnet                 0      0      0      0
xc_impw                   0      0      0      0
xe_impkind                8      3      8      2
xg_genimp                 4      0      4      0
xi_genimp2                4      0      6      0
xj_twoinst                0      0      0      0
xk_order                  0      0      0      0
xl_impclimb               2      0      3      0
y1_pkgnetkind            16     16      3      0
y2_pkgvarkind            26      8     28      4
y3_impshape              16     12      8      0
y4_bindreach             10      7      5      2
y5_defnettype            38     19     19      0
y6_hoistconv             16      0     18      0
z3_pkgtdnet              36     24     15      8
z4_pkgdefnt              62     41     25      0
z5_pkgunpacked           40     34     31     22
z6_pkgconv               20     11     10      4
z7_pkgimpclone           36     23     18      6
z8_pkgqual               30      7     27      0
```

`y6_hoistconv` reads 16 LIST rows and 18 VAR rows with **0 MOVED** — present
and unmoved, which is precisely the reading the corpus gives, arrived at on
an arm that has a package listing in it.

**THE ONE BYTE THE `MOVED` FLAG DOES NOT COVER, AND WHY IT IS ZERO TOO.**
LAW A also gives a net a TYPESPEC where the pre-79 listing left it untyped,
and that branch fires only when the typedef registry lookup finds nothing —
i.e. for an ANONYMOUS packed aggregate, since every TypeAlias-spelled net
already resolved through `pkgTopTypedefTs`/`typedefTs`. It is not a class
change, so the trace reads it SAME. It is nevertheless ZERO in the corpus,
checked by source: the seven package-carrying tests contain **no anonymous
packed struct or union declaration at all** (a `^\s*(struct|union) packed`
scan over every `.sv`/`.svh`/`.v` of all seven returns 0 hits), and
`PackageNet`'s one entry is `typedef logic [1:0] word; word v;`, whose
typedef is in the registry and whose typespec is therefore the pre-79 one
unchanged.

**PREDICTED MOVER SET, WRITTEN BEFORE THE PATCHED SWEEPS: NOTHING. Zero
databases in either corpus, either mode.** Not "probably nothing" — the
instrument names every package-listing entry the corpora contain and reads
every one of them SAME.

---

## 6. THE GATES (question 6)

### 6a. Build and binaries

```
pristine  c56e3f2c141ee7e9a6bb41c9d4e38f8c   == main tree @15ff66f6 == the OPS pin
patched   67a6075c5d761d74bd4a28b0d0cf0b6b
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
                 pristine              patched
default    CMP_EQUAL 474 / NE 9    CMP_EQUAL 474 / NE 9
testflags  CMP_EQUAL 469 / NE 8    CMP_EQUAL 469 / NE 8
```

the committed baseline exactly, on both binaries, and every other status
bucket identical too (5+5 DEFERRED, 285/286 SLANG_REJECT, 25/23
SURELOG_FAIL, 3 NO_DATABASE, 1 NO_UHDM, 1 TIMEOUT, 2 UNTRANSLATABLE).

**Whole-row join vs `results/golden_surelog.csv`: 3 of 1596 rows differ,
every one ENVIRONMENT, and every one present on the PRISTINE binary too.**

```
Earlgrey_0_1/default     committed  CMP_EQUAL,,,differ   ours  CMP_EQUAL,,,
LowMemLib/testflags      SURELOG_FAIL "... Creating log file <WORKDIR>/..."
LowMemPkg/testflags      SURELOG_FAIL "... Creating log file <WORKDIR>/..."
```

— the documented `uhdm-dump` timeout draw blanking the DUMP COLUMN under
load (the STATUS stays `CMP_EQUAL`; the DATABASE byte pins of §6e are the
real gate), and the workdir path carried inside a `SURELOG_FAIL` string. The
pristine sweep draws FOUR: the same two `LowMem*` strings and BOTH Earlgrey
rows, which is the draw and not a difference between the binaries — all four
Earlgrey rows are `CMP_EQUAL` on both.

**Whole-row join vs this pass's OWN pristine sweep: 3 of 1596 rows differ** —
the two `LowMem*` path strings and the Earlgrey_0_1/testflags DUMP-column
side of that one draw. No status changes anywhere.

**`byteverify SELFCHECK=1`, patched vs this pass's own pristine workdir:**

```
databases: patched=960 pristine=960
PATH_SETS_IDENTICAL (960 paths)
MOVER ./default/MiniAmiq-544c7f61/slang.uhdm
MOVER ./default/Scoreboard-59431470/slang.uhdm
MOVER ./default/SeqDriver-32af76aa/slang.uhdm
MOVER ./testflags/MiniAmiq-544c7f61/slang.uhdm
MOVER ./testflags/SeqDriver-32af76aa/slang.uhdm
MOVERS: 5 / 960
SELFCHECK (every file vs one fixed file): 959 / 960 flagged
```

**FIVE MOVERS, ALL UVM FAMILY, AND EVERY ONE IS THE DOCUMENTED
PRISTINE-NONDETERMINISM CLASS — attributed, not assumed.** Each database's
order-blind, path-normalised, id-stripped whole-dump diff:

```
default/MiniAmiq      4 lines   UINT/vpiDecompile 992  <-> 0
default/Scoreboard    0 lines   (the order draw — order-blind identical)
default/SeqDriver     4 lines   UINT/vpiDecompile 1294 <-> 1249
testflags/MiniAmiq    4 lines   UINT/vpiDecompile 1267 <-> 1233
testflags/SeqDriver   4 lines   UINT/vpiDecompile 0    <-> 1453
```

Four are EXACTLY FOUR LINES and every one of those four is a `UINT:<n>` +
`vpiDecompile:<n>` pair — the UVM macro-buffer line-number class the
standing ops note describes — and the fifth is the documented ZERO-line
order draw. **No `vpiNetType`, no listing line, no package object and no
hoisted object among them** — not one line of any of this pass's three laws.
Their rows stay `CMP_EQUAL`: `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`,
`SimpleUVM` `CMP_EQUAL` in both modes on the committed baseline, on the
pristine binary and on the patched one, and `Scoreboard`
`CMP_EQUAL`/`SLANG_REJECT` unchanged.

**AN INDEPENDENT CONFIRMATION OF THE CENSUS SITS IN THIS LIST.** The census
names seven tests that carry a package listing at all; `ApbSlave`,
`PackageNet`, `SimpleUVM` and `BuildUVMPkg` are four of them and **not
movers at all**, while the three databases that did move are the three the
nondeterminism class names. The listing population and the mover population
do not intersect.

`rowheads.sh` on the patched workdir: **16 measured, 15 of them
`0 0 cmp rc=0`**; `Rggen/default` reads `64 1 cmp rc=255`, which is its
committed `CMP_NOTEQUAL` row unchanged. `SKIP-NOFILE` 2
(`Scoreboard/testflags` + `Rggen/testflags`, expected), `UNKNOWN-NAME` 0.
`ApbSlave` and `PackageNet` — the two non-UVM package-listing carriers —
were added to the list and read `0 0 cmp rc=0` in both modes.

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
canaries.sh  surelog, patched vs committed         ok=51 changed=1 absent=0
                                                    (Earlgrey_0_1/default,
                                                     the DUMP-column draw;
                                                     STATUS CMP_EQUAL on all four)
canaries.sh  surelog, patched vs OWN PRISTINE      ok=51 changed=1 absent=0
                                                    (Earlgrey_0_1/testflags,
                                                     the other side of that draw)
canaries.sh  u2r,     patched vs committed gate    ok=8  changed=0 absent=0
ctcan2       surelog  EXPECT_UNKNOWN=1             ok=58 changed=0  PASS
ctcan2       u2r      EXPECT_UNKNOWN=6             ok=1  changed=0  PASS
canaudit.sh  canaries.sh ctcan2.sh                 audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS
```

No fenced name appears anywhere in the patch outside `canaudit.sh`'s own
`FENCED=` line: the four names grep to **0** occurrences in
`git diff 15ff66f6` over the production surface and to **0 files** in this
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
  macro-buffer line-number class by its own order-blind diff (four of
  exactly four `UINT`/`vpiDecompile` lines, one of zero), none of them a
  line of any law here, and every one of those rows still `CMP_EQUAL`.
* Grid: 38 arms, **8 CONVERT**, **0 REGRESS**, 228 object-block sections
  scanned with **0 newly-wrong blocks**, and the package section is golden's
  on 36 of 38 arms — **498 golden rows against 494 of ours, 8 disagreeing
  cells, both groups a named PRE-79 residue**.
* `results/*.csv` untouched — read only, never written.

---

## 7. RESIDUES (ranked)

1. **A package DYNAMIC container's `vpiAutomatic` is the container kind's,
   not the declaration shape's.** Golden reads `logic [7:0] u_dyn []` and
   `u_q [$]` as `vpiAutomatic:1` (`z5_pkgunpacked`, both views) where
   `emitPkgArrayVar`'s standing rule — "vpiAutomatic only on the ASSOCIATIVE
   one at PACKAGE scope" — writes none. § packageVarAutomaticIsDataDeclShape26
   explains BOTH readings (the measurement that rule was written from used a
   NamedType-spelled element, which is static; a KEYWORD-spelled one is
   automatic), so the fix is to route that builder through § 26 as well. It
   is PRE-79, it is four cells, and it was left alone on purpose: it is the
   one place on this ground whose population is the UVM family's own
   queues and associative arrays. **R0.**

2. **The EXPLICIT-import clone is not built at all** — golden's `pe`, which
   writes `import pa::a_net; import pa::a_var;`, lists both named items plus
   its own net, and we list only its own (`z7_pkgimpclone`, 4 cells, both
   views). This is a PRE-79 gap for the VARIABLE half too, so LAW A did not
   widen to it: the wildcard road was measured, the explicit one was not.

3. **A package's `Typespecs` listing misses an UNPACKED-ARRAY typedef** —
   golden lists `pu::arr_t` as an `array_typespec` among `vb_unpackedfaces`'
   three `vpiTypedef` entries and we list two. PRE-79 and identical on both
   binaries; it is the typedef listing, not the data listing.

4. **A TWO-HOP typedef's net typespec is an `unsupported_typespec` in
   golden and a `logic_typespec` in ours** (`y5_defnettype` `d_tdtd`,
   `z4_pkgdefnt` `d_wtd2`). PRE-79 and unchanged here; it is now the head of
   `z4` and `y5` because the package-listing head above it is gone.

5. The pass-77/r11v77 residue set stands: the five unpacked element
   spellings the MODULE-side hoist builder declines, `var logic`'s
   over-broad module-side `vpiNetType:36`, and the gen-scope namesake
   collision binding.

**R0 — NEXT.** Residue 1 is one rule in one builder and its golden table is
already committed here (`grid/z5_pkgunpacked`, rows `u_dyn`/`u_q`/`u_as`).
It is the last disagreeing cell of the package listing that is not an
explicit-import one.

---

## 8. HOW TO RE-RUN

```bash
GRID=<this dir>/grid bash rr79.sh <binary> <tag>        # golden + ours + cmp per arm, every rc recorded
GRID=<this dir>/grid bash sw79.sh <binary> <tag>        # the switch ledger: distance from pristine/patched
GRID=<this dir>/grid python3 score79.py pris patch      # gold-only / ours-only dump distance per arm
GRID=<this dir>/grid bash pcen79.sh <patched-binary>    # the census POSITIVE CONTROL, arm by arm
python3 pkgscore79.py <gold.dump> <ours.dump> [--all]   # the PACKAGE-SECTION scorer, one row per entry
DIFF=1 python3 lister79.py <gold.dump> <ours.dump>      # the whole-listing shape lister
python3 shapecmp79.py <gold.dump> <ours.dump> <section> # the object-block comparator (span-normalised)
python3 pkgcen79.py <repo> <corpus> <binary> <out.tsv>  # the site census, declined entries included
```

`rr79.sh` regenerates the golden with the pinned Surelog per arm per tag and
records `golden_rc` and `ours_rc` for every arm; an arm whose compile fails
teaches error recovery, not golden. No corpus test is ever dispatched from
here — every arm is its own `dut.sv`, and the four slang-fenced names appear
in no driver.
