# r10uvm215 — § `modportNeedsSimplePort215` — **A MODPORT OBJECT IS MINTED BY ITS *SIMPLE PORT* ITEMS AND BY NOTHING ELSE: A MODPORT WHOSE ITEMS ARE ONLY `clocking`/`import`/`export` HAS NO `modport` OBJECT IN GOLDEN, IN ANY VIEW** — the SeqDriver head clears on both row-modes and our modport population is exactly golden's on every row of both corpora

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; the corpus predictor walks a sweep workdir that contains
them, so `scrub215.sh` redacts their names out of every artifact — reading the
fence list out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s
own `FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b7eb7ff3` |
| pristine binary | md5 `49b83611ebc24e7155c5e62e6c8e23e2`, built `-j 2` from this pass's OWN worktree at a clean `b7eb7ff3` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `5c5c3503c01fc9a957f4099deb0ba401`, frozen `chmod 555` |
| production surface | `src/ModuleEmit.cpp` ONLY — **+73 / −2 lines, of which 60 are the decoded comment**. One predicate, one filter inside the collector all three modport emission sites already share, and one three-line conjunct on the port view's existing filter. No new pass, no new phase, nothing re-parented, and the dropped objects are never MINTED rather than minted and abandoned. |
| probe surface | `tools/probe/r10uvm215repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, re-measured on this pass's own pristine build FIRST | **SeqDriver ×2, 209 cmp lines / ONE head each**, exactly what r10uvm214's R0 handed over. Every other row at BASE: SimpleUVM ×2 **0**, Scoreboard/default **0**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**; MiniAmiq ×2 is the sister pass's head and is untouched here. |
| the shape (question 1) | the **VECTOR** overload, decoded with the field table and not guessed: `interface_inst::Modports()` — `vpiType 606` — is a **NULL POINTER on golden** and a **one-element vector on ours**, so `BaseClass.h:220-222` set `m_failedRhs` to the **OWNER** and left `m_failedLhs` unset. That is why the judge printed `LHS: <null>` with a full RHS: the object in the log is OUR def-listing `interface_inst work@adpcm_if`, not a field value. |
| the head after | **THE OBJECT IS GONE.** SeqDriver ×2 now stop on `module_inst work@top_tb` with a `vpiNet` **vector SIZE mismatch, golden 224 nets vs our 191** — a NEW head object, both containers named, and the string `mon_mp` appears **nowhere** in either new log. R0. |
| the law | **CONFIRMED, decoded to Surelog `file:line`, and closed corpus-wide.** `CompileModule.cpp:1321` is the only road into `m_modportSignalMap`; a clocking item goes to a DIFFERENT map and the tf/hierarchical branches record nothing at all; both UHDM writers iterate that one map. § 4. |
| the population (question 2) | SeqDriver holds **2 interface_inst objects per side** (the def listing and the elaborated `ADPCM`). Golden: **MPNULL on both**. Ours: **`mon_mp` with a NULL io_decl list on both**. Golden's whole `uhdm-dump` contains **zero** occurrences of `mon_mp`; ours contained exactly **two**, and after the patch **zero**. Nothing on either side references the object. |
| the golden grid (question 3) | **5 arms × 2 views = 10 arm-views, one REAL Surelog golden each, 0 NO-DATABASE, golden-vs-golden CALIBRATION null in all 10.** Arm **A** (the law, 8 item-kind cells) closes **10/10 → 0/0** in BOTH views; arm **E** (the corpus shape + a virtual interface qualified by the dropped modport) **2/4 → 0/0**; arm **C** (ports qualified by modports, 6 cells) **7/15 → 0/0** in the parse view; arm **D**, the MUST-STAY control, is **0/0 before and after**. **No `ONLY-GOLDEN` row survives anywhere except arm B's three pre-existing interface-in-an-interface rows, and over the ten arm-views together ONLY-GOLDEN falls 43 → 6 and ONLY-OURS 83 → 10.** § 5. |
| the a-priori prediction (question 5) | Written from PRISTINE databases alone, BEFORE the patched sweep existed: **exactly TWO row-modes over 956 surelog databases — `SeqDriver` default and testflags, 2 cells each, TO-GOLDEN 2 / AWAY 0** — and **none of the 1358** uhdm2rtlil databases. |
| byte movers | **3 / 956** surelog: `SeqDriver` default + testflags, **exactly the two predicted BY NAME** (12 dump lines each, every one a pristine-only `mon_mp` line, nothing added), plus `Scoreboard`/default — **THE COIN**, 0 differing lines over 1 100 422 sorted dump lines on a database holding zero interfaces and zero modports. **0 / 1358** uhdm2rtlil. SELFCHECK controls fire at 955/956 and 1357/1358. |
| the protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `SimpleUVM` ×2, `Earlgrey_0_1` ×2 and `Scoreboard`/default — **all seven CMP_EQUAL on BOTH binaries at judge rc = 0, both columns scored, and NONE of them is a byte mover** (§ 7). |
| gates | goldens **23 PASS / 0 FAIL on BOTH binaries**, `/bin/false` negative control 23 FAIL; uhdm2rtlil **679 / 50 / 2 in BOTH modes on both binaries**, `ct8rows` PASS against the committed baseline and both controls, `byteverify` 0/1358; surelog **475/6 default + 469/6 testflags on both binaries — no row converted in either direction**; wide boundary **LISTED = PROCESSED**, RC_DIFFS 0. § 7. |

---

## 1. THE HEAD, AND THE PRISTINE BASELINE, MEASURED FIRST

This pass built its own pristine binary from a clean `b7eb7ff3` worktree; it came
out **byte-identical** to the main tree's binary at that commit
(`49b83611…`). Before a line was written: `check_goldens.sh` 23 PASS / 0 FAIL
with the `/bin/false` control at 23 FAIL; both uhdm2rtlil sweeps 679/50/2 with
`ct8rows` PASS against the committed baseline; the surelog sweep reproducing the
committed status histogram exactly (475/6 + 469/6).

`rowheads.sh` on that sweep:

```
SeqDriver ×2 209/1   (the head)
```

and the head itself (`head_pris_SeqDriver.default.cmp`, identical in testflags):

```
LHS: <null>
RHS:
decompile:
interface_inst: work@adpcm_if (work@adpcm_if), id:291911,
  file:.../SeqDriver/design.sv, line:1:1, endln:16:23
