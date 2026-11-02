# v11u466: adversarial verification of r11u466 (module/type ground, pass 466)

Base e79fb32e4. The verified patch /tmp/r11u466.verified.patch is a diff against that base. It carries the implementer's six laws unchanged, two verifier refinements in src/ModuleEmit.cpp, this directory, the implementer's tools/probe/r11u466repro and the regenerated tests/LAWS.md.

## How it was measured

- The main tree had moved to HEAD fe1067e0c (passes 465 and 467, src/ParamEmit.cpp only). As the implementer did, the worktree /tmp/wt_v11u466 took fe1067e0c's src/ParamEmit.cpp and results/golden_svtests.csv for the builds and the sweeps only; neither is in the patch.
- Binaries, frozen in /tmp/v11u466_bin (evidence/binaries.md5):
  - law: the implementer's patch, rebuilt here, md5 11abac36c079ceae2dbe699570e41fe6, equal to the implementer's meas7x467; links slang 12.0.0+545f88b2e.
  - pristine: HEAD fe1067e0c built in /tmp/wt_v11u466pris, md5 c9b2f893019899967f666555de7bc9e8, equal to the implementer's head_pristine. The main tree's build/slang-uhdm had already moved to the sister's integration, so it could not serve as the pristine copy.
  - ver1: law + the two refinements, first form (md5 ffa159838a0f6f6d187ee0bbc499f265).
  - ver2: the final verified binary (md5 3f766297a57f95dde6c6eb5ec49cde7d). It widens the shadow refinement to loop variables after the away census found v11u445 VI/vi03.
