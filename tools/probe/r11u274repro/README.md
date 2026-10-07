# r11u274 — pass 274, the expression/parameter ground (ParamEmit)

Implementer of pass 274 (pair A, refill after pass 272), base b557d7d76. Four laws, all in `src/ParamEmit.cpp`,
behind `src/R274.h` (each `R11U274_<LAW>_OFF`; `R11U274_OFF` drops all four and gives pristine's bytes on 118 of
118 grid case-views; `R11U274_TRACE=<dir>` logs every firing and every abstention, one file per process, first line
`OUT <-o path>`).

**Verdict.** No corpus row converts or moves in status (the only corpus byte mover, NoReducTypespec testflags, stays
CMP_EQUAL / strict `equal`); **SIX PROBE CONVERSIONS** and two shrinking probe changes; MiniAmiq d/t keeps
`differ:col(2)` with its bytes identical to pristine's (the heads #241741 / #243118, TaskFuncEmit's constructor return
class_var, the sister's); downstream 803 / 66 / 2 / 0 with the csv byte-identical to pristine's and to the baseline.

Fresh csv rows of the conversions (`results/` untouched):

    r10uvm187repro/g187_a_order,EQUAL,,equal            (was STRICT_NOTEQUAL differ:endcol(2))
    r11u77repro/grid/y4_bindreach,EQUAL,,equal          (was differ:endcol(2))
    r11u82repro/grid/w3_arraynet,EQUAL,,equal           (was differ:endcol(2))
    r11u88repro/grid/q12_ndaparamenc,EQUAL,,equal       (was differ:endcol(1))
    r11u88repro/grid/y1_pkgnetkind,EQUAL,,equal         (was differ:endcol(2))
    v11u114repro/grid/set1/q04,EQUAL,,equal             (was differ:endcol(1))

Changes: r11u88repro/grid/i6_ifarray `differ:endline(15) -> differ:endline(13)`, r11v77repro/grid/vh_arrelem
`differ:endline(35) -> differ:endline(33)` (both § pkgNetTsDimEnd274, first record unchanged, chain away 0, toward 2).

## The laws

### § pkgNetTsDimEnd274 (ParamEmit, the package-net listing branch beside § caPkgListingNetTypeIsPerView79) — `R11U274_PKGNETDIMEND_OFF`

Surelog lists a package net through the same `UhdmWriter::writeNets` `populateCoreMembers` end-only stretch that a
module's nets (§ defNetEndOnlyLoc130) and an importer's copy (§ importNetTsDimEnd275, ModuleEmit) take: the net's
typespec END moves to the end of the FIRST unpacked dimension (`wire [7:0] a_net [0:1];` golden 5:3-5:26, ours
5:3-5:14; `wire n [3];` golden 4:3-4:17, ours 4:3-4:7), or, with none, of the FIRST packed dimension of a
multi-dimension packed declaration (`wire [1:0][7:0] n;` golden 2:3-2:14, ours 2:3-2:19), in both package views.
A one-dimension declaration keeps the type span; a dimension end written by a macro keeps the raw column (traced
`abstain macro`; grid PN pn04 stays `differ:endcol` with 8 -> 4 objects); only the anonymous, located typespec the
branch minted for a `Net` symbol is moved (a typedef-typed net takes the alias road and is not touched, pn03).
The bucket pass 275 found and named for this ground (r11u77 y4, r11u82 w3, r11u88 y1, r11u275 IN/in02,
v11u275 vi09: all converted in both views).

### § pkgElabUnaryFoldOpSpan274 (ParamEmit emitParameters, before the param_assign op-ts stamp) — `R11U274_PKGUNARYSPAN_OFF`

The definition package listing keeps a unary initializer as an operation; the ELABORATED (top) package listing
re-compiles the value with Reduce::Yes and CompileExpression's tail stamps the reduced constant at
`populateCoreMembers(child, child, result)`: the expression node's FIRST CHILD, i.e. the operator token of a prefix
unary operation (the rule § patFlatMemberLeftSpan169 transcribes for a flattened member and
§ elabParamOpSubtreeFold86 for operand subtrees). `parameter int A = -3;` golden 2:21-2:22, ours 2:21-2:23; `~8'h0F`,
`!1'b0`, `- 3`, `-(3)`, `-'sd2`, `-32'sd7`, `-8'sd5`, `- /* c */ 9`, a second declarator `X = 3, Y = -4`, a
localparam, an `integer` the same; `(-3)` takes the operator inside the parentheses (golden 2:22-2:23, ours
2:21-2:25, first field `col`). A module listing keeps the operation in both views (un26 control); a binary
initializer is untouched (un07); an operator written by a macro abstains (un21 stays `differ:endcol`, golden 3:21-3:22,
ours 3:21-3:23 through the macro column model). Fires only on a constant Rhs parented at its own param_assign.

