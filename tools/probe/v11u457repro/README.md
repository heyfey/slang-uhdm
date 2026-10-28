# v11u457 — adversarial verification of r11u457 (pass 457, expression/parameter ground)

Base e8b7d96d3. Implementer's patch /tmp/r11u457.patch, applied clean to a
fresh worktree at the base. The verdict is **CONFIRMED**. No break was found, so
there is no production change: the src diff in the verified patch is
byte-identical to the implementer's. The verified patch adds only this
directory and the regenerated tests/LAWS.md.

## Binaries (within the measurement budget)
- pristine: the main tree's build/slang-uhdm at the base, frozen at
  /tmp/v11u457_bin/pristine (md5 4a384194392779cfff4f9d9ab48a83de). No
  pristine build and no pristine sweep: the pristine reading is the master's
  control /tmp/intr11u455.
- law: built once in /tmp/wt_v11u457 (-j 2) and frozen at /tmp/v11u457_bin/law.
  Its md5 is 59a7e5b331028dd241e69343e6ee509a, equal to the implementer's law9.
  It links slang 12.0.0+545f88b2e.
- There is no verified build because nothing changed.

## Audit of the patch
- It touches src/ExprEmit.cpp, src/StmtEmit.cpp, tests/LAWS.md and
  tools/probe/r11u457repro/ only.
- There is no src/R*.h, no getenv and no reader function. Every switch goes
  through lawOn(457, ...); trace lines go through lawTrace(457, ...).
- scripts/law_index.py --check reads current after the apply.

## The sweep (one full five-stage run on the law binary)
Workdir /tmp/v11u457_swL, launched after three quiet readings.
- probe, surelog, uhdm2rtlil and downstream ran from the worktree.
- sv-tests ran through the main tree's tests/sweep.sh on the same workdir and
  binary, because the worktree's UVM submodule is empty.
- Both runs printed "law index STALE": the worktree because this directory was
  being added, the main tree at the base itself.

Readings:

| Stage | Result | csv vs control |
|---|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64, 0/0/0 | identical |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | identical except the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | identical |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0 | identical |
| sv-tests | EQUAL 1927, DIFFERENT 13, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions 0, conversions 0, changes 0 | identical |

**byteverify** (SELFCHECK=1, law sweep against /tmp/intr11u455; evidence/v11u457_byteverify.txt):
- Path sets are identical: 3409 databases.
- Corpus movers: surelog, uhdm2rtlil and downstream show 0 of 3375.
- The 34 movers are all kept sv-tests databases (the UVM and scoreboard rows).
  Each one reads STRICT_EQUAL against the control under
  `uhdm-strictcmp --no-canon`, the raw walk with every field
  (evidence/v11u457_svmovers_strict.txt). This is the existing raw-byte
  serialization variance that pass 455 recorded. None of them is a mover.
- The self-check flags 3407 of 3409. The single extra match is
  1DUnpackedArray, whose downstream and uhdm2rtlil-testflags databases are
  byte-identical to each other. The control has the same twin, so this is not
  a byteverify weakness.

**Probe databases:** all 4087 are identical to the control by path-normalized
uhdm-dump (evidence/probe_dumpcmp_summary.txt).

**Canaries:** ok=52 and ok=16, changed=0. Both ctcan2 checks PASS
(EXPECT_UNKNOWN=1 surelog, EXPECT_UNKNOWN=6 uhdm2rtlil).

**Binary audit:**
- surelog: 1531 of 1581 cmds.txt records name /tmp/v11u457_bin/law; the other
  50 hold only a Surelog line.
- uhdm2rtlil: 1742 of 1742.
- sv-tests: 2346 of 2346.

## The implementer's grid reproduced (evidence/impl_grid_reproduced.txt)
All 64 case dirs give the same exit code, uhdm-cmp count, strict verdict and
moved/same as evidence/grid_pristine_vs_law9.txt in r11u457repro. Every exit
code is 0. The correct tally is **35 moved** (34 to STRICT_EQUAL plus OR/or18
closer at uhdm-cmp 90 -> 44) and **29 byte-identical**. The README and report
say 40 moved, 39 STRICT_EQUAL and 24 controls; their own evidence file holds
35 / 29.

The backlog movers (evidence/backlog7.txt) are r11u446 CB/cb04, CG/cg01,
cg02 and cg03, and v11u446 VC/vc07. All of them go from uhdm-cmp NOT_EQUAL to
STRICT_EQUAL, as claimed. **r11u455 OC/oc06 does NOT move.** It reads
STRICT_NOTEQUAL type on both binaries with the same bytes. Its call
`f(v) + k()` sits under an operator, where § pkgRetCallSharesConstRet457
abstains by design. So 6 backlog dirs move, not 7, and oc06 stays in the
residues.

R11U457_OFF gives pristine's bytes and exit code on 120 of 120 dirs: the
implementer's 64 and these 56 (evidence/switch_all_off.txt).

## Attack grid: 56 fresh case dirs (cases/VK, VP, VO, VC, VD)
Each case's first line names the law it attacks. Every case is accepted by
upstream slang, and every exit code is 0 on both binaries. Goldens come from
Surelog v1.87 with `-parse -nobuiltin -nocache -sv`. The driver is
drivers/run1.sh / grid.sh and the readings are in
evidence/grid_pristine_vs_law.txt.

Result: 42 moved, 37 of them to STRICT_EQUAL. **No case got worse on either
judge.** 14 are byte-identical controls.

