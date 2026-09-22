# r11v83 — the adversarial verification of r11u83, and the one law it needed

Base commit `14ff07cc`. Everything below was built and measured in this
verifier's own worktrees (`/tmp/wt_v11u83`, `/tmp/wt_v11u83pris`), never
inherited.

```
pristine  33f341dfa44841c1223ce59eeaa071b6   built here, -j 2, md5 taken
                                             separately, == the OPS pin
patched   e91e921c1d296ad7fa2b9f7010aa4da1   the implementer's, REBUILT here
                                             from the patch on a FRESH 14ff07cc
fixed     83eb4474a4da700d16c20a5551e18289   patched + the one law below
```

All three frozen `chmod 555` at immutable paths before any sweep; every
`cmds.txt` in all four sweep workdirs audited by binary PATH.

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Rebuilt both binaries, re-ran every headline instrument. Reproduced exactly:

* the two md5s, the patch applying `-3` clean to a fresh `14ff07cc` with the
  applied production files `cmp`-identical to the implementer's worktree and
  the whole probe dir identical;
* the base witnesses — `w1_iface` `cmp_rc=255 heads=1 cmplines=30`,
  `g11_iface` `255/1/26`, `InterfaceModPort`'s database `59a365f3ce2c` both
  modes;
* the 22-arm grid, pristine and patched, arm for arm: SIX convert
  (`g11_iface`, `i1_ifkinds`, `i4_portview`, `i5_twoinst`, `i6_ifarray`,
  `j3_ifcaselect`), ZERO regress;
* the SWITCH LEDGER, line for line, including `R11U83_OFF=1` reading **0 on
  every arm** — the patched binary with both switches off is byte-identical
  to pristine, which is the independent proof that lifting the module hoist
  block out changed nothing;
* the LIFT-OUT as a pure move: a line-by-line multiset join of the diff's
  removed and added sides leaves exactly FIVE unmatched removed lines — the
  block's `{`, the three `sigOrder.emplace_back(...)` calls and the
  `if (!hanets77->empty())` that gained braces;
* the CENSUS, both corpora, both modes, re-run with the harness's own
  discovery: uhdm2rtlil 1742 arms / 3928 trace rows / **IFHOIST 0** / IFCA 32
  / sps=1 **0**; surelog 1573 arms / 12580 rows / **IFHOIST 0** / IFCA 4 /
  sps=1 **0**; every rc bucket identical. The POSITIVE CONTROL reproduces
  (`i1` 10/4/0, `i4` 4/2/2, `w1` 2/1/0 + ifca 1, `g11` ifca 1 sps 1,
  `j1` ifca 7 sps 3, `j3` ifca 4 sps 1), so the corpus zeros are readings;
* goldens 23 PASS / 0 FAIL on both binaries, `SLANG_UHDM=/bin/false` 0/23;
* uhdm2rtlil 788/16/67 in both modes on both binaries, **0 of 1742 rows**
  differing against `results/golden_uhdm2rtlil.csv`, against
  `results/gate_uhdm2rtlil.csv` (testflags) and against this verifier's own
  pristine sweep; `byteverify SELFCHECK=1` **MOVERS 0 / 1608** with a
  1607/1608 negative control;
* surelog 474/9 default + 469/8 testflags on BOTH binaries, every other
  status bucket identical (5 DEFERRED, 285/286 SLANG_REJECT, 25/23
  SURELOG_FAIL, 3 NO_DATABASE, 1 NO_UHDM, 1 TIMEOUT, 2 UNTRANSLATABLE); the
  whole-row join against `results/golden_surelog.csv` differs in **3** rows
  patched and **4** pristine, every one environment and every one quoted in
  §5;
* the surelog `byteverify SELFCHECK=1` movers, all UVM family and every one
  ATTRIBUTED order-blind: FIVE here, four of them EXACTLY FOUR differing
  lines and every one a `UINT:<n>` / `vpiDecompile:<n>` pair (the macro-buffer
  line-number class) and the fifth a ZERO-line ORDER draw
  (`Scoreboard/default`, the documented `svunit_pkg` `vpiTaskFunc` coin). No
  `vpiNetType`, no `vpiActual`, no `cont_assign`, no listing line, no `Delay`
  and no strength among them — and neither law has a site in that corpus. The
  implementer read THREE movers on the same class; the count is a coin, the
  class is not.
