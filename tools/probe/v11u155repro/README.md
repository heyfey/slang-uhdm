# v11u155: adversarial verification of r11u155 (the module/type ground, pair B refill after pass 152)

Base `78f8134a` (branch matrix-1.87). This pass verifies the implementer's patch `/tmp/r11u155.patch`
(`tools/probe/r11u155repro/README.md`: eleven laws under twelve `R11U155_*_OFF` switches in `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp`, `src/UhdmExporter.cpp`). It adds two refinements for breaks found by fresh cases.

**Verdict: VERIFIED WITH TWO REFINEMENTS.**
- Every headline number reproduces bit for bit.
- Fresh cases found two breaks where pristine was right and the patch was wrong. Both are on legal SV and both are
  invisible to the corpora. Each is fixed behind its own switch (section 3).
- The shipped patch is `/tmp/r11u155.verified.patch`: the implementer's patch, plus the two refinements, plus this
  directory.

The four slang-fenced tests are named nowhere here. No binary, gdb session or script ran on their sources. The
attribution reruns used a positive whitelist of the moved tests' names.

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/v11u155_bin/pris.bin` | `3b033b63958f68a1837d254512b79a3e` | worktree `/tmp/wt_v11u155pris` at 78f8134a (system-deps config, `-j 2`); the brief's pristine md5 |
| `/tmp/v11u155_bin/law.bin` | `9539451580d1a22a2a38a8086d11a8b7` | 78f8134a + `/tmp/r11u155.patch`; byte-identical to the implementer's `law2.bin` |
| `/tmp/v11u155_bin/ver.bin` | `782c30e99a3f347fe52e5edfc58dfcd9` | law + the two refinements of section 3 (the shipped patch) |
| `/tmp/v11u155_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator (identical in both worktrees and the main tree) |

Audit of `cmds.txt`: 3273 of 3273 `slang:` lines name the right binary in each sweep. The pristine sweep names
`pris.bin`, the law sweep `law.bin` and the verified sweep `ver.bin`. The sweeps are `/tmp/v11u155_sw{P,L,V}` (same
length) and were run with `drivers/sweep.sh` = `tests/sweep.sh --jobs 3`, with `SLANG_UHDM` and `STRICT_CMP` exported.

## 2. The implementer's numbers, reproduced

| gate | pristine `swP` | law `swL` | verified `swV` |
|---|---|---|---|
| probe vs golden_probe.csv | 0/0/0, EQUAL 2491 / STRICT_NOTEQUAL 1596 | regressions 0, conversions 8, changes 67 (EQUAL 2499 / 1588) | same as law, csv identical |
| surelog vs golden_surelog.csv | CMP_EQUAL 417/416 (d/t) | regressions 0, conversions 10, changes 3; CMP_EQUAL 422/421 | same as law, csv identical |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | CMP_EQUAL 736/736 | regressions 0, conversions 10, changes 2; CMP_EQUAL 741/741 | same as law, csv identical |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0 | same; csv identical to pristine's and to results/downstream_uhdm2rtlil.csv | same |

Notes on the table:
- **Pristine surelog CHANGE.** The pristine surelog stage printed one CHANGE: `Earlgrey_0_1 default differ:line(1738)
  -> differ:?`. The comparator did not finish that pair while six sweep jobs ran. A rerun on the same pristine database
  reads `STRICT_NOTEQUAL line` with `objects_differing=1738`, so this is environment. In the law and verified sweeps
  Earlgrey reads `differ:line(1738)` in both modes.
- **Law-index exit code.** Every sweep exits 1 only on the law-index check. At 78f8134a the pristine worktree's
  `scripts/law_index.py --check` already reads STALE. With the patch applied, it reads `law index current`.

**Conversions** (the fresh rows read `<name>,<mode>,CMP_EQUAL,,,equal`, in both modes):
- surelog: GenForIfaceLocalparamBound, GenForIfaceLocalparamNestedGen, IfGenTypeBinding, ImplicitArg, UnpackPort.
- uhdm2rtlil: OneNetModport, PatternStruct, genscope_module_ctx_reset, iface_sig_in_child_port, union_param_repro.

**Changes:**
- SimpleConstraint d/t: `endcol(4) -> endcol(2)`.
- YosysBigSimEllip d: `fullname(2941) -> type(1)`. Record #70374 (`part_select C` against our `constant`) is already
  present in the pristine walk (`evidence/sweeps/yosysbigsimellip_pris_70374.txt`: 681189 vs 681181 objects on both
  sides).
