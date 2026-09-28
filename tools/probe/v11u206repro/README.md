# v11u206: adversarial verification of r11u206 (the module/type ground, pair B) — packaged by the integrator from the verifier's scratch (cases from /tmp/v11u206_cases, drivers from /tmp/v11u206_drv); the report below is the verifier's final text

Base 3668bf30, pass 206 verified at its base; verdict CONFIRMED, no fix.

**Verdict: CONFIRMED, no fix needed.** I found no case where pristine was right and the patch made it wrong on legal SV. I did not ship `/tmp/r11u206.verified.patch`. `/tmp/r11u206.patch` is accepted as delivered against 3668bf30. The one thing to act on: r11u205dec landed at HEAD 032fbb89 after this pass started, and its law covers the same arb_idx_cast cluster (point 1 below).

**Headline numbers, all reproduced.** Both binaries were built by me, frozen in `/tmp/v11u206_bin`, and every `cmds.txt` audited.

| Check | Result |
|---|---|
| Pristine build | md5 d27bb984d49f6d31eb76cd00e98e517f, the main tree's binary |
| Patch on a fresh 3668bf30 | applies clean, builds to the law md5 b81dbfaca6fdd916dbc1aa17af48e42e |
| `uhdm-strictcmp` | fa6e4f42f252ae0ab69d9845003e71c5 |
| `cmds.txt` audit | 3273 of 3273 per sweep name that sweep's own binary; the other 50 have no slang line |
| Probe stage | EQUAL 3363 / STRICT_NOTEQUAL 724, 0/0/0; `probe.csv` byte-identical to `results/golden_probe.csv` |
| Surelog stage | 0/0/0 (463+17 default, 459+15 testflags) |
| uhdm2rtlil stage | regressions=0 conversions=2 changes=0 |
| Downstream | 803 / 66 / 2 / 0, `downstream.csv` byte-identical pristine vs law |
| Canaries | surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 PASS for both |

- **The two conversions (fresh rows, `results/` untouched):**
  - `arb_idx_cast,default,CMP_EQUAL,,,equal` (was `differ:endline(2)`)
  - `arb_idx_cast,testflags,CMP_EQUAL,,,equal` (was `differ:endline(2)`)
  - Downstream stays `arb_idx_cast,IDENTICAL,OK,OK,11,11,,`.
- **Strict column:** diffing the whole csv pristine vs law, only the two arb_idx_cast rows change; the LowMem rows differ by workdir path only. No row-mode's strict column gets worse.
- **Byteverify** (SELFCHECK, mirrors without the fenced tests, 8 fenced databases left out): 6 of 2560 databases move.
  - arb_idx_cast d/t is the real mover. Away census: distance 2 → 0, lost=0, gained=2.
  - MiniAmiq d/t, SimpleUVM d and Scoreboard d are the known UVM coin. Their sorted dumps differ only in the header line (0 content lines).
  - The mover set differs from the implementer's 5, which is expected for a coin.
