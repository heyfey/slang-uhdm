# r10buvm10 — ADVERSARIAL VERIFICATION (`vbuvm10`)

**VERDICT: ACCEPT.**  The production surface (`src/TypeEmit.cpp`, `buildEnumTs`)
is taken **UNCHANGED**; every headline number reproduces bit-for-bit on
independently built binaries, and no cell was found where the pristine binary is
right and the patched binary is wrong on legal SystemVerilog.

Worktrees `/tmp/wt_vbuvm10` (patched) and `/tmp/wt_vbuvm10pris` (pristine), both
cut fresh at `1a5d01e`; the patch `git apply --check`ed CLEAN on the fresh tree.

| | implementer | verifier | |
|---|---|---|---|
| pristine md5 | `8b5e2f68abfc42dfb43c389faa929c83` | same | REPRODUCED |
| patched md5 | `1cbb4c34040e4bca0facc551818533e1` | same | REPRODUCED |
| goldens pristine / patched / `/bin/false` | 23 / 23 / 0 | same | REPRODUCED |
| u2r both modes, both binaries | 679 / 50 / 2 | same | REPRODUCED |
| u2r rows vs committed + pristine-vs-patched | 0 / 1462, 0 / 731 | same | REPRODUCED |
| surelog rows vs committed `results/golden_surelog.csv` | 0 / 1588 | same | REPRODUCED |
| byteverify surelog / u2r (+ both controls) | 9/955, 0/1358, 954/955 + 10, 1357/1358 + 1 | same | REPRODUCED |
| predicted movers | 35 CAND A / 0 CAND B in 9 dbs = the 9 byte movers | same | REPRODUCED |
| BuildUVMPkg cmp lines, heads | 17 -> 79, 1 head, modes byte-identical | same | REPRODUCED |
| new head | `bit_var(uvm_pkg::uvm_comparer::compare_map)@21545 < array_var` | same | REPRODUCED |
| census G=A P=N | 3 -> 0 (`G=N P=A` stays 8) | same | REPRODUCED |
| census calibration G-vs-G | 913 A / 13 987 N / DISAGREEING 0 | same | REPRODUCED |
| boundary gate, 455 arms | PROCESSED 455 / IDENTICAL 449 / MOVED 0 / REJECT-BOTH 6 / ONE-SIDE 0 | same | REPRODUCED |
| pins on the patched binary | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | same | REPRODUCED |

## the ten adversarial arms (`vadv10/`)

`PRISTINE=... PATCHED=... CEN=... ./vgrid10v.sh <arm>.sv` — the shipped
`grid10.sh` with an overridable census path.  Verdicts:

| arm | what it breaks the law with | result |
|---|---|---|
| `va_agg.sv`  | chain DEPTH 1/2/3 on a package `bit` typedef | CONVERTED 8, **OVER-FIRE 0** |
| `vb_homes.sv`| package / class-in-package / class-outside / module / module-local / interface / program / **generate block**, direct AND chained | CONVERTED 12, **OVER-FIRE 0 in substance** (the 2 flagged cells are the `module_inst(<anon>)` chain-string artifact, §R2) |
| `vc_pos.sv`  | property, formal, return, body local, **nested-block local**, port, cast, `$bits` arg, `foreach` var, struct member, array element, parameter type, bare / wildcard-import / explicit-import spellings | CONVERTED 6, **OVER-FIRE 0** |
| `vd_qual.sv` | QUALIFIED base `enum pd10::td_bit {...}` | Surelog `SNT:PA0207` -> golden UNMEASURABLE; **both binaries accept it, neither crashes**, patch adds exactly one alias block |
| `ve_dim.sv`  | packed dimension after the typedef name (`enum te_bit [3:0]`) | **strict NO-OP** (the base is a `packed_array_typespec`; the site is never reached) |
| `vf_tparam.sv`| a **type PARAMETER** as the enum base, two specializations | **strict NO-OP** (a type parameter is in neither typedef registry) |
| `vg_unit.sv` | `$unit` scope, direct AND chained; module-local control | CONVERTED 4, **OVER-FIRE 0** |
| `vh_anon.sv` | INLINE anonymous enums (`implicitBaseRef`) with a typedef base, direct and chained; enum inside a packed struct member | CONVERTED 6, **OVER-FIRE 0** |
| `vi_atom.sv` | every ATOM base kind — `bit`(scalar) `logic`(scalar) `int` `byte` `integer` `time` `bit signed [7:0]` — direct AND chained | CONVERTED 15, **OVER-FIRE 0** |
| `vj_spec.sv` | a typedef whose TARGET is a type parameter (drives `chained0` from a specialization), and a class alias of a package chain | **no compared field moves**; only 2 dangling arena objects fewer |

