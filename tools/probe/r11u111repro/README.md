# r11u111 — pair P of the fold ground, the parameter side: which object a parameter's typespec copies

**TWO ROWS CONVERT, BOTH MODES.** Each reads 0 uhdm-cmp lines and 0 heads with the
law binary, and `CMP_EQUAL` in the law sweep:

```
results/golden_uhdm2rtlil.csv: cfg_func_width_loop,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv: cfg_func_width_loop,testflags,CMP_NOTEQUAL,decompile:,,
results/gate_uhdm2rtlil.csv:   cfg_func_width_loop,testflags,CMP_NOTEQUAL,decompile:,,
results/golden_surelog.csv:    LargeValue2Struct,default,CMP_NOTEQUAL,decompile:,,
results/golden_surelog.csv:    LargeValue2Struct,testflags,CMP_NOTEQUAL,decompile:,,
LAW sweep:                     cfg_func_width_loop,{default,testflags},CMP_EQUAL,,,differ
                               LargeValue2Struct,{default,testflags},CMP_EQUAL,,,differ
```

* uhdm2rtlil: 794/10/67 → **795/9/67** in both modes.
* Surelog: 477/6 → **478/5** (default) and 472/5 → **473/4** (testflags).
* `results/*.csv` were NOT edited. The master promotes.

Every other row keeps its status. The only other row-text differences are
environment: the LowMemLib/LowMemPkg log path in the SURELOG_FAIL detail.

Base `1d7a03b8`. Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `b3dc863277c4f1340e9058c8b78f2f01` | own worktree at `1d7a03b8`, `-j 2`; equals the OPS pin |
| **LAW** | `759b34baa3a764957a7605355ea0079b` | this patch; the same md5 when the patch is applied to a FRESH `1d7a03b8` and rebuilt |

Every law has its own kill switch, and `R11U111_OFF=1` turns them all off. With
`R11U111_OFF=1` the law binary is byte-identical to pristine on all 242 switch
arms (`evidence/SWITCH.txt`).

**Surface.** The production change touches two files:

* `src/EmitHelpers.h` holds every § block, helper and switch. It is appended
  before the closing namespace.
* `src/ParamEmit.cpp` has 15 call sites. Each is **appended to (or edits) an
  existing line**. The file stays at 33717 lines, so every `__LINE__` keeps its
  value.

`ModuleEmit.cpp`, `ExprEmit.cpp`, `TypeEmit.cpp`, `UhdmExporter.cpp`,
`include/` and `results/` are absent from the patch. The rest of the patch is
this directory.

---

## Q1. The five rows at `1d7a03b8`

Measured with uhdm-cmp, LHS golden, one head per row. The counts are the same
in each mode. The full heads are in `evidence/HEADS_base.txt`.

| row | lines | head: golden (LHS) vs ours (RHS) |
|---|---|---|
| cfg_func_width_loop | 148/1 | LHS: `logic_typespec (q::mask_t)` 16:11, parented at ref `work@cfg_func_width_loop.u.M`, vpiInstance `q`, range `[0:2]` (`UINT:0`, `INT:2`), no Typedef_alias. RHS: `logic_typespec (mask_t)` with a vpiTypedefAlias ref `work@cfg_func_width_loop.u.M.mask_t` → `q::mask_t`, and its right bound is still the `NF-1` operation. |
| stamped_gen_param | 17/1 | LHS: `ref_typespec (q2::q2::row_t)`, the Elem of `logic_typespec (q2::row_t)`, whose actual is an unnamed `logic_typespec` 11:11-11:21. RHS: `<null>`. |
| ibex_tracer | 19/1 | LHS: `<null>`. RHS: `enum_const (OPCODE_LUI)` HEX:37 size 7, under `enum_typespec (ibex_pkg::opcode_e)`. |
| LargeValue2Struct (surelog) | 108/1 | LHS: `logic_typespec (sram_key_t)` 4:11, parented at ref `work@top.pack::scrmbl_key_init_t.key.sram_key_t`, vpiInstance `pack`, range `[127:0]`. RHS: `logic_typespec (pack::sram_key_t)` with no parent. |
| Rggen (surelog, default; testflags is SURELOG_FAIL at the base) | 64/1 | LHS: constant 4:33-4:42 `UINT:32` dc `32` size 32, with a ts ref (`work@rggen.u_block_0.u_adapter.register_if[0]`) → `int_typespec` 4:13. RHS: `UINT:64` dc `64` size 32, **with** the same ts ref → `int_typespec`. The brief said ours has no typespec; ours has it. Only the value differs. |

