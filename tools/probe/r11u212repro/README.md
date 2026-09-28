# r11u212: v1.87 strict pass 212, the module/type ground (pair B, refill after pass 209)

Base `b69dc2da` (pass 209). Ground: src/TypeEmit.cpp, src/ModuleEmit.cpp, src/UhdmExporter.cpp (TaskFuncEmit.cpp and
uhdm_main.cpp untouched). Six laws, each behind its own switch; `R11U212_OFF` drops all six;
`R11U212_TRACE=<dir>` names every firing (`<dir>/<pid>.212`, first line `OUT <-o path>`).

**Verdict in one line:** no corpus row-mode converts (every row this ground can reach still carries records of the
sister ground or of a Surelog defect, section 5); 12 corpus databases move, all toward golden, all predicted by name;
4 probe conversions and 2 probe changes; 0 regressions in all three stages; downstream 803 / 66 / 2 / 0 with the
verdicts identical to the pristine sweep and to the baseline, row for row.

## 1. The laws

| law | site | switch | statement |
|---|---|---|---|
| § anonMemberTdLastWriter212 | UhdmExporter.cpp `typedefParentModel134` | `R11U212_ANONMEMTD_OFF` | a named struct, union or enum typedef written as the member type of an ANONYMOUS struct or union is parented at the last such member; its member refs (the enum's base ref) read `<member>.<typedef>.<m>` |
| § pkgEnumAliasListingParent212 | UhdmExporter.cpp `typedefParentModel134` | `R11U212_PKGENUMALIAS_OFF` | a package typedef that aliases an enum typedef (`typedef e_t f_t;`), left without a parent, is parented at its package: its alias ref reads `p::p::f_t` |
| § queueMemberSpanToDim212 | TypeEmit.cpp `buildStructTs` | `R11U212_QUEUEMEMSPAN_OFF` | a queue struct member (`string args[$];`) spans its name through the last dimension, the end read through setLoc's location model |
| § sizeDimOvrFileAtDim212 | ModuleEmit.cpp `fillSizeDimRange` | `R11U212_SIZEDIMFILE_OFF` | the override value folded into a size dimension (`p[N]` with `.N(25)` in another file) takes the dimension's file with its line and columns |
| § signCastSysCallLhsTs212 | ModuleEmit.cpp `emitContAssigns` (the written-assignment `$signed` stamp) | `R11U212_SIGNCASTTS_OFF` | a signing cast (`signed'(x)`, `unsigned'(x)`) as a whole right side of a module continuous assignment onto a name is stamped with the left side's typespec, like a written `$signed(x)` |
| § ndaSysCallNetTs212 | ModuleEmit.cpp `emitContAssigns` (the net-declaration branch) | `R11U212_NDASYSTS_OFF` | a module net declaration whose whole initializer is a system call (`$signed`, `$unsigned`, `$bits`, `$clog2`, the range queries) or a signing cast is stamped with the net's typespec |

### 1.1 Decodes (Surelog source under third_party/Surelog/src)

* **anonMemberTdLastWriter212.** CompileType.cpp, the struct-member loop of `compileTypespec` (`paStruct_union`):
  every member ends with `member_ts->VpiParent(m);`, and for a bare typedef name `compileDatastructureTypespec`
  returns the typedef's OWN typespec (TypeDef::getTypespec: no clone for a struct, union or enum), so every anonymous
  aggregate that writes the typedef re-parents the one shared object. The order, decoded by grid (cases/SR):
  definitions in UhdmWriter's order, programs, then interfaces, then modules (s32: interface `zi` loses to module
  `dut`; s39 a program loses to the module), each group in name order and NOT in instance order (s19: `zb` wins over
  `za` whatever the declaration order; s25: top `zz` wins over its child `aa`; s26 `zz` over `yy` over `aa`); inside
  one definition, declaration order (s04 `third` after `second`; s01 `q` after `p`; s35 nested: the outer member
  after the inner). The member reparent comes after the module's own typedef listing (s07: a module typedef reads
  `q.in_t.a`, not `work@dut.in_t.a`) and BEFORE writeCont_assign's unparenting (UhdmWriter.cpp writeCont_assign:
  `if (tps != nullptr) const_cast<typespec*>(tps)->VpiParent(nullptr);`), which keeps the last word: s13 (a
  continuously assigned variable of the typedef declared BEFORE the anonymous struct) and s05, s23, s31 read the bare
  name (§ contAssignLhsTsUnparented134 already models the unparent; the new block sits between the listing writer and
  it in `typedefParentModel134`). The definition-view anonymous aggregate has no parent, so the name stops at the
  member. Declines: a typedef held by a package or class (s17 parse view: a package typedef keeps the package
  listing), a typedef nested in a NAMED outer typedef (s02, s03: no anonymous aggregate), a member whose anonymous
  chain carries a name.
