# r10uvm83 — § scopedTdUnsupTsHomePkgInstance83 — **THE WALL CAME DOWN**

**MEASUREMENT-ONLY.**  Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here.  slang was NOT patched;
`results/*.csv` were READ ONLY.

## The headline

The official `uhdm-cmp` head of the five big UVM NE rows — unmoved for thirty
passes, printing 1.4 MILLION lines of `package uvm_pkg` with `RHS: <null>` — was
**one null pointer**:

| row (both modes where they exist) | cmp lines BEFORE | AFTER |
|---|---|---|
| SeqDriver default / testflags | 1450011 | **54** |
| SimpleUVM default / testflags | 1405511 | **54** |
| Scoreboard default            | 1399779 | **54** |
| BuildUVMPkg default / testflags | 19 | 19 (head unmoved; 2 objects still moved) |

Still `CMP_NOTEQUAL` — nothing was promoted — but the head is now a 54-line
object instead of a 1.4-million-line container, and it is the object the ladder
already predicted would be next.

## The law

> The `unsupported_typespec` PLACEHOLDER that a declaration written `Owner::td`
> (`Owner` a CLASS) binds — § `classScopedTdDeclTsUnsupported11`'s object —
> carries the SAME `vpiInstance` the RESOLVED typespec of that very declaration
> carries: the **home package** for an OUT-OF-BODY class method, **nothing** for
> an in-body one.  The placeholder substitution threw that stamp away.

`typespec::Compare` reads `Instance`, so the discarded pointer was a compared
field.  Both call sites already computed the pointer for the resolved typespec
one screen earlier (`tsInst` in `src/TaskFuncEmit.cpp`, `pkgScopeInst` in
`src/StmtEmit.cpp`) and both are NULL for an in-body method — so the fix is the
pointer itself and introduces **no new predicate**.  Six lines of logic:

```
  StmtEmit.cpp   (SITE 2, block-item local)   if (pkgScopeInst) uts11->Instance(pkgScopeInst);
  TaskFuncEmit.cpp (SITE 1, subroutine-body)  if (tsInst) { uts11->Instance(importCopyTsInst ? importCopyTsInst : tsInst);
                                                            if (importCopyTsInst && importCopyTsCollect)
                                                                importCopyTsCollect->push_back(uts11); }
```

Neither site is redundant, and that is measured rather than assumed: the UVM
rows' `rq` is parented at a synthetic `begin` and takes **SITE 2**, while
grid11 `g4`'s `o_scoped` is parented at the function and takes **SITE 1**
(CENSUS Part 6).

## Why it hid for thirty passes — two mechanisms, both worth keeping

