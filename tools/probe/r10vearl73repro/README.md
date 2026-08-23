# r10vearl73 — ADVERSARIAL VERIFICATION of r10earl73 (§ ovActReduceIntOp73)

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10earl73.patch` needs no fix. Every
headline number was reproduced bit-for-bit from binaries this verifier built
itself, and **AWAY-GOLDEN is 0 in every measurement taken here** — seven
adversarial grids × two views, 25 boundary arms × two views, Earlgrey both
modes, and both corpora.

**MEASUREMENT ONLY.** The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is
the sole judge. **BASE `6c74d2a`.** `results/*.csv` was READ ONLY and is
untouched; **no row was converted**.

---

## 1. Reproduction of the implementer's numbers

Two fresh worktrees at `6c74d2a`, both built `-j 2` and frozen `chmod 555`
before any sweep; `SLANG_UHDM` exported explicitly per binary; **every
`cmds.txt` audited by binary PATH** (u2r 1458/1458, surelog 1523/1523 name the
frozen path, never the main-tree binary).

| | verifier's own build | implementer's claim |
|---|---|---|
| pristine md5 | `26fbd8c01ce0de4b3e257726f388de86` (= the main tree's build) | same |
| patched md5 | `edd438d853959c11079678996909266b` | same |

| gate | measured here |
|---|---|
| goldens | patched 23/0, pristine 23/0, `/bin/false` **0/23** |
| uhdm2rtlil, both modes | **679 / 50 / 2**, **0 differing ROWS** (status AND dump) vs the committed baseline, vs my own pristine sweep, and patched-vs-pristine |
| surelog, `--mode both`, 1588 rows | **0 differing ROWS**; histogram 937 CMP_EQUAL / 19 CMP_NOTEQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM, identical on both binaries. **NO row converted.** |
| byte movers, u2r | **0 / 1358** (SELFCHECK 1357/1358 flagged) |
| byte movers, surelog | **3 / 956** — see §2 |
| heads (`rowheads.sh`) | Earlgrey **64 → 36, 1 head → 1 head, BOTH modes**; SeqDriver 60, SimpleUVM 17, Scoreboard 29, MiniAmiq 348, BuildUVMPkg 32, Rggen 0 (rc=0) — **all unchanged** |
| head files | my `HEAD_BEFORE_*` / `HEAD_AFTER_*` are **byte-identical** to the committed ones in both modes |
| canaries | 52 ok / 0 changed; 8 ok / 0 changed; both `ctcan2` PASS; `canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected DBs | all five byte-identical, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` on pin |
| Earlgrey `param_assign` census | `msjoin73.py`: default shared 28,655 **TO-GOLDEN 12 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 182**; testflags shared 36,735 **TO-GOLDEN 20 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 182**. Golden-vs-golden calibration: 31,897 cells, **0 differing**. |
| R0 range census (`rngcen73`) | 90,076 shared cells, **9 (ct,tag)-only disagreements, byte-for-byte the same 9 before and after** (6 golden-INT/ours-UINT + 3 INVERTED) |
| boundary WIDE | `PROCESSED=3346 identical=6368 DIFFERING=50 no_output=274` — **exactly the implementer's tally** |
| boundary DIR | `PROCESSED=1485 identical=2685 DIFFERING=42 no_output=243` — **exactly the implementer's tally** |
| patch hygiene | `git apply` (no `-3`) clean on a FRESH `6c74d2a`; production surface = `src/ParamEmit.cpp` **+263 / −0** and nothing else; fenced-name scan 0/0/0/0 |

## 2. The THIRD byte mover — and why it is not the law

My surelog byteverify reported **3** movers, not 2: the two predicted Earlgrey
databases **plus `./default/Scoreboard-59431470`**. Attributed the way RESUME §9
requires:

```
raw path-normalised dump diff : 92 lines over 1,099,496
ORDER-BLIND (both dumps sorted): 0 lines
```

That is the documented Scoreboard/default ~50/50 `svunit_pkg vpiTaskFunc`
list-ORDER coin, to the line. **It is not a mover of this law.** The
implementer's run happened to land the same side of the coin; mine did not.
Any future gate on this row must sort before it diffs.

## 3. Independent mover PREDICTION, from pristine databases only

`vpredict73.sh` (stage 1: any `param_assign` payload disagreement between
golden and PRISTINE) then `vpredict2.sh` (stage 2: the LAW's own shape — a
`param_assign` Rhs constant where golden and ours disagree on `vpiConstType`
7-vs-9 with the SAME digits). The four slang-fenced tests are FENCED-SKIPped
and are never named in any artifact here.

```
uhdm2rtlil : 0 of 1358 databases carry the shape  ->  0 can move  ->  0 moved
surelog    : default/Earlgrey_0_1  cells=12       ->  MOVED (census TO-GOLDEN 12)
             testflags/Earlgrey_0_1 cells=20      ->  MOVED (census TO-GOLDEN 20)
             default/BuildUVMPkg   cells=2        ->  did NOT move  (refused)
             testflags/BuildUVMPkg cells=2        ->  did NOT move  (refused)
```

The cell counts predicted from the pristine databases are **exactly** the
TO-GOLDEN counts the patched databases delivered. `VPREDICT_*.txt`.

**Correction to the implementer's README.** It attributes BuildUVMPkg's 2
non-moving cells to "R3 — the three refused ACTUAL shapes" (unsized based
literal / comparison / XOR). They are neither: the object is
`uvm_pkg::UVM_CORE_POST_INIT`, an **enum-typed parameter in a PACKAGE** whose
Rhs is `INT:3` in golden and `UINT:3` in ours, with no arithmetic anywhere.
It is refused for a different (and correct) reason — the declaration arm is
gated `!inPackage` and the initializer is not arithmetic. The number (2) and
the conclusion (it must not move) are right; the attribution is not.

## 4. Breaking the law — seven adversarial grids, both views

`gen_v73.py` generates v1–v5; `v6_v73.sv` / `v7_v73.sv` are hand-built.
Scored 3-way (golden / pristine / patched) with a MULTISET join over a
**NO-SPAN, judge-fields-only payload** (`vjoin73.py`), and **span PRESENCE
scored in a SEPARATE column** because golden's constant here is span-carrying
while some of ours are not. Both the `param_assign` census (`pacen73`) and an
independent **ALL-CONSTANT** census (`vcen73.cpp`, every `constant` the
listener reaches, keyed on the parent chain plus the owning
`param_assign`/`cont_assign` Lhs name) were run on every arm.

| arm | what it crosses | shared cells | TO-GOLDEN | **AWAY-GOLDEN** | MOVED-WRONG |
|---|---|---:|---:|---:|---:|
| v1 | 46 actual shapes × 6 declared types: `/ % * - + << >> >>> & \| ^ ~^ == != < <= > >= && \|\| === !==`, unary `- + ! ~ & \| ^`, ternary (both branches), `int'() signed'() unsigned'() 16'()`, `$signed $unsigned $clog2 $bits`, concat, replication, literals (decimal/based/sized/unsized/signed), parent-parameter ref, package-qualified ref, enum member, nested/deep arithmetic, `/0`, 64-bit overflow | 1521 | 144 | **0** | 12 |
| v2 | the DECLARATION call site (~13158): the same shapes as `localparam`/`parameter`, `int` / `integer` / `int signed` / `bit [15:0]` / untyped | 1389 | 12 | **0** | 6 |
| v3 | **declared-type matrix**: `bit`/`logic`/`logic signed`/untyped at widths **1,2,3,7,8,9,15,16,17,31,32,33,63,64,65** + `byte`/`shortint`/`longint`/`longint unsigned`/`int unsigned`/`integer unsigned`/typedef'd, × 12 arithmetic actuals | 3496 | **1008** | **0** | 0 |
| v4 | homes and binding forms: 1–3 instances, **nested overrides** (parent's fold feeds the child's), **positional** overrides, **`defparam`**, **instance arrays**, gen-for, gen-if, nested gen-for inside gen-if | 142 | 50 | **0** | 0 |
| v5 | non-integral formals: `real`, `string`, `enum`, packed `struct`, package-qualified `real`/`string`, `$rtoi`, real→int cast | 119 | 4 | **0** | 0 |
| v6 | truncated leaves, **package-level** arithmetic localparams, **interface** parameters, negative leaves, `2**30/62/64/100`, a 6-deep localparam chain, hop-through-a-hop, and the **unpacked-array-dimension carrier** (R0's own family) | 213 | 42 | **0** | 6 |
| v7 | X/Z operands, `$size/$high/$low/$bits`, element-select and part-select operands, signed based literals | 108 | 10 | **0** | 6 |
| **total, per view** | | **6988** | **1270** | **0** | **30** |

Both views give the **same numbers, cell for cell**. Span presence is
identical between pristine and patched on every arm (`SPAN_DIFF` equal on both
sides of every golden-vs-ours comparison).

### 4a. A census trap this verification walked into, and the fix

An all-constant census keyed on the parent chain ALONE reported
**AWAY-GOLDEN 22** on v2 and **4** on v4/elab. Every one was a PHANTOM: an
unnamed `param_assign` (or a parentless constant) collapses hundreds of cells
into ONE key, and a sorted positional multiset pairing inside that bucket
re-shuffles the moment any payload changes. Two independent proofs:

* keying each constant by its owning `param_assign`'s **Lhs name** drops the
  AWAY count to **0** on both arms — with no other change;
* on `r10v64repro/v1_srcs64.sv` the single residual AWAY lived in the `-`
  (parentless) bucket, which holds **47 golden constants against 97 of ours**;
  excluding that one bucket gives `TO-GOLDEN 10 / AWAY 0 / MOVED-WRONG 0 /
  SPAN_DIFF 0`. Parentless constants are the weaklyReferenced tail and are
  unreachable to the judge anyway.

RESUME §9's "NODEDUP censuses manufacture AWAY-GOLDEN phantoms" is exact: a
census must be keyed at least as finely as the object it scores.

### 4b. Two measured FALSIFICATIONS of the README's digit model (judge-neutral)

The README states the digits are "the MATHEMATICAL fold computed as 64-bit
words, with its own sign". Golden disagrees in two shapes. **Neither is a
regression** — the pristine binary printed the same wrong digits under a
`UINT:` tag, `expr::Compare` reads `VpiDecompile` *before* `vpiConstType`, and
the cell is unequal on both binaries — but the model as written is not what
golden does.

1. **A TRUNCATED LEAF.** `localparam bit [7:0] T8 = 16'h1234;` (v6)

   | actual | golden | pristine | patched |
   |---|---|---|---|
   | `.P(T8 * 2)` | `INT:9320` (= 4660·2) | `UINT:104` | `INT:104` |
   | `.P(T8 - 1)` | `INT:4659` | `UINT:51` | `INT:51` |
   | `.P(T4 * 2)`, `logic [3:0] T4 = 8'hAB` | `INT:342` | `UINT:22` | `INT:22` |

   Surelog feeds the **untruncated literal** (4660) into an override actual's
   arithmetic; `ovMath73` feeds slang's **stored** value (52). The README
   justifies the stored-value reading by citing r10vrgg18's
   § genLpFoldRefValueNotInitializer18v — but **that measurement was taken in a
   different context** (`localparam bit [7:0] TRD = T8 + 8'(g)` in a GEN SCOPE,
   where golden really does give 52/53). The two contexts answer differently,
   and the override-actual context is the one this law owns.

2. **A SIGNED BASED LITERAL.** (v7)

   | actual | golden | pristine | patched |
   |---|---|---|---|
   | `.P(8'sh80 * 2)` | `INT:256` | `UINT:-256` | `INT:-256` |
   | `.P(-8'sh80)` | `INT:-128` | `UINT:128` | `INT:128` |

   Surelog reads the literal's **magnitude** (128), we read slang's signed
   value (−128) — the same `'s`-drop the file's own ~12890 note records as "an
   override-path rule". Ranked R-A/R-B below.

### 4c. Shapes the arm REFUSES, confirmed refused (no over-claim)

`/0` (golden leaves an `operation`), `^`/`~^`, `===`/`!==`, `==`/`!=`/`<`/`<=`
comparisons, unary `!`/`~`/`&`/`|`/`^`, unary `+` (golden leaves an
`operation`), unsized based literals, `>>>`, concat/replication, `real`,
`string`, `2**64`/`2**100` (golden wraps to `INT:-9223372036854775808`; the
arm refuses on the `__int128` cap), and every explicit cast. All keep the
pristine encoding exactly; all were unequal before and after.

## 5. Boundary — recursive per-file AND per-directory, from a COPY, no filter

A COPY of the whole `tools/probe` tree, `.sv` and `.v` at ANY depth, both
views, both frozen binaries, workdir-normalised whole-dump byte compare; the
file list is read on **fd 3**, children `</dev/null`, `PROCESSED` asserted
equal to LISTED, `rc` recorded per cell. Sharded 6 ways; tallies summed.

```
WIDE  PROCESSED=3346  identical=6368  DIFFERING=50  no_output=274   (3346 == LISTED)
DIR   PROCESSED=1485  identical=2685  DIFFERING=42  no_output=243   (1485 == LISTED)
rc: WIDE {0:12350, 3:528, 4:486, 139:20}   DIR {0:5264, 3:476, 4:190, 139:10}
```

**Every rc=139 cell pairs A with B** (10 sources wide, 5 dirs, all `--elabuhdm`)
— pre-existing segfaults on BOTH binaries, no new crash and no new timeout.

**All 25 moved sources adjudicated** (`VARMSCORE.txt`, `varm73.sh`): golden
rebuilt with Surelog per arm, official `uhdm-cmp` counted pristine-vs-patched,
and both censuses scored 3-way.

* **Every one of the 25 arms has an IDENTICAL official `uhdm-cmp` line count
  pristine vs patched, in BOTH views.** No arm's judge count gets worse.
* **AWAY-GOLDEN 0 in all 50 cells** in the `param_assign` census and — after
  §4a's key fix — in the all-constant census too.
* `r10vearl71repro/v3_enc71.sv` MOVED-WRONG 2 is one object (`B5`) seen twice:
  `UINT:12 ts=-` → `INT:12 ts=-` against golden `INT:12 ts=int_typespec`. It
  moved ONTO golden on the fields this law owns; the residue is the missing
  `ref_typespec`, a different and pre-existing defect.
* `r10uvm75repro` / `r10uvm76repro` appear only in the DIR walk: raw diffs of
  10–18 lines over 9,154–23,569, and **0 lines once both dumps are sorted** —
  the documented `design::Task_funcs` list-ORDER coin.
* The named boundaries hold: § genCaNestedModuleLhsOpRhsBinds59's binder-mirror
  arms, the port `High_conn` law arms (earl61–69), the assignment-pattern /
  `tagged_pattern` arms, and every uvm/buvm arm except the two coins and the
  layout artifact below are byte-identical between the two binaries in both
  views.

### 5a. `r10buvm22repro/g22.sv` is NOT this law's — proved with a NEUTRAL RELAYOUT binary

Independent replication of the implementer's control, built the other way
round: a THIRD binary from the **PRISTINE** source with only a semantically
inert 4096-byte pad appended to `src/ParamEmit.cpp`
(md5 `bd25fe19cfade13b853139a159bb0c2f`). Re-running all 25 moved sources
against the pristine binary with it leaves **exactly one differing, in both
views: `r10buvm22repro/g22.sv`** — 48 of 50 cells byte-identical
(`VNEUTRAL.txt`).

The disputed cell is the range right bound of `typedef C22 ka_cls_t[string];`,
where golden writes `STRING:associative` / ct 6 and we write an `operation`
over a number that tracks the BINARY's allocation layout:

```
pristine 22371705   patched 22375801   pristine+inert-pad 22375833
```

and it is invariant to a 200 kB environment pad for a given binary.
**`g22.sv` declares no `parameter` or `localparam` at all**, so the arm — which
lives inside `emitParameters` — cannot fire on it. R5 stands, correctly
attributed and correctly ranked.

## 6. Residues, as measured here (R0–R5 from the implementer's README stand)

* **R-A (new, ranked with R2/R3)** — the TRUNCATED-LEAF digits (§4b.1). The
  fix is a producer-side rule: in an OVERRIDE ACTUAL an arithmetic leaf
  contributes its **written literal**, not slang's stored (truncated) value —
  the opposite of the gen-scope rule rgg18's verifier measured. 6 grid cells,
  0 corpus cells; judge-neutral today because the tag moved and the decompile
  did not.
* **R-B (new)** — the SIGNED-BASED-LITERAL leaf sign (§4b.2). 4 grid cells,
  0 corpus cells.
* **R-C (new, documentation)** — BuildUVMPkg's 2 refused cells are a
  package-homed ENUM-typed parameter, not one of R3's three actual shapes
  (§3). Whoever picks up R3 should not expect BuildUVMPkg to fall with it.
* **R-D (new, method)** — Scoreboard/default flipped its documented coin in
  this verification (§2). Any pass whose gate reads that database must sort
  before it diffs, or it will report a phantom mover.
* **R0 confirmed independently.** `rngcen73` on Earlgrey/default: the 9
  (ct,tag)-only range disagreements are **byte-for-byte identical before and
  after** this pass, 6 in one direction and 3 INVERTED — so the fix at the
  array-var / typespec range carrier must be an INHERITANCE rule, not a sign
  rule, exactly as the implementer wrote. The new head
  (`VHEAD_AFTER_*.cmp`, 36 lines, 1 head, both modes) is
  `prim_generic_ram_1p.sv:31:30-31:35`, `INT:32768` ct 7 vs `UINT:32768` ct 9
  under `constant <- operation <- range <- array_var(mem)`.

## 7. Instruments in this directory

* `gen_v73.py <v1|v2|v3|v4|v5>` — regenerate the adversarial grids;
  `v6_v73.sv`, `v7_v73.sv` — the hand-built ones.
* `vcen73.cpp` — ALL-CONSTANT census, direct `.uhdm` reader; payload is
  judge-visible fields only, **span in a separate column**; keyed on the parent
  chain plus the owning `param_assign`/`cont_assign` Lhs name (see §4a).
  Build: `g++ -O2 -std=c++17 vcen73.cpp -I ~/.local/include -L ~/.local/lib64
  -L ~/.local/lib -luhdm -lcapnp -lkj -o vcen73`.
* `vjoin73.py <golden> <ours> [--base <base>]` — 3-way MULTISET join;
  scores TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / STILL-RIGHT and
  prints every AWAY and MOVED-WRONG cell with its G/B/O payloads; span scored
  separately.
* `varm73.sh <file.sv> <outdir>` — one arm: Surelog golden + both frozen
  binaries in both views + both censuses + the official `uhdm-cmp` count.
* `vpredict73.sh <pristine-workdir> <out>` then `vpredict2.sh <workdir> <out>` —
  the two-stage mover prediction from PRISTINE databases only (FENCED-SKIP on
  the four slang-fenced tests).
* `vwide73v.sh` / `vdir73v.sh` — the recursive per-file / per-directory
  boundary (fd-3 list, `</dev/null` children, PROCESSED asserted, rc per cell).
* `vneutral73.sh` — the NEUTRAL RELAYOUT control over the moved-source list.
* Artifacts: `VHEAD_{BEFORE,AFTER}_{default,testflags}.cmp`,
  `VGRID_SCORE.txt`, `VARMSCORE.txt`, `VBOUNDARY_{WIDE,DIR}.{tally,diff}`,
  `VNEUTRAL.txt`, `VPREDICT_{sl,u2r}.txt`.

No integration, commit, main-tree edit, `results/` edit, stash or fenced-test
dispatch belongs to this verification.
