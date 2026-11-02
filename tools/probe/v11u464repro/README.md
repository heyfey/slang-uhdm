# v11u464: adversarial verification of r11u464 (module/type ground, pass 464)

Base dbf4f9529. Implementer's patch /tmp/r11u464.patch (six laws in src/UhdmExporter.cpp). Verdict: **ONE BREAK FOUND AND FIXED** in § unitImpTransitiveTds464, by the refinement § unitImpTransNameFirst464v (src/UhdmExporter.cpp, read through fixOn(464, "R11V464_TDNAMEFIRST_OFF")). The other five laws are confirmed unchanged. The verified patch is /tmp/r11u464.verified.patch.

## Binaries (frozen, chmod a-w; evidence/binaries.md5)

| binary | md5 | what it is |
|---|---|---|
| /tmp/v11u464_bin/pristine | d59c9ff65c1b72790be68a21e7794397 | a copy of the main tree's build/slang-uhdm (no pristine build, per the measurement budget) |
| /tmp/v11u464_bin/law | 0cc21ab91f3f74e62f3ed31f81161d8d | rebuilt from /tmp/r11u464.patch on a fresh dbf4f952; equal to the implementer's law7; reports slang 12.0.0+545f88b2e |
| /tmp/v11u464_bin/ver3 | 450798454c55b4a77ef33ecc1d731c07 | the verified binary: law plus § unitImpTransNameFirst464v |

There were two intermediate verified builds, ver1 and ver2. They differ from ver3 only in how narrowly the refinement's lawTrace call is guarded. ver1 and ver3 give identical bytes and exit codes on all 8314 case dirs, apart from the 26 dirs that exit 3, whose bytes vary from run to run on any binary.

## THE BREAK: § unitImpTransitiveTds464 lists two typedefs of one name

Surelog fills a scope's DataTypeMap through `DesignComponent::insertDataType`, which is a `std::map::emplace` (third_party/Surelog/src/Design/DesignComponent.cpp). `CompileHelper::importPackage` copies the imported package's map entry by entry with that call. So within a package's map, and within a module's map, **the first typedef of a name wins**.

When a package reaches two transitive typedefs of one name, golden lists only the first one. The law listed both.

Case VT/vt02: `abc` imports a::t and then b::t, `e` imports abc, and the module has a file-scope `import e::*`.
- Golden lists a::t only.
- Pristine listed neither (uhdm-cmp 221 lines).
- The law listed both a::t and b::t. uhdm-cmp grew to 494 lines, and the extra b::t at the module is an object golden lacks.

This is legal SV, accepted by upstream slang, and the law adds an object that golden does not have. The same break shows in:
- vt14: two file-scope imports, each reaching a different t;
- vt15: an explicit file-scope `import p::t;` written before a wildcard import that reaches another t;
- vt16: a deeper chain whose two branches each carry a t.

**§ unitImpTransNameFirst464v** (R11V464_TDNAMEFIRST_OFF). A transitive typedef is listed only while its name is not yet in the module's map. The names already in the map are, in import order:
- the names of earlier explicit file-scope imports;
- the direct package's own typedefs that no import of that package shadows (§ importShadowOf: in vt01 golden drops e's own t for the imported a::t, and the law already had that right);
- the transitive typedefs already taken, in walk order.

lawTrace(464, "unitImpTransNameFirst464v", ...) logs only a skip of a different symbol. A diamond, or an earlier import that reaches the same symbol, is not logged.

The design-level listing needed no change: there `byName.emplace` is already first-wins.

| case | pristine | law | verified |
|---|---|---|---|
| VT/vt02 | uhdm-cmp 221, dist 12 | uhdm-cmp 494, dist 8 | **STRICT_EQUAL** (117 objects) |
| VT/vt14 | 221, dist 8 | 494, dist 6 | **STRICT_EQUAL** (113) |
| VT/vt15 | 494, dist 8 | 602, dist 6 | **STRICT_EQUAL** (127) |
| VT/vt16 | 602, dist 28 | 818, dist 8 | **STRICT_EQUAL** (231) |

