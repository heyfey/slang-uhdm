# r11v181 — adversarial verification of r11u181: every headline number reproduced bit for bit; three breaks where pristine was right refined (§ lvIdxReadNestedKeepsLvalue181v, § lvIdxReadCallNameSpan181v, § procLvPartSelBoundCallName181v), the wide decimal's separators dropped (§ bigDecUnderscoreDropped181v); gates unchanged from the implementer's patch, 10 more case-modes converted

Verifier pass of `r11u181` (pair A, expression/parameter ground). Base `80a1c2af` (branch matrix-1.87). Worktrees
`/tmp/wt_v11u181` (patched) and `/tmp/wt_v11u181pris` (pristine), system-deps config, `-j 2`. Deliverable
`/tmp/r11u181.verified.patch` = the implementer's patch + the four refinements below (all in `src/ExprEmit.cpp`) + two
driver path fixes in `tools/probe/r11u181repro/drivers` + this directory + the regenerated `tests/LAWS.md`. No edit to
`TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`, `uhdm_main.cpp`, `results/`, `third_party/`.

## Verdict

**ACCEPT WITH FIX.** Every number of the implementer's report reproduces bit for bit. The break hunt (51 fresh cases,
both views, judged by uhdm-cmp, uhdm-strictcmp record by record, and the downstream verdict) found three faces where
the pristine binary was right and the law binary wrong, all on legal SV: a member path nested two levels in an lvalue's
index, a call inside the index of a path nested in an lvalue index, and a call as a part-select bound of a procedural
lvalue. Each is refined behind its own switch. With the refinements, no case-mode of the implementer's grid or of this
grid has a record entering against pristine or against the law binary, and every gate reads as the implementer's.

## Binaries (frozen `chmod 555` in `/tmp/v11u181_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `3f7b4f737b6020424bc0f734eb0ff64a` | worktree build of `80a1c2af`; = the brief's pristine md5 |
| `law.bin` | `3afc1bf084f83489627936066da0b347` | `/tmp/r11u181.patch` built here; = the implementer's `law181f.bin` |
| `ver1.bin` | `d090a514399d14917c86d38465b3c574` | first cut of the refinements (superseded: the nested path's names) |
| `ver2.bin` | `32dcfed30b517409cdfcedbf47182d4e` | the verified patch |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

Every sweep's `cmds.txt` names its own frozen binary on all 3273 `slang:` lines (`/tmp/v11u181_swP` pris.bin,
`/tmp/v11u181_swL` law.bin, `/tmp/v11u181_swV` ver2.bin, `/tmp/v11u181_swF` ver2.bin from the final tree with the
regenerated law index; same-length workdir names). The final sweep `swF` exits 0 (no law-index staleness) and its four
csvs equal `swV`'s but the LowMem log-path text.

## 1. Reproduction of the implementer's numbers

