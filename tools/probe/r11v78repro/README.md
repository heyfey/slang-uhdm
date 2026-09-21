# r11v78 — ADVERSARIAL VERIFICATION of r11u78, and one fix

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of r11u78 reproduces
bit-for-bit in this verifier's own worktrees, and the four laws plus R1 move
only TO golden on 33 arms. One defect found and fixed here:
§ caSubstLeafCtSeesParens78 reaches a road the pass did not census —
`pkgSubstIntEnc50` (`src/TypeEmit.cpp:700`) — where the landed abstention
`§ pkgSubstEncBasedLitAbstain50v`'s own guard `basedLitOrigin50` is STILL
paren-blind, and four cells move WRONG→WRONG in a shape that landed law
exists to refuse. `§ pkgSubstAbstainSeesParens78v` restores the fence's shape
under parentheses and keeps every conversion.

Base `7d0c7bf4`, pins per `SUPPORT_MATRIX.md`. Every golden here is a real
Surelog v1.87 run through the committed `run66.sh`; **all 33 arms × 3 binaries
read `slrc=0 ourrc=0 slerr=0`**.

| binary | md5 | what |
|---|---|---|
| pristine | `963667a2299a360105d9677e3a065959` | built in `/tmp/wt_v11u78pris` at `7d0c7bf4` — **byte-identical to the main tree's `build/slang-uhdm`** |
| law | `11d069db9ddbeff921367ab3b426b853` | `/tmp/r11u78.patch` as submitted — **the implementer's md5 reproduced exactly** |
| verified | `a1304be10090119c2c6beafc61c81c92` | law + `§ pkgSubstAbstainSeesParens78v` |

All three frozen `chmod 555` before any sweep; every `cmds.txt` audited by
absolute path (1742 u2r + 1531 surelog per binary, **0 naming the main tree**).

---

## 1. THE PRODUCER, RE-DECODED FROM THE PINNED SOURCES

Every citation in the implementer's §2 is correct, and two of them are
stronger than claimed.

* **`>>>` and `>>` are ONE body** —
  `~/git-repos/UHDM/templates/ExprEval.cpp:3149-3171`:
  `uint64_t val = ((uint64_t)val0) >> ((uint64_t)val1);` then `UINT:` at
  `VpiSize(64)`, `vpiUIntConst`. `<<`/`<<<` mirror it at `:3236-3255`. **No
  sign fill on either path.** The `if (c->VpiSize() == -1) invalidValue` bail
  on arg0 is at `:3157`.
* **The cast's typespec** — `:4700-4711` mints a signed `logic_typespec`
  behind a `ref_typespec` parented to the constant, **only when
  `!c->Typespec()`**, then `return c`; `$unsigned` over a non-negative
  Int/Dec `return c` at `:4716` with the argument's own typespec untouched.
* **AND WHOSE TYPESPEC THE ARGUMENT CARRIES IS SETTLED IN SURELOG, NOT
  INFERRED FROM A DUMP.** `~/git-repos/Surelog/src/DesignCompile/
  CompileExpression.cpp:514-521`:
  ```cpp
  if (isSigned) {                       // value.find_first_of("sS") != npos
    int_typespec *tps = s.MakeInt_typespec();
    tps->VpiSigned(true);
    ref_typespec *const rt = s.MakeRef_typespec();
    rt->VpiParent(c);  c->Typespec(rt);  rt->Actual_typespec(tps);
  }
  ```
  This matters because **`uhdm-dump` does not print `vpiSigned` under an
  `int_typespec` on this visitor path** — golden's `int K` typespec prints no
  children either — so the lister renders golden's and ours identically
  whatever the field holds, while `int_typespec::Compare`
  (`~/git-repos/UHDM/build/generated/src/int_typespec.cpp`) READS
  `Cast_to_expr`, `VpiSigned` and `Ranges`. The source settles it: golden's
  field is `true`, `§ castOperandCarriesItsTypespec78` writes `true`, neither
  sets `Cast_to_expr` or `Ranges`, and the ref_typespec carries no
  `VpiName`/`VpiDefName` on either side. **The law's mint is field-for-field
  the producer's.**
