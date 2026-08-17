# r10earl51 — verifier notes

Three things were wrong and were fixed **before** anything landed. A silently
corrected mistake is indistinguishable from one that was never made, so all
three are here.

---

## V1. `bndarms51.sh` — a CITED GUARD THAT DID NOT COVER WHAT THE CITATION CLAIMED

The carried-forward `bndarms50.sh` was copied in as `bndarms51.sh` and would
have been cited in this write-up as "every boundary arm re-run". It had **two**
defects that made that sentence false:

1. its `ARM=` variable still pointed at `arm50.sh`, a file this directory does
   not contain (the harness was renamed to `arm51.sh`) — so **every** arm would
   have reported `NO_OUTPUT`, and a run of nothing prints the same
   `differing=0` as a clean run;
2. its directory list stopped at `r10earl48repro`, so the two directories the
   standing ops rules name **by name** — `r10earl49repro` (the b1/b2/c1/d1/e1/
   f1/g1/a1 + v1..v8 grid) and `r10earl50repro` (h1..h8 + w1..w5) — were never
   visited at all.

Both fixed here. The rewritten script stages each `.sv` out of the MAIN TREE
(read-only) rather than copying arms into this directory, so there is exactly
one copy of every boundary arm and it cannot drift, and it refuses to delete an
arm this pass owns. It now reports `identical=70 differing=0 no_output=0` — and
70 is a number that could not have been printed before the fix.

---

## V2. r10earl50's `h7` reading is REFUTED, and it is the reason R0 survived a pass

r10earl50 wrote: "`h7` PASS_CMP … the struct-member LHS is not it." `h7` passes
because **our side never folds there**, not because golden folds. Its
`output h7p::tl_h2d_t tl_o` elaborates to a struct_**NET**, so `emitContAssigns`'
`dottedLhs` net-base test keeps the SHARE of the def cont_assign and the fold
site is never reached. Earlgrey's `tl_h2d_t` carries an enum-typed member and a
nested packed struct, elaborates to a struct_**VAR**, drops the share, and
folds.

The lesson is specific and worth carrying: **a PASS_CMP on an arm is not
evidence that golden and we agree on a LAW — it is evidence that we agree on
that arm's OUTPUT.** When the arm reaches the disputed code by a different
route than the corpus does, the two are different statements. `i2_earl51.sv`
exists precisely to make the arm reach the same route (it reproduces the head:
`cmp heads=1`, the same fold, the same shape), and only then is the member-LHS
answer readable.

`h6` vs `h7` also moved TWO features at once — the LHS kind *and* whether the
localparam folds through a module parameter. `i1_earl51.sv` crosses them: the
operand's provenance is measured irrelevant in all ten cells, the LHS decides
all ten.

---

## V3. The first cut of the law was going to be TOO WIDE, and `i3` stopped it

`i2` showed golden keeping the operation for a member-LHS cast **and** for the
member-LHS `SRAM_DWB[1:0] | 2'h0`, which reads as "no member-LHS operation ever
folds". `i3` measures seven operation shapes on a member LHS against their
plain-net twins and refutes that: `LP2|4'h1`, `4'h1|4'h2`, a constant ternary, a
concat and `~4'h1` ALL fold on a member LHS, exactly as their net twins do.
Only the two CASTS survive.

The `i2.63` cell that suggested the wide rule is a **different family**: its net
twin `i2.76` `n_k3 = SRAM_DWB[1:0] | 2'h0` — a plain net LHS — ALSO keeps the
operation in golden, so what stops that reduce is the part-select of a
localparam, not the LHS. It is recorded as residue R1 and deliberately left
unmoved; a wide rule would have "fixed" it for the wrong reason and would have
been over-fire on the other five shapes.

Surelog's own source then confirms the narrow reading rather than the wide one:
`UhdmWriter::writeCont_assign`'s `else if (rhs->UhdmType() == uhdmoperation)`
arm is gated on `op->Typespec()`, which a cast carries and a binary/unary/
ternary/concat operation does not.

---

## What the gates actually ran

| gate | result |
|---|---|
| 1. two builds | patched `329fc208b0545f863fcd46f47facaca5`, pristine `a554402b367aeb786bef648638b94e35` (the pristine md5 reproduced exactly across two independent builds of 4e3ca19) |
| 2. goldens | patched 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL |
| 3. uhdm2rtlil | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, both modes, both binaries; `ct8rows.sh` vs the committed `results/gate_uhdm2rtlil.csv` — **baseline first (pristine): 0 differing rows**, then patched: 0 differing rows; default-mode pristine-vs-patched: 0 differing rows |
| 4. surelog | 794 rows × 2 modes = 1588; `ct8rows.sh` vs the committed `results/golden_surelog.csv` — pristine 0 differing rows, patched 0 differing rows |
| 5. byteverify | u2r 1358 paths, **0 movers**; surelog 953 paths, **2 movers** — see below. `SELFCHECK=1` flagged 1357/1358 and 952/953; `SELFCHECK1=1` reported 1 (u2r) and 3 (surelog = the injected corruption + the 2 movers) |
| canaries | `canaries.sh` u2r ok=8 changed=0, surelog ok=52 changed=0; `ctcan2.sh` ok=1 / ok=58 changed=0; `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| boundary arms | 70 arms, `identical=70 differing=0 no_output=0` |

### The two byteverify movers, named and attributed

* `./default/Earlgrey_0_1-71da2fd7/slang.uhdm` — **the predicted mover**,
  `3d1f57715d76` → `ed708d6cb37c`. Byte-deterministic: two independent runs of
  each binary (the sweep's and a standalone `earl51.sh` run) give the same md5
  per binary. The dump delta is the six lines in the README.
* `./default/Scoreboard-59431470/slang.uhdm` — **NOT this pass**. Scoreboard/
  default is multi-stable, and this is the direct proof rather than the
  citation: the **PRISTINE** binary, running the identical command line three
  times, produced `b3d565c6db10`, `b3d565c6db10`, `ea4ce33e1160` — that is,
  the pristine binary alone produces *both* of the md5s the verifier reported
  as a mover, including the one it attributed to the patched binary. The
  patched binary over three runs produced `ea4ce33e1160`, `573005e4670c`,
  `ea4ce33e1160`. Its CSV row is byte-identical to the committed baseline in
  both modes (`CMP_NOTEQUAL` / `SLANG_REJECT`).

### Reachability, stated honestly

`§ memberLhsCastNoElabFold51` fires **once** in the whole of both corpora — the
Earlgrey cell. The corpus therefore cannot over-verify this law; the 47 arm
cells of `i1..i4` are what bound it, and they were all measured against real
Surelog with one read position per cell.
