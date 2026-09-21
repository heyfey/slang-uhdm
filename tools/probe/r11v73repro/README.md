# r11v73 — ADVERSARIAL VERIFICATION OF r11u73, and the three faces it over-fired

Base `71490354`. Worktrees `/tmp/wt_v11u73` (law + fix) and `/tmp/wt_v11u73pris`
(pristine), both at the base, built `-j 2`, md5s taken separately, every
binary frozen `chmod 555` before any sweep.

| binary | md5 | what it is |
|---|---|---|
| pristine | `598195b29a98fb7ee3263d01d53861e6` | the base; byte-identical to the main tree's `build/slang-uhdm` |
| as landed | `f7e288e08efb587e4a2b8c9dcfd11752` | `/tmp/r11u73.patch` applied to a fresh `71490354` |
| verified | `0666658a1ae58470f631f76b409130f0` | the same plus this pass's three fixes and the fence redaction |

The implementer's two headline md5s reproduce EXACTLY.

---

## 1. WHAT REPRODUCES (every headline number, bit for bit)

The twelve committed grid arms, re-run with `run66.sh` against real Surelog
v1.87 (`slrc=0 ourrc=0 slerr=0` on all twelve) and scored with the verifier's
own `ord66v.py`, print the committed `GRID.12arms.txt` LINE FOR LINE:

```
FULL TO=45  ENC TO=13  AWAY=0  MOVED-WRONG=0  STILL=9  WRONG2=9
```

* **Question 1's four witnesses.** `t3_beyond72` `d`/`e` (`2**64`, `2**70`)
  golden `const/64@7=INT:-9223372036854775808`, pristine `INT:0` — R0
  reproduces. `f` (`3**39`) is golden **and pristine** `INT:4052555153018976256`
  at size 64 — **R2 does not reproduce**, and the reason is in the source, not
  in a measurement: `BinaryOperator::Power` has been in `patRedSz68`'s 64 group
  since pass 67 (`/tmp/wt_v11u73pris/src/ParamEmit.cpp:848`). The implementer
  says so and adds no code for LAW B. **Honest.**
* `t7_fence72` `A` (`2**31`) is golden `INT:2147483648` and **pristine equal**
  at this base — r11u72's standing fence witness had already healed. `B`/`C`/`D`
  are golden the artefact with probes **64**; the law converts the value AND
  both probes (3 cells each, 9 FULL TO).
* `v7_decwide72` `A`/`E` golden `op11`/`op13` UNFOLDED; `v4_hop72` `c` golden
  `const/32@7=INT:-5` vs pristine `const/16@7`.
* **The producer decode is correct.** `~/git-repos/UHDM/templates/ExprEval.cpp`
  `:3777` is `val = static_cast<int64_t>(std::pow<int64_t>(val0, val1))` inside
  `if ((invalidValue == false) && (invalidValueI == false))`, with a
  `get_double` / `REAL:` fallback below it; `get_value` (`:1947`) has its
  `vpiDecConst` arm at `:1980` with **no** `VpiSize() > 64` guard, calling
  `NumUtils::parseInt64`, while `vpiBinaryConst` (`:1967`), `vpiHexConst`
  (`:1985`) and `vpiOctConst` (`:1997`) all guard on the declared width and
  `vpiUIntConst` (`:2014`) uses `parseIntLenient`. Verified against the pinned
  tree at `18837c1`.
* **Census** reproduces to the unit: STRICT `INTISH=31 AGREE=31 CANDIDATES 0`,
  LOOSE `INTISH=50 AGREE=37 POW=13 CANDIDATES 5`, `DECWIDE=0 UNTCHAIN=0`,
  r11u72's own scanner unchanged, `--selftest PASS`.
* **Positive control** reproduces on the verified binary too: `cvb_pow`,
  `cvc_unt`, `cve_dec` DIFFER, `cvb_base`, `cvc_base`, `cve_base` read SAME,
  `prc=0 lrc=0` on all six. The census zero is a zero the instrument can see
  through.
