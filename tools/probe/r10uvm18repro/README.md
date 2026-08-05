# r10uvm18 — UVM pass 18: § pkgTdRangeViewFold18 closed

The pair is `tools/probe/r10uvm17repro/t28` — pass 17 built it, decoded the law
off it and deferred the fix.  Pass 18 implements it.  **t28's body residue is
now ZERO in both views** (def and elab), from 19 rows.

Run it with `tools/probe/r10uvm13run.sh <copy-of-t28>` (needs `SLANG_UHDM`
exported; copy the directory somewhere writable first).  Measure with

    R10B=/tmp/r10uvm18_b tools/probe/r10uvm18p.sh <Test> <outdir> rows

## THE LAW (one sentence)

A package typedef's own packed RANGE bound is **view-dependent**: it stays the
symbolic operation ONLY in the typedef's HOME PACKAGE **DEF** listing, and every
other view carries the reduced constant — the elaborated package listing, a
wildcard-import CLONE's re-minted body, the package's class methods seen from
the elaborated view, and both module views.  This is the same law
`pkgParamOwnDefView` (§ pkgParamOwnDefRange) already states for a package
PARAMETER's declared range: *the def listing reduces nothing, top and import
copies reduce everything.*  The **listing objects** already obeyed it; the
**per-declaration named clones** (a formal's / return's / body local's twin) did
not, because they are built by `makeTypespec` from the SYNTAX and their fold
state followed `makeTypespec`'s ambient context instead of the listing they
alias.

`UhdmExporter::pkgTdOwnDefView(const TypeAliasType&)` (`ParamEmit.cpp`, next to
`pkgParamOwnDefView`) is the whole predicate; `pkgHomedTdAlias18` is the SITE
test — only a BARE alias inherits the typedef's range, a declaration that WRITES
its own range keeps the tf rule (§ r10fsv3 S3) untouched.

## The five things that had to be right together

Doing only one half moves nothing or moves backwards — the first cut fixed the
range in the home def view and cost +10 residue overall, because Compare simply
walked one level further into a mismatch it had been masking.

1. **The range** — `tfContext = pkgTdOwnDefView(alias)` at the typedef'd-formal
   arm (`TaskFuncEmit` ~2130), the scalar-return clone (~1550), the
   no-clone return fallback (~1660) and the body-local build (~2975).
2. **The alias target** — the clone points at the LISTING OBJECT OF ITS OWN
   VIEW.  `typedefTs` holds the DEF listing, `pkgTopTypedefTs` the elaborated
   one; a folded clone aliasing a symbolic listing is exactly the pair Compare
   reports next.  Same swap on the return share (`ts` remap after the return
   arms), widened from `pkgTopEmit` to the law so that a MODULE view — which
   also lists an imported package's functions — folds too.
3. **`pkgClassTfClone` is a DEF view.**  The def listing's `C::m` class-method
   clones are BUILT during the package's TOP pass
   (`emitPackageClassMethodClones` runs under `if (topView)`, because it needs
   the class_defns that pass just created), so `pkgEmitTopView` is true while
   they are emitted even though they belong to the DEF listing.  Two
   consequences, and BOTH were needed:
     * `pkgTdOwnDefView` returns true inside that window;
     * `makeTypespec`'s typedef-SHARE path must return the DEF object there.
       The package's own free functions get it for free — the def pass runs
       first, when `pkgTopTypedefTs` is still empty for that package — but the
       class clones ran after it was filled and bound the elaborated object.
   This single item was worth **-5.9%** on its own (17990 -> 16933): it is what
   the 371 `Io_decls | operation vs constant` and 594 `Stmt | …` rows were.
4. **The import clone re-mints FOLDED** (`importCloneBareTdAlias16`).  A
   wildcard-import clone's whole chain is re-minted against the IMPORTING
   package and re-elaborated there, so BOTH links carry the folded range even
   in the def view, where the object they replace is symbolic.  Implemented by
   minting the bare copies from the ELABORATED twin (a local def->top map over
   `typedefTs`/`pkgTopTypedefTs`) while keeping the replaced object's
   `vpiInstance`, which still tracks the view (r7's rule).
5. **§ pkgTdCloneRefNoBind18** — a bound INHERITED from a package typedef into
   a per-declaration clone is re-minted, **not re-resolved**: its ref_obj stays
   DANGLING, while the very same operand inside the LISTING object binds the
   parameter's def constant.  t28 shows both in one database:

   ```
   golden  pt@16:29   [operation]  {operation(ref_obj 'PW' -> <null>,        constant=1)}
   golden  p28::pt    [operation]  {operation(ref_obj 'PW' -> constant@10:22, constant=1)}
   ```

   Two carriers: the `tdCloneRefNoBind18` flag (guards the `pkgTsParam9` and
   `tfTypeScope` binders in `TypeEmit`) for the clones `makeTypespec` builds,
   and a range RE-MINT inside `bareScalarTdCopyOfFresh16` for LAW S's bare
   copies, which used to SHARE the listing's range vector — and therefore its
   bound ref.  The re-mint fires ONLY when the source range actually carries a
   bound ref, i.e. only in the home def view; every folded view keeps the
   shared vector and is bit-identical to before.

## § pkgClassFormalCloneInst18 (found while gating this)

A package CLASS METHOD's per-formal typedef clone carries the same
`vpiInstance` its shared-typespec formals already take (`tsInst`, the
out-of-body home package); an IN-BODY method, whose `tsInst` is deliberately
null, still names the enclosing package OF THE VIEW BEING EMITTED
(`pkgEmitTopView ? pkgTopMap : pkgDefMap`).  `stampPkgFormalTs`'s guard read
`!pkgScope || classScope` and skipped all of them.  Invisible until the range
agreed — Compare stops at the first difference — which is why it surfaced only
after items 1-3 landed.  -101 residue, and it is what closed t28's elab view.

## Measured (UVM-4, default mode, body residue via `r10uvm7b`)

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL |
|---|---|---|---|---|---|
| HEAD 7cbd6e5 | 3398 | 3290 | 6902 | 4830 | 18420 |
| + range/alias/`pkgClassTfClone` (items 1-3) | 3073 | 2969 | 6442 | 4449 | 16933 |
| + import-clone fold (item 4) | 3073 | 2969 | 6400 | 4449 | 16891 |
| + § pkgClassFormalCloneInst18 | 3046 | 2930 | 6330 | 4388 | 16694 |
| + LAW-S range re-mint (item 5) | 3042 | 2930 | 6327 | 4388 | **16687** |

**-9.4%**, all four tests moving.  The pass-17 `operation vs constant` block was
604 + 357 + 347 + 346 = 1654 rows across the four Compare slots; it is now ONE
row of 244.  Goldens 23/23, u2r testflags (732 rows) and Surelog both-modes
(1589 rows) byte-identical to the committed baselines at every step — four full
gates, one per landed item.

## Tools

* `r10uvm18a.cpp` — the instrument the whole pass was read off.  For every
  task_func in every VIEW it prints each io_decl / return / body-local
  typespec: object id, name, **packed-range LEFT-bound kind** (`operation` =
  symbolic, `const:<v>` = folded), `vpiInstance`, and the same triple for its
  `Typedef_alias` target.  `deep` adds the whole bound expression with each
  ref's `vpiActual` (this is what showed § pkgTdCloneRefNoBind18); `listing`
  prints the package's own `Typespecs` vector instead of its bodies (this is
  what proved the LISTING objects already agreed and moved the search onto the
  clones).  **View labels match `r10uvm7b`**: `AllPackages` is DEFPKG,
  `TopPackages` is ELABPKG — getting that backwards inverts the law.
* `r10uvm18{m,p,rank,cen}.sh` — the measuring set, deriving the worktree from
  the SCRIPT's own path so they do not rot when this worktree is harvested (the
  pass-15/16/17 copies each hard-coded a dead sibling).

