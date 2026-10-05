# r11u240 — pass 240, the expression/parameter ground (implementer)

Base `63725718` (matrix-1.87). Ground: `src/ParamEmit.cpp` and the new switch header `src/R240.h` (two laws; each
reads its own `R11U240_<LAW>_OFF`, `R11U240_OFF` drops both and restores the pristine bytes; `R11U240_TRACE=<dir>`
writes `<dir>/<pid>.240`, first line `OUT <-o path>`, then one `<law> <detail>` line per firing, every branch traced).
The four slang-fenced tests are never named here: every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh`, fail-closed; nothing fenced was dispatched outside the gate sweeps, decoded or
opened (the census ran with a `--filter` built from `$FENCED`; byteverify and the away census ran on mirrors / path
lists filtered by `$FENCED` before any file was opened).

## Verdict per targeted row (base -> this pass; fresh rows of the law sweep `/tmp/r11u240_wL`)

No row converts. Both targeted rows move their first record later or to another face with **0 golden-agreeing
records lost** (chain-keyed away census 0 on every mover).

| row-mode | base | after | first record after, and whose ground |
|---|---|---|---|
| SimpleUVM d/t | `differ:line(8)` #75572 / #75584 (`work@top.m_parent` golden uvm_phase.svh 1001:10-18, ours uvm_component.svh 1925:11-19) | `differ:file(6)` #75684 / #75696 | `m_parent` and `m_inst_count` (golden uvm_object.svh 845:10-22, ours uvm_component.svh 1763) cleared by § hoistPoolSourceOrder240. Next: the late-binding wire `work@top.this`, golden 902:36-40 with no file, ours uvm_component.svh 1767:16-20 with the file: minted by TypeEmit `thisImplicitNetBoth38`, **ground B** (sister face 1). Then the `uvm_driver` REQ/RSP face #80104 (ground B). The count falls 8 -> 6 on a first-field change; chain away 0, toward 57 per mode |
| BlackBePipeInt d | `differ:fullname(73)` #24671 | `differ:depth(1)` #38807 | N2471 cleared by § pkgImpPackedArrElemCopy240 (the 72 member references of `bp_be_pkg::all_cfgs_gp`'s element struct, at the four positions the walk lists `bp_be_pkg`'s copy). Next: in `bp_be_pkg`'s DEFINITION listing the import copy's paren-cast width reference `dev_addr_width_gp` (the int_typespec's `Cast_to_expr` of `bp_be_pkg::dev_addr_width_gp`, its param_assign constant and Lhs): golden binds a `bp_common_pkg::dev_addr_width_gp` parameter object listed nowhere else (its own int_typespec carries no cast reference), ours leaves the reference unbound (ParamEmit `stampParenCastWidthTs`, § parenCastWidthRefPkgBare207; ground A, decoded below, not written). Chain away 0, toward 288 |
| BlackBePipeInt t | `differ:fullname(75)` #24667 | `differ:fullname(3)` #38803 | the same N2471 records cleared. Next (the `-elabuhdm` view): the same reference binds golden's MODULE copy `work@bp_be_pipe_int.dev_addr_width_gp` (§ pcwElabKeepsClaim207v's claimant), ours `bp_common_pkg::dev_addr_width_gp`, whose typespec carries a cast reference golden's does not (#38806). Chain away 0, toward 288 |

Fresh rows (`/tmp/r11u240_wL/surelog.csv`, the law binary):

```
BlackBePipeInt,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
BlackBePipeInt,testflags,STRICT_NOTEQUAL,differ:fullname(3),,differ:fullname(3)
SimpleUVM,default,STRICT_NOTEQUAL,differ:file(6),,differ:file(6)
SimpleUVM,testflags,STRICT_NOTEQUAL,differ:file(6),,differ:file(6)
```

SeqDriver d/t: bytes move (its module's hoisted wires move toward golden's spans and order), verdict unchanged
(`differ:fullname(8)`, the first record on ground B), chain away 0, toward 57 per mode.
BuildUVMPkg d/t after these laws alone: bytes unchanged (no module hoists `uvm_pkg` there), first record #81218 as at the
base (`uvm_driver`'s REQ / RSP type location, ground B). UVM order-blind distance ([evidence/uvmdist.txt](evidence/uvmdist.txt),
`drivers/uvmdist.sh`): SeqDriver d/t 3201 -> 3087, SimpleUVM d/t 1234 -> 1120, MiniAmiq 4411, Scoreboard 713,
BuildUVMPkg 192 and ApbSlave 0 unchanged.

### The base's records, reproduced (question 1)

SimpleUVM default at the base (`uhdm-strictcmp --max 5`, pristine binary):

```
#75572 line
  A: 6	logic_net	m_parent		work@top.m_parent		1001	10	1001	18		0
  B: 6	logic_net	m_parent		work@top.m_parent		1925	11	1925	19		0
