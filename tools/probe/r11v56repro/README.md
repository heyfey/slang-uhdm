# r11v56 — ADVERSARIAL VERIFICATION of § caSubstLeafEncReduceTable56

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's
report reproduces bit-for-bit from binaries built here. The law's three faces
and its base-letter fence are right. **One arm of it was not: the enum arm
answered `vpiIntConst` for EVERY enum member, and that moved three cells from
RIGHT to WRONG on legal SystemVerilog.** The fix is in this patch; a fourth
defect (the census's own positive control printing `FAIL` from the committed
tree) is fixed too.

Base `9fd4d5bc`. Worktrees `/tmp/wt_v11u56` (law) and `/tmp/wt_v11u56pris`
(pristine), scratch `/tmp/v11u56_*`, frozen binaries
`/tmp/v11u56_bin/{pris_3adf163e,law_27341f25,vlaw_a5c8b3e8}.bin`.

---

## 1. REPRODUCTION OF THE IMPLEMENTER'S NUMBERS

| claim | reproduced here |
|---|---|
| pristine md5 `3adf163eba2a507938ba380cad920ccc`, byte-identical to the main tree at the base | YES, md5-for-md5 |
| law md5 `27341f25ee945fa1468fb6cb940ee01a` | YES, the same binary from an independent configure+build |
| goldens `PASS=23 FAIL=0`, `/bin/false` `PASS=0 FAIL=23` | YES |
| `e1` 20/20, `e2` 27/27, `e3` 21/26 (unchanged), `e4` 10/10, `e5` 14/16, `vv3` 5/5, `vv4` 12/12, `vv6` 4/4 | YES, every arm, cell for cell |
| pristine side 48/120, law side 113/120 | YES (48 → 113) |
| `vv6_edge` CONVERTS: `cmp_rc=0 heads=0 cmplines=0`, base `18 lines / 1 head` | YES |
| `e3_base56` and `vv4_singleread` byte-unchanged pristine→law | YES, and so are `vv1a`, `vv1b`, `vv1c`, `vv2`, `vv5`, `vv7`, `vv8`, `vv9` |
| census boundary 23 dirs, 5 candidates `Ariane2024`, `Earlgrey_Verilator_01_05_21`, `Earlgrey_nexysvideo`, `IncompTitan`, `cva6_equiv` | YES, and each candidate's non-comparable status re-read from `results/golden_surelog.csv` (`SLANG_REJECT`/`NO_DATABASE`, `DEFERRED`, `SLANG_REJECT`) and `cva6_equiv`'s absence from both u2r baselines |
| the mutation positive control moves exactly four lines (`UINT:2`→`INT:2`, ct 9→7) | YES, `evidence/POSCTL.census.txt` |
| u2r `MOVERS 0/1608`, `PATH_SETS_IDENTICAL` | YES, against my own pristine workdir |
| `census56.py --selftest` prints `SELFTEST PASS` | **NO — it printed `SELFTEST FAIL`** (§ 3) |

---

## 2. THE DEFECT: A BLANKET `vpiIntConst` FOR EVERY ENUM MEMBER

`caSubstLeafCt56` answered `vpiIntConst` for any `SymbolKind::EnumValue`,
reasoning from `LValue::vpiValType` mapping `Type::Integer` to `vpiIntConst`.
That mapping is real, but the member's `Value::Type` is the one **its own
literal** set, and `Value.cpp:952` also maps `Type::Unsigned` to
`vpiUIntConst` and `Type::Binary` to `vpiBinaryConst`.

Arm [`grid/x2_enum`](grid/x2_enum/dut.sv) grids nine enum-member spellings
plus an implicit member, a wide based-decimal and a NAME-initialised member —
each read exactly once at a 32-bit Lhs. Golden Surelog v1.87 answers:

| enum member's own initializer | golden at the substituted Rhs | pristine | implementer's law |
|---|---|---|---|
| `4'd9` (`od`) | `INT:9` ct 7 | ct 9 ✗ | ct 7 ✓ |
| `16'd40` (`om`) | `INT:40` ct 7 | ct 9 ✗ | ct 7 ✓ |
| `4'sd3` (`os`) | `INT:3` ct 7 | ct 9 ✗ | ct 7 ✓ |
| `-7` on an `int` base (`on_`) | `INT:-7` ct 7 | `UINT:4294967289` ✗ | ct 7 ✓ |
| `K * 2` (`ox`) | `INT:12` ct 7 | ct 9 ✗ | ct 7 ✓ |
| IMPLICIT, no initializer (`oi`) | `INT:2` ct 7 | ct 9 ✗ | ct 7 ✓ |
| **`4'o7` (`oo`)** | **`UINT:7` ct 9** | **ct 9 ✓** | **ct 7 ✗ REGRESSION** |
| **`9`, unsized decimal (`ou`)** | **`UINT:9` ct 9** | **ct 9 ✓** | **ct 7 ✗ REGRESSION** |
| **`R_A = K`, a NAME (`orr`)** | **`UINT:6` ct 9** | **ct 9 ✓** | **ct 7 ✗ REGRESSION** |
| `4'b1001` (`ob`) | `4'b1001` ct 3 @4 | ✗ | ✗ (unchanged class) |
| `4'hC` (`oh`), `16'hCAFE` (`ow`) | `4'hC` / `16'hCAFE` ct 5 | ✗ | ✗ (unchanged class) |

Three cells went pristine-right → law-wrong. That is the landing bar's
`MOVED-WRONG 0`, broken on ordinary SystemVerilog.

**THE FIX** (`src/ModuleEmit.cpp`, inside `caSubstLeafCt56`): an enum member
answers **from its own initializer, through the table the law already calls**.

```cpp
if (auto* ein56 = e.as<ValueExpressionBase>().symbol.getInitializer())
    return dimRedCtExpr79(*ein56, 0);
return vpiIntConst;          // an IMPLICIT member has no literal of its own
```

`dimRedCtExpr79` maps `'d`/`'sd` and every arithmetic arm to `vpiIntConst`,
and `'o`/`'b`/`'h` to their own base constants, an unsized decimal and a NAME
to `vpiUIntConst` — none of which is `vpiIntConst`, so F1 declines and the
pass-54 mint's `vpiUIntConst` stands, which is exactly what golden carries for
the octal, unsized-decimal and NAME forms. Six right cells are kept, three
wrong ones recovered: **`x2_enum` 3 → 6 (3 MOVED-WRONG) → 9 (0 MOVED-WRONG)**.

**THE `'d` FENCE DELIBERATELY DOES NOT REACH THIS ARM, and that is measured.**
§ pkgSubstEncBasedLitAbstain50v abstains because golden re-spells a
based-decimal *parameter* leaf as `DEC:`/ct 1; an enum member's based-decimal
literal is consumed into the stored `Value` and comes back as ct 7 (`od` at 4
bits, `om` at 16). `basedLitOrigin56` only follows `SymbolKind::Parameter`, so
it never sees this arm — the split is intentional and both sides are gridded.

---

## 3. THE SECOND DEFECT: THE POSITIVE CONTROL DID NOT RUN

`census56.py --selftest` called `walk([here])` with `here` = the repro
directory. `walk` scans the CHILDREN of each root, so it saw `evidence/` and
`grid/` as the two "dirs" and never keyed an arm — every arm printed
`classes=-` and the control printed **`SELFTEST FAIL`**, not the `SELFTEST
PASS` the committed `evidence/CENSUS.selftest.txt` shows. A census zero whose
positive control cannot even see the pass's own arms proves nothing.

Fixed to `walk([os.path.join(here, "grid")])`; the control now prints
`SELFTEST PASS` and reproduces the committed evidence file line for line.

**An independent check of the census's coverage claim.** The README calls the
census "a SUPERSET by construction", but `classify()` files every bare NAME
setter as `PLAIN` — while the law DOES fire through a NAME whose parameter
initializer reaches an INT arm (arm `x3_names` cells `o1`, `o2`, `o3`, `o6`,
`o7`). So the boundary census UNDER-approximates for name setters. Re-run with
NAME hops promoted to a firing class
([evidence/CENSUS.namehop.txt](evidence/CENSUS.namehop.txt)): **the same 23
boundary dirs and the same 5 candidates**. The gap is real but inert here, and
`byteverify` is the measurement that decides.

---

## 4. THE ADVERSARIAL GRID — 63 NEW CELLS IN FIVE ARMS

Every arm reads each member EXACTLY ONCE PER INSTANCE (no cross-assign
last-writer confound); `golden_rc` and `ours_rc` are recorded for every arm on
every binary, and no arm's compile fails on either side.