Build the probes with:

    g++ -O2 -std=c++20 -I$HOME/.local/include -o /tmp/r10uvm18_a \
        tools/probe/r10uvm18a.cpp -L$HOME/.local/lib64 \
        -luhdm -lcapnp -lkj -lpthread

## Ranked residue for pass 19 (UVM-4, after this pass)

| n | pair | note |
|---|---|---|
| 880 + 752 | `Stmt` io_decl vs `<null>` / `<null>` vs io_decl | presence, BOTH directions — unchanged by this pass; still the "which object does this reference bind" question.  Split against the full element set first (golden-only = wrong-bind / no-bind / OBJECT ABSENT) |
| 678 | `Stmt` logic_net vs `<null>` | presence — golden binds a `logic_net 'this'` inside ELAB class methods |
| 600 | `Stmt` function vs `<null>` | presence |
| 567 + 491 + 468 + 448 | `Stmt` `<null>` vs class_typespec / class_var / ref_obj / string_var | presence, ours-only |
| 550 + 366 | `Stmt` / `Variables` package vs `<null>` | presence; the io_decl half of this family was § pkgClassFormalCloneInst18 — the REST is a Variables-SIZE problem, not an instance one (golden's `uvm_root::report_header` lists 4 body locals, ours lists none) |
| 460 + 319 | `Return` / `Variables` class_typespec vs class_typespec | VpiName, both directions |
| 459 | `Io_decls` `<null>` vs ref_obj | presence |
| 387 / 330 | `Stmts` / `Io_decls` SIZE | |
| 366 | `Stmt` constant vs constant | |
| 335 | `Stmt` class_var vs int_var | the KIND law — `CompileType`/`compileVariable`, source-first |
| 244 | `Stmt` constant vs operation | what is LEFT of this pass's family: all inside STATEMENT trees (a clone body's `uvm_transaction::is_active`, `ELABPKG[uvm_pkg]/uvm_vector_to_string`), i.e. the expression-side twin of the declaration-side law this pass closed.  The io_decl/return/local sides are DONE |
