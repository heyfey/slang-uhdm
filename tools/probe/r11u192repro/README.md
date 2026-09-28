# r11u192 — the expression/parameter ground: a part-select bound folded from a wildcard-imported package parameter named by its owning instance, the qualified package reference in a part-select range spanned at its qualifier, and the elaborated package pattern's unparented reference bound to the package typedef; 4 row-modes and 18 probe cases converted

Implementer pass (pair A, refill after pass 187). Base `a1c89c1a` (branch matrix-1.87). Ground: `src/ExprEmit.cpp` and
`src/ParamEmit.cpp` (`src/StmtEmit.cpp` and `src/EmitHelpers.h` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`,
`UhdmExporter.cpp`, `TaskFuncEmit.cpp`, `uhdm_main.cpp`, `include/`, `results/`, `third_party/`, or `tests/` other than
the regenerated law index (`tests/LAWS.md`). Net binding is not touched. Every law of the earlier passes and every
refinement stays as landed; the new code is new sites under their own switches. Worktree `/tmp/wt_r11u192`, system-deps
config, `-j 2`. The live decode r11u191 had not landed (`tools/probe/r11u191dec` absent at the start and at the end), so
item (0) did not apply and its clusters (the UVM heads N0228 / N0215 / N0229, Earlgrey's N1082, N0923, the
const_cast_signext and Scr1SvTests `type(1)` rows, the unsized package-parameter fold, the type-parameter enum copies'
location) were left to it.

## Result

| axis | base (committed = pristine sweep `swP`) | law (`swL`, `law8.bin`) | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL, default + testflags) | 458 + 454 | 458 + 454 | 0 (Earlgrey_0_1 d/t CHANGE `col(102) -> col(95)`) |
| uhdm2rtlil strict-equal (of 1606) | 790 + 790 | **792 + 792** | **+4** |
| probe EQUAL (of 4087) | 3039 | **3057** | **+18** |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | `downstream.csv` byte-identical to swP's |

**CONVERSIONS (uhdm2rtlil corpus; results/ untouched).** Fresh rows of the law sweep (`/tmp/r11u192_swL/uhdm2rtlil.csv`):

    ibex_icache,default,CMP_EQUAL,,,equal               was differ:fullname(49)   § psBoundPaOwnerName192, § genForReplCountOwner192, § procPsBoundOwner192
    ibex_icache,testflags,CMP_EQUAL,,,equal             was differ:fullname(49)
    iface_zero_width_field,default,CMP_EQUAL,,,equal    was differ:fullname(3)    § pkgPatReadTsBindsTopTypedef192
    iface_zero_width_field,testflags,CMP_EQUAL,,,equal  was differ:fullname(3)

Downstream rows of the two tests (both IDENTICAL before and after, their `_nohier.il` byte-identical between the lanes):

    ibex_icache,IDENTICAL,OK,OK,3610,3610,,
    iface_zero_width_field,IDENTICAL,NO_GATES,NO_GATES,0,0,,

**Probe CONVERSIONS (18):** `r10earl31repro/e1_psbound` (§ pkgQualBoundSpanQualifier192);
`r11u115repro/grid/r/f/p01_ibex`, `p02_replcat`, `p03_replbare`, `p04_repladd`, `p13_ternrepl`,
`r11u115repro/grid/r/k/k01_ius_lit_p01_ibex`, `k01_ius_lit_p02_replcat`, `k02_int_p01_ibex`, `k02_int_p02_replcat`,
`k04_logic4_p01_ibex`, `k04_logic4_p02_replcat`, `k09_bodyimp_p01_ibex`, `r11u115repro/grid/r/x/x01_icache_shape`,
`v11u115repro/grid/f1/a16_gf_mixed`, `a26_gf_twoinst` (§ genForReplCountOwner192 / § psBoundPaOwnerName192: pass 115's
ibex_icache-shape grid), `r11u60repro/g4`, `r11u61repro/h1` (§ psBoundPaOwnerName192).

## Binaries (frozen `chmod 555` in `/tmp/r11u192_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `5e6e8c2d6edf06661ab60336dad2f0cf` | the worktree build of `a1c89c1a`, byte-identical to the main tree's `build/slang-uhdm` (sweep `swP`) |
| `law8.bin` | `b5ff7af737f7b91618e43f0b6ebc385f` | `a1c89c1a` + this patch's sources: THE DELIVERED SOURCES (census `cen8`, gate sweep `swL`); the final worktree build is byte-identical |
| `law1.bin` ... `law7.bin` | | the development steps (section 2's grid was read on them; superseded) |
| `dbg*.bin` | | MEASUREMENT ONLY, a separate worktree `/tmp/wt_r11u192d`: every `ref_typespec` mint (and the fold's naming branch) tagged in `VpiFile` with its source line and context flags, to pin the emitter site of each record (`DBG192=1`); never swept |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's |

`/tmp/r11u192.patch` applied to a FRESH `a1c89c1a` worktree (`git apply --check` clean; whitespace warnings only, in
evidence text) builds to `b5ff7af737f7b91618e43f0b6ebc385f`, byte-identical to `law8.bin`, and reads `law index current`.

Every `cmds.txt` of both sweeps names its own binary on all 3273 `slang:` lines (`/tmp/r11u192_swP`: `pris.bin` 3273,
`/tmp/r11u192_swL`: `law8.bin` 3273; same-length workdir names).

**The fence.** No fenced test is named in this directory (grep of every file for the four names: 0). `drivers/env.sh`
reads the names from `tools/probe/r11u107repro/canaudit.sh`'s `FENCED=` line and refuses to run without four;
`drivers/census.sh` runs `verify_golden.py` / `check_probe.py` with `--filter` built from `$FENCED`;
`drivers/rows.sh` refuses a regex matching a fenced name; `drivers/bvmirror.sh` hard-links the databases leaving the
8 fenced row-mode databases out; `grid.sh`, `head.sh`, `boundary.sh`, `offcheck.sh`, `switchmatrix.sh`,
`probemovers.sh`, `chgcheck.py` refuse a fenced path. No gdb run; the gate sweeps dispatched every row as mandated.

## 1. The heads at the base (question 1)

The brief's list (1), each row's current strict column read at `a1c89c1a` (pristine sweep `swP` = the committed
baselines, `evidence/sweeps/`):

| row-mode(s) | base | first records (golden / ours) | ground |
|---|---|---|---|
| ibex_icache d/t (u2r) | `fullname(49)` | `ref_typespec` of the constant folded for `IC_LINE_W` in `fill_addr_q[i][ADDR_W-1:IC_LINE_W]` (and 48 more): `work@ibex_icache` / `work@ibex_icache.fill_addr_q.fill_addr_q` | A: **converted** (section 2) |
| iface_zero_width_field d/t (u2r) | `fullname(3)` | the package `B` pattern's struct member references: raw `work@top.p::bus_t.CTL` / `p::B.p::bus_t.CTL` | A (ParamEmit): **converted** (section 4) |
| anon_struct_packed_dim d/t (u2r) | `fullname(43)` | 39 records are member references inside the anonymous struct's `pte_t` copies (raw `gpte.pte_t.ppn` / `pte_t.ppn`: the sister's N0014, TypeEmit `buildStructTs`); 4 are N0820 (`gx` in `tq[gi].is_page[2-gx][0:0]` named through the path) | joint: not convertible on this ground alone |
| func_typename_ret d/t (u2r) | `name(2)` | the function return `logic_typespec` named `P::S` / `S` with an extra alias level (TaskFuncEmit's return typespec) | B |
| StructParamPatternInitCast d/t | `fullname(3)` | the elaborated `INT` pattern's `ref_typespec` unnamed / `work@StructParamPatternInitCast`, its struct's members `...INT.S_SW` / `...S_SW` | decoded (section 6, R3), not landed |
| FuncStructValSimple d/t | `file(39)` / `file(59)` | the `INT:2` constant-function leftovers on `typespec_member`s: unlocated / located at the call (67:46-68:35); the 1024-bit constant's reference named `cva6_config_pkg` / unnamed | not reached (R6) |
| FuncStructVal d/t | `endcol(95)` / `(165)` | `config_pkg::NOC_TYPE_AXI4_ATOP` (a package declared later): 106:16-106:28 / 106:16-106:46, then the `INT:N` leftovers (74 `file` records) | not reached (R6) |
| InterfArrayBind d | `fullname(3)` | `io_idx` in `peripheral_io_bus[io_idx].write_en` named through the path / the scope; `#183` the module-level listing that shares the definition's object | needs ModuleEmit (R7) |
| UnitElabBlock d/t, ibex_tracer d/t | `endline(13)`/`(12)`, `fullname(579)` | typespec spans (TypeEmit) first; ibex_tracer many faces | joint, not reached |

## 2. Decode: the fold substituted for a wildcard-imported package parameter is the owning instance's `param_assign` clone

**Head.** ibex_icache `fill_addr_q[i][ADDR_W-1:IC_LINE_W]` (and `lookup_addr_ic0[ADDR_W-1:IC_LINE_W]`,
`{{IC_LINE_BEATS_W{1'b0}}, ...}` in the `gen_fbs` loop, ...): golden's constant for `IC_LINE_W` is parented at the
`param_assign` of `IC_LINE_W` that the MODULE lists (the materialized import), so the reference it carries reads
`work@ibex_icache`; the constant for `ADDR_W - 1`'s `ADDR_W` hangs under its operation and reads the select's name.
Ours named every such reference after the select or the generate scope.

**Surelog.** `CompileHelper::getValue` / the reduction branches of `compileExpression` (third_party/Surelog/src/
DesignCompile/CompileExpression.cpp, the netlist and component `param_assigns` loops) substitute a parameter read by
`clone_tree(param_ass->Rhs())` and set `result->VpiParent(param_ass)`; UHDM's `BaseClass::ComputeFullName` then derives
the reference's name through the `param_assign` (unnamed) to the instance. The clone keeps that parent unless something
re-parents it: an operation takes its operands (`x[W-1:0]`: the operation parents the constant), and the elaborator's
clone of a whole continuous assignment re-parents every child. Measured (grid `cases/B`, both views, golden from the
pinned Surelog): where the `param_assign` parent survives, and where it does not.

| context of the fold (`W` wildcard-imported, unqualified, the bound ITSELF) | golden name | case |
|---|---|---|
| definition listing, any continuous-assignment RHS (`x[W:0]`, `{x[W:0]}`, `x[W:0]+1`, call argument, `$unsigned`, cast, hier-path member select, `==`, `~`) | owning module | b01 b02 b03 b16 |
| elaborated listing of a whole-RHS select (the definition's object, listed again) | the DEFINITION's module (`work@sub` in a child) | b03 b07 |
| elaborated module-body RHS re-emitted (nested select) | the select | b03 b07 (control) |
| top-level FOR-generate RHS, any nesting, and its replication count `{W{1'b0}}` | owning instance | b04 b07 b11 |
| ... unless the RHS holds an unbased unsized literal (`'0`, `'1`, `'x`, `'z`) | select / generate scope | b11 b12 |
| if / case generate scope: the select IS the whole RHS | owning instance | b06 |
| if / case generate scope: nested select, replication count | select / scope (control) | b04 b06 |
| continuous-assignment target `y[W:0]` (definition; top-level generate scopes unless the RHS is unbased unsized) | owning instance | b09 b13 b14 |
| port connection `.a(x[W:0])`, `.a({1'b0, x[W:0]})`, both listings | the INSTANTIATING instance | b10 b15 |
| process (`always_comb`, `initial`, a `for` body), a select of a select `x[i][31:W]` | owning module | b01 b05 b07 |
| function / task body | owning module (the definition's, also in the elaborated listing, which shares it) | b03 b05 b07 b09 b17 |
| elaborated net declaration assignment `wire w = x[W:0];` (nested too) | owning instance | b18 b19 |
| `W-1`, `W+1` (inside an operation), a module localparam or port parameter, a qualified `p::W` | the select (unchanged, controls) | b02 b08 b17 b18 b19 |

**Laws** (ExprEmit.cpp; the owner is read off the vpiParent chain by `ownerInstName192`: the first module / interface /
program instance, skipping the instance that owns a port when the chain passes through that port; only an instance's
own full name is read):

- § psBoundPaOwnerName192 (`R11U192_PSOWNER_OFF`) — at § caPartSelBoundFoldTs's naming branch, the bound itself
  (`psOwner9 == parent`), unqualified: the definition listing (`contAssignView == 1`), a top-level for-generate RHS
  without an unbased unsized literal (`caRhsUnbasedUnsized192`, a scan of the assignment's syntax), an if / case
  generate scope's whole-RHS select, an assignment target in the definition or a top-level generate scope, a port
  connection (`defRefModConn` / `elabConnEmit21`).
- § genForReplCountOwner192 (`R11U192_GFREPL_OFF`) — the replication count (`vpiMultiConcatOp`'s first operand) of a
  top-level for-generate RHS without an unbased unsized literal.
- § procPsBoundOwner192 (`R11U192_PROCPS_OFF`) — § procPsFold9's reference: the owner, not `prefix` (which is the select
  base's name below a select of a select: `work@top.x.x`).
- § tfPsBoundOwner192 (`R11U192_TFPS_OFF`) — § psBoundPkgParamTs31's reference in a subroutine body, the bound itself,
  an imported unqualified parameter.
- § ndaPsBoundOwner192 (`R11U192_NDAPS_OFF`) — the same in an elaborated net declaration assignment.
- § caPsSelFullVerbatim192 (`R11U192_PSVERB_OFF`) — § caPartSelBoundFoldTs's rebuild (`prefix + select name`) is for a
  select inside a hier_path; an elaborated port connection's plain select already carries its instance-qualified name
  (golden `work@top.m.u4.a.x`, ours `work@top.m.x.work@top.m.u4.a.x.x`, b15), now used verbatim.

The reference's name is set without reading anything but an instance's full name, so no lazily computed name is frozen
mid-emission; the constant keeps its vpiParent (no generated Compare reads it, and the plugin reads the value).

## 3. Decode: a qualified package reference in a part-select range spans its qualifier

**Head** (seen on the grid's controls, then on Earlgrey_0_1 and 10 probe cases): `x[p::S:0]` folds to a constant whose
span is `p::` (golden 8:17-8:20) where ours spans `p::S` (8:17-8:21). Surelog compiles a part select's range unreduced
(`compilePartSelectRange`, `Reduce::No`), so the package-scoped reference is populated from the package-scope node
and the later reduction keeps that span (the same node § pkgQualFoldSpanByView124 reads for a parameter initializer).
A bit-select index, an indexed part select's base, a plain operand and a replication count reduce at the reference and
keep the whole name (golden and ours already agree there: q01 lines 10-12, q02 line 15).

- § pkgQualBoundSpanQualifier192 (`R11U192_QBSPAN_OFF`) — a written `pkg::P` (or `(pkg::P)`) folded from a PACKAGE
  parameter or a package enum constant whose parent chain through operations (not a conditional) reaches a part
  select, outside a parameter initializer: the span ends after the last `::`. Grid `cases/Q`: q01 (every context: cont
  assign, both bounds, `p::S-1`, net declaration assignment, process, function), q02 (two-deep arithmetic, an indexed
  part select as control, a hier_path member select, an assignment target, an enum constant, a port connection, a
  concatenation, parentheses; in a child instance), q03 (the reference written through a macro from an INCLUDED file,
  a macro with an argument, a macro of this file), q04 (a named block, an `initial`), q05 (a class method: the span
  record leaves, the method-call argument's full name face remains).

## 4. Decode: the elaborated package pattern's unparented reference binds the package typedef

**Head.** iface_zero_width_field: package `p`'s `localparam bus_t B = '{CTL:0, DAT:8, STS:0}` is read by member inside
`p` (`logic [B.CTL-1:0] ctl`), so § pkgPatUnqualReadTsNoParent178 gives the elaborated package listing's pattern an
unparented reference; golden's struct members under it read `work@top.p::bus_t.CTL` (the typedef object the last
writer parents), ours `p::B.p::bus_t.CTL` (the parameter's own struct copy).

**Surelog.** getValue's qualified and component branches call `ExprEval::flattenPatternAssignments(s, opts, ...)` with
`opts` = the pattern operation's OWN typespec (CompileExpression.cpp), and UHDM's ExprEval
(templates/ExprEval.cpp) mints the unparented `ref_typespec` with `Actual_typespec(tps)`: the package typedef's object.

- § pkgPatReadTsBindsTopTypedef192 (ParamEmit.cpp `drainShareDefParamTs`, `R11U192_PATTD_OFF`) — in the ELABORATED
  package listing (`TopPackages`), the fresh unparented reference binds `pkgTopTypedefTs[<the parameter's alias>]`
  when that object is of the same kind. Grid `cases/P`: p03 (an interface importing the package), p04 (a child
  module), p05 (a qualified port type) and pass 178's own cases `r11u178repro/cases/pz/z01` and `z07` convert; pass 178's `z04`
  (the reference names now match, the next head is the `W = B.D` value's location, 4:33 golden / 5:22 ours: R4); pass
  178's `z02` and p02 do not fire (controls); p01 (qualified read in a port range), p06 (alias of an alias) are judge-unequal at pristine.

The raw uhdm-dump distance of the converted P cases grows (e.g. z01 40 -> 72 lines): golden holds a private copy of
the typedef per use, ours now shares the typedef object, and a shared object's subtree prints once. That is the
typespec-identity class GOLDEN_EQUIVALENCE.md canonicalises ("Typespec identity is canonicalised"); the canonical
record multiset (`drivers/recdist.py`) is golden's before and after, only the raw names differed, and
the strict comparator, which re-expands a typespec at every reference, reads them STRICT_EQUAL after the law
(STRICT_NOTEQUAL fullname before).

## 5. Gates

| stage | pristine `swP` | law `swL` |
|---|---|---|
| probe vs golden_probe.csv | reg 0 conv 0 chg 0 (EQUAL 3039) | **reg 0 conv 18 chg 5 (EQUAL 3057)** |
| surelog vs golden_surelog.csv | reg 0 conv 0 chg 0 | **reg 0 conv 0 chg 2** (Earlgrey_0_1 d/t `col(102) -> col(95)`) |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | reg 0 conv 0 chg 0 | **reg 0 conv 4 chg 0** |
| downstream (871) | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, `downstream.csv` byte-identical |

`only-fresh=0 only-committed=0` everywhere. Both sweeps exit 1 for one reason only, `law index STALE` (the worktree
sources carry the unlanded laws; `python3 scripts/law_index.py` regenerates `tests/LAWS.md` in this patch, after which
`--check` reads current). Logs: `evidence/sweeps/sweep_swP.log`, `sweep_swL.log`.

**Every CHANGE and CONVERSION judged** (`drivers/chgcheck.py`, `evidence/sweeps/changes_swL_vs_swP.txt`: the first
record, the walk divergence and the order-blind strict-record distance to golden): all TOWARD. Earlgrey_0_1 d/t keep
their first record (`#26470` / `#27073` `constant` flash_phy_pkg.sv 43:53 golden / 43:28 ours: N1082, r11u191's) and
fall 12940 -> 12880 / 12420 -> 12364 (22 § psBoundPaOwnerName192, 2 § pkgQualBoundSpanQualifier192, 1
§ procPsBoundOwner192 firings); ibex_icache 102 -> 4 (STRICT_EQUAL after); iface_zero_width_field 0 -> 0
(raw names only). Probe: `r10earl31repro/e4_ctrl` 34 -> 4 (`endcol(17) -> endcol(2)`: the next head is a named block's
span), `v4_ops` 28 -> 8, `v5_hier` 12 -> 4 (`endcol(6) -> fullname(2)`: the two full-name records were already there;
the 4 span records left), `r10earl_repro/vo` 16 -> 12 (`endcol(8) -> fullname(6)`: the pre-existing indexed-part-select
index names), `r10v65repro/a8_orphan` 8 -> 4 (`fullname(5) -> (2)`: an uninstantiated definition's port connections,
R5). uhdm-cmp reads 0 lines on every corpus mover (Earlgrey_0_1 d/t, ibex_icache d/t, iface_zero_width_field d/t) and
every probe case reads EQUAL or STRICT_NOTEQUAL.

**Byte movers, predicted by name first.** The firing census (`drivers/census.sh`, law binary with `R11U192_TRACE`;
`drivers/censum.py`, filtered to this pass's laws) was frozen (`chmod 444`) before the gate sweep:
`evidence/predicted_movers_192.txt` (6 corpus row-modes: Earlgrey_0_1 d/t, ibex_icache d/t, iface_zero_width_field
d/t; 23 probe databases). The census corpus csvs also read reg 0 against the baselines (fence-filtered compare).

* Corpus (`byteverify.sh` SELFCHECK on fence-free mirrors, 2560 databases, 8 fenced skipped, self-check 2559 / 2560;
  `evidence/sweeps/byteverify_corpus.txt`): **11 movers, 6 predicted** (exactly the six). The other five are the UVM
  family's known UINT / vpiDecompile order coin: MiniAmiq d/t, SeqDriver d/t, SimpleUVM d; no law of this pass fires
  on them (census), and each reads exactly 4 lines in the path-normalised order-blind uhdm-dump diff (`|UINT:a` /
  `|UINT:b` / `|vpiDecompile:a` ...; `evidence/sweeps/uvm_coin_and_distance.txt`). Earlgrey_0_1 moves by the laws
  (predicted), not by a draw.
* Probe (`drivers/probemovers.sh`, `evidence/sweeps/probemovers.txt`): **23 movers, 23 predicted**, 0 moved-not-predicted,
  0 predicted-not-moved.
* Downstream slang lane (805 databases, SELFCHECK 804 / 805; `evidence/sweeps/byteverify_downstream.txt`): **2 movers**,
  ibex_icache and iface_zero_width_field (predicted from their corpus twins), both IDENTICAL.

**Canaries** (`evidence/sweeps/canaries.txt`): `canaries.sh` surelog ok=50 changed=2 (exactly Earlgrey_0_1 d/t),
uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS; `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.

**Switches.** `evidence/switch_all_off.txt` (`drivers/offcheck.sh`): `R11U192_OFF=1` alone on the law binary writes the
pristine bytes on all 4121 cases (every tests/probe case, every case here and the four pz copies of the grid; 0
differ, 0 both-fail; positive control:
the grid below moves bytes on 64 of its 68 case-modes with the laws on). `evidence/switch_matrix.txt`
(`drivers/switchmatrix.sh`): per switch and case, ok=282 bad=0 mixed=24 (a case where two laws fire is MIXED by
construction).

**Grid** (`cases/` plus pass 178's four pz cases, 34 cases x both views, `evidence/grid_final.txt`, `drivers/gridcmp.sh`: strict verdict, record
movement, order-blind dump distance, laws fired): B 19 cases, P 6, Q 5; pass 178's pz cases z01 z02 z04 z07 were run on the same grid (`evidence/grid_final.txt`,
copied there before the copies were removed: test inputs live in one place).
Every case-mode where a law fires moves TOWARD by strict records; 42 of the 48 B/Q case-modes that fire convert to
STRICT_EQUAL; the others keep a face of another ground (b16 the streaming operand's select name, b17 the constant
function body golden keeps as a call, q05 a method-call argument's name). The P cases that convert read AWAY by raw
dump lines only (section 4: identity).

**Boundary** (`drivers/boundary.sh`, `evidence/boundary.txt`): every case of r11u118repro, r11v11u118repro,
r11u119repro, r11u124repro, r11v124repro, r11u131repro, r11v131repro, r11u168repro, r11u178repro, r11v178repro,
r11u184repro, r11v184repro, r11u187repro, v11u187repro, r11u115repro, v11u115repro, r11u133repro, r11u147repro,
r11u181repro, r11v181repro, r10earl31repro, r10earl_repro, r11u163repro, r11u167repro, r11u120repro, r11v120repro
(1568 cases, default view), pristine vs law: 32 move (two more rows are slang failures on both binaries), every mover
this pass's; 8 convert to STRICT_EQUAL (r11u118 p22, r11v11u118 w12 x07 x09, r11u178 z01 z07, r11u133 pkr/u01,
r11u163 pi/p08), the rest move TOWARD by strict records or, on judge-unequal cases, drop names or spans golden does
not hold. The eight `pkgPatReadTsBindsTopTypedef192` movers that read AWAY by raw dump lines are the identity class
of section 4 (u11_pkg_import_both, for one: the law drops `p::B.p::cfg_t.*` names golden never writes; the extra dump
lines are the shared typedef printed once).

**UVM** (item 4): no law of this pass fires on MiniAmiq, SeqDriver, SimpleUVM, Scoreboard or BuildUVMPkg; their
order-blind distance (`r11u168repro/drivers/uvmdist.sh`) is identical in both sweeps (MiniAmiq 7482, SeqDriver 6140,
SimpleUVM 2918, Scoreboard 2293). Their first records at the base: MiniAmiq / SeqDriver the typedef `file` records
(`uvm_bitstream_t`, `uvm_integral_t`, `uvm_severity`: the sister's typedef relocation, F-family file) then N0228
(`obj.get_type_name`, r11u191's) and N0224 (`space.substr` index names: the nested-index family, R2 below);
SimpleUVM / Scoreboard the `ref_typespec` full names of package parameters (`UVM_MACRO_NUMFLAGS` golden,
`uvm_pkg::UVM_MACRO_NUMFLAGS` ours: F5, ParamEmit `makeParamTs`' reference name, not reached); BuildUVMPkg N0215 /
N0229 (`uvm_report::verbosity::severity`, r11u191's).

## 6. Residues, ranked, and the sister-ground faces

R1. **anon_struct_packed_dim d/t fullname(43)**: 39 of the 43 records are the sister's N0014 (member references
inside the anonymous struct's `pte_t` copies, raw `gpte.pte_t.ppn` / `pte_t.ppn`: TypeEmit.cpp `buildStructTs`); the
4 of this ground are N0820 (`gx` in `tq[gi].is_page[2-gx][0:0]` inside an elaborated two-level generate scope, named
through the path in golden: ExprEmit `trailSelIdxNames133`'s nested-path residue, pass 187's R4). Not convertible on
ground A alone.

R2. **A path nested in another path's index** (pass 187's R4 / 178's h09; the UVM `space.substr` names N0224): not
reached; site ExprEmit `trailSelIdxNames133` (the outer path's name must be carried to the inner path's emission).

R3. **StructParamPatternInitCast d/t fullname(3)**, decoded (not landed): the elaborated `INT` param_assign's pattern
comes from NetlistElaboration.cpp's parameter clone path (`complexVal` cloned, `expandPatternAssignment(ts, ...)` with
`ts` = the parameter's own typespec), whose operation carries an UNPARENTED reference onto the PARAMETER's struct copy
(members named `...INT.S_SW`); ours parents the reference and binds the module-level struct. Module-own patterns
without a function-computed struct parameter (`evidence/residue/pat_m01`-`pat_m08`: `P.a` reads, a `localparam type`,
member values reading `Cfg.XLEN` from a pattern default) are all STRICT_EQUAL at the base, so the trigger is the
struct parameter whose value a function call computes. Site: ParamEmit's elaborated op75 (beside
§ elabPatQualRefQualSpan133); the gate needs the complex-value condition.

R4. **The member value read from a package pattern parameter is located at the pattern member's value** (`localparam
int W = B.D`: golden 4:33-4:34, ours the read 5:22-5:25; pass 178's z04, r11v178's u08 u09): the next head of those cases
after § pkgPatReadTsBindsTopTypedef192. ParamEmit's folded member read.

R5. **Port connections of an uninstantiated definition** (`r10v65repro/a8_orphan`: `u_w.a_i` / `u_b.a_i`, golden
`work@orphan8`): the § psBoundPaOwnerName192 port branch needs `defRefModConn`, which the orphan definition's connection
emission does not set; and a **streaming operand's** select (`{<<{x[W:0]}}`, b16) whose own name is `x.x` where golden
reads `x` (a pristine select-name face below the stream).

R6. **FuncStructVal / FuncStructValSimple**: the `INT:N` leftover constants that Surelog's constant-function evaluator
writes onto `typespec_member`s are unlocated in golden and located at the call in ours (74 / 20 file records), and the
1024-bit leftover's reference is named after its package (`cva6_config_pkg`) in golden; FuncStructVal's first record
(a package declared later: golden spans the qualifier of the unresolved `ref_obj`) is judge-unequal in every small
shape (pass 187's R5). Not reached.

R7. **InterfArrayBind d fullname(3)**: needs ModuleEmit (the module-level listing shares the definition's continuous
assignment, pass 181 S4); the ExprEmit half alone does not convert it.

R8. **Sister-ground faces met on the way** (not this ground): func_typename_ret (TaskFuncEmit's return typespec alias
level), UnitElabBlock / ibex_tracer typespec spans (TypeEmit), a port declaration list with several unpacked ports
(`output logic [7:0] y2 [2], y3 [2]`: the array_typespec spans the whole list, TypeEmit / ModuleEmit), and a folded
binary operation's constant spanning the operation's LEFT OPERAND in golden (`'{a: (W'(1) << (W - 1)) | W'(1)}`: golden
3:27-3:45, ours 3:27-3:53; the same shape as pass 187's R3 for arb_idx_cast's bound): a candidate cross-ground law
(ParamEmit's pattern-member fold here, TypeEmit's bound there).

R9. **Two-level generate scopes, `$unit` imports and a package function's qualified bound** are judge-unequal at the
base (golden keeps the reference: b-grid drafts removed from the cases), so the laws are gated off there
(`genNestedScopeEmit24`, the owner walk's `gens == 1`, `!inParamInit`).

## 7. Switches

| switch | law |
|---|---|
| `R11U192_PSOWNER_OFF` | § psBoundPaOwnerName192 |
| `R11U192_GFREPL_OFF` | § genForReplCountOwner192 |
| `R11U192_PROCPS_OFF` | § procPsBoundOwner192 |
| `R11U192_TFPS_OFF` | § tfPsBoundOwner192 |
| `R11U192_NDAPS_OFF` | § ndaPsBoundOwner192 |
| `R11U192_PSVERB_OFF` | § caPsSelFullVerbatim192 |
| `R11U192_QBSPAN_OFF` | § pkgQualBoundSpanQualifier192 |
| `R11U192_PATTD_OFF` | § pkgPatReadTsBindsTopTypedef192 |
| `R11U192_OFF` | every law of this pass |

`R11U192_TRACE=<dir>`: one file per process (`<dir>/<pid>.EX192`, `<pid>.PE192`), first line `OUT <-o path>`, then one
law name per firing, on every branch that changes a field.

## 8. Files

- `cases/B` (§ psBoundPaOwnerName192 and its siblings): b01 (the ibex_icache shape: concatenation + process), b02 b08
  (parameter kinds: typed, untyped, localparam, `logic [3:0]`, literal and computed; module localparam and port
  parameter controls; qualified), b03 (contexts: RHS shapes, process, function), b04 (for / if generate, replication
  count: § genForReplCountOwner192), b05 (a select of a select in a process and a function: § procPsBoundOwner192),
  b06 (if / case generate), b07 (a child instance), b09 (assignment targets, a task), b10 (a macro-born bound, a port
  connection), b11 b12 (the unbased unsized literal distinguisher in a for-generate: § genForReplCountOwner192), b13
  (targets in generate scopes and a child), b14 (an unbased unsized RHS with targets and an if scope), b15 (port
  connections: § caPsSelFullVerbatim192), b16 (definition-view nested contexts), b17 (subroutine bounds:
  § tfPsBoundOwner192), b18 (controls + one net declaration assignment), b19 (net declaration assignments:
  § ndaPsBoundOwner192).
- `cases/P` (§ pkgPatReadTsBindsTopTypedef192): p01-p06 (p02 a control; pass 178's pz cases are the rest of its grid).
- `cases/Q` (§ pkgQualBoundSpanQualifier192): q01 (positions), q02 (shapes, child instance), q03 (macros from an
  included file), q04 (named block, `initial`), q05 (class method).
- `drivers/`: `env.sh` (pins, `$FENCED`), `grid.sh` / `gridcmp.sh` (golden + ours + uhdm-cmp + strictcmp per case, both
  views; `recmv.py`, `obdist.py`), `rows.sh` / `head.sh` (named corpus rows and their strict records), `census.sh` +
  `censum.py` (the firing census = the prediction), `boundary.sh`, `bvmirror.sh`, `probemovers.sh`, `chgcheck.py`,
  `offcheck.sh`, `switchmatrix.sh` (after r11u187repro's), `obrows.sh`, `rowrec.sh`.
- `evidence/`: `predicted_movers_192.txt` (frozen before the gate sweep), `grid_final.txt`, `boundary.txt`,
  `switch_all_off.txt`, `switch_matrix.txt`, `sweeps/` (sweep logs, byteverify corpus and downstream, probe movers,
  changes judged, canaries, the UVM coin attribution and distances).
