# v11u171: adversarial verification of r11u171 (the module/type ground, pair B: r11u172's TypeEmit laws landed, seven laws of its own)

Base `f34d9d7c` (branch matrix-1.87). Worktrees `/tmp/wt_v11u171` (the implementer's patch `/tmp/r11u171.patch`, md5
`49c74a47…`) and `/tmp/wt_v11u171pris` (pristine), both built with system deps at `-j 2`. The patch applies clean on a
fresh `f34d9d7c`. The fenced tests are written `FENCED=` here and never spelled. Every driver that reads corpus sources
or databases (`drivers/env.sh` builds `$FENCED_RE` from RESUME.md and fails closed; `drivers/mirror.sh`,
`drivers/attrib.sh`, `drivers/judge.sh`, `drivers/boundary.sh`, `drivers/dscase.py`) skips a fenced path by word
boundary. The byte comparisons ran on hard-link mirrors that leave out the 8 fenced row-mode databases. No fenced source
or database was run, read or decoded outside the gate sweeps.

## 1. Verdict

**ACCEPT-WITH-FIX.** Every headline number of the implementer reproduces bit-for-bit with binaries built here (section
3). 75 fresh cases attack all ten laws. Two laws turned pristine-right cells wrong on legal SV. Both are fixed here
behind their own switches (section 4):

* § genElseIfGateTermPath171 added a third `genblk1` to gate terminal names in a top-level `else if` chain whose bodies
  have no `begin..end`. Pristine named these exactly as golden does. The fix is **§ genElseIfFlatOnly171v**
  (`R11V171_GENFLAT_OFF`).
* § udpFormConcatSwallowSpans171 renamed and re-spanned objects of a positional instantiation whose first concatenation
  holds a literal or an operation. Surelog does not read that instantiation in UDP form, and pristine's fields there
  were golden's. The fix is **§ udpSwallowLvalueOnly171v** (`R11V171_UDPLVALUE_OFF`).

Both failures sit inside cases that uhdm-cmp already rejects at stage 1 on both binaries. No corpus row or probe case
has either shape: the fixed binary gives the same verdicts as `law.bin` on all three corpora and the downstream gate. It
differs by bytes from `law.bin` only on the UVM order coin.

`/tmp/r11u171.verified.patch` is the implementer's patch plus these two refinements, this directory and the regenerated
`tests/LAWS.md`.

## 2. Binaries (frozen `chmod 555` before any measurement, `/tmp/v11u171_bin/`)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `348259b71247518263d3efe929e5e3aa` | `f34d9d7c` worktree build = the brief's pristine md5 |
| `law.bin` | `02fbc6be01e329311b6744489ab40197` | `f34d9d7c` + `/tmp/r11u171.patch` = the implementer's `final.bin`, byte for byte |
| `fix2.bin` | `9e42d2639e13182401c2aa57a1cedb83` | `law.bin` + § genElseIfFlatOnly171v + § udpSwallowLvalueOnly171v (the verified patch) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

(`fix1.bin`, `070162d6…`, was a first cut of the generate refinement that declined on the wrong quantity and lost five
conversions, G/a02, a07, a09, a11 and a13. It never entered a sweep.)

Sweeps: `tests/sweep.sh --jobs 3` with `SLANG_UHDM` exported, on same-length workdirs: `/tmp/v11u171_swP` (pris),
`/tmp/v11u171_swL` (law), `/tmp/v11u171_swV` (fix2). Downstream sweeps ran one at a time after the corpus stages.
cmds.txt audit, fenced rows left out: all 3265 `slang:` lines name the sweep's own binary in each of swP, swL and swV
(3323 cmds.txt per sweep; 3273 golden cache hits).

## 3. The implementer's numbers, reproduced

