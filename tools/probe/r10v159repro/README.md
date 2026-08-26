# r10v159 — ADVERSARIAL VERIFICATION of r10uvm159 § `pkgImportTfOpFoldTs159`

**VERDICT: ACCEPT.** No pristine-right → patched-wrong cell was found on legal
SystemVerilog. `/tmp/r10uvm159.patch` is unchanged and is what should land;
this directory is verifier evidence only (five new arms, one scorer), and it is
additive.

Fresh worktrees at BASE `06e1acc`; both binaries rebuilt here, frozen
`chmod 555`, and `SLANG_UHDM` exported explicitly per binary. LHS is always
golden. The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else;
everything in this directory is measurement-only.

## 1. The pass's own numbers, reproduced

| claim | reproduced |
|---|---|
| pristine md5 `eacf54446cce390191ad1174f3fb9f73` | EXACT |
| patched md5 `2c7e7caa55154c7e82a0b83b7d1aa87b` | EXACT |
| goldens 23/0 both binaries, `/bin/false` 23 FAIL | EXACT |
| u2r 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, both modes, both binaries | EXACT |
| surelog histogram (471+466 / 283+284 / 25+23 / 10+9 / 5+5 / 3 / 2 / 1 / 1) | EXACT, pristine == patched |
| ct8rows: 0 differing rows vs the committed baselines AND vs this run's own pristine, both corpora, both modes | PASS ×5 |
| no row converted in either direction | confirmed |
| `cmds.txt` audit 1523/1523 + 1458/1458 name the frozen patched binary | EXACT; 0 name any other binary (pristine likewise) |
| byteverify u2r 0/1358, selfcheck 1357/1358 | EXACT |
| census delta table has EXACTLY ONE line, `MISSING-OURS own=operation ctx=tf home=cls` **54 → 0** | EXACT |
| whole-census totals gts 57674 unchanged, ots 52715 → 52769, MISSING 3359 → 3305, EXTRA 1240 → 1240 | EXACT |
| heads: SeqDriver 17 → 163 both modes, ONE `^LHS:`; every other head log byte-identical | EXACT |
| the patched SeqDriver head IS SimpleUVM's head (R0) | byte-identical modulo ids |
| canaries 52 / 8 changed=0; ctcan2 PASS ×2; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | EXACT |
| protected DBs SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | EXACT |
| wide boundary `LISTED=4441 PROCESSED=4441 PRODUCED_DBS=4291 MOVED_ARMS=5 RC_DIFFS=0`, same 5 arms | EXACT |
| the 5 movers re-measured against golden: WRONG→RIGHT **8**, MOVED-WRONG **0**, AWAY **0**, two heads cleared | EXACT |
| fence check over the four brief-fenced names = 0/0/0/0; surface = 3 production files + the repro dir; no `results/*.csv`; applies clean (plain `git apply --check`) on a fresh 06e1acc | EXACT |

Three cosmetic corrections, none of them a gate:

1. the production surface is **+105** lines (8 + 84 + 13), not +103;
2. "SeqDriver 58 added, 0 removed" is the DIFF-FILE line count; the ADDED-LINE
   count is **42** (7 dump lines × 6 new edges). MiniAmiq's 147 is right
   (176-line file, 29 hunk headers, 7 × 21 edges);
3. byteverify read **5** / 956 movers here, not 4: the fifth is
   **Scoreboard/default**, the known ~50/50 `vpiTaskFunc`-order COIN. Its
   path-normalised ORDER-BLIND dump diff is **0 added, 0 removed**, so it is
   not a content mover — but "the coin did not move at all" is a per-run luck
   reading (RESUME.md §9). The durable claim is the order-blind 0.

Order-blind dump diffs of the four real movers, re-measured: SeqDriver
**42 added / 0 removed** (both modes), MiniAmiq **147 added / 0 removed** (both
modes); every added line is one of the 6 / 21 new `ref_typespec` edges, and
NOTHING is removed.

## 2. THE ONE REAL FINDING — the census the law is scored on is CONTENT-BLIND

