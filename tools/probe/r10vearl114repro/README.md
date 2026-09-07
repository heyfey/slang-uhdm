# r10vearl114 — ADVERSARIAL VERIFICATION of r10earl114 § `patHierPathRootTs114`

**VERDICT: ACCEPT.**  Both binaries rebuilt from scratch reproduce the
implementer's md5s bit-for-bit; every headline gate reproduces; and the law
survives every face this verifier could aim at it — **AWAY 0 and MOVED-WRONG 0
across 18 database triples, with 5356 hung typespec-edge instances in the
patched databases and not ONE of them a payload golden does not hold at the
same span+name.**  What did NOT survive is part of the README's *prose*: four
of its face readings are contradicted by its own committed arms (§4 below).
None of them changes the code's behaviour, its safety, or the verdict.

**MEASUREMENT-ONLY.**  Nothing in this directory is an acceptance judge.  The
official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities.  slang was NOT patched;
`results/*.csv` were READ ONLY; nothing was promoted and NO CORPUS ROW
CONVERTED; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests were never
dispatched and are named nowhere here outside `canaudit.sh`'s own `FENCED=`
list (`canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0
FENCE-BREACH=0**).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

---

## 1. THE NUMBERS, REPRODUCED FROM AN INDEPENDENT BUILD

| | |
|---|---|
| BASE | `362dcfa0`, two fresh worktrees, `cmake -DCMAKE_BUILD_TYPE=Release`, `-j 2`, md5 taken separately |
| pristine | **`8b1777950b91feef705565e6f16e8b0a`** — byte-identical to the implementer's pristine AND to the main tree's `build/slang-uhdm` |
| patched | **`fff26ad19801bf4bbf445db25df03f44`** — byte-identical to the implementer's patched |
| the patch | `/tmp/r10earl114.patch`, md5 `c901362ed1b8dac944bcefa0711ce65b`, applies clean on a fresh `362dcfa0`, 0 conflict markers, and `git diff 362dcfa0` after applying is **byte-identical to the patch file** |
| surface | `src/ModuleEmit.cpp` ONLY + `tools/probe/r10earl114repro/` — 66 files, no `results/` edit, no stray path |
| both frozen | `chmod 555` at `/tmp/vearl114_bin/{pristine,patched}` BEFORE any sweep |

Every `cmds.txt` in all four sweep workdirs audited **by binary PATH**: `p_sl`
1573 files → only `/tmp/vearl114_bin/patched` (1523 with a slang line), `q_sl`
1573 → only `.../pristine`, `p_u2r` 1462 → only `.../patched`, `q_u2r` 1462 →
only `.../pristine`.  **Cross-contamination checks all 0, and no cmds.txt
anywhere names the main-tree binary.**

## 2. THE GATES

| gate | measured here |
|---|---|
| goldens | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| uhdm2rtlil, both modes | **679 / 50 / 2** on BOTH binaries, identical histograms |
| surelog, `--mode both`, 1588 rows | histograms **identical on both binaries**: default 471/283/25/10/5, testflags 466/284/23/9/5/3/2/1/1 |
| `ct8rows` | **PASS ×5** — 0 differing rows vs the committed baselines AND vs this verifier's own pristine control, both corpora, both modes.  **NO ROW CONVERTED.** |
| `byteverify SELFCHECK=1` | uhdm2rtlil **0 / 1358**; surelog **3 / 956** — the two PREDICTED Earlgrey rows **plus `Scoreboard/default`, PROVEN to be the documented coin** (§3) |
| rowheads | **Earlgrey_0_1/testflags 17 → 37 cmp lines, ONE head**; every other row identical, and **every other rowhead cmp log BYTE-IDENTICAL** between the two binaries (Earlgrey/default included) |
| canaries | surelog **ok=52 changed=0**, u2r **ok=8 changed=0**; `ctcan2` PASS ×2 |
| protected DBs | 10 pins, **all SAME**: `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex e3e354129d5a`/`73a10e8217e5`, `YosysOldOr d68e0796d62c`, **`SVSwitch 4842211c4030`**, **`YosysVerx 6ccda350c24a`** |

## 3. THE THIRD MOVER IS THE COIN, PROVEN ON THE PRISTINE BINARY ALONE

`Scoreboard/default` moved in this run and not in the implementer's.
RESUME.md §9 names it a ~50/50 coin; this verifier proved it rather than cited
it, two ways:

* the path-normalised **ORDER-BLIND** dump diff is **0 lines** with identical
  line counts (1 100 381 both sides) against **78** raw order-flip lines;
* the **PRISTINE binary alone**, run four times on that row, produced **three
  distinct hashes** — `0d80f8f5d07e` ×2, `6b7c9be975d8`, `c09f5e4b3e5b` — and
  `6b7c9be975d8` is exactly the hash `byteverify` attributed to the patched
  side.  The law never touched that database.

## 4. THE HEAD ADVANCED — BOTH cmp LOGS READ, NOT ASSERTED

```
PRISTINE  LHS: ref_typespec (work@top_earlgrey...gen_host_fifo[0].tl_h_i[0].a_valid)
               |vpiParent: hier_path (tl_h_i[0].a_valid) 109:19-109:36
               |vpiActual: array_typespec id:793266
          RHS: <null>                       <- expr::Typespec, +1
PATCHED   LHS: <null>
          RHS: typespec_member (a_valid) ... |vpiParent: struct_typespec (tlul_pkg::tl_h2d_t)
                                             <- Path_elems[..].Actual_group, -1
```

`hier_path::Compare` runs `expr::Typespec` BEFORE `Path_elems`, so the judge
descended exactly one field on the same object.  **The 17 → 37 line count is
the new head object's decompile size, not a distance** — a `typespec_member`
with its `struct_typespec` owner and its own `ref_typespec` prints larger than
a bare `ref_typespec`.  One head before, one head after.

## 5. THE LAW, ATTACKED

`vts114` (this verifier's own reader, not the implementer's `cen114`) prints
every `hier_path` in a database with its typespec edge, its `Root_value` kind
and name, the ROOT's own typespec edge, `Path_elems` count, `VpiSize`,
`VpiDecompile` and the full ancestor chain.  `vscore114.py` scores three ways
(fine key = span+name+chain; `COARSE=1` = span+name, the key that convicted
the implementer's first cut).  `vaway114.py` asks the only question that
decides the verdict, with no join key that can hide a cell.

**Arms written independently of the implementer's** (`v1_root114.sv` root
kinds; `v2_gen114.sv` declaring-scope and generate depth; `v3_iface114.sv`
interface instance / interface ARRAY / modport port / a generate scope inside
an interface; `v4_carrier114.sv` keyed / positional / nested / plain / binary /
`always_comb` carriers and the PACKAGE and PARAMETER roots):

```
MY ARMS,  fine key   TOGOLD=222  AWAY=0  MOVEDWRONG=0  SAME_AGREE=240  STILLWRONG=108
MY ARMS,  coarse key TOGOLD=138  AWAY=0  MOVEDWRONG=6  SAME_AGREE=138  STILLWRONG=48
THEIRS,   fine key   TOGOLD=140  AWAY=0  MOVEDWRONG=0  SAME_AGREE=279  STILLWRONG=48
THEIRS,   coarse key TOGOLD=128  AWAY=0  MOVEDWRONG=0  SAME_AGREE=170  STILLWRONG=28
```

The coarse row on the implementer's arms — **128 / 0 / 0 / 170 / 28** — is
their claimed `P0` total, digit for digit, from a different instrument.

**THE SIX COARSE `MOVEDWRONG` ARE THE IMPLEMENTER'S NAMED EXCEPTION,
REPRODUCED ON MY OWN ARM.**  At `v3_iface114.sv:10`, golden holds SEVEN
objects: six `gen_scope` copies (one per interface instance × gen index), every
one HUNG with `struct_typespec('pv114::vs_t')`, plus ONE bare copy in the
interface DEFINITION view.  We hold the six, all now hung with golden's payload
character for character, and no definition-view copy on EITHER binary.  Our set
is a strict subset of golden's and every element of it is golden's; the
set-shape rule cannot say that, so it reports MOVED-WRONG.  Under the fine key
the same cells score TOGOLD/SAME_AGREE.  The root KIND differs there
(`struct_var` golden, `struct_net` ours) and the typespec edge does not.

**THE CORPUS SURFACE, WHOLE.**  `byteverify` proves only two of 2314 databases
changed, so scoring those two IS scoring the law's entire corpus surface:

```
Earlgrey_0_1 default   fine  TOGOLD=464 AWAY=0 MOVEDWRONG=0 STILLWRONG=0 NOGOLD_MOVED=0
Earlgrey_0_1 testflags fine  TOGOLD=464 AWAY=0 MOVEDWRONG=0 STILLWRONG=0 NOGOLD_MOVED=0
both, coarse key             TOGOLD=68  AWAY=0 MOVEDWRONG=0 STILLWRONG=0
```

68 coarse cells is the implementer's surelog `P0` figure exactly.

**NOTHING BUT THE ONE FIELD MOVED.**  Masking the typespec column out of every
row and diffing pristine against patched — i.e. `VpiSize`, `VpiDecompile`,
`Path_elems` count, `Root_value` kind and name, `VpiName` and the span — gives
**0 differing lines** on both corpus movers and on all sixteen arm/views.

**THE EXHAUSTIVE AWAY HUNT** (`vaway114.py`, over all 28 triples at once — my four
arms, the implementer's four, the ten earl113/vearl113 arms, both views each,
plus the two corpus movers):

```
hung payload instances in OURS: 5620
   NOT held by golden at the same span+name: 0     (on the PRISTINE binary: 0)
```

**Not one unjustified hang anywhere.**  Every face aimed at it came back clean:
a PORT struct root, a PORT unpacked array, a module-body array, a `wire`
struct, a `wire` array, an anonymous-typed struct, a nested struct, a 2-D
array, a localparam, a module parameter, a package parameter, a package
variable, an interface instance, an interface ARRAY, a modport port, a
function formal, a gen-if, a gen-case, gen depth 2, module scope, positional,
nested, plain and `always_comb` carriers, and the DEF view of every one of
them.  **No def-view (`gen_for` / `named_begin`) row moved in ANY arm.**

**IDENTITY AND POPULATION** (`vident114`, on the databases):

* GOLDEN: the path `ref_typespec` is a DIFFERENT object from the root's in
  **54 of 54** cells, and its `Actual_typespec` is the SAME object as the
  root's in **54 of 54**.  Minted per path, target shared — as claimed.
* PATCHED: **every hung path carries exactly its root's typespec edge, 0
  mismatches.**
* The typespec population grows, and the growth is arena copies at an
  **UNCHANGED COORDINATE SET**: zero new spans, zero removed spans, only
  counts.  That independently confirms the `+261 array_typespec` reading.
* Whole-dump, path-normalised, ORDER-BLIND, on the two movers:
  **default ADDED 3248 / REMOVED 0**, **testflags ADDED 5075 / REMOVED 0** —
  **zero content removed, in either mode.**

## 5b. THE WIDE BOUNDARY AND THE MUST-STAY FLOOR

This verifier's own wide boundary (`vwide114.sh`) over the whole committed
`tools/probe` tree, both views, both frozen binaries:

```
LISTED = PROCESSED = 5055     (5050 committed + this verifier's 5 new files)
FENCED-NAME HITS IN THE LIST 0 ; FILES WITH != 4 rc LINES 0 ; NEVER RUN 0
identical=9738  DIFFERING=36  no_output=336
rc by side, PERFECTLY SYMMETRIC:  A/0 9383  A/3 320  A/4 391  A/139 16
                                  B/0 9383  B/3 320  B/4 391  B/139 16
```

**DIFFERING 36 = earl113's four arms, r10vearl113's six, earl114's four (the
positive control) and this verifier's four — each in both views, and NOTHING
ELSE.**  `r10earl110repro`, `r10earl111repro`, `r10earl112repro` and their
verifiers' arms are not in the differing list at all: byte-identical from both
binaries in both views, so their genvar-value, user-call-argument,
gen-parameter and int-whitelist fences are untouched by construction.

**THE FLOOR, STATED THE STRONGEST WAY IT CAN BE.**  On all twenty
earl113 / r10vearl113 arm/views the path-normalised ORDER-BLIND dump diff is
**ADDED > 0, REMOVED = 0** — the patch only ADDS, and the only added shapes are
the minted `ref_typespec` triple (`vpiTypespec` / `vpiParent` / `vpiActual`),
the actual typespec it points at, and the `hier_path` + computed `vpiFullName`
the dump prints under it.  Nothing any prior law produced was removed anywhere.
Re-scored with this verifier's own instrument, those twenty arm/views give
**AWAY 0 on both keys**, with coarse `MOVEDWRONG 4` = `v5_iface113`'s two cells
in two views and nothing else — and the official `uhdm-cmp` log for
`v5_iface113` **and** for `v6_name113` (earl113's NAME-WALK FENCE arm) is
**BYTE-IDENTICAL between the two binaries in both views**.

**EIGHT FURTHER CORPUS DATABASES SAMPLED** (`YosysBigSimEllip`, `Rggen`,
`BlackBePipeInt` ×2 modes, `Scr1SvTests`, `YosysOldOr`, `MiniAmiq`,
`YosysVerx`): `goldenHungWeDont=0`, `unjustifiedHang=0`,
`cellsMovedVsPristine=0` in every one — corroborating, from outside the two
movers, that the typespec-edge family has no residual population there.

---

## 6. FOUR PROSE FACE-READINGS THAT ARE WRONG — ALL SAFE-DIRECTION

Each was measured on the implementer's OWN committed arm or on mine.  Every one
of them makes the fence keep out a cell golden actually hangs — a MISS, never
an AWAY, and identical to what the pristine binary already produced.

1. **`t1` row `r10` — "an ENCLOSING generate block's local … golden hangs
   nothing — THE FENCE".**  Measured on their own committed golden:
   `r10_src[1].a_valid` carries `ref_typespec → array_typespec` with
   `rv=array_var('r10_src')`, in all six `gen_r10b[N]/gen_r10a[N]` scopes.
   **Golden HANGS there and we do not.**  Their own arm's source comment
   ("an ancestor generate block's local is reached by the SAME search that
   misses the innermost one's") says so; the README table contradicts it.
2. **"A signal DECLARED IN A GENERATE BLOCK is not answered by name."**  True
   only for an *array* root of the *innermost* block.  On arm `v2_gen114`,
   golden binds and hangs `gl_var` (a gen-local plain struct) and `gl_net`
   (a gen-local `wire` struct) and leaves only `gl_arr` (the unpacked array)
   bare.  `getObject`'s netlist walk CLIMBS through generate-kind instances
   (`inst = inst->getParent()`), and its `pexpr` prologue searches
   `scope::Variables()` before the netlist at all — neither is `array_vars()`.
3. **"An ANONYMOUS-typed root has no `ref_typespec` to copy."**  On arm
   `v1_root114`, an anonymous packed-struct VAR root carries
   `ref_typespec → struct_typespec('')` and golden HANGS it; we hang it too and
   score TOGOLD.  Only anonymous NET roots are bare.
4. **"An `array_net` / `struct_net` root carries NO `ref_typespec` on EITHER
   side, so fence (d) does the work."**  Their own `t1` `r5_src` is a
   `struct_net` in OUR database carrying
   `ref_typespec → struct_typespec('p114::h2d_net_t')`; fence **(d) does not
   stop it — fence (c) does**.  Inside an interface the same is true.  A
   `wire`-declared *non-array* packed struct is modelled by Surelog as a
   `struct_var` WITH a typespec (arm `v1` `x3_wsingle`), so the axis is the
   object kind Surelog chose, not the `wire` keyword.

## 7. RANKED RESIDUES

* **VR1 — the gen-local fence over-fires (the largest missed cell class).**
  Golden hangs on a gen-local NON-array root and on an ENCLOSING generate
  block's array root; `rootGenLocal114` blocks both.  Direction is safe.  The
  correct decode is narrower: `getObject` misses only what is reachable ONLY
  through `array_vars()` of the innermost generate instance.  Reproduced by
  `v2_gen114` cells a1/a2/b1/b2 and by the implementer's own `t1` r10.
* **VR2 — R1 confirmed: the positional / nested / process carriers.**  On
  `v4_carrier114`, golden hangs on a POSITIONAL pattern element (line 21), on a
  pattern NESTED in a pattern (23) and on a pattern in an `always_comb` (29);
  `flattenPatternCaRhs` is entered for none of them.  Zero population in the
  two corpus movers.
* **VR3 — a root whose `ref_typespec` has a NULL `Actual_typespec`.**  Surelog
  mints the path `ref_typespec` whenever the root HAS a `ref_typespec`, even
  when its `Actual_typespec` is null (CompileExpression.cpp:5462-5468); the
  patch requires a non-null actual.  Judge-visible if the shape exists; not
  observed in any database measured here.
* **VR4 — R4 confirmed and widened.**  Inside an interface the two emitters
  disagree on the root's KIND (`struct_var` vs `struct_net`) AND golden holds a
  third, bare, definition-view copy we emit on neither binary.  Reproduced
  independently on `v3_iface114`.
* **VR5 — the arena COUNT residue (R3).**  Confirmed judge-invisible: no new
  typespec coordinate, none removed, only counts.
* **VR6 — un-re-verified scope.**  The implementer's `P0 STILLWRONG 0 over
  49 427 joined keys` is a whole-corpus statement; this verifier measured
  STILLWRONG 0 on the two databases that actually changed and did not re-run
  the 2314-database census.  It cannot affect the verdict (the other 2312
  databases are byte-identical on the two binaries).

## 8. OPS NOTES

* This verifier's own wide boundary scored **2423 phantom DIFFERING cells** on
  its first pass: the `uhdm-dump` header names the output file it restored, and
  the side letter (`A.plain.uhdm` vs `B.plain.uhdm`) was not normalised out.
  `vwide114.sh` now normalises it and `vwidescore114.sh` re-derives the verdict
  from the RETAINED per-cell dumps, so a normalisation bug never costs a re-run.
* `vwide114.sh` / `vwidescore114.sh` read the fence list out of `canaudit.sh`'s
  own `FENCED=` line rather than spelling the four names — spelling them is
  itself a FENCE-BREACH, which `canaudit.sh` caught here before anything shipped.

## 9. FILES

| file | what it is |
|---|---|
| `vts114.cpp` | the independent reader: every `hier_path` with its typespec edge, `Root_value`, the ROOT's own edge, `Path_elems`/`VpiSize`/`VpiDecompile`, and the ancestor chain |
| `vscore114.py` | the three-way scorer (`TOGOLD` / `AWAY` / `MOVEDWRONG` / `STILLWRONG` / `NOGOLD` / `NOGOLD_MOVED`), fine key and `COARSE=1` |
| `vaway114.py` | the exhaustive AWAY hunt: any hung payload of ours that golden does not hold at the same span+name |
| `vident114.cpp` | the identity (minted-vs-shared) and typespec-population probe |
| `vgrid114.sh`, `TOPS.txt` | the arm driver (rc recorded, children `</dev/null`, reader rc asserted) |
| `pv114.sv`, `v1_root114.sv`, `v2_gen114.sv`, `v3_iface114.sv`, `v4_carrier114.sv` | the four independent arms |
| `vwide114.sh`, `vwidescore114.sh` | the wide boundary and its re-scorer |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the landing gates, copied verbatim from their owning pass dirs |
| `VERIFIED.r10earl114.txt` | the raw gate transcript |
| `BOUNDARY_WIDE.*` | this verifier's own wide-boundary accounting, tally and differing list |

Build the two C++ instruments with

```
g++ -O2 -std=c++17 <tool>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <tool>
```