- const_cast_signext d/t: `line(15) -> line(5)`.
- 67 probe changes. 66 of them lower the count on the same first field. `r11v1repro/vA` reads `endcol(2) -> depth(1)`:
  the pristine walk lists #253 endcol and #292 depth, and the law clears #253 only.

**Downstream rows of the converted tests** (fresh, law and verified):
- `union_param_repro,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
- `genscope_module_ctx_reset,IDENTICAL,OK,OK,11,11,,`
- `PatternStruct,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
- `OneNetModport,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
- `iface_sig_in_child_port,IDENTICAL,OK,OK,2,2,,`
- `const_cast_signext,IDENTICAL,NO_GATES,NO_GATES,0,0,,`

**Byte movers, law vs pristine** (`evidence/sweeps/byteverify_law_vs_pris.txt`; SELFCHECK 1607/1608 and 959/960):
- uhdm2rtlil: 12 movers, the six converted or changed tests in both modes.
- surelog: 24 movers:
  - the 14 attributed ones;
  - Earlgrey_0_1 d/t;
  - OneNetModPort d/t;
  - Rggen d (testflags is SURELOG_FAIL);
  - the UVM coin family: MiniAmiq d/t, SeqDriver d/t, Scoreboard d, SimpleUVM t. Order-blind, each reads 4 dump lines
    (Scoreboard 0), `evidence/sweeps/uvm_coin_orderblind_P_vs_L.txt`.

The implementer listed 23 surelog movers. Which coin members flip differs per run.

**Single-switch attribution** (`drivers/attrib.sh`, `evidence/sweeps/corpus_attribution_law.txt`):
- Under `R11U155_OFF=1`, all 32 rerun databases return to the pristine bytes.
- Every deterministic mover returns to pristine under exactly one switch:
  - PVLEFTOP: GenForIface x2
  - TDSTRETCHHDR: IfGenTypeBinding
  - IMPLARGDIM: ImplicitArg
  - NAARRNET: UnpackPort
  - PRGINITEND: SimpleConstraint
  - PSELNAME: Earlgrey_0_1 d/t, YosysBigSimEllip, genscope_module_ctx_reset
  - IFSIGCHILD: OneNetModPort d/t, Rggen d, OneNetModport, iface_sig_in_child_port
  - MODAGGARG: const_cast_signext
  - NDAFOLDLOC: PatternStruct
  - UNITUNIONARG: union_param_repro
- OneNetModPortGeneric (the implementer's fixed break) is a non-mover under every switch.

**Byte-only movers move toward golden.** By order-blind dump lines against golden (`drivers/dist.sh`), pristine ->
law:
- OneNetModPort d: 363 -> 335
- OneNetModPort t: 313 -> 285
- Rggen d: 146756 -> 146126
- Earlgrey_0_1 d: 394125 -> 393965

These are the implementer's deltas (-28, -630, -160) under this normalisation.

**Canaries** on the law and verified sweeps (`evidence/sweeps/canaries_V.txt`):
- canaries.sh: surelog ok=50 changed=2 (SimpleConstraint d/t, the attributed CHANGE); uhdm2rtlil ok=16 changed=0.
- ctcan2: surelog ok=58 PASS (EXPECT_UNKNOWN=1); uhdm2rtlil ok=2 PASS (EXPECT_UNKNOWN=6).

**The implementer's grid.** 135 cases (`evidence/grid/impl_grid_P_L_OFF.txt`) read pristine STRICT_EQUAL 28 -> law 97,
with 0 breaks. uhdm-cmp stays at 0 wherever pristine read 0. `R11U155_OFF=1` gives the pristine bytes on all 135. The
verified build gives the law bytes on all 135 (`evidence/grid/impl_grid_V.txt`).

## 3. Breaks found, and the two refinements

Fresh cases live in `cases/`, 114 of them. Each case's first line names its law. The cases were judged by uhdm-cmp
against the v1.87 pin, by uhdm-strictcmp field by field, by the order-blind dump distance and by the downstream
verdict.

| law | switch | site | statement |
|---|---|---|---|
| § naArrNetOwnPortDecl155v | `R11V155_NAARRSEP_OFF` | ModuleEmit.cpp emitInstance, the § nonAnsiArrayNetAtHeader155 block | § nonAnsiArrayNetAtHeader155 moves the array_net to the header name only when the PORT DECLARATION itself declares it: the internal symbol's declarator must sit under a `PortDeclaration` |
| § tdStretchProgramKeeps155v | `R11V155_TDPRG_OFF` | UhdmExporter.cpp, `nonAnsiHdr155` (§ pkgTdStretchNonAnsiHeaderSkips155) | a PROGRAM keeps the imported typedef stretch whatever its header; the skip is limited to modules and interfaces |

`R11U155_OFF=1` drops both refinements together with the implementer's laws. Each refinement switch alone gives the
implementer's law bytes back (`drivers/gridall.sh` column S).

**Break 1: § nonAnsiArrayNetAtHeader155 on a port re-declared by a net declaration.** Case NA u07 is
`module dut(o, i); output [1:0] o [2]; input [1:0] i; wire [1:0] o [2];`.
- Golden and pristine locate the array_net `work@dut.o` and its logic_net element at the `wire` declaration's name
  (4:14-4:15). The law moved both to the header (1:12-1:13).
- The strict count grows from `line(4)` to `line(6)`, with the same first field.
- The same break shows on u09 (input), u10 (child instance), u11 (`output var3; struct2 var3 [3];`) and u12
  (`output o; wire [1:0] o [2];`). The order-blind distance grows by 10 to 14 lines on each.
- With the refinement, all five are pristine bytes again. u01-u06 (the port declaration declares the net) still
  convert.

**Break 2: § pkgTdStretchNonAnsiHeaderSkips155 on a program.** Case TE h07 is
`program p(); import pk::*; s_t x [2]; ... endprogram`.
- Golden lists the elaborated `pk::s_t` and the program's references at the stretched 2:37, as pristine did. The law
  unstretched them (1:56). The order-blind distance goes from 21 to 27.
- h08 (`program p;`) and h10 (an ANSI program) never moved.
- With the refinement, h07 is pristine bytes again. Modules and interfaces keep the law: t01-t10 of the implementer,
  and h01, h04 and h06 here, convert.

**Every other law held.** Fresh instances (`evidence/grid/summary.txt`, P = pristine, V = verified):

| family | law | cases | pristine EQUAL | verified EQUAL | notes |
|---|---|---|---|---|---|
| IC | ifaceSigConnNamedByChildPort155 | 16 | 0 | 11 | different child port names (c01), two modport ports (c03), two parents (c04), two children in the other order (c06), always_comb use (c08), a second modport (c09), output member (c10), nested view pass-through (c11), an unconnected second child (c13): all convert; c15 (child interface instance) improves, first record moves to a later `type`; generate child (c02), primitive (c16): untouched |
| PV | ifacePortViewFoldAtLeftOperand155 | 12 | 1 | 8 | `(DAT+32)/16`, `DAT*2/16`, `36 - DAT`, `(DAT)/8`, a header parameter default, literal-only `32/8`, a default-parameter instance: convert; two children on one instance (p12) improves to the pre-existing `depth` record; ternary (p03) untouched |
| FN | dirlessFormalTypeAtName155 | 7 | 1 | 3 | task, enum element: convert; class method, package function: the endcol record clears |
| IA | implicitArgDimsInner155 | 12 | 0 | 8 | task, typed-input follower, package, class, `$unit`, output follower, DPI import follower, pure virtual prototype: convert; `[W-1:0]` clears to a pre-existing fullname face |
| MF | modAggTfArgLastWriter155 | 8 | 0 | 3 | return type + formal, a task and a function, union + net: convert |
| UF | unitAggTfArgLastWriter155 | 7 | 0 | 3 | two formals in one function, a module port of the type (struct, union): convert |
| NA | nonAnsiArrayNetAtHeader155 + naArrNetOwnPortDecl155v | 12 | 0 | 5 | see break 1 |
| TE | pkgTdStretchNonAnsiHeaderSkips155 + tdStretchProgramKeeps155v | 9 | 2 | 5 | header import, interface, `$unit` import: convert; see break 2 |
| IT | initTsEndProgramLocal155 | 13 | 1 | 7 | `real`, `string`, two declarators, one of two initialised, `byte unsigned` sum, class `= null`: convert |
| PS3 | pselConnNameNotFrozen155 | 10 | 1 | 4 | generate case, parameterised parent, generate-local base: convert |
| PS4 | packedStructNdaFoldConstLoc155 | 8 | 0 | 0 | see residue L3 |

Totals over the 114 cases:
- **Strict axis:** pristine 6 STRICT_EQUAL, law 57, verified 57. No case moves from STRICT_EQUAL to anything else.
  Wherever pristine read uhdm-cmp 0, the verified build reads 0 too.
- **Distance to golden:** 86 cases move. By the order-blind dump distance, 80 move toward golden, 6 stay level and 0
  move away (`evidence/grid/movers_P_to_V.txt`).
- **Switches:** `R11U155_OFF=1` gives the pristine bytes on all 114. Each case's own switch gives the pristine bytes on
  every moved case.
- **Downstream:** 93 fresh cases were run through `scripts/downstream_uhdm2rtlil.py` `one()` with the pristine and the
  law binary. Their verdicts are identical: 86 IDENTICAL, 2 DIVERGENT, 1 EQUIVALENT, 4 SLANG_REJECT. The 27 later cases
  (batch 3) are identical between pristine and verified (`evidence/grid/downstream_*`). PS3 r08 (an instance array
  with a part-select actual) reads STATUS_DIFF on both binaries.

## 4. The verified patch's gates (`/tmp/v11u155_swV`)

The verified sweep reproduces every row of the law sweep's csvs in probe, surelog, uhdm2rtlil and downstream,
including the LowMem path text.

The prediction was made before the sweep. Both refinements only narrow a law, so they can only move tests the law
moved. The law's NAARRNET and TDSTRETCHHDR movers are UnpackPort (a port declaration that declares the net) and
IfGenTypeBinding (a module). Predicted: 0 movers against the law sweep, apart from the UVM coin.

Measured (`evidence/sweeps/byteverify_V_vs_L.txt`):
- uhdm2rtlil: 0 of 1608.
- probe: 0 of 4087.
- surelog: 7 of 960, all of them the UVM coin: MiniAmiq d/t, SeqDriver d/t, Scoreboard d, SimpleUVM d/t. Order-blind,
  each reads 4 lines, and Scoreboard 0 (`evidence/sweeps/uvm_coin_orderblind_L_vs_V.txt`).

## 5. Residues on the laws, ranked (pristine wrong, and the law wrong differently; neither is a break)

Each residue keeps the same strict count or the same order-blind distance.

1. **L1, § modAggTfArgLastWriter155 and generate-block subroutines** (MF g07). A formal of a function inside a
   generate block is a later writer in golden: s_t lands at the generate function's `s_t` (4:39-4:42). Ours reads the
   module-direct `h` (7:37-7:40); pristine read the typedef. Next step: scan the generate blocks as the last writers.
2. **L2, § initTsEndProgramLocal155 and an unpacked local** (IT k05, `int a [2] = '{1,2};`). Golden ends the
   int_typespec at the unpacked dimension (1:35), and the array_typespec at 1:34. Ours ends at the initializer (1:44);
   pristine ended at the type (1:29).
