# r11u419: interface port-view parameters and keyword-less parameter port order (pass 419, expression/parameter ground)

Base b539955d7. Production surface: `src/ParamEmit.cpp` only. No change to
`EmitHelpers.h`, `ExprEmit.cpp`, `StmtEmit.cpp`, `include/` or `uhdm_main.cpp`.
Every law reads its switch through `src/LawSwitch.h`: `lawOn(419, ...)` and
`lawTrace(419, ...)`. There is no `src/R*.h` file, no `getenv` and no reader
function. `R11U419_OFF=1` gives pristine's bytes and exit code on 40 of 40
grid case dirs (`evidence/grid.txt`).

## Result

sv-tests: 9 rows convert, with 0 regressions and 0 changes (`evidence/svtests_stage.log`).
The totals move as follows:
- EQUAL: 1824 -> 1833
- STRICT_NOTEQUAL: 11 -> 3
- DIFFERENT: 105 -> 104

| row | before -> after | law |
|---|---|---|
| generated/uvm_classes_1/uvm_{agent,driver,env,monitor,scoreboard,sequencer,test}_class_1.sv (7) | STRICT_NOTEQUAL differ:value(3) -> EQUAL | § ifPortViewArithIntForm419 + § ifPortViewPaLhsOwn419 + § ifPortViewTdAliasDefName419 |
| testbenches/uvm_agent_env.sv | STRICT_NOTEQUAL differ:value(3) -> EQUAL | the same three |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_mux_one_hot.sv | DIFFERENT -> EQUAL | § implicitPortParamListedFirst419 |

The 8 UVM rows had three faces in a row. Each face appeared only after the
one before it was fixed:
1. value(3), INT vs UINT.
2. depth: the walk diverges where a Lhs is shared.
3. fullname(58): the typedef alias.

All three faces sit in the same place. It is the interface PORT VIEW of
`input_if` / `output_if` under `work@top.d`. Its param_assigns are the
`$unit` `import uvm_pkg::*` copies of the uvm_pkg parameters.

Pass 418 said this face was ParamEmit's. The value really is restamped by
ModuleEmit, at the default-scope fold in emitInterfaceInstance. The fix lives
in ParamEmit, as a design-final post-pass (`ifPortViewPas419`, called at the
end of `drainShareDefParamTs`).

## Laws (src/ParamEmit.cpp; find a site with `grep -n '§ <law>'`)

### § ifPortViewArithIntForm419

Switch: `R11U419_PVINTFORM_OFF`.

The face: the port view's Rhs constant is restamped from its Lhs parameter's
value at emission. The ModuleEmit restamp `c6->VpiValue(lv6)` changes the
value only, not the constant type. At emission time that value is still the
`UINT:` fold of an untyped arithmetic package parameter
(`UVM_SMALL_STRING = UVM_LINE_WIDTH*8-1`). § paramValueIsDefRhs124 later
rewrites the Lhs to `INT:`, but not the Rhs. The Rhs is left with const type 7
and a `UINT:` value.

Golden writes INT:959 with const type 7. The law writes a port-view Rhs
constant of type vpiIntConst whose value is `UINT:n` as `INT:n`.

Found with gdb on the pristine binary: a breakpoint on
`expr::VpiValue("UINT:959")` caught the write in emitInterfaceInstance at the
restamp.

### § ifPortViewPaLhsOwn419

Switch: `R11U419_PVLHSOWN_OFF`.

The face: § elabReExportPaLhsShare binds both `$unit`-import occurrences of a
parameter to one Lhs. That is right for a home view, but not for a port view.
In golden, the walk meets a fresh parameter under every entry of the first
port view of a definition. It meets none under a later view of the same
definition (IA/ia15, the second interface-array element). So golden's
port-view Lhs objects are the DEFINITION listing's Lhs objects.

