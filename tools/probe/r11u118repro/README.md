# r11u118 — pair A, the value-and-name ground: the downstream-lane fields the judge never reads

**One targeted row converts downstream. `pkg_localparam_partsel` goes from
DIVERGENT to IDENTICAL.** The other four targeted rows are decoded down to the
field and the producer's writer. Their fixes sit in `src/ModuleEmit.cpp`, the
sister pass r11u119's file. Here they stop at the decode and are reported as
located residues R1 and R2. A scratch build that was NOT landed (the edit is
kept as `evidence/fenced_ModuleEmit_experiment.diff`) turns all five rows
IDENTICAL with uhdm-cmp at 0 lines.

Base `849800d1`, branch `matrix-1.87`. Pins per README.md: slang `7d61e0ad1`,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil `ddef9ffd`
with its own Surelog v1.87-5 (downstream lane).

| binary | md5 | what |
|---|---|---|
| pristine | `ac66a3d985fbeb31fd157e4e3b06b11e` | own worktree at `849800d1`, `-j 2`; equals the main tree's `build/slang-uhdm` |
| **LAW** | `74fb40af499ec4e3a5167de45f130ff4` | this patch, `-j 2` |
| (law cell 1 alone) | `ee85335378cab81b9ed0d4609ade125f` | intermediate build, cell 1 only; rebuilt from reverted sources to the same md5 (build determinism check) |
| (experiment, NOT landed) | `d2039d7b45b5724c865f0a324af1dbb9` | LAW cell 1 + the fenced ModuleEmit edit in `evidence/fenced_ModuleEmit_experiment.diff` |

