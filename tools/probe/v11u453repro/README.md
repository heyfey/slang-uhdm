# v11u453 — adversarial verification of r11u453

Base ccfaa169 (pass 450 on top of pass 451). Implementer's patch /tmp/r11u453.patch
(eight laws in src/ExprEmit.cpp, src/ParamEmit.cpp and src/EmitHelpers.h,
tests/LAWS.md, tools/probe/r11u453repro). VERDICT: CONFIRMED, no break, no
production change. The verified patch's src diff is byte-identical to the
implementer's; it adds this directory and the regenerated tests/LAWS.md.

## Binaries

- pristine: the main tree's build/slang-uhdm at the base (md5
  bcbbf4bebc1acb00e518ec826fbaabdf), frozen at /tmp/v11u453_bin/pristine. No
  pristine build of my own and no pristine sweep (measurement budget): the
  pristine sweep reading is the master's control /tmp/intr11u450.
- law: the implementer's patch applied to a fresh worktree at ccfaa169 and
  built once (cmake Release, SYSTEM_DEPS, -j 2): md5
  a6737bb721028e3e28cd355e393687f4, equal to the implementer's law14; links
  slang 12.0.0+545f88b2e. Frozen at /tmp/v11u453_bin/law.
- No verified build: nothing changed.

No-header audit of the added lines: no src/R*.h, no getenv, no reader
function; the eight switches read through lawOn(453, ...) from src/LawSwitch.h
(R11U453_VSCOLJOIN_OFF, R11U453_VSPARENSTART_OFF, R11U453_HPPSPARENEND_OFF,
R11U453_HPVSPARENBND_OFF, R11U453_XPARAMREEXP_OFF, R11U453_IMPPARAMFIRST_OFF,
R11U453_XVARREEXP_OFF, R11U453_MODCOPYIMPFIRST_OFF), eight lawTrace(453, ...)
sites.

## The implementer's grid reproduced

