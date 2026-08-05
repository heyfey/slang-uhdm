# r10uvm21 — UVM pass 21

Three laws, gated clean, **0 movers**.  UVM-4 body residue **15844 -> 15516
(-2.1%)**, every one of the four tests down, and the pass-20 residue's ranked
**#1** — `§ foreachClassPropArrayVar20`, "DECODED, SPLIT, NOT IMPLEMENTED,
right on two tests and wrong on the other two" — is **closed**: the second gate
it was missing is a `$unit`-scope import, and finding it also **refuted and
replaced** pass 19's `§ foreachAssocIdxImporterView19`.

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL |
|---|---|---|---|---|---|
| HEAD 2add49d | 2953 | 2840 | 5870 | 4181 | 15844 |
| + § classPropUnitImport21 + § foreachClassPropArrayVar21 | 2813 | 2840 | 5756 | 4181 | 15590 |
| + § foreachHierPathAlwaysRes21 | 2813 | 2837 | 5756 | 4172 | 15578 |
| + § classPropIterThisRefVar21 | **2800** | **2827** | **5735** | **4154** | **15516** |

Gates run on the final tree: goldens 23/23, u2r testflags (732 rows) and
Surelog both-modes (1589 rows) **byte-identical** to the committed baselines
(`diff | wc -l` = 0 for each).  Canaries unchanged including the `dump` column.

Measure with (from this worktree, `SLANG_UHDM` exported):

    python3 scripts/verify_golden.py --corpus surelog --mode default \
      --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
      --out /tmp/r10uvm21_u4.csv --workdir /tmp/r10uvm21_u4w --jobs 2
    R10B=<r10uvm7b build>  R10W=/tmp/r10uvm21_u4w  tools/probe/r10uvm19m.sh
    R10B=<r10uvm20b build> R10W=/tmp/r10uvm21_u4w  tools/probe/r10uvm19rank.sh 25

---

## THE GATE: a `$unit`-scope import of the class's home package

Pass 20 measured the class-property `array_var` arm as **RIGHT on BuildUVMPkg
(-43) + SeqDriver (-114)** and **WRONG on Scoreboard (+37) + SimpleUVM (+102)**
and could not name the discriminator.  It is this:

> **§ classPropUnitImport21** — an ELABORATED class body's foreach over a CLASS
> PROPERTY resolves its loop variable through `getSimpleVarFromTypespec` of the
> property's declaration — **unless some file of the design imports the class's
> home package at COMPILATION-UNIT (`$unit`) scope**, in which case every such
> loop variable in the whole design falls back to `int_var`.

Source-first, from Surelog: `CompileHelper::importPackage`
(`CompileHelper.cpp:194`) copies the imported package's **whole**
`needLateTypedefBinding` list into the importing scope — **unfiltered**, so
`import p::C;` copies exactly as much as `import p::*` — and
`UhdmWriter::write` runs the FileContent pass over that copy **after** the
package loop (`UhdmWriter.cpp:4991` vs `:1302`).  `swapForSpecifiedVar`
(`:2490`) overwrites the loop variable every time it is reached, so the LAST
pass wins; at file scope `decodeHierPath` cannot resolve a bare class-property
name and the `int_var` fallback at `:2550` is what lands.

The four tests line up exactly:

| test | import of `uvm_pkg` | class properties resolve |
|---|---|---|
| BuildUVMPkg | none (uvm_pkg is the whole design) | YES |
| SeqDriver | `package adpcm_pkg; import uvm_pkg::*;` and `module top_tb; import uvm_pkg::*;` | YES |
| Scoreboard | `import uvm_pkg::*;` at the top of `design.sv` | NO |
| SimpleUVM | `import uvm_pkg::*;` at the top of `testbench.sv` | NO |

### Measured BOTH DIRECTIONS on the corpus sources, one line each

`tools/probe/r10uvm21ab.sh` re-runs a UVM test under the harness's DEFAULT-mode
argv after an arbitrary edit and histograms the loop-variable kinds per view.

