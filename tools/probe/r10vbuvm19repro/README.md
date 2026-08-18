# r10vbuvm19 — the ADVERSARIAL VERIFICATION of § `foreachArraySelfSelectAssignDropsTs19`

**MEASUREMENT-ONLY probes.** The official `uhdm-cmp` and
`scripts/verify_golden.py` are the only judges. slang was **not** patched,
`results/*.csv` were **READ ONLY**, nothing was promoted.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `bab1c2e` |
| worktrees | `/tmp/wt_vbuvm19` (patched+fix), `/tmp/wt_vbuvm19pris` (pristine) |
| pristine binary | md5 `7e9bfebd45e988d63767a207a6ff168c` |
| implementer's patched binary | md5 `1d1cb908cc3dd8000d80661eecbc22de` |
| **verified binary (this dir's clause added)** | md5 `0766980d0ea1515706fc8ca6e34e1300` |
| deliverable | `/tmp/r10buvm19.verified.patch` |

## VERDICT: ACCEPT-WITH-FIX

Every headline number in the implementer's report reproduced **bit for bit**
(both binary md5s, the 17-line / `2bb940e8dd2d` pristine head, the 152-line /
`23df339e1b17` new head, 9/956 + 0/1358 movers, 0 differing rows on both
corpora, `PROCESSED=2868 DIFFER=1`). The law survived a 138-cell adversarial
grid over shapes, ancestors and homes with **zero** over-fire.

It did **not** survive the IMPORT axis. One family is
**pristine-RIGHT -> patched-WRONG on legal SV**:

> a **PACKAGE-LEVEL VARIABLE** iterated by a `foreach` in a package-homed
> subroutine, when a **MODULE or INTERFACE** writes `import p::*;`.
> Golden RESOLVES the reference to the variable's real `array_typespec`
> (`lateTypedefBinding`'s `func->Instance()` -> `pack->Variables()` arm);
> pristine matched golden EXACTLY; the shipped patch dropped the typespec.

`vg19j.sv` splits the axis: wildcard-imported by a module (`vjb19`, over-fire)
/ by an uninstantiated module (`vja19`, over-fire) / not imported (`vjc19`,
converts) / **EXPLICIT** named import (`vjd19`, converts) / class property under
a wildcard import (`vje19`, converts). `vg19k.sv` adds an INTERFACE importer
(over-fire) and shows FORMALS (`vkc19`) and subroutine LOCALS (`vkd19`) are
immune. `vg19l.sv` shows it fires from a class METHOD over a package variable
too. `vg19i{1,2,3}.sv` are the 1..3-instance axis — the flip is independent of
instance count.

**THE FIX** (`src/StmtEmit.cpp`, one clause): a package-level variable is
excluded from the law. Golden's answer for one is CONTEXT-DEPENDENT and the
emitter cannot see the importer set from the subroutine it is emitting, so the
safe reading keeps pristine behaviour there. **All 20 corpus cells this law
moves are CLASS PROPERTIES** (`m_object_references`, `m_executing_phases`), so
the clause is **INERT on both corpora** — the head still clears — and formals,
class properties and subroutine locals still convert.

## THE GRIDS (each run three-way: golden / pristine / patched, both views)

| file | axis | verified-binary verdict |
|---|---|---|
| `vg19a.sv` | HOMES: package fn/task, class in-body/OOB/static in-body/static OOB, module fn/task/initial/always, generate, interface, program | 21 cells, 3 CONVERTED, **0 OVER-FIRE** |
| `vg19b.sv` | SHAPES + ANCESTORS: 2-D fixed, 2-D assoc, TWO loop vars, packed-struct array, typedef'd assoc, enum-keyed assoc, queue, dynamic, range-select LHS, member LHS, compound `+=`, concat LHS, nonblocking, `$size()` index, nested foreach, shadowing inner decl, while/for/case/forever/fork-join ancestors, decl-outer-assign-inner, `super.` LHS, package-qualified LHS | 50 cells, 17 CONVERTED, **0 OVER-FIRE** |
| `vg19c.sv` | OOB + in-body CONSTRUCTORS, `this.`-qualified header, package-qualified header, `$unit` function, wildcard + EXPLICIT import clones, instantiated program/interface | 21 cells, **0 OVER-FIRE** |
| `vg19d.sv` | the qualified-header family (cross-package, own-package, header-vs-assignment) | 8 cells, **0 OVER-FIRE** |
| `vg19e.sv` / `vg19e2.sv` | class-qualified and `super.`-qualified headers, method-call ancestor, `for`-init assignment, queue `$` index | 10 cells, **0 OVER-FIRE**, 2 MOVED-STILL-WRONG (residue R-A) |
| `vg19f.sv` | DECLARATION forms: static / automatic / named-block / initialized / typedef'd / const locals (the `Variables()`-before-`Stmts()` boundary) | 14 cells, **0 OVER-FIRE** |
| `vg19m.sv` | struct-keyed assoc, unpacked array of unpacked struct, 3-D unpacked (three loop vars), queue-of-assoc | 8 cells, 4 CONVERTED, **0 OVER-FIRE** |
| `vg19g.sv` | ancestor chains THROUGH a foreach: inner foreach under an outer whose body assigns the same / another array, 3-deep named blocks, `ref` task formal, `disable` | 14 cells, 5 CONVERTED, **0 OVER-FIRE** |
| `vg19j/k/l.sv` | **the IMPORT axis** — the family the fix closes | **0 OVER-FIRE** after the fix (2 over-fire cells before it) |
| `vg19i{1,2,3}.sv` | 1..3 instances | **0 OVER-FIRE** after the fix |

Every grid was also run with `-elabuhdm` / `--elabuhdm` on both sides; the
verdicts are identical.

## FILES

| file | what it is |
|---|---|
| `vrun19.sh` | three-way runner: Surelog golden + both binaries + `fecen19.py` + `vcmp19.py` |
| `vcmp19.py` | the view-GENERAL verdict table (the pass's own `gridcen19.sh` iterates only the two PACKAGE views, so module / interface / program / `$unit` homes were structurally invisible to it) |
| `vbounddir19.sh` | the PER-DIRECTORY boundary gate (every probe dir compiled as one unit; the per-FILE gate cannot see arms that only exist as a group) |
| `vpred19.py` | independent mover prediction + the ELABPKG contingency + a per-slot TO-GOLDEN / AWAY / STILL census over **all** views |
| `seg19.sv` | **8-line PRE-EXISTING SEGFAULT** repro (R-B): `for (pf19[0] = 0; ...)` — a `for` loop whose loop variable is a SELECT of a class property, in a package-homed class method, **`--elabuhdm` only**. `rc=139` on the PRISTINE and the patched binary alike (so not this pass's), `rc=0` in default mode, and Surelog accepts it. |