#75684 file
  A: 7	logic_net	this		work@top.this		902	36	902	40		0
  B: 7	logic_net	this		work@top.this	uvm_component.svh	1767	16	1767	20		0
#79910 line
  A: 9	logic_net	m_inst_count		work@top.m_inst_count		845	10	845	22		0
  B: 9	logic_net	m_inst_count		work@top.m_inst_count		1763	15	1763	27		0
```

Both databases bind the same references to these wires (golden and ours: `uvm_phase::get_parent`'s, `uvm_component::
get_parent`'s, `uvm_object::get_inst_count`'s references all take the module wire); only the mint location (and the
module's net vector order: 225 nets in both, the hoisted ones in another order) differs. BlackBePipeInt default at
the base: [evidence/blackbepipeint_default_base_head.txt](evidence/blackbepipeint_default_base_head.txt) (#24671
onwards, `raw fullname A: bp_be_pkg::all_cfgs_gp::bp_common_pkg::bp_proc_param_s::cc_x_dim | B:
work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s.cc_x_dim`); after: [evidence/blackbepipeint_heads_after.txt](evidence/blackbepipeint_heads_after.txt).
## The laws

### § hoistPoolSourceOrder240 (switch `R11U240_POOLORDER_OFF`; ParamEmit `emitPackage`, after the § pkgFreeSubRefVarHoistNet117 join)

SimpleUVM d/t #75572 (brief item 1). ModuleEmit `bindHoistedClassPropRefs` mints one implicit wire per NAME in a
module that hoists a package's out-of-body bodies, at the FIRST pool entry of that name (`classPropRefs`), and the
module's net vector follows the pool order. Surelog's pool is `mod->getLateBinding()`, which
`CompileHelper::importPackage` copies from the package ("Incomplete bindings" loop, CompileHelper.cpp), and the
package's own list is filled by `CompilePackage::compile`, which walks the package's items three times
(`collectObjects_` FUNCTION, DEFINITION, OTHER, CompilePackage.cpp): functions and tasks (the out-of-body method
definitions and the free subroutines alike) compile in the first two walks, class constructors
(`compileClassConstructorDeclaration`) in the OTHER walk only. So the list is: every function and task body in the
flattened (include-expanded, macro-expanded) text order, then every constructor body in that order. Ours filled the
pool in EMISSION order (classes in `emitPackageClasses`' order, the free subroutines appended by § 117).

Golden SimpleUVM: `work@top.m_parent` at uvm_phase.svh 1001:10-18 (`uvm_phase::get_parent`), `m_inst_count` at
uvm_object.svh 845:10-22 (`uvm_object::get_inst_count`), `this` at uvm_object.svh 902:36-40 (`uvm_object::sprint`);
pristine at uvm_component.svh 1925 / 1763 / 1767. The constructor rule is decoded on the corpus itself: without it
the law put `m_parent` at uvm_phase.svh 798 (`uvm_phase::new`, `m_parent = parent;`) and `m_inst_count` at
uvm_object.svh 799 (`uvm_object::new`), golden skips both; and on grid H/h02 (a constructor written before the
method: golden's net at the method). The macro rule was found by the first law census: keyed on
`getFullyOriginalLoc`, the `$sformatf` arguments of `svunit_testcase::report` sorted at the macro's defining header
(ahead of the package) and ApbSlave d/t left CMP_EQUAL (`error_count` 105 against golden 91:5, `test_count` against
151:3); keyed on the expansion site (`getFullyExpandedLoc`) ApbSlave reads its pristine bytes.

**Law**: this package's pool entries are stably sorted by (constructor body last, the include-expanded position of the
macro expansion site of the BODY that holds them, the body keyed by its earliest entry); entries of one body keep the
emission order (the statement walk the pool already followed). An entry without a valid location makes the law
abstain for the package (`hoistPoolSourceOrder240_abstain`, fired nowhere). The trace names a firing only when the
sequence the mint reads (the names in order of first entry, each with its first entry's location) changes;
`_same` lines write nothing. Other packages' entries and cross-package order are untouched.

Cases (§ hoistPoolSourceOrder240): H/h01 (two classes, source order against name order), h07 (a task body before a
function body, several names), h10 (a reference written through a macro), h11 (the constant slots: indexed
part-select base, replication operand, index), h12 (a virtual class with a pure virtual prototype, extern
prototypes above and below their caller, a parameterized class and its specialization typedef) convert
`STRICT_NOTEQUAL line -> STRICT_EQUAL` in both views (h07 and h11 are stage 1 at the base in the `-elabuhdm` view:
the net ORDER is read by uhdm-cmp there); h09 (class-scope enum constants and a `with` iterator, stage 1 on another
face), h13 (`this.` paths, a hoisting interface, an implicit net beside the hoist: stage 1 on the net order of the
implicit net against the hoisted one, a ModuleEmit face) and h14 (named-argument calls, a class specialization in a
bound: stage 1 on two nets golden mints that ours does not) move toward golden on every hoisted net
(dump-checked: every net's name and span equal to golden's) with unchanged uhdm-cmp line counts; h02 (a
constructor written first), h03 (a free function between two classes), h04 (two include files whose names sort
against their include order), h05 (a constructor of an earlier class against a later class's method and task), h06
(an include between a class and its out-of-body method), h08 (two packages imported by one module): pristine
already right, bytes unchanged.

### § pkgImpPackedArrElemCopy240 (switch `R11U240_IMPARRELEM_OFF`; ParamEmit `makeParamTs`, the packed-array-of-typedef branch)

BlackBePipeInt d/t #24671 / #24667 (map 15's N2471, brief item 2). Surelog re-lists every parameter a wildcard
import brings into a package (`import bp_common_pkg::*;` in `bp_be_pkg` re-lists `all_cfgs_gp`), and the copy of a
packed array of a package struct carries its own copy of the element struct, so UHDM's ComputeFullName names its
members through the importing listing: golden `bp_be_pkg::all_cfgs_gp::bp_common_pkg::bp_proc_param_s::cc_x_dim`
(raw full name, `uhdm-strictcmp --no-canon`), where ours pointed the element ref at a shared listing object whose
member references read `work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s.cc_x_dim`, a name golden gives no
object at that position (the canonical comparator excuses a copy's name only when it is one of golden's names for
the object). § pkgImpParamMemberColons210 builds this copy for a STRUCT parameter; a packed array's element did not
reach it.

**Law**: under the 210 state (an imported parameter's copy in an importing PACKAGE, `pkgImpParamTs210()`), a
packed struct or union element is rebuilt by `buildStructTs` / `buildUnionTs` with the member scope
`<listing path>::<pkg>::<typedef>` joined by `::`; the copy keeps the shared object's name, span and instance, and
its fresh member actuals take the shared members' actuals' instance (without that stamp uhdm-cmp read
`package(bp_common_pkg)` against `<null>`: the first development binary, never measured on a gate). An element of
another kind (`_kind`) or a failed build (`_nobuild`) keeps the shared object (both fire nowhere).

Cases (§ pkgImpPackedArrElemCopy240): N/n01 (the BlackBePipeInt shape; the member names in `bp`'s listing move to
golden's `bp::allc::cp::ps_t::xd`, raw walk checked; STRICT_NOTEQUAL on an earlier depth face at the base and after),
n02 (a packed union element with a dimension bound by a package localparam), n03 (a struct holding an enum and a
nested struct, a two-level re-export), n05 (the module reads a selected element's member): stage 1 at the base on
other faces, bytes move, uhdm-cmp line counts unchanged; n04 (controls: an unpacked array of the struct, a struct
parameter, a vector-typedef element): bytes unchanged.
## Binaries (frozen before any measurement; every cmds.txt audited by binary path)

| binary | md5 | note |
|---|---|---|
| pristine (`/tmp/r11u240_bin/pristine`) | `67b53b6b11f95808c8b8f655858c6f3f` | built at `63725718` with the system-deps config (`-j 2`), identical to the main tree's `build/slang-uhdm`; reports slang 12.0.0+545f88b2e |
| law (`/tmp/r11u240_bin/law`) | `ba6ec6f9038fb19f697aec5366fbd14f` | this patch (the worktree's build of the delivered sources; the delivered patch applied to a fresh `63725718` worktree and built there gives the same md5) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build of `tools/uhdm-strictcmp` |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `drivers/strictcmp_x.cpp` (map 15's variant with a fence check), built by `drivers/cc_x.sh`, for the away census |

Development binaries `dev1`-`dev7` ran only on cases and on filtered rows (SimpleUVM, BlackBePipeInt, the UVM family
and ApbSlave), plus one firing census (`dev7`, before the macro refinement below); none ran a gate. `dev8` is `law`.
Every `cmds.txt` of the pristine sweep names `/tmp/r11u240_bin/pristine` only (3273 of 3273 with a slang line), of the
law sweep `/tmp/r11u240_bin/law` only (3273 of 3273).

## Gates (from the worktree, SLANG_UHDM exported, `tests/sweep.sh --jobs 3`; [evidence/sweep_pristine.txt](evidence/sweep_pristine.txt), [evidence/sweep_law.txt](evidence/sweep_law.txt))

| stage | pristine sweep (`/tmp/r11u240_wP`) | law sweep (`/tmp/r11u240_wL`) |
|---|---|---|
| probe | EQUAL 3476 + STRICT_NOTEQUAL 611, 0 / 0 / 0 | EQUAL 3476 + 611: **regressions 0, conversions 0, changes 0** |
| surelog | 469 + 11 / 465 + 9, 0 / 0 / 0 | the same counts: **regressions 0, conversions 0, changes 4** (BlackBePipeInt d/t, SimpleUVM d/t, quoted above) |
| uhdm2rtlil | 803 + 0 per mode, 0 / 0 / 0 | **0 / 0 / 0** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | **803 / 66 / 2 / 0, not excused 0, verdict diff 0** (the two csvs sorted and diffed: 0 lines) |

Both sweeps print `law index STALE` first (the base's committed `tests/LAWS.md` predates its own commit); the patch
carries the regenerated file. uhdm-cmp on every corpus mover reads 0 lines (BlackBePipeInt d/t, SimpleUVM d/t,
SeqDriver d/t: rc 0, 0 lines, [evidence/movers/uhdmcmp.txt](evidence/movers/uhdmcmp.txt)). Canary battery on the law
csvs ([evidence/canaries.txt](evidence/canaries.txt)): `canaries.sh` surelog ok=50 changed=2 (SimpleUVM d/t, the
targeted change), unknown-names 7 (the u2r-only canaries, as expected on a surelog csv); uhdm2rtlil ok=16 changed=0 (the 25
unknown names are the surelog canaries); `EXPECT_UNKNOWN=1 ctcan2.sh` surelog ok=56 changed=2 (BlackBePipeInt d/t,
the targeted change; it reads PASS ok=58 on the pristine csv), `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS (ok=2
changed=0). `R11U240_OFF=1` with the law binary writes the pristine bytes on every corpus mover and on ApbSlave
([evidence/movers/off_corpus.txt](evidence/movers/off_corpus.txt)).

