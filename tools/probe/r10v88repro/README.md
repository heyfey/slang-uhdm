# r10v88 — ADVERSARIAL VERIFICATION of r10earl88 (`§ pkgScopedPaStructStrictNetVar88`)

**VERDICT: ACCEPT AS SHIPPED.** Production surface in
`/tmp/r10earl88.verified.patch` is BYTE-IDENTICAL to the implementer's
`/tmp/r10earl88.patch`; this directory is the only addition.
**MEASUREMENT ONLY.** The official `uhdm-cmp` is the sole judge.
**BASE `d0499f7`. `results/*.csv` untouched, no row converted.**

## 1. Every headline number reproduced bit-for-bit

Two fresh worktrees at `d0499f7` (`/tmp/wt_v88pris`, `/tmp/wt_v88`), both built
`-j 2` by the verifier, both frozen `chmod 555` before any sweep:

| | verifier's build | implementer claimed |
|---|---|---|
| pristine `d0499f7` | `3f628b1cfc10` | `3f628b1cfc10` |
| patched | `3cf1df8c63b4` | `3cf1df8c63b4` |

`rowheads.sh` on the verifier's own two sweeps:

| row | pristine | patched |
|---|---:|---:|
| Earlgrey_0_1 / default | 21302 lines, 1 head | **17 lines, 1 head** |
| Earlgrey_0_1 / testflags | 21926 lines, 1 head | **17 lines, 1 head** |
| SeqDriver both / SimpleUVM both / Scoreboard def / MiniAmiq both / BuildUVMPkg both / Rggen def | 17,17,64,64,64,80,80,60,60,0 | identical |

The two AFTER head logs are byte-identical (`cmp` clean) — ONE R0.
The R0 decode is confirmed from the log itself: a SINGULAR `SafeCompare`,
`RHS: <null>`, LHS = golden's `ref_typespec → int_typespec` on the folded
`TotalRegions` constant at `flash_mp.sv:54`
(`logic [AllPagesW-1:0] region_end[TotalRegions];`) — the unpacked-dimension
bound. Ours carries no typespec. `constant::Compare` reads `Typespec`, so it
is judge-visible.

## 2. Gates, all re-run by the verifier

* goldens **23 PASS / 0 FAIL on BOTH binaries**, **0 PASS / 23 FAIL on `/bin/false`**.
* **cmds.txt audited file-by-file by binary PATH** (`GATES.r10v88.txt`):
  surelog 1573 files each side, u2r 1462 each side; every `slang:` line names
  the frozen path; **0 name the main-tree binary**.
* uhdm2rtlil **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**,
  `ct8rows` **0 differing rows** vs the committed baseline AND vs the
  verifier's own pristine sweep, in **both** modes.
* Surelog corpus **0 differing rows over 1588** (status AND dump column),
  identical per-mode status histograms, **no row converted**.
* byte movers: **u2r 0 / 1358**; **surelog 3 / 956** =
  `Earlgrey_0_1/default`, `Earlgrey_0_1/testflags` (both PREDICTED, below) and
  `Scoreboard/default` — 92 raw dump lines, **0 order-blind** ⇒ the documented
  coin. SELFCHECK 955/956 and 1357/1358.
* **run-time A/B**: `R10E88_OFF=1` on the PATCHED binary reproduces the
  pristine Earlgrey databases byte for byte in both modes
  (`feb743d6f254`, `22dc13775f8d`) ⇒ 100 % of the delta is this law.
* canaries `ok=52 changed=0` / `ok=8 changed=0`; both `ctcan2` PASS;
  `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`; five protected DBs
  byte-identical, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` on pin.
* the four slang-fenced names appear in **0 of 3957** boundary files and in
  **0** hunks of the patch.

## 3. Independent mover PREDICTION

`pareach88` over all 956 pristine surelog databases and all 1358 pristine u2r
databases, selecting every row our emitter made a NET whose element struct
FAILS the strict scan (`PREDICT.movers.surelog.txt`):

```
surelog: 2 rows  -- default/Earlgrey_0_1 + testflags/Earlgrey_0_1,
                    both work@top_earlgrey.u_flash_ctrl.u_flash_mp|region_cfgs_i
