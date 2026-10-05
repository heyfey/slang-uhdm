# v11u242 — adversarial verification of r11u242

Base `6cd6f5ac` (matrix-1.87). Implementer's delivery: `/tmp/r11u242.patch` (md5 `7225b3a6bee6093155575c982d174add`),
six laws in `src/ParamEmit.cpp` behind `src/R242.h` (each `R11U242_<LAW>_OFF`, `R11U242_OFF` drops all six). The
four slang-fenced tests are never named here: every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh`, fail-closed; nothing fenced was dispatched outside the gate sweeps, decoded,
read or opened (byteverify ran on hard-link mirrors filtered by `$FENCED`, the away census skips fenced rows before
opening anything, the determinism and OFF reruns used fixed name filters that hold no fenced name).

## Verdict: ACCEPT, no fix

Every headline number of the implementer reproduces bit for bit, and 51 fresh cases in both views (102 case-views,
918 grid runs, every exit code 0) found no break: no case-view leaves STRICT_EQUAL or uhdm-cmp equality, no
stage-1 case-view's uhdm-cmp text changes except to shrink, the chain-keyed away census reads 0 lost records on every
case-view that moved, and every downstream verdict is the same on both binaries. `/tmp/r11u242.verified.patch` is the
implementer's patch plus this directory and the regenerated `tests/LAWS.md`; the production files are byte-identical
to the implementer's.

**FuncStructVal CONVERTS in both modes** (fresh rows of the law sweep):

```
FuncStructVal,default,CMP_EQUAL,,,equal          (pristine STRICT_NOTEQUAL differ:depth(1), #7975)
FuncStructVal,testflags,CMP_EQUAL,,,equal        (pristine STRICT_NOTEQUAL differ:depth(1), #14765)
Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(160),,differ:fullname(160)   (pristine differ:col(2))
Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(55),,differ:fullname(55)   (pristine differ:col(2))
```

Earlgrey's grown count is a later divergence: the pristine first records #122230 (constant 43:53 vs 43:28 in
flash_phy_pkg.sv) and #130430 (`range` vs `ref_typespec`) are gone; the new first record #136315 (`$clog2(NumRound)`
argument's ref_typespec, golden `work@sha2`, ours unnamed) then #142988 (a bit_select span in hmac.sv 133); the
chain-keyed away census reads away 0 / toward 41 per mode ([evidence/heads.txt](evidence/heads.txt),
[evidence/away_corpus.txt](evidence/away_corpus.txt)).

## Binaries (built by this verifier, frozen at `/tmp/v11u242_bin` before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine | `e8e74e7af71d0b248694123631d26dbe` | fresh worktree at `6cd6f5ac`, system-deps config, `-j 2`; reports slang 12.0.0+545f88b2e |
| law | `caf12314455901eaaa60b95ecb8ad333` | fresh worktree at `6cd6f5ac` + the patch, `-j 1`; equal to the implementer's |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | equal to the implementer's |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `r11u242repro/drivers/cc_x.sh`; equal to the implementer's |

cmds.txt audit: the pristine sweep names `/tmp/v11u242_bin/pristine` in 3273 of 3323 cmds.txt, the law sweep
`/tmp/v11u242_bin/law` in 3273 of 3323; the other 50 in each are Surelog-only rows (no slang run).

## Gates reproduced

| gate | pristine | law |
|---|---|---|
| probe | 3480 + 607, 0/0/0 | 3480 + 607, regressions 0, conversions 0, changes 0; probe csv identical to pristine's |
| surelog | 469 + 11 / 465 + 9, 0/0/0 | 470 + 10 / 466 + 8: regressions 0, conversions 2 (FuncStructVal d/t), changes 2 (Earlgrey_0_1 d/t); every other row identical (LowMem detail text = workdir path) |
| uhdm2rtlil | 803 + 0 per mode | 0/0/0, csv identical |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 | the same; the two csvs identical |

Both sweeps print `law index STALE`: the pristine tree's because the base's `tests/LAWS.md` predates its own commit,
the law tree's because this directory's cases were already in it. The implementer's patch applied alone on a fresh
`6cd6f5ac` reads `law index current` (checked, then reverted). uhdm-cmp on the 36 corpus movers: 0 lines on all.
Canaries: `canaries.sh` surelog ok=48 changed=4 (exactly the four rows above), uhdm2rtlil ok=16 changed=0;
`EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS ok=58; `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS ok=2.

**Movers.** byteverify (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`, on `$FENCED`-filtered hard-link
mirrors `/tmp/v11u242_mL` / `_mP`): `PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS 36 / 2560**, the same 36 paths and
the same hashes as the implementer's, and exactly the corpus part of the implementer's frozen prediction
(`r11u242repro/evidence/census/predict.txt`, written 02:27:56, before its law sweep's first database at 02:28:28).
`SELFCHECK 2559 / 2560 flagged`: the self-check replaces one side with one fixed file, and that file compared with
itself is the one path it cannot flag; it is the check working, not a mover. Probe: a pristine probe sweep run from
the LAW worktree (probe sources embed the worktree path, so the cross-worktree pristine sweep moves every probe byte)
gives 4 of 4087 movers, the four predicted (r10uvm48repro/t67b, r11u10repro/grid/h9_1e1m_port and hD_1e1mvec,
r11u114repro/grid/f3/c05), verdicts unchanged. Downstream lanes: 15 of 805 slang-lane databases move, the 15
predicted, all IDENTICAL in both sweeps, slang-lane `_nohier.il` byte-identical on all 15.
`R11U242_OFF=1` with the law binary writes pristine's bytes on all 36 corpus movers (both corpora, both modes).

**Away census** (`r11u242repro/drivers/awayrows.py`, chain-keyed, strictcmp_x records): 0 away (chain and flat) on
all 36 corpus movers and all 4 probe movers; toward 296 / 280 on FuncStructVal d/t, 41 / 41 on Earlgrey_0_1 d/t,
0 elsewhere. Positive control: with the sweeps swapped the same rows read away 296 / 280 / 41 / 41
([evidence/away_corpus_reversed_control.txt](evidence/away_corpus_reversed_control.txt)).

**Determinism** (`r11u242repro/drivers/det.sh`, three concurrent runs, law binary): one hash per row-mode on
Earlgrey_0_1 and the five UVM rows (11 of 11; Scoreboard testflags writes none), each equal to the law sweep's and to
the implementer's.

**Implementer's grid** rerun (`r11u242repro/drivers/grid.sh`, 378 runs): every verdict, cmp line count and exit
code equal to its `evidence/grid.txt`, and the md5 partition per case-view identical (the absolute md5s differ only by
the worktree path embedded in the databases) ([evidence/grid_impl_rerun.txt](evidence/grid_impl_rerun.txt)).

## The attack (cases/, 51 cases, both views; [evidence/grid.txt](evidence/grid.txt), [evidence/grid_summary.md](evidence/grid_summary.md))

Each case ran on pristine, law, law + `R11U242_OFF` and law + each of the six switches, in the default and
`-elabuhdm` views: 918 runs, **every exit code 0**; `R11U242_OFF` = pristine bytes on 102 of 102 case-views; 100
case-views move bytes; **28 enter STRICT_EQUAL, none leaves**; no uhdm-cmp line count rises; on the stage-1 case-views
the uhdm-cmp text (ids stripped) is identical between pristine and law except Z/z03 (32 -> 28 lines: the
`unsigned'(32'd5)` member's mismatch is cleared and the head moves to the `unsigned'(K)` member, which no law takes)
and Z/z08_sc_k3 / k4 (stage 1 -> STRICT_EQUAL). Case-level away census ([drivers/caseaway.py](drivers/caseaway.py),
[evidence/caseaway.txt](evidence/caseaway.txt)): **0 away** on every moved case-view, toward 2433 on the judge-equal
ones and 952 on the stage-1 ones; reversed control reads them as away. Downstream (`drivers/dscase.py`, the harness's
`one()`): 45 IDENTICAL and 6 EQUIVALENT on both binaries, the same verdict on every case, the slang-lane `.il` files of
the six EQUIVALENT cases byte-identical between the binaries.

