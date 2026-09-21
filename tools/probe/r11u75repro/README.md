# r11u75 — the gen-scope namesake binding reaches the NET store and the
# IMPORT's holder, and the member fold reaches a base declared in the block

Base commit `2f728c97`. Pristine binary md5 `ca45217f2ac9f7766fc232a8be0ee319`
— built in this pass's own worktree, `-j 2`, md5 taken separately, and
**byte-identical to the main tree's `build/slang-uhdm` at `2f728c97` and to the
OPS pin**, compared not assumed. Patched binary md5
`3bcf6c65315faa0e2615d0e46373b915`. Both frozen `chmod 555` at immutable paths
before any sweep; every `cmds.txt` audited by binary PATH.

An earlier patched binary (`eeac388802ff23ca952ee50e6152938d`) was DISCARDED
and every gate re-run: the switch ledger of §4 caught a switch-interaction bug
in it (`R11U75_GLPFOLD_OFF=1` did not revert its own law and nothing else) and
the fix changed the code, so the sweeps it had passed no longer described the
delivered binary. The ON-path behaviour of the two is identical — the grid
listing and the arm scores below are the same on both — but a gate is a gate on
the binary that ships.

Five laws, five switches, each droppable alone. `results/*.csv` untouched.

---

## 1. THE FOUR WITNESSES, RE-MEASURED AT THE BASE (question 1)

Every arm compiles on both sides (`golden_rc=0 ours_rc=0`); the goldens are
regenerated per arm by the pinned Surelog v1.87.

```
v9_hops          golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=15
v6_ifacepkg      golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=87
w8_unitname      golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=18
v7_foldshape     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=29
```

**`v9_hops`, ALL CELLS, through this pass's resolving lister** (`calist75.py`,
one row per `cont_assign`, the Lhs ref's `vpiActual` printed verbatim) — the
whole difference between golden and pristine is ONE cell, and it is `n3`:

```
    section          lhs_fullname                   GOLDEN actual                            OURS actual
!!  uhdmtopModules   work@dut.L1[0].L2.L3.n3        logic_net (work@dut.L1[0].L2.n3)         -
```

`m3` (a VARIABLE namesake one scope out), `m2` and `m1` (two and three scopes
out, golden-unbound) and `L5.u1` (an unnamed enclosing block) all agree — pass
73's one-hop law stands exactly as landed, and the NET is the only miss.

**`w8_unitname`**, the arm's ONE head, is the width:

```
LHS: constant id:362 |vpiDecompile:300 |vpiSize:16 |UINT:300 |vpiConstType:9
RHS: constant id:190 |vpiDecompile:300 |vpiSize:32 |UINT:300 |vpiConstType:9
```

and its binding half sits behind it: golden `work@dut.gp.pkgname` ->
`logic_var (work@dut.pkgname), line:7:16` (line 7 is **package `q`'s own
declaration**), ours none.

**`v6_ifacepkg`**: `work@dut.gm[0].pkns` -> golden `logic_var
(work@dut.pkns), line:5:16`, ours none. Same law, the WILDCARD spelling.

**`v7_foldshape`** `gl_loc`: golden `constant
BIN:00000000000000000000000100000000 vpiSize:32`, ours `hier_path (GLOC.n)` —
and, on the SAME arm, `twice_a`/`twice_b` carry an `vpiActual` golden does not
have although their Rhs already matches. Two residues, not one.

---

## 2. THE DECODE (question 2)

### 2a. LAW A — where a generate scope's NET objects live at emission time

`emitGenScopes`' own member loop mints the block's `logic_net` and files it in
**two** maps, and only one of them unconditionally:

```
src/ModuleEmit.cpp:18608  genScopeNets[&gm] = sn;     // struct_net: BOTH maps
src/ModuleEmit.cpp:18609  netMap[&gm] = sn;
src/ModuleEmit.cpp:18622  netMap[&gm] = an3;          // unpacked ARRAY net: netMap only
src/ModuleEmit.cpp:18640  netMap[&gm] = n;            // plain net: ONLY when caVar
src/ModuleEmit.cpp:18703  genScopeNets[&gm] = n;      // plain net: ALWAYS
```

So a plain `wire` declared in a generate scope is in `genScopeNets` and not in
`netMap` unless it is the net-ified-`reg` arm. Pass 73's bind site resolves
through `netMap` alone, which is why its walk FOUND `n3` and stored nothing —
`R11U74BIND … name=n3 ns=n3 bound=0` on the pristine binary. `genScopeNets` is
already the map the landed `bindGenLocal9` fallback resolves through
(`ModuleEmit.cpp:22398`), so consulting it mints nothing and keys nothing new.

### 2b. LAW B — golden's holder for an imported package name

