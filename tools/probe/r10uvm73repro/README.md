# r10uvm73 — `§ classScopedTypedefPropIsBareLogicVar73`: the 50-line head **CLEARED on all THREE target rows** (50 → 42), and the brief's stated axis **REFUTED** — it is not enum-ness and it is not resolvability, it is WHOSE SCOPE THE TYPE NAME LIVES IN

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after, and no conversion
was expected at this depth. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines — whole ROW, dump column included — **0 differing ROWS** on
both, from the patched sweeps AND from my own PRISTINE sweeps.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**.
`SimpleUVM/default`, `SimpleUVM/testflags` and `Scoreboard/default` each sat at
**50** cmp lines on the head `LHS: logic_var (uvm_pkg::uvm_sequence_request::request)`
against our `RHS: enum_var` (+ `ref_typespec` → `enum_typespec (seq_req_t)`).
All three now sit at **42** lines on a head in a different family and a
different object — `LHS: bit_select (arb_sequence_q[i])` @554:32 against our
`RHS: ref_obj (arb_sequence_q[i])`, i.e. a `hier_path` ELEMENT, in
`uvm_sequencer_base::do_print`. The three new heads are **byte-identical to each
other** with ids normalised (`1b5046e2bdc6` on all three).

**THIRD LINE, and it is the finding.** The brief's hypothesis was *"Surelog
cannot resolve the type name from `uvm_sequence_request`'s scope … so the axis
is TYPE-NAME RESOLVABILITY (cross-class unqualified typedef), not enum-ness."*
**Enum-ness is refuted and so is resolvability.** The grid's decisive cell is
`c_self_qual_enum`: a class's **OWN** typedef, declared **in that same class**,
written `selfuser::s_e_t` — nothing to resolve across any boundary — and golden
**still** degrades it to a bare `logic_var`. Its twin `c_self_enum`, the SAME
typedef written bare, does not. Two more cells finish the refutation: the
inherited-but-**unqualified** `e_t` degrades (so a `::` is not necessary
either), and `holder::s_t` / `holder::i_t` / `holder::v_t` — struct, plain
`int`, logic vector — degrade exactly like the enum (so enum-ness is not the
carrier). What decides is whether the type NAME comes out of a **class scope
that the property's own class body does not itself declare**; when it does,
Surelog's Signal binds no typespec and `makeVar_` ends in the same
`// default type (fallback)` arm `§ virtualIfacePropIsBareLogicVar6` already
transcribes. **This is that one fallback's third trigger, not a new object.**

