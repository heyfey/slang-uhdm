# r10vearl115 — THE ADVERSARIAL VERIFICATION OF r10earl115 — **VERDICT: ACCEPT**

**MEASUREMENT ONLY.** Nothing here is an acceptance judge. The official
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **no row was converted** in either
direction; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests were never
dispatched and are not spelled in any file here.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table.

| | |
|---|---|
| verdict | **ACCEPT — no fix was needed, and none was made.** The production surface of `/tmp/r10earl115.verified.patch` is byte-for-byte the implementer's; this directory is the added evidence. |
| base | `89631b31`, two fresh worktrees, both binaries built by the verifier |
| pristine md5 | `fc4c6d192b7e39bf2e48728a17a6e29f` — **the implementer's number, reproduced exactly** |
| patched md5 | `3c7aef193c82b156aee0ff76a5de2a89` — **the implementer's number, reproduced exactly** |
| headline | Earlgrey_0_1/testflags **37 cmp lines / 1 head → 92 / 1 on a DIFFERENT object**; every other named row's cmp log BYTE-IDENTICAL; all gates green (`VGATES.txt`) |
| adversarial surface | **4 multi-cell arms + 13 single-cell arms**, plus a re-score of **56 committed arm files** from r10earl110–115 and their verifiers, **146 arm/views in all**, each scored by **two independent scorers** |
| the finding that matters | **AWAY = 0 and MOVED-WRONG = 0 everywhere except two cells of r10vearl114's arms, which the implementer's boundary never scored** — and those two are pristine-WRONG → patched-CLOSER, with the judge's verdict byte-identical. **No legal SV was found where pristine was right and patched is wrong.** |

---

## 1. WHAT WAS REPRODUCED BIT FOR BIT

Everything in the implementer's report that is a number was re-measured from
scratch, never carried forward:

* **both binary md5s**, from the verifier's own worktrees and its own builds;
* **goldens** 23/0 on each binary, 0/23 with `SLANG_UHDM=/bin/false`;
* **both corpora, both modes**, four sweeps, `cmds.txt` audited file by file
  (6070 files, one distinct binary path per workdir, zero strays);
* **ct8rows** — six comparisons, **0 differing ROWS** in every one, status AND
  dump column, against the committed baselines and against the verifier's own
  pristine controls;
* **byteverify SELFCHECK=1** — u2r 0/1358, surelog 2/956, and both movers named;
* **the 464-cell prediction**, made again from the PRISTINE databases with a
  DIFFERENT, deliberately fence-free predictor (`vpredict115`): 464 cells in
  exactly one row, 0 cells over all 1358 u2r databases, and 0 cells left
  anywhere after the patch;