**SLANG-FENCED, measured not guessed:** a packed-struct, packed-union or enum
typedef as an enum base is REJECTED BY SLANG
(`invalid enum base type ... (must be a single dimensional integer type)`), even
though Surelog accepts all three.  So § `enumBaseTdChainNoClone10`'s bypass of
the `bit`/`logic` kind gate can never see an aggregate: the fence is
STRUCTURAL, and that is why arm `va_agg.sv` carries only the scalar chains.

## the alias TARGET is per-view, and that is MEASURED

The law's riskiest sentence — "the def-view copy aliases the def listing object
and the elaborated copy the elaborated twin, without this site needing to know
which view it is in" — is true on the corpus, not merely argued.  In
BuildUVMPkg the patched database carries `uvm_field_flag_t` copies
`#274 #292 #180382` aliasing the **DEF** listing `#267` and `#2989 #3007 #24905
#180370` aliasing the **ELAB** listing `#2984`; golden splits the same way
(`-> #61381` DEF, `-> #1584` ELAB).

## ONE GATE DEFECT FOUND AND FIXED (`attrib10.sh`)

`attrib10.sh` judged the RAW, ORDER-SENSITIVE dump diff.  The standing
MEASUREMENT LAWS say *"Scoreboard/default is a ~50/50 COIN (svunit_pkg
vpiTaskFunc reorder) — attribute only by order-blind census."*  On the
verifier's build of the SAME two binaries `default/Scoreboard` read
`+67 / -46  NOT ATTRIBUTED` — a **FALSE ALARM entirely produced by that coin**;
sorted, the same pair reads `+21 / -0`, exactly 3 `vpiTypedefAlias` blocks.
The implementer's `0 NOT ATTRIBUTED` was therefore a lucky flip, not a property
of the gate.  The script now prints BOTH numbers (so an ORDER regression stays
visible) and takes its VERDICT order-blind; all 9 movers read ATTRIBUTED, and
the whole-corpus delta is `+7·n / -0`, alias blocks only.

## ranked residues (measured, none of them a regression)

1. **R1' — the integer-ATOM enum base is still ANONYMOUS, and the fix already
   exists in this file.**  `typedef int t; typedef enum t {...} e;` gets golden a
   NAMED `int_typespec 't'` with a `Typedef_alias`; we mint an anonymous one.
   `tdVecNamedClone42` (`src/TypeEmit.cpp` ~627) ALREADY implements exactly this
   law — name + `Typedef_alias` + § `tdChainNoClone43` — for
   `bit/logic/int/byte/short_int/long_int/integer/time/string`.  This pass
   open-codes a `bit`/`logic`-only duplicate 30 lines above it.  Routing the
   enum base through that helper is the single highest-value follow-up, and
   arm `vi_atom.sv` is its ready-made grid (5 atom kinds, 10 cells).
   NOT done here: it changes the span/`Instance` handling and therefore the
   binary, which is out of a verifier's remit when nothing regressed.
2. **R2' — the chained base in the DEF PACKAGE view moves further from golden.**
   Golden's DEF-view chained enum base is an `unsupported_typespec` carrying the
   BARE name (`t_chain`); pristine emitted `bit_typespec 't_chain'` (name right,
   type wrong), patched emits `bit_typespec 'pk10::t_chain'` (name AND type
   wrong).  The ELAB view converts fully, which is the trade the law took.
   **NOT a cmp flip**: `VpiType` already differed, so the cell was NOT EQUAL on
   both binaries — and gate 4 measures 0 moved rows over 1588.
3. **The chain law is CORPUS-UNFALSIFIABLE.**  § `enumBaseTdChainNoClone10`
   never fires on either corpus: `predict10.sh` reports 0 CAND B, and every one
   of the 9 movers has **0 removed dump lines** while the chain branch always
   removes the clone when it fires.  Its entire evidence base is the arms.
4. **`predict10.sh` models a narrower law than the code.**  It filters actuals to
   `bit_/logic_typespec`, but `chained0` binds `shb` whatever its kind
   (`vi_atom.sv` moves `int/byte/integer/time` objects).  Re-run with the filter
   widened to every typespec kind the answer is IDENTICAL (35 CAND A, 0 CAND B,
   the same 9 databases) — so the gap is LATENT on this corpus, not active, and
   the shipped prediction stands.
5. **Arithmetic nit in the README's census table.**  "present on one side only
   904" is `G=- P=N` 478 + `G=N P=-` 286 + `G=A P=-` 140; the `G=- P=A` 18
   bucket is left out of the sum.  The actionable classes (3 -> 0, `G=N P=A`
   8 unchanged) are exact.
6. **Ops hygiene** — `bndsub10v.sh` writes its scratch to `/tmp/vbuvm9_bnd2_*`,
   i.e. the PREVIOUS pass's verifier namespace.  Harmless today, a collision the
   day both are re-run at once.