**§ pkgRetCallSharesConstRet457, VK.** These go to STRICT_EQUAL:
- vk01: an `integer` return, which is 4-state predefined. The decode holds:
  only logic_typespec takes evalFunc's clone branch (ExprEval.cpp, evalFunc's
  return block).
- vk02: a `bit` return of 3.
- vk03: a `byte` return of 300.
- vk04: a typedef of int.
- vk05: a qualified q::rep across packages.
- vk07: two callers share one constant.
- vk08: an in-body method keeps its call; the out-of-body one shares.
- vk10: an `int unsigned` return.
- vk12: the clone of an out-of-body method.
- vk13: module callers.
- vk14: a parenthesized return.

These are byte-identical controls:
- vk06: a callee with a local declaration. It is STRICT_NOTEQUAL depth on both.
- vk09: in $unit.
- vk11: a return inside an if.

**§ pkgRetCallPassArgShare457, VP.** These go to STRICT_EQUAL:
- vp04: a byte formal with an int actual.
- vp06: a caller local as the actual.
- vp09: a parenthesized return.
- vp10: a defaulted formal written positionally.
- vp11: two callers with clones.
- vp13: a logic [7:0] formal with a logic [3:0] actual.
- vp14: the out-of-body class copy with a local actual, and a static method.

These move closer but stay NOT_EQUAL:
- vp12: unary minus is fixed. The ternary condition `rep(a) ? 1 : 0` still
  abstains where golden shares. Dump distance 60 -> 41.
- vp15: q::rep(a) is fixed. The share chained into the next caller is not.
  Distance 74 -> 55.
- vp16: rep(b) is fixed. The nested rep(rep(a)), which golden reduces whole,
  is not. Distance 85 -> 66.

These are byte-identical controls:
- vp01, vp02, vp03: ref, inout and output formals. Pristine and law are both
  NOT_EQUAL.
- vp05: a package-variable actual.
- vp07: an in-body method.
- vp08: in $unit.

**§ oobClsRetCallSharesCalleeRet457, VO.** These go to STRICT_EQUAL:
- vo01: the callee in a third package.
- vo02: an extern static method.
- vo03: a parameterized class C #(2).
- vo04: a derived class.
- vo06: a $urandom callee (kind 2).
- vo07: a virtual class with an extern virtual method.
- vo08: a method-local actual.
- vo10: two methods sharing.

These are byte-identical controls:
- vo05: a return inside an if.
- vo09: a $unit class.
- vo12: a class inside a module.
- vo11: a package-parameter actual. Pristine and law are both NOT_EQUAL at
  60 lines.

**§ importCloneRetCallCopiesShare457, VC.** These go to STRICT_EQUAL:
- vc01: a package variable named like the callee's formal. The copy stays
  unbound, as in golden.
- vc02: the literal-first `2 + v`.
- vc03: two importers.
- vc04: a wrap local actual.
- vc07: an out-of-body clone in a derived class.
- vc08: a wrap local named like the callee's formal.
- vc09: a class property named like the callee's formal.
- vc10: the constant copy in both clones.

Also in VC:
- vc06: the importer's own function calling the clone, wrap(b). It moves from
  NOT_EQUAL to STRICT_NOTEQUAL depth. Golden reduces that call too (a chained
  evalFunc); ours keeps func_call wrap at 8:35.
- vc05: a module importer. It is a byte-identical control.

**Downstream, VD** (a cell or continuous assignment over the calls). vd01 to
vd04 go from EQUIVALENT (nohier and il differ) to **IDENTICAL**.
- vd02, vd03 and vd04 also go to STRICT_EQUAL.
- vd01 stays NOT_EQUAL on a module port's ref_typespec, which predates the
  pass. Dump distance 29 -> 7.
- Sampled no-gate cases (VK/vk01, vk07, vk13, VP/vp06, vp13, VC/vc05) are
  IDENTICAL on both binaries.

**Each switch alone** (evidence/switch_each.txt): the firing law's own switch
restores pristine on every single-law mover. VC/vc07, VK/vk12 and VP/vp11 need
their pair. VK/vk08 is restored by either the class-copy switch or the
constant switch, because that law needs both.

## Residues (all wrong on pristine too, none moved away)
1. A share that golden makes and the laws abstain on:
   - VP/vp12: a ternary condition.
   - VP/vp16: a nested rep(rep(a)) reduced whole.
   - VC/vc06 and VP/vp15: a call to a function whose own return is shared,
     which golden's chained evalFunc reduces.
   - r11u455 OC/oc06: under an operator.
2. Pass-through with ref, inout or output formals (VP/vp01 to vp03), and
   package-variable or parameter actuals (VP/vp05, VO/vo11). The law abstains;
   golden differs at the call's argument.
3. A callee with a local declaration (VK/vk06). Pristine's constant-call fold
   writes a constant where golden keeps a different shape.
4. The implementer's residues 1 to 5, and the carried lists of passes 455 and
   earlier.

## Sister-ground faces
None new. The implementer's two stand: ModuleEmit's elaborated port-connection
rename (v11u453 VR/vr11), and pipelined_get_put's class-listing count.

## Process
- Within the budget: one law build, no pristine build, one full sweep,
  byteverify once.
- The attack grid ran at nice 19 while the sister v11u456's sweep was live
  (timing only). This pass's own sweep waited for three quiet readings.
- No other agent's process was touched. No fenced test was named, opened or
  run: every case is a fresh file, and no tree-wide reader was used.