|vpiParent:
\_design: (work@top_tb), id:1
|vpiNet: … ×4   |vpiModport: modport (mon_mp)   |vpiClockingBlock: … |vpiEndLabel
```

**AN OPS TRAP, PAID FOR HERE.** `SeqDriver`'s default and testflags goldens are
DIFFERENT cache entries (RESUME §9). A first decode read the golden path out of
the first `cmds.txt` that `find` returned — the *testflags* one — and compared it
against the *default* database: the head came back as a completely different
object (`design work@top_tb`, an `AllPackages`-side mismatch) and the field
table was meaningless. **Always take the golden from the row's OWN mode
directory.** `rowheads.sh` does; a hand-rolled `find | head -1` does not.

## 2. QUESTION (1) — THE SHAPE, DECODED BEFORE ANY FIELD WAS NAMED

RESUME §9: `LHS: <null>` with a full RHS is produced by **two** different
overloads of `BaseClass::SafeCompare`, and they mean opposite things —
the SINGULAR one (`BaseClass.h:194-196`) names the **field VALUE** and the owner
is not printed; the VECTOR one (`BaseClass.h:220-222`) names the **OWNER** when
golden's vector POINTER is null and ours is non-empty, and the field is not
printed. `ct215fields` (descended from r10uvm212's shape decoder, re-pointed at
the RESTORE HANDLE's design the way `uhdm-cmp` itself does) settles it by
printing every `GetByVpiType` edge of the head and of its face-matched
counterpart:

```
HEAD LHS(golden) = <null>
HEAD RHS(ours)   = interface_inst()@1:1-16:23#291911
COUNTERPART CANDIDATES on the golden side: 1
  >>> vpiType=36    golden: VEC size 4 [0]=logic_net(clk)      ours: VEC size 4 [0]=logic_net(clk)
  >>> vpiType=81    golden: SING design(work@top_tb)           ours: SING design(work@top_tb)
  >>> vpiType=606   golden: -                                  ours: VEC size 1 [0]=modport(mon_mp)@14:11-14:17
  >>> vpiType=650   golden: VEC size 1 [0]=clocking_block(cb)  ours: VEC size 1 [0]=clocking_block(cb)
