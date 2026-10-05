# v11u241 — adversarial verification of r11u241

Verifier for pass 241 (module/type ground, brief item (1)). Base `23a9a439`. The worktrees were `/tmp/wt_v11u241`
(base plus the implementer's patch) and `/tmp/wt_v11u241pris` (base); scratch files used the `/tmp/v11u241_*` prefix.

**VERDICT: CONFIRMED. No fix was needed.** Every headline number of r11u241 reproduces bit for bit, with one
arithmetic slip in its README (the away census sums to 3073 records toward golden, not 3134; corrected there).
50 fresh cases (108 case-views, both views) found no break:
- no case-view leaves STRICT_EQUAL or uhdm-cmp equality;
- the chain-keyed away census loses 0 records on all 50 judge-equal case-views;
- every downstream verdict is the same on pristine and law (50 of 50 IDENTICAL);
- `R11U241_OFF` gives pristine bytes on 108 of 108 case-views.

The source of the patch is unchanged. The delivery `/tmp/r11u241.verified.patch` is the implementer's patch plus this
directory, the README correction and the regenerated `tests/LAWS.md`.

## Binaries (built here, frozen read-only before any measurement)
| binary | md5 |
|---|---|
| pristine (`/tmp/wt_v11u241pris`) | `aa9012ebb7b3104475c0e59866e01645` (= main tree's `build/slang-uhdm`) |
| law (`/tmp/wt_v11u241` + `/tmp/r11u241.patch`) | `219ff84f7dff1511eef8b7a819ed2a61` (= the implementer's) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` (= main tree's) |

Every `cmds.txt` of both corpus sweeps names only its own frozen binary: 3273 runs each, `/tmp/v11u241_bin/pristine`
or `/tmp/v11u241_bin/law`.

## Gates reproduced (`tests/sweep.sh --jobs 3`, `SLANG_UHDM` exported, GOLDEN_DEFER unset)
| stage | pristine | law (vs results/) |
|---|---|---|
| probe | EQUAL 3480 + 607, 0/0/0 | EQUAL 3481 + 606; regressions 0, conversions 1, changes 6 |
| surelog | 0/0/0 | regressions 0, conversions 0, changes 9 |
| uhdm2rtlil | 0/0/0 (1606 + 0) | 0/0/0 |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0; verdict diff 0 vs results/; 0 rows differ from the pristine sweep |

- **Probe conversion** (results/ untouched): `CONVERSION r10v182repro/v182_g_names STRICT_NOTEQUAL differ:fullname(36) -> EQUAL`
  (§ cloneLocalArrayTsParented241).
- **The six probe changes**, the same as the implementer's: g180_a_kinds, g193_c_argface, g193_d_propfence, g207_c_share,
  t42a and v181_h_nofe.
  - g207_c_share's count grows from 13 to 16 on the same first record, #152.
  - Its walk divergence moves later, from `#269 type` in pristine to `#335 type` in law.
  - The chain away census is 0 lost and 60 toward.
- **The nine surelog changes**, the same as the implementer's:
  - BuildUVMPkg d/t `line(16) -> file(8)`;
  - Scoreboard d `file(11) -> fullname(3)`;
  - SimpleUVM d/t `line(8) -> line(4)`;
  - MiniAmiq d/t `fullname(8) -> fullname(4)`;
  - SeqDriver d/t `fullname(8) -> fullname(4)`.
- **Row-by-row csv, pristine sweep vs law sweep:** only these 9 surelog rows and 7 probe rows differ, plus the two
  LowMem detail texts (environment). There are no uhdm2rtlil or downstream row changes.
- **Gate exit code:** `tests/sweep.sh` exits 1 on both trees only from `law_index.py --check`. At the base commit,
  `tests/LAWS.md` lacks that commit's own hash, so a fresh worktree of 23a9a439 also reads STALE.
- **Fresh first records** (`evidence/uvm_heads_law.txt`), as the implementer quotes them:

| row-mode | first record | golden (A) / ours (B) |
|---|---|---|
| BuildUVMPkg d/t | #81827 file | `begin uvm_port_component::get_connected_to` at 45157:26 / ours unlocated |
| Scoreboard d | #81633 fullname | `...write::predict_info.addr[]::addr::addr` / `...write::addr` |
| SimpleUVM d / t | #75572 / #75584 line | `m_parent` net at 1001:10 / 1925:11 |
| MiniAmiq d/t | #71388 fullname | `int_var` in `svaunit_pkg::uvm_table_printer::emit`, ours `...::emit::q` |
| SeqDriver d / t | #71344 / #71356 fullname | the same face, in `adpcm_pkg` |

## Byte movers, prediction, census
- **byteverify** on fence-filtered hard-link mirrors (`drivers/bvmirror.sh`, 8 fenced paths skipped by name only):
  PATH_SETS_IDENTICAL, MOVERS 9 / 2560, SELFCHECK 2559 / 2560 (`evidence/byteverify.txt`). The hashes are equal to the
  implementer's.
- **Probe movers:** 12 (`evidence/probe_movers.txt`), the same 12 names as the implementer's.
  - The pristine side must come from a probe sweep run in the LAW worktree (`/tmp/v11u241_wQ`). A probe database
    embeds the absolute source path, so a pristine sweep from another worktree shows 785 false movers.
- **Prediction:** the implementer's `evidence/predict.txt` names exactly these 21 databases (9 corpus + 12 probe).
- **Away census** (`r11u241repro/drivers/awayrows.py`, chain key, variant comparator built here):
  - 21 databases, away 0 on every one, toward 3073 (`evidence/away.txt`, identical line for line to the implementer's).
  - Flat-key losses: MiniAmiq 30, SeqDriver 20, v181_h_nofe 1. The v181 record was decoded: golden holds 13 copies of
    `trebuchet_imp::trebuchet_home::springald_t::onager`, pristine 17 and law 12.
  - The 4 pristine surplus records sat in copies where golden names through the copy's chain. The law gives those
    copies their own chain, so the flat key counts an extra pristine record as "lost". No record is lost at its
    chain position.
- **Canaries:**
  - surelog ok=45 changed=7, the seven predicted UVM canary row-modes;
  - u2r ok=16 changed=0;
  - ctcan2 surelog PASS (ok=58, unknown 1), u2r PASS (ok=2, unknown 6) (`evidence/canaries.txt`).
- **Determinism** (`drivers/det.sh`, three CONCURRENT harness runs with the law binary on Earlgrey_0_1 and the five UVM
  rows, both modes): one hash per row-mode, equal to the law sweep's and to the implementer's (`evidence/det_law.txt`).

## Implementer's grid reproduced
`r11u241repro/drivers/grid.sh` with these binaries: 666 lines, all carrying rc.
- The verdict, cmp line count and rc agree on 666 of 666. md5s differ only through the embedded worktree path.
- rc=4 occurs on TD d05 and d08 on every binary, including pristine.
- 74 case-views: `R11U241_OFF` gives pristine bytes on 74 of 74; 22 enter STRICT_EQUAL and none leave.
- Switches changing the law's bytes: TPDEFLOC 18, TPDEFCLSNAME 4, CLONEARRTS 18, CLONEAGGLOC 24, CLONEAGGCOPY 22,
  CLONEAGGMEMB 16, as the implementer reports.
- TD d05 is stage 1 on both binaries. Its cmp head moves from the law's class_typespec face to the module-scope
  `typedef p::drv#(...)` face, which is unsupported (rc 4) on pristine as well.

## Attack grid (`drivers/grid.sh`, `evidence/grid.txt`, `evidence/grid_summary.txt`)
50 fresh cases, both views, 9 configurations each (pristine, law, law + `R11U241_OFF`, law + each switch): 972 lines,
every one `rc=0`. Totals over 108 case-views:
- `R11U241_OFF` gives pristine bytes on 108;
- 39 enter STRICT_EQUAL;
- 0 leave STRICT_EQUAL;
- 0 leave uhdm-cmp equality.

Away census on every case-view that is judge-equal on both binaries (`drivers/caseaway.py`, `evidence/away_cases.txt`):
50 case-views, chain away 0 on all 50, toward 1025.

Downstream (`drivers/dscase.py`, the HEAD harness's `one()`, `evidence/ds_{pristine,law}.txt`): 50 of 50 IDENTICAL on
both binaries. This includes packed-struct and enum package functions reached from module logic through `export`
(AG g01, g02, g11).

| family | cases (law named in each first line) | what it attacks | result |
|---|---|---|---|
| § tpPropDefaultLoc241 | TP t01 qualified default `o::item`; t02 a default split over two lines, module-scope `p::drv#(p::item,p::item)`; t03 a macro default plus a class member specialization; t04 CRLF; t05 `$unit` with a non-default typedef first; t06 `extends drv#(R,R)` plus `drv#(item)`; t07 the class from a header included in two packages; t08 a value parameter before the type parameters; t09 an alias `item_t` as the argument; t10 an interface-class default; t11 the specialization only through `extends`; t12 a nested class `outer::inner`; t13 a module variable `drv#(item,item)` beside `drv` | header vs specialization location in every context | 18 of 26 case-views STRICT_EQUAL under the law (t02 and t09 from stage 1 at the base). Three cases stay stage 1 on faces already present at the base: t05 (a `$unit` typedef of a specialization listed under the design), t10 and t12 (golden writes an interface-class or nested-class property as a logic_var). In all three the law moves the RHS class_typespec to the header location (4:24, where pristine had the typedef argument 10:15), as in the converted cases. t13 is unmoved: its default is already the walked one. |
| § tpClsDefaultAtClassName241 | TC c01 named argument `base #( .W(2) )`; c02 spaces and a newline before `#(`; c03 package-qualified `o::base #(2)`; c04 nested `base #(inner #(3))`; c05 `$unit` with a module variable; c06 module-scope specialization; c07 two value/type arguments plus a named-type argument | end at the class name | 12 of 14 case-views STRICT_EQUAL under the law (c06 from stage 1). c05 stays stage 1 on a pre-existing module-variable face. |
| § cloneLocalArrayTsParented241 | AR r01-r16: queue, dynamic, `[string]`, `[*]`, `[qc]`, `[e_t]` and bounded queue locals; a nested begin; a macro-written declaration; a 2-D dynamic; a typedef'd queue; a static method; two importers; CRLF; a foreach in the copy | parenting of the copy's array_typespec, and its guard | r10 and r12_el enter STRICT_EQUAL. r09 (dynamic + foreach) stays `fullname`: the guard abstains, and that abstention is the residue. The other cases are stage 1 at the base on pre-existing faces (free package functions, unused package typedefs listed with vpiInstance = the importer, bounded queue, class-index assoc). |
| § cloneAggTsAtHomeListing241 / § cloneAggLocalOwnCopy241 / § cloneAggMemberOwn241 | AG g01-g18: packed struct, enum and packed union formals, locals, returns, nested begins, tasks with output/ref formals, two importers, a same-named `k_t` in two packages, typedefs from an include, a formal written in a macro, CRLF, nested struct members, `s2_t` alias, a tagged union, two struct formals of one type, an array of structs, `export` | relocation, private copies, member copies | g08, g16 and g17 enter STRICT_EQUAL in both views. g05, g09, g11, g14 and g15 stay STRICT_NOTEQUAL with chain away 0. See the notes below. The other cases are stage 1 at the base. |

Notes on the AG cases that stay STRICT_NOTEQUAL. None of them is a law error; each is a pre-existing face that the
walk now reaches:
- **g11** `line -> depth`, objects 429 -> 537 of golden's 501, first record #70 -> #251, chain away 0, toward 83.
  - The new head is q's own `g(s_t x)` passing x to `f1`. Golden's `ref_obj x` binds f1's formal typespec (4:37,
    evalFunc's re-point); ours, on pristine as well, binds g's own formal typespec (11:36).
  - The members under it are now listed because the shared member set was first listed there once the copy took its
    own members.
- **g14** `line -> fullname`: a nested member's member, `row.r.hi`, still reads the shared `in_t` member. This is the
  implementer's residue 5.
- **g15** `line`: an enum typespec under a copied struct member keeps the member type's location. That is the shared
  member type, a face already at the base.
- **g05 and g09** `fullname`: the home-side member reference full name, `work@top.p::s_t.a` vs ours `p::p::s_t::a`.
  This is the implementer's residue 6.

`VpiTagged` is not carried by the law's union copy. Neither Surelog nor this exporter ever writes `VpiTagged`, so the
omission is latent.

## Ranked residues (verifier's view)
1. MiniAmiq / SeqDriver #71388 / #71344: the nested-block fixed array in a copy (StmtEmit, ground A).
2. BuildUVMPkg #81827: an unlocated foreach body `begin` (StmtEmit, ground A).
3. Scoreboard #81633: hier_path member naming (ExprEmit, ground A).
4. SimpleUVM #75572: the implicit-net mint (the sister pass r11u240).
5. § cloneLocalArrayTsParented241 abstaining when a home foreach binds the copy's array_typespec (AR r09; StmtEmit
   `arrayVarArrayTs` binds the last emission's object, sister ground).
6. Member paths deeper than one level and member types inside copied aggregates (AG g14, g15).
7. Home-side member ref full names (AG g05, g09).
8. evalFunc's actual-to-formal typespec re-point on a package function's own formal passed on (AG g11). This is the
   § modportArgVarFormalTs239 family, outside modports.
9. Stage-1 faces at the base: unused package typedefs listed with the importer as vpiInstance; interface-class and
   nested-class properties (TP t10, t12); a `$unit` module variable of a specialization (TC c05); bounded queue and
   class-index associative locals in copies; free package functions copied into importers. Plus brief items (2)-(5)
   and (7), not attempted by the pass.

## Drivers (`drivers/`; each reads $FENCED fail-closed; paths resolve from this checkout)
- `env.sh`, `case.sh`, `det.sh` and `bvmirror.sh` are copied from r11u241repro.
- `grid.sh` is adapted to run the cases 3-parallel.
- `gridsum.py`, `caseaway.py`, `dscase.py` and `heads.sh` are written for this pass.

## Process
- The pristine and law binaries were both built and frozen before any measurement. No source was edited.
- The two corpus sweeps ran concurrently; the downstream sweeps ran one at a time under a lock.
- No fenced test was dispatched, read or opened outside the gate sweeps:
  - corpus databases were reached only through mirrors and row lists filtered by $FENCED before opening;
  - `heads.sh` and `det.sh` refuse a fenced name.
- No pgrep or ps listing was run.
- One `grep -lwE "$FENCE_RE"` over this pass's own two repro directories ran before the variable was set. It matched
  every file of those directories and read nothing else. It was rerun with the variable set: clean.