* **Wide boundary** reconciles exactly: my list is 1101 arms (the implementer's
  1095 plus the six `cv*` controls) and reads **1082 SAME, 13 DIFFERS, 6 NODB**
  = their 1079 + 3, 10 + 3, 6 + 0.

---

## 2. WHAT DOES NOT SURVIVE: THREE OVER-FIRES AND A FENCE BREACH

The three laws are each right about the cells the implementer built. Each is
also wider than its evidence, and the arms they did not build convict two of
them — LAW C once and LAW D twice — on **legal SystemVerilog with clean
goldens** (`slrc=0 ourrc=0 slerr=0`). Twenty size cells go from RIGHT to WRONG.

### FINDING 1 (severe) — LAW C refuses on a literal the producer folds

`red72WideBasedLeaf`'s new decimal face asks `SVInt::as<uint64_t>() >
INT64_MAX`. `SVInt::as<uint64_t>()` **SIGN-EXTENDS** a signed literal
(`~/.local/include/slang/numeric/SVInt.h:251-267`), so every `W'sd<top bit
set>` — `1'sd1`, `2'sd3`, `4'sd15`, `8'sd200`, `32'sd4294967295` — reads
`0xFFFF…` and the arm REFUSES. The producer reads the `DEC:` **string**, which
carries the digits as WRITTEN. Measured, arm `grid/x7_sdecpos73.sv`:

```
  1'sd1 * 1'sd1                 golden INT:1            (the producer read 1 * 1)
  32'sd4294967295 * same        golden INT:-8589934591  (= (2**32-1)**2 wrapped)
```

so on `CA`, `CC` and `CE` the **pristine binary is byte-equal to golden on all
three cells** and the as-landed binary moves both probes from `const/8` to
`const/64` — the member stamp stops where golden completes:

```
  *** AWAY work@x7_sdecpos73.CA op1  G=const/8@9=UINT:7  P=const/8@9=UINT:7  L=const/64@9=UINT:7
  … CA op2, CB op1/op2, CC op1/op2, CD op1/op2, CE op1/op2
  ARM x7_sdecpos73_ASLANDED FULL TO=2 AWAY=10 MOVED-WRONG=10 STILL=3 SAME=69
```

**TEN AWAY cells, MOVED-WRONG 10.** `x1_sdec73` cannot see this class — there
every cell is already wrong on both binaries, because golden reads the written
magnitude and we sign-extend, and a negative value of ours bails the stamp
anyway. It takes a product of two such leaves, where both readings agree on the
VALUE, to separate the predicate from that residue.

**FIX** (`src/EmitHelpers.h`, § `redDecLeafMagnitudeNotSign73v`): clear the
sign flag before reading the magnitude — `iv.setSigned(false)`. Two lines,
inside LAW C's own new branch, droppable with LAW C.

### FINDING 2 — LAW D mints 32 over a one-bit comparison

`red73MintsUntypedInt` answers TRUE for **any** `BinaryOp`, and the gate
`red72Int64(...) != Refuses` is open on every operator that table does not
model, because it returns `Unknown` there, not `Refuses`. Measured on arms
`grid/x4_cmp73.sv` and `grid/x5_rel73.sv`, an untyped name one and two hops
above its initializer:

```
  ==  !=  <  <=  >  >=      golden const/1@3=BIN:1   (ONE BIT, and a 2-hop chain carries it)
  === !== ==?               golden UNFOLDED (op16 / op17 / op69)
  &&  ||                    golden const/32@9=UINT:0 / UINT:1     MINTED
  ~ ! & >> + cast <<        golden 32                             MINTED
  (16'd9 > 16'd5) << 1      golden const/32@9=UINT:2  — the SHIFT mints over a
                            relational, so only the TOP operator decides
```