| arm | what it cuts at the law | cells | pris | law | FIXED |
|---|---|---|---|---|---|
| [`x1_optable`](grid/x1_optable/dut.sv) | the reduce-table operators `e1` leaves out: `*`, `/`, `%`, `**`, `>>`, `>>>`, `&`, `|`, `$clog2`, `-(K*2)`, a negative out of a subtract, a ZERO out of an INT arm, `-0`, a 40-bit shift — and the ABSTENTIONS `^`, a comparison, a concat, a ternary, a cast, `~` | 20 | 8 | 16 | **16** |
| [`x2_enum`](grid/x2_enum/dut.sv) | ten enum-member spellings (§ 2) | 12 | 3 | 6 | **9** |
| [`x3_names`](grid/x3_names/dut.sv) | NAMES, not operators: an already-negative parameter, a two-hop chain, a name whose init is `-16'd5`, a signed based decimal, a name reading a name reading `'h`, an 8-bit member, an unsigned 32-bit all-ones, an unsigned subtract | 9 | 2 | 7 | **7** |
| [`x4_nest`](grid/x4_nest/dut.sv) | the NESTED chain and `spsPureDef56`: outer named + inner pure fill, outer pure fill over a nested struct, outer named + inner named with `-1` and an enum | 10 | 1 | 7 | **7** |
| [`x5_scope`](grid/x5_scope/dut.sv) | scopes and overrides: two instances of one definition with DIFFERENT parameter overrides, a module-local `localparam`, an instance inside a generate block | 12 | 2 | 11 | **11** |
| | **new cells** | **63** | **16** | **47** | **50** |

Joined with the implementer's eight arms re-run here:

**183 cells — pristine 64 → implementer's law 160 (3 MOVED-WRONG) → FIXED 163
(0 MOVED-WRONG, 0 AWAY).**

Findings worth naming beyond the enum defect:

* **The operator table transfers cleanly.** `*`, `/`, `%`, `**` are golden ct 7
  and the law gets all four; `>>`, `>>>`, `&`, `|`, `$clog2` and `~` are golden
  ct 9 and the law correctly leaves them alone. `K - K` → `INT:0` and `-0` →
  `INT:0` (not `-0`) are both right.
* **Instance identity holds.** `x5_scope` proves the in-place mutation is safe
  across two instances carrying different overrides, inside a generate block,
  and for a module-local `localparam` — no cell carries another instance's
  value.
* **`x5_scope` `u_c.oe`** is a standing DIFF on both binaries: a module-local
  `localparam`'s enum setter arrives already `vpiIntConst` with decompile
  `4'd9`, so F1 never fires and the spelling stays. Golden says `9`. It is not
  this law's site (the constant was not minted by the pass-54 fold) and it did
  not move.
* **The scorer is blind to a non-`ref_obj` Lhs.** `score56.py` keys cells by
  `LHS=ref_obj(...)`, so `e4_share56`'s part-select and bit-select assigns —
  the very cells residue R2 cites as "the measurement" — are silently dropped
  from its 10-cell tally. I checked them by whole-dump diff instead: they are
  byte-identical pristine vs law, which is what R2 claims, but the CELL TALLY
  never tested it.

**THE WIDE BOUNDARY, at the byte level** ([evidence/ARMBYTES.txt](evidence/ARMBYTES.txt)):
the whole `uhdm-dump` of every arm the law does not claim — `e3_base56` (the
fence) and r11v55's `vv1a_pos`, `vv1b_repl`, `vv1c_cast`, `vv2_chain`,
`vv4_singleread`, `vv5_deepmulti`, `vv7_gensubst`, `vv8_sharemut`,
`vv9_cast2` — is identical pristine vs the fixed binary apart from the dump's
own banner line.

---

## 5. GATES, ON THE SHIPPED BINARY (`a5c8b3e869a33e96fb9bf481ee4eb415`)

Both binaries built here, frozen `chmod 555` before any sweep, every
`cmds.txt` audited by binary PATH (u2r pristine 1742/1742 name
`pris_3adf163e.bin`, u2r law 1742/1742 name `vlaw_a5c8b3e8.bin`, surelog
likewise), every arm's rc recorded.

