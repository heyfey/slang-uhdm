# r10earl50 — verifier notes

Four things went wrong inside this pass and were fixed **before** anything
landed. All four are recorded here, because a silently-corrected mistake is
indistinguishable from one that was never made.

---

## V1. The first cut BROKE THE `BlackParrotComplex` CANARY, and the corpus sweep is what caught it

The first implementation dropped the select rule for **every** syntax position
that the 62-cell grid measured as golden-LOCATED, including a select inside
ANOTHER PARAMETER's INITIALIZER (`h1.H5`, and later `h5.L1..L8`, eight
independent variants — all golden-LOCATED).

`Surelog/tests/BlackParrotComplex/dut.sv` disagrees:

```systemverilog
 parameter bit [1:0][dirs_lp-1:0][dirs_lp-1:0] routing_matrix_p = (dims_p == 2) ? StrictXY : StrictX;
 localparam output_dirs_sparse_lp = (($bits(routing_matrix_p[0][i]) < 65) ? ... );
```

`routing_matrix_p` is read ONLY by `routing_matrix_p[0][i]` inside another
parameter's initializer, and it needs the BARE typespec: the LOCATED
`bit_typespec@40:12-40:47` carries `[dirs_lp-1:0]` ranges whose `ref_obj`s
resolve to a `parameter (work@top.dirs_lp)` that golden does not have there.

Measured, `surelog/testflags`:

```
BlackParrotComplex,testflags,CMP_EQUAL,,,differ            <- pristine
BlackParrotComplex,testflags,CMP_NOTEQUAL,decompile:,,     <- first cut
```

head: `LHS: <null>` / `RHS: parameter (work@top.dirs_lp)`. Deterministic —
two runs of each binary, identical md5s each time.

**Remediation, and it is deliberately a NON-fix of the position.** The
parameter-initializer select is KEPT exactly as it was, unchanged from the
pristine binary, and recorded as residue R5 — an OPEN CONTRADICTION between
eight arm cells and one canary, stated rather than resolved. Everything else
the grid measured is dropped. After the fix the canary's database is
**byte-identical to pristine** (md5 `73a10e8217e5`) and CMP_EQUAL again.

**The lesson is the standing one, and it earned its place again:** the arms are
not the corpus. Nine positions measured golden-LOCATED on purpose-built arms;
the tenth had a corpus witness pointing the other way, and only the sweep saw
it. A pass that shipped on arm evidence alone would have landed a canary
regression.

---

## V2. A second cut then got `h2.I1` wrong, by losing a flag on a recursive call

The `wide50` harvest is gated on `(ctx & 2) || !(ctx & 4)` — bit 2 is the
generate-condition context, bit 4 the dropped context. The ContinuousAssign
arm's own explicit recursion into a ternary PREDICATE was still passing
`ctx = 1` (narrow only), so bit 4 was clear and the predicate's selects were
harvested after all:

```
work@h2_earl50.I1   golden LOCATED   cut-2 BARE   ✗
```

`assign o1 = I1[0] ? n1 : n2;` — golden is LOCATED because the ternary's
operand-1 is a bare net and stops the pre-scan. Fixed to `ctx = 5` (`1|4`):
the NARROW (ranged-untyped) path keeps that predicate, `wide50` drops it, and
the operand walk decides it. The pair that proves the walk is the right
decider and a blanket predicate rule is not:

| cell | expression | golden | after fix |
|---|---|---|---|
| `h2.I1` | `I1[0] ? n1 : n2` — net branches | LOCATED | LOCATED ✓ |
| `h4.K6` | `K6[0] ? n1[0] : n2[0]` — bit-sel branches | BARE | BARE ✓ |

Caught by re-running the arm grid after the V1 fix rather than assuming the
V1 fix was local.

---

## V3. earl49's 77-cell set is NOT what this pass was sent to fix, and the instrument is why

The brief (from r10earl49's README) says the 77-line census disagreement set
"is THE WHOLE remaining Earlgrey elab param census disagreement set" and that
"every remaining line ... belongs to paramNameIsRead, residue R1".

`census49.py` keys on `(instance ref name, typespec kind, typespec span)` with
the parameter NAME projected out. Two different parameters of one instance
whose typespecs differ in span produce two `<`/`>` line PAIRS that look like
four disagreements; a cell that merely moved span looks like a disagreement in
both directions. Re-keyed on the CELL (`grid50.py`, `<instance>.<param>`):

```
77 census49 lines  ->  12 disagreeing CELLS
                          7 R1 (this pass moves all 7, +1 more)
                          2 the OTHER direction   (R2)
                          3 cells golden does not have at all (R4)
```

The 77 number was never wrong as a count of `census49.py` lines; the claim
attached to it was. Both instruments are shipped so the difference can be
re-read: `census49.py` unchanged as `census50.py`, and `grid50.py` as the
cell-keyed one this pass judged on.

---

## V4. The CENSUS PREDICTION missed a mover, in the instrument's blind spot

`CENSUS_PREDICT50.txt` predicted seven moved cells and named them. Eight
moved. The eighth is `work@jtag_mux.TieOffValues`, and the prediction missed
it because `grid50.py`'s default view is the LAST `|uhdmtopModules:` block,
while Earlgrey's dump carries several standalone-top listings before it (a
module slang treats as top because nothing instantiates it). Re-run with
`--all`, the pristine dump has TWO rows for that cell — one BARE in the
standalone listing, one LOCATED elsewhere — and the patched dump has only the
LOCATED one, which is exactly golden's single row.

