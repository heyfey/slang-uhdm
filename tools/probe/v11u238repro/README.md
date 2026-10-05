# v11u238 — adversarial verification of r11u238 (pass 238, the expression/parameter ground)

Base `0a1c70e0` (matrix-1.87). Implementer's patch `/tmp/r11u238.patch` (md5 `a560291c4ba50f7b93d0b7e0209ea0bd`),
README [../r11u238repro/README.md](../r11u238repro/README.md). Verdict: **ACCEPT WITH FIX**. Every headline number
of the implementer reproduces bit for bit. Fresh cases on legal SV found two breaks where pristine was right and the
patch was wrong (both in § foreachFlatLocalRefTs238). Two refinements behind `R11V238_*` switches fix them. Neither
refinement fires on any gate database. The verified patch is `/tmp/r11u238.verified.patch`.

The four slang-fenced tests are never named here. Every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed. Nothing fenced was dispatched outside the gate sweeps, read,
decoded or opened. Byteverify and the away census ran on hard-link mirrors and path lists filtered by `$FENCED`
before any file was opened, and the firing census ran with a `--filter` built from `$FENCED`.

## Binaries (frozen before any measurement; every cmds.txt audited by binary path)

| binary | md5 | note |
|---|---|---|
| pristine | `f5497dc77d1cdf48a3b6702d2e1d2e03` | built at `0a1c70e0` (system-deps config); matches the brief |
| law | `a4a9d9c8d90ecf5e6072a48ab625a2a1` | `/tmp/r11u238.patch` built here; matches the implementer's `law3` |
| fix | `b9f2e607e0b22acddf2f01ade2ebfdc1` | law + the two refinements below (the verified patch) |
| detfix | `b19823949e5e0567ec80308beca89075` | fix + the ground-B ordering fix of the determinism section (measurement only, not in the verified patch) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the pristine worktree's build |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `drivers/strictcmp_x.cpp` (copied, fence-checked), for the away census |

cmds.txt audit: 3273 of 3273 slang lines name `/tmp/v11u238_bin/<binary>` in each of the pristine (`/tmp/v11u238_wP`),
law (`wL`), fix (`wF`) and detfix (`wD`, corpora only) sweeps. The other 50 cmds.txt hold no slang line.

## Reproduction of the implementer's numbers

| item | implementer | here |
|---|---|---|
| probe | EQUAL 3476 + 611, 0 regressions / 13 conversions / 1 change | the same (law and fix sweeps) |
| surelog | 469+11 / 465+9, 0 / 0 / 9 changes | the same; every csv row identical apart from the workdir in two LowMem detail texts |
| uhdm2rtlil | 0 / 0 / 0 | the same |
| downstream | 803 / 66 / 2 / 0, not excused 0 | the same; 0 of 805 lane databases differ pristine to fix (positive control differs) |
| byteverify corpus | 9 of 2560 movers, SELFCHECK 2559 of 2560 | the same 9 (BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d) |
| probe movers | 14 | the same 14 (pristine probe stage re-run from the law worktree, `/tmp/v11u238_wQ`, because probe databases embed the source path) |
| prediction | 23 movers, md5 `c227a54e652f68297cd4176c1db42bf6` | my own census with the fix binary gives the same 23 and the same md5, with identical firing counts: 126 + 2728 + 347 + 8 + 12 |
| away census | chain 0, flat 0, toward 2920 | the same, for law and for fix |
| canaries | surelog ok=45 changed=7, u2r ok=16, both ctcan2 PASS | the same |
| grid | 33 cases, 528 runs, rc 0, 19 enter, 0 leave, R11U238_OFF pristine 66/66 | the same verdicts and the same md5 partitions on all 66 case-views |
| SeqDriver default coin | 2 hashes (3 of 9) | reproduced: law 8 + 1 of 9; see the determinism section |

Fresh rows (fix sweep, `evidence/sweeps/targeted_rows_fix.csv`):

```
BuildUVMPkg,default,STRICT_NOTEQUAL,differ:line(16),,differ:line(16)
BuildUVMPkg,testflags,STRICT_NOTEQUAL,differ:line(16),,differ:line(16)
MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(8),,differ:fullname(8)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:fullname(8),,differ:fullname(8)
Scoreboard,default,STRICT_NOTEQUAL,differ:file(11),,differ:file(11)
SeqDriver,default,STRICT_NOTEQUAL,differ:fullname(8),,differ:fullname(8)
SeqDriver,testflags,STRICT_NOTEQUAL,differ:fullname(8),,differ:fullname(8)
SimpleUVM,default,STRICT_NOTEQUAL,differ:line(8),,differ:line(8)
SimpleUVM,testflags,STRICT_NOTEQUAL,differ:line(8),,differ:line(8)
```