* **the attribution** — ORDER-BLIND 949, ADDED 1 (the dump's own header),
  REMOVED 464 `|vpiActual:` + 464 `typespec_member` lines, 29 × 16;
* **the head move**, object and all: golden's `tagged_pattern` at
  `tlul_socket_m1.sv:241:17` is the new head, so the line count going 37 → 92 is
  the new object's decompile size and not a distance;
* **the canary battery**, `canaudit` 29/0/0, and all ten protected pins.

`VGATES.txt` holds every one of those numbers.

---

## 2. THE ADVERSARIAL ARMS — WHAT WAS PUT UNDER LOAD THAT WAS NOT BEFORE

r10earl115's grid varies the path (p1), the root and depth (p2) and the carrier
(p3). It does **not** vary the Lhs SHAPE beyond one bit-select, it has no cell
inside an interface, none with a namesake that is not a variable/net/port, and
its `genAbove` fence rests on an arm (`v4_ctx113`) that also carries r10earl113's
namesakes. These arms close those axes.

### 2a. the single-cell arms (`cells/`) — one face each, in arm p1's package

The **enum member in the packed struct is load-bearing** and was measured, not
assumed: an all-`logic` packed-struct port draws an unrelated `vpiNetType` head
that stops the judge before it ever reaches a path element (`m1.sv` vs `m3.sv`
in the verifier's scratch: 30 lines / unrelated head vs 37 lines / the law's
head). Every cell here therefore uses p1's package shape, and six of them let the
judge speak directly.

| cell | the face | golden | pristine → patched |
|---|---|---|---|
| `w1_memlhs` | MemberAccess Lhs, target in the MODULE BODY | trailing **bare** | unchanged — **the law does not fire** (residue R-B) |
| `w2_outergen` | whole-name Lhs, target declared in the ENCLOSING gen block | bare | **37 cmp lines / 1 head → 0 / 0, FULLY CMP-EQUAL** |
| `w3_genarr` | bit-select Lhs into a GEN-LOCAL array | bare | **TO-GOLDEN** (12 cells, PX) |
| `w4_selmem` | MemberAccess OF an element select, module-scope array | bare | unchanged — the law does not fire (R-B) |
| `w5_nestinst` | ONE child module with a gen-local pattern and NO namesake, instantiated at module scope AND inside a generate block | binds under the gen-instantiated copy, bare under the module-scope one | **37 / 1 → 0 / 0, FULLY CMP-EQUAL — the `genAbove` fence is exactly right, on an arm that carries nothing else** |
| `w6_iface` | a gen scope inside an INTERFACE | bare | already bare on both sides (24 cells) — nothing to move |
| `w7_nestpat` | a NESTED assignment pattern | bare | unchanged — the walk does not descend (R-C) |
| `w8_nsparam` | namesake is a module-scope **PARAMETER** | **bare** | unchanged — **the fence trips where the prose says it should not** (R-A) |
| `w9_nsinst` | namesake is a **MODULE INSTANCE** name | **bare** | unchanged (R-A) |
| `w10_nsblk` | namesake is a **GENERATE-BLOCK LABEL** | **bare** | unchanged, and the arm's head IS the law's head (`LHS: <null>` vs our `typespec_member`) — 37 / 1 both binaries (R-A) |
| `w11_nssib` | the name exists ONLY in an unrelated sibling module | bare | **37 / 1 → 0 / 0, FULLY CMP-EQUAL — the fence does NOT over-reach across siblings** |
| `w12_deep2` | gen-for inside gen-for, no module boundary | bare | **37 / 1 → 0 / 0, FULLY CMP-EQUAL** |
| `w13_concat` | a hier_path inside a CONCATENATION operand | bare | head moves 37 / 1 → 17 / 1; the direct operands go TO-GOLDEN, the concat's own path does not (R-C) |

### 2b. the multi-cell arms

`va1_lhs115` (six Lhs shapes), `va2_ctx115` (interface / nested instance / two
module boundaries below a gen block / depth 2), `va3_rhs115` (nested pattern,
mixed path lengths, `default:` key, concat, repeated path, interface-array root),
`va4_name115` (six namesake kinds including the parent-module and sibling-module
cases). Scores in `VGRID.txt`.

### 2c. THE SCORE — two scorers, 146 arm/views, and the one number that matters

```
AWAY = 0  and  MOVED-WRONG = 0
   * on all 8 arm/views of the four multi-cell arms
   * on all 26 arm/views of the thirteen single-cell arms
   * on 110 of the 112 arm/views of the 56 committed arm files (section 3)
   * in BOTH scorers: r10earl115's own sig115.py (PX/P0) and vsig115.py (VX/V0)
   * golden-vs-golden CALIBRATION clean on every one of them (all SAME_AGREE)
```

`vsig115` is the verifier's own instrument and exists because `sig115`'s key
carries **no instance path** and its payload is a **SET**: every instance's copy
of a cell collapses into one key, so an arm that instantiates the same child four
ways — which is what a fence arm is — cannot say which instance moved, and a
change in the NUMBER of bound copies is invisible. `vsig115` keys on the parent
chain (`gen_inst[0]` and `gen_inst[1]` are different keys) and compares
Counters. It agrees with `sig115` on every arm it was pointed at, and it is what
turned the two `MOVED-WRONG` cells of section 3 into a measured "strictly
closer".

---

## 3. THE GAP IN THE IMPLEMENTER'S BOUNDARY — FOUND, MEASURED, AND HARMLESS

**r10earl115's `wide115.sh` runs every arm file with NO `-top` and from a
STAGED COPY of the single `.sv`.** r10vearl114's four arms `` `include`` a sibling
package file, so a copied single file fails to compile — on BOTH binaries — and
they land in the uncounted `no_output=392` bucket. They are absent from
`BOUNDARY_WIDE.diff` and absent from `BOUNDARY_arms.txt` (27 arm files × 2 views
= the 54 the implementer scored).

Run the way the implementer's OWN arm driver runs them (`grid115.sh`: the arm's
own `-top`, `--nobuiltin`, compiled in place), **all four differ between the two
binaries**, and two of them score `MOVED-WRONG` under the implementer's own
scorer:

