# r10v123 — ADVERSARIAL VERIFICATION of r10uvm123 § `castPkgVecTdBareViewClone123`

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduced bit-for-bit on binaries I built myself. One **REGRESSION on legal SV**
survived their fences and I fixed it: a cast to a **TYPEDEF OF A TYPEDEF**. The
fix is one boolean at the recording site, it is **provably corpus-neutral**
(every one of the 956 + 1358 databases is BYTE-IDENTICAL to the implementer's
binary), and it restores four boundary cells to golden.

Deliverable: `/tmp/r10uvm123.verified.patch`.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
`results/*.csv` were **READ ONLY**; **no row converted**, nothing promoted;
slang not patched; the four fenced tests never dispatched.
**LHS IS ALWAYS GOLDEN (Surelog); RHS IS ALWAYS OURS.**

| | |
|---|---|
| BASE | `7bfb970`, worktrees `/tmp/wt_v123` (patched) and `/tmp/wt_v123pris` (pristine) |
| pristine md5 | `94786b24b692c0fbd46e1fefacfb715a` — **exactly the implementer's**, frozen `chmod 555` |
| implementer's patched md5 | `1c0f7d3c9a5a42edbee112912da29d98` — **exactly the implementer's**, frozen |
| verified (fixed) md5 | `4a0a39021ad91e31fb0187c33ed49ccd`, frozen |

## 1. THE REGRESSION — an ALIAS OF AN ALIAS is not cloned

```systemverilog
package quince123_pkg;
  typedef bit [7:0]     quince_base_t;
  typedef quince_base_t quince_mid_t;      // <- an alias OF an alias
  function automatic int quince_f(int qq);
    return int'(quince_mid_t'(qq));        // <- a BARE ranged-bit package cast
  endfunction
endpackage
```

`v123_m3_chain_novar.sv`, both views, official judge:

| | golden's cast target | ours |
|---|---|---|
| GOLDEN | `bit_typespec` **`quince123_pkg::quince_mid_t`**, `Typedef_alias -> quince_base_t` | — |
| **pristine** | | **byte-identical to golden** (2/2 def rows, 4/4 elab rows) |
| implementer's patch | | `bit_typespec` **`quince_mid_t`**, `Typedef_alias -> quince123_pkg::quince_mid_t` — **WRONG ON BOTH FIELDS** |

