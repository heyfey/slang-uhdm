# r10v87 — adversarial verification of r10earl87 (§ `impOvNameSetShadow87`)

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10earl87.patch`
(md5 `b4bc3ee9e3d4761ebfbb7a0af133b7da`) is unchanged; no `.verified.patch` was
needed. Every headline number in the implementer's report was reproduced
bit-for-bit from binaries this verifier built itself, and no arm anywhere in a
23-face × 2-view adversarial grid turned a pristine-right cell wrong.

Worktrees `/tmp/wt_v87` (patched) and `/tmp/wt_v87pris`, both fresh at
`8877c49`. Frozen binaries `/tmp/v87_bin/{pris,patched}.bin`; sweeps
`/tmp/v87_wdpris` and `/tmp/v87_wdpatch`. Full battery in `GATES.r10v87.txt`.

---

## 1. Independent reproduction

Both binaries were built from scratch and reproduce the implementer's md5s to
the byte: `pris 58e40a645b33f5b6a09322e71a884033`,
`patched c0c6be0ea94c54d9e0b1bed0fe986801`. So do the two Earlgrey mover
hashes (`feb743d6f254` / `22dc13775f8d`), the pristine head file (0 diff lines
against the committed `HEAD_BEFORE_Earlgrey_default.cmp`), the head counts
(150 → 21302 / 21926, one head each), every census bucket
(FAMILY-OVSTAMP 16 → 0, BOTH-SAME 45428 → 45444, GATE-REACHABLE 6528,
GATE-COLLIDE 16), the 3-way (CELL W2R 16 / R2W 0 / W2O 0; FIELD TO-GOLDEN 16 /
AWAY 0 / MOVED-WRONG 0), the A/B kill switch, and every canary and pin.

One difference from the implementer's numbers, and it is not a discrepancy:
byteverify reports **3** surelog movers here, not 2. The third is
`./default/Scoreboard`, the documented ~50/50 coin; its uhdm-dump
path-normalised **order-blind diff is 0 lines**, which is the campaign's
sufficient attribution for the coin.

## 2. Decoding Surelog independently

Read at `~/git-repos/Surelog`, not taken on trust:

* `CompileHelper::importPackage` (`src/DesignCompile/CompileHelper.cpp:241-281`)
  clones **every** `ParamAssign` of the imported package into the importing
  scope's own vector and tags the clone `VpiImported(pack_name)`. The clone is
  **unconditional** — it never asks whether the importing scope already declares
  that name, which is what makes the collision possible. The `object_name`
  filter is the only difference between an explicit and a wildcard item.
* `NetlistElaboration::elab_parameters_` opens **every** row with
  `inst_assign->VpiOverriden(instance->isOverridenParam(paramName))`
  (`NetlistElaboration.cpp:326`), and the assignment-pattern branch that
  short-circuits at `NetlistElaboration.cpp:262-320` stamps from the **same**
  name set (`pclone->VpiOverriden(...)`, line 263) — so there is no early-exit
  path that escapes the law. **Checked, because an escaping path would have been
  a false-positive source.**
* `ModuleInstance::isOverridenParam` (`src/Design/ModuleInstance.cpp:392`) is a
  `std::set<std::string>` lookup; the set is filled only from the eleven
  `setOverridenParam` calls in `DesignElaboration.cpp:2182-2363`, all inside the
  **instantiation** parameter-override walk.
* **`defparam` does NOT enter the set.** `DesignElaboration.cpp:841-849` applies
  a defparam with `parent->setValue(name, value, m_exprBuilder)` and no
  `setOverridenParam`. This was the verifier's leading false-positive
  hypothesis; arm `va2` proves it does not fire (below).

## 3. Breaking the law — 23 arms × 2 views

`arm87.sh` builds each arm with Surelog (golden) and with both frozen binaries,
plain and `-elabuhdm`, records every rc, and `score87.py` scores the three
censuses as a multiset. `arms/` holds the thirteen NEW faces; the
implementer's `g1`-`g7` were re-run unchanged as controls.

| new arm | face | result |
|---|---|---|
| `va1_nodefault87` | a formal with **no declaration default**, overridden | **MISS** — golden stamps the import copy, pristine AND patched do not (residue R-A) |
| `va2_defparam87` | a **defparam** override | nothing fires on either side — golden OV=0, ours OV=0. **No false positive.** |
| `va3_positional87` | **positional** (`#(7, 8, 9)`) overrides — Surelog's other branch | TO-GOLDEN 3, AWAY 0 |
| `va4_typeparam87` | the colliding name is a **type parameter** | value twin TO-GOLDEN 2; the `UT` copy is a **MISS** (residue R-B) |
| `va5_portwidth87` | the package member used only in a **port width** and a **gen-if condition** | TO-GOLDEN 1, AWAY 0 |
| `va6_typedefparam87` | a **package-typedef'd** parameter and a **parameter-named range** | TO-GOLDEN 3, AWAY 0 |
| `va7_sameval87` | override text **equal to the default**, and a **bare ref to a parent parameter** | TO-GOLDEN 2, AWAY 0 |
| `va8_structpat87` | **assignment-pattern** override on a struct formal (the early-clone branch) | TO-GOLDEN 1, AWAY 0 |
| `va9_reexport87` | a **re-export chain** (`export pinner::*`) | TO-GOLDEN 2, AWAY 0 |
| `va10_arr87` | **instance arrays** `[0:2]` + a gen-for home + an interface in the loop | TO-GOLDEN 11 (elab) / 7 (plain), AWAY 0 |
| `va11_bodyparam87` | a **body** parameter, module with **no parameter port list** (`defImpElabShape9` false) | TO-GOLDEN 1, AWAY 0 |
| `va12_implicit87` | an **implicit** parameter port (`#(int unsigned IA = 1)`) | TO-GOLDEN 1, AWAY 0 |
| `va13_genimport87` | a wildcard import **inside a generate block** shadowing the same name | one apparent R2W — **a census INST-collapse artifact, decoded in `ARMS.r10v87.txt`**; the patched row matches golden's module-level row in the dump |

