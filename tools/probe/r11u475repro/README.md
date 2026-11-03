# r11u475 — parameter value forms: the add mint, reference chains, qualified reads, unreduced XOR and the elaborated Rhs chain (expression/parameter ground, pass 475)

Base 2fa6cb00 (pass 473). Ground: src/ParamEmit.cpp and src/ExprEmit.cpp (EmitHelpers.h and StmtEmit.cpp unchanged).
Every law is read through src/LawSwitch.h: `lawOn(475, "R11U475_<LAW>_OFF")`. `R11U475_OFF=1` drops the pass.
`R11U475_TRACE=<dir>` logs each firing through `lawTrace(475, ...)`. There is no src/R*.h, no getenv, no reader function and no header under include/ changed.
TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit, include/ and uhdm_main.cpp are unchanged.

Binaries (frozen, chmod 555):
- pristine: `/tmp/r11u475_bin/pristine`, md5 afa30e9d601c11d257df9155230c42ca. This is a copy of the main tree's build/slang-uhdm, which the worktree's first build reproduced byte for byte. Used for case runs and the census only.
- law: `/tmp/r11u475_bin/law8`, md5 c36dc182efeec8aad37c0debd5d6a57f, linking slang 12.0.0+545f88b2e. This is the swept binary.
- law1 to law7 were intermediate binaries, used only on case runs. law6 (md5 c70e7f640c88bc263b4066c28f731cd8) ran the pre-sweep census. law8 differs from law6 only in where three lawTrace calls sit, and writes the same bytes on all 34 grid case dirs.

## Item (a): no open row head on this ground

The 8 DIFFERENT sv-tests rows at the base all head on the sister's ground (pass 469's census, re-read by passes 471 and 473).
So this pass took this ground's backlog, in the brief's order:
1. the respell of a parameter defined by another in the elaborated module copy (EX/ex07, VT/vt14, VM/vm01);
2. the alias full name in a non-top instance (VX/vx01, VA/va04, va10);
3. then the faces the grid of those two exposed. These are the add mint, the reference chain read, the qualified read, the unreduced XOR and the hex digit case.

## Characterize and decode

Every head was read with uhdm-cmp, build/uhdm-strictcmp and the path-normalized dump diff (drivers/runcase.sh). The param_assign value forms of every listing were read with drivers/pas.py.

1. **The respell (ex07, vt14, vm01).** The head is the elaborated module copy of `localparam t LB = PA` (PA = `6'd33`, wildcard-imported). Golden reads `INT:33`, decompile `33`, const type 7. Ours read `DEC:33`, `6'd33`, const type 1.
   - Surelog's NetlistElaboration::elab_parameters_ builds the elaborated instance's Rhs from the parameter's Value (`c->VpiValue(value->uhdmValue())`, `decompiledValue()`, `vpiValType()`).
   - A DEC Value is `Type::Integer`, so it becomes INT and bare digits. An OCT Value is parsed to `Unsigned`, so it becomes UINT and decimal digits. HEX and BIN keep their form.
   - Our elaborated respell (§ impCopyBasedDecKeep / § sizedOctElabRespell) runs on a literal default only. A reference default goes through paramOriginBaseRecode, which writes the literal's form back as `DEC:`.