**Surface:** `src/EmitHelpers.h` (switches + the law's doc block),
`src/ExprEmit.cpp` (three emission sites), `tools/probe/r11u118repro/`.
Nothing under `results/`, `tests/` or `third_party/`.

**Switches:** `R11U118_OFF=1` drops everything (pristine bytes on every grid
arm, `evidence/switch_g1.txt`). `R11U118_PKGPS_OFF` drops cell 1 only and
`R11U118_PKGVS_OFF` drops cell 2 only.

---

## Q1. The five heads at `849800d1`

These were reproduced with `scripts/downstream_uhdm2rtlil.py` on the frozen
pristine binary (`evidence/HEADS118.txt`, `evidence/ds_five_base.csv`). All
five rows read DIVERGENT, and uhdm-cmp between the two downstream-lane
databases reads 0 lines on all five.

| row | nohier diff (surelog lane `<`, slang lane `>`) |
|---|---|
| pkg_localparam_partsel | `connect \B 305419896` / `connect \B 0` |
| IndexedPartSelectOfMember | `connect \a [0] 1'1` / `1'x` (also `[7]`, `[8]`) |
| PartSelectOfMember | same as above |
| SelectOnMemberSelectedFrom2DArray | `connect \a [2] 1'1` / `1'x` |
| iface_array_elem_cfg_param | `connect \A 8` / `connect \A 16` |

## Q2. The decodes

### Why the judge is blind: two different mechanisms

1. **A `ref_obj` subclass never compares its name.** `part_select::Compare`
   (UHDM `build/generated/src/part_select.cpp:84`) inserts `this` into
   `m_visited` and then calls `basetype_t::Compare`, which is
   `ref_obj::Compare`. That function's own visited check (`ref_obj.cpp:129`)
   returns 0 at once, so VpiName, VpiDefName, Actual_group and everything in
   `expr` and `BaseClass` are never read. `indexed_part_select` has the same
   order. What the judge compares on a part_select is VpiConstantSelect plus
   the two range expressions, and nothing else. Measured with
   `r11u118why.cpp`: golden `part_select 'mask_pkg::MASK'` against ours
   `'MASK'` reads `fresh r=0`.
2. **A shared object hides its twin.** Golden shares the definition view's
   constant with the elaborated cont_assign. The official walk visits it
   first in `uhdmallModules`, so when it reaches the elaborated Rhs, golden's
   side is already visited and the comparison returns 0, whatever our object
   holds. uhdm-dump elides a repeated object the same way, which is why the
   two dumps read identical.

### Face 1: pkg_localparam_partsel (LANDED, § pkgQualParamPartSelName118)

* **Plugin:** `import_part_select` (uhdm2rtlil `src/frontends/uhdm/expression.cpp:6987`)
  takes the base name from **VpiDefName**, then looks it up among wires,
  module parameters, and finally `package_parameter_map` (`:7092`), which is
  keyed `pkg::NAME`. Our `MASK` falls through every lookup and the select
  imports as 0.
* **Producer:** `CompileExpression.cpp:2717` is the `paPackage_scope` arm.
  It builds `name = "pkg::NAME"` and, when the package holds the parameter,
  calls `compileSelectExpression(... name ...)` at `:2759` without
  re-locating the result. The unqualified arm does re-locate at `:2840`.
  `compilePartSelectRange` then:
  * names and def-names the part_select `pkg::NAME`;
  * stamps `VpiFullName(name)` explicitly (`:4260`, the `::` gate);
  * gives it the span of the RANGE alone (`:4262`,
    `populateCoreMembers(Constant_expression, Sibling(...))`).

  The var_select `::` gates at `:1324` and `:1365` stamp the same explicit
  fullname on a select chain.
* **Golden, measured** (`evidence/HEADS118.txt`, grid g1): the part_select has
  name, def and full `mask_pkg::MASK`, span 15:39-15:47. Its bound ref's
  fullname is `work@<m>.mask_pkg::MASK.XLEN`. The indexed twin is named the
  same way, and its fullname is the lazy `work@<m>.mask_pkg::MASK`.

### Faces 2-4: the member-select rows (RESIDUE R1, `src/ModuleEmit.cpp`)

* **The object the plugin reads.** uhdm2rtlil re-elaborates an unelaborated
  database (`uhdm2rtlil.cpp:92`, `ElaboratorContext` clone). The elaborated
  cont_assign `a.b[0] = 1` then imports its Rhs through `import_constant`
  (`expression.cpp:3747`). Ours reads `(type=0, size=0)` with an empty
  VpiValue, so the plugin logs "Unsupported constant type: 0" (`:4047`) and
  returns `x` (`evidence/plugin_debug_PartSelectOfMember_*.log`).
* **Ours:** `r11u118const` over the database shows each elaborated
  cont_assign's Rhs as a separate constant that carries only a location:
  no value, size, type, decompile or parent. It is minted at
  `ModuleEmit.cpp:36692-36696`, the `memberSelLitLhs` arm (`:34058`). The
  comment there says Surelog leaves "a BARE loc-only Rhs constant". That
  reading came from the uhdm-dump elision described above. A comment in the
  same file (the `ifaceDotFresh` branch, `ModuleEmit.cpp:34579-34584`) has already
  retracted the same misreading for interface members.
* **Producer:** `UhdmWriter::writeCont_assign` (`UhdmWriter.cpp:2254-2277`).
  The reduce hands back the def's own constant. `clone_tree` clones the
  assign; `adjustSize(tps=nullptr, …)` is a no-op for a hier_path Lhs
  (`lhs->Typespec()` is null); then `res->VpiParent(assign)` (`:2277`) and
  `assign->Rhs(res)`. The elaborated cell SHARES the def constant, with its
  parent set to the elaborated cont_assign (golden `constant#6
  parent=cont_assign#73`, listed by both cont_assigns).
* **Fix (not landed, fenced file):** at `:36692`, take
  `defInfo->contAssigns[myIdx]->Rhs()` when it is a constant, set its parent
  to `ca`, and keep the bare mint only as the fallback. Measured with the
  experiment build: grid g2 m01 moves DIVERGENT -> IDENTICAL and m04
  DIVERGENT -> EQUIVALENT; the other eight arms stay IDENTICAL. All three
  rows go IDENTICAL, cmp 0.

### Face 5: iface_array_elem_cfg_param (RESIDUE R2, `src/ModuleEmit.cpp`)

* **Plugin:** `fold_iface_param_via_chain` (`uhdm2rtlil.cpp:1079-1111`)
  follows the hier_path's `CFG` element to its `parameter`. When
  `par->Expr()` is null, it reads the value from `par->VpiParent()` if that
  parent is a `param_assign` (`:1098`). Golden's port-view parameter
  `work@top.u.s.CFG` is parented at its param_assign, whose Rhs is the
  interface DEFAULT `'{DAT: 8}`, so the surelog lane reads **8**. Ours is
  parented at the interface_inst, so the plugin falls through to
  `eval_iface_param_field`, which follows the connection to `arr[0]` and
  reads 16. uhdm-dump shows the parent line (golden `param_assign`, ours
  `interface_inst`), but the judge never reads VpiParent.
* **Producer:** `NetlistElaboration::elab_parameters_` (`:264`). An
  assignment-pattern parameter is built by
  `pclone = clone_tree(mod_assign)`, and the clone's Lhs parameter is
  parented at `pclone`. A scalar shares the def's parameter instead
  (`:450`, `inst_assign->Lhs(mod_assign->Lhs())`).
* **Fix (not landed, fenced file):** in the port-view block
  (`ModuleEmit.cpp:41962`, after `:41986`), when the def Rhs is
  `vpiAssignmentPatternOp`, parent the Lhs parameter at `pa4`. Measured with
  the experiment build on grid g3: i01 and i05 move DIVERGENT -> IDENTICAL,
  and the row goes IDENTICAL with cmp 0. The same parent law also holds on
  the i02, i03 and i04 port views, which that block does not reach (field
  diffs remain). They are downstream-IDENTICAL either way. The scalar
  port-view shares the DEF parameter in golden but is a fresh object in ours
  (i07).

## Q3. The grids

The drivers are `arm.sh`, `grid.sh` and `score118.sh`; the per-arm tables
are in `evidence/GRID118.txt`, and every arm records the rc of all four
producers. Two goldens are built per arm: the pinned v1.87 (probe flags; the
`cmp` column) and uhdm2rtlil's own v1.87-5 (downstream flags; the verdict
column).

