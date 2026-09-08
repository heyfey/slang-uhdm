# r10uvm220 — § uninstIfaceForeachHdrUnresolved220

**A `foreach` header inside an UNINSTANTIATED interface's subroutine keeps
Surelog's placeholder — the iterated-array reference AND every loop variable.**

MiniAmiq's head, both row-modes, 20 cmp lines / 1 head at `dad0ad27`:

```
LHS:  unsupported_typespec: (a_lof_sva)                        line 198:15-198:24
RHS:  class_typespec: (svaunit_concurrent_assertion_info)      line 196:45-196:78
```

196:45 is the FORMAL's own declaration
(`svaunit_concurrent_assertion_info a_lof_sva[]`, svaunit_vpi_interface.sv:196);
198:15 is the `foreach (a_lof_sva[index])` header one line down. After the
patch the head is 19 lines and a different family (see R0).

---

## 1. THE LAW

Surelog's `paFOREACH` arm ALWAYS mints a placeholder first and defers the
answer:

* the iterated ARRAY IDENTIFIER goes to `compileVariable`
  (CompileStmt.cpp:529), which compiles the NAME AS IF IT WERE A TYPE
  (CompileType.cpp:317-330), misses every lookup, falls out as an
  `unsupported_typespec` NAMED AS WRITTEN at the identifier's own span
  (CompileType.cpp:1617-1626), is wrapped in a `ref_var` and registered with
  `needLateTypedefBinding` (CompileType.cpp:420-432);
* every LOOP VARIABLE is minted as `ref_var` + `unsupported_typespec` named for
  the index, unconditionally, with no lookup at all (CompileStmt.cpp:549-557).

What normally replaces both is `UhdmWriter::lateTypedefBinding`
(UhdmWriter.cpp:2573), which reads the io_decl / local / member / parameter the
name denotes (:2637-2692) and, for the loop variable, `swapForSpecifiedVar`
(:2490).

**And `UhdmWriter::writeInterface` (UhdmWriter.cpp:1626-1794) never calls it.**
The complete caller list is `writePackage` (:1302), `writeElabProgram` (:2071),
`writeInstance` (:4784, :4786) and the two `$unit` FileContent passes (:4912,
:4991) — `writeClass`'s pair is commented out at :1066-1067, which is why
§ classMethodNoBind exists. An interface no instance elaborates reaches none of
them, so the placeholders survive into `uhdmallInterfaces`, its only listing.

This is the same producer fact § uninstIfaceBodyBindsInMethodWindow218 decoded
one pass over for `lateBinding`, so the law rides that pass's flag,
`uninstIfaceSubBody218` — true for exactly the `emitTaskFuncs` call
ModuleEmit.cpp:28627-28652 makes for an interface definition with
`defAllInstCount[&def] == 0`, false everywhere else.

`DECODE.r10uvm220.txt` carries the full read, line by line.

### The two fences, both decoded and both measured

* **PARAMETER (the ARRAY half only).** Before `compileDatastructureTypespec`
  can fall out at :1617 it scans `getParamAssignVec()` for a parameter of this
  name and returns its own `Actual_typespec` (CompileType.cpp:750-762) — at
  COMPILE time, so an iterated parameter never reaches the placeholder tail in
  any holder. Arm a1's `PAR220`: golden's array reference is the real
  `array_typespec` while its loop variable `i5` is still the placeholder, which
  is why the LOOP-VARIABLE half carries no parameter fence. Same fence,
  same lines, as § cloneForeachArrayRefUnresolved183.
* **TYPE NAME (the ARRAY half only).** When the iterated identifier's name is
  ALSO a visible type name, `compileVariable`'s FIRST lookup succeeds
  (`component->getDataType(typeName)`, CompileType.cpp:339-355) and golden
  answers an `array_var` over that typedef's own `array_typespec` — no
  placeholder is minted. Arm a6's `g220(input int t220[4])` under
  `typedef int t220[4]`. ZERO corpus cells, so the fence costs nothing and is
  written to keep the law from degrading a cell golden RESOLVES.

A DOTTED iterated reference (`h220.q220[i]`) is a `hier_path` and never reaches
this code (`arrMember9`); a `::`-scoped one is answered first by
§ foreachScopedArrayWrittenClassVar33. Their LOOP VARIABLES do take the law —
golden gives every one of them the placeholder (arm a6).

