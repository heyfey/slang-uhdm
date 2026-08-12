# r10earl29 — § concatIdxDecompile29

## 0. MASTER'S INTEGRATION ADDENDUM — verdict PARTIAL; TWO regressions FIXED before landing

The verifier found the decoded table wrong/incomplete in SIX product cells, two of
them **strictly worse than base**. Both were fixed in code before this landed;
the rest are ranked residues (all 0-mover under-fires, priced empirically):

| # | finding | disposition |
|---|---|---|
| **F1** | the `Conversion` arm rendered EMPTY for EVERY conversion surviving the strip — the string literal of `q.m[{"a_chan_", s}]` was **DELETED** (`q.m[{,s}]`, base was one space from golden). The README's claimed abstention was not on that path. | **CODE FIXED**: EMPTY only for a WRITTEN `CastExpression`; every other surviving conversion ABSTAINS. NOTE the verifier's mechanism wording was itself off — `stripImplicitConv` removes `isImplicit()` = Implicit AND Propagated (ConversionExpression.h:28), so what survives is StreamingConcat/Explicit/BitstreamCast; the measured deletion and the fix stand under both readings. Re-measured on arm `v10_str.sv`: literal intact, cast control (`2'(k)`, b3_edges o3) still EMPTY. |
| **F2** | the RangeSelect arm couldn't tell `w[3:0]` from `m[1][3:0]` — the latter shipped `{1'b1,3:0}`, base name LOST. | **CODE FIXED** with the verifier-specified gate `simpleBase && elemLevels == 0`; anything else abstains. Defect signature `{1'b1,3:0}` absent on arm `v2_sel.sv`; golden's full rendering recorded as unmeasured-beyond-one-cell. |
| F3 | a SIXTH hier_path name site (cross-instance prefix) is unpatched — under-fire, carrier Nyuzi soc_tb.sv:377 (SLANG_REJECT) | residue V3 |
| F4 | scoped names drop the `pkg::` qualifier where golden renders the VALUE (import-context-dependent — the naming dead-end family) | residue V4 |
| F5 | golden strips digit-separator `_` from constants (`4'd1_0`→`4'd10`) | residue V5 |
| F6 | indexed part select rendered from raw text, not recursively (`{1'b1,k[0]+:2}` vs golden `{1'b1,+:2}`) | residue V6 |

**Integration gates on the FIXED binary `aedb6f94…`** (agents' md5s `40ca13d1…`
reproduced bit-for-bit first, then the fix rebuilt): goldens 23/0, negctl 0/23;
u2r 679/50/2, 0 differing rows, **0 byte movers / 679** vs a freshly rebuilt
bc6abbb control (itself the FOURTH bit-for-bit reproduction of `d1ccd848…`);
surelog 467/13 + 463/10, 0 differing rows, **2 movers / 953**: Earlgrey — 12
changed shapes, EVERY fixed count landing exactly on golden's (3/3, 2/2 at both
`:309` and `:422`), **0 moved away** — and Scoreboard with **multiset delta ZERO**
(pure permutation, the known per-run instability). Arm re-run on the fixed
binary: v10/v2/b3/a1/a6 → **0 over-fires**, 38 cells fixed, a6_noconcat control
unchanged. Head re-measured on the landed base: **36 lines, 1 head**, `constant
@389:36-389:50` golden `vpiConstType:7` vs ours `:9` — pre-existing (base's own
dump already reads `:9`), now the row's actual blocker, handed to r10earl30.

---

**The target.** `Earlgrey_0_1` (surelog corpus, **default** mode), the design's only
not-equal row: **228 cmp lines, ONE head**, at `dm_csrs.sv:309`.

```
SOURCE  cmd_valid_d = abstractauto_q.autoexecprogbuf[{1'b1, dmi_req_i.addr[3:0]}];
GOLDEN  hier_path: (abstractauto_q.autoexecprogbuf[{1'b1,}])
OURS    hier_path: (abstractauto_q.autoexecprogbuf[{1'b1, dmi_req_i.addr[3:0]}])
```

**Outcome.** The head is **CLEARED** — 228 cmp lines → **36**. `Earlgrey_0_1/default`
does **NOT** convert: clearing this head exposed a **second, pre-existing head** that
was masked behind it (`vpiConstType` 7-vs-9 on a package enum literal at
`dm_csrs.sv:389`, characterised below and **proved pre-existing**). One mover, both
its occurrences, every changed line landing exactly on golden.

