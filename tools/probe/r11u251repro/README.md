# r11u251: pass 251, the module/type ground: the reg-typed typedef net placement, the interface dynamic-typedef twins, and the ground-B UVM heads of SimpleUVM and Scoreboard (one corpus conversion, Scoreboard default)

Base 084d871b (`matrix-1.87`). Ground: src/ModuleEmit.cpp, src/UhdmExporter.cpp, src/TaskFuncEmit.cpp, plus the new
src/R251.h (switch reader `r11u251On`, trace writer `tr251`, the net-placed variable set). Nothing under results/,
tests/ (apart from the regenerated tests/LAWS.md) or third_party/ changes.

**Headline.** One surelog corpus conversion and four probe conversions, no regression in any stage:

* **CONVERSION Scoreboard default**: `Scoreboard,default,STRICT_NOTEQUAL,differ:col(5),,differ:col(5)` ->
  **`Scoreboard,default,CMP_EQUAL,,,equal`** (law sweep row; results/ untouched).
* **Probe conversions** (law sweep rows): `r10uvm46repro/t63a,EQUAL,,equal`, `r10uvm46repro/t63c,EQUAL,,equal`,
  `r10uvm46repro/t63d,EQUAL,,equal`, `r10uvm46repro/t63e,EQUAL,,equal` (baseline STRICT_NOTEQUAL fullname(10), (20),
  (10), (10)).
* **Change SimpleUVM default and testflags**: `differ:col(5)` -> `differ:value(50)`. Every ground-B record of
  SimpleUVM is cleared. The 50 records left are on the sister ground (see "Sister-ground faces" below).
* The brief's first item: the four downstream cases of pass 249's verifier finding 1 (v11u249 N/n06, N/n10, R/r03,
  R/r05) go from **STATUS_DIFF (slang lane READ_FAIL, Yosys `Assert width >= 0 && width < RTLIL::WIDTH_LIMIT`) to
  IDENTICAL**. They also go from stage 1 to STRICT_EQUAL in both views.

## Binaries (frozen before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine (fresh 084d871b worktree, system-deps cmake config, -j 2) | 188f251c2aa8e23a6af95a77909eec69 | the same as the main tree's build/slang-uhdm |
| law (084d871b + this pass) | 6de2dcb040105726241878705123de02 | rebuilt after the last comment edit: same md5 |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | |

Both link slang 12.0.0+545f88b2e.

## Laws (src/R251.h; each `R11U251_<LAW>_OFF`, `R11U251_OFF` drops all; `R11U251_TRACE=<dir>` logs every firing)

1. **§ regTdArrElabIsNet251** (`R11U251_REGNET_OFF`; ModuleEmit, plus two skips in UhdmExporter's design-final folds;
   cases `cases/RN`). An elaborated signal written as a bare name of a `reg`-keyword unpacked-array typedef (fixed,
   dynamic, queue, associative, 2-D) is listed among the instance's **nets** (`vpiNet`), not its variables. Its
   array_var carries no vpiVisibility. Its typespec keeps the typedef's unfolded `N - 1` range.
   *Decode*: Surelog NetlistElaboration::elabSignal decides net or variable from the Signal's type. For a typedef
   written over a built-in, that type is the typedef's own keyword. `logic`, `bit` and the atoms are on the variable
   list; `reg` keeps isNet. The net branch's SIMPLE_TYPEDEF branch then hands every typespec that is not
   logic/struct/enum/bit/byte to `getSimpleVarFromTypespec`. That makes the array_var, with no visibility and the
   typedef's own typespec. With no unpacked dimension of the declarator's own, the variable lands in
   `nets->push_back((net*)obj)`.
   *Gate*: the type syntax is an unqualified identifier, the typedef's own target syntax is `RegType`, the canonical
   type is an unpacked array, the declarator has no dimensions, and no `var` keyword appears (data declaration
   modifiers or a variable port header).
   *Grid*: these cases move to vpiNet: $unit, module-body and `import p::*` typedefs; ports (ANSI and non-ANSI); two
   instances; an initializer; two declarators; a wire before and after. These stay variables in golden and are left
   alone: `p::f_t` (g08), `var` (g09), typedef over a named type (g06, g24), packed-struct element (g18), and
   `logic`/`integer`/`bit` (g05, g17). The sites are the module typedef branch (`aliasTs9`), the
   emitDynArrayVar and emitArrayVar branches, and the interface road (below). The design-final folds § unitArrTd245
   (`_elabfold`) and § modTdElabFoldSize249 skip the net-placed variables (`g251RegNetVars`).
