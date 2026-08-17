# r10buvm7 — § lvIncDecSelMemberCollapse7 (+ § lvIncDecCollapseNetSpans7)

**BASE 5c132aa.** Production surface: `src/ExprEmit.cpp` **only** — ONE hunk
inside the ONE `ExpressionKind::UnaryOp` arm of `emitExpr`. Probe surface:
`tools/probe/r10buvm7repro/` only.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and every script here.

**Result, up front.** The BuildUVMPkg head is CLEARED on BOTH modes:
**66 → 17 cmp lines**, cross-mode byte-identical, and the ladder (the official
`design::Compare`, run to fixpoint, calibration 0 rungs on 183142 golden
objects) falls **253 → 251 rungs** — the rung-list diff is EXACTLY the two
`ref_obj|VpiType|KIND:ref_obj>hier_path` rungs removed, **zero added**.
Five gates green.
7 movers, every one PREDICTED BY NAME before the build, every moved line
attributed, and distance to golden strictly DOWN on all 7.

---

## 1. THE HEAD

`uvm_pkg.sv:13042`, `m_override_info[index].used++` inside
`uvm_default_factory::find_override_by_type`:

```
LHS  ref_obj (uvm_pkg::uvm_default_factory::find_override_by_type::m_override_info)
     13042:7-13042:34   parent = the vpiPostIncOp operation   (no vpiActual)
RHS  hier_path (m_override_info[index].used) 13042:7-13042:34
       bit_select m_override_info[index] + ref_obj index + ref_obj used
```

Golden emits ONE reference NAMED FOR THE BASE, spanning the WHOLE lvalue text.

## 2. THE MECHANISM — a GRAMMAR fact, not a type fact

Read out of Surelog's source, then confirmed on the artifact.

`vparser`'s `variable_lvalue` builds a **`Hierarchical_identifier`** node — the
production `{identifier constant_bit_select .} identifier` — **only when the
FIRST identifier is followed by a bracket and then a dot**. The AST
(`surelog -d ast`) says it exactly:

| source | `Ps_or_hierarchical_identifier`'s child | its trailing `Select` |
|---|---|---|
| `sq[index].used++` | `Hierarchical_identifier(sq, [index], used)` | EMPTY `Bit_select` |
| `sq[index].ai[1]++` | `Hierarchical_identifier(sq, [index], ai)` | `Bit_select([1])` |
| `sbare.used++` | `StringConst(sbare)` | `Select(StringConst(used))` |
| `ch.sq[index].used++` | `StringConst(ch)` | `Select(sq, [index], used)` |

`CompileHelper::compileExpression`'s primary arm
(`CompileExpression.cpp` ~2696, `paHierarchical_identifier` / `slStringConst`)
then takes the name from **`fC->Child(child)` — the FIRST identifier ALONE** —
and walks only the **SIBLINGS of the `Ps_or_hierarchical_identifier`**, i.e. the
trailing `select`. Every bracket and every dot INSIDE the
`Hierarchical_identifier` is never visited: `[index].used` is **dropped on the
floor**. Here that trailing `Select` holds an EMPTY `Bit_select`, so
`compileSelectExpression` returns `nullptr` and the arm falls through to
"create ref_obj down below" — *the same code a bare `sq++` takes*, which is why
golden's object carries the ordinary scoped fullname and the ordinary late
binding. In rows 3 and 4 the child is a plain `StringConst`, the trailing
`Select` carries the dotted chain, and `compileSelectExpression`'s
`slStringConst` branch builds the full **hier_path** — which is why those keep
one.

The SPAN is then overwritten by the `paVariable_lvalue` arm's
`populateCoreMembers(child, child, variable)` (`CompileExpression.cpp` ~2465)
with the WHOLE lvalue node's text — the same line that gives a plain
`ia[1]++`'s `bit_select` its whole-lvalue span (§7, residue R1).

