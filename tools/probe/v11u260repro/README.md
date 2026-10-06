# v11u260: adversarial verification of r11u260 (pass 260, the expression/parameter ground)

Base a609e392 (pass 258). Implementer's patch /tmp/r11u260.patch (md5 8def411f37d3451a18be43faeb860b36), three
laws in `src/ExprEmit.cpp` behind `src/R260.h`: § pkgSelPsBoundColonsElab260 (`R11U260_PSELELAB_OFF`),
§ shadowedImportTsRefOwner260 (`R11U260_SHADOWTSOWNER_OFF`) and § castStructInstCopy260
(`R11U260_CASTSTRUCTCOPY_OFF`); `R11U260_OFF` drops all three.

## Verdict

ACCEPT, NO PRODUCTION FIX. Every headline number of the implementer reproduces bit for bit on binaries I built
myself. No break was found on legal SV: no probe case, corpus row or downstream row moves away, no strict cell gets
worse, and no record is lost in any away census. The production code in the verified patch is the implementer's,
byte for byte. The verified patch adds this directory, three corrections to the implementer's README (below) and
the regenerated `tests/LAWS.md`.

NO CORPUS ROW CONVERTS. The fresh csv rows of the two changed row-modes:

    Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:file(34),,differ:file(34)        (base: differ:fullname(36))
    Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(20),,differ:fullname(20)  (base: differ:fullname(4))

## Binaries (gate 1)

| binary | md5 | note |
|---|---|---|
| pristine (fresh worktree at a609e392) | c84be26c6817dd700c631e458e1683f6 | equal to the brief's pin and the implementer's |
| law (a609e392 + /tmp/r11u260.patch) | 395ec3e583221d108d2e0c2f5042143b | equal to the implementer's |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | same in both worktrees |

Both binaries report slang 12.0.0+545f88b2e. All three were copied and set read-only (chmod 555) before any
measurement. Binary-path audit (drivers/binaudit.sh, the path list filtered by `$FENCED` before any file is opened;
evidence/binaudit.txt): in each sweep, 3315 cmds.txt, 3265 name that sweep's frozen binary, 0 name another, 50 have
no slang line, and 8 fenced paths are skipped unread.

## Reproduction of the implementer's numbers

Every row below matched the implementer's report exactly.

