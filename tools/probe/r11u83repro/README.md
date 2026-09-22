# r11u83 — the interface body has the module's two faces: the imported
# package's holders are hoisted into its elaborated listing, and its own
# module-level `cont_assign` is folded by the same writer

Base commit `14ff07cc`. Pristine binary md5
`33f341dfa44841c1223ce59eeaa071b6` — built in this pass's own worktree,
`-j 2`, md5 taken separately, and **byte-identical to the main tree's
`build/slang-uhdm` at `14ff07cc` and to the OPS pin**, compared not assumed.
Patched binary md5 `e91e921c1d296ad7fa2b9f7010aa4da1`. Both frozen
`chmod 555` at immutable paths before any sweep; every `cmds.txt` audited by
binary PATH.

Two laws, two switches, each droppable alone. `results/*.csv` untouched —
read only, never written. `src/ParamEmit.cpp` untouched (it is
`__LINE__`-sensitive and the sister pass's ground); the whole production diff
is `src/ModuleEmit.cpp` + one declaration in `include/UhdmExporter.h`.

---

## 1. THE WITNESSES, RE-MEASURED AT THE BASE (question 1)

`GRID.pris.r11u83.txt`. Every arm compiles on both sides, both rc values
recorded; the goldens are regenerated per arm by the pinned Surelog v1.87.

```
w1_iface      golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=30
g11_iface     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=26
```

### 1a. `w1_iface` — LAW A's witness, through this pass's shape lister

The lister prints one row per `vpiVariables`/`vpiNet`/`vpiArrayNet` slot at
ANY depth, keyed on the DECLARATION SPAN, which is what separates a hoisted
imported copy (the package's own line) from the body's own namesake:

```
    section          owner           slot          kind        name    span          GOLD OURS
!!  uhdmtopModules   work@dut.u_if   vpiNet        logic_net   c_net   5:15-5:20      1    0
!!  uhdmtopModules   work@dut.u_if   vpiVariables  logic_var   c_var   6:15-6:20      1    0
!!  uhdmtopModules   work@dut.u_if   vpiNet        logic_net   o       9:36-9:37      1    0
!!  uhdmtopModules   work@dut.u_if   vpiVariables  logic_var   o       9:36-9:37      0    1
```

Lines 5 and 6 are package `pc`'s own declarations — the copies
`importPackage` hoists into the interface — and the interface's own namesakes
at lines 11/12 are present on both sides. The consequence is the cell
binding, and it is exactly what r11v82's residue 1 predicted:

```
row                          GOLDEN binds                                OURS
work@dut.u_if.gi[0].c_net    logic_net (work@dut.u_if.c_net)  line 5:15  line 11:16
work@dut.u_if.gi[0].c_var    logic_var (work@dut.u_if.c_var)  line 6:15  line 12:16
```

Pass 80's lookup already CHOOSES golden's object here (`take=1` on both
cells); `resolve82` then found no emitted object and `shadowed82` correctly
handed the cell back. **The defect was upstream in the hoist, and the fourth
row above is a separate residue (the interface's own output PORT is a net on
golden and a variable for us) that this pass does not touch — see §8 R3.**

### 1b. `g11_iface` — LAW B's witness

```
LHS (golden):  constant: , line:6:31, endln:6:32  |vpiDecompile:6 |vpiSize:32 |UINT:6 |vpiConstType:9
                 |vpiParent: cont_assign: , line:12:10, endln:12:21
RHS (ours):    hier_path: (C.n), line:12:18, endln:12:21
```

`assign i_top = C.n;` written in the INTERFACE BODY at module level. The
generate-scope twin one line down (`gi.i_gen`) already folds on both binaries
— that is r11u69's § caStructParamGenScopeSubst69, whose home `emitGenScopes`
an interface DOES reach. Only the body's own module-level listing did not.

### 1c. `InterfaceModPort`'s own database at the base

The OPS STATUS canary is an interface test, so it was measured as a database
BEFORE anything was written: `59a365f3ce2c` in both modes on the pristine
binary, the OPS pin verbatim, and the same on the patched one (§7e).

---

## 2. THE DECODE (question 2)

### 2a. LAW A — the producer materialises interface-body holders on the
### SAME road as module-body ones, and it is one road, not two

`CompileHelper::importPackage`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:171-189`) copies the
imported package's variables and its whole SIGNAL VECTOR into the IMPORTING
component's own registries. Its caller for an INTERFACE declaration is
`CompileModule::collectObjects_`
(`src/DesignCompile/CompileModule.cpp:579/603` and `:1066/1087`) — the same
function as for a module, because Surelog files both under
`ModuleDefinition`.

The elaborated listing is then built by
`NetlistElaboration::elab_ports_nets_`'s pass 1 over `comp->getSignals()`
(`NetlistElaboration.cpp:2810-2811`, `:3035-3052`), and **that function's own
component-type switch NAMES `paInterface_declaration`**
(`NetlistElaboration.cpp:2807`) beside `paModule_declaration`. An interface
instance reaches it through `elab_interface_`
(`NetlistElaboration.cpp:1847-1849`), which calls `elab_ports_nets_` twice
with the interface's `ModuleDefinition`. So the entries, their vector order
and `elabSignal`'s kind table are the module home's, unchanged.

Our exporter had the module half (r11u77's § caImportedPkgNetHoist77 +
§ caImportedPkgHoistKindTable77, r11u79's unpacked builder) and not the
interface half: `emitInterfaceInstance` listed `collectNetOrder(body)` alone.
The def view was already right — `emitInterfaceDef` calls
`emitImportedPkgVarNets` and the index-aligned `makeIfaceDefArrayNet225`
road — which is why this pass touches the ELAB half only.

### 2b. LAW B — the interface's elaborated `cont_assign` listing is
### `writeCont_assign`'s, the same writer the module's is

`NetlistElaboration::elaborate_`
(`~/git-repos/Surelog/src/DesignCompile/NetlistElaboration.cpp:762-772`)
pushes the DEFINITION component's `getContAssigns()` into the INSTANCE's own
netlist — for an interface instance exactly as for a module one.
`UhdmWriter::writeElabInterface`
(`src/DesignCompile/UhdmWriter.cpp:4296-4303`) then hands that vector to
`UhdmWriter::writeCont_assign` (`:2090`), which is the identical call
`writeElabModule` makes at `:4146`. Inside it, a cell whose Rhs REDUCES to a
constant is CLONED and the constant swapped in (`:2246-2277`), so the
elaborated interface view holds a fresh `cont_assign` carrying the reduced
value while the def view keeps the written expression.

We shared the def object through instead, except for two shapes the emitter
already knew differ per view (a package-enum-const Rhs ref and a plain
constant Rhs). A struct-parameter member read is the THIRD.

---

## 3. THE GOLDEN GRID (question 3)

22 arms, `grid/`, every one its own `dut.sv`, every golden regenerated by the
pinned Surelog v1.87, every arm `golden_rc=0 ours_rc=0` on both binaries
(`GRID.pris.r11u83.txt` / `GRID.patch.r11u83.txt`). No corpus test is
dispatched from this directory.

### 3a. LAW A — imported KINDS x interface SHAPES

| arm | what it holds | GOLDEN | pristine | patched |
|---|---|---|---|---|
| `i1_ifkinds` | ten imported kinds (wire/scalar/tri/wire-struct nets; plain, struct, int-member struct, enum, int, packed-array variables), each with a gen-scope namesake cell | listed + all ten cells bound | **none listed, none bound** | golden's, `cmp_rc 255 -> 0` |
| `i6_ifarray` | a package unpacked array (`array_var`), an unpacked array of an all-logic struct (`array_net`), an unpacked NET array, a flat control | listed in the right slots | **absent** | golden's, `cmp_rc 255 -> 0` |
| `i5_twoinst` | the same interface instantiated TWICE | one holder per instance | absent in both | golden's, `cmp_rc 255 -> 0` |
| `i4_portview` | the interface's HOME view and a reference-style PORT view (`work@dut.u_sub.p`) | port view lists the hoisted VARIABLE and **no `vpiNet` at all** | absent in both views | golden's, `cmp_rc 255 -> 0` |
| `i2_ifimpshape` | wildcard, EXPLICIT item, its unnamed sibling, TRANSITIVE hop, a package nobody imports, a `$unit` net | the four reachable copies listed; `c_unread`, `z_net`, `unitnet` **not listed** | none listed | the listing is golden's, row for row (§3c) |
| `i7_dblgen` / `i9_dblownnet` | the interface handed to a PLAIN GENERIC interface port (the doubling shape) | hoisted vars listed FOUR times (doubled) | absent | golden's four |
| `w1_iface` | the pass-80 collide witness | hoisted copies listed, cells bound to them | absent, cells on the own namesakes | golden's (§3c residue) |

**`i4_portview` settles the port-view question by measurement, not by
analogy.** Golden's `work@dut.u_sub.p` lists `[k_var (the hoisted copy),
i_own]` and carries no `vpiNet`, while the home view `work@dut.u_if` lists
those two variables AND the hoisted `k_net` — which is the same shape our
port view already had for the interface's OWN declarations. So the port view
runs the same builder with a THROWAWAY net slot: one rule, two slots, and the
net half is withheld by where its output goes rather than by a second
decision. The first cut of this pass fenced the port view out entirely and
`i4_portview` convicted it; the arm is the reason the fence reads the way it
does.

**`i7_dblgen` + `i9_dblownnet` separate the doubling.** `i7` alone could not
say whether golden's doubled `k_net` was a property of the HOIST; `i9` adds an
interface's OWN net to the same shape and golden doubles THAT too, so the net
doubling is a pre-existing gap in our `dblVars9` law and not something LAW A
introduced (§8 R4). LAW A's own entries double correctly because the builder
runs BEFORE the doubling, which is the producer's order (`netlist->variables()`
already carries the hoisted group when the doubling happens).

### 3b. LAW B — the interface body's `cont_assign`, shape by shape

| arm | row | written | GOLDEN | pristine | patched |
|---|---|---|---|---|---|
| `g11_iface` | `i_top` | `assign i_top = C.n;` | `UINT:6` sz 32 | `hier_path` | golden's, `cmp_rc 255 -> 0` |
| `j1_ifcafold` | `f_mem` | `C.n` | `UINT:6` | shared def `hier_path` | golden's |
| `j1_ifcafold` | `f_wide` | `C.m` | `8'hAA` | shared | golden's |
| `j1_ifcafold` | `f_nest` | `D.inner.n` | `UINT:11` **`vpiSize:64`** | shared | `UINT:11` `vpiSize:32` — **NOT golden's** [r11v83 correction] |
| `j1_ifcafold` | `f_plain` | a plain `int` param | folds to `UINT:5` | shared | **unchanged** (§8 R5) |
| `j1_ifcafold` | `f_const` / `f_enum` / `f_own` | a literal / a package enum const / a net read | the landed shapes | the landed shapes | **unchanged** |
| `j2_iftwoinst` | `u_a.i_top` / `u_b.i_top` | the same interface twice, DIFFERENT overrides | `UINT:6` and `UINT:9` | ONE shared def object in both views | **both golden's, per instance** |
| `j2_iftwoinst` | `u_m.q` (a MODULE twin in the same arm) | `C.n` at module level | `UINT:6` | already golden's | unchanged — the in-arm control |
| `j3_ifcaselect` | `whole` | whole-name Lhs | `UINT:6` | shared | golden's, `cmp_rc 255 -> 0` |
| `j3_ifcaselect` | `bitsel[0]` / `partsel[3:0]` / `arr[0]` | SELECT Lhs | declined by golden too | shared | **declined** — the landed Lhs fence holds |

`j3_ifcaselect` is the arm that tests the fence and converts in the same
breath: one whole-name row takes, three select rows decline, and the arm goes
`cmp_rc 255 -> 0`.

### 3c. What the grid leaves standing, named

* `i2_ifimpshape` keeps ONE head after the patch and it is **not a listing
  row** — the listing is golden's row for row (`gold rows 34, ours rows 34,
  0 differing`). It is the gen-scope cell for `a_net`, a net reached through
  a TRANSITIVE import (`pb` imports `pa`), which golden binds to the hoisted
  copy and we leave unbound. **Arm `i3_transmod` is the control that
  attributes it**: the MODULE home has the byte-identical head, and it is
  byte-identical PRISTINE and PATCHED. The transitive hop's namesake bind is
  a pre-existing, home-independent limit of `nsImportHome75` (§8 R1).
* `w1_iface` keeps ONE cell pair: golden's interface OUTPUT PORT `o` is a
  `logic_net` and ours is a `logic_var`. Byte-identical on both binaries, and
  the hoist rows behind it are all gone (§8 R3).

### 3d. THE MODULE-SIDE CONTROLS

`c2_kinds` and `vf_collide` (pass 80), `y1_pkgnetkind`, `y2_pkgvarkind` and
`y6_hoistconv` (pass 77/79), `i8_modtwin` (the module twin of `i1_ifkinds`,
written for this pass) and `i3_transmod` are **BYTE-IDENTICAL between the two
binaries** — `NONE=0` in the switch ledger's first column, with both laws ON.
That is the proof that lifting the module hoist block out into the shared
builder changed nothing: the module home's bytes are that block's, moved and
not changed.

`s5_ifacepath`, `v5_ifaceport` and `v6_ifacepkg` (pass 82's interface arms)
are byte-identical on both binaries too, with their own pre-existing heads.

---

## 4. THE TWO LAWS, GATED (question 4)

### § caIfaceImportedPkgHoist83 — LAW A (`R11U83_IFHOIST_OFF=1`)

> A package signal imported into an INTERFACE body is materialised in that
> interface's ELABORATED listing exactly as one imported into a module body
> is — same entries, same vector order, same kind table — because the
> producer builds both from `comp->getSignals()` through one
> `elab_ports_nets_` whose component switch names
> `paInterface_declaration`.

The module-side block is LIFTED OUT into `UhdmExporter::emitHoistedPkgListing83`
and both homes call it, exactly as r11u69 lifted `caStructParamSetter55` out
when its second home landed, so the two homes cannot drift. Nothing in the
builder is new; the interface call is. **The moved body keeps its original
indentation on purpose**, so the diff reads as a pure move: a line-by-line
join of the diff's removed and added sides leaves exactly FIVE lines
unmatched — the block's own `{`, the three `sigOrder.emplace_back(...)` calls
that became `if (sigOrder) sigOrder->emplace_back(...)`, and the
`if (!hanets77->empty())` that gained braces for the lazy array-net slot.
Nothing else in that block changed, and the switch ledger's `NONE=0` on every
module arm is the independent confirmation.

**The throwaway net slot mints no orphan.** A `Make…Vec` is a WRITE, so the
port view's discarded net vector was checked and not assumed: `i4_portview`'s
`ours_only` dump distance is **0 both before and after** the patch, and the
shape lister finds no `logic_net` of the hoisted name anywhere the dump does
not also place one on golden.

Fences, each measured:
* the PORT view takes the VARIABLES and not the NETS (`i4_portview`),
  expressed as a throwaway net slot rather than a second decision;
* the builder runs BEFORE the generic-port doubling, which is the producer's
  order (`i7_dblgen`, `i9_dblownnet`);
* the import-shape filters are r11u77's, unchanged and unwidened: a package
  nobody imports, an unnamed sibling of an explicit import and a `$unit` name
  are not consulted (`i2_ifimpshape`) — GOLDEN WRITES NOTHING ON A MISS;
* **no binding code is touched.** The holders are filed in `netMap`, and
  pass 80's `resolve82` reads `netMap` first, so the gen-scope namesake
  lookup (§ caNamesakeImportCopyShadows82 + § caNamesakeStructIsProducerNet82)
  serves the cells with NO NEW LOOKUP CODE — proved by construction (the
  patch adds nothing to `genCaLhsNamesake74` or to `resolve82`) and by arm
  (`w1_iface`'s two cells, `i1_ifkinds`'s ten, `i4_portview`'s two).

### § caIfaceBodyCaFolds83 — LAW B (`R11U83_IFCAFOLD_OFF=1`)

> [r11v83 addendum] The clone this law forces MUST also carry the cell's
> DRIVE FIELDS — `VpiNetDeclAssign`, `VpiStrength0`, `VpiStrength1` and
> `Delay`, all of which `cont_assign::Compare` reads BEFORE the Rhs.  Sharing
> the def object carried them for free; forcing the clone dropped them, which
> verifier arm `b14_cadelay` convicted (the head MOVED to golden's `#5` delay
> constant).  § caIfaceBodyCaFoldKeepsDriveFields83v copies them, gated to
> this law's own cells; see `tools/probe/r11v83repro/README.md` §3.

> The interface BODY's own module-level `cont_assign` listing is
> `writeCont_assign`'s, so a cell whose Rhs is a constant-valued read of a
> struct parameter's member is CLONED per elaborated view and carries the
> folded value — the same rule § caStructParamPatternSubst55 landed at the
> module level and § caStructParamGenScopeSubst69 landed in generate scopes.

It runs through the SAME decision (`caStructParamSetter55`, W1/W2 + the cast
fence + § caSubstBailStopsMemberStamp68v) and the SAME emitter
(`emitCaStructParamSubst55`, § caSubstLeafEncReduceTable56's encoding table,
`adjustSize`'s width), not a second copy of them. The clone this site
already builds for the enum-const and plain-constant shapes IS the object
golden writes; only its Rhs had to be the folded value, and the emitter runs
AFTER the Lhs is built because it sizes the constant against the Lhs
declaration.

Fences:
* the landed Lhs fence rides along unchanged — a select Lhs declines
  (`j3_ifcaselect`, three rows);
* the AST side is INDEX-ALIGNED AND SELF-CHECKED. The def listing was built
  by `emitContAssigns` walking `caOrder` (`body.members()` in source order,
  gen-region entries rotated to the end, a non-`Assignment` form skipped);
  this rebuilds that same order over the elaborated body and uses it ONLY
  when the two lists are the same length. A length mismatch declines the law
  outright rather than read another cell's expression;
* a declined emission leaves the shared Rhs exactly as the branch already set
  it — GOLDEN WRITES NOTHING ON A MISS, and neither does this.

`R11U83_OFF=1` drops both. `R11U83_CELLDBG=1` traces every cell that reaches
either site with the laws ON, DECLINED ones included — LAW A names every
entry the collector returns, the ones its kind table then skips as well, and
LAW B names every cell of the interface's listing with the predicate's answer
beside it. That is what lets ONE run of one binary predict the mover set
without a second binary. (Stated exactly: each trace sits inside its own
law's switch, so a census must be run with the switch UNSET, which is how
§6's was run; it is the emission, not the decision, that the trace precedes.)

---

## 5. THE SWITCH LEDGER

`SWITCHES.r11u83.txt` — differing dump lines against the PRISTINE binary's own
dump of the same arm (0 = byte-identical):

```
arm             NONE  R11U83_OFF  IFHOIST_OFF  IFCAFOLD_OFF
c2_kinds           0      0            0             0
g11_iface         16      0           16             0
i1_ifkinds       270      0            0           270
i2_ifimpshape    145      0            0           145
i3_transmod        0      0            0             0
i4_portview      113      0            0           113
i5_twoinst       150      0            0           150
i6_ifarray       213      0            0           213
i7_dblgen        115      0            0           115
i8_modtwin         0      0            0             0
i9_dblownnet     115      0            0           115
j1_ifcafold       48      0           48             0
j2_iftwoinst      32      0           32             0
j3_ifcaselect     16      0           16             0
s5_ifacepath       0      0            0             0
v5_ifaceport       0      0            0             0
v6_ifacepkg        0      0            0             0
vf_collide         0      0            0             0
w1_iface          75      0            0            75
y1_pkgnetkind      0      0            0             0
y2_pkgvarkind      0      0            0             0
y6_hoistconv       0      0            0             0
```

**`R11U83_OFF=1` reproduces the PRISTINE database BYTE FOR BYTE on all 22
arms**, and each single switch returns exactly its own law's arms to pristine
and leaves every other arm at the patched reading. There is no residual line:
the two laws share no byte.

---

## 6. THE CENSUS AND ITS POSITIVE CONTROL (question 5)

`CENSUS.r11u83.txt`, both corpora, both modes, replaying the harness's own
discovery (`verify_golden.discover_*`) and its own slang argument vector
(`translate` / `location_args`), every invocation's rc recorded. The four
slang-fenced names are read off `canaudit.sh`'s own `FENCED=` line and never
dispatched.

| corpus | test x mode arms | trace rows | `R11U74BIND` | `R11U83IFHOIST` | `R11U83IFCA` | `sps=1` |
|---|---|---|---|---|---|---|
| uhdm2rtlil | 1742 | 3928 | 3892 | **0** | **32** | **0** |
| surelog | 1573 | 12580 | 12574 | **0** | **4** | **0** |

* **LAW A has ZERO sites in either corpus, both modes.** Not one interface in
  either corpus imports a package that declares data of any kind, so the
  hoisted interface listing cannot touch a byte of either.
* **LAW B has 36 LIVE SITES and takes NONE of them.** Every one of the 32
  uhdm2rtlil cells and all 4 surelog cells reads `sps=0`. The rows are quoted
  verbatim in `CENSUS.r11u83.txt`, with their `plainLhs` and their Rhs kind:
  `InterfaceAssign` and `InterfaceProcess` write a literal, `iface_*` and
  `jeras_tcb_gpio` write an operation or a plain signal read, and
  `GenForStructParamBound` writes a constant onto a select Lhs. No corpus
  interface writes a constant-valued read of a struct parameter's member at
  its body's module level.
* **THE ZEROS ARE ZEROS INSIDE A LIVE POPULATION** — the genvar_loop_decl_3
  precedent. 3892 (uhdm2rtlil) and 12574 (surelog) `R11U74BIND` rows reach the
  very lookup LAW A's holders feed, and 36 rows reach LAW B's site.
* rc is recorded on every invocation and nothing is dropped: uhdm2rtlil
  5392/131/12 plus 3 rc=-11, surelog 12571/900/578/32/12/4. The 900 surelog
  rc=-11 rows SEGFAULT, which the harness itself records as `SLANG_REJECT`;
  an arm whose compile fails teaches error recovery, not golden.

**PREDICTED MOVER SET, WRITTEN FROM THE CENSUS BEFORE THE PATCHED SWEEPS WERE
READ: NOTHING. Zero databases in either corpus, either mode.**

**POSITIVE CONTROL** (`POSCTRL.r11u83.txt`, the same trace, the same binary,
the 22 grid arms) — the instrument sees both sites and both outcomes:

```
arm              ifhoist  net=1  portview=1   ifca  sps=1
i1_ifkinds         10       4        0          0     0
i2_ifimpshape       4       3        0          0     0
i4_portview         4       2        2          0     0
i5_twoinst          4       2        0          0     0
i6_ifarray          4       1        0          0     0
i7_dblgen           4       2        2          0     0
i9_dblownnet        4       2        2          0     0
w1_iface            2       1        0          1     0
g11_iface           0       0        0          1     1
j1_ifcafold         0       0        0          7     3
j2_iftwoinst        0       0        0          2     2
j3_ifcaselect       0       0        0          4     1
s5_ifacepath        0       0        0          1     0
v6_ifacepkg         0       0        0          1     0
(the module arms c2_kinds, i3_transmod, i8_modtwin, y1, y2, y6, vf_collide,
 v5_ifaceport: all zeros — no interface import, no interface body cell)
```

36 hoisted entries over 8 arms, 17 of them NETS and 6 in PORT views; 17 cells
reach LAW B's site and 7 take it, so **10 DECLINED rows** are named too
(`j1`'s four controls, `j3`'s three select-Lhs rows, and `s5`/`v6`/`w1`'s
cells). `j3_ifcaselect` reads `ifca=4 sps=1` — the fence, counted.

---

## 7. THE GATES (question 6)

### 7a. Build and binaries

```
pristine  33f341dfa44841c1223ce59eeaa071b6   == main tree @14ff07cc == the OPS pin
patched   e91e921c1d296ad7fa2b9f7010aa4da1
```

Built `-j 2`, md5s taken separately, both frozen `chmod 555` at immutable
paths before any sweep.

**THE PATCH IS REPRODUCIBLE, CHECKED NOT ASSUMED.** The deliverable was
applied with `git apply -3` to a FRESH `14ff07cc` worktree (rc 0, no
conflict marker in either production file), the applied `src/ModuleEmit.cpp`
and `include/UhdmExporter.h` `cmp` byte-identical to this worktree's, the
whole `tools/probe/r11u83repro/` tree identical, and that tree REBUILT to the
same patched md5 `e91e921c1d296ad7fa2b9f7010aa4da1`.

### 7b. Goldens

```
pristine   PASS 23   FAIL 0
patched    PASS 23   FAIL 0
/bin/false PASS 0    FAIL 23        (negative control)
```

### 7c. uhdm2rtlil, both modes, both binaries

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
                                                (and 0 on the pristine sweep too)
```

**`byteverify SELFCHECK=1`, patched vs this pass's own pristine workdir:**

```
databases: patched=1608 pristine=1608
PATH_SETS_IDENTICAL (1608 paths)
MOVERS: 0 / 1608
SELFCHECK (every file vs one fixed file): 1607 / 1608 flagged
```

**MOVERS 0 — the census's predicted set exactly**, with a 1607/1608 negative
control, so the zero is a reading and not a broken instrument.

### 7d. surelog, `--mode both`, both binaries

```
                 pristine          patched
default    CMP_EQUAL 474 / NE 9   CMP_EQUAL 474 / NE 9
testflags  CMP_EQUAL 469 / NE 8   CMP_EQUAL 469 / NE 8
```

the committed baseline exactly, on both binaries, and **every other status
bucket identical too** (5 DEFERRED, 285/286 SLANG_REJECT, 25/23 SURELOG_FAIL,
3 NO_DATABASE, 1 NO_UHDM, 1 TIMEOUT, 2 UNTRANSLATABLE).

**Whole-row join vs `results/golden_surelog.csv`: 4 of 1596 rows differ,
every one ENVIRONMENT, and every one present on the PRISTINE binary too — the
SAME four rows, quoted:**

```
Earlgrey_0_1/default     committed  CMP_EQUAL,,,differ   ours  CMP_EQUAL,,,
Earlgrey_0_1/testflags   committed  CMP_EQUAL,,,differ   ours  CMP_EQUAL,,,
LowMemLib/testflags      SURELOG_FAIL "... Creating log file <WORKDIR>/..."
LowMemPkg/testflags      SURELOG_FAIL "... Creating log file <WORKDIR>/..."
```

— the documented `uhdm-dump` timeout draw blanking the DUMP COLUMN under load
(this sweep shared the machine with another pass's integration sweep and
three concurrent `YosysOpenSparc` dumps; the STATUS stays `CMP_EQUAL` on all
four Earlgrey rows and the DATABASE byte pins of §7e are the real gate), and
the workdir path carried inside a `SURELOG_FAIL` string.

**Whole-row join vs this pass's OWN pristine sweep: 2 of 1596 rows differ**,
both of them the `LowMem*` workdir path strings. **No status changes
anywhere, and the Earlgrey dump-column draw fell identically on both
binaries.**

**`byteverify SELFCHECK=1`, patched vs this pass's own pristine workdir:**

```
databases: patched=960 pristine=960
PATH_SETS_IDENTICAL (960 paths)
MOVER ./default/SeqDriver-32af76aa/slang.uhdm
MOVER ./testflags/MiniAmiq-544c7f61/slang.uhdm
MOVER ./testflags/SeqDriver-32af76aa/slang.uhdm
MOVERS: 3 / 960
SELFCHECK (every file vs one fixed file): 959 / 960 flagged
```

**THREE MOVERS, ALL UVM FAMILY, AND EVERY ONE IS THE DOCUMENTED
PRISTINE-NONDETERMINISM CLASS — attributed, not assumed.** Each database's
order-blind, path-normalised, id-stripped whole-dump diff is **EXACTLY FOUR
LINES, and every one of them a `UINT:<n>` + `vpiDecompile:<n>` pair**:

```
default/SeqDriver     UINT:0    <-> UINT:684    vpiDecompile:0    <-> :684
testflags/MiniAmiq    UINT:942  <-> UINT:0      vpiDecompile:942  <-> :0
testflags/SeqDriver   UINT:1211 <-> UINT:0      vpiDecompile:1211 <-> :0
```

That is the UVM macro-buffer line-number class exactly as the standing ops
note describes it. **No `vpiNetType`, no `vpiActual`, no hoisted object, no
`cont_assign` and no listing line among them** — not one line of either law
here, and neither law has a site in this corpus at all (§6). Their rows stay
`CMP_EQUAL`: `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM` `CMP_EQUAL`
in both modes on the committed baseline, on the pristine binary and on the
patched one, and `Scoreboard` `CMP_EQUAL`/`SLANG_REJECT` unchanged.

`rowheads.sh` on the patched workdir: **12 measured, 11 of them `0 0 cmp
rc=0`**; `Rggen/default` reads `64 1 cmp rc=255`, which is its committed
`CMP_NOTEQUAL` row unchanged. `SKIP-NOFILE` 2 (`Scoreboard/testflags` +
`Rggen/testflags`, expected), `UNKNOWN-NAME` 0.

### 7e. Canaries

**Canary DATABASE byte pins, patched vs this pass's own pristine — ALL SAME,
and every one the OPS pin verbatim:**

```
SVSwitch            default/testflags  4842211c4030   (OPS HARD pin)
YosysVerx           default/testflags  6ccda350c24a   (OPS HARD pin)
InterfaceModPort    default/testflags  59a365f3ce2c   (OPS pin — and an
                                                       INTERFACE test, so it
                                                       was watched BYTE for
                                                       BYTE, not by status)
YosysOldOr          default/testflags  d68e0796d62c
BlackParrotComplex  default e3e354129d5a  testflags 73a10e8217e5
Earlgrey_0_1        default 8bdf25272e08  testflags 59d0ee6d10c3   (OPS pins)
```

**CSV canaries:**

```
canaries.sh  u2r,     patched vs committed gate    ok=8  changed=0 absent=0
ctcan2       u2r      EXPECT_UNKNOWN=6             ok=1  changed=0  PASS
canaudit.sh  canaries.sh ctcan2.sh                 audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS
canaries.sh  surelog, patched vs OWN PRISTINE      ok=52 changed=0 absent=0
canaries.sh  surelog, patched vs committed         ok=50 changed=2 absent=0
                                                    (both Earlgrey_0_1, the
                                                     DUMP-column draw; STATUS
                                                     CMP_EQUAL on all four)
ctcan2       surelog  EXPECT_UNKNOWN=1             ok=58 changed=0  PASS
```

### 7f. Binary path audit

```
u2r pristine       1742 / 1742 cmds.txt name <PRISTINE-BIN>   other-tree binaries: 0
u2r patched        1742 / 1742 cmds.txt name <PATCHED-BIN>    other-tree binaries: 0
surelog pristine   1531 / 1581 cmds.txt name <PRISTINE-BIN>   other-tree binaries: 0
surelog patched    1531 / 1581 cmds.txt name <PATCHED-BIN>    other-tree binaries: 0
```

The other 50 are Surelog-side failures that never invoked an exporter (their
`cmds.txt` carries the `surelog:` line alone).

```
```

No `cmds.txt` in any of the four workdirs names a main-tree or another
worktree's binary.

### 7g. Score

**MOVED-WRONG 0. AWAY-GOLDEN 0.** Both corpora, both mode columns.

* **Grid, PER CELL** (`cellmw83.py`, the arbiter — r11v82's lesson that a
  per-BLOCK scan is blind below the block): 22 arms, 836 cells,
  **CONVERTED 38, MOVED-WRONG 1, AWAY-GOLDEN 0**. The owner-free cross-check
  reads CONVERTED 33 / MOVED-WRONG 1 / AWAY 0 on the same dumps.
  [r11v83 correction: the scorer prints MOVED-WRONG=1 under both keyings;
  the headline above read 0 while the very next sentence named the row.]
  The scorer's ONE flagged row is named, not rounded: `i6_ifarray`'s
  `v_sarr.v_sarr` element net, where golden's span is `7:15-7:27` and ours
  `7:15-7:21`. A SPAN is not a compared field, `uhdm-cmp` returns 0 on that
  arm, and arm `y2_pkgvarkind` shows the module home carrying the identical
  `+6` difference byte-identically on BOTH binaries — it is pass 79's
  pre-existing reading, carried by the shared builder (§8 R6).
* **Grid, by arm**: **6 CONVERT** (`g11_iface`, `i1_ifkinds`, `i4_portview`,
  `i5_twoinst`, `i6_ifarray`, `j3_ifcaselect` — all `cmp_rc 255 -> 0`),
  **0 REGRESS**: every arm that was `cmp_rc 0` at the base (`c2_kinds`,
  `i8_modtwin`, `vf_collide`, `y1_pkgnetkind`, `y2_pkgvarkind`,
  `y6_hoistconv`) is still 0, and every one of them is byte-identical between
  the binaries.
* **Arm distance** (`SCORE.r11u83.txt`, order-blind `gold_only/ours_only`):
  `gold_only` FALLS on every interface arm and rises on none —
  `i1` 315→48, `i2` 175→30, `i4` 127→14, `i5` 170→20, `i6` 257→51,
  `i7` 177→76, `i9` 214→113, `w1` 273→202, `g11` 24→8, `j1` 394→348,
  `j2` 79→48, `j3` 86→71. The rising `ours_only` counts are attributed line
  by line and, on this grid, only ONE is a compared field [r11v83 correction:
  `j1_ifcafold`'s `|vpiSize:32` on the `f_nest` cell above; on the verifier
  arm `b6_ifgen` a `|vpiDecompile:` also rises, r11v83 §4.2]. The rest are
  nested `logic_typespec` /
  `struct_typespec` print positions under an owner (`i1` +3, `i6` +7,
  `j1` +2, `j2` +1, `j3` +1) and, on `i7`/`i9` (+14 each), the generic-port
  view's per-view mint whose whole surface is `vpiFullName:work@dut.u_g.g.*`
  strings where golden shares the home view's objects — and with LAW A the
  two views' object COUNTS now agree with golden's (§8 R4).
* `results/*.csv` untouched — read only, never written. `src/ParamEmit.cpp`
  untouched. The four slang-fenced names grep to **0** occurrences in
  `git diff 14ff07cc` over the production surface and to **0 files** in this
  directory outside `canaudit.sh`'s own `FENCED=` line.

---

## 8. RESIDUES (ranked)

1. **THE TRANSITIVE HOP'S NAMESAKE BIND** (`i2_ifimpshape` `a_net`,
   `i3_transmod` `a_net`). A package net that reaches the importer only
   through ANOTHER package's wildcard import is now LISTED correctly in both
   homes and the gen-scope cell still does not bind it; golden binds the
   hoisted copy. `nsImportHome75` walks the scope's own import items and does
   not follow the transitive splice that `collectImportedPkgVars` already
   models. **Measured in BOTH homes and byte-identical pristine and patched
   on the module one**, so it is a pre-existing limit of pass 75's lookup,
   not a consequence of this pass. **R0 — one law in one function, and it is
   the last head on `i2_ifimpshape`.**
2. **THE ELABORATED INTERFACE `cont_assign` Lhs BINDING ACROSS TWO
   INSTANCES** (`j2_iftwoinst`). With the values now folded per view, the
   arm's head is a binding: golden's SECOND view binds its Lhs ref to the
   FIRST view's variable (`work@dut.u_b`'s cell -> `logic_var
   (work@dut.u_a.i_top)`) and leaves the first view's own unbound; we leave
   both unbound. Pristine left both unbound too — the shared def object
   carries no binding, and the def view is byte-identical golden's on both
   binaries — so **nothing became "no object" that was an object before**
   (pass 80's rule). It is `writeCont_assign`'s `bindVariable(mod, m, ...)`
   resolving against the primary instance, the same quirk the landed
   `pendingModportExprRefs` note records, and closing it needs its own grid
   (three instances, interface arrays, a modport view).
3. **AN INTERFACE'S OWN OUTPUT PORT IS A NET ON GOLDEN AND A VARIABLE FOR US**
   (`w1_iface` `o`, the arm's only remaining cell pair). A module's output
   port is already a `logic_net` on both sides; the interface elab view lists
   it under `vpiVariables`. Byte-identical on both binaries, untouched here,
   and it is what keeps `w1_iface` at `cmp_rc 255` although every hoist row
   converted.
4. **THE GENERIC-PORT DOUBLING DOES NOT DOUBLE THE NETS** (`i7_dblgen`,
   `i9_dblownnet`). `dblVars9` doubles `Variables()` and golden doubles
   `Nets()` too — measured on an interface's OWN net (`i9`), so it is
   pre-existing and independent of LAW A. Beside it, golden's generic-port
   VIEW shares the HOME view's objects (their `vpiFullName` is the home's)
   where we mint per-view copies; `vpiFullName` is not a compared field, and
   with LAW A the two views' object COUNTS now agree.
5. **A PLAIN PARAMETER READ IN AN INTERFACE BODY DOES NOT FOLD**
   (`j1_ifcafold` `f_plain`): golden's elab view carries `UINT:5` where we
   share the def ref. That is the module-level `typedParamRhs` rule's
   interface home — the same shape of gap LAW B closed for the struct-member
   read, on a different rule, and it was deliberately left alone here so the
   pass lands one decision per law.
6. **The hoisted unpacked-array-of-struct ELEMENT NET's END COLUMN**
   (`i6_ifarray` `v_sarr.v_sarr`: golden `7:15-7:27`, ours `7:15-7:21`). It
   is the MODULE home's pre-existing pass-79 reading carried faithfully by the
   shared builder — arm `y2_pkgvarkind` shows the identical `+6` on the module
   side, byte-identical on both binaries. Spans are not compared fields and
   `uhdm-cmp` returns 0 on `i6_ifarray`; it is the one cell the per-cell
   scorer flags, and §3c/§7g name it rather than round it away.
7. The pass-82 interface residues stand unmoved and byte-identical:
   `s5_ifacepath`/`v5_ifaceport`'s `typespec_member` default constant,
   `v6_ifacepkg`'s gen-block naming, and r11u75's `func_call` leftover
   argument.

---

## 9. HOW TO RE-RUN

```bash
GRID=<this dir>/grid bash rr83.sh <binary> <tag>        # every arm, both rc values
GRID=<this dir>/grid bash sw83.sh <pristine> <patched>  # the switch ledger
GRID=<this dir>/grid bash score83.sh pris patch         # order-blind arm distance
GRID=<this dir>/grid python3 cellmw83.py pris patch     # PER-CELL moved-wrong (the arbiter)
GRID=<this dir>/grid NOOWNER=1 python3 cellmw83.py pris patch   # its cross-check
DIFF=1 python3 lister83.py <gold.dump> <ours.dump>      # the resolving SHAPE lister
python3 cellcen83.py <repo> <corpus> <binary> out.tsv   # the site census
```

No corpus test is dispatched from this directory; every arm is its own
`dut.sv`, and the four slang-fenced names appear in no file here but
`canaudit.sh`'s own `FENCED=` line.
