# r11u181 — the expression/parameter ground: `$root` paths read their chain, parenthesized and inc/dec select spans, the unbound-item body wrapper, bare-decimal separators, macro and syntax-less do-whiles, procedural lvalue member paths (inc/dec operands, class methods, chain names, call indices, nested reads, class `new` targets); 4 row-modes and 6 probe cases converted

Implementer pass (pair A, refill after pass 178). Base `80a1c2af` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`,
`src/StmtEmit.cpp`, `src/ParamEmit.cpp` (the design-final drain hook only; `src/EmitHelpers.h` untouched). No edit to
`TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`, `uhdm_main.cpp`, `include/`, `results/`,
`tests/` (except the regenerated `tests/LAWS.md`) or `third_party/`. Net binding is not touched. Every law of passes
140-178 and every refinement is left as landed; the new laws are new sites under their own switches. Worktree
`/tmp/wt_r11u181`, system-deps config, `-j 2`.

## Binaries (frozen `chmod 555` in `/tmp/r11u181_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `3f7b4f737b6020424bc0f734eb0ff64a` | the worktree build of `80a1c2af`, byte-identical to the main tree's `build/slang-uhdm` |
| `law181f.bin` | `3afc1bf084f83489627936066da0b347` | the final patch (`/tmp/r11u181.patch`) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `dev7.bin`, `law181.bin` (`90f565c5...`) | | intermediate law sets (sweeps `swL`, `swM`, section 6); superseded |

Every sweep's `cmds.txt` names its own binary on all 3273 `slang:` lines: `/tmp/r11u181_swP` pris.bin 3273/3273,
`/tmp/r11u181_swF` law181f.bin 3273/3273 (same-length workdir names).

**The fence.** No fenced test is named in this directory. `drivers/env.sh` reads the four names from
`tools/probe/r11u107repro/canaudit.sh`'s `FENCED=` line and refuses to run without four; `drivers/predict181.sh` lists
6647 databases with the 8 fenced row-mode databases excluded by word boundary (`fenced_excluded 8`) and the predictor
refuses any source path naming a fenced test (exit 4); `drivers/bvmirror.sh` hard-links 2560 corpus databases leaving the
8 fenced ones out (`fenced_skipped=8`); `drivers/rowrec.sh`, `obrows.sh` and `obmovers.py` refuse a fenced name; the
filtered corpus runs (`verify_golden.py --filter`: the census with `drivers/tracewrap.sh`, the switch-off run with
`drivers/offwrap.sh`) named only non-fenced tests, checked against `$FENCED_RE` before dispatch; the downstream database
comparison skips fenced names (0 present). No gdb run.

## Result

| axis | base (committed = pristine sweep swP) | law (law181f.bin, swF) | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL, default + testflags) | 450 + 447 | **452 + 449** | **+4** |
| uhdm2rtlil strict-equal (of 1606) | 783 + 783 | 783 + 783 | 0 |
| probe EQUAL (of 4087) | 2814 | **2820** | **+6** |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | `downstream.csv` byte-identical to swP's; 0 of 805 slang-lane databases move |

Gate verdicts of `tests/sweep.sh --jobs 3` against the committed baselines (`evidence/sweep_swP.log`,
`evidence/sweep_swF.log`):

| sweep | probe (reg / conv / changes) | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|
| swP pristine | 0 / 0 / 0, EQUAL 2814 / STRICT_NOTEQUAL 1273, `probe.csv` byte-identical to the baseline | 0 / 0 / 0 | 0 / 0 / 0 | 803 / 66 / 2 / 0, not excused 0 |
| swF law181f | 0 / **6** / 20, EQUAL 2820 | 0 / **4** / 11 | 0 / 0 / 0 | csv byte-identical to swP's |

Both sweeps print `law index STALE` (a clean `80a1c2af` checkout reads STALE too); the regenerated `tests/LAWS.md` in this
patch clears it.

**CONVERSIONS (corpus; results/ untouched).** The fresh rows of the law sweep (`/tmp/r11u181_swF/surelog.csv`):

    CovMacro,default,CMP_EQUAL,,,equal        was differ:fullname(8)   § rootPathFullNameByChain181
    CovMacro,testflags,CMP_EQUAL,,,equal      was differ:fullname(8)   § rootPathFullNameByChain181
    YosysRiscv,default,CMP_EQUAL,,,equal      was differ:col(40)       § bitSelParenIdxSpan181
    YosysRiscv,testflags,CMP_EQUAL,,,equal    was differ:col(40)       § bitSelParenIdxSpan181

Neither is a downstream row (both are Surelog-corpus tests).

