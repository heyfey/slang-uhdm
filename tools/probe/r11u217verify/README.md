# r11u217 — second adversarial verification of passes 209, 210 and 212

Base `83ee16d6` (branch matrix-1.87: pass 209 landed at `b69dc2da` with its verifier v11u209, r11u213's refinement at
`6dcc0818`, pass 210 at `a727b8c7` with v11u210, pass 212 at `745f66ab` with v11u212, the r11u214 decode on top, tools
only; its `law_typeemit.patch` is NOT applied here). Measurement only: no file under `src/`, `scripts/`, `tests/`,
`results/` or `third_party/` is edited by this directory. The four proven breaks are refined in [fix.patch](fix.patch)
(not applied), each behind its own switch, `R11V217_OFF` dropping all four, new header `src/R217.h`. A probe case is
called a case throughout. The four slang-fenced tests are never named here. No canonicalisation patch of
`tools/uhdm-strictcmp` was handed to this pass and none was written: no comparator defect was proven.

## 0. Verdict

* **Four breaks, all refined** (section 4). On fresh legal SystemVerilog, a landed law moved a field that the law-off
  state (pristine for that law) had equal to golden away from golden:
  * **B1, § anonMemberTdLastWriter212** re-parents EVERY object of the typedef's key at the last anonymous member,
    including a parameter's or localparam's per-use typespec copy. Golden keeps those copies at their parameter
    (`work@dut.P.in_t.b`, `work@dut.Q.in_t.b`, `work@dut.EA.a::e_t.x`). Strict records lost in the elaborated view
    (SR/s10_el 1, SR/s11_el 2, X/x02_el 1). Refinement **§ anonMemberTdUseCopyKeeps217v** (`R11V217_TDUSECOPY_OFF`):
    only the typedef's listing objects move. SR/s10_el and s11_el then read **STRICT_EQUAL** (pristine and law both
    `fullname`).
  * **B2, § ifacePortDeclTsAtPortDecl205** relocates a folded bound over the whole bound expression. Golden locates
    a folded binary bound at its top operation's LEFT operand (`W-1` at `W`, `WIDTH-1` at `WIDTH`, `2*W-1` at `2*W`,
    `W-1-1` at `W-1`, `-W+7` at `-W`, measured). PD/p10 lost 6 / 8 strict records in the two views. p06, p09, p11
    and v11u209's own PD/v05 moved dump records away. Refinement **§ ifacePortDeclFoldedBoundLeftOp217v**
    (`R11V217_PDBOUNDOP_OFF`). PD/p10_el converts to **STRICT_EQUAL**, p06, p09 and p11 get the pristine bytes, and
    v05 gets golden's `3:11-12`.
  * **B3, § ndaSysCallNetTs212's range-query branch** (v11u212's e09, e16, g13 finding, decided here). Golden folds
    `$high`, `$low`, `$left`, `$right` and `$size` of a net-declaration initializer to a constant at the queried bound
    with no typespec (`UINT:7` at 2:25, measured: 0 range-query calls in golden's databases). The stamp only adds a
    `ref_typespec` golden never writes (stage 1 at the base and after, +7 to +35 dump lines per case). Refinement
    **§ ndaQueryFoldsNoStamp217v** (`R11V217_NDAQUERY_OFF`). It gives pristine bytes on NS/n02, n07 and n08 and on
    v11u212's E/e09, E/e16 and G/g13.
  * **F1 decided, § caseItemImpWildParamScopeName210.** For a plain wildcard literal (no concatenation in the
    initializer), golden substitutes a CONSTANT, and the law renames a reference golden does not hold. The rename is
    neutral on the dump-name multiset: C/c02 shifts one `tp::W*` name to `work@dut.W*` per parameter, and golden holds
    neither on the item. Refinement **§ caseItemWildConcatOnly217v** (`R11V217_CASEWILDCAT_OFF`, the brief's
    requirement): the law needs § imppCopyOpReadIsRef114's `concatBearing114` predicate. Pristine bytes result on
    C/c02 and v11u210's C/vc09. Every concatenation-bearing item still converts: the three probe conversions, ibex_tracer,
    and C/c04's two.
* **The fix fires nowhere in the gates.** The firing census of the fix sweep G (`R11V217_TRACE` over probe, both
  corpora in both modes, the downstream lanes) finds 0 trace files. That prediction was frozen before the byte
  comparison. The comparison: probe 0/4087 and downstream lanes 0/805 databases move. Corpus: 2/2560 move, the known
  coins (Scoreboard default svunit order, MiniAmiq testflags storage order, each 0 order-blind lines). All gates read
  0/0/0 and downstream reads 803/66/2/0. The fix binary rebuilds byte-identically from a fresh `83ee16d6` worktree
  (`275b48efc283`). Over all 13373 tools/probe case directories x 2 views, it fires only on this directory's
  break cases and on v11u209 PD/v05, v11u210 C/vc09, and v11u212 E/e09, E/e16, G/g13. Crash parity holds: 508
  non-zero rc case-views, each with the same rc on law and fix.
* **No other break** in 100 fresh cases x 2 views (200 case-views), judged on uhdm-cmp, uhdm-strictcmp field by
  field, and downstream:
  * Every rc is 0 in every state.
  * From the three landings off to law: 42 case-views enter EQUAL, and 0 leave EQUAL. With the fix, 3 more enter
    EQUAL and none leave.
  * Downstream: 0 of 100 cases leave IDENTICAL. LV/l02 goes EQUIVALENT -> IDENTICAL.
* **Composition** (section 5). Every claimed conversion is its own landing's, exactly as claimed:
  * pass 209: HierPathTypespec t, InterfaceStructMemberPort d/t, and 33 probe cases;
  * pass 210: FuncStructValSimple d/t and the three probe cases;
  * pass 212: the four probe cases.

  CANCEL is 0 at status level and at byte level over 7452 databases. The all-off state reproduces `baf91896`'s
  committed baselines with 0/0/0 in all three stages, and the Earlgrey and UVM hashes r11u213 measured there.
* **Away census** (map 13's method, all three landings): each reproduces its pass's claim to the record, with **0 lost**.

  | landing | databases | toward |
  |---|---|---|
  | 209 | 59 | 8362 |
  | 210 | 13 | 2212 |
  | 212 | 18 | 161 |
  | all | 77 | 10735 |

  Positive control: the reversed census reads 10735 lost. A raw full-name census of the typespec-copy movers (which
  the chain census cannot see) reads 0 lost; its reversed control reads 3.
* **Determinism.** No new reader-visible coin:
  * Earlgrey, SeqDriver and BuildUVMPkg: one hash per mode in every state.
  * SimpleUVM default draws a second hash in 1 of 13 runs, both with the landings on and with them off. The
    all-off draw is v11u210's `09716ef0`. The dumps are identical even in order.
  * v11u210's SeqDriver second hash does not reproduce in 26 draws.
  * MiniAmiq: storage order only. Scoreboard default: the svunit coin (92 ordered lines, 0 order-blind).
  * § twinElemOnlyNoRange209's rebuild claim is confirmed across four builds.
* **Fence and process** (section 10): no fenced read.
  * The six directories hold no fenced name.
  * Every env.sh fails closed. v11u210repro has no env.sh; each of its drivers reads the fence itself.
  * The predictions match the claimed md5s. This census reproduces the union of the three frozen predictions line
    for line (83 rows).
  * Findings: every packaged driver's frozen binaries (`/tmp/*_bin`) are gone. v11u210repro's `det.sh` does
    `cd /tmp/wt_v11u210`, and its `uvmdist.sh` / `switchreach.sh` read the main checkout by absolute path. Two source
    comments cite a directory that does not exist (`tools/probe/r11u212verify`; it is `v11u212repro`).

## 1. Binaries and states

Frozen `chmod 555` in `/tmp/r11u217_bin` before any measurement
([evidence/sweeps/binaries_and_states.txt](evidence/sweeps/binaries_and_states.txt)):

| binary | md5 | what |
|---|---|---|
| `law.bin` | `8c724b640425` | `83ee16d6`, this worktree's build (system deps, `-j 2`): byte-identical to the main tree's `build/slang-uhdm` (an independent build) |
| `fix3.bin` | `275b48efc283` | `83ee16d6` + [fix.patch](fix.patch); a fresh `83ee16d6` worktree with `git apply fix.patch` and a fresh cmake rebuilds the same md5 |
| `fix1.bin`, `fix2.bin` | `2b2654ab`, `24c7c864` | development steps (fix1: the parameter-only first draft of B1's refinement, which left s11_el's localparam copy; fix2: the three refinements without § caseItemWildConcatOnly217v) |
| `uhdm-strictcmp` | `fa6e4f42f252` | the base's comparator (not edited) |

Gate sweeps (`tests/sweep.sh --jobs 3`, all four stages, `/tmp/r11u217_sw<tag>`, same-length names; every `cmds.txt`
names the sweep's own wrapper, 3273 of 3273 per sweep: [evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt)):

| tag | state | switches |
|---|---|---|
| H | law (+ the firing census) | `R11U209_TRACE R11U210_TRACE R11U212_TRACE` |
| A | the three landings off | `R11U209_OFF R11V209_OFF R11U210_OFF R11U205_IFARRIDX_OFF R11U212_OFF R11V212_OFF` |
| 9 | landing 209 off | `R11U209_OFF R11V209_OFF` |
| 0 | landing 210 off | `R11U210_OFF` |
| 2 | landing 212 off | `R11U212_OFF R11V212_OFF` |
| X5 | the cross-ground switch | `R11U205_OFF` |
| F | fix2 (development) | `R11V217_TRACE` (0 trace files) |
| G | the fix (`fix3.bin`) | `R11V217_TRACE` (0 trace files) |

Every sweep reads `law index STALE` (this directory's cases name laws; `tests/LAWS.md` is not regenerated here, the
integrator runs `scripts/law_index.py`), hence `SWEEP_RC=1`; every stage reads 0 unexcused.

**The switch map, read from src** ([drivers/laws.py](drivers/laws.py) header):

* `r11u209Law` (UhdmExporter.cpp): `R11U209_OFF` or the law's own switch; the seven 209 laws.
  `r11u205Law`: `R11U205_OFF` **or `R11U209_OFF`** or its own; pass 209's three r11u205 laws. `r11v209Law`:
  `R11V209_OFF` or `R11U209_OFF` or its own; v11u209's three refinements. `R11U209_OFF` alone restores pass 209's
  pristine bytes.
* `r11u210On` (EmitHelpers.h, cached): `R11U210_OFF` or its own; the six 210 laws. `r11u205aOn`: `R11U205_OFF` or
  `R11U210_OFF` or `R11U205_IFARRIDX_OFF`; § elabIfArrIdxChainName205. `R11U210_LANDING201_OFF` /
  `R11U210_GENBITS201_OFF` are switches of landing 201's state, no law of this pass.
* `r11u212Law`: `R11U212_OFF` or its own; `r11v212Law`: `R11V212_OFF` or its own. **It does not read
  `R11U212_OFF`**, but § anonMemberTdOwnerDef212v runs only inside § anonMemberTdLastWriter212's application, so
  `R11U212_OFF` alone restores pristine bytes (sweep 2 reproduces pass 212's claims exactly).
* **`R11U205_OFF` spans both grounds (v11u210's F5), measured by sweep X5.** It drops four laws:

  | law | ground | measured on |
  |---|---|---|
  | § ifacePortDeclTsAtPortDecl205 | B | 20 probe regressions and 3 probe changes, pass 209's interface-port cases |
  | § genConnTrailSelChain205 | B | Earlgrey_0_1 d/t `endcol(45) -> fullname(75)` |
  | § defGenTargetIpsDefName205 | B | Rggen d `file(3) -> defname(141)` |
  | § elabIfArrIdxChainName205 | A | InterfArrayBind d `fullname(1) -> (3)` |

  Downstream 803/66/2/0.
* **Older laws gating three of pass 209's**, the reach of an older switch:
  * § defGenTargetIpsDefName205 needs pass 161's `sel161 && name161`, so `R11U161_ROUTE_OFF` and `R11U161_NAME_OFF`
    drop it.
  * § tfItemLocalSpecAtName209 needs pass 142's `tfItemLocalClassTs142` and pass 53's `pkgGeneric53`.
  * § classTdPkgEnumMemberShares209 runs only where § aggMemberAggTdSharesListing3's `unban3` did not already share.
  * § mpOrphanLaterWriter209v reads the writer positions noted by § ifaceSigConnNamedByChildPort155.

## 2. The gates of the fix (sweep G against H and against the committed baselines)

| gate | result |
|---|---|
| (1) build | `83ee16d6` + fix.patch, `-j 2`, md5 `275b48efc283`, reproduced from a fresh worktree; `R11V217_OFF=1` writes law.bin's bytes on 64 of 64 grid case-views where a refinement is scored ([evidence/grid/grid_fix_*.txt](evidence/grid/)) |
| (2) probe | EQUAL 3410 / STRICT_NOTEQUAL 677, `regressions=0 conversions=0 changes=0`; probe.csv byte-identical to H's |
| (3) surelog, uhdm2rtlil | `0 / 0 / 0` in both (929 + 25; 1596 + 10); surelog.csv differs from H only in the LowMemLib / LowMemPkg testflags detail text (the workdir path); uhdm2rtlil.csv identical |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, downstream.csv byte-identical to H's |
| (5) uhdm-cmp | no row touched |
| (6) byteverify | `MOVERS: 2 / 2560`, SELFCHECK 2559 / 2560, fence-free mirrors (`fenced_skipped=8`): Scoreboard default (`de42a8e4` / `50f1e9cd`) and MiniAmiq testflags, both 0 order-blind lines (the known coins); probe 0 / 4087; downstream lanes 0 / 805 ([evidence/fix/](evidence/fix/)) |
| prediction | frozen before the comparison ([evidence/fix/predicted_movers_fix.txt](evidence/fix/predicted_movers_fix.txt), md5 `ee853740d799`): 0 movers, 0 trace files |
| canaries | H and G: surelog `ok=52 changed=0`, uhdm2rtlil `ok=16 changed=0`; `ctcan2.sh` `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS ([evidence/fix/canaries_H_G.txt](evidence/fix/canaries_H_G.txt)) |
| firing census, all tools/probe | [evidence/fix/firecensus_traces.txt](evidence/fix/firecensus_traces.txt): 13373 case directories x 2 views, 32 trace files: this directory's C/c02, NS/n02 n07 n08, PD/p06 p09 p10 p11, SR/s10 s11, X/x02 and v11u209 PD/v05, v11u210 C/vc09, v11u212 E/e09 E/e16 G/g13 ([evidence/fix/other_firings_judged.txt](evidence/fix/other_firings_judged.txt): vc09, e09, e16, g13 get the law-off bytes; v05 gets golden's `3:11-12` where the law wrote `3:11-14`); 508 non-zero rcs, fix = law on every one |

The sweep H itself reproduces every committed baseline with 0/0/0 in all three stages and downstream 803/66/2/0.

## 3. The laws, fresh cases, three axes

100 fresh cases in [cases/](cases/). Each case names its laws on its first line: an `args` case names them in its
first root file, and a header case holds its `.svh`. Goldens come from the pinned Surelog with check_probe's
arguments, in both views (`EL=1`: `-elabuhdm` / `--elabuhdm`).

[drivers/grid.py](drivers/grid.py) runs each case in these states:
* the binary with every law on (`on`);
* the traces;
* each named law's switch alone;
* the landing off;
* every pair of named laws (under X/);
* all off, and all off plus `R11V213_OFF` (the `baf91896` state).

`WITH217=1` also scores the four refinements wherever their parent law is under test. It scores pristine (the switch
on) against the law on the strict records when stage 1 is equal. When stage 1 differs, it scores on the order-blind
dump distance.

Two grid runs:
* on law.bin: [evidence/grid/grid_law_*.txt](evidence/grid/), per-law table [lawtable_law.txt](evidence/grid/lawtable_law.txt);
* on fix3.bin: [grid_fix_*.txt](evidence/grid/), [grid3_fix.txt](evidence/grid/grid3_fix.txt), table
  [lawtable_fix.txt](evidence/grid/lawtable_fix.txt).

Downstream comes from the harness's own `one()` ([drivers/dscase.py](drivers/dscase.py), states ON / ALLOFF / FIX:
[evidence/downstream/cases_ON_ALLOFF_FIX.txt](evidence/downstream/cases_ON_ALLOFF_FIX.txt)).

| law (switch) | fresh cases (shapes) | fired case-views | law vs its switch off | verdict |
|---|---|---|---|---|
| § genConnTrailSelChain205 (`R11U205_GENIDXSEL_OFF`) | GS/g01 (a modport interface PORT's member bit-select, named and positional, nested for-generate, genvar arithmetic `b.e[2*i+j]`), g02 (a packed-array-of-struct element member `pa[1].en[k]`, a local struct, a parameter-expression index `cfg.en[P-1-k]`), g03 (a trailing indexed part select beside a bit-select, if-in-for, case-generate), g04 (generate-scope INTERFACE instances, an operation actual), g05 (a three-level path, a 2-D packed member slice, an output actual, a generate loop inside an interface), X/x01 | 12 | TOWARD 2 (g01 both views), STAGE1-CLOSER 10 | holds |
| § defGenTargetIpsDefName205 (`R11U205_IPSNAME_OFF`) | IP/i01 (if-in-for, a two-level member, `+:` and `-:`), i02 (an interface instance member, a packed-array element member, case-generate), i03 (a parameter base `P*2+:2`, a genvar base: R3), i04 (if/else, a middle select), i05 (the SPACED operator forms) | 8 | TOWARD 4 (i01 -> STRICT_EQUAL both views; i04), STAGE1-CLOSER 4 | holds; **under-reach: the spaced forms `[2 +: 2]` never fire** (pass 161's text route reads only the unspaced form; i05 law = pristine) |
| § ifacePortDeclTsAtPortDecl205 (`R11U205_PORTDECLTS_OFF`) | PD/p01 (tri, wand, wor), p02 (bit, logic signed, reg, logic, wire outputs), p03 (two packed dims, an unpacked dim), p05 (a module: control; a comment and a split declaration), p06 (a parameterized width, two declarators, signed, scalar), p07 (var logic, byte, int, integer, tri1, uwire), p08 (tri / wor / wand / signed wire outputs), p09 (a parameterized width twice instantiated), p10 (a parameterized port redeclared in the body), p11 (`WIDTH-1`, `2*W-1`, `(W)-1`) | law.bin: 4 STAGE1-AWAY + p10 MIXED | **BREAK B2** (p06, p09, p11 dump records, p10 6 / 8 strict records); with the refinement: p10 TOWARD (p10_el STRICT_EQUAL), p06 p09 p11 = pristine | refined (section 4) |
| § pdTsNotTypedefListing209v (`R11V209_PDNAMED_OFF`) | PD/p04 (a typedef port, a port redeclared with a package typedef, the typedefs read by the module) | 2 | STAGE1-CLOSER 2 | holds |
| § twinElemOnlyNoRange209 (`R11U209_TWINELEM_OFF`) | TW/t01 (dynamic / associative / queue returns of an enum, a class handle, a string, a packed struct), t02 (PACKAGE functions: the twin helper never fires), t03 (a module-scope class, an out-of-body queue return, a parameterized-class dynamic array) | 4 | STAGE1-SAME 4 (reader-invisible orphan) | holds; rebuild identity section 8 |
| § pkgArrTdElemClone209 (`R11U209_ARRTDCLONE_OFF`) | HP/h01 (one typedef in two modules), h02 (a nested-struct and a union element), h03 (fixed unpacked, dynamic, queue element typedefs), h04 (a class property, a package function, a wildcard import) | 6 | TOWARD 2 (h01_el, h02_el), BYTES-ONLY 2, STAGE1-CLOSER 2; h04 unfired | holds |
| § portConnOpLeafChain209 (`R11U209_OPLEAFCHAIN_OFF`) | IM/m05 (operations without a struct net: unary, binary, ternary), m06 (a local struct and a struct port, twice instantiated) | 4 (+ every IM case) | TOWARD 2 (m06), BYTES-ONLY 1, STAGE1-CLOSER 1 | holds |
| § modportOpOrphanReparent209 (`R11U209_MPORPHAN_OFF`) | IM/m01 (an assignment pattern beside the trigger), m03 (a later single-select and a later bare connection in another instance), m04 (two modports of one instance), m07, m08 (the trigger in a generate loop, nested in a concatenation) | 10 | TOWARD 4 (m03, m04 -> STRICT_EQUAL both views), STAGE1-CLOSER 6 | holds |
| § mpOrphanSkipConcat209v (`R11V209_MPCONCAT_OFF`) | IM/m09 (a multiple concatenation and a positional assignment pattern), m02 and m10 (streaming, nested: no trigger) | 2 | STAGE1-CLOSER 2 | holds |
| § mpOrphanLaterWriter209v (`R11V209_MPLATER_OFF`) | IM/m07 (a later whole-struct and a later bare connection) | 2 | STAGE1-CLOSER 2 | holds |
| § tfItemInitLocalAtType209 (`R11U209_TFINITTYPE_OFF`) | LV/l01 (byte, shortint, longint, bit signed, logic, time, realtime, shortreal, integer), l02 (a task with a body `input`, an enum, a struct, a string; a function with a body `output`), l03 (in-body and out-of-body paren-less class methods: int, `new`, dynamic array, queue, automatic), l05 (parenthesized control, const / static, an interface function), l06, X/x05 | 10 | TOWARD 4 (l02, l03), STAGE1-CLOSER 6 | holds; downstream l02 EQUIVALENT -> IDENTICAL |
| § tfItemLocalSpecAtName209 (`R11U209_TFSPECNAME_OFF`) | LV/l04 (specializations with and without initializers, type and named arguments), l06 (a generic from another package, a typedef of a specialization) | 2 | TOWARD 2 (l04) | holds; l06 fires with no byte move |
| § classTdPkgEnumMemberShares209 (`R11U209_CLSENUMMEM_OFF`) | CS/c01 (two classes and a module), c02 (a union, another package's enum, a class-scope enum: declined), c03 (a formal, a port, a derived class) | 6 | TOWARD 4 (c01, c03 -> STRICT_EQUAL both views), STAGE1-CLOSER 2 | holds |
| § elabIfArrIdxChainName205 (`R11U205_IFARRIDX_OFF`) | IA/a01 (depths 1-3, inner and outer genvars), a03 (a concatenation left side: F2; member bit / part selects), a04 (an interface-array port of a child twice instantiated; a parameter index: F2), X/x01 | 4 (parse view only) | TOWARD 1 (a01), STAGE1-CLOSER 2, STAGE1-SAME 1 (a03) | holds; F2 confirmed: golden builds another structure for a concatenation left side and folds a parameter index (stage 1 in both states, no line lost) |
| § elabIfArrIdxExprChainName210 (`R11U210_IFARREXPR_OFF`) | IA/a02 (`b[i+P].w`, `b[P*i+5].w`, `b[2*i].w`) | 1 | STAGE1-CLOSER 1 | holds |
| § memLeftReadsPatUnlocated210 (`R11U210_MLPATLOC_OFF`) | M/m01 (nested builder calls through helper functions), m02 (a builder called twice, a same-package and a module-local pattern), m03 (the result as an override and a generate condition, a nested member: unfired), X/x03 | 6 | STAGE1-CLOSER 2, STAGE1-SAME 4 | holds (see section 6: FuncStructVal's R2 file field) |
| § pkgTopWidePatReplTsName210 (`R11U210_PKGREPLTS_OFF`) | W/w01 (qualified read only inside another package's function: F4), w02 (qualified and unqualified, two replication members), w03 (an override and a generate condition, a product count), X/x05 | 4 | TOWARD 2 (w02), STAGE1-CLOSER 2 | holds; **F4 decided**: in w01 golden parents the replication constant at the operation and names its ref_typespec `vp` (the law's form), ours unparented and unnamed: an under-reach, stage 1 at the base (residue) |
| § caseItemImpWildParamScopeName210 (`R11U210_CASEWILD_OFF`) | C/c01 (x, z and ? digits with concatenations, casez / casex), c02 (plain wildcard literals: F1), c03 (explicit single-name imports, a task, an interface function, a parenthesized item, a two-item list), c04 (plain and concatenation-bearing in one casez), X/x04 | law.bin 8 | TOWARD 4 (c01, c03), STAGE1-CLOSER 2, STAGE1-SAME 2 (c02: F1) | **F1 refined** (section 4) |
| § pkgImpParamMemberColons210 (`R11U210_PKGIMPCOLON_OFF`) | P/p01 (a chain of three packages), p03 (explicit imports, a nested struct, both packages imported), X/x02 | 6 | TOWARD 2 (x02), STAGE1-CLOSER 4 | holds |
| § pkgImpParamAliasColons210 (`R11U210_PKGIMPALIAS_OFF`) | P/p02 (an alias of a vector typedef, a signed vector typedef, an enum-typed parameter) | 2 | STAGE1-CLOSER 2 | holds |
| § anonMemberTdLastWriter212 (`R11U212_ANONMEMTD_OFF`) | SR/s01 (program zp, interface mi, module aa), s02 (an anonymous union with an enum member, a nested anonymous struct, `Zb` / `ab`), s05 (a header included EARLY with the larger line: a06's mirror), s06 (anonymous-struct ports and nets), s10 (an imported package typedef + a module parameter), s11 (a module typedef + a parameter and a localparam), s12 (a $unit typedef + a child parameter override), X/x02 | law.bin 12 | **BREAK B1** (s10_el, s11_el, x02_el); with the refinement TOWARD 10 (s10_el, s11_el -> STRICT_EQUAL), BYTES-ONLY 2, STAGE1-CLOSER 2, STAGE1-SAME 2 (s05) | refined (section 4); s05 / a06 residue |
| § anonMemberTdOwnerDef212v (`R11V212_TDOWNER_OFF`) | SR/s03 (a header in an interface and a module), s04 (a multi-line macro in two modules), s07 (one header in three modules, two anonymous), s08 (an interface and a module both anonymous), s09 (a program and a module) | 2 (s08; s07 traces, same bytes) | BYTES-ONLY 2 (s08 STRICT_EQUAL both); s03 s04 s07 s09 EQUAL in every state | holds |
| § pkgEnumAliasListingParent212 (`R11U212_PKGENUMALIAS_OFF`) | EA/e01 (read by two importers: no fire), e02 (two aliases, one read by a package function), e03 (an alias of another package's enum, a class property) | 4 | TOWARD 2 (e03), STAGE1-CLOSER 2 | holds |
| § queueMemberSpanToDim212 (`R11U212_QUEUEMEMSPAN_OFF`) | QM/q01 (one, two, three dimensions, a bounded queue), q02 (packed element, class handle, string, package typedef in a class), q03 (two declarators, a spaced dimension with a comment, class scope) | 6 | TOWARD 6 | holds |
| § sizeDimOvrFileAtDim212 (`R11U212_SIZEDIMFILE_OFF`) | SF/f01 (two size dimensions overridden from another file: hex and a package localparam), f02 (one child twice overridden plus its default) | 4 | TOWARD 4 | holds |
| § signCastSysCallLhsTs212 (`R11U212_SIGNCASTTS_OFF`) | NS/n03 (onto signed, unsigned, int and struct targets, plus an interface), n05, n09 (n03 without the interface), n10 (a type-parameterized child: g08), n11 (a bound checker: g09) | 10 | n09 stage 1 -> **STRICT_EQUAL**, n11 stage 1 -> judge-equal, el views closer; the grid's dump metric reads STAGE1-AWAY on n03, n05, n09, n10, n11 in the parse view | holds: the stamps are golden's (golden's `ref_typespec (work@dut)` on each call, checked in the dump); the dump metric counts the stamp's lines per printed copy (n09 reaches STRICT_EQUAL while its dump distance rises); n10's stamps carry the pre-existing parse-view prefix `work@dut.u` where golden writes `work@c` (v11u212's g08) |
| § ndaSysCallNetTs212 (`R11U212_NDASYSTS_OFF`) | NS/n01 (a parameterized child twice: e05 / g11), n02 (all five range queries), n04 ($bits, $clog2, casts; typedef, scalar and interface nets), n06 (generate scopes: unfired), n07 (`$high` alone), n08 (`$size` / `$left` of a parameterized vector, plus $bits / $clog2), X/x03 | law.bin 14 | STAGE1-CLOSER on n01 n04 x03; **BREAK B3** on n02 n07 n08 (+7 to +35 dump lines, 0 range-query calls in golden) | refined (section 4) |

Judge level over the 200 case-views ([evidence/grid/judge_tally.txt](evidence/grid/judge_tally.txt)):

| all off | law | fix | case-views |
|---|---|---|---|
| stage 1 | stage 1 | stage 1 | 116 |
| judge-equal | EQUAL | EQUAL | 39 |
| judge-equal | judge-equal | judge-equal | 22 |
| EQUAL | EQUAL | EQUAL | 15 |
| stage 1 | EQUAL | EQUAL | 3 |
| judge-equal | judge-equal | **EQUAL** | 3 (s10_el, s11_el, p10_el: the refinements) |
| stage 1 | judge-equal | judge-equal | 2 |

**No case-view leaves EQUAL.** The rc is 0 on every case-view in every state (1396 runs).

**Downstream on the fresh cases** (100 cases, states ALLOFF / ON / FIX):
* 79 read IDENTICAL in all three states.
* LV/l02 goes EQUIVALENT -> IDENTICAL.
* 15 read EQUIVALENT, 3 DIVERGENT and 2 STATUS_DIFF in all three states. On each of those 20, the slang lane's
  `_nohier.il` is byte-identical across the three states.
* **0 leave IDENTICAL.**

### 3.1 The cross-ground pairs (X/, every pair switched off, both views)

| case | pair | reading |
|---|---|---|
| x01 | § genConnTrailSelChain205 + § elabIfArrIdxChainName205: `.x(b[k].v[1])` in a generate loop beside `assign b[k].w = 1'b1` | each alone closer (stage 1), both closer still; the genConn law fires in both views, the IFARRIDX law in the parse view only |
| x02 | § anonMemberTdLastWriter212 + § pkgImpParamMemberColons210: an anonymous member of an imported package struct beside imported parameters of it | the colon law TOWARD; the anon law MIXED on the elaborated view (B1: the EA copies); with the refinement TOWARD |
| x03 | § ndaSysCallNetTs212 + § memLeftReadsPatUnlocated210: a net initialized by `$unsigned` of a builder result member | both fire, STAGE1-SAME / CLOSER, no sign conflict |
| x04 | § pkgEnumAliasListingParent212 + § caseItemImpWildParamScopeName210: a casez reading a wildcard-concatenation parameter and an enum-alias constant | the case law closer; the alias law does not fire (the importing module lists the alias) |
| x05 | § tfItemInitLocalAtType209 + § pkgTopWidePatReplTsName210: a paren-less package function local initialized by a wide pattern | the tf-item law closer; the replication law does not fire on a read inside a function (F4's under-reach) |

No pair's joint effect differs in sign from its members'.

## 4. The breaks and the refinements ([fix.patch](fix.patch), [evidence/breaks/break_records.txt](evidence/breaks/break_records.txt))

**B1: § anonMemberTdLastWriter212 moves per-use copies** (UhdmExporter.cpp `typedefParentModel134`).

* **What the law does.** It keys the last anonymous member by the typedef's kind, name, file, line and column. It
  then calls `setNP(o, mem)` on EVERY named object of that key outside an unelaborated package.
* **What Surelog does.** It compiles a struct, union or enum typedef once. `TypeDef::getTypespec` returns the shared
  object, and only that object is re-parented by `member_ts->VpiParent(m)`. A parameter's typespec is a clone the
  elaborator makes per use: golden parents it at its `ref_typespec (work@dut.P)`.
* **Break cases.** In SR/s11_el (a module typedef, a parameter P and a localparam Q of it, one anonymous member m),
  the objects' parents are:

  | state | parents |
  |---|---|
  | golden | `ref_typespec (work@dut)` x2, `(work@dut.P)`, `(work@dut.Q)`, `typespec_member (m)` |
  | pristine | `module_inst work@dut`, `ref_typespec (work@dut)` x2, `(work@dut.P)`, `(work@dut.Q)` |
  | law | `typespec_member (m)` x5 |
  | fix | exactly golden's |

  The strict walk sees the move: s10_el `#202 golden work@dut.P.a::e_t.x / law mem.a::e_t.x`; s11_el `#230`, `#236`.
  X/x02_el (imported package parameters EA in the module and in an importing package b) reads golden
  `work@dut.EA.a::e_t.x` x7, pristine x8, law x0 (`mem.a::e_t.x` x10). The parse views canonicalise these names
  inside typespec copies and read BYTES-ONLY at the strict level, but the dump shows the same move.
* **Refinement § anonMemberTdUseCopyKeeps217v.** An object moves only when its current parent is a listing owner:
  the design, a module, interface, program, package or generate scope, or already an anonymous member. A draft that
  kept only objects parented at a parameter (`fix1.bin`) left s11_el's localparam copy, which sits under a
  `ref_typespec`.
* **Result.** s10_el and s11_el go from `fullname` to **STRICT_EQUAL** (205 and 239 objects). x02_el's EA copies
  keep their parameter parents, while the anonymous member's object moves as golden's does. The refinement fires on
  no gate database, so pass 212's four probe conversions and anon_struct_packed_dim are untouched.

**B2: § ifacePortDeclTsAtPortDecl205 locates a folded binary bound over the whole expression** (ModuleEmit.cpp).

* **What the law does.** It relocates each bound to `rs205.left->sourceRange()`.
* **What golden does,** measured on PD/p11 and a scratch grid: the folded constant spans the top operation's left
  operand.

  | bound | golden's span |
  |---|---|
  | `WIDTH-1` | 3:16-21 (`WIDTH`) |
  | `2*W-1` | 4:16-19 |
  | `(W)-1` | 5:16-19 |
  | `W-1-1` | `W-1` |
  | `-W+7` | `-W` |
  | `W` | `W` |

  Pristine wrote golden's span wherever the port was not redeclared.
* **Break cases.**
  * PD/p10 (a port redeclared in the body): golden `constant 4:11-4:12`, law `4:11-4:14`; 6 / 8 strict records new.
  * PD/p06, p09 and p11: 2-4 dump records each, stage 1.
  * v11u209's own PD/v05: `3:11-14` where golden writes `3:11-12`.
* **Refinement § ifacePortDeclFoldedBoundLeftOp217v.** When the UHDM bound is a constant and its syntax a binary
  expression, it is located at the left operand. p10_el reaches **STRICT_EQUAL**, p10's parse view keeps only its
  pre-existing `line` record, p06, p09 and p11 get pristine bytes, and v05 gets golden's `3:11-12`.

**B3: § ndaSysCallNetTs212's range queries** (ModuleEmit.cpp `emitContAssigns`, the net-declaration branch).

* **What golden does.** `wire [3:0] h = $high(v);` with `[7:2] v` becomes golden `cont_assign` Rhs `constant UINT:7`,
  `vpiSize 4`, located at the bound 2:25-26, with no typespec. The databases of NS/n02, n07, n08 and v11u212's e09,
  e16, g13 hold 0 range-query calls in either view.
* **What the law does.** Ours keeps the `sys_func_call` (a pre-existing stage-1 face), and the law adds a
  `ref_typespec (work@dut)` to it: +7 to +35 dump lines, no gate row.
* **Refinement § ndaQueryFoldsNoStamp217v.** It declines `$high`, `$low`, `$left`, `$right` and `$size`, giving
  pristine bytes on all six cases. The fold itself belongs with q08's generate-scope fold: ModuleEmit's
  net-declaration branch has no `sysFold`.

**F1: § caseItemImpWildParamScopeName210 on a plain wildcard literal** (StmtEmit.cpp).

* **What golden does.** Measured on C/c02: each item is a `constant` (`W1 = 4'b??11`), not a reference.
* **What the law does.** It renames our pre-existing reference from `tp::W1` to `work@dut.W1`. This is neutral on the
  names (golden holds neither on the item) and neutral on the dump distance.
* **Refinement § caseItemWildConcatOnly217v** (the brief's "refine if the law renames a reference golden does not
  hold"). It requires `concatBearing114` on the parameter's initializer.
* **Result.**
  * C/c02 and v11u210's C/vc09 get pristine bytes.
  * C/c04 renames only its two concatenation-bearing items and declines the plain one.
  * ibex_tracer and the three probe conversions are concatenation-bearing: 0 firings in the gates.

## 5. Composition ([evidence/compose/](evidence/compose/))

[drivers/compose.py](drivers/compose.py) (status level, H against A with 209 / 210 / 212 off one at a time):

| corpus | conversions A -> H | attributed |
|---|---|---|
| probe | 40 | OWN209 33 (r10earl53 v5, the 12 tf-item cases, the 20 interface-port cases), OWN210 3 (b02, x57_case_item, e04), OWN212 4 (g149/shapes, a12_anon_named_member, k10_named_member_dim, p04_enum_member) |
| surelog | 5 | OWN209: HierPathTypespec t, InterfaceStructMemberPort d/t; OWN210: FuncStructValSimple d/t |
| uhdm2rtlil | 0 | - |

Changes (not conversions) are attributed as follows:

* probe: OWN209 4 (v2_v53, pb10, pb19, v15) and OWN212 2 (g149/homes, paramtype).
* surelog: OWN209 Earlgrey d/t; OWN210 FuncStructVal d/t and InterfArrayBind d; **JOINT 209+212** on BuildUVMPkg
  d/t, MiniAmiq d/t, Rggen d, Scoreboard d, SeqDriver d/t and SimpleUVM d/t (both landings move them).
* uhdm2rtlil: OWN210 ibex_tracer d/t, OWN212 anon_struct_packed_dim d/t.

**CANCEL 0.**

[drivers/bytecancel.py](drivers/bytecancel.py) covers 7452 databases (probe, corpus and downstream lanes).
**CANCEL 0.** The databases that move:

| attribution | probe | corpus | lanes |
|---|---|---|---|
| OWN209 | 37 | 10 | TypedefPackedDimensions |
| OWN210 | 3 | 7 | ibex_tracer |
| OWN212 | 6 | 2 | anon_struct_packed_dim |
| JOINT209+210 | | BlackBePipeInt d/t (both fire there) | |
| JOINT209+212 | | the 9 UVM / Rggen databases | |
| JOINT209+210+212 | | MiniAmiq t: sweep 0's draw is the storage-order coin, 0 order-blind lines | |

**All-off = `baf91896`.** Sweep A against `baf91896`'s committed baselines reads probe, surelog and uhdm2rtlil
`regressions=0 conversions=0 changes=0`. Its UVM and Earlgrey hashes are r11u213's measured hashes at `baf91896`
(Earlgrey `15e6e48bc148` / `e449573deea9`, BuildUVMPkg `7c0083c739f6`, SeqDriver `05bc42521016` / `0d4f5053d8bf`,
Scoreboard `24ba24eb6c91`). The switches of the three landings are exact.

**The byte movers** (byteverify `SELFCHECK=1`, fence-free mirrors, [evidence/movers/byteverify_H_vs_offs.txt](evidence/movers/byteverify_H_vs_offs.txt)):

* H vs A: 31 of 2560. H vs 9: 22, exactly pass 209's 22. H vs 0: 9 plus the MiniAmiq t coin. H vs 2: 12, exactly
  pass 212's 10 + 2.
* Every mover is inside the firing census of sweep H, frozen before any comparison
  ([evidence/census/predicted_movers_H.txt](evidence/census/predicted_movers_H.txt), md5 `6dd454d16e85`, stamp
  `predicted_frozen_at.txt`): 33 corpus row-modes, 50 probe cases, 4 downstream lanes.
* Predicted but unmoved: TypedefEnum d/t and its lane, as pass 212 found: the continuous assignment unparents the
  alias again.
* **The census's corpus and probe rows equal the union of the three passes' frozen predictions line for line (83
  rows).**

**Switch reach of § landingSwitchReach210 on fresh cases** ([evidence/compose/reach201_fresh.txt](evidence/compose/reach201_fresh.txt),
[drivers/reach201.sh](drivers/reach201.sh)). `R11U210_LANDING201_OFF` writes the same bytes as `R11U201_OFF R11V201_OFF
R11U200_NEWARRHP_OFF R11U200_UNITFOLD_OFF R11U200_FOLDDEPTH_OFF R11U210_GENBITS201_OFF` on **200 of 200** case-views.
It moves 6 of them (C/c03, HP/h04, LV/l05) away from the switch-free bytes.

## 6. The CHANGES: unmasking proofs and the away census ([evidence/unmask/](evidence/unmask/), [evidence/away/](evidence/away/))

[drivers/unmask2.py](drivers/unmask2.py) compares golden against each database, with records and walk indices:

| comparison | probe | surelog | uhdm2rtlil |
|---|---|---|---|
| 209 (9 -> H) | CONVERSION 33, SUBSET 4 | CONVERSION 3, SUBSET 3 (Earlgrey d/t, Rggen d), UNMASK 7 (BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t), NEW 2 (SimpleUVM d/t) | - |
| 210 (0 -> H) | CONVERSION 3 | CONVERSION 2, SUBSET 1 (InterfArrayBind d), NEW 2 (FuncStructVal d/t) | SUBSET 2 (ibex_tracer d/t 579 -> 13) |
| 212 (2 -> H) | CONVERSION 4, SUBSET 2 (g149/homes 15 -> 1, paramtype 22 -> 2) | SUBSET 10 (BuildUVMPkg d/t 57 -> 51, MiniAmiq d/t 77 -> 75, Rggen d 4 -> 3, Scoreboard d 193 -> 188, SeqDriver d/t 63 -> 61, SimpleUVM d/t 241 -> 236) | SUBSET 2 (anon_struct_packed_dim d/t 43 -> 4) |

**The NEW verdicts, decoded** ([drivers/newrecs.py](drivers/newrecs.py)):

* **SimpleUVM d/t (209).** The walk's divergence moves from #20905 to #78244. The 5 records before #20905 that the
  law side reports and pristine did not are `int_typespec UVM_FILE` file records: golden `uvm_root.svh 348:39`,
  ours `uvm_object_globals.svh 313:9`. These are **identical in both databases**: 54 x `313:9` in pristine and in law,
  12 in golden (`evidence/unmask/newrecs_SimpleUVM_d_9_H.txt`). The comparator's span-pairing excuse over the longer
  walk reports them now, as v11u209 found for BuildUVMPkg #3245. It is an unmasking by the comparator's alignment;
  no field moved.
* **FuncStructVal d/t (210).** The 4 / 8 new records are pass 210's residue R2: `INT:2` leftovers golden locates at
  `dut.sv 618:22-45`, pristine at the call span, the law unlocated. At record level this is count-neutral, and the
  census is 0 lost. **At field level the law drops the FILE field (`dut.sv`) that pristine had equal to golden on
  these 4 / 8 objects, while their line and column were already wrong.** Golden's rule for this one read site is
  undecoded (pass 210 tried eight shapes; the fresh M/m01-m03 and X/x03 are unlocated in golden as the law writes).
  No refinement can separate these objects from FuncStructValSimple's, where the law is right. Reported, not refined
  (residue R2). Downstream is unaffected: FuncStructVal's lanes CRASH in Yosys in both states.
* pass 209's claimed changes at its own base (`fullname(76) -> endcol(45)` ...) are measured here at HEAD by the
  landing switch; the counts differ because pass 207 landed after pass 209's base. The per-landing deltas match the
  claims exactly (the UVM distances below).

**Away census** ([drivers/awayrows.py](drivers/awayrows.py): records keyed by ancestor chain and flat; lost = in golden
and in the off state, not in the law):

| landing | databases | toward (chain / flat) | lost | pass's own claim |
|---|---|---|---|---|
| 209 (9 -> H) | 59 | 8362 / 8362 | **0** | 8362, 0 lost |
| 210 (0 -> H) | 13 | 2212 / 2212 | **0** | FuncStructVal 502 / 826, FuncStructValSimple 39 / 59, InterfArrayBind 2, ibex_tracer 388 / 388, 3 cases 8: 2212 |
| 212 (2 -> H) | 18 | 161 / 161 | **0** | 161 |
| all three (A -> H) | 77 | 10735 / 10735 | **0** | additive, no interaction |
| positive control (H -> A) | 77 | 0 | **10735** | |

**Raw full-name census** ([drivers/namecensus.sh](drivers/namecensus.sh)) on the movers whose records sit inside
typespec copies the chain census canonicalises:

| row | lost | gained |
|---|---|---|
| anon_struct_packed_dim d | 0 | 3 |
| TypedefPackedDimensions d | 0 | 1 |
| HierPathTypespec d | 0 | 1 |
| TypedefRange d | 0 | 1 |
| BlackBePipeInt d | 0 | 9072 |

The reversed control reads 3 lost.

## 7. Downstream

| row / lane | law | all off | slang lane vs Surelog lane |
|---|---|---|---|
| TypedefPackedDimensions (lane, pass 209's mover) | IDENTICAL | IDENTICAL | nohier, il, synth byte-identical in both states; the lane database moves |
| ibex_tracer (lane, pass 210's) | IDENTICAL | IDENTICAL | byte-identical in both |
| anon_struct_packed_dim (lane, pass 212's) | IDENTICAL (52 gates) | IDENTICAL | byte-identical in both |
| TypedefEnum (lane, predicted, unmoved) | IDENTICAL | IDENTICAL | - |
| HierPathTypespec, InterfaceStructMemberPort (33 gates), FuncStructValSimple, InterfArrayBind (surelog rows, [drivers/dsrow.py](drivers/dsrow.py)) | IDENTICAL | IDENTICAL | ([evidence/downstream/rows_ON_ALLOFF.txt](evidence/downstream/rows_ON_ALLOFF.txt)) |
| FuncStructVal | IDENTICAL (both lanes CRASH in Yosys) | the same | pre-existing |

**The passes' own cases**, all 367 of the six directories, law against all off
([evidence/downstream/passcases_ON_ALLOFF.txt](evidence/downstream/passcases_ON_ALLOFF.txt)):
* 338 read IDENTICAL in both states.
* 3 go EQUIVALENT -> IDENTICAL: v11u209's LV/d01 and LV/v11 (confirmed), and r11u209's LV/l08, which neither pass
  reported.
* 14 stay EQUIVALENT, 9 DIVERGENT and 3 STATUS_DIFF.
* **0 leave IDENTICAL.**

**Pass 212's downstream faces** (its `evidence/downstream/cases.txt`: 271 listed, the README says 272;
[evidence/downstream/faces272_ON_ALLOFF.txt](evidence/downstream/faces272_ON_ALLOFF.txt)): 226 IDENTICAL, 22
EQUIVALENT, 16 DIVERGENT, 6 STATUS_DIFF and 1 SLANG_REJECT in both states. **0 verdict changes.**

**UVM order-blind distance** ([drivers/uvmdist.sh](drivers/uvmdist.sh), [evidence/residues/uvmdist.txt](evidence/residues/uvmdist.txt); dist / sym, both modes equal):

| row | all off (A) | 209 off | 212 off | 210 off | law (H) | fix (G) |
|---|---|---|---|---|---|---|
| MiniAmiq | 6565 / 14920 | 6554 / 14898 | 6539 / 14802 | 6528 / 14780 | **6528 / 14780** | 6528 |
| SeqDriver | 5115 / 11094 | 5102 / 11068 | 5084 / 10954 | 5071 / 10928 | **5071 / 10928** | 5071 |
| SimpleUVM | 2017 / 3946 | 2006 / 3924 | 1994 / 3834 | 1983 / 3812 | **1983 / 3812** | 1983 |
| Scoreboard | 1480 / 2937 | 1471 / 2919 | 1462 / 2847 | 1453 / 2829 | **1453 / 2829** | 1453 |
| BuildUVMPkg | 739 / 1477 | 732 / 1463 | 720 / 1385 | 713 / 1371 | **713 / 1371** | 713 |

These tie out to earlier measurements:
* A is r11u213's `baf91896` figures, and pass 210's sym figures.
* H is pass 212's reported law figures, and 212 off is pass 212's base figures.
* Pass 209's own delta at HEAD (209 off -> H) is -26 / -31 / -23 / -18 / -19, exactly its claimed 6634 -> 6608,
  5194 -> 5163, 2074 -> 2051, 1526 -> 1508, 776 -> 757.
* Pass 210 moves no UVM record.

The first records at the base are in [evidence/residues/heads_H.txt](evidence/residues/heads_H.txt): MiniAmiq #899,
SeqDriver #10090, SimpleUVM #458, Scoreboard #466, BuildUVMPkg #26067.

## 8. Determinism ([evidence/determinism/](evidence/determinism/))

The harness's own command lines and cwd, concurrent draws ([drivers/det.sh](drivers/det.sh)):

| row | law | all off | fix | reading |
|---|---|---|---|---|
| Earlgrey_0_1 d / t | 1 / 1 (`5bb5b3b989b4`, `1961f9984a06`) | 1 / 1 (`15e6e48bc148`, `e449573deea9`) | 1 / 1 (the law's) | deterministic |
| BuildUVMPkg d / t | 1 (`c020394bcdbc`) | 1 (`7c0083c739f6`) | 1 | deterministic |
| SeqDriver d / t | 1 / 1 in 13 draws each | 1 / 1 in 13 draws each | 1 / 1 | **v11u210's second default hash does not reproduce (26 draws)** |
| SimpleUVM d | 2 hashes: `bd82609ab364` in 1 of 13 | 2 hashes: `09716ef0d4fa` in 1 of 13 (v11u210's pristine second hash, reproduced) | 1 in 3 | **dumps identical even in order** (0 ordered, 0 order-blind lines): storage order only, present on the all-off state too, not a landing's coin, not reader-visible |
| MiniAmiq d / t | `322b782ebb31` (the sweep drew `4db8f` / `1dfa6`) | `de78d9e9` / `f1dbe619` | law's | 0 ordered, 0 order-blind lines: storage order |
| Scoreboard d | `de42a8e4` / `4bece0e4` | `24ba24eb` / `498cfef0` | `de42a8e4` / `50f1e9cd` | 92 ordered, 0 order-blind lines: the known svunit coin |

([evidence/determinism/coins_orderblind.txt](evidence/determinism/coins_orderblind.txt)). **No new reader-visible coin.**

**Rebuild identity and § twinElemOnlyNoRange209** ([evidence/determinism/twin_rebuild.txt](evidence/determinism/twin_rebuild.txt)).

* The main tree's build and this worktree's build are byte-identical (`8c724b640425`).
* r11u196's V191/qr01, r11u209's TW/qr01, and this pass's TW/t01 and t03 each write ONE hash in 4 runs of each of
  four binaries: the main build, law.bin, fix2.bin and fix3.bin. fix2 and fix3 are rebuilds that recompiled
  ModuleEmit, UhdmExporter and StmtEmit.
* With `R11U209_TWINELEM_OFF=1`, the rebuilt binaries write different bytes from law.bin on qr01 (both) and t01:
  the build-dependent orphan the law closes. The orphan is deterministic per binary.

## 9. The residues of the passes, re-measured at the base ([evidence/residues/](evidence/residues/))

| residue | status at `83ee16d6` |
|---|---|
| 209 #1 Earlgrey_0_1 d/t's remaining records (ground A) | stands: `endcol(45)`, first records #93964 / #95240 `endcol` |
| 209 #2 the kept-reduced connection operation (IM m05 / g05) | stands: `fullname` in the parse view, stage 1 in the elaborated view; downstream EQUIVALENT (both) |
| 209 #3 the genvar-based indexed part-select target (R5 i1) | stands: `fullname` both views (and this pass's IP/i03's `o.g[k*2+:2]`); a new under-reach: the SPACED operator forms never fire (IP/i05) |
| 210 R1 ibex_tracer's last 13 records | stands: first record #27582 `fullname` |
| 210 R2 FuncStructVal's INSTR_PER_FETCH leftovers | stands: #4782 `file` (d), #7129 (t); the file field lost on these objects (section 6) |
| 210 M/m06 (the leftover copy of an imported pattern actual) | stands: `--elabuhdm` `fullname`; parse stage 1 |
| 210 F4 (qualified read inside another package's function) | decided: golden writes the law's form, the law under-reaches (W/w01, v11u210 W/vw03 stage 1) |
| 212 q08 (golden folds `$high` in a generate-scope cont_assign) | stands: DIVERGENT downstream, `line` / stage 1 |
| 212 the instance-range stamps (v11u212 E/e05, G/g11) | stand: stage 1 (e05 both views, g11 elaborated) with downstream IDENTICAL; the stamp binds the definition's `[W-1:0]`, golden the instance's folded range (also NS/n01) |
| 212 the exposed names (v11u212 B/b02 `line`, C/c02 and C/c07 `fullname`, A/a13_el `fullname`) | stand |
| 212 v11u212 a06 (late include) | stands, and its mirror SR/s05 (an early include with the larger line) is stage 1 at the base: golden orders anonymous members in the preprocessed stream; the law sorts by (line, column) across files. Pristine and law both lose on a06 (bare vs the wrong member). Not refined: it needs the members' compilation-unit order at the post-pass (a slang SourceLocation map from TypeEmit's member builder), a law, not a refinement of a break |
| 212 SF f04, NS n06 (generate-scope nets: unfired), EA e01 (two importers: unfired) | stand as reported |

Rows at the base: Rggen d `file(3)` (#23164, the Surelog defect), InterfArrayBind d `fullname(1)` (#183),
BlackBePipeInt d `type(1)` (#15272) / t `depth(1)`, anon_struct_packed_dim d/t `fullname(4)` (#766, the `gx` records),
BuildUVMPkg d/t `col(51)` (#26067).

## 10. Fence and process ([evidence/fence/](evidence/fence/))

**This pass.**
* Every driver sources [drivers/env.sh](drivers/env.sh). It reads the four names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh in this checkout and refuses without four: rc 1 beside a two-name canaudit
  copy ([fencecheck.txt](evidence/fence/fencecheck.txt)).
* Corpus databases were byte-compared only through fence-free hard-link mirrors (`fenced_skipped=8`).
* Every census drops fenced paths by word boundary before opening them. The firing census found 0 fenced hits.
* The sweep logs were copied with every fenced-name line dropped (0 such lines existed).
* No fenced source or database was run, read, dumped or decoded outside the gate sweeps' own dispatch, and no gdb
  was used. A word scan of this directory finds no fenced name; the positive control finds the planted file.

**The six directories** (static audit [fenceaudit.txt](evidence/fence/fenceaudit.txt); runtime
[fencecheck.txt](evidence/fence/fencecheck.txt); first lines [casefirst.txt](evidence/fence/casefirst.txt)):

* **env.sh.** The env.sh of r11u209repro, v11u209repro, r11u212repro and v11u212repro reads 4 names from the
  checkout (rc 0) and refuses a two-name copy (rc 1). r11u210repro's resolves the main repository through git's
  common dir: a scratch copy has none and refuses (rc 1, 0 names).
* **v11u210repro has no env.sh.** Each of its corpus-touching drivers reads the fence itself and fails closed:
  `awaycorp.sh`, `det.sh`, `vcase.sh`, `ctlmove.sh`, `switchreach.sh`, `uvmdist.sh`, and `dscase.py` (4 names
  required). `bvmirror.sh` needs `FENCED` exported. `probecmp.sh` reads only probe databases.
* **The drivers without their own check touch no corpus source or database:**
  * `censum.py` (r11u210) reads trace files handed in by the fenced `census.sh`.
  * `away.py` (r11u210, v11u210) reads databases handed in by the fenced `awaycorp.sh`.
  * `caseaway.py` / `join.sh` (v11u209), `ctlsum.py` / `obdist.sh` (r11u210) and `dumpaway.py` / `leftovers.py`
    (v11u210) read outputs.
  * `grid.sh`, `switches.sh`, `judge.sh`, `ctlbytes.sh`, `j.sh` and `k.sh` run the directories' own cases through
    fenced `case.sh`.
  * v11u209's `sweep.sh` runs the gate, which dispatches every row by design.
* **Scratch and hard-coded paths.** Every driver's frozen binaries (`/tmp/r11u209_bin`, `/tmp/v11u209_bin`,
  `/tmp/r11u210_bin`, `/tmp/v11u210_bin`, `/tmp/r11u212_bin`, `/tmp/v11u212_bin`) are gone, so none of the six
  directories re-runs as packaged; each fails closed at its first binary. Further:
  * v11u210repro's `det.sh` runs `cd /tmp/wt_v11u210`, a pruned worktree.
  * v11u210repro's `uvmdist.sh` and `switchreach.sh` set `REPO=/home/heyfey/git-repos/slang-uhdm`: the main
    checkout by absolute path, so a copy reads the main repository's fence (still fail-closed).
  * v11u212repro's `awayrows.py` comment names `/tmp/r11u212_awaycache`, another pass's scratch.
* **Relative writes.** No driver of the six writes relative to its current directory. The static scan's hits are
  docstring words (`dsfaces.py` usage lines, `censum.py`'s "for", `dumpaway.py`'s "and"). Every write in a `cd`
  subshell targets an absolute path.
* **Predictions.**
  * Pass 209: `evidence/movers/predicted_firings_law8.txt` md5 `2eab14f0b9b4...` as claimed, and v11u209's frozen
    copy has the same md5. There is no stamp file with a time, so the order against the law sweep rests on the
    README.
  * Pass 210: `predicted_movers.txt` md5 `6ddcf389...`, equal to its `predicted_frozen_at.txt`, stamped
    2026-09-28T18:33:16Z. 13 rows: 9 corpus row-modes, 3 probe cases, 1 lane.
  * Pass 212: `evidence/census/predicted.txt` md5 `25d42148...` as claimed, 20 rows. `r11u212_cen.log` reads
    `fenced hits (must be 0 0 0 0): 0 0 0 0`. There is no time stamp.
  * The union of the three (83 corpus and probe rows) equals this pass's frozen census of the base, line for line.
* **Packaged cases.** Every case of the six directories names a law that exists in src on its first line: 52, 102,
  28, 36, 75 and 74 cases, the READMEs' counts.
* **Source comments** cite `tools/probe/r11u212verify` twice (the v11u212 refinement's comments). The directory is
  `v11u212repro`.
* Builds `-j 2`, and free memory was checked before each. Binaries were frozen before measurement. No stash,
  `GOLDEN_DEFER` unset. Nothing under `results/`, `tests/` or `third_party/` was written. Scratch is `/tmp/r11u217_*`
  only (worktrees `/tmp/wt_r11u217` and `/tmp/wt_r11u217fix`, the latter removed after the rebuild check). The live
  pairs' worktrees were not touched, and r11u216 had not landed when this pass finished (main HEAD `83ee16d6`).

## 11. Files

* [fix.patch](fix.patch): `src/R217.h` plus the four refinements (UhdmExporter.cpp § anonMemberTdUseCopyKeeps217v,
  ModuleEmit.cpp § ifacePortDeclFoldedBoundLeftOp217v and § ndaQueryFoldsNoStamp217v, StmtEmit.cpp
  § caseItemWildConcatOnly217v). `R11V217_OFF` drops all four; each has its own switch; `R11V217_TRACE=<dir>` names
  every firing. Not applied.
* [cases/](cases/): C 4, CS 3, EA 3, GS 5, HP 4, IA 4, IM 10, IP 5, LV 6, M 3, NS 11, P 3, PD 11, QM 3, SF 2
  (two-file `args` cases), SR 12 (header cases s03 s07 s08 s09, include cases s05), TW 3, W 3, X 5. Each names its
  laws on its first line; C/c04 names § caseItemWildConcatOnly217v, which exists only in fix.patch (casefirst.py reads
  it as not in src at the base).
* [drivers/](drivers/). Copied from r11u213verify and adapted: `env.sh`, `case.sh`, `grid.py`, `gridall.sh`,
  `laws.py`, `lawtable.py`, `mkstate.sh`, `sweep.sh`, `awayrows.py`, `unmask2.py`, `bvmirror.sh`, `lanebytes.sh`,
  `det.sh`, `uvmdist.sh`, `heads.sh`, `obpair.sh`, `dscase.py`, `dsrow.py`, `censum.py`, `firecensus.sh`,
  `fenceaudit.py`, `fencecheck.sh`, `casefirst.py`. Generalised to three landings: `compose.py`, `bytecancel.py`.
  New: `judgetally.py`, `newrecs.py`, `namecensus.sh`, `reach201.sh`, `detob.sh`.
* [evidence/](evidence/):
  * `sweeps/`: logs without progress lines, the cmds audit, binaries and states;
  * `census/`: the frozen prediction and its stamp;
  * `movers/`, `compose/`, `away/`, `unmask/`, `grid/`, `breaks/`, `fix/`, `downstream/`, `determinism/`,
    `residues/`, `fence/`.
