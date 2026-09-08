# r10v216 — ADVERSARIAL VERIFICATION of r10uvm216 (§ `dpiExportListedAtExportItem216`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduces bit-for-bit on binaries this verification built itself. One face of
the law was **pristine-right → patched-wrong on legal SystemVerilog** and is
fixed here by a fourth fence; the fix changes **no corpus database byte**
(byteverify fix-vs-patched 0/956 and 0/1358), so every reproduced number still
stands. Deliverable `/tmp/r10uvm216.verified.patch`.

**MEASUREMENT ONLY** except the fence itself. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py` are the
sole acceptance judges. **LHS is ALWAYS golden.** `results/*.csv` were READ
ONLY and NOT EDITED, **no row converted in either direction**, `GOLDEN_DEFER`
stayed unset, slang was **NOT** patched, and the four slang-fenced tests were
never dispatched (they are not named in this directory).

| | |
|---|---|
| BASE | `b7eb7ff3` |
| pristine | `49b83611ebc24e7155c5e62e6c8e23e2` — matches the implementer's |
| patched | `4db85bc0e24d58654a133cb7c318140b` — the implementer's patch applied to a FRESH `b7eb7ff3` worktree and rebuilt `-j 2` comes out **byte-identical** |
| fixed | `dd981cc3f7dae732a1f6a9298baa49fd` — patched + FENCE 3 |
| all three | frozen `chmod 555` before any sweep; every `cmds.txt` audited BY PATH (`/tmp/v216_bin/{pris,pat,fix}`), **none names the main-tree binary** |

---

## 1. THE DEFECT THIS VERIFICATION FOUND, AND FIXED

### § `dpiExportBelowDefIsTwoEntries216` — AN EXPORT WRITTEN **BELOW** ITS DEFINITION IS A DIFFERENT SURELOG SHAPE, AND THE LAW MUST NOT FIRE ON IT

Surelog's FUNCTION pass walks the holder's items in order. When the
`export "DPI-C"` item comes **first**, it pushes a named prototype at the export's
slot and the later definition's `compileFunction` bare-name scan
(`CompileStmt.cpp:2353-2358`) finds it and fills it in place — that is the
implementer's law and it is correct. When the **definition** comes first the scan
finds nothing, so the definition is listed **UNSTAMPED at its own slot**, and the
later export item runs `compileFunctionPrototype` + `insertFunction`, which does
not re-scan: **golden ends up with TWO entries.**

We emit one entry. Pristine held it unstamped at the definition's slot — which is
exactly golden's first entry. The patch moved that entry to the export's slot AND
stamped it `vpiAccessType=EXPORT`, losing the cell we already had. Measured on
real Surelog goldens, both views, every holder kind (`armsv216B/`,
`GRID.r10v216.B.*`; each cell is the whole-database subroutine-listing census,
golden-vs-golden calibration null in all 30 arm-views):

| arm | shape | pristine | patched | fixed |
|---|---|---|---|---|
| `v216_b1_iface_below_sep` | interface, separated | OG 3 / OO 1 | **OG 6 / OO 4** | OG 3 / OO 1 |
| `v216_b2_mod_below_sep` | module (slang resolves the export itself), separated | OG 10 / OO 6 | **OG 12 / OO 8** | OG 10 / OO 6 |
| `v216_b3_pkg_below_sep` | package + a wildcard importer, separated | OG 14 / OO 10 | **OG 18 / OO 14** | OG 14 / OO 10 |
| `v216_b4_iface_below_adj` | interface, ADJACENT below (`r10v170repro/v170_p_export.sv`'s `epsil7` shape) | OG 3 / OO 1 | **OG 5 / OO 3** | OG 3 / OO 1 |
| `v216_b5_mixed` | one export above AND one below, same interface | OG 7 / OO 5 | OG 5 / OO 3 | **OG 2 / OO 0** |

`v216_b4` is the one that shows the flags half on its own: the position never
changes there (an adjacent pair is an identity permutation) and the arm still
regresses, because the patch **stamps a definition golden leaves unstamped**.

`v216_b1` cell by cell (interface `work@v216_ifb1`, parse view; elab identical):

```
GOLDEN   [0] eb_one   acc=-      io=1 body=1      <- the definition, UNSTAMPED
         [1] plain_b  acc=-
         [2] eb_one   acc=EXPORT io=0 body=0      <- the second, EMPTY prototype
         [3] plain_b2 acc=-
PRISTINE [0] eb_one   acc=-      io=1 body=1      <- golden's [0], RIGHT
         [1] plain_b  acc=-                       <- golden's [1], RIGHT
         [2] plain_b2 acc=-
PATCHED  [0] plain_b  acc=-                       <- both cells LOST
         [1] eb_one   acc=EXPORT io=1 body=1
         [2] plain_b2 acc=-
```

**THE FIX — FENCE 3, three lines of behaviour.** `dpiExportItem216` returns null
when the export item's index is greater than the subroutine's own item index, and
the `pkgTfOrder9` listing key reads that fenced answer (`dpiExportAbove216`)
instead of `dpiExportSyn`, which slang also sets for a below export. The below
shape therefore keeps the pristine listing until R2 models the second entry.
`v216_b5` shows the two halves are independent: with the fence, the *above*
export closes and the *below* one keeps its cell, reading **better than either**
earlier binary (OG 2 / OO 0, and that 2 is only golden's extra empty prototype —
**ONLY-OURS is 0, nothing of ours is misplaced**).

**THE FIX COSTS NOTHING.** `byteverify` fixed-vs-patched is **0 / 956** surelog
and **0 / 1358** uhdm2rtlil databases: no corpus row contains the below shape, so
the fence is invisible to the corpus and every number the implementer measured
still holds on the fixed binary.

---

## 2. THE IMPLEMENTER'S NUMBERS, REPRODUCED

Full transcript in `GATES.r10v216.txt`. Headlines, all re-measured here:

* goldens **23 PASS / 0 FAIL** on all three binaries, `/bin/false` control 23 FAIL;
* uhdm2rtlil **679 / 50 / 2** in both modes on all three, `ct8rows` PASS,
  `byteverify` **0 / 1358**;
* surelog **475 + 6** default and **469 + 6** testflags on all three — histogram
  identical, **NO ROW CONVERTED**; `ct8rows` pristine-vs-patched **0 differing
  rows over 1588**, committed-vs-FIXED **0 over 1588**;
* `byteverify` surelog **6 / 956**, the same six databases at the same md5s:
  `MiniAmiq` ×2 (the law), `BuildUVMPkg` ×2 and `SeqDriver`/default (allocation),
  `Scoreboard`/default (the coin);
* heads: **MiniAmiq ×2 838/1 → 29/1**, `SeqDriver` ×2 209/1 unchanged, every
  other row 0/0. The patched head log is **byte-identical** to the committed
  `head_pat_MiniAmiq.default.cmp`;
* the MiniAmiq listing: `interface_inst work@svaunit_vpi_interface` size **931 on
  both sides**; golden `[900] pass_info_to_sv_dpi EXPORT @72:4-72:48`,
  `[901] create_assertion_dpi EXPORT @78:4-78:49`; pristine had them **unstamped
  at [906]/[905]**; patched reproduces golden's index, flags and span exactly.
  Whole-database census 37151 cells, calibration null, **9 → 0**;
* DPI IMPORT / EXPORT / plain in that interface: golden **21 / 3 / 907**,
  pristine **21 / 1 / 909**, patched **21 / 3 / 907**;
* canaries on the fixed sweep **ok=52 changed=0** (surelog) and **ok=8 changed=0**
  (u2r), `ctcan2` PASS ×2, `canaudit` audited=29 UNCOVERED=0 **FENCE-BREACH=0**;
* protected databases: `InterfaceModPort` (an INTERFACE test) **SAME**,
  `BlackParrotComplex` SAME, `YosysOldOr` SAME, `SVSwitch` `4842211c4030`,
  `YosysVerx` `6ccda350c24a`.

**The two unpredicted movers are attributed without the implementer's control
binaries.** `uhdm-dump`, pristine vs patched: `BuildUVMPkg` differs in exactly
ONE line, the dump's own embedded workdir path (RESUME §9); `SeqDriver`/default
differs in 27 — the path line plus one relocated `logic_typespec
(uvm_hdl_data_t)` block — and its `uhdm-cmp` output is **byte-identical**
(209 lines, same head). **Order-blind (sorted) both read ZERO differing lines**,
as does `Scoreboard`/default's 93-line raw diff, the documented coin.

**The `Earlgrey_0_1` informational cell is a harness timeout, proved by
inversion.** Running the pristine and patched sweeps CONCURRENTLY blanked
`Earlgrey_0_1`/**testflags**'s dump column on BOTH binaries (status `CMP_EQUAL`
both, database bytes identical); running the fixed sweep ALONE reproduced the
committed row exactly — committed-vs-fixed `ct8rows` **0 differing rows over
1588**. The implementer saw the same class on the `default` row. It is a
load-induced `uhdm-dump` timeout in the informational column, not an effect of
any binary.

---

## 3. THE FACES THE LAW WAS BROKEN AGAINST

`armsv216/`, `armsv216K/`, `armsv216N/` — real Surelog goldens
(`-parse -d coveruhdm -nobuiltin -nocache`, and again `-elabuhdm`), one per arm
per view, golden-vs-golden calibration **null in every cell**, scored by the
whole-database subroutine-listing census (ONLY-GOLDEN / ONLY-OURS) and, where
one side holds an entry the other does not, by the shift-immune rank scorer.

| arm | face | pristine | fixed |
|---|---|---|---|
| `v216_a_iface_sep` | the law: two exports far above their definitions, in the OPPOSITE order, plain functions and a DPI import between | 7 / 7 | **0 / 0** |
| `v216_c_inst_iface` | an INSTANTIATED interface (slang resolves the export itself) | 4 / 4 | **0 / 0** |
| `v216_d_fence_class` | FENCE 1: a class method whose bare name equals the module's exported name | 4 / 4 | **0 / 0** parse |
| `v216_e_imports` | DPI imports plain / context / **pure** interleaved with two separated exports in reverse order | 8 / 8 | **2 / 2** (the residual 2 are `vpiDPIPure`, pre-existing — see R2) |
| `v216_f_pkg_task` | a package with a separated FUNCTION export and a separated TASK export, plus a wildcard importer | 12 / 12 | **0 / 0** |
| `v216_h_import_hoist` | an interface that wildcard-imports a package (entries with no item index of their own) and exports at item 0 | 3 / 3 | **0 / 0** |
| `v216_i_program` | a PROGRAM block, separated export | 2 / 2 | **0 / 0** |
| `v216_k_include` | the export item and the definition in DIFFERENT `include` buffers | 8 / 8 | **0 / 0** |
| `v216_l_macro` | the export item out of a **MACRO EXPANSION** buffer | 8 / 8 | 4 / 4 — the package closes, the **hoisted copy does not** (R1) |
| `v216_m_nested_mod` | a NESTED MODULE whose function shares the outer module's exported name | 8 / 8 | 4 / 4 — the module closes exactly; the 4 are a pre-existing nested-module HOLDER-NAME residue (`work@v216_mod_m::v216_inner_m` vs `work@v216_inner_m`) |
| `v216_n{1,2,3}_inst` | THE SAME exporting interface instantiated 1, 2 and 3 times | 4/4, 6/6, 8/8 | **0 / 0, 0 / 0, 0 / 0** |

The implementer's own six arms were re-run on all three binaries
(`GRID.r10v216.IMP.*`): **A–E close 0 / 0 on patched AND fixed**; arm F reads
16 / 8 by absolute index on both, and the shift-immune scorer confirms the
implementer's account — `RANK-GOLDEN 2 / RANK-OURS 2 → 0 / 0`, the absolute-index
worsening being entirely the entry only golden holds (`f216_cls::get`, their R3).
Read by eye, ours goes from `… plain3, f216_other, f216_positive` to
`… plain3, f216_positive, f216_other`, which is golden's relative order.

**Nothing golden does not list ever appears.** No arm's ONLY-OURS rises on the
fixed binary; `MiniAmiq`'s interface holds 931 entries on both sides before and
after; no arm gains an entry.

Surelog cannot parse an `interface` nested inside a `module` (3 syntax errors),
so that face has no golden and is not scoreable; the nested-**module** face
(`v216_m`) stands in for it.

---

## 4. THE WIDE BOUNDARY

`bound216.sh` over a COPY of the whole probe tree plus this verification's own
arms — subdirectories included, both views, children `</dev/null`, the file list
on fd 3, scratch keyed on the RELATIVE path — pristine vs **fixed**. Transcript
`BOUNDARY.r10v216.txt`, movers `BOUNDARY.movers.r10v216.txt`.

---

## 5. RESIDUES, RANKED

* **R0 (the implementer's, confirmed as the next head).** `MiniAmiq` ×2 now read
  29 cmp lines / one head: golden's `io_decl a_sva_type` (`svaunit_vpi_interface.sv:255:103`,
  parented to `pass_info_to_sv_dpi` @72) against `RHS: <null>` — the SINGULAR
  overload, the buvm13/15 shape. **Caveat for whoever takes it:** the cmp log
  names the VALUE (`io_decl`) and not the owner, so "the owner is a `ref_obj`'s
  `Actual_group`" is the implementer's inference, not something the log states.
  Decode the owner from the databases before building on it.
* **R1 — A MACRO-EXPANDED EXPORT ITEM MIS-SORTS THE HOISTED COPY.**
  `pkgTfOrder9` still keys the package listing on a raw `SourceLocation`, so with
  the export item coming out of a macro-expansion buffer the package's own
  listing is right and the wildcard importer's hoisted copy is not
  (`v216_l_macro`: package holder exactly golden, `work@v216_top_l` still
  `plain_l, el_one` where golden has `el_one, plain_l`). Pristine had BOTH
  holders wrong, so this is an un-fixed half and not a regression; `include`
  buffers sort correctly (`v216_k_include` closes 0 / 0), and ten runs of the
  macro arm give one md5, so it is deterministic here. The item-INDEX discipline
  the memo already uses is the fix.
* **R2 — `vpiDPIPure` IS NEVER STAMPED.** `import "DPI-C" pure function` reads
  `pure=1` on golden and `pure=0` on ours, in every arm that has one
  (`v216_e_imports` idx 4, and the implementer's own `g216_f_muststay` idx 2 —
  their arm carries the cell but their report does not name it). Pre-existing,
  unchanged by this pass, two cells per pure import.
* **R3 — A PORTED INTERFACE THAT IS NEVER INSTANTIATED SEGFAULTS.** Pre-existing
  at `b7eb7ff3` **and at the current main-tree HEAD**, nothing to do with this
  pass, but it is a live `rc=139` that `verify_golden.py` would record as
  `SLANG_REJECT` wearing the last stderr warning (RESUME §9). Minimal repro
  `segfault/j10.sv`:

  ```systemverilog
  interface j10_if (input logic clk);
    logic a;
  endinterface
  ```

  `UhdmExporter::emitPorts` ← `emitModuleDefPorts` ← `exportDesign`. Adding a
  module that instantiates it (`segfault/j11.sv`) makes it rc=0; removing the
  port list makes it rc=0. `segfault/j8.sv` is the same crash with a subroutine
  in the interface, which is how it was found.
* **R4 — the implementer's R2 is now FENCED, not merely recorded.** An export
  written below its definition makes golden emit two entries; modelling that
  (emit the empty `vpiAccessType=EXPORT` prototype at the export's slot, leave
  the definition unstamped) would close `v216_b1`–`b5` completely. FENCE 3 is
  what keeps us at pristine until someone does.
* **R5 — the implementer's R1 stands.** The memo is built eagerly and moves three
  databases' bytes with a byte-identical (order-blind) dump; a lazy build removes
  the churn.
* **R6 — an out-of-body class-method definition is not hoisted into an INTERFACE
  listing** (their R3, confirmed on arm F), and a nested module's holder name
  lacks its parent prefix (`v216_m`). Both pre-existing, both different families.

---

## 6. THE FILES

| file | what it is |
|---|---|
| `armsv216/` | the ten faces of §3 (A–J; G has no golden, J is R3's crash) |
| `armsv216B/` | the five below-shape arms that convicted the patch |
| `armsv216K/` | the include-buffer, macro-buffer and nested-module arms |
| `armsv216N/` | the same exporting interface at 1, 2 and 3 instances |
| `segfault/` | R3's minimal repro and its two negative controls |
| `GRID.r10v216.V.*`, `.B.*`, `.K.*`, `.N.*` | those arms on pristine / patched / fixed |
| `GRID.r10v216.IMP.*` | the implementer's own six arms on all three binaries |
| `GATES.r10v216.txt` | every gate number, both corpora, three binaries |
| `BOUNDARY.r10v216.txt`, `BOUNDARY.movers.r10v216.txt` | the wide boundary |

Scoring reuses the implementer's committed `ct216cen` / `cen216.py` /
`list216.py` / `rank216.py` / `grid216.sh` / `bound216.sh` unchanged — an
independent scorer would have been a second thing to trust; instead the
calibration (golden vs golden) is asserted null in every cell of every table
above, which is what makes reusing them safe.
