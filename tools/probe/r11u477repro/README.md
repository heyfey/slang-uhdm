# r11u477: expression/parameter ground, pass 477 of the sv-tests campaign

Base 61ba6caa. Laws in src/EmitHelpers.h, src/ExprEmit.cpp, src/ParamEmit.cpp. Each law reads its switch through src/LawSwitch.h. `R11U477_OFF` drops every law of the pass, and `R11U477_TRACE=<dir>` logs each firing. There is no src/R*.h, no getenv and no header change outside EmitHelpers.h.

## Target: generated/easyUVM/top.sv (DIFFERENT -> DIFFERENT, two of its heads cleared)

At the base, uhdm-cmp reads 60 lines. The head is the call `exp.compare(rec)` at comparator.sv 63:14. Golden writes one vpiArgument. Ours also writes the formal's default `uvm_comparer comparer = null` (UINT:0 at uvm_object.svh 1168:58).

Measured with each switch set alone (evidence/easyuvm_switches.txt):

| binary | uhdm-cmp lines | head |
|---|---|---|
| pristine / R11U477_OFF | 60 | comparator.sv 63:14, the defaulted argument |
| law, R11U477_PARENCALL_OFF | 60 | the same head |
| law, R11U477_ROOTFILE_OFF | 659303 | interface_inst work@input_if: golden lists uvm_pkg's import copies, ours lists none |
| law, R11U477_FILEPATH_OFF | 36 | env.sv 119:104, the `__FILE__` string: golden .../easyUVM/env.sv, ours .../easyUVM/./env.sv |
| law (all on) | 658119 | the definition module work@top's vpiRefModule vector: golden has none, ours lists ref_module `in` and `out` (ModuleEmit, the sister's ground, see below) |

The row stays DIFFERENT. Its first difference is now on the module/type ground. The large line count is the cascade of a vector-level mismatch at the module, not a move away. In the sweep the row's detail column is unchanged (`decompile:`).

## Laws

1. **§ parenCallWrittenArgs477** (EmitHelpers.h, at callInvocation167; `R11U477_PARENCALL_OFF`)
   - A parenthesized call keeps its written argument list.
   - slang binds `(f(a))` by creating the inner call and then stamping the ParenthesizedExpression syntax on it (Expression.cpp, `result->syntax = &syntax`). The invocation accessor therefore answered null, and § writtenCallArgs16 fell back to the bound list, which holds every defaulted formal.
   - Surelog writes only the written actuals.
   - The accessor now reads through any number of parentheses to the InvocationExpression. Every written-argument decoder that starts from callInvocation167 follows: the method, function and named-argument decoders.
   - Cases: cases/CD.
