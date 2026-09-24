# r11u123canon — adversarial verification of typespec identity canonicalisation in uhdm-strictcmp

Base `1fc087af` (branch matrix-1.87). Verification pass: no `src/`, `scripts/`, `results/` or `tests/`
edit. Worktree `/tmp/wt_r11u123`, system-deps config at `-j 2`. Frozen binaries (`chmod 555`, used by
every measurement below and named in every `evidence/*/cmds.txt`):

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `3e6d2800759fb6ea476700223ab73bb0` | the 1fc087af exporter; the worktree build is byte-identical to the main tree's |
| `uhdm-strictcmp` | `6f7814960b1212631fdcb54b10f88369` | 1fc087af + the canonicalisation patch under test (`/tmp/r11u123_canon.patch`, applied with `git apply`, rc 0) |
| `uhdm-strictcmp.fix1` | `10dd00c3a111be97795ae757811ccd9a` | + the one proven fix of this pass (section 5) |

Inputs (read-only): the 1fc087af strict sweeps `/tmp/strict_sweep/{surelog,uhdm2rtlil}/<mode>/<test>-<hash>/`
(2560 judge-equal row-modes; every `cmds.txt` names the main-tree binary and a golden-cache `golden.uhdm`;
`drivers/pairs.py` resolves all 2560, 0 ambiguous, 0 missing) and the master's re-measure
`/tmp/canon_remeasure.csv`. `drivers/run_all.py` reproduces the re-measure exactly: raw verdict = `old`
on 2560/2560, canonical verdict = `new` on 2560/2560 (`evidence/runall_corpus.csv`, which also records
record counts per side and seconds).

## 0. Verdicts

| question | verdict |
|---|---|
| (1) soundness | **SOUND.** Canonical-equal implies every raw difference is identity: checked mechanically on 82/82 corpus row-modes, 143/143 probe arms and 4/4 designed arms (0 failures; 3/3 negative controls caught). 44,080 single-field mutations, every one caught (0 missed) |
| (2) termination and size | **Always terminates** (by the listener's own visited set; the patch's cycle guard never fires). **DEFECT, FIXED:** the unfolding is exponential in typedef nesting, and the 20M-record overflow guard could not fire before memory ran out (bad_alloc, arm t07). Fix: 4M records per side, and no records are kept after the overflow |
| (3) barrier and roots | Keep the root set (every `typespec` subclass plus `enum_const`) and the `class_typespec` barrier. The barrier is sound and changes nothing on the corpus. Adding nets, parameters and constants as roots converts at most 4 of the 66 remaining structural rows and exposes content in most of the rest |
| (4) flip preview | 1579 of 2560 judge-equal row-modes are strict-equal (raw 1497). Sections 4 and 6 give the per-corpus table and the controls |

## 1. The mechanism, decoded

