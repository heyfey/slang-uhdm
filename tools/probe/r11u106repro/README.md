# r11u106 — the struct pattern's own typespec and the typedef'd array variable carry their range bounds reduced

**TWO GATED LAWS, THREE SWITCHES, ONE HEAD FACE IN TWO HOMES.** The brief's
four target rows share one face: golden writes a location-less evaluator
constant (`INT:<v>`, size 64, `vpiIntConst`, no location, no parent) at a
range bound where we write the unfolded operation. The pristine re-run
shows that face sits in **two different producer homes**, reached by two
different roads:

* **S (3 rows: `cva6_struct_param_field`, `StructParamFieldRange`,
  `StructParamFuncBodyFieldCompare`, plus the untargeted
  `StructParamPatternInitCast`).** The ELAB struct localparam's
  assignment-pattern OPERATION has its own typespec clone. Golden reduces that
  clone's member range bounds (`[Cfg.XLEN-1:0]` becomes `INT:63`).
  § `structPatternOpTsBoundFold106`.
* **M (1 row: `mem_packed_2d_byte_write`).** The ELAB variable declared from a
  module unpacked-array typedef (`mem_t mem;` with
  `typedef logic [..][..] mem_t [DEPTH]`) gets a typespec clone whose OWN
  dimension bounds golden reduces (`[DEPTH]` is `[0:DEPTH-1]`, so it becomes
  `INT:3`). The brief read its `ref_obj (work@dut.mem_t.DEPTH)` as a member
  read "through a struct typedef scope". It is not one: that full name is
  synthesized by the dump from the parent chain, and `DEPTH` is a plain module
  parameter. § `typedefArrayVarElabFold106`.

**RESULT.** `mem_packed_2d_byte_write` **CONVERTS in BOTH modes** (cmp 48 → 0
lines). The three S target rows reach their NEXT head (LAW B). That head is a
**different face**, named as R0 below. No other row changes status. Every
predicted mover, and nothing else, moved. AWAY is 0 and MOVED-WRONG is 0 per
cell, on the grid, over the corpus movers and over the 8730-arm wide boundary.

Base `81f13b5f`. Pins per `SUPPORT_MATRIX.md`: slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`, and the
uhdm2rtlil corpus v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `84adb8d34c76d136325c65a6aa2e4b22` | own worktree at `81f13b5f`, == the OPS pin |
| **LAW** | `77f1796144334e9e4355079e74980443` | this patch; reproduced on a FRESH `81f13b5f` + `git apply` |
| explore | `ee458dea6fc3607fa6950d9e4b949ccf` | the three gates read from `R106OFF` (drops only) |

**Surface.** Production code touches three files. `src/EmitHelpers.h` holds
both § blocks and the helpers. `src/ParamEmit.cpp` gets two call sites,
**appended to existing lines** so that every `__LINE__` below them keeps its
value (the diff is 2 lines changed, 0 added). `src/ModuleEmit.cpp` gets the
one variable site. `TypeEmit.cpp`, `UhdmExporter.cpp`, `ExprEmit.cpp`,
`include/` and `results/` are ABSENT. The rest of the patch is
`tools/probe/r11u106repro/`.

---

## 1. THE FOUR ROWS AT `81f13b5f` (question 1)

`four106.sh` runs the pristine binary, then `uhdm-cmp`. Each arm reads 1 head
(`grep -c '^LHS:'`). The first 20 lines of each are in `evidence/HEADS106.txt`.

| row | default | testflags | head (golden → ours) |
|---|---|---|---|
| `cva6_struct_param_field` | 74 | 74 | constant `INT:63` sz64 ct7, no location → `operation vpiOpType:11 (hier_path Cfg.XLEN, UINT:1)` under `range 26:11` |
| `mem_packed_2d_byte_write` | 48 | 48 | constant `INT:3` sz64 ct7, no location → `operation 11 (ref_obj DEPTH, INT:1)` under `range 19:51` |
| `StructParamFieldRange` | 74 | 74 | as cva6, `range 24:11` |
| `StructParamFuncBodyFieldCompare` | 74 | 74 | as cva6, `range 43:11` |

The paths come from `cmptool` (the whole-design Compare with parent chains):
```
S: operation@24:12 < range@24:11 < logic_typespec@24:5 < ref_typespec < typespec_member(x) < struct_typespec@23:26
     < ref_typespec < operation@27:23 (op75) < param_assign@27:19 < module_inst < design     (TopModules only)
