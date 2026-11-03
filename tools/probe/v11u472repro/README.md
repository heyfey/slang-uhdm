# v11u472 — adversarial verification of r11u472

Base 67001800 (pass 470 landed). Implementer's patch /tmp/r11u472.patch: two laws, in
src/ModuleEmit.cpp (§ grpOwnOobGenericCls472, switch R11U472_GRPOOBGEN_OFF) and
src/UhdmExporter.cpp (§ clsImpGroupHomeOrder472, switch R11U472_CLSGRPORDER_OFF).

VERDICT: CONFIRMED, NO BREAK, NO PRODUCTION CHANGE. The verified patch's src diff is
byte-identical to the implementer's. This patch adds only this folder and the
regenerated tests/LAWS.md.

## Binaries (frozen before any measurement)

- pristine: a copy of the main tree's build/slang-uhdm, md5 68485a77e78c33553a08c638ca5f629c
  (no pristine build, per the budget).
- law: rebuilt once from the patch in /tmp/wt_v11u472 (-j 2), md5
  21cd25b130d5a097624f8d4fc3dbb292, equal to the implementer's law2. It links slang
  12.0.0+545f88b2e.
- No verified build, because nothing changed.

## Code audit (src diff)

- No src/R*.h, no getenv, no header change. Both switches go through lawOn(472, ...);
  each law has a lawTrace(472, ...) call.
- § grpOwnOobGenericCls472 collects into a std::map keyed by name, so its output does not
  depend on the pointer-keyed classOobTfs iteration order. The clash test is
  order-independent, and a clash makes the law abstain for the whole package.
- § clsImpGroupHomeOrder472 reuses reorder446, which is keyed on the import statement's
  buffer and offset and on the home DEF listing's index. It is deterministic and
  idempotent if two classes share one vector. Both laws read only VpiName.
- NOTE (not a break): § clsImpGroupHomeOrder472 is also gated on R11U446_IMPGRPORDER_OFF.
  Dropping pass 446's switch drops this law too, and reorder446's own
  lawTrace(446, "importGroupKeepsHomeOrder446", <class name> ...) lines now also fire for
  class listings. The implementer's README does not say this.

## Reproduction of the implementer's numbers

- Grid r11u472repro CL/cl01 to cl08 and TI/ti01 to ti10, on exit code, uhdm-cmp line
  count, strict verdict and md5, all reproduced (evidence/grid.txt). Pristine CL: 3
  STRICT_EQUAL, 1 STRICT_NOTEQUAL, 4 NOT_EQUAL. Law CL: 8 of 8 STRICT_EQUAL. cl03 and all
  TI dirs are byte-identical.
- Switch table reproduced (evidence/switches.txt):
  - R11U472_OFF gives pristine's bytes on all 8 CL dirs, all 9 TI dirs, the 4 away
    movers and all 31 of this verifier's dirs.
  - R11U472_GRPOOBGEN_OFF alone restores cl02, cl04, cl07, cl08 and VP/vp01.
  - R11U472_CLSGRPORDER_OFF alone restores cl01, cl06, UG/ug01, UG/ug02 and VG/vg05.
  - cl05 needs both switches.