The listener ([VpiListener.cpp:41](../../../third_party/Surelog/third_party/UHDM/templates/VpiListener.cpp#L41)):
`listenAny` calls `enterAny`/`leaveAny` only when the object is NOT in `visited` (line 43-52), and the
per-kind `listenX` pushes the object, inserts it into `visited`, walks the children, and POPS it
([VpiListener.py:92-98](../../../third_party/Surelog/third_party/UHDM/scripts/VpiListener.py#L92)) before
`leaveAny` runs. A revisited object therefore emits NO record at all. Two consequences, both measured:

* **raw ⊆ canonical.** The patch only ever erases objects from `visited` (at their own `leaveAny`), so the
  canonical walk enters everything the raw walk enters, at the same points, and adds whole re-expanded
  subtrees. The raw record list is the canonical list with whole subtrees deleted. So the canonical walk
  cannot hide a record the raw walk has. It can only add records, and each added record is a re-listing
  of an object the walk already listed.
* **The cycle guard is dead code, and termination does not depend on it.** An object leaves `visited` only
  at its own `leaveAny`, which runs after it has been popped. So an object on the path is always in `visited`, and any
  reach of it from below is a revisit (no enter, no leave, no children). Instrumented
  (`drivers/exp/strictcmp_onpath_exp.cpp`): over 2598 stage-2 runs (all 2560 pairs plus the arm self-pairs),
  26,537,361 canonical leaves, the `onPath` branch fired **0** times and `callstack.back()==o` **0** times
  (`evidence/onpath.txt`). The patch comment "The listener leaves this object before popping it" is
  wrong, but the code is harmless. Termination is bounded by the path length, which is at most the number of objects. Size is NOT
  bounded that way: see section 3.
* **Symmetric.** One `Lister` class serves both sides. With the arguments swapped (ours first), 2428 of 2560
  row-modes give the identical verdict string. The other 132 fail at **stage 1** only when swapped:
  `uhdm-cmp ours golden` itself exits 255 on them while `uhdm-cmp golden ours` exits 0. Compare's order
  sensitivity is the library's, not the canonical walk's (`evidence/swapped.txt`; the only equal-row case is
  TypeParameterAsPortTypeWithLogic, both modes). Stage 2 is symmetric on every row both orders reach.

## 2. Question 1 — soundness

**Invariant.** For a pair (golden A, ours B) whose canonical walks are equal (`canA == canB` = C):
`rawA` and `rawB` are each C with whole subtrees deleted, every surviving record identical in all 14 fields
(depth included) and in order, and every deleted subtree is a **re-listing**: its root record (and in fact
its whole relative-depth block) already occurs EARLIER in C. So the two raw walks differ only in which
re-listings each side omits. An object is shared on one side and is an equal-content copy on the other.
That is identity and nothing else.

**Mechanical check** (`drivers/identity_only.py`, greedy embedding plus the earlier-block test):

| population | rows (raw ≠ equal, canon = equal) | OK | FAIL | deleted subtrees golden / ours | re-listing of an identical earlier block |
|---|---|---|---|---|---|
| corpus (the re-measure) | 82 | 82 | 0 | 1513 / 1533 | 3046 / 3046 |
| probe arms (tests/probe, 2833 pairs, `drivers/probe_pairs.py`) | 143 | 143 | 0 | 562 / 537 | 1099 / 1099 |
| designed arms e01–e04 | 4 | 4 | 0 | 19 / 18 | 37 / 37 |
| negative controls (ExplicitPort dumps edited: one endcol in rawB; one record in canB; a FIRST listing deleted from rawB) | 3 | 0 | **3** | — | — |

Output: `evidence/identity_only.txt`, `identity_only_probe.txt`, `identity_only_arms.txt`, `identity_only_negctl.txt`.

**"Raw reads a content difference ⇒ canon NOT_EQUAL."** On the corpus, 0 of 2560 row-modes have a raw first
field in {name … consttype} and a canonical verdict of equal. Every one of the 82 conversions had a raw first field of depth (78),
count (2) or type (2). On the probe arms there are 2 such rows
(`r11u111repro/grid/f5/e18_mod_own_ctl`, `v11u116repro/arms/r3_qual`: raw `name` at #48/#177, enum_const
`B` vs `A`, then `depth` at the next record). Those are **different objects compared by position**: the walk
misaligned on a type-coincident pair. The identity proof passes on both. So the statement holds as the brief
qualifies it, "on the same objects". A raw first field alone is not evidence of content.

**Adversarial mutation** (`drivers/mutate.cpp` changes ONE field of ONE object and re-saves the database;
`drivers/mutation_sweep.py`). On every canon-equal pair, each object the raw walk enters (up to 400 a side: every object inside a canonical subtree first, the rest evenly sampled) is mutated
(`endcol+1`; for expressions inside a typespec or enum_const subtree also `VpiValue`), on the golden side
and on ours. Round-trip controls (the current value written back) must stay equal.

| population | controls equal | endcol in canon subtree | endcol outside | value in canon subtree | caught (rc 2, first field = mutated field) | missed |
|---|---|---|---|---|---|---|
| 82 converted corpus pairs x 2 sides | 164/164 | 17,135 | 19,776 | 5,962 | 42,873/42,873 | **0** |
| arms e01–e04, s01 x 2 sides | 10/10 | 385 | 666 | 156 | 1,207/1,207 | **0** |

Every mutated copy is caught, including a single golden copy whose content differs from its siblings and from our shared object
(`evidence/mutation_summary.txt`).

**Designed arms** (`arms/<name>/dut.sv`; golden = pinned Surelog with check_probe SL_ARGS, built fresh;
ours = the frozen exporter; `evidence/<name>/{cmp,raw,canon,self}.txt`). The content adversary
`arms/<name>/v/dut.sv` is the same file with one judge-blind whitespace edit inside the copied
declaration. Its golden differs from ours in CONTENT on top of the identity difference (`vraw`/`vcanon` =
golden(v) vs ours; `ggraw`/`ggcanon` = golden vs golden(v)).

| arm | shape | raw | canon | content adversary: raw | content adversary: canon |
|---|---|---|---|---|---|
| e01_bits_param_x3 | `$bits(P)` x3, golden copies the int typespec | depth (82/79 records) | **STRICT_EQUAL** 83 | col, walk diverged after 5 objects | **col, 10 objects** |
| e02_explicit_port_x3 | three explicit ports on one net, ours copies | depth (37/39) | **STRICT_EQUAL** 39 | col, 8 | **col, 12** |
| e03_enum_const_x3 | enum const in three port connections | depth (73/75) | **STRICT_EQUAL** 126 | endcol, 4 | **endcol, 16** |
| e04_sysfunc_x3 | `$unsigned(a)` x3 | depth (88/88) | **STRICT_EQUAL** 91 | col, 17 | **col, 46** |
| s01_struct_param_widths | struct typedef with member range `[W-1:0]`, W=2 and W=8 instances (per-instance content) | equal 245 | equal 332 | endcol, 30 | **endcol, 105** |
| s02_typedef_casts | typedef used by three casts | fullname (193/181) | **fullname** (3 ref_typespec: golden `work@top.byte_t`, ours `byte_t`) | endcol, 47 | **endcol, 119** |
| s03_enum_two_pkgs | same-named enum typedef in two packages, used in two modules | fullname | **fullname** (golden `pa::st_t`, ours `pa::pa::st_t`) | endcol, 22 | **endcol, 82** |

The canonical walk turns every pure-identity arm to equal and keeps every content difference, at every
copy: the canonical count of differing objects is 2x to 4x the raw one, because the raw walk stops at the
first identity divergence. `ggraw`/`ggcanon` (golden vs golden(v): identical identity structure, content
only) read the same content field in both modes. Seven earlier drafts of these arms hit exporter
residues at stage 1 (`NOT_EQUAL stage1`) and were replaced by shapes stage 1 accepts. The trial driver is
`drivers/try.sh`.

## 3. Question 2 — termination and size

**Cycle arms.** Self pairs (golden vs golden, ours vs ours) always reach stage 2, so each producer's walk is
measured even when the golden/ours pair stops at stage 1:

| arm | golden/ours stage 1 | raw records (golden/ours) | canon records (golden/ours) | terminates |
|---|---|---|---|---|
| t01_class_self_member (`node next, prev` of its own class) | STRICT_NOTEQUAL endcol | 77/77 | 77/77 | yes, 0.02 s |
| t02_classes_mutual (`typedef class`; A has B, B has A) | STRICT_EQUAL | 67/67 | 67/67 | yes |
| t03_struct_enum_param_cycle (struct of enum members, range from a param folded from an enum const) | NOT_EQUAL stage 1 | 182/182 | 555/555 | yes |
| t04_virtual_interface (two `virtual bus_if` members) | NOT_EQUAL stage 1 | 120/118 | 120/118 | yes |
| t05_param_class_many_refs (`box#(16)` x30, `box#(8)` x10) | NOT_EQUAL stage 1 | 451/451 | 452/452 | yes |
| t08_class_spec_typedef (`typedef box#(16) box16_t` x20, self-typed member) | NOT_EQUAL stage 1 | 236/236 | 276/276 | yes |
| **t06_nested_struct_dag** (12 levels, `t_i = struct packed {t_{i-1} x, y}`) | STRICT_NOTEQUAL fullname | 323/323 | **786,273/786,273** | yes, 2.3–4.6 s, 790 MB |
| **t07_nested_struct_dag16** (16 levels, 12.8 KB database) | STRICT_NOTEQUAL fullname | 391/391 | **exit 3 (overflow)** with the fix; **bad_alloc (rc 134)** under an 8 GB cap before it | see section 5 |

The canonical walk is the tree unfolding of the typespec DAG, so it grows as the product of the member
multiplicities along a typedef chain: 2^depth here. t06 multiplies the record count by 2434x. The corpus
never gets close (the largest ratio is 5.4x, FuncStructVal/testflags, 45k records).

**Largest corpus rows** (`drivers/timesize.py`, one process at a time, `--max 0`, no dumps; records from
`evidence/runall_corpus.csv`; full table in `evidence/size_table.md`):

| row | mode | raw records golden/ours | canon records | raw s | canon s | canon peak RSS | flag |
|---|---|---|---|---|---|---|---|
| surelog/Earlgrey_0_1 | default | 877,176/866,470 | 2,173,209/2,170,358 (2.48x) | 6.19 | **14.48** | **3214 MB** (raw 1240) | **> 5 s, > 2M records** |
| surelog/Earlgrey_0_1 | testflags | 918,396/906,862 | 1,342,584/1,339,014 | 9.64 | **11.20** | 2057 MB | > 5 s (raw already 9.6 s) |
| surelog/YosysBigSimEllip | default | 627,084/643,212 | 681,189/681,181 | 5.25 | **5.36** | 1074 MB | > 5 s (raw already) |
| surelog/SeqDriver | both | 439k/416k | 476k/462k | 3.4 | 3.8 | 622 MB | |
| surelog/MiniAmiq | both | 407k/374k | 436k/414k | 3.5 | 3.5 | 610 MB | |
| surelog/SimpleUVM | both | 303k/299k | 334k/334k | 2.6 | 2.7 | 515 MB | |
| surelog/Scoreboard | default | 246k/242k | 270k/269k | 1.9 | 2.2 | 484 MB | |
| surelog/BuildUVMPkg | both | 183k/181k | 202k/202k | 1.4 | 1.4 | 283 MB | |
| uhdm2rtlil/func_upto | both | 227k/227k | 295k/295k | 1.8 | 2.2 | 520 MB | |
| uhdm2rtlil/ibex_* (17 tests, both modes) | | ≤ 34k | ≤ 36k (≤ 1.20x) | ≤ 0.19 | ≤ 0.22 | ≤ 75 MB | |

Whole corpus: 140 s canonical vs 131 s raw summed over 2560 row-modes at 3 jobs (`evidence/runall_corpus.csv`).
Only Earlgrey_0_1/default crosses 2M records. Canonicalisation adds about 8 s and 2 GB there.

## 4. Question 3 — the barrier and the roots

**The 66 row-modes still structural after canonicalisation** (37 depth, 9 count, 20 type; `drivers/residue_kinds.py`,
`evidence/residue_kinds.tsv`). Every hunk of `diff canA canB` is classified. A hunk is IDENTITY when it is a pure
insertion of whole subtrees, each re-listing an identical earlier block, and the inserted root is NOT inside
a canonical context. Inside a canonical context the other side would have re-listed the object too, so an
omission there means the relation is ABSENT: that is CONTENT.

| kind (root < container, side with extra records) | rows | what it is | content? |
|---|---|---|---|
| `logic_net < ref_obj` (A 39 hunks, B 19) | 28 row-modes, 15 tests | golden's ref_obj.Actual is a second net object where ours points at the module's net (C0024/F13/F21), or the reverse | mostly YES once aligned: with nets as roots, sva_range's golden net copy has no typespec while ours has `ref_typespec > logic_typespec` (content), param_type_logic_width moves to fullname. Only Moves/default and vector_index (both modes) are pure identity |
| `ref_typespec < logic_typespec` (ours) | WireType, LogicTypedef, net_types (both modes) | ours' net typespec carries a Typedef_alias (`ref_typespec > logic_typespec typename`) that golden's copy lacks | **YES**, relation absent. The raw `depth` became canonical `type`: the canonical walk exposes it |
| `constant < typespec_member` (golden) | StructParamFuncBodyFieldCompare, def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot | a member default constant ours shares with a constant FIRST visited outside any typespec (never erased, so collapsed inside the typespec) | a completeness gap of the walk, not a soundness hole. Every one of these rows also has content hunks |
| `constant < array_expr` (ours), `parameter < param_assign` (golden) | DefaultPattern*, ParamArrayUnsizedPattern, ParamFromPackage, ParameterFromPkgOnParameterPortList | constant/parameter identity (C0012 imported-param Lhs clone) | identity, outside typespecs; mixed with content in 6 of 9 rows |
| content-only (`func_call`↔`constant`, `logic_typespec`↔`int_typespec`, new constant under param_assign) | FunctionParam, func_local_array, SelectGivenBySelectOnParameterInFunction, TypeParam, BlackParrotComplex | real structure differences | YES |

All 15 u2r tests of the `logic_net < ref_obj` class are downstream IDENTICAL (results/downstream_uhdm2rtlil.csv).

**Root-set experiments** (`drivers/exp/strictcmp_rootset_exp.cpp`: the fixed comparator plus env switches; the
default build reproduces the patch's 2560 verdicts exactly; `drivers/variant_sweep.py`, `drivers/variant_diff.py`,
`evidence/variants.txt`):

| root set | equal row-modes | conversions | regressions | first-field moves on still-NE rows |
|---|---|---|---|---|
| patch (typespec subclasses + enum_const) | 1579 | — | — | — |
| + nets (`UHDM::nets` subclasses) | 1582 | 3 (Moves/default, vector_index x2) | 0 | count→depth 2, depth→fullname 2 |
| + parameter/type_parameter | 1579 | 0 | 0 | depth→fullname 4, depth→type 2 |
| + constant | 1580 | 1 (DefaultPatternModule/default) | 0 | depth→file 4, →endcol 2, →fullname 1 |
| + all three | 1583 | 4 | 0 | 7 to fullname, 4 file, 2 type, 2 endcol, 2 count→depth |
| patch without the class_typespec barrier | 1579 | 0 | 0 | none. UVM rows +0.2–0.9 % records (`evidence/nobarrier_sizes.txt`); t01/t02/t04/t05/t08 identical |

**Recommended root set: keep it exactly as patched.** Roots stay every `UHDM::typespec` subclass plus `enum_const`, with the
`class_typespec` barrier. This covers ranges, `typespec_member`s, packed/unpacked `array_typespec`s and io_decl
typespecs, because they sit under a typespec root. Evidence:
* No extension is sound-but-worth-it. Nets, parameters and constants together buy 4 of the 66 row-modes. On
  the others they remove an identity mask and expose content (fullname, file, spans, a missing net typespec), which
  is correct but is no longer identity. They also widen canonicalisation beyond the decided scope (typespec
  identity) into net/parameter binding identity. Net objects are what the plugin keys its maps on, so that
  identity stays a residue.
* The barrier is correct and inert. It never hides anything: it only withholds erasure. It changes no verdict and no
  first field on 2560 row-modes, and saves under 1 % of records on the UVM rows. Keep it as the bound on
  class-body re-listing.
* A narrower set would reopen identity. The 82 conversions come from typespec kinds and enum_const (C0002/4/5/6/8/11:
  of the 49 row-modes whose ground-map clusters are all in the brief's identity list, 43 convert; the other 6 are
  WireType/LogicTypedef testflags, which are content, and ConstantBits/PackFunc, which are C0010 fullname content).

## 5. The fix (the only source change beyond the patch under test)

Defect, proven by `arms/t07_nested_struct_dag16`: the overflow guard is 20M records **per side**, and both
sides' records are kept. A record costs 0.5–0.8 KB (t06: 790 MB for 1.57M records; Earlgrey: +1974 MB for
2.6M extra). So the guard fires only after 10–30 GB on this 15 GB machine. Under `ulimit -v 8000000` the patched
comparator dies with `std::bad_alloc` (rc 134) after 13 s on a 12.8 KB database. The sweep would read that as
`differ:?`, and without the cap it would drive the VM out of memory. Fixed ([uhdm-strictcmp.cpp:72](../../uhdm-strictcmp/uhdm-strictcmp.cpp#L72),
[:96](../../uhdm-strictcmp/uhdm-strictcmp.cpp#L96), [:204](../../uhdm-strictcmp/uhdm-strictcmp.cpp#L204)):

    size_t cap = 4000000;                                    // was 20000000; 1.8x Earlgrey_0_1 default (2.17M)
    if (overflow) return;  // the verdict is exit 3: keep no more records
    if (!lA.overflow) lB.listenDesigns(hB);

After the fix: rc 3 `canon overflow` in 6.7 s, 1798 MB peak (`evidence/overflow_t07.txt`). The fix changes no
verdict and no record count on any row: all 2560 corpus row-modes are identical to the patch's (verdict, both
raw and canon record counts), and so are all arms except t07. Everything above was re-run with the fixed
binary: run_all, identity check, mutation sweep, arms.

## 6. Question 4 — flip preview (canonical verdicts, `drivers/flip_preview.py`, `evidence/flip_preview.txt`)

| corpus | mode | judge-equal | raw strict-equal | canon strict-equal | canon differ by first field |
|---|---|---|---|---|---|
| surelog | default | 480 | 240 | **265** | file 71, fullname 55, endcol 22, line 21, value 16, col 8, endline 8, depth 7, type 3, decompile 2, name 1, count 1 |
| surelog | testflags | 474 | 231 | **252** | fullname 76, file 64, endcol 21, line 17, value 16, col 9, endline 7, depth 6, type 3, decompile 2, name 1 |
| uhdm2rtlil | default | 803 | 513 | **531** | file 108, fullname 89, endcol 13, depth 12, col 10, endline 8, line 8, value 7, type 7, count 4, name 3, decompile 3 |
| uhdm2rtlil | testflags | 803 | 513 | **531** | same as default |

Tests: surelog 242 strict-equal in both modes, 30 in one mode only, 6 judged in one mode only. uhdm2rtlil 531 in both, 0 in one only.
Equal in default only: AllPackageSignal, ArrayExprFuncArg, ArrayVarName, ClogParam, DollarBits, EmptyAssign,
FileList, ForeachFunction, FuncParam, FuncRetArray, FuncStruct, ImplicitPackedStructNet, InterfInst,
InterfaceUnpackedStructArrayDim, JKFlipflop, NoParamSubs, OneNetInterf, PortByName, TypespecExpr, UnsizedFunc.
Equal in testflags only: BiasValue, BlackBoxInst, BlackBoxInstTop, BlackBoxMod, BlackBoxSubMod, DecValue, Moves,
PackFunc, PackageParamConst, PortInitVal.

Controls (fixed binary): 1364_2005/default raw 146 → canon **STRICT_EQUAL** 159; HierPathInterfBlock/default
220 → **STRICT_EQUAL** 226; 1DUnpackedArray/default 182 → **STRICT_EQUAL** 194. stamped_gen_param stays
`NOT_EQUAL stage1` in both modes with `lhsPath: design(work@stamped_gen_param) > module_inst(work@stamped_gen_param)
> gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`. No raw-equal row becomes canon-NE
(0 of 1497 in the corpus, 0 of 1117 probe arms).

## 7. Observations outside the patch under test

* The main tree's working copy of `tools/uhdm-strictcmp/uhdm-strictcmp.cpp` (uncommitted, not built into
  `build/uhdm-strictcmp`) leaves `fullname` out of every record inside a canonical subtree. Built separately
  (`/tmp/r11u123_bin/strictcmp_mainwip`), it turns arms s02 and s03 to STRICT_EQUAL. That hides golden
  `work@top.byte_t` vs ours `byte_t`, and golden `pa::st_t` vs ours `pa::pa::st_t`, which are parent-chain and naming CONTENT. It also
  adds 67 row-modes to equal (all from `fullname`), with 0 regressions (`evidence/variants.txt`). That is a
  separate policy (content, not identity) and should be gated as one. The plugin reads the stored `VpiFullName()`
  (13 sites, module.cpp/interface.cpp/expression.cpp, including ref_obj at expression.cpp:10256-10306), while
  the record reads the synthesised `vpi_get_str(vpiFullName)`.
* The patch's "cycle guard" and its comment (section 1) can be deleted or reworded. Behaviour does not depend on them.

## 8. Gates (pristine exporter, fixed comparator in the strict column)

`tests/sweep.sh --jobs 3 --workdir /tmp/r11u123_sweep --corpus "probe surelog uhdm2rtlil downstream"` with
`SLANG_UHDM=/tmp/r11u123_bin/slang-uhdm STRICT_CMP=/tmp/r11u123_bin/uhdm-strictcmp.fix1`, exit 0
(`evidence/sweep_gates.txt`; every cmds.txt, 3273/3273, names the frozen binary):

| gate | result |
|---|---|
| build | slang-uhdm `3e6d2800759f` (byte-identical to the main tree), uhdm-strictcmp `6f7814960b12` (patch), `10dd00c3a111` (fixed) |
| probe | EQUAL=2833 of 2833 (strict, measurement: equal=1260; raw would read 1117) |
| surelog, both modes | 480/3 + 474/3; regressions=0 conversions=0 changes=0 |
| uhdm2rtlil, both modes | 803/1/67 both modes; regressions=0 conversions=0 changes=0 |
| downstream | IDENTICAL 794 / SLANG_REJECT 66 / EQUIVALENT 7 / DIVERGENT 4 of 871; not identical and not excused 0 (the baseline) |
| uhdm-cmp on touched rows | no exporter change; no row touched |
| byte movers | no law binary in this pass. Databases vs the same-binary 1fc087af sweep: 2565/2568 byte-identical; movers MiniAmiq (both modes) and SeqDriver/default are the UVM order coin |
| strict column | status changes 0; strict-cell movers 254 (surelog) + 330 (u2r) = exactly the rows whose raw and canonical verdicts differ in the re-measure, each predicted by name (committed cell = raw verdict, fresh cell = canonical verdict), 0 unpredicted |
| canaries | the fresh csv is LF and results/*.csv are CRLF. Both scripts compare `$NF`, which is now the strict column, so on raw files every row reads CHANGED, and the 1fc087af baseline sweep reads the same. After CR normalisation: ctcan2 u2r PASS (ok=2). canaries.sh (22+8 ok) and ctcan2 surelog (55 ok) list only strict-cell changes, all in the predicted set above. No status or detail cell moved |

## Files

* `arms/<name>/dut.sv` (+ `v/dut.sv` content adversaries); `evidence/<name>/` per arm.
* `drivers/`: `arm.sh` (one arm: goldens, ours, uhdm-cmp, raw/canon/variant/self runs), `pairs.py`, `run_all.py`,
  `identity_only.py`, `mutate.cpp` + `mutation_sweep.py`, `residue_kinds.py`, `variant_sweep.py`, `variant_diff.py`,
  `timesize.py`, `flip_preview.py`, `probe_pairs.py`, `try.sh`, `exp/` (experiment-only comparator builds).
  Build the mutator with `c++ -std=c++20 -O2 -I$HOME/.local/include drivers/mutate.cpp -o mutate
  $HOME/.local/lib64/{libuhdm,libcapnp,libkj}.a -ldl -lutil -lm -lrt -lpthread`.
* `evidence/`: `runall_corpus.csv`, `runall_probe.csv`, `identity_only*.txt`, `mutation_summary.txt`,
  `residue_kinds.tsv`, `variants.txt`, `size_table.md`, `timesize.tsv`, `nobarrier_sizes.txt`, `overflow_t07.txt`,
  `onpath.txt`, `swapped.txt`, `flip_preview.txt`, `sweep_gates.txt`.