| item | result |
|---|---|
| firing census (drivers/tracecensus.sh on my frozen law binary, frozen 2026-10-06T06:16:27-04:00 before my law sweep) | md5 0dd5978c413289693277bef80b7908ef, IDENTICAL line for line to the implementer's predict_frozen.txt: 7 movers (Earlgrey d/t, ConstantBits d/t, uhdm2rtlil CastStruct d/t, downstream CastStruct), 0 probe |
| gate 2, probe | `EQUAL=3566 STRICT_NOTEQUAL=521`, regressions=0 conversions=0 changes=0; csv identical to pristine's |
| gate 3, surelog | regressions=0 conversions=0 changes=2 (the two Earlgrey rows above) |
| gate 3, uhdm2rtlil | 1606 of 1606, regressions=0 conversions=0 changes=0 |
| gate 4, downstream | `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)`; csv identical to pristine's and to results/downstream_uhdm2rtlil.csv |
| pristine sweep | reproduces every baseline: 0 / 0 / 0 in all three stages |
| other csv differences | only the LowMemLib / LowMemPkg testflags detail text, which embeds the workdir (evidence/csv_rowdiff_P_vs_L.txt) |
| gate 5, uhdm-cmp | 0 lines on all six corpus movers |
| gate 6, byteverify (fence-filtered hard-link mirrors, same-length workdirs) | PATH_SETS_IDENTICAL, MOVERS 6 / 2560, exactly the predicted six; Earlgrey hashes 0d28327c9ef4 / a603c2abcb02 as the implementer's |
| probe databases | 0 of 4087 move |
| downstream databases (slang lane) | 1 of 805 moves, CastStruct, IDENTICAL on both binaries |
| chain-keyed away census (drivers/awaychain.py with the variant comparator) | Earlgrey d 0 away / 11 toward, t 0 / 61; ConstantBits and CastStruct 0 / 0 |
| canaries | surelog ok=50 changed=2 (the Earlgrey rows); uhdm2rtlil ok=16; ctcan2 surelog (EXPECT_UNKNOWN=1) PASS, uhdm2rtlil (EXPECT_UNKNOWN=6) PASS |
| determinism (drivers/det.sh, three concurrent draws per binary) | Earlgrey_0_1 and the five UVM rows: one hash on every row-mode on both binaries, equal to the sweeps' hashes; Scoreboard testflags has no database, as at the base |
| implementer's grid (73 case dirs, rerun on my binaries) | 876 lines; every verdict field identical to the implementer's grid.txt (the md5 field differs only because the case path is in the database); 146 case-views, 57 moving, 23 entering STRICT_EQUAL, none leaving; `R11U260_OFF` pristine on 146 of 146; E/e04 rc 4 on both binaries |
| away census of those 57 movers | 0 lost on all 57 |
| downstream on the 73 case dirs | 73 IDENTICAL on both binaries |
| byte controls (the implementer's 20 dirs, drivers/controls.sh) | 3132 case-views, 15 moving, 8 entering STRICT_EQUAL, none leaving, no exit code or uhdm-cmp line count changing; the same 15 movers; away census 0 lost on all 15 |

The probe databases of my two sweeps differ wholesale because I ran the pristine sweep from the pristine worktree:
the case path is stored in each database and the two worktree paths have different lengths. I re-swept the probe
stage with the pristine binary from the law worktree, and that comparison reads 0 of 4087.

SELFCHECK reads 2559 of 2560. The self-check compares every database with one fixed database. That file cannot flag
itself, so 2559 is the expected reading and is not a mover line.

Positive control for the census: the probe harness passes `R11U260_TRACE` through to the binary. A wrapper used as
`SLANG_UHDM` on one probe case logged the variable on the dispatched command. The surelog and downstream lanes show
firings in the census itself.

The Earlgrey first records (evidence/earlgrey_*_records.txt):

    base default   #233633 fullname ref_typespec  golden work@rstmgr_ctrl   ours work@rstmgr_ctrl.rst_req_i
                   #233638 fullname (the same, ours work@rstmgr_ctrl.rst_parent_synced), then #395727 onward
    law  default   #395727 file  enum_const WB_INSTR_OTHER  golden ibex_pkg.sv 179:3-179:17  ours no file
                   (the old #233633 / #233638 cleared; every later record the base already had)
    base testflags #216212 / #235310 / #235315 fullname, #403326 depth
    law  testflags #446024 fullname ref_typespec  golden work@top_earlgrey.u_ram1p_ram_main  ours work@top_earlgrey
                   #530951 / #530956, #580520 to #594077 (12) fullname, #604623 / #604627 / #604631 file
                   (int_typespec golden flash_erase_ctrl.sv 9:13, ours flash_ctrl_pkg.sv 18:14), #604991 depth

The testflags count grows from 4 to 20 because the base's walk stopped at #403326 and the law's walk runs to
#604991. None of the 20 is an old record, and the chain-keyed census reads 0 away.

## Widened controls

18 more repro dirs, 2220 new case-views (evidence/controls_wide_summary.txt; the summary's 2308 counts r11u120
twice, since I passed it to both runs). The dirs are r11u259, v11u259, r11u257, v11u257, r11u255, v11u255, r11u251,
v11u251, r11u250, v11u250, r11u248, v11u248, r11u246, v11u246, r11u244, v11u244, r11u242 and v11u242. Result: 0
moving, 0 entering or leaving, no exit code or uhdm-cmp line count changing.

## Attack: 63 fresh case dirs in both views (cases/VC, VS, VX)

Every case names its law in its first line. Each ran on six configurations (pristine, law, law with `R11U260_OFF`,
and the law with each switch off), 756 lines, every line carrying its exit code (evidence/grid_fresh.txt,
gridsum_fresh.txt).

Totals over 126 case-views:
- 59 moving and 7 entering STRICT_EQUAL. None leaves STRICT_EQUAL, no exit code changes, and no uhdm-cmp line count
  changes.
- `R11U260_OFF` gives pristine's bytes on 126 of 126.
- Each mover is moved by exactly one switch: CASTSTRUCTCOPY 28, SHADOWTSOWNER 22, PSELELAB 9.
- vc04 and vc12 exit rc 4 on both binaries: an Invalid expression with two instances of a casting module, the same
  pre-existing face as the implementer's e04.
- Away census (drivers/awayall.sh, evidence/away_fresh.txt): 0 lost on all 59 movers.
- Downstream (drivers/dscases.py, evidence/downstream_cases_{P,L}.txt): the same verdict on both binaries for all 63
  dirs: 58 IDENTICAL, 4 EQUIVALENT (vc04, vc06, vc22, vs14) and 1 DIVERGENT (vx03).

**VX, § pkgSelPsBoundColonsElab260** (17 dirs, 34 views):
- 9 moving and 7 entering STRICT_EQUAL, all in the elaborated view: vx01_body_param (a body parameter in a module
  without a header list), vx02_task, vx07_untyped_param_ca (an untyped parameter at depth 2), vx11_shift_bound,
  vx13_top_param_elab, vx14_iface_param_module and vx16_inst_in_for_gen (a module instantiated in a for-generate
  with a genvar override).
- vx03_iface_func_el moves and is stage 1 on both, 2 golden lines gained and 0 lost.
- vx17_class_spec_bound_el clears the module-parameter record. The `cp::C#(6)::W` bound abstains ("abstain node")
  and keeps its pre-existing record.
- Unmoved: vx04 (a for-generate process), vx05 (a parameter inside a nested part select of the element index),
  vx08 (a parameterized package class), vx09 (a package function), vx10 and vx15 (generate bodies), and vx06, vx12
  (already STRICT_EQUAL).

**VS, § shadowedImportTsRefOwner260** (22 dirs, 44 views):
- Moving fullname -> line in both views: vs01 (a declaration dimension plus a part-select bound), vs06 (instance
  depth 3, two instances, a replication count), vs07 ($clog2 inside an indexed part-select width), vs10 (the `-:`
  base in an always_ff), vs11 (a body wildcard import), vs12 (a struct member's part select), vs18 (both bounds of
  one select), vs19 (a loop's indexed part-select width) and vs20 (the module instantiated in a for-generate). The
  remaining line record is the implementer's residue 1.
- vs14 (an overridable header parameter, overridden in one instance) and vs22 (a module-local class beside a
  module assignment) are stage 1 on both and move toward golden (2 gained, 0 lost).
- Unmoved, stage 1 on both: vs03 (interface), vs04 (for-generate), vs05 (function), vs08 (nested replication),
  vs09 (case-generate), vs13 (port actual), vs15 (if-generate), vs16 ($bits / $unsigned), vs17 (task).
- Unmoved, not stage 1: vs02 (a $clog2 localparam initializer) and vs21 (a named user-call argument).

**VC, § castStructInstCopy260** (24 dirs, 48 views):
- Moving with STRICT_EQUAL on both (the copy invisible to the canonical walk, record distance 0 -> 0): vc03 (two
  casts), vc05 (a wildcard-imported package typedef), vc10 (a signed struct with enum and typedef members), vc14 (a
  concatenation and a ternary), vc15 (a 2-D packed array of a package struct, a packed union), vc18 (an interface
  member), vc20 (two modules each with their own t_t) and vc23 (an implicit net).
  - On vc05, uhdm-dump lines move toward golden: the package listing struct keeps its package parent and golden's
    `p::p::t_t::a` names, where pristine re-parented the listing at the cast.
- Moving with stage 1 on both: vc04, vc06, vc07, vc12, vc22 and vc24 (findings 1 and 2).
- Unmoved: vc01 (always_ff), vc02 (a call argument), vc08 (a port actual), vc09 (an if condition and a case
  expression), vc11 (one for-generate level), vc13 (a task), vc16 (an if-generate typedef), vc17 (the top module),
  vc19 (an instance in a for-generate) and vc21 (initial and unique case).

Illegal-SV rewrites, all before any law measurement of the rewritten case:
- vc02 and vc09: a member select of a cast result, which Surelog rejects.
- vx16: two always_comb blocks driving one variable.
- vs02: a header default reading a name declared later in the body, which slang rejects with rc 3 on both binaries
  (so it moved nothing). Rewritten and regridded.

## Findings (none is a break; all are invisible to every gate)

1. **The struct copy is unparented and its member names are not golden's** (§ castStructInstCopy260;
   evidence/findings_copy_names.txt).
   - The law sets the copy's parent to the cast's ref_typespec and names the member references
     `<scope>.<typedef>.<member>`.
   - The delivered database holds the copy with NO parent and its member references named `t_t.x`. Golden has
     parent `ref_typespec (work@top.u)` and `work@top.u.t_t.x`.
   - The writer is UhdmExporter typedefParentModel134, which re-derives typedef parents after emission. On e01,
     `R11U134_DBG=1` prints `TDPARENT t_t -> (none)`, and its rename of the names below a typespec_member then rewrites
     the members.
   - The strict walk records neither a parent nor a full name inside a typespec copy. It reads e01 STRICT_EQUAL and
     the dump distance grows by 4 lines per copy (e04, vc04, vc12, vc22, vc24: the two member references and their
     names).
   - The implementer's README explained e04's 3 -> 7 dump distance as golden's leaf-typespec copies. It is these 4
     name lines. I corrected that README in place, marked "Verifier correction, v11u260".
   - The fix is in typedefParentModel134 (UhdmExporter, the sister ground): leave the cast copies out of its re-parent
     and rename.
2. **The copy also fires where golden has no struct** (§ castStructInstCopy260).
   - vc06: a cast to `p::C::t_t`, a struct typedef in a package class. Surelog writes an unsupported_typespec there,
     and the law copies the struct pristine already bound. The dump distance goes 20 -> 56 (36 lines golden lacks),
     with 0 golden lines lost and the uhdm-cmp line count unchanged at 86.
   - vc07: a typedef of a struct typedef. Golden copies both u_t and t_t at the struct's span 3:11; ours makes one
     copy at the alias's span 4:11-4:14, which is the listing's pre-existing span. The distance goes 17 -> 24 with 32
     golden lines gained and 0 lost.
   - Both cases are stage 1 on both binaries. With pristine wrong first and no record lost, these are residues, not a
     break.
3. **§ pkgSelPsBoundColonsElab260 also renames references in our elaborated generate scopes** (r11u254
   Q/q05_gen_scopes_el).
   - Golden folds those bounds to constants, so it has no such references. Ours keeps four, and the law renames them
     from `work@top.gen_fwd[k].gi.cp::RC.cp::RC.W` to `cp::RC::cp::RC::cp::RC::W`.
   - Neither spelling is golden's: record distance 4 -> 4, dump distance 214 -> 214, 0 lost.
   - The law's premise ("only the definition listing holds the reference") does not hold in our generate scopes. The
     underlying face is that ours does not fold a generate-scope part-select bound where golden does: the implementer's
     residue 4, "generate bodies".
4. **README count**: the frozen prediction holds 20 abstain-only surelog testflags rows, where the implementer's
   README said 22. Corrected in place.

## Residues, ranked

1. **The shadowed import fold's int_typespec location** (ExprEmit § shadowedImportParamFold, this ground):
   - Earlgrey testflags #604623 / #604627 / #604631.
   - Every VS mover that leaves stage 1 keeps this `line` record: golden at the module's own `localparam int`, ours at
     the package's.
   - Not attempted (the implementer's residue 1).
2. **Earlgrey testflags #446024**: pass 256's #464077 face in the if-generate ips width.
3. **Earlgrey testflags #530951 / #530956**: the #600811 fill-constant face.
4. **§ castStructInstCopy260 on golden's unsupported_typespec and alias-chain casts** (vc06, vc07; finding 2), and
   two for-generate levels (the implementer's e19).
5. **§ shadowedImportTsRefOwner260's stage-1 contexts**, pre-existing on both binaries: interface, for-, if- and
   case-generate, function, task, port actual, nested replication, $bits.
6. **§ pkgSelPsBoundColonsElab260's unmoved shapes**: package-class and package-function bounds (vx08, vx09),
   generate processes (vx04, vx15, q05), and a class specialization's parameter (vx17).
7. **The brief's items (2) to (7)**: not attempted by the implementer; out of scope for this verification.

## Sister-ground faces (call sites; not written)

- Finding 1: UhdmExporter typedefParentModel134 (the typedef re-parent and the rename below a typespec_member)
  unparents and renames the cast copies.
- Earlgrey default #395727: an enum_const without a file (the new head).
- Earlgrey default #620047 to #620111: ModuleEmit dottedLhs, the tlul_socket_1n shared cont_assign. #658559 onward:
  the tlul_err_resp cont_assign order.
- Earlgrey testflags #580520 to #594077: the typespec_member bound under the port actual
  `reg2hw.mp_region_cfg[0].en.q`, ModuleEmit's port connection (the implementer's decode, not re-decoded here).
- MiniAmiq / SeqDriver #126482 / #127418 (UhdmExporter) and Rggen #92960 (ModuleEmit § genLpUnpackedArray): the
  databases of the five UVM rows are byte-identical on both binaries.

## Process

- Worktrees: /tmp/wt_v11u260 (law) and /tmp/wt_v11u260pris (pristine), both fresh at a609e392. Scratch:
  /tmp/v11u260_*.
- Build: each binary with -j 1. The pristine binary was frozen before any measurement. No source was edited while a
  build ran, and src was never edited.
- Build launch slip: my first launch started both builds from one backgrounded shell, and only the pristine build
  ran. The law build was relaunched on its own before anything was measured.
- Golden prewarm slip: one prewarm of two cases ran with `SURELOG` unset. `timeout` failed to start the command
  (no tool ran and no database was executed), and the failure markers were written only in my scratch golden
  store. They were removed and the two goldens rebuilt.
- Sweeps: the census ran first, then the pristine sweep, then the law sweep, one at a time, each with `--jobs 3`
  and its own workdir.
  - Both sweeps exit 1 only on the law-index check. On the pristine sweep this is the committed index's one-landing
    lag. On the law sweep it is because my cases did not yet exist in the patch's index. The index is regenerated in
    the verified patch.
- The fence:
  - Every corpus path list (mirrors, cmds.txt audit, probe and downstream mover lists) was built and filtered by
    `$FENCED` (word boundary, read from canaudit.sh's FENCED= line) before any file was opened.
  - The census ran with the drivers' `$FENCED` filters.
  - The only corpus databases opened outside the gate sweeps are the six named movers and the determinism rows.
  - Nothing fenced was dispatched, read or opened outside the gate sweeps.
  - The whole-word scan for the fenced names reads 0 on this directory and on the verified patch.
- No process was signalled. Every tool call through a variable was guarded with `[ -x ]`.

## Files

- `cases/VC` (24 dirs), § castStructInstCopy260.
- `cases/VS` (22 dirs), § shadowedImportTsRefOwner260.
- `cases/VX` (17 dirs), § pkgSelPsBoundColonsElab260.
- `drivers/`: the implementer's drivers copied (case.sh maps this directory's cases to `V/...` store keys).
  - grid.sh per case dir; controls.sh, ctlsum.py; awayall.sh, away.py, awaydump.py; awaychain.py with cc_x.sh /
    strictcmp_x.cpp; tracecensus.sh; bvmirror.sh, binaudit.sh; det.sh; dscases.py; rowhead.sh.
  - Source `drivers/env.sh` with `B` (the frozen binaries) and `S` (scratch) exported.
- `evidence/`: the census and its freeze time; sweep summaries and csv row diffs; binaudit; byteverify; probe and
  downstream movers; canaries; det; the Earlgrey records (P and L, both modes); the implementer's grid rerun and the
  fresh grid with their summaries; the away censuses (corpus, implementer grid, controls, fresh); control summaries;
  downstream on the cases; findings_copy_names.txt.
