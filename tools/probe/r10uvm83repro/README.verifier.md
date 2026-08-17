# r10uvm83 — ADVERSARIAL VERIFICATION (independent re-measurement)

Verdict: **ACCEPT the law and the patch.  NO code change was needed** — no
pristine-right → patched-wrong cell exists on any legal SV I could write.  Two
of the shipped README's *residue* claims were **REFUTED BY CELLS I BUILT** and
are corrected in place; those are documentation fixes only, so the SHIPPED
BINARY IS UNCHANGED (`8969b56acb68815e8a86747c02153fb4`).

Worktrees `/tmp/wt_v83` (patched) and `/tmp/wt_v83pris` (pristine), both at base
`f5a97aa`.  Every binary, sweep, cmp, ladder and boundary number below was built
and run by the verifier; nothing was copied from the implementer's report.

## Reproduced BIT-FOR-BIT from my own builds

| claim | implementer | verifier |
|---|---|---|
| CONTROL binary md5 | `44956a58cccfce6600c047936ee9fc51` | same |
| SHIPPED binary md5 | `8969b56acb68815e8a86747c02153fb4` | same |
| goldens / negative control | 23 PASS 0 FAIL / 0 PASS 23 FAIL | same |
| surelog 1588 rows, committed vs CONTROL | 0 differing ROWS | same |
| surelog 1588 rows, committed vs SHIPPED | 0 differing ROWS | same |
| surelog CONTROL vs SHIPPED | 0 differing ROWS | same (5 DEFERRED both modes, `GOLDEN_DEFER` `[UNSET]`) |
| u2r both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | same, both binaries |
| u2r committed vs CONTROL / vs SHIPPED / ctl-vs-shipped | 0 / 0 / 0 differing ROWS | same (731 / 731 / 1462) |
| byteverify surelog | MOVERS 7 / 953, SELFCHECK 952/953, SELFCHECK1 8 | same, and the SAME SEVEN databases by name |
| byteverify u2r | MOVERS 0 / 1358, SELFCHECK 1357/1358, SELFCHECK1 1 | same |
| predictor bijection | surelog nonzero on exactly 7 (`2 34`,`4 35`,`8 39`,`4 35` …), u2r 0/1358 | same, every PRED pair to the unit |
| **official heads BEFORE** | 1450011 / 1450011 / 1405511 / 1405511 / 1399779 / 19 / 19 | **same, byte-for-byte** |
| **official heads AFTER** | 54 / 54 / 54 / 54 / 54 / 19 / 19, one head each | **same** |
| the new head object | `constant#25787` @1576:23-1576:44 `vpiDecompile:this` vs `hier_path(this.sequences.size)` | same, read out of my own cmp output |
| BuildUVMPkg head unmoved | a `constant` in `uvm_default_factory::find_override_by_name` | same (`#6934` @12983:53, RHS `<null>`) |
| sd-grid boundary | cells=347 MOVERS=2 NO_OUTPUT(both)=4 | same; the 2 are `r10sd{11,12}repro/grid11/g4.sv` |
| full sd/uvm/buvm boundary | CELLS=923 MOVERS=2 NO_OUTPUT=16, 4 symmetric segfault lines | same |
| grid11 `g4` positive control vs a REAL Surelog golden | 45:5 golden DEF+ELAB, pristine NULL/NULL, patched DEF+ELAB; 33:7 / 35:7 NULL on all three | same, measured with my own instrument |
| `ct11grid` three measures | identical pristine/patched on all 8 grid11 cells | same (12/12/4/10/6/13/4/10 lines, IDENTICAL per cell) |
| canaries / ctcan2 / canaudit | 52+8 / 58+1 changed=0, audited=29 UNCOVERED=0 FENCE-BREACH=0 | same |
| DB md5 pins (5 names, both modes) | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a`/`73a10e8217e5`, YosysOldOr `d68e0796d62c` | **all ten SAME** |
| patch round-trip | applies clean on fresh `f5a97aa`, md5 `2f3752d0372e9730ac09ff9f32a1cff3` | same; my regenerated `git diff f5a97aa` is BYTE-IDENTICAL to the shipped patch |
| `results/*.csv` | read only | `git diff --name-only f5a97aa -- results/` = 0 files |
| fence | four slang-fenced tests never named in this directory | independently grepped: 0 files (canaudit excluded) |

## CENSUS Part 0 (the refutation of the brief) — RE-MEASURED WITH MY OWN TOOL

`v83pkg.cpp` reads the package and design vectors straight off the databases,
independent of `ctfields.inc`.  On **all four** tests, golden / pristine /
patched:

* elaborated `package uvm_pkg`: Variables 33/33/33, Parameters 45/45/45,
  Param_assigns 45/45/45, **Typespecs 89/89/89**, Class_defns 323/323/323,
  Task_funcs 58/58/58 (BuildUVMPkg 26/41/41/89/327/52, all three equal);
  def-view `uvm_pkg` Typespecs 46/46/46, Task_funcs 894/894/894.  Every other
  compared vector NULL on all three.  **There is no package membership deficit
  and no null package vector.  The brief's premise is refuted.**
* the "34" is the DESIGN's: `design::Typespecs` golden 123 / ours 89 on
  SimpleUVM, and golden **125 / ours 91 on Scoreboard** — which is *literally*
  the ladder's "125 vs 91" string, now attributed to the right owner.
  `design::Parameters` and `design::Param_assigns` are golden 45 / ours **NULL**
  (the report says "0"; the vector is null, not empty — a stronger statement in
  the same direction).
* pristine and patched are IDENTICAL on every one of these vectors, so the
  patch moves no listing membership anywhere.

## Breaking the law — 23 arms, all scored against a REAL Surelog golden

`v83score.sh` runs each arm on BOTH binaries plus Surelog, then prints the
`unsupported_typespec` `vpiInstance` **role multiset per (name, span)** three
ways (GOLDEN / PRISTINE / PATCHED) and flags any cell that was
`PRISTINE-RIGHT → PATCHED-WRONG`.  `v83ts.cpp` is my own instrument (it does not
share a line with the pass's tools).  The competing container-scope typedef in
each arm is what makes the class typedef DEGRADE, i.e. what makes the
placeholder exist at all — without it the declaration resolves and the arm tests
nothing (measured: my first draft of arm 02 produced zero placeholders).

Spellings and scopes covered: package free FUNCTION and free TASK bodies;
package free-function BLOCK item; out-of-body method body / `begin` / `fork`
arm / `for` body / `while` body; out-of-body TASK; out-of-body CONSTRUCTOR;
out-of-body method of a VIRTUAL class; self-qualified own typedef and own STRUCT
typedef; parameterized-class owner `zbase#(int)::c_t`; INTERFACE-CLASS owner;
FORWARD-declared class target; typedef CHAIN (the decline arm); NESTED class
owner (`Outer::Inner::td`) and an out-of-body method of a nested class; class in
a MODULE; class at `$unit`; class in an INTERFACE; wildcard IMPORT, EXPLICIT
import, `export`/RE-EXPORT chain, foreign-package owner; generate-block context;
declarator ARRAYS (fixed/queue/dynamic/associative); and two negative controls
(`pkg::td`, bare `td`, plain `int`).

**RESULT: `REGRESSED=0` on every arm.  12 arms convert cells to golden-exact
(`FIXED`), 9 arms are inert on both binaries, 2 arms are unreachable in ours.**

Two things the implementer's report ASSERTED but never witnessed, now measured:

* **the package FREE SUBROUTINE population is real and the patch is right about
  it.**  `v83_a02` / `v83_a03` / `v83_a23` (free function body local, free
  function `begin` local, free task body + block local): golden stamps
  `pkg:DEF(pa*)` + `pkg:ELAB(pa*)`, pristine NULL x2, patched **exactly
  golden**.  The report's parenthetical "a package free function's own package"
  was a guess; it is now a measurement.
* **the in-body / out-of-body split is golden's, not ours.**  Every arm's
  in-body twin is NULL in golden and NULL in both binaries; the out-of-body /
  free-subroutine half moves.  `v83_a06` (class in a module), `v83_a07`
  (`$unit`), `v83_a21` (class in an interface) and `v83_a23`'s NESTED class's
  out-of-body method are all NULL in golden and inert under the patch — the
  `oobHomePkg`-needs-a-PACKAGE-parent gate is golden's own rule.

## What I could NOT break, and where I tried hardest

* the two extra guards the RESOLVED typespec site carries (`sharedClassTypedef9`,
  `foreignSharedTs`) are absent from the new stamp.  That is safe **because
  `makeScopedTdUnsupTs11` mints a FRESH object per declaration**, so there is
  nothing shared to over-scope; `v83_a08` writes the self-qualified own typedef
  AND the own STRUCT typedef of an out-of-body method — the shape those guards
  exist for — and golden stamps them exactly as the patch does.
* `pkgScopeInst` is a MEMBER, so a stale value could in principle leak into a
  module-level `initial` block.  It cannot: `emitTaskFuncs` saves/restores it
  (`TaskFuncEmit.cpp:1558`/`5616`) and the only other writer restores it around
  `emitParameters` alone (`ParamEmit.cpp:17868`/`17881`).  `v83_a06` and
  `v83_a22` exercise module and generate-block contexts and both are inert.
* the `importCopyTsInst` / `importCopyTsCollect` arm really is unexercised: the
  three import arms (`v83_a14` wildcard, `v83_a16` explicit, `v83_a15`
  re-export) show that **ours emits no placeholder object at all** in an
  importing package, so the collected-fixup path cannot be reached.  Structurally
  it mirrors `TaskFuncEmit.cpp:5042-5046` exactly, and the fixup it feeds
  (`UhdmExporter.cpp:4227`) only re-points `Instance` to the ELAB home package —
  the same value the sibling typespecs get.  `v83_a15` is a **slang REJECT**
  (`unknown class or package` on the re-export chain, rc=3 on BOTH binaries) —
  a pre-existing slang limitation, not a crash and not this pass's.

## THE TWO SHIPPED RESIDUE CLAIMS I REFUTED (corrected in `README.md` in place)

1. **the FORMAL / RETURN spelling.**  The shipped bullet said the corpus
   "contains no OUT-OF-BODY method with an `Owner::td` FORMAL, so there is no
   cell that could distinguish the two readings".  `v83_a24_formal_oob.sv` IS
   that cell, and golden distinguishes them: in
   `function zbase24::c_t aderiv24::f_oob(zbase24::c_t a, output zbase24::c_t b)`
   golden stamps the RETURN placeholder (`16:12`) **and both FORMALS**
   (`16:41`, `16:71`) with `pkg:DEF(pa24)`+`pkg:ELAB(pa24)`, while ours leaves
   all three NULL x3 — on the pristine AND the patched binary.  The in-body
   twins are NULL in golden.  So the law extends to § `classScopedTdFormalUnsupported34`
   and to the return-type site, and this is the **first-ranked residue**.
2. **the DECLARATOR-ARRAY sites.**  The shipped bullet said extending them
   "would be a generalisation rather than a measurement".  `v83_a17_arrays.sv`
   makes it a measurement: all four declarator forms inside an out-of-body
   method (`20:5` `[4]`, `21:5` `[$]`, `22:5` `[]`, `23:5` `[string]`) are
   `pkg:DEF(pa17)`+`pkg:ELAB(pa17)` in golden and NULL x2 in ours, both
   binaries; the four in-body twins are NULL in golden.  **Second-ranked
   residue.**

Neither is a regression — pristine and patched are equal on both — so no code
change was made here.  They are now *answered* questions with cells attached.

## Whole-corpus proof that nothing else moved

`v83rows.sh` prints the same three-way instance table over the real sweep
workdirs.  On the four UVM rows, scoped placeholders only:

| row | REGRESSED | FIXED | already equal | residue |
|---|---|---|---|---|
| default SimpleUVM | **0** | 2 | 29 | `496:12` object ABSENT in ours; `1308:33` span `-53` vs `-61` |
| default Scoreboard | **0** | 2 | 29 | the same two |
| default SeqDriver | **0** | 0 (2 MOVED toward golden) | 29 | golden ELAB x5 vs our x3 at `1260:4` / `1434:3` — a placeholder-CLONE MEMBERSHIP residue; plus the two above |
| default BuildUVMPkg | **0** | 1 | 29 | `56591:12` absent, two `16625/16687` span pairs |

**Not one instanced-vs-NULL disagreement remains on any row**, which is the
report's Part-5 claim, independently confirmed.

## The ladder, re-run by me on all seven UVM row-modes

The BEFORE R1 rung's own `MK` line names the object this pass fixed —
`unsupported_typespec(uvm_resource_types::rsrc_q_t)@uvm_sequencer_base.svh:1434:3-1434:23#25354`
— so the instrument had the owner all along and only its FIELD attribution was
wrong, exactly as the report says.  Numbers in `LADDERS.verifier.txt`.

## Instruments added by the verifier (all MEASUREMENT-ONLY)

    g++ -O2 -std=c++17 v83ts.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o v83ts
    g++ -O2 -std=c++17 v83pkg.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o v83pkg

| file | what it is |
|---|---|
| `v83ts.cpp` | every `unsupported_typespec`'s name/span/`vpiInstance` ROLE, plus (`--vars`) the binding variable and its object kind — independent of `ctfields.inc` |
| `v83pkg.cpp` | package and design vector sizes, NULL vs count (the Part-0 re-measurement) |
| `v83arm.sh` | one arm: Surelog golden + ours, official `uhdm-cmp`, dump delta |
| `v83score.sh` | an arm on BOTH binaries + the three-way instance table + the REGRESSED flag |
| `v83rows.sh` | the same three-way table over a real `verify_golden` workdir pair |
| `v83_a02…v83_a24*.sv` | the 23 arms |
| `v83allbound.sh` / `v83sdbound.sh` | the committed boundary scripts with a v83-prefixed output dir (the committed ones write shared `/tmp` paths) |

**NOTE FOR THE NEXT PASS:** the `CELLS=923` / `cells=347` boundary figures were
measured BEFORE these 23 `.sv` arms were added to this directory.  A re-run of
`v83allbound.sh` in a tree that contains them scans **946** cells; the 23 extra
are by construction POSITIVE cells of this law (13 move between the two
binaries, 1 is the slang-rejected re-export arm, 9 are inert).  Measured here,
so it is a known shift and not a surprise.

## Ops notes

* the implementer's DETERMINISM note is real and I hit it from the other side:
  pristine `testflags/SeqDriver` is `4f482d08f546` in MY FULL SWEEP and they
  recorded `13056b5cd98f` for their full sweep and `4f482d08f546` for their
  4-test workdir.  Same binary, different bytes, different workdirs — the
  campaign's known `SourceLocation`-across-macro-buffers nondeterminism.  It
  moves no row, no head and no mover set.
* `ct83inst.cpp` has a latent C++ defect the numbers here do not depend on:
  `const char* rr = !t ? "NULL" : (… ? "pkg:…" : std::string(UhdmName(...)).c_str());`
  dangles for every NON-package target (the temporary dies at the end of the
  full expression).  Every role this pass reads is a package or NULL, so no
  quoted number is affected — but the line should not be reused as-is.

## Ladder numbers (mine)

`LADDERS.verifier.txt`.  Rungs BEFORE→AFTER, my own runs, all seven row-modes:
508→507, 229→228, 230→229, 259→258, 268→267, 229→228, 259→258; `MAXVIS`
identical to the implementer's on every row; `FAM=package|*` 1→0 on five rows and
2→1 on the two SeqDriver rows (survivor
`package|VpiName|TEXT:uvm_pkg|adpcm_pkg`); calib golden-vs-golden RUNGS=0 on
183142 / 187081 / 188084 objects.  **Every figure matches
`LADDERS.r10uvm83.txt`.**

## Ranked residues (measured, with the cell that witnesses each)

| # | residue | corpus reach today | witness |
|---|---|---|---|
| 1 | placeholder **CLONE MEMBERSHIP** — golden clones the `Owner::td` placeholder into MORE elaborated listings than we do (`1260:4` / `1434:3`: golden `DEF x1 + ELAB x5`, ours `DEF x1 + ELAB x3` on SeqDriver) | **all 4 UVM rows**, and it is the family sitting behind the new head | `v83rows.sh` on `default/SeqDriver` |
| 2 | the `this_type::m_typewide_sequences` placeholder golden emits at `496:12` (instanced DEF+ELAB) and **we do not emit at all** | **all 4 UVM rows** | `v83rows.sh`, `v83ts --vars` (golden has the binder, ours has none) |
| 3 | the **§34 FORMAL / RETURN site's SPAN** — golden spans the `Owner::` PREFIX, ours spans the WHOLE written type: corpus `1308:33-53` vs ours `-61` (33+20 vs 33+28 chars); arm cell `12:28-37` vs `-40` and `16:41-50` vs `-53` | **all 4 UVM rows** | `v83_a24_formal_oob.sv` (the arithmetic is exact on both) |
| 4 | the **§34 FORMAL / RETURN site's INSTANCE** — golden stamps the formal and return placeholders of an OUT-OF-BODY method, ours leaves them NULL.  Same site as #3, so ONE change clears both | 0 rows today (the corpus's formals are all in-body) | `v83_a24_formal_oob.sv` (`16:12`, `16:41`, `16:71` golden DEF+ELAB, ours NULL x3) |
| 5 | the **DECLARATOR-ARRAY sites** (4a/4b/4c/5) leave the placeholder uninstanced where golden stamps it | 0 rows today | `v83_a17_arrays.sv` (all four forms, golden DEF+ELAB, ours NULL x2) |
| 6 | ours emits a placeholder golden does NOT have for an out-of-body **CONSTRUCTOR** body local, and now instances it (an EXTRA object either way) | 0 rows | `v83_a18_oob_ctor_virtual.sv` `23:5` |
| 7 | in an IMPORTING package (wildcard / explicit / foreign owner) ours emits **no placeholder object at all** where golden emits one, instanced at the IMPORTING package | related to #1 | `v83_a14`, `v83_a16`, `v83_a20`, `v83_a21` |
| 8 | INSTRUMENT residue: `ctladder`'s `FIELD`/`G=`/`O=` are read off the REFERRER while the identity printed is the TARGET, so a `SafeCompare(lhs,nullptr)` rung can name a field the judge never compared.  Not a database defect; a reading hazard the campaign should stop paying for | every masked-null rung | `LADDERS.verifier.txt` §"caught in the act" |

Residues #3 and #4 are the SAME emitter site and are the cheapest next step:
`scopedTdPrefixSpan11` already exists and `tsInst` is already in scope there.
