# r10earl54 — ADVERSARIAL VERIFICATION of § connReplFoldNested54

**VERDICT: ACCEPT.** Every headline number in the implementer's report reproduced
bit-for-bit from binaries I built myself at 5bd0a3a, including both md5s, the
patched Earlgrey database md5, the DEF-view md5, and golden's own object id in
the predicted new head. **Zero pristine-right → patched-wrong cells** were found
in 33 arm×view three-way measurements, 48 boundary-arm re-runs of the earl49 /
earl51 / earl52 grids, and 2 311 corpus databases. No fix was required, so the
production diff is unchanged; this directory gains verifier arms and instruments
only.

## What this file adds to README.md

The pass's own instruments (`census54.scan`, and therefore `plainreg54.py` and
`attrib54.py`) read **port-HighConn slots only**. They are structurally blind to
a change anywhere else in the database — a package parameter's own declaration, a
cont-assign RHS, the `uhdmallModules` listing. Every arm below was therefore also
measured with a WHOLE-DUMP instrument (`lm3.py` / `lm3b.py`) and with a
**per-section multiconcat census** (`vpiOpType:34` counted separately inside
`uhdmallModules` and inside `uhdmtopModules`), which is the single number that
settles both the law and its fence:

| a1_earl54, elab | golden | pristine | patched |
|---|---:|---:|---:|
| DEF (`uhdmallModules`) multiconcats | 12 | 12 | **12** |
| ELAB (`uhdmtopModules`) multiconcats | 3 | 11 | **3** |

and design-wide on Earlgrey_0_1/default: DEF 165 / 165 / **165**, ELAB 1796 /
1897 / **1798**. The patched elaborated multiconcat population lands two objects
from golden's across the whole design, and the DEF listing does not move at all.

## The attacks, and what each one measured

| arm | the hypothesis it was built to kill | result |
|---|---|---|
| `v1_v54.sv` | **SHARED SUBTREE.** The arm walks a referenced parameter's INITIALIZER and then rewrites an operand slot of the emitted HighConn. If the emitter shares one UHDM subtree between the parameter's own `param_assign` RHS and the conn, the rewrite would fold a PARAMETER INITIALIZER — earl52-F2's fence — invisibly to `census54.scan`. | **REFUTED.** In the plain view the entire pristine↔patched dump difference is the one conn slot, and the patched `u_pat` `.p` HighConn is field-for-field golden's. The package parameter's declaration is untouched. |
| `v2_v54.sv` | degenerate widths: `{0{…}}`, a zero PACKAGE PARAM count, x and z bodies, count 1, a string body, a 32-wide count. A malformed `BIN:` with no digits or `vpiSize:0` would be a wrong VALUE. | No `vpiSize:0` and no empty `BIN:` is ever minted. The four cells we abstain on are named as **R-V1** below. |
| `v3_v54.sv` | escaped identifiers (`\snk-v3_54`, `\a.port`, `\u.inst`) in module / port / instance / net names — earl53's lesson. | BROKE 0. The one census "BROKE" is a span-frame artefact: golden's columns on an escaped-identifier line run 8 wider than ours, **identically in pristine and patched**, so a span-keyed instrument mispairs two unrelated constants. Pre-existing; named **R-V2**. |
| `v4_v54.sv` | connection FORMS the a-grids never used: positional (ordered) conns, a modport-connected child, an instance array with a named conn, an inout port. | BROKE 0, DEF unchanged, ELAB lands on golden (0/5/0). |
| `v5_v54.sv` | positions reached through a NON-`Operands()` link: a replication inside a part-select bound, a function-call argument, a system-function argument; and depth 5. | BROKE 0. |
| `v6_v54.sv` | macro spans: one macro body holding two replications, one macro invoked twice on a line, a macro inside both ternary arms. | BROKE 0; each invocation keys to a distinct span. |
| `v7_v54.sv` | **IMPLICIT WIDTH CONTEXTS** — the R4 hazard one step over. A ternary whose other arm is wider, a context-determined binary operand, an explicit size cast, a sign cast. A width taken from the wrong node is a wrong VALUE, the worst class this law can produce. | Golden folds `sel ? d : {4{1'b1}}` at the REPLICATION's own width (4), which is what `replBinConst54` uses. No width divergence. The head advances from `u_wid` to `u_cast`, an R1 cell. |
| `v8_v54.sv` | the **earl51 cont-assign LHS boundary**, replicated: whole-signal, struct member, array element, part-select, concat, net-decl-assign, generate-scope cont-assign, and two procedural forms — all holding the same written replication, in the same file as a cell where the law DOES fire. | BROKE 0 in both views and both instruments; ELAB multiconcats 10 golden / 11 pristine / **10** patched. The arm converts the probe from CMP_FAIL to **CMP_EQUAL**. |
| `v9_v54.sv` | **MIS-PAIR WITH DISTINGUISHABLE VALUES.** Every earlier arm replicated the same value in every cell, so a wrong pairing would have been invisible. Here siblings differ in width AND value. | Widths 1 / 3 / 4 / 4 with values `1` / `000` / `1111` / `0000` — each **byte-identical to golden**. |
| `v10_v54.sv` + `pkC_54.sv` | **CROSS-FILE SPAN COLLISION.** A package parameter's initializer replication and a conn-actual replication placed at the SAME (line, col) in two files, with different values, and the parameter referenced from that conn — so `reps` receives two distinct nodes under one key. | The `ambig` guard fires: the patched database is **byte-identical to pristine**. Confirmed non-vacuous — span `6:60-6:70` really is used by both. |
| `v10step1.sv` | spaced based literals in the count (`{4 {1'b0}}`, `{4'd 4{…}}`, `{ 4 { 1'b1 } }`), the shape `setLocShrunk` exists for. | All three fold; the probe goes from CMP_FAIL to **CMP_EQUAL**. |
| `v11_v54.sv` | TRANSITIVE parameter initializers (`PB = {PA, 4'h0}` with the replication in `PA`): the visitor descends one level only. | Abstains — a missed fold, never a wrong one. |
| `v12_v54.sv` | shapes where `tryEval` might succeed and Surelog's reducer fail: a constant FUNCTION CALL count, `$clog2`, `$bits(...)/8`, and six-deep nesting against an uncapped recursive walk. | Golden folds all of them and so do we; patched matches golden's ELAB population exactly (0/9/0). |
| `v13_v54.sv` | the **BIND path widened**: one `bind` statement against a target instantiated TWICE, plus gen-scope instances inside the target. This is the one shape where `hcPrefix` ≠ `prefix`. | The folded constant, including `vpiFullName: work@v13_v54.u_t1.u_bound.pa`, is **byte-identical to golden**. Head 1 → 0. |
| `v14_v54.sv` | **CO-OCCURRENCE with § connPathRootTs53**, which rewrites typespecs on the same `h` immediately before this arm: actuals holding BOTH a hier_path (struct / interface member) and a nested replication. | BROKE 0 on both instruments; slot count exactly golden's. |

