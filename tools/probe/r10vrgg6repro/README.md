# r10vrgg6 — ADVERSARIAL VERIFICATION of r10rgg6 / § nestedParamActualTs6

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge.  **BASE `f9bd718`.**  Every number here was produced by
binaries this directory's owner built and md5'd itself:

    base    ef5689e371158c0ccfabe2d543c6c881   (pristine f9bd718)
    r10rgg6 c636d3e012031c0e3602b0d10f031aa7   (implementer's patch, reproduced)
    r10vrgg6 1b77ae23c917951cc4fca041ef48b744  (+ the view guard shipped here)

`cells/` holds **54 purpose-built cells** on the axes the implementer's 69-cell
grid does not reach: params in packages / interfaces / generate scopes,
hierarchical (`pkg::`) actuals, `defparam`, instantiation-time overrides,
recursive module instantiation, struct-typed formals, an 18-deep chain, a
function-name collision across two modules, and — the productive half — the
**driving-site** axis (declaration range, unpacked dimension, if/case-generate
condition, genvar loop bound, instance port connection, instance parameter
override, constant-function body, continuous assign, procedural block,
net-decl-assign, task actual) and the **order** axis (2x2 and 3x3 permutations
of middle-parameter declaration order against consumer order, plus renames of
every identifier and a function-body swap).

    run_cells.sh <cellsdir> <outdir> [binary]   real Surelog + a slang-uhdm binary
    report_all.sh <baseout> <patout>            GOLD vs two binaries, ALL views
    report.sh                                   the ELAB-only view of the same
    boundary.sh <a> <b> <out> <dir>...          566-file precedent boundary

## WHAT THE VERIFICATION FOUND

1. **Every headline number of r10rgg6 reproduces bit-for-bit** — both binary
   md5s, goldens 23/0 + `/bin/false` 0/23, u2r 679/50/2 and `identical=1358
   MOVERS=0`, the grid 33/62 -> 58/62, Rggen/default 17 -> 85 cmp lines at one
   head, the whole-database diff of **120 lines removed / 1 added** (the banner)
   with every removed line in the `ref_typespec` family, and the census of
   param-initializer `func_call`s carrying a `vpiTypespec` going **17 -> 0**
   against golden's **0**.
2. **The head object is genuinely cleared, and the new head is BETTER-SHAPED.**
   Base's head was `LHS: <null> / RHS: ref_typespec` — an object WE invented.
   The new head is `LHS: gen_scope(...u_reducer.g_reduce) / RHS:` — an object
   GOLDEN has and we lack.  A missing object outranks a spurious one.
3. **The one boundary mover is a CORRECTION**, verified independently against
   real Surelog on that cell: `r10vrgg2repro/x4_v2x2_n25`, golden bare, base
   stamped `bit_typespec@32:56`, patched bare.
4. **A LATENT SPURIOUS-DEF-OBJECT DEFECT, FIXED HERE** (`cells/w_port_conn`).
5. **The ORDER clause of the shipped law is REFUTED** (`cells/s_*`, `z_*`).

Both are written up in the pass report.  The GATES this directory's owner ran
are listed there too; nothing in `results/` was written.
