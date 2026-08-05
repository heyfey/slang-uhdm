# r10uvm20 — UVM pass 20

Three laws, gated clean, **0 movers**.  UVM-4 body residue **16019 -> 15844
(-1.1%)**, every one of the four tests down, and the pass-19 residue's ranked
#2 — `§ foreachLoopVarIsRefTs19`, "DECODED but BLOCKED" — is **closed**: the
475 `array_var vs class_var` / `array_var vs int_var` rows are gone, together
with the 191-row reverse family the first half of the fix created and the
283-row binding family the second half exposed.

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL |
|---|---|---|---|---|---|
| HEAD 09c0984 | 2976 | 2866 | 5933 | 4244 | 16019 |
| + § foreachLocalArrayVar20 + § foreachAssocIdxLocalOnly20 | 2973 | 2863 | 5924 | 4235 | 15995 |
| + § foreachLoopVarBindArray20 | **2953** | **2840** | **5870** | **4181** | **15844** |

Gates run on the final tree: goldens 23/23, u2r testflags (732 rows) and
Surelog both-modes (1589 rows) **byte-identical** to the committed baselines
(`diff | wc -l` = 0 for each).  Canaries unchanged including the `dump` column.

Measure with (from this worktree, `SLANG_UHDM` exported):

    python3 scripts/verify_golden.py --corpus surelog --mode default \
      --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
      --out /tmp/r10uvm20_u4.csv --workdir /tmp/r10uvm20_u4w --jobs 2
    R10B=<r10uvm7b build>  tools/probe/r10uvm19m.sh      # per-test residue
    R10B=<r10uvm20b build> tools/probe/r10uvm19rank.sh 25

---

## Purpose-built pairs

Run one with `tools/probe/r10uvm13run.sh <dir>` (needs `SLANG_UHDM` exported).
Copy the directory somewhere writable first — the runner drops `gd/ge` (golden
def/elab), `sd/se` (ours) and their `uhdm-dump` text next to `t.sv`.

Read the loop-variable census off a pair with

    g++ -O2 -std=c++20 -I$HOME/.local/include -o /tmp/p tools/probe/r10uvm20a.cpp \
        -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread
    /tmp/p ge.uhdm       # golden, every view
    /tmp/p se.uhdm       # ours

| dir | what it pins |
|---|---|
| t30 | the FOREACH LOOP-VARIABLE matrix: {queue, dynamic, fixed, associative} x {int, string, class handle, packed struct}, in FOUR owner contexts (class-method local, class property, module-task local, module variable) — 64 arms, both views |
| t31 | the two controls t30 cannot answer: subroutine FORMAL arrays (all four kinds, `ref`/`input`, int and class element) and the ISOLATED `task tone; int lq[$];` / `task ttwo; int tq[5];` / `function int fone; int rq[$];` triple |

## The measured matrix (golden, identical in DEFMOD and ELABMOD)

t30, module-task LOCALS (`tloc`) and module VARIABLES (`tmod`):

| array kind | local (`t_*`) | module variable (`m_*`) |
|---|---|---|
| `T q[$]`   | `array_var array_typespec''` | element var (`int_var` / `string_var` / `class_var 'Cel'` / `struct_var 'st_t'`) |
| `T d[]`    | `array_var array_typespec''` | element var |
| `T f[4]`   | `array_var array_typespec''` | element var |
| `T a[string]` | `string_var` — the INDEX | element var |

and the element type does **not** matter in the local column: all four of int,
string, class handle and packed struct give the same bare `array_var`.

t31 controls:

| shape | golden loop var |
|---|---|
| `task automatic tformal(ref int fq[$], ref int fd[], input int ff[4], ref int fa[string])` | `int_var` — all four, the ELEMENT |
| `task automatic tformalc(ref Cel cq[$], ref Cel ca[string])` | `class_var 'Cel'` — both |
| `task tone; int lq[$];` | `array_var array_typespec''` |
| `task ttwo; int tq[5];` | `array_var array_typespec''` |
| `function int fone; int rq[$];` | `int_var` |