* **Parentheses** — `~/git-repos/slang/source/ast/Expression.cpp:791-799`
  recurses into the inner syntax and `:1002` then OVERWRITES
  `result->syntax = &syntax` with the parenthesized node. Confirmed verbatim.

---

## 2. THE HEADLINE NUMBERS, REPRODUCED

| claim | implementer | this verifier |
|---|---|---|
| pristine md5 | `963667a2299a…` | **same**, and byte-identical to the main tree |
| law md5 | `11d069db9ddb…` | **same** |
| goldens law / pristine / `/bin/false` | 23·0 / 23·0 / 0·23 | **same** |
| u2r both modes, both binaries | 788 / 16 / 67 | **same** |
| u2r row joins (committed, own pristine, tf gate) | PASS | **PASS ×3** |
| u2r byteverify | MOVERS 0 / 1608 | **0 / 1608**, selfcheck 1607/1608 |
| surelog `--mode both`, both binaries | 474·9 + 469·8 | **same** |
| surelog law vs own pristine | only the two `LowMem*` workdir paths | **same** |
| surelog verified vs the COMMITTED CSV | — | **only those two rows — every status AND every dump column identical, histograms to the unit** |
| census STRICT | AGREE 4392, PAREN78 39, SCAST 21, SHIFT78 1503, UNSARM78 0, 13 candidates | **identical to the unit**, LOOSE 4613 likewise; selftest PASS |
| every SHIFT78 occurrence a LEFT shift | claimed | **measured: 0 of 1503 lines contain `>>`** |
| TSCAST78 | (not printed) | **0 occurrences in either corpus** |
| wide boundary | 16 DIFFERS | **2298 arms: 2267 SAME, 16 DIFFERS, 15 NODB — the same sixteen** |
| `l154_noenum` layout proof | LAYOUTPROOF OK | **OK on this binary pair**, tail delta `23179289→23183385` = exactly 4096 |
| protected DB pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey `8bdf25272e08`/`59d0ee6d10c3` | **all SAME, all exactly those values** |
| conversion rows | 0 cmp lines / 0 heads | **12 measured 0/0, Rggen/default 64/1** |
| grid, the implementer's 25 arms | TO 71 AWAY 0 WRONG2 2 | **TO 71 AWAY 0 WRONG2 2, arm for arm** |

Two draw-level differences, both environment and both present on the
PRISTINE sweep:

* surelog byteverify reads **MOVERS 4 / 960** here where the pass read 5 — the
  UVM coin, different names on a different draw (§ 4).
* `Earlgrey_0_1`'s dump COLUMN reads blank in **both** modes on the two
  `--jobs 3` draws — the law sweep AND the PRISTINE one alike (the pass saw
  testflags only). Re-run at `--jobs 2` it reads `differ`, the committed
  value, and the whole-CSV diff falls to the two `LowMem*` rows. It is a
  `uhdm-dump` TIMEOUT under load: the status was `CMP_EQUAL` on every draw
  and the **DATABASE byte-compare — the actual pin — never moved**.

### The instrument

`ts78.py` is the committed DEC-aware `shape.py` plus one field. Verified by
running both over six goldens and stripping the `/ts=` token: **character-
identical**. `shape.py` and `sizeaxis.py` in the pass directory are
byte-identical to the committed `r11u76repro` generation, as are
`bnd72.sh`, `byteverify.sh`, `canaries.sh`, `canaudit.sh`, `caread55.py`,
`ct8rows.sh`, `ctcan2.sh`, `list76.py`, `ord66v.py`, `rowheads.sh`,
`run66.sh`.

**THE SCORER'S OWN POSITIVE CONTROL.** `score78.py`'s AWAY bucket was proved
to fire: scoring `z4_shift78` and `w1_ts78v` with the two binaries SWAPPED
turns every one of their 25 TO cells into an AWAY cell and TO to 0. `AWAY=0`
below is therefore a measurement, not a blind spot.

