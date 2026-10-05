# v11u244 — adversarial verification of r11u244 (pass 244, the expression/parameter ground)

Base `2b7fb2f5` (matrix-1.87). Subject: the implementer's patch (md5 `d54e3c79e741815c4d4e0c6238916877`), seven laws
behind `src/R244.h` (§ cloneBlockArrElemOwnCopy244, § cloneBlockFixedArrTsParented244, § cloneNewArrayCallParented244,
§ hpSelIdxPathTrailByChain244, § lvHpIpsOperandChain244, § invalidBlockLocFromSyntax244,
§ methCallNameSpanAcrossLines244; README in [../r11u244repro/README.md](../r11u244repro/README.md)).

**Verdict: VERIFIED WITH ONE FIX.** Every headline number of the implementer reproduces bit for bit. Fresh cases
found one shape on legal SV where the patch moves a database away from golden: a block-local whose array type comes
from a typedef (`ia_t t;`, `iq_t q;`, `id_t d;`) in an importer's copy. The fix is § blkElemCopyDeclDimsOnly244v
behind `R11V244_TDARR_OFF` (`R11V244_OFF` drops it and restores the implementer's bytes). It moves no gate database.
The pass also shipped 67 cases whose first line named a law that does not exist; their first lines are corrected.

The four slang-fenced tests are never named here. Every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed. Nothing fenced was dispatched outside the gate sweeps,
decoded or opened: every corpus path list was filtered by `$FENCED` before any file was opened (cmds.txt audit,
byteverify mirrors, downstream lane compare, away census, evidence copies), and the determinism and trace runs used
fixed filters over the five UVM rows and Earlgrey_0_1.

## Binaries (frozen before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine `/tmp/v11u244_bin/pristine` | `ffc33c14c9ae12cc33b6f0eeee552e26` | built at `2b7fb2f5` (system-deps config, `-j 2`); equals the required md5; reports slang 12.0.0+545f88b2e |
| law `/tmp/v11u244_bin/law` | `6961085a65faf68adff922649aebecea` | the implementer's patch applied on a fresh `2b7fb2f5`, built here: **the implementer's md5** |
| fix `/tmp/v11u244_bin/fix` | `0ee8bac0f2977b28668761f74cc585f2` | law + § blkElemCopyDeclDimsOnly244v |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | same as the implementer's |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `../r11u244repro/drivers/cc_x.sh`; same as the implementer's |

cmds.txt audit (path lists filtered by `$FENCED` first): pristine sweep 3265 of 3315 name `/tmp/v11u244_bin/pristine`
and nothing else, law sweep 3265 of 3315 name `/tmp/v11u244_bin/law` and nothing else; the other 50 are golden-only
runs (Surelog fails or the row is not translatable) that name no slang binary.

## Reproduction of the implementer's numbers

| item | implementer | this verification |
|---|---|---|
| pristine sweep | probe 3481 + 606; surelog 470 + 10 / 466 + 8; u2r 803 + 0; downstream 803/66/2/0 | identical ([evidence/sweeps/sweep_P.txt](evidence/sweeps/sweep_P.txt)) |
| law sweep, probe | 3493 + 594, regressions 0, conversions 12, changes 7 | identical, the same 12 + 7 by name ([sweep_L.txt](evidence/sweeps/sweep_L.txt)) |
| law sweep, surelog | 0 regressions, 0 conversions, 7 changes | identical: BuildUVMPkg d/t `file(8) -> endcol(4)`, MiniAmiq d/t and SeqDriver d/t `fullname(4) -> depth(1)`, Scoreboard d `fullname(3) -> file(2)` |
| law sweep, u2r / downstream | 0/0/0; 803/66/2/0, verdict csvs identical | identical; 0 of 805 downstream slang-lane databases move |
| csv rows pristine vs law | the 7 surelog rows, 19 probe rows, LowMem detail text | identical |
| byteverify (SELFCHECK=1, fence-filtered hard-link mirrors) | 9 / 2560 | 9 / 2560, the same nine with the same hashes ([movers/byteverify.txt](evidence/movers/byteverify.txt)) |
| probe movers | 19 / 4087 | 19 / 4087 (pristine probe sweep rerun from the law worktree, since a probe database embeds the worktree path; the cross-worktree compare reads 4087 / 4087, an artifact) |
| prediction | 28 named, every one moved | the implementer's list frozen here at 05:26:35 before this law sweep; 9 corpus and 19 probe movers equal it name for name |
| uhdm-cmp on the 9 corpus movers | 0 lines | 0 lines each |
| away census (chain key, strictcmp_x) | 0 away on 28; MiniAmiq 972, SeqDriver 652 toward per mode | 0 away and 0 flat-away on all 28; toward 972 / 652 / 14 / 14 / 11 and g208_e_head 48, the same ([movers/away_sweeps_pristine_law.txt](evidence/movers/away_sweeps_pristine_law.txt)) |
| g208_e_head `fullname(4) -> fullname(8)` | walk diverges later | confirmed: the old first record #92 (`addrs208`'s block element, golden `...::m_set_reg_offset208`) and pristine's #119 depth misalignment are cleared; #109 is in the pristine database too; the added records #173, #386, ... are the alias-name face of item (1)(e) reached by the longer aligned walk |
| canaries | surelog ok=47 changed=5; u2r ok=16; both ctcan2 PASS | identical ([movers/canaries.txt](evidence/movers/canaries.txt)) |
| determinism | 11 of 11 one hash | three concurrent draws: 11 of 11 one hash, equal to the sweep databases, for law and for fix ([movers/determinism.txt](evidence/movers/determinism.txt)) |
| grid | 2580 lines, 254 rc 0, f19 rc 3, x02 rc 4; 108 enter, 0 leave; OFF pristine on 258 | rerun: verdicts identical line for line to `../r11u244repro/evidence/grid.txt` (md5 fields differ only because a database embeds the case path); 108 enter, 0 leave, `R11U244_OFF` pristine on 258 of 258, per-switch counts 46 / 28 / 28 / 24 / 20 / 17 / 16 as reported ([grid/r11u244_grid_rerun_law.txt](evidence/grid/r11u244_grid_rerun_law.txt)) |

`SELFCHECK (every file vs one fixed file): 2559 / 2560 flagged` is the comparator's negative control reading
correctly: one side is replaced by a single fixed file, and the one path whose own database IS that file cannot
differ from it, so 2559 of 2560 is the maximum.

The fresh first records ([movers/heads.txt](evidence/movers/heads.txt)), pristine -> law (= fix):

```
MiniAmiq d   #71388 fullname int_var  golden ...uvm_table_printer::emit  ours ...::emit::q
          -> #76762 depth   golden class_var iter (uvm_pkg::uvm_phase::execute_phase::iter)  ours method_func_call first
SeqDriver d/t #71344 / #71356 -> #76718 / #76730, the same two faces
Scoreboard d #81633 fullname ref_obj addr  golden ...::write::predict_info.addr[]::addr::addr  ours ...::write::addr
          -> #84633 file    param_assign  golden no file  ours uvm_analysis_port.svh 110:31
BuildUVMPkg d/t #81827 file begin  golden uvm_pkg.sv 45157:26-45159:8  ours no location
          -> #91593 endcol  int_typespec  golden 9187:66-9187:69  ours 9187:66-9187:78
SimpleUVM d/t #75684 / #75696 file logic_net work@top.this, unchanged (the sister ground; pass 243 has since landed there)
```

## The break and the fix

### § blkElemCopyDeclDimsOnly244v (`R11V244_TDARR_OFF`; StmtEmit `recordBlkElemCopy244`)

Cases: [E/e08_x_nested_loop](cases/E/e08_x_nested_loop/dut.sv), [E/e11_x_tdarr_kinds](cases/E/e11_x_tdarr_kinds/dut.sv).

A local whose array type comes from a typedef (`ia_t t;` with `typedef int ia_t[4]`, `iq_t q;`, `id_t d;`) has **no
element entry on the block** in golden, in the home listing and in the importer's copy: Surelog compiles the typedef's
typespec and mints no element variable. Ours already lists one at the base, shared with the array_var (a
pre-existing face, the home listing's too). § cloneBlockArrElemOwnCopy244 replaced that block entry with a private
copy, so the walk met two element variables where golden meets none:

| case-view | records off golden: pristine -> law -> fix | away (chain) |
|---|---|---|
| E/e08_x_nested_loop | 56 -> **60** -> 54 | 0 |
| E/e11_x_tdarr_kinds | 239 -> **265** -> 241 | 0 |
| E/e11_x_tdarr_kinds `-elabuhdm` | 461 -> 457 -> 457 | 0 |

The records the law added (e08, the copy `q::fac::emit`): golden `6 array_var t` only; pristine `6 int_var` (shared)
+ `6 array_var t`; law `6 int_var q::fac::emit` (the copy) + `6 array_var t` + `7 int_var q::fac::emit::t` (the
original, now met again under the array_var). Both cases already fail stage 1 at the base on another face (the
package order), so no verdict moves; the away census reads 0 lost, but the distance from golden grows by 4 and 26
records on legal SV where the law has no golden support. That is pristine-right in the sense of the brief (a record
count moving away from golden), so it is fixed.

**Law:** the block-element copy abstains when the local's declarator carries no unpacked dimension (trace tag
`blkElemCopyDeclDimsOnly244v`). Declarator arrays (`int q[5]`, `by_t q[4]`, `int a[string]`, `int d[]`, `int qq[$]`)
keep the law. `ia_t b[3]` (a declarator over a typedef'd array element) keeps it too: golden lists a block-level
element there (an array_var, ours an int_var at the base: a pre-existing kind face, residue 4).

Measured on the fix binary:
* Gate sweep ([sweep_F.txt](evidence/sweeps/sweep_F.txt), rc 0, law index current): probe 3493 + 594 with the same 12
  conversions and 7 changes; surelog 470 + 10 / 466 + 8 with the same 7 changes, 0 regressions, 0 conversions;
  u2r 803 + 0 per mode, 0 / 0 / 0; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0, not excused 0.
* Fix vs law: **0 of 2560 corpus, 0 of 4087 probe and 0 of 805 downstream databases move**; every csv row
  identical apart from the LowMem SURELOG_FAIL detail text (it carries the workdir path). The prediction, frozen
  before the fix sweep ([movers/fix_predicted_frozen.txt](evidence/movers/fix_predicted_frozen.txt)), was 0: the
  refinement's trace fired 0 times on the five UVM rows in both modes (the only corpus rows where
  § cloneBlockArrElemOwnCopy244 fires; their databases byte-identical to the law's) and 0 times on g208_e_head (the
  only probe case where it fires).
* Fix vs pristine: the same 9 corpus movers as the law.
* The implementer's 129 cases on the fix binary ([grid/r11u244_cases_fix.txt](evidence/grid/r11u244_cases_fix.txt)):
  fix bytes = law bytes on 258 of 258 case-views, `R11U244_OFF` pristine on 258 of 258, `R11V244_OFF` the law's
  bytes on 258 of 258.

## Fresh cases (59 cases, both views; [cases/](cases/))

Each case names its law in its first line. `drivers/grid.sh` ran pristine, the law, the law with `R11U244_OFF`, and
the law with each switch ([grid/vgrid_law.txt](evidence/grid/vgrid_law.txt), 1180 lines); the same grid on the fix
binary adds `R11V244_TDARR_OFF` and `R11V244_OFF` ([grid/vgrid_fix.txt](evidence/grid/vgrid_fix.txt), 1416 lines).
**Every line carries its exit code; all 1416 are rc 0.** Downstream verdicts of every case on pristine, law and fix
([downstream/](evidence/downstream/)).

| group | law | shapes |
|---|---|---|
| A a01-a15 | § hpSelIdxPathTrailByChain244 | module unpacked-array FIRST select `s[t.k].w` (a01, a13 in a class), always_ff lvalue, a path nested in a path index (a03, a14 two levels), rvalue indexed part selects with a path base and with an operation base, an interface instance `b.mem[t.k]` (a05), for-generate two levels deep (a06), a child port connection (a07), constant slots: a header struct parameter and a localparam in indexed part-select bases (a08), a three-element inner path, a call index, an operation, a concatenation and `exists` (a09), `this.` / `super.` inner paths (a10), an importer copy (a11), an implicit net (a12), inc/dec, unary indices, a function defined below its caller, a streaming lvalue, a queue `$` (a14), if/case generate scopes and a cross-scope `g_if.u.k` (a15) |
| B b01-b07 | § lvHpIpsOperandChain244 | always_ff in a for loop, `-:` with an operation, a genvar base inside a for-generate, class forms (a call base, `$clog2`, a nested member, `+=`, a member base, an operation width), an importer copy, a nonblocking assignment in a module task, instances at depth 1-3 under a generate |
| C c01-c08 | § methCallNameSpanAcrossLines244 | spaces, a tab, a newline before and after the dot, deep receivers, a call receiver, queue methods, a parens-less call, macros (`O.M`, `O. M`, a macro argument on the next line), receivers named like the method and methods whose names are prefixes of others, block and line comments, interface methods in a module, `randomize() with`, `srandom`, string and queue built-ins in a module, `this.` / `super.`, extern methods defined below the class and pure virtual prototypes with named and empty-slot arguments |
| D d01-d08 | § invalidBlockLocFromSyntax244 | an unbindable call under if/else, case items and default, while, repeat, do-while, fork in a task, a declaration in the block, the subroutine's first item, nested foreach, a for body, a macro body, and a macro from an included file with a backslash-continued body |
| E e01-e11 | § cloneBlockArrElemOwnCopy244, § cloneBlockFixedArrTsParented244, § blkElemCopyDeclDimsOnly244v | in-class and extern-body methods, a fork in a task, 2-D, associative, dynamic and queue locals, typedef'd element and array types, nested loops and if blocks, a named block with parameter-sized dimensions (`[N]`, `[N-1:0]`, `[$clog2(N*4)]`), struct, class-handle and string elements, two importers |
| W w01-w06 | § cloneNewArrayCallParented244 | in-class and extern-body forms: `new[n]`, `new[n](d)`, a property, `this.`, a call size, `$clog2`, a nested begin, foreach, a condition, task and static forms, fork, a free package function, declaration initialisers |
| X x01-x04 | context | a class specialization with a parameter in bounds and a `cfg#(N)::k` index, extern and pure virtual prototypes with named / empty-slot arguments, linked named calls with an omitted default in an index, an interface body with an always_ff indexed part select |

Results, pristine -> fix ([grid/vgrid_fix_summary.txt](evidence/grid/vgrid_fix_summary.txt),
[grid/vgrid_away_pristine_fix.txt](evidence/grid/vgrid_away_pristine_fix.txt)):
* 118 case-views; 97 move bytes; **41 enter STRICT_EQUAL, none leaves**; `R11U244_OFF` writes pristine's bytes on
  118 of 118; `R11V244_OFF` writes the implementer's law bytes on 118 of 118; `R11V244_TDARR_OFF` changes only E e08
  and e11 (4 case-views).
* Chain-keyed away census: **0 lost on all 118**, 482 records toward.
* Downstream: the same verdict on pristine, law and fix for all 59 cases (54 IDENTICAL, 2 DIVERGENT and 3
  STATUS_DIFF identical on all three binaries: A a04, B b02, A a05, C c04, X x04, pre-existing); the slang-lane
  RTLIL of every case byte-identical on the three binaries. Every module-level firing of the naming laws (a02, a06,
  a07, a12, b01, b03, b06, b07 among them) leaves the netlist unchanged.
* One uhdm-cmp line count rises: E e06 default 368 -> 390. Not a new failure: the stage-1 path is the same on both
  binaries (`design > package(p)` vs `package(q)`, the package order at the base), and uhdm-cmp prints the whole
  subtree pair, which now holds the copied element variable. Records there move toward golden only (12 toward,
  0 away).

## Findings that stay as residues (pristine wrong as well, no record lost)

1. **§ hpSelIdxPathTrailByChain244 on a module's FIRST select** (A a01 `s[t.k].w`): golden stores and reports no full
   name on the trailing `k`; pristine wrote `work@top.k`, the law writes `work@top.s[].w.k`. Count unchanged (4 -> 4),
   0 lost. In a class (A a13 `q[rw.k].m`) the law moves toward golden.
2. **The chain renders a path or an operation in the index differently from golden**: golden drops a hier_path operand
   from an operation's text (`s.d[ * 8+:8]`, `s.d[ + 3'd1-:2]`, `pi.d[ * 2-:2]`) and drops the brackets of an inner
   or streamed path's select (`pi.v[]::v::pi.o.v::v::k`, `pi.v::v::k`) and of an interface instance's select
   (`work@top.b.mem.mem.k`); `chainFullName175` writes the decompile (`s.d[t.k * 8+:8]`) and the brackets. Cases A a04,
   a05, a08, a14, X x04: pristine wrote the scope name (`work@top.k`), counts unchanged or falling, 0 lost. Site:
   ExprEmit `chainFullName175` as called by `drainHpSelIdxTrail244`.
3. **The block copy of a struct element** (E e10): the copy's member ref_typespecs read `work@top.p::st_t.a`, golden
   `q::fac::emit::p::st_t::a`, pristine `q::fac::emit::s::p::st_t::a`; flat key 2 / 4 records (the chain key 0); the
   walk's first record moves later in the `-elabuhdm` view (#218 -> #684).
4. **`ia_t b[3]`** (E e11): golden's element is an array_var at block level and under the array_var; ours an int_var at
   the base (kind face, StmtEmit's fixed-size block branch, declArrayElemVarKind12's site).
5. **Typedef'd array locals list an element at all** (E e08, e11, home and copy): golden lists only the array_var with
   the typedef's typespec; ours lists an int_var and an anonymous array_typespec (StmtEmit's fixed-size and queue
   block branches). The fix stops the law from doubling it; removing it is a separate law.
6. The implementer's residues stand as reported: BuildUVMPkg #153018 (StmtEmit `arrayVarArrayTs`, item (1)(e)),
   Rggen d #23546 (ExprEmit's call-argument stamping beside § nestedParamActualTs6), BlackBePipeInt #38807 / #38803,
   Earlgrey_0_1 d/t #136315 / #137760, grid D d12, N n04, N n08, F f13, the W stage-1 shapes, and the sister-ground
   heads (MiniAmiq / SeqDriver #76762 UhdmExporter `pkgCloneHierBind9` / § cloneStmtHomeVarRef17, Scoreboard #84633
   the UhdmExporter class_typespec param_assign writers, BuildUVMPkg #91593 TaskFuncEmit's formal typespec span,
   SimpleUVM TypeEmit `thisImplicitNetBoth38`).

## Delivery corrections

* **Phantom law names.** 67 of the implementer's 129 cases named laws that do not exist in their first line
  (`lvHpSelIdxPathTrailUnnamed244` 24, `foreachBodyBeginLoc244` 20, `cloneBlockFixedArrElemOwn244` 13,
  `hpIpsOperandRefByChain244` 10), so `tests/LAWS.md` attributed none of them, and § cloneBlockFixedArrTsParented244
  had no case at all. Corrected by the switch that changes each case's bytes in the grid: F -> § invalidBlockLocFromSyntax244;
  L i01-i06, i08-i10 -> § lvHpIpsOperandChain244, i07 -> § hpSelIdxPathTrailByChain244; L l*, m* ->
  § hpSelIdxPathTrailByChain244; N n01-n03, n05 -> § cloneBlockArrElemOwnCopy244, N n04, n06-n13 ->
  § cloneBlockFixedArrTsParented244. The databases do not change (no file text is stored in them): the fix binary
  wrote the law's bytes on all 258 case-views after the edit.
* `tests/LAWS.md` regenerated last (`python3 scripts/law_index.py`).

## Process

* Worktrees `/tmp/wt_v11u244` (law, then fix) and `/tmp/wt_v11u244pris` (pristine) at `2b7fb2f5`; scratch
  `/tmp/v11u244_*`. The main checkout was never written. No submodule was initialised.
* The pristine binary was frozen before the law binary finished building; the fix source was edited only after the
  law binary was frozen, and the law sweep ran from the frozen copy.
* Every tool reached through a variable was checked with `[ -x ]` (`drivers/env.sh`, `case.sh`, the envx helper)
  before use.
* The determinism draws ran `../r11u244repro/drivers/det.sh` (a fixed list, checked against `$FENCED`).
* No process of another agent was listed or signalled; no `pgrep` or `ps` listing was used.

## Drivers ([drivers/](drivers/); each reads `$FENCED` fail-closed)

`env.sh`, `case.sh` (copied from r11u244repro; a case of either pass is keyed by its path), `grid.sh` (the switch grid,
`EXTRA_SW` adds the R11V244 switches), `gridmin.sh` (pristine / law / fix / fix + R11U244_OFF / fix + R11V244_OFF),
`gridsum.py` (per case-view verdicts, OFF check, switch reverts, enter / leave counts), `caseaway.py` (map 13's
chain-keyed away census on one case-view, each database dumped by comparing it with itself so stage-1 cases are walked
too), `ds.py` (the downstream verdict of every case through `scripts/downstream_uhdm2rtlil.py`'s `one()`), `look.sh`
(raw-full-name records of golden and ours matching a pattern).
