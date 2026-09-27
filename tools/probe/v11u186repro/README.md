# v11u186: adversarial verification of pass 186 (pair B, r11u186)

Verdict ACCEPT, no fix needed. The report below is the verifier's final text; cases/ holds its 38 fresh cases (each with its § law first line) and drivers/ its scripts (they were written against the scratch paths /tmp/wt_v11u186 and /tmp/v11u186_bin and need path edits to run from the tree; the packaging was done at integration).

**Verdict: ACCEPT, no fix needed.** The implementer's headline numbers reproduce bit for bit, and none of my 38 new cases found a spot where pristine matched golden and the patch does not. `/tmp/r11u186.patch` (md5 `90a34e2d…`) ships as it is, so there is no `/tmp/r11u186.verified.patch`.

## What I rebuilt and reran
- **Builds:** two fresh worktrees at a3a62624, `/tmp/wt_v11u186pris` and `/tmp/wt_v11u186` (the patch applies clean). Both built with `-j 2`. Pristine md5 is `11406ca1…`, as the brief requires; patched is `2d409958…`, the same as the implementer's final binary. Both are frozen `chmod 555` in `/tmp/v11u186_bin`, with `uhdm-strictcmp` `5d4617d0`.
- **Binary audit:** every `cmds.txt` of the patched sweep names `/tmp/v11u186_bin/law.bin` (3273 `slang:` lines).
- **Fence:** the four names are read from the `FENCED=` line of `canaudit.sh`. The patch and the implementer's repro directory contain none of them. My byte comparisons ran on hard-link mirrors that leave out the 8 fenced row-mode databases.

## Headline numbers
Full sweeps: `/tmp/v11u186_swN` (patched, rc=0, law index current) and `/tmp/v11u186_swP` (pristine). The pristine sweep's rc=1 comes only from "law index STALE" on the a3a62624 tree itself.

| gate | patched | pristine |
|---|---|---|
| probe | EQUAL 3022 / STRICT_NOTEQUAL 1065; regressions 0, conversions 127, changes 84 | 2895 / 1192; 0 / 0 / 0 |
| surelog | regressions 0, conversions 0, changes 12 (plus the two LowMem detail-path lines from the environment) | 0 / 0 / 0 |
| uhdm2rtlil | regressions 0, conversions 4, changes 2 | 0 / 0 / 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, 0 not excused | same; csv byte-identical to patched, every verdict matches the committed csv |

**Conversions, loudly (fresh rows; `results/` untouched):**
- `ParameterFromPkgInNestedModule,default|testflags,CMP_EQUAL,,,equal`
- `ParameterFromPkgOnParameterPortList,default|testflags,CMP_EQUAL,,,equal`
- Both read `IDENTICAL,NO_GATES,NO_GATES,0,0,,` downstream.

**Other targeted rows:**
- `jeras_union` d/t goes `fullname(75)` → `file(60)`; its downstream row stays `IDENTICAL`.
- ArrayMethodIterator and ApbSlave cells are unchanged. They wait for the sister's `law_exprstmt.patch`, as the implementer reported.