## The mover prediction, frozen before the law sweep ([evidence/census/](evidence/census/))

`drivers/census.sh` ran `law` with `R11U240_TRACE` over both corpora in both modes (`--filter` built from `$FENCED`)
and every probe case, `drivers/dscensus.py` every downstream lane (the harness's translated command line). The pool
law traces `hoistPoolSourceOrder240` only when the sequence the mint reads changes (`_same` otherwise);
`drivers/predict.py` names every database whose process fired a byte-writing branch (`_same`, `_abstain`, `_kind`,
`_nobuild` write nothing and are listed apart): **13 predicted movers** (11 surelog row-modes, 2 probe cases, 0
uhdm2rtlil, 0 downstream lanes), frozen at 2026-10-05T00:10:02 (md5 `c0d9a8daa745b2a8271a73f598248125`,
`frozen_at.txt`) before the law sweep started. Firings: hoistPoolSourceOrder240 11, `_same` 42 (ApbSlave d/t among
them), pkgImpPackedArrElemCopy240 4; `_abstain`, `_kind`, `_nobuild` 0.

**byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`, on hard-link mirrors of both sweeps without
the fenced paths, `drivers/bvmirror.sh`, same-length workdir names; [evidence/movers/byteverify.txt](evidence/movers/byteverify.txt)):
`PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS: 6 / 2560**: BlackBePipeInt d/t, SimpleUVM d/t, SeqDriver d/t, all
predicted. `SELFCHECK (every file vs one fixed file): 2559 / 2560 flagged` is the self-check reading correctly, not a
movers line: one side is replaced by one fixed file, and that file compared with itself is the one path the check
cannot flag. **Probe**: 1 of 4087 databases moves (`r10uvm81repro/c5_bindpos81`, predicted: its module's two hoisted
wires swap into golden's order, `m_b` from the task `d85::tv85` ahead of `m_s` from the constructor `c85::new`;
EQUAL in both sweeps). **Downstream lanes**: 0 of 805 lane databases differ (positive control: two different lanes
compared read as differing). [evidence/movers/probe_downstream_movers.txt](evidence/movers/probe_downstream_movers.txt).

Predicted and not moved (6): BuildUVMPkg d/t, MiniAmiq d/t and Scoreboard d (the `uvm_pkg` pool sequence changes, but
no module of these designs hoists the package's bodies: none of their databases holds a hoisted wire, so ModuleEmit
`bindHoistedClassPropRefs` reads nothing), and probe `r10uvm27repro/t37b` (its one module imports nothing). Every
mover was predicted.

## Away-moved-record census (map 13's chain-keyed census, `drivers/awayrows.py` with strictcmp_x; [evidence/movers/away.txt](evidence/movers/away.txt))

Over the 7 databases that differ between the pristine and the law sweeps: **chain-keyed away 0 on every one**,
toward 288 (BlackBePipeInt per mode), 57 (SimpleUVM and SeqDriver per mode), 0 (c5_bindpos81: an order swap).
Flat away reads 288 on BlackBePipeInt and 0 elsewhere: it is the flat key's blind spot, not a loss. The 288 flat
records are the module copy's member names (`work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s.cc_x_dim` and its 71
siblings): golden holds 323 of the first, the pristine database 125, the law database 121; the four lost occurrences
are the four `bp_be_pkg` listing positions, where golden names the record `bp_be_pkg::all_cfgs_gp::...` (the chain
key reads those 288 positions as toward).

