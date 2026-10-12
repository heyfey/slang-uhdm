# v11u295 — adversarial verification of r11u295 (module/type ground: escaped-name spans, raw ends through the line model, the nested module array's scoped name, dynamic and associative struct-member spans)

Base 2baa2091 (pass 293). The implementer's patch lands four laws behind `src/R295.h`. This pass rebuilt both binaries
and reproduced every headline number. Fresh cases then found **one break**: § nestedModArrayScopedName295 moves a
record away from golden when a file-scope definition shares the nested module's name. The fix is one refinement,
**§ nestArrShadowTopKeepsBare295v** (ModuleEmit emitModuleArray, switch `R11V295_NESTSHADOW_OFF`; `R11V295_OFF`
drops every refinement of this pass and gives the law's bytes; `R11U295_OFF` still gives pristine's bytes). It moves
no gate database: 0 of 2560 corpus, 0 of 4087 probe and 0 of 805 downstream slang-lane databases differ between the
law and the fix.

**Verdict: VERIFIED WITH ONE PRODUCTION FIX.** The five probe conversions reproduce bit for bit in both views (probe
3941 + 146 -> 3946 + 141, regressions 0, changes 0). No corpus row moves.

| target | base | law | fix | law |
|---|---|---|---|---|
| r10earl54repro/v3_v54 | `endcol(5)` | EQUAL | EQUAL | § escNameSpanSites295 |
| v11u110repro/brk/v3/a36_escaped_inst_name | `endcol(1)` | EQUAL | EQUAL | § escNameSpanSites295 |
| r10v223repro/arms/v5_escaped | `endcol(2)` | EQUAL | EQUAL | § rawEndLineModel295 |
| v11u93repro/grid/b07_rv2arr | `fullname(1)` | EQUAL | EQUAL | § nestedModArrayScopedName295 |
| r10earl29repro/v10_str | `endcol(4)` | EQUAL | EQUAL | § dynAssocMemberSpanToDim295 |

All five read STRICT_EQUAL in the elaborated view too, with uhdm-cmp at 0 lines on all three binaries
(evidence/probe_targets.txt). The away census over the ten case-views reads lost 0 and chain away 0, with 27 records
moving toward golden (evidence/probe_movers_away.txt).

## The break and the fix — § nestArrShadowTopKeepsBare295v (switch `R11V295_NESTSHADOW_OFF`)

**The face.** cases/VN/vn09_nested_shadows_toplevel: a file-scope `module inner` beside `module outer;
module inner ...; inner u_i [1:0] (...)`. Golden's elaborated module_array under work@top.u_o reads full name
`work@inner`. The law wrote `work@outer::inner`. The chain-keyed away census reads **away 1** in both views, where
pristine was right on that record. The case reads uhdm-cmp stage 1 on every binary: Surelog elaborates the
file-scope `inner` there, while slang and ours elaborate the nested one (an LRM-correct binding that we keep).

**The decode.** Surelog's DesignElaboration looks the instantiated module up as `work@<name>` first. It falls back to
`<parent definition>::<name>` only when that lookup misses (the `libs` loop just before the module_array is built).
The module_array's VpiFullName is whichever modName the lookup settled on. So when a file-scope component of the same
name exists (a module, or an interface as in vn12), golden keeps `work@<name>`.

**The refinement.** Inside the law's branch, when `comp.tryGetDefinition(name, root)` finds a file-scope definition
other than the nested one, the law steps aside and keeps the bare name. Its trace tag is
`nestArrShadowTopKeepsBare295v`.

| case (first line `// § nestArrShadowTopKeepsBare295v`) | pristine | law | fix |
|---|---|---|---|
| VN/vn09_nested_shadows_toplevel d/e | stage 1 | stage 1, chain away 1 | pristine's bytes |
| VN/vn11_shadow_top_uninst d/e (file-scope `inner` not instantiated) | stage 1 | stage 1, flat away 1 | pristine's bytes |
| VN/vn12_shadow_top_iface d/e (file-scope `interface inner`; golden `work@inner`) | stage 1 | stage 1 | pristine's bytes |

Downstream verdicts do not change on any of them: vn09 is IDENTICAL, vn11 EQUIVALENT and vn12 STATUS_DIFF on all
three binaries.

## Reproduction (binaries frozen read-only before any measurement)

