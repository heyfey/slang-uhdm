# r11u209: v1.87 strict pass 209 — the module/type ground (pair B)

**Base** `6e39a3fc` (branch matrix-1.87, pass 206 landed). Production files touched: `src/TypeEmit.cpp`,
`src/ModuleEmit.cpp`, `src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp` (this ground only; `ExprEmit.cpp`,
`EmitHelpers.h`, `StmtEmit.cpp`, `ParamEmit.cpp` untouched). A probe case is called a case throughout. The four
slang-fenced tests are never named here; every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed.

## 0. Verdicts

| row-mode | base | after | law(s) |
|---|---|---|---|
| **HierPathTypespec testflags** | `STRICT_NOTEQUAL differ:fullname(1)` | **`CMP_EQUAL`** | § pkgArrTdElemClone209 |
| **InterfaceStructMemberPort default** | `STRICT_NOTEQUAL differ:fullname(6)` | **`CMP_EQUAL`** | § portConnOpLeafChain209 + § modportOpOrphanReparent209 |
| **InterfaceStructMemberPort testflags** | `STRICT_NOTEQUAL differ:fullname(6)` | **`CMP_EQUAL`** | same |
| Earlgrey_0_1 d/t | `fullname(76)` | `endcol(45)` | § genConnTrailSelChain205 (all 30 head records) + § portConnOpLeafChain209 |
| Rggen default | `defname(142)` | `file(4)` | § defGenTargetIpsDefName205 |
| BuildUVMPkg d/t | `line(11)` | `line(74)` (the walk now runs past the structural record #22506; see 5.3) | § tfItemInitLocalAtType209, § tfItemLocalSpecAtName209, § classTdPkgEnumMemberShares209 |
| SeqDriver d/t | `fullname(65)` | `fullname(64)` | same three |
| MiniAmiq d/t | `file(71)` | `file(78)` (walk runs further, first record #899 unchanged) | same three |
| SimpleUVM d/t | `fullname(95)` | `fullname(259)` (walk runs further, first record #458 unchanged) | same three |
| Scoreboard default | `fullname(103)` | `fullname(211)` (walk runs further, first record #466 unchanged) | same three |
| probe (tests/probe) | EQUAL 3363 + 724 | **EQUAL 3396 + 691: 33 conversions, 4 changes (all shorter), 0 regressions** | 20 by § ifacePortDeclTsAtPortDecl205, 12 by § tfItemInitLocalAtType209 / § tfItemLocalSpecAtName209, 1 by § portConnOpLeafChain209 |

The converted rows, quoted from the law sweep's csv (`evidence/sweeps/law_surelog.csv`):

    HierPathTypespec,testflags,CMP_EQUAL,,,equal
    InterfaceStructMemberPort,default,CMP_EQUAL,,,equal
    InterfaceStructMemberPort,testflags,CMP_EQUAL,,,equal

**Gates** (sweeps `tests/sweep.sh --jobs 3`, all four stages, from `/tmp/wt_r11u209`; pristine `/tmp/r11u209_sP`,
law `/tmp/r11u209_sQ`, same-length names): probe regressions 0 (conversions 33, changes 4); surelog regressions 0
(conversions 3, changes 12, all named above); uhdm2rtlil regressions 0, conversions 0, changes 0; downstream
**803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict-identical to the pristine sweep and to
`results/downstream_uhdm2rtlil.csv` row for row**. The pristine sweep reproduces every committed baseline with 0
conversions and 0 changes. uhdm-cmp reads 0 lines on every row this pass touches (each stays or becomes judge-equal).
`law_index.py --check` read STALE in both sweeps only because the worktree carries the new `...209` / `...205` law
names; the patch commits the regenerated `tests/LAWS.md`.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u209_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `b81dbfaca6fdd916dbc1aa17af48e42e` | worktree at `6e39a3fc`, system-deps config, `-j 2`: byte-identical to the main tree's `build/slang-uhdm` |
| `law8.bin` | `e207001d247c7a03b3b8c25422989ea9` | `6e39a3fc` + this patch's `src/` (the delivered source, built last) |
| `law1.bin` .. `law7.bin` | (development) | law1 = the three r11u205 laws + the twin fix; law2 + § pkgArrTdElemClone209; law3/law4 + the two port-connection laws (law4 resets the re-parented objects' names); law5-law7 the tf-item laws (law6 widened the location law to a task with a body port, grid LV l08); law8 + § classTdPkgEnumMemberShares209 |
| comparator | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's `build/uhdm-strictcmp` (unchanged) |

Every `slang:` line of each sweep's `cmds.txt` names that sweep's frozen binary by path.

## 2. The laws (every law under its own switch; `R11U209_OFF=1` drops all ten, the r11u205 three included)

| law | switch | file | what |
|---|---|---|---|
| § genConnTrailSelChain205 | `R11U205_GENIDXSEL_OFF` | ModuleEmit (`emitDefGenStmts`) + UhdmExporter (post-pass) | r11u205dec's law, landed unchanged except for its placement (below) |
| § defGenTargetIpsDefName205 | `R11U205_IPSNAME_OFF` | TypeEmit (`emitSyntaxExpr`'s hier_path branch) | r11u205dec's law, unchanged |
| § ifacePortDeclTsAtPortDecl205 | `R11U205_PORTDECLTS_OFF` | ModuleEmit (`emitInterfaceInstance`) | r11u205dec's law, unchanged |
| § twinElemOnlyNoRange209 | `R11U209_TWINELEM_OFF` | TypeEmit (`buildUnpackedArrayTypedefTs`) | pass 206's R1: the build-dependent orphan |
| § pkgArrTdElemClone209 | `R11U209_ARRTDCLONE_OFF` | UhdmExporter (post-pass, last in `exportDesign`) | HierPathTypespec t |
| § portConnOpLeafChain209 | `R11U209_OPLEAFCHAIN_OFF` | UhdmExporter (post-pass) | InterfaceStructMemberPort d/t (the 2 reference records) |
| § modportOpOrphanReparent209 | `R11U209_MPORPHAN_OFF` | UhdmExporter (post-pass) | InterfaceStructMemberPort d/t (the 4 modport-view records) |
| § tfItemInitLocalAtType209 | `R11U209_TFINITTYPE_OFF` | TaskFuncEmit (the body-local loop) | BuildUVMPkg #22454 / #22460 and the UVM rows |
| § tfItemLocalSpecAtName209 | `R11U209_TFSPECNAME_OFF` | TypeEmit (the class-handle branch of `makeTypespec`) | the tf-item local's specialization typespec span |
| § classTdPkgEnumMemberShares209 | `R11U209_CLSENUMMEM_OFF` | TypeEmit (`buildStructTs` / the union builder, the member typespec) | BuildUVMPkg's structural record #22506 (and the UVM rows' twin) |

`R11U209_TRACE=<dir>` names every firing (one file per process, `<pid>.209`, first line `OUT <-o path>`; the r11u205
laws write `<pid>.205` there too when `R11U205_TRACE` is unset).

### 2.1 The r11u205 ground-B laws (question 0)

`tools/probe/r11u205dec/law_typeemit.patch` was applied with `git apply -3` on `6e39a3fc`: ModuleEmit and TypeEmit
applied clean; the UhdmExporter post-pass call conflicted with pass 206's rewrite of the § tpUseBindsDefDefault160
call site. **§ tpDefaultUseCastAndArrayElem205 (R11U205_TPDEFUSE_OFF) was dropped as instructed** (pass 206's
§ tpCastUseBindsDefDefault206 / § tpArrayElemBindsDefDefault206 are the landed version); the resolution keeps pass
206's block and calls `genConnTrailSelChain205(d)` after it, and the function's own block was moved above the
§ tpUseBindsDefDefault160 comment it had been spliced into. `r11u205Law` also honours `R11U209_OFF`.

Measured alone (law1) and in the composition (law8), on r11u205dec's grids (`evidence/grid/r205_*.tsv`, both views,
pristine vs law8, OFF check): GS 14 case-views convert (g01 g08 g09 g13 q01 q05 q06), IP 10 (i01 i02 i03 i04 i08),
TP unchanged (t02 is already golden's through pass 206; t13 stays `endline(2)`, r11u205's R4); every case-view
`OFF=pristine`. The probe stage reproduces r11u205's 20 conversions and 3 changes exactly (plus 13 of this pass's
own). **Fresh cases of my own** (`cases/R5`, both views): § genConnTrailSelChain205 g1 (a for-generate struct member
array select), g2 (an if-generate literal index), g3 (an interface instance member select) all convert; §
defGenTargetIpsDefName205 i2 (`7-:4` in an if-generate) converts, **i1 (a genvar-based base `o.f[k*2+:2]`) is not
reached** (golden gives the same defname and chain name; ours keeps the base form: the route that builds a
genvar-based indexed part select is not the `sel161` route, as r11u205's GS g03 already showed; its first record, the
right-hand `i[k*2+:2]`'s `k` named through `i` in golden, is ExprEmit's: residue R3); § ifacePortDeclTsAtPortDecl205
p2 (`output wire [7:4]`) stays EQUAL, p1 and p3 are stage-1 at the base and after (other faces). No fresh case moves
away.

### 2.2 § twinElemOnlyNoRange209 (question 0, pass 206's R1)

TaskFuncEmit's § queueTwinKeepsElem204v borrows the clone form's element by calling `buildUnpackedArrayTypedefTs` on a
DYNAMIC container, where `fua = ct.as<FixedSizeUnpackedArrayType>()` reads a QueueType / DynamicArrayType /
AssociativeArrayType: `elementType` shares the layout (a sound read), `range` reads past the object, so the orphaned
range carried an uninitialised `UINT` value that changed with every rebuild. The law reads the element through the
container's own type and mints no range for a dynamic container. Reader-invisible (the orphan is unreachable).
**Byte census**: 9 corpus row-mode firings, all on the five UVM rows (movers anyway), 8 tools/probe cases in the wide
byte control (`r11u183dec/cases/a/*`, `r11u195repro/.../Q/*`, `r11u204verify/.../qr3`, `r11u196repro/cases/V191/qr01`),
every one with identical verdicts and 0 lost records. **Rebuild check**: `cases/TW/qr01` (qr01 with a new first line)
reads `f21ed42d1d33` with law1 and with law8 (seven rebuilds apart, three source files changed between them), while
`R11U209_OFF=1` on law1 and the pristine binary differ from each other (the garbage value), as pass 206 found. On every
other database `R11U209_OFF=1` restores the pristine bytes (section 4).

### 2.3 § pkgArrTdElemClone209 (HierPathTypespec t)

**Head** (testflags only): the `-elabuhdm` member reference `c[1].x` binds a typespec_member whose ref_typespec reads
golden `pkg::pkg::b::pkg::a::x`, ours `pkg::pkg::a::x`. **Decode**: Surelog's `CompileHelper` typedef compile (the
named-type branch, package or file scope, `Reduce::Yes`) lists `typedef a [5:0] b;` as `tpclone =
clone_tree(ts, ElaboratorContext(&s, false, true))` with a Typedef_alias back to the original; that context
uniquifies typespecs, so `ref_typespec::DeepCopy` deep-clones the element struct, parented at the clone's element
reference. UHDM's elaborator binds `c[1].x` through the variable's typespec element (clone_tree.cpp, the
packed_array_var branch), so golden's member lives under `b`. Shared vs copied typespecs are invisible to uhdm-cmp and
canonicalised by the strict walk: only the bound member's chain differs. **Law**: post-pass (before the elaborator
runs in uhdm_main): a package listing packed_array_typespec with a name, a Typedef_alias and an element whose actual
is a named struct or union not parented at the element reference takes a clone made exactly as Surelog makes it, its
stored member full names dropped. **Grid** `cases/HP` (8 cases x 2 views): h01 (the corpus shape), h04 (a union
element), h06 (through a wildcard import, golden `work@top.q::v_t.q::s_t.z`), h07 (the struct used plainly beside
the array typedef) convert in the elaborated view, their parse views stay EQUAL (bytes only); h02 ($unit), h03
(module typedef), h05 (two dimensions, nested member), h08 (enum element) are stage-1 at the base and after.

### 2.4 § portConnOpLeafChain209 and § modportOpOrphanReparent209 (InterfaceStructMemberPort d/t)

**Heads** (6 records, both modes): the port view's modport `struct_net req` / `logic_var trn` golden with no full name
and ref_typespecs `req` / `trn` (ours `work@top.w.sub.sub.req.req` / `work@top.w.sub.trn`), and the child's
`sub.req.wen & sub.trn` references golden `work@top.w.u.sys_wen.wen` / `.trn` (ours `work@top.w.wen`).

**Decode** (Surelog `NetlistElaboration.cpp`, the port-actual loop): the actual is compiled with `Reduce::Yes` first;
every modport member reference reduces to the port view's own object (`sub.trn` -> the logic_var, `sub.req.wen` ->
the WHOLE struct_net, the member dropped) and a binary operation parents its operands at itself; an operand that
reduced to a struct_net (`needsUnreduced`) makes it recompile with `Reduce::No` and keep the hier_path form, so the
first operation is orphaned (golden's dump lists it at top level with `vpiOperand: struct_net req, logic_var trn`)
while the shared view objects stay parented at it. The hier_path form stores no full name on a path's last element
(only a whole ref_obj actual gets one), so it reads UHDM's lazy chain through the operation and the formal.

**Laws**: (a) § portConnOpLeafChain209 — every port's High_conn operation tree: a hier_path whose last element is a
ref_obj drops that element's stored full name. It is general, not modport-specific: grid `cases/IM` m10 (a local
struct member), m11 (nested operation), m12 (condition), m13 (concatenation), m15 (an interface instance member),
g10 (in a generate block: the definition view's gen-stmt listing golden `work@wrapper.g.u.b.wen` where ours was bare),
m03 (unary) all convert in both views; m14 (a path ending in a select) and m16 (a whole path actual) are golden's at
the base and stay. (b) § modportOpOrphanReparent209 — elaborated tree, instance and port order (the last connection
wins): a High_conn operation of two or more operands with an operand `<port>.<member>.<...>` rooted at a modport
interface port of the enclosing module whose member is a struct_net re-parents every `<port>.<member>[...]` operand's
view object at a fresh parentless operation of the same kind and span (as golden's orphan), dropping their cached
names. Grid: m01 (the corpus shape), m02 (the operation port first), m04 (two member paths), m06 (two instances),
m07 (a generate-scope instance), g03 (unary in a generate block) convert in both views. **Not modelled** (decoded):
an operation whose operands reduce to no struct net is KEPT reduced, its operands replaced by the view objects
(m05, g05: `sub.trn & sub.trn`, golden's operation lists the vars, ours the hier_paths; the elaborated view is
stage-1): a structural change, residue R2.

### 2.5 § tfItemInitLocalAtType209 and § tfItemLocalSpecAtName209 (the UVM rows)

**Heads**: BuildUVMPkg #22454 `static bit first = 1;` golden bit_var 41170:10-13 (at `bit`), ours 14-19 (the name);
#22460 `uvm_cmdline_processor clp = ...` golden 3-24, ours 25-28, both in the paren-less `function void
uvm_component::m_set_cl_verb;`. **Decode**: a subroutine in the TF-ITEM form (a function without a port list, or a
subroutine whose body declares a port: `blockItems9` false) declares its locals through Surelog's tf-item loop
(`CompileStmt.cpp`, the `paBlock_item_declaration` branch), which types the variable with `compileTypespec` and makes
it with `compileVariable` at the DATA TYPE whether or not it is initialised; ours already put an uninitialised tf-item
local there and moved an initialised one to its name. The typespec of such a local written as a specialization of a
generic in the subroutine's home package comes from compileTypespec's slStringConst branch, whose `getClassDefinition`
probe hits and mints the bare class_typespec at the NAME token. **Grid** `cases/LV` (both views): l01 (out-of-body,
paren-less), l02 (in-body), l04 (module function with a body `input`), l07, l08 (a task with a body `input`), l11 (in
an included header), l12 (declared through a macro body), l13 (a CRLF file) convert; l09 (the specialization span,
tf-item vs block-item form in one class) converts; l03 (with parentheses) and l05 (a paren-less task with no body port,
golden at the name) stay EQUAL; l10 (class properties and module variables) stays EQUAL; l14 (a package-qualified
typedef local in two functions, same declarator position) moves the variables to golden's span and keeps a
pre-existing typespec-name face (`name`); l06 is stage-1 at the base and after. The probe stage converts 12 cases of
r10uvm139/145/148 and their verifiers (tf-item locals) by these two laws.

### 2.6 § classTdPkgEnumMemberShares209 (BuildUVMPkg's structural record)

**Head** #22506: `uvm_verbosity verbosity;` in uvm_component's class-scope `typedef struct {...} m_verbosity_setting;`
golden `enum_typespec uvm_pkg::uvm_verbosity` (the package listing, located at its last formal writer, 43411:55-68),
ours a `bit_typespec` at the member's type token (uhdm-cmp reads them equal; the strict walk diverged there).
**Decode**: `buildClassTypedefTs` holds `bypassTypedefShare` across the whole struct build (§
aggMemberAggTdSharesListing3's decode), so a member written with an enum typedef fell to the generic tail; Surelog's
member compile hands back the typedef's own listing object. **Law**: lift the ban for a member written with a
PACKAGE enum typedef whose listing exists and is named. **Grid** `cases/CS`: c01 (with a class-method formal writer),
c04 (no writer), c05 (packed struct, logic-based enum) convert in both views; c03 (a package-scope struct) is the
control, EQUAL before and after. The wide byte control found one more case converting from stage 1:
`r11u159verify/cases/cx/x08_tp_and_enum_default` (uhdm-cmp 255 -> 0, STRICT_EQUAL).

## 3. Movers, predicted by name before the law sweep

**Predictor** ([drivers/census.sh](drivers/census.sh)): law8 with `R11U209_TRACE` over the 4087 probe cases and both
corpora in both modes, the corpus runs filtered `^(?!(<fenced>)$)` read from `$FENCED` (fail closed: `fenced hits 0 0
0 0`); frozen `chmod 444` ([evidence/movers/predicted_firings_law8.txt](evidence/movers/predicted_firings_law8.txt),
md5 `2eab14f0b9b4487a9a70756f735c4147`) before the law sweep started: 99 firings, **22 corpus row-modes, 41 cases**.

**Corpus movers** (`r11v75repro/byteverify.sh`, `SELFCHECK=1`: 959/960 and 1607/1608 flagged, path sets identical;
[evidence/movers/byteverify.txt](evidence/movers/byteverify.txt)): **22 databases, exactly the 22 predicted**:
BlackBePipeInt d/t and TypedefRange d/t (bytes only: § classTdPkgEnumMemberShares209 / § pkgArrTdElemClone209 inside
canonicalised typespecs, strict cells unchanged), BuildUVMPkg d/t, Earlgrey_0_1 d/t, HierPathTypespec d/t (default
bytes only), InterfaceStructMemberPort d/t, MiniAmiq d/t, Rggen d, Scoreboard d, SeqDriver d/t, SimpleUVM d/t,
TypedefPackedDimensions d/t (uhdm2rtlil, bytes only, § pkgArrTdElemClone209, CMP_EQUAL both). Firings per law:
classTdPkgEnumMemberShares209 11, tfItemInitLocalAtType209 9, tfItemLocalSpecAtName209 9, twinElemOnlyNoRange209 9
(the UVM rows), pkgArrTdElemClone209 6, portConnOpLeafChain209 4, genConnTrailSelChain205 2, modportOpOrphanReparent209
2, defGenTargetIpsDefName205 1 (row-modes). **Probe movers: 37 of 4087, all predicted** (33 conversions, 4 changes); 4
predicted cases do not move (g148_a_prod, v148_g_corpus: the name span equals the existing span; pb13, v16: as
r11u205 found). **Downstream lane**: 805 slang databases compared, 1 moves (TypedefPackedDimensions, predicted, verdict
IDENTICAL both).

**Away-moved-record census** ([drivers/away.py](drivers/away.py), map 12's method, all 59 movers:
[evidence/movers/away_census.txt](evidence/movers/away_census.txt)): **LOST 0 on every mover; GAINED 8362** (Earlgrey
d/t 3411 each, Rggen d 138, SeqDriver 109, MiniAmiq 92, SimpleUVM 89, BuildUVMPkg 73, Scoreboard 72,
InterfaceStructMemberPort 6 each, HierPathTypespec t 1, the bytes-only rows 0, the 37 cases 2-34 each). So the rows
whose count grows (BuildUVMPkg, MiniAmiq, SimpleUVM, Scoreboard) lose no record: their walks now pass the
`bit_typespec`/`enum_typespec` structural record and compare further. Their first records are the base's (MiniAmiq
#899, SimpleUVM #458, Scoreboard #466, SeqDriver #10090), except BuildUVMPkg, whose #3245 (`uvm_action`) record is
byte-identical in both databases but no longer reported by the comparator's alignment after the divergence moved
(its first reported record is now #5639, a ground-A call-argument constant). **UVM order-blind distance** (
`r11u168repro/drivers/uvmdist.sh`): MiniAmiq 6634 -> 6608, SeqDriver 5194 -> 5163, SimpleUVM 2074 -> 2051, Scoreboard
1526 -> 1508 (per mode), falling on every row.

**Every switch alone** ([drivers/switches.sh](drivers/switches.sh), 156 case-views of `cases/` and r11u205dec's GS /
IP): every byte move under a switch is on a case-view where that switch's law traced (UNTRACED 0;
[evidence/grid/switches.txt](evidence/grid/switches.txt)).

**Wide byte control** ([drivers/bytectl.sh](drivers/bytectl.sh), every `tools/probe` case dir, 12737, parse form,
pristine vs law8): 12356 same, 166 without a database in both binaries (three of them rc 139 in both), **95 movers**,
every one judged ([drivers/movjudge.sh](drivers/movjudge.sh), [evidence/bytectl/movjudge.txt](evidence/bytectl/movjudge.txt)):
every mover carries a firing, **0 lost records on all 95**, none leaves EQUAL, 49 convert (48 strict, 1 from stage 1).

## 4. Controls

* **OFF = pristine**: `R11U209_OFF=1` on law8 writes the pristine bytes on all 4087 probe databases (0 differ, csv
  byte-identical to the pristine sweep's) and on 102 of 104 case-views of `cases/` plus every r11u205dec GS/IP/TP and
  r11u202 IM case-view; the two exceptions are `cases/TW/qr01` (the build-dependent orphan this pass fixes).
* **Grids** ([evidence/grid/grid_pris_law8_off.tsv](evidence/grid/grid_pris_law8_off.tsv), 104 case-views): 62
  convert, 0 leave EQUAL; 18 stage-1 unchanged; 4 fullname and 2 col->name cells stay (m05/g05 default, R5 i1, LV
  l14).
* **Downstream faces** ([drivers/dsfaces.py](drivers/dsfaces.py), the gate's own `one()`): IM m01 m04 m10 m11 m13, HP
  h01 h04, LV l04, R5 g1 i2 IDENTICAL with both binaries.
* **Canaries**: `r11u107repro/canaries.sh` surelog ok=43 changed=9 absent=0 (the nine: Earlgrey d/t, SimpleUVM d/t,
  SeqDriver d/t, BuildUVMPkg d/t, Scoreboard d: all predicted movers with 0 lost), uhdm2rtlil ok=16 changed=0;
  `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` PASS (ok=58), uhdm2rtlil `EXPECT_UNKNOWN=6` PASS (ok=2).
* **Determinism** ([drivers/det.sh](drivers/det.sh), three concurrent runs per binary per row-mode,
  [evidence/determinism/](evidence/determinism)): law8 one hash per mode on Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, BuildUVMPkg (each the law sweep's); Scoreboard default draws three hashes whose sorted dumps are identical
  (storage order only, the known svunit coin), as the pristine binary also draws three. The pristine binary draws two
  MiniAmiq hashes (`dd9e7e671b37` / `44503790f4d7`, the known coin), law8 one. No new coin. The UVM value coin stays
  closed. v11u202's V2 (a rare BuildUVMPkg draw lacking a weakly referenced `this_type` class_typespec) did not appear
  in 6 + 6 draws here; not decoded (residue R8), reader-invisible (unreachable).

## 5. Residues, ranked

1. **Earlgrey_0_1 d/t `endcol(45)`**: r11u205's residue 1 stands (the package-qualifier-span constants, ground A;
   work@flash_ctrl ref_typespecs; names read through indexed part selects; the structural `#130430`).
2. **The kept-reduced connection operation** (IM m05 / g05, r11u202's IM f01 f03): an elaborated port actual whose
   operation has no struct-net operand is kept in its `Reduce::Yes` form, its operands REPLACED by the modport view
   objects (re-parented at it: golden `work@top.w.u.x.a`); ours keeps hier_paths. Structural (the elaborated view is
   stage-1); ModuleEmit's elaborated port-connection emission.
3. **A genvar-based indexed part select target** (R5 i1): § defGenTargetIpsDefName205's route is not reached; the
   right-hand index named through the select (`work@top.gen_p.i.k`) is ExprEmit's.
4. **BuildUVMPkg** after the laws: `#5639`/`#5909` (a method-call argument constant at the formal's default, ExprEmit),
   `#13373` (`foreach (this.m_predecessors[pred])` ref_var span, StmtEmit), `#19888` (a bit_select with a call index,
   ExprEmit), the `uvm_action` writer family (#3245 #20735 #20759 #20795; section 6), then the `in_use` / `fields`
   ref_var spans (foreach, StmtEmit) and the `m_fields[idx + 1]` decompile/fullname (ExprEmit).
5. **MiniAmiq #899 / BuildUVMPkg #3245**: the scalar/enum typedef formal writer order across uvm_pkg (r11u205's 4.3)
   — not attempted.
6. **anon_struct_packed_dim, ibex_tracer, OutputSize..., cfg_func_width_loop, struct_param_func_config** (uhdm2rtlil,
   unchanged): not attempted this pass; r11u205's section 2 and pass 206's R2 decodes stand.
7. **HierPathTypespec's raw-walk remainder**: our Typedef_alias actual's element struct is not the listing object golden
   shares (visible only with `--no-canon`); nothing judged.
8. **v11u202's V2** (the rare `this_type` draw): not reproduced in 12 draws, not decoded.
9. From pass 206's list not attempted: R4-R6 (the generate-block class local definition view, the class_var vs
   ref_var return, the typedef-end writer in macro bodies and headers, foreign owners of the class-scope return law,
   the generate-scope unpacked class array), V6 (input var / input bit packed ports), r11u204's B3 / B4 / N5 / N7-N9,
   map 12's N0778 / N0144.

**Sister-ground faces met on the way (stopped at the decode)**: the UVM rows' method-call spans in macro bodies
(`phase_state_change` endline, `get_full_name` line: ExprEmit's macro location model), SimpleUVM / Scoreboard's
`UVM_MACRO_*` ref_typespec full names (ParamEmit), BuildUVMPkg's call-argument constants and select spans (ExprEmit),
foreach ref_var spans (StmtEmit), R5 i1's right-hand index name (ExprEmit).

## 6. Pass 206 / r11u205 items: what this pass did with each

| item | status |
|---|---|
| (0) r11u205's three ground-B laws | **landed** (2.1); § tpDefaultUseCastAndArrayElem205 dropped |
| (1) the twin helper's determinism defect | **landed**, § twinElemOnlyNoRange209 (2.2) |
| (2) R2 anon_struct_packed_dim | not attempted |
| (2) R3 InterfaceStructMemberPort | **converted d/t** (2.4) |
| (2) R4 HierPathTypespec t | **converted** (2.3) |
| (2) R5, R6, V6 | not attempted |
| (2) V2 | not reproduced (4) |
| (3) MiniAmiq #899, BuildUVMPkg #3245 | not attempted; BuildUVMPkg's #22454/#22460/#22506 landed (2.5, 2.6) |
| (3) Earlgrey's next records, r11u204 B3/B4/N5/N7-N9, cfg_func_width_loop | not attempted |
| (3) UVM first ten records per row | [evidence/uvm/first10_base.txt](evidence/uvm/first10_base.txt) (families in section 5) |
| (4) map 12's pair-B list | HierPathTypespec t N1174 converted; the others not attempted |

## 7. The fence and the process

* Every driver that reads corpus sources or databases reads the fence from `canaudit.sh`'s `FENCED=` line and fails
  closed (`env.sh`, `case.sh`, `census.sh`, `away.py`, `det.sh`, `dsfaces.py`, `bytectl.sh`, `movjudge.sh`); the two
  gate sweeps dispatched every row as the gate mandates; no binary, gdb run or script touched a fenced test's sources
  or databases outside them; no gdb was used. A grep of this directory for the four names reads 0.
* Builds `-j 2`; the pristine binary was frozen before any source edit. No stash, `GOLDEN_DEFER` unset, nothing under
  `results/`, `tests/probe/` or `third_party/` edited. Scratch `/tmp/r11u209_*` only.

## 8. Files

* [cases/](cases): HP (8, § pkgArrTdElemClone209), IM (17: m01 m02 m04-m07 g03 g05 § modportOpOrphanReparent209; m03
  m10-m16 g10 § portConnOpLeafChain209), LV (14: l01-l08 l11-l14 § tfItemInitLocalAtType209; l09 l10 §
  tfItemLocalSpecAtName209), CS (4, § classTdPkgEnumMemberShares209), TW (1, § twinElemOnlyNoRange209), R5 (8: g1-g3 §
  genConnTrailSelChain205, i1 i2 § defGenTargetIpsDefName205, p1-p3 § ifacePortDeclTsAtPortDecl205). Each names its
  law in its first line.
* [drivers/](drivers): `env.sh` (pins, fence), `case.sh` / `grid.sh` (one case / a grid, both views, OFF check),
  `census.sh` (the predictor), `away.py`, `switches.sh`, `det.sh`, `dsfaces.py`, `bytectl.sh`, `movjudge.sh`.
* [evidence/](evidence): `sweeps/` (both sweep logs, the law sweep's probe csv and its surelog csv without the fenced
  rows; its uhdm2rtlil csv is row-identical to the pristine sweep's and its downstream csv verdict-identical to
  `results/downstream_uhdm2rtlil.csv`, so neither is copied: a row name of each contains a fenced name as a substring),
  `movers/`, `grid/`, `bytectl/`, `determinism/`, `uvm/`.
