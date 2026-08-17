# r10buvm9 — ADVERSARIAL VERIFICATION of § sharedTdRefNoRestamp9

**MEASUREMENT-ONLY.**  The official `uhdm-cmp` and `scripts/verify_golden.py`
remain the only acceptance judges.  slang was not patched, `results/*.csv` were
READ ONLY, nothing was promoted, `GOLDEN_DEFER` was left UNSET.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `79efb64` |
| worktrees | `/tmp/wt_vbuvm9` (patched+fix), `/tmp/wt_vbuvm9pris` (pristine) |
| pristine md5 | `ec401fc9f5510140460b9658dfc59dc9` — reproduced from aan independent configure+build |
| shipped-patch md5 | `7c41b38a41a4b4459fe1fc568dba6cdc` — reproduced |
| VERIFIED md5 | `466d1a24cb82827dd30e599b70dc7bf1` |

## VERDICT: ACCEPT, with ONE cell re-cut

Every headline number reproduced bit-for-bit from independently configured
builds.  One **pristine-right → patched-wrong** cell was found on legal SV by a
new arm and is fixed here (§ `classPkgAliasKeepsStamp9v`); the fix produces
**byte-identical databases to the shipped patch on all 2 313 corpus databases**,
so it costs nothing and every corpus number above still holds.

## THE OVER-FIRE, and the fix

`w6v_clsalias.sv` — a CLASS-scope typedef that is an ALIAS OF A PACKAGE typedef
(`class k; typedef pkg::b_s n_s; ...`).  Golden stamps ALL TEN such cells with
the **ELABORATED** package; the law's `ClassOther` cell claimed they carry
nothing.  Nine of the ten were already wrong on the pristine binary (DEF or
NONE), but **one was RIGHT**:

```
OVER-FIRE   struct_typespec|n10_s|CLS:w6k   G=ELAB  P=ELAB  Q=NONE
```

`n10_s` is referenced from a **PACKAGE function's** nested-block local, where
site 1's pristine stamp IS golden's answer.  The fix adds a fifth cell,
`SharedTd9::ClassPkgAlias` (target-is-a-TypeAlias homed in a Package), held at
**exactly pre-law behaviour** — stamp KEPT at sites 1-3, REMOVED at site 4 — so
the cell is pristine-identical instead of newly wrong.  An INLINE
`typedef struct{...}`/`typedef enum{...}` at class scope has an ANONYMOUS
target, never a `TypeAlias`, so the three BuildUVMPkg head objects cannot land
in the new cell.  After the fix `w6v_clsalias` reads `residue=9 same=7`,
OVER-FIRE **0**, and v1/v2/v3/v4 keep their 2/7/0/3 CONVERTED verdicts.

## Reproduced bit-for-bit

* both binaries' md5s; goldens **23/23/23** and `/bin/false` → **0**
* u2r **679/50/2** each mode each binary; row gate **0 differing rows / 1 462**
* surelog row gate **0 differing rows / 1 588** vs pristine AND vs the committed
  `results/golden_surelog.csv`
* `byteverify SELFCHECK=1 SELFCHECK1=1`: surelog **9/955**, u2r **0/1 358**,
  controls 954/955 + 10 and 1357/1358 + 1 — same 9 movers, same md5s
* head set: BuildUVMPkg **644 323 → 17** lines, heads 1→1, both modes byte
  identical to each other; the other 12 measured rows BYTE-IDENTICAL;
  `measured=12 SKIP-NOFILE=2 UNKNOWN-NAME=0`
* new head = `ref_typespec(uvm_field_flag_t)#1710` < `bit_typespec@7859:9`,
  `RHS: <null>`
* ladder: pristine **247** / patched **341** rungs, both FIXPOINT, calibration
  **0 rungs on 183 142 objects**; **0** pristine rungs LOST by LHS object,
  94 added; added RUNG 34 is `recursion_state_e#144162` vs `bit_typespec#11139`
  and **#11139 is present with the same id and chain in the PRISTINE database**
  (R5 is pre-existing, made visible)
* canaries `ok=52/16 changed=0`, ctcan2 `ok=58/2 changed=0`,
  `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`, all five pinned md5s in
  both modes, determinism 1 distinct hash / 0 NO_OUTPUT
* the committed `results/golden_uhdm2rtlil.csv` disagrees with a fresh sweep on
  **104** rows (100 relative-vs-absolute `SLANG_REJECT` detail paths +
  `ParameterSizeOfInstance` / `paramod_genscope_child` dump `differ`→`match`,
  both modes) — the diff sets are **IDENTICAL on pristine and patched**, so the
  committed baseline is stale at `79efb64`.  Confirms the pass's ops note.

## Two GAPS in the shipped gates, both closed here

