# v11u476: adversarial verification of r11u476

Pass 476, the module/type ground (ModuleEmit, UhdmExporter, TypeEmit). The verifier's report.
Base e6f5d904f. VERDICT: CONFIRMED, no break found, no production change. The verified patch's
src diff is byte-identical to the implementer's /tmp/r11u476.patch.

## Binaries (frozen under /tmp/v11u476_bin before any measurement; evidence/binaries.txt)

- law: rebuilt once from /tmp/r11u476.patch applied to a fresh e6f5d904f worktree
  (/tmp/wt_v11u476, `cmake --build build -j 2`): md5 8b59c2a66cda09cfb5aac611789ea29d, the
  implementer's law27. It links slang 12.0.0+545f88b2e.
- pristine: the implementer's frozen copy of the main tree's base build, md5
  1f099603e0eb6704a58436e2fa7da0ac (the budget: no pristine build and no pristine sweep; the
  pristine sweep reading is the master's control /tmp/intr11u474).
- No verified build, since nothing changed.

## The target rows (reproduced)

| row | control /tmp/intr11u474 | law sweep /tmp/v11u476_lw |
|---|---|---|
| generated/easyUVM/top.sv | DIFFERENT | **EQUAL**, fresh row `generated/easyUVM/top.sv,EQUAL,,equal` (CONVERSION) |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT, uhdm-cmp 46 lines | DIFFERENT, uhdm-cmp 46 lines (the sister's param_assign face) |

The row step behind the sister's face (pass 474's addpa.cpp built against ~/.local's UHDM, run on a
COPY of each database; measurement only; drivers/rowstep.sh, evidence/row_param_vif_step.txt):
the simulated copy reads uhdm-cmp 0 on both binaries; the first strict walk divergence moves from
#138364 (uvm_misc.svh 103, `pos`, 994575 objects against golden's 1002258) on pristine to #201344
(uvm_reg_map.svh 2034, typespec_member `data` against an operation, 1002253 objects) on the law,
with face (d) standing at #93329 and #165115 (set_arbitration's `val` UVM_SEQ_ARB_TYPE alias named
sfr_test_pkg where golden names sfr_agent_pkg and tb_params_pkg). The implementer's numbers, bit for
bit.

## Gates: one full five-stage sweep on the law binary (evidence/sweep_law.log)

Workdir /tmp/v11u476_lw (the control's length), launched by a wait script only after the sister
r11u483's sweep had ended; probe, surelog, uhdm2rtlil and downstream through this worktree's
tests/sweep.sh, sv-tests through the main tree's scripts/check_svtests.py (identical to the base's)
with `--baseline <worktree>/results/golden_svtests.csv`, since the worktree's UVM folder is empty.
R11U476_TRACE on.

- probe: EQUAL 4025, STRICT_NOTEQUAL 62; regressions 0, conversions 1, changes 0. The conversion is
  `r10uvm227repro/grid227/a9_class_holder STRICT_NOTEQUAL differ:depth(1) -> EQUAL`, fresh row
  `r10uvm227repro/grid227/a9_class_holder,EQUAL,,equal`, attributed to
  § cloneViaProviderTopClone476 by the trace (2 lines, its only probe process).
- surelog: default CMP_EQUAL 480, testflags 474; regressions 0, conversions 0, changes 0. The csv
  equals the control's except the two LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes; 0 / 0 / 0; csv equal to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not identical and not
  excused 0; csv equal to the control.
- sv-tests: EQUAL 1936, STRICT_NOTEQUAL 0, DIFFERENT 4, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0, conversions 1 (easyUVM),
  changes 0. The csv equals the control except the easyUVM row (evidence/csv_vs_control.txt).
- The corpus command exits 1 on the law index alone: this verifier's new case dirs were already on
  disk when the sweep started (tests/LAWS.md is regenerated in the verified patch).
- byteverify (SELFCHECK on) against the control: surelog 0 of 962, uhdm2rtlil 0 of 1608,
  downstream 0 of 805; each negative control flags all but its fixed file.
- probe databases: the sweep runs from a different tree, so the bytes carry a different source
  path; path-normalized uhdm-dump of all 4087 against the control differs on exactly 1,
  a9_class_holder; negative control 99 of 99 flagged (evidence/probe_dump_census.txt).
- sv-tests kept databases (the 25 databases the law sweep keeps): against the control each
  differs in exactly the 10 bytes of the workdir name except uvm_param_vif_config_db and rsd, the
  two kept rows the trace names (evidence/svtests_dump_census.txt); easyUVM converts and is no
  longer kept. A path-normalized uhdm-dump comparison agreed on the 23 it finished; its tnoc and
  rsd control dumps hit the 1800 s timeout and were read by raw bytes instead.