`ct159cls` decides a cell by COUNTING typespec-bearing constants per key:

```
if (gn == on) continue;                       // ct159cls.cpp
const char* cls = gn > on ? "MISSING-OURS" : "EXTRA-OURS";
```

so a cell where **golden holds typespec X and we hold typespec Y** is invisible
to it, and so is a key golden has that we do not emit at all
(`O.find(k) == end → continue`). The pass's "AWAY 0" is therefore a
**missing-edge** AWAY, not a **wrong-edge** AWAY — and a wrong-edge AWAY is
exactly what this pass risks, because its stamp runs BEFORE
§ `psBoundPkgParamTs31` and every other `!c->Typespec()` arm below it.

`vscore.py` closes that hole: it keys on the compare-visible payload plus owner
and home, and compares the **typespec STRING** across golden / pristine /
patched, scoring each changed cell TO-GOLDEN / AWAY / SIDEWAYS by multiset
distance. Run over all five arms here and over the four unpaired boundary
cells: **43 changed cells, 43 TO-GOLDEN (distance 2 → 0), 0 AWAY, 0 SIDEWAYS,
0 RIGHT→WRONG.** Future passes in this family should score the string, not the
count.

## 3. THE ARMS (all standalone, no UVM; `varm.sh` builds golden + ours and scores)

| arm | axis | pristine → patched (law cells) | AWAY |
|---|---|---|---|
| `v159_a_owners` | 19 owner positions the pass's grid A does not carry: part-select bounds 1 and 2 operations deep, a PLAIN part-select bound, a bit-select index with and without an operation, indexed-part-select BASE and WIDTH, a for-loop bound, `while`/`if` conditions, `$clog2` argument and `$clog2` under an operation, an unpacked-array index, a DEFAULT ARGUMENT value, a case item, depth-4 nesting, concat, replication, and the qualified negative control in two risky slots | 14 → 1 | 0 |
| `v159_b_faces` | 25 folded-constant faces: `int` / `integer` / `bit[7:0]` / `logic[3:0]` / untyped / `string` / `real` / sized-literal / unsized-literal / typedef / parameter-of-parameter / enum constant / cast / `$bits` / `$clog2` / macro / plain and sized literals / package-own / class localparam / class parameter / type parameter, plus `$bits`, `$clog2`, `int'()` and `64'()` OF the import | 14 → 2 | 0 |
| `v159_c_homes` | in-body, OUT-OF-BODY (`extern`), STATIC, NESTED-class and PARAMETERISED-class methods; package function; module function; class declared inside a MODULE; interface function; class declared inside an INTERFACE; module process; gen-scope process; one module instantiated THREE times | 4 → 0 | 0 |
| `v159_d_cross` | CROSS-PACKAGE ALIASING — the map is keyed on the slang `ParameterSymbol`, shared by every import of the same package parameter: two packages each materialise the SAME parameters and each hosts a class that folds them; plus a RANGED import whose range reads another import, a parameter defaulting to another parameter, and an EXPLICIT single-name import | 9 → 0 | 0 |
| `v159_e_gates` | THE GATES, ATTACKED: a MACRO expanding to a QUALIFIED read, a macro expanding to an UNQUALIFIED read, a class localparam and a class parameter default from the import, and a class at COMPILATION-UNIT scope while another package holds the same symbol in the map | 1 → 0 | 0 |

What the arms convict:

* **the `::` text gate HOLDS through a macro.** `` `define VE_QUAL vq159e_pkg::VE_A ``
  read as an operand inside a class method: slang's source range covers the
  EXPANSION, so `rawText` contains `::` and the arm abstains — and golden
  leaves that fold bare too. This was the single most dangerous gate
  (§ `psBoundPkgParamTs31`'s own comment records that a `rawText("::")` test
  misses a macro-written bound), and it is measured correct. The unqualified
  macro (`` `define VE_BARE VE_A ``) is the positive control and moves
  TO-GOLDEN.
