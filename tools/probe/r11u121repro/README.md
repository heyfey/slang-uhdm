# r11u121 — the cast to a type parameter in an elaborated generate scope, the select on a member of a qualified package parameter, and the qualified package-variable read

**THE TARGET ROW CONVERTS DOWNSTREAM: `arb_idx_cast` EQUIVALENT -> IDENTICAL.**
Fresh row from the LAW sweep's `downstream.csv`:

```
results/downstream_uhdm2rtlil.csv: arb_idx_cast,EQUIVALENT,OK,OK,11,11,nohier il synth,✅ Formal equivalence check PASSED ...
LAW sweep:                         arb_idx_cast,IDENTICAL,OK,OK,11,11,,
```

Downstream 794 / 7 / 4 / 66 -> **795 IDENTICAL / 6 EQUIVALENT / 4 DIVERGENT / 66
SLANG_REJECT** of 871. No other row moves. `results/` was NOT edited; the
master promotes the row.

Base `d31ae79a` (branch matrix-1.87). Pins per README.md: slang `7d61e0ad1`,
Surelog v1.87 `0445655e` (UHDM `c7562484`) as the judge, uhdm2rtlil `ddef9ffd`
with its own Surelog v1.87-5-g04a865c0 as the downstream lane.

| binary | md5 | what |
|---|---|---|
| pristine | `3e6d2800759fb6ea476700223ab73bb0` | own worktree at `d31ae79a`, `-j 2`; equal to the main tree's `build/slang-uhdm` |
| **LAW** | `6e0b0cef42b4bbb23d812ada31135a65` | this patch; the SAME md5 when the patch is applied to a fresh `d31ae79a` worktree and rebuilt |

**Surface.** `src/ExprEmit.cpp` only (four laws), plus this directory.
`EmitHelpers.h`, `StmtEmit.cpp`, `ParamEmit.cpp`, the sister's files
(`TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp`), `include/`, `results/`, `tests/` and `third_party/` are
absent from the patch.

---

## 1. The head at `d31ae79a` (Q1)

`python3 scripts/downstream_uhdm2rtlil.py --filter '^(arb_idx_cast)$'` on the
pristine binary: EQUIVALENT, differs `nohier il synth`. The nohier diff is 96
lines (`evidence/ARB_NOHIER_PRIS.diff`). Its non-renumbering content:

```
< autoidx 27                                   > autoidx 31
< wire width 2 $auto$rtlil.cc:3402:Mux$10     > attribute \src "dut.sv:31.13-31.80"
                                               > wire width 32 $auto$expression.cpp:6227:import_operation$9
                                               > attribute \src "dut.sv:32.13-32.78"
                                               > wire width 32 $auto$expression.cpp:6227:import_operation$11
                                               > wire width 32 $auto$rtlil.cc:3402:Mux$14
< cell $mux $mux$dut.sv:30$9  WIDTH 2          > cell $pos ...import_operation$10  A_WIDTH 2 Y_WIDTH 32  A { 1'1 \index_nodes [4] }
                                               > cell $pos ...import_operation$12  A_WIDTH 2 Y_WIDTH 32
                                               > cell $mux $mux$dut.sv:30$13  WIDTH 32
```

The uhdm-dump cells of the two casts at `dut.sv:31-32`
(`idx_t'({1'b1, index_nodes[Idx1+1][...]})` in the if-in-for else branch
`gen_other_levels`). The golden is uhdm2rtlil's Surelog with `-DSYNTHESIS`:

```
golden: \_operation (vpiOpType 67) 31:13-31:80
          |vpiTypespec: \_ref_typespec (work@dut.gen_levels[0].gen_level[0].gen_other_levels)
             |vpiActual: \_logic_typespec 8:40-15:27   range [IdxWidth-1:0]
ours:   \_operation (vpiOpType 67) 31:13-31:80
          |vpiTypespec: \_ref_typespec (same name)
             |vpiActual: \_integer_typespec 31:13-31:18   no value, no vpiExpr
```

Object identity (`castdump.cpp`, `evidence/ARB_CASTS121.txt`): golden's
`logic_typespec` is ONE object, shared by the `type_parameter idx_t`, the port
and variable `idx_o`, the net and packed-array variable `index_nodes`, and
both casts (8 refs). Ours was a fresh value-less `integer_typespec` per cast.
uhdm-cmp reads 0 lines on both lanes (the judge is blind, see §2).

## 2. Decode (Q2)

**The plugin.** The cast import (`third_party/uhdm2rtlil/src/frontends/uhdm/expression.cpp`)
does three things:

* `:6070` reads an `integer_typespec` for a size cast. It has no value and no
  `Expr()`, so it falls to `get_width_from_typespec` (`:6132`).
* `get_width_from_typespec` (`module.cpp:3248`) returns 32 for any
  `integer_typespec`.
* The operand is 2 bits and the target is 32, so `:6227` adds a 32-bit wire and
  a `$pos` cell named `import_operation`, and the ternary becomes a 32-bit
  `$mux`.

Golden's `logic_typespec [IdxWidth-1:0]` sizes the cast at 2 bits. The
operand is already 2 bits, so it is returned unchanged and the mux is 2 bits
wide.

**The producer.**

* `CompileExpression.cpp:2660-2710` (the `paCast` arm) compiles the target
  with `compileTypespec`. Inside a generate scope the type-parameter name is
  not a type of the scope's component, so it files an
  `unsupported_typespec (idx_t)` and queues the operation with
  `needLateTypedefBinding` (`:2710`).
* `UhdmWriter::lateTypedefBinding` (`UhdmWriter.cpp:2576`) walks the parent
  chain of each queued expression. At a `module_inst` (`:2836`) it finds the
  name among the instance's `Parameters()`, which include the
  `type_parameter`, and binds the `type_parameter`'s OWN typespec. So the
  resolved cast shares the very object the `type_parameter` (and everything
  typed by it) points at, per instance.
* WHICH casts golden resolves and which keep the placeholder was MEASURED, not
  derived; see the grid in §3. The placeholder cases are laws 113 and 115,
  already landed.

**Our site.** In the cast arm (`ExprEmit.cpp`) the elaborated gen-scope cast
failed every earlier arm. It bound the type name as an EXPRESSION (the
`Invalid` expression, rc 4, `unsupported constructs`) and reached the
catch-all value-less `integer_typespec`.

**The judge's blindness.** `expr::Compare` does read `Typespec()`, and
`ref_typespec::Compare` reads `Actual_typespec()`. But `CompareContext::m_visited`
is keyed on the LHS (golden) object. Golden's shared `logic_typespec` is
visited first, through the port / `type_parameter`, so every later comparison
of it returns 0 whatever our side holds.

## 3. The golden grid (Q3)

`mkgrid121.py` writes every arm. `arm.sh` and `grid.sh` run each one:

* both goldens: the v1.87 pin with probe flags (`g187`), and uhdm2rtlil's
  Surelog with the downstream flags (`gds`);
* our two forms (`ours`, `ours_ds` with `-DSYNTHESIS`);
* uhdm-cmp;
* the downstream verdict via `scripts/downstream_uhdm2rtlil.one`, with a
  fresh `GOLDEN_CACHE`.

Every arm records rc. `dist121.sh` gives the order-blind whole-dump distance
to golden, both lanes. `castdump.cpp` and `tsusers.cpp` give object identity.

| grid | arms | varies |
|---|---|---|
| `grid/t` | 42 | cast to a type parameter x context {module cont_assign direct / ternary / op, module always_comb (+ternary), loop-gen cont_assign direct / ternary / op / concat / ternary-of-concat / nested ternary / ternary+op / as a ternary condition / `~`, loop-gen always_comb (+ternary), if-in-for (the corpus shape), if-gen ternary, if-gen always_comb, nested for-for} x target {logic [W-1:0], [0:0], [3:0], [W+1:0], signed, 2-D packed, bit [2:0], byte, int, a typedef default, a body `localparam type`, an override `#(.idx_t(logic [3:0]))` next to a default instance} + the corpus row verbatim (t45) |
| `grid/s` | 15 | select on a member of a package struct parameter: qualified `pkg::CFG.f[3:0]` in a ternary / direct / always_comb / under `+` / in a gen loop; bit, variable-bit, indexed and part selects; 2-D packed member with one and two selects; an unpacked struct with an unpacked member; a nested member; the IMPORTED spelling and a module localparam as controls |
| `grid/v` | 11 | qualified package VARIABLE read `mask_pkg::v` bare / selected / in a ternary / under `+` / always_comb / unpacked element; `p::longer_name` and the spaced `p :: longer_name`; the imported control |
| `grid/r` | 5 | pass 118's residue arms, copied: p13, p17, p22, p28 and m07 |
| `grid/q` | 10 | folded qualified package PARAMETER read in 10 contexts (R6 characterisation only; no law) |

**Measured golden answers** (both producers agree on every cell scored):