```

`vpiType 606` is `vpiModport`, and `interface_inst::Compare` reads
`Modports()` at its second vector field (generated `interface_inst.cpp`), before
`Clocking_blocks()`. So the head is the VECTOR arm, the owner is our def-listing
interface, and the **question is a POPULATION question: which modports exist**.

## 3. QUESTION (2) — THE POPULATION, BOTH SIDES, BOTH VIEWS

`POPULATION.r10uvm215.txt`. SeqDriver's design has ONE interface, `adpcm_if`
(`design.sv:1`), whose only modport is `modport mon_mp (clocking cb);`. Each side
carries exactly two `interface_inst` objects for it — the def listing under
`design->AllInterfaces` and the elaborated `ADPCM` under the top module:

| | golden | ours (pristine) | ours (patched) |
|---|---|---|---|
| def listing `work@adpcm_if` | nets 4, **Modports NULLVEC**, clocking 1 | nets 4, **Modports size 1 (`mon_mp`, Io_decls NULL)**, clocking 1 | nets 4, **Modports NULLVEC**, clocking 1 |
| elaborated `ADPCM` | vars 4, **Modports NULLVEC**, clocking 1 | vars 4, **Modports size 1 (`mon_mp`, Io_decls NULL)**, clocking 1 | vars 4, **Modports NULLVEC**, clocking 1 |

The whole-dump check agrees and is stronger than the census: `uhdm-dump` of
golden contains **zero** lines mentioning `mon_mp`; ours contained exactly two
(the two objects), and **nothing on either side references them** — no port
LowConn, no `virtual adpcm_if.mon_mp` typespec, nothing. Dropping them dangles
no reference, which is question (2)'s real content.

## 4. QUESTION (4) — THE SURELOG MECHANISM, AND OUR EMISSION ROAD

**Surelog.** `CompileModule.cpp:1264-1352` walks a `Modport_item`'s port
declarations and routes each KIND to a different place:

| item | Surelog | lands in |
|---|---|---|
| `Modport_simple_ports_declaration` (`input a`, `output b`, and the explicit `.P(expr)` form) | `insertModPort(name, Signal, nodeId)` — `CompileModule.cpp:1321` | `m_modportSignalMap` (`ModuleDefinition.cpp:76-86`, its ONLY writer) |
| `clocking cb` | `insertModPort(name, ClockingBlock&)` — `CompileModule.cpp:1346` | `m_modportClockingBlockMap` — **a different map** (`ModuleDefinition.cpp:112-123`) |
| `Modport_tf_ports_declaration` (`import`/`export`) | — | **nothing: the branch body is empty** (`CompileModule.cpp:1327-1329`) |
| `Modport_hierarchical_ports_declaration` | — | **nothing: the branch body is empty** (`CompileModule.cpp:1325-1326`) |

Both writers — `UhdmWriter.cpp:1684-1719` for the def listing and `:4267-4301`
for an elaborated instance — iterate `getModPortSignalMap()` and nothing else.
Surelog then calls `m->Modports(dest_modports)` **unconditionally**, so the
vector is always set; but an EMPTY vector is not serialised, and it restores as
a NULL pointer. That is the whole distance from `modport mon_mp (clocking cb);`
to `LHS: <null>`.

**Ours.** Three sites mint modports — the def listing
(`ModuleEmit.cpp` `emitInterfaceDef`), the col-0 reference dup (`makeIfaceRefDup`)
and the elaborated/port view — and **all three take their list from the one
collector `sortedModports`**. That is where the law is gated, so no site can
mint what another drops, and a dropped modport is never CREATED (`Serializer::
Make*` mints into `AllObjects` whether or not anything points at the result).

**The discriminator is our own io_decl list.** slang's `ModportSymbol::fromSyntax`
(`MemberSymbols.cpp:334-417`) produces a `ModportPortSymbol` for the simple form
and ONLY for it — subroutine items become `MethodPrototypeSymbol`, a clocking
item a `ModportClockingSymbol` — and our io_decl loop already filters on
`SymbolKind::ModportPort`. So "at least one `ModportPortSymbol`" is Surelog's
"at least one entry in `m_modportSignalMap`", one for one, and no new traversal
was needed.

## 5. QUESTION (3) — THE GOLDEN GRID

`grid215.sh` + `grid215/`, five arms × two views (`-parse -d coveruhdm
-nobuiltin -nocache`, then again with `-elabuhdm`), one REAL Surelog golden each
(`~/git-repos/Surelog/build/bin/surelog`, the one `scripts/verify_golden.py`
names), every rc recorded. The per-arm `uhdm-cmp` verdict is RECORDED and is
**NOT** the scorer (r10uvm210's caution: `-nobuiltin` makes golden's
`AllPackages` one entry shorter than ours, so every arm's head is that vector
mismatch). The scorer is the MODPORT census `ct215mpcen` + `cen215.py`, keyed
`<defname>|<instance name>|<parent KIND>` × modport × io_decls, with `MPNULL`
(a null vector POINTER — what the head means) distinguished from `MPEMPTY`, and
golden-vs-golden CALIBRATED FIRST in every cell (**null in all 10**).
Transcripts: `GRID.pristine.r10uvm215.txt`, `GRID.patched.r10uvm215.txt`.

| arm | what it varies | parse ONLY-G/ONLY-O pris → pat | elab pris → pat | verdict |
|---|---|---|---|---|
| **A** `a_kinds` | **THE LAW** — eight interfaces, one modport each: simple ports (a1), clocking only (a2), `import` only (a3), `export` only (a4), clocking+simple (a5), two clocking items (a6), an explicit `.P(r[3:0])` port (a7), `import`+clocking (a8) | 10/10 → **0/0** | 10/10 → **0/0** | **the separation is TOTAL**: golden mints a1, a5, a7 and mints nothing for a2, a3, a4, a6, a8 — and in every surviving cell golden's io_decl list is the one we already build |
| **B** `b_views` | **THE VIEW CONJUNCT** — the same pair of modports reached as a def listing, an elaborated instance, an interface instantiated TWICE, one NEVER instantiated, and one instantiated INSIDE another interface | 3/9 → **3/1** | 3/9 → **3/1** | every law cell closes in every view; the residue is PRE-EXISTING and unrelated (§ 8 R1) |
| **C** `c_topology` | **THE BINDING RISK** — module ports qualified by a clocking-only modport (c1), by a simple one (c2, the control), both at once (c3), two SIMPLE modports with the port on one (c4), a clocking-only modport beside a simple one (c5), and three modports with the port on the clocking-only one (c6) | 7/15 → **0/0** | 6/22 → **0/8** | closes, **including the port-view conjunct** the arm decoded (below); the elab residue is the pre-existing port-view doubling (§ 8 R2) and ONLY-GOLDEN there is **0** |
| **D** `d_muststay` | **THE MUST-STAY CONTROL** — plain in/out/inout, a `ref` member (§ modportRefDirInout), interface HEADER-PORT members (§ modportHdrPortNetKeyword), the three expression-port forms (§ modportExprPort), and a one-item modport | **0/0 → 0/0** | **0/0 → 0/0** | census-identical on the two binaries: no earlier landing's cell moves |
| **E** `e_virtual` | **THE CORPUS SHAPE** — SeqDriver's interface minimised, plus a class holding it as `virtual e1_if.mon_mp` and a control holding a simple-modport one | 2/4 → **0/0** | 2/4 → **0/0** | the virtual-interface reference does not need the object, exactly as golden says |

**THE PORT-VIEW CONJUNCT, MEASURED NOT ASSUMED.** Our elaborated port view
already filtered its modport list to the CONNECTED modport. Arm C cell **c4**
(two simple modports, port qualified by `mps1`) confirms that filter against
golden — golden lists `mps1` alone. But cell **c6** (`mpc` clocking-only plus
`mpa` and `mpb`, port qualified by `mpc`) has golden listing **BOTH `mpa` and
`mpb`**, and cell c3's `a` view the same way: when the connected modport was
never minted, the filter matches nothing and the view falls back to EVERY minted
modport. Reading that fallback off the ALREADY-FILTERED collector is what makes
the two conjuncts one rule, and it is three lines.

## 6. QUESTION (5) — THE A-PRIORI PREDICTION

`ct215pred` + `predictall215.sh`, run on the PRISTINE workdirs **before the
patched sweep existed**. § `modportNeedsSimplePort215` removes exactly the
modports we mint with an EMPTY io_decl list, so a row can move iff our own
pristine database holds one; for each such row the row's OWN golden is loaded
and every empty modport checked against golden's census for a modport of the
same name on the same interface view (a hit would be an AWAY cell).

```
surelog:     rows scanned=956   PREDICTED MOVERS=2   golden missing=0   rows with AWAY>0 = 0
  FIRE SeqDriver default   emptyModports=2 TO-GOLDEN=2 AWAY=0
  FIRE SeqDriver testflags emptyModports=2 TO-GOLDEN=2 AWAY=0
