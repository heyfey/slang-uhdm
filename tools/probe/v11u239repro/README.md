# v11u239 — adversarial verification of r11u239 (pass 239, the module/type ground)

Base 40f5caf7. Verdict: **r11u239's numbers reproduce bit for bit, and its three laws hold on the generate-scope
faces. § modportArgVarFormalTs239 broke on legal SV in two fresh shapes; both are fixed here behind two refinements,
§ modportArgOwnBodyFn239v and § ndaBeforeAssign239v (src/R239.h `r11v239Law`, switches `R11V239_HOMEBODY_OFF`,
`R11V239_NDAFIRST_OFF`; `R11V239_OFF` drops both and gives r11u239's bytes, `R11U239_OFF` drops everything and gives
the base's bytes).** The refinements write r11u239's bytes on every gate database, on all 76 r11u239 cases and on the
Rggen row. Delivery: `/tmp/r11u239.verified.patch` = r11u239's patch + the refinements + this directory + the
regenerated tests/LAWS.md.

## Binaries (built here, frozen read-only before any measurement; [evidence/binaries_md5.txt](evidence/binaries_md5.txt))

| binary | md5 | |
|---|---|---|
| pristine (fresh worktree at 40f5caf7, system-deps config) | 273961bd0118143bb6c037c332f9ff30 | equals the main tree's build/slang-uhdm |
| law (40f5caf7 + /tmp/r11u239.patch, md5 59792a23...) | 8978a39fd0ca596fc89560824720d8a4 | equals the implementer's law binary; reports slang 12.0.0+545f88b2e |
| fix (law + the two refinements) | 777f1171aa526d25ece5b9adad7d3d2b | |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | |

The patch applies clean on a fresh 40f5caf7. Its surface is src/ModuleEmit.cpp, src/UhdmExporter.cpp, src/R239.h,
tests/LAWS.md and tools/probe/r11u239repro, with no patch file. Every cmds.txt of the sweeps names its frozen binary.

## Reproduction (every headline number of r11u239)

* **Pristine sweep** (tests/sweep.sh --jobs 3, run from the pristine worktree): probe EQUAL 3463 + STRICT_NOTEQUAL 624;
  surelog default 469 + 11, testflags 465 + 9; uhdm2rtlil 803 + 0 per mode; downstream 803 IDENTICAL / 66 SLANG_REJECT
  / 2 EQUIVALENT / 0 DIVERGENT. Every stage reads regressions=0 conversions=0 changes=0. The sweep exits 1 only
  because `law index STALE`: the LAWS.md committed at 40f5caf7 cannot name its own commit hash, so the index at any
  landed head is stale for that head's laws (r11u239's regenerated LAWS.md adds `commits: 40f5caf7b` to the pass-237
  laws). This is not a regression.
* **Law sweep** (same harness, law binary): probe EQUAL 3467 + STRICT_NOTEQUAL 620, regressions=0 conversions=4
  changes=0, and the four CONVERSIONS are the implementer's. surelog regressions=0 conversions=0 changes=3:
  `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)`, the same for testflags, and
  `Rggen,default,STRICT_NOTEQUAL,differ:line(202),,differ:line(202)`. uhdm2rtlil 0/0/0. downstream 803/66/2/0, and the
  verdict diff against the pristine sweep is 0 lines. Outside those rows the surelog csvs differ only in the LowMem
  detail text (the workdir path).
* **First records** (uhdm-strictcmp against the cached golden):
  * Earlgrey default goes #121994 fullname (`...i_core.host_req_i.bank`, ours
    `...host_req_i.host_rsp_avail.bank`) -> #122230 col (flash_phy_pkg.sv 43:53 vs ours 43:28). #123586 (`N` with no
    full name) and #123996 (`alloc_i.alloc.i`) are cleared, so 5 objects -> 2.
  * Earlgrey testflags goes #123468 -> #123704, with the same faces.
  * Rggen default goes #23164 file (golden `logic_typespec` at rggen_adapter_common.sv 43:5, ours rggen_bus_if.sv 9:3;
    objects 314498 vs 312769, walk diverged) -> #23546 line (`int_typespec` rggen_or_reducer.sv 3:13 vs ours 8:55;
    objects 314498 vs 314389).
