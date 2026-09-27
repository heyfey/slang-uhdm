# r11u184 — the expression/parameter ground: generate-block enum constants bound to the shared constant, the type-parameter enum copy located at its typedef, member selects with parenthesized indices, inc/dec member selects and streaming lvalues in their golden shapes, lvalue-index member reads, generate-scope trailing select names, `$root` targets, call indices of rvalue paths; 6 row-modes and 3 probe cases converted

Implementer pass (pair A, refill after pass 181). Base `1eeff71d` (branch matrix-1.87). Ground: `src/ExprEmit.cpp` and
`src/ParamEmit.cpp` (`src/StmtEmit.cpp` and `src/EmitHelpers.h` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`,
`UhdmExporter.cpp`, `TaskFuncEmit.cpp`, `uhdm_main.cpp`, `include/`, `results/`, `third_party/`, or `tests/` other than
the regenerated law index (`tests/LAWS.md`). Net binding is not touched. Every law of passes 140-181 and every refinement
is left as landed; the new laws are new sites under their own switches. The r11u183 decode had not landed at the start
(no `tools/probe/r11u183dec`), so step (0) did not apply. Worktree `/tmp/wt_r11u184`, system-deps config, `-j 2`.

## Binaries (frozen `chmod 555` in `/tmp/r11u184_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `d0519110f1f72bc00dcc51de37f89dd0` | the worktree build of `1eeff71d`, byte-identical to the main tree's `build/slang-uhdm` |
| `law1.bin` | `93351650d5bd570557c7dea9c91a2208` | first law set (sweep `swL`, section 10); superseded |
| `law2.bin` | `46db18341c830ac83a808240346d0c2c` | the law set of this patch (sweep `swM`) |
| `fin1.bin` | `36605bc183cbcf047b7158703972e1c1` | the final patch (`/tmp/r11u184.patch`): `law2` plus two trace lines (`GSTRAIL lvidx`, `TPENUM parented`) that print only under `R11U184_TRACE`; sweep `swF` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

`/tmp/r11u184.patch` applied to a FRESH `1eeff71d` worktree (`git apply --check` clean; whitespace warnings only, in
evidence text) builds to `36605bc183cbcf047b7158703972e1c1`, byte-identical to `fin1.bin`, and reads `law index current`.

Every sweep's `cmds.txt` names its own binary on all 3273 `slang:` lines (`/tmp/r11u184_swP` pris.bin, `/tmp/r11u184_swM`
law2.bin, `/tmp/r11u184_swF` fin1.bin; same-length workdir names).

**The fence.** No fenced test is named in this directory. `drivers/env.sh` reads the four names from
`tools/probe/r11u107repro/canaudit.sh`'s `FENCED=` line and refuses to run without four (its first cut clobbered the
positional arguments with `set --`; `grid.sh` then resolved a fenced NAME as its case path and refused it, exit 4, before
any binary ran: fixed to a word count). `drivers/predict184.sh` lists 6647 databases with the 8 fenced row-mode databases
excluded by word boundary and the predictor refuses any source path or database naming a fenced test (exit 4);
`drivers/bvmirror.sh` hard-links the corpus databases leaving the 8 fenced ones out (`fenced_skipped=8`);
`drivers/rowrec.sh`, `obrows.sh` and `probemovers.sh` refuse a fenced name; the filtered census run
(`verify_golden.py --filter` through `drivers/tracewrap.sh`) named only non-fenced tests, checked against `$FENCED_RE`
before dispatch. No gdb run.

## Result

| axis | base (committed = pristine sweep swP) | law (swF) | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL, default + testflags) | 455 + 451 | 455 + 451 | 0 (9 CHANGES, each 2 records fewer) |
| uhdm2rtlil strict-equal (of 1606) | 783 + 783 | **786 + 786** | **+6** |
| probe EQUAL (of 4087) | 2886 | **2889** | **+3** |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | `downstream.csv` byte-identical to swP's |

Gate verdicts of `tests/sweep.sh --jobs 3` against the committed baselines (`evidence/sweep_swP.log`,
`evidence/sweep_swM.log`, `evidence/sweep_swF.log`):

| sweep | probe (reg / conv / changes) | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|
| swP pristine | 0 / 0 / 0, EQUAL 2886 / STRICT_NOTEQUAL 1201 | 0 / 0 / 0 | 0 / 0 / 0 | 803 / 66 / 2 / 0, not excused 0 |
| swM law2 | 0 / **3** / 3 | 0 / 0 / 9 | 0 / **6** / 0 | csv byte-identical to swP's |
| swF fin1 (the final gate, rc 0) | 0 / **3** / 3, EQUAL 2889 / STRICT_NOTEQUAL 1198 | 0 / 0 / 9 | 0 / **6** / 0, CMP_EQUAL 786 + 786 | 803 / 66 / 2 / 0, not excused 0; csv byte-identical to swP's |

