# r11v43 — the ADVERSARIAL VERIFICATION of r11u43, and the enum/union split it needed

Base commit `f98e6e2c`.  Worktrees `/tmp/wt_v11u43` (law) and
`/tmp/wt_v11u43pris` (pristine), both built from source by this verifier.
The judge is the official `uhdm-cmp` through `scripts/verify_golden.py`;
everything in this directory is measurement-only.  **`results/*.csv` ARE NOT
EDITED BY THIS PASS.**

## VERDICT — ACCEPT WITH FIX

r11u43's decoded law is right about the STRUCT face and every write-site
clause, and it is wrong about ENUM and PACKED UNION elements reached through a
TYPE PARAMETER: on seven arms of legal SV it writes `VpiSize` -1 where golden
writes the ELEMENT's width.  The verifier's fix is one added clause,
`aliasAnyTypeParam43` asked only of the enum and union arms; with it the law
writes no cell golden does not hold, on 172 arms across eight grids.

| binary | md5 |
|---|---|
| pristine (rebuilt from `f98e6e2c`) | `0442c5b6d15987b61261f7b3d67a0741` — the OPS-stated main-tree md5, byte for byte |
| r11u43 as submitted | `642b03fbd3cf6e2bd518a4168022ebb9` — the implementer's md5, byte for byte |
| r11v43 verified | `9811dc58e3d9c30bcba81581365e2bb2` |

## 1. WHAT REPRODUCED BIT FOR BIT

Rebuilt both binaries from source; both md5s matched the implementer's claim
exactly.  Re-ran the implementer's four generators and scored the arms with a
scorer written independently of theirs (`vscore.py`, view-sectioned by
`|uhdmtopModules:`):

* golden **84/84 rc=0 ERR=0 FTL=0 db=YES**; ours 83/84, `g33` rc=3 a genuine
  SLANG_REJECT (slang refuses `'0` onto a bare enum) — excluded from scoring.
* the 32 converting arms reproduce **NAME FOR NAME**: `g02 g03 g04 g09 g28 g31
  g32 g35 g38 g39 g40 h03 h08 h09 h12 h13 h15 i05 i06 i07 i08 i09 i11 i13 j01
  j02 j04 j05 j06 j08 j09 j11`; **0 REGRESS, 0 MOVED-WRONG** on those 84.
* every §3c element-width number reproduces (`g12`/`g13`/`h10` 8,
  `g18`/`g19`/`h01`/`h04`/`h05`/`h06`/`i12`/`i10`/`j03` 56, `j10` 1, `h02` 168,
  `j07` 56) and every one is UNMOVED.
* the landed fill laws' witnesses STAY: `g20`–`g25`, `g29`, `g30`, `h14`, `i04`
  are -1 on golden, pristine AND law.
* the NEUTRAL binary (`R11U43_OFF=1`) is byte-identical to pristine on all 172
  arms of all eight grids.
* the head, re-measured on this verifier's own pristine build, `grep -c '^LHS:'`
  = 1, both modes: golden `|vpiSize:-1`, ours `|vpiSize:168`, both `BIN:0`
  ct 3 decompile `'0`.  It CLEARS under the law, and the row's next head is the
  disjoint declaration-shape one — golden's elaborated view carries
  `vpiNet: packed_array_net arr` + `struct_net scalar_sig`, ours
  `vpiVariables: struct_var` for both.  Read out of golden's own database here.
* corpus: **780/24/67 both modes on uhdm2rtlil and 474/9 + 469/8 on the Surelog
  suite, on BOTH binaries** — the f98e6e2c baseline, unmoved.  The a-priori
  census (`vpred.py`, the neutral binary + the cell trace over each row's own
  recorded argv) predicts **2** movers on uhdm2rtlil by name and **0** on the
  Surelog suite; `byteverify SELFCHECK=1` measures exactly those 2 of 1608, and
  the moved bytes are **two lines per database**, `|vpiSize:168` → `-1`.
