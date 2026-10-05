# v11u248: adversarial verification of r11u248

Base 910f9474 (pass 246 on top of pass 247). This directory verifies the r11u248 patch: four laws on the
expression/parameter ground (src/ExprEmit.cpp, src/StmtEmit.cpp, src/ParamEmit.cpp, the switch header src/R248.h) plus
the cleanup of a dead early return in § macroParamMethNameEnd246.

**Verdict: the patch is VERIFIED WITH ONE FIX.**

* Every headline number of the implementer reproduces bit for bit, the hashes included.
* The fresh cases found one break on legal SV, in § callArgCopyReduceOpModel248, and it is fixed here behind its own
  switch. In the elaborated view, the law moved one golden record away on six fresh case-views. Those case-views read
  stage 1 on every binary, so no gate row, probe case or downstream row could see the loss.
* The fix moves no gate database: 0 of 3373 corpus and downstream databases and 0 of 4087 probe databases differ from
  the law's. That was predicted and frozen before the fix sweep.

## Binaries (built here from fresh worktrees at 910f9474)

| binary | md5 | note |
|---|---|---|
| pristine | d648893fb282dbd79047ec841d57b894 | the brief's pristine md5. The main tree's build/slang-uhdm read 188f251c… at measurement time (rebuilt since); it was not used |
| law (r11u248.patch) | 51a675644dac5543ff49eee50200bf38 | equal to the implementer's |
| fix (law + this pass) | 5b42566f278486ffb07d0a6309f1413d | the delivered /tmp/r11u248.verified.patch |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | equal to the main tree's |

All binaries were frozen at /tmp/v11u248_bin before any measurement. Every cmds.txt of the three sweeps was audited by
binary path, with the path list built first and filtered by `$FENCED`:

* pristine: 3265 of 3265 name /tmp/v11u248_bin/pristine;
* law: 3265 of 3265 name /tmp/v11u248_bin/law;
* fix: 3265 of 3265 name /tmp/v11u248_bin/fix;
* no cmds.txt names any other binary.

The other 50 cmds.txt hold no slang-uhdm run.

## The fix: § callArgCopyElabNearestOp248v (`R11V248_ELABNEAREST_OFF`; `R11V248_OFF` drops it)

Sites: ExprEmit callArgCopyLpReduced246v (the § callArgCopyReduceOpModel248 walk), the view flag
`callArgCopyElabView248v()` in src/R248.h, and the setter in ParamEmit just before drainCallArgCopyTs246.

### The break

§ callArgCopyReduceOpModel248 marks a reference to the localparam L as unreduced when ANY ancestor up to the module
is an operator UHDM reduceExpr has no case for (`^ ~^ === !== ==? !=? -> <->`) or a range selector. Golden follows
that whole-path rule in the default view. In the --elabuhdm view it does not:

* A reference whose NEAREST enclosing operator is reducible is reduced, even under an outer xor.
* The instance's copied call actual (`work@top.u`'s param_assign `L = f(N)`) then wears the formal's int_typespec,
  golden 3:41.
* The law set the parameter's own typespec (2:24) there, where pristine and golden agree.

Each of these case-views lost one golden record (order-blind dump census, stage 1 on every binary):

| case | expression | default view, law vs pristine | --elabuhdm view, law vs pristine |
|---|---|---|---|
| R/r01_add_under_xor | `(L[1] + 8'd1) ^ 8'd3` | 1 gained, 0 lost | **1 lost** |
| R/r18_shift_xnor | `(L[1] << 1) ~^ 8'd3` | 1 gained, 0 lost | **1 lost** |
| R/r22_neg_xor | `(-L[1]) ^ 8'd1` | 1 gained, 0 lost | **1 lost** |
| R/r23_call_add_xor | `g(L[1] + 8'd1) ^ 8'd1` | 1 gained, 0 lost | **1 lost** |
| R/r28_tern_xor | `((L[1] != 0) ? 8'd1 : 8'd2) ^ 8'd3` | 1 gained, 0 lost | **1 lost** |
| R/r29_addtwo_xor | `(L[1] + L[2]) ^ 8'd1` | 1 gained, 0 lost | **1 lost** |

The law stays right in the elaborated view when the opaque operator is the nearest one: `L[1] ^ a` (r02), `L[0] ^ 8'd0`
(r13), `((L[0] ^ 8'd1) != 0) ? …` (r05), `g(L[1] ^ 8'd1)` (r03), `o[0][L[1] -: 2]` (r06), `L[1] !== …` (r16), and PE
e15, e16, e20.

