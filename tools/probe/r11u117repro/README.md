# r11u117 — the typespec line, last head: the package-qualified member select flattens the package's elaborated struct pattern

**No row converts.** `stamped_gen_param` (uhdm2rtlil, both modes) moves off its
typespec head: **11 lines / 1 head → 64 lines / 1 head**, per mode. The head it
had at the base (golden's nameless `ref_typespec → struct_typespec q2::impl_t`,
ours `<null>`) is cleared. The new head is the generate-scope localparam value.
There, golden writes Surelog's single-bit garbage (`1'b0`, size 1) and we write
the correct element (`6'b010101`, size 6). After that head, golden's generate
STRUCTURE diverges from slang's elaboration. So the row cannot convert against
the pinned producer (section 6, R0).

* Surelog: 480/3 default, 474/3 testflags. Unchanged.
* uhdm2rtlil: 801/3/67 in both modes. Unchanged.
* `results/*.csv` were NOT edited.

Base `931a3c69`. Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `59c4a296bbc892558b6d637d7eff020e` | own worktree at `931a3c69`, `-j 2`; equals the main tree's binary |
| **LAW** | `b49a4e60de5c8db4a9b4b65dcf693465` | this patch, `-j 2` (a comment-only header edit was rebuilt and kept this md5) |

**Surface.** The patch touches only these files:

* `src/TypeEmit.cpp`: the helpers and switches.
* `src/ParamEmit.cpp`: three call sites. Each one is appended to an existing line, so the file stays at 33717 lines and every `__LINE__` is unchanged.
* `src/UhdmExporter.cpp`: one call site.
* `include/UhdmExporter.h`: declarations only.
* `tools/probe/r11u117repro/`.