swP and swM exit 1 only for `law index STALE` (a clean `1eeff71d` checkout reads STALE too); swF runs with this patch's
regenerated `tests/LAWS.md` and exits 0. swF's four csvs equal swM's but the LowMemLib log-path text; its databases equal
swM's but five UVM order coins (MiniAmiq d/t, Scoreboard d, SeqDriver d/t; `evidence/byteverify_final_vs_law2.txt`),
0 probe and 0 downstream movers between them.

**CONVERSIONS (corpus; results/ untouched).** The fresh rows of the law sweep (`/tmp/r11u184_swM/uhdm2rtlil.csv`, identical
in swF):

    ibex_multdiv_fast,default,CMP_EQUAL,,,equal                                    was differ:file(11)  § genLocalEnumConstShared184
    ibex_multdiv_fast,testflags,CMP_EQUAL,,,equal                                  was differ:file(11)  § genLocalEnumConstShared184
    TypeParameterAsPortTypeWithEnum,default,CMP_EQUAL,,,equal                      was differ:file(8)   § tpEnumCopyAtTypedef184
    TypeParameterAsPortTypeWithEnum,testflags,CMP_EQUAL,,,equal                    was differ:file(8)   § tpEnumCopyAtTypedef184
    TypeParameterAsPortTypeWithEnumOfParametrizedWidth,default,CMP_EQUAL,,,equal   was differ:file(6)   § tpEnumCopyAtTypedef184
    TypeParameterAsPortTypeWithEnumOfParametrizedWidth,testflags,CMP_EQUAL,,,equal was differ:file(6)   § tpEnumCopyAtTypedef184