- canaries: canaries.sh ok=52 (surelog) and ok=16 (uhdm2rtlil); ctcan2.sh PASS on both (ok=58
  with 1 unknown pattern, ok=2 with 6).
- binary audit (fence-filtered): surelog 1523 of 1573 records name the law binary, the other 50
  hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346; no record names
  another slang-uhdm binary.
- trace (evidence/trace_sweep.txt): the laws fire in four processes only, as the implementer
  reported: a9_class_holder, easyUVM (23 fileMacroLenNormal476, 4 ifaceUdpShapedLowConnDecl476,
  2 ifaceUdpShapedNoRefMod476), uvm_param_vif_config_db (the provider laws) and generated/rsd/rsd.sv
  (SURELOG_CRASH at the base and after, no golden, exit code unchanged).

## The implementer's grid, reproduced (evidence/implementer_grid_repro.txt)

All 37 dirs on both binaries read the implementer's exit code, uhdm-cmp count, strict verdict and
dump distance, 74 of 74 lines. R11U476_OFF gives pristine's bytes on 37 of 37. (The implementer's
README heading says 36 dirs; there are 37, corrected there.)

## Pass 474's finding (evidence/finding474_check.txt)

§ cloneValFormalUnnamed474 now reads R11U474_CLONEPARNAME_OFF before the full-name getter. On the
105 runnable r11u474 and v11u474 case dirs the law binary is byte-identical to pristine; with
R11U474_CLONEPARNAME_OFF set on both binaries they are again identical, and the switch moves the
same 31 dirs on each. Byte-neutral, as expected.

## The attack grid: 72 fresh case dirs (cases/VI, VF, VP; evidence/grid_*.txt)

Every case is accepted by upstream slang (`~/.local/bin/slang dut.sv --single-unit`, rc 0 on 72 of
72; two first drafts slang rejected, vi19's mixed assignment and vf10's include path, were rewritten
before any run). Every exit code is 0 on both binaries. Surelog fails only on VF/vf10 (rc 4: its
nested `include "./inner.svh"` is resolved by slang from the including file's folder and not by
Surelog), so vf10 has no usable golden; it is kept as the one dir where the FILE law moves bytes
without a judge.

Totals, pristine -> law: STRICT_EQUAL 10 -> 50, STRICT_NOTEQUAL 29 -> 9, NOT_EQUAL 33 -> 13. No dir
reads a worse verdict on the law binary; 40 dirs move to STRICT_EQUAL. R11U476_OFF gives pristine's
bytes on 72 of 72, and each switch moves only its own law's dirs (evidence/grid_switches.txt):
FILELEN and CLONEPROVIDER each return all their movers to pristine; IFUDPREF and IFUDPLOW take back
their own halves of the shared VI dirs (vi01, vi07 and vi21 need only IFUDPLOW); FORINITHOME moves
the VP dirs with a declared for-init variable off the law's bytes while the provider law still acts.

Downstream verdict on all 72 (evidence/downstream_grid.txt): 7 EQUIVALENT -> IDENTICAL (vf01 to
vf06, vf12, nohier), VF/vf10 STATUS_DIFF on both, every other dir IDENTICAL on both. None moves away.

### VI: § ifaceUdpShapedNoRefMod476 and § ifaceUdpShapedLowConnDecl476 (30 dirs)

- To STRICT_EQUAL: vi02 (`#(4)`, delay2), vi05 (bit-select first terminal), vi07 (generate-for,
  low conn only), vi09 (two instances of a module holding one), vi10 (modport passed on), vi13
  (an implicit net first terminal), vi17 (`#(P)`), vi19, vi20 (an output port), vi21 (nested
  generate blocks, low conn only), vi23, vi24 (`#(4, 2)`), vi25, vi28 (interface passed to a
  submodule), vi29 (a part-select first terminal), vi30 (beside a named instance).
- Controls byte-identical: vi03 (named override), vi04 (three values), vi11 (literal first
  terminal), vi12 (empty terminal), vi18 (a bind into two instances), all STRICT_EQUAL; vi14 (`.*`)
  STRICT_NOTEQUAL endcol on both (an older face).
