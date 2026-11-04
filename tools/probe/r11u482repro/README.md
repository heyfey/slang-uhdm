# r11u482 — module/type ground, pass 482 (sv-tests campaign, forty-first pass on this ground)

Base 6344380c (pass 480). Files touched: src/UhdmExporter.cpp, src/TaskFuncEmit.cpp (and the
regenerated tests/LAWS.md). No src/R*.h, no getenv, no header change; every law reads its switch
through src/LawSwitch.h (`lawOn(482, "R11U482_<LAW>_OFF")`), `R11U482_OFF` drops the whole pass,
`R11U482_TRACE=<dir>` logs each firing through `lawTrace(482, ...)`.

No sv-tests row is open on this ground (EQUAL 1937 at the base; the three DIFFERENT rows are the
known exceptions p733, p737 and tnoc). This pass works the first backlog item: the import-clone
half of pass 480's fixed-size array element, and the clone faces behind it.

## Binaries

| tag | md5 | what |
|---|---|---|
| pristine | ca935476c93bd4580c8beef2e2385789 | the main tree's build/slang-uhdm (copied, frozen); the worktree's first build at 6344380c reproduced it bit for bit |
| law1 | d15087e7bd3397a3587bfafd12303bae | the six laws; the array-element copy taken for every member kind (away census only) |
| law2 | 4c9283cceefb17c5126a5a0f0737aeff | the array-element copy narrowed (named member types only for the fixed arrays of the first law); the full five-stage sweep |
| law3 | 9b2ac7c75b8d9e830b60ed561c389994 | FINAL: § cloneHierIdxChainActual482 narrowed to an unresolved bit_select (v11u224 LX/lb02); links slang 12.0.0+545f88b2e |

law3 differs from law2 only in that narrowing, which fired in no sweep process (the sweep's trace
holds no cloneHierIdxChainActual482 line). law3's probe stage was rerun alone (0/0/0, all 4087
databases byte-identical to law2's sweep), and law3 gives law2's MiniAmiq default bytes. Over the
3346-dir away census law3 differs from law2 only on LX/lb02, which goes back to pristine's bytes.

## The face, decoded

Golden's import clone is UHDM's DeepClone of the home subroutine (`clone_tree`, uniquified
typespecs): `ref_typespec::DeepCopy` deep-clones its actual, and `*clone = *this` keeps the
source's fields, vpiInstance included. Every struct, union or enum the clone holds is a private copy
under the reference that binds it. The copy's vpiInstance is the instance the typedef had when the
importer was elaborated: the top view of the typedef's package. Surelog's last writer rewrites the
SHARED object's instance (and parent) later, to the last importer that lists it (package t,
parented by module_inst top, on v11u478 VM/vm03). Read with evidence/tools/tsinfo.cpp, pkgs.cpp
and tsinst.cpp on fa16 and vm03.

Pass 480's law2 note ("taking the shared object re-homed the home typedef") was a misreading.
The 924-line head that law2 reached on VM/vm04 is golden's own last-writer typedef, package u's
op_t with instance t and parent module_inst top. It was compared against ours because the walk
reached it through the copies' instance: golden's copies hold package u (top), ours held the
shared object's later instance. The queue twin VM/vm03 reads the same 924 lines on pristine.

## Laws

1. **§ cloneFixArrAggElemShared482** (TaskFuncEmit, in § fixArrLocalNamedAggElemTs480's helper;
   switch `R11U482_CLONEFIXAGG_OFF`). This is the import-clone half. In an importer's copy the
   fixed-size array local's element also takes the shared typedef object, and the design-final
   drains below give the copy its private object. The array_typespec is recorded in a
   membership-only set (`g_cloneFixArr482`, never iterated) for law 2. The law abstains in three
   cases:
   * an enum: the drains do not model its copy's base and constants (CI/ci03);
   * a typedef of a package other than the subroutine's: § 241's drain does not copy those
     (CI/ci16, v11u478 VM/vm12);
   * a struct declared in a class: golden binds differently there (v11u478 VM/vm14, which grew
     483 -> 1337 dump lines until this abstention).
