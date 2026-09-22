# r11v90 — the ADVERSARIAL VERIFIER's record for r11u90

**VERDICT: ACCEPT-WITH-FIX.** Both laws are decoded correctly against the
pinned producer, both are gated, each drops alone, and neither moves a single
cell away from golden on 170 arms — 41 of them written here to break them.
The one defect is in the deliverable, not the code: the shipped
`GATES.r11u90.txt` spelled the four slang-fenced test names, so the mandated
`canaudit.sh` read **`FENCE-BREACH=4`, exit 6**, against a report that claimed
`FENCE-BREACH=0`.  Fixed here (that file no longer spells them); re-run reads
`audited=29 UNCOVERED=0 FENCE-BREACH=0`, rc 0.  Ship
`/tmp/r11u90.verified.patch`.

Verifier worktrees `/tmp/wt_v11u90` + `/tmp/wt_v11u90pris` at `05399931`,
scratch `/tmp/v11u90_*`, sweep workdirs `/tmp/v11u90_wd/{pris,lawx}` (surelog)
and `{prisu,lawxu}` (uhdm2rtlil), frozen binaries `/tmp/v11u90_bin/*.bin`.

## 1. Rebuilt, refrozen, re-measured — every headline number reproduces

Both binaries built here, `-j 2`, md5 taken separately, `chmod 555` before any
sweep: pristine `4125277d8f6d4d67aa0d85dbb4843a5d`, **`cmp`-identical** (not
md5-identical, byte-compared) to the main tree's `build/slang-uhdm` at
`05399931` and to the OPS pin; law `f021109740f891eecc75a873cf0920ea` —
the implementer's md5 exactly.  Every `cmds.txt` in all four workdirs audited
by absolute binary path: surelog 1581 + 1581, u2r 1742 + 1742, and **0 lines
naming any other binary** — which mattered, because the sister pass was
rebuilding the main tree during these sweeps.

The grid was re-run with the verifier's OWN runner (`vrr90v.sh`, shipped here),
which produces each golden ONCE and runs BOTH binaries against it, so a
pris/law difference cannot be a golden redraw.  **All 129 arms the implementer
shipped reproduce bit-for-bit — `cmp_rc` and cmp line count, on both
binaries.**  The 14 conversions to `cmp_rc=0` are confirmed one by one.

## 2. The decode, checked against the pinned sources

* LAW A.  `CompileHelper::compileNetDeclaration` is lines **2096–2212** of
  `~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp` (Surelog
  `0445655ee7`, v1.87), and `grep -n 'strength\|Strength'` over exactly that
  range returns **nothing**: no `paDrive_strength` arm, no `paCharge_strength`
  arm.  The single `paDrive_strength` in the whole file is line **2442**, in
  `compileContinuousAssignment` — the `assign (s1,s0) …` STATEMENT form, a
  different function.  The decode is exact.
* LAW B.  `compileContinuousAssignment:2440-2444` compiles `paDelay3` with
  `Reduce::No`; `UhdmWriter::writeCont_assign:2104-2118` binds through
  `bindParameter(mod, netlist->getParent(), delay->VpiName(), …)` AFTER
  `clone_tree`, then sets `Actual_group`.  Verified line by line.
* `cont_assign::Compare`
  (`~/git-repos/UHDM/build/generated/src/cont_assign.cpp:99-127`) reads
  VpiNetDeclAssign, VpiStrength0, VpiStrength1, **Delay**, Rhs, Lhs,
  Cont_assign_bits — in that order.  `Delay` is judge-visible and is compared
  before `Rhs`, so LAW B is a judge-relevant change, not cosmetics.

## 3. 41 NEW ARMS written to break the laws — 0 cells moved away

`vx1`–`vx23` (LAW A) and `vy1`–`vy19` (LAW B), all on real v1.87 goldens,
every rc recorded.  Scored PER CELL by the verifier's own lister and
transition scorer (`lister90v.py`, `celltrans90v.py`, both shipped here),
keyed `kind|fullname|span` and counted as a MULTISET, over the 163 of 170
arms that have all three dumps (the other 7 are NAMED, never dropped):

```
MATCH -> MATCH      1725      MOVED-WRONG (MATCH -> non-MATCH) = 0
OURS-ONLY -> ABSENT   95      set-wise AWAY                    = 0
GOLD-ONLY -> GOLD-ONLY 13     MATCH cells pristine=1725 law=1725
OURS-ONLY -> OURS-ONLY  5     COUNT -> COUNT 2
```

