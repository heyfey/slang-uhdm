# v11u429 — adversarial verification of r11u429

Base 54e2aae2d. Implementer's patch /tmp/r11u429.patch (md5 e20cc2a4540a3c7fe2dc1db4c770947f),
applied clean on a fresh worktree at the base (only whitespace warnings in one evidence file).

VERDICT: CONFIRMED, NO PRODUCTION REFINEMENT. On 52 fresh case dirs, no legal SV case
was right on pristine and wrong with the patch, so the verified patch carries the
implementer's src/ExprEmit.cpp byte for byte.

## Binaries (frozen before any measurement)

- Pristine: the main tree's build/slang-uhdm, md5 7367e445066cacd63a0fb9e00c939e15, copied
  to /tmp/v11u429_pris/slang-uhdm. No pristine build and no pristine sweep, per the
  measurement budget. The pristine sweep reading is the master's control /tmp/intr11u427.
- Law: rebuilt once in /tmp/wt_v11u429 (-j 2), md5 a68b561e10c30ef8b8f1e9ad8bc58506,
  equal to the implementer's law5. Frozen as /tmp/v11u429_law/slang-uhdm. It reports
  slang 12.0.0+545f88b2e.
- uhdm-strictcmp: the main tree's build, md5 fa6e4f42f252ae0ab69d9845003e71c5, frozen
  at /tmp/v11u429_bin.

## The laws under test (both in src/ExprEmit.cpp, through lawOn(429, ...))

- § unitClsCastPkgEnumTdTopListing429 (`R11U429_UNITCLSCAST_OFF`)
- § genBodyBitsOuterNameKeeps429 (`R11U429_GENBITSNAME_OFF`)

`R11U429_OFF` drops both. The audit finds no src/R*.h, no getenv and no reader
function in the added lines.

## Headline numbers reproduced

One five-stage sweep on the law binary, workdir /tmp/v11u429sw1; drivers/fullsweep.sh is
the implementer's driver with the worktree path changed. Evidence: evidence/fullsweep.log.

| stage | reading | vs baseline |
|---|---|---|
| probe | EQUAL 4018, STRICT_NOTEQUAL 69 of 4087 | 0/0/0; csv identical to the control |
| surelog | default 480, testflags 474 CMP_EQUAL | 0/0/0; csv differs from the control only in the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 both modes | 0/0/0; csv identical to the control |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | csv identical to the control |
| sv-tests | EQUAL 1892, STRICT_NOTEQUAL 6, DIFFERENT 42, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | regressions 0, conversions 0, changes 4 |

The corpus stages exited 1 only because the law index was stale: this repro dir was
added before the sweep and the index was regenerated afterwards.

The four sv-tests changes are the implementer's rows, all from
§ unitClsCastPkgEnumTdTopListing429. The sv-tests csv is identical to the
implementer's on all 2346 rows (evidence/svtests_vs_control.diff).

- testbenches/uvm_agent_active.sv,STRICT_NOTEQUAL,differ:file(2),differ:file(2) (was differ:type(1))
- testbenches/uvm_agent_passive.sv,STRICT_NOTEQUAL,differ:file(2),differ:file(2) (was differ:type(1))
- testbenches/uvm_driver_sequencer_env.sv,STRICT_NOTEQUAL,differ:file(2),differ:file(2) (was differ:type(1))
- testbenches/uvm_monitor_env.sv,STRICT_NOTEQUAL,differ:file(2),differ:file(2) (was differ:type(1))

Strict heads on uvm_agent_active, from a targeted runner call on both binaries
(evidence/uvm_agent_active_strict_heads.txt):

- Pristine: `#205756 type` (golden `constant INT:27`, ours `operation`), objects 444579 vs 444600.
- Law: `#206401 file` (int_typespec uvm_resource_defines.svh in golden, uvm_resource_specializations.svh in ours),
  then `#219489 depth`, objects 444579 vs 444576.

