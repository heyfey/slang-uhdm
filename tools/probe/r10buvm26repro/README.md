# r10buvm26 — § `droppedIdxRecvCall26` — **A DROPPED CALL'S RECEIVER MAY BE SUBSCRIPTED: `x[k].m()` on an unspecialized type parameter kept the bare `bit_select` and LOST THE CALL**

**IMPLEMENTER VERDICT: ACCEPT.**  The 72-line `BuildUVMPkg` head clears in both
modes.  The row stays `CMP_NOTEQUAL` at a new 76-line head; **no corpus row
converts and no baseline was edited**.

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** (the copies in this worktree) and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `ecdded75` |
| worktree | `/tmp/wt_r10buvm26` |
| pristine binary | md5 `9ae62f2d6a19f72cf5cb259847914b9a` — reproduced the main tree's pin `/tmp/pris_9ae62f2d.bin` byte for byte |
| patched binary | md5 `905a87ec0b0218401130db11d5618f4b` |
| NULL-CONTROL binary | md5 `0f0e67dc6338f942cffec327df3502f5` (the whole pass compiled in, the arm switched off at run time — see BOUNDARY.txt) |
| production surface | `include/UhdmExporter.h` (2 declarations), `src/StmtEmit.cpp` (one extracted predicate, one new predicate pair, one finder, one emitter), `src/ExprEmit.cpp` (one gated clause) |
| probe surface | `tools/probe/r10buvm26repro/` only |
| deliverable | `/tmp/r10buvm26.patch`, applies clean on a FRESH `ecdded75` |

## 0. THE HEADLINE