* **g1, face 1: 39 arms.** They cross pkg localparam / pkg parameter /
  module localparam / module param / package variable / import-reached bare
  name with simple / indexed (`+:` `-:`, operation base) / bit select /
  2-D (packed and element selects, with and without a trailing range), in
  these contexts: cont_assign (ternary, concat, arithmetic, compare),
  always_comb, always_ff, function body, function argument, localparam
  init, generate if/for, interface body, port connection, a select index,
  a package-param bound, and whitespace around `::`.
  * Downstream, pristine: IDENTICAL 15, DIVERGENT 21, EQUIVALENT 2,
    STATUS_DIFF 1.
  * Downstream, LAW: **IDENTICAL 38**. The one DIVERGENT arm is p28, a
    struct-member select `pkg::CFG.f[3:0]`, which is residue R3.
  * cmp: every arm that is EQUAL at base stays 0. The NE arms keep their
    heads; their line count drops by 2 (60->58, 86->84, 104->102) because the
    decompile print loses the `vpiFullName` line once fullname == name.
  * Fields (`evidence/SCORE118_g1.txt`, exact kind + span + file + name +
    def + full per golden `::` cell): **61 of 63 with the law, 2 of 63
    pristine**. The 2 short cells are structural NE residues: p29 has no
    elaborated interface part_select, and p30 is the def-view gen-scope
    select.
* **g2, faces 2-4: 10 arms** (member bit/part/indexed/2-D/nested/sized/
  unsized-hex/whole-member, plus plain-vector controls). Pristine and LAW
  both read IDENTICAL 8 / DIVERGENT 2. The experiment reads IDENTICAL 9 /
  EQUIVALENT 1 (m01 -> IDENTICAL, m04 -> EQUIVALENT; m04 is NE at base,
  180 lines).