The distinguisher, decoded on pairwise cases:

* A call's argument list is transparent: `g(L[1]) ^ 8'd1`, r25, stays unreduced in golden's elaborated view.
* A concatenation is transparent: `{L[1]} ^ 8'd1`, r26, stays unreduced.
* An operator inside the call stops the scan: `g(L[1] + 8'd1) ^ 8'd1`, r23, is reduced.

### The rule

In the elaborated view only, the scan stops at the reference's nearest operator:

* if that is an opaque operator or a range selector, the reference stays unreduced (the law's answer);
* if it is any other binary or prefix-unary operator, the reference is reduced (pristine's answer);
* parentheses, argument lists, concatenations and other expression nodes are transparent.

The default view keeps the law's whole-path rule.

### Effect

* The fix restores pristine bytes on 11 elaborated case-views: r01, r09, r17, r18, r20, r21, r22, r23, r24, r28 and
  r29, each `_el`.
* The six losses above are gone.
* r09, r17, r20, r21 and r24 moved bytes under the law with no record or dump line changing. Their dumps are identical
  on law and pristine.
* It changes nothing in the default view, in any r11u248 case or in any v11u246 PE case: 138 case-views on pristine,
  law, fix and fix + `R11V248_OFF`, in [grid/reduce_pe_fix.txt](evidence/grid/reduce_pe_fix.txt).
* Pass 246's six conservative case-views (PE e15, e16 and e20, both views) keep the law's one record gained each.
* `R11V248_OFF` gives the law's bytes on 138 of 138 there, and on 118 of 118 in the final grid.

The trace tag is `callArgCopyElabNearestOp248v` (under `R11U248_TRACE`). The firing census of the fix binary over the
probe and both corpora shows that neither it nor `callArgCopyReduceOpModel248` fires anywhere
([census/tracecensus_fix_predict.txt](evidence/census/tracecensus_fix_predict.txt): 4 databases, MiniAmiq d/t and
SeqDriver d/t, with only the three other laws firing).

## Reproduction of the implementer's numbers

### Grid

The implementer's 40 cases were rerun with its own drivers on these binaries
([grid/impl_grid_rerun.txt](evidence/grid/impl_grid_rerun.txt), 560 lines):

* every verdict is identical line for line;
* the md5-equality pattern per case-view (which runs equal pristine's bytes) is identical on 80 of 80. The md5 values
  themselves differ only because a case database embeds its case path;
* gridsum: 26 entering STRICT_EQUAL, 0 leaving; `R11U248_OFF` pristine bytes 80 of 80; uhdm-cmp count rising 0; exit
  codes all 0.

### Sweeps

The three sweeps are `tests/sweep.sh --jobs 3` with workdirs /tmp/v11u248_wP, /tmp/v11u248_wL and /tmp/v11u248_wF,
the same length ([sweeps/](evidence/sweeps)).

| stage | pristine | law | fix |
|---|---|---|---|
| probe | 3539 EQUAL + 548 STRICT_NOTEQUAL; 0/0/0 | 3539 + 548; regressions 0, conversions 0, changes 0 | the same as law |
| surelog | 470 + 10 / 466 + 8; 0/0/0 | regressions 0, conversions 0, changes 4 | the same as law |
| uhdm2rtlil | 803 / 803; 0/0/0 | 0/0/0 | 0/0/0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same | the same |

The four surelog changes:

* MiniAmiq default: `differ:type(1)` -> `differ:fullname(5)`
* MiniAmiq testflags: `differ:type(1)` -> `differ:fullname(5)`
* SeqDriver default: `differ:type(1)` -> `differ:fullname(5)`
* SeqDriver testflags: `differ:type(1)` -> `differ:fullname(5)`

Every sweep exits 1 on the law-index staleness check alone:

* At the base, the index lacks commit 910f9474 itself.
* In the law and fix trees, it lacked this directory's cases.
* The delivered patch carries the regenerated tests/LAWS.md, and `--check` reads current.

The fresh csv rows of the targeted rows (fix sweep; the law sweep's are identical):

```
MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
SeqDriver,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
SeqDriver,testflags,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
```

### Row-by-row csv comparison

* Law against pristine: only those four rows differ in surelog. uhdm2rtlil, downstream and probe differ in no row; the
  LowMem detail text differs only by workdir path.
* Fix against law: 0 lines differ in any of the four csvs.

### Heads ([census/heads_wP.txt](evidence/census/heads_wP.txt), [census/heads_wL.txt](evidence/census/heads_wL.txt))

At the base:

* MiniAmiq d/t `#78478 type`: golden `int_typespec` unlocated, ours `class_typespec uvm_phase` at uvm_phase.svh
  575:33-42.
* SeqDriver: `#78434` (default) / `#78446` (testflags), the same face.

With the law:

* MiniAmiq d/t `#79121 fullname`: `int_var succ` golden `uvm_pkg::uvm_phase::sync::visited.exists::succ`, ours
  `svaunit_pkg::…`, uvm_phase.svh 1896:9-16. Then #79122 and #79458.
* SeqDriver: `#79078` (default) / `#79090` (testflags).
* The objects read 435559 vs 434734 (MiniAmiq) and 475526 vs 474778 (SeqDriver default); every old head is cleared.

### Byteverify, movers and the away census

**byteverify** (`SELFCHECK=1`):

* Law against pristine moves 4 of 3373: MiniAmiq d/t and SeqDriver d/t, with hashes equal to the implementer's
  (bbad9ddd0f7b, ba7fe72bd953, 0f676f0dc7ee).
* Fix against law moves 0 of 3373; fix against pristine moves the same 4.
* SELFCHECK reads 3371 of 3373 and prints SELFCHECK_FAILED. The fixed reference is
  `./downstream/1DUnpackedArray/slang.uhdm`, and `./uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm` is
  byte-identical to it: the same command line writes both, so two paths match the reference by construction. That is
  pass 201's self-check artifact and not a mover. It reads one more than pass 201's 2559 of 2560 because the threshold
  is na-1.

**Probe** (byteverify does not list probe databases): a probe database embeds the worktree path. The pristine probe was
therefore rerun from the law worktree ([sweeps/probe_pristine_lawtree.txt](evidence/sweeps/probe_pristine_lawtree.txt),
EQUAL 3539).

* Law against that pristine: 0 of 4087 probe databases move.
* Fix against law: 0 of 4087.
* Positive control: the cross-tree comparison reads every probe database as a mover.

**Movers:**

* uhdm-cmp reads 0 lines on all 4.
* `R11U248_OFF` on the law binary gives pristine's bytes on all 4: MiniAmiq cb8bed8776a3 in both modes, SeqDriver
  1f41f8297925 / daca9febce01.

**Away census** (chain-keyed, r11u248's drivers/awayrows.py with its variant comparator;
[census/away_law.txt](evidence/census/away_law.txt)):

* MiniAmiq: away 0, toward 60 per mode.
* SeqDriver: away 0, toward 40 per mode.
* Flat keys give the same numbers.
* The swapped run ([census/away_swapped.txt](evidence/census/away_swapped.txt)) reads them as away, so the census can
  see a loss.

### Canaries ([sweeps/canaries_fix.txt](evidence/sweeps/canaries_fix.txt); the law sweep reads the same)

* surelog: ok=50, changed=2 (SeqDriver d/t, targeted).
* uhdm2rtlil: ok=16, changed=0.
* `EXPECT_UNKNOWN=1` ctcan2: PASS. `EXPECT_UNKNOWN=6` ctcan2: PASS.

### Determinism ([det/det_fix.txt](evidence/det/det_fix.txt))

Three concurrent draws of Earlgrey_0_1 and the five UVM rows on the fix binary give one hash per row-mode on 11 of 11.
Scoreboard testflags is SLANG_REJECT. The hashes equal the sweep's and the implementer's.

### Byte controls ([grid/controls_fix.txt](evidence/grid/controls_fix.txt))

The same 12 repro dirs as the implementer: r11u246, v11u246, r11u247, v11u247, r11u244, v11u244, r11u238, v11u238,
r11u183, r11u118, r11u119 and r11u120. That is 693 cases, 1386 case-views, 2772 lines, pristine against the FIX
binary (the `law` column of the file).

* The verdicts equal the implementer's pristine/law file line for line.
* The same 14 case-views move:
  * r11u247 decode/d01 in both views (enters STRICT_EQUAL);
  * v11u238 C/c02 (type -> name, 0 lost);
  * v11u238 E/e01 and e02 (stage 1);
  * v11u246 PE e15, e16, e20 (1 record toward each, 0 lost).
* 2 case-views enter STRICT_EQUAL, none leave, and no uhdm-cmp count rises.
* Non-zero exits are identical on both binaries: r11u244 F/f19 rc 3, and rc 4 on r11u244 X/x02, r11u246 DT/d12_v11,
  v11u238 D/d01_tdqueue, v11u246 LN/v04_ifcbody, **v11u247 E/e07_multidim and K/k10_union**. The implementer's README
  omits these last two from its list. They are pass 247's known exits, the same on pristine.
* v11u238 E e01 and e02 lose one context-free `|vpiParent:` dump line each. It is the parent line of the pristine
  unsupported placeholder, which a shared string_typespec does not print. Each gains golden's `string_typespec` line.

## Fresh cases (cases/, 59 cases, every first line names its law)

The grid is [grid/vgrid_final.txt](evidence/grid/vgrid_final.txt) with the summary
[grid/vgrid_final_sum.md](evidence/grid/vgrid_final_sum.md): 1180 lines, every line with its exit code (all 0).

* Each case runs in both views on pristine, law, fix, fix + `R11U248_OFF`, fix + `R11V248_OFF`, and fix + each of
  the five switches.
* 118 case-views: the law enters STRICT_EQUAL on 39 and leaves none, and the fix does the same.
* fix + `R11U248_OFF` gives pristine bytes on 118 of 118; fix + `R11V248_OFF` gives the law's bytes on 118 of 118.
* No uhdm-cmp count rises.
* Every switch reverts only its own group's cases:
  * A: CLONEDOTBASE (a10 also WITHCHAIN, since it holds a `with`);
  * B: WITHCHAIN;
  * S: CLONEPROPSTR;
  * R: PAREDUCE, or ELABNEAREST on the 11 elaborated case-views;
  * K: the laws it holds.

[vgrid_law_first40.txt](evidence/grid/vgrid_law_first40.txt) is the first grid, on the law binary and its own
switches.

Away census on every moved case-view ([census/away_fix_cases.txt](evidence/census/away_fix_cases.txt),
[census/away_law_cases.txt](evidence/census/away_law_cases.txt)): chain-keyed on the strict walk records, or the
order-blind dump when stage 1 rejects. The tool is drivers/awayrec.py.

* **Fix against pristine:** 0 records lost on every case-view, 254 gained. The exception is K/k01 in both views, which
  loses the same context-free `|vpiParent:` placeholder line as v11u238 E e01.
* **Law against pristine:** the six elaborated-view losses above, which are fixed.

Downstream, with the harness's own `one()` ([downstream/](evidence/downstream)): each case gets the same verdict on
pristine, law and fix, 41 IDENTICAL / 9 EQUIVALENT / 4 DIVERGENT.

* The DIVERGENT cases are R r03, r13, r19 and r25: xor and concatenation shapes on which golden keeps the call or the
  select unfolded. They are pre-existing.
* No case leaves IDENTICAL.

| group | law | cases | result |
|---|---|---|---|
| A a01-a10 | § cloneDotLoopVarBaseNoDrill248 | a01 union element type with a member of the base's name, a02 enum element, a03 typedef'd class element, a04 ref string element with a fixed-array member and slots, a05 two-dot path `x.sub.m_pred`, a06 vector element with the constant slots (`k*4 +: 4`, `k -: 1`, replication) and a 2-index loop, a07 derived class with `super.` in the body, a08 task with fork, a09 parameterized class, a10 a dotted loop variable used inside a `with` | a02, a05, a07, a08 enter in both views, a04 in the elaborated view, a06 6 records toward; a01 and a09 are stage 1 on both binaries with 1 golden line gained; a03 (a typedef'd class element) is stage 1 on every binary and the law does not move it |
| B b01-b13 | § cloneWithOperandChainName248 | b01 whitespace and a comment in the receiver, b02 sum/product with a cast, a package parameter and a static property, b03 sort/rsort statements, b04 min/max/unique with `[lim -: 2]`, b05 an associative receiver with `k.index()`, b06 struct members, b07 `with` in an if, a foreach and a task with a delay, b08 concatenation and replication, b09 select receivers `m_sync[ lim + 1 ].m_v`, b10 local declaration initialisers, b11 `super.` receiver, b12 parameterized class with `m_sync[i].m_v`, b13 a static function with a `c::s_v` receiver | b04-b08 and b10 enter (default view); b01, b02, b09, b12, b13 are stage 1 with 8-24 golden lines gained each; b11 moves bytes with 0 lost and 0 gained; the elaborated views are unmoved (the law is default-view only) |
| S s01-s06 | § cloneLoopVarClassPropStringTs248 | s01 parameterized class, s02 `string m_name, m_alt;`, s03 initialiser and `const string`, s04 task with fork/begin, s05 a queue loop beside a string loop, nested, s06 a property inherited from the base class | all 12 case-views enter STRICT_EQUAL |
| R r01-r29 | § callArgCopyReduceOpModel248 / § callArgCopyElabNearestOp248v | r01-r16: an add under an xor, xor with a net, xor in a call argument, xor in a concatenation, xor in a ternary condition, `-:`, an indexed select beside a plain read, unary xor, `->`, `inside`, a stream, xor in a generate-for header, whole-L xor, xor in always_comb, a range in always_comb, `!==` and `!=?`; r17-r29: the nearest-operator decode | r02, r05, r06, r09, r16, r17, r20 and r27 enter in the default view, r02, r05, r06 and r16 in the elaborated view too, 0 lost; the other elaborated views: see the fix |
| K k01 | (all three clone laws) | an interface body with a `with` in a function, an implicit net, pure virtual and extern prototypes above the caller, named calls with an empty slot, a `this.` receiver | stage 1 on both binaries; 18 / 2 golden lines gained and 1 placeholder `|vpiParent:` line |

## Ranked residues

1. **The two sister-ground heads now leading MiniAmiq and SeqDriver (4 row-modes)**, re-measured here.
   * #79121 / #79078 and the next 3 records: the receiver-argument mint of `visited.exists(succ)` in the copy of
     uvm_phase::sync / unsync is named with the copy's package. The site is UhdmExporter mintArrayElemVar193 /
     drainCloneArrayRecvArgMint193 (§ cloneArrayRecvArgMintsElemVar193).
   * Then #87013 / #86971, TypeEmit § cloneStmtHomeVarRef17 (the implementer's decode; not re-derived here).
2. **§ callArgCopyReduceOpModel248 still uses a syntax scan, not a model of the real reduction.**
   * A hierarchical reference (`u.L[1]`) or one in a nested module is still not scanned.
   * In the elaborated view, the nearest-operator rule is decoded on 13 shapes. A conditional, an `inside` or a cast as
     the nearest node is treated as transparent, and that is untested.
   * The xor shapes stay stage 1 on golden's folded select (e20, r03, r13, r19, r25 DIVERGENT downstream on every
     binary).
   * `g(L[1] ^ 8'd1)` (r03): golden keeps the call `g` unfolded where ours writes the constant 9, the same on every
     binary.
3. **Copy faces wrong on pristine too**, with no law of this pass worsening any of them:
   * the implementer's S s03, s05, W w06, w09, w11, C c07;
   * A a01, a03 and a09 (stage 1 elsewhere);
   * B b01, b02, b09, b11, b12 and b13 (stage 1 on other faces of the same copy);
   * B b06's elaborated view (`STRICT_NOTEQUAL name` on every binary).
4. The implementer did not attempt brief items (3) beyond the decode, or (4) to (7). BlackBePipeInt and Earlgrey_0_1
   are unchanged at the base heads.

## Process

* No fenced test was dispatched, read or opened outside the gate sweeps.
  * Every path list (cmds.txt audits, controls, grids) was built first and filtered by `$FENCED`, read fail-closed from
    tools/probe/r11u107repro/canaudit.sh by drivers/env.sh, before any file was opened.
  * The firing census ran with the implementer's tracecensus.sh, whose filters are built from `$FENCED`.
  * The fence check over this directory reads clean.
* Every tool variable was checked with `[ -x ]`. No process outside this pass was listed or signalled.
* Nothing was written outside /tmp/wt_v11u248, /tmp/wt_v11u248pris and /tmp/v11u248_*.
* Source was edited only after the pristine and law binaries were frozen and their builds had finished.
* The fix prediction was frozen ([census/predicted_fix.txt](evidence/census/predicted_fix.txt)) before the fix sweep:
  0 corpus, 0 probe and 0 downstream movers against the law. The sweep confirmed 0 / 0 / 0.
* The implementer's README lists the byte-control non-zero exits without v11u247 E/e07 and K/k10. Both exit 4 on
  pristine too. This is a reporting omission, not a mover.

Drivers:

* drivers/case.sh, env.sh, grid.sh and controls.sh are copied from r11u248repro, with paths resolved from this checkout.
* drivers/vgrid.sh and vgridsum.py run and summarise the final grid.
* drivers/awayrec.py is the per-case away census, chain-keyed or by dump.