| claim | measured here |
|---|---|
| probe: regressions 0, conversions 13, changes 5 (EQUAL 2697 → 2710) | swL: `[probe] EQUAL=2710 STRICT_NOTEQUAL=1377`, `regressions=0 conversions=13 changes=5`, the same 13 and 5 names |
| surelog: 7 conversions, 11 changes, 480/3 + 474/3 | swL: `CMP_EQUAL=450 … STRICT_NOTEQUAL=30` (default), `446 … 28` (testflags), `regressions=0 conversions=7 changes=11` |
| uhdm2rtlil: 0 conversions, 12 changes, 803/1 | swL: `CMP_EQUAL=776 CMP_NOTEQUAL=1 SLANG_REJECT=67 STRICT_NOTEQUAL=27` both modes, `regressions=0 conversions=0 changes=12` |
| downstream 803/66/2/0, csv byte-identical to pristine | swL: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66`; `downstream.csv` byte-identical to swP's |
| 42 byte movers of 2560 (8 fenced skipped), SELFCHECK 2559/2560 | `evidence/sweeps/byteverify_swL_vs_swP.txt`: `PATH_SETS_IDENTICAL (2560 paths)`, `MOVERS: 42 / 2560`, `SELFCHECK … 2559 / 2560 flagged`; the same 42 names as the implementer's table |
| canaries surelog ok=41 changed=11, u2r ok=16; ctcan2 PASS | the same, on swL and on swV (`evidence/sweeps/canaries_swV.txt`) |
| grid 24 → 57 of 69 strict-equal; `R11U171_OFF=1 R11U172_OFF=1` = pristine bytes | `evidence/grid/r11u171_grid_pris_law_fix2.txt`: pris 24, law 57, fix2 57; all-off = pristine bytes on the 69 grid cases and on all 75 fresh cases |
| boundary 12687 listed: 12497 SAME, 98 MOVER, 92 NODB; no mover away from golden | pris vs fix2 (`evidence/boundary/`): `listed=12687`, 12497 SAME, 98 MOVER, 92 NODB (89 rejected by both, 3 segfaults on both); the same 98 movers as the implementer's list |
| prediction written before the law sweep | timestamps check out: `pred_P.tsv` 20:42:40, the swL probe stage finished 20:50:41; `pred_F.tsv` 21:08:37, the swF probe stage finished 21:09:30 |

The pristine sweep exits 1 only on `law index STALE`, as the implementer says. The law sweep exits **0** here, because
the patch carries the regenerated index.

Changed rows at fix2, quoted from `/tmp/v11u171_swV` (identical to swL):

    CONVERSION GenerateUnnamed default STRICT_NOTEQUAL differ:fullname(9) -> CMP_EQUAL
    CONVERSION GenerateUnnamed testflags STRICT_NOTEQUAL differ:fullname(9) -> CMP_EQUAL
    CONVERSION UnionCast default STRICT_NOTEQUAL differ:value(26) -> CMP_EQUAL
    CONVERSION UnionCast testflags STRICT_NOTEQUAL differ:value(28) -> CMP_EQUAL
    CONVERSION YosysBigSimEllip default STRICT_NOTEQUAL differ:type(1) -> CMP_EQUAL
    CONVERSION YosysOldOr default STRICT_NOTEQUAL differ:line(1) -> CMP_EQUAL
    CONVERSION YosysOldOr testflags STRICT_NOTEQUAL differ:line(1) -> CMP_EQUAL
    CHANGE Earlgrey_0_1 default|testflags  differ:fullname(511) -> differ:fullname(436)
    CHANGE MiniAmiq default|testflags, SeqDriver default|testflags  differ:file(46) -> differ:file(29)
    CHANGE SimpleUVM default|testflags, Scoreboard default  differ:fullname(62) -> differ:fullname(45)
    CHANGE Scr1SvTests default|testflags  differ:file(143) -> differ:type(1)
    CHANGE rp32_r5p_{alu,bru,mdu,wbu} default|testflags  differ:file(46) -> differ:type(1)
    CHANGE jeras_union default|testflags  differ:fullname(54) -> differ:fullname(36)
    CHANGE ibex_multdiv_fast default|testflags  differ:endcol(26) -> differ:file(11)

The `type(1)` rows are not a new face. The pristine rp32 walk already reads `type=1 … (walk diverged)` behind 45
earlier facets (`evidence/rows/rp32_first_records.txt`). At the base the first record is `#1157 file struct_typespec
riscv_isa_pkg::isa_t` (golden `riscv_isa_i_pkg.sv 417:34`, ours `riscv_isa_pkg.sv`). At fix2 it is `#15963 type`:
golden `constant INT:31` against our `operation` at `riscv_isa_i_pkg.sv 144:27`. That is the sister's DEPTH face,
§ pkgFnCastTopListing172. Scr1SvTests is the same case: its pristine walk diverged at the same record the implementer
quotes.