* **g3, face 5: 7 arms** (array element [0]/[1], single instance
  overridden/default, named modport, two-member struct, scalar). Pristine
  and LAW both read IDENTICAL 5 / DIVERGENT 2. The experiment reads
  IDENTICAL 7 (i01, i05).

## Q4. The laws (all in `src/ExprEmit.cpp`, documented in `src/EmitHelpers.h`)

* **§ pkgQualParamPartSelName118** (`R11U118_PKGPS_OFF`). This covers the
  whole-variable RangeSelect site. When the base is written qualified
  (§ pkgWrittenQualSelBase41) AND is a PARAMETER:
  * the part_select's name, def and explicit fullname are `pkg::NAME`, and
    its span is the range;
  * the indexed twin's name and def are `pkg::NAME`, with fullname
    `joinRef(prefix, pkg::NAME)`;
  * bound refs scope through `joinRef(prefix, pkg::NAME)`.
* **§ pkgQualParamVarSelFull118** (`R11U118_PKGVS_OFF`). This covers
  § pkgWrittenQualSelBase41's two var_select sites. The var_select and its
  trailing part_select carry the explicit `pkg::NAME` fullname; the bound
  and index refs keep their scoped prefixes, which golden matches.

Switch audit over the 39 g1 arms (fresh output files; `evidence/switch_g1.txt`):

| arms | law | ALL_OFF | PKGPS_OFF | PKGVS_OFF | BOTH_OFF |
|---|---|---|---|---|---|
| 25 (cell 1 arms) | moved | pristine | pristine | moved | pristine |
| 7 (cell 2 arms: p27, p34-p39) | moved | pristine | moved | pristine | pristine |
| 7 controls (p04 p07 p08 p15 p17 p25 p28) | pristine | pristine | pristine | pristine | pristine |

## Q5. Census, predicted from the pristine databases (`cen118.py`, `evidence/census_*.txt`)

A mover must carry a package-qualified select cell (part_select,
indexed_part_select or var_select whose name contains `::`) in golden or in
ours. Positive control: `pkg_localparam_partsel` reads `G=2 X=0` at base.
From the pristine sweep (4128 databases):

    surelog/{default,testflags}/Earlgrey_0_1        G=32/59  X=0  O=28/52
    surelog/{default,testflags}/EarlgreyPackParam   G=1      X=0  O=0
    uhdm2rtlil/{default,testflags}/pkg_localparam_partsel  G=2  X=0  O=0
    downstream/pkg_localparam_partsel               G=2      X=0  O=0

Predicted movers are those seven databases and no other row. The predicted
downstream movement is `pkg_localparam_partsel` DIVERGENT -> IDENTICAL, with
every other verdict unchanged.

## Q6. The gates

Both sweeps ran `tests/sweep.sh --jobs 3` from this worktree with the
`SURELOG_ROOT` / `UHDM2RTLIL_TESTS` / `UHDM2RTLIL_ROOT` / tool variables of
the ops rules. The workdirs have same-length names (`<scratch>/wdP` pristine,
`<scratch>/wdL` LAW). The `cmds.txt` files were audited by binary path:
all 3273 `slang:` lines in each workdir name that sweep's frozen binary
(`pris.bin` / `law2.bin`, `chmod 555` copies), and nothing else.

1. **Build.** Pristine `ac66a3d985fb…` equals the main tree's binary. LAW is
   `74fb40af499e…`. Both built with `-j 2`. The patch was applied to a FRESH
   `849800d1` checkout and rebuilt there (`-j 2`), which reproduces
   `74fb40af499ec4e3a5167de45f130ff4` exactly.
