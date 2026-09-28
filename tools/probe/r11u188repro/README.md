# r11u188: the module/type ground, pair B (refill after pass 186): bound and nested assertions named by their last instance, keyword-default class type parameters at their default, formal writers in include order, and Surelog's `-sverilog` mode

Base `c168c209` (branch matrix-1.87, pass 186). Files of the ground touched: `src/TypeEmit.cpp`, `src/ModuleEmit.cpp`,
`src/UhdmExporter.cpp`, `uhdm_main.cpp` (`src/TaskFuncEmit.cpp` needed nothing). No line of the sister's files
(`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`), of `include/`, `scripts/`,
`results/`, `tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated (`python3 scripts/law_index.py`).

**The fence.** The four slang-fenced tests are written `FENCED=` here and never spelled. Every driver that reads
corpus sources or databases (`drivers/env.sh` and everything that sources it: `case.sh`, `row.sh`, `rowrun.sh`,
`det.sh`, `census.sh`, `bvmirror.sh`, `svmode.sh`, `offcheck.sh`, `switches.sh`, `dscase.sh`) takes the four names
from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed (`uvmdist.sh` reads the same line
itself). The firing census ran `verify_golden.py --filter` built from `$FENCED` (`$NEGFENCE`, the four rows excluded);
the byte comparison ran on hard-link mirrors that leave the 8 fenced row-mode databases out (`fenced_skipped=8`). No
fenced test was run, read or decoded outside the gate sweeps, which dispatch every row themselves; their csv verdicts
are the only fenced facts cited (none moved). gdb was not used. Every driver resolves its paths from the repository
holding it (`env.sh`: `R188_REPO`, the main checkout for the pins) and takes the frozen binaries directory from
`$R188_BIN`; none names a scratch worktree.

**Switches.** Every law reads its own `R11U188_<LAW>_OFF` through `r11u188Law` (`UhdmExporter.cpp`, beside
`r11u186Law`); `R11U188_OFF=1` drops all of them. `R11U188_TRACE=<dir>` names every firing (one file per process,
`<dir>/<pid>.188`, first line `OUT <-o path>`, then `<law> <detail>`); unset, nothing is written.

| switch | law | file |
|---|---|---|
| `R11U188_PROPLAST_OFF` | § propAssertLastInstPath188 | ModuleEmit.cpp |
| `R11U188_BINDPARENT_OFF` | § bindDisplayTargetParent188 | ModuleEmit.cpp |
| `R11U188_TPKEYWORD_OFF` | § classTpKeywordTsAtDefault188 | TypeEmit.cpp, UhdmExporter.cpp |
| `R11U188_TPDEFSYN_OFF` | § tpOwnTsAtHeaderDefault188 | UhdmExporter.cpp |
| `R11U188_TPINCORDER_OFF` | § tpFormalIncludeOrder188 | TypeEmit.cpp |
| `R11U188_SVMODE_OFF` | § svModeAllFiles188 | uhdm_main.cpp (`--sverilog`), UhdmExporter.cpp |

`R11U188_OFF=1` on the law binary gives the pristine bytes on all 4087 `tests/probe` databases and on all 86 case
directories of this pass (`drivers/offcheck.sh`, [evidence/offcheck.txt](evidence/offcheck.txt): probe same=4087
differ=0, cases same=86 differ=0). Each switch alone moves only its own law's cases
([evidence/switches.txt](evidence/switches.txt)).

## 1. Binaries (frozen `chmod 555` in `$R188_BIN` = `/tmp/r11u188_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `31cca146e477f929354b62ba79ce40b6` | the worktree's system-deps `-j 2` build of `c168c209` = the main tree's `build/slang-uhdm` |
| `law.bin` | `947db135b19754654eb4b12254f18eb0` | the patch (the worktree's `build/slang-uhdm` built from the delivered sources) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

(`d1` .. `d12` are development builds; `d12` = `law.bin`.) The delivered patch applied to a fresh `c168c209`
worktree (`git apply`, no warning) builds byte-identical to `law.bin` (`947db135…`), and `law_index.py --check` reads
current there. Sweeps: `drivers/sweep.sh <bin> <workdir>` =
`tests/sweep.sh --jobs 3` with the pins exported, same-length workdirs `/tmp/r11u188_sw{P,A,L}` (P pristine, all four
stages; A an intermediate corpus-only sweep of `d3`; L the law binary, all four stages). Every corpus `cmds.txt` of
swP names `pris.bin` (3273 of 3273 `slang:` lines) and every one of swL names `law.bin` (3273 of 3273).

## 2. The laws

### 2.1 § propAssertLastInstPath188 (`R11U188_PROPLAST_OFF`) — ModuleEmit.cpp, `emitInstance`

**Face** (map N0431 + N0627 + N1047: AssertDelayError d/t `fullname(48)` / `fullname(66)`, AssertTempError d/t
`fullname(28)` / `fullname(38)`). Every differing record was a property declaration, an assertion or a reference in
their bodies, in both listings:

    #317 fullname
      A: 2 property_decl p_send  work@tb_UART.uart_inst.uut.p_send   design.sv 82:14-82:20
      B: 2 property_decl p_send  work@UART_assertions.p_send          design.sv 82:14-82:20
    #373 fullname
      A: 2 assert_stmt           work@tb_UART.uart_inst.uut           design.sv 87:4-87:69
      B: 2 assert_stmt           work@UART_assertions                 design.sv 87:4-87:69

**Decode.** Surelog compiles a module's named property declarations and its module-scope concurrent assertions once,
on the definition; `UhdmWriter`'s elaborated module lists those same objects, and each instance's elaboration binds
them in place. The shared objects therefore carry the full name and the parent of the last instance elaborated
(depth first, in instantiation order). Measured on 19 cells (`cases/B`, dumps in the grid): one instance two levels
down (`work@tb.u_m.u_c.p_a`, c02), an instance-array element (`u_c[0]`, d04), a generate-loop instance
(`work@tb.g[0].u_c`, d05), an inline `assert property` (d06), two tops (d07), and a bound module whose target sits
below the top (`bind dut chk u_chk`, b01: `work@tb.u_dut.u_chk.p_a`, the target-based path, while the bound
module_inst displays `work@tb.u_chk`). The multi-instance cells are judge-unequal at the base and were read only for
the order: two instances name every listing after the second (`u_two`, c03, b02), a bound instance followed by a
direct one takes the direct one (b07). The mriscv_bind_sva road (`bindDefDisplay`, a module bound into a TOP) is the
special case this law generalises: its display path is the last instance's path.

**Law.** At every non-top `emitInstance` visit, the definition's property_decl objects (recorded per definition at
the def emission) and its shared assertions are renamed from their current prefix to the instance's path and
re-parented at the instance; the last visit wins. The rename walks only objects the root owns (a `VpiParent` chain
reaching the root: a reference's target, a typespec, the instance itself are never followed; UHDM's own
`UhdmListener` with the non-owned objects marked visited). Declined: a TOP instance (its path is the definition's
name, and the re-parent is invisible in the dump: the def view and the elaborated top print alike, cell d08, bytes
kept) and a bind that names an INSTANCE (`bind u_dut chk u_chk` inside the holder: Surelog does not elaborate it and
golden keeps `work@chk.p_a`, cell b04). Interfaces are not touched (d01: golden names them too, but ours emits no
property_decl there: judge-unequal before and after).

