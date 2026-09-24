# r11u120 — the span-and-instance ground (downstream axis, pair B refill)

Base d31ae79a. Ground: `src/ModuleEmit.cpp`, `src/UhdmExporter.cpp`,
`uhdm_main.cpp`, plus the one permitted harness edit in
`scripts/verify_golden.py` (it forwards `-filterprotected`).

**EIGHT of the ten targeted rows are now downstream IDENTICAL, all with
uhdm-cmp 0.** Fresh rows from the LAW binary's full downstream sweep
(`evidence/DOWNSTREAM120.txt`, `evidence/ds_ten_law.csv`):

    IndexedPartSelectOfMember,IDENTICAL,NO_GATES,NO_GATES,0,0,
    PartSelectOfMember,IDENTICAL,NO_GATES,NO_GATES,0,0,
    SelectOnMemberSelectedFrom2DArray,IDENTICAL,NO_GATES,NO_GATES,0,0,
    iface_array_elem_cfg_param,IDENTICAL,NO_GATES,NO_GATES,0,0,
    type_param_override_elem_sel,IDENTICAL,OK,OK,3,3,
    gen_scope_numports,IDENTICAL,NO_GATES,NO_GATES,0,0,
    param_name_collision_typeparam,IDENTICAL,NO_GATES,NO_GATES,0,0,
    ibex_controller,IDENTICAL,OK,OK,565,565,

Downstream: IDENTICAL 794 -> **802**, EQUIVALENT 7 -> 3, DIVERGENT 4 -> 0,
SLANG_REJECT 66 (of 871). No row left IDENTICAL. gen_scope_numports'
downstream-lane uhdm-cmp goes 9824 -> 0.

**func_upto and matching_end_labels stay EQUIVALENT** (baseline verdict). They
are decoded as NOT reachable from the database's object model. A Restore+Save
round trip of golden's own matching_end_labels database keeps every object,
field and per-type order, yet it produces OUR RTLIL. The order is the
plugin's `std::map<RTLIL::Wire*, …>` heap-address order (Q2 (4)/(5),
residue R1).

Seven laws (L1-L7), each droppable alone, and the one permitted harness edit.
Probe 2833/2833. Both corpora: 0 regressions, 0 conversions, 0 changes. Every
byte mover was predicted by name or is the known UVM coin.

## Patch

`/tmp/r11u120.patch` = `git diff d31ae79a` of this worktree. Its production
surface is `src/ModuleEmit.cpp`, `src/UhdmExporter.cpp` and `uhdm_main.cpp`,
plus the harness edit in `scripts/verify_golden.py`. The rest is this
directory. `git apply --check` is clean on a fresh d31ae79a worktree and on
the main tree's newer HEAD 1fc087af (whose `scripts/verify_golden.py` gained
the strict column). Applied to a fresh d31ae79a worktree and rebuilt (`-j 2`), it gives md5 `e0f0c780f6706df6e19e888b26240d6f`, byte-identical to the LAW binary every measurement used.

## Binaries

| name | md5 | what |
|---|---|---|
| pristine | `3e6d2800759fb6ea476700223ab73bb0` | worktree build at d31ae79a, byte-identical to the main tree's `build/slang-uhdm` |
| LAW (final) | `e0f0c780f6706df6e19e888b26240d6f` | this patch |
| (intermediate) | `1ce13bd1…` law1 (L1+L2), `ab3f994c…` law2 (+L2b), `a6b75b98…` law3 (+L3), `1a27dc07…` law4 (+L4), `cb5b999c…` law5 (+L6/L7), `4e69a750…` law6 (L5 without the deferred-path half) | measurement only |

Every measurement ran from frozen `chmod 555` copies.

## Q1. The heads at d31ae79a (pristine, `evidence/HEADS120.txt`)

`scripts/downstream_uhdm2rtlil.py` on the ten rows reproduces the baseline:
DIVERGENT 4, EQUIVALENT 6 (`evidence/ds_ten_pristine.csv`). uhdm-cmp between
the downstream-lane golden and our slang lane: 0 on every row except
gen_scope_numports (9824 lines).

