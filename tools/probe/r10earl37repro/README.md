# r10earl37 — § genConnDottedActualIsHierPath37

**THE HEADLINE, FIRST.** The brief handed me three candidate diagnoses for the
`hier_path (flash_ctrl_i.rd)` head — "the second ref's FULLNAME (scoped through
the PORT), a missing vpiActual binding, or the member decomposition" — and told
me to census both sides before any theory. The census answered on the first
arm and **all three candidates are wrong**: the fullname rule, the binding
policy and the member decomposition are already implemented, already correct,
and already byte-identical to golden in the ELABORATED view of the very same
connection. What was missing is one object: golden's HighConn is a **hier_path**
and ours was a single **ref_obj carrying the dotted text as its own name**, and
only in the **DEF-view GENERATE-BLOCK listing**, whose port connections are
emitted by a separate TEXT-DRIVEN emitter that never saw the rule.

The law that was missing is not new either. r10earl8's § genConnDotSelInterior
already routes a **SELECTED** dotted actual to the hier_path emitter at this
exact site, and its own closing sentence — *"an UNSELECTED `a.b` still keeps the
doubled-fullname ref_obj of the final else"* — is **REFUTED by this pass's
grid**: the select was never any part of the discriminator. Deleting ONE
conjunct (`!idxGroups.empty()`) plus one leaf-fullname stamp clears the head.

`Earlgrey_0_1/default`'s 48-line head is **CLEARED**, the whole design moved by
**11 objects in 4.65 million dump lines**, and the object-level mover fence
computed from the PRISTINE dump predicted **exactly those 11**, 5 + 6, cell for
cell, with nothing else reachable.

---

## 0. THE LAW

> **§ genConnDottedActualIsHierPath37 — in the DEF-view listing, a port
> connection whose ACTUAL is a DOTTED path is a `hier_path`, and the SELECT is
> not a discriminator: `a.b` and `a[i].b` and `a.b.c.d` get the same object.
> Every path element but the last carries the BARE written component text as
> both name and fullname; the LAST element, WHEN IT IS A `ref_obj`, carries
> `<scope>.<instance>.<formal>.<component>` — the fullname that scopes THROUGH
> THE CHILD'S FORMAL PORT, not through the actual's own declaration. A
> non-`ref_obj` last element (a `part_select` / `indexed_part_select` tail) keeps
> its own bare path text.**
>
> The rule is INDIFFERENT to every axis the corpus exposes: the base may be the
> enclosing module's INPUT PORT, a module-local VAR, an INTERFACE PORT, a
> LOCALLY-INSTANTIATED interface or a MODPORT; the connection may be named or
> positional; the nesting may be one, two or three members deep; the carrier may
> be a `ref_module` or a `module_array`; and the block may be a genvar generate
> body or the plain module body. **Golden's answer is the same hier_path in all
> of them**, and the whole-design control proves it: in golden's 4.82M-line
> Earlgrey dump there are **ZERO** def-view dotted-name `ref_obj` HighConns and
> **ZERO** def-view `hier_path`s whose last `ref_obj` element lacks a fullname.
>
> What the rule does NOT reach: an actual with **no dot** (`q38::PKW` folds to a
> constant — a different law, residue **R2**), an actual that is an OPERATION
> (`pin_i.rd & x` — golden's operation over a hier_path operand, which the
> operator arm already builds), and the whole-port pass-through (`.all_i(pin_i)`,
> a plain bound `ref_obj`).

| # | site | what changed |
|---|---|---|
| 1 | `src/ModuleEmit.cpp` ~25505, the GEN-SCOPE conn loop's `dotHp9` gate + its `High_conn` arm | drop the `!idxGroups.empty()` conjunct; POST-STAMP the leaf `ref_obj`'s fullname |
| 2 | `src/ModuleEmit.cpp` ~2358, the PLAIN-BODY MODULE-ARRAY conn loop's `hcA` gate | admit a dotted `ScopedName`; the existing `syntaxRefPrefix` already writes golden's leaf fullname |

`git diff --stat 45716d3 -- src include` = **1 file, 63 insertions, 4
deletions**. Of the 63 added lines **49 are comment and 14 are code**; of the 4
removed, 2 are the comment sentence this pass refutes and 2 are the two gate
lines it rewrites. So the behavioural change is **14 lines of code at two
sites**. No `include/` change, therefore **no new member, no new helper, no new
predicate**: `emitSyntaxExpr`'s `ScopedName` arm and `syntaxRefPrefix` are called
exactly as they already stood.

### STATED GATE == CODE GATE

Read verbatim — this is the entire behavioural change.

**Call site 1**, the gate (one conjunct removed, nothing added):

```cpp
if (dotSyn9->kind == syntax::SyntaxKind::ScopedName &&
    !act.empty() &&
    act.find('.') != std::string::npos)
    dotHp9 = emitSyntaxExpr(*dotSyn9, p);
```

**Call site 1**, the stamp, inside the arm that was already there:

```cpp
auto* hp37 = (UHDM::hier_path*)dotHp9;
if (auto* pes37 = hp37->Path_elems(); pes37 && !pes37->empty())
    if (auto* lf37 = pes37->back();
        lf37->UhdmType() == UHDM::uhdmref_obj)
        ((UHDM::ref_obj*)lf37)
            ->VpiFullName(branchPrefix + "." + iname + "." +
                          formal + "." + std::string(lf37->VpiName()));
p->High_conn((UHDM::expr*)dotHp9);
```

**Call site 2**, the gate (one disjunct added):

