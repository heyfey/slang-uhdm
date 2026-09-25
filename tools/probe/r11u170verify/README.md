# r11u170: second adversarial verification of passes 158, 160 and 163 (verifier, measurement plus one refinement patch)

Base `d8cfd83a` (branch matrix-1.87). Pass 158 landed at `202fb296`, pass 160 at `d48f8f8a`, pass 163 at `576b21fa`;
the commit before pass 158 is `0f607463`. Worktrees: `/tmp/wt_r11u170` (HEAD, the deliverable), `/tmp/wt_r11u170pre`
(`0f607463`), `/tmp/wt_r11u170fix` (HEAD + [fix.patch](fix.patch)). System-deps configuration, `-j 2`.

This directory is the whole deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is
edited. The refinements are [fix.patch](fix.patch), a `git diff d8cfd83a -- src` that applies clean on a fresh
`d8cfd83a` (`git apply --check` measured). It is NOT applied here. No canonicalisation patch for
`tools/uhdm-strictcmp` was handed to this pass, and no comparator defect was found, so the comparator is not edited.

The slang-fenced tests are named nowhere here. [drivers/env.sh](drivers/env.sh) builds `$FENCED` from RESUME.md without
spelling it. Every driver that reads corpus sources or databases refuses to run without it and skips those names by
word boundary.

## Verdict

**Three breaks found, all fixed behind their own switches in fix.patch.** Each is a law of the three landings moving a
field away from golden on legal SystemVerilog:

| break | law | shape | axis |
|---|---|---|---|
| B1 | § genCaLhsEnumConstClone158 | the enum type is declared at compilation-unit scope, or its package is imported there | strict: 4 cases STRICT_EQUAL -> STRICT_NOTEQUAL `file`; 3 stage-1 cases farther from golden |
| B2 | § defNetTypeParamPackedVec160 | a NET declaration (`wire T [N-1:0] w;`) of the vector half | the default typespec's end moves off golden on 3 stage-1 cases (gate-invisible, the pass-158 verifier's B3 precedent) |
| B3 | § sizeCastCaSignedSize158 | a size cast of a PACKAGE-SCOPED name (`2'(pk::V)`) or a `$unit` name | downstream EQUIVALENT -> DIVERGENT on 2 cases (the signed branch's INT:-1 where golden masks unsigned) |

The refinements move every break case toward golden:

- 4 cases become STRICT_EQUAL.
- 3 downstream cases go DIVERGENT -> IDENTICAL.
- The rest are closer by dump distance.

They move no probe case, no corpus database (apart from the UVM order coin) and no downstream row. The census before
the fix sweep predicted zero firings, with a positive control.

**Composition: additive.**

- `R11U157_OFF R11U158_OFF R11V158_OFF R11U160_OFF R11U163_OFF R11V163_OFF` gives the bytes of the pre-158 build
  everywhere: probe 0/4087 movers, corpora 7/2560 (the UVM coin only), 176/176 fresh cases in both modes.
- Every conversion the landings claimed is owned by exactly one landing, except three row-modes that either landing
  converts alone: gen_scope_numports d/t and probe `r11u20repro/t3`.
- No conversion needs two landings, and no pair of laws cancels: 0 rows at the status level, 0 databases at the byte
  level.
- Two laws are shadowed at HEAD:
  - § elabTpDefaultDefNamed163 is verdict-redundant with § tpUseBindsDefDefault160 on the whole gate, except one
    count on `r11u20repro/t6`.
  - § aggParamFoldUnqualWholeSpan158 changes no byte while pass 163 is on.

**Changes: all unmaskings or strict improvements.** The 67 probe + 13 surelog + 8 uhdm2rtlil CHANGE lines of the three
landings at HEAD were re-read record by record, and field by field where the record text moved:

- pass 158: 24 + 11 + 0, all SUBSET;
- pass 160: 25 + 2 + 8;
- pass 163: 32 + 0 + 0, all SUBSET.

The nine grown counts of pass 160 are UNMASK. No broken cell appears anywhere.

**Fence: held.**

- No law, case or number rests on a fenced reading. The fenced rows' verdicts are identical with all three landings
  on, all off and in the pre-158 build.
- Three drivers of the six directories do not meet the fence rule on their own (section 9).
- § uncaughtExitsReject160 exits 3 on every standard exception type, including kj's. A non-standard thrown type still
  aborts, but none can be thrown by the linked code.

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u170_bin/law.bin` | `2a705713aa2d9ba859d3fd83eaa95ed7` | worktree build of d8cfd83a = the main tree's `build/slang-uhdm` (the brief's `2a705713aa2d`) |
| `/tmp/r11u170_bin/pre.bin` | `a52c8ec19093858f0da7a4daae5bfbad` | build of `0f607463`, the commit before pass 158 (= r11u162's fix.bin) |
| `/tmp/r11u170_bin/fix.bin` | `6f3af056ead6eeaf3ee28be2d1c1e01c` | d8cfd83a + fix.patch (with its census traces) |
| `/tmp/r11u170_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `alloff.sh`, `off158.sh`, `off160.sh`, `off163.sh`, `offTPDEFNAME.sh`, `offTPUSEDEF.sh` | wrappers | law.bin under the landing switches (158 = `R11U157_OFF R11U158_OFF R11V158_OFF`, 160 = `R11U160_OFF`, 163 = `R11U163_OFF R11V163_OFF`) |
| `/tmp/r11u170_throw/slang-uhdm-throw` | `3e6e4668789e71b39cffb67c8b610608` | scratch: HEAD objects + a `uhdm_main.cpp` that throws on purpose (`R11U170_THROW=<type>`), linked outside the build tree |

Two intermediate fix builds were superseded, and neither was swept:

- `ace8447f…`: its scoped-name test read the NamedValue's own syntax, which slang leaves unset for `pk::V`. The
  refinement did not fire (measured on sc/f08).
- The build before it had no census traces.

## 2. Gate sweeps (`tests/sweep.sh --jobs 3`, [drivers/sweep.sh](drivers/sweep.sh), logs in [evidence/sweeps](evidence/sweeps))

Every `cmds.txt` names its sweep's binary or wrapper: 3273 of 3273 `slang:` lines in each of the nine sweeps. The only red
in every sweep is `law index STALE`, which the clean main tree at d8cfd83a reads too (environment).

| sweep | binary | probe reg/conv/chg | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|---|
| L | law.bin (HEAD) | 0/0/0 (EQUAL 2597 / SN 1490) | 0/0/0 (437 + 434 CMP_EQUAL) | 0/0/0 (769 + 769) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0; csv = results/downstream_uhdm2rtlil.csv |
| A | alloff.sh | 82/0/80 | 23/0/13 | 36/0/8 | the same verdicts (803/66/2) |
| P | pre.bin | 82/0/80 | 23/0/13 | 36/0/8 | - |
| 8 | off158.sh | 14/0/24 | 7/0/11 | 6/0/0 | - |
| 0 | off160.sh | 17/0/25 | 6/0/2 | 22/0/8 | - |
| 3 | off163.sh | 50/0/32 | 10/0/0 | 6/0/0 | - |
| N | offTPDEFNAME.sh | 0/0/1 | 0/0/0 | 0/0/0 | - |
| U | offTPUSEDEF.sh | 7/0/8 | 0/0/0 | 4/0/2 | - |
| F | fix.bin | **0/0/0** | **0/0/0** | **0/0/0** | **803/66/2, not excused 0; csv byte-identical to L's** |

"Regressions" in A, P, 8, 0, 3, N and U are the landings' own conversions returning, since a switch turns a law off.

**Canaries:**

- L and F: `r11u107repro/canaries.sh` surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0.
- `EXPECT_UNKNOWN=1 ctcan2.sh` surelog ok=58 changed=0 PASS.
- `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil ok=2 changed=0 PASS.

**Byte verifier**:

- Tool: `tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, on hard-link mirrors that leave the 8 fenced row-mode
  databases out ([drivers/bvmirror.sh](drivers/bvmirror.sh)). Path sets are identical: 2560, with 2559/2560 flagged
  by the self-check.
- F vs L: 5 movers, MiniAmiq d/t, Scoreboard d, SeqDriver d, SimpleUVM t. Each is the UVM order coin
  ([evidence/sweeps/coin_fix_vs_head.txt](evidence/sweeps/coin_fix_vs_head.txt), path-normalised uhdm-dump):
  order-blind 4 lines, and 0 lines on Scoreboard.
- Probe databases F vs L: 0 of 4087.
- These are the predicted movers. The census ran BEFORE the F sweep: [drivers/census.sh](drivers/census.sh) with
  [drivers/tracewrap.sh](drivers/tracewrap.sh), fence-filtered, and 3265 corpus runs plus 4087 probe cases passed
  through the wrapper.
- The census read 0 firings of the three refinements ("fenced mentions: 0"). Its positive control (gl/g01, tv/v06,
  sc/f08, sc/f16 through the same wrapper) logged GCALHSUNIT 8, TPVECNET 1, SCSCOPED 3 + 2
  ([evidence/sweeps/census_fix.txt](evidence/sweeps/census_fix.txt)). The predicted mover set was therefore the coin
  family only, and the measured set is exactly that.

## 3. The fresh cases and the per-law scores

**The cases:**

- [cases/](cases) holds 178 cases: 176 graded in the grid, `mm/m05` (Surelog rejects it, no golden) and `ux/s01`. Each first line names its law or laws.
- Every law of the three landings has at least two fresh cases that fire it. The one exception is
  § aggParamFoldUnqualWholeSpan158, which is shadowed (section 5).
- The shapes were written to avoid the grids of r11u157hp, r11u158repro, r11v158repro, r11u160repro, v11u160repro,
  r11u163repro and r11v163repro.

**How they were run:**

- [drivers/grid.py](drivers/grid.py) runs HEAD in these states:
  - ON;
  - each named law's own switches; a refinement `…v` is also scored against its parent's switch, which is that
    site's pristine;
  - OFFL<n>, the landing off;
  - every pair of named laws, for `cx/`;
  - ALLOFF;
  - PRE, the pre.bin binary.
- Each state runs in the default probe mode and with `-elabuhdm` / `--elabuhdm` (the testflags form). Goldens come
  from the pinned Surelog with check_probe's arguments, cached per case text.

**How they were scored:**

- ON is scored against each OFF state on the strict records (TOWARD / AWAY / MIXED / UNMASK / BYTES-ONLY / UNFIRED).
  When either state is stage 1, the path-normalised order-blind dump distance to golden decides (STAGE1-CLOSER /
  SAME / AWAY).
- Every AWAY, MIXED, STAGE1-AWAY and newbad line was then read field by field. [drivers/cells.py](drivers/cells.py)
  counts a BROKEN cell when a field is golden-equal in OFF and not in ON, before either walk's divergence.
- [drivers/ddiff.py](drivers/ddiff.py), [drivers/carhs.py](drivers/carhs.py) and [drivers/pas.py](drivers/pas.py)
  show the objects.
- Downstream: [drivers/dscase.py](drivers/dscase.py) runs the harness's `one()` in the states ON, OWN and FIX.

**ALLOFF equals PRE byte for byte on 176 of 176 cases in both modes.**

Per law, fresh cases and the ON-vs-own-switch score in default mode. The `--elabuhdm` scores are the same unless noted
([evidence/grid/law_summary.txt](evidence/grid/law_summary.txt), with the case lists):

| law | cases (firing / total) | ON vs own switch | verdict |
|---|---|---|---|
| § hpSelRoute157 | 4 / 12 (hs h06 h07 h09, cx/x04) | 3 STAGE1-CLOSER, 1 TOWARD, 8 UNFIRED | no break; new unreached contexts: residue R1 |
| § thisPathFormByPosition157 | 3 / 3 (th t01-t03) | 3 TOWARD (t02, t03 -> STRICT_EQUAL) | no break |
| § foreachArrPathVarForm157 | 2 / 3 (fe e01 e02) | TOWARD, STAGE1-CLOSER | no break |
| § rootPathOwnNames157 | 2 / 4 (rt r03 r04) | 2 TOWARD | no break; r01 unreached (R2) |
| § genTgtLhsLeafOwnName157 | 2 / 3 (gt q01 q03) | 2 TOWARD -> STRICT_EQUAL | no break |
| § withRecvOnlyLastScoped157 | 2 / 2 (wr w01 w02) | TOWARD (-> STRICT_EQUAL), STAGE1-CLOSER | no break |
| § enumAliasEndAtDimOrInitDecl158 | 2 / 7 (ev a05 a07) | 2 TOWARD | no break |
| § genCaLhsEnumConstClone158 | 13 / 13 | 4 TOWARD, 1 STAGE1-CLOSER, **4 AWAY, 4 STAGE1-AWAY** | **BREAK B1** (fixed) |
| § sizeCastCaLitMask158 | 6 / 16 | 5 STAGE1-CLOSER, 1 STAGE1-SAME | no break (wrong-to-wrong cells: R5, R6) |
| § sizeCastCaSignedSize158 | 6 / 6 (sc f08 f09 f15-f18) | 6 STAGE1-CLOSER; **downstream sc/f08, f16 EQUIVALENT -> DIVERGENT** | **BREAK B3** (fixed) |
| § pkgFoldLeftParenSpan158 | 3 / 3 (pp f01-f03) | 2 TOWARD -> STRICT_EQUAL, 1 STAGE1-CLOSER | no break |
| § arrQueryFoldAtBound158 | 3 / 5 | 2 STAGE1-CLOSER, 1 STAGE1-SAME | no break (aq/q02: R7) |
| § aggParamFoldUnqualWholeSpan158 | 1 / 4 (ua/u01, definition view) | STAGE1-SAME, span toward golden's ref_obj span | no break; shadowed by pass 163 (section 5) |
| § methodRandomizeCallSpan158 | 3 / 3 (rz z01-z03) | 3 TOWARD -> STRICT_EQUAL | no break |
| § sizeCastNarrowTargetAbstain158v | 2 / 2 (sc f12 f20) | STAGE1 -> STRICT_EQUAL on both | no break |
| § sizeCastSignedLitAbstain158v | 2 / 2 (sc f11 f19) | = parent-off (pristine) bytes | no break (golden's INT branch stays v158's residue 3) |
| § sizeCastNamedWidthNoCast158v | 2 / 2 (sc f05 f10) | STAGE1-CLOSER | no break (R5) |
| § arrQueryParamArgOnly158v | 2 / 2 (aq q04 q05) | 2 STAGE1-CLOSER | no break |
| § ppMacroBodyLines160 | 9 / 17 | 6 TOWARD, 3 MIXED (0 BROKEN cells) | no break; **defect D1** (mm/m07, m13) |
| § objMacroParenArgsTrimmed160 | 2 / 5 (ma o04 o05) | 2 TOWARD -> STRICT_EQUAL | no break; empty body unreached (R3) |
| § tpCloneWholeLhsBare160 | 2 / 12 (gw z07 z10) | TOWARD, STAGE1-CLOSER | no break |
| § defNetTypeParamPackedVec160 | 9 / 10 | 5 TOWARD, 1 STAGE1-CLOSER, **3 STAGE1-AWAY** | **BREAK B2** (fixed) |
| § bodyTypeParamDefaultBound160 | 3 / 3 (bt b01-b03) | STAGE1-CLOSER, MIXED (0 BROKEN), UNMASK | no break |
| § tpUseBindsDefDefault160 | 5 / 7 | 2 TOWARD (3 in `--elabuhdm`), 3 BYTES-ONLY | no break |
| § implNetBareParamElab160 | 2 / 4 (cp/c01, cx/x03) | TOWARD -> STRICT_EQUAL, STAGE1-CLOSER | no break |
| § uncaughtExitsReject160 | ux/s01, `-o /dev/full`, unwritable `-o`, scratch throws | rc 3 (off: 134) | holds for std types (section 9) |
| § pasteChainRunning160v | 2 / 4 (pa p01 p04) | 2 TOWARD -> STRICT_EQUAL | no break |
| § tpWholeLhsInstantiatedOnly160v | 2 / 4 (gw z08 z11) | 2 TOWARD | no break |
| § elabAggFoldYCopyDefNamed163 | 3 / 7 (sy y04 y06 y07) | TOWARD -> STRICT_EQUAL, BYTES-ONLY, STAGE1-SAME | no break |
| § aggParamFoldQualSpanByView163 | 2 / 5 (qs a04 a05) | 2 TOWARD -> STRICT_EQUAL | no break |
| § elabOvArrFoldSharesDefParamTs163 | 3 / 6 (oa o04 o05, cx/x03) | TOWARD -> STRICT_EQUAL (o04 `--elabuhdm` stage 1 -> STRICT_EQUAL), STAGE1-SAME | no break |
| § ovPkgPatOpInstanceCopy163 | 4 / 4 (po c01-c04) | 2 TOWARD, 2 STAGE1-CLOSER | no break |
| § pkgPatListingCopyWhenShared163 | 2 / 3 (pl d01 d03) | 2 TOWARD | no break |
| § importPatOpCloneParamNamed163 | 2 / 2 (ic i01 i02) | 2 TOWARD | no break |
| § paramOpCloneRelocatedSpan163 | 2 / 3 (rc f01 f03) | 2 TOWARD (f03 -> STRICT_EQUAL) | no break |
| § elabTpNamedElemDimDefNamed163 | 2 / 4 (nd n06 n07) | TOWARD -> STRICT_EQUAL, STAGE1-SAME (golden lacks the renamed refs) | no break |
| § elabTpDefaultDefNamed163 | 6 / 7 | 5 BYTES-ONLY, 1 STAGE1-SAME | no break; verdict-redundant (section 5) |
| § fnParamRangeNetNoFile163 | 2 / 3 (fn f01 f03) | 2 STAGE1-SAME | no break |
| § ovPatOpCopyAtLocalRef163v | 2 / 2 (po c03 c04) | 2 TOWARD | no break |

**Downstream** ([evidence/downstream/summary.txt](evidence/downstream/summary.txt), 178 cases).

OWN -> ON, the laws' own effect:

- 111 IDENTICAL both, 24 EQUIVALENT both, 21 DIVERGENT both.
- 18 improve: 6 DIVERGENT -> IDENTICAL, 11 EQUIVALENT -> IDENTICAL, 1 DIVERGENT -> EQUIVALENT.
- **2 worsen, sc/f08 and sc/f16 (B3).**

ON -> FIX: 0 worsen; 3 improve (sc/f08, sc/f16, sc/f18 DIVERGENT -> IDENTICAL).

## 4. The breaks, their decodes and the refinements (fix.patch; `R11V170_OFF=1` drops all three)

### B1: § genCaLhsEnumConstClone158 on an enum the compilation unit can see (§ genCaLhsUnitEnumShared170v, `R11V170_GCALHSUNIT_OFF`, ExprEmit.cpp)

**Measurement.** `typedef enum int {E_LO = 1, E_HI = 3} e_t;` at file level, `assign o[i][j][E_HI:E_LO] = ...` in a
gen-for.

- Golden binds the located shared `E_HI` 2:30-2:38.
- The law mints the loc-less clone. gl/g01 goes STRICT_EQUAL (pristine) -> STRICT_NOTEQUAL `file`, 8 records.
- The same holds for g04 (one gen-for), g06 (a packed target), g11 (two instances of a child), both modes.

**Distinguisher.** The same shapes with a module enum (g05) or a module-body package import (g07, g08) are the law's
own clone in golden (TOWARD). With a file-level `import pk::*;` (g09) golden binds the located constant too, and that
case is stage 1 on both binaries for an unrelated gen_scope typedef head (STAGE1-AWAY). g10 and cx/x07 are also
STAGE1-AWAY.

**Decode.** UhdmWriter::lateBinding
([UhdmWriter.cpp:3899](../../../third_party/Surelog/src/DesignCompile/UhdmWriter.cpp#L3899)) scans the file's own
typedef map, `fC->getTypeDefMap()`, and binds the located `enum_const` BEFORE it reaches the fresh-constant mint
`mod->getValue(name)`
([UhdmWriter.cpp:3955](../../../third_party/Surelog/src/DesignCompile/UhdmWriter.cpp#L3955)) that the law models. A
compilation-unit typedef (declared or imported at file level) is in that map; a module or package typedef reached
through a module-level import is not.

**Refinement.** The law abstains when the enum value's declaring scope is the CompilationUnit, or its package is
imported at compilation-unit scope (a wildcard import, or an explicit import of the name).

**Result.**

- g01, g04, g06, g11 -> **STRICT_EQUAL** in both modes.
- g09, g10, cx/x07 -> STAGE1-CLOSER, bytes = pristine.
- g02, g03, g05, g07, g08 keep the law's bytes.

### B2: § defNetTypeParamPackedVec160 on a net declaration (§ defNetTpVecNetKeepsEnd170v, `R11V170_TPVECNET_OFF`, ModuleEmit.cpp)

**Measurement.** `parameter type T = logic [3:0]`, `wire T [N-1:0] w;`.

- Golden binds `work@sub.w` to the default `logic_typespec` 2:33-2:44 and does NOT move its end.
- The law binds it and moves the end to the dimension (2:33-3:17). Every golden line that lists the default,
  pristine-matched, now differs.
- tv/v03, v04, v06: STAGE1-AWAY in both modes (dump distance 38 -> 45/51, 73 -> 88).
- The variable form `T [N-1:0] w;` (tv/v05, v07) is the law's shape and converts.

**Decode.** writeNets' end-only populate
([UhdmWriter.cpp:879](../../../third_party/Surelog/src/DesignCompile/UhdmWriter.cpp#L879),
`if (!dimensions) dimensions = orig_net->getPackedDimension();`) reads the Signal's packed dimension, which a
net_declaration's data_type does not hand to the Signal.

**Refinement.** For a `SymbolKind::Net` of the vector half, the binding stays but the packed-dimension end move is
skipped. The struct/union half of pass 144 is untouched.

**Result.** v03, v04, v06 STAGE1-CLOSER (45 -> 35, 51 -> 35, 88 -> 70; below pristine's 38, 38, 73); they stay
stage 1 on an unrelated face (golden's elaborated `logic_net` against our `packed_array_var`).

### B3: § sizeCastCaSignedSize158 on a scoped or `$unit` name (§ sizeCastScopedNameUnsigned170v, `R11V170_SCSCOPED_OFF`, ExprEmit.cpp)

**Measurement.** Golden per operand shape (continuous assignment into logic [3:0] p / logic [7:0] r):

| operand | golden | law | pristine |
|---|---|---|---|
| `2'(pk::V)`, V = 7 (package-scoped) | UINT:3 size 4 | INT:-1 size 4 | INT:-1 size 2 |
| `3'(pk::N)`, N = -1 | UINT:7 size 8 | INT:-1 size 8 | INT:-1 size 3 |
| `$unit` `localparam int V = 7`, `2'(V)` | UINT:3 size 4 | INT:-1 size 4 | INT:-1 size 2 |
| `import pk::*; 2'(V)` (bare, imported) | INT:-1 size 4 | = golden | size 2 |
| module header `parameter int V`, `2'(V)` | INT:-1 size 4 | = golden | size 2 |
| module `localparam int L = pk::V; 2'(L)` | INT:-1 size 4 | = golden | size 2 |

The plugin reads the law's INT:-1 as `4'1111`. Pristine's size-2 INT is zero-extended through a `$pos` cell to
`4'0011`, which golden's netlist proves equal. So downstream sc/f08 and sc/f16 go **EQUIVALENT -> DIVERGENT**, and
sc/f18 stays DIVERGENT with its scoped half moving away.

**Decode.** A package-scoped operand is compiled by CompileExpression's `paPackage_scope` branch
([CompileExpression.cpp:2717](../../../third_party/Surelog/src/DesignCompile/CompileExpression.cpp#L2717)), not as the
module's parameter reference. The cast then reduces an unsigned value, the § sizeCastCaLitMask158 shape; a `$unit`
name binds the design-level parameter the same way.

**Refinement.** In § sizeCastCaLitMask158's operand test, a top-level operand written as a ScopedName (read from the
cast's own syntax, through parentheses) or declared at compilation-unit scope counts as a literal leaf. The mask branch
folds it (UINT, masked to the cast width, at the assignment width), so the signed branch is not reached.

**Result.**

- f08, f16, f18 match golden in every field of the Rhs.
- Downstream **DIVERGENT -> IDENTICAL** on all three.
- f18 becomes STRICT_EQUAL. f08 and f16 become STRICT_NOTEQUAL `endcol`, a face the stage-1 head hid.
- f15 and f17 (bare names) keep the law's INT.

### Fix measurements

- **Fresh cases** ([evidence/grid/fixgrid_default.txt](evidence/grid/fixgrid_default.txt),
  `fixgrid_elabuhdm.txt`): FIX against HEAD moves exactly those 13 cases per mode:
  - 4 TOWARD -> STRICT_EQUAL;
  - 9 STAGE1-CLOSER; in `--elabuhdm`, gl/g09 is STAGE1-SAME.
  - Each is moved by its own switch alone. `R11V170_OFF=1` gives HEAD's bytes on 176/176 cases in both modes.
- **Earlier passes' cases:** the 553 cases of the seven earlier directories give HEAD bytes = FIX bytes in both modes
  (547 + 6 with no database on either binary,
  [evidence/grid/earlier_cases_head_vs_fix.txt](evidence/grid/earlier_cases_head_vs_fix.txt)).
- **The gate (sweep F):** zero on every stage, as in section 2.

## 5. Composition ([drivers/compose.py](drivers/compose.py), [evidence/composition](evidence/composition))

**Switch completeness.** A (the three landings off) against P (the pre-158 build):

- The csvs have the same statuses.
- Probe databases: 0 / 4087 movers.
- Corpora: 7 / 2560 movers, all the UVM coin: MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t (4 order-blind lines each)
  and Scoreboard d (0).
- The downstream verdicts of A equal L's (803 / 66 / 2).

**Ownership.** Per row, judge-and-strict-equal in L and not in A, the landings whose single-off sweep loses it:

| stage | conversions L vs A | owned by 158 | by 160 | by 163 | shared (either alone) | joint |
|---|---|---|---|---|---|---|
| probe | 82 | 14 | 17 | 50 | 1 (`r11u20repro/t3`) | 0 |
| surelog | 23 | 7 | 6 | 10 | 0 | 0 |
| uhdm2rtlil | 36 | 6 | 22 | 6 | 2 (gen_scope_numports d/t) | 0 |

- Every surelog and uhdm2rtlil conversion is the one its landing claimed, by name
  ([evidence/composition/compose_census.txt](evidence/composition/compose_census.txt)).
- Pass 160 claimed 18 probe + 24 uhdm2rtlil conversions; at HEAD 17 + 22 are its own, and the shared 1 + 2 are
  converted by pass 163 as well. That matches the pass-163 verifier's composition reading (50 probe conversions on
  pass 160's landing).

**Cancellation:**

- Status level: 0 rows whose (status, strict) is equal in L and A but differs with one landing off.
- Byte level: 0 databases equal in L and A but different in a single-off sweep (2560 corpus, 4087 probe).

So no conversion hides two laws cancelling.

**The cross-ground pairs:**

- **§ elabTpDefaultDefNamed163 with § tpUseBindsDefDefault160.** The verdict-redundant one is
  **§ elabTpDefaultDefNamed163**.
  - Gate sweep N (TPDEFNAME alone off): probe 0 regressions, 1 change (`r11u20repro/t6` fullname 2 -> 3), corpora
    0 / 0.
  - Gate sweep U (TPUSEDEF alone off): 7 probe + 4 uhdm2rtlil regressions (packed_array_reset_loop d/t,
    packed_array_struct d/t), 8 + 2 changes.
  - On the fresh pairs (cx x01 x02 x08 x09) TPDEFNAME off is BYTES-ONLY or stage-1-same wherever TPUSEDEF is on. In
    `--elabuhdm`, cx/x01 with TPUSEDEF off and TPDEFNAME on reads STRICT_NOTEQUAL `depth`, so TPDEFNAME alone does
    not cover it. With both off, x01 and x02 read `fullname` / `endline`.
  - The two laws agree wherever both fire. Keeping both costs nothing. Retiring TPDEFNAME costs one fullname record on
    `r11u20repro/t6`.
- **§ implNetBareParamElab160 with § elabOvArrFoldSharesDefParamTs163 (cx/x03).** Additive: each law's switch moves
  only its own objects, the pair is STAGE1-CLOSER (dump 88 -> 76), and ALLOFF = PRE.
- **§ ppMacroBodyLines160 with § hpSelRoute157, member paths in a multi-line macro body (cx/x04).**
  - The route law fires inside the body and reads TOWARD: 4 `col` records leave, and none enters.
  - The macro-line law is UNFIRED there, because the body's lines are right without it.
  - The pair equals the route law alone.
  - The r11u157 R7 face (golden's element spans in body coordinates) did not appear on these select and part-select
    positions.
- **§ genCaLhsEnumConstClone158 with § tpCloneWholeLhsBare160 (cx/x05).**
  - STAGE1-AWAY from the enum law.
  - Golden leaves the left-side enum references UNBOUND in a module whose type parameter an instance overrides. Ours
    binds, located (pristine) or a clone (law): wrong on both, not a golden-equal cell. Residue R8.
  - TPWHOLELHS is UNFIRED there. The two laws do not interact.
- **§ sizeCastCaLitMask158 with § defNetTypeParamPackedVec160 (cx/x06).**
  - The pair is STAGE1-CLOSER.
  - `$bits(T)'(7)` into logic [7:0]: golden UINT:7 (the width is not applied), law UINT:3, pristine UINT:255. Wrong on
    all three, R5.
  - `T'(7)` is a type cast, untouched.

**Shadowed law.** § aggParamFoldUnqualWholeSpan158 changes no byte at HEAD while pass 163 is on:

- Its 20 pass-158 probe movers (`r11u108repro/grid/pk` k10*/k23*, `r11u111repro/grid/f2` b03-b14,
  `v11u111repro/brk/f2/x22`) are byte-equal between L and sweep 8.
- So are StructUnsizedVal d/t, LargeValue2Struct d/t and its own grids uq/u1 u3 u5 and a05 a06.
- `R11U163_AGGQUALSPAN_OFF` revives it. § aggParamFoldQualSpanByView163's elaborated span covers the same fold.

The two agree; this is not a cancellation.

## 6. The CHANGE lines re-derived (unmask.py, the landing off vs HEAD, [evidence/composition/changes_off*_vs_head.txt](evidence/composition))

Records are `uhdm-strictcmp --max 100000` against the same golden. [drivers/unmask.py](drivers/unmask.py) is copied
from r11u162verify.

| landing | probe changes | surelog | uhdm2rtlil | classification |
|---|---|---|---|---|
| 158 | 24 | 11 | 0 | all SUBSET (every record HEAD holds, the landing-off walk held) |
| 160 | 25 | 2 | 8 | 7 SUBSET, 8 UNMASK, 6 NEW, 4 BOTH-DIVERGED (probe); 2 SUBSET (surelog); 6 SUBSET, 2 UNMASK (uhdm2rtlil) |
| 163 | 32 | 0 | 0 | all SUBSET |

**Pass 160's nine grown counts are all UNMASK.** The landing-off walk diverged, and HEAD's walk is aligned:

- `r11u112repro/grid/k` k03_dims, k12_twodims, k14_unpacked, k16_comb_driven, k17_ff_driven (endline(5), diverged ->
  fullname 15 / 15 / 10 / 24 / 18);
- `r11u47repro/branches/g8` (3 -> 10);
- `r11v47repro/branches/v30` (8 -> 18);
- arb_idx_cast d/t (endline(3), diverged -> endcol(17)).

The same class holds `v11u112repro/grid/brk/k/b3a_multi_decl`.

**The other ten, read cell by cell** ([drivers/pcells.sh](drivers/pcells.sh)): **0 BROKEN cells.**

- The six NEW rows are `r11u8repro/b8`, `gA`, `r11v11u8repro/v2`, `v8`, `v10`, `v12`.
  - Fixed cells: 12, 12, 18, 6, 14, 6.
  - A record's text changed because its `line` was fixed while its `endcol` stays wrong; the same objects are listed.
- The four BOTH-DIVERGED rows are `r11u110repro/grid/f2/i11_attr_wdims_child`, `v11u110repro/brk/v1/d01`, `d02` and
  `r11v32repro/w1_regression_witness`. The divergence moved later (20 -> 26, 12 -> 39): unmasking, with 2 to 4 fixed
  cells.

The pass counts differ from the landing-time counts (158: 44 + 15; 160: 25 + 2 + 8; 163: 32) because at HEAD the later
landings have already rewritten some of those rows. For example, pass 163 converted StructUnsizedVal and
LargeValue2Struct, which were pass-158 changes.

## 7. Downstream

**Byte checks.** Every uhdm2rtlil row the three landings converted is byte-identical between the Surelog lane and the
slang lane in the HEAD sweep: `<t>_nohier.il`, `<t>.il` and `<t>_synth.v`, 18 of 18 tests.

- pass 158: MultirangesStartNotFromZero, expr_width_cast, portsel_struct_param.
- pass 160: the seven ibex tests, gen_scope_typaram, gen_scope_numports, packed_array_reset_loop, packed_array_struct,
  packed_struct_array_fifo.
- pass 163: param_array_wildcard, type_param_override_elem_sel, struct_param_pattern_packing.

The md5s are in [evidence/sweeps/downstream_bytes_converted_rows.txt](evidence/sweeps/downstream_bytes_converted_rows.txt).
The csv rows read IDENTICAL, for example:

- `ibex_decoder,IDENTICAL,OK,OK,327,327,,`
- `param_array_wildcard,IDENTICAL,OK,OK,19,19,,`
- `expr_width_cast,IDENTICAL,NO_GATES,NO_GATES,0,0,,`

**The harness on the fresh cases.** Size-cast, macro-body and type-parameter cases, section 3.

**The escaped name holding `#`** (`ux/s01`, a module enum constant `\E#1`; the pass-160 case was a `$unit` one):

| binary | exit code | database | downstream verdict |
|---|---|---|---|
| HEAD | 3 | none | SLANG_REJECT |
| `R11U160_CATCH_OFF` | 134 (abort) | none | SLANG_REJECT |
| pre.bin | 134 | none | - |

HEAD also exits 3 with `-DSYNTHESIS`. The harness cannot tell the two exits apart because it does not record the exit
code; the codes above are measured directly.

## 8. Residues

### Re-measured at the base: every top-three residue still stands

[evidence/residues_at_base.txt](evidence/residues_at_base.txt), csv rows from sweep L.

**Pass 158:**

1. r11u157 R2/R3 mixed paths and component indexes: fresh hs/h01 `fullname`, h03 `col`, h04 `fullname`.
2. R-SP: StructParamFieldRange and cva6_struct_param_field `fullname(7)`. StructUnsizedVal and LargeValue2Struct were
   converted by pass 163.
3. N0003 + N1132: ParamNoImport was converted by pass 163; iface_zero_width_field `fullname(4)` stands.

Sister faces:

- S1 HighLow `value(1)`.
- S2 sc/c10: stage 1.
- S3 sc/c12 was fixed by r11v158.

Its verifier:

1. The implementer's list stands (above).
2. sc/b09: stage 1.
3. sc/b03: stage 1.
4. sc/b08: stage 1.

**Pass 160:**

1. Earlgrey_0_1 `line(1730)` d/t.
2. ClassTypeParam `endline(17)` / `file(30)`.
3. The rest of the ibex family: ibex_icache `fullname(49)`, ibex_load_store_unit `endline(142)`, ibex_tracer
   `fullname(579)`, ibex_register_file_ff `fullname(31)`, ibex_pmp `file(52)`.

Its verifier:

- MM/p03 `line(10)`.
- MM/q08 `endcol(1)`.
- MM/q20 `endcol(8)`.
- BT/b03 `fullname(10)`.

**Pass 163:**

1. LocalScopeHierPath t `fullname(1)`.
2. iface_zero_width_field, and pi/p08 `fullname(4)`.
3. rl/q03 `line(7)`.

hc/g02 `line(1)` stands too. Its verifier:

1. lr/r01 `line(1)`.
2. The implementer's list stands (above).
3. sy/b08 `fullname(7)`, ip/e04 `fullname(4)`, tp/g08 `fullname(8)`, tp/g02 `fullname(8)`.

### New, found here (none is a break, each is ranked by reach)

**D1 (defect, wrong-to-wrong, § ppMacroBodyLines160).** A nested MULTI-LINE call on a body line after an inactive
`` `ifdef `` branch.

- mm/m07 and m13: the cont_assign's line is 8 in golden, 7 pristine, 5 with the law. The INACTIVE subtraction lands on
  a line golden resyncs to the nested call's closing parenthesis.
- Without the inactive branch (mm/m11, m12), golden is again the closing parenthesis' definition line (5, 6). The law
  and pristine both write the opening line (4, 5).
- The POP resync of the nested call is not modelled. The r11u166mac decode describes this family ("nested calls write
  their own PUSH/POP"); its patch was not applied here.

**R1, § hpSelRoute157 contexts left unrouted** (UNFIRED, golden differs):

- a package function's lvalue index holding a part-select path (hs/h03 `col`: golden CFC own token);
- a class method's indexed-part-select base inside a member path (hs/h04, = r11u157 R3);
- a gen-for bit-select of a struct member (hs/h01, R2).

**R2, § rootPathOwnNames157, a `$root` path to a NET in a continuous assignment** (rt/r01). Golden anchors `$root` at
`top` 3:44-47 and names the hier_path; ours keeps its own token. The law fires on parameter-member paths only
(rt/r03, r04).

**R3, § objMacroParenArgsTrimmed160 with an EMPTY-body object macro** (`` `define D ``, ma/o01-o03). Golden trims the
same blanks (`endcol`/`col` faces); the law abstains. A non-empty body converts (ma/o04, o05).

**R4, the elaborated view of a genCaLhs-shaped `$unit` import** (gl/g09). Stage 1 on both binaries, on a gen_scope
`vpiTypedef` head.

**R5, size-cast widths golden does not apply.** A parenthesised bare local name `(W)'(7)` (sc/f05) and `$bits(T)'(7)`
(cx/x06):

| | value |
|---|---|
| golden | UINT:7 |
| § sizeCastCaLitMask158 | UINT:3 |
| pristine | UINT:255 |

`(pk::W)'(-1)` masks in golden (UINT:3, = the law). This extends § sizeCastNamedWidthNoCast158v; the downstream verdict
is DIVERGENT on all binaries.

**R6, a size cast into a select or an unpacked element** (sc/f02: `p[5:2] = 2'(7)`, `arr[1] = 3'(-1)`). Golden keeps
the cast operation; ours folds it (stage 1). The law's value is the right one: downstream goes DIVERGENT ->
EQUIVALENT.

**R7, § arrQueryFoldAtBound158 on other parameter shapes** (aq/q02):

- A typedef-typed parameter: golden locates `$low(Q)` at the TYPEDEF's bound, 4:20-21; the law abstains.
- `$right(pk::P)`: golden keeps the sys_func_call unfolded, even in the elaborated view.
- `$high(P, 2)` (aq/q01): golden's constant has no value.

**R8, a gen-scope left-side enum constant in a module whose type parameter is overridden** (cx/x05). Golden leaves the
references unbound.

**R9, `wire T [N-1:0] w` after the fix** (tv/v03, v04, v06). The elaborated net is a golden `logic_net` against our
`packed_array_var` (stage 1).

## 9. The fence and the process

**Fence scans:**

- A word-boundary grep of the seven directories (r11u157hp, r11u158repro, r11v158repro, r11u160repro, v11u160repro,
  r11u163repro, r11v163repro) for the four names reads 0 files.
- Positive control: each name is found twice in RESUME.md.
- No verdict of a fenced row-mode differs between L, A and P: 8 surelog row-modes, 0 in uhdm2rtlil.

So no conversion, change or law of the three landings rests on a fenced row.

**Laws re-derived by this pass from its own cases and Surelog's source.** These are the laws of each pass nearest to
the fenced tests' shapes as their names suggest, which were never opened:

| pass | law | fresh cases | Surelog source |
|---|---|---|---|
| 158 | § hpSelRoute157 | hs/h06-h09, cx/x04 (parameter-struct members in generate, interface, package and class scopes) | CompileExpression.cpp compileSelectExpression / compileComplexFuncCall, the r11u157 decode |
| 158 | § sizeCastCaSignedSize158 | sc/f08, f15-f18 | CompileExpression.cpp:2717; a refinement found (B3) |
| 160 | § implNetBareParamElab160 | cp/c01, cx/x03 | - |
| 160 | § tpUseBindsDefDefault160 | tu/u01-u03, cx/x01, x02, x08, x09 | - |
| 163 | § elabAggFoldYCopyDefNamed163 and § aggParamFoldQualSpanByView163 | sy/y04-y07, qs/a04 a05 | - |
| 163 | § fnParamRangeNetNoFile163 | fn/f01-f03 | - |

**Drivers that do NOT refuse to run without `$FENCED` and skip the names:**

- v11u160repro/drivers/orderblind.sh reads the golden-cache, pristine and law databases of a corpus row it is handed,
  with no fence test. Its README used it on the UVM rows only.
- v11u160repro/drivers/unmask.py reads any database it is handed, with no fence test. Its corpus caller
  classify_corpus.sh is fenced; classify_probe.sh reads only probe databases.
- r11v158repro/drivers/paramassign.py, recdiff.py and run3.sh read databases or cases they are handed, with no fence
  test (used on grid cases).

Partial:

- r11v163repro/drivers/census.sh tests only that `$FENCED` is non-empty, not that it holds four names. It also
  dispatches with `--jobs 4`, over the three-job rule.
- r11v163repro/drivers/ds.py and grid.sh refuse by substring, which is stricter.

The trace wrappers (all four tracewrap.sh) have no guard of their own; they run only under censuses that filter the
fenced rows. The gate-sweep drivers dispatch every row themselves, which the rule allows. Every other driver of the six
directories either reads no corpus data or refuses and skips.

**Process checks:**

- **Pass 160's prediction was written after the development sweeps**, as its README states.
  - At HEAD its byte movers total its stated 15 + 48 = 63 corpus row-modes and 89 probe cases (sweep 0 vs L, byte
    level).
  - Its source-shape census (r11u160repro/drivers/predict.py, fence-guarded) was re-run here from the sources alone,
    with no database read ([evidence/composition/pass160_predict_rerun.txt](evidence/composition/pass160_predict_rerun.txt)).
    It names 254 tests, which cover the 32 moving tests except ApbSlave, Scoreboard, SeqDriver and SimpleUVM: the
    four its README disclosed, whose macros live outside the test directory.
- **Pass 163's "347 names before the sweep"** cannot be timed from committed evidence; its scratch is pruned. Its
  predicted_movers.tsv covers every mover measured here with pass 163 alone off (71 corpus row-modes, 99 probe cases)
  except the four UVM coin tests. That is consistent with a prediction.
- **§ uncaughtExitsReject160** ([evidence/uncaught/throw_types.txt](evidence/uncaught/throw_types.txt)):
  - The scratch binary threw each type on purpose from `realMain`. std::runtime_error, std::logic_error,
    std::bad_alloc and std::out_of_range exit 3 with the message and no database (134 with `R11U160_CATCH_OFF`).
  - kj's exception derives from std::exception, and exits 3 on two natural paths: `-o /dev/full` ("No space left on
    device") and an output in a read-only directory. pre.bin aborts 134 there.
  - A thrown `int`, `const char*`, `std::string` or custom struct still aborts 134. `catch (const std::exception&)`
    does not see them.
  - Nothing linked throws them: slang's sources throw only std types (its AssertionException is a std::logic_error),
    UHDM has no throw, and kj's derive from std::exception.
  - Not a break. A `catch (...)` would close the gap, and it is not in fix.patch.

## 10. Files

- [fix.patch](fix.patch): the three refinements (src/EmitHelpers.h `r11v170On`, src/ExprEmit.cpp, src/ModuleEmit.cpp),
  `R11V170_TRACE=1` traces, not applied.
- `cases/<grid>/<case>/dut.sv` (178; `mm/m04` also holds `defs.svh`). Grids: hs th fe rt gt wr (the r11u157 laws),
  ev gl sc pp aq ua rz (pass 158 and r11v158), mm ma pa gw tv bt tu cp ux (pass 160 and v11u160), sy qs oa po pl ic rc
  nd fn (pass 163 and r11v163), cx (composition pairs).
- `drivers/`:
  - environment: env.sh, laws.py (law -> switch map);
  - runners: case.sh, grid.py, gridall.sh, fixgrid.py, rescase.sh, oldbytes.sh;
  - readers: cells.py, ddiff.py, carhs.py, pas.py, pcells.sh;
  - downstream: dscase.py, dsbytes.sh;
  - composition: compose.py, unmask.py (from r11u162verify), bvmirror.sh (from r11u160repro), coin.sh;
  - sweeps and census: sweep.sh, sweeps_all.sh, sweeps_tp.sh, sweep_fix.sh, census.sh + tracewrap.sh;
  - summarize.py.
- `evidence/`:
  - `grid/`: the grids in both modes, the fix grids, law_summary.txt, earlier_cases_head_vs_fix.txt;
  - `sweeps/`: the nine sweep logs, byteverify, coin, census, downstream bytes;
  - `composition/`: ownership, changes, byte-cancel, all-off vs pre;
  - `downstream/`, `uncaught/`, residues_at_base.txt.
