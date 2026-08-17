# r10ladder1 — the ladder families vs the KNOWN residue ledger

`CLUSTERS.md` is generated.  This file is the reading of it: which ranked
families are already-known residues, which are new, and — the part that changes
where the campaign spends its next passes — which known residues **cannot
appear here at all**.

---

## 0. THE LAW THAT REFRAMES HALF THE LEDGER

Before mapping anything, one fact about the judge, read out of UHDM's own
generated sources rather than assumed:

```
$ ./comparescope.sh
Compare bodies found: 463
  VpiFullName           0
  VpiFile               0
  VpiLineNo             0
  VpiColumnNo           0
  VpiEndLineNo          0
  VpiEndColumnNo        0
  VpiName              38     (plus BaseClass::Compare, which every kind inherits)
  VpiDefName            9     (idem)
  VpiDecompile          2
  VpiType              19
  VpiAutomatic          7
  Instance             13
```

**`design::Compare` — and therefore `uhdm-cmp`, and therefore every
`CMP_NOTEQUAL` in the corpus — never compares a fullname and never compares a
file, line or column.**  `BaseClass::Compare` compares `VpiType`, `VpiName` and
`VpiDefName`; each kind then compares its own scalar vpi properties and its
children.  Spans and fullnames are dump-only.

Consequences for the ledger, stated as claims that can be checked:

* the **uvm78-R5 `idxPrefix` 1585-object family** and the **joint-family law2**
  work are about `vpiFullName` text.  They **cannot** be the cause of any
  `CMP_NOTEQUAL`; they belong to the CMP_ONLY / dump axis.  Consistent with the
  measurement: `FIELD=VpiFullName` appears **0 times** in any ladder of any row.
* likewise every "span residue" in the ledger (the `73:38` vs `73:39` cells in
  the uvm78 census, and the span halves of the sd8 cells) is invisible to the
  judge.
* `VpiDecompile` **is** compared, and it is a rendered-text property.  So the
  decompile-text families below are real `CMP_NOTEQUAL` causes even though they
  look like cosmetics.

---

## 1. FAMILIES THAT MAP ONTO A KNOWN RESIDUE

