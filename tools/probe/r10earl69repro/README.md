# r10earl69 — § hpNameBareIdxFold69

**BASE `a621c25`.  Earlgrey_0_1, BOTH modes.  The head earl68 named as R0 is
CLEARED — 216 → 50 cmp lines in both modes, the whole 152-cell family to
golden per mode, with the two BEFORE logs byte-identical and the two AFTER
logs byte-identical.  The new head is in `PREDICT_R0.txt`.**

Pristine binary md5 `32bbd68862ba4da0bb03f6700bdf0241`,
patched binary md5 `15e3eb1ceb30c1fcfcbc2b322f8b1cd0`.
Golden caches (immutable, read-only): `00d4794526e44dc553f3` (default),
`d7348d2d2fe67abe767b` (testflags).

Baselines are this pass's OWN pristine sweeps, taken in this worktree with the
frozen pristine binary (u2r 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
per mode; surelog 936 CMP_EQUAL / 20 CMP_NOTEQUAL over 1,588 rows), and the
COMMITTED `results/gate_uhdm2rtlil.csv` / `results/golden_surelog.csv`, which
were only ever read.

---

## 1. The head, decoded before any code

```
LHS(golden): hier_path  id:311505  flash_phy_rd.sv 122:43-122:81
               |vpiName: read_buf[i].addr[7+:8]
RHS(ours)  : hier_path  id:253394           122:43-122:81
               |vpiName: read_buf[i].addr[FlashWordsW+:PageW]
```

`hier_path::Compare` (UHDM/build/generated/src/hier_path.cpp:110) runs, in
order, the VECTOR `SafeCompare(Path_elems())`, the singular
`SafeCompare(Root_value())`, and finally `lhs->VpiName().compare(...)`.  In the
pristine cmp log the two `Path_elems` vectors agree ELEMENT FOR ELEMENT — the
same `bit_select(read_buf)` with the same **unbound `ref_obj(i)`** index, the
same `indexed_part_select(addr)` with `vpiConstantSelect 1` and BOTH bounds
already folded to `UINT:7 sz 32` / `UINT:8 sz 32` with matching `int_typespec`
actuals at 38:13-38:16 and 14:13-14:16 — so the failing field is the LAST one
read, **VpiName**, and the MK line names the `hier_path` on both sides (neither
a `<null>` singular arm nor a vector size mismatch).  Read the MK line, not the
shape (RESUME §9).  `HEAD_R0_BEFORE_*.cmp` are the two logs.

The owner is `flash_phy_rd.sv:122`, inside
`…u_flash_eflash.gen_flash_banks[0].i_core.i_rd.gen_buf_match[0]`:

```systemverilog
for (genvar i = 0; i < NumBuf; i++) begin: gen_buf_match
  assign data_hazard[i] = buf_valid[i] &
      ( … (pg_erase_i & read_buf[i].addr[FlashWordsW +: PageW] ==
                        addr_i[WordW +: PageW]));
```

`FlashWordsW` and `PageW` are `parameter int`s of `flash_phy_pkg`, wildcard-
imported by `module flash_phy_rd import flash_phy_pkg::*`.

## 2. Where the name comes from, decoded not guessed

**Surelog does not spell a `hier_path`'s name from the source text.**
`CompileHelper::compileSelectExpression` (CompileExpression.cpp:1376-1546)
builds it by appending, per path element, that element's NAME plus the bracket
text `CompileHelper::decompileHelper` (CompileHelper.cpp:2544) renders **from
the element OBJECT**.  That dispatch is CLOSED and has no default arm:

| object | rendered as |
|---|---|
| `constant` | `VpiDecompile` |
| `ref_obj` | `VpiName` |
| `operation` | `ExprEval::prettyPrint` |
| `bit_select` | `"[" + (its constant / ref_obj / operation index) + "]"` |
| `part_select` | `"[l:r]"` |
| `indexed_part_select` | `"[b+:w]"` / `"[b-:w]"` |
| `var_select` | the concatenation of its exprs |
| **everything else** | **the empty string** |