Base **7d7c29f**. Worktree `/tmp/wt_r10uvm73`; pristine control worktree
`/tmp/wt_r10uvm73pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `7d7c29f8e338398562a1874552f3504b4820db1c`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 7d7c29f) | `ece9e9899d1089f7ebd56a8e55920d3f` | my own build of the base commit |
| **SHIPPED (patched)** | **`3b03bf98a78287b3cd7d5c1772a3e70e`** | every number below was measured on THIS binary |

**THE THIRD ANCHOR HOLDS THIS TIME.** The main tree's `build/slang-uhdm` at
`HEAD == 7d7c29f` md5s to `ece9e9899d1089f7ebd56a8e55920d3f` — the *same* md5 my
pristine worktree build produced. Two independent builds of the base commit
agree byte for byte, and both pristine sweeps reproduce the committed baseline
CSVs exactly (0 differing ROWS on 731 and on 1588).

BUILD DIRS (absolute): `/tmp/wt_r10uvm73/build`, `/tmp/wt_r10uvm73pris/build`,
both `-j 2`. `[100%] Linking CXX executable slang-uhdm` → `[100%] Built target
slang_uhdm` was read before any md5 was taken; every md5 was asserted in its own
command against `^[0-9a-f]{32}$`.

`git stash` was never used. `results/*.csv` were only ever READ (every baseline
quoted here is `git show 7d7c29f:results/…`). slang was not patched.
`GOLDEN_DEFER` was left **UNSET** and echoed as `[UNSET]` at every sweep launch.
The four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) were never dispatched — `canaudit.sh` proves it mechanically.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

---

## 0. THE LAW

### § classScopedTypedefPropIsBareLogicVar73

*A class **PROPERTY** whose DECLARED TYPE is a **typedef name whose home scope is
a CLASS** — reached either by a `::` class-scope qualifier or by INHERITANCE from
a base class — is a **BARE `logic_var` with NO `vpiTypespec` at all** in golden.
It keeps everything else the declaration says: name, fullname, class_defn
parent, the NAME's span, `vpiAutomatic`, `vpiVisibility`, `vpiConstantVariable`,
`vpiIsRandomized` + `vpiRandType`. Only the property's OWN class's typedef,
written UNQUALIFIED, escapes; a package / `$unit` typedef escapes however it is
written, including package-QUALIFIED (`p1::pkg_e_t`).*

*And, per `§ classPropNullInitParentedByTypespec2`'s own law ("having no
typespec is the gate"), the declaration INITIALIZER of a degraded property is
**parented by the CLASS_DEFN**, not by the variable, and its constant is sized
**64** — Surelog's typespec-less default — instead of the property's width.*

```
uvm-1.2 writes it three times, and all three are the head's family:
  seq/uvm_sequencer_base.svh:1771  uvm_sequencer_base::seq_req_t  request;   <- THE HEAD
  reg/uvm_mem_mam.svh:580          rand uvm_mem_mam::alloc_mode_e mode;
  reg/uvm_mem_mam.svh:584          rand uvm_mem_mam::locality_e   locality;
```

`seq_req_t` is declared at `uvm_sequencer_base.svh:43` — **inside class
`uvm_sequencer_base`, 1722 lines ABOVE the use, in the same file, in the same
package**. It is not a forward reference, it is not ambiguous, and slang
resolves it without complaint. Surelog's *variable-declaration* path simply does
not look in another class's typedef table.

### Where this sits

`§ virtualIfacePropIsBareLogicVar6` (r10svs6) transcribed golden's bare
`logic_var` for a `virtual <iface>` property. `§ classPropNullInitParentedByTypespec2`
(r10buvm2) found the SAME fallback from the initializer side and re-stated the
gate as *no typespec → no re-parent*, with `chandle` as its second trigger.
This pass adds the third trigger and, in doing so, makes buvm2's rule
**derivable rather than enumerated**: the three triggers are one Surelog
fallback chain, entered whenever no typespec binds to the Signal.

### STATED GATE == CODE GATE — read off the source, not the comment

ONE predicate, ONE `const bool`, EIGHT reads, in TWO files:

```bash
grep -c classScopedTypedefPropIsBareLogicVar73 src/EmitHelpers.h      # 1  (the law's name on the predicate)
grep -c classScopedTypedefPropIsBareLogicVar73 src/UhdmExporter.cpp   # 7  (all of them comments)
grep -c classScopedTypedefProp73               src/EmitHelpers.h      # 1  (the definition)
grep -c classScopedTypedefProp73               src/UhdmExporter.cpp   # 1  (the single call)
grep -c foreignTd73                            src/UhdmExporter.cpp   # 9  (decl + 8 reads)
```

The code gate is **exactly this, and nothing else** (`src/EmitHelpers.h`):

```cpp
inline bool classScopedTypedefProp73(const slang::ast::ClassPropertySymbol& cp,
                                     const slang::ast::Symbol& ownerCls) {
    const slang::ast::Type& dt = cp.getType();
    if (dt.kind != slang::ast::SymbolKind::TypeAlias)          // clause (1)
        return false;
    const slang::ast::Scope* home = dt.getParentScope();
    if (!home || home->asSymbol().kind != slang::ast::SymbolKind::ClassType)
        return false;                                          // clause (2)
    if (&home->asSymbol() != &ownerCls)                        // clause (3a)
        return true;
    if (auto* tsyn = cp.getDeclaredType()->getTypeSyntax())    // clause (3b)
        if (auto* nts = tsyn->as_if<syntax::NamedTypeSyntax>())
            return nts->name &&
                   nts->name->kind == syntax::SyntaxKind::ScopedName;
    return false;
}
```

* **Clause (1) is the WRITTEN type, not the canonical one.** `cp.getType()` is
  the declared type; a `holder h;` handle, a `logic [7:0] x;` and every
  DECLARATOR-formed array (`holder::e_t x[3]`, `x[]`, `x[$]`) are not typedef
  names and do not degrade — and they measurably must not (a1 `c_class_handle`,
  `c_qual_enum_arr`, `c_qual_enum_aa`; a5 `c_qual_dyn`, `c_qual_q`, all AGREE
  on both binaries). A typedef of a WHOLE array or queue **does** degrade
  (a5 `c_qual_arrtd`, `c_qual_qtd`), which is why the canonical kind is not the
  test and why the predicate is read AHEAD of the array arm.
* **Clause (2) is the HOME SCOPE, not the spelling.** Package and `$unit`
  typedefs never degrade — `pkg_e_t`, `pkg_s_t` and the package-QUALIFIED
  `p1::pkg_e_t` all keep their typespec in golden (a1).
* **Clause (3b) is the WRITTEN QUALIFIER, and it exists because of ONE measured
  cell.** Without it, `selfuser::s_e_t c_self_qual_enum;` — the class's own
  typedef, self-qualified — would keep its typespec and golden drops it. That
  cell is also the refutation of the brief's stated axis.
* **Nothing else in the property loop changed shape.** The five extra reads of
  `foreignTd73` are: the array-arm veto, the kind decode, the integer-literal
  initializer (size + parent), the negated-integer initializer (size + parent),
  the `= null` initializer (routed through r10buvm2's own helper by its FIRST
  argument, leaving that helper's body untouched), and the `ref_typespec` skip
  it now shares with `vifProp6`.

---

## 1. THE CENSUS, BOTH SIDES, SPAN-KEYED — RUN FIRST, BEFORE ANY CODE

`ct73cen.py` merges every print of every `*_var` / `*_net` object in a dump,
keyed on **(vpiFullName, line-span)** — the fullname carries package and class,
so it is a key where a bare span is not (a macro body's line numbers travel with
each expansion; that trap cost r10uvm72 a day). It records the merged KIND set
**and whether any print carried a direct `vpiTypespec`**, because a census that
tests kind alone reads a missing typespec as green.

### 1.1 SimpleUVM/default, design-wide, PRISTINE vs golden

| | golden (LHS) | ours (RHS) |
|---|---|---|
| variable/net objects | **6642** | **6221** |
| shared keys | 6172 | 6172 |
| LHS-only / RHS-only | 470 / 49 | — |
| **DISAGREEING shared keys** | **36** | |

The disagreements sort into exactly **eleven** shapes. **Only ONE of them is
this pass's**, and it has exactly **THREE** cells:

| # cells | LHS golden | RHS ours (pristine) |
|---|---|---|
| **3** | **`logic_var` ts=0** | **`enum_var` ts=1** ← THE HEAD'S FAMILY |
| 10 | `ref_var` | `class_var` |
| 6 | `class_var` | `ref_var` |
| 4 | `ref_var` | `struct_var` |
| 4 | `class_var` | `struct_var` |
| 2 | `ref_var` | `logic_var` |
| 2 | `ref_var` | `array_var\|ref_var` |
| 1 each | `int_var\|ref_var`, `array_var\|ref_var`, `struct_var`, `array_var\|class_var`, `enum_var\|ref_var` | … |

The three cells, named:

```
uvm_pkg::uvm_sequence_request::request   1771:34-1771:41   <- the head
uvm_pkg::uvm_mem_mam_cfg::mode            580:35-580:39
uvm_pkg::uvm_mem_mam_cfg::locality        584:35-584:43
```

**The census IS the reach statement.** SimpleUVM has three such properties and
no more; the ten `ref_var`/`class_var` shapes are function-RETURN-var families
(`§ retNameRecvCollapse69`'s neighbourhood), not this one.

### 1.2 The same census on the PATCHED binary

```
LHS(golden) objects=6642  RHS(ours) objects=6221
LHS-only=470 RHS-only=49 shared=6172
---- DISAGREEING SHARED KEYS: 33
```

**36 → 33, and the `logic_var / enum_var` row is GONE from the shape table.**
Object counts, LHS-only and RHS-only are **unchanged** — the patch changed three
objects' KIND and dropped three typespec edges; it created and destroyed
nothing. No new disagreement of any shape appeared.

### 1.3 What golden does with the rest of `uvm_sequence_request`

Read in full before any code, because it is the control that says the class is
otherwise perfectly emitted (golden, `uvm_sequencer_base.svh:1765-1773`):

| property | written type | golden |
|---|---|---|
| `grant` | `bit` | `bit_var` + `bit_typespec` |
| `sequence_id` | `int` | `int_var` + `int_typespec`, `vpiSigned:1` |
| `request_id` | `int` | `int_var` + `int_typespec` |
| `item_priority` | `int` | `int_var` + `int_typespec` |
| `process_id` | `process` | `class_var` + `class_typespec (process)` |
| **`request`** | **`uvm_sequencer_base::seq_req_t`** | **`logic_var`, NO typespec** |
| `sequence_ptr` | `uvm_sequence_base` | `class_var` + `class_typespec` |

`sequence_ptr` is the cell that kills the resolvability story on its own: its
type is a class declared in a **different file**, and golden binds it fine. The
only property Surelog loses is the one whose type lives inside another CLASS.

---

## 2. THE GRID, CELL FOR CELL

Five arms, 66 cells, every one measured on BOTH binaries against golden
(`ct73arm.sh` runs Surelog and slang-uhdm in one scratch dir; `ct73cells.sh`
prints, per cell, the merged object KIND and the ACTUAL typespec behind the
`ref_typespec`, or `NONE`).

### 2.1 arm a1 — the SCOPE axis (`a1_scoped.sv`), 23 cells

| cell | written declaration | golden | ours PRISTINE | ours FINAL |
|---|---|---|---|---|
| `c_qual_enum` | `holder::e_t p;` | **`logic_var` / NONE** | `enum_var` / `enum_typespec` | **=golden** |
| `c_qual_struct` | `holder::s_t p;` | `logic_var` / NONE | `bit_var` / `struct_typespec` | **=golden** |
| `c_qual_int` | `holder::i_t p;` | `logic_var` / NONE | `int_var` / `int_typespec` | **=golden** |
| `c_qual_vec` | `holder::v_t p;` | `logic_var` / NONE | `logic_var` / `logic_typespec` | **=golden** |
| `c_self_qual_enum` | `selfuser::s_e_t p;` **in `selfuser`** | `logic_var` / NONE | `enum_var` / `enum_typespec` | **=golden** |
| `c_inh_enum` | `e_t p;` in `derived extends holder` | `logic_var` / NONE | `enum_var` / `enum_typespec` | **=golden** |
| `c_inh_qual_enum` | `holder::e_t p;` in the derived class | `logic_var` / NONE | `enum_var` / `enum_typespec` | **=golden** |
| `c_unit_qual_enum` | `uholder::e_t p;` ($unit classes) | `logic_var` / NONE | `enum_var` / NONE | **=golden** |
| `c_own_enum` | `own_e_t p;` (own typedef, bare) | `enum_var` / `enum_typespec` | =golden | =golden |
| `c_self_enum` | `s_e_t p;` (own typedef, bare) | `enum_var` / `enum_typespec` | =golden | =golden |
| `c_pkg_enum` | `pkg_e_t p;` | `enum_var` / `enum_typespec` | =golden | =golden |
| `c_pkgqual_enum` | `p1::pkg_e_t p;` | `enum_var` / `enum_typespec` | =golden | =golden |
| `c_class_handle` | `holder p;` | `class_var` / `class_typespec` | =golden | =golden |
| `c_qual_enum_arr` | `holder::e_t p[3];` | `array_var` / `array_typespec` | =golden | =golden |
| `c_qual_enum_aa` | `holder::e_t p[string];` | `array_var` / `array_typespec` | =golden | =golden |
| `l_qual_enum` | `holder::e_t` **function LOCAL** | `enum_var` / `enum_typespec` | =golden | =golden |
| `l_qual_struct` | `holder::s_t` function local | `struct_var` / `struct_typespec` | =golden | =golden |
| `l_own_enum`, `l_pkg_enum` | function locals | full typespec | =golden | =golden |
| `a_qual_enum`, `a_own_enum`, `a_pkg_enum` | **FORMAL ARGUMENTS** | full typespec | =golden | =golden |
| `c_pkg_struct` | `pkg_s_t p;` (PACKED struct, package) | `struct_var` | `bit_var` | `bit_var` — **residue R3, pre-existing** |

`22 / 23 AGREE` after the patch (was 14/23). The one DISAGREE is R3 below and
predates this pass.

**The two cells that decide the law** are `c_self_qual_enum` (own class, own
typedef, `::`-written → degrades) against `c_self_enum` (same typedef, bare →
does not), and `c_inh_enum` (base's typedef, bare → degrades) against
`c_own_enum`. Together they say: *class scope that is not the property's own
declaring class, OR a written `::`*.

### 2.2 arm a2 — ALIASES, INHERITANCE DEPTH, PARAMETERISATION (`a2_alias.sv`)

| cell | written declaration | golden | ours FINAL |
|---|---|---|---|
| `c_grand_inh` | `b_e_t p;` — typedef **two** levels up | `logic_var` / NONE | **=golden** |
| `c_grand_qual` | `base2::b_e_t p;` two levels up, qualified | `logic_var` / NONE | **=golden** |
| `c_qual_handle` | `holder::self_t p;` (a CLASS-HANDLE typedef) | `logic_var` / NONE | **=golden** |
| `c_param_qual` | `pholder#(int)::g_e_t p;` | `logic_var` / NONE | **=golden** |
| `c_xpkg_qual` | `p1::holder::e_t p;` from package p2 | `logic_var` / NONE | **=golden** |
| `c_samepkg_qual` | `p2holder::q_e_t p;` same package | `logic_var` / NONE | **=golden** |
| `c_locloc` | `locloc_t p;` where the class itself does `typedef holder::e_t locloc_t;` | `enum_var` / `enum_typespec` | =golden |
| `c_fwd` | own typedef, declared before use | `enum_var` / `enum_typespec` | =golden |
| `c_pkgalias` | `pkgalias_t p;` where the PACKAGE does `typedef holder::e_t pkgalias_t;` | **`logic_var` / NONE** | `enum_var` — **residue R2** |

`c_locloc` against `c_pkgalias` is the arm's surprise and the reason R2 exists:
**a CLASS-scope alias of a class-qualified type resolves in golden; a
PACKAGE-scope alias of the very same type does not** — golden's own typespec for
`p1::pkgalias_t` is an `unsupported_typespec`, and the poison travels to every
property that names it.

### 2.3 arm a3 — HOW FAR THE POISON TRAVELS (`a3_chain.sv`)

| cell | chain | golden | ours FINAL |
|---|---|---|---|
| `c_pkgpkg` | pkg alias → pkg enum | `enum_var` / ts | =golden |
| `c_clsofcls` | CLASS alias → `holder::e_t` | `enum_var` / ts | =golden |
| `c_mod_qual` | `mholder::m_e_t` inside a **module-local** class | `logic_var` / NONE | **=golden** |
| `c_mod_own` | own typedef, module-local class | `enum_var` | =golden |
| `c_pkgcls` | pkg alias → `holder::e_t` | `logic_var` / NONE | `enum_var` — **R2** |
| `c_pkgpkgcls` | pkg alias → pkg alias → `holder::e_t` | `logic_var` / NONE | `enum_var` — **R2** |
| `c_clsofpkgcls` | CLASS alias → **poisoned pkg alias** | `logic_var` / NONE | `enum_var` — **R2** |

`c_clsofpkgcls` is the cell that says R2 is a **chain** property and not a
one-link one: a class-scope alias launders a direct `holder::e_t` (`c_clsofcls`)
but does **not** launder a poisoned package alias.

### 2.4 arm a4 — THE QUALIFIERS AND THE INITIALIZERS (`a4_qual.sv`), 20 cells

Every qualifier spelling over a class-qualified type degrades, and every one of
them keeps its own field: `c_plain`, `c_rand` (+`vpiIsRandomized`,
`vpiRandType:2`), `c_randc` (`:3`), `c_static` (no `vpiAutomatic`), `c_const`
(+`vpiConstantVariable:1`), `c_prot` (`vpiVisibility:2`), `c_local` (`:3`),
`c_str` (string typedef), `c_chand` (chandle typedef), `c_null`, `c_intinit`,
`c_neg` — **12/12 `logic_var` / NONE in golden, 12/12 `=golden` after the
patch**, against 8 CONTROL cells (`k_*`, the same qualifiers over the class's
OWN typedef) that are unchanged and equal on both sides.

The INITIALIZER halves, read at their own child depth:

| cell | golden constant | control | ours FINAL |
|---|---|---|---|
| `c_null` (`= null`) | `vpiSize 64`, parent = **class_defn** | `k_null`: parent = the VAR | **=golden** |
| `c_intinit` (`= 7`) | `vpiSize **64**`, parent = **class_defn** | `k_intinit`: size **32**, parent = the VAR | **=golden** |
| `c_const` (`= 3`) | size 64, parent = class_defn | `k_const`: 32 / VAR | **=golden** |
| `c_neg` (`= -1`) | `operation` parent = **class_defn**, operand size **64** | `k_neg`: operation parent = VAR, operand 32 | **=golden** |

This is `§ classPropNullInitParentedByTypespec2` seen on a third population,
exactly as that pass stated its gate ("having no typespec is the gate") — and it
extends the observation from `null` to the INTEGER and NEGATED-INTEGER
constants, which that pass had no degraded population to see.

### 2.5 arm a5 — WHICH EMISSION ARM (`a5_shape.sv`)

| cell | written declaration | golden | ours PRISTINE | ours FINAL |
|---|---|---|---|---|
| `c_qual_arrtd` | `holder::arr_t p;` (whole-array typedef) | `logic_var` / NONE | **no object at all** | **=golden** |
| `c_qual_qtd` | `holder::q_t p;` (whole-queue typedef) | `logic_var` / NONE | `array_var` / `array_typespec` | **=golden** |
| `c_qual_ustruct` | `holder::st_t p;` (UNPACKED struct) | `logic_var` / NONE | `struct_var` | **=golden** |
| `c_qual_pstruct` | `holder::sp_t p;` (PACKED struct) | `logic_var` / NONE | `bit_var` | **=golden** |
| `c_qual_dyn` | `holder::e_t p[];` | `array_var` | =golden | =golden |
| `c_qual_q` | `holder::e_t p[$];` | `array_var` | =golden | =golden |
| `p_pkgvar` | `holder::e_t v;` at **PACKAGE** scope | `logic_var` / NONE | `enum_var` / ts | `enum_var` — **residue R1** |
| `l_fnlocal` | `p1::holder::e_t` function local | `class_var` | =golden | =golden |

`c_qual_arrtd` is the cell that pays for reading the predicate ahead of every
arm: pristine emitted **nothing at all** for it (`noteUnsupportedAt`), so the
property was missing from `vpiVariables` and the whole class first-failed.

---

## 3. THE HEAD, before and after

PRISTINE (`ece9e989…`), all three rows, **50 lines / 1 head**:

```
LHS: logic_var: (uvm_pkg::uvm_sequence_request::request), line:1771:34, endln:1771:41
     |vpiParent: class_defn (uvm_pkg::uvm_sequence_request) @1765:1-1773:9
     |vpiName:request  |vpiFullName:…::request  |vpiAutomatic:1  |vpiVisibility:1
RHS: enum_var:  (uvm_pkg::uvm_sequence_request::request), line:1771:34, endln:1771:41
     |vpiTypespec: ref_typespec -> enum_typespec (seq_req_t) @43:3-45:42
     … same five fields …
```

FINAL (`3b03bf98…`), all three rows, **42 lines / 1 head**, byte-identical
across the three with ids normalised:

```
LHS: bit_select: (arb_sequence_q[i]) @554:32-554:46
       |vpiParent: hier_path (arb_sequence_q[i].request.name) @554:32-554:64
       |vpiName:arb_sequence_q  |vpiFullName:arb_sequence_q[i]
       |vpiIndex: ref_obj (…do_print::i) -> vpiActual int_var
RHS: ref_obj:    (arb_sequence_q[i]) @554:32-554:49
       |vpiParent: hier_path (…)   |vpiName:arb_sequence_q[i]
```

| row | pristine cmp lines / heads | final cmp lines / heads |
|---|---|---|
| `SimpleUVM` / default | 50 / 1 | **42 / 1** |
| `SimpleUVM` / testflags | 50 / 1 | **42 / 1** |
| `Scoreboard` / default | 50 / 1 | **42 / 1** |
| `Scoreboard` / testflags | `SLANG_REJECT`, no database (before and after) | — |

The new head is the **use site of the very property this pass fixed**
(`arb_sequence_q[i].request.name`, `uvm_sequencer_base::do_print` @554): golden
decomposes the `hier_path`'s first element into a `bit_select` with a
`vpiIndex`, we emit one `ref_obj` whose NAME is the text `arb_sequence_q[i]`.
That is the ranked residue R4 and the obvious next head.

---

## 4. THE FIVE GATES

### GATE 1 — BUILD

`cmake --build build -j 2` in `/tmp/wt_r10uvm73/build` →
`[100%] Linking CXX executable slang-uhdm` / `[100%] Built target slang_uhdm`,
read before any md5 was taken. Then, in a SEPARATE command:

```
PRISTINE=ece9e9899d1089f7ebd56a8e55920d3f
FINAL=3b03bf98a78287b3cd7d5c1772a3e70e
OK: BINARY md5 CHANGED ece9e9899d1089f7ebd56a8e55920d3f -> 3b03bf98a78287b3cd7d5c1772a3e70e
32-hex OK pris / 32-hex OK final
```

and the pristine build equals the MAIN TREE's binary at `HEAD == 7d7c29f`,
`ece9e9899d1089f7ebd56a8e55920d3f`, printed twice hours apart.

### GATE 2 — GOLDENS

`tests/check_goldens.sh` on the FINAL binary: **23 PASS / 0 FAIL**.
NEGATIVE CONTROL `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the control
fires.

### GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`

**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump column
**496 match / 183 differ / 52 blank**. WHOLE-ROW judge (`ct8rows.sh`) against
`git show 7d7c29f:results/gate_uhdm2rtlil.csv`:

```
baseline: 732 lines = 731 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

The PRISTINE sweep gives the **same 0 differing ROWS** — the control is anchored
on the corpus, not just on the binary.

### GATE 4 — surelog, `--mode both`, `--jobs 2`

`default` **469 CMP_EQUAL / 11 CMP_NOTEQUAL** / 5 DEFERRED / 284 SLANG_REJECT /
25 SURELOG_FAIL; `testflags` **465 CMP_EQUAL / 8 CMP_NOTEQUAL** / 5 DEFERRED /
286 SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE /
1 TIMEOUT / 1 NO_UHDM. Dump column 225 match / 244 differ (default), 165 match /
300 differ (testflags). Every figure equals the expected one and **both
histograms are unchanged**. WHOLE-ROW judge against
`git show 7d7c29f:results/golden_surelog.csv`:

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

The PRISTINE sweep is **also 0 differing ROWS**. `GOLDEN_DEFER` was left UNSET:
the 5 memory-giant tests read `DEFERRED` in both modes, exactly as the baseline
does.

### GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs the PRISTINE 7d7c29f workdirs I built

`SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched-wd> <pristine-wd>`:

```
surelog / both modes:
  databases: patched=953 pristine=953
  PATH_SETS_IDENTICAL (953 paths)
  MOVER ./default/BuildUVMPkg  ./default/Scoreboard  ./default/SeqDriver  ./default/SimpleUVM
  MOVER ./testflags/BuildUVMPkg  ./testflags/SeqDriver  ./testflags/SimpleUVM
  MOVERS: 7 / 953
  SELFCHECK: 952 / 953 flagged        SELFCHECK1: 8

uhdm2rtlil / testflags:
  databases: patched=679 pristine=679
  PATH_SETS_IDENTICAL (679 paths)
  MOVERS: 0 / 679
  SELFCHECK: 678 / 679 flagged        SELFCHECK1: 1
```

Both negative controls fire on both corpora (`SELFCHECK1`'s 8 = the 7 real
movers plus the one corrupted file; the u2r 1 = the corrupted file alone).
**NOT ONE `CMP_EQUAL` DATABASE MOVED A BYTE, IN EITHER CORPUS.** The 7 that
changed are the 4 UVM tests x modes, all `CMP_NOTEQUAL` before and after
(`Scoreboard/testflags` is `SLANG_REJECT` and has no database). There is
therefore no room for a silent regression inside the 183 + 244 + 300 rows whose
dump column reads `differ`.

### 4.5 MOVERS, PREDICTED FIRST

`ct73predict.py` reads the PRISTINE workdirs alone. The law is decided by
SOURCE SYNTAX, so the predictor reads the SOURCES each pristine database names
(every `file:` path in its own dump) and flags any `X::y name;` declaration.
Its error direction is stated in its header and here: it is an **UPPER bound**
on the `::`-written half (it cannot tell a class body from a module body, nor a
class prefix from a package one) and a **LOWER bound** on the
inherited-unqualified half (a bare name gives it nothing to key on).

* **surelog PREDICTION: 46 databases / 953 CAN move, `DUMP_FAIL=0`**, written to
  `/tmp/r10uvm73_predict_sl.txt` at 18:00 — **before** `byteverify.sh` was run
  on that corpus. **The sweep produced 7, and all 7 are inside the 46**:
  `default/{SimpleUVM, Scoreboard, SeqDriver, BuildUVMPkg}` and
  `testflags/{SimpleUVM, SeqDriver, BuildUVMPkg}`. The 39 predicted-but-still
  are the upper bound's expected slack — every one of them writes only
  PACKAGE-qualified (`pkg::t x;`) or FUNCTION-LOCAL `::` declarations, and the
  grid says neither moves (a1 `c_pkgqual_enum`, `l_qual_enum`).
* **uhdm2rtlil PREDICTION: 19 databases / 679, `DUMP_FAIL=0`.** **The sweep
  produced 0.** All 19 sites are module/interface-scope package-qualified
  declarations (`keymgr_pkg::hw_key_req_t keymgr_key_i;`, `p::req_t req;`,
  `my_pkg::word w = 8'h5C;` …) — not one uhdm2rtlil design declares a class
  PROPERTY with a class-scope-qualified type.
* **No mover fell OUTSIDE the prediction**, so the lower-bound half never had to
  be invoked: the corpus's degraded properties are all `::`-written.

### 4.6 MOVERS PER-SHAPE, BY MULTISET

`mv73.sh` sorts whitespace-stripped dump lines and diffs the MULTISETS, because
a positional `diff` reports re-indentation as change. **All seven movers have
the SAME shape**, and the size delta is NONZERO on every one (the rule's
own requirement — a zero delta would prove nothing):

```
./default/BuildUVMPkg    REMOVED=24 ADDED=3   size 11097846 -> 11097669  (delta -177)
./default/Scoreboard     REMOVED=24 ADDED=3   size 11123420 -> 11123248  (delta -172)
./default/SeqDriver      REMOVED=24 ADDED=3   size 17962880 -> 17962716  (delta -164)
./default/SimpleUVM      REMOVED=24 ADDED=3   size 11119038 -> 11118874  (delta -164)
./testflags/BuildUVMPkg  REMOVED=24 ADDED=3   size 11097846 -> 11097669  (delta -177)
./testflags/SeqDriver    REMOVED=24 ADDED=3   size 17963307 -> 17963133  (delta -174)
./testflags/SimpleUVM    REMOVED=24 ADDED=3   size 11119350 -> 11119186  (delta -164)
```

and the accounting CLOSES exactly, per database (SimpleUVM shown; the other six
differ only in line numbers, BuildUVMPkg's being the precompiled `uvm_pkg.sv`'s
70509 / 70505 / 53674):

```
removed (24):  3x |vpiTypespec:   3x |vpiParent:   3x |vpiActual:   3x \_ref_typespec:
               2x \_enum_var: 584:35   2x \_enum_var: 580:35   2x \_enum_var: 1771:34
               1x |vpiFullName:uvm_pkg::uvm_sequence_request::request
               1x |vpiFullName:uvm_pkg::uvm_mem_mam_cfg::mode
               1x |vpiFullName:uvm_pkg::uvm_mem_mam_cfg::locality
               1x \_enum_typespec: 93:4   1x \_enum_typespec: 81:4   1x \_enum_typespec: 43:3
added (3):     1x \_logic_var: 584:35   1x \_logic_var: 580:35   1x \_logic_var: 1771:34
```

**THREE objects per database, the three the census named, and nothing else.**
The `enum_var` lines are removed TWICE and the `logic_var` added ONCE because
the pristine object was printed once as itself and once as its own
`ref_typespec`'s `vpiParent` — the edge that is now gone. The three
`enum_typespec` lines are the shared typedef typespecs losing their last
referrer in this listing; the typespec OBJECTS themselves are untouched (they
still appear in the class's `vpiTypedef` listing — that is why only the
`ref_typespec` chain is in the removed set).

### 4.7 THE OTHER TWO ROWS ADVANCED TOO

`rowheads.sh` on all four UVM names, both sweeps:

| row | pristine cmp lines | final cmp lines |
|---|---|---|
| `SimpleUVM` default / testflags | 50 / 50 | **42 / 42** |
| `Scoreboard` default | 50 | **42** |
| `SeqDriver` default / testflags | 1416183 / 1416183 | **1416141 / 1416141** |
| `BuildUVMPkg` default / testflags | 1368017 / 1368017 | **1367975 / 1367975** |

Every one is **-42 lines**, the same three objects' worth, and no row grew.

---

## 5. RESIDUES, RANKED

**R1 — a PACKAGE (or `$unit`) VARIABLE with a class-scope-qualified type
degrades in golden too, and we do not follow.** Arm a5 cell `p_pkgvar`
(`holder::e_t v;` at package scope): golden `logic_var` / NONE, ours `enum_var`
+ `enum_typespec`. Same law, different EMISSION SITE (`TypeEmit.cpp`'s
package/module variable factory, not `emitClassDefn`), with its own canary
surface — and **zero corpus witnesses**: neither corpus moved a non-UVM
database, and the surelog predictor's 46 candidates contain no package-scope
class-qualified declaration. Deliberately out of scope for a ONE-HEAD pass;
this is the first thing to do next if a witness appears. One predicate, already
written, plus one call site.

**R2 — the POISONED PACKAGE ALIAS, and it is TWO objects, not one.** A
package-scope `typedef holder::e_t pkgalias_t;` is an **`unsupported_typespec`**
in golden (`a2` g.dump line 69), and every property that names it — or names a
package alias of it, or even a CLASS-scope alias of it — degrades exactly like a
directly-qualified one (a2 `c_pkgalias`; a3 `c_pkgcls`, `c_pkgpkgcls`,
`c_clsofpkgcls`). We emit a full `enum_typespec` for the package typedef itself,
so fixing only the property half would leave the wrong typespec object in the
package's `vpiTypedef` listing and move the head one field along. The package
half is the prerequisite and it is a different family (typedef compile, not
variable emission). No corpus witness: uvm-1.2 writes no such alias.

**R3 — a PACKED-struct property typed by a PACKAGE typedef is `struct_var` in
golden and `bit_var` in ours.** PRE-EXISTING, not touched by this pass (a1 cell
`c_pkg_struct`, identical before and after). It has a corpus witness — the
design-wide census's `uvm_reg_map_info::mem_range` @29:27, the single
`LHS struct_var / RHS bit_var` cell — so it is the one residue here with a real
UVM reach.

**R4 — THE NEW HEAD, and it is the obvious next pass.** `hier_path
(arb_sequence_q[i].request.name)` @554:32 in `uvm_sequencer_base::do_print`:
golden's FIRST element is a `bit_select (arb_sequence_q[i])` carrying a
`vpiIndex` -> `ref_obj` -> `vpiActual int_var`; ours is a single `ref_obj` whose
`vpiName` is the literal text `arb_sequence_q[i]` and whose span runs to 554:49
instead of 554:46. Three rows, 42 lines each, one shared object shape. It is the
USE site of the very property this pass fixed.

**R5 — our negated-integer initializer constant carries a `vpiParent` golden
omits.** Visible in a4's remaining dump diff on BOTH the degraded cell (`c_neg`)
and its control (`k_neg`), i.e. PRE-EXISTING and orthogonal to this law: golden
prints the `vpiMinusOp` operand constant with no parent edge at all, we point it
back at the operation. One line in `emitClassDefn`; left alone here because it
belongs to `§ classPropInit29`'s family, not this one.

**R6 — the 33 remaining design-wide census disagreements** in SimpleUVM, in rank
order of cell count: `ref_var`/`class_var` (10), `class_var`/`ref_var` (6),
`ref_var`/`struct_var` (4), `class_var`/`struct_var` (4), and seven singletons.
All but ONE are FUNCTION-RETURN or FUNCTION-LOCAL variables
(`§ retNameRecvCollapse69`'s neighbourhood); the single class PROPERTY left in
the list is `uvm_reg_map_info::mem_range` @29:27, which is R3's witness and not
this law. This pass's own family is EMPTY: no `logic_var`-vs-anything cell
remains.

---

## 6. THE CANARIES

| guard | result |
|---|---|
| `canaries.sh` surelog | **ok=52 changed=0 absent=0**, unknown-names=7 (the u2r-only names, the documented number) |
| `canaries.sh` uhdm2rtlil | **ok=8 changed=0 absent=0**, unknown-names=25 (the surelog-only names) |
| `ctcan2.sh` surelog, `EXPECT_UNKNOWN=1`, baseline FIRST | **ok=58 changed=0 absent=0**, unknown-patterns=**1** — PASS |
| `ctcan2.sh` uhdm2rtlil, `EXPECT_UNKNOWN=6`, baseline FIRST | **ok=1 changed=0 absent=0**, unknown-patterns=**6** — PASS |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** — PASS |
| `InterfaceModPort` BY NAME | `default` + `testflags` both `CMP_EQUAL/differ`, byte-identical to baseline |
| `BlackParrotComplex` BY NAME | `default` + `testflags` both `CMP_EQUAL/differ`, byte-identical to baseline |

**BOUNDARIES, each checked against the named pass's own README before coding.**

* **`§ implicitRetSigningIsIntVar70`** owns implicit-signing RETURN vars. Its
  population is `makeReturnVar`'s object in `TaskFuncEmit.cpp`; this pass writes
  only `emitClassDefn`'s property loop and never a return var. Arm a1's
  `l_*` / `a_*` cells are the measured negative control: a FUNCTION LOCAL and a
  FORMAL ARGUMENT of the identical class-qualified type are byte-identical to
  golden before and after.
* **`§ atomVarSignedWritten68`** owns `vpiSigned` suppression on NAMED atom
  types. This patch writes no `VpiSigned` anywhere. A degraded property has no
  typespec to carry signedness, and golden prints none on it (a4 `c_randc`,
  `c_const`, `c_intinit` — all `int`-typed, none signed on either side).
* **`§ classPropTimeLitInit2` / `§ classPropNullInitParentedByTypespec2`
  (r10buvm2)** own class-property INITIALIZERS, and its README's R2/R6 were read
  FIRST as the brief required. **Its re-scoped law — "no typespec -> no
  re-parent" — is confirmed on a third population here** and extended from
  `null` to the integer and negated-integer constants (a4 `c_intinit`,
  `c_const`, `c_neg`). Its helper `nullInitDefnParented2` is called with an
  OR'd first argument and its BODY IS UNTOUCHED, so the two passes cannot
  drift. **One nuance for its R6**, measured here and worth its residue: golden's
  typespec-less objects are NOT all one kind — a plain `chandle p;` is a
  `chandle_var` with no typespec (buvm2's cell) while a class-qualified chandle
  TYPEDEF (`holder::ch_t p;`, a4 `c_chand`) is a `logic_var` with no typespec.
  "No typespec" is the shared gate; the KIND still comes from whichever
  fallback branch Surelog entered.
* **uvm68's V3 enum_var law** ("golden enum_var NAMED is 126/126 unstamped") is
  untouched: this pass does not stamp or unstamp anything on an `enum_var`, it
  removes three enum_vars from existence and puts `logic_var`s there. The
  census confirms no other `enum_var` changed (36 -> 33 disagreements, and the
  `enum_var|ref_var` singleton is unchanged).
* **Live passes**: `r10sd4` (package wall) and `r10earl44` (scoped conn actual).
  Neither touches `UhdmExporter.cpp`'s class-property loop or `EmitHelpers.h`'s
  tail; **no collision seen, and the possibility is reported rather than assumed
  away** — if `r10sd4` edits the package-typedef compile it will meet residue R2
  head-on, which is worth knowing.

**LANDING HYGIENE.** No `README.verifier.md` is carried forward — that file is
the VERIFIER's to author, and this directory deliberately contains none. Every
script here was RUN in this pass. No instrumentation was left in the shipped
binary: the diff is 2 production files, 4 hunks plus one file-local predicate.

---

## 8. REFUTATIONS, stated plainly

1. **The brief's axis is REFUTED.** "Surelog cannot resolve the type name from
   `uvm_sequence_request`'s scope … the axis is TYPE-NAME RESOLVABILITY
   (cross-class unqualified typedef)." Cell `c_self_qual_enum` degrades with
   NOTHING to resolve across any boundary (own class, own typedef, only a `::`
   written), and cell `c_locloc` does NOT degrade even though its typedef's RHS
   is the very cross-class name the brief blamed. Resolvability is not the axis;
   the type name's HOME SCOPE plus the written qualifier is.
2. **Enum-ness is REFUTED as the carrier**, and this matters because the head's
   object was an `enum_var`. `holder::s_t` (packed struct), `holder::i_t`
   (`int`), `holder::v_t` (`logic [7:0]`), `holder::s_t` (string),
   `holder::ch_t` (chandle), `holder::self_t` (CLASS HANDLE), `holder::st_t`
   (unpacked struct), `holder::arr_t` (whole array) and `holder::q_t` (whole
   queue) all degrade to the SAME bare `logic_var`.
3. **"Forward reference / single-pass compile order" is REFUTED.** `seq_req_t`
   is declared 1722 lines ABOVE its use IN THE SAME FILE (line 43 vs 1771), and
   `alloc_mode_e` 499 lines above (81 vs 580). Cell `c_fwd` shows golden
   handling a genuine forward use of an own-class typedef with a full typespec.
4. **The brief's guess at the SPELLING was wrong.** It expected "a class-scoped
   typedef referenced from a DIFFERENT class UNQUALIFIED". uvm-1.2 writes
   `uvm_sequencer_base::seq_req_t` — fully QUALIFIED. (The unqualified-inherited
   form degrades too, cell `c_inh_enum`, but it is not what the corpus writes.)
5. **A PRESENT typespec is not a CORRECT one, and a census that tests only KIND
   is blind.** `ct73cen.py` records typespec PRESENCE alongside the kind set for
   exactly this reason; with kind alone, the three head cells would still have
   been found, but the `ts=0|1` column is what proves the patched run added no
   new typespec-only divergence anywhere in 6172 shared keys.
6. **A predictor that cannot be wrong is not a control.** `ct73predict.py`'s
   first draft read the DUMP's indentation as containment — but uhdm-dump prints
   `vpiParent` chains UPWARD, so indentation is not nesting, and it reported 54
   phantom cells for SimpleUVM (every PACKAGE typedef read as a class one).
   It was rewritten to read SOURCES instead, and its two error directions are
   stated in its own header rather than discovered later.

---

## 7. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm73repro
# the grid, either binary (each arm runs Surelog + slang-uhdm in its own scratch)
SLANG_UHDM=<bin> ./ct73arm.sh a1_scoped.sv /tmp/x_a1
./ct73cells.sh /tmp/x_a1 c_qual_enum c_own_enum c_self_qual_enum c_inh_enum …

# the design-wide census, span-keyed, ONE dump per side
python3 ct73cen.py <golden.dump> <ours.dump> --diff

# the mover PREDICTION, from a PRISTINE workdir, before the patched sweep
python3 ct73predict.py <pristine verify_golden workdir>

# the head on the target rows
./rowheads.sh <verify_golden workdir> <outdir> SimpleUVM Scoreboard
```
