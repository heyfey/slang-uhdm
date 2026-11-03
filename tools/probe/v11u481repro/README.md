# v11u481 — adversarial verification of r11u481

Verifier of pass 481 (expression/parameter ground, base 24db9b73b). Implementer's patch:
/tmp/r11u481.patch; verified patch: /tmp/r11u481.verified.patch.

## Verdict

**CONFIRMED WITH TWO BREAKS FIXED.** The attack grid found two breaks on legal SV that
upstream slang accepts. Both are in § vifTdRefVarLocalImplicitNet481 (ExprEmit), and in
both pristine was right or closer. Both are fixed behind their own switches. Neither the law
nor the fixes fire on any corpus row, probe case or sv-tests row.

| break | shape | pristine | law | verified |
|---|---|---|---|---|
| 1 | a statement call that is a class method `c.m(g == null);` (VA/va09), an interface task through an instance `u.tk2(g == null);` (va34), `void'(c.f(g == null));` (va48), `void'(u.f2(g == null));` (va57), the method statement in a nested begin (va47) | STRICT_EQUAL | NOT_EQUAL (215 to 486 uhdm-cmp lines) | STRICT_EQUAL, pristine's bytes |
| 2 | a parameter of the local's name visible in the module: wildcard-imported (va37), explicitly imported (va52), from a second wildcard package (va54), a `$unit` parameter (va51) | NOT_EQUAL 50 / 58 lines | NOT_EQUAL 298 to 524 lines, an extra minted wire | pristine's bytes |

- **Break 1.** The law's binding window counted a statement call only at the plain user-call
  site. Golden keeps Surelog's compile-time ref_var binding for any subroutine call written
  as a statement.
- **Break 2.** Surelog's late binder meets the parameter and writes its constant. The law
  minted a wire, where pristine left the ref_var binding.
- **Side effect of the fix.** Two law cases that already improved now become STRICT_EQUAL:
  - va49 and va60: STRICT_NOTEQUAL col on the law, STRICT_EQUAL verified.
  - On those two, the window arguments keep the ref_var, and a later plain reference takes
    the wire.

## Fixes (each through src/LawSwitch.h fixOn; R11V481_OFF gives the law's bytes on all 156 dirs)