**SeqDriver + `import uvm_pkg::*;` prepended to `design.sv`** (nothing else
changed; SeqDriver and SimpleUVM already share a byte-identical command line):

| ELABPKG | array_var | class_var | string_var | int_var |
|---|---|---|---|---|
| SeqDriver | 900 | 630 | 180 | 12 |
| SeqDriver + $unit import | **486** | **132** | **36** | **1074** |
| (SimpleUVM, per view x6) | 486 | 132 | 36 | 1074 |

**SimpleUVM with its `$unit` import and its classes moved INTO a package** (the
SeqDriver shape, `tools/probe/r10uvm21b.py`):

| DEFMOD | array_var | class_var | string_var | int_var |
|---|---|---|---|---|
| SimpleUVM | 81 | 22 | 6 | 179 |
| SimpleUVM, classes in a package | **150** | **105** | **30** | **2** |
| (SeqDriver) | 150 | 105 | 30 | 2 |

## The purpose-built matrix (t32a..t32g)

Run one with `tools/probe/r10uvm13run.sh <dir>` (needs `SLANG_UHDM` exported);
copy the directory somewhere writable first.  Read the census off a pair with
`tools/probe/r10uvm20a.cpp` built as usual.

Every arm shares ONE 25-line body: a package `pk` whose class `C` declares
`int p_q[$] / p_d[] / p_f[4]`, `string p_a[string]`, `Cel p_c[Cel]` and an
**extern** `run` defined out of body at package scope (the uvm-1.2 shape — the
`extern` matters: an IN-BODY method is never late-bound at all and every arm
reads `ref_var` for it).

| dir | import position | golden's loop variables (ELAB views) |
|---|---|---|
| t32a | none | `array_var array_typespec''` x3, `string_var`, `class_var 'Cel'` |
| t32b | `module top; import pk::*;` | same as t32a |
| t32c | **`import pk::*;` at `$unit`** | `int_var` x5 |
| t32d | `package pk2; import pk::*;` | same as t32a, in both package views |
| t32e | **`import pk::C;` at `$unit`** (explicit!) | `int_var` x5 |
| t32f | t32c's `$unit` import, every reference written `this.<prop>` plus three `other.<prop>` | `int_var` x5 for `this.`, **`array_var` / `string_var` / `class_var 'Cel'` for `other.`** |
| t32g | no import, same spellings as t32f | resolves all eight |

t32e is the arm that makes the mechanism unambiguous: an **explicit,
single-name** `$unit` import kills the resolution exactly as a wildcard does,
which is only explicable by `importPackage`'s unfiltered list copy.

## The three laws as implemented (`StmtEmit.cpp`, the `Foreach` case)

### § classPropUnitImport21 + § foreachClassPropArrayVar21

`pkgImportedByUnit21(pkg)` (StmtEmit.cpp:42) walks
`comp.getCompilationUnits()` for a `WildcardImport` **or** `ExplicitImport` of
the package, memoised.  `classPropRes21` is the per-site verdict; when it holds
and the property's canonical type is a Queue / DynamicArray /
FixedSizeUnpackedArray the loop variable becomes an `array_var` carrying a
**FRESH, EMPTY** `array_typespec` — not the declaration's own object, which is
what the subroutine-local arm (`§ foreachLocalArrayVar20`) shares.  Golden
prints `array_var array_typespec''` for a property whose own reference is still
an `unsupported_typespec`, and that is `getSimpleVarFromTypespec`'s `else` arm
minting a new one (`CompileType.cpp:220`).  **-254.**

The same `classPropRes21` **replaces** `§ foreachAssocIdxImporterView19`'s gate
for the associative arm.  Pass 19 tested "does ANOTHER PACKAGE wildcard-import
the home package"; that is true only of SeqDriver, so it agreed with the truth
on three of the four by coincidence and was **wrong on BuildUVMPkg**, whose
golden resolves 23 `string_var` + 107 `class_var` the old gate withheld.
`pkgWildcardImportedByPkg19` is deleted.

