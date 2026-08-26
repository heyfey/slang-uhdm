# r10earl97 — adversarial verification of § castTypedParamDeclSigned97

**VERDICT: ACCEPT (with one documentation correction, applied).**

BASE `915002a`. Everything here is MEASUREMENT ONLY; the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

`VERIFIER.r10earl97.txt` is the full transcript. The short form:

* **Both binaries rebuilt from scratch** in fresh worktrees at `915002a`, `-j 2`,
  md5 taken separately, frozen `chmod 555` at immutable paths of equal length.
  Both md5s came out **equal to the implementer's** — the build is reproducible.
* **Every headline number reproduced bit-for-bit**: goldens 23/0 on both binaries
  and 0/23 on `/bin/false`; u2r 679/50/2 with `ct8rows` 0 differing rows against
  the committed baseline AND against this verifier's own pristine sweep, both
  modes; surelog `--mode both` 0 differing rows over 1588, no row converted,
  `results/*.csv` untouched; `byteverify SELFCHECK=1` **u2r 0/1358, surelog 2/956**
  and the two movers are the two predicted Earlgrey databases; the mover dumps
  differ by **four added `|vpiSigned:1` lines and nothing else** on the four named
  cells; the census reads TO-GOLDEN 4 / AWAY-GOLDEN 0 / ADDED 0 / REMOVED 0 per
  mode with both one-sided sets unchanged to the row; the population is 0/1358 and
  278/956 and the listing is byte-identical to the committed `POP_sl.txt`; the
  heads are 54 → 36 (new object) on Earlgrey/testflags, 31 unchanged on
  Earlgrey/default, and every other measured row unchanged.
* **The wide boundary was re-run as a SUPERSET** (4370 files — the pass's own six
  arms included, where the pass's own run listed 4364 and scored them separately).
  LISTED == PROCESSED, rc histogram symmetric side for side, and the twelve
  differing cells reconcile exactly with the pass's two: the pass's five moving
  arms in both views, plus `r10earl_repro/qj27.sv` in both views — which
  re-measured against golden goes **1 head / 27 cmp lines → uhdm-cmp EQUAL** in
  both views with TO-GOLDEN 1 / AWAY-GOLDEN 0.
* **Six new adversarial arms** (`va1`–`va6`) drive the law across every integer
  face and home the brief names — explicit `signed`/`unsigned`, typedefs of `int`
  and of `int unsigned`, chained and package typedefs, a type parameter, an
  override-dependent target, an instance array, three instances of one span, a
  three-deep nest, a generate-instantiated module, a target whose default is a
  bare ref to another parameter, and a no-move control carrying a struct member,
  a union member, a class property, an enum with an `int` base, a packed array of
  `int`, a function return and argument, a port, a variable, a gen-scope
  declaration and an interface. **AWAY-GOLDEN is ZERO on every arm in both
  views**, `ADDED`/`REMOVED` are zero everywhere, `va4` is byte-identical before
  and after, and `va2` and `va6` convert to `uhdm-cmp` **EQUAL** outright.
* **Whole-field sweep**: over EVERY integer-kind typespec of both Earlgrey
  databases, same-count `VpiSigned` payload flips go **4 per mode → 0 per mode**.
  None remain.

## The one correction applied to the pass's own record

The pass README and `PREDICT_R0.txt` said the four added lines were "all in the
ELAB section (the DEF section and the weaklyReferenced tail are byte-identical)".
Measured, it is the other way round in the DUMP's terms: the four lines land in
the design's `weaklyReferenced` print block, which is the only place `uhdm-dump`
FULLY EXPANDS these typespecs; the `uhdmallModules` (DEF) and `uhdmtopModules`
(ELAB) blocks print the same objects only as unexpanded `|vpiActual:` headers and
are byte-identical side for side.

This is a labelling error, not a measurement error, and it does **not** make the
stamps judge-invisible: the objects are parented under the ELABORATED module
instances (the census keys them at `work@top_earlgrey.u_hmac.u_packer` and
`work@top_earlgrey.u_pinmux`), and the official Compare reaches them through the
cast operation's `ref_typespec -> Actual_typespec` — which is precisely how the
pristine head named one of them, and why the head clears. earl60's "never count
tail stamps" rule is about objects nothing references; it does not reach these.
Both files are corrected in place by this verifier's patch.

## Files

| file | what it is |
|---|---|
| `VERIFIER.r10earl97.txt` | the full transcript: binaries, gates, movers, census, population, heads, boundary, arms |
| `va1_sign97.sv` | explicit `signed`/`unsigned` and typedef targets |
| `va2_ovr97.sv` | override dependence, an instance array, three instances of one span |
| `va3_ref97.sv` | a target whose default is a bare ref to another parameter; package targets |
| `va4_home97.sv` | the integer faces that must NOT move (member / property / enum base / array / funcret / port / var / gen scope / interface) |
| `va5_td97.sv` | package, chained and aliased typedefs, and a type parameter, as the declared type |
| `va6_nest97.sv` | shared def bodies: two overrides, a three-deep nest, a generate-instantiated module |
| `vwide97v.sh` | the verifier's wide-boundary worker (list on fd 3, children `</dev/null`, PROCESSED asserted, run in four shards) |
| `BOUNDARY_WIDE_V.*` | the wide-boundary tally, diff list and per-side rc histogram |
