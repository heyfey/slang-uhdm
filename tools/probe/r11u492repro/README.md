# r11u492 — the package-qualified scalar typedef formal (§ tfArgQualVecTdShared492, § pkgRetTopArgTsImportClone492)

Base da667f353. Target: tests/probe/r10buvm8repro/vxpkg8, STRICT_NOTEQUAL `differ:line(7)` in
results/golden_probe.csv (pass 299's residue 2, "not attempted"). Production surface:
src/TaskFuncEmit.cpp, src/UhdmExporter.cpp, src/ExprEmit.cpp, src/law/LawState.h (no other
header, no getenv; every switch through src/law/LawSwitch.h). Worked in the main tree of the
clone (single agent, implementer and lander at once; no separate verifier pass).

## Verdict

vxpkg8 reads EQUAL (uhdm-cmp equal and STRICT_EQUAL, 349 objects). Two laws, both decoded from
Surelog's source and measured on a golden grid. The gate sweep converts 9 probe cases (vxpkg8 and
8 others) and moves no corpus or sv-tests row.

## The laws

1. § tfArgQualVecTdShared492 (switch R11U492_QUALVECTD_OFF; TaskFuncEmit records, the
   design-final pass in UhdmExporter::exportDesign applies). A subroutine formal written
   package-qualified (`zp::zb_t a`) whose typedef is a scalar or vector kind (logic, bit, int,
   integer, byte, shortint, longint) binds the typedef's SHARED object, the elaborated package's
   listing object. An ANSI formal also MOVES that object to its qualifier.
   - Surelog: CompileType.cpp:1525 (`case VObjectType::paPackage_scope`) answers `p::t` with the
     package DataType's own typespec (`result = sit->getTypespec()`, CompileType.cpp:1568,
     no clone). Only the bare name's compileDatastructureTypespec clones, which is the ground of
     § tfArgScalarTdWriter223. CompileStmt.cpp:1809 (`fC->populateCoreMembers(type, type, ts)`)
     relocates the object to `type`, the data type's first child: the Package_scope node `zp::`,
     or the whole scoped name when a direction keyword is written (§ tfArgQualOutsideWriter176's
     decode).
   - The last compiled writer wins: the packages' own subroutines in source order, then module
     and interface subroutines in definition-name order, then programs, then class methods in
     class-map key order (`p::C`, `work@m::C`). Grid cells: q06 and q26 (packages in source
     order, not name order), q21 (a module after a package written later in the file), q23
     (modules by name), q22 and q25 (a class method after the package's or module's own
     subroutine), q20 (a writer inside the typedef's own package is a writer like any other).
   - The definition package listing keeps its declaration span. A body-declared formal
     (`input zp::zb_t a;`, q16) binds the object without moving it.
   - Two copies follow the move. (a) An elaborated instance variable's unaliased bare copy
     (LAW S), which Surelog mints at elaboration after every compile, takes the moved span
     (q04, q31, vxpkg8 `work@m_xpkg.z`). (b) In an importer's DEFINITION-view clone of a home
     subroutine (§ importCloneBareTdAlias16), the bare unaliased alias target takes the moved
     span (vxpkg8 `ap::zf`'s x, y and return; the elaborated clone's keeps the declaration span
     in golden).
   - A bare formal outside the typedef's package (§ 223's copy, `zb_t a` in an importer) has its
     alias re-pointed to the moved object in the definition view (q11, q12, q29, q30). A formal
     whose io_decl sits in the home package's text (the home's own subroutines and the
     importers' clones of them) keeps its alias (vxpkg8, q32).
   - Abstains: a writer in `$unit`, a writer in an out-of-body definition, a DPI import, an
     import copy, a class-scope qualifier, an unpacked formal other than fixed-size.
   - Ours bound a per-formal named clone at the whole written type and left the object at the
     typedef declaration.
