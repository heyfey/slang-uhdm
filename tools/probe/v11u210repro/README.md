# v11u210 — adversarial verification of r11u210 (the expression/parameter ground: § elabIfArrIdxChainName205, § elabIfArrIdxExprChainName210, § memLeftReadsPatUnlocated210, § pkgTopWidePatReplTsName210, § caseItemImpWildParamScopeName210, § pkgImpParamMemberColons210, § pkgImpParamAliasColons210, § landingSwitchReach210): CONFIRMED without a fix — every headline number reproduced bit for bit, 36 fresh cases (72 case-views) and a 12970-directory byte census found no record moved away from golden, no status leaving EQUAL and no downstream change

**Base.** `62ac216e` (branch matrix-1.87). Two fresh worktrees: `/tmp/wt_v11u210pris` (pristine) and `/tmp/wt_v11u210`
(`/tmp/r11u210.patch`, md5 `0865c47a26ffdb78a45b04d950158aaa`, applied clean with `git apply`). Scratch `/tmp/v11u210_*`.
The implementer's worktree, binaries and scratch were read only. No source file was edited: the verified patch is the
implementer's patch plus this directory and the regenerated `tests/LAWS.md`.

**The fence.** Every driver here reads the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` in the main repository and fails closed (`vcase.sh`, `dscase.py`, `ctlmove.sh`,
`det.sh`, `awaycorp.sh`, `switchreach.sh`, `uvmdist.sh`; `bvmirror.sh` needs `FENCED` exported and refuses without
four names). The byte comparison ran on fence-free hard-link mirrors (`fenced_skipped=8`). The wide byte census list
was fence-filtered (0 hits in 12970 directories). The gate sweeps dispatched every row; their csv verdicts are the only
fenced facts cited: 0 fenced rows changed between the pristine and law csvs. No fenced source, database or head was
read, run or decoded. No gdb.

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u210_bin` before any measurement)

| binary | md5 | built from |
|---|---|---|
| `pris.bin` | `6292e702987d24e3bdb63e4f4938a601` | `/tmp/wt_v11u210pris` at `62ac216e`: byte-identical to the main tree's `build/slang-uhdm` |
| `law.bin` | `4863a1d4d9f51ee9e4d9dcea212fda3b` | `/tmp/wt_v11u210` = `62ac216e` + `/tmp/r11u210.patch`: **the implementer's `law12.bin` md5, reproduced from a fresh worktree** |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's and the pristine worktree's build |

`cmds.txt` audit ([evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt)): 3323 `cmds.txt` per sweep, 3273
`slang:` lines each, every one naming `pris.bin` (pristine sweep) or `law.bin` (law sweep).

## 2. The gates, reproduced (`tests/sweep.sh --jobs 3`, all four stages)

| gate | pristine `/tmp/v11u210_swP` | law `/tmp/v11u210_swL` |
|---|---|---|
| law index | current | current |
| probe | EQUAL 3370 / STRICT_NOTEQUAL 717, `regressions=0 conversions=0 changes=0`; `probe.csv` byte-identical to `results/golden_probe.csv` | **EQUAL 3373 / 714, `regressions=0 conversions=3 changes=0`** |
| surelog | 464 + 16 / 460 + 14, `0 / 0 / 0` | **465 + 15 / 461 + 13, `regressions=0 conversions=2 changes=3`** |
| uhdm2rtlil | 798 + 5 both modes, `0 / 0 / 0` | **798 + 5 both modes, `regressions=0 conversions=0 changes=2`** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **the same; `downstream.csv` byte-identical to the pristine sweep's** |
| SWEEP_RC | 0 | 0 |

The fresh rows (law sweep; `results/` untouched):

    FuncStructValSimple,default,CMP_EQUAL,,,equal        (was STRICT_NOTEQUAL differ:file(39))
    FuncStructValSimple,testflags,CMP_EQUAL,,,equal      (was differ:file(59))
    FuncStructVal,default,STRICT_NOTEQUAL,differ:endcol(7)       (was endcol(95))
    FuncStructVal,testflags,STRICT_NOTEQUAL,differ:endcol(10)    (was endcol(165))
    InterfArrayBind,default,STRICT_NOTEQUAL,differ:fullname(1)   (was fullname(3))
    ibex_tracer,default|testflags,STRICT_NOTEQUAL,differ:fullname(13)   (was fullname(579), uhdm2rtlil)
    r11u114repro/grid/f2/b02,EQUAL,,equal
    v11u111repro/brk/f5/x57_case_item,EQUAL,,equal
    v11u114repro/grid/set1/e04,EQUAL,,equal