---

## 3. BREAKING THE LAWS — FIVE VERIFIER ARMS

`w1`–`w3` attack faces the pass's own grid does not reach; `w4`–`w5` attack
the ROADS the pass's census did not scan. Scored on the judge's fields plus
the value byte, on the FINAL binary:

```
  w1_ts78v         TO=8  AWAY=0 STILL=4 WRONG2=1 EQ=95
  w2_shift78v      TO=11 AWAY=0 STILL=0 WRONG2=0 EQ=170
  w3_uns78v        TO=4  AWAY=0 STILL=2 WRONG2=0 EQ=218
  w4_parenroad78v  TO=0  AWAY=0 STILL=0 WRONG2=0 EQ=82
  w5_contparen78v  TO=1  AWAY=0 STILL=0 WRONG2=0 EQ=29
```

SIZE axis over every law arm (`sizeaxis.py`, the field the value scorer
cannot see): **TO 12, AWAY 0, WRONG2 0.**

### w1 — LAW A's faces the pass did not write
| written | golden | pristine | law | |
|---|---|---|---|---|
| `$signed(16'sd5)` (system-call spelling) | `int_typespec` | none | `int_typespec` | **TO** |
| `signed'((8'sd200))` PARENTHESISED argument | `const/8` `int_typespec` | `const/24` none | `const/8` `int_typespec` | **TO** (size and typespec) |
| `signed'(8'sd2_00)` UNDERSCORED digits | `const/8` `int_typespec` | `const/24` none | `const/8` `int_typespec` | **TO** |
| `unsigned'(3'so7)` | `OCT:7` `int_typespec` | none | `int_typespec` | **TO** |
| `$unsigned(16'd5)` | a ref_typespec with **no actual** | none | none | STILL (declined — R1) |
| `signed'(signed'(8'sd200))` NESTED | `const/8@1=DEC:200` | `const/24@9=UINT:16777160` | unchanged | STILL |
| `signed'(16'sh1F)` (the mint face) | `const/32@7=INT:31` | `const/16@9=UINT:31` | unchanged | STILL |
| `signed'('sd5)` UNSIZED | `const/-1@1=DEC:5` | `const/32@9=UINT:5` | unchanged | STILL |
| `16'sd5` / `8'sd200` VERBATIM controls | `int_typespec` | **`int_typespec`** | same | EQ on BOTH binaries — the positive control for the minted object's shape |

### w2 — LAW D's boundary, and the host mask is real
```
  8'sd200 >>> 63   golden UINT:0        ours 18446744073709551615  -> 0        TO
  8'sd200 >>> 64   golden UINT:200      (count & 63 == 0)          -> 200      TO
  8'sd200 >>> 65   golden UINT:100                                 -> 100      TO
  8'sd200 <<  64   golden UINT:200                                 -> 200      TO
  8'sd200 >>> (K-7)  count -1 -> &63 = 63,  golden UINT:0          -> 0        TO
  8'sd200 >>> 8'sd200  count 200 -> &63 = 8, golden UINT:0         -> 0        TO
  8'sd200 >>> 4'd2 (a BASED count)      golden UINT:50             -> 50       TO
  (8'sd200 >>> 1) >>> 1                 golden UINT:50             -> 50       TO
  8'sd200 >>> 1 + 1  (precedence)       golden UINT:50             -> 50       TO
  -8'sd100 >>> 1   golden UINT:9223372036854775758                 -> exact    TO
  4'hF0 >>> 2      golden UINT:60       ours 0                     -> 60       TO
  8'hAx >>> 1      the UNKNOWN-digit operand DROP, 3 golden operands against
                   our 2 on BOTH binaries (R4, unchanged)
  KU << 1, K >>> 1   name-only CONTROLS, EQ on both binaries
```
`red78ShiftCount`'s `& 63` is confirmed on four separate counts, including a
NEGATIVE one, against real v1.87 goldens.

