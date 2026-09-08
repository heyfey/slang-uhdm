# r10uvm221 — § `uninstIfaceEnumConstNoActual221` — **AN INTERFACE THAT NO INSTANCE ELABORATES GIVES AN ENUM-CONSTANT REFERENCE NO `vpiActual` AT ALL** — the MiniAmiq ×2 head clears

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; they are named only inside `canaudit.sh`'s own `FENCED=`
list, and its `FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f8062cfc` |
| pristine binary | md5 `3165257bc467b3720b4558c24fa4b87b`, built `-j 2` from this pass's OWN worktree at a clean `f8062cfc` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `769b69341dc3d59dab592c3fa80c4983`, frozen `chmod 555` before any sweep |
| production surface | `src/ExprEmit.cpp` and `include/UhdmExporter.h` only. **ONE TERM — `&& !uninstIfaceSubBody218` — on one existing condition, plus its decode. No new flag, no new pass, no new phase, nothing minted, nothing reshaped: the patch only ever DECLINES a mint the pristine emitter made.** |
| probe surface | `tools/probe/r10uvm221repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, re-measured on this pass's own pristine build FIRST | **MiniAmiq ×2, 19 cmp lines / ONE head each**, the two logs byte-identical — the r10uvm220 R0 reproduced exactly. Every other row at BASE: SeqDriver ×2 **0**, SimpleUVM ×2 **0**, Scoreboard/default **0**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. |
| the head after | **THE OBJECT IS GONE.** MiniAmiq ×2 read **152 lines / 1 head**, a NEW object of a different family — the line count rises because it is the NEW head's decompile size, not because anything got worse. golden `func_call: (control_assertion_dpi)` @`svaunit_vpi_interface.sv:310:7` against our `method_func_call: (control_assertion_dpi)` @310:35. **R0.** |
| the law | **CONFIRMED and decoded to Surelog `file:line`.** The only producer of an enum-constant `vpiActual` is `UhdmWriter::lateBinding`'s last resort at UhdmWriter.cpp:**3953-3961** — `mod->getValue(name)` answers and Surelog MINTS a fresh loc-less `enum_const`, parented on the reference. `UhdmWriter::writeInterface` (**1626-1794**), the only writer for an interface DEFINITION, **calls `lateBinding` nowhere**, and an uninstantiated interface has no netlist so it never reaches the elaborated writer's call at :4785 either. The compile-time road cannot stand in: `CompileHelper::bindVariable` (CompileStmt.cpp:**3089**) walks **only** `Variables()` and `Io_decls()` and can never return a constant. **So the law is UNCONDITIONAL — no window, no home, no view carves anything out, and the term carries NO FENCE.** |
| the population (question 2) | Inside `interface_inst work@svaunit_vpi_interface`, ONE view (`uhdmallInterfaces`; an uninstantiated interface has no second listing): **310 reference keys**, calibration null. Pristine `SAME 277 / MISSING-OURS 1 / EXTRA-OURS 16 / OTHER 16`; patched `SAME 293 / MISSING-OURS 1 / EXTRA-OURS 0 / OTHER 16`. **The 16 are the whole enum-constant population — the enum-only census goes from 16 keys, all EXTRA-OURS, to ZERO KEYS ON EITHER SIDE.** By context: **10** are the `return <ENUMCONST>;` values of `get_state_from_reason` (:155-:182) and **6** are the members of the `inside` set at :206. |
| the golden grid (question 3) | **5 arms × 2 views, one REAL Surelog golden each, 0 FAILED arms, every rc checked, golden-vs-golden CALIBRATION null in all 24 arm-view-holder cells, on BOTH binaries.** One body compiled three times in ONE design says it in one line: **the UNINSTANTIATED interface binds 0 of 22 enum constants, its INSTANTIATED twin binds 21 of 22, and a MODULE binds 21 of 21.** `a4_corpus` (the corpus shape) **CLOSES COMPLETELY** — SAME 38 / MISSING 0 / EXTRA 0 / OTHER 0. `a3_muststay` is **byte-identical, cell for cell, in both views**. `MISSING-OURS` never rises in any arm-view: **AWAY-GOLDEN 0, MOVED-WRONG 0.** |
| the a-priori prediction (question 5) | Written and run from PRISTINE databases and PRISTINE sources alone, before the patched binary touched either corpus: the fire set is **6 of 1573** surelog row-modes and **0 of 1462** uhdm2rtlil ones; of the six, four (`AmiqSimpleTestSuite` ×2, `Monitor` ×2) are `SLANG_REJECT` with no database. Predicted **exactly two** surelog movers, `MiniAmiq` ×2, 16 cells each; **zero** uhdm2rtlil; **and NO ROW CONVERSION**, because the holder still carries § 218's R1 and 16 OTHER cells. |
| byte movers | **2 / 956** surelog and **0 / 1358** uhdm2rtlil — **exactly the two predicted, by name, and no others.** The move is **REMOVE-ONLY, proved at the byte level**: the whole-dump diff of the MiniAmiq database with ids normalised is **0 lines added, 144 removed**, and every one of the 144 is accounted for (§7). |
| gates | goldens **23 PASS / 0 FAIL on BOTH binaries**, `/bin/false` control 23 FAIL; uhdm2rtlil **679/50/2 in BOTH modes on both binaries**, `ct8rows` PASS three ways, `byteverify` 0/1358; surelog 1588 rows, status histogram **476/5 default + 470/5 testflags UNCHANGED, cell for cell — NO ROW CONVERTED IN EITHER DIRECTION**; the **NINE** protected CMP_EQUAL row-modes all HELD at judge rc = 0 with both columns scored; wide boundary **LISTED = PROCESSED = 5525, MOVED_ARMS 16, RC_DIFFS 0**, all 16 re-scored against real goldens at **TOWARD-GOLDEN 16 / AWAY 0 / NEITHER 0, BROKEN-CELLS 0**. |

---

## 1. THE HEAD, AND THE PRISTINE BASELINE, MEASURED FIRST

This pass built its own pristine binary from a clean `f8062cfc` worktree; it came
out **byte-identical** to the main tree's binary at that commit
(`3165257b…`). `rowheads.sh` on this pass's own pristine sweep reproduced the
brief's target exactly: **MiniAmiq ×2, 19 cmp lines, ONE head, both modes, and
the two logs are byte-identical to each other.**

```
LHS: <null>
RHS:
decompile:
enum_const: (SVAUNIT_START)
|vpiParent:
\_ref_obj: (work@svaunit_vpi_interface.get_state_from_reason.SVAUNIT_START),
                                                  line:155:20, endln:155:33
