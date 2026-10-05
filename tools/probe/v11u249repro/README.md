# v11u249: adversarial verification of r11u249 (the module/type ground, pass 249)

Base dfc487f1 (`matrix-1.87`). Implementer's patch /tmp/r11u249.patch, applied clean on a fresh dfc487f1 worktree.

**Verdict: VERIFIED, no production fix.** Every headline number of r11u249 reproduces bit for bit, except two small
misstatements in its README (below). No landed row, probe case or downstream row moves. No fresh case leaves
STRICT_EQUAL and no downstream case leaves IDENTICAL. No case found pristine right and the law wrong. The production
files of the delivery are byte-identical to the implementer's; this directory and the regenerated tests/LAWS.md are
the verifier's only additions.

## Binaries (built by the verifier, frozen before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine (fresh dfc487f1, system-deps cmake config, -j 2) | da60f833fd263102ef74d71140183800 | the same as the main tree's build/slang-uhdm |
| law (dfc487f1 + /tmp/r11u249.patch) | 9ef1b5bbcb757d8df1d568cb1d22bbd3 | the same as the implementer's law binary |
| uhdm-strictcmp (both trees) | fa6e4f42f252ae0ab69d9845003e71c5 | |

Both link slang 12.0.0+545f88b2e.

## Gates, reproduced (`evidence/*_sweep_summary.txt`)

Both sweeps ran from the law worktree with SLANG_UHDM exported (tests/sweep.sh --jobs 3, workdirs /tmp/v11u249_wdP
and /tmp/v11u249_wdL), so the probe databases embed the same path.

| gate | pristine sweep | law sweep |
|---|---|---|
| probe | 3511 EQUAL + 576 STRICT_NOTEQUAL, 0/0/0 | 3511 + 576, regressions=0 conversions=0 changes=0 |
| surelog | default 470 + 10, testflags 466 + 8, 0/0/0 | the same, 0/0/0 |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | the same, 0/0/0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same |

* The law sweep's exit code read 1 only because the verifier had added its own cases after regenerating the law
  index (`law index STALE`); every stage read 0 regressions. The index was regenerated at the end and
  `scripts/law_index.py --check` reads current.
* Every csv of the law sweep equals the pristine sweep's row for row (probe, uhdm2rtlil, downstream: 0 lines; surelog:
  the 2 LowMem log-path text rows, environment). Every csv equals the implementer's law sweep after the workdir name
  is normalised (0 lines in all four).
* **Binary-path audit**: 3315 fence-filtered cmds.txt per sweep, 3265 naming a slang binary, each naming only its own
  frozen binary (0 files of the pristine sweep name law.bin, 0 of the law sweep name pristine.bin or build/slang-uhdm).
* **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors /tmp/v11u249_mL and
  /tmp/v11u249_mP, same length, drivers/bvmirror.sh: mirrored=2560, fenced_skipped=8 each): PATH_SETS_IDENTICAL
  (2560), **MOVERS 0 / 2560**, SELFCHECK 2559 / 2560 flagged.
* **Probe databases**: 0 of 4087 move. **Downstream slang lanes**: 0 of 805 move.
* **Firing census** (`drivers/tracesweep.sh` on the law binary with R11U249_TRACE, both corpora in both modes with
  the fenced tests excluded by the harness filter, 794 surelog and 871 uhdm2rtlil tests, and the 4087 probe cases):
  **0 firings**. Positive control: the law binary on cases/F/f02_size1 writes
  `modTdElabFoldSize249 work@top.x` to its trace. The implementer's frozen prediction (0 movers) holds.
* **Canaries** (law csvs): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 on the
  surelog csv PASS (ok=58), EXPECT_UNKNOWN=6 on the uhdm2rtlil csv PASS (ok=2).
* **Determinism** (`evidence/determinism.txt`, drivers/det.sh, three concurrent harness runs of the law binary):
  one hash per row-mode on Earlgrey_0_1 and the five UVM rows, 11 of 11 (Scoreboard testflags has no database, as at
  the base), each equal to the law sweep's database.
* **Away census**: 0 corpus and 0 probe databases differ, so the census over the gate is vacuous; its instrument is
  byteverify's SELFCHECK. On the cases, the only case-view that moves while judge-equal on both binaries is Q/q03
  (STRICT_NOTEQUAL fullname -> STRICT_EQUAL), 0 records lost.
* **Targeted rows**: none moves, as the implementer reports. Every UVM row stays headed by its ground-A record.

## The implementer's grid and controls, reproduced