All three are downstream rows and read IDENTICAL before and after (fresh rows of swM's `downstream.csv`):

    ibex_multdiv_fast,IDENTICAL,OK,OK,3906,3906,,
    TypeParameterAsPortTypeWithEnum,IDENTICAL,NO_GATES,NO_GATES,0,0,,
    TypeParameterAsPortTypeWithEnumOfParametrizedWidth,IDENTICAL,NO_GATES,NO_GATES,0,0,,

**Probe CONVERSIONS (3):** `r10buvm21repro/g21c` (§ incDecMemberSelIsLvalue184: `hnd.h_arr[s]++`), `r10earl_repro/qa23`
(§ genLocalEnumConstShared184), `r11u108repro/grid/f5/f5a07_enumelem` (§ tpEnumCopyAtTypedef184, the default branch).

**CHANGES (corpus: 9 row-modes, each TWO records leave, 0 enter; `evidence/corpus_changes_records.txt`).** SimpleUVM d/t,
Scoreboard d, BuildUVMPkg d/t `fullname(23) -> fullname(21)`, SeqDriver d/t `fullname(7) -> fullname(5)`, MiniAmiq d/t
`fullname(8) -> fullname(6)`: the records of `seed_map.count[type_id]++` (uvm_misc.svh 425, the flat uvm_pkg.sv 8694)
leave: `ref_obj seed_map` golden 425:12-17 (ours 425:3-11) and `bit_select count` golden 425:12-26 (ours 425:18-25),
§ incDecMemberSelIsLvalue184.

**Probe CHANGES (3):** `r10uvm143repro/g143_c_index` `endcol(7) -> file(4)` (§ hpIdxCallNameSpan184: the three
`func_call helper` records, golden 61:49-55, ours 61:49-60, leave; the first remaining record is the file face behind
them, LEAVE 3 ENTER 0), `r10uvm79repro/c2_idxkind` `file(9) -> file(8)` (§ hpIdxCallNameSpan184: `func_call fn` 27:14-16
leaves), `r11u32repro/k9b` `endline(6) -> endline(4)` (§ tpEnumCopyAtTypedef184: the two `enum_typespec t_t` file records
leave).

## 1. § genLocalEnumConstShared184 (ExprEmit.cpp) — ibex_multdiv_fast d/t

**Head (at the base).** `gen_mult_fast`'s `typedef enum logic [1:0] {ALBL, ALBH, AHBL, AHBH} mult_fsm_e;` read in the
block's `always_comb` / `always_ff`:

    #11323 file  A: enum_const ALBL  ibex_multdiv_fast.sv 269:7-269:11
                 B: enum_const ALBL  (no file) 0:0-0:0          ... 11 records, all the block's constants

**Decode.** Surelog binds a generate scope's process references in `UhdmWriter::lateBinding` (UhdmWriter.cpp, called from
the generate-scope writer with the gen scope as `m`). It asks, in order, the parent chain's scopes, `m`'s interfaces,
nets, `Variables()` by name, param assigns, parameters, property / sequence declarations, then `m->Typespecs()` — every
`enum_typespec` declared in the block answers with its own located `enum_const` — then the file's typedef map, then
`m->Variables()` again — every `enum_var` declared in the block answers with its typespec's constants — and only when all
of them miss does `mod->getValue(name)` mint the FRESH loc-less `enum_const` parented on the reference. Ours minted for
every generate-scope process reference (the mint beside § uninstIfaceEnumConstNoActual221). Grid `cases/E` (13 cases x
both views; pairwise distinguishers): the enum declared in the block (e01, e05, e07 a generate-for body, e08 a function /
initial / case in the block, e10 a macro from an included file, e12 inside an interface's generate block), a module enum
typing a variable declared in the block (e02) and a package enum typing one (e04) share; a module enum read through a
module-level variable (e03) and an outer block's enum read in a nested block without a variable there (e06 `h`) mint
(golden loc-less); a nested block declaring a variable of the outer block's enum shares (e11); a continuous assignment
keeps § genCaEnumBindsSelectOnly22 (e05's `assign y = q == S1` stays unbound; the select position was already located).

- **Law:** in a generate-scope process (not a continuous-assignment right side), an enum constant whose enum type is
  declared in the current generate block (a typedef there), or types a variable declared directly in the block (its
  declared type the enum itself or one typedef of it), binds the shared `enum_const` instead of the mint. A typedef of
  a typedef in the block (`typedef c_e d_e;`, e09) is stage 1 on every binary and left to the mint (the law abstains:
  bytes identical). Switch `R11U184_GENENUM_OFF`.

Grid: 22 of 26 case-modes STRICT_EQUAL (18 converted from STRICT_NOTEQUAL file; e02 / e04 elaborated equal on both, their
bytes move to the shared object), 0 records enter; e03 / e09 / e13 bytes unchanged.

## 2. § tpEnumCopyAtTypedef184 (ParamEmit.cpp) — TypeParameterAsPortTypeWithEnum d/t, ...OfParametrizedWidth d/t

**Head.** `test_module #(.test_parameter(enum_foo_e)) inst1` (a module-local enum typedef as a type-parameter override):

    #75 file      A: enum_typespec enum_foo_e  dut.sv 10:3-12:16        B: (no file) 0:0-0:0
    #76 fullname  (raw) A: ref_typespec  work@top.inst1.test_parameter.enum_foo_e   B: enum_foo_e
    ParametrizedWidth #56: ref_obj StateWidth  A: work@top.inst1.test_parameter.state_e.StateWidth
                                                B: work@top.inst1.test_parameter.StateWidth

**Decode.** The copy is minted in ParamEmit `emitParameters`' elaborated-override branch (`buildEnumTs(ta9 ...)`, pass
171's gdb pin). Surelog's elaborated type parameter takes a clone of the typedef's typespec: it keeps the typedef
declaration's span and file (`typedef ... enum_foo_e;`) and, when parented at the type parameter, the references inside
it store no full name, so the reader computes them through the copy (`...test_parameter.enum_foo_e`,
`...test_parameter.state_e.StateWidth`). Golden leaves the copy UNPARENTED (its inside named through the copy alone,
`ie_t`, `f_t.L`) in two measured cases: the parameter's DEFAULT is in force (x21, x22, probe f5a07), or the child's
continuous assignment writes a WHOLE signal declared with the type parameter (`T r; assign r = si;`,
`output T so; assign so = si;`: x2, x13, x14, t06, t12) — a select target (x15), a target of another type (x18, x11) and
a procedural write (x12, x19) keep the parented shape (grid `cases/T`, `cases/X`, 29 cases x both views; the
distinguisher found by pairwise DUT diffs x4/x9 -> x2 -> x13/x15/x18/x19).

- **Law:** the copy is located at the typedef declaration (`setLoc` on the typedef syntax; file stamped); its base
  reference and its range references are named through `<type parameter>.<typedef>` when the override is in force and
  no whole-signal continuous assignment writes a `T`-typed signal in the child, else through `<typedef>` alone. Switches
  `R11U184_TPENUM_OFF` (all of it), `R11U184_TPENUMCA_OFF` (the continuous-assignment distinguisher).

Grid: 48 of 58 case-modes STRICT_EQUAL (44 converted from STRICT_NOTEQUAL file; t03 / t04 equal on both, bytes
unchanged); t06 `file(16) -> fullname(1)` (the remaining record is
the cast `e_t'(a)`'s range reference in `top`, pristine alike, sister typespec face); t08-t10 and x20 stage 1 on both
(pre-existing faces: a generate-block typedef's own listing, a typedef-named base, a package-read range, a `$unit` typedef
override), every one TOWARD golden order-blind (`evidence/stage1_orderblind.txt`); 0 records enter.

## 3. § memberSelParenIdxSpan184 (ExprEmit.cpp) — r11v181's residue V2

`y = s.f[(i)]`: golden spans `(i)` (10:13-16), ours the content (10:14-15). § bitSelParenIdxSpan181's rule, transcribed to
the member selects anchored at their index: the member-chain builder's trailing rvalue select (`obj.f[i]`,
emitExpr's ElementSelect-over-MemberAccess branch) and emitMixedHierPath's process / interface-port and trailing member
branches. Switch `R11U184_MEMPAREN_OFF`. Grid `cases/P` (p01-p07: trailing and nested parentheses, two-dimensional
members, continuous assignments with a macro-born index from an included file, an interface port and a modport,
mid-path selects as controls, a class method, a function body, nested in lvalue / rvalue indices, a generate scope):
p01 p02 p06 p07 STRICT_EQUAL both views; p05 loses its paren records and keeps the two-dimensional member face
(`m.g[(i)][(j)]` var_select, residue R5); p03 stage 1 on both (the modport path's name keeps the parentheses, residue R6)
with bytes unchanged; p04 (lvalue controls) bytes unchanged. r11v181's own `px/p05` converts (boundary, section 8).

## 4. § incDecMemberSelIsLvalue184 (ExprEmit.cpp) — the UVM `seed_map.count[type_id]++`

An inc/dec operand that is a member path ENDING in an element select (`s.f[i]++`, `--s.a.g[k]`, `hnd.h_arr[s]++`) is
compiled through Surelog's Variable_lvalue branch (§ incDecMemberPathIsLvalue124's decode; § incDecMixedPathIsLvalue181 took
the paths through a select) and takes the lvalue path's shape: the base on the first member's token, the trailing
bit_select spanning member + index. The operand is emitted under `inLhs`; its trailing index keeps the path naming of
§ hpTrailSelIdxNamesByPath133 in every context. A `this`- / `super`-rooted chain (`this.h.arr[i]++`) keeps its own
builder's shape (golden and pristine agree: probe v84x2_incdec, g21b — the first law sweep's one probe regression,
excluded before swM). Switch `R11U184_INCDECSEL_OFF`. Grid `cases/I` (i01-i03: post/pre increment and decrement, nested
members, a generate scope, a module function and task, a class method, a for step; controls: a plain select, a
select-free member, a member select inside an inc/dec index, a read): all STRICT_EQUAL both views (i03 bytes unchanged).

## 5. § lvIdxMemberSelIsRead184 (ExprEmit.cpp) — § lvIdxPathIsRead154's twin for the member-chain builder

`arr[s.f[(i)]] = 1`: a member path ending in a select, nested in an lvalue's select index, is a read; golden spans it
as one (base 9:9-10 on its own token, the select at its index with its parentheses 9:13-16) where ours took the lvalue
spans (9:11-12, 9:11-17). Only the two spans move; the names already agree. Switch `R11U184_LVIDXSEL_OFF`. Grid
`cases/L` (l01-l04: blocking and nonblocking, a two-dimensional target, an indexed part-select base, a concatenation
target, an operation index, a class method, a generate scope, a plain select nested in the index, two levels): l01-l03
STRICT_EQUAL both views; l04 (two levels) stage 1 on both (the hier_path name), TOWARD order-blind.

## 6. § genScopeTrailSelNameLate184 (ExprEmit.cpp) — trailing member selects in generate-scope processes

In a generate scope's process the trailing member select is named through the generate scope (golden
`work@top.gg.r.s.f[2].f`); ours froze its name before the process hung under its scope (`work@top.r.s.f[2].f`). The
member-chain builder leaves the name to the reader's parent chain in a generate-scope process (both views), and an
elaborated generate scope's process lvalue names its trailing index through the path (`t.f[i] <= z`: golden
`work@top.ga.t.f[i].i`). Switch `R11U184_GSTRAIL_OFF`. Grid `cases/G` (g01-g03: reads, writes, nested blocks, a
generate-for, continuous assignments and an initial block, an interface generate scope, a macro-born select): g03
STRICT_EQUAL; g01 keeps one record (a part-select index `s.g[i[1:0]]`'s name, residue R4); g02 stage 1 on both (the
interface's struct port, sister face), TOWARD.

## 7. § rootLvalueSpanAtRoot184, § streamLvMemberPathRead184, § hpIdxCallNameSpan184 (ExprEmit.cpp)

- **§ rootLvalueSpanAtRoot184** (`R11U184_ROOTLV_OFF`; the design-final `$root` drain `rootPathFullNameByChain181`):
  r11u181's residue R4. Surelog's lvalue branch locates an assignment-target `$root` path at the `$root` keyword node, six
  columns (`$root.top.v = ...` golden 3:21-27; blocking, nonblocking, compound, member and deeper paths, a macro-born
  target, a select target, a continuous assignment, a generate scope, a task and a class method alike), and a trailing
  bit_select element stores its written text as its full name at its index (`v[2]` 13:17-18). Grid `cases/R` (r01-r04):
  r01-r03 STRICT_EQUAL; r04 keeps the elaborated continuous assignment's parent (ModuleEmit's shared object, sister S2);
  its elaborated view stage 1 on both, TOWARD. Pass 181's `rt/g05` and `s05` convert (boundary); `rt/g06`
  (`$root.top.v[$root.top.i] = ...`, stage 1 on both on the path's name) moves SAME order-blind: the spans reach golden,
  the select's stored name follows ours path name, which golden writes without the index (residue R3).
- **§ streamLvMemberPathRead184** (`R11U184_STREAMRD_OFF`): pass 178's V1 / r11u181's R2. A streaming concatenation's
  lvalue operand is compiled as a read, and golden builds exactly the read shape for a member path through selects
  (`{>>{m.w[k+2].v}} = x`: base 8:9-10, bit_select `m.w[k + 2]` on the member token, leaf `work@top.v`), a select-free
  member path (`{>>{s.v}} = x`) and a plain select (`{<<{arr[k]}} = x`: at the index). The three builders emit the
  operand with the lvalue branches off. Grid `cases/S` (s01-s04: module and class method, two operands, a right-to-left
  stream with a slice size, a streaming rvalue control): all STRICT_EQUAL both views; v178's `hk/k06` TOWARD.
- **§ hpIdxCallNameSpan184** (`R11U184_HPIDXCALL_OFF`): pass 178's R2 first half. A call indexing a NON-TRAILING select of
  an rvalue path spans its name (`m.w[f(k)].v` golden 10:14-15, ours 10:14-18), also through an operation index
  (`m.w[f(k) + 1].v`), a plain select nested in the index (`pb[arr[f(k)]].w[k].v`) and a packed base select
  (`pa[f(k)].v`); a trailing select's index call, a call nested in the indexing call's arguments and a system call span
  the whole call. The flag is raised by emitMixedHierPath per non-trailing component. Grid `cases/C` (c01-c03): c02 c03
  STRICT_EQUAL; c01 keeps the trailing member select's index name (`m.q[f(k)]`: `k` golden `work@top.m.q.q.k`, residue
  R4). Pass 178's `cs/c01_module`, `hp/h08_ops_class` convert (boundary).