- Control: the master's HEAD sweep /tmp/intr11u467. No pristine sweep was run.
- Every launch waited on drivers/quietwait.py (the implementer's script, renamed; it skips its own pid, its ancestors and the session wrapper shells).

## Verdict

CONFIRMED WITH TWO BREAKS FIXED. The row conversion reproduces bit for bit, every gate holds, and two laws had legal-SV breaks where pristine was closer to golden, both fixed behind their own switches.

| row | control (HEAD) | law | verified (ver1 sweep, ver2 sv-tests stage) |
|---|---|---|---|
| generated/uvm-examples/uvm_use_models_pipelined_get_put.sv | DIFFERENT (decompile:) | EQUAL | EQUAL, `generated/uvm-examples/uvm_use_models_pipelined_get_put.sv,EQUAL,,equal` (STRICT_EQUAL 838378 objects) |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT | DIFFERENT, same uhdm-cmp output, dump distance 961064 -> 955144 | same as law |
| generated/uvm-examples/uvm_many_to_one.sv | EQUAL | EQUAL | EQUAL |

The runner on the three rows (evidence/rows3_pristine_verified.csv): pristine NOTEQUAL/DIFFERENT, NOTEQUAL/DIFFERENT, EQUAL/IDENTICAL; verified EQUAL/IDENTICAL, NOTEQUAL/DIFFERENT, EQUAL/IDENTICAL.

## The breaks and the fixes (src/ModuleEmit.cpp, read through src/LawSwitch.h)

R11V466_OFF gives the law binary's bytes on 78 of 78 grid case dirs; R11U466_OFF gives pristine's bytes on 78 of 78.

1. § ifcDeepTransEarlierOnly466v (fixOn(466, "R11V466_DEEPORDER_OFF")), on § ifcBodyImpDeepTrans466.
   - THE BREAK: the deeper walk followed import edges to packages declared later in source order. Surelog compiles packages in source order, so such an edge copies an empty map (the rule of § pkgLateTsEarlierPkgOnly454v).
   - VD/vd02 (b imports a c declared after b): pristine 58 dump lines from golden, law 62, golden's work@ifc listing no c::c_t where the law listed it. VD/vd08 (a imports a b declared after a): pristine 22, law 28. uhdm-cmp at 94 lines on all binaries (the head is older).
   - The fix: an edge counts only when the imported package is declared earlier than the importer, the first edge (the interface's package to its import) included, the order taken from the compilation-unit members. Both cases are back on pristine's bytes.
2. § ifcEventShadowSkip466v (fixOn(466, "R11V466_EVSHADOW_OFF")), on § ifcEventTrigNet466.
   - THE BREAK: the wire's first reference was found by matching the event's name as text, so a read of a task or function formal, a block local, or a foreach or for loop variable of the same name counted.
   - v11u445 VI/vi03 (`event i;` and `foreach (sig[i]) s = s + i;`), found by the away census: pristine uhdm-cmp 29 lines and 14 dump lines; law 249 and 15, a wire golden lacks with the loop variable's read bound to it.
   - VE/ve03 (task formal), ve09 (task-local event), ve13 (function formal), ve15 (for-loop variable): STRICT_NOTEQUAL line on the law (the wire at the shadowing read), STRICT_EQUAL on the verified binary. ve14 (foreach loop variable plus a real `@i`): law depth at 14 dump lines, verified depth at 10 (the wire now at golden's 8:6; the loop variable's read still binds the wire, residue 4).
   - The fix: a name declared again in a task or function (formal or local), a begin or fork block, a foreach loop list or a for-loop initializer is skipped inside that scope. vi03 on the verified binary: 29 uhdm-cmp lines as pristine, 8 dump lines (the named_event golden lists, no wire).

Neither fix touches UhdmExporter, TypeEmit, TaskFuncEmit, the sister's files, include/ or uhdm_main.cpp. No src/R*.h, no getenv; each fix logs through lawTrace(466, ...).

## Gates

### Law binary: one full five-stage sweep (/tmp/v11u466law)

- probe EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions=0 conversions=0 changes=0; csv identical to the control.
- surelog default 480 + testflags 474 CMP_EQUAL, 0/0/0; csv differs from the control only in the two LowMem log-path texts.
- uhdm2rtlil 803/1/67 in both modes, 0/0/0; csv identical.
- downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2 of 871, not excused 0; csv identical.
- sv-tests (the main tree's scripts/check_svtests.py with HEAD's baseline, since the worktree's UVM folder is empty): EQUAL 1932, DIFFERENT 8, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions=0 conversions=1 changes=0; the csv differs from the control on pipelined_get_put only.
- byteverify against the control (SELFCHECK=1): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805, each self-check flagging n-1.
- Kept sv-tests databases: 29, all differing from the control in raw bytes; 28 STRICT_EQUAL under uhdm-strictcmp --no-canon, the 29th param_vif_config_db (same uhdm-cmp output, dump distance 961064 -> 955144).
- Canaries ok=52 and ok=16; ctcan2 PASS on both (ok=58 with 1 unknown pattern, ok=2 with 6).
- Binary audit, fence-filtered: surelog 1523 of 1573 records name the law binary (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346; no other binary named.
- Every implementer headline number reproduced.

### Verified binary

- ver1, one full five-stage sweep (/tmp/v11u466ver): the five csvs equal to the law sweep's (sv-tests on its first four columns); byteverify ver1 against law 0 of 962, 0 of 1608, 0 of 805, and against the control the same; probe 0 of 4087 raw-byte movers against the law sweep; the 29 kept sv-tests databases all STRICT_EQUAL to the law's under --no-canon. Canaries ok=52 and ok=16, ctcan2 PASS on both, binary audit 1523/1573, 1740/1740, 2346/2346 naming ver1.
- A probe pass of ver1 through the main tree's scripts/check_probe.py (main-tree paths, so raw bytes compare with the control): 0 of 4087 movers, csv identical.
- ver2 differs from ver1 only inside the wire walk of § ifcEventTrigNet466, which runs only for an elaborated interface that declares an event. That law adds a named_event wherever it fires, and the law and ver1 sweeps read 0 movers on all four corpora, so it fires on none of them and ver2's bytes there are ver1's. ver2 was therefore measured on the affected stage alone:
  - sv-tests (/tmp/v11u466ve2): EQUAL 1932, DIFFERENT 8, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions=0 conversions=1 (pipelined_get_put DIFFERENT -> EQUAL) changes=0; the csv equal to the law sweep's on its first four columns; the 29 kept databases STRICT_EQUAL to ver1's under --no-canon; the audit names ver2 in 2346 of 2346 records.
  - probe through the main tree's scripts/check_probe.py (/tmp/v11u466pr2): EQUAL 4024 + 63, csv identical to the control, 0 of 4087 raw-byte movers against the control.

### Predicted before the verified sweep (evidence/prediction_fixes.txt)

No byte mover on any corpus, probe case or sv-tests row: the deeper walk fires nowhere in the corpora, and the event law fires on pipelined_get_put alone, whose `->do_data_phase;` is in a task declaring no local or formal of that name. Held on ver1 and ver2.

## Determinism

pipelined_get_put's recorded command, rerun against the cached golden (evidence/determinism_pipelined_get_put.txt): every draw on every binary reads uhdm-cmp 0 and STRICT_EQUAL 838378 on law and verified. The raw bytes take two hashes on every binary, PRISTINE INCLUDED: verified 12 draws 9 + 3, law 3 draws 2 + 1, pristine 9 draws 7 + 2. Each time the two hashes differ in 6 bytes, two value swaps, with identical uhdm-dump output and STRICT_EQUAL under --no-canon. It is a standing variance of this row, not this pass's. The implementer's "one md5 in 3 draws" was a lucky draw.

## Grids

### The implementer's 27 case dirs

On exit code, uhdm-cmp count and strict verdict, both grids match the implementer's exactly: pristine 3 STRICT_EQUAL, law 17, and the same 6 byte-identical dirs (EV/ev03, GP/gp02, gp06, IK/ik03, ik07, UG/ug03). The raw md5s differ because the case path is written into VpiFile. ver2 gives the law's bytes on all 27.

### Attack grid: 51 case dirs in VD, VE, VG, VK, VM and VU

- Upstream slang accepts all 51 (evidence/upstream_slang.txt). Every exit code is 0 on all three binaries.
- Surelog first rejected two drafts, VE/ve05 (an event-array trigger, a syntax error) and ve11 (an event in a modport, internal error UH0703). Both were rewritten before any measurement.
- Table: evidence/attack_grid.txt (pristine, law, verified; dump distance pristine -> verified).
- 30 STRICT_EQUAL on the verified binary against 3 on pristine, so 27 are new; the law binary reaches 26.
- 15 byte-identical: VD/vd02, vd03, vd06, vd08, VG/vg03, vg04, vg08, VK/vk07, vk08, vk09, VM/vm02, vm06, VU/vu01, vu02, vu03.
- 9 movers that do not convert, every one closer by dump distance:
  - VD/vd07 64 -> 62;
  - VE/ve05 76 -> 69 (uhdm-cmp 17 -> 910 with the head now the interface instance: golden lists the event array `ea [2]` as a named_event, ours an array_var on every binary);
  - VE/ve06 28 -> 14;
  - VE/ve14 25 -> 10;
  - VK/vk01 59 -> 49, vk02 34 -> 22, vk04 92 -> 58, vk11 74 -> 54;
  - VM/vm05 12 -> 8.
- By law:
  - § ifcEventTrigNet466 holds on two instances (ve01), parameterized instances (ve07), a generate loop (ve10), a hierarchical trigger (ve04), `.triggered` (ve02), `@(ev or posedge clk)` (ve08), a generic-port reader (ve11) and two events (ve12).
  - § genIfcViewSharesParamAssigns466 takes an overridden header parameter, two differently parameterized instances, two ports on one instance, a type parameter and a parameterized reader (VG/vg01, vg02, vg05 to vg07) from STRICT_NOTEQUAL depth to STRICT_EQUAL. It does not fire on a modport generic port (vg03), an interface-array element (vg04) or a reader in a generate block (vg08).
  - § transImpClassKeys466: a diamond (vk03), body imports (vk05, vk06) and two module instances (vk10) reach STRICT_EQUAL. It abstains correctly on a later-declared package (vk07), an explicit middle import (vk08) and a same-named class in the direct package (vk09).
  - § emptyListClassKeys466: vm01, vm03 and vm04 reach STRICT_EQUAL; a body import (vm02) is not taken; a program (vm05) moves closer.
  - § ifcBodyImpDeepTrans466 with the fix: vd01, vd04 and vd05 reach STRICT_EQUAL.
  - § unitGroupKeepsHomeOrder466 fires on none of vu01 to vu03.

### Switch checks

- R11U466_OFF on ver2 gives pristine's bytes on 78 of 78 dirs. R11V466_OFF gives the law binary's bytes on 78 of 78.
- R11V466_DEEPORDER_OFF alone restores the law's bytes on vd02 and vd08. R11V466_EVSHADOW_OFF alone restores them on ve03, ve09, ve13, ve14 and ve15.
- On the law binary, every attack mover is restored by its own law's switch alone (evidence/attack_switchcheck_law.txt), except VM/vm04, which needs TRANSCLSKEYS and EMPTYLISTKEYS together.

### Away census (evidence/away_census.txt)

2526 earlier case dirs of passes 440 to 464 and their verifier twins, single-file, fence-filtered, pristine against ver1 with absolute paths:
- 2470 exit 0 byte-identical, 25 exit 4 on both, 16 exit 3 differing as exit-3 dirs do on any binary;
- 15 exit-0 movers, judged against their goldens on ver2 (evidence/away_judged_ver1.txt and away_movers_ver2.txt).
  - 7 reach STRICT_EQUAL: r11u450 FL/fl01; v11u450 VF/vf01, vf02, VT/vt03, VW/vw07; v11u452 VK/vk01, vk02; v11u460 VS/vs06.
  - Closer by dump distance: r11u452 CK/ck01 34 -> 14, r11u456 WT/wt04 109 -> 96, r11u463 MO/mo08 166 -> 162, v11u456 VW/vw11 52 -> 37, and v11u445 VI/vi03 14 -> 8 once fixed (the law's break above).
  - v11u463 VG/vg06 and vg14, 230 -> 230 lines: § emptyListClassKeys466 lists the specialization group object in module top, where golden lists the same object. Ours names it a::a_seqr where golden names it b::aa_unit_seqr, pass 463's standing residue.
  - None moves away on ver2.

### Downstream

Nine sampled attack cases through the downstream machinery (evidence/downstream_samples.txt): VK/vk03, VD/vd01, vd02, VM/vm01 IDENTICAL on both binaries, VG/vg01 and vg02 IDENTICAL on both (both READ_FAIL), and the event cases VE/ve01, ve12, ve15 EQUIVALENT on pristine (nohier differs) -> IDENTICAL on the verified binary. None moves away.

## Residues (ranked; all wrong on pristine too, none moved away on the verified binary)

1. The 8 DIFFERENT sv-tests rows: param_vif_config_db's class-local this_t (a Surelog artefact), easyUVM, the three uvm_scoreboard rows, and p733, p737 and tnoc (await the user's decision).
2. Interface event arrays: golden lists `event ea [2]` as a named_event spanning the declarator with its dimension, ours an array_var on every binary (VE/ve05). An event with an initializer `event e2 = e1;`: golden spans the named_event to the initializer's end, and orders the wires by process references before the initializer's reference (ve06).
3. pipelined_get_put's raw bytes vary in 6 bytes between runs on every binary, pristine included (see Determinism); not decoded.
4. A foreach loop variable named like an interface event that is also referenced: the read binds the minted wire where golden binds the loop variable's logic_var. This is pass 445's interface loop-variable binder looking the name up among the instance's nets (VE/ve14, STRICT_NOTEQUAL depth).
5. Class keys:
   - per-use typedef-alias copies (VK/vk04, as the implementer's IK/ik01, ik04);
   - a middle package's own typedef beside a transitive class key, where golden's work@ifc definition head differs (VK/vk01, vk02);
   - a body import into an interface of a class-only package (VM/vm02, not taken);
   - a program importer (VM/vm05);
   - a class specialization constant (VK/vk11, an older face).
6. A middle package importing a later package while also reaching typedefs through an earlier one: the module branch lists the later package's typedef (VD/vd07). A module importer does the same on pristine (VD/vd06). This is the module branch's own transitive listing, which predates pass 466.
7. Generic interface port views the law does not take: modport generics (VG/vg03), interface-array elements (vg04) and readers in a generate block (vg08).
8. The implementer's residues stand: IK/ik01, ik02, ik04, ik07, ik08, GP/gp04, UG/ug01 to ug03, and the carried lists of passes 464 and earlier.

## Sister-ground faces

None found.

## Process

- Two builds in the worktree (law, then ver1 and ver2 incremental) and one pristine build of HEAD. The main tree's binary had moved to the sister's integration, so a HEAD pristine was built rather than copied.
- Two full five-stage sweeps (law, ver1). The narrowed ver2 was measured on the affected sv-tests stage alone, plus a probe pass and the grids. Every launch waited for a quiet machine.
- The fence list was read from canaudit.sh's FENCED= line into a file by a program, never printed. Every tree-wide list was filtered on it before any file was opened.
- No other agent's process was touched. Another agent's wait loop, seen in a quiet check, was left alone.

Files:
- cases/ (51 dirs in VD, VE, VG, VK, VM, VU);
- drivers/ (env.sh, runcase.sh, switchcheck.sh, dist.sh, awaycensus.sh, quietwait.py);
- evidence/ (grids on all binaries, attack_grid.txt, switch checks, upstream slang, the prediction, sweep logs and csvs, byteverify, kept databases, determinism, away census, downstream samples, binaries.md5).
