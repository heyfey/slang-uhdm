# v11u465: adversarial verification of r11u465

Pass 465, the expression/parameter ground (src/ParamEmit.cpp only). Base dbf4f952. The implementer's two
laws are § cloneLvSharesHomeUnitTs465 (`R11U465_CLONELVUNITTS_OFF`) and § pkgTransImpAggTd465
(`R11U465_TRANSAGGTD_OFF`). This pass reproduces every headline number, attacks both laws with 50 fresh
case dirs, and fixes one break in § pkgTransImpAggTd465 behind its own switch.

**Verdict: one break, fixed.** § pkgTransImpAggTd465 walked import edges to packages declared LATER in
source order. Surelog compiles packages in strict source order, so those edges copy nothing. On 4 fresh
legal cases the pristine listing was golden's and the law added names golden lacks. The refinement
§ pkgTransImpEarlierOnly465v (`R11V465_TRANSORDER_OFF`) puts those cases back on pristine's bytes. It fires
on no corpus row, probe case or sv-tests row. Law 1 holds on every attack case.

## Binaries (frozen, read-only)

| binary | md5 | what it is |
|---|---|---|
| /tmp/v11u465_bin/pristine | d59c9ff65c1b72790be68a21e7794397 | copy of the main tree's build/slang-uhdm (no pristine build, per the budget) |
| /tmp/v11u465_bin/law | 0d6857acbfa6cefc70fddf3c8a30045c | rebuilt from /tmp/r11u465.patch; equal to the implementer's law5 |
| /tmp/v11u465_bin/verified | 8e409ad68c5c44922ad20c6b616e464e | law + § pkgTransImpEarlierOnly465v |

All three link slang 12.0.0+545f88b2e. The patch applies cleanly on a fresh dbf4f952, and its tests/LAWS.md
was current there.

## Reproduction of the implementer's numbers (law binary, one five-stage sweep, /tmp/v11u465sw1)

| stage | result | control /tmp/intr11u462 |
|---|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63, regressions=0 conversions=0 changes=0 | csv identical; all 4087 databases identical by path-normalized uhdm-dump (evidence/probe_pdump_law.txt) |
| surelog | default CMP_EQUAL 480, testflags 474, 0/0/0 | csv differs only in the two LowMem log-path texts |
| uhdm2rtlil | 803 / 803 CMP_EQUAL, 0/0/0 | csv identical |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 | csv identical |
| sv-tests | EQUAL 1930, STRICT_NOTEQUAL 0, DIFFERENT 10, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions=0 conversions=0 changes=0 | csv byte-identical |

- byteverify (SELFCHECK=1) against the control: surelog 0 / 962, uhdm2rtlil 0 / 1608, downstream 0 / 805.
- sv-tests kept databases: 31 raw-byte movers. 27 are STRICT_EQUAL to the control under
  `uhdm-strictcmp --no-canon` (serialization-order variance). The other 4 are the law movers rsd,
  uvm_many_to_one, uvm_param_vif_config_db and uvm_use_models_pipelined_get_put
  (evidence/svtests_movers_law.txt).
- The sweep's trace fires on exactly those 4 databases, with the implementer's counts: rsd 524
  (§ pkgTransImpAggTd465), many_to_one 180 (§ cloneLvSharesHomeUnitTs465), param_vif_config_db 74
  (§ pkgTransImpAggTd465), pipelined_get_put 180 + 6.
- Canaries: ok=52 and ok=16. ctcan2 surelog (EXPECT_UNKNOWN=1) PASS ok=58; ctcan2 uhdm2rtlil
  (EXPECT_UNKNOWN=6) PASS ok=2.
- Binary audit, fence-filtered: surelog 1523 of 1573 records name the law binary, and the other 50 hold only a
  Surelog line. uhdm2rtlil names it in 1740 of 1740.
- The corpus command (from the worktree) exits 0. The sv-tests stage ran through the main tree's
  tests/sweep.sh, because the worktree's UVM folder is empty. It exits 1 on the main tree's law-index check
  alone.