The `fone` cell is **not** an exception to the rule — it is the rule reading a
different declaration.  Golden compiles a FUNCTION-local `int rq[$]` as a bare
`int_var` (`vpiAutomatic:1`, parented at the `function`, the unsized dimension
lost), where the same declaration in a TASK is the `array_var` + inner
`int_var` pair parented at the body `begin`.  We already reproduce both
declarations; only the loop variable had to follow them.

## The law

Surelog's loop variable is built by `swapForSpecifiedVar`
(`UhdmWriter.cpp:2490`), which runs over the `needLateTypedefBinding` list: for
a `ref_var` loop variable still carrying its compile-time
`unsupported_typespec`, it re-resolves the ARRAY's bare NAME through
`decodeHierPath` and feeds the result to `getSimpleVarFromTypespec`
(`CompileType.cpp:78`).  That function's `uhdmarray_typespec` arm is the whole
story:

```c++
case uhdmarray_typespec: {
  array_typespec* atps = (array_typespec*)spec;
  if (ref_typespec* atps_rt = atps->Index_typespec()) {
    if (typespec* indextps = atps_rt->Actual_typespec())
      return getSimpleVarFromTypespec(indextps, packedDimensions, compileDesign);
  } else {
    UHDM::array_var* array = s.MakeArray_var();      // fresh, EMPTY array_typespec
    ...
  }
}
```

So: **the loop variable is `getSimpleVarFromTypespec` of whatever typespec the
array's DECLARATION object carries** — an `array_typespec` with an index
(associative local) recurses into the index, an `array_typespec` without one
becomes an `array_var`, and anything else (a formal's `io_decl`, a module
signal, a function-local that lost its dimension) becomes that type's simple
var.  Every cell of both tables follows from that one sentence, and the emitter
now keys off the DECLARATION we emitted (`arrayVarArrayTs`) rather than
predicting a class from the slang type.

## Status after pass 20

t31 is down to one row in each view (`fone`'s array REFERENCE typespec: golden
`int_typespec` — the declaration it lost the dimension on — where we still bind
the `array_typespec`; ranked for pass 21).  t30 keeps three declaration-level
families that are NOT loop-variable bugs and were invisible before this matrix
existed:

| n (per view) | what |
|---|---|
| 4 | a subroutine-local ASSOCIATIVE array is an `array_var` in golden; we emit a `logic_var` |
| 3 | a subroutine-local FIXED array of string / class handle / packed struct gets the wrong ELEMENT typespec (`logic`/`bit`) |
| 4 | `Stmt array_typespec vs <null>` — the assoc locals' array reference |

## The three laws as implemented (`StmtEmit.cpp`, the `Foreach` case)

### § foreachLocalArrayVar20

The loop variable of a foreach over a **subroutine-local, non-associative**
unpacked array is an `array_var` carrying the DECLARATION's own
`array_typespec` (`arrayVarArrayTs`), whatever the element type.  This
generalises the pass-9 `tfLocalArrayTs9` branch (fixed-size only) to queues and
dynamic arrays, and it keys off the emitted declaration rather than the slang
type — which is what makes the `fone` cell fall out for free.  `tfLocalArr20`
is the scope test: a `SymbolKind::Variable` whose parent-scope chain reaches a
`Subroutine` through nothing but `StatementBlock`s.  **-24 with the next law.**

### § foreachAssocIdxLocalOnly20

§ foreachAssocIndexVar19's "the loop variable of an associative array is its
INDEX" is a **subroutine-local** rule.  Pass 19 applied it to every resolved
associative array; t31 shows a FORMAL drills to the element (`ref int
fa[string]` -> `int_var`, `ref Cel ca[string]` -> `class_var 'Cel'`) and t30
shows a MODULE variable does too (`Cel m_a_cls[string]` -> `class_var`).  Only
a subroutine local hands `getSimpleVarFromTypespec` an `array_typespec` with an
`Index_typespec` to recurse into.  The unresolved-class arm keeps its own
§ foreachAssocIdxImporterView19 gate.

### § foreachLoopVarBindArray20

The § foreachLoopVarObjs9 bindable registration is widened to the `array_var`
shape.  The moment the loop variable stopped being the drilled element var, 283
`array_var vs <null>` rows appeared — golden binds the array_var object in body
references exactly as it binds an `int_var`.  Registering it is worth **-151**
on its own and improves all four tests; pass 19's warning about widening to
*every* resolved kind (string/bit/logic) still stands and is untouched.

