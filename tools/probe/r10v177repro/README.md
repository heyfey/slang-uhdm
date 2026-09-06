# r10v177 — the ADVERSARIAL VERIFICATION of r10uvm177 (§ `ownNamedAliasRetIsRefVar177`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of r10uvm177 reproduces
bit-for-bit from an independent build. The law is real and the head clears. But
the predicate, as submitted, moves cells **AWAY** from golden on legal
SystemVerilog that r10uvm177's arms never spell: a typedef whose NAME is also
reachable through an `import`. Seven such golden cells are measured here. The
shipped patch is `/tmp/r10uvm177.verified.patch` — r10uvm177's two production
edits unchanged plus one new term, § `ownNamedAliasNameIsNotShadowing177v`.

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities. slang was **NOT** patched; `results/*.csv` were **READ
ONLY**; **no row was converted**; `GOLDEN_DEFER` was never set.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, everywhere below.

| | |
|---|---|
| BASE | `0ae0ad69` |
| worktrees | `/tmp/wt_v177` (patched, then fixed) and `/tmp/wt_v177pris` (clean), both fresh |
| pristine binary | md5 `a70f55847d13f3bb67224e7c5049ba18` — **the implementer's number, reproduced exactly** |
| submitted patched binary | md5 `447ba723ecfb17bbd37505068bce7ce0` — **likewise reproduced exactly** |
| verified binary | md5 `676dac3fd2c178d9128825b0d0201ee4` |
| production surface | `src/EmitHelpers.h`, `src/TaskFuncEmit.cpp` — unchanged from r10uvm177 except the one added term |
| probe surface | `tools/probe/r10v177repro/` only |

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Built both binaries from scratch in my own worktrees, froze them `chmod 555`,
exported `SLANG_UHDM` per binary and audited every `cmds.txt` by binary path.

| r10uvm177 claimed | I measured |
|---|---|
| pristine md5 `a70f5584…`, patched `447ba723…` | **identical** |
| goldens 23 PASS / 0 FAIL on both, `/bin/false` 0 / 23 | identical |
| uhdm2rtlil 679 / 50 / 2 both modes, `ct8rows` 0 differing rows | identical, vs the committed baseline **and** my own pristine control, status and dump |
| surelog **0 differing rows over 1588**, no row converted | identical |
| byteverify 9 / 956 and 0 / 1358, `SELFCHECK=1` | identical — **the same nine databases** |
| every mover is `enum_var → ref_var` at `uvm_sequencer_base::get_arbitration` | identical, order-blind |
| raw vs order-blind: Scoreboard/default 82 → 4, SeqDriver/default 44 → 4, the rest 4 → 4 | identical |
| SimpleUVM ×2 **52 → 29**; every other row's head byte-unchanged | identical |
| canaries `ok=52 changed=0` / `ok=8 changed=0`; ctcan2 ×2 PASS; canaudit `UNCOVERED=0 FENCE-BREACH=0` | identical |
| five protected DBs byte-identical, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | identical |
| boundary `PROCESSED == LISTED`, `RC_DIFFS=0`, 21 moved arms | `LISTED=4877 PROCESSED=4877 PRODUCED_DBS=4719 MOVED_ARMS=26 RC_DIFFS=0` — the same 21 plus my own five new arms |

**The movers, PREDICTED BY NAME independently** (`vpredict177.sh` +
`vretscan177.cpp`, a rule stated before any patched sweep was read: the law can
only ever mint a `ref_var`, so a database can move only if it holds a function
whose GOLDEN return is a `ref_var` and ours is not):
`SCANNED=956 CANDIDATE_DBS=9 NOGOLDEN=0 SCANFAIL=0` and
`SCANNED=1358 CANDIDATE_DBS=0`. The nine named databases and the one named
function are **exactly** the nine observed movers. (The first cut of this
predictor read the golden cache path as a FILE when it is a DIRECTORY and
scored `CANDIDATE_DBS=0` over the whole corpus — a green reading from a blind
gate; the shipped form counts `NOGOLDEN`/`SCANFAIL` so that cannot recur.)

**The Scoreboard/default coin, five repeat runs per binary, frozen binaries:**

