# r10earl41 — GATE 4 (surelog corpus) and GATE 5 (byte verifier), raw

Every number below is from the FINAL binary
`/tmp/wt_r10earl41/build/slang-uhdm` md5 `0b7bba3fa768a345acb8ab02b6b6ed4c`
against the PRISTINE `19730ce` binary `/tmp/wt_r10earl41pris/build/slang-uhdm`
md5 `d90af4f662bab7e66f24bfe6258a8f9b` that I built in a clean worktree.

## GATE 4 — surelog, BOTH modes, `--jobs 2`, ONE INVOCATION PER MODE

Run sequentially, one `verify_golden.py` invocation per mode, so the documented
`SURELOG_FAIL` detail-row race under concurrent sweeps cannot fire.
`GOLDEN_DEFER` left UNSET.

```
[default]   794 tests  CMP_EQUAL 469  CMP_NOTEQUAL 11  SURELOG_FAIL 25  DEFERRED 5   -> 469/11  EXPECTED
[testflags] 794 tests  CMP_EQUAL 465  CMP_NOTEQUAL  8  SURELOG_FAIL 23  DEFERRED 5   -> 465/8   EXPECTED
```

`ct8rows.sh` against the committed `results/golden_surelog.csv`
(1588 rows vs 1588 rows, the two modes concatenated into one CSV):

```
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
---- per-mode DUMP-column histogram (baseline -> fresh)
  default    base: 325 blank  244 differ  225 match
  default    fresh: 325 blank  244 differ  225 match
  testflags  base: 329 blank  300 differ  165 match
  testflags  fresh: 329 blank  300 differ  165 match
PASS: every row byte-identical to the committed baseline
```

The target's own rows are byte-identical to the baseline — **its ROW does not
move, its BYTES do**:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
```

Independent confirmation that every row number above is a property of the change
and not of the machine: `diff sl_pat.csv sl_pris.csv` and
`diff u2r_pat.csv u2r_pris.csv` are **both empty**, and both match the committed
CSVs.

## GATE 5 — BYTE VERIFIER, both corpora, both modes

```
uhdm2rtlil : databases patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
surelog    : databases patched= 953 pristine= 953  PATH_SETS_IDENTICAL  MOVERS: 2 /  953
  MOVER ./default/Earlgrey_0_1-71da2fd7  patched=db5d5f79efc7  pristine=c2384ffe6132
  MOVER ./default/Scoreboard-59431470    patched=8e9695a9e7cf  pristine=9d3fd083f4f1
```

Both mandatory controls fire on both corpora:

```
uhdm2rtlil  SELFCHECK=1 -> 1357 / 1358 flagged      SELFCHECK1=1 -> 1
surelog     SELFCHECK=1 ->  952 /  953 flagged      SELFCHECK1=1 -> 3
```

The surelog `SELFCHECK1` answer **3 = the one corrupted file + the two movers**,
which is what that control's own message says to expect.

### The two movers, arbitrated by the stated law (size-delta, then 3 reps)

```
SIZE  Earlgrey_0_1  patched 49941318  pristine 49940463  -> +855, SIZE DELTA, REAL
      Scoreboard    patched 11122938  pristine 11122938  -> SAME SIZE

3 REPS, the SAME PRISTINE BINARY, Scoreboard/default, run by hand:
   rep1 9d3fd083f4f172a7f4bde5009f7cfc61   size 11122938
   rep2 8a2c4827db5b402472284df03c6eafe0   size 11122938
   rep3 ed015f929da634a6f37fcdd1e9704035   size 11122938
