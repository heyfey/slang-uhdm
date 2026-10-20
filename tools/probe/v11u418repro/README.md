# v11u418 — adversarial verification of r11u418

This is the verifier pass for r11u418 on base `a39e1069a` (pass 416). The
ground is module/type: `src/TypeEmit.cpp`, `src/ModuleEmit.cpp` and
`src/UhdmExporter.cpp`.

**Verdict: VERIFIED WITH ONE PRODUCTION REFINEMENT.**
- Fresh cases on legal SV found one break, in § unitVarRefMintsNet418.
- Four cases were STRICT_EQUAL on pristine and moved away from golden under
  the law.
- § unitVarNestedScopeAbstain418v fixes the break (ModuleEmit
  mintUnitEnumNets, switch `R11V418_UNITVARSCOPE_OFF`, read through
  `fixOn(418, ...)` from src/LawSwitch.h).
- No src/R*.h, no getenv and no reader function were added.

## The break and the refinement

§ unitVarRefMintsNet418 mints a module wire at the first reference to a
`$unit` variable. It walks the whole module syntax tree, so it also counted
two kinds of reference that golden does not late-bind in the module:
- references inside a generate construct (loop, if or case generate, with
  or without a begin block);
- references inside a class declared in the module.

For those, golden leaves the ref_obj unbound (`work@top.g.label`, no
actual) and mints no net. When the module also reads the name directly,
golden's wire sits at the module's own reference.

| case | shape | pristine | law | verified |
|---|---|---|---|---|
| VU/vu04 | `if (1) begin : g initial $display(label); end` | STRICT_EQUAL | NOT_EQUAL (uhdm-cmp 111) | STRICT_EQUAL, pristine's bytes |
| VU/vu07 | class in the module reading `label` | STRICT_EQUAL | NOT_EQUAL (161) | STRICT_EQUAL, pristine's bytes |
| VU/vu13 | `if (N == 1) initial $display(label);` (no block) | STRICT_EQUAL | NOT_EQUAL (201) | STRICT_EQUAL, pristine's bytes |
| VU/vu18 | case generate `assign o = g;` | NOT_EQUAL 28 (dump distance 12) | NOT_EQUAL 422 (distance 19, away) | pristine's bytes |
| VU/vu16 | class reference first, then a module `initial` | NOT_EQUAL 145 | STRICT_NOTEQUAL line | **STRICT_EQUAL** |
| VU/vu17 | gen-block reference first, then a module `initial` | NOT_EQUAL 161 | STRICT_NOTEQUAL line | **STRICT_EQUAL** |

**§ unitVarNestedScopeAbstain418v.**
- The wire is minted only for a reference the module itself compiles: its
  processes, continuous assigns, subroutines and their blocks.
