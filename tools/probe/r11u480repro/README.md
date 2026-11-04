# r11u480 — module/type ground, pass 480 (sv-tests campaign, fortieth pass on this ground)

Base ffae79ca (pass 478 on top of pass 485). Files touched: src/UhdmExporter.cpp, src/TaskFuncEmit.cpp
(and the regenerated tests/LAWS.md). No src/R*.h, no getenv, no header change; every law reads its
switch through src/LawSwitch.h (`lawOn(480, "R11U480_<LAW>_OFF")`), `R11U480_OFF` drops the whole
pass, `R11U480_TRACE=<dir>` logs each firing through `lawTrace(480, ...)`.

No sv-tests row is open on this ground (EQUAL 1937 at the base, the three DIFFERENT rows the known
exceptions p733, p737 and tnoc). This pass closes pass 478's three findings and works one backlog
family (pass 478's array-member residue: subroutine-local fixed-size arrays of a named struct, union
or enum).

## Binaries

| tag | md5 | what |
|---|---|---|
| pristine | c2b2989cd5535d93b46bfce45857e5bc | the main tree's build/slang-uhdm (copied, frozen); the worktree's first build at ffae79ca reproduced this md5 bit for bit |
| law1 | aa0743291be95dff5f723ce5af7231e2 | findings 1 and 2 only (used for the r11u478/v11u478 byte check) |
| law3 | ca935476c93bd4580c8beef2e2385789 | FINAL: findings + § fixArrLocalNamedAggElemTs480 with its import-clone abstention; links slang 12.0.0+545f88b2e |

(law2 had the element law without the import-clone abstention; it moved the home typedef's parent on
the VM cases, see below, and was replaced. It was never swept.)

## Pass 478's three findings

1. **§ aliasParamStoredRead480** (UhdmExporter, inside § aliasCopyParamUnnamed478; switch
   `R11U480_APSTORED_OFF`). UHDM's generated `parameter::VpiFullName()` computes the full name and
   STORES it when none is stored, and § aliasCopyParamUnnamed478 called it on every candidate before
   deciding to fire. The stored symbol is now read first through the explicit-instantiation probe
   r11u287 already uses (`storedParFullName480`, `Rob287<ParFull480, &UHDM::parameter::vpiFullName_>`);
   a candidate with no stored name is left alone (its computed chain name ends with the copy's name,
   so the law never fired on it) and logged. The verifier's apstored audit read every candidate as
   stored because it read the databases AFTER the getter had stored them; the trace shows the
   unstored candidates directly: uvm_param_vif_config_db has 332 of them (166 `this_t.UVM_ALL_ON`,
   166 `this_t.UVM_CHECK_FIELDS`), while § aliasCopyParamUnnamed478 still fires its 332 times on the
   row (evidence/row_param_vif_traces.txt; the row reads EQUAL on pristine and on law3).
   NOT byte-neutral, as the brief expected: 12 of 98 r11u478/v11u478 grid dirs move bytes
   (AP/ap01 to ap04, VQ/vq09 to vq15 and vq18), each with an IDENTICAL dump (only the header line
   naming the file differs), the same uhdm-cmp count, strict verdict and dump distance, each restored
   by `R11U480_APSTORED_OFF` alone (evidence/g478_pristine.txt, g478_law1.txt; driver
   drivers/g478md5.sh). The move is the symbol table's order: the names the getter stored are no
   longer registered at that point. Cases AS/as01 (vq09's shape) and AS/as02 (ap03's shape) carry the
   law's name: STRICT_EQUAL before and after, bytes moved, restored by the switch.
2. **The duplicated § cloneHierArrElemMember478 comment block** (24 lines, verbatim) is deleted from
   UhdmExporter's final287. A comment-only deletion (no token changes), checked with
   `diff <(git show ffae79ca:src/UhdmExporter.cpp) src/UhdmExporter.cpp`: the only removed lines besides finding 1's getter line are the
   24 comment lines.
