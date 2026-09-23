# v11u112 — adversarial verification of r11u112 (ACCEPT WITH A FIX)

Base `1d7a03b8`. Pins per `SUPPORT_MATRIX.md` (slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 `~/git-repos/Surelog/build/bin/surelog`, uhdm2rtlil v0.68).

| binary | md5 | what |
|---|---|---|
| pristine | `b3dc863277c4f1340e9058c8b78f2f01` | own worktree at `1d7a03b8`, `-j 2`; equals the pin |
| law (`r11u112.patch`) | `8515ddf0478b481965fbb772bf9c0248` | fresh `1d7a03b8` + the patch; equals the implementer's md5 |
| **verified** (`r11u112.verified.patch`) | `31d6bf001c1f6d2ad07edd704b66a8b0` | law + the two fences below |
| HEAD `a8acb1e9` pristine | `e3a9a05109775022fe781f9a6401cef3` | integration control (pass 109 landed) |
| HEAD + law | `a5f3e3c9149c01f9f8ec47ae7e358a47` | integration check |

## Headlines reproduced (bit for bit)

* The seven rows at the base: const_cast_signext 17, ibex_icache 17, ibex_pmp 36,
  arb_idx_cast 46, unpacked_elem_partsel_comb 91, packed_array_struct 499
  (uhdm2rtlil) and SequenceInst 122 (surelog), the same in both modes, with
  the heads the implementer quotes.
* With the law binary and the verified binary: SequenceInst, const_cast_signext,
  packed_array_struct and unpacked_elem_partsel_comb read 0 lines / 0 heads and
  `CMP_EQUAL` in both modes. arb_idx_cast 46 -> 18, ibex_icache 17 -> 36 (the
  fenced range-bound face), ibex_pmp 36 -> 36. `evidence/SEVENV112.txt`.
* uhdm2rtlil 794/10/67 -> 797/7/67 in both modes. Surelog 477/6 -> 478/5 (default)
  and 472/5 -> 473/4 (testflags). The pristine sweep equals the committed CSVs
  row for row (apart from the LowMem log-path text and Earlgrey's dump column,
  which read blank on a uhdm-dump timeout draw under load in the pristine and
  law sweeps and `differ` in the verified sweep; the Earlgrey databases are
  byte-identical to the pins in every sweep).
* Byteverify (`SELFCHECK=1`, identical path sets): u2r 10/1608 = the five moved
  target rows x 2 modes; surelog = SequenceInst x 2 + the UVM 4-line
  `UINT`/`vpiDecompile` class (MiniAmiq, SeqDriver) + one Scoreboard/default
  coin at order-blind 0. Every UVM row stays `CMP_EQUAL`.