2. § pkgRetTopArgTsImportClone492 (switch R11U492_RETARGCLONE_OFF; ExprEmit records at the
   § pkgRetTopCallArgFormalTs8 stamp, UhdmExporter applies design-final). A bare call
   (`zf(a, b)`) of a function brought in by a wildcard import, inside a return in the
   elaborated package listing, has its actuals typed by the formals of the importer's CLONE
   (`ap::zf`, the function the call binds), not by the home function's elaborated twin.
   - Golden vxpkg8: `ap::af`'s `a` and `b` read `ap::zf`'s formal copies (alias to the bare
     `zb_t` 7:11). Ours read `zp::zf`'s (alias to the listing `zp::zb_t`).
   - The clone's formal copies are final only after § importCloneBareTdAlias16, so the
     re-point is applied design-final. It applies to each actual that still holds its stamp or
     the home twin's final formal typespec, when the clone's formal typespec is a scalar or vector
     kind of the same type.
   - An enum formal abstains. Without that gate, tests/probe/r11u446repro/cases/EB/eb03 and
     v11u446repro/cases/VE/ve06 moved away (3 to 7 differing records).
   - Pristine shows the face without any qualified writer (RC rc01, rc02, rc05). vxpkg8 needs
     it once law 1 is in place.

`R11U492_OFF` drops both laws. With it set, or with both named switches set, the binary's output
matches pristine byte for byte on vxpkg8, Q/q04, RC/rc02 and r11u446 EB/eb03 (md5 equal).

## Grid

