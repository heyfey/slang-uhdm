# r11u210 — the expression/parameter ground: the r11u205 decode's last ground-A law landed (§ elabIfArrIdxChainName205) with its expression-index twin (§ elabIfArrIdxExprChainName210), a computed struct-builder leftover that reads a formal member of a pattern actual unlocated (§ memLeftReadsPatUnlocated210), the elaborated package listing's folded replication member named by its package (§ pkgTopWidePatReplTsName210), an imported wildcard-valued parameter in a case item named by the enclosing scope (§ caseItemImpWildParamScopeName210), an imported parameter's copy in an importing package joined with `::` (§ pkgImpParamMemberColons210, § pkgImpParamAliasColons210), and a landing-201 switch that drops that landing's whole ground-A state (§ landingSwitchReach210); FuncStructValSimple d/t CONVERT, 3 probe cases convert, 0 regressions

**Base.** `62ac216e` (branch matrix-1.87, pass 207 landed). Worktree `/tmp/wt_r11u210`, system-deps config. Ground A
only: `src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h`. No file of the sister's ground
(TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main, include/UhdmExporter.h) is touched; nothing under
`results/`, `tests/` (but the regenerated `tests/LAWS.md`) or `third_party/` is edited. A probe case is called a case.

**Landed while this pass ran** (not in its base): pass 209 (`b69dc2da`, the module/type ground: TypeEmit, ModuleEmit,
TaskFuncEmit, UhdmExporter only, no file of this patch) and the r11u211 map (`baf91896`). The src part of this patch
touches none of pass 209's files; `tests/LAWS.md` is generated and is regenerated at integration.

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`
in the main repository (resolved through git's common dir) and every driver fails closed on it: `case.sh`, `judge.sh`,
`grid.sh`, `ctlmove.sh`, `switchcheck.sh`, `switchreach.sh`, `det.sh`, `awaycorp.sh`, `uvmdist.sh`, `dscase.py`
refuse a fenced name; `census.sh` runs the corpora and the downstream lanes with a `--filter` built from the fence;
`bvmirror.sh` leaves the 8 fenced row-mode databases out of every byte comparison (`fenced_skipped=8`); the byte-control
list was filtered by the fence (0 hits). The gate sweeps dispatched every row; their csv verdicts are the only fenced
facts cited (all unchanged). No fenced source, database or head was read, run or decoded.

## 0. Verdicts

| row-mode | base (`62ac216e`) | after | laws |
|---|---|---|---|
| **FuncStructValSimple d** | `differ:file(39)` | **`CMP_EQUAL`** | § memLeftReadsPatUnlocated210 (20 file records), § pkgTopWidePatReplTsName210 (19 full names) |
| **FuncStructValSimple t** | `differ:file(59)` | **`CMP_EQUAL`** | the same two |
| FuncStructVal d | `differ:endcol(95)` | `differ:endcol(7)` | the same two (88 records; left: #747 / #7462 a `config_pkg::NOC_TYPE_AXI4_ATOP` span, four read-site leftovers, then the walk's structural record #7975) |
| FuncStructVal t | `differ:endcol(165)` | `differ:endcol(10)` | the same two (155 records) |
| InterfArrayBind d | `differ:fullname(3)` | `differ:fullname(1)` | § elabIfArrIdxChainName205 alone (the r11u205 law measured alone on `law1.bin`: the same bytes); left: #183, ModuleEmit's |
| ibex_tracer d (uhdm2rtlil) | `differ:fullname(579)` | `differ:fullname(13)` | § caseItemImpWildParamScopeName210 (388), § pkgImpParamMemberColons210 (156), § pkgImpParamAliasColons210 (22: 16 renamed, and 6 more — the param_assign constant's copies `ibex_tracer_pkg::ibex_mubi_t` — excused by the comparator's copy rule once ours is one of golden's names); left: R1 |
| ibex_tracer t (uhdm2rtlil) | `differ:fullname(579)` | `differ:fullname(13)` | the same three |
| **probe r11u114repro/grid/f2/b02** | `differ:fullname(2)` | **`EQUAL`** | § caseItemImpWildParamScopeName210 |
| **probe v11u111repro/brk/f5/x57_case_item** | `differ:fullname(4)` | **`EQUAL`** | § caseItemImpWildParamScopeName210 |
| **probe v11u114repro/grid/set1/e04** | `differ:fullname(2)` | **`EQUAL`** | § caseItemImpWildParamScopeName210 |

**CONVERSIONS (loud).** The fresh rows of the law sweep `/tmp/r11u210_swL` (NOT written to `results/`):

    FuncStructValSimple,default,CMP_EQUAL,,,equal
    FuncStructValSimple,testflags,CMP_EQUAL,,,equal
    r11u114repro/grid/f2/b02,EQUAL,,equal
    v11u111repro/brk/f5/x57_case_item,EQUAL,,equal
    v11u114repro/grid/set1/e04,EQUAL,,equal

Totals against the committed baselines: probe `regressions=0 conversions=3 changes=0` (EQUAL 3370 -> 3373, STRICT_NOTEQUAL
717 -> 714); surelog `regressions=0 conversions=2 changes=3` (CMP_EQUAL 924 -> 926 + STRICT_NOTEQUAL 30 -> 28 of 954
judge-equal; default 465 + 15, testflags 461 + 13; CMP_NOTEQUAL 3 / 3 unchanged); uhdm2rtlil `regressions=0 conversions=0
changes=2` (1596 + 10 unchanged: the two changes are ibex_tracer d/t 579 -> 13); downstream 803 IDENTICAL / 66 SLANG_REJECT
/ 2 EQUIVALENT / 0 DIVERGENT with `downstream.csv` byte-identical to the pristine sweep's.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u210_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `6292e702987d24e3bdb63e4f4938a601` | the worktree's build at `62ac216e`: **byte-identical to the main tree's `build/slang-uhdm`** |
| `law1.bin` | `6fe481fb25b966241414ea9769960594` | `62ac216e` + § elabIfArrIdxChainName205 + § landingSwitchReach210 only (the r11u205 law applied and measured alone) |
| `law2` .. `law11` | | development steps (the laws as they were added and gated; `law5` -> `law6` is the refinement of § pkgTopWidePatReplTsName210, section 3.4) |
| **`law12.bin`** | **`4863a1d4d9f51ee9e4d9dcea212fda3b`** | **THE DELIVERED SOURCES**: ran the firing census, the law sweep, the grids, the switch checks, the byte controls and the determinism runs |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

`cmds.txt` audit ([evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt)): the pristine sweep `/tmp/r11u210_swP`
3273 of 3273 `slang:` lines name `/tmp/r11u210_bin/pris.bin`, the law sweep `/tmp/r11u210_swL` 3273 of 3273
`/tmp/r11u210_bin/law12.bin`.

## 2. Switches (every law droppable alone; `R11U210_OFF=1` restores the pristine bytes on every case)

| switch | law | file | grid |
|---|---|---|---|
| `R11U205_IFARRIDX_OFF` (and `R11U205_OFF`, `R11U210_OFF`) | § elabIfArrIdxChainName205 | ExprEmit.cpp (the HierarchicalValue base-select branch) + EmitHelpers.h (`r11u205aOn`) | cases/IA i01-i05, tools/probe/r11u205dec/cases/IA |
| `R11U210_IFARREXPR_OFF` | § elabIfArrIdxExprChainName210 | ExprEmit.cpp (the symbolic base-index branch) | cases/IA i02 |
| `R11U210_MLPATLOC_OFF` | § memLeftReadsPatUnlocated210 | ParamEmit.cpp (`stampEvalFuncLeftovers`, § memLeftSliceUnlocated169's drain half) | cases/M |
| `R11U210_PKGREPLTS_OFF` | § pkgTopWidePatReplTsName210 | ExprEmit.cpp (the replication member fold of a package pattern) + ParamEmit.cpp (the listing flag `pkgTopWidePat210`, set in `emitParameters`) | cases/M, W, Q q04 |
| `R11U210_CASEWILD_OFF` | § caseItemImpWildParamScopeName210 | StmtEmit.cpp (the case-item expression loop, beside § imppCopyOpReadIsRef114) | cases/C |
| `R11U210_PKGIMPCOLON_OFF` | § pkgImpParamMemberColons210 | ParamEmit.cpp (`makeParamTs`'s member scope; the flag `pkgImpParamTs210` set in `emitParameters` and `drainDefParamTs`) | cases/P |
| `R11U210_PKGIMPALIAS_OFF` | § pkgImpParamAliasColons210 | ParamEmit.cpp (`makeParamTs`'s vector-typedef alias ref) | cases/P |
| `R11U210_LANDING201_OFF` | § landingSwitchReach210 (a switch, not a law: no byte moves without it) | EmitHelpers.h (`r11u201On`, `r11v201On`) + ExprEmit.cpp / ParamEmit.cpp (their local `r11u200Law`) | section 2.1 |
| `R11U210_GENBITS201_OFF` | § landingSwitchReach210 (drops the ExprEmit half of § genBlockBitsKeepsSelect200 alone) | ExprEmit.cpp | section 2.1 |

`R11U210_TRACE=<dir>` (one file per process, `<pid>.T210`, first line `OUT <-o path>`, then one law name per firing):
the census's input. **`R11U210_OFF=1` writes the pristine bytes on all 27 grid cases in both forms** (`OFF=pristine` in
every row of [evidence/grid/grid_parse.tsv](evidence/grid/grid_parse.tsv) and [grid_elab.tsv](evidence/grid/grid_elab.tsv)).
**Switch checks** ([evidence/switchcheck.txt](evidence/switchcheck.txt), `drivers/switchcheck.sh law12.bin`): each switch
alone, on every case where its law and no other fires, restores the pristine bytes: CASEWILD 8 of 8 case-views,
IFARRIDX 5 of 5 (i01 i03 i05 a02 a05), PKGREPLTS 8 of 8 (m05 q04 w02 w03, both views), MLPATLOC 2 of 2 (m06);
NOT_RESTORED none. On the cases where two laws fire, each switch alone leaves its own records: m01 MLPATLOC_OFF ->
`file(16)`, PKGREPLTS_OFF -> `fullname(15)`; p01 PKGIMPCOLON_OFF -> `fullname(26)`, PKGIMPALIAS_OFF -> `fullname(8)`; i02
IFARREXPR_OFF -> `fullname(8)`, IFARRIDX_OFF -> `fullname(1)`.

### 2.1 The switch reach (r11u208's finding, fixed by a new switch family)

r11u208 read from the sources that `R11U201_OFF` drops the six r11u201 laws and the new[] refinement but leaves on the
three r11u200 laws landing 201 carried (an unlanded state), that `R11U200_OFF` crosses the grounds, and that
`R11U200_GENBITS_OFF` drops both halves of § genBlockBitsKeepsSelect200 at once. The old switches keep their meaning;
the new ones:

| switch | drops | ground |
|---|---|---|
| `R11U210_LANDING201_OFF` | landing 201's WHOLE ground-A state: the six r11u201 laws (`r11u201On`), the v11u201 refinements (`r11v201On`), and the r11u200 laws of ExprEmit and ParamEmit (§ newArrayArgPathElemsStripped200 `R11U200_NEWARRHP_OFF`, the `$unit` / reduced-bound folds `R11U200_UNITFOLD_OFF` and `R11U200_FOLDDEPTH_OFF`, the ExprEmit half of `R11U200_GENBITS_OFF`) | A |
| `R11U210_GENBITS201_OFF` | the ExprEmit (landing 201) half of § genBlockBitsKeepsSelect200 alone | A |
| `R11U201_OFF` (unchanged) | the six r11u201 laws and `R11U201_NEWARRLAST_OFF`'s refinement | A |
| `R11U200_OFF` (unchanged) | every r11u200 law of both grounds (landing 201's three and landing 202's ten) | A + B |
| `R11U202_OFF` (unchanged, the sister's) | landing 202's whole state, including the TypeEmit half of the $bits law | B |

**Measured** ([evidence/switchreach/](evidence/switchreach), `drivers/switchreach.sh law12.bin` over every case of
tools/probe/r11u201repro, v11u201repro and r11u200dec, 210 case dirs, both views): `R11U210_LANDING201_OFF` writes the
same bytes as `R11U201_OFF R11V201_OFF R11U200_NEWARRHP_OFF R11U200_UNITFOLD_OFF R11U200_FOLDDEPTH_OFF
R11U210_GENBITS201_OFF` on **210 of 210 case dirs in both views**; it moves 106 of them away from the switch-free bytes
where the old `R11U201_OFF R11V201_OFF` moves 69 (parse) / 83 (`--elabuhdm`): the 37 parse-form cases it moves in
addition are the r11u200 laws' (r11u200dec cases/B, N, ...). One case dir (v11u201repro/cases/B/b09_two_roots, two root
files and no `args` file) writes no database in any state and reads equal trivially. No switch-free byte moves (the
switches only add conditions).

## 3. The laws

Every grid case is judged against a real pinned Surelog v1.87 golden in two forms: the probe form (`-parse -nobuiltin
-nocache -sv` against `--single-unit --nobuiltin`) and the `-elabuhdm` form (`ELAB=1`, `--elabuhdm` on our side). Each
case names its law on its first line. Verdicts: pristine -> law.

### 3.1 § elabIfArrIdxChainName205 (`R11U205_IFARRIDX_OFF`; the r11u205 decode's last ground-A law, map N0427)

Landed from tools/probe/r11u205dec/law_exprstmt.patch's IFARRIDX hunk, rebased over passes 207 and r11u208 (the literal
right-side test moved into a static helper `lhsOfLiteralAssign205` shared with section 3.2, the trace through
`trace210`); § hiddenBlockVarNetNoFile205 was NOT applied (pass 207's § hiddenBlockVarMintNoFile207 is the landed law on
that face). **Law** (r11u205's, unchanged): in the parse form's elaborated view, a continuous-assignment target
`b[i].w` whose right side is an integer literal stores no full name on its base-select index, which reads the chain
`<scope>.b[i].w.i`. **Measured alone** (`law1.bin`): the r11u205 IA grid a02 and a05 convert (a01, a03 module-scope
residue; a04, a06-a09 EQUAL on both), InterfArrayBind d `fullname(3)` -> `fullname(1)` with `law1.bin` and `law12.bin`
writing the same bytes; testflags stays CMP_EQUAL. **Fresh cases** (cases/IA): i01 (parenthesized, sized, unbased `'1`
and decimal literal right sides in two for-generates) `fullname(8)` -> EQUAL; i02 (a two-level for-generate and an
if-in-for generate) `fullname(9)` -> EQUAL with section 3.2; i03 (right sides that read, beside one literal) NOT_EQUAL on
both; i04 (a struct array, not an interface) the law does not fire, bytes unchanged; i05 (an interface-array port driven
in a child instantiated twice, beside an always_comb target) `endcol(12)` -> `endcol(8)` (the four assign records gone;
left: the procedural `p[0].z` hier_path span, pristine's). `--elabuhdm`: every IA case unchanged (the law is parse-form
only).