An RVALUE never collapses because it does not parse this way at all: `r =
sq[index].used` puts a **`Complex_func_call`** node there, which routes to
`compileComplexFuncCall` and builds the proper hier_path.

## 3. THE LAW

```
§ lvIncDecSelMemberCollapse7   src/ExprEmit.cpp, emitExpr, the UnaryOp arm
§ lvIncDecCollapseNetSpans7    the same hunk, the classPropRefs range
```

> An **inc/dec operand** (`vpiPostIncOp` / `vpiPreIncOp` / `vpiPostDecOp` /
> `vpiPreDecOp`) whose lvalue is a MEMBER access chain **whose base is DIRECTLY
> element-selected** collapses to a SINGLE reference built by the ORDINARY
> named-value path for the BASE, spanned over the WHOLE operand text.
> A lvalue with a TRAILING bracket after the last member is NOT claimed.

**The early return and the const-parent flags.** The collapse arm returns from
inside the `UnaryOp` case, before the `suppressConstParent` / `forceConstParent`
restore at the bottom. That is safe *by construction*, not by luck: the only
code between the save and this arm sets those flags when `unaryLitOperand` is
true, and `unaryLitOperand` requires `isLiteralExpr(operand)` or a
`RealLiteral` — mutually exclusive with the `MemberAccess` operand this arm
requires. So when this arm fires the two flags still hold their saved values and
a restore would be dead code.

The second law is one line of the same hunk: the collapsed reference is an
ordinary one, so an unresolved class property named by it mints the hoisting
module's bare `logic_net` through `classPropRefs` — as golden does — and that
net must carry the WHOLE-LVALUE span too, because Surelog's `lateBinding` reads
the ref's span after `populateCoreMembers` has already widened it.

## 4. THE GRID — 29 cells, `v1_lvincdecshape.sv`

Read with `r10buvm7cen` (below); `WIDEREF` = golden's collapse, `PATH` = a
hier_path, `SEL` = a plain select, `WIDESEL` = the unclaimed trailing-bracket
twin. GOLDEN vs PATCHED, per cell:

| cells | shape | GOLDEN | pristine | patched |
|---|---|---|---|---|
| a1-a8 | `sq[i].used++` over queue / dynamic / assoc / fixed / 2-dim / depth-2 / class-handle element, var and const index | WIDEREF | PATH | **WIDEREF** |
| a13-a16 | prefix `--`, postfix `--`, inside an EXPRESSION, another member | WIDEREF | PATH | **WIDEREF** |
| b7-b13 | in a task, a for body, a fork, a foreach, a module `initial`, an `always` | WIDEREF | PATH | **WIDEREF** |
| a9, a10, b1, b2, b3 | `ch.s.used++`, `sbare.used++`, `ch.iq[i]++`, `ch.sq[i].used++`, `ch.s.ai[i]++` | PATH | PATH | PATH |
| a11, a12, b12 | `iq[i]++`, `i++`, `ia[1]++` | SEL / PLAIN | SEL / PLAIN | SEL / PLAIN |
| b6, b6b, b6c, b6d | `= 5`, `+= 2`, rvalue, if-condition | PATH | PATH | PATH |
| b5, b5b | `sq[i].ai[1]++`, `sq[i].v[3:0]++` | WIDESEL | PATH | PATH (residue) |

18 cells convert, 11 hold. Census totals: golden `PATH=5 WIDEREF=18 WIDESEL=2`,
pristine `PATH=25`, patched `PATH=7 WIDEREF=18`. Dump distance to golden
**673 → 242** lines, and the converted objects are BYTE-IDENTICAL to golden
including the module cells' late-bound `vpiActual` `logic_net`.

The base's own kind is IRRELEVANT — measured, not assumed. The brief's
suggested discriminator ("the STRUCT-ness of the element") is **REFUTED**: a
queue of CLASS HANDLES (a8) collapses exactly like a queue of structs, and a
plain struct member with no index (a10) does not collapse at all.