First records, base then fix, quoted with uhdm-strictcmp (A golden, B ours):

| row (default) | base | after |
|---|---|---|
| BuildUVMPkg | #77588 file: `string_typespec` A `uvm_pkg.sv 38343:3-9`, B unlocated | #81218 line: `class_typespec uvm_sequence_item` A `50947:29-46` (the REQ default), B `57038:25-42` (the specialization typedef's argument); ground B |
| Scoreboard | #79148 type: A `string_typespec uvm_component.svh 3380:10-16`, B `array_typespec` | #80496 file: the same `uvm_driver` face (`uvm_driver.svh 44` vs `uvm_seq.svh 38`); ground B |
| MiniAmiq / SeqDriver | #64612 / #64568 depth: A `int_var _byte uvm_pkg::uvm_oneway_hash::_byte`, B an `operation` | #68597 / #68553 fullname: a ref_typespec under the clone's body-local associative array, golden named, ours empty; ground B |
| SimpleUVM | #75572 line: `logic_net work@top.m_parent` A 1001:10-18, B 1925:11-19 | the same record (decoded by the implementer, not written); the count grows 3 -> 8 because the walk now diverges later; chain away 0 |

The probe changes (`evidence/sweeps/probe_changes_fix.txt`): 13 conversions to `EQUAL,,equal` (g204_b_ctx,
g204_c_shadow, g204_e_head, t31_t, t32d_t, t33e_t, v180_a_share, v181_e_idxbase, v181_f_mixed, v204_c_clones,
v204_m_module, v204_s_shadow, v204_v_extra) and g180_a_kinds `differ:depth(1) -> differ:line(5)`.

**byteverify SELFCHECK 2559 / 2560.** This is the self-check working correctly, not a movers line. The comparator is
run with one side replaced by a single fixed file, and the one path it cannot flag is that file compared with itself.

## The breaks (fresh cases, legal SV, pristine right and the law wrong)

§ foreachFlatLocalRefTs238 binds a foreach's iterated reference to a paren-less subroutine local's flattened element
typespec. Its only abstention was a same-named variable in the enclosing package's slang scope. Golden binds
something else in two more situations:

1. **The package listing, not slang's package scope** (case B/b01_ctorhoist). An out-of-body constructor's block-item
   local (`function c::new(); string vals[$];`) is hoisted into the package's UHDM listing, because
   `CompilePackage::collectObjects_` does not stop at `paClass_constructor_declaration`. slang has no package member
   of that name. Golden's `foreach (vals[i])` in the paren-less `c::m_set` binds the base's `array_typespec`, while
   the law bound the local's `string_typespec`. Result: pristine STRICT_EQUAL, law STRICT_NOTEQUAL type, in both views.