1. **`SafeCompare(lhs, rhs == nullptr)` sets `m_failedLhs` to the TARGET of the
   edge and never touches `m_failedRhs`.**  The head therefore printed as the
   thing being POINTED AT (golden's elaborated `package uvm_pkg`) and said
   nothing about the OWNER of the pointer, 115 levels away.  Every reading of
   this head — including this pass's own brief — attributed the defect to the
   package's own vectors, and the package's vectors are all identical
   (CENSUS Part 0).
2. **The visitor prints a REFERENCED object as one identity line and none of
   its own fields.**  Inside the old 1,450,011-line head this very placeholder
   appears as

   ```
   \_unsupported_typespec: (uvm_resource_types::rsrc_q_t), id:25354, line:1434:3, endln:1434:23
   ```

   and nothing else — which is *literally* the "prints one line" that the
   comment in `src/TypeEmit.cpp` cited when it concluded golden's placeholder
   "carries a vpiName and a span and NOTHING else ... no vpiInstance".  The SAME
   object decompiled **as a root** does print `|vpiInstance:` and the package
   under it (measured on golden `#25349` / `#25354`).  So the leaf form is
   *silent* about the field, not evidence against it — and a head whose LHS is a
   big container shows every interesting object in exactly that silent form.
   That sentence is now corrected in place with this mechanism spelled out.

   **This correction was itself made twice.**  The first draft of this pass
   asserted the stronger and FALSE claim "decompile never prints vpiInstance for
   a typespec"; a root decompile of `#25349` refuted it before the patch was
   finalised.  Recorded because it is the same species of error as the one being
   fixed: a true reading of one form generalised to all forms.

## The new head — R0 on all five rows

`uvm_sequencer_base.svh:1576:23-1576:44`, inside `operation` at `1576:19`:

```
LHS  constant            vpiDecompile:this          id 25787/25782
RHS  hier_path (this.sequences.size)                id 106861/104225/...
```

which is EXACTLY the ladder's pre-existing **R3** (`constant|VpiType|
KIND:constant>hier_path` at `uvm_sequencer_base.svh:1576:23`) from
`r10ladder1repro/ladder_default_*.txt` — the ladder named the next head before
this pass started, and the official judge has now arrived at it.  `BuildUVMPkg`
keeps its own older head (a `constant` in `uvm_default_factory::
find_override_by_name`, which the walk reaches before the placeholder).

## The instruments (all MEASUREMENT-ONLY; build line in each header)

    g++ -O2 -std=c++17 <tool>.cpp -I ~/.local/include -I ../r10ladder1repro \
        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <tool>

| tool | what it answers |
|---|---|
| `ct83pkg.cpp`  | every vector `package::Compare` walks, in compare order, NULL vs EMPTY vs count — the census that refuted the brief |
| `ct83why.cpp`  | per-field re-run of a failing package pair from the polluted context (the FIRST attempt; kept because its failure is instructive — see below) |
| `ct83head.cpp` | the same with `m_visited` SNAPSHOT before each field, which is what makes a per-field verdict faithful |
| `ct83path.cpp` | **the head-path tracer** — walks `design::Compare`'s own field order level by level, snapshotting `m_visited` before every field AND every vector element, descending only where the failure still reproduces the OFFICIAL `(m_failedLhs, m_failedRhs)` pair.  116 levels, every one CONFIRMED |
| `ct83bind.cpp` | which RHS object was the head paired with?  (answer here: NONE — which is what proved the head was a `SafeCompare(lhs, nullptr)` on a SINGULAR field rather than a vector-shape mismatch) |
| `ct83ref.cpp`  | referrer index: every object+FIELD in golden that points AT a given object (4060 of them point at `package uvm_pkg #1`, all through `Instance`) |
| `ct83inst.cpp` | the `vpiInstance` tally per (referrer kind -> target role); `--dump <kind>` enumerates by name+span+role |
| `ct83cen.cpp`  | joined census, golden vs ours, comparing the MULTISET of `Instance` roles per positional key (order-independent, so parentless twins cannot force an invented pairing) |
| `ct83pred.cpp` | the MOVER PREDICTOR, run on PRISTINE databases only |
| `ct83dec.cpp` / `ct83fld.cpp` | `decompile()` and every COMPARED field of one object by `UhdmId`, for reading the same object off both databases |

`ct83why` is kept deliberately: it re-ran the fields from the context left at the
END of the failing walk and therefore reported that SIX fields "FAIL", because
`m_visited` was already past them.  A per-field re-run without the pre-field
snapshot answers a different question than the judge asks.  `ct83head` and
`ct83path` are the corrected form.

## Field tables

`ct83ref`, `ct83inst`, `ct83cen`, `ct83fld` and `ct83path` `#include
"ctfields.inc"` from the COMMITTED `tools/probe/r10ladder1repro/` — the official
Compare field order, scraped from UHDM's generated `Compare` bodies by that
directory's `genfields.py`.  Nothing there is modified, and nothing in UHDM was
patched or rebuilt.

`ct83path` also carries the 24 hand-written fallbacks for the fields UHDM
exposes no vpi selector for; `design::AllPackages`, the FIRST container
`design::Compare` walks, is one of them, and without it the tracer skipped
straight past the head and reported `design::Typespecs 123 vs 89`.

## Read next

* `CENSUS.r10uvm83.txt` — the refutation of the brief, the located head, the
  enumerated family, the distinguisher and the predictor.
* `PREDICT.r10uvm83.txt` — the mover prediction and what byteverify measured.
* `GATES.r10uvm83.txt` — the five gates.
* `LADDERS.r10uvm83.txt` — ladder before/after on all seven UVM row-modes.

## What did NOT change, and is recorded as residue

* the **FORMAL** spelling of the same catch-all (§ `classScopedTdFormalUnsupported34`,
  `src/TaskFuncEmit.cpp`) is left uninstanced.  The shipped text of this bullet
  said that was "deliberate" because "the corpus contains no OUT-OF-BODY method
  with an `Owner::td` FORMAL, so there is no cell that could distinguish the two
  readings".  **THE ADVERSARIAL VERIFIER BUILT THAT CELL AND IT DISTINGUISHES
  THEM.**  `v83_a24_formal_oob.sv` writes the formal AND the RETURN type of an
  out-of-body method as `Owner::td`, and a real Surelog golden stamps BOTH:
  `zbase24::c_t` at `16:12` (return), `16:41` and `16:71` (formals) carry
  `pkg:DEF(pa24)` + `pkg:ELAB(pa24)` in golden and NULL x3 in ours, on the
  pristine AND the patched binary alike.  The corpus half of the sentence is
  true (no corpus row writes it); the "no cell could distinguish" half was
  false, and the reading is now settled: the formal and return sites take the
  SAME stamp this pass gave the body local.  That is the pass's **first-ranked
  residue**, not an unanswerable question.  See `README.verifier.md`.
* the **DECLARATOR-ARRAY** sites (4a queue/dynamic, 4b associative, 4c, 5) are
  left as they were.  Their resolved element typespec IS stamped and the
  placeholder that replaces it is not, which is the same shape this pass fixed
  at the flat-local sites — but no corpus row and no grid cell writes
  `Owner::td arr[...]` inside an out-of-body method, so the reading would be a
  generalisation rather than a measurement.  **THE ADVERSARIAL VERIFIER MADE IT
  A MEASUREMENT:** `v83_a17_arrays.sv` writes all four declarator forms
  (fixed `[4]`, queue `[$]`, dynamic `[]`, associative `[string]`) inside an
  out-of-body method, and the Surelog golden stamps ALL FOUR
  (`pkg:DEF(pa17)`+`pkg:ELAB(pa17)` at `20:5`, `21:5`, `22:5`, `23:5`) while
  ours leaves all four NULL x2 on both binaries; the in-body twins are NULL in
  golden too.  Second-ranked residue, with a cell.
* the `importCopyTsInst` / `importCopyTsCollect` arm of the new stamp mirrors the
  resolved typespec's treatment exactly, and NO corpus row exercises it (no
  wildcard-import clone declares an `Owner::td` local).  Untested by
  construction; structurally identical to the line above it.
* `unsupported_typespec` families this pass did NOT touch, still differing on
  SimpleUVM (ct83cen): `G{pkg:DEF,pkg:ELAB} O{pkg:ELAB,pkg:ELAB}` x10 (the
  `REQ`/`RSP` base-type-parameter names) and `G{pkg:DEF} O{pkg:DEF,pkg:ELAB}` x2
  (`m_executing_phases`).  Different emitter sites, different laws.
* one `Owner::td` placeholder golden HAS and we do not emit at all
  (`496:12-496:23`, instanced def+elab in golden), and one whose SPAN differs
  (`1308:33-1308:53` vs our `-1308:61`).  Both are separate families, both
  recorded in CENSUS Part 2.