* **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) ran per stage on symlink trees built by
  [drivers/mktree.sh](drivers/mktree.sh). It builds the path list and filters it by $FENCED before any database is
  opened. Results ([evidence/sweep/byteverify_law_vs_pristine.txt](evidence/sweep/byteverify_law_vs_pristine.txt)):
  * probe: 4 of 4087 move;
  * surelog: 3 of 952 (Earlgrey_0_1 d/t 535cffbc1d16 / 8ff4d1cc41ba, Rggen d aa90e136172e);
  * uhdm2rtlil: 0 of 1608;
  * downstream: 0 of 805.

  These are exactly the implementer's 7 predicted movers. Every stage's negative control flags n-1 of n. Run over one
  merged tree, the selfcheck flags 7450 of 7452, because the downstream and uhdm2rtlil/testflags databases of
  1DUnpackedArray are byte-identical copies; that is not a comparator fault.
* **Away census over the sweeps** (r11u239repro/drivers/awayall.py): 7 databases, chain_lost 0, chain_toward 5147
  (Rggen 5117, Earlgrey 6 + 6, probe 6/4/4/4), flat_lost 0
  ([evidence/sweep/away_law_vs_pristine.txt](evidence/sweep/away_law_vs_pristine.txt)).
* **Canaries:**
  * canaries.sh on the law surelog csv: ok 50, changed 2 (Earlgrey_0_1 d/t), unknown 7 (the u2r-only names).
  * canaries.sh on the u2r csv: ok 16, changed 0.
  * ctcan2.sh (EXPECT_UNKNOWN=1) on surelog: ok 58, PASS.
  * ctcan2.sh (EXPECT_UNKNOWN=6) on u2r: ok 2, PASS.
* **r11u239's grid** was rerun with these binaries: 76 cases, both views, 9 configurations, 1368 lines, every one
  rc=0 ([evidence/grid/r11u239_grid_rerun.txt](evidence/grid/r11u239_grid_rerun.txt)).
  * Pristine -> law: 88 STRICT_NOTEQUAL -> STRICT_EQUAL, 50 identical, 14 bytes moved with the same verdict
    (10 stage 1, 4 STRICT_NOTEQUAL), none leaving equality.
  * `R11U239_OFF`: pristine bytes on 152 of 152.
  * Each switch alone: OPSELIDX off leaves 78 conversions and moves only OS cases (14 case-views), GENLPSYSARG off
    leaves 72 (GL, 22), MPARGTS off leaves 26 (MA, 66).
  * The fix binary writes the law's bytes on all 152.
* **Downstream on the cases** (r11u239repro/drivers/dscase.py, the 76 r11u239 and 43 v11u239 cases;
  [evidence/downstream](evidence/downstream)): the only verdict movers are r11u239's MA d07 EQUIVALENT -> IDENTICAL,
  MA e13 and e14 IDENTICAL -> EQUIVALENT, and v11u239 MA m24 EQUIVALENT -> IDENTICAL. law and fix agree on every case.
  * e13 differs only in RTLIL module order (`top` before or after `adapter`); the sorted files are equal.
  * Run under uhdm2rtlil's own Surelog with the downstream flags, the law's database is STRICT_EQUAL to the Surelog
    lane on e13 (301 objects), e14 (301) and d07 (287). Pristine is STRICT_NOTEQUAL line on all three.
  * So the coin is object order in the plugin, not a field. This confirms r11u239's reading.
* **Determinism** (r11u239repro/drivers/det.sh, three concurrent harness runs of the fix binary): one hash per
  row-mode on Earlgrey_0_1 and the five UVM rows. Scoreboard testflags writes no database, as on pristine. The
  Earlgrey hashes equal the law sweep's, and the UVM hashes equal pristine's ([evidence/det/det.txt](evidence/det/det.txt)).

## The breaks (fresh cases, legal SV) and the refinements