The only other csv lines that differ are LowMemLib and LowMemPkg testflags' SURELOG_FAIL detail text, which carries the
workdir path ([evidence/sweeps/csv_diffs.txt](evidence/sweeps/csv_diffs.txt)).

First records after the laws, quoted from `uhdm-strictcmp --max 2`:
* FuncStructVal d: `#747 endcol` (the `config_pkg::NOC_TYPE_AXI4_ATOP` ref, golden 106:16-28, ours 106:16-46). It is
  `#746` at the base, so the record is unchanged. Then `#4782 file`: golden's `INT:2` leftover at 618:22-45, ours
  unlocated, where the base had it at the call span. That is the implementer's R2, count-neutral.
* InterfArrayBind d: `#183 fullname` (golden `work@soc_tb.peripheral_io_bus[IO_ONES].write_en.IO_ONES`, ours
  `work@soc_tb.IO_ONES`). This is R5, the sister's.
* ibex_tracer d: `#27582 fullname` (a module-listing `ref_typespec`, golden bare, ours `work@ibex_tracer`). This is R1.
  At the base the first record was `#2073`.

**The r11u205 law alone.** `law.bin` with the six other R11U210 switches set writes the full binary's InterfArrayBind
bytes in both modes (`790bf69df6f3` / `5943d70cb91b`): default `differ:fullname(1)`, testflags CMP_EQUAL.

**Canaries**, against the committed baselines:
* `canaries.sh`, surelog csv: pristine `ok=52 changed=0`, law `ok=50 changed=2`. The two changes are exactly the named
  FuncStructVal d/t CHANGE.
* `canaries.sh`, uhdm2rtlil csv: `ok=16 changed=0` on both.
* `EXPECT_UNKNOWN=1 ctcan2.sh`, surelog: PASS `ok=58` on both.
* `EXPECT_UNKNOWN=6 ctcan2.sh`, uhdm2rtlil: PASS `ok=2` on both.

## 3. The byte movers and their attribution

| where | compared | movers | predicted by r11u210's frozen census | unpredicted |
|---|---|---|---|---|
| corpus (`byteverify.sh`, `SELFCHECK=1`, mirrors) | 2560 | **9**: BlackBePipeInt d/t, FuncStructVal d/t, FuncStructValSimple d/t, InterfArrayBind d, ibex_tracer d/t | 9 of 9 | 0 (no coin in this sweep pair) |
| probe (4087 databases) | 4087 | **3**: the three conversions | 3 of 3 | 0 |
| downstream slang lanes (fence-filtered) | 805 | **1**: ibex_tracer (IDENTICAL on both) | 1 of 1 | 0 |

* **The predictor.** The implementer's `evidence/predicted_movers.txt` still reads md5 `6ddcf389...`, the value
  recorded in `predicted_frozen_at.txt`. Its 13 rows are exactly the movers above. The implementer's law sweep
  directory was created at 14:33:16.400 EDT, after the census's last write at 14:33:16.364: the prediction was frozen
  before the law sweep, as claimed.
* **Probe databases.** The raw bytes carry the source path, which includes the worktree name. So each probe pair was
  compared on its uhdm-dump with the worktree root replaced by a token (`drivers/probecmp.sh`). The three movers found
  there are themselves the positive control.
* **SELFCHECK 2559 / 2560 is the pass value.** `byteverify.sh` compares every patched database against the pristine copy
  of one fixed path (the first in sort order). That path is not a mover, so exactly one comparison reads equal. The
  check fails only below `N - 1`.
* **Every switch reaches pristine.** `R11U210_OFF=1` on `law.bin` writes pristine bytes for all 10 corpus mover
  databases and all 3 probe movers.

### Away-moved-record census (map 12's method; `drivers/awaycorp.sh`, [evidence/away/](evidence/away))

| mover | strict records: dist pristine -> law, LOST, GAINED | uhdm-dump lines: LOST, GAINED, added-not-in-golden |
|---|---|---|
| FuncStructVal d / t | 532 -> 30, **0**, 502 / 879 -> 53, **0**, 826 | **0**, 78, 0 |
| FuncStructValSimple d / t | 39 -> 0, **0**, 39 / 59 -> 0, **0**, 59 | **0**, 11, 0 |
| InterfArrayBind d | 3 -> 1, **0**, 2 | **0**, 4, 0 |
| ibex_tracer d / t | 407 -> 19, **0**, 388 | **0**, 646, 0 |
| BlackBePipeInt d / t | 16907 / 17132 unchanged, **0**, 0 (the names sit inside canonicalised typespec copies) | **0**, 27216, **0** |