> **§ hpNameBareIdxFold69** — a `hier_path`'s `VpiName` is A FUNCTION OF ITS
> PATH_ELEMS: a select bound the compiler REDUCED carries its VALUE in the
> name, one that stayed a reference carries its identifier.  We composed the
> name from the SOURCE SPELLING instead, which is why the head differed in
> `VpiName` **alone** — both sides' `indexed_part_select` bounds were already
> the same folded `UINT:7` / `UINT:8` constants.

Note what the same law says about the GENVAR in that name: `read_buf[i]`'s
index is still a `ref_obj` on BOTH sides, so `i` stays SPELLED.  The parameters
fold because their OBJECTS are constants, **not** because a gen scope folds
everything — which is exactly the distinction rgg17's port-actual family (where
the genvar itself IS folded, objects and name together) turns on.  The two
passes therefore compose without touching each other: this one is a NAME law
that reads whatever objects are there, that one is an OBJECT law.  Measured on
golden, arm `a1_hpname69.sv`, one `assign … read_buf[i].addr[<bounds>]` per row:

| written | golden DEF name | golden ELAB name |
|---|---|---|
| `[PP+:PW]` (package params) | `[PP+:PW]` | `[7+:8]` |
| `[LP+:LW]` (module localparams) | `[LP+:LW]` | `[7+:8]` |
| `[MP+:PW]` (module parameter) | `[MP+:PW]` | `[7+:8]` |
| `[PC+:PW]` (COMPUTED pkg param) | `[PC+:PW]` | `[4+:8]` |
| `[PW:PP]` (simple range) | `[PW:PP]` | `[8:7]` |
| `[7+:8]` (literals) | `[7+:8]` | `[7+:8]` |
| `[i+:8]` (GENVAR base) | `[i+:8]` | `[i+:8]` |
| `[PP + i+:8]` | `[PP + i+:8]` | **`[7 + i+:8]`** (param folds INSIDE the operation, genvar does not) |
| `[PP]` / `[LP]` bit-select index | `[PP]` / `[LP]` | `[7]` / `[7]` |
| `read_buf[PP - 7]` base index | `[PP - 7]` | `[7 - 7]` |
| `marr[i][1].addr[PP+:PW]` | `[PP+:PW]` | `[7+:8]` |
| the same read TWO gen blocks deep | — | **`[PP+:PW]`**, and its OBJECTS are `ref_obj`s too |

The last row is the proof that the name follows the objects rather than the
scope: the same text, one nesting level deeper, keeps BOTH the refs and the
spelling on golden.

**The other half of the model — and the fence.**  UHDM's POST-EXPORT
`ElaboratorContext` + `UhdmAdjuster` (uhdm_main.cpp:485-490, `--elabuhdm`
only) replace folded operations with constants **after** the name was composed
and never re-render it.  That runs on our side too, after this emitter, so
those cells are out of reach here by construction.

## 3. Calibration: golden is a FIXED POINT of the rewrite

`hpname69.cpp` reads a `.uhdm` DIRECTLY (never `uhdm-dump`: Earlgrey's dump is
>1 GB — the earl61-68 rule) and prints, per `hier_path`, its `VpiName` beside
the name a faithful transcription of `decompileHelper` renders from the
elements.  `hpfold69.py` is the PYTHON MIRROR of the emitter helper.

| measurement | result |
|---|---|
| whole golden cache: databases scanned | **3,673** |
| hier_path objects in them | **267,547** |
| `VpiName` == render(Path_elems) | **266,849** |
| exceptions | **698**, ALL one shape — the name carries an OPERATION's text (`SubAW - 1`, `7 - i`, `9 - 1`, `$clog2(64) - 1`, `byte_lane * 8`) while the object is a folded constant: the post-export elaborator cells above |
| **the rewrite applied to every golden database** | **0 names would change, in all 3,673** |
| the rewrite applied to the 2,314 pristine sweep databases (37,178 hier_paths) | **152 names change in `Earlgrey_0_1` default, 152 in testflags, and NOTHING ELSE — no other database in either corpus is touched** |

That corpus fence was run BEFORE the patched binary was gated, and it is what
predicted the mover set by name.