1. **§ modportArgOwnBodyFn239v** (`R11V239_HOMEBODY_OFF`, UhdmExporter, the § modportArgVarFormalTs239 walk). The law
   accepted any function whose home is an instance body, then looked the function up by NAME among the caller
   module's own task_funcs. A call into another body therefore borrowed the caller's same-named function's formal:
   * `bif.chk(bif.address)` through `modport slave (..., import chk)`, beside a module function `chk` (case MA m26);
   * the hierarchical call `c.chk(bif.address)` into a child instance (case MA m31).

   On m31, pristine is STRICT_EQUAL and the law fails **uhdm-cmp** (stage 1, 36 lines) in both views. On m26, pristine
   is judge-equal and the law fails stage 1 (36 lines). Golden leaves the member's typespec alone in both. The
   refinement binds only when the function's home is the caller's own body. Result: m31 regains pristine's bytes
   (STRICT_EQUAL); m26 goes to STRICT_EQUAL, keeping the law's correct stamp of `valid_chk(bif.valid)`.
2. **§ ndaBeforeAssign239v** (`R11V239_NDAFIRST_OFF`). The law walked a scope's net-declaration assignments and its
   assign statements in one source-order pass ("last call wins"). In Surelog's netlist, a scope's net-declaration
   assignments come before its assign statements, whatever the source order, so an assign statement's call wins over
   a later `wire w = f(...)`:
   * m06: assign pa, then wire pb: golden pa, law pb;
   * m21: wire pb, assign pa, wire pc: golden pa, law pc;
   * m22: the same inside a generate block: golden pa;
   * m25: two members, both kinds: golden pa;
   * m07 and m23 (one kind, or the net declaration first) were already right.

   The law's result was wrong-to-wrong (0 records lost), but the stated order rule was wrong. With the refinement,
   m06, m21 and m25 convert in both views and m22's elaborated view converts. m22's default view moves its typespec
   record to golden and then diverges structurally at #317: golden has a `cont_assign` where ours has the
   generate-scope `logic_net w`, already so at the base.

## Fresh cases (tools/probe/v11u239repro/cases, 43; every first line names its law)

Each cell gives the default and elaborated views as pristine -> law -> fix (EQ = STRICT_EQUAL, SNE = STRICT_NOTEQUAL
with its first field, s1 = uhdm-cmp stage 1 with its line count). Every grid line carries rc=0
([evidence/grid/grid.txt](evidence/grid/grid.txt): 86 case-views x 7 configurations, 602 lines).