M: operation@19:51 < range@19:51 < array_typespec(mem_t)@19:11 < [array_var mem] < module_inst < design
```
The walker `tw106.cpp` prints every range bound by name path, with no dedupe
and a cycle guard. It shows S's golden folds ONLY on the pattern op's typespec.
The same member ranges under `param(I)`, `pa(I).lhs` and `param(it_t)` stay
unfolded in golden. The M fold sits ONLY on the elaborated variable's
array_typespec. The typedef list, the element typespec and the DEF view stay
unfolded.

## 2. THE PRODUCER'S ROADS, AND WHERE WE EMIT (question 2)

**S.** `NetlistElaboration::elab_parameters_`
(`~/git-repos/Surelog/src/DesignCompile/NetlistElaboration.cpp:250-431`) runs
this road:
* An instance param_assign whose Rhs is `vpiAssignmentPatternOp` /
  `vpiMultiAssignmentPatternOp` (`:250-252`) is cloned.
* If the LEFT parameter's typespec is a `struct_typespec` (`:404`),
  `reduceTypespecRanges` runs on the param typespec AND on the pattern op's
  own typespec (`:405-409`).
* The walk (`:338-360`) descends struct MEMBERS only. At a
  `logic_typespec` / `packed_array_typespec` / `array_typespec` it reduces that
  typespec's OWN ranges. It never reduces an element typespec, and never a
  `bit_typespec`.
* `reduceBound` (`:311-325`) swaps a NON-constant bound for `reduceExpr`'s
  constant when the reduce succeeds.

`reduceExprTree` (`:369-394`) does two more things: it reduces nested
operation typespecs, and it replaces `hier_path` operands inside the pattern
VALUES (this is R0's road).

On our side the pattern op's typespec is the ELAB clone that
`mintParamOpClones` (`src/ParamEmit.cpp:25666`) mints, with
`patchParamTypespecs`'s fallback (`src/ParamEmit.cpp:25791`). Both are built
by `makeParamTs(…, parentBounds=true)` under `paramOpCloneCtx`. That clone is
already a separate object: pristine ids show `#276` for the op typespec
against `#331` for the param's own typespec.

**M.** `NetlistElaboration::elabSignal` → `ElaborationStep::makeVar_`
(`NetlistElaboration.cpp:2753`). A declared type that resolves to a
`SimpleType` goes through `CompileHelper::elabTypespec`
(`ElaborationStep.cpp:1901-1905`, `CompileType.cpp:2158-2238`). That function
CLONES a bit/logic/array/packed-array typespec that has ranges and
`reduceExpr`s both bounds of each of its own ranges, never the element's.