### 3.2 § elabIfArrIdxExprChainName210 (`R11U210_IFARREXPR_OFF`)

**Face** (i02): `assign b[i*2+k].w = 1'b0;` in `g[..].q[..]`: golden's index references `work@dut.g[0].q[0].b[i * 2 +
k].w.b.i`, ours `...b[i * 2 + k].w.i`. **Decode.** The same no-name rule as 3.1, but an expression index puts an
operation between the reference and the bit_select, and UHDM's ComputeFullName skips a bit_select's name only directly
above a ref_obj, so the base name `b` stays in the chain. **Law.** Under 3.1's gate, the symbolic base-index branch
names the index's references through `<scope>.<path>.<base>`. i02 converts with 3.1.

### 3.3 § memLeftReadsPatUnlocated210 (`R11U210_MLPATLOC_OFF`; FuncStructValSimple's file family, map N0086)

**Face.** FuncStructValSimple `cfg.INSTR_PER_FETCH = CVA6Cfg.RVC == 1'b1 ? (cfg.FETCH_WIDTH / 16) : 1;` in the builder
`build_config_func(cva6_config_pkg::cva6_cfg)`: the typespec member's leftover `INT:2` golden unlocated with no file at
every listing (20 records d, 30 t), ours at the call (`dut.sv 67:46-68:35`); FuncStructVal the same for 17 computed
members (INT:32, INT:34, UINT:2, INT:1, UINT:3, INT:128, INT:4, UINT:0 ...). **Decode.** § memLeftSliceUnlocated169 had
kept the call span when a formal member read by the right side had a PATTERN caller actual (its README: golden writes it
at a read site of the parameter, FuncStructVal's `CVA6Cfg.INSTR_PER_FETCH` 618:22-45). Scratch reductions of
FuncStructValSimple (not committed: they copy a corpus test) show golden unlocated in every shape tried: without the
instance, a ternary or arithmetic read, the caller in a package, a popcount header with `$clog2(INPUT_WIDTH)`, a
`LOG2_INSTR_PER_FETCH` member reading `cfg.INSTR_PER_FETCH`, and both together; only FuncStructVal's own
`INSTR_PER_FETCH` sits at 618:22 (4 records, undecoded, residue R2). **Law.** The pattern keep is dropped: the reduction
is unlocated like every other computed leftover. **Grid** (cases/M, both forms): m01 (FuncStructValSimple's shape
renamed), m02 (arithmetic `U.EN + 3`), m04 (the member read as an instance parameter override) `file(31)` / `file(51)`
-> EQUAL with 3.4; m03 (the caller a package localparam) `file(13)` -> `depth(1)` (a structural record past the old
divergence, the same #491-area package-caller face at the base); m05 control (the computed member reads no formal) the
law does not fire; m06 (the actual an IMPORTED pattern parameter, `build(ucfg)` after `import valp::*`) the law alone
fires, `--elabuhdm` `file(50)` -> `fullname(24)`: the 26 file records gone, the 24 left are the leftover copy's
ref_typespec that golden names by the importing module (`work@dut`), residue R3.

### 3.4 § pkgTopWidePatReplTsName210 (`R11U210_PKGREPLTS_OFF`; FuncStructValSimple's full-name family)

**Face.** In the ELABORATED package listing (uhdmtopPackages) of `cva6_config_pkg::cva6_cfg`, the folded member
`PMPCfgRstVal: {16{64'h0}}`: golden's constant is parented at the pattern operation and its ref_typespec stores
`cva6_config_pkg`; ours unparented and bare (the definition listing: bare in both). The same object is the typespec
member's leftover copy (§ patLeftoverOrphanCopy151 copies its ref_typespec's full name), so the name reaches every
listing (19 records d, 29 t). **Decode.** CompileHelper::getValue's qualified-name branch writes the expanded pattern back
as the param_assign Rhs (§ patLeftoverOrphanCopy151's decode); the written-back copy is parented and named through its
chain constant -> operation -> param_assign -> package, which UHDM's ComputeFullName reduces to the package name.
**Law.** For a package's own WIDE struct-pattern parameter emitted down the definition path in its elaborated listing
(`structWidePkg`), read somewhere by its qualified name — outside a parameter declaration (§ pkgNestedPatElabNoExpandSize34's
predicate) or as a call argument in a live parameter context (§ pkgElabPatMemberStamp58's) — the folded replication
member is parented at the operation and its ref_typespec stores the package name. **Refinement found by the grid** (law5
-> law6): the first draft named every wide package pattern and moved two records away from golden in cases/W w01 (read
through a wildcard import only) and w03's second package (never read); the gate on the qualified read restores both.
**Grid** (cases/W, Q, M): w02 (a qualified read `vp::S.E` in two modules, the count a package localparam)
`fullname(1)` -> EQUAL; w03 (two wide patterns, one read as `bp::mk(ap::U1)`) `fullname(15)` -> EQUAL; w01 (read through
an import) unchanged `type(1)` (a pre-existing stage-2 structural record); q04 (FuncStructVal's wide shape with a
qualified enum member) `fullname(1)` -> EQUAL; q01, q03 controls EQUAL on both; q02 stage 1 on both; m05 converts
by this law alone.

### 3.5 § caseItemImpWildParamScopeName210 (`R11U210_CASEWILD_OFF`; ibex_tracer's 388 A-half records)

**Face.** ibex_tracer `unique casez (insn) INSN_CLW: ...` with `import ibex_tracer_pkg::*;`: golden's item reference
`work@ibex_tracer.INSN_CLW` (in the function `decode_expanded_insn`: `work@ibex_tracer.decode_expanded_insn.INSN_CMPUSH`),
ours `ibex_tracer_pkg::INSN_CLW`, exactly on the parameters whose value holds `?` digits (`{3'b010, 11'h?, {OPCODE_C0}}`);
the parameters without them (`INSN_ECALL`) already read the scope name through § imppCopyOpReadIsRef114. **Decode.** A
value with x/z bits cannot fold, the item keeps the reference, and golden names it by the enclosing scope like the other
kept imported references. **Law.** A case-item ref_obj reading an UNQUALIFIED imported package parameter whose value has
unknown bits stores `joinRef(prefix, name)`. **Grid** (cases/C, both forms): c01 (casez in always_comb and in a function)
`fullname(4)` / `(2)` -> EQUAL; c02 (explicit single-name imports, a `case`, a task body) `fullname(4)` / `(2)` -> EQUAL;
c03 (a case in a generate block beside an `if` condition reading the same parameter) `fullname(1)` -> EQUAL (elab EQUAL on
both); c04 (a module instantiated twice, a function called from a continuous assignment and a named block) `fullname(6)`
/ `(3)` -> EQUAL; controls c05 (a module-local wildcard parameter) and c06 (the qualified `tp::W`) do not fire, bytes
unchanged (both stage 1 on both binaries: c06 is golden's `tp::W` VpiName, a pre-existing face). Probe: three cases
convert (section 0).

### 3.6 § pkgImpParamMemberColons210 and § pkgImpParamAliasColons210 (`R11U210_PKGIMPCOLON_OFF`, `R11U210_PKGIMPALIAS_OFF`)

**Face.** ibex_tracer_pkg `import ibex_pkg::*;` re-lists ibex_pkg's parameters; the copies' typespecs: golden
`ibex_tracer_pkg::ExcCauseBreakpoint::ibex_pkg::exc_cause_t::irq_int` (struct members, 144 + 12 records) and
`ibex_tracer_pkg::IbexMuBiOff::ibex_mubi_t` (a vector typedef's alias ref), ours joined with `.` after the parameter
name. **Decode.** The copy lives in the importing package, and UHDM's ComputeFullName joins every segment with `::` once
a package is on the chain (the same rule § pkgParamTsRefColons131 applied to the bounds of a package parameter's
typespec). Our alias ref tested the parameter's HOME package against the prefix, which starts with the importing one.
**Laws.** While ParamEmit builds the typespec of an imported parameter's copy in a package (the package emission's
`inPackage && isImported`, and drainDefParamTs's deferred clone `pd.inPackage && importCopy0`): the struct member scope
joins `<prefix>::<typedef>` with `::` members; the vector-typedef alias ref joins with `::`. **Grid** (cases/P): p01 (a
package importing another's struct and vector-typedef parameters, both imported into a module) `fullname(32)` ->
`fullname(2)`; p04 (two vector typedefs and a struct, the module reading only the importer's own parameter)
`fullname(23)` -> `file(3)` (a later record, a module-listing `'0` constant's location, past the old ones); p05 (the
module imports only the importing package: ibex_tracer's shape) `fullname(32)` -> `fullname(2)`, both forms; control p02 (no
importing package) EQUAL on both, bytes unchanged. The two records left in p01 / p05 are residue R1 below. **BlackBePipeInt**
(fires 126 times per mode, byte mover): its strict records do not move (the names sit inside canonicalised typespec
copies); in the uhdm-dump, every one of the 4536 distinct full-name lines the law writes is present in golden's dump and
none of the 4536 it removes is (section 6).

### 3.7 § landingSwitchReach210 (section 2.1)

## 4. The gates (`tests/sweep.sh --jobs 3`, all four stages, against the committed baselines at `62ac216e`)

| gate | pristine (`/tmp/r11u210_swP`, `pris.bin`) | **law (`/tmp/r11u210_swL`, `law12.bin`)** |
|---|---|---|
| (1) build | = the main tree's build (`6292e702...`) | `62ac216e` + this patch (`4863a1d4...`) |
| (2) probe vs golden_probe.csv | EQUAL 3370 / 717, `probe.csv` byte-identical to the worktree's baseline, `regressions=0 conversions=0 changes=0` | **EQUAL 3373 / 714: `regressions=0 conversions=3 changes=0`**; 3 of 4087 probe databases move (the three conversions) |
| (3) surelog vs golden_surelog.csv | `regressions=0 conversions=0 changes=0` (464 + 16 / 460 + 14) | **`regressions=0 conversions=2 changes=3`** (465 + 15 / 461 + 13; CMP_NOTEQUAL 3 / 3 unchanged; judge-equal 480 / 474 unchanged) |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `regressions=0 conversions=0 changes=0` (798 + 5 both modes) | **`regressions=0 conversions=0 changes=2`** (798 + 5 both modes; ibex_tracer d/t 579 -> 13) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **the same; `downstream.csv` byte-identical to the pristine sweep's**; 1 of 805 slang-lane databases moves (ibex_tracer, predicted, IDENTICAL on both) |
| (5) uhdm-cmp | – | every mover keeps its judge status (the histograms above) |
| (6) byteverify (`SELFCHECK=1`, fence-free mirrors `fenced_skipped=8`) | | **11 / 2560 movers: 9 predicted by name, 2 environment draws** ([evidence/sweeps/byteverify.txt](evidence/sweeps/byteverify.txt)); SELFCHECK 2559 / 2560 flagged |

Both sweeps exit 0 (`law index current`). The two surelog csvs differ in exactly the five rows above plus the LowMemLib /
LowMemPkg testflags detail text (the workdir path in Surelog's log line: environment)
([evidence/sweeps/surelog_diff.txt](evidence/sweeps/surelog_diff.txt)); the uhdm2rtlil csvs in the two ibex_tracer rows.

**The SELFCHECK reading 2559 / 2560** is byteverify's negative control working as designed, not a movers line: it
compares every patched database against the PRISTINE copy of ONE fixed path (the first in sort order) and counts the
files that differ; that fixed path's own patched database is byte-identical to its pristine copy (it is not a mover),
so exactly one of the 2560 comparisons reads equal and the control passes at `>= N - 1`. A reading below 2559 would mean
a second database byte-identical to the reference, or a blind comparator.

## 5. The prediction and the attribution of every mover

**The prediction** ([evidence/predicted_movers.txt](evidence/predicted_movers.txt), frozen `chmod 444` at
2026-09-28T18:33:16Z before the law sweep started, md5 in [predicted_frozen_at.txt](evidence/predicted_frozen_at.txt)):
`drivers/census.sh` ran `law12.bin` with `R11U210_TRACE` over every corpus row-mode but the fenced four (the `--filter`
built from the fence), every probe case and every downstream lane; `drivers/censum.py` lists every database a law fired
on: 9 corpus row-modes, 3 probe cases, 1 downstream lane. Every branch of every law traces (the four IA/C/M/W laws one
line per firing; § landingSwitchReach210 has no firing: it never moves a byte without its switch).

| where | moved | predicted | predicted, not moved | moved, not predicted |
|---|---|---|---|---|
| corpus (2560 databases, fence-free mirrors) | 11 | 9 | 0 | Scoreboard d, SimpleUVM d (environment, below) |
| probe (4087) | 3 | 3 | 0 | 0 |
| downstream slang lanes (805) | 1 | 1 | 0 | 0 |

| row-mode / case | change | law, by the firing census |
|---|---|---|
| FuncStructValSimple d/t | `file(39)` / `file(59)` -> **CMP_EQUAL** | § memLeftReadsPatUnlocated210 ×1, § pkgTopWidePatReplTsName210 ×1 |
| FuncStructVal d/t | `endcol(95)` -> `endcol(7)`, `endcol(165)` -> `endcol(10)` | ×17, ×2 (the same two) |
| InterfArrayBind d | `fullname(3)` -> `fullname(1)` | § elabIfArrIdxChainName205 ×2 |
| ibex_tracer d/t (uhdm2rtlil) and its downstream lane | `fullname(579)` -> `fullname(13)`; downstream IDENTICAL -> IDENTICAL | § caseItemImpWildParamScopeName210 ×194, § pkgImpParamMemberColons210 ×26, § pkgImpParamAliasColons210 ×8 |
| BlackBePipeInt d/t | bytes only (`type(1)` / `depth(1)` unchanged) | § pkgImpParamMemberColons210 ×126 |
| 3 probe conversions | section 0 | § caseItemImpWildParamScopeName210 ×1 / ×2 / ×1 |
| **Scoreboard d** | bytes only | no firing: the known svunit listing-order coin (92 ordered uhdm-dump lines, 0 order-blind; the pristine binary draws `24ba24eb` and the law sweep drew `498cfef0`, both seen by pass 207) |
| **SimpleUVM d** | bytes only | no firing: a storage-order draw (0 ordered and 0 order-blind uhdm-dump lines, the same size; the pristine binary's three concurrent determinism runs produce the law sweep's hash `efa957a0`, so the pristine sweep's `09716ef0` was the draw) |

**The CHANGE lines.** Every count shrinks. FuncStructVal's first record stays #747 (the `config_pkg::NOC_TYPE_AXI4_ATOP`
pattern member's span: golden 106:16-28, the qualifier alone, ours the whole name; not reproduced by q01 / q04's typed
enum and stage 1 in an untyped-enum reduction, residue R4); ibex_tracer's first record moves from #2073 (a member full
name) to #27582 (residue R1); InterfArrayBind d's left record is #183 (residue R5).

## 6. Away-moved census, distances, determinism, downstream, byte controls, canaries

**Away-moved-record census** (map 12's method, v11u202's `away.py`; `drivers/awaycorp.sh`; golden, pristine and law
records of every predicted corpus mover as multisets, depth dropped; LOST = in golden and pristine, not in law;
[evidence/away/](evidence/away)): **0 lost records on all 9 movers**; gained FuncStructVal 502 / 826, FuncStructValSimple
39 / 59, InterfArrayBind 2, ibex_tracer 388 / 388 (the member and alias names sit inside canonicalised copies, whose
records carry no full name), BlackBePipeInt 0 / 0 (distance 16907 / 17132 unchanged: every changed name is inside a
canonicalised copy; the uhdm-dump check: 4536 distinct full-name lines written, all present in golden's dump, 4536
removed, none present in golden's). The first law5 draft of § pkgTopWidePatReplTsName210 moved two case records away
(cases/W w01, w03) and was refined before the census (section 3.4).

**Order-blind distance to golden** (`drivers/uvmdist.sh`; [evidence/uvmdist.txt](evidence/uvmdist.txt)), identical in
both sweeps: MiniAmiq 14920, SeqDriver 11094, SimpleUVM 3946, Scoreboard 2937, BuildUVMPkg 1477 per mode (pass 207's
figures reproduce exactly), ApbSlave and SVSwitch 0. No law of this pass reaches the UVM rows.

**Determinism** (`drivers/det.sh law12.bin`: three CONCURRENT harness runs per row-mode;
[evidence/determinism/](evidence/determinism)): **Earlgrey_0_1 default and testflags one hash per mode**; MiniAmiq,
SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg, BlackBePipeInt, FuncStructVal, FuncStructValSimple and InterfArrayBind
one hash per mode. The pristine binary's three runs of SimpleUVM and Scoreboard produce the same hashes as the law
binary's (`efa957a0`, `24ba24eb`): no law adds a coin.

**Downstream** ([evidence/downstream/](evidence/downstream), the gate's `one()` on every grid case, both binaries): the
same verdict on every one of the 28 cases (25 IDENTICAL, c05 and q02 STATUS_DIFF on both, c06 EQUIVALENT on both: pre-existing faces of
the controls); the corpus lanes: `downstream.csv` byte-identical, ibex_tracer's slang database moves and stays IDENTICAL.

**Byte controls** ([evidence/byte_controls/](evidence/byte_controls), `drivers/ctlmove.sh`: every case dir of pass 207's
1760-case list plus r11u207repro, v11u207repro, r11u205dec, r11u208verify, r11u206repro, v11u206repro, r11u204verify
and r11u169repro, 2190 case dirs, both forms, fence-filtered: 0 fenced paths): **movers parse form 4, `--elabuhdm` 2**:
r11u205dec IA/a02 and a05 (parse: the § elabIfArrIdxChainName205 conversions), r11u169repro ml/m18 (`--elabuhdm`
`file(23)` -> **EQUAL**; parse NOT_EQUAL on both, order-blind uhdm-dump 162 -> 158 lines: § memLeftReadsPatUnlocated210)
and r11u195repro P/p13 (NOT_EQUAL on both views and both binaries, order-blind 205 -> 189 lines); **0 worse**. Six case
dirs write no database on either binary (NODB: multi-root cases without an `args` file and four that SLANG_FAIL on both).

**Canaries** ([evidence/canaries_swP.txt](evidence/canaries_swP.txt), [canaries_swL.txt](evidence/canaries_swL.txt)):
`canaries.sh` on the surelog csv reads `ok=43 changed=9` pristine and `ok=41 changed=11` law, the two extra changes
exactly FuncStructVal d/t (the named CHANGE; the nine others compare with the script's own older snapshot and read the
same on both sweeps); uhdm2rtlil `ok=16 changed=0`; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS (`ok=58 changed=0`),
`EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS (`ok=2`).

## 7. Ranked residues and the sister-ground faces (call sites; not edited here)

1. **R1 — ibex_tracer d/t's last 13 records** (#27582..: the module listing's import copy of a struct-pattern parameter,
   its pattern operation's ref_typespec: golden bare, ours `work@ibex_tracer`). Decoded by grid, not written: golden
   names it by the module when the module imports the parameter's home package DIRECTLY (cases/P p01: golden
   `work@dut`, ours bare) and leaves it bare when the parameter reaches the module only through an importing package
   (p05 and ibex_tracer: golden bare, ours `work@dut`); ours is the inverse in both. The ref is named in
   `emitParameters` (ParamEmit, the parameter-Rhs typespec ref of an imported copy: gdb on `law12.bin` over p05 finds the
   module-listing `work@dut` refs written from `emitParameters` and `emitExpr`; the exact site is not pinned); **the
   row reads no other record, so it converts in both modes once this is written** (ground A).
2. **R2 — FuncStructVal's four read-site leftovers** (`INSTR_PER_FETCH` at 618:22-45, `CVA6Cfg.INSTR_PER_FETCH` in the
   popcount override): golden locates this one leftover at the module's read of the member, the eight scratch shapes
   of section 3.3 do not reproduce it (FuncStructValSimple has the same read and is unlocated); undecoded. Count-neutral
   under this pass (the call span was not golden's either).
3. **R3 — the leftover copy of an IMPORTED pattern actual** (cases/M m06 `--elabuhdm`, 24 records): golden's copy's
   ref_typespec reads the importing module (`work@dut`); ours bare. A full-name rule by the caller's module would need
   the caller scope in `stampEvalFuncLeftovers`' stamp (ParamEmit).
4. **R4 — FuncStructVal #747 / #7462**: an untyped-enum member written `config_pkg::NOC_TYPE_AXI4_ATOP` in a wide
   package pattern spans the qualifier in golden (106:16-28); every small shape is either EQUAL (a typed enum: q01, q04)
   or stage 1 (an untyped enum folds to a constant in golden where ours keeps the ref). Then the row's structural record
   #7975 (golden's `NonIdempotentLength` operation, the § r10fsv3 S2 face).
5. **R5 — InterfArrayBind d #183** `peripheral_io_bus[IO_ONES].write_en` at module scope: the instance listing shares
   the definition's continuous-assignment object where golden clones it (pass 207's decode), so § elabIfArrIdxChainName205
   (gated off in the definition emission) cannot reach it: **ModuleEmit `emitContAssigns`, the instance listing (sister)**.
6. **R6 — the module-listing import copy's `'0` constant location** (cases/P p04 `file(3)` after the laws): golden
   locates the copy's `'0` Rhs at its declaration, ours unlocated; past this pass's records.
7. **R7 — cases/M m03** (the builder called from a package localparam): `depth(1)` at the base and after (a structural
   package-caller record, the same face at the base's #491).
8. **Carried, not reached this pass** (the brief's items (1), (3), (4)): SeqDriver #10090 / the N0540 family, N0689,
   the UVM_MACRO_NUMFLAGS ref_typespec names (ModuleEmit importPaCopy82 lists the class copies without their
   ref_typespec), the named call to a later-declared callee (x02) and the parenthesized no-argument call (x01),
   BlackBePipeInt's #15272 tagged-pattern order and the testflags first-listing binding, the written-order and
   cast-width and foreach-this laws' further grids, struct_param_func_config's memberScope names (then its #1364
   structural record), cfg_func_width_loop's stamp, OutputSize's A half (the `Info.x` hier_path at each use, and the
   child's `'1` that golden keeps unsized: a value encoding the plugin reads), the ExprEval value encodings
   (srlgRedIntSyn, r11u204's B3 / N5 / N10), the class_var return predicates (TaskFuncEmit call site), the formal stamp
   in a generate-variable initializer, the module-scope cast, anon_struct_packed_dim's four gx records, and map 12's
   UVM A families (N0290 ... N0397). The r11u211 map landed while this pass ran and was not read.
9. **r11u208's narrow away cell** (two `$unit` typedefs specializing one generic class, § classSpecExprArgUnlocated202):
   golden's second typedef is a Surelog alias defect behind a structural divergence; no gate-able rule, report only.

## 8. Files, and how to reproduce

* `drivers/`: `env.sh` (pins + fence), `case.sh` (judge one case, `ELAB=1` for `--elabuhdm`), `judge.sh`, `grid.sh`
  (`OFFCHECK=1 LAWBIN=law12.bin GRIDBINS="pris.bin law12.bin"`: the `R11U210_OFF=1` byte check), `switchcheck.sh`,
  `switchreach.sh` (section 2.1), `census.sh` + `censum.py` (the firing census), `bvmirror.sh`, `ctlmove.sh` (+
  `ctlbytes.sh`, `ctlsum.py`), `awaycorp.sh` + `away.py`, `uvmdist.sh`, `det.sh` + `detob.sh`, `dscase.py`,
  `rowhead.sh`, `obrow.sh`, `obdist.sh` (copied from pass 207's drivers with this pass's names).
* `cases/`: IA (§ elabIfArrIdxChainName205, i02 § elabIfArrIdxExprChainName210), M (§ memLeftReadsPatUnlocated210; m05
  converts by § pkgTopWidePatReplTsName210), W and Q (§ pkgTopWidePatReplTsName210), C (§ caseItemImpWildParamScopeName210),
  P (§ pkgImpParamMemberColons210, § pkgImpParamAliasColons210).
* `evidence/`: `grid/`, `switchcheck.txt`, `switchreach/`, `predicted_movers.txt` (frozen), `predicted_frozen_at.txt`,
  `sweeps/` (summaries, csv diffs, cmds audit, byteverify; the full sweep csvs are not committed because they list the fenced rows), `away/`, `heads/` (the strict heads of the changed rows
  after the laws), `uvmdist.txt`, `determinism/`, `downstream/`, `byte_controls/`, `canaries_*.txt`.

Reproduce: build `62ac216e` + the patch (`cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON
-DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build build -j 2`), freeze it beside the pristine build in `/tmp/r11u210_bin`
as `law12.bin`, then `bash drivers/grid.sh` (and `ELAB=1`), `bash drivers/switchcheck.sh law12.bin <case dirs>`,
`bash drivers/census.sh <wd> <tr> <prefix>`, `tests/sweep.sh --jobs 3 --workdir <wd>` with `SLANG_UHDM` exported.

## 9. The patch

`/tmp/r11u210.patch` = `git diff 62ac216e` of this worktree: `src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`,
`src/EmitHelpers.h`, `tools/probe/r11u210repro/`, `tests/LAWS.md` (regenerated by `python3 scripts/law_index.py`;
`--check` reads `law index current`). It applies clean on a fresh `62ac216e` worktree, and its src part rebuilt there
reproduces `law12.bin`'s md5 (section 1).