Trace census of the sweep (evidence/trace_census_sweep.txt): 8 sv-tests databases fire,
all on § unitClsCastPkgEnumTdTopListing429. easyUVM/top fires 18 times and the 7
testbenches uvm_* rows fire 6 times each. No corpus row and no probe case fires.

Firing rows (evidence/firing_rows_uhdmcmp.txt): the uhdm-cmp line counts are equal on
both binaries. easyUVM reads 659635. The three scoreboard rows read 2200983, 2231211
and 2216265. The four agent rows read 0.

Byte census:
- byteverify (SELFCHECK=1, law against the master's control, workdir names of equal
  length) finds 0 movers in all three corpora: surelog 0 of 962 (selfcheck 961), uhdm2rtlil
  0 of 1608 (selfcheck 1607), downstream 0 of 805 (selfcheck 804).
- Probe: 4087 of 4087 identical by path-normalized uhdm-dump. The positive control,
  VB/vb01 pristine against law, differs (evidence/probe_dump_compare.txt).

Canaries: ok=52 and ok=16, with changed 0. Both ctcan2 checks PASS.

Binary audit: a fence-filtered walk of the surelog and uhdm2rtlil command records finds
3263 of 3313 naming /tmp/v11u429_law/slang-uhdm. The other 50 hold only a Surelog line,
2 of them because they name the repository path.

The implementer's grid (39 case dirs) is reproduced line for line after the md5 column
is stripped (evidence/grid_r11u429_reproduced.txt). The md5s differ only because the
output path is embedded in the database.

Earlier-pass census (evidence/earlier_pass_census.txt): 4160 fence-filtered case dirs of
r11u401 to r11u430 and v11u401 to v11u430, excluding this pass, were run on both binaries.
All 4160 have the same exit code and the same database bytes. The positive controls
VB/vb01 and VC/vc01 move.

## Attack grid (52 fresh case dirs; drivers/grid.sh, run1.sh, cdist.sh, ds.sh)

Every case's first line names its law, and upstream slang accepts every case. vb06 was
removed (slang reports a use before declaration). The vc07 and vc09 texts were changed
once (Surelog syntax error, Surelog segfault) before any law reading. Every exit code is
0 on both binaries. `R11U429_OFF` and the case's own switch give pristine's bytes on all
52 (evidence/grid_attack.txt).

VB, § genBodyBitsOuterNameKeeps429 (33 cases): a for-loop bound, a shift amount, a
struct, an unpacked array, an outer gen-block name read from a nested block, a gen case,
a wire, a typedef, always_ff in a gen-for over a port, int, byte and enum, a function in
a gen block, a parameterized child instantiated twice, a case item, a process-local
initializer, initial $display, an interface, a genvar-dependent width, an arithmetic
expression, a part-select bound, a continuous assignment (control), a hierarchical
top.x, a package variable, a $unit variable, a loop variable, always_latch, non-ANSI
reg/wire, a block-local name shadowing a module name, a select beside a name, a type
argument, $size beside a block-local wire, and $signed.

- NOT_EQUAL -> STRICT_EQUAL (23): vb01, vb02, vb03, vb04, vb07, vb08, vb09, vb10, vb11,
  vb14, vb15, vb16, vb17, vb19, vb20, vb24, vb26, vb27, vb28, vb30, vb31, vb33, vb34.
- NOT_EQUAL on both and toward golden by dump distance: vb05 (30 -> 15), vb23 (36 -> 6,
  uhdm-cmp 38 -> 33), vb32 (38 -> 12).