Mover attribution (`evidence/sweeps/attrib_movers.txt`). Each of the 42 movers was re-exported with pris twice, fix2
with `R11U171_TRACE=1`, law, all-off, and each of the twelve switches. Every deterministic mover reads all-off =
pristine and law = fix2, and its moving switches are exactly the implementer's table. The UVM rows (MiniAmiq, SeqDriver,
SimpleUVM, Scoreboard) carry the known coin, so their byte attribution is unreliable. Order-blind
(`evidence/uvm/uvm_orderblind.txt`), the only record differences between the pristine and law databases are
`typespec_member` records that differ in the FILE column alone, plus the coin constant: MiniAmiq 1035, SeqDriver 1155,
SimpleUVM 873 and Scoreboard 666 records. The implementer's counts are confirmed.

## 4. The breaks and the two refinements

The judge for a case uhdm-cmp rejects at stage 1 is `drivers/away2.sh`. It forms golden's strict records as a
multiset, and "away" counts the records pristine shared with golden that the patched binary lost.

### 4a. § genElseIfFlatOnly171v (`R11V171_GENFLAT_OFF`, ModuleEmit.cpp `emitGates`, beside § genElseIfGateTermPath171)

**Break.** Take a top-level else-if chain whose bodies have no `begin..end`: `if (p == 1) and g0(c, a, b); else if
(p == 2) xor g1(c, a, b);`. Here our generate-scope naming already lists two levels, and the terminal prefix is
`work@dut.genblk1.genblk1`. That is golden's terminal path exactly. slang's chain (direct nesting, LRM 27.5) has one
block, and the law appended the doubled level again: `work@dut.genblk1.genblk1.genblk1.c`.

* Case `cases/G/a08_elseif_no_begin` (§ genElseIfFlatOnly171v): records away from golden 3.
* Case `cases/G/a10_elseif_nobegin_three` (§ genElseIfFlatOnly171v, two elaborated instances): away 6.

Both are stage-1 NOT_EQUAL on every binary, because the gen_scope structure is an older residue, and uhdm-cmp reads 111
lines on each.

**Rule.** The law fires only while the prefix lists no more generate segments below the enclosing instance than slang's
chain has blocks. The enclosing instance's full name is read from the emitted scope's parent chain. The begin..end
forms name one segment per chain block, and the law keeps all of them.

**Grid.** Every case of the implementer's G grid gives the same verdict under law and fix2: 12 cases, 9 strict-equal on
both. Every fresh G case keeps law's verdict (a01–a13). a08 and a10 give pristine's bytes, and
`R11V171_GENFLAT_OFF=1` gives law's bytes back.

### 4b. § udpSwallowLvalueOnly171v (`R11V171_UDPLVALUE_OFF`, ModuleEmit.cpp `emitInstance`, before § udpFormConcatSwallowSpans171's early swallow)

**Break.** Surelog reads a fully positional instantiation in UDP form only when its first actual parses as a
net_lvalue. The decode is from goldens:

* The first concatenation may hold names, selects with any index, member accesses and nested such concatenations. Each
  of these swallows: `{w13[s], w13[1]}` in Q/c11, a parameter name `{P, w1}` in Q/c13, and `{w13[I], w13[I+1]}` in
  Q/c14.
* A literal `{1'b0, w1}` (Q/c07) or an operation `{w1 & w2, w1}` (Q/c12) does not swallow. Golden keeps port A's
  concatenation whole at 8:10-8:20 and leaves `w135` on its own port as `work@dut.w135`.

Pristine already swallows these wrongly: uhdm-cmp reads 287 and 371 lines on every binary. Inside that wrong structure,
pristine's spans and names were golden's. The law moved the inner concatenation to its first element (8:11-8:15) and
renamed the swallowed copy `work@dut.a142.A.w135`: away 1 on each case.

**Rule.** The early swallow runs only for an lvalue-shaped first concatenation. Any other shape keeps the pristine late
wrap, so its bytes are pristine's.

**Grid.** The implementer's Q grid gives law's verdicts, 10 cases with 9 strict-equal on both. Fresh c01–c14 give law's
verdicts. c07 and c12 give pristine's bytes, and `R11V171_UDPLVALUE_OFF=1` gives law's bytes back.

`R11V171_OFF=1` drops both refinements, which gives `law.bin`'s bytes. `R11U171_OFF=1 R11U172_OFF=1` still gives
pristine's bytes on every case.

## 5. The attack grid (`cases/`, 75 cases, first line `// § <law>`; `drivers/case.sh`, goldens from the pinned Surelog with check_probe's arguments, content-keyed cache `/tmp/v11u171_gold`)

Strict verdicts are pris / law / fix2, from `evidence/grid/grid_pris_law_fix2.txt`. Records away are in
`evidence/grid/records_away.txt`.