2. **A module, interface or program member of the same name** (B/b07_module_shadow, b10_iface, b05, b09, b13, b14).
   Surelog compiles the foreach array name with `compileVariable` against the enclosing DesignComponent (the
   paFOREACH branch of CompileStmt.cpp). That component's own signal of the same name is what the reference's typespec
   reads. On b07 (`int vals[4]` in the module beside a paren-less function's `int vals[$]`) pristine is STRICT_EQUAL
   and the law fails **uhdm-cmp** (stage 1, 14 lines) in both views. On b10's `-elabuhdm` view (an interface variable)
   pristine is STRICT_NOTEQUAL and the law fails stage 1. A **class** property of the same name does NOT win:
   b08_clsprop and b11_inherited convert under the law, and golden agrees with the law there.

### § pkgListingWinsFlatLocal238v (switch `R11V238_PKGLISTING_OFF`; StmtEmit, the foreach iterated-array ref_var branch)

In the package's OWN subroutine (§ 81's subHomeIsPkg81 gate: the subroutine's package is `pkgScopeInst`), a
TF-ITEM body local (`tfItemBodyLocal148`) whose name is in the home package's UHDM `Variables()` listing keeps the
base's deferred array bind. That listing is what § tfItemLocalLosesToPkgVar148's late binder reads. Cases:
B/b01_ctorhoist (§ pkgListingWinsFlatLocal238v; STRICT_NOTEQUAL type under the law -> STRICT_EQUAL, both views).
B/b02_impvar (a variable of a wildcard-imported package; stage 1 at the base on another face) also moves bytes under
this switch, with the away census reading 0 / 0 from law to fix.

### § instBodyMemberWinsFlatLocal238v (switch `R11V238_INSTSHADOW_OFF`; same branch)

When the subroutine's nearest enclosing instance body (module, interface or program) has a member of the local's
name, the base's deferred array bind stands. Cases (§ instBodyMemberWinsFlatLocal238v):

- B/b07_module_shadow: the law fails uhdm-cmp; the fix is STRICT_EQUAL, both views.
- B/b10_iface: `-elabuhdm` goes law stage 1 -> fix STRICT_EQUAL. The fix CONVERTS it against pristine's
  STRICT_NOTEQUAL type, because the unshadowed `bq` beside it still takes the law.
- B/b05_module, b09_net (a module net), b13_modparam (a module parameter) and b14_task_module (a paren-less module
  task): stage 1 at the base. Law to fix, the away census reads 0 lost and 2 toward on b05 and b14, and 0 / 0 on b09
  and b13. Pristine to fix reads 0 lost.

Controls the law still fires on: B/b06_module_noshadow (STRICT_NOTEQUAL type -> STRICT_EQUAL, both views),
b08_clsprop, b11_inherited.

`R11V238_OFF` drops both refinements and gives the law's bytes. `R11U238_OFF` drops the laws and the refinements and
gives pristine bytes. The trace (`R11U238_TRACE`) names both refinements.

## Census, prediction and gates of the fix binary

The firing census with the fix binary covered every corpus row-mode but the fenced ones (`--filter` from `$FENCED`),
every probe case and every downstream lane (`evidence/census/`). The refinements fire **0 times**. The prediction,
frozen at 2026-10-04T22:46:15 before the fix sweep, was: fix vs law moves no database, and fix vs pristine moves the
implementer's 23 (same md5 `c227a54e...`).

The fix sweep `/tmp/v11u238_wF` (`evidence/sweeps/sweep_F.txt`):

- probe EQUAL 3476 + STRICT_NOTEQUAL 611: regressions 0, conversions 13, changes 1.
- surelog: regressions 0, conversions 0, changes 9.
- uhdm2rtlil: 0 / 0 / 0.
- downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0.
- Every csv is identical to the law sweep's, apart from the workdir in two LowMem detail texts.
- Each sweep's only nonzero exit is `law index STALE`. The base's committed tests/LAWS.md predates its own commit;
  the patch carries the regenerated file.

byteverify (`evidence/movers/byteverify.txt`):

- fix vs pristine: the 9 predicted.
- fix vs law: **1 of 2560**, `surelog/default/SeqDriver`. The fix sweep drew the minority hash `c946207f4fd3` of
  the order coin below. Its sorted uhdm-dump is identical to the law sweep's (52 raw lines: two pairs of minted
  unreferenced variables swap). The refinements did not fire there.
- Probe: fix vs law 0 of 4087; fix vs pristine (same-worktree re-run) exactly the 14 predicted.
- Downstream lanes: 0 of 805 against law and against pristine, with a positive control.

Away census (`evidence/movers/away_fix_vs_pristine.txt`): chain away 0, flat away 0, toward 2920 over the 23 movers.
The 13 `MISSING` lines are rgg probe cases whose names the census cannot map to a golden. They are byte-identical
across the sweeps. Canaries (`evidence/canaries.txt`): surelog ok=45 changed=7 (the seven changed UVM row-modes),
uhdm2rtlil ok=16 changed=0, and both ctcan2 runs PASS. uhdm-cmp reads 0 lines on every corpus mover (each is
STRICT_NOTEQUAL).

## Grids

**The implementer's 33 cases** (`evidence/grid_r11u238.txt`, `grid_r11u238_summary.txt`; 858 runs, every exit
code 0). Fix = law on all 66 case-views. 19 case-views enter STRICT_EQUAL and none leaves. `R11U238_OFF` gives
pristine bytes 66 / 66 on both binaries, and `R11V238_OFF` gives the law's bytes 66 / 66.

**Fresh cases** (`cases/`, 35 cases, both views, 910 runs; `evidence/grid_fresh.txt`, `grid_fresh_summary.txt`).
Every exit code is 0 except D/d01_tdqueue, which exits 4 on every binary, pristine included: slang-uhdm reports
"unsupported constructs: class property type: FixedSizeUnpackedArrayType" for a typedef'd 2-D class property.

| | law | fix |
|---|---|---|
| case-views moved vs pristine | 60 | 54 |
| enter STRICT_EQUAL | 11 | 12 |
| **leave STRICT_EQUAL** | **4** (b01 d/el, b07 d/el) | 0 |
| **leave judge-equal (uhdm-cmp)** | **3** (b07 d/el, b10 el) | 0 |
| uhdm-cmp line count changed on a stage-1 case | 12 | 0 |
| chain away records vs pristine | **20** | 0 (toward 212) |