---

## 1. LOCALIZATION — which field, on which object

Read from the **generated** Compare in `~/git-repos/UHDM`, not guessed:

`build/generated/src/hier_path.cpp` — `hier_path::Compare` reads `VpiName` **explicitly**:

```cpp
if ((r = basetype_t::Compare(other, context)) != 0) return r;      // <-- fires first
...
if ((r = SafeCompare(lhs, lhs->Path_elems(), rhs, rhs->Path_elems(), context)) != 0) return r;
if ((r = SafeCompare(lhs->Root_value(), rhs->Root_value(), context)) != 0) return r;
if ((r = lhs->VpiName().compare(rhs->VpiName())) != 0) { ... }
```

`build/generated/src/bit_select.cpp` — `bit_select::Compare` reads **neither** name:

```cpp
if ((r = basetype_t::Compare(other, context)) != 0) return r;
if ((r = (lhs->VpiConstantSelect() == rhs->VpiConstantSelect()) ? 0 : ...) != 0) { ... }
if ((r = SafeCompare(lhs->VpiIndex(), rhs->VpiIndex(), context)) != 0) return r;
```

`bit_select` is `final : public ref_obj`, and the chain bottoms out at
`BaseClass::Compare` (`build/generated/src/BaseClass.cpp:163`), which reads exactly
three fields:

```cpp
if ((r = VpiType() - rhs->VpiType()) != 0)                 { ...; return r; }
if ((r = VpiName().compare(rhs->VpiName())) != 0)          { ...; return r; }
if ((r = VpiDefName().compare(rhs->VpiDefName())) != 0)    { ...; return r; }
```

> **REFUTATION 1 — the brief's framing.** The brief describes the difference as living
> "inside the hier_path NAME **and** the bit_select NAME/FULLNAME". **`VpiFullName` is
> never compared by anything**: `grep -rn "VpiFullName().compare" build/generated/src/`
> returns **zero hits** across all generated Compares. And the `bit_select`'s `VpiName`
> is `autoexecprogbuf` on *both* sides. **The single gating field is the `hier_path`'s
> `VpiName`.** The `bit_select` fullname difference is a real dump difference and a
> genuine byte mover, but it can never be a cmp head.

Localized on the target, not by eye — the whole failing subtree diffed with ids and
spans stripped (`/tmp/e29_L.txt` vs `/tmp/e29_R.txt`): **every** differing line is the
bracket text, spans and structure identical, and the compared field is

```
|vpiName:abstractauto_q.autoexecprogbuf[{1'b1,}]        (golden)
|vpiName:abstractauto_q.autoexecprogbuf[{1'b1, dmi_req_i.addr[3:0]}]   (ours)
```

**The field was proved by flipping it**: the shipped patch changes *only* name strings
(28 changed dump lines, all name strings — §5), and the head went 228 → 36. Nothing
else in the subtree was touched.

## 2. WHERE the string is built, and the actual root cause

`src/ExprEmit.cpp`, the single-dim member-select hier_path builder — the Earlgrey site:

```cpp
std::string idxTxt9 = rawText(es.selector().sourceRange);   // <-- RAW SOURCE TEXT
...
dotted += "[" + idxTxt9 + "]";
```

> **The root cause is not a truncation rule. We copy SOURCE TEXT; Surelog DECOMPILES
> ITS OWN TREE.** Every divergence in the grid — the missing space after a comma, the
> vanished elements, the range-only part selects, the doubled replication braces —
> is one consequence of that single difference in *method*. The emitter already carried
> two partial approximations of that decompiler (`spaceIdxOps`, `selName`), which is
> why a non-concat `[k+1]` index already renders `k + 1` in golden and `k+1` here.

## 3. THE DECODED RULE — the grid, cell for cell

Nine arms, both element positions, 2- and 3-element concatenations, five statement
contexts, four emitter name-building sites, and a non-concat CONTROL arm. Driver
`arm.sh` (LHS always golden/Surelog, RHS always ours); cell extractor `cells.py`
(**span-keyed**, because `uhdm-dump` prints one object many times and a positional
pairing would compare an object with a re-print of a different one).

### 3a. The leaf table (`R(e)`), measured