### w3 — LAW C's fence and LAW E's depth
```
  2'b111 - 1 / 2'b111 - 8   the producer's SubOp mints INT: at 64
                            (ExprEval.cpp:3443-3459) -> the table answers
                            vpiIntConst -> the else-if never fires     EQ
  8'sd200 + 1               a vpiDecConst operand makes the add SIGNED
                            (:3268-3279) -> vpiIntConst                EQ
  4'hFF & 1, 4'hFF | 1      the table ABSTAINS                         EQ
  64'hFFFFFFFFFFFFFFFF + 1 / + 2   the int64/uint64 boundary           EQ
  PA + 1  (ONE name hop to 4'hFF)   golden UINT:256  ours 16    -> 256 TO
  PB + 1  (TWO name hops)           golden UINT:256  ours 16    -> 256 TO
  (4'hFF) + 1                       golden UINT:256             -> 256 TO
  ((8'sd200)) + 1  DOUBLE paren     golden const/64@7=INT:201
                                    ours @9 UINT:18446744073709551561 -> @7 INT:201  TO
  (K) + 1 (paren on a NAME), ('1) + 1 (unbased unsized), (8'sd200 + 1)
                                    all EQ — the paren walk refuses what the
                                    syntax table refuses
```

---

## 4. THE FIX — § pkgSubstAbstainSeesParens78v

`§ caSubstLeafCtSeesParens78` changes `dimRedCtExpr79`, and that function is
**not only the pattern operand's encoding classifier**. It is also read by
`caSubstLeafCt56` (`src/ModuleEmit.cpp:27760`, the cont_assign / gen-scope
substitution) and by `pkgSubstIntEnc50` (`src/TypeEmit.cpp:700`, the package
parameter substitution). The pass's census scans PATTERN spans only, so
neither road was predicted. Both were measured here.

**The cont_assign road is a clean win** (`w5_contparen78v`): `(16'd4660) + 1`
is golden `const/32@7=INT:4661`, pristine `@9 UINT:4661`, law `@7 INT:4661` —
converting on all three of its sites (the pattern operand, the module-level
`assign`, and the one inside `if (1) begin : gblk`). The BARE parenthesised
literals beside it do not move on this road at all, because the emitted rhs is
the literal's own constant and both writers require a minted `vpiUIntConst`.

**The package road is not.** `pkgSubstIntEnc50` asks `basedLitOrigin50`
(`src/TypeEmit.cpp:673`) "does this initializer bottom out at a based
literal?" and abstains when it does — that is the landed
`§ pkgSubstEncBasedLitAbstain50v`. **That guard still reads
`e.syntax->kind == IntegerVectorExpression` directly**, so it does not
recognise a parenthesised literal, and the two walks are now out of step in
opposite directions. Measured, `w4_parenroad78v`, the `logic [P-1:0]`
dimension operands (real Surelog v1.87, `slrc=0 ourrc=0 slerr=0`):

```
  parameter                    golden       pristine     law          FIXED
  P_DEC   = 32'd40   control   DEC:40 ct1   UINT:40 ct9  UINT:40 ct9  UINT:40 ct9
  P_PDEC  = (32'd40)           DEC:40 ct1   UINT:40 ct9  INT:40  ct7  UINT:40 ct9
  P_PPDEC = ((32'd40))         DEC:40 ct1   UINT:40 ct9  INT:40  ct7  UINT:40 ct9
  P_PSDEC = (32'sd40)          DEC:40 ct1   UINT:40 ct9  INT:40  ct7  UINT:40 ct9
  P_REFP  = P_PDEC  (a NAME)   DEC:40 ct1   UINT:40 ct9  INT:40  ct7  UINT:40 ct9
  P_PHEX  = (32'h28)           HEX:28 ct5   UINT:40 ct9  UINT:40 ct9  UINT:40 ct9
  P_PARM  = (32'd32) + 8       INT:40 ct7   UINT:40 ct9  INT:40  ct7  INT:40  ct7
  P_NMUL  = A32 * 2  control   INT:64 ct7   INT:64  ct7  INT:64  ct7  INT:64  ct7
```