uhdm2rtlil:  rows scanned=1358  PREDICTED MOVERS=0   golden missing=0   rows with AWAY>0 = 0
```

`PREDICT.surelog.r10uvm215.txt`, `PREDICT.uhdm2rtlil.r10uvm215.txt`.

## 7. QUESTION (6) — THE GATES

Full transcript in `GATES.r10uvm215.txt`; the wide boundary in
`BOUNDARY.r10uvm215.txt` + `ARMSCORE.r10uvm215.txt` + `FALSEMOVERS.r10uvm215.txt`.

| gate | result |
|---|---|
| goldens | **23 PASS / 0 FAIL on BOTH binaries**, `SLANG_UHDM` exported explicitly per binary; `/bin/false` negative control **0 PASS / 23 FAIL** |
| uhdm2rtlil | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in BOTH modes on BOTH binaries**; `ct8rows` PASS against the committed baseline and against both `/tmp` controls; **all 1458 `cmds.txt` audited by binary PATH** (1458 patched-wd → `pat.bin`, 1458 pristine-wd → `pris.bin`) |
| uhdm2rtlil bytes | `byteverify` **MOVERS 0 / 1358**, SELFCHECK control 1357/1358 |
| surelog rows | **475/6 default + 469/6 testflags on BOTH binaries — NO ROW CONVERTED in either direction.** `ct8rows` vs the committed `results/golden_surelog.csv` PASS on both binaries, and patched-vs-this-pass's-own-pristine **0 differing rows over 1588**. Against the `/tmp` control CSV exactly one row-SIDE moves — `Earlgrey_0_1,testflags`, status **CMP_EQUAL on both sides**, only the informational uhdm-dump column flipping to `differ` — and it flips on the **PRISTINE** binary too, so it is the recorded Earlgrey dump TIMEOUT and not this patch |
| surelog bytes | `byteverify` **MOVERS 3 / 956**, SELFCHECK control 955/956. **SeqDriver default + testflags = the two predicted BY NAME**; attributed ORDER-BLIND at **12 differing dump lines each, every one of them a `>` (pristine-only) line of the two `mon_mp` modport objects — nothing added.** The third is **Scoreboard/default, THE COIN**: **0 differing lines over 1 100 422** sorted dump lines, and its database holds **zero interfaces and zero modports** |
| the seven CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `SimpleUVM` ×2, `Earlgrey_0_1` ×2, `Scoreboard`/default — **0 cmp lines, 0 heads, judge rc = 0 on BOTH binaries**, and **not one of them is a byte mover** |
| canaries | surelog `ok=52 changed=0`, u2r `ok=8 changed=0`; `ctcan2` PASS on both; `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected databases | all **20** name×mode pins **SAME**, including `InterfaceModPort` (the byte-identical INTERFACE canary — its `modport MEM(clocking cb, input clock);` keeps the object because of the `input clock`), `BlackParrotComplex`, `YosysOldOr`, and the two literal pins `SVSwitch 4842211c4030` / `YosysVerx 6ccda350c24a` |
| wide boundary | **LISTED 5510 = PROCESSED 5510**, PRODUCED_DBS 5317, **RC_DIFFS 0**, MOVED_ARMS 8 — four of them THIS pass's own grid arms (the positive control; `d_muststay.sv` correctly did NOT move), one an earlier pass's arm the law FIXES (`r10v125repro/arms/v7_recv.sv`, `modport mp (import fetch);`, **3/3 → 0/0 in both views**), and three the STATIC-ADDRESS FALSE MOVER (below) |

