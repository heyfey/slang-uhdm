# r10v94 — adversarial verification of r10earl94 (§ genCaCastOperandParentScopeBind94)

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10earl94.patch`
(md5 `1491a1ff7c76bf5cadad7427b2b641a9`) applies clean on a fresh `e6156a8`,
rebuilds bit-for-bit to the tested binaries, reproduces every headline number,
and **no legal SystemVerilog was found on which the patch turns a
pristine-right cell wrong**. Production code is unchanged by this verifier;
this directory adds arms and measurements only.

BASE `e6156a8`, branch `auto5h`. `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
sole acceptance judge; everything here is MEASUREMENT ONLY.

---

## 1. What reproduced bit-for-bit

Both binaries were built by the verifier, in verifier worktrees, `-j 2`:

    pristine  377572c695d6878809390a6912be5481   (e6156a8)
    patched   d56a5ef7bb590a992d4d5c34e8f6302c

— the implementer's md5s exactly, from a different worktree path, so the build
is path-independent and the tested artefact is the shipped one.

Reproduced identically (`GATES.r10v94.txt` carries every number): goldens 23/0
patched and pristine, `/bin/false` 0/23; u2r 679/50/2 both modes; surelog
default 471 EQ / 10 NE and testflags 466 EQ / 9 NE, histograms identical
pristine vs patched; ct8rows 0 differing rows on every pairing with no row
converted and `results/*.csv` untouched; canaries ok=52 / ok=8 changed=0;
ctcan2 PASS ×2; canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0`;
InterfaceModPort / BlackParrotComplex / YosysOldOr SAME, SVSwitch
`4842211c4030`, YosysVerx `6ccda350c24a`; u2r byteverify **MOVERS 0 / 1358**;
census surelog `BOTH-SAME 2102537→2102551, MOVED-WRONG 3025→3013,
GOLDEN-ONLY 22819→22817, OURS-ONLY 501361→501359` with cell verdict
**WRONG→RIGHT 12 / RIGHT→WRONG 0 / no-golden-key 0**, u2r every bucket
unchanged and its census files byte-identical; heads
`Earlgrey_0_1/default 29 → 46 cmp lines, 1 head` with every other named row's
`.cmp` file byte-identical.

The head decode is confirmed from the verifier's own cmp logs
(`HEAD_{BEFORE,AFTER}_Earlgrey_default.v94.cmp`): the pristine default head is
`logic_net entropy_i / RHS <null>` — the SINGULAR `SafeCompare` naming the
POINTEE and hiding the owning `ref_obj` — and the patched default head is the
SAME `ref_obj LfsrDw` vs `constant UINT:64 vpiSize 32` at `prim_lfsr.sv:308`
that testflags already carried. The head is CLEARED and the two modes now
share one head.

**Cleaner than claimed on one point:** the verifier's surelog byteverify is
**MOVERS 2 / 956** — Earlgrey default and testflags, the two predicted
databases, and nothing else. No SeqDriver mover, no Scoreboard coin flip.

## 2. What was REFUTED — SeqDriver is not "build layout"

`SEQDRIVER_PATH.r10v94.txt` has the full measurement. The short form: the
**same bit-identical pristine binary** writes SeqDriver/default as
`59faaf3106e0` to `-o /tmp/v94_t1.uhdm` and as `d56dec429669` to
`-o /tmp/v94_arl94_wd/pris_sl/default/SeqDriver-32af76aa/slang.uhdm`,
reproducibly, interleaved in one shell; a synthetic length sweep flips the face
between 31 and 41 characters of output path. So

* "SeqDriver is DETERMINISTIC per binary" is **false**;
* the two hashes r10earl94 reports as its PATCHED and LAYOUT-CONTROL faces are
  what the PRISTINE binary produced in this verifier's sweep;
* the layout-control experiment was confounded by an uncontrolled variable, not
  wrong in its conclusion — SeqDriver is order-only either way (sorted,
  path-normalised dumps: raw 58 differing lines, **sorted 0**).

Earlgrey is *not* path-sensitive (a short-path run reproduces the sweep's
hashes exactly), so the law's attribution is untouched. The residue r10earl94
files as **R2 should be restated**: *SeqDriver's dump ORDER is a deterministic
function of the OUTPUT PATH, not of the binary's layout* — and, as an ops law,
a byteverify pairing must hold the workroot path shape fixed or SeqDriver
appears as a phantom mover. The verifier's own layout control
(`3ed9ef50f9208699b49bbc4a22c24bf7`) is still a valid control for earl93's R5:
it shifts `r10buvm22repro/g22.sv`'s associative-index constant by exactly its
own 64-byte `.bss` delta (22515417 → 22515481) where the patch shifts it by
4096.

## 3. Breaking the law — 6 new arms, 30 arm×view cells scored

`v1_iarr94` … `v6_hier94` here, plus earl57's two committed arms, plus the
pass's own seven, each built with Surelog (GOLDEN) and both frozen binaries in
BOTH views. `castcen.cpp` is the verifier's own instrument: every `vpiCastOp`
operand[0] that is a `ref_obj`, keyed by the ref's full name + span + the cast
op's span, payload = the `Actual_group`'s KIND, **FULL NAME** and span. The
full name in the payload is what exposes a cross-instance bind that a
span-only payload hides — golden's spans are identical across instances of one
module, so a span-keyed census cannot see it.

    30 arm × view combinations   WRONG→RIGHT 232   RIGHT→WRONG 0

Faces newly covered and found CORRECT (`ARMS.r10v94.txt`):

| arm | face | result |
|---|---|---|
| v1 | gen scope inside an INSTANCE ARRAY (`u_arr[0:2]`) | each element binds its OWN net, as golden |
| v2 | keyword casts `int'` `signed'` `unsigned'` `byte'`, a typedef cast, a package-type cast | all bind, as golden |
| v2 | cast under a function-call arg / a `$signed` arg | ours already equals golden's mixed state; the law is a no-op there |
| v3 | a BIND instance's gen scope; a 3-deep chain; an INTERFACE gen scope | bind instance binds as golden; interface gen scope agrees on all three sides (the law is a no-op) |
| v4 | ternary arms, concat, replication, a part-select operand, the same name twice, a second gen scope | all bind, as golden |
| v5 | THREE instantiations of one span with W=8/16/32, a defparam'd instance, struct / enum module vars, a gen-scope localparam, a nested gen scope reading the PARENT's local | all bind to the right instance; `struct_net`/`enum_var` payloads equal golden's |
| v6 | a sibling gen scope holding the SAME name as the module signal | binds the MODULE one, as golden |

The multi-instance question is settled by direct inspection of golden, not by
inference: `work@g1_cast94_top.u_b.gen_if.a_i` binds to
`work@g1_cast94_top.u_b.a_i` — golden binds PER INSTANCE, and so does the law.

Faces where golden and ours differ **identically before and after** (not this
pass's business, listed as residues below): a `pkg::name`-spelled operand, a
bare imported package variable, an instance array declared INSIDE a gen scope,
a PROCESS in a nested gen scope, a top-module gen scope's own local.

## 4. The wide boundary, run with a SECOND comparator

`vwide_v94.sh` is r10earl94's `vwide94.sh` with one addition that matters: it
compares the path-free `ct94cen` census **as well as** the normalised
`uhdm-dump`. Measured reason: on this pass's own arms the elaborated-view dump
is BLIND to the change — `g1_cast94` elab has 0 differing dump lines while the
two `.uhdm` files differ and the census sees 6 moved cells. A dump-only wide
boundary under-reports elaborated-view movers.

    PROCESSED=4204  identical=8026  DUMP_DIFFERING=21  CEN_DIFFERING=28  no_output=352
    rc histogram  rc=0 15410  rc=3 676  rc=4 702  rc=139 28
    rc BY SIDE    0 A 7705 / B 7705   3 A 338 / B 338
                  4 A 351 / B 351     139 A 14 / B 14      (SYMMETRIC)

The union of the two comparators names **only**:

* 24 cells that are this pass's own arms and the verifier's five new ones — the
  positive control that proves the gate can see;
* `r10buvm22repro/g22.sv` (plain+elab, dump only) — earl93's R5 build-layout
  constant, re-proven with the verifier's own layout control (+64 exactly);
* `r10earl57repro/v2_contexts57.sv` and `v3_gengrid57.sv` — REAL law movers,
  scored against purpose-built Surelog goldens at **WRONG→RIGHT 40,
  RIGHT→WRONG 0** on cast-operand cells.

All 14 `rc=139` cells are symmetric (both sides), i.e. pre-existing (R6).

## 5. Residues this verification adds (ranked)

* **V1 — an imported package variable is not in the law's pool.**
  `v6_hier94` `gen_h`: `8'(pvar)` where `pvar` is imported by `import pkv6_94::*`.
  Golden binds BOTH elaborated copies to `work@…u_a.pvar`; we bind only the
  second (pre-existing, unchanged by the patch). The object EXISTS on our side
  — the bound copy points at it — so the miss is the pool test
  (`getParentScope() != pool94`, the symbol's parent scope being the package).
  A one-line-shaped extension, but it is an ADD in a family where over-binding
  is the standing danger; it needs its own pass and its own fences.
* **V2 — an instance array declared INSIDE a gen scope loses its element index
  and its child gen scopes.** `v1_iarr94` `gen_holder.u_in[0:0]`: golden emits
  `work@…gen_holder.u_in[0].gen_a.*`, we emit `work@…gen_holder.u_in` with no
  index and no `gen_a` at all (3 golden-only cast cells per view). Pre-existing,
  identical before and after; a structural gap, not a binding one.
* **V3 — a `pkg::name`-spelled cast operand.** `v6_hier94` `8'(pkv6_94::pvar)`:
  golden emits a `ref_obj` named `pkv6_94::pvar` spanning only the NAME
  (`32:20-32:29`) with a NULL actual; we span the whole scoped name
  (`32:20-32:33`) and bind it. Pre-existing, both a span and a binding
  difference.
* **V4 — the elaborated-view `uhdm-dump` is not a sufficient boundary
  comparator** for `Actual_group` changes (§4 above). Any future boundary run
  should pair it with an `AllObjects` census.
* **V5 — cosmetic:** `r10earl94repro/dirmap94.sh`'s header still says
  "r10earl93" and "usage: dirmap93.sh".

r10earl94's own R0–R6 were checked and stand as written, except R2 (§2):
R0's four facts were re-measured object-by-object with `ln94` — our DEF listing
at `prim_lfsr.sv:308` keeps `LfsrDw` / `GAL_XOR_LUT_OFF` symbolic exactly as
golden does; golden folds NOTHING in that statement; golden and ours BOTH fold
the `{LfsrDw{…}}` replication count at `315:53-315:59` to `constant UINT:64
vpiSize 32`; and our extra DEF-view `constant UINT:0 vpiSize 64` at `308:71`
(R5) is present. R1 (the process half: golden binds `p1`, leaves `m_var` null;
we do the exact reverse) and R3 (`gtop.tv` over-bound by one copy) are
confirmed pre-existing and unchanged by the patch.

## 6. Reproducing

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.local/lib64:$HOME/.local/lib
g++ -O2 -std=c++17 -I ~/.local/include castcen.cpp -o /tmp/castcen \
    -L ~/.local/lib64 -luhdm -lcapnp -lkj
BIN=<binary> bash ../r10earl94repro/run94.sh v5_par94.sv /tmp/out_v5   # one arm, both views
bash cmpcast.sh v5_par94 elab                                          # golden/pristine/patched cells
PATCHED_BIN=… PRISTINE_BIN=… CEN94=… PROBE_ROOT=<copy of tools/probe> \
    bash vwide_v94.sh <file-list> /tmp/WIDE                            # the two-comparator boundary
```

`cmpcast.sh` reads `/tmp/v94_out/{pris,patc}_<arm>/<view>/{g,o}.uhdm`, which is
where `run94.sh` puts them. The four slang-fenced tests are never dispatched
and no file here spells them.