### § elabMemberReadCopyChain274 (ParamEmit, design-final in the deferred post-passes after § leftoverTsCopyPerElabUse272) — `R11U274_MEMREADCOPY_OFF`

Surelog elaborates every instance parameter with a DEEP clone_tree of its typespec (uniquifyTypespec); UHDM's
ElaboratorListener then binds each member element of a path `P.u.a` read in the elaborated instance (task, process,
continuous assignment) to the member of the struct the previous element's typespec resolves to, so golden's `a`
names itself through the copies (`work@dut.k0.P.pk::c_t.u.pk::in_t.a`, v11u272repro vn12_el) and `P.d` of a
parameter whose struct carries no leftover binds a copy too (`work@dut.k0.P.pk::c_t.d`, grid MR mr16). Ours copied
only an annotated struct and its annotated nested structs (§ leftoverTsCopyPerElabUse272), so the listener bound the
package listing's member (`pk::pk::in_t::a`, `pk::pk::c_t::d`). The law, in the `--elabuhdm` view only (the listener
runs there alone; the default view keeps its bytes): every hier_path of a DEFINITION rooted at a parameter of that
definition (no enclosing block, generate block, subroutine or variable declaring the name: traced `abstain shadow`)
and every hier_path of an elaborated instance (rooted at the nearest scope's parameter) walks its member names along
the instance parameter's struct; the struct is copied when it is still the shared listing, and each later member
whose typespec is a shared struct or union listing and is followed by another element takes a copy named through the
member's ref_typespec; an element the exporter already bound to a member of a replaced struct is re-bound to the
copy's member. Abstains (traced) on a struct shared with the parameter's own value constant (`value-shared`, grid MR
mr05's generate localparam), on a copy owned by another object (`shared`), on a listing a subroutine argument is typed
by (`tfarg`: § tfArgTypedefLastWriter146 / § modAggTfArgLastWriter155 move that listing's span AFTER this drain in
UhdmExporter, so a copy would keep the old span, MR mr14: a first draft lost the golden 8:36 span there, found by the
away census, refined before the freeze), and on a member leftover it cannot clone. A copy's span is re-read from its
source design-final (`memReadCopySync274`, from drainPaNameCopySrc38). Unions are walked like structs (mr07).

### § lotsCopyNestedGenWalk274 (ParamEmit lotsCopyDrain272's instance walk) — `R11U274_LOTSNESTGEN_OFF`

§ leftoverTsCopyPerElabUse272's drain walked the instances of a module's FIRST generate level only; an instance two
or more generate levels down (for/for, for/if/for, case/for) kept the shared listing where golden's instance parameter
holds its own copy (`<in>pk::c_t.u`, ours `pk`; v11u272repro vm02, vm30). The deeper levels are walked now (the
first level left to the landed loop). The trace names a firing only when the walk re-pointed a typespec of the
instance subtree (`fire`), else `abstain nochange`.

## Grid (drivers/grid.sh, drivers/case.sh, drivers/gridsum.py; evidence/grid.txt, grid_summary.txt)

53 fresh case dirs (cases/PN pn01-pn07 § pkgNetTsDimEnd274; cases/UN un01-un27 § pkgElabUnaryFoldOpSpan274;
cases/MR mr01-mr17 § elabMemberReadCopyChain274; cases/NG ng01-ng02 § lotsCopyNestedGenWalk274) plus six earlier dirs
read in place (v11u272repro VN/vn12, VM/vm02, VM/vm30; r11u272repro L/l11_slots; r11u275repro IN/in02;
v11u275repro VI/vi09), both views, each on pristine, the law, the law + R11U274_OFF and the law + each switch:
**118 case-views, 826 lines, every line with its exit code; 79 moving, 54 entering STRICT_EQUAL, 0 leaving, 0 exit-code
changes, 0 uhdm-cmp line-count changes; R11U274_OFF gives pristine's bytes on 118 / 118**; every mover returns to
pristine's bytes under exactly one switch (PKGUNARYSPAN 42, PKGNETDIMEND 18, MEMREADCOPY 11, LOTSNESTGEN 7) except
vm02_gen2level's elaborated view, which both MEMREADCOPY and LOTSNESTGEN touch (only both off restore it; distance
toward golden, chain toward 32). Away census (chain-keyed, tools/probe/r11u272repro/drivers/awaychain.py with
strictcmp_x, drivers/awaygrid.sh; evidence/away_grid.txt): **away 0 on all 79 movers**; flat away 2 on un24 (an import
read of `A = -3`, stage 1 on both binaries; chain-keyed 0).

Grid coverage: constant slots (MR mr03 dimension bound / replication count / indexed width, mr12 localparam defaults
and an implicit net, mr13 select index and indexed part-select base in a process), two instances with an override
(mr01, mr13), instance depth 1-3 (mr03 two levels, mr04 the top), nested and if/for generate (mr02, NG), shadows by a
generate localparam, a task local and a function formal (mr05, mr14), unions (mr07), arrays of structs (mr08, a
residue), interfaces and macros (mr09, mr10), a $unit typedef (mr17; mr15 stage 1 on both binaries); macro-born dimensions and operators from the
file itself and from an included header (pn04, pn07, un21, un22), queue/dynamic-free net kinds in an interface import
(pn06, stage 1 on both), two packages (un23).

## Gates (final binary 8f954c199ecf3e3187352de73ade4c66, pristine 3ddde3c0b5abae4824299578f13e9bcd = the main tree's build)

- Probe (tests/sweep.sh --corpus probe): **regressions=0 conversions=6 changes=2** (EQUAL 3748 + STRICT_NOTEQUAL 339;
  base 3742 + 345); every probe case uhdm-cmp-equal.
- Surelog: regressions=0 conversions=0 changes=0 (default 477 + 3, testflags 471 + 3); uhdm2rtlil: regressions=0
  conversions=0 changes=0 (803 / 1 / 67 both modes). Row-by-row csv diff law vs pristine: only the LowMemLib/LowMemPkg
  testflags workdir path in the detail text. Both sweeps exit 1 on the law-index staleness check alone (tests/LAWS.md
  regenerated last, in the patch).
- Downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, csv byte-identical to pristine's and to
  results/downstream_uhdm2rtlil.csv; 0 of 805 slang-lane databases move.
- Downstream on the 53 fresh case dirs (tools/probe/r11u272repro/drivers/dscases.py, both binaries): 52 IDENTICAL and
  1 EQUIVALENT (pn03, the typedef-typed package net, pre-existing) on both, the slang lane's `.il`, `_nohier.il` and
  `_synth.v` byte-identical between the binaries (159 files; evidence/downstream_cases_*.txt).
- Firing census (drivers/tracecensus.sh, frozen before the law sweep; evidence/predict.txt, md5 in predict.md5): 49
  lines, 9 databases with a firing (8 probe, 1 corpus row-mode, 0 uhdm2rtlil), the rest abstentions only.
- byteverify (fence-filtered hard-link mirrors, tools/probe/r11u272repro/drivers/bvmirror.sh, SELFCHECK=1):
  PATH_SETS_IDENTICAL 2560, **MOVERS 1 / 2560 = exactly the predicted NoReducTypespec testflags** (MEMREADCOPY; CMP_EQUAL
  / strict `equal` on both binaries, uhdm-cmp 0 lines, chain away 0 toward 3). SELFCHECK reads 2559 / 2560: every file is
  compared against one fixed file, and that file is the one not flagged (a self-check artefact, pass 201's note, not a
  mover). Probe: **8 of 4087 databases move = exactly the 8 predicted** (evidence/byteverify_probe.txt), chain away 0 on
  all 8, positive control (binaries swapped on y4_bindreach) away 2 (evidence/away_probe_movers.txt).
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 PASS on both (evidence/canaries.txt).
  Binary-path audit: 3273 of 3323 cmds.txt name each sweep's own frozen binary, the other 50 carry no slang line.
- Determinism (tools/probe/r11u272repro/drivers/det.sh, three concurrent draws): Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg, Rggen default and the testflags row-modes: one hash each, equal to the law sweep's
  (evidence/determinism.txt).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` first): 21 earlier repro dirs (r11u118, r11v11u118,
  r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u272, v11u272, r11u275, v11u275, r11u268, v11u268,
  r11u77, r11u82, r11u88, r11v77, r11u24, r11u26), both views: **2328 case-views, 106 moving, 11 entering STRICT_EQUAL,
  0 leaving, 0 exit-code or uhdm-cmp changes, chain away 0 on all 106** (flat away 1-3 on four stage-1 or still-differing
  case-views, r11u24 n9_el and v11u268 vq05 / vq06 / vq21_el; evidence/controls*.txt, away_controls.txt). A first
  controls run raced two concurrent builds of one golden (NOGOLDEN on 104 lines); case.sh now builds a golden in a
  private directory and moves it in whole, and every number above is the rerun's.

## Residues, ranked (probe residue at the base, evidence/residue_heads_base.tsv: first record and its object chain)

Ground A (this ground), not converted:
1. The call-argument read (`assign o = f(K)` with a module function): golden keeps `func_call` and K's located declared
   typespec; ours mints the loc-less bare typespec because paramCaFoldRead's whole-right-side `tryEval` harvests K
   (ParamEmit `readFold9`). Probe r11u108repro/grid/f4/c12_const_fold; scratch grid: top or child instance, `f = x`,
   `return x`, `return x + 1`, `f = 5`, `return 5` all golden `func_call` + located, while `return 32'd42` folds (and is
   stage 1 here). The exact rule of Surelog's evalFunc refusal was not decoded; a call-argument exclusion in the harvest
   is the candidate law.