- A reference with an ancestor GenerateBlock, LoopGenerate, IfGenerate,
  CaseGenerate, ClassDeclaration or nested Module/Interface/Program
  declaration (below the module's own declaration) abstains.
- Each abstention is logged through `lawTrace(418, "unitVarNestedScopeAbstain418v", ...)`.
- It fires on no corpus row, no probe case and no sv-tests row: the verified
  sweep's trace holds no firing of it.

## Reproduction of the implementer's claims

**Builds.**
- The law build in a fresh worktree is md5 `6786a1ce32083161c8dfc969493883ac`,
  equal to the implementer's final binary.
- The pristine binary is the implementer's frozen copy, md5
  `18f76dd113d0725710277d4ac13ad9c5`, equal to the base build. No pristine
  build and no pristine sweep were made; the pristine reading is the master's
  control /tmp/intr11u416.
- The verified binary (law plus the refinement) is md5
  `51cedf51297d3664f9219836689fe5ce`.
- Both binaries were frozen under /tmp/v11u418_bin before any measurement.
- All three report slang 12.0.0+545f88b2e.

### Law sweep: five stages, one sweep, on the law binary

This sweep reads the corpus stages on the implementer's final binary. The
implementer's own corpus stages had run on its law binary 13.

- **probe:** 4018 EQUAL + 69 STRICT_NOTEQUAL; 0/0/0. The csv is byte-identical
  to results/golden_probe.csv.
- **surelog:** 480 + 0 default, 474 + 0 testflags; 0/0/0. The csv differs
  from the control only in the two LowMem log-path texts.
- **uhdm2rtlil:** 803/1/67 in both modes; 0/0/0. The csv is identical to the
  control.
- **downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0
  DIVERGENT. The csv is identical to the control.
- **sv-tests:** run with the main tree's scripts/check_svtests.py (identical
  to the base's) and `--baseline a39e1069:results/golden_svtests.csv`, since
  a worktree has no UVM tree and no sv-tests sibling. It reads
  **regressions=0, conversions=21, changes=0**: EQUAL 1816, STRICT_NOTEQUAL
  11, DIFFERENT 113, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1. The csv is byte-identical to the implementer's
  on all 2346 rows, and the conversion list is line-identical.
- **byteverify** (SELFCHECK=1) against the master's control: surelog 0 of
  962, uhdm2rtlil 0 of 1608, downstream 0 of 805. The path sets are identical
  and every selfcheck flags all but the reference file.
- **Canaries:** ok=52 changed=0 and ok=16 changed=0. ctcan2 PASS with
  EXPECT_UNKNOWN=1 and 6.
- **Binary audit, fence-filtered:**
  - surelog: 1523 of 1573 records name /tmp/v11u418_bin/law. The other 50
    hold no slang-uhdm line; 2 of them, CoresSweRV and CoresSweRVMP, name
    slang only in the UVM checkout path.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
- **Trace census (R11U418_TRACE):**
  - No law fires in the surelog, uhdm2rtlil or downstream stages.
  - In the probe stage, § ifcFileScopeImportListing418 fires on 5 cases,
    the same 5 as the implementer's. Their databases are identical to the
    control after normalizing the file path; the probe-stage path differs
    between a worktree and the main tree.
  - In the sv-tests stage the laws fire on 61 rows: 21 conversions, 36 still
    DIFFERENT, 3 SLANG_ONLY and 1 SURELOG_CRASH (rsd).
  - § unitVarRefMintsNet418 fires on 19 chapter-16 rows, each at
    `work@top.label` in a module-level `uvm_info`.
  - § unnamedGateTermDefName418 fires nowhere in the sweep.
  - Per-row counts: evidence/trace_law_sweep_rows.tsv.

### Verified sweep: five stages, the second and last sweep

The verified binary changed production code, so the five stages ran once
more on it.

- **probe, surelog, uhdm2rtlil and downstream:** each csv equals the law
  sweep's (surelog apart from the two LowMem log paths).
- **sv-tests:** the csv is byte-identical to the law sweep's: regressions=0,
  conversions=21, changes=0.
- **byteverify** (SELFCHECK=1): verified against law reads 0 of 962, 0 of
  1608 and 0 of 805; verified against the master's control reads the same.
- **sv-tests databases, verified against law:** 144 of 145 kept databases
  read an identical normalized dump. tnoc was not compared: its dump was
  stopped to free the machine, the refinement does not fire on it, and its
  csv row is identical.
- **Canaries:** ok=52 and ok=16; both ctcan2 checks PASS.
- **Exit code:** the corpus run exits 1 only on the stale law index, which
  this patch regenerates (tests/LAWS.md).

### Converted rows, fresh rows from the verified sweep

```
generated/basejump/bsg_clk_gen_BaseJumpSTL_bsg_dram_clk_gen.sv,EQUAL,,equal          (was STRICT_NOTEQUAL fullname(138); § tdKeptParentMemberNames418)
generated/basejump/bsg_cache_BaseJumpSTL_bsg_cache_to_test_dram.sv,EQUAL,,equal      (was STRICT_NOTEQUAL fullname(2); § defGenPartSelBoundRefMember418)
generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_router.sv,EQUAL,,equal           (was STRICT_NOTEQUAL fullname(1); § tdMoveRenamesBitSelect418)
generated/hdlconv_std2017/hdlconvertor_std2017_p791.sv,EQUAL,,equal                  (was DIFFERENT; § genGateTermGenNetBind418)
generic/class/class_test_53.sv,EQUAL,,equal                                          (was DIFFERENT; § classTpUnitTdAliasClone418)
chapter-16/16.9--sequence-{changed,fell,past,rose,stable}-uvm.sv,EQUAL,,equal        (5 rows, were DIFFERENT)
chapter-16/16.7--sequence-{intersect,throughout}-uvm.sv, 16.15--property-iff-uvm.sv,EQUAL,,equal  (3 rows, were DIFFERENT)
generated/uvm_classes_1/uvm_{agent,driver,env,monitor,scoreboard,sequencer,test}_class_1.sv,STRICT_NOTEQUAL,differ:value(3),differ:value(3)  (7 rows, were DIFFERENT)
testbenches/uvm_agent_env.sv,STRICT_NOTEQUAL,differ:value(3),differ:value(3)        (was DIFFERENT)
```

The 16 chapter-16 and UVM rows move through four laws together:
§ ifcFileScopeImportListing418, § thisNetFirstListingModule418,
§ hoistNetsFirstModule418 and § unitVarRefMintsNet418. The uvm_classes_1
rows and uvm_agent_env also need § modportImplicitHdrNoNetType418.

### The implementer's grid

The implementer's grid (120 case dirs, evidence/grid_implementer.txt) is
reproduced line for line: exit code, uhdm-cmp line count, strict verdict,
and whether the law's bytes equal pristine's.
- The verified binary's bytes equal the law's on 120 of 120.
- `R11U418_OFF` on the verified binary gives pristine's bytes and exit code
  on 120 of 120.
- `R11V418_OFF` gives the law's bytes on 120 of 120.

## Attack grid

**Setup.** 76 fresh case dirs in 11 groups, each with its own law's switch
(evidence/grid_attack.txt; the law binary's first pass with each group's own
switch is evidence/grid_attack_law_ownswitch.txt).
- Every case is accepted by upstream slang (~/.local/bin/slang with the same
  arguments and --single-unit, rc=0).
- Two drafts that upstream slang rejects (a gate inside an interface; a
  modport `import` of a `$unit`-imported function) were dropped.
- Drivers: drivers/grid.sh, vgrid.sh, run1.sh and dir.sh. dir.sh gives an
  exact multiset distance to golden over sorted, id- and path-stripped
  dumps.

**Pristine -> verified:**
- 29 NOT_EQUAL -> STRICT_EQUAL.
- 8 STRICT_NOTEQUAL -> STRICT_EQUAL, among them VU/vu16 and vu17 (through the
  refinement).
- 14 STRICT_EQUAL kept. VU/vu04, vu07 and vu13 are at pristine's bytes.
  VK/vk01, vk05 and vk06 move their member full names to golden's (distance
  8 -> 0).