## 4. The code

ONE file, `src/ExprEmit.cpp`, **+285 lines, 0 removed**: a file-static
`hpNameBareIdxFold69` (with `hpBareIdent69` / `hpGrpEnd69` / `hpConstDec69`)
plus a call at each of the **21** `hp->Path_elems(elems)` sites in that file.

The helper implements ONLY `decompileHelper`'s `constant` row, and only where
the text now in the bracket group is a **single unqualified identifier**.  It
walks the name in lockstep with the elements and rewrites nothing else:

* a group is never added, removed or emptied, so every bracket-PRESENCE law is
  untouched — § hpTrailSelIdxDecompiled89's A/B convention,
  § hpMidSelIdxDecompiled79's empty-string rows, § hpMidSelIdxSelectIsBitSelectV79,
  § hpIdxBaseHierPathEmpty94 (`pend_req[].mask` and `mem_q[[k]].sbe.rd` keep
  their text because `""` and `"[k]"` are not identifiers);
* a group holding an OPERATION's text is never touched — that is exactly the
  698 golden cells above, and § hpIdxOpPrettyPrint92's `prettyPrint` dispatch
  is left entirely alone;
* a QUALIFIED `pkg::P` read is not an identifier here either, which is the
  measured "a qualified read keeps its text" rule (§ reducedImportedIdx);
* **any** parse mismatch between the name and the elements aborts the whole
  rewrite for that object (fail-closed), which is what makes the 21 call sites
  safe without auditing each builder's naming conventions;
* an element's `VpiFullName` is re-stamped only when it is EXACTLY the old
  running prefix — the same conservative test § hpIdxBaseHierPathEmpty94 uses.

