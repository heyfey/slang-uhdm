# v11u284 — adversarial verification of r11u284 (pass 284, the expression/parameter ground)

Base 75e43718.  Implementer's patch /tmp/r11u284.patch (six laws plus one refinement switch behind src/R284.h, in
ParamEmit and ExprEmit).  **Verdict: every headline number reproduced bit for bit; ONE BREAK on legal SV found by
fresh cases and fixed (§ hpSelPortOrphanSibling284v), ONE over-reach of § pkgAliasTdRefNameByParent284 decoded and
narrowed (§ aliasWriteModuleScope284v).  The fix binary's gate sweeps are byte-identical to the law's (0 of 2560
corpus, 0 of 4087 probe, 0 of 805 downstream databases differ), so the ten probe conversions and three changes
stand unchanged.**  Delivery: /tmp/r11u284.verified.patch.

## Binaries (frozen under /tmp/v11u284_bin before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine | 884cf2ee5872967740255962bcd3a381 | built in /tmp/wt_v11u284pris at 75e43718, equal to the main tree's base build and the implementer's |
| law | 91ba5bad5055a2afd6e3e88bb9762c93 | /tmp/r11u284.patch applied on fresh 75e43718, equal to the implementer's |
| fix | 33a34347d5eb6d57ccd699f13bc97de4 | law + the two refinements below |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | equal to the main tree's |
| strictcmp_x | 886f030233ecdbcce7d0e29ac0c4df2c | tools/probe/r11u273repro/drivers/cc_x.sh, equal to the implementer's |

## Reproduction of the implementer's numbers (my sweeps /tmp/v11u284_wP, _wL, _wF; same-length workdir names)

- **Probe** (law): EQUAL 3873 + STRICT_NOTEQUAL 214, regressions 0, conversions 10, changes 3 against
  results/golden_probe.csv; pristine 3863 + 224 with 0/0/0.  The thirteen rows that move, fresh law csv:
  r10earl31repro/v5_hier `EQUAL,,equal` (was fullname(1)); r10earl52repro/a2_earl52 `EQUAL` (file(1));
  r11u108repro/grid/pk/k05_param_a `EQUAL` (file(4)); r11u111repro/grid/f1/a10_q_chain `EQUAL` (fullname(5));
  r11u111repro/grid/f1/a27_q_row_named_dims `EQUAL` (file(4)); r11v23repro/adv/v11_concat_64bit_param `EQUAL`
  (fullname(2)); r11v23repro/adv/x09_concat_64bit_param_small `EQUAL` (fullname(1));
  v11u110repro/brk/v6/s01_single_chain2_ctl `EQUAL` (fullname(6)); v11u111repro/brk/f3/x38_param_in_module_typed
  `EQUAL` (file(4)); v11u111repro/brk/f6/x65_chain_td_dims `EQUAL` (fullname(3)); changes
  r11u108repro/grid/f5/f5a20_ovr_pkgarr `STRICT_NOTEQUAL,differ:name(2)` (fullname(6)),
  v11u108repro/brk/f5/b13_pkg_arr `differ:name(1)` (fullname(7)), v11u111repro/brk/f3/y31_two_pkgs_rows
  `differ:name(6)` (fullname(8)).  The fix sweep's probe.csv is byte-identical to the law's.
- **Surelog**: default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2, 0/0/0 on all three binaries; the
  pristine, law and fix csvs equal row for row except the LowMemLib/LowMemPkg testflags SURELOG_FAIL detail
  (the workdir path).  **uhdm2rtlil** 803/1/67 both modes, 0/0/0, csvs identical.  **Downstream** 803 IDENTICAL /
  66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the three csvs identical.  Every sweep exits 1 on the law-index
  check alone (the pristine worktree's check also reads stale, an environment fact of the worktree).
- **Firing census** (drivers/tracecensus.sh on the FIX binary, frozen before the fix sweep: evidence/predict_fix.txt,
  predict_fix.md5): 17 lines, byte-identical to the implementer's evidence/predict.txt; neither refinement's tag
  (ALIASSCOPE_V, ORPHANSIB_V, `(orphan sibling)`) fires on any gate database, so the census PREDICTED 0 law -> fix
  movers.  Positive control of the refinement tags: evidence/refinement_trace_poscontrol.txt (va05, va03, vh12).
- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors,
  8 fenced paths skipped): pristine -> law MOVERS 2 / 2560 (uhdm2rtlil stamped_gen_param default and testflags);
  law -> fix 0 / 2560; pristine -> fix the same 2.  SELFCHECK 2559 / 2560 each time: pass 201's artefact, the
  negative control compares every patched file with the pristine file of the FIRST path, and that path's own pair is
  byte-equal (it is not a mover), so exactly one file is not flagged.  Probe: the pristine probe stage rerun from
  the law worktree (the databases carry the case's absolute path, so a probe stage run from another worktree
  differs in every file): pristine -> law 13 / 4087, exactly the thirteen above; law -> fix 0 / 4087.
  Downstream slang-lane databases: pristine -> law 1 / 805 (stamped_gen_param), law -> fix 0 / 805.
