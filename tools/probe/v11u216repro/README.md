# v11u216: adversarial verification of r11u216 (the module/type ground, pair B, base 745f66ab)

**Verdict: CONFIRMED WITH FIX.** Every headline number of r11u216 reproduces bit for bit. Fresh cases found two
places where one of its laws writes a record golden does not hold. Both are fixed behind their own switches:

* § tfArgOutsideClassOrder216 states Surelog's class compile order as "packages by name, then module classes". The
  real order is Surelog's class-definition multimap key. It gives the wrong writer on 7 fresh cases (14 case-views).
* § genScopeRangeQueryFold216 / § ndaRangeQueryFold216 locate a parameter operand's arithmetic bound at the left
  operand, where golden locates it at the query call. This affects 3 fresh cases (6 case-views).

In all 20 case-views pristine was wrong too (a `line` record or stage 1), so no gate row, probe case or downstream row
moves. Neither fix moves any corpus, probe or downstream-lane database against r11u216's. With the fixes, all 20
case-views reach EQUAL except t02 and t04, which reach r11u216's own exposed module-class name face (`fullname`).

**Process finding (item (0) of the brief):** r11u216's README says the r11u214 decode "had not landed at the start or at
delivery". That is wrong for delivery. `tools/probe/r11u214dec` landed at 83ee16d6, and /tmp/r11u214.patch existed at
18:06. Both came before r11u216's README (18:39) and patch (18:39), but after its start (worktree 17:03). The brief's
item (0) therefore applied, and its law_typeemit.patch was not landed. Section 5 measures the composition. The two
patches merge cleanly (the only textual conflict is at the switch declarations, and `git apply --3way` resolves it)
and compose additively. The 12 generic records the flat census reads as lost belong to r11u214 alone.

Ship: /tmp/r11u216.verified.patch = r11u216's patch + the two refinements + this directory + the regenerated
tests/LAWS.md.

## 1. Reproduction (both binaries built here, frozen before any measurement)