| gate | result |
|---|---|
| (1) build both, md5 | pristine `3adf163eba2a507938ba380cad920ccc` = main tree at `9fd4d5bc`; shipped law `a5c8b3e869a33e96fb9bf481ee4eb415` |
| (2) goldens | `PASS=23 FAIL=0`; `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| (3) u2r both modes | `785 / 19 / 67` ×2; whole-row PASS vs `results/gate_uhdm2rtlil.csv`, vs `results/golden_uhdm2rtlil.csv` SPLIT BY MODE, and vs my own pristine sweep both modes |
| (4) surelog `--mode both` | `474 / 9` default + `469 / 8` testflags, identical to my pristine control and to `results/golden_surelog.csv` |
| (5) byteverify `SELFCHECK=1` | u2r `MOVERS 0 / 1608`, SELFCHECK `1607 / 1608` flagged, `PATH_SETS_IDENTICAL`; surelog see § 6 |
| canaries / ctcan2 / canaudit | `ok=52` surelog and `ok=8` u2r `changed=0 absent=0`; `ctcan2` PASS ×2; `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` (run with the `r10uvm221repro` generation the brief names) |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`, BlackParrotComplex, YosysOldOr — identical to pristine |
| UVM family + witness | `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM`, `Scoreboard` still `CMP_EQUAL`; `struct_param_pattern_packing`, `packed_struct_array_fifo`, `bits_of_type_param` unchanged |

`results/*.csv` untouched. No corpus row converts, so no baseline row is
promoted. FENCED tests never dispatched.

---

## 6. THE SURELOG MOVERS ARE THE DOCUMENTED COIN

Reproduced with the fixed binary and attributed order-blind (sorted,
workdir-normalised `uhdm-dump`): see `evidence/MOVERS.attribution.txt`.
**POSITIVE CONTROL: the same frozen PRISTINE binary run twice draws different
hashes on the same databases**, so the class is per-invocation
nondeterminism, not the law — and none of the moved lines is an encoding or a
`vpiConstType`, which is what this law's signature looks like (the mutation
control in `evidence/POSCTL.census.txt` shows exactly what the law's own four
lines look like).

---

## 7. RESIDUES, RANKED

* **R0 — the member-width stamp on a based literal** (the implementer's R0,
  unchanged and confirmed): `e3_base56`'s five standing cells, a 16-bit based
  literal on an 8-bit member. `CompileHelper::adjustOpSize`
  (`CompileHelper.cpp:5111`) stamps the member's bits on every operand without
  touching its value. Corpus-invisible by the same census. The next one-liner.
* **R1 — the value half of the unary-minus-through-a-NAME cell.**
  `x3_names` `o3`: `localparam MD = -16'd5`, setter `md: MD`. Golden is
  `INT:-5`; the law now gets the ct right (7) but writes `65531`, because F2's
  else-branch takes slang's own 16-bit unsigned evaluation of the NAME while
  `reduceExpr`'s `vpiMinusOp` arm negates the OPERAND's magnitude one hop
  down. Pristine was `65531` ct 9, so nothing regressed — but the cell is now
  wrong in ONE field instead of two, and the fix is to follow the minus
  through the name hop the way `dimRedCtExpr79` already does.
* **R2 — the census under-approximates NAME setters** (§ 3). Inert today,
  measured; any future use of `census56.py` to predict movers must promote
  `NAMEHOP` to a firing class first.
* **R3 — `score56.py` drops every non-`ref_obj` Lhs cell** (§ 4). The
  select-Lhs cells exist in `e4_share56` but are not scored; residue R2 of the
  implementer's README cites them as a measurement they are not.
* **R4 — the golden EMPTY constant under a pure `default:` fill**
  (the implementer's R1): `e5_deffill56` `o5b`/`o6b`. Unclaimed producer
  class, wrong before and after.
* **R5 — the `32` in F3's pure-fill arm is modelled, not decoded** (the
  implementer's R4): measured on six arms, never varies; the Surelog line that
  stamps it is still unquoted.
* **R6 — the nested pure-`default:` fill through a struct member**
  (`x4_nest` `d1`/`d2`/`d3`): golden plants the fold on the FIRST leaf and
  bare loc-only constants on the rest, we plant it on the last. Present
  identically in pristine and in the law — a pass-54 scoping residue, not
  this law's.

---

## 8. REPRODUCING

```bash
git worktree add /tmp/wt 9fd4d5bc && cd /tmp/wt && git apply -3 /tmp/r11u56.verified.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2
mkdir -p /tmp/g && cp -r tools/probe/r11u56repro/grid/* tools/probe/r11v56repro/grid/* /tmp/g/
cp -r tools/probe/r11v55repro/grid/{vv3_default,vv4_singleread,vv6_edge} /tmp/g/
GRID=/tmp/g bash tools/probe/r11u56repro/run56.sh <binary> <tag>
CAREAD=$PWD/tools/probe/r11u55repro/caread55.py \
  python3 tools/probe/r11u56repro/score56.py /tmp/g/<arm>/gold.<tag>.dump \
                                             /tmp/g/<arm>/ours.<tag>.dump <arm>
python3 tools/probe/r11u56repro/census56.py --selftest   # SELFTEST PASS
```