So the miss is an instrument-SCOPE miss, not a law error: the eighth mover is
the same law, the same direction, and it lands ON golden. It is recorded here
because "the prediction landed exactly" would otherwise be a false statement,
and the prediction's whole job is to be checkable.

Every subsequent count in the README is the `--all` one.

---

## The `msdist` number went UP, and the per-shape table says why

`msdist.sh` (multiset line distance to golden) on Earlgrey_0_1:

```
pristine 300953   patched 300977   (+24)
```

while the cell census improved 38 → 23 disagreements. Both are true and the
+24 is fully attributed, line by line:

| Δ | golden | pris | pat | shape |
|---|---|---|---|---|
| −1 ×11 | 1..2 | 0..1 | 1..2 | every SPAN-BEARING `logic_typespec` line — each moves to golden's exact count |
| −8, −8 | 43, 75 | 53, 85 | 45, 77 | the anonymous `\_logic_typespec:` / `\_range:` surpluses shrink |
| **+8 ×4, +16, +4, +2, +1** | 32005, 31999, 64140, 510 … | ours already SHORT | shorter still | `\|UINT:0`, `\|vpiLeftRange:`, `\|vpiRightRange:`, `\|vpiParent:`, `\_constant:`, `\|UINT:11`, `\|UINT:31`, `\|UINT:2` |

Removing eight bare typespecs removes eight 11-line generic subtrees, and on
six of those generic line kinds ours is **already below** golden for unrelated
reasons (`\_constant:` 425 vs 510, `|vpiParent:` 60709 vs 64140). So the
multiset distance charges us for lines we no longer emit even though the
objects that carry identity all moved ONTO golden's counts. `msdist` is a
resync-immune distance, not a correctness measure; on this pass the CELL
census and `shapes50.sh` are the authorities, and both say the same thing.

Scr1SvTests, where no such global deficit dominates, moves the expected way:
`2419 -> 2416`.

---

## Gate record

| gate | result |
|---|---|
| 1. build both, md5 | pris `eacd60adb66c45ccdf5db8cb56596955`, pat `fe7143d9c326a32e330290f1d71aa1d5` |
| 2. `tests/check_goldens.sh` | patched **23 PASS / 0 FAIL**; negative control `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** |
| 3. uhdm2rtlil, both modes, both binaries | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** ×4; `ct8rows` baseline-vs-patched **0 differing rows**, pristine-vs-patched **0** in both modes |
| 4. surelog, both modes, both binaries | `ct8rows` committed baseline (1588 rows) vs patched **0 differing rows**; pristine-vs-patched **0** in both modes |
| 5. `byteverify50.sh` | u2r **6 movers / 1358**, surelog **3 / 953**; `SELFCHECK=1` flags 1357/1358, `SELFCHECK1=1` reports 7 = 6 real + 1 corrupted |
| canaries | `canaries.sh` u2r ok=8 changed=0, surelog ok=52 changed=0; `ctcan2.sh` `EXPECT_UNKNOWN=6` (u2r) and `=1` (surelog) both **PASS, changed=0** |
| boundary arms | `bndarms50.sh` **identical=25 differing=0** over earl38/45/46/47/48 |
| DEF-view fence | Earlgrey `head -1196437` md5 `c69245ac103c4a355e58b0ef99234970` on BOTH binaries |
| heads | `rowheads.sh`: Earlgrey_0_1/default 52 lines / 1 head on both; Scr1SvTests, BlackParrotComplex, SVSwitch, YosysOldOr, InterfaceModPort all 0/0 on both |

### Every byte mover, named and attributed

| database | cells | why |
|---|---|---|
| `Earlgrey_0_1` default | 8 | the census table in README.md |
| `Scr1SvTests` default + testflags | 1 | `SCR1_TIMER_MTIMECMPHI`, read only as `MTIMECMPHI[ADDR_WIDTH-1:2]` inside `assign dmem_req_valid = (…) & (dmem_addr[W-1:2] <= …)` — a PART-SELECT operand stops the walk (`c1.C6`/`e1.E7`). golden-vs-ours dump lines 27653 → 27640 |
| `ParameterInitializedByPartSelectOfParametersAssignedToVar` ×2 modes | 1 | `FullDepth`, read by `assign max_value = FullDepth;` inside a TAKEN if-generate — the gen-scope BARE-NAME rule (`h3.JM`). 22 → 9 |
| `rp32_r5p_mouse` ×2 modes | 3 | `GPR_ADR[XLEN-1:5+2]` and two `localparam logic [2:0]` funct3 codes, all read only in procedural `case`/assignments. 71 → 32 |
| `rp32_r5p_mouse_soc_simple_top` ×2 modes | 2 | the same two funct3 localparams, one instance level down. 762 → 736 |

Every one moves STRICTLY toward golden; no database moved away.

### Ops note

Four `verify_golden.py` processes belonging to ANOTHER session's worktree
(`/tmp/wt_v79`) were alive while this pass's sweeps ran. They are reported
here because `ps -eo cmd | grep -c '[v]erify_golden.py'` counts them and a
reader checking that count would see a non-zero number after this pass's own
`ALL_SWEEPS_DONE`. This pass's sweeps were confirmed finished by the marker
AND by the absence of any `r10earl50` CSV/workdir process; the `TIMEOUT: 1` and
`NO_UHDM: 1` rows in the surelog histogram are **in the committed baseline**
(`ct8rows` vs `results/golden_surelog.csv` is 0 differing rows over 1588 for
BOTH binaries), so they are not contention artifacts.
