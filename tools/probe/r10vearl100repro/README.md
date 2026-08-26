# r10vearl100 — ADVERSARIAL VERIFICATION of r10earl100 (`structPortNetIsMemberScanOnly100`)

**VERDICT: ACCEPT.** Every headline number reproduced bit-for-bit from an
independent rebuild; seven new adversarial arms over the struct-declaration
face × home × view matrix score **TO-GOLDEN 38 / AWAY-GOLDEN 0 /
MOVED-WRONG 0**, with **two arms converting outright to `uhdm-cmp` EQUAL**.
No pristine-right → patched-wrong cell was found, so the production surface
ships unchanged.

Everything here is **MEASUREMENT ONLY**; the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.

---

## 1. Bit-for-bit reproduction (independent worktrees, independent build)

Two fresh worktrees at `400a941`, `git apply` of the pass patch on one, both
configured and built `-j 2`, both frozen `chmod 555`:

| | md5 |
|---|---|
| pristine `400a941` | `e3d14ab934b7b9e6862f85620f3c60e7` |
| patched `400a941` + the pass patch | **`6b5ee27cfaa974f5da3ec536420e4066`** |

The patched md5 is **byte-identical to the binary the implementer shipped**.
The patch applies to a fresh `400a941` with rc 0, **0 conflict markers**,
**35 entries**, and exactly **one** entry outside
`tools/probe/r10earl100repro/`: `src/ModuleEmit.cpp` (+34 / −143). Fence check
`0 0 0 0`.

Reproduced, each measured here and not carried forward:

| claim | reproduced |
|---|---|
| Earlgrey_0_1/testflags **26594 → 132**, 1 head | YES (`ROWHEADS_pris.txt` / `ROWHEADS_pat.txt`) |
| every other named row unchanged (SeqDriver 17, SimpleUVM 67, Scoreboard-def 67, MiniAmiq 106, BuildUVMPkg 67, Earlgrey-def 132, Rggen-def 0) | YES |
| surelog census pristine `same 205841 · G-only 372 · O-only 4 · nV-bad 8 · nN-bad 10` over 956 DB / 41146 scopes | YES, to the unit |
| surelog census patched `same 205845 · G-only 368 · O-only 0 · nV-bad 4 · nN-bad 6` | YES, to the unit |
| u2r census calibration `1358 DB / 23620 scopes / 31664 cells, 0 one-sided, 0 count-bad`, identical both binaries | YES |
| byteverify surelog **2 / 956** = `default/Earlgrey_0_1` + `testflags/Earlgrey_0_1`; u2r **0 / 1358** | YES |
| histograms 937/19/567/48/10/3/2/1/1 and u2r 679/50/2 both modes | YES |
| wide boundary `identical 8614 · no_output 356 · rc 0:16514 3:684 4:746 139:28 symmetric 14/side` | YES (`8614` and `356` land exactly; my rc=0 is 16538 = 16514 + 4×6 for the six extra verifier arms in my list) |
| the 16 differing boundary cells and their attribution | YES, all four non-pass files re-attributed independently below |

## 2. The head decode — the implementer's CORRECTION is right, `RESUME.md` is wrong

Read straight out of both `.uhdm` files (`ct100lst`, never a decompile),
`work@top_earlgrey.u_hmac.u_sha2.u_pad`:

```
golden   nV=8  nN=16   fifo_rdata = N 5  struct_net   (hmac_pkg::sha_fifo_t)
pristine nV=9  nN=15   fifo_rdata = V 0  struct_var
patched  nV=8  nN=16   fifo_rdata = N 5  struct_net   <- golden's own index
```

