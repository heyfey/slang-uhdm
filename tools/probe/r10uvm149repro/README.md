# r10uvm149 — § `structMemberWrittenQueueArrayTs149` — **A STRUCT/UNION MEMBER WRITTEN WITH A QUEUE DIMENSION CARRIES AN `array_typespec` WHOSE MARKER RANGE IS THE QUEUE'S OWN `[0 : $]`** — the `uvm_cmdline_parsed_arg_t.args` head CLEARED on all three row-modes, 0 corpus rows changed

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**; `GOLDEN_DEFER` was never set.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `cfc5eaa` (= UVM pass 147) |
| pristine binary | built from a clean worktree at `cfc5eaa`, frozen `chmod 555` before any sweep; its own head logs reproduce the brief's head object for object |
| patched binary | frozen `chmod 555` before any sweep |
| production surface | `src/TypeEmit.cpp` (one new member function + two three-line hooks), `src/UhdmExporter.cpp` (one clause inside the existing `bareWrapInst`), `include/UhdmExporter.h` (one declaration) |
| probe surface | `tools/probe/r10uvm149repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SimpleUVM default / testflags** | 60 cmp lines, head = golden's `array_typespec` (`0:$`, elem `string_typespec`) vs our bare `string_typespec` on `uvm_cmdline_parsed_arg_t.args` | **head CLEARED** — 62 lines on a NEW head object of a different family |
| **Scoreboard default** | 60, the same head | **head CLEARED**, the same new head |
| SeqDriver default / testflags | 62, 1 head | head log identical **modulo serializer object ids** |
| MiniAmiq default / testflags | 62, 1 head | head log identical **modulo serializer object ids** |
| BuildUVMPkg default / testflags | 68, 1 head | head log identical **modulo serializer object ids** |
| Earlgrey_0_1 default / testflags | 29 / 50, 1 head | head logs **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL), byte-identical |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this pass's own pristine sweeps |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the set **PREDICTED BY NAME** from pristine+golden databases before the patched sweep ran |
| the law's corpus census, nine UVM row-modes | 1 wrong cell each | **`TO-GOLDEN 1 / AWAY-GOLDEN 0 / MOVED-WRONG 0` on every one of the nine** |
| the law's grid, five arms | 24 wrong keys | **`TO-GOLDEN 18 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / STILL-WRONG 6`**; arm `shapes` CONVERTS (cmp 64 → 0); arm `neg`'s two databases **BYTE-IDENTICAL** |
| golden calibration | — | golden-vs-golden residual **0** on every census, corpus and grid |
| wide boundary | — | 4250 arms LISTED = PROCESSED, 4105 databases produced, RC_DIFFS 0, **7 moved arms**: this pass's own 4 (positive control) + 3 earlier-pass arms that all declare a `[$]` struct member, all re-measured against golden: **5 keys TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG** |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`uvm-1.2 src/base/uvm_component.svh:1701-1705`, inside the `uvm_component`
class body:

```systemverilog
typedef struct  {
	string arg;
	string args[$];
	int unsigned used;
} uvm_cmdline_parsed_arg_t;
```

```
LHS:
array_typespec: , id:127529
|vpiRange:
\_range: , id:127526, line:1703:14, endln:1703:15
  |vpiLeftRange:
  \_constant: , id:127527                    |vpiDecompile:0 |vpiSize:64 |UINT:0 |vpiConstType:9
  |vpiRightRange:
  \_constant: , id:127528, line:1703:14, endln:1703:15
                                             |vpiDecompile:$ |vpiSize:1  |STRING:$ |vpiConstType:10
|vpiElemTypespec:
\_ref_typespec: , id:127530
  |vpiActual:
  \_string_typespec: , id:127523, line:1703:2, endln:1703:8