It does not touch ExprEmit.cpp, EmitHelpers.h or StmtEmit.cpp (the sister pass's files), or `results/`.

Switches: `R11U117_OFF` drops everything. `R11U117_QSEL_OFF`,
`R11U117_BITS_OFF` and `R11U117_QSELREF_OFF` each drop one law.
`R11U117_DBG=1` prints the detectors (`QSEL117`, `QSELFIRE117`, `BITS117`).

---

## Q1. The row at `931a3c69`

The row reads 11 lines / 1 head in both modes (`evidence/HEADS117.txt`):

```
LHS:  ref_typespec: , id:537   |vpiActual: struct_typespec (q2::impl_t) 12:11-16:4   (no name, no vpiParent)
RHS: <null>
```

## Q2. The owning object, the producer's rule, our sites

**The object.** It is the Rhs `operation` (op75) of `q2::IMPL`'s `param_assign`
in the ELABORATED package listing (`uhdmtopPackages`). Golden FLATTENS that
listing:

* `vpiTypespec` is a bare `ref_typespec` with no name and no parent, actual `q2::impl_t`.
* The three operands are the member constants, positional.
* The `UnitTypes` operand is **size 36**, not 12, with no decompile.

Our base listing kept the `tagged_pattern` tree, so there was no op typespec at
that position.

**The producer** (all paths are in the pinned trees):

* The select `q2::IMPL.UnitTypes[grp]` sits in a generate-loop LOCALPARAM. Surelog
  compiles that parameter default through `CompileHelper::getValue`'s `pkg::NAME`
  arm (`src/DesignCompile/CompileExpression.cpp:870-947`). That arm replaces the
  package's own `param_assign` Rhs with
  `expandPatternAssignment(ts, rhs)` (`:941`).
* `expandPatternAssignment` (`src/DesignCompile/CompileHelper.cpp:5207`) first
  calls UHDM `flattenPatternAssignments` (`:5233`). That function clones the op
  and mints `ref_typespec* rtps = s.MakeRef_typespec(); opres->Typespec(rtps)`
  with **no name and no parent** (UHDM `templates/ExprEval.cpp:933-934`). The
  ref is nameless because nobody ever named it; it is not a copy.
* Next, the untagged arm walks the flat operands in member order and calls
  `adjustOpSize` (`CompileHelper.cpp:5114-5171`, `cop->VpiSize(ncsize)` at
  `:5155`). That call sets each constant to Surelog's `Bits` of the member
  typespec, **in place**. The shift guard (`:5433`,
  `if (shift < 0 || shift >= 64) return result;`) then returns the ORIGINAL
  tagged tree for any member of 65 or more bits. The members it already resized
  keep their new size inside that tagged tree: golden s02/t01/t02 show `vpiSize:72`
  inside `tagged_pattern`.
* `Bits` → `ExprEval::size` (`ExprEval.cpp:1354-1372`): a logic_typespec is
  `size(Elem) × Π(Ranges)`. Surelog spells `typedef ut_e [0:2] row_t` as a
  logic_typespec with Range `[0:2]` **and** an anonymous Elem logic_typespec that
  carries `[0:2]` again (golden dump, 4:11-4:21). The dims count twice:
  `row_t` = 3·3·2 = 18, and `row_t [0:1]` = 36.

**The earlier decode is superseded.** Pass 113's R2 said a "second gate" blocks
typedef'd-array members. That gate is in OUR walk, not the producer's. With the
trigger alone, a01 and a30 already flatten (grid g02/g03). Pass 113's R2 is this
same object.

**Our sites** (by grep, before editing):

* The flatten decision: `ParamEmit.cpp:14383-14412`, the SCOPED-REFERENCE and
  MEMBER-SELECT rules. `hasScopedPkgRef` (`TypeEmit.cpp:8655`) deliberately
  skips `pkg::NAME` inside a parameter declaration, so a WHOLE read there stays
  tagged (grid g10, GenIfIfaceParamStructField). `hasMemberSelectOf` counts only
  selects written in a package.
* The flat walk's op ref: `ParamEmit.cpp:15003-15007`.
* The operand sizing: `ParamEmit.cpp:15087-16232`, where `fld.getType().getBitWidth()` is used at nine places.

## Q3. The golden grid

The grid is in `grid/`, 67 arms. Golden is the pinned Surelog in the testflags
form (`grid117.sh`). Golden rc is 0 on all 67; every arm records its rc.

* **g1** (51 arms), face 1:
  * The trigger × position: generate-loop, module localparam, parameter port, interface localparam, direct instance override, cont-assign, function body, `$bits`, dead generate.
  * Member shape: typedef'd 2-D, plain vector, literal vs concat, nested struct, wide struct, unpacked, positional, `default:`, a parameter-ref value, a chained parameter, an import copy.
  * Size probes s01-s12 and t06-t10.
* **g2** (10 arms): every landed-grid arm that the control battery moved, re-scored against golden.
* **g3** (6 arms): face-3 R5 (b11 plus r02-r06).

Measured rules (golden, elaborated package listing):

| cell | golden |
|---|---|
| `pkg::P.m…` read in a module/gen/interface localparam or a port default (g01-g08, g14, g16, g17, t14, t20, t21, t23, t24) | FLAT, nameless ref |
| unqualified select after `import` (g12), dead generate (g13), whole read in a param decl (g10), never read (g18) | tagged |
| nested-struct member (g15) | tagged |
| a member with Surelog `Bits` > 64 (s02 72, s12 72, t04 70; also t01/t02 on the EXISTING roads) | tagged, the resized member keeps the size |
| wide struct with every member ≤ 64 (g14, 76 bits) | FLAT (the trigger outranks the WIDTH rule) |
| positional pattern (t17) | flat but UNTYPED, `UnitTypes` 36 |
| `UnitTypes` operand size | 36 (s01), 54 (s03 `logic[2:0]` elem), 16 (s04), 18 (s05 `row_t`), 32 (t09 `ut_e[0:1][0:1]`) |
| operand size, NOT doubled | 6 (s06 `ut_e[0:2]`), 12 (s08, s11, t07 non-typedef elem), 12 (t06 ENUM elem), 6 (t10 STRUCT elem), 6 (t08 alias of alias) |
| module import copy (t14 MELAB) | flat, 36 |

## Q4. The laws (each droppable alone, `evidence/DROPS117.txt`)

* **L1 § pkgQualSelParamFlat117** (`TypeEmit.cpp:24193`, called at
  `ParamEmit.cpp:14410`). A qualified `pkg::NAME.member` in a LIVE parameter
  declaration of the elaborated hierarchy is a fourth trigger, ranked with the
  member-select rule. Liveness uses the same walk as § pkgElabPatMemberStamp58.
  Its fences:
  * positional pattern (t17);
  * pattern-valued member (`patParamPatElem26v`, g15);
  * unpacked struct (t22, residue);
  * any member Surelog-`Bits` = 0 or > 64 (s02, s12);
  * symbolic dims, inherited from the existing rule;
  * `time`, which is not modelled.
* **L2 § pkgFlatSurelogBits117** (`TypeEmit.cpp:24121` `surelogBits117`,
  `:24356` recorder, `:24334` writer; called at `ParamEmit.cpp:16232` and
  `UhdmExporter.cpp:9756`):
  * **Scope.** It applies in the package's elaborated flat walk and the module
    import copy's (`topView && (inPackage || isImported)`).
  * **Which operands.** Up to and including the bail operand, an operand sized
    at its member's slang width gets Surelog's `Bits` instead. That only changes
    anything for the doubled typedef shape.
  * **When the write happens.** The write is DEFERRED to the end of
    `exportDesign` and lands on a CLONE. A module-side fold copies the operand
    while it is emitted, and golden keeps the reader's declared width (t20:
    interface `V` stays 12).
