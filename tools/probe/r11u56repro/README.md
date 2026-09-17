# r11u56 — § caSubstLeafEncReduceTable56

**THE CONSTANT SUBSTITUTED AT AN ELABORATED `cont_assign` Rhs CARRIES THE
PRODUCER'S OWN ENCODING — `ExprEval::reduceExpr`'S OPERATOR TABLE FOR THE
PATTERN ELEMENT, THE STORED `Value`'S `vpiValType()` FOR AN ENUM MEMBER, AND
`adjustUnsized` FOR AN UNBASED-UNSIZED FILL — NOT ONE SYNTHETIC `UINT:` PER
FOLDED VALUE.**

Base `9fd4d5bc`. One law at the pass-54 mint site, three faces, one fence.
**120 grid cells, pristine 48 right → law 113 right, +65, 0 MOVED-WRONG, 0
AWAY. Corpus movement ZERO, predicted by name before the sweeps and proved
sighted by a positive control.** This is CORRECTNESS GROUNDWORK: no corpus row
is at the head of this defect today.

---

## 1. THE THREE RESIDUES, RE-MEASURED AT THE BASE

r11v55's R1/R2/R3 reproduce bit-for-bit with the frozen pristine binary
(`md5 3adf163eba2a507938ba380cad920ccc`, byte-identical to the main tree at
`9fd4d5bc`), Surelog v1.87 golden, one head per run (`grep -c '^LHS:'` = 1):

| residue | arm / cell | golden | pristine |
|---|---|---|---|
| **R1** `default: '1` | `vv3_default` `o_8`/`o_16`/`o_32` | `UINT:4294967295 vpiSize:32 ct 9` (all three) | `'1 vpiSize:-1 ct 3` |
| **R2** `s: -1` onto `logic signed [31:0]` | `vv3_default` `o_s` | `vpiDecompile:-1 vpiSize:32 ct 7` | `4294967295 vpiSize:32 ct 9` |
| **R3** `ev: E_B` | `vv6_edge` `o_ev` | `9 vpiSize:32 ct 7` | `9 vpiSize:32 ct 9` |

`vv4_singleread` (the `adjustSize` table with the sharing confound removed) is
**12/12 identical at the base and 12/12 after the law** — the encoding change
composes with W3 rather than fighting it, which was caution (e) of the brief.

---

## 2. THE PRODUCER, DECODED (pinned sources)

`UhdmWriter::writeCont_assign` (`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:2245`)
reduces the Rhs and re-sizes the product with `CompileHelper::adjustSize`
(`CompileHelper.cpp:4065`). For a dotted read off a struct parameter the reduce
lands in `ExprEval::hierarchicalSelector`
(`~/git-repos/UHDM/templates/ExprEval.cpp:3014`), whose `uhdmtagged_pattern` arm
returns `reduceExpr` of **the element itself** — so the encoding question is
"what did the producer already stamp on that element?", and the answer is
readable directly in golden's `uhdmtopModules` listing, where the elaborated
parameter's value is a POSITIONAL `vpiAssignmentPatternOp` (`vpiOpType:75`) of
already-encoded operands. Measured, grid `e1_enc56` (the operand, then the
final cont_assign Rhs at a 32-bit Lhs):

