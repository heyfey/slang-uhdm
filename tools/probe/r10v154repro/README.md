# r10v154 — ADVERSARIAL VERIFICATION of r10uvm154 (§ `enumWrittenNegDecLit154`)

**VERDICT: ACCEPT WITH FIX.**

Every headline number in the implementer's report reproduces bit-for-bit in
fresh worktrees at BASE `258e615`, including both binary md5s. The law is
correct, the decoded Surelog mechanism is correct, and the head clears as
claimed. **One break was found on legal SystemVerilog and fixed here**: the
shipped first cut spelled the enum-constant `vpiDecompile` from `pkgTopEmit`
alone, which turned **7 pristine-RIGHT cells WRONG** in a `$unit`-scope enum.

---

## 1. REPRODUCTION — every headline number, measured independently

Fresh worktrees `/tmp/wt_v154` + `/tmp/wt_v154pris` at `258e615`, both binaries
built here at `-j 2`, md5'd separately, frozen `chmod 555` before any sweep,
`SLANG_UHDM` exported explicitly per binary and **every `cmds.txt` audited by
binary PATH**.

| claim | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `18aa89a5…` | **`18aa89a57254ce22ce8839296a248013`** — identical |
| patched binary md5 | `5307130b…` | **`5307130b930c286cef5f106147db85b2`** — identical |
| `check_goldens.sh` | 23 / 0 | **PASS 23 FAIL 0** (pristine also 23/0) |
| `SLANG_UHDM=/bin/false` | 0 / 23 | **PASS 0 FAIL 23** |
| surelog rows, both modes | 0 differing over 1588 | **0 differing ROWS (0 row-sides)** vs `results/golden_surelog.csv` AND vs this worktree's pristine; histograms identical |
| uhdm2rtlil | 0 differing, 679/50/2 | **0 differing**, **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, both modes |
| `cmds.txt` audit | 2981 each, no crossover | **2981 `/tmp/v154_bin/pris`, 2981 `/tmp/v154_bin/pat`, 0 crossover** (3035 files, the rest are SURELOG_FAIL rows with no slang command) |
| byteverify surelog | 9 / 956 | **9 / 956**, selfcheck **955/956** |
| byteverify uhdm2rtlil | 0 / 1358 | **0 / 1358**, selfcheck **1357/1358** |
| the mover set PREDICTED BY NAME | 9 named | **independently predicted**: `ct154cen` over all 956 pristine databases names the 9 that hold a `UVM_CVR_ALL` enum_const (2 cells each = the 18 census cells) — `default {BuildUVMPkg, MiniAmiq, Scoreboard, SeqDriver, SimpleUVM}` + `testflags {BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM}` — **the prediction is exactly the mover set** |
| mover attribution, ORDER-BLIND | 4 or 6 lines, non-payload 0 | **46 order-blind lines over 9 databases, 4 or 6 each, `NON-PAYLOAD=0`** — every line `\|INT:` or `\|vpiDecompile:`, `4294967295 → -1` |
| census surelog | SAME 25072→25090, WRONG 34→16, ONLY-GOLDEN 6953, ONLY-OURS 205 | **exactly those five numbers** |
| census uhdm2rtlil | WRONG 0 before and after | **WRONG 0 / SAME 8213 both**; the two TSVs are **content-identical (sorted diff 0)**, not byte-identical — `ct154cen`'s ROW ORDER is not stable across processes (12 ordering-only lines on three `builtin.sv` `state` cells whose databases have the same md5). The multiset join is order-blind, so no verdict moves. |
| canaries | ok=52 / ok=8, changed=0 | **ok=52 changed=0** / **ok=8 changed=0** |
| `ctcan2` both | PASS | **PASS / PASS** |
| `canaudit` | audited=29 UNCOVERED=0 FENCE-BREACH=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, re-run from THIS directory |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **both exact**; InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical, both modes |
| heads | SimpleUVM ×2 36→60 on a NEW object, all others byte-identical | **exact**; and the new head object is byte-for-byte the object `SeqDriver ×2` heads on (`class_var: (uvm_pkg::clp)` @801:27-801:66, parent `\_package: uvm_pkg`) — only the serializer `id:` differs |
| wide boundary | `LISTED=4300 PROCESSED=4300 MOVED=26 TAILONLY=4 BREACH=0 RC-MISMATCH=0` | **identical, re-run on the FIXED binary**; and `LISTED=4305 PROCESSED=4305 MOVED=36 TAILONLY=4 BREACH=0 RC-MISMATCH=0` with this verifier's five arms added — **BOUNDARY PASS** both ways |
| `goldscore154.sh` | better=11 equal=0 worse=0 | **better=11 equal=0 worse=0**, every one of the 11 distances identical to the implementer's table; **better=16 equal=0 worse=0** over all 16 moved arms including this verifier's |
| the deliverable itself | — | the verified patch applied to a **completely fresh `258e615` worktree** and built independently produces the identical gated md5 **`a67a9b495cc896b727765534dbb65580`** |

