# r11v50 — the ADVERSARIAL VERIFICATION of r11u50 (§ pkgSubstEncIsReduceTable50)

**VERDICT: ACCEPT-WITH-FIX.** The law is right, decoded from the right
producer, and every headline number reproduces bit-for-bit on binaries this
verifier built itself. One fence the pass CLAIMS it holds does not hold: the
`'d` base letter. `§ pkgSubstEncBasedLitAbstain50v` closes it, costs none of
the pass's thirteen conversions, and ships as `/tmp/r11u50.verified.patch`.

Base `70f84b03`. Worktrees `/tmp/wt_v11u50` (law + fix) and `/tmp/wt_v11u50pris`
(pristine). Binaries frozen at `/tmp/v11u50_{pris,law,fix}.bin` before any
sweep; every `cmds.txt` audited by binary PATH.

---

## 1. THE HEADLINE NUMBERS, REPRODUCED

| claim | reproduced |
|---|---|
| pristine md5 `acbe2f0ed8915eb33dec990178ffd794`, byte-identical to the main tree at the base | YES, both |
| law md5 `16656aa852b6d7701be0233ba50c147c` | YES, exactly |
| patch applies clean on a fresh `70f84b03`, 36 files, 0 conflicts | YES; surface = `src/TypeEmit.cpp` + `include/UhdmExporter.h` + `RESUME.md` §3b + `tools/probe/r11u50repro/` only; `results/*.csv` untouched; all four fence names 0 |
| arm (a) head: `ibex_icache` 60 cmp lines, 1 head, golden `INT:22` ct 7 / ours `UINT:22` ct 9 at 32 | YES, re-measured — [evidence/HEAD.ibex_icache.pristine.remeasured.cmp](evidence/HEAD.ibex_icache.pristine.remeasured.cmp) |
| arm (b) head: `struct_member_cfg_width` 64 cmp lines, 1 head, golden `BIN` ct 3 `64'b…0011` / ours `UINT:274877906947` ct 9 at 64 | YES — [evidence/HEAD.struct_member_cfg_width.pristine.remeasured.cmp](evidence/HEAD.struct_member_cfg_width.pristine.remeasured.cmp) |
| the two arms are NOT one head (different producers, different golden answers) | CONFIRMED |
| g1 calib 48/0; pristine 39/48 → law 48/48, 9 cells | EXACT, cells `c03 c05 c10 c11 c18 c19 c21 c22 c23` |
| g2 calib 34/0; pristine 26/34 → law 30/34, 4 cells | EXACT, cells `d01 d06 d14 d17` |
| g3 calib 11/0; 9 SAME / 2 DIFF, untouched by the law | EXACT — the g3 `uhdm-cmp` output is byte-identical between pristine and law after workdir-path normalisation |
| predict50 positive control: names all 13 moving grid parameters, none of the 10 named non-movers | EXACT |
| census `cenc50.py` on `ibex_icache`: calib 0 lines, golden 2947 constants / 60 shapes, ours 2829, 14 differing keyed shape rows | EXACT |
| battery scripts are the current generation | `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` byte-identical to `tools/probe/r10uvm221repro/` |
| goldens 23/0, `/bin/false` 0/23 | YES, for pristine, law and fix |
| pristine u2r both modes | 783/21/67 ×2; row-join against `results/golden_uhdm2rtlil.csv` = **0 differing row-sides of 1742** |

