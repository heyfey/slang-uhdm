# r11u153: second adversarial verification of passes 145 and 146 (verifier)

Base `d10675dd` (branch matrix-1.87). Passes verified: pass 145 (landed at 1fb349a9: seven laws and the
refinement § lpBoundOperandKeepsBase145v of its verifier r11v145) and pass 146 (landed at 3e06cad2: sixteen
laws, including r11u148's three sharing-class laws, and the three refinements of its verifier v11u146).
Read first: tools/probe/r11u145repro, r11v145repro, r11u146repro, v11u146repro and r11u148share.
This pass is a verification pass. The patch holds this directory only. The refinements that fix the
breaks are in [fix.patch](fix.patch), a `git diff d10675dd -- src`, not applied. Nothing under `src/`,
`scripts/`, `results/`, `tests/` or `third_party/` changes. No canonicalisation patch came with the
brief, so `tools/uhdm-strictcmp` is unedited: no case proved a defect in it. The slang-fenced tests are
written `FENCED=` here. Every driver that reads corpus sources, databases or csv rows refuses to run
without `$FENCED` and skips those names.

The four refinements are not landed, so this README and the cases write them `law <name>`, without the
section sign, as r11u148share did. `scripts/law_index.py` therefore indexes no law from this directory
before the refinements land. fix.patch names them with the section sign at their source sites. The
index does read the cases here as evidence cases of the landed laws they name, so `tests/LAWS.md` is
regenerated when this patch lands. tests/ is outside this deliverable.

## Verdict

**Four breaks were found.** In each, a landed law moves a field AWAY from golden on legal SystemVerilog,
in shapes the implementers' and verifiers' grids did not contain. Each break is refined behind its own
switch in `fix.patch`. `R11U153_OFF=1` gives the landed bytes on all 179 cases.

| break | law | shape | axis | refinement (switch) |
|---|---|---|---|---|
| B1 | § tpDefaultCaLhsUnparented146 | a type-parameter-typed net DECLARED IN A GENERATE BLOCK, written by a plain continuous assignment (`if (1) begin : g T w; assign w = i; end`) | **strict records**: `tn/j03` #10 and #51 and `tn/j12` #10 and #68 go from equal to `fullname` (golden `<in>T.W`, law empty); the verdict goes from `line` to `fullname` | law tpDefaultCaGenLocalLhsKeeps153v (`R11U153_TPCAGEN_OFF`) |
| B2 | § tfArgTypedefLastWriter146 | a subroutine whose `export "DPI-C"` declaration PRECEDES its definition (package function, module function, package task) | stage-1 cells (ours does not model DPI export): 7 to 12 enum_typespec spans per case move from golden's own typedef span to the argument token (depth-blind dump: 14 to 22 lines away, 0 to 2 toward) | law tfArgDpiExportFirstNoWrite153v (`R11U153_TFARGDPIEXP_OFF`) |
| B3 | § hpBaseSelOpIdxNamesByPath145 | a path with an operation base index INSIDE a whole-variable simple part-select's range bound (`i[P[D-1].w-1:0]`, `i[P[D-1].w:0]`, in a process too) | stage-1 cells (struct-array parameter): golden `work@dut.i.D` (the bound's base naming), law `work@dut.i.P[D - 1].w.D` (4 lines away, 0 toward, 5 cases) | law psRangeBoundHpBaseSelKeeps153v (`R11U153_PSRBASESEL_OFF`) |
| B4 | § defaultFillImportCopies145 | a package `'{default: X}` parameter of any integral element type other than `int` (byte, shortint, longint, integer, `logic [31:0]`, `bit [7:0]`, `logic [3:0]`, packed struct) | stage-1 cells: golden does not expand these at all (CompileHelper.cpp:3401 `baseType == uhdmint_typespec`); the law mints one constant per element on our (pre-existing) expansion, +6 to +10 dump lines per case. This is r11v145's residue V1, generalised and decoded | law defaultFillImportIntOnly153v (`R11U153_DFIINT_OFF`) |

