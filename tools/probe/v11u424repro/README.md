# v11u424 — adversarial verification of r11u424

Base 556047d2e.  Implementer's patch /tmp/r11u424.patch (module/type ground:
src/ModuleEmit.cpp, src/TypeEmit.cpp, src/UhdmExporter.cpp,
src/TaskFuncEmit.cpp, tests/LAWS.md, tools/probe/r11u424repro).

**Verdict: VERIFIED, no production refinement.**  Every headline number of
r11u424 reproduces bit for bit, and 124 fresh case dirs found no shape on legal
SV where pristine was right and the law is wrong.  The verified patch
(/tmp/r11u424.verified.patch) carries the implementer's four source files
byte-identical, plus this directory and tests/LAWS.md regenerated for it.

## Binaries

| binary | md5 | note |
|---|---|---|
| /tmp/v11u424_bin/pristine | 3ee8999f424a2bdc9c6378d0ba960e77 | the main tree's build/slang-uhdm at the base (no pristine build, per the budget) |
| /tmp/v11u424_bin/law | c623a2128527ff4453411543a280fc43 | rebuilt once in /tmp/wt_v11u424 from the patch (-j 2); equal to the implementer's law21 |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | the same as the main tree's and the implementer's |

The law binary reports slang 12.0.0+545f88b2e and UHDM 1.87.

## Audit

- Surface: src/ModuleEmit.cpp, src/TypeEmit.cpp, src/UhdmExporter.cpp,
  src/TaskFuncEmit.cpp, tests/LAWS.md and tools/probe/r11u424repro only.  No
  ExprEmit, StmtEmit, ParamEmit, EmitHelpers.h, include/ or uhdm_main.cpp change.
- In the added lines there is no getenv, no src/R*.h and no reader function.
  There are 16 `lawOn(424, "R11U424_<X>_OFF")` reads (the implementer's report
  says 17).  They cover 15 switches, with R11U424_TPRETOOB_OFF read twice.
- **Trace gap.** § ifcProcCallArgNoTs424 (R11U424_IFCARGTS_OFF) has no
  `lawTrace` call, so its firings are absent from every trace census.  Its
  attribution here comes from its switch.  On both 16.12 rows,
  R11U424_IFCARGTS_OFF alone gives NOT_EQUAL, the same as dropping
  R11U424_IFCASSERT_OFF or R11U424_IFCUNITVAR_OFF alone.  Dropping
  R11U424_COVERCLK_OFF keeps STRICT_EQUAL at 414886 objects, so all three
  interface laws are needed on both rows and coverClocked is not.  Its byte
  effect on the corpora is bounded by byteverify: the only movers are Tnoc
  default and testflags, and the trace attributes those to
  § defGenConnPsExprBounds424.
- This law also sets ExprEmit's `defOnlyDefEmit`.  Its only reader is the
  formal-typespec stamp in ExprEmit.  **Cross-pass risk:** if the sister pass
  423 adds another reader of that flag, this window would gate it too.
- Law index: the implementer's tests/LAWS.md is current on a fresh base plus
  the patch (`scripts/law_index.py --check` passes).  It is regenerated here
  for the 124 cases this directory adds.
- Fence: the list was read from canaudit.sh's FENCED= line by a program into
  /tmp/v11u424_fenced.txt and never printed.  Every tree-wide list (cmds.txt
  audit, the earlier-pass census) was filtered on it before any file was
  opened.  No fenced test was named, opened or run.

## Reproduction of the implementer's numbers (law binary, one five-stage sweep)

The sweep was drivers/fullsweep.sh with workdir /tmp/v11u424wd and trace
/tmp/v11u424_trace.  It ran 22:47 to 23:14 on 2026-10-20 and was launched after
three quiet readings.  The sister verifier v11u423's own waiter script was alive
but stuck in its quiet loop, matching its own name, so no sister sweep ran
during this one.