* **L4 § pkgQselRefNoParent117** (`TypeEmit.cpp:24329`, `ParamEmit.cpp:15006`).
  Only on L1's own cells: the op ref gets NO parent, the way
  `flattenPatternAssignments` mints it. It moves no judge field; it removes 6
  dump cells per arm that are otherwise AWAY.

Drops (dump-text compare, 134 arm-forms):

| switch | effect |
|---|---|
| `R11U117_OFF` | pristine on 134/134 |
| `QSEL_OFF` | moves 78 arm-forms (L1's) |
| `BITS_OFF` | moves 56 |
| `QSELREF_OFF` | moves 78 |

**Byte-level caution.** The database BYTES of flat-pattern arms vary from run to
run on the PRISTINE binary too (g19, t03 under parallel load). This class is
invisible in the dump. So drops and attribution use dump text.

## Q5. Census and the a-priori movers (`evidence/PREDICT_CENSUS117.txt`)

**The source predictor.** `predict117.py` walks both corpora with discovery
exactly as `verify_golden.py`. Two findings:

* The L1 shape (`pkg::NAME.m` in a param decl) appears in ONE row,
  `stamped_gen_param`. A whole-tree grep of Surelog `tests/` + `third_party/`
  finds 0.
* The L2 shape (typedef of a packed array of a user type) appears in 21 rows.

**The law detector.** Run with `R11U117_DBG=1` on all 21 candidate rows, both
modes, rc recorded (`pred117.sh`):

* Fires ONLY on `stamped_gen_param` (QSEL + BITS `UnitTypes 12→36`).
* The Ariane, fpnew and `unit_type_t` rows carry ENUM elements, which are not doubled. Or they are baseline SLANG_REJECT / SURELOG_FAIL / DEFERRED.

**The census on the sweep roots.** `cen117.sh` lists every op75 `param_assign`,
per section. Golden-vs-golden calibration reads 0. Its positive control is
`stamped_gen_param` ELAB `q2::IMPL`:

| db | op ref | operands |
|---|---|---|
| golden | NAMELESS | `@4 @36 @2` |
| pristine | none | tagged |
| law | NAMELESS | `@4 @36 @2` |

The other nine comparable candidates read 0/0/0.

**Predicted movers:** u2r `stamped_gen_param` ×2, and no Surelog row, apart
from the UVM pristine-nondeterminism class.

## Q6. Gates

1. **Build.** Pristine = main tree (`59c4a296…`). LAW `b49a4e60…`.
2. **Goldens.** LAW 23/0; `/bin/false` 0/23; pristine 23.
3. **u2r, both modes.** 801/3/67 per mode. The row-join vs `results/golden_uhdm2rtlil.csv` (both modes), vs `results/gate_uhdm2rtlil.csv` (testflags) and vs the own pristine all read **PASS, every row byte-identical**.
4. **Surelog, both modes.** Statuses are identical to the baseline and to the own pristine. The row diffs are environment only:
   * the Earlgrey_0_1 dump COLUMN, a timeout draw (the pristine sweep drew it on default);
   * the LowMem workdir paths.
5. **byteverify, SELFCHECK=1, same-length roots** (`/tmp/r11u117_swp/{pris,lawx}`), `evidence/BYTEVERIFY117.txt`:
   * **u2r 2/1608**: `stamped_gen_param` default and testflags. Both are predicted. Each is 83 contextual cells, all TO, AWAY 0.
   * **Surelog 4/960**: MiniAmiq ×2 and SeqDriver ×2. Each has a sorted dump diff of 4 lines, the documented UINT/vpiDecompile line-number class. They stay CMP_EQUAL.

**Pins** (`evidence/ROWS117.txt`), both modes, in both sweeps:

| row | database md5 prefix |
|---|---|
| SVSwitch | `4842211c4030` |
| YosysVerx | `6ccda350c24a` |
| InterfaceModPort | `59a365f3ce2c` |
| Earlgrey_0_1 testflags | `59d0ee6d10c3` |
| Earlgrey_0_1 default | `8bdf25272e08` |

BlackParrotComplex and YosysOldOr are byte-identical to the pristine.

**Battery** (`evidence/CANARIES117.txt`):

* canaries: Surelog ok=51, changed=1 (the Earlgrey dump-column draw); u2r ok=8.
* ctcan2: PASS both.
* canaudit: PASS.

**Controls** (`ctl117.sh`, `evidence/CTL117.txt`). The committed grids of r11u107/108/109/111/112/113/114/115 and v11u113/114/115 give 993 arms, 1986 arm-forms. SAME 1966, DIFF 20, RCDIFF 0.

* All 20 DIFFs are this pass's shapes: r11u114 a01/a29/a30, r11u111 k13/k14/s00/t10/t12, r11u108 k13/k14.
* Re-scored against golden in `grid/g2`: TO 779, AWAY 2.
* `r11u111 t12` CONVERTS (32 → 0).

**Per cell** (`cells117.py`, keyed by section + two enclosing objects + line; `evidence/CELLS117.txt`):

| grid | TO | AWAY |
|---|---|---|
| g1 | 3458 | 0 |
| g2 | 779 | **2** |
| g3 | 0 | 0 (R5 not landed) |

**The 2 MOVED-WRONG cells.** Both are the k14 arm (the same source in r11u108 and
r11u111). Its module localparam `UT = q2::IMPL.U` (a WHOLE typedef'd member)
used to be a `hier_path`, where golden has a constant. Once the package
flattens, it becomes a constant. That is golden's kind, but the decompile is
`6'b010110` where golden has `010110`, and the typespec ref is missing. That
constant comes from a module-side reader of the package's flat operands. It is
not in this pass's files: the reader is on the expression ground (ExprEmit,
where `patMemberSlot`, `ExprEmit.cpp:1025`, maps a member to its flat operand),
and the constant disappears under `R11U117_QSEL_OFF`. No corpus row has the
shape (the predictor finds only `stamped_gen_param`, which reads `[grp]`
elements).

## Row counts, before → after (uhdm-cmp, golden LHS)

* `stamped_gen_param`/default: **11/1 → 64/1**.
* `stamped_gen_param`/testflags: **11/1 → 64/1**.

The NEXT head (both modes), at `dut.sv` 44:31-44:54, `work@stamped_gen_param.gen_grps[0]`, is the value of `localparam q2::row_t UT = q2::IMPL.UnitTypes[grp]`:

```
LHS: constant 1'b0  vpiSize:1  BIN:0      ts ref -> logic_typespec (q2::row_t)
RHS: constant 6'b010101 vpiSize:6 BIN:010101  ts ref -> logic_typespec (q2::row_t)
```

Our value was the same at the base: the old head masked it.

## Residues (ranked)

* **R0 — stamped_gen_param cannot convert against the pinned producer.** Golden
  evaluates `q2::IMPL.UnitTypes[grp]` as a BIT-select of the flattened member
  constant (`BIN:010101101010`, bit `grp` → `1'b0` / `1'b1`). The test's own
  header names this bug ("chipsalliance/UHDM element-select fix"). With
  `UT = 1'b0` / `1'b1`, Surelog elaborates `sgp_leaf`'s generate differently:
  * golden: `gen_grps[0].u.g[0..2].inv`, `gen_grps[1].u.g[0].keep`, `g[1..2].inv`;
  * slang: `gen_grps[0]` all `keep`, `gen_grps[1]` all `inv`.

  Emitting the garbage value moves the head one object. It cannot reach the
  generate structure, which slang decides. So it was decoded and NOT landed.
* **R1 — k14's module-side whole-member fold** (the 2 MOVED-WRONG cells, ExprEmit ground, above).
* **R2 — the positional pattern's size** (t17). Golden `UnitTypes` is 36 on an
  UNTYPED flat op. Ours stays 12: the pristine positional road is not this walk's
  setter mapping.
* **R3 — unpacked struct** (t22). Golden flattens it. Our unpacked walk also
  mints a parameter-parented struct typespec clone (90 tail cells), so L1 fences
  it.
* **R4 — the >64 bail on the EXISTING roads** (t01, t02). Golden keeps the
  tagged tree, with the bailing member resized to 72. Ours flattens at 24. This
  is pre-existing and needs a gate on the SCOPED-REFERENCE and MEMBER-SELECT
  rules plus the in-tree resize.
* **R5 (face 3) — `{..}+1` module import copies** (grid g3). Golden keeps the
  op24/op29/op1/op25 in MDEF (untyped) and MELAB (typed `work@top`) for EVERY
  concat-bearing imported parameter, read or not (r06). The gate is
  `ParamEmit.cpp:12630`. It was built and measured (`concatBearing54` in place of
  top-level-concat): the package copies went TO, but the elaborated module's
  cont_assigns became SHARED with the definition's (r02: 5 elab cont_assigns lost
  their own objects, 55 AWAY cells). That is the ExprEmit/elaboration road, so it
  was DROPPED.
