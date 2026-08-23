# r10v107 — ADVERSARIAL VERIFICATION of r10uvm107 § `oobRefVarLocalHoistNet107`

**VERDICT: ACCEPT AS SHIPPED.** Every headline number reproduces bit-for-bit from
independent builds; twelve new adversarial arms score **0 AWAY**; the one
characterised hole (§ `tdSuppressesMintPkgOrModScope107`, below) is a
**PRE-EXISTING** property of the shared hoisted-net pool, measured to have
**zero reach** on both corpora and on the whole 3,347-arm boundary.

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `uhdm-cmp` and `scripts/verify_golden.py` are. slang was **NOT**
patched; `results/*.csv` were **READ ONLY**; **no row was converted**.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours** — everywhere below.

| | |
|---|---|
| BASE | `6c74d2a` (fresh worktrees `/tmp/wt_v107` + `/tmp/wt_v107pris`) |
| pristine binary, built here | `26fbd8c01ce0de4b3e257726f388de86` — **identical to the implementer's** |
| patched binary, built here | `3ed8227a2c636825cfefc1da571ab59d` — **identical to the implementer's** |
| production surface reviewed | `src/ExprEmit.cpp` + `include/UhdmExporter.h` only; fence check over the four slang-fenced names: 0 hits each; `results/*.csv` untouched |

## 1. WHAT REPRODUCED, BIT FOR BIT

Both binaries rebuilt from scratch (`-j 2`, md5 taken separately, both frozen
`chmod 555` before any sweep), `SLANG_UHDM` exported explicitly per binary, and
**every** `cmds.txt` audited by binary PATH: 1,573 surelog + 1,460 uhdm2rtlil
files per sweep, exactly **one** distinct slang path each, and it is mine.