**Positive control** (`CONTROL=1`: the binaries swapped). LOST then equals the forward GAINED on every row, for
example FuncStructVal d 502, ibex_tracer 388 and BlackBePipeInt 27216 dump lines. The dump-line census confirms the
implementer's BlackBePipeInt claim: every line the law writes is in golden's dump, and none it removes is.

## 4. Determinism, distances, switch reach

**Determinism** ([evidence/determinism/](evidence/determinism), `drivers/det.sh`: three concurrent harness runs).

With `law.bin`, every row-mode reads one hash across the three runs except two:

| row-mode | hashes | reading |
|---|---|---|
| Earlgrey_0_1 d / t | `15e6e48bc148` / `e449573deea9` | one per mode |
| MiniAmiq, SimpleUVM, BuildUVMPkg, BlackBePipeInt, FuncStructVal, FuncStructValSimple, InterfArrayBind (both modes); SeqDriver t | one each | stable |
| Scoreboard d | `498cfef0` / `24ba24eb` | Ordered dumps differ, sorted dumps identical: the known svunit listing coin. Pass 207's own pristine determinism runs drew `498cfef0` (`tools/probe/r11u207repro/evidence/determinism/det_runs.txt`), so it is not this pass's coin. |
| SeqDriver d | `05bc4252` / `2b98a36a` | Identical uhdm-dumps (storage order only). Map 13 recorded the same second-hash phenomenon on law binaries. No law fires on SeqDriver: the census predicts none, and it is not a byte mover in the sweep pair. |

With `pris.bin` (three runs of the UVM rows), SimpleUVM d draws two hashes, `efa957a0` / `09716ef0`. That is the draw
the implementer attributed to the pristine binary, and it is confirmed.

**UVM order-blind distance** (`drivers/uvmdist.sh`, [evidence/away/uvmdist.txt](evidence/away/uvmdist.txt)). Identical in
both sweeps, reproducing the implementer's figures: MiniAmiq 14920, SeqDriver 11094, SimpleUVM 3946, Scoreboard 2937,
BuildUVMPkg 1477, ApbSlave 0, SVSwitch 0.

**Switch reach** (§ landingSwitchReach210; `drivers/switchreach.sh` over r11u201repro, v11u201repro and r11u200dec,
[evidence/switches/](evidence/switches)):
* `R11U210_LANDING201_OFF` writes the same bytes as `R11U201_OFF R11V201_OFF R11U200_NEWARRHP_OFF R11U200_UNITFOLD_OFF
  R11U200_FOLDDEPTH_OFF R11U210_GENBITS201_OFF` on **210 of 210 case dirs in both views**.
* It moves 106 dirs away from the switch-free bytes; the old `R11U201_OFF R11V201_OFF` moves 69 (parse) / 83
  (`--elabuhdm`).
* The four extra directory names in the raw listing are one directory with two root files and no `args` file. It
  writes no database in any state.
* The source confirms the enumeration: `r11u201On` / `r11v201On` are read only in ExprEmit, and the r11u200 switches of
  landing 201 are `R11U200_NEWARRHP_OFF` (ExprEmit ×2), the ExprEmit `R11U200_GENBITS_OFF`, and `R11U200_UNITFOLD_OFF` /
  `R11U200_FOLDDEPTH_OFF` (ParamEmit). UhdmExporter names them only in comments.

**Reach table after integration (new finding).** HEAD `6dcc0818` carries pass 209's r11u205 ground-B laws. Their gate
(`r11u205Law` in UhdmExporter.cpp) reads `R11U205_OFF` and `R11U209_OFF`. Once this patch lands, `R11U205_OFF` drops
**both grounds'** r11u205 laws: pass 209's three and § elabIfArrIdxChainName205. This is the same cross-ground reach
r11u208 reported for `R11U200_OFF`. The per-landing switches stay exact: `R11U210_OFF` drops this landing (including
its r11u205 law), and `R11U209_OFF` drops pass 209's.

