# v11u254 — adversarial verification of r11u254 (pass 254, the expression/parameter ground)

Base aeabc99d. Implementer's patch: six laws in src/ExprEmit.cpp and src/StmtEmit.cpp behind src/R254.h
(tools/probe/r11u254repro/README.md). **Verdict: ACCEPT, no production fix.** Every headline number of the
implementer reproduces bit for bit on binaries built here. 47 fresh cases in both views (94 case-views) move no case-view away
from golden on any switch. No probe case, corpus row, downstream row or control case leaves EQUAL, STRICT_EQUAL
or IDENTICAL. The delivery adds this directory and the regenerated tests/LAWS.md to the implementer's patch, and
its production files are byte-identical to the implementer's.

## 1. Binaries (built here, frozen before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine (worktree at aeabc99d) | 86b9049a3c31716209e7ba2a4778d03e | the brief's main-tree md5 |
| law (aeabc99d + /tmp/r11u254.patch) | 29b5f8dd6c98e6a45638f52a735486c3 | the implementer's law md5 |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | |
| strictcmp_x (drivers/cc_x.sh) | 886f030233ecdbcce7d0e29ac0c4df2c | the implementer's |

Both report slang 12.0.0+545f88b2e and UHDM 1.87. The patch applies cleanly on a fresh aeabc99d.
`scripts/law_index.py --check` reads current there.

## 2. Targeted rows (fresh sweep csv rows, evidence/fresh_rows.txt)

| row-mode | base | law sweep here |
|---|---|---|
| BuildUVMPkg default | differ:endcol(1) #194627 | **CONVERTED** `BuildUVMPkg,default,CMP_EQUAL,,,equal` |
| BuildUVMPkg testflags | differ:endcol(1) | **CONVERTED** `BuildUVMPkg,testflags,CMP_EQUAL,,,equal` |
| Earlgrey_0_1 default | differ:fullname(155) | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(133),,differ:fullname(133)` |
| Earlgrey_0_1 testflags | differ:fullname(50) | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(40),,differ:fullname(40)` |

**BuildUVMPkg default.** On pristine, uhdm-strictcmp's only record is
`#194627 endcol  A: hier_path factory.is_type_registered uvm_pkg.sv 14097 13 14097 46` against
`B: ... 14097 13 14097 39`. On the law binary it reads `STRICT_EQUAL 201533 objects`.

**Earlgrey.** The first record stays #136315 (default) / #137760 (testflags). The records cleared in default
are #154375, #165002, #193018, #214553, #233668 to #233761 (7 records) and #346618 to #347342 (11 records); see
evidence/earlgrey_default_law_strict200.txt.

The writer of #136315 is confirmed on the law binary. In r11u255repro decode/A/a03, gdb stops in
`UhdmExporter::crossPkgBoundFoldConst9` called from `emitSyntaxExpr` / `makeTypespec` / `materializeDefNetTs`.
That is TypeEmit's § crossPkgBoundFoldConst9, so the record is on the sister ground and not ExprEmit's
§ sysFuncArgFold. This agrees with the implementer's correction of pass 255.

## 3. Gates reproduced (frozen binaries, own workdirs; evidence/sweeps_summary.txt)

**Stage results:**

| stage | pristine sweep | law sweep |
|---|---|---|
| probe | EQUAL 3552 / STRICT_NOTEQUAL 535, 0/0/0 | EQUAL 3559 / 528; regressions=0 conversions=7 changes=1 |
| surelog | 0/0/0 | regressions=0 conversions=2 changes=2 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | identical to pristine, 0/0/0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same verdicts; verdict diff 0 against pristine |

* Probe conversions under the law: g6_earl82, qa20, wd, g160_c_context, g167_b_spell, vA_meth and vD_kinds. The
  one change is v41v_comment fullname(24) -> (20). Both lists are the implementer's.
* The surelog sweep's two conversions and two changes are the four rows of section 2.

