# r10vbuvm22 — ADVERSARIAL VERIFICATION of r10buvm22 / § `namedBaseUnpackedTdRetVar22`

**VERDICT: ACCEPT AS SHIPPED.**  Every headline number reproduced bit-for-bit
from independently built binaries; no `pristine-right → patched-wrong` cell was
found on any legal SV the verifier could construct; no production change was
needed, so `/tmp/r10buvm22.verified.patch` = the implementer's patch **+ this
evidence directory only**.

**MEASUREMENT-ONLY.**  Nothing here is an acceptance judge; the official
`uhdm-cmp` and `scripts/verify_golden.py` are.  slang was **not** patched;
`results/*.csv` were **READ ONLY**; nothing was promoted.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours** — in every table and
every script here.

| | |
|---|---|
| BASE | `a2aa8b3` |
| verifier worktrees | `/tmp/wt_vbuvm22` (patched), `/tmp/wt_vbuvm22pris` (pristine) |
| binaries, built by the VERIFIER | pristine `d8f8bd12744497c72f2fda00b6392765`, patched `7e5f0a49e681c80d2761b2814c092469` — **both md5s identical to the pass's**, frozen `chmod 555` at `/tmp/vbuvm22_bin/{pris,pat}.bin` |
| workdirs | `/tmp/vbuvm22_wd/{pris,pat}` (both corpora, both modes, per binary) |
| every `cmds.txt` audited | surelog 1523/1523 and u2r 1458/1458 name the frozen binary of their own arm — 0 leaks to the main tree |

---

## 1. REPRODUCTION OF THE PASS'S HEADLINE NUMBERS — ALL BIT-FOR-BIT

| claim | pass | verifier | verdict |
|---|---|---|---|
| pristine binary md5 | `d8f8bd12…` | `d8f8bd12744497c72f2fda00b6392765` | HIT |
| patched binary md5 | `7e5f0a49…` | `7e5f0a49e681c80d2761b2814c092469` | HIT |
| pristine `BuildUVMPkg` cmp (`2>&1`), both modes | 52 lines, 1 head, md5 `f21a1042bba06220ee5c1e4f49ff24f4` | identical, both modes | HIT |
| patched `BuildUVMPkg` cmp (`2>&1`), both modes | 166 lines, 1 head, md5 `b0d8ba9e85acfcdb4650c0743e17352e` | identical, both modes | HIT |
| return-var census, `BuildUVMPkg` | 4 768 joined, KIND same 4902 diff 4 → 4903 diff 3 | reproduced exactly with the pass's own `cen22.sh` | HIT |
| surelog sweep | 936 EQ / 20 NE / … | 936 / 20 / 10 DEFERRED / 3 NO_DATABASE / 1 NO_UHDM / 567 SLANG_REJECT / 48 SURELOG_FAIL / 1 TIMEOUT / 2 UNTRANSLATABLE, patched == pristine | HIT |
| u2r sweep | 679 / 50 / 2 both modes | identical both modes, both binaries | HIT |
| byteverify surelog | MOVERS 9/956, the predicted set | MOVERS 9/956, **the same nine by name** | HIT |
| byteverify u2r | MOVERS 0/1358 | MOVERS 0/1358, PATH_SETS_IDENTICAL | HIT |
| rowheads | only `BuildUVMPkg` 52→166 | SeqDriver/SimpleUVM/Scoreboard/MiniAmiq 17, Earlgrey 46, Rggen 64 **unchanged**; BuildUVMPkg 52→166 | HIT |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, three byte-identical | all five SAME, both pins hit | HIT |

### The gates, re-run by the verifier

1. **Builds** — both configured and built from scratch, `-j 2`, 0 errors, md5s above.
2. **Goldens** — patched `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23`.
3. **`uhdm2rtlil`** — 679/50/2 in BOTH modes; `ct8rows` **0 differing rows** vs the committed `results/gate_uhdm2rtlil.csv` and vs the verifier's own pristine sweep, status AND dump, both modes.
4. **`surelog --mode both`** — `ct8rows` **0 differing ROWS over 1588** vs the committed `results/golden_surelog.csv` and vs the verifier's own pristine sweep, status AND dump.  **NO ROW CONVERTED.**
5. **byteverify** — u2r `MOVERS 0/1358`; surelog `MOVERS 9/956`, every one attributed below.
6. **Canaries** — `ok=52 changed=0` (surelog), `ok=8 changed=0` (u2r); `ctcan2` PASS ×2; `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`.

