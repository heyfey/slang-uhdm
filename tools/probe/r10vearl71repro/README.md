# r10earl71 — adversarial verification (VERDICT: ACCEPT AS SHIPPED)

Independent re-measurement of `§ genScopeConnPsDirectBoundKeepsRef71` +
`§ pkgParamValueIsUnsigned71` at base `ecdded75`, from two fresh worktrees and
two self-built frozen binaries. Nothing here changes production code: the
verified patch's `src/ExprEmit.cpp` diff is byte-identical to the implementer's.
`VGATES.txt` carries every gate number; `VGRID_SCORE.txt` every arm score;
`VBOUNDARY_*` the two exhaustive walks.

## Reproduced bit-for-bit

Both binaries rebuilt from source reproduce the implementer's md5s exactly
(`9ae62f2d…` pristine, `adf4be78…` patched). Earlgrey_0_1 goes **46 -> 17**
comparison lines, one head to one head, in BOTH modes; every other named row's
head is unchanged. The two Earlgrey `.cmp` heads match the committed
`HEAD_BEFORE_*` / `HEAD_AFTER_*` modulo object ids. The corpus census
reproduces 531489 -> 32 TO-GOLDEN and 811229 -> 64 TO-GOLDEN with 0 away and 0
wrong, on a 521401 / 799038-cell golden-vs-golden calibration. Byte movers are
0/1358 (uhdm2rtlil) and 3/956 (surelog: the two Earlgrey targets plus the
Scoreboard coin, sorted-diff 0 over 1099609 lines). The seven grid arms score
112 / 96 / 240 / 104 / 112 / 88 / 80 TO-GOLDEN with AWAY-GOLDEN 0 and
MOVED-WRONG 0 in the plain view, exactly as reported.

## Five new adversarial arms

`v1_shapes71` (every select shape), `v2_origins71` (symbol origin x home,
including an instance array of three, gen-if, nested gen and a `pkg::P`
qualifier), `v3_enc71` (25 value-encoding shapes `d3_earl71` did not measure),
`v4_homes71` (interface, program, a gen-scope module that instantiates in its
own gen scope, and cont_assign / bit-select / procedural controls),
`v5_edges71` (nested part-select bound, call-arg bound, modport connection,
OUTPUT-direction High_conn, macro-written and written qualifiers, an x-valued
package parameter, gen-if `else`, gen-case).