* **the ordering risk is NULL.** The new stamp runs before
  § `psBoundPkgParamTs31`. A class-method part-select bound one operation deep
  (`v[VA_INT-1:0]`) and two deep (`v[VA_INT-1+2:0]`) carries the SAME
  `int_typespec@6:13-6:16` before and after, and golden's is the same object —
  no shadowing.
* **cross-package aliasing is harmless.** Two packages materialising the same
  symbol write the map last-writer-wins; both classes still get a typespec
  field-identical to golden's, including a RANGED import
  (`bit [VD_W-1:0]` → `bit_typespec@9:13-9:27`), because
  `stampPkgTsInst`/`wantInst9` instance the copy at its HOME package in either
  importer.
* **the law is not "wildcard".** An EXPLICIT single-name `import q::VE_B;`
  materialises the same way and golden stamps it; the patch stamps it and
  matches. The README's wording is narrower than both the code and golden.
* **the module homes are untouched.** A class declared inside a MODULE, a
  module function, an interface function, a module process and a gen-scope
  process were already right through § `tfOpFold9` and do not move.

## 4. RESIDUES, RANKED

1. **The census is content-blind** (§2). Highest-value fix for the family.
2. **Golden stamps more owners than the pass's R1 lists.** In the same
   class-method context golden also stamps a plain **`bit_select` INDEX**
   (`v[VA_INT]`, no operation between) and BOTH the **BASE and the WIDTH of an
   `indexed_part_select`** (`v[VA_INT+:8]`, `v[0+:VA_INT]`) — three owner kinds
   beyond R1's assignment / return_stmt / sys_func_call-argument / case_item.
   6 grid cells on `v159_a_owners`, 0 corpus cells.
3. **An OUT-OF-BODY (`extern`) class method never reaches the law.** Golden
   FOLDS the read in `function void C::m(); r = VC + 1; endfunction` and stamps
   it; we emit no constant at that span at all, so there is nothing to stamp.
   A separate under-emission (`v159_c_homes` line 40).
4. **`string` and `real` imported parameters are not folded by us** in a class
   method — golden folds and stamps (`string_typespec` / `real_typespec`), we
   keep a `ref_obj`. Same family as (3). This is also the NEW head of the
   boundary arm `g159_d_min.sv` after the fix, so it is the first thing the
   next pass on that arm will see.
5. **R5 confirmed on two fresh witnesses** (`v159_b_faces` line 46,
   `parameter VB_UNSZ = 'h17;`, and the two boundary arms): golden's fold
   carries a `ref_typespec` with a **NULL** `Actual_typespec` and `VpiSize -1`;
   ours carries a non-null actual and size 32. Both sides mismatch, and
   `expr::Compare` reads **VpiSize before Typespec**, so the pre-existing size
   mismatch is what the judge fails on — the new edge is neutral there, never
   RIGHT→WRONG. 4 boundary cells + 1 arm cell, 0 corpus cells.
6. **R2 confirmed** — a TYPEDEF-declared import read under a cast: golden gives
   the fold a `logic_typespec` NAMED after the typedef and
   `pkgImportParamTs159` has no entry, so we stamp nothing. 1 arm cell, 0
   corpus cells.

## 5. FILES

| file | what |
|---|---|
| `varm.sh` | build golden (`~/git-repos/Surelog/build/bin/surelog`, `-noprecompiledcache -nocache -mt 0 -mp 0`) and ours for one standalone arm, then score with `r10uvm159repro/ct159cls`. `SLANG_UHDM` and `CLS` must both be exported — no worktree path is baked in. Both exit codes are recorded; a missing database prints NOGOLDEN/NOOURS and is counted. |
| `vscore.py` | the CONTENT-AWARE scorer of §2: `vscore.py <golden.cen> <pristine.cen> <patched.cen>` over `r10uvm159repro/ct159cen` output, printing each changed cell's golden / pristine / patched typespec multiset and a TO-GOLDEN / AWAY / SIDEWAYS verdict by multiset distance. |
| `v159_a..e*.sv` | the five arms of §3. |
