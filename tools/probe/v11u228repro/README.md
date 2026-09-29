# v11u228: adversarial verification of r11u228 (pass 228, the module/type ground) — ACCEPTED WITH FIX: two breaks where pristine was right (a crash, and member bounds folded where golden keeps the path), fixed by three refinements (§ memberRootOwnInstance228v, § memberRootFoldShapes228v, § pvSizeNoElemDeclines228v)

**Base** `1a30095a` (branch matrix-1.87). The implementer's patch `/tmp/r11u228.patch` (md5 `6acb93b6f2ff7be65e77f088edf23dd5`)
applies clean on a fresh `1a30095a` worktree. The verified patch adds refinements to `src/TypeEmit.cpp`,
`uhdm_main.cpp` and `src/R228.h`, and adds this directory. It touches nothing in ExprEmit.cpp, EmitHelpers.h,
StmtEmit.cpp, ParamEmit.cpp, `results/`, `tests/probe/` or `third_party/`. `tests/LAWS.md` is regenerated. The four
slang-fenced tests are never named here. Every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed. A probe case is called a case.

## 0. Verdict

| claim of r11u228 | measured here | verdict |
|---|---|---|
| law binary `4c87f728d26c2fec1c7fadb9dcdaf314` rebuilt from the patch; pristine `cf79d4525ea4bfdf0d2a148f0929fce6` | both rebuilt byte for byte (`-j 2`, `SYSTEM_DEPS=ON`) | reproduced |
| gates: probe 0/0/0 (3453 + 634), surelog 0/0/0 (930 + 24), uhdm2rtlil 0/0/0 (1602 + 4), downstream 803/66/2/0 identical to pristine | the same on my law sweep `/tmp/v11u228_wL` against my pristine sweep `/tmp/v11u228_wP`; downstream csv identical | reproduced |
| byte movers 1 of 2560 (Scoreboard default, a storage-order coin), 0 of 4087 probe | the same: Scoreboard default (dump 92 raw lines, 0 order-blind); probe 0 of 4087 against a pristine probe run from the same tree | reproduced |
| canaries surelog ok=52, uhdm2rtlil ok=16, both ctcan2 checks pass | the same | reproduced |
| grid: 60 case-views move, 19 enter EQUAL, 0 leave EQUAL, **0 leave judge-equality**, `R11U228_OFF` gives pristine bytes, per switch 38 / 20 / 4 | 60 / 19 / 0 / 0 / all / 38 20 4 on the implementer's cases. **But its grid printed no exit codes: the law binary exits rc 139 on 4 of its own control cases** (section 1) | reproduced, incomplete |
| grid away census: chain 0 lost / 102 toward, reversed 102 lost, flat 45 lost (all explained) | 0 / 102, reversed 102, flat 45 | reproduced |
| downstream: "20 cases DIVERGENT -> IDENTICAL, none leaving IDENTICAL" | **18** (the README's own list: MR m14, PS p01-p07 p11 p12, v11u223 S s01-s06, v11u219 S s08 s01c, which is 18 cases, not 20); none leaving IDENTICAL | number corrected |
| every targeted row's first record is on the sister's ground | FuncStructVal d/t `endcol(7)`/`endcol(10)`, BlackBePipeInt d/t `type(1)`, struct_param_func_config d/t `fullname(5)` (#759 `work@...u_c.Cfg.p::cfg_t.u` against golden's `work@struct_param_func_config.p::cfg_t.u`), cfg_func_width_loop d/t `line(3)` (#464 `mask_t` 16:11 against golden's 27:40); the same cells at the base and after | reproduced |

**Breaks on legal SV where pristine was right (fixed here):**

1. **Crash.** `§ parseViewSizeExprEval228` ran UHDM ExprEval on `$size` of a fixed-then-dynamic or fixed-then-queue array
   in the parse view. `ExprEval::size` reads `array_var->Variables()->at(0)` unguarded and segfaulted. This happened on
   v11u219 S `s01_dyn_inner` and `s01b_queue_inner`, v11u223 S `s09_genfor_dyn` and `s10_dyn_queue_decline`, and fresh
   FS `s10` and `s12`: **rc 0 -> rc 139**. The backtrace is `UHDM::ExprEval::size` <- `reduceExpr` <- `realMain`.
   Surelog writes no database on these cases, so the implementer's grid reads SURELOG_FAIL on both binaries. Its line
   format dropped `rc=`, so the crash never showed.
2. **Member bounds folded where golden keeps `Info.x`.** `§ memberInitReducedRootFolds228` folds every root that is
   not a cast or a typed pattern. Golden keeps the path for:
   * a conditional of casts: FM f03 goes **judge-equal (`STRICT_NOTEQUAL decompile`) -> stage 1**, and so do FR c2, c3 and c7;
   * a replicated pattern `'{2{7}}` (f06);
   * a bare int parameter `Info = W` (f08, d06);
   * `info_t'(5) + 0` (c5), `+16` (d04), `{2{16'd5}}` (d16) and `SEL ? W : 9` (d17).

   Every one moved 7 records away in the parse view and 13 to 16 in the elaborated view.
3. **First-instance root.** The root was read in `currentScope`, which is the FIRST instance's body for every instance
   of one definition. In f12 (child default `'{x: 4}`, u1 `'{x: 5}`, then u2 `info_t'(6)`) the law folded u2, whose
   golden keeps the path: 7 records away. In the reverse order (f14) it folded neither, although golden folds u1.

The fixed binary moves **0 records away** from golden against pristine and 0 against r11u228's binary, on all 434 grid
case-views, chain-keyed (sections 3 and 4). No corpus row-mode or probe case converts.

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u228_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pristine` | `cf79d4525ea4bfdf0d2a148f0929fce6` | `/tmp/wt_v11u228pris` at `1a30095a` |
| `law` | `4c87f728d26c2fec1c7fadb9dcdaf314` | `1a30095a` + `/tmp/r11u228.patch`, the implementer's md5 |
| `fix1` | `ead81c6be747d00a3ecd69841705ce5a` | draft: the two TypeEmit refinements, first form (grid only) |
| `fix2` | `735533fcfae349be369c7f6c33a3d35e` | + the crash guard, the own-instance rule limited to one definition, the conditional's selected branch, signing and size casts |
| **`fix3`** | **`20cb9d02c69c01afc31d06ccba5ef55a`** | **the final binary: fix2 plus the predictor trace of § pvSizeNoElemDeclines228v (bytes identical to fix2 on all 432 grid case-views); `/tmp/r11u228.verified.patch` applied to a fresh `1a30095a` worktree rebuilds it byte for byte** |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | built from the base, the main tree's md5 |

Sweeps (`tests/sweep.sh --jobs 3`, 15-character workdirs): pristine `/tmp/v11u228_wP`, law `/tmp/v11u228_wL`, fix
`/tmp/v11u228_wX`. The pristine probe stage was rerun from the law worktree into `/tmp/v11u228_wQ`, so that the probe
databases carry the same source paths. Every corpus `cmds.txt` names its own binary: 3273 of 3273 `slang:` lines per
sweep, and 3265 on the census (fenced rows filtered out).

## 2. The refinements (switches; `R11V228_OFF` drops all three and gives r11u228's bytes on all 434 grid case-views)

### § memberRootOwnInstance228v (switch `R11V228_ROOTINST_OFF`, TypeEmit `makeTypespec` `resolveMemberInit`)

The member parameter found by binding the bound in `currentScope` belongs to the first instance of the definition. A
debug print showed this on f12: `decl=top.u2.q p=top.u1.N bp9=top.u1.Info scope=top.u1`. When the signal's own instance
body is another instance of the SAME definition, the root is the parameter of the same name declared directly in that
body. A root that cannot be mapped keeps the base's substitution. A root in another definition, such as an override
chain into the parent (FO g15, g17, OS o21: `sub #(.Depth(N))` where N reads the parent's `Info`), is read as r11u228
reads it; fix1 had declined those and lost 2 to 4 toward-records, so fix2 limits the rule to one definition. Cases: FM
f12 (7 records back toward golden in the parse view, 13 in the elaborated view) and f14 (1 toward).

### § memberRootFoldShapes228v (switch `R11V228_ROOTSHAPE_OFF`, the same site)

The decode is 25 golden shapes in [evidence/decode/golden_root_shapes.txt](evidence/decode/golden_root_shapes.txt),
counting `hier_path (Info.x)` records in golden's dump: 3 means folded, 10 means kept. Golden folds the member for:
* an untyped assignment pattern that is not replicated: named, positional, default, or with expression members (`'{x: W}`, `'{int'(16)}`);
* an integer or vector literal;
* a single concatenation;
* an arithmetic of literals and names (`16 + 0`, `W + 1`);
* a signing or size cast (`unsigned'(16)`, `16'(5)`);
* any of these in parentheses.

It keeps the path for:
* a struct cast or a typed pattern;
* a replicated pattern;
* a replicated concatenation;
* a unary operator;
* an arithmetic holding a cast;
* a bare non-struct parameter;
* a conditional whose selected branch keeps.

A conditional with a constant condition is read on the branch it selects (slang's `ConditionalExpression::knownSide`):
`SEL ? '{x: 5} : info_t'(9)` folds, while `!SEL ? ...` and `SEL ? info_t'(5) : '{x: 9}` keep. The chain from the root
follows struct parameters only. The law now folds only on those shapes; any other shape keeps the base's substitution.
The rule agrees with golden on all 25 decode shapes (d20 and d21 are rejected by slang, so they are not cases). Cases:
FM f03 f06 f08 f13, FR c1-c10 d01-d19.

### § pvSizeNoElemDeclines228v (switch `R11V228_PVSIZEDYN_OFF`, `uhdm_main.cpp`, inside § parseViewSizeExprEval228)

For the parse-view ExprEval runs only, every `array_var` without an element holds a placeholder: a `chandle_var` typed
by a `chandle_typespec`, which `ExprEval::size` does not size, so it sets invalidValue and the call stays. This mirrors
§ unsizedInnerSizeDeclines223 with § sizeDeclineTsInvalid223v in the adjuster's run. The placeholders live outside the
serializer and are removed right after. Traced as `pvSizeNoElemDeclines228v <net> placeholders=<n>` for every call
evaluated while one is attached. On the six crash case-views (4 control cases, fresh FS s10 and s12, parse view), the exit code goes back to 0. Three of
the four control databases (v11u219 S s01_dyn_inner, s01b_queue_inner, v11u223 S s10_dyn_queue_decline) are uhdm-cmp
identical to pristine's (0 lines), strict-equal, and dump-identical. Their bytes still differ from pristine's (file sizes
4810 -> 4806, 4464 -> 4522, 11547 -> 11662), because ExprEval's evaluation allocates in the serializer. In the fourth,
v11u223 S s09_genfor_dyn, the generate-for block's `$size(bp)` of `bit [3:0][1:0]` folds to `UINT:2`, size 3, as the law
intends; the same shape reads EQUAL against golden in v11u223 S s04 and r11u228 PS p04. Surelog writes no database on
any of these files, so golden cannot confirm it. FS s10 and s12 fold their fixed-shape calls the same way (`w1` 12,
`w2` 4).

## 3. Grid ([evidence/grid/](evidence/grid/), drivers/gridv.sh, drivers/gridsum.py)

The grid covers 217 cases, 434 case-views in both views:
* every r11u228 grid case: MR, PS, v11u225 FO, r11u225 OS, v11u223 S, v11u219 S, r11u219 S, r11u216 NQ GQ TW;
* 45 fresh cases: FM f01-f14, FS s01-s12, FB b01-b04, FR (23).

Each case-view ran under pristine (P), r11u228's binary (L), fix (X), X with `R11U228_OFF` (XO), X with `R11V228_OFF`
(XV), and X with each refinement switch dropped alone (I, S).

| measure | L (r11u228) | X (fixed) |
|---|---|---|
| case-views moved from pristine | 136 | 116 |
| entering STRICT_EQUAL | 32 | 32 |
| leaving EQUAL | 0 | 0 |
| **leaving judge-equality** | **4** (FM f03, FR c2 c3 c7 parse view) | **0** |
| **exit code not 0 where pristine's is 0** | **12** (6 crash case-views; each crashes under L and XV) | **0** |
| away census against pristine, chain-keyed lost / toward | 263 / 164 | **0 / 168** (reversed control 168 lost) |

* `XO` equals P on 434 of 434 case-views, and `XV` equals L on 434 of 434.
* X differs from L on 30 case-views: `R11V228_ROOTINST_OFF` alone moves 4 of them (f12 and f14, both views) and
  `R11V228_ROOTSHAPE_OFF` alone moves 26.
* Against L, X moves 0 records away and 267 toward, chain-keyed; the reversed control reads 267 lost.
* Flat-lost records: 10 against L and 106 against pristine. drivers/flatexplain.py explains every one: 0 unexplained.
  Each is a record removed from under the `Info.x` path, at a chain golden does not hold it at.

The 32 case-views entering EQUAL under X:
* r11u228's 19: PS p01-p08 p10 p11 parse view and p03 elaborated; v11u223 S s01-s05 parse view and s06 in both views;
  v11u219 S s08 parse view.
* 13 fresh: FB b01-b03 in both views and b04 parse view; FS s02 s03 s05 s08 parse view; FR d08 in both views. FB b04's
  elaborated view goes from stage 1 to STRICT_NOTEQUAL `type`.

The implementer's own cases reproduce its numbers under L: 60 moved, 19 entering, 38 / 20 / 4 per switch, `R11U228_OFF`
= pristine.

## 4. Downstream on the grid ([evidence/downstream/](evidence/downstream/), drivers/dscases.py, fresh `GOLDEN_CACHE`)

The run covers 109 cases: r11u228's 57 and the fresh ones.

| binary | IDENTICAL | EQUIVALENT | DIVERGENT | SLANG_REJECT | SURELOG_FAIL | STATUS_DIFF |
|---|---|---|---|---|---|---|
| pristine | 52 | 14 | 35 | 2 | 5 | 1 |
| law | 78 | 14 | 9 | 2 | 5 | 1 |
| fix3 | 78 | 15 | 8 | 2 | 5 | 1 |

* **26 DIVERGENT -> IDENTICAL**: r11u228's 18, plus FB b01-b04 and FS s02 s03 s05 s08.
* FR d13 (`16'(5)`) goes DIVERGENT -> EQUIVALENT under fix3 only.
* **None leaves IDENTICAL.**

## 5. Gates of the fixed binary (fix3, `/tmp/v11u228_wX`)

| gate | pristine `/tmp/v11u228_wP` | r11u228 law `/tmp/v11u228_wL` | **fix3 `/tmp/v11u228_wX`** |
|---|---|---|---|
| (2) probe vs results/golden_probe.csv | 0 / 0 / 0; EQUAL 3453, STRICT_NOTEQUAL 634 | 0 / 0 / 0; 3453 + 634 | **regressions=0 conversions=0 changes=0; 3453 + 634** |
| (3) surelog vs results/golden_surelog.csv | 0 / 0 / 0 | 0 / 0 / 0 | **0 / 0 / 0** (default CMP_EQUAL 467 + STRICT_NOTEQUAL 13, testflags 463 + 11) |
| (3) uhdm2rtlil vs results/golden_uhdm2rtlil.csv | 0 / 0 / 0 | 0 / 0 / 0 | **0 / 0 / 0** (801 + 2 per mode) |
| (4) downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, csv identical to pristine's | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, "not identical and not excused=0", csv identical to pristine's and to the law's** |
| csv against pristine, row by row | | probe 0, uhdm2rtlil 0, surelog 2 rows (LowMemLib and LowMemPkg testflags: the SURELOG_FAIL detail carries the workdir path) | the same 0 / 0 / 2 environment rows; against the law's csvs, the same |
| law index | stale at the base in the pristine tree | | stale only from this directory before the regeneration; `scripts/law_index.py --check` clean after it |

* **(5)** No row changes status or strict detail, so there is no touched row to hold at 0 uhdm-cmp lines. The targeted
  rows keep their cells: FuncStructVal d/t `endcol(7)`/`endcol(10)`, BlackBePipeInt d/t `type(1)`,
  struct_param_func_config d/t `fullname(5)`, cfg_func_width_loop d/t `line(3)`. InterfArrayBind d/t and OutputSize d/t
  stay CMP_EQUAL, and the UVM rows and Earlgrey_0_1 are as at the base.
* **(6) The mover prediction** ([evidence/census/](evidence/census/)) was frozen before this sweep. The fix3 firing
  census used `R11U228_TRACE` over both corpora in both modes (`--filter` built from `$FENCED`: 3265 `slang:` lines, all
  fix3), every probe case and every downstream lane. It wrote **0 trace files**. On six grid cases the positive control
  wrote all six law names: `memberInitReducedRootFolds228` x2, `memberRootFoldShapes228v` x2,
  `memberRootOwnInstance228v`, `parseViewSizeExprEval228` x2, `pvSizeNoElemDeclines228v` x3 and `sizeBitNetIsVar228`.
  The prediction was therefore 0 movers besides the known coins.
* **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`, on hard-link mirrors that leave out the 8
  fenced databases unread, r11u228repro/drivers/bvmirror.sh):
  * fix3 against pristine: PATH_SETS_IDENTICAL (2560), **MOVERS 2 / 2560**. These are `surelog/default/MiniAmiq`
    (`c31175d9` against `62214489`) and `surelog/default/Scoreboard` (`11620893` against `60ca9a0c`). Both hashes are
    the pre-existing coin draws the implementer's pristine determinism run also drew. MiniAmiq's uhdm-dumps are
    identical (0 raw lines), Scoreboard's differ by 92 raw lines and 0 order-blind, and the order-blind away census
    reads 0 lost and 0 gained on both.
  * fix3 against the law: 1 / 2560 (MiniAmiq, the same coin). SELFCHECK flagged 2559 of 2560.
  * **Probe databases: 0 of 4087 differ** from the pristine probe run of the same tree (`/tmp/v11u228_wQ`).
* The prediction (0 besides the coins) is met.
* **Canaries** on the fix3 csvs: canaries.sh gives surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0.
  `EXPECT_UNKNOWN=1 ctcan2.sh results/golden_surelog.csv` gives PASS (ok=58), and `EXPECT_UNKNOWN=6 ctcan2.sh
  results/golden_uhdm2rtlil.csv` gives PASS (ok=2).
* **Allocation.** The refinements allocate during emission only on their firing paths (the trace strings), and none
  fires on a corpus row. The placeholder guard runs after emission. So the address-order walk of
  § refFullNameThroughNamedExpr175 sees the base's heap on every corpus row. Determinism is measured below.


### 5.1 Determinism ([evidence/det/det.txt](evidence/det/det.txt), drivers/det.sh: three concurrent harness runs per binary on Earlgrey_0_1 and the five UVM rows, both modes)

| row-mode | pristine (3 runs) | fix3 (3 runs) |
|---|---|---|
| Earlgrey_0_1 d / t | `ede36385` x3 / `260e88fe` x3 | the same x3 / x3 |
| SeqDriver d / t | `0218e5d9` x3 / `e628b31f` x3 | the same |
| BuildUVMPkg d / t | `6463b4cd` x3 / x3 | the same |
| SimpleUVM d / t | `40e2f8a8` x3 / `0267d39f` x3 | the same |
| MiniAmiq t | `48699d65` x3 | the same |
| MiniAmiq d | `48699d65` x3 (this sweep's pristine drew `62214489`) | `62214489` + `c31175d9` x2 (uhdm-dump identical to pristine's `48699d65`: 0 raw lines) |
| Scoreboard d | `441c72a8` + `60ca9a0c` x2 | `11620893` x3 (against `60ca9a0c`: 92 raw dump lines, 0 order-blind) |

Every deterministic row-mode writes pristine's bytes. The two coins draw several hashes on pristine too, and fix3's
draws are dump-identical or identical order-blind.

### 5.2 Each refinement switch dropped alone

* `R11V228_ROOTINST_OFF` moves 4 grid case-views (FM f12 and f14, both views) and `R11V228_ROOTSHAPE_OFF` moves 26 (FM
  f03 f06 f08 f13, FR c1-c3 c5 c7 c8 d04 d06 d13 d16 d17, both views). Each is a case its own law fires on.
* `R11V228_PVSIZEDYN_OFF` gives fix3's bytes on all 428 grid case-views that write a database. The other 6 exit rc 139,
  as r11u228's binary does: v11u219 S s01_dyn_inner and s01b_queue_inner, v11u223 S s09 and s10, FS s10 and s12, parse
  view.
* `R11V228_OFF` gives r11u228's bytes on all 434 case-views, and `R11U228_OFF` gives pristine's bytes on all 434.

## 6. Residues (ranked)

1. **Sister ground behind every member-law case.** The case goes stage 1 on golden's `int` typespec stamp on the
   elaborated `param_assign` constants: ParamEmit `emitParameters`, next to § paramValueIsDefRhs124. This is r11u228's
   residue 1; my refinements do not move it.
2. **Member-root shapes left to the base**, where golden folds but the whitelist keeps the path, as pristine did:
   * a conditional whose selected branch is a struct parameter;
   * a root reached through a generate-block or package scope in another instance of the same definition (the
     own-instance rule maps only parameters declared directly in the body);
   * an override chain crossing two instances of the parent definition (the parent's first instance is read).
3. **`$size` shapes the parse-view law leaves**, as r11u228 lists them:
   * a select or package-qualified operand: FS s01 `p::pv` stays stage 1;
   * a modport member (FS s11);
   * a parameter operand;
   * an expression around the call;
   * an assign statement or a variable initializer.
4. **Fixed-then-dynamic `$size`** (FS s10, s12, v11u223 S s09 and s10): Surelog writes no database, so no golden
   decides the parse view's value of the fixed calls in those files.
5. Carried from r11u228 unchanged:
   * the 598 minted clone return variables (the fix is at the class-method clone loop in ParamEmit, passing
     `pkgImportCloneRetVar`, the sister's);
   * `'0`, `'z` and net-declaration `'1` onto a substituted width;
   * two instances with two member widths (FO g16, OS o21);
   * UVM_SEQ_ARB_TYPE, this_type and the imported scalar typedef formals;
   * based range bounds, formal columns in macros, and Earlgrey_0_1's 19 records;
   * N0120 and N0039;
   * the address-order loop of § refFullNameThroughNamedExpr175 (ground A).

## 7. Fence and process

* Every driver of this directory reads `FENCED` from canaudit.sh and fails closed: env.sh, case.sh, census.sh and
  dscases.py, with bvmirror.sh from r11u228repro. The census and the firing positive control never dispatched a fenced
  test. The gate sweeps dispatched every row as the gate mandates, and only their csv verdicts are cited.
* gdb ran once, on the unfenced v11u219 case `s01b_queue_inner`, to take the crash's backtrace.
* **One process slip.** A wait loop of mine used `pgrep -f` with a pattern its own shell command line contained, so it
  matched itself and never ended. I stopped it; it had started nothing.
* **One fence-process breach, found and cleaned.** At 08:31:53 one comparison command of mine called `$UHDM_CMP` in a
  shell that had not sourced the environment. Bash executed two pristine databases of v11u219 S (from this pass's own
  case store). This is the hazard pass 223 decoded. The command ran from the session's working directory, the main
  checkout, and left two EMPTY garbage-named files in its root (inodes 1108617 and 1020055, 0 bytes, created 08:31:53-54).
  I deleted both by inode within a minute, and the main tree's `git status` is clean again. No file was written
  anywhere else. The numbers of that command were discarded and remeasured through a guarded shell (the ones quoted in
  section 2). Every later tool call sources the environment and checks `[ -x ]` first.
* Every uhdm-dump went through drivers/udump.sh, which calls it by an absolute path after checking `[ -x ]`. Every
  sourced environment checks its tool variables with `[ -x ]`.
* The four fresh cases slang rejects (FR d20 and d21, and the first drafts of FS s02 s07 s10) were removed or rewritten
  before any measurement cited here.

## 8. Files

* `cases/FM` (member root: f01-f14), `cases/FR` (the golden root-shape decode as cases), `cases/FS` (the parse-view
  `$size` law: s01-s12), `cases/FB` (the bit-net law). Every case's first line names its law.
* `drivers/`: env.sh, case.sh, grid228.sh, udump.sh, awaycase.py, flatexplain.py, dscases.py and census.sh, copied from
  r11u228repro as noted in each file; gridv.sh and gridsum.py are new.
* `evidence/`: grid, away, downstream, decode, census (the frozen prediction), sweeps, det.
