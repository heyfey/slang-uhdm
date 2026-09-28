# v11u188: adversarial verification of r11u188 (pair B, the module/type ground) — every headline reproduced, one break found and refined (§ tpFormalMacroAtExpansion188v)

Base `c168c209` (branch matrix-1.87). The implementer's patch `r11u188` applies cleanly to a fresh `c168c209` worktree and
builds the implementer's `law.bin` byte for byte. This pass adds one refinement, a switch, a census trace and this
directory. Production files touched by the refinement: `src/TypeEmit.cpp` only (the ground's file: no sister file,
`results/`, `tests/probe/`, `scripts/` or `third_party/` is edited). `tests/LAWS.md` is regenerated
(`python3 scripts/law_index.py`).

**Verdict: ACCEPT WITH FIX.** Every headline number of r11u188 reproduces bit for bit. One break was found with fresh
cases: § tpFormalIncludeOrder188 placed a formal written inside a macro body at the macro's `define`. The shared
type-parameter object then moved away from golden, where pristine had it right. It is refined behind
`R11V188_MACROEXP_OFF`. The refined binary keeps every gate: probe, corpus statuses, the downstream bytes and every
strict column.

**The fence.** The four slang-fenced tests are named only through the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh`. Every driver here sources `drivers/env.sh`, which fails closed without four
names. The firing census ran with `--filter "$NEGFENCE"`, which leaves the four rows out. The byte comparison ran on
hard-link mirrors without the 8 fenced row-mode databases (`fenced_skipped=8`). No fenced test was run, read or
decoded outside the gate sweeps, and gdb was not used.

## 1. Binaries (frozen `chmod 555` in `$V188_BIN` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `31cca146e477f929354b62ba79ce40b6` | `c168c209`, system deps, `-j 2`; the same as the main tree's build at the base |
| `law.bin` | `947db135b19754654eb4b12254f18eb0` | `c168c209` plus r11u188's patch; the same as the implementer's `law.bin` |
| `v2.bin` | `9a12cf1cf3b4b482adbb893728120c4e` | `law.bin` plus this pass's refinement and census trace (the verified patch) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | `c168c209`'s `tools/uhdm-strictcmp` |

Every corpus `cmds.txt` names its sweep's binary: swP 3273 of 3273 `pris.bin`, swL 3273 of 3273 `law.bin`, swV 3273 of
3273 `v2.bin`. Workdirs are `/tmp/v11u188_sw{P,L,V}` (same length). The probe byte comparison ran the pristine probe
stage from the law worktree (`/tmp/v11u188_swQ`), because probe databases embed the case's absolute path.

## 2. Reproduction of r11u188's numbers (law sweep swL against pristine sweep swP)

| claim | measured |
|---|---|
| pristine gates at the base | probe EQUAL 3026 / STRICT_NOTEQUAL 1061; surelog 456+24 d, 452+22 t; uhdm2rtlil 789+14 both; downstream IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 |
| probe | regressions=0 conversions=98 changes=23; EQUAL 3124 / STRICT_NOTEQUAL 963 |
| surelog | regressions=0 conversions=4 changes=2: AssertDelayError d/t and AssertTempError d/t `CMP_EQUAL,,,equal`; Earlgrey_0_1 d/t `col(102) -> col(98)` |
| uhdm2rtlil | 0 / 0 / 0 |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2; `downstream.csv` byte-identical to swP's |
| corpus byte movers | 15 / 2560 (SELFCHECK 2559 / 2560), the implementer's 15 by name |
| probe byte movers | 121 / 4087, the implementer's 121 by name |
| canaries | surelog ok=50 changed=2 (Earlgrey_0_1 d/t), uhdm2rtlil ok=16 changed=0; both `ctcan2.sh` PASS (swP: 52/0 and 16/0) |
| whole-pass switch | `R11U188_OFF=1`: 4260 / 4260 case databases byte-identical to `pris.bin` (all of `tests/probe`, r11u188's 86 cells, this pass's cells) |
| determinism | Earlgrey_0_1 default `94a33ef3`, testflags `f641f7fb`: one hash over 3 concurrent runs, the implementer's hashes |
| InterfaceModPort by hand | both modes with `--sverilog`: `STRICT_EQUAL 790 objects`, uhdm-cmp 0 lines; without the flag `STRICT_NOTEQUAL endcol` |

**Strict columns, change by change.**
- **Probe.** All 121 byte movers were compared order-blind with the canonical strict records (depth dropped, multisets
  against golden). Every one reads 0 records away from golden that pristine did not already hold, and no distance grows
  ([evidence/probe_movers_orderblind.tsv](evidence/probe_movers_orderblind.tsv)). So the 23 changes are unmaskings or
  strict improvements.
- **Earlgrey_0_1.** 8 (default) and 4 (testflags) records fixed, 0 new.
- **AssertDelayError and AssertTempError.** Distance goes to 0.
- **The five UVM rows.** 339-358 records fixed each. The only new record is the known one-constant `UINT` /
  `vpiDecompile` coin ([evidence/corpus_movers_orderblind_P_V.txt](evidence/corpus_movers_orderblind_P_V.txt)).

**Corrections to r11u188's write-up (no code change).**
1. Its README said 66 of the 98 probe conversions are map N0039 cases. The count against
   `tools/probe/r11u189map/probe_clusters.csv` is **93** (the report's figure). The README line is corrected.
2. "Each switch alone moves only its own law's cases" holds for five switches. `R11U188_TPKEYWORD_OFF` also drops
   § tpOwnTsAtHeaderDefault188: its code requires both switches. So that switch moves 4 probe cases that fire only the
   header-default law (r10svs6repro b4_qual, r10uvm12repro t6_t, r10uvm97repro g97_a1_selftd and g97_a4_plainclass).
   `R11U188_TPDEFSYN_OFF` alone drops only its own law.
3. The claim "cells V/v01, v07, v08 equal on a `.v` root without `-sverilog`" is right, and the verifier checked the
   flag forms behind it ([evidence/svmode_Vcells_surelog_flags.txt](evidence/svmode_Vcells_surelog_flags.txt)):
   - Surelog's `-sv dut.v` (the file form, which the case driver passes) keeps the Verilog lexer.
   - `-sverilog dut.v` and a trailing `dut.v -sv` switch to SystemVerilog.
   - On those, ours with `--sverilog` reads STRICT_EQUAL on v01, v03, v05 and v07, where v03 and v05 differ in the
     Verilog form.

   So the harness half of § svModeAllFiles188 must translate `-sverilog`, and `-sv` only when a flag or nothing follows
   it (`CommandLineParser.cpp`: `-sv <file>` marks one file, and that file form keeps the Verilog lexer as measured).

## 3. The break and its refinement

### 3.1 The break: § tpFormalIncludeOrder188 on a macro-generated method

§ tpFormalIncludeOrder188 orders formal writers by their include chain. It maps a macro location through
`getFullyOriginalLoc`, which for a token of a macro BODY is the `define`. A `define always precedes its use, so a
method generated by a macro could never be the last formal writer. Before the law, § 180 did not relocate a
keyword-default parameter's object at all, and the macro formal's own typespec sat at golden's location. Under
§ classTpKeywordTsAtDefault188 the object now moves, so the earlier plain formal wins and overwrites that correct
record.

    cases/M/m01 (`define DECL_SET(NM) function void NM(T v); ...` expanded after `function void first(T a)`)
    pristine  line(3)   law  line(4)   refined  STRICT_EQUAL
    #20 line
      A: 6 int_typespec  dut.sv 7:26-7:27      (golden: the expansion's `T v`)
      B: 6 int_typespec  dut.sv 6:25-6:26      (law: the plain formal before it; pristine read 7:26-7:27)

The same break shows on four more cells:
- m04: the `define` sits in an included header.
- m12: nested macros.
- m13: a macro before and after a plain formal.
- m14: the expansion sits in an included file.

Each is judge-equal, and the law grows its count (line or file 3/4 -> 4/5): a pristine-right record moves away from
golden. m10 (a pasted `set_``NM` name) keeps its count but moves one record the same way.

### 3.2 § tpFormalMacroAtExpansion188v (`R11V188_MACROEXP_OFF`) — TypeEmit.cpp, `inclChain188`

**Law.** A formal written inside a macro sits in the preprocessed stream at the macro's EXPANSION. The include chain of
a macro-located formal therefore starts from `getFullyExpandedLoc`.
- Formals from one expansion tie, and the later one visited wins, as within a buffer.
- A macro-ARGUMENT token (`DECL_SET(second, T)`, m03 and m11) orders the same either way.
- The class-handle branch of § classTpFormalMovesTs180 goes through the same chain. m06 (a class-handle default, a
  pristine § 180 residue: the first buffer seen won) converts too.

**Census trace.** `tpFormalMacroAtExpansion188v <T> <formal>` is written for every macro-located formal the chain
decides (`R11U188_TRACE`).

**Grid** (`cases/M`, [evidence/grid_P_L_V.txt](evidence/grid_P_L_V.txt); pristine -> law -> refined):

| cell | shape | pristine | law | refined |
|---|---|---|---|---|
| m01 | macro body after a plain formal | line(3) | line(4) | **equal** |
| m04 | the same, `define` in an included header | line(3) | line(4) | **equal** |
| m06 | the same on a class-handle default | line(4) | line(4) | **equal** |
| m10 | pasted method name | line(4) | line(4) | col(4): lines right; the pasted-token column is residue R4 |
| m12 | nested macros | line(4) | line(5) | **equal** |
| m13 | macro, plain, macro | line(4) | line(5) | **equal** |
| m14 | expansion inside an included file | file(3) | file(4) | **equal** |
| m02 m03 m05 m07 m08 m09 m11 | controls (macro first; argument token; plain last; header included in two packages; include between formals; inactive `ifdef`; multi-line argument) | differ | equal | equal |

The downstream verdict on all 14 M cells is IDENTICAL under both `pris.bin` and `v2.bin`.

## 4. Gates of the verified binary (sweep swV, `v2.bin`, from the patched worktree)

| gate | result |
|---|---|
| (1) build | `v2.bin` `9a12cf1c…`; the verified patch applied to a fresh `c168c209` builds it byte for byte |
| (2) probe | regressions=0 conversions=98 changes=23; `probe.csv` byte-identical to swL's (EQUAL 3124 / STRICT_NOTEQUAL 963) |
| (3) corpora | surelog regressions=0 conversions=4 changes=2, the same rows as swL; uhdm2rtlil 0/0/0. `uhdm2rtlil.csv` identical to swL's; `surelog.csv` identical but for the LowMemLib/LowMemPkg detail text, which embeds the workdir |
| (4) downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2, not excused 0; `downstream.csv` byte-identical to swP's |
| (5) uhdm-cmp | 0 lines on each of the 15 corpus movers ([evidence/uhdmcmp_corpus_movers_v2.txt](evidence/uhdmcmp_corpus_movers_v2.txt)) |
| (6) byteverify | v2 vs pris 15 / 2560, the same 15 as law vs pris; v2 vs law 5 / 2560 (MiniAmiq d/t, SeqDriver d, SimpleUVM d, Scoreboard d). Every one is a known coin: 4 lines of `UINT` / `vpiDecompile`, or Scoreboard's 92-line svunit order with 0 lines sorted |
| canaries | surelog ok=50 changed=2 (Earlgrey_0_1 d/t), uhdm2rtlil ok=16 changed=0, both `ctcan2.sh` PASS ([evidence/canaries.txt](evidence/canaries.txt)) |
| switches | [evidence/switch_matrix_summary.txt](evidence/switch_matrix_summary.txt), movers in [evidence/switch_matrix_movers.txt](evidence/switch_matrix_movers.txt) (4265 case databases x 12 variants) |
| determinism | [evidence/determinism_v2.txt](evidence/determinism_v2.txt), three concurrent runs per row (below) |
| UVM distance | [evidence/uvmdist_P_L_V.txt](evidence/uvmdist_P_L_V.txt): MiniAmiq 22,752 -> 22,074, SeqDriver 17,726 -> 17,048, SimpleUVM 5,881 -> 5,203, Scoreboard 4,664 -> 3,978, BuildUVMPkg 3,052 -> 2,336. v2 equals law within the one-constant coin; ApbSlave 4 and SVSwitch 102 unchanged |

Switch matrix results:
- `R11U188_OFF=1` on either binary gives pristine bytes on every case.
- `R11V188_MACROEXP_OFF=1` on `v2.bin` gives `law.bin` bytes on every case.
- The refinement moves exactly the 7 fresh cells m01, m04, m06, m10, m12, m13 and m14, and no probe case and no corpus
  row's content.

Determinism results (three concurrent runs per row):
- Earlgrey_0_1 d/t: one hash each, the same as `law.bin`'s.
- SimpleUVM and BuildUVMPkg: one hash each.
- MiniAmiq and SeqDriver: three hashes each, differing only by the 4-line coin.
- Scoreboard: two hashes, the 92-line svunit order coin, 0 lines sorted.

**Prediction before the sweep** (the firing census of `v2.bin` at `/tmp/v11u188_cen`, frozen `chmod -R a-w` before the
sweep: [evidence/census_v2_surelog.txt](evidence/census_v2_surelog.txt), `census_v2_uhdm2rtlil.txt`,
`census_v2_probe.txt`):
- § tpFormalMacroAtExpansion188v fires 217 times on each of MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t and Scoreboard d.
  It fires on no probe case and no other row. Its possible movers are those seven row-modes.
- § tpFormalIncludeOrder188's replacements go from 105 to 113 per UVM row, but the final winners are unchanged.
  Order-blind dumps of law vs v2 on those rows differ only by the coin.
- The r11u188 laws' firings match the implementer's census: AssertDelayError, AssertTempError and Earlgrey_0_1 fire
  § propAssertLastInstPath188; mriscv_bind_sva and sva_basic02 fire it with no byte change; the UVM rows and BuildUVMPkg
  fire the type-parameter laws; 121 probe cases fire.

## 5. Break attempts on r11u188's laws (fresh cells, judged by uhdm-cmp, uhdm-strictcmp and the downstream verdict)

Every cell was run under `pris.bin`, `law.bin` and `v2.bin`
([evidence/grid_P_L_V.txt](evidence/grid_P_L_V.txt)). The downstream verdicts (P and Q cells, M, H, K/kp01-kp05) are
IDENTICAL, or SLANG_REJECT on both binaries (Q/q06, H/h09), and never move
([evidence/downstream_cases_pris.txt](evidence/downstream_cases_pris.txt),
[evidence/downstream_cases_v2.txt](evidence/downstream_cases_v2.txt)).

**P** (§ propAssertLastInstPath188)
- Seven cells convert:
  - p02: generate-if above the parent.
  - p03: two definitions at two depths.
  - p04: a hierarchical `u_sub.x` and a function call in the property.
  - p05: default clocking plus cover.
  - p06: a generate block inside the checker.
  - p07: a procedural assertion beside a module one.
  - p13: a generate-for instance.
- p08 (the checker below a bound wrapper) improves `fullname(15) -> fullname(3)`, a subset. The rest is the bound
  child's display path, which is pre-existing.
- Judge-unequal at the base: p01 (a parameter override), p09 and p10 (two instances, an instance array), p11 (`assume` /
  `restrict`), p12 (a sequence). Order-blind dump distance to golden falls on every one (p01 50 -> 6, p09 42 -> 2, p10
  42 -> 2, p11 76 -> 26, p12 73 -> 45). p11's 4 lines not in golden belong to `restrict`, which Surelog does not emit.
- Also run in scratch (not shipped): interface assertions, depth-1 and depth-2 instances, a generate loop, a
  parameterized property and two tops. Interface assertion bytes are unchanged; the generate loop (r03) and the
  depth-4 chain (r06) convert.

**Q** (§ bindDisplayTargetParent188)
- q01, q03 and q05 convert: a generate-loop target, a `.*` connection, and a top target beside a deeper one.
- q02, q04 and q07 improve to a subset. Their residues are pre-existing: an expression high-conn, positional
  high-conn lines, and the walk divergence at the bound net.
- q06 (an interface target) is SLANG_REJECT on both binaries. q08 (the `bind dut: tb.u_mid.u_dut` instance-list form) is
  SURELOG_FAIL.

**K** (§ classTpKeywordTsAtDefault188)
- Thirteen cells convert: k15, kp02, kp03, kp05, kp08, kp10, kp11, kp12, kp14, kq1, kq2, kq5 and kq6. They cover
  `int unsigned`, `bit signed`, `real` statics and consts, `ref`, `output` and `inout` formals, the extends chain, three
  parameters, a `localparam type`, a `rand` property with a constraint, a virtual override and `T2 = T`.
- kp01, kp16 and kq4 improve to a subset. The residues are unpacked-array properties and fixed-size array locals
  written `T arr[4]` (R2) and a struct member written `T` (R3).
- kp20 is unchanged. It is the typedef `tt` of `T`: golden relocates that alias too (R3).
- The judge-unequal cells (kp04, kp06, kp07, kp09, kp17, kp18, kp19, kq3) all fall in dump distance. Their new lines
  are extra copies of golden's own location, with one exception: kp07's interface class. Golden relocates the interface
  class's object to the IMPLEMENTING class's last formal; ours stops at the interface class's own formal (R3).

**H** (§ tpOwnTsAtHeaderDefault188)
- d01, d02, h03, h04, h05, h06 and h08 convert: explicit specializations in either order, `int unsigned`, `logic`,
  and extends of `base #(byte)` and `base #(int)`.
- h07 and h10 improve to a subset. The rest is the specialization's own override token, which is pre-existing.
- h01, h02 and h11 are judge-unequal at the base (a typedef override, a named override, a value parameter beside the
  type parameter). They fall in distance.

**M** (§ tpFormalIncludeOrder188): section 3. The five breaks are there, and all are fixed by the refinement.

**Harness half of § svModeAllFiles188**: section 2, correction 3.

## 6. Residues, ranked

1. **R1 — InterfaceModPort d/t**: converts once `scripts/verify_golden.py` passes `--sverilog` to slang-uhdm for
   Surelog's `-sverilog` or a flag-form `-sv` (not `-sv <file>`), in both modes (the operator's decision; out of this
   ground).
