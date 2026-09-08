# r10v205 — adversarial verification of r10uvm205 (`cloneArrayElemBareTdAlias205`)

**VERDICT: ACCEPT.** Every headline number in the implementer's report reproduces
bit-for-bit from binaries I built myself, and no construction I could find makes the
patched binary wrong where the pristine binary was right.

MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
LHS is ALWAYS golden. The full measured record is `VERIFIED.r10uvm205.txt`.

## What was reproduced independently

Two fresh worktrees at `450b7a24` (`/tmp/wt_v205pris` pristine, `/tmp/wt_v205` patched),
built `-j 2`, frozen `chmod 555`. Both binary md5s came out **identical to the
implementer's**: pristine `505cad23a156a75a6da1a3fd69b64617`, patched
`2bd808c3610a262f520fde0d2af277d4`. The patch (`md5 1ab58e754d790a07ea7f8a5d00812bf1`)
applies clean on a fresh `450b7a24`.

Reproduced from my own sweeps and my own instruments: the kind table
(`agree=5255 differ=26`, one DIFFER row), the a-priori prediction (exactly four
row-modes over 948 databases), the byte movers (5/956 surelog, 0/1358 uhdm2rtlil),
the corpus census (TO-GOLDEN 20 / AWAY 0 on the four moved rows, 0 everywhere else),
the head-object change on all four rows, the six grid arms, and the wide boundary.

## Where this verification went beyond the pass

1. **A stricter payload.** The generated `typespec::Compare` reads `Typedef_alias`
   and then `Instance` (`~/git-repos/UHDM/build/generated/src/typespec.cpp:93-94`), but
   `score205.py` scores only `(kind, VpiName, alias VpiName)` — so the pass's
   `AWAY-GOLDEN 0` was measured with a judge-visible field excluded. `v205score.py`
   puts `vpiInstance` and the alias target's `vpiInstance` back in. Re-scored, every
   row-mode and every arm still reads **AWAY-GOLDEN 0 / MOVED-WRONG 0**, and on the
   four moved corpus rows all 20 cells reach golden on all five fields.

2. **The owner-mask blind spot, measured rather than argued** (`v205own.cpp`). The
   law's exclusivity guard cannot see a class property, a package- or module-level
   variable, or an unparented declaration — and the pass's census shares that blind
   spot exactly. The escaped population is large (89–102 element refs per UVM row),
   and its intersection with the refs the law can move is **empty on every row-mode**.
   Arms H and M drive the hole deliberately and cannot reach it either.

3. **Seven new arms** (`grid/`) against real Surelog goldens: the untested
   `Index_typespec` branch (G), the owner-mask hole (H, M), depth ≥ 2 (I), a two-hop
   import chain (J), module/interface/explicit-import contexts (K), and the sharing
   maximiser (L). AWAY-GOLDEN 0 in all of them under both payloads.

4. **The Scoreboard coin proven directly, not inferred.** Three consecutive runs of the
   *pristine* binary give two different hashes, and the *patched* binary reproduces the
   hash byteverify attributed to pristine.

5. **The naming dead end closed design-wide.** Across every arm's whole-arena,
   order-blind diff, the number of post-patch lines that contain `::` and did not
   before is **0**. Every changed line is `[t -> pkg::t]` → `[t -> t]`.

## Ranked residues this verification adds

* **R-V1 — the owner-mask cannot see three declaration populations.** Latent, not
  live (`ESCAPED_SHARED 0` everywhere, arms H and M clean). Any future pass that makes
  our emitter share an element `ref_typespec` between a subroutine declaration and a
  class property / package- or module-level variable turns it live, and neither
  `ct205cen` nor `score205.py` would report it. Run `v205own` before widening this law.
* **R-V2 — `score205.py` is blind to `vpiInstance`.** Use `v205score.py --cols=5`, or
  put `inst`/`ainst` in `score205.py`'s payload, for any pass in this family.
* **R-V3 — the `vpiInstance` residue itself.** On the elaborated (`TOP[…]`) copies the
  alias name now reaches golden while `vpiInstance` still names the *importing* package
  where golden names the *declaring* one (arms G, I, J, K; §189's arms too). Wrong on
  both binaries, so no regression — but it is the next field in `typespec::Compare`
  after the one this law fixed, and it is a larger population (410–718 cells per row).
* **R-V4 — `bound205.sh` treats a nonzero Surelog rc as a usable golden.** Arms A and B
  run Surelog's `-elabuhdm` at rc=4; the databases it wrote are real elaborated ones
  (verified: larger than, and different from, the def golden), so the readings stand,
  but the driver would not have told anyone if they had not been.
* **R-V5 — the mint key has no tiebreaker.** `std::sort` over
  `name|kind|file|line:col|instance-name` is not stable, and DEF/ELAB listing twins can
  in principle collide on all six. No effect measured (SeqDriver is byte-stable over
  three runs per binary, matching the sweep), and object ids are invisible to the judge;
  a tiebreaker would make it unconditional.

## How to reproduce

```bash
g++ -O2 -std=c++17 v205own.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/v205own
/tmp/v205own <pristine slang.uhdm>            # ESCAPED_SHARED must be 0

# the seven arms, against a real Surelog golden, both views, both binaries
for a in grid/v205_*.sv; do
  CEN=<ct205cen> bash ../r10uvm205repro/grid205.sh "$a" <PRIS> <PATCHED> /tmp/w_$(basename $a .sv)
done
# then re-score with the judge-visible payload:
python3 v205score.py /tmp/w_<arm>/raw.a.<view>.txt /tmp/w_<arm>/raw.b.<view>.txt --show
```
