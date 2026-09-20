# r11v72 — ADVERSARIAL VERIFICATION of r11u72, and § redWideLeafPositionNotDepth72v

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's
report reproduces bit-for-bit from my own build. Breaking the laws found ONE
pristine-right → patched-wrong class on legal SV — a wide-declared parameter
NAME sitting AT operand 0 — which is fixed here in one predicate argument and
gated through the full battery. Ship `/tmp/r11u72.verified.patch`.

Base `9637b9fd`, pins per `SUPPORT_MATRIX.md`. Every golden below is a real
Surelog v1.87 run through the committed `run66.sh`; every arm records
`slrc` / `ourrc` / `slerr` and every arm scored reads `0 0 0`.

| binary | md5 | what |
|---|---|---|
| pristine | `d7d16dbc92e585c323223489a790ad76` | my own build at `9637b9fd` — byte-identical to the main tree |
| law | `8794860fd835afa68733006ee62a7438` | the implementer's patch, rebuilt by me — md5 matches their claim exactly |
| verified | `5e22824a8872e046a35c523ce51cf127` | the law + § redWideLeafPositionNotDepth72v |

All three frozen `chmod 555` before any sweep; every `cmds.txt` audited by
absolute binary path: 1742 per u2r sweep (all three name their own frozen
binary) and 1581 per surelog sweep (1530/1531 name their own frozen binary,
the rest are rows where Surelog failed and slang never ran). **0** name the
main tree in any of the six sweeps.

---

## 1. WHAT REPRODUCED (bit-for-bit)

* **Both md5s**, from my own worktrees and my own `cmake -j 2` builds.
* **Q1 heads.** `a2_uwrap66` golden `[INT:-2@32, INT:-2@64 ×4, INT:6@64,
  INT:-2@64]` against pristine `[4294967294@32, 4294967294@32, 4294967294@8,
  0@64, -2@32, 6@64, 0@64]`; `a7_arith66` `BIG * 2` golden `INT:4000000000@32`,
  pristine `INT:-294967296@32`, law golden's — the one regressed-field cell
  heals.
