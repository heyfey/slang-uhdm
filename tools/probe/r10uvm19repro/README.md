# r10uvm19 — UVM pass 19

Four laws, all gated clean, **0 movers**. UVM-4 body residue **16645 -> 16019
(-3.8%)**, and the pass-18 residue's ranked #1 — the statement-tree twin of
`pkgTdRangeViewFold18` — is **closed**: `constant vs operation` range rows
332 -> 11, with **zero** rows in the reverse direction.

Measure with (from this worktree, `SLANG_UHDM` exported):

    python3 scripts/verify_golden.py --corpus surelog --mode default \
      --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
      --out /tmp/r10uvm19_u4.csv --workdir /tmp/r10uvm19_u4w --jobs 2
    R10B=/tmp/r10uvm19_b tools/probe/r10uvm19m.sh        # per-test residue
    R10B=/tmp/r10uvm19_b tools/probe/r10uvm19rank.sh 25  # ranked pairs
    tools/probe/r10uvm19cls.sh "constant vs operation"   # range vs expression
    tools/probe/r10uvm19fe.sh                            # foreach loop vars

## The laws

### § retVarTdViewFold19 — the return variable a BODY REFERENCE binds

Pass 18 made every DECLARATION of a bare package-typedef type (formal, return,
body local) carry the listing object **of its view**. The variable a body
*reference* to the function's own name binds did not follow: `drainFuncRet`
(`ModuleEmit.cpp` ~18205) always takes `typedefTs` — the DEF listing, whose
packed range is the symbolic operation — so every `uvm_reg_cvr_t
build_coverage()` reference in ELABPKG, DEFMOD and ELABMOD alike read a
symbolic bound where golden reads the folded one. The aggregate kinds already
had the swap (`topPf1 -> pkgTopTypedefTs`) and `logic` its per-reference clone
arm; `bit` fell through both.

The view cannot be read at drain time — `drainFuncRet` runs after every package
is emitted — so it is captured at PUSH time (`PendingFuncRet::tdOwnDefView19`,
`TaskFuncEmit.cpp` ~3430) with pass 18's own `pkgTdOwnDefView` predicate, while
`curPkgEmitSym`/`pkgEmitTopView`/`pkgClassTfClone` still describe the body being
walked. **-134.**

### § pkgTdRangeViewFold18, the UNPACKED-ARRAY-ELEMENT half

`ref uvm_reg_addr_t addr[]` inherits the typedef's packed range through its
ELEMENT, and the element arm (`TaskFuncEmit.cpp` ~2279) applied neither half of
the law: not the range (`tfContext`) and not the alias target (always
`typedefTs[e0]`). Both added, exactly as the bare-alias arm one branch up.
**-218.**

### § pkgTdRangeViewFold18, the arrayElemTypedefTs15 half

`makeTypespec`'s § arrayElemTypedefTs15 shortcut (`TypeEmit.cpp` ~402) — the
one that types `addr_t dyn[];` on the typedef's own object — returned the DEF
listing in **every** view. The scalar share path one branch up already answers
the same view question; the element path now does too (`pkgTopTypedefTs` unless
`pkgTdOwnDefView`). The pass-15 note it sits under is about the element's NAME,
which both objects now spell identically. **-13** (rows mostly moved one level
deeper rather than disappearing; the range family fell 33 -> 11).

### § foreachAssocIndexVar19 + § foreachAssocIdxImporterView19

An ASSOCIATIVE array's foreach loop variable is its **INDEX**, not its element
(LRM 12.7.3): golden types `foreach (m_children[i])` over `uvm_component
m_children[string]` as a `string_var` and `foreach (m_maps[map])` over `bit
m_maps[uvm_reg_map]` as a `class_var` NAMED for the key class, where the
`classPropArr9` rule leaves us the bare int default. The r10c4 probes could not
see this — an `int q[$]`'s element type and the int fallback are the same object
kind.

**And it fires only when ANOTHER PACKAGE of the design wildcard-imports the
class's home package.** This is the pass's sharpest measurement, and it came out
of a regression: implementing the index law unconditionally fixed SeqDriver's
423 rows and *created* 324+88 in the opposite direction on the other three.
`tools/probe/r10uvm19c.cpp` on the four goldens shows why — the SAME shared body
object, in every elab view at once:

| golden | `uvm_component::get_children` loop var | design has a package importing `uvm_pkg` |
|---|---|---|
| SeqDriver | `string_var string_typespec''` | yes (`package adpcm_pkg; import uvm_pkg::*;`) |
| SimpleUVM | `int_var int_typespec''` | no (only a `$unit` import) |
| Scoreboard | `int_var int_typespec''` | no (`svunit_pkg` imports nothing) |
| BuildUVMPkg | — | no (uvm_pkg alone) |

The ARRAY reference stays the unresolved `unsupported_typespec 'm_children'` in
**both**, so the loop variable resolves through the importing package's
re-elaborated symbol table and not through the iterated reference. The
DEF listings agree everywhere (`ref_var`), and so does the import CLONE listing
inside `adpcm_pkg` — only the HOME package's elaborated body flips.

Second half: once the loop variable stops being an `int_var`, the § foreachLoopVarObjs9
bindable registration drops it, and 235 `class_var vs <null>` + 41 `string_var
vs <null>` rows appear. Golden binds the resolved index object exactly as it
binds an int_var, so the registration is widened to this shape and nothing else.
**-60 then -201.**