**Byte checks:**

* **uhdm-cmp:** 0 lines on all four corpus movers.
* **byteverify:** run on fence-filtered hard-link mirrors (drivers/bvmirror.sh: 2560 mirrored, 8 fenced paths
  skipped unread).
  * The path sets are identical. There are 4 movers of 2560: BuildUVMPkg d/t and Earlgrey_0_1 d/t.
  * Their patched hashes (803e6e35cade, b3c161ed0756, c93e7aa371fd) are the implementer's.
  * SELFCHECK reads 2559 / 2560. That is the self-check artifact pass 201 recorded: every file is compared with
    one fixed file, and that file cannot flag itself. It is not a movers line.
* **Probe databases:** 8 movers of 4087, exactly the eight probe status changes (evidence/dbmovers_probe.txt).
  * The pristine probe stage was rerun from the law worktree, because a database embeds its source path. That
    rerun's csv is identical to the pristine sweep's.
* **Downstream slang lanes:** 0 movers of 805 databases.

**Prediction:** frozen before the law sweep in evidence/census_predict_frozen.txt, from my own R11U254_TRACE firing
census over the fence-filtered probe and both corpora in both modes.

* It names the same 11 corpus databases and 13 probe databases as the implementer's census.
* All 4 corpus movers and all 8 probe movers were predicted.
* The 7 UVM row-modes fire § shellCallInvocationSpan254 only on statement-position calls, and their bytes did
  not move, as predicted.
* The uhdm2rtlil corpus has 0 firings and 0 movers.

**Away census on the corpus movers** (chain key drivers/awaychain.py, flat key drivers/awaycorp.sh +
away.py; evidence/corpus_movers_away.txt):

| row-mode | distance | lost | gained (toward golden) |
|---|---|---|---|
| BuildUVMPkg d/t | 19 -> 18 | 0 | 1 |
| Earlgrey default | 1032 -> 1009 | 0 | 23 |
| Earlgrey testflags | 764 -> 753 | 0 | 11 |

The chain key reads away=0 on all four.

**Canaries and audit:**

* Canaries: surelog ok=48 changed=4 (the four targeted rows); uhdm2rtlil ok=16 changed=0.
* ctcan2 surelog PASS (ok=58); ctcan2 uhdm2rtlil PASS (ok=2).
* Binary-path audit (evidence/binary_audit.txt): in each sweep, 3265 of 3315 fence-filtered cmds.txt name the
  frozen binary of that sweep, and 0 slang lines name another binary. The other 50 are rows where Surelog fails or
  the row is deferred, and they carry no slang line.

**Determinism** (drivers/det.sh: three concurrent draws per row-mode on Earlgrey_0_1 and the five UVM rows with
the law binary): one hash per row-mode on 11 of 11 (Scoreboard testflags is SLANG_REJECT). Each hash equals the
sweep's database, so 4 of 4 draws agree.

**Law index:** `law_index.py --check` reads STALE in an untouched aeabc99d worktree. That is the base's own
artifact: it does not depend on the patch, and a clean patched tree reads current. tests/sweep.sh's exit status 1
on every stage here comes from that check alone.

## 4. The implementer's grid, rerun (evidence/grid_implementer_rerun.txt)

* All 88 case dirs ran in both views on the 9 configurations.
* All 1584 lines match the implementer's evidence/grid.txt in every field except the md5. The databases embed the
  case path, which is under /tmp/wt_v11u254 here.
* V/v06_forinit_split, which ran outside the implementer's grid, adds 18 lines: L stage 1 with 368 uhdm-cmp
  lines against 15 on pristine, and the elaborated view going from rc 139 to rc 0.
* The 368-line face is the two-initializer for-loop `for (s.a = 0, i = 0; ...)`. It is not this pass's law:
  an isolating run of that loop alone gives byte-identical pristine and law databases, because that loop takes the
  multi-initializer branch. See residue 3.