Both fields are read by `typespec::Compare` (`VpiName`, and `Typedef_alias`
walked before `Instance`). The **official uhdm-cmp head moves 17 -> 136 lines in
BOTH views** and the head object becomes this very pair — a differing object
where pristine had an exact one. `v123_m1_chain_min.sv` (the same chain WITH a
variable of the type, so LAW S's `ref_var` head masks the cell from the judge)
shows the same census regression: 2/2 exact rows -> 0/2.

Surelog's own reason: `compileDatastructureTypespec`'s cloning `SimpleType` arm
is not what a chained typedef reaches, so golden binds the package's LISTING
object, qualified, whose OWN `Typedef_alias` already points at the base
typedef's bare copy — which is exactly what we emitted before the pass.
It is **LAW S's own refusal**, at `src/TypeEmit.cpp`'s `note()`
(`targetType.getType().kind == SymbolKind::TypeAlias -> return`), and
§ `pkgTdCloneRefNoBind18` established it for the same reason. The implementer
carried LAW S's *copy builder* but not LAW S's *exclusion*.

### THE FIX — FENCE 6, five lines in `src/ExprEmit.cpp`

```c++
bool aliasOfAlias123 =
    expr.type && expr.type->kind == SymbolKind::TypeAlias &&
    expr.type->as<TypeAliasType>().targetType.getType().kind ==
        SymbolKind::TypeAlias;
if (bareCastName123 && !aliasOfAlias123 && cts && expr.type && ...
```

**The fix is corpus-neutral, proven, not argued:** `byteverify` of the fixed
binary's sweeps against the implementer's binary's sweeps is
**MOVERS 0 / 956** (surelog) and **0 / 1358** (uhdm2rtlil). Every number the
implementer reported therefore stands unchanged for the verified patch.
`R10U123_CASTTDDBG=1` on SimpleUVM prints `recorded=6 re-pointed=6` with and
without the fence: UVM has no bare alias-of-alias vector cast.

## 2. EVERY HEADLINE NUMBER, REPRODUCED

| claim | reproduced |
|---|---|
| pristine md5 = main tree's build at `7bfb970` | **yes**, `94786b24…` |
| patched md5 `1c0f7d3c…` | **yes** |
| goldens 23/0 pristine, patched, fixed; `/bin/false` 0/23 | **yes** |
| uhdm2rtlil 679/50/2 both modes, all three binaries | **yes** |
| `ct8rows` uhdm2rtlil: 0 differing rows vs committed baseline AND vs own pristine | **yes** (status AND dump) |
| uhdm2rtlil byteverify 0 / 1358 | **yes** (SELFCHECK 1357/1358) |
| surelog default 471/283/25/10/5, testflags 466/284/23/9/5/3/2/1/1 | **yes**, identical for pristine, patched and fixed |
| `ct8rows` surelog: 0 differing rows over 1588 vs `results/golden_surelog.csv` | **yes** |
| surelog byteverify **9 / 956**, exactly the nine in `PREDICT.r10uvm123.txt` | **yes**, name for name |
| all nine movers are **CMP_NOTEQUAL** rows — no CMP_EQUAL row moved a byte | **yes** (verified against the CSV) |
| SimpleUVM/default order-blind `removed=6 added=45` | **yes**; also BuildUVMPkg 6/45, SimpleUVM/tf 6/45, Scoreboard 6/45, SeqDriver 10/49, MiniAmiq 10/49 — **0 non-typespec lines in every one** |
| direction TO-GOLDEN 6 / AWAY 0 per mover | **yes** — independently: cast-census MATCH +6 and **LOST_GOLDMATCH = 0** in all nine |
| heads 148 -> 98 on SimpleUVM ×2, Scoreboard/default, BuildUVMPkg ×2 | **yes** |
| SeqDriver / MiniAmiq / Earlgrey head logs BYTE-IDENTICAL; Rggen still 0 | **yes** (Rggen's log byte-identical too) |
| committed `head_pris_default_SimpleUVM.cmp` / `head_pat_…` | **byte-identical to my own runs** |
| canaries ok=52 / ok=8 changed=0; ctcan2 PASS ×2; canaudit 29/0/0 | **yes** |
| five protected DBs byte-identical, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | **yes** |
| wide boundary 3746 arms | **3756 with my 10 new arms — the count checks out** |

Determinism: SimpleUVM / SeqDriver / MiniAmiq / BuildUVMPkg are byte-stable
across three fixed-binary runs. Scoreboard/default flips (the standing ~50/50
COIN) — its two faces are **order-blind identical** (removed=0 added=0), and its
mover was attributed order-blind.

## 3. WHERE I BROKE THE LAW — the arms

`arm_v123.sh` runs Surelog in BOTH views and both frozen binaries in BOTH views
and judges with the official `uhdm-cmp` in BOTH views.

> **A harness correction the implementer's `arm123.sh` needs.** It omits the
> corpus's own `--single-unit --nobuiltin`, so every arm database carries a
> `builtin` package golden does not have and the cmp count is swamped:
> `v123_m2_plain_min` reads **2478** lines without `--nobuiltin` and **122**
> with it. Their arm cmp column ("5442 -> 5442") is therefore not a
> non-increasing check of anything; their **census** score is. With the flag the
> same arm reads **122 -> 0, CMP_EQUAL**.

| arm | what it varies | cmp def p->q | cmp elab p->q |
|---|---|---|---|
| `v123_m2_plain_min.sv` | the minimal positive control | **122 -> 0 CMP_EQUAL** | **122 -> 0** |
| `v123_m4_plain_novar.sv` | same, cast not stored in a variable | **122 -> 0 CMP_EQUAL** | **122 -> 0** |
| `v123_m1_chain_min.sv` | alias-of-alias, judge-masked | 56 -> 56 | 60 -> 60 |
| `v123_m3_chain_novar.sv` | **alias-of-alias, judge-VISIBLE** | 17 -> 17 (**was 17 -> 136**) | 17 -> 17 (**was 17 -> 136**) |
| `v123_a_chain.sv` | 2- and 3-deep chains × home pkg / class / other pkg / module / module sub | 56 -> 56 | 60 -> 60 |
| `v123_b_bounds.sv` | macro / parameter / localparam / literal / signed bounds × home fn, home class, wildcard importer, EXPLICIT importer, interface sub, module scope, module sub | **174 -> 33** | **174 -> 112** |
| `v123_c_kinds.sv` | bit, logic, rangeless bit, rangeless logic, int, integer, byte, shortint, longint, enum, packed struct, **packed union**, 2-D packed, packed array of typedef | 5804 -> 5804 | 6462 -> 6462 |
| `v123_d_scopes.sv` | `$unit`, class-scope, module-scope, interface-scope typedefs beside the package control | **122 -> 17** | **122 -> 17** |
| `v123_e_spelling.sv` | ONE typedef cast bare / package-scoped / wildcard-visible / explicitly imported / from a nested block | 1130 -> 1130 | 1218 -> 1218 |
| `v123_f_multi.sv` | **3 instances** of one module + a 3-iteration generate loop | **170 -> 26** | **174 -> 26** |

**NON-INCREASING in every arm and both views.** Multiset direction score
(`LOST_GOLDMATCH` = golden-matching census cells we HAD and lost):
**0 in every arm, every view.** Golden-matching cells rise
(`b_bounds` 4->29 def / 10->59 elab, `c_kinds` 13->21 / 28->46,
`d_scopes` 2->8 / 5->16, `e_spelling` 3->10 / 5->18, `f_multi` 3->10 / 9->22).

Cells that MUST NOT move, and did not: `$unit` (`iron123_unit_t`,
`iron123_lunit_t`), class-scope (`jun_cls_t`), module-scope (`iron_mod_t`),
interface-scope (`kapok_if_t`), and every PACKAGE-SCOPED written spelling
(`larch123_pkg::larch_v_t` at 17:10 / 19:10 / 33:15 — untouched and matching
golden while the bare spellings in the SAME method were cloned).

Kind grid: `bit`/`logic` with ranges move, and a **2-D packed** `bit [1:0][7:0]`
typedef moves too — golden agrees (`gum_2d_t` matches golden after the pass).
Rangeless `bit`/`logic`, `int`, `integer`, `byte`, `shortint`, `longint`,
`enum`, packed `struct`, packed `union` and a packed-array-of-typedef are all
left exactly where pristine had them.

The four earlier-pass arms the boundary flags, re-measured against THEIR
goldens with the fixed binary: `g29_b_targets` MATCH 4->5, `v118_a3_written_fences`
0->2 (def) / 0->4 (elab), `gv29_e_targets` 1->3, `gv29_g_tdname` 2->4 (def) /
4->8 (elab) — **`LOST_GOLDMATCH` = 0 in all four**, cmp counts unchanged.

## 4. THE TWO WIDE BOUNDARIES (fixed binary vs pristine)

Both from a **COPY** of `tools/probe` with **no path filter**, `.sv` and `.v`,
list on **fd 3**, children `</dev/null`, **PROCESSED asserted**, **rc per cell**.

**Per file** (`vwide123.sh`, the implementer's, reused):
`PROCESSED=3756 identical=7182 DIFFERING=36 no_output=294`;
rc histogram `rc=0 13850, rc=3 560, rc=4 586, rc=139 28` — the 28 segfaults are
14 elab cells on **BOTH** binaries (symmetric, pre-existing).
All 36 differing cells are arms of THIS family: 14 the implementer's own
(positive control), 14 mine, 8 the four earlier-pass arms.
**`v123_a_chain`, `v123_m1_chain_min` and `v123_m3_chain_novar` are ABSENT from
the list** — independent confirmation that fence 6 restored them.

**Per directory** (`vdir_v123.sh`, mine — every directory's files compiled in ONE
invocation): `PROCESSED=1552 identical=2821 DIFFERING=19 no_output=264`;
rc `0 5430, 3 516, 4 250, 139 12` (6 elab cells on each binary).
Of the 19, **11 are pure `vpiTaskFunc` LIST-ORDER coins** — proven by running the
PRISTINE binary alone four times on those directories
(`r10uvm117repro`, `r10uvm75repro`, `r10uvm76repro`, `r10v109repro`,
`r10v117repro`, `r10uvm88repro` produce up to four different hashes) and by an
**order-blind diff of 0 lines** in every one. The remaining 8 are the four
directories that hold this family's arms
(`r10uvm123repro`, `r10v123repro`, `r10buvm29repro`, `r10v118repro`), whose
order-blind diffs are 313/389, 443/577, 15/15 and 30/34 lines.
**No other precedent moved**: `r10uvm107repro` (§ `oobRefVarLocalHoistNet107`'s
four nets), `r10uvm114repro` (the re-pointed enum-base clones), `r10uvm76repro`'s
enum-constant pool, `r10uvm105repro`, `r10uvm97/98repro`, `r10buvm18/20repro`,
`r10uvm103repro`, `r10buvm23repro`, `r10uvm92/94/95/89repro`, `r10buvm24repro`,
`r10uvm99repro`, `r10buvm13/15/28/57/64/88repro` — identical in both views, both
boundaries.

## 5. RESIDUES, RANKED

1. **R1 (the implementer's, confirmed and quantified)** — a cast clone inside a
   WILDCARD-IMPORT clone body wants a BARE alias target. It is the only reason
   SeqDriver's and MiniAmiq's censuses still show 4 non-golden cells each
   (2 cells × 2 views) after gaining 6 golden ones. Witnesses
   `v123_b_bounds.sv` @18:10/@20:10/@22:10 (golden carries TWO rows per site,
   one `alias=pkg::T` and one `alias=T`; we now match the first exactly and
   miss the second only in the alias's own name). § `importCloneBareTdAlias16`
   reaches a clone `task_func`'s `Io_decls`/`Variables`, never its statement
   tree. **Highest value next step.**
2. **R7 (NEW, mine)** — the alias-of-alias cast target is *correct again* but
   still not *modelled*: golden's chained-typedef binding is the listing object
   in the home package yet a BARE clone once a wildcard importer exists
   (`v123_a_chain.sv` @15:10, golden's two rows split `alder_mid_t`/
   `alder123_pkg::alder_mid_t` by `vpiInstance`). Fence 6 keeps us on pristine's
   answer, which is right for the un-imported case and no worse for the
   imported one (census MATCH 0->0, `LOST_GOLDMATCH`=0). Zero corpus witnesses.
3. **R2 / R3 / R4 / R5 / R6** — the implementer's, all re-measured and all
   identical on the pristine and the fixed binary. R3 (a packed-array cast
   target is the wrong KIND) reproduces on my `v123_c_kinds.sv` @38:10:
   golden `packed_array_typespec gum_parr_t`, ours a rangeless `bit_typespec`
   named `gum123_pkg::gum_parr_t`, unchanged by the pass.
4. **R8 (NEW, methodological)** — `arm123.sh` must pass `--single-unit
   --nobuiltin` (§3 above). Until it does, no arm in `ARMS.r10uvm123.txt` has a
   meaningful cmp column.

## 6. FILES HERE

| file | what it is |
|---|---|
| `arm_v123.sh` | one arm: Surelog **both views** + both frozen binaries **both views**, cast census + **official uhdm-cmp in both views**, corpus flags by default |
| `vdir_v123.sh` | the PER-DIRECTORY wide boundary (fd-3 list, `</dev/null`, PROCESSED asserted, rc per cell) |
| `v123_a_chain.sv` … `v123_m4_plain_novar.sv` | the ten arms of §3 |
| `VERIFIED.r10v123.txt` | the whole battery, verbatim |