## Measured (UVM-4, default mode, body residue via r10uvm7b)

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL |
|---|---|---|---|---|---|
| HEAD 0999231 | 3038 | 2926 | 6308 | 4373 | 16645 |
| + § retVarTdViewFold19 | 3022 | 2907 | 6263 | 4319 | 16511 |
| + unpacked-array-element half | 2981 | 2868 | 6194 | 4250 | 16293 |
| + arrayElemTypedefTs15 half | 2976 | 2866 | 6194 | 4244 | 16280 |
| + § foreachAssocIndexVar19 (gated) | 2976 | 2866 | 6134 | 4244 | 16220 |
| + bindable widening | 2976 | 2866 | **5933** | 4244 | **16019** |

`constant vs operation`, split by `r10uvm19cls.sh`:

| | range family | other |
|---|---|---|
| HEAD | 332 | 19 |
| after the three fold halves | **11** | 19 |
| reverse direction (`operation vs constant`) | 0 | 15 |

Gates run **three times** (after the fold halves, after the foreach law, and on
the final tree): goldens 23/23, u2r testflags (732 rows) and Surelog both-modes
(1589 rows) byte-identical to the committed baselines every time. Canaries
(LowMemPkg, InterfaceModExp, FuncStruct, FuncStructVal, Scr1SvTests,
jeras_union, EvalFunc) unchanged including the `dump` column.

## Tools

* `r10uvm19a.cpp` — r10uvm15c plus `tree` mode: for each failing pair it prints
  the WHOLE expression on both sides (operands, each ref's `vpiActual`, each
  expr's resolved typespec) **plus the golden side's VpiParent CHAIN**, and
  takes a 5th argument filtering to one `"<Lkind> vs <Rkind>"`. The parent chain
  is what turned "244 `constant vs operation` rows" into "these live in a
  typespec RANGE, under a package listing on one side and a per-occurrence clone
  on the other" in one look.
* `r10uvm19b.cpp` — STATEMENT-TREE typespec census (r10uvm18a projects the
  DECLARATION side). Walks a task_func's Stmt tree and prints, for every expr
  and every `ref_obj`'s `vpiActual`, the resolved typespec's identity, its
  packed-range LEFT bound and its VpiParent kind — "listing object or
  per-occurrence clone?" is the whole question § retVarTdViewFold19 asks.
* `r10uvm19c.cpp` — FOREACH LOOP-VARIABLE census: per view, the loop variable's
  object kind and typespec next to the ITERATED reference's typespec. The
  importer-view law was read straight off it.
* `r10uvm19{m,p,rank,fe,cls}.sh` — the measuring set; all derive their siblings
  from the script's own path.

Build the probes with:

    g++ -O2 -std=c++20 -I$HOME/.local/include -o /tmp/r10uvm19_t \
        tools/probe/r10uvm19a.cpp -L$HOME/.local/lib64 \
        -luhdm -lcapnp -lkj -lpthread

## Ranked residue for pass 20 (UVM-4, after this pass)

| n | pair | note |
|---|---|---|
| 880 + 753 | `Stmt` io_decl vs `<null>` / `<null>` vs io_decl | presence, BOTH directions — untouched by this pass. Split against the full element set first (golden-only = wrong-bind / no-bind / OBJECT ABSENT) |
| **475** | `Stmt` array_var vs class_var (238) + array_var vs int_var (237) | **§ foreachLoopVarIsRefTs19 — DECODED, not implemented.** Surelog does NOT drill: the loop variable is `getSimpleVarFromTypespec` applied to the typespec the ITERATED REFERENCE carries, so a reference resolved to an `array_typespec` yields an `array_var` SHARING that object (golden `array_var array_typespec''` over `ref_var 'vfields' ts=array_typespec''` for SeqDriver's `uvm_vreg_field vfields[$]` local; we drill to the element and emit class_var). The tfLocalArrayTs9 branch already states the special case. BLOCKER: for exactly these subroutine locals the reference's own typespec is bound in a LATER pass (`pendingForeachArrayTs`), so the VARIABLE'S CLASS has to be predicted from the slang type — and that prediction is what the r10c4 `int lq[$] -> int_var` pin constrains, with no corpus test covering it. Needs a purpose-built pair over {queue,dynamic,fixed,assoc} x {int,string,class,struct} element. A no-op attempt that only used the already-bound case moved 0 rows and was reverted. |
| 696 | `Stmt` logic_net vs `<null>` | presence |
| 600 | `Stmt` function vs `<null>` | presence |
| 570 + 491 + 471 + 448 | `Stmt` `<null>` vs class_typespec / class_var / ref_obj / string_var | presence, ours-only |
| 559 + 366 | `Stmt` / `Variables` package vs `<null>` | presence; a Variables-SIZE problem, not an instance one |
| 460 + 319 | `Return` / `Variables` class_typespec vs class_typespec | **VpiName**, and the property is uniform: golden NAMES a class-handle return's typespec after the TYPEDEF (`type_id`, `adpcm_pkg::this_subtype`, `uvm_pkg::uvm_event_pool`) where we leave it empty. Cheap to try, but this is the "naming is context-dependent" minefield — build the pair first |
| 459 | `Io_decls` `<null>` vs ref_obj | presence |
| 387 / 330 | `Stmts` / `Io_decls` SIZE | |
| 366 | `Stmt` constant vs constant | |
| 317 + 187 | `Stmt` ref_var vs `<null>` / ref_var vs hier_path | the OTHER foreach loop-variable families (`r10uvm19fe.sh`); same cluster as the 475 above |
| 304 | `Stmt` constant vs hier_path | |
| 264 | `Io_decls` `<null>` vs enum_const | |
| 30 | `Stmt` constant vs operation | ALL that is left of the pass-18/19 fold family: 11 range rows (a package STRUCT typedef's MEMBER typespec still reads the def listing in the elab view — `uvm_reg_bus_op.addr`, the aggregate twin of § arrayElemTypedefTs15) + 19 genuine expressions (`return -1` folds its unary minus in golden, we keep `op1(1)`) |
