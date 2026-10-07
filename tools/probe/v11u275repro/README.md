# v11u275 — adversarial verification of r11u275 (pass 275, the module/type ground)

Base `dc979404` (pass 273). Implementer's delivery `/tmp/r11u275.patch` (tools/probe/r11u275repro). Verdict:
**ACCEPT WITH ONE FIX** — every headline number reproduces bit for bit; 81 fresh case dirs (162 case-views) find
no case-view leaving STRICT_EQUAL, no exit-code change and no downstream verdict leaving IDENTICAL; one refinement,
§ defNetTpPatKeepsActual275v, clears the implementer's own declared away face (grid TN tn07 `--elabuhdm`, 3
golden-agreeing records lost under the law) and moves no gate database.

| binary | md5 | what |
|---|---|---|
| pristine | `0bb3812861a4eae78cd2f672f6a144fb` | built here at the base; equals the brief's md5 |
| law | `a0b963c2946ea0de76c0dd91807973c5` | the implementer's patch built here; equals the implementer's frozen law |
| fix | `afa6257ba1b12a762f79bdeaa32a3231` | law + this pass's refinement (the verified patch) |

All three link slang 12.0.0+545f88b2e. Each was frozen read-only before any measurement made with it. Two
intermediate fix binaries were withdrawn (below) and every fix number was rerun on the final one.

## Reproduced (law against pristine, same harness, same-length workdirs)

- probe: pristine 3682 EQUAL + 405 STRICT_NOTEQUAL; law 3721 + 366, regressions=0, conversions=39, changes=7 (the
  same 39 names and 7 changes as the implementer's `evidence/probe_conversions.txt`); 47 of 4087 probe databases
  move, exactly the 47 of the implementer's predict.txt; away census on all 47 (`drivers/awayprobe.py`, away.py
  order-blind + awaychain.py chain-keyed against the cached goldens): 0 lost, 0 chain-keyed away
  (`evidence/away_probe_movers.txt`; g122_f_clone dist 32 -> 23, 9 toward).
- surelog default 476 + 4, testflags 470 + 4; uhdm2rtlil 803 / 1 / 67 both modes; regressions=0 conversions=0
  changes=0 in both; the csvs identical to pristine's row by row (the two LowMem rows differ only by the workdir
  path in their detail text).
- downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; the csv identical to pristine's and to
  results/downstream_uhdm2rtlil.csv; 0 of 805 fence-filtered downstream-lane databases move (positive control: two
  different rows flagged).
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered hard-link mirrors
  (`drivers/bvmirror.sh`, 2560 databases, 8 fenced row-modes left out): MOVERS 0 / 2560, SELFCHECK 2559 / 2560.
- the firing census (`drivers/tracecensus.sh`, the law binary under R11U275_TRACE, filters built from $FENCED):
  49 lines, identical to the implementer's predict.txt line for line (`evidence/census_predict.txt`; per law,
  databases fired: IMPNETDIMEND 15, DEFNETTPPAT 11, TPVARINIT 8, IFGENUNBOUND 6, TFARRRANGEEND 6, TPPATRESET 6; the
  FuncDeclScope d/t prediction does not move, as the implementer says).
- the implementer's grid (44 dirs, 88 case-views, `drivers/grid.sh`): summary identical line for line to its
  `evidence/grid_summary.txt` (`evidence/grid_impl_reproduced_summary.txt`): 60 moving, 47 entering, 0 leaving,
  OFF = pristine on 88 of 88, every mover attributed to exactly one switch.
- canaries surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs; binary-path audit
  3265 of 3315 fence-filtered cmds.txt name each sweep's own binary (pristine, law, fix), the other 50 run no
  slang, none names another binary.
