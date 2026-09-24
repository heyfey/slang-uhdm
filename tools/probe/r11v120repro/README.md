# r11v120 — adversarial verification of r11u120 (base d31ae79a)

**Verdict: ACCEPT WITH FIX.** Every headline number of r11u120 reproduces bit
for bit. One law, L6 (§ filterProtected120), moved legal designs away from
golden. That happens wherever slang's translate-off matcher and Surelog's
disagree, and those shapes are absent from both corpora. This pass adds one
gated law, § fpAbstainOnMatcherSplit120v in `uhdm_main.cpp`. It returns all
five broken arms to their pristine verdicts and bytes. It does not fire on
any corpus row, any downstream row or any arm of r11u120.

The verified patch is `/tmp/r11u120.verified.patch`. It is r11u120's patch
plus that law plus this directory.

## Binaries (built here, frozen `chmod 555`, every sweep's cmds.txt audited)

| name | md5 | what |
|---|---|---|
| pristine | `3e6d2800759fb6ea476700223ab73bb0` | d31ae79a, = the main tree's build |
| law | `e0f0c780f6706df6e19e888b26240d6f` | `/tmp/r11u120.patch` applied to a fresh d31ae79a (= the implementer's claim) |
| fix | `601855b0709c09d244ca326adf191f08` | law + § fpAbstainOnMatcherSplit120v; a FRESH d31ae79a worktree with the verified patch's production diff builds this exact binary |

## Reproduction of r11u120's claims (law binary)

* **Ten rows** (`evidence/HEADS.txt`): pristine DIVERGENT 4 / EQUIVALENT 6,
  and the heads match the report (`1'1`/`1'x`, `A 8`/`16`, `rt_i` width
  4/2, the `$sub` cells, 161 lines, 34 src lines one line apart, the
  sync-init reorders). Law: eight rows IDENTICAL, func_upto and
  matching_end_labels EQUIVALENT. uhdm-cmp against the downstream-lane golden
  is 0 -> 0 everywhere except gen_scope_numports, which goes 9824 -> 0.
* **Sweeps** (`evidence/SWEEPS.txt`):
  * probe: 2833/2833.
  * surelog: 480/3 and 474/3.
  * u2r: 803/1/67 in both modes.
  * regressions=0, conversions=0, changes=0.
  * downstream: pristine 794/7/4/66, law 802 IDENTICAL / 3 EQUIVALENT / 66 SLANG_REJECT, with 0 rows leaving IDENTICAL.
* **Byte movers, law vs pristine** (`evidence/BYTEVERIFY_bv_law_*.txt`, SELFCHECK on, same path sets):
  * surelog: 23/960. That is the 18 predicted (9 rows × 2 modes) plus the UVM coin: MiniAmiq ×2 and SeqDriver ×2 are 4-line UINT/vpiDecompile flips, and Scoreboard/default is 92 ordered lines and 0 order-blind.
  * u2r: 56/1608, the implementer's 28 rows × 2.
  * downstream: 29/805, the same 28 plus ibex_controller.
* **Census** (`evidence/CENSUS_vs_MOVERS.txt`, implementer's `cen120` rebuilt, run on MY 2568 pristine databases): 96 predicted. Every non-coin mover is predicted. The 22 predicted cells that did not move are exactly the ones the report names: 20 L3 named-override cells and GenForStructParamBound ×2.
* **uhdm-cmp, all 29 downstream movers** (`evidence/CMP_DOWNSTREAM_MOVERS.txt`): 0 -> 0, except cva6_struct_param_field at 17 -> 17 and gen_scope_numports at 9824 -> 0.
* **Switches** (`evidence/SWITCHES_fix.txt`): each switch dropped alone reverts exactly the rows the report names. IFACEAGGPARENTNM, TPSHARE and the new FPSPLIT move no row. `R11U120_OFF` reverts all eight.
* **Byte controls:**
  * `R11U120_OFF=1` equals pristine bytes and rc on 281 arms, in both probe flags and downstream flags with `--filterprotected` (`evidence/OFFBYTES_281.txt`). The arms are: this grid (47), r11u120's (61), r11u118 (56), r11u119 (78) and r11v11u118 (56), with duplicates removed.
  * Laws on vs pristine: 9/190 pass-118/119 arms move, exactly r11u118's g2 m01/m04/m09 and g3 i01-i06 (`evidence/ONBYTES_190.txt`).
* **Order rows:** golden's matching_end_labels, restored and saved unchanged (idlist diff 0), gives the slang lane's RTLIL (`evidence/ORDER_and_TIMING.txt`).

## The break (grid, `grid/`, `arm.sh`)

Each arm has four readings: uhdm-cmp against the pinned v1.87 with probe
flags, pristine and law; and the downstream verdict with the pristine
harness and binary, and with the law harness and binary. Every producer
exits with rc 0, except d03, which is illegal SV: Surelog rc 4. No arm's
uhdm-cmp count moves. Tables: `evidence/GRID_law_e0f0c780.txt` and
`evidence/GRID_fix_601855b0.txt`.

| family | arms | pristine -> law (verdicts) | law regressions |
|---|---|---|---|
| M (L1: gen-if/else and case-generate with DIFFERENT literals per branch, net-decl-assign before, `'1` over a param width, gen-for, hex / x / negative) | 6 | DIVERGENT 4 -> IDENTICAL 4, 2 IDENTICAL stay | 0 |
| T (L3/L4: named override in gen-for / gen-if / nested hierarchy / escaped instance name, type param over an overridden type param, value-dependent type param, ordered + named mix, the row's shape two levels deep) | 8 | EQUIVALENT -> IDENTICAL on t03, t08; t05 and t07 stay EQUIVALENT; the rest stay IDENTICAL | 0 |
| D (L5: typedef chain, signed vector, `int` (illegal), two instances with different W, non-ANSI ports, ordered type override, header localparam type, top ports) | 8 | EQUIVALENT -> IDENTICAL on d01, d02, d04, d07 | 0 (d05, the non-ANSI port road, is not covered by L5: residue V3) |
| I (L2/L2b: named modport with two fields, a generic interface port, an unpacked-array pattern param, scalar + aggregate) | 4 | i01 DIVERGENT -> IDENTICAL | 0 (i02 is NE at base, 11 lines) |
| F (L6/L7: translate_off / translate_on placement × branch × macro × include × header, plus the MATCHER boundary) | 21 | 14 EQUIVALENT -> IDENTICAL | **5** |

**The five regressions (law, pristine -> law):**

| arm | shape | pristine | law |
|---|---|---|---|
| x01 | `// synopsys translate_off  sim only` (trailing words) | EQUIVALENT | STATUS_DIFF |
| x02 | `/* synopsys translate_off */` .. `/* synopsys translate_on */` | IDENTICAL | STATUS_DIFF |
| x03 | `// pragma translate_off, begin sim` | EQUIVALENT | STATUS_DIFF |
| x04 | `// synopsys translate_off` closed by `// pragma translate_on` | EQUIVALENT | SLANG_REJECT |
| x05 | translate_off inside an inactive `` `ifndef SYNTHESIS ``, translate_on after the `` `endif `` | EQUIVALENT | SLANG_REJECT |

**Decode.**
* **slang** (`Lexer::tryApplyCommentHandler` / `scanDisabledRegion`):
  * Opens a region on `//` OR `/*`, followed by `<prefix> translate_off`, with any trailing text.
  * Closes it only at the SAME prefix's `translate_on`, again as `//` or `/*` and with any trailing text.
  * Scans RAW text, straight through `` `endif `` and `` `define ``.
* **Surelog** (`SV3_1aPpTreeShapeListener::enterComment`):
  * Takes one-line comments only, `regex_match` `//\s*<prefix>\s+translate_(off|on)\s*`, with no trailing text.
  * Closes at ANY prefix's translate_on.
  * Keeps executing `define/include/ifdef inside the region; only the text is filtered.

**Fix, § fpAbstainOnMatcherSplit120v** (`uhdm_main.cpp`, switch `R11V120_FPSPLIT_OFF`):
* After the parse, every translate-off region slang made (a DisabledText trivia that begins with slang's opener for a registered prefix) is checked against Surelog's reading:
  * the opening line regex_matches;
  * the closing comment is one line, regex_matches, and ends the region;
  * no other prefix's translate_on appears inside;
  * no `` `define ``, `` `undef `` or `` `include `` appears inside;
  * the conditionals inside are balanced (pulp common_cells' `` `ifndef VERILATOR `` .. `` `endif `` inside regions is common in cva6_equiv).
* On any disagreement the sources are re-parsed without the three handlers and L7 stands down, which gives the pristine reading.
* **Measured:**
  * x01-x05 and x20 (`` `define `` inside a region) return to their pristine verdicts with **byte-identical pristine databases**.
  * x06-x19 and x21 keep L6/L7's bytes. x19 is a balanced ifdef inside a region, and x21 is an inactive region with a balanced inner ifdef and a nested other-prefix translate_off.
  * The fix does not fire anywhere in the corpora: fix vs law has 0/1608 u2r movers, 0/805 downstream movers, and 4/960 surelog movers, which are the MiniAmiq/SeqDriver coin, each a 4-line UINT/vpiDecompile flip.

## Gates, fix binary (`evidence/SWEEPS.txt`, `evidence/CANARIES.txt`)

* probe EQUAL=2833 (of 2833)
* surelog 480/3 and 474/3; u2r 803/1/67 in both modes; regressions=0, conversions=0, changes=0
* downstream: EQUIVALENT=3, IDENTICAL=802, SLANG_REJECT=66; not identical and not excused=0; the eight targeted rows are IDENTICAL; 0 rows leave IDENTICAL
* canaries: canaries.sh ok=41/changed=11 and ok=12/changed=4; ctcan2 changed 18 and 2.
  * These are IDENTICAL to the PRISTINE sweep's readings in the same environment, so the drift is environmental.
  * A row-join of the fix and pristine csvs differs in one cell, YosysBigSimEllip/default dump `''` vs `differ`. That database is not a byte mover.

## Residues, ranked

1. **V1:** L6 is dormant wherever the matchers split. That is the pristine reading, not Surelog's. Reproducing Surelog's region semantics exactly would need a region filter that follows Surelog's rules instead of slang's lexer handler. No corpus row needs it.
2. **R1 (implementer):** func_upto and matching_end_labels. The order comes from the saved file's layout, as reproduced above.
3. **V3:** L5 does not reach NON-ANSI port declarations (d05: `input data_t [N-1:0] d_i;` in the body). The row stays EQUIVALENT before and after, so this is not a regression.
4. Implementer's R3-R8 stand as reported: i02, which is the generic interface port, is NE at base, and t05/t07/d06 stay EQUIVALENT at base and after.

## Instruments

* `arm.sh <arm> <out>`: the four readings above.
  * It uses `LAW=<binary>`, pristine `/tmp/v11u120_bin/pri.bin`, and the env file `/tmp/v11u120_env.sh`, which exports the OPS tool paths.
  * The downstream names are distinct per arm and lane (`vL<md5>` / `vP<md5>`). The harness's `/tmp/u2rds-<sha1(name/lane)>` run directory is shared by any two concurrent runs of the same name. This includes two sweeps of the same corpus by different binaries, so **never run two downstream sweeps concurrently.** This pass killed its own overlapping pair and re-ran them sequentially.
* `offbytes.sh <list> <out>`: `R11U120_OFF=1` fix vs pristine, probe and downstream flags, rc included.