## Determinism ([evidence/det_law.txt](evidence/det_law.txt))

`drivers/det.sh` (three concurrent harness runs on Earlgrey_0_1 and the five UVM rows, both modes, `--jobs 2` each)
with the law binary: **one hash per row-mode on all 11** (Scoreboard testflags writes no database at the base), and
each equal to the law sweep's database (SeqDriver d `0cbd048e5248`, SimpleUVM d `fb410e81b3e3`, ...). The pool law
sorts by include-expanded source keys (no address order); ties keep the emission order.

## Grid (cases/, 19 cases, both views; `drivers/grid.sh`, `drivers/gridsum.py`; [evidence/grid.txt](evidence/grid.txt), [evidence/grid_summary.md](evidence/grid_summary.md))

190 runs (pristine, law, law with `R11U240_OFF`, the law with each of the two switches; default and `-elabuhdm`
views), **every exit code 0**. `R11U240_OFF` writes the pristine bytes on 38 of 38 case-views; each switch alone
reverts exactly its own law's cases (POOLORDER 16, IMPARRELEM 8 case-views). 24 case-views move bytes; **10 enter
STRICT_EQUAL (two of them from stage 1: h07 and h11 in the `-elabuhdm` view, whose net order uhdm-cmp reads), none
leaves**; no uhdm-cmp line count changes on any stage-1 case (h09 96, h13 32, h14 90/44, n02 245, n03 1038, n04 82,
n05 58/66 on both binaries). The stage-1 cases a law moves were checked against golden on what the law writes: every
hoisted wire's name and span equal to golden's on h09, h13 and h14 in both views (dump-checked); the importing
package's member reference names on n02, n03, n05 ([evidence/n_cases_rawnames.txt](evidence/n_cases_rawnames.txt):
golden-agreeing raw full names 12 -> 16, 8 -> 14, 12 -> 16, none ours-only before or after) and n01 (raw walk:
`bp::allc::cp::ps_t::xd` where pristine wrote `work@top.cp::ps_t.xd`). Fresh-case coverage for the brief's list:
`this.` paths and a hoisting interface body and an implicit net (h13), a class specialization in a bound and linked /
unlinked named calls (h14), extern prototypes above and below their caller and a pure virtual prototype, a
parameterized class specialization (h12), macro-born references (h10), include files (h04, h06), the constant slots
(h11; for the element law the dimension bound by a package localparam, n02, n05).