- § stmtMethodCallArgWindow481v (ExprEmit, R11V481_STMTMETHOD_OFF)
  - The non-system call branch raises the law's statement-call counter for EVERY call in
    statement position (callStmtCtx0), not only at the user-call site.
  - A second side counter covers a statement call of a subroutine declared in a module or
    interface body (`u.tk2(...)`), which opens no § classArgBind12 window.
  - The law's window test reads `(classArgBindDepth12 > 0 || that counter) && statement
    counter`.
  - Expression-position method calls still mint, as golden does: va45 `x = c.f(g == null);`
    and va46 `x = u.f2(g == null);` are STRICT_EQUAL on the law and on the verified binary.
- § visibleParamAbstain481v (ExprEmit, R11V481_VISPARAM_OFF)
  - Before minting, the law looks the name up from the instance body (slang
    Scope::lookupName). It abstains when the lookup finds a non-variable symbol.
  - A visible package or `$unit` VARIABLE of that name does not stop golden's mint, so it is
    kept: va50 (`$unit` int g) and va53 (package int g) are STRICT_EQUAL on both binaries.
- Each fix switch alone restores the law's bytes on exactly its own movers:
  - STMTMETHOD: va09, va34, va47, va48, va49, va57, va60
  - VISPARAM: va37, va51, va52, va54
  - Evidence: evidence/swcheck.txt.
- No src/R*.h, no getenv, no header change. The new bookkeeping is one static side counter
  beside the implementer's.

## Reproduction of the implementer's numbers

- Law binary rebuilt from the patch: md5 d5d1fa792f08f836da605ffe18607076, equal to the
  implementer's law6.
- Pristine: a copy of the implementer's frozen pristine, 7347b3417a262cd8ca085f3e8a13ed5c.
- Verified binary: 780b72b98d1261dda2a0025ff7c3e04f.
- Grid of 82 dirs (evidence/impl_grid_pristine_law.txt): 81 of 82 match on rc, uhdm-cmp
  lines, strict verdict and dump distance.
- **RN/rn52 is a misreading.** The README says golden's database is broken there (no
  package listed). Surelog gives one dump in 9 of 9 draws (3 serial, 6 concurrent), and that
  dump lists package t. Against it rn52 reads:

  | binary | uhdm-cmp lines | strict verdict | dump distance |
  |---|---|---|---|
  | pristine | 446 | NOT_EQUAL | 35 |
  | law | 0 | STRICT_EQUAL | 26 |

  The implementer's cached Surelog dump for that dir lacks the package listing. So the grid
  reads 63 / 2 / 17 on law6, not 62 / 2 / 18.
- The verified binary is byte-identical to the law on all 82 implementer dirs.
- R11U481_OFF on the verified binary gives pristine's bytes on all 156 dirs (82 + 74).
- The implementer swept law3, not law6. This verifier's law sweep is the first full sweep of
  the final law binary.

## Attack grid (cases/VA, VB, VC + NEG; evidence/grid.txt)

- 74 fresh case dirs, each accepted by upstream slang (rc 0). The negative control NEG/neg01
  reads rc 1 upstream and rc 3 on all three binaries. Every other exit code is 0 on all
  three binaries.
- Two dirs written as attacks, a `t::vt_t` local without an import and a class property in
  `$unit`, crash Surelog and were dropped.

| | pristine | law (d5d1fa79) | verified (780b72b9) |
|---|---|---|---|
| STRICT_EQUAL | 14 | 41 | 48 |
| STRICT_NOTEQUAL | 9 | 6 | 4 |
| NOT_EQUAL | 51 | 27 | 22 |

- On the law binary 5 dirs read a worse verdict than on pristine: va09, va34, va47, va48 and
  va57. On the verified binary none does. 34 dirs move to STRICT_EQUAL on the verified binary.
- **VA, 54 dirs, the implicit-net law.** Shapes that mint, all toward golden:
  - mailbox and process locals
  - always @(posedge clk), final, foreach and while bodies
  - do-while conditions, a delayed use, a for-if at deeper depth
  - two processes with locals of one name, a non-top child instance, two module definitions
  - the source order among implicit wires: before or after a continuous-assign implicit wire
    or a port-connection implicit wire (va61 to va64), and two instances (va65)
  - Remaining head on va65: ModuleEmit's full name of the continuous assign's implicit
    left side, work@sub.zz where golden writes work@top.a.zz. This is pre-existing and the
    sister's.
- **VB, 9 dirs, the span law.** The shapes:
  - a named parameter `#(.W(8)).mp`, two parameters
  - explicit import, re-export, a class property, a package function local
  - vb01 to vb03, vb07 and vb08 go STRICT_NOTEQUAL endcol -> STRICT_EQUAL
  - The `$unit` and module typedef branches keep the old span (vb05, vb06), as the implementer
    said (§ 402 / § 410 branches, the sister's).
- **VC, 9 dirs, the initializer law.** The shapes:
  - named begin, fork, two declarators, static, a module-variable initializer
  - vc02, vc03, vc05, vc06, vc08 and vc09 go to STRICT_EQUAL
  - Subroutine locals (vc04 module task, vc07 package function) are unchanged: TaskFuncEmit,
    the sister's.
- Dump distance grows on two dirs on the verified binary, and neither is a step away:
  - vc09 reaches STRICT_EQUAL, and its dump distance still grows (15 -> 24).
  - vc01 keeps the same head: golden mints a wire `u` for the interface instance read as a
    value, on both binaries. The bare copy now binds as in golden; only its position in the
    dump's tail of unparented objects differs.
- Downstream (evidence/downstream_grid.txt), 44 dirs: 11 fix movers plus 33 law movers.
  - 42 dirs read IDENTICAL on pristine and verified.
  - va15 and va65 move EQUIVALENT(nohier) -> IDENTICAL.
  - The 11 fix movers read IDENTICAL on the law binary too, so the breaks were visible only to
    uhdm-cmp and the strict comparator.

## Sweeps (one on the law binary, one on the verified binary)

Both sweeps ran with tests/sweep.sh --jobs 3. The four corpus stages ran from the worktree.
The sv-tests stage ran through the main tree's tests/sweep.sh, whose scripts and
golden_svtests.csv equal the base's; the worktree's UVM folder is empty. The machine was
quiet for each launch.

- **Law sweep (/tmp/v11u481_sw)**
  - Stage results:
    - probe: EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0
    - surelog: 480 + 474, 0/0/0
    - uhdm2rtlil: 803/1/67 in both modes, 0/0/0
    - downstream: 803/66/2/0, not identical and not excused 0
    - sv-tests: EQUAL 1935, STRICT_NOTEQUAL 0, DIFFERENT 5, SURELOG_ONLY 75, BOTH_REJECT 303,
      SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, 0/0/0
  - All five csvs equal /tmp/intr11u479's row for row after workdir normalization.
  - The law trace (R11U481_TRACE) wrote no file. The positive control RN/rn01 does write one.
  - byteverify against the control: surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of
    805, with the selfcheck flagging 961, 1607 and 804.
  - canaries: ok=52 and ok=16; ctcan2 PASS on both.
  - Binary audit, fence-filtered:
    - surelog: 1523 of 1573 records name the law binary, and the other 50 hold only a Surelog
      line
    - uhdm2rtlil: 1740 of 1740
    - sv-tests: 2346 of 2346
  - The two target rows, uvm_param_vif_config_db and easyUVM top, stay DIFFERENT. Their dumps
    are identical to the control's after path normalization.
- **Verified sweep (/tmp/v11u481_sv)**
  - The four corpus stages read as above with 0/0/0. Every csv equals the control's.
  - The trace wrote no file.
  - byteverify verified against law: 0 of 962, 0 of 1608 and 0 of 805. All 4087 probe
    databases are byte-identical.
  - sv-tests: the same counts as the law sweep, 0/0/0, the csv equal to the control's
    (evidence/sweep_verified_svtests.log).
  - canaries: ok=52 and ok=16; ctcan2 PASS on both.
  - Binary audit, fence-filtered: surelog 1523 of 1573 records name the verified binary (the
    other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.

## Away census (evidence/away.tsv)

- Scope: 2590 fence-filtered case dirs under the main tree's tools/probe. Each source holds a
  process or task plus one of the words virtual / mailbox / semaphore / process / typedef.
- Run: pristine against the verified binary, single process, traced.
- Result: no exit code moves, 2585 are byte-identical, and 5 move bytes. All 5 are the
  implementer's external movers:
  - r11u479 LV/lv07 and lv09
  - v11u479 VA/va15 and VL/vl03
  - v11u447 VN/vn20
- No dir fires a trace without moving bytes.

## Goal 1 (re-measured)

- C::mk().arr[1] (v11u413 VC/vc04) and u.mk(x).a[2] (VI/vi06) exit 4 on pristine and
  verified, and 0 upstream.
- this.mk().inner.s (v11u415 VT/vt03) exits 0 on both.
- bp_unicore alone on the verified binary, guard on: exit 3 in 19.4 s at 814 MB max RSS.
  The guard stays.
- All 75 SURELOG_ONLY details carry an upstream slang `error:` diagnostic, and none is the
  exporter's own message.

## Residues (ranked; all wrong on pristine too, none moved away on the verified binary)

1. The implementer's residues 1 to 7 stand: the formal binding (TypeEmit), the subroutine-local
   kinds (TaskFuncEmit), qualified `t::vt_t` in an importing module, a same-named module
   member, the generate-block local, the interface process and task locals, and program locals.
2. An interface instance read as a value (`g = u;`, `vt_t g = u;`): golden mints a logic_net
   `u` in the module and binds the read to it (VA/va01, va30, va59, VC/vc01). Not decoded;
   the reference is ExprEmit's.
3. A statement call of a module task through an instance, `s1.tk(g == null);` (va56):
   NOT_EQUAL at an older face on every binary.
4. The span face in the `$unit` and module typedef branches (VB/vb05, vb06; the sister's).
5. The continuous-assign implicit left side's full name in a non-top instance (va65;
   ModuleEmit, the sister's).

## Sister-ground faces (reported, not written)

- The implementer's list: TypeEmit's formal law for package vif typedef formals, TaskFuncEmit
  § blockLocalTdDeclIsRefVarUnsupported155 site 1, and the ModuleEmit / TaskFuncEmit
  interface paths.
- ModuleEmit's emitContAssigns implicit left-side full name (va65).
- TypeEmit's VirtualInterfaceType span in the `$unit` and module typedef branches (vb05, vb06).

## Process

- Pristine was copied, not built. The law binary was built once. The verified binary was
  built twice, the first build missing the instance-subroutine half; that build was used
  only on case runs. One temporary debug build added trace lines and was used on va34
  alone; its source was reverted before the second verified build. These were all
  `cmake --build build --target slang_uhdm -j 2`.
- One full sweep was run on the law binary and one on the verified binary, never
  overlapping another sweep.
- The fence list was read into a file by a program and never printed. Every tree-wide list
  was filtered on it, and the repro folder was scanned with it.
