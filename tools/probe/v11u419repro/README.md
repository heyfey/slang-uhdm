# v11u419: adversarial verification of r11u419 (pass 419, expression/parameter ground)

Base b539955d7. The implementer's patch `/tmp/r11u419.patch` applies cleanly on a fresh
b539955d7 (production surface `src/ParamEmit.cpp` only). The verifier made NO production
change: no fresh case on legal SV, no corpus row, no probe case and no sv-tests row went
from right on pristine to wrong on the law binary. `/tmp/r11u419.verified.patch` carries
the implementer's source byte-identical plus this directory and the regenerated
`tests/LAWS.md`.

## Binaries (frozen before any measurement)

| binary | path | md5 |
|---|---|---|
| pristine | /tmp/v11u419_bin/pris (copy of the main tree's build/slang-uhdm; no pristine build, per the budget) | 14bc1038ee758bf84d816c1a23adcaf5 |
| law | /tmp/v11u419_bin/law (rebuilt once in /tmp/wt_v11u419, -j 2) | 4e8fadac83107afcce7396f734f144f5, equal to the implementer's final binary |

The pristine reading is the master's control sweep /tmp/intr11u417.

## The sweep (one, on the law binary, quiet machine)

`tests/sweep.sh --jobs 3 --workdir /tmp/v11u419_sw --corpus "probe surelog uhdm2rtlil downstream"`,
then the sv-tests stage through the main tree's `scripts/check_svtests.py` read-only (a worktree has
no UVM tree), launched after three quiet readings. Exit 1 of the corpus part is the stale
law index alone (this directory's cases); every comparison reads 0 regressions.

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69, regressions 0, conversions 0, changes 0; the csv byte-identical to the control.
- surelog: default 480, testflags 474; 0/0/0; the csv differs from the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes; 0/0/0; csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not identical and not excused 0; csv identical to the control.
- sv-tests: regressions 0, conversions 9, changes 0; EQUAL 1833, STRICT_NOTEQUAL 3, DIFFERENT 104, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346. The csv is byte-identical to the implementer's `evidence/svtests.csv` on all 2346 rows, and it differs from the control on exactly the 9 converted rows.

| sv-tests row | control -> law | law |
|---|---|---|
| generated/uvm_classes_1/uvm_{agent,driver,env,monitor,scoreboard,sequencer,test}_class_1.sv (7) | STRICT_NOTEQUAL differ:value(3) -> EQUAL | § ifPortViewArithIntForm419 + § ifPortViewPaLhsOwn419 + § ifPortViewTdAliasDefName419 |
| testbenches/uvm_agent_env.sv | STRICT_NOTEQUAL differ:value(3) -> EQUAL | the same three |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_mux_one_hot.sv | DIFFERENT -> EQUAL | § implicitPortParamListedFirst419 |

Other gates:
- byteverify against the control (SELFCHECK=1): surelog 2 of 962 (Tnoc default and testflags, § implicitPortPaLastIface419, CMP_NOTEQUAL rows with an unchanged csv line), uhdm2rtlil 0 of 1608, downstream 0 of 805; selfchecks 961/962, 1607/1608, 804/805 (`evidence/byteverify.txt`).
- probe: 0 movers of 4087 by path-normalized dump (`drivers/probecmp.sh`), with a positive control (a swapped pair is flagged, a same-name pair is not).
- canaries ok=52 (surelog csv) and ok=16 (uhdm2rtlil csv); both ctcan2 checks PASS.
- binary audit: sv-tests 2346 of 2346 cmds.txt name /tmp/v11u419_bin/law; uhdm2rtlil 1742 of 1742; surelog 1531 of 1581, the other 50 holding only a Surelog line (Surelog failed first).

## Reproduction of the implementer's evidence

- Grid: the implementer's 40 case dirs (IA, UO) rerun on both frozen binaries reproduce
  `r11u419repro/evidence/grid.txt` line for line (exit code, uhdm-cmp lines, dump distance,
  strict verdict; `evidence/impl_grid_reproduced.txt`).
- Earlier-pass census: 2623 fence-filtered dut.sv files under r11u4*/v11u4* on both binaries;
  the only mover is r11u405repro IP/ip03 (bytes move, the implementer's NOT_EQUAL -> STRICT_EQUAL);
  every exit code unchanged (`evidence/earlier_census.txt`, `evidence/earlier_movers.txt`).
- Away census on the 128 sv-tests databases both sweeps keep, by path- and id-normalized dump:
  117 identical; 11 moved (`evidence/svtests_kept_normdump.txt`, `evidence/away_census.txt`):
  8 UVM rows toward golden (uvm_component_class_1, uvm_agent_active, uvm_agent_passive,
  uvm_driver_sequencer_env, uvm_monitor_env, uvm_scoreboard_env, uvm_scoreboard_monitor_agent_env,
  uvm_scoreboard_monitor_env; uhdm-cmp equal or smaller), uvm_use_models_pipelined_get_put at the
  same distance, rsd (SURELOG_CRASH) +190 dump lines that are 95 orphaned parameter objects and
  their 95 ref_typespecs (top-level unreferenced `\_parameter` 81793 -> 81888, `\_ref_typespec`
  285 -> 380; `evidence/rsd_top_*.txt`), and tnoc: uhdm-cmp 28 -> 28 lines at the same head (tnoc_pkg.sv 333:14); its
  dump distance is NOT MEASURED: the census's 1200 s dump timeout cut both dumps (the
  `AWAY` multiset line in `evidence/away_census.txt` is that truncation artefact), and an untimed
  dump of each database ran 64 minutes without finishing and was stopped by its own PID. The
  law firing there is § implicitPortPaLastIface419 on Tnoc's `interface tnoc_types import
  tnoc_pkg::*; #(tnoc_packet_config PACKET_CONFIG = ...)` shape; the fresh case VP/vp08 holding
  that shape moves toward golden (dump distance 543 -> 449, uhdm-cmp unchanged) and vp09
  converts to STRICT_EQUAL. The implementer's "tnoc toward golden" reading has no line in its
  `away_census.txt` either.
- Goal 1: C::mk().arr[1] (v11u413 VC/vc04) and u.mk(x).a[2] (VI/vi06) exit 4 on both binaries,
  upstream slang 0; this.mk().inner.s (v11u415 VT/vt03) exits 0 on both. All 75 SURELOG_ONLY
  rows carry an upstream slang `error:` (75 of 75); no rejecting row carries an exporter error
  (the 5 rows matching 'slang-uhdm' name it only in the UVM checkout path).
  Black-parrot: bp_unicore alone on the law binary with the size guard exits 3 in 16.9 s at
  775 MB peak (python rusage) with the same substr error, during the verifier's two tnoc dump
  processes; no memory-bounded export, the guard stays.

## Attack grid (51 fresh case dirs; every one accepted by upstream slang, every exit 0)

`drivers/grid.sh` (pristine and law line per case with exit code; `R11U419_OFF=1` and the
case's own law switch), `evidence/grid.txt`. Groups: VA (§ ifPortViewArithIntForm419: value
forms), VL and VC (§ ifPortViewPaLhsOwn419: the definition-share and the copy form), VT
(§ ifPortViewTdAliasDefName419), VO (§ implicitPortParamListedFirst419), VP
(§ implicitPortPaLastIface419). Each case's first line names its law.

- 34 STRICT_EQUAL on the law binary: 33 conversions (22 STRICT_NOTEQUAL -> STRICT_EQUAL: VA/va02,
  va04, va06, va07, va09, va10, va12, VC/vc01, vc04, vc05, vc06, vc07, vc08, VL/vl01, vl02, vl04,
  vl05, vl06, vl07, VT/vt01, vt04, vt05; 11 NOT_EQUAL -> STRICT_EQUAL: VO/vo01, vo03, vo04, vo06,
  vo09, vo10, VP/vp01, vp02, vp04, vp06, vp09) and the control VT/vt02 at pristine's bytes.
- Toward golden, still unequal: VC/vc02 (STRICT_NOTEQUAL value at walk #394 -> depth at #422, a
  modport io_decl listing), VC/vc03 (same uhdm-cmp head, the generate scope's missing imported
  parameter listing; multiset 654 -> 620, uhdm-cmp lines 1924 -> 1976 from the printed subtree, the
  implementer's ia14 face), VO/vo02, vo07, vo08, VP/vp03, vp05, vp08 (Tnoc's shape: an interface
  `import pk::*; #(cfg_t CFG = DEF)`, dump distance 543 -> 449, uhdm-cmp unchanged), VA/va05.
- Bytes moved with the same uhdm-cmp head and only orphaned objects added (the replaced port-view
  Lhs objects): VA/va01, va08, va11 (value overflow faces), VL/vl03 (a port view inside a generate
  block, the generate-scope listing face); all wrong on pristine too.
- At pristine's bytes, unreached: VA/va03, VO/vo05 (a program), VP/vp07, VT/vt03.
- `R11U419_OFF` restores pristine's bytes and exit code on 51 of 51; the group's switches
  (the three port-view switches for VA/VC/VL/VT, the two order switches for VO/VP) on 51 of 51.

Downstream (`drivers/ds.sh`, `evidence/downstream.txt`, pristine | law, the 51 fresh cases plus the
implementer's ia16 and ia18): 12 EQUIVALENT -> IDENTICAL (VO/vo01, vo03, vo04, vo06 to vo10, VP/vp01,
vp02, vp04, vp09), every other fresh case at its pristine verdict, none worse;
VC/vc03 and VA/va10 IDENTICAL only because both lanes fail in the plugin (READ_FAIL, CRASH)
on both binaries; VA/va08, va11 STATUS_DIFF on both; VL/vl05, VO/vo02, VP/vp05, vp08
EQUIVALENT on both.

## The implementer's downstream question: IA/ia16 and IA/ia18 IDENTICAL -> EQUIVALENT

Reproduced. The two lanes' `_nohier.il` differ only in module order (`\top` and `\dut`
swapped). The plugin removes interface modules by iterating `std::set<RTLIL::Module*>
interface_modules` (third_party/uhdm2rtlil/src/frontends/uhdm/uhdm2rtlil.cpp, the "Removing
interface module" loop), a container keyed by the plugin's own heap addresses. Proof that the
order is an allocator artefact and not database content: the same law database through the
same Yosys gives `\dut \top` by default and `\top \dut` (the Surelog lane's order) with
`GLIBC_TUNABLES=glibc.malloc.tcache_count=0`; the pristine database gives `\top \dut` under all
four allocator settings tried. Both law databases are STRICT_EQUAL to golden. Verdict: not a
break of the laws (the plugin is out of scope); the extra allocations come from the orphaned
Lhs objects § ifPortViewPaLhsOwn419 leaves behind (byte hygiene, below).

## Verdict

PASS. Every headline number reproduced: law md5, the four corpus stages and their csvs, the sv-tests
stage's 9 conversions with 0 regressions and 0 changes (csv byte-identical to the implementer's),
byteverify 2/0/0 (Tnoc d/t), probe 0 of 4087, the 40-line grid, the earlier-pass census, the away
census. No break found by 51 fresh cases.

## Residues (ranked; all wrong on pristine too, none moved away)

1. Port-view parameter values inside a generate block where the interface instance is overridden
   by the genvar: golden writes the definition's default (B = 2) in the port view, ours the
   override (VP/vp03, vp07; ModuleEmit's port-view emission, the sister's ground).
2. A generate scope's own listing of imported parameters (VC/vc03, the implementer's ia14; ModuleEmit).
3. A modport-typed generic port `dut(i x)` connected with `.x(u.oth)`: the io_decl listing (VC/vc02).
4. A `parameter type T` between keyword-less entries (VO/vo08: golden lists A where we list T);
   a keyword-less `type T = int` whose use golden leaves unsupported_typespec (VO/vo02).
