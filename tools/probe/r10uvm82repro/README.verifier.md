# r10uvm82 — ADVERSARIAL VERIFICATION (independent re-measurement)

Verdict: **ACCEPT the law, with ONE SHIPPED-GATE FIX applied here.**
Worktrees `/tmp/wt_v82` (patched) and `/tmp/wt_v82pris` (pristine), both at base
4df4bab; every binary, every sweep, every ladder below was built and run by the
verifier, not copied from the implementer's report.

## Reproduced BIT-FOR-BIT from my own builds

| claim | implementer | verifier |
|---|---|---|
| pristine binary md5 | 4220e4f818406b3c91323967eb59db89 | same |
| patched binary md5 | 683788581e68882202c6079d3a68b1e7 | same |
| goldens / negative control | 23 PASS 0 FAIL / 0 PASS 23 FAIL | same |
| u2r both modes | 679 CMP_EQUAL 50 SLANG_REJECT 2 SURELOG_FAIL | same |
| row gate, base-4df4bab baselines | 0 differing ROWS over 1588 and over 731 | same |
| sweep CSVs pristine vs patched | identical | byte-identical (surelog/u2r/u2r-tf) |
| byteverify | surelog 5/953, u2r 0/1358 | same; SELFCHECK flags a 1-byte corruption (6/953) |
| the 5 movers | the 5 UVM rows | same rows, no others |
| sd grid boundary | cells=347 MOVERS=0 NO_OUTPUT=4 | same |
| full sd/uvm/buvm boundary | CELLS=909 MOVERS=14 NO_OUTPUT=16 | same |
| canaries / ctcan2 | 52+8 ok / 58+1 ok, changed=0 | same |
| DB pins incl. the mandated SVSwitch pin 4842211c4030 | 4 pins hold | same |
| official cmp, 7 UVM row-modes | byte-identical, 1450011/1405511/1399779/29 | same; Scoreboard re-run from scratch = 1399779, 1 head, byte-identical |
| ladder family `parameter|VpiImported|O-EMPTY` | 902 -> 0 | **902 to the unit** (164+164+164+246+164) -> 0, and no `FIELD=VpiImported` of any shape remains |
| ladder rungs per row | 385->506, 392->228 x2, 514->268, 392->228, 258->258 x2 | same, maxvis figures identical |
| BuildUVMPkg negative control | ladders byte-identical | same (both modes, after normalising workdir+secs) |
| new tops after the wall falls | 165 / 28 / 25 / 16 / 16 ; 21 / 22 | same |
| ladder self-calibration | RUNGS=0 on 183142 and 187081 objects | same |
| ct82imp census (goldens vs ours) | 275/225, 275/90, 280/0 | same |
| patch applies on fresh 4df4bab, round-trips | md5 4ef1970498ae2305eba53719bd14ceef | same; also applies clean on branch head 039295a |

## THE SHIPPED TREE FAILED ITS OWN CITED GATE (fixed here)

`canaudit.sh` searches every file in this directory except itself and
`README.md` for the four slang-fenced names.  The shipped
`GATES.r10uvm82.txt` **spelled all four out**, so on a pristine application of
the shipped patch `canaudit.sh` prints `FENCE-BREACH=4` and **exits 6** — the
report claimed `FENCE-BREACH=0`.  Measured on a fresh 4df4bab worktree with the
shipped patch applied, before any edit.  The fix is the two header lines of
`GATES.r10uvm82.txt`: name the fenced LIST, not its members.  `src/ModuleEmit.cpp`
is untouched by this fix, so every number above still refers to binary
683788581e68882202c6079d3a68b1e7.

## Breaking the law — 35 arms, order-blind

`v82varm.sh` (golden = Surelog, RHS = ours, official `uhdm-cmp`), each arm run on
BOTH binaries; `v82varmladder.sh` ladders every arm before AND after and diffs
the rung KEY sets; `v82vcmpmiss.sh` does a multiset line diff of the dumps.
Shapes covered: wildcard / explicit / two-explicit / typedef-only imports;
2-hop and 3-hop chains; `export pkg::*` re-export; `$unit`-scope imports (class
at `$unit`, class in module); package-scope classes; interface and program
classes; nested classes; inheritance; virtual + pure-virtual classes;
parameterized classes; duplicate imports; shadowed names; `type_parameter`;
localparams; every scalar parameter kind (string/real/signed/packed/struct/
unpacked-array); and two NON-import negative controls.

