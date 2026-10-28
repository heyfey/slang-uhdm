# v11u454 — adversarial verification of r11u454 (module/type ground, pass 454)

Base 7f271bbb6. The implementer's patch is /tmp/r11u454.patch. Verdict: **CONFIRMED WITH TWO BREAKS FIXED.**
Both breaks are in § pkgLateTsTransitiveImport454; the verified patch is /tmp/r11u454.verified.patch.
The other three laws held on every attack.

## Binaries (frozen, chmod 555, under /tmp/v11u454_s/bin)

| binary | md5 | notes |
|---|---|---|
| pris | b14a8513b3c466ce49608d70120e8f0b | the main tree's HEAD build, copied; no pristine build of our own |
| law | dbd76f862b3cf0fbe1c5029789b364d3 | rebuilt once from the patch; equals the implementer's law6 |
| ver | 61990b658b183290f4b48a414a72a435 | the verified build; only UhdmExporter changes |

All three link slang 12.0.0+545f88b2e.

## Reproduction (law binary; one full five-stage sweep, workdir /tmp/v11u454lsw)

| Stage | Result |
|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, 0/0/0 |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT |
| sv-tests | EQUAL 1926, DIFFERENT 14, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions 0, conversions 2, changes 0 |

- The probe, surelog, uhdm2rtlil and downstream csvs are identical to the master's control /tmp/intr11u452
  after workdir-path normalization.
- svtests.csv differs from the control only in two rows:
  - `generated/uvm-examples/uvm_use_models_bidir_get_put.sv,EQUAL,,equal` (control `DIFFERENT,decompile:,`)
  - `generated/uvm-examples/uvm_use_models_bidir_item_done.sv,EQUAL,,equal` (control `DIFFERENT,decompile:,`)
- byteverify (SELFCHECK=1) against the control: surelog 2 of 962 (Tnoc default and testflags; self-check 961),
  uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804). See evidence/byteverify_law.txt.
- Canaries: ok=52 and ok=16. ctcan2 passes on both (58 and 2 rows ok).
- Binary audit of cmds.txt: surelog 1531 of 1581 name the law binary (the other 50 hold only a Surelog line),
  uhdm2rtlil 1742 of 1742, sv-tests 2346 of 2346. No record names another slang-uhdm binary.
- The corpora stage exit code is 1 only because of the stale law index (this repro dir was not yet indexed).
- Tnoc mover: with pass 446's allrefs tool (r11u454repro/evidence/allrefs.cpp), only two lines change between
  pristine and law. tbcm_mux::get_ack's `return valid && ready` now binds valid@23:25 and ready@24:25 under
  receiver_if[0]. Golden holds exactly these two bindings. So the row moves toward golden and stays
  CMP_NOTEQUAL (evidence/tnoc_default_binding_diff_law.txt, evidence/tnoc_default_golden_get_ack.txt).
- The implementer's 10 grid case dirs reproduce on exit code, uhdm-cmp count and strict verdict
  (8 to STRICT_EQUAL, lt02 62 -> 24, gi01 byte-identical). R11U454_OFF gives pristine's bytes on all 10.

## Attack grid (50 case dirs: VL 16, VB 12, VG 12, VI 10)

- Every case is accepted by upstream slang (~/.local/bin/slang --single-unit). VI/vi08 was first written
  illegally (a use before declaration) and was rewritten in place.
- Every exit code is 0 on all three binaries (evidence/grid_{pris,law,ver}_rc.txt).
- Surelog's goldens carry no error, except VL/vl01's UH0701 on a function-scope import.
- VL/vl14, vl15 and vl16 are multi-file cases: files.lst gives the file order for both tools.
- Driver: drivers/runcase.sh <bin> <tag> <dirs>. Downstream driver: drivers/dscase.py.
- STRICT_EQUAL count: pristine 5, law 29, verified 32.

### THE BREAKS (pristine STRICT_EQUAL, law STRICT_NOTEQUAL on type; legal SV, Surelog clean)

The law's package-import closure follows edges that Surelog does not.