| dir | law attacked | cases | result |
|---|---|---|---|
| G | § genElseIfGateTermPath171 (+ § genElseIfFlatOnly171v on a08, a10) | 13 | **5 converted by the law and kept by fix2**: a02 (three parameterised instances), a07 (nested unnamed else-if chain), a09 (buf / bufif1 terminals), a11 (outer begin, inner no-begin chain), a13 (chain inside a named block). **The break**: a08, a10 (section 4a). Unchanged: a06 (plain else after else-if: equal on all); a03 (`else begin if … end`), a05 (a gate ARRAY in the body) and a12 (outer no-begin, inner begin) are fullname(3) on all, law gaps; a01 and a04 are stage 1 on all (a01 away 0, law 6 → 0 records off golden) |
| Q | § udpFormConcatSwallowSpans171 (+ § udpSwallowLvalueOnly171v on c07, c12) | 14 | **6 converted and kept**: c01 (constant tail), c05 (part-select tail), c09 (child two levels down, two parents), c10 (two-port), c11 (variable index). **The break**: c07, c12 (section 4b). c03 (nested first concat) goes from 4 objects off to col(1). c02, c06, c13 and c14 are stage 1 on all, with records off golden 7 → 2, 19 → 9, 4 → 1 and 9 → 4. c04 (replication: no swallow) is equal on all. c08 (instance array) is unchanged |
| Y | § selLhsBareDecRhsShared171 | 8 | **6 converted**: b01 (parameterised width), b02 (truncated value `C[3:2] = 5`), b03 (unpacked-array element), b04 (indexed part-select), b06 (logic variable), b08 (a 32-bit literal into four bits). b07 (three levels, stage 1 on all) goes from 3 records off golden to 0. b05 (concatenation Lhs) fullname(2) is unchanged |
| K | § defNetEndOutputCol171 | 8 | **5 converted**: d02 (an include before the declaration), d06 (wire 2-D and unpacked), d07 (two declarators with a macro dimension), d08 (the whole type and dimension from macros). d01 (a multi-line macro before) is equal on all. d03 (`line`) is unchanged, line(38) on all. d04 and d05 are stage 1 on all and move toward golden (2 → 1, 7 → 6) |
| M | § tsMemberRootFile171 | 5 | **4 converted**: e01 (`include` inside a struct body), e02 (union and unpacked member in a header package), e03 (two root files, `files` list), e04 (a macro defined in one header and expanded in another). e05 (struct parameter default, stage 1 on all) goes from 31 records off golden to 19 |
| N | § splitPortTsKeyOnPortDecl171 | 6 | **3 converted**: f02 (ranged `input` + `wire`), f05 (top-level three split outputs), f06 (signed 32-bit). f01 and f03 (one port declaration, separate body declarations) are equal on all. f04 (stage 1 on all) goes from 4 records off golden to 0 |
| F | § tdMoveCarriesFile172 | 10 | **3 converted**: h06, h08, h09 (the end-only move to a net's unpacked dimension, two files at the same position). **Tie-break defect**: h05 and h07 move a_pkg.sv → dut.sv against golden's m1.sv, wrong to wrong, no count change (residue R1). **Key defect**: h10 moves a_pkg.sv → c_pkg.sv against golden's b_pkg.sv, wrong to wrong (residue R2). h01–h03 (package-qualified formal) are unchanged on all (residue R3). h04 is stage 1 on all |
| V | § boundLitWrittenDigits172 | 5 | **1 converted**: i03 (package typedef and parameter range). i01, i02 and i05 (module, function-return, elaborated struct: stage 1 on the underscore-decompile face) go from 23, 10 and 36 records off golden to 8, 2 and 18, with 0 away. i04 (20-digit bounds) is unchanged, as the law states |
| S | § sysSignNameSpanSyntax172 | 4 | **3 converted**: j01 (`$signed` from a macro, `$unsigned (a)` with a blank), j03 (gen-for condition), j04 (a multi-line argument). j02 (arguments of a macro call) is stage 1 on all |
| U | § castUnionCloneFile171 | 2 | **1 converted**: k02 (two union casts, header package). k01 (package in another root file) is stage 1 on all, 2 records off golden → 0 |

Totals: pris 5 → law 40 → fix2 40 strict-equal of 75. On fix2 no case that pristine read strict-equal reads otherwise,
no uhdm-cmp line count changes, all 225 runs exit 0, and every case reads away 0.

Downstream through the harness's own `one()` (`drivers/dscase.py`, own `GOLDEN_CACHE`), on the 63 single-file cases,
pris → fix2 (`evidence/downstream/`):

* 55 cases read IDENTICAL on both binaries.
* 7 cases read EQUIVALENT on both, with the same `differs` column: c02, c07, c08, c12, c14, d03 and e05.
* Q/c11 goes from EQUIVALENT (nohier) to **IDENTICAL**.
* No case leaves IDENTICAL.

## 6. Gates of the verified binary (fix2, `/tmp/v11u171_swV`)

| gate | result |
|---|---|
| (1) build | pris `348259b7` (= main-tree pristine), fix2 `9e42d263` |
| (2) probe vs golden_probe.csv | `regressions=0 conversions=13 changes=5`, EQUAL 2710 / STRICT_NOTEQUAL 1377; `probe.csv` byte-identical to swL's |
| (3) surelog | `regressions=0 conversions=7 changes=11`, 450+30 / 446+28 judge-equal; the csv equals swL's except the LowMem detail text (the workdir path) |
| (3) uhdm2rtlil | `regressions=0 conversions=0 changes=12`, 776+27 both modes; csv byte-identical to swL's |
| (4) downstream | `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66`, not excused 0; `downstream.csv` byte-identical to swP's |
| (5) uhdm-cmp | every changed and converted row is judge-equal before and after; no row moves between judge-equal and anything else |
| (6) byteverify | swV vs swP: the same 42 movers as swL. swV vs swL: `MOVERS: 5 / 2560`, SELFCHECK 2559 / 2560, all the UVM coin (MiniAmiq d/t, SeqDriver d, SimpleUVM d, Scoreboard d; the only order-blind record difference is the coin constant, or nothing) |
| canaries | surelog ok=41 changed=11 (the attributed rows), uhdm2rtlil ok=16; ctcan2 surelog `EXPECT_UNKNOWN=1` ok=58 PASS, uhdm2rtlil `EXPECT_UNKNOWN=6` ok=2 PASS |
| boundary | pris vs fix2 on every `tools/probe/**/dut.sv` and `tests/probe/**/dut.sv` outside r11u171repro. `listed=12687`, processed 12687: 12497 SAME, 98 MOVER, 92 NODB. The 98 movers are judged against pinned-Surelog goldens in `evidence/boundary/movers_judged.txt` (next list) |

The 98 boundary movers, judged against golden:

* 33 go from STRICT_NOTEQUAL to STRICT_EQUAL.
* 25 are STRICT_EQUAL on both binaries.
* 9 are STRICT_NOTEQUAL on both.
* 31 are stage-1 NOT_EQUAL on both, with the same uhdm-cmp line count.
* Records off golden: fewer on 56 cases, the same on 42, more on 0. Away is 0 on all 98.

**Prediction for the refinements.** It was written before any result of swV was read. The sweep had already been
launched, which is stated in `evidence/prediction/prediction_fix2_vs_law.txt`. It named the rows where the declined laws
fire (GenerateUnnamed d/t, YosysBigSimEllip d). Trace runs of law and fix2 on both rows show identical firings and
byte-identical databases. It predicted 0 corpus movers and 0 probe changes between law and fix2. Measured: 0
status or strict changes. There were 5 byte movers between swL and swV, all the UVM coin. The prediction did not name
them, and they are attributed order-blind here.

## 7. Findings on the implementer's report (none changes a gate)

1. **The boundary tally is off by one.** The implementer counts `tools/probe/r11u118repro/grid/g2/m07_plain_vecsel` as
   "converted -> STRICT_EQUAL" from a pristine judge that read `SURELOG_FAIL` (a golden build that failed in their
   judge run). With the golden built, the case is STRICT_EQUAL on both binaries, a § selLhsBareDecRhsShared171
   identity move. So the tally is 33 converted and 25 equal on both, not 34 and 24.
2. **The mover prediction is a wide superset.** `pred_F.tsv` names 1757 row-mode keys for 42 movers, precision about
   2.4 %. The FILE172 trigger counts relocated-span typedef objects, not objects whose file changes. It names 41 of
   the 42 movers, as reported: ImplicitPorts2 testflags is missing, and ImplicitPorts2 default is named only under
   FILE172, not under its law SPLITPORTKEY. A narrower FILE172 trigger (the relocated object's file differs from the
   formal's or declarator's file) would make the census a prediction rather than a list of candidates.
3. **The downstream grid** (67 IDENTICAL cases) and **the switch matrices** reproduce as claimed.

## 8. Residues, ranked (decoded, not landed)

1. **R1 § tdMoveCarriesFile172's end-only tie-break** is the declarator written last in syntax-tree order. Surelog's is
   writeNets' module order, which is alphabetical by module name and independent of the file order: F/h05, h07 (golden
   `m1.sv`, law `dut.sv`), h09 (`a0`/`dut`: golden `dut.sv`). This only matters when two files hold a declarator of the
   same type name at the same line and column. Pristine is wrong there too. Next law: order `declEnd` writers by the
   enclosing definition's name (TypeEmit, `pkgImportCloneLastWriter32`).
