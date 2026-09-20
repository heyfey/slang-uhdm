# r11v68 — adversarial verification of r11u68, and TWO FIXES

**VERDICT: ACCEPT-WITH-FIX.** Both of r11u68's laws are correctly decoded and
both land, but each over-fires on a face the implementer's grids do not carry,
and each over-fire is **pristine-right → patched-wrong on legal SV**:

* **LAW B** stamps the member width past a bail. The cont_assign substitution
  is re-materialised by the SAME `expandPatternAssignment`, so the SAME
  `if (invalidValue) return result;` stops the stamp there too. 3 cells on
  arm `ca/v4_cabail68.sv`, 4 more on `ca/v3_lawb68.sv`.
* **LAW A** reads the refusal off a value WE may have wrapped. Our
  `vpiIntConst` arms run at slang's self-determined width; the producer's run
  in `int64_t` and never wrap (r11v66's R-V1, still open). 4 cells on
  **`a7_arith66`, a COMMITTED r11v66 arm the implementer's evidence does not
  list** (their `GRID.a*` files carry a1/a2/a4/a5/a6 only).

Both fixes are one-sided: they only ever DECLINE, so an unproven face falls
back to the pristine behaviour — a STILL cell, never an AWAY one. With them,
**every arm in this pass and every committed arm on this ground reads
AWAY 0 / MOVED-WRONG 0 in all four listings**, and no measured TO cell of
r11u68 is lost.

Base `ff5541cd`. Pins per `SUPPORT_MATRIX.md`. Every golden here is a real
Surelog v1.87 run through `run66.sh`; every arm records `slrc` / `ourrc` /
`slerr` and all of them read `0 0 0`. Three binaries were built in this
verifier's own worktree and frozen `chmod 555` before any sweep:

| binary | md5 | what |
|---|---|---|
| pristine | `82111bbd435be0d05af1580b2222a687` | byte-identical to the main tree at `ff5541cd` |
| r11u68 as submitted | `aedb5d8261aeac22923ad6b48d6325bb` | the implementer's patch, unmodified |
| shipped | `a3c3218c61a86b654659f9a50751d0a0` | + the two fixes below |

---

## 1. LAW B's over-fire — `§ caSubstBailStopsMemberStamp68v`

`ca/v4_cabail68.sv` is two packed structs with the SAME members and the SAME
setters, differing only in WHERE the bailing member sits. Golden, Surelog
v1.87:

```
X1 '{a: 16'd4660, bail: -3, c: 16'd4660, d: UD16, e: 16'd4660}
   a  (before the bail)        golden vpiSize:8    = the MEMBER width
   c  (after)                  golden vpiSize:16   = the LITERAL's own width
   d  (after, through a NAME)  golden vpiSize:16
   e  (after, 24-bit member)   golden vpiSize:16
X2 the identical members, `bail` LAST
   a, c, d  golden vpiSize:8      e  golden vpiSize:24    -- all stamped
```

The pristine binary already reads 16/16/16 on X1's `c`/`d`/`e`; r11u68 reads
8/8/24. `ca/v3_lawb68.sv` reproduces two more behind the same `-3` (`nld`,
`nud`, both `16'd4660` through a NAME on an 8-bit member).

The fix records, per member read, whether the producer's walk PROVABLY reaches
it still stamping: every member declared before it, at every level of a W1/W2
chain, must be set by a setter `caSetterProvenFolds68v` can prove folds — a
based literal whose FIRST digit is valid for its base, an unsized decimal,
`'0`/`'1`, a string of at most 64 characters, or a NAME/enum member bottoming
out at one of those. Everything else is unproven and leaves the pristine
`vpiUIntConst` arm exactly as it stood. `c1_stamp68` keeps all 28 of its TO
cells and `e3_base56` all 4 of its conversions.

The proof set is not guessed: it is the measured refusal boundary. `ltrim` +
`NumUtils::parse*` is `std::from_chars`-shaped and stops at the first bad
character rather than rejecting the string, so `8'hAx` and `8'b1z` COMPLETE
where `8'hxA`, `6'ox7`, `8'bx` and `1'bz` REFUSE — all four measured in
`grid/v1_ofire68.sv` and `grid/v2_align68.sv`.

## 2. LAW A's over-fire — `§ patBailNegCorroborated68v`

`a7_arith66` (committed at `tools/probe/r11v66repro/grid/`, re-run here
unmodified, `slrc=0 ourrc=0 slerr=0`):

```
localparam int BIG = 2000000000;   localparam byte SB = 8'sd100;
'{a: BIG*2, b: BIG+BIG, c: SB*SB, d: SH*SH, e: SB-200, f: K*K}

op0 a  BIG*2   golden INT:4000000000 @32   ours INT:-294967296 @32
op1 b  BIG+BIG golden UINT:4000000000 @64  pristine @64   r11u68 @32   AWAY
op2 c  SB*SB   golden INT:10000 @32        pristine @32   r11u68 @64   AWAY
op3 d  SH*SH   golden INT:900000000 @32    pristine @32   r11u68 @64   AWAY
op4 e  SB-200  golden INT:-100 @32         -- golden's OWN bail
op5 f  K*K     golden INT:36 @64           pristine @32   r11u68 @64   TO
```

`get_uvalue` refuses an integer arm whose string starts with a minus
(`parseUint64` is `from_chars` into an UNSIGNED). `patUvalueRefuses68` reads
that off OUR operand — and ours wrapped where the producer's, run in `int64_t`
(`ExprEval.cpp:3443`, `:3479`), did not. So r11u68 bails at operand 0 where
golden walks on to operand 4, and the four operands between them take
`patRedSz68`'s answer where golden stamped the member width.

The fix corroborates: the LEADING-MINUS face of the refusal fires only when
`patInt64Val68v` — the same `int64_t` table over the setter — is also
negative. Anything it cannot answer abstains. The other refusal faces (a
non-constant, an unknown leading digit, an unfolded operator, `vpiRealConst`)
are properties of the OBJECT's shape, not of a value we might have wrapped,
and are untouched. `x1_optable`, `g3_neg66` and `v9` keep every TO cell.

## 3. The arms

* `grid/v1_ofire68.sv` — LAW A OVER-FIRE HUNT. 28 rows: operand 0 is the
  candidate, operands 1–2 a control `K+1` on 8-bit members, so golden's
  control size reads the refusal directly (8 = completed, 64 = bailed) with
  `plain: 3` as the no-bail positive control. Candidates the implementer's
  `b1`/`b2`/`b3` do not carry: a package-qualified param ref, a 96-bit param,
  `$bits`, `$high`, a 2-arg and a vector-returning constant function call,
  `-1`, `K << 2`, `KU <<< 2`, `8'shF0`, `4'sb1011`, `8'sd200`, a 9-character
  string, `1'bz`, `8'hxA`, `8'hAx`, `6'ox7`, `70'h5`, `96'b1`, `65'd1`, a
  64-bit all-ones decimal, plus five known-bail controls. **18 TO, 0 AWAY.**
  It also settles R2 independently: `70'h5`, `96'b1`, `65'd1` and
  `64'd18446744073709551615` all COMPLETE, so the `VpiSize() > 64` clause does
  not key on the literal's declared width. Two STILL residues: `$high` (golden
  keeps the `sys_func_call`) and a named-type cast (golden keeps `op67`) —
  both under-fires, both safe.