1. **VL/vl12** (one file, `package mid; import u::*;` written BEFORE `package u`) and **VL/vl15** (the same order
   across files mid.sv u.sv dut.sv).
   - Surelog compiles packages in source order (CompileDesign.cpp "Compile packages in strict order",
     AnalyzeFile's addOrderedPackage). So mid copies u's still-empty late list.
   - Golden keeps the foreach's int_typespec. The law bound the interface net's logic_typespec.
   - Fix **§ pkgLateTsEarlierPkgOnly454v** (UhdmExporter, `R11V454_PKGORDER_OFF`): an edge P imports Q counts
     only when Q is declared before P in the syntax trees' member order.
   - Positive control VL/vl16: the order u.sv mid.sv dut.sv still converts (NOT_EQUAL 62 -> STRICT_EQUAL).
2. **VL/vl14** (three files: `import u::*;` at file level in b.sv above `package mid`).
   - Golden does not carry u's list into mid. The law did, through the package file's file-level imports.
   - Fix **§ pkgLateTsBodyImportsOnly454v** (UhdmExporter, `R11V454_PKGBODYONLY_OFF`): only an import
     declaration written directly in the package body counts.
   - The same fix covers **VL/vl01**: an import inside a package function, where Surelog reports UH0701 and
     golden keeps int_typespec. Pristine was already wrong there, but the law moved further away (dump distance
     64 -> 68) and the verified binary gives pristine's bytes again. This is a refinement, not a break.
   - VL/vl13 is a control where pristine and law are both STRICT_EQUAL: an import of u inside another module of
     the same file does not reach mid in golden.

Switch checks:
- R11V454_OFF gives the law's bytes on all 50 dirs. R11U454_OFF gives pristine's bytes on all 50 dirs and on
  the implementer's 10.
- Each fix's own switch alone restores the law's bytes on its cases: PKGORDER on vl12 and vl15, PKGBODYONLY on
  vl01 and vl14.
- Each law's own switch alone restores pristine's bytes on every mover: LATETRANS on 9 VL, DIMBASEDLIT on 9 VB,
  GENRUNTS on 8 VG, IFCWALKALL on 10 VI.
- Determinism: vl15 and vl16 each give one hash in 4 of 4 (three concurrent draws plus the grid run).

### Per face, pristine -> verified

- **§ pkgLateTsTransitiveImport454** (VL)
  - to STRICT_EQUAL: vl03 (explicit import u::C), vl05 (module variable), vl06 (first importing instance
    after a non-importing one), vl08 (interface variable), vl09 (free package function), vl16.
  - NOT_EQUAL -> STRICT_NOTEQUAL: vl10 (type; a module net named like the loop variable), vl11 (line; the
    `export u::*` re-export).
  - closer: vl04 (three-level chain, 62 -> 24, lt02's face).
  - byte-identical controls: vl02 (file-level import already direct), vl07 (direct import too), vl12, vl13,
    vl14, vl15, vl01.
- **§ unpackedDimBasedLitKept454** (VB)
  - to STRICT_EQUAL: vb01, vb04 (function local and formal), vb05 (ports), vb06 (unpacked parameters),
    vb08 (per-instance), vb09 (package and class), vb11 (memory), vb12 (unsized signed, uppercase radix, octal,
    underscores).
  - closer:
    - vb07: the dump now differs from golden only in array_var sg's vpiSize. Golden writes -2 for
      `[3'sd2:-3'sd1]`; ours writes 4.
    - vb10: dump 139 -> 41; the head is the hier_path i.mem[16][0] select.
  - byte-identical residues: vb02 (the size form `[4'd4]`, golden DEC:4 and array vpiSize 4 where ours writes
    UINT and size 1), vb03 (struct member and typedef ranges).
  - Downstream: vb12 EQUIVALENT -> IDENTICAL. vb01, vb05, vb08 and vb11 stay IDENTICAL.
- **§ ifcTaskFixupWalksAllStmts454** (VI)
  - to STRICT_EQUAL: vi01 (a formal shadowing an interface variable), vi02 (a named-block local shadowing),
    vi03 (a return of a function local shadowing), vi04 (case and casez items), vi05 (forever, break,
    do-while, two instances), vi07 (modport import, unique case), vi08 (a wire in the condition), vi09 (an
    output formal shadowing).
  - closer: vi06 (an interface array, binds ia[0] as golden does, dump 47 -> 41), vi10 (a parameterized
    interface declared after top, 33 -> 30).
  - Downstream: vi05 and vi07 stay IDENTICAL.
- **§ genericIfcPortRunSharedTs454** (VG)
  - to STRICT_EQUAL: vg01 (three ports), vg04 (followed by typed ports), vg06 (two instances with swapped
    actuals), vg07 (positional), vg10.
  - closer, toward golden's single `a` typespec:
    - vg02 (`interface.mp a, interface b`; 248 -> 226; the head's own interface_typespec(mp) residue)
    - vg03 (an interface with generic ports, 10 lines moved to golden's typespec)
    - vg08 (a nested pass-through, 259 -> 234)
    - vg12 (c after `interface.mp b`)
  - byte-identical abstentions: vg05 (after a typed interface port), vg09 (after `input logic e`; gi01's
    face), vg11.
  - Downstream on vg01, vg04, vg06, vg07, vg10 and vg12: both lanes READ_FAIL (IDENTICAL) on both binaries.

None of the cases moves away from golden on the verified binary.

## Verified binary: one full five-stage sweep (workdir /tmp/v11u454vsw, R11U454_TRACE on)

- Every stage reads the same as the law sweep: probe 4023 + 64, surelog 480/474, uhdm2rtlil 803/1/67,
  downstream 803/66/2/0, sv-tests 1926/14 with regressions 0, conversions 2 (the same two rows) and changes 0.
- All five csvs are identical to the law sweep's.
- byteverify against the law sweep: 0 of 962, 0 of 1608 and 0 of 805 (evidence/byteverify_ver.txt).
- Trace census:
  - Neither fix fires in any stage. This was predicted before the sweep: the law's own transitive capture fires
    only on the two bidir rows and uvm_wait_for_signal, and none of them has a later-declared or file-level
    package edge.
  - In the corpora only the interface walk fires: Tnoc, FuncDeclScope, HierPathInterfBlock,
    InterfaceFuncCall and probe cases.
  - In sv-tests the four laws fire on:
    - the two bidir rows
    - uvm_wait_for_signal
    - pipelined_get_put (GENRUNTS and IFCWALKALL)
    - id_register, param_vif_config_db, ef_vif_config_db, uvm_slave_agent, uvm_slave_agent_multi_seq_item
      and tnoc (IFCWALKALL)
  - No status moves except the two conversions.
- Determinism: three concurrent draws of uvm_use_models_bidir_get_put on the verified binary give one hash,
  each STRICT_EQUAL at 685505 objects.

## Findings on the implementer's process

- The Tnoc mover was not predicted (its prediction named 0 corpus movers). It is attributed and moves toward
  golden.
- A `pkill -f` matched its own shell. The brief forbids pattern kills; the slip is recorded, and no other
  process was hit.
- One runner call overlapped the sister's census runner.

## Residues, ranked (all wrong on pristine too)

1. The four open uvm-examples rows the law reaches without converting: pipelined_get_put (the int_var vs
   array_var loop-variable face), many_to_one, id_register, param_vif_config_db. Not decoded further here.
2. The three-level chain's import-clone loop variable: lt02, VL/vl04. VL/vl10's loop variable named like a
   module net (type). VL/vl11's `export u::*` (line).
3. Based-literal bounds the law does not reach:
   - the size form `[4'd4]` (VB/vb02: golden DEC:4 and array vpiSize 4, ours UINT and size 1)
   - struct member and typedef ranges (vb03)
   - golden's vpiSize -2 for a signed range `[3'sd2:-3'sd1]` (vb07; a Surelog artefact)
   - the hier_path select i.mem[16][0] (vb10)
4. Generic-interface runs:
   - the generic modport head `interface.mp a` (VG/vg02) and a generic modport port inside a run
     (vg11, vg12's b): golden writes the run head's unsupported_typespec, ours an interface_typespec
   - a nested pass-through module's hier_path typespecs (vg08)
   - a generic port after a non-interface port (vg09, gi01)
5. Interface-walk residues: vi06's interface array and vi10's late-declared parameterized interface, at
   their next faces.
6. The carried lists of pass 452 and earlier, the 3 sfr_scoreboard rows (ParamEmit), easyUVM, the 3
   uvm_scoreboard rows, p733, p737 and tnoc.

## Sister-ground faces

None new.

## Process

- The verifier ran within the budget: one law build, one verified build, one full sweep on each. The pristine
  reading is the master's control.
- Every build and sweep started after three quiet readings. The sister r11u455's sv-tests sweep was live at
  launch, and nothing ran until it ended.
- The fence list was read into a file by a program and never printed. No tree-wide reader ran over the
  corpora, and no fenced test was named, opened or run.
- Every process stopped was stopped by task id.
