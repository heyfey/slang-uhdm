# v11u445 — adversarial verification of r11u445 (expression/parameter ground)

Verifier of pass 445 (the implementer's r11u445: six laws for a foreach loop
variable named like a declaration). Base 3b825bc59. Verdict: the six laws
REPRODUCE and HOLD. No break was found: no fresh case moved away from golden,
no corpus row, probe case or sv-tests row moved, and no downstream verdict
changed. The verifier adds one production refinement,
§ nestedLoopVarSkipsOuter445v. It is not a fix for a break. It completes the
law's nested same-name shape, where pristine and the law were both wrong and
the law was closer.

## Binaries (frozen)

| Binary | Path | md5 |
|---|---|---|
| pristine | /tmp/v11u445_bin/pristine (copy of the implementer's frozen base build) | 8b728ab5166adfa3a8f77d8a35558391 |
| law | /tmp/v11u445_bin/law (rebuilt once from /tmp/r11u445.patch) | 685e64471b6aff5cb6e1fd77a1f0c883 |
| verified | /tmp/v11u445_bin/ver1 | c0cd9a67b61af441995a3e52b30217ba |

- The pristine md5 equals the base's main-tree build.
- The law md5 equals the implementer's law5.
- All three binaries link slang 12.0.0+545f88b2e.
- uhdm-strictcmp is the worktree build, fa6e4f42f252ae0ab69d9845003e71c5.
- No pristine build and no pristine sweep: the pristine reading is the master's control /tmp/intr11u443.

## Reproduction of the implementer's numbers

- **Grid.** The 75 case dirs (drivers/grid.sh) on pristine and law reproduce
  evidence/r11u445_grid_law5.tsv line for line: exit code, uhdm-cmp count,
  dump distance and strict verdict. Only the md5 column differs, because it
  embeds the work path. Result: 44 NOT_EQUAL -> STRICT_EQUAL, 8 closer,
  8 residues and 15 controls byte-identical
  (evidence/v11u445_grid_impl75.tsv).
- **Earlier passes' cases** (evidence/v11u445_grid_earlier.tsv), pristine -> law:
  - To STRICT_EQUAL: r11u443 IF/if11 and if12, r11u439 LM/lm11 and lm13, v11u439 VL/vl01.
  - Closer by dump distance: PF/pf20 (27 -> 19) and pf33 (46 -> 19).
  - Byte-identical: VL/vl02, VL/vl08 and v11u443 VA/va16.
- **Away census** over 4456 fence-filtered tools/probe and tests/probe files
  that hold `foreach` or `with` (pristine vs law, traced):
  - Exit codes are equal on all 4456.
  - Byte movers: exactly the implementer's 7.
  - Firing files: the same 9.
  - Evidence: evidence/v11u445_census_pris_law.tsv.
  - The fence filter ran on the path list before any file was opened. The list was read into a file by a program and never printed.
- **Goal 1.** Of the rejecting rows in results/golden_svtests.csv (303 BOTH_REJECT, 75 SURELOG_ONLY, 0 SLANG_CRASH), none carries an exporter message. The six whose detail matches "uhdm" or "export" are upstream slang front-end errors.

## The law sweep (law binary, once, after three quiet readings)

Driver: drivers/fullsweep.sh. The four corpus stages run from the worktree.
The sv-tests stage runs from the worktree's scripts and baseline through
drivers/svstage.py, whose only change is that UVM_DIR points at the main
checkout's bundled UVM tree, read only. The trace was on.

| Stage | Result |
|---|---|
| probe | 4023 + 64, 0/0/0; csv identical to the control; 4087 of 4087 databases dump-identical, path-normalized (positive control: two different databases differ by 887 lines) |
| surelog | 480 + 0 / 474 + 0, 0/0/0; csv differs from the control only in the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0; csv identical |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; csv identical |
| svtests | EQUAL 1913, STRICT_NOTEQUAL 0, DIFFERENT 27, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=0 changes=0; csv identical to the control |

- **byteverify** against /tmp/intr11u443:
  - Movers: 0 of 962, 0 of 1608 and 0 of 805.
  - Self-checks flag 961, 1607 and 804.
- **Canaries:** ok=52 and ok=16; both ctcan2 checks PASS.
- **Binary audit**, fence-filtered:
  - surelog: 1523 of 1573 records name the law binary; the other 50 hold only a Surelog line.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
- **Trace directory:** empty. This matches the prediction recorded beforehand in evidence/v11u445_prediction.txt.

## Attack grid (cases/, 126 fresh case dirs; first line `// § <law>`)

Groups:
- VB: block-local shadows.
- VM: module parameters.
- VR: reads and `with` iterators.
- VP: program and interface parameters.
- VI: interface declarations.
- VK: package subroutines.
- VU: uninstantiated program and interface.
- VN: mixed.
- VS: nested same-name foreach.

Every case is accepted by upstream slang (two shapes slang rejects were
dropped), and every exit code is 0 on all three binaries. Goldens come from
Surelog -parse -nobuiltin -nocache -sv. Results by binary are in
evidence/v11u445_grid_attack_pris_law.tsv and v11u445_grid_ver1.tsv.

**Pristine -> verified:**
- **76 NOT_EQUAL -> STRICT_EQUAL**:
  - The law alone converts 65.
  - The refinement converts these 11: VB/vb02, VM/vm15, VN/vn01, VS/vs01 to vs04, vs09, vs11, vs14, vs17, vs18.
- **2 NOT_EQUAL -> STRICT_NOTEQUAL type** with uhdm-cmp at 0: VN/vn13 and VS/vs12. The remaining field is the package definition view's relisting of the outer loop variable, where golden mints a fresh placeholder.
- **11 closer** by dump distance, none further:
  - VB/vb17: the generate definition view.
  - VI/vi08: the with-iterator argument reference.
  - VI/vi09: the nested-interface listing.
  - VK/vk05: the with-iterator argument reference.
  - VM/vm05: a type parameter.
  - VN/vn04 and VS/vs10: the program-net listing, the sister's.
  - VN/vn16: the port-connection constant typespec.
  - VP/vp05: a program struct array.
  - VP/vp08: the program listing.
  - VS/vs16: the with-iterator argument reference.
- **35 byte-identical** to pristine: 17 STRICT_EQUAL controls and 18 residues.
- **2 where Surelog rejects** (no comparable golden):
  - VB/vb14 `var i;`: Surelog UH0701 "Unsupported statement".
  - VM/vm20 std::randomize with: Surelog exit 3.

**Switches:**
- R11U445_OFF gives pristine's bytes and exit code on 201 of 201 case dirs
  (75 + 126) on both law and verified.
- R11V445_OFF and R11V445_NESTSKIP_OFF give the law's bytes on 201 of 201.
- Per-law droppability on the law binary (evidence/v11u445_switches_law.tsv): every mover is restored by one switch or by a measured pair.
  - MODPARAM with PARAMREAD: 16 cases.
  - SHADOWBLK with IFACELVDECL: 2 cases.

**Downstream:**
- 106 class-free attack cases, pristine vs law: 101 IDENTICAL, 4 EQUIVALENT and 1 SURELOG_FAIL on both binaries; no verdict changes.
- The 18 VS cases on all three binaries, and vb02, vm15, vn01 and vn13 on the verified binary: IDENTICAL.

**Shapes covered without a break:**
- for-loop init variables.
- Locals of struct, string, unpacked array, event, real, class handle and signed bit types.
- Static locals.
- Fork, named and nested blocks.
- Multi-dimensional and skipped slots.
- Associative, queue and dynamic arrays.
- always_ff and final processes.
- $unit functions.
- Task formals: input, ref and output.
- Interface instances: twins, arrays, nested.
- Interface ports and modports.
- Members declared after the process.
- Module parameters: typed by W, overridden, defparam, port-list, enum, unpacked, string, untyped.
- Imported and $unit parameters (abstaining as before).
- Parameters in a task or function.
- `with` iterators in functions and generate blocks.
- Program and interface parameters: overridden, twin instances, type parameters, dynamic, associative and struct arrays, in a generate block, under a block local.
- Package tasks and functions: formals, static locals, typedef'd locals, nested loops, fork.
- Uninstantiated programs and interfaces.

## The refinement: § nestedLoopVarSkipsOuter445v (R11V445_NESTSKIP_OFF)

Read through lawFixOn(445, ...), so R11U445_OFF and R11V445_OFF both drop it.
It touches EmitHelpers.h and ExprEmit only; StmtEmit is unchanged from the
implementer's patch.

**Rule:** a nested foreach whose loop variable shares its name with an
enclosing foreach's loop variable passes over that enclosing loop variable.
The enclosing variable is itself the ref_var over the declaration found
further out, since the same walk found it, and lateTypedefBinding's and
lateBinding's foreach branches skip ref_var loop variables. So:
- The inner loop variable becomes a fresh ref_var over the declaration's typespec. Before, it fell to an int_var or array_var over the array element.
- The inner read binds that declaration. Before, the read minted an implicit net.
- Under a module parameter, the inner read stays bare.

**Example**, golden VB/vb02:

```
begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
```

The inner loop variable is a ref_var at 4:48 over the local's int_typespec
4:15, and the read binds int_var work@top.i at 4:19.

**Sites:**
- loopVarShadowBlockSym445: continues past an Iterator.
- loopVarFirstDecl445: same.
- A new loopVarDeclPastOuter445v, used as the fallback of the module, interface and package read bindings when loopVarModuleDecl439 returns nothing. It binds only when at least one same-name loop variable was passed and a variable, net or formal lies beyond.
- Trace lines: `nestedLoopVarSkipsOuter445v decl|param|read <name>`. A decl or param line also records a pass-over that finds nothing and changes no bytes.

**Measured:**
- Grid (above): 11 cases to STRICT_EQUAL and 2 to STRICT_NOTEQUAL, none further.
- Census law -> verified over the same 4456 files: 0 byte movers and 0 exit-code changes. Two files log only a pass-over line: r10uvm181repro/g181_b_dims.sv and v11u443repro VA/va16.
- Determinism: three concurrent runs each of VB/vb02, VS/vs03, VM/vm15, VS/vs01 and VN/vn01 read one hash, equal to the grid's.
- The refinement fires on no corpus row (verified sweep below).

## The verified sweep (verified binary, once)

This sweep was run after three quiet readings, with the prediction recorded
beforehand in evidence/v11u445_prediction.txt. The prediction held.

| Stage | Result |
|---|---|
| probe | 4023 + 64, 0/0/0; 4087 of 4087 databases dump-identical to the control |
| surelog | 480 + 0 / 474 + 0, 0/0/0 |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 |
| downstream | 803/66/2/0 |
| svtests | EQUAL 1913, DIFFERENT 27, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, 0/0/0 |

- **csvs:** each one equals the law sweep's and the control's. The only exception is the two LowMem log-path texts in surelog.csv.
- **byteverify:** 0 of 962, 0 of 1608 and 0 of 805 movers, both against the law sweep and against the control. The self-checks flag 961, 1607 and 804.
- **Canaries:** ok=52 and ok=16; both ctcan2 checks PASS.
- **Binary audit**, fence-filtered:
  - surelog: 1523 of 1573 records name the verified binary.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
  - No record names another binary.
- **Trace directory:** empty in all five stages.
- **Exit status:** the corpus stages exited 1 only because the law index was stale (this README was written after the index was generated). The index has been regenerated since.

## Residues (ranked; all wrong on pristine too; none moved away)

1. **Ports of a module** (SM/sm05 to sm07, v11u439 VL/vl02); an interface port, VI/vi02, is STRICT_EQUAL. A port's typespec is not yet attached when the process is emitted. Sister's ground: ModuleEmit emission order, or UhdmExporter's pendingLoopVarTs9 drain.
2. **Program listing of block locals** (SP/sp01, sp02, sp07, PF/pf20, pf33, VN/vn04, VS/vs10, VP/vp08). ModuleEmit's program hoist, pass 444's.
3. **Generate-block definition view** (SG/sg01, sg02, SM/sm20, VB/vb17, VM/vm03, vm12, VN/vn08, VS/vs13). Golden keeps the placeholders there.
4. **Package definition view of a nested same-name foreach** (VN/vn13, VS/vs12, both STRICT_NOTEQUAL type). Ours relists the outer object where golden mints a fresh placeholder ref_var.
5. **with-iterator argument reference** q.sum(i) / q.find(x) (SW/sw02, sw03, VI/vi08, VK/vk05, VS/vs15, vs16).
6. **Type parameters** (VM/vm05 closer; VP/vp01, VP/vp09 interface/program type parameters byte-identical).
7. **Program and interface subroutine bodies** (SI/si05, SP/sp05, sp06, VP/vp06, VI/vi11, VU/vu01).
8. **Imported or $unit parameters as loop-variable names** (VM/vm09 to vm11). These are byte-identical; golden swaps the placeholder.
9. **Singletons:**
   - SK/sk05 and VK/vk02: a package variable or parameter.
   - SM/sm18: the typedef listing.
   - VI/vi03: an interface event.
   - VN/vn06: a function named like the loop variable.
   - VM/vm21: a class constraint, already equal.

## Sister-ground faces (reported, not written)

Unchanged from r11u445:
- The port typespec bind (ModuleEmit emission order / UhdmExporter pendingLoopVarTs9).
- ModuleEmit's program hoist.
- TypeEmit's typedef listing.
- UhdmExporter's admission of the three basejump rows.

## Process

- **Builds and sweeps:** one law build, one verified build, and one full sweep each on law and verified. The verified sweep was run because production code changed.
- **Overlap with the master's sweep:** the grids, the switch checks, the census and the verified build ran single-process at nice 19 while the master's pass 444 integration sweep (/tmp/intr11u444) was live. These are case runs only, and timing was the only shared resource. Both sweeps of this pass started after three quiet readings.
- **Audit command that hung:** a fence-filtered binary-audit command hung on an empty downstream list. The downstream stage writes no cmds.txt, so `xargs grep` waited on stdin. It was stopped by its task id, and nothing else was touched.
- **Fence and sister processes:** the fence list was read into a file by a program and never printed. No fenced test was named, opened or run, and no other agent's process was touched.

## Files

- cases/: 126 case dirs.
- drivers/: gencases*.py, grid.sh, switches.sh, census.sh, dsgrid.py, probedump.sh, fullsweep.sh, svstage.py.
- evidence/: grids, switches, downstream, censuses, prediction, sweep logs.