| element kind | golden renders | proven by |
|---|---|---|
| constant | its own spelling — `1'b1`, `4'd3` | a1 o1, a2 o1 |
| ref_obj: net / var / localparam / enum literal / enum var | its **name** — `k`, `P`, `E1`, `ev` | a1 o2, b2 o3/o4/o5 |
| concatenation | `{R,R,...}` — comma, **NO space** | a1 o6, a5 o1 |
| replication | `{R(n){R(concat)}}` — `{2{1'b1}}` → **`{2{{1'b1}}}`** | a1 o7, b3 o6 |
| binary `+ - * /` | `R(l) op R(r)` — **spaces around the operator** | b2 o6, a6 o4 |
| unary `~` | `~R(operand)` — `~k[0]` → **`~`** | b2 o7 |
| ternary | `R(c) ? R(l) : R(r)` → **` ? 1'b1 : 1'b0`** | b2 o8 |
| system function call | its own spelling — `$clog2(4)`, `$signed(k)` | a5 o6, b3 o4 |
| part / indexed part select, **simple** base | the **RANGE ALONE** — `w[3:0]`→`3:0`, `w[1+:2]`→`1+:2` | a1 o4, b3 o2 |
| **multi-level** element select, simple base | **in full** — `m[1][2]` | a1 o9, a2 o9 |
| **single-level** bit select | **EMPTY** — `w[2]` → `` | a1 o5, b1 |
| member access / hierarchical ref | **EMPTY** — `rq.addr`, `rq.addr[3:0]`, `u.x` | a1 o3/o10, b3 o5 |
| **user** function call | **EMPTY** — `fx(k)` | a1 o8 |
| explicit cast | **EMPTY** — `2'(k)` | b3 o3 |

### 3b. Structure

* **The comma always survives.** N elements → N−1 separators regardless of which
  render empty: `{1'b1,}` / `{,1'b1}` / `{1'b0,,1'b1}` (empty in the MIDDLE) /
  `{1'b0,1'b1,}` (empty LAST) / **`{,}`** (EVERY element empty). — a5 o2/o3/o4/o5
* **Position is irrelevant.** a1 (candidate second) and a2 (candidate first) are exact
  mirrors, cell for cell.
* **Context is irrelevant.** a4 renders identically in all five: module-scope
  cont-assign, unnamed `always_comb`, **named** block, `always_ff`, and as an
  assignment **LVALUE**. 15/15 cells equal.
* **Only the hier_path name carries an index.** A plain non-hier `bit_select` names
  itself `work@m.pbuf` with **no bracket at all**, whatever the index — a3, **11/11
  cells equal at base and unchanged after the patch**.

### 3c. Every brief hypothesis is REFUTED

> **REFUTATION 2.** The brief offered five candidate rules; the grid kills all five.
>
> * **(a) "any non-constant element renders empty"** — FALSE. `k`, `ev`, `m[1][2]`,
>   `$signed(k)`, `k[1:0]+1'b1` are all non-constant and all render.
> * **(b) "any element containing a `.` renders empty"** — FALSE both ways. `w[2]` has
>   no dot and renders empty; and `w[3:0]` has no dot yet renders only *part* of itself.
> * **(c) "any element containing a SELECT renders empty"** — FALSE. `m[1][2]` is two
>   selects and renders in full; `w[3:0]` renders its range.
> * **(d) "only the FIRST element ever renders"** — FALSE, and a2 was built to kill it
>   directly: `{k,1'b1}` renders both, `{,1'b1}` renders only the *second*.
> * **(e) "a length limit"** — FALSE. `{1'b1,{2{{1'b1,1'b0}}}}` is longer than the
>   source it replaces.
>
> The real rule is none of these: it is a **recursive decompiler with an incomplete
> leaf table**. The brief's own summary of the target cell ("the constant element
> rendered, the hierarchical element rendered as EMPTY STRING, the comma PRESERVED")
> is *correct for that one cell* and does not generalise — exactly the risk the brief
> named.

### 3d. The gate is NOT "contains a concatenation" — the top-level kind decides