- **Probe databases** (dumps compared with paths normalised): 3 move, the same 3 r11u113 cases the implementer predicted.
- **Determinism** (three concurrent runs per binary): Earlgrey_0_1 gives one hash per mode, the same in both binaries and the same as the implementer's. Every UVM hash the law binary produced is one the pristine binary also produced. BuildUVMPkg drew a22b6ee6955d in all 12 runs, so V2 did not occur. The laws add no coin.
- **UVM order-blind distance**, identical in both sweeps: MiniAmiq 6634, SeqDriver 5194, SimpleUVM 2074, Scoreboard 1526, BuildUVMPkg 776 per mode.
- **`R11U206_OFF=1`** gives the pristine bytes on all 87 fresh cases. Each switch alone, over 115 cases (mine plus the implementer's), moves only cases where its own law traced: 0 untraced.

**Breaking attempts.** I wrote 87 fresh cases in `/tmp/v11u206_cases`, each first line `// § <law>`. Each was judged by uhdm-cmp, by uhdm-strictcmp field by field, and by the downstream `one()`.
- **Grid:** none leaves EQUAL, and no strict cell moves away from golden.
- **Improvements:**
  - A/a02, a03, a06, a07, a10 (an `always_ff` cast), B/b01, b02, b04, b06, b07, C/c01, c02, c03, c05, c08 (CRLF), D/d02, d06, d12 and E/e01, e03, e04, e06–e10, e12, e13, e17–e20 turn EQUAL.
  - D/d03 and D/d05 improve from stage 1.
  - A/a04 goes `endline(7)` → `line(3)`: its first four records are fixed and the remaining one is pre-existing.
  - C/c09 (declaration in a macro body) goes `endline(7)` → `endcol(7)`, and C/c10 (declaration in an included header) keeps `file(7)` with two fewer wrong fields. Both are closer to golden.
- **Downstream on the grid:** 18 cases go EQUIVALENT → IDENTICAL (the generate-scope class variables and C/c04). None leaves IDENTICAL. A/a12 is DIVERGENT in both binaries with identical bytes, so it is pre-existing.
- **Wide byte controls** over all 12441 `tools/probe` case dirs (fenced names refused): 63 move.
  - 62 carry a firing of a law of this pass. The one without is `r11u196repro/cases/V191/qr01`, which I confirmed below.
  - No law fired on a case whose bytes did not move.
  - Judged: 17 convert, 26 EQUAL in both, and 20 fail uhdm-cmp in both binaries with the same first differing object each time.
  - Downstream: 11 go EQUIVALENT → IDENTICAL. The 3 DIVERGENT in both (v11u121 branches a13, a14, a16) have byte-identical slang-lane netlists before and after.

**Findings for the orchestrator:**
1. **r11u205dec landed at 032fbb89** (2026-09-28 11:00, after the implementer began). Its `law_typeemit.patch` law `tpDefaultUseCastAndArrayElem205` targets the same N0090 cluster as `tpCastUseBindsDefDefault206` and `tpArrayElemBindsDefDefault206`.
   - The two conflict textually in `src/UhdmExporter.cpp`, inside `tpUseBindsDefDefault160`: 205's patch does not apply on top of 206's.
   - By reading the code, 205 walks only continuous assignments and `array_var` elements. 206 also reaches procedural casts (my a10 `always_ff` converts) and `array_net` elements.
   - Only one of the two should land.
   - On HEAD 032fbb89, `/tmp/r11u206.patch` applies except for `tests/LAWS.md`; regenerate it with `python3 scripts/law_index.py` after applying.
2. **R1 confirmed.** On qr01 the pristine binary and the law binary with `R11U206_OFF=1` give dumps identical but bytes different (a `UINT:249…` value at byte offset 7227). This is the orphan from `§ queueTwinKeepsElem204v`, not caused by this pass.

**Residues, ranked** (all pre-existing, none caused by the laws):
1. **A return whose owner class sorts earlier** (D/d08 at pristine, D/d04 and D/d07 at law): golden writes a `class_var` return variable, ours a `ref_var`. The choice is the lateRv10 chain in TaskFuncEmit, whose predicates live in EmitHelpers.h (sister ground).
2. **R5 is wider than the README says.** In the definition view golden also turns a named-value specialization `c #(.W(8)) q;` (E/e05) into a statement, not only type arguments, package scope and initializers.
3. **The typedef-end writer inside a macro body or an included header** (C/c09, C/c10): ours gives end column 0 where golden has the expanded column, and golden moves the file to the header. This is pass 202's location model.
4. **Specialization-qualified or foreign owners.** `K#(2)::q_t` (D/d01) and `z_pkg::K::q_t` (D/d11) are not reached by the class-scope return law. A class-scoped enum typedef return `K::e_t` (D/d13, D/d14) gives ours a `bit_typespec`.
5. **E/e14:** a generate-scope unpacked class array's element is a `logic_var` (emitArrayVar).
6. **A/a12:** a module-scope function with type-parameter casts is DIVERGENT downstream at the base.
7. The implementer's R2–R4, R6, R7 and the sister-ground faces stand as reported.

Evidence is in `/tmp/v11u206_grid_P.txt`, `/tmp/v11u206_grid_L.txt`, `/tmp/v11u206_grid2.txt`, `/tmp/v11u206_ds_P.txt`, `/tmp/v11u206_ds_L.txt`, `/tmp/v11u206_ds2P.txt`, `/tmp/v11u206_ds2L.txt`, `/tmp/v11u206_bytectl/last.txt`, `/tmp/v11u206_bcj.txt`, `/tmp/v11u206_dsb_P.txt`, `/tmp/v11u206_dsb_L.txt`, `/tmp/v11u206_det.txt` and `/tmp/v11u206_away_grid.txt`. The sweeps are `/tmp/v11u206_sP` and `/tmp/v11u206_sL`, the drivers `/tmp/v11u206_drv/`. The worktrees `/tmp/wt_v11u206` and `/tmp/wt_v11u206pris` are kept. The main tree is clean, no fenced test was run, read or decoded, and no git stash was used.