2. **§ ifaceDynAliasNetType251** (`R11U251_IFDYNNT_OFF`; ModuleEmit emitInterfaceDef; cases `cases/IN`). This is the
   interface definition road's twin of § dynAliasNetType249, next to its § unpackedAliasNetType65 branch. On an
   instantiated interface, a definition net written as a bare typedef name whose one-level dynamic, queue or
   associative container holds an alias-free four-state packed vector or scalar gets vpiNetType 36, or 48 for `reg`.
   This is pass 249's residue 3 (v11u249 D/d02, N/n04).
3. **§ ifaceDynTdElabVar251** (`R11U251_IFDYNVAR_OFF`; ModuleEmit emitInterfaceInstance; cases `cases/IN`). In the
   interface ELABORATED home view, a bare-named typedef of a one-level dynamic, queue or associative container
   without the `reg` keyword is golden's bare array_var under vpiVariables (vpiVisibility 1). The road wrote nothing
   for it. The same branch writes the `reg` case of law 1 into the nets. A port view is not measured and is left alone.
4. **§ ppStrEndNotTokStart251** (`R11U251_PPSTREND_OFF`; UhdmExporter pp166 model; cases `cases/SC`). The pp166
   output-text model keys a token's END at its start plus slang's token text length. For a stringified literal
   (`` `"F`" `` with F = `abstractions`), that text is the produced literal (14), not the source span. When that key
   lands exactly on the next token's start, the model's ambiguity rule read the start as ambiguous and fell back to
   the unshifted body column. A start query on such a stringification end entry now reads the token start.
   *Head*: SimpleUVM default/testflags and Scoreboard default #194836 / #194848 / #195016, uvm_printer_defines.svh
   270 `p__.print_array_header(`"F`", max__, `"T``(string)`")` with F = `abstractions`. Golden column 51, ours 42.
   *Reduction*: s10 reproduces the face with the UVM macro body. s_x09 is the minimal body. The distinguisher is
   s_x15 against s_x16: `mx` against `maxxx` between the two literals. The second literal's body offset equals the
   first literal's start + 14 only with the 5-character identifier.
5. **§ clsEnumBaseRefFullName251** (`R11U251_CLSENUMBASE_OFF`; UhdmExporter buildClassTypedefTs; decode `decode/EB`).
   The base reference of a class-scoped enum typedef is named `<class full name>::<typedef>`
   (`uvm_pkg::uvm_resource_types::override_e`). Golden e01, e05 and e06 read `p::c::e_t`, e07 `work@top::c::e_t`,
   e02 `work@c::e_t`. Ours wrote the bare typedef name.
   The class name is spelled from its scope, because the class_defn may not exist yet: a method formal builds the
   listing on demand.
   *Head*: SimpleUVM #201235. The branch runs only without `--nobuiltin`, so no probe case reaches it. The decode cases
   are stage 1 under `--nobuiltin` for another reason: the class enum typedef is not listed at all.
6. **§ clsTdAssocIdxKwLoc251** (`R11U251_CLSTDIDXLOC_OFF`; UhdmExporter buildDynContainerTypedefTs; cases
   `cases/AI`). An associative index written as a keyword type in a class dynamic-container typedef
   (`typedef T tab_t[string];`, `[int]`) gets its fresh typespec located at the keyword. Golden reads
   uvm_spell_chkr.svh 30:19-30:25 for `string`, and AI a04 4:19-4:22 for `int`. Ours left the string typespec
   unlocated and put the integer one at the element token.
   *Head*: SimpleUVM #201602 / #201634. A named (typedef) index keeps its object (a09 control).
7. **§ dynTdRetTwinNoAlias251** (`R11U251_RETTWINALIAS_OFF`; TaskFuncEmit, the return-twin branch of
   § queueRetTwinDynShape191 / § queueTwinKeepsElem204v; cases `cases/RT`). The return twin of a class
   dynamic-container typedef whose element is a class TYPE PARAMETER has no Typedef_alias in golden. Ours aliased
   it to the listing.
   *Head*: SimpleUVM #202914, uvm_misc.svh 642 `typedef TYPE types_t[$]` returned by `uvm_utils::find_all`. RT r02,
   r07 and r08 are STRICT_EQUAL. Other elements (r03-r05) are stage 1 on both binaries for another reason and keep
   the alias.
8. **§ bindIfacePortRefDefName251** (`R11U251_BINDPORTREF_OFF`; ModuleEmit, inside § bindIfaceTwinInParent46's
   rename; cases `cases/BP`). A bound interface (`bind <module> <iface> <name>(...)` whose target has a parent) is
   named on the target's parent. Its port connections are named under the same parent-based path:
   * a high-conn reference reads `<target's parent>.<name>` (`work@top.clk`; the actual `work@top.dut.clk`);
   * a low-conn reference reads `<interface path>.<port>` (`work@top.add_sub_if0.clk`).

   Only plain references move. A bit select stays (b09: golden `work@top.dut.add_sub_if0.a0`, not modelled).
   *Head*: SimpleUVM's ten `add_sub_if0` port records, unmasked once #202914 cleared. Probe r10uvm46repro t63a,
   t63c, t63d, t63e convert. A module bind (b02) and a top-level target (b11) are unchanged.

## Rows (before -> after; fresh first records, `build/uhdm-strictcmp`)

| row-mode | base | law | records |
|---|---|---|---|
| Scoreboard d | `col(5)` #195016 | **CMP_EQUAL / equal** | every record cleared (law 4 on #195016, laws 5, 6, 7 behind it) |
| SimpleUVM d / t | `col(5)` #194836 / #194848 | `value(50)` #203342 | #194836 (law 4), #201235 (law 5), #201602 / #201634 (law 6), #202914 (law 7) and the ten bind port references (law 8) cleared. The 50 left are `work@top.UVM_*` parameters without a folded value: sister ground |
| BuildUVMPkg d / t | `depth(1)` #185844 | `depth(1)` #185844, unchanged | laws 5 and 6 move 2 records toward golden behind the head (away census) |
| MiniAmiq d / t, SeqDriver d / t | `type(1)` #78478 / #78434 | unchanged | laws 4-7 move 3 records per row-mode toward golden behind the ground-A head |
| Rggen d, Earlgrey_0_1 d / t | `fullname(199)`, `fullname(160)` / `(55)` | unchanged | no law fires (not attempted, see residues) |

## Gates

| gate | pristine sweep (/tmp/r11u251_wdP) | law sweep (/tmp/r11u251_wdL) |
|---|---|---|
| probe | EQUAL 3539 + STRICT_NOTEQUAL 548, 0/0/0 | **3543 + 544, regressions=0 conversions=4 changes=0** |
| surelog | default 470 + 10, testflags 466 + 8, 0/0/0 | **default 471 + 9, testflags 466 + 8, regressions=0 conversions=1 changes=2** |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | the same, 0/0/0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; the downstream csvs are equal row for row |

* The law sweep's exit code read 1 only on `law index STALE` (this pass's cases were added before the index was
  regenerated). `scripts/law_index.py --check` now reads current.