**Probe CONVERSIONS (6):** `r11u82repro/grid/v3_rootpath` (§ rootPathFullNameByChain181), `v11u116repro/branches/f2_incd_d2ff`
and `f2_incd_d3cb` (§ incDecBitSelWholeSpan181), `r10uvm59repro/d10_argstmt` and `r10v167repro/probe0`
(§ invalidStmtAnchorSyntax181), `r10buvm6repro/v5_hierpathparent` (§ classMethodLvIsProcess181 +
§ lvSelIdxChainName181).

**CHANGES (corpus: 11 row-modes, each ONE record leaves, 0 enter; `evidence/corpus_changes_records.txt`).**

| row-mode | before -> after | the record that leaves | law |
|---|---|---|---|
| SVSwitch d/t | file(9) -> file(8) | `#264 bit_select rcvr` Environemnt.sv 43:11-12 (ours 43:6-13): `rcvr[i]= new(...)` | § newLhsBitSelAtIndex181 |
| SimpleUVM d/t, Scoreboard d, SeqDriver d/t, MiniAmiq d/t | fullname(42)/file(26) -> fullname(41)/file(25) | `bit_select uvm_random_seed_table_lookup` uvm_misc.svh 409:34-41 (ours 409:5-42): `uvm_random_seed_table_lookup[inst_id] = new;` | § newLhsBitSelAtIndex181 |
| BuildUVMPkg d/t | line(69) -> line(68) | the same statement in the flat uvm_pkg.sv 8678:34-41 | § newLhsBitSelAtIndex181 |

**Probe CHANGES (20, `evidence/sweep_swF.log`):** 18 lose records on the same first field (the INVSTMT family:
r10v160/r10uvm160/r10uvm162/r10v162/r10v165/r10buvm1/r10buvm21/r10uvm14/r10uvm55/r10uvm59/r10uvm165/r10v158 cases,
`line(n) -> line(m)`, m < n; `r10uvm79repro/v79v2_recv` file(11) -> file(8) by LVCLASS + LVCHAIN; `r10v167repro/vB_bare`
file(9) -> file(8)); `r10v167repro/vA_meth` file(10) -> endcol(9) (the one `file` record, its method-body `begin`, leaves:
record-level LEAVE 1, ENTER 0; the remaining endcol records are the hier_path call-span face, residue R3). Every one of
the 82 probe byte movers is TOWARD golden order-blind but one SAME (`evidence/probe_movers_orderblind.tsv`: TOWARD 81,
SAME 1): `r10v134repro/v134_4bodies`, LVCLASS fired, its `uhdm-dump` is identical before and after (the getter-cached
full-name symbol only), verdict and records unchanged.

## 1. The `$root` family (ExprEmit.cpp) — grid `cases/rt` (26 cases x both modes) and `cases/adv/a10`

**Head (CovMacro d/t fullname(8)).** `i = $coverage_control(..., $root.top);`:

    #106 fullname  A: hier_path $root.top   work@top.$root.top   dut.sv 12:42-12:51
                   B: hier_path $root.top   (empty)