2. **§ cloneArrElemAggOwnCopy482** (UhdmExporter, the array leg of § cloneSharedAggOwnCopy265 in
   finish241; `R11U482_ARRELEMCOPY_OFF`). A clone local's array_typespec element reference holds,
   in golden, the deep clone's own struct or union. § 265 takes that copy only when a member is
   typed by a home enum, and § 450 only when the spans differ. This law makes the copy (through
   ownCopy265) in two cases:
   * every member is typed by an unnamed keyword type;
   * the array is one of law 1's fixed arrays, whatever the member types (CI/ci15, ci19).

   It abstains for a queue or dynamic array whose members have named types. Golden copies those
   member types too, and the member copies made here share them, which reads further from golden
   (r11u458 MB/mb01: object-census distance 52 without the copy, 68 with it).
3. **§ cloneOwnCopyInstHomeTop482** (UhdmExporter, start of final287; `R11U482_COPYINST_OFF`).
   Design-final, in each import clone: a struct, union or enum typespec parented at a
   ref_typespec inside the clone whose name is a package typedef `P::x` takes the top view of P
   as its vpiInstance. So does every instance-carrying, non-array member type of such a copy (the
   `_member` trace line). The copies covered are § importCloneBodyLocalCopies175's begin copies
   (StmtEmit's clone_tree, made after the shared instance was rewritten),
   § cloneAggLocalOwnCopy241's and § cloneSharedAggOwnCopy265's, and law 2's. An array member
   type is left alone: golden writes no instance on it (VM/vm08, an older face). An ambiguous
   name abstains.
4. **§ cloneTfVarParentAtTf482** (UhdmExporter, start of final287; `R11U482_TFVARPARENT_OFF`). In
   an import clone the subroutine's own Variables list is a DeepClone list of its own, parented
   at the subroutine (golden `array_var (a::f::acc)` under `function (a::f)`). Ours kept the home
   emission's parent, the body begin, after § 175 gave the begin its own copies. A clone Variables
   entry parented at a begin of the clone that no longer lists it is re-parented at the
   subroutine. This is residue 2 of pass 480. The strict comparator reads depth by walk, not by
   parent, so this law is judged by the dump and the object census.
5. **§ cloneHierIdxChainActual482** (UhdmExporter, in § cloneHierArrElemMember478's walk;
   `R11U482_IDXCHAIN_OFF`). DeepClone's `a[i][j]` branch: an element with no name (or a name
   starting with `[`) after a bit_select takes that bit_select's actual (golden binds the clone's
   `acc[0][1]` to the array `acc[0]` binds; the home body's stays unbound). The member after it
   then binds through § 478. This is pass 478's two-dimension residue, v11u478 VM/vm01. The
   verifier-style narrowing in law3: DeepClone's `previous` is still that bit_select only when the
   walk did not resolve it. So the branch applies after the first element, or after an element
   bound by this branch, and never after a bit_select bound to a member (v11u224 LX/lb02
   `s.arr[i][1:0]`, where golden's part_select stays unbound; law2 bound it, a dump-only move,
   restored in law3).
6. **§ cloneHierMemberChain482** (UhdmExporter, the same walk; `R11U482_MEMBCHAIN_OFF`).
   DeepClone's typespec_member branch: after an element bound to a struct or union member, the next
   name binds the member of that member's type, with one array or packed-array level unwrapped
   (golden `acc[1].i.data` binds `data` to the in_t member; CI/ci19). This is pass 478's nested
   member-path residue. VM/vm08 and vm18 still stop at an older head (below).

Interactions:
* Laws 5 and 6 extend § cloneHierArrElemMember478's walk, so `R11U478_ARRMEMBER_OFF` turns them
  off too.
