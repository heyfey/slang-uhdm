# v11u246 — adversarial verification of r11u246

Base `08d31c79` (matrix-1.87). Worktrees `/tmp/wt_v11u246` (the implementer's patch, then the fix) and
`/tmp/wt_v11u246pris` (pristine), scratch `/tmp/v11u246_*`. The four slang-fenced tests are never named here; every
driver reads them from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed.

## Verdict: ACCEPT WITH ONE FIX

Every number the implementer reports reproduces exactly, including the md5 of the law binary. The fresh cases break one
of the nine laws, § callArgParamCopyOwnTs246, on legal SV where pristine was right. On the six shapes below,
**12 case-views leave STRICT_EQUAL**: pristine is STRICT_EQUAL on all 12 and the law reads `STRICT_NOTEQUAL line`. In
all, 25 case-views each lose one golden-agreeing record (the other 13 are stage 1 on both binaries).

The fix is § callArgCopyEvalCtxAbstain246v (`R11V246_PAEVALCTX_OFF`; `R11V246_OFF` drops every fix of this
verification). After the fix:

* all 12 case-views are STRICT_EQUAL again, and 0 fresh case-views lose a record;
* the fix writes the law's bytes on all 2560 corpus, all 4087 probe and all 805 downstream databases (predicted 0, frozen
  before the fix sweep);
* the fix writes the law's bytes on all 186 of the implementer's case-views;
* every gate reads as it does for the law.

Delivery: `/tmp/r11u246.verified.patch`.

## Binaries (frozen under `/tmp/v11u246_bin/`, `chmod 555`, before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine | `2af88ce8c0c70f3e728d6e8fdfaf0d9a` | built at `08d31c79` in `/tmp/wt_v11u246pris` with the system-deps config (`-j 2`); identical to the main tree's `build/slang-uhdm`; reports slang 12.0.0+545f88b2e |
| law | `35706fcd9b8f6a3e61d1874dc6e84d1e` | `/tmp/r11u246.patch` applied to a fresh `08d31c79`, built here; **the same md5 as the implementer's frozen law binary** |
| fix | `d96f6017a0355dd2e29967ba8ade040f` | law + this verification's fix (incremental build in the same tree; see "Clean rebuild" below) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the pristine worktree's build (all three sweeps' `uhdm-strictcmp` read the same md5) |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `drivers/cc_x.sh` (equal to the implementer's) |

Binary audit: for each of the three corpus sweeps, the `cmds.txt` path list was built first, filtered by `$FENCED`, and only then
read (3315 files per sweep). Each sweep names only its own binary, 3265 slang runs each (`/tmp/v11u246_bin/pristine`,
`law` and `fix`).

## Reproduction of the implementer's numbers (all bit-for-bit)