## Boundary re-runs: 48/48 byte-identical

Every `.sv` arm of `r10earl49repro` (the walk boundary: `a1 b1 b2 c1 d1 e1 f1 g1`
+ `v1…v8_v49`), `r10earl51repro/i1…i4` (the cont-assign i-grids) and
`r10earl52repro/a1…a4` (the param-initializer a-grids) was run with BOTH binaries
in BOTH views: **24 arms × 2 views = 48 runs, o.dump byte-identical on all 48.**

## Corpus completeness: the law's reach is exactly one row

`v54_pop2.py`-style scanning (reproduced in the report) finds 18 corpus tests
whose sources hold a nested replication inside a port-connection actual. Of those,
**exactly one is comparable — `Earlgrey_0_1` (CMP_NOTEQUAL)**; every other is
`SLANG_REJECT`, `SURELOG_FAIL`, `DEFERRED`, or a source tree that is not a test
row. Two comparable tests hold the shape only in files their `.sl` does not
compile. So gate 5's "1 mover / 953 databases" is the COMPLETE population, and the
u2r half (1 358 databases, 0 movers) contains no instance of the shape at all —
only the depth-0 `ReplicationPassedToInstance`, which the arm deliberately does
not touch. That half is a fence control, not evidence for the law.

`YosysOldSpi` is the corpus over-fire control the pass never ran: it is
`CMP_EQUAL`, and `spi_top.v:280` `.latch(spi_tx_sel[3:0] & {4{wb_we_i}})` is a
nested replication in a port actual with a NON-CONSTANT body. Golden keeps `op34`;
census golden-vs-patched reports `KEEP=1`, `MOVERS=0`, and the database is
byte-identical between the two binaries.

## Instrument controls (an arm agreeing is not an arm testing)

* `census54.py --selftest` passes on MY dumps (MOVERS 4 / KEEP 1 / UNPAIRED 4,
  golden-vs-golden 0 / 1 / 0).
* NULL control: `plainreg54.py` given the same dump as both sides reports
  `FIXED=0 BROKE=0`.
* POLARITY control: with the two sides swapped, a1's 28 FIXED become **28 BROKE** —
  so a `BROKE=0` reading here is a measurement, not a blind spot.
* The whole-dump instrument must EXCLUDE the `\_weaklyReferenced:` tail
  (`lm3b.py`): UHDM parks there any object reachable only by a weak link — a
  folded constant's loc-less `int_typespec` and the `vpiParent` chain that prints
  it — and **golden's tail grows for exactly the same reason** (v3: golden 53
  objects, pristine 45, patched 53). Counting the tail manufactures BROKE lines
  out of back-references.