**THE THREE FALSE MOVERS, CONVICTED NOT ASSUMED.** `r10buvm22repro/g22.sv`,
`r10uvm154repro/l154_noenum.sv` and `r10uvm185repro/grid185/g185_e_kinds.sv`
contain the word `interface` and the word `modport` **zero** times, and the
modport census reads 0/0/0 on both binaries. Each binary is byte-DETERMINISTIC
over three runs. Their whole-dump difference is 4–6 lines in every case and is
the SAME single 64-bit UINT constant — **22744825 pristine vs 22740729 patched,
exactly 4096 apart**, the one page by which the patched binary **SHRANK**
(22 589 768 → 22 585 672 bytes) — and **every differing line sits below the
dump's `\_weaklyReferenced:` marker**, which the judge cannot reach.
`l154_noenum.sv` is r10uvm154's own LAYOUT PROOF source, written to demonstrate
exactly this artefact. `FALSEMOVERS.r10uvm215.txt` carries all three diffs.

## 8. RESIDUES

* **R0 — THE NEW SeqDriver HEAD IS THE TOP MODULE'S NET LIST.** Both row-modes
  now stop on `module_inst work@top_tb` (`testbench.sv:210`) with a **`vpiNet`
  vector SIZE mismatch — golden 224, ours 191**. Both containers are named, so
  it is the VECTOR arm with both sides present: 33 nets golden lists in the top
  module and we do not. `head_pat_SeqDriver.*.head400.cmp` carry the first 400
  lines of each (the full logs are 1.3 M lines — the two module decompiles).