| switch | drops |
|---|---|
| `R11U210_OFF` | this landing's seven laws, including § elabIfArrIdxChainName205; pristine bytes on every case, corpus mover and probe mover measured |
| `R11U205_IFARRIDX_OFF` | § elabIfArrIdxChainName205 alone |
| `R11U205_OFF` | at `62ac216e` + this patch: § elabIfArrIdxChainName205; after integration on HEAD: also pass 209's `R11U205_PORTDECLTS_OFF`, `R11U205_GENIDXSEL_OFF`, `R11U205_IPSNAME_OFF` laws (cross-ground) |
| `R11U210_LANDING201_OFF` | landing 201's whole ground-A state (measured above) |
| `R11U210_GENBITS201_OFF` | the ExprEmit half of § genBlockBitsKeepsSelect200 |

**Per-switch checks** on the fresh cases ([evidence/switches/switch_alone.txt](evidence/switches/switch_alone.txt)):
* Each law's own switch restores pristine bytes on every case where that law alone fires: CASEWILD on vc02 and vc07,
  IFARRIDX and `R11U205_OFF` on va01 and va06, MLPATLOC on vm02, PKGREPLTS on vw01 and vm03, PKGIMPCOLON on vp01 and
  vp06, PKGIMPALIAS on vp03 and vp05, both views each.
* Where two laws fire, each switch alone leaves the other law's bytes, and both switches together restore pristine:
  va03 (IFARRIDX plus IFARREXPR), and vm04 (`file(15)` with MLPATLOC off, `fullname(14)` with PKGREPLTS off,
  `fullname(26)` = pristine with both).
* `R11U210_OFF=1` restores pristine bytes on all 72 fresh case-views
  ([evidence/switches/r11u210_off_all_cases.txt](evidence/switches/r11u210_off_all_cases.txt)).

## 5. Breaking the laws: fresh cases (cases/, 36 directories, 72 case-views)

Every case is judged against a pinned Surelog v1.87 golden in two forms: the probe form, and `-elabuhdm` /
`--elabuhdm`. Each one is checked four ways:
* by uhdm-cmp;
* by uhdm-strictcmp's canonical `differ:<field>(<n>)`;
* by the uhdm-dump line census `drivers/dumpaway.py` (indentation-aware, plus `--flat`) and, for member leftovers, the
  object-aware `drivers/leftovers.py`;
* by the downstream gate's own `one()` on both binaries (`drivers/dscase.py`).

Full table: [evidence/grid/grid.tsv](evidence/grid/grid.tsv). Firings from `R11U210_TRACE`:
[evidence/grid/traces.txt](evidence/grid/traces.txt).

**Totals.**
* 50 of 72 case-views move, and every mover carries a traced firing.
* **13 convert to EQUAL; 0 leave EQUAL.** Two more shrink: vc05 `fullname(6/4) -> (2)`, vm04 `fullname(26/35) -> (3/2)`.
* **0 dump lines lost** on every mover in the structural census. The object-aware leftover census also reads 0 lost.
* Downstream: **36 of 36 cases give the same verdict on both binaries, and the slang lane's `_nohier.il` is
  byte-identical in all 36.**