On our side, `emitInstance` binds such a variable to a per-reference copy
(`copyArrayTypedefTs`, TypeEmit's). It does this when
`unpackedArrayTypedefCopies` is true, at `src/ModuleEmit.cpp:11670-11690`.
The copy owns fresh `range` objects (`copyRangeVec`), so an in-place bound
swap touches nothing shared.

## 3. THE GOLDEN GRID (question 3)

There are 5 arms in `grid/`, all run on real Surelog v1.87. Every arm reads
`slrc=0 ourrc=0 slerr=0` on both binaries.

**S — `s1_homes106`, `s2_edges106`, `s3_pkgunp106`** (the member reads, the
homes, the operators and the nesting). Golden's value on the pattern op's
typespec:

| bound shape | golden | law |
|---|---|---|
| `Cfg.XLEN-1`, `Cfg.W2+1`, `Cfg.W2*2-1`, `$clog2(Cfg.XLEN)-1`, `W/2-1`, plain `W-1`, localparam `LW-1`, `q106::PW-1`, `Cfg.XLEN*2-1` (127), ascending `[0:Cfg.W2-1]`, a non-zero right `[..:Cfg.W2]` left side, packed-2D inner range, 3-member struct, `'{default:0}` | `INT:<v>` sz64 ct7, no loc | **folds** (op gate) |
| bare `$clog2(W)` | `UINT:4` sz64 ct9, no loc | **folds** (clog2 gate) |
| bare member `[Cfg.W2:0]`, nested `[NC.s.a:0]`, bare param `[W:0]` | the VALUE LITERAL's own object with ITS location (`DEC:8 32'd8 @6:53`, `UINT:16 @21:73`) | declines (residue R1) |
| `bit [Cfg.W2-1:0]` member | unfolded (bit is not reduced) | untouched |
| a nested NAMED struct member (t02 inside t11) and the nested pattern op's typespec | folded | declines: the object is SHARED with the DEF view (residue R2) |
| unpacked struct localparam | folded | declines: its op typespec is the SHARED def object (residue R3) |
| package-level struct pattern (`r106::PL`), cast Rhs, constant Rhs, constant bounds | unfolded / no op | untouched |
| child instances (`u_c1`/`u_c2`/`u_a`/`u_b`/`u_c` with CW/N overridden), interface instance with a pattern-overridden struct param | folded per instance value | folds |
| gen-scope struct localparam | folded, but golden's Rhs is an OPERATION and ours a CONSTANT (a pre-existing face) | no op clone, untouched |

**M — `m1_vars106`, `m2_homes106`.**

| variable | golden | law |
|---|---|---|
| `[D]`, `[D*2]`, `[4]`, `[$clog2(W)]`, `[D][2]` (outer), `logic [W-1:0] … [2]` (outer only; the element stays), two vars on one declaration, a var with a pattern initializer, a child instance (`u_c1`) | `INT:<v>` sz64, no loc, element unfolded | folds |
| a NAMED element (`st_t sa_t [D]`, `vec_t [3:0] nml_t [DEPTH]`) | unfolded | declines (shared arm / element gate) |
| a `wire` of the typedef, a non-ANSI port `input a_t ai`, a `reg` element | golden's signal is a NET, unfolded | declines (`it.port`, the `Variable` gate, the element gate) |
| a package typedef var, alias-of-array typedef, `[0:D-1]` / `[D-1:0]` | constant already on our side (UINT, located) | untouched (residue R4) |
| overridden child `u_c2`, interface var, gen-scope vars | golden folds; we emit no such variable (pre-existing) | unreached |

The logic-typedef vars (`typedef logic [W-1:0] a03_t; a03_t v`), bit and
packed-2D were ALREADY golden at the base. That is an existing transcription
of the same `elabTypespec` road for packed types, and it is this law's control.

**Scores, name key** (`score106.py`: the name path with every span stripped,
the judge fields of the bound, multiset-safe, with a name-free fallback key;
`evidence/GRID106.cells.txt`):

| arm | TO | AWAY | MOVED-WRONG | swap control |
|---|---|---|---|---|
| s1_homes106 | 11 | 0 | 0 | AWAY 11 |
| s2_edges106 | 10 | 0 | 0 | AWAY 10 |
| s3_pkgunp106 | 6 | 0 | 0 | AWAY 6 |
| m1_vars106 | 8 | 0 | 0 | AWAY 8 |
| m2_homes106 | 2 | 0 | 0 | AWAY 2 |

## 4. THE LAWS, EACH DROPPABLE ALONE (question 4)

`src/EmitHelpers.h` (§ blocks at the file's tail):
* `spOpTsFoldOp106` — an OPERATION bound of the pattern op's struct clone becomes `INT:<v>`.
* `spOpTsFoldClog2106` — a bare `$clog2` bound there becomes `UINT:<v>`.
* `utdVarFoldOp106` — an OPERATION bound of the typedef'd array variable's
  own dimensions becomes `INT:<v>`.

**Gates shared by the S law.** The clone must be a `struct_typespec`
(`:404`). Its parent must be an op 75/76. A member's leaf typespec is folded
only when its `VpiParent` is that member's own ref (OWNED, never a shared
def object). The value is slang's evaluated range of the same dimension.

**M gates.** Only the per-reference COPY arm is folded; the SHARED arm never
is. The home must not be a package typedef. It must be a body `Variable`, not
a port and not a net. The element as written must be a `logic` scalar under
packed dimensions: not named, not `reg`, not another array alias.

Drops use the explore binary (`evidence/GRID106.drops.txt`). **All three on**
gives dumps byte-identical to LAW on 5/5 arms. **All three off** gives dumps
byte-identical to pristine on 5/5. The single drops:

| drop | effect |
|---|---|
| `spOpTsFoldOp106` | S TO 27→1 (the clog2 cell stays) |
| `spOpTsFoldClog2106` | s2 TO 10→9 |
| `utdVarFoldOp106` | M TO 10→0 |

Every drop has AWAY 0 and MOVED-WRONG 0.

## 5. CENSUS AND THE A-PRIORI MOVER SET (question 5)

`census106.py` reads the PRISTINE sweep databases, golden first, by the same
name key (`evidence/CENSUS106.txt`). A reach cell is our operation / `$clog2`
bound at an S or M home, classed against golden's cell under the same key.
* **Calibration** (golden read as both sides): Surelog 0 cells. uhdm2rtlil has
  2 M GOLD-OTHER cells, `unpacked_struct_array_typedef` in both modes: a
  struct-typed element where golden keeps the operation.
* **Positive control** (the grid): s1 12, s2 10, s3 7 S GOLD-FOLD; m1 8 and
  m2 2 M GOLD-FOLD. The census is a superset: it also sees the declined
  shared/unpacked/net cells.

```
uhdm2rtlil 1608 dbs  S GOLD-FOLD 4 cells  cva6_struct_param_field x2 modes
                     M GOLD-FOLD 2 cells  mem_packed_2d_byte_write x2 modes
                     M GOLD-OTHER 2 cells unpacked_struct_array_typedef x2 modes -> must NOT move (shared arm)
Surelog     960 dbs  S GOLD-FOLD 12 cells StructParamFieldRange, StructParamFuncBodyFieldCompare,
                                          StructParamPatternInitCast x2 modes;  M 0
```
**PREDICTED MOVERS by name:** the 4 target rows. Also
`StructParamPatternInitCast` (both modes; its head is elsewhere, an extra
`32'd64` constant on our side, so it stays CMP_NOTEQUAL at 15 → 15 cmp
lines). Only `mem_packed_2d_byte_write` changes status.