Targeted rows (law sweep databases against the control's; pass 446's localizer clsloc ALL top):

| row | status | clsloc pristine -> law | uhdm-cmp lines | note |
|---|---|---|---|---|
| uvm_use_models_pipelined_get_put | DIFFERENT -> DIFFERENT | 500 -> 0 | 1385354 -> 1382776 | mbus_pipelined_env_pkg's listing 130 -> 133 = golden in both views; head moves from package(mbus_pipelined_env_pkg) to interface_inst (sister's ground) |
| uvm_many_to_one | DIFFERENT -> DIFFERENT | 1250 -> 0 | 1428344 -> 1428344 | head unchanged (ModuleEmit's $unit-route listing, sister's) |
| uvm_param_vif_config_db | DIFFERENT -> DIFFERENT | 1574 -> 1574 | 230 -> 230 | tb_params_pkg listing name overlap with golden 57 -> 94 (golden 134), 0 names golden lacks |
| generated/rsd/rsd | SURELOG_CRASH | n/a | n/a | law mover only |

The implementer's 18 grid dirs reproduce on exit code, uhdm-cmp count and strict verdict, with the same 12
movers. Pass 462's r11u462 EB/eb01 reads 160 -> STRICT_EQUAL, and v11u462 VS/vs08 (76) and vs09 (50) are
byte-identical.

## The break and the refinement

**§ pkgTransImpEarlierOnly465v** (`R11V465_TRANSORDER_OFF`, src/ParamEmit.cpp inside
§ pkgTransImpAggTd465's walk, read through fixOn).

- **Decode.** Surelog compiles packages in strict source order (CompileDesign, the same order pass 454's
  § pkgLateTsEarlierPkgOnly454v uses). CompileHelper::importPackage copies the imported package's datatype
  map as it stands at that moment, so a package declared LATER contributes nothing.
- **Rule.** The transitive walk follows an import edge only when the imported package is declared earlier
  than the importer. The first edge (this package -> the directly imported package) is checked too. The
  order is the syntax trees' compilation-unit member order.
- **Break cases** (all accepted by upstream slang, every exit code 0; the package-typedef listing of A in the
  three databases):

| case | shape | golden A | pristine A | law A | verified |
|---|---|---|---|---|---|
| VT/vt23 | B (imports C) declared before C | import B | import B | C::e_t C::s_t import B | pristine bytes |
| VT/vt24 | A, B, C fully reversed | import B | import B | one view lists C::e_t, C::s_t | pristine bytes |
| VT/vt25 | A imports B declared after A; an earlier D made C's clones | import B | import B | C::e_t C::s_t import B | pristine bytes |
| VT/vt26 | B imports C declared after B; an earlier D made C's clone | import B | import B | C::e_t import B | pristine bytes |

The uhdm-cmp counts do not move on these four, because each first difference is an earlier pre-existing face:
our B lists C's clones where golden's B lists only the import, which is the direct-import branch and predates
the pass. The break shows in the listing cells.

**Switch checks** (68 case dirs: my 50, the implementer's 18):

- `R11U465_OFF` on the verified binary gives pristine's bytes on 68 of 68.
- `R11V465_OFF` gives the law binary's bytes on 68 of 68.
- On the law binary, `R11U465_CLONELVUNITTS_OFF` restores pristine on every LV/VL mover, and
  `R11U465_TRANSAGGTD_OFF` restores it on every TL/VT mover. No dir needs both switches.

## Attack grid (tools/probe/v11u465repro/cases, 50 dirs; evidence/grid_summary.txt, grid_*.txt)

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit, exit 0). Every exit code is 0 on
all three binaries. Columns in the evidence: uhdm-cmp lines and strict verdict, path-normalized dump
distance, package-typedef listing lines that differ from golden (drivers/pkgtd.py), and loop-variable census
lines that differ from golden (evidence/lvall.cpp, drivers/lvcmp.sh).

**VL, § cloneLvSharesHomeUnitTs465 (24 dirs).** 19 move and 5 are byte-identical controls (vl08 in-body
method, vl12 module-local class, vl13 dynamic-array formal, vl14 string-queue formal, vl16 method-local
array).

- **14 reach STRICT_EQUAL:** vl01 (2-D), vl02 (assoc by string), vl03 (two methods), vl04 (package
  function), vl07 (import after the module), vl09 (parameterized class), vl15, vl17 (under if/begin), vl18
  (base-class property), vl19 (static), vl20 (nested foreach), vl21, vl22 (assoc by byte), vl24 (package
  assoc of handles).
- **vl05, vl06, vl11:** the loop-variable census reaches golden's (lvcmp 4/4/5 -> 0/0/1, the 1 being a
  pre-existing module listing entry). Their uhdm-cmp head moves LATER, to module_inst work@top's
  $unit-route typedef or task listing (the sister's ModuleEmit face), so the line count grows (18 -> 223,
  54 -> 317, 18 -> 414).
