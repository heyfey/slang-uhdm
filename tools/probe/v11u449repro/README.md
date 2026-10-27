# v11u449 — adversarial verification of r11u449

This is the adversarial verification of r11u449 (the expression/parameter ground, pass 449).
- Base: 84452b82f (pass 446).
- Implementer's patch: /tmp/r11u449.patch.
- Verified patch: /tmp/r11u449.verified.patch. It is the implementer's patch plus two production refinements in src/StmtEmit.cpp, plus the label fix and the files listed under "Non-production changes" below.

## Verdict

**The laws are confirmed. One break was found and fixed (§ drillUnresolvedFallback449v), and one law overreach was refined (§ pkgVarScopedNameInt449v).**

The three sv-tests conversions reproduce bit-for-bit on the law binary and on the verified binary:

    generated/uvm-examples/uvm_messaging_example.sv,STRICT_NOTEQUAL,differ:file(5),differ:file(5)
    generated/uvm-examples/uvm_priority_arbitration.sv,STRICT_NOTEQUAL,differ:file(5),differ:file(5)
    generated/uvm-examples/uvm_priority_grab_lock.sv,STRICT_NOTEQUAL,differ:file(5),differ:file(5)

sv-tests on both binaries reads EQUAL 1914, STRICT_NOTEQUAL 3, DIFFERENT 23, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8 and TIMEOUT 1 of 2346, with `regressions=0 conversions=3 changes=0`. The law sweep's csv is identical to the implementer's.

## Builds and binaries (frozen under /tmp/v11u449_bin)