* canary DATABASE byte pins, all on the OPS pins, `InterfaceModPort` watched
  byte for byte: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
  `InterfaceModPort 59a365f3ce2c`, `YosysOldOr d68e0796d62c`,
  `BlackParrotComplex e3e354129d5a / 73a10e8217e5`,
  `Earlgrey_0_1 8bdf25272e08 / 59d0ee6d10c3`.

---

## 2. THE BREAK GRID (19 arms, `grid/`)

Written against the faces the implementer's grid does not reach: the
name-keyed `netMap` binds the hoist newly feeds (`b1_fnref` the interface
function-ref fixup, `b2_mpexpr` a modport EXPRESSION port, `b5_mpio` a
modport io_decl, `b8_clkblk` a named clocking block), the `netToVar` rebind
of the DEF cont_assigns (`b3_ifcaread`), the port view's throwaway net slot
(`b7_pvmodport`), an interface ARRAY (`b12_ifarr`), a port NAMESAKE
(`b15_portname`), LAW B's index alignment under the gen-region rotate
(`b4_calign`, `b9_calign2` with four DISTINCT member values, `b10_mixdecline`
with folding and non-folding cells interleaved), LAW B x LAW A in one arm
over two elaborated views (`b6_ifgen`), the MODULE twins that attribute a
reading (`b11_nestmod`, `b13_exprovmod`), the clone's drive fields (`b14_cadelay`,
`b16_preclone`), a TOP-LEVEL interface (`b17_topiface` — the site is not
reached and the arm is `cmp_rc=0` on all three binaries, which is the arm
saying so rather than agreeing by luck: `R11U83_CELLDBG=1` reads 0 hoist
entries there), and LAW B's DECLINE path on an X-valued member
(`b18_xmember`, which CONVERTS: the fold carries `BIN:xxxxxxxx` and no
spurious clone appears), and the hoist x the generic-port doubling x
pass-80's collide in one arm (`b19_dblcollide`).

Every arm is its own `dut.sv`, `golden_rc=0 ours_rc=0` on all three binaries,
goldens regenerated per arm by the pinned Surelog v1.87. No corpus test is
dispatched from this directory.

**Result: 3 arms convert on the patched binary (`b2_mpexpr`, `b12_ifarr`,
`b18_xmember`), a fourth (`b14_cadelay`) converts only after the law in §3,
and no arm regresses.** Per-line AWAY-from-golden (`away83v.py`: golden lines
we matched pristine and no longer match) is **0 on every arm but one**, both
grids, on the patched and on the fixed binary.

