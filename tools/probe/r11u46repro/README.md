# r11u46 — the missing `$unsigned(genvar)` operand in a def-view `gen_for` condition

Base commit `2bbb8fae`.  Pristine binary md5 `d82adeb552c6e4f42b50568702897292`
(byte-identical to the main tree at the base), law binary md5
`6149b15131bcc9665d0c0ad02d6274d4`.  Both frozen read-only before any sweep;
every `cmds.txt` in every workdir names the frozen path.

## 1. The head, re-measured at the base

`uhdm-cmp golden.uhdm slang.uhdm`, one head per run (`grep -c '^LHS:'` = 1 on
all four runs), LHS golden:

```
LHS:                                          RHS:
operation: , line:12:26, endln:12:54          operation: , line:12:26, endln:12:54
|vpiOpType:20                                 |vpiOpType:20
|vpiOperand:                                  |vpiOperand:
\_sys_func_call: ($unsigned), 12:26..12:42    \_ref_obj: (…NumLevels), 12:45..12:54
  |vpiArgument:
  \_ref_obj: (work@genvar_pow_index.level)
    |vpiActual: int_var (…level), 12:15
  |vpiName:$unsigned
|vpiOperand:
\_ref_obj: (…NumLevels), 12:45..12:54
```

`genvar_pow_index` (u2r, both modes) and `arb_idx_cast` (u2r, both modes,
`work@dut`, dut.sv:18) carry the SAME head, object for object.  Both designs
write `for (genvar level = 0; unsigned'(level) < NumLevels; level++)`.  Golden's
def-view condition is a two-operand `operation` (opType 20); ours has ONE
operand — the cast-wrapped genvar is absent.  Full texts in
`evidence/HEAD.pristine.*.cmp`.

`genvar_pow_index`'s ENTIRE order-blind whole-dump residue against golden is
that one subtree — **NETDIST 13**, nothing else
(`evidence/CENSUS.genvar_pow_index.pristine.netdist13.txt`), which is why this
head was the survey's only PROVED conversion.

## 2. The producer, decoded

`unsigned'(x)` / `signed'(x)` parses in slang as `SignedCastExpressionSyntax`
(SyntaxKind::SignedCastExpression), a DIFFERENT node from `int'(x)`
(`CastExpression`).  Our def-view expression emitter, `emitSyntaxExpr`
(`src/TypeEmit.cpp`), had an arm for `CastExpression` and NO arm for
`SignedCastExpression`, so the node fell through to the `default:` label, past
`InsideExpression`, `ConditionalExpression`, `mapSyntaxUnaryOp` and
`mapSyntaxBinOp`, and returned `nullptr`.  Every caller pushes only non-null
operands (`if (auto* l = emitSyntaxExpr(*be.left, op)) operands->push_back(l);`),
so the operand was DROPPED — not mis-shaped, absent.

Surelog rewrites a signing cast into the SYSTEM FUNCTION CALL of the same name:
a `sys_func_call` named `$signed` / `$unsigned`, located across the WHOLE cast,
with the inner expression as its single `Tf_call_args` element at the inner
token span (parentheses dropped), parented at the enclosing operation.  It sets
no `Scope` and no typespec; `tf_call::Compare` reads `Scope`, `Tf_call_args`
and `VpiName`, and `sys_func_call::Compare` adds `VpiFuncType` / `VpiUserDefn` /
`User_systf` — all default on both sides.

Our BOUND (elaborated) emitter already built the call; only the syntax view was
blind.

## 3. The golden grid — 27 cells, three grids, every arm rc=0

`grid/grid.sv`, `grid/grid2.sv`, `grid/grid3.sv`, each run through the pinned
Surelog v1.87 (`-parse -nobuiltin -nocache -sv -d uhdm`, rc=0, 0 FATAL/SYNTAX/
ERROR) and through both of our binaries (`--single-unit`, rc=0).  Scored by
`gridread.py`, a VIEW-AWARE shape lister that counts `$signed`/`$unsigned`
`sys_func_call` objects per source cell, split at `|uhdmtopModules:` into the
DEF and ELAB views.  Calibration golden-vs-golden is `CELLS-DIFF 0` on all
three.  Full table in `evidence/GRID.r11u46.txt`.