* the Surelog suite's byte movers are the documented UVM coin: 3 of 960,
  each **4 order-blind lines** of one `|UINT:<n>` + its `|vpiDecompile:<n>`
  line-number constant, **not one of them a `vpiSize`**.  POSITIVE CONTROL:
  three runs of the SAME PRISTINE binary on `MiniAmiq/default` give three md5s
  (`db2daa9fe934`, `25f36d639d25`, `308cfe7de892`) differing by that same
  4-line class.

## 2. THE BREAK — seven arms, measured, and the clause that fixes them

`mkvgrid3.py` / `mkvgrid4.py` ask the one question neither the implementer's
grid nor r11u25's asked: what does golden do with an ENUM or a PACKED UNION
element that reaches the declaration **through a type parameter**?

| arm | declaration | golden | pristine | r11u43 as submitted |
|---|---|---|---|---|
| `x01` | `#(parameter type T = pk::e_t)` · `T [2:0] x;` | **8** | 24 | **-1** |
| `x02` | `#(parameter type T = pk::un_t)` | **8** | 24 | **-1** |
| `x05` | `localparam type T = pk::e_t;` | **8** | 24 | **-1** |
| `x06` | `localparam type T = pk::un_t;` | **8** | 24 | **-1** |
| `x09` | `#(parameter type T = enum logic [7:0] {..})` | **8** | 24 | **-1** |
| `x13` | a localparam type aliasing a DEFAULTED enum type parameter | **8** | 24 | **-1** |
| `y05` | the enum type parameter at an ANSI PORT | **8** | 24 | **-1** |

against the plain typedef, which golden DOES keep raw — `g31` (`e_t [2:0] z0`),
`g32` (`un_t [2:0] z1`), `v02`/`v03`/`v42`/`y01`/`y02`/`y04`.  None of the seven
is a `pristine-right → patched-wrong`: pristine answers 24 and golden 8, so the
row's verdict is DIFF either way.  It is still a defect — a landed law must
never mint a cell golden does not hold, because the next pass reads the emitter
as the spec.

The **STRUCT** element is NOT split this way.  It keeps the raw fill through
exactly those aliases — `g02`'s `localparam type`, `j01`/`j09`'s defaulted port
type parameter, `x03`/`x07`/`x12`/`y03`/`y06`/`y09`/`y10`, and the corpus row
itself, whose `my_t` is a `localparam type` struct.  So the fix is asked only of
the enum and union arms and the struct face is left bit for bit as it was.

### The cost, stated

Two arms golden answers -1 for are declined with it: `y07`
(`typedef pk::e_t q_t; localparam type T = q_t; T [2:0] x;`) and `y08`
(`localparam type T = pk::e_t; typedef T q_t; q_t [2:0] x;`).  Golden
contradicts itself across that hop — the same `localparam type T` answers **8**
when its target is the PACKAGE typedef (`x05`) and **-1** when it is a
MODULE-LOCAL one (`y07`) — so it is not one rule.  A LOST CONVERSION is a
residue; a WRONG CELL is a defect.  Declined whole, left exactly as pristine
left them.

## 3. THE SCORE, all 172 arms, eight grids

| | EQ_EQ | CONVERT | DIFF_UNMOVED | **MOVED-WRONG** | REGRESS |
|---|---|---|---|---|---|
| r11u43 as submitted | 65 | 79 | 44 | **7** | 0 |
| r11v43 verified | 65 | 77 | 53 | **0** | 0 |

`JOIN.submitted.all.txt` and `JOIN.fix.all.txt` carry every cell.

## 4. GATES on the verified binary

Built `-j 2`, md5 taken separately, both binaries frozen `chmod 555` at
`/tmp/v11u43_bin/*.bin` BEFORE any sweep; every `cmds.txt` audited by binary
PATH (1742 u2r + 1531 Surelog per sweep, 100% the intended frozen binary, zero
stray `slang-uhdm` references).  `SLANG_UHDM` exported explicitly per binary;
`GOLDEN_DEFER` unset; no `git stash`.

