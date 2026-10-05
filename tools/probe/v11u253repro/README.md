# v11u253: adversarial verification of r11u253 (pass 253, the module/type ground)

Base 56afa6f0 (`matrix-1.87`). Verified patch: r11u253's delivery (src/R253.h, UhdmExporter, TypeEmit, TaskFuncEmit,
tools/probe/r11u253repro). **Verdict: verified, no production fix.** Nothing in the patch moves a strict cell, a
corpus row or a downstream row away from golden where pristine was right. This directory adds only cases, drivers and
evidence. Nothing under src, results/, tests/ (apart from the regenerated tests/LAWS.md) or third_party/ changes.

## Binaries (built by the verifier, frozen read-only before any measurement)

| binary | md5 |
|---|---|
| pristine (fresh 56afa6f0 worktree, system-deps config, -j 2) | 6c9a38c7c336533642274ab10bde5a8d (= main tree build/slang-uhdm) |
| law (fresh 56afa6f0 + /tmp/r11u253.patch, applied clean) | 10f0d294e218c87a65dec461a46b908c (= the implementer's) |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 |
| strictcmp_x (r11u253repro drivers/cc_x.sh) | 886f030233ecdbcce7d0e29ac0c4df2c |

Binary-path audit, with the cmds.txt path list filtered by `$FENCED` first: 3265 of 3265 `slang:` lines name the
sweep's own frozen binary, in each sweep.

## Every headline number reproduced

**Gate sweeps** (tests/sweep.sh --jobs 3; pristine from the pristine worktree, law from the law worktree;
evidence/sweep_P.txt and sweep_L.txt):

| stage | pristine | law vs results/ |
|---|---|---|
| probe | EQUAL 3543 + STRICT_NOTEQUAL 544 | EQUAL 3547 + 540: regressions 0, conversions 4, changes 4 |
| surelog | 471 + 9 / 466 + 8 | regressions 0, conversions 0, changes 4 |
| uhdm2rtlil | 803 / 1 / 67 in both modes | 0 / 0 / 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same, verdict diff 0 |

* Both sweeps exit 1 on `law index STALE` only. The committed tests/LAWS.md at 56afa6f0 already reads stale in a clean
  base worktree, because `scripts/law_index.py` reads the base commit's own message through `git log`.
* Row by row, the law csvs equal the pristine csvs apart from these:
  * the 4 surelog rows: MiniAmiq d/t and SeqDriver d/t, `differ:fullname(5)` -> `differ:type(1)`;
  * the 8 probe rows;
  * the two LowMem path-text rows.
* Probe conversions:
  * `r10uvm193repro/g193_d_propfence,EQUAL,,equal`
  * `r10uvm208repro/g208_e_head,EQUAL,,equal`
  * `r10uvm37repro/t51a,EQUAL,,equal`
  * `r10v195repro/v195_d_tfitem,EQUAL,,equal`
* Probe changes, each the same first field with fewer objects:
  * g193_c_argface fullname(44) -> (4)
  * g122_f_clone endcol(8) -> (7)
  * v200_5_modmat fullname(3) -> (2)
  * v208_f_io name(12) -> (7)

**Heads** (evidence/heads.txt):
* At the base:
  * MiniAmiq d/t: #79121, #79122, #79458 (golden `uvm_pkg::uvm_phase::sync::visited.exists::succ`, ours `svaunit_pkg::...`).
  * SeqDriver d: #79078 / #79079 / #79416.
  * SeqDriver t: #79090 / #79091 / #79428 (ours `adpcm_pkg::...`).
* With the laws, all four row-modes read one record: `type`, golden `string_typespec` uvm_component.svh 3380:10,
  ours `unsupported_typespec i` 3392:18. This is #87036 (MiniAmiq d/t), #86994 (SeqDriver d) and #87006 (SeqDriver t).
  It is the sister-ground face the implementer names (StmtEmit, the foreach branch's § cloneLoopVarHomeObject183 block).

**Byte movers** (all path lists filtered by `$FENCED` before any file is opened):
* **Corpora:** drivers/bvmirror.sh hard-links the 2560 non-fenced databases of each sweep. 8 fenced databases are
  skipped. Then tools/probe/r11v75repro/byteverify.sh runs with SELFCHECK=1 (evidence/byteverify_corpora.txt):
  * PATH_SETS_IDENTICAL, 2560 paths; selfcheck flags 2559 of 2560.
  * 6 movers: EvalFuncNamed, MiniAmiq and SeqDriver, both modes. 0 uhdm2rtlil movers.
* **Probe:** the pristine probe stage was rerun from the law worktree, so the source paths in the databases are equal.
  Its csv equals the pristine sweep's byte for byte. 35 of 4087 move, the same 35 the implementer lists
  (evidence/probe_movers.txt).
* **Downstream slang lanes:** 0 of 805 move.
* **Prediction:** the implementer's firing census was written at 14:27, before the law sweep's first probe database
  (14:36). It names 42 databases; the 41 movers are all among them, and r10v182repro/v182_g_names fires without moving.

**Away census on the corpus movers** (evidence/away_corpus.txt, chain_*.txt):
* Flat key (v11u202 away.py):
  * MiniAmiq d/t: distance 405 -> 229, lost 26, gained 72.
  * SeqDriver d/t: distance 245 -> 132, lost 10, gained 58.
  * EvalFuncNamed: 0 / 0.
* Chain key (r11u253 flatlost.py): 0 of the 62 (MiniAmiq) and 7 (SeqDriver) loss contexts holds a golden record
  (`g=0` on every line). Every flat loss is a pristine surplus.

**Grid** (the implementer's 46 cases, through drivers/vgrid.sh; evidence/rgrid.txt):
* Identical to r11u253repro/evidence/grid.txt in every field but md5, which embeds the case path. The switch pattern
  per case-view is identical too.
* 736 lines, every exit 0.
* R11U253_OFF gives pristine bytes on 92 of 92 case-views.
* 33 case-views enter STRICT_EQUAL and none leaves.

**Byte controls** (drivers/vcontrols.sh):
* **The implementer's 17 dirs** (evidence/controls17.txt): 1280 case-views. 124 move and 4 enter STRICT_EQUAL:
  r11u244 N/n13 and v11u247 A/a02_siblingq, both views. None leaves, and exit codes and uhdm-cmp line counts are
  identical. There is one first-field change, r11u238 F/f19 depth -> type and f19_el fullname -> type; the walk
  reaches the sister face.
* **Widened by 17 more dirs** (evidence/controlsW.txt): r11u243, v11u243, r11u245, v11u245, v11u249, v11u238,
  r11u246, v11u246, r11u118, r11v11u118, r11u119, r11u120, r11u131, r11u124, r11v124, v11u241 and r11u239, 2286
  case-views.
  * 28 move.
  * 2 enter STRICT_EQUAL: v11u238 A/a05_inner_shadow, both views.
  * None leaves, and exit codes and uhdm-cmp line counts are identical.
* **Away census over all 152 moved control case-views** (evidence/controls_away.txt): one flat loss in total, F/f19's
  int_typespec. Its chain context has `g=0`, so it is a pristine surplus.

**Determinism:** three concurrent verify_golden.py runs of the law binary on Earlgrey_0_1, MiniAmiq, SeqDriver,
SimpleUVM, Scoreboard and BuildUVMPkg in both modes (evidence/det_law.txt). Each of the 11 row-modes reads one hash,
equal to the law sweep's; Scoreboard testflags is a SLANG_REJECT and writes no database.

**Canaries:**
* surelog: ok=50, changed=2 (SeqDriver d/t, targeted).
* uhdm2rtlil: ok=16, changed=0.
* ctcan2 PASS on both corpora (EXPECT_UNKNOWN=1 / 6).

## The attack: 55 fresh cases (cases/), both views, the 8 configurations (evidence/vgrid_all.txt)

* 880 lines, every exit 0.
* R11U253_OFF gives pristine bytes on 110 of 110 case-views.
* 37 case-views enter STRICT_EQUAL and none leaves; no uhdm-cmp line count rises.
* The strict away census, over every moved case-view the walk can read (evidence/vaway.txt), shows no golden record
  lost. va06 is the only flat loss, and its chain contexts are `g=0` (evidence/chain_va06.txt).

Every case names its law on its first line. The cases, by law:

* **§ cloneTfItemLocalOwnVar253** (`T`, 20 cases; `D/vd01`):
  * vt01 a subroutine local read from a nested begin
  * vt02 an out-of-block class task with body io
  * vt03 a local shadowing a package variable
  * vt04 static locals with initializers
  * vt05 a Verilog-2001 function with body io
  * vt06 a for-loop bound
  * vt07 a paren-less in-class method
  * vt08 a paren-less class task (control)
  * vt09 two importers
  * vt10 a function written by a macro
  * vt11 CRLF
  * vt12 a class-handle local
  * vt13 a named block
  * vt14 a task with a local before the io
  * vt15 a function with a local before the io
  * vt16 a task with io and a static local
  * vt17 a single statement
  * vt18 an out-of-block local named like a property
  * vt19 a paren-less prototype with a parenthesised definition (control)
  * vt20 a static out-of-block method with string and queue locals
  * Result: the law fires and enters STRICT_EQUAL on every default view where the walk reads: vt01–vt04, vt06,
    vt09–vt13, vt15–vt18, vt20 and vt12_el, vt18_el. Golden binds the copy's own variable in each. The controls
    vt08 and vt19 do not fire.
* **§ cloneMintParentHomeCall253** (`M`, 9 cases):
  * vm01 a member-path receiver
  * vm02 two receivers on one line
  * vm03 delete / first / next
  * vm04 an exporting importer and a second-level importer
  * vm05 an in-class method
  * vm06 a home in a header included in two packages
  * vm07 foreach bodies
  * vm08 a paren-less function
  * vm09 a task
* **§ cloneFormalTsParented253** (`P`, 12 cases; `D/vd02`):
  * vp01 two formals in one declaration
  * vp02 output, inout and ref formals
  * vp03 anonymous struct and enum formals
  * vp04 default values
  * vp05 signed, unsigned, integer, byte and logic formals
  * vp06 in-class and out-of-block methods
  * vp07 a DPI import beside the subroutine
  * vp08 a ranged return
  * vp09 formals in the body of a paren-less function
  * vp10 unpacked, dynamic and queue formals
  * vp11 a named typedef formal (control)
  * vp12 a range written with another package's parameter
  * Result: vp02, vp05, vp06_el, vp08 and vp10 enter STRICT_EQUAL. vp01 stays endcol with distance 20 -> 12.
* **§ cloneArrTsHomeElabFirst253** (`A`, 6 cases):
  * va01 a named begin
  * va02 two blocks with same-named locals of different kinds
  * va03 a named fork
  * va04 an out-of-block method with an associative local
  * va05 two macro-written blocks at one line and column
  * va06 a paren-less function's queue plus a block queue
  * Result: va01, va02, va03 and va05 enter STRICT_EQUAL in both views. va06 moves its head later, onto the
    sister face.
* **§ cloneTfFixedArrTsParented253** (`F`, 5 cases; `D/vd03`):
  * vf01 struct, 2-D and typedef'd elements
  * vf02 a task with a static local and a parameter-sized local
  * vf03 a paren-less function
  * vf04 pattern initializers
  * vf05 two importers
* **Downstream** (`D`, drivers/dscases.sh, evidence/vds.txt): vd01–vd03, vt05 and vp02 have the same verdict on both
  binaries (IDENTICAL; vd03 is READ_FAIL in both lanes).

**Stage-1 case-views** (uhdm-cmp already unequal on pristine, a package-level difference). The strict walk is blind
here, so they were read with drivers/dumpaway.py, an order-blind line-multiset census of uhdm-dump output
(evidence/vdumpaway.txt). Every flat loss there is a dump-printing artefact of a typespec that gained its parent,
except one real face:

* **Export-chain mint, M/vm04** (residue 1 below). q imports p::*; r imports q::*; q writes `export p::*;`.
  * Golden's mint in q's copy is `p::f::seen.exists::k`, and the mint in r's copy is `q::f::seen.exists::k`.
    Surelog clones r's copy from q's copy, so the parent is q's call.
  * Pristine names them `q::...` and `r::...`: both wrong.
  * The law names both `p::...`. q's copy is now right; r's copy is still wrong, in a different way
    (evidence/vm04_mint_names.txt).
  * No object goes from right to wrong. The row is stage 1 on both binaries, and no corpus row or probe case holds
    the shape.

## Findings on the delivery

1. **Unrecorded fence breach in the implementer's byte verification.** r11u253repro/evidence/byteverify_surelog.txt
   reads `databases: patched=960 pristine=960`, and the README reports "6 of 960, selfcheck 959 / 960". The surelog
   sweep holds 960 databases, 8 of them the fenced rows'. The fence-filtered mirror holds 952.
   * So byteverify.sh ran `cmp` on the unfiltered sweep tree and opened the fenced rows' databases in both sweeps.
     This is the shape of the breach pass 236's verifier recorded.
   * The README records only the cmds.txt audit breach. drivers/bvmirror.sh is shipped, but no mirror directory exists
     under /tmp/r11u253_*.
   * Nothing about a fenced row was printed beyond the count. The verifier's own corpus byteverify ran on the
     fence-filtered mirrors.
2. evidence/predict.txt's file time (14:51) is after the law sweep (14:36). The census it formats (/tmp/r11u253_tc.log:
   42 databases) finished at 14:27, before the sweep, so the prediction holds.
3. **README count error:** r11u253repro's byte-mover section says "surelog 6 of 960 (selfcheck 959 / 960)". On the
   fenced-filtered surface it is 6 of 952.

## Residues, ranked

1. **The sister head on 4 row-modes** (#87036 / #86994 / #87006). StmtEmit, the foreach branch in the
   § cloneLoopVarHomeObject183 block: a foreach over a tf-item queue or string local, where golden's shared home loop
   variable binds the local's element typespec and ours binds `unsupported_typespec`. The same face is reached by
   va06 and r11u238 F/f19.
2. **§ cloneMintParentHomeCall253 on export chains** (M/vm04): a copy of a copy names its mint on the final home,
   where golden names it on the intermediate copy (the clone source). This needs the importer's source package; it
   is pristine-wrong too.
3. BuildUVMPkg d/t #185844, Rggen #26477 and Earlgrey are unchanged, as the implementer reports. g193_c_argface's 4
   records are the receiver index named like the call argument. vp01: two formals sharing one declaration keep an
   endcol difference after the law.
4. Stage-1 package-level faces (`keep_c` and similar) block the strict reading of 25 fresh case-views on both
   binaries.

## Process

* Every case, control, census and byte scan builds its path list and filters it by `$FENCED` (word boundary, read from
  tools/probe/r11u107repro/canaudit.sh) before opening anything. No fenced test was dispatched, read or opened outside
  the gate sweeps.
* Every tool variable is checked with `[ -x ]`.
* One waiter matched the build script with `pgrep -f '^/bin/bash /tmp/v11u253_s/build.sh'`, an anchored pattern on
  the verifier's own script. No process was signalled except the verifier's own waiter, stopped by its task id.
* drivers: env.sh, case.sh, grid.sh and gridsum.py (from r11u253repro), plus vgrid.sh, vcontrols.sh, awaygrid.sh,
  away.py (v11u202 with a fence check), dumpaway.py, dscases.sh and bvmirror.sh.
