# r10v145 — ADVERSARIAL VERIFICATION of r10uvm145 (§ `tfItemLocalInitHoistsNoStatement145`)

**MEASUREMENT ONLY.**  Nothing in this directory is an acceptance judge:
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` are the
authorities for every number below.  slang was NOT patched; `results/*.csv`
were READ ONLY; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests were
never dispatched and are named only inside `canaudit.sh`'s own fence list.

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number in the implementer's
report reproduces bit-for-bit on binaries this verifier built itself.  One face
of the law was WRONG and cost a pristine-right cell: a **TASK** whose body
declares io *and* a `parameter` / `localparam`.  The fix is in
`/tmp/r10uvm145.verified.patch`.

---

## 1. Reproduction (independent builds, three frozen binaries)

Fresh worktrees `/tmp/wt_v145pris` and `/tmp/wt_v145` at base `2ce3785`,
configured and built here, `-j 2`, frozen `chmod 555`:

| binary | md5 | implementer reported |
|---|---|---|
| pristine `2ce3785` | `81c535856b9c7f0c125f791af6969272` | **same** |
| implementer's `/tmp/r10uvm145.patch` applied | `527a4e6c6a1384c4afa40dda0e2b5c2c` | **same** |
| this verifier's `.verified.patch` | `56512a5d36b03a5ba0dd27b7b9fb3067` | — |

The implementer's patch applies clean on a fresh `2ce3785` (`git apply -3`
rc 0, 2 M + 35 A, 0 conflict markers); its surface is `src/StmtEmit.cpp` +
`include/UhdmExporter.h` + `tools/probe/r10uvm145repro/` only; `results/*.csv`
untouched; the four fenced names appear 0 times outside `canaudit.sh`; its
drivers use `WD=${WD:-/tmp/r10uvm145_*}` (no hard-coded foreign scratch, no
`rm -rf` on a shared path); the probe directory is 288 KB with no databases.

Reproduced numbers (all re-measured here, `GATES.txt`):

* goldens **23/0**, negative control `SLANG_UHDM=/bin/false` **0/23**;
* uhdm2rtlil **679 / 50 / 2** in BOTH modes for all three binaries;
* surelog histograms **byte-identical to pristine** in both modes
  (default 471/283/25/10/5, testflags 466/284/23/9/5/3/2/1/1);
* `ct8rows` **0 differing rows over 1588** (status AND dump column) vs
  `results/golden_surelog.csv` *and* vs this verifier's own pristine sweep;
  u2r likewise vs `results/gate_uhdm2rtlil.csv`.  **No row converted.**
* `byteverify SELFCHECK=1`: u2r **MOVERS 0 / 1358**, surelog **MOVERS 9 / 956**,
  `PATH_SETS_IDENTICAL` on both — and the nine are **exactly the nine the
  implementer predicted by name**: SeqDriver / MiniAmiq / BuildUVMPkg /
  SimpleUVM in both modes plus Scoreboard/default;
* heads (`rowheads.sh`, own sweeps): SeqDriver **6254 → 62** both modes,
  MiniAmiq **6222 → 62** both modes, SimpleUVM 62, Scoreboard 62,
  BuildUVMPkg 55, Earlgrey 250 / 278, Rggen 0 — ONE `^LHS:` everywhere;
  SimpleUVM's head log is **byte-identical pristine → patched**;
* every `cmds.txt` in all 5 sweep workdirs (2 × 1462 + 2 × 1573 files) names a
  frozen `/tmp/v145_bin/*.bin`; **main-tree hits 0**;
* canaries **ok=52 changed=0** / **ok=8 changed=0**, ctcan2 PASS ×2,
  canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0`;
* InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical,
  SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`.

Mover attribution, order-blind (uhdm-dump, workdir-normalised, `id:`-stripped,
SORTED, so Scoreboard/default's coin cannot speak): on all nine databases every
REMOVED line is one of the predicted `assignment`s, its `vpiOpType:82` /
`vpiBlocking:1` / `vpiLhs` / `vpiRhs` / `vpiStmt` / `vpiParent` fields, its Rhs
`constant` (`UINT:1` / `UINT:0`) or `ref_obj (uvm_cmdline_processor::get_inst)`,
or a `\_begin:` / `\_bit_var:` / `\_class_var:` parent-reference line those
objects printed; and **every ADDED line is a `\_function:` vpiParent reference —
`added-that-is-not-a-vpiParent-line = 0` on all nine.**  No generated `Compare`
reads `VpiParent`.

The **pristine SEGFAULT** reproduces independently: `/tmp/v145_bin/pris.bin`
returns **rc=139** on `v145_g_zero.sv` and on `v145_d_thresh.sv`'s original
2-and-3-initialiser zero-statement cells, in both views.  The patch turns it
into a clean run.

---

## 2. THE BREAK — the face the law got wrong

### § `tfItemTaskParamBreaksTheWalk145v`

`compileTask` (`~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp:2010-2028`)
does **not** advance past every `tf_item_declaration` the way `compileFunction`
does.  It advances only while each item is a `paTf_port_declaration` or a
`paBlock_item_declaration` whose child IS a `paData_declaration`:

```cpp
} else if (fC->Type(Tf_port_declaration) ==
           VObjectType::paBlock_item_declaration) {
  NodeId ItemNode = fC->Child(Tf_port_declaration);
  if (fC->Type(ItemNode) != VObjectType::paData_declaration) break;   // <-- HERE
}
```

A `parameter` / `localparam` declaration is a `block_item_declaration` that is
**not** a `data_declaration`, so it **BREAKS** the advance and
`Statement_or_null` is left pointing AT it.  From that item on everything —
including every further data declaration — is compiled by `compileStmt` →
`compileDataDeclaration`, which mints the hoisted `assignment`.  Declarations
that PRECEDE the break stay tf-items and hoist nothing.

`compileFunction` (`:2425-2470`) has no such break: it compiles a body
parameter inline into `func->Param_assigns()` and keeps advancing, so a
paren-less FUNCTION hoists nothing whatever a parameter does.

### The measurement (arm `v145_h_param.sv`, golden vs pristine vs patched, both views)

| cell | shape | golden hoists | pristine | implementer's patch |
|---|---|---|---|---|
| `h_ba145v` | task+io, `pre` before `parameter`, `post` after | `post` only | BOTH (1 right, 1 wrong) | **NEITHER — `post` LOST** |
| `h_lp145v` | task+io, `localparam` then `a` | `a` | `a` | **NONE — LOST** |
| `h_p2145v` | task+io, `parameter` then `a`,`b` | `a`,`b` | `a`,`b` | **NONE — 2 LOST** |
| `h_plast145v` | task+io, `a`,`b` then `parameter` | neither | both (wrong) | neither (right) |
| `h_td145v` | task+io, `typedef` (a data_declaration) | neither | neither | neither |
| `h_noparam145v` | task+io control | neither | both (wrong) | neither (right) |
| `hf_ba145v` | paren-less FUNCTION with a parameter | neither | both (wrong) | neither (right) |
| `hb_ba145v` | BLOCK-ITEM task twin | both | both | both |

Under the implementer's patch, arm H scored `RIGHT->WRONG` **2** (def) / **4**
(elab) and `AWAY` **4** / **8** (`ARMS.h_param.implementer-patch.txt`), and arm
D's `tp_n1m1145v` scored `RIGHT->WRONG` **1** / **2** and `AWAY` **1** / **2**
(`ARMS.implementer-patch.txt`).  Those are the ONLY regressions found anywhere.

### The fix

`src/StmtEmit.cpp`, `StatementKind::List` arm — one predicate, asked once and
used by BOTH halves so the threshold and the statement list can never disagree
again (their disagreement was the SEGFAULT):

```cpp
bool tfHasBreak145v = false;                       // the first body parameter
SourceLocation tfBreakLoc145v = SourceLocation::NoLocation;
if (bodyTfItems9 && bodyParams9)
    for (auto& pr9 : tfBodyPaAnchor9) ...          // earliest valid start

auto hoists145v = [&](const VariableSymbol* vs) {
    if (!bodyTfItems9)   return true;              // BLOCK-ITEM: unchanged
    if (!tfHasBreak145v) return false;             // pure TF-ITEM: § 145
    return declStart145v(vs).valid() && tfBreakLoc145v < declStart145v(vs);
};
size_t eff9 = <#initialised decls that hoist> + real.size();
...
if (!hoists145v(vsym)) continue;                   // the statement half
```

`tfBodyPa9` is populated for TASKS only (`TaskFuncEmit.cpp:5002`), so
`bodyParams9` is exactly this break and nothing else can reach the new arm.

After the fix, **`RIGHT->WRONG` 0 and `AWAY` 0 in every arm, every view, every
column** (`ARMS.txt`), and arm H is strictly better than *both* the pristine
and the implementer's binary: ROW=STMT `ONLY-OURS` 8/16 → **0** *and*
`ONLY-GOLDEN` 4/8 → **0**.

---

## 3. The adversarial grid (`arms145v.sh` + `ct145cen` + `score145.py` — `ARMS.txt`)

Eight arms × golden / pristine / patched × def and elab,
`LISTED=8 PROCESSED=8 PROCESSED-ASSERT-OK`, every rc recorded, and the official
`uhdm-cmp` run golden-vs-ours on each side of every arm.

| arm | what it breaks |
|---|---|
| `v145_a_faces.sv` | every initialiser face — `static` / `automatic` / neither × literal / call / `new` / `null`; two-and-three declarators in one declaration; a local in an inner `begin`; a local in `fork`; task vs function; void vs non-void — each with its BLOCK-ITEM twin |
| `v145_b_homes.sv` | homes: package class, `$unit` class, module class, interface, program, interface class (prototype only), nested class, package/module/interface/program free subroutines; 1-3 instances each |
| `v145_c_ctrl.sv` | the MUST-STAY controls: § `classPropNewLhsNoHoist109` property initialisers, § `oobRefVarLocalHoistNet107` block-item hoist, § `ctorBodyLocalsNotOnFunc71` + § `tfItemLocalClassTsNotAConstructor142v` constructors (paren AND paren-less), § `qualLifetimeStubListsNoBodyLocals141` stub, § `declInitWrittenNewNoStmt66` `= new` under both productions |
| `v145_d_thresh.sv` | N inits × M statements, N,M ∈ 0..3, both productions; explicit-`begin` bodies; a `for`-loop variable; the parameter-bearing bodies |
| `v145_e_oob.sv` | out-of-body methods (paren-less, paren, task, virtual), a TF-ITEM method beside a BLOCK-ITEM method in ONE class, a static method, 11 kinds (bit/string/real/enum/packed struct/fixed/queue/dynamic/assoc array/class handle/static call) |
| `v145_f_after.sv` | a local declared AFTER a statement — slang and Surelog REJECT it identically (rc 3 / 3 / 3), the legal-SV boundary |
| `v145_g_zero.sv` | zero-statement TF-ITEM bodies in every home — the pristine rc=139 SEGFAULT, quarantined |
| `v145_h_param.sv` | **the break** (§2 above) |

**Controls held, measured against GOLDEN and not merely against pristine.**
Arm C's `Ctor145v::new()` and the paren-less `Ctor2145v::new` produce the
census row `BKIND=begin NSTMTS=3 NVARS=-1 BVARS=1 NTOPS=3` in golden, in
pristine AND after the fix — byte-identical, constructors keep their hoist
(§ `ctorBodyLocalsNotOnFunc71`, § `tfItemLocalClassTsNotAConstructor142v`).
The § `qualLifetimeStubListsNoBodyLocals141` stubs `Qual145v::q1145v` /
`q2145v` are UNMOVED: their only non-`RIGHT` cells are a pre-existing
body-SPAN key split (golden keys the body at `55:5-59:12`, we at `55:5-55:14`)
that is identical in pristine and patched.  Arm C's one `LAUTO` `WRONG->WRONG`
(`Ctor2145v::new`'s local `ck`) is likewise pre-existing.  `ROW=STMT` and
`ROW=LOC` score `RIGHT->RIGHT` on **every** cell of arm C, both views — the
property initialisers (§ `classPropNewLhsNoHoist109`), the BLOCK-ITEM hoist
(§ `oobRefVarLocalHoistNet107` shape) and the `= new` drops
(§ `declInitWrittenNewNoStmt66`) are untouched.  Arm C's one improvement is
`new66one145v` at `84:3-88:10` — a TF-ITEM task whose `= new` was already
dropped and which therefore has ONE surviving statement: golden
`BKIND=sys_func_call NSTMTS=-1`, pristine `BKIND=begin NSTMTS=1`, fixed
`= golden`.  That is the § 4b shape of the implementer's report, reproduced
independently in this verifier's own arm.

---

## 4. Wide boundary (`bound145v.sh`)

Every `.sv` / `.svh` under `tools/probe/` — **4094 files** (4086 + this
directory's 8), both views, each compiled by two binaries TO THE SAME OUTPUT
PATH and compared by md5.  Subdirectory arms included; the scratch key is the
RELATIVE path (`r10uvm33repro` keeps three files all named `dut.sv`); children
get `</dev/null`; PROCESSED asserted; every rc recorded.

**pristine vs verifier-fixed** (`BOUNDARY.pris-vs-fix.txt`):
`LISTED=4094 PROCESSED=4094`, `MOVED=42`, `RC-MISMATCH=4`, `NORUN=356`,
`SAME=7786`.  The 4 rc mismatches are the two crash arms
(`r10uvm145repro/g145_e_zero.sv` and `r10v145repro/v145_g_zero.sv`,
`139 → 0` / `139 → 4`).  The moved set is exactly:

| tree | file-views | note |
|---|---|---|
| `r10uvm139repro` | 6 | § `tfItemLocalAutomaticIsNotWrittenStatic139`'s TF-ITEM grids |
| `r10v139repro` | 12 | its verifier's grids |
| `r10uvm66repro` | 4 | `a2_slots` / `a3_count` — the § 66 interaction |
| `r10uvm145repro` | 8 (+2 crash) | the implementer's own arms |
| `r10v145repro` | 14 (+2 crash) | this directory's arms — the gate's POSITIVE CONTROL |

**Nothing else moved.**  `r10uvm71repro` (§ `ctorBodyLocalsNotOnFunc71`),
`r10uvm141repro` (§ `qualLifetimeStubListsNoBodyLocals141`), `r10uvm107repro` /
`r10v107repro`, `r10uvm109repro` / `r10v109repro`, `r10uvm113repro`,
`r10uvm122repro`, `r10uvm142repro` / `r10v142repro`, `r10uvm143repro`,
`r10uvm89repro`, `r10uvm77-79repro`, `r10buvm3-15repro`, `r10uvm82-91repro`,
`r10sd8-12repro` and `r10uvm33repro` are all byte-identical.

Every one of the 22 moved EARLIER-PASS file-views was re-scored against its own
Surelog golden (`PRIOR_ARMS.txt`): **`RIGHT->WRONG` 0 and `AWAY` 0** on all of
them, ROW=STMT `ONLY-OURS` → **0** everywhere, `ONLY-GOLDEN` never up.  The
§ 66 cell `r10uvm66repro/a2_slots.sv` `n24_tfitems` is byte-identical to golden
under the fix and was not under pristine:

```
golden    BKIND=method_func_call BSPAN=253:10-253:13 NSTMTS=-1 NTOPS=1 NVARS=1
pristine  BKIND=begin            BSPAN=253:7-253:20  NSTMTS=1  NTOPS=1 NVARS=1
fixed     BKIND=method_func_call BSPAN=253:10-253:13 NSTMTS=-1 NTOPS=1 NVARS=1
```

**implementer-patched vs verifier-fixed** (`BOUNDARY.pat-vs-fix.txt`):
`LISTED=4094 PROCESSED=4094`, `MOVED=4`, `RC-MISMATCH=0` — and the four are
`r10v145repro/v145_d_thresh.sv` and `r10v145repro/v145_h_param.sv`, the only
two files anywhere that contain a parameter-bearing TF-ITEM task.  **The fix's
delta from the implementer's patch has zero reach outside those two arms**,
which is also why the corpus mover set is still exactly the same nine.

---

## 5. Residues (ranked) and R0

* **R0 — CONFIRMED as the implementer states it.**  SeqDriver / SimpleUVM /
  Scoreboard / MiniAmiq, six row-modes, **62 cmp lines, ONE head, the SAME
  object**: golden resolves the function-local `uvm_coreservice_t cs;`
  (`uvm_component.svh:3385`) to a PACKAGE-scope `class_var uvm_pkg::cs` at
  `uvm_pkg.sv:1731:21` carrying `vpiVisibility:1`; we bind it to the local
  (`…m_set_cl_verb::cs`, `3385:3`) and carry no visibility.  `variables::Compare`
  reads `VpiVisibility`.  A § `oobRefVarLocalHoistNet107`-family late-binding
  question.  Logs: `head_fix_SeqDriver.default.cmp` (and the identical-shaped
  `head_fix_SimpleUVM.default.cmp`, byte-identical to the pristine one).
* **R1 — the post-break TASK local is NOT DUAL-LISTED.**  New, from §2's arm:
  after the break golden lists the declaration's variable BOTH on the task and
  on the body `begin` (`NVARS` 3 vs our 2, `BVARS` 1 vs our −1 in `h_ba145v`).
  We list it once.  `WRONG->WRONG` in pristine and after the fix alike — the
  fix moves the STATEMENT only.  `scope::Compare` reads `Variables`, so this
  one is judge-visible.  Corpus incidence 0 (no corpus database has a
  parameter-bearing TF-ITEM task; the boundary's `MOVED=4` proves it).
* **R2 — the wrapper `begin`'s ANCHOR ignores the break.**  The `items9` loop
  still skips every `VariableDeclaration` when `bodyTfItems9`, so a post-break
  declaration is not counted as a body item for the second-item anchor.
  Dump-only: no generated `Compare` reads `VpiFile` / line / column.
* **R3 — the BLOCK-ITEM body that is nothing but ONE initialised declaration.**
  As the implementer states: slang hands `function void f(); int b1 = 1;
  endfunction` as a bare `VariableDeclStatement`, StmtEmit's list arm is never
  entered, we emit no `Stmt` and one variable where golden's `Stmt` IS the bare
  hoisted assignment and lists two.  Reproduced here as arm D's `n1m0145v` /
  `b1m0145v` (and it is what makes arm D exit rc=4, "unsupported statement
  kind: VariableDeclaration", on BOTH binaries).  Corpus incidence 0.
* **R4 — the surplus DUPLICATE LISTING in the ELAB view.**  Reproduced
  (arm B / arm E).  A separate law about whatever mints the extra listing.
* **R5 — the TF-ITEM local's SPAN.**  Dump-only; no `Compare` reads it.
* **R6 — `= new` under BLOCK-ITEM** stays § `declInitWrittenNewNoStmt66`'s;
  different Surelog sites, not merged.

---

## 6. Files

| file | what it is |
|---|---|
| `v145_[a-h]_*.sv` | the eight adversarial arms |
| `arms145v.sh` | golden/pristine/patched × def/elab, PROCESSED-asserted, uhdm-cmp on each side |
| `bound145v.sh` | the wide boundary (any two binaries) |
| `ARMS.txt` | the arm scores under the FIXED binary — `RIGHT->WRONG` 0, `AWAY` 0 |
| `ARMS.implementer-patch.txt`, `ARMS.h_param.implementer-patch.txt` | the same arms under the IMPLEMENTER's binary — the regressions, as measured |
| `PRIOR_ARMS.txt` | the 22 moved earlier-pass file-views re-scored against golden |
| `BOUNDARY.pris-vs-fix.txt`, `BOUNDARY.pat-vs-fix.txt` | the two wide boundaries |
| `GATES.txt` | every gate, raw |
| `head_fix_*.cmp` | the heads after the fix |
| `ct145cen.cpp`, `score145.py`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `byteverify.sh`, `rowheads.sh` | the campaign's instruments, copied verbatim so this directory reproduces on its own |