| arm/view | implementer's scorer | verifier's scorer | the judge |
|---|---|---|---|
| `v1_root114_elab` | **PX MOVEDWRONG=6**, P0 MOVEDWRONG=6, AWAY 0 | VX **MOVEDCLOSER=6**, AWAY 0 | cmp log **BYTE-IDENTICAL**, 118 / 1 |
| `v4_carrier114_elab` | P0 **MOVEDWRONG=3**, AWAY 0 | V0 **MOVEDCLOSER=15**, AWAY 0 | cmp log **BYTE-IDENTICAL**, 477 / 1 |
| `v2_gen114_elab` | PX TOGOLD=24, AWAY 0, MOVEDWRONG 0 | VX MOVEDCLOSER=24 | 5644 / 1 → 5560 / 1, **same head object** |
| `v3_iface114_elab` | PX TOGOLD=6, AWAY 0, MOVEDWRONG 0 | AWAY 0 | cmp log **BYTE-IDENTICAL**, 58 / 1 |

The six `v1_root114` cells are `x9_2d[i][0].v` — a 2-D unpacked array root, a
MIDDLE `bit_select`: golden `{<null>}`, pristine `{array_var}`, patched
`{<null>, array_var}`. **Nothing that was right became wrong**; the payload set
merely stopped being pure. Read off the LIVE gen-scope tree (`gs2` on both
databases) every element of both `g[0]` and `g[1]` is cleared in the patched
database — the residual bound copies are OTHER live copies of the same paths,
i.e. r10earl115's own **R1 multiplicity** residue surfacing, not an asymmetry
between generate instances.

**`vwide115.sh`** is the corrected instrument: it reads every committed
`TOPS.txt` under `tools/probe`, runs the arm it names with THAT top,
`--nobuiltin`, **compiled in place**, both views, both frozen binaries.

```
LISTED=130  PROCESSED=130  identical=218  DIFFERING=40  no_output=2
rc by side: 0/256 3/2 4/2 on A and on B alike -- perfectly symmetric
DIFFERING 40 = the 30 arm files the implementer scored
             + the 4 r10vearl114 arms it could not see
             + 6 of this verifier's own new arms
```

Every one of the 40 is scored in `VBOUNDARY_arms.txt` / `VGRID.txt`.

---

## 4. WHERE THE IMPLEMENTER'S PROSE IS WRONG

The README claims, under **STATED GATE == CODE GATE**: *"There is no condition in
the code that is absent from the prose and none in the prose that is absent from
the code."* **That is false, in the safe direction, and three arm cells measure
it.** The prose's namesake exception reads *"a gen-local target whose NAME ALSO
EXISTS as a variable, net or port of the enclosing module"*; the code is

```cpp
if (auto* ns9 = w9->find(std::string(lsym115->name)); ns9 && ns9 != lsym115)
```

and `Scope::find` answers **any** member of that scope. `w8_nsparam` (a
`localparam`), `w9_nsinst` (a module instance) and `w10_nsblk` (a generate-block
label) are all gen-local pattern targets whose namesake is none of variable, net
or port; **golden leaves their trailing element bare** and the shipped code
declines the law on all three. The law as stated fires there; the code does not.

Two further prose-vs-code gaps, same direction: the law says "a `hier_path` that
is an OPERAND of an assignment-pattern operation", and `w7_nestpat` / `w13_concat`
show that a path one level down (inside a nested pattern, inside a concatenation)
is bare in golden and is not reached; and `w1_memlhs` / `w4_selmem` show that a
MemberAccess Lhs never reaches the record site at all, although the stated gate
("its Lhs type is a packed struct") admits it.