### § foreachHierPathAlwaysRes21

A reference **dotted in the source onto another object** (`foreach
(phase.m_predecessors[pred])`) is EXEMPT from the gate — it resolves in all
four tests.  That is the other arm of `swapForSpecifiedVar`: a `hier_path` loop
list is handed to `decodeHierPath` **as written** (`:2511`), so the path root
carries its own type in whatever DesignComponent the pass is walking, where the
synthetic one-element path the bare-name arm builds (`:2529`) has only the name
and needs the class scope the FileContent pass does not have.  t32f pins both
halves in one file.  **-12.**

`this.<prop>` is **not** exempt: t32f answers `int_var` for all five `this.`
spellings under a `$unit` import while the same file's `other.<prop>` still
resolves.  uvm-1.2 writes both (`foreach (this.in_use[i])` in `uvm_mem_mam`,
`foreach (phase.m_predecessors[pred])` in `uvm_phase`), so the cell is
load-bearing.

### § classPropIterThisRefVar21

slang models an IMPLICIT class-property reference as a `MemberAccess` on an
implicit `this`, so `fe.arrayRef.kind` cannot tell `q[i]` from `other.q[i]` —
`arrMember9` was firing on **every** class-property foreach and emitting a
`hier_path` where golden has a `ref_var`.  Read the written syntax instead
(`ScopedName`, and whether its leftmost root is a `ThisHandle`).  Three
spellings, three shapes, identical in every view of t32f and t32g:

| written | golden's `foreach_stmt` Variable |
|---|---|
| `q[i]` | `ref_var 'q'` bound to `unsupported_typespec 'q'` |
| `this.q[i]` | `ref_var 'q'` with **NO** typespec at all |
| `other.q[i]` | `hier_path` (VpiName cleared) |

**-62**, all four tests.  Our t32f and t32g loop-variable censuses are now
byte-identical to golden's.

---

## Ranked residue after this pass

`tools/probe/r10uvm19rank.sh 25` on the UVM-4:

| n | row |
|---|---|
| 890 + 753 | `Stmt io_decl vs <null>` / `<null> vs io_decl` |
| 738 | `Stmt logic_net vs <null>` |
| 600 | `Stmt function vs <null>` |
| 574 | `Stmt package vs <null>` |
| 571 | `Stmt <null> vs class_typespec` |
| 497 | `Stmt <null> vs class_var` |
| 476 + 459 | `Stmt` / `Io_decls` `<null> vs ref_obj` |
| 460 | `Return class_typespec vs class_typespec` |

The pass-20 presence census (`r10uvm20b mode=pres`) already classified the
first five: **all binding policy, no emission gaps.**

### The loop-variable residue that is left (112 census rows, ranked)

`r10uvm21` leaves the foreach loop variable disagreeing at 112 sites, and the
head of that is ONE unimplemented cell:

| n | shape | what |
|---|---|---|
| 40 | `G=struct_var 'uvm_pkg::uvm_reg_map_addr_range' O=int_var` | an associative property indexed by a **STRUCT** |
| 16 | `G=bit_var 'uvm_reg_addr_t' O=int_var` | indexed by a **typedef'd bit vector** |
| 20 | `G=class_var O=int_var` over a `this.`-prefixed assoc | see below |

`§ foreachAssocIndexVar19`'s index mapping only knows `StringType` and
`ClassType` and drops everything else to the `int_var` default; golden names the
index typespec after its **typedef** (`uvm_reg_addr_t`, package-qualified for
the struct).  Generalising it needs a Type-keyed typespec builder — there is no
`makeTypespec(const Type&)` today, only the `Symbol`-keyed one — which is why
it is ranked for pass 22 rather than attempted here.

The remaining `<missing>` rows in the census are **view multiplicity**, not loop
variables: golden's SeqDriver `ELABPKG` lists every uvm_pkg body once per
importing-package class (6 views x 150), where we emit one.