- **Corpus away census** (r11u272repro awaychain.py): stamped_gen_param d/t chain away 0, toward 8 each.
- **Canaries** law and fix: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 PASS (EXPECT_UNKNOWN=1, 6).
- **Binary audit**: 3265 of 3315 cmds.txt name each sweep's own binary, 50 run no slang, 0 other, 8 fenced skipped,
  for all three sweeps.
- **Determinism** (drivers/det.sh, three concurrent draws, fix binary): one hash per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg, Rggen d, each equal to the fix sweep's and to the
  implementer's law hashes (e.g. Earlgrey_0_1 d 3f77d6f16c61, t 891990462621).
- **The implementer's grid** (cases A, C, C2, C3, E, F, H, S; 474 case-views): rerun with my binaries, identical to
  evidence/gridall.txt of r11u284repro in every field but md5 on 4740 of 4740 lines: 222 moving, 102 entering
  STRICT_EQUAL, 0 leaving, 0 exit-code changes, 2 uhdm-cmp line changes (S/s21), law+R11U284_OFF = pristine on
  474 of 474.  Fix vs law on the same grid: **0 of 474 move** (evidence/grid3_impl.txt, g3sum_impl_*).
- **Byte controls** on the implementer's 35 repro dirs (5830 case-views, three binaries, evidence/controls3.txt):
  pristine -> law 46 moving, 8 entering STRICT_EQUAL, 0 leaving, 0 exit-code or uhdm-cmp changes, the same 46
  movers by name as the implementer's; law -> fix 2 moving (r11u119repro/grid/g1/a23_alias_alias_init d/e, an
  alias variable initializer, chain away 0, toward 1 each); pristine -> fix chain away 0 on all 46.
- **Widened byte controls** (19 repro dirs the implementer did not use: r11u21, r11u24, r11u26, r11u28, v11u110,
  r11u110, r11u107, r11u113, r11u116, r11u264, v11u264, r11u262, v11u262, r11u285, v11u285, r11u283, v11u283,
  r11u260, v11u260; 2334 case-views, evidence/controls3_wide.txt): pristine -> law 20 moving (v11u110repro brk/v1
  e01-e09 and brk/v5/k08, stage 1 on every binary), 0 entering, 0 leaving, chain away 0 on all 20; law -> fix 0.
  No case-view's exit code differs between the three binaries in any grid or control file (rc 3, 4 and 139 lines
  read the same on all three).

## The fresh cases (cases/VA, VC, VE, VF, VH, VS: 99 dirs, 198 case-views, every line with its exit code)

Each dut.sv names its law on its first line.  evidence/grid3_fresh.txt carries labels pristine, law, fix,
fix+R11U284_OFF, fix+R11V284_OFF, fix+R11V284_ALIASSCOPE_OFF, fix+R11V284_ORPHANSIB_OFF.

- pristine -> law: **144 moving, 36 entering STRICT_EQUAL, 0 leaving, 0 exit-code or uhdm-cmp changes; chain away 0
  on 138 of 144 and chain away 2 on six (the break below)**, chain toward 216.
- pristine -> fix: 144 moving, **46 entering, 0 leaving, chain away 0 on all 144**, chain toward 270.
- law -> fix: 26 moving, 10 entering, 0 leaving, chain away 0 on all 26, toward 66.
- fix+R11U284_OFF = pristine and fix+R11V284_OFF = law on 198 of 198.
- Away census positive control (binaries swapped) on six movers of five laws: away 1 to 8 on 6 of 6
  (evidence/away_fresh_poscontrol.txt).
- First grid per law switch (VA to VS, 73 dirs, before the later additions): every mover back to pristine under
  exactly one law switch except VF/vf08_param_and_var (F3ELEMCHAIN and F3PARAMCOPY together, chain away 0,
  toward 10).