`fifo_rdata` appears **exactly once on each side**. **`RESUME.md` §3b's
Earlgrey_0_1/testflags row ("golden's Variables holds 16 … ours holds 18 —
fifo_rdata listed TWICE") is REFUTED by measurement** and must be replaced at
integration time; it also carries a head (26594) this landing clears.

The new head, measured on this verifier's own patched binary: `hmac_pkg.sv:17:11`,
golden `logic_typespec` `|vpiName:sha_word_t` with a `vpiTypedefAlias`, ours
`|vpiName:hmac_pkg::sha_word_t` — 132 lines, 1 head, and the **default and
testflags cmp bodies are byte-identical**. earl96's naming family; queued.

## 3. Breaking the law — seven adversarial arms, and what they found

`varm.sh` builds a Surelog golden in place for each arm × {plain, elab} and
judges both frozen binaries with `uhdm-cmp`; `lst3.py` then scores every
(scope, signal) cell three ways (golden / pristine / patched) as
TO-GOLDEN · AWAY-GOLDEN · STILL-WRONG · MOVED-WRONG. cmp lines alone cannot
score this — a listing move can hide behind an earlier head — so the per-key
intersection is the arbiter, exactly as the brief requires.

| arm | faces | pristine → patched (plain / elab) | cells |
|---|---|---|---|
| `v1_union100` | **packed union** port, a struct with a **union member**, an enum-member struct, in an undriven module AND in a module that blocking-writes a struct port | 1010 / 1034 → **0 / 0 — uhdm-cmp EQUAL** | TO-GOLDEN 4, AWAY 0 |
| `v2_homes100` | input / output / **inout** / `input var` / read-only / blocking / cont-assign / `always_ff <=` / member-select / nested-struct member / typedef-of-logic member / pass-through to a child / **parameterized submodule at two widths** | 8 / 8 → 8 / 8 | TO-GOLDEN 12, AWAY 0 |
| `v3_gen100` | **two generate arms declaring the same name**, a genvar loop, a struct **shadowing a package variable**, a **macro-expanded double declaration**, **three instances of one span**, an interface home | 386 → 386 | TO-GOLDEN 3, AWAY 0, STILL-WRONG 3 |
| `v4_forms100` | **non-ANSI port list**, unpacked struct port, **unpacked array-of-struct port**, `wire`/`var`/plain body decls, `'{...}` / `'0` / concat initialisers, local vs package typedef | 8 → 8 | TO-GOLDEN 2, AWAY 0 |
| `v5_deep100` | a struct-ported module instantiated **inside a generate if arm** and **inside a genvar loop** (both indices), a port with a **DEFAULT VALUE**, an unpacked array-of-struct port, an interface home | 557 / 561 → 557 / 561 | TO-GOLDEN 6, AWAY 0, STILL-WRONG 1 |
| `v6_more100` | **alias-of-a-package-alias** typedef, a port carried **three instance levels deep**, procedural AND continuous writes to different struct ports of one module, an **anonymous packed-struct port**, a body decl of the port's own typedef | 291 / 299 → **0 / 0 — uhdm-cmp EQUAL** | TO-GOLDEN 4, AWAY 0 |
| `v7_edge100` | **`` `default_nettype none ``**, **macro-expanded PORT declarations**, bare AND `pkg::`-qualified spelling of one typedef **in one module**, an **anonymous nested-struct member** (the usbdev shape), a `bit` member, a parameter-width `logic` member | 15 → 15 | TO-GOLDEN 7, AWAY 0 |

**TOTAL: TO-GOLDEN 38 · AWAY-GOLDEN 0 · MOVED-WRONG 0.**

Three hypotheses this verifier raised and **refuted by measurement**:

* **Unions.** Surelog's `elabSignal` (`NetlistElaboration.cpp:1995-2038`) has no
  `uhdmunion_typespec` arm at all, so a union signal keeps `isNet=false` from
  the leading block and golden lists it as a `union_var`. If the deleted route
  had reached unions, deleting it would have pushed them into `vpiNets`.
  It does not: `isPkgStructType` bottoms out on slang's `Type::isStruct()`,
  which is **struct-only** (`slang/source/ast/types/Type.cpp:227`). Measured:
  `v1_union100`'s `u_in`/`u_out` are `union_var` under `vpiVariables` in
  golden **and** in both binaries, and the arm converts outright.
* **A port with a default value.** The deleted route was guarded by
  `!getInitializer()`, so `input al_t p = '0` never took it. `v5_deep100`'s
  `u_df.p` shows golden nets it anyway — the guard was over-cautious, and
  removing the route moves the cell TO-GOLDEN.
* **`` `default_nettype none ``, macro-expanded ports, mixed bare/qualified
  spelling.** None of them changes the member scan's verdict (`v7_edge100`,
  7 TO-GOLDEN, 0 AWAY).

The law also matches Surelog read directly: `elabSignal`'s `isNet` starts
`true`, is cleared for a named-type signal (`slStringConst` / `paClass_scope`)
— and is then **unconditionally re-decided** by the `ttmp == uhdmstruct_typespec`
member scan at `NetlistElaboration.cpp:2001-2015`. There is no drivenness,
direction or `var` term anywhere on that path.

And the deleted route's reachability claim checks out by reading: the
member-scan route above it `continue`s on every non-net-like struct **and** on
every struct carrying an initializer, so the drivenness route could only ever
fire on a LOOSE-net-like package struct port — precisely where golden nets.

**Its own precedents survive the deletion**, verified on the corpus, not
argued: `rsp_gen_minimal` (`work@dut`: `tl_i`/`tl_o` still `struct_var`s,
`vpiNets` still a null vector — listing identical to golden), `simple_package`
and `rp32_r5p_bru` are all **CMP_EQUAL and byte-identical between the two
binaries** (byteverify u2r 0 / 1358).

## 4. The regression field, and the must-stay controls

* **Corpus, per-key intersection, not a dump diff** (`CEN_*.txt`): 2314
  databases, 64766 scopes. u2r **identical before and after** (0 one-sided
  cells on 1358 CMP_EQUAL databases = 0 false positives, the calibration).
  surelog: **TO-GOLDEN 4 · AWAY-GOLDEN 0 · ADDED 0 · REMOVED 0** — the four
  cells are `u_pad.fifo_rdata` and `i_usbdev_iomux.sys_reg2hw_config_i` in both
  modes, and Earlgrey disappears from the patched report entirely. Each side's
  cell total is invariant (golden 206213, ours 205845).
* **Wide boundary**, 4499 files (the whole `tools/probe` tree at any depth plus
  the seven verifier arms), both views, both frozen binaries, fd-3 list,
  children `</dev/null`, `PROCESSED == LISTED == 4499`. `identical 8614 ·
  DIFFERING 28 · no_output 356`; segfaults **symmetric 14 per side**.
  28 = 12 (my own six arms × 2 views — the **positive control**: the gate can
  see this law) + the pass's own 8 + **the same four non-pass files the
  implementer named, re-attributed here independently**:

  | file | verdict |
  |---|---|
  | `r10earl77repro/g1_portkind77.sv` | **TO-GOLDEN 2 · AWAY 0** (`u_c3.i_impstruct` / `o_impstruct` become golden's `struct_net`s); the 10 STILL-WRONG cells are the pre-existing `pkgvecdim` `packed_array_var` residue, identical on both binaries |
  | `r10sing3_pa3.sv` | **CONVERTS** 1350 / 1394 → **uhdm-cmp EQUAL** both views (TO-GOLDEN 2, AWAY 0) |
  | `r10buvm22repro/g22.sv` | equidistant — the **entire** normalised diff is 12 lines of one constant, `22527705` vs `22556377`; cmp lines 1719/1719, heads 1/1, 0 listing cells |
  | `r10uvm154repro/l154_noenum.sv` | equidistant — 8 lines of the same constant; cmp bodies **byte-identical** on both binaries (head is a `pnq2::K22::ka_int_t` ref_typespec name) |

  **Zero unattributed movers.** The **44** committed arms of `r10earl98repro`,
  `r10vearl98repro`, `r10earl99repro`, `r10vearl99repro` and `r10uvm75repro`
  (earl98's bindVariable law, earl99's pattern-flatten law, the § 75 hoist net)
  are all **byte-identical on both binaries**, as is `g3_neg100`, the pass's own
  negative control, which is in the list and correctly absent from the diff.
* Gates: `GATES.r10vearl100.txt`. All green, all re-run here.

## 5. Ranked residues this verifier measured

1. **R0 (queued, earl101/earl96's family)** — `hmac_pkg.sv:17:11` typespec
   name, now the head of **both** Earlgrey modes with byte-identical cmp
   bodies. Naming is context-dependent; no uniform rename.
2. **INTEGRATION HAZARD — `RESUME.md` §3b.** The Earlgrey_0_1/testflags row
   carries a head this landing clears **and** a decode this verifier refutes
   ("18 / listed TWICE"). It must be corrected in the landing commit
   (campaign rule: docs ride with the code that implies them). The correction
   is quoted in §2 above.
3. **An interface's struct member skips the member scan** (the pass's R2).
   Independently reproduced on two different arms: `v3_gen100`'s `u_if.i_var`
   and `v5_deep100`'s `u_if.if_var` (`enum` member) are `struct_var` in golden
   and `struct_net` in **both** binaries. 0 corpus cells; interface-cluster
   hazard; its own law.
4. **A `pkg::T [N:0]` port is a net, not a `packed_array_var`** (the pass's
   R4) — 10 STILL-WRONG cells on `g1_portkind77`, identical on both binaries.
   STRICT-scan territory.
5. **A wildcard-imported PACKAGE VARIABLE is missing from an interface**
   (new here) — `v3_gen100`: golden materialises `vp3::shadowme` as a
   `logic_net` in `work@v3_if` and a `logic_var` in `work@v3_gen100.u_if`;
   we emit neither. Identical on both binaries, 0 corpus cells.
6. **A macro-expanded port declaration's DEF-view net** (new here) —
   `v7_edge100`'s `work@v7_macro.m_i` / `.o` span the macro *call* site;
   15 cmp lines, identical on both binaries.
7. **The layout-derived constant `22527705` / `22556377`** — a value that
   changes with binary layout reaches the database on `g22.sv` and
   `l154_noenum.sv` (uvm154 §7 / earl99 R7). Pre-existing, equidistant, and
   `byteverify` proves it is not a corpus mover — but it is an unspecified
   value in a shipped artifact and deserves its own pass.
8. **The symmetric probe segfaults** — 28, 14 per side, unchanged.

## 6. Files

| file | what |
|---|---|
| `v1_union100.sv` … `v7_edge100.sv` | the seven adversarial arms (faces × homes × spelling × view) |
| `varm.sh` | arm scorer: Surelog golden built in place, both frozen binaries, official `uhdm-cmp`, rc recorded |
| `lst3.py` | the three-way per-key listing scorer (golden / pristine / patched → TO-GOLDEN · AWAY-GOLDEN · STILL-WRONG · MOVED-WRONG); reads `ct100lst` from the pass's own repro dir |
| `ARM.r10vearl100.txt` | the arm table |
| `LISTING_SCORE.r10vearl100.txt` | every cell, every arm, both views |
| `CEN_*.txt` | this verifier's own census reports, both corpora, both binaries |
| `BOUNDARY_WIDE.tally` / `.diff` | the wide boundary, 4499 files |
| `BOUNDARY_ATTRIBUTION.txt` | the four non-pass boundary files, re-attributed |
| `ROWHEADS_*.txt`, `CT8ROWS.txt`, `GATES.r10vearl100.txt` | the raw gate battery |
