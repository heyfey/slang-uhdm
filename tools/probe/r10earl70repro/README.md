# r10earl70: generate-scope HighConn part-select bound abstention

Implementer verdict: **ACCEPT** at base
`efb12c5a4f60d79d538c6f92c68bb3125eaad404`.

This directory is the durable reproducer and measurement kit for the first
Earlgrey head in both modes.  The official `uhdm-cmp` comparison is the judge;
the text tools here are diagnostics only.  All measurements below were freshly
repeated after inheriting the worktree rather than accepted from its write-up.

## R0 and decoded law

The pristine binary has 50 comparison lines and one head in each mode at
`flash_phy_rd.sv:143:22-143:31`:

```systemverilog
.addr_i(addr_i[BankAddrW-1:LsbAddrBit])
                 ^^^^^^^^^
```

Golden retains a located `ref_obj BankAddrW` whose Actual is a fresh, locless
`enum_const BankAddrW`.  The pristine exporter instead emits a located
`constant`, `UINT:16`, size 32, with an `int_typespec`.

The source-level law is:

1. `NetlistElaboration::high_conn_` recompiles the actual with `Reduce::Yes`,
   expression `p`, and instance `parent` (Surelog
   `src/DesignCompile/NetlistElaboration.cpp:1094-1096`).
2. At a child instantiation in a generate scope, that reduction window abstains
   from substituting the unqualified package parameter used inside the simple
   part-select bound operation.
3. `UhdmWriter::lateBinding` finds the surviving name with
   `mod->getValue(name)` and attaches a newly minted `enum_const`
   (`src/DesignCompile/UhdmWriter.cpp:3951-3960`).

This pass deliberately implements only the measured positive slice: an
unqualified, nonnegative package parameter that is an immediate subtraction
operand inside that elaborated generate-scope HighConn part-select bound.
Direct bounds, other operation kinds, and negative parameter values are not
claimed.  The verifier recut and its counterexample are documented in
`../r10vearl70repro/README.md`.

The inherited broad rule was rejected before the full sweeps.  Although it
changed the Earlgrey head from 50 to 17 lines, it produced these wrong grid
cells:

| Grid | broad-patch result |
|---|---:|
| g1 direct right bounds | 104 MOVED-WRONG |
| g2 direct right bounds | 112 MOVED-WRONG |
| g3 negative `ENEG+8` | 8 AWAY-GOLDEN |

The extra parent-operation and nonnegative guards eliminate all three classes.

## Purpose-built golden grid

`g1_earl70.sv` crosses seven symbol origins, two homes, and seven select/use
positions.  `g2_earl70.sv` crosses qualification and generate-container forms.
`g3_enc70.sv` measures eleven nonnegative encodings plus the negative refusal.
The golden databases for this grid were produced with the current compatible
Surelog build at `/home/heyfey/git-repos/Surelog/build/bin/surelog`; an older
pinned sv-tests binary writes a serialization that the current probe reader
cannot consume.

Fresh scoring of the narrowed binary, in both probe views:

| Grid | View | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG |
|---|---|---:|---:|---:|
| g1 | plain | 64 | 0 | 0 |
| g1 | elab | 64 | 0 | 0 |
| g2 | plain | 48 | 0 | 0 |
| g2 | elab | 48 | 0 | 0 |
| g3 | plain | 88 | 0 | 0 |
| g3 | elab | 88 | 0 | 0 |

`GRID_SCORE.txt` contains the full calibrated counts.  The calibration
golden-vs-golden rows contain only STILL-RIGHT cells.

## Corpus census and predicted movers

The corpus comparison is calibrated with golden-vs-golden first and excludes
the judge-invisible span, typespec-span, and actual-full-name payloads before
classification.

| Mode | Cells | STILL-RIGHT | STILL-WRONG | TO-GOLDEN | away/wrong |
|---|---:|---:|---:|---:|---:|
| default | 531489 | 508206 | 23251 | 32 | 0 |
| testflags | 811229 | 770377 | 40820 | 32 | 0 |