| stage | pristine `swP` | law `swL` (implementer's claim) | verified `swV` |
|---|---|---|---|
| probe | EQUAL 2814 / STRICT_NOTEQUAL 1273, reg 0; `probe.csv` byte-identical to the baseline | EQUAL 2820, reg 0 / conv 6 / changes 20 (as claimed, same 26 rows) | = `swL` (`probe.csv` identical) |
| surelog | CMP_EQUAL 450 + 447, reg 0 / 0 / 0 | 452 + 449, reg 0 / conv 4 / changes 11 (as claimed, same 15 rows) | = `swL` (csv identical but the LowMem log-path text) |
| uhdm2rtlil | 783 + 783, 0 / 0 / 0 | same | same |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | `downstream.csv` byte-identical to `swP`'s | byte-identical |

Conversions (fresh rows of `swL` and `swV`, results/ untouched):

    CovMacro,default,CMP_EQUAL,,,equal       was differ:fullname(8)   § rootPathFullNameByChain181
    CovMacro,testflags,CMP_EQUAL,,,equal     was differ:fullname(8)   § rootPathFullNameByChain181
    YosysRiscv,default,CMP_EQUAL,,,equal     was differ:col(40)       § bitSelParenIdxSpan181
    YosysRiscv,testflags,CMP_EQUAL,,,equal   was differ:col(40)       § bitSelParenIdxSpan181

Probe conversions: `r10buvm6repro/v5_hierpathparent`, `r10uvm59repro/d10_argstmt`, `r10v167repro/probe0`,
`r11u82repro/grid/v3_rootpath`, `v11u116repro/branches/f2_incd_d2ff`, `v11u116repro/branches/f2_incd_d3cb`. The 20 probe
CHANGES and the 11 corpus CHANGES are the implementer's list exactly, each a count decrease on the same first field
(`r10v167repro/vA_meth` file(10) -> endcol(9)).

- **Corpus byte movers** (`byteverify.sh` with SELFCHECK=1 on fence-free hard-link mirrors, 2560 paths, 8 fenced
  databases never mirrored; `evidence/byteverify.txt`): law vs pristine 17 / 2560, exactly the implementer's 17
  (BuildUVMPkg, CovMacro, Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, SVSwitch, YosysRiscv both modes, Scoreboard
  default). Earlgrey_0_1 default moves 32 order-blind dump lines, all § lvSelIdxChainName181 renaming the index
  reference of `hw2reg.key[7 - i].d` from `...key[7 - i].d.i` to `...key[7 - i].d.key.i`, which is golden's name in both
  the module and the elaborated listings (read from the cached golden); testflags 0 order-blind lines. Status and strict
  detail unchanged.
- **Downstream slang lane:** 805 databases compared law vs pristine and verified vs law, 0 movers.
- **Canaries** on `swL`: `canaries.sh` surelog ok=43 changed=9 (the nine claimed CHANGE rows), uhdm2rtlil ok=16;
  `ctcan2.sh` PASS on both corpora (EXPECT_UNKNOWN=1 / 6).
- **The implementer's grid** (89 cases x both views, rebuilt here with the pinned Surelog): 98 STRICT_NOTEQUAL ->
  STRICT_EQUAL and 8 stage-1 -> STRICT_EQUAL, as claimed; `ver2.bin` writes the law binary's bytes on all 178
  case-modes (156 moved by the law, 22 unmoved by either).

## 2. The breaks and their refinements (`src/ExprEmit.cpp`)

The grid is `cases/` (51 cases, both views, goldens from the pinned Surelog with and without `-elabuhdm`). Record
level (`drivers/recmv.py`: every differing record of `uhdm-strictcmp --max 100000`, keyed on its walk index and the
golden record): pristine -> law LEAVE / ENTER / CHANGED.

**B1. A member path nested two levels in an lvalue index** (`cases/lx/x01`, `x02`). `m.w[n.w[o.w[k].v].v].v += 2`
and `arr[n.w[o.w[k].v].v] = 3`: § lvIdxMixedPathIsRead181 builds the level-1 path `n.w[...].v` as a read (right), but
its flag, still set, also built the level-2 path `o.w[k].v` as a read. Golden builds the level-2 path in the
nested-path shape: `o` on the member token 9:15-16, the bit_select `w[k]` 9:15-19 named through both paths
(`work@top.arr.n.w[].v.o.w[k].v.w`), its index named through the chain, the leaf unnamed. Pristine gave the columns and
the unnamed leaf; the law gave `o` 9:13-14, `o.w[k]` 9:15-16 and a named leaf. x01: ENTER 4 CHANGED 4; x02: ENTER 10
CHANGED 6. The rvalue twin `y = n.w[o.w[k].v].v` (`x04`) builds the level-2 path the same way in golden, and it is
untouched by every law.

- **§ lvIdxReadNestedKeepsLvalue181v** (`R11V181_NESTRD_OFF`): a mixed path entered while that flag is set is
  emitted under `inLhs` with the flag cleared (the pristine form), and its selects are handed to
  § lvSelIdxChainName181's drain, so the select and its index read their chain names (the prefix pristine passed had
  lost the read path's own name). x01 and x02 go to STRICT_EQUAL both views (pristine: col / fullname).

**B2. A call in the index of that read path** (`cases/lx/x03`). `m.w[n.w[f(k)].v].v = 4`: golden spans `f` alone
(13:13-14), as for any call indexing a read path (pass 178's R2 first half). Pristine spanned the name because the
whole left side was emitted under `inLhs`; the law cleared `inLhs`, so the call took the rvalue whole-call span
(13:13-17). ENTER 2 per view.

- **§ lvIdxReadCallNameSpan181v** (`R11V181_RDCALL_OFF`): while the builder is inside a path the law built as a read
  (a depth counter, `lvIdxReadDepth181`), a call keeps the name span and § procLvIdxCallWholeSpan181 abstains. x03 keeps
  its other faces (a plain member read `s.v` and a select `arr[k]` inside the read path's index: names off on every
  binary, residue V3).

**B3. A call as a part-select bound of a procedural lvalue** (`cases/lc/c02`, `c03`). `a[f(3):f(0)] = 4'h1` and
`{a[f(5):f(4)], b[f(6)-:2]} = 4'h5`: golden spans the name (8:7-8, 8:12-13), pristine alike;
§ procLvIdxCallWholeSpan181 spanned the whole call (8:7-11). The same cases show the law right on the other
positions: an indexed part-select base, a bit_select index at either dimension, an associative key and a
concatenation element's index all span the whole call in golden. ENTER 4 per view.

- **§ procLvPartSelBoundCallName181v** (`R11V181_LVCALLPS_OFF`): the law abstains when the call's parent is a
  `part_select`. c02 and c03 go to STRICT_EQUAL both views.

**Extension. § bigDecUnderscoreDropped181v** (`R11V181_DECBIG_OFF`). Surelog's `compileConst` erases every `_` before
it sets the decompile of ANY bare decimal, including one wider than 64 bits (the `largeInt` branch):
`1_000_000_000_000_000_000_000` reads `vpiDecompile 1000000000000000000000` in golden, where ours kept the written
text (the value was already `DEC:<digits>`). `cases/us/d06` goes from stage 1 to STRICT_EQUAL both views.

Every refinement also reads `R11V181_OFF` (all four) and the pass switch `R11U181_OFF`. `R11U181_TRACE=1` prints
`R11U181 law V181 <TAG>` on every branch (NESTRD, RDCALL, RDCALL lhs, LVCALLPS, DECBIG).

## 3. Switch matrix (`evidence/switch_matrix.txt`)

On the 12 case-modes the refinements move, each `R11V181_<X>_OFF` alone restores the law binary's bytes on exactly the
cases its trace fires on and leaves the others at the verified bytes; `R11V181_OFF=1` gives the law binary's bytes on
all of them; `R11U181_OFF=1` gives the pristine bytes (`us/d06`: law = pristine there).

## 4. Movers of the refinements, predicted by name first

`drivers/predict181v.cpp` read every database of the LAW sweep `swL` (the refinements' pristine: 6647 listed, 8 fenced
row-mode databases excluded by word boundary, fail closed) and flagged the shapes each refinement can touch (NESTRD: a
path nested in a path that is itself nested in a left side or an inc/dec operand without being it; RDCALL: a call below
such a path; LVCALLPS: a call whose parent is a part_select below a left side; DECBIG: a vpiDecConst constant whose
decompile holds `_`). **Predicted: 0 of 6647.** Positive control: the same binary flags `lx/x01 x02 x03`, `lc/c02 c03`,
`us/d06` and not the single-level controls (`evidence/predict.txt`).

Verified sweep vs law sweep (`evidence/byteverify.txt`): probe 0 / 4087 databases moved; downstream 0 / 805; corpus 6 /
2560, all the UVM coin: MiniAmiq d/t, SeqDriver d/t, SimpleUVM d move 4 order-blind dump lines each (`UINT:` /
`vpiDecompile` of one constant, `evidence/uvm_coin.txt`), Scoreboard d 0 order-blind lines (list order only). No row's
status or strict detail differs between `swL` and `swV`.

## 5. The rest of the break hunt: laws that held

| group | cases | what was attacked | result |
|---|---|---|---|
| `rt` | r01-r11 | `$root` reads in a function body / loop / return, case items, assertions, `$display`, `repeat`, generate scopes, a module-local class, an interface instance, an instance parameter, `$bits`, two top modules, a macro-born path; lvalues in concatenations, inc/dec, force | every judgeable case STRICT_EQUAL (6 conversions x 2 views); the `$root` lvalue forms in a concatenation or an inc/dec are stage 1 on both binaries (golden writes a bit_select named `top`, no hier_path) |
| `px` | p01-p06 | constant / cast / nested / spaced parenthesized indices, a parameter and a param init, a memory word, generate loops, case subject and items, a return, macros in and around the parentheses, a class method's queue and dynamic array, a nonblocking right side, an index inside an index | 3 conversions x 2 views; 0 records enter; downstream p01/p03/p04/p06 EQUIVALENT -> IDENTICAL |
| `lv` `id` | l01-l15, i01-i04 | inc/dec on assoc / queue / packed / 2-D / nested selects, inside an index, a condition, a call argument, genvar-indexed generate processes and functions, through a class handle; class methods (extern, static, a local struct, derived, `this`, package); streaming lvalues; `new` into queue, assoc, member arrays, copy `new` | 6 conversions x 2 views; 0 records enter (stage-1 cases: class and struct shapes pristine already fails) |
| `lc` | c01 | call indices in an interface always, a program initial, a final block, a generate always and a generate function | STRICT_NOTEQUAL on both (endcol: other faces), 7 records leave, 0 enter |
| `us` | d01-d05 | delays, replication, repeat, part-select widths, for bounds, trailing / doubled separators, a macro-born literal, a negation, a 20-digit value, parameter defaults and overrides, enum values, patterns, case ranges, `inside` | d01 d02 d05 stage 1 -> STRICT_EQUAL; downstream d05 DIVERGENT -> IDENTICAL, d03 EQUIVALENT -> IDENTICAL |
| `iv` `dw` | i01-i03, w01-w03 | the unbound second item labelled, split over lines, macro-born, an unbound assignment; do-while conditions through function-like, nested and partial macros, a whole do-while in a macro, a two-line macro, locals in parameterized-class bodies | i03 w01 lose records, w02 converts, 0 enter |

Downstream verdicts on 11 synthesizable cases (`drivers/ds.sh`, pristine -> verified): 5 EQUIVALENT -> IDENTICAL, 1
DIVERGENT -> IDENTICAL, 4 IDENTICAL stay, `rt/r05` DIVERGENT on both.

## 6. Residues (ranked)

- V1. **Separators in constants built outside the literal branch** (downstream-visible values): an enum constant
  `A = 1_0` reads `UINT:1` / `1_0` (golden `UINT:10` / `10`), built by the enum typespec builder (TypeEmit, the
  `MakeEnum_const` loop; sister ground); a generate loop condition `g < 1_0` reads `UINT:1` (ModuleEmit, the
  generate-loop condition; sister ground). § bareDecUnderscoreDropped181 is the rule to transcribe at both.
- V2. **A member path's parenthesized select index** (`y = s.f[(i)]`, `px/p05`): golden spans `(i)` (15:13-16), ours
  the content (15:14-15). ExprEmit `emitMixedHierPath`'s member select branches: § bitSelParenIdxSpan181 reaches only the
  plain bit_select.
- V3. **Reads inside a read path nested in an lvalue index** (`lx/x03`): a plain member read `s.v` and a select
  `arr[k]` there are named off on every binary (golden `...m.w[].v.w.v`, the select spanning the whole `arr[k]` with
  the chain name); and a class method's level-1 index reference (`lv/l15` elab: golden
  `work@C::f::m.w[].v::w::n.w[k].v::k`, pristine `work@C::f::k`, law `work@C::f::m.w[].v::w::k`).
- V4. The implementer's residues R1-R7 and sister faces S1-S5 stand as reported (not re-worked here).

## 7. Files

- `cases/` (every case names its laws in its first line): `lx/x01 x02` § lvIdxReadNestedKeepsLvalue181v, `lx/x03`
  § lvIdxReadCallNameSpan181v, `lx/x04` § lvIdxReadNestedKeepsLvalue181v (control), `lc/c02 c03`
  § procLvPartSelBoundCallName181v, `lc/c01` § procLvIdxCallWholeSpan181, `us/d06` § bigDecUnderscoreDropped181v,
  `us/d01-d05` § bareDecUnderscoreDropped181, `rt/r01-r11` § rootPathFullNameByChain181 (with § rootPathElemOwnName181,
  § rootNetPathOwnNames181), `px/p01-p06` § bitSelParenIdxSpan181, `id/i01-i04` § incDecBitSelWholeSpan181 /
  § incDecMixedPathIsLvalue181, `lv/*` the lvalue laws named in each first line, `iv/i01-i03`
  § invalidStmtAnchorSyntax181, `dw/w01-w02` § doWhileMacroCondEnd181, `dw/w03` § doWhileSyntaxFromCond181.
- `drivers/`: `env.sh` (pins, `$FENCED` from `canaudit.sh`, fail closed), `grid.sh` (golden + ours + uhdm-cmp +
  strictcmp + dump, one view), `both.sh` (pristine and law, both views, traces), `three.sh` (a third binary against both),
  `recmv.py` (record movement), `sw.sh` (switch matrix), `ds.sh` (downstream verdict of one case), `bvmirror.sh`
  (fence-free byteverify mirrors), `predict181v.cpp` / `predict181v.sh` (mover predictor).
- `evidence/`: `grid_pristine_vs_law.txt`, `grid_verified.txt`, `switch_matrix.txt`, `predict.txt`, `byteverify.txt`,
  `uvm_coin.txt`, `sweep_swP.log`, `sweep_swL.log`, `sweep_swV.log`, `sweep_swF.log` (the final gate, rc 0), `canaries.txt`, `downstream_cases.txt`.