drivers/grid.sh (pristine, law) on the implementer's 57 movers, its 44
r11u453repro case dirs and its 19 evidence dirs (sister/HS, IQ, IR and
residue/TS): every line reproduced on exit code, uhdm-cmp line count, strict
verdict and moved/same (evidence/impl_grid_repro.txt, impl_grid_ev.txt; the
md5 column differs only because the source paths are inside the database).
Dump distance on the r11u84 and r11u79 movers: t2_expkinds 2208 -> 1854,
t3_shapes 2134 -> 1741, t4_expviews 2213 -> 2036, t6_slots 1611 -> 1139,
z7_pkgimpclone 725 -> 646 (the implementer's numbers plus 2 header lines),
t5_expfences 654 -> 685 (its golden is a Surelog error run, three CP0317
Undefined type errors, confirmed in the golden's log).

## The sweep (one full five-stage sweep on the law binary)

drivers/fullsweep.sh: tests/sweep.sh --jobs 3 --workdir /tmp/v11u453swp
--corpus "probe surelog uhdm2rtlil downstream" from the worktree, then the
sv-tests stage through the main tree's scripts/check_svtests.py on the same
binary (the worktree's UVM submodule is empty), R11U453_TRACE on. Launched
after the sister r11u452's sweep ended and three quiet readings.

- probe: EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, regressions=0
  conversions=0 changes=0; the csv identical to the control; the 4087
  databases identical to the control by path-normalized dump (0 movers;
  comparator positive control: two different cases flagged).
- surelog: default CMP_EQUAL 480, testflags 474, 0/0/0; the csv differs from
  the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; the csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of
  871; the csv identical to the control.
- sv-tests: EQUAL 1920, DIFFERENT 20, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions=0
  conversions=0 changes=0; status identical to the control on all 2346 rows.
  No sv-tests row converts, as the implementer reported.
- byteverify (tools/probe/r11v75repro/byteverify.sh, law workdir against
  /tmp/intr11u450): 0 movers in the surelog, uhdm2rtlil and downstream
  databases; the 41 sv-tests databases the runner keeps all differ by bytes
  because the work-directory path is written into the (packed) database: 18
  of them are identical to the control by path-normalized dump
  (evidence/svtests_dump.txt; the tnoc line there is a dump stopped by hand),
  and the 22 large ones (tnoc, easyUVM, the 16 uvm-examples rows and the 3
  scoreboard rows; uhdm-dump runs over 40 minutes on each) read 0 uhdm-cmp
  lines against the control (evidence/svtests_cmp_big.txt; positive control:
  two different uvm-examples databases give 9833530 lines); generated/rsd/rsd
  (SURELOG_CRASH, its status cannot move) was not compared.
- canaries: canaries.sh ok=52 (surelog) and ok=16 (uhdm2rtlil); ctcan2
  EXPECT_UNKNOWN=1 ok=58 PASS, EXPECT_UNKNOWN=6 ok=2 PASS.
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name
  /tmp/v11u453_bin/law, the other 50 hold only a Surelog line; uhdm2rtlil
  1742 of 1742; sv-tests 2346 of 2346.
- the corpus stages exited 1 on the stale law index alone (this directory's
  cases are the index's input; regenerated last in the patch).
- trace census: exactly one firing process in all five stages, the probe
  case r10uvm92repro/v92_b2_varsel (§ vsTrailRangeColonJoin453, two names
  `vsp::probe::probes::uv::uv`), whose database is path-normalized identical
  to the control. The implementer's census is reproduced.

## Attack grid (85 fresh case dirs, cases/, every first line names its law)

Every case accepted by upstream slang (~/.local/bin/slang --single-unit), every
exit code 0 on pristine and law. drivers/run1.sh (golden from Surelog -parse
-nobuiltin -nocache -sv, cached per case text). Pristine -> law: 60 to
STRICT_EQUAL, 15 moving with the same verdict, 10 byte-identical, NONE
FURTHER (evidence/attack_table.txt).

- VC (§ vsTrailRangeColonJoin453, 12): a static method of a $unit class
  vc01, a package class method vc03, a package function read in a module
  continuous assignment vc04, a package task over a package variable vc06, a
  three-index select vc07, a parameterized package class vc09, an out-of-body
  package method vc10: STRICT_NOTEQUAL fullname -> STRICT_EQUAL; controls a
  $unit function vc02, a generate-block function vc05, an interface function
  vc08 byte-identical; a package parameter as base and width vc11 and an
  unpacked local behind an explicit function import vc12 closer (dump 64 ->
  52, 62 -> 50) at other faces.
- VR (§ vsTrailRangeParenStart453, 12): double parentheses vr01, -: vr03, a
  macro bound vr04, spaced parentheses vr05, a generate loop vr06, an
  unpacked-array prefix vr07, a macro wrapping the whole select vr08, a cast
  operand vr09, a concatenation vr10, a parenthesized width vr12: col / endcol
  -> STRICT_EQUAL; a port connection vr11 STRICT_NOTEQUAL col -> fullname with
  2 differing objects -> 1 (its remaining face is the port-connection full
  name work@top.u.i.q.q, not this law's); control vr02 (parentheses on the
  index, not the range) byte-identical.
- VH (§ hpPartSelParenRightEnd453, 10): both bounds parenthesized vh01,
  double parentheses vh02, an interface path vh03, a macro bound vh04, an
  array-of-struct prefix vh05, an operation bound vh07, a procedural left side
  vh08, a nested member vh10: endcol -> STRICT_EQUAL; controls vh06 (left
  bound only) and vh09 (`(0)+0`, the parentheses not at the end) byte-identical.
- VB (§ hpVsParenBoundPretty453, with § vsTrailRangeParenStart453 at the
  dotted site, 14): vb01, vb02 (`**`), vb04 (a unary minus), vb05,
  vb06 (indexed), vb10 (shift and divide), vb11 (conditional), vb12 (-:),
  vb14 (`**` on both bounds): uhdm-cmp NOT_EQUAL -> STRICT_EQUAL; same
  verdict, same dump distance, both binaries wrong: vb03 (`$clog2` bounds:
  golden names `[$clog2(W) + 1:]`, Surelog rendering the second call empty,
  pass 421's residue), vb09 (a package-qualified parameter golden folds to 4,
  `[4 - 1:4 - 2]`), vb13 (a macro bound, the raw text keeping the backtick so
  the law abstains on the name) and vb08 (a procedural left side where golden
  writes a ref_obj under the hier_path; only the part select's end column
  moves); control vb07 (an interface path, not this site) byte-identical.
- VX (§ pkgExplicitImpParamReExport453, 13): a module importer vx01, a
  logic-typed parameter through a chain vx02, an explicit localparam import
  beside a wildcard vx03, an interface importer vx04, two explicit imports
  under a diamond vx05, a diamond of two re-exporting packages vx08, a
  wildcard plus explicit import of one parameter vx12, two instances vx13:
  NOT_EQUAL -> STRICT_EQUAL; closer at other faces: vx06 (171 -> 69, a
  package parameter defined by the imported one, golden folding the module
  read), vx07 (176 -> 64, an imported function), vx09 (uhdm-cmp 402 -> 91,
  dump 148 -> 36, the module's own explicit import beside the re-export),
  vx11 (354 -> 242, an export statement); control vx10 (explicit enum value
  and typedef imports) byte-identical.
- VO (§ pkgImpParamsAheadOfOwn453, 7): vo01 to vo05 NOT_EQUAL ->
  STRICT_EQUAL (two parameters around a wildcard, an explicit import after a
  parameter, two imports in a chain, an interface importer, a module importing
  both); vo06 (187 -> 83, a parameter computed from the import) and vo07 (468
  -> 234, a typedef-typed parameter, the r11u453 TS residue face) closer.
- VV (§ pkgExplicitImpVarReExport453, 9): a module importer vv01, a net
  vv02, wildcard plus explicit imports and an unpacked array vv03, a chain
  vv04, beside an imported class vv05, an initialized and a const variable
  with the module's own explicit import vv07, a module with ports vv09:
  NOT_EQUAL -> STRICT_EQUAL; vv06 (a program importer, 51 -> 36) and vv08 (a
  struct and an unpacked logic array, 242 -> 149) closer at other faces.
- VM (§ modCopyImportsFirst453, 8): vm01, vm02 (an interface and a net),
  vm03 (with § pkgExplicitImpVarReExport453), vm05 (a chain), vm07 (a module
  importing the inner package too), vm08 (instances in a generate loop):
  NOT_EQUAL -> STRICT_EQUAL; controls vm04 (an out-of-body constructor local,
  where the law abstains by design) and vm06 (only a parameter in the
  imported package: the law fires and the bytes stay) byte-identical.

Switches (evidence/switch_attack.txt): R11U453_OFF gives pristine's bytes on
all 85; on the single-law movers the firing law's own switch alone restores
pristine; the two-law movers (vb01, vb03 to vb06 with VSPARENSTART +
HPVSPARENBND, vm03 with MODCOPYIMPFIRST + XVARREEXP, vo02 with XPARAMREEXP +
IMPPARAMFIRST) and vb08 (HPPSPARENEND, the law its trace names) are restored
by the switches of the laws their trace names. Trace on and off give the same
bytes on all 54 of the first batch.

Downstream (ds.one, both lanes; evidence/ds_attack.txt) on 22 class-free
cases: pristine 13 IDENTICAL + 9 EQUIVALENT, law 22 IDENTICAL (vr01, vr03,
vr10, vm01, vm08, vv01, vv09, vx01, vx13 EQUIVALENT -> IDENTICAL); none away.

## Goal 1

Reproduced: nothing new on this ground; no exit-code mover anywhere (every
grid and attack case exit 0 on both binaries, the five sweep stages' statuses
unchanged).

## Residues (ranked; all wrong on pristine too, none moved away)

1. The implementer's residues stand as written in r11u453repro/README.md
   (the module variable initializer binding of IR, the typedef-typed
   re-exported parameter TS/ts02, XP/xp05 and VO/vo07, r11u84 t3 and t6 at a
   typedef-typed wire net).
2. A dotted var_select's bounds golden renders through prettyPrint where
   § hpVsParenBoundPretty453 renders differently: a system call in a bound
   (VB/vb03, golden writing the second `$clog2` empty), a package-qualified
   parameter golden folds to its value (vb09), a macro bound left as raw text
   (vb13).
3. A procedural left side through a dotted path's var_select (VB/vb08), where
   golden writes a ref_obj under the hier_path.
4. An interface path's trailing range `u.pg[1][(3):2]` written as one
   part_select where golden writes a var_select (VB/vb07).
5. The port-connection part select's full name work@top.u.i.q.q (VR/vr11).
6. Explicit-import shapes at other faces: a package parameter read in a
   module through a re-export (VX/vx06), an imported function beside a
   parameter (vx07), the module's own explicit import (vx09), an export
   statement (vx11), a program importer (VV/vv06), struct and unpacked-array
   variables (vv08), a hoisted out-of-body constructor local (VM/vm04, the
   law abstains), a package parameter computed from an import (VO/vo06).

## Process

Within the budget: one law build (md5 equal to the implementer's), no
verified build, one full five-stage sweep on the law binary after the
sister's sweep ended and three quiet readings, never overlapping another
sweep; byteverify once. The attack batches and the reproduced grid ran one
process at a time; the first attack batch and part of the grid reproduction
ran while the sister r11u452's sweep was live (timing only, no measurement
affected; the sweep itself waited). The fence list was read into a file by a
program without printing it, and every tree-wide list (the cmds.txt audit)
filtered on it before opening a file; no fenced test named, opened or run; no
other agent's process touched.