* **Row-for-row csv diff, pristine against law** (`evidence/csv_diff_pristine_law.txt`): surelog has the 3 rows
  above plus the 2 LowMem log-path text rows (environment); probe has the 4 conversions; uhdm2rtlil and downstream
  have 0 rows.
* **uhdm-cmp** reads 0 lines on every moved row-mode: every mover is CMP_EQUAL or STRICT_NOTEQUAL on both binaries.
* **Binary-path audit**: 3315 fence-filtered cmds.txt per sweep, 3265 naming a slang binary. The pristine sweep
  names only pristine.bin, the law sweep only law.bin, and neither names the main tree's binary.
* **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors from drivers/bvmirror.sh,
  same-length workdirs; mirrored=2560, fenced_skipped=8 each): PATH_SETS_IDENTICAL (2560), **MOVERS 9 / 2560**,
  SELFCHECK 2559 / 2560 flagged. The movers are BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t and
  SimpleUVM d/t.
* **Probe databases**: 4 of 4087 move (t63a, t63c, t63d, t63e). **Downstream slang lanes**: 0 of 805 move. Both path
  lists were filtered by $FENCED before any file was compared.
* **Prediction, frozen before the law sweep** (`evidence/prediction.txt`, `evidence/firings.txt`): the firing census
  (drivers/tracesweep.sh, law.bin with R11U251_TRACE, both corpora in both modes with the fenced tests excluded by
  the harness filter, plus the 4087 probe cases). It named 13 databases: the 9 surelog row-modes and the 4 probe
  cases. **Every mover was predicted by name and every predicted database moved.**
  * Laws 1, 2 and 3 fire nowhere in the corpora or the probe. Their positive control is the grid, where the trace
    fires on RN, IN and BP.
  * Per law: law 4 fires on 7 row-modes; law 5 on 9; law 6 on 9; law 7 on 7 (BuildUVMPkg has no `find_all` in its
    1800.2 copy); law 8 on SimpleUVM d/t and the 4 probe cases.