* **Face 2 — not landed. Decoded where noted, sites given.**
  * **a10 (the typedef-typed package parameter `n_t N`).** The stamp is
    `ExprEmit.cpp:17355`, which reads `importedParamDefTs`. That map is filled
    only at `ParamEmit.cpp:21232`, on the `its` road. Widening it reaches every
    fold kind that reads the map (all in ExprEmit), so it needs pair A's grid.
  * **Interface-array plain port views (w04/w05), s10's receiver-shadow
    abstain, and f05's untyped package parameter signedness.** Not attempted in
    this pass.
* **Face 3 R4 / R6 — not landed.**
  * R4's hex/x-digit and unpacked-element shapes were not re-measured.
  * R6: the replacement happens inside `pkgPatCatFold114` (`EmitHelpers.h:13678`,
    fenced) and the case-item law in StmtEmit (fenced). Erasing the old objects
    needs those files.

## Scripts

| script | what |
|---|---|
| `grid117.sh` | golden (pinned Surelog, testflags form) plus each binary, per arm; uhdm-cmp lines and heads; rc |
| `pkgshape117.py` / `shapes117.sh` | SHAPE LISTER: one parameter's pattern Rhs per section |
| `norm117.py` / `dist117.sh` / `cells117.py` | contextual cells, whole-dump distance, per-cell TO/AWAY |
| `drops117.sh` | each switch against LAW and PRISTINE (dump text, same-length names) |
| `ctl117.sh` | control battery over the landed grids, both forms, rc |
| `predict117.py` / `pred117.sh` | a-priori source candidates, plus the law detector on each candidate |
| `cen117.py` / `cen117.sh` | census on the sweep roots, with golden-vs-golden calibration |
| `sweep117.sh` | both corpora, both modes, `--jobs 3`, own workdir |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the r10uvm221 battery |