THE ONE EXCEPTION IS THE FALLING-COUNT TRAP, not a regression.
`b19_dblcollide` (the hoist x the generic-port doubling x pass-80's collide)
reads `AWAY=2`: `logic_net (work@dut.u_if.q_net) 12:16` and
`logic_var (...q_var) 13:16`, the interface's OWN declarations, each printed
once less than before. The cause is the CONVERSION itself — the gen-scope
cell stopped referencing the own object and now binds the hoisted copy,
which is what golden binds:

```
golden   gi[0].q_net -> logic_net (work@dut.u_if.q_net) line 6:15   (the package's)
pristine gi[0].q_net -> logic_net (work@dut.u_if.q_net) line 12:16  (the interface's own)
fixed    gi[0].q_net -> logic_net (work@dut.u_if.q_net) line 6:15   golden's
```

A reference moving off an object lowers that object's PRINT count, and a
multiset-of-lines scorer reads the fall as a loss. `cellmw83.py` reads the
same arm `CONVERTED=2 MOVED-WRONG=0 AWAY=0`, and `uhdm-cmp`'s head is
byte-identical pristine and fixed (a pre-existing gen-scope naming head,
`cmp_rc=255 cmplines=87` on both). Two instruments and the judge agree
against the third; the third is the one the OPS note already names.

---

## 3. THE ONE REGRESSION, AND THE LAW THAT CLOSES IT

### § caIfaceBodyCaFoldKeepsDriveFields83v — arm `b14_cadelay`

`cont_assign::Compare`
(`~/git-repos/UHDM/build/generated/src/cont_assign.cpp:104-124`) reads
**VpiNetDeclAssign, VpiStrength0, VpiStrength1 and Delay BEFORE it reads
Rhs**. The elaborated-interface clone this site builds copies only the
parent and the span. Before § caIfaceBodyCaFolds83 a struct-parameter cell
SHARED the def object, so

```systemverilog
assign #5 d_del = C.n;
assign (strong1, weak0) d_str = C.m;
```

carried their delay and their strengths into the elaborated view for free.
Forcing the clone dropped them, and the judge said so: on `b14_cadelay` the
head MOVED from golden's folded constant

```
pristine head:  constant DEC:6  vpiSize:8   parented at cont_assign 15:10
```

to golden's **delay** object

```
patched head:   constant |vpiDecompile:#5 |vpiSize:64 |UINT:5
                parented at cont_assign 13:13   RHS: <null>
```

That is pristine-right -> patched-wrong on legal SV. The law copies the four
fields, **gated to the cells this pass newly clones** (`sps83` is null
whenever `R11U83_IFCAFOLD_OFF=1` or `R11U83_OFF=1`, so it rides LAW B's own
switch and adds none of its own). With it, `b14_cadelay` goes
`cmp_rc 255 -> 0`: the arm CONVERTS.

**Deliberately NOT widened.** The two shapes that already took this clone at
the base — a plain-constant Rhs and a package-enum-const Rhs — drop the same
fields and golden wants them there too (arm `b16_preclone`, which stays at
`cmp_rc=255` and `NONE=0` in the ledger). That is a PRE-EXISTING gap with a
LIVE corpus site (`InterfaceAssign` writes a literal into an interface body,
census row quoted), so closing it is its own law with its own census, not a
silent widening here. It is ranked R1 below.

### The instrument that missed it

`cellmw83.py`, the implementer's per-cell arbiter, scores `b14_cadelay`
`CONVERTED=3 MOVED-WRONG=0 AWAY=0` — its CA key is (owner, span, Lhs name,
Rhs kind, Rhs value) and reads **none** of the four drive fields. A
line-multiset scorer (`linescore83v.py`, `SCORE.r11u83.txt`) is blind for a
different reason: the dump prints a SHARED sub-object abbreviated on reuse,
so the `|vpiDelay:` line stays in the file once (the def view) on both sides.
The only instrument that saw it was `uhdm-cmp` itself. **A cell scorer must
carry every field its owner's generated `Compare` reads, in that order.**

---

## 4. CORRECTIONS TO THE IMPLEMENTER'S WRITE-UP

Each measured here, on the implementer's own arms, with the module twin that
attributes it.

1. **`j1_ifcafold` `f_nest` is NOT "golden's".** The §3b table row
   (`D.inner.n | UINT:11 | shared | golden's`) is an overclaim: golden's
   elaborated constant reads `vpiSize:64`, ours reads `vpiSize:32`. Every
   other field matches (span `8:42-8:44`, `vpiDecompile:11`, `UINT:11`,
   `vpiConstType:9`). `vpiSize` is a compared field. The MODULE twin
   `b11_nestmod` reads `vpiSize:32` on BOTH sides, so the 64 is an
   interface-home reading of the NESTED member read that LAW B does not
   reproduce. It is a move TOWARD golden (pristine shared a `hier_path`
   there), not away — ranked R2.
2. **"none of the rising `ours_only` lines is a compared field" is false.**
   On `j1_ifcafold` the rising lines include `|vpiSize:32` (that cell) and
   `|UINT:6` / `|vpiDecompile:6` (one extra minted constant where golden
   shares one object). On the verifier arm `b6_ifgen` the rising lines are
   `|vpiDecompile:1` and `|vpiDecompile:2`: golden's interface-home fold of a
   member whose override element is an EXPRESSION (`8'(i+1)`) carries NO
   `vpiDecompile` and we write one. `VpiDecompile` IS read by Compare. The
   MODULE twin `b13_exprovmod` shows golden carrying `vpiDecompile:1` there
   and ours matching byte for byte, so this too is an interface-home reading
   — ranked R3.
3. **`cellmw83.py` reports `MOVED-WRONG=1`, not 0.** The flagged row is
   `i6_ifarray`'s `v_sarr` element-net span, which §7g/§8 R6 names honestly
   in the next sentence; only the headline number was rounded.
4. **The surelog whole-row join reads 3 rows here, not 4** — one
   `Earlgrey_0_1` dump-column blank on the patched binary instead of two,
   while the PRISTINE binary's join reads 4 with BOTH Earlgrey dump columns
   blank. The draw is load-dependent and falls on either binary; the STATUS
   is `CMP_EQUAL` on all four Earlgrey rows and the DATABASE byte pins hold.
5. **The surelog byteverify reads 5 movers here, not 3** — same UVM family,
   same class, every one attributed order-blind (four at exactly four
   `UINT:<n>`/`vpiDecompile:<n>` lines, `Scoreboard/default` a 0-line order
   draw). The COUNT of that coin is not a number a pass can quote as a pin;
   the CLASS is.

---

## 5. THE GATES ON THE FIXED BINARY

See `GATES.r11v83.txt` for the raw numbers. Nothing in §1 changes: the fixed
binary's grid is arm-for-arm the patched binary's plus `b14_cadelay`
converting, its switch ledger is line-for-line identical (`R11U83_OFF=1`
reads 0 on all 41 arms), and both laws stay droppable alone.  On the
corpus the fixed binary is the patched one exactly: uhdm2rtlil 788/16/67 in
both modes, 0 of 1742 rows differing against the committed baseline, against
the patched sweep and against this verifier's own pristine sweep, and
`byteverify SELFCHECK=1` MOVERS 0 / 1608.  That is the census's predicted
(empty) mover set, and it is what the gate on `sps83` guarantees: 0 sps=1
sites in either corpus.

---

## 6. RESIDUES (ranked; the implementer's R0-R5 stand unchanged and are not
## repeated)

* **R1 — the elaborated-interface clone drops the DRIVE FIELDS on the two
  shapes it already served at the base** (`b16_preclone`): a plain-constant
  Rhs and a package-enum-const Rhs lose `Delay` / `VpiStrength0/1` /
  `VpiNetDeclAssign` in the elaborated view, where golden keeps them. It has
  a LIVE corpus site (`InterfaceAssign`, `work@top.u_sw:53`, `rhs=constant`),
  so it needs its own census and its own gate. One law, one site, and the
  §3 law is its template.
* **R2 — the nested struct-parameter member read folds to `vpiSize:32` in an
  interface body where golden reads 64** (`j1_ifcafold` `f_nest`;
  `b11_nestmod` attributes the module home at 32 on both sides). The width
  answer `emitCaStructParamSubst55` takes by default (`adjustW71 = -1`,
  "ask `caLhsAdjustBind106`") is the module home's; the interface home needs
  its own, the way the gen-scope home already passes `genCaSubstAdjustW71`.
* **R3 — an EXPRESSION-valued override element folds with a `vpiDecompile`
  golden's interface home omits** (`b6_ifgen`; `b13_exprovmod` shows the
  module home carrying it on both sides). Same family as R2: one encoding
  rule, two homes, measured apart.