| row | nohier diff | head (surelog lane `<`, slang lane `>`) |
|---|---|---|
| PartSelectOfMember | 6 | `connect \a [0] 1'1` / `1'x` (and [7], [8]) |
| IndexedPartSelectOfMember | 6 | the same face |
| SelectOnMemberSelectedFrom2DArray | 2 | `connect \a [2] 1'1` / `1'x` |
| iface_array_elem_cfg_param | 2 | `connect \A 8` / `connect \A 16` |
| type_param_override_elem_sel | 6 | `module \child$typaram_2_1_1` / `_1_1_1`, `wire width 4 input 1 \rt_i` / `width 2`, `\A_WIDTH 4` / `2` |
| param_name_collision_typeparam | 58 | golden's `$sub $sub$dut.sv:11` cells (`DataWidth-1`, src `dut.sv:11.34-11.45`) missing in ours |
| gen_scope_numports | 161 | uhdm-cmp 9824: the design is named `work@tc_sram` in golden (tc_sram becomes a top once its only instance is filtered), ours elaborates that instance |
| ibex_controller | 34 | `attribute \src "ibex_controller.sv:194.28-194.61"` / `193.28-…`: every src line 183-207 one less in ours |
| matching_end_labels | 2 | `update \blk1.x 1'1` moves from the 4th to the 1st place of `sync init` |
| func_upto | 814 | the same kind of `update` reorder in `sync init` |

## Q2. Decode (plugin read, producer, judge blindness)

### (0a) the three member-select rows — L1
* **Plugin.** The elaborated cont_assign `a.b[0] = 1` imports its Rhs through
  `import_constant` (`expression.cpp`, the "Unsupported constant type: 0"
  arm). Ours was a constant with no value, size, type or parent, so the bit
  reads `1'x`.
* **Ours.** Minted at `ModuleEmit.cpp` (the `memberSelLitLhs` arm, `:36837`
  at d31ae79a; the brief's `:36692` predates pass 119). Its comment read the
  uhdm-dump REPEAT elision (a repeated object prints as its header line
  alone) as a "bare loc-only" constant.
* **Producer.** `UhdmWriter::writeCont_assign` (Surelog v1.87
  `UhdmWriter.cpp:2254-2277`): the reduce returns the def's own constant,
  `adjustSize(nullptr, …)` is a no-op for a hier_path Lhs, then
  `res->VpiParent(assign)` and `assign->Rhs(res)`. Golden shares the def
  constant (`UINT:1` size 64) and parents it at the elaborated cont_assign.
* **Judge.** `constant::Compare` reads VpiConstType/VpiSize/VpiDecompile of
  the pair it reaches, and the def constant is compared first through the
  definition, so the stub was never a head (cmp 0 before and after).

### (0b) iface_array_elem_cfg_param — L2 (+ L2b)
* **Plugin.** `fold_iface_param_via_chain` (`uhdm2rtlil.cpp:1079-1111`):
  when the hier_path's `CFG` parameter has no Expr, the value is read from
  `par->VpiParent()` if that parent is a `param_assign` (`:1096-1099`), the
  declaration default `'{DAT: 8}`; otherwise the chain falls through to the
  connected `arr[0]` and reads 16.
* **Ours.** The port-view parameter is parented at the `interface_inst`.
* **Producer.** `NetlistElaboration::elab_parameters_` (`:262-264`): an
  assignment-pattern parameter is built by `pclone = clone_tree(mod_assign)`,
  so the cloned Lhs is parented at the cloned param_assign (a scalar shares
  the def parameter, `:450`).
* **Judge.** No generated Compare reads VpiParent.
* **L2b.** The named-modport port view (g3 i02/i03/i04, gB b06) is the same
  producer, but the block that holds L2 skips that view, so it gets its own
  loop keyed on OUR param_assign's Rhs (op 75). It moves only cells: g3
  i02-i04 were downstream-IDENTICAL already, and gB b06 is NE at base
  (residue R4) and stays DIVERGENT.

### (1) type_param_override_elem_sel — L4 (+ L3)
* **Plugin.** Before it names a specialization, `type_param_signature`
  (`uhdm2rtlil.cpp:2921-2942`) sizes every port with
  `get_width_from_typespec` (`module.cpp:3111`). For `rt_i` that is a
  `packed_array_typespec`: element width × range (`module.cpp:3290-3340`).
  With `-debug` the golden lane reads `logic_typespec simple range width = 2`
  for the element, and ours `ExprEval returned size=1`. Both lanes go through
  the plugin's own re-elaboration of the unelaborated database
  (`uhdm2rtlil.cpp:92-98`), and it is the DEFINITION's port `rt_i` whose
  element differs.
* **Head, measured (`porttree`, `tsrefs`).** In golden, the definition
  `work@child`'s port `rt_i` refs the REBUILT array (#4, element `id_t` ->
  clone of the override `logic [1:0]`). That is the same object the
  definition's `type_parameter rt_t` points at after
  § tpElemRebindDefView107, and nothing refs the original array. Ours kept
  the original (element = the `logic` default, 1 bit).
* **L4.** § tpElemRebindDefView107 (`UhdmExporter.cpp`, `rebindTypeParamElem107`)
  already mints golden's rebuilt array; L4 also re-points the definition's
  ports that ref the original. Alone, L4 makes the row IDENTICAL.
