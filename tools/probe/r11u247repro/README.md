# r11u247 — module/type ground: the clone home bindings, the pure-virtual formal span, the type-parameter array element, the keyword element typespecs

Pass 247 (PAIR B refill after pass 245), base `08d31c79`, worktree `/tmp/wt_r11u247`. Ground: `src/TypeEmit.cpp`,
`src/ModuleEmit.cpp`, `src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`, `uhdm_main.cpp`. This pass touches
`src/TypeEmit.cpp`, `src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp` and adds `src/R247.h` (switches +
`R11U247_TRACE`). Nothing on the sister ground (ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit) is edited.

Six laws, each behind its own switch; `R11U247_OFF` drops all of them (pristine bytes on 62 of 62 case-views of the
grid and on all 9 corpus movers). `R11U247_TRACE=<dir>` writes `<dir>/<pid>.247`: `OUT <-o path>` then one
`<law> <detail>` line per firing; every branch of every law is traced (the firing census below is the predictor).

Binaries (both frozen `chmod 555` before any measurement): pristine `2af88ce8c0c70f3e728d6e8fdfaf0d9a`
(byte-identical to the main tree's build at the base), law `da60f833fd263102ef74d71140183800`; both link slang
12.0.0+545f88b2e. Every cmds.txt of both corpus sweeps names its own frozen binary (3265 + 3265 of 3315 cmds.txt
read after the fence filter; the other 50 have no slang line).

## Verdicts per targeted row (before -> after)

No corpus row converts. **One probe case CONVERTS**: `r10svs6repro/b4_qual`
(`STRICT_NOTEQUAL differ:line(2)` -> fresh row `r10svs6repro/b4_qual,EQUAL,,equal`; § clsTpKwDefaultArrElemAtUse247,
the two `T` array elements of `class b4_par #(type T=int)` read the type parameter's object).
Every targeted UVM head on this ground is cleared; each row is now headed by a ground-A record.

| row-mode | base (first record) | after (first record) | law(s) |
|---|---|---|---|
| MiniAmiq d/t | `depth(1)` #76762, golden class_var `uvm_pkg::uvm_phase::execute_phase::iter` 164:49 where ours goes on to the method_func_call | `type(1)` #78478 (the walk moves on 1716 records past the old head) | § cloneStmtHomeVarDupKeyByOrder247 clears #76762; § cloneArrTsHomeRefOwn247 clears #78360 (the copy `get_predecessors_for_successors::successors` element reference, golden `<in>` named, ours unnamed) |
| SeqDriver d / t | `depth(1)` #76718 / #76730 | `type(1)` #78434 / #78446 | the same two laws |
| BuildUVMPkg d/t | `endcol(3)`: #91593, #129711, #153018 | `type(1)`: #153018 alone (ground A) | § pureVirtFormalSignKwTrim247 clears #91593; § clsTpKwDefaultArrElemAtUse247 clears #129711 |
| SimpleUVM d/t, Scoreboard d | `type(1)` #98800 / #98812, #130737 (ground A) | unchanged verdict and first record; bytes move toward golden behind the head (9 records per row-mode, 0 away) | § clsTpKwDefaultArrElemAtUse247 (`uvm_queue`'s `T queue[$]`), § clsPropElemAliasName247 (`uvm_reg_fifo::fifo`, `uvm_reg_field::m_reset`) |
| v11u245 A/a06 (pass 245's residue 1, a downstream reader failure) | stage 1 (92 cmp lines), downstream STATUS_DIFF (uhdm2rtlil READ_FAIL `Could not find wire 't' for bit select`) | STRICT_EQUAL in both views, downstream **IDENTICAL** | § anonAggElemKeywordTs247 |
| v11u241 AR/r09 (pass 241's residue: "AR r09's UhdmExporter half") | `STRICT_NOTEQUAL fullname` both views | STRICT_EQUAL both views | § cloneArrTsHomeRefOwn247 |

The new heads (all ground A, decode only, see "Sister-ground faces"):
* MiniAmiq / SeqDriver #78478 / #78434 / #78446: in the copy of `uvm_phase::get_predecessors_for_successors`,
  `foreach (pred.m_predecessors[next_pred])`: the loop variable `next_pred` (the shared home object
  `uvm_pkg::...::next_pred`) binds an unlocated `int_typespec` in golden and the index's `class_typespec uvm_phase`
  575:33 in ours. Reduced as `decode/d01` (`foreach (succ[s].m_pred[pred])`, `bit m_pred[c]`): law reads
  `STRICT_NOTEQUAL type` #161, the same face. Site: StmtEmit, § cloneLoopVarHomeObject183 / § cloneLoopVarClassPropArrayTs238
  (the associative member array over a DOTTED loop list: golden's shared object binds a fresh int_typespec).
* BuildUVMPkg #153018: StmtEmit `arrayVarArrayTs` (the foreach loop variable binding the unfolded array_typespec,
  pass 244's residue 1), unchanged.

## The laws

### § cloneStmtHomeVarDupKeyByOrder247 (`R11U247_HOMEVARDUP_OFF`; TypeEmit `cloneStmtHomeVarRef17`)
§ cloneStmtHomeVarRef17 re-points a wildcard-import copy's statement references from the copy's own variable to the
elaborated home body's, keyed by (name, line, column), and skipped an AMBIGUOUS key. A declaration written inside a
MULTI-LINE macro body is exactly such a key: every expansion of `` `uvm_do_callbacks `` in `uvm_phase::execute_phase`
declares `iter` and `cb` at the same `uvm_callback_defines.svh` 164:49 / 165:19 (golden locates a multi-line body's
tokens in the definition file; a one-line body sits at the expansion, which is why pass 244's grid H, one-line
macros, never reproduced it). Golden binds each expansion's reference to THAT expansion's home variable, a distinct
object per expansion (`class_var iter uvm_pkg::...` re-listed under each `iter.first()`, case I/i01 records 84 and
117). The law pairs the n-th copy variable of an ambiguous key with the n-th home variable of the same key in
UhdmId (creation) order, both bodies being emitted in source order; it abstains unless both sides hold the same
number (at least 2) of distinct variables under the key, pairwise of the same UHDM kind. Case I/i01 (a two-expansion
multi-line macro from an included file), both views.

### § cloneArrTsHomeRefOwn247 (`R11U247_HOMEARRTS_OFF`; UhdmExporter, the § cloneLocalArrayTsParented241 drain)
§ cloneLocalArrayTsParented241 parents an importer copy's local array_typespec at the local's ref_typespec, and
abstains when anything outside that copy binds the object (the v208_f_io refinement). In
`uvm_phase::get_predecessors_for_successors` (`uvm_phase successors[]; foreach (successors[s]) ...`) two such
outside binders exist, and both are ours by mistake: (1) the HOME body's foreach operand `successors` (a ref_var
outside every copy) binds the COPY's array_typespec, because StmtEmit `arrayVarArrayTs` keeps the last emission's
object per declaration and the copy is emitted after the home; (2) the home loop variables `s` and `pred` the copy's
foreach keeps (§ cloneLoopVarShared37: they read `uvm_pkg::...::s` inside the copy) took the copy's array_typespec
when the copy was emitted. So the copy's element reference stayed unnamed (MiniAmiq #78360: golden
`svaunit_pkg::...::successors`, ours empty). Golden's home binders read the home's own array_typespec (unparented,
no names). The law, design-final and ahead of the abstention: (1) re-points a home ref_var's reference at the
array_typespec of the variable of the same name its own subroutine or an enclosing block declares, when that is a
different object of the same kind; (2) re-points a home loop variable kept inside the copy (its full name outside
the copy's) at the home's array_typespec, found from (1) or from § cloneStmtHomeVarRef17's clone -> home map (the
home subroutine's local of the copy local's name, line and column, both home views; abstains on two candidates);
then the abstention is re-read. Cases F/f01 (both views), control v11u241 AR/r09 (`STRICT_NOTEQUAL fullname`
-> STRICT_EQUAL both views). Traced as `cloneArrTsHomeRefOwn247` and `cloneArrTsHomeRefOwn247_loopvar`.

### § pureVirtFormalSignKwTrim247 (`R11U247_PUREFORMAL_OFF`; TaskFuncEmit, the pure virtual prototype's formals)
A formal of a PURE VIRTUAL prototype written WITHOUT its own direction keyword (and without `const`, `var`,
`static`) has its builtin-keyword typespec located at the type KEYWORD alone: `int` of `int unsigned`, `bit` of
`bit signed [3:0]` (the signing and the packed dimensions outside the span); BuildUVMPkg #91593
`set_resource_pool_default_precedence(int unsigned precedence)` golden 9187:66-9187:69, ours 9187:66-9187:78. A
formal with a direction (`input int unsigned a`) spans the whole data type like every other ANSI formal
(§ tfSigningSpanFollowsCompilePath200); an INHERITED direction does not count (`f3(input int unsigned a, int
unsigned b)`: `b` takes the keyword, P/p07). Measured on functions and tasks, bare and macro-written, defaults,
`ref` / `output` neighbours, packages and `$unit` (P p01-p08). A non-pure method's formals (p01's `impl`) and an
extern prototype's (p04, STRICT_EQUAL on both binaries) are untouched; an interface class's pure prototype (p03) is
stage 1 on both binaries (514 / 602 cmp lines both, another face).

### § clsTpKwDefaultArrElemAtUse247 (`R11U247_TPKWELEM_OFF`; UhdmExporter class property switch -> TypeEmit)
The CLASS-PROPERTY ARRAY-ELEMENT holder of § classTpKeywordTsAtDefault188. A queue, dynamic, associative or
fixed-size class property written with a keyword-default type parameter of its own class (`T q[$]`, `T d[]`,
`T a[string]`, `T f[2]`) has its element typespec recorded for the same design-final drain as a scalar property
written `T`: it reads the type parameter's own object, located at its last formal writer (BuildUVMPkg #129711
`protected T queue[$]` in `class uvm_queue #(type T=int)`: golden 14837:35-14837:36, the `T` of
`push_back(T item)`, ours 14699:13, the property's own `T`). The element minted by UhdmExporter's class property
switch (`predefIntTypespec`) never passed makeTypespec's hook. Cases T t01, t03-t07, t09-t11 (queue, fixed,
dynamic, associative, no formal writer, two parameters, `bit` default, macro-declared, nested class, extern
prototype writer); t02 (a scalar `T v;`) is the control (STRICT_EQUAL on both binaries); t08 (`type U = T` chain
with a specialization) is stage 1 on both binaries with the same 216 / 654 cmp lines.

### § anonAggElemKeywordTs247 (`R11U247_KWELEM_OFF`; TypeEmit `anonAggregateElemTs`, `buildUnpackedArrayTypedefTs`, `freshLeafTsCopy`)
The element typespec of an anonymous-element aggregate (an array typedef `typedef bit [1:0] pr_t [4];`, a struct
member `bit [3:0] pair [2]`) is the kind of its WRITTEN keyword: Surelog compiles the member's own type syntax
(CompileType's builtin branches), so `bit` is a bit_typespec and `int` / `byte` / `shortint` / `longint` / `integer` /
`time` their own atom typespecs. Ours minted a logic_typespec for every integral element (pass 245's residue 1:
v11u245 A/a06 downstream STATUS_DIFF, uhdm2rtlil failing to read the database with `Could not find wire 't' for bit
select`), and the array-typedef builder an int_typespec for every atom (`typedef byte unsigned ba_t [3];`). The
per-use leaf copy (`freshLeafTsCopy`) now keeps the signedness of every atom kind (it copied it for int only, the
one atom an element could be before). `logic` / `reg` keep the logic_typespec. Cases B b01-b07 ($unit, package and
module typedefs, struct members, signed, `byte unsigned`, `shortint`, `integer`, `time`, `longint unsigned`, `reg`).
Downstream on the cases: pristine 1 IDENTICAL / 2 EQUIVALENT / 1 DIVERGENT (b05, `int` members: "Constant value
mismatch — circuits are NOT equivalent") / 4 STATUS_DIFF (READ_FAIL) -> law **8 of 8 IDENTICAL** (with A/a06).
B/b04 (module-body typedefs) stays stage 1 (92 -> 56 cmp lines): the module typedef's size-form dimension `[4]`
folded where golden keeps `4 - 1` (a ModuleEmit / TypeEmit face, residue 4). Fires nowhere in the corpora or the
probe (the copy branch traced as `anonAggElemKeywordTs247_copysigned`: 0 firings).

### § clsPropElemAliasName247 (`R11U247_ELEMALIAS_OFF`; UhdmExporter design-final, beside § clsPropLawSAliasName243)
The ELEMENT of a class property array typed by a scalar or vector typedef (`my_t tq[$]`, `v_t vd[]`, `b_t bf[2]`,
`my_t aa[string]`) binds a per-declaration copy whose Typedef_alias reference golden names by the property:
`p::q::tq::my_t` (the property's full name, then the bare typedef name), the twin of § clsPropLawSAliasName243 for
the scalar property. The INDEX of an associative property keeps the bare name (`int ia[my_t]`: golden `my_t`;
read with uhdm-dump on N/n01, the alias names of golden and law equal as a set). Renamed only when the copy is bound
by that one element reference and its alias reference holds the bare name; classes walked in listing order. Cases
N/n01, T/t11; N/n02 ($unit typedefs and module arrays) and N/n03 (package and function-local arrays) are stage 1 on
both binaries with the same cmp lines (other faces).

## Measurements

**Grid** (`drivers/grid.sh`, `evidence/grid.txt`): 31 cases in both views on 9 configurations (pristine, law,
law + `R11U247_OFF`, law + each switch), 558 lines, every line carrying its exit code, every exit code 0.
**48 case-views enter STRICT_EQUAL, none leaves**; no uhdm-cmp line count rises (B/b04 falls 92 -> 56, the B
stage-1 cases fall to 0); `R11U247_OFF` gives pristine bytes on 62 of 62. Each switch reverts only its own law's
cases (case-views whose bytes the switch changes: ELEMALIAS 6, HOMEARRTS 2, HOMEVARDUP 2, KWELEM 14, PUREFORMAL 14,
TPKWELEM 20). The grid was rerun on the final law binary (`evidence/grid.txt`); the first run, on the binary before
the copy branch's trace line was added, read the same md5 on every line.

**Downstream on the cases** (`drivers/dscases.py`, `evidence/downstream_cases.txt`; scripts/downstream_uhdm2rtlil.py's
own `one()`): 32 cases (the 31 + v11u245 A/a06): pristine 25 IDENTICAL / 2 EQUIVALENT / 1 DIVERGENT / 4 STATUS_DIFF,
law **32 IDENTICAL**, none leaving IDENTICAL.

**Byte controls** (`drivers/controls.sh`, `evidence/controls.txt`): every case of r11u241repro, v11u241repro,
r11u243repro, v11u243repro, r11u244repro, v11u244repro, r11u245repro, v11u245repro, r11u188repro and r11u234dec
(666 cases, 1332 case-views, 2664 lines with exit codes) on pristine and law: 1314 byte-identical, 16 moved:
4 enter STRICT_EQUAL (v11u241 AR/r09 both views, v11u245 A/a06 both views), none leaves, no uhdm-cmp line count
rises (2 fall: a06), the other 12 stay stage 1 with the same line count (r11u234dec N/n05, v11u241 AR r02 r03,
v11u243 E/e01_mixed, v11u244 E/e07_x_2d_assoc and W/w04_x_forms); the only non-zero exit is r11u244 F/f19 (exit 3,
an illegal fork in a function) on both binaries.

**The predictor** (`drivers/tracesweep.sh`, `evidence/prediction.txt`, frozen before the law sweep): the law
binary with `R11U247_TRACE` over both corpora in both modes and the probe cases, every fenced test excluded by the
harness's own `--filter` (a negative lookahead built from `$FENCED`, fail-closed). 36 (database, law) firings
naming 9 corpus row-modes (BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d), 4 probe
databases (r10svs6repro/b4_qual, r10uvm52repro/a1, r10uvm208repro/g208_e_head, r10v208repro/v208_f_io), no
uhdm2rtlil test (so no downstream lane predicted). § anonAggElemKeywordTs247 fires nowhere.

**Gate sweeps** (`tests/sweep.sh --jobs 3`, pristine workdir `/tmp/r11u247_wdP`, law `/tmp/r11u247_wdL`, same
length; `evidence/sweep_law.log`):
* probe: 3511 EQUAL + 576 STRICT_NOTEQUAL, **regressions=0**, conversions=1 (`r10svs6repro/b4_qual`, above),
  changes=1: `r10uvm52repro/a1` `differ:line(2)` -> `differ:depth(1)` (the old first record #61, an `int_typespec`
  41:42-41:45 of `class gen52 #(...type T=int)`'s `pool` element, cleared by § clsTpKwDefaultArrElemAtUse247; the new
  first record #230 is the pristine database's second record, unchanged). Pristine probe sweep: 3510 + 577,
  0/0/0.
* surelog: 936 CMP_EQUAL + 18 STRICT_NOTEQUAL, **regressions=0, conversions=0**, changes=6 (BuildUVMPkg d/t
  `endcol(3)` -> `type(1)`, MiniAmiq d/t and SeqDriver d/t `depth(1)` -> `type(1)`, each a first-field change with the
  old first record cleared, above). uhdm2rtlil 1606 + 0, 0/0/0. Pristine corpus sweep 0/0/0 on both.
* downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, csv byte-identical to the pristine
  downstream sweep's; slang lanes moved: **0 of 805**.
* Every sweep's exit code 1 comes from the law-index check alone (`law index STALE`, at the base too: the pristine
  sweeps' first line, before any file of this pass existed); the patch carries the regenerated tests/LAWS.md.

**Byte movers** (`tools/probe/r11v75repro/byteverify.sh` on fence-filtered hard-link mirrors, `drivers/bvmirror.sh`:
2560 databases each, 8 fenced paths skipped by name; `evidence/byteverify.txt`): **9 of 2560** corpus databases, the
9 predicted row-modes exactly; SELFCHECK 2559 / 2560 flagged. Probe: **4 of 4087**, the 4 predicted. Downstream:
0 of 805. g208_e_head and v208_f_io move bytes with no record change (0 toward, 0 away: a home reference now binds
the home's array_typespec, equal in content). uhdm-cmp reads 0 lines on all 9 corpus movers (`evidence/heads.txt`).
Law + `R11U247_OFF` writes pristine bytes on all 9 corpus movers (`evidence/off_movers.txt`).

**Away census** (map 12's chain-keyed census, `drivers/awayrows.py` with the variant comparator built by
`drivers/cc_x.sh`; `evidence/away.txt`): every one of the 13 moved databases reads **away=0** by the chain key:
toward 431 per MiniAmiq mode, 256 per SeqDriver mode, 9 per BuildUVMPkg / SimpleUVM mode and Scoreboard d, 2 on
b4_qual, 1 on a1, 0 on g208_e_head and v208_f_io. The flat key reads losses on MiniAmiq (27 per mode) and SeqDriver
(17 per mode): one record each, `bit_typespec uvm_reg_addr_t` 73:10-73:31 under the foreach loop variable `i`'s
array_typespec in `uvm_reg_map::get_physical_addresses`, `do_bus_read`, `do_bus_write` (golden 1245, pristine 1242,
law 1215 on MiniAmiq): every chain context where the law dropped it has golden count 0 (`evidence/flatlost_*.txt`,
`drivers/flatlost.py`), so these are pristine's surplus records in the wrong place (the home loop variable reading
the copy's array_typespec), not golden records lost, the reading pass 241 gave its own flat-key losses. Positive
control: the swapped sweep (law as OFF, pristine as ON) reads every toward number as away
(`evidence/away_swapped.txt`).

**Canaries**: surelog `ok=48 changed=4` (SeqDriver d/t, BuildUVMPkg d/t, all targeted), uhdm2rtlil `ok=16
changed=0`; `EXPECT_UNKNOWN=1 ctcan2.sh` PASS on the surelog csv and `EXPECT_UNKNOWN=6` PASS on the uhdm2rtlil csv.

**Determinism** (`drivers/det.sh`, `evidence/determinism.txt`): three concurrent harness draws of the law binary
on Earlgrey_0_1 and the five UVM rows read one hash per row-mode on 11 of 11 (Scoreboard testflags is a
SLANG_REJECT), each equal to the law sweep's database (4 draws per row-mode).

## Sister-ground faces (decode only; call sites)

1. **MiniAmiq / SeqDriver #78478 / #78434 / #78446** (the new head of all four row-modes; reduced as `decode/d01`):
   a foreach over a DOTTED associative member array (`foreach (succ[s].m_pred[pred])`, `bit m_pred[c]` indexed by a
   class) inside an importer copy: the shared home loop variable binds an unlocated `int_typespec` in golden and the
   index's `class_typespec` in ours. StmtEmit, the § cloneLoopVarHomeObject183 / § cloneLoopVarClassPropArrayTs238
   branch (the associative index branch).
2. **BuildUVMPkg #153018** (StmtEmit `arrayVarArrayTs`, pass 244's residue 1), **SimpleUVM #98800 / #98812** (ExprEmit
   § dpiExportedPkgSubBareOwnTdUnsupported170), **Scoreboard #130737** (the folded constant INT:63 at
   uvm_reg_model.svh 73:24, ParamEmit / ExprEmit): unchanged, not attempted.
3. Brief item (7)'s carried faces (Rggen #23546, Earlgrey #136315, BlackBePipeInt #38807 / #38803, DP/d01, c04, d03):
   not touched; no law of this pass fires on Rggen, Earlgrey or BlackBePipeInt (the firing census).

## Residues, ranked

1. The ground-A heads above (every UVM row-mode on the gate is now headed by a ground-A record).
2. **Module-body array typedefs** (B/b04: `typedef bit [1:0] mr_t [4];` inside a module): the size-form dimension
   is folded to a constant where golden keeps the `4 - 1` operation; stage 1 on both (92 -> 56 lines).
3. **Interface-class pure prototypes** (P/p03) and **`type U = T` chains with a specialization** (T/t08): stage 1 on
   both binaries, other faces (514 / 216 cmp lines unchanged).
4. **$unit and module-scope arrays of typedefs** (N/n02, N/n03): stage 1 on both, unchanged.
5. The brief's items not attempted: (1)(c) the this-wire residues of pass 243 (behind SimpleUVM's ground-A head),
   (1)(e) N n13 and L m01-m05, (2) beyond the bit/atom element (US/u11 unranged $unit ports, UA a02 / a04 / a05 /
   a06, the generate-block listing position, V/v01, K/k02 / k03, A/a03 / a04, DR/d01, US/u15, the class-property
   half of d01), (3), (4) beyond AR r09, (5) beyond #91593 / #129711, (6).

## Cases

| cases | what | law |
|---|---|---|
| I i01 | two expansions of a multi-line macro (from an included file) declaring `iter` / `cb`, in a copied out-of-body method | § cloneStmtHomeVarDupKeyByOrder247 |
| F f01 | a function-level dynamic array local iterated by `foreach (a[s]) foreach (a[s].m[p])` in a copied out-of-body method | § cloneArrTsHomeRefOwn247 |
| P p01-p08 | pure virtual prototype formals: `int unsigned`, signed atoms, tasks, interface class (p03, stage 1), extern control (p04), multi-line and commented signing, macro-written, inherited direction, defaults, `ref` / `output`, packed vectors | § pureVirtFormalSignKwTrim247 |
| T t01-t11 | class property arrays of a keyword-default type parameter: queue, scalar control (t02), fixed, dynamic, associative, no writer, `bit` / `byte` defaults, chain (t08, stage 1), macro, nested class, extern writer with a typedef'd neighbour | § clsTpKwDefaultArrElemAtUse247 (t11 also § clsPropElemAliasName247) |
| B b01-b07 | `bit` and atom elements of $unit / package / module array typedefs and struct members | § anonAggElemKeywordTs247 |
| N n01-n03 | class property array elements and indexes typed by typedefs; $unit, module, package and local controls (n02, n03 stage 1) | § clsPropElemAliasName247 |
| decode d01 | the MiniAmiq head after this pass (sister ground) | § cloneLoopVarClassPropArrayTs238 (site) |

Every case names its law in its first line.

## Drivers

`drivers/env.sh` (pins, binaries `$B`, scratch `$S`, `$FENCED` read fail-closed from
tools/probe/r11u107repro/canaudit.sh), `case.sh` (one case: golden with check_probe's arguments, ours, uhdm-cmp,
uhdm-strictcmp, the exit code), `grid.sh`, `controls.sh`, `dscases.py`, `tracesweep.sh` (the predictor),
`bvmirror.sh`, `awayrows.py` + `cc_x.sh` + `strictcmp_x.cpp` (the away census), `flatlost.py`, `det.sh`. Every
driver resolves its paths from the repo and reads `$FENCED` fail-closed; every scan builds its path list first and
filters it by `$FENCED` before opening anything.

## Process notes

* No fenced test was dispatched, read or opened outside the gate sweeps: the firing census excluded them through the
  harness filter, byteverify ran on fence-filtered mirrors, every cmds.txt list was filtered before reading.
* One waiter of this pass used `pgrep -f` on a pattern holding its own workdir name, matched its own shell and never
  ended; it was stopped by its task id (no other process touched).
* One `pkill -f` on a pattern holding this pass's scratch path (to stop this pass's own control runner) matched the
  issuing shell itself and killed it; the pattern named this pass's scratch directory, so no other agent's process
  could match it (a listing afterwards showed no process of this pass left). The control runs were restarted and
  stopped from then on by a pid file.
* A `sed` edit of `drivers/case.sh` broke its `rel=` line between the grid and the control runs; the first control
  launch failed on the syntax error before writing a line, the line was restored (diff against r11u244repro's
  `case.sh` shows only the repro name), and the grid had run on the intact driver (it was rerun afterwards anyway).
