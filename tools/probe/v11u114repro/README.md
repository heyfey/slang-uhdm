# v11u114 — adversarial verification of r11u114 (package-pattern concat fold, case-item parameter ref, leaked-copy typespec)

Base a81eb328. Implementer patch r11u114 (law binary md5 `e67a68ed307cbe8efdeb4c5bef51a76e`).
Verified patch = r11u114 + three verifier fences (fixed binary md5 `5a306a8a446705758851d9b8d425e2d8`).
Pristine md5 `e2ae9bd546d27ae8d37dd939675e9412` (the pin).

## Verdict: ACCEPT-WITH-FIX

The implementer's headline numbers reproduce exactly. The law binary also moves
cells away from golden on legal SV in two of its faces, and one more is a
wrong-to-wrong move. Three fences fix this. Each fence only narrows a
law, and none of them moves a corpus database or a committed probe arm.

## Reproduced (law binary and fixed binary alike)

- `ibex_tracer` goes from 28 uhdm-cmp lines to 0 in both modes, so it CONVERTS.
  The committed rows the master should promote are
  `results/golden_uhdm2rtlil.csv:329 ibex_tracer,default,CMP_NOTEQUAL,decompile:,,`,
  `results/golden_uhdm2rtlil.csv:1200 ibex_tracer,testflags,CMP_NOTEQUAL,decompile:,,` and
  `results/gate_uhdm2rtlil.csv:329 ibex_tracer,testflags,CMP_NOTEQUAL,decompile:,,`. The sweep row is
  `ibex_tracer,{default,testflags},CMP_EQUAL,,,differ`.
- `stamped_gen_param` goes from 96 lines to 11 in both modes. Its next head is golden's bare
  `ref_typespec -> struct_typespec (q2::impl_t)` 12:11-16:4 against `RHS: <null>`.
- u2r is 799/5/67 → 800/4/67 in both modes. Surelog stays at 479/4 + 474/3.
- The goldens gate is 23/0, and /bin/false gives 0/23.
- byteverify (SELFCHECK 1607/1608 and 959/960):
  - u2r has 4 movers: ibex_tracer and stamped_gen_param, both modes.
  - Surelog movers are only the UVM order class. Each one is the 4-line
    UINT/vpiDecompile line-number flip, and Scoreboard/default is a 0-line
    order draw. See `evidence/BYTEVERIFY.txt`.
- The fixed binary against the law binary shows 0/1608 u2r movers. On the Surelog side it shows only
  UVM-class movers.
- Canary pins are identical in all three sweeps: SVSwitch 4842211c4030, YosysVerx 6ccda350c24a,
  InterfaceModPort 59a365f3ce2c, Earlgrey_0_1 8bdf25272e08/59d0ee6d10c3, and
  BlackParrotComplex/YosysOldOr the same as pristine. canaries.sh reports ok=52/8. ctcan2 and canaudit PASS.
- The wide boundary (9613 committed arms, pristine against fixed) moves the same 31 arms the
  implementer reported. Scored per cell against golden (`evidence/BOUNDARY_score.txt`):
  - 24 face-1 arms move TO golden; every added line is in golden.
  - 4 face-3 arms move TO golden, by the typespec-presence cell.
  - 3 arms are the binary-layout tail (`UINT:23562649 -> 23583193`); one of them is an rc=4 arm on both sides.
- The implementer's 49 grid arms are byte-identical between the law and fixed binaries.
- The kill switches work. `R11U114_OFF=1` is byte-identical to pristine on both target rows, and each face switch
  reverts only its own row.

## Breaks found (law binary), and the fence for each

Scored per cell by the five-field span and by kind/value (grid `grid/set1..4`, `evidence/GRID.txt`).

1. **Face 2, unqualified: AWAY.** The implementer's rule is "our module copy's Rhs is
   not a constant, so emit a ref". Golden substitutes a constant, and we wrote a ref, for these initializers:
   - `P = ~8'h0F` (d04)
   - `P = OTHER` with OTHER concat-valued (d10)
   - `P = OTHER.a` (d17)
   - the second item of p01
   Our copy of each is an operation or a ref, but golden's copy is reduced.
   Golden keeps the ref exactly for a **concat-bearing** initializer: d05 `{4{..}}`, d09 `{..}+1`,
   d11, d16, m02 `8'({2{..}})`, m06 `-{..}`, m07. A conditional with a concat branch is
   substituted (m01).
   **Fence:** `concatBearing114(initializer)`, a copy of ParamEmit's concatBearing54 walk, is ANDed onto
   the case-item arm in StmtEmit.cpp.