**Golden's binding target is a MODULE-LEVEL object, and we already emit it.**
Arm `g2_importshapes`, golden: `work@dut.gw[0].w_ns` binds `logic_var
(work@dut.w_ns), line:9:16` — the MODULE's name, the PACKAGE's location. That
is Surelog's `CompileHelper::importPackage` copying the imported package's
signal vector into the importing scope's registries; our exporter builds the
same object in `emitImportedPkgVarNets` (def view) and in the
`collectImportedPkgVars` hoist inside `emitInstance` (elab view,
`ModuleEmit.cpp:10239`), and keys it in `topNets` **under the package
variable's symbol** — and `topNets` IS the `netMap` `emitGenScopes` is handed
(`ModuleEmit.cpp:13230`). The object exists; only the NAME fails to resolve.

Why it fails: `slang::ast::Scope::find` is documented "won't return anything
weird like … imported symbols" and returns `nullptr` outright for an
`ExplicitImport` (`slang/source/ast/Scope.cpp:559-562`); a WILDCARD import puts
no `nameMap` entry there at all. Both spellings are therefore invisible to
`q->find(nm)` in `genCaSubstAdjustW71` and to `w74->find(nm74)` in
`genCaLhsNamesake74` — the two walks this pass extends, and the only two.

### 2c. LAW C — why a generate-scope localparam base never reaches the fold

`drainCaAsmMemberSlice` resolves its base through `elabParamPa`
(`ParamEmit.cpp:3670`), and that map has exactly one writer,
`ParamEmit.cpp:7092`, gated on `topView` inside `emitParameters`. A localparam
declared in a generate scope is emitted by `emitGenScopes`' own parameter loop
(`ModuleEmit.cpp:17940-18070`), which never reaches it, so the base resolves to
nothing and the cell keeps its `hier_path`.