| Binary | md5 | How it was made |
|---|---|---|
| pristine | 0629d46c68933a364c6dcac8b2a3967b | Copy of the main tree's build. No pristine build and no pristine sweep. The pristine reading is the master's control at this base, /tmp/intr11u446. Its probe, downstream and svtests csvs equal results/*.csv. |
| law | c1d444154eb3fc539c31cdd6546704ed | The one rebuild of /tmp/r11u449.patch on a fresh 84452b82f. Equal to the implementer's law5. Links slang 12.0.0+545f88b2e. |
| ver1 | 29ac33237cd7705b0fb357483a2f6dda | The verified build (the second build). |

## Reproduction (the implementer's headline numbers)

**Grid.** The implementer's 34 case dirs give the same exit code, uhdm-cmp count and strict verdict as its evidence/grid_law5.txt, on both binaries (evidence/grid_r11u449_cases.txt). The md5s differ only by the source path.
- ce01 and mc01 to mc04 go to STRICT_EQUAL.
- pv01 and pv10 go to STRICT_EQUAL.
- it01 goes from line to fullname.
- `R11U449_OFF` gives pristine's bytes on 34 of 34. Each case's own law switch restores pristine on every mover (evidence/switch_ver1.txt).

**Law sweep** (/tmp/v11u449_swl, the five stages, trace on):

| Stage | Result |
|---|---|
| probe | 4023 + 64, 0/0/0. 0 of 4087 databases move against the control by path-normalized dump (drivers/pdump.sh). Positive control: two different databases differ by 787 lines. |
| surelog | 480 + 0 / 474 + 0, 0/0/0. The csv differs from the control only in the two LowMem log paths. |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0. |
| downstream | 803/66/2/0. The csv is identical to the control's. |
| sv-tests | As in the verdict. |

The corpus stages exited 1 on the stale law index alone, because this verifier relabeled cases (see below).

**Byteverify against /tmp/intr11u446:**
- surelog: 4 of 962 movers, exactly the predicted ones:
  - MiniAmiq default and testflags: 2045a4349505
  - SeqDriver default: 76376697c46f
  - SeqDriver testflags: 904727dc7e44
- uhdm2rtlil: 0 of 1608.
- downstream: 0 of 805.
- The self-checks flag 961, 1607 and 804.

**Other checks on the law sweep:**
- Canaries ok=52 and ok=16. ctcan2 PASS on surelog (EXPECT_UNKNOWN=1) and on uhdm2rtlil (EXPECT_UNKNOWN=6).
- Binary audit (cmds.txt fence-filtered before any file was opened):
  - surelog: 1523 of 1573 records name the binary under test. The other 50 hold only a Surelog line; two of them mention the repository path in a UVM source.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
- Trace census: the same 25 databases and per-law counts as the implementer's. The 4 MiniAmiq/SeqDriver databases fire formalClsElemMemberDrill449 only. The 21 sv-tests uvm-examples rows fire all six laws.

**Localizer** (pass 446's clsloc, `ALL top`, on runner pairs kept for 5 rows; pristine -> ver1):

| Row | pristine | ver1 |
|---|---|---|
| uvm_messaging_example | 16 | 0 |
| uvm_priority_arbitration | 16 | 0 |
| uvm_priority_grab_lock | 16 | 0 |
| uvm_test_init | 128 | 0 |
| uvm_use_models_unidirectional | 16 | 0 |

The first strict field on messaging_example is struct_typespec uvm_pkg::uvm_reg_bus_op: golden uvm_reg_map.svh 1793:40, ours uvm_reg_item.svh 244:9. This is the implementer's residue 1(a), on the sister's ground.

**Determinism.** Three concurrent ver1 runs of MiniAmiq default, from the sweep's command line and directory, plus the sweep's own database, read one hash (2045a4349505) 4 of 4.

## THE BREAK and the refinements (src/StmtEmit.cpp, read through src/LawSwitch.h)

1. **§ drillUnresolvedFallback449v** (`R11V449_DRILLFALL_OFF`, `lawFixOn`). This is THE BREAK, found on legal SV where pristine was right.
   - **The case:** VT/vt08, a FREE package function `function automatic void walk(ref C blks[$]); foreach (blks[i]) ...` where class C declares `int unsigned blks[C]`.
   - **What went wrong:** § formalClsElemMemberDrill449 drills to the property, as golden does: golden binds the property's index class_typespec C at 4:23. The branches that follow resolve a property only through arrayVarArrayTs or the queue and string branches, which are not reached from a free function. So the shared home object fell to the unsupported placeholder: pristine STRICT_EQUAL went to the law's STRICT_NOTEQUAL type.
   - **The fix:** a drilled property left unresolved takes its own class_defn listing typespec. When there is no such listing, the formal's io_decl route is restored, which gives pristine's bytes.
   - **Result:** vt08 and vt11 (the class declared after the function through `typedef class C`) are STRICT_EQUAL again, byte-identical to pristine. vt02, vt10 and vt13 (scalar `int` and `string` properties, where golden binds the property's own int_typespec 4:5 or string_typespec 4:5) also return to pristine's bytes. They are wrong on both binaries and were not toward golden on the law either: the law's placeholder against pristine's class_typespec.
2. **§ pkgVarScopedNameInt449v** (`R11V449_PKGVARSCOPED_OFF`, `fixOn`). This is an overreach of § pkgVarArrCloneLoopVarTs449, not a break, since pristine was wrong too.
   - **The shape:** a qualified `foreach (p::a[i])` over a package variable. Golden binds a fresh int_typespec with no span, which is § cloneLoopVarClassScopedInt252's rule for a scoped name. The law wrote the bare spelling's array_typespec (VP/vp08) or string_typespec (vp12).
   - **The fix:** a scoped spelling takes the int_typespec.
   - **Result:** vp08 and vp12 now bind golden's int_typespec. vp11 (`foreach (p::s[i])` over a package string) goes from STRICT_NOTEQUAL type on pristine and on the law to STRICT_EQUAL.

**Switches.** On every case dir: `R11V449_OFF` gives the law's bytes, `R11U449_OFF` gives pristine's bytes, and each fix's own switch gives the law's bytes. The fixes fire only when their law fires.

**Prediction, recorded before the verified sweep** (evidence/prediction_ver1.txt): ver1 writes the law's bytes everywhere and the fixes fire 0 times. The prediction held:
- byteverify ver1 vs law: 0 of 962, 0 of 1608 and 0 of 805.
- probe: 0 of 4087 byte movers.
- Every csv equals the law sweep's, apart from the two LowMem paths.
- The verified sweep's trace lists the same 25 databases with the same counts, and no 449v line.

**Verified sweep** (/tmp/v11u449_swv): probe 4023 + 64, surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 in both modes, downstream 803/66/2/0, all 0/0/0, and sv-tests with the 3 conversions and 0 regressions. Canaries ok=52 and ok=16, ctcan2 PASS on both, and the binary audit as for the law sweep.

## Attack grid (61 case dirs in cases/; evidence/grid_v11u449_cases.txt)

Every case is accepted by upstream slang (`--single-unit`), and every exit code is 0 on all three binaries. Distances are measured by the shared home object's typespec (drivers/shobj.sh), uhdm-dump distance, and strict record distance (drivers/rdist.sh).

**VM (§ macroCloneLoopVarPerSub449)**
- vm01: nested i/j in macro methods.
- vm02: macro-written FREE functions.
- vm04: a parameterized class with a named block.
- vm01, vm02 and vm04 go STRICT_NOTEQUAL depth -> STRICT_EQUAL, with every shared object golden's.
- vm03 (diamond import r, s): its shared objects are now golden's. It stays NOT_EQUAL behind the diamond-listing residue.
- vm05: control, byte-identical.
- The dump distance grows by 2 to 12 lines on these cases while strict is equal: this is the implementer's placement residue 3.

**VP (§ pkgVarArrCloneLoopVarTs449, § pkgVarScopedNameInt449v)**
- vp01 to vp06 and vp10 get golden's shared object (array_typespec; string_typespec 3:3; an associative array's index string_typespec 3:9). They stay NOT_EQUAL behind the package-variable listing face (implementer residue 5).
- vp08, vp11 and vp12 are the scoped fix.
- vp07 (packed `logic [7:0] v`): golden logic_typespec 3:3. The law abstains, so it stays pristine.
- vp09 and vp13: no firing.
- vp04 and vp09 were renamed from loop variable `k` to `kk`: with `k`, Surelog's lateBinding picks up the importer package's own `int k`, a golden artefact.

**VT (§ formalClsElemMemberDrill449, § drillUnresolvedFallback449v)**
- vt01, vt03, vt04, vt05, vt06 and vt09 get golden's drilled object:
  - vt01: index class C 4:29.
  - vt03: a property of another class, a fresh array_typespec.
  - vt04: an INHERITED property, class_typespec A 4:23.
  - vt05: a fixed formal, int_typespec 4:17.
  - vt06: a queue property.
  - vt09: a free function over a queue property.
- vt01's record distance goes 10 -> 2 and vt04's 10 -> 2. The rest are behind the listing face.
- vt07 and vt12: no firing.
- vt02, vt08, vt10, vt11 and vt13: the break and the fix (above).

**VI (§ cloneLvFormalTdTopListing449)**
- vi01 (union), vi02 (enum), vi04 (two importers) and vi06 (a dynamic array) bind golden's object, the listing clone at the formal's first use, re-parented at the home foreach.
- vi02's record distance goes 8 -> 0.
- vi03 (a FREE function) and vi05 (a typedef from a third package o): the parent is now golden's, but the typespec stays at the typedef 3:11 where golden has the first-use copy (4:39 and 8:29). vi05's dump distance grows 300 -> 392 because the dump prints the home foreach subtree in its tail. Its strict verdict and uhdm-cmp count are unchanged (692).

**VF (§ freeCloneCmCallKeepsClassMethod449)**
- vf02 (a static task), vf03 (diamond) and vf04 (with a free call) move toward golden: dump distance 40 -> 36, 130 -> 122 and 64 -> 60, strict unchanged.
- vf01 (a class from a third package), vf05 (the importer's own same-named class R) and vf06: byte-identical.

**VC (§ cloneCtorEatenLocalNoBind449)**
- vc01 (two importers), vc03 (the module also news R), vc06 (two eaten locals) and vc07 (an importer subclass) go NOT_EQUAL -> STRICT_EQUAL.
- vc02 (diamond): uhdm-cmp 29 -> 341, because its first difference moved from the clone's rh to the diamond package listing (implementer residue 2). Dump distance 280 -> 214.
- vc04 (an in-body constructor) and vc05 (a constructor with a port): no firing.

**Downstream.** VT/vt08, VP/vp08, VC/vc01, VM/vm01, VI/vi04 and VF/vf03 read IDENTICAL on pristine and ver1. These are class-only designs, NO_GATES on both lanes.

## Non-production changes in the verified patch

- 14 of the implementer's case files named laws that do not exist on their first line. IT/it01 to it04 said `§ cloneLoopVarFormalTdImporterCopy449` and TS/ts01 to ts10 said `§ cloneLoopVarThisPropIdx449`. They now name `§ cloneLvFormalTdTopListing449` and `§ formalClsElemMemberDrill449`, so tests/CASES.csv attributes them.
- tests/LAWS.md was regenerated with this directory included.

## Residues, ranked (all wrong on pristine too; none moved away on the strict axis)

1. **The three converted rows' file(5).** UhdmExporter § cloneAggLocalOwnCopy241 / § cloneSharedAggOwnCopy265, the sister's: the private struct copies sit at 244:9 where golden has 1793:40. Also the indexed part-select clone binding (the implementer's residue 1b).
2. **Diamond imports.** VM/vm03, VC/vc02 and VF/vf03 (dump), plus uvm_test_init and the generation_seq rows. ParamEmit impVars9 / collectImportedParams. Decoded by the implementer, not written.
3. **A drilled SCALAR property (int or string)**, where golden binds the property's own typespec: VT/vt02, vt10, vt13. The class_defn listing is not reachable when the clone body is emitted, so the fallback restores pristine.
4. **Packed package variables** (VP/vp07): golden binds the variable's logic_typespec and the law abstains.
5. **The typedef rebind for a free function** (VI/vi03) and **for a typedef imported from a third package** (vi05): golden binds the formal's first-use copy.
6. **The placement of the shared home object** (the implementer's residue 3): dump-only.
7. The implementer's residues 4 to 7 and the carried backlog.

## Sister-ground faces (reported, not written)

The implementer's list stands:
- UhdmExporter § cloneAggLocalOwnCopy241 / tryOwnCopy265 spans.
- § pkgCloneHierBind9 and TypeEmit § cloneStmtHomeVarRef17 do not cover indexed_part_select.
- ModuleEmit's interface listing on uvm_use_models_unidirectional.

## Process

- **Budget:**
  - The law was rebuilt once and swept once.
  - One verified build (ver1) was swept once, after a prediction written before launch.
  - No pristine build and no pristine sweep. No third build.
  - Targeted runner calls on 5 rows with both binaries ran on a quiet machine after both sweeps.
- **No overlap:**
  - Each sweep started after three quiet readings 60 s apart (drivers/gate.bash).
  - The law build ran at nice 19 while the sister v11u448's sweep was live: a build, not a measurement.
  - The case grids (one process at a time, nice 19) also ran beside the sister's sv-tests stage, which affects timing only.
- **Fence:** the fence list was read into a file by a program and never printed. Every cmds.txt list was filtered on it before any file was opened. No fenced test was named, opened or run.
- **Isolation:** no other agent's process was touched, and every scratch file is under /tmp/v11u449_*.

Drivers:
- run1.sh: one case. Golden cached per case text; prints rc, uhdm-cmp, strict and md5.
- grid3.sh: pristine, law and ver1, plus both OFF switches.
- switch.sh: per-law switches.
- shobj.sh: the shared home object's typespec.
- rdist.sh: strict record distance.
- pdump.sh: the probe path-normalized dump census.
- gate.bash: the quiet-gated five-stage sweep.