---

## Delivered for pass 21

### The presence census (`tools/probe/r10uvm20b.cpp`, `mode=pres`)

The pass-19 residue's ranked **#1** was "io_decl PRESENCE 880+753 both
directions — split against our full element set first (golden-only = wrong-bind
/ no-bind / OBJECT ABSENT)".  `mode=pres` indexes BOTH serializers by
`(VpiName, line, col)` and by name, and classifies every presence row as
`ABSENT` / `NOLOC(n)` / `KIND=<kinds at that exact span>`.  Run it with
`tools/probe/r10uvm20pres.sh`.  The answer, over the UVM-4:

| n | row | verdict |
|---|---|---|
| 745 | `Stmt <null> vs io_decl` | `KIND=io_decl` |
| 557 | `Stmt io_decl vs <null>` | `KIND=io_decl` |
| 156 | `Stmt io_decl vs <null>` | `KIND=io_decl` x26 (ambiguous key — 26 per-view clones) |

**Not one io_decl row is an emission gap.**  In every direction the io_decl the
other side names exists over here at the same span; the block is entirely a
BINDING-POLICY difference — which view's `io_decl` object a body reference
binds — i.e. the same family as § cloneStmtHomeVarRef17, not a missing-object
family.  That reframes the largest remaining block and rules out the "OBJECT
ABSENT" third of the hypothesis outright.

The same census splits the rest of the head:

| n | row | verdict | reading |
|---|---|---|---|
| 558 + 366 | `Stmt` / `Variables` `package vs <null>` | `KIND=package,package` | golden resolves a reference to the PACKAGE object; both our package views exist |
| 550 + 392 | `<null> vs class_typespec` | `ANON` | an anonymous class_typespec we emit and golden does not |
| 398 + 171 | `Stmt function vs <null>` | `KIND=function` x2 / x4 | binding policy, not presence |
| 369 + 363 | `Stmt logic_net vs <null>` | `KIND=ref_obj` x2 / x4 | golden mints an IMPLICIT NET where we leave a `ref_obj` |
| 236 / 140 | `<null> vs class_var` / `string_var` | `KIND=<same>` | ours over-binds |
| 196 | `Io_decls <null> vs enum_const` | `KIND=enum_const,enum_const` | binding |
| 127 + 116 + 123 | `Io_decls`/`Stmt` `<null> vs constant`/`operation` | `ANON` | extra unnamed defaults on our side |

### Ranked residue after this pass

`ANON`/`BOTH` rows are property differences, `KIND=` rows are binding
differences, `ABSENT` rows would be emission gaps — and there are none in the
head.

| n | pair | note |
|---|---|---|
| 745 + 557 + 156 | io_decl presence, both directions | **binding policy**, see the census above |
| 558 + 366 | `package vs <null>` | binding |
| 550 + 392 | `<null> vs class_typespec` | ours-only anonymous typespec |
| 460 + 319 | `Return`/`Variables` `class_typespec vs class_typespec` | **VpiName** — golden names a class-handle return's typespec after the TYPEDEF; the context-dependent-naming minefield, pair-decode first |
| 398 + 171 | `function vs <null>` | binding |
| 387 / 330 | `Stmts` / `Io_decls` SIZE | |
| 369 + 363 | `logic_net vs <null>` | implicit-net synthesis |
| 366 | `Stmt constant vs constant` | |
| 304 | `constant vs hier_path` | |
| 237 | `Stmt array_var vs int_var` | **§ foreachClassPropArrayVar20 — decoded, gate unknown** (see the `StmtEmit.cpp` note); shipping it ungated trades these 237 for 139 in the reverse direction |
| 214 + 175 + 115 | `unsupported_typespec vs class_typespec` | |
| 195 + 194 | `ref_var vs hier_path`, `hier_path vs hier_path` | |
| 30 | `Stmt constant vs operation` | still all that is left of the pass-18/19 fold family: 11 range rows (a package STRUCT typedef's MEMBER typespec reads the def listing in the elab view) + 19 `return -1` unary-minus folds |