- 2 STRICT_NOTEQUAL kept, both toward golden: VB/vb04 (10 -> 4) and VN/vn02
  (endcol, 20 -> 4).
- 23 NOT_EQUAL on both:
  - 9 toward golden: VG/vg05, VI/vi05, vi06 (52 -> 28), VM/vm04, VN/vn05,
    VU/vu05, vu08, vu12 and vu15;
  - VP/vp05 at the same distance, its bound name now golden's `.addr.B`;
  - 13 at pristine's bytes, VU/vu18 among them.
- No exit code changed. No case leaves an equal status under the verified
  binary, and none moves away from golden.

**Switches:**
- `R11U418_OFF` restores pristine on 76 of 76.
- `R11V418_OFF` restores the law on 76 of 76.
- Each group's own switch restores pristine on 71 of 76. The other 5, VH/vh02
  to vh06, also need `R11U418_THISFIRSTMOD_OFF`, because their package
  method prints `this`.

**Downstream** (drivers/downstream_cases.py, evidence/downstream_cases.txt):
- 151 class-free case dirs from the 76 fresh ones and the implementer's 120.
- UV/uv03 goes EQUIVALENT -> IDENTICAL.
- 145 stay IDENTICAL and 5 stay EQUIVALENT. None is worse.

Groups, with each case's law in its first line:
- VU (§ unitVarRefMintsNet418, § unitVarNestedScopeAbstain418v): a
  continuous assign, always_comb, `$unit::cnt`, a gen-block reference, a port
  connection, an assign target, a class in the module, an interface plus a
  module, a bit select, a for loop, a program, gate terminals, an if/case
  generate without a block, a generate region, and class or gen-block first
  followed by the module's own reference.
- VG (§ genGateTermGenNetBind418): an implicit gen-scope net, two instances
  of a child, case generate, if inside for, a udp, pullup and nmos, a `logic`
  gen net.
- VN (§ unnamedGateTermDefName418): two instances, a concatenation or
  operator terminal, a gen loop, nmos, a comparison terminal, pullup.