## Ranked residues found by the verification (none is a regression)

* **R-V1 — an X/Z-BODIED replication is this same law, one guard away.** Golden
  folds `{4{1'bx}}` in a conn actual to `vpiDecompile:XXXX` / `vpiSize:4` /
  `BIN:XXXX` / `vpiConstType:3`, with `vpiParent` = the enclosing operation and a
  conn-scoped `ref_typespec` over a loc-less `int_typespec` — **the identical
  object this pass mints**, differing only in the digit alphabet (`X` uppercase,
  `z` lowercase, measured). `replBinConst54`'s `hasUnknown()` guard abstains.
  Cost: the bit loop plus a two-case map. Highest-value next step for this family.
* **R-V2 — escaped-identifier column frame.** On a line whose module name is
  escaped, golden's columns run 8 wider than ours (`part_select` at `11:50` vs
  `11:42`), identically in both binaries. cmp-invisible (Compare reads no spans),
  but it makes every span-keyed instrument mispair cells on such lines.
* **R-V3 — the fold CASCADES into other arms.** Making an operand constant lets
  pre-existing folds fire behind it: in `v7`'s elab view `4'({2{1'b1}})` becomes a
  single `UINT:3` constant, which no arm produced before. Bounded on the corpus by
  gate 5 (one mover) and on probes by BROKE=0, but it is a real blast-radius
  mechanism the report does not name.
* **R-V4 — `ladcmp54.py`'s join is not a partition.** It keys a dict on the golden
  L line, so rungs sharing one golden site collapse: 33 of my 2 667 pristine
  rungs, and 40/41 of the implementer's 3 113/3 103. `CLEARED + KEPT` therefore
  cannot sum to the rung count, and 8 `<null>`-site rungs share one key. The
  directional reading (a site in one run and not the other) stands.
* **R-V5 — ladder family SIZES are load- and depth-dependent, not properties of
  the base.** Measured before/after at equal `--max=20000 --budget=1500`:

  | | rungs | stop | secs | maxvis |
  |---|---:|---|---:|---|
  | pristine | 2 667 | BUDGET | 1500.4 | 550 765 / 783 183 |
  | patched | 3 202 | BUDGET | 1500.2 | 624 157 / 783 183 |

  The **qualitative** claim reproduces exactly: family
  `constant|VpiType|KIND:constant>operation` **20 -> 7**, of which
  `tlul_fifo_sync.sv:76:69-76:91` **12 -> 0** and `clkmgr_pkg.sv:38:11-38:20`
  **1 -> 0**, and the 7 survivors are the 7 the implementer named (3 loc-less,
  `pwrmgr_pkg:156` = the R4 cast, `pinmux_pkg:20`, `flash_ctrl:137`,
  `alert_handler:87`).  `constant|VpiType|KIND:constant>ref_obj` is untouched
  (2 024 -> 2 041, the delta being depth).  The **absolute** figures are not
  reproducible: the implementer read 44 -> 7 with 36 at the tlul site from a run
  that reached 3 113 rungs / maxvis 610 086; mine reads 20 -> 7 with 12 at 2 667
  rungs / maxvis 550 765.  A ladder family count is a lower bound set by how deep
  that particular run got, and this machine carries other agents' `ctladder`
  processes.  The census's 99 is the population.
* **The ladder's own over-fire signature is flat.** `operation>constant` (golden
  an operation, OURS a constant) is **1 rung before and 1 rung after**, and no
  patched rung sits at the tlul replication site.  The 540 NEW patched rungs are
  the pre-existing `tagged_pattern` / `int_typespec>integer_typespec` /
  `ref_obj>constant` families reached ~74 000 golden objects deeper; the 7
  family names that are new to the patched run are all `tagged_pattern` and
  `hier_path`/`constant` decompile-text families, none replication-related.

## Files

| file | what it is |
|---|---|
| `v1_v54.sv` … `v14_v54.sv`, `pkC_54.sv`, `v10step1.sv` | the verifier arms, one hypothesis each (table above) |
| `v54run3.sh` | three-way arm driver: golden (Surelog) + pristine + patched, one view, cmp + dump per side |
| `v54run3m.sh` | the multi-file variant, for the cross-file span-collision arm |
| `v54lm3.py` | whole-dump three-way line-multiset BROKE / FIXED counter |
| `v54lm3b.py` | the same, restricted to the design (the `weaklyReferenced` tail excluded) |
| `v54pop.py` | corpus population scanner: which TESTS hold a nested replication in a conn actual, attributed to the test whose `.sl` compiles the file |
