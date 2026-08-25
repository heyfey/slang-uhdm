# r10uvm124 — § `selRecvStmtCallBareNames124`

**A STATEMENT CALL'S RECEIVER IS NAMED FROM THE *NAME NODE*, NEVER FROM THE
SUBSCRIPT** — the SeqDriver ×2 + MiniAmiq ×2 head **CLEARED**, 28 → 17 cmp
lines on all four row-modes.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `5254f43` |
| production surface | `src/ExprEmit.cpp` ONLY — one law, inside the BUILT-IN statement-call arm |
| probe surface | `tools/probe/r10uvm124repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SeqDriver default / testflags** | **28** | **17** | 1 — a **NEW** head, a different family (§5 R0) |
| **MiniAmiq default / testflags** | **28** | **17** | 1 — the same new head |
| SimpleUVM default / testflags | 148 | 148 | cmp log **byte-identical** |
| Scoreboard default | 148 | 148 | cmp log **byte-identical** |
| BuildUVMPkg default / testflags | 148 | 148 | cmp log **byte-identical** |
| Earlgrey_0_1 default / testflags | 240 / 268 | 240 / 268 | cmp log **byte-identical** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes) | |
| byte movers | — | **7 / 956** surelog, **0 / 1358** uhdm2rtlil | |
| the nine UVM databases | — | **35 cells TOGOLD, 0 MOVED-WRONG, 0 AWAY, 0 one-sided added or removed** | |
| the twelve arm-views | — | **58 TOGOLD, 0 MOVED-WRONG, 0 AWAY**, 6 MOVEDOTHER = residue R1 | |
| wide boundary | — | 3769 sources × 2 views, 16 moved arm-views, every one attributed; the 6 foreign ones are **10 cell moves, all TOGOLD** | |

The cmp-line counts are DEPTH, not distance: they are the size of the head
object's decompile, not a count of remaining defects.

---

## 1. THE HEAD, AS THE JUDGE PRINTED IT

`head_pris_default_SeqDriver.cmp` (28 lines, `grep -c '^LHS:'` = 1, identical
on MiniAmiq and in both modes):

```
LHS  ref_obj (uvm_pkg::uvm_default_factory::register::m_inst_override_queues) @919:13-919:35
       |vpiName:m_inst_override_queues
RHS  ref_obj (…::m_inst_override_queues[obj]) @919:13-919:40
       |vpiName:m_inst_override_queues[obj]
       both |vpiParent: method_func_call (queue) @919:41-919:46
```

**THE FIELD IS `VpiName`.**  `ref_obj::Compare`
(`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:122`) reads
`basetype_t::Compare`, then **`VpiName`**, then `VpiDefName`, `VpiGeneric`,
`Actual_group`, `VpiStructMember`.  Neither `VpiFullName` nor the span is a
compared field (RESUME §9) — the span is fixed here because Surelog's own
builder fixes it, and because a name and its span must not drift apart, not
because the judge reads it.

Site, `uvm-1.2 src/base/uvm_factory.svh:919`, inside
`uvm_default_factory::register`:

```systemverilog
            m_inst_override_queues[obj].queue.push_back(m_wildcard_inst_overrides[i]);
