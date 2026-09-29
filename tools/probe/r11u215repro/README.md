# r11u215 — the expression/parameter ground: a package alias typedef's ref is named by its LAST WRITER (§ pkgTdAliasLastWriter215, with its plain-enum import-clone twin § pkgImportEnumCloneLastWriter215: the importing-context prefix family N0540 / N0582 / N0689 / N0900 / N1424 and the TypeEmit twin N0778, decoded as ONE rule), the first imported copy of a struct-pattern parameter keeps its fresh unparented pattern ref (§ impPatCopyFirstListingUnparented215, refined by § impPatMemberReadKeepsParent215v: ibex_tracer's last 13 records), an inc/dec operand keeps its lvalue form in every position (§ incDecOperandKeepsLvalueForm215), a deep receiver's operation index follows the path (§ opIdxRecvElemFollowsPath215, § opIdxRecvPlainElab215), the F1 gate of r11u210's second check (§ caseItemWildConcatOnly215) and R11V198_OFF's reach (§ landingSwitchReach215); ibex_tracer d/t CONVERT, 12 probe cases convert, 0 regressions

**Base.** `a727b8c7` (branch matrix-1.87, pass 210 landed). Worktree `/tmp/wt_r11u215`, system-deps config. Ground A
only: `src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h`. No file of the sister's ground
(TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main, include/UhdmExporter.h) is touched; nothing under
`results/`, `tests/` (but the regenerated `tests/LAWS.md`) or `third_party/` is edited. A probe case is called a case.

**r11u214.** No `tools/probe/r11u214dec` had landed and no `/tmp/r11u214.patch` existed when this pass started or
delivered; the live decode's worktree holds case grids only (no README, no `law_exprstmt.patch`), so item (0) did not
apply and item (1) was decoded here from Surelog's writer (section 3.1). r11u214's live run measures the same
`UVM_SEQ_ARB_TYPE` family from the ground-B side: the integration must compose the two (this pass's stamp is
design-final in ParamEmit and renames only refs whose stored name ends with the typedef's `<pkg>::<name>`, or that store
none).

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`
in the main repository (resolved through git's common dir) and every driver fails closed on it: `case.sh`, `judge.sh`,
`grid.sh`, `switchcheck.sh`, `refcheck.sh`, `reach198.sh`, `ctlmove.sh`, `det.sh`, `detob.sh`, `uvmdist.sh`,
`awaycorp.sh`, `awayrows.py`, `dscase.py` refuse a fenced name; `census.sh` runs the corpora and the downstream lanes
with a `--filter` built from the fence; `bvmirror.sh` leaves the 8 fenced row-mode databases out of every byte
comparison (`fenced_skipped=8`); the byte-control list (13034 case dirs) holds 0 fenced paths. The gate sweeps
dispatched every row; their csv verdicts are the only fenced facts cited (all unchanged). No fenced source, database or
head was read, run or decoded; gdb ran once, on a scratch case of this pass (no breakpoint was hit), never on a fenced source.

## 0. Verdicts

| row-mode | base (`a727b8c7`) | after | laws |
|---|---|---|---|
| **ibex_tracer d (uhdm2rtlil)** | `differ:fullname(13)` | **`CMP_EQUAL`** | § impPatCopyFirstListingUnparented215 (13 records: pass 210's R1) |
| **ibex_tracer t (uhdm2rtlil)** | `differ:fullname(13)` | **`CMP_EQUAL`** | the same |
| SeqDriver d / t | `differ:fullname(63)` | `differ:endline(61)` | first record `#10090` (N0540, `uvm_pkg::uvm_event_pool` alias ref, golden `work@top_tb.uvm_pkg::`) cleared by § pkgTdAliasLastWriter215; the next head is the macro method-call span (sister, section 7) |
| MiniAmiq d / t | `differ:file(77)` | `differ:file(75)` | N0540 `#10107` and the N0582 family cleared; first record `#899` (the `uvm_severity` typedef relocation, sister) unchanged |
| SimpleUVM d / t | `differ:fullname(241)` | `differ:fullname(190)` | 51 records (alias refs, the operation-index and inc/dec receiver faces); first record `#458` (`UVM_MACRO_NUMFLAGS`, sister) unchanged |
| Scoreboard d | `differ:fullname(193)` | `differ:fullname(136)` | 57 records, the same laws; first record `#466` unchanged |
| BuildUVMPkg d / t | `differ:endcol(57)` | `differ:endcol(33)` | 24 records: N0778 `#25472` (`uvm_pkg::uvm_pkg::UVM_SEQ_ARB_TYPE`, the TypeEmit twin) and the `fields[fld_idx-1].get_lsb_pos()` / `sequence_ptr.m_next_transaction_id++` families; first record `#22884` (a `typespec_member args` span, sister) unchanged |
| BlackBePipeInt d / t | `differ:type(1)` / `differ:depth(1)` | the same | bytes only: 21 records toward golden behind the structural first record (the chain census, section 6) |
| **12 probe cases** | `STRICT_NOTEQUAL` | **`EQUAL`** | § pkgTdAliasLastWriter215 ×11, § pkgImportEnumCloneLastWriter215 ×1 (section 5) |

**CONVERSIONS (loud).** The fresh rows of the law sweep `/tmp/r11u215_swL` (NOT written to `results/`):

    ibex_tracer,default,CMP_EQUAL,,,equal
    ibex_tracer,testflags,CMP_EQUAL,,,equal
    r10uvm202repro/g202_e_head,EQUAL,,equal
    r10uvm206repro/g206_b_dedup,EQUAL,,equal
    r10uvm49repro/a3,EQUAL,,equal
    r10uvm49repro/a4,EQUAL,,equal
    r10uvm49repro/a5,EQUAL,,equal
    r10uvm49repro/a6,EQUAL,,equal
    r10uvm50repro/a1,EQUAL,,equal
    r10uvm50repro/a7,EQUAL,,equal
    r10v136repro/v136_g_param,EQUAL,,equal
    r10v202repro/v202_6_twotd,EQUAL,,equal
    r10v206repro/v206_d_selfname,EQUAL,,equal
    r11u111repro/grid/f5/e08_explicit_import,EQUAL,,equal