```cpp
bool dotA37 = csA && csA->kind == syntax::SyntaxKind::ScopedName &&
              rawText(csA->sourceRange()).find('.') != std::string::npos;
if (!ifaceArr && csA && ax->kind != ExpressionKind::NamedValue &&
    (csA->kind == syntax::SyntaxKind::ElementSelectExpression ||
     csA->kind == syntax::SyntaxKind::IdentifierSelectName || dotA37)) {
```

Every clause is load-bearing with a measured cell behind it:

* `kind == ScopedName` — slang parses `a.b` as a `ScopedNameSyntax` with a DOT
  separator, so this is the ONLY kind the rule can reach. It also makes the
  dot test safe: a real literal `1.5` and a string `"a.b"` are other kinds and
  never enter (they cannot be mis-parsed as a path).
* `act.find('.') != npos` — a `::`-only actual is a DIFFERENT rule and golden
  answers it with a folded constant. a2 `f_pkgc` is the cell; it is the one cell
  in either grid that is still wrong after the patch, and it is still wrong in
  exactly the way it was before (residue **R2**).
* **the stamp is a POST-STAMP, not a `syntaxRefPrefix` assignment** — and this
  is the one non-obvious decision in the pass. Setting the prefix would ALSO
  rewrite a `bit_select` element's fullname, and golden keeps those BARE:
  a2 `f_selint` (`uarr_i[b]`) and `f_mparr` (`arr_if[b]`) are the two cells that
  forbid it. Call site 2 needs no stamp for the mirror-image reason — its
  `syntaxRefPrefix` is already the array/formal scope and the emitter's own leaf
  rule writes golden's string.
* **only a `ref_obj` leaf is stamped** — a1 `g_psel` and a2 `f_seltail` end in a
  select object whose fullname golden leaves as the bare path text.