## 6. THE LAWS MEASURED (question 6)

**Sweeps.** Both corpora, both modes, own workdirs with same-length tags
(`pris`/`lawx`), `--jobs 3`, `SLANG_UHDM` exported. Every `cmds.txt` names
the right frozen binary: 3273/3273 per binary. The full record is in
`evidence/GATES106.txt`.
* uhdm2rtlil, joined against `results/gate_uhdm2rtlil.csv` and both modes of
  `results/golden_uhdm2rtlil.csv`: pristine differs in 0 rows; LAW differs in
  exactly 1 row per mode. **CONVERSION, QUOTED:**
  ```
  results/golden_uhdm2rtlil.csv: mem_packed_2d_byte_write,default,CMP_NOTEQUAL,decompile:,,
  results/golden_uhdm2rtlil.csv: mem_packed_2d_byte_write,testflags,CMP_NOTEQUAL,decompile:,,
  results/gate_uhdm2rtlil.csv:   mem_packed_2d_byte_write,testflags,CMP_NOTEQUAL,decompile:,,
  LAW:                           mem_packed_2d_byte_write,{default,testflags},CMP_EQUAL,,,differ
  ```
  This moves u2r from 788/16/67 to **789/15/67** in both modes.
  `results/*.csv` were NOT edited; the master promotes.
* Surelog `--mode both`: 0 rows differ for either binary (943 EQUAL / 17
  NOTEQUAL of 1596).