| grid | cells | pristine wrong | law wrong |
|---|---|---|---|
| grid.sv  (cast kinds × genvar positions × condition shapes × views) | 15 | 13 | **0** |
| grid2.sv (package-parameter reads inside the cast, elab view)       |  6 |  5 | **0** |
| grid3.sv (the remaining def-view emitSyntaxExpr positions)          |  6 |  4 | **1** |

What the grid says:

* Golden writes the call in EVERY def-view position — gen_for condition (LHS,
  RHS, nested in a binary, under a unary, both operands at once), loop INIT,
  loop INCREMENT, gen_if condition, gen_case selector, a net range bound, an
  interface's own gen_for, a def-view gen-block continuous assign, a
  concatenation element, a function-call argument, a module parameter default.
  `signed'` spells `$signed` on the identical rule (grid.sv row B).
* Golden writes NOTHING in the two cells that never reach `emitSyntaxExpr`: a
  loop wrapped in an explicit `generate … endgenerate` region (grid.sv row O —
  the landed placeholder law, which keeps the region's begin EMPTY) and a
  parameter OVERRIDE actual (`leaf #(.W(unsigned'(M)))`, grid3.sv row V), which
  folds.  Both are unchanged by this pass; their witnesses stay.
* `int'(f)` (grid.sv row F) produces no `sys_func_call` on either side — the
  `CastExpression` arm is untouched.
* **grid2 rows Q and R**: golden FOLDS a package parameter read INSIDE the cast
  argument — `q < unsigned'(PN)` becomes `$unsigned(<constant 5, UINT, size
  32>)` with a module-scoped `ref_typespec` onto a copy of the package
  parameter's own `int_typespec`, for the BARE and the QUALIFIED
  (`p46::PN`) spelling alike.  This is why the landed `genForCondPkgParamFold`
  walkers had to learn the argument vector (§4).
* The ONE law-side wrong cell is grid3 row X's ELAB half
  (`28:27:unsigned:ELAB`, golden 0 / ours 1): golden folds the elaborated
  gen-block assign `{4'b0, unsigned'(M[3:0])}` to a `constant BIN:00000011`
  while we keep the operation.  That object is PRE-EXISTING — pristine had it
  too — and lives on the bound path this pass does not touch.  Pristine scored
  row X wrong on BOTH halves (def missing + elab extra); the law scores it
  wrong on the elab half only.  Probe-only: no corpus row moves on it.

## 4. The law

`src/TypeEmit.cpp`, `emitSyntaxExpr`, a new
`case syntax::SyntaxKind::SignedCastExpression` immediately before the
`CastExpression` arm — § `signedCastSysFuncCall46`.  It mints the
`sys_func_call`, names it `"$" + signing.valueText()`, spans the whole cast, and
hands the inner `ParenthesizedExpressionSyntax` to `emitSyntaxExpr` (whose own
paren arm unwraps it, which is what puts the argument at the inner token span
golden uses).

`src/ModuleEmit.cpp`, the def-view `gen_for` builder, two walkers that until now
could only see operand vectors:

* `bindGenvar` — the genvar ref now sits inside a call's ARGUMENT vector, and
  golden binds it to the loop's `int_var` exactly as it binds a bare one
  (grid.sv row A: `ref_obj (work@grid.a) |vpiActual: int_var`).  Without this
  the new operand would carry an unbound `ref_obj` and the head would move
  rather than close.
* `foldPkgLoopRefs` — the package-parameter fold reaches THROUGH the argument
  vector (grid2 rows Q and R above).  `foldPkgLoopRef1` is unchanged; only its
  traversal learned the new container.

Nothing else changes.  The landed gen-scope laws keep their witnesses: the
explicit-`generate`-region placeholder (grid.sv row O), the interface expansion
(row P, which now matches golden INCLUDING the cast), the qualified/bare
package-parameter condition fold (§ `genForCondQualPkgParamFold19`, grid2 rows
Q/R), the loop-INIT fold (§ `genForInitPkgParamFold`, grid.sv row G) and the
postfix-increment quirk (row H).

## 5. Census — movers predicted BY NAME a priori, with a positive control

`predict46.py` (u2r) and the surelog predictor recover each row's own source
directory from the `sha1(dirpath)[:8]` the harness stamps into the workdir name,
read the row's actual slang command line out of `cmds.txt`, and flag every row
that compiles a file containing a signing cast.  **UNRESOLVED-DIRS 0.**

uhdm2rtlil — 5 candidate rows per mode: `arb_idx_cast`, `cfg_func_width_loop`,
`genvar_pow_index`, `ibex_compressed_decoder`, `static_cast_simple`.  Two of
those (`ibex_compressed_decoder`, `static_cast_simple`) are CMP_EQUAL at the
base and were the rows at risk.

Surelog suite — 8 candidate rows per mode: `Ariane2024`, `ArianeElab`,
`ArianeElab2`, `CastUnsigned`, `IncompTitan`, `rp32` (all SLANG_REJECT /
NO_DATABASE at the base — no database exists to move), plus `FuncStructVal`
(CMP_EQUAL, at risk) and `StructParamFuncBodyFieldCompare` (CMP_NOTEQUAL).
Both databased rows were pre-tested by hand with the law binary on their own
command lines: all four databases came back BYTE-IDENTICAL to their pristine
counterparts.  **Predicted surelog movers: ZERO.**

POSITIVE CONTROL for that zero: the identical hand procedure run on
`genvar_pow_index` reports MOVED, and the database it produces is byte-identical
to the one the law sweep wrote.  `byteverify.sh`'s own `SELFCHECK=1` flags
803/804 paths per mode.  A zero here is a measured zero, not a blind one.

MEASURED (byteverify, law workdir vs my own pristine workdir; full text in
`evidence/CENSUS.byteverify.r11u46.txt`):

```
u2r testflags     PATH_SETS_IDENTICAL (804)  MOVERS: 2 / 804   SELFCHECK 803/804
u2r default       PATH_SETS_IDENTICAL (804)  MOVERS: 2 / 804   SELFCHECK 803/804
    MOVER ./<mode>/arb_idx_cast-dbf8cde6/slang.uhdm
    MOVER ./<mode>/genvar_pow_index-c7bf081b/slang.uhdm
surelog suite     PATH_SETS_IDENTICAL (960)  MOVERS: 3 / 960   SELFCHECK 959/960
    MOVER ./default/MiniAmiq-544c7f61/slang.uhdm
    MOVER ./default/SeqDriver-32af76aa/slang.uhdm
    MOVER ./testflags/MiniAmiq-544c7f61/slang.uhdm
```

The two u2r movers are the two rows named before the sweep; nothing else in
that corpus moved.

The three surelog movers are the DOCUMENTED UVM pristine nondeterminism, and
they are attributed, not asserted (`evidence/CENSUS.uvm-coin.r11u46.txt`):

* each one's order-blind, path-normalised whole-dump distance pristine-vs-law
  is exactly **4 lines**, and every line is one half of a LINE-NUMBER attribute
  value (`UINT:<n>` + `vpiDecompile:<n>`) — the 0-or-4-line class RESUME.md §9
  names.  No structural object moved.
* POSITIVE CONTROL: the PRISTINE binary ALONE, run twice on MiniAmiq/default's
  own command line, produces two DIFFERENT databases (`5fae05d6d83a…` vs
  `27419f6011b4…`) — and `27419f6011b4` is exactly the md5 byteverify reports
  for the LAW MiniAmiq/testflags database.  The "law" hash is a value the
  pristine binary itself produces.
* Neither MiniAmiq nor SeqDriver compiles a file containing a signing cast, so
  the law cannot reach them.

Every UVM-family row stays CMP_EQUAL (Scoreboard/testflags stays SLANG_REJECT,
its committed state), and `rowheads.sh` reads 0 heads / `cmp rc=0` on
SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg and Earlgrey_0_1 in
both modes.

MOVED-WRONG 0, AWAY 0.

## 6. The scoreboard

**`genvar_pow_index` CONVERTS, both modes.**  The whole-row gate against the
COMMITTED `results/gate_uhdm2rtlil.csv` reports exactly one differing row:

```
< genvar_pow_index,testflags,CMP_NOTEQUAL,decompile:,,
> genvar_pow_index,testflags,CMP_EQUAL,,,match
```

and the same row in default against my own pristine CSV.  Its order-blind
whole-dump distance to golden goes **13 → 0** in both modes
(`evidence/CENSUS.genvar_pow_index.law.netdist0.txt` is empty).

**`arb_idx_cast` ADVANCES, it does NOT convert** — predicted loudly before the
run.  Its status stays CMP_NOTEQUAL in both modes; its database moved by exactly
the 13 lines of the `$unsigned` subtree
(`evidence/CENSUS.arb_idx_cast.pristine-vs-law.13lines.txt`), its order-blind
distance to golden goes 512 → 501, and its head moved OFF this face onto a NEW
one (`evidence/HEAD.law.arb_idx_cast.*.cmp`): an ELABORATED gen-scope localparam
`Idx1` that golden folds to `constant 1 / INT / size 32` with a `ref_typespec`
onto the localparam's own `int_typespec` (dut.sv:22:18..22:30) where we still
print `ref_obj Idx1` (`req_nodes[Idx1]`, dut.sv:28:64).

## 7. Gates

1. **Build.** Pristine md5 `d82adeb552c6e4f42b50568702897292` — byte-identical
   to the main tree at `2bbb8fae`.  Law md5 `6149b15131bcc9665d0c0ad02d6274d4`,
   reproduced byte-for-byte on a second build.  Both frozen `chmod 555` before
   any sweep; every `cmds.txt` in every workdir names the frozen path
   (`grep -o 'slang: *[^ ]*' cmds.txt` reads `/tmp/r11u46_{pris,law}.bin`).
2. **Goldens.** 23 PASS / 0 FAIL with the law binary; `SLANG_UHDM=/bin/false`
   gives 23 FAIL / 0 PASS (negative control).
3. **uhdm2rtlil, both modes.** Whole-row gate against the committed
   `results/gate_uhdm2rtlil.csv` and `results/golden_uhdm2rtlil.csv` and against
   my own pristine CSVs: exactly the two `genvar_pow_index` rows differ, both
   CMP_NOTEQUAL → **CMP_EQUAL / dump match**.  781/23/67 → **782/22/67** in both
   modes.
4. **Surelog suite, `--mode both`.**  My own pristine sweep reproduces the
   committed baseline EXACTLY (474/9 default, 469/8 testflags).  The law sweep
   scores the same 474/9 + 469/8.  Three rows read differently from the
   committed CSV and none is an exporter move:
   * `Earlgrey_0_1` default+testflags — the DUMP COLUMN reads blank (the
     documented uhdm-dump timeout draw).  Status stays CMP_EQUAL in both modes,
     **and my own PRISTINE run reads blank the same way**, so it is not a law
     effect.  The database pins hold: default `8bdf25272e08`, testflags
     `59d0ee6d10c3`.
   * `LowMemLib` / `LowMemPkg` testflags — SURELOG_FAIL on both sides; the only
     difference is the WORKDIR PATH quoted inside the row's `detail` text.
   * `YosysOpenSparc` default — SLANG_REJECT in the committed CSV and in my
     pristine sweep, SURELOG_FAIL in the law sweep.  That is a GOLDEN-SIDE
     failure (`[INF:UH0708] Writing UHDM DB …` — Surelog itself died writing the
     giant database under three-way CPU contention).  Re-run alone with the LAW
     binary the row comes back **SLANG_REJECT**, the committed value.  Our
     exporter rejects this test with both binaries, so it can never carry a CMP
     status at all.
5. **Byte census.**  §5 above: 2 + 2 predicted u2r movers, 3 attributed UVM coin
   flips, SELFCHECK live on all three runs.
6. **Canaries / pins.**  `canaries.sh` u2r ok=8 changed=0; `canaries.sh` surelog
   ok=50 changed=2 — the two are Earlgrey_0_1's blank dump column above, status
   unchanged.  `ctcan2.sh` PASS on both corpora.  `canaudit.sh` audited=29
   UNCOVERED=0 FENCE-BREACH=0.  HARD byte pins hold in both modes: SVSwitch
   `4842211c4030`, YosysVerx `6ccda350c24a`.  STATUS pins byte-identical to my
   pristine: InterfaceModPort `59a365f3ce2c`, BlackParrotComplex, YosysOldOr.
7. **`results/*.csv` untouched** — read only.

## 8. Reproducing

```bash
# the grids (both producers, rc recorded, calibration first)
cd grid
surelog -parse -nobuiltin -nocache -sv -d uhdm grid.sv      # -> slpp_all/surelog.uhdm
$SLANG_UHDM grid.sv --single-unit -o ours.uhdm
uhdm-dump slpp_all/surelog.uhdm > g.raw; uhdm-dump ours.uhdm > o.raw
python3 ../gridread.py g.raw g.raw | tail -1        # CALIBRATION: CELLS-DIFF 0
python3 ../gridread.py g.raw o.raw                  # the table

# the a-priori mover prediction over a verify_golden workdir
python3 predict46.py <workdir> testflags

# the byte census (both controls mandatory)
SELFCHECK=1 bash byteverify.sh <law_workdir> <pristine_workdir>
```

## 9. Residues and R0

* **R0 — `arb_idx_cast`'s new head: a gen-scope LOCALPARAM read that golden
  folds in the ELABORATED view and we do not.**  `assign req_nodes[Idx0] =
  req_nodes[Idx1] | req_nodes[Idx1+1];` (dut.sv:28), with `localparam int
  unsigned Idx1 = 2**(level+1)-1+l*2;` declared inside the same gen-block
  (dut.sv:22).  Golden prints, at 28:64, a `constant` with `vpiDecompile:1`,
  `vpiSize:32`, `INT:1`, `vpiConstType:7` and a `ref_typespec` whose actual is
  an `int_typespec` at the localparam's own declared type (22:18..22:30); we
  print `ref_obj (…gen_other_levels.req_nodes.Idx1)`.  One head, both modes,
  identical text (`evidence/HEAD.law.arb_idx_cast.*.cmp`).  Order-blind
  whole-dump distance 501, so this head is a face of a larger cluster, not the
  whole row.
* **R1 — the elaborated gen-block CONCAT fold** (grid3 row X, probe-only): golden
  folds `assign out_o = {4'b0, unsigned'(M[3:0])};` inside an elaborated
  gen-block to a `constant BIN:00000011` of size 8; we keep the operation with
  the `$unsigned` call under it.  Pre-existing, on the bound path, no corpus row
  moves on it — but it is the same "elaborate-then-fold" family as R0 and the
  grid already isolates it in four lines of source.
* **R2 — `cfg_func_width_loop`** was a signing-cast CANDIDATE that did NOT move:
  its `unsigned'(2 ** (ENC[i].e - 1) - 1)` sits in a FUNCTION body that our
  def-view emitter reaches by another route.  It stays CMP_NOTEQUAL on a head
  that has nothing to do with this face.