The calibrated golden-vs-golden totals are 521401 cells in default and 799038
in testflags, all STILL-RIGHT.  `CENSUS.txt` preserves the scorer output.

Before sweeping, the predicted byte movers were exactly:

- `default/Earlgrey_0_1-71da2fd7/slang.uhdm`
- `testflags/Earlgrey_0_1-71da2fd7/slang.uhdm`

Byte verification found exactly those two among 956 Surelog database paths and
zero movers among 1358 uhdm2rtlil database paths.  Both path-set assertions
passed.  The negative comparator controls flagged 955/956 and 1357/1358 paths,
respectively.

## Five gates

All sweeps used frozen pristine and patched binaries, `-j2` builds, harness
`--jobs 2`, and both modes where applicable.  `GATES.txt` records the exact
summary.

1. **Row/status parity:** pristine and patched Surelog sweeps each produced
   1588 rows with identical status/dump columns; pristine and patched
   uhdm2rtlil sweeps each produced 731 rows per mode with identical rows.
2. **Committed-baseline parity:** patched Surelog and uhdm2rtlil rows match the
   committed golden CSVs exactly.
3. **Targeted heads:** Earlgrey is 50 -> 46 lines, one head -> one head, in both
   modes.  The original `BankAddrW` head is gone.  The new R0 is the deliberately
   unclaimed direct right bound `LsbAddrBit` (`ref_obj`/`enum_const` versus
   `UINT:1`/`int_typespec`).
4. **Golden tests and controls:** 23/23 golden dumps pass; `/bin/false` produces
   0 passes and 23 failures.  Named and supplementary canaries report no
   changed rows.  The canary coverage audit reports 29 protected names/families,
   zero uncovered entries, and zero fence breaches.  All campaign fences were
   untouched.
5. **Protected bytes and pins:** the protected rows have no pristine-to-patched
   byte movers.  The two external pins are unchanged (`SVSwitch`
   `4842211c40304b44fbb046201ec0287e`, `YosysVerx`
   `6ccda350c24a83cebc9ca4a7b6e505cf`).

## Exhaustive boundary

The boundary drivers compare the frozen pristine and narrowed binaries twice:
plain serialization and elaborated-model serialization.

| Walk | Processed | identical | differing | no output |
|---|---:|---:|---:|---:|
| every `.sv` file | 3154 | 6032 | 6 | 270 |
| every unique directory | 1449 | 2659 | 6 | 233 |

The six per-file differences are exactly g1/g2/g3 in both views.  The six
directory differences are this reproducer in both views plus two pre-existing
UVM probe directories in both views.  Those four UVM differences are only
`design::Task_funcs` ordering: sorted normalized dumps are byte-identical.
Every signal was symmetric between the pristine and patched arms (20 entries
in the file walk, 10 in the directory walk), so there is no new crash or
timeout.  The only substantive boundary movers are the three positive-control
grid files, and every measured changed cell moves to golden.

Raw evidence is in `BOUNDARY_WIDE.*`, `BOUNDARY_DIR.*`, `HEAD_BEFORE_*`, and
`HEAD_AFTER_*`.

## Reproduction

Build the probe tools with `tscen70.cpp` and `findobj70.cpp`, then use:

- `earl70.sh` for the official Earlgrey comparison;
- `runarm70.sh` and `armscore70.sh` for the golden grid;
- `cen70.sh`, `nospan70.sh`, and `score70.py` for the census;
- `byteverify.sh`, `rowheads.sh`, `canaries.sh`, `ctcan2.sh`, and
  `canaudit.sh` for the sweep gates;
- `vwide70.sh` and `vdir70.sh` for the exhaustive boundary.

The scripts refuse missing inputs where absence could otherwise masquerade as a
pass and contain their own comparator/coverage controls.  No integration,
commit, main-tree edit, results edit, stash, or fence dispatch belongs to this
pass.