* **L3.** `writeElabParameters` (Surelog `UhdmWriter.cpp:442-500`, the same in
  both Surelogs) lists, for a type parameter that `instance->getTypeParams()`
  does not name, "the sole copy (unelaborated)", i.e. the definition's own
  object. `getTypeParams()` is filled only by the NAMED-override arm
  (`DesignElaboration.cpp:2319-2326`). Golden's `work@dut.u` lists
  `work@child.rt_t` (17:21-17:25) and `sel_t`. Ours listed unlocated copies
  (`work@dut.u.rt_t`, minted in ParamEmit). L3 is a post-pass after § 107,
  which still reads the copies, and it lists the definition's object. It
  does not move the row, but grid gT t04 (two instances with different
  overrides) goes EQUIVALENT -> IDENTICAL only with it.

### (3) param_name_collision_typeparam and (2) gen_scope_numports — L5
* **Plugin.** The same port sizing. Golden's port `d_i` (`data_t
  [NumPorts-1:0]`) refs the type parameter's DEFAULT typespec
  `logic [DataWidth-1:0]` (11:27-11:48) in the definition and in every
  elaborated view, and the written dims are dropped. The plugin imports that
  range, which makes golden's `$sub $sub$dut.sv:11` (`DataWidth-1`) cells.
  Ours minted a fresh RANGE-LESS logic_typespec at the written-type span
  (14:10-14:31).
* **Producer.** The name `data_t` goes through `compileTypespec`, which
  returns the parameter's typespec. It is the producer § tpDimPortTsIsDefault41
  decoded for aggregate leaves. The fenced predicate there
  (`tpAggregateLeafAlias41`, EmitHelpers.h) admits only struct/enum leaves, so
  L5 is the same predicate with a vector/scalar leaf, on the three port roads
  of ModuleEmit (child, top, def), plus the deferred `pendingNetTs` def path.
  That last path is taken when the written dims name an overridden parameter
  (`[N-1:0]` with `N` overridden: grid d01/d06, and both rows).
* **Judge.** Equal before and after on every row and arm (masked: the port's
  typespec pair is reached after the type parameter's).
* **gen_scope_numports needs L6 first.** Its cmp 9824 comes from
  `-filterprotected`, not `-DSYNTHESIS`: the only `tc_sram` instance sits in
  a `// synthesis translate_off` region (`dut.sv:26-30`). Surelog drops it
  (`SV3_1aPpTreeShapeListener::enterComment`, the three
  `synopsys|pragma|synthesis translate_off` regexes), `tc_sram` becomes a top,
  and the design takes its name (`work@tc_sram`). The slang lane never got
  the flag (`IRRELEVANT_NOARG`). With L6 the cmp is 0. With L6 + L5 the row
  is IDENTICAL.

### (6) ibex_controller — L7 (the line filler), with L6
* **Plugin.** `get_src_attribute` builds every `src` attribute and cell name
  from VpiFile basename + line.col-endline.endcol.