//          ^col 13              ^col 35 ^39 ^41
```

The object is the RECEIVER of the `queue` call.  Golden names it with the BARE
associative-array name and spans the NAME ALONE (13–35); the pristine binary
named it with the SELECTED TEXT and spanned through the `]` (13–40).  The
parent `method_func_call (queue) @919:41-919:46` was already byte-identical.

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT GUESSED

`CompileHelper::compileTfCall`'s **user-call arm**,
`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:4216-4241`, is the
WHOLE statement-position builder for `a[i].b…(args)`:

```cpp
    tfNameNode = dollar_or_string;                 // the FIRST name node, `a`
    name = fC->SymName(tfNameNode);                // "a"          <-- SymName
    NodeId Constant_bit_select = fC->Sibling(tfNameNode);
    while (fC->Type(Constant_bit_select) == VObjectType::paAttribute_instance)
      Constant_bit_select = fC->Sibling(Constant_bit_select);
    if (fC->Type(Constant_bit_select) == VObjectType::paConstant_bit_select) {
      tfNameNode = fC->Sibling(Constant_bit_select);   // STEP OVER the subscript
      method_func_call* fcall = s.MakeMethod_func_call();
      const std::string_view mname = fC->SymName(tfNameNode);      // "b"
      fC->populateCoreMembers(tfNameNode, tfNameNode, fcall);      // `b`'s span
      fcall->VpiName(mname);
      fcall->VpiParent(pexpr);
      ref_obj* prefix = s.MakeRef_obj();
      prefix->VpiName(name);                                       // "a"
      prefix->VpiParent(fcall);
      fC->populateCoreMembers(dollar_or_string, dollar_or_string, prefix);
      fcall->Prefix(prefix);                                       // `a`'s span
      call = fcall;
    }