The law fires only on a view where some Lhs is taken by two of its
param_assigns, which is the face. When every Lhs is definition-named
(§ portViewParamDefName130) and the definition listing lines up, the view
takes the definition's Lhs objects. The line-up is by name, import and
occurrence (the definition lists the imports first; ia16).

Otherwise a duplicated, view-named Lhs gets its own copy. That case is the
named-modport view, IA/ia10. The law abstains on:
- interface-array element views;
- definition-named Lhs that do not line up (ia17).

The first sweep showed why the duplicated-Lhs condition is needed. That
sweep's binary swapped every definition-named view's Lhs, duplicated or not.
It read Rggen default CMP_EQUAL -> STRICT_NOTEQUAL differ:depth(1)
(`evidence/sweep_corpus_first.txt`). The law was narrowed to views holding a
duplicated Lhs, and the four corpus stages were rerun alone.

### § ifPortViewTdAliasDefName419

Switch: `R11U419_PVTDALIAS_OFF`.

The face: a typedef-typed parameter's typespec copy is referenced by a
port-view Rhs constant (or by its Lhs). That copy names its typedef-alias ref
after the view, `work@top.d.x.A.f_t`. Golden names it after the
definition-named Lhs, `work@i.A.f_t`, and writes no `work@top.d.x.A.f_t`
anywhere (ia13). In the UVM rows this is the 58 `uvm_field_flag_t` aliases.

### § implicitPortParamListedFirst419

Switch: `R11U419_IMPLFIRST_OFF`.

Surelog compiles the parameter port list's keyword-less
`data_type list_of_param_assignments` form ahead of the
`parameter`/`localparam` entries. An entry that continues that form counts
too: `int B = 2, C = 3`. slang leaves the keyword invalid for these entries
(`isImplicitPortParam`).

Golden lists these entries first, after the materialized imports and before
the body parameters, in these vectors:
- a module's and an interface's Parameters vector, in both views;
- the definition's Param_assigns vector.

The elaborated Param_assigns keep the rank order.

| case | header | golden order |
|---|---|---|
| uo01 | `#(parameter A, int B=1, C=2)` | B C A |
| uo10 | `#(parameter A = 4, B = 2, int C = 1, D = 3)` | C D A B |
| uo13 | | B D A C |
| uo17 | interface | |

All-keyword-ful and all-keyword-less lists keep source order (uo02-uo04,
uo06-uo08, uo11, uo12).

### § implicitPortPaLastIface419

Switch: `R11U419_IMPLPALAST_OFF`.

This extends § implicitPortPaLastNoBody405's elaborated demotion in two ways:
- the demotion now reaches INTERFACES (uo17, uo19, uo21, uo22);
- the demoted keyword-less entries follow the materialized imports
  (uo16, uo20: golden A, L, Q(import), B).

## Grid

There are 40 case dirs (`cases/IA`, `cases/UO`). Each case's first line names
its law. The full per-case results, with exit codes, are in
`evidence/grid.txt` (`drivers/grid.sh`).

### IA cases (18), pristine -> final

- ia01-ia03, ia05-ia13, ia15, ia16, ia18: STRICT_NOTEQUAL (value / depth /
  fullname) -> STRICT_EQUAL.
- ia04: STRICT_EQUAL control, byte-identical to pristine.
- ia14 and ia17: NOT_EQUAL on both, at heads the laws do not reach:
  - ia14: a generate scope's imported-parameter listing, ModuleEmit's face. The
    dump distance goes 846 -> 842. The uhdm-cmp line count goes 1892 -> 1944;
    the head is the same, and the printed mismatch subtree holds the port view.
  - ia17: package q's re-export listing. The dump distance goes 1593 -> 1581.

### UO cases (22)

- 15 NOT_EQUAL -> STRICT_EQUAL.
- 6 STRICT_EQUAL controls, byte-identical.
- uo18: NOT_EQUAL on both, moving toward golden (dump distance 104 -> 16). Its
  remaining head is the size of `localparam C = A + B` with an int-typed B:
  golden 32, ours 64.

### Switches