* **The grid.** 18 arms (the 7 new `t*` arms plus `a2 a4 a6 a7 a8 b2_faces68
  b3_ops68 g3_neg66 v1_ofire68 x1_optable x3_names`), scored by the committed
  `ord66v.py`: **FULL TO 51, ENC TO 31, AWAY 0, MOVED-WRONG 0, WRONG2 1** —
  the claimed totals to the unit, with the same single `WRONG2` (`a4_wide66`
  op1's size).
* **The producer's arms.** `ExprEval.cpp` `:3301` `+` (signed arm), `:3415`
  unary `-`, `:3454` `-`, `:3490` `*`, `:3726` `%`, `:3782` `**`, `:3822` `/`
  — all `int64_t`, all writing `INT:` + `VpiDecompile`. Read line by line in
  the pinned tree; the beyond-int64 measurements (`2**64` and `2**70` golden
  `INT:-9223372036854775808`, `3**39` golden the double-rounded
  `4052555153018976256`, `HUGE*4` golden `INT:-2446744073709551616`) all
  confirmed against my own goldens.
* **The cont_assign road.** `t1_arith72` and `t2_leaf72` are identical to
  golden line for line on the law binary (0 diff lines, against 20 and 14 on
  pristine); `g3_neg66 o12` golden `5` / pristine `-18446744073709551611` /
  law `5`; `a6_misc66 y7` golden `3` / pristine `-18446744073709551613` / law
  `3`; `a8_real66 y1` golden `1099511627776` / pristine `0` / law golden's.
* **The census.** `census72.py --selftest` PASS; STRICT `INTISH=31
  AGREE=20 OVF=2 WRAP=9`, 5 candidates; LOOSE `INTISH=50 AGREE=21 OVF=17
  WRAP=12`, 12 candidates — the same test names, `NAMEHOP=0 WIDE=0`.
* **Gates.** Goldens `23/0` on all three binaries, `/bin/false` `0/23`. u2r
  both modes `788/16/67`, 1742-row join against `results/golden_uhdm2rtlil.csv`
  = 0 differing rows. Surelog `--mode both` `474/9` + `469/8`. byteverify
  u2r `MOVERS 0/1608` (selfcheck 1607/1608).

---

## 2. THE BREAK — § redWideLeafPositionNotDepth72v

`red72WideBasedLeaf` carries TWO measured rules: **inside an arm** the leaf's
DECLARED width decides (`t6_wide72`), **at the operand itself** its VALUE does
(r11u68 `b2_faces68`). The law selects between them with `depth > 0`. A NAME
sitting at operand 0 is hopped into its initializer at depth 1, so the leaf
gets the DECLARED-width rule while it is standing at the operand — and bails
where golden completes.

Arm [`grid/v6_wname32.sv`](grid/v6_wname32.sv), real Surelog v1.87 golden,
operand 0 a bare name, `K+1`/`K+2` probes on 8-bit members (8 = the walk
stamped, 64 = it bailed):

```
  operand 0                                   golden  pristine  law  verified
  W96H  logic [95:0] = 96'h1                    8        8       64    8
  W96B  logic [95:0] = 96'b1                    8        8       64    8
  W71H  logic [70:0] = 71'h5                    8        8       64    8
  W96X  logic [95:0] = 96'h123456789ABCDEF0…   64       8        64   64
  96'b1 / 96'h1 (literals, the b2 control)      8        8        8    8
```

**Six pristine-right → patched-wrong cells** (three structs × two probes) on
the law binary; `W96X` is the value-rule cell and is a correct TO on both.

**The fix**, `src/EmitHelpers.h`: `inArm` becomes an explicit position
argument instead of the recursion depth — descending into a binary or unary
operand sets it, a NAME hop PROPAGATES it. One defaulted parameter, four
recursive call sites, one predicate argument. Nothing else in the patch moved.

**The fix is surgical, measured:** the verified binary's databases are
BYTE-IDENTICAL to the law's on all 18 committed/new grid arms and on 4 of my 6
break arms, and differ only on the two arms that contain a wide-declared NAME
at operand 0. The 18-arm grid re-scores identically on the verified binary
(FULL TO 51, ENC TO 31, AWAY 0, MOVED-WRONG 0, WRONG2 1).

---

## 3. THE OTHER FIVE BREAK ARMS (all AWAY 0)

| arm | the face it attacks | result |
|---|---|---|
| `v1_uadd72` | the `+` arm's UNSIGNED half (`ExprEval.cpp:3267-3296`), which `red72Int64` does not model | fenced by the landed `caSubstLeafCt56 == vpiIntConst` gate; AWAY 0. Golden leaves `DU+1`, `DU+DU`, `DU-1` UNFOLDED (a beyond-int64 DEC leaf refuses) — wrong→wrong, 3 cells |
| `v2_usz72` | § redUntypedIntNameSz72's "32" measured on only `-8'd3` / `-4'd3` | the rule HOLDS wider than claimed: `-64'd3`, `-40'd3`, `-32'd3`, `-3`, `-8'h3`, `-(8'd3+1)` and `signed`-implicit are ALL golden 32; 7 more TO cells, AWAY 0 |
| `v4_hop72` | the NAME hop and its modulo-width guard: truncating declarations, two-hop chains, enum members, and an OVERRIDDEN parameter | AWAY 0; the override case CONVERTS (`#(.P(2000000000*2))` golden `INT:4000000000`, pristine `INT:-294967296`). One `WRONG2`: a name reached through ANOTHER name (`HOP2 = HOP1 = MD`) keeps slang's 16 against golden's 32 — the size rule does not follow a name chain |
| `v7_decwide72` | the RANGE-STRICT decimal leaf (`parseInt64`, `:1978`/`:2008`), which has no size guard and no face in the table | AWAY 0. Golden REFUSES (`op11` / `op13` survive) where the table answers `Value`; wrong→wrong, 2 cells. A missed refusal can only leave the pristine bail standing, never move one |
| `v3_wname72` | the same wide NAME with a **96-bit member** | golden bails on EVERY struct including the control — `expandPatternAssignment`'s `if (shift >= 64) return result` (`CompileHelper.cpp:5432`) stops the walk at any >64-bit member. AWAY 0; the law's agreement there was accidental and the fix turns 6 accidental TO cells into honest STILL ones |

`v5` (INT64_MIN `/ -1`) is **not a golden**: Surelog v1.87 itself dies with
`rc=136` (SIGFPE) on it — and so does the PRISTINE binary, while the law and
the verified binary survive, because `red72Int64` guards `INT64_MIN / -1`
where `patInt64Val68v` did not. An incidental robustness gain, not claimed.

---

## 4. GATES ON THE VERIFIED BINARY

1. Built `-j 2` in its own worktree at `9637b9fd`, md5 taken separately,
   frozen before any sweep.
2. Goldens `23 PASS / 0 FAIL`; `SLANG_UHDM=/bin/false` `0 PASS / 23 FAIL`.
3. uhdm2rtlil both modes `788 / 16 / 67`; the 1742-row join against
   `results/golden_uhdm2rtlil.csv` and against my own pristine sweep:
   **0 differing rows**. byteverify vs pristine **MOVERS 0 / 1608**
   (selfcheck 1607/1608), and vs the law binary 0/1608.