### 2.2 § bindDisplayTargetParent188 (`R11U188_BINDPARENT_OFF`) — ModuleEmit.cpp, `emitInstance` child loop

**Face** (cells b05, b06, after 2.1): a module bound into `tb.u_mid.u_dut` displays in golden as
`work@tb.u_mid.u_chk` (ours `work@tb.u_chk`), and its high-conn references scope through `work@tb.u_mid`
(`work@tb.u_mid.clk`, ours `work@tb.clk`). **Decode**: `DesignElaboration::createBindInstance_` parents the bind
instance at the target's parent (`parent->getParent()`), the same rule § bindIfaceTwinInParent46 transcribed for
interfaces; a top target has no parent (the bind re-parents onto the target: the pristine `currentTopPrefix` road,
unchanged), and a target directly under the top reads the same either way. **Law**: the bind display path is the
target's parent path plus the child name; the high-conn prefix is that parent path. In a generate block the parent
is the block (`work@tb.g.u_chk`, b06). Corpus: fires on no row (every corpus bind targets a module at or under the
top); probe: one change (r10vrgg16repro `cells/v14` `fullname(4)` -> `fullname(2)`, a strict subset).

### 2.3 § classTpKeywordTsAtDefault188 (`R11U188_TPKEYWORD_OFF`) — TypeEmit.cpp `makeTypespec` hook, UhdmExporter.cpp `emitClassParameters`