Totals against the committed baselines: probe `regressions=0 conversions=12 changes=1` (EQUAL 3406 -> 3418,
STRICT_NOTEQUAL 681 -> 669; the change `r10uvm202repro/g202_a_kinds fullname(6) -> fullname(4)`); surelog
`regressions=0 conversions=0 changes=9` (all nine shrink or move their first field later, section 5; CMP_EQUAL 929 +
STRICT_NOTEQUAL 25 unchanged); uhdm2rtlil `regressions=0 conversions=2 changes=0` (1596 + 10 -> **1598 + 8**);
downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT with `downstream.csv` byte-identical to the
pristine sweep's.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u215_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `11b349f41c8453bbb85b792816e5e5a1` | the worktree's build at `a727b8c7`: **byte-identical to the main tree's `build/slang-uhdm`** |
| `law1` .. `law25` | | development steps (section 3 names the drafts the refinements came from; `law23` -> `law26`: the candidate order, the stored-name probe and the syntax scan of section 6's determinism note; every grid database and every corpus mover's hash is the same on both, the storage-order coin rows aside) |
| **`law26.bin`** | **`6a021c3c045bbe47c20a827e9bbf41c9`** | **THE DELIVERED SOURCES**: ran the firing census, the law sweep, the grids, the switch checks, the byte controls and the determinism runs |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

`cmds.txt` audit: the pristine sweep `/tmp/r11u215_swP` 3273 of 3273 `slang:` lines name `/tmp/r11u215_bin/pris.bin`,
the law sweep `/tmp/r11u215_swL` 3273 of 3273 `/tmp/r11u215_bin/law26.bin` ([evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt)).

## 2. Switches (every law droppable alone; `R11U215_OFF=1` restores the pristine bytes on every case)

| switch | law | file | grid |
|---|---|---|---|
| `R11U215_TDALIAS_OFF` | § pkgTdAliasLastWriter215 | ParamEmit.cpp (`pkgTdAliasLastWriter215`, called from `drainPaNameCopySrc38`) + EmitHelpers.h (`r11u215On`, `trace215`) | cases/A |
| `R11U215_ENUMCLONE_OFF` | § pkgImportEnumCloneLastWriter215 | ParamEmit.cpp (the same stamp's candidate scan) | cases/A a07 a08 a18 |
| `R11U215_IMPPATFIRST_OFF` | § impPatCopyFirstListingUnparented215 | ParamEmit.cpp (`impPatCopyFirstListing215`, called from `drainPaNameCopySrc38`) | cases/I |
| `R11V215_MEMBERREAD_OFF` | § impPatMemberReadKeepsParent215v (refines the law above; dropping it re-opens the break) | ParamEmit.cpp (`memberReadNames215`, a syntax scan) | cases/I i13-i18 |
| `R11U215_INCDECROUTE_OFF` | § incDecOperandKeepsLvalueForm215 | ExprEmit.cpp (the member-path hier_path builder, beside § hpSelRoute157) | cases/D |
| `R11U215_OPIDXRECV_OFF` | § opIdxRecvElemFollowsPath215 (and the sub-law below) | ExprEmit.cpp (§ deepRecvCall11's expression branch) | cases/R |
| `R11U215_OPIDXRECVELAB_OFF` | § opIdxRecvPlainElab215 | ExprEmit.cpp (the same branch) | cases/R r01, r06, r07 (`--elabuhdm`) |
| `R11U215_CASEWILDCAT_OFF` | § caseItemWildConcatOnly215 | StmtEmit.cpp (§ caseItemImpWildParamScopeName210's gate) | cases/C |
| `R11V198_OFF` (new meaning: it was read nowhere) | § landingSwitchReach215 | ExprEmit.cpp (`vsStampReducedCtxOnly198v`) | section 8 |

`R11U215_TRACE=<dir>` (one file per process, `<pid>.T215`, first line `OUT <-o path>`, then one `<law> <detail>` line
per firing; lines starting `diag` are diagnostics — a candidate seen, a writer computed, a refinement's skip — and are
not firings): the census's input. **Switch checks** ([evidence/switchcheck.txt](evidence/switchcheck.txt),
`drivers/switchcheck.sh law26.bin <every grid case>`, both views, 113 lines): every case-view where one law fires is
RESTORED to the pristine bytes by that law's switch alone (80 of 80); on the 14 mixed case-views (a07, a08, a18: the
alias and the clone law; r01 `--elabuhdm`: the two receiver laws) each switch alone DROPS its own records; the 19 case-
views with no firing are byte-identical to pristine; **`R11U215_OFF=1` writes the pristine bytes on all 113**.
The refinement ([evidence/refcheck.txt](evidence/refcheck.txt), `drivers/refcheck.sh`): on i13-i15 and i18
`R11V215_MEMBERREAD_OFF` writes the unrefined law's bytes (they differ from the refined ones); on i16 the unrefined law
did not move a byte either; i17 (no member read) never skips.

## 3. The laws

Every grid case is judged against a real pinned Surelog v1.87 golden in two forms: the probe form (`-parse -nobuiltin
-nocache -sv` against `--single-unit --nobuiltin`) and the `-elabuhdm` form (`ELAB=1`, `--elabuhdm` on our side). Each
case names its law on its first line. The whole grid: **53 case dirs, both views: 28 / 28 convert, 3 / 4 shrink, 22 /
21 keep their verdict (stage-1 controls and EQUAL controls), 0 worse** ([evidence/grid/](evidence/grid/)).

### 3.1 § pkgTdAliasLastWriter215 (`R11U215_TDALIAS_OFF`) and § pkgImportEnumCloneLastWriter215 (`R11U215_ENUMCLONE_OFF`) — the importing-context prefix family as ONE decode

**Faces.** Map 13's N0540 (MiniAmiq, SeqDriver: `ref_typespec` of the class typedef `uvm_pkg::uvm_event_pool`, golden
`work@svaunit_vpi_interface.uvm_pkg::uvm_event_pool` / `work@top_tb.uvm_pkg::...`, ours bare), N0582 / N0900 / N1424
(the enum alias `UVM_SEQ_ARB_TYPE`: golden `work@svaunit_vpi_interface.`, `work@env::`, `work@my_scoreboard::`), N0689
(the class typedef in SimpleUVM / Scoreboard) and the TypeEmit twin N0778 (BuildUVMPkg: golden
`uvm_pkg::uvm_pkg::UVM_SEQ_ARB_TYPE`, ours bare).