> **REFUTATION 3, and this one changed the shipped design.** `m[1][2]` renders **in
> full** as a concat *element* (a1 o9) but as a **whole index** golden drops the entire
> bracket group: `q.autoexecprogbuf[m[1][2]]` → **`q.autoexecprogbuf`** (b2 o1). Same
> for `w[2]` (b2 o2) and `rq.addr` (a6 o3). So Surelog gates the brackets on the index's
> **top-level kind** ∈ {constant, ref_obj, operation} and only *then* recurses with the
> richer table. Arm b2 was written to separate these two models and did.
>
> **That bracket-drop is a different law and is deliberately NOT shipped here** — it is
> outside the assigned territory (non-concatenation indices) and is residue R1.

## 4. THE LAW AS SHIPPED — § concatIdxDecompile29

Declared in `include/UhdmExporter.h` (full table + gate in the comment); implemented in
`src/ExprEmit.cpp` as `UhdmExporter::idxDecompile` (one node) and
`UhdmExporter::concatIdxText` (the gate).

**THE GATE, and it is the gate in the code at all five call sites:**

```cpp
std::string UhdmExporter::concatIdxText(const Expression& sel) {
    auto& s9 = stripImplicitConv(sel);
    if (s9.kind != ExpressionKind::Concatenation)   // <-- THE GATE
        return {};
    std::string out;
    if (!idxDecompile(s9, out))                     // <-- unmeasured kind -> abstain
        return {};
    return out;
}
```

Returning `""` means *"not my shape, leave the caller's text alone"* — unambiguous,
because a concatenation always renders at least `{}`.

**The five call sites**, each with the identical gate and each keeping its own
pre-existing fallback untouched:

| site | shape | grid cell |
|---|---|---|
| `emitMixedHierPath`, `dotted` loop | mixed hier path name | b1 o2/o3 |
| `emitMixedHierPath`, `dottedAt` base-select | base multi-dim select | b1 o3 |
| `emitMixedHierPath`, `dottedAt` member-select | member select | b1 o2 |
| single-dim member-select, NamedValue base | **THE EARLGREY SITE** | a1/a2/a4/a5/b2/b3 |
| nested selects, member-access leaf | member + TWO selects | b1 o1/o4 |

The fifth site was found **because b1 measured it**: after the first four were patched
b1 o1/o4 (`z.g[{1'b0,k[0]}][3]`) were still wrong. All four b1 site families now render
byte-exactly as golden.

**Two MEASURED ABSTENTIONS** — `idxDecompile` returns false so the whole index keeps
its raw text, rather than shipping a guessed spelling:

* **wildcard-imported package parameter element.** Golden reduces `PP` to the **sized
  literal `2'd1`** (b3 o1) — which is neither the identifier nor the decimal value that
  the existing `§ hierSelPkgParamFold` splices for a whole-index fold. Detected exactly,
  via `importedParamDefTs.count(&sym)`. Residue R2.
* **multi-argument / spaced system call.** Only single-argument system calls are
  measured, so a spelling carrying `,` or a space abstains. This is what protects the
  Opentitan `cov.sticky_intr_cov[{"...", $sformatf("%0d", each_bit)}]` shape (also
  guarded by the string-literal kind falling through to `default: return false`).

## 5. THE CENSUS AND THE MOVERS

**Census run BEFORE coding, so the movers were a prediction and not a discovery.**

* **uhdm2rtlil corpus: ZERO** occurrences of a concat-indexed member select
  (`grep -rInE '\.[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\[[[:space:]]*\{'` → 0 files).
  The only two `[{` carriers are `asym_ram_sdp_read_wider` / `asym_ram_sdp_write_wider`
  (`RAM[{addrB, lsbaddr}]`) and both are **plain selects on a simple name** — no
  hier_path, and per arm a3 no index in the name. Both are `CMP_EQUAL`+`match` today,
  so they are the ideal over-fire canary. **Predicted: 0 movers.**
* **surelog corpus: 14 files carry the shape, and every carrier but one is unmeasurable
  today** — `Earlgrey_Verilator_0_1`, `IncompTitan`, `AzadiRTL`, `Ariane2024`,
  `NyuziProcessor`, `Opentitan` are all **SLANG_REJECT** (we never write a database);
  `Earlgrey_nexysvideo` and `Earlgrey_Verilator_01_05_21` are **DEFERRED**; `ariane`
  is not a test. `Ariane2024`/`ariane` carry `data[{cl_offset_q,3'b0} +: N]`, an
  **indexed part select** whose top level is a RangeSelect — outside the gate anyway.
  **Predicted: exactly ONE mover, `Earlgrey_0_1/default`.**