- Downstream on the 72 dirs whose views move: the same verdict per dir on pristine, law and fix (49 IDENTICAL,
  7 EQUIVALENT, 16 DIVERGENT; the DIVERGENT ones DIVERGENT on all three), the 216 slang-lane RTLIL and netlist
  files byte-identical across the three binaries (evidence/ds_fresh_*.txt).

### THE BREAK: § hpSelPortConnFoldChain284's orphan bound matched by name (FIXED)

The law renames the reference of a package-parameter fold in a member-path select bound through the port of a port
connection, and then renames every recorded bound constant that has no parent ("orphan") whose stored name equals a
renamed name.  The same select text in a process or a continuous assignment beside the port connection has its own
unparented right bound with the same stored name, so it took the port's chain name:

```
sub u1 (.a(o.a[pk::DC-1:pk::LO]), .b(y));
assign z = o.a[pk::DC-1:pk::LO];      // or always_comb z = ...
```

the cont_assign's right-bound reference became `work@dut.u1.a.o.a[4'h2 - 1:4'h0].a` where golden and pristine read
`work@dut.o.a[4'h2 - 1:4'h0].a`: **chain away 2 in both views on VH/vh11_same_sel_port_and_proc,
vh12_same_sel_port_and_ca and vh18_both_bounds_and_proc** (records pristine had right, the law lost); two port
connections with the same select text (vh13) cross-renamed u2's bound into u1's name (stage-1-free, still fullname).

**§ hpSelPortOrphanSibling284v** (ParamEmit pkgAliasTdNames284, `R11V284_ORPHANSIB_OFF`): an orphan bound is renamed
only when it IS the other bound of the part select or indexed part select holding a renamed reference (climbing
through operations above the renamed constant, `o.a[pk::DC+1:pk::DC]`); an orphan left unrenamed is traced
`ORPHANSIB_V kept`.  Result: vh11, vh12, vh13, vh18 convert to STRICT_EQUAL in both views (8 case-views), vh14
(both bounds package parameters) and the implementer's h04 keep the law's bytes, the implementer's H grid moves 0.

### THE OVER-REACH: § pkgAliasTdRefNameByParent284's "written" set (NARROWED)

The law names the alias reference `pk::a_t` (unparented) when any whole-signal continuous assignment or any
declaration initializer anywhere in the design writes a signal of the alias type.  Golden (decoded with fresh
cases, both views) unparents only on the shapes where UhdmWriter::writeCont_assign reaches the declared typedef
object through bindVariable or the net declaration:

| shape | golden | law | case |
|---|---|---|---|
| module-body signal, `assign z = ...` | pk::a_t | pk::a_t | implementer A grid, va34 |
| module-body signal assigned from inside a generate block | pk::a_t | pk::a_t | va23 |
| net declaration assignment `wire pk::a_t z = i` (module, if- and for-generate) | pk::a_t | pk::a_t | va25, va33 |
| VARIABLE initializer `pk::a_t z = 4'h3` | pk::pk::a_t | pk::a_t | va03, va28 |
| generate-local variable written by an assign | pk::pk::a_t | pk::a_t | va06, va14, va32 |
| interface-body variable written by an assign | pk::pk::a_t | pk::a_t | va05 |
| program-body variable written by an assign | pk::pk::a_t | pk::a_t | va21 |

Pristine stored `work@dut.pk::a_t` on all of these, so the law moved no golden-agreeing record away (chain away 0),
but it wrote a third value golden never has.  **§ aliasWriteModuleScope284v** (ParamEmit pkgAliasTdNames284,
`R11V284_ALIASSCOPE_OFF`): variable initializers no longer count, and a continuous assignment counts only when its
target is declared directly in a module body (an interface, program or generate-block target is skipped, traced
`ALIASSCOPE_V`); net declaration assignments still count at any depth.  Result: every alias reference name in VA
equals golden's except va30 (a generate-local wire, where the law abstains because the listing is already
parented, pristine's bytes); va05 converts to STRICT_EQUAL; byte control r11u119repro/grid/g1/a23_alias_alias_init
moves toward (1 record).  Interface and program NETS (va24, va31, va35) are stage 1 on every binary, so their
golden reading is not measured; the refinement treats an interface or program net written by an assign as not
written and a net declaration assignment there as written.

### Other fresh-case findings (all toward golden or unmoved)