- VH (§ hoistNetsFirstModule418 with § thisNetFirstListingModule418): an
  uninstantiated `asub`, three levels, two instances, an interface first, a
  module declared after top, two parameterizations, a program.
- VI (§ ifcFileScopeImportListing418): an import written after the
  interface, an explicit `import p::f`, two interfaces, a body import of
  another package, interface use of package items, interfaces in a generate
  loop.
- VM (§ modportImplicitHdrNoNetType418): inout vector, output, `input [3:0]`,
  mixed implicit and logic, tri, var, wire signed.
- VC (§ classTpUnitTdAliasClone418): logic vector, two classes, the typedef
  also used by a module, bit signed, string, real (not reached), an extended
  class, integer.
- VK (§ tdKeptParentMemberNames418): a union, a nested struct, a program, a
  wildcard import with a local variable, a package-parameter range, a module
  struct holding the package struct.
- VP (§ defGenPartSelBoundRefMember418): a two-level member, an array
  element, a concatenation in a port connection, a genvar bound, `pk::A`, an
  interface.
- VB (§ tdMoveRenamesBitSelect418): a union, `pk::P[1]`, a nested struct, a
  parameter vector bit, a function return.

## Earlier-pass case census

The census ran on 2002 fence-filtered case dirs of passes 401 to 416
(drivers/census1.sh), comparing pristine, law and verified by bytes and exit
code.
- **1999 unchanged** on all three binaries, including the 20 that exit 3 or 4
  on every binary.
- **3 move**, with law and verified equal:
  - v11u402repro VG/vg16_unnamed_and_bitsel and vg19_unnamed_not_multi go
    STRICT_NOTEQUAL fullname -> STRICT_EQUAL (§ unnamedGateTermDefName418,
    pass 402's face, distance 12 -> 0).
  - r11u404repro PS/ps02 moves 2 bytes in the serializer's string table only.
    The uhdm-dump and the strict record walk (--no-canon) are identical, and
    the verdict stays STRICT_NOTEQUAL endcol. `R11U418_KEPTTDNAMES_OFF`
    restores the bytes and no law logs a firing.
    § tdKeptParentMemberNames418 lets typedefParentModel134 run past its old
    early return when only kept typedefs exist (here the module struct
    `ms_t`). That leaves one interned full-name string different; no object
    changes.
- The downstream verdict of all three is IDENTICAL on both pristine and
  verified.

## Away census on the sv-tests rows the laws touch

drivers/away.sh, evidence/away_census.txt: the 40 firing rows that keep
their status (36 DIFFERENT, 3 SLANG_ONLY with a cached Surelog database, and
rsd), comparing the master's control database with the verified database.
Each row is measured by uhdm-cmp line count and by exact multiset distance
to golden (`comm -3` over sorted, id- and path-normalized dumps).
- **39 of 39 measurable rows move toward golden, 0 away.**
- rsd has no golden database (SURELOG_CRASH).
- On the chapter-16 16.10 rows, the uhdm-cmp head moves from 659173 lines to
  32.

## Determinism

Three concurrent draws each of chapter-16/16.9--sequence-past-uvm and
generated/uvm_classes_1/uvm_agent_class_1 with the verified binary read one
md5 per row (3 of 3).

On the corpora, the five-stage sweeps of the law and verified binaries are
byte-identical to each other and to the master's control (byteverify 0 of
962, 0 of 1608 and 0 of 805). The five corpus UVM rows therefore keep the
control's bytes.

## Residues (ranked; all wrong on pristine too; none moved away under the verified binary)

1. **The implementer's ranked residues stand as written** in
   ../r11u418repro/README.md: the 36 UVM rows still DIFFERENT, the 8 new
   STRICT_NOTEQUAL rows on the sister's ParamEmit face, concentrator_out,
   p488, p719, CT/ct07 and ct08, the class listing, interface variables, the
   empty interface port connection, and the backlog.
2. **§ unitVarRefMintsNet418 not reached** (a selected reference `g[3]` or `g[i]` mints nothing in golden either, and the law agrees: VU/vu09 and vu14 STRICT_EQUAL controls):
   - `$unit::cnt` (VU/vu03: a ScopedName; golden's head is elsewhere, 28
     lines on both);
   - a `generate ... endgenerate` region with no block (VU/vu15, toward
     golden, still NOT_EQUAL);
   - an interface reading a `$unit` variable (VU/vu08: the law covers modules
     only, toward on the module);
   - a gate terminal and a port connection (VU/vu12 and vu05, toward, other
     heads).