## 5. THE CENSUS — the prediction, written BEFORE the byte gate

`r10buvm7cen.cpp` reads a database's `Serializer::AllObjects()` and prints one
row per inc/dec operation keyed `line:col`, so golden and ours JOIN on source
position. Over **ALL 3673 cached golden databases**:

```
incdec=69971  PLAIN=63794  SEL=990  PATH=3811  WIDEREF=1368  WIDESEL=0  OTHER=8
```

* **WIDESEL = 0**: the trailing-bracket half of the law never fires in either
  corpus. That is why it is left unclaimed instead of guessed at.
* `OTHER=8` are `unsupported_expr` operands in two probe databases (Surelog
  cannot compile an ATTRIBUTED inc/dec — r10buvm-era finding, not ours).

`predict7.sh` then joins golden's WIDEREF positions against OUR pristine
databases, per (corpus, mode, test). Written to
`/tmp/r10buvm7_prediction.txt` BEFORE any patched sweep:

| corpus | MOVER | CLEAN | AGREE | NOGOLD |
|---|---:|---:|---:|---:|
| uhdm2rtlil | **0** | 1358 | 0 | 0 |
| surelog | **7** | 946 | 0 | 0 |

The uhdm2rtlil corpus is an **impossibility proof**: golden's WIDEREF count is
0 in all 1358 databases, so the law cannot move one of them. Measured after
the fact: 0 movers / 1358.

The 7 predicted movers, by name: `BuildUVMPkg` (both modes, 5 positions),
`SimpleUVM` (both, 7), `SeqDriver` (both, 7), `Scoreboard` (default, 7).
Measured: **exactly those 7 / 953**.

## 6. Files

| file | what it is |
|---|---|
| `r10buvm7cen.cpp`, `build7.sh` | the census instrument (inc/dec operand shapes, keyed line:col, `file=` printed) |
| `v1_lvincdecshape.sv` | the 29-cell grid |
| `ct7arm.sh` | arm driver (golden + both binaries in ONE scratch dir) |
| `predict7.sh` | the corpus-wide prediction from a PRISTINE workdir |
| `striplines7.py` | block-level attribution filter (statements the law names) |
| `bound7.sh` | boundary check over the protected neighbour arms |
| `attrib7.sh` | per-mover attribution: DIFFLINES / FLIPS / RESIDUE |
| `sweeps.sh`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh`, `detcheck.sh` | carried-forward gate instruments |

## 7. THE GATES (all five, both binaries built here)

pristine md5 `8e90e5e318029d1336b1c447d9f8356e`, patched md5
`2a1259014e4c044da1e0ff9fe5caf7a1`.

| gate | result |
|---|---|
| 1 build | both binaries built at `-j 2`, `Built target slang_uhdm`, md5s above |
| 2 goldens | patched **23/0**, pristine 23/0, and `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (the negative control — note `check_goldens.sh` DEFAULTS to the MAIN-TREE binary, so it is exported explicitly for every reading here) |
| 3 uhdm2rtlil | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL per mode; `ct8rows` **0 differing rows** vs the committed `gate_uhdm2rtlil.csv` (baseline FIRST) and **0** vs the pristine sweep over all 1462 rows |
| 4 surelog | 470/10/5/284/25 and 466/7/5/3/1/286/23/1/2 per mode; `ct8rows` **0 differing rows / 1588** vs the committed `golden_surelog.csv`, and 0 vs pristine |
| 5 byteverify | surelog **7 movers / 953** — the predicted set, by name; uhdm2rtlil **0 / 1358**; `SELFCHECK` 952/953, `SELFCHECK1` 8; attribution **RESIDUE 0 on all 7** |

The PRISTINE sweeps reproduce both committed baselines EXACTLY (0 differing
rows on 1588 and on 731), which is what makes the patched readings mean
something.