**PREDICTION CONFIRMED.** Both byte verifiers report exactly the predicted movers
(§6, gate 5). No unpredicted mover.

### Per-shape attribution of the mover, against GOLDEN

`Earlgrey_0_1/default`: **28 changed dump lines** (base-ours vs patched-ours), covering
**two** source occurrences of the shape — `dm_csrs.sv:309` **and `dm_csrs.sv:422`**
(the census grep had found only 309 because the second is an identical line elsewhere
in the same file). Three distinct shapes:

| shape | removed | added |
|---|---|---|
| `hier_path` paren name | `(abstractauto_q.autoexecprogbuf[{1'b1, dmi_req_i.addr[3:0]}])` | `(abstractauto_q.autoexecprogbuf[{1'b1,}])` |
| `bit_select` paren fullname | `work@dm_csrs.csr_read_write.abstractauto_q.autoexecprogbuf[{1'b1, dmi_req_i.addr[3:0]}].autoexecprogbuf` | `...[{1'b1,}].autoexecprogbuf` |
| `vpiName:` / `vpiFullName:` fields | the same two, as field lines | the same two, as field lines |

Every one of the 28 lines checked individually with `grep -Fxc` against golden's dump:

```
=== REMOVED lines: each must be ABSENT from golden ===
  OK: all removed lines absent from golden (0 findings)
=== ADDED lines: each must be PRESENT in golden ===
  OK: all added lines present in golden (0 findings)
```

**ADDED and REMOVED counted separately, and both clean.**

### The NEW head, and the proof it is pre-existing

```
GOLDEN  constant: , line:389:36, endln:389:50   vpiDecompile:0  vpiSize:3  INT:0  vpiConstType:7
OURS    constant: , line:389:36, endln:389:50   vpiDecompile:0  vpiSize:3  INT:0  vpiConstType:9
SOURCE  dm_csrs.sv:389: end else if (cmderr_q == dm::CmdErrNone) begin
```

A package **enum literal** folded to a 3-bit 0: golden types it `vpiIntConst` (7), we
type it `vpiUIntConst` (9). Everything else about the object matches.

**Proof it is not mine, two independent ways:**
1. The base-vs-patched dump diff is **28 lines, and `grep -c "vpiConstType\|389:"`
   over them returns 0** — the object is byte-identical in both binaries.
2. Read straight out of the **base** binary's dump at that span: `|vpiConstType:9`.

It was simply **masked**: `uhdm-cmp` reports ONE head per run, and this one sat behind
the concat-name head.

> **REFUTATION 4 — the brief's premise.** The brief states this was "the SINGLE
> remaining head on this design after 28 passes, so clearing it is a plausible
> CONVERSION." Clearing it did **not** convert the row: there was a second head all
> along, invisible because one head is all cmp will show. **"One head" is a property of
> the instrument, not of the design.**

## 6. THE FIVE GATES

**GATE 1 — BUILD.** Absolute build path
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl29/build`;
`[100%] Linking CXX executable slang-uhdm` present in the output on both builds; md5
asserted changed in a **separate command** each time; baseline md5 checked for 32 hex
digits before building (`^[0-9a-f]{32}$`).

```
BASELINE_MD5=663899bcad3b7696f1d3f9fa972ec085   (well-formed, 32 hex)
after first build   3b2d7e8513db0c69014f7e8e18e4be61   md5 CHANGED
after 5th-site fix  40ca13d1183a4b10ab52dd809af1f1ca   md5 CHANGED
```

**GATE 2 — GOLDENS: 23 PASS / 0 FAIL.** Negative control `SLANG_UHDM=/bin/false`:
**0 PASS / 23 FAIL** — the harness has teeth. Run early (immediately after the first
build) and again after the fifth-site fix, because this is a naming law and campaign
memory records uniform name fixes breaking goldens before.

**GATE 3 — u2r testflags, `--jobs 2`.**

```
testflags fresh:  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump      fresh:  496 match  183 differ  52 blank
WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

**GATE 4 — surelog `--mode both`, `--jobs 2`.** See §7 for the measured numbers.