A SECOND instrument for LAW B, because the cell scorer is blind to a field
INSIDE a `cont_assign`: `dlycell90v.py` scores every `vpiDelay` subtree
as a multiset against golden.  **Golden delays pristine matched and the law
does not: 0.**  Pristine matched 0 param-ref delays; the law matches every
one, in both views, on `vy12` 4/4, `vy8` 4/4, `vy5` 3/3, `w15` 3/3,
`vy14` 3/3.  On `vy17_dlyifnested` (an interface inside an interface) the law
writes golden's two faces BYTE FOR BYTE — def `ref_obj (work@inner.D)`
unbound, elab `ref_obj (work@dut.u_out.u_in.D)` with
`vpiActual -> parameter` — which is why that arm's cmp line count RISES
722 → 726 while moving TOWARD golden: the head object never changed and the
four new lines are the ref's own.

New conversions to `cmp_rc=0` on verifier arms: `vx1` 152→0, `vx4` 198→0,
`vx5` 152→0, `vx8` 78→0, `vx10` 135→0, `vx11` 206→0, `vx13` 152→0,
`vx14` 150→0, `vx15` 174→0, `vx22` 166→0, `vx23` 196→0, `vy1` 16→0,
`vy4`/`vy5`/`vy6`/`vy7`/`vy8`/`vy9`/`vy12`/`vy15`/`vy19` 16–18→0.

### 3a. THE ONE THING THE IMPLEMENTER'S GRID COULD NOT SEE

`u5_strread` reads the dropped net HIERARCHICALLY, from outside its home.  No
shipped arm referenced the dropped name inside the home's OWN body.  Five
verifier arms do (`vx2` read, `vx3` driven, `vx16` port connection, `vx19`
procedural read, `vx18` the interface twin), and there **golden mints an
IMPLICIT NET at the first reference's span** — `work@sub.w_str` at `5:24`,
`5:10`, `8:16`, `7:19`, bare `vpiNetType:1`, no typespec — in the module,
program and top homes in BOTH views, and in the interface home in the
ELABORATED view only (`vx18`: golden's `work@ifc` lists none, golden's
`work@dut.u_if` lists one).  A reference from a nested GENERATE scope mints
nothing at all (`vx17`: golden writes the ref and no net anywhere).

This is NOT a regression.  Per cell every one of those arms IMPROVES —
`vx2` 4 wrong cells → 1, `vx3` 4 → 1, `vx16` 5 → 2, `vx19` 4 → 1,
`vx17` 3 → **0**, `vx18` 3 → 1 — because the drop removes three OURS-ONLY
cells and leaves the one GOLD-ONLY cell that was already there.  Their cmp
line counts RISE (`vx2` 8→169, `vx3` 8→209, `vx16` 8→143, `vx19` 30→251)
purely because the net VECTOR SIZE now differs and the vector overload dumps
both containers: §7's "a line count going UP is fine when the head object
CHANGED", measured rather than assumed.  A conservative guard that kept our
declaration net instead would have put those OURS-ONLY cells BACK, so no fix
was applied.  **The mint is this pass's true R0.**

## 4. Census — reproduced, and its reason corrected

The verifier's own census (`census90v.py`, discovery taken from
`verify_golden.py` itself, scanning every `.sv/.v/.svh/.vh` under each
discovered row's directory — a SUPERSET of the compiled set) with its own
positive control (the verifier grid: 34 LAW A rows, 27 LAW B rows, fires):

```
surelog     rows=798  files=10314  LAW A sites=6   LAW B sites=203
uhdm2rtlil  rows=871  files=2171   LAW A sites=0   LAW B sites=0
```