2. **R2 The formal key ignores the package.** § tdMoveCarriesFile172 keys formals on the type's right-most identifier,
   so `pa::s_t` and `pz::s_t` formals at the same position in two files merge. F/h10 files `pa::s_t` at `c_pkg.sv`
   (golden `b_pkg.sv`, pristine `a_pkg.sv`). Next law: key the formal on its resolved alias (the subroutine formal's
   `getType()`).
3. **R3 A package-qualified formal is not relocated at all.** F/h01–h03: golden spans the qualifier `pa::` (4:30-4:34)
   in the formal's file. This is ibex_pmp's face, § tfArgTypedefLastWriter146's unmodelled branch, the implementer's
   residue 6.
4. **R4 UDP-form structure for a non-lvalue first concatenation** (Q/c07, c12). This is pristine's own wrong swallow,
   older than this pass: golden does not swallow at all. The rule is the net_lvalue shape of § udpSwallowLvalueOnly171v.
   Applying it to the late wrap too (ModuleEmit `emitInstance`) should make those instantiations structurally golden's.
5. **R5 § genElseIfGateTermPath171's gaps**: gate arrays in an else-if body (G/a05, fullname(3)), `else begin if …
   end` (a03), and an outer no-begin else-if whose body is a begin..end if (a12). The top-level no-begin chain's
   gen_scope structure (a08, a10) is stage 1 on every binary.
6. The implementer's residues 1–10 are confirmed where re-measured: the rp32 DEPTH face (§ pkgFnCastTopListing172,
   ExprEmit, the sister's), the Earlgrey first record `#25840 ref_typespec <in>ibex_pkg::csr_op_e` (the identity
   family), and the base statuses of HighLow, GenForStructParamBound and ibex_register_file_ff (CMP_EQUAL at the base).
   The rest: UnsizedParam d fullname(2), OneNetModPort d/t file(3), OneNetModPortGeneric d/t line(2), ClassTypeParam,
   LogicTypespec endline(3), PreprocTest endcol(2), HierPathTypespec t fullname(1), cfg_func_width_loop,
   const_cast_signext, mem_read_reg, ibex_pmp file(16), TypeParameterAsPortTypeWithEnum* file(8)/file(6).