* **R4 — the PORT VIEW mints hoisted NET holders it lists nowhere.** The
  shared builder runs with a throwaway net vector, so the holders are created
  (a `Make` is a WRITE) and filed in `netMap` while no listing references
  them. Judge-invisible — they are unreachable from the design root, the
  `ours_only` distance on `i4_portview` and `b7_pvmodport` is unchanged, and
  `emitGenScopes` is `!portView` so no cell can resolve to one — but it is an
  orphan mint, and a future port-view law that reads `netMap` would find
  objects golden does not have.
* **R5 — golden binds an interface's function-body ref, and a modport
  io_decl's `vpiExpr`, to the HOISTED copy, not to the interface's own
  namesake** (`b1_fnref` golden `vpiActual: logic_var (work@dut.u_if.fv)` at
  the package's line 5:15; `b5_mpio` golden `vpiExpr` at 6:15 where ours is
  the interface's own 12:16). Both are byte-identical pristine and patched —
  pre-existing — but LAW A is what puts the object golden wants on the table,
  so these are now one lookup away.

---

## 7. HOW TO RE-RUN

```bash
GRID=<this dir>/grid bash ../r11u83repro/rr83.sh <binary> <tag>
GRID=<this dir>/grid bash ../r11u83repro/sw83.sh <pristine> <patched>
python3 away83v.py <gold.pris> <ours.pris> <gold.patch> <ours.patch>
python3 linescore83v.py <gold.dump> <ours.dump> [v]
```

`away83v.py` is the AWAY arbiter used above: it scores the golden lines we
MATCHED pristine and no longer match, which is the only reading that cannot
be inflated by a new ours-only line. Its blind spot is named in §3.