Same files the implementer found — `XilinxUnisimLibrary`, `Icarus/ivltests`.
**The implementer's stated reason is wrong.**  They wrote "no discovered
corpus row names any of those files"; the rows `Icarus` and `Unisim` DO reach
them, through `-batch batch.txt` (`drive_strength1.v` and `sched1.v` are named
in Icarus's `batch.txt`; `ICAPE2.v`, `ICAPE3.v`, `glbl.v` and the
`*DELAYE2*` files in Unisim's).  The correct reason is stronger and is in the
committed baseline: **both rows are `SLANG_REJECT` in BOTH modes** —
`error: no input files` (default) and `batch.txt:1:1: error: expected member`
(testflags) — so our exporter never compiles a single one of those files.
The population REACHABLE by our emitter is zero, and that is why the emitter
trace reads zero.  Conclusion unchanged; its ground is now load-bearing.
If `-batch` is ever supported, those two rows become the corpus's first LAW A
and LAW B sites.

## 5. Gating — verified on 170 arms, not 126

`sw90v.sh` (the verifier's own ledger, shipped here) over the whole grid:
**`R11U90_OFF=1` reads `0` on every one of the 167 compilable arms** — the law binary
with all three switches off is the base, object for object.  Each switch
returns exactly its own law's arms and disturbs no other: `R11U90_DLYREF_OFF`
returns all 21 LAW B arms to 0 and leaves every LAW A arm at its patched
reading, and vice versa.  The two LAW A faces are independent in both
directions: `u12_strnonansi` `STRCELL_OFF=0 / STRNET_OFF=52` (only the cell
law fires) and `vx7_strchargebig` `STRNET_OFF=0` (only the net law fires).

## 6. The five gates, re-run end to end

1. **Binaries** — above.  `results/*.csv` read-only; `src/ParamEmit.cpp`
   untouched (`git diff` empty) and `src/ModuleEmit.cpp` carries 0 `__LINE__`
   against ParamEmit's 30, so the sister pass's ground is undisturbed.
2. **Goldens** — law `23 PASS / 0 FAIL`, pristine `23 PASS / 0 FAIL`,
   negative control `SLANG_UHDM=/bin/false` `0 PASS / 23 FAIL`.
3. **uhdm2rtlil, both modes** — `ct8rows.sh` PASS on the committed gate CSV
   and on the verifier's own pristine sweep, both modes; and a direct join of
   `results/golden_uhdm2rtlil.csv` split per mode: **871 rows per mode, 0
   differing in status OR dump column**, histogram `788 CMP_EQUAL / 16
   CMP_NOTEQUAL / 67 SLANG_REJECT` in each — the OPS baseline exactly.
4. **surelog, `--mode both`** — status histograms byte-identical across
   committed, verifier-pristine and verifier-law: `474 / 9` default,
   `469 / 8` testflags.  vs the committed baseline **4 rows differ, and the
   SAME 4 differ on the verifier's PRISTINE binary**, which is the proof they
   are environment: `Earlgrey_0_1` ×2 (status stays `CMP_EQUAL`, only the DUMP
   column goes blank — the uhdm-dump draw the OPS names) and
   `LowMemLib`/`LowMemPkg` testflags (`SURELOG_FAIL` whose detail embeds the
   workdir path).  **pristine vs law: 2 rows differ and the only difference
   inside them is `pris` vs `lawx` in the embedded log path — ZERO
   law-attributable rows.**
5. **byteverify `SELFCHECK=1`**, verifier-law vs verifier-pristine workdirs:
   * u2r `PATH_SETS_IDENTICAL (1608)`, **`MOVERS: 0 / 1608`**, selfcheck
     `1607 / 1608`.
   * surelog `PATH_SETS_IDENTICAL (960)`, **`MOVERS: 5 / 960`**, selfcheck
     `959 / 960` — `MiniAmiq` ×2, `SeqDriver` ×2, `SimpleUVM`, the family the
     OPS names.  Each attributed ORDER-BLIND (sorted, path- and
     id-normalised) to a **4-line `UINT:` / `vpiDecompile:` line-number pair**
     and nothing else — no net, no `cont_assign`, no delay.
     POSITIVE CONTROL MEASURED HERE: the PRISTINE binary, run FOUR times on
     `default/MiniAmiq`'s own replayed command line, gives four different
     database hashes (`0d31b2e20d46`, `2d8392333596`, `4d61e9434f79`,
     `56a57f8c50e9`) and every pairwise order-blind diff is that same class
     (`UINT:1289 <-> 0 <-> 1299 <-> 1088`).

**Pins, read from the law binary's own workdir, all held both modes:**
`SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
`InterfaceModPort 59a365f3ce2c` (watched byte-for-byte),
`Earlgrey_0_1` default `8bdf25272e08` / testflags `59d0ee6d10c3`;
`BlackParrotComplex` and `YosysOldOr` identical pristine↔law.
`rowheads.sh`: all seven conversion rows `cmp rc=0` in BOTH modes
(`Scoreboard`/tf and `Rggen`/tf SKIP-NOFILE as expected).
`canaries.sh` surelog `ok=50 changed=2` **on BOTH binaries** — the two are
`Earlgrey_0_1`'s blank dump column, status `CMP_EQUAL`; u2r `ok=8 changed=0`;
both `ctcan2.sh` PASS; `canaudit.sh` PASS after the fix below.

## 7. THE FIX

`GATES.r11u90.txt` spelled the four slang-fenced names in prose while
documenting the fence check, and `canaudit.sh` audits every file in this
directory except itself and the `README*` records.  Measured on the shipped
tree: **`FENCE-BREACH=4`, exit 6** — the integration cycle's own mandated gate
would have gone RED, against a report claiming `FENCE-BREACH=0`.  The fix
rewords that block so it names no fenced test; nothing else changed.  The
production surface is untouched by the fix, so no binary, dump, sweep or
measurement in this record moves.  Re-run: `audited=29 UNCOVERED=0
FENCE-BREACH=0`, rc 0.  The production diff itself was clean throughout:
**0 occurrences of any fenced name in `git diff 05399931 -- src include`**,
and no driver dispatches one.

## 8. RESIDUES the verifier adds or corrects (ranked)

1. **R0 — THE IMPLICIT-NET MINT the drop uncovers.**  §3a above.  Golden mints
   a bare `vpiNetType:1` net, no typespec, at the FIRST reference's span,
   whenever the dropped name is referenced by a DIRECT member of its home's
   body — module/program/top in both views, interface in the ELABORATED view
   only — and mints nothing for a reference from a nested generate scope.
   `vx2`, `vx3`, `vx16`, `vx18`, `vx19` (1–2 cells each); `vx17` proves the
   generate boundary and is already at 0.  This is now the single remaining
   cell on five arms, and it is the drop's own shadow.
2. **The PROGRAM home writes no net-decl-assign cell at all** — the
   implementer's R0, CONFIRMED independently: golden's elaborated
   `work@dut.u_p` carries `vpiNet w_plain` and **no `vpiContAssign` vector at
   all** (`u10_strprog`, head `LHS:<null>`, 53 lines), while the module and
   interface homes both list one.
3. **`u12_strnonansi` is TWO faults, not one.**  The implementer named the
   ORDER only.  Measured: golden lists `[p@6:15, o@2:13]` and we list
   `[o@5:32, p@6:15]` — the order is the head, AND golden anchors the net `o`
   at its non-ANSI PORT declaration (`2:13`) while we anchor it at the
   strength declaration (`5:32`), in `work@sub` and `work@dut.u_s` alike.
4. **The net-DECLARATION delay written as a parameter name is untouched**
   (`v22_ndadelayparam`, 25 lines, `DELTA=0`, golden `rc=0`).  LAW B reaches
   only the cont_assign call site; the two net-decl-assign call sites pass
   `scope=nullptr` and keep the base's constant.  Unnamed in the
   implementer's residue list and live in the interface home.
   `vy3_dlyimportparam` (25 lines) is the explicit-package-import twin of
   their `#pk::PD` residue, in the module home.
5. The `supply0`/`supply1`/`trireg` net-type constants (`u8`, `u14`,
   `vx21_strsupplyparen` — 29 lines each, head is the `s0` net's typespec),
   `#(D)`'s min-typ-max wrapper, the delay operand tree, `#dv`/`#pk::PD`, and
   the generate scope's missing `vpiDelay`: all re-measured, all unmoved,
   all as the implementer ranked them.
6. An enum-value delay name is correctly declined (`vy18_dlyenumname`,
   `DELTA=0`, 18 lines both binaries) — golden writes a ref there too, so it
   joins residue 5's family.

Hygiene nit, not a gate: `score90.sh` names its scratch `/tmp/r11u85_sc_*.$$`
— another pass's tag.  PID-suffixed and removed, so it cannot collide.

## 9. HOW TO RE-RUN THE VERIFIER'S OWN MEASUREMENTS

The 41 arms of `grid.verifier/` and the instruments below are shipped inside
this directory; none hard-codes a scratch path (`GRID`/`REPO` default sanely).

```bash
H=tools/probe/r11u90repro
GRID=$H/grid.verifier bash $H/vrr90v.sh <pris-bin> <law-bin>    # ONE golden per arm, BOTH binaries, every rc
GRID=$H/grid.verifier bash $H/sw90v.sh  <pris-bin> <law-bin>    # the switch ledger; R11U90_OFF must read 0 everywhere
GRID=$H/grid.verifier python3 $H/celltrans90v.py                # PER-CELL transition matrix + MOVED-WRONG + set-wise AWAY
GRID=$H/grid.verifier python3 $H/dlycell90v.py                  # the vpiDelay subtree scorer (LAW B's own cells)
python3 $H/lister90v.py <gold.dump> [<ours.dump>]               # the SHAPE LISTER, per holder, multiset-safe
GRID=$H/grid.verifier python3 $H/census90v.py --control         # census POSITIVE CONTROL (must fire)
python3 $H/census90v.py                                         # both corpora, superset file scan
```

Readings shipped beside them: `GRID.r11v90.txt` (170 arms, both binaries,
every rc), `SWITCHES.r11v90.txt` (the gating ledger, 170 arms),
`CELLTRANS.r11v90.txt` (the per-cell transition matrix),
`DLYCELL.r11v90.txt` (the vpiDelay scorer) and `CENSUS.r11v90.txt` (both
corpora; the only written sites live in the two `-batch` rows, which are
`SLANG_REJECT` in both modes).