| setter | elaborated operand | final Rhs | where the encoding comes from |
|---|---|---|---|
| `3` | `UINT:3` @32 | `UINT:3` @32 | `compileConst`'s unsized arm, `CompileExpression.cpp:557` |
| `-1` | `INT:-1` @32 | `INT:-1` @32 | `reduceExpr`'s `vpiMinusOp` arm, `ExprEval.cpp:3407-3424`, `INT:<-val0>` |
| `-K` | `INT:-6` @32 | `INT:-6` @32 | same arm, operand magnitude negated |
| `K + 1` | `UINT:7` @64 | `UINT:7` @32 | the `+` arm, neither operand signed-ish |
| `K - 1` | `INT:5` @64 | `INT:5` @32 | the `-` arm: `vpiIntConst` **even for a positive result** |
| `KU << 1` | `UINT:12` @64 | `UINT:12` @32 | the shift arm |
| `E_B` (`= 4'd9`) | `INT:9` @4 | `INT:9` @32 | the stored `Value`: `LValue::vpiValType` maps `Type::Integer` to `vpiIntConst` (`Surelog/src/Expression/Value.cpp:952`) — but the `Value::Type` is the one the member's OWN literal set, so `4'o7` and an unsized `9` come back `vpiUIntConst` and a NAME-initialised member likewise (r11v56 arm `x2_enum`; the enum arm reads the initializer, it does not answer `INT` blindly) |
| `'1` (32-bit member) | `UINT:4294967295` @32 | same | `adjustUnsized(cop, <member bits>)` then the member width (`CompileHelper.cpp:5111`) |
| `'1` (8-bit member) | `UINT:255` @8 | `UINT:255` @32 | same, at the MEMBER's width |
| `'0` / `'x` (named) | `UINT:0` @32 | `UINT:0` @32 | the value store loses the unknowns |
| `16'hBEEF` | `HEX:BEEF` @16 | `HEX` @32 | the base letter, `CompileExpression.cpp:508-565` |
| `16'b…` | `BIN` @16 | `BIN` @16 | `adjustSize` shrinks BINARY only |
| `16'd4660` | `DEC:4660` @16 | `DEC` @16 | `adjustSize` never re-sizes `vpiDecConst` |
| `-16'd5` | `INT:-5` @16 | `INT:-5` @32 | the minus arm OVERRIDES the base letter |

So `ct 7` is the reduce table's `vpiIntConst` (and the stored `Value`'s), `ct 9`
is its `vpiUIntConst`, and `ct 3`/`ct 5`/`ct 4`/`ct 1` are the literal's own base
letter — **the same table § pkgSubstEncIsReduceTable50 transcribed one site
over, which is why this law CALLS `dimRedCtExpr79` instead of copying it.**

---

## 3. THE LAW

`caSubstLeafCt56` ([src/ModuleEmit.cpp](../../../src/ModuleEmit.cpp), beside
`patMemberSetter55`) answers the `vpiConstType` the producer would carry, or 0
to abstain, and the pass-54 mint site reads it:

* **F1 — the constant type.** A constant WE encoded in decimal (`vpiUIntConst`)
  is re-spelled `vpiIntConst` when the table says so.  An ENUM MEMBER answers
  from ITS OWN INITIALIZER through that same table (r11v56 corrected a blanket
  `vpiIntConst` here that moved `4'o7`, an unsized `9` and a NAME-initialised
  member from RIGHT to WRONG); an implicit member, which has no literal, is
  `vpiIntConst`. A constant `emitExpr`
  carried through with a base letter is never touched, so the Hex/Bin/Oct/Dec
  cells cannot move by construction.