| case | law | face | default | elab |
|---|---|---|---|---|
| OS/s01 | § genConnOpSelIdxScope239 | `v[ i ]` with spaces | s1(28) unchanged | s1(28) unchanged |
| OS/s02 | § genConnOpSelIdxScope239 | generate-local localparam index, unnamed block | s1(50), bytes move | same |
| OS/s03 | § genConnOpSelIdxScope239 | 2-D select `m[i][0]` | SNE:fullname unchanged (var_select naming) | EQ unchanged |
| OS/s04 | § genConnOpSelIdxScope239 | `{r, v[i]} & v[i*2 +: 2]` | SNE:col unchanged | same |
| OS/s05 | § genConnOpSelIdxScope239 | net index and enum-constant index in an if-generate | SNE -> EQ | SNE -> EQ |
| OS/s06 | § genConnOpSelIdxScope239 | nested for, struct-array member | EQ unchanged | EQ unchanged |
| OS/s07 | § genConnOpSelIdxScope239 | positional, index named like the formal | s1(121) unchanged | same |
| OS/s08 | § genConnOpSelIdxScope239 | wildcard-imported package parameter index, ternary | s1(120), bytes move | same |
| OS/s09 | § genConnOpSelIdxScope239 | non-top module, two instances, port index | SNE -> EQ | SNE -> EQ |
| GL/s01 | § genLpSysCallArgName239 | for-generate, `$clog2` of local localparam and module parameter | SNE -> EQ | SNE -> EQ |
| GL/s02 | § genLpSysCallArgName239 | unnamed if-generate, `$bits` of local typedef, `$size` of local array | s1(64), bytes move | same |
| GL/s03 | § genLpSysCallArgName239 | `parameter` in a generate, `$high`, `$clog2` of enum constant | s1(58), bytes move | same |
| GL/s04 | § genLpSysCallArgName239 | two instances with different N | SNE -> EQ | SNE -> EQ |
| GL/s05 | § genLpSysCallArgName239 | generate localparam in an interface and in the module | SNE -> EQ | SNE -> EQ |
| MA/m01 | § modportArgVarFormalTs239 | named arguments out of formal order | SNE -> EQ | SNE -> EQ |
| MA/m02 | § modportArgVarFormalTs239 | part-select target, operation right side | SNE -> EQ | SNE -> EQ |
| MA/m03 | § modportArgVarFormalTs239 | concatenation target | SNE -> EQ | SNE -> EQ |
| MA/m04 | § modportArgVarFormalTs239 | two modules, one interface instance, one modport | SNE -> EQ | SNE -> EQ |
| MA/m05 | § modportArgVarFormalTs239 | the same through two modports | SNE -> EQ | SNE -> EQ |
| MA/m06 | § ndaBeforeAssign239v | assign pa, then wire pb | SNE -> SNE -> EQ | SNE -> SNE -> EQ |
| MA/m07 | § modportArgVarFormalTs239 | wire pb, then assign pa | SNE -> EQ | SNE -> EQ |
| MA/m08 | § modportArgVarFormalTs239 | call inside `$unsigned(...)` | SNE unchanged (residue) | same |
| MA/m09 | § modportArgVarFormalTs239 | call in a child port connection | s1(1574) unchanged | s1(1614) unchanged |
| MA/m10 | § modportArgVarFormalTs239 | `bif . address` with spaces | SNE unchanged (residue) | same |
| MA/m11 | § modportArgVarFormalTs239 | generate loop, per-instance formal width | SNE -> EQ | SNE -> EQ |
| MA/m12 | § modportArgVarFormalTs239 | defaulted second formal | SNE -> EQ | SNE -> EQ |
| MA/m13 | § modportArgVarFormalTs239 | `pre(bif.address) \| pre(x)`, a plain net inside a call argument | SNE unchanged (residue) | same |
| MA/m14 | § modportArgVarFormalTs239 | if-generate | SNE -> EQ | SNE -> EQ |
| MA/m15 | § modportArgVarFormalTs239 | wildcard-imported and qualified package functions, member select | SNE -> EQ | SNE -> EQ |
| MA/m16 | § modportArgVarFormalTs239 | interface array elements | SNE -> EQ | SNE -> EQ |
| MA/m17 | § modportArgVarFormalTs239 | nested user calls | s1(17), bytes move | same |
| MA/m18 | § modportArgVarFormalTs239 | assign with a delay | SNE -> EQ | SNE -> EQ |
| MA/m21 | § ndaBeforeAssign239v | wire pb, assign pa, wire pc | SNE -> SNE -> EQ | SNE -> SNE -> EQ |
| MA/m22 | § ndaBeforeAssign239v | the same order inside a generate block | SNE:line -> SNE:line -> SNE:depth (later, structural) | SNE -> SNE -> EQ |
| MA/m23 | § modportArgVarFormalTs239 | two net-declaration assignments | SNE -> EQ | SNE -> EQ |
| MA/m24 | § modportArgVarFormalTs239 | parent and child through a passed-down port | SNE -> EQ | SNE -> EQ |
| MA/m25 | § ndaBeforeAssign239v | two members, both kinds | SNE -> SNE -> EQ | SNE -> SNE -> EQ |
| MA/m26 | § modportArgOwnBodyFn239v | modport-imported interface function beside a same-named module function | SNE -> **s1(36)** -> EQ | SNE -> **s1(36)** -> EQ |
| MA/m27 | § modportArgVarFormalTs239 | wire of a package struct type, typedef formals | s1(60), bytes move | same |
| MA/m28 | § modportArgVarFormalTs239 | modport-output target, genvar-indexed member select | SNE:fullname unchanged | same |
| MA/m29 | § modportArgVarFormalTs239 | two parameterized instances on one interface | SNE -> EQ | SNE -> EQ |
| MA/m30 | § modportArgVarFormalTs239 | call written through a macro, int typedef formal | s1(17), bytes move | same |
| MA/m31 | § modportArgOwnBodyFn239v | hierarchical call into a child's function beside a same-named module function | **EQ -> s1(36) -> EQ** | **EQ -> s1(36) -> EQ** |