- Surelog decode spot-checked: CompileHelper::bindVariable (CompileStmt.cpp) handles function, task, begin and
  module_inst scopes only and recurses to VpiParent for every other kind, so an interface_inst never binds its own
  signals (§ ifaceGenCaLhsUnbound275's basis); UhdmWriter::writeCont_assign ends with
  `tps->VpiParent(nullptr)` (§ tpPackedArrCaUnparent275's basis); writeElabInterface calls writeCont_assign with the
  interface_inst as scope.

## The fix: § defNetTpPatKeepsActual275v — `R11V275_KEEPACTUAL_OFF`

The implementer's residue TN/tn07_param_depth `--elabuhdm` (`localparam int D = (1 << $bits(id_t))`,
`localparam type rt_t = id_t [D-1:0]`): golden's definition net `y` lists the range bound `ref_obj D` bound to the
INSTANCE's parameter `work@dut.u.D`; under the law our copy's `ref_obj D` is bound to the DEFINITION's
parameter `work@child.D`, which the strict walk does not re-expand (it was listed outside any typespec subtree),
so 3 golden-agreeing records (parameter, ref_typespec, int_typespec) are lost and the first record moves from #43
to #37. Decode by trace: at export time the source array's `ref_obj D` has NO binding (both null); the binding is
made later by UHDM's ElaboratorListener (uhdm_main.cpp, only under --elabuhdm), which binds our copy, parented
in the definition, to the definition's D. Golden's object is the SHARED last-instance compile: the listener binds it
while visiting the FIRST instance and later visits find it bound — measured on fresh cases: VN vn11 / vn12 golden
`work@dut.u.D` / `work@dut.u.N` with the last instance w's element; vn14 `work@dut.w.N` (the first instance u
overrides the array itself and is skipped); vn15 `work@dut.m.c.N` (a nested first instance, depth first). The
refinement records each (first qualifying instance's array, copy) pair in § defNetTpDimLastInstPat275 and, right
after the listener, gives every ref_obj of the copy (through packed-array ranges and their operations) the binding
its counterpart holds (UhdmExporter `defNetTpPatKeepActual275v`, called from uhdm_main.cpp; `src/R275.h` gains
`r11v275On`: `R11V275_OFF` gives the law's bytes, `R11U275_OFF` still gives pristine's). The default view is never
touched (no listener), so the refinement predicted 0 gate movers before the fix sweep
(`evidence/predict_fix.txt`) and moved 0 (below).

Withdrawn before the final binary: fix1 (copied the binding at export time: the source had none, fired nowhere) and
fix2/fix3 (fix3 bound from the LAST instance after the listener: tn07 STRICT_EQUAL but vn11 / vn12 / vn14 / vn15
read the last instance's parameter where golden reads the first's; its gate sweep was stopped by its own task id
and its workdir deleted unread).

## Fix measurements

- Grid (`drivers/gridv.sh`, `evidence/grid.txt` 1500 lines each with its exit code, `evidence/grid_summary.txt`):
  125 dirs (the implementer's 44 + 81 fresh), 250 case-views, configurations P, L, F, FV (F + R11V275_OFF),
  FU (F + R11U275_OFF), FK (F + R11V275_KEEPACTUAL_OFF): FV = L bytes on 250 of 250, FU = P bytes on 250 of 250;
  F against P 178 moving, 115 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 2 uhdm-cmp line-count changes
  (VG vg07 both views, 251 -> 239 lines, stage 1 on all three binaries, the law's IFGENUNBOUND, 0 away); F against L
  6 moving, all six restored by R11V275_KEEPACTUAL_OFF: TN tn07 `_el` line -> STRICT_EQUAL (CONVERTED), vn11 /
  vn12 / vn13 / vn14 / vn15 `_el`.
- Away census F against P on all 178 movers (`evidence/away_grid_fix_vs_pristine.txt`): 0 lost, 0 chain-keyed
  away. F against L on the 6 (`evidence/away_grid_fix_vs_law.txt`): 0 lost, 0 chain-keyed away, 3 toward each.
- Gate sweep (`evidence/sweep_F_summary.txt`): probe 3721 + 366, regressions=0 conversions=39 changes=7; surelog
  and uhdm2rtlil regressions=0 conversions=0 changes=0; downstream 803 / 66 / 2 / 0 with the csv identical to
  pristine's and to the baseline; the probe, surelog and uhdm2rtlil csvs identical to the law sweep's; byteverify
  fix against law 0 / 2560 corpus, 0 of 4087 probe, 0 of 805 downstream-lane databases (the prediction).
  Canaries ok=52 / ok=16, ctcan2 PASS twice. Every sweep exited 1 on the law-index check alone (case dirs added
  during the runs; the index is regenerated last).
- Determinism (`drivers/det.sh`, three concurrent draws per row-mode with the fix binary,
  `evidence/determinism_fix.txt`): Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg, Rggen,
  12 row-modes, one hash each, equal to the pristine and fix sweeps' hashes.
- Downstream on all 125 case dirs (`drivers/dscases.py`, `evidence/downstream_cases_{pristine,law,fix}.txt`):
  pristine 86 IDENTICAL, law and fix 112 IDENTICAL (12 DIVERGENT -> IDENTICAL, 14 EQUIVALENT -> IDENTICAL), none
  leaving IDENTICAL, the law and the fix the same verdict on every dir.

## Fresh cases (cases/, 81 dirs, both views; each dut.sv names its law on line 1)

- VV (§ tpTypedVarInitNameSpan275, 15): anonymous struct, two declarators, `var` from a macro, `var` with a `;` in
  a comment, generate block, interface, scalar logic, multi-line initializer, package-struct override, real, a
  localparam chain, enum, no-initializer control, CRLF, two instances.
- VA (§ tfLocalArrRangeDimEnd275, 12): descending range, parameter range, range then size, two declarators, module
  task, interface function, initializer, macro range, static class method, spaces, size control, CRLF.
- VI (§ importNetTsDimEnd275, 19): size, int, bit 2-D, typedef with packed dimension, packed + unpacked, two
  unpacked, explicit import, interface header import, package wire 2-D, multi-line, CRLF, signed, reg, scalar
  unpacked, queue + dynamic, macro dimension, two packages at the same declarator position in two modules, three
  packed, struct unpacked.
- VG (§ ifaceGenCaLhsUnbound275, 8): case generate, generate-local net, plain int parameter, interface in a
  module generate scope, typed parent namesake, for generate, interface port, two interface instances.
- VP (§ tpPackedArrCaUnparent275, 12): two dimensions, bit-select left side, parent override, interface,
  always_comb control, two type parameters, union body net, member-select left side, named-struct control, net
  declaration assignment, generate-conditional assignment in one of two instances, two definitions.
- VN (§ defNetTpDimLastInstPat275, 10: three instances, depth-first vs breadth-first last instance, package
  element, port and body, for-generate genvar widths, two definitions interleaved, interface, struct element,
  non-local parameter, always_comb variable; § defNetTpPatKeepsActual275v, 5: vn11 to vn15 above).

Law against pristine on the fresh set: 162 case-views, 118 moving, 67 entering STRICT_EQUAL, 0 leaving, every mover
attributed to exactly one switch (`evidence/grid_fresh_lawonly_summary.txt` for the first 74 dirs: DEFNETTPPAT 18,
IFGENUNBOUND 10, IMPNETDIMEND 34, TFARRRANGEEND 20, TPPATRESET 10, TPVARINIT 12), R11U275_OFF pristine on all.
The laws held on every shape tried: no break was found in the law beyond the tn07 family.

## Residues (all wrong on pristine too; none moved away by the laws)

1. § defNetTpDimLastInstPat275 / KEEPACTUAL: the last instance's OWN array in the elaborated view — golden's
   instance shares the object the first instance's visit bound, ours lists its own binding (vn12 / vn14 / vn15
   `_el` depth at #200 to #269, vn13 `_el` a `<in>rt_t.N` vs `<in>N` full name, the walk diverging at #36 to #43
   on pristine); an override written as the default's own type (`.id_t(logic)`, vn11: golden locates the
   element at the override, ours at the default, line on every binary); an always_comb-driven variable
   (vn10, fullname, the b21 face); interfaces (vn07, stage 1).
2. § tpTypedVarInitNameSpan275 in an interface (vv06 endcol unmoved) and through a localparam type chain (vv11
   line unmoved); stage 1 on every binary: vv01 default view, vv05 generate block, vv08 multi-line initializer,
   vv10 real, vv15 two instances (DIVERGENT downstream on vv05, vv06, vv08, vv10 on every binary).
3. § importNetTsDimEnd275: the package NET's own listing (vi09, the sister's ground, as the implementer's in02);
   a struct element with an unpacked dimension (vi19, endline); stage 1 on every binary: vi04, vi08 default view,
   vi15, vi16.
4. § tfLocalArrRangeDimEnd275: va06 (an interface function: the three array records cleared, the call `u.f(5)`
   folded where golden keeps the hier_path); stage 1 on every binary for package functions called from a
   continuous assignment (va01, va02, va04, va07, va08, va10, va11, va12).
5. § tpPackedArrCaUnparent275: bit-select and member-select left sides (vp02, vp08) and an unassigned second
   type parameter or definition (vp06, vp12) keep fullname records (moved toward golden, 0 away); vp03 an anonymous
   struct override actual exits 3 on every binary (pass 273's vt03); vp10 Surelog crashes (no golden).
6. The implementer's ranked residues and items (2) to (7) of the brief stand as it lists them.

## Process

- The fence: every corpus path list was filtered by $FENCED (from tools/probe/r11u107repro/canaudit.sh's FENCED=
  line) before anything was opened; byteverify ran on fence-filtered mirrors; the census used the fence filter; no
  fenced source or database was read.
- THE VERIFIER'S SLIP: one uhdm-dump call ran with UHDM_DUMP unset and without the `[ -x ]` guard, so the shell
  executed a scratch database (/tmp, this pass's own tn07 output); every redirection it attempted failed ("No such
  file or directory"), and a check of the main tree (git status clean, no new file in its root) and of the worktree
  found no stray file. Every later tool call was guarded.
- Processes: only this pass's own background sweep (the withdrawn fix3 sweep) was stopped, by its own task id; no
  leftover process named its workdir. Nothing was written outside the worktree and /tmp/v11u275_* scratch.
