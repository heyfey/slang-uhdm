# r11v11u118 — adversarial verification of r11u118 (pair A, the value-and-name ground)

**Verdict: ACCEPT-WITH-FIX.** The implementer's headline reproduces bit for bit:
`pkg_localparam_partsel` goes DIVERGENT -> IDENTICAL, the other four targeted rows
stay DIVERGENT on decodes that sit in `src/ModuleEmit.cpp` (fenced), and every gate
holds. Across 56 fresh arms and the implementer's 56, no probe arm, corpus row or
downstream row moved away from golden. Two cells of the law were not exact on fresh
arms, and neither face occurs in either corpus:

1. The law's range-only span dropped a parenthesized bound's written parentheses.
2. The folded-bound ref_typespec lost its scope prefix.

Pristine was wrong on both cells as well, so neither is a regression, only a gap in
the law. Both are fixed here, each under its own switch. The shipped patch is
`/tmp/r11u118.verified.patch`.

Base `849800d1`, branch `matrix-1.87`. Worktrees `/tmp/wt_v11u118` (patched) and
`/tmp/wt_v11u118pris`, built `-j 2`.

| binary | md5 | what |
|---|---|---|
| pristine | `ac66a3d985fbeb31fd157e4e3b06b11e` | equals the main tree's `build/slang-uhdm` |
| implementer LAW | `74fb40af499ec4e3a5167de45f130ff4` | `/tmp/r11u118.patch`; equals the implementer's md5 |
| paren-only (intermediate) | `7268f412bbd4d0f611e2349a09f8d514` | LAW + § pkgQualPsParenSpan118v |
| **FINAL** | `311fb4c52783d5b1badfda477cc96f1a` | LAW + both verifier laws = the verified patch |

All binaries were frozen as `chmod 555` copies before any measurement. Every
`cmds.txt` of the three full sweeps names only that sweep's frozen binary (3273 of
3273 `slang:` lines per workdir).

## Q1. The five heads at 849800d1 (reproduced)

`scripts/downstream_uhdm2rtlil.py --filter` on the five rows, pristine binary
(`evidence/ds_five_P.csv`); all five read DIVERGENT. The nohier diffs, with the
surelog lane on the `<` side:

| row | surelog lane | slang lane |
|---|---|---|
| pkg_localparam_partsel | `connect \B 305419896` | `connect \B 0` |
| PartSelectOfMember (IndexedPartSelectOfMember is the same) | `connect \a [0] 1'1`, `[7]`, `[8]` | `1'x` |
| SelectOnMemberSelectedFrom2DArray | `connect \a [2] 1'1` | `1'x` |
| iface_array_elem_cfg_param | `connect \A 8` | `connect \A 16` |

uhdm-cmp reads 0 lines on all five, under both the probe flags and the downstream
flags.

## Q2. Decodes (checked against the databases)

### Face 1: pkg_localparam_partsel (landed)