- **Binaries**: pristine 4d4a234d (equal to the main tree's build at the base), law c8c36f21 (equal to the
  implementer's), fix 73236433, uhdm-strictcmp fa6e4f42. All are built with the system-deps config at -j 1 or -j 2.
  The binaries report slang 12.0.0+545f88b2e.
- **Gate sweeps** (tests/sweep.sh --jobs 3; evidence/sweep_P.log, sweep_L.log, sweep_F.log):
  - probe: pristine 3941 + 146; law and fix **3946 + 141**, regressions 0, conversions 5 (the five above), changes 0.
  - surelog: default 480 + 0 / testflags 474 + 0 CMP_EQUAL; uhdm2rtlil 803/1/67 in both modes. 0 regressions,
    conversions and changes on all three binaries.
  - The three surelog csvs differ only in the LowMemLib and LowMemPkg testflags detail text, which carries the
    workdir path. The uhdm2rtlil csvs are identical. The probe csvs of law and fix are identical.
  - Every sweep exited 1 on the law-index check alone. The base's own tests/LAWS.md already reads stale in a fresh
    worktree.
- **Downstream** (run one at a time): pristine and fix both read 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT /
  0 DIVERGENT. The fix csv is byte-identical to the pristine csv and to results/downstream_uhdm2rtlil.csv
  (evidence/downstream_fix.csv).
- **Firing census** (drivers/tracecensus.sh, frozen before each sweep): the law's predicted set is exactly the five
  probe databases and 0 corpus row-modes, identical to the implementer's predict.txt (evidence/predict_law.txt). The
  fix's census is the same five, and the refinement fires nowhere in the gate (evidence/predict_fix.txt). Its
  positive control is the three VN cases above, where it fires.
- **byteverify** (fence-filtered hard-link mirrors, SELFCHECK=1; same-length workdirs):
  - corpus: pristine -> law, law -> fix and pristine -> fix each move 0 of 2560 (PATH_SETS_IDENTICAL; SELFCHECK
    2559 of 2560, the known artefact).
  - probe: pristine (re-run from the law worktree so the embedded source paths match) -> law moves exactly the five
    predicted of 4087; law -> fix moves 0. The selfcheck flags 4087 of 4087.
- **Canaries**: surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0 on every binary. ctcan2 EXPECT_UNKNOWN=1
  (surelog) and EXPECT_UNKNOWN=6 (uhdm2rtlil) PASS on all three.
- **Binary-path audit**: 3315 fence-filtered cmds.txt per sweep, 3265 naming that sweep's own binary, 0 naming
  another, and 50 carrying no slang line.
- **Determinism** (drivers/det.sh, fix binary): three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen read one hash each. Each hash equals both the pristine and
  the fix sweep's hash (Scoreboard and Rggen testflags write no database) (evidence/determinism.txt).
- **The implementer's grid** (64 case dirs, 128 case-views, re-run here on the frozen binaries): every strict, rc and
  cmplines field is identical to the implementer's evidence/grid.txt. The md5 values differ only through the embedded
  worktree path. 96 moving, 70 entering STRICT_EQUAL, 0 leaving. `R11U295_OFF` restores 128 of 128. The per-switch
  attribution matches: ESCNAMESPAN 38, RAWEND 30, DYNMEMSPAN 22, NESTARRNAME 6 (evidence/impl_grid_rerun*.txt).

## Attack: 103 fresh case dirs in both views (206 case-views; every line with its exit code)

Families: VE (escaped-name sites), VR (raw ends), VN (nested module arrays), VD (dynamic and associative members).
Every case's first line names its law. Configurations: P, L, OFF and each law switch off (evidence/grid.txt); F, F
with `R11V295_OFF`, F with `R11U295_OFF`, and F with `R11V295_NESTSHADOW_OFF` (evidence/grid_fix.txt).

| step | moving | entering STRICT_EQUAL | leaving | exit-code changes |
|---|---|---|---|---|
| pristine -> law | 178 | 131 | 0 | 0 |
| pristine -> fix | 172 | 131 | 0 | 0 |
| law -> fix | 6 | 0 | 0 | 0 |

- The law -> fix movers are vn09, vn11 and vn12 in both views.
- Switch checks hold on 206 of 206 case-views: `R11V295_OFF` gives the law's bytes, `R11U295_OFF` gives pristine's,
  `R11V295_NESTSHADOW_OFF` gives the law's, and the law's OFF gives pristine's.
- Each pristine -> law mover is restored by exactly one switch (RAWEND 80, ESCNAMESPAN 44, DYNMEMSPAN 34,
  NESTARRNAME 16). Two cases need a pair: VN/vn10 (an escaped nested array, ESCNAMESPAN with NESTARRNAME) and VR/vr51
  (ESCNAMESPAN with RAWEND).
- **Away census** pristine -> fix over all 172 movers: lost 0, chain away 0, 485 records toward golden
  (evidence/fresh_away_pristine_fix.txt). The positive control (binaries swapped) reads away 1 to 8 on 8 of 8
  (evidence/fresh_away_poscontrol.txt). Under the law, vn09 reads chain away 1 in both views, which is the break.
- **Downstream** (drivers/dscases.py on the 98 single-file dirs; evidence/downstream_cases_{P,L,F}.txt): no verdict
  changes on any binary.

Shapes the laws pass (pristine wrong, fix STRICT_EQUAL unless noted):
- ESCNAMESPAN: a simple identifier written escaped (`\u1 `); an escaped instance with a parameter override, after an
  escaped reference on the same line, in a bind, an array with an escaped formal, an instance in an included header,
  a property, a program instance, CRLF with two blanks, a comment after the name, an interface instance, a tab
  before the name, `.*` connections, two escaped instances on one line; named escaped formals on modules, programs
  and interface ports.
- RAWEND: the definition-net initializer with an escaped identifier inside or before it on the line, a multi-line
  macro body, a macro with arguments split over lines, a paste, a based-literal squeeze, two macro ends on one line,
  a header macro, ten declaration kinds with a header macro or an escaped neighbour, an interface or a program body,
  CRLF, and tabs. The import copy covers a macro with arguments, a macro in the middle, nested macros, a
  stringification, a multi-line body, a dimension from a macro (whole and partial), an escaped neighbour, a header
  macro across two files, and an interface importer. The deferred-port element covers an escaped neighbour and a
  macro type.
- NESTARRNAME: a parameter override, the same nested name in two outer modules, the top itself, a 2-D array, a
  file-scope array beside a nested one, and an escaped nested array.
- DYNMEMSPAN: `[]` of fixed, assoc of queue, a class property's struct, an escaped member, `[ * ]`, a macro index, a
  multi-line dimension, an escaped neighbour, byte and longint indices, comma members, CRLF, and package members over
  two lines.

Cases that move only at stage 1, toward golden (lost 0, chain away 0): vd01, vd02, vd15, vd17, ve09, ve17, ve18, ve28,
vr04, vr05, vr12, vr13, vr14, vr29 (default view), vr33, vr45 to vr47, vr49. vd12 and vr37 move toward golden but
still read endcol on another object: the inline struct variable's struct_typespec, and a Verilog-mode escaped
logic_var.

Unmoved controls: ve05 (a bind), ve10, ve15, ve19 (generate routes), vr01, vr02, vr26, vr36, vr41 (no line shift),
vr08 and vn01 (stage 1), vd05 (fixed of assoc). vd07 exits 3 and vn02 exits 139 on every binary.

## Byte controls (fence-filtered path lists; pristine vs fix; evidence/controls_pristine_fix.txt)

- **Scope**: 41 earlier repro dirs, 3882 case dirs, 7764 case-views. These are the implementer's 17, the mandated
  r11u118/r11v11u118/r11u119/r11u120/r11v120/r11u124/r11v124/r11u131/r11v131, and every dir holding escaped
  identifiers (v11u286, r11u153verify, r11u229verify, r11u220, r11u286, r11u162verify, r11u159verify, v11u220,
  r11u226verify, r11u170verify, v11u207, r11v167, r11u268, r11u160, r11u166mac).
- **Result**: 20 moving and 10 entering STRICT_EQUAL:
  - r11u159verify pc/q02_escaped_inst
  - r11u171repro K/k12_stringified_neighbour
  - r11v120repro T/t05_escaped_inst
  - v11u146repro esc/x2_inst
  - v11u291repro VT/vt14_escaped_inst (each in both views)
- **Other changes**: 0 leaving, 0 exit-code changes, 0 uhdm-cmp line-count changes. r11v124repro/rx/r01_macro moves
  endcol -> name, with its macro real literal's record now right and nothing lost. Lost 0 and chain away 0 on all
  20, with 30 records toward golden (evidence/controls_away.txt).
- **Law vs fix**: the law binary over the same 7764 case-views differs from the fix on 0
  (evidence/controls_law.txt).

## Residues (ranked; all wrong on pristine too)

1. **The nested-module crashes**: the implementer's NA n02 and n07, plus VN/vn02_outer_in_genfor (an outer module
   holding a nested module array, instantiated in a for-generate). All exit 139 on every binary. ModuleEmit, this
   ground.