`R11U238_OFF` gives pristine bytes on 70 / 70 for both binaries, and fix + `R11V238_OFF` gives the law's bytes on
70 / 70. Each switch moves only its own law's cases: PROPSTRTS 12, FLATLOCALREFTS 30, CLONEFORINC 10,
CLONEFORINCCLS 3, CLONEPROPARR 12, PKGLISTING 4, INSTSHADOW 12 case-views. Flat away 2 on fix: B/b02_impvar, one
per view, with chain away 0. It is the same under the law, and b02 is stage 1 at the base on another face.

Fresh cases by law (each case's first line names its law):

- § cloneForIncBindsHomeVar238:
  - A/a01_twoclones: two importers, a re-export chain, loop variable in part-select bounds.
  - A/a02_shadow, a05_inner_shadow: an inner block re-declaring the loop variable, which keeps its own binding; a
    sibling loop reusing the name; the loop variable as a call argument inside an index.
  - A/a03_task_class: a task clone, a parameterized class method, a `$unit` import.
  - A/a04_synth, a08_synth: synthesizable callees of an importing package's function.
  - A/a06_two_importers.
  - A/a07_while_fork: while, case item, nested call argument and return. STRICT_NOTEQUAL depth -> STRICT_EQUAL.
  - E/e01_mixed: named and positional calls into the home function, an extern body below its caller, a pure virtual
    prototype, a class specialization in a bound, an implicit net.
  - All of these: chain away 0 and toward 3-18 each (e01 10 and 1). a05's walk divergence at #160 (the loop
    variable's depth record) is cleared and its fullname face remains. a06's head moves from #63 to #146 (golden's z
    clone reads q's clone variable `c`: a re-export face, not this law).
- § foreachFlatLocalRefTs238: B/b02, b03_kinds (packed, enum, struct, class handle and typedef'd queue elements, a
  nested begin, a task; toward 20 per view), b04_param, b06, b08, b11, b12_pkgparam (bytes move, records do not).
- § foreachClassPropStringTsShared238:
  - C/c01_strprops, c04_derived_shadow: stage 1 at the base on other faces; toward 2-6.
  - C/c06_unit_class (a `$unit` class and a class in an interface): stage 1 at the base, no byte moves.
  - C/c02_clone: a class-method import clone and specialization; toward 1.
  - C/c03_twodecl: `string a, b;`, protected and static strings. STRICT_NOTEQUAL file -> STRICT_EQUAL, both views.
  - C/c05_local_shadow: a local and a formal shadowing the property. STRICT_NOTEQUAL type -> STRICT_EQUAL, both views.
- § cloneLoopVarClassPropArrayTs238: D/d01_tdqueue, d02_param_cls, d03_tdq (typedef'd queue and dynamic
  properties: bytes move, records do not), d04_twoidx (toward 8), d05_static_scope (toward 2; residue 2),
  E/e02_this_paths (toward 8 and 5).

**Downstream on the synthesizable cases** (`drivers/ds.sh`):

- a08_synth is DIVERGENT on pristine, law and fix alike, a pre-existing function-inlining difference. The slang
  lane's `_nohier.il` is byte-identical across the three binaries.
- a04_synth is READ_FAIL in both lanes: a Yosys `alumacc` assert on its popcount loop, on every binary.

## Determinism (the implementer's finding, verified)

`drivers/det2.sh` ran three concurrent harness runs per round on SeqDriver default (`evidence/det_seqdriver.txt`):

| binary | runs | hashes |
|---|---|---|
| law | 9 | 8 × `8350e50ef7d9` + 1 × `c946207f4fd3` |
| pristine | 9 | 1 hash |
| detfix | 9 | 1 hash (`8350e50ef7d9`) |

The fix gate sweep also drew `c946207f4fd3`. `drivers/det.sh` ran Earlgrey_0_1 and the five UVM rows in both modes
three times concurrently (`evidence/det_rows.txt`): one hash per row-mode on both fix and detfix in that run.
Scoreboard testflags is SLANG_REJECT and has no database.

**Cause, confirmed.** UhdmExporter `drainCloneArrayRecvArgMint193` iterates `s.AllObjects()`, which is
`Serializer::IdMap = std::map<const BaseClass*, uint32_t>`, keyed by address. The coin's two databases differ only
in the order of the minted unreferenced variables (`adpcm_pkg::uvm_phase::{sync,unsync}::visited.exists::succ`
and the `do_print` `get_address::this` mints). Their sorted dumps are identical, and both read uhdm-cmp equal and
strict `fullname`.

**The ground-B fix, measured but not in the verified patch.** That code is the module/type ground, which is the
sister pass's ground. The fix is `/tmp/v11u238_detfix.patch` (transport only). It collects the hier_paths and sorts
them by `UhdmId()` before minting. It applies clean at `0a1c70e0` and at HEAD `40f5caf7`. The measured binary
carried the same change behind a `DETFIX_OFF` environment guard, which was never set.

The detfix corpus sweep (`/tmp/v11u238_wD`; `evidence/sweeps/sweep_D_detfix.txt`):

- surelog 0 regressions / 0 conversions / 9 changes; uhdm2rtlil 0 / 0 / 0.
- Every csv row is identical to the fix sweep's.
- byteverify vs the law sweep: 3 movers, MiniAmiq d/t and SeqDriver testflags. Each is an order-only move (sorted
  uhdm-dump identical, 76 and 52 raw lines).
- It removes the coin: SeqDriver default reads one hash in 9 of 9 runs plus the sweep.

The integrator must either land this patch with or before r11u238 and accept those three predicted order-only
movers, or list SeqDriver/default as a known order coin.

## Residues, ranked

1. **The integrator's choice on the SeqDriver default coin** (above).
2. **D/d05_static_scope** `foreach (fac::m_s[k])`, a class-scope spelling in a class-method clone. Golden binds a
   fresh `int_typespec` (the element) to the shared clone object. Pristine had the placeholder `unsupported_typespec`
   and the law has an `array_typespec`: wrong to wrong, same verdict, no record lost. § cloneLoopVarClassPropArrayTs238
   should give the element typespec for a `C::prop` spelling.
3. **A/a06_two_importers**: in a re-export chain (`z` imports `q`, which exports `p::*`), golden's `z` clone reads
   `q`'s clone variable (`q::h::c`) where ours lists the for statement. This clone-of-clone binding face is not written.
4. **B/b02_impvar**: a wildcard-imported package's same-named variable. It is stage 1 at the base on another face
   (122 lines on every binary). Flat away 1 per view with chain away 0, under both law and fix.
5. The implementer's residues stand: SimpleUVM #75572, BlackBePipeInt N2471 / N0028 / N0118 / N0873, brief items
   (3)-(7), `byte` loop variables in clones (k07), and the typedef'd string property (f16).
6. Pre-existing on every binary: a typedef'd 2-D class property is unsupported (rc 4, D/d01); a typedef'd queue
   property in a clone is stage 1 at the base (D/d03); a Yosys alumacc assert (a04_synth).

Sister-ground faces (call sites) are the implementer's four: the `uvm_driver` REQ/RSP property location (class body
writers), body-local associative array full names in class-method clones (TaskFuncEmit), `drainCloneArrayRecvArgMint193`
(UhdmExporter, fix measured above), and g180_a_kinds' import-clone enum location (TypeEmit).

