# r11u161 — the definition-view generate-scope path family, the first ordered connection, and the non-package enum alias clone (analyst pass, measurement only)

Base `5a602076` (branch matrix-1.87). Worktree `/tmp/wt_r11u161`, system-deps config, `-j 2`. This directory is the
whole deliverable. The law is [law.patch](law.patch): `git diff 5a602076 -- src` over `src/TypeEmit.cpp`,
`src/ModuleEmit.cpp` and `src/UhdmExporter.cpp` (pair B's ground). It applies clean on a fresh 5a602076
(`git apply --check`, measured). It is NOT applied to `src/` in the deliverable. Nothing under `src/`, `scripts/`,
`results/`, `tests/` or `third_party/` is edited. `tools/uhdm-strictcmp` is unchanged: no canonicalisation patch was
supplied with the brief and no comparator defect was found. (The brief's standing text names the directory
`tools/probe/r11u161hp/`. Its task text names `tools/probe/r11u161gen/`, which this pass uses.)

The slang-fenced tests are never named here. Every driver that reads corpus sources or databases takes `$FENCED` from
`drivers/env.sh` (built from RESUME.md, never spelled), refuses to run without four names, and skips those rows by
word boundary. The byte comparisons ran on hard-link mirrors that leave the 8 fenced row-mode databases out
(`drivers/bvmirror.sh`). No binary, gdb session or script touched a fenced source or database. The gate sweeps ran
every row, as the gate requires.

## 0. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u161_bin/pris.bin` | `6dc4aab88e16f6e83302720c74dd53ea` | worktree build of 5a602076, byte-identical to the main tree's `build/slang-uhdm` |
| `/tmp/r11u161_bin/law.bin` | `eca16dbc9e4e2e2066ed797f4473fc07` | 5a602076 + law.patch (a rebuild from the final tidied source gives the same md5) |
| `/tmp/r11u161_bin/pris.g1` | (the `-g1` build of 5a602076) | gdb only (`drivers/ourpin.sh`) |
| `/tmp/r11u161_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the main tree's |

Every `cmds.txt` of the two gate sweeps names its binary by path: `/tmp/r11u161_swP0` has 3273 × `pris.bin`, and
`/tmp/r11u161_swL7` has 3273 × `law.bin`.

## 1. Verdict

There are three laws plus one alias rule, each under its own switch. Each law is split by axis. `R11U161_OFF`
restores pristine bytes on all 54 grid cases in both views.

| rule | switch | what golden does (decoded) | converts |
|---|---|---|---|
| § defGenPathSel161 (span + name axes) | `R11U161_ROUTE_OFF` | In the definition view, a continuous-assignment target, a gen-if / gen-case condition, a case-generate item, and the gen-for header are `net_lvalue` / `constant_expression` positions, so they are **SEL**. The base sits at the next component's token. Every field stores its own name. A selected field spans name..`]` and stores no full name. The assignment's right side is **CFC**: only its trailing select sits at its index. | surelog `GenIfIfaceParamStructField` d/t; probe `r10earl_repro/ps23`, `tj`, `r10vearl115repro/w1_memlhs`, `r11u25repro/grid/p13_member_lhs_fill0`; 9 grid cases |
| § firstOrderedPathSel161 (span + name) | `R11U161_PORT_OFF` | The **first** actual of an ordered connection list of two or more is SEL. Every later one is CFC, whatever its direction. This refines r11u157's R5 "input SEL / output CFC", which was the list position. | 4 grid cases (p03 p04 p08 p09) |
| § enumAliasClone161 (file axis = the clone's location) | `R11U161_ALIAS_OFF` (+ `R11U161_FILE_OFF`) | A module / interface / `$unit` typedef that aliases a named enum typedef is a clone of the enum: the enum's location, Instance, base typespec clone, constants, and `Typedef_alias` → the target. It lifts § elemAliasPkgScope159v's guard while it is on. | **11 downstream DIVERGENT cases → IDENTICAL** (e02 e04 e05 e07 e09 e10 e11 e12 e16 e17 e18); 5 cases stage 1 → STRICT_EQUAL per view |

Gate sweep (`tests/sweep.sh --jobs 3`, law.bin against the committed baselines):

| stage | regressions | conversions | changes |
|---|---|---|---|
| probe (4087) | 0 | 4 (EQUAL 2491 → 2495) | 1 (v6_ndecl78 `fullname(5) -> fullname(3)`) |
| surelog both modes | 0 | 2 (`GenIfIfaceParamStructField` d/t) | 6, every one smaller on a family row |
| uhdm2rtlil both modes | 0 | 0 | 0 |
| downstream (871) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, csv equal to the pristine control on every column; not identical and not excused = 0 | | |

The sweep exits 1 only on `law index STALE`. The pristine control sweep reads the same line (environmental: the
index's commit count). **Improved rows, loudly** (fresh csv rows from `/tmp/r11u161_swL7/surelog.csv`, not written
to `results/`):

    GenIfIfaceParamStructField,default,CMP_EQUAL,,,equal
    GenIfIfaceParamStructField,testflags,CMP_EQUAL,,,equal
    ComplexHierPath       d/t   differ:col(10) -> differ:endcol(4)   /  differ:col(8) -> differ:endcol(2)
    GenForStructParamBound d/t  differ:fullname(7) -> differ:fullname(3)
    Earlgrey_0_1          d/t   differ:line(1738) -> differ:line(1694)
    probe: r10earl_repro/ps23, r10earl_repro/tj, r10vearl115repro/w1_memlhs, r11u25repro/grid/p13_member_lhs_fill0 -> EQUAL

## 2. Question 1: the family's rows at 5a602076

The instrument is `drivers/row.sh` (uhdm-strictcmp `--max 50 --dump-a --dump-b` on the 5a602076 strict sweep's
databases) plus `drivers/chain.py` (each differing record with its parent chain from the record dump). Every
row-mode the brief lists was run: 24 tests, both modes, every non-fenced one. Scoreboard/testflags is SLANG_REJECT
and Rggen/testflags is SURELOG_FAIL, so neither has a database. The records are in
[evidence/q1_rows_max50/](evidence/q1_rows_max50/) and the per-row shape tally of the first 50 records is
[evidence/q1_shapes_first50.txt](evidence/q1_shapes_first50.txt).

Grouped by shape. Quoted records are golden `G:` against ours `O:`, with the parent chain after `<`.

* **cont-assign left side in a generate block (def view)**. `ComplexHierPath` #120/#121
  (`assign B.x = 0;` in gen-if `C`):
  `G: ref_obj 'B' 11:58-11:59 / O: 11:56-11:57`, `G: ref_obj 'x' full='' / O: full=work@genblk_dive_top.Z.A.B.C.x`,
  `< hier_path 'B.x' 11:56 < cont_assign < named_begin 'C' < gen_if 9:41`. `GenIfIfaceParamStructField` #257/#258
  (`assign sub.rsp_sel = sub.sel;` in the gen-if branch): `G: ref_obj 'sub' 16:18-16:25 / O: 16:14-16:17`,
  `G: rsp_sel full='' / O: full=work@child.rsp_sel`.
* **gen-if condition (def view)**. `GenIfIfaceParamStructField` #246/#249 and #263/#266 (`if (sub.CFG.HSK.DLY == 0)`,
  nested `else if`): `G: ref_obj 'sub' 15:13-15:16 / O: 15:9-15:12`, `G: DLY full='' / O: full=work@child.DLY`,
  `< hier_path < operation < gen_if_else 15:5`.
* **gen-for bound (def view)**. `GenForStructParamBound` #241/#243 (`i <= CFG.HSK.DLY`): `G: ref_obj 'CFG' 16:33-16:36 /
  O: 16:29-16:32`, `G: DLY full='' / O: full=work@bus_if.DLY`, `< hier_path < operation < gen_for`.
* **the elaborated view of the same statements** (`gen_scope`). `ComplexHierPath` #158/#161/#175:
  `G: hier_path 'B.C.x' 16:40-16:45 / O: 16:40-16:43`, `G: x full='' / O: full=B.C.x`. This is ExprEmit's mint
  (pinned below), so it belongs to pair A's ground.
* **an interface-parameter range in an interface (not generate)**. `GenForStructParamBound` #221-#224
  (`logic dly [0:CFG.HSK.DLY]`): golden stores no full names, ours stores `work@bus_if.dly.<name>`. This is a
  different writer (array_net range) and a residue.
* **a bind instance's named connection**. `mriscv_bind_sva` #23371-#23406: `G: hier_path full='' / O: full=work@...S2QED_BIND.cpu0_rs1i.<path>`,
  and the non-leaf elements likewise (`< port 'cpu0_rs1i' < module_inst 'S2QED_BIND'`). Not reproduced on fresh cases
  (`pc/p01`, `p11` are strict-equal on pristine). This is a residue.
* **the rp32 / cfg_func_width_loop bound operation (N0033 / N0025), N0049, N0774, N0912, N0030, N0273, N0204, N0799,
  N1224, N1225, N1249**. Within the first 50 records these rows show other faces: a package struct copy's file,
  UVM line faces, and the int_types gen-block net-decl initializer ref full name (`G: ref_obj 'x' full=work@top.x /
  O: ''`, `< assignment 5:23 < begin < gen_if`, N0912). The walks of Rggen, Earlgrey_0_1, Scr1SvTests, rp32_*,
  jeras_union and ibex_* **diverge** before the family objects, so the strict record list cannot reach them. For those
  rows the family is measured by the pristine-database predictor (Rggen/default 414 definition-view path candidates,
  Earlgrey_0_1 51 per mode) and by order-blind dump distances (section 5).

## 3. Question 2: the decode

### 3.1 Definition-view generate paths (golden: `CompileGenStmt.cpp` + `CompileExpression.cpp`)

`CompileHelper::compileGenStmt` (third_party/Surelog/src/DesignCompile/CompileGenStmt.cpp) compiles:

* the gen-if / gen-if-else condition (`compileExpression(component, fC, condId, ..., nullptr)`);
* the gen-case condition and every `Case_generate_item`'s `Constant_expression`. The case_item is pushed into the
  gen_case's items **without VpiParent**;
* the gen-for `Genvar_initialization` RHS, the `endLoopTest` condition, and the iteration `Lhs`/`Rhs`;
* the block body through `compileStmt(... GENERATE_STMT_PLACEHOLDER ...)`, where a continuous assignment's target is
  a `net_lvalue`.

These are `constant_expression` / `genvar_expression` / `net_lvalue` productions. They reach
`CompileHelper::compileSelectExpression`'s hierarchical branch (CompileExpression.cpp, the `Ps_or_hierarchical_identifier`
/ `slStringConst` branch):

* `r1` stores `VpiFullName(name)` and is populated from `Bit_select`, the next component's name node;
* a bare field stores its own name and span;
* a field with one index becomes a `bit_select` populated `Bit_select .. last_indexed`, which is name through `]`,
  with no stored full name;
* a range becomes `compilePartSelectRange(..., field_name, ...)`, which sets VpiDefName to the field and stores no
  full name.

The assignment's right side is an `expression`, so it takes `compileComplexFuncCall` (CFC). Its trailing select is
built by `compileSelectExpression` called from compileComplexFuncCall, located at the index. Unstored names are
computed at `Serializer::Save`.

Pinned with gdb on the pinned Surelog, own cases only ([evidence/gdb/](evidence/gdb/)):

* `gp/a04`: the LHS `sub.rsp[i]` is `compileSelectExpression < compileExpression < compileContinuousAssignment < compileStmt`.
  `sub` is at 8:16-8:19, the next component's token. `rsp` bit_select spans 8:16-8:22, full set at SAVE.
* The RHS `sub.sel[i]` is `compileComplexFuncCall < compileExpression < compileExpression`. The trailing `sel` is
  minted by `compileSelectExpression < compileComplexFuncCall` at 8:33-8:34, which is the index.
* The elaborated gen scopes have the same writers under `collectModuleObjects_`.

Ours, pinned on the `-g1` pristine build (`drivers/ourpin.sh`, [evidence/gdb/our_mints_gp_a04_pristine.txt](evidence/gdb/our_mints_gp_a04_pristine.txt)):

* the definition view is minted at TypeEmit.cpp `emitSyntaxExpr` (the hier_path mint and its element loop), called
  from ModuleEmit.cpp `emitDefGenStmts` (LHS and RHS emission);
* the elaborated view is minted at **ExprEmit.cpp `emitExpr`**, called from ModuleEmit's gen-scope emission. That
  mint is pair A's.

**When golden stores a full name on an element, measured on the grid.** SEL stores the element's own name on every
plain component, which reads empty. A SEL or CFC trailing select and its index store nothing and read through the
path: `<scope>.<path>.<field>` and `<scope>.<path>.<index>` (`work@child.g.sub.rsp[i].rsp`, `...sub.rsp[i].i`).

A CFC **middle** select keeps `path-so-far` and the scoped index. For example, probe `r10earl_repro/tj` row B
`r2h_i.cause[k].d` has `cause` full `r2h_i.cause[k]` at its name token and `k` full `work@tj.gen_a.k`. A first cut
that treated the middle select as a leaf failed this probe case, and the law was narrowed to the trailing select
before the final sweep.

A SEL path over a constant-selected base (`g[0].x`) anchors the hier_path at the base token and names the leaf by the
raw path, which is the genvar-base form. The definition view and the elaborated view differ only in the full names
computed through their parent chains. The spans and stored names are the same writers. That is why the elaborated
view needs the same rule on ExprEmit's side.

### 3.2 The first ordered connection (golden: `NetlistElaboration::high_conn_`)

gdb on `pc/p09_ordered_three_inputs` (`leaf u0 (b.d, b.e, b.f)`,
[evidence/gdb/golden_writers_pc_p09.txt](evidence/gdb/golden_writers_pc_p09.txt)):

* `b.d` is `compileSelectExpression < compileExpression < high_conn_ < elaborate_`: `b` at `d`'s token, `d` storing
  its own name;
* `b.e` and `b.f` are `compileComplexFuncCall < compileExpression < compileExpression < high_conn_`: own tokens, leaf
  `work@top.u0.j.e` at SAVE.

`pc/p08` makes the first formal an **output**, and it is SEL too. `pc/p10` has a single ordered connection, and it is
CFC. So the rule is the list position (the first of two or more). That is the same position
§ firstOrderedConnBitSelWhole147 found for a bit-select. Ours writes the path in ExprEmit `emitExpr`, then re-scopes
the leaf in ModuleEmit `emitInstance`. The law sits at that re-scope, which is pair B's file.

### 3.3 The non-package enum alias (golden: `ElaborationStep::bindTypedefs_`)

`bindTypedefs_` (ElaborationStep.cpp, the `noTypespec` branch) walks the typedefs of every file content (`$unit`),
package, module, program and class. An alias whose definition is still the DUMMY data type is bound to its target, and
then `tpclone = clone_tree(tps)`, `rt->Actual_typespec(tps)`, `tpclone->Typedef_alias(rt)`,
`tpclone->VpiName(alias)`.

gdb on `al/e02` ([evidence/gdb/golden_writers_al_e02_typespecs.txt](evidence/gdb/golden_writers_al_e02_typespecs.txt)):
`enum_typespec 31 DeepClone < bindTypedefs_ < elaboration_`, and its base `logic_typespec 33 DeepClone < DeepCopy <
DeepClone`. Id 31 is the `my_t` object uhdm-cmp names.

The clone keeps the enum's span and file (3:4-3:51, the package's typedef), its Instance (package `lp`; the module for
a module-local enum), a cloned base parented at the clone's base reference and Instanced as the target's base is
(package / none), its constants, and a folded base bound (e17 `logic [W-1:0]` → constants).

Ours built a fresh enum at the alias declaration's span, Instanced at the declaring scope, with no base typespec. The
plugin reads the width from that base, which is why the variable came out 32 / 64 bits instead of 4 / 8
(r11u159's residue 1).

## 4. The laws (question 4), in law.patch

Axes: `R11U161_SPAN_OFF` (an anchor or a span), `R11U161_NAME_OFF` (a stored full name or definition name),
`R11U161_FILE_OFF` (the alias clone's location, meaning its file together with its span), `R11U161_ALIAS_OFF`.
`R11U161_OFF` drops everything. `R11U161_TRACE=1` prints one stderr line per decision.

| law | site | rule | switches |
|---|---|---|---|
| § defGenPathSel161 | TypeEmit.cpp `defGenRoute161` + the `emitSyntaxExpr` hier_path loop; ModuleEmit.cpp `emitDefGenStmts` marks the cont_assign whose LHS is emitted (`setDefGenCaLhs161`) | route = SEL for a def-view cont_assign target, gen_if / gen_if_else / gen_case condition, parentless or gen_case case_item, gen_for condition / header assignment; CFC for the cont_assign RHS; a `?:`, pattern or concatenation on the way abstains. SEL: base at the next component's name token (also when that component is selected); leaf plain field stores its own name; selected field (literal or genvar index) spans name..`]`, stores `<scope>.<path>.<field>`; its genvar index `<scope>.<path>.<index>`; part_select gets VpiDefName = field and the same full name; a constant-selected base anchors the hier_path at itself and names the leaf by the raw path. CFC: only the trailing genvar-indexed select moves (to its index, same names) | `R11U161_ROUTE_OFF`, `_SPAN_OFF`, `_NAME_OFF` |
| § firstOrderedPathSel161 | ModuleEmit.cpp `emitInstance`, the struct-member-connection re-scope (helper `firstOrderedConn161`) | the first actual of an ordered list of ≥2, a plain dotted path: base takes the next element's span, leaf stores its own name | `R11U161_PORT_OFF`, `_SPAN_OFF`, `_NAME_OFF` |
| § enumAliasClone161 | TypeEmit.cpp `emitTypedefs` (module + interface), UhdmExporter.cpp `exportDesign` ($unit); helpers `enumAliasSyn161`, `enumAliasCloneFinish161` | an enum typedef whose target is a named enum typedef the emitter listed: build from the chain's enum syntax, copy the target's location, keep the target's Instance, base parented at its reference with the target base's Instance and folded bounds, `Typedef_alias` → the target | `R11U161_ALIAS_OFF`, `_FILE_OFF` |
| (guard) | TypeEmit.cpp § elemAliasPkgScope159v's lambda | while § enumAliasClone161 is on, the packed-array element may name a non-package alias that is a clone (has `Typedef_alias`); `R11U161_ALIAS_OFF` restores 159v's package-only guard | `R11U161_ALIAS_OFF` |

Switch table (grid, definition view, 54 cases; [evidence/grids/](evidence/grids/)):

| switch | cases byte-equal to pristine | cases that differ from law.bin |
|---|---|---|
| `R11U161_OFF` | **54 / 54** (and 54 / 54 in the elab view) | 35 |
| `R11U161_ALIAS_OFF` | 32 | 13 (the alias cases) |
| `R11U161_ROUTE_OFF` | 34 | 15 (the gp cases the route moves) |
| `R11U161_PORT_OFF` | 26 | 7 (the ordered-port cases) |
| `R11U161_SPAN_OFF` / `_NAME_OFF` | 19 / 19 | 22 / 22 (route + port cases) |
| `R11U161_FILE_OFF` | 19 | 13 (alias cases: the clone stays at the declaration span) |

## 5. Measurements (the gates)

1. **Build**: pristine md5 `6dc4aab88e16` = main tree; law md5 `eca16dbc9e4e`; strictcmp `5d4617d0458f`.
2. **Probe**: `regressions=0 conversions=4 changes=1`. Converted: `r10earl_repro/ps23`, `r10earl_repro/tj`,
   `r10vearl115repro/w1_memlhs`, `r11u25repro/grid/p13_member_lhs_fill0`. Changed toward golden:
   `r10v78repro/v6_ndecl78` 5 → 3.
3. **Corpora**: `regressions=0` in both. Surelog has conversions=2 and changes=6 (all family rows, all smaller). This
   pass reports them loudly and edits no baseline. The brief's "conversions=0 changes=0" is a verifier's criterion
   for a pass that ships nothing. uhdm2rtlil reads 0 / 0 / 0.
4. **Downstream**: 803 / 66 / 2 / 0. The downstream csv equals the pristine control's on every column. Downstream
   database byte movers: `genvar_iface_struct`, `iface_array_modport_drive` (both predicted, dump-identical, see 6).
   No row moved away from IDENTICAL.
5. **uhdm-cmp** on every mover row: 21 of 21 read 0 lines ([evidence/uhdmcmp_movers.txt](evidence/uhdmcmp_movers.txt)).
6. **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`) on fence-free mirrors of `/tmp/r11u161_swL7`
   and `/tmp/r11u161_swP0` (same-length names): `PATH_SETS_IDENTICAL (2560 paths)`, `MOVERS: 21 / 2560`, SELFCHECK
   2559 / 2560 flagged ([evidence/byteverify_law_vs_pristine.txt](evidence/byteverify_law_vs_pristine.txt)). The
   movers were **predicted by name from the pristine databases first**: `drivers/predict161.cpp` +
   `drivers/predict_all.py`, fail-closed on `$FENCED`, [evidence/predicted_candidates_from_pristine.tsv](evidence/predicted_candidates_from_pristine.tsv).
   The predictor lists ComplexHierPath, Earlgrey_0_1, GenForStructParamBound, GenIfIfaceParamStructField, Rggen/d,
   OneNetModPort, genvar_iface_struct, iface_array_modport_drive and jeras_tcb_gpio (d/t). All 15 non-coin movers
   are on that list. jeras_tcb_gpio was predicted and did not move (a superset). The other 6 movers are the UVM coin:
   MiniAmiq / SeqDriver / SimpleUVM d/t, 4 order-blind lines each, `UINT` / `vpiDecompile`
   ([evidence/uvm_coin_orderblind.txt](evidence/uvm_coin_orderblind.txt)). genvar_iface_struct and
   iface_array_modport_drive move bytes only: their uhdm-dump is identical, because the stored full names now equal
   the computed ones. Probe databases: 6 / 4087 moved (the 5 sweep movers + `w4_selmem`, EQUAL both), all 6 among the
   8 predicted.