* **Away census** (drivers/away.py, the order-blind record multiset of v11u202, per mover against its cached golden;
  `evidence/away_corpus.txt`, `evidence/away_cases.txt`): **0 records lost on all 9 corpus movers**.
  * Gained per row-mode: BuildUVMPkg 2, MiniAmiq 3, SeqDriver 3, Scoreboard 3, SimpleUVM 13.
  * The 4 probe movers gain 10 or 20 records with 0 lost. The judge-equal case movers b08, b09, r01 and r06 lose 0.
  * Positive control: t63a with the binaries swapped reads `lost=10`.
* **SimpleUVM's count grows (5 -> 50)** because the walk now completes. At the base it diverged at #202914, a type
  difference ("walk diverged"), and every later record was unreported. The 50 records were masked before. The
  away census reads 0 lost.
* **Canaries** (law csvs): surelog ok=49 changed=3, the three targeted rows. uhdm2rtlil ok=16 changed=0. ctcan2
  EXPECT_UNKNOWN=1 on the surelog csv: PASS. EXPECT_UNKNOWN=6 on the uhdm2rtlil csv: PASS.
* **Determinism** (drivers/det.sh, three concurrent harness runs per binary; `evidence/det_*.txt`): one hash per
  row-mode on Earlgrey_0_1 and the five UVM rows, 11 of 11 for both binaries, each equal to its sweep's database
  (Scoreboard testflags has no database, as at the base).

## Grid (`evidence/grid.txt`, drivers/grid.sh; 93 cases in both views on 11 configurations, 2046 lines, every line with its exit code)

The 11 configurations are pristine, law, law + R11U251_OFF, and law + each of the eight switches.

* **R11U251_OFF gives pristine bytes on 186 of 186 case-views.**
* **120 case-views move, 88 enter STRICT_EQUAL, none leaves.**
* Exit codes are equal on both binaries: 182 lines exit 0 and 4 lines exit 4 (g24, a typedef of an array typedef,
  in both views on both binaries).
* No stage-1 case-view rises in uhdm-cmp lines. g10 falls from 374 to 239.
* Each switch moves only its own law's cases. The moves that cross groups are cases where two laws combine:
  REGNET on IN i02 (`reg` queue in an interface), IFDYNNT on RN g11, and CLSTDIDXLOC on RT r01 (string index).
* **Rerun**: the grid was run twice. The second run came after the SC and IN first lines were renamed to the final
  law names. Every case, tag, cmp and strict field is identical across the two runs.

| group | law | result (pristine -> law, both views alike) |
|---|---|---|
| RN g01-g27 | regTdArrElabIsNet251 | STRICT_EQUAL: g01-g04, g11, g16, g19-g22, g26 (and controls g05, g17). Stage 1 on both, other faces: g06 alias element, g07 module-body tail clones (pass 249 residue M), g08/g25 package listings (sister ground), g09 `var`, g10 golden's net-decl `cont_assign` (374 -> 239), g12/g27 port typespecs, g13 2-D, g14 own dimension (golden array_net of array_var), g15 generate-block definition view (pass 247 K/k07), g18, g23 program, g24 exit 4 |
| IN i01-i09 | ifaceDynAliasNetType251, ifaceDynTdElabVar251 | STRICT_EQUAL: i01, i02, i03, i04, i08 (and control i05). Stage 1: i06 interface-body typedef (tail clones), i07 alias element (exit 4 on both), i09 `p::d_t` |
| SC s01-s16, s_x01-s_x17 | ppStrEndNotTokStart251 | s10-s14 and the s_x reductions that hold the face enter STRICT_EQUAL. s01-s09, s15, s16, s_x14, s_x15, s_x17 are STRICT_EQUAL on both (controls) |
| AI a01-a09 | clsTdAssocIdxKwLoc251 | STRICT_EQUAL: a01, a03, a04, a05. Stage 1 on both: a02, a06 (class typedef listing under `--nobuiltin`), a08 byte/longint index, a09 typedef index (control) |
| RT r01-r08 | dynTdRetTwinNoAlias251 | STRICT_EQUAL: r02, r07, r08. r01 file -> fullname (the string index reference's stored full name in the twin, residue). r06 file face unchanged (the range constant's location). Stage 1 on both: r03, r04, r05 |
| BP b01-b11 | bindIfacePortRefDefName251 | STRICT_EQUAL: b01, b03, b05, b07, b10 (and controls b02, b11). b08 `.*`: fullname -> endcol (the `.*` span, pre-existing). b09 bit select stays fullname. b04 (`bind top.dut`) and b06 (expression actual) stage 1 on both |