u2r:     0 rows
```

Realised movers = predicted movers + the Scoreboard coin. A whole-signal
census of the two Earlgrey databases shows **exactly one row changed** out of
41055 (default) and 54144 (testflags), and it lands on golden:

```
GOLDEN  …u_flash_mp|region_cfgs_i  VAR packed_array_var ELEM=struct_var
GOLDEN  …u_flash_mp|bank_cfgs_i    NET packed_array_net ELEM=struct_net
PATCHED both identical to golden;  PRISTINE had region_cfgs_i as NET.
```

## 4. BREAKING THE LAW — four new adversarial arms, 0 AWAY-GOLDEN

Element type × dimensions × direction × declaration style × home, built with
Surelog for golden and with BOTH frozen binaries in BOTH views, every cell
recording `rc`, scored on the WHOLE-SIGNAL census (every `Nets`/`Variables`/
`Array_nets` entry of every `module_inst`/`gen_scope`/`interface_inst`) — not
only on the packed-array subset, so a signal that moves out of the family is
still seen.

| arm | axes | RIGHT | TO-GOLDEN | **AWAY-GOLDEN** | MOVED-WRONG | STILL-WRONG |
|---|---|---:|---:|---:|---:|---:|
| `v1_members88.sv` | 14 element structs, one MEMBER axis each: typedef'd logic, typedef-of-typedef logic, `logic signed`, typedef'd struct, packed-union member, enum, typedef'd bit, param-bounded, single member, 2-D logic, ALIAS of a struct, cross-package member, a packed union as the element; + the same types with NO dims; driven and undriven instances | 78 | 27 | **0** | 0 | 9 |
| `v2_dimsdir88.sv` | `[P-1:0]`, `[pkg::NP-1:0]`, packed+unpacked, three packed dims, typedef-carried dims, dims ON TOP of typedef dims, inout, non-ANSI with separate `wire`/`var` declarations, ANSI ports with DEFAULTS, interface + modport ports, 3 instances | 67 | 37 | **0** | 8 | 18 |
| `v3_homes88.sv` | 3-deep instance chain, sibling instances ×3, generate-for ×2, generate-if, interface with a port, module bodies at every depth | 41 | 35 | **0** | 0 | 5 |
| `v4_ref88.sv` | `ref` ports | 1 | 1 | **0** | 1 | 3 |

Both views score identically. **AWAY-GOLDEN = 0 everywhere: no legal-SV cell
that was right under the pristine binary is wrong under the patched one.**

Every `MOVED-WRONG` cell was inspected: 8 of the 9 move the CONTAINER onto
golden's container (`packed_array_var`) while keeping an inline element list
golden does not have — pristine had BOTH wrong. The ninth (`i_nw`, a non-ANSI
port with a separate `wire` declaration) is a shape golden emits as a bare
`struct_net` with the dims dropped; pristine and patched are both a different
UHDM kind from golden, so neither matches the judge. Per-arm official-`uhdm-cmp`
line counts all go DOWN (v1 15129→15107, v2 16270→15925, v3 9931→9896,
v4 1586→1584; elaborated view likewise).

The no-dimension (`_d0`) cells are byte-identical pristine vs patched and
match golden — the LOOSE scan is untouched, as the law requires.

## 5. Controls and boundary

The implementer's three grids were rebuilt and rescored from scratch and
reproduce EXACTLY: `g1` RIGHT 202 / TO-GOLDEN 72 / AWAY 0 / STILL-WRONG 86;
`g2` 43 / 13 / 0 / 2; `g3` 29 / 18 / 0 / 4.

Committed earlier-pass arms as must-stay controls: **earl64** (`gA`,`gA2`,`gB`),
**earl77** (`g1_portkind77`,`g2_portkw77`,`g3_body77`) and **earl87**
(`g2_kinds87`,`g3_decl87`,`g4_homes87`) have IDENTICAL cmp line counts on both
binaries in both views — not one cell moves. The three arms that DO move
(earl35 `a1_flat`/`a2_wire`, earl53 `v1_v53`) were re-measured against golden:
TO-GOLDEN 25, **AWAY-GOLDEN 0**, MOVED-WRONG 0.

**Wide boundary** — a copy of the whole `tools/probe` tree plus these four new
arms, every `.sv`/`.v` at ANY depth, both views, list on fd 3, children
`</dev/null`:

```
PROCESSED=3957 == LISTED=3957      identical=7578   DIFFERING=20 (=10 files x 2 views)
rc histogram: rc=0 14542  rc=3 604  rc=4 654  rc=139 28
rc parity: 7914 cells, 0 A-vs-B rc mismatches  (so 'no_output' is symmetric --
           there is no file the patched binary fails to emit and the pristine one emits)