* **Grid** (`evidence/grid_impl_rerun.txt`, the implementer's drivers/grid.sh on the verifier's binaries, 1100
  lines, every line with its exit code): identical to the implementer's evidence/grid.txt in every field but the
  database md5, which carries the worktree path. R11U249_OFF gives pristine bytes on 110 of 110 case-views. 40 enter
  STRICT_EQUAL and none leaves. Each switch moves only its own law's cases.
* **Byte controls** (`evidence/controls.txt`, widened from 17 to 23 repro dirs: the implementer's 17 plus
  v11u241repro, r11u239repro, v11u239repro, v11u237repro, r11u235repro and v11u235repro; 2818 case-views, paths
  filtered by $FENCED before any case is opened): the same 18 movers as the implementer's, 8 entering STRICT_EQUAL,
  none leaving. The one rc=139 line is r11v124repro hx/x02_forstep in the elaborated view, on both binaries
  (pre-existing).
* **Downstream on the implementer's cases**: pristine 38 IDENTICAL / 11 EQUIVALENT / 4 STATUS_DIFF / 2 DIVERGENT;
  law 47 / 6 / 0 / 2 after one rerun, every verdict equal to the implementer's ds_law.txt. No case leaves IDENTICAL.

## Misstatements in the implementer's README (no number of the gate)

1. "Exit 4 drops from 90 case-views to 4": the grid reads **86** pristine case-views exiting 4 (24 exit 0); the law
   leaves 4 (A/a18, N/n07, both views).