| item | implementer | reproduced |
|---|---|---|
| pristine sweep | probe 3510 + 577; surelog 470+10 / 466+8; u2r 803 per mode; downstream 803/66/2/0; all 0/0/0 | identical ([sweeps/sweep_P.txt](evidence/sweeps/sweep_P.txt)) |
| law sweep, probe | 3538 + 549; regressions 0, conversions 28, changes 5 | identical, the same 28 names and 5 changes ([sweeps/sweep_L.txt](evidence/sweeps/sweep_L.txt)) |
| law sweep, surelog | changes 4: Rggen d line(202) -> fullname(199), Scoreboard d type(1) -> line(6), SimpleUVM d/t type(1) -> line(6) | identical |
| law sweep, u2r and downstream | 0/0/0; 803/66/2/0 | identical; downstream verdict csvs sorted and diffed: 0 lines |
| byteverify law vs pristine | 10 / 2560 movers | `PATH_SETS_IDENTICAL (2560 paths)`, `MOVERS: 10 / 2560`, the same 10 row-modes ([movers/byteverify_law_vs_pristine.txt](evidence/movers/byteverify_law_vs_pristine.txt)) |
| prediction | 47 rows, md5 `f9933dbb…`, frozen before the law sweep | the 10 corpus movers and 35 probe movers are all on it; the two over-predictions (r10buvm8repro/v3_argts8, r10v122repro/q7extra) did not move here either |
| probe movers | 35 of 4087 | 35 of 4087 against a pristine probe sweep run from the law worktree (probe databases embed the worktree path) ([movers/probe_movers_law_vs_pristine.txt](evidence/movers/probe_movers_law_vs_pristine.txt)) |
| downstream movers | 0 of 805 | 0 of 805, fence-filtered path list; positive control: two different lanes compared across the sweeps are flagged |
| uhdm-cmp on corpus movers | 0 lines on all 10 | 0 lines, rc 0, on all 10 for both law and fix ([movers/uhdmcmp.txt](evidence/movers/uhdmcmp.txt)) |
| away census | 45 databases, chain and flat away 0 | 45 databases, chain away 0 and flat away 0 on every one, toward numbers identical (SimpleUVM 260 per mode, MiniAmiq 186, Scoreboard 168, SeqDriver 145 / flat 118, BuildUVMPkg 23, Rggen 13, v4_home 48, m_sat_13x 13); the swapped run reads them as away with toward 0 ([movers/away_law_vs_pristine.txt](evidence/movers/away_law_vs_pristine.txt), [movers/away_reversed_control.txt](evidence/movers/away_reversed_control.txt)) |
| canaries | surelog ok=49 changed=3; u2r ok=16; both ctcan2 PASS | identical for law and fix ([movers/canaries.txt](evidence/movers/canaries.txt)) |
| determinism | one hash per row-mode on 11 of 11 | one hash per row-mode on 11 of 11 for law **and** fix (three concurrent draws each). The hashes equal the implementer's and the sweep's databases, and fix's hashes equal law's ([movers/det_law.txt](evidence/movers/det_law.txt), [movers/det_fix.txt](evidence/movers/det_fix.txt)) |
| implementer's grid | 2232 lines; R11U246_OFF pristine 186/186; 95 entering, 0 leaving; per-switch reverts DPITOPRES 38, FEOWNTS 6, HPFNSTATIC 12, MARGCASTTS 12, MACNAMEEND 6, STREAMBRACEMAC 6, COLSPANFILE 6, PACOPYTS 22, LVNETMIDSEL 12 | rerun with these binaries: every one of the 2232 lines carries the same verdict, cmp count and exit code. Only the md5 column differs, because the databases embed the worktree path. The summary and the per-switch reverts are identical ([grid/impl_grid_rerun_summary.md](evidence/grid/impl_grid_rerun_summary.md)) |

Heads ([movers/heads.txt](evidence/movers/heads.txt)), reproduced with `uhdm-strictcmp` against the cached v1.87 goldens:

```
SimpleUVM d   pristine #98800  type    A enum_typespec uvm_pkg::uvm_severity uvm_sequence_item.svh 352:37-352:49 / B unsupported_typespec uvm_severity uvm_globals.svh 168:15-168:27
              law      #159457 line    A int_typespec uvm_queue.svh 171:35-171:36 / B 43:13-43:14   (t: #98812 -> #159469, the same)
Scoreboard d  pristine #130737 type    A constant INT:63 uvm_reg_model.svh 73:24-73:26 / B operation 73:24-73:28
              law      #159637 line    the uvm_queue T face above
Rggen d       pristine #23546  line    A int_typespec rggen_or_reducer.sv 3:13-3:16 / B 8:55-8:58
              law      #26477  fullname A ...g_decoder[0].u_decoder.i_access.access / B ...u_register_common.register_if.access
BuildUVMPkg d pristine #91593 #129711 #153018 (3 records)  ->  law #91593 #129711 #185844 (#153018 cleared)
MiniAmiq d / SeqDriver d  #76762 / #76718 depth on both (the sister's iter class_var)
```

The byteverify self-check reads `SELFCHECK (every file vs one fixed file): 2559 / 2560 flagged` on every pair. This is
how the check is built, not a mover line. It replaces one side with a single fixed file and compares each of the 2560
paths against it. The fixed file is one of those paths, so compared with its own bytes it cannot be flagged: 2559 of
2560 is the correct reading.

## The break: § callArgParamCopyOwnTs246 on a parameter Surelog reduces