2. **The add mint.** `PC = PA + 6'd1` and `PD = PA + 1` (PA = `6'd33`) read golden `INT:34` in every listing (the package's elaborated listing, the module listings' import copies, a module's own elaborated listing). Ours read `UINT:34`.
   - UHDM ExprEval::reduceExpr's vpiAddOp / vpiPlusOp branch (third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp, the `unsignedOperation` loop) mints INT when ANY reduced operand is a constant of const type INT, DEC, STRING or REAL.
   - A based-decimal literal is a vpiDecConst. A reference to a parameter whose constant is DEC or INT reduces to that constant.
   - Our § foldSigned9 and srlgArithFoldSigned asked only the operators (`-` `*` `/` `%` and `+` over them), never a leaf.
   - § addMintFollowsOperandMint97's `red97OperandMintsInt97` already answers the leaf (a `'d` literal, a minting operator, a parameter through its initializer). A hex, binary, octal or plain decimal leaf, an enum member and a cast keep UINT (AM/am07).
3. **The unreduced XOR.** `assign y = PA ^ PB` (the next head on am01 to am06 and MC/mc06) keeps golden's operation, vpiOpType 30, with its operands as written. Those are literals, a module parameter as a ref_obj, or an imported package parameter as its folded constant. Ours folded it to one constant (`UINT:36`).
   - reduceExpr has no branch for `^`, `~^`/`^~`, `===`, `!==`, `==?`, `!=?` or unary `+`. That is § redTableOneHome72's measured set, `red72ReduceLeavesOp` in EmitHelpers.h.
   - Parameter folds keep folding, because a parameter's value is the instance's Value (Surelog's own evaluator).
4. **The reference chain read.** In g07/RC/rc01, a module-side read of a package parameter whose initializer is a reference chain to a based literal (`parameter HB = HA`, HA = `8'h2a`; `parameter PB = PA`, PA = `6'd33`) reads golden's literal form (`HEX:2a` `8'h2a`, `DEC:33` `6'd33`). Ours read slang's `UINT` digits.
   - substituteAssignedValue follows the reference to the referenced parameter's compiled Rhs.
   - The direct literal initializer already took this road in ExprEmit. A chain did not.
5. **The hex digit case.** paramOriginBaseRecode upper-cased the hex digits (`HEX:2A`). Golden keeps them as written (`HEX:2a`) in every listing. Only the enum-member road re-renders a Value (§ enumOriginConstTypeIsTheMemberValue168).
6. **The qualified read.** In QR/qr_d and qr_u, `assign y = a::P` with P = `6'd33` or `'d9` reads golden `INT:33` / `INT:9` with bare digits. The unqualified read through an import keeps `DEC:` `6'd33` (EX/ex07).
   - The paPackage_scope node hands back a constant built from the parameter's Value, not a clone of its compiled Rhs.
   - HEX, BIN and a signed `-6'sd3` already read equal (qr_h, qr_b, qr_s).
   - OCT (qr_o, golden `UINT:33`) is NOT written. A UINT whole right side takes ModuleEmit's elaborated own-copy road, a second constant with a typespec that golden does not make for a qualified read, so the law abstains there (see "Sister-ground faces").
7. **The non-top alias full name (vx01, va04, va10).** The head is the elaborated child instance's param_assign Rhs constant. Golden names its alias reference `work@sub.PB.t`; ours named it `work@top.u1.t`.
   - elab_parameters_ gives that constant `crt->Actual_typespec(ag)`, where `ag` is the typespec of `mod_assign->Lhs()`: the DEFINITION listing's parameter.
   - So the constant shares the definition copy's chain. Its alias is named after the definition (`<defName>.<param>.<t>`).
   - In a top module the definition and instance names coincide, which is why § modImpCopyTdChainHomeTop473's MC grid read equal.

## Laws

- **§ addOperandConstMint475** (ParamEmit `addLeafMint475`, called from § foldSigned9's `+` branch and srlgArithFoldSigned's; `R11U475_ADDMINT_OFF`). An add whose operand mints INT under `red97OperandMintsInt97` folds INT. This applies to the elaborated package listing, the module listings' import copies and a module's own listing. The trace logs each decision (the caller flips only a `UINT:` value).
- **§ elabImpRefDecRespell475** (ParamEmit, at paramOriginBaseRecode's call site; `R11U475_REFRESPELL_OFF`). In the PHYSICAL elaborated module instance (`!inPackage && !defViewOrig9`), a recoded reference-chain literal is respelled as the instance Value: DEC becomes `INT:<digits>` with the bare digits, and OCT becomes `UINT:<decimal>`. HEX and BIN keep their form. The package views and both module definition listings keep the literal.
- **§ pkgReadRefChainLitForm475** (ExprEmit, the module-side package parameter fold; `R11U475_READCHAIN_OFF`). A read of a package parameter whose initializer is a reference takes paramOriginBaseRecode's literal form. A variable initializer never reaches this site: RC/rc02's `logic [5:0] v = PB` keeps pristine's `UINT:33`, golden `INT:33`, which is reported below.
- **§ refChainHexWrittenCase475** (ParamEmit paramOriginBaseRecode; `R11U475_HEXCASE_OFF`). A hex literal reached through a reference keeps its written digits when any is a lower-case letter. All-upper and all-digit hex is unchanged.
- **§ caReduceLeavesOpKept475** (ExprEmit tryFoldConst; `R11U475_CAXORKEEP_OFF`). With `!paramCtx`, an expression whose top operator is in `red72ReduceLeavesOp`'s set is not folded. The emitter then writes the operation. The trace logs the value it declined.
- **§ elabRhsSharesDefParamChain475** (ParamEmit, inside § modImpCopyTdChainHomeTop473's walk; `R11U475_ELABRHSDEF_OFF`). In the elaborated tree (TopModules and below), the param_assign Rhs role is named `<VpiDefName>.<param>` instead of its own reference's full name. The law's memo therefore shares the definition copy's clone, and the alias reads `work@sub.PB.t`. The trace fires only where the two-hop shape passed § 473's gates.
- **§ pkgQualCaReadValueForm475** (ExprEmit, after the literal-form block; `R11U475_QUALCAFORM_OFF`). A qualified `p::P` read as a continuous assignment's whole right side whose value is `DEC:` reads `INT:<digits>` with the bare digits.

## Grid (evidence/grid_law8.txt; drivers/runcase.sh; every exit code 0 on both binaries, every case accepted by upstream slang with the real exit code read)

34 case dirs in AM, HC, NT, QR, RC, RR and XK. Every case names its law in its first line.
Columns: exit code, uhdm-cmp lines and strict verdict, pristine -> law8, then the golden line overlap (drivers/overlap.py, pristine -> law8).

| case | law | shape | pristine | law8 | overlap |
|---|---|---|---|---|---|
| AM/am01 | § addOperandConstMint475 | typedef'd PA=6'd33, PB=PA, PC=PA+6'd1, PD=PA+1, imported, `PC ^ PD` | 64 NOT_EQUAL | STRICT_EQUAL | 2256 -> 2360 of 2606 |
| AM/am02 | § addOperandConstMint475 | hex PA, PA+6'd1 (INT) beside PA+1 (UINT) | 64 NOT_EQUAL | STRICT_EQUAL | 1696 -> 1768 of 1770 |
| AM/am03 | § addOperandConstMint475 | untyped PA=6'd33 | 17 NOT_EQUAL | 17 NOT_EQUAL (head: PB's implicit typespec, residue 4) | 913 -> 967 of 973 |
| AM/am04 | § addOperandConstMint475 | a module's own parameters | 64 NOT_EQUAL | STRICT_EQUAL | 831 -> 851 of 851 |
| AM/am05 | § addOperandConstMint475 | binary and octal, PC = PA - 6'd1, PE = PD (octal) | 64 NOT_EQUAL | STRICT_EQUAL | 1970 -> 2060 of 2062 |
| AM/am06 | § addOperandConstMint475 | int-typed PA=33 (UINT control), PA*2 | 86 NOT_EQUAL | STRICT_EQUAL | 1339 -> 1403 of 1405 |
| AM/am07 | § addOperandConstMint475 | the UINT leaves (hex, binary, enum, cast, plain decimal) beside 'd leaves | 64 NOT_EQUAL | 64 NOT_EQUAL (same head: the package's `8'(3)` cast fold) | 3114 -> 3431 of 3445 |
| AM/am08 | § addOperandConstMint475 | module, generate-block localparam, child override | 64 NOT_EQUAL | 64 NOT_EQUAL, head later (the generate block's whole-right-side fold) | 1137 -> 1141 of 1144 |
| HC/hc01 | § refChainHexWrittenCase475 | lower, upper and mixed hex chains | 60 NOT_EQUAL | STRICT_EQUAL | 2404 -> 2412 of 2418 |
| NT/nt01 | § elabRhsSharesDefParamChain475 | two levels down, middle and leaf read PB | STRICT_EQUAL | STRICT_EQUAL (bytes move) | 1954 -> 1954 |
| NT/nt02 | § elabRhsSharesDefParamChain475 | generate-nested child and instance array | 17 NOT_EQUAL | 17 NOT_EQUAL (same head, `work@sub.y` net) | 1925 -> 1925 |
| NT/nt03 | § elabRhsSharesDefParamChain475 | interface instance importing b | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL fullname (pass 473's MC/mc10 face) | 919 -> 916 (weakly-referenced tail only) |
| QR/qr01 | § pkgQualCaReadValueForm475 | a::PA, a::PI, a::PL with no import | 32 NOT_EQUAL | 17 NOT_EQUAL, head later (int read typespec, residue 2) | 912 -> 915 of 918 |
| QR/qr02 | § pkgQualCaReadValueForm475 | b::PB, b::PI with an import of b | 17 NOT_EQUAL | 17 NOT_EQUAL (same head) | 1099 -> 1098 (tail only) |
| QR/qr03 | § pkgQualCaReadValueForm475 | seven bases, one module | 13 NOT_EQUAL | 13 NOT_EQUAL (same head: the package's untyped `'d` parameter typespec) | 1825 -> 1831 of 1858 |
| QR/qr04 | § pkgQualCaReadValueForm475 | qualified read beside an import, var init | 32 NOT_EQUAL | 17 NOT_EQUAL, head later (the variable initializer's typespec) | 1187 -> 1190 of 1194 |
| QR/qr_d | § pkgQualCaReadValueForm475 | `assign y = a::P`, P = 6'd33 | 32 NOT_EQUAL | STRICT_EQUAL | 307 -> 310 of 312 |
| QR/qr_u | § pkgQualCaReadValueForm475 | P = 'd9 | 32 NOT_EQUAL | STRICT_EQUAL | 307 -> 310 of 312 |
| QR/qr_b, qr_h, qr_s | § pkgQualCaReadValueForm475 | binary, hex and signed controls | STRICT_EQUAL | byte-identical | — |
| QR/qr_i | § pkgQualCaReadValueForm475 | int control (typespec face, residue 2) | 17 NOT_EQUAL | byte-identical | — |
| QR/qr_o | § pkgQualCaReadValueForm475 | octal, abstained (residue 3) | 32 NOT_EQUAL | byte-identical | — |
| RC/rc01 | § pkgReadRefChainLitForm475 | untyped and hex chains, unqualified and qualified | 17 NOT_EQUAL | 17 NOT_EQUAL (same head: residue 4) | 1638 -> 1654 of 1660 |
| RC/rc02 | § pkgReadRefChainLitForm475 | var init, override, `PB + 6'd1`, `{1'b0, PB}` | 64 NOT_EQUAL | 64 NOT_EQUAL, head later (the variable initializer, residue 5) | 1995 -> 2004 of 2078 |
| RR/rr01 | § elabImpRefDecRespell475 | decimal and hex chains through an import | 60 NOT_EQUAL | STRICT_EQUAL | 1964 -> 1894 of 2020 (tail only; the tree moves to golden) |
| RR/rr02 | § elabImpRefDecRespell475 | octal and binary two-hop chains in a child | 60 NOT_EQUAL | STRICT_EQUAL | 2227 -> 2240 of 2244 |
| RR/rr03 | § elabImpRefDecRespell475 | CONTROL a module's own chain | STRICT_EQUAL | byte-identical | — |
| XK/xk01 | § caReduceLeavesOpKept475 | `^`, `~^`, `===` over module parameters | 50 NOT_EQUAL | STRICT_EQUAL | 715 -> 763 of 763 |
| XK/xk02 | § caReduceLeavesOpKept475 | imported, and `(PA ^ PB) + 6'd1` | 86 NOT_EQUAL | 112 NOT_EQUAL, head later (the `+` over XOR, residue 6) | 1133 -> 1216 of 1312 |
| XK/xk03 | § caReduceLeavesOpKept475 | net declaration, variable initializer, port actual | 46 NOT_EQUAL | byte-identical (not reached, residue 6) | — |
| XK/xk04 | § caReduceLeavesOpKept475 | literals `6'd33 ^ 6'd5`, `3 ^ 5` | 58 NOT_EQUAL | STRICT_EQUAL | 361 -> 401 of 401 |
| XK/xk05 | § caReduceLeavesOpKept475 | generate block, localparam, signal operand | 90 NOT_EQUAL | byte-identical (generate scope not reached, residue 6) | — |
| XK/xk06 | § caReduceLeavesOpKept475 | `^~`, `!==`, `==?`, nested | 50 NOT_EQUAL | 76 NOT_EQUAL, head later (the nested `+`, residue 6) | 836 -> 884 of 913 |

**Tally:** 12 NOT_EQUAL -> STRICT_EQUAL (am01, am02, am04, am05, am06, hc01, qr_d, qr_u, rr01, rr02, xk01, xk04). Nine movers move their head later or keep it with a higher overlap. Eight are byte-identical controls. No case moves its head earlier in the walk, and none lowers its golden overlap outside the weakly-referenced tail.

**The brief's targets** (drivers/runcase.sh on the earlier passes' own case dirs):

| case | pristine | law8 |
|---|---|---|
| r11u471 EX/ex07 | 64 NOT_EQUAL | STRICT_EQUAL |
| v11u469 VT/vt14 | 64 NOT_EQUAL | STRICT_EQUAL |
| v11u469 VM/vm01 | 64 NOT_EQUAL | STRICT_EQUAL |
| v11u473 VX/vx01 | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| v11u473 VA/va04 | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| v11u473 VA/va10 | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| r11u473 MC/mc06 (`PA ^ PB`, pass 473's residue) | 86 NOT_EQUAL | STRICT_EQUAL |
| r11u473 PO/po03 | 64 NOT_EQUAL | STRICT_EQUAL |
| v11u473 VC/vc02 | 68 NOT_EQUAL | STRICT_EQUAL |
| v11u469 VT/vt08 | 64 NOT_EQUAL | STRICT_EQUAL |
| v11u409 VW/vw01 | 64 NOT_EQUAL | STRICT_EQUAL |
| v11u467 VU/vu10 | 64 NOT_EQUAL | STRICT_EQUAL |
| v11u471 VI/vi05 | 64 NOT_EQUAL | STRICT_EQUAL |
| v11u471 VI/vi08 | 64 NOT_EQUAL | STRICT_EQUAL |

## Switch check (evidence/switch_check_grid.txt, evidence/switch_check_away.txt)

- `R11U475_OFF=1` on law8 gives pristine's bytes and exit code on 34 of 34 grid dirs and on 67 of 67 away-census movers.
- Each law's own switch moves only the dirs that law fires on.
- A dir that needs one law is restored by that switch alone: am06 and the XK movers by CAXORKEEP, am08 by ADDMINT, the NT dirs and qr02 by ELABRHSDEF, and qr01, qr03, qr04, qr_d and qr_u by QUALCAFORM.
- The other movers need two to four laws together by design. am01 needs ADDMINT, REFRESPELL, READCHAIN and CAXORKEEP; hc01 and rc01 need READCHAIN and HEXCASE; rr01 needs REFRESPELL, READCHAIN and HEXCASE.

## Away census (evidence/away_census.txt; drivers/awaybytes.sh)

- **Scope:** every case dir of passes 401 to 473 and their verifier twins, 8856 dirs after the fence filter. Each dir was run by pristine and law8 (dut.sv --single-unit --nobuiltin), comparing exit code and md5.
- **Exit codes:** no exit code moves.
- **Byte movers:** 67, every one exit 0. Each was then run against its Surelog golden (drivers/runcase.sh):
  - **17 to STRICT_EQUAL:**
    - r11u471 EX/ex07, TF/tf07, tf09;
    - r11u473 MC/mc06, PO/po03;
    - v11u409 VW/vw01;
    - v11u411 VE/ve08;
    - v11u467 VU/vu10;
    - v11u469 VM/vm01, VT/vt08, vt14;
    - v11u471 VI/vi05, vi08;
    - v11u473 VA/va04, va10, VC/vc02, VX/vx01.
  - **Head later:** v11u409 VW/vw07 and v11u423 VC/vc09 (64 -> 17 uhdm-cmp lines).
  - **The other 48 keep their verdict and their uhdm-cmp head.** The STRICT_EQUAL ones stay STRICT_EQUAL, and no strict verdict leaves STRICT_EQUAL.
    - Their bytes move in the weakly-referenced tail (the clone the elaborated Rhs now shares, § elabRhsSharesDefParamChain475) or toward golden in the tree.
    - The golden line overlap falls only by tail objects (checked by diffing the dumps above the `weaklyReferenced` line on every dir whose overlap fell).
## Census before the sweep, prediction and the sweep

- **The census** (drivers/census.py, evidence/census_law6.tsv, evidence/PREDICTION.txt) ran pristine and law6 on the slang side of every fence-filtered row-mode, from the row's own directory with the sweep's own arguments. The rows were probe 4087, surelog 789 + 784, uhdm2rtlil 870 + 870, downstream 870 and sv-tests 2346.
- **Census result:** 0 exit-code movers. 0 byte movers in probe, surelog, uhdm2rtlil and downstream. One sv-tests byte mover, generated/rsd/rsd.sv, a SURELOG_CRASH row with no golden, so its status cannot move.

**The one five-stage sweep on law8** (`tests/sweep.sh --jobs 3 --workdir /tmp/r11u475_sw` with SLANG_UHDM=law8 and R11U475_TRACE on):
- The four corpus stages ran from the worktree. The sv-tests stage ran through the main tree's tests/sweep.sh, since the worktree's UVM folder is empty. That command reads `law index STALE` on the main tree, which pass 468 had moved to e8a5bf18e during this pass. The worktree's own index is current.
- **probe:** EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions/conversions/changes 0/0/0.
- **surelog:** default CMP_EQUAL 480, testflags 474, 0/0/0 (Tnoc d/t CMP_NOTEQUAL standing).
- **uhdm2rtlil:** 803/1/67 in both modes, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL standing).
- **downstream:** IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871, "not identical and not excused" 0.
- **sv-tests** (the main tree's command compares against the main tree's baseline, which pass 468 had already promoted, so it printed its three uvm_scoreboard conversions as "regressions"; re-read against this base's results/golden_svtests.csv with scripts/compare_results.py):
  - EQUAL 1932, STRICT_NOTEQUAL 0, DIFFERENT 8, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 7 and TIMEOUT 2 of 2346;
  - regressions 0, conversions 0 and one change, generated/rsd/rsd.sv SURELOG_CRASH -> TIMEOUT.
  - **The rsd change is a load artefact.** rsd's slang side takes 110.8 s on pristine and 114.2 s on law8 alone (drivers/timeit.py, 3.1 GB both) against the runner's 120 s cap, and the sweep ran three jobs.
  - **Rerun:** the row alone (scripts/check_svtests.py --filter generated/rsd/, jobs 1) reads SURELOG_CRASH with regressions/conversions/changes 0/0/0.
  - **Final reading:** EQUAL 1932, DIFFERENT 8, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 (uvm_tb_build_ss_tb, the standing Surelog-side timeout), 0/0/0. No row moves, as predicted.
- **Byte check** (drivers/bytecmp.py, evidence/sweep_bytecmp.txt): the sweep's kept databases against the census's pristine databases of the same rows (same cwd and arguments). The master's control /tmp/intr11u473 had been rotated away for pass 468's landing. The negative control flags every row.

  | lane | identical of compared |
  |---|---|
  | probe | 4087 of 4087 |
  | surelog default | 480 of 480 |
  | surelog testflags | 474 of 474 |
  | uhdm2rtlil default | 803 of 803 |
  | uhdm2rtlil testflags | 803 of 803 |
  | downstream | 804 of 804 |

  **NO CORPUS MOVER**, exactly as predicted.
- **The sweep's trace:** addOperandConstMint475 decided INT 10 times on three databases (probe r10vrgg3repro/xl_deep_transitive, surelog HierPathStructTypespec d/t), with no byte moving on any of them (the byte check above): the decision is logged before the caller, which rewrites only a `UINT:` value. On sv-tests the trace fired on rsd alone (addOperandConstMint475 42 decisions, pkgReadRefChainLitForm475 5), the census's one byte mover; rsd has no golden.

## Downstream on the grid (evidence/downstream_cases.txt; downstream_uhdm2rtlil.one with the harness flags)

- **Six cases go EQUIVALENT -> IDENTICAL:** AM/am01, am04, am05, RR/rr02, XK/xk01 and xk04. The unreduced XOR and the INT/UINT forms are what the plugin reads.
- **Five stay IDENTICAL on both binaries:** RR/rr01, QR/qr_d, NT/nt01, HC/hc01 and RC/rc02.
- **One stays EQUIVALENT on both:** XK/xk06, whose nested `+` is residue 6.
- None moves away.

## Canaries

On the sweep csvs, canaries.sh reads ok=52 (surelog) and ok=16 (uhdm2rtlil) with changed=0. Both ctcan2 checks pass: surelog ok=58 with EXPECT_UNKNOWN=1, and uhdm2rtlil ok=2 with EXPECT_UNKNOWN=6.

## Goal 1 (re-measured on the base)

- **SURELOG_ONLY rows:** all 75 SURELOG_ONLY rows of results/golden_svtests.csv carry an upstream slang `error:`, and no row of any status carries the exporter's own unsupported message.
- **The probe faces on law8:**

  | face | case | ours | upstream slang | Surelog |
  |---|---|---|---|---|
  | C::mk().arr[1] | v11u413 VC/vc04 | 4 | 0 | 3, [SNT:PA0207] syntax error |
  | u.mk(x).a[2] | v11u413 VI/vi06 | 4 | 0 | 3, syntax error |
  | this.mk().inner.s | v11u415 VT/vt03 | 0 | 0 | 3, syntax error |

  Surelog rejects all three, so golden has no shape for them. They are not forced.
- **Black-parrot:** bp_unicore's slang side was run alone on a quiet machine on law8 (the runner's own recipe, drivers/timeit.py, evidence/bp_unicore_law8.txt), with the guard of § macroVecLitTokenText403 on.
  - It exits 3 in 21.4 s at 836 MB maximum RSS.
  - No memory-bounded export exists, so the guard stays and the six rows stay SURELOG_CRASH (Surelog crashes first).
- **rsd:** generated/rsd/rsd.sv stays SURELOG_CRASH.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **The variable initializer's read of a package parameter.** Golden `INT:33` (the Value) where ours writes `UINT:33` (RC/rc02, the scratch v01). This holds for a direct literal too. It is ModuleEmit's variable-initializer branch (pass 473's IA/ia12 face): reported to the sister.
2. **A qualified read of an `int`- or typedef-typed package parameter carries a typespec in ours that golden does not have** (QR/qr_i, qr01, v11u473 VC/vc10). The stamp is not ExprEmit's qualified-read gate, which already abstains on `::`. Not located.
3. **The qualified OCT read** (QR/qr_o). Golden is `UINT:33` and shared. The law abstains, because the UINT value takes ModuleEmit's elaborated whole-right-side own-copy road: see "Sister-ground faces".
4. **An untyped parameter defined by a reference** (`parameter PB = PA`): golden writes no implicit int_typespec, where ours mints one (AM/am03, RC/rc01). This is ParamEmit's implicit-typespec derivation; not written.
5. **The continuous-assignment fold `PB + 6'd1`** (RC/rc02, g08): golden `INT:34` where ours writes `UINT:34`. tryFoldConst's `isIntEncoded` asks no DEC leaf. This is the CompileExpression Value algebra (SValue::plus follows its left operand's type), not ExprEval's add branch. Not written.
6. **XOR faces the law does not reach:**
   - `(A ^ B) + 1`, where golden keeps the `+` because its XOR operand never reduces (XK/xk02, xk06);
   - a variable initializer and a port actual (xk03);
   - a generate-scope continuous assignment (xk05, a different fold site).
7. **v11u473's unreached folds:** a function return (VA/va02), a function argument (VD/vd04, where golden's typespec is the formal's), and a replication operand (VD/vd07). Each is a typespec presence face at the fold; not decoded.
8. **The package's `8'(3)` cast fold** (AM/am07) and **the generate-block localparam's whole-right-side fold** (AM/am08). Older faces.
9. **The carried lists** of passes 473 and earlier (their READMEs), and the open DIFFERENT rows at the sister's heads. After pass 468 the open rows are easyUVM, p733, p737, tnoc and uvm_param_vif_config_db. p733, p737 and tnoc await the user's decision.

## Sister-ground faces (reported, not written)

- **ModuleEmit's elaborated whole-right-side own copy of a UINT constant** (§ elabCaReusesParamValueConst's family). For a QUALIFIED package read, golden shares the one constant and writes no typespec (QR/qr_o, `assign y = a::P` with P = `6'o41`, golden `UINT:33` shared). This blocks the OCT half of § pkgQualCaReadValueForm475.
- **ModuleEmit's variable-initializer branch.** It writes the package parameter read as UINT digits where golden writes the Value form (`INT:33` for a DEC parameter; RC/rc02, pass 473's IA/ia12).
- **The interface instance's reference full name** (NT/nt03, pass 473's MC/mc10).