**Downstream on the cases** (`evidence/ds_cases.txt`, drivers/dscases.py; this pass's cases plus v11u249 N/n04-n12,
R/r01-r05, D/d02):
* pristine reads 67 IDENTICAL / 27 EQUIVALENT / 14 STATUS_DIFF; law reads **98 / 7 / 3**;
* **no case leaves IDENTICAL**;
* v11u249 N/n06, N/n10, R/r03 and R/r05: **STATUS_DIFF -> IDENTICAL**. R/r04 (fixed `reg` typedef, wrong on pristine
  too): EQUIVALENT -> IDENTICAL.

**Byte controls** (`evidence/controls.txt`, drivers/controls.sh; 26 earlier repro dirs, 3470 case-views; paths filtered
by $FENCED before any case is opened). The dirs are r11u249repro, v11u249repro, r11u247repro, v11u247repro,
r11u245repro, v11u245repro, r11u243repro, v11u243repro, r11u160repro, v11u160repro, r11u166mac, r11u219repro,
r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11v120repro, r11u124repro, r11v124repro, r11u131repro,
r11v131repro, r11u196repro, r11u231repro, r11u191dec, r11u204verify and r10uvm46repro.
* **40 case-views move, 24 enter STRICT_EQUAL, none leaves.** The 24 are v11u249 D/d02, N/n04, n06, n09, n10, n12,
  R/r02-r05, r11u249 N/n01 and r11u191dec Q/q01.
* The other movers stay stage 1 with the same cmp line count: r10uvm46repro t63f, r11u191dec Q/q03, q05, r11u196
  V191/qr01, qr02, r11u204verify V191/qr2 (exit 4 on both), v11u247 K/k03, v11u249 M/m01.
* Exit codes are equal on both binaries: 18 exit 3, 18 exit 4, and one rc=139 (r11v124repro hx/x02_forstep,
  elaborated view, on both binaries, pre-existing).

## Residues, ranked

1. **BuildUVMPkg d/t #185844** (brief (2)(b), TaskFuncEmit / UhdmExporter design-final). The in-body formal
   `function void connect(this_type provider)` of uvm_tlm_b_initiator_socket inherits `this_type` from
   uvm_port_base. Ours binds the first-key class's `this_type` (uvm_abstract_component_registry, 13776:11); golden's
   walk reaches the function's begin with no actual there.
   * With R11U231_OOBCLSTD_OFF the head moves back to #172811 (m_check), so § oobClassTdFirstClassKey231's
     out-of-body rule is involved.
   * Decode cases `decode/TT` t01-t06 (inherited `this_type` through a parameterised `extends IF`, specialised
     interfaces, a first-key class) all agree on both binaries. The distinguisher is not isolated; not written.
2. **Rggen d #26477** (interface port-view full name, ModuleEmit) and **Earlgrey_0_1 #136315 / #142988 / #154375**
   (TypeEmit emitSyntaxExpr, ModuleEmit). Not attempted.