It is placed AFTER `hpIdxBaseHierPathEmpty94` at the two sites that call it, and
is idempotent there (that law's output, `[+:32]`, has no bare-identifier part).

**No object moves.** The whole-expression census (`tscen69`, 162,259 cells per
mode) diffs to **ZERO lines** between the pristine and patched Earlgrey
databases: this pass changes names and nothing else.

## 5. Arms, scored JUDGE-FAITHFULLY

`hier_path::Compare` reads Path_elems FIRST, so a name change on a cell whose
elements already differ from golden is UNREACHABLE to the judge.
`armscore69.py` scores that way: a cell is `STILL-WRONG(ELEMS-DIFFER)`
whatever its name does.

`a1_hpname69.sv` — the grid above: 24 shapes × DEF/ELAB × 1-2 unrollings ×
nested gen blocks × module body.
`a2_fence69.sv` — the fence: package / local / module parameter bounds, an
OPERATION bound, a QUALIFIED bound, a literal bound, a function-call bound, a
SELECT bound, bare/genvar/operation base indexes, two-dimensional base selects,
a plain dotted read, and module-body copies of each.

```
ARM a1_hpname69  plain view  cells 54  STILL-RIGHT 24  TO-GOLDEN 16  AWAY 0  MOVED-WRONG 0
ARM a1_hpname69  elab  view  cells 54  STILL-RIGHT  2  TO-GOLDEN  4  AWAY 0  MOVED-WRONG 0
ARM a2_fence69   plain view  cells 38  STILL-RIGHT 10  TO-GOLDEN  8  AWAY 0  MOVED-WRONG 0
ARM a2_fence69   elab  view  cells 38  STILL-RIGHT  4  TO-GOLDEN  4  AWAY 0  MOVED-WRONG 0
```

Every negative control held: the operation bound, the qualified bound, the
literal bound, the call bound, the select bound and the genvar base index are
byte-identical to the pristine build in both views.

**The one over-reach, measured and bounded.**  Scored on the NAME ALONE, arm
a2 shows two cells moving pristine-right → patched-wrong: the module-body
`assign o[14] = st[0].a[LQ+:LW];`, where golden's `Width_expr` is a
`ref_obj(LW)` and OURS is already a folded `UINT:4` constant
(§ elabHierSelWidthFold over-fires there — a PRE-EXISTING object defect this
pass does not own).  Once the name follows the object, the name follows the
object's mistake.  It is judge-unreachable — `indexed_part_select::Compare`
reads `Width_expr` (generated/src/indexed_part_select.cpp) INSIDE the
Path_elems vector, i.e. BEFORE `hier_path::VpiName` — so the judge-faithful
score above shows **0 AWAY-GOLDEN**, and its corpus population is **zero**
(§3's fence: no database outside Earlgrey moves at all).

## 6. Gates (all run in this worktree, both binaries frozen at 555)

| gate | result |
|---|---|
| build both, md5 | `32bbd688…` pristine / `15e3eb1c…` patched |
| `tests/check_goldens.sh` (SLANG_UHDM exported per binary) | **PASS 23 / FAIL 0** on BOTH binaries |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags / default, both binaries | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| `ct8rows` u2r tf vs **committed** `results/gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** |
| `ct8rows` u2r tf + def vs this pass's own pristine sweep | **PASS, 0 differing rows** (status AND dump) |
| `byteverify SELFCHECK=1` u2r (1358 DBs) | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL |
| surelog `--mode both` (1,588 rows, 956 DBs) | status histogram **IDENTICAL** to pristine (936 CMP_EQUAL, 20 CMP_NOTEQUAL, 567 SLANG_REJECT, 48 SURELOG_FAIL, 10 DEFERRED, 3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM) |
| `ct8rows` surelog vs **committed** `results/golden_surelog.csv` | **PASS, 0 differing rows** (status AND dump, both modes) |
| `ct8rows` surelog vs this pass's own pristine sweep | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` surelog (956 DBs) | **MOVERS 4 / 956** = `Earlgrey_0_1` default + testflags (the PREDICTED set) + `Scoreboard`/default and `SeqDriver`/default, both **order-only** (sorted-dump diff **0 lines**) |
| Earlgrey both modes | head **CLEARED**, 216 → 50 lines, 1 head each; BEFORE logs byte-identical (`3dced0fa…`, identical to earl68's committed AFTER logs) and AFTER logs byte-identical (`f2ea546b…`) |
| whole-design hier_path NAME census, both modes | **152 TO-GOLDEN, 0 AWAY-GOLDEN, 0 MOVED-WRONG** out of 12,330 cells; 304 census diff lines = 152 × (before/after) and nothing else |
| whole-EXPRESSION census (`tscen69`, 162,259 cells) | **0 diff lines** — no object moved |
| golden-vs-golden calibration | golden re-read byte-identical; the rewrite changes 0 names in all 3,673 cached golden databases |
| corpus fence scan (2,314 pristine sweep DBs, 37,178 hier_paths) | only `Earlgrey_0_1` × 2 modes move, 152 cells each |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected DBs by md5 | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME** (both modes); SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `rowheads.sh` | **only Earlgrey moved** (216 → 50, both modes); SeqDriver 99202, SimpleUVM/Scoreboard 99106, MiniAmiq 99202, BuildUVMPkg 166, Rggen 194 all unchanged |
| WIDE boundary (3,187 `.sv`/`.v`, both views, both binaries) | **PROCESSED == LISTED**, 6,076 identical / 28 differing / 270 no_output — see §6b |
| per-DIRECTORY boundary (1,445 dirs, both views) | **PROCESSED == LISTED**, 2,638 identical / 19 differing / 233 no_output — see §6b |

`cmds.txt` audited by BINARY PATH in every arm (1,458 u2r + 1,523 surelog lines,
every one `/tmp/r10earl69_p{ristine,atched}.bin`), `SLANG_UHDM` exported
explicitly per binary, `GOLDEN_DEFER` unset, `results/*.csv` never written.
No row was converted: the two `Earlgrey_0_1` rows stay `CMP_NOTEQUAL` on a
deeper head.

### 6b. The boundary, and what every difference is

`vscore69.sh` / `vdirscore69.sh` do what a raw boundary cannot: they build the
GOLDEN for each differing unit with Surelog and score it judge-faithfully.
Across **all 14 differing files and all 10 differing directory units, in both
views: 0 AWAY-GOLDEN and 0 MOVED-WRONG.**

* `r10earl34repro/{a2_shape,v2_kinds,v4_paren,v5_init}.sv`,
  `r10earl37repro/{a2_fence,v1_stamp}.sv`, `r10earl_repro/{tj,vc}.sv`,
  `r10v65repro/a10_mp.sv`, `r10v66repro/v4_iface66.sv`,
  `r10vrgg17repro/cells/v1/v1.sv` and this pass's own two arms — every
  difference is either **TO-GOLDEN** or a name change on a cell whose
  Path_elems already differ from golden (judge-unreachable).
* `r10uvm75repro`, `r10uvm76repro`, `r10uvm88repro` (directory units only) —
  **pure ORDER COINS**: order-blind (sorted-dump) diff **0 lines**, and the
  PRISTINE binary run twice against ITSELF reproduces the same 14 raw lines
  (a `vpiTaskFunc` list order flip, the documented macro-buffer
  SourceLocation coin, RESUME §9).
* `r10buvm22repro/g22.sv` — **carries no name change at all**.  Its 12
  differing dump lines are three `array_typespec` range constants
  (`22198457` vs `22186169`, differing by exactly 0x3000) produced by a
  PRE-EXISTING TYPE-CONFUSION READ this pass discovered and did not touch:
  `src/TypeEmit.cpp:10345`, `buildUnpackedArrayTypedefTs`, does
  `ct.as<FixedSizeUnpackedArrayType>()` UNCHECKED, and for
  `typedef C22 ka_cls_t[string];` the canonical type is an
  `AssociativeArrayType`, so `fua.range.width()` reads garbage.  The value is
  stable per binary and per source (proved: three source perturbations and
  three `MALLOC_PERTURB_` values leave it unchanged) and moves only with the
  BINARY — this patch touches `src/ExprEmit.cpp` only.  Filed as a residue in
  `PREDICT_R0.txt`'s tail; it has ZERO corpus population (byteverify: no u2r
  or surelog database outside Earlgrey moves).
* SIGNALS: 20 wide + 10 dir rows of `rc=139`, **every one paired A and B** —
  pre-existing segfaults on both binaries, none introduced.

## 7. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `hpname69.cpp` — **new**: the hier_path NAME census.  Direct `.uhdm` reader;
  per hier_path it prints the positional key (section, owner instance path,
  site, positional route — never a span in the key), the `VpiName`, the name a
  faithful transcription of `decompileHelper` renders from the elements, and
  the per-element payload (kind, name, and for every index/base/width object
  the judge-visible fields plus span PRESENCE and span, payload only).
* `hpfold69.py` — **new**: the PYTHON MIRROR of the emitter helper, run over a
  census.  This is what proved golden is a fixed point and what predicted the
  mover set.
* `fencescan69.sh` — **new**: runs the census + mirror over every `.uhdm` under
  a root (a sweep workdir, or the whole golden cache).
* `armscore69.py` — **new**: the JUDGE-FAITHFUL 3-way scorer (Path_elems first,
  then VpiName), the only honest way to score a name-only law.
* `vscore69.sh` / `vdirscore69.sh` — **new**: build the golden for every
  boundary-differing file/directory and score it, so the boundary says WHICH
  WAY, not just "they differ".
* `tscen69.cpp` — the whole-expression census (unchanged from
  `r10earl68repro/tscen68.cpp`), used here as the "no object moved" proof.
* `sfam69.py` — the (golden kind, ours kind) pair census and the ranked
  superfamilies; run in BOTH directions this pass, which is how the new head's
  family was found.
* `vwide69.sh` / `vdir69.sh` — the recursive and per-directory boundaries; list
  on fd 3, children `</dev/null`, PROCESSED asserted.
* `earl69.sh` — one Earlgrey run, one binary, md5 printed, golden from cache.
* `runarm69.sh`, `cen69.sh`, `nospan69.sh`, `score69.py` — carried.
* `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `byteverify.sh`,
  `rowheads.sh` — the standard battery.
* `HEAD_R0_{BEFORE,AFTER}_{default,testflags}.cmp` — the four cmp logs.
