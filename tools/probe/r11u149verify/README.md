# r11u149verify — second adversarial verification of passes 140 and 144 (verifier, measurement + one refinement as a patch file)

Base `1d0c82ef` (branch matrix-1.87). Landings under test: `c24699f1` (pass 140 + its verifier r11v140: twelve laws and
two refinements, expression/parameter ground) and `b2199096` (pass 144 + its verifier v11u144: ten laws, module/type
ground). Worktree `/tmp/wt_r11u149`, system-deps config, `-j 2`. This directory is the whole deliverable; nothing under
`src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited. The one proven break's refinement is
[fix.patch](fix.patch) (a `git diff 1d0c82ef -- src`, applies clean on `1d0c82ef`, NOT applied here).
`tools/uhdm-strictcmp/uhdm-strictcmp.cpp` is not edited: no comparator defect was found. The brief mentions "the
canonicalisation patch you were given": no such patch was handed to this pass, so the deliverable carries none.
Case directories name their law in the first line as `// § name`, so the landing must run `python3 scripts/law_index.py`
and commit `tests/LAWS.md` (the index already reads STALE at `1d0c82ef` in the main tree; every sweep's `rc=1` is that
check alone). The four slang-fenced tests are never named here: every driver reads them from `$FENCED`, which
`drivers/env.sh` takes from RESUME.md's own fence-check loop.