2. **Face 2, qualified: AWAY.** `pk::P` with `P = (OTHER > 1) ? {4'h1,4'h2} : 8'h2` (n01)
   is a constant in golden, but the law made it a ref. subst114Refused
   descended into the conditional.
   **Fence:** `subst114Refused` stops at `vpiConditionOp`. This is concatBearing54's selected-branch rule.
3. **Face 1, enum leaf with an unsized initializer.**
   - AWAY: `enum logic[5:0] {EA = 3, EB = 60}` with member `{EA, EB}` (g04), `{EA, 6'h1}` (k07) and `EA = 1 + 2` (k10).
     Golden KEEPS the op33, because its operands are UINT size 64 and the producer's concat reduce gives up. We folded it.
   - WRONG→WRONG: single-operand `{EA}` (k05), where golden writes a 64-digit BIN at size 12, and based-unsized `'h3` (k06), where
     golden writes `BIN:` with size -2.
   - Measured TO golden and kept folding:
     - sized inits (k01)
     - auto values, including after an unsized init (k02, k03, g05)
     - a sized parameter-ref init (k08)
     - sized arithmetic (k09)
   **Fence:** `unsizedLit114`. An enum leaf whose initializer holds an unsized literal declines.

With the fences, every cell above equals pristine or golden. The d/n/k arms named here revert to pristine byte for byte.
p01's P item stays a ref (golden) and its N item a constant (golden). No other arm in the
four sets, the implementer's 49 arms, the 9613 committed arms or either corpus moves between the
law and fixed binaries.

## Other measured cells (law = fixed)

- Face 1 moves TO golden:
  - signed (g01), octal/decimal (g02) and z-digit (g03) literals
  - hex truncation `4'h1F` (g15)
  - unpacked struct (g19)
  - array of struct (g20; the cmp count rises only by unmasking the vpiReordered residue)
  - typedef'd packed array (g23)
  - module copy in the elaborated view (g25)
  - macro-expanded members with different arguments, so no span-key collision (g26)
  - nested positional plus keyed patterns and the module copy (g27)
  - the wider parameter leaf `logic [7:0] L = 6'h2A` in the DEF listing (g07). Golden's TOP-package and module cells are
    `BIN:00101010000001`, 14 digits at size 12, and both binaries leave them unchanged.
- Face 1 declines, so the arm stays at pristine. These are missed opportunities, not regressions:
  - a cross-package parameter leaf (g06)
  - function-call, `'1` and string operands (g08-g10)
  - a replication with a parameter count (g14)
  - casts of parameters or negative values (g16, g17)
  - selects (g18)
- Face 2 moves TO golden: a task (e01), an elaborated generate (e03), an explicit import inside begin blocks (e09),
  `always_ff` with an enum concat (e12), replication (d05) and `-{..}` (m06).
  Declined and unchanged: an interface (e02), `case inside` (e05), and package or class methods (e10, e11).
- Face 3 moves TO golden per cell:
  - three hops (h01)
  - array of struct (h05)
  - export (h07)
  - two modules, one of which also imports the home package (h08, toward golden's 2+1 split)
  - two parameterizations (h09)
  Unchanged: h02-h04 and h06.

## Residues (ranked)

- **R2 (the R0 line).** stamped_gen_param's next head is the flatten of `q2::IMPL` triggered by a module
  parameter's qualified member select. See the implementer's face-4 decode.
- **R1.** Face 2 outside case items (if-condition, assignment Rhs, continuous assign) is in ExprEmit.cpp,
  the sister pass's file. The unqualified `{..} & 8'hF0` (m05) and `{..}+1` (d09) reads stay constants
  because our copy is folded (the implementer's R5).
- **R6 (new, hygiene).** Face 1 and the unqualified half of face 2 emit and then discard objects. The replaced concat
  op, its operand constants and the case-item constant stay in the serializer as unreachable
  objects, together with their strings. The judge and uhdm-dump never reach them, but this is a
  write that could have been avoided.
- **R4.** Face 1 declines x-digit hex literals and unpacked-array parameters (implementer). It also declines the unsized-enum
  shapes above; golden's single-operand and based-unsized outputs are malformed (64-digit BIN, size -2).

## Files

- `grid/set1..set4`: arms (dut.sv).
- `evidence/GRID.txt`: per-arm lines/heads/rc for pris/lawx/fixv.
- `evidence/BOUNDARY_*`: wide boundary and per-cell score.
- `evidence/BYTEVERIFY.txt`: byteverify and order-blind attribution.
- Drivers: `sweep114v.sh` (WDROOT), `bscore114v.sh` (ROOT, BINDIR), `attr114v.sh`, and the scorers
  `dist114v.py`, `member114v.py` and `rhsts114v.py`. Grids run with `../r11u114repro/grid114.sh`.