**No strict cell got worse.** For every changed corpus row the new first differing record is the old second record or later (for example Rggen goes from #2063 to #2931 and `endcol(634)` → `endcol(144)`; MiniAmiq from #770 to #899). Of the 84 probe changes:
- 81 move their first record later.
- 3 keep the same record index with a smaller count (`g143_c_index` 7→3, `t32g_t` 15→14, `v16_oobctor` `col(9)` → `col(5)`).
- None moves earlier.

**UVM order-blind distance matches the implementer exactly:** MiniAmiq 22,792, SeqDriver 17,774 / 17,776, SimpleUVM 5,913, Scoreboard 4,688, BuildUVMPkg 3,084, ApbSlave 4, SVSwitch 102.

**Byte movers (byteverify, SELFCHECK 2559/2560):**
- Corpus: 36 of 2560, and all 36 appear in the implementer's frozen `predicted_movers_final.tsv`.
- Probe: 253 of 4087, all predicted. Both binaries were run from one tree so the paths match.

**The downstream Yosys outputs did not change** for the downstream movers (jeras_union, both ParameterFromPkg rows, rp32_r5p_alu/bru/mdu/wbu).

**Canaries:**
- `canaries.sh`: surelog ok=43 changed=9, exactly the named UVM and SVSwitch rows; uhdm2rtlil ok=16 changed=0.
- Both `ctcan2.sh` runs pass (`EXPECT_UNKNOWN` 1 and 6).

**Whole-pass switch** (`R11U186_OFF=1 R11U183_OFF=1`):
- Probe: 0 of 4087 databases differ from pristine, and the csv is identical.
- Corpora: 4 of 2560 differ (MiniAmiq and SeqDriver, both modes). Each is only the known 4-line UINT/vpiDecompile coin.
- My 35 break cases: all pristine bytes.

**Determinism (§ lawSCopyIdOrder186), three concurrent runs each:**

| row-mode | pristine | patched |
|---|---|---|
| Earlgrey_0_1 default | 2 hashes (`657dd42f` ×2, `529b2a71`) | 1 hash (`d8c6c5f6`, 6 of 6) |
| Earlgrey_0_1 testflags | not rerun | 1 hash (`982f47f6`, 3 of 3) |
| BuildUVMPkg default | 1 hash | 1 hash |
| MiniAmiq, SeqDriver default | 3 hashes each | 3 hashes each; every pair differs only by the 4-line coin |

**Switches.** On my cases each switch moves only its own law's cases. `R11U186_LAWSSORT_OFF`, `ASSOCPKG_OFF`, `TPGATE_OFF` and `TPDEFER_OFF` move none. `R11U183_FEIDX_OFF` leaves the bytes of all 17 probe cases where that law fires unchanged, so their conversions come from § classPropElemClassTsAtType183.

## Attempts to break the laws
38 cases in `/tmp/v11u186_cases/{A,D,G,H,I,K,P,Q,R,U,W}/x*`, each with its `// § law` first line. Each was judged by uhdm-cmp, uhdm-strictcmp and the order-blind dump distance; the separator, parameter, `$root`, import and interface-array cases also ran downstream.

- **Converted to EQUAL:**
  - D/x01, D/x02 (separators)
  - P/x01, x02, x07, x08: two instances, two specializations, four instances of two modules, a bit-select and a generate scope
  - R/x02, U/x03, W/x01 (header imports), W/x02 (three packages, one without typedefs, a modport)
- **Judge-unequal on both binaries, all closer to golden:** A/x02 28→16, G/x01 127→97, K/x01 420→352, I/x01 359→327, P/x09 84→26, P/x10 (package in an included header) 64→12, H/x03 44→28, U/x01, U/x02, U/x04 (element class written through a macro, located correctly).
- **Same head on both, or bytes unchanged:** A/x01, A/x03, P/x05, P/x06, Q/x01, Q/x02, W/x04, W/x05 (both abstain correctly).
- **W/x03 goes `fullname(5)` → `fullname(7)`, and that is allowed.** Pristine's walk diverged at #37 on the name order. The patch fixes the order, so the walk now runs through and meets a pre-existing wrong fullname at every reference: the interface re-scoped alias ref `work@bus_if.p2::e_t`, ours `p2::p2::e_t`, the same as pristine.
- **W/x06 moves only in order**, and the new interface listing order a_t, m_t, z_t matches golden.
- **Downstream:** no case moved away from IDENTICAL. D/x01 and D/x05 went DIVERGENT → EQUIVALENT, and P/x07 went EQUIVALENT → IDENTICAL.
- **P/x04 is the one case whose order-blind distance grew (238 → 273).** It is judge-unequal on both binaries with the same kind of head, and I attributed the change to § pkgParamElabCaSharesDefFold183 sharing the definition constant. The clean single-parameter versions of the same shape (P/x05 signed, P/x06 struct) keep pristine's head, and P/x04's downstream verdict stays IDENTICAL. I read it as a mixed struct-parameter case, not a break.

## Findings, ranked
1. **Surelog separator defects we should not follow (report only; pristine is not right here either):**
   - an enum value `-1_0` becomes −1 in golden (D/x01 stays EQUIVALENT downstream);
   - a wide if-generate condition `P < 100_000_000_000_000_000_000` elaborates the else branch (D/x04, DIVERGENT on both binaries);
   - a generate step `1_0` (D/x06, DIVERGENT on both; the implementer's d06).
2. **A new residue on this ground:** an unpacked size-form dimension `logic [3:0] m [1_6]` keeps the decompile `1_6` in its subOp operand (D/x03, the next head after § boundLitUnderscoreDropped186). It is built by one of the size-form `INT:1` subOp builders in TypeEmit/ModuleEmit; I did not pin which.
3. **§ macroPathTokOneBuffer186 holds back a partial gain.** With `R11U186_PATHBUF_OFF`, Q/x01 reads `fullname(1)` against `fullname(2)`, and Q/x02 reads `endcol(2)` against `endline(2)`. Neither mapping matches golden, which lays out macro-argument tokens at their expanded-line columns. This is the implementer's residue R4.
4. **The interface alias-of-typedef ref's fullname** (`work@<iface>.<pkg>::<alias>`; W/x03) is a pre-existing module/type-ground residue.
5. **§ typeParamUseSharesOwnTs183 is dead by default**: § typeParamDefersToTpUse186 makes it fire only under `R11U180_TPUSE_OFF`.
6. **Housekeeping:** the patch's drivers hard-code `/tmp/wt_r11u186` and `/tmp/r11u186_bin` (`drivers/env.sh`, `det.sh`, `case.sh`), so they will not run elsewhere without edits.

The implementer's residues R1–R7 and the report-only rows stand as reported.

Scratch is in `/tmp/v11u186_*`: the sweeps `swN`, `swP` and `swO` (switches off), the probe runs `prN`, `prP` and `prO`, the case grid `g1`, and the determinism runs under `det`. The drivers are `/tmp/v11u186_case.py`, `/tmp/v11u186_ds.py`, `/tmp/v11u186_det.sh`, `/tmp/v11u186_obd.py` and `/tmp/v11u186_uvmdist.sh`.