---

## 2. THE CHANGE

`src/StmtEmit.cpp`, three terms, all under `uninstIfaceSubBody218`:

* `uninstIfaceArrUnres220` joins `foreachUnres9` (the ARRAY half, with both
  fences);
* the loop-variable "already resolves in the enclosing scope" arm is skipped;
* `uninstIfaceSubBody218` joins the loop-variable PLACEHOLDER arm's gate.

No new object kind, no new pass, no signature change. The flag is false
everywhere outside one `emitTaskFuncs` call, so every term is inert elsewhere —
which arms a2/a3/a4/a5 confirm byte for byte.

---

## 3. THE MEASUREMENTS

**The head.** 20 lines / 1 head -> 19 lines / 1 head, MiniAmiq, both modes,
the two cmp logs byte-identical on each binary.

**The population** (POPULATION.r10uvm220.txt): 38 cells, all in one holder
(`interface_inst work@svaunit_vpi_interface`) and one view
(`uhdmallInterfaces` — an uninstantiated interface has no second listing):
19 iterated-array references (1 FORMAL of an unsized dynamic array of a class
handle, 18 INTERFACE MEMBERS) and their 19 loop variables. All 38 convert; the
census leaves ZERO cells in that holder.

**The sharing, by identity.** Golden mints ONE placeholder PER SITE:
`report_for_sva` iterates `sva_info` three times (592:15, 602:15, 613:15) and
carries three distinct objects; arm a6 pins the same fact with one formal
iterated twice. Our arms are per-site mints, so the identity structure matches
by construction. Pristine we SHARED — one io_decl `class_typespec` for the
formal, the element `class_typespec` for all eighteen members.