3. The rest of item (1):
   * (b) unitDynTdShape249's non-keyword elements (D/d07 class: golden lists a class_typespec; d08 inline enum
     and N/n03 inline struct: golden's elaborated variable is an enum_var / struct_var bound to the array_typespec,
     and the listing carries an element reference; d09 real/string). Measured, not written; the gate is unchanged.
   * (d) § clsPropWholeArrTd249 on type-parameter properties (P/p21, p22). Not attempted.
   * Law 1's open shapes: the `reg` net with an initializer (g10: golden adds a net-decl `cont_assign`), the
     generate block (g15, behind the definition-view face), ports' typespec (g12, g27), 2-D (g13), a declarator
     with its own dimension (g14: golden's array_net of array_var), program (g23).
4. Law 8's bit-select and expression actuals (b09: golden names the bit select `work@top.dut.add_sub_if0.a0`; b06).
   Law 7's string-index twin reference full name (RT r01, golden `p::c::tab_t`). The tp dynamic return twin's range
   constant location (r06).
5. Items (3)-(6) of the brief not attempted: pass 249's tail clones, unpacked unions, hybrid `[][$]`, B/b04-b07,
   C/c04-c05, exit-4 shapes, N/n01 (now STRICT_EQUAL through law 1's interface/module branches: r11u249 N/n01 entered
   STRICT_EQUAL in the controls), A/a17, U/u07; passes 247, 245, 243, 241, 239, 237 residues; the decode's
   BuildUVMPkg module/type clusters behind #185844; pass 231/228 residues.

## Sister-ground faces (ExprEmit / StmtEmit / ParamEmit / EmitHelpers.h: reported, not written)

* **SimpleUVM d/t value(50)**: the 50 `work@top.UVM_*` parameters, e.g. `work@top.UVM_ABSTRACT` (golden
  `UINT:16384`, ours no value). The module's copy of a package parameter imported at `$unit` (`import uvm_pkg::*;`
  before `module top`) carries the ELABORATED package's folded value in golden. Ours carries the definition
  listing's (none) whenever the initializer is an operation (`(1<<14)`, `UVM_MACRO_EXTRAS+3`).
  * Literal initializers are already right (`UVM_ALL_ON` BIN).
  * Decode cases `decode/HP`: h01 and h02 reproduce it (`$unit` import: A and C lack `UINT:8` / `UINT:9`); h03
    (module-scope import) is STRICT_EQUAL.
  * Writer: ParamEmit, the imported-parameter mint `up->VpiImported(occ9 ...)` in the module parameter emitter
    (§ impOcc's materialization), whose value is not folded for the module's copy.
  * **This is SimpleUVM's last face on both modes: written by the sister pass, it converts SimpleUVM d/t.**
* MiniAmiq / SeqDriver #78478 / #78434 / #78446 (StmtEmit, the dotted associative member foreach loop variable).
  BlackBePipeInt #38807 / #38803 (ParamEmit stampParenCastWidthTs). Package typedef listings of arrays (ParamEmit
  emitPackage; RN g08, g25 here). These are unchanged.

## Process

* **Fence**: nothing fenced was dispatched, read or opened outside the gate sweeps. Every driver reads $FENCED
  fail-closed. The census used the harness filter. The byteverify mirrors, the cmds.txt audit, the probe and
  downstream byte comparisons and the away census build their path lists and filter them by $FENCED before opening
  a file.
* **One process slip**: one wait loop for the firing census used `pgrep -f` on a pattern holding the census's
  workdir name. That pattern could match the loop's own shell. The loop ended on its file test, the census having
  already finished. No process was signalled, and no other agent's command line was read.
* Every tool call through a variable was guarded with `[ -x ]`. Nothing was written outside the worktree and the
  pass's own /tmp scratch.
* Temporary `R11U251_DBG` prints used during the decode were removed before the law binary was built. The source
  holds none, which grep confirms.

## Drivers (`drivers/`; each reads $FENCED fail-closed and resolves paths from the repo)

* `env.sh`, `case.sh`, `controls.sh`, `det.sh`, `bvmirror.sh`, `dscases.py`, `awayrows.py`, `flatlost.py`,
  `cc_x.sh`, `strictcmp_x.cpp` are copied from r11u249repro.
  * `case.sh`: the relative names come from this directory.
  * `dscases.py`: prints a compact verdict line.
* `grid.sh` (copied): this pass's eight switches and R11U251_OFF.
* `tracesweep.sh` (copied): R11U251_TRACE, `*.251` trace files.
* `away.py` (from v11u202repro): the order-blind away census of one database pair.
* `awaycorp.sh` (new): that census over a list of corpus movers.