Switch checks on the verified binary (evidence/switchcheck.txt, 103 dirs: my 66 plus the implementer's 37):
- R11V464_OFF gives the law's bytes on 103 of 103.
- R11U464_OFF gives pristine's bytes and exit code on 103 of 103.
- Every moved dir is restored by its own law's switch alone.
- The refinement's trace fires on exactly vt02, vt14, vt15 and vt16, the only four dirs where the verified bytes differ from the law's.

## Reproduction of the implementer's numbers

- **Law build.** md5 equals law7.
- **Implementer's grid.** All 42 dirs reproduced on exit code, uhdm-cmp count, strict verdict and dump distance, with 0 mismatches (37 own cases plus r11u463 MO/mo06 and mo09, v11u462 VR/vr06 and vr09, and r11u462 CR/cr03).
- **Tally slips in the implementer's README (measurement unaffected).** Its grid holds **42** dirs, not 43, and the implementer's own cases number **37**, not 38. **34** reach STRICT_EQUAL on law7, not 30, and 27 of them were not equal on pristine, which matches. **19** dirs go from exit 4 to exit 0, not 17: 15 reach STRICT_EQUAL and 4 do not (cn08, cs04, cs05, cr03).
- **One full five-stage sweep on law** (`/tmp/v11u464sw_L`, R11U464_TRACE on). The four corpus stages ran from the worktree (rc 0). The sv-tests stage ran through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty; that run exited 1 only on the main tree's "law index STALE". Results:
  - probe: EQUAL 4024 + STRICT_NOTEQUAL 63; regressions 0, conversions 0, changes 0; csv identical to the control /tmp/intr11u462.
  - surelog: 480 + 0 / 474 + 0; 0/0/0; csv equal to the control except the two LowMem log-path texts.
  - uhdm2rtlil: 803/1/67 in both modes; 0/0/0; csv identical.
  - downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; csv identical.
  - sv-tests: EQUAL 1930, STRICT_NOTEQUAL 1, DIFFERENT 9, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions 0, conversions 1, changes 0. The csv is byte-identical to the implementer's evidence/svtests_law7.csv.
- **The conversion.** `generated/uvm-examples/uvm_many_to_one.sv,STRICT_NOTEQUAL,differ:type(1),differ:type(1)`. On the kept pair, uhdm-cmp reads 0 lines. build/uhdm-strictcmp's first record is #67925: golden `class_typespec uvm_object_wrapper` (uvm_object_globals.svh 717), ours `unsupported_typespec idx` (uvm_globals.svh 373:29). That is the sister's StmtEmit foreach face, as the implementer reported.
- **Byteverify, law against the control, per corpus.**
  - surelog 3 of 962 move (Scoreboard default, SimpleUVM default and testflags), with the implementer's hashes. SimpleUVM default is d5640b2350a8.
  - uhdm2rtlil 0 of 1608; downstream 0 of 805.
  - SELFCHECK flags 961, 1607 and 804 per corpus. A single combined run reads 3404 of 3406, because two duplicate databases make the selfcheck's na-1 rule fail; that is a harness artefact.
  - sv-tests: 31 of 31 kept databases move raw bytes. Under uhdm-strictcmp --no-canon, 28 are STRICT_EQUAL to the control (serialization order). The other 3 are rsd, uvm_many_to_one and uvm_use_models_pipelined_get_put, the § unitImpTransitiveTds464 firings.
- **Trace firing sets** match the implementer's:
  - § unitClsListsSpecBase464 on 133 sv-tests rows, the 3 surelog row-modes above and probe r10uvm49repro/a6;
  - § unitImpTfNameDedup464 on uvm_many_to_one only;
  - § unitImpTransitiveTds464 on rsd, uvm_many_to_one and pipelined_get_put;
  - the three goal-1 laws on no corpus row, probe case or sv-tests row.
- **Other checks.** Canaries read ok=52 and ok=16, and both ctcan2 checks PASS. The fence-filtered binary audit names the law binary in 1523 of 1573 surelog cmds.txt (the other 50 hold only a Surelog line), 1740 of 1740 uhdm2rtlil and 2346 of 2346 sv-tests.

## The verified sweep (one, on ver3; `/tmp/v11u464sw_V`, trace on)

The prediction was written before the sweep (evidence/prediction_verified.txt). The refinement only narrows law 1, and law 1 fires on no corpus or probe database. A traced runner call of ver3 on law 1's three sv-tests rows logged no firing of the refinement. ver1's databases there were STRICT_EQUAL --no-canon to the law sweep's (rsd 7200634, many_to_one 966731, pipelined_get_put 751654 raw objects).

The prediction held:
- All five verified csvs equal the law sweep's after path normalization.
- Byteverify of the verified sweep against the law sweep: surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805. The sv-tests 31 raw-byte movers are 31 of 31 STRICT_EQUAL --no-canon to the law sweep.
- Byteverify of the verified sweep against the control: the same 3 surelog movers with the same hashes.
- The refinement fired nowhere in the sweep.
- Canaries read ok=52 and ok=16, and both ctcan2 checks pass. The binary audit names ver3 in 1523 of 1573, 1740 of 1740 and 2346 of 2346.
- Determinism: three concurrent ver3 draws of SimpleUVM default plus the sweep's database give one hash in 4 of 4: d5640b2350a86246ebb01e0f9b2b9532. This is the new SimpleUVM default hash from § unitClsListsSpecBase464, the same as the implementer's.

Verdicts per targeted row:
- **generated/uvm-examples/uvm_many_to_one.sv: DIFFERENT -> STRICT_NOTEQUAL differ:type(1)** (fresh row above). The refinement leaves it unchanged.
- uvm_use_models_pipelined_get_put: stays DIFFERENT.
- uvm_param_vif_config_db: stays DIFFERENT.

## Attack grid (evidence/attack_grid.txt; 66 fresh case dirs; pristine | law | verified, path-normalized uhdm-dump distance)

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit). VT/vt09 was first written with an export that slang rejects ("use of undeclared identifier 'a_t'") and was rewritten in place so that m names a_t.