```

The 20 differing entries are 3 earlier-pass arms (adjudicated above), the
pass's own 3 grids, and these 4 new arms. **Nothing else in the tree moves.**

## 6. Code audit — the change is exactly containable

`packedStructArrayElemTs()` returns non-null under EXACTLY the conditions under
which `emitPackedStructArrayNet()` returns non-null (same guards, same
`typedefTs` first-match scan). Therefore, in the PORT arm:

* pristine behaviour on `{scoped ∧ elemTs≠null}` was ALWAYS a `packed_array_net`;
* the patch splits that same set into net (`kind≠TypeAlias ∧ STRICT`) and var
  (everything else) and changes NOTHING outside it — `{scoped ∧ elemTs=null}`
  still falls through untouched, `{!scoped}` still reaches the var arm.

`structTsIsNetStrict` is `SURELOG::Struct::isNet()`
(`~/git-repos/Surelog/src/Design/Struct.cpp:44`) verbatim, including "a member
with no `ref_typespec` / no `Actual_typespec` is a FAILURE, not a skip".
The decode was re-read at the source: `NetlistElaboration.cpp:1996`'s
`else if (ttmp == uhdmstruct_typespec)` is indeed unreachable once the
`packed_array_typespec` arm has taken the branch (`tmp` is reassigned, `ttmp`
is not), and `bindStructInPackage` (`ElaborationStep.cpp:1233`) is the only
site that restores `isNet` for a `paClass_scope` spelling.
`R10E88_OFF` follows the campaign's existing `R10E<N>_OFF` convention
(`R10E79_OFF`, `R10E81_OFF`, `R10E82_OFF`, `R10E85_OFF` already in the tree).

## 7. Residues the verifier ADDS to the implementer's list

**V-R1 (new, ranked first) — a typedef OF a package struct typedef.**
`typedef m_plain_t ma_plain_t;` then `r88::ma_plain_t [1:0] p`: golden is a
`packed_array_VAR` of `struct_var` naming `ma_plain_t`, even though the element
struct passes the STRICT scan (Surelog's `getActual()` does not reach the
`Struct` through the second alias, so `bindStructInPackage` never restores
`isNet`). Ours — pristine AND patched — is a `packed_array_net` and names the
BASE typedef `m_plain_t`. 4 cells in `v1`, 0 corpus cells. **This refutes the
general form "the STRICT scan decides": for an alias-of-alias the strict scan
is never consulted at all.** The shipped law is right on the corpus because
the alias-of-alias shape does not occur there; a future widening must key on
the alias DEPTH, not on the member scan.

**V-R2 (new) — declaration dims ON TOP of typedef-carried dims.**
`pkg::npa_t [1:0] p` where `typedef n_t [1:0] npa_t`: golden is a BARE
`packed_array_var` sharing the package `packed_array_typespec`. The
`kind != TypeAlias` conjunct does not fire (the declared type is a
PackedArrayType), so patched emits a `packed_array_var` WITH inline elements
(closer than pristine's net, still not golden), and the all-logic twin
`pkg::fpa_t [1:0]` stays a NET (golden: var). 8 + 4 arm cells, 0 corpus cells.

**V-R3 (new) — non-ANSI port with a SEPARATE `var`/`wire` declaration.**
`input i_nv; var pkg::n_t [1:0] i_nv;` — golden is a bare `packed_array_var`;
`input i_nw; wire pkg::n_t [1:0] i_nw;` — golden is a `struct_net` with the
dims DROPPED. `hasVarKeywordDecl`/`hasExplicitNetKeyword` are consulted only by
the BODY arm, never by the port arm. 2 arm cells, 0 corpus cells.

**V-R4 (new) — a packed UNION element** (`pkg::pu_t [1:0]`): golden emits a
`packed_array_var` of `union_var`; we emit the signal NOT AT ALL
(MISSING-OURS, 6 cells). Pre-existing, unrelated to this law.

**V-R5 — interface_inst signals** are MISSING-OURS entirely (earl77 R1),
confirmed on `v3` (3 cells) and `v2`.

**V-R6 — gen-scope body declaration of a STRICT-passing struct**: golden NET,
ours VAR, both binaries (2 cells) — this is the implementer's R1, and it
confirms their warning: widening the law into gen-scopes blind would make
these AWAY-GOLDEN.

**V-R7 — `ref` ports are an unsupported construct** for our emitter
(`slang-uhdm: unsupported constructs encountered: port direction`, rc=4); the
database is still written and the law behaves correctly on it.