### The nine movers, attributed ORDER-BLIND (`vattrib22.sh`)

Both dumps sorted, ids stripped, workdir normalised — the only read allowed on
`Scoreboard/default`, which is a ~50/50 coin (RESUME §9).

| DB (both modes unless noted) | changed lines | content |
|---|---|---|
| `BuildUVMPkg` | 4 | `logic_var → ref_var` on `uvm_pkg::uvm_report_message_element_container::get_elements` @28181:20 |
| `MiniAmiq`, `SeqDriver`, `SimpleUVM`, `Scoreboard` (default only) | 8 each | the same object @338:20 **and** `uvm_pkg::uvm_utils::find_all` @649:19 |

**Zero collateral lines** — no `vpiActual`, no typespec, no location, no other
object on any of the nine.  Independently confirmed.

### The four CMP_EQUAL rows of the same family are unmoved, byte-for-byte

`ArrayExprFuncArg`, `DefaultPatternInt`, `DefaultPatternModule`, `FuncRetArray`
(`typedef int unsigned ASSIGN_VADDR_RET_T[2]`, a KEYWORD base) — md5 SAME on
both binaries in both modes, status still `CMP_EQUAL`.  The pass's
"safe by construction" claim is measured, not assumed: `makeReturnVar` already
answered `array_var` for a `FixedSizeUnpackedArrayType`, and the predicate
answers `ArrayVar` for a keyword base, so the object is re-emitted identically.

---

## 2. THE HEAD AND THE LAW, RE-DECODED FROM SOURCE BY THE VERIFIER

**The head** (read off the verifier's own pristine cmp log, not carried
forward): both sides are objects and both are `variables`, the `ref_typespec →
array_typespec (queue_of_element)` payload is identical on both sides, so
`BaseClass::Compare`'s **VpiType** test is the failing field.  Confirmed.

**The Surelog decode** was re-read at the named line numbers and is correct:

* `CompileType.cpp:78-233` `getSimpleVarFromTypespec` — `uhdmarray_typespec`
  with **no** `Index_typespec` → `s.MakeArray_var()` with a ref to a FRESH
  `array_typespec`;