Plain view TO-GOLDEN / AWAY-GOLDEN: 104/0, 112/0, 96/0, 72/0, 128/0. The
official `uhdm-cmp` improves on all five arms in BOTH views
(13454->13324, 27669->27529, 17173->17013, 11041->10951, 12017->11847 plain).
A span-PRESENCE payload (coordinates collapsed to LOC/NOLOC, scored separately
because golden's minted `enum_const` is LOC-LESS) scores identically to the
judge-fields payload in every arm: the minted `enum_const` is loc-less on both
sides and the `ref_obj` keeps golden's span.

**Every changed cell in every arm is a port `High_conn` part-select BOUND.**
The censuses cover `cont_assign` (97 cells in `v4` alone) and `param_assign`
sites and NONE of them moves; neither does any bit-select index, any `+:`/`-:`
base or width, any DEF-listing (`ref_module`) copy, or any qualified `pkg::P`
read (golden folds those too — confirmed for the written AND the macro-written
spelling, so `§ argWrittenQualIsSyntaxKind33`'s syntax-kind discriminator is
right here).

## What broke, and why it does not block

`v3_enc71` finds **four value-encoding shapes `§ pkgParamValueIsUnsigned71`
claims but Surelog does not store the way our encoder writes them.** All four
are MOVED-WRONG (a cell that was already wrong becomes differently wrong),
never AWAY-GOLDEN, and the official judge still IMPROVES on each of them in
isolation, so refusing them would be a regression relative to the shipped
patch:

| package-parameter init | golden's minted `enum_const` | ours |
|---|---|---|
| `parameter int B17 = 20 + 8'd4` | `INT:24` | `UINT:24` |
| `parameter int B23 = signed'(20)` | `INT:20` | `UINT:20` |
| `parameter int B2 = $bits(logic [23:0])` | `UINT:1` | `UINT:24` |
| `parameter int B7 = 8'b1010_0001` | `INT:-95` dec `-95` | `BIN:10100001` dec `32'b10100001` |

`m17.sv` and `m7.sv` isolate the first and the last: the official judge goes
1460 -> 1455 and 1452 -> 1447 lines. The cause of the first two is that
`pkgParamExprIsUnsigned71` returns `true` for EVERY `IntegerLiteral` (a
based-DECIMAL literal is stored `INT:` by Surelog, so an `Add` over one is
`INT:` too) and recurses straight through a `Conversion` (so a `signed'` cast
is invisible to it). The fourth is law 70's inherited encoder: `g3_enc70`
measured a based-BINARY init only on a `[7:0]`-declared parameter, where
`BIN:` is right; on an `int`-declared one golden sign-extends the literal
width and stores `INT:-95`. None of the four occurs in either corpus.

`v3_enc71` also confirms nine REFUSALS are correct and one more is a pure
residue: `$unsigned(20)` (golden `UINT:20`) keeps the pristine fold because
the classifier does not model `$unsigned`.

`v5_edges71`'s 8 MOVED-WRONG cells are a key-shape artifact, not a value
error: golden folds the `idf71(...)` call away entirely so its bound sits at
`HC/r` while ours sits at `HC/arg[0]/r`, and the multiset join pads. On the
payload our patched cell is byte-equal to golden's
(`ref_obj name=EP actual=enum_const aval=UINT:16 adec=16 asz=32`).

The `--elabuhdm` MOVED-WRONG count equal to TO-GOLDEN is confirmed to be the
census artifact the pass names: the padded golden side prints `<none>`.

## Exhaustive boundary

A COPY of `tools/probe` with no path filter, `.sv` and `.v`, both views, both
frozen binaries, workdir-normalised whole-dump byte compare; file list on fd 3,
children `</dev/null`, `PROCESSED == LISTED` asserted, `rc` recorded per cell.

| walk | processed | identical | differing | no output |
|---|---:|---:|---:|---:|
| every `.sv`/`.v` file | 3258 | 6220 | 22 | 274 |
| every unique directory | 1472 | 2690 | 13 | 241 |

The 22 file differences are **exactly** the seven implementer grid arms and my
four new arms, in both views, and nothing else — the walk's own positive
control that it can see. Every `r10earl61…69repro`, `r10rgg14…18repro`,
`r10v6*repro` and `r10uvm*repro` source is byte-identical between the two
binaries in both views, so `§ elabCaPortParamPaCopy64`, `§ connIpsBareBaseUint64`,
`§ connIpsPkgParamBoundNoTs65`, `§ connMpRootIpsBoundKeepsTs65v`,
`§ elabConnEnumConstFold66`, `§ connCallArgKeepsEnumRef66v`,
`§ genLpBitSelIdxOneHopFold67`, `§ genvarWholeCaRhsFold68`,
`§ caLhsAdjustSize68`, `§ hpNameBareIdxFold69`, `§ connOperandOwnScopeBind61`,
`§ patFlatUnsizedMemberWidth61` and the rgg14/16/17 fold laws all hold
untouched.

The 13 directory differences are the three arm-holding directories plus mine,
plus `r10uvm75repro`, `r10uvm76repro` and `r10uvm88repro`. All three of those
last are the documented `design::Task_funcs` ORDER coin: sorted diff 0 over
9154–23569 lines, and the PRISTINE binary alone produces two different dumps
of `r10uvm88repro` across four invocations
(`8fe5cf7c1943`, `8fe5cf7c1943`, `b307d71870ef`, `b307d71870ef`) — which is
also why the implementer's walk counted 10 differing directories where mine
counts 11 real + 2 mine.

All 20 (file walk) and 10 (directory walk) `rc=139` signals are symmetric
between the two binaries; `ASYMMETRIC_RC_CELLS=0` in both walks. No new crash,
no new timeout.

## Reproduction

`vrunarm71.sh <arm.sv> <dir>` builds one arm with Surelog
(`~/git-repos/Surelog/build/bin/surelog`, the harness's own pin) plus both
frozen binaries in both views and writes a judge-fields census (`*.ex`) and a
span-presence census (`*.sp`); score with `r10earl71repro/score71.py <g> <o>
<q> 4`. `vwide71v.sh file|dir <list> <out> <stage>` is the boundary driver.