* Pins (both modes, every sweep): Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`,
  SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort
  `59a365f3ce2c`, and BlackParrotComplex and YosysOldOr unchanged. Canaries
  ok=52/8 changed=0, both ctcan2 runs PASS, and canaudit PASS. Goldens 23/0 on
  all three binaries; `/bin/false` 0/23.
* Integration on HEAD `a8acb1e9`: the patch applies cleanly, and
  type_param_override_elem_sel stays `CMP_EQUAL` in both modes. The u2r movers
  are the same 10 databases, and the only row changes are the same three rows
  in each mode.
* Controls: 888 compiles over r11u109, r11u106, v11u94, r11u108, v11u108 and
  r11u107 at the base, plus HEAD's r11u110 and v11u110. Pristine vs law: 22
  DIFF, all of them the implementer's named cells (r11u108 f4 c01-c03, c06-c09,
  c11, c12; r11u107 t08, t10). Scored against golden
  (`grid/ctlg`): 0 AWAY. Law vs verified: 888/888 SAME.

## What broke: pristine-wrong -> patched-wrong with AWAY cells

These arms are legal SV with real v1.87 goldens (`grid/brk*`, both forms).
Each one reads CMP_NOTEQUAL on both binaries, but the per-cell scorer found
cells moving AWAY from golden:

1. **Face 3, the dims cell with an inline anonymous enum member**
   (`brk/k/b3b_enum_member`, `brk2/k/m08_body_param_enum`; 20-22 AWAY per form).
   The declaration is `localparam type T = struct packed { enum logic [1:0]
   {A,B,C} e; logic [1:0] b; }; T [1:0] p;`.
   * Golden has `packed_array_var p`, and the law wrote `packed_array_net p`.
   * The cause: the body-parameter disjunct scans OUR resolved struct
     (`typeParamElabTs`), and in it the member `e` is a `logic_typespec`, so
     `structTsIsNetLike` read "net".
   * **Fix (§ tpStructKindNet112's enum fence, `V11U112_ENUMFENCE_OFF`):** decline
     the dims cell when the declared element struct has an enum field (directly
     or under packed dims).
2. **Face 5, property bodies whose shape emitAssertionExpr gets wrong in the
   declaration home** (`brk3/p/b5j`, `brk4/p/q02 q06 q10 q14 q18`; AWAY up to 5
   and MOVED-WRONG up to 6 per form). Inline assertions are no control here,
   because both sides write no body there.
   * `s_eventually`: golden writes no vpiOpType, ours 91.
   * Sequence `or` / `and`: golden 27 / 26, ours 80 / 79.
   * A written leading delay ahead of further elements (`##1 b ##2 c`): golden
     nests it as op53 [1, op54 [b, 2, c]], ours flattens it into op54.
   * **Fix (§ propDeclDisableIffSkip112's operator fence, `V11U112_PROPFENCE_OFF`):**
     a whitelist of the operators measured golden. Unary allows `not`, `always`
     and `s_nexttime` without a range. Binary allows `|->`, `|=>`, `intersect`,
     `throughout` and `within`. A SequenceConcat is declined when its first
     element carries a nonzero delay and more elements follow.

With the fences, every fenced arm is byte-identical to pristine. SequenceInst
and every implementer grid arm are unchanged.

## Measured after the fix

* 218 moved arm-forms over all grids (implementer's 102 arms + 90 verifier arms
  + the 11 control arms), pristine -> verified: TO=4150 AWAY=0 MOVED-WRONG=0
  (`evidence/SCOREV112.pris-vfx2.txt`).
* The kill switches, all 188 arms (`evidence/DROPSV112.txt`):
  * `R11U112_OFF=1` equals pristine on 188/188.
  * Each of the seven `R11U112_*_OFF` switches and the two `V11U112_*_OFF`
    switches changes only its own face's arms.
* Sweeps with the verified binary are identical to the law sweeps, row for row,
  in both corpora and both modes (surelog aside from Earlgrey's dump column and
  the LowMem log path). The surelog byteverify against law sees only the UVM
  coin and Scoreboard/default.

## Residues (the verifier's, ranked)

* **V1: the property declaration home of emitAssertionExpr.** `s_eventually`
  (no opType in golden), sequence `and`/`or` (26/27), nested leading delays and
  ranged repetitions (`b[*1:3]`, `a[*0:2]`, `b[=1:2]`: golden carries a range
  operand that ours lacks). All but the ranged repetitions are fenced. The
  ranged repetitions still move toward golden (0 AWAY) and read SAME-WRONG on
  the range cell.
* **V2: the inline anonymous enum member of a struct typespec** is written as a
  `logic_typespec` (the head of `b3b`/`m08` on both binaries). This is on the
  typespec ground (TypeEmit, fenced).
* **V3, pre-existing on both binaries:** a header `parameter type` defaulted to a
  struct with an inline enum crashes our binary with rc 139 (`brk2/k/m07`).
* **V4:** the package `localparam type` struct (`brk3/k/b3k`) moves under
  `TPNET`, but Surelog v1.87 itself segfaults on it (golden rc 139), so it is
  unscored.