**Face** (map N0039, `span|int_typespec|...|under:ref_typespec`, 156 probe cases, 10 UVM row-modes):

    r10v160repro/c01_scopedname  #119 line
      A: 8 int_typespec  dut.sv 17:26-17:29     (the default `int` of `class hold160 #(type T=int)`)
      B: 8 int_typespec  dut.sv 19:24-19:25     (the use `T t;`)

**Decode.** The pass-180 laws § classTpDefaultTsAtUse180 / § classTpFormalMovesTs180 / § classTpChainRootShares180
(compileTypespec answers a type parameter's name with the parameter's own typespec; a formal's
`populateCoreMembers` moves that object to its type token, the last formal of the class body winning) were measured
and landed for class-handle defaults only. The same rule holds for a KEYWORD default: `class c #(type T = int)`'s
method local, nested-block local, return value, pure-virtual prototype return and class property written `T` read
the default's object (`cases/T` t06, t09, t13; r10uvm58repro a7_formal, a8_locals), and a task formal `output T o`
moves it (t20: the type parameter's own listing, the local and the formal all read the formal's `T`, 3:18-3:19),
through a chain (`type T2 = T1`, r10uvm14repro t19_t: every object at the last formal `T2 s`, 8:49).

**Law.** The type parameter's own typespec is registered (`noteTpOwnTs180`) when its chain root's written default is
a keyword type with no dimensions (`bit logic reg byte shortint int longint integer time string real shortreal
realtime chandle event`); `makeTypespec` records the finished typespec of a variable, class property, formal,
subroutine or prototype written as such a parameter of its own class (recursion-guarded per symbol) into § 180's
design-final drain, which copies file and span from the own object after the formal moves it. A default written as a
NAME (typedef, class, another parameter at the root) is not claimed: its object may be the typedef's shared one, and
no relocation of it is made here.

### 2.4 § tpOwnTsAtHeaderDefault188 (`R11U188_TPDEFSYN_OFF`) — UhdmExporter.cpp `emitClassParameters`

**Face**: r10uvm68repro a4_typaram, r10uvm12repro t6_t: the class_defn listing's `TP` typespec at 15:8, the override
token of `C4 #(int) c4;`, where golden reads the header's `int` 6:22. **Decode**: slang hands the listing the first
specialization with the default values; when that is an explicit specialization, its target syntax is the override
token. The class_defn is the generic class's (golden locates at the header). **Law**: for a keyword default, the
listing's own typespec is built from the class header's written default. Cells T/t31 (converts), t32 (control: the
override differs, unchanged by the switch).

### 2.5 § tpFormalIncludeOrder188 (`R11U188_TPINCORDER_OFF`) — TypeEmit.cpp, the formal writer of § classTpFormalMovesTs180