2. The doubled var_select owner in a for-generate indexed part-select base (`rd[i+1][o -: 4]`: golden `work@m.g.rd.o`,
   ours `work@m.g.rd.rd.o`; 4 probe cases v11u112 b4b / b4d / b4h, v11u115 v06): for-generate only (not if-generate,
   module body, simple range or bit select); no R11U switch changes it, so the writer is a pre-pass-140 path; not located.
3. A reduction-and `&4'hF` package initializer (un10) keeps the whole span: its constant is not the param_assign's own
   Rhs when the law runs; a macro-born operator (un21).
4. The member path through an array element `P.arr[0].a` (mr08; golden copies the packed array too, the name
   `work@dut.k0.P.s_t.arr.e_t.a`), and its definition-view bit_select full name (`work@kid.P.arr[0].a.arr`, golden
   `P.arr[0]`, default view too: ExprEmit's hier_path select naming).
5. The generate-local struct localparam whose value shares the parameter's struct copy (mr05: ours names the copy
   `pk::c_t.u`, golden `work@dut.k0.g[0].P.pk::c_t.u`).
6. vm02 / vm30's P.u.a[0] in a localparam initializer (golden's P at 13:35, its bit_select named `work@kid.P.u.a[0].a`).
7. Brief items not attempted: pass 272's converted value (r11vu13 v3 / v10) and module-local function sources (m4, m7,
   a2); pass 270's inside-set range bounds (vi23), call index (vn01), I/i14, I/i25, the realtime / $time typespecs, the
   enum-alias shapes e08-e10, N/n01, N/n03; pass 268's macro shapes and override shapes; passes 266-232's lists and the
   decode's BuildUVMPkg clusters.