- **vl10 (chain b -> a -> h under $unit), 29 -> 24:** the shared object's typespec is now golden's
  class_typespec W. It still sits under package a where golden parents it under h, which is the lv08
  re-import residue.
- **vl23 (package int queue):** census 3 -> 0, with the head at another face.

**VT, § pkgTransImpAggTd465 (26 dirs).** On the verified binary 18 move and 8 are byte-identical: the
controls vt07 (import inside a function body), vt09 (packed union and vector only), vt10 (explicit import at
A) and vt14 (listing already golden's), plus the four break cases vt23 to vt26 now back on pristine.

- **4 reach STRICT_EQUAL:** vt06 (enum alias plus struct), vt13 (scoped C::e_t in A's struct), vt15 (C's
  enum through a class in B), vt18 (struct of struct).
- **Every other mover's package listings now equal golden's:**
  - vt02, vt03 (C and D both declare e_t), vt04 (diamond), vt05 (four hops), vt08 (export C::*), vt11,
    vt16, vt17, vt19, vt20, vt21, vt22.
  - vt01 and vt12 move toward golden but are not equal. vt01 has B's own same-name enum, a pre-existing
    naming face. vt12 has an explicit import in the middle package, the tl04 residue.
- **No dump distance grows** except lv08's 40 -> 42, which the implementer documented: the replaced
  placeholder stays in the database unreferenced.
- **vt17 (322 -> 426):** the extra lines come from the shared C::e_t clone's vpiInstance moving from B to
  A, which is golden's last writer. The occurrence census confirms it moves toward golden.
- **vt03 and vt19:** their head moves later, to module_inst.

**Downstream** (ds.one on the three binaries): VT/vt20 (logic over A's struct of C's enum), vt04, VL/vl01 and
vl23 read IDENTICAL on pristine and law.

## Verified sweep (/tmp/v11u465sw2)

The prediction was written before the sweep (evidence/prediction_verified.txt). The refinement only removes
edges from § pkgTransImpAggTd465's walk, and that law fired only on rsd, param_vif_config_db and
pipelined_get_put. A traced runner call of the verified binary on those three rows fires the law with the
same counts and the refinement 0 times. The prediction: no mover.

| stage | verified result | against the law sweep |
|---|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0 | csv identical; 4087 of 4087 databases byte-identical |
| surelog | 480 / 474 CMP_EQUAL, 0/0/0 | csv identical except the LowMem log-path texts; byteverify 0 / 962 |
| uhdm2rtlil | 803 / 803, 0/0/0 | csv identical; byteverify 0 / 1608 |
| downstream | 803 / 66 / 2 / 0 | csv identical; byteverify 0 / 805 |
| sv-tests | EQUAL 1930, STRICT_NOTEQUAL 0, DIFFERENT 10, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; 0/0/0 | csv byte-identical to the control; 31 raw-byte movers, all STRICT_EQUAL under --no-canon (variance) |

- The trace is identical to the law sweep's (evidence/trace_summary.txt).
- Canaries: ok=52 and ok=16; both ctcan2 checks PASS.
- Binary audit: surelog 1523 of 1573, uhdm2rtlil 1740 of 1740 and sv-tests 2346 of 2346 records name the
  verified binary.
- Both commands exit 0.

**Byte check on earlier grids** (evidence/bytecheck_pass460_463_cases.txt): 312 case dirs of r/v11u460 to
r/v11u463, pristine against verified. 310 are byte-identical with equal exit codes. 2 move toward golden:
r11u462 EB/eb01 (160 -> STRICT_EQUAL, the implementer's) and v11u462 VB/vb06 (NOT_EQUAL 192 ->
STRICT_EQUAL; package c's listing gains a::e_t through b, as golden has it).

## Goal 1

Nothing new on this ground. VL/vl22 was first written with `int m[*]`. Upstream slang rejects that ("foreach
loops cannot be used with associative arrays that have a wildcard index"), and so does our exporter, so it is
not a goal-1 face. It was rewritten in place as `int m[byte]`. The black-parrot size guard was not touched.

## Residues (all wrong on pristine too, none moved away on the verified binary)

1. **Re-import chains** (lv08, VL/vl10): golden parents the shared clone loop variable under the home
   package's foreach and binds the outer importer's clone reads through it. Ours parents it under the
   first importer.
2. **The direct-import branch of a package listing ignores source order** (VT/vt23, vt25, vt26: our B lists
   C's clones where golden's B, declared before C, lists only the import). This predates the pass. The
   vector/scalar collectOther walk has the same blind spot.
3. **A middle package's own same-name typedef** (vt01): golden's datatype map keeps the FIRST inserted entry,
   the imported C::e_t. Our A names B's own enum B::e_t.
4. **Explicit import in the middle package** (tl04, vt12).
5. **The replaced placeholder typespec of § cloneLvSharesHomeUnitTs465** stays in the database unreferenced
   (byte hygiene, dump tail only).
6. The implementer's ranked residues 3 to 6 (param_vif_config_db's 40 class-specialization typedefs; lv02;
   vs08 and vs09; the carried lists).

## Sister-ground faces (reported, not written)

- **module_inst work@top's $unit-route typedef and task listings** (ModuleEmit): the next head on VL/vl05,
  vl06 and vl11, the same face as many_to_one's head.
- **The interface definition listing work@mbus_pipelined_driver_bfm** (4 entries vs golden's 131, ModuleEmit
  interface typedef listing): pipelined_get_put's head now.
- **The design-level $unit typedef listing** (ModuleEmit / UhdmExporter): TL/tl06.

## Process

- **Builds and sweeps:** two builds (law, verified) and two five-stage sweeps (law, verified). There was no
  pristine build and no pristine sweep; the pristine reading is the master's control at /tmp/intr11u462.
- **Targeted runs:** one runner call (3 rows, the verified binary, traced) for the prediction. Case runs at
  nice 10 while sweeps ran. Every sweep and runner call was launched after drivers/quiet.sh read 0 live
  sweep/runner processes, waiting out the sister v11u464's sweeps.
- **Fence:** the fence list was read into a file by a program and never printed. Every tree-wide list
  (cmds.txt audit) was filtered on it first. No fenced test was named, opened or run.
- **Slips (no measurement affected):**
  - My first upstream-slang check loop printed `$?` after a `$(basename ...)` substitution, so it read 0
    for every case. Rerun correctly, it found vl22 rejected (rewritten in place) and vt08 rejected before its
    fix.
  - vt06 and vt13 were rewritten before any run, to avoid names slang does not import transitively.
  - I edited the first line of vt23 to vt26 to name the refinement after their runs. The golden cache of my
    driver rebuilds on a newer dut.sv, and the bytes are unaffected.
