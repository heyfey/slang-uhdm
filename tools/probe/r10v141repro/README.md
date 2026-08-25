# r10v141 — ADVERSARIAL VERIFICATION of r10uvm141 (§ qualLifetimeStubListsNoBodyLocals141)

**VERDICT: ACCEPT.** Production is one term and it is correct on every face
this verifier could reach. Every headline number in the implementer's report
reproduces bit-for-bit from independently built binaries. One defect was found
and fixed here, and it is arithmetic in the pass's own census prose, not code.

Base `c695e97`; worktrees built from scratch by this verifier; both binaries
frozen `chmod 555` before any sweep; every `cmds.txt` audited by BINARY PATH.

---

## 1. Reproduced, bit-for-bit

| claim | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `3e74edcd1880a7142b25e7fa2e0f92e1` | same |
| patched binary md5 | `0647faa1f2ddbc93c9b390ea1badce25` | same |
| goldens | 23/0, `/bin/false` 0/23 | same (pristine 23 too) |
| uhdm2rtlil both modes | 679 / 50 / 2 | same, both binaries |
| surelog `--mode both` | def 471/283/25/10/5, tf 466/284/23/9/5/3/2/1/1 | same, both binaries |
| `ct8rows` vs committed baselines | PASS, 0 differing rows over 1588 | same; u2r PASS both modes |
| `cmds.txt` audit | 1523/1523 surelog name the frozen binary | same (1523 slang invocations, 0 other, 50 golden-cache rows carry no slang line); u2r 1458/1458 |
| byte movers | surelog 2/956, u2r 0/1358 | same, `SELFCHECK` live (955/956, 1357/1358) |
| a-priori prediction (`pred141`) | 2 CANDs by name of 956; 0 of 1358 | same, rebuilt and re-run on THIS verifier's pristine sweep |
| whole-dump order-blind diff | 32 removed, 0 added, all `uvm_reg_map::ceil::r`/`r0` | same, both modes |
| heads | BuildUVMPkg 83→55 both modes; the other 12 rows unchanged | same; all 24 committed head logs byte-identical after path/id normalisation |
| corpus census | 5 tests × modes, 0/0 after; BuildUVMPkg 1/1 → 0/0 | same, all nine databases |
| canaries / ctcan2 / canaudit | 52 / 8 / PASS / `audited=29 UNCOVERED=0` | same |
| protected DBs | InterfaceModPort, BlackParrotComplex, YosysOldOr SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | same |
| boundary | LISTED=4079 PROCESSED=4079 MOVED_ARMS=5 RC_DIFFS=0 | LISTED=4082 PROCESSED=4082 PRODUCED_DBS=3938 MOVED_ARMS=8 RC_DIFFS=0 — the same 5 plus this verifier's own 3 arms |
| `r10uvm46repro/t64a` re-measured | 3930→3874 DEF, 4546→4490 ELAB, head object unchanged | same, and the census rows match line for line |
| arms A/B/C endpoints | A 8→1, B →1/3, C →0/1, both views | same |

`results/*.csv` untouched; no row converted; patch surface is
`src/TaskFuncEmit.cpp` + `tools/probe/r10uvm141repro/` only; the four
slang-fenced names appear in no artifact but `canaudit.sh`'s own fence list.
The patch applies clean on a FRESH `c695e97` and `-3` clean on `eca73296` and
on `c8873907`.

## 2. The head decode, re-derived from the sources

`~/.local/include/uhdm/BaseClass.h:220` is the vector overload's
`lhs == nullptr && rhs != nullptr && !rhs->empty()` branch: it sets
`m_failedRhs` only, so a `LHS: <null>` head prints the **container**, and
golden's vector is null. `generated/src/scope.cpp:340` compares `Variables()`
before `task_func::Compare`'s `Return` / `Io_decls` / `Stmt`
(`generated/src/task_func.cpp:180/182/183`). The field is `vpiVariables`.

`CompileStmt.cpp:1839` `setFuncTaskQualifiers`: the two unwrapping `if`s at
`:1844`/`:1848` fire only when the node handed in IS the
`paFunction_declaration`/`paTask_declaration`. `paFunction_declaration` is NOT
in the `while` condition's type list, so with a qualifier in front the loop
consumes the qualifier and **exits still holding the wrapper**;
`compileFunction`'s `Function_body_declaration = fC->Child(func_decl)`
(`:2337`) then reads the LIFETIME node whenever a lifetime is written, and its
guard `if (func->Io_decls() || func->Variables() || func->Stmt())` (`:2368`)
names the three vectors that all come from it. Without a qualifier the same
loop reaches `paLifetime_Automatic` at `:1907` as a SIBLING and stamps
`vpiAutomatic` — which is exactly why the stub never carries it and the
non-stub does. Model confirmed independently.

## 3. Breaking the law — four NEW grids, 30+ faces, zero regressions

Sources here; each built with Surelog in BOTH views and both frozen binaries,
scored by the pass's own `cen141.py` multiset join, judged by the official
`uhdm-cmp`, every child rc printed.