2. "U u01 STATUS_DIFF -> IDENTICAL" is not a property of the law. The STATUS_DIFF is the SURELOG lane reading
   `CRASH` (the uhdm2rtlil Yosys plugin on Surelog's own database): 3 of 3 pristine draws and 1 of 3 law draws crash
   there, and the slang lane reads NO_GATES on every draw. The verdict is a reference-lane flake.

## Attack (`cases/`, 83 fresh cases in both views, `evidence/vgrid.txt`)

Pristine, law, law + R11U249_OFF and law + each of the seven switches (1660 lines, every line with its exit code;
drivers/vgrid.sh, summary `evidence/vgrid_summary.txt` by drivers/vgridsum.py). Every case's first line names the
law whose switch moves it, or says it is a control.

* **R11U249_OFF gives pristine bytes on 166 of 166 case-views.**
* **68 case-views enter STRICT_EQUAL and none leaves.** 140 move. Exit 4 drops from 126 case-views to 2 (N/n08).
* Each switch moves only its own law's cases. Two switches move one case where two laws combine:
  UNITDYNTD + WHOLEARRTD on a class property of a $unit dynamic typedef, DYNNETTYPE + UNITDYNTD on a $unit dynamic
  typedef variable, CLSTDARRPATH + WHOLEARRTD on a package class.
* Every case-view where pristine already exited 0 and the law moves its bytes moves toward golden: F/f02, f05 enter
  STRICT_EQUAL; F/f04 56 -> 28 cmp lines; F/f07, f08, f10 keep their count while the elaborated copy's right bound
  becomes golden's `INT:3` (dump-checked); P/p01 94 -> 17; Q/q03 STRICT_NOTEQUAL fullname -> STRICT_EQUAL.
* **Downstream** (`evidence/ds_*.txt`, drivers/dscases.py): pristine 48 IDENTICAL / 28 EQUIVALENT / 6 STATUS_DIFF /
  1 DIVERGENT, law 61 / 16 / 5 / 1. **No case leaves IDENTICAL.** 13 cases move to IDENTICAL. Four cases move
  EQUIVALENT -> STATUS_DIFF; see finding 1.

| group | law | cases | result (pristine -> law, both views alike unless noted) |
|---|---|---|---|
| P p01-p23 | § clsPropWholeArrTd249 | own-scope queue and fixed typedefs, a parameterised class, a derived class, class / struct / enum / vector / bit elements, string dynamic, two and local properties, a module-class typedef, ranged forms, assoc int, static / const / protected rand, 2-D, a foreign class's typedef, foreach and constraint uses, dynamic foreach, type-parameter defaults, a virtual override | STRICT_EQUAL: p02, p03, p04, p08, p10, p11, p12, p13, p16, p18, p19, p23 (rc 4 -> 0). Stage 1 on both: p01 (94 -> 17), p05 class element (43 -> 64), p06 struct element (43 -> 17), p07 enum element (43 -> 17), p09 string dynamic (94 -> 17), p14 the pattern initializer's constant sizes (141 -> 28, the r11u249 A/a17 face), p15 2-D (43 -> 230), p21 / p22 type-parameter defaults (see residue 4). Controls p17 (a foreign class's typedef, § classScopedTypedefPropIsBareLogicVar73) and p20 (a specialisation argument) unmoved. |
| Q q01-q06 | § clsTdArrElemPkgPath249 | interface, program, package and parameterised package classes, a class without the property, two packages with the same class and typedef names | STRICT_EQUAL: q01, q03 (from STRICT_NOTEQUAL fullname), q04, q05, q06. q02 (a parameterised package class, `[W-1:0]` element) stays stage 1 (199 -> 56): the element's range operation differs. |
| D d01-d13 | § unitDynArrTd249 | generate-block, interface and program variables, a function formal, a struct member, `int unsigned` / `byte` / `longint` / `integer` indexes, class / enum / real / string elements, two modules, procedural use, unused listings | STRICT_EQUAL: d03, d04, d05, d06, d10, d11, d12, d13. Stage 1 rc 4 -> 0: d01 generate block (327 -> 41), d02 interface (84 -> 58, residue 3), d07 class element (32 -> 86), d08 enum element (76 -> 17), d09 real element (84 -> 17). |
| M m01-m06 | § modDynArrTd249 | interface, parameterised, two-instance, assoc-string, program and generate-block typedefs | m01-m05 rc 4 -> 0, 17 cmp lines each (the implementer's residue 2, unreferenced Surelog clones). m06 (a generate-block typedef) is rc 0 on both, unmoved. |
| N n01-n12 | § dynAliasNetType249 (n02-n04 name § unitDynArrTd249) | signed vector, integer / time, inline packed struct, interface, `var` keyword, `reg` assoc, two declarators, alias element, reg / logic with string / int indexes | STRICT_EQUAL: n01, n02, n07, n11. Stage 1: n03 (17), n04 interface (58, residue 3), n05 `var` (58), n06 / n09 / n10 / n12 `reg` elements (47-75, finding 1). n08 (an aliased packed-struct element) exits 4 on both. |
| F f01-f13 | § modTdElabFoldSize249 | ranged `[0:8-2]` / `[0:5-1]`, size 1, nested instance, two variables with an initializer, two modules, typedef of the typedef, function local, port-net element, generate block, interface, parameterised modules, continuous assigns | STRICT_EQUAL: f02, f05. Toward golden in stage 1: f04, f07, f08, f10. Unmoved: f01, f06 (the ranged form is not an operation in the listing), f03, f09, f13 (STRICT_EQUAL on both), f11 interface and f12 parameterised element (the implementer's residue 5). |
| U u01-u05 | § unitUnpackedUnionTd249 | struct member, function formal, unused, class and module, two unions | STRICT_EQUAL: u01, u03, u05. u02 and u04 rc 4 -> 0 in stage 1 (the elaborated union_var face, the implementer's residue 3). |
| R r01-r05 | § unitDynArrTd249 (r01, r04 controls) | `reg` element order probes | finding 1. |

## Findings

1. **A `reg` scalar element makes the downstream plugin assert (READ_FAIL) on the law's database.** Pristine exits 4
   on all of these shapes. N/n06 (`typedef reg s_t[int]` beside `typedef reg [3:0] a_t[string]`), N/n10
   (`typedef reg s_t[int]`), R/r03 and R/r05 (`typedef reg d_t[]`): pristine EQUIVALENT (NO_GATES on both lanes) ->
   law STATUS_DIFF. The slang lane fails with `Assert 'width >= 0 && width < RTLIL::WIDTH_LIMIT'` in Yosys
   rtlil.cc. The switch is R11U249_UNITDYNTD_OFF (with it set the case exits 4 again and reads EQUIVALENT);
   R11U249_DYNNETTYPE_OFF does not change it. Vector `reg [3:0]` elements (n09, n12) and the queue r11u249repro N/n01_reg_q read
   EQUIVALENT.
   - **The face.** Golden writes the ELABORATED variable of a `reg`-typed typedef array into the instance's
     `vpiNet` list (`Nets()`), after the variables. Ours writes it into `vpiVariables`. In every case the whole
     uhdm-cmp difference is this placement (47 lines; n11, the same shape with `logic`, is STRICT_EQUAL).
   - **The decode.** Surelog NetlistElaboration.cpp elabSignal, the net branch: a net-kind signal (the typedef's
     keyword is `reg`) whose typespec is not a logic, struct, enum, bit or byte typespec takes
     `getSimpleVarFromTypespec`, giving an array_var, and with no unpacked dimension of its own lands in
     `nets->push_back((net*)obj)`.
   - **On pristine too.** The same placement is wrong for a FIXED-size `reg` typedef (R/r04
     `typedef reg [3:0] f_t[4]`, rc 0 on both binaries, 202 lines, unmoved). r01 (`reg [3:0] q[$]` written
     directly) is a separate pre-existing face: golden writes no array_var at all.
   - **The site.** ModuleEmit, the emitDynArrayVar branch of the elaborated signal loop (`vars->push_back(av)`), a
     module/type-ground write. This is not a pristine-right case (pristine exits 4), so the verifier does not fix
     it. It ranks first for the next module/type brief: the law turns an exporter refusal into a database the
     downstream tool cannot read.
2. **The shape gate is wider than its stated law.** `unitDynTdShape249`'s comment says "over a keyword element", but
   the code excludes only an alias or an unpacked element. Class handles (D/d07), inline enums (D/d08), inline packed
   structs (N/n03) and real or string elements (D/d09) enter § unitDynArrTd249 and § modDynArrTd249. All of them
   exit 4 on pristine and are stage 1 on the law. In d07 golden lists a `class_typespec (cq_t)` where ours lists the
   array; in d08 and n03 our elaborated copy carries a Typedef_alias golden lacks; in d09 golden has an element
   reference ours lacks. No STRICT_EQUAL case or downstream IDENTICAL case is affected. The next pass should narrow
   the gate to the keyword elements it has measured, or write these faces.
3. **The interface definition road has no twin of § dynAliasNetType249.** D/d02 and N/n04 (a $unit dynamic typedef
   variable in an interface) stay stage 1 at 58 lines: golden prints vpiNetType 36 on the interface's
   definition-view net where ours prints none. The site is emitInterfaceDef's § unpackedAliasNetType65 branch.
4. **Type-parameter properties.** P/p21 (`class c #(type T = f_t); T m;`) and P/p22 (a queue default) enter
   § clsPropWholeArrTd249 because the property's type resolves to the alias. Golden binds a per-property aliased
   copy whose alias reference is named `work@c::m::f_t`. Ours binds an int_typespec at the `T` token, the write
   phase's type-parameter binding. Both exit 4 on pristine and are stage 1 on the law (69 -> 112, 94 -> 88). A
   specialisation argument (p20, `c #(f_t)`) does not fire and is unmoved.

## Residues, ranked (the implementer's list stands; the verifier adds the faces above)

1. Finding 1: the `reg`-typed typedef variable belongs in the elaborated `Nets()` (ModuleEmit emitDynArrayVar branch;
   downstream READ_FAIL on scalar `reg` dynamic elements; fixed-size `reg` typedefs wrong on pristine too).
2. The implementer's residue 1: package typedef listings of arrays (sister ground, ParamEmit emitPackage).
3. The implementer's residues 2 and 3 (unreferenced Surelog tail clones; elaborated unpacked unions written as
   logic_net, U/u02, u04 here), and finding 3 (the interface definition-net twin).
4. Finding 2 (non-keyword elements through the dynamic-typedef shape gate) and finding 4 (type-parameter
   properties).
5. The implementer's residues 4 to 9 (class-property `[][$]` hybrids, module-body typedef variables in other
   positions such as F/f11 and f12 here, 2-D and parameter-sized class typedefs as in Q/q02 and P/p15, the remaining
   exit-4 shapes as in N/n08, the smaller faces, and the brief items not attempted).

## Process

* **Fence.** No fenced test was dispatched, read or opened outside the gate sweeps. Every driver reads $FENCED
  fail-closed from tools/probe/r11u107repro/canaudit.sh. The cmds.txt audit, the byteverify mirrors and the byte
  controls filter their path lists by $FENCED before opening a file.
* **One process error.** The probe and downstream byte-compare loops (cmp over the probe and downstream sweep
  workdirs) ran on an unfiltered path list. A check on path names only, run afterwards, shows that neither list
  holds a fenced name (0 of 4087 probe databases, 0 of 805 downstream databases, 0 downstream directories), so no
  fenced database was opened.
* **One driver defect, fixed before any count was reported.** A first away-census loop shared one scratch dir across
  cases. uhdm-strictcmp writes no record dump on a stage-1 verdict, so stale dumps were read. It was rerun with one
  directory per case. The census is reported only for case-views that are judge-equal on both binaries.
* **Other agents.** No process of another agent was listed or signalled. Every tool call through a variable was
  guarded with `[ -x ]`.

## Drivers

`drivers/` (copied from r11u249repro/drivers unless noted; each reads $FENCED fail-closed and resolves paths from
the repo):

* `env.sh`, `case.sh` (relative names `v/...` for these cases), `grid.sh`, `controls.sh`, `det.sh`, `dscases.py`,
  `tracesweep.sh`, `bvmirror.sh`, `awayrows.py`, `cc_x.sh`, `strictcmp_x.cpp`, `flatlost.py`.
* `vgrid.sh` (new): the grid over these cases.
* `vgridsum.py` (new): its per-case-view summary.
* `away.py` (from v11u202repro): the order-blind away census of one case.