* **byteverify** `SELFCHECK=1`, LAW vs own pristine, identical path sets:
  * **u2r 4/1608**: cva6 ×2, mem_packed ×2, exactly the prediction.
    `unpacked_struct_array_typedef` is unmoved.
  * **sl 12/960**: the 6 predicted Struct* databases, plus the UVM family.
    MiniAmiq ×2, SeqDriver ×2 and SimpleUVM/default each have an order-blind
    dump diff of 4 lines (2 `|UINT` + 2 `|vpiDecompile`), the documented
    line-number class. Scoreboard/default diffs 0 lines order-blind: the coin.
    All UVM rows stay CMP_EQUAL.
  * Every law mover is scored per cell: **TO 22, AWAY 0, MOVED-WRONG 0**. Each
    mover's whole dump diff is exactly those bound objects.
* **The wide boundary** covers every `*.sv`/`*.v` under `tools/probe`:
  **8730 arms**, 8428 SAME, 69 DIFFERS and 233 NODB
  (`evidence/BOUNDARY106.arms`).
  * NODB: 227 × rc=3/3 and 5 × 139/139. One `r10buvm13repro/v2_reach13.sv`
    read `lrc=134` once, during a concurrent build. 15 re-runs per binary read rc=0 and SAME path-neutral 3/3, and the arm is SAME in this
    pass's first boundary.
  * Every one of the 69 DIFFERS arms was scored against a FRESH Surelog v1.87
    golden (`slrc=0 slerr=0`, NULL re-run SAME on 69/69;
    `evidence/BOUNDARY106.scored`). 143 cells moved, every one owned by a law
    (S 65, M 78): **TO 141, AWAY 0, MOVED-WRONG 0, NOGOLD 2**. The 2 NOGOLD
    cells are `r11v47` v15/v31. There golden has NO such param_assign at all,
    a pre-existing presence difference; the law changes a cell inside an
    object golden never writes.
  * **The first draft (`cd86e623`) was CONVICTED here.** It had AWAY 2 at
    `r11u52vrepro/grid/b3_namedelem` (a NAMED element with packed dims), and it
    moved golden-NET cells at `r11u65repro/grid/n1_netkinds` `r` (a `reg`
    element) and `n3_ports` `ai` (a non-ANSI port). The element gate and the
    `it.port` gate are those convictions. The shipped LAW re-ran every sweep
    and the whole boundary.
* The prior passes' grids (r11u94-r11u105, r11v94-r11v102 and every older arm)
  are inside the wide boundary. None of their fold cells moved; the only
  DIFFERS arms are S/M cells.
* **Goldens** 23/0; `/bin/false` 0/23.
* **Canaries:** `canaries.sh` sl ok=50 changed=2 (Earlgrey_0_1's dump COLUMN
  blank in both modes; the pristine sweep reads the same two); u2r ok=8.
  `ctcan2` PASS ×2, `canaudit` PASS.