## 9. Files

* `cases/{G,Q,Y,K,M,N,F,V,S,U}/`: 75 cases. The first line of each is `// § <law>`: the attacked law, or
  § genElseIfFlatOnly171v for G/a08 and a10, and § udpSwallowLvalueOnly171v for Q/c07 and c12. A `files` list names the
  root files of a multi-file case.
* `drivers/`:
  * `env.sh`: pins, `$FENCED` and `$FENCED_RE`, fails closed.
  * `case.sh`: golden + `BINS` binaries, uhdm-cmp, strict.
  * `away2.sh` (`recs.sh`, `away.sh`): the strict-record multiset judge.
  * `judge.sh` and `boundary.sh`: the boundary.
  * `mirror.sh`: the fence-clean hard-link mirrors.
  * `attrib.sh`: mover attribution with every switch.
  * `dscase.py`: downstream through `one()`.
  * `sweeps.sh` and `sweepV.sh`: the sweeps as run.
  * `dd.sh` and `obd.sh`: dump and order-blind diffs.
* `evidence/`: `sweeps/` (sweep and downstream logs, the byteverify runs, the attribution, canaries), `grid/`,
  `boundary/`, `downstream/`, `uvm/`, `rows/`, `prediction/`.

## 10. On the moved main tree

While this verification ran, the main tree moved to `50a01bc3d`: pass 169, r11u173's verification of passes 164 and 167,
and a `tools:` decode commit. Every file of `/tmp/r11u171.verified.patch` except the generated `tests/LAWS.md` applies
clean there (`git apply --check --exclude=tests/LAWS.md`, rc 0; `--3way` applies ModuleEmit.cpp, TypeEmit.cpp and
UhdmExporter.cpp cleanly). Regenerate `tests/LAWS.md` on integration (`python3 scripts/law_index.py`). The integrated
tree needs its own sweep.