**AND THE ENCODING IS NOT THERE EITHER — measured, and it changes the fix.**
The drain slices the digits out of the base's elaborated `param_assign` Rhs and
declines unless that Rhs is the assembled `BIN` of exactly the struct's packed
width (the producer's own bail signal, grid `d14` `kid_ovr`). Our gen-scope
localparam carries neither shape. On arm `g3_lpbase`, `work@dut.gf[0].G_LOC`:

```
golden  |BIN:0000000000000000000000010000000011000011   param_assign Rhs
        |vpiDecompile:40'b0000000000000000000000010000000011000011  vpiSize:40
ours    |UINT:65731                                     param_assign Rhs
        |vpiDecompile:65731                             vpiSize:40
```

The VALUE is the same (0x100C3) and only the ENCODING differs — a residue of
the generate-scope parameter listing, recorded in §7 and NOT this law's ground.
So this pass takes the digits from the value itself and leaves that drain, its
map and its bail rule untouched.

---

## 3. THE GOLDEN GRID (question 3)

19 arms, `golden_rc=0 ours_rc=0` on every one; 11 are the pass-73/71 CONTROLS
carried in verbatim. The five new arms:

### 3a. `g1_netkinds` — NET KINDS x SCOPES (LAW A)

One enclosing gen scope `G1`, one nested `G2`, every target a gen-local
variable, and the module-body rows (`H1`) as the in-arm control.

| namesake, one scope out | golden | pristine | patched |
|---|---|---|---|
| `wire [31:0] e_plain` | `logic_net work@dut.G1[0].e_plain` | **none** | golden's |
| `wire e_scalar` (SCALAR) | `logic_net … e_scalar` | **none** | golden's |
| `wire [31:0] e_nda = 32'd7` (net-decl-assign) | `logic_net … e_nda` | **none** | golden's |
| `reg [31:0] e_reg` (net-ified reg) | `logic_net … e_reg` | golden's | golden's |
| `logic [31:0] e_var` (a VARIABLE) | `logic_var … e_var` | golden's | golden's |
| `mb_plain`, TWO scopes out | **none** | none | none |
| `pin_i` (a module PORT), two out | **none** | none | none |
| a gen-local NET as the TARGET | **none** | none | none |
| `H1[0].mb_plain` / `H1[0].pin_i`, the instance body one hop out | bound | bound | bound |

`cmp_rc 255 -> 0`. **CONVERTS**, and its ONE head was `LHS: logic_net
(work@dut.G1[0].e_plain) / RHS: <null>`.

### 3b. `g4_edges` — THE FENCE, and the edges of B and C

| row | golden | pristine | patched |
|---|---|---|---|
| `sn_ns`, a STRUCT net one scope out | `struct_net work@dut.E1[0].sn_ns` | golden's | golden's |
| `an_ns`, an UNPACKED-ARRAY net one scope out | **none** | `array_net (work@dut.E1[0].an_ns)` **WRONG** | **none** |
| `un_ns`, a COMPILATION-UNIT `import pun::*` | **none** | none | none |
| `F1.f_if`, gen-scope base in a gen-IF arm | folded `BIN:…01100000` | `hier_path` | golden's |
| `F2.f_case`, gen-scope base in a gen-CASE arm | folded `BIN:…01110000` | `hier_path` | golden's |

The array-net row is a **pristine over-bind this pass corrects**: pass 73's
walk reaches it through `netMap`'s array-net entry and writes an object golden
does not have. The `$unit` row is the boundary that keeps LAW B honest — a
compilation-unit wildcard import materialises the module's holder listing
TWICE and is still **not** a namesake home, so the law reads the import items
of the ONE scope it is handed and never climbs.

### 3c. `g2_importshapes` — IMPORT SHAPE BY IMPORT SHAPE (LAW B, binding)

| row | golden | pristine | patched |
|---|---|---|---|
| `w_ns` — `import pw::*`, a 16-bit package var | `logic_var work@dut.w_ns` | **none** | golden's |
| `w_same` — wildcard, same width as the target | `logic_var work@dut.w_same` | **none** | golden's |
| `w_net` — wildcard, a package **NET** | `logic_net work@dut.w_net` | **none** | none — **residue** |
| `W_PAR` — wildcard, a package **PARAMETER** | golden's Lhs is not a ref at all | — | unchanged |
| `e_ns` — `import pe::e_ns` (EXPLICIT) | `logic_var work@dut.e_ns` | **none** | golden's |
| `u_ns` — a package NOBODY imports | **none** | none | none |
| `unitname` — a `$unit` name | **none** | none | none |

The `w_net` row is honest about its own limit: the trace reads
`R11U74BIND … name=w_net ns=w_net bound=0` — the NAME resolves and the object
does not exist, because our hoist lists package VARIABLES only. Golden binds
it; we decline rather than invent, and §7 records it.

### 3d. `g3_lpbase` — WHERE THE BASE IS DECLARED (LAW C)

Only the base's declaring scope varies; the module-level row is the control.

| row | golden | pristine | patched |
|---|---|---|---|
| `t_mod` — a MODULE localparam base, module level | folded | folded | folded |
| `g_mod` — a MODULE base read from a gen scope | folded, **no Lhs actual** | folded, own-local actual | golden's |
| `g_loc` — a GEN-SCOPE localparam base | `BIN:…100000000 sz=32` | `hier_path` | golden's |
| `g_ovr` — per-iteration `build(256 + i*8)` | `gf[0]`=256, `gf[1]`=264 | `hier_path` | golden's, per iteration |
| `g_t` — the OTHER member | `BIN:11000011 sz=8` | `hier_path` | golden's |
| `g_narrow` — an 8-bit Lhs, no namesake | `sz=32`, member width stands | `hier_path` | golden's |
| `g_sh` — an operation AROUND the select | `UINT:257 sz=64` | `sz=32` | unchanged — r11u69's R1 |
| `gn.n_loc` — base one scope OUT, read from a nested block | folded | `hier_path` | golden's |
| `gn.n_own` — base in THIS scope | folded 512 | `hier_path` | golden's |

After the patch the arm's whole `cont_assign` listing matches golden except
`g_sh`, which is unmoved and not this pass's. `v7_foldshape`'s `cont_assign`
listing matches golden **completely**.

### 3f. `g5_glpwidth` — LAW C's SIZE RULE, which `g3_lpbase` cannot ask

Every `g3` fold cell reads `lhsw=0`: its target has no namesake, so
`bindVariable` answers nothing and `adjustSize` matches no branch. This arm
gives every target a module-body namesake and varies the namesake's WIDTH
against the member KIND — `a2_fbwidths`' question, asked again for a base
declared in the generate scope.

| member | namesake width | golden | pristine | patched |
|---|---|---|---|---|
| `int unsigned n` (32) | 8 | `BIN` 32 digits, **sz=8** — value NOT truncated | `hier_path` | golden's |
| `int unsigned n` (32) | 64 | sz=32 | `hier_path` | golden's |
| `logic [39:0] w` | 8 | `BIN:00010111` — value AND digits truncated to the LOW 8, sz=8 | `hier_path` | golden's |
| `logic [39:0] w` | 64 | untouched, sz=40 | `hier_path` | golden's |
| `byte b` (8) | 32 | `BIN:01011011` sz=8 — no branch matches, member width stands | `hier_path` | golden's |
| `int unsigned n`, NO namesake | — | sz=32 and **no Lhs actual** | `hier_path` + own-local actual | golden's |

**All six cells match golden after the patch** — the arm's whole `cont_assign`
listing is golden's, and what is left is residue 3's `func_call` head.
`R11U75_GLPFOLD_OFF=1` returns the arm to the pristine database byte for byte
(`delta 0`), which is the cleanest single reading of LAW C in the grid.

### 3e. The CONTROLS

`a1_fbgenkind`, `a3_fbfence`, `b1_bindvis`, `b2_homes`, `b3_rhskind`,
`b4_nonamesake`, `b5_walkedge` (pass 73's own arms) and `v1_nearest`,
`v2_kindns`, `v4_lhsshape` (the verifier's) are **BYTE-IDENTICAL** between the
pristine and patched binaries — 0 differing dump lines each, path-normalised.
`v9_hops` and `w8_unitname` move only on their named cells. No arm's ours-only
dump-line count rises anywhere in the grid:

```
arm                gold_only/ours_only[pris]  gold_only/ours_only[patch]
a1_fbgenkind       785/22                  785/22                
a3_fbfence         1440/215                1440/215              
b1_bindvis         9/1                     9/1                   
b2_homes           86/10                   86/10                 
b3_rhskind         94/138                  94/138                
b4_nonamesake      109/144                 109/144               
b5_walkedge        136/3                   136/3                 
g1_netkinds        46/2                    40/2                  
g2_importshapes    215/4                   209/4                 
g3_lpbase          2394/302                2266/134              
g4_edges           294/117                 274/89                
g5_glpwidth        977/91                  914/20                
v1_nearest         16/4                    16/4                  
v2_kindns          28/6                    28/6                  
v4_lhsshape        137/30                  137/30                
v6_ifacepkg        144/5                   142/5                 
v7_foldshape       1654/76                 1632/40               
v9_hops            19/3                    17/3                  
w8_unitname        48/17                   45/16
```

**THREE ARMS CONVERT** (`cmp_rc 255 -> 0`): `g1_netkinds`, `v9_hops`,
`w8_unitname`. **ZERO ARMS REGRESS.**

---

## 4. THE FIVE LAWS, GATED (question 4)

All five are in `src/ModuleEmit.cpp`; the header carries one record struct and
two maps and `src/UhdmExporter.cpp` carries the one drain call.
**`ParamEmit.cpp` is not touched at all** — it is `__LINE__`-sensitive and the
sister pass's ground.

**§ caGenScopeNetNamesakeStore75** (`R11U75_NETNS_OFF=1`) — the one-hop
namesake bind resolves through `genScopeNets` when `netMap` misses, and
DECLINES an `array_net` however it was reached. Fences: the walk itself is
untouched (still exactly one searchable scope, hit or miss); the resolved
object's kind decides, so both stores answer to the same rule.

**§ caNamesakePkgImportHome75, binding half** (`R11U75_IMPBIND_OFF=1`) — on a
`find` miss the ONE scope's own `ExplicitImport` / `WildcardImport` items are
read; the answer is the package's own symbol and the caller looks it up in
`netMap`, so a name with no emitted holder declines. Fences: that scope's items
only, never the compilation unit (`g4_edges` `un_ns`); a package nobody imports
is not consulted (`g2` `u_ns`).

**§ caNamesakePkgImportHome75, width half** (`R11U75_IMPW_OFF=1`) — the same
lookup in `genCaSubstAdjustW71`, which is `bindVariable`'s own walk, so
`adjustSize` re-sizes the substituted constant to the IMPORT's width
(`w8_unitname` `gp`, 32 -> golden's 16). Gated apart from the binding half
because the witnesses separate them.

**§ caAsmMemberSliceFoldGenLocalBase75** (`R11U75_GLPFOLD_OFF=1`) — a base
declared in the generate scope takes its digits from the value instead of from
an `elabParamPa` entry that road never makes; the member's own typespec comes
off the parameter object `emitGenScopes` built, and `adjustSize` is copied
branch for branch from the existing drain, its signed-`int` decline included.
Fences: `asmRefFamilyBase`'s own (a bare reference chain down to a
member-by-member const-function-built parameter), a packed struct with no
packed-struct member, the producer's leftover model must NAME EVERY MEMBER of
the struct, and the value slang folded must be a fully-defined integer of
exactly the struct's packed width. Nothing is minted until the write is
certain.

**§ caGenScopeFoldedLhsNoOwnBind75** (`R11U75_CASUPP_OFF=1`) — a cell recorded
for EITHER fold road drops the own-local Lhs `vpiActual`, exactly as
§ genCaConstRhsLhsNoBind25 does for an installed constant Rhs, because the fold
is a record here and a write at the drain. It is a residue LAW C would
otherwise inherit and it is measured on cells **pass 73 already folds**
(`g3_lpbase` `g_mod`, `v7_foldshape` `twice_a`/`twice_b`). As narrow as its
model: the target must be a variable of THIS scope, an ancestor scope's local
keeps its binding, and § caGenScopeLhsNamesakeBind74's namesake write runs
after it untouched (the joint cell `v7_foldshape` `both` keeps golden's
namesake actual AND its folded constant).

**`R11U75_OFF=1` reproduces the pristine database BYTE FOR BYTE on all 18
arms** (0 of 18 differing, path-normalised). Each switch drops its own law
alone, measured as the normalised dump delta against the patched and the
pristine database:

| switch | the arms that revert to the PRISTINE database | every other arm |
|---|---|---|
| `NETNS_OFF` | `g1_netkinds` 0, `v9_hops` 0 (`g4_edges` 56 -> 54: the array fence) | unchanged from patched |
| `IMPBIND_OFF` | `g2_importshapes` 0, `v6_ifacepkg` 0 (`w8_unitname` 4 -> 2: the width half stays) | unchanged from patched |
| `IMPW_OFF` | `w8_unitname` 4 -> 2 (the binding half stays) | unchanged from patched |
| `GLPFOLD_OFF` | `g5_glpwidth` 0, `g3_lpbase` 320 -> 4, `v7_foldshape` 62 -> 8, `g4_edges` 56 -> 2 | unchanged from patched |
| `CASUPP_OFF` | `g3_lpbase` 320 -> 292, `v7_foldshape` 62 -> 50, `g4_edges` 56 -> 52, `g5_glpwidth` 152 -> 150 | unchanged from patched |

The full ledger is `SWITCHES.r11u75.txt`. Read it as "distance from pristine":
`off` is 0 on all 19 arms, and each `sX` column returns exactly its own law's
arms toward pristine and leaves every other arm at the patched reading. The
GLPFOLD/CASUPP residuals are what LAW D still does to the cells **pass 73's own
fold road** produces (`g3`'s two `g_mod` cells, `v7`'s four `twice_*` cells,
`g4`'s array fence), which is the point of §4's note that LAW D is not a
consequence of LAW C.

A SWITCH-INTERACTION BUG WAS CAUGHT BY THIS LEDGER AND FIXED, which is why it
is a gate and not a formality. In the discarded binary the road was chosen by
reading the switch (`genBase75 = !glpFoldOff75() && isGenBlock`), so
`R11U75_GLPFOLD_OFF=1` sent a generate-scope base down the `caMemSel` road,
where the drain declines it but the RECORD still set `foldRec75` — LAW D then
fired on a cell whose Rhs never folded and `g4_edges` `f_if`/`f_case` came out
STRIPPED of an actual pristine carries. The scope test now stands alone and the
switch decides only whether the record is taken.

---

## 5. THE CENSUS AND THE PREDICTION (question 5)

`cellcen75.py` replays the harness's OWN discovery and its OWN slang argv
(`verify_golden.discover_*` / `translate` / `location_args`), runs BOTH frozen
binaries with `R11U71_CELLDBG=1 R11U74_CELLDBG=1 R11U75_CELLDBG=1`, and writes
one row per cell that reaches ANY of the three sites — the DECLINED cells
included. Every invocation's rc is recorded. The four slang-fenced names are
read off `canaudit.sh`'s own `FENCED=` line and never dispatched.

The trace covers all five laws: `R11U74BIND` carries the binding answer
(`ns=` and `bound=`) for LAWS A and B-bind, `R11U69CELL`'s `adjw=` carries
`genCaSubstAdjustW71`'s answer for LAW B-width **on the whole substitution
population, not just the fold sites** (that walk has three call sites, and two
of them are the pass-69/71 substitution, which is far wider than the fold), and
`R11U74FOLD` / `R11U75GLPFOLD` carry LAW C and, with them, the set LAW D can
touch.

| corpus | arms | trace rows | `R11U69CELL` (the substitution width walk) | `R11U74BIND` (gen-scope CA namesake) | `R11U74FOLD` | `R11U75GLPFOLD` |
|---|---|---|---|---|---|---|
| uhdm2rtlil | 871 x 2 modes | 9480 | **5588** | **3892** | **0** | **0** |
| surelog | 798 x 2 modes | 40710 | **28136** | **12574** | **0** | **0** |

**AND THE CENSUS IS ROW-IDENTICAL ON THE TWO BINARIES.** `diff` of the
pristine census against the patched one is **0 lines** on uhdm2rtlil (9480
rows) and **0 lines** on surelog (40710 rows) — the same cells, the same
`ns=`, the same `bound=`, the same `adjw=`, the same `lhsw=`.

The population is live, not empty: `bound=1` on 2858 of 3892 u2r cells and
12186 of 12574 surelog cells, and `adjw=` is NON-ZERO on 214 u2r and 7574
surelog substitution cells — LAW B's width walk has thousands of corpus cells
under it and moves none of them. Both fold roads are **0**, which is pass 73's
own census reading re-measured: the corpus holds no generate-scope
`cont_assign` whose whole Rhs is a member of a function-built struct parameter,
so LAWS C and D have nothing to touch there either.

`rc != 0` arms are recorded and carry no blind spot: on uhdm2rtlil 131 arms are
`rc=3`, 8 `rc=4` and 3 `rc=-11`, and only TWO of them emit any trace row at all
(`arb_idx_cast` default and testflags, `rc=4`); on surelog 578 are `rc=3`, 32
`rc=2`, 12 `rc=4`, 4 `rc=1` and 3 `rc=-11`, and only ONE emits trace rows
(`Rggen/testflags`, `rc=-11`, the census's own `-o /dev/null` artifact after
emission). A compile that fails emits nothing and the sweep has no database for
it — it teaches error recovery, not golden.

**THE CENSUS ZERO HAS A POSITIVE CONTROL** (a census zero needs one): the same
trace on `g1_netkinds` names 5 BIND hits and 3 golden-agreed misses, on
`g2_importshapes` 3 import BIND hits plus `w_net` found-and-unbound and three
declines, on `g4_edges` the fenced `an_ns` (`ns=an_ns bound=0`) and 2 GLPFOLD
cells, and on `g3_lpbase` 12 GLPFOLD cells beside 2 pass-73 FOLD cells — the
exact converted sets. The instrument can see.

**PREDICTED MOVER SET, WRITTEN BEFORE THE PATCHED SWEEPS: NOTHING. Zero
databases in either corpus, either mode.** Not "probably nothing" — the
instrument that names every cell of all five laws reads the same 50190 rows on
both binaries.

**MET on uhdm2rtlil: 0 movers of 1608.** On surelog the byte verifier reports
5, and §6d shows every one of them is the documented UVM pristine-
nondeterminism class, attributed by its own 4-line order-blind diff — no cell
of any law here appears in any of them, which is exactly what this census
says a priori.

---

## 6. THE GATES (question 6)

### 6a. Build and binaries

```
pristine  ca45217f2ac9f7766fc232a8be0ee319   == main tree @2f728c97 == the OPS pin
patched   3bcf6c65315faa0e2615d0e46373b915
```

Built `-j 2`, md5s taken separately, both frozen `chmod 555` before any sweep.

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
both modes vs results/golden_uhdm2rtlil.csv     0 of 1743 rows differing
```

**`byteverify SELFCHECK=1`, patched vs this pass's own pristine workdir:**

```
databases: patched=1608 pristine=1608
PATH_SETS_IDENTICAL (1608 paths)
MOVERS: 0 / 1608
SELFCHECK (every file vs one fixed file): 1607 / 1608 flagged
```

**MOVERS 0 — the predicted set exactly.** The comparator's negative control
fires on 1607 of 1608, so a zero here is a reading and not a broken instrument.

### 6d. surelog, `--mode both`

```
                 pristine          patched
default    CMP_EQUAL 474 / NE 9   CMP_EQUAL 474 / NE 9
testflags  CMP_EQUAL 469 / NE 8   CMP_EQUAL 469 / NE 8
```

the committed baseline exactly, on both binaries.

**Whole-row join vs `results/golden_surelog.csv`: 4 of 1597 rows differ, every
one ENVIRONMENT, and every one present on the PRISTINE binary too.**

```
Earlgrey_0_1/default     committed  CMP_EQUAL,,,differ   ours  CMP_EQUAL,,,
Earlgrey_0_1/testflags   committed  CMP_EQUAL,,,differ   ours  CMP_EQUAL,,,
```

— the documented `uhdm-dump` timeout draw blanking the DUMP COLUMN under load;
the STATUS stays `CMP_EQUAL` and the DATABASE byte pins below are the real
gate. Both blank on the pristine sweep as well, so the row does not appear in
the pristine-vs-patched join at all.

```
LowMemLib/testflags      SURELOG_FAIL "... Creating log file <WORKDIR>/..."
LowMemPkg/testflags      SURELOG_FAIL "... Creating log file <WORKDIR>/..."
```

— the workdir path carried inside a `SURELOG_FAIL` string.

**Whole-row join vs this pass's OWN pristine sweep: 3 of 1597 rows differ.**
The two `LowMem*` path strings again, plus one that moves TOWARD the committed
baseline:

```
YosysOpenSparc/default   pristine  TIMEOUT,surelog timeout
                         patched   SLANG_REJECT,... t2.v:269093:6: error: expected a declaration name
                         COMMITTED SLANG_REJECT,... t2.v:269093:6: error: expected a declaration name
```

The PRISTINE sweep drew a GOLDEN-SIDE Surelog timeout under load (a second
pass was sharing the machine); the patched row IS the committed value. Our
exporter is not on that path at all — the row is a Surelog-side draw.

**`byteverify SELFCHECK=1`, patched vs this pass's own pristine workdir:**

```
databases: patched=960 pristine=960
PATH_SETS_IDENTICAL (960 paths)
MOVER ./default/MiniAmiq-544c7f61/slang.uhdm    patched=27419f6011b4 pristine=1f412c52f146
MOVER ./default/SeqDriver-32af76aa/slang.uhdm   patched=83451156ebca pristine=1ab0ffc44005
MOVER ./default/SimpleUVM-1dc93a62/slang.uhdm   patched=d4f8cd018f2d pristine=ae201c42dd58
MOVER ./testflags/MiniAmiq-544c7f61/slang.uhdm  patched=da2371024182 pristine=0daaa17afacd
MOVER ./testflags/SeqDriver-32af76aa/slang.uhdm patched=1e9a523fad62 pristine=05df6c25a21b
MOVERS: 5 / 960
SELFCHECK (every file vs one fixed file): 959 / 960 flagged
```

**FIVE MOVERS, ALL UVM FAMILY, AND EVERY ONE IS THE DOCUMENTED
PRISTINE-NONDETERMINISM CLASS — attributed, not assumed.** Each database's
order-blind, path-normalised, id-stripped whole-dump diff is **EXACTLY FOUR
LINES, and every one of them a `UINT:<n>` + `vpiDecompile:<n>` pair**:

```
default/MiniAmiq     UINT:0    <-> UINT:1121    vpiDecompile:0    <-> :1121
default/SeqDriver    UINT:1498 <-> UINT:580     vpiDecompile:1498 <-> :580
default/SimpleUVM    UINT:0    <-> UINT:642     vpiDecompile:0    <-> :642
testflags/MiniAmiq   UINT:997  <-> UINT:765     vpiDecompile:997  <-> :765
testflags/SeqDriver  UINT:899  <-> UINT:0       vpiDecompile:899  <-> :0
```

That is the UVM macro-buffer line-number class exactly as the standing ops
note describes it (the 0-or-4-line `UINT`/`vpiDecompile` class, a 0-line draw
also occurring). **No `vpiActual` and no folded `constant` among them** — not
one line of any of this pass's five laws. Their rows stay `CMP_EQUAL`:
`BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM` `CMP_EQUAL` in both modes
on the committed baseline, on the pristine binary and on the patched one, and
`Scoreboard` `CMP_EQUAL`/`SLANG_REJECT` unchanged.

`rowheads.sh` on the patched workdir: **11 measured, every one `0 0 cmp
rc=0`**, `SKIP-NOFILE` 1 (`Scoreboard/testflags`, expected), `UNKNOWN-NAME` 0.

### 6e. Canaries

**Canary DATABASE byte pins, patched vs this pass's own pristine — ALL SAME,
and every one the OPS pin verbatim:**

```
SVSwitch            default/testflags  4842211c4030   (OPS pin)
YosysVerx           default/testflags  6ccda350c24a   (OPS pin)
InterfaceModPort    default/testflags  59a365f3ce2c   (OPS pin)
YosysOldOr          default/testflags  d68e0796d62c
BlackParrotComplex  default e3e354129d5a  testflags 73a10e8217e5
Earlgrey_0_1        default 8bdf25272e08  testflags 59d0ee6d10c3   (OPS pins)
```

**CSV canaries:**

```
canaries.sh  surelog, patched vs OWN PRISTINE      ok=52 changed=0 absent=0
canaries.sh  surelog, patched vs committed         ok=50 changed=2  (both Earlgrey_0_1
                                                    CMP_EQUAL/differ -> CMP_EQUAL/, the
                                                    dump-column draw above; STATUS unchanged)
canaries.sh  u2r,     patched vs committed gate    ok=8  changed=0 absent=0
ctcan2       surelog  EXPECT_UNKNOWN=1             ok=58 changed=0  PASS
ctcan2       u2r      EXPECT_UNKNOWN=6             PASS
canaudit.sh  canaries.sh ctcan2.sh                 audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS
```

No fenced name appears anywhere in the patch outside `canaudit.sh`'s own
`FENCED=` line: the four names grep to **0** occurrences in
`git diff 2f728c97` over the production surface.

### 6f. Binary path audit

```
u2r pristine   1742 / 1742 cmds.txt name <PRISTINE-BIN>
u2r patched    1742 / 1742 cmds.txt name <PATCHED-BIN>
```

```
surelog pristine  1530 / 1581 cmds.txt name <PRISTINE-BIN>
surelog patched   1531 / 1581 cmds.txt name <PATCHED-BIN>
```

The others are Surelog-side failures that never invoked an exporter (their
`cmds.txt` carries the `surelog:` line alone) — the same 50-51 as pass 73.

No `cmds.txt` in any of the four workdirs names a main-tree or another
worktree's binary.

### 6g. Score

**MOVED-WRONG 0. AWAY-GOLDEN 0.** Both corpora, both mode columns.

* uhdm2rtlil: **0 movers of 1608 databases**, both modes — the census's
  prediction met exactly.
* surelog: **5 movers of 960**, every one attributed to the documented UVM
  macro-buffer line-number class by its own 4-line order-blind diff, none of
  them a line of any law here, and every one of those rows still `CMP_EQUAL`.
* Grid: 19 arms. **4 CONVERT** (`g1_netkinds`, `v9_hops`, `w8_unitname`
  `cmp_rc 255 -> 0`; `v7_foldshape` and `g5_glpwidth` reach a complete
  `cont_assign` match with golden and keep only residue 3's head).
  **0 arms regress**, and on no arm does the ours-only dump-line count rise.
* `results/*.csv` untouched — read only, never written.

---

## 7. RESIDUES (ranked)

1. **The imported-package NET has no module holder of ours to bind**
   (`g2_importshapes` `w_net`, trace `R11U74BIND … name=w_net ns=w_net
   bound=0`). Golden lists `logic_net (work@dut.w_net)` in the module and
   binds gen-scope cells to it; `collectImportedPkgVars` hoists package
   VARIABLES only, so the name resolves and the object is absent and this pass
   declines rather than invent one. The missing hoist is the law, not the
   binding — one arm, measured, and the cheapest next cell on this ground.

2. **A generate-scope function-built struct localparam's own constant is
   UINT-encoded where golden assembles the BIN** (`g3_lpbase`
   `work@dut.gf[0].G_LOC`: golden
   `BIN:0000000000000000000000010000000011000011` / decompile
   `40'b0000…`, ours `UINT:65731` / decompile `65731`, both `vpiSize:40`).
   Same value, different encoding. `emitParameters`' two assemble arms and
   their bail rule never run for the generate-scope parameter listing, which is
   why LAW C takes its digits from the value instead. Pre-existing on both
   binaries.

3. **The gen-scope `func_call` leftover argument constant** — `g3_lpbase`'s and
   `v7_foldshape`'s remaining head after this pass: golden's
   `p::build(512)` argument is `constant UINT:512 vpiSize:64` parented at the
   `func_call`, ours is the module-level `UINT:64` object. Unmoved, and the
   reason those two arms stay `cmp_rc 255` although their whole `cont_assign`
   listing now matches golden.

4. **An operation AROUND the member select still declines** (`g3_lpbase`
   `g_sh`, golden `UINT:257 vpiSize:64` and ours `vpiSize:32`) — r11u69's R1,
   byte-identical on both binaries and not this pass's.

5. **The interface DEFINITION listing's generate-scope statements**
   (`v6_ifacepkg`, six golden-only `uhdmallInterfaces` rows). Pre-existing;
   `v6`'s LAW B cell converted and this is what is left.

6. **`v4_lhsshape`'s concat Lhs actuals** (r11v74's fourth residue) and the
   pass-73/71 residue set stand unmoved and byte-identical.

**R0 — NEXT.** Residue 1 is the cheapest: one hoist (package NETS into
`collectImportedPkgVars`' listing, with `emitImportedPkgVarNets`' own net-kind
rule) closes the last golden-bound namesake this pass measured and leaves no
new class behind. Residue 2 is the widest on this ground and is the thing that
would let LAW C fold through the EXISTING drain instead of beside it — it needs
the generate-scope parameter listing routed through the assemble arms' bail
rule, which is a parameter-listing pass, not a binding one.

---

## 8. HOW TO RE-RUN

```bash
GRID=<this dir>/grid bash rr75.sh <binary> <tag>        # golden + ours + cmp per arm, every rc recorded
GRID=<this dir>/grid python3 score75.py pris patch      # gold-only / ours-only dump distance per arm
DIFF=1 python3 calist75.py <gold.dump> <ours.dump>      # the RESOLVING LISTER: one row per cont_assign
python3 cellcen75.py <repo> <corpus> <binary> <out.tsv> # the site census, declined cells included
```

`rr75.sh` regenerates the golden with the pinned Surelog per arm per tag and
records `golden_rc` and `ours_rc` for every arm; an arm whose compile fails
teaches error recovery, not golden. No corpus test is ever dispatched from
here — every arm is its own `dut.sv`.

---

## 9. VERIFIER AMENDMENT (r11v75) — three fences this record predates

The adversarial verifier reproduced every number above (binary md5s, the four
witnesses, the 19-arm distance table, the three conversions, the switch ledger,
the goldens and the corpus gates) and then broke three of the five laws on a
wider golden grid. The SHIPPED patch carries three fences this section's text
does not describe; read `tools/probe/r11v75repro/README.md` for the measured
arms:

1. **LAW B, width half** — `nsImportHome75` now answers only a Net or a
   Variable. Returning a package PARAMETER/TYPEDEF/FUNCTION made
   `genCaSubstAdjustW71` return 0 and STOP, where the pristine walk climbed to
   the instantiating scope and read golden's width (arm `xc_impw`, golden 12
   and 4, patched 32).
2. **LAW C / LAW D** — the fold record is gated on the base being read by a
   SIMPLE NAME. Golden folds `B_LOC.n` and leaves `B1.B_LOC.n`, `A1.A_LOC.n`,
   `A3[1].L_LOC.n` and `dut.M_LOC.n` symbolic AND bound to the cell's own local
   (arms `xf_crossblk`, `xh_ancpath`).
3. **LAW B, binding half** — the import lookup is asked of an `InstanceBody`
   only. A generate block's own `import pg::*` is not a namesake home in golden
   even when the module-level holder exists (arms `xg_genimp`, `xi_genimp2`).

The 19 arms of this directory are BYTE-IDENTICAL on the patched and the
verified binary; the fences move only the verifier's own arms.
