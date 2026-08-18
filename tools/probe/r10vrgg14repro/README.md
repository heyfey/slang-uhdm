# r10vrgg14 — ADVERSARIAL VERIFICATION of r10rgg14 § genvarIdxFoldRerender14

**VERDICT: ACCEPT WITH A VERIFIER FIX.** The law is real, the head is genuinely
cleared, and every headline number reproduces bit-for-bit from scratch.  The
shipped patch also carried **one wrong-value defect on legal SV** that none of
its own grids could see, and **one false model row**.  Both are fixed here;
the fixed patch is `/tmp/r10rgg14.verified.patch`.

Worktrees `/tmp/wt_vrgg14` (patched+fixed) and `/tmp/wt_vrgg14pris` (pristine),
both from a clean `3b318d6`.  Binaries frozen `chmod 555` at
`/tmp/vrgg14_bin/slang-uhdm-{BASE,PAT,VFIX}` BEFORE any sweep.

| binary | md5 | note |
|---|---|---|
| BASE (3b318d6) | `44f9087d5a1700a69ea4c0cd6053179c` | implementer's number, reproduced |
| PAT (shipped patch) | `794d7741ad65972a59bfd66bb93a68d4` | implementer's number, reproduced |
| VFIX (this pass) | `f456d44a0059ee0f89ce55e94ad6608d` | + the two fixes below |

## 1. The two verifier fixes

**FIX A — `src/ModuleEmit.cpp`: the instance-array slot→index map was inverted
for DESCENDING arrays.** See `GRID_v5_arrayranges.txt`.  slang builds
`InstanceArraySymbol::elements` ASCENDING from `range.lower()` regardless of the
declared direction; the shipped `range.left + step*k` produced a **wrong
number** for `sif dn [63:0]` and `sif rof [20:10]` (e.g. `rof[20-i]` → 10,11,12
where golden has 20,19,18).  Fixed to `range.lower() + k`.  Arm `cells/v5`
CONVERTS under the official `uhdm-cmp` in BOTH views: 36 lines / 1 head → 0 / 0.

**FIX B — `src/ExprEmit.cpp`: `^` is not reducible and must abstain.**
`ExprEval::reduceExpr` has rows for `vpiBitAndOp`, `vpiBitOrOp`, `vpiLShiftOp`,
`vpiRShiftOp`, `vpiArithLShiftOp`, `vpiArithRShiftOp` — and **no
`vpiBitXorOp` case at all** (grep the whole switch).  Golden therefore leaves
`arr[i^4]` as an unreduced `operation` (measured: `op=30`, two operands, both
views, arm `v1`/`a16`).  The shipped `srlgRedCt14` claimed `vpiUIntConst` for
`^`, so the emitter MINTED a folded constant where golden has none.  It abstains
now.  Judge-neutral (both spellings already fail on `VpiType`), but a documented
law that is false is a trap for the next pass.

## 2. Head decode, re-derived from the generated Compare (not carried forward)

`~/git-repos/UHDM/build/generated/src/expr.cpp:83` — `expr::Compare` reads
**VpiDecompile, then VpiSize, then Typespec**; `constant.cpp:58` adds
**VpiConstType** after the base call.  **`VpiValue` is never read; the span is
never read.**  The implementer's §1 is correct.

## 3. The 12 adversarial arms (`cells/v1..v12`), both views, three binaries

Slot-keyed census with a Compare-visible payload (`vcen.py` + `vscore3.py`),
keyed by the owner's `vpiFullName` + span, MISSING/EXTRA reported never dropped:

```
TOTAL over 26 cell-views (v1..v13): N=1416 golden-witnessed slots
  BASE ok=418   shipped PAT ok=758   verifier-fixed VFIX ok=770
  REGRESSION (PAT-right -> VFIX-wrong) = 0
  REGRESSION (BASE-right -> VFIX-wrong) = 0
  FIXED by the verifier = 12   (arm v5, both views)
```
On the implementer's own cells (`g1 g2 g3 pc1 pc2 pc4 pc5`, 14 cell-views):
`N=428  BASE 193  PAT 269  VFIX 269`, zero regressions — the fixes are INERT
there, and `pc1` converts (0/0) in BOTH views, not only `default`.