| | run 1 | 2 | 3 | 4 | 5 | faces |
|---|---|---|---|---|---|---|
| pristine | `5345d158` | `5345d158` | `5345d158` | `a4eaa5fb` | `5345d158` | 2 |
| submitted | `3083f1ef` | `3083f1ef` | `3083f1ef` | `3083f1ef` | `3083f1ef` | 1 |
| verified | `c64e7692` | `3083f1ef` | `c64e7692` | `c6e2a6c5` | `c6e2a6c5` | 3 |

All fifteen: **95 cmp lines, 1 head, the same head object**
(`class_typespec: (type_id) @483:12`). The two pristine faces have
**identical** return-kind scans, so the coin is provably not the law's cell;
pristine-vs-patched order-blind is the law's one line.

---

## 2. THE REGRESSION — a name reachable through an `import` resolves in golden

`r10v140repro/v140_r_import.sv`, an arm r10uvm177's OWN boundary moved and its
`armjudge177` scored `ARMS-WITH-MOVED-WRONG=0`:

```
work@bellows_top::Anvil::clsShadowed  @34:5
   GOLDEN   enum_var   enum_typespec  Forge_pkg::HeatBand_e
   PRISTINE enum_var   enum_typespec  HeatBand_e          <- the KIND agreed
   PATCHED  ref_var    enum_typespec  HeatBand_e          <- and stopped agreeing
```

`Anvil` is a class in `module bellows_top`, which does `import Forge_pkg::*;`;
the class declares `typedef Ember_pkg::heatBand HeatBand_e;`, **shadowing**
`Forge_pkg::HeatBand_e`. Golden resolves the return token to the OUTER,
already-bound typedef — its typespec is literally named `Forge_pkg::HeatBand_e`
— and therefore takes the RESOLVED kind.