The four slang-fenced tests were never dispatched and are not spelled here.
`results/*.csv` were not edited by the patch or by this verification.

---

## 2. THE BREAK — § `enumWrittenNegDecLit154`'s decompile in a `$unit` home

### What the grid did

561 generated arms, run against Surelog and BOTH binaries, scored cell by cell:

* **value FACES** (24): `-1`, `-7`, `-2147483648`, a 33-bit `-4294967296`, an
  18-digit and a 19-digit magnitude (the gate's own edge), `-0`, **`-007`
  (leading zeros)**, `-1_0` (digit separator), `-(1)`, `- 1`, `-(-2)`, `-'d1`,
  `-32'd3`, `-32'sd3`, `32'hFFFF_FFFF`, `'hFFFFFFFF`, `1-2`, `-1-1`, `~0`, a
  local parameter, a package parameter, `int'(-1)`, `signed'(-1)`;
* **BASES** (12): none, `int`, `integer`, `bit [31:0]`, `logic [7:0]`, `byte`,
  `shortint`, `longint`, `int unsigned`, `bit unsigned`, a typedef'd base, and
  a base NARROWER than the value;
* **HOMES** (6): package, `$unit`, module, class, **parameterized class**,
  interface; **1 / 2 / 3 instances**; DEF and ELAB views under one key;
* **must-stay**: the enum as a parameter value, a case selector, a port default
  and an array index; `uvm_tlm_response_status_e`'s five written negatives; the
  based / binary / hex / octal / unbased-unsized / concat / reference / shift /
  cast encodings other passes own; the implicit-successor chain on six bases;
  overflow of the base width.

Names are deliberately varied (never `a_t`/`b_t`/`c_t` over `A`/`B`/`C`), the
key is `(owner, name, span)` with BOTH views kept as a multiset, and the payload
is the three fields `enum_const::Compare` reads beyond `VpiName`.

### What it found

```
                       SHIPPED FIRST CUT      AFTER THE FIX
   AWAY-GOLDEN                 7                    0
   MOVED-WRONG                26                   25
   TO-GOLDEN                 163                  164
   still-right              2966                 2973
   still-wrong               249                  249
   COUNT-MOVED                 0                    0     (the law mints nothing)
   rc parity                561/561              561/561  (0 mismatches, 0 segfaults)
```

All **7 AWAY-GOLDEN cells were the same shape**: a `$unit`-scope enum whose
written negation is `-0` or has **leading zeros**.

```
   $unit   UZ_ZERO = -0     golden INT:0  / `0`  / 64
                            pristine       `0`   RIGHT
                            first cut      `-0`  WRONG
   $unit   UZ_LEAD = -007   golden INT:-7 / `-7` / 64
                            pristine       `-7`  RIGHT
                            first cut      `-007` WRONG
```

### Why

`-0` and leading zeros are the only two written faces where the raw digits are
not the canonical spelling of the value, so they are the only faces that can see
the def/elab discriminator at all. The first cut used `pkgTopEmit`, the *package
top view* flag, which is FALSE for a `$unit` enum — so `$unit` got the DEF
spelling.

Measured over all six homes × both faces × four bases, golden's rule is:

| home | listings | decompile |
|---|---|---|
| package | 2 | DEF `-0` / `-007`, then ELAB `0` / `-7` |
| **`$unit`** | **1** | **FOLDED `0` / `-7`** |
| module / class / parameterized class / interface | 1 | WRITTEN `-0` / `-007` |

That is § `unitArith`'s own rule, already written above this loop: *the
compilation unit is compiled before any module and is elaborated LIKE A TOP
PACKAGE*, so its single listing IS the top one. `unitEnum9` was already computed
there for exactly this reason.

### The fix

```c
-   ec->VpiDecompile(pkgTopEmit ? d4 : ("-" + dg4));
+   ec->VpiDecompile((pkgTopEmit || unitEnum9) ? d4 : ("-" + dg4));
```

One token, inside the law's own block, no new state, and the field ORDER the
implementer's serialization note depends on (decompile, size, value) is
untouched. Re-running the whole battery on the fixed binary: **AWAY-GOLDEN 7 →
0, TO-GOLDEN 163 → 164, still-right 2966 → 2973**, and every gate in §1 stays
green. A comment-only re-edit afterwards rebuilt to the **identical md5
`a67a9b495cc896b727765534dbb65580`**, so the gate evidence holds for the shipped
source.

**The arms convict the first cut, and the controls do not move.** Scored against
Surelog end to end:

```
  arm                            pristine -> FIRST CUT      pristine -> FIX
  v154_a_unitspell.sv                4 -> 4  (EQUAL)            4 -> 0
  v154_d_threehomes.sv              26 -> 4                    26 -> 0
  v154_b_homespell.sv               54 -> 12                   54 -> 12   (control)
  v154_e_importclone.sv             29 -> 2                    29 -> 2    (control)
  v154_c_muststay.sv               141 -> 119                 141 -> 119  (control)
```

Two arms reach **zero lines from golden** under the fix and stall under the
first cut; the three controls are identical either way. The fix is not a trade.

### Corpus impact of the fix: exactly one coin

`byteverify` fixed-vs-first-cut over the 956 surelog databases reports **1
mover, `Scoreboard/default`** — and its ORDER-BLIND dump diff is **0 lines**
(the raw diff is the known ~92-line `svunit_pkg` `vpiTaskFunc` coin, RESUME.md
§9). Order-blind against PRISTINE it is **6 lines, all `\|INT:` /
`\|vpiDecompile:`**. No corpus source has a `$unit` enum with `-0` or leading
zeros, so the fix is corpus-neutral and purely a correctness repair.

---

## 3. THE ARMS (must-stay for every later pass on this surface)

| arm | what it pins |
|---|---|
| `v154_a_unitspell.sv` | **THE BREAK.** `$unit` × {`-0`, `-007`, a plain `-9`, `-1_0`} × four bases. Scores `AWAY-GOLDEN=2` on the first cut and `0` on the shipped code. The `-9` cell is the face that CANNOT see the bug (raw == folded) — it is there so the arm cannot be mistaken for a self-confirming one. |
| `v154_b_homespell.sv` | **THE OVER-FIRE CONTROL.** package (two listings), module, class, parameterized class and interface, each with `-0` and `-007`. Identical score on the first cut and the fix (`TO-GOLDEN=8 still-right=13`): the fix did not turn "always fold" on. |
| `v154_c_muststay.sv` | every enum-constant precedent's encoding (based / bin / hex / oct / unbased-unsized / concat / reference / shift / cast), `uvm_tlm_response_status_e`'s five written negatives, the implicit-successor chain, and the enum used as a **parameter value, case selector, port default and array index**. Identical score on the first cut and the fix (`TO-GOLDEN=2 still-right=21 still-wrong=8`). |
| `v154_d_threehomes.sv` | **THE SHARPEST STATEMENT OF THE RULE — one file, one Surelog run, all three listing kinds.** `$unit` (one listing, FOLDED `0`/`-7`), package (two listings, `-0` then `0`, `-007` then `-7`), module (one listing, WRITTEN `-0`/`-007`). First cut `AWAY-GOLDEN=2 TO-GOLDEN=4 still-right=9`; fix `AWAY-GOLDEN=0 TO-GOLDEN=4 still-right=11`, with the package and module rows byte-identical either way — which is what makes it a fix rather than a trade. |
| `v154_e_importclone.sv` | an **import-listing clone** of a package enum carrying `-0`, leading zeros and a plain negative. Identical on the first cut and the fix (`TO-GOLDEN=3 still-right=6`): `unitEnum9` did not leak into the clone road. |

**Why the implementer's own `$unit` arm could not see this.**
`g154_c_home.sv` writes `UNIT_ALL = -1` — the one face where the written digits
ARE the canonical spelling, so raw and folded agree and the discriminator is
invisible. RESUME.md §9: *an arm AGREEING with golden is not an arm TESTING the
law*. `-0` and leading zeros are the only two faces that test it.

`vrun154.sh` runs one arm against Surelog and all three binaries;
`vcells154.py` extracts the cell set; `vscore154.py` scores one arm against
golden; `vgen154_faces.py` / `vgen154_homes.py` / `vgen154_succ.py` regenerate
the 561-arm grid.

---

## 4. FINDINGS THAT ARE NOT BREAKS

1. **`-1_0` (digit separator) — 25 MOVED-WRONG cells, no field regresses.**
   Golden's DEF value is `INT:-1` while its decompile is `-10` and its
   elaborated value is `INT:-10`: `ExprBuilder::evalExpr` stops at the `_` in
   the def view. The law gives `INT:-10` / `-10` in both views, which fixes the
   decompile and the elaborated value and leaves the def value wrong.
   **Corpus incidence 0.** Recorded as R5 in the implementer's README §6.

2. **The `l154_noenum.sv` tail constant is NOT judge-invisible.** The
   implementer's README §7 called it so; the official `uhdm-cmp` on the two
   databases reports a head (`constant` under an `operation` at 11:28).
   `uhdm-dump` prints the object below `\_weaklyReferenced:`, but the judge
   still walks it. What IS true is the thing that matters: **all three binaries
   are equidistant from golden on that source (17 cmp lines each)** — golden
   emits a `string_typespec` for the `[string]` index where we emit an
   `operation` over a garbage-valued constant. The value is run-STABLE per
   binary (3 runs identical) and differs across binaries (a third, unrelated
   build gives `UINT:0`), i.e. binary-layout-derived and fully pre-existing.
   Corrected in place in the implementer's README §7.

3. **`ct154cen`'s row order is not stable across processes.** The u2r census
   TSVs are content-identical (sorted diff 0) but not byte-identical (12
   ordering-only lines) even though the databases have the same md5. Any future
   census claim on this instrument must say "sorted".

---

## 5. RANKED RESIDUES

1. **R2 — `uvm_recursion_policy_enum`, 12 cells**, the largest remaining
   `enum_const` payload population in either corpus: `1 << 16/17/18` under a
   `bit` typedef base, golden `UINT:65536` / `1 << 16` / **size 80** (the shift
   WIDENS Surelog's evaluator: 64 + the shift amount) vs our `INT:…` /
   `1<<16` / 64. Three sub-facts: the `UINT:` prefix, the widened size, and the
   prettyPrint spacing around `<<`. Confirmed present in this verifier's own
   census of the fixed binary.
2. **R3 — `WidthMultiple`, 4 cells**: golden `INT:2`, ours `UINT:2`, same
   decompile and size. An encoding-PREFIX cell in § `enumSubstIntConst30`'s
   family.
3. **R5 — the `-1_0` def value** (finding 1 above), corpus incidence 0.
4. **The associative-array typedef `[string]`** (finding 2 above): we emit an
   `operation` over a layout-derived constant where golden emits a
   `string_typespec`. Judge-visible, equidistant, pre-existing, corpus-
   invisible; a different law entirely.
5. **`logic [7:0]` with a negative member is a slang width error**
   (`SLANG_REJECT`, out of scope by decision), as is any `bit`-family base whose
   implicit successor would overflow. 79 of the 561 grid arms are such rejects,
   **rc-identical on all three binaries** — the patch rejects nothing pristine
   accepted.

---

## 6. R0 — unchanged by this verification

**SeqDriver ×2 and SimpleUVM ×2 now share one head**: `class_var:
(uvm_pkg::clp)` @801:27, 60 cmp lines, one `^LHS:`. MiniAmiq ×2 106,
Scoreboard/default 163, BuildUVMPkg ×2 45, Earlgrey_0_1 ×2 112.