2. **R2 — § classTpKeywordTsAtDefault188 on unpacked arrays.** `T arr[4]`, `T q[$]` and `T m[string]` as class
   properties, and `T la[2]` as a local, keep their element typespec at the use token, where golden reads the shared
   object (kp01: 5 records). The makeTypespec hook records only the finished declaration typespec.
3. **R3 — shapes of the shared type-parameter object outside the law.** A struct member written `T` (kq4); the typedef
   alias `typedef T tt` (kp20: golden names the relocated object `tt`); and an interface class's parameter chained
   through `implements ic #(T)`, which golden relocates to the implementing class's last formal (kp07, judge-unequal).
4. **R4 — the pasted-token column** (M/m10). A formal after a ``` `` ``` paste inside a macro body is laid out at
   7:32 in ours and 7:30 in golden. That is the macro location model, pre-existing at the base.
5. **r11u188's own residues stand as its README ranks them**: ibex_pmp's import-parameter copy; const_cast_signext's
   `ExprEval::evalFunc` argument reduction; N0039's other 63 probe cases; arb_idx_cast; rsp_gen_minimal;
   ClassTypeParam and UnitElabBlock; pass 186's residues; and the sister faces (ExprEmit / ParamEmit) at the call sites
   it names.

## 7. Files

- `cases/` (every cell's first line names its law):
  - `M/` — m01, m04, m06, m10, m12, m13 and m14 under § tpFormalMacroAtExpansion188v; m02, m03, m05, m07, m08, m09 and
    m11 under § tpFormalIncludeOrder188 as its controls.
  - `P/` — p01-p13 under § propAssertLastInstPath188.
  - `Q/` — q01-q08 under § bindDisplayTargetParent188.
  - `K/` — k15, kp01-kp20 and kq1-kq6 under § classTpKeywordTsAtDefault188.
  - `H/` — h01-h11 under § tpOwnTsAtHeaderDefault188; d01 and d02 under § classTpKeywordTsAtDefault188.

  The switch matrix ran on the scratch copies (`/tmp/v11u188_cases/<cell>`; the scratch `kp13` is `M/m01`).
- `drivers/`:
  - `env.sh`: pins, `$FENCED` (fail closed), paths from the repository, `$V188_BIN`.
  - `sweep.sh`, `case.sh`, `census.sh` with `censum.py`, `swmatrix.sh`, `ds.sh`, `bvmirror.sh`, `det.sh`.
- `evidence/`: the sweep logs (swP, swL, swV), byteverify (L vs P, V vs P, V vs L), the v2 census, the probe movers'
  order-blind check, the corpus movers' order-blind check, UVM distances, uhdm-cmp on the movers, canaries, the
  switch matrix, determinism, the grid, downstream on cases, and the `--sverilog` runs.