**The golden grid** (GRID.r10uvm220.txt, grid220.sh, LISTED=6 PROCESSED=6
FAILED=0 on both binaries, every arm's rc checked, both golden views):

| arm | what it is | pristine | patched |
|---|---|---|---|
| a1_uninst_if | uninstantiated interface — MiniAmiq's shape | SAME=0/16 | **SAME=13/16** |
| a2_inst_if | THE SAME BODY, instantiated | SAME=12 | SAME=12, 0 dump lines changed |
| a3_mod | a module (always elaborated) | SAME=10 | SAME=10, 0 dump lines changed |
| a4_prog | uninstantiated + instantiated PROGRAM | SAME=5 | SAME=5, 0 dump lines changed |
| a5_pkg | package function + in-body class method | SAME=21 | SAME=21, 0 dump lines changed |
| a6_kinds | the fence arm inside an uninstantiated interface | SAME=1/12 | **SAME=10/12** |

The PARSE and ELAB golden censuses are identical cell for cell on every arm,
which is why the law is written view-independent.

**The prediction** (PREDICT.r10uvm220.txt), written and run from PRISTINE
databases and sources alone, BEFORE the patched binary touched either corpus:
*surelog exactly two movers, MiniAmiq/default and MiniAmiq/testflags;
uhdm2rtlil zero of 1358; 38 cells per mode; no row-status conversion claimed.*
The sweep found exactly that.

**The gates**: GATES.r10uvm220.txt. All green — 23/0 goldens with the negative
control at 23, 0 differing rows over 1588 + 731 + 731, MOVERS 2/956 and 0/1358
both predicted, canaries 52/8/PASS/PASS, canaudit 29/0/0, every protected
database byte-identical (`InterfaceModPort` included — it is an interface test
and its interface is INSTANTIATED), and the 5513-arm wide boundary with 18
moved arm-views all re-scored TOWARD-GOLDEN, 0 AWAY, 0 broken cells.

---

## 4. FILES

| file | what it is |
|---|---|
| `cen220.py` | THE SCORER — every `foreach_stmt`'s iterated reference and loop variable, keyed (view, role, name, span) as a MULTISET, valued by ref kind + typespec kind + typespec name + typespec span. |
| `grid220.sh`, `grid220/`, `GRID.r10uvm220.txt` | question (3): six arms x two golden views x both binaries, every rc checked. |
| `DECODE.r10uvm220.txt` | question (4): the producer, read `file:line`. |
| `POPULATION.r10uvm220.txt` | question (2): the holder chain, the population by kind x holder x view, and the sharing by identity. |
| `predict220.sh`, `PREDICT.r10uvm220.txt` | question (5): written and run before the patched sweep. |
| `CENSUS.pristine.MiniAmiq.*`, `CENSUS.patched.MiniAmiq.*`, `CENSUS.moved-cells.*`, `CENSUS.MiniAmiq.wholedump.diff.txt` | the corpus census on both binaries, the 38 moved cells with golden's value beside each, and the whole-dump proof that nothing else in 1.89M lines moved. |
| `bound220.sh`, `BOUNDARY.r10uvm220.txt`, `armscore220.sh`, `ARMSCORE.r10uvm220.txt` | question (6): the 5513-arm wide boundary and the against-golden re-score of every mover. |
| `GATES.r10uvm220.txt` | every gate number, both binaries. |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the head on both binaries, both modes. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged from their canonical homes. |

---

## 5. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD IS uvm218's R4, NOW SURFACED.** 19 lines, one
  head, both row-modes, the two logs byte-identical. `LHS: <null>` against our
  `enum_const (SVAUNIT_START)` bound as the `Actual_group` of
  `ref_obj work@svaunit_vpi_interface.get_state_from_reason.SVAUNIT_START`
  @`svaunit_vpi_interface.sv:155:20`. We MINT an enum-const actual the
  uninstantiated interface's golden does not have — uvm218 measured sixteen
  such cells in this holder and one in each of its arms a1/a2, called it
  "pre-existing on both binaries, EXACTLY unchanged", and deliberately left it
  because removing it is a separate law with its own grid. It is now the head.
  `head_pat_MiniAmiq.default.cmp` carries it.
* **R1 — AN UNINSTANTIATED PROGRAM IS THE SAME LAW AND WE DO NOT TAKE IT.**
  Arm a4 measures it directly: golden's `pr220u` (uninstantiated) keeps the
  placeholder on all three of its `foreach` headers in BOTH views while
  `pr220i` (instantiated) resolves all three, and our answer is unchanged on
  both binaries. `writeProgram` (UhdmWriter.cpp:1795-1900) has no late pass and
  `writeElabProgram` (:2071-2072) has both — the exact interface/instance
  split. This is uvm218's R2 in the typespec column: the emitter has no
  "uninstantiated program" flag to ride, so lifting it means raising one, which
  is its own landing. 0 corpus cells (the prediction's stage 1 found no
  candidate outside `svaunit_vpi_interface`).
* **R2 — AN UNINSTANTIATED INTERFACE'S `initial` BLOCK IS NOT EMITTED AT ALL.**
  Arm a1's `s18` (`foreach (mvar220[k0])` in an `initial` block, 37:16 and
  37:24): golden carries both cells as placeholders and our dump carries no
  cell there in either binary — the statement is missing, not mistyped. Out of
  this law's reach by construction (`uninstIfaceSubBody218` is raised only for
  the `emitTaskFuncs` call), and a different family: a missing body, not a
  typespec.
* **R3 — THE FENCED PARAMETER'S `array_typespec` HAS NO SPAN AND NO RANGES.**
  Arm a1's `PAR220`: golden `array_typespec @13:14`, ours `array_typespec` with
  no line at all. Both sides are the same KIND, so the judge (which reads no
  line or column) is indifferent, and the fence did its job — the cell stayed
  RESOLVED. Pre-existing, unchanged pristine to patched.
* **R4 — A FORMAL THAT SHADOWS A TYPEDEF IS A `class`/`array_var` IN GOLDEN AND
  A `ref_var` IN OURS.** Arm a6's `g220(input int t220[4])` under
  `typedef int t220[4]`: golden `array_var` over the typedef's own
  `array_typespec 't220'`, ours `ref_var` over the io_decl's `int_typespec`.
  The VARIABLE kind already differed pristine, which is exactly why the
  type-name fence is written — without it this pass would have replaced a
  resolved typespec with a placeholder under a variable that is wrong anyway.
  Unchanged on both binaries; lifting it is `getSimpleVarFromTypespec`'s arm,
  a different law.
* **R5 — OUR DOTTED ITERATED REFERENCE CARRIES A SPAN GOLDEN'S DOES NOT.**
  Arm a6's `h220.q220`: both sides emit a `hier_path` with no typespec, ours
  spanned at 38:16 and golden's with no line. Judge-invisible, pre-existing,
  unchanged.