* Census (evidence/grid_implementer_rerun_census.txt): R11U254_OFF gives pristine bytes on 178 of 178. Each switch
  moves only its own cases (FORINITSEL 15, GCAPSOP 6, HCSELPORT 18, PKGSELREF 11, REPLCOUNT 18, SHELLSPAN 28).
  Moving 94, entering STRICT_EQUAL 60, leaving 0.

## 5. Attack: 47 fresh cases in both views (cases/, evidence/grid_fresh*.txt)

Every case's first line names its law. Each case ran on the 9 configurations (P, L, OFF and each switch off):
846 lines, every line with its exit code.

| law | cases | shapes |
|---|---|---|
| § shellCallInvocationSpan254 | S/vs01 to vs06 | while, ternary, case and return conditions; user-function and $display arguments; unary and binary operands; two arguments with the bad one second; named arguments; a space before the paren; macro-born whole calls and macro arguments; an extern method defined after the class; an override of a pure virtual; a property, this. and this.f receivers |
| § pkgSelIdxRefColons254 | P/vp01 to vp10, X/vx02 | index a local variable, a genvar or a module localparam; net-declaration, variable and parameter-default initializers; nonblocking and compound assignments, two and three levels; index a package function call, a package parameter (own and other package), a ternary or a nested qualified select; function return, task output and struct-member read; child instance two levels down and an if-generate; an array element and an always_comb local as the index; macro-born selects and indices; an implicit net target |
| § hcSelIdxTsSkipsPort254 | H/vh01 to vh07, X/vx01 | operation index; 2-D with one imported index; for-generate connections and instance depths 2 and 3; concatenation, output and inout; package-qualified index without import; an interface instance port; port and signal names that are suffixes of each other; positional lists; part selects with imported bounds; struct-member selects; selects under ternary, binary and unary operations; an interface-body interface instance |
| § procReplCountOwner254 | R/vr01 to vr06, X/vx01 to vx03 | localparam, parameter default, variable and named-block initializers; nested, in-concatenation and parenthesised counts; function, task with a named fork, final block, if condition; depth 3 and a middle instance's connection; package-qualified count; generate-instance connection; parameter override; case item, case expression and for-loop bound; interface body; class specialization parameters |
| § genCaPsBoundOpChain254 | G/vg01 to vg07 | indexed part-selects over a var_select with operation base and width, two-level for generate; if and case generate scopes; part-select targets one and two levels down; net declaration assignment and generate-local net; bounds over localparam, imported, package-qualified and macro-born parameters; concatenation, ternary, reduction and call-argument contexts; $clog2 and user-function bounds |
| § forInitSelectLhsBase254 | F/vf01 to vf08 | class property struct member; class handle member from a module; interface-port member and part select; packed struct member; indexed part-select; 2-D element; index an expression; two initializers; hierarchical base; generate-block variable; package function; program and interface bodies; synthesizable always_comb; output port struct; ref formal; named-block local; queue, associative and dynamic array elements; a function's return variable member |

**Census** (evidence/grid_fresh_census.txt):

* R11U254_OFF gives pristine bytes on 94 of 94.
* Each switch moves only its own law's cases, with one exception: the X cases, which were written to combine laws.
  The counts are FORINITSEL 13, GCAPSOP 2, HCSELPORT 10, PKGSELREF 12, REPLCOUNT 14 and SHELLSPAN 12.
* **59 case-views move, 34 enter STRICT_EQUAL, and none leave.**
* Exit codes: six pristine rc 139 crashes now exit 0 (vf01, vf03, vf05, vf06, vf07 and vf08, all elaborated), and
  none gets worse.

**First-field changes:**

* P/vp07 and vp10: fullname -> type. The fullname records are cleared, and the walk then diverges at the
  pre-existing face where golden writes a var_select and ours writes the folded constant. It is the first record
  on both binaries for vp01, vp06 and vp07 too.