The change is **NARROW and MONOTONE**: it can only replace ONE object at ONE
slot (a port's `vpiHighConn`) with the hier_path the ELAB emitter already builds
for the same connection, or write ONE string onto that hier_path's leaf. It
cannot touch the elaborated view at all — a different emitter, asserted per-arm
below — and it can reach no object outside a `vpiHighConn` subtree. That is why
§ 4's fence is a formal consequence and not a pattern match.

---

## 1. THE TARGET, MEASURED — and all three of the brief's candidates refuted

`Earlgrey_0_1/default` at BASE `45716d3`, head measured by me before any edit
(48 cmp lines; LHS is golden, RHS is ours, quoted from `uhdm-cmp` verbatim):

```
LHS hier_path: (flash_ctrl_i.rd), id:90798, line:129:13, endln:129:28
    |vpiParent: \_port: (rd_i), id:90797, line:129:7, endln:129:29
    |vpiActual: \_ref_obj: (flash_ctrl_i), line:129:13, endln:129:25   |vpiName:flash_ctrl_i
    |vpiActual: \_ref_obj: (work@flash_phy.gen_flash_banks.i_core.rd_i.rd), line:129:26, endln:129:28
                |vpiName:rd  |vpiFullName:work@flash_phy.gen_flash_banks.i_core.rd_i.rd
    |vpiName:flash_ctrl_i.rd

RHS ref_obj: (work@flash_phy.gen_flash_banks.i_core.rd_i.flash_ctrl_i.rd), id:86178,
             line:129:13, endln:129:28
    |vpiParent: \_port: (rd_i), id:86177, line:129:7, endln:129:29
    |vpiName:flash_ctrl_i.rd
    |vpiFullName:work@flash_phy.gen_flash_banks.i_core.rd_i.flash_ctrl_i.rd
```

`flash_phy.sv:129` — `.rd_i(flash_ctrl_i.rd)` inside
`for (genvar bank = 0; bank < NumBanks; bank++) begin : gen_flash_banks`, where
`flash_ctrl_i` is flash_phy's own `input flash_ctrl_pkg::flash_req_t` port and
`rd` a 1-bit member of that packed struct. This is r10earl36's residue **R4**,
inherited by name.

### the brief's three candidates, each refuted BY THE SAME CENSUS

The whole diagnosis fits in a 120-line file. `a1_pact.sv`'s `g_named` cell is
`.rd_i(pin_i.rd)` in a genvar block, and the census prints both views of it:

| view | GOLDEN | PRISTINE |
|---|---|---|
| **DEF** (`ref_module i_gn`) | `hier_path(pin_i.rd)` → `ref_obj(pin_i)` bare + `ref_obj(rd)` full `work@top37.gen_b.i_gn.rd_i.rd` | **`ref_obj` name=`pin_i.rd`** full `work@top37.gen_b.i_gn.rd_i.pin_i.rd` |
| **ELAB** (`module_inst gen_b[0].i_gn`) | `hier_path(pin_i.rd)` + ref_typespec + the two elements + `vpiExpr -> struct_net work@top37.pin_i` | **byte-identical to golden** |

* **"the second ref's FULLNAME (scoped through the PORT)" — REFUTED.** That
  string is not merely correct in the elab view, it is *already produced by a
  named rule* on the AST path: `src/ModuleEmit.cpp`'s
  *"A struct-member (dotted) conn on a REGULAR port scopes its LAST element
  through the child port path"* writes `connScope9 + "." + last->VpiName()`, and
  the plain-body cells (`p_named`, `p_loc`, `p_nest`) print it byte-identically
  to golden in PRISTINE. Nothing about the fullname needed deciding; it needed
  *reaching*.
* **"a missing vpiActual binding" — REFUTED, and there is no binding to miss.**
  `vpiActual` on a `hier_path` is the dump's label for `Path_elems`, not a
  resolution edge. In the DEF view golden binds **nothing** on any element: each
  is a bare `ref_obj` with a name and (for the leaf) a fullname, and no
  `Actual_group` at all. The census prints the complete attribute set of every
  element and there is no binding anywhere in it.
* **"the member decomposition" — REFUTED.** The decomposition golden wants is
  one element per written component with the leaf last, and `emitSyntaxExpr`'s
  `ScopedName` arm has produced exactly that since r10earl8 — a2 `f_deep`
  (`deep_i.mid.inner.rd`) comes out with four elements in the right order the
  moment the gate lets it run.

### WHERE the head actually is: a SECOND, TEXT-DRIVEN emitter

A gen-block's DEF-view listing is not emitted from the bound AST. It is built
from SYNTAX by its own loop in `ModuleEmit.cpp` (~25160 onward), which parses
the actual's raw TEXT for `[`…`]` groups and operators. Its dotted-path arm
required `!idxGroups.empty()` — a select — so `pin_i.rd`, having no brackets,
fell to the loop's **final else**: one `ref_obj` named with the whole raw text
and a fullname doubling the formal onto it. That is the exact RHS above, and it
is why the head is a naming-shaped print of a MISSING-OBJECT defect.

### the head after the patch: CLEARED

```
LHS/RHS named_begin: (work@padring.gen_mio_pads.gen_mio_input)
        (padring.sv:126 — golden emits two `assignment` statements for
         `logic unused_out, unused_oe;` that we do not emit at all)
596 cmp lines
```

`Earlgrey_0_1/default` stays `CMP_NOTEQUAL` (its ROW does not move, by design);
the new head is an unrelated family in an unrelated file. Residue **R3**.

---

## 2. REFUTATIONS

**F1 — r10earl8's own closing sentence at this site is FALSE.**
*"An UNSELECTED `a.b` still keeps the doubled-fullname ref_obj of the final
else."* Measured on 9 unselected cells across two arms and 5 corpus objects:
golden gives every one of them a hier_path. § genConnDotSelInterior's
observation (that Surelog keys on the path being *selected at all*, rather than
on it *ending* in `]`) was a step in the right direction that stopped one step
short — the select is not a condition, it is irrelevant.

**F2 — the brief's "the failing pair may be the second ref's FULLNAME / a
missing vpiActual binding / the member decomposition" is FALSE on all three
counts,** each disproved by the same census in § 1, and each for the same
underlying reason: those three things live in the emitter that was never
reached, so none of them could have been the defect.

**F3 — "read our side from the cmp log RHS" would have MISLED.** The cmp log's
RHS prints a `ref_obj` with a *dotted vpiName* and a *dotted fullname*, which
reads exactly like a naming-policy bug — and the campaign's own memory note
("naming residues are often parent-policy bugs; check vpiParent before name
code") points at yet another wrong place. Both sides' `vpiParent` are the same
port. The KIND was the difference, and only a shape census keyed on
(view, instance, formal) makes the kind the first thing you see.

**F4 — MY OWN first plan was wrong, and the grid caught it before the build.**
Reading the working AST path, the obvious transposition was *"set
`syntaxRefPrefix` to the instance/formal scope around the `emitSyntaxExpr`
call"*, which is what call site 2 does. On the gen-scope path that would have
been an **over-fire**: `syntaxRefPrefix` is also read by the `bit_select`
element branch, and a2 `f_selint` / `f_mparr` show golden keeping those elements'
fullnames at the BARE select text (`uarr_i[b]`, `arr_if[b]`). Had the prefix been
set, 6 already-correct pinmux prints and 2 grid cells would have broken while
the target was fixed. The post-stamp is the version that abstains.

**F5 — a prior measured law does NOT extend here, and golden says so.** The
`ScopedName` arm carries *"A gen-scope modport-array member path gives the LEAF
the RAW dotted fullname (Surelog)"* (`genVarBaseEmitted`). a2's `f_mparr` cell
(`.bus_i(arr_if[b].mp)`) is precisely a gen-scope modport-array member path in a
PORT CONNECTION, and golden's leaf fullname there is
`work@top38.gen_c.i_ma.bus_i.mp` — **the child-port scoping, not the raw text**.
So that law belongs to some other position (a cont-assign), the unconditional
stamp is correct at this one, and the cell is now `FIXED` rather than a
counterexample. This is why the cell was written: I expected a fence and
measured a confirmation.

**F6 — a measurement-instrument defect I introduced and FIXED before landing.**
`pactcen.py`'s first version keyed a `module_array`'s rows on the object's
parenthesised dump name — which for an ARRAY is its `vpiFullName`, i.e. the
DEFINITION name (`work@ch38`). Two different arrays of the same child therefore
collapsed onto one census key and the per-cell `join` produced a **cartesian
product of 8 meaningless rows per formal, including two invented
`*** REGRESSION ***` verdicts**. The instance name is in the object's own
`|vpiName:` attribute; the key now reads that and appends the span. The number
that was never wrong is the DIRECT census diff (`a2` golden-vs-patched = 1
differing row), which is what caught the artefact.

**F7 — the source-derived fence in `pred37.py` is HONESTLY WEAK, and the fence
that binds is a different one.** `pred37.py` enumerates dotted named-conn
actuals from source text; on Earlgrey it finds **2266**, against **11** real
movers, because it cannot tell a gen-scope/module-array connection from a
plain-body one (the plain body's AST path was already correct). Widening its
per-test walk to catch filelist sources outside the `.sl`'s own directory made
it worse, not better: 36 candidate tests became 768. **The fence used in § 4 is
therefore the OBJECT-level one computed from the PRISTINE DUMP**, which is
exact. `pred37.py` is kept because it is the only instrument that shows the
population is large and the *reach* is small, which is itself the finding.

---

## 3. THE GRID, CELL FOR CELL

`arm37.sh a1_pact.sv` / `a2_fence.sv`, census through `pactcen.py`, keyed on
(view, instance@span, formal). LHS always golden. Every row below is the DEF
view; the ELAB view is asserted separately at the end of each table.

### 3a. a1_pact.sv — the WITNESS and its axes (24 DEF cells)

| cell | shape | GOLDEN | PRISTINE | PATCHED | verdict |
|---|---|---|---|---|---|
| **`g_named` (i_gn) rd_i / addr_i** | **bare member of an INPUT PORT, named conn, IN A GENVAR BLOCK — THE WITNESS** | `hier_path` + bare base + leaf full `…i_gn.rd_i.rd` | **`ref_obj('pin_i.rd')`** | = golden | **FIXED ×2** |
| **`g_loc` (i_gl) rd_i / addr_i** | base is a module-LOCAL var, in gen | `hier_path`, leaf `…i_gl.rd_i.rd` | `ref_obj` | = golden | **FIXED ×2** |
| **`g_nest` (i_gnst) rd_i / addr_i** | TWO-level member `onest_i.inner.rd`, in gen | `hier_path`, 3 elems, middle `inner` BARE | `ref_obj` | = golden | **FIXED ×2** |
| **`g_psel` (i_gps) rd_i** | the bare sibling of a selected conn | `hier_path` | `ref_obj` | = golden | **FIXED** |
| `g_psel` (i_gps) addr_i | `pin_i.addr[0 +: 8]` — leaf is an `indexed_part_select` with its own BARE text | `hier_path`, leaf ips full `pin_i.addr[0+:8]` | same | same | ok (the leaf is not a ref_obj) |
| **`g_op` (i_gop) addr_i** | the bare sibling of an OPERATION conn | `hier_path` | `ref_obj` | = golden | **FIXED** |
| `g_op` (i_gop) rd_i | `pin_i.rd & (b == 0)` — the actual is an OPERATION | `operation` over a `hier_path` operand | same | same | ok (operator arm, r10earl8) |
| `g_whole` (i_gw) all_i | `.all_i(pin_i)` — WHOLE port, no dot | `ref_obj(pin_i)` | same | same | ok |
| `p_named` (i_pn) rd_i / addr_i | the SAME shape in the PLAIN body | `hier_path`, leaf scoped | **same as golden** | same | ok — the AST path was always right |
| `p_loc` (i_pl) rd_i / addr_i | local base, plain body | `hier_path` | same | same | ok |
| `p_nest` (i_pnst) rd_i / addr_i | 3-elem path, plain body | `hier_path` | same | same | ok |
| `*_ack_o` ×7 | `ack_o[b]` / `ack_o[2+b]` — the non-dotted controls in every cell | `bit_select` | same | same | ok |

**FIXED = 10 cells. unchanged-correct = 14. STILL WRONG = 0. REGRESSIONS = 0.**
`diff` of the WHOLE a1 DEF-view census, golden vs patched: **IDENTICAL, 0 rows.**
`diff` of the a1 ELAB-view census, pristine vs patched: **ELAB_UNCHANGED** — the
proof that the two views are two emitters and only one was touched.

**The separating pair is `p_named` against `g_named`.** Same file, same base,
same member, same named connection, same formal — the ONLY difference is that
one instance sits in a `for (genvar …)` block. Golden's answer is the same for
both; ours was not. **The POSITION (which emitter compiles the listing), not any
property of the actual, is the whole discriminator**, which is why every axis in
the table above turns out not to be an axis.

### 3b. a2_fence.sv — the OVER-FIRE FENCE (35 DEF cells)

Every cell is a dotted actual in a gen block that is NOT the witness's shape —
i.e. exactly what a widened gate could damage.

| cell | shape | GOLDEN | PRISTINE | PATCHED | verdict |
|---|---|---|---|---|---|
| **`f_mp` (i_mp) bus_i** | **modport-QUALIFIED actual on an INTERFACE port** (`u_if.mp`) | `hier_path`, leaf full `…i_mp.bus_i.mp` | `ref_obj('u_if.mp')` | = golden | **FIXED** |
| **`f_ifsig` (i_ifs) rd_i** | an INTERFACE-PORT member read on a REGULAR port (`ifp.sig`) | `hier_path`, leaf `…rd_i.sig` | `ref_obj` | = golden | **FIXED** |
| **`f_ifloc` (i_ifl) rd_i** | a LOCALLY instantiated interface's member (`u_if.other`) | `hier_path`, leaf `…rd_i.other` | `ref_obj` | = golden | **FIXED** |
| **`f_selint` (i_si) rd_i / addr_i** | **a SELECT on an INTERIOR component** (`uarr_i[b].rd`) — r10earl8's own cell | `hier_path`; base `bit_select` full **BARE** `uarr_i[b]`; leaf `ref_obj` full `…i_si.rd_i.rd` | hier_path with a **NOFULL** leaf | = golden | **FIXED ×2** (the SECOND defect this pass found) |
| `f_seltail` (i_st) addr_i | a select at the TAIL (`pin_i.addr[7:0]`) | `hier_path`, leaf `part_select` full BARE | same | same | ok (leaf not a ref_obj) |
| **`f_seltail` (i_st) rd_i** | its bare sibling | `hier_path` | `ref_obj` | = golden | **FIXED** |
| `f_hier` (i_hi) rd_i | `sib_w` — a plain module wire, NO dot | `ref_obj`, doubled fullname | same | same | ok — the final else still owns it |
| **`f_hier` (i_hi) addr_i** | its dotted sibling | `hier_path` | `ref_obj` | = golden | **FIXED** |
| **`f_pkgc` (i_pk) w_i** | **`q38::PKW` — `::` and NO dot** | **`constant`** | `ref_obj('q38::PKW')` | `ref_obj` | STILL WRONG — **R2**, untouched by design |
| **`f_deep` (i_dp) rd_i / addr_i** | THREE levels (`deep_i.mid.inner.rd`) | `hier_path`, 4 elems, both middles BARE | `ref_obj` | = golden | **FIXED ×2** |
| **`f_mparr` (i_ma) bus_i** | **a MODPORT-ARRAY member path** (`arr_if[b].mp`) — the expected counterexample | `hier_path`; leaf full **`…i_ma.bus_i.mp`**, NOT the raw text | hier_path, NOFULL leaf | = golden | **FIXED** — and F5 |
| **`f_arr` (i_ar) rd_i / addr_i** | the **MODULE-ARRAY** carrier inside the gen block | `hier_path`, leaf `…i_ar.rd_i.rd` | `ref_obj` | = golden | **FIXED ×2** (call site 1 serves `module_array` too) |
| **`f_parr` (i_parr) rd_i / addr_i** | **a MODULE ARRAY in the PLAIN body — CALL SITE 2** | `hier_path`, leaf `work@top38.i_parr.rd_i.rd` | `ref_obj` named **`rd`** spanning the whole `pin_i.rd` | = golden | **FIXED ×2** |
| `u_dut` ×5, `*_ack_o` ×12 | the wrapper's own conns and the non-dotted controls | — | same | same | ok |

**FIXED = 18 cells. unchanged-correct = 16. STILL WRONG = 1 (`f_pkgc`, a
different law). REGRESSIONS = 0.** a2 ELAB census, pristine vs patched:
**ELAB_UNCHANGED.**

`f_hier`'s two ports are the cleanest fence in the pass: **`.rd_i(sib_w)` and
`.addr_i(pin_i.addr)` are the same connection list on the same instance**, and
the patch moves the second and not the first — the dot conjunct doing its work
in one line of source.

### 3c. the DESIGN-SCALE over-fire control

The grids are 59 cells; the design is 34 542 census rows. Run on the WHOLE
4.82M-line golden Earlgrey dump:

| | golden | pristine | patched |
|---|---|---|---|
| DEF-view port HighConns that are a `ref_obj` with a DOTTED name | **0** | **5** | **0** |
| DEF-view port HighConn `hier_path`s whose last `ref_obj` element has NO fullname | **0** | **6** | **0** |

**Golden never once produces either shape and after the patch neither do we.**
That is the law stated as a whole-design invariant rather than as a cell count,
and it is also the exact reachable set — see next section.

---

## 4. THE MOVER FENCE — computed from the PRISTINE dump, and it closes EXACTLY

The fence is not a source pattern (F7). The patch can write to exactly two
shapes and the pristine dump contains a countable number of each:

> **PREDICTION (`pactcen.py` on the PRISTINE Earlgrey dump, before the sweeps):
> movers = 5 + 6 = 11 objects.**
> * **5** convert `ref_obj -> hier_path`: `flash_phy.sv` 129 `rd`, 130 `prog`,
>   131 `pg_erase`, 132 `bk_erase`, 134 `prog_data` — all five actuals of
>   `i_core` in `gen_flash_banks` that are bare member selects. (`flash_phy.sv`
>   :124 is an operation and :133 a select, both already correct.)
> * **6** get a leaf fullname stamped: `pinmux.sv` 238 `q`, 239 `q`, 241 `q`,
>   244 `qe`, 245 `q`, 246 `d` — `i_pinmux_wkup` in `gen_wkup_detect`, all six
>   `reg2hw.…[k].<member>` interior-select paths.
> * ADDED lines outside those 11 subtrees = 0; REMOVED outside them = 0. Any
>   other mover is an OVER-FIRE and fails the pass.

Measured, PRISTINE dump vs PATCHED dump (both `sed 1d`, whole design):

```
$ diff o.dump p.dump
REMOVED lines: 16     ADDED lines: 72     HUNKS: 27
o lines 4654903       p lines 4654959
```

**27 hunks in 4.65 million lines, over exactly the 11 predicted objects and
nothing else.** Each of the 11 was then read against golden and is
**byte-for-byte golden's print**; the target's group verbatim:

```
          \_hier_path: (flash_ctrl_i.rd), line:129:13, endln:129:28
            |vpiParent:
            \_port: (rd_i), line:129:7, endln:129:29
            |vpiActual:
            \_ref_obj: (flash_ctrl_i), line:129:13, endln:129:25
              |vpiParent:
              \_hier_path: (flash_ctrl_i.rd), line:129:13, endln:129:28
              |vpiName:flash_ctrl_i
            |vpiActual:
            \_ref_obj: (work@flash_phy.gen_flash_banks.i_core.rd_i.rd), line:129:26, endln:129:28
              |vpiParent:
              \_hier_path: (flash_ctrl_i.rd), line:129:13, endln:129:28
              |vpiName:rd
              |vpiFullName:work@flash_phy.gen_flash_banks.i_core.rd_i.rd
            |vpiName:flash_ctrl_i.rd
```

### per-shape, against GOLDEN, by MULTISET (`msdist.sh`, dumps `sed 1d`)

| | golden-only | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| pristine vs golden | 238937 | 70392 | **309329** |
| patched vs golden | 238875 | 70386 | **309261** |
| delta | **−62** | **−6** | **−68** |

The pristine figure `309329` is bit-identical to the number r10earl36's README
recorded for its own PATCHED build, and `o.dump` is 4654903 lines — r10earl36's
patched line count. An independent confirmation that this pass' PRISTINE build
reproduces the landed baseline `45716d3`.

### ADDED and REMOVED accounted separately, per distinct line

61 distinct line shapes changed. **59 of them reach EXACT golden parity
(|g−p| = 0)**; the accounting of the other two, and the closure:

| line shape | golden | pristine | patched | \|g−o\| | \|g−p\| |
|---|---|---|---|---|---|
| the 59 target shapes (5 `hier_path` ×2 depths, 11 element `ref_obj`s, 11 `vpiFullName`s, 6 removed `ref_obj`s, 5 removed fullnames, 6 `vpiName`s …) | — | — | — | **1836−1768 accounted below** | **0 each** |
| `\_hier_path: (flash_ctrl_i.rd) …` (depth 10) | 2 | 0 | 2 | 2 | **0** |
| `\_hier_path: (flash_ctrl_i.rd) …` (depth 8) | 1 | 0 | 1 | 1 | **0** |
| `\_ref_obj: (work@…i_core.rd_i.flash_ctrl_i.rd) …` | 0 | 1 | 0 | 1 | **0** |
| `|vpiName:flash_ctrl_i` | 6 | 1 | 6 | 5 | **0** |
| `\_ref_obj: (q), line:238:56, endln:238:57` | 0 | 1 | 0 | 1 | **0** |
| `|vpiParent:` (that indent) | 56207 | 54551 | 54561 | 1656 | **1646** |
| `|vpiActual:` (that indent) | 59376 | 59488 | 59498 | 112 | **122** |
| **SUM over all 61 changed shapes** | | | | **1836** | **1768** |

`1836 − 1768 = −68`, which is the whole-design multiset delta **to the unit** —
so no line outside the 61 changed shapes moved at all, and the accounting closes.

### CALL SITE 2 HAS ZERO MEASURED CORPUS REACH — stated, not hidden

All 11 movers are CALL SITE 1 (`flash_phy` and `pinmux`, both gen scopes). Across
**2311 databases in two corpora and two modes, call site 2 moved nothing at
all**: no test in either corpus writes a dotted actual on a plain-body module
ARRAY. Its entire evidence is therefore the a2 `f_parr` cell, where golden's
answer was measured directly and PRISTINE was wrong. It is kept because it is
the same § at its second position and because its blast radius is measured at
exactly zero — but a reader should know that the corpus does not test it and only
the grid does.

**59 shapes to exact parity, one shape 10 closer, one shape 10 further.** The
honest cost is stated rather than netted: `|vpiParent:` at that indent was a
DEFICIT (54551 < 56207) and gains 10, `|vpiActual:` was already a SURPLUS
(59488 > 59376) and gains 10 the wrong way. Both are generic relation lines, and
a hier_path necessarily prints one of each per element — golden pays the same
price for the same object, which is why the surplus is a POPULATION difference
elsewhere (residue **R5**) rather than anything this patch chose.

---

## 5. THE FIVE GATES, each with the number I measured

**BASE printed and grep-checked on every binary.** Both worktrees report
`git rev-parse HEAD` = `45716d32f8bedb149dac4be776e38afb1148e71c` (grep-asserted
against the literal, not eyeballed), and `git status --porcelain` in the PRISTINE
worktree is **empty**.

| binary | md5 | 32-hex asserted |
|---|---|---|
| PRISTINE 45716d3 (built here) | `65f339fdc5b4497ec6a2773f7462113f` | yes |
| PATCHED | `ff9f076343d0253cc7f3b310a65b5381` | yes |

**GATE 1 — BUILD.** Absolute path `/tmp/wt_r10earl37/build/slang-uhdm`. Waited
for the link line (`[ 88%] Linking CXX executable slang-uhdm` -> `[100%] Built
target slang_uhdm`); `grep -iE 'error:'` = **0 lines**. md5 taken in a SEPARATE
step from the build, 32-hex-checked, and it differs from pristine. **GREEN.**

**GATE 2 — GOLDENS.** `tests/check_goldens.sh` with **`SLANG_UHDM` set
explicitly**: **23 PASS / 0 FAIL**. Negative control `SLANG_UHDM=/bin/false`:
**0 PASS / 23 FAIL**. Recorded because it nearly went wrong: the script
DEFAULTS `SLANG_UHDM` to the MAIN TREE, so my first run measured a binary that
is not under test and printed a green 23 anyway. **GREEN.**

**GATE 3 — uhdm2rtlil, `--mode both`, `--jobs 2`.**

```
[default]   CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2   -> 679/50/2  EXPECTED
[testflags] CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2   -> 679/50/2  EXPECTED
dump (testflags): 496 match / 183 differ / 52 blank            -> 496/183/52 EXPECTED
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
```
The committed baseline carries **testflags rows only** (`awk` count of
non-testflags baseline rows = **0**), so the row gate is fed the testflags
projection: 731 rows against 731, testflags-to-testflags — the committed gate,
not a weakened one. The sweep ran both modes because GATE 5 needs both modes'
databases; the default-mode dump histogram is `492 match / 187 differ / 52`, and
it is **not** part of any committed gate — stated here so the number is not
mistaken for a regression against a baseline that does not contain it. **GREEN.**

**GATE 4 — surelog, BOTH modes, `--jobs 2`.**

```
[default]   CMP_EQUAL 467   CMP_NOTEQUAL 13   -> 467/13  EXPECTED
[testflags] CMP_EQUAL 463   CMP_NOTEQUAL 10   -> 463/10  EXPECTED
ct8rows vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
dump histograms UNCHANGED both modes:
  default   327 blank / 242 differ / 225 match   (base == fresh)
  testflags 331 blank / 298 differ / 165 match   (base == fresh)
```
`SURELOG_FAIL` = 25 (default) / 23 (testflags), **byte-identical to the
committed baseline's own counts** — so the documented detail-row race under
concurrent sweeps did not fire and no isolated re-run was owed.
`Earlgrey_0_1/default` stays `CMP_NOTEQUAL` and `testflags` stays
`SLANG_REJECT`: its ROW does not move, its BYTES do, which is exactly the
target. **GREEN.**

**GATE 5 — BYTE VERIFIER**, `r10oth6repro/byteverify.sh`, patched vs the
PRISTINE 45716d3 I built, **both corpora BOTH modes**, `SELFCHECK=1
SELFCHECK1=1`, movers attributed per-shape against GOLDEN by MULTISET with
ADDED/REMOVED counted separately (§ 4), and the movers PREDICTED from the
pristine dump first (§ 4).

```
uhdm2rtlil, BOTH modes:
  PATH_SETS_IDENTICAL (1358 paths)
  MOVERS: 0 / 1358
  SELFCHECK  1357 / 1358 flagged   (the one fixed file matches itself)
  SELFCHECK1 1                     (exactly the one corrupted file)

surelog, BOTH modes:
  PATH_SETS_IDENTICAL (953 paths)
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  <- THE TARGET, predicted
  MOVERS: 1 / 953
  SELFCHECK  952 / 953 flagged
  SELFCHECK1 2                     (1 corrupted + the 1 reported mover)
```

**ONE real mover in 2311 databases, and it is the target. No flake fired** —
`Scoreboard`, the documented multi-stable emitter-nondeterminism case, compared
EQUAL on both sides this run, so no attribution was owed. Both sides of the
mover were `cmp`-checked against the databases § 1 and § 4 analysed:
`PATCHED_DB_IDENTICAL_TO_ANALYSED` and `PRISTINE_DB_IDENTICAL_TO_ANALYSED` — the
analysis and the gate measure the same bytes. **GREEN.**

### CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `golden_surelog.csv` | **ok=52 changed=0 absent=0** unknown-names=7 (the u2r-only names, expected) |
| `canaries.sh` vs `gate_uhdm2rtlil.csv` (testflags projection) | **ok=8 changed=0 absent=0** unknown-names=25 (expected) |
| `ctcan2.sh` EXPECT_UNKNOWN=1 (surelog), baseline FIRST | **PASS** — ok=58 changed=0 absent=0 unknown-patterns=1 |
| `ctcan2.sh` EXPECT_UNKNOWN=6 (u2r), baseline FIRST, mode-matched | **PASS** — ok=1 changed=0 absent=0 unknown-patterns=6 |
| `canaudit.sh <canaries.sh> <ctcan2.sh>` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| `InterfaceModPort` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `BlackParrotComplex` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `Earlgrey_0_1` BY NAME | base `default/CMP_NOTEQUAL testflags/SLANG_REJECT` == fresh |

Both `ctcan2` runs are baseline-FIRST and mode-matched; the u2r runs are fed the
testflags projection for the same reason GATE 3 is. The four SLANG-FENCED names
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched by
no driver in this directory — asserted by `canaudit.sh`, not by a sentence.

### BOUNDARIES — checked, no collision

The brief's three named owners were grepped and read before any edit and none
of them is touched: § hpMixedIdxPkgFold34 owns element-select INDEX TEXT (this
pass writes no index and no `dispRaw`), § parensLessEventPathBaseRef9 owns
parens-less EVENT paths (a port connection is not an event expression), and
§ vifClockingPathComponent5 owns CLOCKING components. The two ADJACENT hier_path
families were checked against the localized pair specifically:
**earl33-F2** (unbound refs missing `enum_const` clones in gen scopes) — this
pass sets no `Actual_group` anywhere and adds no clone; the 11 moved objects
carry no binding on either side. **earl34-R1** (middle-ref fullname) — the
adjacency is real and the answers agree: every MIDDLE element here keeps the
BARE component text (a1 `g_nest`'s `inner`, a2 `f_deep`'s `mid` and `inner`,
both measured against golden), and the stamp is applied to the LAST element
only. The two live passes `r10svs14` and `r10uvm66` touch neither
`ModuleEmit.cpp`'s gen-conn loop nor its module-array conn loop.

---

## 6. RANKED RESIDUES

**R1 — the SELECT-TAILED path's last element is the next layer of THIS law, it
is fully characterised, and it is the single biggest remaining DEF-view HighConn
family.** When a dotted actual's LAST component carries the select
(`hw2reg_wrap.class_accum_cnt[k]`), golden's leaf `bit_select` gets **three**
things we get wrong at once:

| field | GOLDEN | OURS |
|---|---|---|
| `vpiName` | the last component's BASE name — `class_accum_cnt` | the WHOLE path text — `hw2reg_wrap.class_accum_cnt[k]` |
| `vpiFullName` | `…i_accu.accu_cnt_o.hw2reg_wrap.class_accum_cnt[k].class_accum_cnt` (scope + formal + whole path + base) | the bare path text |
| span | the INDEX token only — `152:51-152:52` | the whole component — `152:35-152:50` |

Design population: **15 `hier_path` + 27 `bit_select` census rows** on Earlgrey
(`alert_handler.sv` 148–152 / 159–171, `gpio.sv` 40, and the `pinmux` block).
This is *the* cheapest true extension of § genConnDottedActualIsHierPath37 and it
already has its own witness (`a2_fence.sv`'s `f_selint` is one index-position
away from it). Deliberately NOT folded in: it is a THREE-field rule on a
DIFFERENT element kind, and this pass owns one head.

**R2 — a `::`-scoped actual with no dot is FOLDED by golden and kept a ref_obj by
us.** a2 `f_pkgc` (`.w_i(q38::PKW)`): golden emits a `constant`, we emit
`ref_obj('q38::PKW')` with a doubled fullname. PRE-EXISTING and untouched (the
gate's dot conjunct abstains). This is the gen-scope port-CONNECTION position of
the package-parameter fold whose call-argument position is
§ fcArgPkgParamValueFolds32 and whose gen-cont-assign position is
§ genCaArgPkgParamValueFolds33 — so it is the SIXTH known position of a law with
five implemented ones, and the delegation pattern § 33 used (bind the read in
the enclosing scope, hand it to `emitExpr`) is the shape to reuse. Corpus
population unmeasured.

**R3 — the NEW HEAD, and it is a MISSING-STATEMENT family, not a naming one.**
`Earlgrey_0_1/default` after this pass: `named_begin
(work@padring.gen_mio_pads.gen_mio_input)`, 596 cmp lines. Golden emits two
`assignment` statements (opType 82, blocking) for `logic unused_out,
unused_oe;` declared inside the gen-if branch at `padring.sv:126` — a
DECLARATION with no initializer becoming a statement — and we emit neither, so
the divergence is a `vpiStmt` VECTOR SIZE mismatch, which is why the cmp log's
first 90 lines print identically on both sides. A different family from every
naming and fold law in the earl29–earl37 chain, and the natural next pass.

**R4 — the a2 ELAB view has three pre-existing defects the a1 witness does not
expose**, catalogued because the arm now measures them: (a) `f_selint`'s elab
`hier_path` name keeps the UNFOLDED genvar (`uarr_i[b]` where golden has
`uarr_i[0]`) and has no `vpiExpr`; (b) `f_seltail` / `f_deep` elab hier_paths are
missing their `vpiTypespec` `ref_typespec`; (c) `f_ifsig`'s elab `logic_var`
HighConn is missing name, fullname and typespec. All three are in the ELAB
emitter, all three are byte-identical before and after this patch
(`ELAB_UNCHANGED`), and all three have a ready-made witness in `a2_fence.sv`.

**R5 — the `|vpiActual:` surplus this patch grows by 10.** § 4's last row. Our
design prints 112 more `|vpiActual:` than golden at that indent BEFORE the patch;
adding golden's own 5 hier_paths and 11 elements necessarily adds more. The
surplus is a population difference elsewhere (objects we emit that golden does
not), pre-existing and an order of magnitude larger than this pass; catalogued so
the net `−68` is not mistaken for "nothing moved the wrong way".

**R6 — `pred37.py` is a weak instrument and its replacement is known.** F7. The
source-text fence over-counts by 200× because it cannot see WHICH emitter
compiles a connection. The instrument that is exact is `pactcen.py` run on the
PRISTINE dump (§ 4), and the way to make a source-derived fence useful would be
to ask slang which instances are in a generate scope rather than to grep for
`for (genvar`.

---

## 7. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm37.sh` | one arm's golden + ours + dumps + cmp. r10earl36's `arm36.sh` carried forward verbatim (prints the binary md5 on every run; `sed 1d` on both dumps; existence-guards every tool because `uhdm-cmp` exits 0 on a missing input; runs in its own scratch dir because Surelog synthesizes `builtin.sv` into the CWD) |
| `a1_pact.sv` | **THE WITNESS AND ITS AXES** — 24 DEF cells crossing the base KIND (enclosing module's input PORT / module-local var), the POSITION (genvar generate body / plain module body), the CONNECTION FORM (named / positional), the ACTUAL SHAPE (bare member / nested member / member+indexed-part-select / member inside an operation / whole port) and the member TYPE (1-bit / vector / nested struct). `p_named` vs `g_named` is the separating pair and it isolates the POSITION as the only discriminator |
| `a2_fence.sv` | **THE OVER-FIRE FENCE** — 35 DEF cells of dotted actuals in a gen block that are NOT the witness: modport-qualified, interface-port member, locally-instantiated-interface member, interior select, tail select, three-level, `::`-with-no-dot, a MODPORT ARRAY (F5's expected counterexample, which golden refutes), the module-ARRAY carrier inside the gen block, and a module ARRAY in the plain body (CALL SITE 2). `f_hier`'s two ports are the dot conjunct's own fence: same instance, same conn list, one moves |
| `pactcen.py` | **THE PORT-ACTUAL CENSUS** — one row per (view, instance@span, formal) with the HighConn's kind / name / span / fullname and every child relation rendered as `kind(name@span)[fullname]`. Purpose-built because the two sides disagree on the OBJECT KIND at the slot, which shifts a line diff and makes per-cell verdicts unreadable. Indent is used only to find an object's own attributes and children and is never part of the key (r10earl35 F5). Back-reference prints (a `port` appearing as some child's `vpiParent`, carrying no attributes) are dropped: they are a second print of one object, not a second port. Carries F6's fix — a `module_array`'s key reads its `|vpiName:` attribute, not its parenthesised dump name, which is the DEFINITION name |
| `pred37.py` | the SOURCE-TEXT fence — enumerates dotted named-conn actuals. **Kept with its weakness stated (F7, R6): it over-counts by 200× and the fence that binds is the object-level one in § 4** |

Reused unchanged and by ABSOLUTE path:
`r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`,
`r10uvm52repro/canaries.sh`, `r10oth6repro/byteverify.sh`,
`r10oth8repro/ct8rows.sh`.