**`RIGHT->WRONG` 0 and `AWAY-GOLDEN` 0 on every one of the 23 arms × 2 views
except va13's artifact, which the golden dump refutes.** The implementer's
`g6`/`g7` (earl85's two negative controls) keep golden's `vpiOverriden:1` and
`g7` still moves nothing at all.

The claim "an explicit import of a colliding name is illegal" was re-measured:
slang emits `error: redefinition of 'QA' [-Wredefinition]` (Surelog accepts it
silently), so such a design is `SLANG_REJECT` and out of scope. A collision our
emitter can reach really can only come from a wildcard import.

## 4. The verifier's own field audit — beyond the pass's evidence

Over **every joinable `param_assign` cell of both corpora, DEF and ELAB**:

```
  pristine   golden-stamped / ours-not = 16     ours-stamped / golden-not = 0
  patched    golden-stamped / ours-not =  0     ours-stamped / golden-not = 0
```

After the patch `vpiOverriden` is **correct on every comparable cell of both
corpora**, and the law adds no stamp golden does not have **anywhere**. This
is stronger than FAMILY-OVSTAMP → 0 (that bucket only counts cells where OV is
the *only* disagreement) and it is what bounds residues R-A and R-B to zero
corpus cells.

Ground truth for scale: golden holds **6102** ELAB rows carrying
`vpiImported`, of which **32** are stamped — the 16 this pass clears, plus 16
MODULE-OWN rows golden mis-tags with `vpiImported` (the FAMILY-IMPID / R1
residue), which we already stamp correctly.

## 5. Corrections to the implementer's report

1. **R0's "second witness" is wrong.** The head after the patch is
   `work@top_earlgrey.u_flash_ctrl.u_flash_mp` and the flipped object is
   `region_cfgs_i` (golden `packed_array_var`, ours `packed_array_net`) — that
   part is exact. But `bank_cfgs_i` is `packed_array_net` on **both** sides
   (golden id 402779, ours id 331914, same line 22:81-22:92): golden and we
   AGREE on it. The top-level marker counts prove there is exactly **one**
   flipped object, not two — `vpiVariables` 30 vs 28 and `vpiNet` 50 vs 52 are
   header+backref pairs, i.e. 15 vs 14 variables and 25 vs 26 nets.
2. **`GATE-COLLIDE` cannot be recomputed from the golden side** with this
   payload. `cencount87.py` builds its overridden-name set from OUR rows
   (`OV=1` with `IMP='-'`); the same reconstruction from GOLDEN's rows yields
   **0**, because golden gives the module's own shadowed row `IMP=<pkg>` (the
   R1 residue). The metric is sound as a predictor but it is not independently
   confirmable from golden — the audit in §4 is what confirms the outcome.