|vpiName:SVAUNIT_START
|UINT:606
|vpiDecompile:606
|vpiSize:64
```

`BaseClass.h`'s **SINGULAR** `SafeCompare` with `LHS: <null>` is the mirror of
the buvm13/15 shape: it names OUR value for a field golden left null, and the
only field on a `ref_obj` whose value can be an `enum_const` is
`Actual_group()`. The reference itself is identical on both sides — same kind,
same name, same span, same parent `return_stmt` at 155:13. **We mint an actual
golden does not have.** This is § 218's R4, now surfaced as the head, exactly as
§ 220's R0 said it would be.

The source is `svaunit_vpi_interface.sv:148-186`:

```systemverilog
function svaunit_concurrent_assertion_state_type get_state_from_reason(int a_reason);
   if (a_reason inside { ... }) begin
      if (a_reason == `SVAUNIT_VPI_CB_ASSERTION_START) begin
         return SVAUNIT_START;                      // <- 155:20, the head
```

---

## 2. QUESTION (2) — EVERY CELL, KEYED BY CONTEXT × VIEW

`POPULATION.r10uvm221.txt` carries the full table; `cen221.py` produced it.

There is **ONE VIEW**. An interface no instance elaborates appears in exactly
one listing, `uhdmallInterfaces` — there is no elaborated copy to disagree with.
(The `weaklyReferenced` TAIL re-prints the same objects with a shorter field
set; it is unreachable to the judge, and `cen221.py` cuts every dump at it —
without that cut the scanner manufactures 14 phantom keys.)

**SIXTEEN CELLS, one holder, one view**, every one `g=['-'] o=['enum_const(…)']`:

```
  155:20 SVAUNIT_START        158:20 SVAUNIT_SUCCESS      161:20 SVAUNIT_FAILURE
  164:20 SVAUNIT_STEP_SUCCESS 167:20 SVAUNIT_STEP_FAILURE 170:20 SVAUNIT_DISABLE
  173:20 SVAUNIT_ENABLE       176:20 SVAUNIT_RESET        179:20 SVAUNIT_KILL
  182:17 SVAUNIT_IDLE
  206:34 SVAUNIT_SUCCESS      206:51 SVAUNIT_FAILURE      206:68 SVAUNIT_DISABLE
  206:85 SVAUNIT_ENABLE       206:101 SVAUNIT_RESET       206:116 SVAUNIT_KILL
```

Ten are `return <ENUMCONST>;` statements; six are the members of

```systemverilog
   if (crt_state inside {SVAUNIT_SUCCESS, SVAUNIT_FAILURE, SVAUNIT_DISABLE,
                         SVAUNIT_ENABLE, SVAUNIT_RESET, SVAUNIT_KILL}) begin
```

nested two `if`s deep inside a `foreach` body. All sixteen are constants of
`svaunit_concurrent_assertion_state_type`, a `typedef enum int` declared in
`svaunit_types.svh` and `` `include ``d **inside `svaunit_pkg`** — so the home
is a PACKAGE and the reference is bare-named through a wildcard import.

**THE SHARING (question 4), by identity.** The object we mint is a *fresh,
loc-less* `enum_const` per reference — the shape Surelog's own
`lateBinding` mint has — and the shared `enum_const` that lives in the package's
`enum_typespec` is only **READ** at that site (`enumConstMap.find`), never
re-parented. So declining the mint can orphan nothing and move nothing, and the
measurement says so: the `enum_const` set inside `uhdmallPackages` is
**byte-identical between the two binaries** (same md5 over the sorted multiset),
while the database's total `enum_const` line count falls 4236 → 4204 — exactly
the 16 declined clones and their 16 tail copies.

**§ 218's R5 CHECKED FOR COLLISION.** R5 is the for-loop-iterator asymmetry: our
iterators bind where the PARSE-view golden leaves them bare while the ELAB-view
golden binds them. It is a *different symbol kind* and a *different arm*, and
arm `a5_r5mix` puts the two features in the same statements to prove they do not
touch: in the uninstantiated interface the arm carries **6 enum cells and 7
iterator cells** pristine, and patched it carries **0 enum cells and the same 7
iterator cells**, unchanged, in both views. On § 218's own `a2_window` arm the
five R5 cells (`i218` 42:26 / 42:36 / 44:20, `j218` 48:26 / 48:38) are present on
both binaries in the parse view and absent from both in the elab view — exactly
as R5 records them.

---

## 3. QUESTION (3/4) — THE DECODE, AND WHY THE LAW CARRIES NO FENCE

Full transcript in `DECODE.r10uvm221.txt`, every `file:line` READ in
`~/git-repos/Surelog`. In one paragraph:

> Surelog has two roads to a `vpiActual`. **Road 1**, the compile-time
> `CompileHelper::bindVariable` (CompileStmt.cpp:3089), walks `Variables()` and
> `Io_decls()` and **nothing else** — there is no enum arm in it, so it can
> never answer with a constant, in any holder. **Road 2** is
> `UhdmWriter::lateBinding` (UhdmWriter.cpp:3294); its last resort, :3953-3961,
> asks `mod->getValue(name)` and **MINTS** a fresh loc-less `enum_const` with the
> name, value, decompile and size, parented on the reference. That mint is where
> every enum-constant actual in a module, a package or an elaborated instance
> comes from. Its callers are `writePackage` :1304, `writeModule` :1575 and
> :1623, `writeElabProgram` :2072, and the elaborated-instance writer :4785
> gated `if (mod && netlist)`. **`UhdmWriter::writeInterface` (1626-1794) — the
> only writer for an interface DEFINITION — contains no `lateBinding` call at
> all**, and an interface nothing instantiates has no netlist, so :4785 never
> runs for it either. Road 2 never runs; Road 1 never had it. **There is no
> enum-constant actual to be had.**

**THIS IS THE THIRD LAW ON ONE PRODUCER FACT.** § 218 took Road 2's *variable*
half, § 220 took `lateTypedefBinding`, and this pass takes Road 2's
*enum-constant* half — all three riding one emitter flag,
`uninstIfaceSubBody218`, raised at exactly one call site.

**WHY THERE IS NO FENCE.** § 218 needed a symbol test and a position test
because Road 1 *survives* for an uninstantiated interface and Road 1 has
structure. § 220 needed two fences because `compileDatastructureTypespec`
answers a parameter and a visible type name at COMPILE time. Neither applies
here: the producer is a single write-time site that does not run. The grid tests
the prediction rather than assuming it — **22 reference contexts × 5 enum homes
× 2 golden views, and golden binds ZERO of them** — so the term is a bare
`!uninstIfaceSubBody218` with nothing beside it.

### the gates that were REFUTED, each on a grid arm

| candidate gate | refuted by |
|---|---|
| "this is a § 218 WINDOW question — the window binds and the rest is bare" | a1 35:18 (an `if` condition) and 37:15 (a statement-position call argument) are IN the § 218 window and golden is BARE; 36:13 and 40:16 are outside it and golden is bare too. Golden binds **none** of the 22. |
| "an interface is an interface" | a1 `if221i` — the SAME BODY, instantiated — golden BINDS 21 of 22, and the patch leaves it untouched |
| "it depends where the enum LIVES" | a2_home: the interface's own typedef, an imported package, a `::`-qualified name, `$unit` and a subroutine-local typedef all behave identically — every one bare |
| "the elaborated view is different" | a1/a2/a4/a5 elab: the enum column is IDENTICAL to the parse column in every uninstantiated holder, which is why the law is written view-independent |
| "a module or package might be affected too" | a3_muststay: a package function, an uninstantiated MODULE WITH PORTS, an instantiated PROGRAM and a top module all bind on both sides and are byte-identical between the binaries |
| "an uninstantiated PROGRAM is the same law" | a3 `pr221un` — golden's numbers differ from an interface's, and our answer there is UNCHANGED by this pass (**R1**); `writeProgram` (1795-1900) has no late pass, so the law's PROGRAM twin is real but needs its own flag, exactly as § 218's R2 and § 220's R1 say |

---

## 4. THE LAW

> **§ uninstIfaceEnumConstNoActual221** — a reference to an ENUM CONSTANT in the
> body of a subroutine declared in an interface DEFINITION that no instance
> elaborates gets **NO `vpiActual` OF ANY KIND**, in every context, from every
> enum home, in both views. The fresh `enum_const` our emitter mints there is
> `UhdmWriter::lateBinding`'s object (UhdmWriter.cpp:3953-3961) and
> `UhdmWriter::writeInterface` never calls `lateBinding`.

### STATED GATE == CODE GATE

**STATED:** one existing condition gains one term; no new flag, no fence.

**CODE:** `git diff` vs `f8062cfc` — `include/UhdmExporter.h` gains the decode
paragraph on the existing `uninstIfaceSubBody218` member, and `src/ExprEmit.cpp`
gains its decode comment plus **exactly this**:

```c
     if (nv.symbol.kind == SymbolKind::EnumValue &&
-        !defGenProcessEmit &&
+        !defGenProcessEmit && !uninstIfaceSubBody218 &&
         !(inGenScopeCaRhs &&
```

**REMOVE-ONLY IS THE SAFETY PROPERTY, AND IT IS MEASURED, NOT ASSERTED.** The
term can only skip a `MakeEnum_const()` + `Actual_group()` pair; there is no
branch below it that could set something else instead, and the flag is false
everywhere outside one `emitTaskFuncs` call. The whole-dump diffs prove it: the
corpus mover is **0 lines added / 144 removed**, and each of the four foreign
boundary arms is **0 added / 9 removed**. A reference golden BINDS therefore
stays bound by construction, and every cell the term fires on is a cell the grid
measured golden leaving bare.

---

## 5. QUESTION (5) — THE PREDICTION, AND THE MOVERS

`PREDICT.r10uvm221.txt` + `predict221.sh`, written and run from PRISTINE
databases and PRISTINE sources alone, before the patched binary produced a
single corpus database. Stage 1 asks each row-mode's own `cmds.txt` file set
whether it declares an interface nothing in the set instantiates; stage 2 reads
the PRISTINE database and counts `enum_const` actuals inside its
`uhdmallInterfaces` listing.

* FIRE SET: **6 of 1573** surelog row-modes, **0 of 1462** uhdm2rtlil.
* All six name `svaunit_vpi_interface`; four (`AmiqSimpleTestSuite` ×2,
  `Monitor` ×2) are `SLANG_REJECT` with **no `slang.uhdm` at all**.
* PREDICTED: **exactly two** surelog byte movers, `MiniAmiq` ×2, **16 cells
  each**, all TO-GOLDEN; **zero** uhdm2rtlil; **and NO ROW CONVERSION** — the
  pristine census leaves § 218's R1 and 16 OTHER cells standing, so `MiniAmiq`
  cannot go CMP_EQUAL and a new head of a different family must appear.

**MEASURED: 2 / 956 and 0 / 1358 — the two predicted, by name, and no others**,
with `PATH_SETS_IDENTICAL` on both corpora and SELFCHECK 955/956 and 1357/1358.
16 cells moved in each mode (the two modes' databases carry the same md5).
**No unpredicted mover to attribute** — no layout class, no allocation churn —
because the patch allocates nothing and removes nothing from any container: it
reads one extra `bool` in a condition. `Scoreboard`/default, the ~50/50 coin,
did not move at all on this run.

---

## 6. QUESTION (6) — THE GATES AND THE BOUNDARY

`GATES.r10uvm221.txt` carries every number. Headlines: goldens 23/0 on both
binaries with the `/bin/false` control at 23 FAIL; uhdm2rtlil 679/50/2 in both
modes on both binaries with `ct8rows` PASS three ways and `byteverify` 0/1358;
surelog **476/5 default + 470/5 testflags on BOTH binaries**, `ct8rows` PASS
against the committed baseline AND against this pass's own pristine — **0
differing rows over 1588, status column and dump column, NO ROW CONVERTED IN
EITHER DIRECTION**.

**THE NINE protected CMP_EQUAL row-modes, both columns scored explicitly, judge
rc = 0 on both binaries:** `SeqDriver` ×2, `SimpleUVM` ×2, `Scoreboard`/default,
`BuildUVMPkg` ×2, `Earlgrey_0_1` ×2 — **all HELD**, and none is in the fire set.

Canaries: `canaries.sh` ok=52 changed=0 (surelog) and ok=8 changed=0 (u2r);
`ctcan2.sh` PASS on both; `canaudit.sh` over this pass's drivers **audited=29
UNCOVERED=0 FENCE-BREACH=0**. Protected databases by name, both modes:
**`InterfaceModPort` — AN INSTANTIATED-INTERFACE TEST, and therefore the pin
that matters most for an interface law — SAME**, `BlackParrotComplex` SAME,
`YosysOldOr` SAME, `SVSwitch` pinned at `4842211c4030`, `YosysVerx` pinned at
`6ccda350c24a`.

Wide boundary over a COPY of the whole probe tree (subdirectories included, both
views, both binaries, children `</dev/null`, the file list on fd 3, scratch keyed
on the RELATIVE path): **LISTED = PROCESSED = 5525, MOVED_ARMS 16, RC_DIFFS 0**.
Eight are this pass's own grid arms — the POSITIVE CONTROL that proves the gate
can see. **No § 220 arm moved and no § 220 fence arm. No § 216 arm moved and not
its index fence. No uvm82-91 arm, no sd8-12 arm, no § 215 / § 214 / § 161 /
§ 164 arm moved.** The eight FOREIGN arm-views are four arms, and
`armscore221.sh` re-scored every one against a REAL Surelog golden in both views
(calibration null everywhere): **TOWARD-GOLDEN 16, AWAY-FROM-GOLDEN 0,
NEITHER 0, BROKEN-CELLS 0, FIXED-CELLS 108.** Each foreign arm moved **exactly
one enum-constant cell**, in both views, and nothing else:

```
  r10buvm13repro/v2_reach13.sv             IE13_B 14:43
  r10uvm218repro/grid218/a1_iface/dut.sv   E218_A 33:28   (§ 218's own R4)
  r10uvm218repro/grid218/a2_window/dut.sv  Q218_A 33:18   (§ 218's own R4)
  r10v218repro/arms/b1_kinds/dut.sv        P1V_A  52:18
```

---

## 7. THE CORPUS MOVE, LINE BY LINE

MiniAmiq's whole-dump diff with ids and workdir paths normalised, over 1.89M
lines: **0 lines added, 144 removed**, and every removed line classified:

```
   16  |vpiActual:                     the declined links
   32  \_enum_const:                   16 in uhdmallInterfaces + 16 in the tail
   16  |vpiParent:      \
   16  \_ref_obj:        |  the weaklyReferenced TAIL copy's own six
   16  |vpiName:SVAUNIT* |  fields, one set per declined mint
   16  |UINT:            |
   16  |vpiDecompile:    |
   16  |vpiSize:64      /
    0  UNCLASSIFIED                    16 + 32 + 96 = 144
```

---

## 8. THE FILES

| file | what it is |
|---|---|
| `cen221.py` | THE SCORER — every `ref_obj`/`ref_var` under a holder prefix, keyed (vpiName, line, col) as a MULTISET, valued by the ACTUAL'S KIND **and its name**, so a declined mint can never be confused with a mint that landed on a different constant. Cuts the dump at the `weaklyReferenced` tail. `--enum-only` isolates the law's population; `--diff` is the whole-database form the boundary re-scorer uses. |
| `grid221.sh`, `grid221/`, `score221.sh`, `GRID.r10uvm221.txt`, `GRID.pristine.*`, `GRID.patched.*` | question (3): five arms × two views × both binaries, every rc checked, calibration first. |
| `DECODE.r10uvm221.txt` | question (3/4): the two Surelog roads, read `file:line`, and why the law carries no fence. |
| `POPULATION.r10uvm221.txt` | question (2): the sixteen cells with golden's value beside each, and the whole-holder census on both binaries. |
| `predict221.sh`, `PREDICT.r10uvm221.txt`, `PREDICT.stage.*` | question (5), written and run before the patched binary touched either corpus. |
| `CENSUS.moved-cells.r10uvm221.txt`, `CENSUS.MiniAmiq.wholedump.diff.txt` | the sixteen moved cells, and the REMOVE-ONLY whole-dump proof. |
| `bound221.sh`, `BOUNDARY.r10uvm221.txt`, `armscore221.sh`, `ARMSCORE.r10uvm221.txt` | question (6): the 5525-arm wide boundary and the against-golden re-score of every mover. |
| `GATES.r10uvm221.txt` | every gate number, both binaries. |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the head on both binaries, both modes. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged from their canonical homes. |

---

## 9. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD IS A CALL-STATEMENT'S OWN KIND.** 152 lines, one
  head, both row-modes, the two logs byte-identical. Golden
  `func_call: (control_assertion_dpi)` @`svaunit_vpi_interface.sv:310:7` against
  our `method_func_call: (control_assertion_dpi)` @310:35 — same three
  arguments, same parent `begin`, same callee; only the OBJECT KIND (and the
  span it takes) differs. `reset_assertion` calls the interface's own
  `control_assertion_dpi(a_sva.get_sva_path(), …)`, and because the FIRST
  ARGUMENT is a receiver-qualified method call our emitter renders the whole
  statement through the `hier_path`/method arm and mints a
  `method_func_call` where golden has a plain `func_call` bound to the
  interface's `vpiFunction`. The census sees it as six ours-only keys —
  310:7, 334:7, 358:7, 383:7, 408:7, 434:7 — plus 512:13. A different family
  (call-statement shape, not reference binding). `head_pat_MiniAmiq.default.cmp`
  carries it. **Note the interaction with § 218's R1**: R1's unbound sibling
  formal `a_sim_time` @383:56 sits *inside* one of these very statements, so a
  pass that fixes R0 should re-measure R1 before assuming it is separate.
* **R1 — AN UNINSTANTIATED PROGRAM IS THE SAME PRODUCER FACT AND WE DO NOT TAKE
  IT.** Arm a3 `pr221un`: `UhdmWriter::writeProgram` (1795-1900) has no
  `lateBinding` call either, exactly like `writeInterface`, and our answer there
  is unchanged on both binaries (enum column MISSING-OURS 3 / EXTRA-OURS 2, both
  views, both binaries). This is § 218's R2 and § 220's R1 in the enum-constant
  column: the emitter has no "uninstantiated program" flag to ride, so lifting it
  means raising one, which is its own landing. **0 corpus cells** — the
  predictor's stage 1 found no candidate outside `svaunit_vpi_interface`.
* **R2 — A `::`-QUALIFIED ENUM REFERENCE IS A `constant` IN GOLDEN AND A
  `ref_obj` IN OURS.** Arm a1 53:13 (`p221::PE_B` in the uninstantiated
  interface) and 105:13 (the identical text in the INSTANTIATED one): golden
  FOLDS the qualified name and emits `\_constant: , line:53:13` with **no
  reference at all**, while we emit a `ref_obj`. Pre-existing in BOTH holders on
  BOTH binaries — a FOLD residue of a different family. Declining its actual
  moves the census cell from EXTRA-OURS to OTHER without making it agree or
  disagree any more than it already did, because golden has no reference there
  to agree with; that is the whole of the `OTHER 0 → 1` in a1 and `2 → 3` in a2.
  It is **not** AWAY: no actual golden binds was removed anywhere.
* **R3 — A SUBROUTINE-LOCAL ENUM'S CONSTANT BINDS AN IMPLICIT `logic_net` IN AN
  INSTANTIATED INTERFACE.** Arm a2_home `ifh221i` 72:14 / 75:14: golden answers
  `logic_net(work@toph221.u_ifh.SE_A)` where we answer `enum_const(SE_A)` —
  `lateBinding`'s implicit-net fallback at UhdmWriter.cpp:3966+, reached because
  `mod->getValue` cannot see a name declared inside the subroutine. Pre-existing,
  unchanged on both binaries, and it is the arm's own corroboration that
  `lateBinding` really does run for an instantiated interface. Lifting it is a
  separate law.
* **R4 — § 218's R5 SURVIVES UNCHANGED, AND THAT IS DELIBERATE.** Our for-loop
  iterators bind in an uninstantiated interface where the PARSE-view golden
  leaves them bare, while the ELAB-view golden binds them. Arm a5_r5mix carries
  7 such cells beside the law's 6 enum cells and only the 6 moved; § 218's
  `a2_window` keeps all five of its R5 cells on both binaries. A blanket silence
  would have moved them AWAY in the elab view, which is exactly why this law is
  scoped to `SymbolKind::EnumValue` and nothing else.