The equal cases are in tests/probe/r11u492repro/cases/{Q,RC}. The residues are in
tools/probe/r11u492repro/cases. The evidence is in evidence/grid_pristine.txt, grid_law.txt
(scripts/converge.sh plus build/uhdm-strictcmp through drivers/grid.sh) and in
probe_pristine.csv and probe_law.csv (scripts/check_probe.py, the gate's flags).

| group | law | cases | pristine EQUAL / STRICT_NOTEQUAL / NOT_EQUAL | law EQUAL |
|---|---|---|---|---|
| Q (moved) | tfArgQualVecTdShared492 | 30 | 3 / 7 / 20 | 30 |
| RC (moved) | pkgRetTopArgTsImportClone492 | 6 | 3 / 3 / 0 | 6 |
| vxpkg8 | both | 1 | 0 / 1 / 0 | 1 |

The controls stay EQUAL: q03 (a qualified return type does not move the object), q09 and q10
(struct and enum, which § tfArgQualOutsideWriter176 handles), rc03 (int formals), rc04 (a
qualified call), rc06 (a call that is not a return).

## Residues (tools/probe/r11u492repro/cases; wrong on pristine too, none moved away)

Reachable distance is the number of differing lines between the view-annotated dumps without the
weaklyReferenced tail, pristine -> law.

- Q/q15_unpacked_formal: NOT_EQUAL on both binaries. The module's `zp::zb_t v [2]` end-only move
  (writeNets) is not modelled for a vector typedef. A module-only control without any formal
  fails on pristine too. Distance 12 -> 12.
- Q/q27_byte_td: STRICT_NOTEQUAL (law), NOT_EQUAL (pristine). Golden binds the listing object
  for a byte-typedef module net and variable, where ours binds LAW S's qualified copy and a
  bare copy. A module-only control fails on pristine. Distance 10 -> 4.
- Q/q33_clone_in_writer: STRICT_NOTEQUAL on both binaries. The first difference is the full
  name of the importer's clone body references (`ap::af::x` vs `ap::zf::x`). Distance 63 -> 47.
- Q/q34_clone_in_other_importer and Q/q35_clone_no_import_writer: NOT_EQUAL on both binaries.
  Golden writes the cast of a bare imported call `int'(zf(...))` as an operation where ours
  keeps the func_call. Distance 80 -> 64 and 51 -> 39.
- RC/rc07_nested_expr: NOT_EQUAL on both binaries, the same face as q34. Distance 25 -> 25.

## Predicted and observed movers

Prediction: R11U492_TRACE on the law binary over 317 probe dirs whose sources hold a qualified
formal or a bare call returned in an importing package (fence-filtered;
evidence/trace_candidates.txt). The final binary
fires on 35 dirs. 24 of them re-point actuals; the others bind or move.

Gate sweep on the law binary (/tmp/agenttest/int492, SLANG_UHDM frozen at
/tmp/agenttest/law8.bin, md5 ccf9616493258bb901e25604f24527c9):

- probe: 9 CONVERSIONs, each to EQUAL:
  - vxpkg8
  - r11u196 SF/s05, r11u223 F/f13, r11u229verify E/e01, r11u277 C/c03_kinds,
    r11u423 residue_cases/ci10, v11u266 VA/va09_module_func_literal (law 1)
  - r10uvm36 t48a, r10v208 v208_f_io (law 2; not in the grep list, attributed by trace)
- probe: 4 CHANGEs, all STRICT_NOTEQUAL and closer to golden. Differing records:
  r11u196 FR/f02 3 -> 2, r11u284 E/e12_func_arg 9 -> 8, v11u236 A/a03 6 -> 2,
  v11u243 X/x01_qualint 3 -> 2.
- probe: the only regressions were q27 and q33 as new STRICT_NOTEQUAL cases. They went back to
  tools/probe, and the re-run probe stage is clean (SWEEP below).
- surelog: regressions 0, conversions 0, changes 0. uhdm2rtlil: the same.
- sv-tests: regressions 0, conversions 0, changes 0.
- downstream: IDENTICAL 803, EQUIVALENT 2, SLANG_REJECT 66; "not identical and not excused" 1
  (gen_test7: IDENTICAL in results/downstream_uhdm2rtlil.csv). The pristine binary reads the
  same EQUIVALENT on that row in this clone (`tests/sweep.sh --corpus downstream --filter
  '^gen_test7$'`, exit 1 on both). It comes from the toolchain reused from another checkout, not
  from this change.
- Bytes against a pristine control sweep of the surelog and uhdm2rtlil corpora
  (tools/probe/r10oth4repro/byteverify.sh, SELFCHECK=1):
  - uhdm2rtlil: 0 of 1608 movers.
  - surelog: 4 of 962 movers, MiniAmiq and SeqDriver in both modes. Both stay CMP_EQUAL and
    strict equal.
  - Both are attributed to § pkgRetTopArgTsImportClone492 (svaunit_pkg and adpcm_pkg clones of
    uvm_pkg's `uvm_bitstream_to_string`, `uvm_dpi_get_next_arg_c`, `uvm_re_match`). The only
    dump change is two vpiParent lines in the weaklyReferenced tail.
  - Deterministic: MiniAmiq default eab7b29ed7ed and SeqDriver default 92c3a3c15476 in 4 of 4
    runs (the sweep and 3 reruns from cmds.txt).

## SWEEP

Law binary /tmp/agenttest/law8.bin (md5 ccf9616493258bb901e25604f24527c9), pristine
/tmp/agenttest/base.bin (md5 990748033e220211e9c2e7e37c4483f9, the clone's build at da667f353).

- Full five-stage sweep (/tmp/agenttest/int492), exit 1:
  - probe: the 9 conversions and 4 changes above, plus q27 and q33 as new-case regressions
    (since moved back).
  - surelog: default CMP_EQUAL 480, testflags 474. uhdm2rtlil: CMP_EQUAL 803 in both modes.
    sv-tests: no row moved. All three read regressions 0, conversions 0, changes 0.
  - The exit 1 has three sources: the stale law index at sweep time, the two new-case rows,
    and the downstream gen_test7 row, which reads the same on the pristine binary.
- Probe stage re-run after the move (/tmp/agenttest/int492p), exit 0: EQUAL 29946,
  STRICT_NOTEQUAL 2033 of 31979; regressions 0, conversions 9, changes 4, only-fresh 36 (the
  new r11u492 cases, all EQUAL). Law index current. results/golden_probe.csv is that run's csv.
- Negative control: `SLANG_UHDM=/bin/false tests/sweep.sh --corpus surelog --filter '^Assign'`
  reads regressions=6.
