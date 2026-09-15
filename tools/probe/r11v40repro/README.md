# r11v40 — ADVERSARIAL VERIFICATION of r11u40 (`§ ovHopBareActualElabFold40`)

Base `e305f3d7`.  LHS is ALWAYS golden.  Judge: `uhdm-cmp`
(`/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp`, v1.87).  Own worktrees, own
binaries built `-j 2` and frozen, own workdirs, every `cmds.txt` audited by
binary PATH, every arm's rc recorded on both producers.

## VERDICT: ACCEPT-WITH-FIX

Every headline number of the pass reproduces bit-for-bit — including the law
binary's md5 (`c6b54054bd2c8080d3056fe468082b1b`), the head, the whole-dump
distances (949/543 → 745/255), all four grid arms' scores, the single u2r
conversion in both modes, and the 2/1608 byte movers.

The law's own face is right.  But the abstain is written as "the parameter's
value is a known integer", which is a SLANG-side question, and the producer's
abstain is a different one.  THREE shapes reach the two gated arms where the
producer KEEPS the written operation, our PRISTINE emitter already agreed with
golden, and the submitted patch folds anyway.

| face | arm | golden | pristine | r11u40 | fixed |
|---|---|---|---|---|---|
| the corpus shape (bare chain, interface default present, scalar formal) | `iface_param_2level`, `v5_depth40`, `v8_bitvec40` | folds | keeps | folds ✔ | folds ✔ |
| a PACKED-STRUCT formal (`#(.B(s.CFG.BUS))`, bound reads `B.DAT`) | `v7_structonly40`, `v4_structformal40` | **keeps** | **keeps** | **folds ✘** | keeps ✔ |
| the hop parameter declared WITHOUT a default | `v1_nodef40`, `v6_nodefpkg40` | **keeps** | **keeps** | **folds ✘** | keeps ✔ |
| the hop parameter's default READS another parameter | `v9_defchain40` | **keeps** | **keeps** | **folds ✘** | keeps ✔ |
| an interface OVERRIDDEN away from its default | `v2_ifovr40` | folds the DEFINITION's default | keeps | folds the CONNECTED value | unchanged (R1) |

AWAY-GOLDEN under `r11u40`: **7 cells over 5 arms** (SET and MULTISET alike;
`v1` 3, `v6` 1, `v4` 1, `v7` 1, `v9` 1 — three distinct shapes).
AWAY-GOLDEN under the fix: **0 on every arm**, with every TO-GOLDEN cell kept
— the pass's own grid still scores TO-GOLDEN 11 / AWAY 0 / MOVED-WRONG 5, and
the conversion still lands in both modes.

## THE THREE BREAKS, MEASURED

All arms `golden_rc=0 ours_rc=0` on every binary, Surelog `[FATAL] : 0
[ERROR] : 0`, real v1.87 goldens, scored with the pass's OWN `rangecensus40.py`
+ `score40.py` (the SHAPE LISTER beside the census).

### (1) A PACKED-STRUCT FORMAL — `v7_structonly40`, `v4_structformal40`

slang keeps a packed struct's value as an `SVInt`, so `getValue().isInteger()`
is TRUE for `#(.B(s.CFG.BUS))`.  The producer does not fold it:

```
GOLDEN, elaborated param_assign 20:42..20:55  |vpiOverriden:1
  vpiRhs -> hier_path (s.CFG.BUS) 31:17..31:26   [ref_obj s / CFG / BUS, vpiExpr]
OURS, PRISTINE — the same hier_path, the same three actuals, the same vpiExpr
OURS, r11u40   — constant UINT:25 @32 ct9
```

and the `[B.DAT-1:0]` bound follows: golden and pristine
`op11(hier_path, constant) x2`, r11u40 `const INT:24@64 ct7` + one kept copy.
`SET/MULTISET: AWAY-GOLDEN=1` (`v4` the same cell beside an `int unsigned`
control that correctly folds — TO-GOLDEN=1 there, so the arm proves both
halves at once).

### (2) A HOP PARAMETER WITH NO DEFAULT — `v1_nodef40`, `v6_nodefpkg40`

`interface ndif40 #(parameter pv40::cfg_t CFG);` — override-only, ordinary
legal SV.  `CompileHelper::getValue` resolves the hop against the interface
DEFINITION (which is exactly why an OVERRIDDEN interface still folds the
definition's default — the pass's own R1), so there is no value on that road,
`reduceExpr` reports `invalidValue` (`CompileExpression.cpp:4032`) and golden
keeps:

```
cell              golden                       pristine                     r11u40
29:32 port dim    op11(hier_path,constant) x2  op11(hier_path,constant) x2  const INT:20@64 ct7 x2
30:32 port dim    op11(hier_path,constant) x2  op11(hier_path,constant) x2  const INT:20@64 ct7 x2
31:9  body var    op11(hier_path,constant) x1  op11(hier_path,constant) x1  const INT:20@64 ct7 x1
```

`SET/MULTISET: AWAY-GOLDEN=3`.  The INTERFACE's OWN bound (`23:9`) folds on all
three binaries — the interface instance HAS the value; only the read THROUGH
THE PORT does not.  `v6_nodefpkg40` is the same break with the actual written
as a package parameter (`AWAY-GOLDEN=1`).