**Decode.** Surelog builds a `$root.` path in `CompileHelper::compileComplexFuncCall`'s `paDollar_root_keyword` branch
(CompileExpression.cpp): the hier_path gets `VpiName` and `VpiParent` and never a `VpiFullName`, so the reader computes it
from the parent chain (UHDM `BaseClass::ComputeFullName`); `$root` is populated from the NEXT name node and every
reference element stores its own name. Ours stored the name itself on the hier_path (the no-full-name idiom, which reads
empty). Measured in every position (grid `rt` g01-g20: a system function / task argument, a user call argument, an
operand, a whole lvalue, a module task / function body, a nonblocking assignment, an event control, generate-if and
generate-for scopes, a continuous assignment, a port actual, an if / case condition, a macro-born path, a class method,
a ternary, a concatenation; s01-s06 the earlier passes' `$root` cases): golden's hier_path reads its chain name in both
views, except an assignment TARGET holding a select (s05 `$root.top.v[1] = 1'b0`, g06), which the lvalue branch names by
its own name.

- **§ rootPathFullNameByChain181** (`R11U181_ROOTFN_OFF`; `rootPathFullNameByChain181`, called design-final from
  `drainPaNameCopySrc38` in ParamEmit.cpp): every hier_path named `$root.<...>` has its stored full name cleared, except
  an assignment / continuous-assignment left side holding a select.
- **§ rootPathElemOwnName181** (`R11U181_ROOTELEM_OFF`; the same drain): every reference element of such a path stores
  its own name (ours named the leaf through a port actual's chain `work@sub.u3.a.v`, g14, and a generate scope's, g11).
- **§ rootNetPathOwnNames181** (`R11U181_ROOTNET_OFF`; ExprEmit.cpp, the HierarchicalValue branch): § rootPathOwnNames157's
  twin for a `$root` path to a NET or variable (the parameter-member and instance paths go through
  `buildDottedHierPath`, where pass 157 put its law): `$root` anchored on the next name's token, every element its own
  name (golden `$root` 3:42-45 on `top`, ours 3:36-41; r11u170's R2).

Grid result (`evidence/grid_pristine_vs_law.txt`): 39 of 52 `rt` case-modes STRICT_EQUAL (was 2, the g07 control); g05 (`$root.top.v = 4'd1`)
keeps the lvalue path's endcol (golden 3:21-27, residue R4); g11 keeps the `$root` column in the DEFINITION view's
generate scope (built by TypeEmit `emitSyntaxExpr`, sister ground, residue S2); s05 keeps the lvalue endcol and its
bit_select faces (R4); g17 elab keeps a class full name (S5); g06, g12 and s02 are stage 1 before and after (a `$root`
path with a select); g07 (event trigger) is byte-identical (no hier_path in either).

## 2. § bitSelParenIdxSpan181 (ExprEmit.cpp) — an rvalue bit-select's parenthesized index keeps its parentheses

**Head (YosysRiscv d/t col(40)).** `{butterfly[`smartbextdep_bfly_idx_b(4, i)], ...}` on the right-hand side:

    #1843 col  A: bit_select butterfly  smartbextdep.v 174:18-174:77
               B: bit_select butterfly  smartbextdep.v 174:19-174:76

**Decode.** `CompileHelper::compileSelectExpression` (CompileExpression.cpp) populates a bit_select from the `Bit_select`
node (`populateCoreMembers(Bit_select, Bit_select, bit_select)`), the parse node of the bracket's content, which for a
parenthesized index is the parenthesized primary; slang binds the parentheses away, so the selector's range was the
content (the macro body `(... )` here expands to 59 columns, ours 57). **Law:** the rvalue anchor is the outermost
ParenthesizedExpression that is the selector's syntax (slang keeps that node on the bound selector), walked through the
syntax parents. Switch `R11U181_PARENIDX_OFF`. Grid `cases/bx` (15 cases): a concatenation on either side of a
procedural assignment (b01), YosysRiscv's macro shape (b02), plain rvalue and lvalue (b03), `((i))` and `(i)` (b04), a
macro-born index (b05), a ternary / concatenation / operation / call argument / memory word / if condition /
nonblocking right-hand side (b07-b10): 18 case-modes STRICT_EQUAL; a package function and a class method (b14) and a
cast / system-call / inc-dec index (b15) lose their bit_select records and keep other faces (a class method's index
reference name; a cast typespec's file); controls unchanged: b06 (no parentheses), b11/b12 (member paths and a
two-dimensional select: no firing), b13 stage 1 on both; `adv/a03` adds an included-file macro, a generate continuous assignment and a nested select.

## 3. § incDecBitSelWholeSpan181 (ExprEmit.cpp) — an inc/dec operand bit-select spans the whole select

`cnt[P%4]++` (v11u116 f2_incd_d2ff): golden `bit_select cnt` 15:11-19, ours 15:15-18 (the index). Surelog compiles an
inc/dec operand through its Variable_lvalue branch (§ incDecMemberPathIsLvalue124's decode), so the select takes the
lvalue's whole-select span. Grid `cases/ix` (i01-i04: post/pre increment and decrement, parenthesized / operation /
parameter indices, a module initial, always_ff in nested generate scopes, a subexpression, a for step, a module
function / task / class method; both views): 8 case-modes STRICT_EQUAL; i05 stage 1 on both. Switch
`R11U181_INCDECBS_OFF`.

## 4. § invalidStmtAnchorSyntax181 (StmtEmit.cpp) — the subroutine body wrapper anchors at an unbound second item

The synthesized body `begin` of a multi-item subroutine is anchored at its second item (pass 140's rule). A statement
slang leaves INVALID (an unbound call in an uninstantiated parameterized class, `f.note(T::get(), nm);`) carries no
source range, so the wrapper was unlocated (golden `begin` 12:7-28, the statement through its semicolon; map clusters
N0152 / N0153: 71 probe cases, the UVM rows). **Law:** such an item's syntax node supplies the range. Switch
`R11U181_INVSTMT_OFF`. Evidence: the probe conversions d10_argstmt and probe0, 18 probe changes, `adv/a06` (the unbound
statement first, alone, last of three, in a task; STRICT_EQUAL both modes, was file).

## 5. § bareDecUnderscoreDropped181 (ExprEmit.cpp) — a bare decimal's digit separators are dropped

`assign c[15:8] = 1_0;` (v11u182 G/g04, downstream DIVERGENT on every binary): golden `vpiDecompile 10`, `UINT:10`;
ours `1_0` and the value string `UINT:1_0`, which the reader parses as 1. Surelog's `compileConst` (CompileExpression.cpp,
the `slIntConst` branch) erases every `_` before the decompile and the value. Grid `cases/us` (u01-u08): a select and a
whole net, parameter defaults and localparams, procedural assignments, a case item, a cast operand, select indices and
part-select bounds, an override and a port actual, a comparison and a call argument: u01, u04, u05, u06 STRICT_EQUAL
both modes (were stage 1); u03 and u07 stay stage 1 on another face (u03: the range bound `[1_5:0]` keeps `1_5` in
its decompile, built by TypeEmit, residue S3; u07: the constant call argument's formal typespec, residue R5); u02 /
u08 (sized and based literals, unsized based onto a 16-bit net) unchanged. Switch `R11U181_DECUS_OFF`.

## 6. The do-while span laws reaching two more shapes (StmtEmit.cpp) — pass 178's V4

- **§ doWhileSyntaxFromCond181** (`R11U181_DWSYN_OFF`): slang leaves the do-while statement's syntax null when its body
  block declares a local inside an uninstantiated parameterized class's method (`r10v158repro/v158_d`, golden
  88:7-92:24, ours stopped at `do`); the condition expression's syntax parent is the do-while's node, and the two landed
  span laws read it from there. Grid `cases/dw` d04 (the do_while record leaves; the remaining record is the type
  parameter's typespec, TypeEmit), d05 control (plain class, module task, package function: bytes unchanged).
- **§ doWhileMacroCondEnd181** (`R11U181_DWMACRO_OFF`): a condition written through a macro (`do j++; while `C;`) ends in
  the expansion buffer, which the same-buffer test refused; golden lays the end out in the expanded line (8:5-25). The
  end is taken through setLoc's macro model when the `do` keyword is not macro-born and the condition's expansion is on
  the keyword's line. Grid d01-d03 and `adv/a07` (object-like, function-like, included-file and two-line macros, a
  nested do-while, a class method and a function): all STRICT_EQUAL both modes; v11u178's `dw/w01` converts.