7. **Dump distance toward golden** (order-blind, [evidence/dumpdist_movers.txt](evidence/dumpdist_movers.txt),
   [evidence/awaylines_rggen_default.txt](evidence/awaylines_rggen_default.txt)):
   * Rggen/default: 153478 → 152788. 966 lines fixed, 414 re-rendered: 207 paths whose base now copies the NEXT
     component's span, which still carries the pre-existing macro-expanded endline face (N1224: `4:28-186:3` where
     golden has `4:28-4:37`). The base column is now golden's, and its endline inherits that face.
   * ComplexHierPath 115 → 100 / 88 → 73. GenForStructParamBound 637 → 632. GenIfIfaceParamStructField 607 → 602.
     OneNetModPort 361 → 356 / 311 → 306.
   * Earlgrey_0_1 default: 747327 → 747045. 282 lines changed and all 282 moved toward golden. Earlgrey_0_1
     testflags: 7343384 → 7343182, of 282 changed lines (so 40 are re-rendered). The strict count goes 1738 → 1694
     per mode.
8. **Canaries** ([evidence/canaries.txt](evidence/canaries.txt)):
   * surelog ok=50 changed=2: Earlgrey_0_1 d/t, a predicted family mover, `line(1738) -> line(1694)`;
   * uhdm2rtlil ok=16 changed=0;
   * `EXPECT_UNKNOWN=1 ctcan2.sh` surelog ok=58 changed=0 PASS;
   * `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil ok=2 changed=0 PASS.
9. **Landed-law controls**: every committed case of r11u152repro, r11u159verify, r11u157hp, r11u118repro,
   r11v11u118repro, r11u119repro and v11u152repro (597 `dut.sv`, `drivers/bytes.sh`,
   [evidence/bytes_prior_pass_cases.tsv](evidence/bytes_prior_pass_cases.tsv)) was run on both binaries. 10 moved,
   all family cases:
   * r11u157hp `g1/c03_genif_contlhs` and `g1/c14_genfor_bound` (r11u157's R1 cases) STRICT_NOTEQUAL → **STRICT_EQUAL**;
   * `g3/q01_gen_plain_lhs` 14 → 8 differing objects; the rest are the elaborated view and the module-level
     `assign G.H.y`, both ExprEmit;
   * `g1/c18_port_ordered` still stage 1 on another head;
   * r11u159verify `ea/e02 e04 e05 e07 e08` (copied into `cases/al/`);
   * r11u152repro `EA/e03_local_alias`, unmasked to the enum-constant fold head, see 6.

   4 cases are rejected by slang on both binaries. The r11u118 / r11u119 grids, pass 152's and r11u159's laws' cases
   are byte-identical.

## 6. The grid (question 3), `cases/`, both views, goldens from the pinned Surelog

Per case, pristine against law, with downstream: [evidence/grid_table.txt](evidence/grid_table.txt). 54 cases, run
through `drivers/grid.sh` (asserts PROCESSED == LISTED) and `drivers/case.sh`, `EL=1` for the elab view
(`-elabuhdm` / `--elabuhdm`), and `drivers/dscase.py` (the harness's `one()`).

* `al/` (18: module, local enum, import, `$unit`, interface, two aliases, parameter base, chain, port, scalar,
  controls):
  * downstream **DIVERGENT → IDENTICAL on 11**;
  * strict: e02, e07, e10, e12, e17 stage 1 → STRICT_EQUAL (both views); e11 → STRICT_NOTEQUAL fullname (the
    package side's `lp::lp::tx_t` naming face, ParamEmit); e16 → STRICT_NOTEQUAL type(1);
  * e04 e05 e09 e18 stage 1 17 lines → 36 lines: unmasked to e01's pre-existing head (a bare enum constant
    `On` folded to a constant in golden's elaborated cont_assign); order-blind distance 71 → 24, 73 → 24, 95 → 48,
    67 → 24;
  * interface e08 / e13 stay stage 1 on the interface-variable face (`packed_array_var` against our `logic_var`);
    distance 123 → 98, 115 → 90;
  * controls e01, e03, e06, e14 (struct alias) and e15 (alias with an added packed dimension: Surelog compiles a fresh
    typespec, still DIVERGENT on both binaries) are byte-unchanged.
* `gp/` (25):
  * STRICT_EQUAL now: a03, a05, a06, b05, c02, e03;
  * fewer objects: a01 3 → 1, a02 8 → 4, a04 13 → 8, a07 11 → 4, c01 15 → 8, c03 19 → 10, e01 8 → 4, e02 8 → 4.
    Every remaining record is the **elaborated view** (ExprEmit, pair A) or the module-level cont-assign (ExprEmit);
  * the controls a08, b01, b02, e04 and e06 are unchanged, and e05 (a `?:` condition, abstained) is unchanged;
  * downstream IDENTICAL on all, both binaries.
* `pc/` (11): p03, p04, p08 and p09 → STRICT_EQUAL. The named / single / bind controls p01, p02, p07, p10 and p11 are
  unchanged. p05 and p06 stay stage 1 on other heads.

## 7. What is left and why (ranked by objects)

| # | residue | where | why not here |
|---|---|---|---|
| R1 | the **elaborated view** of the same generate statements: `sub` own token, selected field at the index, `x` full `A.x` (grid a01 a02 a04 a07 c01 c03 e01 e02; ComplexHierPath's remaining `endcol(4)/(2)`, r11u157 q01) | ExprEmit.cpp `emitExpr` hier_path mint (pinned: ExprEmit.cpp:31201 / :31268 at 5a602076, called from ModuleEmit's gen-scope emission) | pair A's file. The rule is § defGenPathSel161 verbatim (golden's writers are the same, under `collectModuleObjects_`). r11u157's § genTgtLhsLeafOwnName157 covers only part of it |
| R2 | Rggen macro-expanded element spans (N1224: `4:28-186:3` for `4:28-4:37`), now also on the base the law re-anchors (207 paths) | setLoc macro mapping | r11u157's R7, the macro location law |
| R3 | module-level cont-assign `sub.q[0]` / `G.H.y` (c03 line 10, q01 line 12) | ExprEmit | pair A (r11u157's route law + GENTGT) |
| R4 | mriscv_bind_sva's bind named connections (hp and non-leaf full names scoped) | ModuleEmit `emitInstance` | not reproduced by a bind in the same module or from a wrapper (p01, p11 strict-equal on pristine); the distinguisher is not modelled yet |
| R5 | a `?:` in a generate condition (the true branch is CFC) | defGenRoute161 abstains | the emitter emits the branches before the operation holds its operands; e05 keeps `col(2)` |
| R6 | the bare enum constant folded in golden's elaborated cont_assign (e01 e04 e05 e09 e18, r11u152 EA e03) | ExprEmit | another face, unmasked here |
| R7 | int_types gen-block declaration initializer ref full name (N0912), GenForStructParamBound's interface range `[0:CFG.HSK.DLY]` full names, the rp32 bound-operation copies (N0033/N0025), N0049, N0774, N0273, N0030 | various | not this family's writers; not decoded in this pass |
| R8 | alias with an added packed dimension (e15, downstream DIVERGENT on both binaries); interface alias variable form (e08 e13) | TypeEmit / ModuleEmit | Surelog compiles a fresh typespec there; the interface face is the elaborated interface variable, not the alias |
| R9 | the CFC middle-select index (the port-actual form N0799 `hw2reg.alert_cause[k].d.k` in Earlgrey) | ModuleEmit port actual in a gen block | named port actuals are not routed; N0799's golden form looks like SEL, so the connection's position rule is needed there |

No law copies an object golden holds once. The alias clone adds the objects golden's DeepClone holds (the base
typespec clone and the alias reference); every other law changes a span or a stored name only.

## 8. Files

* [law.patch](law.patch): `git diff 5a602076 -- src` (TypeEmit.cpp, ModuleEmit.cpp, UhdmExporter.cpp).
* `cases/al/` (18), `cases/gp/` (25), `cases/pc/` (11): each `dut.sv`'s first line names its shape. `al/e01`-`e08`
  are r11u159verify's `ea/` cases and `al/e09` is r11u152repro's `EA/e03`, copied with a new first line.
* `drivers/`:
  * environment and cases: `env.sh` (tools, `$FENCED`), `case.sh` (one case: golden, ours, uhdm-cmp, strict dumps),
    `grid.sh`, `dscase.py` (downstream per case);
  * row records: `row.sh`, `chain.py`, `shape.py`;
  * prediction and bytes: `predict161.cpp` + `predict_all.py`, `bytes.sh`, `bvmirror.sh` (copied from r11u159verify);
  * distances: `dumpdist.sh`, `awaylines.py`;
  * gdb: `slpin.sh` / `ourpin.sh` (r11u157hp's drivers with the tool paths rebased; they source
    r11u157hp/drivers' gdb Python and objtab).

  The C++ tools build with the uhdm_strictcmp flags (see r11u157hp/drivers/cc.sh) into `/tmp/r11u161_bin`.
* `evidence/`: `q1_rows_max50/`, `q1_shapes_first50.txt`, `gdb/`, `grids/`, `grid_table.txt`,
  `downstream_cases_{P0,law}.txt`, `sweeps/` (summaries), `byteverify_law_vs_pristine.txt`, `uvm_coin_orderblind.txt`,
  `uhdmcmp_movers.txt`, `probe_db_movers.txt`, `predicted_candidates_from_pristine.tsv`,
  `bytes_prior_pass_cases.tsv`, `dumpdist_movers.txt`, `awaylines_rggen_default.txt`, `canaries.txt`.

The landing regenerates `tests/LAWS.md`: law.patch introduces four new `§` names. This directory names them too, so
`scripts/law_index.py` will read it as their pass.