| | pristine | patched |
|---|---|---|
| `BuildUVMPkg` cmp lines (`2>&1`), default / testflags | **72 / 72** | **76 / 76** |
| `uhdm-cmp` heads (`grep -c '^LHS:'`) | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp md5 (`2>&1`), both modes byte-identical | `c8a31e84977b61b9ecf368cda64a5521` (buvm25's pin, hit exactly) | `9d162daeca3fa0bcbdba4dec5a005afb` |
| head object | `hier_path (list1[name].get_comp)` vs a bare `bit_select (list1)` at uvm_pkg.sv:45158 | a **`constant UINT:8`** vs our `sys_func_call ($bits)` at uvm_pkg.sv:58066 (**R0**) |
| surelog sweep | 937 `CMP_EQUAL` / 19 `CMP_NOTEQUAL` | 937 / 19 — **unchanged**, 0 differing rows |
| u2r sweep, both modes | 679 / 50 / 2 | 679 / 50 / 2 — 0 differing rows, **0 byte movers / 1358** |

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG — AND buvm25's DECODE CORRECTED

The pristine log is 72 lines `2>&1`, `grep -c '^LHS:'` = 1, and the two modes
are byte-identical.  Source, `1800.2-2017-1.0/pp_output/uvm_pkg.sv:45152-45160`,
inside `uvm_port_component #(type PORT=uvm_object)`:

```systemverilog
  virtual function void get_connected_to(ref uvm_port_list list);
    PORT list1[string];
    m_port.get_connected_to(list1);
    list.delete();
    foreach(list1[name]) begin
      list[name] = list1[name].get_comp();      // :45158
    end
  endfunction
```

```
LHS  hier_path: (list1[name].get_comp)            @45158:20-42
       |vpiActual \_bit_select: (list1[name])       @45158:20-25
                    vpiName list1  vpiFullName list1[name]
                    vpiIndex \_ref_obj: (…get_connected_to::name) @45158:26-30
       |vpiActual \_method_func_call: (get_comp)    @45158:32-40
       |vpiName:list1[name].get_comp
RHS  bit_select: (uvm_pkg::uvm_port_component::get_connected_to::list1) @45158:26-30
       vpiName list1  vpiIndex ref_obj name
```

**THE SLOT IS `vpiRhs`, NOT `vpiLhs`.**  buvm25's README names the `Lhs` and
says the `Rhs` compared equal; the generated source and the databases both say
otherwise.  `assignment::Compare`
(`~/git-repos/UHDM/build/generated/src/assignment.cpp:106-120`) reads
`VpiOpType`, `VpiBlocking`, **`Rhs`**, then `Lhs` — and the whole-design dump
settles which is which:

```
\_assignment: , line:45158:7, endln:45158:42        (golden)
  |vpiOpType:82  |vpiBlocking:1
  |vpiRhs:  \_hier_path: (list1[name].get_comp)      <- THE HEAD
  |vpiLhs:  \_bit_select: (…get_connected_to::list)  <- identical on both sides
```

There is no swap: `CompileHelper::compileBlockingAssignment`
(`CompileHelper.cpp:4456-4530`) compiles the `Variable_lvalue` into `Lhs` and
the `Expression` into `Rhs`, exactly as written.  The source LHS is
`list[name]` and it agrees; the source RHS is `list1[name].get_comp()` and it
is the one that fails.  This matters concretely: the object is **not** "a
hier_path that lost its path suffix" — **we drop the method call entirely**, so
`list[name] = list1[name].get_comp()` came out as `list[name] = list1[name]`.

**THE OWNER, and WHICH COPIES.**  One object per database.  The whole design
holds exactly one `:45158` subtree in each of golden and ours, in both modes.

**THE FIELD.**  `BaseClass::Compare` tests `VpiType` before names or per-kind
fields, and `hier_path` vs `bit_select` differs there, so the walk stops
immediately — `Path_elems` is never reached.

## 2. WHY SLANG DROPS IT — THE STATE, ISOLATED IN 21 LINES

§ `droppedCall14` (`src/StmtEmit.cpp`) already decodes the state: a method call
whose receiver's type is an **unspecialized type PARAMETER** does not resolve,
so slang builds an `InvalidExpression` whose `child` is the receiver it *did*
bind.  Diagnostics are suppressed because a generic class's DEFAULT
specialization is uninstantiated, which is why this is silent and confined to
the DEF listing.  `uvm_port_component`'s default `PORT` is `uvm_object`, which
has no `get_comp`.

`tools/probe/r10buvm26repro` reproduces the corpus head in a 21-line file
(`/tmp/r10buvm26_t1.sv` in the pass log; the same shape is cell `39` of
`g26b.sv`), and a 5-cell matrix isolates the gate exactly:

| cell | default type has the method? | receiver | pristine |
|---|---|---|---|
| A | no  | `l1[nm]` | **bare bit_select** (the defect) |
| B | no (an explicit specialization exists) | `l1[nm]` | **bare bit_select** |
| C | **yes** | `l1[nm]` | correct `hier_path` |
| D | no  | `h1` (plain handle) | correct `hier_path` — § `droppedCall14` fires |
| E | no  | `l1[nm]`, a class PROPERTY not a local | **bare bit_select** |

So the discriminator is exactly **the SUBSCRIPT**: § `droppedCall14`'s shape
test demands `sn.left` be an `IdentifierName`, and its finder anchors on the
receiver IDENTIFIER's location — but slang's surviving child is a bound
`ElementSelect` whose `sourceRange` is the SELECTOR's, not the base's.  Neither
could see the spelling, and the arm fell through to the plain
`emitExpr(*iv2.child)` unwrap.

## 3. THE LAW

> **§ `droppedIdxRecvCall26`** — a DROPPED call's receiver may be SUBSCRIPTED,
> and the reference tool builds the ordinary shapes for it, because it does no
> member lookup at this level:
>
> * in **EXPRESSION** position the object is a `hier_path` named
>   `<base>[<decompiled index>].<method>` over exactly two elements — a
>   `bit_select` named for the BASE, located at the BASE NAME alone, whose
>   `vpiFullName` is the written component `<base>[<index>]` and whose
>   `vpiIndex` is the index expression, and a `method_func_call` named after
>   the METHOD at the method token, carrying the WRITTEN arguments;
> * in **STATEMENT** position **THE SUBSCRIPT IS NEVER READ**: the object is
>   § `droppedCall14`'s own statement shape — a `method_func_call` named after
>   the method with a `vpiPrefix` `ref_obj` named after the BASE — and the
>   index is neither in the name nor an argument, while the written arguments
>   survive and bind;
> * the index TEXT the path NAME carries is `CompileHelper::decompileHelper`'s,
>   the same closed dispatch § `dottedIdxRecvFromSyntax23` transcribes, so
>   `q[f()]` renders `q[]` here exactly as it does there.
>
> The gate is ONE bit-select subscript on a plain base identifier, with
> § `droppedCall14`'s own argument narrowness applied unchanged.  Two
> subscripts, a part-select and every argument shape § 14 refuses ABSTAIN, and
> the pre-existing unwrap then stands byte for byte.

## 4. DECODED FROM SURELOG (`~/git-repos/Surelog`), NOT INFERRED

* **EXPRESSION** — `CompileExpression.cpp:5455` mints the `hier_path`; its
  `while (dotedName)` loop walks the written path.  A `paSelect` /
  `paBit_select` step (`:5514-5546`) pushes what `compileSelectExpression`
  builds for the base name — a `bit_select` named for the BASE — and appends
  `decompileHelper(select)` to the running `the_name`.  An `slStringConst` step
  (`:5504-5512`) appends `"." + name`.  The `paMethod_call_body` /
  `paList_of_arguments` step (`:5611-5691`) pushes a `method_func_call` named
  `fC->SymName(dotedName)` carrying `compileTfCallArguments`, parented AT THE
  PATH.  `:5706-5710` stamps `the_name` as the path's VpiName/VpiFullName and
  collapses a ONE-element path to that element.  **No member lookup anywhere in
  that loop** — which is the whole reason golden has an object here at all.
* **STATEMENT** — `CompileHelper::compileTfCall`'s user-call arm
  (`CompileHelper.cpp:4216-4241`): `name = SymName(tfNameNode)` is the BASE;
  `Constant_bit_select = fC->Sibling(tfNameNode)` is the subscript and is
  **skipped**, `tfNameNode = fC->Sibling(Constant_bit_select)` is the METHOD;
  the object is a `method_func_call` at the method with a `vpiPrefix` `ref_obj`
  at `dollar_or_string`; and `argListNode = fC->Sibling(tfNameNode)` (`:4318`)
  is the WRITTEN argument list.  The index is read by nothing.

## 5. THE GOLDEN GRIDS — BOTH VIEWS, BROKEN 0 EVERYWHERE

See `GRID.txt` for the cell-by-cell tables.  In one line:

```
g26b.sv (the DROPPED family)  default  CELLS 82  FIXED 21  BROKEN 0
                              elab     CELLS 82  FIXED 24  BROKEN 0
g26.sv  (the VALID family)    default/elab  FIXED 0  BROKEN 0 — and the whole
        DATABASE is byte-identical between the two binaries in both views.
```

`g26.sv` byte-identity (md5 `1a107ba6…` def, `91816fc9…` elab, pristine ==
patched) is the load-bearing negative control: the twenty-odd shapes the VALID
`x[k].m()` path already gets right — assoc/queue/dynamic/fixed receivers, class
handles, `+=`, `<=`, module `initial`, `always_comb`, tasks, package functions,
out-of-body methods, two instances of a parameterized module — do not move.

## 6. CENSUS AND MOVER PREDICTION (see CENSUS.txt)

Predicted **from the pristine databases only, BY NAME, before the patched
sweep**, over all 2314 of them: the site's shape appears in 9 surelog
row-modes and **0 / 1358** u2r row-modes.  Realized: `BuildUVMPkg` default and
testflags, exactly as predicted; the eight uvm-1.2 `maps[...]` row-modes carry
the shape but not the slang state, so their databases are byte-identical before
and after (**residue R-MAPS**).  The prediction is an upper bound by
construction and the realized set is a subset of it.

`BuildUVMPkg` two-element `[bit_select, method_func_call]` hier_paths:
golden 358, ours pristine 357, ours patched **358**, remaining predicted
sites 0.

## 7. FIVE GATES AND THE FULL BOUNDARY

`GATES.txt` has the numbers; `BOUNDARY.txt` has the 9448-cell four-way
boundary and the NULL-CONTROL proof for its one non-law mover.  In one line:
build, goldens 23/0 with the `/bin/false` negative control 0/23, both
full-corpus sweeps with **0 differing ROWS** against both the committed
baselines and the pristine controls, byte attribution (u2r 0/1358; surelog 3/956
= the two predicted `BuildUVMPkg` modes plus the documented Scoreboard/default
list-order coin, 92 ordered dump lines and **zero order-blind** lines), all
canaries and pins, and the four-way boundary with `PROCESSED == LISTED`, zero
asymmetric rejects and no earlier law arm moved semantically.

`BuildUVMPkg` attribution: the order-blind path-normalised dump diff is 26
lines and **every one of them is at `uvm_pkg.sv:45158`**.

## 8. NEW R0 AND RESIDUES

**R0** — the new `BuildUVMPkg` head, both modes, 76 lines, one head, cmp logs
byte-identical between modes, at `uvm_pkg.sv:58066` inside
`uvm_tlm_generic_payload::do_compare`:

```systemverilog
void'(comparer.compare_field_int(name , m_data[i] & be, gp.m_data[i] & be,
                                 $bits(m_data[i] & be), UVM_HEX));
```

Golden's fourth argument is a **`constant`** — `vpiDecompile:8`, `vpiSize:64`,
`UINT:8`, `vpiConstType:9` — parented at the `method_func_call
(compare_field_int)`; ours is the unfolded `sys_func_call ($bits)` over the
`operation` `m_data[i] & be`.  So Surelog CONSTANT-FOLDS `$bits` of a
bit-select-and-mask expression at compile time (`m_data` is
`uvm_tlm_generic_payload::m_data`, a `byte unsigned` dynamic array, so
`$bits(m_data[i] & be)` is 8) where we keep the call.  The field is `VpiType`
again.  The next pass should decode Surelog's `$bits` reduction
(`ExprEval` / `compileExpression`'s `paSystem_task` arm with `Reduce::Yes`) and
find which `$bits` operands fold and which stay, then gate on that.

**Residues this pass measured and deliberately left**

* **R-2SUB** — a TWO-subscript receiver (`aa29[nm][nm].get_comp()`): golden's
  path carries a second, UNNAMED `bit_select`; we emit a `var_select`.  The
  VALID path is wrong in the same way (`g26.sv` C18), so it is ONE residue in
  two places and belongs to a shared fix.
* **R-TRAILMEM** — a trailing member on the call (`as29[nm].self29().v`):
  golden appends a further UNNAMED `method_func_call`.  On the VALID path the
  same spelling gives us a **NULL `Rhs`** (`g26.sv` C7), which is worse and is
  the more urgent half.
* **R-IDXPFX** — golden scopes a hier_path element's INDEX ref through the PATH
  NAME in the ELAB listing (`…::e1::as29[nm].get_comp::nm`) and through the
  plain subroutine scope in the DEF listing; we use the plain scope in both.
  `VpiFullName` is read by NO generated `Compare` — byte identity only.
* **R-MAPS** — the eight uvm-1.2 row-modes whose `maps[j].get_full_name()` /
  `maps[read_from].get_full_name()` show golden's two-element hier_path against
  our bare `bit_select` but that this arm does not reach.  Same observable, a
  different slang state; the natural next probe for this family.
* **R-G22RANGE** — `r10buvm22repro/g22.sv`'s associative/dynamic array typedef
  RANGE-BOUND constants (`22235321` -> `22243513`, +8192 each) track the
  BINARY, not any law: a pre-existing uninitialised/layout-dependent read in
  the array-typespec range emitter.  Proved with the null-control binary; see
  BOUNDARY.txt.
* **buvm25's loop-variable residues, RE-RANKED.**  They did not move and this
  pass did not touch them.  Ranked by how close each is to a decoded rule:
  1. `BuildUVMPkg`'s `init_sequence_library`'s `i` — `int_var` where golden has
     `array_var`.  This is § `foreachPkgClassArrayVar25`'s own rule applied to
     a NON-class element type, so it is the closest to already-decoded and the
     cheapest next loop-variable cell.
  2. `BuildUVMPkg`'s `pred` — `array_var` vs golden's `class_var`: the
     INVERSE direction, so it separates "typed from the ARRAY" from "typed from
     the ELEMENT" and would settle the rule's boundary.
  3. `next_pred` — `int_var` vs `class_var`: the same question with a third
     kind, and the least constrained of the three.
  4. the `g25` scalar/aggregate and associative cells — measured, but a wider
     family than any single head, and none of them is a corpus head today.
* **buvm24's R-MIXED / R-ASSOC and buvm23's R-D / R-A** — unchanged and
  untouched; nothing this pass measured bears on them.

## 9. REPRODUCE

```bash
bash build26.sh /tmp/r10buvm26cen              # the corpus census program
bash predsweep26.sh <control-workdir> /tmp/r10buvm26cen <out>   # mover prediction
bash sweeps26.sh <binary> <workroot> <repo worktree>            # both corpora
bash boundary26.sh <probe-copy> <out> file|dir def|elab <pris> <pat>
python3 gridscore26.py <golden.dump> <pristine.dump> <patched.dump> [--full]
python3 asgcen26.py <dump> <tag>               # assignment Rhs/Lhs shapes
python3 gridcen26.py <a.dump> <b.dump> [--full]
```