Sister-ground faces (reported, not written):
- TaskFuncEmit: the constructor return class_var (#241741 / #243118, MiniAmiq d/t's last records; r11u270repro C/c01).
- TypeEmit: the typedef-alias chain of a packed array of an array typedef inside a package struct parameter's member
  (`typedef ut_e [0:2] row_t; struct { row_t [0:1] U; }`: golden member typespec unnamed -> alias `q2::row_t`, ours named
  `row_t` at 4:11 -> alias; 9 probe cases r11u111 t12, r11u114 a02, r11u117 g18 / t03 / t12, v11u108 c01 / c03 / c16,
  v11u117 b02, `differ:name(8)`) and r10uvm36 t48a's `home48::w48_t` the same face; the struct-member ref_typespec full
  names of type-parameter and module-local structs (16 cases, `fullname ref_typespec/struct_typespec/typespec_member`).
- ModuleEmit emitContAssigns: the `assign o = P` struct-parameter read (22 + 3 probe cases `name ... cont_assign/ref_obj`,
  pass 272's decode); the elaborated cont_assign constant folds (12 cases `type ... cont_assign/constant`).
- UhdmExporter: the tf-argument last-writer relocation (§ tfArgTypedefLastWriter146) runs after ParamEmit's deferred
  drains, so this ground's copies cannot follow it (the reason for MEMREADCOPY's `tfarg` abstention); the macro column
  model (un21, pn04).

## Process

The implementer fence-filtered every path list before anything was opened (controls.sh, bvmirror.sh, the downstream
byte comparison), read no fenced source or database outside the gate sweeps, and signalled only its own processes: the
first firing census (run on a superseded binary) was stopped by its own pids after checking their command lines, and
every number above is from the final binary. A waiter's `pgrep -f` matched its own command line once (read as
`running`; the grid output was complete) and was not used again. Superseded binaries: law1-law12 (the MR law's
definition-path rewrite, the shadow index, the value-shared, tfarg and span-sync refinements, the trace of the nested
walk); the census, grid, controls and sweeps were all rerun on the final one.

Files: drivers/case.sh, grid.sh, gridsum.py, awaygrid.sh, controls.sh, ctlsum.py, tracecensus.sh (from r11u272repro);
the away census, bvmirror, det.sh and dscases.py are used in place from tools/probe/r11u272repro/drivers.
