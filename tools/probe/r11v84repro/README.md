# r11v84 — ADVERSARIAL VERIFICATION OF r11u84 (the import clones in the package's own listing)

**VERDICT: ACCEPT-WITH-FIX.** The three laws are right on golden, every headline
number reproduces bit-for-bit from my own build, and no face I could build moves
a pristine-right cell wrong. The fix is probe-only (two re-runnability defects in
the pass's own drivers); the production surface is byte-identical to
`/tmp/r11u84.patch` and the patched binary md5 is unchanged.

Own worktrees `/tmp/wt_v11u84` (patched) and `/tmp/wt_v11u84pris` (pristine) at
`c2ff6b71`, own `-j 2` builds, md5 taken separately, both frozen `chmod 555`
before any sweep, same-length sweep workdirs `slpa/slpr/u2pa/u2pr`.

```
  pristine  0765c72612466247727527e9f48c7512   == the OPS pin, built here, compared not assumed
  patched   217c082c9f5997646c3639e2d212eb40   == the implementer's, from the deliverable patch
```

## 1. What reproduced (every headline, independently)

| claim | implementer | measured here |
|---|---|---|
| boundary over the 52 committed arms | 44 identical / 8 moved, CONVERT 0, REGRESS 0 | identical, and each arm's blind/ordered distance equals `SWITCHES.r11u84.txt` cell for cell |
| per-cell score, 51 scored arms | 120 / 0 / 10 | 120 / 0 / 10 (t5 excluded: `golden_rc=4`) |
| `R11U84_OFF=1` == pristine | all 52 arms | all 52 arms **and** all 8 of my arms, byte for byte |
| surelog census | 1573 inv, 660 cells (452 own + 208 clone), 0 movers | identical, incl. the rc histogram and the 52/28/740 disjointness |
| uhdm2rtlil census | 1742 inv, 752 views, 0 cells | identical |
| u2r sweep | 788/16/67 both modes, join 0/1742, byteverify 0/1608 | identical, on both binaries |
| surelog sweep | 474/9 + 469/8, join 2/1596 (Earlgrey dump column) | identical — **and my pristine control sweep produces the same two rows** |
| surelog byteverify | 5/960, all UVM family | identical mover set |
| canaries / ctcan2 / canaudit / DB pins / rowheads | green | green; every byte pin matches the OPS value in both modes |

## 2. The breaks I built (8 arms, `grid/`) — none of them convicts the laws

`v1_hoistimp` **the one that could have broken LAW C.** A package whose
out-of-body constructor locals (`collectOobCtorLocals`, hoisted into the listing)
are written ABOVE the import: the pre-84 walk flushed the hoist queue at the
import slot, the patched walk does not. Golden settles it —

```
  GOLD hp1  h_var(clone), hl_a, hl_b, own_var_z | h_net(clone), h_wtd nt36(clone), own_net_z
  PRIS      hl_a, hl_b, h_var, ...              (hoist before the clone: WRONG)
  PATCH     == GOLD, both views
```

6 cells TO-GOLDEN on a face the pass never built: **the clone batch precedes the
hoisted locals too.** Note the census's `R11U84ORD` row reads `decls=2 SAME`
here, because it counts only `pkg.members()` Variable/Net — see §4.

`v7_ordmix` decl/import/decl/import/decl over BOTH vectors, plus an
import-last package and a parameter-and-typedef-first package: all EQ, 22 cells
TO-GOLDEN. `v8_expkinds2` own-decl-first + explicit + wildcard over one home,
`var`-keyword and `typedef reg` entries: 16 TO-GOLDEN, the only residue being the
split-on-erase phantom net (`k_ua` as a `logic_net nt36`), which is the pass's
own declared R0 and reproduces on an explicit+wildcard mix.

`v3_expedge` LAW B's declines, measured against golden: `import p::f` (function),
`::t` (task), `::L` (localparam), `::ENUMVAL`, `::class_type` put **nothing** in
golden's listing and nothing in ours; a `string` variable and a net do; the SAME
item twice gives TWO entries in both. `v4_transexp` an explicit clone carried on
by a wildcard hop, and an explicit item over the importer's own entry: all EQ,
including `t_wtd nt36` (LAW A on an explicit clone one hop down).

`v6_modctl` the MODULE-side control: the package cells move to golden, and the
module sections of every arm are **byte-identical between the two binaries** —
the ModuleEmit fence holds. It also measures the module-side residue (§4).

`v2_unitimp` a compilation-unit `import` before the packages (the
`fC->getObjects(paPackage_import_item)` pre-loop in `CompilePackage::
collectObjects_`): golden puts NO $unit clone in a package's listing. Arm is
0/0 on both binaries — the theory is refuted, not a residue.

`v5_nestdia` the nested diamond — see §4 residue 2.

Switch ledger over my 8 arms (`SWITCHES.r11v84.txt`): `R11U84_OFF=1` returns
every one to pristine byte for byte; `ELAB_OFF` returns `v6`; `EXP_OFF` returns
`v3`/`v4`; `ORDER_OFF` leaves `v1` 200 and `v7` 732 ORDERED lines with
`patch_blind=0` — an order-blind comparator reads LAW C as dead code, exactly as
the pass warned.

## 3. What I checked that the pass's own instruments could not

**The five surelog movers, ORDER-SENSITIVE.** The pass attributed them with an
order-BLIND diff, which is the one instrument its own LAW C is invisible to. I
re-dumped all five from both frozen binaries and diffed path-normalised and
ORDERED: `4` lines each for MiniAmiq (x2), SimpleUVM, SeqDriver — `vpiDecompile`
+ `UINT` (e.g. `1151` -> `1336`), the documented line-number class — and `92`
ordered lines with `0` blind for Scoreboard, which is verbatim the svunit_pkg
`vpiTaskFunc` order coin of RESUME §9. **Package-listing lines: 0 of 5.**

## 4. Residues, ranked (mine, on top of the pass's list)

1. **The pass's R0 (split-on-erase phantom net) is real and reaches further than
   its own grid.** Reproduced on `v5_nestdia` `nd2` and on `v8_expkinds2` `xk2`
   (an explicit + wildcard pair over one home): golden carries a `logic_net`
   named after a VARIABLE with `vpiNetType 36`. 4 cells here, unbuilt by design.
2. **NEW — the transitive diamond is DEDUPED by `seen9` and golden does not
   dedupe.** `v5_nestdia`: `nd3` wildcard-imports `nd2`, which reached `nd1`
   twice (direct + through `nd1b`). Golden's `nd3` lists `nd1`'s entries TWICE;
   we list them once, on BOTH binaries (pre-existing, pass-79 ground, 4 cells).
   The top-level diamond is right because each import item starts its own
   recursion; the dedupe only bites one hop down. This is the next head on this
   ground beside R0.
3. **NEW — the MODULE-side clone does not read the elaborated entry.**
   `v6_modctl`, `uhdmallModules`: golden's `work@dut.c_wtd` is `nt 36` in the DEF
   view, ours `nt 1`; `uhdmtopModules` `work@dut.c_b2` is `bit_var` in golden,
   `logic_var` in ours. LAW A is a property of the Signal POINTER, so it holds on
   the module hoist too — that is ModuleEmit ground (the sister pass's), left
   measured, unchanged by this patch.
4. **The census's LAW C predictor under-counts.** `R11U84ORD` counts only
   `pkg.members()` Variable/Net as `decls`, so a package whose pre-import entries
   are HOISTED ctor locals reads `SAME` while its database moves 204 ordered
   lines (`v1_hoistimp`). The corpus claim survives anyway because the BYTE gate
   is order-sensitive and named only 5 movers, all attributed — but the a-priori
   argument, as written, is narrower than it reads.
5. **The `t5_expfences` cells are `AWAY-GOLDEN=6` when scored.** Excluding them
   is correct (`golden_rc=4`; an arm whose compile fails teaches error recovery),
   and the pass discloses it — quoted here so the exclusion is never silent.

## 5. The fix in `/tmp/r11u84.verified.patch` (probe-only)

* `ordlist84.py` read `pkgscore79.py` through a hard-coded
  `/tmp/wt_r11u84/...` path — another pass's worktree, gone after landing, and
  an OPS rule ("drivers must not hard-code another pass's paths"). Now resolved
  relative to the script's own directory, like `reg84.py` already did.
* `cen84.py`'s docstring named `R11U71_CELLDBG`, `pkgcen79.py` and
  "generate-scope cont_assign" — a copy from an earlier pass that misdirects a
  future operator re-running the census. Text only; no code changed.

Production (`src/ParamEmit.cpp`, `include/UhdmExporter.h`) is untouched by the
fix, so the patched binary md5 and every gate above carry over unchanged.

## 6. How to re-run

```
GRID=<dir> bash ../r11u84repro/rr84.sh <binary> <tag>        # the arms, rc on every line
python3 ../r11u84repro/reg84.py <grid-dir>                   # per-cell TO/AWAY/STILL
GRID=<dir> bash ../r11u84repro/sw84.sh <binary> t R11U84_OFF=1
```