- Target row generated/uvm-examples/uvm_param_vif_config_db.sv, run through the runner on
  both binaries with the cached golden (0445655ee703/50a224b0134d47ab3870):
  - DIFFERENT on both; uhdm-cmp 172 -> 172 lines.
  - The class-listing census (evidence/tools/clsall.cpp: every class_defn's subroutine
    listing from every container, name, index and parent) reads 1507 differing lines
    against golden on pristine (15131 entries against golden's 15136) and 0 on the law
    binary (15136 entries).
  - The implementer's claim stands: tb_params_pkg::SFR at 984 entries and the five
    sfr_test_pkg classes equal golden name for name, parent for parent, in order.
  - The law database of the sweep and the runner's database are STRICT_EQUAL --no-canon
    to each other. The byte size differs by about 140 bytes, as it does between the
    master's control and the pristine runner run. That is workroot text.
- easyUVM: unchanged (the sweep's sv-tests csv is identical to the control's).

## Full five-stage sweep on the law binary (one sweep, R11U472_TRACE on)

drivers/sweep.sh, evidence/sweep_law_summary.txt. The machine was quiet at launch
(pgrep of sweep, runner, verify, probe, downstream and svtests processes read 0). The
corpus stages ran from /tmp/wt_v11u472. The svtests stage ran through the main tree's
tests/sweep.sh (same base, same golden csv), since the worktree's UVM folder is empty.

| stage | reading | regressions / conversions / changes | csv vs control /tmp/intr11u470 |
|---|---|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087 | 0/0/0 | identical |
| surelog | default CMP_EQUAL 480, testflags 474 | 0/0/0 | only the two LowMem testflags log-path texts differ |
| uhdm2rtlil | 803/1/67 in both modes | 0/0/0 | identical |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | — | identical |
| svtests | EQUAL 1935, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | 0/0/0 | identical |

- Both sweep commands exited 1 on "law index STALE" alone.
- byteverify against the master's control (SELFCHECK=1, same-length roots /tmp/v11u472_sw
  and /tmp/intr11u470): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805. The
  self-checks flag 961, 1607 and 804 (evidence/byteverify_law_vs_control.txt).
- Probe: the 4087 databases differ in bytes from the control only by the embedded source
  root (the worktree against the main tree). The path-normalized uhdm-dump is the same
  in 4087 of 4087; the negative control (law databases against one fixed control
  database) reads DIFF in 200 of 200 (evidence/probe_dump_census.txt).
- Trace (evidence/trace_sweep_law.txt): exactly one database in the whole sweep,
  sv-tests uvm_param_vif_config_db.
  - § grpOwnOobGenericCls472: 40 lines, the five sfr_agent_pkg definitions, 8 each.
  - § clsImpGroupHomeOrder472: 1 line, class SFR.
  - No corpus row, no probe case, and not the two scanner false positives the
    implementer named (uvm_slave_agent, uvm_slave_agent_multi_seq_item).
- Canaries ok=52 and ok=16 with changed=0. ctcan2 PASS on both
  (EXPECT_UNKNOWN=1 surelog, EXPECT_UNKNOWN=6 uhdm2rtlil).
- Binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the law binary (the
  other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346. No
  other slang-uhdm binary appears in any cmds.txt.
- No corpus byte mover, so no determinism draw was needed for the UVM corpus rows.

## Away census (independent selection)

drivers/away1.sh, evidence/away_census.txt. 2678 dirs: every earlier case dir under
tools/probe whose dut.sv holds both `class` and `import`, plus every dir with a FILES
list. The path list was fence-filtered before any file was opened. Each dir ran on both
binaries.

- 2660 exit-0 dirs, 11 exit-3 dirs and 3 exit-4 dirs are byte-identical.
- No exit code moved.
- 4 exit-0 dirs move, the same four the implementer named. Each is attributed by switch
  and each is closer to golden (evidence/distance_movers.txt, class-listing distance and
  dump distance):

| case | pristine | law | law (switch) | class / dump distance |
|---|---|---|---|---|
| r11u466 UG/ug01 | STRICT_NOTEQUAL name | STRICT_EQUAL 249 | § clsImpGroupHomeOrder472 | 8/124 -> 0/52 |
| r11u466 UG/ug02 | NOT_EQUAL 136 | STRICT_EQUAL 179 | § clsImpGroupHomeOrder472 | 4/68 -> 0/32 |
| v11u455 VP/vp01 | NOT_EQUAL 710 | STRICT_EQUAL 171 | § grpOwnOobGenericCls472 | 0/28 -> 0/24 |
| v11u446 VG/vg05 | NOT_EQUAL 46 | NOT_EQUAL 46, same head | § clsImpGroupHomeOrder472 | 6/215 -> 0/211 |

## Attack grid (31 fresh dirs, cases/VG, VM, VO)

- Upstream slang (~/.local/bin/slang dut.sv --single-unit) accepts all 31 (rc 0). The
  negative control `int x = ;` reads rc 1.
- Every exit code is 0 on both binaries. drivers/runcase.sh writes its output to
  /tmp/v11u472_runs/<full case path>.
- Tallies:

| binary | STRICT_EQUAL | STRICT_NOTEQUAL | NOT_EQUAL |
|---|---|---|---|
| pristine | 5 | 6 | 20 |
| law | 24 | 2 | 5 |

  19 dirs newly STRICT_EQUAL, 4 byte-identical controls (vg06, vg11, vg13, vo02).
- No dir is further from golden. Every one of the 27 movers has the class-listing distance
  and the dump distance lower or equal on the law binary (evidence/distance_movers.txt).
  One mover keeps both distances: vo01 re-orders a class listing inside an interface
  that golden does not list at all.
- Switches: each law's switch alone restores exactly its own movers.
- Downstream on vo07, vo10, VG/vg05 and VM/vm02: IDENTICAL on both binaries.

§ grpOwnOobGenericCls472 cases (VG, VM):

| case | shape | pristine -> law |
|---|---|---|
| VG/vg01 | two specializations as typedefs | NOT_EQUAL 302 -> STRICT_EQUAL 68 |
| VG/vg02 | type-parameter class, return D::T | NOT_EQUAL 378 -> STRICT_EQUAL 156 |
| VG/vg03 | out-of-body new and static function | NOT_EQUAL 308 -> STRICT_EQUAL 149 |
| VG/vg04 | plain and generic class side by side | NOT_EQUAL 164 -> STRICT_EQUAL 56 |
| VG/vg05 | module imports the home directly, module variable D #(3) | NOT_EQUAL 142 -> STRICT_EQUAL 40 |
| VG/vg06 | home with no import | STRICT_EQUAL, byte-identical (law does not fire) |
| VG/vg07 | generic extends a plain class, virtual override | NOT_EQUAL 208 -> STRICT_EQUAL 62 |
| VG/vg08 | two homes, each with a generic | NOT_EQUAL 164 -> STRICT_EQUAL 75 |
| VG/vg09 | virtual generic with a pure method, extended | NOT_EQUAL 142 -> STRICT_EQUAL 54 |
| VG/vg10 | type parameter defaulted from a value parameter | NOT_EQUAL 73 -> 73, bytes move, closer (class 1 -> 0, dump 64 -> 62) |
| VG/vg11 | class in an interface | byte-identical, NOT_EQUAL 81 |
| VG/vg12 | diamond, three methods out of written order | NOT_EQUAL 182 -> STRICT_EQUAL 84 |
| VG/vg13 | default-less generic `class D #(int W)` | byte-identical, NOT_EQUAL 94; residue 1 below |
| VG/vg14 | three type specializations | NOT_EQUAL 332 -> STRICT_EQUAL 112 |
| VG/vg15 | generic in two chained homes | NOT_EQUAL 294 -> STRICT_EQUAL 73 |
| VG/vg16 | macro-written out-of-body methods, class in module | NOT_EQUAL 160 -> STRICT_EQUAL 43 |
| VM/vm01 | generic plus macro clones | NOT_EQUAL 428 -> STRICT_EQUAL 201 |
| VM/vm02 | diamond import with a generic in the middle package | NOT_EQUAL 294 -> STRICT_EQUAL 93 |
| VM/vm03 | two generics, two specializations | NOT_EQUAL 220 -> STRICT_EQUAL 66 |

§ clsImpGroupHomeOrder472 cases (VO):

| case | shape | pristine -> law |
|---|---|---|
| VO/vo01 | class in an interface | NOT_EQUAL 353 -> 353, bytes move with both distances equal: golden lists no subroutines in that class, ours four (re-ordered) |
| VO/vo02 | class in a program | byte-identical, NOT_EQUAL 387 |
| VO/vo03 | $unit class, file-scope import | STRICT_NOTEQUAL name -> STRICT_EQUAL 182 |
| VO/vo04 | two import runs plus a class's own out-of-body method | STRICT_EQUAL -> STRICT_EQUAL, closer |
| VO/vo05 | macro-written free functions | STRICT_EQUAL -> STRICT_EQUAL, closer |
| VO/vo06 | nested class in a module class | STRICT_NOTEQUAL name -> STRICT_NOTEQUAL name, closer; residue 2 below |
| VO/vo07 | class in a module instantiated twice | STRICT_NOTEQUAL name -> STRICT_NOTEQUAL name, closer; residue 3 below |
| VO/vo08 | generic class | STRICT_EQUAL -> STRICT_EQUAL, closer |
| VO/vo09 | reversed written order | STRICT_EQUAL -> STRICT_EQUAL, closer |
| VO/vo10 | package class with its own out-of-body method and a free function, module class | STRICT_NOTEQUAL name -> STRICT_EQUAL 247 |
| VO/vo11 | two import runs from two homes, module class | STRICT_NOTEQUAL name -> STRICT_EQUAL 280 |
| VO/vo12 | four-level chain | STRICT_NOTEQUAL name -> STRICT_EQUAL 292 |

## Residues (ranked; all wrong on pristine too, none moved away)

1. uvm_param_vif_config_db's first head, the SISTER's (ParamEmit emitPackage writes no
   package virtual-interface typedef), then the this_t vpiInstance face the implementer
   did not decode. The row cannot move until the sister writes the listing.
2. § clsImpGroupHomeOrder472 does not reach a NESTED class's listing (VO/vo06: the
   uhdm-strictcmp head is the depth-4 C::z9 under work@top::S's nested class, golden
   C::get_bytes). The class walk visits only the top-level Class_defns of each container.