2. **§ unitImpRootFileDef477** (EmitHelpers.h unitImpReachesDef477, used by collectMaterializedPkgs and by ParamEmit's file-scope import items; `R11U477_ROOTFILE_OFF`)
   - A file-scope import reaches a module, interface or program written in a file that the import's file includes.
   - Surelog's preprocessor folds every `include into the root file's FileContent, and CompileModule hands `fC->getObjects(paPackage_import_item)` to every definition of that FileContent.
   - The test compares the root buffer of each side's include chain, with a macro location mapped to its original first. This is the same rule as the sister's § unitInclClassImports468 for classes.
   - Cases: cases/RF.
3. **§ fileMacroPathNormal477** (ExprEmit, StringLiteral branch; `R11U477_FILEPATH_OFF`)
   - The `__FILE__` literal is written in its lexically normal form.
   - slang writes the buffer name as the include resolved it (`./env.sv` gives `<dir>/./env.sv`). Surelog substitutes FileSystem::toPath of the file id, which is normal: `sub/../sub/./inc.svh` reads `<dir>/sub/inc.svh`.
   - The token is recognised by its fully original text, `` `__FILE__ ``. slang's intrinsic expansion has no macro name and its range has no raw text.
   - The value, decompile, size and the literal's own end column follow.
   - Cases: cases/FN.
4. **§ caAddLeafIntMint477** (ExprEmit isIntEncoded; `R11U477_CAADDLEAF_OFF`)
   - ExprEval's add rule reaches leaves in the expression-side fold too. A `+` whose operand is a 'd literal or a parameter whose own constant is DEC mints INT (red97OperandMintsInt97, the rule § addOperandConstMint475 asks in ParamEmit).
   - The rule applies only while every enclosing node is an implicit conversion or a `+`. `(P + 1) & 8'hff` stays UINT:34 in golden (AD/ad06; an earlier draft without this restriction broke ad06 and was narrowed before any sweep).
   - It closes the r11u475 residue RC/rc02: `assign z = PB + 6'd1` with an imported `PB = PA` reads INT:34 as golden does (AD/ad01).

## Grid (evidence/grid.txt; tools/probe/r11u477repro/cases; every exit code 0 on both binaries)

**CD, § parenCallWrittenArgs477**
- 24 dirs. 17 go from NOT_EQUAL to STRICT_EQUAL: cd01, cd02, cd10 to cd20, cd22 and cd24.
- cd21 (`(obj::sf(1))`) moves closer, from 74 to 42 uhdm-cmp lines. Golden writes the class-scoped static call as a ref_obj named `obj::sf`. That is an older, unrelated face.
- cd04 (`comp #(packet) c;` in a module) moves its head later, from 60 to 178 lines. The dump distance falls from 95 to 89. Its next face is the module-scope specialization, golden's `class_typespec (comp)` without parameters, on the sister's ground.
- 6 controls are byte-identical: cd03, cd05 to cd09 and cd23.

**RF, § unitImpRootFileDef477**
- 8 dirs. rf01, rf02, rf04 and rf05 go from NOT_EQUAL to STRICT_EQUAL.
- rf03 (a program in an included file) keeps 441 lines at the program's listing. The dump distance falls from 611 to 125.
- rf07 (a nested include) goes from 419 to 51 lines. Its head is pass 451's residue: a module variable initializer reading an imported package variable, unbound in ours.
- rf08 (easyUVM's shape) goes from 373 to 403 lines, with the head later and the dump distance down from 768 to 266. Its next face is the ref_module face.
- rf06 (an include inside a module body) is a byte-identical control.

**FN, § fileMacroPathNormal477**
- 3 dirs go from NOT_EQUAL (36 lines) to STRICT_NOTEQUAL endcol: uhdm-cmp equal, with the rest of the line after the literal still two columns late. See the sister-ground faces below.

**AD, § caAddLeafIntMint477**
- ad01 goes from NOT_EQUAL to STRICT_EQUAL.
- ad02 to ad08 are STRICT_EQUAL on both binaries. ad02, ad03, ad06 and ad08 move bytes with identical dumps: an intermediate UINT string is no longer stored in the string table.

**Switch checks**
- With `R11U477_OFF` set, the law binary writes pristine's bytes and exit code on 45 of 45 grid dirs (evidence/swcheck_all_off.txt).
- Each dir moves under exactly one law's own switch: PARENCALL 17, ROOTFILE 7, FILEPATH 3, CAADDLEAF 5, none 13 (evidence/lawsw.txt).

## Prediction before the sweep and the sweep (evidence/PREDICTION.md, census*.tsv, sweep_*.log, byteverify.txt)

**The census**
- Pristine (cf8527bc, byte-identical to the main tree's build) and the law binary, traced, were run over all 10616 fence-filtered row-modes from each row's own directory.
- No exit code moved.
- 46 byte movers:
  - surelog: BlackBePipeInt d/t, Earlgrey_0_1 d/t and YosysOldOpen d/t, all through § caAddLeafIntMint477. Their dumps are identical to pristine's; only the serialized string table changed. All six read STRICT_EQUAL against golden on both binaries, at 339479/338504, 2173209/1342584 and 31337/31337 objects.
  - probe: 39 cases, all dump-identical.
  - sv-tests: easyUVM alone.
- § parenCallWrittenArgs477's trace fires on 158 sv-tests rows (uvm_pkg's parenthesized calls with every formal written) without moving their bytes. The trace logs every parenthesized call it reads, not only the movers.

**The one full sweep** (law binary law6, md5 in evidence/binaudit.txt context)
- probe: EQUAL 4024 + STRICT_NOTEQUAL 63, regressions 0, conversions 0, changes 0. All 4087 databases are dump-identical to the master's control /tmp/intr11u475 after path normalization; the negative control reads DIFF.
- surelog: default 480 + 0 and testflags 474 + 0, 0/0/0.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0. The verdict diff against the baseline is 0.
- sv-tests (run through the main tree's tests/sweep.sh, since the worktree's UVM folder is empty): EQUAL 1935, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, regressions 0, conversions 0, changes 0. Every row's status and detail equals the base's results/golden_svtests.csv. The command exited 1 only on the main tree's stale law index, after pass 470 landed there.

**Byteverify against the master's control** (SELFCHECK on)
- surelog: 6 of 962 movers, exactly the predicted six.
- uhdm2rtlil: 0 of 1608.
- downstream: 0 of 805.

**Other checks**
- Canaries: ok=52 and ok=16. ctcan2 passes on both.
- Binary audit: surelog has 1523 of 1573 records naming law6; the other 50 hold only a Surelog line. uhdm2rtlil has 1740 of 1740 and sv-tests 2346 of 2346.

**Goal 1**
- All 75 SURELOG_ONLY rows carry an upstream slang ` error: ` diagnostic and none carries the exporter's own message.
- No law here touches the black-parrot guard or the member-select probe faces, so bp_unicore was not rerun.

## Residues (all wrong on pristine too; none moved away)

1. **easyUVM's next head** is the definition module's ref_module listing (sister, below).
2. **The `__FILE__` line shift.** The literal's end column is now golden's, but every later token on that line stays two columns late (FN, easyUVM env.sv 119). The shift is computed in UhdmExporter's § ppMacroBodyLines160 from the token's raw length (argLen of the `__FILE__` argument buffer), which is the sister's ground.
3. **A qualified read of an int-typed package parameter** carries a typespec golden lacks (r11u475 QR/qr_i, qr01; evidence/residue/QT/qt01). The writer is now located by a gdb backtrace on MakeRef_typespec: ModuleEmit **emitContAssigns** in the elaborated module, under emitInstance. It is not in ExprEmit. Sister ground.
4. **An add overflowing its declared width** (v11u475 VA/va04; evidence/residue/OV/ov01). Golden keeps the 64-bit sum, `PC = PA + 6'd1` reading INT:64 at size 6, in the package listing, the module copies and the continuous assignment; ours writes slang's wrapped INT:0. This needs an ExprEval-style re-fold at every parameter-value site. It is not written.
5. **cd21's class-scoped static call** in parentheses, which golden writes as a ref_obj `obj::sf`.
6. **rf03's program in an included file**, whose listing goes through another path.
7. **rf07's nested-include module variable initializer `int y = pv`**, unbound in ours (pass 451's DI/di02 face).
8. Pass 475's residues XK/xk02, xk03, xk05, xk06, VX/vx11, VH/vh02, VQ/vq03, VA/va05, AM/am03, am07, am08, VR/vr06 and RC/rc01 are untouched. The lists of passes 473 and earlier carry over.

## Sister-ground faces (reported, not written)

- **ModuleEmit, the definition-module ref_module listing for interface instances with two or more ports.** Golden writes no ref_module for `a_if in(clk, rst)` and points the high connections at the interface's port declarations. With one port it writes the ref_module (evidence/sister/rm2port against rm1port: Surelog 0 against 2 ref_module, ours 3 and 2). This is easyUVM's head now.
- **UhdmExporter § ppMacroBodyLines160**: the rest-of-line shift after a `__FILE__` expansion uses slang's unnormalized path length (residue 2).
- **ModuleEmit emitContAssigns**: the elaborated whole-right-side typespec stamp on a qualified int-typed package parameter read (residue 3).
- **ModuleEmit vpiDefFile** of a module defined in an included file. Golden names the root file (dut.sv); ours names the included file (RF/rf07 dump). Neither judge reads it.