**What the plugin reads.** The plugin takes the select's name from VpiDefName
([expression.cpp:6987](../../../third_party/uhdm2rtlil/src/frontends/uhdm/expression.cpp#L6987)).
It then looks that name up in `package_parameter_map`
([:7092](../../../third_party/uhdm2rtlil/src/frontends/uhdm/expression.cpp#L7092)),
whose keys are `pkg::NAME`.

**How Surelog writes the field.**

- Package-scope branch: [CompileExpression.cpp:2717](../../../third_party/Surelog/src/DesignCompile/CompileExpression.cpp#L2717).
- Explicit `pkg::NAME` fullname on the part_select:
  [:4260](../../../third_party/Surelog/src/DesignCompile/CompileExpression.cpp#L4260).
- Explicit fullname on the var_select:
  [:1324](../../../third_party/Surelog/src/DesignCompile/CompileExpression.cpp#L1324).

**Golden versus ours.** Golden's downstream-lane cell is
`part_select 15:39-15:47 name/def/full='mask_pkg::MASK'`, with the bound ref named
`work@pkg_localparam_partsel.mask_pkg::MASK.XLEN`. Pristine's cell was
`15:24-15:48 name='MASK' full='work@pkg_localparam_partsel.MASK'`.

**Why the judge is blind to it.** `part_select::Compare` inserts `this` into
m_visited
([part_select.cpp:84](../../../../Surelog/build/third_party/UHDM/generated/src/part_select.cpp#L84)).
It then calls `ref_obj::Compare`, which checks VpiType and then returns at its own
visited check
([ref_obj.cpp:129](../../../../Surelog/build/third_party/UHDM/generated/src/ref_obj.cpp#L129)).
The name, the def-name and every field below them are never compared.

### R1: IndexedPartSelectOfMember, PartSelectOfMember, SelectOnMemberSelectedFrom2DArray (fenced)

**Golden.** The elaborated `cont_assign#73` shares the definition view's
`constant#6 UINT:1 size=64 ctype=9`, re-parented to `#73`.

**Ours.** We mint `constant#55 val='' size=0 ctype=0 parent=NULL` at
[ModuleEmit.cpp:36688](../../../src/ModuleEmit.cpp#L36688) (`memberSelLitLhs`).
The plugin reads constant type 0, logs "Unsupported constant type" and produces `x`.

### R2: iface_array_elem_cfg_param (fenced)

**Golden.** The port-view `work@top.u.s.CFG` parameter is parented at
`param_assign#292`, so the plugin reads the interface default, 8.

**Ours.** The same parameter is parented at the `interface_inst`, so the plugin
follows the connection and reads 16. That 16 is the value the test is written to
expect: this is a case where golden's semantics are wrong and ours are right.

## Q3. Grids

Every arm is judged by uhdm-cmp against the v1.87 pin (probe flags) and by the
downstream verdict (`ds.one`, which uses uhdm2rtlil's own v1.87-5 Surelog). Field
cells come from `r11u118const`, and the order-blind whole-dump lines are compared
against the downstream-lane golden. Every arm records the exit code of every producer
run, and every run exited 0.

**The arms.** The 56 fresh verifier arms are in `grid/v1`–`grid/v4`:

- `v1` covers the faces and contexts: parens, shadowing, task, port default,
  parameter override, package-in-package init, indexed variable/down, var_select
  variable/3-D, concat parameter, if/gen-if/gen-for, class method, bit bound,
  compare, package function, always_ff, module-param bound, 2-D element/range,
  interface modport port, and var_select in function/ff/bit/indexed/gen-for.
- `v2` covers the self-package, an indexed select in a package function, initial,
  unpacked slice, typedef dimension, gen-if condition, indexed override, both-paren
  bounds, latch, case item, a package-param bound in a function, and a named block.
- `v3` covers folded package-param bounds (the ref_typespec face) under
  var_select / ff / function / paren / localparam init / gen-for / class / bare /
  task.
- `v4` covers macros (base, whole select, bound, argument), `::` with spaces, and
  bounds split across lines.

| set (arms) | pristine downstream | LAW downstream | FINAL downstream | uhdm-cmp |
|---|---|---|---|---|
| verifier v1–v4 (56) | 22 IDENTICAL, 28 DIVERGENT, 4 STATUS_DIFF, 2 EQUIVALENT | 50 IDENTICAL, 6 DIVERGENT | 50 IDENTICAL, 6 DIVERGENT | 29 arms at 0 stay at 0; not-equal arms keep their head (−2 lines) |
| implementer g1–g3 (56) | 28 IDENTICAL, 25 DIVERGENT, 2 EQUIVALENT, 1 STATUS_DIFF | 51 IDENTICAL, 5 DIVERGENT | 51 IDENTICAL, 5 DIVERGENT | 41 arms at 0 stay at 0 |

- No arm leaves IDENTICAL. No arm's uhdm-cmp count grows. No arm leaves 0.
- On the implementer's grid the verifier reproduces g1 exactly: pristine 15
  IDENTICAL, 21 DIVERGENT, 2 EQUIVALENT, 1 STATUS_DIFF, and LAW 38 IDENTICAL plus
  p28.
- g2 and g3 are byte-identical between pristine and LAW.

Every field line the LAW adds that golden lacks was followed to its object. Each one
is a sideways move on a cell pristine already got wrong:

- A var_select whose fullname now matches golden but whose parent still differs
  (golden parents it at the package **parameter**).
- Duplicate definition/elaboration cells, where golden has one cell.
- The case_item-versus-begin parent in w10.
- The two faces below.

**Face V1, a parenthesized bound** (`v01 cfgp::K[(cfgp::N-1):0]`, `w08
[ ( 15 ) : (cfgp::N) ]`).

| cell | span |
|---|---|
| golden | 10:22-10:35 and 10:23-10:41 |
| pristine | the whole expression |
| LAW | 10:23 and 10:25-10:40 |

slang keeps the inner sourceRange and records the `ParenthesizedExpression` only as
`syntax`
([Expression.cpp:1002](../../../third_party/slang/source/ast/Expression.cpp#L1002)).
**FINAL: both spans equal golden.**

**Face V2, the folded-bound ref_typespec** (p13, p22, v01, w11, w12, x05–x09). The
folded-bound rule reads the select's fullname verbatim, at
[ExprEmit.cpp:17764](../../../src/ExprEmit.cpp#L17764). The law's explicit
`cfgp::K` turned the ref_typespec into `cfgp::K`.

| cell | ref_typespec fullname |
|---|---|
| golden (computed through the chain) | `work@top.blk.cfgp::K`, `work@top.f.cfgp::K`, `work@top::C::get::cfgp::K`, `work@top.t.cfgp::K`, `work@top.mask_pkg::MASK` |
| pristine | `work@top.blk.K` and so on |
| **FINAL** | equal to golden on every arm listed |

The var_select's trailing part_select (x01–x03) keeps its pristine ref_typespec
bytes. There, golden's name is `cfgp::A2::cfgp::A2::cfgp::A2`, an artifact of
parenting at the package parameter, so it remains residue RV3.

## Q4. Laws and switches

| law | switch | where | owner |
|---|---|---|---|
| § pkgQualParamPartSelName118 | `R11U118_PKGPS_OFF` | ExprEmit.cpp plain/indexed RangeSelect site | implementer |
| § pkgQualParamVarSelFull118 | `R11U118_PKGVS_OFF` | the two § pkgWrittenQualSelBase41 var_select sites | implementer |
| § pkgQualPsParenSpan118v | `R11U118_PSPAREN_OFF` | [ExprEmit.cpp:32536](../../../src/ExprEmit.cpp#L32536), [EmitHelpers.h:14087](../../../src/EmitHelpers.h#L14087) | verifier |
| § pkgQualPsRtFull118v | `R11U118_PSRTFULL_OFF` | [ExprEmit.cpp:1966](../../../src/ExprEmit.cpp#L1966), [:17767](../../../src/ExprEmit.cpp#L17767), [:30672](../../../src/ExprEmit.cpp#L30672), [:32509](../../../src/ExprEmit.cpp#L32509), [EmitHelpers.h:14105](../../../src/EmitHelpers.h#L14105) | verifier |

`R11U118_OFF=1` turns off all four laws. The switch audit ran on all 112 arms with
fresh output files; the results are in `evidence/SWITCH_final.txt` and were produced
by `switch2.sh`:

- FINAL with `R11U118_OFF=1` equals pristine bytes on 112 of 112 arms.
- FINAL with both verifier switches off equals the implementer's LAW on 112 of 112.
- Each implementer switch alone, with the verifier switches off, equals LAW with the
  same switch on 112 of 112.
- `PSPAREN_OFF` moves v01 and w08 only; `PSRTFULL_OFF` moves 13 arms.

## Q5. Census (predicted by name from the pristine databases)

`cen118.py` on the pristine sweep (4128 rows) predicts the LAW movers:

- surelog: Earlgrey_0_1 (G=32/59, O=28/52) and EarlgreyPackParam (G=1), both modes;
- uhdm2rtlil: pkg_localparam_partsel, both modes;
- downstream: pkg_localparam_partsel.

Positive control: pkg_localparam_partsel reads G=2 X=0.

For the verifier laws the predicted movers are **zero** in every corpus:

- None of the 7 Earlgrey law cells has a parenthesized bound (source lines
  prim_prince 59, 81, 106, 142, 167 and dm_mem 273, 471).
- No Earlgrey ref_typespec moved between pristine and LAW (0 changed ref_typespec
  lines in either mode). Earlgrey's DataWidth-bound ref_typespec is `work@prim_prince`
  on both binaries, which is a pre-existing residue that does not go through the
  verbatim rule.

The positive control for the verifier laws is the arms v01, w08, p13 and the others
listed above, which do move.

## Q6. Gates

Sweeps: `tests/sweep.sh --jobs 3`, workdirs `/tmp/v11u118_wd{P,L,G}` (same length).

1. **Build.** Pristine md5 equals the main tree; LAW md5 equals the implementer's;
   FINAL is `311fb4c5…`.
2. **Probe.** EQUAL=2833 (of 2833) on P, L and G.
3. **Corpora.** `regressions=0 conversions=0 changes=0` in both corpora on P, L and
   G.
   - surelog: 480/3 and 474/3.
   - uhdm2rtlil: 803/1/67 in both modes.
   - The status column is identical row for row between P, L and G.
   - Earlgrey_0_1's dump column read blank on L and G because of the 180 s dump
     timeout under the two concurrent sweeps. A rerun of that row alone on FINAL
     reads `CMP_EQUAL … differ` in both modes, the same as pristine.
4. **Downstream.** Only pkg_localparam_partsel moves verdict (P→L and P→G).

   | sweep | IDENTICAL | EQUIVALENT | DIVERGENT | SLANG_REJECT |
   |---|---|---|---|---|
   | P | 780 | 20 | 5 | 66 |
   | L | 781 | 20 | 4 | 66 |
   | G | 781 | 20 | 4 | 66 |

   **Fresh row: `pkg_localparam_partsel,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.** On
   FINAL its downstream-lane database is order-blind identical to golden's (0 field
   lines, 0 dump lines).

   `gen_test7` reads EQUIVALENT against results/ on all three sweeps. Its database
   is byte-identical across them (`93600fca…`). Run alone (three serial runs and one
   `--jobs 3` run of gen_test[0-9]) it reads IDENTICAL on pristine: it is a coin
   inside the plugin under load, not a mover.
5. **uhdm-cmp.** 0 lines on the five rows, under both flag sets, on FINAL.
   pkg_localparam_partsel, Earlgrey_0_1 and EarlgreyPackParam are CMP_EQUAL in both
   modes.
6. **byteverify** (SELFCHECK 959/960, 1607/1608, 804/805):

   | comparison | surelog | uhdm2rtlil | downstream |
   |---|---|---|---|
   | L vs P | 10/960: Earlgrey_0_1 ×2 and EarlgreyPackParam ×2 (predicted), plus the UVM coin MiniAmiq/SeqDriver/SimpleUVM ×2 | 2/1608 (pkg_localparam_partsel ×2) | 1/805 (pkg_localparam_partsel) |
   | G vs L | 5/960, the UVM coin only; Earlgrey/EarlgreyPackParam byte-identical as predicted | 0/1608 | 0/805 |

   - Every UVM mover is 4 order-blind lines, `UINT:`/`vpiDecompile:` 0 against N.
   - EarlgreyPackParam, order-blind: 7 lines, all on the law's `AsyncOn` cell.
   - Earlgrey, attributed per object: every elaborated var_select and part_select
     header at prim_prince 106:29/106:68 and 142:30/142:86 moves to golden's
     `(prim_cipher_pkg::PRINCE_ROUND_CONST)`. The 3+3 def-view `gen_*_pass.` cells
     remain (R7, TypeEmit).
   - A line-multiset tally reads 15 "away" lines per mode. They are text
     coincidences: pristine's doubled part_select fullname equals golden's text on a
     **different** object, the DataWidth-bound ref_typespec, which is
     `work@prim_prince` on both our binaries.
7. **Canaries.**
   - Against the pristine sweep: surelog ok=50 changed=2, both the Earlgrey
     dump-blank timeout; uhdm2rtlil ok=16 changed=0; ctcan2 PASS in both corpora.
   - Against results/: the pristine sweep itself reads ok=43 changed=9 and ctcan2
     FAIL. That is dump-column drift at the base.

## Residues, ranked

- **R1** (fenced, [ModuleEmit.cpp:36688](../../../src/ModuleEmit.cpp#L36688)): 3
  rows. Share the definition's constant and re-parent it.
- **R2** (fenced, ModuleEmit port-view parameter): 1 row. Parent the port-view
  aggregate parameter at its param_assign.
- **R7** (fenced, TypeEmit): the definition-view generate-scope form of the same
  cell. Earlgrey has 3+3 per mode.
- **RV1** (ExprEmit, pre-existing `selRange` at the two § pkgWrittenQualSelBase41
  sites): a var_select's trailing part_select drops a parenthesized bound's `(`
  (x04: ours 10:27, golden 10:26). Pristine behaves the same way.
- **RV2** (Surelog/plugin semantics): v08, v11, v22, w04 and x03 read DIVERGENT on
  both binaries. In each of them the surelog lane computes the wrong value (for
  example `PK2[11 -: 4]` gives 0100 where the correct value is 0010) and our lane
  computes the right one. v27 differs structurally (autoidx). None of these shapes
  is in the corpora.
- **RV3**: golden parents a qualified var_select at the package parameter. Its
  ref_typespec name `pkg::A::pkg::A::pkg::A` and the var_select's parent differ
  from ours. This is judge-blind and downstream IDENTICAL.
- The implementer's R3–R6 are confirmed as stated: p28 not equal at base; the
  size-1 constant in m07; p17's span; the orphan ref in p13 and p22.

## Drivers

- `varm.sh <arm> <out> <binA> <binB>`: runs both goldens, both binaries and both
  flag sets, and reports rc, cmp, downstream verdict, field and dump mismatch sets,
  and the lines each binary adds.
- `vgrid.sh`: runs `varm.sh` over a list of arms, 3 jobs.
- `switch.sh` and `switch2.sh`: the switch audits.
- `rtchain.cpp`: ref_typespec fullname plus parent chain.
- `tow.py`: the line-multiset toward/away tally, with the caveat above.

Build the C++ tools like r11u118's
(`g++ -std=c++20 -O1 X.cpp -I$HOME/.local/include $HOME/.local/lib64/lib{uhdm,capnp,kj}.a -lpthread`).