Totals on the verified binary:
- 47 cases are STRICT_EQUAL, 43 of them newly.
- 26 go from exit 4 to exit 0, and 22 of those reach STRICT_EQUAL.
- 57 dirs move and 9 are byte-identical controls (VF/vf09, vf10, VM/vm05, vm09, vm10, VN/vn08, vn09, VT/vt03, vt04).
- **No case moves away from golden on the verified binary.** Dump distance falls or holds on every case.

The groups:
- **VT** (§ unitImpTransitiveTds464, 16 cases). Reach STRICT_EQUAL: vt01 (the importing package's own t shadowed by the imported a::t, a case the law already had right), vt02 and vt14 to vt16 (the break), vt05, vt06 (struct and enum typedefs), vt07 (class specializations), vt08 (two modules), vt10 (diamond), vt12 and vt13 (the packages in another file). Closer but not equal: vt09 (re-export, 687 -> 679, the same head) and vt11 (a program, 12 -> 4). Controls: vt03 (an explicit body import `import a::a_t;`: Surelog's importPackage copies the named entry, so golden lists a_t where the law does not follow explicit edges; a residue, pristine equally wrong) and vt04 (a middle package declared after its importer; the order rule holds).
- **VF** (§ unitImpTfNameDedup464, 10 cases). vf01 to vf03 (unrelated packages sharing f or t, in either import order) reach STRICT_EQUAL. vf06 and vf07 (a three-package chain) go from uhdm-cmp 3628 to 0, STRICT_NOTEQUAL fullname. vf04 (the importer declares its own f), vf05 (two packages' C::m) and vf08 (a $unit f beside the imports) move closer but stay NOT_EQUAL at older heads. Controls: vf09, and vf10 (imports in two files, where the law abstains).
- **VB** (§ unitClsListsSpecBase464, 8 cases). vb01 to vb06 (two $unit classes, a typedef of the base, an explicit import, the module also using the base, the class extending the base, a class never naming it) go from STRICT_NOTEQUAL fullname to STRICT_EQUAL. vb07 stays STRICT_EQUAL and moves closer (14 -> 12). vb08 moves closer (145 -> 117) at uhdm-cmp 17, the pass-463 group-copy head.
- **VS** (§ clsShortRealAliasElem464, 6 cases). All six go from exit 4 to exit 0. vs01, vs03, vs04 and vs05 reach STRICT_EQUAL. vs02 and vs06 (realtime aliases) stay NOT_EQUAL at the $unit typedef's vpiInstance and listing, the implementer's cs05 face.
- **VN** (§ clsNestedUnsizedDims464, 13 cases). 11 go from exit 4 to exit 0 and 10 reach STRICT_EQUAL: string, class-handle, packed-struct and enum elements, `[$][$]`, `[][$]`, `[][][]`, bit vectors, a parameterized class, static and rand. vn12 (shortreal `[][]` with realtime `[$][]`) reaches exit 0 but NOT_EQUAL, because the realtime element is written as real_var where golden has time_var. vn08 (`[][int]`) stays at exit 4. vn09 (bounded leading queue) is byte-identical, already STRICT_EQUAL.
- **VM** (§ clsInnerUnsizedAnyElem464, 13 cases). Eight reach STRICT_EQUAL: real `[2][$]`, string `[3][$]`, logic signed, two-dimension packed logic, an alias of real, realtime, `[2:0][]` and `[0:1][]` ranges, and `[2][3][]`. vm07 (an alias of shortreal) goes to exit 0 but NOT_EQUAL: the inner element is golden's logic_typespec, where the law writes unsupported_typespec. vm05 (bit vector), vm09 (scalar logic) and vm10 (`[2][int]`) stay at exit 4 and are byte-identical. vm13 (`reg [7:0] m[2][]` in a package class) stays at exit 4.

Downstream sample (evidence/downstream_sample.txt): VT/vt02, vt12, vt14, vt16, VF/vf01, vf06 and VB/vb04 read IDENTICAL on both pristine and verified. These shapes do not reach the RTLIL.

Byte checks on earlier cases: 8314 fence-filtered case dirs of every r11u4xx and v11u4xx repro, plus this pass's two grids.
- Law against verified: only VT/vt02, vt14, vt15 and vt16 move, plus the 26 dirs that exit 3 on both binaries and whose bytes vary from run to run on any binary (the implementer's evidence/bytecheck_rc3_pristine_vs_pristine.txt).
- ver1 against ver3: the same 26 only.

## Residues (ranked; none moved away on the verified binary)

1. uvm_many_to_one's last strict face is the sister's StmtEmit foreach loop-variable typespec in import-clone bodies (record #67925 above).
2. uvm_use_models_pipelined_get_put and uvm_param_vif_config_db stay DIFFERENT, unchanged by the refinement (as in the implementer's README).
3. A transitive chain through an explicit body import (`import a::a_t;` in a package that a file-scope import reaches) is not followed by § unitImpTransitiveTds464 (VT/vt03). The DataTypeMap still holds that one entry.
4. Goal-1 class-property shapes still at exit 4:
   - a bit vector or scalar logic inner element `[2][]` (VM/vm05, vm09);
   - an inner associative dim `[2][int]` (vm10);
   - a reg vector inner element (vm13);
   - `[][int]` (VN/vn08).
5. Exit 0 but not equal:
   - an alias-of-shortreal inner element, where golden's element typespec is logic_typespec and ours unsupported_typespec (VM/vm07);
   - a realtime element in a nested-unsized property, real_var where golden has time_var (VN/vn12);
   - realtime-alias dynamic, queue and associative properties at the $unit typedef's vpiInstance face (VS/vs02, vs06; the implementer's cs05).
6. VF/vf04, vf05 and vf08 sit at older class-method and $unit-function heads. vf06 and vf07 are STRICT_NOTEQUAL on fullname.
7. VB/vb08 is the cross-package group-copy face of pass 463.
8. The implementer's ranked list stands: easyUVM and the 3 uvm_scoreboard rows; the goal-1 probe shapes AC/ac05, PA/pa04, pa05, AQ/aq03, aq04, v11u450 VA/va04 and v11u451 VN/vn05; cn08, cs04, cs05, uf05, ut02 and mo06; p733, p737 and tnoc await the user's decision.

## Sister-ground faces (report only)

- StmtEmit: the foreach loop-variable typespec in import-clone bodies, uvm_many_to_one's only remaining strict face. Golden class_typespec uvm_object_wrapper, ours unsupported_typespec idx, at uvm_globals.svh 373:29 in b_pkg's clone of uvm_pkg::uvm_init.

## Process

- **Measurement budget.** No pristine build and no pristine sweep: the pristine reading is the master's control /tmp/intr11u462. There was one law build and one five-stage law sweep. Because the verified binary changed production code, there was one five-stage verified sweep. There were three verified builds; the second and third changed only the trace guard and were byte-checked against the first on every case dir.
- **The sister's sweeps.** No build, grid batch, runner call or sweep ran while the sister's sweeps (r11u465, then v11u465) were live. The waits used a quiet-check script that excludes itself from the match.
- **Slip, affecting no measurement.** My first wait loop's `pgrep -f` pattern matched its own command line. It was stopped by its task id and rewritten as a script file.
- **Slip, affecting no measurement.** My first law-against-verified byte check ran on relative case paths from the main repo directory. Every `cd` failed, no binary ran and nothing was written outside /tmp. It was rerun on absolute paths.
- **The fence.** The fence list was read into a file by a program and never printed. Every tree-wide list (case dirs, cmds.txt files) was filtered on it first. No fenced test was named, opened or run. No other agent's process was touched.

Files: cases/ (66 dirs in VT, VF, VB, VS, VN and VM; each first line names its law); drivers/ (env.sh, runcase.sh with multi-file FILES support, dist.sh, switchcheck.sh, bytecheck.sh); evidence/ (binaries.md5, attack_grid.txt, switchcheck.txt, prediction_verified.txt, downstream_sample.txt, determinism_simpleuvm_default.txt, sweep summaries, byteverify).
