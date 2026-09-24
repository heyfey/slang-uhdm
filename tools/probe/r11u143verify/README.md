# r11u143 — second adversarial verification of pass 133, the r11u141 refinements and pass 137

Verifier pass, base `3bccdec9` (branch matrix-1.87). The laws under test landed at `d8473d78` (pass 133 and its
verifier r11v133: 5 laws), `a7bee711` (r11u141: § includeInactiveTabNotText141v, § ipsQualBaseRangeSpan141v) and
`6ef15be0` (pass 137 with its verifier v11u137: 12 laws, r11u139's four net-binding roads, and the two refinements
`R11V137_DEFWIRE_OFF` / `R11V137_PVQUAL_OFF`). That is 23 laws and 2 refinements. Every case here is new.

**VERDICT: NO BREAK FOUND. No fix.patch ships, and no source file is touched.**

* **Fresh cases.** There are 160 cases: 150 aimed at a law, 5 cross-ground pair cases and 5 fence
  re-derivation cases. Each was judged in default mode and in `--elabuhdm` mode, with its own law off and on and with
  all three landings off and on. Every case was also run under each of the 26 single switches.
* **No field moves away from golden.** In no cell does a law move a field away from golden on legal SystemVerilog:
  * uhdm-cmp: not on any line count or rc.
  * uhdm-strictcmp, field by field: the walk-aligned judge and the difflib-aligned judge both agree.
  * The downstream verdict: not in any cell.
* **Composition is clean.**
  * Across six whole-gate sweeps, no row is non-monotone.
  * Every claimed conversion falls back when its claimant is switched off.
  * The 9 joint rows are conjunctions, not cancellations.
* **The unmaskings and the downstream claims hold.**
  * Every reported count growth is an unmasking.
  * All 31 converted uhdm2rtlil tests are byte-identical downstream.
* **Every ranked residue still stands.**
* **The fence.** The fenced gdb run served residue S3, which is no landed law. Its decode reproduces on fresh cases
  and from Surelog's source, with one correction to its site.

Deliverable: this directory only (`/tmp/r11u143.patch`). Two notes on the brief:

* The brief names "the canonicalisation patch you were given". No patch was given, and none is carried.
  `tools/uhdm-strictcmp` is unchanged, since no comparator defect was found.
* `/tmp/strict_sweep` was not used. Every number here comes from sweeps run for this pass.