* goldens **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**.
* uhdm2rtlil **780 / 24 / 67 both modes**; ct8rows PASS vs the `f98e6e2c`
  committed gate and vs this verifier's own pristine, both modes.
* Surelog suite **474/9 default, 469/8 testflags**; the only rows differing from
  the `f98e6e2c` committed baseline are the two `LowMemLib`/`LowMemPkg`
  SURELOG_FAIL detail strings that embed the workdir path and Earlgrey's
  dump-COLUMN draw — **all three appear identically on this verifier's own
  PRISTINE sweep**, so none is attributable to the law.
* byteverify `SELFCHECK=1` vs this verifier's own pristine workdirs: u2r
  **2 / 1608** (the two predicted by name), Surelog the UVM coin only.
* canary database pins HELD on both binaries: SVSwitch `4842211c4030`,
  YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
  BlackParrotComplex and YosysOldOr SAME, Earlgrey_0_1 default
  `8bdf25272e08` / testflags `59d0ee6d10c3`.
* `rowheads.sh`: SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg /
  Earlgrey_0_1 — **0 heads, cmp rc=0** (Scoreboard/testflags SKIP-NOFILE is the
  documented expectation).
* `canaries.sh` ok=52 changed=0 against this verifier's own pristine;
  ctcan2 PASS ×2; `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0.
  The four fenced names appear nowhere in the patch outside `canaudit.sh`, and
  no fenced test was dispatched.
* census POSITIVE CONTROL (`vctl.sh`): a source that MUST claim reads 2 claim
  lines, one that MUST NOT reads 0 with the site still reached, one that never
  reaches the site reads 0 trace lines at all.

## 5. A NOTE THE MASTER MUST READ

`f98e6e2c` is no longer the main tree's HEAD: pass 41 (`beb0c148`) landed
during this verification and promoted `struct_member_expr_index,testflags` in
`results/gate_uhdm2rtlil.csv`, which is why that file now reads 781/23 where
`f98e6e2c` reads 780/24.  Every number above is scored against the `f98e6e2c`
blobs this verifier's worktrees carry.  The verified patch was checked to apply
cleanly on `beb0c148` as well.

## 6. RESIDUES, ranked

1. **The corpus row still does not convert**, on the disjoint declaration-shape
   head (golden `packed_array_net` + `struct_net`, ours `struct_var`).
   Confirmed out of golden's own database.
2. **Golden's enum/union type-parameter face**, now DECLINED whole: `x01` `x02`
   `x05` `x06` `x09` `x13` `y05` at 8, against `y07`/`y08` at -1.  Whatever
   separates a package typedef from a module-local one through the same
   `localparam type` is the next decode on this face.
3. **The type-parameter DEFAULT refines clause (3)**, measured here and not by
   the implementer: golden keeps the fill RAW when the parameter's DEFAULT is a
   packed STRUCT even though the parameter is OVERRIDDEN (`w02` default
   `pk::s8_t` → `.T(pk::st_t)` = **-1**; `w05`, `w07` likewise), and sizes at
   the element width when the default is `logic` / a vector / an ENUM (`w01`
   `w03` `w04` `w06` = 56 / 1 / 56 / 56).  `isOverridden()` is therefore a
   CONSERVATIVE PROXY costing three measured arms; it never writes a wrong
   cell, so it ships unchanged.
4. **The `'1` fill at the same target**, r11u43's own R0-1, re-measured and
   CONFIRMED: `R11U27_OFF=1` does not remove the sized elab object, so a third
   site mints it.  Unmoved by this pass.
5. **`pk::st_t'('0)`** (`w20`): golden mints no constant at all in the
   `cont_assign` where we mint a 168-bit `UINT:0`.  A different face.