| binary | md5 | what |
|---|---|---|
| `on.bin` | `6820ba5daec69a13d1ff66dca5fcb356` | the worktree build of `1d0c82ef`, byte-identical to the main tree's `build/slang-uhdm` (both landings on) |
| `off.sh` / `off140.sh` / `off144.sh` | wrappers of `on.bin` | `R11U140_OFF=1 R11U144_OFF=1` / `R11U140_OFF=1` / `R11U144_OFF=1` (`R11U140_OFF` also drops r11v140's two refinements; there is no `R11V140_OFF` switch in the source) |
| `fix.bin` | `134fb0c36f027328611ae600c56123c5` | `1d0c82ef` + fix.patch (§ tpDefaultEndTopTwin149v); `fixoff.sh` = `fix.bin` under `R11V149_TPTWIN_OFF=1` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the main tree's, unchanged |

All frozen (`chmod 555`, `/tmp/r11u149_bin/`) before any measurement. `evidence/cmds_audit.txt`: every sweep's 3273 corpus
`slang:` lines name its own frozen binary or wrapper (ON, OF, X0, X4, FX: 3273 / 3273 each). The brief's
`/tmp/strict_sweep` databases were written at 03:31, before both landings, so this pass built its own sweeps.

## Verdict

**ONE BREAK, refined in fix.patch.** § defNetTypeParamPackedDim144 moves a field AWAY from golden on legal SV when the
type parameter's default is a PACKAGE typedef (`parameter type dtype = p::d_t`; `dtype [D-1:0] mem;`). The same defect
sits in pass 137's unpacked-dimension case of the same end-move (`dtype mem [2];`, § defNetTypeParamDefault137). That
defect was already wrong at pass 137, so it is not a pass-144 break, and the same refinement fixes it. No other law of
the 24 (12 + 2 refinements + 10) moved any field away from golden on 118 fresh cases × 2 modes (236 cells). The laws
compose: every conversion both landings claimed is theirs alone, and no row or case is equal only because two laws
cancel. Every unmasking is proven at the record level. The ten converted uhdm2rtlil rows are byte-identical to golden's
lane, and so are the two rows pass 144 moved without converting. The top residues all still stand. The fence check
holds: the fail-closed predictor refuses to run without `$FENCED` and, with it, reproduces the committed mover
prediction byte for byte.

### B1 — § defNetTypeParamPackedDim144 with a package typedef default (and pass 137's unpacked case)

`cases/tq/n01_pkg_struct_default` (golden vs law, strict records, both modes the same):

| record | golden | law on (`on.bin`) | law off (`R11U144_TPPACKEDNET_OFF`) |
|---|---|---|---|
| #2 `struct_typespec p::d_t` in `uhdmallPackages` (the definition) | 3:11-3:52 | **3:11-6:16** | 3:11-3:52 (matched) |
| #13 the same typedef in `uhdmtopPackages` (the elaborated twin) | 3:11-6:16 | 3:11-3:52 | 3:11-3:52 |
| #26 / #47 the type parameter's default and the net's typespec (module listing) | 3:11-6:16 | 3:11-3:52 | #47 `packed_array_typespec` (walk diverged) |

**The decode.** Golden's net binds the ELABORATED package's typedef object: writeNets' end-only populate moves the end of
that object and leaves the `uhdmallPackages` definition object alone. Ours holds the definition-view object in
`typeParamDefaultTs`, and the law moves that object's end. At design end § modPkgTypedefTopTs15
(`repointModOwnedTs16`) then re-points every module-owned reference to the twin, which is still unmoved. The law binds
the right typedef and fixes #47 (`type` -> `endline`), but #2, which pristine matched, now differs: that is a NEW
record, so B1 is a break. Every shape with a package typedef default shows it: `tq/n01`, `n08` (two nets), `n09` (the
typedef also used by another module). `tq/n07` (pass 137's `dtype mem [2]` case) shows the same wrong object. A
module-local or `$unit` typedef (`tq/n06`, the pass's own grid) is right.

**THE REFINEMENT § tpDefaultEndTopTwin149v** (fix.patch; switch `R11V149_TPTWIN_OFF`, also off under `R11U144_OFF`).
The shared end-move records every move it makes. `modPkgTypedefTopTs15`, right after it builds its def->top map and
before it re-points, hands each recorded move of a mapped definition object to its twin: the twin takes the last
recorded end (the last net wins, as before) and the definition object gets its own end back. An object with no twin
(a module or `$unit` typedef) is untouched.

| case (plain and --elabuhdm) | base | fix | fix + `R11V149_TPTWIN_OFF` |
|---|---|---|---|
| tq/n01_pkg_struct_default | endline (4 records) | **STRICT_EQUAL** 160 / 146 | base bytes |
| tq/n07_pkg_default_unpacked_137arm | endline (6 records) | **STRICT_EQUAL** 138 / 136 | base bytes |
| tq/n08_pkg_default_two_nets | endline | **STRICT_EQUAL** 197 / 172 | base bytes |
| tq/n09_pkg_default_other_user | endline | **STRICT_EQUAL** 216 / 201 | base bytes |
| tq/n04 (union default), n05 (+ a package parameter use) | stage 1, cmp 124 / 34 | stage 1, cmp 124 / 34, order-blind distance 45->41, 52->45, 24->18, 40->34 | base bytes |
| tq/n02, n03, n06 (inline struct, interface, `$unit` typedef) | — | bytes equal to base | base bytes |

Gates of `fix.bin` (the sweep FX, `/tmp/r11u149_wFX`):
- **Probe:** `EQUAL=2308 STRICT_NOTEQUAL=1779`, regressions=0 conversions=0 changes=0; the probe csv is byte-identical to `results/golden_probe.csv`.
- **Corpora:** surelog and uhdm2rtlil each read regressions=0 conversions=0 changes=0, and the scoreboards stay 480/3 + 474/3 and 803/1/67.
- **Downstream:** `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66`, with 0 cells differing from `results/downstream_uhdm2rtlil.csv`.
- **byteverify** fix vs base (`SELFCHECK=1`, same-length workdirs):
  - surelog: `PATH_SETS_IDENTICAL`, `MOVERS: 4 / 960`, selfcheck 959/960. The four are MiniAmiq d/t, SeqDriver d and SimpleUVM t, the UVM coin: each order-blind dump differs from the base by 4 lines, all `UINT:`/`vpiDecompile:` (evidence/coin_FX_vs_ON.txt).
  - uhdm2rtlil: `MOVERS: 0 / 1608`, selfcheck 1607/1608.
  - probe: 0 / 4087.
- **Prediction** (drivers/predict149.py, run on the base databases before any FX result was read, evidence/predict149_ON.tsv): 28 databases whose package typedef ends differ between the two package listings. The predicate is wider than the law, and none of the 28 moved: no corpus test or probe case has a package-typedef type-parameter default with a dimensioned definition net.
- **Byte controls** (drivers/bytes.sh, plain and --elabuhdm):
  - fix vs base over 1223 case directories (this directory, r11u144repro/grid, v11u144repro/brk, r11u140repro, r11v140repro, r11u137repro, r11u148share, r11u119repro, r11u118repro, r11v11u118repro, r11u143verify, v11u137repro, r11u139netbind, r11u142map): the only movers are this directory's tq/n01, n04, n05, n07, n08 and n09 (12 databases).
  - The first run also listed v11u137 h07 twice. Both binaries reject that case (rc 3) and write no database. bytes.sh now ignores a pair where both runs fail and neither writes a file.
  - `fixoff.sh` vs base: 0 movers on 310 directories. `R11U144_OFF` on the fix binary vs `R11U144_OFF` on base: 0 on 199.
- **Downstream of the cases:** every case keeps its verdict (evidence/downstream_cases.tsv).
- **Canaries** (FX sweep csvs): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1` / `EXPECT_UNKNOWN=6 ctcan2.sh` both PASS.

## 1. The break grid (118 fresh cases × plain/--elabuhdm, + 3 composition cases; every case names its law)

Goldens: pinned Surelog v1.87, check_probe's flags (`-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`, `-elabuhdm` in
elab mode), cached per content md5. Ours: `dut.sv --single-unit --nobuiltin` (`--elabuhdm`) under three switch states: ON
(both landings), OWN (the law's own switch off), OFF (both landings off). Per cell: rc, uhdm-cmp line count (`cN`),
order-blind dump distance to golden (`oN`), strict verdict, and the record rule from pass 131 (worse.py): a record
that the reference walk matched before its own structural divergence and that differs under ON is NEW (a BREAK).
Downstream: `scripts/downstream_uhdm2rtlil.one` per case, OFF vs ON (and FX), with a fresh golden cache. None of the
cases occurs in the implementers' or verifiers' grids. The new shapes are: interface / macro / ternary / concatenation
contexts; 2-D element and generate-block selects; CRLF and multi-line streams; loop-variable, case-branch, latch and
struct-member indices; deep base-select chains; interface-task, associative and dynamic-argument foreach loops;
unary / parenthesised / ternary / override pattern operands; struct-typed, `automatic`, `static`, package and interface
declarations; signed and byte elements with two importers; shortint, int unsigned, 3-D, signed, `integer` and
negative-literal package folds; generate-block, non-bare and two-instance renames; `parameter`-keyword, expression and
enum-member casts; expression, ascending, interface and override default fills; package, expression and generate
replication counts; instance arrays, nested generates, bind, generate sequences and property instance arrays under
--elabuhdm; generate-loop, `-:`, 2-D, parameterised and over-wide select Lhs; package-function, two-formal, decimal and
qualified-concatenation folded calls; function-local, struct-member, port, interface and generate folded bounds;
package-typedef, union, two-net and other-user type-parameter defaults; interface, two-bound, sub-module and package
alias bounds; package-parameter, function-return, package-variable, class-property and 2-D-member foreign qualifiers;
local static, protected virtual, extern, override and pure-then-implemented methods; attribute values, extern
prototypes and split-line attributes; parameter, generate-if, deep-member, nested-loop, localparam and unpacked-array
generate Lhs.

| grid | cases | cells | converts | toward golden / unmask | law not reached (bytes equal) | stage 1 both | BREAK |
|---|---|---|---|---|---|---|---|
| sca | 4 | 8 | 6 | 0 | 0 | 2 | 0 |
| scv | 4 | 8 | 2 | 2 | 4 | 0 | 0 |
| stm | 5 | 10 | 8 | 2 | 0 | 0 | 0 |
| plv | 4 | 8 | 6 | 0 | 2 | 0 | 0 |
| plt | 3 | 6 | 6 | 0 | 0 | 0 | 0 |
| fav | 4 | 8 | 4 | 0 | 4 | 0 | 0 |
| pso | 4 | 8 | 6 | 0 | 2 | 0 | 0 |
| mdi | 5 | 10 | 8 | 0 | 2 | 0 | 0 |
| lat | 4 | 8 | 1 | 1 | 0 | 6 | 0 |
| pfp | 8 | 16 | 14 | 0 | 0 | 2 | 0 |
| pfx | 3 | 6 | 0 | 0 | 4 | 2 | 0 |
| tdc | 3 | 6 | 4 | 1 | 0 | 1 | 0 |
| dfl | 4 | 8 | 0 | 1 | 0 | 7 | 0 |
| rcf | 3 | 6 | 0 | 0 | 6 | 0 | 0 |
| el | 8 | 16 | 0 | 2 | 13 | 1 | 0 |
| ia | 5 | 10 | 8 | 0 | 2 | 0 | 0 |
| pf | 4 | 8 | 8 | 0 | 0 | 0 | 0 |
| fb | 11 | 22 | 2 | 0 | 20 | 0 | 0 |
| tq | 9 | 18 | 2 | 2 | 2 | 6 | **6** (B1) |
| pt | 4 | 8 | 0 | 0 | 2 | 6 | 0 |
| qb | 5 | 10 | 4 | 0 | 4 | 2 | 0 |
| vf | 5 | 10 | 8 | 0 | 2 | 0 | 0 |
| at | 3 | 6 | 2 | 0 | 4 | 0 | 0 |
| hg | 6 | 12 | 3 | 5 | 4 | 0 | 0 |
| **total** | **118** | **236** | **102** | **16** | **77** | **35** | **6** |

Notes on the non-conversions:
- **Stage 1 on every binary (35 cells).** Each keeps or lowers its uhdm-cmp line count under the law (dfl 136 -> 112) and keeps or lowers its order-blind distance, with one exception, `pfp/n04_signed_vec_body` (52 -> 74, same 17-line uhdm-cmp head on both). Its head is the negative literal `-16'sd5` folded by X's param_assign, which the law does not touch. The +22 is the typespec-identity noise the order-blind count cannot see through: the same shape with `16'sd5` (`pfp/n05`) converts to STRICT_EQUAL under the law while its distance goes 6 -> 26.
- **Unmask cells.** Four cells read UNMASK and each is proven (evidence/grid_unmask_proof.txt; drivers/unmask_case.py aligns ours-OFF with ours-ON by difflib). `lat/n03` plain and `tdc/n02` elab: every grown record is unchanged by the law. `tq/n02` (both modes): the grown records are the inline default struct's member references (`<in>a` vs `a`). Those names are pass 144's R4, reached now because the net binds the default.
- **Downstream of the cases** (evidence/downstream_cases.tsv, 108 + 31 cases, OFF -> ON -> FX):
  - 126 IDENTICAL on all three.
  - `sca/n01`-`n04` go EQUIVALENT -> IDENTICAL: § sysArgUnaryWholeSpan140's spans reach the RTLIL src attributes.
  - No case leaves IDENTICAL.
  - Pre-existing on every binary: DIVERGENT on `pfx/n02_not_bare` (`assign o = ~P`, P a 2-D package fold), `tq/n03_iface` and `tq/n04_pkg_union_default`, all three judge-NE at stage 1; STATUS_DIFF on `dfl/n03_iface`.

The per-law tables (every cell) follow at the end of this README.

## 2. Composition (four full sweeps of the same binary: ON, OF = both off, X0 = 140 off, X4 = 144 off)

| sweep | probe EQUAL | surelog CMP_EQUAL (d + t) | uhdm2rtlil CMP_EQUAL (d + t) | vs committed baselines |
|---|---|---|---|---|
| ON | 2308 | 399 + 397 | 702 + 702 | regressions=0 conversions=0 changes=0 in all three; probe csv byte-identical to results/golden_probe.csv |
| OF | 2272 | 389 + 383 | 692 + 692 | regressions 36 / 24 / 20 = exactly the two landings' re-baselined rows |
| X0 (140 off) | 2285 | 391 + 389 | 697 + 697 | regressions 23 / 16 / 10 = pass 140's 49 |
| X4 (144 off) | 2295 | 397 + 391 | 697 + 697 | regressions 13 / 8 / 10 = pass 144's 31 |

- Every sweep keeps the judge scoreboards at 480/3 + 474/3 and 803/1/67.
- **Downstream:** ON and OF each read 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT and match `results/downstream_uhdm2rtlil.csv` on all 871 rows × 8 columns.
- **Claims** (drivers/compose.py, evidence/composition_rows.tsv): a landing's claims are the rows its commit re-baselined, read with `git show`. Pass 140 re-baselined 26 row-modes + 23 probe cases, which includes ClassVar t, DefaultPatternModule t and Kmac t, rows the implementer's README did not list but the landing measured. Pass 144 re-baselined 18 + 13.
- **Conversion census:** 80 conversions OF -> ON (probe 36, surelog 24, uhdm2rtlil 20).
  - Pass 140 claims 49 of them and pass 144 claims 31, so every one is claimed and none is unclaimed.
  - Each is moved by its claimer's switch alone: the row regresses in X0 exactly for pass 140's 49 and in X4 exactly for pass 144's 31.
  - No conversion needs both landings.
  - No row is equal with both landings on and with both off but not with one off (0 SUSPECT rows).
- **Every changed row** gets the record rule in all five directions, over the 126 CHANGE rows (probe 66, surelog 24, uhdm2rtlil 36) for OF->ON and over all 206 rows (conversions included) for the other four: OF->ON, OF->X4 (pass 140 alone), OF->X0 (pass 144 alone), X0->ON (pass 140 given pass 144) and X4->ON (pass 144 given pass 140) (evidence/recheck_*.tsv).
  - The verdicts are EQUAL, IMPROVE, SAME-RECS or UNMASK in every direction: **0 NEW and 0 earlier divergences in 126 + 4 × 206 checks.**
  - So each landing alone moves toward golden from either starting point, and no pair of laws cancels an error.
- **Byte movers ON vs OF** (byteverify, `SELFCHECK=1`, same-length workdirs):
  - surelog 54/960, uhdm2rtlil 56/1608, probe 104/4087.
  - The corpus mover sets are EXACTLY the union of the two landings' committed byteverify lists: surelog 35 ∪ 32 with 13 shared = 54, uhdm2rtlil 42 ∪ 14 = 56, 0 unpredicted, 0 missing.
  - Attributed by bytes (evidence/mover_attrib.txt, probe_mover_attrib.txt): surelog 22 moved by 140 only, 19 by 144 only, 13 by both (the UVM coin rows plus Earlgrey_0_1, SVSwitch and BuildUVMPkg, as both landings reported); uhdm2rtlil 42 by 140 and 14 by 144, disjoint; probe 69 by 140 only, 34 by 144 only, and 1 by both (`r10uvm57repro/b2_shape`, which improves in every direction).
  - Pass 140's own list of 70 probe movers is exactly its share here.
- **The cross-ground pairs the brief names:**
  - **§ foldedBoundTsRefUnstored144 × § impLhsCloneArrayTsOwnCopy140.** Pass 144 moves no byte of any ibex row or either StructArray row: X4 is byte-equal to ON on all of them. Pass 144's S1(b) face (the element bound's folded reference) is still untouched. In case `cmp/c3` (the ibex PmpAddrRst shape plus a module variable) pass 144 moves nothing and pass 140 improves.
  - **§ defGenLhsHpBaseAnchor144 × § procLvTrailIdxNamesByPath140.** The corpus rows are disjoint: genvar_iface_struct and iface_array_modport_drive are moved by 144, struct_dynamic_range and struct_member_trailing_index by 140. In case `cmp/c1` each law improves alone, and with both on the elab cell converts to STRICT_EQUAL: complementary faces, not a cancellation.
  - **§ elabCloneInstTreeUnstored144 × § pkgRefFoldClonesMultiDimOnly140.** In case `cmp/c2` (--elabuhdm) each law improves alone and together (evidence/composition_cases.txt).

## 3. The unmaskings (evidence/unmask_proof.tsv; drivers/unmask_proof.py)

For every row whose strict count grows from OF to ON, the record walks against golden were dumped in full
(`--dump-a/--dump-b`). The proof has two parts:

1. **Every grown record lies past OF's structural divergence.** No grown record precedes it, and ON's own divergence is later or absent.
2. **Each grown record is an object the landings did not write.** ours-OF and ours-ON are aligned record by record with difflib, and every grown record sits in an EQUAL block. So its difference from golden existed under OF, hidden behind OF's divergence.

| row | OF | ON | grown | before OF's divergence | written by the landings |
|---|---|---|---|---|---|
| Earlgrey_0_1 d | line(1051), diverged @51100 | line(1755), diverged @130430 | 719 | 0 | **0** (fullname 396, endcol 219, file 75, col 24, …) |
| Earlgrey_0_1 t | line(1051) @52346 | line(1755) @131904 | 719 | 0 | **0** |
| ibex_alu / branch_predict / compressed_decoder / decoder / icache / multdiv_fast / multdiv_slow / wb_stage / tracer (d and t) | fullname(2) (tracer 87), diverged @5550-5662 (tracer @4880) | fullname(9 / 20 / 141 / 28 / 200 / 109 / 26 / 32 / 587), no divergence | 8…501 | 0 | **0** on all 18 |
| ibex_pmp d/t | file(6) @5647 / @5557 | file(60) @13972 / @13882 | 55 | 0 | **0** |
| packed_struct_array_fifo d/t (pass 144) | endline(2) @190 / @100 | fullname(8), no divergence | 8 | 0 | **0** |
| probe k20_hdr_param_type_ctl (pass 144) | endline(3) @36 | endline(2), no divergence | 2 | 0 | **0** |
| probe h9_1e1m_port, hD_1e1mvec, vv1c_cast, t67b, f3/c05; StructArray… and NestedStructArray…PassedAsPort d/t | diverged | later or none | 1-8 | 0 | **0** |
| def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot (d/t) | type @36 | depth @43 | 1 | 0 | 1 each |

In the last row, the first difference moves 7 records later: the walk now matches the typedef struct, its XLEN member,
the range and the constants. The one "written" record is a member-default constant under XLEN. It sits under a newly
bound parent (the cast target was an integer_typespec in OF), so the aligner cannot pair it. The constant itself is
pre-existing: OF already lists 42 (latch rows 30) struct members carrying such a default constant, and ON lists the same
struct 3 members more (drivers/unmask_proof.py output; this is pass 140's residue R7, the type ground's member-default
mutation of the shared typedef). **Every growth the two landings reported is an unmasking; no new difference exists.**

## 4. Downstream bytes of the converted uhdm2rtlil rows (ON sweep, `<workdir>/downstream/<test>/{surelog,slanguh}/`)

| test | pass | `_nohier.il` | `.il` | `_synth.v` | fresh row |
|---|---|---|---|---|---|
| func_local_compound_xor | 140 | identical (13840 B) | identical | identical | `IDENTICAL,OK,OK,65,65,,` |
| param_struct_field_bitsel | 140 | identical (11856 B) | identical | identical | `IDENTICAL,OK,OK,6,6,,` |
| param_unpacked_struct_array | 140 | identical (10239 B) | identical | identical | `IDENTICAL,OK,OK,20,20,,` |
| struct_dynamic_range | 140 | identical (23959 B) | identical | identical | `IDENTICAL,OK,OK,68,68,,` |
| struct_member_trailing_index | 140 | identical (28800 B) | identical | identical | `IDENTICAL,OK,OK,177,177,,` |
| ParameterInitializedByPartSelectOfParametersAssignedToVar | 144 | identical (792 B) | identical | identical | `IDENTICAL,NO_GATES,NO_GATES,0,0,,` |
| ParameterOfParametrizedType | 144 | identical (411 B) | identical | identical | `IDENTICAL,NO_GATES,NO_GATES,0,0,,` |
| ParameterOfParametrizedTypeInSubmodule | 144 | identical (2267 B) | identical | identical | `IDENTICAL,NO_GATES,NO_GATES,0,0,,` |
| PkgParamAsFunctionArg | 144 | identical (313 B) | identical | identical | `IDENTICAL,NO_GATES,NO_GATES,0,0,,` |
| iface_array_modport_drive | 144 | identical (2232 B) | — | — (both lanes READ_FAIL) | `IDENTICAL,READ_FAIL,READ_FAIL,0,0,,both READ_FAIL` |
| genvar_iface_struct, packed_struct_array_fifo (moved, not converted) | 144 | identical | identical | identical | `IDENTICAL,OK,OK,20,20,,` / `IDENTICAL,OK,OK,25,25,,` |

All ten converted rows (the brief asked for two per pass) are byte-identical between the two lanes on every file both lanes write.

## 5. Residues re-measured at 1d0c82ef (evidence/residues_base.txt)

| list | residue | measured | stands? |
|---|---|---|---|
| 140 R1 | PatternStruct head; dfl/rcf next face (cont_assign fold) | PatternStruct d/t `differ:file(1)`; r11u140 dfl/d01 `file`, rcf/r01 `type` | yes |
| 140 R2 | N0284: FunctionParam, SelectGivenBySelectOnParameterInFunction, func_local_array | each d/t `differ:type(1)` (r11u148share's E law is still unlanded) | yes |
| 140 R3 | N0063 nested pattern ts ref, iface port view | iface_nested_param_field d/t `differ:fullname(5)` | yes |
| r11v140 1 | plv/v05_task (function-body lvalue) | `fullname` | yes |
| r11v140 2 | plv/v07_basesel_opidx | `fullname` | yes |
| r11v140 3 | stm/b05_comment, stm/b04_macro | `col`, `col` | yes |
| 144 S1 | ibex family two faces | ibex_alu fullname(9), …, ibex_tracer fullname(587), ibex_pmp file(60) (face (a) closed by pass 140; the (b) name face and the unmasked tails remain) | yes (partly: (a) closed) |
| 144 S2 | LocalParamInNestedForLoops | d/t `differ:fullname(2)` | yes |
| 144 S3 | packed_array_struct | d/t `differ:endline(2)` | yes |
| 144 R1 | PortExpr / ExplictiPorts | PortExpr d/t `endline(14)`; ExplictiPorts d `line(8)`, t `line(15)` | yes |
| 144 R2 | HierPathTypespec t | `fullname(1)` (d `equal`) | yes |
| 144 R3 | packed_struct_array_fifo after the law | d/t `fullname(8)` | yes |
| v11u144 1 | elaborated gen-scope index references (brk/hg/x1, x2, x5) | `fullname` each; this pass's hg/n01, n02, n05, n06 show the same face | yes |
| v11u144 2 | def-view gen Lhs with a trailing select (brk/hg/x4) | `endcol` | yes |
| v11u144 3 | net-binding shapes pc31 / pc33 | `col` / `fullname` | yes |

New residues this pass found. All are pristine-wrong; no law changes them:
- **R-a** — the B1 fix is not landed; it is in fix.patch.
- **R-b** — a definition-view generate RHS hier_path over a generate-scope path (`O[i].I[0].t`, el/n08) spans the base only (golden 8:21-8:32, ours 8:21-8:22), and its leaf stores the raw path.
- **R-c** — a property declaration inside an instance ARRAY under --elabuhdm is named by the definition (`work@chk.p_a`); golden names it by the element (`work@dut.u[1].p_a`, el/n06). The ELABPROP law does not reach it.
- **R-d** — downstream DIVERGENT on legal SV: `pfx/n02_not_bare` (`assign o = ~P` over a 2-D package fold), `tq/n03_iface` and `tq/n04_pkg_union_default`. All three are judge-NE at stage 1 on every binary, so they are real netlist differences, and none is in a corpus.

## 6. The fence (evidence/fence_check.txt; drivers/fence_check.sh, which prints counts only)

1. **The scan cannot reach fenced sources.** The fenced directories are resolved by path: 4 of 4. 0 unfenced tests share a scan directory with them, and 0 unfenced command-line tokens resolve into one. So pass 144's predictor, run with `$FENCED`, never opens a fenced source.
2. **No committed pass-144 file names a fenced test.** The word-match hit count is 0 for each of the four names. The only substring hit is the allowed superstring test name, in downstream_law.csv and predict_pristine.tsv, which v11u144 also reported. `evidence/predict_pristine.tsv` holds 0 fenced rows.
3. **The committed predictor is fail-closed and reproduces its prediction.** `drivers/predict.py` without `$FENCED` exits 1 and writes nothing. With `$FENCED` it scans 3315 rows (994 carry a face) and writes a file BYTE-IDENTICAL to the committed `predict_pristine.tsv` (md5 `338916705f10`).
4. **What the scan can have influenced.** Its only use in pass 144 is the byte-mover prediction (README section 6, "44 of 46 predicted").
   - The laws come from the grids (`grid/{ia,pf,fb,el,tq,pt,qb,vf,at,hg}`, no fenced name) and from Surelog's source (section 3 of that README).
   - The attributions come from re-running each mover's `cmds.txt` under the switches.
   - This pass's composition confirms pass 144's mover list independently: the X4 sweep attributes exactly 32 surelog and 14 uhdm2rtlil byte movers to pass 144, equal to its committed byteverify lists, and no fenced row moves in any of the five sweeps.
   - **No measurement, law or case of pass 144 rests on the unfenced first scan.**

This pass's own drivers never read a fenced row. compose.py, recheck.py and unmask_proof.py drop `$FENCED` names, and predict149.py skips their workdirs. The mandated `tests/sweep.sh` gate itself dispatches every corpus test, as every landing's sweep does.

## 7. Gates (this pass's deliverable changes no binary; the base binary is the measured one)

1. **Build:** the worktree `build/slang-uhdm` has md5 `6820ba5daec6…`, equal to the main tree's. The fix build is `134fb0c36f02…`.
2. **Probe:** ON and FX both read regressions=0 conversions=0 changes=0, and each probe csv is byte-identical to `results/golden_probe.csv`.
3. **Corpora:** ON and FX read regressions=0 conversions=0 changes=0 in both corpora.
4. **Downstream:** ON, OF and FX each read `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66`, with 0 cells differing from the baseline. No row leaves IDENTICAL, and every row this pass targets (section 4) reads IDENTICAL.
5. **uhdm-cmp:** no corpus row or probe case changes status in any of the five sweeps except the landings' own claimed rows (the status join). Every grid cell keeps its uhdm-cmp count under each law, or lowers it (dfl 136 -> 112).
6. **byteverify** (sections 2 and B1): every mover is named, predicted and attributed.
7. **Canaries** (evidence/canaries.txt):
   - ON: `canaries.sh` surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS; `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.
   - FX: the same.
8. **Positive controls:** byteverify's selfcheck flags 959/960 and 1607/1608. The bytes.sh census of the fix sees its 12 databases. The grid sees the B1 NEW records and the 102 conversions.

## Files

- `cases/<grid>/<case>/dut.sv`: 121 cases, each with its law on the first line. `el/` holds the elaboration-law grid, and `cmp/` holds the three composition cases.
- `fix.patch`: § tpDefaultEndTopTwin149v in `src/ModuleEmit.cpp` and `src/TypeEmit.cpp` (`git diff 1d0c82ef -- src`).
- `drivers/`:
  - `env.sh` sets the pinned tools and `$FENCED`, read from RESUME.md.
  - `sweep.sh <ON|OF|X0|X4|FX>` runs one sweep.
  - `case.sh` runs one case (golden, ours, uhdm-cmp, strict, order-blind distance). `grid.sh` runs a case under ON, OFF and OWN in both modes. `score.py` scores the grid.
  - `pairjudge.py`, `unmask_case.py` judge a single case directory.
  - `compose.py` joins the four sweeps. `recheck.py` applies the record rule in any direction, and `unmask_proof.py` proves the unmaskings.
  - `predict149.py` predicts the fix's movers. `bytes.sh` is the byte control over case trees. `coin.sh` does the order-blind UVM coin check.
  - `ds.py`, `ds_all.sh` run the downstream harness on the cases. `fence_check.sh` runs the fence check. `mktables.py` builds the per-law tables below.
- `evidence/`:
  - `sweep_{ON,OF,X0,X4,FX}.txt`
  - `composition_rows.tsv`, `composition_totals.txt`, `composition_cases.txt`
  - `recheck_{OF_ON,OF_X0,OF_X4,X0_ON,X4_ON}.tsv`
  - `unmask_proof.tsv`, `grid_unmask_proof.txt`
  - `byteverify_{ON_vs_OF,FX_vs_ON}_{surelog,uhdm2rtlil}.txt`, `mover_attrib.txt`, `probe_mover_attrib.txt`, `probe_movers_*.txt`
  - `predict149_ON.tsv`, `bytes_*.txt`, `coin_FX_vs_ON.txt`, `fix_tq_cases.txt`
  - `grid_raw.txt`, `grid_score.tsv`, `downstream_cases.tsv`
  - `residues_base.txt`, `fence_check.txt`, `canaries.txt`, `cmds_audit.txt`

## Per-law tables (cell = strict verdict / uhdm-cmp lines / order-blind distance [/ rc]; EQ = STRICT_EQUAL, S1 = uhdm-cmp stage 1)

#### § sysArgUnaryWholeSpan140 (`R11U140_SYSUNARY_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `sca/n01_iface_ca` | elab | S1/c47/o27 | S1/c47/o27 | S1/c47/o23 | stage 1 both |  |
| `sca/n01_iface_ca` | plain | S1/c47/o29 | S1/c47/o29 | S1/c47/o25 | stage 1 both | EQUIVALENT -> IDENTICAL |
| `sca/n02_ternary_cond` | elab | NE:endcol/c0/o12 | NE:endcol/c0/o12 | EQ/c0/o0 | law converts |  |
| `sca/n02_ternary_cond` | plain | NE:endcol/c0/o8 | NE:endcol/c0/o8 | EQ/c0/o0 | law converts | EQUIVALENT -> IDENTICAL |
| `sca/n03_macro_arg` | elab | NE:endcol/c0/o8 | NE:endcol/c0/o8 | EQ/c0/o0 | law converts |  |
| `sca/n03_macro_arg` | plain | NE:endcol/c0/o39 | NE:endcol/c0/o39 | EQ/c0/o35 | law converts | EQUIVALENT -> IDENTICAL |
| `sca/n04_concat_operand` | elab | NE:endcol/c0/o16 | NE:endcol/c0/o16 | EQ/c0/o0 | law converts |  |
| `sca/n04_concat_operand` | plain | NE:endcol/c0/o8 | NE:endcol/c0/o8 | EQ/c0/o0 | law converts | EQUIVALENT -> IDENTICAL |

#### § sysArgUnaryConstSelToken140v (`R11V140_CONSTSEL_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `scv/n01_2d_elem_ips_width` | elab | NE:fullname/c0/o8 | NE:endcol/c0/o16 | NE:fullname/c0/o8 | toward golden |  |
| `scv/n01_2d_elem_ips_width` | plain | NE:fullname/c0/o4 | NE:endcol/c0/o8 | NE:fullname/c0/o4 | toward golden | IDENTICAL -> IDENTICAL |
| `scv/n02_genblk_range` | elab | NE:endcol/c0/o6 | NE:endcol/c0/o6 | NE:endcol/c0/o6 | law not reached (bytes equal) |  |
| `scv/n02_genblk_range` | plain | S1/c31/o6 | S1/c31/o6 | S1/c31/o6 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `scv/n03_ff_lhs_range` | elab | S1/c92/o31 | S1/c92/o31 | S1/c92/o31 | law not reached (bytes equal) |  |
| `scv/n03_ff_lhs_range` | plain | S1/c92/o8 | S1/c92/o8 | S1/c92/o8 | law not reached (bytes equal) | EQUIVALENT -> EQUIVALENT |
| `scv/n04_ips_base_expr_in_width_nested` | elab | EQ/c0/o0 | NE:endcol/c0/o8 | EQ/c0/o0 | law converts |  |
| `scv/n04_ips_base_expr_in_width_nested` | plain | EQ/c0/o0 | NE:endcol/c0/o4 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § streamOperandBraceSpan140 (`R11U140_STREAMBRACE_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `stm/n01_iface` | elab | NE:col/c0/o4 | NE:col/c0/o4 | EQ/c0/o0 | law converts |  |
| `stm/n01_iface` | plain | NE:col/c0/o4 | NE:col/c0/o4 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `stm/n02_pkg_func` | elab | NE:col/c0/o16 | NE:col/c0/o16 | EQ/c0/o0 | law converts |  |
| `stm/n02_pkg_func` | plain | NE:col/c0/o8 | NE:col/c0/o8 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `stm/n03_in_concat` | elab | NE:col/c0/o42 | NE:col/c0/o42 | EQ/c0/o30 | law converts |  |
| `stm/n03_in_concat` | plain | NE:col/c0/o38 | NE:col/c0/o38 | EQ/c0/o30 | law converts | IDENTICAL -> IDENTICAL |
| `stm/n04_genfor` | elab | NE:fullname/c0/o24 | NE:fullname/c0/o24 | NE:fullname/c0/o16 | toward golden |  |
| `stm/n04_genfor` | plain | NE:fullname/c0/o24 | NE:fullname/c0/o24 | NE:fullname/c0/o16 | toward golden | IDENTICAL -> IDENTICAL |
| `stm/n05_crlf_multiline` | elab | NE:line/c0/o8 | NE:line/c0/o8 | EQ/c0/o0 | law converts |  |
| `stm/n05_crlf_multiline` | plain | NE:line/c0/o8 | NE:line/c0/o8 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § procLvTrailIdxNamesByPath140 (`R11U140_LVIDX_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `plv/n01_loopvar_idx` | elab | NE:fullname/c0/o8 | NE:fullname/c0/o8 | EQ/c0/o0 | law converts |  |
| `plv/n01_loopvar_idx` | plain | NE:fullname/c0/o4 | NE:fullname/c0/o4 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `plv/n02_case_branch` | elab | NE:fullname/c0/o16 | NE:fullname/c0/o16 | EQ/c0/o0 | law converts |  |
| `plv/n02_case_branch` | plain | NE:fullname/c0/o8 | NE:fullname/c0/o8 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `plv/n03_latch` | elab | NE:fullname/c0/o8 | NE:fullname/c0/o8 | EQ/c0/o0 | law converts |  |
| `plv/n03_latch` | plain | NE:fullname/c0/o4 | NE:fullname/c0/o4 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `plv/n04_idx_member` | elab | NE:col/c0/o10 | NE:col/c0/o10 | NE:col/c0/o10 | law not reached (bytes equal) |  |
| `plv/n04_idx_member` | plain | NE:col/c0/o5 | NE:col/c0/o5 | NE:col/c0/o5 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |

#### § procLvBaseSelTrailAtIdx140 (`R11U140_LVTRAIL_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `plt/n01_loopvar_base` | elab | NE:fullname/c0/o12 | NE:fullname/c0/o12 | EQ/c0/o0 | law converts |  |
| `plt/n01_loopvar_base` | plain | NE:fullname/c0/o6 | NE:fullname/c0/o6 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `plt/n02_deep_chain` | elab | NE:fullname/c0/o12 | NE:fullname/c0/o12 | EQ/c0/o0 | law converts |  |
| `plt/n02_deep_chain` | plain | NE:fullname/c0/o6 | NE:fullname/c0/o6 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `plt/n03_if_else` | elab | NE:fullname/c0/o24 | NE:fullname/c0/o24 | EQ/c0/o0 | law converts |  |
| `plt/n03_if_else` | plain | NE:fullname/c0/o12 | NE:fullname/c0/o12 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § foreachArrayPlaceholderFile140 (`R11U140_FEFILE_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `fav/n01_iface_task` | elab | S1/c223/o36 | S1/c223/o36 | S1/c223/o36 | law not reached (bytes equal) |  |
| `fav/n01_iface_task` | plain | S1/c219/o34 | S1/c219/o34 | S1/c219/o34 | law not reached (bytes equal) | EQUIVALENT -> EQUIVALENT |
| `fav/n02_assoc` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `fav/n02_assoc` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fav/n03_func_dynarg` | elab | NE:file/c0/o2 | NE:file/c0/o2 | EQ/c0/o2 | law converts |  |
| `fav/n03_func_dynarg` | plain | NE:file/c0/o2 | NE:file/c0/o2 | EQ/c0/o2 | law converts | IDENTICAL -> IDENTICAL |
| `fav/n04_class_in_module` | elab | NE:file/c0/o40 | NE:file/c0/o40 | EQ/c0/o40 | law converts |  |
| `fav/n04_class_in_module` | plain | NE:file/c0/o0 | NE:file/c0/o0 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § elabPatOperandRefSpan140 (`R11U140_PATOPSPAN_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `pso/n01_unary_minus` | elab | NE:line/c0/o20 | NE:line/c0/o20 | EQ/c0/o14 | law converts |  |
| `pso/n01_unary_minus` | plain | NE:line/c0/o20 | NE:line/c0/o20 | EQ/c0/o14 | law converts | IDENTICAL -> IDENTICAL |
| `pso/n02_paren_product` | elab | NE:line/c0/o18 | NE:line/c0/o18 | EQ/c0/o12 | law converts |  |
| `pso/n02_paren_product` | plain | NE:line/c0/o18 | NE:line/c0/o18 | EQ/c0/o12 | law converts | IDENTICAL -> IDENTICAL |
| `pso/n03_ternary_cond` | elab | S1/c164/o86 | S1/c164/o86 | S1/c164/o86 | law not reached (bytes equal) |  |
| `pso/n03_ternary_cond` | plain | S1/c164/o86 | S1/c164/o86 | S1/c164/o86 | law not reached (bytes equal) | EQUIVALENT -> EQUIVALENT |
| `pso/n04_sub_override` | elab | NE:line/c0/o40 | NE:line/c0/o40 | EQ/c0/o28 | law converts |  |
| `pso/n04_sub_override` | plain | NE:line/c0/o40 | NE:line/c0/o40 | EQ/c0/o28 | law converts | IDENTICAL -> IDENTICAL |

#### § multiDeclOneItem140 (`R11U140_MULTIDECL_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `mdi/n01_struct_typed` | elab | NE:line/c0/o24 | NE:line/c0/o24 | EQ/c0/o0 | law converts |  |
| `mdi/n01_struct_typed` | plain | NE:line/c0/o12 | NE:line/c0/o12 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `mdi/n02_automatic_kw` | elab | NE:line/c0/o20 | NE:line/c0/o20 | EQ/c0/o0 | law converts |  |
| `mdi/n02_automatic_kw` | plain | NE:line/c0/o8 | NE:line/c0/o8 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `mdi/n03_pkg_func` | elab | NE:line/c0/o48 | NE:line/c0/o48 | EQ/c0/o0 | law converts |  |
| `mdi/n03_pkg_func` | plain | NE:line/c0/o24 | NE:line/c0/o24 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `mdi/n04_iface_func_second_multi` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `mdi/n04_iface_func_second_multi` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `mdi/n05_static_kw_task` | elab | NE:line/c0/o20 | NE:line/c0/o20 | EQ/c0/o0 | law converts |  |
| `mdi/n05_static_kw_task` | plain | NE:line/c0/o8 | NE:line/c0/o8 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § impLhsCloneArrayTsOwnCopy140 (`R11U140_LHSARRTS_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `lat/n01_signed_elem` | elab | S1/c102/o127 | S1/c102/o127 | S1/c102/o89 | stage 1 both |  |
| `lat/n01_signed_elem` | plain | S1/c102/o143 | S1/c102/o143 | S1/c102/o105 | stage 1 both | IDENTICAL -> IDENTICAL |
| `lat/n02_byte_elem_func` | elab | S1/c24/o102 | S1/c24/o102 | S1/c24/o64 | stage 1 both |  |
| `lat/n02_byte_elem_func` | plain | S1/c24/o102 | S1/c24/o102 | S1/c24/o64 | stage 1 both | IDENTICAL -> IDENTICAL |
| `lat/n03_two_mods` | elab | NE:type/c0/o101 | NE:type/c0/o101 | EQ/c0/o61 | law converts |  |
| `lat/n03_two_mods` | plain | NE:type/c0/o119 | NE:type/c0/o119 | NE:fullname/c0/o79 | unmask (proven) | IDENTICAL -> IDENTICAL |
| `lat/n04_localparam_use` | elab | S1/c22/o86 | S1/c22/o86 | S1/c22/o46 | stage 1 both |  |
| `lat/n04_localparam_use` | plain | S1/c22/o86 | S1/c22/o86 | S1/c22/o46 | stage 1 both | IDENTICAL -> IDENTICAL |

#### § pkgRefFoldClonesMultiDimOnly140 (`R11U140_PKGREFMD_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `pfp/n01_shortint` | elab | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o6 | law converts |  |
| `pfp/n01_shortint` | plain | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o6 | law converts | IDENTICAL -> IDENTICAL |
| `pfp/n02_int_unsigned` | elab | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o5 | law converts |  |
| `pfp/n02_int_unsigned` | plain | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o5 | law converts | IDENTICAL -> IDENTICAL |
| `pfp/n03_three_dim` | elab | NE:fullname/c0/o73 | NE:fullname/c0/o73 | EQ/c0/o69 | law converts |  |
| `pfp/n03_three_dim` | plain | NE:fullname/c0/o73 | NE:fullname/c0/o73 | EQ/c0/o69 | law converts | IDENTICAL -> IDENTICAL |
| `pfp/n04_signed_vec_body` | elab | S1/c17/o52 | S1/c17/o52 | S1/c17/o74 | stage 1 both |  |
| `pfp/n04_signed_vec_body` | plain | S1/c17/o52 | S1/c17/o52 | S1/c17/o74 | stage 1 both | IDENTICAL -> IDENTICAL |
| `pfp/n05_signed_vec_body_pos` | elab | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o26 | law converts |  |
| `pfp/n05_signed_vec_body_pos` | plain | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o26 | law converts | IDENTICAL -> IDENTICAL |
| `pfp/n06_unsigned_vec_body_ctl` | elab | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o25 | law converts |  |
| `pfp/n06_unsigned_vec_body_ctl` | plain | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o25 | law converts | IDENTICAL -> IDENTICAL |
| `pfp/n07_signed_vec_hdr` | elab | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o26 | law converts |  |
| `pfp/n07_signed_vec_hdr` | plain | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o26 | law converts | IDENTICAL -> IDENTICAL |
| `pfp/n08_integer_kw_body` | elab | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o6 | law converts |  |
| `pfp/n08_integer_kw_body` | plain | NE:line/c0/o6 | NE:line/c0/o6 | EQ/c0/o6 | law converts | IDENTICAL -> IDENTICAL |

#### § mdRenameNotUnderBareCa140v (`R11V140_MDRENAME_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `pfx/n01_genblk_assign` | elab | NE:fullname/c0/o98 | EQ/c0/o94 | EQ/c0/o94 | law not reached (bytes equal) |  |
| `pfx/n01_genblk_assign` | plain | NE:fullname/c0/o98 | EQ/c0/o94 | EQ/c0/o94 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `pfx/n02_not_bare` | elab | S1/c87/o25 | S1/c87/o21 | S1/c87/o21 | law not reached (bytes equal) |  |
| `pfx/n02_not_bare` | plain | S1/c87/o25 | S1/c87/o21 | S1/c87/o21 | law not reached (bytes equal) | DIVERGENT -> DIVERGENT |
| `pfx/n03_two_inst_one_reads` | elab | S1/c87/o53 | S1/c87/o61 | S1/c87/o53 | stage 1 both |  |
| `pfx/n03_two_inst_one_reads` | plain | S1/c87/o53 | S1/c87/o61 | S1/c87/o53 | stage 1 both | IDENTICAL -> IDENTICAL |

#### § pkgTypedefCastTargetTs140 (`R11U140_PKGTDCAST_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `tdc/n01_parameter_kw` | elab | NE:type/c0/o5/rc4 | NE:type/c0/o5/rc4 | EQ/c0/o0 | law converts |  |
| `tdc/n01_parameter_kw` | plain | NE:type/c0/o5/rc4 | NE:type/c0/o5/rc4 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `tdc/n02_cast_expr` | elab | NE:type/c0/o9/rc4 | NE:type/c0/o9/rc4 | NE:endcol/c0/o4 | unmask (proven) |  |
| `tdc/n02_cast_expr` | plain | S1/c62/o28/rc4 | S1/c62/o28/rc4 | S1/c62/o23 | stage 1 both | IDENTICAL -> IDENTICAL |
| `tdc/n03_enum_member` | elab | NE:type/c0/o5/rc4 | NE:type/c0/o5/rc4 | EQ/c0/o0 | law converts |  |
| `tdc/n03_enum_member` | plain | NE:type/c0/o5/rc4 | NE:type/c0/o5/rc4 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § defaultFillOneConstant140 (`R11U140_DEFFILL_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `dfl/n01_expr_value` | elab | S1/c136/o117 | S1/c136/o117 | S1/c112/o105 | stage 1 both |  |
| `dfl/n01_expr_value` | plain | S1/c136/o133 | S1/c136/o133 | S1/c112/o121 | stage 1 both | IDENTICAL -> IDENTICAL |
| `dfl/n02_ascending` | elab | S1/c136/o105 | S1/c136/o105 | S1/c112/o93 | stage 1 both |  |
| `dfl/n02_ascending` | plain | S1/c136/o121 | S1/c136/o121 | S1/c112/o109 | stage 1 both | IDENTICAL -> IDENTICAL |
| `dfl/n03_iface` | elab | NE:type/c0/o42 | NE:type/c0/o42 | NE:type/c0/o34 | same records |  |
| `dfl/n03_iface` | plain | S1/c31/o38 | S1/c31/o38 | S1/c31/o30 | stage 1 both | STATUS_DIFF -> STATUS_DIFF |
| `dfl/n04_override` | elab | S1/c17/o76 | S1/c17/o76 | S1/c17/o68 | stage 1 both |  |
| `dfl/n04_override` | plain | S1/c17/o63 | S1/c17/o63 | S1/c17/o55 | stage 1 both | IDENTICAL -> IDENTICAL |

#### § replCountFoldFile140 (`R11U140_REPLCNTFILE_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `rcf/n01_pkg_count` | elab | S1/c50/o101 | S1/c50/o101 | S1/c50/o101 | law not reached (bytes equal) |  |
| `rcf/n01_pkg_count` | plain | S1/c50/o125 | S1/c50/o125 | S1/c50/o125 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `rcf/n02_expr_count` | elab | S1/c58/o35 | S1/c58/o35 | S1/c58/o35 | law not reached (bytes equal) |  |
| `rcf/n02_expr_count` | plain | S1/c58/o97 | S1/c58/o97 | S1/c58/o97 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `rcf/n03_genblk` | elab | S1/c47/o291 | S1/c47/o291 | S1/c47/o291 | law not reached (bytes equal) |  |
| `rcf/n03_genblk` | plain | S1/c47/o215 | S1/c47/o215 | S1/c47/o215 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |

#### § elabCloneInstTreeUnstored144 (`R11U144_ELABINST_OFF` + `R11U144_ELABPROP_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `el/n01_inst_array` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `el/n01_inst_array` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `el/n02_nested_gen_hp` | elab | S1/c364/o846 | S1/c364/o846 | S1/c364/o846 | stage 1 both |  |
| `el/n02_nested_gen_hp` | plain | S1/c324/o86 | S1/c324/o86 | S1/c324/o86 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `el/n03_bind` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `el/n03_bind` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `el/n04_seq_in_gen` | elab | S1/c353/o84 | S1/c353/o84 | S1/c353/o84 | law not reached (bytes equal) |  |
| `el/n04_seq_in_gen` | plain | S1/c353/o45 | S1/c353/o45 | S1/c353/o45 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `el/n05_carry_chain_hp` | elab | NE:fullname/c0/o534 | NE:fullname/c0/o534 | NE:fullname/c0/o522 | toward golden |  |
| `el/n05_carry_chain_hp` | plain | NE:fullname/c0/o14 | NE:fullname/c0/o14 | NE:fullname/c0/o14 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `el/n06_inst_array_prop` | elab | NE:fullname/c0/o38 | NE:fullname/c0/o38 | NE:fullname/c0/o38 | law not reached (bytes equal) |  |
| `el/n06_inst_array_prop` | plain | S1/c351/o42 | S1/c351/o42 | S1/c351/o42 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `el/n07_bind_seq_gen` | elab | S1/c421/o84 | S1/c421/o84 | S1/c421/o84 | law not reached (bytes equal) |  |
| `el/n07_bind_seq_gen` | plain | S1/c421/o45 | S1/c421/o45 | S1/c421/o45 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `el/n08_nested_gen_member` | elab | NE:endcol/c0/o508 | NE:endcol/c0/o508 | NE:endcol/c0/o492 | toward golden |  |
| `el/n08_nested_gen_member` | plain | NE:endcol/c0/o44 | NE:endcol/c0/o44 | NE:endcol/c0/o44 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |

#### § caSelLhsBareDecNoAdjust144 (`R11U144_SELBAREDEC_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `ia/n01_genloop` | elab | NE:col/c0/o12 | NE:col/c0/o12 | NE:col/c0/o12 | law not reached (bytes equal) |  |
| `ia/n01_genloop` | plain | NE:col/c0/o12 | NE:col/c0/o12 | NE:col/c0/o12 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `ia/n02_minus_colon` | elab | NE:size/c0/o20 | NE:size/c0/o20 | EQ/c0/o20 | law converts |  |
| `ia/n02_minus_colon` | plain | NE:size/c0/o20 | NE:size/c0/o20 | EQ/c0/o20 | law converts | IDENTICAL -> IDENTICAL |
| `ia/n03_2d_packed` | elab | NE:size/c0/o28 | NE:size/c0/o28 | EQ/c0/o28 | law converts |  |
| `ia/n03_2d_packed` | plain | NE:size/c0/o28 | NE:size/c0/o28 | EQ/c0/o28 | law converts | IDENTICAL -> IDENTICAL |
| `ia/n04_param_sub` | elab | NE:size/c0/o14 | NE:size/c0/o14 | EQ/c0/o14 | law converts |  |
| `ia/n04_param_sub` | plain | NE:size/c0/o14 | NE:size/c0/o14 | EQ/c0/o14 | law converts | IDENTICAL -> IDENTICAL |
| `ia/n05_value_wider_than_select` | elab | NE:decompile/c0/o26 | NE:decompile/c0/o26 | EQ/c0/o26 | law converts |  |
| `ia/n05_value_wider_than_select` | plain | NE:decompile/c0/o26 | NE:decompile/c0/o26 | EQ/c0/o26 | law converts | IDENTICAL -> IDENTICAL |

#### § callFoldFormalBitSelLoc144 (`R11U144_CALLBITSEL_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `pf/n01_pkg_func_lit` | elab | NE:file/c0/o4 | NE:file/c0/o4 | EQ/c0/o0 | law converts |  |
| `pf/n01_pkg_func_lit` | plain | NE:file/c0/o2 | NE:file/c0/o2 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `pf/n02_two_formals` | elab | NE:file/c0/o4 | NE:file/c0/o4 | EQ/c0/o0 | law converts |  |
| `pf/n02_two_formals` | plain | NE:file/c0/o2 | NE:file/c0/o2 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `pf/n03_dec_literal` | elab | NE:file/c0/o4 | NE:file/c0/o4 | EQ/c0/o0 | law converts |  |
| `pf/n03_dec_literal` | plain | NE:file/c0/o2 | NE:file/c0/o2 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `pf/n04_concat_param_repl` | elab | NE:endcol/c0/o0 | NE:endcol/c0/o0 | EQ/c0/o0 | law converts |  |
| `pf/n04_concat_param_repl` | plain | NE:endcol/c0/o0 | NE:endcol/c0/o0 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § foldedBoundTsRefUnstored144 (`R11U144_FOLDTSNAME_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `fb/n01_func_local` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `fb/n01_func_local` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n02_iface_var` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `fb/n02_iface_var` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n03_genif_var` | elab | EQ/c0/o66 | EQ/c0/o66 | EQ/c0/o66 | law not reached (bytes equal) |  |
| `fb/n03_genif_var` | plain | EQ/c0/o2 | EQ/c0/o2 | EQ/c0/o2 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n04_nonansi_port` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `fb/n04_nonansi_port` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n05_func_local_ident` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `fb/n05_func_local_ident` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n06_struct_member_ident` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `fb/n06_struct_member_ident` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n07_nonansi_port_ident` | elab | S1/c15/o8 | S1/c15/o8 | S1/c15/o8 | law not reached (bytes equal) |  |
| `fb/n07_nonansi_port_ident` | plain | S1/c15/o8 | S1/c15/o8 | S1/c15/o8 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n08_iface_ident` | elab | S1/c17/o9 | S1/c17/o9 | S1/c17/o9 | law not reached (bytes equal) |  |
| `fb/n08_iface_ident` | plain | S1/c17/o9 | S1/c17/o9 | S1/c17/o9 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n09_genfor_ident` | elab | NE:fullname/c0/o240 | NE:fullname/c0/o240 | NE:fullname/c0/o240 | law not reached (bytes equal) |  |
| `fb/n09_genfor_ident` | plain | NE:fullname/c0/o16 | NE:fullname/c0/o16 | NE:fullname/c0/o16 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n10_ansi_port_ident` | elab | S1/c15/o8 | S1/c15/o8 | S1/c15/o8 | law not reached (bytes equal) |  |
| `fb/n10_ansi_port_ident` | plain | S1/c15/o8 | S1/c15/o8 | S1/c15/o8 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `fb/n11_two_vars_one_decl` | elab | NE:fullname/c0/o3 | NE:fullname/c0/o3 | EQ/c0/o0 | law converts |  |
| `fb/n11_two_vars_one_decl` | plain | NE:fullname/c0/o3 | NE:fullname/c0/o3 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § defNetTypeParamPackedDim144 (`R11U144_TPPACKEDNET_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `tq/n01_pkg_struct_default` | elab | NE:endline/c0/o49 | NE:endline/c0/o49 | NE:endline/c0/o6 | **BREAK** NEW[2] |  |
| `tq/n01_pkg_struct_default` | plain | NE:endline/c0/o49 | NE:endline/c0/o49 | NE:endline/c0/o6 | **BREAK** NEW[2] | IDENTICAL -> IDENTICAL |
| `tq/n02_two_packed_dims` | elab | NE:endline/c0/o85 | NE:endline/c0/o85 | NE:fullname/c0/o74 | unmask (proven) |  |
| `tq/n02_two_packed_dims` | plain | NE:endline/c0/o85 | NE:endline/c0/o85 | NE:fullname/c0/o74 | unmask (proven) | IDENTICAL -> IDENTICAL |
| `tq/n03_iface` | elab | S1/c79/o156 | S1/c79/o156 | S1/c79/o145 | stage 1 both |  |
| `tq/n03_iface` | plain | S1/c79/o140 | S1/c79/o140 | S1/c79/o129 | stage 1 both | DIVERGENT -> DIVERGENT |
| `tq/n04_pkg_union_default` | elab | S1/c124/o56 | S1/c124/o56 | S1/c124/o49 | stage 1 both |  |
| `tq/n04_pkg_union_default` | plain | S1/c124/o52 | S1/c124/o52 | S1/c124/o45 | stage 1 both | DIVERGENT -> DIVERGENT |
| `tq/n05_pkg_default_unused_pkg_ref` | elab | S1/c34/o77 | S1/c34/o77 | S1/c34/o40 | stage 1 both |  |
| `tq/n05_pkg_default_unused_pkg_ref` | plain | S1/c34/o61 | S1/c34/o61 | S1/c34/o24 | stage 1 both | IDENTICAL -> IDENTICAL |
| `tq/n06_local_typedef_ctl` | elab | NE:endline/c0/o41 | NE:endline/c0/o41 | EQ/c0/o2 | law converts |  |
| `tq/n06_local_typedef_ctl` | plain | NE:endline/c0/o41 | NE:endline/c0/o41 | EQ/c0/o2 | law converts | IDENTICAL -> IDENTICAL |
| `tq/n07_pkg_default_unpacked_137arm` | elab | NE:endline/c0/o6 | NE:endline/c0/o6 | NE:endline/c0/o6 | law not reached (bytes equal) |  |
| `tq/n07_pkg_default_unpacked_137arm` | plain | NE:endline/c0/o6 | NE:endline/c0/o6 | NE:endline/c0/o6 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `tq/n08_pkg_default_two_nets` | elab | NE:endline/c0/o79 | NE:endline/c0/o79 | NE:endline/c0/o23 | **BREAK** NEW[2] |  |
| `tq/n08_pkg_default_two_nets` | plain | NE:endline/c0/o70 | NE:endline/c0/o70 | NE:endline/c0/o10 | **BREAK** NEW[2] | IDENTICAL -> IDENTICAL |
| `tq/n09_pkg_default_other_user` | elab | NE:endline/c0/o47 | NE:endline/c0/o47 | NE:endline/c0/o14 | **BREAK** NEW[2] |  |
| `tq/n09_pkg_default_other_user` | plain | NE:endline/c0/o45 | NE:endline/c0/o45 | NE:endline/c0/o12 | **BREAK** NEW[2] | IDENTICAL -> IDENTICAL |

#### § paramAliasBoundRefUnstored144 (`R11U144_PARAMALIASREF_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `pt/n01_iface` | elab | S1/c33/o61 | S1/c33/o61 | S1/c33/o53 | stage 1 both |  |
| `pt/n01_iface` | plain | S1/c31/o57 | S1/c31/o57 | S1/c31/o49 | stage 1 both | IDENTICAL -> IDENTICAL |
| `pt/n02_two_bounds` | elab | S1/c64/o57 | S1/c64/o57 | S1/c64/o41 | stage 1 both |  |
| `pt/n02_two_bounds` | plain | S1/c64/o53 | S1/c64/o53 | S1/c64/o37 | stage 1 both | EQUIVALENT -> EQUIVALENT |
| `pt/n03_localparam_sub` | elab | S1/c142/o50 | S1/c142/o50 | S1/c142/o42 | stage 1 both |  |
| `pt/n03_localparam_sub` | plain | S1/c142/o48 | S1/c142/o48 | S1/c142/o40 | stage 1 both | EQUIVALENT -> EQUIVALENT |
| `pt/n04_pkg_typedef_param` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `pt/n04_pkg_typedef_param` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |

#### § pkgTsForeignQualRefUnstored144 (`R11U144_PKGQUALREF_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `qb/n01_pkg_param_type` | elab | S1/c64/o27 | S1/c64/o27 | S1/c64/o24 | stage 1 both |  |
| `qb/n01_pkg_param_type` | plain | S1/c64/o27 | S1/c64/o27 | S1/c64/o24 | stage 1 both | IDENTICAL -> IDENTICAL |
| `qb/n02_pkg_func_ret` | elab | S1/c64/o42 | S1/c64/o42 | S1/c64/o42 | law not reached (bytes equal) |  |
| `qb/n02_pkg_func_ret` | plain | S1/c64/o42 | S1/c64/o42 | S1/c64/o42 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `qb/n03_pkg_var` | elab | S1/c76/o40 | S1/c76/o40 | S1/c76/o40 | law not reached (bytes equal) |  |
| `qb/n03_pkg_var` | plain | S1/c76/o40 | S1/c76/o40 | S1/c76/o40 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `qb/n04_two_dims_member` | elab | NE:fullname/c0/o6 | NE:fullname/c0/o6 | EQ/c0/o0 | law converts |  |
| `qb/n04_two_dims_member` | plain | NE:fullname/c0/o6 | NE:fullname/c0/o6 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `qb/n05_pkg_class_prop` | elab | NE:fullname/c0/o3 | NE:fullname/c0/o3 | EQ/c0/o0 | law converts |  |
| `qb/n05_pkg_class_prop` | plain | NE:fullname/c0/o3 | NE:fullname/c0/o3 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § classMethodQualSpan144 (`R11U144_METHQUALSPAN_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `vf/n01_local_static_func` | elab | NE:endline/c0/o2 | NE:endline/c0/o2 | EQ/c0/o0 | law converts |  |
| `vf/n01_local_static_func` | plain | NE:endline/c0/o2 | NE:endline/c0/o2 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `vf/n02_protected_virtual_func` | elab | NE:col/c0/o4 | NE:col/c0/o4 | EQ/c0/o0 | law converts |  |
| `vf/n02_protected_virtual_func` | plain | NE:col/c0/o2 | NE:col/c0/o2 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `vf/n03_extern_virtual_task` | elab | NE:line/c0/o18 | NE:line/c0/o18 | NE:line/c0/o18 | law not reached (bytes equal) |  |
| `vf/n03_extern_virtual_task` | plain | NE:line/c0/o16 | NE:line/c0/o16 | NE:line/c0/o16 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `vf/n04_derived_override` | elab | NE:endline/c0/o18 | NE:endline/c0/o18 | EQ/c0/o0 | law converts |  |
| `vf/n04_derived_override` | plain | NE:endline/c0/o6 | NE:endline/c0/o6 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `vf/n05_pure_then_impl` | elab | NE:endline/c0/o10 | NE:endline/c0/o10 | EQ/c0/o0 | law converts |  |
| `vf/n05_pure_then_impl` | plain | NE:endline/c0/o6 | NE:endline/c0/o6 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |

#### § methodSpanSkipsAttrs144 (`R11U144_METHATTR_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `at/n01_attr_value_static_task` | elab | NE:endline/c0/o2 | NE:col/c0/o2 | EQ/c0/o0 | law converts |  |
| `at/n01_attr_value_static_task` | plain | NE:endline/c0/o2 | NE:col/c0/o2 | EQ/c0/o0 | law converts | IDENTICAL -> IDENTICAL |
| `at/n02_attr_extern` | elab | NE:line/c0/o10 | NE:line/c0/o10 | NE:line/c0/o10 | law not reached (bytes equal) |  |
| `at/n02_attr_extern` | plain | NE:line/c0/o8 | NE:line/c0/o8 | NE:line/c0/o8 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `at/n03_attr_protected_func` | elab | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `at/n03_attr_protected_func` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |

#### § defGenLhsHpBaseAnchor144 (`R11U144_DEFGENHP_OFF`)

| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |
|---|---|---|---|---|---|---|
| `hg/n01_param_index` | elab | NE:endcol/c0/o108 | NE:endcol/c0/o108 | NE:fullname/c0/o96 | toward golden |  |
| `hg/n01_param_index` | plain | NE:endcol/c0/o22 | NE:endcol/c0/o22 | NE:fullname/c0/o10 | toward golden | IDENTICAL -> IDENTICAL |
| `hg/n02_genif_in_loop` | elab | NE:endcol/c0/o62 | NE:endcol/c0/o46 | EQ/c0/o12 | law converts |  |
| `hg/n02_genif_in_loop` | plain | NE:endcol/c0/o46 | NE:endcol/c0/o46 | NE:fullname/c0/o12 | toward golden | IDENTICAL -> IDENTICAL |
| `hg/n03_deep_member` | elab | NE:fullname/c0/o16 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) |  |
| `hg/n03_deep_member` | plain | EQ/c0/o0 | EQ/c0/o0 | EQ/c0/o0 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `hg/n04_nested_loops` | elab | NE:fullname/c0/o112 | EQ/c0/o48 | EQ/c0/o48 | law not reached (bytes equal) |  |
| `hg/n04_nested_loops` | plain | NE:fullname/c0/o48 | NE:fullname/c0/o48 | NE:fullname/c0/o48 | law not reached (bytes equal) | IDENTICAL -> IDENTICAL |
| `hg/n05_localparam_index` | elab | NE:endcol/c0/o122 | NE:endcol/c0/o106 | EQ/c0/o82 | law converts |  |
| `hg/n05_localparam_index` | plain | NE:endcol/c0/o104 | NE:endcol/c0/o104 | NE:fullname/c0/o82 | toward golden | IDENTICAL -> IDENTICAL |
| `hg/n06_unpacked_net_array` | elab | NE:endcol/c0/o58 | NE:endcol/c0/o34 | EQ/c0/o12 | law converts |  |
| `hg/n06_unpacked_net_array` | plain | NE:endcol/c0/o34 | NE:endcol/c0/o34 | NE:fullname/c0/o12 | toward golden | IDENTICAL -> IDENTICAL |