Results, every arm: **NEW ladder rung keys = 0**, **REGRESSED golden lines = 0**,
**ours-only stamped objects = 0**, family cleared to 0 wherever it fired.
**11 arms convert CMP_FAIL -> PASS_CMP** on the official judge.  The two
non-import controls are byte-identical (0 rungs, 0 dump delta) — no over-fire.
Value string: golden stamps the **immediately-imported** package, and the
re-export arm (`v82v_arm04_reexport.sv`) **witnesses it** — golden and ours both
say `pb4`, not the source `pa4`, so the residue the report left un-witnessed is
now measured and correct.

## Whole-row proof that nothing else moved

`uhdm-dump` of the pristine and patched databases, whole row, path-normalised:

* default SeqDriver: removed **225 lines, all of them one-line `\_parameter`
  back-references**; added 5185, all of them the copies (450 `vpiImported`,
  450 `\_parameter`, 225 `\_param_assign`, and their back-refs).  Nothing else
  in 1.81 M lines changed.
* default SimpleUVM: 180 `vpiImported` added (90+90); removals only back-refs.
* default Scoreboard: multiset removed = exactly 90 back-reference lines; the
  positional diff's extra noise is expansion-point RELOCATION and cancels.

This is why the 45 "new families" in the SeqDriver ladder are not new defects:
that row's `maxvis` nearly TRIPLED (15910 -> 43092), so the ladder now walks
regions it could never reach — the content delta is provably only the copies.

## The 14 boundary movers, checked against GOLDEN (not just by bytes)

Each of the 14 was re-run through the arm harness on both binaries:
`MISS` drops on every one, `REGRESSED golden lines = 0` on every one, added dump
lines are the copies only, and `r10uvm23repro/t34e/t.sv` **converts to PASS_CMP**.

## RESIDUES, ranked (measured, none of them regressions)

1. **`type_parameter` is UNFIXED and IS reachable on legal SV.**
   `v82v_arm06_typeparam.sv`: golden stamps `work@top::C::T6` with `pt6`; ours
   leaves it empty, and the ladder keeps one `type_parameter|VpiImported|O-EMPTY`
   rung BEFORE **and** AFTER.  The report's "no package in either corpus exports
   one" is true of the corpus, not of the language.  Same copy, `MakeType_parameter`.
2. **Parameterized classes never receive the copies at all.** `C17 #(int W=3)`:
   golden stamps `work@top::C17::BASE` with `pk17`; our dump delta for that arm is
   **zero** before and after (`MISS` 257 unchanged).  §23/§82 do not reach
   specializations.  Biggest remaining slice of this family's shape.
3. **Duplicate-import multiplicity.** `import pk::*;` twice: golden emits the
   class listing entry TWICE (and the module's twice), ours once — a
   `class_defn|Parameters|VEC:G>O` rung identical before and after.
4. **Re-export over-lists.** `v82v_arm04_reexport.sv`: `class_defn|Parameters`
   golden 2 vs ours 3, unchanged by this pass.
5. **Shared `ref_typespec`** (report's residue 1): confirmed dump-axis only —
   450 back-reference lines per SeqDriver, and 11 arms pass the official judge
   with it in place.
6. **Two committed probe cells SEGFAULT on BOTH binaries** at base 4df4bab:
   `r10uvm67repro/c3_iface.sv`, `r10uvm67repro/v3_boundary.sv` (rc=139).
   Pre-existing and symmetric, but they sit inside `allbound82.sh`'s
   `NO_OUTPUT=16` bucket and the report did not name them.
7. **Base-drift note for the master:** `results/golden_surelog.csv` was PROMOTED
   after this pass's base (the YosysVerx conversion).  Against the CURRENT
   committed baseline both binaries show the same 2 differing rows; against the
   4df4bab baselines both show 0.  The gate is green, the report's "results/*.csv
   unchanged since 4df4bab" is no longer literally true at head.
8. `class`-body imports are rejected by slang on both binaries
   (`-Wpackage-import-in-class`), so that arm cannot be exercised; recorded so the
   next pass does not re-spend it.