**GATE 5 — BYTE VERIFIER, both corpora**, against a **pristine 266d3a6 workdir built
by me** (`.claude/worktrees/r10earl29pris`, `git rev-parse HEAD` =
`266d3a6649663dc151188b0623e88d9336b7c745`, binary md5 `663899bcad3b7696f1d3f9fa972ec085`
— identical to this pass's own pre-patch md5, which is what makes it a valid baseline).
Base commits of **both** binaries printed and checked before any delta was attributed.
`SELFCHECK=1 SELFCHECK1=1` on both runs. See §7.

**CANARIES.** `EXPECT_UNKNOWN=6 tools/probe/r10oth7repro/ctcan2.sh` on u2r
(`ok=1 changed=0 absent=0 unknown-patterns=6`);
**`tools/probe/r10uvm52repro/canaries.sh`** — named explicitly, six files share that
basename — on u2r (`ok=8 changed=0 absent=0`);
`tools/probe/r10uvm55repro/canaudit.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`.
`InterfaceModPort` and `BlackParrotComplex` checked **by name** (no row in u2r; see §7
for surelog).

## 7. MEASURED NUMBERS (surelog corpus / byte verifier)

**GATE 4 — surelog `--mode both --jobs 2`**, judged whole-row against the committed
`results/golden_surelog.csv`:

```
default    fresh:  467 CMP_EQUAL  13 CMP_NOTEQUAL   5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  fresh:  463 CMP_EQUAL  10 CMP_NOTEQUAL   5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
                                  3 NO_DATABASE  1 NO_UHDM  1 TIMEOUT  2 UNTRANSLATABLE
dump default:    225 match  242 differ  327 blank
dump testflags:  165 match  298 differ  331 blank
WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` left at its default — **5 DEFERRED**, both modes.

**`Earlgrey_0_1/default` stays `CMP_NOTEQUAL`. It does NOT convert, so there is nothing
to promote and no row is quoted as converted.** `results/*.csv` was read only, never
written.

**Canaries.**

```
u2r      ctcan2.sh   EXPECT_UNKNOWN=6  ->  ok=1  changed=0 absent=0 unknown-patterns=6   PASS
u2r      r10uvm52repro/canaries.sh     ->  ok=8  changed=0 absent=0 unknown-names=25     (u2r expects the surelog-only names to be absent)
surelog  ctcan2.sh   EXPECT_UNKNOWN=1  ->  ok=58 changed=0 absent=0 unknown-patterns=1   PASS
surelog  r10uvm52repro/canaries.sh     ->  ok=52 changed=0 absent=0 unknown-names=7      (the documented 7 u2r-only names)
         r10uvm55repro/canaudit.sh     ->  audited=29  UNCOVERED=0  FENCE-BREACH=0       PASS
```

`InterfaceModPort` and `BlackParrotComplex` **by name**, surelog, both modes,
baseline → fresh: `CMP_EQUAL,,,differ` → `CMP_EQUAL,,,differ`, unchanged. Neither has a
row in u2r. The four slang-fenced names (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) are dispatched by no driver here.

**GATE 5 — BYTE VERIFIER, both corpora, `SELFCHECK=1 SELFCHECK1=1`.**

```
uhdm2rtlil   PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog      PATH_SETS_IDENTICAL (953 paths)   MOVERS: 2 / 953
             SELFCHECK 952/953 flagged        SELFCHECK1 = 3 (1 corrupted + 2 movers)
```

**u2r: 0 movers — the census prediction, confirmed exactly.** The two `[{` carriers
(`asym_ram_sdp_read_wider` / `asym_ram_sdp_write_wider`) are byte-identical, as arm a3
said they must be.

### The two surelog movers, attributed

**MOVER 1 — `Earlgrey_0_1/default`: REAL, PREDICTED, fully attributed.**
28 changed dump lines, three shapes, two source occurrences (309 and 422). **Every
removed line absent from golden; every added line present in golden; ADDED and REMOVED
counted separately; 0 findings** (§5). Deterministic across run conditions:

```
pristine  21c7884247a2  in the --jobs 2 sweep AND in an isolated --jobs 1 run
patched   a5e4b8d46499  in the --jobs 2 sweep AND in an isolated --jobs 1 run
```

**MOVER 2 — `Scoreboard/default`: UNPREDICTED, and NOT attributable to this law.**

> **This is the finding the brief asked for, and the honest answer is that it is not my
> law.** Four independent proofs:
>
> 1. **It is a PURE PERMUTATION.** Same line count (1 097 053 both) and, sorted, the two
>    dumps are `cmp`-identical: *"IDENTICAL AS MULTISETS -> the change is a PURE
>    PERMUTATION, zero content delta"*. The delta is 92 lines in **2** hunks: 23
>    `svunit_pkg` `vpiTaskFunc` entries relocated within one list.
> 2. **No changed line is this law's output.** `grep -c '\[{'` over the 92 changed lines
>    = **0**. Their kinds are only `|vpiTaskFunc:` (46), `\_function:` (36), `\_task:`
>    (10) — no name string of any select.
> 3. **The shape does not occur in the test.** `Scoreboard`'s sources contain **zero**
>    concat-indexed member selects, so `concatIdxText` cannot have fired on it at all.
> 4. **THE DECISIVE MEASUREMENT: the PRISTINE, UNPATCHED binary is nondeterministic on
>    this test.** Six **byte-identical invocations**, same binary, same cwd, same
>    argument list, no sweep harness involved:
>
>    ```
>    run1: efa9bf85d1d051f8      run4: efa9bf85d1d051f8
>    run2: efa9bf85d1d051f8      run5: 4fc00091d5205811   <-- the md5 the verifier flagged
>    run3: d747b770a3f4c5ac      run6: efa9bf85d1d051f8
>    ```
>
>    **THREE distinct databases from one unpatched binary and identical inputs.** Run 5
>    reproduces *exactly* the pristine-sweep md5 that the byte verifier called a mover.
>    A patch cannot be the cause of a difference the unpatched binary produces against
>    itself.

All three variants are **pure permutations**: 1 097 053 lines each, and sorted they are
`cmp`-identical pairwise. Two distinct permutation classes were seen — the
`vpiTaskFunc` list order (run5, the flagged one) and a `uvm_pkg` typespec listing order
(`vpiTypedefAlias` / `ref_typespec` / `bit_typespec`, run3). **`uhdm-cmp` calls the
variants EQUAL** (`PASS_CMP` for 1-vs-5 and 1-vs-3), i.e. the instability is
order-only and cmp-invisible. `Scoreboard/default` is `CMP_NOTEQUAL` in both baseline
and fresh CSV and the whole-row judge reports **0 differing rows**, so nothing regressed.

> **A CORRECTION TO MY OWN FIRST WRITE-UP OF THIS FINDING, and a note on a memory that
> has since been refuted.** My first draft attributed this to the campaign memory
> *alias-population-build-dependent* ("pointer-keyed `std::map` address order shifts UVM
> alias counts"). **That memory was REFUTED by r10det1 (commit `35f3677`)**, which
> proved with seven binaries and an env-guarded heap pad that the population is *not*
> build-dependent and that address order does *not* reach the database. I must not lean
> on a discredited claim, so the attribution above rests on **nothing but my own direct
> measurement**: one unpatched binary, identical inputs, three outputs. That is a
> different and stronger claim than the refuted one, and it is consistent with r10det1 —
> r10det1 showed `BuildUVMPkg` is byte-stable *across binaries* and that the *population*
> never moves; here the population never moves either (identical multisets), only the
> LIST ORDER does, *within one binary across runs*, which r10det1 did not test on this
> test. The un-refuted *emitter-nondeterminism* memory (ordering flips per run under
> parallel parse) is the compatible one.
>
> **CONSEQUENCE FOR THE INSTRUMENT, worth more than this pass:** the byte verifier has a
> blind spot on `Scoreboard` — a single-run comparison of that test can report a
> spurious mover in either direction. Any future pass that sees `Scoreboard` move should
> re-run the **unpatched** binary several times before attributing it to a law.

**Net: exactly ONE real mover, exactly the one predicted, every changed line landing on
golden.**

## 8. RANKED RESIDUE LIST

Ranked by **cells-per-fix × reachability**, not by how close they look.

**R1 — the bracket-DROP for a non-concatenation index. 6 grid cells, 3 arms.**
Golden emits **no bracket group at all** when the index's top-level kind is a hier ref,
a single-level bit select, or a multi-level element select:
`q.autoexecprogbuf[rq.addr]` → `q.autoexecprogbuf` (a6 o3),
`[m[1][2]]` → dropped (b2 o1), `[w[2]]` → dropped (b2 o2). Highest-value residue: the
mechanism is already decoded (§3d) and the same five call sites are already touched, so
the fix is a gate widening plus a "drop the brackets when the rendering is empty" rule.
**Deliberately not shipped: it is outside this pass's assigned territory** (indices that
are not concatenations) and it would move rows the census did not scope.

**R2 — the wildcard-imported package parameter element. 2 grid cells (b3 o1).**
Golden renders the **sized literal** `2'd1`; `§ hierSelPkgParamFold`'s existing
`reducedImportedIdx` returns the **decimal** `1`. Needs the "literal keeps its own
spelling, computed goes decimal" rule of `§ crossPkgRangeBoundFold` applied one level
down inside a concatenation. Currently a clean, detected abstention.

**R3 — inner-index-object `VpiFullName` parent policy. ~8 grid cells across a1/a2/b1/b2/b3.**
A `bit_select` / `var_select` / `indexed_part_select` **inside** the index gets, in
golden, a fullname prefixed by the **enclosing bit_select's** fullname
(`work@a1_hp2.q.autoexecprogbuf[{1'b1,}].autoexecprogbuf.w`); we emit the module-scoped
`work@a1_hp2.w`. Note we **already** do the parent-prefix for `part_select` at the same
site but not for `bit_select`/`var_select` — so this is an inconsistency in our own
parent policy, matching campaign memory's *dump-fullname-synthesis* note ("naming
residues are often PARENT-POLICY bugs — check `vpiParent` before touching name code").
**Invisible to cmp** (`VpiFullName` is compared nowhere) but a real byte/dump residue.

**R4 — the `vpiConstType` 7-vs-9 law on a folded package enum literal.**
The **new Earlgrey_0_1/default head**, `dm_csrs.sv:389`. Pre-existing, now the blocker
on this row. Not in any live pass's territory. This is the next thing to look at for
this design.

**R5 — inner-index-object SPANS.** b1 reports 8 `MISSING` cells that are pure span
disagreements on the index's own sub-objects (golden `27:23-27:27` vs ours
`27:25-27:26`, i.e. golden spans `k[0]` where we span `k`). Pre-existing, unchanged by
this pass, and it borders **r10svs3's function-object SPAN policy** — flagged, not
touched.

**R6 — an indexed part select over a concatenation.** `data[{cl_offset_q,3'b0} +: 8]`
(Ariane/Ariane2024, both SLANG_REJECT today). Top-level kind is a RangeSelect, so
outside this gate. Unmeasured — no cell was built for it because no measurable row
carries it.

**R7 — `Scoreboard` per-run output instability (INSTRUMENT defect, not an emitter
correctness bug).** Three distinct byte outputs from one unpatched binary on identical
inputs, all `uhdm-cmp`-equal and all identical as multisets (§7). It costs the byte
verifier its precision on that one test. Worth fixing at the source (a stable sort key
for the `vpiTaskFunc` and `uvm_pkg` typespec listing vectors) so the verifier is exact
everywhere; until then, treat a `Scoreboard` mover as unattributed until the unpatched
binary has been re-run several times.

## 9. FILES

| file | what |
|---|---|
| `arm.sh` | arm driver; LHS golden / RHS ours, `sed 1d` both dumps, explicit input guards |
| `cells.py` | span-keyed cell extractor: hier_path names + select fullnames, both sides verbatim |
| `a1_hp2.sv` | 10 element kinds, candidate SECOND (the Earlgrey shape) |
| `a2_hp1.sv` | the same 10, candidate FIRST — kills hypothesis (d) |
| `a3_plain.sv` | plain non-hier bit_select — the "does the rule live in the select name?" control |
| `a4_ctx.sv` | five statement contexts incl. named block and LVALUE |
| `a5_three.sv` | 3-element concats: the comma policy, incl. every-element-empty |
| `a6_noconcat.sv` | **the OVER-FIRE CONTROL** — non-concat indices, must not move |
| `b1_sites.sv` | the four emitter name-building sites |
| `b2_kinds.sv` | element kinds a1 missed + the two candidate suffix models |
| `b3_edges.sv` | pkg param, indexed part select, cast, sysfunc, cross-instance, nested replication |