- Closer, not equal (all NOT_EQUAL or worse on pristine):
  - vi01, an interface ARRAY `a_if u[2](clk, rst)`: the low-conn law is right (golden 2:22 on both
    elements), uhdm-cmp 205 on both; the definition view still lists a module_array with ports
    where golden lists nothing (residue 2).
  - vi06, a concatenation first terminal: 189 -> 62 lines.
  - vi08, an interface instantiated in an interface: 1980 -> 1916.
  - vi15, `a_if u1(clk, rst), u2(clk, rst);`: NOT_EQUAL 199 -> STRICT_NOTEQUAL col (the
    implementer's residue 2 shape: u2's high connections at its own actuals where golden reuses
    u1's).
  - vi16, a non-ANSI interface header: NOT_EQUAL 135 -> STRICT_NOTEQUAL line; golden puts the low
    conn at the body declaration `input clk;` (3:9), the law at the header name (2:16), pristine at
    the actual (residue 1).
  - vi22, an operation second terminal `a_if u(clk, rst & en, en)`: NOT_EQUAL 213 -> STRICT_NOTEQUAL
    depth (golden lists no net for the operand; not decoded).
  - vi26, a module nested in the top: 71 -> 445 uhdm-cmp lines, dump distance 53 -> 21; the head
    moves LATER, from the definition view's ref_module (cleared) to the elaborated nested instance
    `work@top.i`, which golden lists with its interface and ours does not (an older face; uhdm-cmp
    prints the whole module).
  - vi27, a hierarchical first terminal `top.clk`: NOT_EQUAL 151 -> STRICT_NOTEQUAL col, the high
    connection's hier_path elements (golden spans `top` at clk's columns and leaves clk unnamed).

### VF: § fileMacroLenNormal476 (12 dirs)

- To STRICT_EQUAL: vf01 (`./inc.svh`), vf02 (`sub/./inc.svh` with `__LINE__`), vf03 (`__FILE__`
  through another macro), vf05 (two includes, `./sub` and `sub`), vf06 (`./sub/../sub`, a
  two-argument macro), vf08 (a multi-line macro body), vf12 (`$sformatf` around it).
- Controls byte-identical: vf07 (`__LINE__` only), vf11 (the top file).
- Closer, not equal: vf04, two `__FILE__` on one line, endcol 12 -> 4 objects; vf09,
  `parameter string F = `__FILE__;`, unchanged. In both the remaining object ENDS at the expansion
  (`a = `__FILE__`, the param_assign), golden at the normal literal's length and ours at slang's
  (residue 3).
- The top file given as `./dut.sv` or `../f1/dut.sv`: STRICT_EQUAL on both binaries
  (evidence/extra_measurements.txt).

### VP: § cloneViaProviderTopClone476 and § cloneForInitHomeVar476 (30 dirs)

- To STRICT_EQUAL: vp03 (a three-level chain t -> b -> a -> u), vp04 and vp05 (two providers in
  either order), vp08 (a task with a fork-block local and an output formal), vp11 (a module also
  importing u), vp12 (an out-of-body class method in the home), vp13 (a static local and recursion),
  vp14 (`export u::*` in the provider), vp15 (a call to another home function), vp16 (two blocks
  declaring the same local), vp19 (a queue local and foreach), vp20 (four levels), vp22 (a plain
  for init), vp24 (a class-typed formal, foreach in a class method), vp26 (a first import that
  offers nothing), vp27 (a provider that imports the home twice over), vp28 (`import b::*; import
  a::*;` with b importing a).
- Controls byte-identical: vp02 (an explicit `import a::AC;` only), vp10 (the provider imports
  `u::f` explicitly; the law does not fire), vp18 (a file-level import above the provider), vp23 (a
  module importer).
- Closer, not equal: vp07 NOT_EQUAL 24 -> STRICT_NOTEQUAL fullname and vp17 STRICT_NOTEQUAL depth
  -> fullname, both at a struct member's ref_typespec named `work@top.u::s_t.b` where golden names
  `a::f::s::u::s_t::b` (an older face); vp01 (`import a::*; import u::f;`), vp09 (the provider
  declares its own f), vp21 (two for loops with `k`, a two-variable init), vp25 (string methods),
  vp29 (a struct array local) and vp30 (a struct local in a named block with disable) keep their
  uhdm-cmp heads with smaller dump distances.
- vp06, the provider package declared AFTER the importer: NOT_EQUAL 427 on both, dump distance
  484 on both. Golden's t lists no clone of f at all (Surelog compiles packages in source order, so
  t copies a's empty list); ours lists one on both binaries, and the law re-binds that extra clone's
  references to a's clone. No verdict moves, but the law does not check the declaration order that
  pass 454's verifier required of import walks (finding 1).

## Away census (evidence/away_census.txt, away_movers_judged.txt)