| law | fresh cases (the law named on each case's first line) | result |
|---|---|---|
| § elabIfArrIdxChainName205 / § elabIfArrIdxExprChainName210 | va01 (a GENERATE-BLOCK array `g[i].a` and an instance array `c[j].w`), va02 (a PARAMETER index in if/case generate scopes), va03 (a concatenation left side, a parameter inside an expression index), va04 (x/z, `'0`, a negative and a cast literal, if-in-case generate), va05 (double parentheses, a parameter-driven sibling), va06 (a module-instance array's net), va07 (leaf bit/part selects, a nested interface in the element), va08 (in a for-generate inside an interface body), va09 (a 2-D interface array), va10 (control: always_comb and a net right side), va11 (a leaf module at depths 1-3) | va01, va06, va11 parse convert. va04, va05, va07, va08, va09 gain golden lines at stage 1. The law is right on generate-block and instance arrays, not only interface arrays. |
| § caseItemImpWildParamScopeName210 | vc01 (a function of another package), vc02 (an interface body), vc03 (a class method in the module), vc04 (a static method of a class in another package), vc05 (explicit imports, an always_ff named block, a nested case), vc06 (a task in an if-generate, an always_comb in a for-generate), vc07 (casex at depths 1-2), vc08 (control: `case inside`), vc09 (a plain wildcard literal), vc10 (a `$unit` import), vc11 (reached through an exporting package) | vc02, vc03, vc07 convert in both views; vc05 shrinks; vc04 keeps its structural record; vc06, vc10, vc11 gain at stage 1; vc01 and vc08 do not fire. |
| § memLeftReadsPatUnlocated210 | vm01 (a module-local pattern actual), vm02 (reads through `$clog2` and a comparison chain; the result read in a port width and a generate condition), vm03 (a nested member read), vm04 (a pattern formal beside a scalar formal; a module localparam reads the result) | vm02 converts in both views; vm04 shrinks; vm01 does not fire (no recorded pattern actual). |
| § pkgTopWidePatReplTsName210 | vw01 (two replication members, read whole), vw02 (read only as an instance override), vw03 (read only in another package's function), vw04 (a nonzero replication value and a product count) | vw01 converts in both views; vw02 and vw04 gain at stage 1; vw03 does not fire (residue F4). |
| § pkgImpParamMemberColons210 / § pkgImpParamAliasColons210 | vp01 (three package levels, a nested struct), vp02 (explicit single-name imports), vp03 (wildcard import plus `export ap::*`, read in a function), vp04 (a packed array of structs), vp05 (an enum-typed and a signed vector-typedef parameter), vp06 (the importing package reads the struct and a union) | every firing view gains golden lines (6-20) with 0 lost; all six are stage 1 at the base; vp04 does not fire. |

The implementer's 28 cases re-judged with these binaries reproduce every grid verdict (c01-c04, i01, i02, m01, m02,
m04, m05, q04, w02 and w03 convert; p01 and p05 32 -> 2; p04 -> `file(3)`; m03 -> `depth(1)`; m06 elab
`file(50) -> fullname(24)`). All read 0 dump lines lost. Downstream matches the implementer's summary on every case:
25 IDENTICAL, c05 and q02 STATUS_DIFF, c06 EQUIVALENT ([evidence/downstream/](evidence/downstream)).

### 5.1 The wide byte census (`drivers/ctlmove.sh` over every case directory under tools/probe at `6dcc0818`: 12970 dirs, both views)

**Scale.** The implementer's control list held 2190 directories and read 4 / 2 movers. The wide census reads **52 movers
in the parse form and 49 under `--elabuhdm`** (52 distinct directories).

**Every mover judged against golden** ([evidence/byte_controls/movers_judged.tsv](evidence/byte_controls/movers_judged.tsv)):
* **50 directories carry a firing, and `R11U210_OFF` restores pristine bytes on every one.**
* **Firings by law:** § memLeftReadsPatUnlocated210 32 directories (mostly r11u58/r11u59/r11v58/r11v59 evaluator-bail
  grids), § pkgImpParamMemberColons210 13, § pkgImpParamAliasColons210 2, § pkgTopWidePatReplTsName210 3,
  § elabIfArrIdxChainName205 3.
* **7 case-views convert:** r11u169repro ml/m18 elab, r11u177verify M/m09 elab, r11u205dec IA/a02 and a05 parse,
  r11v163repro rc/f03 both views, v11u144repro hg/x5 parse.
* **One shrinks:** r11v163repro ip/e02 `fullname(9) -> (1)` in both views.
* **None leaves EQUAL, and the structural dump census reads 0 lost on all.**

**The `--flat` census reads 2-4 "lost" lines on 22 memLeft / PKGREPLTS directories.** Each is a same-content line of a
*different* object: golden's `param_assign` right side at the call span, or a bare `ref_typespec:` of another
reference. So the object-aware `leftovers.py` census was run on all 22, and it reads **0 leftovers lost** on every one.
Examples:
* r11v59repro xv2_w63: golden's member leftover sits at the pattern element 25:33-36. Neither pristine's call span nor
  the law's unlocated form is golden's.
* r11u11repro a10: golden's elaborated listing parents the replication constant at the operation and names it `p`,
  exactly as the law now writes it.

**The two directories moving without a firing** are r11u196repro V191/qr01 and r11u209repro TW/qr01. `R11U210_OFF`
still moves them, and their uhdm-dumps are identical. This is the rebuild-dependent orphan of the r11u204 twin helper,
which pass 206 found and pass 209 closed at HEAD. It is present at `62ac216e`, and two independent builds of any code
differ there.

**Crash parity.** Every nonzero exit code is the same on both binaries: 203 parse and 207 elab directories with rc 3,
4 or 139. **No new crash, and no crash lost.**

## 6. Findings on the decodes (no break; reported for the next passes)

* **F1 — § caseItemImpWildParamScopeName210's distinguisher.** The law's gate is the value's unknown bits. Golden keeps
  a *reference* in the case item only when the parameter's initializer is concatenation-bearing (the ibex_tracer
  shape `{3'b010, 11'h?, ...}`, the same predicate as § imppCopyOpReadIsRef114's `concatBearing114`).
  * For a plain wildcard literal (`4'b??11`, cases vc09 and the first drafts of vc02, vc05, vc07), golden substitutes a
    **constant** with an importing-scope `ref_typespec`. Ours keeps a reference at the base: stage 1, a pre-existing
    face.
  * The law then renames that reference. The rename is harmless (stage 1 on both, 0 lines lost, RTLIL identical) but
    inert. A future law writing the constant would supersede it.
* **F2 — § elabIfArrIdxChainName205 fires where golden's elaborated view folds the index.** This happens on a parameter
  index (va02: golden `b[1]`, ours `b[P]`) and on a concatenation left side (va03: a different elaborated structure).
  Both are stage 1 on both binaries with 0 lines lost. The names it writes there (`work@dut.g.b[P].w.P`) have no golden
  counterpart either way.
* **F3 — the implementer's byte-control list was narrow.** The wide census adds 46 moving directories with a firing,
  all toward golden or neutral, plus the two rebuild-dependent qr01 directories. It finds 4 more converting case-views
  (r11u177verify M/m09 elab, r11v163repro rc/f03 in both views, v11u144repro hg/x5 parse) and 0 records lost.
* **F4 — § pkgTopWidePatReplTsName210's predicate misses a qualified read inside another package's function**
  (`return vp::S.E;` in vw03). The law does not fire there. The case is stage 1 at the base, so golden's side is
  unmeasured.
* **F5 — cross-ground `R11U205_OFF` after integration** (section 4).

## 7. Ranked residues (the implementer's, re-read, plus this verification's)

1. **R1, ibex_tracer d/t's last 13 records** (`#27582..`, ParamEmit `emitParameters`, the module listing's import-copy
   pattern `ref_typespec`). Confirmed as the first record. Ground A; the row converts when it is written.
2. **R2, FuncStructVal's `INSTR_PER_FETCH` read-site leftover** (618:22-45, `#4782`). Confirmed and undecoded. xv2_w63
   shows the same kind of face: golden locates a bailed member leftover at the pattern element 25:33.
3. **R5, InterfArrayBind d `#183`.** Confirmed: ModuleEmit `emitContAssigns`, sister ground.
4. **F1, F2, F4** (section 6).
5. **R3, R4, R6, R7 and the carried items** (N0540 / N0689, UVM_MACRO_NUMFLAGS, x01 / x02, BlackBePipeInt `#15272`,
   the value encodings, the class_var return predicates, the generate-initializer stamp, anon_struct_packed_dim, map
   12's UVM A families) stand as the implementer reported them. This verification did not reach them.
6. **r11u208's alias cell**: report only, as the implementer says.

## 8. Files

* `drivers/`:
  * `vcase.sh` judges one case with both binaries (`ELAB=1`, `EXTRA_ENV` for the law side, an `args` file honoured).
  * `dumpaway.py` is the dump-line census (`--flat`); `leftovers.py` is the object-aware member-leftover census.
  * `dscase.py` runs the downstream gate's `one()`.
  * `ctlmove.sh` is the wide byte census with rc parity.
  * `probecmp.sh` compares probe databases on path-normalised dumps.
  * Copied from r11u210 and adapted: `bvmirror.sh`, `away.py` + `awaycorp.sh` (with the dump census and
    `CONTROL=1`), `det.sh`, `uvmdist.sh`, `switchreach.sh`.
* `cases/`: C (vc01-vc11), IA (va01-va11), M (vm01-vm04), P (vp01-vp06), W (vw01-vw04). Each names its law on its first
  line.
* `evidence/`: `sweeps/` (summaries, csv diffs, cmds audit, byteverify, probe and lane movers), `away/`, `determinism/`,
  `switches/`, `grid/`, `downstream/`, `byte_controls/`. The full sweep csvs are not committed because they list the
  fenced rows.

**The verified patch** `/tmp/r11u210.verified.patch` is `/tmp/r11u210.patch`'s source and repro hunks unchanged, plus
this directory and `tests/LAWS.md` regenerated by `python3 scripts/law_index.py`. The src part also applies clean on
the current main HEAD `6dcc0818`; only `tests/LAWS.md` needs regenerating at integration.