**Why r10uvm177's own gate could not see it.** Its census value is the triple
(var kind, typespec kind, typespec name), and the typespec NAME on that cell is
a pre-existing residue (`HeatBand_e` against golden's `Forge_pkg::HeatBand_e`).
A compound value that never agreed can never be scored MOVED-WRONG, so a cell
that was RIGHT on the judged `VpiType` field and became WRONG reads as
"MOVED-STILL-WRONG" and passes. `vscore177.py` prints the same classification,
but the elaborated view's rows carry no typespec, and there the move is naked:
`MOVED-WRONG`.

**`v177_6_shadow.sv` separates the two features the boundary cell confounds**
(a SCOPED base, and a SHADOWED name) at four homes. Golden, DEF views:

| cell | shadowed? | base | golden |
|---|---|---|---|
| `Holder2::pkgScoped`, `pkgBare` (package free fn) | no | scoped / bare | **`ref_var`** |
| `modScoped`, `modBare` (module fn) | no | scoped / bare | **`ref_var`** |
| `ifScoped`, `ifBare` (interface fn) | no | scoped / bare | **`ref_var`** |
| `InModA::mScoped`, `InModB::mBare` (module-homed class) | no | scoped / bare | **`ref_var`** |
| `PkgA::pScoped`, `PkgB::pBare` (package-homed class) | no | scoped / bare | **`ref_var`** |
| `Holder2::pkgShadowed` | **yes** | scoped | `enum_var`, typespec `Outer2::Plain_e` |
| `modShadowed`, `ifShadowed` | **yes** | scoped | `enum_var`, the OUTER typespec |
| `InModC::mShadScoped`, `InModD::mShadBare` | **yes** | scoped / **bare local** | `enum_var`, the OUTER typespec |
| `PkgC::pShadScoped`, `PkgD::pShadBare` | **yes** | scoped / **bare local** | `enum_var`, the OUTER typespec |

The base's spelling splits BOTH ways; the shadowing splits cleanly. Scored
against the submitted patch that arm is **`MOVED-WRONG=1` (def) and `7` (elab)**
— seven distinct source constructs, and `Holder2::pkgShadowed` moves wrong on
the FULL triple, where no residue can mask it.

## 3. THE FIX — § `ownNamedAliasNameIsNotShadowing177v`, and why it is IMPORT-ONLY

```c++
// term (5) of § ownNamedAliasRetIsRefVar177
if (ownNamedAliasNameIsNotShadowing177v(ta) == false)
    return false;
```

The helper walks outward from the alias's own scope and asks each scope's
`import`s — explicit and wildcard — whether the SAME NAME reaches a DIFFERENT
type. Two things were measured into it, each after a wrong first cut:

* **It must exclude the alias itself.** `import uvm_pkg::*;` written at FILE
  scope lands in the shared compilation unit under `--single-unit`, which is an
  ENCLOSING scope of `uvm_pkg`; a wildcard scan there hands back
  `uvm_pkg::UVM_SEQ_ARB_TYPE` itself. The first cut therefore killed the pass's
  own head in exactly the `--single-unit` rows: **7 movers instead of 9**,
  `SimpleUVM/default` and `Scoreboard/default` byte-identical to pristine, while
  `SimpleUVM/testflags` — the same sources without `--single-unit` — still moved.
* **It must ask IMPORTS ONLY.** A same-named type that is merely a NATIVE member
  of an enclosing scope does NOT resolve. `v177_7_native.sv` measures six golden
  cells with no import in the file at all — `$unit`↔package (`Native7::pkgTwin`),
  `$unit`↔module (`modTwin`), package↔class (`Inner7::clsTwin`), module↔class
  (`InMod7::imTwin`), the two-deep derived class (`Deep7::deepTwin`) — and golden
  is **`ref_var`** in every one, as it is for `r10v140repro/v140_w_inherit.sv`'s
  `Kiln_pkg::Urn::urnShadowed`. A cut that also declined those cost that arm's
  fixed cell and bought nothing. This is the same reading
  § `blockLocalTdDeclIsRefVarUnsupported155`'s shadow gate arrived at, and the
  helper reuses its `typeLike155`.

**The fix is lossless.** Every one of r10uvm177's own arms scores IDENTICALLY
before and after (`g177_a_alias` 6/12 FIXED, `g177_b_kinds` 5/14, `g177_c_homes`
4/8, `g177_d_bounds` 4/9, MOVED-WRONG 0 throughout), all nine corpus movers and
the 52 → 29 head are unchanged, and `v140_r_import` goes `MOVED-WRONG 1 → 0`
while keeping all six of its FIXED cells.

## 4. THE OTHER ARMS — seven of them, and the faces r10uvm177 never compiled

`vgrid177.sh` builds golden (Surelog) plus both binaries in BOTH views, echoing
every command WITH ITS BINARY PATH and every rc; the per-cell instrument is
`retcen177v.py`, which reads `uhdm-dump` TEXT and so shares no code with
r10uvm177's `ct177cen`. `vscore177.py` scores MOVED-WRONG = "agreed with golden,
then stopped". Verified patch, both views:

| arm | what is new in it | FIXED (def/elab) | MOVED-WRONG |
|---|---|---|---|
| `v177_1_ifprog.sv` | **interface**, **program**, class-in-**module**, class in **`$unit`** — four homes r10uvm177 never compiled | 6 / 9 | **0** |
| `v177_2_clone.sv` | wildcard-import clones, the FREE-subroutine half as well as the class half | 3 / 7 | **0** |
| `v177_3_kinds.sv` | kinds re-asked in a different order under different names; 3-deep chains; two typedefs of one enum; class-scope-scoped base; the return name assigned / read / bit-selected | 11 / 28 | **0** |
| `v177_4_cls.sv` | parameterized-class specializations, inheritance, out-of-body `Cls::alias` returns, `static` methods | 7 / 14 | **0** |
| `v177_5_inh.sv` | the inherited alias with the two class names sorting BOTH ways | 4 / 8 | **0** |
| `v177_6_shadow.sv` | **the regression** — shadowed × scoped-base, four homes | 10 / 18 | **0** (was 1 / 7) |
| `v177_7_native.sv` | shadowing with NO import anywhere, six scope pairings | 7 / 13 | **0** |

Every committed arm of **r10uvm169, r10uvm171, r10uvm173 and r10uvm174** was
re-run against both binaries: identical cmp line counts, identical head counts,
`MOVED-WRONG=0`. Those windows are undisturbed.

## 5. FINDINGS THAT ARE NOT REGRESSIONS (ranked residues)

1. **R0 IS MISDIAGNOSED — see `R0.r10v177.txt`.** r10uvm177 hands on
   "a `typedef REQ param_t;` inside a method body … golden materialises nothing".
   `uvm_sequencer_param_base.svh:270` is **`REQ param_t;`**, a plain LOCAL
   VARIABLE, and golden **does** list it — in the function's `Variables`, in the
   `begin` block's, in both listings, 8 occurrences to our 9. The single extra
   object is a `ref_obj` at 297:26, the argument of
   `m_req_fifo.try_put(param_t)`: **we bind its `Actual_group` to the local's
   `ref_var` and golden leaves it unbound** (golden also scopes its dump-only
   fullname under the CALL). Acting on the R0 as written — deleting a
   `Variables` entry golden has — would move cells AWAY from golden.
2. **The inherited alias is `ref_var` in golden whatever the names sort like.**
   `v177_5_inh.sv`: `Zzz5::zInhVia` (base alias, named base) and
   `Zzz5::zInhDirect` (base alias, **inline** base) and `Kid5::kGrandVia`
   (grandparent) are golden `ref_var`; we answer `enum_var` on both binaries.
   r10uvm177 cites `cv_inherited` / `cv_inh_direct` as evidence that its
   own-component term is right — but those two cells agree only because
   § `classTdLocalVarKindFollowsCompileOrder10`'s ORDER term happens to fire
   (`Parent177` sorts after `Child177`). Rename the base to sort first and the
   agreement evaporates while golden does not move. Three cells here, a family
   on the corpus; the ORDER model for a NON-SELF owner is the thing to re-decode.
3. **An out-of-body method returning a CLASS-SCOPE alias** (`Deck9::deckClsVia`,
   `Box9::boxOob`, spelled `Cls::alias` because slang demands it) is golden
   `ref_var` + `enum_typespec`; we emit `class_var` + `unsupported_typespec`.
   Pre-existing, untouched, two fields wrong.
4. **The unqualified typespec name** (r10uvm177's R1) is what keeps 6 arm-3 and
   4 arm-B cells at MOVED-STILL-WRONG, and it is what MASKED the regression in
   §2. It is worth its own pass for that reason alone.
5. `zQueue` / `zScopedInner` (arm 3): golden `array_typespec` / a
   `unsupported_typespec` where we mint `byte_typespec` / `enum_typespec` —
   pre-existing, both binaries.
6. Cosmetic, in my own added code: the call site reads
   `if (ownNamedAliasNameIsNotShadowing177v(ta) == false)`. Correct, but a
   double negative; left alone rather than spend a rebuild-and-regate cycle on
   spelling.

## 6. HOW TO REPRODUCE

```bash
g++ -O2 -std=c++17 vretscan177.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/v177_vretscan

# one arm, golden + two binaries, both views, then score it
bash vgrid177.sh v177_6_shadow.sv <pristine> <patched> <workdir>
python3 vscore177.py <workdir> --list

# the census of ONE database (independent of r10uvm177's ct177cen)
python3 retcen177v.py <db.uhdm>

# predict the movers BY NAME from PRISTINE + GOLDEN, before any patched sweep
VRETSCAN=/tmp/v177_vretscan bash vpredict177.sh <pristine sweep workdir> /tmp/PRED

# attribute the movers order-blind (the Scoreboard coin)
bash vattrib177.sh <pristine root> <patched root> <outdir> <rel> ...

# the boundary and the arm judgement reuse r10uvm177's own bound177.sh
PRIS=<pristine> PATCHED=<verified> bash ../r10uvm177repro/bound177.sh <probe copy> <out>
```

Evidence: `GATES.r10v177.txt`, `GRID.r10v177.txt`,
`GRID.assubmitted.r10v177.txt` (the regression as scored against the submitted
patch), `ARMS.r10v177.txt`, `BOUNDARY.r10v177.txt`, `R0.r10v177.txt`.
