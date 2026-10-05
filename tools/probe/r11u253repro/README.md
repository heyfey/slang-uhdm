# r11u253: pass 253, the module/type ground: the ground-B heads of MiniAmiq and SeqDriver (the importer-copy mint parent, the tf-item local binding) and the copy typespec parents behind them

Base 56afa6f0 (`matrix-1.87`). Ground: src/UhdmExporter.cpp, src/TypeEmit.cpp, src/TaskFuncEmit.cpp, plus the new
src/R253.h (switch reader `r11u253On`, trace writer `tr253`). Nothing under results/, tests/ (apart from the
regenerated tests/LAWS.md) or third_party/ changes. No sister-ground file (ExprEmit, EmitHelpers.h, StmtEmit,
ParamEmit) is touched.

**Headline.** Every ground-B record at the head of MiniAmiq and SeqDriver is cleared; the four row-modes are now headed
by a sister-ground (StmtEmit) record. No corpus row converts; four probe cases convert; no regression in any stage.

* **Change MiniAmiq default / testflags, SeqDriver default / testflags**: `differ:fullname(5)` -> `differ:type(1)`
  (law sweep rows `MiniAmiq,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)`, the same on the other three).
  First-field changes: the old heads #79121 / #79122 / #79458 / #79459 (SeqDriver d #79078 ..., t #79090 ...) and
  #87013 (SeqDriver d #86971, t #86983) are cleared; the new head is #87036 (SeqDriver d #86994, t #87006), one
  record, on the sister ground (see "Sister-ground faces").
* **Probe conversions** (law sweep rows): `r10uvm193repro/g193_d_propfence,EQUAL,,equal` (was fullname(4)),
  `r10uvm208repro/g208_e_head,EQUAL,,equal` (fullname(5)), `r10uvm37repro/t51a,EQUAL,,equal` (fullname(2)),
  `r10v195repro/v195_d_tfitem,EQUAL,,equal` (depth(1)). Results/ untouched.
* **Probe changes** (all the same first field with fewer objects): `r10uvm193repro/g193_c_argface` fullname(44) ->
  fullname(4), `r10uvm122repro/g122_f_clone` endcol(8) -> endcol(7), `r10v200repro/v200_5_modmat` fullname(3) ->
  fullname(2), `r10v208repro/v208_f_io` name(12) -> name(7).

## Binaries (frozen before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine (fresh 56afa6f0 worktree, system-deps cmake config, -j 2) | 6c9a38c7c336533642274ab10bde5a8d | the same as the main tree's build/slang-uhdm |
| law (56afa6f0 + this pass) | 10f0d294e218c87a65dec461a46b908c | rebuilt after the last source edit: same md5 |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | |
| strictcmp_x (drivers/cc_x.sh, the chain-keyed census) | 886f030233ecdbcce7d0e29ac0c4df2c | |

Both link slang 12.0.0+545f88b2e. Binary-path audit (path list filtered by `$FENCED` first): 3265 of 3265 `slang:`
lines of each sweep's surelog and uhdm2rtlil cmds.txt name that sweep's frozen binary.

## Laws (src/R253.h; each `R11U253_<LAW>_OFF`, `R11U253_OFF` drops all; `R11U253_TRACE=<dir>` logs every firing)