| stage | result | vs control /tmp/intr11u422 | vs implementer /tmp/r11u424wd |
|---|---|---|---|
| probe | EQUAL 4018 + STRICT_NOTEQUAL 69, regressions/conversions/changes 0/0/0 | csv byte-identical | byte-identical |
| surelog | default 480, testflags 474 CMP_EQUAL; 0/0/0 | differs only in the two LowMem log-path texts | same two texts |
| uhdm2rtlil | 803/1/67 in both modes; 0/0/0 | byte-identical | byte-identical |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 | byte-identical | byte-identical |
| sv-tests | regressions=0 conversions=20 changes=0; EQUAL 1880, STRICT_NOTEQUAL 2, DIFFERENT 58, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | — | **csv byte-identical on all 2346 rows**; the same 20 conversions |

The 20 conversions are listed below as "row: before -> after (law)".
`differ:<field>(<n>)` is the strict verdict with the number of differing
objects.

- chapter-16/16.12--property-interface-uvm.sv and -prec-uvm.sv: DIFFERENT -> EQUAL (§ ifcConcAssertListed424, § ifcUnitVarRefMintsNet424 and § ifcProcCallArgNoTs424; each switch alone breaks the row)
- generated/basejump bsg_async_fifo, bsg_launch_sync_sync, bsg_sync_sync, bsg_cache, bsg_tag_trace_replay and bsg_nonsynth_mem_1rw_sync_mask_write_byte_assoc: DIFFERENT -> EQUAL (§ defGenConnIpsExprBounds424)
- bsg_mem_1rw_sync_mask_write_var and bsg_mem_1r1w_sync_mask_write_var: DIFFERENT -> EQUAL (§ defGenConnPsExprBounds424)
- bsg_mul_array and bsg_nonsynth_dramsim3: DIFFERENT -> EQUAL (§ defGenConnVarSelRange424)
- bsg_pipeline_stall_collapse: DIFFERENT -> EQUAL (§ genForCompoundStep424)
- bsg_wormhole_router_decoder_dor: STRICT_NOTEQUAL differ:fullname(1) -> EQUAL (§ defGenLpSelIdxThroughBase424)
- bsg_mesh_router: STRICT_NOTEQUAL differ:col(1) -> EQUAL (§ defGenLpSysArgBitSelAtIndex424)
- hdlconvertor_std2012_p88 and hdlconvertor_std2017_p124: DIFFERENT -> EQUAL (§ tpVarInitSizedByDefault424)
- generic/class/class_test_51.sv: DIFFERENT -> EQUAL (§ classParamBitsKeywordFold424)
- hdlconvertor_std2017_p193_2: DIFFERENT -> STRICT_NOTEQUAL differ:line(3) (§ tpRetOobRefVar424)
- hdlconvertor_std2017_p600: DIFFERENT -> STRICT_NOTEQUAL differ:fullname(6) (§ boundSizedLitKept424)