**Face** (found by the fresh cells of brief caution i: a class body with a method in an `included file): § 180
compared the formal writers' offsets only within one buffer, so the first buffer seen won across files. Golden takes
the last formal Surelog compiles, i.e. the last in the preprocessed stream: t21 (include first, then a formal in the
main file: golden dut.sv 4:18) and t22 (the mirror: golden m22.svh 1:20); the class-handle branch reads the same (t29,
t30). **Law**: each writer carries its include chain (root first); a writer in another buffer replaces the recorded
one when it is later at the first chain level that differs. It fires 105 times on each UVM row (formals of
parameterized UVM classes whose methods are spread over included `.svh` files) and on no probe case. Measured on the
UVM order-blind distance (section 6): with § classTpKeywordTsAtDefault188 it removes 448 of MiniAmiq's 678 records.

### 2.6 § svModeAllFiles188 (`R11U188_SVMODE_OFF`) — uhdm_main.cpp `--sverilog`, UhdmExporter.cpp `verilogLexMode`

**Face** (map N0040: InterfaceModPort d/t `endcol(12)`): the six scalar `logic` signals of interface `mem_if`
(`top.v` 27-34) end at the declarator's name in ours (27:3-27:21) and at the keyword in golden (27:3-27:8), in both
listings. Pass 186 found three small SystemVerilog shapes equal (cells I/i01-i03 reproduce that: equal).

**Decode.** The distinguisher is the `.v` extension together with the `.sl` flag `-sverilog`. slang-uhdm models
Surelog's Verilog-mode lexer for a `.v` root file (`verilogLexMode`: `logic` is not a keyword there, so a bare
`logic x;` becomes a net whose typespec stretches to the first declarator, § of ModuleEmit's `materializeDefNetTs`
road; cells V/v01, v07, v08 equal on a `.v` root without `-sverilog`, golden stretching too). Surelog's `-sverilog`
(`CommandLineParser.cpp`: `m_sverilog = true`; `ParseFile.cpp`: `(type == ".sv") || clp->fullSVMode() ||
clp->isSVFile(fileId)`) forces every file to SystemVerilog, and InterfaceModPort's `.sl` carries it; the harness drops
the flag (`scripts/verify_golden.py`, `IRRELEVANT_NOARG` and `location_args`: `-sverilog` is Surelog-only), so the
exporter never learns it. **Law**: `--sverilog` sets `g_svAllFiles188` and `verilogLexMode` answers false. The gate
never passes it, so the law is inert on every sweep (0 movers); by hand (`drivers/svmode.sh`,
[evidence/svmode_InterfaceModPort.txt](evidence/svmode_InterfaceModPort.txt)) the row's own translated command plus
`--sverilog` reads `STRICT_EQUAL 790 objects` in both modes (without it `STRICT_NOTEQUAL endcol`;
`R11U188_SVMODE_OFF=1` restores that). **The harness half** (out of this pass's surface): translate `-sverilog`
(and a bare trailing `-sv`, which sets the same `m_sverilog`) to `--sverilog` in both modes. The corpus rows whose
`.sl` carries `-sverilog` with a `.v` source: InterfaceModPort, ForElab, SimpleClass1, SimpleClass2 (the last three
are SLANG_REJECT). InterfaceModPort would convert in both modes.

## 3. Verdict per targeted row (fresh rows of the law sweep swL; results/ untouched)

**4 surelog row-modes STRICT_NOTEQUAL -> CMP_EQUAL, 0 regressions, loudly** (§ propAssertLastInstPath188):

    AssertDelayError,default,CMP_EQUAL,,,equal       (was differ:fullname(48))
    AssertDelayError,testflags,CMP_EQUAL,,,equal     (was differ:fullname(66))
    AssertTempError,default,CMP_EQUAL,,,equal        (was differ:fullname(28))
    AssertTempError,testflags,CMP_EQUAL,,,equal      (was differ:fullname(38))

**98 probe cases STRICT_NOTEQUAL -> EQUAL** (EQUAL 3026 -> 3124, STRICT_NOTEQUAL 1061 -> 963): 97 fire
§ classTpKeywordTsAtDefault188 (11 of them § tpOwnTsAtHeaderDefault188 too), 1 (r10uvm12repro t6_t)
§ tpOwnTsAtHeaderDefault188 alone ([evidence/probe_movers_laws.tsv](evidence/probe_movers_laws.tsv)). 93 of the 98 are
map N0039 cases (of 156; 63 stay open; the figure read 66 here until the verifier v11u188 recounted it against
`tools/probe/r11u189map/probe_clusters.csv`).

| row-mode | base | law | law / what waits |
|---|---|---|---|
| AssertDelayError d/t, AssertTempError d/t | `fullname(48/66/28/38)` | **CMP_EQUAL** | § propAssertLastInstPath188 |
| InterfaceModPort d/t | `endcol(12)` | `endcol(12)` in the gate; **STRICT_EQUAL by hand with `--sverilog`** | § svModeAllFiles188 needs the harness to pass the flag (section 2.6) |
| Earlgrey_0_1 d/t | `col(102)` | `col(98)` | § propAssertLastInstPath188 named `dm_csrs` / `dm_sba`'s assertions `work@top_earlgrey.u_dm_top.i_dm_csrs...` (4 records fixed, 0 new; the first record is unchanged: `#26470` a `flash_phy_pkg.sv` constant column, ExprEmit) |
| ibex_pmp d/t (u2r) | `file(5)` | `file(5)` | not landed: residue R2 |
| rsp_gen_minimal d/t (u2r) | `fullname(2)` | `fullname(2)` | not decoded: R6 |
| arb_idx_cast d/t (u2r) | `endcol(17)` | `endcol(17)` | R5 (sister half at #322) |
| const_cast_signext d/t (u2r) | `type(1)` | `type(1)` | decoded in part: R3 |
| OutputSizeWith...StructMember d/t (u2r) | `line(8)` | `line(8)` | sister: hier_path spans and the `'1` constant |
| LogicTypespec d/t | `endline(3)` | `endline(3)` | user decision: measured only (package logic_typespec 2:9-7:44 golden, 2:9-2:20 ours) |
| MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg | `file(5)`, `file(4)`, `fullname(20)` x3 | unchanged columns; order-blind distance falls on every one (section 6) | the first records are pass 186's residues (section 7) |

Status histograms (CMP_EQUAL + STRICT_NOTEQUAL): surelog 458+22 default, 454+20 testflags (480 / 474 judge-equal, as
at the base), uhdm2rtlil 789+14 both modes (803 / 803). No row leaves judge-equality.

## 4. The gates (law sweep `/tmp/r11u188_swL`, `law.bin`; pristine sweep `/tmp/r11u188_swP`)

| gate | result |
|---|---|
| (1) build | pristine `31cca146…` = the main tree's; law `947db135…` |
| (2) probe | regressions=0 conversions=98 changes=23; EQUAL 3124 STRICT_NOTEQUAL 963, every case judge-equal |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 4 + 0; changes 2 (Earlgrey_0_1 d/t `col(102)` -> `col(98)`) + 0 |
| (4) downstream | IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2, not identical and not excused=0; `downstream.csv` byte-identical to the pristine sweep's (pass 120's rows IDENTICAL, mem_read_reg `IDENTICAL,OK,OK,1789,1789,,`, mriscv_bind_sva `IDENTICAL,NO_GATES,NO_GATES,0,0,,`, sva_basic02 `IDENTICAL,OK,OK,4,4,,`) |
| (5) uhdm-cmp | 0 lines on each of the 15 corpus movers ([evidence/uhdmcmp_corpus_movers.txt](evidence/uhdmcmp_corpus_movers.txt)); every probe mover judge-equal (strict stage 1) |
| (6) byteverify | corpus MOVERS 15 / 2560 (SELFCHECK 2559 / 2560 flagged, `fenced_skipped=8`); probe 121 / 4087; every one predicted by name (section 5) |
| canaries | `r11u107repro/canaries.sh`: surelog ok=50 changed=2 (exactly Earlgrey_0_1 d/t, section 3), uhdm2rtlil ok=16 changed=0 (pristine 52/0 and 16/0); `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS (ok=58), `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS |
| changes judged | the 23 probe changes: each a strict subset of its pristine records (records fixed 1-14, new or changed 0: [evidence/probe_changes_subset.txt](evidence/probe_changes_subset.txt)); the 13 whose first field moves (line -> file, depth, name, endcol, col, fullname) are unmaskings of records present at the base; Earlgrey 4 fixed, 0 new; the UVM rows' strict records identical (the walk diverges before the moves) |
| cases | 86 case directories ([evidence/grid_pristine_law.tsv](evidence/grid_pristine_law.tsv)): 26 verdicts change, every one STRICT_NOTEQUAL -> STRICT_EQUAL; the 11 judge-unequal byte movers all move toward golden by the order-blind dump distance ([evidence/grid_judgeunequal_movers_orderblind.tsv](evidence/grid_judgeunequal_movers_orderblind.tsv): b02 40 -> 2, b07 44 -> 2, c03 44 -> 2, d02 122 -> 118, d03 105 -> 45, t11 10 -> 6, t12 14 -> 8, t15 12 -> 8, t16 27 -> 23, t17 14 -> 12, t18 22 -> 16) |
| downstream on cases | the 43 `dut.sv` cells of B and T: no verdict moves (41 IDENTICAL, B/d01 EQUIVALENT, B/b04 DIVERGENT, both at the base) ([evidence/downstream_cases_pristine_law.txt](evidence/downstream_cases_pristine_law.txt)) |
| switches | each alone moves only its own law's cells; `R11U188_OFF` moves 37 = their union ([evidence/switches.txt](evidence/switches.txt)) |
| whole-pass switch | `R11U188_OFF=1`: 4087 / 4087 probe databases and 86 / 86 case databases byte-identical to pristine |
| law index | regenerated; the law sweep exits 1 for one reason only, `law index STALE` (the worktree's sources and this directory were ahead of `tests/LAWS.md` while it ran); after the regeneration `tests/sweep.sh --corpus probe` on `law.bin` exits 0 (section 9) |

## 5. Movers, predicted by name first

The prediction is the firing census (`drivers/census.sh` + `censum.py`): the law binary with `R11U188_TRACE` over
both corpora in both modes (the fenced four excluded by `--filter "$NEGFENCE"`) and all 4087 probe cases, frozen
(`chmod -R a-w`, `census.tsv` md5 `9d6dd3b6…`) before the gate sweep started
([evidence/census_law.tsv](evidence/census_law.tsv)): 19 corpus row-modes and 121 probe cases, every firing a
predicted mover (a superset: every branch that can write a field traces).

- corpus: 15 movers, 15 predicted, 0 moved-not-predicted ([evidence/byteverify_L_vs_P.txt](evidence/byteverify_L_vs_P.txt),
  [evidence/corpus_movers.tsv](evidence/corpus_movers.tsv)). AssertDelayError d/t, AssertTempError d/t, Earlgrey_0_1 d/t:
  § propAssertLastInstPath188; BuildUVMPkg d/t: § classTpKeywordTsAtDefault188 (325) + § tpOwnTsAtHeaderDefault188 (2);
  MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d: the same two + § tpFormalIncludeOrder188 (105).
  Predicted-not-moved: mriscv_bind_sva d/t and sva_basic02 d/t (uhdm2rtlil): the law fires on bind children whose names
  already carry the path (`renamed=0`) and whose parent the pristine bind road already set; bytes identical.
- probe: 121 movers = the 121 predicted cases, 0 unpredicted, 0 predicted-not-moved
  ([evidence/probe_movers.txt](evidence/probe_movers.txt)); every one is a conversion (98) or a change (23).
- The UVM rows are byte-deterministic per binary up to the known coins (section 6).

## 6. The UVM rows and determinism (brief items 4 and caution j)

Order-blind distance to golden (`drivers/uvmdist.sh`, strict records as multisets, depth dropped;
[evidence/uvmdist_P_L.txt](evidence/uvmdist_P_L.txt)), pristine -> law, default (testflags the same within 2):
MiniAmiq 22,752 -> 22,074, SeqDriver 17,728 -> 17,048, SimpleUVM 5,881 -> 5,203, Scoreboard 4,664 -> 3,978,
BuildUVMPkg 3,052 -> 2,336, ApbSlave 4 -> 4, SVSwitch 102 -> 102. Per law on MiniAmiq default
([evidence/uvmdist_switches.txt](evidence/uvmdist_switches.txt)): `R11U188_TPKEYWORD_OFF` 22,740,
`R11U188_TPINCORDER_OFF` 22,522, `R11U188_TPDEFSYN_OFF` 22,074 (the two first laws compose: include order carries the
keyword formals of the included UVM methods); BuildUVMPkg: 3,052 with the keyword law off, 2,336 with either other off.

Determinism ([evidence/determinism.txt](evidence/determinism.txt), `drivers/det.sh`, three concurrent harness runs per
row-mode): `law.bin` Earlgrey_0_1 default 1 hash (`94a33ef3`, = swL), testflags 1 hash (`f641f7fb`, = swL),
BuildUVMPkg 1 hash, SimpleUVM 1 hash, Scoreboard 1 hash; MiniAmiq 3 hashes and SeqDriver 2: every pair differs only by
the known 4-line `UINT` / `vpiDecompile` coin (`|vpiDecompile:1292` / `586`), exactly as `pris.bin` (MiniAmiq 3,
SeqDriver 3 hashes, the same 4 lines; Scoreboard 2 hashes on `pris.bin`, the 92-line svunit order coin, 0 lines
sorted). No r11u188 law iterates a pointer-keyed container in an order that reaches the database (the rename runs in
`emitInstance` order; § 180's formal map is drained per entry into its own object).

First records after the laws ([evidence/first10_law.txt](evidence/first10_law.txt)): MiniAmiq `#899` the
`uvm_severity` enum file (pass 176's class-writer residue), `#1694/#1858/#2014` `uvm_bitstream_t` / `uvm_integral_t`
logic_typespec files (§ tdMoveCarriesFile172's writer order), `#2450` the `printer` depth record; SeqDriver the same
from `#1677`; BuildUVMPkg `severity` / `UVM_ERROR` reference full names through `uvm_report::verbosity` (ExprEmit);
SimpleUVM / Scoreboard ten `UVM_MACRO_*` ref_typespec names (N0682, ParamEmit); SVSwitch `size` reference names
(ExprEmit); Earlgrey `#26470` the `flash_phy_pkg.sv` constant column then `reg2hw.key[i]` bit_select names (ExprEmit);
Rggen `#2931` the `rggen_mux.sv` logic_typespec end, then indexed_part_select def names.

## 7. Residues, ranked, and the sister-ground faces

1. **R1 — InterfaceModPort d/t**: decoded and transcribed (§ svModeAllFiles188); converts once the harness passes
   `-sverilog` through (`scripts/verify_golden.py`, both modes). Operator's decision.
2. **R2 — ibex_pmp d/t `file(5)`** (N0219): the package parameter `PmpCfgRst`'s element `struct_typespec
   ibex_pkg::pmp_cfg_t` reads the moved typedef (`ibex_pmp.sv 114:47`, the last formal writer
   `perm_check_wrapper(... ibex_pkg::pmp_cfg_t region_csr_pmp_cfg ...)`) in golden's package listing (#2404) and the
   unmoved `ibex_pkg.sv 433:11` in the three import copies (#4375 module, #5655 param_assign, #7760 elaborated); ours
   the reverse. The copy site is the import-parameter copy (ModuleEmit `importParamCopy82` / ParamEmit's package
   parameter emission); not landed. Even with it the row stops at `#13972 type` (a generate-scope `var_select` whose
   `ref_typespec` golden lists and ours omits: ExprEmit, the sister's).
3. **R3 — const_cast_signext d/t `type(1)`** (N0133): golden keeps the user call in the elaborated cont_assign where
   ours folds. Grid `cases/E` (28 + 4 cells, § evalFuncSelectKeepsCall148's residue): golden keeps the call for a
   struct-typed parameter actual (e01, e06-e09, e12, e14), a member read of one as the actual (e04) or in the body
   (e05), a struct parameter port (e15), and for a hex literal actual even with a trivial body (`g(12'h1)` with
   `g = x`, e17-e24, and e10 whose struct parameter is unused); golden folds a parameter actual declared `logic`
   (e03) and a binary literal (r11u148's f01/f07, x01). So the discriminator is the reduced actual's encoding inside
   `ExprEval::evalFunc` (its argument `reduceExpr` then `setValueInInstance`) as far as this grid reads, not the body shape § 148 keys on (a hypothesis the grid supports, not a decode of the evaluator). The
   decline would sit at ModuleEmit `emitContAssigns` (§ evalFuncSelectKeepsCall148's call site, this ground); not landed
   until `evalFunc`'s argument path is decoded.
4. **R4 — N0039's other 63 probe cases**: Rggen's module-scope int typespecs (r10rgg6repro, r10rgg7repro: not class
   type parameters), the `ref_var` stage-1 shapes (cells T/t11, t12, t14-t19: judge-unequal at the base), and
   specialization listings.
5. **R5 — arb_idx_cast d/t `endcol(17)`**: `#209` the elaborated `packed_array_var index_nodes` range bound folded
   from `2**NumLevels-2` spans the expression in golden (15:10-15:22), the first token in ours (TypeEmit's fold
   constant); then `#322` generate-scope bit_select `ref_typespec` full names (ExprEmit, the sister's).
6. **R6 — rsp_gen_minimal d/t `fullname(2)`**: `#1802` an elaborated port's ref_typespec named
   `work@dut.u_rsp_gen.data_i` in golden, `work@dut` ours, then the walk diverges (`#1805` golden a `ref_obj data_i`
   where ours lists `logic_net rsp`). Not decoded.
7. **R7 — ClassTypeParam d/t, UnitElabBlock d/t** (read, not attempted): a class_typespec specialization's
   type_parameter and param_assign located in ours, unlocated in golden, and the specialization spans
   (UhdmExporter class specialization); UnitElabBlock's Verilog-mode non-ANSI port typespec spans end before they
   start in golden (`4:1-3:7`, an empty implicit data type between the direction keyword and the name) and one
   late-bound net without a file.
8. **Pass 186's residues not attempted**: MiniAmiq `#899` (class writers plus outside writers), § tdMoveCarriesFile172's
   writer order across unit kinds, Rggen `#2931`, the macro-argument select index, the interface alias-of-typedef
   reference name, the size-form unpacked dimension `1_6` decompile, and pass 180's list; PreprocTest and the
   Surelog separator defects stay report-only.
9. **Sister faces (the fix sits in ExprEmit / ParamEmit)**: ibex_pmp's `#13972` var_select typespec; arb_idx_cast's
   generate-scope ref_typespec names; OutputSize...StructMember's `hier_path Info.x` spans (`#169`, `#220`) and the
   `'1` constant (`#242`); InterfArrayBind's index reference full names through the interface-array path
   (`work@soc_tb.io_gen[0].peripheral_io_bus[io_idx].write_en.io_idx`); the UVM first records above.

## 8. Files

- `cases/<letter>/<cell>/` (first line `// § <law>`):
  B § propAssertLastInstPath188 (b01, b08, c01, c02, d04-d08; b02, b03, b04, b07, c03, d01-d03 controls), with
  § bindDisplayTargetParent188 (b05, b06);
  T § classTpKeywordTsAtDefault188 (t06, t09, t11-t20, t23-t28), § tpFormalIncludeOrder188 (t21, t22, t29, t30; each
  with its `.svh`), § tpOwnTsAtHeaderDefault188 (t31, t32);
  I § svModeAllFiles188 (i01-i03, SystemVerilog-mode InterfaceModPort shapes), V § svModeAllFiles188 (v01-v08,
  `dut.v` Verilog-mode cells: `drivers/case.sh` runs them with `TOP=dut.v`; `tests/probe` has no `.v` form);
  E § evalFuncSelectKeepsCall148 (e01-e28, x01-x04: residue R3's decode grid, measurement only).
- `drivers/`: `env.sh` (pins, `$FENCED`, fail closed, paths from the repository), `sweep.sh`, `case.sh`, `row.sh`,
  `rowrun.sh`, `det.sh`, `census.sh` + `censum.py` (the prediction), `bvmirror.sh`, `uvmdist.sh`, `offcheck.sh`,
  `switches.sh`, `dscase.sh`, `svmode.sh`.
- `evidence/`: the census, byteverify, corpus and probe movers with their laws, the probe change subset check, the
  sweep summaries and the compare outputs against the committed baselines, uhdm-cmp on the corpus movers, the grid, the
  judge-unequal movers' order-blind distances, switches, offcheck, downstream on cases, determinism, UVM distances and
  first records, the `--sverilog` run.

## 9. After the law index regeneration

`python3 scripts/law_index.py` regenerated `tests/LAWS.md`; `python3 scripts/law_index.py --check` reads current, and
`tests/sweep.sh --corpus probe` on `law.bin` then exits 0 with `regressions=0 conversions=98 changes=23`
([evidence/sweep_probe_after_index.txt](evidence/sweep_probe_after_index.txt)).