| binary | md5 | what |
|---|---|---|
| base `/tmp/r11u143_bin/slang` | `614337e4c8d4b8833fe5c71262db8aae` | `/tmp/wt_r11u143` (system-deps, `-j 2`); byte-identical to the main tree's `build/slang-uhdm` |
| `/tmp/r11u143_bin/strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's `build/uhdm-strictcmp` |
| `/tmp/r11u143_bin/strictx` | `34b24191e2b99f3177f5f33ec2d9e44c` | MEASUREMENT ONLY: `../r11u141verify/drivers/strictx.cpp` (record dumps plus `--diffs`) |
| `/tmp/r11u143_buildg/slang-uhdm` | (not frozen, gdb only) | MEASUREMENT ONLY: the base built with `-g1`; used with gdb on this pass's own fresh fence cases |

All binaries were frozen (`chmod 555`) before they measured anything. Law-off configurations are environment
switches on the ONE base binary: `R11U133_OFF`, `R11V141_OFF`, `R11U137_OFF`, `R11U139_OFF`, `R11V137_OFF` and each
single `*_OFF`. A switch reaches the binary: the six sweeps give six different tallies.

The cmds.txt audit covered all six sweeps (`evidence/sweep_summaries.txt`). In each one, 3273 of 3273 slang lines
(surelog 1531 + uhdm2rtlil 1742) name `/tmp/r11u143_bin/slang`.

## 1. The laws, fresh cases on three axes

**How a cell is judged.** Goldens come from the pinned Surelog: `-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`,
plus `-elabuhdm` in the elab column. They are cached by content md5 under `/tmp/r11u143_gc`. Ours come from
`dut.sv --single-unit --nobuiltin [--elabuhdm]`. The checks per cell:

* `drivers/judge.py` walk-aligns golden, law-off and law-on records. It reports BREAK:eq->ne, WORSE (a field golden
  matched with the law off differs with it on), GROW, OK, TURNED or SAME.
* `drivers/judge2.py` re-checks every judge-equal pair with a difflib alignment.
* A stage-1 pair (uhdm-cmp not equal on both sides) is scored by `drivers/dd.py`. It gives the order-blind uhdm-dump
  distance to golden (excess plus missing lines), with the law off against the law on.
* Downstream: `drivers/ds_case.py` runs the HEAD harness's `one()` under ON, the own law off, and A3 (the three
  landings off).

**Coverage.** Every law fires on at least one fresh cell. Every law but § constCallNameSpan137 and
§ impPaLhsDisjointClone133 turns at least one fresh judge-equal cell strict-equal. Those two fire on stage-1 or
non-equal cells only, and there the dump distance shrinks or the walk aligns further.

Summary (`evidence/law_summary.txt`). The judge column reads judge-equal/strict-equal at the base; then T turned
equal, B better, U unmasking (GROW, decoded below), S stage-1 byte move (distance to golden not larger, except
al04, §1.1), and - untouched.

| law (switch) | cases | default | `--elabuhdm` | BREAK |
|---|---|---|---|---|
| § impPaLhsDisjointClone133 (`R11U133_LHSCLONE_OFF`) | 4 | 2/0 U2 S2 | 2/0 U2 S2 | 0 |
| § hpBaseSelMidMemberBare133 (`R11U133_HPMID_OFF`) | 7 | 7/4 T2 B3 -2 | 7/4 T2 B3 -2 | 0 |
| § hpTrailSelIdxNamesByPath133 (`R11U133_TRAILIDX_OFF`) | 6 | 6/4 T3 -3 | 6/4 T3 -3 | 0 |
| § elabPatQualRefQualSpan133 (`R11U133_PATQUAL_OFF`) | 4 | 2/1 T1 B1 S2 | 2/1 T1 B1 S2 | 0 |
| § unknownParamOperandFile133 (`R11U133_UNKFILE_OFF`) | 8 | 4/4 T4 S3 -1 | 4/4 T4 S3 -1 | 0 |
| § includeInactiveTabNotText141v (`R11V141_INCTABACT_OFF`) | 8 | 8/8 T4 -4 | 8/8 T4 -4 | 0 |
| § ipsQualBaseRangeSpan141v (`R11V141_IPSQUAL_OFF`) | 6 | 3/3 T3 S1 -2 | 3/3 T3 S1 -2 | 0 |
| § elabCloneFullNameUnstored137 (`R11U137_ELABCLONE_OFF`) | 4 | 3/3 -4 | 3/3 **T3** -1 | 0 |
| § packedArrTdElemRefName137 (`R11U137_PATD_OFF`) | 8 | 2/2 T2 S1 -5 | 2/2 T2 S1 -5 | 0 |
| § emptyNamedConnLowConnAtDecl137 (`R11U137_EMPTYCONN_OFF`) | 5 | 4/4 T4 S1 | 4/4 T4 S1 | 0 |
| § unsignedScalarVecTsAtKeyword137 (`R11U137_UNSIGNEDSPAN_OFF`) | 3 | 3/2 T2 B1 | 3/2 T2 B1 | 0 |
| refinement `R11V137_DEFWIRE_OFF` (same law) | 5 | 3/3 T2 S1 -2 | 4/4 T2 S1 -2 | 0 |
| § constCallNameSpan137 (`R11U137_CALLSPAN_OFF`) | 8 | 2/0 B1 S5 -2 | 2/0 B1 S5 -2 | 0 |
| § connReplTsRefThroughPort137 (`R11U137_REPLTSNAME_OFF`) | 4 | 4/4 T3 -1 | 4/4 T3 -1 | 0 |
| § pureVirtProtoSpan137 (`R11U137_PUREVIRTSPAN_OFF`, refinement `R11V137_PVQUAL_OFF`) | 6 | 3/3 T3 S3 | 3/3 T3 S3 | 0 |
| § taggedUnionElabSpan137 (`R11U137_TAGGEDSPAN_OFF`) | 4 | 3/3 T2 -2 | 3/3 T2 -2 | 0 |
| § defNetTypeParamDefault137 (`R11U137_DEFNETTP_OFF`) | 5 | 4/2 T1 B1 U1 -2 | 4/2 T1 B1 U1 -2 | 0 |
| § aliasCloneTakesTargetFile137 (`R11U137_ALIASFILE_OFF`) | 7 | 2/2 T2 S1 -4 | 2/2 T2 S1 -4 | 0 |
| § defNetScopedPkgArrTdShares137 (`R11U137_SCOPEDARRTD_OFF`) | 6 | 2/2 T2 S4 | 2/2 T2 S4 | 0 |
| § structParamPathBaseAtMember137 (`R11U137_PATHBASE_OFF`) | 4 | 3/3 T3 -1 | 3/3 T3 -1 | 0 |
| § caLhsDefNetUnlessOpRhs139 (`R11U139_CA_OFF`) | 18 | 12/12 T2 S3 -13 | 12/12 B2 S3 -13 | 0 |
| § ndaLeftmostLeafElab139 (`R11U139_NDA_OFF`) | 9 | 8/7 T3 -6 | 9/9 B3 -6 | 0 |
| § clockingEventDefNet139 (`R11U139_CLK_OFF`) | 6 | 2/2 T1 S1 -4 | 2/2 B1 S1 -4 | 0 |
| § connLeftmostLeafElab139 (`R11U139_PORT_OFF`) | 5 | 4/4 T4 -1 | 4/4 T3 B1 -1 | 0 |
| **total** | **150** | 96 judge-equal, 82 strict-equal at base; **53 turned equal**, 7 better, 3 unmask, 28 stage-1 moves, 59 untouched | 98 / 85; **49 turned**, 14 better, 3 unmask | **0** |

**The switch battery.** Each of the 26 single switches was run over all 160 cases in both modes, 330 case-mode lines
(`evidence/battery_{default,elab}.txt`, `battery_adv_xg.txt`). The switches that move a cell read:

* TURNED 159, EQUAL-both 7, OK:better 39;
* stage-1 with a dump distance not larger, 85;
* GROW 6 (lc01, lc04 and tp04, both modes);
* the al04 stage-1 delta, 2 (both modes).

The GROW and al04 cells are decoded below. Apart from the cross-ground pairs reported in §2, no switch moves a cell
its law does not claim.

**uhdm-cmp.** In 269 case-mode runs, no case changes its uhdm-cmp line count or rc across ON / own-off / A3.

**Downstream.** 160 cases × {ON, own law off, A3} (`evidence/downstream_cases.jsonl`):

* 144 IDENTICAL, 7 EQUIVALENT, 7 DIVERGENT and 2 STATUS_DIFF with the laws on. All 16 non-IDENTICAL cells are
  stage-1 shapes, and they read the same verdict in all three configurations.
* **No law moves any cell away from IDENTICAL.**
* **§ defNetTypeParamDefault137 improves three downstream verdicts:** tp01 and tp03 go from DIVERGENT to IDENTICAL,
  and tp04 from EQUIVALENT to IDENTICAL. With the law off, the definition net of a type parameter built `int` at the
  use, and the plugin read it. With the law on, the net binds the parameter's default typespec, as golden's does.

### 1.1 The cells that needed a decode (none is a break)

* **§ impPaLhsDisjointClone133 lc01 / lc04: GROW (col, line and endcol counts).** `drivers/unm.sh` and `unmask.py`
  show that with the law off the walk diverges at #48 (#31 for lc04), where the header-import clone is missing. With
  the law on it aligns to the end.
  * The four new `int_typespec` spans are pass 133's residue R5: golden locates `W = GW`'s Rhs typespec at the
    module's own `int`, 4:39-42, where ours has the package's, 3:23-26.
  * The law-off walk holds the same four records, #178-#256, with the same values.
  * The 2 "WORSE past divergence" cells of lc04 are a mis-alignment of the local-key search. The record the law-off
    walk truly aligns to (#94, `int_typespec 4:23-26`) holds the value the law-on walk has.
  * **Unmasking.**
* **§ impPaLhsDisjointClone133 lc02 / lc03 (stage 1).**
  * The dump distance falls: 74 → 52 and 42 → 21.
  * The 3 new excess lines are full prints of the cloned Lhs's typespecs: `\_int_typespec 3:25`,
    `\_param_assign 3:29`, `\_logic_typespec 4:25`. Golden prints the same objects at the module's declaration (R5
    again).
* **§ defNetTypeParamDefault137 tp04: GROW fullname 1 → 5.** The law binds the default typespec, so the walk reaches
  `logic [W-1:0]`'s range reference `W`.
  * Golden leaves that name unstored. Ours carries `<in>T.W`, which is the same face the law-off walk shows at #11.
  * **Unmasking.**
* **§ defNetScopedPkgArrTdShares137 on al04 (a two-dimension alias `typedef a b[1:0][2:0]`; stage 1, A3 distance
  87 → 89).**
  * With the law off, the definition net `v` binds `struct_typespec (ap4::a)`, the wrong object.
  * With the law on it binds `array_typespec (ap4::b)`, the object golden binds.
  * The +2 is a multiset artifact. Golden prints its six `(ap4::b)` listings at `5:11-5:19`, the FIRST dimension
    only. Ours prints every `(ap4::b)` / `(b)` listing at `5:11-5:24`, with the law off too.
  * The law adds one more print of that pre-existing span, and removes one struct print that matched golden by
    coincidence.
  * The object identity moves toward golden; the span is a new residue (§6, N1).
* **§ pureVirtProtoSpan137 pv02 / pv03 (stage 1).** Golden has NO task object for a pure virtual task in an interface
  class (pv02), nor for `pure virtual local task` (pv03). The law moves the span of an object golden lacks (5:49 →
  5:48). Distance 47 → 47 and 47 → 43. This is not a field comparison against golden.
* **§ unsignedScalarVecTsAtKeyword137 dw01 (stage 1, A3 → ON).**
  * The distance falls, 25 → 17.
  * The 2 new excess lines (`\_logic_typespec 6:10-6:15`) are the elaborated view of a `tri logic unsigned` net in a
    generate block. Golden prints them elsewhere.
  * `R11V137_DEFWIRE_OFF` does not move this cell; the refinement's definition-view scope does not reach a
    generate block.
  * In `--elabuhdm` the cell turns strict-equal.
* **The refinements themselves fire on fresh cells.**
  * `R11V137_DEFWIRE_OFF`: dw04 (a parameterized sub-module) and dw05 (an attributed `wand`) turn strict-equal only
    with the refinement on.
  * `R11V137_PVQUAL_OFF`: pv05 (a `pure virtual protected function` in a module-scoped class) turns strict-equal.
  * § includeInactiveTabNotText141v: it01, it03, it04 and it07 turn equal (ifndef of a defined macro, skipped elsif
    after a taken branch, a TAB-led undef, a skipped inner else).
  * Its controls it02, it05, it06 and it08 are untouched and equal: an active outer branch after a skipped inner one,
    a TAB continuation line in a skipped define and in an active define, and a taken elsif.
  * § ipsQualBaseRangeSpan141v: iq01, iq02 and iq05 turn equal (two instances, an operation start index, a
    qualified select nested in a concatenation). Its continuous-assignment control iq04 is untouched.
  * iq06 (`-:`, stage 1) moves the distance 10 → 8.

Cases outside the laws' reach: the law does not fire, the cell keeps its pristine-wrong value, and no field moves.

* tx02 / tx04: a trailing index under a function call or a system call. These keep `work@dut.i`, as golden's own
  path name would not.
* tx06: a trailing indexed part-select, equal either way.
* cs01 / cs04: a call in an unpacked dimension, or in a generate-block range.
* sp01: an unpacked dimension, stage 1.
* ca01-ca10, ca12, ca13 and ca18: at HEAD the CA road moves only parameter-derived right-hand sides that the older `lhsMap`
  list does not catch.
  * The r11u139 grid itself moves on c05, c06 and c07 only.
  * ca16 (`$clog2` in an overridden sub-module) and ca17 (a bit-select of an imported package parameter) are the
    fresh judge-equal cells it turns.

**Illegal shapes dropped.** Two shapes were written and dropped (the generators say so):

* `sp05`, `logic [CFG.DAT-1 -: 4] w`: a part-select as a declaration range. Surelog fails and slang rejects it.
* `dw06`: a net read before its declaration. slang rejects it.

The per-law tables, one row per case, follow. The same text is in `evidence/law_tables.md`, generated by
`drivers/lawtable.py`.

#### unknownParamOperandFile133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_unkfile/uk01_mod | stage1 cmp=32 | stage1 cmp=32 → stage1 cmp=32: stage1 both, dump distance 8→8 | stage1 cmp=32 | stage1 both, dump distance 14→14 | stage1 both, dump distance 8→8 | IDENTICAL |
| p133_unkfile/uk02_and_z | stage1 cmp=32 | stage1 cmp=32 → stage1 cmp=32: stage1 both, dump distance 8→8 | stage1 cmp=32 | stage1 both, dump distance 14→14 | stage1 both, dump distance 8→8 | IDENTICAL |
| p133_unkfile/uk03_sub_override | stage1 cmp=32 | stage1 cmp=32 → stage1 cmp=32: untouched | stage1 cmp=32 | untouched | untouched | EQUIVALENT |
| p133_unkfile/uk04_shift | equal | ne:file(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_unkfile/uk05_unary | equal | ne:file(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_unkfile/uk06_typed_vec_xor | equal | ne:file(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_unkfile/uk07_two_unknown_add | equal | ne:file(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_unkfile/uk08_macro_operand | stage1 cmp=32 | stage1 cmp=32 → stage1 cmp=32: stage1 both, dump distance 8→8 | stage1 cmp=32 | stage1 both, dump distance 14→14 | stage1 both, dump distance 8→8 | IDENTICAL |

#### aliasCloneTakesTargetFile137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_aliasfile/al01_enum_unpacked | stage1 cmp=56 | stage1 cmp=56 → stage1 cmp=56: untouched | stage1 cmp=56 | untouched | stage1 both, dump distance 84→81 | IDENTICAL |
| p137_aliasfile/al02_union_module | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | stage1 cmp=17 | untouched | untouched | IDENTICAL |
| p137_aliasfile/al03_chain | stage1 cmp=56 | stage1 cmp=56 → stage1 cmp=56: stage1 both, dump distance 131→131 | stage1 cmp=56 | stage1 both, dump distance 131→131 | stage1 both, dump distance 131→131 | IDENTICAL |
| p137_aliasfile/al04_two_dims | stage1 cmp=162 | stage1 cmp=162 → stage1 cmp=162: untouched | stage1 cmp=162 | untouched | stage1 both, dump distance 87→89 | EQUIVALENT |
| p137_aliasfile/al05_two_modules | equal | ne:file(5) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_aliasfile/al06_union_pkg | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | stage1 cmp=17 | untouched | stage1 both, dump distance 99→96 | IDENTICAL |
| p137_aliasfile/al07_alias_in_include | equal | ne:file(3) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### constCallNameSpan137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_callspan/cs01_unpacked_dim | stage1 cmp=36 | stage1 cmp=36 → stage1 cmp=36: untouched | stage1 cmp=36 | untouched | untouched | IDENTICAL |
| p137_callspan/cs02_param_port_range | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: stage1 both, dump distance 50→38 | stage1 cmp=17 | stage1 both, dump distance 44→32 | stage1 both, dump distance 50→38 | IDENTICAL |
| p137_callspan/cs03_genif_op_of_calls | stage1 cmp=99 | stage1 cmp=99 → stage1 cmp=99: stage1 both, dump distance 12→4 | stage1 cmp=99 | stage1 both, dump distance 12→4 | stage1 both, dump distance 12→4 | IDENTICAL |
| p137_callspan/cs04_genblock_lp_range | ne:endcol(1) | ne:endcol(1) → ne:endcol(1): untouched | ne:endcol(1) | untouched | untouched | IDENTICAL |
| p137_callspan/cs05_two_args | stage1 cmp=193 | stage1 cmp=193 → stage1 cmp=193: stage1 both, dump distance 8→2 | stage1 cmp=193 | stage1 both, dump distance 8→2 | stage1 both, dump distance 8→2 | IDENTICAL |
| p137_callspan/cs06_genif_in_gencase | ne:fullname(12) | ne:fullname(13) → ne:fullname(12): OK:better=1 | ne:fullname(12) | OK:better=1 | OK:better=1 | IDENTICAL |
| p137_callspan/cs07_sysfunc_arg | stage1 cmp=99 | stage1 cmp=99 → stage1 cmp=99: stage1 both, dump distance 6→2 | stage1 cmp=99 | stage1 both, dump distance 6→2 | stage1 both, dump distance 6→2 | IDENTICAL |
| p137_callspan/cs08_named_arg | stage1 cmp=45 | stage1 cmp=45 → stage1 cmp=45: stage1 both, dump distance 45→43 | stage1 cmp=45 | stage1 both, dump distance 71→69 | stage1 both, dump distance 45→43 | EQUIVALENT |

#### unsignedScalarVecTsAtKeyword137 / R11V137_DEFWIRE

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_defwire/dw01_tri_genblock | stage1 cmp=31 | stage1 cmp=31 → stage1 cmp=31: untouched | equal | untouched | stage1 both, dump distance 25→17 | IDENTICAL |
| p137_defwire/dw02_wor_uwire | stage1 cmp=60 | stage1 cmp=60 → stage1 cmp=60: stage1 both, dump distance 12→4 | stage1 cmp=60 | stage1 both, dump distance 12→4 | stage1 both, dump distance 12→4 | IDENTICAL |
| p137_defwire/dw03_wire_unpacked | equal | equal → equal: untouched | equal | untouched | **turned equal** | IDENTICAL |
| p137_defwire/dw04_param_sub | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_defwire/dw05_attr_wand | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### packedArrTdElemRefName137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_patd/pd01_union_elem | stage1 cmp=78 | stage1 cmp=78 → stage1 cmp=78: untouched | stage1 cmp=78 | untouched | untouched | DIVERGENT |
| p137_patd/pd02_port_type | stage1 cmp=194 | stage1 cmp=194 → stage1 cmp=194: untouched | stage1 cmp=194 | untouched | untouched | DIVERGENT |
| p137_patd/pd03_vec_elem | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | stage1 cmp=17 | untouched | untouched | DIVERGENT |
| p137_patd/pd04_genblock_td | stage1 cmp=238 | stage1 cmp=238 → stage1 cmp=238: untouched | stage1 cmp=238 | untouched | untouched | DIVERGENT |
| p137_patd/pd05_struct_always | equal | ne:fullname(5) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_patd/pd06_pkg_enum_localparam | stage1 cmp=198 | stage1 cmp=198 → stage1 cmp=198: untouched | stage1 cmp=198 | untouched | untouched | IDENTICAL |
| p137_patd/pd07_import_struct | equal | ne:fullname(12) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_patd/pd08_func_return | stage1 cmp=116 | stage1 cmp=116 → stage1 cmp=116: stage1 both, dump distance 49→45 | stage1 cmp=116 | stage1 both, dump distance 57→53 | stage1 both, dump distance 49→45 | IDENTICAL |

#### pureVirtProtoSpan137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_purevirt/pv01_module_class_defaults | equal | ne:endline(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_purevirt/pv02_iface_class_task | stage1 cmp=103 | stage1 cmp=103 → stage1 cmp=103: stage1 both, dump distance 47→47 | stage1 cmp=103 | stage1 both, dump distance 47→47 | stage1 both, dump distance 47→47 | IDENTICAL |
| p137_purevirt/pv03_local_task | stage1 cmp=162 | stage1 cmp=162 → stage1 cmp=162: stage1 both, dump distance 47→43 | stage1 cmp=162 | stage1 both, dump distance 50→44 | stage1 both, dump distance 47→43 | IDENTICAL |
| p137_purevirt/pv04_extends_override | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_purevirt/pv05_module_protected_func | equal | ne:endcol(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_purevirt/pv06_param_class | stage1 cmp=18 | stage1 cmp=18 → stage1 cmp=18: stage1 both, dump distance 7→3 | stage1 cmp=18 | stage1 both, dump distance 9→3 | stage1 both, dump distance 7→3 | IDENTICAL |

#### defNetScopedPkgArrTdShares137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_scopedarrtd/sd01_enum_elem | stage1 cmp=56 | stage1 cmp=56 → stage1 cmp=56: stage1 both, dump distance 92→89 | stage1 cmp=56 | stage1 both, dump distance 93→90 | stage1 both, dump distance 92→89 | IDENTICAL |
| p137_scopedarrtd/sd02_port_type | stage1 cmp=105 | stage1 cmp=105 → stage1 cmp=105: stage1 both, dump distance 207→204 | stage1 cmp=105 | stage1 both, dump distance 209→206 | stage1 both, dump distance 207→204 | STATUS_DIFF |
| p137_scopedarrtd/sd03_ascending_init | stage1 cmp=11 | stage1 cmp=11 → stage1 cmp=11: stage1 both, dump distance 55→55 | stage1 cmp=11 | stage1 both, dump distance 57→57 | stage1 both, dump distance 55→55 | EQUIVALENT |
| p137_scopedarrtd/sd04_struct_two_lines | equal | ne:type(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_scopedarrtd/sd05_bit_elem | stage1 cmp=105 | stage1 cmp=105 → stage1 cmp=105: stage1 both, dump distance 160→157 | stage1 cmp=105 | stage1 both, dump distance 161→158 | stage1 both, dump distance 160→157 | EQUIVALENT |
| p137_scopedarrtd/sd06_odd_bounds | equal | ne:type(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### caLhsDefNetUnlessOpRhs139

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p139_ca/ca01_nonansi_op | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca02_repl_rhs | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca03_delay_op | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca04_inst_array_child | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca05_partsel_rhs | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca06_member_rhs | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca07_ips_rhs_sub_two | equal | equal → equal: untouched | equal | untouched | **turned equal** | IDENTICAL |
| p139_ca/ca08_var_index_rhs | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca09_bits_sysfunc | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca10_pkg_param_partsel | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca11_struct_param_member_override | stage1 cmp=84 | stage1 cmp=84 → stage1 cmp=84: stage1 both, dump distance 181→179 | stage1 cmp=84 | stage1 both, dump distance 181→179 | stage1 both, dump distance 181→179 | EQUIVALENT |
| p139_ca/ca12_param_bitsel_logic_lhs | stage1 cmp=48 | stage1 cmp=48 → stage1 cmp=48: untouched | stage1 cmp=52 | untouched | untouched | IDENTICAL |
| p139_ca/ca13_top_pkg_partsel | stage1 cmp=58 | stage1 cmp=58 → stage1 cmp=58: untouched | stage1 cmp=58 | untouched | untouched | IDENTICAL |
| p139_ca/ca14_nested_member_localparam | stage1 cmp=489 | stage1 cmp=489 → stage1 cmp=489: stage1 both, dump distance 207→207 | stage1 cmp=489 | stage1 both, dump distance 207→207 | stage1 both, dump distance 207→207 | IDENTICAL |
| p139_ca/ca15_countones_param | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: stage1 both, dump distance 32→32 | stage1 cmp=17 | stage1 both, dump distance 42→42 | stage1 both, dump distance 32→32 | DIVERGENT |
| p139_ca/ca16_clog2_sub_override | equal | ne:count(0) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_ca/ca17_imported_param_bitsel | equal | ne:count(0) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_ca/ca18_genblock_param_bitsel | stage1 cmp=40 | stage1 cmp=40 → stage1 cmp=40: untouched | stage1 cmp=40 | untouched | untouched | STATUS_DIFF |

#### clockingEventDefNet139

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p139_clk/ck01_edge | stage1 cmp=29 | stage1 cmp=29 → stage1 cmp=29: untouched | stage1 cmp=29 | untouched | untouched | IDENTICAL |
| p139_clk/ck02_bitsel_clock | stage1 cmp=351 | stage1 cmp=351 → stage1 cmp=351: untouched | stage1 cmp=351 | untouched | untouched | IDENTICAL |
| p139_clk/ck03_genblock_sub | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_clk/ck04_skews | stage1 cmp=273 | stage1 cmp=273 → stage1 cmp=273: untouched | stage1 cmp=273 | untouched | untouched | IDENTICAL |
| p139_clk/ck05_two_blocks | stage1 cmp=429 | stage1 cmp=429 → stage1 cmp=429: stage1 both, dump distance 58→58 | stage1 cmp=429 | stage1 both, dump distance 60→60 | stage1 both, dump distance 58→58 | IDENTICAL |
| p139_clk/ck06_global_sub | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |

#### ndaLeftmostLeafElab139

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p139_nda/nd01_concat_leftmost | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd02_call_leftmost | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd03_cast_leftmost | ne:depth(1) | ne:depth(1) → ne:depth(1): untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd04_member_leftmost | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd05_compare | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_nda/nd06_nested_left_chain | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_nda/nd07_logical_unary_left | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd08_sub_two_inst | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_nda/nd09_genblock | stage1 cmp=31 | stage1 cmp=31 → stage1 cmp=31: untouched | equal | untouched | untouched | IDENTICAL |

#### hpBaseSelMidMemberBare133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_hpmid/hm01_partsel_leaf | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p133_hpmid/hm02_2d_base | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_hpmid/hm03_ff_if_cond | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_hpmid/hm04_port_actual | ne:fullname(2) | ne:fullname(3) → ne:fullname(2): OK:better=1 | ne:fullname(1) | OK:better=2 | OK:better=1 | IDENTICAL |
| p133_hpmid/hm05_ips_leaf | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p133_hpmid/hm06_base_index_op | ne:fullname(2) | ne:fullname(4) → ne:fullname(2): OK:better=2 | ne:fullname(2) | OK:better=2 | OK:better=2 | IDENTICAL |
| p133_hpmid/hm07_nb_lvalue_member_idx | ne:fullname(2) | ne:fullname(4) → ne:fullname(2): OK:better=2 | ne:fullname(2) | OK:better=2 | OK:better=2 | IDENTICAL |

#### hpTrailSelIdxNamesByPath133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_trailidx/tx01_idx_ternary | equal | ne:fullname(6) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_trailidx/tx02_idx_funccall | ne:fullname(4) | ne:fullname(4) → ne:fullname(4): untouched | ne:fullname(4) | untouched | untouched | IDENTICAL |
| p133_trailidx/tx03_idx_int_var | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_trailidx/tx04_idx_sysfunc | ne:fullname(2) | ne:fullname(2) → ne:fullname(2): untouched | ne:fullname(2) | untouched | untouched | IDENTICAL |
| p133_trailidx/tx05_idx_sub_op | equal | ne:fullname(4) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_trailidx/tx06_trailing_ips_var | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |

#### defNetTypeParamDefault137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_defnettp/tp01_pkg_typedef_default | equal | ne:type(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL; DIVERGENT; DIVERGENT |
| p137_defnettp/tp02_signed_vec_default | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p137_defnettp/tp03_unit_enum_default | ne:file(1) | ne:name(3) → ne:file(1): OK:better=7 | ne:file(1) | OK:better=7 | OK:better=7 | IDENTICAL; DIVERGENT; DIVERGENT |
| p137_defnettp/tp04_dependent_default | ne:fullname(5) | ne:fullname(3) → ne:fullname(5): GROW:fullname:1->5 | ne:fullname(4) | GROW:fullname:1->4 | GROW:fullname:1->5 | IDENTICAL; EQUIVALENT; EQUIVALENT |
| p137_defnettp/tp05_packed_dim_on_tp | stage1 cmp=36 | stage1 cmp=36 → stage1 cmp=36: untouched | stage1 cmp=36 | untouched | untouched | IDENTICAL |

#### emptyNamedConnLowConnAtDecl137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_emptyconn/en01_inout | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_emptyconn/en02_struct_port | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_emptyconn/en03_multiline_attr_decl | stage1 cmp=27 | stage1 cmp=27 → stage1 cmp=27: stage1 both, dump distance 11→9 | stage1 cmp=27 | stage1 both, dump distance 11→9 | stage1 both, dump distance 11→9 | IDENTICAL |
| p137_emptyconn/en04_with_wildcard | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_emptyconn/en05_unpacked_port | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### taggedUnionElabSpan137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_tagged/tu01_struct_member | equal | ne:endcol(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_tagged/tu02_genblock | stage1 cmp=174 | stage1 cmp=174 → stage1 cmp=174: untouched | stage1 cmp=174 | untouched | untouched | DIVERGENT |
| p137_tagged/tu03_signed | equal | ne:endcol(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_tagged/tu04_port_type | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |

#### connLeftmostLeafElab139

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p139_port/pc01_inst_array_op | stage1 cmp=240 | stage1 cmp=240 → stage1 cmp=240: untouched | stage1 cmp=240 | untouched | untouched | EQUIVALENT |
| p139_port/pc02_paren_nested | equal | ne:fullname(3) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p139_port/pc03_param_sub_concat | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_port/pc04_bitsel_right | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p139_port/pc05_genblock_op | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### includeInactiveTabNotText141v

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p141_inctabact/it01_ifndef_defined | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_inctabact/it02_inner_skip_outer_tab_after | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p141_inctabact/it03_elsif_after_taken | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_inctabact/it04_skip_tab_undef_after | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_inctabact/it05_skipped_continuation | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p141_inctabact/it06_active_continuation | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p141_inctabact/it07_skipped_inner_else | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_inctabact/it08_elsif_taken_tab | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |

#### ipsQualBaseRangeSpan141v

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p141_ipsqual/iq01_sub_two_inst | equal | ne:col(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_ipsqual/iq02_op_start | equal | ne:col(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_ipsqual/iq03_genblock_lp | stage1 cmp=56 | stage1 cmp=56 → stage1 cmp=56: untouched | stage1 cmp=56 | untouched | untouched | IDENTICAL |
| p141_ipsqual/iq04_contassign_ctl | stage1 cmp=62 | stage1 cmp=62 → stage1 cmp=62: untouched | stage1 cmp=62 | untouched | untouched | IDENTICAL |
| p141_ipsqual/iq05_in_concat | equal | ne:col(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_ipsqual/iq06_minus_localparam | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: stage1 both, dump distance 10→8 | stage1 cmp=64 | stage1 both, dump distance 10→8 | stage1 both, dump distance 10→8 | DIVERGENT |

#### impPaLhsDisjointClone133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_lhsclone/lc01_gen_for_inst | ne:line(4) | ne:depth(1) → ne:line(4): GROW:endline:0->4,col:1->4,line:0->4,endcol:1->4 | ne:line(4) | GROW:endline:0->4,col:1->4,line:0->4,endcol:1->4 | GROW:endline:0->4,col:1->4,line:0->4,endcol:1->4 | IDENTICAL |
| p133_lhsclone/lc02_pkg_explicit_pkg | stage1 cmp=50 | stage1 cmp=50 → stage1 cmp=50: stage1 both, dump distance 74→52 | stage1 cmp=50 | stage1 both, dump distance 74→52 | stage1 both, dump distance 74→52 | IDENTICAL |
| p133_lhsclone/lc03_two_pkgs_hdr | stage1 cmp=87 | stage1 cmp=87 → stage1 cmp=87: stage1 both, dump distance 42→21 | stage1 cmp=87 | stage1 both, dump distance 42→21 | stage1 both, dump distance 42→21 | IDENTICAL |
| p133_lhsclone/lc04_macro_pkg_param | ne:line(2) | ne:depth(1) → ne:line(2): GROW:col:1->2,endcol:1->2 | ne:line(2) | GROW:col:1->2,endcol:1->2 | GROW:col:1->2,endcol:1->2 | IDENTICAL |

#### elabPatQualRefQualSpan133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_patqual/pq01_positional_pattern | stage1 cmp=52 | stage1 cmp=52 → stage1 cmp=52: stage1 both, dump distance 81→73 | stage1 cmp=60 | stage1 both, dump distance 84→76 | stage1 both, dump distance 81→73 | IDENTICAL |
| p133_patqual/pq02_nested_struct | stage1 cmp=112 | stage1 cmp=112 → stage1 cmp=112: stage1 both, dump distance 288→280 | stage1 cmp=112 | stage1 both, dump distance 288→280 | stage1 both, dump distance 290→280 | IDENTICAL |
| p133_patqual/pq03_two_params | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_patqual/pq04_genif_inst | ne:fullname(1) | ne:endcol(2) → ne:fullname(1): OK:better=1 | ne:fullname(1) | OK:better=1 | OK:better=1 | IDENTICAL |

#### elabCloneFullNameUnstored137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_elabclone/ee01_iface_process | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | stage1 cmp=17 | untouched | untouched | IDENTICAL |
| p137_elabclone/ee02_func_struct_local | equal | equal → equal: untouched | equal | **turned equal** | untouched | IDENTICAL |
| p137_elabclone/ee03_latch_case_block | equal | equal → equal: untouched | equal | **turned equal** | untouched | IDENTICAL |
| p137_elabclone/ee04_task_output_arg | equal | equal → equal: untouched | equal | **turned equal** | untouched | IDENTICAL |

#### structParamPathBaseAtMember137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_pathbase/sp01_unpacked_dim | stage1 cmp=50 | stage1 cmp=50 → stage1 cmp=50: untouched | stage1 cmp=50 | untouched | untouched | IDENTICAL |
| p137_pathbase/sp02_typedef_range | equal | ne:col(6) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_pathbase/sp03_genif_and | equal | ne:col(4) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_pathbase/sp04_genblock_net_range | equal | ne:col(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### connReplTsRefThroughPort137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_repl/rp01_net_operand_ctl | equal | equal → equal: untouched | equal | untouched | **turned equal** | IDENTICAL |
| p137_repl/rp02_struct_port | equal | ne:fullname(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_repl/rp03_genfor | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_repl/rp04_nonansi_child | equal | ne:fullname(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### unsignedScalarVecTsAtKeyword137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_unsigned/us01_unpacked_mem | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_unsigned/us02_typedef | equal | ne:endcol(12) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_unsigned/us03_genblock_iface | ne:endcol(1) | ne:endcol(5) → ne:endcol(1): OK:better=4 | ne:endcol(1) | OK:better=4 | OK:better=4 | IDENTICAL |

## 2. Composition (evidence/composition_census.txt, claimed_conversions_check.txt, law_pairs_*.txt)

**Six whole-gate sweeps** of the ONE base binary: probe, surelog and uhdm2rtlil in both modes, plus downstream for ON
and A3. Workdirs are `/tmp/r11u143_wd{ON,33,37,3B,A3,41}`. The bits are (133 on, 141 on, 137 on), where 137 means
`R11U137_OFF` + `R11U139_OFF` + `R11V137_OFF`.

| configuration | surelog strict-equal (of 1596 row-modes; 954 judge-equal) | uhdm2rtlil (of 1742; 1606) | probe (of 4087) |
|---|---|---|---|
| ON (1,1,1) = the base | 772 | 1384 | 2272 |
| 133 off (0,1,1) | 767 | 1368 | 2183 |
| 137 off (1,1,0) | 709 | 1334 | 2221 |
| 133 + 137 off (0,1,0) | 704 | 1320 | 2139 |
| all three off (0,0,0) | 704 | 1320 | 2139 |
| 141 off (1,0,1) | 772 | 1384 | 2272 |

**Status and monotonicity.**

* Judge-equal status never differs across the six configurations, on any row or case.
* NON-MONOTONE rows: **0** in all three sets. No row is equal in one configuration and not equal in a configuration
  with a superset of the landings on.
* The 141-off csv equals the ON csv, and the all-off csv equals the 133+137-off csv, row for row. At the byte level
  (`byteverify_41_vs_ON_*`), 141-off vs ON moves 7 surelog databases and 0 uhdm2rtlil. Those 7 are the UVM coin:
  MiniAmiq d/t, SeqDriver d/t and SimpleUVM d/t read 4 order-blind dump lines each, and Scoreboard/default reads 0
  (`evidence/uvm_coin_41_vs_ON.txt`).
* The probe moves 0 of 4087.
* So r11u141's refinements are inert on both corpora and the probe set, as r11u141 predicted.

**Byte movers per landing** (same-length workdirs, `SELFCHECK=1 byteverify.sh`, PATH_SETS_IDENTICAL, selfcheck
959/960 and 1607/1608):

* 133-off vs ON: **33 + 56 = 89**. This is pass 133's 89 exactly.
* 137-off vs ON: **128 + 76 = 204**. This is pass 137's 204 exactly.
* A3 vs ON: 142 + 124 = 266 = the union of the two (overlap 27).
* Probe: 133-off moves **283** (pass 133's 283), 137-off moves 164, A3 moves 414 = the union (overlap 33), and 141-off
  moves 0.

**Every claimed conversion is its claimant's** (`claimed_conversions_check.txt`):

* Pass 133: 19 corpus row-modes and the 81 probe cases of `r11u133repro/evidence/probe_conversions_by_law.txt` are
  all equal at the base. All fall back with `R11U133_OFF`, and none needs pass 137.
* Pass 133's landing counted 82 probe conversions. The 82nd is r10earl_repro/vf, which needs § impPaLhsDisjointClone133
  alone (the switch battery gives TURNED).
* Pass 137: the 155 TURNED_EQUAL rows of `r11u137repro/evidence/cols_P_L.tsv` (63 surelog, 48 uhdm2rtlil, 44 probe)
  are all equal at the base, and all fall back with the 137 switches.

**The joint rows** are the difference between pass 137's README (48 / 44) and its landing commit (50 / 51). Each needs
BOTH landings. Each is a conjunction: with the pair off, the row is further from golden than with either law off.
For every pair, (A-off ∩ B-off) − both-off = 0 fields.

| row | laws (from the single-switch battery, `law_battery_overlap_rows.tsv`, `probe_overlap_switches.txt`) | pair check |
|---|---|---|
| struct_param_repl_count, both modes (uhdm2rtlil) | § impPaLhsDisjointClone133 + § elabPatQualRefQualSpan133 + § structParamPathBaseAtMember137 (three laws; each alone off gives fullname / endcol / col) | three pairs, no cancellation |
| probe r11u20repro/b7, v11u94repro/b2_cfg94 | § elabPatQualRefQualSpan133 + § structParamPathBaseAtMember137 | no cancellation (A=1, B=2 / 104, both = 3 / 105 fields) |
| probe r11u51repro/grid/e1_ca_rhskind, r11v55repro/grid/vv4_singleread, vv6_edge, vv8_sharemut, r11v69repro/grid/w1_netlhs | § elabPatQualRefQualSpan133 + § caLhsDefNetUnlessOpRhs139 | no cancellation (endcol, and the CA road's depth) |

**Cross-ground pairs.**

* § impPaLhsDisjointClone133 with § elabCloneFullNameUnstored137 fire together on DefaultPatternInt/testflags and
  Kmac/testflags.
* § hpTrailSelIdxNamesByPath133 fires with ELABCLONE on FuncStructVal/testflags.
* § impPaLhsDisjointClone133 fires with § ndaLeftmostLeafElab139 on BlackBePipeInt, both modes.
* § elabPatQualRefQualSpan133 fires with § structParamPathBaseAtMember137 on StructParamFieldRange and
  cva6_struct_param_field; LHSCLONE fires with PATHBASE on struct_param_func_config; PATQUAL fires with the CA road on
  struct_param_pattern_packing.
* Every one is independent (`law_pairs_corpus.txt`): the both-off field set is the union of the single-off sets.
* No corpus row or probe case co-fires § hpTrailSelIdxNamesByPath133 with a net-binding road. Five fresh pair cases
  therefore construct it (cases/xg_pairs, both modes; `xg_pairs_judge.txt`):
  * x01: a trailing-select path as the leftmost leaf of a net declaration assignment.
  * x02: a path inside an operation port actual.
  * x03: a trailing-select right-hand side in a sub-module.
  * x04 and x05: LHSCLONE + ELABCLONE in `--elabuhdm` (a header-import module with a function; a package importing a
    package read in a process).
  * Results: x01 and x03 turn strict-equal with TRAILIDX (NDA and CA do not fire there). x02, x04 and x05 show each
    law improving and the pair independent, with **no cancellation**.
  * x02 keeps a composed residue (§6, N2).

## 3. The unmaskings (evidence/unmask_pass133_rows*.txt, unmask_pass137_rows.txt, unmask_pass137_probe.txt)

**The method.** `drivers/rowunmask.sh` dumps strict records of golden vs law-off and golden vs law-on.
`drivers/unmask2.py` aligns golden with the law-off walk by difflib in a window around the new differences. For
every field the law-on walk differs on that the law-off walk did not report, it gives one class:

* UNMASKED: the law-off record for the same object holds the same off-golden value, found by alignment or by content
  match on every other field.
* WORSE: the law-off record matched golden.
* PAST-L-DIVERGENCE: the field sits at or after the law-on walk's own structural divergence, where records are not
  compared.

| row | at base / law off | walk divergence off → on | L-only fields | classes |
|---|---|---|---|---|
| Earlgrey_0_1 d and t (pass 133) | line(1051) / line(1028) (+23, pass 133's +23) | #50756 → #51100 (t: #52002 → #52346) | 31 | UNMASKED 23 (the param_assign `endcol` = golden+1 face), PAST-L-DIVERGENCE 8, **WORSE 0** |
| ibex_tracer d and t (pass 133) | fullname(87) / fullname(44) (+43) | #3727 → #4880 | 51 | UNMASKED 6; NEWOBJ 37 (below); PAST-L-DIVERGENCE 8; **WORSE 0** |
| ParameterFromPkgOnParameterPortList d and t (pass 133) | fullname(8) / depth(1) | #160 → #262 (t: #70 → #172) | 40 | UNMASKED 31, PAST-L-DIVERGENCE 9, **WORSE 0** |
| Rggen/default (pass 133, not in the brief) | file(9) / file(5) | #439 → #466 | 20 | UNMASKED 5, PAST-L-DIVERGENCE 15, **WORSE 0** |
| YosysOldOr d and t (pass 137) | line(595) / line(78) | aligns to the end | 1046 | **UNMASKED 1046** |
| YosysRiscv d and t (pass 137) | endcol(86) / endcol(67) | — | 40 | **UNMASKED 40** |
| DelayAssign/default (pass 137) | value(16) / value(8) | — | 9 | **UNMASKED 9** |
| YosysOldOpen d (t: fullname(4) / depth(1)) (pass 137) | line(17) / line(14) | — | 4 | **UNMASKED 4** |
| probe r10earl54repro/v10step1 (pass 137) | endcol(16) / endcol(11) | #183 → end | 10 | **UNMASKED 10** |
| probe r10earl54repro/v3_v54 (pass 137) | col(132) / col(70) | #154 → end | 124 | **UNMASKED 124** |
| probe r10earl94repro/g3_kind94 (pass 137) | fullname(18) / fullname(17) | #856 → end | 8 | **UNMASKED 8** |

**ibex_tracer's 37 NEWOBJ fields.**

* These are records of the object § impPaLhsDisjointClone133 supplies: the package listing's own copy of
  `ibex_tracer_pkg::ExcCauseIrqSoftwareM`, which the law-off walk lacked.
* The differing field is the raw full name of its struct typespec's member references:
  * golden: `ibex_tracer_pkg::ExcCauseIrqSoftwareM::ibex_pkg::exc_cause_t::irq_int`
  * ours: `...ExcCauseIrqSoftwareM.ibex_pkg::exc_cause_t.irq_int`
* The law-off walk carries the same dot-form name on the shared object (5 records, 0 colon-form). The law-on walk has
  7 records, 0 colon-form; golden has 4 dot-form and 4 colon-form.
* So this is the pre-existing member-name face inside a parameter's typespec copy (r11u134's R1), reached on the new
  object. **Unmasking.**

Two probe GROW cells of LHSCLONE are unmaskings too (`unmask_probe_lhsclone_grow.txt`):

* r11u20repro/b4: 179 UNMASKED.
* v11u114repro/set1/g25: 2 UNMASKED. Its "divergence" at #254 is a pre-existing extra `constant 4:35-4:47` that
  the law-off walk also holds, at #240.

## 4. Downstream

**Gate.** The base's downstream stage reads `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and
not excused=0`. Joined to results/downstream_uhdm2rtlil.csv, it differs on 0 of 871 rows on any column. The A3 sweep's
downstream stage reads the same verdict and `differs` on 871 of 871 rows. The two landings are strict-only
downstream.

**Converted rows, by bytes.** For all **31** converted uhdm2rtlil tests (pass 133: 7; pass 137: 24),
`evidence/downstream_bytes_converted_u2r.txt` compares the Surelog lane and the slang lane. `_nohier.il`, `.il` and
`_synth.v` are byte-identical for all 31 (md5 per file). Two per pass:

    133 dyn_field_select BYTE-IDENTICAL nohier.il:374df2d8f2d7=374df2d8f2d7 .il:cbe4e6f53a2f=cbe4e6f53a2f synth.v:fdb0d78f1b35=fdb0d78f1b35
    133 struct_param_func_loop BYTE-IDENTICAL nohier.il:85df062633db=85df062633db .il:4d68c6af471e=4d68c6af471e synth.v:511e71df601a=511e71df601a
    137 wandwor BYTE-IDENTICAL nohier.il:d7bc071d538e=d7bc071d538e .il:cda8a80c735e=cda8a80c735e synth.v:797d10274d55=797d10274d55
    137 sva_value_change_changed BYTE-IDENTICAL nohier.il:b504620c87ca=b504620c87ca .il:443d0685be13=443d0685be13 synth.v:a60250aabbf3=a60250aabbf3

* **Positive control:** func_upto, an EQUIVALENT row, reads DIFFER on `_nohier.il`.
* The lane databases are the frozen base binary's own output. Re-derived with `-DSYNTHESIS dut.sv --single-unit
  --nobuiltin`, dyn_field_select gives `d5a71026865f` and wandwor `35cc6645f3d7`, the same as the sweep's.
  `d5a71026865f` is pass 133's law database.

## 5. The ranked residues, re-measured at 3bccdec9 (evidence/residue_rows_remeasured.txt, residue_cases_remeasured.txt)

| pair | residue (top three) | measured at the base (first strict difference) | status |
|---|---|---|---|
| r11u133 R1 | range-bound fold's ref_typespec name | ParameterInitializedByPartSelectOfParametersAssignedToVar d/t `fullname(1)`: #150 ref_typespec golden '' ours `<in>` | stands |
| r11u133 R2 | package pattern parameter read in its own package | pkr/p01 `col` (fullname 2, col 1, endcol 1), pkr/u01 `col` (4 objects); iface_zero_width_field `col(8)`: `B` ref under `B.CTL` in a package typedef range, golden 11:14 (the member token), ours 11:12 | stands |
| r11u133 R3 | hier_path spans built by emitSyntaxExpr | iface_param_2level `col(3)`: `CFG` under `CFG.BUS.DAT` in the interface range, golden 10:14 ours 10:10 (§ structParamPathBaseAtMember137 does not reach this range, `work@tif.data`); genvar_iface_struct `endcol(3)`, iface_array_modport_drive `endcol(2)`: definition-view gen paths `man[i].vld` 15:12-15 vs ours -22. **Closed since pass 133:** iface_array_elem_cfg_param, iface_cfg_param_def_pass (by pass 137), struct_param_repl_count (by 133 + 137 jointly, §2) | stands (3 of its 6 named rows closed) |
| r11v133 F2 | spaced qualifier in the definition listing | pqs/d01 `endcol(1)` | stands |
| r11v133 F3 | macro-born `pkg::NAME` | pqs/d06 `endcol(1)` | stands |
| r11v133 F4 | generate-scope trailing select; hier_path index | tix/a02 and f06 `fullname(2)`, a07 `fullname(2)` | stands |
| r11u137 R1 | net-binding leftovers | YosysBigSimEllip/default `fullname(3039)`: #8924 golden `...label[0].c.i` (the port chain), ours `...label[0].i`; PortExpr d/t `endline(14)`; ExplictiPorts d `line(8)` t `line(15)`; pc31 `col(1)`, pc33 `fullname(2)` | stands |
| r11u137 R2 | elab-clone leftovers | CarryAdd/t `fullname(2)` (`STAGE.i`), SequenceInst/t `fullname(6)` (`work@m.a1.p_triggers.a` vs `p_triggers.a`), HierPathTypespec/t `fullname(1)`, GenScopeHierPath3/t `fullname(163)` | stands |
| r11u137 R3 | N0084 / N0638 / N0096 | StructParamFieldRange d/t `endcol(5)`, StructParamFuncBodyFieldCompare `depth(1)`, StructParamPatternInitCast `fullname(2)`, IOClassStruct d `fullname(3)` t `fullname(5)` | stands |
| v11u137 1 | attribute start of a prototype | brk/cases/f04 `col(1)` | stands |
| v11u137 2 | non-pure `virtual function` with a body | f05 `endcol(1)` | stands |
| v11u137 3 | replication inside a concatenation actual | e01 `fullname(1)` | stands |

## 6. New residues (measured here, not landed)

* **N1.** A multi-dimension unpacked typedef (`typedef a b[1:0][2:0]`). Golden spans every listing of it to the FIRST
  dimension (5:11-5:19); ours spans to the last (5:24) and names some copies `b` for `ap4::b` (al04, stage 1).
* **N2.** A trailing-select path inside an operation port actual (xg_pairs/x02, `q & tbl[r].sat[i]`). Golden names
  every reference under the actual by the port chain, `work@dut.u.a.tbl[r].sat[i].i`, and the base-select index `r`
  binds the definition net. With both § hpTrailSelIdxNamesByPath133 and § connLeftmostLeafElab139 on, ours keeps
  `work@dut.r` / the path name without the chain. This is r11u133's R7 composed with the port road.
* **N3.** Five fresh shapes are stage 1 AND downstream DIVERGENT on every configuration, so they are pre-existing:
  * pd01-pd04: packed-array typedefs over a union element, a port type, a logic-vector element, and a generate-block
    enum.
  * tu02: a tagged union in a generate block.
  * ca15: `$countones(P)` onto an int.
  * iq06: `p::A[11 -: 4]`.
  * The netlists differ in a constant ("Constant value mismatch").
* **N4.** Interface-class pure virtual tasks (pv02) and `pure virtual local task` (pv03) produce no task object in
  golden. Ours emits one.
* **N5.** § caLhsDefNetUnlessOpRhs139's live domain at HEAD is narrow: 3 of its own 23 grid cells and 5 of 18 fresh
  cells. Every other shape is already routed by the older `lhsMap` right-hand-side list. The law is correct where it
  fires, but most of its grid no longer tests it.

## 7. The fence: which law the gdb decode served, re-derived on unfenced evidence (evidence/fence_s3.txt)

**Which face.** Section 6 of r11u137repro/README.md reports a gdb run on a scratch copy of a slang-fenced test's
source, "to locate the enum mint", and points to its section 7, **S3**. S3 is decoded and NOT landed:

> the struct member's enum copy is minted by ParamEmit.cpp emitPackage (the import-clone `buildEnumTs(..., nm2)`
> beside the pkgImportCloneTs alias) without its base-type ref and file; golden's is the package's
> elaborated-listing enum. (map cluster N0057; carriers: the nested-submodule parameter family, 8 uhdm2rtlil
> row-modes)

**No landed law rests on that decode.**

* Pass 137's patch touches no ParamEmit.cpp. Its commit lists N0057 under "decoded, not landed".
* The 16 laws of pass 137 are the ones tested in §1.
* The breach therefore affects the provenance of residue S3 only.

**Re-derivation on this pass's own cases** (cases/fence_s3, five fresh shapes; no fenced source and no copy of one
was read, run or referenced):

* **The cases.**
  * f01: package B wildcard-imports package A and types a struct member with A's enum; a top parameter of B's struct.
  * f02: an explicit import.
  * f03: a variable, not a parameter.
  * f04 (control): B names the enum by its SCOPED name `ea4::ph_e`, with no import.
  * f05: the member reaching a sub-module parameter through an override.
* **Golden vs ours.** All five are stage 1 (uhdm-cmp 17 lines), with one head: golden holds a
  `ref_typespec (…::st_e)` base-type reference under an `enum_typespec` copy, and ours has `RHS: <null>`.
* **The dump (f04).** Golden's per-use copies of `ea4::ph_e` under package eb4's struct keep vpiInstance = the
  **home** package ea4, with vpiBaseTypespec and the base `logic_typespec`. Ours mints a copy with vpiInstance = eb4
  and no base typespec (the file is not copied either: `cl9` copies the four span fields only).
* **Our mint site**, from gdb on the `-g1` base build over f01, f03 and f04 only:
  * ParamEmit.cpp emitPackage, the member loop's "FRESH per-use clone": `buildEnumTs(*et9, nullptr, ...)`, which gets
    no syntax and so no base, and is called at ParamEmit.cpp:30624. It fires in all three.
  * For the import shapes, the import-clone `buildEnumTs(ct2..., eSyn2, nm2)` at ParamEmit.cpp:29407 fires as well.
* **Surelog's side** (third_party/Surelog/src):
  * `CompileHelper::importPackage` (DesignCompile/CompileHelper.cpp, the "Typespecs" loop) calls
    `scope->insertDataType(type.first, type.second)`. It inserts the home package's DataType itself, not a clone.
  * CompileType.cpp's `Enum` case (`result = en->getTypespec()`) returns the home object.
  * Every later copy is `UHDM::clone_tree(…, ElaboratorContext(&s, false, true))`, which deep-copies the base
    typespec reference and keeps `Instance()` and the file. See CompileType.cpp `bindTypespec` and the SimpleType case
    for the pattern.
* **Result: S3 stands on unfenced evidence, with one correction.**
  * The face is the member-enum copy without its base typespec reference and file, with vpiInstance set to the
    importing package instead of the home package.
  * It is not specific to the import clone. The per-use member clone at ParamEmit.cpp:30624 mints it for a
    scoped, non-imported reference too (f04).
  * A fix must cover both sites. Golden's rule is: clone the home enum as clone_tree does (base reference, file,
    home Instance).

## 8. Gates (this pass ships no source change: the gates are run on the base binary and establish the ground)

1. **build:** `/tmp/wt_r11u143` (system deps, `-j 2`) gives `614337e4c8d4b8833fe5c71262db8aae`, the main tree's
   md5. The strict comparator is identical to the main tree's.
2. **`tests/sweep.sh --corpus probe`:** `EQUAL=2272 STRICT_NOTEQUAL=1815 (of 4087)`,
   `regressions=0 conversions=0 changes=0`.
3. **`--corpus "surelog uhdm2rtlil"`:** `regressions=0 conversions=0 changes=0` in both.
   * surelog: `[default] CMP_EQUAL=389 ... STRICT_NOTEQUAL=91`, `[testflags] CMP_EQUAL=383 ... STRICT_NOTEQUAL=91`
     (772 + 182 of 954).
   * uhdm2rtlil: `CMP_EQUAL=692 CMP_NOTEQUAL=1 SLANG_REJECT=67 STRICT_NOTEQUAL=111` in both modes (1384 + 222 of 1606).
4. **`--corpus downstream`:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; 0 of 871 rows off the
   baseline.
5. **uhdm-cmp:** no corpus row or probe case changes status in any of the six configurations. No fresh case changes
   its uhdm-cmp line count across configurations.
6. **byteverify:** §2 (89, 204, 266, and 7 UVM-coin for the inert 141 refinements), predicted by name from the passes'
   own mover lists before this pass measured them: 89 = pass 133's 89; 204 = pass 137's 204; 0 real movers for 141.
7. **canaries** (base csvs):
   * `canaries.sh` vs committed: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0.
   * `EXPECT_UNKNOWN=1 ctcan2.sh` and `EXPECT_UNKNOWN=6 ctcan2.sh`: PASS.
8. **`tests/sweep.sh` exits 1** in every sweep only on `law index STALE`. The cause is this directory's 160 law-named
   cases: with the directory set aside, `law_index.py --check` reads current. The landing regenerates tests/LAWS.md.

## 9. Files

* `cases/<group>/<case>/dut.sv`: each names its law in its first line.
  * `p133_*`, `p141_*`, `p137_*` and `p139_*`: one directory per law (150 cases).
  * `xg_pairs/` (5): the cross-ground pairs.
  * `fence_s3/` (5): the S3 re-derivation.
  * The four `p141_inctabact` cells from the first batch reuse r11u141's two-line `body.svh` helper byte for byte.
    Their `dut.sv` and `defs.svh` are new; no other file repeats any `.sv` / `.svh` under tools/probe or tests/probe.
* `drivers/`:
  * `gen133.py`, `gen137.py`, `gen_more.py`, `gen_adv.py`: the case generators.
  * `case.py`: one case, a golden cached by content, any set of switch configurations, strict records and diffs.
  * `runall.py` and `table.py`: batteries and verdicts.
  * `judge.py`, `judge2.py` and `dd.py`: the field-level and stage-1 judges.
  * `allsw.py` and `allsw_all.sh`: the 26-switch battery.
  * `ds_case.py` and `ds_all.sh`: downstream verdicts.
  * `sweep.sh` and `chain.sh`: the six sweeps.
  * `compose.py`: the composition census.
  * `rowsw.py`, `lawbattery.sh`, `pairjudge.py` and `pairjudge_case.py`: law and pair level on rows and cases.
  * `rowunmask.sh`, `unm.sh`, `unmask.py` and `unmask2.py`: the unmasking proofs.
  * `rowhead.py`: a row's first strict difference with its golden ancestors.
  * `dsbytes.sh`: downstream lane bytes.
  * `lawmap.py`, `lawtable.py` and `lawsummary.py`: reports.
  * `gdb_buildenumts.cmd`: the gdb script used on the fresh fence cases.
  * `env.sh`: the environment.
* `evidence/`: every table above in raw form.