```

**Three runs of the unmodified pristine binary give three different md5s at a
constant size.** `Scoreboard` is nondeterministic run to run independently of
this patch (the documented emitter nondeterminism: SourceLocation compares
across macro buffers flip per run under parallel parse). It is a FLAKE by BOTH
halves of the stated test, and its CSV row is byte-identical in every sweep.

**The one REAL mover in 2311 databases is `Earlgrey_0_1/default` — the target,
named by the verifier itself** — and it is accounted for object-for-object in
README.md §§ 1 and 7.

### An earlier binary of this pass had THREE movers — recorded, not hidden

The 3-cell `joinRef` rule (`work@`-rooted AND dotted ⇒ `.`) produced

```
MOVER ./default/SVSwitch-db796243    patched=bd0c6084ae2e pristine=de7ab46e3f2e   -5 bytes
MOVER ./testflags/SVSwitch-db796243  patched=bd0c6084ae2e pristine=de7ab46e3f2e   -5 bytes
```

`SVSwitch` is a PROTECTED canary. Its rows never moved (status and dump column
identical), so **only the byte verifier could see it**, and the dump said what it
was:

```
golden   work@Receiver::start::bytes::size
pristine work@Receiver::start.bytes::size     (the `.bytes` is our own older defect)
patched  work@Receiver::start.bytes.size      <- MOVED AWAY on the second separator
```

That refuted the 3-cell rule and produced the 4-cell one now in the code
(`::` iff the first `::` precedes the first `.`), under which SVSwitch is
byte-identical to pristine again and is not a mover. **Both wrong repairs are
kept as named cells in the `joinRef` comment so the next edit cannot break one
silently.**

## CANARIES

```
canaries.sh  u2r (testflags projection) : rows ok=8  changed=0 absent=0 unknown-names=25
canaries.sh  SL                          : rows ok=52 changed=0 absent=0 unknown-names=7
ctcan2.sh    u2r  EXPECT_UNKNOWN=6       : rows ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh    SL   EXPECT_UNKNOWN=1       : rows ok=58 changed=0 absent=0 unknown-patterns=1  PASS
canaudit.sh                              : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
```

Both `ctcan2` runs are mode-matched to the corpus and take the COMMITTED
baseline as their first argument, per that script's own contract. The 25/7
unknown-name counts are the documented per-corpus split.

**PROTECTED genscope canaries, BY NAME, fresh vs committed baseline — all
IDENTICAL:**

```
gen_test9              testflags CMP_EQUAL ,,match     IDENTICAL
genvar_loop_decl_2     testflags CMP_EQUAL ,,differ    IDENTICAL
genvar_loop_decl_3     testflags CMP_EQUAL ,,differ    IDENTICAL
paramod_genscope_child testflags CMP_EQUAL ,,match     IDENTICAL
genscope_cells         testflags CMP_EQUAL ,,differ    IDENTICAL
gen_test4              testflags CMP_EQUAL ,,differ    IDENTICAL
indexed_partsel_array  testflags CMP_EQUAL ,,match     IDENTICAL
EnumConcat             testflags CMP_EQUAL ,,differ    IDENTICAL
```

**BY NAME, per corpus, so a vacuous "identical" cannot hide:**

```
InterfaceModPort     gate_uhdm2rtlil.csv : 0 rows (surelog-only canary) -- vacuous, stated
                     golden_surelog.csv  : 2 rows, IDENTICAL
BlackParrotComplex   gate_uhdm2rtlil.csv : 0 rows (surelog-only canary) -- vacuous, stated
                     golden_surelog.csv  : 2 rows, IDENTICAL
```

## THE FENCED BOUNDARY ARMS — all held, both binaries

Dumps compared after workdir-path normalisation (uhdm-dump embeds the scratch
dir in every `file:` field).

```
r10earl38 bnd_a1_chain (§ genChainBranchScopeThreads38)  PASS_CMP both, DUMP BYTE-IDENTICAL
r10earl38 bnd_a2_fence (earl38 residue R3)               CMP_FAIL 989/68 both, BYTE-IDENTICAL
r10earl39 bnd_a1_argts (§ defGenProcArgNoFormalTs39)     CMP_FAIL 306/21 both, BYTE-IDENTICAL
                                                         (earl39's own recorded value)
```

### r10earl40's own two probes — its DEF grid HELD, its recorded R1 CLEARED

`a1_sel40.sv` (56 view-keyed rows) and `v40_overfire.sv` (10 rows), both read
with `cells41.py`, name axis:

```
a1_sel40      REGRESSED 0   HOLD-OK 11   rows whose select NAME moved to golden 16
                                          (13 ELAB + 3 DEF: c_gpr_pkg_bk_rsym,
                                           c_mca_pkg_br, c_mpr_pkg_br)
v40_overfire  REGRESSED 0   HOLD-OK  7   rows moved to golden 3 (c_ws/c_nest/c_three ELAB)
```

**Those 16 rows are the cells r10earl40's README named as its residue R1,
verbatim** ("`c_mca_pkg_br`, `c_mpr_pkg_br` and every `ELAB` row"). They are
`ARR40 -> p40::ARR40`, i.e. golden's name, so the earl40 grid does not merely
hold: this pass clears the residue that grid was measuring.

`v40_overfire`'s whitespace cell is also the F3 witness on earl40's own file:

```
|vpiName:q40::A<space>   pristine 2 occurrences      patched 0
```