* `grid/v2_align68.sv` — LAW A OPERAND-INDEX ALIGNMENT. 15 rows: `'x`/`'z` in
  the MIDDLE with and without a bail before it, `8'b1z` behind a valid digit, a
  nested pattern at member 1 with operands after, a packed-array member, a
  `default:` fill interleaved with named setters, a bail at the LAST operand,
  two bails, a post-bail string, a post-bail size table (`4'd3`, `96'h1`, a
  name, `KU+1`, `-K`), and a no-bail positive control. **33 TO, 0 AWAY.**
  `opSet68`'s flush-the-previous-setter pairing holds on every one.
* `ca/v3_lawb68.sv` — LAW B's uncovered faces: `'1`/`'0`, an unsized decimal,
  an expression, a concatenation, a string, an enum member, a negative, a
  LOGIC-typed name, and four Lhs shapes where `caLhsAdjustBind106` fails
  (bit-select, part-select, indexed part-select, unpacked-array element).
* `ca/v4_cabail68.sv` — the bail at the cont_assign site, §1 above.

## 4. Gates, on the SHIPPED binary

* goldens **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**
* u2r both modes **787 / 17 / 67**; whole-row `ct8rows.sh` PASS against
  `gate_uhdm2rtlil.csv`, against `golden_uhdm2rtlil.csv` (both modes joined)
  and against my own pristine sweep, in both modes; `byteverify SELFCHECK=1`
  **MOVERS 0 / 1608**, selfcheck sights 1607/1608; canaries `ok=8 changed=0`,
  `ctcan2.sh` PASS
* surelog both modes **474/9 + 469/8**, the committed baseline to the row
* every one of the 1742 + 1742 + 960 `cmds.txt` files names the frozen binary
  by absolute path
* **POSITIVE CONTROL** (`runpair.sh`, path-neutral — the output CWD is embedded
  in the database, so a two-directory pairing reads DIFFERS on everything and
  proves nothing): pristine-vs-pristine SAME, pristine-vs-shipped differs on
  21 of 36 arms. The corpus reading of zero is a measurement.
* **WIDE BOUNDARY** (`evidence/BOUNDARY.allarms.txt`): all 36 arms of this pass
  and of r11u56 / r11v55 / r11u66 / r11v66, scored in ALL FOUR listings, read
  **AWAY 0 / MOVED-WRONG 0**. `vv4_singleread` and `vv6_edge` databases are
  byte-identical to pristine.

## 5. Residues the verification adds

* **RV0** — `$high`/`$size`/`$low` and the named-type cast are golden bails the
  AST predicate does not name; both under-fire (STILL, never AWAY).
  `grid/v1_ofire68.sv` `syshigh` and `tcast` are the standing cells.
* **RV1** — the `default:`-sourced operand's POST-BAIL size is the reduce's 64,
  not `defaultPatternAssignment`'s 32: `grid/v2_align68.sv` `C9` op1/op3 are
  golden `UINT:9` at **64**, ours at 8. r11u68's `default:` fence abstains on
  them, which is right at the `e5_deffill56` site and over-broad here. Two
  cells.
* **RV2** — a packed-array member is ONE flat constant for us and an `op75` for
  golden (`v2_align68` `C7`/`C8` op1). A shape residue, older than this pass.
* **RV3** — LAW A's proven-fold set and LAW B's are now two predicates with the
  same measured boundary in two files. They should merge once r11v66's R-V1
  (whose arithmetic) closes, because the corroboration is what keeps them
  apart.