### (3) THE DEFAULT THAT READS ANOTHER PARAMETER — `v9_defchain40`

`#(parameter int unsigned BASE, parameter cfg_t CFG = '{BUS: '{DAT: BASE}})`:
the hop parameter HAS a default, but the definition-side value is still
unavailable to the producer, and golden keeps `op11(hier_path, constant)` where
r11u40 folds `INT:22`.  This is the bound of the fix's own second test, found
by pushing on it — the fix answers it by requiring the default to be made of
LITERALS alone.

## THE FIX (`/tmp/r11u40.verified.patch`)

`ovHopBareActualFolds40` gains the hop's own parameter and answers TRUE only
when all of the following hold, asked in this order so the syntactic tests
short-circuit before `getValue()` forces any evaluation:

1. `p.getType().isSimpleBitVector()` — a predefined integer, a scalar, or a
   packed array of scalars: the values the reducer prints as a scalar.
   `v8_bitvec40` measures `logic [7:0]` beside `int unsigned` and golden folds
   both, so the test is not narrower than golden on the measured faces.
2. the parameter reached THROUGH THE HOP was declared with a LITERAL-ONLY
   default (`ParameterSymbolBase::defaultValSyntax`'s declarator has an
   `initializer`, and `defaultIsLiteralOnly40` finds no name in it — skipping
   assignment-pattern KEYS the way slang's own default-expression visitor
   does).  An override replaces the symbol's initializer without touching that
   syntax, so it is the DEFINITION's own default and nothing else.
3. `p.getValue()` is a known integer (the submitted test, kept).

Condition 2 is deliberately CONSERVATIVE: a default the producer could still
evaluate (a package parameter, say) is left symbolic — the pristine answer,
which never moves a cell away from golden.  That is a RESIDUE, not a
regression, and it is named below.

## GATES (the fixed binary)

* goldens 23 PASS / 0 FAIL; `/bin/false` 0 PASS / 23 FAIL.
* u2r both modes 777/27/67 → **778/26/67**, exactly one row, quoted in
  `evidence/GATES.r11v40.txt`; `iface_param_2level` CONVERTS in BOTH modes.
* byteverify u2r: FIXED vs pristine = the same 2/1608 with the same md5s;
  **FIXED vs r11u40 = 0 / 1608** — the narrowing is byte-neutral on the corpus.
* surelog both modes 474/9 + 469/8, no status moves; the byte movers are the
  UVM per-invocation coin, proved by a three-run pristine positive control
  whose order-blind class and count are identical to the law-vs-pristine pair.
* canary pins all SAME (`SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
  `InterfaceModPort 59a365f3ce2c`, `Earlgrey_0_1 8bdf25272e08 / 59d0ee6d10c3`);
  canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0; `results/*.csv` untouched.

## ARMS

`grid/v1_nodef40`, `grid/v2_ifovr40`, `grid/v4_structformal40`,
`grid/v5_depth40` (member depths 1..4 × a generate loop × no override at all),
`grid/v6_nodefpkg40`, `grid/v7_structonly40`, `grid/v8_bitvec40` (the formal's
own type: `logic [7:0]`, an enum through a cast, `int unsigned`),
`grid/v9_defchain40`.  `grid/v3_xval40` is kept UNSCORED: an `x`-valued bound is
refused by slang (`ours_rc=3`) and an arm whose compile fails teaches error
recovery, not golden.

Runner: the pass's own `r11u40repro/run40.sh` with `GRID=` pointing here, so
both producers run and both rcs are recorded.  `rungates40.sh` is the sweep
driver (its paths are all overridable; it hard-codes no other pass's scratch).

## RESIDUES (ranked)

* **R1 — THE VALUE A MEMBER READ LENDS ACROSS AN INTERFACE PORT** (the pass's
  own R1, confirmed and sharpened).  `v2_ifovr40`: golden folds the interface
  DEFINITION's default (32 → 31) even when the connected instance carries 26,
  where we fold the CONNECTED value (26 → 25).  The corpus conversion is
  therefore value-coincidence: `iface_param_2level` instantiates `tif s()`
  without an override, so the two numbers agree.  Any design that overrides its
  interface is MOVED-WRONG on this face, before and after — a `DesignElaboration`
  VALUE law, not a fold law, and the largest thing this family still owes.
* **R2 — the conservative half of condition 2.** A hop parameter whose default
  reads a package parameter (or any other name) is left symbolic even where the
  producer can evaluate it.  Closing it needs the definition-side evaluation
  slang does not offer directly; the safe answer costs a fold, never a cell.
* **R3 — an actual the reducer FAILS on that we fold** (the pass's R2):
  `#(.W(s.CFG.BUS.DAT + 4))` — golden keeps `op24(hier_path,4)`, our pristine
  already folds `INT:35`; neither arm can see that shape.
* **R4 — the row's next head.** `iface_param_2level` is judge-equal and still
  745 dump lines (255 order-blind) from golden: the `p::bus_t` / `p::cfg_t`
  typespec pool and the interface parameter's `struct_typespec` `vpiInstance`
  chain.  A different family; the row's status no longer depends on it.