| claim | implementer | measured here |
|---|---|---|
| goldens patched / pristine / `/bin/false` | 23-0 / 23-0 / 0-23 | **same** |
| surelog status histogram, both modes | 937 EQ / 567 REJ / 48 SL_FAIL / 19 NE / 10 DEF / 3 NO_DB / 2 UNTR / 1 TIMEOUT / 1 NO_UHDM | **same, both binaries** |
| `ct8rows` committed-vs-patched, pristine-vs-patched, committed-vs-pristine (surelog) | PASS | **PASS ×3** |
| `ct8rows` u2r tf + def, all four comparisons | PASS | **PASS ×4** |
| u2r counts, both modes, both binaries | 679 / 50 / 2 | **same** |
| byte movers | 9/956 surelog, 0/1358 u2r, SELFCHECK 955/956 + 1357/1358 | **same** |
| the nine movers by name | `{default,testflags}/{SimpleUVM,SeqDriver,MiniAmiq,BuildUVMPkg}` + `default/Scoreboard` | **same** |
| SimpleUVM ×2 head | 17 → 17, a NEW object | **same**: `LHS logic_net(work@top.param_t)@290:27 / RHS <null>` → `LHS <null> / RHS logic_net(work@top.rsp_export)@228:3` |
| Scoreboard/default head | 29 → 42, a NEW object | **same**: `RHS ref_var(send_request::param_t)` (uvm105's R-B) → `constant −1 @529:23` |
| SeqDriver 60, MiniAmiq 348, BuildUVMPkg 32, Earlgrey 64, Rggen 0 | unchanged | **same** |
| the three committed `head_*.cmp` files | — | **byte-identical** to my measured heads (object ids aside) |
| fence, surelog | MEASURED=956 SKIP=617 HIT=28 OTHER=27174, 4 MUST-MOVE | **identical, same four names** |
| fence, u2r | HIT=0, 0 databases | **identical** |
| mover predictor | 11 surelog MAY-MOVE, 0 u2r | **identical** (9 measured ⊂ 11 ⊃ the 4) |
| nine UVM databases, `score107.py` | TO-GOLDEN 38 / AWAY 0 / STILL 0 | **identical** (7+7+2+2+2+7+7+2+2 over 454k scored cells) |
| canaries / ctcan2 / canaudit | ok=52, ok=8, PASS ×2, audited=29 UNCOVERED=0 FENCE-BREACH=0 | **same** |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | **same, both modes** |
| boundary file/def + file/elab | PROCESSED=3347 LISTED=3347 DIFFER=11, symmetric rejects | **same** (132=132 def, 142=142 elab), **the same eleven arms in BOTH views** |
| boundary attribution | def 30 TO-GOLDEN / 0 AWAY / 1 OTHER; elab 5 / 0 / 1 | **identical, cell for cell** |

**ORDER-BLIND MOVER ATTRIBUTION, re-done from scratch** (whole dump,
workdir- and id-normalised, sorted): SimpleUVM ×2 and SeqDriver ×2 = **42 lines**
each — four new `logic_net`s (`param_t`@290:27, `req_item`@764:17,
`setting`@3411:35, `t`@171:31) with their Name/FullName/NetType/Parent children,
five `|vpiActual`, minus two `\_ref_var` actuals; Scoreboard, MiniAmiq ×2,
BuildUVMPkg ×2 = **4 lines** each, exactly `2 |vpiActual + 2 \_ref_var`.
**No other object kind appears in any of the nine.**

**NET-LEVEL CHECK the pass did not report** — SimpleUVM/default `work@top`
`logic_net` name+span sets: golden 192, pristine 183, patched 187. The patched
binary gains **exactly** `param_t@290:27`, `req_item@764:17`, `setting@3411:35`,
`t@171:31`, and **golden holds all four at the same name and span**. Nets ours
has that golden lacks: **34 before, 34 after** — the patch adds **zero** spurious
wires to the corpus's flagship database.

## 2. TWO DISCREPANCIES, BOTH RESOLVED AS COIN / STALE

**(a) `DIFFER=8`, not 7, in BOTH dir-mode boundary runs.** My extra directory is
`r10uvm88repro`. It is a **pre-existing COIN**: its raw diff is six lines that
move one `\_function: (p3::base3::oob_base)` and its `|vpiTaskFunc:` within a
`Task_funcs` vector, its **order-blind diff is 0 lines**, and the **PRISTINE
binary alone** produces two different dumps in twenty runs of the same command
(18 / 2). That is RESUME §9's `vpiTaskFunc` ORDER flip under slang's parallel
parse, the same face `r10uvm75repro` shows (order-blind 0 here too). Not a mover.
Across all differing dir-mode arms the order-blind content is EXCLUSIVELY
`\_logic_net` / `|vpiActual` / `|vpiNet|Name|FullName|NetType|Parent` /
`\_module_inst` / `\_ref_var` — the law's own family, nothing else.

**(b) "pristine reproduces the main tree's `build/slang-uhdm` byte for byte."**
Unverifiable now and irrelevant: the main tree advanced to `3dba439f` (Earlgrey
pass 73) mid-verification and its binary was rebuilt. The load-bearing fact holds
— my independent build at `6c74d2a` reproduces the implementer's pristine md5
exactly. **The patch also `git apply -3 --check`s clean on `3dba439f`.**

## 3. THE ADVERSARIAL GRID — twelve arms, 0 AWAY

`v107cells.py <golden.cen> <pristine.cen> <patched.cen> <label>` prints every
census cell on which golden, pristine or patched disagree, verdict per cell.
All twelve arms were built with `grid107.sh` in **both views**, every cell's own
`rc` recorded, all cells `rc=0`.

| arm | what it attacks | TO-GOLDEN | **AWAY** |
|---|---|---|---|
| `v107_b1` | nested shapes inside the expression-position receiver call's argument list: a receiver-less call, a second receiver call, a ternary, a concat, an index, a `with`-clause built-in | 6 | **0** |
| `v107_b2` | the `= new` fence's corners: index on the LHS of `= new`, a **constructor argument** of the same `new`, `new[n]` size, `h.f = new()` | 5 | **0** |
| `v107_b3` | in-body class method, package function, module `initial`/`always`, generate block, interface, program block | 0 | **0** — **nothing outside an out-of-body package-class body moved** |
| `v107_b4` | two tops + a child + an import-only module + an import-nothing module | 1 | **0** |
| `v107_b5` | `this.m(v)`, `super.m(v)`, a **chained** receiver `h.s.ask(v)`, a name shadowed by a typedef | 0 | **0** (2 STILL, §4) |
| `v107_b6` | bare `return v`, LHS write, if condition, two control bodies deeper | 4 | **0** |
| `v107_b7` | one wire per NAME: three methods declaring the same-named local | 3 | **0** |
| `v107_b8` | named block, `fork…join_none`, `foreach` body, `case` selector, `while` condition | 6 | **0** |
| `v107_b9` | ten NAME collisions: package typedef / struct typedef / enum typedef / parameter / class / function / class property / module net / module variable | 5 | **0** (4 STILL, §4) |
| `v107_b10` | where the colliding declaration must live: home package vs module vs `$unit` vs a package NOT imported | 4 | **0** (5 STILL, §4) |
| `v107_b11` | is the §4 hole PRE-EXISTING? the same collision on § `classPropRefs` and § `classEnumConstBindsHoistNet76` names | 0 | **0** |
| `v107_b12` | **ZERO tops** — the package alone | 1 | **0** |

Also re-run from scratch: the pass's own `g107_a1` / `a2` / `a3`. On a1 my
census reads 32 ELABPKG cells (the pass counts 17 positions): patched agrees
with golden on **25/32**, pristine on **18/32**, the seven that moved all moved
**TO GOLDEN**, and the seven still-disagreeing are `class_var` / `array_var`
**multiplicity** on the RECEIVER refs (`s`, `qv`) — identical in both binaries,
a different family. `a2` byte-identical between binaries. `a3` = R-MULTI.

**Two SLANG_REJECT facts, measured not assumed:** an **undeclared identifier**
and a **misspelled property** are refused by slang outright
(`error: use of undeclared identifier`), so those two shapes from the brief are
out of scope by the campaign's own definition. `v107_b8` keeps the reachable
half.

**Fence corners that turned out unreachable:** the index of a `= new` lvalue and
the size of `new[n]` cannot be of an unsupported type-parameter type, so they are
never `ref_var`s and `lhsOfWrittenNewAsg107`'s behaviour there is moot. The
corner that IS reachable — a `ref_var` local as a **constructor argument** of
`plain = new(v)` — walks up the RIGHT side, is correctly NOT fenced, and is
**TO-GOLDEN** (`v107_b2` 42:17, golden `logic_net`).

**Code review:** `lhsOfWrittenNewAsg107`'s `p->as<BinaryExpressionSyntax>()` is
type-correct — slang maps both `AssignmentExpression` and
`NonblockingAssignmentExpression` to `BinaryExpressionSyntax`
(`~/.local/include/slang/syntax/AllSyntax.h:10037`, `:10336`). The walk is
null-safe (`n && n->parent`) and terminates at the root.

## 4. THE ONE HOLE, CHARACTERISED — § `tdSuppressesMintPkgOrModScope107`

> **A name the MODULE can already spell as a TYPEDEF or a PARAMETER never gets an
> implicit wire.** Surelog's module-level search at the tail of
> `UhdmWriter::lateBinding` consults the module's typespecs and parameters
> BEFORE it mints, so such a reference ends `NONE` (typedef, or a module
> parameter) or bound to the `constant` / `parameter` (a package or `$unit`
> parameter). Our shared hoisted-net pool consults neither and mints anyway.

Read off ONE golden per arm, `v107_b9` + `v107_b10`, ELABPKG, both views:

| the local's name is also… | golden | pristine | patched |
|---|---|---|---|
| nothing else (control) | `logic_net` | `ref_var` | `logic_net` ✓ |
| a package **class** / package **function** / **class property** | `logic_net` | `ref_var` | `logic_net` ✓ |
| a module **net** / module **variable** | `logic_net` | `ref_var` | `logic_net` ✓ |
| a typedef in a package the module does **not** import | `logic_net` | `ref_var` | `logic_net` ✓ |
| a **`$unit` typedef** | `logic_net` | `ref_var` | `logic_net` ✓ |
| a **typedef in the class's home package** (int / struct / enum) | **NONE** | `ref_var` | `logic_net` ✗ |
| a **typedef in the importing module** | **NONE** | `ref_var` | `logic_net` ✗ |
| a **parameter in the home package** | **`constant`** | `ref_var` | `logic_net` ✗ |
| a **`$unit` parameter** | **`parameter`** | `ref_var` | `logic_net` ✗ |
| a **parameter in the importing module** | **NONE** | `ref_var` | `logic_net` ✗ |

At the reference field pristine is wrong too (`ref_var` where golden has
`NONE`/`constant`), but at `module_inst::Nets` pristine is **right** and patched
is **wrong** — patched mints a wire golden has not (`v107_b5`:
`work@topb5.shadow5@60:15`; `v107_b9`: four; `v107_b10`: five). The order-blind
whole-dump diff of those arms contains **only** `\_logic_net` and its children
plus the binding lines: no collateral.

**IT IS PRE-EXISTING, AND `v107_b11` PROVES IT.** Give a **class property** and a
**class-scope enum constant** — § `classPropRefs`' and § 76's own populations,
already in the pool at `6c74d2a` — a name a package typedef also spells:

```
golden   rd_enum 25:17 td_e11 -> NONE          PRISTINE -> logic_net   PATCHED -> logic_net
golden   rd_prop 21:12 td_c11 -> int_var,NONE  PRISTINE -> int_var,logic_net  PATCHED -> same
control  rd_prop 21:30 uq_c11 -> int_var,logic_net   both sides agree
```

The pristine binary already mints for the suppressed names. § 107 widens the
population that walks into the gap; it does not open it.

**ZERO measured reach.** 0 AWAY over the nine UVM databases (454k scored
reference cells); 0 AWAY over the 3,347-arm boundary in both views; 0 rows
changed on either corpus; and SimpleUVM's `work@top` gains exactly four wires,
all four of which golden has.

**WHY I DID NOT FIX IT IN THIS PASS.** The correct fix is one predicate in
`bindHoistedClassPropRefs` (`src/ModuleEmit.cpp:5726`), which is the binder for
**all four** name families — § `classPropRefs`, § `withIterRefBindsHoistNet75`,
§ `classEnumConstBindsHoistNet76` and now § 107. Putting it there changes three
laws this pass does not own and would move corpus cells; putting it only inside
`oobRefVarLocalHoistNet107` would close the home-package half and leave the
importing-module half (the reference site cannot see which module will hoist),
i.e. a new asymmetric un-gated law of the verifier's own invention. This is the
same call the pass itself makes for R-MULTI, and it is a pass, not a patch.

## 5. RESIDUES, RANKED (the pass's own R0 first)

1. **R0 (the pass's) — the new SimpleUVM ×2 head**, `RHS logic_net(work@top.rsp_export)@228:3`,
   16 cells, all `golden=NONE ours=logic_net parent=hier_path`. **Confirmed
   pre-existing**: the pristine binary's `work@top` already carries 34 nets
   golden lacks, and the patched binary carries the same 34.
2. **R1 (NEW, mine) — § `tdSuppressesMintPkgOrModScope107`**, §4 above. One
   predicate in `bindHoistedClassPropRefs` closes it for **all four** pool
   families at once; the ten-cell golden table in `v107_b9`/`v107_b10` is the
   spec, `v107_b11` is the pre-existence proof and the regression control.
3. **R2 (NEW, mine) — the CHAINED receiver is a MISS**, `v107_b5` 54:17
   `if (h.s.ask(v) == 0)`: golden mints `work@topb5.v@54:17`, **both** binaries
   bind the declaration. `recvUserMethodArgDepth107` is raised only at the
   ONE-NAME-receiver arm (`recv0.kind == NamedValue`), so a two-name receiver
   never opens the window. Safe direction (under-inclusive), one arm cell,
   no corpus reach.
4. **R-C (the pass's) — Scoreboard/default's new 42-line head**, an unfolded
   unary MINUS over `1` at `uvm_sequencer_base.svh:529:23`. **Confirmed**: the
   pristine head was the uvm105 R-B `ref_var` cell and it is gone.
5. **R-MULTI (the pass's) — one wire per reference.** **Confirmed and
   quantified on my own arm** (`v107_b4`, def view): golden mints `vb4` in
   `work@childb4` ALONE; patched mints it in `childb4`, `topb4_a` **and**
   `topb4_b` (which only imports the package). Pre-existence proved on the same
   arm — the **pristine** binary already mints `d4` in two modules where golden
   mints it in none.
6. **R-P / R-NONREFVAR / R-CTOR / R-ELABMULT / R-DEFCOPY (the pass's)** — all
   re-observed. R-CTOR is the def boundary's single OTHER cell; R-ELABMULT is
   the elab boundary's single OTHER cell; R-DEFCOPY is visible as the DEFPKG
   half of `v107_b12`.

## 6. FILES

```
README.md        this file (the verdict, what reproduced, the new laws)
v107cells.py     per-cell golden/pristine/patched verdict printer
v107_b1..b12.sv  the twelve adversarial arms (§3); drive with the pass's own
                 grid107.sh <arm> <pristine> <patched> <workdir> <cen>
```