* F/vf01: stage 1 -> fullname. The remaining record is a class struct member's ref_typespec,
  `work@top::c::st::a`, which is TypeEmit's.

**uhdm-cmp lines rise only on stage-1 case-views**, and the first mismatch moves later in each:

* F/vf03: 15 -> 94, on the two-initializer loop (residue 3).
* F/vf05: 15 -> 29, on a program-block net, unrelated to the laws.
* F/vf05_el: crash -> 58.

**Away census** (evidence/grid_fresh_away.txt, chain and flat keys): every mover that has a pristine database reads
away=0 in both keys. Six movers have no pristine database (the rc 139 crashes listed above).

**Downstream on the cases** (drivers/dscases.py, both binaries, 47 case dirs; evidence/downstream_fresh.txt):

* None leaves IDENTICAL.
* F/vf01, vf03, vf05, vf06, vf07 and vf08 go STATUS_DIFF -> IDENTICAL: the plugin crashed on the missing for-init Lhs.
* The remaining verdicts are unchanged:
  * F/vf02 and vf04 stay STATUS_DIFF. Their bases are an interface port and a hierarchical path, which the law
    leaves to pristine.
  * The P stage-1 cases stay DIVERGENT on both binaries.
  * X/vx01 stays EQUIVALENT on both.

## 6. Byte controls (drivers/controls.sh; evidence/controls*.txt)

**Part 1, the implementer's 14 dirs.** 968 case dirs, 1936 case-views.

* 14 move: 8 enter STRICT_EQUAL and none leave. The only exit-code difference is r11v124 hx/x02_forstep_el,
  139 -> 0.
* The movers that enter STRICT_EQUAL:
  * r11u169 gc/c04 (GCAPSOP);
  * r11u255 decode/A a01 in both views (SHELLSPAN) and a02 in both views (HCSELPORT);
  * r11v11u118 v1/v09_vsvar (HCSELPORT);
  * r11v124 hx/x02_forstep in both views (FORINITSEL).
* Bytes only:
  * r11u169 c04_el (GCAPSOP);
  * r11u250 decode/E e01 in both views (GCAPSOP in the elaborated view; 4 records toward golden in the definition
    view);
  * r11v11u118 v30_vs_genfor (4 toward).
* r11u169 c04_el and r11u250 e01_el move bytes that uhdm-dump does not print: their dumps are identical apart from
  the header line, and both away keys read 0/0.
* v11u255 F/vf03_twospecs in both views is not attributable to a law. It is pass 255's pristine first-writer
  nondeterminism: pristine itself writes 2 hashes in 6 draws here, and the case is STRICT_EQUAL on both binaries.
  The implementer's run caught vf08 as well, the same coin.

**Part 2, widened by 12 more dirs** (r11u167, r11v167, r11u236, v11u236, r11u246, v11u246, r11u248, v11u248,
r11u244, v11u244, r11u238 and v11u250). 1578 case-views.

* 2 move, r11u236 P/p04 in both views. That case is stage 1 on both binaries with the same 64 uhdm-cmp lines, and
  attribution shows HCSELPORT alone.
* None enters or leaves STRICT_EQUAL, and no exit code differs.

**Away census** (evidence/controls_away.txt): chain away=0 and flat away=0 on every moved control case-view.

## 7. Findings

**No pristine-right -> patched-wrong case was found on legal SV:**

* not in the 47 fresh cases (94 case-views);
* not in 3514 control case-views;
* not in the probe (4087), the corpora (2560 fence-filtered databases) or downstream (805 slang-lane databases).

No production fix is needed.

**README corrections recorded for the implementer:**

1. **§ procReplCountOwner254 "abstains through interfaces"** does not hold in an interface's own definition body.
   * In X/vx01_iface_body the trace reads `procReplCountOwner254 work@ifc.p_i -> work@ifc`. Our definition listing
     reaches a module-kind owner there.
   * The firing agrees with golden: golden's uhdm-dump names that ref_typespec `work@ifc`.
   * So it is a coverage note, not a break.