## Q2. Decode per face, and the site of our emission

Pass 107 located the sites by backtrace (`tools/probe/r11u108repro/evidence/SITES.txt`).
This pass re-located each one by grep. Two more sites were found with gdb on
the law binary (face 1's gen-scope callers below).

### FACE 1 — § pkgTdQualParamCopiesListing111 (LANDED; `ParamEmit.cpp` makeParamTs, drainDefParamTs, patchParamTypespecs, drainShareDefParamTs)

**Golden** (grid `f1` a01–a27 and pass 107's `pk` k01–k03/k17/k20–k22).
Take a parameter whose declared type is **written** `pkg::T`, where T is a
package 4-state vector typedef:

* **ELAB parameter.** Its typespec is a COPY of the package's TOP listing
  object: named `pkg::T`, vpiInstance the package, **no Typedef_alias**, bounds
  folded, parented at the parameter's ref. This holds in every elaborated home
  tested: module parameter, localparam, two instances, a generate block, a top
  module, and a package function.
* **DEF parameter.** The module definition's parameter and its DEF param_assign
  Rhs ref **share** the TOP listing object. This is judge-invisible in a module,
  because golden's object is visited under TopPackages first. It is
  judge-visible in a **package home** (a16: `package r; parameter q::mask_t RM`,
  where both r listings share `q`'s TOP object).
* **Import copy of such a package parameter** (a24: `import r::*` in a module).
  Golden has the same listing copy, named **bare** `T`, still with no alias, in
  both module views.

**Surelog.** `compileDatastructureTypespec` resolves `pkg::T` through the
package's datatype map. That returns the object `writeDataTypes` lists, so
elaboration clones it. A **bare** `T` (wildcard or explicit import) resolves
through the typedef's own `tpclone`, the bare clone with an alias. That is the
arm we already emit, and grid a08/a09/k06 keep it: a09 is equal, and a08/k06
have their own head.

**So the name is WHICH OBJECT IS COPIED, never a uniform `pkg::` rewrite.**

**Our site.** makeParamTs's vector-typedef arm (`ParamEmit.cpp` 24784–24876)
minted a bare clone with a `Typedef_alias`, in every view. The law has four
parts:

* **(a) The ELAB copy** is appended to the arm's last line (24875) and is gated
  by `qualPkgVecTd111`. It uses `copyLogicTs111` with the bounds folded from
  slang's packed ranges. INT is minted only for the six evaluator operators
  (evalIntOp106v).
* **(b) The DEF share** is in drainDefParamTs (26589, 26626, 26842–26843). In a
  package home it shares outright. In a module definition only the parameter
  ref and the DEF Rhs ref are re-pointed. The pristine bare clone stays the
  `DefInfo::paramTs` holder.
* **(c) The ELAB param_assign Rhs ref** keeps the pristine bare clone
  (drainShareDefParamTs 26510). The golden rule there is unmodelled: it is the
  package's LAST registered `T` typespec. That is the listing object in grid a02,
  but a package function's `T` argument clone in k17 and cfg_func_width_loop.
  The pristine clone matches the second shape.
* **(d) A FOLDED READ** of the parameter keeps binding the pristine bare clone
  (patchParamTypespecs 26373, 26383). Golden's folded read carries the bare `T`:
  `tools/probe/r10v64repro` v2_types64 a49–a52 `P + 1`.

**Refused:**

* A chain (`typedef mask_t m2_t`): a10 is already equal.
* bit / scalar / aggregate typedefs: those are other arms (a04/a05 residues).
* `$unit`.
* The ELAB copy in an **interface** home. ModuleEmit's net-decl-assign
  substitution (§ v11u88, fenced) hangs the parameter's own typespec on the
  folded read, where golden has the bare `T` (`r11v88repro` v23).

The gen-scope callers were found with gdb: `emitDefGenStmts` and `emitTopPorts`,
both in ModuleEmit, where `syntaxRefPrefix` is empty. There the copy's Elem ref
is named `work@<hierarchical path>.pkg::T`.

**Switches.** `R11U111_F1_OFF` drops face 1 (a–d). `R11U111_F1D_OFF` drops the
DEF share. `R11U111_F1B_OFF` drops the import-copy home.

### FACE 2 — § pkgRhsStructBareCopy111 (LANDED; `ParamEmit.cpp` pkgHomedYTs 20537)

**Golden** (grid `f2` b01–b24). A param_assign Rhs that NAMES a package
struct parameter carries a struct copy. Each vector-typedef member of that copy
binds a **bare `T` copy parented at its alias ref**, in two cases:

* when the Rhs is WRITTEN `pkg::P`, at any width: b01 b04 b05 b08 b10 b11 b12;
* when the value is WIDER than 64 bits: b06 b07 b13 b14 k10l (66 bits).

What decides is the **Rhs** spelling, not the parameter's type spelling (b03 vs
b04). An imported `P` of ≤ 64 bits keeps the pkg-named fold twin: b02, b03, b09
and k10k are equal at the base, and the law refuses them.

**Our site.** The copy is minted by the § paramCloneImportedCopy arm of
TypeEmit `buildStructTs` (fenced, unchanged). The flags it reads
(`structCloneMemberRefParent`, `paramCloneImportedCopy`) are now raised, and
saved/restored, around pkgHomedYTs's `makeParamTs` call (20537). The gate is
`rhsStructBareCopy111`.

**Typespec-ground residues:**

* **b15/b16:** a bit member, or a literal-range member. The TypeEmit arm fires
  only when a fold twin exists, so the flag cannot reach it.
* **b18:** a pattern-valued module parameter's Rhs op clone, the
  `paramOpCloneCtx` road.

**Switch:** `R11U111_F2_OFF`.

### FACE 3 — § pkgTdOfNamedDimsListing111 (LANDED; `ParamEmit.cpp` emitPackage listing loop 29000, 29017)

**Golden** (grid `f3`; shape decoded on t04 with `who108`).
`typedef ut_e [0:2] row_t` (ut_e a same-package `logic` typedef) is **one object
L built at package compile**:

* It is OMITTED from the package DEF listing.
* It is LISTED in the TOP listing.
* The DEF struct member (§ defPkgMemberTdOfNamedShares108), the TOP member
  wrapper, and the listing all share it.

Its shape:

```
L  logic_typespec `pkg::row_t`, Instance pkg, no span, Elem ref `pkg::pkg::row_t` -> A, range [0:2] (folded)
A  logic_typespec (unnamed) @type span, Instance pkg, Typedef_alias ref -> B, Elem ref -> U2, range [0:2]
B  logic_typespec (unnamed) @type span, Instance pkg, Elem ref -> U1, range [0:2]
U1 `ut_e`, Typedef_alias ref `ut_e` -> ut_e's TOP listing object;  U2 `ut_e`, Typedef_alias -> U3;  U3 `ut_e`
```

This is Surelog's typedef `tpclone` pair (CompileHelper.cpp:890-1043) applied to
the named element.

**Our site.** The listing loop's alias-of-typedef branch (29000–29017) already
builds ONE shared object, omits it from the DEF listing, and lists it in the TOP
listing. The law widens that branch's condition to `tdOfNamedDims111(ta)`. In
the DEF pass it builds L/A/B/U1/U2/U3 with `buildTdOfNamedDims111`. U1's alias
target is bound through the existing `pendingAliasChainTgt` drain.

**Gate:**

* A same-package element typedef, declared earlier, written `logic` with at
  most one LITERAL range, unsigned.
* Exactly one written dimension on the named type.

t05 (a `bit` element) is refused: golden's L there is a `packed_array_typespec`.

**Fullname note.** The Elem ref's fullname depends on the first binder:

| first binder | Elem ref fullname |
|---|---|
| a struct member | `q2::q2::row_t` |
| a module variable | `work@dut.q2::row_t` |
| a type-parameter override | `p::arr_t` |
| a plain listing | `q2::row_t` |

The law always writes the first form. No Compare reads a fullname.

**Switch:** `R11U111_F3_OFF`.

### FACE 4 — STOPPED AT THE DECODE (site fenced: `ModuleEmit.cpp`)

**The value.** Rggen's head is `u_adapter.register_if[0]`, a port view of an
element of `rggen_register_if #(8, 32, 64) register_if[25]` passed to the
adapter's `rggen_register_if.host register_if[REGISTERS]` port. Surelog v1.87
folds such a view at the **declaration defaults**
(§ ifacePortViewParamAssignsOnly, NetlistElaboration.cpp:1913-1934), so
`VALUE_WIDTH = BUS_WIDTH` → 32. Ours prints the connected instance's `64`.

The literal defaults ADDRESS_WIDTH and BUS_WIDTH are already right, because
ModuleEmit's restamp (41195–41225) copies the DEF parameter's inline
`UINT:`/`INT:` value. `VALUE_WIDTH`'s default is an expression, so its DEF
parameter carries **no** inline value and the restamp skips it.

**The fix** is to read the parameter's value in `ifaceDefaultScope`, the
fold-scope instance ModuleEmit already computes (`ifacePortViewFoldScope`).
That value is not visible to `emitParameters`: the port view, the receiver and
the named-modport exception are all local to `emitInterfaceInstance`. The fix
therefore needs an edit in the fenced file.

**The prototype** (`evidence/F4PROTO.txt`: built, measured, reverted — the
rebuilt law binary's md5 was unchanged):

* Grid `f4` d02 (a plain positional port, `C = B` default, `#(8,32,64)`):
  64/1 → **0/0**.
* **Rggen:** the head moves past VALUE_WIDTH to the NEXT head. That head is
  `u_block_0.g_register_0.u_register.register_if`, an array element reached by
  a **named** modport connection. Golden folds ADDRESS_WIDTH at the connected
  instance (`UINT:8`); ours folds at the declaration default (`UINT:16`).

The type face in the brief does not exist: our constant already carries the
`int_typespec` ref. The shared helper for pair Q is not needed on this ground.
The three uhdm2rtlil rows on pair Q's ground are ExprEmit fold reads, and that
is where their ts ref is missing (see grid f1 a24's next head below).

### FACE 5 — § impCopyConcatUnbound111 (LANDED; `ParamEmit.cpp` emitParameters 18032, 18269)

**Decode.** There is no duplicated copy. The six extra `parameter:` dump lines
are print-position artifacts of other parameters; the per-name counts differ
for PmpAddrRst and five others, not for the INSN_ parameters. The head is the
**binding**.

A module's materialized copy of an imported package parameter whose
initializer is concat-bearing (concatBearing54) is Surelog's clone of the
package's **elaborated** Rhs tree:

* Every `ref_obj` in it survives, module-scoped and **actual-less**.
* An enum-constant leaf loses its `enum_const`: grid `f5` e01/e02/e05/e08–e11/e13/e14/e22/e23.
* A bare package-parameter leaf stays a ref instead of folding: e03/e04/e12/e16/e21.
* A **written-qualified** leaf (`pq::Q0`) folds to its constant:
  `r11v54repro` xb2 `Y3 = {pq::Q0, C0}`.

ibex_tracer has 736 such cells across its INSN_* copies, both module views.

**Our site.**

* **Leaf half.** 18032 raises the existing `pkgElabSymOperands` flag for such
  copies. ExprEmit's actual-less arm at 15030 then fires; it is unchanged and
  was written for exactly this clone. A tree that holds a qualified parameter
  leaf is refused (`hasQualParamRef111`).
* **Enum half.** At 18269, `dropEnumActuals111` clears the `enum_const` actuals
  of the emitted tree.

**Switch:** `R11U111_F5_OFF`.

### FACE 6 — § tpOvrNamedDimsDrop111 (LANDED; `ParamEmit.cpp` type_parameter emission 21655, 21659)

**Golden.** An **override** written as a named type with packed dims
(`.id_t(pk::w_t [1:0])`, `w_t [1:0]`, a `$unit` typedef with dims) binds the
elaborated `type_parameter` to the named type ALONE.

**Our site.** The widened condition routes that shape into the existing
TypeAlias arm, which shares a package typedef and clones a module/`$unit` one.
The alias is found by `tpOvrNamedDimsAlias111`. A declaration default
(`localparam type rt_t = id_t [3:0]`, v11u108repro brk f5/b05) is refused.

**Residue (typespec ground).** An AGGREGATE element (a35 `pk::s_t [1:0]`, q01)
is refused. Golden's port variable there is a `struct_var`, and TypeEmit's
variable factory would build a `packed_array_var` WITH ranges and elements off
the rebound struct. That is a per-object move AWAY.

q02/q03/q05 move to golden at the type_parameter. Their next head is the
`rt_t` element: pass 109's § tpElemRebindElabPort110, which is not in this base.

**Switch:** `R11U111_F6_OFF`.

## Q3. Golden grids

Summaries are in `evidence/GRIDS.txt`. The golden-vs-golden calibration over
105 arms has 0 nonzero.

* **`grid/f1`, 27 arms.** Qualified/imported/explicit/chained package typedefs × homes (module parameter,
  localparam, interface, two instances, gen block, top module, package home,
  import copy, self-qualified) × literal/symbolic/ascending/signed/multidim
  ranges, plus bit/scalar/struct/enum/port controls.
* **`grid/f2`, 24 arms.** RHS qualified/imported × type qualified/imported ×
  width 16/64/66/80 × homes, plus bit/literal/plain/pattern members and pass
  107's k10*/k23*.
* **`grid/f3`, 21 arms.** Typedef-of-named with dims × listing only / variable /
  member / member dims / bit / scalar / symbolic range / parameter, pass 110's
  n01/n02/c13, pass 107's k05/k12–k15, the corpus copy, and the concat-member
  controls t09–t12.
* **`grid/f4`, 4 arms.** Interface port views, declaration-default fold.
* **`grid/f5`, 23 arms.** Enum / own-parameter / qualified leaves × brace /
  replication / cast / int / ternary / re-export / explicit import / sub-instance.
* **`grid/f6`, 6 arms.** The verifier's a35 and q01–q05.

## Q4. Laws, each droppable alone

`sw111.sh` runs 242 arms: this pass's grids, `r11u108repro/grid` and
`v11u108repro/brk`.

* `R11U111_OFF=1` is byte-identical to pristine on 242/242.
* Of the 122 law-moved arms, 112 are restored by exactly one single switch:

| switch | arms |
|---|---|
| F1 (incl. 3 moved by the DEF share alone) | 24 |
| F2 | 28 |
| F3 | 40 |
| F5 | 17 |
| F6 | 3 |

* 10 arms carry both F1 and F3: a parameter typed by a typedef-of-named-type.
  Only OFF restores them. Each single switch leaves the other law's bytes.

## Q5. Census and prediction

The evidence is in `evidence/CENSUS.txt` and `evidence/PREDICT.txt`.

* `cen111` records name-keyed, Compare-visible cells for the five faces:
  * F1: logic typespecs of parameters that are pkg-named or pkg-aliased;
  * F2: member alias targets under a param_assign Rhs struct;
  * F3: listing entries with Elem presence;
  * F5: ref_obj actuals inside module/interface param_assign Rhs;
  * F6: type_parameter bindings.
* Golden-vs-golden calibration: 3273 golden censuses, run twice, 0 differ.
* Positive control: f1 a01, f2 b01, f3 t01, f5 e01 read golden ≠ pristine and
  law = golden.
* `PREDICT.txt` was written from golden vs PRISTINE census cells BEFORE the
  first law sweep:
  * F1: cfg_func_width_loop, stamped_gen_param;
  * F3: stamped_gen_param;
  * F2: LargeValue2Struct, StructUnsizedVal;
  * F5: ibex_tracer and 3 other uhdm2rtlil rows, plus 11 surelog rows.
* Every law-moved cell is predicted. Predicted but unmoved: StructUnsizedVal,
  and the other F5 rows. Their census differences are shapes the gates refuse.
* Law census vs pristine (both corpora, both modes): every changed face cell is
  TO-GOLDEN, and AWAY is 0.

| row | F1 | F3 | F2 | F5 |
|---|---|---|---|---|
| cfg_func_width_loop | 4→0 | | | |
| stamped_gen_param | 12→0 | 3→0 | | |
| LargeValue2Struct | | | 8→4 | |
| ibex_tracer | | | | 736→0 |

## Q6. Gates

The evidence is in `evidence/GATES.txt`, `evidence/BOUNDARY.txt` and `evidence/SWITCH.txt`.

* **Build.** Both binaries were built `-j 2` and frozen at immutable paths
  before any sweep. Every `cmds.txt` was audited by binary path: 3273/3273 name
  the law binary.
* **Goldens:** 23/0, and the `/bin/false` control gives 0/23.
* **uhdm2rtlil, both modes.** The row-join against `results/golden_uhdm2rtlil.csv`
  (per mode) and against `results/gate_uhdm2rtlil.csv` differs only in
  cfg_func_width_loop, the conversion.
* **Surelog, both modes.** The row-join against `results/golden_surelog.csv`
  differs in LargeValue2Struct (the conversion) and in the LowMemLib/LowMemPkg
  log-path text (environment).
* **byteverify SELFCHECK=1, uhdm2rtlil:** 6/1608 movers, exactly the predicted
  cfg_func_width_loop, stamped_gen_param and ibex_tracer in both modes.
  * Each is TO-GOLDEN per cell, with 0 AWAY objects.
  * Context-keyed whole-dump distances: 17→11, 307→282, 3458→2050.
* **byteverify SELFCHECK=1, Surelog:** 7/960 movers.
  * LargeValue2Struct, both modes: TO-GOLDEN, F2 8→4, 0 AWAY.
  * The UVM family (MiniAmiq ×2, SeqDriver ×2, SimpleUVM default): each is the
    documented 4-line `UINT`/`vpiDecompile` order class. Their cen111 census is
    byte-identical to pristine, and they stay CMP_EQUAL. The draws differ
    between two law sweeps, which shows the class is nondeterministic.
* **Pins.** These are byte-identical to pristine in both modes:
  * SVSwitch `4842211c4030`;
  * YosysVerx `6ccda350c24a`;
  * InterfaceModPort `59a365f3ce2c`;
  * BlackParrotComplex and YosysOldOr (status pins);
  * Earlgrey_0_1 (`8bdf25272e08` / `59d0ee6d10c3`).
* **Canary battery:** ok=52/changed=0 (surelog), ok=8/changed=0 (uhdm2rtlil),
  ctcan2 PASS ×2, canaudit PASS.
* **The seventeen conversion rows** stay CMP_EQUAL, including the six from pass
  108, type_param_packed_dim and InterfaceModPort.
* **Wide boundary.** 9062 committed probe sources, compiled alone by both
  binaries: 73 movers.
  * 69 are TO-GOLDEN per cell (census plus per-object context distance), with
    0 AWAY.
  * 4 are LATERAL:
    * k15: member-leaf re-parenting, a parent-only change toward golden's parent lines;
    * g22, l154_noenum, g185_e_kinds: the layout-derived tail constant.
      `r10uvm154repro/layoutproof154.sh` with these binaries gives `LAYOUTPROOF OK`.
  * grid18 and g22 fail to compile on BOTH binaries (rc 4). They are
    error-recovery arms, not golden.

**Scoring method.** `score111.sh` scores each moved arm by:

* the cen111 per-face distance;
* `ctxdist111.py`, a CONTEXT-KEYED whole-dump distance. Each dump line is keyed
  by its owning header chain. Spans, `vpiParent` fields and `vpiFullName` are
  stripped, and the weaklyReferenced tail is excluded. It reports the objects
  whose own distance grows.

The order-blind sorted-line pool was tried first and rejected. It manufactured
AWAY verdicts: an extra wrong body in one place cancelled a missing body
elsewhere.

## The five rows: before → after, and the NEXT head

The full text is in `evidence/HEADS_law.txt`.

| row | base | law | next head |
|---|---|---|---|
| cfg_func_width_loop | 148/1 | **0/0 CONVERTS** | — |
| LargeValue2Struct | 108/1 | **0/0 CONVERTS** | — |
| stamped_gen_param | 17/1 | 96/1 | Package `IMPL`'s struct pattern: golden folds the concat member value `UnitTypes: {2'b01,…}` to a parentless `BIN:010101101010` size 12; ours keeps the op33. This is a pre-existing general face: grid f3 t09 shows it at the BASE on a plain `logic [11:0]` member. |
| ibex_tracer | 19/1 | 28/1 | Case item `INSN_ECALL` (1035:9): golden keeps `ref_obj work@ibex_tracer.INSN_ECALL`; ours folds it to `UINT:115`. A module-side read of an imported concat-valued parameter stays a ref in golden, because the module copy is the unreduced tree. The fold is ExprEmit's (fenced; sister pass r11u112). |
| Rggen | 64/1 | 64/1 | Unchanged. FACE 4 is fenced; see the prototype. |

## Residues, ranked

* **R0 — FACE 4 value (ModuleEmit, fenced; ready to land).** Port-view
  param_assign Rhs of an expression default. Read the parameter's value in
  `ifaceDefaultScope` in the restamp at ModuleEmit.cpp 41215. The prototype is
  in `evidence/F4PROTO.txt`: grid f4 d02 64→0; Rggen moves to the named-modport
  array-element ADDRESS_WIDTH head (8 vs 16).
* **R1 — ExprEmit folds** (fenced, sister pass r11u112):
  * a module-side read of an imported CONCAT-valued package parameter stays a
    `ref_obj` in golden (ibex_tracer's next head; grid f5 e02/e04/e14/e16/e21/e22);
  * a folded read of a package parameter keeps a ts ref (grid f1 a24's next
    head: golden `ref_typespec work@dut` → the bare `mask_t` copy on `o = RM`);
  * top-module `L ^ P` reads stay refs in golden (a18).
* **R2 — the package pattern's concat member value** folds to a parentless BIN
  constant in golden. This is stamped_gen_param's next head, grid f3 t09–t12,
  and it is present at the base.
* **R3 — typespec ground (TypeEmit, fenced):**
  * F2 b15/b16 (no fold twin) and b18 (paramOpCloneCtx);
  * F6 aggregate elements a35/q01 (`struct_var`);
  * the Elem-ref fullname of FACE 3's L when the first binder is not a member;
  * face 3's `'0` size: golden sizes a `row_t` value by L's range × A's range
    × ut_e, `18`/`37`, a double count; ours uses slang's 6/13. This is t02/t04's
    next head.
* **R4 — FACE 1's unmodelled last-writer rule** for the elaborated param_assign
  Rhs ref. The pristine bare clone is kept, and the rule is judge-invisible.
  Also: a04 (a scalar `logic` typedef) and a05 (a `bit` vector typedef) are
  other arms, and a13 (an interface home) is refused.

## Tools

| tool | what it does |
|---|---|
| `five111.sh` | Runs the five rows through verify_golden, both modes, then uhdm-cmp. |
| `grid111.sh` / `heads111.sh` | Grid runner (golden + tags, rc recorded) and a head summary. |
| `cen111.cpp` / `cenrun111.sh` / `censcore111.py` / `predict111.py` | Five-face census, its runner, per-row scoring and the a-priori prediction. |
| `score111.sh` / `ctxdist111.py` | Per-arm scoring: census plus context-keyed per-object whole-dump distance. |
| `bnd111.sh` / `bndscore111.sh` | Wide boundary, and golden-backed scoring of its movers. |
| `sw111.sh` | Switch check. |
| `sweep111.sh` | Own-workdir sweeps (same-length tags). |
| `pkgids111.cpp` | Which package object is which listing. |

The `who` tool is pass 107's `who108.cpp`.