Arms: v1 expression zoo at an interface-array port actual (32 shapes) · v2 the
same zoo on a net array (the `ExprEmit` arm) · v3 homes (nested gen-for,
gen-if, case-generate, gen-for inside an interface) · v4 non-port positions
(cont-assign, procedural, localparam init, hier_path elements, part-select,
indexed part-select, module instance array) · v5 array range directions and
offsets · v6 genvar named like a parameter + shadowing · v7 >32-bit and
negative intermediate folds · v8 THE FENCE (based literals) · v9
multi-dimensional interface arrays · v10 ordered vs named vs reordered
connections · v11 module instance array inside a gen-for · v12 a loop that
starts at 3 and steps by 4 · v13 calls, `$clog2`, and package-qualified names
in the index.  `GRID_v1_shapes.txt` is the shape-by-shape table.

## 4. Every gate, run from scratch

| gate | BASE | shipped PAT | VFIX |
|---|---|---|---|
| goldens `tests/check_goldens.sh` | 23/0 | 23/0 | 23/0 |
| goldens with `SLANG_UHDM=/bin/false` | — | — | **0/23** |
| u2r both modes | 679/50/2 per mode | same | same |
| u2r rows vs BASE (status AND dump) | — | **0 of 1462** | **0 of 1462** |
| u2r testflags slice vs committed `gate_uhdm2rtlil.csv` | 0/731 | 0/731 | 0/731 |
| surelog both modes | 936 EQ / 20 NE / 567 REJ / 48 FAIL / 10 DEF / 3 NODB / 2 UNTR / 1 NOUHDM / 1 TIMEOUT | same | same |
| surelog rows vs BASE | — | **0 of 1588** | **0 of 1588** |
| surelog rows vs committed `golden_surelog.csv` | 0 | 0 | 0 |
| byteverify u2r (SELFCHECK=1) | selfcheck 1358/0 | **0 movers / 1358** | **0 movers / 1358** |
| byteverify surelog (SELFCHECK=1) | selfcheck 956/0 | **2 movers / 956** | **2 movers / 956** |
| boundary, 2,937 sources from a COPY of `tools/probe` | — | — | **listed 2937 = processed 2937, 0 MOVERS, 0 asymmetries** |
| boundary per-DIRECTORY | — | — | **listed 1358 = processed 1358, 0 MOVERS** |
| boundary POSITIVE CONTROL | — | — | **14 movers of 19** (the gate can see) |
| canaries (surelog) | ok=52 changed=0 | ok=52 changed=0 | ok=52 changed=0 |
| ctcan2 (surelog, EXPECT_UNKNOWN=1) | — | ok=58 changed=0 | ok=58 changed=0 |
| canaudit | — | audited=29 UNCOVERED=0 **FENCE-BREACH=0** | same |
| canary byte pins | — | — | `InterfaceModPort` `BlackParrotComplex` `YosysOldOr` identical both modes; `SVSwitch` **4842211c4030**; `YosysVerx` **6ccda350c24a** |
| `cmds.txt` audited BY BINARY PATH | — | — | u2r 1458/1462, surelog 1523/1573 carry the intended binary; every remaining file has no `slang:` line at all (SURELOG_FAIL / NO_DATABASE) |

**The two surelog movers are both attributed.**  `Rggen/default` is the target.
`Scoreboard/default` is the documented COIN — and it has **THREE faces, not the
two the implementer reported**: six runs of the *BASE* binary on one command
line gave `e651aa64…` ×4, `e7b0c9b4…`, `a1949b9d…`, and six runs of VFIX gave
the same three-face set (`COIN_scoreboard_3faces.txt`).  Face sets identical ⇒
the mover is nondeterminism, not the patch.

## 5. The target, re-measured