Two small prose corrections to the implementer's report, neither affecting a
measurement: (i) the u2r prediction is a subset of the **28** discovered
`ibex_*` rows, not 20 — 20 is `CANDIDATE_PARAMS`, the parameter count; (ii) the
law is read at three call sites, of which only two are package-parameter-only:
the third (`§ elabPortIntBound109`'s encoding half) takes a MODULE localparam.
That third site was unmeasured by the pass and is scored below as grid b2.

---

## 2. BREAKING THE LAW — six grids the pass does not have, on real v1.87 goldens

Every grid: `surelog -parse -nobuiltin -nocache -sv -d uhdm`, `rc=0`, `0 [ERR`,
our binary `rc=0`, and golden-vs-golden CALIBRATED FIRST. Scores are
pristine → fixed (the law binary's numbers are identical except where named).

| grid | face | cells | pristine | fixed | MOVED-WRONG | AWAY |
|---|---|---|---|---|---|---|
| [grid/b1_break50.sv](grid/b1_break50.sv) | 20 initializer shapes the pass's grids do not carry (cross-package name and multiply, add over a unary-minus NAME, shift over a `%`, right-shift over a `/`, both-literal power, explicit cast, USER function call, negative fold, declared-signed multiply, `logic signed` multiply, add over a multiply NAME, a multiply of two operations) × 2 views | 40 | 24 | **36** | 0 | 0 |
| [grid/b2_port50.sv](grid/b2_port50.sv) | **the ELAB PORT bound arm** — a MODULE localparam in the parameter port list, the shape of the law's own corpus head `usbdev_usbif.sv:12-54` | 23 | 9 | **13** | 0 | 0 |
| [grid/b3_dbase50.sv](grid/b3_dbase50.sv) | the BASE-LETTER faces + the named-element array bound | 17 | 8 | **9** | 0 | 0 |
| [grid/b4_width50.sv](grid/b4_width50.sv) | WIDTHS × SIGNEDNESS on the one shape the law moves: `int unsigned`/`int`/`integer`/`longint`/`longint unsigned`/`shortint`/`byte`/`bit [63:0]`/`logic [15:0]`/`logic signed [15:0]` | 24 | 14 | **24** | 0 | 0 |
| [grid/b5_sites50.sv](grid/b5_sites50.sv) | the OTHER sites: a named-element packed array, a NINE-HOP derivation chain, a generate-block bound, a function-body bound, and § shadowedImportBoundFold's shadowed name | 11 | 5 | **8** | 0 | 0 |
| [grid/b6_kinds50.sv](grid/b6_kinds50.sv) | non-integer VALUE KINDS: an X-bearing value, a `real`, a `string`, and the override-actual `param_assign` Rhs | 6 | 3 | **4** | 0 | 0 |

**121 new cells, pristine 63 right → 94 right, +31, MOVED-WRONG 0, AWAY 0.**
Adding the pass's own three grids (93 cells, 74 → 87): **214 cells, 137 → 181,
+44, MOVED-WRONG 0, AWAY-FROM-GOLDEN 0.**

### What the break grids CONFIRM

* **b4 settles the declaration-type question the pass only asked three ways.**
  The pick is blind to the declared type across ten of them and to signedness in
  both directions — every one of the ten is golden `INT` for `A * B` and the law
  gets all ten, where pristine got none.
* **b2 settles the third call site.** The port arm is a MODULE localparam, not a
  package parameter, and golden answers it off the same table: `MaxA * 2` → INT,
  `MaxA - 8 - 4 + 1` → INT, `-8 + 40` → INT, and `(MaxA / 8) << 1` → **UINT**
  where the marker said INT. Four DEF cells convert, no ELAB cell regresses.
* **b5 settles the budget and the shadow.** A nine-hop `H9 ← H8 ← … ← A * B`
  chain resolves (the walk's 32-level budget is not a model, as its own comment
  says), and § shadowedImportBoundFold's re-pointed name takes the law with it.
  The named-element packed-array cells are a PRE-EXISTING shape residue on our
  side (our elaborated `packed_array_typespec` carries no printed range there);
  the law moves no byte in them, and the plain-ADD control `NA = A + B` — golden
  UINT — stays UINT, which is the arm that would have caught an over-fire.
* **b6 settles the value kinds.** An X-bearing, a `real` and a `string` package
  parameter each reach the helper and each is refused upstream
  (`dcv.isInteger() && !hasUnknown()`); no crash, no move, and the override
  actual `#(.P(NM))` is a different emitter and does not move either.
* **Every moved line in every grid is a value tag or a `vpiConstType`.** The
  whole-dump order-blind diff over all nine grids classifies 100 % of the moved
  lines as `|UINT:` ↔ `|INT:` or `|vpiConstType:` — no location, no size, no
  typespec, no parenting, nothing below the slot the reader keys on.

---

## 3. WHAT BROKE — § pkgSubstEncBasedLitAbstain50v, and the fix

**THE PASS'S FENCE PARAGRAPH IS TRUE FOR THREE BASE LETTERS OUT OF FOUR.** It
says an encoding this decimal-digit encoder cannot spell leaves the caller's own
answer alone, and cites `32'h28` → `HEX` ct 5. `vecBaseCt79` maps `'h`/`'o`/`'b`
to `vpiHexConst`/`vpiOctConst`/`vpiBinaryConst`, which the helper's
`ct50 == vpiIntConst || ct50 == vpiUIntConst` filter drops — but it maps **`'d`
to `vpiIntConst`**, which the filter PASSES.

Measured on real v1.87 goldens, b3 `e02`/`e03`/`e04`/`e05` and b1 `c01`/`c02` —
`32'd40`, `'d40`, the same under a `signed` declaration, and a NAME reading one:

```
golden   |DEC:40  |vpiConstType:1        <- a THIRD encoding, neither side's
pristine |UINT:40 |vpiConstType:9
r11u50   |INT:40  |vpiConstType:7        <- four bytes per cell, no golden licence
```

No cell REGRESSES — every one of the six is wrong on both sides, so the pass's
`MOVED-WRONG 0 / AWAY 0` survives intact and this is not a rejection. What it is
is an unmeasured byte-move in exactly the shape the law's own fence claims it
leaves untouched, and a documented-model error: `'d` is a based literal too.

The fix restores the abstention, through bare NAME hops because the walk itself
follows them (`e05` is `T_REFD = T_DEC`):

```cpp
static bool basedLitOrigin50(const slang::ast::Expression& e0, int depth) {
    if (depth > 32) return false;
    const Expression& e = stripImplicitConv(e0);
    if (e.kind == ExpressionKind::IntegerLiteral)
        return e.syntax != nullptr &&
               e.syntax->kind == slang::syntax::SyntaxKind::IntegerVectorExpression;
    if (e.kind == ExpressionKind::NamedValue || e.kind == ExpressionKind::HierarchicalValue) {
        auto& sy50 = e.as<ValueExpressionBase>().symbol;
        if (sy50.kind != SymbolKind::Parameter) return false;
        if (auto* in50 = sy50.as<ParameterSymbol>().getInitializer())
            return basedLitOrigin50(*in50, depth + 1);
    }
    return false;
}
```
…consulted once, before the table, inside `pkgSubstIntEnc50`. It is STRICTLY
NARROWING: `'h`/`'o`/`'b` were already filtered out and an unbased literal is
not an `IntegerVectorExpression`, so its ONLY behavioural effect is the `'d`
case. It mirrors the refusal the declaration-side caller at
[src/TypeEmit.cpp:574](src/TypeEmit.cpp#L574) already makes for the same reason.

**IT COSTS NOTHING MEASURED.** Every published grid scores identically under the
fixed binary — g1 48/48, g2 30/34, g3 9/11, b2 13/23 — and the law→fix cell diff
on all of them is `FIXED 0 MOVED-WRONG 0 WRONG->WRONG 0`. `32'd32 + 8` (b1 c10,
golden `INT:40` ct 7) is an ADD at the top, so the table still answers it and the
cell still converts: the guard bites only where the derivation BOTTOMS OUT on a
based literal.

---

## 4. THE CORPUS, ALL FOUR COLUMNS — three sweeps, this verifier's own

Three full sweep sets (`pristine`, `law`, `fix`), each with its own frozen
binary and its own workdir root; **1742/1742 u2r and 960/960 surelog `cmds.txt`
name the frozen binary under test and 0 name the main tree**. Transcripts:
[evidence/GATES.law.txt](evidence/GATES.law.txt),
[evidence/GATES.fix.txt](evidence/GATES.fix.txt);
[evidence/MOVERS.verified.txt](evidence/MOVERS.verified.txt) carries every
mover, its order-blind attribution and the coin positive control.

| gate | pristine | law | fix |
|---|---|---|---|
| binary md5 | `acbe2f0ed8915eb33dec990178ffd794` (= main tree at the base) | `16656aa852b6d7701be0233ba50c147c` (= the pass's) | `9be297f87ce752ca318a4d32b204ebe9` |
| goldens | `PASS=23 FAIL=0` | `PASS=23 FAIL=0` | `PASS=23 FAIL=0` (`/bin/false` → `PASS=0 FAIL=23`) |
| u2r both modes | 783/21/67 ×2 | 783/21/67 ×2 | 783/21/67 ×2 |
| u2r row-join vs `golden_uhdm2rtlil.csv` (1742 rows), `gate_uhdm2rtlil.csv` (871), and this verifier's pristine | 0 differing | 0 differing | **0 differing, all three** |
| surelog both modes | 474/9 + 469/8 | 474/9 + 469/8 | 474/9 + 469/8 |
| surelog row-join vs `golden_surelog.csv` (1596 rows) | 2 differing row-sides — the `LowMemLib`/`LowMemPkg` `SURELOG_FAIL` strings that QUOTE THE WORKDIR PATH | same 2 | those 2 + `Earlgrey_0_1/testflags` `CMP_EQUAL/differ → CMP_EQUAL/` — the DUMP COLUMN only, the OPS-documented `uhdm-dump` timeout draw; **the pin is the database and it is `59d0ee6d10c3` in all three sweeps** |
| surelog byteverify vs pristine | — | **MOVERS 5/960** (the pass drew 3) | **MOVERS 3/960** |
| **fix vs law on surelog** | — | — | MOVERS 5/960 — two of them landing the FIXED binary exactly on the PRISTINE hash, which is the coin proof |
| u2r byteverify vs pristine (SELFCHECK, `PATH_SETS_IDENTICAL`) | — | **MOVERS 2/1608**, the two `ibex_icache` rows, `946a08c60b18`/`5b3e22429722` and `e7a1a82f152e`/`de55da748b46` — the pass's paths AND its md5 prefixes | **MOVERS 2/1608, the identical two** |
| **fix vs law on u2r** | — | — | **MOVERS 0 / 1608 — byte-identical on every database** |
| canaries / ctcan2 / canaudit | ok=52 + ok=8, PASS ×2, `audited=29 UNCOVERED=0 FENCE-BREACH=0` | same | same |
| rowheads (SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg, Earlgrey_0_1) | all `0 lines 0 heads`; Rggen 64/1 | identical | identical |
| byte pins SVSwitch / YosysVerx / InterfaceModPort / Earlgrey_0_1 / BlackParrotComplex / YosysOldOr | `4842211c4030` / `6ccda350c24a` / `59a365f3ce2c` / `8bdf25272e08`+`59d0ee6d10c3` / … | every one IDENTICAL | every one IDENTICAL |
| `results/*.csv` | untouched by the patch | | |

**ADVANCE vs CONVERT, confirmed the way the pass predicted it.** `ibex_icache`
head moves `ibex_icache.sv:87` (60 cmp lines, 1 head) →
`ibex_icache.sv:1020:45` under `param_assign 392:26` (64 lines, 1 head);
`struct_member_cfg_width` head byte-identical at 64 lines. Neither row converts,
so no baseline row is promoted and `results/*.csv` stays as committed.
The keyed census on `ibex_icache` moves exactly one cell inside one of its 14
differing shape rows (`owner=operation ts=int_typespec size=32`: INT 6→7,
UINT 142→141) and 14 rows remain 14.

### The one headline that is NOT a constant

**The pass reports `surelog MOVERS 3/960`; this verifier drew 5.** Both draws
are the documented per-invocation coin and neither carries the law:

* the sets are `{MiniAmiq/default, SeqDriver/default, SeqDriver/testflags}` (the
  pass) and `{MiniAmiq both modes, SeqDriver both modes, Scoreboard/default}`
  (here) — every member of both is in the coin family
  `{MiniAmiq, SeqDriver, SimpleUVM, Scoreboard}`, and no other name has ever
  appeared;
* every one attributes order-blind to the documented 0-or-4-line
  `UINT`/`vpiDecompile` LINE-NUMBER class (`|UINT:0` ↔ `|UINT:1068`, `0` ↔
  `858`, `0` ↔ `879`, `1113` ↔ `1167`) or, for `Scoreboard/default`, to a
  **0-line, 0-byte-delta pure ORDER draw**. **Not one carries `|INT:` or
  `|vpiConstType:`**;
* POSITIVE CONTROL, two independent forms. (i) The same frozen PRISTINE binary,
  run twice on the same command line, draws `64369038c3e4` then `da1573a088aa`
  on `MiniAmiq/default`. (ii) **FIX vs LAW** — two binaries that differ only in
  the `'d` abstention, a shape that occurs in NEITHER corpus (u2r fix-vs-law is
  `MOVERS 0/1608`, byte-identical) — still draws `MOVERS 5/960` on surelog, and
  TWO of the five land the fixed binary exactly on the PRISTINE hash
  (`default/Scoreboard e70775324004`, `testflags/MiniAmiq 27419f6011b4`) while a
  third lands on the value the PASS recorded for one of ITS pristine runs
  (`testflags/SeqDriver 05df6c25a21b`). Three binaries drawing from one
  interchangeable pool on exactly those four test names is a coin, not a law.
* And the count itself travels: the FIXED binary vs pristine draws
  `MOVERS 3/960` — the pass's own number, from a different binary.

So the reproducible claim is not "3 movers"; it is **"every surelog mover is in
the UVM coin family, attributes to the line-number/order class, and changes no
row's status"** — and that reproduces exactly. The pass's own README should say
the count is a draw, not a number.

---

## 5. RESIDUES THIS VERIFICATION ADDS (ranked)

* **V1 — the `'d` base still has no renderer.** After the fix, a bare sized- or
  unsized-decimal package parameter substituted at a bound is golden `DEC:` ct 1
  and we write `UINT:` ct 9 (b3 e02/e03/e04/e05, b1 c01/c02). It is the pass's
  own R1 one base letter over: the table KNOWS the answer, the decimal-digit
  encoder cannot spell `DEC` or `HEX` or `BIN`. One renderer closes `DEC` ct 1,
  `HEX` ct 5 (R1), `BIN` ct 3 (b1 c03, `8'b101000`) and `OCT` at once — four
  encodings, one site, and it is the largest single thing left on this road.
* **V2 — a USER function call reduces `INT` in golden.** b1 c13
  `K_UFN = f51(B8 * C3)` is golden `INT:25` ct 7 where we write `UINT:25` ct 9.
  `dimRedCtExpr79` REFUSES a non-system call (returns 0) and the pass inherits
  that refusal, so the cell is untouched by law and fix alike. The refusal is
  documented in § dimExprLeafBoundInit79v as "a USER function call is NOT
  claimed" — this is the first measurement showing what golden actually does
  with one, and it says the table should claim it.
* **V3 — the ELAB half of the port arm keeps a size/typespec residue.** b2
  `p_div`/`p_pow`/`p_sub`/`p_shd` are right in the DEF listing and land at
  size 64 with no typespec in the ELABORATED one, where golden keeps 32 and the
  `int_typespec`. Pre-existing, untouched by this law, and it is the reason b2's
  four conversions are DEF-only.
* **V4 — the named-element packed array's bound is not built on our side at
  all.** b5 c01/c02/c03 and b3 c08/c09/c10: golden's elaborated
  `packed_array_typespec` over a struct typedef carries the substituted bound,
  ours carries no range there. § patDefBoundPkgParamSubst builds the DEF half;
  the ELAB half is missing. Pre-existing, untouched.

Nothing in V1–V4 is caused by r11u50, and nothing in V1–V4 blocks it.

---

## 6. REPRODUCING

```bash
# the two binaries, built from scratch at the base and at the base + this patch
git worktree add /tmp/wt_pris 70f84b03; git worktree add /tmp/wt_law 70f84b03
(cd /tmp/wt_law && git apply -3 /tmp/r11u50.verified.patch)
for W in /tmp/wt_pris /tmp/wt_law; do
  cmake -S $W -B $W/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $W/build -j 2; md5sum $W/build/slang-uhdm
done
cp /tmp/wt_pris/build/slang-uhdm /tmp/pris.bin; chmod 555 /tmp/pris.bin   # FREEZE
cp /tmp/wt_law/build/slang-uhdm  /tmp/law.bin;  chmod 555 /tmp/law.bin

# ONE break grid, both producers, CALIBRATED FIRST (the others are the same shape)
cd <scratch> && cp <repo>/tools/probe/r11v50repro/grid/b1_break50.sv .
~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv -d uhdm b1_break50.sv
/tmp/pris.bin b1_break50.sv --single-unit -o ours.uhdm
uhdm-dump slpp_all/surelog.uhdm > g.raw; uhdm-dump ours.uhdm > o.raw
R=<repo>/tools/probe/r11u50repro/gread50.py
python3 $R g.raw g.raw <repo>/tools/probe/r11v50repro/grid/b1names.txt | tail -1   # CALIB: DIFF 0
python3 $R g.raw o.raw <repo>/tools/probe/r11v50repro/grid/b1names.txt             # the 20x2 grid
# then the same with /tmp/law.bin, and:
python3 cmp50.py b1.pristine.txt b1.law.txt b1     # FIXED / MOVED-WRONG / WRONG->WRONG

# the whole-dump order-blind diff beside every grid (nothing below the slot)
sed 's#<workdir>#WD#g' pris/o.raw | sort > x1; sed 's#<workdir>#WD#g' law/o.raw | sort > x2
diff x1 x2 | grep '^[<>]' | sed 's/[0-9]\+/N/g' | sort | uniq -c
```