* `CompileType.cpp:337-431` `slStringConst` arm — `var->Typespec()->Actual_typespec(ts)`
  immediately overwrites that fresh typespec with the declaration's real one
  (which is why our array_var's payload matches), and the tail is
  `s.MakeRef_var()` with the declaration typespec and `component->needLateTypedefBinding`
  ONLY for an `unsupported_typespec` — so an ARRAY typespec's `ref_var` is
  never redeemed.  Both halves of the law's mechanism verified.
* `ref_var::Compare` reads VpiDefName / VpiGeneric / **Actual_group** / Task_func /
  VpiStructMember, none of which either side sets here; `array_var::Compare`
  reads **VpiArrayType** / Var_selects / Ranges / Left_expr / Right_expr /
  Variables, and golden's return `array_var` sets none of them.  So both new
  object classes are Compare-complete as emitted.

---

## 3. BREAKING THE LAW — SIX PURPOSE-BUILT GRIDS, BOTH VIEWS, VIEW-GENERAL SCORING

`vgrid22.sh` builds each grid with Surelog (`-parse` and `-parse -elabuhdm`) and
with BOTH binaries (default and `--elabuhdm`), censuses all six databases with
the pass's `r10buvm22cen`, and `vcmp22.py` scores every
`(VIEW, function fullname, SITE, return-var line:col)` **slot as a MULTISET**
with payload `(object kind, typespec shape, typespec name)` — deliberately NOT
the pass's `(short name, view)` **last-writer dict**, which drops colliding rows
(RESUME §9's census trap).

| grid | axis | CONVERTED | **MSW-REGRESSION** | still-wrong | same | scored |
|---|---|---|---|---|---|---|
| `v1_homes.sv` | homes × container flavour × written base (package / package class / `$unit` class / `$unit` level / module / module class) | 129 | **0** | 20 | 35 | 184 |
| `v2_rettypes.sv` | every return type the brief names (int/byte/string/real/packed/struct/union/enum/class/parameterized class/type param/typedef-of-typedef/alias-of-array/void/task-with-output) | 59 | **0** | 8 | 68 | 135 |
| `v3_kinds.sv` | in-body / OOB `extern` / static / virtual / derived override / pure virtual in an interface class / nested class / class in an interface / class in a program / 3 interface instances | 28 | **0** | 24 | 30 | 82 |
| `v4_adversary.sv` | **the danger family**: FIXED-SIZE and 2-D unpacked typedefs (where pristine already answered `array_var`) × named/keyword base × package/class/module scope × scoped spelling × inheritance | 70 | **0** | 4 | 45 | 119 |
| `v5_exotic.sv` | generate-block typedef, wildcard assoc `[*]`, importers ABSENT (fully scoped), task with output arg, three module instances | 34 | **0** | 4 | 20 | 58 |
| `v6_nasty.sv` | array-typedef-of-array-typedef, dyn-of-queue-of-class, struct containing a queue, 3-D fixed, parameterised class with `T q[$]` / `T f[N]` / `T f[N][N]`, self-referential `typedef D dq_t[$]` | 37 | **0** | 8 | 26 | 71 |
| the pass's own `g22.sv` / `g22b.sv`, re-scored view-generally | — | 87 / 51 | **0** / **0** | 46 / 4 | 116 / 22 | 249 / 77 |
| `r10buvm15repro/a2_collbuiltin15.sv`, `r10uvm69repro/a1_type.sv` (the boundary movers) | — | 9 / 30 | **0** / **0** | 5 / 5 | 18 / 78 | 32 / 113 |

**MSW-REGRESSION 0 in every grid, in both views, on both the kind-only and the
full Compare-visible payload.**  That is the verdict-bearing number and it holds
under the stricter keying.

### The clause the brief demanded be attacked, and how it survived

The one place the law can turn a RIGHT answer into a WRONG one is the
FIXED-SIZE unpacked typedef, because `makeReturnVar` already answered it
`array_var` (`ct.kind == FixedSizeUnpackedArrayType`) — so any cell where the
predicate says `RefVar` is a candidate regression.  `g22.sv` contains no
fixed-size **named-NON-class** package typedef at all, so `v4_adversary.sv` was
written for exactly that cell.  Golden's answer, measured:

| cell | DEFPKG | ELABPKG / TOPMOD / DEFMOD | pristine | patched |
|---|---|---|---|---|
| `typedef ti4_t pf_tdint4[4]` (package, named non-class) | `ref_var` | `array_var` | `array_var` everywhere | `ref_var` / `array_var` — **matches golden in every view** |
| `typedef ti4_t p2d_tdint4[2][3]` | `ref_var` | `array_var` | `array_var` | matches |
| `typedef p4::ti4_t psc_f_tdint4[4]` (SCOPED base) | `ref_var` | `array_var` | `array_var` | matches |
| `typedef base4 pf_cls4[4]` (package, class base) | `ref_var` | `ref_var` | `array_var` | matches |
| `typedef ti4_t cf_tdint4[4]`, `c2d_tdint4[2][3]`, `cf_cls4[4]` (CLASS scope) | `ref_var` | `ref_var` | `array_var` | matches |
| `typedef int cf_int4[4]` (keyword base) | `array_var` | `array_var` | `array_var` | unmoved |

The `defPkgListing` gate (`curPkgEmitSym && !pkgEmitTopView`) reproduces
golden's DEF-vs-elaborated split exactly, in the NON-elaborated database as well
as the elaborated one, for every named-non-class base tested.

---

## 4. THE WIDE BOUNDARY — PER-FILE **AND** PER-DIRECTORY, `.sv` **AND** `.v`

Run from a COPY of `tools/probe`, list on fd 3, children `</dev/null`,
`PROCESSED` asserted, scratch keyed on the RELATIVE path, rc recorded per cell,
uhdm-dump banner normalised (`vbound22.sh`).  The pass's own `bound22.sh` globs
`*.sv` only and never compiles a directory as one unit; both gaps are closed here.

```
PER-FILE : PROCESSED=3066 LISTED=3066 DIFFER=8 PRIS_REJECT=128 PATCHED_REJECT=128   (no asym.txt)
PER-DIR  : PROCESSED=1504 LISTED=1504 DIFFER=6 PRIS_REJECT=116 PATCHED_REJECT=116   (no asym.txt)
```

Per-file, the eight are **six positive controls** (the pass's `g22`/`g22b` and
the verifier's `v1`–`v4`, which prove the gate can see a moved cell) and **two
real arms**:

* `r10buvm15repro/a2_collbuiltin15.sv` — `typedef int iq15[$]` returned by
  `q15p::pkgq15`, `qcls15::mkq15`, `qcls15::smkq15`: 16 lines, all
  `logic_var → array_var`.  Re-run against Surelog by the verifier: golden is
  `array_var` for all three, in all listings — **9 CONVERTED, MSW 0**.  Every
  `vpiActual` and every body local byte-identical, so
  § `collArgNamedBlkLocalNoBind15`'s window is untouched.
* `r10uvm69repro/a1_type.sv` — six `p1::f_*` returning `qT[$]` / `dT[]` /
  `aT[string]`: 48 lines, all `logic_var → array_var`, golden-correct
  (**30 CONVERTED, MSW 0**), nothing else.

Per-directory, four of the six are the same arms plus the two grid dirs.  The
two NEW names — `r10uvm75repro`, `r10uvm76repro` — are **NOT movers**: their
diff is a reordering of one `vpiTaskFunc` list, the **order-blind diff is 0
lines**, and the PRISTINE binary alone produces three different dumps in three
consecutive runs of that same directory.  They are the known parallel-parse coin
(RESUME §9), not this patch.

**Every bind-window law the brief names is therefore proved untouched by
construction**: their arms (`r10sd10repro` 68, `r10sd12repro` 108,
`r10buvm13repro` 10, `r10buvm15repro` 9, `r10uvm81repro` 14, `r10uvm88repro` 9,
`r10uvm90repro` 3, `r10uvm28repro` 5, `r10earl57repro` 4, `r10earl64repro` 3 …)
are all inside the 3 066 per-file and 1 504 per-directory cells, and the only
lines that moved anywhere in the tree are function RETURN VARIABLE object kinds.
§ `typeParamRetIsRefVar58` and § `aliasClassRefVar10` were checked cell-by-cell
in `v2` (`r_typaram`, `r_typaramq`, `r_tdcls`, `r_tdparm` — `ref_var` on all
three of golden/pristine/patched, unmoved).

---

## 5. THE OWNER-KEYED CENSUS ON THE REAL TARGET

`vcen3.py` joins golden / pristine / patched on the same slot key as §3 and
scores TO-GOLDEN / AWAY-GOLDEN / STILL per slot, with the Compare-visible
payload.  On `BuildUVMPkg/default` (the row this pass targets):

```
kind only     : TO-GOLDEN 1  AWAY-GOLDEN 0  STILL-WRONG 409  STILL-RIGHT 3455
kind + ts     : TO-GOLDEN 1  AWAY-GOLDEN 0  STILL-WRONG 538  STILL-RIGHT 3326
```

Exactly ONE slot moved, TO-GOLDEN, with the typespec payload identical on both
sides (`array_typespec … tsname=queue_of_element`).  **AWAY-GOLDEN 0.**
(The `STILL-WRONG` bulk is pre-existing copy-count and location disagreement,
identical on both binaries.)

---

## 6. CORRECTIONS TO THE PASS'S WRITE-UP (none affect the verdict)

1. **R0's failing FIELD is `Path_elems`, not `VpiName`.**  `hier_path::Compare`
   (UHDM generated) compares `Path_elems` **first**, then `Root_value`, then
   `VpiName`; the vector `SafeCompare` overload sets BOTH containers as the
   failed objects on a size mismatch, which is why the log names the two
   `hier_path`s.  `expr::Compare` (VpiDecompile / VpiSize / Typespec) passes
   because neither side sets any of them.  The substance — 2 golden elements
   against our 3, from splitting on the dot inside the subscript — is right, and
   so is the remedy; only the field name in the write-up is wrong.  Recorded
   because RESUME §9 forbids carrying a wrong framing forward.
2. **The grid totals are keying-dependent.**  The pass's `gridcmp22.sh` keys a
   cell on `(short function name, view)` in a **last-writer dict**, so slots that
   collide (the same function reached from several elaborated roots) are
   silently collapsed.  Re-scored view-generally as a multiset over
   `(view, fullname, site, retvar loc)`, `g22`+`g22b` are
   **CONVERTED 138 / MSW 0 / still-wrong 50 / same 138 over 326 slots**, not
   `151 / 0 / 21 / 139 over 311`.  MSW-REGRESSION 0 — the number the verdict
   rests on — is identical under both keyings.
3. Cosmetic: the `EmitHelpers.h` law comment says "190 grid cells" where the
   README says 311; `build22.sh`'s header names itself `build21.sh`.

---

## 7. RANKED RESIDUES THE VERIFIER FOUND (all pre-existing-wrong → differently-wrong; NONE is a regression)

* **R-V1 — INHERITED class typedefs.**  A DERIVED class's method returning a
  typedef declared in its BASE class is a `ref_var` in golden **whatever the
  base type**, because Surelog's `component->getDataType(name)` is
  component-local and never sees the inherited typedef.  Measured:
  `v3` `p3::d3::vb_int` and `v4` `p4::cd4::di_int` (`typedef int t[$]` inherited)
  — golden `ref_var`, pristine `logic_var`, patched `array_var`; and
  `p4::cd4::di_fint` (`typedef int t[4]` inherited) — golden `ref_var`, both
  `array_var`.  The law's "keyword base ⇒ `array_var`" clause is refuted by
  inheritance.  **Corpus reach measured: zero** (the only keyword-base cells in
  either corpus are module-level, not class-inherited), which is why no gate
  moves.  Fix direction: answer `RefVar` when the typedef's declaring class is
  not the function's own class chain.  ~6 grid cells.
* **R-V2 — the SCOPED-written package typedef of a CLASS array is `class_var`.**
  `v1` `work@top1.mf_pk_cls` and `v5` `work@noimp5.f_ni_cls` /
  `noimp5::nic5::m_ni_cls`: a module function writing `p::pq_cls_t` in full gets
  a golden `class_var` (Surelog reaches the `class_typespec` the `:906`
  exclusion left on the package typedef — the pass's own R3), where the law
  gives `ref_var`.  Pristine gave `logic_var`, so this is wrong→wrong.
  ~6 grid cells, zero corpus reach.
* **R-V3 — a typedef whose written base is ITSELF an array typedef.**
  `v6` `pn::f3` (`typedef bq_t bqq_t[];` over `typedef B bq_t[$];`): golden
  `ref_var` in EVERY listing, i.e. the package "eager" arm does NOT redeem it,
  contradicting the law's "named non-class base in a package ⇒ `array_var` when
  elaborated".  ~4 grid cells, zero corpus reach.
* **R-V4 — the OUT-OF-BODY exclusion is over-broad for a KEYWORD base.**
  `r10buvm15repro/a2_collbuiltin15.sv` `qcls15::oobq15` (`extern function iq15`,
  `typedef int iq15[$]`, definition written with a BARE return type) is golden
  `array_var` in every listing, and clause (0) refuses it, leaving `logic_var`.
  The pass's R2 (`class_var` for OOB) is measured on SCOPED return spellings
  (`c3::q_int3` in `v3`) and does not cover the bare one.  A missed conversion,
  never a regression.
* **R-V5 — the pass's own R1 (`typedef <named> t;` with NO dimensions)** is
  reproduced: `v2` `p2::pf2_alias` / `p2::c2::r_alias_q` (`typedef q_int2 alias_q2;`)
  golden `array_var`, both binaries `logic_var`.
* **R-V6 — the two pre-existing `BuildUVMPkg` kind disagreements** the pass
  reports as R4 (`uvm_sequencer_base::get_arbitration`,
  `uvm_printer::object_printed`) are present on BOTH binaries: confirmed.

---

## 8. THE INSTRUMENTS IN THIS DIRECTORY

```bash
bash vgrid22.sh <grid.sv> <pristine> <patched> <workdir> [<census bin>]   # 6 DBs, both views
python3 vcmp22.py <workdir>/cen.tsv [--kindonly]                          # VIEW-GENERAL 3-way multiset scorer
python3 vcen3.py <golden.tsv> <pris.tsv> <pat.tsv> [--kindonly]           # owner-keyed TO-GOLDEN / AWAY / STILL
bash vattrib22.sh <pris wd> <pat wd> <rel path>                           # ORDER-BLIND mover attribution
PRISTINE=… PATCHED=… ROOT=<copy of tools/probe> OUT=… MODE=file|dir bash vbound22.sh
```

Grids: `v1_homes.sv`, `v2_rettypes.sv`, `v3_kinds.sv`, `v4_adversary.sv`,
`v5_exotic.sv`, `v6_nasty.sv`.
