# r10earl107 — § `patFlatPortConnUnsizedMember107`: the substituted pattern at a PORT high_conn re-types an unsized member value at the MEMBER's own width, exactly as the `param_assign` carrier already does

Everything in this directory is **MEASUREMENT ONLY**.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

`Earlgrey_0_1` **testflags** went from **32 cmp lines / 1 head to 122 / 1** — a
line count that rises because the head **OBJECT CHANGED**: the constant at
`pwrmgr_pkg.sv:157` is gone and a whole `op75` at `pwrmgr_cdc.sv:108` is now
first (counts are DEPTH, not distance — RESUME.md §7).  `Earlgrey_0_1`
**default** keeps its own earlier head **byte-identical** while its database
moves.  Three databases moved: **two by the law and one by the recorded coin**,
and the corpus census scores **TO-GOLDEN 4 / AWAY-GOLDEN 0 / MOVED-WRONG 0** on
surelog and **0 / 0 / 0** on uhdm2rtlil.

* BASE COMMIT `d53fbaad`, branch `auto5h`.  Worktree `/tmp/wt_r10earl107`.
* Pristine binary md5 `fb82059559765e79eee43ee365aa4879` — **byte-identical to
  the main tree's build at `d53fbaad`** — patched
  `fd2870e34b3081cb23199acbdfdf838d`.  Both frozen `chmod 555` at immutable
  paths **before any sweep**; all **3035** `cmds.txt` audited BY BINARY PATH
  (2981 name the frozen binary, **0 name the main-tree binary**).
* `/tmp/r10earl107.patch` applied to a **FRESH `d53fbaad` worktree** and rebuilt
  there produces the **BYTE-IDENTICAL** binary, same md5
  `fd2870e34b3081cb23199acbdfdf838d` — the patch IS the artifact every number
  below was measured on.
* Production diff: `src/ModuleEmit.cpp` **only** — one loop, inside the arm that
  already exists for this connection shape.  No new function, no new member, no
  header change.  `slang` is NOT patched.  `results/*.csv` were **READ ONLY** and
  **no row was converted**.  `GOLDEN_DEFER` stayed unset.  The four slang-fenced
  tests were never dispatched and are named only inside `canaudit.sh`'s own
  fence list.

---

## 1. THE HEAD, and WHICH FIELD FAILS FIRST — decoded before a line of law

`rowheads.sh` on this pass's **own pristine build**, not carried forward:
`Earlgrey_0_1` **default 31 / 1**, **testflags 32 / 1** — different objects; only
testflags is this pass's (the default head is the pre-existing
`u_pinmux.gen_mio_periph_in[0].data_mux` null).

```
LHS (golden)  constant  id:704546   line 157:14-157:16
              |vpiDecompile:0   |vpiSize:2   |UINT:0  |vpiConstType:9
RHS (ours)    constant  id:1479774  line 157:14-157:16
              |vpiDecompile:'0  |vpiSize:16  |BIN:0   |vpiConstType:3
```

```systemverilog
pwrmgr_pkg.sv:149  typedef struct packed {
pwrmgr_pkg.sv:150    logic [WakeUpPeris-1:0] wakeups;      // WakeUpPeris == 16
pwrmgr_pkg.sv:151    logic [HwRstReqs-1:0]   rstreqs;      // HwRstReqs   == 2
pwrmgr_pkg.sv:152  } pwr_peri_t;
pwrmgr_pkg.sv:155  parameter pwr_peri_t PWR_PERI_DEFAULT = '{
pwrmgr_pkg.sv:156    wakeups: WakeUpPeris'(1'b1),
pwrmgr_pkg.sv:157    rstreqs: '0
pwrmgr_pkg.sv:158  };
top_earlgrey.sv:710   .pwr_peri_i(pwrmgr_pkg::PWR_PERI_DEFAULT),
```