* **pkgEnumAliasListingParent212.** UhdmWriter `writeDataTypes(setParent)` parents every datatype of a package map at
  the package; the alias copy (an enum_typespec with a Typedef_alias ref to the aliased enum) was left parentless by
  ours, so its alias ref read `p::f_t` (grid EA e02) where golden reads ComputeFullName over the package chain,
  `p::p::f_t`. An importing module that lists the alias sets a parent before the model runs and is not touched (e03,
  EQUAL before and after); the listing writer of § typedefParentLastWriter134 skips enums on purpose (a plain package
  enum keeps its package parent, which ours already writes). A continuous assignment typed by the alias unparents it
  afterwards (uhdm2rtlil TypedefEnum: the law fires, § contAssignLhsTsUnparented134 unparents, the bytes stay pristine).
* **queueMemberSpanToDim212.** CompileType.cpp's member loop locates every member with
  `buildTypespecMember(..., fC->Line/Column/EndLine/EndColumn(Variable_decl_assignment))`: the node runs through the
  variable dimension whatever its kind; ours extended only the fixed-size form. Grid cases/QM: q01 (BuildUVMPkg's
  `uvm_cmdline_parsed_arg_t`), q04 module struct, q05 class-scope struct, q06 two declarators and a spaced dimension,
  q07 a member written inside a macro body (the first draft read the dimension end's raw column, 0 inside the
  expansion; the law now ends through setLoc's pp166 model, 6:19 as golden), q08 an included header, q09 CRLF, q10 a
  dimension on the next line. The dynamic-array and associative forms (q02, q03) are stage-1 unequal at the base and
  are not claimed.
* **sizeDimOvrFileAtDim212.** ModuleEmit `fillSizeDimRange`, § sizeDimOvrChain4's Verbatim branch: the override literal
  is emitted from the instantiating file and relocated by `setLoc(c, bs->expr->sourceRange())`, which never replaces
  a file already set; Surelog's reduced constant carries the dimension's location whole. Rggen d #22375
  (`register_if[REGISTERS]`, `.REGISTERS(25)` in block_0.sv): golden rggen_apb_adapter.sv 18:39-48, ours block_0.sv
  18:39-48. Grid cases/SF (two files): f01 by name, f02 positional, f03 a decimal-based sized literal, f06 the child
  in an included header; f04 (no override) is another face (the default's ref_typespec, pre-existing, section 5), f05
  stage 1.
* **signCastSysCallLhsTs212 / ndaSysCallNetTs212.** UhdmWriter.cpp writeCont_assign's name-blind branch
  (`rhs->UhdmType() == uhdmsys_func_call && Typespec() == nullptr` -> a ref_typespec whose actual is `tps`, the left
  side's typespec) runs on every netlist cont_assign, and a net-declaration assignment is one
  (NetlistElaboration elabSignal); CompileExpression's paCast branch compiles `signed'(x)` as a `$signed` sys_func_call
  with no typespec. Ours stamped only a written system call of a written assignment. Grid cases/NS: n01 n02 n05
  (net declarations), n03 (a written assignment of a cast), n06 (a child instantiated twice) leave stage 1; n08 (an
  interface: golden's stamp is UNRESOLVED there, writeCont_assign binds no interface variable) made the law module-only
  (the first draft bound it and read a new stage-1 record); n07 (generate scope), n09 (a select target), n10 (an
  interface net) stay stage 1 at their pre-existing heads.

## 2. The grid (cases/, 75 cases x 2 views = 150 case-views; evidence/grid/grid_pris_law.tsv)

Every case names its law in its first line. `drivers/grid.sh` with `GRIDBINS="pristine.bin law.bin" OFFCHECK=1`:
**R11U212_OFF restores the pristine bytes on 150 of 150 case-views.**

| family (law) | cases | pristine -> law (case-views) |
|---|---|---|
| SR (anonMemberTdLastWriter212) s01-s42 | 42 | fullname -> **EQUAL 51**; EQUAL -> EQUAL 17 (s02 s03 s05 s13 s23 s29 s30 s31 s17 parse, controls); fullname -> fullname 6 (s09 x2: the anonymous union's elaborated member refs `work@dut.v.p`; s17_el, s28_el, s32_el, s33_el: one pre-existing interface/package record each); endcol -> endcol 4 (s08, s18: the anonymous struct's own span, pre-existing); stage 1 -> stage 1 6 (s16, s27, s40) |
| EA (pkgEnumAliasListingParent212) e01-e07 | 7 | fullname -> **EQUAL 2** (e02); EQUAL -> EQUAL 6 (e03-e05); stage 1 6 (e01 e06 e07: the formal writer-order family, section 5) |
| QM (queueMemberSpanToDim212) q01-q10 | 10 | endcol/endline -> **EQUAL 16**; stage 1 4 (q02 q03) |
| SF (sizeDimOvrFileAtDim212) f01-f06 | 6 | file -> **EQUAL 8**; fullname -> fullname 2 (f04); stage 1 2 (f05) |
| NS (signCastSysCallLhsTs212, ndaSysCallNetTs212) n01-n10 | 10 | stage 1 -> judge-equal 10 (n02_el **EQUAL**; n01 n03 n05 endcol: the stamp binds the definition net's typespec where golden binds the elaborated net's, visible only on a `signed` net whose definition typespec ends at the keyword; n02 parse and n06_el depth, n06 fullname: the elaborated net-declaration assignment's left side, a copy where golden lists the net itself); stage 1 -> stage 1 10 (n04 n07 n08 n09 n10) |

**Totals: 78 case-views convert to EQUAL (one of them, NS n02_el, from stage 1), 23 EQUAL stay EQUAL, none leaves EQUAL; 9 more leave stage 1 for a strict record.**

## 3. The gates (evidence/sweeps/, evidence/gates/, evidence/movers/)

Binaries (frozen, `chmod 555`, /tmp/r11u212_bin): pristine `e453e0e281c4bc7ad330c68a5eda1295` (byte-identical to the
main tree's build/slang-uhdm), law `318e90a35b26e2494948a5bfe45418c6`. Sweeps `tests/sweep.sh --jobs 3` from the
worktree: pristine /tmp/r11u212_sP, law /tmp/r11u212_sQ (same-length names). Every one of the 3273 `slang:` lines of
each corpus sweep names that sweep's frozen binary by path.

| stage | pristine vs baselines | **law vs baselines** |
|---|---|---|
| probe | 3403 + 684, 0 / 0 / 0 | **3407 + 680: regressions 0, conversions 4, changes 2** |
| surelog | 927 + 27, 0 / 0 / 0 | **927 + 27: regressions 0, conversions 0, changes 10** |
| uhdm2rtlil | 1596 + 10, 0 / 0 / 0 | **1596 + 10: regressions 0, conversions 0, changes 2** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **803 / 66 / 2 / 0, rc 0; verdicts identical to the pristine sweep and to results/downstream_uhdm2rtlil.csv row for row** |

The pristine sweep's `rc=1` on the downstream stage was the law-index staleness of the edited worktree (the stage
itself read 0 unexcused); the law sweeps ran after the index was regenerated and read rc 0.

Probe conversions (fresh csv rows, `EQUAL`): `r10uvm149repro/g149/shapes` (endcol(30), queue law),
`r11u107repro/grid/a12_anon_named_member` (fullname(8)), `r11u109repro/grid/f5/k10_named_member_dim` (fullname(14)),
`v11u93b107repro/brk/p04_enum_member` (fullname(5)) (the last three the anonymous-member law). Probe changes:
`r10uvm149repro/g149/homes` endcol(15) -> endline(1) (the 14 queue-member records gone, the anonymous struct's own
span record left), `r10v149repro/arms/paramtype` endcol(22) -> fullname(2) (20 queue records gone).

Corpus changes (all shrinking or moving the first field past a cleared record):

| row-mode | base | law | laws (from the firings) |
|---|---|---|---|
| BuildUVMPkg d/t | endcol(57) | col(51) | queue (57 -> 55: #22884 #23179, `uvm_cmdline_parsed_arg_t.args`), alias (55 -> 51: the `UVM_SEQ_ARB_TYPE` alias ref `uvm_pkg::uvm_pkg::`, map 13's N0778, measured with `R11U212_PKGENUMALIAS_OFF`) |
| MiniAmiq d/t | file(77) | file(75) | queue |
| SeqDriver d/t | fullname(63) | fullname(61) | queue |
| SimpleUVM d/t | fullname(241) | fullname(236) | queue |
| Scoreboard d | fullname(193) | fullname(188) | queue; the alias law fires on uvm_pkg's copy and moves bytes (36 order-blind dump lines) but no strict count: golden names that object through the importing class (`work@my_scoreboard::uvm_pkg::`, N1424, the sister's ParamEmit), ours moved from bare to `uvm_pkg::uvm_pkg::`, still wrong, away 0 |
| Rggen d | file(4) | file(3) | sizeDimFile (#22375) |
| anon_struct_packed_dim d/t | fullname(43) | fullname(4) | anonMember (39 `gpte.pte_t.*` records) |

uhdm-cmp reads 0 lines on every moved row (each stays judge-equal: STRICT_NOTEQUAL before and after).
Canaries: `r11u107repro/canaries.sh` surelog ok=45 changed=7 (the seven predicted UVM changes above) absent=0,
uhdm2rtlil ok=16 changed=0; `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` PASS (ok=58), uhdm2rtlil `EXPECT_UNKNOWN=6` PASS
(ok=2).

## 4. Movers, predicted by name before the law sweep

**Predictor** ([drivers/census.sh](drivers/census.sh)): the law binary with `R11U212_TRACE` over the 4087 probe cases
and both corpora in both modes, the corpus runs filtered by `^(?!(<the four fenced names>)$)` read fail-closed from
`$FENCED` (fenced hits 0 0 0 0); every trace line is written where the law's condition holds (in the model laws only
where the parent actually changes or a parentless alias is found). Frozen (`chmod 444`,
[evidence/census/predicted.txt](evidence/census/predicted.txt), md5 `25d42148`) before the law sweep: 20 row-modes /
cases (23 firings).

**Movers** (byteverify `SELFCHECK=1`: surelog 959 / 960 and uhdm2rtlil 1607 / 1608 flagged, path sets identical;
probe compared file by file): **surelog 10 databases** (BuildUVMPkg d/t, MiniAmiq d/t, Rggen d, Scoreboard d,
SeqDriver d/t, SimpleUVM d/t), **uhdm2rtlil 2** (anon_struct_packed_dim d/t), **probe 6** (the four conversions and
two changes): **exactly the predicted set**, except TypedefEnum d/t, predicted (the alias law fires) and unmoved,
because its `assign o = pkg::x;` onto `output pkg::b o` unparents the alias afterwards (§ contAssignLhsTsUnparented134,
the order the decode states). Downstream lane: 805 slang databases compared, 1 moves (anon_struct_packed_dim,
predicted), IDENTICAL in both sweeps. The two stamp laws fire on no corpus row, probe case or downstream lane.

**Pass switch:** the law binary under `R11U212_OFF=1` writes the pristine bytes on all 4087 probe databases (and a
byte-identical probe csv) and on 13 of the 14 predicted corpus databases; the 14th, Scoreboard d, is the known
storage-order coin (its sorted dump equals pristine's, 0 lines; 94 ordered lines, the svunit listing).

**Away-moved-record census** ([drivers/awayrows.py](drivers/awayrows.py), map 12's method, chain-keyed and flat;
[evidence/movers/away_census.txt](evidence/movers/away_census.txt)): 18 databases differ; **away 0 on every one,
toward 161** (BuildUVMPkg 7 per mode, MiniAmiq 11, SeqDriver 13, SimpleUVM 11, Scoreboard 9, Rggen 4, probe 14 / 30 /
20). Positive control (the two sweeps swapped): **away 161**. The census is blind to a full name inside a typespec copy
(the record carries the canonical `<in>` name): anon_struct_packed_dim and the three anonymous-member probe cases read
0 / 0 there; their witness is the strict count (fullname(43) -> (4); three conversions) and the grid (51 conversions,
none leaving EQUAL).

**UVM order-blind distance** ([drivers/uvmdist.sh](drivers/uvmdist.sh), ours-not-in-golden `dist` and the symmetric
`sym`; [evidence/uvmdist.txt](evidence/uvmdist.txt)), base -> law: MiniAmiq 6539 -> 6528 (sym 14802 -> 14780),
SeqDriver 5084 -> 5071 (10954 -> 10928), SimpleUVM 1994 -> 1983 (3834 -> 3812), Scoreboard 1462 -> 1453 (2847 ->
2829), BuildUVMPkg 720 -> 713 (1385 -> 1371). (Pass 209's figures 6608 / 5163 / 2051 / 1508 / 757 were measured at
its own base; these are re-measured at b69dc2da.)

**Determinism** ([drivers/det.sh](drivers/det.sh), three concurrent runs per binary per row-mode;
evidence/det_law.txt, det_pris.txt): Earlgrey_0_1 one hash per mode in both binaries (the sweep's); SeqDriver,
SimpleUVM, BuildUVMPkg one hash per mode (the sweep's); MiniAmiq d/t and Scoreboard d draw two hashes in BOTH binaries,
each pair order-blind identical (sorted dumps 0 lines after the file-name line): the known storage-order coin. No new
coin.

**Downstream faces** ([drivers/dsfaces.py](drivers/dsfaces.py), the gate's own `one()`, fresh `GOLDEN_CACHE`, both
binaries; evidence/downstream/): 272 cases (map 13's 197 existing face cases + its 6 extras + this directory's 69
single-file cases): **pristine 227 IDENTICAL / 22 EQUIVALENT / 16 DIVERGENT / 6 STATUS_DIFF / 1 SLANG_REJECT, law the
same, row for row (0 verdict changes).** Map 13's two scratch copies under /tmp/r11u211_dscases no longer exist.

## 5. Residues and faces, ranked (the targeted rows first)

1. **anon_struct_packed_dim d/t `fullname(4)`** (was 43): the four left are the sister's: the ref_obj `gx` in
   `tq[gi].is_page[2-gx][0:0]` in the elaborated `g_i[*].g_x[*]` scopes, golden named through the path chain
   (`...tq[gi].is_page[2 - gx][0:0].is_page.gx`), ours scoped (`...g_x[1].gx`): ExprEmit's select-index naming, the
   § elabIfArrIdxChainName205 / § genConnTrailSelChain205 family. With it the row converts d/t.
2. **InterfArrayBind d `fullname(3)`**: all three records are ExprEmit's (#166 / #177 the § elabIfArrIdxChainName205
   face; #183 `peripheral_io_bus[IO_ONES].write_en` at module scope). Decoded here: by emitContAssigns' branch conditions the elaborated cont_assign
   is re-emitted (a literal right side onto an interface-array member target never takes the shared-slot branch), not
   the shared definition object the brief assumed; golden's elaborated index ref_obj stores no full name (chain
   `work@soc_tb.peripheral_io_bus[IO_ONES].write_en.IO_ONES`), ours the scoped name written by ExprEmit's
   HierarchicalValue base-select branch. Nothing of this row is ModuleEmit's.
3. **Rggen d `file(3)`**: #23164 is a **Surelog defect**: NetlistElaboration.cpp `elab_ports_nets_` keeps a
   `TypespecCache tscache` keyed by `NodeId` ALONE across FileContents, so the modport io_decl `address` of the
   `rggen_bus_if` instance reached through `u_adapter_common`'s port takes the typespec compiled for
   rggen_adapter_common.sv 43 (the function formal `logic [ADDRESS_WIDTH-1:0] address`, an unfolded operation) where
   the interface's own declaration is rggen_bus_if.sv 9 (walk diverged: `operation` vs `constant`). Modelling it
   means reproducing Surelog's node numbering; no law.
4. **BuildUVMPkg d/t `col(51)`**: the first record is now #26067 (a ref_obj column, ground A); the remaining records
   are mostly ground A (17 ref_obj and 10 bit_select full names, a var_select, an assignment span, string constant
   end lines) plus the class_typespec spans and `this_type` / callback typedef full names (`uvm_pkg::uvm_callbacks::`
   vs ours `uvm_callbacks::`) and the enum_typespec line of `uvm_active_passive_enum` / `uvm_tlm_phase_e` located at a
   formal (#64384, #64777: the formal writer-order family, item 7).
5. **The UVM rows' importing-context family** (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard): the enum-alias side is
   now modelled for a package WITHOUT an importer (N0778); where golden names the copy through an importing module or
   class (N0582 N0900 N1424) the parent is ParamEmit emitPackage's to set (the sister). Contract: once that parent is
   set, § pkgEnumAliasListingParent212 no longer fires (it touches only a parentless copy).
6. **Earlgrey_0_1 d/t `endcol(45)`**: its first ten records at the base are all ground A: eight `constant` spans
   stopping at a package qualifier (`dm::Data0` dm_csrs.sv 91:52-56 golden, -61 ours; 92; dm_mem.sv 64-66
   `dm::HaltAddress`), two part_select definition names / ref_obj columns in dm_csrs 362 / 417 (`dmi_req_i.addr[...]`).
7. **Not attempted**: the scalar / enum typedef formal writer order (MiniAmiq #899, BuildUVMPkg #3245; grid EA e01
   e06 e07 reproduce it at stage 1), the svaunit class-method clone names (MiniAmiq 86, SeqDriver 89), the macro-argument
   method-call spans, the class param_assign copies in importPaCopy82, the header-without-parentheses initializer,
   the ref_var return, ibex_tracer (its 579 records split into ExprEmit ref_obj names, 194, and `::` vs `.` parameter
   typespec names), OutputSize, cfg_func_width_loop, struct_param_func_config, HierPathTypespec d.
8. **Downstream faces of map 13 section 7b** (re-measured, both binaries): q08 DIVERGENT (decoded: golden folds
   `$high(a)` in each generate-scope cont_assign to `UINT:4` size 64 located at the parameter's queried bound, 3:14-15;
   ours keeps the sys_func_call: ModuleEmit's generate-scope cont_assign emission, the `sysFold` of emitContAssigns is
   not reached there; not written), UD/u04 DIVERGENT, GV v07 v08 v09 v15 / PG p04 STATUS_DIFF, US/u01 STATUS_DIFF,
   us u02 u08 and sc c10 c12 EQUIVALENT, V191/rp2 (N7) DIVERGENT: unchanged. **c06 DIVERGENT**: the two stamp laws
   supply the `$signed` stamp golden writes, and the face is left with the inner size cast `7'(r)` inside
   `signed'(...)`: golden types that operation (vpiCastOp) with an integer_typespec at the width literal (6:33-34),
   ours with the net's logic_typespec, so the plugin sizes it to 1 bit: ExprEmit's cast emission (the sister; grid NS
   n04 carries it at stage 1).
9. **This pass's own residues**: the stamp binds the definition net's typespec where golden binds the elaborated
   net's (NS n01 n03 n05: one endcol record on a `signed` net); the elaborated net-declaration assignment's left side
   is a copy where golden lists the net (NS n02, n06); the anonymous union's elaborated member refs (SR s09); an
   anonymous struct's own span (s08 unpacked, s18 a port); a struct size dimension without an override reading the
   default's ref_typespec (SF f04); the interface-listed anonymous struct member ref in the elaborated view (s28_el,
   s32_el, s33_el); the package typedef in an anonymous struct in the elaborated view (s17_el).

## 6. Fence and process

* Every driver that reads corpus sources or databases reads the four fenced names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh and fails closed (env.sh, case.sh, census.sh with `^(?!(...)$)` and a fenced
  hit count of `0 0 0 0`, away.py, awayrows.py, dsfaces.py, det.sh, uvmdist.sh). The gate sweeps dispatched every row;
  no binary, gdb or script ran on a fenced test's sources or databases outside them; no fenced head was read. A grep of
  this directory for the four names reads 0.
* Builds `-j 2`; the pristine binary was frozen before the first edit; no source was edited while a unit compiled.
  Scratch `/tmp/r11u212_*` only (binaries `_bin`, sweeps `_sP` `_sQ`, the development sweep `_sD`, the census `_cen`,
  the OFF runs `_sO`, `_sA`, goldens `_g`, `_dsg`, downstream faces `_dsf`, determinism `_det`); worktree
  /tmp/wt_r11u212. Nothing under results/, tests/ (but the regenerated tests/LAWS.md) or third_party/ was written; no
  stash; `GOLDEN_DEFER` unset.

## 7. Files

* [cases/](cases): SR (42), EA (7), QM (10, q08 with its header), SF (6, two files each via `args`, f06 with a
  header), NS (10).
* [drivers/](drivers): env.sh, case.sh, grid.sh, census.sh, awayrows.py, away.py, uvmdist.sh, det.sh, dsfaces.py.
* [evidence/](evidence): grid/, census/ (the frozen predictor and firings), movers/ (byteverify, probe movers, away
  census and its reversed control), sweeps/ (the four sweep logs), gates/ (canaries), downstream/ (face verdicts and
  the case list), det_law.txt, det_pris.txt, uvmdist.txt.