**The five-row wall holds.** SimpleUVM 1405511, SeqDriver 1450011, Scoreboard
1399779 cmp lines, and each of those five cmp LOGS is **BYTE-IDENTICAL**
pristine vs patched even though four of their databases move — their heads sit
behind the uvm_pkg container wall, far above this law's sites. Canaries: 66 rows
(`canaries.sh`) + 60 rows (`ctcan2.sh`), **0 changed**, `canaudit.sh`
UNCOVERED=0 FENCE-BREACH=0. Pins: SVSwitch `4842211c4030`, YosysVerx
`6ccda350c24a`, InterfaceModPort/BlackParrotComplex/YosysOldOr byte-identical.
Boundaries: **all 145 `.sv` arms** of r10uvm70-82, r10buvm1-6 and r10sd1-12 —
`MOVED=0 RESIDUE=0 NO_DB=0`, with `v1_lvincdecshape.sv` as the POSITIVE CONTROL
(`DIFFLINES=431 FLIPS=18 RESIDUE=0`); an arm agreeing is not an arm testing, so
the control is run every time.

### The one PERMUTED mover, run down

`default/Scoreboard`'s attribution reads `RESIDUE=0 / PERMUTED`: content
identical as a line multiset, 92 lines in a different ORDER. It is the emitter's
own run-to-run nondeterminism, not a consequence of the law — the SAME patched
binary produces two different databases across 6 sequential runs
(`0e82f3489c92` x5, `fb2a57db5412` x1, and the sweep captured the rarer one),
and the two differ by exactly the same 46 `vpiTaskFunc` entries of
`svunit_pkg` permuted, multiset diff **0**. r10buvm6 recorded the identical
phenomenon on this row; the MEMORY entry "emitter nondeterminism" names the
mechanism (SourceLocation compares across macro buffers flip per run).

### On the attribution's line-only key

`striplines7.py` strips by SOURCE LINE, and two files of one design can share a
line number, so the filter can in principle remove more than the law's own
statements. The census prints `file=` so the risk can be BOUNDED instead of
assumed: on the golden side each of the 7 firing lines of the UVM-1.2 movers maps
to EXACTLY ONE file (`uvm_factory.svh` 1403/1441/1488, `uvm_objection.svh`
906/913, `uvm_component.svh` 3506/3576), so no collision exists there. On OUR
side the field prints EMPTY — our emitter sets no `VpiFile` on these references
at all, in both binaries, which is a pre-existing property this pass neither
causes nor changes (and one uhdm-cmp does not read).

## 8. RESIDUES (named, measured, NOT fixed)

* **R1 — § lvIncDecOperandSpan7.** Golden spans EVERY inc/dec operand over the
  whole lvalue text, not just the collapsed ones: `m_severity_count[severity]++`
  gives its `bit_select` 30001:5-31 where ours gives 30001:22-30 (the index's
  own span), and `this.for_each_idx++` gives its hier_path 70769:4-21 where ours
  gives 4-8. 4 bit_selects + 1 hier_path in BuildUVMPkg alone; 990 `SEL` rows
  corpus-wide. Span-only, so INVISIBLE to `uhdm-cmp` — it is a dump-byte
  residue, and a separate pass.
* **R2 — § lvIncDecTrailingSelect7.** `sq[i].ai[1]++` and `sq[i].v[3:0]++`:
  golden collapses to a `bit_select` / `part_select` NAMED FOR THE BASE and
  indexed by the LAST bracket (`compileSelectExpression`'s own two branches).
  ZERO occurrences in either corpus (census WIDESEL=0), reproduced in v1 cells
  b5/b5b.
* **R3 — `this.sq[index].used++`.** Golden emits
  `hier_path (this.@@BAD_SYMBOL@@)` — a Surelog symbol-table failure on legal
  SV. Not modelled, not moved by this pass (our own output there is unchanged).