| arm | faces | wrong cells DEF | wrong cells ELAB | cmp lines |
|---|---|---|---|---|
| D `v141_d_owners.sv` | owners: `$unit` class, package class, DERIVED class OVERRIDING a base virtual, wildcard-IMPORTED class, INTERFACE-owned class, PROGRAM-owned class, class inside a MODULE GENERATE block | 7 → **2** | 8 → **3** | 4068→3872 / 4898→4702 |
| E `v141_e_shapes.sv` | body-local shapes: STATIC local, local inside `fork/join_none`, local SHADOWING a class property, packed-struct + unpacked-array locals, CLASS-HANDLE + QUEUE locals (the R0 shape), `void` function, task with an OUTPUT formal, a local feeding `$bits` | 9 → **2** | 9 → **2** | 4596→4270 / 6276→5950 |
| F `v141_f_styles.sv` | styles: in-body, `extern` prototype + out-of-body definition (lifetime on either half), `pure virtual` + implementing override; names colliding with a PACKAGE FREE FUNCTION (`ceil`) and with a system-function spelling (`clog2`); REFERENCED vs UNREFERENCED; 3 specializations of a parameterized class; 1 vs 3 instances | 6 → **1** | 6 → **1** | 7382→7218 / 9714→9550 |
| G `v141_g_mix.sv` | an affected method NEXT TO four unaffected siblings and a constructor in the SAME class; TWO qualifiers + a lifetime (`local static function automatic`); `virtual protected function automatic` | 4 → **1** | 4 → **1** | 3764→3652 / 4904→4792 |

**No cell moved away, in either view, in any arm.** No `ONLY-OURS` row appeared
that was not already there, and the suppression does **not** leak to siblings:
arm G's `sib1`/`sib2`/`sib4` and the constructor stay byte-identical to golden.

Measured negatives confirmed independently: the WRITTEN LIFETIME is the
distinguisher, not which qualifier or how many; reachability, instance count
and specialization count are not distinguishers; a name colliding with a
package function or a system-function spelling changes nothing (the stub has no
name to collide with); the out-of-body definition keeps its body local on BOTH
sides, which is why pass 46's `!oob` exclusion is right.

Must-stay controls, all listed by the boundary and all UNMOVED:
`r10uvm127repro` (6 arms), `r10uvm113repro` (4), `r10buvm32repro` (3),
`r10uvm138repro` (4), plus `r10uvm107/109repro`, `r10uvm89repro`,
`r10buvm14repro`, `r10sd8repro` (37), `r10sd12repro` (108) and every other
committed family. The only earlier-pass arms that moved are pass 46's and pass
47's `t64a/dut.sv` — the arms of the law this pass extends — and they move
TOWARD golden.

## 4. The one defect found, and fixed here

`CENSUS.r10uvm141.txt:30` and `:40` and `README.md:51` derived the wrong TOTAL
from a correct table. The nine measurable UVM databases hold
8358+8358+4751+4751+4799+14892+14892+4244+4244 = **69,289** class-method rows on
each side, not 60,494. Every per-database number in the table is right and the
conclusion is unaffected (two wrong cells pristine, zero patched). Corrected in
place; **no production change**.

## 5. Ranked residues this verifier measured

1. **R0 (unchanged, confirmed)** — the new BuildUVMPkg head, both modes, 55
   lines: `LHS: array_var uvm_pkg::uvm_reg_map::unregister::q` with
   `RHS: <null>` at line 55 (the SINGULAR overload), the queue-of-class body
   local `uvm_reg_block q[$]` at `pp_output:75268`. Arm E's `ea5::f5` builds
   the same shape (`int q[$]` plus a class handle) and it is CORRECT there
   post-patch, so the R0 gap is not the queue local per se.
2. **R1 (implementer's, confirmed on four independent witnesses)** — a
   non-stub class method whose declaration writes `automatic` carries
   `vpiAutomatic` in golden and not in ours (`TaskFuncEmit.cpp`'s automatic arm
   is gated `&& !classScope`; Surelog stamps it at `CompileStmt.cpp:1907`).
   Witnesses: arm E `eb1::g1`, arm F `fb_extdef::e1` (out-of-body), arm G
   `ga_mix::sib3`, pass 46's `t64a f_auto_2tok`. It is the LAST wrong cell in
   arms A, E, F and G. Corpus-invisible over all 69,289 census rows.
3. **NEW — the VOID qualifier+lifetime stub loses `vpiReturn`.** Golden's stub
   for `local function automatic void f6(...)` prints
   `vpiParent, vpiFullName, vpiMethod, vpiVisibility, vpiReturn`; we print it
   without `vpiReturn`, because pass 46's return arm is gated
   `if (isFunc && qualLifetime46 && !sub.getReturnType().isVoid())`
   (`TaskFuncEmit.cpp:3351`). Golden mints the bare `logic_var` regardless,
   since the return type it reads is the same invalid lifetime node. PRE-
   EXISTING (pristine is wrong the same way); pass 141 fixes the variables half
   of that cell and leaves this half. Witness: arm E `ea6`. Corpus-invisible.
4. **R2 (implementer's, confirmed)** — several qualifier+lifetime methods in
   ONE class fuse into ONE golden object; we emit one stub per declaration
   (`t64a` 4 vs 1 after this pass). Unimplemented by design; no corpus source
   has two in one class.
5. **Pre-existing, untouched, surfaced by arm D** — for a class owned by an
   INTERFACE (`work@di_iface`) or declared inside a MODULE GENERATE BLOCK
   (`work@t141d::dgen`) golden lists the method stub and we list **no method
   object at all** (they are `ONLY-GOLDEN` with no `ONLY-OURS` partner in BOTH
   the pristine and the patched census). Unrelated to this law.

## 6. Files

`v141_d_owners.sv` `v141_e_shapes.sv` `v141_f_styles.sv` `v141_g_mix.sv` — the
four verifier grids. Build and score them with the pass's own
`../r10uvm141repro/arm141.sh` and `../r10uvm141repro/score141.sh`
(`PRIS=<pristine> PATCHED=<patched> arm141.sh <file.sv> <outdir>`, then
`PAT=<row-regex> score141.sh <outdir>`). `v141_f_styles.sv` deliberately avoids
the identifier `use` — it is a keyword and slang rejects it as a method name.