## Drivers (`drivers/`; each reads `$FENCED` fail-closed)

- Copied from r11u238repro: `env.sh` (repo paths; `$B` binaries, `$S` scratch), `case.sh` (one case and view:
  golden, ours, uhdm-cmp, uhdm-strictcmp, rc), `census.sh`, `dscensus.py`, `predict.py`, `bvmirror.sh`, `det.sh`,
  `awayrows.py`, `strictcmp_x.cpp` + `cc_x.sh`.
- `grid.sh`: pristine, law + every R11U238 switch, fix + R11U238_OFF / R11V238_OFF / each R11V238 switch.
  `CASEROOT` runs another pass's cases.
- `gridsum.py`.
- `awaycase.py`: map 12's chain-keyed away census over case-view directories.
- `pdmovers.py`: probe and downstream database movers between two sweeps, workdir-normalised, with a positive control.
- `det2.sh`: N rounds of three concurrent harness runs on named rows.
- `ds.sh`: one case's downstream verdict.

## Process notes

- Worktrees `/tmp/wt_v11u238` (law + fix) and `/tmp/wt_v11u238pris` (pristine), both at `0a1c70e0`. Scratch is
  `/tmp/v11u238_*`. The main checkout was never written, no submodule was initialised, and every tool reached
  through a variable was guarded with `[ -x ]`.
- The detfix binary was built by temporarily editing `src/UhdmExporter.cpp` in the law worktree. The file was
  restored byte for byte immediately after the copy (`git diff` empty), and the verified patch does not touch it.
- No process of another agent was listed or signalled. Nothing was killed.
- First run of this verifier: its worktrees and scratch were lost when the master session ended. Everything here
  is from this run.