3. **§ ifcFileScopeImportListing418 not reached:**
   - an explicit file-scope `import p::f;` (VI/vi02, 179 lines on both:
     golden lists the interface's import copies);
   - an interface with a body import of another package plus the file import
     (VI/vi04, 590 lines on both; the law abstains when the body imports);
   - interfaces instantiated in a generate loop (VI/vi06, toward golden,
     still NOT_EQUAL).
4. **§ classTpUnitTdAliasClone418 not reached:** a real typedef (VC/vc06, the
   law lists integral kinds and string only).
5. **§ genGateTermGenNetBind418 not reached:** an undeclared gate output in a
   generate block (VG/vg01, golden's implicit gen-scope net).
6. **§ modportImplicitHdrNoNetType418 not reached:** `input tri`, `input var`
   and `input wire signed` headers (VM/vm04 toward, vm06 and vm07 at
   pristine's bytes); the implementer's MP/mp05 signed.
7. **The program as first listing module:** `program aprg` before top (VH/vh07,
   237 lines on both); the hoist and `this` laws cover modules only.
8. **§ tdKeptParentMemberNames418 with a program:** VK/vk03, 403 lines on
   both.
9. **Bit-select member ranges not reached:** inside a union or with a package
   parameter array (VB/vb01, vb02, vb05 at pristine's bytes).
10. **§ defGenPartSelBoundRefMember418 with a scoped bound:** `pk::A` is folded
    to 8 in golden's name (VP/vp05; the ExprEmit fold, sister ground).

## Sister-ground faces

These are as the implementer reported them; this pass found none new:
- **ParamEmit:**
  - the interface listing's import copies of untyped arithmetic package
    parameters (INT in golden, UINT in ours), the last face of the 8
    STRICT_NOTEQUAL rows;
  - a module type parameter defaulting to a `$unit` typedef.
- **ExprEmit:**
  - concentrator_out's `$clog2` in an indexed part-select width under
    ModuleEmit emitModuleDefPorts;
  - `$realtobits`'s ref_typespec (p599);
  - `$clog2` in a net initializer;
  - the folded elaborated read of a `$unit` int variable;
  - VP/vp05's `pk::A` folded inside a definition-view part-select name.

## Case files

- **The implementer's TN cases:** 8 of their files (TN/tn01 to tn04 and tn06 to tn08 pk.sv, tn05 dut.sv)
  named a law that does not exist (`thisNetFirstModuleHome418`) in their
  first line. They are renamed to § thisNetFirstListingModule418. tn05 had
  been attributed to no law in tests/LAWS.md.
- **Driver path:** the implementer's drivers/downstream_cases.py points at
  the main tree's tools/probe/r11u418repro, which does not exist there. This
  pass's drivers take explicit case directories.

## Process

- **Budget:**
  - One law build (md5 equal to the implementer's) and one verified build;
    the first verified compile failed on a `ParentRef` type and was fixed
    before any binary was produced.
  - Two full five-stage sweeps: law, then verified.
  - No pristine build or sweep, and no third build or sweep.
- **Slips, none affecting a measurement:**
  - The verified sweep was first launched while the sister pass r11u417's
    surelog stage was live; the pgrep that printed its processes was not
    acted on. It was stopped by its own PIDs within about a minute, its
    probe stage unfinished, and its workdir deleted. It was relaunched at
    06:35 on a quiet machine.
  - The first attack grid and the implementer's grid (single process,
    05:56-05:59) overlapped the first minutes of r11u417's sweep.
  - The kept-database dump comparison (up to 3 uhdm-dump processes) was still
    running when the sister verifier v11u417 launched its sv-tests stage at
    07:14. It was stopped by its own PIDs at 07:20, which left tnoc
    uncompared.
  - Two of my waiters self-matched their own pgrep pattern. They were stopped
    by task id; the busy check now runs from a script file.
- **Fence:** the fence list was read by a program from canaudit.sh's FENCED=
  line into a file and never printed. Every tree-wide list (cmds.txt
  records, earlier-pass case dirs) was filtered on it before any file was
  opened. No fenced test was named, opened or run.
- **Processes:** only this pass's own processes were stopped, by PID or task
  id.