* **F2 — the value's sign.** A unary `-` writes `-<operand magnitude>`
  (`reduceExpr`'s own arithmetic: `-16'd5` is `-5`, not `65531`); every other
  `vpiIntConst` answer writes the setter's own signed value — `K - 1` is `5`
  and `E_B` is `9`, NOT the 4-bit two's-complement reading `-7`.
* **F3 — the unbased-unsized leaf, and its TWO producers.**
  A NAMED setter comes back through the value store: `UINT:<mask(member
  width)>` for `'1`, `UINT:0` for `'0`/`'x`/`'z`, at the member's width (a
  >64-bit member keeps the store's saturated 64-bit all-ones at its own width).
  A PURE `'{default: X}` fill (a pattern with no member setter at all) is a
  different producer: ONE object stamped by `adjustUnsized` at the **32-bit
  default width**, never the member's — `'1` is `UINT:4294967295` whatever the
  member is, `'0`/`'x` keep `BIN` untouched, and only the SIZE follows the
  member. Both then meet W3's Lhs-level `adjustSize` unchanged.
* **THE FENCE — the `'d` abstention.** `basedLitOrigin56` is
  § pkgSubstEncBasedLitAbstain50v's refusal transcribed at this site: a based
  literal at the bottom of the derivation (through bare NAME hops) abstains,
  `'d` included, because golden answers a THIRD encoding (`DEC:`/ct 1) there and
  this decimal-digit writer cannot spell it.

No line of behaviour is removed; the diff is 199 added lines across
`src/ModuleEmit.cpp` and `include/UhdmExporter.h` and **zero deletions**.

---

## 4. THE GOLDEN GRID (5 new arms + the 3 re-run, every arm's rc recorded)

Every arm compiles clean on both sides (`surelog rc=0`, 0 `[ERR`, ours `rc=0`);
each member is read EXACTLY ONCE PER INSTANCE so no cell measures golden's
cross-assign last writer instead of the law.

| arm | what it cuts | cells | pristine right | law right |
|---|---|---|---|---|
| `e1_enc56` | 20 setter KINDS at one 32-bit Lhs: plain, `-1` on a signed and on an UNSIGNED member, unary `-` over a name, `+`, `-`, `<<`, enum, `'1`/`'0`/`'x`, all four base letters, a NAME reading a `'d` and a `'h` literal, `-16'd5`, an 8-bit member | 20 | 10 | **20** |
| `e2_width56` | the three faces × member width (8/32/64/96) × Lhs width (narrow/equal/wide), `'z` included | 27 | 0 | **27** |
| `e3_base56` | THE FENCE: h/b/o/d, the `'s` forms, a NAME reading each, at shrinking and widening Lhs | 26 | 21 | 21 |
| `e4_share56` | mutation safety: one member read by THREE assigns of one instance, a SECOND instance, a part-select and a bit-select Lhs | 10 | 0 | **10** |
| `e5_deffill56` | which member sizes a `default:` fill: last vs widest vs a named/default mix, `default: '0`, `default: -1`, `default: 'x`, a 96-bit member | 16 | 1 | **14** |
| `vv3_default` (r11v55) | R1 + R2 | 5 | 1 | **5** |
| `vv4_singleread` (r11v55) | the `adjustSize` table | 12 | 12 | 12 |
| `vv6_edge` (r11v55) | R3, a 96-bit member, an X/Z literal | 4 | 3 | **4** |
| **TOTAL** | | **120** | **48** | **113** |

**+65 cells, 0 MOVED-WRONG, 0 AWAY** (scored per cell, both binaries, at
[evidence/GRID.*.txt](evidence/)). `vv6_edge` now CONVERTS outright
(`uhdm-cmp` rc=0, heads=0, 0 cmp lines, where the base had 18 lines / 1 head);
`vv4_singleread` stays converted.

The `e3` fence, proved at the BYTE level and not only per cell: the whole
`uhdm-dump` of `e3_base56` — and of `vv4_singleread` — is **identical between
the pristine and the law binary apart from the dump's own file-name banner
line**. The base letters and the `adjustSize` table are untouched. `e3`'s 5
standing DIFF cells are a DIFFERENT residue (§ 6 R0) that predates this law.

---

## 5. CENSUS, PREDICTION, GATES

### The a-priori mover prediction, and its positive control

[census56.py](census56.py) walks both corpora, keeps § caStructParamPatternSubst55's
own boundary (a `cont_assign` whose Rhs is a dotted read off a user-typed
parameter declared in the same directory — 23 directories) and classifies every
pattern setter it finds as UNSIZED / INTISH / ENUMNAME (the law can fire) or
BASED / PLAIN (it abstains). It is a SUPERSET by construction: it never asks
whether the classified member is the one read.

*Positive control:* `--selftest` runs it over this pass's own grid, where the
setter kinds are known cell by cell, and asserts `e1`/`e2`/`e4` carry the firing
classes and that `e3_base56` — the fence arm — carries **BASED/PLAIN only**.
Prints `SELFTEST PASS` ([evidence/CENSUS.selftest.txt](evidence/CENSUS.selftest.txt)).
(r11v56: as first committed the selftest pointed `walk` at the repro directory
instead of `grid/`, so it saw no arm and printed `SELFTEST FAIL`; the one-line
path fix is in this patch.  It also UNDER-approximates for a bare NAME setter,
which `classify` files as `PLAIN` although the law fires through a name whose
parameter initializer reaches an INT arm — re-run with NAME hops promoted, the
boundary and the five candidates are unchanged.)

*Predicted before the sweeps:* 23 boundary directories, of which **5 CANDIDATE**
— `Ariane2024`, `Earlgrey_Verilator_01_05_21`, `Earlgrey_nexysvideo`,
`IncompTitan` (surelog third_party) and `cva6_equiv` (uhdm2rtlil, not a
discovered test). **Every other boundary directory is abstain-only, the pass-54
witness `struct_param_pattern_packing` (BASED,PLAIN) among them — so its
conversion was predicted to STAY, and it did.**
[evidence/CENSUS.boundary.txt](evidence/CENSUS.boundary.txt).

*Why the five candidates cannot move a comparable row* (read off the committed
baselines before the sweeps): `Ariane2024` is `SLANG_REJECT`/`NO_DATABASE`,
`IncompTitan` is `SLANG_REJECT` both modes, `Earlgrey_Verilator_01_05_21` and
`Earlgrey_nexysvideo` are `DEFERRED` both modes, and `cva6_equiv` is not a
discovered uhdm2rtlil test (no row in `results/golden_uhdm2rtlil.csv`).

*Measured:* **u2r `MOVERS 0 / 1608`. surelog `MOVERS 4 / 960` — `MiniAmiq` and
`SeqDriver`, both modes, all four the documented per-invocation UVM coin.**
Each of the four is a FOUR-LINE order-blind diff (sorted `uhdm-dump`, workdir
normalised) of ONE `UINT:`/`vpiDecompile` **line-number** pair — `1278`↔`784`,
`0`↔`1322`, `582`↔`727`, `0`↔`1477` — never an encoding and never a
`vpiConstType`, which is what this law's own signature looks like. **POSITIVE
CONTROL: the SAME frozen pristine binary, run a second time, draws a THIRD hash
on every one of the four.** All five UVM rows stay `CMP_EQUAL` and rowheads
reads `0 lines 0 heads` for the whole family.
[evidence/MOVERS.attribution.txt](evidence/MOVERS.attribution.txt).

**So the law moves ZERO corpus bytes** outside the nondeterministic class.

*The zero is SIGHTED, not blind* ([evidence/POSCTL.census.txt](evidence/POSCTL.census.txt)):
the witness test's own sources, UNMODIFIED, give one md5 from both binaries
(`31e6f3db6a47946df29217108142f5b7`); the SAME sources with one setter changed
to an INT-answering subtract (`n: 3 - 1`) give two different databases whose
order-blind, workdir-normalised dump diff is exactly the law's own four lines
(`UINT:2` → `INT:2`, `vpiConstType:9` → `vpiConstType:7`).

### The gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `3adf163eba2a507938ba380cad920ccc` = the main tree at the base, byte-identical; law `27341f25ee945fa1468fb6cb940ee01a` |
| (2) goldens | `PASS=23 FAIL=0`; `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| (3) u2r both modes | `785 CMP_EQUAL / 19 CMP_NOTEQUAL / 67 SLANG_REJECT` ×2, every row byte-identical to `results/gate_uhdm2rtlil.csv`, to `results/golden_uhdm2rtlil.csv` (both modes) and to my own pristine sweep |
| (4) surelog `--mode both` | `474/9` default + `469/8` testflags, status histograms identical to `results/golden_surelog.csv`; the only differing row-sides are the two `SURELOG_FAIL` detail strings that quote the WORKDIR PATH (`LowMemLib`, `LowMemPkg`), which differ between the committed baseline and my own PRISTINE control in exactly the same way |
| (5) byteverify SELFCHECK=1 | u2r `MOVERS 0/1608`, SELFCHECK `1607/1608` flagged; surelog `MOVERS 4/960`, SELFCHECK `959/960` flagged; `PATH_SETS_IDENTICAL` both |
| canaries | `ok=52 changed=0 absent=0` (surelog), `ok=8 changed=0 absent=0` (u2r); `ctcan2` PASS ×2; `canaudit` PASS |
| rowheads | the UVM family, Earlgrey_0_1 and Rggen unchanged |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 default `8bdf25272e08` / testflags `59d0ee6d10c3`, BlackParrotComplex, YosysOldOr — every one identical to pristine |
| UVM family | BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard all still `CMP_EQUAL` |

`results/*.csv` untouched. **No row converts, so no baseline row is promoted.**
Every `cmds.txt` was audited by binary PATH; every arm's rc recorded.

---

## 6. RESIDUES, and R0

* **R0 — THE MEMBER-WIDTH STAMP ON A BASED LITERAL.** `e3_base56`'s five
  standing cells, unchanged by this law and unchanged since the base: a 16-bit
  based literal on an **8-bit member** is golden `16'b1010010111000011` at
  `vpiSize:8` and `16'd4660` at `vpiSize:8`, where we keep the literal's own 16
  (or shrink the BINARY value to the Lhs). `CompileHelper::adjustOpSize`
  (`CompileHelper.cpp:5111`) stamps `cop->VpiSize(<member bits>)` on EVERY
  operand without touching its value, and we model only the Lhs-level
  `adjustSize`. It is the fourth face of the same site, it needs no new decode
  (the producer line is quoted above), and it is the next one-liner in the
  chain. Corpus-invisible today by the same census.
* **R1 — the golden EMPTY constant under a pure `default:` fill.**
  `e5_deffill56` `o5b`/`o6b`: for `'{default: -1}` and `'{default: 'x}` the
  NARROW member's elaborated read is a constant with NO value fields at all
  (the bare loc-only class § memberSelLitLhs already models elsewhere), while
  the 32-bit member's read is a full `INT:-1` / `'X`. Both cells were wrong
  before this law and are wrong after; the law moves `o5b` from `UINT:4294967295`
  to `INT:-1` inside an already-not-equal cell of a producer class it does not
  claim.
* **R2 — the non-plain-Lhs unbased-unsized cell.** F3 is gated on
  `spsMemberTy55`, which the pristine one-level arm leaves null when the Lhs is
  a select, so `'1` keeps `vpiSize:-1` there. Golden's ELABORATOR still sizes
  the operand (its Lhs-level `adjustSize` is what returns early), so the cell is
  golden-sized and ours is not. `e4_share56`'s part-select and bit-select cells
  are the measurement; widening F3 to that arm means widening pass 54's own Lhs
  fence, which has no corpus site.
* **R3 — the positional pattern form** (r11v55 R4, unchanged): golden folds
  `'{3, 16'hBEEF}` and the predicate tests `StructuredAssignmentPattern` only.
* **R4 — which member sizes a pure `default:` fill is modelled, not decoded.**
  The 32 in F3's default arm is measured on six arms (`e5` s1 `32/8`, s2
  `8/64/16`, s7 `96/8`, `vv3` `8/16/32`) and never varies, which is consistent
  with `defaultPatternAssignment` stamping at the default integer width; the
  Surelog line that does it is not quoted here.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wt 9fd4d5bc && cd /tmp/wt && git apply -3 /tmp/r11u56.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2
mkdir -p /tmp/g && cp -r tools/probe/r11u56repro/grid/* /tmp/g/
cp -r tools/probe/r11v55repro/grid/{vv3_default,vv4_singleread,vv6_edge} /tmp/g/
GRID=/tmp/g bash tools/probe/r11u56repro/run56.sh <binary> <tag>      # rc for BOTH sides
python3 tools/probe/r11u56repro/score56.py /tmp/g/<arm>/gold.<tag>.dump \
                                           /tmp/g/<arm>/ours.<tag>.dump <arm>
python3 tools/probe/r11u56repro/census56.py --selftest    # the positive control
python3 tools/probe/r11u56repro/census56.py               # the boundary + candidates
```

`run56.sh` drives Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog` with
`uhdm-dump` / `uhdm-cmp` from `~/git-repos/UHDM/build/bin`; `score56.py` reads
the ELAB cont_assign cells through `r11u55repro/caread55.py`, which exits 4 on a
dump that yields no cont_assign at all — a reader that reaches nothing can never
read as agreement.

---

## 8. VERIFIER (r11v56)

`tools/probe/r11v56repro/README.md` carries the adversarial verification: the
enum-arm fix and the census positive-control fix that are in this patch, five
new arms (63 cells: the rest of the operator table, ten enum spellings, name
derivations, the nested chain, instance/generate/module-local scopes), and the
gates re-run end to end on the shipped binary.  **183 cells total: pristine 64
-> this patch 163, 0 MOVED-WRONG, 0 AWAY.**