3. Byteverify movers are **3 / 956**, not 2: the third is the Scoreboard coin
   (order-blind diff 0 lines).

## 6. Ranked residues the verifier measured

* **R-A — a colliding formal with NO declaration default is not stamped.**
  `isOverriddenParam` (`src/EmitHelpers.h:1178`) returns false when
  `paramDefaultSyn(ps) == nullptr`, so `module m #(parameter int NA) ...` +
  `import p::*` (p declaring `NA`) leaves the import copy unstamped where
  golden stamps it. Arm `va1_nodefault87`, 2 cells per view, **0 corpus
  cells**. The one-line in-law extension is the disjunct the same gate already
  uses for `ps` itself: `isOverriddenParam(om7) || (!paramDefaultSyn(om7) &&
  om7.as<ParameterSymbol>().getInitializer())`. Not taken here: it moves no
  corpus byte and it belongs with a re-gate of its own.
* **R-B — a colliding TYPE parameter is not stamped.** Surelog's name set is
  kind-blind and its named-override path reaches `setOverridenParam`
  (`DesignElaboration.cpp:2295`) for a type override too, so golden stamps an
  import copy whose name collides with an overridden `parameter type`. The
  patch's `om7.kind != SymbolKind::Parameter` filter skips it. Arm
  `va4_typeparam87`, 1 cell per view, **0 corpus cells**.
* **R-C — gen-scope import copies are never materialized.** Arm
  `va13_genimport87`: golden emits a second set of import copies inside the
  generate-scope instance (`work@top87.u_ov.g_in`); we emit none (6
  ONLY-GOLDEN rows). Pristine == patched. Unrelated to this law, but it is what
  makes the va13 census pairing ambiguous.
* The implementer's R1 (FAMILY-IMPID, 28 cells), R2 (the ELAB Rhs span), R3
  (FAMILY-OPKEPT, 2 cells) and R4 (the shadowed-import Rhs *value* — visible on
  arms `va13`/`g1`, 0 corpus cells) all reproduce exactly as described.

## 7. Instruments here

`arms/va*.sv` (13 new faces), `ovdiff87.py` (OV-only 3-way row lister used to
separate a real flip from a payload residue), `ARMS.r10v87.txt` (the full arm
table plus the va13 dump decode), `GATES.r10v87.txt` (the battery as run),
`BOUNDARY_WIDE.*` (the verifier's own wide boundary over a copy of
`tools/probe` including these arms). The implementer's `pacen87` / `cen87.sh` /
`cencount87.py` / `cen3way87.py` / `score87.py` / `arm87.sh` / `vwide87.sh`
were reused unmodified and were checked byte-identical to their upstream
originals where they are copies (`canaries.sh`, `ctcan2.sh`, `ct8rows.sh`,
`byteverify.sh`, `rowheads.sh`, `canaudit.sh`).