| ladder family | known residue | strength of the match |
|---|---|---|
| `string_var\|VpiType\|KIND:string_var>io_decl`, `io_decl\|<rhs-null>\|MISSING-OURS`, `+io_decl\|<lhs-null>\|EXTRA-OURS`, `+string_var\|<lhs-null>\|EXTRA-OURS` | **the io_decl / hoisted-package-var family** | **EXACT.**  The cells are literally golden's package-level `string_var(val)` against our `io_decl(val)` inside `uvm_sequencer_base::set_arbitration`, i.e. golden hoists the subroutine argument to a package variable and we keep it as an io_decl.  Present in every UVM row. |
| `hier_path\|VpiName\|TEXT:m_streams[]…\|m_streams[ro.get_name()]…` (UVM rows) | **uvm79 V-R2 / V-R3** (the qualified-base select index and the cast index) | **EXACT.**  Golden writes the bracket EMPTY, ours renders the index expression — measured cell: golden `m_streams[].exists`, ours `m_streams[ro.get_name()].exists`.  This is V-R2's shape verbatim, now shown to be a `CMP_NOTEQUAL` head and not only a dump residue (`hier_path` compares `VpiName`). |
| `ref_typespec\|<rhs-null>\|MISSING-OURS` | **the typespec-linkage cluster** (missing `ref_typespec`, t2304) | **SUPERSET.**  The ledger entry is about ranged-typedef elements; the ladder shows the same *shape* (golden binds a `ref_typespec`, we bind nothing) at a scale the ledger never suspected, and mostly under `hier_path`, not under typedefs. |
| `ref_typespec\|<rhs-null>\|MISSING-OURS` (subset) | **G_UNSUP-142** (golden binds an `unsupported_typespec`, ours does not) | **PLAUSIBLE SUBSET, NOT CONFIRMED.**  A missing `ref_typespec` is exactly how a G_UNSUP cell would surface, but the ladder's head is the unnamed `ref_typespec` itself and this instrument does not open it to see whether the typespec behind it is `unsupported_typespec`.  Stated as unproven. |
| `constant\|VpiType\|KIND:constant>operation` | **earl52's ternary fold** | **CONSISTENT.**  Golden folded an expression to a `constant`; we emit the `operation`.  The ladder does not identify the operator, so "this is the ternary" is not claimed — only the fold-vs-no-fold shape. |
| `ref_var\|VpiType\|KIND:ref_var>logic_var`, `class_var` / `ref_var` kind swaps | **sd12's element residues / r10sd10 R1** | **CONSISTENT in shape** (a declaration bound to the wrong one of two variable kinds), same pair of kinds the sd12 README leaves alone deliberately. |
| `logic_typespec\|VpiName\|O-EXTRA-PREFIX(uvm_pkg::)` (UVM rows), `…O-EXTRA-PREFIX(hmac_pkg::)` (Earlgrey) | **the "naming is context-dependent" dead-end** (MEMORY: don't uniformly fix `pkg::` / `work@mod.` base-ref names — it breaks goldens) | **CONFIRMS the dead-end AND makes it schedulable.**  The memory note says a UNIFORM fix is wrong; the ladder supplies the exact cells where golden is bare (`uvm_bitstream_t`, and the `hmac_pkg::` cells in Earlgrey), so the context can now be read off a measurement instead of guessed at.  It is a real `CMP_NOTEQUAL` family, not a dump residue. |

## 2. KNOWN RESIDUES WITH **ZERO** LADDER ENTRIES

These are not refuted — they are shown to be **off every head path of every
NE row**, which is itself a scheduling fact:

| known residue | measurement |
|---|---|
| **uvm80-R2, the tf-ITEM `VpiAutomatic` residue** | `FIELD=VpiAutomatic` appears **0 times** across the 11 NE rows and the 8 appendix rows.  `VpiAutomatic` *is* compared (it is in `class_defn`, `module_inst`, `task_func` field lists), so a disagreement would be visible — it simply is not on any reachable head.  Either those objects live inside a masked subtree, or the 144 MISS objects are in rows that already compare EQUAL. |
| **sd8-R1, the 4 `struct_typespec` element stamps** | `FIELD=Instance` appears **0 times**.  `Instance` *is* compared (`typespec`, `variables`, `task_func`, `ports`, `clocking_block`, `instance`), so the same reading applies. |
| **uvm78-R5 / joint-family law2** | structurally impossible to appear — see §0. |

## 3. THE DISCOVERIES — big families matching NO known residue

Ranked by what they would buy.

1. **`ref_typespec|<rhs-null>|MISSING-OURS` under `hier_path` (1 460 entries,
   8 of 11 rows).**  The largest family in the corpus, and its Earlgrey cells are
   uniform: golden hangs a `ref_typespec` off every `hier_path`
   (`tl_h_i.a_opcode`, `tl_h_i.a_param`, …) and we hang nothing.  The ledger's
   typespec-linkage entry is about typedefs and does not cover this.
2. **`constant|VpiType|KIND:constant>ref_obj` — the PARAMETER-FOLD family
   (1 289 entries, **2 rows** — `default_Earlgrey_0_1` 1 263 and `default_Rggen`
   26, plus one appendix cell in `testflags_FileLocalParam`).
   *(vladder1 correction: this file and the pass report both said "6 rows"; the
   generated `CLUSTERS.md` this file is a reading OF says 2, and 2 is what a
   fresh re-run reproduces.  With 2 rows it is rank 39 by the stated
   rows-then-entries policy, not rank 2 — see `VERIFY.md` §2.)*
   Measured cell (`prim_fifo_sync.sv:131:29`): golden folded `PTR_WIDTH`
   inside `fifo_wptr[PTR_WIDTH-1:0]` to a `constant`; we emit
   `ref_obj(PTR_WIDTH)`.  This is the same *direction* as earl52's ternary fold
   but a different trigger — a bare parameter reference in an expression, not a
   conditional — and nothing in the ledger covers it.
3. **`hier_path|VpiName` with an UNFOLDED GENVAR INDEX (Earlgrey, 32 entries).**
   Distinct from uvm79 V-R2 above and matching nothing in the ledger: golden
   writes `reg2hw.ctrl_en_input_filter.q[0]` — the genvar folded to its VALUE —
   and we write `reg2hw.ctrl_en_input_filter.q[i]`.  Golden EMPTIES the bracket
   in the UVM cells and FOLDS it here, so the two hier_path families need
   different fixes and must not be merged.
4. **`int_typespec|VpiType|KIND:int_typespec>integer_typespec` (236 entries).**
   A pure
   kind-selection defect: golden picks `int_typespec` where we pick
   `integer_typespec` (and, in a second variant, `logic_typespec`).  Nothing in
   the ledger mentions the `int` / `integer` / `logic` typespec choice.
5. **`constant|VpiDecompile|O-EXTRA-PREFIX(')` (40 entries).**  Golden's decompile text is
   `0`, ours is `'0` — the unsized-literal apostrophe is kept in our rendered
   text.  `VpiDecompile` IS compared, so this is a genuine `CMP_NOTEQUAL`
   cause, and it is a pure rendering rule.
6. **`constant|VpiDecompile|DIGITS-ONLY` with golden `"1"` and ours `"0"` on
   `HierPathEval`, together with `gen_scope_array|VpiName|
   TEXT:gen_inner_if_true|gen_inner_if_false`.**  These two are the same defect
   seen twice: the generate condition evaluates the other way in our build, so
   the elaborated branch is the wrong one.  This is a correctness bug, not a
   naming residue, and the row is only 3 rungs deep.
7. **`design|VpiName|TEXT:work@top|unnamed` (TopParam, both modes).**  The
   design object's own name.  It is the FIRST field of the FIRST object, so it
   blocks the entire comparison (`ROOT-BLOCKED`, `maxvis=1`): the row's true
   defect count is unknown until this one line is fixed.  Cheapest item on the
   whole queue.
8. **`module_inst|<rhs-null>|MISSING-OURS` (UnsignedParam, both modes).**
   Golden emits a top `module_inst` we do not emit at all, and it is the ONLY
   rung in the row.
9. **`+module_inst|<lhs-null>|EXTRA-OURS` (YosysVerx, both modes).**  The mirror
   image, and again the row's only rung: every one of golden's 24 205 objects
   compares EQUAL and we emit ~12 000 objects too many hanging off one extra
   top module.

---

## 4. THE PRIORITY QUEUE, IN ONE TABLE

Ranked the way a convergence campaign should schedule: rows covered first,
entries second, and the cheapest certain wins pulled to the top.

| # | family | rows | entries | known residue? |
|---:|---|---:|---:|---|
> **vladder1 — THIS TABLE IS SUPERSEDED.**  It was computed from ladders the
> instrument truncated 3-8x too early (the bisection fallback masked golden's
> whole `package(uvm_pkg)` at rung 9/89 of BuildUVMPkg, 13/47 of SimpleUVM,
> 13/76 of Scoreboard, 39/59 of SeqDriver), and two of its rows-covered figures
> are wrong.  Read `VERIFY.md` and the regenerated `CLUSTERS.md` instead; the
> corrections are kept inline below rather than deleted.

| # | family | rows | entries | known residue? |
|---:|---|---:|---:|---|
| 1 | `ref_typespec\|<rhs-null>\|MISSING-OURS` | 8 | 1460 | superset of the typespec-linkage cluster; the `hier_path` bulk is NEW.  **1 441 of the 1 460 are ONE row (Earlgrey); the other 7 rows contribute 19 between them** |
| 2 | `constant\|VpiType\|KIND:constant>ref_obj` | ~~6~~ **2** | 1289 | **NEW** — parameter fold.  Earlgrey 1 263 + Rggen 26 |
| 3 | `int_typespec\|VpiType\|KIND:int_typespec>integer_typespec` | 1 | 236 | **NEW** — int/integer/logic typespec choice (Earlgrey only) |
| 4 | `constant\|VpiType\|KIND:constant>operation` | 9 | 27 | earl52's fold family.  **This is the true rank 1 by the stated policy** |
| 5 | `function\|<rhs-null>\|MISSING-OURS` | 7 | 83 | ~~whole subroutines golden emits and we do not~~ **CORRECTED: the function IS emitted, at the same span.  44 of 45 cells are `func_call.vpiFunction == nullptr` — a missing CALL→DEFINITION link, not a missing definition.**  Verified by dump on `default_BuildUVMPkg`: golden's `func_call(get_result)@21532:9` carries `\|vpiFunction:`, ours carries none |
| 6 | the io_decl / hoisted-package-var cluster (`+string_var`, `io_decl`, `+io_decl`, `string_var\|VpiType`) | 7 | 75 | KNOWN |
| 7 | `hier_path\|VpiName` (two DIFFERENT sub-families) | 9 | 66 | uvm79 V-R2 **plus** a NEW genvar-fold variant |
| 8 | `constant\|VpiDecompile` | 4 | 55 | **NEW** — rendered-text rules, and they DO decide CMP |
| 9 | TopParam `design\|VpiName` | 2 | 2 | **NEW** — one field, blocks a whole row |
| 10 | UnsignedParam / YosysVerx whole-top-module in/out | 4 | 4 | **NEW** — one rung each, both modes |