* **Producer, decoded.** Under the flag, `enterComment` calls
  `addLineFiller(ctx)` (`SV3_1aPpTreeListenerHelper.cpp:181-186`: one
  `\n` per newline of the comment) for EVERY one-line translate_on comment.
  It is the comment's only newline when the comment closes a region in
  active text, because the append was skipped while the region was on. In an
  INACTIVE branch, `exitComment` adds a second filler for the same comment.
  A STRAY translate_on (no region open) in active text was already appended
  whole, so it also yields two newlines. Each extra newline shifts every
  later preprocessed line by one. Lines map back to source only through the
  IncludeFileInfo records that macro expansions write. A with-args macro
  records PUSH+POP even for an empty body (`enterMacroInstanceWithArgs`), and
  re-anchors from its own source line, the whole line included. A no-arg
  macro records the POP only when its body holds a newline. ibex: the
  `ifndef SYNTHESIS` block `171-183` holds `// synopsys translate_on` at 182,
  so lines 183-207 read +1 until `` `ASSERT(...)`` at 208.
* **Measured on the producer** (`fpspans.sh`, uhdm2rtlil's Surelog,
  `-DSYNTHESIS` with vs without `-filterprotected`, grid gF): inactive
  `ifndef`/`else` +1 (f01, f07), two inactive blocks +2 (f05), stray +1
  (f03), closing 0 (f04, f06), with-args macro re-anchors (f02, f09, f12),
  single-line no-arg macro does not (f08), across modules (f10), and a
  filtered instance leaves its module a top (f11).
* **L7** (`uhdm_main.cpp`). One walk over the syntax trees classifies each
  translate_on comment by the place slang keeps it:
  * an active LineComment trivia is a stray;
  * a disabled token's trivia, or a not-taken branch's terminator trivia
    (which slang's `parseBranchDirective` rewrites to DisabledText), is
    inactive;
  * the tail of a translate-off region's DisabledText is a closing comment,
    and counts only if the region itself sits in an inactive branch (the
    ibex case).

  Active MacroUsage (with args, or with a multi-line body) and Include
  directives are re-anchors. The shift is applied as a post-pass over every
  object's line fields (VpiLineNo/EndLineNo, instance VpiDefLineNo,
  typespec_member VpiRefLineNo/RefEndLineNo) right before the save, keyed by
  the object's file (the nearest ancestor's VpiFile for a file-less object).
  It is a post-pass because 56 emitter sites stamp lines with a direct
  `getLineNumber`, not through `locLineCol`.
* **L6** (`uhdm_main.cpp`) asks slang's `--translate-off-format` for the three
  prefixes. **The harness edit** (`scripts/verify_golden.py`) moves
  `-filterprotected` from `IRRELEVANT_NOARG` to a translation, `--filterprotected`.
  In the corpora only `PragmaProtect.sl` passes it (testflags row
  SLANG_REJECT before and after). In the downstream lane every row gets it.

### (4) func_upto and (5) matching_end_labels — NOT in the database's object model (residue)
* **Plugin.** Both rows differ only in the order of `update` actions in the
  `sync init` of an initial block with block-local variables.
  `import_initial_interpreted` (`process.cpp:14643-14670`) collects them in
  `std::map<RTLIL::Wire*, …> wire_to_value`, so they come out in Yosys
  `Wire*` HEAP ADDRESS order.
* **The id-listing tool** (`idlist.cpp`) lists every object in restored-address
  order. `ordcmp.sh` compares per-type creation orders: matching_end_labels
  differs in cont_assign, logic_net, port and ref_obj creation order
  (`evidence/ORDER120.txt`). Golden walks definition generate blocks
  depth-first in source order, and ours emits a block's own items before its
  nested blocks.
* **The decisive experiment** (`resave.cpp`, `ylane.py`, `evidence/ORDER120.txt`).
  Restoring GOLDEN's matching_end_labels database and saving it back
  unchanged (idlist diff 0: same objects, fields, ids and per-type order)
  turns golden's RTLIL (`0b1b923c0c79`) into OURS (`76629ce38082`). For
  func_upto, a round trip of OUR database moves ours to a third order
  (`83e46e70302c` -> `7d1d4d96cc7b`), and erasing our 1024 orphan call
  arguments (below) gives the same third order, not golden's. The order is
  in the plugin's heap history (the saved file's symbol table and layout),
  not in any object, field or per-type order the exporter controls. Matching
  per-type creation orders would not reproduce it, so no law is landed.


## Q3. The grids

Two goldens per arm (`arm.sh`): the pinned v1.87 with probe flags (the `cmp`
column) and uhdm2rtlil's own v1.87-5 with the downstream flags (the verdict
column). Each arm records the rc of all four producers, and every rc is 0.
Pristine verdicts come from the BASE harness (`REPO=` the main tree), law
verdicts from this worktree's. The per-arm tables are in
`evidence/GRID120*.txt`.

| grid | arms | what | pristine downstream | LAW downstream | cmp |
|---|---|---|---|---|---|
| r11u118 g2 (control) | 10 | member bit/part/indexed/2-D/nested/sized/unsized/whole + plain-vector controls | IDENTICAL 8, DIVERGENT 2 | IDENTICAL 9, EQUIVALENT 1 (m04, NE at base, 180 lines) | unchanged per arm |
| gA | 10 | L1 fresh: two instances of one def, gen-if, sized indexed part, a PARAMETER Rhs (control), nested struct, packed union, multi-bit decimal, overridden child param, gen-for, array-element member | IDENTICAL 5, DIVERGENT 5 | IDENTICAL 9, EQUIVALENT 1 (a10, NE at base, 158 lines) | unchanged per arm |
| r11u118 g3 (control) | 7 | port views: array element [0]/[1], single overridden/default, named modport, two-member struct, scalar | IDENTICAL 5, DIVERGENT 2 | IDENTICAL 7 | 0 |
| gB | 6 | L2 fresh: two readers on arr[0]/arr[1], 2-member B field, generic port, gen-for readers, scalar+aggregate, single default | IDENTICAL 0, DIVERGENT 5, EQUIVALENT 1 | IDENTICAL 1 (b01), the other five unchanged: each is NE at base (68-84 lines: an INLINE `#('{…})` aggregate override on an interface instance — residue R4) | unchanged per arm |
| gT | 8 | L3/L4: the row's shape, non-local default, ORDERED override, two instances with different overrides, plain localparam type, gen-scope instance, localparam type over a value param, body localparam type | IDENTICAL 3, EQUIVALENT 4, DIVERGENT 1 | IDENTICAL 6, EQUIVALENT 1 (t03, NE at base 47), DIVERGENT 1 (t08, residue R5) | unchanged per arm |
| gD | 8 | L5: vector default in child/top, scalar default, overridden type, `bit` vector, gen-scope, two dims, output port | IDENTICAL 2, EQUIVALENT 5, DIVERGENT 1 | IDENTICAL 8 | 0 |
| gF | 12 | L6/L7: translate_on placements x active/inactive branches x macro kinds (below) | IDENTICAL 3, EQUIVALENT 9 | IDENTICAL 12 | 0 |

