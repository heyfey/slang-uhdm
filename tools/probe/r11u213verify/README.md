# r11u213 — second adversarial verification of passes 206 and 207

Base `baf91896` (branch matrix-1.87: pass 206 landed at `6e39a3fc` with its verifier v11u206, pass 207 at `62ac216e`
with its verifier v11u207, r11u208's refinement at `4acbe8a5`, map 13 (r11u211) on top, tools only). Measurement only:
no file under `src/`, `scripts/`, `tests/`, `results/` or `third_party/` is edited by this directory. The one proven
break's refinement ships as [fix.patch](fix.patch) (not applied), gated by `R11V213_PROTOBUF_OFF` (`R11V213_OFF` drops
it), header `src/R213.h`.

## 0. Verdict

* **One break, refined.** § namedOrderLinkedDeclines207v (v11u207's refinement of § namedUnlinkedWrittenOrder207)
  decides whether an in-body call's `extern` / `pure virtual` TASK prototype sits above the call with
  `m.location.buffer() == callLoc.buffer() && m.location < callLoc`. A prototype written in an included header or
  by a macro, or a call written by a macro or in an included file, lives in another slang buffer, so the decline is
  skipped and the written-order law reorders a call that golden LINKS (formal order). Surelog compiles the
  preprocessed stream, so "above" is the flattened order (section 4). Fresh cases NL/l01, l02, l06: 6 case-views
  move the argument order away from golden where pristine had golden's order; **NL/l06 `--elabuhdm` is STRICT_EQUAL
  with the law off and NOT_EQUAL with it on** (the only judge-level regression of 172 case-views). The refinement
  **§ namedOrderProtoAboveAnyBuffer213v** (`R11V213_PROTOBUF_OFF`) asks slang's
  `SourceManager::isBeforeInCompilationUnit` when the buffers differ. It restores pristine bytes on all 6
  case-views (l06 `--elabuhdm` back to STRICT_EQUAL 69 objects). It fires on no corpus row, probe case or downstream
  lane, and on no other tools/probe case (12852 case directories x 2 views: 6 trace files, all NL/l01, l02, l06).
  It moves 0 of 2560 + 4087 + 805 databases, every gate reads 0/0/0, and downstream reads 803/66/2/0.
* **No other break** in 86 fresh cases x 2 views (172 case-views, 132 with a firing of a law under test). No crash:
  every rc is 0, or 4 (unsupported construct, database written) on both binaries alike. No strict record, chain-keyed
  record or order-aware record moves away from golden except the break and two walk artifacts (section 3.3). No
  downstream verdict leaves IDENTICAL (16 of 86 cases move toward IDENTICAL).
* **Away-moved-record census** (map 12's method, full corpora + probe): pass 206: 6 databases, 13 records toward,
  **0 lost**. Pass 207: 23 databases, 701 toward, **0 lost**. Both together (A -> H): 28 databases, 714 toward, 0
  lost. The positive control (H -> A) reads 714 records away. This reproduces map 13 exactly.
* **Composition:** every claimed conversion is its own landing's (pass 206: arb_idx_cast d/t; pass 207: UnitElabBlock
  d/t and the seven probe cases). There are 0 cancellations at status level and at byte level over 6647 databases.
  Every one of the 11 surelog and 3 probe CHANGE lines is a strict subset of the records, except BlackBePipeInt d,
  which is an unmasking (its one new record sits at #15272, past the old divergence at #67). Four cross-ground pairs
  compose: X/x03 needs both laws to reach STRICT_EQUAL. X/x01, x02, x04, x05 each close in with each law alone and
  further with both.
* **Determinism** (HEAD): Earlgrey_0_1 draws one hash in 6 concurrent runs per mode, the same hash in every sweep.
  BuildUVMPkg draws one hash in 23 draws per mode, and the `this_type` object is present in it. SeqDriver testflags
  draws one hash in 10 of 10 (law) and 10 of 10 (pass 207 off), so **map 13's second SeqDriver hash does not
  reproduce at HEAD and pass 207 does not change the draw rate**. MiniAmiq draws two hashes that differ in storage
  order only. Scoreboard default draws two hashes, 0 lines apart order-blind and 92 lines apart in the ordered dump
  (the svunit listing order). Rebuild identity: the main tree's and this worktree's builds are byte-identical
  (`6292e702987d`). The qr01 orphan is deterministic per binary and unchanged by an ExprEmit-only rebuild.
* **Fence and process:** no fenced reading (section 11). v11u206repro's drivers `det.sh` and `sw.sh` filter nothing
  themselves, and its `env.sh` reads the MAIN checkout's canaudit.sh by absolute path. Five of its drivers source
  `/tmp/v11u206_drv/env.sh`, which no longer exists, and the other three name `/tmp/v11u206_*` scratch, so the
  packaged directory refuses to run (it fails closed, but it cannot be re-run). No driver of the four directories writes relative to its current directory. The frozen
  predictions of both passes contain every mover measured here.

## 1. Binaries and states

Frozen `chmod 555` in `/tmp/r11u213_bin` before any measurement ([evidence/sweeps/binaries_md5.txt](evidence/sweeps/binaries_md5.txt)):

| binary | md5 | what |
|---|---|---|
| `law.bin` | `6292e702987d` | `baf91896`, the worktree build (system deps, `-j 2`), byte-identical to the main tree's `build/slang-uhdm` |
| `fix.bin` | `5450a3bbda42` | `baf91896` + [fix.patch](fix.patch); a FRESH `baf91896` worktree with `git apply fix.patch` and a fresh cmake rebuilds the same md5 |
| `uhdm-strictcmp` | `fa6e4f42f252` | the base's strict comparator (not edited) |

State wrappers ([evidence/sweeps/state_wrappers.txt](evidence/sweeps/state_wrappers.txt)), gate sweeps `tests/sweep.sh --jobs 3`
(all four stages) in `/tmp/r11u213_sw<tag>`; every `cmds.txt` names the sweep's own wrapper (3273 of 3273 per sweep):

| tag | state | switches |
|---|---|---|
| H | law (+ the firing census) | `R11U206_TRACE R11U207_TRACE R11V208_TRACE` |
| A | both landings off | `R11U206_OFF R11U207_OFF R11V207_OFF` |
| 6 | landing 206 off | `R11U206_OFF` |
| 7 | landing 207 off | `R11U207_OFF R11V207_OFF` |
| 8 | r11u208's refinement off | `R11V208_OFF` |
| W | A + r11u208 off | `R11U206_OFF R11U207_OFF R11V207_OFF R11V208_OFF` |
| F | the fix | `fix.bin` + `R11V213_TRACE` |

**The switch map, read from src** ([drivers/laws.py](drivers/laws.py) header, measured in [evidence/grid/switch_reach.txt](evidence/grid/switch_reach.txt)):

* `R11U206_OFF` (UhdmExporter.cpp `r11u206Law`) drops exactly the six pass-206 laws, which read it at six sites.
  Two of them also sit under an older law's gate. § unitClassTdEndAtInitIfcPrg206 runs inside
  `if (r11u202Law("R11U202_CLSTDINITEND_OFF"))`, so `R11U202_OFF` and `R11U202_CLSTDINITEND_OFF` drop it too (UT/t07:
  `R11U202_OFF` = `R11U202_OFF R11U206_OFF` bytes). § classScopeTdRetBuildsOwner206 requires
  `r11u200Law("R11U200_CLASSTDRET_OFF")`, so `R11U200_OFF`, `R11U202_OFF` and `R11U200_CLASSTDRET_OFF` drop it too
  (TR/r01). This is the same over-reach r11u208 found for `R11U200_OFF`.
* `R11U207_OFF` (EmitHelpers.h `r11u207On`, cached in a static) drops all seven pass-207 laws and r11u207's
  refinement § pcwElabKeepsClaim207v. With it alone the whole landing writes pristine bytes, because v11u207's
  refinement only declines inside § namedUnlinkedWrittenOrder207. `R11V207_OFF` / `R11V207_NAMEDLINK_OFF` alone
  re-open the v11u207 break, a state that never landed. `R11U207_PCWELAB_OFF` alone runs § parenCastWidthRefPkgBare207
  unrefined in the `--elabuhdm` view, which also never landed.
* `R11V208_OFF` drops § opCtxTargetAncestorBind208v, which fires nowhere (sweep 8: 0/0/0; 1 byte mover, Scoreboard
  default's coin, 0 order-blind lines).

## 2. The gates of the fix (sweep F against H, and against the committed baselines)

| gate | result |
|---|---|
| (1) build | `baf91896` + fix.patch, `-j 2`, md5 `5450a3bbda42`, reproduced from a fresh worktree; `R11V213_OFF=1` writes law.bin's bytes on all 12 NL case-views ([evidence/fix/nl_judge.txt](evidence/fix/nl_judge.txt)) |
| (2) probe | EQUAL 3370 / STRICT_NOTEQUAL 717, `regressions=0 conversions=0 changes=0` |
| (3) surelog, uhdm2rtlil | `regressions=0 conversions=0 changes=0` in both corpora (924 + 30; 1596 + 10). surelog.csv differs from H only in the LowMemLib testflags detail text (the workdir path); uhdm2rtlil.csv, probe.csv and downstream.csv are byte-identical to H's |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the verdict columns identical to H |
| (5) uhdm-cmp | no row touched |
| (6) byteverify | `MOVERS: 0 / 2560`, SELFCHECK 2559 / 2560 (fence-free mirrors, `fenced_skipped=8`); probe 0 / 4087; downstream slang lanes 0 / 805 ([evidence/fix/byteverify_F_vs_H.txt](evidence/fix/byteverify_F_vs_H.txt), [evidence/sweeps/lanebytes.txt](evidence/sweeps/lanebytes.txt)) |
| prediction | frozen before sweep F ([evidence/fix/predicted_movers_fix.txt](evidence/fix/predicted_movers_fix.txt), stamp in `predicted_frozen_at.txt`): 0 movers, 0 trace files; measured 0 and 0 (`/tmp/r11u213_trF` empty) |
| firing census | `drivers/firecensus.sh` over all 12852 tools/probe case directories x 2 views: 6 trace files, all NL/l01, l02, l06 ([evidence/fix/firecensus_traces.txt](evidence/fix/firecensus_traces.txt)). 500 non-zero rcs, each equal on law.bin (274 rc 3, 216 rc 4, 10 rc 139: pre-existing, [firecensus_rc.txt](evidence/fix/firecensus_rc.txt)) |
| canaries | H and F: surelog `ok=52 changed=0`, uhdm2rtlil `ok=16 changed=0`; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS |

The fix's new branch returns `true` only where its trace fires, so the firing census is its byte boundary.

The HEAD gate sweep H itself reads probe `0/0/0` (3370 / 717), surelog `0/0/0` (464 + 16 / 460 + 14), uhdm2rtlil
`0/0/0`, downstream 803/66/2/0 ([evidence/sweeps/sweep_H.summary.txt](evidence/sweeps/sweep_H.summary.txt)). The sweeps after H
exit 1 only on `law index STALE`: this directory's new cases name their laws and `tests/LAWS.md` is not regenerated
here. The integrator runs `scripts/law_index.py`.

## 3. The laws, fresh cases, three axes

86 fresh cases in [cases/](cases/). Each names its laws on its first line (a case with an `args` file names them in
its first root file; a `nosv` file drops `-sv`). Goldens come from the pinned Surelog with check_probe's arguments,
in both views (`EL=1`: `-elabuhdm` / `--elabuhdm`). [drivers/grid.py](drivers/grid.py) runs each case under
`law.bin`, the traces, each named law's switch alone, the landing off, every pair of named laws (X/), all off and
all off + `R11V208_OFF`. It scores pristine (switch on) against law on the strict records when stage 1 is equal,
and on the order-blind dump distance when stage 1 differs. [drivers/recaway2.py](drivers/recaway2.py) (chain-keyed
records), the new [drivers/recorder.py](drivers/recorder.py) (chain-keyed AND sibling-ordinal: sees a reordered list)
and [drivers/dumpaway2.py](drivers/dumpaway2.py) name every golden-agreeing record a switch-off state had and the law
lost. Downstream verdicts come from the harness's own `one()` ([drivers/dscase.py](drivers/dscase.py)). Tally
([evidence/grid/lawtable.txt](evidence/grid/lawtable.txt); `grid_def.txt`, `grid_el.txt`):

| law (switch) | cases (shapes) | fired case-views | verdicts, law vs its switch off | away | verdict |
|---|---|---|---|---|---|
| § tpCastUseBindsDefDefault206 (`R11U206_TPCASTDEF_OFF`) | TC/c01 (for in for in if, three generate levels), c02 (always / initial in a loop generate, a typedef default), c03 (an int default, a generate-scope function body with a local of the type), c04 (overridden per instance twice through a parent's type parameter), c05 (a packed-struct default, generate-case in a loop), c06 (a parameterized-class typedef default `cfg#(3)::w_t`), c07 (an interface's nested generate + a module), X/x01 | 8 (c01 c04 c07 x01) | TOWARD 4 (c01, c04 -> STRICT_EQUAL both views), STAGE1-CLOSER 4 | 0 | holds; c02 c03 c05 c06 unfired (procedural / function / case-in-loop / class-typedef default: under-reach, stage 1 in both) |
| § tpArrayElemBindsDefDefault206 (`R11U206_TPARRELEM_OFF`) | TA/a01 (depth 3), a02 (`tri` / `wand` array_net), a03 (an int default, 1 and 2 dims), a04 (three instances: default, type override, value override), a05 (a generate-local array and an unpacked output port) | 4 (a01 a04) | TOWARD 4 (-> STRICT_EQUAL both views) | 0 | holds; array_net elements unfired (a02, stage 1 in both), a03 / a05 unfired |
| § unitClassTdEndAtInitIfcPrg206 (`R11U206_UTIFCPRG_OFF`) | UT/t01-t06 (module, interface and program writers in all six alphabetical orders, source order reversed), t07 (two interfaces + a program, no module), t08 (a package class typedef: control), t09 (the module's only writer in a generate block), t10 (a checker), t11 (CRLF), t12 (two declarators in a program, a parameterized interface instantiated twice), X/x04 | 12 | TOWARD 8 (t07 t11 t12 x04 -> STRICT_EQUAL), STAGE1-CLOSER 4 | 0 | holds; t01-t06 unfired as the law says (a module writer wins, pass 202's law) |
| § classScopeTdRetBuildsOwner206 (`R11U206_CLSCOPETDRET_OFF`) | TR/r01 (a typedef of a typedef), r02 (inherited two levels up), r03 (the owner nested in the returning class), r04 (extern prototypes, bodies in an included file), r05 (`K#(.W(2))::q_t`, `p::J::r_t`), r06 (an interface-class owner; another package's class), r07 (the owner sorts before), r08 (r06 with a plain class), X/x03 | 14 | TOWARD 4 (r04, x03 -> STRICT_EQUAL), STAGE1-CLOSER 9, **STAGE1-AWAY 1 (r06 `--elabuhdm`: decoded, not a break, section 3.2)** | 0 records | holds; r02 r07 unfired (nothing to build) |
| § genScopeClassVarListed206 (`R11U206_GENCLSVAR_OFF`) | GV/v01 (generate-if / else, two classes), v02 (generate-case with default, three instances), v03 (nested generate-for), v04 (initializers `new` / `null`), v05 (type arguments, two instances), v06 (`#(.W(8))`, `#()`), v07 (fixed / dynamic / queue arrays of handles), v08 (wildcard-imported class, a typedef of a specialization, a same-named outer variable), v09 (an interface's and a program's generate scope), X/x02 | 20 | STAGE1-CLOSER 20 (v01 v02 v03 v08 x02 -> STRICT_EQUAL both views) | 0 | holds; residues v04 (null init), v07 (arrays), R5 |
| § genScopeClassVarSpecAtName206 (`R11U206_GENCLSSPAN_OFF`) | GS/s01 (`c#( 3 )`, a line break before `#`, two arguments, two declarators), s02 (a parameter, a nested specialization, a genvar expression), GV/v05, v06, X/x05 | 10 | TOWARD 2 (x05 -> STRICT_EQUAL), STAGE1-CLOSER 8 | 0 | holds (every span at the class name = golden, s01 checked line by line) |
| § hiddenBlockVarMintNoFile207 (`R11U207_HIDDENVARFILE_OFF`) | HV/h01 (always, initial, nested named begin, fork), h02 (the block from an included `.vh`), h03 (a `.v` module beside a `.sv` sibling hiding nothing), h04 (the hidden name also an implicit net elsewhere; two modules), h05 (read in a condition and `$display`: control), X/x04 | 10 | TOWARD 10 (all -> STRICT_EQUAL) | 0 | holds |
| § namedUnlinkedWrittenOrder207 (`R11U207_NAMEDORDER_OFF`) | NC/n01 (a same-class callee declared LATER in the body), n02 (another package: scoped, explicit and wildcard import), n03 (extern body in an included file), n04 (an interface class), n05 (a static extern called from a module and a class), n06 (a subclass calling the base's extern task), n07 (nested named calls), n08 (package / module caller above its callee), n09 (declines: empty slot, positional prefix, output formal), NL/l01-l06, X/x03 | 18 | STAGE1-CLOSER 14, STAGE1-SAME 4 (order-blind) | **order-aware: 12 records (NL/l01, l02, l06 `--elabuhdm`) + the two default-view argument orders; l06 `--elabuhdm` EQUAL -> NOT_EQUAL** | **BREAK via the refinement's task half: refined (section 4)** |
| § namedOrderLinkedDeclines207v (`R11V207_NAMEDLINK_OFF`) | NL/l03 (a parameterized class's own extern function in fork / nested begin; a pure virtual function), l04 (a class in a module: extern task and extern function above), l05 (an extern FUNCTION prototype from an include), l01 l02 l06 (the task prototype / the call across buffers) | 6 (l03 l04 l05) | against the unrefined law: l03, l05 STRICT_EQUAL where unrefined is stage 1 (both views), l04 stage 1 both | 0 | holds where it fires; **misses l01 l02 l06 (the break)** |
| § namedSlotFillerRootFile207 (`R11U207_SLOTFILE_OFF`) | SF/f01 (a package in an included header), f02 (string, real, enum, struct, class, bit, logic formals), f03 (interface continuous assignment, generate, a macro from an included header), f04 (two root files: the callee's package in a.sv, callers in b.sv) | 8 | TOWARD 2 (f02 -> STRICT_EQUAL), STAGE1-SAME 6 (the dump prints no constant file) | 0 | holds: every filler's file equals golden's (`dut.sv`; `b.sv` in f04), checked on the records |
| § bitSelMethodCallIdxSpan207 (`R11U207_MCALLIDX_OFF`) | MI/m01 (two arguments, a nested call argument, `this.h.get`, a chained call, two dimensions), m02 (built-in methods, a part select, an operation, a parenthesized call: controls), m03 (module always / initial, a multi-line argument list), X/x05 | 6 | TOWARD 4 (m03, x05 -> STRICT_EQUAL), STAGE1-CLOSER 2 | 0 | holds |
| § parenMethodCallPathSpan207 (`R11U207_PARENMCALL_OFF`) | PM/p01 (three pairs, casts around it, if / while / ternary conditions), p02 (operands, `this.`, a chained receiver, a concatenation), p03 (an interface instance's function, a class handle, module context) | 6 | TOWARD 6 (all -> STRICT_EQUAL) | 0 | holds |
| § foreachThisArrAtThisToken207 (`R11U207_FOREACHTHIS_OFF`) | FT/t01 (two and three indices, a skipped index; associative / dynamic / queue dimensions), t02 (a static array, associative by string and by class, a `super.` control), t03 (a nested class, fork, a loop, 1 / 4 / 5 / 12-letter names), X/x02 | 8 | TOWARD 4 (t03, x02 -> STRICT_EQUAL), STAGE1-CLOSER 4 | 0 | holds (4-letter `abcd` fires with no byte move, as reported) |
| § parenCastWidthRefPkgBare207 (`R11U207_PCWPKG_OFF`) | CW/w01 (explicit imports of the width and of the cast parameter), w02 (through two packages: import + export), w03 (a module localparam shadowing the width; a class body cast), w04 (a generate scope; per-instance overrides of a parameter defaulted from the width), X/x01 | 10 | STAGE1-CLOSER 10 | 3 chain records (w02) and 5 (x01) default view: walk artifacts, section 3.3 | holds; w02 residue |
| § pcwElabKeepsClaim207v (`R11U207_PCWELAB_OFF`) | CW/w04 `--elabuhdm` | 1 | STAGE1-SAME | 0 | holds |

Judge level over the 172 case-views ([evidence/grid/](evidence/grid/)), from all off to law: EQUAL 19 -> 80 (22
from NOT_EQUAL, 40 from STRICT_NOTEQUAL, 2 more NOT_EQUAL -> STRICT_NOTEQUAL). **One case-view leaves EQUAL: NL/l06
`--elabuhdm`, the break.** With fix.bin it is EQUAL again (81).

### 3.1 Downstream on the fresh cases ([evidence/downstream/cases_join_ON_ALLOFF.txt](evidence/downstream/cases_join_ON_ALLOFF.txt))

All 86 cases, law against both landings off: **16 move toward IDENTICAL, 0 leave IDENTICAL**:

* EQUIVALENT -> IDENTICAL: GS/s01, s02, GV/v01, v02, v03, v05, v06, v08, v09, HV/h02, h03, h04, MI/m03, UT/t09, X/x02.
* STATUS_DIFF -> IDENTICAL: X/x05.

60 are IDENTICAL in both states. Nine are non-IDENTICAL in both, all pre-existing (the slang-lane netlists are
byte-identical in both states): CW/w03, TA/a05, TC/c06, TC/c07 DIVERGENT; TC/c03 EQUIVALENT; NC/n08, UT/t10
STATUS_DIFF. The other two, GV/v04 and GV/v07, stay EQUIVALENT but their nohier moves TOWARD golden's lane: v04 lacks
only golden's `connect \g.r 1'x` (the `= null` initializer), v07 lacks only the wires of the dynamic and queue
handle arrays. The fix on NL/l01-l06 leaves them IDENTICAL.

### 3.2 TR/r06 `--elabuhdm` (the one STAGE1-AWAY verdict), decoded ([evidence/residues/r06_interface_class_alias.txt](evidence/residues/r06_interface_class_alias.txt))

The law binds `function K::b_t g()`'s return to K's listed typedef `b_t`, the object golden binds. Pristine minted an
anonymous class_typespec at the return token, so the name moves toward golden. The new dump lines are that listed
object's own fields: ours is located 7:13-7:26 and aliases `IK::q_t`, in pristine as in law. Golden has that alias
too when the first owner is a plain class, a Surelog specialization-alias defect we model (scratch al1). Here the
first owner is an INTERFACE class, which golden never lists (unsupported `IK::q_t`), so golden's `b_t` has no alias.
The control TR/r08 (r06 with `class IK`) converts from stage 1 to judge-equal under the law (`endcol`: the typedef
span of another package's specialization, pre-existing). No golden-agreeing record is lost (recaway2 / recorder:
away 0 on r06, both views). **Not a break**; residue R-213-2.

### 3.3 The two chain-keyed "away" readings of § parenCastWidthRefPkgBare207 (walk artifacts, not breaks)

* **X/x01** (default view, 5 chain records): the law rebinds the constant `dw`'s cast-width mark to `pk::dw`, which
  is golden's binding (pristine: `work@x01.dw` with `<in>dw`). The "lost" records are the `int_typespec 3:3-3:20`
  children under that binding. Golden's `pk::dw` typespec is a separate copy, so golden's walk expands it. Ours is
  the shared int_typespec already on the walk's path, so the walk stops at the cycle. This is typespec identity,
  which the strict contract canonicalises and excludes.
* **CW/w02** (default view, 3 chain records; re-export `p2` imports and exports `p1`, a module imports `p2`):
  golden binds p2's imported copy's mark to `p1::dw`. Pristine binds it to the importing module's copy `work@top.dw`.
  The law binds it to p2's copy itself (a cycle, not expanded). Neither pristine nor the law agrees with golden on
  the binding. The "lost" records are the int_typespec children of pristine's (wrong) binding, whose content matches
  golden's by type and name. The same law state holds without the module (scratch w02b = v11u207's G/g04 shape:
  pristine and law both bind p2's copy). Residue R-213-1: the design-final re-point
  (`parenCastWidthRefPkgBare207 imported`) does not reach a re-exporting package's own listing.

## 4. BREAK: § namedOrderLinkedDeclines207v's task half compares buffers (refined by § namedOrderProtoAboveAnyBuffer213v)

**Decode (Surelog source only).** `CompileHelper::compileTfCallArguments`
(third_party/Surelog/src/DesignCompile/CompileHelper.cpp 4455-4478) takes `io_decls` from the call's resolved
`task_call::Task()` / `func_call::Function()`. With them it rebuilds the list in FORMAL order, filling
`INT:0` (4546-4561). Without them it pushes `argOrder`, the written order (4562-4565). The link exists when the class's
task has been compiled before the call in Surelog's single pass over the PREPROCESSED file content (`fC` is the pp
output: includes and macro bodies expanded). So a prototype above the call in the flattened text links the call,
whatever file or macro wrote it. slang keeps one buffer per included file and per macro expansion, and the task
half's `m.location.buffer() == callLoc.buffer()` test cannot order two locations in different buffers.

**Grid** ([evidence/fix/nl_calls.txt](evidence/fix/nl_calls.txt), `drivers/calls.py`: each call's link and argument list per database):

| case | shape | golden | pristine (law off) | law | fix |
|---|---|---|---|---|---|
| NL/l01 | `extern task tk(...)` from `` `include "proto.svh" `` in the class body; `tk(.b(2), .c(y), .a(1))` | `task_call` -> `p::F::tk` (proto.svh 1:5): `1 2 y` | `1 2 y` | `2 y 1` | `1 2 y` |
| NL/l02 | the prototype and a `pure virtual task tv` written by macros; `tv(.c(y), .b(1), .a(x))` | `x 1 y` (linked) | `x 1 y` | `y 1 x` | `x 1 y` |
| NL/l06 | the prototype in the file; the CALL written by a macro (`tk(.c(y), .b(5), .a(x))`) and by an included file (`tk(.b(7), .c(y), .a(2))`) | `x 5 y`, `2 7 y` (linked) | `x 5 y`, `2 7 y` | `y 5 x`, `7 y 2` | `x 5 y`, `2 7 y` |
| NL/l06 `--elabuhdm` | the same | STRICT_EQUAL 69 objects with pristine | **STRICT_EQUAL** | **NOT_EQUAL** | **STRICT_EQUAL** |
| NL/l01 first call | `tk(.c(y), .a(x))`, a formal skipped | `x INT:0 y` | `x 3` (v11u207's V3) | `y x` | `x 3` |

The default views stay stage-1 different in every state: our class-body call is a `func_call` where golden writes a
`task_call` (v11u207's V4). The argument order moves away from golden in 6 case-views (l01, l02, l06 x 2), and the
order-aware census reads 4 / 3 / 5 records away in the elaborated views with 0 toward
([evidence/grid/recorder_orderaware.txt](evidence/grid/recorder_orderaware.txt)). The function half is right across
buffers (NL/l05: the call is bound through § externProtoInBodyCallBinds12 and declines by `Function() != nullptr`).

**Refinement** ([fix.patch](fix.patch): src/R213.h, src/ExprEmit.cpp `classTaskProtoAbove207v`): when the prototype and
the call sit in different buffers, `sm->isBeforeInCompilationUnit(prototype, call)` decides (slang's flattened
"compilation unit space" order). Traced as `namedOrderProtoAboveAnyBuffer213v` under `R11V213_TRACE`. Measured:
l01, l02, l06 in both views write pristine's bytes (md5-equal to `R11U207_NAMEDORDER_OFF`), l03-l05 unchanged,
`R11V213_OFF=1` = law.bin's bytes on all 12 NL case-views, downstream IDENTICAL on all six. Gates: section 2.

## 5. Composition ([evidence/compose/](evidence/compose/))

| corpus | conversions both-off (A) -> law (H) | attributed (single-landing-off sweeps 6, 7) |
|---|---|---|
| probe | 7 | OWN207 7: r10buvm4repro/a2_kindgrid, r10uvm167repro/g167_d_decline, r10uvm21repro/t32g_t, r10uvm84repro/g84_c1_lvalue, r10uvm84repro/v84x6_stmt, r10uvm85repro/v85x4_pos, r10v167repro/vB_bare |
| surelog | 2 | OWN207: UnitElabBlock d/t |
| uhdm2rtlil | 2 | OWN206: arb_idx_cast d/t |

Changes (not conversions) are all OWN207: probe 3 (g167_b_spell, t33e_t, v204_s_shadow), surelog 11 (BlackBePipeInt
d/t, BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t, SimpleUVM d/t). **CANCEL 0** at status level.

At byte level over 6647 databases (`drivers/bytecancel.py`): L != A on 28 (OWN206 5 = 3 probe + arb_idx_cast d/t;
OWN207 22 = 10 probe + 12 surelog; BOTH 1 = Scoreboard default, whose sweep-6 draw is the other coin face,
`498cfef0` vs `24ba24eb`, 0 order-blind lines), **CANCEL 0**.

The claims read the same: sweep 6 reproduces exactly pass 206's two conversions, and sweep 7 exactly pass 207's 7 +
3 probe lines and 2 + 11 surelog lines. The byte movers H vs A are 15 corpus + 13 probe + 1 downstream lane
(arb_idx_cast), every one predicted by name by the firing census frozen before the comparison
([evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt), `frozen_at.txt`). The census predicted
two more, SVSwitch d/t and probe r10svs4repro/g1_thisidx (`this.data`: a four-letter name spans `this`'s columns),
and they did not move. Moved and not predicted: 0.

**Cross-ground pairs** (X/, every pair switched off, both views):

| case | pair | reading |
|---|---|---|
| x01 | § tpCastUseBindsDefDefault206 + § parenCastWidthRefPkgBare207: a type-parameter cast in a loop generate whose default width and operand are a package paren-cast width parameter | each alone closer, both closer still (order-blind dump distance 122 with both off, 112 / 97 with one off, 87 with both on); stage 1 in every state |
| x02 | § genScopeClassVarListed206 + § foreachThisArrAtThisToken207: a class declared in a generate block iterating `this.arr` | STRICT_EQUAL with both; each alone closer |
| x03 | § classScopeTdRetBuildsOwner206 + § namedUnlinkedWrittenOrder207: a reordered named call to an extern method returning `K::q_t` | **STRICT_EQUAL (106 / 115 objects) only with both**; 207 off: stage 1; 206 off: `name(1)` |
| x04 | § unitClassTdEndAtInitIfcPrg206 + § hiddenBlockVarMintNoFile207: a `.sv` interface with a `$unit` typedef variable instantiated by a `.v` module hiding a block variable | STRICT_EQUAL with both; each alone moves only its own records |
| x05 | § genScopeClassVarSpecAtName206 + § bitSelMethodCallIdxSpan207: `c #(3) q` in a generate scope, `a[q.get(k)]` | STRICT_EQUAL with both; downstream STATUS_DIFF -> IDENTICAL |

No pair's joint effect differs in sign from its members'.

## 6. The CHANGES: unmasking proofs and the away census ([evidence/unmask/](evidence/unmask/), [evidence/census/](evidence/census/))

`drivers/unmask2.py` (golden against each database, records with walk indices):

| comparison | probe | surelog | uhdm2rtlil |
|---|---|---|---|
| both landings (A -> H) | CONVERSION 7, SUBSET 3 | CONVERSION 2, SUBSET 10, UNMASK 1 | CONVERSION 2 |
| landing 206 (6 -> H) | - | - | CONVERSION 2 |
| landing 207 (7 -> H) | CONVERSION 7, SUBSET 3 | CONVERSION 2, SUBSET 10, UNMASK 1 | - |

Every shrunk count is a strict subset: g167_b_spell 6 -> 2, t33e_t 8 -> 2, v204_s_shadow 3 -> 1, BlackBePipeInt t
2 -> 1, BuildUVMPkg d/t 11 -> 7, and the UVM rows 71 -> 70, 65 -> 64, 95 -> 94, 103 -> 102. The UVM rows keep the same
first record and the same walk divergence (#20788-#22506). The one UNMASK is BlackBePipeInt default: the two
`fullname` records at #66 / #67 go, and the walk now diverges at #15272 (one record: a `tagged_pattern` child order,
pass 207's residue 3). NEW 0.

**Away census** (map 12's method, `drivers/awayrows.py`: records keyed by ancestor chain, and flat; LOST = golden and
the off side share, the law side lacks):

| landing | databases | toward (chain / flat) | lost |
|---|---|---|---|
| 206 (6 -> H) | 6 (arb_idx_cast d/t, 3 probe, Scoreboard default's coin) | 13 / 13 | **0** |
| 207 (7 -> H) | 23 | 701 / 717 | **0** |
| both (A -> H) | 28 | 714 / 730 | **0** |
| positive control (H -> A) | 28 | 0 | **714** chain / 730 flat |

Map 13's figures (pass 206: 6 databases, 13 toward; pass 207: 23, 701) reproduce exactly.

## 7. Downstream (rows and the passes' cases)

| row | law | both landings off | golden lane |
|---|---|---|---|
| arb_idx_cast (downstream lane) | IDENTICAL `OK,OK,11,11` | IDENTICAL | the lane database moves (the cast binding), the netlists stay byte-identical, in all seven sweeps |
| UnitElabBlock (surelog row, `drivers/dsrow.py`, `top.v` without `-sv`) | **IDENTICAL** (nohier byte-identical to the Surelog lane) | EQUIVALENT (nohier, il: the implicit wire's `\src`) | [evidence/downstream/unitelabblock.txt](evidence/downstream/unitelabblock.txt) |

The passes' own cases ([evidence/downstream/passcases_join_ON_ALLOFF.txt](evidence/downstream/passcases_join_ON_ALLOFF.txt), 84 cases):
pass 206's VG/g01-g07 EQUIVALENT -> IDENTICAL (7, confirmed). v11u206's C/c04 and E/e01-e15, e18-e20 EQUIVALENT ->
IDENTICAL: 19 where v11u206 reported 18 (its per-case downstream list was not packaged, so the extra case is not
named). Pass 207's U/u01, u02 and v11u207's A/a01, a02 EQUIVALENT -> IDENTICAL (confirmed). None leaves
IDENTICAL. v11u206's A/a12 DIVERGENT and v11u207's C/c02, G/g01 stay non-IDENTICAL in both states.

**UVM order-blind distances** (`drivers/uvmdist.sh`, [evidence/residues/uvmdist_H_A.txt](evidence/residues/uvmdist_H_A.txt); dist = records ours
holds that golden lacks, sym = dist + records golden holds that ours lacks; both modes equal):

| row | both off (A) dist / sym | law (H) dist / sym |
|---|---|---|
| MiniAmiq | 6634 / 15058 | 6565 / 14920 |
| SeqDriver | 5194 / 11252 | 5115 / 11094 |
| SimpleUVM | 2074 / 4060 | 2017 / 3946 |
| Scoreboard (default) | 1526 / 3029 | 1480 / 2937 |
| BuildUVMPkg | 776 / 1551 | 739 / 1477 |

A reproduces map 13's 4acbe8a5 figures exactly (pass 206 moves no UVM record). H reproduces pass 207's sym figures
exactly. The first records at the base are in section 10.

## 8. Determinism ([evidence/determinism/](evidence/determinism/))

law.bin, the sweep's own command lines and cwd, concurrent draws (`drivers/det.sh`, `drivers/ob.sh`):

| row | draws per mode | distinct hashes | reading |
|---|---|---|---|
| Earlgrey_0_1 | 6 concurrent + 4 sweeps (H, F, 6, 8) | 1 / 1 (`15e6e48bc148`, `e449573deea9`, the hashes pass 206 reported) | deterministic |
| BuildUVMPkg | 3 + 5 + 5 + 6 concurrent + 4 sweeps = 23 | 1 (`7c0083c739f6`, default = testflags) | the `this_type` class_typespec is present (145 dump lines); v11u202's V2 draw not reproduced in 23 |
| SeqDriver | 3 + 10 concurrent + 4 sweeps | 1 / 1 (`05bc42521016`, `0d4f5053d8bf`) | **map 13's second testflags hash (8 of 10 under its law binaries) does not reproduce at HEAD: 0 of 10**; with pass 207 off (sweep-7 wrapper) also 0 of 10 (`5388c9e9503c`): pass 207 does not change the draw rate |
| SimpleUVM | 3 + 4 sweeps | 1 / 1 | deterministic |
| MiniAmiq | 3 + 4 sweeps | 2 / 2 (`de78d9e916c4` concurrent, `f1dbe61971fc` sweeps; also `17adb057`/`dd9e7e67` in sweeps A / W) | order-blind 0 lines, ordered dump (ids stripped) 0 lines: storage order only |
| Scoreboard default | 3 + 7 sweeps | 2 (`24ba24eb6c91`, `498cfef0fcc3`) | order-blind 0 lines; the ordered dump differs by **92 lines** (`svunit_pkg::svunit_base`'s vpiTaskFunc listing order): the reader-visible coin, confirmed |

**Rebuild identity** ([evidence/determinism/rebuild_identity.txt](evidence/determinism/rebuild_identity.txt)): two independent builds of the pristine
source at HEAD (the main tree's and this worktree's) are byte-identical (`6292e702987d`), so every database of one is
the other's. The fix built incrementally and from a fresh worktree gives the same md5. The r11u204 twin helper's
orphan (r11u196repro V191/qr01) is `f399f67bbbcc` in 4 of 4 runs of law.bin and of fix.bin: deterministic per binary,
and unchanged by a rebuild that recompiles only ExprEmit.cpp.

## 9. The residues of the pairs, re-measured at the base ([evidence/residues/](evidence/residues/))

| residue (top three of each) | status at `baf91896` |
|---|---|
| 206 R1 the build-dependent orphan (qr01) | stands, deterministic per binary (section 8) |
| 206 R2 anon_struct_packed_dim d/t `fullname(43)` | stands: #112 `ref_typespec <in>pte_t.ppn`, raw golden `gpte.pte_t.ppn`, ours `pte_t.ppn` |
| 206 R3 InterfaceStructMemberPort d/t `fullname(6)` | stands: #336 `struct_net req` ours `work@top.w.sub.sub.req.req`, golden no full name |
| v206 1 a return whose owner sorts earlier (D/d04, d07, d08) | stands (stage 1 both views) |
| v206 2 R5 wider: `c #(.W(8)) q` in the definition view (E/e05) | stands (stage 1); confirmed on the fresh GS/s01 (`c\n#(5, byte) b` stmt-ified by golden) |
| v206 3 the typedef-end writer in a macro / include (C/c09, c10) | stands: `endcol` / `file` (judge-equal) |
| 207 #1 the UVM first records | stand: MiniAmiq #899 (`uvm_severity` file), SeqDriver #10090 (`<in>uvm_pkg::uvm_event_pool`), SimpleUVM #458 / Scoreboard #466 (`UVM_MACRO_NUMFLAGS`), BuildUVMPkg #3245 (`uvm_action` line) |
| 207 #2 the paren-less TF-ITEM body variable (a fresh probe, cases/R/q01) | stands: `m1;` locates `first`, `clp`, `init` at the data type in golden, at the name in ours; `m2()` agrees (`col(6)`) |
| 207 #3 BlackBePipeInt's next records | stand: d #15272 (`ref_typespec bp_common_pkg` against our constant 2047:16), t #66 (`depth`: the first package listing) |
| v207 V2 foreach over `this.obj.arr` (F/f01) | stands (stage 1) |
| v207 V3 a linked no-link-branch call skipping a formal (B/b09) | stands; also on the fresh NL/l01 (`tk(.c(y), .a(x))`: golden `x INT:0 y`, ours `x 3`) |
| v207 V4 an extern / pure virtual TASK called in-body is a `func_call` (B/b09, b12) | stands (b12 `--elabuhdm` STRICT_EQUAL); on every fresh NL task case's default view |

Rows at the base: CoresSweRV and CoresSweRVMP default read **SURELOG_FAIL** in every sweep here (pass 206's TIMEOUT
was an environment draw, confirmed). Scr1SvTests d/t `type(1)`, Earlgrey_0_1 d/t `fullname(76)`, Rggen d
`defname(142)`, InterfArrayBind d `fullname(3)` and HierPathTypespec t `fullname(1)` (#105, the elaboration clone) are
unchanged.

**New residues of this pass:**

* R-213-1: CW/w02, the re-exporting package's own listing binds its mark to itself (golden: the declaring package's).
* R-213-2: TR/r06, interface-class typedefs join the specialization-alias model that golden (which lists no interface
  class) does not apply.
* R-213-3: the under-reaches found (all law-off = law bytes, stage 1 in both):
  * § tpCastUseBindsDefDefault206 in procedural blocks, generate-scope functions, generate-case inside a loop and a
    class-typedef default (TC/c02, c03, c05, c06);
  * § tpArrayElemBindsDefDefault206 on `tri` / `wand` array_net elements and int defaults (TA/a02, a03, a05);
  * § genScopeClassVarListed206's `= null` initializer and dynamic / queue handle arrays (GV/v04, v07, downstream
    EQUIVALENT);
  * § namedUnlinkedWrittenOrder207 through an interface class or a static extern called from outside the class
    (NC/n04, n05).
* R-213-4: TC/c03 (`t r; r = b ? t'(k + 5) : t'(-1);` in a generate-scope function) and FT/t01 (3-dimensional dynamic
  class properties) read rc 4 (unsupported construct), with a database written, on every state.

## 10. First records at HEAD ([evidence/residues/heads_H_default.txt](evidence/residues/heads_H_default.txt), [heads_H_other.txt](evidence/residues/heads_H_other.txt))

MiniAmiq #899 `file` (`uvm_severity` enum_typespec, golden uvm_globals.svh 271, ours uvm_object_globals.svh 242);
SeqDriver #10090 `fullname`; SimpleUVM #458 and Scoreboard #466 `fullname` (`UVM_MACRO_NUMFLAGS`); BuildUVMPkg #3245
`line` (`uvm_action`); BlackBePipeInt d #15272 `type`, t #66 `depth`; InterfaceStructMemberPort #336; HierPathTypespec
t #105; anon_struct_packed_dim #112.

## 11. Fence and process ([evidence/fence/](evidence/fence/))

**This pass.** Every driver sources `drivers/env.sh`. It reads the four names from the `FENCED=` line of
tools/probe/r11u107repro/canaudit.sh in this checkout and refuses without four (runtime check: rc 1 beside a two-name
canaudit copy, [fencecheck.txt](evidence/fence/fencecheck.txt)). Corpus databases were byte-compared only through
fence-free hard-link mirrors (`fenced_skipped=8`). Every row read by name (UVM rows, BlackBePipeInt, UnitElabBlock,
arb_idx_cast, the residue rows) was checked against the fence by word boundary first; none is fenced. No fenced
source or database was run, read, dumped or decoded, and no gdb was used. The gate sweeps ran the whole corpora, as
the gate does; their csv verdicts of fenced rows are the only fenced facts, and none moved. A word scan of this
directory finds no fenced name (positive control: a planted name found).

**The two laws of each pass nearest the fenced shapes (parameters), re-derived from this pass's own cases and Surelog's
source only:**

* § tpCastUseBindsDefDefault206 and § tpArrayElemBindsDefDefault206: `compileTypespec`'s fallback to the
  definition's own `type_parameter` (CompileType.cpp 1995-2006) returns the definition's object for every use.
  TC/c01, c04 and TA/a01, a04 convert, both views.
* § parenCastWidthRefPkgBare207: `CompileType.cpp` 773-779, where the cast-width `ref_obj` is `Actual_group(lhs)` of
  the declaring `param_assign`'s parameter, with no full name set. CW/w01-w04 and X/x01 are closer, w02 is a residue.
* § namedSlotFillerRootFile207: `CompileHelper.cpp` 4554 `c->VpiFile(fileSystem->toPath(fC->getFileId()))`, the
  compiled root file. SF/f01-f04 fillers carry golden's file, including `b.sv` with two root files.

**The four directories** (static audit [fenceaudit.txt](evidence/fence/fenceaudit.txt), runtime [fencecheck.txt](evidence/fence/fencecheck.txt)):

* **env.sh.** Every env.sh fails closed: 4 names from the checkout, rc 0. r11u206repro's refuses a two-name canaudit
  copy (rc 1). r11u207repro's and v11u207repro's resolve the main repository through git's common dir, so a scratch
  copy has none and refuses (rc 1, 0 names). **v11u206repro's env.sh reads
  `/home/heyfey/git-repos/slang-uhdm/tools/probe/r11u107repro/canaudit.sh` by an ABSOLUTE path**: it is fail-closed,
  but a copy beside another canaudit still reads the main repository's (rc 0, 4 names).
* **v11u206repro (packaged by the integrator from the verifier's scratch; 8 drivers).**
  * 5 read the fence list themselves: `bytectl.sh` (`FENCERE` filter on the tools/probe case list), `case.sh`,
    `dscase.py` (its own canaudit read), `rowrun.sh`, `uvmdist.sh`.
  * `env.sh` is the fence reader itself.
  * **`det.sh` and `sw.sh` do not check it.** `det.sh` re-runs the Earlgrey and UVM row command lines through
    `rowrun.sh`, which refuses the four names; its row list names no fenced test. `sw.sh` runs `law.bin` on the case
    directories of an unpackaged list in `/tmp/v11u206_allcases`, the pass's and verifier's own cases, no corpus
    source or database.
  * Five v11u206repro drivers (`bytectl.sh`, `case.sh`, `det.sh`, `rowrun.sh`, `sw.sh`) source
    `/tmp/v11u206_drv/env.sh`, which no longer exists, so they exit 3 at their first line. `dscase.py`, `uvmdist.sh`
    and `env.sh` name `/tmp/v11u206_*` scratch paths. The packaged directory fails closed, and none of its drivers
    can be re-run from the repository.
* **The other three directories.** The drivers without their own fence check touch no corpus source or database
  directly:
  * r11u206repro: `away.py` and `censum.py` read databases or trace files handed in by fenced callers
    (`awaycorp.sh`, `census.sh`). `grid.sh`, `det.sh`, `detob.sh` and `sweep.sh` run the pass's own cases, go through
    `rowrun.sh`, or run the gate's own sweep.
  * r11u207repro: `away.py`, `censum.py`, `ctlbytes.sh` / `ctlsum.py` and `judge.sh` (tools/probe case lists judged
    through `case.sh`, which refuses fenced paths), `grid.sh`, `obdist.sh`, `switchcheck.sh`.
  * v11u207repro: `away.py`, `calls.py`, `censum.py`, `ctlbytes.sh` / `ctlsum.py`, `jall.sh`, `judge.sh`,
    `switchcheck.sh` and `tr.sh`, of the same kinds.
* **Relative writes.** No driver of the four directories writes relative to its current directory. The static scan's
  hits are `censum.py`'s docstring word and `sw.sh`'s `done < list.txt`, a READ inside `cd /tmp/v11u206_allcases`.
* **Predictions.**
  * Pass 206's `evidence/census/predicted_movers.txt` (5 rows: 3 probe cases + arb_idx_cast d/t) is stamped
    `2026-09-28T10:07:17-04:00`, before the landing commit (11:43:24). Its `frozen_at.txt` carries no md5, so the
    stamp is not bound to the content.
  * Pass 207's `evidence/predicted_movers.txt` (md5 `b50e87e6`: 15 corpus row-modes, 11 probe cases, 0 downstream
    lanes) is stamped `15:03:39 UTC` (11:03:39 -04:00) with lawF.bin's md5 but not its own. v11u207's frozen copy
    carries the same md5 `b50e87e6`, stamped 12:47:14 -04:00, before the landing (13:23:37).
  * The pairs' sweep workdirs are pruned, so the order against the sweeps rests on these stamps.
  * **The brief's figures for pass 207's prediction ("20 corpus row-modes, 6 probe cases, 1 downstream lane") are not
    the file's.** The file holds 15 / 11 / 0, as pass 207's README says.
  * Every database either landing moves here is inside its prediction. This pass's own census at HEAD equals pass
    206's 5 rows + the arb_idx_cast downstream lane (pass 206's census ran no downstream lane) + pass 207's 26 rows,
    line for line.
  * Pass 206's README says "57 cases" for its grid; the directory holds 56 case directories (TE 17, UT 17, TR 8,
    VG 7, VN 7).
* **Packaged cases** ([casefirst.txt](evidence/fence/casefirst.txt)): every case of the four directories (56 + 68 + 29
  + 47) and of this one (86) carries a `§` first line, and every law named exists in src.

## 12. Files

* `fix.patch`: the refinement (src/ExprEmit.cpp `classTaskProtoAbove207v`, src/R213.h), not applied.
* `cases/`: 86 cases in these groups:

  | group | law |
  |---|---|
  | TC | § tpCastUseBindsDefDefault206 |
  | TA | § tpArrayElemBindsDefDefault206 |
  | UT | § unitClassTdEndAtInitIfcPrg206 |
  | TR | § classScopeTdRetBuildsOwner206 |
  | GV | § genScopeClassVarListed206 |
  | GS | § genScopeClassVarSpecAtName206 |
  | HV | § hiddenBlockVarMintNoFile207 |
  | NC | § namedUnlinkedWrittenOrder207 |
  | NL | § namedOrderLinkedDeclines207v, the break |
  | SF | § namedSlotFillerRootFile207 |
  | MI | § bitSelMethodCallIdxSpan207 |
  | PM | § parenMethodCallPathSpan207 |
  | FT | § foreachThisArrAtThisToken207 |
  | CW | § parenCastWidthRefPkgBare207 |
  | X | cross-ground pairs |
  | R | residue probe |

* `drivers/`:
  * `env.sh`: pins and the fence.
  * `laws.py`: the switch map.
  * `grid.py` / `gridall.sh` / `case.sh`: the law grid.
  * `lawtable.py`.
  * `recaway2.py` / `recorder.py` (order-aware, new) / `dumpaway2.py`: case-level away checks.
  * `calls.py`: call lists.
  * `dscase.py` / `dsrow.py`: downstream.
  * `sweep.sh` / `queue.sh` / `mkstate.sh`: gate sweeps and state wrappers.
  * `censum.py`: the census.
  * `bvmirror.sh` / `lanebytes.sh`: byte comparisons.
  * `compose.py` / `bytecancel.py`: composition.
  * `unmask2.py` / `awayrows.py`: unmasking and the away census.
  * `uvmdist.sh`, `heads.sh`.
  * `det.sh` / `ob.sh` / `obpair.sh`: determinism.
  * `firecensus.sh`: the fix's boundary.
  * `fencecheck.sh` / `fenceaudit.py` / `casefirst.py`: the fence and the case audit.
* `evidence/`: `sweeps/`, `grid/`, `fix/`, `compose/`, `unmask/`, `census/`, `downstream/`, `determinism/`,
  `residues/`, `fence/`.

The law index (tests/LAWS.md) is stale against this directory's new cases (the sweeps after H print
`law index STALE`); the integrator regenerates it with scripts/law_index.py.