Grid summary ([evidence/grid/summary.txt](evidence/grid/summary.txt)):

| comparison | entering EQ | other changes | same bytes |
|---|---|---|---|
| pristine -> law | 40 | 4 leave judge-equality (m26, m31 in both views); 14 stage-1 and 10 STRICT_NOTEQUAL case-views move bytes with the same verdict | 18 |
| pristine -> fix | 49 | none leave equality; 14 stage-1 and 3 STRICT_NOTEQUAL move bytes | 20 |
| law -> fix | 11 (m06, m21, m22 elab, m25, m26, m31) | 1 SNE moves (m22 default) | 74 |

* `R11U239_OFF` on the fix binary gives pristine bytes on 86 of 86.
* `R11V239_OFF` gives the law's bytes on 86 of 86.
* `R11V239_NDAFIRST_OFF` moves only m06, m21, m22 and m25; `R11V239_HOMEBODY_OFF` moves only m26 and m31.
* Away census (r11u239repro/drivers/awaycase.py, chain-keyed): pristine -> fix 0 lost, 326 toward; law -> fix 0
  lost, 56 toward.
* Downstream: every fresh case keeps its pristine verdict under law and fix, except m24 EQUIVALENT -> IDENTICAL.

## Gates on the fix binary

The mover prediction was frozen before the fix sweep
([evidence/prediction_fix_vs_law.txt](evidence/prediction_fix_vs_law.txt), md5 7ff7106a5758c4b4e7bc8671b9c0d3d8).
The refinements act only inside the hit list of § modportArgVarFormalTs239, whose firing set on the gate is Rggen
default and the four probe cases. Rggen was measured directly with a filtered, traced harness run: same database
aa90e136, same 1318 firings, 0 firings of the own-body check. The four probe cases each have one assign statement
calling a module-local function. Prediction: 0 databases differ from the law sweep.

**Fix sweep** (tests/sweep.sh --jobs 3 from this worktree, SLANG_UHDM = the fix binary; `law index current`, exit
code 0; [evidence/sweep/sweep_fix_summary.txt](evidence/sweep/sweep_fix_summary.txt)):

| stage | result |
|---|---|
| probe | EQUAL 3467 + STRICT_NOTEQUAL 620, regressions=0 conversions=4 changes=0 (the same four CONVERSIONS, e.g. `r10rgg8repro/cells/h_full STRICT_NOTEQUAL differ:line(3) -> EQUAL`) |
| surelog | default 469 + 11, testflags 465 + 9, regressions=0 conversions=0 changes=3 (`Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)`, the same for testflags, `Rggen,default,STRICT_NOTEQUAL,differ:line(202),,differ:line(202)`) |
| uhdm2rtlil | 803 + 0 per mode, regressions=0 conversions=0 changes=0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, "not identical and not excused=0" |

Every surelog, uhdm2rtlil and downstream csv row equals the law sweep's (apart from the LowMem detail text). byteverify
of fix against law ([evidence/sweep/byteverify_fix_vs_law.txt](evidence/sweep/byteverify_fix_vs_law.txt)) reads 0 of
952 surelog, 0 of 1608 uhdm2rtlil and 0 of 805 downstream databases moving. The probe databases embed the case's
absolute path, so the first fix probe stage, run from this worktree, differs from the law's (run from the pristine
worktree) on all 4087. The fix probe stage was therefore rerun from the pristine worktree: same verdicts, 0 of 4087
moving. **The prediction holds: the refinements move no gate database.** Against pristine, the fix binary moves
exactly r11u239's 7 databases, which the away census credits with 0 lost and 5147 toward. uhdm-cmp reads 0 lines on
the touched row-modes: all three stay in the judge-equal STRICT_NOTEQUAL status.

