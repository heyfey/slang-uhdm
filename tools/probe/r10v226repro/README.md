# r10v226 — adversarial verification of r10uvm226 (`§ ifaceDefListsItsOwnProcesses226`)

**VERDICT: ACCEPT.** Every headline number in the implementer's report reproduced
bit-for-bit on binaries this verifier built itself in fresh worktrees at
`d51916f9`. No pristine-right → patched-wrong case was found on legal
SystemVerilog, so no fix was needed and the shipped patch is the implementer's
plus this directory.

Numbers live in `VERIFIED.r10v226.txt`; this file records the *method* and the
residues.

## What was re-measured from scratch, not read

Both binaries were configured and built here (`52ad6bb9c32d…` pristine, which is
byte-identical to the main tree's `build/slang-uhdm` at `d51916f9`, and
`437d06b01c50…` patched), frozen `chmod 555`, and every sweep ran with
`SLANG_UHDM` exported explicitly per binary. All 1462 u2r and 1573 surelog
`cmds.txt` files were audited by binary PATH: the only four that do not name the
frozen patched binary are the two `SURELOG_FAIL` tests × two modes, where slang
never ran. Every arm's return code is recorded on all three sides.

**Both sweeps were run twice — once per binary** — so the comparison is against
this verifier's own pristine control, never a shared `/tmp/ctl_wd_*`.

## The instruments are the verifier's own

`proccen226v.py` walks a `uhdm-dump` by indentation and emits one CELL per
`(section, scope, position)` holding a `vpiProcess`, **plus a `NO-PROCESS` line
for every instance-like scope that holds none** — so an over-mint into an empty
holder is a scored cell, not an absence. `score226v.py` scores golden × pristine
× patched, so a cell golden lacks that only the patched side has is counted
`AWAY`, not silently dropped.

`dirscore226v.py` exists because the process census is blind outside a
`Process()` vector and the R-A change lives in **subroutine** bodies. A first cut
keyed on the bare dump line and reported 175 `AWAY` — all of it
`|vpiParent:` / `|vpiSize:64` / `|vpiActual:` label totals colliding globally,
RESUME §9's multiset trap. The shipped version keys every line by its ancestor
chain of node headers (depth 3). Both the arm grid and the wide boundary are
then partitioned mechanically into *(pristine == golden, patched != golden)* —
the only shape a real regression can take — and *(key absent from both golden
and pristine)*, which is what a growing dump manufactures. **The first bucket is
empty in both grids.**

`census226v.sh` carries a **positive control**, and it earned it: the first run
of this script reported `HIT_ROWS 0` on the surelog corpus — a clean-looking
zero produced by a script that had simply forgotten to set `R10E226_DBG=1`.
Byteverify's two MiniAmiq movers are what exposed it. The script now asserts the
instrument fires (`MINT226=6` on a known arm) before any zero is trusted.

## The law, re-derived on arms written here

Eighteen arms under `arms/`, compiled against the Surelog that
`scripts/verify_golden.py` names. The ones that carry the verdict:

* **`b02_kinds`** — all six procedure kinds (`initial`, `always`,
  `always_comb`, `always_ff`, `always_latch`, `final`) in an uninstantiated
  interface and in an instantiated twin. Patched matches golden **hash for
  hash on all twelve cells**; pristine listed none of the uninstantiated six.
* **`b06_assertfence`** — golden gives the uninstantiated interface 4 processes
  and 5 `Assertions()`. Patched gives exactly those 4 processes, including both
  `always` blocks that *contain* assertions, and mints **nothing** for the five
  concurrent-assertion items (`assert`/`assume`/`cover`/`restrict`, labelled and
  bare). The syntax-level fence holds; no object is minted then discarded.
* **`b04_gen`** — an uninstantiated interface with a bare `generate` region, a
  genvar loop, an if-generate and a case-generate. Golden lists exactly two
  processes: its own `initial` and the bare region's `always_comb`. Patched is
  **hash-identical on all eight cells** of the arm, module twin included.
* **`b01_holders`** — the same body under an uninstantiated module, an
  instantiated module, a program and a checker. Only the uninstantiated
  interface column moves.
* **`b11_forvar` — the R-A arm, and it vindicates R-A against real golden.**
  One `for (int k …)` written identically in a function, a task, an `initial`
  and an `always_comb`, in an uninstantiated interface, an instantiated
  interface and a module. Golden binds the iterator in the instantiated
  interface (9 refs) and the module (6 refs) and leaves it **bare in all 12
  references of the uninstantiated one**. The pristine binary bound 6 of those
  — in the *subroutine* columns, on §218's pre-existing road. The patched
  binary is exactly golden on all 27 references, and the instantiated and
  module columns do not move.

Across the 15 scoring arms, the pristine→patched dump diff is **additions only**
in 14 of them; the sole removal set is `b11`'s 12 lines, which are precisely
those 6 over-bound `vpiActual` edges.

## Residues found here

1. **A pre-existing segfault, minimal reproducer.** An **uninstantiated
   interface with a port list** crashes `slang-uhdm`:
   ```systemverilog
   interface p1 (input logic clk);
     logic a;
   endinterface
   ```
   `rc=139` on **both** binaries — so it is present at `d51916f9` and the patch
   neither causes nor widens it. Stack: `emitPorts` ← `emitModuleDefPorts` ←
   `exportDesign`. Instantiating the interface fixes it; a module with the same
   port does not crash. This matters to the whole
   §218/§220/§221/§223/§224/§225/§226 family, which legislates over a holder
   that cannot currently be compiled the moment it has a port — `arms/b13_modportproc`
   could not be scored for this reason.
2. **An interface containing an interface instance is emitted as
   `module_inst`**, not `interface_inst` — instantiated or not, on both
   binaries (`arms/d1_ifaceholder`). `VpiType` is judge-visible, so this is a
   real gap; it is pre-existing and untouched.
3. **The implementer's R6 is sharper than stated.** The imported-package
   parameter fold defect in a newly-minted process cell (golden's folded
   constant carries a `param_assign` link and a
   `vpiTypespec`→`ref_typespec`→`int_typespec`; ours carries neither) is
   **identical on all three roads**: `arms/c1_importfold` shows the module DEF
   road and the instantiated-interface road producing the *same* defective
   payload hash on pristine and patched alike. The patch does not introduce it;
   it propagates the existing constant emitter into a cell that was previously
   absent entirely. Absent → present-with-a-known-shared-defect is a move
   toward golden, and the defect is a separate residue.
4. **`b09_nestediface`'s only disagreement is an unjudged span.** The
   `do_while` end location reads `endln:31:31` in golden and `endln:31:7` in
   ours. `Compare` never reads file/line/col, so the cell is exact for the
   judge; the census flagged it only because its key carries the location.

## Reproducing

```bash
PRIS=<pristine> PAT=<patched> bash run226v.sh <armroot> <outdir>   # three-way, rc on all sides
python3 score226v.py <outdir>                                      # process census, three-way
python3 dirscore226v.py <outdir> 3                                 # parent-qualified directional
PRIS=… PAT=… bash bound226v.sh <outfile>                           # wide boundary over tools/probe
BIN=<patched> bash census226v.sh <sweep workdir> <outfile>         # over-mint census + positive control
```