- Unchanged, byte-identical: vb12 (a function declared in a gen block, residue), vb29 (a
  parameterized child's gen-for, residue), vb21 (a continuous assignment, the
  implementer's residue 1), and vb13, vb18, vb22, vb25 (STRICT_EQUAL controls).
- Downstream on all 33 (evidence/downstream_VB.txt):
  - vb02, vb14 and vb34 go EQUIVALENT -> IDENTICAL.
  - vb23 and vb24 go DIVERGENT -> IDENTICAL.
  - vb12 and vb29 stay EQUIVALENT, and vb32 stays DIVERGENT, on both binaries.
  - Every other case is IDENTICAL on both. None is worse.

VC, § unitClsCastPkgEnumTdTopListing429 (19 cases): an explicit `import p::e_t`, a
class extending a package class, a cast in a local initializer, a cast in a property
initializer (no subroutine), a static method called from a module, a $unit function, an
enum base typedef from another package, fork, a package-call argument and a condition,
two classes, an enum with a literal range, a qualified p::e_t, a virtual and derived
class, a class written before the package, a re-typedef of another package's enum, a
module cast beside the class (stale-subroutine check: the trace fires in f only), a
property after a method, a $unit function beside the class, and a cast in another
package's function.

- STRICT_NOTEQUAL type -> STRICT_EQUAL (9): vc01, vc02, vc05, vc08, vc10, vc12, vc13,
  vc14, vc16.
- vc18 goes STRICT_NOTEQUAL type -> STRICT_NOTEQUAL endcol. Its head moved to the $unit
  function's end column, the same head that vc06 shows on both binaries.
- STRICT_EQUAL on both: vc11. The bytes move but no strict field changes: an enum with a
  literal range, where the two listings agree.
- NOT_EQUAL on both with the uhdm-cmp count and dump distance unchanged: vc03, vc04,
  vc07, vc09, vc15, vc17, vc19. The law fires on vc07, vc09, vc17 and vc19 (trace), but
  their heads are elsewhere. The identity move is invisible to an id-blind dump.
- vc03, vc04 and vc15 are byte-identical, and so is vc06 (STRICT_NOTEQUAL endcol on both).

No case on legal SV moves away from golden. No refinement was written.

## Goal 1

Nothing on this ground. No SURELOG_ONLY, BOTH_REJECT or SLANG_CRASH row of
results/golden_svtests.csv carries an exporter message. The 6 rows matching "export" are
slang front-end diagnostics: "expected a declaration name", and "design element does not
have a time scale defined" in uvm_pkg.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The implementer's continuous-assignment face of the gen-scope `$bits` (its gb01 to
   gb08 and gb12 to gb14; here vb21).
2. A `$bits` inside a function declared in a generate block (VB/vb12, downstream
   EQUIVALENT on both).
3. A parameterized child's gen-for `$bits` under two instances (VB/vb29, EQUIVALENT on
   both).
4. A `$bits` of a type argument beside a name (VB/vb32, DIVERGENT on both binaries:
   downstream-visible, the largest new face).
5. A package variable p::v (VB/vb23, closer) and an outer gen-block name read from a
   nested block (VB/vb05, closer).
6. The class-cast heads not reached: a re-typedef of another package's enum (VC/vc15),
   a property initializer (vc04, vc17), a $unit function's end column (vc06, vc18), and
   the implementer's rc05, rc06, rc08, rc09 and rc13.
7. The carried backlog of passes 427 and earlier.

## Sister-ground faces

The implementer's list is confirmed on the 4 testbenches rows:
- The int_typespec file of the uvm_resource#(int) specialization (UhdmExporter
  emitClassPropSpecParams163 -> makeTypespec / setLoc).
- The uvm_bitstream_t property clone's range (TypeEmit tdVecNamedClone42).

## Process

- One law build. No pristine build, no intermediate build, no verified build.
- One full five-stage sweep. It was launched through the implementer's quiet loop, which
  read three quiet states first.
- One targeted runner call per binary on the 8 firing sv-tests rows, on a quiet machine
  after the sweep.
- The attack grid and the downstream case runs ran before the sweep's quiet loop
  released. The earlier-pass census ran after the sweep, at -P 3, with no sweep live.
- The fence list was read into a file by a program without printing it. Every tree-wide
  list was filtered on it before any file was opened. No fenced test was named, opened or
  run. No other agent's process was touched.