**THE JUDGE, read out of the generated `Compare`s and not assumed**
(`~/git-repos/UHDM/build/generated/src/{BaseClass,expr,constant}.cpp`, plus
`~/.local/include/uhdm/BaseClass.h`'s SafeCompare overloads):

| order | reader | field | here |
|---|---|---|---|
| 1–3 | `BaseClass::Compare` | `VpiType`, `VpiName`, `VpiDefName` | all equal |
| 4 | `expr::Compare` | **`VpiDecompile`** | **`"0"` vs `"'0"` — THE FIRST FAILURE** |
| 5 | `expr::Compare` | `VpiSize` | 2 vs 16 |
| 6 | `expr::Compare` | `Typespec` | NONE on both |
| 7 | `constant::Compare` | `VpiConstType` | 9 (`vpiUIntConst`) vs 3 (`vpiBinaryConst`) |

**No location is read anywhere** — not `VpiFile`, not `VpiLineNo`, not
`VpiColumnNo` — which is why the pattern OPERATION's own span (golden anchors it
at `pwrmgr_pkg.sv:155:43-158:4`, we anchor it at the connection,
`top_earlgrey.sv:710:19-710:47`) is a faithfulness question and not a judge
question.  `expr::Compare` never reads `VpiValue` either: the value reaches the
judge only through the decompiled spelling.

### Both holders, named — `own107.cpp`, the id-selector owner-finder

`own107` is r10earl106's `own106.cpp` verbatim (it already accepts an
`id:<UhdmId>` target).  The `vpiParent` chain is NOT the answer: golden's
constant is held by **TWO** operation objects and ours by **ONE**.

```
golden constant#704546  <- VECTOR operation op=75 155:43-158:4  Operands[1]   (x2)
                        <- port 49:21-49:31 pwr_peri_i
                          <- module_inst work@top_earlgrey.u_pwrmgr
                            <- module_inst work@top_earlgrey
   containers: VECTOR=2 SINGULAR=0
ours   constant#1479774 <- VECTOR operation op=75 710:19-710:47 Operands[1]
                        <- the IDENTICAL port / instance chain
   containers: VECTOR=1 SINGULAR=0
```

The golden **VECTOR=2** is not an accident and it is decoded below: UHDM's
`ExprEval::getValue` REPLACES the original operation's operand vector with the
flattened one **and** `flattenPatternAssignments` returns a `clone_tree` of that
same operation carrying the same vector, so two operation objects hold the same
constant.  A fix must therefore not assume a single writer — this one writes the
CONSTANT, which both holders share, and not a vector.

**One of the two holders is the compared one.**  `uhdm-cmp` walks the design
tree, so the object it reaches is the ELABORATED port's high_conn.  On our side
the arena holds two `op75` under that port as well (a DEF-view one at
`id:559871` and the elaborated `id:1235100`), and the pristine dump shows the
mechanism that produced the `16`: the two share `Operands[0]` object-for-object
but NOT `Operands[1]`, because the elaborator cannot serialize a
`VpiSize() == -1` constant and mints a re-sized replacement for it.  The width it
picks is not the member's — the same walk gives `16` here (the FIRST member's
width) and `1` on a three-member arm — which is exactly why the fix must set the
size at the source instead of repairing it afterwards.

---

## 2. THE SURELOG DECODE — read out of the source, and it is UHDM's, not Surelog's

The re-type is **`UHDM::ExprEval::flattenPatternAssignments`**
(`~/git-repos/UHDM/templates/ExprEval.cpp:889-916`).  Its ONLY test is on the
`tagged_pattern`'s `Pattern()` alone — `constant && VpiSize() == -1` — and it
knows nothing about which key put it there:

```cpp
if (c->VpiSize() == -1) {
  uint64_t uval = get_uvalue(invalidValue, c);
  if (uval == 1) {
    uint64_t size = ExprEval::size(fieldTypes[index], …);   // the MEMBER's width
    uval = NumUtils::getMask(size);
    c->VpiValue("UINT:" + std::to_string(uval));
    c->VpiDecompile(std::to_string(uval));
    c->VpiConstType(vpiUIntConst);
    c->VpiSize((int32_t)size);
  } else if (uval == 0) { … same, with uval 0 … }
}
```

Three facts that a paraphrase would lose, each of them measured here:

* **`'x` / `'z` land in the `uval == 0` arm.**  `get_uvalue(bool&, const expr*,
  bool strict = true)` (`ExprEval.h:99`) DOES set `invalidValue` on an X digit —
  but the flatten **never reads `invalidValue`**, and `NumUtils::parseBinary`
  fails leaving `result` at its initialised 0.  (This is
  § `patFlatUnsizedMemberWidth61`'s own V-FIX, re-measured here at a PORT:
  `g2_form107` row `c`.)