## Process notes

- Every command ran from the worktree `/tmp/wt_r11u240` (base `63725718`); scratch under `/tmp/r11u240_*`; the main
  checkout was never written (its `git status` is clean, the submodules too). No submodule was initialised in the
  worktree. No process of another agent was listed or signalled; this pass killed nothing.
- **Fence**: while locating the fence line at the start, one `grep -n FENCED= tools/probe/r11u107repro/canaudit.sh`
  printed that line (the four names) to this session's output once; nothing else was done with it (no binary,
  script or reader touched a fenced test or database outside the gate sweeps; every later read of the line went into
  a variable).
- Every tool reached through a variable was guarded (`[ -x ]` in env.sh / case.sh and before every uhdm-dump and
  uhdm-cmp call); no database was executed.
- Decode runs of the producer (`$SURELOG`) on scratch copies of shapes and on one probe case's source
  (`tests/probe/r10uvm81repro/c5_bindpos81`, output under the scratch) read only unfenced sources.
- The first census (`dev7`) found the ApbSlave regression (the macro rule); the law was refined, the census redone
  with the final binary, the prediction frozen, and only then the law sweep ran.
- Two case files were rewritten after a first run because they were illegal SV (h03 read an undeclared name in a
  free function; h11 used a non-constant replication count); every grid number is the final files'. Two decode-only
  cases (a paren-cast width parameter re-listed in an importing package, a typedef'd string property) were removed
  from `cases/` because they name no law; their findings are below.

## Drivers (`drivers/`; every one reads `$FENCED` fail-closed, compiled helpers included)

`env.sh`, `case.sh`, `grid.sh` (the grid; `LAWBIN` overrides the law binary), `gridsum.py`, `census.sh`,
`dscensus.py`, `predict.py` (the prediction; non-writing trace tags listed apart), `bvmirror.sh`, `det.sh`,
`uvmdist.sh`, `awayrows.py`, `strictcmp_x.cpp` + `cc_x.sh` (all copied from r11u238repro, switches and trace names
updated).
## Sister-ground faces (decode only, call sites)

1. **SimpleUVM d/t #75684 (the new first record)**: the late-binding wire `work@top.this`. Golden mints it at
   uvm_object.svh 902:36-40 (`uvm_object::sprint`'s `printer.print_object(get_name(), this)`) with NO file, ours at
   uvm_component.svh 1767:16-20 (`uvm_component::new`'s `if (parent == this)`) WITH the file. Ours is minted by
   TypeEmit `thisImplicitNetBoth38` (§ thisImplicitNetBoth38), which picks its anchor as the minimum of
   (VpiFile string, line, column) over the hits: the file NAME's alphabetical order, not Surelog's late-binding
   order, and it never notes the net for § implicitNetMintNoFile131's file clear. The rule this pass decodes for the
   pool (§ hoistPoolSourceOrder240: function and task bodies in the flattened text order, constructors last) is
   consistent with golden's anchor: the first non-path `this` written in a function body in the flattened UVM text
   is uvm_object.svh 902 (`sprint`; the earlier `this.srandom(...)` at 809 is a hier_path element, which
   § thisImplicitNetBoth38's position half already excludes), and `uvm_component::new` is a constructor. The two
   edits in TypeEmit (not made, not measured): anchor by the include-expanded position of the macro expansion site
   of the enclosing body with constructors last, and clear the file of a definition-listing net (the § 119 / § 131
   rule).
   After this pass's laws it is the only differing late-binding net of SimpleUVM (m_parent and m_inst_count are
   cleared), and then the row's next records are the `uvm_driver` REQ / RSP faces (#80104, class body writers).
2. **BuildUVMPkg d/t #81218, Scoreboard d #80496**: unchanged by this pass (pass 238's decode stands: `uvm_driver`'s
   type-parameter-typed properties located at the specialization typedef's argument; UhdmExporter / TypeEmit class
   body writers).
3. **MiniAmiq d/t #68597, SeqDriver d/t #68553**: unchanged (TaskFuncEmit, the body-local associative array
   typespec's full names in a class-method clone).
4. **Pass 238's residue (3)(b) — a typedef'd string property** (`typedef string str_t; class b; str_t m_al; ...`):
   at the base the case is stage 1 at `package(p) > class_defn(b) > string_var(m_al) > string_typespec`: golden
   gives the property a `string_typespec` named `str_t`, ours binds the package typedef `p::str_t`. The class
   property declaration writer (UhdmExporter emitClassDefn's property branch / TypeEmit), not the foreach law.
5. **Pass 238's residue (3)(f) — d01**: `slang-uhdm: unsupported constructs encountered: class property type:
   FixedSizeUnpackedArrayType` (exit 4 on every binary) for a class property typed by `typedef int f2_t[2][3];`:
   UhdmExporter's class property switch (the branch that notes "class property type: ...") has no branch for a typedef'd
   multi-dimensional fixed unpacked array.
6. **Pass 238's residue (3)(f) — d03**: stage 1 at the base at `package(p)`: golden writes `typedef int iq_t[$];` and
   `typedef int id_t[];` as `array_typespec` (with the queue / dynamic marker range), ours as `int_typespec` named
   `p::iq_t` / `p::id_t` at the element keyword (4:11-14 against golden's 4:11-22): the package typedef writer
   (TypeEmit), not the clone loop variable.
## Residues, ranked (ground A first)

1. **BlackBePipeInt d #38807 / t #38803 (the rows' new first records, ParamEmit `stampParenCastWidthTs`, § parenCastWidthRefPkgBare207)**:
   in `bp_be_pkg`'s re-listed copy of the paren-cast width parameter `dev_addr_width_gp` (and of its param_assign
   constant and Lhs) the int_typespec's `Cast_to_expr` reference `dev_addr_width_gp`: in the DEFINITION view golden
   binds a parameter object `bp_common_pkg::dev_addr_width_gp` (1793:12-29, UINT:20) that appears in no listing
   (the strict walk expands it fresh three times, records #38808, #39309, #39316, and its own int_typespec has no
   cast reference, unlike both package listings' copies), ours leaves the three references unbound; in the
   `-elabuhdm` view golden binds the module copy `work@bp_be_pipe_int.dev_addr_width_gp` (no cast reference on its
   typespec either), ours the declaring package's listed parameter. Writing it needs an unlisted copy of the
   parameter whose typespec drops the cast reference (default view) and the module claimant for an importing
   package's listing (elab view); a small shape (`package cp; localparam AW = 20; localparam B0 = (AW)'('h0_4000);`
   re-listed by an importing package, a module importing both) is stage 1 at the base on the module copy of `B0`
   (golden folds it to `UINT:16384`, ours keeps the cast operation; with a module parameter the package listing
   itself differs), so the decode grid needs another shape first. Then the row holds map 15's N0028, N0118, N0873.
2. **h14's two wires**: golden mints `a` and `b` (the formals of a free package function `f2(int a, int b = 2)`,
   `return a + b;`) as hoisted wires of the importing module when an out-of-body method calls it as
   `f2(.a(g), .b(g)) + f2(.a(g))`; ours does not. Not a named call with an omitted default alone (a call `f2(.a(g))`
   or `f2(g)` alone mints only `g` in golden, checked with the producer); the distinguisher is not decoded. The
   pool order of this pass already puts golden's `g` where golden has it.
3. The brief's items (3) (a), (c), (d), (e) (clone byte loop variables k07, the `fac::m_s[k]` spelling, the re-export
   chain copy, b02's moving record), (4) (pass 236's and 232's residues), (5) (BuildUVMPkg's expression/parameter
   clusters behind the ground-B record #81218, which this pass does not move), (6) and (7): not attempted.
4. Items (3)(b) and (3)(f) are characterized and sit on ground B (sister faces 4-6 below).