* Worktrees /tmp/wt_v11u216pris (pristine) and /tmp/wt_v11u216 (r11u216's patch applied to a fresh 745f66ab). Both
  were built with `-j 2`.
* Pristine: `8c724b6404258a8d5c9648ea1c376823`, byte-identical to the main tree's build/slang-uhdm.
* r11u216 law: `53d6e821836b2ba7ad70ec7ca2060e72`, byte-identical to the implementer's.
* Fix (`fix2.bin`): `f774a9ec4bb5a082f26487433d0d4cf4`. The strict comparator is `fa6e4f42`.
* The verified patch applied to a fresh 745f66ab (`git apply`, clean) builds `f774a9ec` byte for byte, and
  `scripts/law_index.py --check` reads current there.
* Every cmds.txt of every corpus sweep names its sweep's frozen binary by path. Each of the pristine, law and fix sweeps
  has 3273 `slang:` lines, all naming its own binary.

| claim | measured here |
|---|---|
| probe 3410 + 677, 0 / 0 / 0 | law **3410 + 677, regressions 0, conversions 0, changes 0** |
| surelog 929 + 25, 0 regressions, 2 changes (MiniAmiq d/t `file(75)` -> `fullname(61)`) | **same**: `MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(61),,differ:fullname(61)` and the testflags twin; uhdm-cmp 0 lines on both |
| uhdm2rtlil 1596 + 10, 0 / 0 / 0 | **same** |
| downstream 803 / 66 / 2 / 0, verdicts = pristine = baseline | **same** (law, fix and pristine sweeps, row for row against results/downstream_uhdm2rtlil.csv) |
| byte movers surelog 2 (MiniAmiq d/t `ae2f0060a863` vs `4db8f413be66`), uhdm2rtlil 0, probe 0, lanes 0 of 805 | **same** (byteverify SELFCHECK 959/960 and 1607/1608; probe compared from one worktree, 0 / 4087; lanes 0 / 805) |
| away census 0 lost, 189 gained (flat), reversed 189 lost | **same** on both modes (v11u202's away.py) |
| UVM order-blind distance MiniAmiq 6528 -> 6339 | **same** (away.py dist) |
| grid 124 case-views: 84 -> EQUAL, 3 stay, none leaves; `R11U216_OFF` pristine on 124/124 | **same** ([evidence/grid_r11u216.tsv](evidence/grid_r11u216.tsv)) |
| canaries surelog 52/0, uhdm2rtlil 16/0, ctcan2 PASS both | **same** on the fix sweep ([evidence/gates/canaries.txt](evidence/gates/canaries.txt)) |

## 2. The breaks and the refinements

### 2.1 § tfArgOutsideClassKeyOrder216v (UhdmExporter.cpp, inside § tfArgOutsideClassOrder216's writer order; `R11V216_CLSKEY_OFF`)

**Decode.** Surelog compiles classes in `CompileDesign::compileMT_` over `Design::getClassDefinitions()`. That is a
`std::multimap<std::string, ClassDefinition*>` (Containers.h `ClassNameClassDefinitionMultiMap`), iterated serially
under `-mt 0`. The key comes from `ResolveSymbols::createFastLookup`: `<package>::<class>` for a package class
(`StrCat(pkgname, "::", name)`) and `<lib>@<module>::<class>` for a module class (`StrCat(fullName, "::", name)`,
fullName = `work@<module>`). Nested classes never enter the map before compile, so a nested class compiles inside
its outermost class. r11u216's pair order (package name, then class name, module classes last) agrees with the key
order only in two conditions:

* no package name is a prefix of another followed by a character below `:`;
* no package name sorts after `work@`.

**Faces** (golden, pristine, law), all in [cases/T](cases/T):

| case | shape | golden writer | r11u216 | pristine |
|---|---|---|---|---|
| t01 | packages `p` (own) and `p2` | `p::K` (key `p2::M` < `p::K`) | `p2::M` (line, 13 records) | declaration (line) |
| t02 | outside package `zq` + a module class | `zq::N` (`work@top::M` < `zq::N`) | `M` (line) | declaration |
| t03 | own `p1`, outside `p` | `p::M` (`p1::K` < `p::M`) | `p1::K` (line) | declaration |
| t04 | own `x_pkg` + a module class | `x_pkg::K` | `M` (line) | declaration |
| t09 | nested `q::Z::A` beside `q::M` | `A` (compiled inside `Z`) | `M` (line) | declaration |
| t11 | t01 split over two files | `p::K` | `p2::M` (file) | declaration |
| t12 | t01 in a CRLF file | `p::K` | `p2::M` (line) | declaration |

**Law.** When § tfArgOutsideClassOrder216 fires, the last class writer is the maximum of the Surelog key: the
package or `work@<module>`, then `::`, then the outermost class of the writer, with ties broken by source order.
Where the pair order and the key agree, the bytes are unchanged: r11u216's grid gives 0 of 124 case-views
moved, and MiniAmiq gives `svaunit_pkg::*` < `uvm_pkg::*` under both orders.

### 2.2 § rqParamOpBoundAtCall216v (ModuleEmit.cpp `rqFoldMake216`, both fold laws; `R11V216_PARAMOPLOC_OFF`)

**Faces.** A PARAMETER operand with an arithmetic bound gives golden's constant at the query call. For example,
`parameter logic [W-1:0] P` read by `$high(P)` reads 3:18-3:26 = the `$high(P)` span, INT:<v>, and `[W+2:0]` gives
UINT:<v>. r11u216 located it at the left operand `W`, as it does for a net's typespec bound. The value, size and
encoding are unchanged. The fix relocates only this case; net and variable operands keep the left operand
(r11u216's g06, g15, n05 and n08 unchanged).

| case | shape | pristine | r11u216 | fix |
|---|---|---|---|---|
| f21 | child `parameter logic [W+2:0] P`, instance twice, gen-for | stage 1 | line (2 records) | EQUAL |
| f22 | child net initializers `$high(P)` `[W-1:0]`, `$right(Q)` `[0:2*W]`, instance twice | stage 1 | line (4) | EQUAL |
| f23 | module parameter `[W-1:0]` and localparam `[W+1:0]` in a gen-if | stage 1 | line (2) | EQUAL |

### 2.3 Switch reach (bytes, both views, [evidence/switches.txt](evidence/switches.txt))

* `R11V216_CLSKEY_OFF` writes r11u216's bytes on the 14 T case-views the refinement moves and leaves the 6 F movers
  at the fix's bytes.
* `R11V216_PARAMOPLOC_OFF` does the reverse.
* `R11V216_OFF` writes r11u216's bytes on all 76 case-views of this directory and on all 124 of r11u216's
  (`VOFF=law.bin` in both grids).
* `R11U216_OFF` still gives pristine bytes on all 200 case-views (`OFF=pristine`), because both refinements live
  inside r11u216's laws.

## 3. The fresh grid ([cases/](cases), 38 cases x 2 views = 76 case-views; [evidence/grid_TF.tsv](evidence/grid_TF.tsv))

Each case names its law on its first line. t11 is two files, listed in `args`; t12 is CRLF.

* **T: the writer laws.** t05 is the control where both orders agree. It covers:
  * a parameterized outside class (t06), a macro-written outside class with a qualified formal (t07);
  * module and interface importers with an importer-clone call (t08), an interface class (t10);
  * a packed struct typedef (t13), a program importer (t14), an outside task and a static output formal (t15).
* **F: the fold laws.** It covers:
  * `$size` of int, scalar, enum, packed-struct and integer variables (f01-f04);
  * hex and binary bounds and a shared declarator bound (f05, f12, f13, f15, f16);
  * `pk::W-1` and `$clog2(N)-1` bounds (f06-f08), a loop-body localparam (f09), two packed dimensions (f10);
  * a non-ANSI signed port with two declarators (f11), `$size` of arrays of structs and 2-D arrays (f14);
  * one bound read by a generate query and a net initializer of different widths (f17);
  * interface and generate-scope `$size` cells with the interface instantiated twice (f18);
  * a two-level generate (f19), a negative bound (f20), and parameter arithmetic bounds (f21-f23).

| pristine -> r11u216 -> fix | case-views |
|---|---|
| -> EQUAL -> EQUAL | 40 (f01 f03 f04 f06-f11 f15-f20, t06 t07 t08 t13 t15) |
| -> line/file -> **EQUAL** (the two refinements) | 16 (t01 t03 t09 t11 t12, f21 f22 f23) |
| line -> line -> fullname (the refinement, then r11u216's exposed module-class ref name `work@top::M::p::e_t`, r11u216's w06/w08 face) | 4 (t02, t04) |
| line -> fullname -> fullname (the same face) | 2 (t05) |
| stage 1 -> stage 1 -> stage 1 | 12: f05 f12 f13 the range-bound encoding face (r11u216's g10: golden keeps `4'h7`/`3'b110`/`8'h0A` on the typespec bound, ours `UINT`; the same head object on all three binaries); f14 the 2-D `$size` decline (the head moves later, see residue 3); t10 the interface class listed under package `q`; t14 the program's typedef listing (same head on all three) |
| SLANG_FAIL on all three | 2 (f02: slang rejects `$size` of a scalar) |

**None leaves EQUAL. None moves away from golden:** every r11u216 non-EQUAL record on a mover is rewritten to
golden's value.

**Downstream** ([evidence/ds_TF.txt](evidence/ds_TF.txt), the gate's own `one()`, fresh GOLDEN_CACHE, the 37
single-file cases):
* pristine, law and fix are all IDENTICAL on 30.
* EQUIVALENT -> IDENTICAL on f16, f17, f20, and DIVERGENT -> IDENTICAL on f09, f22 (both under law and fix).
* f14 is DIVERGENT on all three.
* f02 is SLANG_REJECT on all three.
* None moves away from IDENTICAL.

## 4. Gates with the fix binary (sweeps /tmp/v11u216_sF, /tmp/v11u216_dF; [evidence/sweeps](evidence/sweeps))

| stage | fix vs baselines |
|---|---|
| probe | **3410 + 677: regressions 0, conversions 0, changes 0** |
| surelog | **929 + 25: regressions 0, conversions 0, changes 2** (MiniAmiq d/t `file(75)` -> `fullname(61)`, r11u216's § tfArgOutsideClassOrder216 / § tfArgImportCloneFollows216, uhdm-cmp 0 lines) |
| uhdm2rtlil | **1596 + 10: 0 / 0 / 0** |
| downstream | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0**, every verdict equal to the baseline and to the pristine and law sweeps |

* **Movers** ([evidence/movers/byteverify.txt](evidence/movers/byteverify.txt)):
  * fix vs law: surelog 1 / 960, Scoreboard default `5b403f6efc5f` vs `50f1e9cd5845`. This is the known storage-order
    coin: 0 dump lines ordered.
  * fix vs law: uhdm2rtlil 0 / 1608, probe 0 / 4087, downstream lanes 0 / 805.
  * fix vs pristine: MiniAmiq d/t plus the same coin.
* **Wide byte control, fix vs law** ([evidence/wide_law_fix2.txt](evidence/wide_law_fix2.txt)): r11u216's 1287
  earlier case files, both views, 2574 case-views: **0 moved**. The positive control over this directory's cases
  ([wide_positive_control.txt](evidence/wide_positive_control.txt)) flags exactly the 20 case-views of section 2.
* **Prediction:** the refinements fire only where their r11u216 law fires. r11u216's frozen firing census
  (`556a7184`) gives MiniAmiq d/t for the writer law and no corpus row, probe case or lane for the fold laws. The key
  order equals the pair order on MiniAmiq, so the prediction is 0 movers against r11u216, and 0 were observed. This
  prediction was derived from that census and not frozen separately before the fix sweep.
* **Determinism** ([evidence/det_fix2.txt](evidence/det_fix2.txt), three concurrent runs per row-mode):
  * Earlgrey_0_1, SeqDriver, SimpleUVM and BuildUVMPkg: one hash per mode, equal to the sweep.
  * MiniAmiq: `e980a33e2671` / `ae2f0060a863`, the pair r11u216 reported, with dumps identical (0 lines).
  * Scoreboard d: `de42a8e468b9` against the sweep's `5b403f6efc5f`, the svunit listing coin (92 lines ordered,
    0 order-blind).
* **Canaries:** surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 PASS in both
  ([evidence/gates/canaries.txt](evidence/gates/canaries.txt)).

## 5. Composition with the r11u214 decode's law patch (measurement only, [evidence/composition/summary.txt](evidence/composition/summary.txt))

* **Merge:** tools/probe/r11u214dec/law_typeemit.patch applies cleanly at 745f66ab. This directory's src diff then
  applies with `git apply --3way` and no conflict markers. A plain apply fails only at ModuleEmit.cpp's switch
  declarations, where both passes add lines after the r11v209 declarations.
* **Sweep (`comp.bin` `56f06272`):**
  * probe 3430 + 657: 0 regressions, 20 conversions, 35 changes, r11u214's own numbers.
  * surelog 0 regressions and 9 changes: Earlgrey d/t `endcol(39)`, Scoreboard d `endline(111)`, SeqDriver d/t
    `endline(59)` and SimpleUVM d/t `endline(135)` (r11u214's own), and **MiniAmiq d/t `file(75)` -> `endline(59)`**.
    r11u214 alone gives `file(73)`, r11u216 alone `fullname(61)`. The #899 `uvm_severity` record is r11u216's; the
    #10107 `uvm_event_pool` record is r11u214's § classTdAliasLastWriter214.
  * uhdm2rtlil 0 / 0 / 0.
* **Away census (flat, MiniAmiq default):**
  * composition vs pristine: 12 lost, 219 gained, distance 6528 -> 6321.
  * r11u214 alone (`comp.bin` under `R11U216_OFF`): the same 12 lost and 30 gained, distance 6528 -> 6510.
  * The 12 lost records are one generic key: an unnamed, unlocated `ref_typespec` inside a typespec copy. They belong
    to r11u214, whose README ran a raw-full-name census. Whoever lands r11u214 should attribute them. r11u216 adds
    189 gained and 0 lost on top.

## 6. Residues, ranked

1. **Item (0) not done by r11u216:** r11u214's law_typeemit.patch (section 5), plus the 12 flat-census lost
   records to attribute.
2. **r11u216's MiniAmiq head #10107** (the `uvm_event_pool` alias reference named through the importing interface) is
   r11u214's § classTdAliasLastWriter214.
3. **`$size` of a multi-dimensional unpacked array (f14 `logic [1:0] m [2][3]`).** Golden folds it to `UINT:2`, the
   first dimension's count, and § ndaSizeQueryFold216 declines it. It is DIVERGENT downstream on all three binaries.
   Extending the fold is a one-line reach change in `rqSizePlan216` (ModuleEmit.cpp), not written here: pristine is
   stage 1 there too.
4. **The range-bound encoding face** (f05, f12, f13, r11u216's g10). Golden keeps a sized or based bound's own
   encoding on the typespec range (`HEX:7`, `BIN:110`); ours folds it to `UINT`. This is the typespec range emission
   (TypeEmit / ModuleEmit), pre-existing.
5. **The module-scope class reference name** `work@top::M::p::e_t` (t02, t04, t05; r11u216's w06, w08, w18).
6. **The interface-class typedef listing** under the class's package (t10) and **the program's typedef listing**
   (t14): stage 1 on all three binaries, pre-existing.
7. r11u216's own residue list (its README section 5) stands, re-measured on its grid.

## 7. Fence and process

* Every driver that reads corpus sources or databases reads the four fenced names fail-closed from the `FENCED=`
  line of tools/probe/r11u107repro/canaudit.sh: drivers/env.sh, case.sh, det.sh, widebytes.sh, and dsfaces.py (its own
  reader).
* The gate sweeps dispatched every row. No binary, gdb or script ran on a fenced test's sources or databases outside
  them, and a grep of this directory for the four names reads 0.
* The pristine binary was frozen before the first edit. Builds used `-j 2`, and no source was edited while a unit
  compiled.
* Scratch: `/tmp/v11u216_*` and worktrees `/tmp/wt_v11u216`, `/tmp/wt_v11u216pris`, `/tmp/wt_v11u216c`.
* Nothing under results/, tests/ (except the regenerated tests/LAWS.md) or third_party/ was written. No stash, and
  `GOLDEN_DEFER` unset.

## 8. Files

* [cases/T](cases/T) (15 cases), [cases/F](cases/F) (23 cases).
* [drivers/](drivers): env.sh, case.sh (from r11u216repro), grid.sh (+ `VOFFBIN`), switches.sh, dsfaces.py,
  dsrun.sh, det.sh, widebytes.sh (law vs fix).
* [evidence/](evidence): grid_TF.tsv, grid_r11u216.tsv, switches.txt, ds_TF.txt, det_fix2.txt, wide_law_fix2.txt,
  wide_positive_control.txt, sweeps/, movers/, gates/, composition/.