* **R1 — AN INTERFACE THAT INSTANTIATES AN INTERFACE IS MISSING ENTIRELY.**
  Grid arm B cell b4: golden carries `work@b4_outer_if` in the def listing AND
  as the elaborated `u4`, with its modport; we emit **neither object**, and we
  parent the inner interface at the `module_inst` where golden parents it at the
  enclosing `interface_inst`. Three ONLY-GOLDEN rows and one ONLY-OURS row, in
  both views, on both binaries — PRE-EXISTING and untouched by this pass.
* **R2 — THE ELABORATED PORT VIEW IS DOUBLED.** Grid arm C, `-elabuhdm` view:
  we emit two `interface_inst` objects per elaborated instance where golden
  emits one, so each modport is listed twice (8 ONLY-OURS rows, ONLY-GOLDEN 0).
  PRE-EXISTING; the law makes it strictly smaller (22 → 8) and never larger.
* **R3 — THE HIERARCHICAL MODPORT ITEM IS UNMEASURED.** Surelog's
  `Modport_hierarchical_ports_declaration` branch is empty, so golden would mint
  nothing for it either; slang's modport parser has no such item kind
  (`MemberSymbols.cpp:344-414` is exhaustive over three kinds), so the shape
  cannot reach our emitter and no arm could be written for it. Recorded as a
  gap in the grid, not as a claim.

## 9. THE FILES

| file | what it is |
|---|---|
| `ct215fields.cpp` | question (1): the SHAPE decoder — every `GetByVpiType` edge of the head and its face-matched counterpart, singular vs vector distinguished. Uses the RESTORE HANDLE's design, as `uhdm-cmp` does. |
| `ct215ifpop.cpp` | question (2): every `interface_inst` in a database with its view, its vector states and its modports' io_decls. |
| `ct215mpcen.cpp`, `cen215.py` | THE SCORER: the modport census and its multiset join. |
| `ct215pred.cpp`, `predictall215.sh` | question (5): the a-priori mover prediction from pristine databases. |
| `grid215.sh`, `grid215/` | question (3): the golden grid, five arms × two views. |
| `DECODE.r10uvm215.txt`, `POPULATION.r10uvm215.txt` | the transcripts for §§ 2–3. |
| `GRID.pristine.r10uvm215.txt`, `GRID.patched.r10uvm215.txt` | the grid on both binaries. |
| `PREDICT.*.r10uvm215.txt` | the prediction, both corpora. |
| `GATES.r10uvm215.txt`, `BOUNDARY.r10uvm215.txt`, `BOUNDARY.movers.r10uvm215.txt`, `ARMSCORE.r10uvm215.txt`, `FALSEMOVERS.r10uvm215.txt` | question (6). |
| `armscore215.sh`, `protdb215.sh` | the boundary re-score and the protected-database pins. |
| `head_pris_*.cmp`, `head_pat_*.head400.cmp` | the head on both binaries. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` `bound215.sh` `scrub215.sh` | the standing gate scripts, copied unchanged (`bound215.sh` and `scrub215.sh` re-headed for this pass). |