- `R11U419_OFF` restores pristine's bytes and exit code on 40 of 40.
- Each group's own switches restore pristine's bytes and exit code on 40 of 40.
- Each single switch drops its own law alone (`evidence/switches.txt`).

### Downstream (`evidence/downstream.txt`, drivers/ds.sh)

- 14 UO cases: EQUIVALENT -> IDENTICAL.
- 23 cases: IDENTICAL on both.
- ia17: EQUIVALENT on both.
- **ia16 and ia18: IDENTICAL -> EQUIVALENT.**
  - The cause is not a semantic change. The plugin's log is line-identical
    except that one "Removing interface module" line moves.
  - The written modules are identical modulo their order:
    `same-modulo-order` for both, checked on sorted module blocks.
  - The module order follows heap addresses in the plugin process, so any
    change in object count can flip it (pointer-keyed iteration). With
    § ifPortViewPaLhsOwn419 off, both read IDENTICAL.
  - A verifier should weigh this.

## Gates (one final sweep, then the narrowed-law stages again)

- **Prediction before the sweep:**
  - `drivers/pvscan.py` was run over 6647 of the master's control databases
    (fence-filtered). It found 0 port-view firings
    (`evidence/predict_portview_dumpscan.txt`). The positive control was the
    ia01 and ia13 pristine databases, where it finds A, B and C. The Tnoc d/t
    dumps (870 MB) were traced with the final binary instead.
  - `drivers/implscan.py` was run over 19731 corpus sources. It lists the
    ordering-law candidates (`evidence/predict_ordering_srcscan.txt`): Tnoc,
    MiniAmiq's amiq_apb_if, the Rp32 / rp32 interfaces and modules,
    LibraryIntercon (SLANG_REJECT) and others.
  - **The prediction missed one mover.** The scan predicted § ifPortViewPaLhsOwn419
    on duplicated Lhs only. The first sweep's binary also swapped
    non-duplicated views, and Rggen default regressed. The law was narrowed
    to duplicated Lhs, and the four corpus stages were rerun alone on the
    final binary.
- **Corpus stages on the final binary** (`evidence/sweep_corpus_final.txt`):
  - probe: 4018 + 69, 0/0/0.
  - surelog: default 480, testflags 474, 0/0/0.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
  - downstream: 803 / 66 / 2 / 0, not excused 0.
  - Against the master's control (/tmp/intr11u417), the probe, uhdm2rtlil and
    downstream csvs are identical. The surelog csv differs only in the two
    LowMem log-path texts.
- **Byte movers:**
  - byteverify: surelog 2 of 962, both Tnoc default and testflags. This is
    § implicitPortPaLastIface419, predicted by the Tnoc trace: 3736 firings,
    tnoc_types/utils interfaces. Both stay CMP_NOTEQUAL with the same uhdm-cmp
    head (tnoc_pkg 333:14) and 28 lines on both.
  - uhdm2rtlil 0 of 1608, downstream 0 of 805.
  - probe 0 of 4087, by path-normalized dump (`drivers/probecmp.sh`; the
    probe databases embed the checkout path). Positive control: a swapped
    pair is flagged, a same-name pair is not.
  - Selfchecks 961 of 962, 1607 of 1608, 804 of 805.
- **Trace census of the final corpus stages:** only Tnoc d/t fire, with
  § implicitPortPaLastIface419.