The pristine binary reads slang's width — **1**, which is golden's — and the
as-landed binary stamps 32. **Eight size cells from RIGHT to WRONG** (`x4` ops
1-4, `x5` ops 1, 2 and the two-hop `H2`, and `x2_mint73`'s `HEQ`). `ord66v.py`'s FULL tuple hides them, because the
`constType` of those cells is already wrong (`@9 UINT` vs golden `@3 BIN`), so
they land in WRONG2 rather than AWAY — the judge reads every field, so a cell
that was matching on `VpiSize` and stops matching is a loss whatever the other
fields say. The new `sizeaxis.py` scores the size field alone and names them.

**FIX** (`src/EmitHelpers.h`, § `redRelationalMintsOneBit73v`): the `BinaryOp`
case excludes `Equality`, `Inequality`, `CaseEquality`, `CaseInequality`,
`WildcardEquality`, `WildcardInequality`, `GreaterThanEqual`, `GreaterThan`,
`LessThanEqual`, `LessThan` and answers TRUE for the rest. Droppable with
LAW D. Every conversion LAW D earns survives it: `x2`/`x4`/`x5` keep FULL TO=6,
4 and 1 with the fix in.

### FINDING 3 — LAW D mints 32 over a signedness cast

The same `red73MintsUntypedInt` answers TRUE for **every** `Conversion`. One
cast was measured. Arm `grid/x9c_cast73.sv` (`slrc=0 ourrc=0 slerr=0`), an
untyped name one hop above its initializer:

```
  C16 = 16'(5)              golden const/32@9=UINT:5   MINTED   (the measured control)
  CS  = signed'(16'd5)      golden const/16@1=         SIXTEEN BITS
  CU  = unsigned'(16'sd5)   golden const/16@1=         SIXTEEN BITS
  AD  = 16'd9 + 16'd1       golden const/32@7=INT:10   MINTED   (control)
```

A WIDTH cast mints; `signed'` / `unsigned'` keep the operand's width. Pristine
reads 16 — golden's — and the as-landed binary stamps 32: **two more size cells
from RIGHT to WRONG**.

**FIX** (`src/EmitHelpers.h`, § `redSignCastMintsNothing73v`): the `Conversion`
case abstains when the syntax is a `SignedCastExpression`. Droppable with
LAW D.

### FINDING 4 (ops) — the patch spells the four fenced test names

`tools/probe/r11u73repro/evidence/GATES.txt:31` labelled its fence check with
all four slang-fenced test names. That makes RESUME.md §6's own fence gate
score **1 1 1 1** where it must be `0 0 0 0` — the integration cycle stops
there — and `canaudit.sh` reports **FENCE-BREACH=4**, not the `FENCE-BREACH=0`
the report claims. The verified patch rewrites that one line to
`fence check (the four slang-fenced names, unspelled per OPS): 0 0 0 0`;
`canaudit.sh` then reads `audited=29 UNCOVERED=0 FENCE-BREACH=0` and the §6
fence check reads `0 0 0 0`.

---

## 3. WHAT THE FIXES COST: NOTHING THE PASS CLAIMED

Verified binary `0666658a1ae58470f631f76b409130f0`, all twenty arms
(`slrc=0 ourrc=0 slerr=0` on every one):

```
the twelve committed arms   FULL TO=45  ENC TO=13  AWAY=0  MOVED-WRONG=0  STILL=9  WRONG2=9
                            — LINE FOR LINE the as-landed scores
x7_sdecpos73                AWAY 10 -> 0   MOVED-WRONG 10 -> 0
x4 / x5 / x2 / x9c          size-axis AWAY 10 -> 0, every TO kept (4 / 1 / 6 / 2)
SIZE-AXIS over all 20 arms: TO=47  AWAY=0  STILL=53  SAME=1343  WRONG2=1
```

**LAW A survives every break attempt.** `xa_powinf73` grids the faces the
implementer never tested — `2 ** 1000` (`+inf`), `(-2) ** 1001` (`-inf`),
`(-2) ** 1000`, `2 ** -3`, `(-2) ** -3`, `(-1) ** 64`, `9 ** 20`, `(-9) ** 20`
and an in-range control — and the verified binary matches golden on **all
eleven cells**, six of them conversions, `AWAY=0`. The producer's cast writes
`0x8000000000000000` for every infinity too, exactly as the law says.

The only conversion the magnitude fix GIVES UP is `x7` `CG`'s two probe
cells: golden bails there because ITS OWN wrapped product is negative
(`INT:-8589934591`, the `patUvalueRefuses68` ground), not because the leaf
refused, so agreeing with it through a sign-extension bug was an arm agreeing,
not an arm testing.

**Wide boundary, verified binary vs pristine, 1110 arms:**
`1084 SAME, 20 DIFFERS, 6 NODB`. Every DIFFERS is a probe arm carrying a
modelled face (the 13 above plus seven of this pass's own); `x7_sdecpos73` and
`x6b_drop73` read SAME, i.e. byte-identical to pristine. The six NODB are
`prc=3 lrc=3` on both binaries — pre-existing. **No corpus-derived arm differs
on either binary.**

---

## 4. GATES (all on the VERIFIED binary unless stated)

1. **Builds.** pristine `598195b29a98fb7ee3263d01d53861e6`, byte-identical to
   the main tree at `71490354`; as landed `f7e288e08efb587e4a2b8c9dcfd11752`;
   verified `59943d31d379f6f9aa50e3b837431fee`. `-j 2`, md5s separate, frozen.
2. **Goldens.** 23 PASS / 0 FAIL on pristine, as landed and verified;
   `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL.
3. **uhdm2rtlil, both modes.** `788 / 16 / 67` per mode. 1742-row both-mode
   join vs `results/golden_uhdm2rtlil.csv`: **0 differing rows**; vs my own
   pristine sweep: **0**. `ct8rows` PASS, canaries `ok=8 changed=0`, `ctcan2`
   PASS. `byteverify SELFCHECK=1` **MOVERS 0/1608**, selfcheck 1607/1608.
   cmds audit 1742/1742 name the frozen binary, **0** name the main tree.
4. **Surelog, `--mode both`.** `474/9 + 469/8` on pristine, as landed and
   verified. The only rows differing from `results/golden_surelog.csv` on ANY
   binary are environment: Earlgrey_0_1's DUMP COLUMN (status `CMP_EQUAL`
   throughout, and the PRISTINE sweep draws it blank in BOTH modes while the
   as-landed sweep draws it blank in testflags only — a draw, not a binary
   property), and `LowMemLib` / `LowMemPkg` testflags' workdir path strings.
   `byteverify SELFCHECK=1` MOVERS **2/960** as landed and **4/960** verified,
   every one a UVM-family database, attributed ORDER-BLIND to **four** diff
   lines = one `UINT`/`vpiDecompile` line-number pair, or **zero** lines
   (`default/Scoreboard`, the order draw); **zero** `vpiConstType` lines on
   all six.
   COIN POSITIVE CONTROL: the same frozen pristine binary, three runs on the
   MiniAmiq/testflags invocation, three databases (`3bd592f4083d`,
   `8555d65d2b37`, `aeda3d121173`).
5. **Canaries and pins.** Every protected database byte-identical to its pin on
   every binary in both modes: SVSwitch `4842211c4030`, YosysVerx
   `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, BlackParrotComplex
   `e3e354129d5a` / `73a10e8217e5`, YosysOldOr `d68e0796d62c`, Earlgrey_0_1
   `8bdf25272e08` / `59d0ee6d10c3`. UVM family `CMP_EQUAL` as committed.
   `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` after the redaction.
6. **`results/*.csv` untouched.** Fence check `0 0 0 0` after the redaction.

## 5. REPRODUCING

```bash
git worktree add /tmp/wt 71490354 && cd /tmp/wt
git apply -3 /tmp/r11u73.verified.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2 && md5sum build/slang-uhdm      # 0666658a1ae5…
R=$PWD/tools/probe/r11v73repro; G=/tmp/g && mkdir -p $G
cp $R/grid/*.sv $PWD/tools/probe/r11u73repro/grid/*.sv \
   $PWD/tools/probe/r11u72repro/grid/{t3_beyond72,t7_fence72}.sv \
   $PWD/tools/probe/r11v72repro/grid/{v1_uadd72,v4_hop72,v7_decwide72}.sv \
   $R/{run66.sh,shape.py,ord66v.py,sizeaxis.py} $G/
for a in w1_pow73 w2_powbail73 w3_dec73 w4_hop73 w5_fence73 w6_fence64 \
         w7_untw73 t3_beyond72 t7_fence72 v1_uadd72 v4_hop72 v7_decwide72 \
         x1_sdec73 x2_mint73 x3_pow73 x4_cmp73 x5_rel73 x7_sdecpos73 \
         x9c_cast73 xa_powinf73; do
  bash $G/run66.sh $G/$a.sv pris <pristine binary>      # rc for BOTH sides
  bash $G/run66.sh $G/$a.sv ver  $PWD/build/slang-uhdm
  python3 $G/ord66v.py   $G/$a.g.dump $G/$a.pris.dump $G/$a.ver.dump $a
  python3 $G/sizeaxis.py $G/$a.g.dump $G/$a.pris.dump $G/$a.ver.dump $a
done
# to SEE the three over-fires, run the same scorers with the AS-LANDED binary
# in place of the verified one on x7_sdecpos73, x4_cmp73, x5_rel73, x2_mint73
# and x9c_cast73.
```

## 6. RESIDUES THIS PASS FOUND (beyond the implementer's R0-R4)

* **RV-1 — the signed based-decimal VALUE.** Golden reads `W'sd<digits>` by its
  WRITTEN MAGNITUDE and we sign-extend: `8'sd200 + 1` is golden `INT:201` and
  ours `INT:-55`, `4'sd15 - 1` golden `INT:14` and ours `INT:-2`, `32'sd4294967295
  - 1` golden `INT:4294967294` and ours `INT:-2`. Eighteen FULL cells STILL on
  `x1_sdec73`, unchanged by any binary here. Unmodelled, pre-existing, and it
  is the residue that MASKED finding 1 from the implementer's own arm.
* **RV-2 — a DROPPED OPERAND.** `'{… , b: 0 ** -1, …}` emits one operand FEWER
  than golden on BOTH binaries (`x6b_drop73`: golden three, ours two, with a
  `64'sd1 / 64'sd2` control at three on both). A missing operand is a VECTOR
  size mismatch to the judge. Pre-existing, orthogonal to this pass's ground,
  and it is why `x3_pow73`'s ordinals shift by one.
* **RV-3 — `**` over a refusing leaf.** `DU ** 1` and `2 ** DU` with
  `DU = 64'd18446744073709551614` are golden UNFOLDED (`op43`): the producer's
  int branch refuses and its `get_double` fallback refuses too, so it writes no
  constant at all. We fold both. Wrong before and after; LAW C only re-spells
  the digits.
* **RV-4 — LAW A's infinity face is corroborated but unreachable.** `0 ** -1`
  is golden `INT:-9223372036854775808` (`pow` → `+inf` → `cvttsd2si`), exactly
  what LAW A would write — but RV-2 drops that operand before anyone can read
  it.
* **RV-6 — the signedness cast's ENCODING.** Golden writes `signed'(16'd5)` and
  `unsigned'(16'sd5)` as `const/16@1=` — `vpiIntConst` with an EMPTY value
  string — where we write `const/16@9=UINT:5`. The size now matches on both
  binaries; the constType and value do not, on either. Unmodelled, pre-existing.
* **RV-7 — a cast to a user TYPEDEF is rejected by our own front end.**
  `localparam CT = byte_t'(16'd5);` read through a struct-pattern member makes
  the PRISTINE binary exit `rc=4` with `expression kind: Invalid`, and so does
  every binary here. It is why `x9c_cast73` carries only the three casts it
  carries. Golden compiles it (`slrc=0 slerr=0`) and folds it to an `op67`.
  Pre-existing, orthogonal, and it fences a whole cast face from measurement.
* **RV-5 — the rest of LAW D's declined faces** stand as the implementer's R3;
  `x2`/`x4`/`x5` closed `~`, `!`, `&`, `>>`, `^`, `&&`, `||`, the relational
  family, the conditional, the concatenation and a TYPED-arithmetic origin
  (`bit [7:0] TW = 8'd3 + 8'd1` is golden **32** one hop above — the typed
  minting rule generalises past the single `bit [15:0] WD = -16'd5` cell).