## Integration note

Pass 468 (the sister) landed on main at e8a5bf18e during this pass. The patch applies cleanly there except tests/LAWS.md, which regenerates at integration. Pass 468 touches only ModuleEmit, UhdmExporter and TypeEmit, and this pass touches only ExprEmit and ParamEmit.

## Process

- **Budget.** No pristine sweep and no pristine build of my own: the pristine is a copy of the main tree's build, reproduced by the worktree's first build. law1 to law8 were used on case runs. There was one census (pristine against law6) before the sweep, and one full five-stage sweep on law8. The away census ran on law4 during development and was rerun on law8 after the sweep; the README reports the law8 run (evidence/away_census.txt). bp_unicore and rsd were each timed alone after the sweep.
- **Fence.** The fence list was read into a file by a program without printing it. Every tree-wide list was filtered on it first (the census, the away census, the byte check), and every evidence file is filtered on it.
- **Isolation.** No other agent's process was touched. No sweep or runner overlapped another (pgrep before every launch).
- **Slips, none affecting a measurement.** A first per-base case generator split `logic [7:0]` on its own `:` separator and was rerun with `|`. A first walk-record dump was attempted on stage-1-unequal pairs, which strictcmp does not dump. The trace placement of three laws was tightened (law6 -> law8) after the census showed decisions logged where nothing changed.

Files: cases/ (34 dirs), drivers/ (runcase.sh, pas.py, overlap.py, awaybytes.sh, census.py, bytecmp.py, swcheck.sh, r11u475_launch.sh), evidence/ (grid_law8.txt, switch_check_grid.txt, switch_check_away.txt, away_census.txt, census_law6.tsv, PREDICTION.txt, sweep_bytecmp.txt, sweep/).