* Law 2 runs inside § cloneSharedAggOwnCopy265's array leg and needs `R11U265_SHAREDAGGCOPY_OFF`
  unset (that leg's own gate).
* Law 1 is read inside § fixArrLocalNamedAggElemTs480, so `R11U480_FIXARRAGG_OFF` turns it off
  too.
* Law 3 also changes the instance of every earlier clone copy (§ 175, § 241, § 265). That is
  where all of its MiniAmiq/SeqDriver firings come from.

## Grid (cases/CI, 25 dirs; every case accepted by upstream slang, Surelog exit 0, ours exit 0 on every binary)

`drivers/grid.sh <bin> <tag> [VAR=val...]`; evidence/grid_pristine.txt, grid_law3.txt,
grid_law3_off.txt (`R11U482_OFF`: pristine's bytes and exit code on 25 of 25), and
grid_law3_<law>_off.txt for each switch alone. Tally:
* pristine: STRICT_EQUAL 1, NOT_EQUAL 24;
* law3: STRICT_EQUAL 19, NOT_EQUAL 6.

No uhdm-cmp count grows, and every dump distance (dd) and object-census distance (oc) shrinks.
(dd: path-normalised uhdm-dump lines differing from golden. oc: the multiset distance of
evidence/tools/objcensus.cpp, one record per object holding kind, name, span and three parent
kinds, blind to dump order and identity.)

| case | law named in its first line | shape (all in an import clone) | pristine | law3 |
|---|---|---|---|---|
| ci01 | § cloneFixArrAggElemShared482 | fixed struct array, free function cloned into a | NE 94, dd 586 | STRICT_EQUAL 604 |
| ci02 | § cloneFixArrAggElemShared482 | fixed union array | NE 94 | STRICT_EQUAL 604 |
| ci03 | § cloneFixArrAggElemShared482 | fixed enum array (abstains) | NE 88, dd 718 | NE 88, dd 714 (§ 482 instance/parent laws only) |
| ci04 | § cloneFixArrAggElemShared482 | packed struct | NE 96 | STRICT_EQUAL 844 |
| ci05 | § cloneFixArrAggElemShared482 | task local | NE 94 | STRICT_EQUAL 605 |
| ci06 | § cloneFixArrAggElemShared482 | out-of-body class method | NE 94 | STRICT_EQUAL 578 |
| ci07 | § cloneFixArrAggElemShared482 | two importing packages | NE 94 | STRICT_EQUAL 804 |
| ci08 | § cloneOwnCopyInstHomeTop482 | queue of a struct | NE 798 | STRICT_EQUAL 596 |
| ci09 | § cloneOwnCopyInstHomeTop482 | dynamic array of a struct | NE 738 | STRICT_EQUAL 566 |
| ci10 | § cloneOwnCopyInstHomeTop482 | associative array of a struct | NE 742, dd 346 | NE 742, dd 336 (residue) |
| ci11 | § cloneOwnCopyInstHomeTop482 | scalar struct local | NE 33, dd 110 | NE 33, dd 102 (sister face) |
| ci12 | § cloneHierIdxChainActual482 | `acc[2][3]`, `acc[0][1].k` | NE 94 | STRICT_EQUAL 693 |
| ci13 | § cloneHierIdxChainActual482 | three dimensions | NE 94 | STRICT_EQUAL 782 |
| ci14 | § cloneHierIdxChainActual482 | variable indexes | NE 94 | STRICT_EQUAL 750 |
| ci15 | § cloneArrElemAggOwnCopy482 | struct with an enum member | NE 94 | STRICT_EQUAL 716 |
| ci16 | § cloneTfVarParentAtTf482 | typedef of a third package s (law 1 abstains; only the parent law moves it) | NE 94, dd 600 | NE 94, dd 596 (residue) |
| ci17 | § cloneFixArrAggElemShared482 | foreach over the array | NE 94 | STRICT_EQUAL 775 |
| ci18 | § cloneFixArrAggElemShared482 | module importing the function directly (no clone) | STRICT_EQUAL 232 | same bytes |
| ci19 | § cloneHierMemberChain482 | nested struct member `acc[1].i.data` | NE 94 | STRICT_EQUAL 904 |
| ci20 | § cloneFixArrAggElemShared482 | two functions sharing the struct | NE 94 | STRICT_EQUAL 1068 |
| ci21 | § cloneFixArrAggElemShared482 | vector members | NE 94 | STRICT_EQUAL 844 |
| ci22 | § cloneOwnCopyInstHomeTop482 | scalar enum local | NE 60, dd 124 | NE 60, dd 118 (sister face) |
| ci23 | § cloneFixArrAggElemShared482 | array plus a scalar of the struct | NE 94, dd 674 | NE 33, dd 398 (sister face) |
| ci24 | § cloneFixArrAggElemShared482 | union, out-of-body method, chain a then t | NE 94 | STRICT_EQUAL 788 |
| ci25 | § cloneFixArrAggElemShared482 | ranged `[0:1]` | NE 94 | STRICT_EQUAL 578 |

Switch table on the grid: each switch alone moves exactly these dirs.
* CLONEFIXAGG: ci01, 02, 04 to 07, 12 to 15, 17, 19 to 21, 23 to 25.
* ARRELEMCOPY: the same, plus ci08 to ci10.
* COPYINST: all of those, plus ci11 and ci22.
* TFVARPARENT: every clone dir except ci18.
* IDXCHAIN: ci12 to ci14.
* MEMBCHAIN: ci19.

Downstream (`ds.one`, both lanes) on ci01, ci04, ci07, ci12, ci18, ci19, ci21 and ci25 reads
IDENTICAL on pristine and law3. These designs have no gates (NO_GATES on both lanes), so this
confirms no downstream change and nothing more.

### Target residues of passes 480 and 478 (the brief's item (a)), law3 against pristine

| case | pristine | law3 |
|---|---|---|
| r11u480 FA/fa16 | NE 94 | STRICT_EQUAL |
| v11u480 VA/va21 | NE 94 | STRICT_EQUAL |
| r11u478 AM/am08 | NE 96 | STRICT_EQUAL |
| v11u478 VM/vm01 (two dimensions) | NE 94 | STRICT_EQUAL |
| VM/vm03 (queue) | NE 924 | STRICT_EQUAL |
| VM/vm04 | NE 94 | STRICT_EQUAL |
| VM/vm09 | NE 1028 | STRICT_EQUAL |
| VM/vm13 | NE 94 | STRICT_EQUAL |
| VM/vm15 | NE 854 | STRICT_EQUAL |
| VM/vm16 | NE 94 | STRICT_EQUAL |
| VM/vm17 | NE 94 | STRICT_EQUAL |
| VM/vm20 | NE 890 | STRICT_EQUAL |
| VM/vm08, vm18 (nested member paths) | NE 475, NE 431 | unchanged (older head, residue 3) |
| VM/vm11 (alias of the struct) | NE 17 | unchanged (older alias face) |
| VM/vm12 (third package) | NE 94 | unchanged (residue 2) |
| VM/vm14 (class-scoped struct) | NE 369 | unchanged (abstains) |

## Prediction, away census, movers

* **Prediction**, written before the sweep. evidence/tools/clonescan.cpp counts each law's shape
  on PRISTINE databases. A clone is recognised as a task or function whose span lies outside its
  package's span. It was validated on the away census: of 3346 dirs, the pristine databases
  predicted 673 movers and the byte census found exactly those 673 (no miss, no extra). Run over
  the master's 7529 fence-filtered control databases (/tmp/intr11u480), it predicts:
  * probe: 43 cases, by name;
  * surelog: MiniAmiq d/t and SeqDriver d/t (COPYINST 218, COPYINST_member 174, TFVARPARENT 1040
    each);
  * uhdm2rtlil and downstream: none;
  * the kept sv-tests databases: uvm_overriding, uvm_wait_for_signal, uvm_slave_agent,
    uvm_slave_agent_multi_seq_item and rsd.

  See evidence/prediction_scan_control.txt.
* **Away census** (evidence/away_*.txt): 3346 fence-filtered case dirs under tools/probe/*/cases
  whose source holds an import and a function or task, run on pristine and law3. No exit code
  moves; 672 dirs move bytes. Judged against fresh Surelog goldens:
  * 68 UP: 61 NOT_EQUAL -> STRICT_EQUAL, 6 NOT_EQUAL -> STRICT_NOTEQUAL and 1 STRICT_NOTEQUAL
    -> STRICT_EQUAL (r11u265 B/b08, type). Among them are the r11u231 AL family, v11u241 AG and
    AR, v11u265 VB and VE, r11u458 LT and MB, r11u461 UN, r11u478 AF and AM, and the v11u478 VM
    list above.
  * 4 with a smaller uhdm-cmp count.
  * 582 with a smaller dump distance.
  * 13 unchanged in verdict, count and distance (the r11u478 AF and v11u478 VF alias-copy dirs and
    two others, instance-only moves).
  * 5 at the same verdict with a dump distance a few lines larger: r11u244 N/n05 298 -> 304,
    v11u244 E/e10 644 -> 696, v11u248 B/b06 834 -> 844, v11u446 VQ/vq06 333 -> 343 and v11u478
    VM/vm10 972 -> 974. Each has a smaller object-census distance (56 -> 46, 88 -> 74,
    144 -> 114, 65 -> 19, 156 -> 88). The added objects are golden's per-reference copies, and
    the dump's first-visit expansion places them differently.
  * None goes DOWN, none grows its uhdm-cmp count, and no object-census distance grows (0 of 672;
    92 the same, 580 smaller).

  `R11U482_OFF` gives pristine's bytes on 672 of 672. Per switch, these dirs move when the
  switch alone is set: CLONEFIXAGG 20, ARRELEMCOPY 34, COPYINST 251, TFVARPARENT 580, IDXCHAIN 2,
  MEMBCHAIN 4 (evidence/away_switch_table.txt).
* **The 43 probe movers** (evidence/probe_movers.txt): each keeps its verdict with a smaller dump
  distance; the probe csv is unchanged.
* **The four corpus movers** (evidence/corpus_movers.txt): MiniAmiq d/t and SeqDriver d/t, each
  CMP_EQUAL, strict equal at 435559, 435559, 475526 and 475538 objects. Both laws are needed to
  restore control: on MiniAmiq default, `R11U482_TFVARPARENT_OFF` plus `R11U482_COPYINST_OFF`
  gives the control's bytes, and either one alone does not. Both moves go toward golden:
  * the instance census distance to golden drops from 9777 to 9139;
  * the uhdm-dump distance drops from 321278 to 316434.

  The four DETERMINISM HASHES MOVE and must be re-recorded at landing: MiniAmiq default and
  testflags 15a2c8dae023174eba8e9f8c92f3ff1a, SeqDriver default 4aaaa70aadb8ae37c6a3504639e21686,
  SeqDriver testflags d9a59668e594cd070a3fa33fb31aa1d0. Three concurrent draws each of MiniAmiq
  default and SeqDriver testflags read one hash, 3 of 3.

## The sweep (one, on law2; tests/sweep.sh --jobs 3, workdir /tmp/r11u482swp, same length as the control)

The first four stages ran from the worktree. The sv-tests stage ran through the main tree's
tests/sweep.sh, because the worktree's UVM folder is empty. SLANG_UHDM was the frozen law2 and
R11U482_TRACE was on. See evidence/sweep_summary.txt and sweep_trace.txt.

* probe: EQUAL 4026, STRICT_NOTEQUAL 61 of 4087; regressions=0 conversions=0 changes=0.
* surelog: default CMP_EQUAL 480, testflags 474, STRICT_NOTEQUAL 0; 0/0/0.
* uhdm2rtlil: 803/1/67 in both modes; 0/0/0.
* downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871; not identical and
  not excused 0.
* sv-tests: EQUAL 1937, DIFFERENT 3, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=0 changes=0. No sv-tests row
  moves.
* Every csv equals the control's row for row after workdir normalisation (0 differing lines in
  all five).
* byteverify (SELFCHECK=1) law2 against the control: surelog 4 of 962 (exactly the predicted
  MiniAmiq d/t and SeqDriver d/t), uhdm2rtlil 0 of 1608, downstream 0 of 805. The selfchecks
  flagged 961, 1607 and 804.
* canaries ok=52 (surelog csv) and ok=16 (uhdm2rtlil csv); ctcan2 PASS on both (ok=58 and ok=2).
* binary audit of cmds.txt (fence-filtered): surelog 1523 of 1573 name law2, and the other 50
  hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.
* The trace fired in 69 processes. The 43 probe cases and 4 surelog rows are exactly the
  predicted set. In the sv-tests stage 22 processes fired: 21 uvm-examples rows, all EQUAL before
  and after, and rsd, SURELOG_CRASH as at the base. Only COPYINST and TFVARPARENT fired anywhere
  in the sweep.
* Both sweep commands exit 1 on the law-index check alone (the worktree's tests/LAWS.md is
  regenerated last, with this README).

Goal 1 re-checked: no SURELOG_ONLY row moved. All 75 details are unchanged from the control's csv
(upstream slang diagnostics, per passes 406 to 480).

## Residues (ranked; all wrong on pristine too, none moved away)

1. The enum element of a fixed array in a clone (CI/ci03). Law 1 abstains here. Golden's private
   enum copies also copy the base logic_typespec and the constants. § 241's enum copy shares
   both, and the copies' base instance is u(all) where golden has u(top).
2. A typedef of a package other than the clone's home (CI/ci16, v11u478 VM/vm12). § 241's drain
   abstains for third-package typedefs, so the array-element and function-level copies are
   missing. Golden's copies carry the typedef package's top view (s).
3. Nested member paths through a struct member array (VM/vm08 `acc[0].b[1].data`, vm18). These
   stop at an older head: ours writes a vpiInstance on the member's array_typespec where golden
   writes none, plus a package-listing difference (uhdm-cmp LHS null at package u).
4. The associative-array clone (CI/ci10): the function-level `op_t acc[int]` element variable in
   the definition-view clone keeps the shared struct (not copied by § 241's walk), whose instance
   is u's definition view.
5. Member types inside the copies made by § 241 and § 265 (and law 2) are shared. Golden copies
   them per reference: 20 member int copies against our 12 on VM/vm03. The strict comparator does
   not see this; it shows in the census.
6. The older heads on VM/vm11 (alias of the struct typedef) and VM/vm14 (class-scoped struct, where
   Surelog itself exits 4).
7. Carried, as in the brief: the alias-copy law's per-formal copies (VF/vf06) and three-level chain
   (vf02); pass 476's vp06 provider order; the interface-instance shapes iu14/vi15, vi16, vi01;
   AP/ap01, ap02, ap04, ap05; pass 480's FA residues (fa07, fa10, fa20 to fa23, fa25 to fa27);
   the elaborated continuous-assignment call folds (VA/va01, va05, va07, va14 to va16); and the
   carried lists of passes 480 and earlier.

## Sister-ground faces (reported, not written)

* ExprEmit's call-argument typespec: in `return f(1);` of a::g, golden's constant `1` carries a
  ref_typespec to f's formal int_typespec, ours none (CI/ci11, ci23; uhdm-cmp 33 lines; not
  decoded further).
* ExprEmit's constant fold of a package function call: golden folds `f(1)` to the constant 2,
  ours keeps the func_call (CI/ci22).
* StmtEmit's § importCloneBodyLocalCopies175 begin copies run after the shared typedef's instance
  is rewritten. Law 3 repairs their instance from this ground, as pass 478's
  § providerBodyCopyBind478 repairs their binding.

## Process

* One full sweep on law2. law3's narrowing fired nowhere in that sweep; its probe stage was rerun
  alone and law3 was checked byte for byte on the away census and MiniAmiq.
* byteverify ran once, against the master's control. No pristine build or sweep: the pristine
  reading is /tmp/intr11u480.
* The fence list was read into a file by a program, and every tree-wide list was filtered on it
  before any file was opened; the repro folder scans clean.
* No other agent's process was touched, and no other sweep ran during this one.

## Drivers and tools

* drivers/runcase.sh <bin> <tag> <casedir>...: Surelog golden with check_probe.py's flags, cached
  under /tmp/r11u482_runs/<full path>. Prints exit codes, uhdm-cmp lines, strict verdict, dump
  distance, object-census distance and md5.
* drivers/grid.sh <bin> <tag> [VAR=val...]: every case dir of this repro.
* drivers/bytecensus.sh <list> <out> <binA> <binB>: the away byte census (explicit dirs, 3 jobs).
* drivers/judge.py, offchk.sh, swchk.sh: the verdict movement, the R11U482_OFF check and the
  per-switch check over the movers.
* evidence/tools/clonescan.cpp (the prediction scan), tsinfo.cpp (a typespec's parent, instance,
  listers and references), tsinst.cpp (instance census), pkgs.cpp (package views),
  objcensus.cpp + msdist.py (the object census). Build each against ~/.local's UHDM:
  `g++ -std=c++17 -I$HOME/.local/include X.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread`.
