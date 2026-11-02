# v11u467: adversarial verification of r11u467

Verdict: **CONFIRMED, no break, no production change.** The verified patch's src diff is
byte-identical to the implementer's `/tmp/r11u467.patch` (md5 9d80b133fb7721f039057745882a7c50).
Base 1dd2079d. Law under test: § unitCopyOwnTsEveryPath467 (src/ParamEmit.cpp, end of
drainPaNameCopySrc38; switch R11U467_UNITCOPYTS_OFF, pass switch R11U467_OFF).

## Binaries

- pristine: a copy of the main tree's build/slang-uhdm, md5 f679bd99637c44cb0c5098ebcfbf1f7e
  (no pristine build, per the measurement budget).
- law: rebuilt once in /tmp/wt_v11u467 from the patch, md5 c9b2f893019899967f666555de7bc9e8,
  equal to the implementer's law1; links slang 12.0.0+545f88b2e.
- No verified build: nothing changed.

## Decode check

- The pristine pair of sv-tests uvm_many_to_one (master's control database against the cached
  golden) reads 200 strict records, all `fullname`, all depth-3 ref_typespec under the
  design's param_assign copies, golden bare, ours `env_pkg::<name>`
  (evidence/many_to_one_strict_pristine.txt).
- Surelog's CompileHelper::importPackage "Regular parameter" loop clones every entry of
  getParamAssignVec() with clone_tree. Every design copy therefore owns a fresh reference
  with no stored name, as the law states.
- § unitImportCopyOwnTsRef214 (UhdmExporter, exportDesign) runs before drainPaNameCopySrc38
  (exportDesign calls it later). Its source map is an emplace over the package's Parameters
  only, so the per-path repeats were missed.

## Target row (from the verifier's own sweep)

**generated/uvm-examples/uvm_many_to_one.sv: STRICT_NOTEQUAL differ:fullname(200) -> EQUAL**

    generated/uvm-examples/uvm_many_to_one.sv,EQUAL,,equal

## Gates (one five-stage sweep on the law binary, workdir /tmp/v11u467sw1, trace on)

The four corpora ran from the worktree (rc 0). The sv-tests stage ran through the main
tree's tests/sweep.sh, because the worktree's UVM folder is empty. That stage exited 1 only
on the main tree's law-index check.

| stage | result |
|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63; 0/0/0; csv identical to the control |
| surelog | default 480 + 0, testflags 474 + 0; 0/0/0; csv equal to the control after path normalization |
| uhdm2rtlil | 803/1/67 both modes; 0/0/0; csv identical to the control |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2; not excused 0; csv identical to the control |
| svtests | EQUAL 1931, STRICT_NOTEQUAL 0, DIFFERENT 9, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions 0, conversions 1 (many_to_one), changes 0; the csv differs from the control on that row alone |

Other checks:

- **byteverify** against the control (SELFCHECK on; evidence/byteverify.txt):
  - surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805.
  - probe: 4087 of 4087 identical by path-normalized uhdm-dump (raw bytes carry the
    worktree's case paths). The negative control, two different cases, reads DIFF.
  - sv-tests: 30 kept databases (the control keeps 31; many_to_one is now EQUAL and not
    kept). 29 are STRICT_EQUAL under `--no-canon`, which is the serialization-order variance.
    The 30th is rsd, STRICT_NOTEQUAL fullname: the predicted mover, SURELOG_CRASH, with no
    golden (evidence/svtests_kept_nocanon.txt).
- **Trace**: the firings match the implementer's prediction exactly, rsd 1198193 and
  many_to_one 200, and no other process (evidence/sweep_trace_firings.txt).
- **Canaries** ok=52 and ok=16. Both ctcan2 checks PASS.
- **Binary audit** (fence-filtered): surelog 1523 of 1573 cmds.txt name the law binary, and
  the other 50 hold only a Surelog line. uhdm2rtlil 1740 of 1740. sv-tests 2346 of 2346. No
  cmds.txt names any other slang-uhdm binary.

## Implementer's grid reproduced

The implementer's grid (tools/probe/r11u467repro/cases/UC) reproduces on exit code,
uhdm-cmp count, strict verdict and md5 class:

- uc01, uc03 and uc04: STRICT_NOTEQUAL fullname -> STRICT_EQUAL.
- uc02 moves bytes and stays at 690 uhdm-cmp lines.
- uc05 and uc06 are byte-identical.

## Attack grid (cases/VU, 22 dirs, every first line `// § unitCopyOwnTsEveryPath467`)

Every case is accepted by upstream slang, with the real exit code read
(evidence/upstream_slang.txt). Every case exits 0 on both binaries, and Surelog exits 0 on
every case. Grids: evidence/grid_pristine.txt and grid_law.txt. Dump distances:
evidence/dump_distance.txt.

| case (law § unitCopyOwnTsEveryPath467) | shape | pristine -> law | dump distance |
|---|---|---|---|
| VU/vu04 | four packages, two $unit imports reaching a | STRICT_NOTEQUAL fullname -> **STRICT_EQUAL** | 384 -> 356 |
| VU/vu08 | chain e -> c -> b -> a, two $unit imports | STRICT_NOTEQUAL fullname -> **STRICT_EQUAL** | 317 -> 296 |
| VU/vu12 | $unit import placed between two modules | STRICT_NOTEQUAL fullname -> **STRICT_EQUAL** | 193 -> 186 |
| VU/vu20 | typedef'd parameter (impTsChain402 branch), $unit imports a and c | STRICT_NOTEQUAL fullname -> **STRICT_EQUAL** | 1651 -> 1630 |
| VU/vu22 | three-level diamond | STRICT_NOTEQUAL fullname -> **STRICT_EQUAL** | 327 -> 306 |
| VU/vu19 | struct-typed parameter | STRICT_NOTEQUAL fullname 6 -> 4 records | 1203 -> 1189 |
| VU/vu01 | localparam, logic [7:0], string, real | NOT_EQUAL 64, the same | 947 -> 919 |
| VU/vu02 | an explicit export with a module read | NOT_EQUAL 558, the same | 488 -> 481 |
| VU/vu03 | export chains | NOT_EQUAL 346, the same | 1142 -> 1135 |
| VU/vu05 | enum-typed parameter | NOT_EQUAL 736, the same | 2100 -> 2086 |
| VU/vu06 | c's own parameter shadowing a::PA | NOT_EQUAL 1116, the same | 264 -> 250 |
| VU/vu07 | explicit `import c::PA;` plus a wildcard | NOT_EQUAL 1342, the same | 1518 -> 1490 |
| VU/vu09 | override actual PA+3 | NOT_EQUAL 558, the same | 684 -> 677 |
| VU/vu10 | a parameter defined from another | NOT_EQUAL 50, the same | 808 -> 794 |
| VU/vu13 | unpacked-array parameter | NOT_EQUAL 184, the same | 860 -> 846 |
| VU/vu14 | a $unit class reading PA | NOT_EQUAL 558, the same | 651 -> 644 |
| VU/vu15 | an interface range [PA:0] | NOT_EQUAL 558, the same | 684 -> 677 |
| VU/vu16 | two $unit importers, each with an explicit export | NOT_EQUAL 966, the same | 1274 -> 1246 |
| VU/vu17 | untyped, hex and [7:0] parameters | NOT_EQUAL 64, the same | 644 -> 630 |
| VU/vu18 | a program reading PA | NOT_EQUAL 558, the same | 591 -> 584 |
| VU/vu21 | c's own localparam over PA | NOT_EQUAL 50, the same | 210 -> 203 |
| VU/vu11 | a single path, typedef'd (control) | NOT_EQUAL 282, byte-identical | 532 -> 532 |

Results:

- 5 dirs reach STRICT_EQUAL.
- 16 dirs move toward golden, with their uhdm-cmp counts unchanged at older faces.
- 1 dir is a byte-identical control.
- **No case moves away from golden.**
- Switch check (evidence/switchcheck.txt): R11U467_UNITCOPYTS_OFF=1 and R11U467_OFF=1 each
  give pristine's bytes on all 28 dirs (22 VU plus 6 UC), 56 of 56.
- Downstream (evidence/downstream.txt): vu02, vu04, vu10, vu16, vu20 and vu22 read IDENTICAL
  on both binaries. vu09 reads EQUIVALENT on both binaries; the law does not touch that face.

## Away census on earlier grids

704 earlier case dirs (r11u146, r11u214dec, r11u402, r11u451, r11u453, r11u454 and r11u465,
plus their v11u twins; fence-filtered) were run pristine against law
(evidence/bytecheck_earlier_cases.txt):

- 696 exit-0 dirs and 5 exit-4 dirs are byte-identical.
- 3 exit-3 dirs differ in bytes: v11u454 VL/vl14, vl15 and vl16. Each one also differs
  between two pristine runs.
- 0 exit-code movers.

## Goal 1 (reproduced)

- All 75 SURELOG_ONLY rows carry a slang `error:` diagnostic, and none carries the
  exporter's `unsupported`.
- The probe faces are in tools/probe/r11u423repro/evidence/residue_cases (g1a, g1b, g1c):
  - C::mk().arr[1] and u.mk(x).a[2] exit 4 on both binaries.
  - this.mk().inner.s exits 0.
  - Upstream slang exits 0 on all three, and Surelog exits 3 on all three (no golden shape).
- bp_unicore alone on the law binary with the guard on: rc 3, 13.6 s, max RSS 826 MB.
  The guard stays.

## Residues (all wrong on pristine too, none moved away)

1. vu19: 4 depth-4 ref_typespec records under a struct-typed parameter's members named `c`
   where golden leaves them empty. This is an older face, not decoded.
2. The export, string/real, enum and unpacked-array shapes at older uhdm-cmp faces (vu01 to
   vu03, vu05 to vu07, vu09, vu10, vu13 to vu18, vu21). vu11 and uc02 are the typedef-typed
   re-exported parameter family of pass 453 (TS/ts02).
3. vu09: downstream EQUIVALENT on both binaries (a $unit-imported override actual).
4. The implementer's residues stand.

## Sister-ground face

This repeats the implementer's report. UhdmExporter § unitImportCopyOwnTsRef214's source
map keeps only the first same-named package parameter. This pass repairs the leftover copies
from ParamEmit, and the law becomes a no-op if § 214 is widened.

## Process

- One law build and one five-stage sweep.
- One bp_unicore run alone.
- Case runs and downstream case runs.
- Every run was launched after a check showed no sweep or runner live. The sister r11u466's
  only process was a waiter, and it was not touched.
- The fence list was read into a file by a program and never printed. Every tree-wide list
  was filtered on it first.