The law keeps the parameter's own typespec on the copied actual of `localparam bit [N-1:0][7:0] L = f(N)`. Its decode
names the exception: an evalFunc that runs the call **in the tree** binds the actual to the formal. That exception is
UHDM `ExprEval::evalFunc`, which sets `exparg->Typespec()->Actual_typespec(tps)` on each reduced argument.

The law models only the nested write-through of § nestedParamActualTs6. But Surelog also evaluates the in-tree call
whenever it **reduces a reference to L** against L's param_assign Rhs, and the copy then wears the formal's
`int_typespec`, as pristine writes it. Measured on the v1.87 pin, both views (grid PE; the cases name
§ callArgCopyEvalCtxAbstain246v):

| case (PE/) | where L is read | pristine | law | fix |
|---|---|---|---|---|
| e06_genif_cond | `if (L[1] == 8'd1) begin : g` | STRICT_EQUAL | **STRICT_NOTEQUAL line**, 1 away | STRICT_EQUAL |
| e10_genfor_bound | `for (genvar i = 0; i < L[0]; i++)` | STRICT_EQUAL | **line**, 1 away | STRICT_EQUAL |
| e11_casegen | `case (L[1])` generate | STRICT_EQUAL | **line**, 1 away | STRICT_EQUAL |
| e13_dim_bound | `logic [L[1]-1:0] w;` | STRICT_EQUAL | **line**, 1 away | STRICT_EQUAL |
| e14_repl_count | `assign q = {L[1]{1'b1}};` | STRICT_EQUAL | **line**, 1 away | STRICT_EQUAL |
| e17_genif_nested | `if (L[1] > 0) .. if (L[2] != 0)` | STRICT_EQUAL | **line**, 1 away | STRICT_EQUAL |
| e01, e19, e22, e18 | `assign q = L[0];`, `L[0] + 8'd1`, `wire [7:0] wq = L[2];`, `.d(L[1])` | stage 1 (golden folds the select) | 1 away each | 0 away |
| e12 | `leaf #(.P(L[1]))` | stage 1 | 1 away | 0 away |
| e25 | `function int g(); return L[1]; endfunction` with `if (g() == 2)` | stage 1 | 1 away (default view) | 0 away |
| X/v02_ctx_mod | `assign w.key[N-1].d = L[0];` (context case) | stage 1 | 1 away per view | 0 away |