## 8. Grid, boundary, switches

Grid (`cases/`, 70 cases x both views = 140 case-modes, goldens from the pinned Surelog with and without `-elabuhdm`,
`drivers/grid.sh`, `drivers/gridcmp.sh` with `MAX=100000`; `evidence/grid_pristine_vs_final.txt`):

| pristine -> law | case-modes |
|---|---|
| STRICT_NOTEQUAL -> STRICT_EQUAL | 98 |
| verdict moved, still not equal (records leave) | 9 |
| stage 1 on both, bytes moved (all 13 TOWARD order-blind, `evidence/stage1_orderblind.txt`) | 13 |
| STRICT_EQUAL on both, bytes moved (e02 / e04 elaborated: the shared constant) | 2 |
| bytes unchanged (controls, abstentions) | 18 |

Record level over all 140 case-modes: 684 records leave, **0 enter** (one r04 record changes value while still
differing: the continuous-assignment target's span fixed, its parent not).

**Boundary** (`evidence/boundary_r11u178_r11u181_cases.txt`): every case of `r11u181repro`, `r11v181repro`,
`r11u178repro`, `r11v178repro` (234 cases x both views = 468 case-modes), pristine vs law2: **0 records enter**, 34
case-modes move — 14 to STRICT_EQUAL (181 `adv/a01`, `rt/g05`, `rt/s05`; 181v `lv/l08`, `px/p05`; 178 `cs/c01_module`,
`hp/h08_ops_class`, both views), 6 lose records (181 `adv/a08`, 181v `lv/l15`, 178 `hp/m07_idx_kinds`), 14 stage 1 on both
all TOWARD order-blind but `rt/g06` SAME (above).

| switch | law |
|---|---|
| `R11U184_GENENUM_OFF` | § genLocalEnumConstShared184 |
| `R11U184_TPENUM_OFF` | § tpEnumCopyAtTypedef184 |
| `R11U184_TPENUMCA_OFF` | § tpEnumCopyAtTypedef184's continuous-assignment distinguisher |
| `R11U184_MEMPAREN_OFF` | § memberSelParenIdxSpan184 |
| `R11U184_INCDECSEL_OFF` | § incDecMemberSelIsLvalue184 |
| `R11U184_LVIDXSEL_OFF` | § lvIdxMemberSelIsRead184 |
| `R11U184_GSTRAIL_OFF` | § genScopeTrailSelNameLate184 |
| `R11U184_ROOTLV_OFF` | § rootLvalueSpanAtRoot184 |
| `R11U184_STREAMRD_OFF` | § streamLvMemberPathRead184 |
| `R11U184_HPIDXCALL_OFF` | § hpIdxCallNameSpan184 |
| `R11U184_OFF` | every law of this pass |

`R11U184_TRACE=1` prints one stderr line per firing on every branch (`R11U184 law <TAG>`: GENENUM, TPENUM / TPENUM
parented / default / unparented, MEMPAREN, INCDECSEL, LVIDXSEL, GSTRAIL / GSTRAIL lvidx, ROOTLV / ROOTLV select,
STREAMRD / STREAMRD member / STREAMRD select, HPIDXCALL). `evidence/switch_matrix.txt` (`drivers/switchmatrix.sh`,
fin1.bin): on all 140 case-modes `R11U184_OFF=1` writes the pristine bytes; each switch alone leaves the law bytes on every
case-mode where its trace does not fire and moves every one where it does.
On the corpus movers (`drivers/offwrap.sh` through `verify_golden.py --filter` on the 9 moved tests, both corpora and
modes, 18 databases), `R11U184_OFF=1` gives every row-mode the baseline's status and strict detail, the pristine sweep's
bytes on 12 and the documented UVM order coin on 6 (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d: 4 order-blind `UINT` /
`vpiDecompile` dump lines of one constant; Scoreboard t, a SLANG_REJECT row, 0 order-blind lines;
`evidence/uvm_off_coin.txt`).

## 9. Byte movers, predicted by name first

`drivers/predict184.cpp` read every PRISTINE database of swP (6647 listed, 8 fenced excluded, fail closed) before the law
sweep and named 116 (`evidence/predict_pristine.txt`; each predicate over-approximates; positive control: it flags the
grid's pristine databases where each law fires and not the controls). Predicted corpus row-modes (36): AssignSubs d/t,
BuildUVMPkg d/t, Earlgrey_0_1 d/t, EnumConcat d/t, GenForIfaceLocalparamBound d/t, GenForIfaceLocalparamNestedGen d/t,
hier_path d/t, ibex_icache d/t, ibex_multdiv_fast d/t, ibex_pmp d/t, MiniAmiq d/t, MultirangesStartNotFromZero d/t,
prefix d/t, Rggen d, Scoreboard d, SeqDriver d/t, SimpleUVM d/t, TypeParameterAsPortTypeWithEnum d/t,
TypeParameterAsPortTypeWithEnumOfParametrizedWidth d/t; 80 probe databases.

- **Corpus** (`byteverify.sh`, SELFCHECK=1 2559 / 2560 flagged, path sets identical, fence-free mirrors;
  `evidence/byteverify_corpus.txt`): **17 / 2560 movers, all 17 predicted**: BuildUVMPkg d/t, Earlgrey_0_1 d/t,
  MiniAmiq d/t, Scoreboard d, SeqDriver d/t, SimpleUVM d/t, ibex_multdiv_fast d/t, TypeParameterAsPortTypeWithEnum d/t,
  TypeParameterAsPortTypeWithEnumOfParametrizedWidth d/t. The law census (`drivers/tracewrap.sh` through
  `verify_golden.py --filter` on the predicted rows; `evidence/corpus_census.txt`) names the firing laws: the UVM rows
  INCDECSEL + LVIDXSEL (BuildUVMPkg also STREAMRD member), Earlgrey_0_1 GENENUM (25 per mode), ibex_multdiv_fast GENENUM
  (11), the two TypeParameter rows TPENUM; the other predicted rows fire no law. Order-blind distance to golden
  (`drivers/obrows.sh`, `evidence/corpus_movers_orderblind.txt`): every mover TOWARD — BuildUVMPkg d/t 3597 -> 3565,
  MiniAmiq d 26849 -> 26807 (t -> 26809, the UVM order coin), Scoreboard d 5880 -> 5856, SeqDriver d/t 19785 / 19787 ->
  19739, SimpleUVM d/t 7228 -> 7196, Earlgrey_0_1 d 12990 -> 12940 and t 12446 -> 12420 (GENENUM: the generate-block
  enums' constants now the shared located ones; the rows keep their first records, the typespec-identity family),
  ibex_multdiv_fast d/t 26 -> 4, TypeParameterAsPortTypeWithEnum d/t 8 -> 0, ...OfParametrizedWidth d/t 8 -> 4 (the
  converted rows' remainders are records the canonical walk excuses).
- **Probe** (`drivers/probemovers.sh`): **6 movers, all predicted** (80 predicted): the 3 conversions and the 3 CHANGES
  above, each losing records, 0 entering.
- **Downstream slang lane** (`byteverify.sh` on the downstream mirrors, SELFCHECK 804 / 805; mirrored apart because a
  downstream database is byte-identical to its corpus twin): **3 / 805 movers** — ibex_multdiv_fast,
  TypeParameterAsPortTypeWithEnum, TypeParameterAsPortTypeWithEnumOfParametrizedWidth, the three converted rows; every
  downstream verdict unchanged (IDENTICAL before and after).

Canaries (`evidence/canaries.txt`): `canaries.sh` surelog ok=45 changed=7, exactly the claimed canary CHANGES (SimpleUVM
d/t, SeqDriver d/t, BuildUVMPkg d/t, Scoreboard d), uhdm2rtlil ok=16 changed=0; `ctcan2.sh` surelog PASS
(EXPECT_UNKNOWN=1), uhdm2rtlil PASS (EXPECT_UNKNOWN=6). uhdm-cmp: every touched row-mode and probe case keeps a
judge-equal status (CMP_EQUAL / STRICT_NOTEQUAL / EQUAL), i.e. uhdm-cmp reads 0 lines on each.

## 10. The first law sweep (superseded)

`/tmp/r11u184_swL` (law1.bin: GENENUM, TPENUM, MEMPAREN, INCDECSEL, LVIDXSEL, GSTRAIL without their refinements) read
the same 6 corpus conversions and 9 CHANGES, and in the probe stage **one regression**, `r10uvm84repro/v84x2_incdec`
EQUAL -> STRICT_NOTEQUAL endcol(2) (`this.h.arr[i]++`: the inc/dec law turned the `this`-rooted builder's path into its
lvalue shape, golden and pristine agree on the rvalue one), plus g21b / g21c `col -> endcol` and f5a07 `file -> fullname`
(the type-parameter copy of a DEFAULT named through the parameter). The `this` / `super` exclusion and the default branch
of § tpEnumCopyAtTypedef184 fixed all four before swM (g21c and f5a07 then convert; g21b is byte-identical to pristine).
`evidence/sweep_swL_law1.log`; its prediction (made on the pristine databases before swL with the first six predicates)
is `evidence/predict_pristine_v1.txt`: the 17 corpus movers of swL and 4 of its 6 probe movers were in it; the two it
missed are the regression's own cases (`v84x2_incdec`, `g21b`: a `this`-rooted inc/dec operand, whose pristine
hier_path carries no bit_select element, so the INCDECSEL predicate could not see it). The final law excludes that shape.

## 11. The brief's items, before -> after

| item | before | after | note |
|---|---|---|---|
| (4) ibex_multdiv_fast d/t | file(11) | **CMP_EQUAL** | § genLocalEnumConstShared184 |
| (4) TypeParameterAsPortTypeWithEnum + ...OfParametrizedWidth d/t | file(8) / file(6) | **CMP_EQUAL** | § tpEnumCopyAtTypedef184 |
| (1) streaming lvalue member paths | | **fixed** | § streamLvMemberPathRead184 (S, v178 k06) |
| (1) a call as an index inside an rvalue hier_path | | **fixed** | § hpIdxCallNameSpan184 (C, 178 cs/c01, h08) |
| (1) the lvalue `$root` path's end column and its bit_select name | | **fixed** | § rootLvalueSpanAtRoot184 (R, 181 g05 s05) |
| (1) a member path's parenthesized select index | | **fixed** | § memberSelParenIdxSpan184 (P, 181v px/p05) |
| (1) reads inside a read path nested in an lvalue index | | member-chain half fixed | § lvIdxMemberSelIsRead184 (L); the class method's elaborated index reference (181v lv/l15) loses records, keeps its name face |
| (1) FuncStructValSimple d/t | file(39)/(59) | same | its first record is the sister's typedef relocation (N0080) |
| (1) Scr1SvTests d/t type(1) | | same | 21 more clusters behind the head (map 9); not attempted |
| (1) the unsized based literal as a whole continuous-assignment right side | stage 1 | same | decoded, sister ground (R7) |
| (3) rsp_gen_minimal, jeras_union, OutputSize..., arb_idx_cast, Assert*, ParameterFromPkg*, UVM N0682/N0001/N0007/N0061 | as baseline | same | their first records need ground-B clusters (map 9) or were not reached |
| (4) InterfArrayBind d, StructParamPatternInitCast, const_cast_signext, ibex_alu default span, N0003 / N0012 / N0536 | as baseline | same | not reached this pass (N0012 is the TypeParameter rows' cluster: closed) |

## 12. Residues, ranked (this ground), and sister-ground faces

R1. **FuncStructValSimple d/t file(39)/(59)**: unchanged; pass 181's R1 stands (the head `#298` is N0080, the sister's
typedef relocation; the `INT:2` leftover's read-site rule and the package listing element's unnamed reference are not
decoded here).

R2. **Scr1SvTests d/t type(1)**: unchanged; pass 181's R5 decode (UHDM `ExprEval::evalFunc` attaching the formal's
typespec to every argument of a call Surelog constant-evaluates) stands; 21 open clusters behind the head.

R3. **A `$root` select target whose index is itself a path** (`$root.top.v[$root.top.i] = ...`, 181 `rt/g06`): stage 1 on
both (golden names the hier_path `$root.top.v`, without the index); the select's stored name follows ours.

R4. **Index names under trailing selects**: a part-select index of a generate-scope member select (`s.g[i[1:0]]`, G/g01:
golden `work@top.ga.gb.s.g.g.i`), a trailing member select's index inside a call argument (`m.q[f(k)]`, C/c01: golden
`work@top.m.q.q.k`), the class method's elaborated index reference (181v `lv/l15`).

R5. **Two-dimensional member selects** (`m.g[(i)][(j)]`, P/p05): golden's var_select starts at the member token and its
index references are named through the chain.

R6. **A modport / interface path's parenthesized index** (`b.q[(k)]` in a process, P/p03): stage 1 on both (the
hier_path's name keeps the parentheses; its leaf select anchors at the content).

R7. **An unsized based literal as a whole continuous-assignment right side** (`assign a = 'h10;` onto 16 bits,
`evidence/residue/U/u01_dut.sv.txt`; r11u181's R6): decoded — Surelog's `UhdmWriter` continuous-assignment writer
(the `DetectUnsizedConstant` / `reduceExpr` branches) CLONES the cont_assign per instance and sizes the constant with
`CompileHelper::adjustSize` to the target's typespec; ours shares the definition's object at size -1. The clone belongs
to ModuleEmit's elaborated continuous-assignment listing (sister ground).

**Sister-ground faces (report only; not edited):**

- S1. The cast `e_t'(a)` of a module enum in a continuous assignment: its range reference is named `W` where golden reads
  `e_t.W` (T/t06; the cast typespec copy, TypeEmit / castTs).
- S2. An elaborated continuous assignment to a `$root` path is the definition's shared object (R/r04: golden
  `work@top.u.$root.top.w`, ours `work@sub.$root.top.w`): ModuleEmit's instance cont_assign listing.
- S3. The interface's struct-typed port net and a generate-block typedef's own listing (G/g02, T/t08 stage 1): ModuleEmit /
  TypeEmit.
- S4. The UVM rows' first records (SimpleUVM / Scoreboard fullname(21), BuildUVMPkg fullname(21), MiniAmiq / SeqDriver
  fullname(6)/(5)) are unchanged by this pass beyond the two `seed_map` records: map 9's N0682 / N0164 and the F3
  relocations.

