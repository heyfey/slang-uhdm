# r10earl36 — THE MOVER FENCE, recorded BEFORE any patched sweep was read

Written and run against the **PRISTINE 4296917** Earlgrey_0_1/default dump
(`pred36.py o.dump`), and against the corpus SOURCE, before the patched sweeps
were launched.  `git log` order is the proof: this file is committed with the
patch, and the numbers in `README.md` § 4 are the measurement of it.

## The argument

§ patDefBoundShadowedImport36 adds one code path, inside ONE expression
builder: the `identV && tfContext` arm of `makeTypespec`'s
**packed_array_typespec** range (`src/TypeEmit.cpp`, the
§ patDefBoundPkgParamSubst block).  It can do exactly one thing — turn the bare
`ref_obj(idV)` that arm otherwise mints into `pkgBoundValueConst9`'s constant.
Therefore:

* **F1** every moved dump line is either a REMOVED `\_ref_obj:` + `|vpiName:`
  pair or an ADDED `\_constant:` + `|vpiDecompile|vpiSize|UINT|vpiTypespec
  (ref_typespec -> int_typespec) |vpiConstType` group **at the same span**.
* **F2** no other object kind, no other field, and no object COUNT outside that
  one bound can move.  In particular no net, no typespec identity, no name.
* **F3** it fires only where: the bound is written `<ident>-<digits>`, the
  identifier is written UNQUALIFIED, slang resolved it to a parameter that is
  **not** package-homed, and an enclosing scope's **wildcard import** declares
  that name (`wildcardPkgParamNamed9`).

## The COMPLETE candidate set on the target design

`pred36.py` enumerates every bare `ref_obj` bound under a
`packed_array_typespec` range in the PRISTINE Earlgrey_0_1/default dump — the
only objects F1 can reach.  **13 candidates, 13 prints:**

| candidate | site | can it move? | why |
|---|---|---|---|
| `NumBanks` @22:67 | flash_mp.sv:22 | **YES — THE TARGET** | module `parameter int NumBanks`, module wildcard-imports flash_ctrl_pkg, which declares `localparam int NumBanks` (flash_ctrl_pkg.sv:11) |
| `TotalRegions` @21:69 | flash_mp.sv:21 | no | module localparam with **no package twin** — golden keeps the ref_obj too (measured, § 1) |
| `alert_pkg::NAlerts` @239:31, @240:31 | alert_handler_esc_timer / reg_wrap | no | written **QUALIFIED** — the arm's own `idV.find("::")` guard |
| `alert_pkg::N_ESC_SEV` @242:27, @243:27 | ditto | no | written QUALIFIED |
| `N_CLASSES` @41:15, @54:15 | alert_pkg.sv struct members | no | `structMemberTsCtx` — `identV` is not even computed there |
| `N_ESC_SEV` @26:20, @27:20 | nmi_gen.sv:26/27 | no | `localparam int unsigned N_ESC_SEV = 4` and the header-imported `prim_esc_pkg` declares **no** `N_ESC_SEV` (grep = 0 hits) — no twin, no shadow |
| `NrHarts` @39:26 | dm_csrs.sv:39 | no | dm_csrs has **no wildcard import at all** (every package read is `dm::`-qualified) |
| `NrHarts` @53:19 | rv_dm.sv:53 | no | rv_dm has no wildcard import |
| `NrHartsAligned` @201:19 | dm_csrs.sv:201 | no | same as dm_csrs.sv:39 |

## PREDICTION

* Earlgrey_0_1/default movers: **1 object, `NumBanks` @flash_mp.sv:22:67**.
* Dump delta: **1 `\_ref_obj: (NumBanks)` line + its `|vpiName:` removed; 1
  `\_constant:` + `|vpiDecompile:2 |vpiSize:32 |UINT:2 |vpiConstType:9` +
  `|vpiTypespec: \_ref_typespec: … \_int_typespec: , line:11:14` added.**
  ADDED-not-in-that-group = 0; REMOVED-not-in-that-group = 0.
* Multiset distance to golden must improve, with the improvement entirely in
  **ours-only** removals plus **golden-only** removals for the added group —
  i.e. both directions shrink because the object BECOMES golden's object, and
  no third line appears.
* Any mover on a bound golden leaves SYMBOLIC (`TotalRegions`, `NrHarts`,
  `N_ESC_SEV`, `NrHartsAligned`, or any `alert_pkg::`-qualified one) is an
  **OVER-FIRE and fails the pass**.
* Across the two corpora the shape needs a NAMED-element packed dim whose bound
  names a module parameter shadowing a wildcard-imported package member; the
  byte verifier (GATE 5) is the authority on the full population.