```

Both names come off `SymName` of a **NAME NODE** and both spans off
`populateCoreMembers` of that **same node**.  **THE SUBSCRIPT IS NEVER READ
INTO A NAME**: it is stepped over, so neither the receiver's index nor the call
name's index appears in a name, and both spans stop at the `[`.  There is no
gate on the subscript's shape, its kind, the method, the home or the chain
length — Surelog does not look at the subscript's text at all.

**OUR PATH.**  `src/ExprEmit.cpp`, the BUILT-IN method arm's `stmtCtx` branch
(`§ thisStmtHandleCall85`'s neighbour).  The receiver's RAW TEXT is split on
top-level dots into `dots`; `recvNm0 = dots[0]` became the prefix's VpiName and
`callNm0 = dots[1]` (when the receiver is dotted) the call's, both with the
written subscript still in them.  § `dottedIdxRecvFromSyntax23` had already
transcribed Surelog's rule for **one** cell of that population — a
SINGLE-component receiver whose subscript happened to contain a DOT — and gated
it `dotInBracket23(recvText) && !deep0`, because that pass measured only what
its own gate could reach; its README says so as residue **R-Q**
(`tools/probe/r10buvm23repro/README.md:356`).  The USER-method twin
(§ `deepRecvCall11`, ~`ExprEmit.cpp:17412`) never had the defect: it builds its
segments from the AST and its `sg0.name` is already a bare name.  So the whole
defect lived in the BUILT-IN arm, and the whole fix is to let it read the same
tree the USER arm reads.

---

## 3. THE LAW

> **§ `selRecvStmtCallBareNames124`.**  In STATEMENT position, a built-in
> method call's `vpiPrefix` receiver `ref_obj` is named with the BASE NAME of
> the receiver's FIRST written component and spans that NAME ALONE, and — when
> the receiver is dotted — the `method_func_call` is likewise named with the
> BASE NAME of the SECOND component and spans that name alone.  The subscript
> is dropped from BOTH names, whatever it contains and however many dimensions
> it has.
>
> **THE FENCE IS THE TREE, NOT THE TEXT.**  The rename fires only where
> `builtinRecvStepSelectors74` has confirmed the text split COMPONENT FOR
> COMPONENT and DIMENSION FOR DIMENSION against the receiver slang bound, so a
> step whose text merely LOOKS subscripted keeps its written component.
>
> EXPRESSION position is not this law's: Surelog reaches it through
> `compileExpression`'s `hier_path` builder, which DOES read the subscript.

Implementation, `src/ExprEmit.cpp` (the whole behavioural change):

```cpp
    std::string recvNm23 = recvNm0;
    std::string callNm124 = callNm0;
    if (stepOk23) {
        if (!stepSel74[0].sels.empty())
            recvNm23 = stepSel74[0].base;
        if (deep0 && stepSel74.size() > 1 && !stepSel74[1].sels.empty())
            callNm124 = stepSel74[1].base;
    }
```

`stepOk23` is `builtinRecvStepSelectors74(*recv, dots, stepSel74)`, which was
already computed at this site and already hoisted above the
statement/expression split.  The old `dotIdx23 && !deep0` gate is gone; the
mfc's own start offset still uses the WRITTEN component-0 text, because the
second name node sits immediately after that component's `.`.

**WHAT THE FENCE REFUSES, measured on the corpus itself.**  MiniAmiq's
`control_assertion_dpi(a_sva.…)` family (r10buvm23 residue **R-P**) is split
inside PARENTHESES, so its pristine prefix reads
`get_cover_statistics_dpi(cover_info[index]`.  The tree walk refuses it (one
component in the tree, two in the text) and the cell is BYTE-IDENTICAL after
the law — census cell `MiniAmiq 512:56`.  It is exactly why the a-priori
predictor names SIX candidate cells on MiniAmiq and only FIVE move.

---

## 4. THE GRIDS (`g124_*.sv`, six arms, both views, `arms124.sh`)

Every arm is scored against a Surelog golden built for the SAME view, with
`cells124.py`/`score124.py`; the driver keys each arm's scratch on its RELATIVE
path, reads the file list on fd 3, gives every child `</dev/null`, records
every rc and asserts PROCESSED == LISTED.  Names inside the arms are
deliberately unlike the arm letters and unlike each other, so an agreeing cell
cannot be an artefact of the naming scheme.

| arm | axis | patched |
|---|---|---|
| `g124_a_kinds` | SELECT KINDS: associative keyed by a CLASS handle, by a string and by an int; dynamic; fixed unpacked; queue; two-dimensional; plus two no-select fences | def 7 TOGOLD / elab 7 TOGOLD |
| `g124_b_meths` | METHODS: `push_back` `push_front` `pop_back` `delete()` `delete(idx)` `delete(key)`, a user function, a user task, with and without arguments | def 7 / elab 7 TOGOLD |
| `g124_c_homes` | HOMES: in-body method, OUT-OF-BODY task, OUT-OF-BODY function, free package function, free package task, module task, module `initial`, module `always` | def 8 / elab 8 TOGOLD |
| `g124_d_chain` | CHAINS: subscript on component 0 / on 1 / on both / on neither, at lengths 2 and 3, plus a user method at the tail | def 2 / elab 2 TOGOLD + 3 MOVEDOTHER (residue R1) |
| `g124_e_expr` | EXPRESSION position — the CONTROL | **SAME_AGREE=7 in both views; the database is BYTE-IDENTICAL** |
| `g124_f_fence` | FENCES + MULTIPLICITY: no-select receiver, `this` receiver, an index that is a CALL, an index that is an OPERATION, and the same call written 1/2/3 times | def 5 / elab 5 TOGOLD |

Totals: **58 TOGOLD, 0 MOVED-WRONG, 0 AWAY-FROM-GOLDEN**; golden-vs-golden
calibration over the same twelve arm-views is 0 DIFF / 0 ONESIDED
(`CENSUS.r10uvm124.txt` §0).

---

## 5. RESIDUES

**R1 — the SECOND component's subscript is golden's ARGUMENT.**  When the
receiver's second component carries a subscript (`Only.Fan[Px].Ends.push_back(303)`,
`Limb[Px].Fan[Px]…`, `Alias[Qx].Fan[2]…`), Surelog's
`argListNode = fC->Sibling(tfNameNode)` (`CompileHelper.cpp:4324`) lands on
that `paConstant_bit_select` and `compileTfCallArguments` compiles its INDEX as
the call's ONE argument — golden's `method_func_call (Fan)` carries
`vpiArgument ref_obj (Px)` bound to the loop's `io_decl`.  This law moves the
NAMES (both are byte-identical to golden after it) and leaves the argument
vector where it was, so the three grid cells score MOVEDOTHER, not TOGOLD.
**Corpus population: ZERO** — `PREDICT.r10uvm124.txt` and
`PREDICT.u2r.r10uvm124.txt` find no `method_func_call` whose OWN VpiName
carries a `[` in either corpus, so the whole shape is grid-only.  Deliberately
left visible: it is a different UHDM field built by a different Surelog
function, and minting an argument opens a binding window this pass did not
decode.

**R2 — `VpiFullName` of the moved prefix.**  It follows the name
(`joinRef(prefix, base)`) and is byte-identical to golden on all five corpus
cells; recorded only because no generated `Compare` reads it, so it is
byte-identity, not correctness.

**R-P stays open, and is now FENCED BY MEASUREMENT.**  MiniAmiq's
`control_assertion_dpi(a_sva.x)` receivers (12 + 2 rows, both modes) still
mint their `ref_obj (control_assertion_dpi(a_sva…)` fossils.  Golden's shape
for them was not measured here either; what IS measured is that this law does
not touch them.

**R-Q is CLOSED.**  `q[0].delete();` — an indexed receiver with no dot in the
subscript — was r10buvm23's unmeasured residue.  Golden's answer, measured here
on `g124_a_kinds`/`g124_b_meths`/`g124_f_fence` and on the corpus, is the same
bare base name; the gate that produced R-Q is gone.

---

## 6. R0 — THE NEXT HEAD

`head_pat_default_SeqDriver.cmp` (17 lines, `grep -c '^LHS:'` = 1;
byte-identical between the two modes and, but for object ids, on MiniAmiq):

```
LHS  ref_typespec: (uvm_pkg::uvm_printer::adjust_name::id), id:7725
       |vpiParent: \_ref_obj (…::adjust_name::id) @808:25-808:27
       |vpiActual: \_string_typespec  @445:33-445:39
RHS: <null>
```

**A MISSING `ref_typespec` ON A `ref_obj`.**  The SINGULAR `SafeCompare`
overload with `rhs == nullptr` names the VALUE and prints `RHS: <null>`
(RESUME §9), so the failing field is `ref_obj::Typespec`: golden's reference
carries a `ref_typespec`, ours carries NONE.

The two locations name the two ends of a CALL ARGUMENT, and both were checked
in the uvm-1.2 sources rather than assumed:

* `uvm_printer.svh:808` is
  `  return uvm_leaf_scope(id, scope_separator);` inside
  `function string uvm_printer::adjust_name(string id, byte scope_separator=".");`
  (declared at `:805`).  Columns 25–27 are the ARGUMENT `id`, a string FORMAL
  of `adjust_name`.
* `uvm_misc.svh:445` is
  `function string uvm_leaf_scope (string full_name, byte scope_separator = ".");`
  — column 33 is the `string` of the CALLEE's FIRST FORMAL, `full_name`.

So golden types a call ARGUMENT from the CALLEE's FORMAL: the `ref_obj` for
`id` gets a `ref_typespec` whose `vpiActual` is the `string_typespec` of
`uvm_leaf_scope`'s `full_name`.  The family is the typespec-linkage one, not
the naming one this pass closed.

---

## 7. THE MOVER PREDICTION, MADE BEFORE THE COMPARISON

`pred124.py` reads a **PRISTINE dump alone** and names a cell when the database
holds a `method_func_call` whose `vpiPrefix` object's VpiName carries a `[`, or
whose OWN VpiName does.  It deliberately OVER-approximates: it ignores the tree
check and the statement/expression split, so every database the law can touch
is named and a named cell that does not move is a fence doing its job.
`predsweep124.sh` runs it over every database of a workdir with PROCESSED
asserted.  A database with nothing to predict prints NOTHING and is COUNTED,
so the artifact never enumerates a workdir's rows by name — this campaign does
not spell the slang-fenced test names, and a sweep artifact is no exception.

* `PREDICT.r10uvm124.txt` — `LISTED=956 PROCESSED=956
  ZERO_CANDIDATE_DATABASES=949`, i.e. **7 candidate databases out of 956**, 37
  candidate cells: `default/{MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}` and
  `testflags/{MiniAmiq,SeqDriver,SimpleUVM}`.  MiniAmiq is named with SIX cells
  and moves FIVE (the sixth is the R-P fossil the tree fence refuses).
* `PREDICT.u2r.r10uvm124.txt` — `LISTED=1358 PROCESSED=1358
  ZERO_CANDIDATE_DATABASES=1358`: **0 candidates out of 1358**.

`byteverify` then found **exactly** those 7 databases on surelog and **0** on
uhdm2rtlil: **0 movers unpredicted, 0 predicted databases that failed to move.**

`MOVERS.r10uvm124.txt` is the order-blind, path-normalised whole-dump diff of
each mover (both dumps sorted, so Scoreboard/default's ~50/50 `vpiTaskFunc`
ORDER COIN cannot be mistaken for a move).  Per mover: 120 moved lines on
SeqDriver/MiniAmiq (two packages × 5 sites × 2 listings × header+VpiName+
VpiFullName, added and removed), 60 on SimpleUVM/Scoreboard.  **Every moved
line in every mover names `m_inst_override_queues` or
`m_inst_override_name_queues` — 0 lines outside the law's family.**

---

## 8. INSTRUMENTS (all measurement-only; the judge is `uhdm-cmp`)

| file | what it does |
|---|---|
| `cells124.py` | census of every `method_func_call`, its `vpiPrefix` object and its argument count; keyed on `<call start>\|<call name base>\|<prefix start>\|<prefix name base>` — a NAME BASE (truncated at its first `[`) is invariant under this law by construction, and carrying it keeps two unrelated sites that share a `line:col` in two different `.svh` files out of one another's cells.  `VpiName` is read off the object's own `\|vpiName:` line, never off the parenthesised header the dump SYNTHESIZES.  A `\|vpiParent:` back-reference is skipped so it cannot manufacture a phantom |
| `score124.py` | golden vs pristine vs patched, multiset join per key: TOGOLD / MOVEDWRONG / MOVEDOTHER / SAME_AGREE / SAME_DIFF / ONESIDED_PRIS / ONESIDED_PAT |
| `arms124.sh` | every `g124_*.sv` under Surelog + both binaries, BOTH views, per-arm subdirectory keyed on the arm's RELATIVE path, fd-3 file list, children `</dev/null`, every rc recorded, PROCESSED asserted |
| `uvmcen124.sh` | the same census over the named rows of two `verify_golden` workdirs; the golden path comes out of each row's OWN `cmds.txt`, so it cannot compare against the wrong golden, and a missing side prints SKIP-NOFILE and is COUNTED |
| `pred124.py` / `predsweep124.sh` | the A-PRIORI mover predictor and its whole-workdir sweep (§7) |
| `bound124.sh` | the WIDE boundary (from `r10buvm30/bound30.sh` via `r10uvm120`): every `.sv`/`.v` under a COPY of `tools/probe`, both binaries, both views, no path filter |
| `g124_a_kinds.sv` … `g124_f_fence.sv` | the six grids of §4 |
| `head_{pris,pat}_default_{SeqDriver,MiniAmiq}.cmp` | the judge's own head logs, before and after |
| `ARMS*.txt` `CENSUS…` `PREDICT…` `MOVERS…` `BOUNDARY…` `GATES…` | the evidence |
| `canaudit.sh` / `canaries.sh` / `ctcan2.sh` / `ct8rows.sh` / `byteverify.sh` / `rowheads.sh` | the standard gate battery, carried so `canaudit.sh` can prove the fenced names are covered here |

## 9. GATES

All green — see `GATES.r10uvm124.txt` for the full list with the binaries'
md5s, the two status histograms, the byteverify SELFCHECKs, the canary
battery, the protected-database md5s and the wide boundary.