## Ground-A and other faces (reported, not written)

* r11u239's decode of the remaining heads is confirmed on the records:
  * Earlgrey #122230 / #123704 is the ternary package parameter located at its taken branch (ParamEmit).
  * Earlgrey #130430 / #131904 is `range` vs `ref_typespec` at hmac_pkg.sv 26:35 (structural).
  * Rggen #23546 is the argument constant's typespec in ParamEmit's evaluated-call stamping. Behind it are 45
    fullname records (the port-view `register_if.access` variables named after the child connection that reaches
    them) and the macro-argument column records.
* The UVM first records, BlackBePipeInt #24671 and FuncStructVal #7975 belong to the sister pass's ground. No law or
  refinement of this pass fires on those rows: their sweep databases are byte-identical to pristine.

## Residues, ranked

1. § modportArgVarFormalTs239 abstains where golden stamps:
   * a call under a system call (m08: golden stamps `pre`'s formal through `$unsigned(...)`);
   * a member written `bif . address` (m10);
   * an operation whose plain net read sits inside another call's argument (m13: golden stamps
     `pre(bif.address) | pre(x)`; the law's plain-read test descends into call arguments; r11u239's e06/e15 put the
     net as a direct operand);
   * a call in a child port connection (m09, stage 1 at the base);
   * an interface function reached through the modport, which golden also leaves alone (abstaining is right there).
2. § genConnOpSelIdxScope239 leaves an index with spaces inside the brackets (OS s01, stage 1 at the base) and the
   2-D `var_select` naming (OS s03 default: golden `...u_s.a_i.m`, ours `work@top.gen_b[0].m`). The concatenation
   operand span (OS s04: golden 8:25-26, ours 8:23-27) is another emitDefGenStmts face of the same site.
3. Rggen default's 202 objects, as r11u239 reports them.
4. Not attempted by r11u239: pass 237's (2a)-(2g), BuildUVMPkg's module/type clusters, pass 231's and pass 228's
   residues.
5. Known Surelog behaviour (carried): the `--elabuhdm` segfault on a `$unit` class specialization, and a Surelog
   segfault on a modport port named like its interface.

## Process

* Fresh worktrees /tmp/wt_v11u239pris (pristine) and /tmp/wt_v11u239 (law, then fix); scratch /tmp/v11u239_*.
* The pristine binary was frozen before the law build, and the law binary before any edit to src.
* One fix build raced an edit: UhdmExporter.o was newer than the second edit, so the first fix binary lacked
  § modportArgOwnBodyFn239v. `strings` caught it, the file was touched and rebuilt, and only the rebuilt binary
  (777f1171) is cited.
* Process slips, none on a fenced path:
  * One shell called `$UHDM_CMP` with the variable unset on a fresh case's golden database. The shell stopped at a
    syntax error on the database's first line; the directory was checked and no file was written.
  * Two evidence fence scans ran in a shell without $FENCED. Their empty pattern listed every file of this directory
    (my own outputs only); both were rerun with $FENCED set and found 0.
* Every corpus reader went through the harness (the sweeps, det.sh's fixed row list, verify_golden.py
  `--filter '^Rggen$'` for the traced prediction) or through a path list filtered by $FENCED before opening
  (mktree.sh, awayall.py's own fence check). No fenced source or database was read, run or printed.
* No other agent's process was listed or killed.
* r11u239's own process note records one `pgrep -f` on its own workdir name. The brief forbids a pattern that can
  match one's own shell; that one matched only its own shell.
* Drivers are r11u239repro's (env.sh, case.sh, grid.sh, awaycase.py, awayall.py, dscase.py, det.sh), run with
  `B=/tmp/v11u239_bin`, plus [drivers/mktree.sh](drivers/mktree.sh).