**byteverify** (SELFCHECK=1, law workdir against the master's control):

- surelog: **2 of 962** movers, Tnoc default and testflags.  Their bytes are
  identical to the implementer's law sweep (21652dd0f95d / 1ab6f4f0341d).
- uhdm2rtlil: 0 of 1608.  downstream: 0 of 805.
- Path sets were identical in all three.  The selfcheck flagged 961 of 962,
  1607 of 1608 and 804 of 805.

**Canaries:** ok=52 (surelog) and ok=16 (uhdm2rtlil).  ctcan2 PASS on both:
ok=58 with 1 unknown pattern, and ok=2 with 6 unknown patterns.

**Binary audit** (cmds.txt, fence-filtered):

- surelog: 1523 of 1573 name /tmp/v11u424_bin/law.  The other 50 are
  SURELOG_FAIL rows holding only a Surelog line.
- uhdm2rtlil: 1740 of 1740.  sv-tests: 2346 of 2346.

**Trace census** (/tmp/v11u424_trace, by output database).  It is the same as
the implementer's.

- Corpus: FuncStructVal and Tnoc, default and testflags
  (§ defGenConnPsExprBounds424; FuncStructVal's bytes are unchanged).
- Probe cases, all still EQUAL:
  - r11u112repro p06_seq_body and v11u113repro r09_two_props (§ coverClockedPropExprIsClock424)
  - r11u35repro g3_shape35 (§ boundSizedLitKept424)
- sv-tests: the 20 converted rows, plus these rows that did not convert:
  - bsg_cache_non_blocking_data_mem and bsg_round_robin_fifo_to_fifo
  - tnoc and rsd
  - the six black-parrot rows and p612
  - class_test_49

**Away census on sv-tests.**  81 rows keep a database in both the law sweep and
the control.  A path-normalized dump compare (drivers/svnd.sh) found:

- 73 identical.
- 8 moved, exactly the non-converting trace rows plus p193_2 and p600:
  - non_blocking_data_mem: uhdm-cmp 228 -> 228
  - round_robin_fifo_to_fifo: 80 -> 80
  - tnoc: 28 -> 28, the same head
  - class_test_49: 16 -> 36.  The head moved later in the walk, from the
    `parameter reg P` logic_typespec at 26:13 (this law's face, now written) to
    the sister's `f(glb::arr[N])` bit_select at 27:29.
  - rsd and p612: no golden.
- None moved away from golden.

**Determinism.**  Three concurrent draws of 16.12--property-interface-uvm on the
law binary, plus the switch run, give one hash (04e71b12dd32) in 4 of 4.

## Implementer's grid (87 case dirs) — reproduced line for line

drivers/grid.sh uses its own golden cache under /tmp/v11u424_scr/gold.  All 87
lines match evidence/grid_law21.txt on every field: exit code, uhdm-cmp line
count, strict verdict and md5, for pristine and for law.  R11U424_OFF gives
pristine's bytes on 87 of 87.  Each case's own switch gives pristine on 80; the
same 7 as the implementer's (CB/cb02, CP/cp04, PB/pb07, UC/uc05, UI/ui06,
ui09, ui12) need a co-firing switch too.  See evidence/grid_impl_reproduced.txt.

## Attack grid: 124 fresh case dirs (cases/, every one accepted by upstream slang, every exit code 0)

Each case's first line names its law.  Goldens come from Surelog v1.87
(`-parse -nobuiltin -nocache -sv`).  One more case, VG/vg03 (`i += S` with a
parameter step), was dropped: Surelog never finishes it within 300 s, so it has
no golden.

| group | law | cases | pristine -> law |
|---|---|---|---|
| VI | § ifcConcAssertListed424 | vi01-vi16 (labelled assert + always, two instances; generate loop of instances; cover + assume; named property; parameterized instances; modport port view; instances in two parent modules; default clocking; interface array; generate inside the interface; action blocks + assert final + immediate assert; uninstantiated interface; $unit var in action + cover sequence; nested interface; two instances + two port views; module assertion beside it) | 3 NE->SE (vi05, vi06, vi15), vi02 NE->SN line, 11 NE both toward golden (vi12 abstains at pristine bytes) |
| VU | § ifcUnitVarRefMintsNet424 | vu01-vu12 | 8 NE->SE, vu07 SE control byte-identical, vu10 toward, vu02/vu08 abstain at pristine bytes (a same-named local in the interface) |
| VX | § ifcProcCallArgNoTs424 | vx01-vx05 | 3 NE->SE, vx02 SE control byte-identical, vx04 toward |
| VC | § coverClockedPropExprIsClock424 | vc01-vc11 (default clocking, restrict, cover sequence + action, named property, disable iff, beside an assert, procedural cover, generate, begin-end action, program, named sequence) | 8 NE->SE, vc04/vc07 SE controls byte-identical, vc10 (program) toward |
| VL | § defGenLpSelIdxThroughBase424 | vl01-vl05 | 3 SN fullname -> SE, vl05 SE control, vl02 toward |
| VB | § defGenLpSysArgBitSelAtIndex424 | vb01-vb03 | 2 SN col -> SE, vb02 toward |
| VF | § defGenConnIpsExprBounds424 | vf01-vf10 | vf04 NE->SE, vf01/vf06 NE->SN endcol, 5 toward (vf02, vf03, vf08 comment inside a bound, vf10 macro argument), vf05/vf07/vf09 plain bounds at pristine bytes |
| VS | § defGenConnPsExprBounds424 | vs01-vs09 | vs06 NE->SE, vs03 NE->SN fullname, vs01/vs04/vs07/vs08 toward, vs02/vs05/vs09 at pristine bytes |
| VM | § defGenConnVarSelRange424 | vm01-vm06 | 4 NE->SN fullname (vm01, vm02, vm04, vm05), vm03/vm06 toward |
| VG | § genForCompoundStep424 | vg01, vg02, vg04-vg07 (`-=`, `*=`, nested `+=`, `/=`, `i = i + 2` control, if/else body) | 5 NE->SE, vg06 SE control byte-identical |
| VT | § tpVarInitSizedByDefault424 | vt01-vt11 (byte default masked 300, logic [3:0] default, int default narrowed to shortint, U = T default, interface, package typedef default, generate + unary, two overrides, W-dependent default, logic [39:0] override with sized/'1 inits, instances under two parents) | 7 NE->SE, vt10 toward, vt04/vt05/vt07 at pristine bytes |
| VK | § boundSizedLitKept424 | vk01-vk11 (variables, ports, struct member, function return/argument, module typedef in an instance, unpacked dims, class property, generate + enum base, parameter type + instance, package typedef across a port, 32'd/7'b/3'o) | 8 NE->SE, vk04 SE control, vk02/vk06 toward |
| VP | § tpRetOobRefVar424 | vp01-vp06 | vp02/vp04 NE->SN line, vp01/vp06 toward, vp03 (class default) and vp05 (in-body) at pristine bytes |
| VQ | § classParamBitsKeywordFold424 | vq01-vq06 (shortint/longint/integer/byte, logic [7:0] and bit, header parameter + product + int unsigned, package class, reg and logic signed [3:0], type parameter beside it) | 6 NE->SE |
| VW | § classParamWrittenKwTs424 | vw01-vw07 | 5 NE->SE, vw05/vw07 (time, real, integer unsigned, longint unsigned) toward |

The table abbreviates verdicts as NE = NOT_EQUAL, SE = STRICT_EQUAL and
SN = STRICT_NOTEQUAL.

**Totals over 124:**

- 55 NOT_EQUAL -> STRICT_EQUAL
- 5 STRICT_NOTEQUAL -> STRICT_EQUAL
- 10 NOT_EQUAL -> STRICT_NOTEQUAL
- 8 STRICT_EQUAL controls, byte-identical to pristine
- 46 NOT_EQUAL on both:
  - 33 toward golden by path-normalized dump distance (multiset and
    sequential, evidence/attack_unequal_dist.txt)
  - 13 abstentions byte-identical to pristine
  - none away

**Switches.**  R11U424_OFF restores pristine's bytes and exit code on 124 of
124.  Each case's own switch restores pristine on 118.  The other 6 need a
co-firing switch too:

- VB/vb02, VQ/vq03, VQ/vq04 (CLSPARAMKW + CLSBITSKW)
- VI/vi13, VU/vu10 (IFCASSERT + IFCUNITVAR)
- VX/vx03 (IFCARGTS + IFCASSERT)

**Downstream** (scripts/downstream_uhdm2rtlil.py `one()` on the 96 class-free
cases, both binaries):

- 66 IDENTICAL on both
- 22 EQUIVALENT -> IDENTICAL: 13 VI, 7 VU, VX/vx03 and VK/vk11
- 6 EQUIVALENT on both
- 1 DIVERGENT on both
- 1 SURELOG_FAIL on both
- None worse (evidence/downstream_attack.txt).

## Earlier-pass census (pristine against law, byte level)

The census covers 3106 fence-filtered case dirs with a dut.sv under
tools/probe/r11u401repro to r11u422repro and v11u401repro to v11u422repro
(drivers/bytes.sh).

- 3069 are byte-identical at the same exit code.
- **37 move, with no exit code changing.**  Each mover was judged against its
  Surelog golden (evidence/census_movers_judged.txt):
  - 18 -> STRICT_EQUAL: r11u407 BK bk01, bk02; r11u413 TP tp01, tp03, tp04;
    r11u415 GL gl01, gl02 and RG rg01, rg03; r11u421 rf01, rt01; v11u406
    vq07, vq08; v11u408 VG vg04, vg12; v11u418 VU/vu08; v11u420 VS vs12, vs23.
  - bk05 NOT_EQUAL -> STRICT_NOTEQUAL.
  - gl06 STRICT_NOTEQUAL from 3 differing objects to 2.
  - gl05 and gs04 strict-identical to pristine with moved bytes.
  - 15 NOT_EQUAL on both, every one toward golden by dump distance or at the
    same distance (gs04).
- **None away.**

## Residues (ranked; every one was wrong on pristine too)

1. **The part_select of § defGenConnVarSelRange424 in the elaborated
   copies.**  Golden names it through the instance and the formal; the law
   names it through the var_select.  On VM/vm01, vm02, vm04 and vm05 and the
   implementer's VR/vr02, golden writes
   `work@top.g[0].u.p.pa.pa` and ours writes `work@top.g[0].pa.pa`, and its
   references follow the same pattern.  This is the next face for this law; it
   holds those cases at STRICT_NOTEQUAL fullname.
2. **The elaborated fold of an indexed part-select base built from syntax.**
   VF/vf01 and vf06 read STRICT_NOTEQUAL endcol: golden's INT constant spans
   `(i+1)*W` (5:25-5:32) and ours ends at 5:26.  This is the implementer's
   residue 2 (the elaborated port-connection folds).
3. **Interfaces connected positionally.**  The interface instance lists a
   ref_module, or its assertion's references are located at the actual
   argument and not at the port declaration (VI/vi01, vi02, vi03, vi09, vi10,
   vi11, vi16; the implementer's IA/ia01 and ia03).  This is the largest
   interface face left, and §ifcConcAssertListed424 cannot reach STRICT_EQUAL
   there until it is fixed.
4. **Interface items that §ifcConcAssertListed424 does not complete:**
   - a named property declared in the interface (vi04, head at the interface
     definition)
   - a default clocking block (vi08)
   - a nested interface (vi14)
   - an uninstantiated interface's definition listing (vi12; the law abstains)
5. **tpRetOob line(3).**  The prototype ref_var's typespec should be the type
   parameter's default typespec (VP/vp02, vp04; p193_2).
6. **cover in a program** (VC/vc10).
7. **tpVarInit not reached:**
   - an interface's variable (VT/vt05)
   - a type parameter defaulting to another type parameter (vt04)
   - generate-scope variables and unary initializers (vt07)
8. **Class parameters of time, real and unsigned keyword types** (VW/vw07), and
   a `logic [3:0]` class localparam (vw05).
9. **The implementer's own ranked residues** stand as stated: the
   default-less placeholders, the elaborated port-connection folds, p599,
   default-value, p600 fullname(6), cv04, bv06/cp03, ui03/ui05, IA/ia03,
   PS/ps02 and the carried backlog.

## Sister-ground faces (reported, not written)

- class_test_49's next head: `f(glb::arr[N])`.  ExprEmit names the package
  array select's index through the select.
- The faces the implementer reported (ParamEmit's 1<<16 copies and the class
  param_assign copy's ref_typespec) are unchanged.
- § ifcProcCallArgNoTs424 writes ExprEmit's `defOnlyDefEmit` flag from
  ModuleEmit (see Audit).

## Process

- Worktrees: /tmp/wt_v11u424 (law), and /tmp/wt_v11u424pris, used only to
  check the implementer's law index on a fresh base + patch.  It was not built.
- Scratch: /tmp/v11u424_*.
- Within the budget: one law build, one full five-stage sweep, no refinement,
  no second sweep.  The pristine reading is the master's control
  /tmp/intr11u422.
- The grids, downstream case runs and earlier-pass census ran while no sweep
  was live, or alongside my own sweep at low parallelism.  No TIMEOUT or load
  artefact appeared: the sv-tests csv is identical to the implementer's.
- Slip: drivers/run1.sh keys its output directory on the path after
  `/cases/`.  The earlier-pass census therefore overwrote the outputs of two
  of my cases that share a key with older cases (VU/vu08, VL/vl02) after their
  grid lines were recorded.  Both were rerun, and their distances in
  evidence/attack_unequal_dist.txt are from the rerun.  No grid line was
  affected.
- No other agent's process was touched.