Only B1 is visible to the strict walk. B2, B3 and B4 sit on cells that uhdm-cmp already rejects (stage 1)
on both binaries. The earlier verifiers counted those as breaks too (v11u146's DPI-import cases a2 and
a15, and r11v145's Rggen names past the walk divergence), so they are counted the same way here. None
of the four shapes occurs in the gate. The refined binary moves no probe case and no uhdm2rtlil
database. It moves four surelog databases, all UVM order coins (section 2, measurement of the refined binary).

**Composition.** The two landings compose cleanly. Every claimed conversion belongs to its landing:
- 50 are pass 145's alone.
- 70 are pass 146's alone.
- One is joint (BasicOh/testflags). At integration, the pass-146 landing commit baselined it as its
  71st conversion.

No conversion depends on two laws cancelling each other's error: on the four joint rows, record by
record, no record that either landing alone makes wrong was right with both off (section 3).

**Unmaskings.** Every changed non-converted row was checked record by record: 42 for pass 145, 111 for
pass 146. No row moves its first difference earlier. No record before both walks diverge becomes newly
wrong. `r10v200repro/v200_5_modmat` (`fullname 2 -> 3`) keeps its first record (#59) and diverges at
#77 instead of #66, with 0 depth-blind dump lines lost to golden: an unmasking (section 4).

**Fence.** No law, case or number of pass 146 rests on the fenced head. The two laws nearest to that
test's shapes were re-derived from 26 fresh cases and Surelog's source (section 8). Two findings on
the drivers:
- r11u146repro's `newdiffs.sh` refuses to run without `$FENCED`, but does not skip a fenced name it is
  given.
- Nine drivers do not check `$FENCED` at all: three of r11u146repro and six of v11u146repro. They read only
  cases, probe databases or csv rows, or wrap the whole gate.

The claim that every driver refuses to run without `$FENCED` and skips those names is therefore not
exactly true. No corpus read depends on either gap.

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u153_bin/pris.bin` | `0a647f63db9a3a6b6811c14d2c10f4e3` | worktree `/tmp/wt_r11u153` at d10675dd, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` (the landed binary) |
| `/tmp/r11u153_bin/fix.bin` | `1b89f73ee8704d8bb4979a668115366c` | d10675dd + `fix.patch` (`fix.patch` md5 `01be4c45f959de83b4e9247fe861be1f`, applies clean on a fresh d10675dd; the final comment-only edit rebuilds to the same md5) |
| `/tmp/r11u153_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator (worktree build = main tree build) |

Sweeps use `tests/sweep.sh --jobs 3` through `drivers/sweep.sh` (all four stages) and `drivers/sweepc.sh`
(probe and both corpora). The workdirs are `/tmp/r11u153_sw{P,F,A,B,O}`, all names the same length.
Every `cmds.txt` names its binary by path: 3273 of 3323 in each sweep. The other 50 rows are
Surelog-only.

| sweep | binary + switches | probe | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|---|
| P (landed) | pris.bin | EQUAL 2390 / 1697; 0/0/0 | 406 + 405 CMP_EQUAL; 0/0/0 | 714 + 714; 0/0/0 | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2; 0 of 871 rows differ from `results/downstream_uhdm2rtlil.csv` |
| F (fix) | fix.bin | EQUAL 2390 / 1697; 0/0/0 | 406 + 405; 0/0/0 | 714 + 714; 0/0/0 | 803 / 66 / 2; 0 of 871 rows differ from P |
| A (pass 145 off) | pris.bin `R11U145_OFF R11V145_LPOPND_OFF` | 2346; regressions 44, changes 4 | 405 + 403; regressions 3, changes 10 | 712 + 712; regressions 4, changes 28 | not run |
| B (pass 146 off) | pris.bin `R11U146_OFF R11U148_OFF R11V146_{TFARGDPI,TFARGALIAS,TPCALHSIF}_OFF` | 2352; 38, 66 | 400 + 398; 13, 17 | 704 + 704; 20, 28 | not run |
| O (both off) | pris.bin, all of the above | 2308 / 1779; 82, 70 | 399 + 397; 15, 24 | 702 + 702; 24, 56 | 803 / 66 / 2; 0 of 871 rows differ from P |

(The pairs of numbers are `regressions, changes` against the committed baselines; conversions read 0
in every sweep. A, B and O are red by construction, since the landings' conversions revert. In P and F
the only red line is `law index STALE`. That is the environment: a tree checked out at a commit reads
its own commit as missing, and v11u146 noted the same.)

## 2. The breaks, decoded and refined

### B1 § tpDefaultCaLhsUnparented146 — a generate-local net of the type parameter's type

The PRODUCER is Surelog, UhdmWriter.cpp:2295: `if (tps != nullptr) const_cast<typespec*>(tps)->VpiParent(nullptr);`. `tps` comes from
`m_helper.bindVariable(mod, m, lhs->VpiName(), ...)` (UhdmWriter.cpp:2123), and that overload
(CompileStmt.cpp:3095-3156) walks the scope chain:
- it reads function, task and begin variables, and `module_inst` Variables and Nets;
- it passes a `gen_scope` by through `default`, then to its parent.

So a net DECLARED in a generate block is never found, `tps` stays null, and the default's bound references keep
their names. The law's `bodyHits` scan counted every plain-name Lhs typed by the parameter, including one
declared in the generate block.

| case | law off | landed | refined |
|---|---|---|---|
| `tn/j03_gen_local_net` (`if (1) begin : g T w; assign w = i; ...`) | STRICT_NOTEQUAL `line` (#88, a pre-existing face) | STRICT_NOTEQUAL `fullname`: #10 and #51 move from equal to golden `<in>T.W` against ours empty | = law-off bytes |
| `tn/j12_genfor_local_net` (the same in a generate-for) | `line` | `fullname`: #10 and #68 move away | = law-off bytes |
| `tn/j13_genlocal_and_module_ctl` (control: the same body plus a module-level `assign o = g.w`) | `fullname` | `line` (8 records toward) | = landed bytes (the module-level Lhs still fires) |

Refinement **law tpDefaultCaGenLocalLhsKeeps153v** (TypeEmit.cpp `tpDefaultCaLhsUnparented146`, the `bodyHits`
scan): only a Lhs whose symbol is declared in the instance body itself counts. Switch `R11U153_TPCAGEN_OFF`.

### B2 § tfArgTypedefLastWriter146 — `export "DPI-C"` before the definition

Golden, read from uhdm-dump (`drivers/case.sh`; scratch grid `/tmp/r11u153_scr/dpix`, cases `fa/g09`, `g15` to `g18`):

| shape | golden enum typedef span | law |
|---|---|---|
| package: `export "DPI-C" function f;` then `function automatic int f(e_t z)` (g09) | the typedef's own `3:1-3:40` in every listing | moved to the argument token `5:26-5:29` (10 objects) |
| module: the same (g15) | own span `2:1-2:40` (7 objects) | `4:26-4:29` |
| package task: `export "DPI-C" task t;` before `task automatic t(input e_t z)` (g16) | own span | moved |
| export AFTER the definition (g17, control) | argument token `3:26-3:29` | moved (right) |
| export of ANOTHER subroutine (g18, control) | argument token | moved (right) |

Decode:
1. `compileFunction` (CompileStmt.cpp:2316-2375) runs twice. In the FUNCTION collect pass it makes a
   placeholder only when no subroutine of that name exists yet.
2. The export's prototype (CompileStmt.cpp:2631 compileFunctionPrototype, CompileModule.cpp:1181 /
   CompilePackage.cpp:288) creates that object first. So the definition's first pass finds it and
   compiles the ports into it at once (golden's function object sits on the EXPORT line, 3:1-3:27, with
   the definition's io_decl).
3. That port compile runs before the typedef declaration's own compile re-populates the typedef's span,
   so the argument's `populateCoreMembers` (CompileStmt.cpp:1809) is overwritten.

Refinement **law tfArgDpiExportFirstNoWrite153v** (UhdmExporter.cpp, the § tfArgTypedefLastWriter146 walk): a
function or task declaration preceded, in the same parent, by a `DPIExport` naming it writes nothing.
Switch `R11U153_TFARGDPIEXP_OFF`.

### B3 § hpBaseSelOpIdxNamesByPath145 — a path inside a simple part-select's range bound

| case | golden name of `D` | law off | landed |
|---|---|---|---|
| `bso/h07` `i[P[D-1].w-1:0]` | `work@dut.i.D` | `work@dut.i.D` | `work@dut.i.P[D - 1].w.D` (away) |
| `bso/h09` the same in `always_comb` | `work@dut.i.D` | same | away |
| `bso/h11` `i[P[D-1].w:0]` (the path IS the bound) | `work@dut.i.D` | same | away |
| `bso/h14` a literal-initialised struct-array parameter | `work@dut.i.D` | same | away |
| `xg/x03` a declaration range + the same select | `work@dut.i.D` | same | away |
| `bso/h08` `i[P[D-1].w]` (bit-select index, control) | `work@dut.i.P[D - 1].w.D` | `work@dut.i.D` | toward (kept) |
| `bso/h12` `i[P[D-1].w-4 +: 2]` (indexed base, control) | `work@dut.i.P[D - 1].w.D` | `work@dut.i.D` | toward (kept) |
| `bso/h10` `o = P[D-1].w` (rvalue, control) | `work@dut.P[D - 1].w.D` | `work@dut.D` | toward (kept) |

All are stage-1 cells (a struct-array parameter). No strict-comparable shape of this kind was found:
`b[D-1].W` on an interface array is rejected by slang (h15).

Refinement **law psRangeBoundHpBaseSelKeeps153v** (ExprEmit.cpp, both `baseSelOpIdxNames145` call sites): the
renaming is skipped while `inPsRangeBound` (a whole-variable simple part-select's bound) is raised.
Switch `R11U153_PSRBASESEL_OFF`.

### B4 § defaultFillImportCopies145 — a non-`int` element (r11v145's V1, generalised and decoded)

Surelog's CompileHelper.cpp:3358-3408 (`vpiAssignmentPatternOp` with a `default` tagged_pattern) builds the
`array_expr`, pushing the one constant `c` once per element, only `if (baseType == uhdmint_typespec)`. Every other
element type keeps the operation with its tagged_pattern.

Measured on 13 element types (scratch `/tmp/r11u153_scr/dfiv`):
- The array_expr is built for `int`, `int signed`, `int unsigned` and a typedef of `int`.
- It is not built for `byte`, `shortint`, `longint`, `integer`, `logic [31:0]` or `bit [7:0]`,
  nor for r11v145's `logic [3:0]` and packed struct.

Our expansion guard (ParamEmit.cpp, `isIntegral()`) is wider. On those shapes the law mints one copy
per element of an object golden does not have: +8 to +10 dump lines on `dfi/d05`, `d06`, `d07`, `d10`,
`r11v145repro/dfi/x03` and `x06`.

Refinement **law defaultFillImportIntOnly153v** (ParamEmit.cpp, beside `share145`): mint per element only for an
`int` element. Switch `R11U153_DFIINT_OFF`. What is left is the expansion itself on non-`int` elements
(residue N1, section 7). The refinement restores the pristine bytes there and keeps every `int`
conversion: i01, i02, x07, d01 to d04, d08, d09 unchanged.

### Measurement of the refined binary (fix.bin)

* **Gate sweep F** (all four stages): probe, surelog and uhdm2rtlil all read `regressions=0 conversions=0
  changes=0`. Downstream is 803 / 66 / 2, and its csv is identical to P on all 871 rows.
* **Byte movers against P** (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`,
  `evidence/byteverify_fix_vs_landed_*.txt`):
  * surelog: 4 of 960 movers, path sets identical, selfcheck 959 / 960. The four are MiniAmiq/default,
    SeqDriver/default, SeqDriver/testflags and SimpleUVM/testflags. Each reads exactly the known
    4-line `UINT` / `vpiDecompile` order coin in an order-blind path-normalised dump, so none is a
    law mover.
  * uhdm2rtlil: 0 of 1608 movers (selfcheck 1607 / 1608).
  * probe: 0 of 4087 databases move.
* **Prediction by name** (`drivers/predict.py` on P's sources before the byte comparison, fail-closed;
  `evidence/predict_corpus.tsv`, `evidence/predict_probe.tsv`): 245 row-modes and 94 probe cases carry a
  face. All four movers are predicted (the UVM rows carry `DFIINT,DPIEXP,TPCAGEN`).
* **Canaries** (`evidence/canaries.txt`): surelog `ok=52 changed=0`, uhdm2rtlil `ok=16 changed=0`; both
  ctcan2 runs PASS (`EXPECT_UNKNOWN=1`, `EXPECT_UNKNOWN=6`). P reads the same.
* **uhdm-cmp**: every probe case and corpus row keeps its judge status. Every case keeps its uhdm-cmp
  line count (`evidence/fixcheck_all.tsv`).
* **Cases** (`evidence/fixcheck_all.tsv`, 179 cases): fix.bin moves 15 cases, the 14 break cases and
  `bso/h16`. In h16 golden folds `$bits`, so neither name is in golden and the move is neutral. On all
  179, `R11U153_OFF=1` gives the landed bytes. On the 14 break cases the refined bytes equal the parent
  law's switched-off bytes.
* **Earlier grids** as byte controls (`drivers/bytes.sh`, `evidence/bytes_landed_grids.txt`, 583 cases of
  r11u145repro, r11v145repro, r11u146repro, v11u146repro, r11u148share, r11u149verify, r11u151struct):
  - 2 movers, both r11v145's V1 cases (`dfi/x03` and `dfi/x06`, dump distance -10 and -6 toward golden).
  - `v11u146repro/cases/hp/h2_genblk` writes no database on any binary (slang rejects it), so it is
    not a mover.
  - `R11U153_OFF=1` equals the landed bytes on every case.

## 3. Composition of the two landings (`drivers/compose.py`, `evidence/composition_rows.tsv`)

The census covers the four sweeps P (both on), A (pass 145 off), B (pass 146 off) and O (both off),
on every row whose status or strict cell differs anywhere among them. It is fail-closed.

| corpus | conversions (row enters equal) | pass 145 alone | pass 146 alone | joint | other changed rows |
|---|---|---|---|---|---|
| probe | 82 | 44 | 38 | 0 | 70 (4 by pass 145, 65 by pass 146, 1 SUSPECT = v200_5_modmat, section 4) |
| surelog | 15 | 2 (DefaultPatternInt d/t) | 12 (ExplictiPorts d/t, PortExpr d/t, FuncCase d/t, IOClassStruct d/t, InterfArrayBind t, PortInitVal d, PortInitVal2 d/t) | **1 (BasicOh/testflags)** | 24 (7 by 145, 14 by 146, 3 joint: BasicOh d, Scr1SvTests d/t) |
| uhdm2rtlil | 24 | 4 (ibex_counter d/t, packed_struct_array_shift d/t) | 20 (the ten tests of pass 146's table, both modes) | 0 | 56 (28 + 28) |

* **Every claimed conversion is its landing's.** The name sets equal the CONVERSION lines of
  r11u145repro/evidence/sweep_law_vs_baselines.txt (50) and r11u146repro/evidence/sweep_law.txt (70):
  0 differences. BasicOh/testflags is the one conversion neither pair claimed. Pass 145 took it from 22
  to 2 differing objects, the pass-146 landing commit found it at 0 and baselined it (its 71st
  conversion), and it needs both landings.
* **No cancelling pair** (`drivers/joint.py`, `evidence/joint_rows.txt`). For each joint row, the sets of
  differing strict records before any walk divergence, golden against each sweep, satisfy D_A and D_B
  subsets of D_O, and D_P a subset of D_A and D_B. No landing alone makes a record wrong that was right
  with both off.

| row | records < first divergence | D_O | D_A (146 alone) | D_B (145 alone) | D_P | fixed by 146 alone | fixed by 145 alone | overlap |
|---|---|---|---|---|---|---|---|---|
| BasicOh/testflags | 3838 | 22 | 20 | 2 | **0** | 2 | 20 | 0 |
| BasicOh/default | 4011 | 51 | 49 | 31 | 29 | 2 | 20 | 0 |
| Scr1SvTests/default | 16033 | 227 | 223 | 223 | 219 | 4 | 4 | 0 |
| Scr1SvTests/testflags | 16033 | 227 | 223 | 223 | 219 | 4 | 4 | 0 |

* **The cross-ground pairs of the brief**, each on fresh cases (tables in section 5):
  * **§ defaultFillImportCopies145 with § evalFuncSelectKeepsCall148.**
    - `e148/q08_default_fill_module`, a module-local fill read by a callee: E148 converts it, DEFFILLIMP
      does not fire.
    - `e148/q05_default_fill_import`, an imported fill read by a callee: DEFFILLIMP moves it toward
      golden (`depth` -> `type`). E148 does not fire (the base is a package parameter), and golden keeps
      the call (residue N2).
    - Single-switch runs: each law owns its own bytes, and the both-off bytes equal the DEFFILLIMP-off
      bytes on q05 and the E-off bytes on q08.
  * **§ psBoundBareRefByBase145 with § modArrayBoundRefArrayPath146.** `xg/x01` (`sub u[N-1:0](.a(a[H:L]))`)
    and `xg/x02` (`u[N-1:M](.a(a[N-1:M]))`): both stage-1, both move toward golden only (depth-blind 0 away,
    4 and 8 toward).
  * **§ constPathBaseAnyKind146 with § hpBaseSelOpIdxNamesByPath145.**
    - `xg/x03` (a struct-array parameter path in a declaration range and a part-select bound): break
      B3, refined.
    - `xg/x04` (an interface port's struct array indexed by `b.W-1`): stage-1, the laws do not fire.
    - `hp/p08` (`$bits(sd[D-1].r)` in a declaration range): toward only.

## 4. The unmaskings (`drivers/unmask.py`, `evidence/unmask14{5,6}_first_pass.tsv`, `unmask14{5,6}_recheck.tsv`)

Every non-converted row whose status or strict cell a landing changes (census classes ONLY145, ONLY146,
JOINT and SUSPECT) is compared OFF against ON:
- pass 145: sweep A -> P, 42 row-modes and probe cases;
- pass 146: sweep B -> P, 111.

The measures, each golden against each sweep:
* **first**: the index of the first differing strict record. It must not move earlier.
* **newpre**: records ON gets wrong that OFF got right, before either walk diverges. It must be 0.
* **div**: the walk divergence index.
* **the depth-blind order-blind uhdm-dump multisets** (golden, OFF, ON), which see past the divergence and
  past stage 1. `obaway` counts the golden-mismatching lines ON has that OFF did not. `lost` counts the
  golden lines OFF matched that ON no longer matches, which is a right-to-wrong move.

An unmasking reads newpre 0, first not earlier, and lost 0.

| landing | rows | first moves LATER | first SAME | first EARLIER | newpre > 0 | obaway = 0 | obaway > 0 but lost = 0 | lost > 0 |
|---|---|---|---|---|---|---|---|---|
| pass 145 | 42 | 14 | 28 | **0** | **0** | 39 | 1 (YosysBigSimEllip/default: 4704 lines replace other wrong lines of the same objects, 5480 toward) | 2 (int_types d/t: 4 lines, all in the weaklyReferenced tail, N10) |
| pass 146 | 111 | 68 | 43 | **0** | **0** | 90 | 21 (15 probe cases, arb_idx_cast, gen_scope_numports, packed_array_reset_loop d/t: 1 to 52 lines each, a wrong value replacing another wrong value) | **0** |

* **`r10v200repro/v200_5_modmat`** (the brief's `fullname 2 -> 3`): first record #59 on both, newpre 0.
  The walk divergence moves from #66 to #77. Depth-blind dump: 0 lines away and 0 lost. It is the class-I
  unmasking r11u148 documented: the extra differing record is an object that already differed, now
  reached by the walk.
* The implementer's "22 corpus + 54 probe LATER" list was taken at pass 146's own base b2199096. At
  d10675dd, the same machinery reads 68 LATER of 111 against B, and every one satisfies the three
  conditions above.
* Earlgrey_0_1/default read `obaway 5210` on the first pass. That was a partial dump: the run overlapped
  another session's Earlgrey dumps. Re-run alone, it reads `obaway 0, obtoward 212, lost 0`
  (`unmask146_recheck.tsv`). The first-pass file is kept as measured.
* int_types (pass 145, § unsignedScalarParamTsAtKeyword145) is not an unmasking and not a break.
  Golden's weaklyReferenced tail holds four `reg unsigned` localparam typespec copies at the whole span
  4:20-4:32. The main tree holds 20 at the keyword. Ours has no such tail copies, and law-off's
  whole-span values matched them by coincidence. The walk improves by 12 objects with newpre 0, and the
  plugin never reads the tail.

## 5. Downstream

* **The converted uhdm2rtlil rows, by bytes** (sweep P's downstream workdir, `<test>/{surelog,slanguh}/`).
  For all 13 converted tests, not three per pass: `<test>.il`, `<test>_nohier.il` and `<test>_synth.v`
  are byte-identical between the Surelog lane and the slang lane (`evidence/downstream_bytes_converted.txt`).
  * pass 145: ibex_counter (4588 / 6164 / 18648 B), packed_struct_array_shift, comb_dyn_2d_packed_sel.
  * pass 146: FunctionParam, SelectGivenBySelectOnParameterInFunction, SumOfParametersInNestedForLoops,
    func_local_array, genvar_iface_struct, param_name_collision_typeparam, port_chained_type_param,
    sat_asserts_seq, simple_package (4055 / 9982 / 33731 B), typed_named_pattern.

  Their fresh rows (P): `ibex_counter,IDENTICAL,OK,OK,129,129,,`,
  `packed_struct_array_shift,IDENTICAL,OK,OK,54,54,,`, `comb_dyn_2d_packed_sel,IDENTICAL,OK,OK,124,124,,`,
  `simple_package,IDENTICAL,OK,OK,180,180,,`, `genvar_iface_struct,IDENTICAL,OK,OK,20,20,,`,
  `sat_asserts_seq,IDENTICAL,OK,OK,4,4,,`. The other seven read `IDENTICAL,NO_GATES,NO_GATES,0,0,,`.
* **The whole downstream csv** is identical on all 871 rows across P, O (both landings off) and F (fix).
  The landings convert strict cells, never a downstream verdict.
* **The cases** (`drivers/dsgrid.py`, `evidence/downstream_cases.tsv`, 179 cases × {law off, landed, fix}):
  * 17 cases move to IDENTICAL under the laws: `e148/q03` DIVERGENT -> IDENTICAL; 16 EQUIVALENT ->
    IDENTICAL (`e148/q08`, the escaped-identifier cases y01, y02, y03, y05, y06, y10, y11, y12, y17, y18
    and y19, and `ucp/v01`, v03, v04 and v05).
  * None leaves IDENTICAL.
  * The fix binary's verdict equals the landed binary's on all 179.
  * Not IDENTICAL on every binary (the residues of section 7): 16 DIVERGENT, 11 EQUIVALENT,
    1 SLANG_REJECT, 3 SURELOG_FAIL.

## 6. The break grid: 179 fresh cases, per law

The shapes are new to all five grids of the landings (r11u145repro, r11v145repro, r11u146repro,
v11u146repro, r11u148share). They cover:
- declaration forms: ANSI and non-ANSI, body, localparam, multi-declarator, packed/unpacked, typedef
  chains;
- nesting: generate-if and generate-for, case-generate, named blocks, classes, interfaces, modports,
  programs;
- packages: import forms, `$unit`, include files, macros;
- parameterised instances and overrides;
- escaped identifiers in every position: function, enum literal, struct member, generate label, port
  connection, class member, include file, parameter, after a macro call, after a string, and names
  outside Surelog's pp rule;
- DPI imports and exports, and alias chains;
- 20 `--elabuhdm` cases;
- the three cross-ground pairs (`xg/`, `e148/q05`, `e148/q08`, `hp/p08`).

Goldens are from the pinned Surelog with check_probe's arguments. Each case is scored with its law OFF
(the law's own switch; a refinement's parent switch) against the landed binary:
- the strict records, index-aligned before either walk diverges: `away` counts records the law makes
  wrong that off had right, `toward` the reverse;
- the depth-blind order-blind uhdm-dump multiset, which sees past stage 1 and past the walk;
- the uhdm-cmp line count;
- the downstream verdict.

A BREAK is a field the law moves away from golden on legal SV.

slang-uhdm's exit code is the same on every binary and switch, and it is 0 except in these cases:
- `ucp/v01`-`v05` exit 4: the "unsupported constructs" exit, which still writes a database that is
  judged like any other.
- `bso/h15` and `pe/r02` exit 3: slang rejects them. Surelog also fails `pe/r02`.
- `esc/y16` exits 134: an uncaught `std::runtime_error` (`source:1:3: error: expected '('` while
  re-parsing the escaped name `W#1`), under every switch. Surelog fails there too, so there is no golden
  (residue N11).
- `esc/y15`: Surelog fails and slang does not.

The laws change one uhdm-cmp line count, `e148/q06_elab` 34 -> 0: § evalFuncSelectKeepsCall148 takes a
stage-1 `--elabuhdm` case to STRICT_EQUAL. No count grows. The fix changes none.

| law | cases naming it | law moves bytes | converted to STRICT_EQUAL | breaks | moved by fix.patch |
|---|---|---|---|---|---|
| § castKeyElabNetNoFile146 | 5 | 3 | 2 | 0 | 0 |
| § classTdStructMemberPkgPath146 | 5 | 5 | 3 | 0 | 0 |
| § constPathBaseAnyKind146 | 10 | 6 | 2 | 1 | 1 |
| § defaultFillImportCopies145 | 7 | 7 | 5 | 1 | 1 |
| law defaultFillImportIntOnly153v | 6 | 6 | 0 | 4 | 4 |
| § escIdPpColumnShift146 | 19 | 15 | 12 | 0 | 0 |
| § evalFuncSelectKeepsCall148 | 8 | 6 | 5 | 0 | 0 |
| § genLpUintCaRhsOwnCopy148 | 5 | 5 | 3 | 0 | 0 |
| § hpBaseSelOpIdxNamesByPath145 | 19 | 15 | 4 | 5 | 6 |
| § impElabArithWholeSpan145 | 5 | 5 | 3 | 0 | 0 |
| § lpBoundOperandKeepsBase145v | 4 | 2 | 0 | 0 | 0 |
| § lpPaCopyBoundOwnerName145 | 3 | 1 | 1 | 0 | 0 |
| § modArrayBoundRefArrayPath146 | 8 | 6 | 3 | 0 | 0 |
| § pkgTfSigRangeTopViewConst148 | 5 | 4 | 4 | 0 | 0 |
| § portExprElabDefNets146 | 7 | 5 | 4 | 0 | 0 |
| § portExprOperandAtExpr146 | 7 | 5 | 4 | 0 | 0 |
| § portInitAssignAtHeader146 | 6 | 6 | 1 | 0 | 0 |
| § psBoundBareRefByBase145 | 10 | 9 | 5 | 0 | 0 |
| law psRangeBoundHpBaseSelKeeps153v | 4 | 4 | 0 | 4 | 4 |
| § tfArgAliasEndFollows146v | 2 | 2 | 0 | 0 | 0 |
| law tfArgDpiExportFirstNoWrite153v | 5 | 5 | 0 | 3 | 3 |
| § tfArgDpiNoWrite146v | 2 | 2 | 0 | 0 | 0 |
| § tfArgTypedefLastWriter146 | 10 | 10 | 4 | 1 | 1 |
| law tpDefaultCaGenLocalLhsKeeps153v | 3 | 3 | 0 | 2 | 2 |
| § tpDefaultCaIfaceKeeps146v | 3 | 0 | 0 | 0 | 0 |
| § tpDefaultCaLhsUnparented146 | 10 | 7 | 4 | 2 | 2 |
| § typeParamStructAtKeyword146 | 6 | 3 | 2 | 0 | 0 |
| § ucpIfaceInstElabShape146 | 5 | 5 | 0 | 0 | 0 |
| § unaryOperandParamOwnerName145 | 6 | 5 | 2 | 0 | 0 |
| § unnamedConcatIfaceAnchor146 | 5 | 5 | 0 | 0 | 0 |
| § unsignedScalarParamTsAtKeyword145 | 7 | 6 | 4 | 0 | 0 |
| **total (179 cases)** | | 143 | 72 | 14 | 15 |

Per-case tables (`drivers/tables.py`; "records" = strict records away/toward, "-" on a stage-1 cell; "depth-blind dump" = order-blind uhdm-dump lines away/toward; "fix" = the refined binary against the landed bytes):

#### § castKeyElabNetNoFile146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `ck/k01_ca_pattern` | stage-1 -> stage-1 | 560 / 560 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `ck/k02_default_key` | stage-1 -> stage-1 | 17 / 17 | - | 0/0 | DIVERGENT | same | law does not fire (bytes equal) |
| `ck/k03_nested_struct` | stage-1 -> stage-1 | 17 / 17 | - | 0/0 | IDENTICAL | same | toward (or neutral) |
| `ck/k04_elab` | NE file -> EQUAL | 0 / 0 | 0/2 | 0/0 | IDENTICAL | same | toward (or neutral) |
| `ck/k05_module_typedef` | NE file -> EQUAL | 0 / 0 | 0/2 | 0/0 | IDENTICAL | same | toward (or neutral) |

#### § classTdStructMemberPkgPath146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `ct/m01_packed_member_arg` | stage-1 -> stage-1 | 222 / 222 | - | 0/8 | IDENTICAL | same | toward (or neutral) |
| `ct/m02_array_member` | stage-1 -> stage-1 | 20 / 20 | - | 0/8 | IDENTICAL | same | toward (or neutral) |
| `ct/m03_two_classes` | NE fullname -> EQUAL | 0 / 0 | 0/0 | 0/8 | IDENTICAL | same | toward (or neutral) |
| `ct/m04_derived` | NE fullname -> EQUAL | 0 / 0 | 0/0 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `ct/m05_module_import` | NE fullname -> EQUAL | 0 / 0 | 0/0 | 0/4 | IDENTICAL | same | toward (or neutral) |

#### § constPathBaseAnyKind146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `hp/p01_modport_port` | NE col -> EQUAL | 0 / 0 | 0/1 | 0/2 | IDENTICAL | same | toward (or neutral) |
| `hp/p02_case_generate` | NE col -> NE col | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `hp/p03_genfor_bound` | NE col -> NE col | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `hp/p04_iface_struct_param` | stage-1 -> stage-1 | 11 / 11 | - | 0/2 | IDENTICAL | same | toward (or neutral) |
| `hp/p05_struct_port_base_ctl` | stage-1 -> stage-1 | 60 / 60 | - | 0/0 | EQUIVALENT | same | law does not fire (bytes equal) |
| `hp/p06_elab` | NE col -> EQUAL | 0 / 0 | 0/1 | 0/2 | IDENTICAL | same | toward (or neutral) |
| `hp/p07_pkg_param_own_pkg_func` | stage-1 -> stage-1 | 17 / 17 | - | 0/8 | IDENTICAL | same | toward (or neutral) |
| `hp/p08_x_basesel_op` | stage-1 -> stage-1 | 100 / 100 | - | 0/4 | IDENTICAL | same | toward (or neutral) |
| `xg/x03_param_struct_arr_bound` | stage-1 -> stage-1 | 116 / 116 | - | 4/0 | EQUIVALENT | MOVES | **BREAK** (refined) |
| `xg/x04_iface_port_basesel` | stage-1 -> stage-1 | 156 / 156 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |

#### § defaultFillImportCopies145

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `dfi/d01_always_read` | NE depth -> EQUAL | 0 / 0 | 0/0 | 0/24 | IDENTICAL | same | toward (or neutral) |
| `dfi/d02_two_modules` | NE depth -> EQUAL | 0 / 0 | 0/0 | 0/24 | IDENTICAL | same | toward (or neutral) |
| `dfi/d03_interface_import` | NE depth -> EQUAL | 0 / 0 | 0/0 | 0/12 | IDENTICAL | same | toward (or neutral) |
| `dfi/d04_elab` | NE depth -> EQUAL | 0 / 0 | 0/0 | 0/12 | IDENTICAL | same | toward (or neutral) |
| `dfi/d05_byte_elems` | stage-1 -> stage-1 | 24 / 24 | - | 9/3 | EQUIVALENT | MOVES | **BREAK** (refined) |

#### law defaultFillImportIntOnly153v

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `dfi/d06_shortint` | stage-1 -> stage-1 | 24 / 24 | - | 8/4 | EQUIVALENT | MOVES | **BREAK** (refined) |
| `dfi/d07_logic32` | stage-1 -> stage-1 | 72 / 72 | - | 8/4 | EQUIVALENT | MOVES | **BREAK** (refined) |
| `dfi/d08_int_sized_ctl` | stage-1 -> stage-1 | 28 / 28 | - | 6/6 | IDENTICAL | same | no break: stage-1 int element: expanded in golden, wrong -> other wrong |
| `dfi/d09_typedef_int_ctl` | stage-1 -> stage-1 | 40 / 40 | - | 0/12 | IDENTICAL | same | toward (or neutral) |
| `dfi/d10_integer` | stage-1 -> stage-1 | 24 / 24 | - | 8/4 | EQUIVALENT | MOVES | **BREAK** (refined) |

#### § escIdPpColumnShift146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `esc/y01_func_name` | stage-1 -> stage-1 | 17 / 17 | - | 4/86 | EQUIVALENT -> IDENTICAL | same | no break: stage-1; every moved column now equals golden's; ours holds more copies (count) |
| `esc/y02_enum_literal` | NE endcol -> EQUAL | 0 / 0 | 0/30 | 0/72 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `esc/y03_struct_member` | NE endcol -> NE col | 0 / 0 | 0/40 | 4/118 | EQUIVALENT -> IDENTICAL | same | no break: end columns now golden's; the escaped member's START (golden 5:12, the path start) is a residue |
| `esc/y04_genblk_label` | NE col -> EQUAL | 0 / 0 | 0/8 | 0/28 | IDENTICAL | same | toward (or neutral) |
| `esc/y05_include` | NE col -> EQUAL | 0 / 0 | 0/16 | 0/48 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `esc/y06_plain_escaped` | NE col -> EQUAL | 0 / 0 | 0/16 | 0/48 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `esc/y07_block_comment_ctl` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `esc/y08_port_conn` | NE col -> EQUAL | 0 / 0 | 0/13 | 0/38 | IDENTICAL | same | toward (or neutral) |
| `esc/y09_line_comment_ctl` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `esc/y10_after_macro_call` | NE col -> EQUAL | 0 / 0 | 0/12 | 0/40 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `esc/y11_elab` | NE col -> EQUAL | 0 / 0 | 0/16 | 0/56 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `esc/y12_string_after` | NE col -> EQUAL | 0 / 0 | 0/20 | 0/40 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `esc/y13_class_member` | NE col -> EQUAL | 0 / 0 | 0/9 | 0/38 | IDENTICAL | same | toward (or neutral) |
| `esc/y14_param_value_after` | NE endcol -> NE endcol | 0 / 0 | 0/17 | 7/77 | IDENTICAL | same | no break: escaped parameter end 3:20 -> 3:24, golden 3:26 (v11u146 residue 3): closer, not equal |
| `esc/y15_upper_S_colon` | SURELOG_FAIL rc=0 -> SURELOG_FAIL rc=0 | - / - | - | -/- | SURELOG_FAIL | same | law does not fire (bytes equal) |
| `esc/y16_upper_W_hash` | SURELOG_FAIL rc=134 -> SURELOG_FAIL rc=134 | - / - | - | -/- | SURELOG_FAIL | same | law does not fire (bytes equal) |
| `esc/y17_upper_S_alt2_ok` | NE col -> EQUAL | 0 / 0 | 0/16 | 0/48 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `esc/y18_lower_colon_ctl` | NE col -> EQUAL | 0 / 0 | 0/16 | 0/48 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `esc/y19_upper_W_brackets` | NE col -> EQUAL | 0 / 0 | 0/16 | 0/48 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |

#### § evalFuncSelectKeepsCall148

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `e148/q01_two_stmt_body` | NE type -> EQUAL | 0 / 0 | 0/0 | 0/18 | IDENTICAL | same | toward (or neutral) |
| `e148/q02_branch_body` | NE type -> NE type | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `e148/q03_packed_param_localparam` | NE type -> EQUAL | 0 / 0 | 0/0 | 0/18 | DIVERGENT -> IDENTICAL | same | toward (or neutral) |
| `e148/q04_arg_indexed_param` | NE type -> EQUAL | 0 / 0 | 0/0 | 0/18 | IDENTICAL | same | toward (or neutral) |
| `e148/q05_default_fill_import` | NE depth -> NE type | 0 / 0 | 0/0 | 3/9 | EQUIVALENT | same | no break: E148 does not fire (an imported package parameter select, golden keeps the call); DEFFILLIMP moves toward |
| `e148/q06_elab` | stage-1 -> EQUAL | 34 / 0 | - | 0/22 | IDENTICAL | same | toward (or neutral) |
| `e148/q07_local_2d_read` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `e148/q08_default_fill_module` | NE type -> EQUAL | 0 / 0 | 0/0 | 0/18 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |

#### § genLpUintCaRhsOwnCopy148

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `e2148/g01_gen_if` | NE type -> EQUAL | 0 / 0 | 0/0 | 0/13 | IDENTICAL | same | toward (or neutral) |
| `e2148/g02_two_readers` | stage-1 -> stage-1 | 33 / 33 | - | 0/26 | IDENTICAL | same | toward (or neutral) |
| `e2148/g03_logic_var_lhs` | stage-1 -> stage-1 | 64 / 64 | - | 0/11 | IDENTICAL | same | toward (or neutral) |
| `e2148/g04_elab` | NE type -> EQUAL | 0 / 0 | 0/0 | 0/15 | IDENTICAL | same | toward (or neutral) |
| `e2148/g05_child_inst` | NE type -> EQUAL | 0 / 0 | 0/0 | 0/26 | IDENTICAL | same | toward (or neutral) |

#### § hpBaseSelOpIdxNamesByPath145

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `bso/h01_ca_in_gen` | stage-1 -> stage-1 | 180 / 180 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `bso/h02_trail_and_base_op` | NE fullname -> EQUAL | 0 / 0 | 0/2 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `bso/h03_nested_op` | NE fullname -> EQUAL | 0 / 0 | 0/2 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `bso/h04_iface_ca` | stage-1 -> stage-1 | 110 / 110 | - | 0/4 | IDENTICAL | same | toward (or neutral) |
| `bso/h05_if_cond` | NE fullname -> EQUAL | 0 / 0 | 0/2 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `bso/h06_elab` | NE fullname -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `bso/h07_in_ps_bound` | stage-1 -> stage-1 | 118 / 118 | - | 4/0 | DIVERGENT | MOVES | **BREAK** (refined) |
| `bso/h08_in_bitsel_index` | stage-1 -> stage-1 | 144 / 144 | - | 0/4 | DIVERGENT | same | toward (or neutral) |
| `bso/h09_in_ps_bound_proc` | stage-1 -> stage-1 | 118 / 118 | - | 4/0 | DIVERGENT | MOVES | **BREAK** (refined) |
| `bso/h10_rvalue_ctl` | stage-1 -> stage-1 | 144 / 144 | - | 0/4 | DIVERGENT | same | toward (or neutral) |
| `bso/h11_ps_bound_direct` | stage-1 -> stage-1 | 118 / 118 | - | 4/0 | DIVERGENT | MOVES | **BREAK** (refined) |
| `bso/h12_ips_base` | stage-1 -> stage-1 | 144 / 144 | - | 0/4 | DIVERGENT | same | toward (or neutral) |
| `bso/h13_struct_var_ps` | stage-1 -> stage-1 | 160 / 160 | - | 0/0 | DIVERGENT | same | law does not fire (bytes equal) |
| `bso/h14_ps_bound_literal_param` | stage-1 -> stage-1 | 118 / 118 | - | 4/0 | DIVERGENT | MOVES | **BREAK** (refined) |
| `bso/h15_ps_bound_iface_arr` | SLANG_FAIL rc=3 -> SLANG_FAIL rc=3 | - / - | - | -/- | SLANG_REJECT | same | law does not fire (bytes equal) |
| `bso/h16_ps_bound_struct_var` | stage-1 -> stage-1 | 94 / 94 | - | 2/2 | DIVERGENT | MOVES | no break: stage-1; golden folds `$bits(...)` (no ref at all) |

#### § impElabArithWholeSpan145

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `iaw/a01_bitwise` | NE endcol -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `iaw/a02_iface_import` | NE endcol -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `iaw/a03_literal_left` | NE endcol -> NE value | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `iaw/a04_port_range` | NE endcol -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `iaw/a05_elab` | NE endcol -> NE value | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |

#### § lpBoundOperandKeepsBase145v

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `lpb/l01_sysfunc_parent` | stage-1 -> stage-1 | 56 / 56 | - | 1/3 | IDENTICAL | same | no break: stage-1; the bound's ts ref takes golden's `work@dut` (count artifact) |
| `lpb/l02_func_arg` | stage-1 -> stage-1 | 46 / 46 | - | 2/2 | IDENTICAL | same | no break: stage-1; golden keeps the bound UNFOLDED (`ref_obj work@dut.g.a.L`); the law renames our folded copy, neither form in golden |
| `lpb/l03_cast_parent` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `lpb/l04_replication` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |

#### § lpPaCopyBoundOwnerName145

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `lpb/l05_genfor_ifgen_direct` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `lpb/l06_param_inst_direct` | NE fullname -> NE fullname | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `lpb/l07_elab_direct` | NE fullname -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |

#### § modArrayBoundRefArrayPath146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `ma/n01_pkg_bound` | stage-1 -> stage-1 | 48 / 48 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `ma/n02_two_param_bound` | stage-1 -> stage-1 | 48 / 48 | - | 0/12 | IDENTICAL | same | toward (or neutral) |
| `ma/n03_size_form_module` | stage-1 -> stage-1 | 32 / 32 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `ma/n04_override_from_top` | NE fullname -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `ma/n05_elab` | NE fullname -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `ma/n06_localparam_body` | NE fullname -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |

#### § pkgTfSigRangeTopViewConst148

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `i148/s01_task_arg_range` | NE depth -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | toward (or neutral) |
| `i148/s02_two_args` | NE depth -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | toward (or neutral) |
| `i148/s03_localparam_pkg` | NE depth -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | toward (or neutral) |
| `i148/s04_elab` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `i148/s05_bare_bound` | NE depth -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | toward (or neutral) |

#### § portExprOperandAtExpr146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `pe/r01_multiline_expr` | NE line -> EQUAL | 0 / 0 | 0/2 | 0/12 | IDENTICAL | same | toward (or neutral) |
| `pe/r02_nested_concat` | SURELOG_FAIL rc=3 -> SURELOG_FAIL rc=3 | - / - | - | -/- | SURELOG_FAIL | same | law does not fire (bytes equal) |
| `pe/r03_output_dir` | stage-1 -> stage-1 | 704 / 704 | - | 0/12 | IDENTICAL | same | toward (or neutral) |
| `pe/r04_vectors` | NE line -> EQUAL | 0 / 0 | 0/3 | 0/12 | IDENTICAL | same | toward (or neutral) |
| `pe/r05_two_exprs` | NE line -> EQUAL | 0 / 0 | 0/5 | 0/24 | IDENTICAL | same | toward (or neutral) |
| `pe/r06_single_name` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `pe/r07_elab` | NE line -> EQUAL | 0 / 0 | 0/4 | 0/8 | IDENTICAL | same | toward (or neutral) |

#### § portInitAssignAtHeader146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `pi/w01_three_ports` | stage-1 -> stage-1 | 28 / 28 | - | 0/6 | IDENTICAL | same | toward (or neutral) |
| `pi/w02_split_reg_decl` | stage-1 -> stage-1 | 177 / 177 | - | 3/3 | EQUIVALENT | same | no break: stage-1; golden writes NO initializer for `output b; reg b = 0;`, the law relocates one ours invents |
| `pi/w03_multiline_header` | stage-1 -> stage-1 | 28 / 28 | - | 0/6 | IDENTICAL | same | toward (or neutral) |
| `pi/w04_logic_vec` | stage-1 -> stage-1 | 28 / 28 | - | 0/6 | IDENTICAL | same | toward (or neutral) |
| `pi/w05_elab` | NE line -> EQUAL | 0 / 0 | 0/2 | 0/6 | IDENTICAL | same | toward (or neutral) |
| `pi/w06_sub_inst` | stage-1 -> stage-1 | 28 / 28 | - | 0/6 | IDENTICAL | same | toward (or neutral) |

#### § psBoundBareRefByBase145

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `psb/b01_block_localparam` | stage-1 -> stage-1 | 17 / 17 | - | 2/6 | IDENTICAL | same | no break: stage-1; the renamed refs match golden, the away lines are golden copies ours lacks (count) |
| `psb/b02_genfor_genif` | NE fullname -> EQUAL | 0 / 0 | 0/4 | 0/16 | IDENTICAL | same | toward (or neutral) |
| `psb/b03_iface_ca` | NE fullname -> EQUAL | 0 / 0 | 0/6 | 0/8 | IDENTICAL | same | toward (or neutral) |
| `psb/b04_nba_lhs` | NE fullname -> EQUAL | 0 / 0 | 0/4 | 0/8 | IDENTICAL | same | toward (or neutral) |
| `psb/b05_escaped_base` | NE fullname -> EQUAL | 0 / 0 | 0/4 | 0/8 | IDENTICAL | same | toward (or neutral) |
| `psb/b06_sysfunc_arg` | stage-1 -> stage-1 | 17 / 17 | - | 4/12 | IDENTICAL | same | no break: stage-1; ours holds 2 copies of the argument where golden holds 1, both renamed to golden's name |
| `psb/b07_imported_bound` | NE fullname -> NE fullname | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `psb/b08_elab` | NE fullname -> EQUAL | 0 / 0 | 0/4 | 0/16 | IDENTICAL | same | toward (or neutral) |
| `xg/x01_modarr_psb` | stage-1 -> stage-1 | 50 / 50 | - | 0/4 | IDENTICAL | same | toward (or neutral) |
| `xg/x02_modarr_bound_ps` | stage-1 -> stage-1 | 50 / 50 | - | 0/8 | IDENTICAL | same | toward (or neutral) |

#### § tfArgAliasEndFollows146v

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `fa/g10_alias_chain` | stage-1 -> stage-1 | 606 / 606 | - | 0/14 | IDENTICAL | same | toward (or neutral) |
| `fa/g11_alias_then_enum` | NE line -> NE fullname | 0 / 0 | 0/10 | 0/42 | IDENTICAL | same | toward (or neutral) |

#### law tfArgDpiExportFirstNoWrite153v

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `fa/g15_module_export_first` | stage-1 -> stage-1 | 250 / 250 | - | 14/0 | IDENTICAL | MOVES | **BREAK** (refined) |
| `fa/g16_task_export_first` | stage-1 -> stage-1 | 102 / 102 | - | 22/2 | IDENTICAL | MOVES | **BREAK** (refined) |
| `fa/g17_export_after_ctl` | stage-1 -> stage-1 | 448 / 448 | - | 0/24 | IDENTICAL | same | toward (or neutral) |
| `fa/g18_export_other_ctl` | stage-1 -> stage-1 | 202 / 202 | - | 0/24 | IDENTICAL | same | toward (or neutral) |

#### § tfArgDpiNoWrite146v

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `fa/g07_dpi_then_func` | stage-1 -> stage-1 | 90 / 90 | - | 3/29 | IDENTICAL | same | no break: golden moves to the ordinary function's argument; ours holds more copies (count) |
| `fa/g08_func_then_dpi` | stage-1 -> stage-1 | 154 / 154 | - | 1/27 | IDENTICAL | same | no break: as g07 |

#### § tfArgTypedefLastWriter146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `fa/g01_two_args_same` | stage-1 -> stage-1 | 17 / 17 | - | 0/28 | IDENTICAL | same | toward (or neutral) |
| `fa/g02_func_then_task` | stage-1 -> stage-1 | 17 / 17 | - | 0/28 | IDENTICAL | same | toward (or neutral) |
| `fa/g03_output_arg` | NE line -> EQUAL | 0 / 0 | 0/6 | 0/28 | IDENTICAL | same | toward (or neutral) |
| `fa/g04_default_arg` | NE line -> NE type | 0 / 0 | 0/4 | 0/24 | DIVERGENT | same | toward (or neutral) |
| `fa/g05_gen_block_func` | NE line -> EQUAL | 0 / 0 | 0/3 | 0/14 | IDENTICAL | same | toward (or neutral) |
| `fa/g06_class_in_module` | NE line -> EQUAL | 0 / 0 | 0/3 | 0/14 | IDENTICAL | same | toward (or neutral) |
| `fa/g09_dpi_export` | stage-1 -> stage-1 | 250 / 250 | - | 22/2 | IDENTICAL | MOVES | **BREAK** (refined) |
| `fa/g12_elab` | stage-1 -> stage-1 | 17 / 17 | - | 0/28 | IDENTICAL | same | toward (or neutral) |
| `fa/g13_include_typedef` | stage-1 -> stage-1 | 17 / 17 | - | 0/24 | IDENTICAL | same | toward (or neutral) |
| `fa/g14_ref_arg_iface` | NE line -> EQUAL | 0 / 0 | 0/4 | 0/12 | IDENTICAL | same | toward (or neutral) |

#### § tpDefaultCaIfaceKeeps146v

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `tn/j08_iface_body_net` | stage-1 -> stage-1 | 58 / 58 | - | 0/0 | EQUIVALENT | same | law does not fire (bytes equal) |
| `tn/j10_iface_two_inst` | NE line -> NE line | 0 / 0 | 0/0 | 0/0 | EQUIVALENT | same | law does not fire (bytes equal) |
| `tn/j11_iface_via_port` | NE line -> NE line | 0 / 0 | 0/0 | 0/0 | DIVERGENT | same | law does not fire (bytes equal) |

#### § tpDefaultCaLhsUnparented146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `tn/j01_two_param_bound` | NE fullname -> EQUAL | 0 / 0 | 0/24 | 3/15 | IDENTICAL | same | no break: walk equal; the away line is our extra weaklyReferenced copy (pre-existing) |
| `tn/j02_packed_2d` | NE fullname -> EQUAL | 0 / 0 | 0/16 | 2/10 | IDENTICAL | same | no break: walk equal; our extra weaklyReferenced copy |
| `tn/j03_gen_local_net` | NE line -> NE fullname | 0 / 0 | 2/0 | 3/0 | DIVERGENT | MOVES | **BREAK** (refined) |
| `tn/j04_typedef_of_tp` | stage-1 -> stage-1 | 146 / 146 | - | 0/0 | DIVERGENT | same | law does not fire (bytes equal) |
| `tn/j05_nonansi` | NE fullname -> EQUAL | 0 / 0 | 0/8 | 1/5 | IDENTICAL | same | no break: walk equal; our extra weaklyReferenced copy |
| `tn/j06_elab` | NE fullname -> EQUAL | 0 / 0 | 0/8 | 1/5 | IDENTICAL | same | no break: walk equal; our extra weaklyReferenced copy |
| `tn/j07_unpacked_of_T` | NE endline -> NE endline | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `tn/j09_program` | EQUAL -> EQUAL | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `tn/j12_genfor_local_net` | NE line -> NE fullname | 0 / 0 | 2/0 | 3/0 | DIVERGENT | MOVES | **BREAK** (refined) |
| `tn/j13_genlocal_and_module_ctl` | NE fullname -> NE line | 0 / 0 | 0/8 | 1/5 | DIVERGENT | same | no break: the module-level Lhs keeps the law (control); our extra weaklyReferenced copy |

#### § typeParamStructAtKeyword146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `tp/q01_unpacked_struct` | stage-1 -> stage-1 | 88 / 88 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `tp/q02_packed_dims` | NE fullname -> NE fullname | 0 / 0 | 0/0 | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `tp/q03_class_tp` | stage-1 -> stage-1 | 56 / 56 | - | 0/6 | IDENTICAL | same | toward (or neutral) |
| `tp/q04_enum_ctl` | stage-1 -> stage-1 | 60 / 60 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `tp/q05_nonansi` | NE endcol -> EQUAL | 0 / 0 | 0/2 | 3/7 | IDENTICAL | same | no break: walk equal; our 3 extra weaklyReferenced copies (golden 3 at the keyword, ours 6) |
| `tp/q06_elab` | NE endcol -> EQUAL | 0 / 0 | 0/2 | 3/7 | IDENTICAL | same | no break: walk equal; our 3 extra weaklyReferenced copies |

#### § unaryOperandParamOwnerName145

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `uop/o01_reduction_and` | stage-1 -> stage-1 | 60 / 60 | - | 2/2 | IDENTICAL | same | no break: stage-1; golden folds the whole reduction `&M` to one constant; the law renames an operand golden lacks |
| `uop/o02_xor_ips_lhs` | stage-1 -> stage-1 | 31 / 31 | - | 0/4 | IDENTICAL | same | toward (or neutral) |
| `uop/o03_member_elem_lhs` | stage-1 -> stage-1 | 31 / 31 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `uop/o04_body_param_override` | NE fullname -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |
| `uop/o05_ternary_operand` | stage-1 -> stage-1 | 31 / 31 | - | 0/4 | IDENTICAL | same | toward (or neutral) |
| `uop/o06_elab` | NE fullname -> EQUAL | 0 / 0 | 0/1 | 0/4 | IDENTICAL | same | toward (or neutral) |

#### § unnamedConcatIfaceAnchor146

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `ucp/v01_output` | stage-1 -> stage-1 | 34 / 34 | - | 0/32 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `ucp/v02_mixed` | stage-1 -> stage-1 | 88 / 88 | - | 1/27 | EQUIVALENT | same | no break: stage-1; b's elaborated LowConn: golden 2:14 (header), off 3:10, on 8:5 (the actual): wrong -> other wrong (residue) |
| `ucp/v03_vectors` | stage-1 -> stage-1 | 34 / 34 | - | 0/30 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `ucp/v04_elab` | stage-1 -> stage-1 | 34 / 34 | - | 0/30 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |
| `ucp/v05_two_insts` | stage-1 -> stage-1 | 34 / 34 | - | 0/48 | EQUIVALENT -> IDENTICAL | same | toward (or neutral) |

#### § unsignedScalarParamTsAtKeyword145

| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |
|---|---|---|---|---|---|---|---|
| `usp/s01_gen_localparam` | NE endcol -> EQUAL | 0 / 0 | 0/3 | 0/10 | IDENTICAL | same | toward (or neutral) |
| `usp/s02_class_param` | stage-1 -> stage-1 | 36 / 36 | - | 0/0 | IDENTICAL | same | law does not fire (bytes equal) |
| `usp/s03_multi_decl` | NE endcol -> EQUAL | 0 / 0 | 0/8 | 0/24 | IDENTICAL | same | toward (or neutral) |
| `usp/s04_override_top` | NE endcol -> EQUAL | 0 / 0 | 0/4 | 0/12 | IDENTICAL | same | toward (or neutral) |
| `usp/s05_elab` | NE endcol -> EQUAL | 0 / 0 | 0/4 | 0/12 | IDENTICAL | same | toward (or neutral) |
| `usp/s06_macro_gen_signed_mix` | NE fullname -> NE fullname | 0 / 0 | 0/4 | 0/12 | IDENTICAL | same | toward (or neutral) |
| `usp/s07_gen_signed_after_unsigned` | NE endcol -> NE fullname | 0 / 0 | 0/4 | 0/12 | IDENTICAL | same | toward (or neutral) |

## 7. Residues: the pairs' top three re-measured at d10675dd, then the new ones

Heads come from sweep P via `drivers/head.sh` (fail-closed; `evidence/residue_heads_base.txt`). Case
verdicts come from `drivers/case.sh` on the landed binary (`evidence/residue_cases_base.txt`).

| list | residue | at d10675dd |
|---|---|---|
| pass 145 R1 | GenCase / GenCaseStmt: the generate-case item's ref_obj full name | **stands**: `differ:fullname(4)` both modes; head #130 `ref_obj x_1sb1`, golden no full name, ours `work@top.x_1sb1` |
| pass 145 R2 | PreprocTest: `typedef enum bit [2:0]` base typespec end | **stands**: `differ:endcol(2)`; head #9 `bit_typespec` 5:14-5:17 against ours 5:14-5:23 |
| pass 145 R3 | IndexAssign: the literal's encoding under a select Lhs | **resolved** by pass 144: b2199096 baselined IndexAssign CMP_EQUAL in both modes. Pass 145 was measured at c24699f1, before pass 144 landed |
| r11v145 V1 | `'{default:}` not expanded by golden (dfi/x03, x06) | **decoded and partly refined**: break B4 above. The law's per-element copies are now withdrawn for non-`int` elements (x03 -10, x06 -6 dump lines); the expansion itself remains (N1) |
| r11v145 V2 | indexed part-select operand bound named by the select (lpb/x15) | **stands**: STRICT_NOTEQUAL fullname |
| r11v145 V3 | the § hpBaseSelOpIdxNamesByPath145 frontier (bso/x06, x09, x14, x15) | **stands**: x06, x09 and x14 read `fullname`, x15 reads `endcol` |
| pass 146 R1 | N0139 member names in parameter typespec copies (InterfaceParamOverrideProp, iface_nested_param_field, iface_scalar_localparam, iface_struct_field_param_width, iface_struct_field_partsel: 12 row-modes) | **stands**: all 12 row-modes read `differ:fullname`; head #158 `ref_typespec <in>p::cfg_t.HSK` |
| pass 146 R2 | hier_path base placement outside TypeEmit (ComplexHierPath, mem_ff_partial_rsp, portsel_struct_param, expr_width_cast) | **stands**: `col(10)/col(8)`, `col(16)`, `col(4)`, `col(12)` |
| pass 146 R3 | IfGenTypeBinding: § defNetTypedefEndWrite134 over-fires | **stands**: `differ:endline(5)`; head #23 `struct_typespec ibex_pkg::pmp_cfg_t`, golden 3:11-8:4, ours 3:11-18:66. The grid case `ig/i5` is now STRICT_EQUAL at the base |
| pass 146 S1 | select-bound references named through the select | **stands** on its rows: comb_dyn_2d_packed_sel `depth(1)` #743, mriscv_bind_sva `fullname(30)`, jeras_tcb_gpio, mem_packed_2d_byte_write, unpacked_elem_partsel_comb `fullname(4)`. BasicOh/default's head is now a generate-scope part_select full name (#1708, golden `...wr_rsync.genblk1.sync_pipe`) |
| pass 146 S2 | the imported-package typedef clone's file (rp32_r5p_alu/bru/mdu/wbu) | **stands**: `differ:file(46)` × 8; head #1157 golden `riscv_isa_i_pkg.sv`, ours `riscv_isa_pkg.sv` |
| pass 146 S3 | r11u148's D2 and G / D / ARR | **stands**: def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot, StructParamFuncBodyFieldCompare, BlackParrotComplex, array_assign all `depth(1)`; head #43 golden `typespec_member RVC`, ours a stamped constant |
| v11u146 1 | packed_array_struct: the `localparam type` struct's end | **stands**: `differ:endline(2)`; head #94 golden 10:28-17:15, ours 10:28-10:34 |
| v11u146 2 | escaped instance `ref_module` end (esc/x2) | **stands**: STRICT_NOTEQUAL endcol |
| v11u146 3 | escaped parameter end (esc/x9; fresh `esc/y14`: 3:24 against golden 3:26) | **stands** |

New residues from the fresh cases, ranked by what they would unlock (none is a regression; each reads the
same on the law-off, landed and refined binaries unless stated):

* **N1** The non-`int` default-fill EXPANSION itself (ParamEmit.cpp `emitParameters`: the guard reads
  `isIntegral()`, golden requires `int`, CompileHelper.cpp:3401). Seen in `dfi/d05`-`d07`, `d10`,
  r11v145's x03 and x06. These are stage-1 cells, and the downstream verdict is EQUIVALENT (not
  IDENTICAL) on d05, d06, d07 and d10.
* **N2** § evalFuncSelectKeepsCall148's frontier: a callee reading a select of an IMPORTED package
  parameter keeps the call in golden (`e148/q05`, `type`). This is the same family as v11u146's q3.
* **N3** Downstream DIVERGENT on every binary: a generate-local net typed by a type parameter. The
  plugin sizes `g.w` 1 bit on our database and 4 on golden's (`tn/j03`, j12, j13; also j04 typedef of T,
  j11 an interface through a port). A struct-array parameter path (`bso/h07`-`h16`), a function
  default argument (`fa/g04`) and a `default:` key pattern (`ck/k02`) are DIVERGENT for the same
  reason.
* **N4** § genLpUintCaRhsOwnCopy148 with a NARROWER module-level Lhs (`e2148/g03`, `logic [7:0] v`):
  golden's copy is adjustSize'd to 8 bits, ours keeps 32.
* **N5** § unnamedConcatIfaceAnchor146 with a mixed header `module f({a, b}, c)` (`ucp/v02`): b's
  elaborated LowConn is at the header token 2:14 in golden. The law puts it at the actual (8:5), and
  law-off had 3:10.
* **N6** An escaped struct member in a hier_path (`esc/y03`): golden starts BOTH components at the
  path's start (5:12). The end columns are fixed by § escIdPpColumnShift146.
* **N7** Unary reduction operators (`&M`, `uop/o01`): golden folds the whole reduction to one constant.
  § unaryOperandParamOwnerName145's operator range includes them, but renames an operand golden does
  not have (stage-1, neutral).
* **N8** A part-select as a function-call argument in a generate scope (`lpb/l02`): golden keeps the
  bound unfolded (`ref_obj work@dut.g.a.L`). § genCaLpPaCopy folds it (stage-1, neutral).
* **N9** `output b; reg b = 0;` (`pi/w02`): golden writes no initializer at all. Ours invents one, and
  § portInitAssignAtHeader146 relocates it (stage-1, neutral).
* **N10** weaklyReferenced tails, outside the walk and the plugin: golden keeps some copies at the whole
  span.
  * `tp/q05`, `q06`: 3 of our 6 struct copies.
  * int_types under § unsignedScalarParamTsAtKeyword145: 4 `reg unsigned` copies at 4:20-4:32 in
    golden's tail. Ours lacks those objects, and law-off's wrong spans matched them by coincidence.
* **N11** slang-uhdm aborts (rc 134, uncaught `std::runtime_error: source:1:3: error: expected '('`) on the
  legal escaped identifier `\W#1 ` (`esc/y16`), with every law switched off as well. A name is re-parsed
  somewhere without a guard. Surelog fails on the same source (a pp-lexer syntax error), so no golden
  judges it. It is a robustness defect of the exporter, not of these landings.
* Escaped names Surelog's pp lexer cannot form (`\Sa:b `, `\W#1 `: an upper-case `S` or `W` plus a
  character outside `[A-Za-z0-9_$+-.[]]`, SV3_1aPpLexer.g4:19-20) make Surelog fail (rc 0 with no
  database, and rc 134). There is no golden, so this is out of scope.

## 8. The fence

**The incident.** r11u146repro README section 8 records it: while the implementer listed the pristine
sweep's heads, `heads.sh` ran uhdm-strictcmp on one fenced test's sweep databases and read its head.
The line was discarded.

**No law, case or number rests on that head:**
* A word-boundary scan of tools/probe/r11u146repro, v11u146repro, r11u145repro, r11v145repro and
  r11u148share for the four fenced names finds them only in r11u148share/drivers/census.py's `FENCED` set,
  a FENCED= list.
  - Positive control: the same scan finds `PortExpr` in r11u146repro.
  - There are 0 hits in any evidence file, including `heads_pristine.txt`.
  - There are 0 case paths named after a fenced test under tests/probe, r11u146repro and v11u146repro.
* The pass's counts (sweep gates, byteverify, attribution) treat every row alike, as the gate
  mandates. The per-row drivers that produced its classified lists skip fenced names: `corpcmp.sh`,
  `attrib.py`, `predict.py`, and `heads.sh` after the fix.
* **Re-derived independently, from fresh cases and Surelog's source only**, the two laws nearest to that
  test's shapes:
  * **§ escIdPpColumnShift146.**
    - Source: SV3_1aPpLexer.g4:19-20 (`ESCAPED_IDENTIFIER: '\\' ~[WS\r\t\n]*? WS | '\\' ( OPEN_BRACKET?
      [A-Za-z0-9_$+-.]+ CLOSE_BRACKET?)* WS`, with `WS: [ ]+`, spaces only).
    - Source: SV3_1aPpTreeShapeListener.cpp:1000-1011 (`EscapeSequence + text[1..size-2] +
      EscapeSequence`) and CommonListenerHelper.h:52 (`"#~@"`).
    - So a space-terminated `\name ` becomes `#~@name#~@`. The token covers col..col+6+len, and every
      later column on the line reads +4 (6 added, the backslash and one space removed). A tab or a line
      end cannot end the lexeme.
    - 19 fresh cases (`esc/y01`-`y19`). The law converts 12 to STRICT_EQUAL (y02, y04, y05, y06, y08,
      y10, y11, y12, y13, y17, y18, y19). y01 (stage-1) and y03 (a later `col` face) move toward golden, and y14 moves closer on
      the escaped parameter end (3:20 -> 3:24, golden 3:26).
    - The two comment controls do not move.
    - Both lexer alternatives are exercised: `\S$1 ` and `\W[0] ` go through the second, `\a:b ` through
      the first. Names neither alternative forms make Surelog fail (y15, y16).
  * **§ portExprOperandAtExpr146.**
    - Source: CompileExpression.cpp:1803-1840 (the `paPort_expression` case builds a concatenation
      whose operand ref_objs take `populateCoreMembers(Port_reference, ...)`, each at its own token,
      line 1831).
    - Source: UhdmWriter.cpp:686-697 (the explicitly named port's LowConn is that expression).
    - 7 fresh cases (`pe/r01`-`r07`): multi-line, vectors, two port expressions and `--elabuhdm` convert
      to STRICT_EQUAL. `.a(b)` (a single name, the `slStringConst` road of UhdmWriter.cpp:677) does not
      move. A nested concatenation makes Surelog fail.
* **The drivers** (audited by reading every file of both `drivers/` directories):

| driver | touches | refuses without `$FENCED` | skips the names |
|---|---|---|---|
| r11u146 attrib.py, corpcmp.sh, ctx.py, heads.sh, orderblind.sh, predict.py | corpus databases or sources | yes | yes |
| r11u146 **newdiffs.sh** | corpus databases (the name is an argument) | yes | **no**: it runs uhdm-strictcmp on whatever name it is given |
| r11u146 grid.sh, swcheck.sh, probecmp.py | grid cases and probe databases only | no | n/a |
| v11u146 attrib.py, firstdiff.sh, predict.py, rowrec.sh | corpus | yes | yes |
| v11u146 colcmp.py | two csvs (prints every changed row, fenced rows included; firstdiff.sh filters) | no | no |
| v11u146 case.sh, recdiff.py, probefd.py, ds.sh, sweep.sh | cases, probe, or the whole gate | no (ds.sh and sweep.sh source an env file that exports it) | n/a (the gate runs every row by mandate) |

  So the statement "every driver refuses to run without `$FENCED` and skips those names on sources and
  databases" holds for every corpus-reading driver but `newdiffs.sh`, which refuses but does not skip.
  Nothing in either evidence directory names a fenced test, so no result depends on that gap. Every
  corpus-reading driver of this directory is fail-closed:
  - `predict.py`, `unmask.py`, `head.sh`, `compose.py` and `joint.py` each exit 1 without `$FENCED`
    (negative controls, `evidence/fence_negative_controls.txt`).
  - `head.sh`, given a fenced name, prints `FENCED-SKIP` and reads nothing.
* This pass ran no binary, gdb or script on a fenced source, a copy of one, or its sweep databases,
  beyond the gate sweeps that the gate mandates for every row.

## 9. Files

* `cases/<family>/<case>/dut.sv`: 179 fresh cases. The first line names the law(s); `(control)` marks a
  control. An `ELAB` file marks a `--elabuhdm` case (20). Two cases carry an include (`inc.svh`,
  `td.svh`).
* `fix.patch`: the four refinements (`git diff d10675dd -- src`; EmitHelpers.h `r11u153On`, ParamEmit.cpp,
  ExprEmit.cpp, TypeEmit.cpp, UhdmExporter.cpp). Not applied. It lands with `R11U153_OFF` as its master
  switch.
* `drivers/`. The shared setup file `/tmp/r11u153_env.sh` exports the brief's tool paths, `STRICT_CMP`,
  `PRIS` and `$FENCED`. It is not shipped, because it spells the four names.
  * `case.sh`: a case's golden (pinned Surelog, check_probe's SL_ARGS, plus `-elabuhdm` under `ELAB`),
    ours, uhdm-cmp, uhdm-strictcmp record dumps and the order-blind dump.
  * `grid.py` + `laws.txt`: every case with its law off, landed, refinement-off and both-landings-off.
  * `obaway.py` and `obscore.py`: order-blind dump away/toward, with `STRIP=1` for depth-blind.
  * `fixcheck.sh`: landed against fix against `R11U153_OFF`.
  * `dsgrid.py`: downstream verdicts per case.
  * `bytes.sh`: byte controls on earlier grids.
  * `tables.py`: section 6.
  * `sweep.sh` and `sweepc.sh`: gate sweeps with switches.
  * `predict.py` and `predict_probe.py`: mover prediction.
  * `compose.py`: the composition census.
  * `joint.py`: the no-cancellation proof.
  * `unmask.py`: the unmasking proof.
  * `head.sh`: a row's strict head.

  Every corpus-reading driver fails closed on `$FENCED`.
* `evidence/`:
  * `sweep_{P,F,A,B,O}.txt` and `cmds_audit.txt` (3273 of 3273 slang lines name the sweep's binary).
  * `byteverify_fix_vs_landed_{surelog,uhdm2rtlil}.txt`, `canaries.txt`, `predict_{corpus,probe}.tsv`.
  * `grid_all.tsv`, `fixcheck_all.tsv`, `depthblind_off_on.tsv`, `downstream_cases.tsv`.
  * `composition_rows.tsv`, `composition_summary.txt`, `joint_rows.txt`.
  * `unmask14{5,6}_first_pass.tsv` and `unmask14{5,6}_recheck.tsv`.
  * `downstream_bytes_converted.txt`, `bytes_landed_grids.txt`.
  * `residue_heads_base.txt`, `residue_cases_base.txt`, `fence_negative_controls.txt`.