1. **`bndarms9.sh` globs only `<dir>/*.sv`.**  sd8 / sd9 / sd11 keep their arms
   in SUBDIRECTORIES (`grid6`…`grid11`, `qgrid4`, `grid7v`), so the shipped
   boundary gate never compiled a single one of them — and sd9/sd11's listing
   laws are named BOUNDARIES.  `bndsub9v.sh` takes a LIST instead of a glob;
   over the **852** subdirectory arms: `IDENTICAL=778 MOVED=10 REJECT-BOTH=64
   ONE-SIDE=0`, and the 10 include **sd11's own `grid10` arms**.  Combined with
   the top-level run over all 167 probe dirs (**890 IDENTICAL / 12 MOVED /
   10 REJECT-BOTH**) the boundary gate here covers **1 764 arms**, not 143.
2. **`attrib9.sh` joins only LISTED, NAMED typespecs**, so a `vpiInstance` that
   moved on an ANONYMOUS or UNLISTED one is invisible to its "OVER-FIRE 0".
   `attriball9v.py` keys on `kind|name|loc` with no listing filter and prints
   the COMPLETE blast radius.  Over all 9 mover databases it finds exactly
   **9 / 7 / 7 / 2 / 2** changed typespec keys — 47 objects, **every one
   CONVERTED, OVER-FIRE 0, nothing else moved at all**.

## Why a cmp-line INCREASE is not a regression (measured, twice)

`w3v_homes` 175 → 7 930 and `w4v_imports` 1 983 → 3 734 lines.  Both are head
ADVANCES: `w3v_homes`'s new head is `design::AllClasses VEC:G>O` (golden 6
classes, ours 5 — a nested class we never list) which is **ROOT-BLOCKED and
present on the pristine binary**, and `w4v_imports` loses TWO rungs and gains
none.  The general proof is stronger than any single arm: on **every** moved
database, `uhdm-dump` differs ONLY in `vpiInstance` lines (0 non-instance
lines), so this patch cannot create a kind, name, span or structure
disagreement — every added rung is provably pre-existing and previously masked.

## Residues found here (ranked)

* **RV1** — golden stamps a CLASS-scope alias-of-a-PACKAGE-typedef with the
  ELABORATED package (`w6v_clsalias`: 10/10 `G=ELAB`); we write DEF at sites
  1/3, NONE at sites 2/4.  Unreachable by `uhdm-cmp` today because golden models
  such an alias as a `typespec` + `ref_typespec` pair we do not emit at all
  (that MISSING-OURS gap is the arm's head on both binaries).  The next law for
  this family, and the reason `ClassPkgAlias` exists.
* **RV2** — a class NESTED in a class is missing from `design::AllClasses`
  (`w3v_homes`, golden 6 / ours 5); ROOT-BLOCKED, pre-existing.
* **RV3** — `typedef REQ this_r_t;` inside a parameterized class
  (`r10uvm31repro/t41b_dut`): golden names it `p31v::this_r_t`, parents it at
  the `type_parameter` and stamps a THIRD package; we list it in the class.  The
  one arm where this patch's edge is invisible in both directions (124 → 124
  lines, 20 → 20 rungs).
* **RV4** — class-scope `string`/`real`/`shortreal`/`union`/`chandle`/`event`
  typedefs are absent from our class listing entirely (`w2v_clskinds`, 6 kinds);
  queue/dynamic/associative `array_typespec`s are listed but carry ELAB where
  golden carries NONE.  All identical on both binaries.
* **RV4b** — package-scope queue / dynamic / associative `array_typespec`s are
  absent from BOTH our package listings (`w8v_pkgkinds` `pT`/`pU`/`pV`) and the
  fixed-size one is absent from the DEF listing only (`pR`); pre-existing.
* **RV5** — the implementer's R1 (alias-chain / typedef-of-typedef) reproduced
  exactly: `v4inst9` `d0_e`/`d8_t`/`d9_t`/`d10_t` and BuildUVMPkg's
  `UVM_SEQ_ARB_TYPE` / `uvm_sequence_state` / `uvm_sequence_state_enum`.

## Files added by the verifier

| file | what |
|---|---|
| `w1v_pkgclsts.sv` | `PkgClassTs` over 12 reaches incl. a MODULE function's local |
| `w2v_clskinds.sv` | `ClassOther` over **26** typespec kinds |
| `w3v_homes.sv` | $unit / module / interface / nested-class homes (the scope fence) |
| `w4v_imports.sv` | wildcard + explicit import, `export a::*` re-export, 3-package chain |
| `w5v_alias.sv` | class-alias-of-package-td, package-alias-of-class-td, 2-hop chains |
| `w6v_clsalias.sv` | **the arm that found the over-fire** |
| `w8v_pkgkinds.sv` | `PkgOther`/`PkgClassTs` over **26** kinds x the DEF **and** ELAB listing entry: `same=43 CONVERTED=1 OVER-FIRE=0` — the PkgOther fence holds for every kind |
| `w7v_pkgclsts2.sv` | `PkgClassTs` where the ONLY reference is a module / interface / program fn, virtual + interface classes |
| `cmparm9v.sh` | one arm through the OFFICIAL `uhdm-cmp` both ways (heads from BOTH streams) |
| `bndsub9v.sh` | boundary gate over a LIST of arms (reaches the sd8/sd9/sd11 grids) |
| `attriball9v.py` | listing-agnostic complete blast radius per database |