## 7. Procedural lvalue member paths (ExprEmit.cpp) — pass 178's V2 and residue R2's lvalue half

**Decode.** Surelog compiles procedural lvalues through its Variable_lvalue branch and stores no full name on the objects
it builds there (the reader computes them); a member path through selects takes the lvalue path shape (base on the first
member's token, the member select spanning member + index, the leaf storing its own name).

- **§ incDecMixedPathIsLvalue181** (`R11U181_INCDECMIX_OFF`): an inc/dec operand that is a member path through an element
  select (`m.w[k+1].v++`) is emitted under `inLhs` (golden base 8:7-8, bit_select `work@top.m.w[k + 1].v.w` 8:7-13, leaf
  unnamed; ours the rvalue shape). Grid `cases/im` m01-m03.
- **§ classMethodLvIsProcess181** (`R11U181_LVCLASS_OFF`): a class method's lvalue path takes the PROCESS lvalue branches
  (`inProcessEmit` is raised only for a module's processes and subroutines): `q.w[j].v = 1` golden bit_select 5:45-49
  `work@top::C::g::q.w[j].v::w`, ours 5:47-48 `q.w[j]` (m05). A path inside a streaming lvalue or nested in an lvalue's
  select index is excluded (golden compiles both as reads; `adv/a01`).
- **§ lvSelIdxChainName181** (`R11U181_LVCHAIN_OFF`; design-final `drainLvSelChain181`): the process lvalue branches' member
  selects and the references / selects inside their indices read their chain names, where the stored name is that chain
  with ancestors dropped or separators changed (same root, same leaf): `m.w[k+1].v = 3` golden
  `work@top.m.w[k + 1].v.w.k` (ours `...v.k`, m04), a generate scope's `work@top.G.r.w[g].v.w` (ours without `G`, m06),
  a class method's `::` chain (m05), `h.arr[midx[i]].f = 4` golden `...::f::arr::midx` (probe v79v2_recv).
- **§ procLvIdxCallWholeSpan181** (`R11U181_LVCALL_OFF`): a call in a PROCEDURAL lvalue's select index spans the whole
  call (`arr[f(k)] = 1` golden 7:9-13, ours the name 7:9-10); only a continuous assignment's lvalue index call keeps the
  name (mem2reg_test4's `assign intermediate[depth2Index(1)] = 1`, c03 control). Grid `cases/lc` c01-c06: initial,
  always_comb, always_ff nonblocking, module function / task, package function, class method, member paths, operation
  index, compound assignment: all STRICT_EQUAL.
- **§ lvIdxMixedPathIsRead181** (`R11U181_LVIDXREAD_OFF`; the builder flag plus design-final `drainLvIdxRead181`):
  § lvIdxPathIsRead154's twin for the mixed path builder: a member path through selects nested in an lvalue's select index
  (`m.w[n.w[k].v + 1].v = 2`) is built as a read (inner base 18:9 on its own token, bit_select `n.w[k]`), its
  non-trailing index hangs at the inner path (golden `work@top.m.w[ + 1].v.w.k`: § hierPathSelIdxAtPath178's nested
  exception was measured with an RVALUE outer path, h09, and is skipped here) and its reference elements read their
  chain names (`work@top.m.w[ + 1].v.w.v`). Grid `cases/lx` x01 x02 STRICT_EQUAL (were col / fullname); x03 control
  (the rvalue outer path, h09's shape): bytes identical.
- **§ newLhsBitSelAtIndex181** (`R11U181_NEWLHS_OFF`): `CompileHelper::compileBlockingAssignment`'s `= new ...` branch compiles
  the left side with `compileExpression` (an rvalue), so a class-handle array element assigned a `new` object anchors at
  its index: SVSwitch `rcvr[i]= new(...)` golden 43:11-12, ours 43:6-13 (map N0119), uvm_misc.svh 409. Grid `cases/nw`
  n01 n02 (the bit_select records leave; the remaining record is the class member's class_typespec file, TypeEmit,
  residue S1), n04 (a package class and a module task: stage 1 on both, the law fires), n03 controls (`rs[k] = h`, `d = new[4]`, `d[k] = 1`: bytes unchanged).

**Break hunt** (`cases/adv` a01-a10, both views, pristine vs law, record level: `evidence/grid_records_movement.txt`): a
streaming lvalue, a nested path index, compound and nonblocking lvalues in a class method and a module (a01), this-rooted
and nested inc/dec operands, an inc/dec as a select index and a call argument (a02, stage 1 on both), included-file
macros (a03, a07, a10), two-dimensional / this-rooted / queue / member-path `new` targets (a04), macro-born, negated,
20-digit and package-parameter literals (a05). The first cut of § classMethodLvIsProcess181 / § lvSelIdxChainName181 put
a streaming lvalue's and a nested index path's records AWAY from golden where pristine was right (a01 `#127 k`,
`#63 w`); the stream / nested exclusions and § lvIdxMixedPathIsRead181 fixed them before the final sweep.

## 8. Grid, switches and the pass switch

Grid (`cases/`, 89 cases x both modes = 178 case-modes, goldens from the pinned Surelog with and without `-elabuhdm`,
`drivers/grid.sh`, `MAX=500`; `evidence/grid_pristine_vs_law.txt`, `evidence/grid_records_movement.txt`):

| pristine -> law | case-modes |
|---|---|
| STRICT_NOTEQUAL -> STRICT_EQUAL | 98 |
| NOT_EQUAL (stage 1) -> STRICT_EQUAL | 8 (the us family) |
| verdict text moved, still not equal (first field or count) | 16 |
| verdict text unchanged (controls, stage 1 on both, STRICT_EQUAL on both, records moving within) | 56 |

Record level over all 178 case-modes: **802 records leave, 0 enter**, 4 change value while still differing (rt/g05 both
modes: the lvalue `$root` path's full name fixed, its endcol not).

| switch | law |
|---|---|
| `R11U181_ROOTFN_OFF` | § rootPathFullNameByChain181 |
| `R11U181_ROOTELEM_OFF` | § rootPathElemOwnName181 |
| `R11U181_ROOTNET_OFF` | § rootNetPathOwnNames181 |
| `R11U181_PARENIDX_OFF` | § bitSelParenIdxSpan181 |
| `R11U181_INCDECBS_OFF` | § incDecBitSelWholeSpan181 |
| `R11U181_INVSTMT_OFF` | § invalidStmtAnchorSyntax181 |
| `R11U181_DECUS_OFF` | § bareDecUnderscoreDropped181 |
| `R11U181_DWSYN_OFF` | § doWhileSyntaxFromCond181 |
| `R11U181_DWMACRO_OFF` | § doWhileMacroCondEnd181 |
| `R11U181_INCDECMIX_OFF` | § incDecMixedPathIsLvalue181 |
| `R11U181_LVCLASS_OFF` | § classMethodLvIsProcess181 |
| `R11U181_LVCHAIN_OFF` | § lvSelIdxChainName181 |
| `R11U181_LVCALL_OFF` | § procLvIdxCallWholeSpan181 |
| `R11U181_NEWLHS_OFF` | § newLhsBitSelAtIndex181 |
| `R11U181_LVIDXREAD_OFF` | § lvIdxMixedPathIsRead181 |
| `R11U181_OFF` | every law of this pass |

`R11U181_TRACE=1` prints one stderr line per firing on every branch (`R11U181 law <TAG>`).
`evidence/switch_matrix.txt` (`drivers/switchmatrix.sh`): on all 178 case-modes `R11U181_OFF=1` writes the pristine
bytes, and each switch alone moves only the case-modes where its law's trace fires. On the 17 corpus byte movers
(`drivers/offwrap.sh` through `verify_golden.py --filter`, `evidence/corpus_off_bytes.txt`), `R11U181_OFF=1` gives the
pristine sweep's bytes on 13 and the documented UVM order coin on the other 4 (MiniAmiq d, SeqDriver d/t, SimpleUVM d:
0 or 4 order-blind `UINT` / `vpiDecompile` dump lines, `evidence/uvm_off_coin.txt`); every row's status equals the
baseline's.

## 9. Byte movers, predicted by name first

`drivers/predict181.cpp` read every PRISTINE database of swP (6647 listed, 8 fenced excluded) before the final sweep and
named 197 (`evidence/predict_pristine.txt`; per law: INVSTMT 123, LVPATH 61, PARENIDX 25, INCDECBS 13, NEWLHS 12,
INCDECMIX 10, LVCALL 10, ROOTFN 3, DW 1; each predicate over-approximates, PARENIDX reads the source line through the
object's absolute file, fence-refusing).

- **Corpus** (`byteverify.sh`, SELFCHECK=1 2559 / 2560 flagged, path sets identical, fence-free mirrors;
  `evidence/byteverify_corpus_final.txt`): **17 / 2560 movers, all 17 predicted**: BuildUVMPkg d/t, CovMacro d/t,
  Earlgrey_0_1 d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t, SimpleUVM d/t, SVSwitch d/t, YosysRiscv d/t. The law
  census on those rows (`drivers/tracewrap.sh`, `evidence/corpus_census.txt`) names the firing laws: the UVM rows
  INVSTMT / INCDECBS / INCDECMIX / LVCLASS / LVCHAIN / LVCALL / NEWLHS, SVSwitch LVCLASS + NEWLHS, Earlgrey_0_1 LVCHAIN
  (8 firings), CovMacro ROOTFN, YosysRiscv PARENIDX; the predicted rows that did not move (BlackConst, YosysOldOpen,
  YosysOldOr, YosysOldSpi, YosysVerx, Scr1SvTests, LhsHierPath, the uhdm2rtlil LVPATH rows) fire no law. Order-blind
  distance to golden (`drivers/obrows.sh`, `evidence/corpus_movers_orderblind.txt`): every mover TOWARD (CovMacro 16 -> 0,
  YosysRiscv 80 -> 0, SVSwitch 123 -> 121, BuildUVMPkg 13143 -> 13083, MiniAmiq 36021 -> 35827, SeqDriver 29573 -> 29349,
  SimpleUVM 17226 -> 17062, Scoreboard 15462 -> 15328, Earlgrey_0_1 d 13006 -> 12990) except Earlgrey_0_1 t, SAME
  12446 = 12446: its sorted `uhdm-dump` is identical before and after (0 lines of 6742044): LVCHAIN wrote the chain name
  that § elabCloneFullNameUnstored137 then unstores, so only stored-vs-computed bytes differ.
- **Probe** (`drivers/probemovers.sh`, `evidence/probe_movers.txt`): **82 movers, all predicted** (136 predicted); 81
  TOWARD, 1 SAME (v134_4bodies, dump-identical).
- **Downstream slang lane** (`evidence/downstream_slang_movers.txt`): 805 databases compared, **0 movers**; every
  downstream verdict unchanged.

Canaries (`evidence/canaries.txt`): `canaries.sh` surelog ok=43 changed=9, exactly the nine claimed canary CHANGES
(SVSwitch d/t, SimpleUVM d/t, SeqDriver d/t, BuildUVMPkg d/t, Scoreboard d; pristine sweep ok=52 changed=0),
uhdm2rtlil ok=16 changed=0; `ctcan2.sh` surelog PASS (EXPECT_UNKNOWN=1), uhdm2rtlil PASS (EXPECT_UNKNOWN=6).
uhdm-cmp: every touched row-mode and probe case keeps a judge-equal status (CMP_EQUAL / STRICT_NOTEQUAL / EQUAL), i.e.
uhdm-cmp reads 0 lines on each.

## 10. The brief's items, before -> after (swP -> swF, or the grid)

| item | before | after | note |
|---|---|---|---|
| (1) N0131 FuncStructValSimple d/t | file(40)/file(60) | same | not landed; decoded below (R1) |
| (1) rsp_gen_minimal, jeras_union, OutputSize..., arb_idx_cast, Assert*, ParameterFromPkg* | as baseline | same | first records need ground-B clusters (N0022/N0023 emitScopeClocking's caller, N0031, N0448, N0627/N0431, N0083 ...) |
| (1) N0682 / N0001 / N0007 / N0061 / N0119 / N0152-3 (UVM) | | N0119 and N0152/3 shapes landed (NEWLHS, INVSTMT) | the UVM rows' first records are the sister's (F3 relocation, macro reference names) |
| (2) V1 streaming lvalue | | unchanged | excluded from the lvalue laws on purpose (a01) |
| (2) V2 inc/dec path records, `+=` index `...v.w.k` | | **fixed** | INCDECMIX, LVCHAIN (m01, m04, hk/k01 converts) |
| (2) V4 do-whiles (macro condition, v158_d) | | **fixed** | DWMACRO, DWSYN (w01 converts; v158_d's do_while record leaves) |
| (2) R2 call as a select index | | lvalue half **fixed** | LVCALL (c01-c06); the rvalue-path half is residue R3 |
| (2) R1 path nested in another path's index | | lvalue-outer half **fixed** | LVIDXREAD (lx x01 x02); the rvalue-outer h09 face stands |
| (2) R6 Scr1SvTests type(1) | | unchanged | producer FOUND (R5 below) |
| (3) r11u182: `1_0` keeping `UINT:1_0` | DIVERGENT downstream (g04) | **fixed at the literal** | DECUS (us u01 = g04's shape STRICT_EQUAL); the range-bound decompile stays (S3) |
| (4) CovMacro fullname(8) | STRICT_NOTEQUAL | **CMP_EQUAL** both modes | ROOTFN |
| (4) YosysRiscv col(40) | STRICT_NOTEQUAL | **CMP_EQUAL** both modes | PARENIDX (the head was the parenthesized macro index, not the based literal) |
| (4) InterfArrayBind d | fullname(3) | same | decoded below (S4) |
| (4) StructParamPatternInitCast d/t | fullname(3) | same | `#414` is N0003 (the module listing's unparented pattern typespec); `#417/#423` N0014 (TypeEmit) |

## 11. Residues, ranked (this ground), and sister-ground faces

R1. **FuncStructValSimple d/t file(40)/file(60)** cannot convert on this ground: its `#298 struct_typespec
config_pkg::cva6_user_cfg_t` line (golden 38:63-75, the formal's type token; ours the typedef 3:11-6:4) is N0080, the
sister's typedef relocation to formals. The two ground-A faces decoded: (a) `INT:2` for `INSTR_PER_FETCH` located at the
call (67:46-68:35) where golden leaves it unlocated although it reads a pattern member (`CVA6Cfg.RVC`, the caller actual a
package pattern parameter in ANOTHER package); § memLeftSliceUnlocated169's "reads pattern keep" rule was measured on
FuncStructVal, whose golden places the same member at a read site (618:22-45): the distinguisher (which read site, or
none) is not decoded; (b) the elaborated package listing's pattern element constant of `cva6_config_pkg::cva6_cfg`
(ParamEmit, the patElabElems recording near § patElabNoMask59) has an unnamed ref_typespec where golden's reads
`cva6_config_pkg`, and the shared element makes the 19 leftover records of N0131 carry it too.

R2. **Streaming lvalue member paths** (V1, a01 lines 10 and 17): golden builds the path as a read (base at its own token,
bit_select on the member token named `m.w[k + 2]`, the index at the path) but stores the leaf's own name; ours keeps the
lvalue shape. Excluded from this pass's lvalue laws.

R3. **A call as a select index inside an RVALUE hier_path** (`m.w[f(k)].v`, pass 178's R2 first half; vA_meth's four
endcol records `h.mf167`): golden spans the call's name; not changed.

R4. **The lvalue `$root` path's endcol** (g05, s05): golden ends an assignment target `$root.top.v` 6 columns after the
start (the `$root.` token); s05's bit_select is named `v[1]` and spans the index.

R5. **Scr1SvTests d/t type(1): the producer is found.** UHDM `ExprEval::evalFunc` (templates/ExprEval.cpp, "set args"):
for every argument of a function it evaluates, `reduceExpr(arg)` is called and, when the result carries no typespec, a
`ref_typespec` to the FORMAL's typespec is minted on it (`exparg->Typespec()->Actual_typespec(tps)`); when `reduceExpr`
returns the argument object itself (a constant; an irreducible `din[(i+1)*2-1-:2]`) the SOURCE object is mutated. So
golden's call arguments carry the formal typespec wherever Surelog constant-evaluated the call (a continuous assignment's
constant call `f(8'd1_0)`, us/u07; Scr1SvTests' `scr1_search_one_2(din[...])` inside `scr1_search_one_16`, evaluated
through its caller). Modelling it needs the set of calls Surelog evaluates; not landed.

R6. **An unsized based literal as a whole continuous-assignment right side** (`assign a = 'h10;` onto a 16-bit net, us/u02,
u08): golden sizes it 16, ours -1; stage 1, with or without separators.

R7. **The nested-in-rvalue-index path** (pass 178's R1, h09) and the class streaming case keep their faces.

**Sister-ground faces (report only; not edited):**

- S1. A class member array's `class_typespec` has no file / span (nw n01-n04, v79v2_recv `#12`): TypeEmit (the class
  member typespec builder).
- S2. The definition view's generate-scope `$root` path (rt/g11) is built by TypeEmit `emitSyntaxExpr` (its dotted
  hier_path mint beside § pkgTsForeignQualRefUnstored144's `R11U144_PKGQUALREF_OFF`): the `$root` element keeps its own token;
  this pass's drains still fix the path's and the leaf's names there.
- S3. A range bound's bare decimal keeps its separators in the decompile (`logic [1_5:0]`, us u03 u08): the range
  builder (TypeEmit / ModuleEmit) writes the raw text; § bareDecUnderscoreDropped181 is the rule to transcribe there.
- S4. **InterfArrayBind d fullname(3)**: the elaborated generate scope's interface-array path index (`#166/#177`) is
  parented at the hier_path and named `work@soc_tb.io_gen[0].io_idx` where golden (default view only; the testflags row
  is CMP_EQUAL because the listener re-clones) parents it at the first element's bit_select with the chain name; and
  the module-level `#183` is the elaborated listing sharing the DEFINITION's continuous assignment object
  (ModuleEmit, the instance's cont_assign listing), which golden copies. The ExprEmit half alone cannot convert the row.
- S5. The type parameter's local typespec in a class method (dw/d04 `#18 int_typespec`) and the `$root` class `C`
  full name in an elaborated module (rt/g17 elab `work@sub::C`): TypeEmit / ModuleEmit.

## 12. Earlier sweeps (superseded law sets, kept for the record)

`/tmp/r11u181_swL` (dev7: the first seven laws) and `/tmp/r11u181_swM` (`law181.bin`, 14 laws) both read regressions=0
in all three stages and the same four corpus conversions; swM's downstream csv was byte-identical to swP's. The final
set adds § lvIdxMixedPathIsRead181, the stream / nested exclusions of § classMethodLvIsProcess181, and the select-index
branch of § lvSelIdxChainName181 (the a01 and v79v2_recv break hunt).

## 13. Files

- `cases/rt` (§ rootPathFullNameByChain181, § rootNetPathOwnNames181, § rootPathElemOwnName181: g01-g20, s01-s06),
  `cases/bx` (§ bitSelParenIdxSpan181: b01-b15), `cases/ix` (§ incDecBitSelWholeSpan181: i01-i05), `cases/us`
  (§ bareDecUnderscoreDropped181: u01-u08), `cases/dw` (§ doWhileMacroCondEnd181 d01-d03, § doWhileSyntaxFromCond181
  d04-d05), `cases/im` (§ incDecMixedPathIsLvalue181 m01-m03, § lvSelIdxChainName181 m04-m07, with
  § classMethodLvIsProcess181 m03 m05), `cases/lc` (§ procLvIdxCallWholeSpan181: c01-c06), `cases/nw`
  (§ newLhsBitSelAtIndex181: n01-n04), `cases/lx` (§ lvIdxMixedPathIsRead181: x01-x03), `cases/adv` (the break hunt,
  a01-a10, each naming the laws it attacks). Every case names its laws in its first line.
- `drivers/`: `env.sh` (pins, `$FENCED`), `grid.sh` / `gridall.sh` / `pair.sh` (golden + ours + uhdm-cmp + strictcmp per
  case, both views), `recs.py` / `enter.py` / `anc.py` / `consts.py` / `dconsts.py` (record readers), `switchmatrix.sh`
  and `offbytes.sh` (switch matrix, pass switch), `predict181.cpp` / `predict181.sh` / `cc181.sh` (mover predictor),
  `probemovers.sh`, `obmovers.py`, `obrows.sh` (movers and their direction), `bvmirror.sh`, `rowrec.sh`,
  `tracewrap.sh` / `offwrap.sh` (census and switch-off wrappers for the harness).
- `evidence/`: the two sweep logs, byte-verify, predictions, probe movers and directions, corpus mover directions and
  record-level CHANGE attribution, the census, the switch matrix, the grid tables, canaries, the UVM coin check.