2. **Byte-control count.** The implementer reports 15 movers. Here it is 14, with the same attributable set: the
   difference is pass 255's pristine coin (vf03 and vf08).

## 8. Residues, ranked (all wrong on pristine too; none introduced by the laws)

1. **Earlgrey_0_1 d/t fullname(133)/(40).**
   * Head #136315 / #137760 is TypeEmit § crossPkgBoundFoldConst9, the sister ground (confirmed above). Next are
     the implementer's residue (a) to (c) faces on this ground.
   * § pkgSelIdxRefColons254 is gated off for a whole `--elabuhdm` run, so the definition listing of an elaborated
     run keeps the dotted name where golden writes `cp::R3::cp::R3::W` (P/vp03_el, five records).
   * The gate is needed because the elaborated DeepClone copies the name (the implementer's Q/q01 and q05). A
     refinement must separate the definition listing from the DeepClone.
2. **The pkg-select elaborated faces.** The face where golden writes a var_select and ours writes the folded
   constant (P/vp01, vp06, vp07 and vp10, stage 2 type) is the next record after § pkgSelIdxRefColons254 in the
   definition view.
3. **Two-initializer for-loops.**
   * `for (s.a = 0, i = 0; ...)`: golden writes a hier_path `s.a` with vpiOpType 82 and blocking; ours writes a
     ref_var `s` with neither.
   * This is pre-existing (StmtEmit's multi-initializer branch, untouched by § forInitSelectLhsBase254), and the
     downstream verdict is IDENTICAL anyway.
4. **The bases the for-init law leaves to pristine**, all stage 1 on both binaries:
   * an interface-port member (F/vf02; the `--elabuhdm` crash rc 139 remains);
   * a hierarchical path into a child (F/vf04, rc 139 remains);
   * the implementer's this. and package-qualified bases.
5. **The class struct-member ref_typespec full name** after a for-init in a class (F/vf01: golden
   `work@top::c::st::a`, ours `a`; TypeEmit).
6. **A ternary-branch part-select bound** inside a generate continuous assignment (G/vg05: golden `work@top`, ours
   `work@top.g[0]`; not § genCaPsBoundOpChain254's shape).
7. **Part-select targets in generate continuous assignments** (G/vg03, vg07) and net-declaration initializers there:
   stage 1 on both binaries, untouched.
8. **The implementer's residues 2 to 7** stand as written (BlackBePipeInt #331795 / #331692 and brief items (4) to
   (7) not attempted).

## 9. Process

* Worktrees /tmp/wt_v11u254 (law) and /tmp/wt_v11u254pris (pristine), and a clean apply check in /tmp/wt_v11u254chk.
* Scratch is under /tmp/v11u254_*. Nothing was written to the main checkout.
* The builds ran with -j 2, and the pristine binary was frozen before the law binary was built.
* Every case path list and every corpus database list was filtered by `$FENCED` (word boundary, read from
  tools/probe/r11u107repro/canaudit.sh) before any file was opened.
* Nothing fenced was dispatched, read or opened outside the gate sweeps.
* No process was signalled, and no pgrep -f or ps listing of other agents' command lines was run.
* My first control run failed before any case ran: the copied drivers had lost their executable bit. That run was
  rerun in full.
* **Fresh cases rewritten:**
  * Two first drafts were illegal SV for slang and were rewritten before any measurement: S/vs05 dropped a
    module-level function passing int to a class formal, and X/vx01 replaced a module instance inside an interface
    with an interface instance.
  * They appear only in their final form.

## 10. Files

* cases/F, G, H, P, R, S and X: the fresh cases.
* drivers/: copied from r11u254repro/drivers, with paths moved to this directory. controls.sh takes `CTLJOBS`.
* evidence/: every number above.