2. **Surelog's file-scope-first binding**: vn09, vn11 and vn12 read uhdm-cmp stage 1 because Surelog elaborates the
   file-scope module. That is not copied.
3. **A nested module array inside a generate block** (vn01): stage 1, and the law does not fire there.
4. **Dynamic member leftovers**: vd12, an inline (untypedef'd) struct variable's struct_typespec ending at `struct`;
   golden's `unsupported_expr` for `[]` (vd02, the implementer's DM d03/d06/d07/d08); assoc indices typed by a
   typedef or a class (vd01, vd17 stage 1); an interface typedef (vd15).
5. **Verilog-mode escaped declarations** (vr13, vr37: the logic_var span) and the `var` declarations (vr45 to vr47
   stage 1 on the var's typespec).
6. The implementer's residues 2 to 7 stand as listed in tools/probe/r11u295repro/README.md.

## Process

- The fence was read fail-closed from the FENCED= line of r11u107repro/canaudit.sh (drivers/env.sh) and never
  spelled. Every corpus or database path list was filtered before any file was opened: the mirrors, the cmds.txt
  audit, the probe byte compares and the controls. Nothing fenced was read or run, and the main tree was not written.
- **SLIP, no effect**: one helper command used a scratch file named /tmp/x (not pass-prefixed). It was renamed into
  the pass scratch at once.
- **SLIP, no effect**: one shell line ran `grep ''` with an empty file list and waited on stdin. It was stopped by its
  own task id, having read nothing.
- No other agent's process was listed or signalled.