| face | golden |
|---|---|
| cast, elaborated gen scope | Every cast that keeps no placeholder resolves to the INSTANCE's `type_parameter` typespec object. That covers a loop generate under a ternary, an operation, a concat, `~`, a nested ternary or a ternary condition; the if-in-for else branch; and every gen-scope process, loop or if. An override gives that instance's override object (t43). Every target type (t2x). Direct cont_assign Rhs in a loop, and an if-generate cont_assign under a ternary / op, keep the placeholder (t06, t14: laws 113 / 115, unchanged). |
| cast, module scope | Resolves too, but differently. The DEF view shares the def `type_parameter`'s typespec. The ELABORATED cont_assign gets a FRESH copy of the DEFAULT typespec, parented at its `ref_typespec`, even under an override (t44). A process (shared def/elab) takes the def object. **Not landed: R-mod.** |
| qualified member select | The select is ERASED. The DEF view is `hier_path` (empty name, the scope's fullname, the WHOLE written span) holding `ref_obj pkg::CFG` (bound to the parameter, spanning `pkg::CFG`) and `ref_obj f` (fullname `<scope>.f`, spanning `f`). The ELAB view is the member's value constant, select dropped (`8'h3C` for `CFG.f[3:0]`). The imported spelling keeps the select (s08). |
| qualified variable read | The ref spans the PACKAGE SCOPE alone: from the package name through `::`. Examples: `mask_pkg::v` 6:14-6:24, `p::longer_name` 5:14-5:17, `p :: longer_name` 6:14-6:18. The spaced spelling is named `p::longer_name` like the unspaced one. |

**Scored per arm, pristine -> LAW** (`evidence/VERDICTS121.txt`, `evidence/DIST121.txt`):

* whole-dump distance: **TO 49, SAME 34, AWAY 0** (83 arms, both lanes);
* downstream: 20 t arms EQUIVALENT -> IDENTICAL; 10 s/r arms DIVERGENT -> IDENTICAL; v11 DIVERGENT -> IDENTICAL; no arm moves away from IDENTICAL;
* uhdm-cmp: s02 / s03 / s05 / s06 / s12 / s13 98-104 -> 56, s10 98 -> 28, v11 32 -> 0. Every other arm keeps its count; every EQUAL arm stays EQUAL.

## 4. The laws, each droppable alone (Q4)

All four are in `src/ExprEmit.cpp`. `R11U121_OFF=1` drops them all.

| switch | law | what it does |
|---|---|---|
| `R11U121_TPGS_OFF` | § genScopeTypeParamCastTs121 (the cast arm, after § genCaTypeParamCastUnsupported113) | Scope: the elaborated generate scope, i.e. a gen-scope cont_assign Rhs or a gen-scope process, with `castSiteScope57` set and no placeholder bound. For a cast whose written target is an identifier resolving to a TYPE PARAMETER of the instance body, it takes `typeParamElabTs[tp]` (the instance's `type_parameter` object) and does not re-parent that shared object at the cast's ref. |
| `R11U121_QMSEL_OFF` | § pkgQualParamMemberSelErased121 (ElementSelect and RangeSelect arms) | A select run over a member chain whose base is a package PARAMETER written qualified (§ pkgWrittenQualSelBase41) is emitted as the bare member access, with the whole written span on the hier_path. |
| `R11U121_PVSPAN_OFF` | § pkgQualVarRefScopeSpan121 (NamedValue arm, `isPkgQualifiedVarRef`) | Read-side span = the package scope through the first `::`. |
| `R11U121_PVSP_OFF` | § pkgQualVarRefSpacedName121 (`isPkgQualifiedVarRef`) | The written-qualifier test ignores whitespace. |

`drops121.sh` runs every grid arm in both forms (166 arm-forms): the LAW
binary with one switch set, compared byte for byte (`evidence/DROPS121.txt`).

* `R11U121_OFF`: 98 moved vs LAW, **= pristine on 166/166**.
* `TPGS_OFF` moves only t arms (50).
* `QMSEL_OFF` moves only s arms and p28 (26).
* `PVSPAN_OFF` moves only v arms and p17 (22).
* `PVSP_OFF` moves only v11 (2).

## 5. Census and the a-priori movers (Q5)

`cen121.cpp` reads the PRISTINE sweep databases (all 2568 corpus databases
plus 2833 probe databases). It counts:

* TPI_G / TPI_M: casts with a value-less `integer_typespec` target, in or out
  of a gen scope;
* TPR: casts that share a `type_parameter`'s typespec;
* QSEL: hier_paths over a `pkg::` base that carry a select;
* QHP: hier_paths named `pkg::X` without a select;
* PVR: `pkg::` refs bound to a package variable.

**Positive control.** Grid t07 / t45 read TPI_G 4 / 2 on pristine, 0 on LAW,
with TPR equal to golden. s01 / s02 read QSEL 2 / 1 -> 0, QHP = golden.
v01 reads PVR 2. Files: `evidence/CENSUS121.pris.txt` and `CENSUS121.probe.pris.txt`.

**PREDICTED MOVERS BY NAME** (written before the LAW sweep):

* u2r: `arb_idx_cast` x 2 (TPI_G 2).
* downstream: `arb_idx_cast`.
* surelog: `ApbSlave` x 2 and `Scoreboard/default` (PVR 15 / 9:
  `svunit_pkg::current_tc`), plus the UVM family's documented 0/4-line coin.
* probe: r11u113 c13 / c25 / c27 (TPI_G) and r10uvm26 t36a / t36d (PVR).
* Not movers:
  * TPI_M rows (`def_ctx_struct_param`, `latch_decoder_partial`,
    `latch_tlb_napot`) are package-param size casts, not type parameters.
  * `stamped_gen_param`'s QSEL sits in a gen-block `localparam`
    initializer, which this law does not reach (LAW bytes identical, checked
    directly).

## 6. Gates (Q6)

Sweeps: `tests/sweep.sh --jobs 3`, workdirs of the same length
(`/tmp/r11u121_wpris`, `/tmp/r11u121_wlaw5`), `SLANG_UHDM` exported. Every
`cmds.txt` names its frozen binary: pristine 3273/3273 `r11u121_pris.bin`,
LAW 3273/3273 `r11u121_law5.bin`. Summary in `evidence/SWEEPS121.txt`.

* probe: **EQUAL=2833 (of 2833)**, both binaries.
* surelog: 480/3 + 474/3, **regressions=0 conversions=0 changes=0**, both binaries.
* uhdm2rtlil: 803/1/67 both modes, **regressions=0 conversions=0 changes=0**, both binaries.
* downstream: pristine 794/7/4/66 (= baseline); LAW 795/6/4/66. The only
  changed row is `arb_idx_cast` EQUIVALENT -> IDENTICAL (quoted at the top).
  "not identical and not excused=0".
* uhdm-cmp 0 lines on `arb_idx_cast`: default, testflags, and the downstream lane.

**byteverify** (`SELFCHECK=1`, identical path sets, `evidence/BYTEVERIFY121.txt`):

* u2r 2/1608: `arb_idx_cast` x 2.
* downstream 1/805: `arb_idx_cast`.
* surelog 7/960:
  * `ApbSlave` x 2: 30 order-blind lines, all 15 `svunit_pkg::current_tc`
    ref spans, 30 -> 0 cells from golden.
  * `Scoreboard/default`: 18 lines, 9 refs, 18 -> 0 from golden.
  * `MiniAmiq` x 2 and `SeqDriver` x 2: exactly 4 order-blind lines each,
    `UINT:<line>` / `vpiDecompile:<line>`, the documented coin.
* **Exactly the prediction.** Every mover row stays `CMP_EQUAL`.

**Probe movers** (`evidence/PROBE_MOVERS121.txt`): exactly the five
predicted, all still EQUAL, all TO golden (locdump distance c13 11->10,
c25 29->25, c27 23->19, t36a 50->48, t36d 24->22).

**Protected databases** byte-identical to pristine: Earlgrey_0_1,
SVSwitch, YosysVerx, InterfaceModPort, BlackParrotComplex, YosysOldOr.
None is a mover.

**Canary battery** (`evidence/CANARIES121.txt`):

* ctcan2 (both) and the u2r canaries print output identical to the pristine
  sweep's.
* The surelog canaries differ from pristine in ONE line:
  `Earlgrey_0_1/default` dump column `differ -> blank`. That is the
  documented blank-on-timeout draw; its database is not a mover.
* The remaining CHANGED lines (dump `match -> differ` on InterfaceBinding and
  others, LowMemPkg detail) appear identically in the pristine run:
  environment.

**Boundary** (`ctl121.sh`): every `dut.sv` under `tools/probe` and
`tests/probe` except this pass's own (5896 arms), both forms, pristine vs
LAW. The file list is read on fd 3, children get `</dev/null`, and fenced
names are excluded.

* PROCESSED 11792 = LISTED x 2; SAME 11690, DIFF 102 = 51 arms x 2 forms
  (`evidence/BOUNDARY121.summary.txt`).
* `attr121.sh` rebuilt both goldens for each of the 51 arms and attributed
  them (`evidence/BOUNDARY121.attr.txt`):
  * **every one moves TO golden in both forms, AWAY 0**;
  * each is restored to pristine by exactly ONE switch (TPGS 9, QMSEL 23,
    PVSPAN 19);
  * every EQUAL arm stays at 0 cmp lines. NE counts stay or fall: pass 108 /
    111 / 114 / 117 k13 / a01 / a30 / g02 / g03 / g17 go 100 -> 86,
    r11u16 d2 98 -> 48, v11u117 b20 132 -> 102.

## 7. Residues (ranked)

* **R3c — the elaborated cont_assign stays SHARED with the def one** for a
  qualified member select (s02 / s03 / s05 / s06 / s12 / s13, 56-line
  heads).
  * Golden re-compiles the elaborated Rhs to the member's value constant,
    and it is the package value's own constant object.
  * The share decision is `ModuleEmit.cpp:34143-34150` ("Top modules share
    the def's cont_assign object unless netlist elaboration re-compiles
    it"). That is the sister's ground, so this stops at the decode.
  * Downstream is IDENTICAL on all of them except s13. s13's golden elab
    constant is `vpiSize:6`/`2` over a 12-bit `BIN:`, a Surelog oddity the
    plugin reads.
* **R-mod — the module-scope type-parameter cast** (t01-t05, t3x, t42, t44;
  judge-visible 22-100 lines, downstream EQUIVALENT; 0 corpus rows). It is on
  this ground (ExprEmit cast arm) and has three identity sub-rules:
  * the DEF view shares the def `type_parameter` typespec;
  * the ELAB cont_assign mints a fresh copy of the DEFAULT, parented at its
    ref, even under an override;
  * a process takes the def object.
  The next pass on this ground should take it.
* **R3b — s10** `pkg::CFG.f[3:0] + 8'd1`. Golden folds the elaborated
  operation over the ERASED select (`INT:61` = 0x3C+1); ours folds the
  SV-correct `13`. It is DIVERGENT before and after. The fold site is not
  decoded.
* **R3d — s11**: the gen-scope DEF view keeps `mask_pkg::CFG.f[3:0]` with a
  part_select. That is the TypeEmit syntax path (pass 118 R7,
  `TypeEmit.cpp:16723-16795`), the sister's.
* **R3e — the 17-line head of s01 / s07 / s15 / p28.** Our package
  parameter's assignment-pattern Rhs carries a `ref_typespec (mask_pkg) ->
  struct_typespec` where golden has none in exactly these arms; golden's
  package object depends on how the module uses it. Not decoded.
* **R4** (`w[0] = 1`, m07): golden's elaborated cont_assign SHARES the def's
  64-bit constant. Ours clones a size-1 constant under the "unsized literal
  worth 1" rule at `ModuleEmit.cpp:36751-36770`. Sister's ground;
  judge-blind and downstream-IDENTICAL; reported, not edited.
* **R6** — one ORPHAN, location-less, parent-less `ref_obj <P>` per folded
  qualified package-parameter read (grid q01-q07, q09, q10, p13, p22; not the
  declaration q08). It is unreachable, so the judge and the plugin cannot see
  it. The mint site was not located.
  * R6b: in a select bound or a `param_assign` operation, golden's folded
    constant spans the package scope (`7:29-7:39`, the same
    `populateCoreMembers(child, child)` at `CompileExpression.cpp:2748` as
    R5); ours spans the whole name.
  * R6c: golden stamps a ts ref to the parameter's `int_typespec` there;
    ours has none.
* **R-arb-span** — golden's shared `logic_typespec` ends at `15:27`, because
  Surelog widens the shared object's end when `index_nodes` uses it. Ours
  keeps `8:60`. Judge-blind and downstream-IDENTICAL.

## Files

* Drivers:
  * `mkgrid121.py` writes the grids.
  * `arm.sh` / `grid.sh` run one arm / a grid (both goldens, our two forms,
    cmp, downstream verdict).
  * `dist121.sh` gives the whole-dump distance, `drops121.sh` the per-switch
    drops, `ctl121.sh` the boundary, and `attr121.sh` its attribution.
* C++ tools, built with
  `g++ -O2 -std=c++17 X.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj`:
  * `castdump.cpp` — cast target, typespec identity and users;
  * `tsusers.cpp` — the users of the typespecs at a location;
  * `constid.cpp` — constant identity (R4);
  * `cen121.cpp` — the census.
  * `../r11u119repro/locdump.cpp` provides the locdump.
* `evidence/` holds every measurement quoted above.