- **Canaries:** ok=52 and ok=16. Both ctcan2 checks PASS.
- **sv-tests stage:** run on the final binary through the main tree's
  `scripts/check_svtests.py`, read-only (a worktree has no UVM tree):
  regressions 0, conversions 9, changes 0.
  - The laws fire on 21 rows (`evidence/svtests_firing.txt`): the 9
    converted rows, rsd (SURELOG_CRASH, no golden) and 11 rows that stay
    DIFFERENT.
  - Away census on those 11 (`evidence/away_census.txt`, drivers/away.sh,
    against the master's control databases):
    - 9 move toward golden: uvm_component_class_1, uvm_agent_active,
      uvm_agent_passive, uvm_driver_sequencer_env, uvm_monitor_env,
      uvm_scoreboard_env, uvm_scoreboard_monitor_agent_env,
      uvm_scoreboard_monitor_env, and tnoc, whose head is unchanged.
    - 2 stay at the same distance: uvm_param_vif_config_db and
      uvm_use_models_pipelined_get_put.
    - 0 move away.
    - rsd has no golden. Its +190 dump lines are the 95 orphaned original
      Lhs objects, printed in the dump's unreferenced section.
- **Earlier-pass case census:** 2623 fence-filtered dut.sv files under
  r11u4*/v11u4* were run on pristine and the final binary
  (`evidence/earlier_census.txt`). 2614 are byte-identical.
  - 8 are listed "MOVED" only because neither binary writes a database
    (exit 3 on both; the case drivers expect it).
  - r11u405 IP/ip03 goes NOT_EQUAL -> STRICT_EQUAL (§ implicitPortPaLastIface419).

## Goal 1

- All 75 SURELOG_ONLY rows carry an upstream slang front-end `error:`. No
  BOTH_REJECT or SLANG_CRASH row carries an exporter error.
- These probe shapes are left unforced, because Surelog itself rejects them
  and upstream slang accepts them:
  - `C::mk().arr[1]` and `u.mk(x).a[2]` still exit 4 with "element select base";
  - `this.mk().inner.s` exits 0.
- Black-parrot: bp_unicore alone with the size guard exits 3 in 15.9 s at
  810 MB peak, with the same substr error. No memory-bounded export was found,
  so the guard stays.

## Residues (ranked; all wrong on pristine too, none moved away)

1. uo18: a port-list localparam folding over an int-typed keyword-less
   parameter, sized 64 where golden reads 32.
2. ia14: a generate scope's own listing of `$unit`-imported parameters is
   missing. This is ModuleEmit; report only.
3. ia17: package q's re-export listing.
4. The 3 STRICT_NOTEQUAL basejump rows:
   - mesh_router col(1), the ParamEmit generate-localparam face;
   - decoder_dor fullname;
   - wormhole_concentrator_out fullname.
5. The 57 non-UVM DIFFERENT rows' heads at the base
   (`evidence/svtests_heads_nonuvm_base.txt`).
6. Pass 417's and earlier carried lists.

## Sister-ground faces (report only)

- ModuleEmit's port-view value restamp (`emitInterfaceInstance`,
  `c6->VpiValue(lv6)`) copies a not-yet-final Lhs value. This pass repairs the
  result design-final in ParamEmit.
- ModuleEmit: a generate scope's imported-parameter listing (ia14).
- The plugin's module order follows heap order (ia16, ia18; in uhdm2rtlil,
  out of scope).

## Process

- One slip: a targeted runner call on the 57 non-UVM DIFFERENT rows (jobs 2)
  was launched while the sister pass r11u420's targeted runner was live. The
  quiet check printed 4 and the launch was not gated on it. Every later launch
  waited for three quiet readings (`drivers/waitquiet.sh`). This affected no
  measurement.
- A `pkill`-free stop of two of my own slow scans also stopped their waiting
  shell, which matched its own pattern. That shell was my own. No other
  agent's process was touched.
- The fence list was read into a file by a program and never printed. Every
  tree-wide list was filtered on it first. No fenced test was named, opened or
  run.
- Budget:
  - no pristine build and no pristine sweep (the pristine reading is the
    master's control /tmp/intr11u417 and the main tree's build);
  - one full corpus sweep on the first final binary;
  - after the narrowing, the four affected corpus stages once more on the
    final binary, then the sv-tests stage once.
- Binaries: pristine 14bc1038ee758bf84d816c1a23adcaf5; the first final
  17d33da41f973b6b20454941401f2e63; the final
  4e8fadac83107afcce7396f734f144f5.