- § genCaCatMemberInst284: a generate-local parameter (vc01) and a process right side (vc12) do not move; case
  generate, else branch, interface body, two overridden instances, depth 2, struct member left side, implicit net,
  call and replication members move toward or convert (vc03 e, vc05 e, vc06 e, vc07, vc10 e, vc11, vc16 e,
  vc17 e STRICT_EQUAL); a for-generate whole outer left side (vc14) is unmoved (stage 1).
- § ternSgnLitFreshIntTs284: $bits conditions, `int signed`, header parameters, 40-bit literals and two
  localparams convert (vs05, vs06, vs09, vs12, vs13); overridden conditions per instance (vs01), interfaces (vs03),
  a range use (vs07) and a package condition (vs08) move toward at stage 1; a function-call
  condition (vs11), a class parameter (vs04), a genvar condition (vs14) and a generate-local localparam (vs02)
  do not move.  vs10 (nested ternary) d file -> type, toward 1, away 0.
- § f3ParamCopyDeep284 / § pkgTdNamedDimsElemByChain284: interface and program parameters, instances inside
  generate blocks, two instances, wildcard-import parameters (vf03, vf07 convert; vf01, vf02, vf05, vf09 unmoved;
  vf04, vf06, vf08, vf10 stage 1 moving toward); ve05 e fullname -> file (toward 1).
- § hpSelPortConnFoldChain284: instance arrays, for-/if-generate ports, interface instance ports, wildcard import
  (stage 1 on every binary, moving toward), nested member vh04 and depth-2 vh05 convert in the default view, an
  implicit net vh15 converts.

## Laws and switches after this verification

The implementer's six laws and R11U284_F3GENLOCAL_OFF as landed (README of r11u284repro), plus:
- § hpSelPortOrphanSibling284v — `R11V284_ORPHANSIB_OFF`
- § aliasWriteModuleScope284v — `R11V284_ALIASSCOPE_OFF`
- `R11V284_OFF` drops both (= the law's bytes on 198 of 198 fresh case-views and 474 of 474 implementer
  case-views); `R11U284_OFF` still drops everything (= pristine on the same).  src/R284.h gains `r11v284On`.

## Residues (ranked; all wrong on pristine too)

1. The alias listing's module-signal typespec (`name` head of f5a20, b13, y31 and most VA cases): ModuleEmit
   emitInstance / TypeEmit bareScalarTypedefVarTs, the SISTER'S (as the implementer reported).
2. Interface and program nets of an alias type (va24, va31, va35) and the generate-local wire (va30): stage 1 or
   abstained; golden's parent not measured.
3. § hpSelPortConnFoldChain284's stage-1 shapes (instance arrays vh01, generate ports vh02/vh09, interface instance
   ports vh06, wildcard import vh08): moved toward, comparator stage 1 on every binary.
4. § genCaCatMemberInst284 on a for-generate whole outer left side (vc14) and the depth-2 generate-local case (vc08):
   stage 1 on every binary.
5. § ternSgnLitFreshIntTs284 not reaching function-call conditions (vs11, first field col on every binary), class
   parameters (vs04) and genvar conditions (vs14, stage 1).
6. The implementer's residues 1-5 (member-path select element spans, select-naming leftovers, struct-fold leftovers,
   for-generate concatenation member with an outer left side, g29_d_fence / t12 / g1k_hop_userfn / vh_arrelem) stand.

## Process

- Fence: every corpus path list (mirrors, downstream comparisons, binary audit, census through the harness filter)
  was filtered by $FENCED (read fail-closed from tools/probe/r11u107repro/canaudit.sh) before any file was opened;
  the gate sweeps dispatched every row; no fenced source, database or cmds.txt was read, run or decoded.
- No process of another agent was listed or signalled; the only waits were on my own log files.
- The main tree was not written; worktrees /tmp/wt_v11u284 and /tmp/wt_v11u284pris, scratch /tmp/v11u284_*.
- Two fresh drafts were illegal SV and rejected by slang on every binary (vc09 used a localparam before its
  declaration: removed; vh01's first draft connected an unpacked array to an instance array: rewritten with a cast).
- The two refinements were written after the law sweep; the fix binary was frozen, its firing census frozen,
  then the fix sweep ran; every fix measurement is on md5 33a34347.

Drivers (drivers/): env.sh and case.sh (from r11u284repro, own golden cache /tmp/v11u284_gold), grid.sh (per-law
switches), grid3.sh and g3sum.py (three binaries and the refinement switches), controls3.sh and ctl3sum.py,
away.sh (r11u272repro awaychain.py), dscases.py, mirror.sh, tracecensus.sh, det.sh.