| case | law | shape | pristine -> law (default / `-elabuhdm`) |
|---|---|---|---|
| X/x01_macro | § impCondFlipTakenLeaf242 | the leaf and the whole ternary through macros | col -> EQUAL / col -> EQUAL |
| X/x02_real_str | § impCondFlipTakenLeaf242 | real, string and enum ternaries beside an int one | stage 1 (118 / 88), text unchanged |
| X/x03_leaves | § impCondFlipTakenLeaf242 | paren, unary minus, user call, system call, sized, concat leaves | stage 1 (64, the user-call leaf in the package listing), unchanged |
| X/x04_slots | § impCondFlipTakenLeaf242 | replication count, dimension, part-select, indexed width, generate-if, parameter default; interface importer | col -> fullname both: the six col records cleared, the remaining record #544 (a generate-scope ref_typespec full name) is pristine's own |
| X/x05_explicit | § impCondFlipTakenLeaf242 | by-name import, qualified read, empty `#()`, untyped and logic ternaries | stage 1 (17, by-name import face), unchanged |
| X/x06_chain | § impCondFlipTakenLeaf242 | condition and leaf from another package, generate-for depth 2, function body | stage 1 (36, a parenthesized-leaf constant in the package), unchanged |
| X/x07_inc | § impCondFlipTakenLeaf242 | the package in an include file, a macro-born leaf there, a `+` leaf | col -> EQUAL / col -> EQUAL |
| X/x08_crlf | § impCondFlipTakenLeaf242 | CRLF, the ternary over three lines | line -> EQUAL / line -> EQUAL |
| X/x09_real | § impCondFlipTakenLeaf242 | real ternary alone | stage 1 (118 / 88), unchanged |
| X/x10_string | § impCondFlipTakenLeaf242 | string ternary alone | stage 1 (64), unchanged |
| X/x11_enum | § impCondFlipTakenLeaf242 | enum-constant leaves | stage 1 (64), unchanged |
| X/x12_leaves2 | § impCondFlipTakenLeaf242 | x03 without the user call | stage 1 (136 / 106), unchanged |
| X/x13_pkgqual | § impCondFlipTakenLeaf242 | qualified read without import, empty `#()` | stage 1 (17), bytes unchanged (the law does not fire) |
| X/x14_explicit | § impCondFlipTakenLeaf242 | by-name import with a parameter port list | col -> EQUAL / col -> EQUAL |
| X/x15_chain | § impCondFlipTakenLeaf242 | x06 without the parenthesized branch | stage 1 (42 / 46), unchanged |
| X/x20_paren | § impCondFlipTakenLeaf242 | leaf `(LB)` | col -> EQUAL / col -> EQUAL |
| X/x21_uminus | § impCondFlipTakenLeaf242 | leaf `-LB + 5` | stage 1 (64, the package's INT encoding), unchanged |
| X/x22_clog | § impCondFlipTakenLeaf242 | leaf `$clog2(LB)` | col -> EQUAL / col -> EQUAL |
| X/x23_sized | § impCondFlipTakenLeaf242 | leaf `4'd5` | stage 1 (60), unchanged |
| X/x24_nested | § impCondFlipTakenLeaf242 | nested ternary in the false branch | col -> EQUAL / col -> EQUAL |
| X/x25_mul | § impCondFlipTakenLeaf242 | leaf `LB * 2` | stage 1 (64), unchanged |
| X/x26_minus | § impCondFlipTakenLeaf242 | leaf `LB - 1` | stage 1 (64), unchanged |
| X/x27_truelit | § impCondFlipTakenLeaf242 | condition true, literal leaf | col -> EQUAL / col -> EQUAL |
| X/x30_contexts | § impCondFlipTakenLeaf242 | implicit net, interface body, class specialization `c#(W)`, `this.`, named and positional calls with an omitted default, extern and pure virtual prototypes | stage 1 (17), unchanged; downstream IDENTICAL |
| Y/y01_kinds | § impArrParamTsOwnRanges242 | int, `[0:3]`, `[3:0]` arrays, interface and module importers | stage 1 (48 / 52), unchanged |
| Y/y02_dims_pkgparam | § impArrParamTsOwnRanges242 | bounds through a package parameter, replication count, part-select bound, generate-for over `$size` | stage 1 (1483 / 1567), unchanged |
| Y/y03_struct_enum | § impArrParamTsOwnRanges242 | enum and struct arrays, by-name import, qualified read | stage 1 (32), unchanged |
| Y/y04_typedef_arr | § impArrParamTsOwnRanges242 | unpacked dimension inside a typedef, 2-D, string and real arrays | stage 1 (58), unchanged |
| Y/y05_depth | § impArrParamTsOwnRanges242 | importer at depth 3 under for- and if-generates, function and always_comb loop reads | EQUAL -> EQUAL both, bytes move |
| Y/y06_macro_pkg2 | § impArrParamTsOwnRanges242 | macro declaration, bound from another package | stage 1 (36), unchanged |
| Y/y07_vec | § impArrParamTsOwnRanges242 | vector arrays, importer with `#(P)` | fullname / type, unchanged verdicts, 0 away |
| Y/y08_struct | § impArrParamTsOwnRanges242 | struct array, qualified int array | fullname both, unchanged verdicts, 0 away |
| Y/y09_str_real | § impArrParamTsOwnRanges242 | string and real arrays beside an int one | stage 1 (20), unchanged |
| Y/y10_macro | § impArrParamTsOwnRanges242 | macro declaration, read in a parameter default | stage 1 (62), unchanged |
| Y/y11_contexts | § impArrParamTsOwnRanges242 | implicit net, interface body, class specialization `c#(A[0])`, named call, generate-for | stage 1 (64), unchanged; downstream IDENTICAL |
| Z/z01_kinds | § patLeftoverOpCopy242 | replication, uncast concat, small cast, one element read twice | stage 1 (82, the replication member), unchanged |
| Z/z02_two_callers | § patLeftoverOpCopy242 | two parameters and a localparam built from one pattern, two instances | depth -> EQUAL / depth -> EQUAL |
| Z/z03_signcast | § signCastLitLeftoverIsBodyOperand242 | `unsigned'` over 4, 32'd5, 'h6, '1 and K | stage 1 32 -> 28 (see above) |
| Z/z04_genscopes | § s2CloneGenScopeInst242 | holders in a for-generate, a case-generate and a two-level if-generate | depth -> EQUAL / depth -> depth (first record #261 -> #2806, the walk reaching 3872 of golden's 3874 objects; the remaining face: golden lists the `unsigned'(2)` member value twice under `work@top.gf[0].u.C`'s member `n` in the elaborated view, ours none; 0 away) |
| Z/z05_override | § elabParamLeftoverOpRefUnnamed242 | instance override by another build call, pass-down | stage 1 (46), unchanged |
| Z/z06_concat | § patLeftoverOpCopy242 | uncast wide concat and small cast leftovers | stage 1 (54), unchanged |
| Z/z07_dupmember | § patLeftoverOpCopy242 | one cast element read by two members | depth -> EQUAL / depth -> EQUAL |
| Z/z08_sc_k1 | § signCastLitLeftoverIsBodyOperand242 | `unsigned'(4)` | depth -> EQUAL / depth -> EQUAL |
| Z/z08_sc_k3 | § signCastLitLeftoverIsBodyOperand242 | `unsigned'('h6)` | stage 1 -> EQUAL / stage 1 -> EQUAL |
| Z/z08_sc_k4 | § signCastLitLeftoverIsBodyOperand242 | `unsigned'('1)` | stage 1 -> EQUAL / stage 1 -> EQUAL |
| Z/z08_sc_k5 | § signCastLitLeftoverIsBodyOperand242 | `unsigned'(K)` (not a literal: the law abstains) | stage 1 (28), unchanged |
| Z/z09_passdown | § elabParamLeftoverOpRefUnnamed242 | holder passes its parameter to a child | stage 1 (58), unchanged |
| Z/z10_iface_holder | § patLeftoverOpCopy242 | holder in a module that wildcard-imports the package | stage 1 (42), unchanged |
| Z/z11_assembled | § signCastLitLeftoverIsBodyOperand242 | the struct assembles (no unreducible member) | stage 1 (50), unchanged |
| Z/z12_small | § signCastLitLeftoverIsBodyOperand242 | int-only struct, the member read in a continuous assignment | EQUAL -> EQUAL (bytes move) / depth -> EQUAL; downstream IDENTICAL |
| Z/z13_twofuncs | § signCastLitLeftoverIsBodyOperand242 | two holders built by two calls of one function | stage 1 (36), unchanged |

## Residues (ranked; ground A unless named)

1. The implementer's: Rggen d #23546 (ExprEmit's call-argument typespec, view-dependent), Earlgrey_0_1's 160 / 55
   objects behind #136315 (N0131's family), BlackBePipeInt #38807 / #38803, and the brief's items (3) to (7).
2. Stage-1 faces of the flip law's shapes on both binaries: real, string and enum ternaries (X/x09-x11), the
   arithmetic and unary leaves' INT encoding (X/x21, x25, x26), a sized-literal leaf (X/x23), a by-name import of the
   ternary parameter beside a qualified read (X/x05, x13), a user-call leaf and a parenthesized branch in the
   package listing (X/x03, x06).
3. Z/z04 elaborated view: holders inside generate scopes miss the `unsigned'(2)` member value golden lists twice
   under the instance copy's member (StmtEmit/ParamEmit leftover stamping on generate-scope instances).
4. `unsigned'(<parameter>)` member values (Z/z08_sc_k5, Z/z03's head); the replication-member and pass-down /
   override faces (Z/z01, z05, z09) and the wildcard-importing holder (Z/z10): stage 1 on both binaries.
5. The array law's stage-1 neighbours (Y/y01-y04, y06, y09-y11: interface-body constants, enum arrays,
   typedef'd unpacked dimensions, macro bounds from another package, string and real arrays).

## Drivers

`drivers/env.sh`, `case.sh`, `grid.sh`, `gridsum.py` (copied from r11u242repro, the case path prefix `v/`),
`dscase.py` (copied from v11u240repro), `caseaway.py` (new: the chain-keyed away census over the grid store, golden vs
two tags, fail-closed on `$FENCED`). Every corpus-reading step used the implementer's fence-checked drivers
(`bvmirror.sh`, `awayrows.py`, `det.sh`).

## Process

Worktrees `/tmp/wt_v11u242` (law) and `/tmp/wt_v11u242pris` (pristine) at `6cd6f5ac`; scratch `/tmp/v11u242_*`.
No submodule initialised; the main checkout was never written; no process of another agent was listed or signalled.
Every tool reached through a variable was checked executable first. The pristine worktree was used once more, after
every pristine measurement, to apply the implementer's patch for `law_index.py --check` and revert it (`git apply -R`;
`git status` clean after).