Four cells, eight bytes each, moving from one non-golden reading to another —
which is word for word what `§ pkgSubstEncBasedLitAbstain50v`'s own § block
says about this shape before refusing to move it: *"Every one of the six is
wrong on both sides, so no cell regresses — but the flip moves four bytes per
cell that NO golden licenses, in a shape the law's own fence claims it leaves
alone."*

**The fix** reads the literal in `basedLitOrigin50` through the same committed
paren-walking `red76VecSyntax` the table now uses. Three lines. It withdraws
exactly those four moves and **keeps every conversion**: `P_PARM` is a
`BinaryOp` at the top, which this walk does not answer at all, so it still
reaches the table and still converts (column FIXED above), and `w5`'s three
cont_assign sites are byte-identical between the law and the fixed binary.

It is corpus-invisible today (no committed probe arm and no corpus test
writes a parenthesised based literal as a package-parameter initializer —
which is why the pass's own 2161-arm boundary was green), and it is droppable
alone.

---

## 5. GATES ON THE FIXED BINARY

1. `-j 2` in this verifier's own worktree, md5 taken separately, frozen
   `chmod 555`; every `cmds.txt` audited by absolute path, 0 name the main
   tree.
2. Goldens **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0 / 23**.
3. u2r both modes **788 / 16 / 67**; the 1742-row both-mode join against
   `results/golden_uhdm2rtlil.csv` **PASS**, against this verifier's own
   pristine sweep **PASS**, tf gate **PASS**; byteverify **MOVERS 0 / 1608**,
   selfcheck 1607/1608.
4. Surelog `--mode both` **474 / 9 + 469 / 8**; the verified binary against the
   COMMITTED `results/golden_surelog.csv` differs in **exactly two rows**, both
   the `LowMem*` workdir-path detail — every status and every dump column
   identical, dump histograms `324 / 248 differ / 226 match` and
   `329 / 303 / 166` to the unit.
5. byteverify surelog **MOVERS 4 / 960**, selfcheck 959/960 — all four the UVM
   coin, attributed ORDER-BLIND: `MiniAmiq` ×2 and `SeqDriver` move exactly
   **4 sorted lines**, each a `UINT`/`vpiDecompile` PAIR holding a LINE NUMBER
   (`0↔1214`, `692↔1490`, `0↔790`), and `Scoreboard/default` moves **0 sorted
   lines** — the pure ORDER draw. **Zero `vpiConstType`, zero `vpiSize`, zero
   `vpiTypespec` lines.**
   **COIN POSITIVE CONTROL**: the PRISTINE binary alone, three runs of
   MiniAmiq/default in ONE directory writing ONE name, gives two distinct
   databases (`839f925090c5`, `c1709eb4e1c5` ×2), and the order-blind diff of
   the two different ones is the SAME 4-line `UINT`/`vpiDecompile`
   line-number class (`765 ↔ 0`).
6. Canaries `ok=52 changed=0` on the verified binary's `--jobs 2` sweep
   (`ok=50 changed=2` on the law AND the pristine `--jobs 3` draws alike —
   the same two rows, `Earlgrey_0_1`'s dump column); u2r `ok=8 changed=0`; `ctcan2.sh`
   PASS on both corpora; `canaudit.sh` PASS (`audited=29 UNCOVERED=0
   FENCE-BREACH=0`). Every protected database byte-identical between binaries
   at the committed md5s.
7. The seven conversion rows read **0 cmp lines / 0 heads** on the official
   `uhdm-cmp` with golden as LHS; Rggen/default unchanged 64/1.
8. Wide boundary over **2298 arms** (a superset of the pass's 2161):
   **2267 SAME, 16 DIFFERS, 15 NODB** — fifteen law-owned arms scored above
   with AWAY 0, and the sixteenth the committed layout proof, whose own
   `layoutproof154.sh` reads `JUDGE-VISIBLE HEAD IDENTICAL` /
   `LAYOUTPROOF OK` on this binary pair. Every NODB arm has prc == lrc.
9. `results/*.csv` untouched; fence check 0 hits for all four fenced names.

---

## 6. RESIDUES THIS VERIFIER ADDS

* **RV-1 — `basedLitOrigin56` is still paren-blind** (`src/ModuleEmit.cpp:
  27535`), the twin of the guard fixed here. It is harmless TODAY, measured:
  a bare parenthesised based literal never reaches either value writer
  because the emitted rhs is the literal's own constant, not a minted
  `vpiUIntConst` (`w5_contparen78v` `pdc`/`ppdc`/`psdc`/`ph`, EQ on all three
  binaries). Left alone on minimality grounds; it becomes live the moment a
  law mints a UINT for that shape.
* **RV-2 — the a-priori census scans PATTERN spans only.** `dimRedCtExpr79`
  is read by three roads and the census population covers one. The prediction
  held because `byteverify` covers every database on every road, but a future
  paren/encoding law should widen the population or say out loud that
  byteverify is the whole of the prediction's proof.
* **RV-3 — `uhdm-dump` does not print `vpiSigned` under an `int_typespec` on
  the constant-operand visitor path**, while `int_typespec::Compare` reads it.
  Any future typespec law scored from a dump alone is scoring blind on that
  field; settle it from `CompileExpression.cpp` as § 1 does here.
* The pass's own R0 (the hop parameter's typespec), R1–R7 stand as written;
  each was re-read here and none is contradicted.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp 7d0c7bf4 && git worktree add /tmp/wtl 7d0c7bf4
(cd /tmp/wtl && git apply -3 /tmp/r11u78.verified.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm
done            # 963667a2299a…  and  a1304be10090…
G=/tmp/g78v && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u78repro/*.py $R/r11u78repro/*.sh $G/
cp $R/r11v78repro/grid/*.sv $R/r11u78repro/grid/*.sv $R/r11u76repro/grid/*.sv \
   $R/r11v76repro/grid/*.sv $G/grid/
cp $R/r11v73repro/grid/{x1_sdec73,x7_sdecpos73,x9c_cast73}.sv $G/grid/
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm
  bash $G/run66.sh $G/grid/$a.sv law  /tmp/wtl/build/slang-uhdm
done
python3 $G/score78.py $G/grid pris law          # TO 94 AWAY 0 WRONG2 3
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  python3 $G/sizeaxis.py $G/grid/$a.{g,pris,law}.dump $a; done   # AWAY 0
# the scorer's own positive control (TO must become AWAY):
cp $G/grid/z4_shift78.law.dump $G/grid/z4_shift78.swapA.dump
cp $G/grid/z4_shift78.pris.dump $G/grid/z4_shift78.swapB.dump
python3 $G/score78.py $G/grid swapA swapB
```

---

## 8. THE COIN, ACROSS FOUR DRAWS

The surelog byteverify mover COUNT is itself a draw. Measured here on one
machine, one afternoon, the same three binaries:

```
  law      vs pristine   MOVERS 4 / 960   MiniAmiq ×2, SeqDriver, Scoreboard
  verified vs pristine   MOVERS 6 / 960   MiniAmiq ×2, SeqDriver ×2, SimpleUVM,
                                          Scoreboard
  verified vs pristine   MOVERS 3 / 960   (a SECOND sweep of the same binary)
                                          MiniAmiq ×2, SeqDriver
  the pass's own report  MOVERS 5 / 960
```

Every mover in every draw is 4 sorted lines (one `UINT`/`vpiDecompile` PAIR
holding a LINE NUMBER) or 0 sorted lines. **Zero `vpiConstType`, zero
`vpiSize`, zero `vpiTypespec` lines in 13 movers across four draws.** In the
second verified sweep `MiniAmiq/default` landed on `27419f6011b4` — the very
hash the LAW binary produced in the first draw — which is the coin's small
face-pool showing itself. And the pristine binary alone, three runs of
MiniAmiq's own invocation in one directory writing one name, gives two
distinct databases whose order-blind diff is the same 4-line class. A mover
COUNT is therefore not a number to reproduce; the CLASS is.