1. **§ cloneMintParentHomeCall253** (`R11U253_MINTHOME_OFF`; UhdmExporter drainCloneArrayRecvArgMint193; cases
   `cases/M`). The element variable minted for a receiver argument (`visited.exists(succ)`) inside a wildcard-import
   copy hangs under the **home** body's call, not the copy's: its synthesized full name reads the home package
   (`uvm_pkg::uvm_phase::sync::visited.exists::succ`, MiniAmiq #79121 / #79122 / #79458 / #79459).
   *Decode*: UHDM clone_tree.cpp `method_func_call::DeepClone` writes
   `varclone->VpiParent(const_cast<any*>(obj->VpiParent()))`, where `obj` is the argument of the call being cloned;
   CompileHelper::importPackage clones the home subroutine, so the parent is the home's call. The home call is found
   in the home subroutine (the elaborated home first, else the definition listing, as § cloneStmtHomeVarRef17 pairs
   them) as the hier_path with the same file, span and element count whose element at the same index is a call of
   the same kind and name; an ambiguous or missing match keeps the copy's own call.
2. **§ cloneTfItemLocalOwnVar253** (`R11U253_TFITEMOWN_OFF`; TypeEmit cloneStmtHomeVarRef17; cases `cases/T`). In the
   tf-item production (a paren-less function, or a subroutine whose body declares its io: § 139's predicate,
   TaskFuncEmit's `blockItems9` false) a copy's body reference to a **subroutine-level** declaration binds the copy's
   own variable, not the home's: golden's `cs = uvm_coreservice_t::get();` in the copy of the paren-less
   `function void uvm_component::m_set_cl_verb;` binds `svaunit_pkg::uvm_component::m_set_cl_verb::cs` (dump read off
   SeqDriver's golden), ours bound the home's (MiniAmiq #87013, SeqDriver #86971 / #86983).
   *Decode*: CompileStmt.cpp compileFunction lists tf-item declarations on the subroutine, so the home body `begin`
   lists none of them; clone_tree clones the subroutine's Variables first and then pushes the copy's frame
   (`enterTask_func(clone)`), and the source begin's frame (`enterBegin`) holds nothing under those names, so
   `bindAny` returns the copy's own variable. With a port list (block items) the home begin carries them and golden
   binds the home's (T/t03 control, golden read off the dump). A nested block's declaration keeps the home binding
   (T/t07). A paren-less task blockifies (T/t05 control).
3. **§ cloneArrTsHomeElabFirst253** (`R11U253_HOMEARRELAB_OFF`; UhdmExporter, inside pass 247's
   § cloneArrTsHomeRefOwn247 in the § 241 design-final drain; cases `cases/A`). The shared home loop variable of a
   copy's `foreach` over a local array (§ cloneLoopVarShared37) binds the **home's** array_typespec; § 247 found it
   only on the subroutine's own listing and read the two home views (elaborated home and definition listing, each
   with its own array_typespec) as an ambiguity, so the copy's array_typespec stayed shared and § 241 left it
   unparented: golden's element ref_typespec under it reads the local's chain (`<in>`), ours nothing. The law takes the
   elaborated home's answer when both views answer once each, and looks the local up in the home's nested blocks
   (begin, named begin, fork) as well. Identity is invisible to the judge; the visible effect is the parenting
   (MiniAmiq / SeqDriver: the copies of uvm_string_to_action::actions, m_set_cl_verb's comps, m_set_cl_action's
   values).
4. **§ cloneTfFixedArrTsParented253** (`R11U253_TFFIXARRTS_OFF`; TaskFuncEmit, the fixed-size subroutine-level local
   branch; cases `cases/F`). The subroutine-level fixed-size twin of § cloneLocalArrayTsParented241 (queue / dynamic /
   associative locals) and § cloneBlockFixedArrTsParented244 (block-item fixed arrays): in an importer's copy the
   local's array_typespec is recorded for § 241's drain, which parents it at the local's ref_typespec under its guard
   (`int shelf193[4];` in Jetty193's copies of g193_c_argface).
5. **§ cloneFormalTsParented253** (`R11U253_FORMALTS_OFF`; UhdmExporter, after § 241's drain; cases `cases/P`). The
   formal twin of § 241: in an importer's copy a formal's anonymous typespec is a clone parented at the formal's
   ref_typespec, so the names under it read the copy's chain (golden `ref_obj UVM_LARGE_STRING` in the range of
   `logic [UVM_LARGE_STRING:0] str` of the copy svaunit_pkg::uvm_bits_to_string). The copy's return variable is the
   home's object in golden and is not touched; a named typespec is not touched; § 241's guard applies (the typespec
   is changed only when every ref_typespec binding it sits inside that one copy; 6 formals per UVM row-mode refused
   as shared, trace `cloneFormalTsParented253_shared`).

## Measurements

**Grid** (drivers/grid.sh, evidence/grid.txt; drivers/gridsum.py): 46 cases (`cases/M` 10, `T` 8, `A` 9, `F` 6,
`P` 13) in both views on 8 configurations (pristine, law, law + `R11U253_OFF`, law + each of the five switches): 736
lines, every line with its exit code, every exit 0.

* `R11U253_OFF` gives pristine bytes on 92 of 92 case-views.
* 33 case-views enter STRICT_EQUAL, none leaves; no uhdm-cmp line count rises.
* Each switch moves only cases its law fires on; § cloneFormalTsParented253 also moves every case holding a formal in
  a copy (most cases of the other grids), byte-only where the typespec holds no named object.
* Stage 1 on both binaries (pristine's uhdm-cmp already reads a package-level difference; bytes move, cmp lines
  identical): A/a01-a04, a09, F/f01-f04, f06, M/m01-m04, m06-m08, m10, P/p06, p07, p09 (default view). The laws were
  read on these through the probe and corpus movers below.

**Byte controls** (drivers/controls.sh, evidence/controls.txt): 17 earlier repro dirs (r11u241, r11u244, r11u247,
v11u247, r11u249, r11u251, v11u251, r10uvm193, r10v193, r10uvm195, r10v195, r10uvm37, r11u238, r10v208, r11u248,
v11u248, r10uvm208), 1280 case-views in both views, 2560 lines, exit codes identical on both binaries.

* 124 case-views move; 4 enter STRICT_EQUAL (r11u244 N/n13 both views, v11u247 A/a02_siblingq both views); none
  leaves; no uhdm-cmp line count changes.
* One first-field change: r11u238 F/f19 (an interface paren-less function) `depth` #37 -> `type` #45 and its
  elaborated view `fullname` #37 / #38 -> `type` #45: the walk reaches the sister face below.

**Firing census = the mover predictor** (drivers/tracecensus.sh, frozen before the law sweep as
evidence/predict.txt, md5 8d5d9c0bd94328fcae6918365a164b07 before path normalisation): 42 databases, 36 probe and 6
corpus (EvalFuncNamed d/t `cloneFormalTsParented253` only, MiniAmiq d/t and SeqDriver d/t all five laws),
0 uhdm2rtlil.

**Sweeps** (tests/sweep.sh --jobs 3, pristine /tmp/r11u253_wdP and law /tmp/r11u253_wdL, evidence/sweep_*):

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3543 + STRICT_NOTEQUAL 544, regressions 0 | EQUAL 3547 + 540: regressions=0 conversions=4 changes=4 |
| surelog | 937 + 17 (default 471 + 9, testflags 466 + 8), regressions 0 | regressions=0 conversions=0 changes=4 (MiniAmiq d/t, SeqDriver d/t) |
| uhdm2rtlil | 1606 + 0 | regressions=0 conversions=0 changes=0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same, verdict diff 0 |

Both sweeps exited 1 on `law index STALE` only (this pass's README and cases not yet indexed in the worktree);
tests/LAWS.md is regenerated last. The law csvs equal pristine's row for row apart from the four changed surelog
rows, the eight probe rows and the two LowMem path-text rows.

**Byte movers** (byteverify, SELFCHECK=1, same-length workdirs): surelog 6 of 960 (EvalFuncNamed d/t, MiniAmiq d/t,
SeqDriver d/t; selfcheck 959 / 960), uhdm2rtlil 0 of 1608 (selfcheck 1607 / 1608), probe 35 of 4087
(evidence/probe_movers.txt), downstream slang lanes 0 of 805. Every mover was predicted by name; one predicted probe
case did not move (r10v182repro/v182_g_names). EvalFuncNamed d/t stay CMP_EQUAL / equal (the formal typespec's parent
only). uhdm-cmp reads 0 lines on all six corpus movers.

**Away-moved census** (drivers/away.py via awaycorp.sh, flat key; drivers/flatlost.py, chain key; evidence/away,
evidence/flatlost_*):

* EvalFuncNamed d/t: distance 0 -> 0, lost 0.
* MiniAmiq d/t: distance 405 -> 229, flat key lost 26 / gained 72; SeqDriver d/t: 245 -> 132, lost 10 / gained 58.
* Chain key: every flat-key loss (MiniAmiq 62 contexts, SeqDriver 7 per mode) is a pristine surplus in a context where
  golden has none (`g=0 off>=1 on=0` on every line): 0 records lost. Attribution by switch on MiniAmiq default:
  § cloneTfItemLocalOwnVar253 removes the expansions of the home variables ours bound (the uvm_severity enum subtrees,
  17 flat records) and § cloneArrTsHomeElabFirst253 the copy array_typespec reached through the home loop variables
  (9 `uvm_reg_addr_t` element records); golden binds the copy's own object, which the walk does not re-expand.

**Heads** (drivers/heads.sh --max 30, evidence/heads_*): at the base MiniAmiq d #79121, #79122, #79458, #79459
(fullname), #87013 (depth); with the laws #87036 `type` alone on all four row-modes (SeqDriver d #86994, t #87006).

**Determinism** (drivers/det.sh, three concurrent draws per row-mode of the law binary, one job each,
evidence/det_law.txt): one hash per row-mode on 11 of 11 (Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard
default, BuildUVMPkg, both modes; Scoreboard testflags writes no database), each equal to the law sweep's.

**Canaries**: surelog `ok=50 changed=2` (the two SeqDriver rows, targeted); uhdm2rtlil `ok=16 changed=0`; ctcan2
PASS on both corpora (EXPECT_UNKNOWN=1 / 6).

## Sister-ground faces (decode only; call sites)

1. **MiniAmiq d/t #87036, SeqDriver d #86994 / t #87006, the new head of all four** (StmtEmit, the foreach branch's
   § cloneLoopVarHomeObject183 block, `res183`). In the copy of the paren-less m_set_cl_verb, `foreach (values[i])`
   over the tf-item local `static string values[$];`: golden's shared home loop variable binds string_typespec
   3380:10, ours keeps the unsupported placeholder. Surelog compiles a tf-item `string x[$]` as a string_var (the
   dimension is dropped, both sides agree), so `arrayVarArrayTs` has no entry and the io_decl branch does not apply; the
   loop variable takes the local's own string_typespec (`decode/LV` lv01 static, lv02 non-static, both STRICT_NOTEQUAL
   `type` on both binaries). A measurement-only prototype at that site (`netMap` entry a string_var: the actual of its
   ref_typespec; never delivered) clears it and reads, with this pass's laws, `fullname(3)` then `type`:
   * #90429 / #90430: in the copy of uvm_sequencer_base::m_choose_next_request, the inner bit_select of
     `arb_sequence_q[avail_sequences[i]].sequence_ptr` and its index read golden
     `...arb_sequence_q[[i]].sequence_ptr::arb_sequence_q::avail_sequences`, ours without `arb_sequence_q::` (the
     hier_path index naming, ExprEmit);
   * #89283: the copy's `ref_obj UVM_LARGE_STRING`, cleared by § cloneFormalTsParented253 (prototype + law);
   * #93788: `foreach (this_type::m_typewide_sequences[i])` in the copy of
     uvm_sequence_library::init_sequence_library, golden's shared loop variable binds an unlocated int_typespec, ours
     an array_typespec (StmtEmit, the same block).
2. SimpleUVM d/t value(50) #203342 (ParamEmit's imported-parameter mint, pass 251's decode/HP), BlackBePipeInt
   #38807 / #38803 (ParamEmit stampParenCastWidthTs) and the package typedef listings of arrays (ParamEmit
   emitPackage): unchanged, not attempted.

## Residues, ranked

1. The sister head above (4 row-modes of MiniAmiq and SeqDriver; then #90429 ExprEmit and #93788 StmtEmit).
2. **BuildUVMPkg d/t depth(1) #185844**, unchanged. The eight TLM socket classes' in-body formals
   `connect(this_type provider)` (uvm_pkg.sv 60207 ... 60615) are unbound in golden; ours binds the first-key class's
   `this_type` (uvm_abstract_component_registry 13776:11). uvm_port_base's own formals (45472, 45678, 45753) are bound
   to its own on both sides. Decode cases `decode/TT` (and nine unrecorded variants: a specialised class parameter as
   the base's base, class and enum defaults, `$cast` of the formal, a local, an overriding base method, `super.connect`)
   all read golden binding the FIRST-KEY class's typedef, as ours does; the distinguisher of the UVM sockets is not
   isolated.
3. g193_c_argface's last 4 records (c7 / c11, both views): the receiver index `fleet193[kink193]` whose name equals the
   call argument's carries the argument's full name in golden (`...fleet193[kink193].rub193::kink193`), ours its own.
4. Rggen d fullname(199) #26477 (199 objects across port-view names, constants and bind columns) and Earlgrey_0_1
   #136315 / #137760 / #142988 / #154375: not attempted.
5. The brief's items (3) to (7) not attempted.

## Process

* No fenced test was dispatched, read or opened outside the gate sweeps. The firing census ran through the harness
  with the filter built from `$FENCED` (exact names; word boundary on probe paths); every scan of a sweep tree built
  its path list and filtered it by `$FENCED` first; the evidence directory reads clean on a fence grep.
* Every tool variable was checked with `[ -x ]` (env file and drivers).
* **Process error, recorded**: the FIRST binary-path audit ran `find <sweep>/surelog <sweep>/uhdm2rtlil -name
  cmds.txt | xargs grep` without filtering the path list by `$FENCED`, so it read the command-line records of the
  fenced rows' cmds.txt in both sweeps; it printed only per-binary counts (3273 per sweep). No fenced source or
  database was opened and nothing about a fenced row was printed or used; the audit was rerun with the path list
  filtered first (the 3265 above).
* One waiter used `pgrep -f` on a pattern held in its own command line (waiting for the census); it could not end and
  was stopped by its own task id after the census had finished; no process was signalled or listed otherwise. Every
  later waiter tested a file.
* Measurement-only debug and prototype builds (prints in TypeEmit and UhdmExporter, the StmtEmit prototype) were
  built from temporary source edits that were reverted before the law binary was built; the worktree's StmtEmit is
  the base's.
* Drivers resolve from the repo: case.sh, env.sh, grid.sh, gridsum.py (new), controls.sh, det.sh, heads.sh,
  tracecensus.sh, away.py, awaycorp.sh, awayrows.py, flatlost.py, cc_x.sh, strictcmp_x.cpp, bvmirror.sh, dscases.py.
