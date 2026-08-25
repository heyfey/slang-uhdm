# r10v136 — ADVERSARIAL VERIFICATION of r10uvm136 (§ `classPropPackedStructIsStructVar136`)

**VERDICT: ACCEPT `/tmp/r10uvm136.patch` AS SHIPPED.** Production is unchanged
by this directory — the verified patch is the implementer's patch byte for byte
plus this measurement-only probe dir.

**MEASUREMENT ONLY.** The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp`
(md5 `2ad8015175758e918de1789b86ef1ea5`, identical to `~/.local/bin/uhdm-cmp`).
slang was NOT patched; `results/*.csv` were READ ONLY; nothing was promoted; NO
CORPUS ROW CONVERTED. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `73d4acc`, two FRESH worktrees (`/tmp/wt_v136` patched, `/tmp/wt_v136pris` pristine) |
| pristine binary | md5 `bbb257fe5d8b2cfa736920bd64e5cb9e` — **identical to the implementer's**, frozen `chmod 555` before any sweep |
| patched binary | md5 `84f31e681259404d976c23fb61e18478` — **identical to the implementer's** |
| patch | `/tmp/r10uvm136.patch` md5 `85a0af80892851e559a2c7c78217514f`; re-generated from the applied worktree as `git diff --cached 73d4acc` and **byte-identical** to the file supplied |
| surface | `src/UhdmExporter.cpp` (two `else if` arms) + `tools/probe/r10uvm136repro/` — 0 `results/*.csv` hunks, 0 fenced-test mentions, 0 `rm -rf`, no hard-coded foreign paths |

## 1. Every headline number reproduced bit-for-bit

Both binaries built here (`-j 2`, md5'd separately), `SLANG_UHDM` exported
explicitly per binary, both frozen before any sweep.

* **Goldens** pristine 23 PASS / 0 FAIL, patched 23 PASS / 0 FAIL, `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL.
* **uhdm2rtlil** both binaries, both modes: `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2`.
  `ct8rows` PASS vs the committed `results/gate_uhdm2rtlil.csv` **and** vs this
  verification's own pristine sweep (tf and default). `byteverify SELFCHECK=1`
  **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL.
* **surelog `--mode both`** patched histogram identical to pristine cell for
  cell: `CMP_EQUAL 937, CMP_NOTEQUAL 19, DEFERRED 10, NO_DATABASE 3, NO_UHDM 1,
  SLANG_REJECT 567, SURELOG_FAIL 48, TIMEOUT 1, UNTRANSLATABLE 2`.
  `ct8rows` PASS vs `results/golden_surelog.csv` and vs own pristine — **no row
  converted**, `Earlgrey_0_1/testflags` stays `CMP_NOTEQUAL`.
* **`cmds.txt` audit by binary PATH**, file by file: `u2rp` 1458/1462 name
  `/tmp/v136_bin/pris.bin`, `u2rq` 1458/1462 name `/tmp/v136_bin/pat.bin`,
  `slp`/`slq` 1523/1573 name theirs. **0 name the main-tree binary.**
* **Movers, surelog: 9 / 956**, exactly the nine the implementer predicted BY
  NAME (all `uvm_pkg::uvm_reg_map_info::mem_range`). Order-blind attribution
  (`v136_attr.sh`: `uhdm-dump`, workdir normalised out, both sides SORTED)
  reads the same on all nine, Scoreboard/default's coin included:
  **2 lines OUT (`bit_var`), 2 lines IN (`struct_var`), LAW-ONLY.**
* **Heads** (`rowheads.sh`, own sweeps): SimpleUVM ×2 and Scoreboard/default
  **64 → 32**; SeqDriver 17, MiniAmiq 80, BuildUVMPkg 60, Earlgrey 21302/21926
  head logs **byte-identical**; Rggen/default CMP_EQUAL. All eighteen committed
  `head_pris_*` / `head_pat_*` logs reproduce **byte for byte** here, ids
  included — Scoreboard/default's included. The new head is the R0 named:
  `uvm_reg_block.svh:1914 return UVM_FRONTDOOR;`, golden a `constant`
  (ct 7 / size 64 / `INT:0`), ours a `ref_obj`.
* **Canaries** `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2` PASS ×2;
  `canaudit` PASS, audited=29, UNCOVERED=0, **FENCE-BREACH=0**.
  Protected DBs, patched vs own pristine: InterfaceModPort `59a365f3ce2c`,
  BlackParrotComplex `73a10e8217e5`, YosysOldOr `d68e0796d62c` all identical;
  SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a` **pins matched**.
* **Independent kind census** (`v136_kindcen.py`, no shared instrument with the
  pass): golden vs ours on `default/SimpleUVM`, over EVERY `*_var` object —
  pristine 7 kind-disagreeing names, patched 6; the one removed is
  `uvm_pkg::uvm_reg_map_info::mem_range`. Nothing else changed kind.

## 2. Breaking the law — this verification's OWN grid

11 arms (`arms/`, one of them in `arms/sub/`), built by Surelog and by both
frozen binaries in the **DEF and ELAB views** (`v136_arm.sh`; Surelog re-run
with `-elabuhdm` so ELAB has a golden of its own; every child `</dev/null`,
every rc printed; ours run `--nobuiltin` so the cmp is not swamped by the
builtin asymmetry).

Two instruments, deliberately different from the pass's:
* `v136_cells.py` — per-cell census over `uhdm-dump`, keyed on the object's
  fullname, valued by its UHDM class **and its multiplicity**. No spans, no files.
* `v136_score.sh` / `v136_norm.sh` — a whole-dump, id- and path-normalised,
  **sorted** set score: `NEW_WRONG = Q − G − P` (a line the patched binary
  invents that neither golden nor the pristine binary emits) and
  `LOST_RIGHT = (G ∩ P) − Q` (a golden-agreeing line the patch destroyed).

| arm | dimension |
|---|---|
| `v136_a_faces.sv` | 20 faces: packed struct 2-/4-state/mixed, packed union, unpacked struct/union, enum, `logic[N]`/`bit[N]`/`int`/`string` typedefs, a 2-deep chain, a **forward typedef**, a class handle, a **parameterized** class handle, the **anonymous** packed struct / packed union / unpacked struct, raw vector, raw int |
| `v136_b_order.sv` | typedef from an `include`d file, same-file-after, cross-package **qualified** and **wildcard**, **in-class** struct and union typedefs, and the CLASS-QUALIFIED spelling (§73's population) |
| `v136_c_props.sv` | plain / static / rand / randc / local / protected / local static / protected rand / **const with initializer** / initializer / fixed / queue / dynamic / associative / multi-declarator / 2-D unpacked, over struct AND union faces |
| `v136_d_homes.sv` | `$unit` class, package class, module class, **base → derived**, **virtual → concrete**, a `$unit` face used from a module class, **3 instances** |
| `v136_e_edge.sv` | parameterized class, **`type` parameter**, nested class, struct-in-struct, struct-with-enum, specialized handles, unpacked arrays of the face |
| `v136_f_fence.sv` | the FENCE: genuine PACKED arrays (`T [1:0] p;`) over struct / 2-D struct / union / enum, plus `bit`/`logic`/`logic`-typedef leaves that must NOT move, plus scalar controls and a packed-array-inside-unpacked-array |
| `v136_g_param.sv` | `Generic#(packed struct)` / `#(packed union)` / `#(unpacked struct)` / `#(bit[7:0])` specializations, a 3-level inheritance chain, 3 instances |
| `v136_h_more.sv` | a package **split over two files**, an interface home, a **program** home, in-class struct vs in-class union |
| `v136_j_uses.sv` | DOWNSTREAM uses: `rand` under **constraints**, a **covergroup** coverpoint, method bodies reading/writing/member-selecting the property, a **`struct packed signed`**, a name shadowed base/derived, a class in a **generate** block |
| `v136_k_qual.sv` | the §73 BOUNDARY: class-qualified, package-qualified, package+class-qualified, and a **package-level alias of a class-scoped typedef** |
| `v136_z_control.sv` | the NEGATIVE CONTROL — 24 properties, **not one packed struct or union**: unpacked struct/union, enum, class handle, all six integer atoms, `real`, `shortreal`, `string`, `chandle`, `time`, `event`, plain vectors, all four array kinds, `int`/`string` typedefs |
| `arms/sub/v136_c_props.sv` | arm C again, in a SUBDIRECTORY |

### Result

```
per-cell census, all 11 arms x DEF and ELAB, 338 scored cells
  FIXED               146
  AGREE               151
  STILL-WRONG          29   (unchanged, pre-existing)
  CHANGED-STILL-WRONG   6   (kind now golden's, dump MULTIPLICITY still differs — pre-existing)
  MOVED-WRONG           0
  ONLY-OURS             0
  ONLY-GOLDEN           6   (interface-scoped class properties we never emit — pre-existing)

whole-dump set score, every arm x both views
  NEW_WRONG   0   on 10 of 11 arms   (3 on v136_k_qual.sv — see R-A below)
  LOST_RIGHT  0   on ALL 11 arms x both views
```

The negative control `v136_z_control.sv` reads `NEW_WRONG=0 LOST_RIGHT=0
NEWLY_AGREEING=0` — **not one of its 25 cells moves**, before or after, while
every packed-struct arm moves. The fence holds exactly as claimed:
`g05_pabit` / `g06_palogic` / `g07_patypedef` stay `bit_var` / `logic_var` /
`logic_var`, the packed-array cells stay `bit_var` on both binaries, and
`g12_pa_then_unpack`'s packed-array ELEMENT is untouched. §73's fence holds:
`Pk_InClass::QualUser::b08_clsQual` and `Pk_Q::Users::k02_clsQual` /
`k03_clsQualU` / `k07_pkgClsQual` / `k11_clsQualFromMod` are `logic_var` in
golden and `logic_var` in BOTH binaries.

The implementer's own seven arms were re-run here against Surelog with these
instruments and reproduce their claimed DEF FIXED counts exactly
(6 / 7 / 8 / 4 / 8 / 1 / 0 = **34**), `NEW_WRONG=0 LOST_RIGHT=0` on every one.

## 3. The WIDE differential boundary — 3912 files, 7824 runs

`v136_bound.sh` runs BOTH frozen binaries over **every `.sv` under
`tools/probe/`** of the main tree (top level AND subdirectories), in both
views, and byte-compares the databases. `LISTED=3912 PROCESSED=3912`,
**`RC-DIFF 0`**, `MOVED 86 rows / 43 files`, `SAME 7738`.

`v136_bgold.sh` then builds a Surelog golden for each of the 43 moved files and
scores it: **`NEW_WRONG=0 LOST_RIGHT=0` on 42 of 43, both views.**

**The 40 rows of the must-stay controls** — `r10uvm126repro`, `r10uvm129repro`,
`r10uvm114repro`, `r10buvm31repro` — are **all `SAME`**: not one byte of any of
those arms' databases moves.

The one file that flags, `tools/probe/r10buvm22repro/g22.sv`, is **NOT this
pass's doing** — see R-B.

## 4. Ranked residues found by this verification

**R-A — a package-level ALIAS of a class-scoped packed-struct typedef now
reads `struct_var` where golden reads a bare `logic_var`. 3 grid cells,
0 corpus cells. NOT a regression; do not block on it.**
`arms/v136_k_qual.sv`, cells `k04_aliasOfClsTd`, `k09_xpkgAliasOfClsTd`,
`k12_aliasFromMod` — `typedef Home::homeSpan_S aliasOfClassTd_S;` at package
scope, then `aliasOfClassTd_S p;`:

| | golden | ours pristine | ours patched |
|---|---|---|---|
| kind | `logic_var` (§73's degraded, TYPESPEC-LESS object) | `bit_var` + ref_typespec | `struct_var` + ref_typespec |

Golden's §73 degradation follows the typedef chain's ULTIMATE home, not the
written name's scope; our `foreignTd73` predicate only catches the directly
class-qualified spelling, so it **under-fires on the alias** — a PRE-EXISTING
defect. The cell was already wrong (`bit_var` ≠ `logic_var`) and both wrong
kinds first-fail `BaseClass::Compare` at the same field, `UhdmType()`; the arm's
official `uhdm-cmp` line count is **284 before and 284 after**. Corpus reach is
**zero** (0 of the 9 surelog movers, 0 of 1358 u2r). The fix belongs to a §73
widening with its own census, not here.

**R-B — a class-scoped `typedef int T[int];` mints a GARBAGE constant whose
value tracks the binary's code layout. Pre-existing, both binaries, 0 corpus
cells.** `tools/probe/r10buvm22repro/g22.sv:72` (minimal repro: a class
containing `typedef int ka_str_t[int];`). The `array_typespec`'s `[0 : X-1]`
range carries `UINT:22477569` on the pristine binary and `UINT:22481665` on the
patched one — **deterministic per binary, differing by exactly 4096 (one page)**,
i.e. a pointer read as a value. Golden has neither number. This is why that one
boundary file scores `NEW_WRONG=4`: the garbage merely re-rolled. It is not
reachable from either corpus (the surelog byteverify's movers are the nine
`mem_range` cells and nothing else), but any future pass whose patch shifts code
layout will see it as a phantom mover on that file — worth fixing on its own.

**R-C — an IN-CLASS packed UNION typedef binds a `bit_typespec`, and is missing
from the class's `vpiTypedef` list. Pre-existing, unmasked by this pass.**
`arms/v136_h_more.sv` `i06_inClassUnion` / `arms/v136_b_order.sv`
`b07_inClassU`. Golden: `union_var` + `union_typespec (icWrap_U)`, and the
`union_typespec` also appears under the `class_defn`'s `vpiTypedef`. Ours,
BOTH binaries: the property's `vpiActual` is a bare `bit_typespec` and the class
carries no `union_typespec` at all. The in-class packed STRUCT twin is correct
on both counts. Because the patch fixes the variable's CLASS, this typespec
defect becomes the arm's new head (arm B 64 → 92 cmp lines, arm H 64 → 92) —
a masking cascade, not a regression: `NEW_WRONG=0` on both arms.

**R-D (method note) — `bound136.sh`'s DEF half is inert.** It compares
`uhdm-cmp` line counts with our binaries run WITHOUT `--nobuiltin` against a
Surelog golden built WITH `-nobuiltin`, so the head and the whole cascade are
builtin objects: arm A reads `PRIS_CMP 5738 / PAT_CMP 5738` where the same arm
run `--nobuiltin` reads 64 → 46. Its `CMP_OR_RC_DIFFS=0` therefore says only
"no rc change and no gross line-count change"; the real detection in that script
comes from its `ELAB-SAME`/`ELAB-MOVED` byte-compare column, which has no golden
behind it. The pass's golden-checked evidence lives in `arm136.sh` +
`score136.py` + `cen136`, which is sound; the boundary script just reads
stronger than it is. `v136_bound.sh` + `v136_bgold.sh` here are the
byte-compare-then-golden-check form.

## 5. The files

| file | what it is |
|---|---|
| `v136_arm.sh` | build ONE arm with Surelog (DEF **and** `-elabuhdm`) and both frozen binaries, in both views, and cmp all four pairs. `PRIS=` / `PATCHED=` required; scratch keyed on the RELATIVE path; every child `</dev/null`; every rc printed. |
| `v136_cen.py` | the per-object census reader (`uhdm-dump` → `(fullname, UHDM class, multiplicity)`). |
| `v136_cells.py` | the scorer over a golden/pristine/patched triple of arm directories: FIXED / AGREE / STILL-WRONG / CHANGED-STILL-WRONG / **MOVED-WRONG** / ONLY-OURS / ONLY-GOLDEN. |
| `v136_norm.sh` | id-, file- and path-normalised, sorted `uhdm-dump`. |
| `v136_score.sh` | `NEW_WRONG` / `LOST_RIGHT` / `NEWLY_AGREEING` over one arm directory, both views. |
| `v136_bound.sh` | the WIDE differential boundary: both binaries over one probe `.sv`, both views, byte-compare + rc. `PRIS=`, `PATCHED=`, `PROBE_ROOT=` required. |
| `v136_bgold.sh` | golden-check one moved boundary file (`NEW_WRONG`/`LOST_RIGHT`). |
| `v136_attr.sh` | ORDER-BLIND mover attribution. `PRIS_WD=` / `PAT_WD=` required. |
| `v136_kindcen.py` | the independent whole-database kind census, golden vs ours. |
| `arms/*.sv`, `arms/sub/*.sv` | the 11 arms of §2. |

Rebuild the numbers with, e.g.:

```
PRIS=<pristine> PATCHED=<patched> bash v136_arm.sh arms v136_k_qual.sv /tmp/<scratch>
bash v136_score.sh /tmp/<scratch>/v136_k_qual.sv
python3 v136_cells.py /tmp/<scratch>
```