* Whole-dump `Rggen/default` diff BASE vs VFIX over **1,580,844 lines**:
  **109 removed / 109 added** and nothing else (a 110th line is the dump's own
  path header, which differs only by workdir — the implementer's 109 is right).
* VFIX's `Rggen` database is **byte-identical to the shipped patch's**: both
  fixes are inert on the target.
* Genvar-text `vpiDecompile` multiset on `Rggen`: golden **0**, BASE **30** in
  six texts (`10+i`×4, `14+4*i+j`×8, `2+i`×2, `4+i`×2, `6+7*i+3*j+k`×12,
  `6+7*i+6`×2), patched **0**.
* Owner-keyed check of all 30 changed constant sites against golden, keyed by
  the enclosing `bit_select`'s `vpiFullName` + span, payload = span + decompile
  + size + value + consttype: **MATCH-GOLDEN 30, MISS 0.**
* `rowheads.sh` over the seven named rows: identical BASE / PAT / VFIX
  everywhere except `Rggen/default` 36 → 64 (the next head object's decompile
  size, not a progress metric).
* R0 head decode reproduces the implementer's artifact byte-for-byte after id
  normalisation: `rggen_bit_field.sv:5:61`, golden `vpiSize 2` vs ours `64`,
  decompile `'b0` and ct 3 equal on both sides — `expr::Compare` fails on
  **VpiSize**.
* Mover prediction from the PRISTINE databases, re-run on MY workdirs:
  u2r **scanned 1358, predicted 0**; surelog **scanned 956, predicted 5**
  (`PackedArrayHighConn` ×2, `Rggen/default`, `YosysOldOr` ×2) — both files
  **byte-identical to the implementer's committed artifacts**.  Actual movers:
  u2r 0; surelog `Rggen/default` (predicted) and `Scoreboard/default` (the
  three-face COIN, which no static predictor can or should predict).  The
  `PackedArrayHighConn` / `YosysOldOr` predictions are the FENCE — based
  literals with no genvar — and correctly did NOT move: both abstain twice
  over, and `YosysOldOr` is byte-identical in both modes as a named canary.

## 6. Residues found by this pass, ranked

* **R-F (new, cheap):** `vpiModOp`, `vpiPowerOp` and `vpiConditionOp` ARE
  reduced by golden at this position and the model abstains on all three —
  `arr[i%2]` → `0` ct **7**, `arr[2**i]` → `1` ct **7** span=`2`,
  `arr[i?3:4]` → `4` ct 9 spanned on the CHOSEN BRANCH.  Three more `ExprEval`
  rows; measured here, not guessed.
* **R-G (new):** `arr[i^4]` — golden keeps an `operation`; we mint a constant
  either way.  Needs the emitter to leave the operation standing, i.e. a
  reducibility gate on the `genvarConnFold` arm itself.
* **R-H (new, refines the implementer's R-B):** a PARAMETER-only index folds in
  golden too — `arr[P+Q]` → `8` at **`vpiSize` 32**, the ADD's
  `max(sz0,sz1)` over the parameters' own 32-bit constants.  The genvar gate is
  what keeps the shipped 64 from being wrong here, so R-B and R-H are ONE
  family: "parameter-sized folds", and its size is `max` of the operands, not 64.
* **R-I (new):** a module instance ARRAY inside a gen-for
  (`ileaf u [1:0] (.s (sarr[16+i]))`) — golden emits the folded index constant
  on EVERY array element; we emit nothing at all (arm `v11`, 6 slots).
* **R-K (new, arm `v13`):** an index that is a CALL (`sarr[dbl(i)]`,
  `sarr[pk::twice(i)]`), a `$clog2(...)`, or a PACKAGE-QUALIFIED name
  (`sarr[pk::P + i]`) is folded by golden (`ExprEval::evalFunc`) and the model
  abstains on all of them — correctly, no fabricated numbers, base bytes
  preserved.  A plain module parameter in the same position (`sarr[P + i]`)
  folds and MATCHES.  These are the next reachable rows after R-F.
* **R-J (new, cosmetic but Compare-VISIBLE):** a connection written with a space
  before the bracket (`.s (dn [3+2*i])`) gives the synthesized `bit_select` the
  name **`"dn "`** with the trailing space, because the site splits `connRaw` at
  `[`.  `Compare` reads `VpiName`.  Pre-existing (BASE has it), zero corpus
  reach today, one `rtrim` to fix.
* The implementer's R-A / R-C / R-D / R-E are re-checked and stand as written.