**Decode.** The ref is the `Typedef_alias` (and, for an enum, the `Base_typespec`) of the ONE shared typedef object
Surelog makes for a package typedef that aliases another typedef (CompileHelper::compileTypeDef's `tpclone`,
CompileHelper.cpp; CompileType.cpp's use-site lookup returns `parent_tpd->getTypespec()`, the same object). UHDM's
generated `VpiFullName()` getter caches `BaseClass::ComputeFullName()` on first read (UHDM `scripts/classes.py`, the
vpiFullName getter) and the serializer reads it at save (`Serializer_save.cpp`), so the name is ComputeFullName over
the object's FINAL `vpiParent`. `UhdmWriter::writeDataTypes(setParent)` re-parents every DataTypeMap entry at its
writer, and `UhdmWriter::write` (UhdmWriter.cpp) runs the writers in a fixed order: the `$unit` file contents (parent
the design: no prefix), the packages in compile order (`getOrderedPackageDefinitions`; the home package and every
package whose map received the typedef through `importPackage`, transitively; an explicit import only for the item it
names, § enumImpNamedItemWrites190v's decode), then the programs, interfaces and modules each in definition-NAME order
(a module-local class right after its module: measured, decode grid t13), and last the `$unit` classes in class-
NAME order (the top-level class loop; `CompileClass` imports the `$unit` import items of its own FILE only). The last
writer names the ref: `<pkg>::<home>::T` (package, column join), `work@<def>.<home>::T` (program, interface, module),
`work@<mod>::<cls>::<home>::T` (module-local class), `work@<cls>::<home>::T` (`$unit` class). A PLAIN enum typedef has
two objects: the home package's own (`<home>::<home>::e_t`) and the one `importPackage` hands every importer (its
last importing writer's name).

**Grid of the decode** ([evidence/decode/](evidence/decode/): `gen_alias_grid.py`'s 88 shapes and 13 hand-written
ones in `shapes/`, their golden and ours alias names per binary in `decode_grid.txt`; the alias kind {enum alias, class specialization} x the use {none,
class method formal, package function formal, class property} x the context {no importer, module, interface,
interface + module, program, `$unit` class, `$unit` import + module, importing package, a class in an importing
package, module + importing package}, and t1-t16: transitivity, name versus source order, other files, explicit items,
header imports, module-local classes): golden reads ONE name per shape, always the last writer of the order above;
ours was bare (no importer, interface, program, packages, classes), the package's own `p::p::` for every class alias,
and right only for a module importer (§ enumImportParentLastWriter180's drain).

**Laws.** Design-final (the stamp runs first thing in `drainPaNameCopySrc38`: after every emitter and every typedef
clone pass, `pkgImportCloneLastWriter32` included, before § enumImportParentLastWriter180's drain and the parent
model): every `enum_typespec` / `class_typespec` object named `<P>::<T>` with a `Typedef_alias` ref, where P is a
package and T an alias typedef of P (an enum whose target is a typedef, or a class specialization), gets the last
writer's name on its alias ref and, for an enum, its base ref, when the ref's STORED name ends with `<P>::<T>` or it
stores none (a computed name ends with it too; the name is read through `r215StoredFullName`, never computed)
(§ pkgTdAliasLastWriter215); a plain enum object an importing package lists (not its home) with a still-bare base ref
gets the same name (§ pkgImportEnumCloneLastWriter215). A typedef an elaborated continuous assignment's left side is
typed by is skipped (golden unparents it in `writeCont_assign`: uhdm2rtlil TypedefEnum `output pkg::b o`, which the
first draft moved to `pkg::pkg::b`; the same key and LHS binding as `typedefParentModel134`'s caUnparent half).
**Grid** (cases/A, both views): a01 (no importer), a02 (an interface), a03, a04 (two modules: the name-last), a07 (two
importing packages), a09 (a module importing only the re-exporter), a14 (header import), a15 (a `$unit` class without an
import), a16 (a class typedef declared in a class), a17 (the typedefs in an included file), a18 (the plain-enum clone)
`fullname(3..25)` -> **EQUAL**; a06 (`$unit` class after a module) `fullname(34)` -> `fullname(31)` and a12 (module-local
class) `fullname(22)` -> `fullname(19)`: every class alias right, the enum aliases left to the sister's drain (section
7); a13 (the continuous-assignment control) EQUAL on both, bytes unchanged; a05, a08, a10, a11 stage 1 on both (the
program listing, the re-exporting package listing, the explicit-item module listing: pre-existing structures), bytes
move. **Corpus**: fires on MiniAmiq (33), SeqDriver (30), SimpleUVM (30), Scoreboard (30), BuildUVMPkg (2) and
BlackBePipeInt (2) per mode; 11 probe conversions and the clone law's 1.

### 3.2 § impPatCopyFirstListingUnparented215 (`R11U215_IMPPATFIRST_OFF`) and § impPatMemberReadKeepsParent215v (`R11V215_MEMBERREAD_OFF`) — pass 210's R1

**Face.** ibex_tracer d/t's last 13 records: the module listing's import copy of a struct-pattern parameter, its
pattern operation's ref_typespec: golden no parent (full name empty), ours parented at the operation (`work@ibex_tracer`).

**Decode** (grid cases/I; pass 210's P/p01 and p05). In an ELABORATED module instance's listing the parameters a module
imports are copied per import item (`vpiImported` names the item's package), so a parameter reached through two items
is listed twice. Golden's FIRST copy of a name is minted fresh (expandPatternAssignment: the op's ref has no parent)
and every LATER copy is a clone (clone_tree parents the ref at the op): i01 (`import hp::*; import ip::*;`, ip
re-exporting hp) unparented / parented, i02 (the reverse order) the same BY POSITION, i04 (ibex_tracer's shape, only
ip) unparented, i06 one instance down. Pass 210 read "direct import unparented, transitive parented" (ours); the
distinguisher is the position. **Law.** Design-final over every elaborated module instance (top and nested, through
generate scopes): the first imported copy of a name whose right side is an assignment-pattern operation with a typespec
ref leaves the ref unparented (and nameless), a later one parents it at the operation (named by the instance), for a
**packed struct** pattern only, and not for a name the scope declares itself. **Refinements found by the gates**
(each before delivery): an unpacked struct or an array pattern stays parented at every listing (probe r11u60repro/g4,
r11u61repro/h1, r11u10repro/grid/h9_1e1m_port and hD_1e1mvec regressed on the first draft); a module parameter of the
same name (`#(parameter cfg_t Cfg = cfg_pkg::Cfg)` beside `import cfg_pkg::*`: Surelog updates the copy by name, a
clone) stays parented (uhdm2rtlil ff_dead_both_branches, ff_dead_guarded_reset regressed); **§ impPatMemberReadKeepsParent215v**:
a parameter some expression reads by a MEMBER SELECT (`EA.b`) is expanded where it is read and every listing of it is a
clone (golden parented): i13 (the re-exporting package reads it in a parameter), i14 (in a function), i15 (the home
package), i16 (the module); an unread sibling (EB) or a whole-value read (i17 `EC = EA`) keeps the fresh first copy;
the byte controls' chain census caught it (v11u210repro/cases/P/vp06 moved one record away on law20). The read set
comes from a SYNTAX scan of every tree (a `.`-scoped name or a member access whose left side names the parameter,
`pkg::`-qualified or not): a name, so a struct variable of the same name also declines. (The first version walked the
slang AST; it forced slang to elaborate bodies it had not, and the determinism runs drew a storage-only second hash on
SeqDriver testflags with it: section 6.)
**Grid** (cases/I, both views): i01, i02, i04, i05, i06, i08, i09, i10 `fullname(1..4)` -> **EQUAL**; i03 (only the
home import) and i12 (a nested pattern: no outer typespec) EQUAL on both; i07 (unpacked and array controls) and i11
(an interface's listing) stage 1 on both, bytes unchanged; i13-i18 stage 1 on both (the member-select read is a
pre-existing stage-1 face), the refinement measured by bytes (section 2) and by the op-ref parent table
(`drivers/opts.py`: law <= pristine on all six). Pass 210's P/p01, p05 convert (byte controls, section 6).

### 3.3 § incDecOperandKeepsLvalueForm215 (`R11U215_INCDECROUTE_OFF`)

**Face.** BuildUVMPkg `param_t.set_transaction_id(sequence_ptr.m_next_transaction_id++)` (uvm_pkg.sv:54011): golden
`ref_obj sequence_ptr` at the member token 47-68 and the leaf's full name empty; ours at its own token 34-46 and the
leaf scope-named. **Decode.** § incDecMemberPathIsLvalue124 already names this: Surelog compiles an inc/dec operand
through its Variable_lvalue branch whatever the position. § hpSelRoute157's grammar route re-decided the path from the
positions ABOVE the operation (a subroutine argument: CFC) whenever the operation was already parented when its operand
was built (a prefix operator; any operator inside a method call's argument list); a postfix operator in a plain call
kept the lvalue form. **Law.** The direct operand of a pre/post increment or decrement (not `this.`, not a
package-qualified base) takes the lvalue form (base at the first member's token, leaf name-only) and the route is not
consulted; the index of an assignment target (`arr[s.n++] = 1;`, where `inLhs` is up) included. **Grid** (cases/D,
both views): d01 (a method call's argument, postfix ++ / --), d02 (prefix and postfix in a plain call), d04 (a
select index on both sides of an assignment and a ternary branch), d06 (a two-level path; a module's struct variable in an
`always_comb` call), d07 (a task call and a module's call of a class method) `col(2..10)` -> **EQUAL**; d03 (system
calls), d05 (right sides, conditions, returns), d08 (`this.` and plain-variable controls) EQUAL on both, bytes
unchanged. **Corpus**: 2-4 firings per UVM row.

### 3.4 § opIdxRecvElemFollowsPath215 (`R11U215_OPIDXRECV_OFF`) and § opIdxRecvPlainElab215 (`R11U215_OPIDXRECVELAB_OFF`)

**Face.** BuildUVMPkg (uvm_reg_field::is_indv_accessible, uvm_reg::add_field) and the four uvm-1.2 rows:
`fields[fld_idx-1].get_lsb_pos()`: golden's bit_select full name `fields[fld_idx - 1]` and its index reference
`uvm_pkg::uvm_reg_field::is_indv_accessible::fields[fld_idx - 1].get_lsb_pos::fld_idx`; ours `fields[fld_idx-1]` and
`...::is_indv_accessible::fld_idx`. **Decode.** CompileHelper::compileComplexFuncCall's select branch
(CompileExpression.cpp, the `the_name += "[" + decompileHelper(index) + "]"` block, the index compiled with
`Reduce::No`) names the element through the decompiled index, and the
operation index hangs at the HIER_PATH, its references storing no full name, so ComputeFullName walks ref -> op ->
hier_path (`fields[fld_idx - 1].get_lsb_pos`) -> ... -> the scope. § dottedIdxRecvFromSyntax23 applies exactly this to a
DOTTED index; § hpIdxOpPrettyPrint92 already writes the decompiled text into the path's own name. **Law.** In
§ deepRecvCall11's expression branch, an element whose index is an operation (§ hpIdxOpPrettyPrint92's rebuild fired)
takes the written path through the element with every operation index decompiled as its full name (`one.fields[i -
1]`), the operation is parented at the hier_path, and every reference under it (through nested operations and call
arguments) whose stored name is the scope-joined one takes `joinRef(joinRef(prefix, <path name>), <name>)`.
**§ opIdxRecvPlainElab215**: in the `--elabuhdm` view golden names a PLAIN reference index through the path too
(`p::reg_c::f::fields[k].get_lsb_pos::k`) — held to a package CLASS METHOD outside a module definition listing (r06: a
module function's and an `always` block's plain index keep `work@m.f.i` in golden's definition listing and take the
chain in the instance copy, which is not re-emitted here; r07 / r10uvm39repro/t55b: a package FREE function's clone
keeps the scope's name, which the first draft renamed — the byte controls' chain census). **Grid** (cases/R, both
views): r01 (BuildUVMPkg's shape), r02 (a module function and an `always` block), r04 (two-level receivers), r05 (a
parenthesis-less call and a statement call) `fullname(2..10)` -> **EQUAL**; r03 (nested operations, a call, a built-in
`size()` and a parameter in the index) `fullname(11)` -> `endcol(1)` (left: the call-in-index span, section 7); r06
EQUAL parse (no firing), `--elabuhdm` `fullname(3)` -> `fullname(2)`; r07 stage 1 on both.
**Corpus**: 18-36 firings per UVM row.

### 3.5 § caseItemWildConcatOnly215 (`R11U215_CASEWILDCAT_OFF`; the r11u210 verifier's F1)

§ caseItemImpWildParamScopeName210 renamed the kept case-item reference of an imported parameter whose value has
unknown bits; the verifier found golden keeps a REFERENCE only for a concatenation-bearing initializer and substitutes
a constant for a plain wildcard literal (v11u210repro vc09). **Law.** The rename is gated on § imppCopyOpReadIsRef114's
`concatBearing114`. **Grid** (cases/C, both views): c01 (`4'b??11` beside `{4'b01??, 4'h3}`), c02 (hex, x and z digits
in a function's `casez` and a `casex`): stage 1 on both binaries (golden substitutes constants for all of them; our
kept references are the pre-existing face), bytes move: the plain literals' references keep their package names
(`tp::W2`), the concatenation's keeps the scope name. Inert on every judged status, as the verifier said; it only
narrows the law to golden's predicate. Fires on no corpus row or probe case.

### 3.6 § landingSwitchReach215 (section 8)

## 4. The gates (`tests/sweep.sh --jobs 3`, all four stages, against the committed baselines at `a727b8c7`)

| gate | pristine (`/tmp/r11u215_swP`, `pris.bin`) | **law (`/tmp/r11u215_swL`, `law26.bin`)** |
|---|---|---|
| (1) build | = the main tree's build (`11b349f4...`) | `a727b8c7` + this patch (`6a021c3c...`) |
| (2) probe vs golden_probe.csv | EQUAL 3406 / 681, `regressions=0 conversions=0 changes=0` | **EQUAL 3418 / 669: `regressions=0 conversions=12 changes=1`**; 13 of 4087 probe databases move (the 13 predicted) |
| (3) surelog vs golden_surelog.csv | `regressions=0 conversions=0 changes=0` (466 + 14 / 463 + 11) | **`regressions=0 conversions=0 changes=9`** (466 + 14 / 463 + 11; CMP_NOTEQUAL 3 / 3; judge-equal 480 / 474 unchanged) |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `regressions=0 conversions=0 changes=0` (798 + 5 / 798 + 5) | **`regressions=0 conversions=2 changes=0`** (**799 + 4 / 799 + 4**) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **the same; `downstream.csv` byte-identical to the pristine sweep's**; 1 of 805 slang-lane databases moves (ibex_tracer, predicted, IDENTICAL on both) |
| (5) uhdm-cmp | – | every mover keeps its judge status (the histograms above; the conversions are judge-equal on both) |
| (6) byteverify (`SELFCHECK=1`, fence-free mirrors `fenced_skipped=8`) | | **13 / 2560 movers, all 13 predicted by name, no environment draw** ([evidence/sweeps/byteverify.txt](evidence/sweeps/byteverify.txt)); SELFCHECK 2559 / 2560 flagged |

Both sweeps exit 1 for one reason only, printed first: `law index STALE` — this pass's `tools/probe/r11u215repro`
directory existed (drivers copied at the start, cases later) while `tests/LAWS.md` was the base's; every stage reads
`regressions=0`. The regenerated `tests/LAWS.md` in the patch makes `python3 scripts/law_index.py --check` read `law
index current` ([evidence/sweeps/law_index_check.txt](evidence/sweeps/law_index_check.txt)).

**The SELFCHECK reading 2559 / 2560** is byteverify's negative control working as designed, not a movers line: it
compares every patched database against the PRISTINE copy of ONE fixed path (the first in sort order) and counts the
files that differ; that fixed path's own patched database is byte-identical to its pristine copy (it is not a mover),
so exactly one of the 2560 comparisons reads equal and the control passes at `>= N - 1`. A reading below 2559 would
mean a second database byte-identical to the reference, or a blind comparator.

## 5. The prediction and the attribution of every mover

**The prediction** ([evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt), frozen `chmod 444`
at 2026-09-28T23:38:13Z before the law sweep started, md5 and binary in
[predicted_frozen_at.txt](evidence/census/predicted_frozen_at.txt)): `drivers/census.sh` ran `law26.bin` with
`R11U215_TRACE` over every corpus row-mode but the fenced four (the `--filter` built from the fence), every probe case
and every downstream lane; `drivers/predict.py` lists every database a law fired on (`diag*` lines excluded): 13 corpus
row-modes, 13 probe cases, 1 downstream lane. Every branch of every law traces. (Three earlier frozen predictions, for
law20, law22 and law23, are kept as `*_superseded.txt`: the same database set; the refinements found by the byte
controls and the determinism runs were landed after them and the census and sweep were re-run each time.)

| where | moved | predicted | predicted, not moved | moved, not predicted |
|---|---|---|---|---|
| corpus (2560 databases, fence-free mirrors) | 13 | 13 | 0 | 0 |
| probe (4087) | 13 | 13 | 0 | 0 |
| downstream slang lanes (805) | 1 | 1 | 0 | 0 |

(Scoreboard testflags is SLANG_REJECT on both binaries and writes no database.)

| row-mode / case | change | law, by the firing census (per mode) |
|---|---|---|
| ibex_tracer d/t (uhdm2rtlil) and its downstream lane | `fullname(13)` -> **CMP_EQUAL**; downstream IDENTICAL -> IDENTICAL | § impPatCopyFirstListingUnparented215 ×13 |
| BuildUVMPkg d/t | `endcol(57)` -> `endcol(33)` | § opIdxRecvElemFollowsPath215 ×18, § incDecOperandKeepsLvalueForm215 ×2, § pkgTdAliasLastWriter215 ×2 |
| MiniAmiq d/t | `file(77)` -> `file(75)` | ×36, ×4, ×33 (the same three) |
| SeqDriver d/t | `fullname(63)` -> `endline(61)` | ×36, ×4, ×30 |
| SimpleUVM d/t | `fullname(241)` -> `fullname(190)` | ×18, ×2, ×30 |
| Scoreboard d | `fullname(193)` -> `fullname(136)` | ×18, ×2, ×30 |
| BlackBePipeInt d/t | bytes only (`type(1)` / `depth(1)`) | § impPatCopyFirstListingUnparented215 ×21, § pkgTdAliasLastWriter215 ×2 |
| 12 probe conversions | section 0 | § pkgTdAliasLastWriter215 ×1-3 each (11), § pkgImportEnumCloneLastWriter215 ×1 (e08_explicit_import) |
| probe r10uvm202repro/g202_a_kinds | `fullname(6)` -> `fullname(4)` | § pkgTdAliasLastWriter215 ×1 |

**The CHANGE lines.** Every count shrinks or the first field moves later; the first records: SeqDriver `#10090`
(N0540) -> `#11289` (`phase_state_change` method_func_call endline, the macro-argument span); MiniAmiq `#899`
unchanged (its `#10107` N0540 gone); BuildUVMPkg `#22884` unchanged (its `#25472` N0778 gone); SimpleUVM `#458`,
Scoreboard `#466` unchanged. No first record moved EARLIER on any row.

## 6. Away-moved-record census, full-name lines, distances, determinism, downstream, byte controls, canaries

**Away-moved-record census, chain-keyed** (r11u211map's `awayrows.py`, copied as `drivers/awayrows.py`: every
database whose bytes differ between the two sweeps, each strict record keyed by its ancestor chain, and flat;
[evidence/away/](evidence/away/)): **26 databases, 0 records away (chain-keyed and flat) on every one**; toward:
BlackBePipeInt 21 / 21, BuildUVMPkg 40 / 40, MiniAmiq 73 / 73, Scoreboard 60, SeqDriver 102 / 102, SimpleUVM 80 / 80,
ibex_tracer 13 / 13 (d / t); the 13 probe movers read 0 / 0 (their changed names sit inside canonicalised typespec
copies: the strict walk's `<in>` records are equal on both sides; the conversions are the evidence). **Positive
control**: the reversed comparison (pristine as ON) reads exactly those toward counts as away, with the first away
record printed (`ref_obj sequence_ptr uvm_pkg.sv 54011:47`, `ref_typespec work@bp_be_pipe_int`, ...).

**Full-name lines** (`drivers/fnlines.py`, pass 210's BlackBePipeInt check generalised: the distinct `vpiFullName:`
lines of the golden, pristine and law uhdm-dumps; [evidence/away/fnlines.txt](evidence/away/fnlines.txt)): on every
corpus mover **no removed line is in golden's dump**; the written lines are all in golden's dump on BuildUVMPkg (15),
Scoreboard (42), SimpleUVM (39), and on MiniAmiq / SeqDriver 41 / 39 of 50 / 48: the other 9 are the op-index law's
names inside the `svaunit_pkg` / `adpcm_pkg` CLONES of `uvm_reg::add_field` (`svaunit_pkg::uvm_reg::add_field::m_fields[idx
- 1].get_lsb_pos::idx`), whose prefix is the clone's package where golden writes `uvm_pkg::` — the pre-existing clone-
prefix family (N0485, TaskFuncEmit `emitTaskFuncs` < ParamEmit `emitImportedPkgClassMethodClones`): the pristine names
there (`svaunit_pkg::uvm_reg::add_field::idx`) were not golden's either, and the chain census reads 0 away.

**Order-blind distance to golden** (`drivers/uvmdist.sh`, dist / sym; [evidence/uvmdist.txt](evidence/uvmdist.txt)),
re-measured at the base: MiniAmiq 6539 / 14802 -> **6466 / 14656**, SeqDriver 5084 / 10954 -> **4982 / 10750**,
SimpleUVM 1994 / 3834 -> **1914 / 3674**, Scoreboard 1462 / 2847 -> **1402 / 2727**, BuildUVMPkg 720 / 1385 -> **680 /
1305** (each per mode, both modes equal); ApbSlave and SVSwitch 0. (Pass 210's figures, 14920 / 11094 / 3946 / 2937 /
1477, predate pass 209's landing into the base.)

**Determinism** (`drivers/det.sh`: three CONCURRENT harness runs per row-mode, seven rows per batch: Earlgrey_0_1,
MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg, BlackBePipeInt; [evidence/determinism/](evidence/determinism/)):
**`law26.bin`, two batches: Earlgrey_0_1 default and testflags one hash per mode, every row one hash per mode but
Scoreboard default** (the known svunit listing-order coin: three states seen, `087435a3`, `6f65e623`, `d86104a4`, 0
order-blind dump lines); the law sweep's own draw is the regular hash on every mover. **The finding that shaped
`law26`**: `law22` to `law25` drew a second hash on SeqDriver testflags in 1 of 3 runs of a seven-row batch (`5d55bb5a`
against `756a5480`; `law23`'s law sweep drew it once too), with an IDENTICAL uhdm-dump even with object ids kept and
331 bytes apart in the serialized symbol region: storage only. The pristine binary never drew it (15 harness draws: two
seven-row batches, three three-row batches). Three causes were ruled in turn: the stamp's candidate order (an address-
ordered `AllObjects()` with the alias and the base ref of one object on the same id: now ordered by id then ref,
`law24`, still drew), the reads of refs that store no full name (the generated getter computes and interns the chain
name as it stands; every law now reads only a STORED name through `r215StoredFullName`, `law25`, still drew), and the
member-read scan: a slang AST visit over the whole root forces slang to elaborate bodies it had not, and the later
passes' slang lookups then intern strings in another order; the syntax scan that replaced it (`law26`) drew nothing in
six seven-row runs, and SeqDriver testflags ran 33 more times directly (nine concurrent) on `law24`, one hash. SimpleUVM
default drew a second storage-only hash on the pristine binary in the seven-row batch too (`90c01a65`), as passes 210
and 213 recorded. The laws allocate no UHDM object.

**Downstream** ([evidence/downstream/](evidence/downstream/), the gate's `one()` on every grid case, both binaries,
`GOLDEN_CACHE=/tmp/r11u215_dsgold`): **52 of 53 IDENTICAL on both**; r07 (a package free function reading class
handles, cloned into a module) DIVERGENT on both with the slang lane's RTLIL byte-identical between the binaries (its
database moves, the netlist does not); the corpus lanes: `downstream.csv` byte-identical, ibex_tracer's slang database
moves and stays IDENTICAL.

**Byte controls, wide** ([evidence/byte_controls/](evidence/byte_controls/), `drivers/ctlmove.sh`: EVERY case dir under
`tools/probe/` but this pass's, 13034 dirs, 0 fenced, both views, pristine against `law26.bin`; movers judged with
`judge.sh` and walked with `drivers/awaychain.py`, the chain-keyed census of one triple): **parse form 47 movers: 23
convert to EQUAL, 5 shrink, 19 keep their verdict (stage 1 on both, or EQUAL on both), 0 worse, 0 chain-keyed records
away; `--elabuhdm` 52 movers: 24 convert, 7 shrink, 21 keep, 0 worse, 0 away**. The shrinks: r11u170verify ev/a03
`fullname(7)` -> `file(1)` (the file record pre-exists: pristine's tally `fullname=6 file=1`), r11u210repro P/p04 `file(3)`
-> `file(2)`, r11u176repro PQ/q12_alias `line(15)` -> `line(5)`, r11u185verify TD/d03_enum_task_key `file(22)` ->
`file(6)`, r11v147repro c7_member_typedef_of_enum_ctl `fullname(2)` -> `depth(1)` (its first record cleared, the
structural record behind it the pristine second record), and in `--elabuhdm` also r11u210repro M/m01 and
v11u210repro M/m10 by one record each. The 23 parse converters: pass 210's residue cases r11u210repro P/p01 and p05 (R1) and
r11v163repro ip/e02 (the first-listing law), r11u124repro hp/h05_arg and r11v124repro hx/x15_twice (the inc/dec law),
and 18 alias-typedef and enum-import cases of the r11u143-r11u170 grids (al/e03_member, al/e11_mod_alias_of_pkg_alias,
EA/e02_pkg_base_ctl, ea/e03_member, ev/a02, ev/a07, ev/e03, ev/e07, ev/e14, ev/v07, fa/g11_alias_then_enum,
fence_s3/f03_var_not_param, FN/d04, mec/m02_port_type, r10uvm49repro/a1, r11u147repro mec/f02 and f03, r11v147repro
c4_var_only: the stamp); `--elabuhdm` adds r10uvm39repro/t55a (the receiver law) to the same list
([evidence/byte_controls/judge_movers_*.tsv](evidence/byte_controls/)).
NODB (no database on either binary): 91 parse, 95 `--elabuhdm`. **Crash parity** (`drivers/crashparity.sh`, the exit
code of both binaries on all 13034 dirs): 3 parse and 7 `--elabuhdm` segfaults, the same dirs and the same code on
both binaries, and no exit code differs anywhere ([evidence/byte_controls/crash_parity_*.txt](evidence/byte_controls/)).

**Canaries** ([evidence/canaries/](evidence/canaries/)): `canaries.sh` on the surelog csv reads `ok=52 changed=0`
pristine and `ok=45 changed=7` law, the seven changes exactly the named CHANGE rows among the canaries (SimpleUVM d/t,
SeqDriver d/t, BuildUVMPkg d/t, Scoreboard d); uhdm2rtlil `ok=16 changed=0`; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS,
`EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.

## 7. Ranked residues and the sister-ground faces (call sites; not edited here)

1. **The enum-alias twin of § pkgTdAliasLastWriter215 when a CLASS writes last** (SimpleUVM's N0900 `work@env::`, the
   `$unit` class after module `top`; cases/A a06, a12): the stamp writes the class name, then § enumImportParentLastWriter180's
   drain (ModuleEmit `enumImportParentDrain180`, ranks interface 0 / module 1) re-writes the module's. **Sister:
   ModuleEmit `enumImportParentDrain180`** must rank a module-local class right after its module and the `$unit` classes
   (their root file holding a `$unit` import of the package) after every module, and record the alias ref on the
   interface write too (`enumImpWrite180(..., alias=false)` at the interface site): one rule with this pass's writer order.
2. **SimpleUVM `#458` / Scoreboard `#466` — `UVM_MACRO_NUMFLAGS`** (decoded on
   [evidence/residues/unit_param_copy.sv](evidence/residues/unit_param_copy.sv): `package p; parameter int NF = 17;
   parameter int EX = 1 << NF; endpackage import p::*; module m; endmodule`, its strict head beside it): the unelaborated package listing's reference binds the `$unit` import's COPY of the parameter
   (parent the design), whose ref_typespec golden names by ComputeFullName (`NF`); ours shares the package parameter's
   ref_typespec (`p::NF`) between the package and the copy. **Sister: UhdmExporter `designImportParamCopy146`** (a copy
   needs its own ref_typespec, no stored name); the module listing's copy also lacks golden's value (`work@m.EX
   UINT:131072`: the same copy's value). Pass 209 did not change it.
3. **MiniAmiq / SeqDriver's macro method-call spans** (`phase_state_change` 168:11-168:29 in golden, ours 169:9; the
   new SeqDriver head): the method name comes from a macro ARGUMENT (`cb.METHOD;` with `METHOD = phase_state_change(this,
   ps)`) under a nested-macro line; a flat reduction EQUALs, so the end location's mapping through the multi-line
   expansion is **UhdmExporter `locLineCol` / `pp166`'s** (sister); ExprEmit's span choice (the name token) is right.
4. **BuildUVMPkg `#22884` typespec_member `args` span** (TypeEmit, sister) and `#26855` `this_type` class_typespec
   location (sister); **MiniAmiq `#899`** (the `uvm_severity` typedef relocation, TypeEmit).
5. **§ opIdxRecvElemFollowsPath215's clone prefix** (section 6): the names are right once the clone-prefix family is
   (TaskFuncEmit `emitTaskFuncs` < ParamEmit `emitImportedPkgClassMethodClones`, N0485).
6. **A call inside a receiver's index** (r03 `fields[g(i)-1]`: golden locates the `func_call` at its name only, 13:18-19;
   `fields[g(i)].get()` is stage 1 on both: golden decompiles a call index to empty, `fields[].get_lsb_pos`) — ExprEmit,
   undecoded beyond this reading.
7. **§ opIdxRecvPlainElab215 in a module's instance copy** (r06 `--elabuhdm` #98, #112): golden names the instance
   copy's plain index through the path and keeps the definition listing's scope name; our instance copy of a module
   function / process is not re-emitted per view (ModuleEmit's instance copy, sister).
8. **The member-read shapes** (cases/I i13-i18, stage 1 at the base on both binaries): golden parents EVERY listing of a
   member-read parameter; ours keeps the base's direct-unparented / transitive-parented choice there (the refinement
   declines rather than write that half, since the stage-1 face hides the records).
9. **BlackBePipeInt d `#15272` / t `#66`** (ParamEmit, this ground, decoded, not landed): in the `--elabuhdm` view
   golden's cast-width mark `ref_obj dev_addr_width_gp` in the UNELABORATED package listing is not expanded at #66 (it
   binds a parameter already on the walk's path, the listing's own), while § pcwElabKeepsClaim207v keeps every ref
   bound to the importing module's copy (expanded, 8 ours-only records, N0897); the refinement would bind the
   AllPackages listing's refs to their own parameter and keep the claim elsewhere. Needs a golden-side object read of
   the ref's actual (not done: no tool that reads one object's actual was run here).
10. **Carried, not attempted**: FuncStructVal R2 (618:22) and R4 (#747), pass 210's F2 (§ elabIfArrIdxChainName205
    where golden folds the index) and F4 (a qualified read inside another package's function), struct_param_func_config
    (4 member-scope names, then the structural #1364), cfg_func_width_loop, OutputSize, anon_struct_packed_dim's gx
    records, the UVM_MACRO_* names in class copies, the foreach spans, r11u213's NC/n04-n05, R/q01, V2-V4 (V4 re-read:
    golden `task_call`, ours `func_call` for an in-body call to an extern task whose prototype sits above; the call-kind
    decision is not in the § recvNamesSubroutineCollapsesStmtCall172 path), the value encodings, map 13's N0739, N1903 /
    N1904, N0476 / N0477.

## 8. The switch reach (item 8) for this ground

| switch | drops | measured |
|---|---|---|
| `R11V198_OFF` (**new**: read nowhere before) | v11u198's refinement § vsStampReducedCtxOnly198v, like `R11V198_VSSYS_OFF` (unchanged) | `drivers/reach198.sh law26.bin` over every case dir of r11u198repro and v11u198repro, both views ([evidence/reach198.txt](evidence/reach198.txt)): the two switches write the same bytes on every one of the 568 case-views with a database (26 of them differ from the switch-free bytes: the refinement's firings); z03_varsel_both writes no database in any state |
| `R11U198_OFF` (unchanged) | pass 198's laws of this ground (`r11u198On`) | – |
| `R11U191_OFF` (unchanged) | the r11u191 laws, landed by pass 195 in ExprEmit and ParamEmit (and by pass 196 in the sister's files, with `R11U196_OFF`) | read from the sources: `R11U195_OFF` already drops pass 195's landing of them; no switch is missing for this ground |
| `R11U210_LANDING201_OFF`, `R11U210_GENBITS201_OFF` | pass 210's repair for landing 201 (unchanged) | – |
| `R11U215_OFF` | every law and refinement of this pass | 113 of 113 grid case-views pristine (section 2) |

`R11U202_OFF` (two pass 206 laws), `R11U205_OFF` (pass 209's three r11u205 laws) and `R11U200_OFF` cross into the
sister's files and are reported, not changed.

## 9. Files, and how to reproduce

* `drivers/`: `env.sh` (pins + fence), `case.sh` (judge one case, `ELAB=1` for `--elabuhdm`), `judge.sh`, `grid.sh`
  (`OFFCHECK=1 LAWBIN=law26.bin GRIDBINS="pris.bin law26.bin"`), `switchcheck.sh`, `refcheck.sh`, `reach198.sh`,
  `census.sh` + `predict.py` (the firing census and the frozen prediction; `censum.py` the older summary), `bvmirror.sh`,
  `ctlmove.sh` (+ `ctlbytes.sh`, `ctlsum.py`), `awayrows.py` (chain-keyed, two sweeps), `awaychain.py` (chain-keyed, one
  triple), `awaydump.py` (dump lines), `fnlines.py`, `away.py` + `awaycorp.sh` (flat), `uvmdist.sh`, `det.sh` +
  `detob.sh`, `dscase.py`, `rowhead.sh`, `obrow.sh`, `obdist.sh` (copied from pass 210's drivers with this pass's names).
* `cases/`: A (§ pkgTdAliasLastWriter215; a18 § pkgImportEnumCloneLastWriter215), I (§ impPatCopyFirstListingUnparented215;
  i13-i18 § impPatMemberReadKeepsParent215v), D (§ incDecOperandKeepsLvalueForm215), R (§ opIdxRecvElemFollowsPath215;
  r06, r07 § opIdxRecvPlainElab215), C (§ caseItemWildConcatOnly215).
* `evidence/`: `grid/`, `switchcheck.txt`, `refcheck.txt`, `reach198.txt`, `census/` (the frozen prediction and the two
  superseded ones), `sweeps/` (summaries, cmds audit, byteverify, the law-index check; the full sweep csvs are not
  committed because they list the fenced rows), `away/`, `uvmdist.txt`, `determinism/`, `downstream/`,
  `byte_controls/`, `canaries/`, `heads/`.

Reproduce: build `a727b8c7` + the patch (`cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON
-DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build build -j 2`), freeze it beside the pristine build in `/tmp/r11u215_bin`
as `law26.bin`, then `bash drivers/grid.sh` (and `ELAB=1`), `bash drivers/switchcheck.sh law26.bin <case dirs>`,
`bash drivers/census.sh <wd> <tr> <prefix>` + `python3 drivers/predict.py <tr> <wd>`, `tests/sweep.sh --jobs 3
--workdir <wd>` with `SLANG_UHDM` exported.

## 10. The patch

`/tmp/r11u215.patch` = `git diff a727b8c7` of this worktree: `src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`,
`src/EmitHelpers.h`, `tools/probe/r11u215repro/`, `tests/LAWS.md` (regenerated by `python3 scripts/law_index.py`;
`--check` reads `law index current`). It applies clean on a fresh `a727b8c7` worktree, and its src part rebuilt there
reproduces `law26.bin`'s md5 (`6a021c3c045bbe47c20a827e9bbf41c9`, rebuilt in a fresh worktree where `--check` also reads `law index current`).