* **Database pins**, pristine == LAW, both modes: SVSwitch `4842211c4030`,
  YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
  BlackParrotComplex, YosysOldOr, Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`.

**The four rows, uhdm-cmp lines before → after** (`evidence/HEADS106.txt`;
line counts are depth, not distance):

| row | default | testflags |
|---|---|---|
| `mem_packed_2d_byte_write` | 48 → **0 — CONVERTS** | 48 → **0 — CONVERTS** |
| `cva6_struct_param_field` | 74 → 60 | 74 → 60 |
| `StructParamFieldRange` | 74 → 60 | 74 → 60 |
| `StructParamFuncBodyFieldCompare` | 74 → 164 | 74 → 164 |

## LAW B — the next head of each S row, and R0

The range head is gone in all three S rows. The next head is the same face
in all three, and it is a **DIFFERENT face**: the flattened pattern VALUE.
Golden keeps each member's initializer as an OPERATION tree. We fold it to a
constant.

* **cva6 / StructParamFieldRange** (`'{x: Cfg.XLEN'(1), …}`). Golden writes
  `operation vpiOpType:67` (cast), `vpiSize:64`, with vpiTypespec → ref →
  **`void_typespec` @27:28-27:31**, operand `constant UINT:1 sz64` @27:38. The
  second member has the same shape with NO vpiSize. Ours is
  `constant UINT:1 sz64 @27:28` with no decompile. Path:
  `operand[0] < operation@27:23 (op75) < param_assign@27:19 < module_inst (TopModules)`.
* **StructParamFuncBodyFieldCompare**
  (`(Cfg.XLEN'(1) << (Cfg.XLEN - 1)) | Cfg.XLEN'(1)`). Golden writes
  `operation 29 (|) vpiSize 64 [ operation 22 (<<) [ op67 cast → void_typespec,
  operand UINT:1 ], [ op11 (−) [ constant UINT:64 sz32 @30:23 — the
  Base.XLEN literal, parented in the package ], UINT:1 ] ], …`. Ours is
  `constant UINT:9223372036854775809 sz64 @47:13`.

**R0 = the struct-pattern VALUE face.** In the ELAB pattern op of a struct
param_assign, a member value that reads a struct-parameter member stays an
operation. The size-cast gets a `void_typespec`, and `reduceExprTree`
(`NetlistElaboration.cpp:369-394`) replaces each `hier_path` operand with the
member's value literal object. Our fold machinery mints a constant for the
whole value. This is the next head of cva6_struct_param_field,
StructParamFieldRange and StructParamFuncBodyFieldCompare in both modes.

## RESIDUES

* **R1**: a BARE member or parameter bound (`[Cfg.W2:0]`, `[W:0]`) on the
  pattern op's typespec. Golden writes the value literal's own located object.
* **R2**: a nested NAMED struct member, and a nested pattern op's typespec.
  Golden folds them, but ours are the SHARED def objects, so folding them would
  need a clone.
* **R3**: an unpacked struct localparam's pattern-op typespec is the shared
  def object (golden folds).
* **R4**: `[0:D-1]` / `[D-1:0]` / package-typedef variables. Ours copy a
  UINT-located constant our DEF view already folded, where golden keeps the
  operation in the def and `INT` in the var copy. The `typedef` of a module
  (`a02_t`, `a25_t`) is the same pre-existing DEF face.
* Also pre-existing and unreached: an overridden child's / an interface's /
  a gen-scope's typedef'd array variable (we emit none); a gen-scope struct
  pattern Rhs (golden operation, ours constant); a struct op clone named
  `it_t` where golden says `named_t` (`localparam type it_t = named_t`).

## REPRODUCING

```bash
git worktree add /tmp/wtp 81f13b5f && git worktree add /tmp/wtl 81f13b5f && (cd /tmp/wtl && git apply /tmp/r11u106.patch)
for d in /tmp/wtp /tmp/wtl; do cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
   -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; cp $d/build/slang-uhdm /tmp/$(basename $d).bin; chmod 555 /tmp/$(basename $d).bin; done
R=/tmp/wtl/tools/probe/r11u106repro
g++ -O2 -std=c++17 $R/tw106.cpp -I ~/.local/include -L ~/.local/lib64 -luhdm -lcapnp -lkj -o /tmp/r11u106_tw
G=/tmp/g106 && mkdir -p $G && cp $R/grid/*.sv $G && cd $G
for a in *.sv; do bash $R/run106.sh $a pris=/tmp/wtp.bin lawx=/tmp/wtl.bin; python3 $R/score106.py ${a%.sv}.{g,pris,lawx}.tw | tail -1; done
bash $R/four106.sh /tmp/wtl.bin lawx                   # the four rows' cmp line counts
WDROOT=/tmp/wd106 bash $R/sweep106.sh pris /tmp/wtp.bin; WDROOT=/tmp/wd106 bash $R/sweep106.sh lawx /tmp/wtl.bin
python3 $R/census106.py --gg /tmp/wd106_pris/u2r; python3 $R/census106.py /tmp/wd106_pris/u2r /tmp/wd106_pris/sl
SELFCHECK=1 bash /tmp/wtl/tools/probe/r10oth4repro/byteverify.sh /tmp/wd106_lawx/sl /tmp/wd106_pris/sl
# wide boundary: BND_PRIS/BND_LAW/BND_ROOT/BND_OUT + xargs -a <list> -P 3 bnd106.sh; then bndscore106.sh per DIFFERS arm
```