None of these is a regression — every one is `STILLWRONG → STILLWRONG`. They are
ranked in section 5.

---

## 5. RESIDUES, RANKED

* **R-A — THE NAMESAKE FENCE IS KIND-BLIND (3 measured cells, 0 corpus
  population).** `Scope::find` fences on a parameter, a module instance or a
  generate-block label as readily as on a variable. `cells/w8_nsparam.sv`,
  `w9_nsinst.sv`, `w10_nsblk.sv` are the arms; `w10`'s head IS this law's head,
  so it is the cheapest one to re-open. Narrowing the test to
  variable / net / port keeps r10vearl113's `v1_decl113` a3/a7 and `v6_name113`
  g2/g5 (which are exactly those kinds) and gains these three. **Not shipped
  here: it is a law change with zero corpus population, and a verifier does not
  widen a gated law.**
* **R-B — THE MemberAccess Lhs NEVER REACHES THE RECORD SITE.** `w1_memlhs`
  (module-body target) and `w4_selmem` (`arr[i].lo`) are gen-scope structured
  patterns onto a packed struct whose trailing element golden leaves bare and we
  bind. 4 and 12 cells respectively.
* **R-C — ONE LEVEL DOWN IS OUT OF REACH.** A `hier_path` inside a nested
  pattern (`w7_nestpat`) or inside a concatenation operand (`w13_concat`) is bare
  in golden and bound here. `w13`'s head moves 37 → 17 with the patch, so this is
  what is left standing on that arm.
* **R-D — THE WIDE BOUNDARY'S BLIND SPOT IS STRUCTURAL, not this pass's.**
  `wide115.sh` silently excluded 392 file/views; four of them are committed arms
  of the immediately preceding verifier. Any future pass inheriting that driver
  inherits the hole. `vwide115.sh` here is the repair and should be the one that
  is copied forward.
* **R-E — R1 MULTIPLICITY CAPS THE LAW'S REACH.** Our live tree holds two copies
  of a gen-scope pattern's `hier_path` operands where golden holds one
  (`v1_root114`: 36 cleared, 36 not; Earlgrey: 227175 element rows against
  golden's 223529). The consumer walk reaches the gen-scope copy only. Both the
  implementer's predictor and the consumer share that blind spot, which is why
  `PREDICT_sl_AFTER` reads 0 — it is 0 *for the copies the walk can see*.

---

## 6. FILES

| file | what it is |
|---|---|
| `VGATES.txt` | every gate, re-run from scratch, with its number |
| `VGRID.txt` | the adversarial arms scored by BOTH scorers, plain and elab |
| `VBOUNDARY_arms.txt` / `.cmp.txt` | the 56 committed arm files × 2 views, two-scorer score and the official cmp line/head counts |
| `VWIDE.tally` / `.diff` / `.rc_by_side` | the top-aware, compiled-in-place wide boundary and its symmetric rc histogram |
| `VPREDICT.txt` | the verifier's own fence-free prediction, before and after |
| `VCENSUS_Earlgrey.txt` | the one moving corpus row, cell by cell, with its golden-vs-golden calibration |
| `VATTRIB_Earlgrey.txt`, `VATTRIB_Scoreboard_coin.txt` | the order-blind whole-dump attribution of both byte movers |
| `VHEADS_pristine.txt` / `VHEADS_patched.txt`, `VHEAD_*_Earlgrey_testflags.cmp` | the seven named rows before and after, and the head object either side |
| `vsig115.cpp` / `vsig115.py` | the instance-keyed MULTISET element census and scorer |
| `vpredict115.cpp` | the fence-free mover predictor |
| `vwide115.sh` | the top-aware, in-place wide boundary |
| `va1_lhs115.sv` `va2_ctx115.sv` `va3_rhs115.sv` `va4_name115.sv` | the four multi-cell adversarial arms |
| `cells/w*.sv`, `cells/TOPS.txt` | the thirteen single-cell arms, one face each |

Build the C++ instruments with

```
g++ -O2 -std=c++17 <tool>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <tool>
```