3. **L3, § packedStructNdaFoldConstLoc155 and a non-leaf element.** Golden locates the folded constant with the rule
   of § ifacePortViewFoldAtLeftOperand155:
   - a binary element at its LEFT operand: q03 `8'hA + 1` -> `8'hA` 4:26-4:30;
   - a unary element at its operator token: q05 `-1` -> 4:26-4:27;
   - parentheses stripped: q08 `(P)` -> 4:21-4:22.

   The law uses the whole element. q03 moves from `file(1)` to `endcol(1)`; q05 and q08 are stage-1. The transcription
   is the PV reducer applied to the element syntax, and it would convert q03.
4. **L4, § ifaceSigConnNamedByChildPort155 under a generate block** (IC c02). A member connected inside `if (1) begin :
   g` is named through the generate path in golden. The law scans direct members only, so the bytes are pristine.
5. **Stage-1 neighbours seen by these cases, not on this ground:**
   - PS3 r08: instance-array part-select, downstream STATUS_DIFF on both binaries.
   - IC c14: array of modport ports.
   - IT k06: program task local.
   - TE h05: `pk::s_t` array in a non-ANSI module.

The implementer's residues (R-SP, R-EV, R-LT, GenerateUnnamed, the vector half of § defNetTypeParamPackedDim144, and
the sister-ground faces with their call sites) are in `tools/probe/r11u155repro/README.md` sections 6-7. This pass
did not re-derive them.

## 6. Files

- `cases/<family>/<case>/dut.sv`: the 114 fresh cases. The first line is `// § <law>`.
- Drivers:
  - `drivers/grid.sh`: one case, golden + ours + uhdm-cmp + uhdm-strictcmp.
  - `drivers/gridall.sh`: P, L, V, V with `R11U155_OFF`, and V with the case's own switch.
  - `drivers/ds.sh`: the downstream verdict of a case.
  - `drivers/dist.sh`: the order-blind distance.
  - `drivers/attrib.sh`: single-switch corpus attribution, over a positive whitelist of the moved tests.
  - `drivers/sweep.sh`: the gate sweep wrapper.
- Evidence:
  - `evidence/grid/`: the fresh grid, the implementer's grid, the downstream verdicts and the mover distances.
  - `evidence/sweeps/`: sweep and downstream logs for P, L and V, byteverify, attribution, the UVM coin, the
    YosysBigSimEllip heads, the Earlgrey distance and the canaries.