2. **Probe.** `EQUAL=2833 (of 2833)` on both binaries.
3. **Corpora** (row-join vs results/):
   * surelog: `regressions=0 conversions=0 changes=0`. Default is
     CMP_EQUAL=480 CMP_NOTEQUAL=3; testflags is CMP_EQUAL=474
     CMP_NOTEQUAL=3.
   * uhdm2rtlil: `regressions=0 conversions=0 changes=0`, 803/1/67 in both
     modes.
   * The status and dump columns are identical row for row between the
     pristine and LAW sweeps in both corpora (0 differing rows).
   * The dump column read against results/ drifts by 391 (surelog) and 1064
     (uhdm2rtlil) rows. The drift is `match` -> `differ`, plus Earlgrey
     testflags -> blank (the 180 s dump timeout). It reads the same on the
     pristine sweep, so it is present at `849800d1` and is not this patch.
4. **Downstream** (`evidence/DOWNSTREAM118.txt`).
   * LAW: IDENTICAL=781 EQUIVALENT=20 DIVERGENT=4 SLANG_REJECT=66 (of 871).
   * Pristine: IDENTICAL=780 EQUIVALENT=20 DIVERGENT=5 SLANG_REJECT=66.
   * Row join LAW vs pristine: exactly one verdict moves,
     `pkg_localparam_partsel` DIVERGENT -> IDENTICAL. Fresh row:
     `pkg_localparam_partsel,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.
   * Against results/, `gen_test7` reads EQUIVALENT on BOTH sweeps. That is
     the plugin-side coin (Traps below), not a mover: its database is
     byte-identical on both binaries.
   * The four other targeted rows keep their baseline DIVERGENT, because
     their fixes are R1/R2 in a fenced file.
5. **uhdm-cmp on the touched rows** stays at 0 lines:
   * the five targeted rows (downstream lane);
   * `pkg_localparam_partsel` (both corpus modes);
   * Earlgrey_0_1 and EarlgreyPackParam (CMP_EQUAL, both modes).
6. **byteverify** (`evidence/BYTEVERIFY118.txt`; SELFCHECK flagged
   959/960, 1607/1608 and 804/805):
   * surelog corpus: 8/960 movers. Earlgrey_0_1 ×2 and EarlgreyPackParam ×2
     are PREDICTED by the census. MiniAmiq ×2 and SeqDriver ×2 are the known
     UVM coin: 4 order-blind lines each, a `UINT:`/`vpiDecompile:` value
     swap (`evidence/MOVERS_orderblind.txt`).
   * uhdm2rtlil corpus: 2/1608, `pkg_localparam_partsel` both modes
     (PREDICTED).
   * downstream: 1/805, `pkg_localparam_partsel` (PREDICTED).
   * No unpredicted mover.
   * EarlgreyPackParam order-blind: 7 lines, all the law's cell
     (`part_select alert_handler_reg_pkg::AsyncOn`, span 9:50-9:55, no
     vpiFullName line), which is golden's cell.
   * Earlgrey_0_1: 192 order-blind lines (default) and 335 (testflags),
     classified in `evidence/EARLGREY_orderblind.txt`. EVERY line sits on a
     package-qualified select cell (var_select / part_select header, name,
     def, fullname) or on its bound ref's fullname. The bound refs are
     `DbgAddressBits` @dm_mem 471:75, which becomes
     `work@dm_mem.dm::HaltAddress.DbgAddressBits`, and `DataWidth`
     @prim_prince 59:55. Both now equal golden's field (checked with
     `r11u118const` on the golden database), so the census is TO-GOLDEN on
     every cell and AWAY-GOLDEN 0. The census reads `X` 0 -> 28 of 32
     (default) and 0 -> 55 of 59 (testflags); the 4 cells still short per
     mode are R7.
7. **Canaries.**
   * Against the pristine sweep: `canaries.sh` ok=52 changed=0 (surelog)
     and ok=16 changed=0 (u2r). `ctcan2.sh` PASS with EXPECT_UNKNOWN=1
     (ok=58) and EXPECT_UNKNOWN=6 (ok=2).
   * Against results/: the same CHANGED lines as the pristine sweep shows
     against results/ (ok=42/changed=10, ok=12/changed=4, ctcan2
     changed=18/2). Every one is the base-level dump-column drift described
     in item 3.

## Residues, ranked

* **R1**: the three member-select rows. `ModuleEmit.cpp:36692` mints a bare
  loc-only Rhs constant where golden shares and reparents the def constant.
  This is sister pass r11u119's ground; the proposed edit and its
  measurement are above.
* **R2**: iface_array_elem_cfg_param. The port-view aggregate-parameter Lhs
  should be parented at its param_assign (`ModuleEmit.cpp:41986`). Also
  r11u119's ground.
* **R3**: `pkg::S.f[3:0]` (g1 p28). A member select on a qualified struct
  parameter goes through the MemberAccess path; golden writes a `ref_obj
  mask_pkg::CFG` + `ref_obj f` shape. This arm is NE at base (17 lines).
* **R4**: the plain vector-select Lhs `w[1] = 1` (g2 m07 and arm a1). Our
  elaborated Rhs is a fresh size-1 constant, where golden shares the def's
  64-bit constant. It is judge-blind and downstream-IDENTICAL on every arm
  measured. It belongs to the same writeCont_assign rule as R1.
* **R5**: a package VARIABLE select (`pkg::v[7:0]`, g1 p17). Golden spans the
  ref `8:18-8:28`, ours `8:29`. The row is downstream-IDENTICAL. Not gated
  in.
* **R6**: orphan `ref_obj W` without a location under a
  `pkg::MASK[pkg::W-1:0]` bound (g1 p13 and p22). It is unreachable and
  judge-blind.
* **R7**: the DEFINITION-view generate-scope spelling of the same cell.
  `TypeEmit.cpp:16723-16749` (the syntax var_select + part_select) and
  `:16795` (the single part_select) name the qualified select correctly but
  write scope-prefixed fullnames. Golden writes `pkg::NAME` (Earlgrey
  prim_prince `gen_fwd_pass` 106:29/106:68 and `gen_bwd_pass`
  142:30/142:86, 4 cells per mode). Grid g1 p30's def-view `ref_obj
  'mask_pkg::MASK[i*8 +: 8]'` is the same syntax path. TypeEmit is fenced
  (sister pass r11u119). These cells are judge-blind and
  downstream-IDENTICAL.

## Instruments

* `r11u118const.cpp` prints every constant, parameter, cont_assign and
  select with the fields the plugin reads and the judge does not.
* `r11u118why.cpp` runs the official design Compare, then re-compares
  golden/ours pairs of one kind with a fresh context.

Build both with
`g++ -std=c++20 -O1 X.cpp -o X -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread`.
`cen118.py` is the census. `arm.sh`, `grid.sh` and `score118.sh` are the
grid drivers.

## Traps met

* **The golden cache key does not hash the source.** The downstream lane's
  cache key (`surelog_db`) is the Surelog identity + the arm path + the
  args. An arm edited after its first run is served its OLD golden (g1
  p34-p39 read EQUIVALENT on the stale golden, with off-by-one `src` lines).
  The six stale entries, keyed to this worktree's absolute path, were
  deleted and rebuilt.
* **slang-uhdm's `-o` does not truncate.** Writing over an existing, larger
  file leaves the old tail (4027 new bytes inside an 8973-byte file). The
  capnp restore ignores the tail, but byte comparisons do not. `arm.sh` now
  removes its outputs first.
* **gen_test7 is a plugin-side coin.** The pristine sweep read gen_test7
  EQUIVALENT (baseline IDENTICAL): two `update` lines swap order in a
  process. The slang database is byte-identical across 5 runs
  (`93600fca…`), and four serial re-runs read IDENTICAL. This is
  pointer-keyed ordering inside the plugin, i.e. environment, not a mover.