3. § clsImpGroupHomeOrder472 (and § importGroupKeepsHomeOrder446 before it) does not reach
   the class listing of a NON-TOP elaborated instance (VO/vo07: the head is under
   module_inst u1 work@top.u1, class S; the walk visits d->TopModules() but not their
   child instances).
4. A default-less generic class (VG/vg13): golden lists the out-of-body run <
   class_defn D in TOP r::S; ours lists nothing. The law does not fire, because no
   class_defn for the generic is listed in the home's views.
5. Classes inside interfaces and programs (VO/vo01, VO/vo02, VG/vg11), where the
   pre-existing listing already disagrees with golden (golden lists no subroutines in the
   interface class).
6. VG/vg10's remaining NOT_EQUAL head (a type parameter defaulted from a value parameter),
   unrelated to the law.
7. The implementer's residues 2 to 5 and the carried backlog stand as stated.

## Sister-ground faces

None new. The implementer's three stand: ParamEmit emitPackage's virtual-interface
typedefs, ExprEmit's __FILE__ path and default argument, and EmitHelpers.h
collectMaterializedPkgs.

## Process

- One law build, one five-stage sweep, one byteverify, one probe dump census, one away
  census, 31 attack dirs. No pristine build or sweep; no third build.
- Before the build and the sweep, no sweep, runner or svtests process of another agent
  was live. A sister verifier's single downstream case run (v11u477) was live during the
  build; it is not a sweep.
- The fence list was read from canaudit.sh by a program into a file and never printed.
  Every tree-wide list (cmds.txt audit, away census, csv diffs) was filtered on it first.
  This folder scans clean against it.
- No process of another agent was touched.

## Files

- cases/VG (16 dirs), cases/VM (3), cases/VO (12). Each dut.sv names its law on line 1.
- drivers: runcase.sh, dist.sh, away1.sh, pdump.sh, sweep.sh.
- evidence: grid.txt, switches.txt, distance_movers.txt, away_census.txt,
  byteverify_law_vs_control.txt, probe_dump_census.txt, trace_sweep_law.txt,
  sweep_law_summary.txt, and tools/clsall.cpp (build with
  `g++ -O2 -std=c++17 clsall.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj`).