Where the law stays right and the fix keeps it: e02 `assign o = L;`, e03 (`o` a port of `L`'s type), e05
`localparam X = L[1]`, e07 `$bits(L)`, e08 `assign q = L[1][3:0];`, e09 `always_comb q = L[2];`, e23 / e24 (a
localparam `Z = L[1]` then `Z` in a dimension or a generate condition), the implementer's PA p01-p13, Rggen
(`SUB_N_LIST` read in an `always_comb` and in other localparams' initializers) and probe r10rgg13repro/top
(`assign o = LP[0][0];`). All 12 of these case-views are STRICT_EQUAL on law and fix alike.

### § callArgCopyEvalCtxAbstain246v (`R11V246_PAEVALCTX_OFF`; ExprEmit `drainCallArgCopyTs246`, helper `callArgCopyLpReduced246v`; ParamEmit sets `curMdimParam246v()` beside `elabMdimParamInit`)

**Law.** The copy keeps the formal's typespec, which gives pristine's bytes, when L's module syntax names L in any of these places:

* under a declaration dimension (`VariableDimension`);
* in a replication count;
* in an instance parameter assignment;
* in a generate `if` or `case` condition, or a case-generate item label;
* in a generate loop header;
* inside a task or function body;
* **with one select**, outside an always, initial or final block and outside a parameter initializer.

A select of a select (`L[1][3:0]`, `LP[0][0]`) and a whole-L read stay with the law.

Surelog's structural reductions are not uniform: `L[1] ^ L[2]` (e20) and `L[0 +: ..]`-style bounds (e15, e16) stay
unreduced in golden. The abstention there is therefore conservative: those six case-views keep pristine's bytes, and the
law's one toward record on each is not taken (they are STRICT_NOTEQUAL or stage 1 on all three binaries). The rule is a
syntax scan of L's own module. It runs only when the law would fire, and it fires in **no** corpus, probe or downstream
database (census: the tag `callArgCopyEvalCtxAbstain246v` was written by 0 processes).

## Gates on the fix binary (`/tmp/v11u246_wF`, [sweeps/sweep_F.txt](evidence/sweeps/sweep_F.txt))

* probe: EQUAL 3538 + 549, **regressions 0**, conversions 28, changes 5, the same names as the law sweep;
* surelog: 470+10 / 466+8, **regressions 0**, conversions 0, changes 4, the same rows as the law sweep;
* uhdm2rtlil: 803 per mode, 0/0/0;
* downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0.

The fix sweep's csvs equal the law sweep's row for row. The only difference is the two LowMem detail texts that carry
the workdir path.

The targeted rows, fresh from the fix sweep:

```
Rggen,default,STRICT_NOTEQUAL,differ:fullname(199),,differ:fullname(199)
Scoreboard,default,STRICT_NOTEQUAL,differ:line(6),,differ:line(6)
SimpleUVM,default,STRICT_NOTEQUAL,differ:line(6),,differ:line(6)
SimpleUVM,testflags,STRICT_NOTEQUAL,differ:line(6),,differ:line(6)
```

Movers:

* **fix against law:** byteverify 0 / 2560 corpus, 0 / 4087 probe, 0 / 805 downstream. The frozen prediction was none
  ([census/predicted_fix_vs_law.txt](evidence/census/predicted_fix_vs_law.txt), frozen 2026-10-05T08:53:17 before the
  fix sweep started).
* **fix against pristine:** the same 10 corpus movers. The census prediction for fix is byte-identical to the implementer's
  law prediction (md5 `f9933dbb316869b183685f9d6b3f7960`).

uhdm-cmp reads 0 lines on all 10 movers. Canaries ok=49 changed=3 (the three targeted) and ok=16, and both ctcan2
checks PASS. Determinism is one hash per row-mode on 11 of 11.

## Fresh cases (80 cases, both views: 160 case-views; [grid/vgrid_fresh_summary.md](evidence/grid/vgrid_fresh_summary.md))

Every case names its law in its first line. Each runs on pristine, law, fix, fix + `R11V246_OFF`, fix +
`R11V246_PAEVALCTX_OFF` and fix + `R11U246_OFF` (`drivers/vgrid.sh`; 960 lines, every line carries its exit code).

| group | law | cases |
|---|---|---|
| DT v01-v09 | § dpiTopCastResolvesByModImport246 | a header item import `import p::sev_e;`; only a child module imports (with an implicit net in top); an interface only (control); a module in an included file with the file-scope import in the root; a macro-born import; a file-scope import AFTER the module in a second file; two packages each with an export (one imported); an import of another item (control); a class-method DPI path |
| FE v01-v07 | § foreachLocalArrTsOwnListing246 | a typedef'd dynamic array local; 2-D foreach over dynamic and fixed locals; a parameterized class specialised in a module; static locals with `$clog2`-sized dimensions, `-:` part-selects and replication in the body, plus a task with fork; two methods with the same local name; a package function called by an importer; enum and struct elements |
| HS v01-v06 | § hpFnStaticTrailScopeJoin246 | a package-function reader; a named block's static `f.blk.x`; a module function (control); inc/dec, index, indexed part-select and condition reads; a class inside a module; an interface function (control) |
| MC v01-v04 | § methArgCastTsChainName246 | casts under `$unsigned` / `$signed` and in `push_back` arguments with an operation and a ternary; `this.` receivers; module scope with a class and a struct queue; a parameterized class `T'(v)` |
| MN v01-v04 | § macroParamMethNameEnd246 | token-pasted method names; a nested macro as the METHOD argument and an argument with a comment; method calls written literally in a body after a long argument; queue built-ins through METHOD |
| SB v01-v05 | § streamBraceInMacroBody246 | whole streams passed as macro arguments; bodies in an include file; `with [0 +: N]` streams and a macro in a macro; nested streams in module continuous assignments; one-line lvalue macros |
| CF v01-v02 | § colSpanWalkStampsFile246 | the pasted resize macro from an include file used in a second root file, including a dotted `h.q` receiver; dotted and `this.` receivers |
| PA v01-v06 | § callArgParamCopyOwnTs246 | an if-generate localparam; a two-level pass-down; `logic [3:0]` and `shortint` parameters; named and empty-slot calls; a package-typedef'd parameter with an imported default; a case-generate with a for-generate two levels down |
| LN v01-v05 | § contLvMidSelNetBase246 | for-generate `w.key[3 - i].d`; two levels of generate under if with instance depth 3; an output-port net with call, unary, `$clog2` and localparam indices and a part-select tail; an interface body net with an implicit net; a `tri` net with a two-level `w.a[1].b[0].c` |
| PE e01-e26 | § callArgCopyEvalCtxAbstain246v | above |
| X v01-v06 | context | a pure virtual prototype, an extern method defined below the caller, named and empty-slot calls, `this.` paths, a class specialisation in a bound, an implicit net and a DPI cast (v01, v03); a net mid-select beside an interface port, a localparam call actual and an implicit net (v02); hierarchical static reads in `this.`, named and default-argument calls (v04); a method-argument cast with a specialisation-bound property (v05); foreach constant slots (indexed width, replication, part-select bounds; v06) |

Results:

* `R11U246_OFF` gives pristine's bytes on **160 of 160** case-views.
* `R11V246_OFF` and `R11V246_PAEVALCTX_OFF` each give the law's bytes on **160 of 160**.
* **Against pristine, the fix enters STRICT_EQUAL on 48 case-views and leaves it on none.** The law alone entered 48 and left 12 (the PE rows above).
* No uhdm-cmp count rises.
* The only non-zero exits are LN/v04_ifcbody, which exits 4 on every binary, pristine included.
* Chain-keyed away census against pristine ([grid/away_fresh_law.txt](evidence/grid/away_fresh_law.txt), [grid/away_fresh_fix.txt](evidence/grid/away_fresh_fix.txt)):
  * law: 25 case-views lose 1 record each, toward 642;
  * fix: **0 lost on all 160**, toward 635.

On the implementer's 93 cases, the fix gives the law's bytes on all 186 case-views
([grid/vgrid_impl_summary.md](evidence/grid/vgrid_impl_summary.md)).

**Downstream on the fresh cases** (the harness's own `one`; [downstream/](evidence/downstream/)): pristine, law and fix
give the same verdict on all 80 cases: 71 IDENTICAL, 4 EQUIVALENT and 5 DIVERGENT. The DIVERGENT cases (PA v01, v06;
PE e20, e21, e22) are generate-scope and structural localparam shapes that diverge on pristine too.

Results by law:

* **Other laws:** no other law moved a record away on any fresh case-view, and the eight other switches each revert
  only their own cases (the law grid, [grid/law_grid_first50.txt](evidence/grid/law_grid_first50.txt)).
* **§ dpiTopCastResolvesByModImport246:** the decode is confirmed on the five new resolving shapes (DT v01, v05, v06
  and X/v03 elaborated view enter STRICT_EQUAL). The two controls (interface only, another item imported) are
  byte-identical.
* **§ macroParamMethNameEnd246:** a reading of the code. `SourceManager::getSourceText` returns an empty view for a
  macro-expansion buffer, so the law's early return "the start's text spells the name" never fires. The law therefore
  applies to every macro-located method call whose end is not already start + name length. The token-pasted, literal
  and built-in method cases (MN v01, v03, v04) stay byte-identical, so no shape found here is wrong. The comment's
  description is stronger than the code.

## Residues (ranked; ground A unless named)

1. The **reduce model of § callArgCopyEvalCtxAbstain246v** is a syntax scan, not Surelog's `reduceExpr`. Golden leaves
   `L[1] ^ L[2]` (PE e20), an indexed part-select width `[0 +: L[1]]` (e15) and a part-select bound `[L[1]:0]` (e16)
   unreduced, but the fix abstains on them, which keeps pristine's bytes and gives up one toward record each. A
   reference through a hierarchical path (`u.L[1]`) or a nested module is not scanned. The structural shapes golden
   folds (e01, e18, e19, e22, e12) are stage 1 on all binaries: golden folds the select, and ours does not.
2. All of the implementer's residues stand as reported:
   * BlackBePipeInt #38807 / #38803 (ParamEmit `stampParenCastWidthTs`, § parenCastWidthRefPkgBare207);
   * SB b04's one-line-macro rvalue streams;
   * MC m04's elaborated `key`;
   * LN n03 / n04 and PA p07 / p11 / p12;
   * brief items (5) to (7).
3. Fresh stage-1 shapes, wrong on pristine too, with no law moving a record away:
   * a typedef'd dynamic-array local and 2-D foreach locals (FE v01, v02);
   * static locals in a package function (FE v04, v06);
   * a child-module-only import with an implicit net (DT v02);
   * an included-file module (DT v04);
   * a class-method DPI path (DT v09);
   * an interface-body net (LN v04, exit 4 on every binary);
   * generate-scope nets two levels down (LN v02);
   * output-port struct nets (LN v03).
   * DT v07 (two packages) reads `line` on all binaries: the enum_typespec location of the second package, ParamEmit's
     package listing.
4. Sister-ground faces, as decoded by the implementer and seen again here:
   * SimpleUVM / Scoreboard #159457 / #159469 / #159637 (the `uvm_queue` T typespec location, TypeEmit's class body
     writers);
   * Rggen #26477 (ModuleEmit's interface port view);
   * BuildUVMPkg #91593 / #129711 / #185844 (TaskFuncEmit);
   * MiniAmiq / SeqDriver #76762 / #76718 (UhdmExporter pkgCloneHierBind9 / § cloneStmtHomeVarRef17).

## Clean rebuild

The delivered patch (`/tmp/r11u246.verified.patch`) was applied to a third fresh worktree at `08d31c79` (`git apply`
rc 0, `law_index.py --check` current) and built from scratch with the same config. The result is md5
`d96f6017a0355dd2e29967ba8ade040f`, equal to the fix binary every measurement above used.

## Process

* Every corpus path list (cmds.txt audits, byteverify mirrors, downstream lane lists) was built first and filtered by
  `$FENCED` (word boundary) before any file was opened.
* No fenced source, database, golden or head was read, and nothing was run on a fenced test outside the gate sweeps.
* The census ran with the `--filter` built from `$FENCED`.
* No process of another agent was listed or signalled.
* **One unguarded tool call (my error).** The first attempt to quote the heads ran `uhdm-strictcmp` through a shell
  function under `xargs bash -c`. The comparator's variable was checked with `[ -x ]` in the outer shell but not
  exported, so inside the function it was empty. `timeout` then executed the cached golden database of a target row
  (SimpleUVM, Scoreboard, Rggen, BuildUVMPkg, MiniAmiq or SeqDriver; no fenced row) as a shell script, from the main
  checkout's root.
  * It left one empty file with a binary name there (2026-10-05 08:54:08, one second after the command's own output
    file).
  * I deleted it by its exact timestamp and size; the main checkout's `git status` is clean.
  * Nothing else was written, and the heads were then taken with the comparator path inline.
  * Every other tool reached through a variable was checked with `[ -x ]` in the shell that ran it.
* Scratch decode cases lived in `/tmp/v11u246_x` and were copied into `cases/PE` with their law line.
* Four fresh cases first failed on my own illegal SV and were fixed before any grid ran:
  * an enum literal not imported by an item import (DT v01);
  * an `import ...;;` in an interface header (LN v04);
  * an enum-to-bit-vector cast mismatch (MC v01);
  * a function named `use` (HS v04).
* No patch file is kept in this directory.

## Drivers (`drivers/`; every one reads `$FENCED` fail-closed)

Copied from r11u246repro (paths renamed): `env.sh`, `case.sh`, `grid.sh`, `gridp.sh`, `gridsum.py`, `awayrows.py`,
`awaycases.py` (plus `ON_TAG` / `OFF_TAG` to compare any two case.sh tags), `strictcmp_x.cpp` + `cc_x.sh`, `census.sh`,
`predict.py`, `dscensus.py`, `dscases.py`, `det.sh`, `bvmirror.sh`.

New: `vgrid.sh` (pristine / law / fix / fix with `R11V246_OFF` / fix with `R11V246_PAEVALCTX_OFF` / fix with
`R11U246_OFF`, both views) and `vgridsum.py`.