* **`NumUtils::getMask` SATURATES at 64 bits** (`NumUtils.cpp:94`, `~0ULL` for
  `w >= 64`) and the flatten stores that value WHOLE while stamping the TRUE
  width on `VpiSize`.  Golden's 65-bit `'1` is therefore
  `UINT:18446744073709551615` **at `vpiSize` 65** — not `2^65-1`
  (`g2_form107` row `a`, operand 5).
* **A SIZED literal is untouched**, because a sized literal is not
  `VpiSize() == -1`.  `1'b1` / `3'h5` / `8'hA5` / `32'd7` / `64'hFF` / `65'h1`
  keep their own encodings on BOTH sides (`g2_form107` row `d`, six SAME cells).

`recursiveFlattening` (`ExprEval.cpp:652`) then unwraps each
`tagged_pattern` whose key typespec is a `string_typespec` — which is what
`CompileHelper::compileAssignmentPattern` builds for a plain member name
(`CompileExpression.cpp:3799`, `tps->VpiName(fC->SymName(Constant_expression))`)
— down to its `Pattern()`, which is why golden's compared operand is a BARE
CONSTANT and not a `tagged_pattern`.

**WHY THE PORT CARRIES IT.**  Golden's port high_conn is a CLONE of the
parameter's own already-flattened `param_assign` Rhs — measured on
`g1_home107`, where golden's `param_assign` operands are `id:102/106` and the
port's are `id:705/706` with the identical payloads.  It is not the port
connection that re-types; it is the parameter value the port copies.

---

## 3. WHERE OURS COMES FROM — and the fact that made the law one loop

Our `param_assign` carrier **already produces golden's answer**: on the pristine
binary, `PWR_PERI_DEFAULT`'s own `op75` carries `dc "0" / size 2 / UINT:0 /
ct 9`, because ExprEmit's § `patFlatMemberOnly27` + § `patFlatUnsizedMemberWidth61`
run there.  What does not run there is the port connection: `ModuleEmit.cpp`'s
arm for *a named PACKED-STRUCT param connection* re-emits the parameter's
initializer with `reemitting = true` but **without** the flatten's carrier
(`patFlatTs` / `patFlatAdjust`), so its operands are the WRITTEN member values.

The law is written **at that arm**, as one gated loop over the operand vector
that is already there, and **NOT** by turning the ExprEmit flatten on for this
carrier.  That was considered and refused on measurement: the flatten REORDERS
into declaration order and EXPANDS `default:` fills, which would change the
operand COUNT and ORDER that the arm's landed nested-member-sizing loop
(`ov8->size() == ap8.memberSetters.size()`, `memberSetters[i8].expr->type`)
indexes — putting r10earl21's/r10earl57's port precedents at risk for cells this
pass has no witness for.  The loop written instead cannot change a count, an
order, a span, a typespec or a parent; it can only re-encode a constant that
golden also re-encodes.

**r10earl106's law is UNDISTURBED.**  Its site is a gen-scope `cont_assign`'s
whole Rhs, applied after `UhdmAdjuster` from `uhdm_main.cpp`; nothing here reads
or writes that machinery, and every r10earl104/105/106 arm is byte-identical in
the wide boundary (§7).

---

## 4. THE LAW

> **§ patFlatPortConnUnsizedMember107** — where a **port high_conn** substitutes
> a **packed-struct package parameter**'s assignment pattern, a member value
> written as an **unbased-unsized literal** is re-typed at that **member's own
> width**: `vpiSize` = the member width, `VpiValue` `UINT:<v>`, `vpiDecompile`
> the **decimal** spelling of `<v>`, `vpiConstType` `vpiUIntConst`, where `<v>`
> is `NumUtils::getMask(width)` (saturating at 64 bits) for `'1` and **0** for
> `'0`, `'x` and `'z`.

`src/ModuleEmit.cpp`, one loop inside the existing arm.  The fences, each with a
golden witness measured on this pass's own arms:

| fence | witness (golden, LHS) |
|---|---|
| **NAMED member setters only, in lockstep** | a **POSITIONAL** pattern is NOT re-typed by golden at all — `g3_src107` `.d(M_POS)`: golden's port operands keep `'0` (at size 8) and `'1` (at size **-1**).  A **`default:`** fill changes the operand COUNT — `g3_src107` `.c(M_DEF)`: golden has one operand per MEMBER (two of them at the same span), we have one per setter — so an index-aligned walk would read the wrong member.  Both are declined and both are byte-identical between the two binaries |
| **an UNBASED-UNSIZED literal only** | `g2_form107` row `d`: `1'b1` `3'h5` `8'hA5` `32'd7` `64'hFF` `65'h1` are SAME on both sides before and after; `g3_src107` row `a` operand 1, the enum constant `E5` (`INT:5`, size 3), likewise |
| **an INTEGRAL member only** | the arm is already gated on `SymbolKind::PackedStructType`, so `getBitWidth()` IS the width `ExprEval::size` answers and ExprEmit's file-static `surelogTsBits` copy is not needed |
| **the value rule is UHDM's arithmetic, not slang's** | `g2_form107` row `a` operand 5: a 65-bit `'1` is `18446744073709551615` at size 65 on BOTH sides — `SVInt::setAllOnes()` would have given `2^65-1` |
| **this arm only** | a module-LOCAL param (`g3_src107` `.g(T_MOD)`, `g4_fence107` `.d(LOC)`), a pattern written INLINE at the connection (`g4_fence107` `.b`) and a NON-struct param (`g4_fence107` `.c(PLAIN)`) never reach the arm; the `cont_assign` carrier (`g4_fence107` `caw`, r10earl61's own shape), the module-body `param_assign` carrier and the var-declaration initializer are all untouched and byte-identical |

---

## 5. THE GOLDEN GRID (`grid107.sh`, `GRID.r10earl107.txt`)

Four arms × two views, the golden built here by
`~/git-repos/Surelog/build/bin/surelog`, both frozen binaries run against it,
every producer's rc recorded, a missing database printed as REJECT and COUNTED.

| arm | pristine c/h | patched c/h |
|---|---|---|
| `g1_home107` plain | 36 / 1 | **0 / 0** |
| `g1_home107` elab | 32 / 1 | **0 / 0** |
| `g2_form107` plain / elab | 32 / 1 | 32 / 1 |
| `g3_src107` plain / elab | 32 / 1 | 32 / 1 |
| `g4_fence107` plain / elab | 28 / 1 | 28 / 1 |

`g1_home107` is the corpus shape (a package struct param at a child port) and it
goes **EQUAL in both views**.  The other three arms are matrices, and their
uhdm-cmp counts are unchanged because their FIRST failure is one of the residues
in §8, not this law — which is what the three-way census is for.

**THE FILL × MEMBER-WIDTH MATRIX** (`g2_form107`, one 6-member struct, golden
first, `port` carrier, after the patch **ours equals golden in every cell**):

| written | w1 | w3 | w8 | w32 | w64 | w65 |
|---|---|---|---|---|---|---|
| `'1` | 1 | 7 | 255 | 4294967295 | 18446744073709551615 | **18446744073709551615** |
| `'0` | 0 | 0 | 0 | 0 | 0 | 0 |
| `'x` / `'z` | 0 | 0 | 0 | 0 | 0 | 0 |
| sized (`1'b1`…`65'h1`) | UNTOUCHED on both sides, before and after |

each at `vpiSize` = the member width, `vpiUIntConst`, decimal decompile.

**THE THREE-WAY SCORE** (`score107.py` over `cen107 --raw --tagblind`;
tag-blind so a cell whose OPERAND KIND still differs — golden a
`tagged_pattern`, ours a bare constant — is still JOINED and its
compare-visible payload scored rather than silently split into
ONLY-GOLDEN + ONLY-OURS):

```
g1_home107  plain/elab  ALL  TO_GOLDEN=8  AWAY_GOLDEN=0 MOVED_WRONG=0 STILL_WRONG=0
g2_form107  plain/elab  ALL  TO_GOLDEN=18 AWAY_GOLDEN=0 MOVED_WRONG=0 STILL_WRONG=27
g3_src107   plain/elab  ALL  TO_GOLDEN=8  AWAY_GOLDEN=0 MOVED_WRONG=0 STILL_WRONG=17
g4_fence107 plain/elab  ALL  TO_GOLDEN=2  AWAY_GOLDEN=0 MOVED_WRONG=0 STILL_WRONG=0
```

**72 cells move, every one of them ONTO golden; AWAY-GOLDEN 0 and MOVED-WRONG 0
on every arm in every view.**

---

## 6. THE CENSUS — predicted from PRISTINE, then re-scored (`cen107.cpp`)

`cen107`'s population is every CONSTANT that is an operand, at any nesting
depth, of a `vpiAssignmentPatternOp` / `vpiMultiAssignmentPatternOp`.

* **KEY** — `view | CARRIER kind | carrier owner fullname | operand PATH |
  the operand's own line:col span`.  The span stays IN the key here, unlike
  r10earl106's census, because this pass's moving cell keeps its span on both
  sides (golden and ours both anchor the member value at the written token) so
  the span DISCRIMINATES instead of splitting.  The pattern OPERATION's span is
  deliberately OUT of the key: golden anchors a port high_conn at the pattern
  and we anchor it at the connection, and no generated `Compare` reads a
  location.  **The FILE is out of the key too** — our constants carry an EMPTY
  `VpiFile` (RESUME.md §9), and a first cut that keyed on it split all 66
  arm cells into ONLY-GOLDEN + ONLY-OURS and scored nothing.
* **PAYLOAD** — the compare-visible triple and nothing else: `VpiDecompile`,
  `VpiSize`, `VpiConstType`, `VpiValue`.
* **DEDUPED per side before the join.**  Both tools keep several arena copies of
  the same pattern (flattened and not); a NODEDUP multiset join manufactures
  AWAY-GOLDEN phantoms out of the copy counts alone.
* **CARRIER** is a reported column, so `param_assign` / `cont_assign` /
  `assignment` / `var` are scored as CONTROLS beside the moving `port`.

**PREDICTED BEFORE THE PATCHED SWEEPS** (`PREDICT_R0.txt` §2–3): exactly two
databases move, `Earlgrey_0_1/default` and `Earlgrey_0_1/testflags`, and inside
them exactly four constants, named:

```
work@top_earlgrey.u_pwrmgr / pwr_peri_i  operand 1   pwrmgr_pkg.sv:157  `rstreqs: '0`   width 2
work@top_earlgrey.u_rstmgr / peri_i      operand 0   rstmgr_pkg.sv:61   `rst_reqs: '0`  width 2
```

**MEASURED** (`CHANGED_sl.txt`, `CHANGED_u2r.txt`):

| corpus | rows changed | transition |
|---|---|---|
| surelog (956 DBs, 339 with both sides) | **4** | 4 × `DIFF → SAME` |
| uhdm2rtlil (1358 DBs) | **0** | — |

port-carrier totals: surelog **4 DIFF / 34 SAME → 0 DIFF / 38 SAME**;
uhdm2rtlil **0 DIFF / 10 SAME → 0 DIFF / 10 SAME** (the 10 are the landed
`…PassedAsPort` precedents, including `AssignmentPatternArrayPort`'s
`0{default}` — a `default:` fill this law declines).  Every other carrier is
row-for-row identical (`param_assign` 47078 SAME / 2354 DIFF, `cont_assign`,
`assignment`, `struct_var`, `logic_var`, `int_var`, `array_var`, `enum_var`,
`func_call`) — **AWAY-GOLDEN 0, MOVED-WRONG 0 on both corpora.**

---

## 7. THE GATES — all green, and the boundary that could see

| gate | result |
|---|---|
| build both, md5 | pristine `fb82059559765e79eee43ee365aa4879` (= the main tree at `d53fbaad`), patched `fd2870e34b3081cb23199acbdfdf838d` |
| golden dumps | **23 PASS / 0 FAIL**; negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| u2r testflags | CMP_EQUAL **679** / SLANG_REJECT 50 / SURELOG_FAIL 2 |
| `ct8rows` u2r tf/def vs the committed baseline AND vs this pass's own pristine | **PASS — every row byte-identical** (status AND dump column) |
| `ct8rows` surelog vs the committed baseline AND vs this pass's own pristine | **PASS — every row byte-identical over 1588 rows.  NO ROW CONVERTED** |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL, selfcheck 1357/1358 flagged |
| `byteverify SELFCHECK=1` surelog | **MOVERS 3 / 956**, PATH_SETS_IDENTICAL, selfcheck 955/956 flagged |
| canaries | surelog `ok=52 changed=0`, u2r `ok=8 changed=0`; `ctcan2` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` → audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** |

**THE THREE MOVERS, EACH ATTRIBUTED LINE BY LINE** (path-normalised, ORDER-BLIND
`uhdm-dump` diff — `ATTRIB.r10earl107.txt`):

* `Earlgrey_0_1/default` — **14 lines**, and all fourteen are the two constants'
  triples: `BIN:0 → UINT:0` ×2, `vpiConstType:3 → 9` ×2, `vpiDecompile:'0 → 0`
  ×2, and one `vpiSize:-1` removed / one `vpiSize:2` added (the `rstmgr` cell was
  already at size 2, so only the `pwrmgr` one changes width).
* `Earlgrey_0_1/testflags` — **22 lines**: the same triples for the DEF-view and
  the ELAB-view copies, plus one `vpiSize:16` removed, and one
  `\_operation: 710:19-710:47` + one `|vpiParent:` moving indent level, because
  the elaborator no longer has to mint a re-sized replacement for a
  `VpiSize() == -1` constant and shares the original (parented) one instead.
  **Zero unrelated lines.**
* `Scoreboard/default` — **0 lines order-blind.**  This is the documented ~50/50
  COIN (RESUME.md §9: the `svunit_pkg` `vpiTaskFunc` list ORDER flip / macro-
  buffer `SourceLocation` ordering under slang's parallel parse), not a content
  move, and its head log is byte-identical before and after.

**HEADS** (`rowheads.sh`, before → after): SeqDriver 33/33 both modes,
SimpleUVM 17/17, Scoreboard/default 95/95, MiniAmiq 40/40, BuildUVMPkg 52/52,
Rggen/default 0/0, Earlgrey/default 31/31 — **every one of those head logs is
byte-identical**, including Earlgrey/default whose database moved.  Only
`Earlgrey_0_1/testflags` changed: **32 → 122, one head, a NEW object.**

**THE WIDE BOUNDARY** (`wide107.sh`, `BOUNDARY_WIDE.*`) — every `.sv` / `.v`
under a COPY of `tools/probe` **at any depth**, both views, both frozen
binaries, workdir-normalised whole-dump byte compare.  The file list is read on
fd 3 with children `</dev/null`, and PROCESSED is asserted against LISTED:

```
LISTED=4811   PROCESSED=4811   identical=9236   DIFFERING=8   no_output=378
rc histogram   A: 0×8857  3×362  4×387  139×16      B: identical, ASYMMETRIC=0
DIFFERING:  plain/elab  r10earl107repro/{g1_home107,g2_form107,g3_src107,g4_fence107}.sv
```

**The only cells that move are this pass's own four arms, in both views.**  Every
committed r10earl45–106 arm, every uvm / buvm arm, r10earl59's
`genCaNestedModuleLhsOpRhsBinds59` binder mirror, r10earl104/105/106's clone and
cast windows and every subdirectory arm are byte-identical.  The eight moving
cells ARE the positive control: the gate demonstrably sees a moved cell.  The
four slang-fenced names appear in **0** listed files.

---

## 8. RESIDUES, and R0

* **R0 — THE NEXT HEAD IS NAMED, MEASURED AND ITS OWNER FOUND.**
  `Earlgrey_0_1/testflags`, 122 cmp lines, one head:

  ```
  LHS (golden)  operation id:709890  op=75  pwrmgr_cdc.sv:108:17-108:41
                |vpiTypespec -> ref_typespec (work@top_earlgrey.u_pwrmgr.i_cdc.i_ast_sync)
                                -> struct_typespec pwrmgr_pkg::pwr_ast_rsp_t
                |vpiOperand constant 2'b01/2 … (the whole pattern, four operands)
  RHS (ours)    constant  id:557631  9:30-9:31
                |vpiDecompile:0 |vpiSize:1 |UINT:0 |vpiConstType:9
                |vpiTypespec -> bit_typespec 9:13-9:16
  ```

  `own107` on the golden database: **SINGULAR `param_assign` 9:17-9:31 `Rhs`,
  VECTOR=0 SINGULAR=1**, under `module_inst work@top_earlgrey.u_pwrmgr.i_cdc.i_ast_sync`.
  The source is `pwrmgr_cdc.sv:106-108`
  `prim_flop_2sync #(.Width($bits(pwr_ast_rsp_t)), .ResetValue(PWR_AST_RSP_SYNC_DEFAULT)) i_ast_sync`:
  the **PARAMETER-OVERRIDE** carrier of the very same substitution this pass
  fixed at the **PORT** carrier.  Golden keeps the whole `op75` as the child
  `param_assign`'s Rhs with a conn-scoped `ref_typespec` fullname; we fold it to
  the FORMAL's own 1-bit `'0` default.  `expr::Compare` fails at step 1
  (`VpiType`: operation vs constant), so this is a whole-object question, not a
  field one.  The family is the same one; the carrier is one step over.
* **R1 — a plain DECIMAL member value keeps 64 at a port.**  `g2_form107` row
  `e` (`'{w1:1, w3:5, w8:165, w32:7, w64:255, w65:1}`): golden sizes each at the
  MEMBER's width (1/3/8/32/64/65), we keep 64 on four of the six.  Four arm
  cells, ZERO corpus cells; a DIFFERENT producer (Surelog's `adjustSize`, not the
  flatten's `VpiSize()==-1` test) and deliberately not widened here.
* **R2 — a NESTED pattern's own member values are not re-typed.**  `g3_src107`
  rows `a`/`b` operands `2.0`/`2.1`: golden's `'{n4:'1, n2:'0}` inside a member
  becomes `15/4` and `0/2`, ours stays `'1`/`'0` at size −1.  The flatten
  recurses (`ExprEval.cpp:923`); this loop deliberately does not, because the
  arm's landed nested-member walk owns those operands and no corpus cell varies
  it.  Four arm cells, zero corpus cells.
* **R3 — a `default:` fill at a port.**  `g3_src107` `.c(M_DEF)`: golden emits
  one operand per MEMBER (the fill's token repeating), we emit one per setter, so
  the COUNT differs before any encoding does.  Fixing the encoding without the
  count would be motion without a target; declined by the law's own gate, one
  arm cell, zero corpus cells (the u2r `AssignmentPatternArrayPort` `default:`
  row is already SAME).
* **R4 — the TAG axis.**  Golden keeps `tagged_pattern` operands at this port
  when the struct carries an enum or a nested-struct member (`g3_src107` `.a`,
  `.b`) or is wider than a machine word (`g2_form107`, a 173-bit struct); we
  always drop the tags.  This law moves those operands' PAYLOADS onto golden's
  (18 + 8 tag-blind TO-GOLDEN cells) but not their KIND, so those arms' uhdm-cmp
  counts are unchanged.  Zero corpus cells — no corpus port cell is tagged on
  golden's side.
* **R5 — carriers this arm never reaches.**  A module-LOCAL struct param
  (`g3_src107` `.g`, `g4_fence107` `.d`), a pattern written INLINE at the
  connection (`g4_fence107` `.b`) and a POSITIONAL pattern (`g3_src107` `.d`,
  where golden does not re-type either) produce no `op75` under the port on our
  side at all.  Pre-existing, byte-identical on both binaries, and each one is a
  separate producer question.

---

## 9. FILE MAP

| file | what it is |
|---|---|
| `PREDICT_R0.txt` | the head decode, the Surelog/UHDM decode and the mover + census prediction, written BEFORE the patched sweeps |
| `own107.cpp` | the id-selector owner-finder (r10earl106's `own106.cpp`) — names every VECTOR/SINGULAR holder of an object |
| `dumpop107.cpp` | prints every assignment-pattern operation in an arena with its operands' compare-visible triples, its typespec and its carrier |
| `cen107.cpp` | the census (`--raw`, `--tagblind`); `cenrun107.sh` drives it over a `verify_golden` workdir with PROCESSED / SKIP-NOFILE / CENRC asserted |
| `score107.py` | the three-way scorer: TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG, and it REFUSES to score two runs whose golden side differs |
| `g1_home107.sv` … `g4_fence107.sv`, `TOPS.txt`, `grid107.sh` | the four arms and their driver |
| `GRID.r10earl107.txt` | the grid table, the three-way scores and every port cell that stays wrong, listed |
| `CEN_port_{pre,post}_{sl,u2r}.txt`, `CHANGED_{sl,u2r}.txt` | the corpus census, before and after, and the rows that changed |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the pristine and patched head logs |
| `ATTRIB.r10earl107.txt` | the order-blind whole-dump attribution of the testflags mover |
| `BOUNDARY_WIDE.*`, `wide107.sh` | the wide boundary: list, tally, rc histogram, rc by side, and the eight moving cells |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the shared gate instruments, carried so this directory reproduces on its own |