3. **§ aliasFormalCopyPerClone478 is judged by the dump, not by the strict comparator.** The names
   that law writes (one copy of the alias-of-alias enum formal typespec per importing package object,
   named per package) are fields uhdm-strictcmp does not read inside a re-expanded typespec subtree
   (the identity-derived full name is left out of the record there), so uvm_param_vif_config_db reads
   STRICT_EQUAL with `R11U478_ALIASCOPY_OFF` too; the law is what writes golden's names and reference
   counts in the uhdm-dump (pass 478: 4 + 2 references for each of the three packages against
   pristine's sfr_test_pkg only). Any later check of that law must compare dumps.

## § fixArrLocalNamedAggElemTs480 (TaskFuncEmit; switch `R11U480_FIXARRAGG_OFF`)

LAW. A FIXED-SIZE unpacked array local of a task or function (the tf block-item fixed-array branch,
`§ declArrayElemKindIsDeclKind12` SITE 3) whose element is written as the NAME of a struct, union or
enum typedef (packed or unpacked, module, package, $unit, interface, program, class-scope or
imported) types its element on the typedef's own typespec: golden's array_typespec element and the
element variable's ref_typespec both reach `struct_typespec (op_t)` at the typedef's span (Surelog's
compileVariable hands the declaration's data type to CompileType, which resolves the name to the
typedef's typespec), where the vector branch minted a located `logic_typespec` (a `bit_typespec` for a
two-state enum) over the written name and listed it as an orphan of the design. The law takes the
shared typedef object (`sharedAliasTs`, the one makeQueueDynArrayVar already reaches for queues and
dynamic arrays) and never stamps it (the vpiInstance stamp of that branch skips it).
ABSTAINS in an import clone (`importCopyTsInst` or `pkgImportCloneEmit`): golden's deep clone hangs
a private copy of the struct off the clone's ref_typespec; taking the shared object there (law2)
let the clone's later fixups re-parent the HOME listing's typedef (VM/vm04 uhdm-cmp 94 -> 924 lines,
the head reached earlier at package u's op_t parented by module_inst top with instance t), so that
half is a residue (below). Also abstains on a packed dimension over the element (fa27), an anonymous
type (fa07), a typedef declared inside the subroutine (fa25, § 155's placeholder), class-scoped
`D::op_t` and `P#(8)::op_t` (fa22, fa23, § 11's placeholder): byte-identical there.

### Grid (cases/FA, 28 dirs; every case accepted by upstream slang, Surelog exit 0, ours exit 0 on every binary)

`drivers/grid.sh <tag>`; evidence/grid_pristine.txt, grid_law3.txt, grid_law3_off.txt (R11U480_OFF),
grid_law3_fixarragg_off.txt, grid_law3_apstored_off.txt. Tally over the 30 dirs of cases/ (FA + AS):
pristine STRICT_EQUAL 2, STRICT_NOTEQUAL 17, NOT_EQUAL 11; law3 STRICT_EQUAL 20, STRICT_NOTEQUAL 0,
NOT_EQUAL 10. R11U480_OFF gives pristine's bytes and exit code on 30 of 30; `R11U480_FIXARRAGG_OFF`
alone leaves exactly AS/as01, as02 moved, `R11U480_APSTORED_OFF` alone leaves exactly the 23 FA
movers moved.

| case (§ fixArrLocalNamedAggElemTs480) | shape | pristine | law3 |
|---|---|---|---|
| fa01 | module function, unpacked struct typedef | STRICT_NOTEQUAL type | STRICT_EQUAL 142 |
| fa02 | package function, package struct | STRICT_NOTEQUAL type | STRICT_EQUAL 268 |
| fa03 | packed struct | STRICT_NOTEQUAL type | STRICT_EQUAL 160 |
| fa04 | enum typedef (golden enum_typespec, ours bit_typespec) | STRICT_NOTEQUAL type | STRICT_EQUAL 94 |
| fa05 | unpacked union | STRICT_NOTEQUAL type | STRICT_EQUAL 124 |
| fa06 | packed union | STRICT_NOTEQUAL type | STRICT_EQUAL 160 |
| fa07 | anonymous struct (abstains) | NOT_EQUAL 80 | same bytes |
| fa08 | in-body class method, package struct | STRICT_NOTEQUAL type | STRICT_EQUAL 106 |
| fa09 | module task | STRICT_NOTEQUAL type | STRICT_EQUAL 113 |
| fa10 | alias of a struct typedef (older module-typedef alias face first) | NOT_EQUAL 17, dd 82 | NOT_EQUAL 17, dd 81 |
| fa11 | wildcard-imported struct | STRICT_NOTEQUAL type | STRICT_EQUAL 168 |
| fa12 | two-dimension array | STRICT_NOTEQUAL type | STRICT_EQUAL 160 |
| fa13 | scoped p::op_t | STRICT_NOTEQUAL type | STRICT_EQUAL 144 |
| fa14 | out-of-body class method, one importing module | STRICT_NOTEQUAL type | STRICT_EQUAL 263 |
| fa15 | class-scope typedef in its own method | STRICT_NOTEQUAL type | STRICT_EQUAL 67 |
| fa16 | package function called through an importing package (clone half abstains) | NOT_EQUAL 94, dd 608 | NOT_EQUAL 94, dd 586 |
| fa17 | $unit struct typedef | NOT_EQUAL 90 | STRICT_EQUAL 117 |
| fa18 | enum logic [1:0] | STRICT_NOTEQUAL type | STRICT_EQUAL 130 |
| fa19 | interface function | STRICT_NOTEQUAL type | STRICT_EQUAL 183 |
| fa20 | program function | NOT_EQUAL 1058, dd 77 | NOT_EQUAL 1058, dd 76 |
| fa21 | function in a generate block | NOT_EQUAL 29, dd 23 | NOT_EQUAL 29, dd 18 |
| fa22 | D::op_t (abstains) | NOT_EQUAL 86 | same bytes |
| fa23 | P#(8)::op_t (abstains) | NOT_EQUAL 86 | same bytes |
| fa24 | two instances of the declaring module | STRICT_NOTEQUAL type | STRICT_EQUAL 139 |
| fa25 | typedef declared in the function (abstains) | NOT_EQUAL 271 | same bytes |
| fa26 | alias of an enum typedef | NOT_EQUAL 52, dd 13 | NOT_EQUAL 52, dd 8 |
| fa27 | packed dimension over the element (abstains) | NOT_EQUAL 104 | same bytes |
| fa28 | two declarators and an initializer | STRICT_NOTEQUAL type | STRICT_EQUAL 260 |

(dd = path-normalized uhdm-dump lines differing from golden; dd 2 is the header line naming the file.)
No dump distance grows, no uhdm-cmp count grows. Downstream (scripts/downstream_uhdm2rtlil.py `one`,
both lanes): fa01, fa03, fa06, fa24, fa28 IDENTICAL on pristine and law3; fa18 DIVERGENT -> IDENTICAL.

### Prediction, census and away census

* Prediction, before the sweep, from the master's control databases (/tmp/intr11u478, our side,
  7475 databases after the fence filter) with evidence/tools/fanames.cpp (a tf-local fixed array_var
  whose element typespec is logic/bit and whose source token is a name, not a keyword; positive
  control fa01, fa04, fa14 flagged, fa01's law3 database not): hits only in the probe case
  r10uvm129repro/g129_d_bases (16 enum-typed arrays, STRICT_NOTEQUAL type(1)) and the sv-tests row
  generated/rsd/rsd.sv (SURELOG_CRASH, no golden; one enum array RefetchType fires, the
  CommitLaneIndexPath hits are vector typedefs the law does not take). evidence/fanames_prediction.txt.
  For § aliasParamStoredRead480 the shape (a class_typespec under a ref_typespec with a parameter
  Lhs) is absent from every kept control database (evidence/apstored_census.txt, the verifier's
  v11u478 tool, positive control vq09 with 8 candidates); the sv-tests stage keeps no EQUAL row's
  database, so its movers were named from pass 478's firing list: the trace names exactly one,
  uvm_param_vif_config_db (EQUAL before and after).
* The sweep's trace (evidence/sweep_trace.txt) fired in exactly the predicted processes:
  g129_d_bases 16 x fixArrLocalNamedAggElemTs480, rsd 1 x fixArrLocalNamedAggElemTs480,
  uvm_param_vif_config_db 332 x aliasParamStoredRead480.
* Away census (evidence/away_bytes.txt, away_movers_judged.txt): 1888 fence-filtered earlier case
  dirs under tools/probe/*/cases whose source holds a typedef, a function or task and an
  `<name> <name> [..]` declaration, both binaries, no exit code moving, 24 dirs moving bytes, every
  one toward golden: v11u458 VB/vb10 and r11u178 hp/h03_first_pkgfn STRICT_NOTEQUAL type ->
  STRICT_EQUAL, v11u478 VM/vm11 NOT_EQUAL 108 -> 17 uhdm-cmp lines, v11u412 VS/vs02 dd 25 -> 20 at
  the same verdict, and the other 20 (v11u478 VM/vm01, vm04, vm06, vm08, vm12 to vm14, vm16, vm17,
  r11u478 AM/am08, r11u296 CI/ci06, ci07, v11u259 VM/vm14_array_elem_member, v11u476 VP/vp29,
  v11u253 F/vf01_fixed_struct_elem, v11u241 AG/g10, g13, v11u265 VB/vb14_array_elem_root, r11u259
  M/m05_foreach_block, v11u450 VO/vo04) at the same verdict and uhdm-cmp count with the dump
  distance smaller (the home package's half fixed, the clone half the residue).

## The sweep (one, on law3; tests/sweep.sh --jobs 3, workdir /tmp/r11u480swp, same length as the control)

The first four stages from the worktree, the sv-tests stage through the main tree's tests/sweep.sh
(the worktree's UVM folder is empty; SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests), SLANG_UHDM the
frozen law3, R11U480_TRACE on. evidence/sweep_summary.txt.

* probe: EQUAL 4026, STRICT_NOTEQUAL 61 of 4087; regressions=0 conversions=1 changes=0 —
  **CONVERSION r10uvm129repro/g129_d_bases STRICT_NOTEQUAL differ:type(1) -> EQUAL**, fresh row
  `r10uvm129repro/g129_d_bases,EQUAL,,equal` (results/ untouched). Path-normalized dumps of all 4087
  databases against the control: only g129_d_bases differs (evidence/probe_dump_compare.txt).
* surelog: default CMP_EQUAL 480, testflags 474, STRICT_NOTEQUAL 0; regressions=0 conversions=0
  changes=0; the csv equal to the control's row for row except the two LowMem log-path texts.
* uhdm2rtlil: 803/1/67 in both modes; 0/0/0; csv equal to the control's.
* downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871; not identical and
  not excused 0; csv equal to the control's.
* sv-tests: EQUAL 1937, DIFFERENT 3, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=0 changes=0; csv equal to the
  control's. (The main tree's sweep.sh exits 1 on the main tree's own law-index check alone.)
* byteverify (SELFCHECK=1) law3 against the control: surelog 0 of 962, uhdm2rtlil 0 of 1608,
  downstream 0 of 805 (selfcheck 961/962, 1607/1608, 804/805 flagged). evidence/byteverify.txt.
* canaries: ok=52 (surelog csv) and ok=16 (uhdm2rtlil csv); ctcan2 PASS on both (ok=58 and ok=2).
* binary audit of cmds.txt (fence-filtered): surelog 1523 of 1573 name law3, the other 50 hold only
  a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.

Goal 1 re-checked: no SURELOG_ONLY row moved; every one of the 75 details is unchanged from the
control's csv (upstream slang diagnostics, per passes 406 to 478).

## Residues (ranked; all wrong on pristine too, none moved away)

1. The IMPORT-CLONE half of the fixed-array element: golden's clone listing holds a private
   struct_typespec copy parented at the clone's ref_typespec (instance the home package); ours keeps
   the logic_typespec there (v11u478 VM/vm01, vm04, vm08, vm11 to vm13, vm16, vm17, r11u478 AM/am08,
   FA/fa16). Writing it needs a per-clone copy made design-final (the § cloneAggLocalOwnCopy241
   walker), never the shared object.
2. The clone array_var parented at the begin where golden parents it at the function (the VM cases'
   next face, `\_begin: (a::C::f)` against `\_function: (a::C::f)`).
3. The alias-of-typedef element (fa10, fa26: the module typedef alias face first), the generate-block
   function (fa21) and the program function (fa20) at older heads; anonymous, class-scoped,
   subroutine-declared and packed-dimension elements (fa07, fa22, fa23, fa25, fa27) abstain.
4. Carried from pass 478: the alias-copy law's per-formal copies (VF/vf06) and three-level chain
   (vf02); pass 476's vp06 provider order finding; the interface-instance shapes iu14/vi15, vi16,
   vi01; AP/ap01, ap02, ap04, ap05; and the carried lists of passes 476 and earlier.

## Sister-ground faces (reported, not written)

* StmtEmit's § 175 design-final begin copies running after the provider binding is read (repaired
  from this ground by § providerBodyCopyBind478), as pass 478 reported.
* The block-item (StmtEmit) twin of this pass's law: a fixed array of a named struct declared in a
  begin block inside a subroutine is typed by StmtEmit's block-item branch, not measured here.

## Process

One full sweep on the final binary; byteverify once against the master's control; no pristine build
or sweep (the pristine reading is /tmp/intr11u478). The fence list was read into a file by a program
and every tree-wide list was filtered on it before any file was opened; the repro folder scans
clean. No other agent's process was touched. The sister r11u487's wait loops were live during the
sweep; no sweep of theirs ran at the same time.

## Drivers

* drivers/runcase.sh <bin> <tag> <casedir>... (Surelog golden with check_probe.py's flags, cached
  under /tmp/r11u480_runs/<full path>; prints exit codes, uhdm-cmp lines, strict verdict, dump
  distance, md5).
* drivers/grid.sh <tag> [VAR=val...] — every case dir of this repro.
* drivers/g478md5.sh <tagA> <tagB> [VAR=val...] — the byte check on the r11u478/v11u478 grids.
* evidence/tools/fanames.cpp — the prediction scan (built against ~/.local's UHDM: g++ -std=c++17
  -I$HOME/.local/include fanames.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread).