12597 fence-filtered earlier case dirs under tools/probe whose dut.sv holds import, interface or
`__FILE__` (the path list built and filtered on the fence before any file was opened), pristine
against law, dut.sv --single-unit --nobuiltin: no exit code moves; 64 dirs move bytes, the
implementer's 65 less r11u251 BP/b07_positional, which law27 restores. Judged against golden on both
binaries: 34 reach STRICT_EQUAL (none was STRICT_EQUAL on pristine), four go NOT_EQUAL ->
STRICT_NOTEQUAL (R5/p1, PD/p01, VI/vi19_positional on line, VM/vm39_positional_multi on depth), two
stay STRICT_NOTEQUAL at a later object (below), and 24 stay NOT_EQUAL with a smaller dump distance
or a later head. Checked one by one:
- v11u264 VC/vc03_three_level_import: STRICT_NOTEQUAL depth on both, the walk's first divergence
  #91 -> #230, dump distance 211 -> 218 (later, as the implementer said).
- r11u241 CF/e09: depth at #241 -> fullname at #255.
- r11u459 FT/ft04, v11u459 VF/vf07, vf14: 18 -> 20 uhdm-cmp lines, the head moving from package
  x's foreach loop variable to module top's `pk::C` typespec, later in the walk.
- v11u459 VF/vf12: 24 -> 760, the head moving from package r's loop variable to the module_inst.
- v11u436 VC/vc09: 187 -> 311 with Surelog at rc 4 (a partial golden), the head moving from the
  definition module to its interface instance.
No dir moves away from golden. No break.

## Findings (no break)

1. § cloneViaProviderTopClone476 takes the first body import that offers the subroutine without
   checking that the provider package is declared before the importer. Surelog compiles packages
   in source order, so an importer declared first copies nothing from a later provider (VP/vp06:
   golden lists no clone in t). Both binaries write the extra clone, so no verdict moves; a future
   law that writes golden's empty listing should make the provider law abstain there too.
2. The implementer's README heading counts 36 grid dirs; there are 37 (corrected).

## Residues (all wrong on pristine too; none moved away)

1. The low conn of a udp-shaped instance of a NON-ANSI interface: golden at the body declaration
   (`input clk;`), the law at the header name (VI/vi16). The port's internal symbol location would
   serve both header styles; not written, since pristine was further.
2. Udp-shaped interface ARRAYS: the definition view lists a module_array with ports where golden
   lists nothing (VI/vi01; § ifaceUdpShapedNoRefMod476 reads per-instance children only).
3. An object ending at a `__FILE__` expansion (`a = `__FILE__;`, `parameter string F =
   `__FILE__;`): golden's end column counts the normal literal, ours slang's (VF/vf04, vf09); the
   location mapping of the intrinsic buffer's end, UhdmExporter.
4. The multi-instance interface statement (VI/vi15, the implementer's IU/iu14), an operation
   terminal (vi22), a hierarchical first terminal (vi27), an interface inside an interface (vi08),
   a nested module's elaborated instance (vi26).
5. uvm_param_vif_config_db: the sister's param_assign face, then face (d) and the uvm_reg_map.svh
   2034 typespec_member face, as the implementer reports.
6. The provider shapes not reached: an explicit `import u::f` in the provider (vp10), the provider's
   own same-named function (vp09), string-method and struct-array bodies (vp25, vp29, vp30).
7. The carried lists of the implementer and of passes 474 and earlier.

## Sister-ground faces

None new; the implementer's two stand (ParamEmit emitParameters' named `.A(K::w)` param_assign,
StmtEmit's § cloneLoopVarShared37 object for a direct importer).

## Process

- One law build (-j 2), no pristine build, no verified build; one full five-stage sweep on the law
  binary, launched by a wait script after the sister r11u483's sweep ended; no second sweep.
- Slip: the law build ran while r11u483's sweep was live (its probe stage had started about five
  minutes earlier; the build is not a measurement and no number was read from either during it).
  Every grid batch and the away census ran single-process during or after this verifier's own sweep.
- Case runs: drivers/runcase.sh (golden with check_probe.py's flags, cached per case dir), switch
  runs through EXTRA=<switch>=1, drivers/dsgrid.py for downstream, drivers/away.sh for the census,
  drivers/rowstep.sh for the row step.
- The fence list was read into a file by a program and never printed; every tree-wide list was
  filtered on it before any file was opened; the repro folder was scanned with it before delivery.
- No other agent's process was touched; every tool variable is checked by /tmp/v11u476_env.sh.