4. Surelog `--mode both` `474 CMP_EQUAL / 9 CMP_NOTEQUAL` default,
   `469 / 8` testflags, bucket for bucket against the committed baseline.
   FOUR rows differ from it and all four are environment: `Earlgrey_0_1`
   default AND testflags dump column `differ` → blank (the documented
   uhdm-dump timeout draw; STATUS `CMP_EQUAL` in both modes on all three
   binaries), and `LowMemLib` / `LowMemPkg` testflags `SURELOG_FAIL` detail
   strings carrying the workdir path. The LAW and PRISTINE sweeps, which ran
   concurrently with a sister pass's sweeps, additionally drew
   `YosysOpenSparc,default` `SLANG_REJECT` → `SURELOG_FAIL` — on BOTH of
   them, and NOT on the verified sweep: a golden-side draw under memory
   pressure, not a binary's doing. The law-vs-pristine whole-row join over
   all 1596 rows differs on exactly the two `LowMem*` workdir strings.
5. byteverify surelog vs pristine: `PATH_SETS_IDENTICAL (960 paths)`,
   **MOVERS 6 / 960** (selfcheck 959/960), every one of them the UVM family
   and the documented coin, attributed order-blind (workdir-normalised,
   sorted dumps): `Scoreboard/default` **0** substantive lines;
   `MiniAmiq` ×2, `SeqDriver` ×2 and `SimpleUVM/default` one `UINT` /
   `vpiDecompile` LINE-NUMBER pair each; and **not one `vpiConstType` line**
   anywhere — which is what this law's signature would have to contain,
   since it writes `VpiConstType`, `VpiValue` and `VpiDecompile` together.
   POSITIVE CONTROL: the same frozen pristine binary on `MiniAmiq/default`'s
   own command line, three runs, three distinct hashes (`15cdd33c6d68`,
   `d1dc57cc3d97`, `4302707f753c`).
6. Canaries: `ok=50 changed=2` (both changes the Earlgrey dump column, on
   pristine too) + `ok=8 changed=0`; both `ctcan2.sh` PASS; `canaudit.sh`
   `audited=29 UNCOVERED=0 FENCE-BREACH=0`. Every protected database on its
   pin and identical on all binaries in both modes: SVSwitch `4842211c4030`,
   YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1
   `8bdf25272e08` / `59d0ee6d10c3`, BlackParrotComplex `e3e354129d5a` /
   `73a10e8217e5`, YosysOldOr `d68e0796d62c`. UVM family all `CMP_EQUAL`
   (Scoreboard/testflags `SLANG_REJECT`) as committed.
7. **The wide boundary, re-run pristine vs VERIFIED over 1070 committed
   pattern-carrying arms** ([evidence/BOUNDARY.1070arms.txt](evidence/BOUNDARY.1070arms.txt)):
   **1049 SAME, 15 DIFFERS, 6 NODB** (`prc=lrc=3` both sides). The 15 are the
   7 `r11u72` grid arms and the 8 earlier-pass arms the implementer named —
   every one of them scored against a real golden above with AWAY 0.
8. `results/*.csv` untouched; fence check `0 0 0 0`.

---

## 5. RESIDUES, RANKED

* **RV-1 (was the implementer's R0).** The `**` arm past int64: golden writes
  the `static_cast` artefact `INT:-9223372036854775808`, the table abstains.
  Confirmed on `t3_beyond72` `d`/`e`, STILL. Closing it retires the
  corroboration fence (their R1), which I agree should be KEPT until then: it
  only ever DECLINES a bail.
* **RV-2 — the range-strict DECIMAL leaf has no face.** `get_value` refuses a
  `DEC:`/`INT:` operand beyond int64 (`parseInt64`), with no size guard;
  golden leaves the operation unfolded. `v7_decwide72` `A`/`E` and
  `v1_uadd72` `b`/`c`/`f` measure it. Wrong→wrong today because our walk has
  already folded, but it is the same shape as the wide-leaf face and belongs
  beside it.
* **RV-3 — the untyped-minus size rule does not follow a NAME chain.**
  `v4_hop72` `c` (`HOP2 = HOP1 = MD`, `MD = -16'd5`) is golden 32 and ours 16;
  the value converts, the size does not. One cell, the same family as
  § redUntypedIntNameSz72.
* **RV-4 — the >64-bit member stops the producer's walk entirely.**
  `CompileHelper.cpp:5432` `if (shift < 0 || shift >= 64) return result;`
  means any member wider than 64 bits bails the whole pattern before the
  reduce is consulted. `v3_wname72` measures it on eight structs. This is the
  implementer's R3 with a cited mechanism.
* **RV-5 — the `+` arm's unsigned half is unmodelled in the value table.**
  Harmless today because the encoding gate fences it, but the table and the
  gate now disagree about one arm, and a future widening of the gate would
  expose it (`v1_uadd72`).