RHS:
string_typespec: , id:12167, line:1703:2, endln:1703:8
|vpiParent:
\_typespec_member: (args), id:12166, line:1703:9, endln:1703:13
```

The slot is a **singular** `SafeCompare` — `typespec_member::Compare`'s
`Typespec()` field (generated `typespec_member.cpp`) — so both halves are set
and the head names the two typespecs directly. The element `string_typespec` on
our side is already byte-for-byte what golden's element is (same span, same
absent `vpiInstance`); the whole failure is the **missing wrapper**.

## 2. THE DECODED MODEL — one Surelog site, cited

**`CompileHelper::compileTypespec`, the `paStruct_union` arm,
`CompileType.cpp:1723-1760`.** The member's own data type is compiled and
stored first (`m->Typespec()->Actual_typespec(member_ts)`, `:1717-1722`); then:

```cpp
if (Expression && (fC->Type(Expression) == VObjectType::paVariable_dimension)) {
  NodeId Unpacked_dimension = fC->Child(Expression);
  if (fC->Type(Unpacked_dimension) == VObjectType::paUnpacked_dimension) {
    VectorOfrange* ranges = compileRanges(component, fC, Unpacked_dimension, ...);
    array_typespec* pats = s.MakeArray_typespec();
    ref_typespec*   ref  = s.MakeRef_typespec();
    ...
    pats->Elem_typespec(ref);
    ref->Actual_typespec(m->Typespec()->Actual_typespec());
    m->Typespec()->Actual_typespec(pats);
    pats->Ranges(ranges);
  }
}
```

`populateCoreMembers` is **never called on `pats`** (hence golden's
location-less `array_typespec`), the elem `ref` gets **no parent and no
`vpiFullName`**, and the element keeps its own parent (the `typespec_member`)
and its own `vpiInstance`.

### Which written dimensions reach that arm — and the three that do NOT

`unpacked_dimension` is `[ constant_range ]` / `[ constant_expression ]` /
`unsized_dimension` (`grammar/SV3_1aParser.g4:1195-1199`), and
`variable_dimension` tries `unsized_dimension`, `unpacked_dimension`,
`associative_dimension`, `queue_dimension` in that order (`:1211-1215`).

* **`[$]` reaches it through `constant_expression`.** `$` compiles to a
  `vpiUnboundedConst`, which is precisely why `compileRanges`' "Specified by
  size" branch sets `associativeArray = true` and **skips its `-1` decrement**
  (`CompileExpression.cpp:4204`), leaving `Right_expr` the raw `$` marker:
  `vpiUnboundedConst`, size 1, `STRING:$`, decompile `$`, spanning the `$`
  TOKEN; `Left_expr` is the branch's own **location-less** folded `UINT:0`
  (size 64, `vpiUIntConst`, `CompileExpression.cpp:4185-4191`).
* **`[$:N]` reaches it through `constant_range`** — the "Specified by range"
  branch — so the range spans the WHOLE dimension, `Left_expr` is the `$`
  marker at its own token and `Right_expr` the folded bound at its own token.
* **`[]` never reaches it.** A leading `[]` takes
  `variable_decl_assignment`'s own `unsized_dimension` alternative
  (`:1167-1175`), so the declarator's sibling is a `paUnsized_dimension`, not a
  `paVariable_dimension`; Surelog hands it to `compileExpression`, which
  **REJECTS it** (`UH0700 Unsupported expression`, an rc-4 error recorded in
  the arm log) and leaves the member the BARE typespec plus an
  `unsupported_expr` `Default_value`.
* **`[int]` / `[string]` / `[*]` never reach it** — they are
  `paAssociative_dimension`, a sibling alternative of `paUnpacked_dimension`.

Golden confirms all four on arm `dims`, which is why the implemented gate is
**syntactic** and **first-dimension-only**:

* only `fC->Child(Expression)` is compiled, so `string x[$][5]` gets the SAME
  `[0 : $]` wrapper over a plain `string_typespec` (the `[5]` is DROPPED) and
  `string y[5][$]` a `[0 : 5-1]` one — arm `dims`, cells `QueueThenFixed` /
  `FixedThenQueue`;
* a member written with a TYPEDEF of a queue (`preQueued_t m;`) has NO written
  dimension at all, and golden binds the **typedef's own NAMED,
  package-instanced** `array_typespec` (with `Typedef_alias` set) instead — a
  different object and a different law. A gate reading the member's CANONICAL
  type would have fired there and been wrong; arm `dims` cell `TypedefQ` is the
  refutation, and it stays residue **R1**.

### The second half: the wrapper carries NO `vpiInstance`

Surelog instances the typespec it compiled for the member's DATA TYPE and
synthesizes the marker wrapper around it. Our emitter stamps the member's
**outermost** typespec, so the stamp landed on the new wrapper and the element
lost it. `typespec::Compare` recurses `Instance()`, so this is a hard cmp
failure a top-level look cannot show — which is why `ct149cen`'s payload
renders the ELEMENT one level down. `UhdmExporter.cpp`'s existing
`bareWrapInst` already cleared the wrapper for the FIXED-dimension family when
the element is nameless; this pass adds a **disjoint** clause gated on the
queue signature (nameless `array_typespec`, ONE range, a `vpiUnboundedConst`
bound) that hands the stamp down to an element that has none and clears the
wrapper. Measured on arm `elems` cells `clsQ` / `enumQ` / `nestQ` / `tdefQ`,
where golden's wrapper is instance-less and its element carries the package.

## 3. THE GRID — five arms, all named `dut.sv` in five subdirectories

`arm149.sh` builds Surelog golden + pristine + patched per arm; the file list
is read on fd 3, every child gets `</dev/null`, PROCESSED is asserted against
LISTED, scratch is keyed on the RELATIVE path, every rc is recorded, and the
binaries are printed so a run can be audited by path.

| arm | what it varies | pristine | patched |
|---|---|---|---|
| `dims` | queue `[$]` / bounded `[$:7]` / dynamic `[]` / assoc `[int]`,`[string]`,`[*]` / fixed `[9]`,`[3:1]`,`[2][4]` / `[$][5]` / `[5][$]` / packed+unpacked / packed only / a typedef-of-queue | 9 wrong keys | **3 TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG**, 6 named residues |
| `elems` | string / int / `bit[5:0]` / enum / nested struct / logic typedef / class handle / real, all under `[$]` | 8 wrong keys | **8 TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG** |
| `homes` | `$unit` / package / **class-scope** (the head's own home) / module / anonymous struct variable | 5 wrong keys | **5 TO-GOLDEN, 0 AWAY** |
| `shapes` | packed struct + packed union controls, a nested struct that itself carries a queue, 1..3 instances of the leaf | 2 wrong keys, cmp 64 lines | **2 TO-GOLDEN, 0 AWAY; the arm CONVERTS — uhdm-cmp 64 → 0** |
| `neg` | aggregates with NO unpacked dimension anywhere | cmp 0 lines | cmp 0 lines, **the two OUR databases BYTE-IDENTICAL** |

Golden-vs-golden calibration is **0 residual on every arm**, run first.

## 4. THE CENSUS AND THE MOVERS

`ct149cen` emits one row per `typespec_member`, keyed
`<owner-kind>|<owner-name>|<member>|<line>:<col>` with the DEF/ELAB **view out
of the key** and the FILE out of the key (our `typespec_member`s carry an EMPTY
`VpiFile`; a file in the key would make every cell one-sided and manufacture
AWAY phantoms — it is reported in a separate, un-joined column). The payload is
compare-visible only. `cen149.py` joins as MULTISETS; `away149.py` scores
golden/pristine/patched together.

Over the **nine UVM row-modes**: `TO-GOLDEN 1 / AWAY-GOLDEN 0 / MOVED-WRONG 0`
on every one, with golden-vs-golden 0 residual on every one.

`pred149` scanned **every** golden database both sweeps reached (1573 surelog
row dirs, 1462 uhdm2rtlil) for golden's signature — a `typespec_member` whose
actual is a NAMELESS, INSTANCE-LESS `array_typespec` with ONE range carrying a
`vpiUnboundedConst` bound. Result: **36 surelog row-modes, 0 uhdm2rtlil rows**,
and **every candidate in the whole corpus is the same source construct**,
`uvm_cmdline_parsed_arg_t.args` (39 objects). Intersected with the rows that
actually produce one of our databases that is **exactly nine**, and the measured
mover set is **exactly those nine** — no row over, no row under.

Attribution is ORDER-BLIND (both dumps path-normalised and sorted).
Scoreboard/default is a ~50/50 COIN and is attributed only that way: its 27
differing lines are the law's own and nothing else, identical to
SimpleUVM/default's and SeqDriver/default's.

## 5. RESIDUES, and the next head (R0)

* **R0 — the next head on SimpleUVM ×2 and Scoreboard/default is now the one
  SeqDriver and MiniAmiq already carry**: golden's `class_var (uvm_pkg::cs)` at
  `uvm_pkg.sv:1731:21` (`uvm_coreservice_t cs`, a package-level class variable),
  62 cmp lines, 1 head. Five UVM row-modes now share it. It is a sister pass's
  family, not this one's.
* **R1 — a member written with a TYPEDEF of a queue** (`preQueued_t m;`) must
  bind the typedef's OWN named, package-instanced `array_typespec` (with
  `Typedef_alias`); we still give it the bare element typespec. Arm `dims`,
  cell `TypedefQ`. Not in the corpus population.
* **R2 — the member's own SPAN.** Golden spans a dimensioned
  `typespec_member` from its name through the last dimension's `]`; we span the
  name only for queue / dynamic / associative members (the fixed-array arm
  already does it). Compare-invisible, deliberately left alone here.
* **R3 — a DYNAMIC `[]` member** carries an `unsupported_expr`
  `Default_value` in golden (Surelog's own `UH0700`), which
  `typespec_member::Compare` READS. Arm `dims`, cell `Dyn`.
* **R4 — the FIXED unpacked-dimension member arm is broken for a
  non-aggregate element**: `string x[9]` gets an `array_typespec` with NO
  ranges and NO `Elem_typespec` (`anonAggregateElemTs` returns null for a
  `string`), and `int x[3]`'s element comes out `logic_typespec` where golden
  has `int_typespec`. Arm `dims` cells `NineFixed`/`RangeFixed`/`TwoDim`/
  `FixedThenQueue`, and the two boundary arms' STILL-WRONG cells. A separate
  law with its own corpus population.
* **R5 — named-enum struct members** (`m_verbosity_setting.verbosity`,
  `state_info_t.state`) are `bit_typespec` where golden has `enum_typespec`, on
  all nine UVM row-modes. Named by the census here; a different family.

## 6. FILES

| file | what it is |
|---|---|
| `ct149cen.cpp` | the typespec_member census (compare-visible payload, element one level down) |
| `cen149.py` | the multiset join, golden vs ours |
| `away149.py` | TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / SAME over golden+pristine+patched |
| `pred149.cpp`, `pred149.sh` | the a-priori mover predictor over every golden database |
| `corpcen149.sh` | runs the census over named corpus rows, both sides, both modes |
| `arm149.sh`, `score149.sh`, `g149/` | the grid driver, its scorer, the five arms |
| `bound149.sh` | the wide boundary gate over a copy of the whole probe tree |
| `PREDICT` / `CENSUS` / `GRID` / `ARMS` / `MOVERS` / `BOUNDARY` / `GATES` `.r10uvm149.txt` | the measurements |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the official uhdm-cmp head logs, before and after |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the gate scripts, carried unchanged so this directory runs standalone |