5. An elaborated interface continuous assign over its parameters folded by golden (VP/vp05).
6. Package arithmetic over 2^31 (VA/va01, va08, va11: golden INT:2147483653 / UINT:2147483648
   where we write the wrapped INT), a sized 32'd literal parameter's typespec (VA/va05).
7. Byte hygiene: § ifPortViewPaLhsOwn419 leaves the replaced Lhs objects in the database
   unreferenced (rsd 95 parameters + 95 ref_typespecs; every VL/VC case); `s.Erase` would need
   proof that nothing else references them.
8. The implementer's list: uo18, ia17, the three STRICT_NOTEQUAL basejump rows, the 57 non-UVM
   DIFFERENT heads.

## Sister-ground faces (report only)

- ModuleEmit `emitInterfaceInstance`: the port-view value restamp from a not-yet-final Lhs value
  (repaired design-final by this pass), and the generate-scope port-view values (residue 1).
- ModuleEmit: the generate scope's imported-parameter listing (residue 2).

## Process

- One law build (-j 2), no pristine build, one sweep, no refinement build. Attack grids ran as single
  processes, the first batch during my own sweep's corpus stages (my own processes only).
- Before launching the sweep and the sv-tests stage, pgrep of sweep.sh, svtests_matrix,
  verify_golden, check_probe, downstream_uhdm2rtlil and check_svtests read 0, three times.
- The fence list was read into a file by a program and never printed; every tree-wide list was
  filtered on it first. No fenced test was named, opened or run. No other agent's process touched.
