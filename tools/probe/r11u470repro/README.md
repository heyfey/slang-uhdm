# r11u470 — module/type ground, sv-tests campaign pass 470 (implementer)

Base e8a5bf18e. Production file touched: src/UhdmExporter.cpp only (TypeEmit, ModuleEmit,
TaskFuncEmit, uhdm_main.cpp, include/ unchanged; no sister file touched). Four laws, each
read through src/LawSwitch.h (`lawOn(470, "R11U470_<LAW>_OFF")`), `R11U470_OFF` drops all
four, `R11U470_TRACE=<dir>` logs every firing (`lawTrace(470, ...)`). No src/R*.h, no
LawState.h section, no getenv, no reader function.

Binaries (frozen, /tmp/r11u470_bin): pristine a6a6254bae1a79e2c4d36d6fecb0de6a (equal to
the main tree's base build), final law binary law8 22eb28bc9ffef4bed8a34068c3be4e26
(drafts law1 to law6 on case runs and runner calls only; law7 ee4d4068cf1c9d2e31e5e517e89afee3
swept once, see the sweep section).

## The laws

- § specValueArgRefObj470 (R11U470_SPECVALARG_OFF; cases VA). The VALUE branch of Surelog's
  specialization loop (CompileType.cpp, compileDatastructureTypespec's ClassDefinition
  branch): an ordered argument that is not a data type goes through compileExpression; when
  that returns a ref_obj (a name it does not reduce) the loop calls
  compileDatastructureTypespec again with the argument's name, finds no type of that name and
  mints an unsupported_typespec named after it, located at the whole `#(...)`; the
  type_parameter (named after the paired formal) and its param_assign carry no location, the
  param_assign's Lhs is the formal. Measured on the grid: only a CLASS-scoped name `K::w`
  stays a ref_obj (va01, va02, va07, va09, va13, va14, va20 move); a literal, a
  package-scoped `r::X`, a package parameter, an expression `K::w + 1` and a bare class-local
  name take another path and push nothing (va03 to va06, va11, va12 byte-identical); a value
  formal still advances the pairing index; `p::K::w` abstains (va15, golden names it
  `p::w`). Written in emitClassPropSpecParams163 (the class-property / package-typedef
  listing builder).
- § pkgTdSpecPairsImported470 (R11U470_PKGTDPAIR_OFF; case VA/va01; sv-tests
  uvm_param_vif_config_db's `SFR_cfg_t`). The package typedef listing that § 460's drain
  writes is built AFTER § specArgPairsImportedFormal468 ran, so a target class whose own
  parameter list starts with its imports' parameters kept its arguments paired with its own
  formals (golden `type_parameter UVM_ALL_ON` on SFR_cfg_t, ours SFR_ADDR_WIDTH). The same
  re-pairing (`repairSpecPairs468`, factored out of § 468 unchanged) runs on that listing
  before the aliases take their deep copies. Gated by R11U468_SPECIMPFORMAL_OFF too.
- § tdSpecArgTypedefShares470 (R11U470_TDSPECARGTD_OFF; cases TS; sv-tests
  uvm_param_vif_config_db's `typedef uvm_object_registry #(this_t) type_id;` written by
  `uvm_object_param_utils(this_t)`). § specArgTypedefNameShares468 at the class-scope
  typedef builder of a foreign generic (emitClassTdSpecParams1): an argument written as a
  typedef's name shares the typedef's own object; and every clone that
  copyClassTdSpecParams1's deep copy made of such a base gets its OWN deep copy of the
  typedef object for that formal (Parameters and param_assign Rhs alike), made design-final
  at the end of finish241 (Surelog's clone_tree of the base, after the base was bound). In
  that copy a package typedef target keeps its bare name and the elaborated package (the
  vpiTop view) as vpiInstance, since Surelog cloned before UhdmWriter renamed it `pkg::name`.
  Gated by R11U468_SPECARGTD_OFF too. The bookkeeping is side lists (membership set, clone
  pairs, deferred pairs), cleared after use; nothing is added to a listing struct.
- § clsPropSpecFullNameLazy470 (R11U470_PROPFULLLAZY_OFF; cases LZ; the v11u468 FINDING).
  § clsPropSpecTpFullName468 read class_defn::VpiFullName() and type_parameter::VpiFullName()
  before deciding to fire. UHDM's generated getters compute AND STORE the full name when none
  is stored, and storing registers a symbol: the serializer numbers symbols in creation order
  (Serializer_save.cpp saves the symbol table after every save function, which calls the same
  getter), so an early registration renumbers the table and moves bytes with an identical dump,
  with no trace line. The law fires only where a type_parameter carries a STORED name `C.T` (a
  name stored early, while the class_typespec had no parent; a name computed now always holds
  `::` since the class_defn is in the chain, and never matches). The lazy path reads only a
  stored name (`storedFullName470`: the name and parent cleared so the getter computes an empty
  name and stores nothing, both restored, the name's symbol already registered so its id is
  unchanged), and calls the class_defn getter only on a match.
  Bisect (case runs): making only the class_defn read lazy (law6) left all 17 away dirs on the
  § 468 bytes, so the type_parameter read is the mover; law7 tested the COMPUTED name instead
  (no store) and so never matched: its sweep read the three scoreboard rows EQUAL ->
  STRICT_NOTEQUAL differ:fullname(2), a break found by the sweep and fixed in law8 by the
  stored-name read (the three rows back to EQUAL, the law firing on them again).
  Result on law8: the 17 away dirs of the v11u468 finding (r11u254 I/i10_copy, r11u434 SF/sf04
  to sf07, v11u434 VS/vs01 to vs12) read exactly the md5 of pristine with
  R11U468_PROPSPECFULL_OFF (evidence/away468_*.txt), their verdicts unchanged (16
  STRICT_EQUAL, vs11 NOT_EQUAL 33 lines as before); LZ/lz04 is this pass's own mover, lz01 to
  lz03 byte controls.

## Targeted rows (sv-tests)

- generated/uvm-examples/uvm_param_vif_config_db.sv: DIFFERENT -> DIFFERENT, uhdm-cmp
  230 -> 172 lines, the head moved later. At the base the head was the uvm_comparer
  type_id's `T`, golden a deep copy of `this_t` whose alias reaches a copy of `SFR_cfg_t`
  listing UVM_ALL_ON / UVM_CHECK_FIELDS with unsupported_typespecs SFR::sfr_addr_width /
  SFR::sfr_data_width, ours the shared `tb_params_pkg::SFR_cfg_t` with no parameters.
  Draft readings: law1..law3 230, law4 220, law5 2054644 (the copies instanced at the
  definition-view package: golden's instance is the vpiTop view), law6/law7 172.
  The NEW HEAD (evidence/pvc_heads_law6.txt, cmptrace2): golden's DEFINITION-view
  tb_params_pkg lists its own two virtual-interface typedefs first
  (`interface_typespec tb_params_pkg::SFR_master_bfm_t` 54:17 and `SFR_monitor_bfm_t` 53:17,
  parented and instanced at the package), ours lists none: the package typedef loop in
  ParamEmit's emitPackage has no VirtualInterfaceType branch (`ts` stays null, `continue`), a
  SISTER-GROUND face (cases VB/vb01 to vb05 reproduce it on a plain package: golden lists
  `t::vt_t` at the interface name in both package views and in the importing module's
  listing; ours lists it nowhere and types the module variable `vt_t h` as a logic_typespec).
  Heads after it on the row: tb_params_pkg's subroutine listing (golden binds the class
  methods of sfr_driver/sfr_agent through sfr_agent_pkg's class_defn where ours lists import
  copies under tb_params_pkg), the vpiInstance of the original `this_t` of sfr_agent and
  sfr_config_object (golden tb_params_pkg), and the vpiInstance of tb_params_pkg's
  string_typespecs (golden the other package view): not decoded.
- generated/easyUVM/top.sv: unchanged (DIFFERENT). Its heads on law6
  (evidence/easyuvm_heads_law6.txt): exp.compare(rec)'s default argument (ExprEmit, the
  sister's), then the uvm_report string constants: DECODED here, they are `__FILE__`
  expansions, golden `"/.../easyUVM/env.sv"` size 512 where ours writes
  `"/.../easyUVM/./env.sv"` size 528 with the end column 2 later: slang's preprocessor gives
  `__FILE__` the include path as it was joined (`./env.sv` under `-I.`), Surelog the
  normalized path; the constant is written by ExprEmit (the sister's ground: normalize the
  path of a `__FILE__` string literal), then interface_inst / module_inst listing heads at
  the design (the included modules and interfaces, EmitHelpers.h collectMaterializedPkgs'
  raw-buffer comparison, the sister's, as pass 468 reported).
- The three scoreboard rows: stay EQUAL (the § 468 laws they need are untouched; the lazy
  law fires on them through its matched path).

## Gates

Pristine reading: the master's control sweep /tmp/intr11u468 (its csvs equal results/*.csv).
Prediction written before the sweep: evidence/prediction.txt (it allowed Tnoc and the UVM coin
rows to move; neither Tnoc nor any other corpus row moved, the Scoreboard default coin did).

ONE full five-stage sweep on law7 (/tmp/r11u470_sw, R11U470_TRACE on; evidence/
sweep_law7_summary.txt): probe EQUAL 4024 + STRICT_NOTEQUAL 63, regressions 0 conversions 0
changes 0; surelog default CMP_EQUAL 480 / testflags 474 + 0, 0/0/0 (Tnoc d/t CMP_NOTEQUAL
standing); uhdm2rtlil 803/1/67 in both modes, 0/0/0; downstream IDENTICAL 803 / SLANG_REJECT 66 /
EQUIVALENT 2 / DIVERGENT 0, verdict diff against the control 0; sv-tests REGRESSIONS 3: the three
scoreboard rows EQUAL -> STRICT_NOTEQUAL differ:fullname(2), law7's lazy test reading the
computed name so § clsPropSpecTpFullName468 no longer matched (the break, fixed in law8). The
four-stage command exited 1 on the stale law index alone. The trace logged no firing in probe,
surelog, uhdm2rtlil or downstream, and firings on 5 sv-tests rows (the positive control of the
same exported variable).

The narrowed law (law8) changes only that one predicate, so the affected stages were rerun
alone on law8 (/tmp/r11u470_s8, trace on; evidence/sweep_law8_narrowed_summary.txt): probe
EQUAL 4024 + 63, 0/0/0, the csv equal to the control's on name/status/detail; surelog 480 + 0
/ 474 + 0, 0/0/0; the uhdm2rtlil and downstream rows that hold a class (OneClass, OneThis
both modes CMP_EQUAL and byte-identical to the control, downstream IDENTICAL; hello-uvm
SLANG_REJECT as in the baseline); sv-tests EQUAL 1935, STRICT_NOTEQUAL 0, DIFFERENT 5,
BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346 with
REGRESSIONS 0, CONVERSIONS 0, CHANGES 0 (the scoreboard rows `EQUAL,,equal`). Trace on law8
(evidence/trace_law8_svtests.txt): no firing in probe or surelog; sv-tests firings on exactly
uvm_param_vif_config_db (pkgTdSpecPairsImported470 2, specValueArgRefObj470 4,
tdSpecArgTypedefShares470 7), the three scoreboard rows and easyUVM
(clsPropSpecFullNameLazy470 1 and tdSpecArgTypedefShares470 1 each, statuses kept).

byteverify (SELFCHECK=1) against the control: law7 surelog 1 of 962 (Scoreboard default, the
known coin, its dump identical to the control's, no 470 law firing), uhdm2rtlil 0 of 1608,
downstream 0 of 805; law8 surelog 1 of 962, the same Scoreboard default bytes as law7. Canaries:
surelog ok=52 and ctcan2 ok=58 (EXPECT_UNKNOWN=1, PASS) on law8's csv; uhdm2rtlil ok=16 and
ctcan2 PASS (EXPECT_UNKNOWN=6) on law7's csv. uhdm-cmp: every touched corpus row stays at 0 lines
(no corpus row moved). No corpus mover, no probe status change.

No sv-tests row converts this pass. uvm_param_vif_config_db: DIFFERENT -> DIFFERENT, uhdm-cmp
230 -> 172 lines on law8 with the head later (above). easyUVM: 60 lines, unchanged.

## Grid (32 case dirs; evidence/grid_pristine.txt, grid_law7.txt, grid_dist.txt)

Every case is accepted by upstream slang except VA/va16 (`static const` class members are
not constant: upstream slang rc 1, ours rc 3 on both binaries), the negative control.
Case -> law: VA/* § specValueArgRefObj470 (va01 also § pkgTdSpecPairsImported470), TS/*
§ tdSpecArgTypedefShares470, LZ/* § clsPropSpecFullNameLazy470, VB/* residue controls
(sister face) under § specValueArgRefObj470's name.

- STRICT_EQUAL 7 on pristine (va06, va11, va12, lz01 to lz04), 10 on law7 (+ va07, va13,
  va14). Every exit code 0 on both binaries (va16 3 on both).
- Movers 11: va07, va13, va14 to STRICT_EQUAL; va01 161 -> 17 uhdm-cmp lines (dump distance
  433 -> 327), va02 153 -> 17 (221 -> 131), va09 234 -> 169 (53 -> 4), va20 300 -> 235
  (102 -> 4), ts01 87 -> 17 (130 -> 77), ts02 40 -> 40 (47 -> 43), ts03 36 -> 145 uhdm-cmp
  lines with the dump distance 18 -> 12 (the head moved later: golden's `type_id` T now
  shares `this_t` in both, the next difference golden's shared `this_t` parented and
  instanced at the module where ours keeps the class_defn parent, a module-level object that
  uhdm-cmp prints whole), lz04 bytes only (the stored type_parameter names gone, dump equal).
- Byte-identical 21 (va03 to va06, va08, va10 to va12, va15 to va19, vb01 to vb05,
  lz01 to lz03). None moving away by strict verdict or dump distance.
- Switches: R11U470_OFF on law7 gives pristine's bytes and exit code on 32 of 32 dirs.
  Each law alone: R11U470_SPECVALARG_OFF restores 7 dirs (va01, va02, va07, va09, va13,
  va14, va20), R11U470_PKGTDPAIR_OFF 1 (va01's re-pairing), R11U470_TDSPECARGTD_OFF the 3 TS
  dirs, R11U470_PROPFULLLAZY_OFF lz04 (and the 17 away dirs back to the § 468 bytes).

## Residues (ranked)

1. uvm_param_vif_config_db's package virtual-interface typedef listing (ParamEmit
   emitPackage, sister ground; VB cases), then its subroutine-listing and vpiInstance faces.
2. easyUVM: `__FILE__` normalization and exp.compare's default argument (ExprEmit), the
   included modules' listing (EmitHelpers.h) — all sister ground.
3. ts03: the shared `this_t` of a module-level specialization parented and instanced at the
   module in golden.
4. va03 to va05, va08, va10, va15, va17 to va19: value-argument shapes whose first
   difference is elsewhere (unchanged on both binaries); `p::K::w` (va15) naming.
5. The carried lists of passes 468 and earlier stand.

## Sister-ground faces (reported, not written)

- ParamEmit.cpp emitPackage, the package typedef loop: no VirtualInterfaceType branch, so a
  package `typedef virtual ifc #(...) T;` is listed in neither package view (golden: an
  interface_typespec named pkg::T at the interface name, parented and instanced at the
  package; VB/vb01 to vb05; uvm_param_vif_config_db's next head).
- ExprEmit.cpp, the string constant of a `__FILE__` expansion: golden the normalized path
  (easyUVM env.sv; `./` dropped), ours slang's joined include path.
- ExprEmit.cpp call arguments: exp.compare(rec)'s default null (pass 468's report).
- EmitHelpers.h collectMaterializedPkgs' raw-buffer comparison (pass 468's report).

## Process

Restarted implementer (RESUME NOTE). law5 to law8 built after the restart (law8 the final
binary), every build -j 2 with no sweep live. Slip: the five-row runner call on law8 (the
scoreboard rows, param_vif_config_db, easyUVM) overlapped the master's landing sweep
/tmp/intr11u475 (timing only; the readings were repeated by the narrowed stage rerun on a quiet
machine). Budget: one full sweep (law7) and, for the narrowed law, the affected stages alone. No pristine build or pristine sweep: the
pristine reading is the master's control /tmp/intr11u468. The fence list read into a file by
a program without printing it; the text census filtered every path on it before opening a
file; no fenced test named, opened or run. Drivers: drivers/runcase.sh (probe args, keyed
on the full repro path), runuvm.sh, dist.sh (path-normalized dump distance), quietwait.py
(pass 466's wait program), env.sh. Tools in evidence/tools (cmptrace2 from pass 446, chain2,
pkgts, modts: build with `g++ -O2 -std=c++17 <f>.cpp -I ~/.local/include -L ~/.local/lib64
-L ~/.local/lib -luhdm -lcapnp -lkj -o <f>`).