## 13. Files

- `cases/` (every case names its laws in its first line): `E` § genLocalEnumConstShared184 (e01-e13; e03, e09, e13
  controls), `T` and `X` § tpEnumCopyAtTypedef184 (t01-t12, x2-x22; t03, t04 controls), `P` § memberSelParenIdxSpan184
  (p01-p07; p04 control; p07 with § incDecMemberSelIsLvalue184, § lvIdxMemberSelIsRead184,
  § genScopeTrailSelNameLate184), `I` § incDecMemberSelIsLvalue184 (i01-i03; i02 with § genScopeTrailSelNameLate184; i03
  control), `L` § lvIdxMemberSelIsRead184 (l01-l04; l02 with § genScopeTrailSelNameLate184), `G`
  § genScopeTrailSelNameLate184 (g01-g03), `R` § rootLvalueSpanAtRoot184 (r01-r04; r01 r02 copied from 181 `rt/g05`,
  `rt/s05`), `S` § streamLvMemberPathRead184 (s01-s04; s02 control), `C` § hpIdxCallNameSpan184 (c01-c03).
- `drivers/`: `env.sh` (pins, `$FENCED`), `grid.sh` / `gridall.sh` / `gridcmp.sh` (golden + ours + uhdm-cmp + strictcmp
  per case, both views; record movement), `recmv.py`, `enumrefs.py`, `obdist.py` (order-blind dump distance),
  `switchmatrix.sh`, `predict184.cpp` / `predict184.sh` / `cc184.sh` (mover predictor), `bvmirror.sh`, `probemovers.sh`,
  `rowrec.sh`, `obrows.sh`, `tracewrap.sh`.
- `evidence/`: the sweep logs, predictions, byte-verify outputs, census, switch matrix, grid tables, boundary, record
  attributions, canaries, `residue/U`.