**Cells.**
* L1 (`cells.sh ^constant$`, gA + g2): value-less constants in ours
  14 -> 0 (golden 0). Ours' constant count now equals golden's on every arm.
  The remaining constant differences are range-bound constants without a
  parent (ExprEmit, residue R6).
* L2/L2b (`cells.sh ^parameter$ CFG`): g3 matched 15/21 -> 21/21; gB b01
  3/5 -> 5/5. On gB b02-b05 golden has two more port-view parameters than we
  emit (structural, NE at base).
* L3 (listing): the instance's `vpiParameter` entries are the definition's
  objects on t01/t02/t04-t07. The overridden `id_t` keeps its own copy,
  exactly as golden does.
* L4 (`tsrefs 17 31`): the definition port `rt_i` refs the rebuilt array, and
  the original is left unreferenced, as in golden.
* L5 (`porttree`): the definition and elaborated ports ref the type
  parameter's default typespec object on d01-d08 and on both rows.
* L6/L7 (`fpcells.sh`, location multiset against the downstream golden), LAW
  vs law with `R11U120_FPLINE_OFF=1`:

| arm | shape | Surelog shift | LAW matched | L7 off |
|---|---|---|---|---|
| f01 | `ifndef SYNTHESIS` translate_off/on | +1 to EOF | 55/58 | 38/58 |
| f02 | same + with-args macro at line 9 | +1 lines 7-8, 0 from 9 | 59/62 | 55/62 |
| f03 | stray active translate_on | +1 | 55/58 | 40/58 |
| f04 | active pair (closing) | 0 | 55/58 | 55/58 |
| f05 | two inactive blocks | +1 then +2 | 55/58 | 34/58 |
| f06 | `ifdef SYNTHESIS` (active) pair | 0 | 51/54 | 51/54 |
| f07 | pair in the `else of an active `ifdef | +1 | 55/58 | 44/58 |
| f08 | no-arg single-line macro after | +1, NO re-anchor | 56/60 | 38/60 |
| f09 | with-args macro on the next line | 0 | 55/58 | 55/58 |
| f10 | shift across a module boundary | +1 | 89/92 | 19/92 |
| f11 | region holding an instance | 0 (the instance's def becomes a top) | 75/78 | 75/78 |
| f12 | multi-line with-args macro | re-anchor | 50/57 | 48/57 |

The 3 cells short on every arm are the same with the flag off: they come
from outside L7 (constant parents). f12's 7 are the multi-line macro span
residue (golden `cont_assign 1.10-2.6`, ours `9.10-2.6`; residue R7).


## Q4. The laws (each under its own switch; `R11U120_OFF=1` drops all)

| law | where | switch | what |
|---|---|---|---|
| L1 § memberSelLitRhsShared120 | `ModuleEmit.cpp`, the `memberSelLitLhs` Rhs site | `R11U120_MEMBERSELRHS_OFF` | the elaborated cont_assign of a member-select Lhs with a literal Rhs takes the DEFINITION's constant, re-parented at the elaborated cont_assign; the bare mint stays the fallback |
| L2 § ifacePortViewAggParamParent120 | `ModuleEmit.cpp`, the port-view param block | `R11U120_IFACEAGGPARENT_OFF` | port-view aggregate (op 75) parameter parented at its param_assign |
| L2b (same §, (b)) | `ModuleEmit.cpp`, before that block | `R11U120_IFACEAGGPARENTNM_OFF` | the same for the named-modport port view, keyed on our own param_assign's Rhs |
| L3 § instTypeParamSharesDef120 | `UhdmExporter.cpp`, `shareInstTypeParams120`, post-pass after § 107 | `R11U120_TPSHARE_OFF` | an elaborated module_inst lists the definition's type_parameter for every type parameter its instantiation does not override BY NAME (the `ovr110` census; abstains when `R11U110_OFF` empties it) |
| L4 § tpElemRebindDefPort120 | `UhdmExporter.cpp`, `rebindTypeParamElem107` | `R11U120_TPDEFPORT_OFF` | the definition's ports that ref the original array are re-pointed to § 107's rebuilt array |
| L5 § tpDimVecPortTsIsDefault120 | `ModuleEmit.cpp`, `tpVecLeafAlias120` + the child/top/def port roads + the deferred def path | `R11U120_TPDIMVEC_OFF` | a port written `data_t [dims]` whose type parameter resolves to a vector/scalar refs the parameter's default typespec |
| L6 § filterProtected120 | `uhdm_main.cpp` (`--filterprotected`) | `R11U120_FP_OFF` | slang `--translate-off-format` for `synopsys`, `synthesis`, `pragma` |
| L7 § fpLineFiller120 | `uhdm_main.cpp` | `R11U120_FPLINE_OFF` | the filler-line shift (decode above) |
| harness | `scripts/verify_golden.py` | — | `-filterprotected` -> `--filterprotected` |

`R11U120_OFF=1` drops every law. Under it `--filterprotected` is accepted and
changes nothing: 178 + 56 arms (every grid of this pass, r11u118's, r11v11u118's
and r11u119's) are byte-identical to the pristine binary's
(`offbytes.sh`: ARMS=178 SAME=178, ARMS=56 SAME=56).

**Each switch, dropped alone, on the eight moved rows** (`evidence/SWITCHES120.txt`):
MEMBERSELRHS -> the three member-select rows DIVERGENT; IFACEAGGPARENT ->
iface_array_elem_cfg_param DIVERGENT; TPDEFPORT -> type_param_override_elem_sel
EQUIVALENT; TPDIMVEC -> gen_scope_numports and param_name_collision_typeparam
EQUIVALENT; FP -> gen_scope_numports EQUIVALENT; FPLINE -> ibex_controller
EQUIVALENT. IFACEAGGPARENTNM and TPSHARE move no row; each moves grid
cells (g3 i02-i04), and TPSHARE also moves verdict t04. `R11U120_OFF` puts
all eight back at their baseline verdicts.

**Byte controls on arms** (`onbytes.sh`, LAW vs pristine, probe flags). Of
the 190 arms of r11u118 + r11v11u118 + r11u119, 181 are SAME. The 9 movers
are r11u118 g2 m01/m04/m09 and g3 i01-i06, which are exactly L1's value-less
cells and L2/L2b's port views. All 78 r11u119 arms and all 56 r11v11u118
arms are unmoved.


## Q5. Census

`cen120.cpp` reads each law's trigger off a PRISTINE database
(`evidence/census_pristine_corpus.txt`). The positive controls are the
targeted rows: every one flags its law, pristine vs LAW:
PartSelectOfMember L1 3 -> 0, iface_array_elem_cfg_param L2 4 -> 3 (the def
view and home views stay, as in golden), type_param_override_elem_sel L3 3 ->
1 (the named-overridden `id_t` stays) and L4 1 -> 0,
param_name_collision_typeparam L5 2 -> 0, gen_scope_numports L5 12 -> 0.
L6/L7 read no trigger off a database, so they are predicted from the source:
the downstream rows whose objects' files hold a `translate_on|off` one-line
comment (`evidence/census_fp_downstream.txt`) are exactly gen_scope_numports
and ibex_controller. In the corpora only PragmaProtect passes the flag, and
its testflags row is SLANG_REJECT.

**Prediction vs byte movers** (`evidence/BYTEVERIFY120_*.txt`, SELFCHECK on,
path sets identical):
* surelog corpus: 25 of 960 databases move.
  * 18 are predicted: MultiPartSelect (L1); GenForIfaceLocalparamNestedGen,
    GenIfIfaceParamStructField, InterfaceParamOverrideProp (L2);
    PackageTypeParam, StructParamFieldRange, StructParamFuncBodyFieldCompare,
    StructParamPatternInitCast, TypeParam (L3). Each moves in both modes.
  * The other 7 are the UVM coin: MiniAmiq, SeqDriver and SimpleUVM in both
    modes and Scoreboard/default (`evidence/UVM_COIN.txt`). Each of the six
    moves exactly 4 dump lines, `vpiDecompile:0 / UINT:0` -> `1511`, the
    known UINT/vpiDecompile order coin. Scoreboard is order-blind SAME (92
    ordered lines).
* uhdm2rtlil corpus: 56 of 1608 move, i.e. 28 rows in both modes, all
  predicted. L1: the three member-select rows. L2: the ten `iface_*` rows.
  L3/L5: arb_idx_cast, bits_of_type_param, cva6_struct_param_field,
  gen_scope_numports, packed_array_reset_loop, packed_array_struct,
  packed_struct_array_fifo, param_name_collision_typeparam,
  param_nested_struct_field_width, port_chained_type_param,
  top_module_type_param, TypeParameterAsPortTypeWithLogicAnonymous,
  type_param_packed_dim, type_param_unpacked_port. L3/L4:
  type_param_override_elem_sel.
* downstream lane: 29 of 805 move, the same 28 plus ibex_controller (L7).
* **No unpredicted mover.** 22 predicted database cells do not move, and each
  keeps its census count under the LAW binary: 20 are L3 cells whose
  instance names the type parameter in a NAMED override (golden keeps its own
  copy too), e.g. TypeParameterAsPortTypeWith{Enum,…,Struct}, gen_scope_typaram,
  param_type_logic_width, struct_member_cfg_width, TypeParamElab and
  TypeParamOverride; 2 are L2 cells on a view outside L2's gate
  (GenForStructParamBound).

## Q6. Gates

1. **Build.** Pristine `3e6d2800759fb6ea476700223ab73bb0` (= the main tree's
   build at d31ae79a). LAW `e0f0c780f6706df6e19e888b26240d6f`. Both built
   `-j 2`, frozen before measuring, and every `cmds.txt` audited by binary
   path (1531 + 1742 per sweep, each naming its frozen binary).
2. **Probe:** `EQUAL=2833 (of 2833)` (LAW).
3. **Corpora** (LAW, `tests/sweep.sh --corpus "surelog uhdm2rtlil"`):
   surelog default `CMP_EQUAL=480 CMP_NOTEQUAL=3`, testflags `474 / 3`;
   uhdm2rtlil `803 / 1 / 67` in both modes; `regressions=0 conversions=0
   changes=0` in both. The pristine sweep reads the same.
4. **Downstream** (LAW, full, against `results/downstream_uhdm2rtlil.csv`):
   `EQUIVALENT=3 IDENTICAL=802 SLANG_REJECT=66 (of 871); not identical and
   not excused=0`. The only movers are the eight target rows (all to
   IDENTICAL). arb_idx_cast, func_upto and matching_end_labels keep their
   baseline EQUIVALENT. A pristine full sweep reproduces the baseline
   (`794/7/4/66`).
5. **uhdm-cmp on every touched row** (`evidence/CMP_DOWNSTREAM_MOVERS.txt`):
   every downstream mover is at 0 before and after, except
   cva6_struct_param_field. That row is 17 before and 17 after against the
   downstream-lane golden (v1.87-5) and CMP_EQUAL in the corpus.
   gen_scope_numports goes 9824 -> 0. Every corpus mover is CMP_EQUAL before
   and after (the status join is unchanged).
6. **Byteverify:** above (Q5). The canaries (`evidence/CANARIES120.txt`) read
   ok=43/changed=9 and ok=12/changed=4, and ctcan2 reads 18 changed and 2
   changed. **None of those 33 (name, mode) cells is a byte mover**: the LAW
   database is byte-identical to the pristine one there, so the dump-column
   drift is environment. Pass 118 recorded the same numbers at its base.
   Note that the main tree moved to 1fc087af during this pass (fc313b50
   replaced the csv `dump` column with `strict`); my pristine sweep ran on the
   main tree's harness, so its csv carries `strict`. Its slang argv equals the
   LAW sweep's on every row except PragmaProtect/testflags (`--filterprotected`,
   the harness edit).
7. **Arm byte controls:** `R11U120_OFF=1` = pristine bytes on 178 + 56 arms.
   The laws on move 9 of the 190 pass-118/119 control arms, all predicted (Q4).

## Residues, ranked

* **R1 — func_upto, matching_end_labels (the two order rows).** Heap-address
  order in `import_initial_interpreted`'s `std::map<RTLIL::Wire*, …>`
  (`process.cpp:14643`). The object model cannot reach it: a Restore+Save of
  golden flips matching_end_labels to our exact output, and a round trip of
  ours moves func_upto to a third order. func_upto also carries 1024 ORPHAN
  `ref_obj` (A_CONST/B_CONST, 20:36/20:45) under the 512 elaborated
  `func_call F@20:34`, next to the folded constants golden has alone. They
  come from the elaborated param fold of `C_CONST = F(A_CONST, B_CONST)`
  (ParamEmit/ExprEmit, fenced). Erasing them does not restore golden's order
  (`dropargs.cpp`). The per-type creation-order differences (`ordcmp.sh`:
  definition generate blocks are walked depth-first in source order by
  golden, own-items-first by ours) are real but equally unproven as the
  cause.
* **R2 — arb_idx_cast** (EQUIVALENT at base and after, not targeted). An L3
  mover, verdict unchanged.
* **R3 — L6 boundary.** slang's translate-off also honours BLOCK comments and
  trailing words after `translate_off`; Surelog honours neither. No corpus
  file has either form. A translate_off in an inactive branch whose
  translate_on sits outside that branch would split the preprocessors
  (slang's lexer scans raw text across the `endif`). This is unmeasured.
* **R4 — inline aggregate override on an interface instance**
  (`bus_if #('{DAT: 16}) x ()`, gB b02/b03/b04/b05/b06). NE at base, 11-84
  lines, and golden has two port-view parameters more than we emit. It is the
  instance-override param emission (ParamEmit, fenced).
* **R5 — a body `localparam type e_t = T` alias of a header type parameter**
  (gT t08). DIVERGENT at base and after, and golden's own netlist is the
  broken one (`$pos` with A_WIDTH 0). Golden's `e_t [3:0]` typespec spans
  1:35-3:12, and the override typespec is parented at the instance's
  type_parameter.
* **R6 — range-bound constants without a parent** (gA a05 and others:
  golden's `constant 7.17 <- part_select(d)`, ours unparented). ExprEmit,
  fenced. Judge-blind, and downstream-IDENTICAL on every arm.
* **R7 — multi-line macro statement span** (gF f12: golden `cont_assign
  1.10-2.6`, ours `9.10-2.6`). Independent of `-filterprotected`.
  Downstream-IDENTICAL.
* **R8 — the 2-D member / unpacked member arms** g2 m04 (180) and gA a10
  (158). They were NE at base, and L1 moves each DIVERGENT -> EQUIVALENT.

## Instruments

Build every C++ tool with
`g++ -std=c++20 -O1 X.cpp -o X -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread`.

* `idlist.cpp` — the id-listing tool: every object in RESTORED ADDRESS order
  (the order uhdm2rtlil's pointer-keyed maps iterate), with serializer id,
  UhdmId, type, name, span, value (constants) and parent. Within one type the
  restored order is the producer's per-type creation order.
* `ordcmp.sh` — per-type creation-order diff of two databases (idlist).
* `resave.cpp` — Restore + Save, unchanged (the order experiment).
* `dropargs.cpp` — EXPERIMENT ONLY: erase orphan call arguments, save.
* `porttree.cpp` — the typespec tree an elaborated or definition port reads,
  with object identity and every ref's target (what uhdm-dump elides for a
  repeated object), plus the instance's Parameters and param_assigns.
* `tsrefs.cpp` — every ref_typespec pointing at a typespec at a given
  line:col, with its parent chain (which object reads which copy).
* `cen120.cpp` — the census (Q5).
* `arm.sh` / `grid.sh` — the pass-118 drivers with one fix: parallel arms get
  DISTINCT downstream names (all arms were named `arm`, so the harness's
  fixed-length Yosys run directory `/tmp/u2rds-<sha1(name/lane)>` collided
  under `xargs -P`: FileExistsError / missing run.ys). `REPO=` picks the
  harness: the pristine binary must be measured with the BASE harness (the
  main tree), because the edited one passes `--filterprotected`, which the
  pristine binary rejects (SLANG_REJECT on every arm).
* `cells.sh` — per-cell multiset score of one kind (idlist rows) against the
  downstream-lane golden.
* `fpspans.sh` — uhdm2rtlil's own Surelog with and without `-filterprotected`
  on one arm: the filler shift map measured on the producer.
* `fpcells.sh` — location multiset (r11u119 `locdump`) of ours with
  `--filterprotected` against the downstream-lane golden.
* `ylane.py` — the harness's own Yosys lane on arbitrary databases.
* `dsgold.py` — the cached downstream-lane golden path of a corpus row.
* `offbytes.sh` / `onbytes.sh` — the byte controls on arms.

## Traps met

* **The pass-118 arm driver collided under parallelism.** Every arm called the
  harness with the name `arm`. The harness's fixed-length Yosys directory is
  `/tmp/u2rds-<sha1(name/lane)>`, so parallel arms clobbered each other
  (FileExistsError, missing run.ys, spurious STATUS_DIFF). Fixed in this
  pass's `arm.sh`. The same directory is SHARED across concurrent harness
  runs of the same test name, including another pass's sweep of the same row.
* **The harness edit makes the base binary unmeasurable with the new harness.**
  `--filterprotected` is unknown to the pristine binary, so every downstream
  arm or row reads SLANG_REJECT. Pristine measurements use the main tree's
  harness.
* **The two "order" rows are not in the database.** A Restore+Save round
  trip of golden flips matching_end_labels to our exact RTLIL (Q2 (4)/(5)).
  An object-order law would have chased heap noise.
* **The brief's line numbers predate pass 119** (`:36692` is `:36837` at
  d31ae79a; `:41986` is `:42133`).
* A mistyped shell step once executed a `.uhdm` file as a script in my own
  scratch directory, which created two empty stray files there. I removed
  them. Nothing outside `/tmp/r11u120_*` was touched.

