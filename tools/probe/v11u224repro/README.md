# v11u224 — adversarial verification of r11u224 (the expression/parameter ground): CONFIRMED, no fix

Base `551c9751` (pass 220). Implementer's patch `/tmp/r11u224.patch` (md5 `fdbdbae944b3509ba24bcba5d7eed3b9`). The
verified patch is that patch plus this directory, one corrected number in tools/probe/r11u224repro/README.md
(section 4, see section 9 here) and the regenerated tests/LAWS.md. **No production line changes**: the law binary
of the verified patch is the implementer's law binary, byte for byte.

## 0. Verdict

**CONFIRMED.** Every headline number of the implementer reproduces on the verifier's own builds (one README sum was
misstated, section 9). No break was found: 140 fresh cases in both views (280 case-views), a byte control over
every tools/probe case at the base (28,234 case-views), the downstream consumer on 30 fresh cases, and the four
gates. 0 case-views leave EQUAL, 0 records move away from golden in the chain-keyed census, no downstream row or
case leaves IDENTICAL, and every law drops alone.

| target (r11u224 brief) | fresh measurement at the verifier's sweeps | law |
|---|---|---|
| BlackBePipeInt testflags | `differ:depth(1)` -> `differ:type(1)`. The first strict record moves #66 -> #15268 and the object count goes 340984 -> 340760 (golden 338504). | § pcwAllPkgListingBindsOwn224 |
| BuildUVMPkg d/t | `line(19)` -> `line(14)` | § hpLvNewClassFirstElemSpan224, § hpLvSelIdxNamesByPath224, § hpLvSelColumnJoin224, § ipsBasePfxScopeJoin224, § ipsWidthPfxByPathInScope224, § sysCallTypeArgScopeJoin224 |
| Scoreboard d | `file(30)` -> `file(26)` | § hpLvNewClassFirstElemSpan224, § sysCallTypeArgScopeJoin224 |
| SimpleUVM d/t | `file(54)` -> `file(50)` | same two |
| MiniAmiq d/t, SeqDriver d/t | `file(7)` unchanged. Past the head, 13 and 15 records per mode move toward golden. | same two |
| pass-220 residues: T/t12, T/t14, SL s30 s31 s32 s35 s36 s38 s39 | STRICT_NOTEQUAL `endcol` -> **EQUAL** in both views | § strLitPpEscIdShift224 |
| pass-220 residues: K/k04, SL s48, SL s50 | `endline` -> **EQUAL** in both views | § strLitContOwnerEnd224 |
| C/c23 | `fullname` -> **EQUAL** in both views | § ipsBasePfxScopeJoin224 |
| G/g07 | `fullname` -> **EQUAL** in both views | § hpLvSelIdxNamesByPath224 |
| NW/w17 | `fullname` -> **EQUAL** (parse view); the elaborated view was already EQUAL and moves in the weaklyReferenced tail only | § newArrayBitSelIdxOpStripped224 |
| K/k09, C/c21, C/c22, CI/c09 | bytes unchanged (residues, as the implementer reports) | none |
| SL s33, s34 | EQUAL at the base, unchanged | none |
| SL s37 | Surelog writes no database | none |

The probe stage converts five cases, all quoted from this verifier's law sweep `probe.csv`:

    r10svs2repro/s5_negctl,EQUAL,,equal
    r10svs2repro/w3_macrodeep,EQUAL,,equal
    r10v121repro/v121_c,EQUAL,,equal
    r10v172repro/v172_3_pos,EQUAL,,equal
    r10v174repro/v174_b_sysfns,EQUAL,,equal

## 1. Binaries (built by this verifier, frozen `chmod 555` before any measurement)

| name | md5 | what |
|---|---|---|
| pristine.bin | `2510f4fe44619abb4eae492a1a0e737f` | `551c9751` in a fresh worktree, `-DSLANG_UHDM_USE_SYSTEM_DEPS=ON`, `-j 2`. Equal to the brief's md5. |
| law.bin | `c17d2a80d47f9ba2975511b32c70bbc1` | the patch applied (clean) to a second fresh worktree at `551c9751`. Equal to the implementer's law11.bin. |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | both worktrees' builds and the main tree's are identical |
| strictcmp_x | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant (tools/probe/r11u211map/drivers/cc.sh), built here. Equal to the implementer's. |

**cmds.txt audit** (surelog and uhdm2rtlil stages): the pristine sweep has 3273 `slang:` lines, all naming
pristine.bin. The law sweep has 3273, all naming law.bin. The other 50 of the 3323 row-modes run no slang.

## 2. Gates (tests/sweep.sh --jobs 3 against the committed baselines; workdirs of equal name length)

| stage | pristine.bin | law.bin |
|---|---|---|
| probe | EQUAL 3443 + STRICT_NOTEQUAL 644; 0 / 0 / 0 | **3448 + 639: 0 regressions, 5 conversions, 2 changes** |
| surelog | 0 / 0 / 0 | **0 regressions, 0 conversions, 6 changes** |
| uhdm2rtlil | 1600 + 6; 0 / 0 / 0 | **0 / 0 / 0** |
| downstream | 803 / 66 / 2 / 0 | **803 / 66 / 2 / 0** |

The committed baselines:

- **Downstream:** both downstream csvs are byte-identical to results/downstream_uhdm2rtlil.csv.
- **Probe changes:**
  - r10uvm147repro/g147_a: `col(14)` -> `col(6)`
  - r10uvm56repro/v3_hierpath: `endcol(6)` -> `endcol(4)`
- **Surelog changes:** exactly the six the implementer lists. The whole-column diff law vs pristine
  ([evidence/sweeps/rowdiffs.txt](evidence/sweeps/rowdiffs.txt)) holds only those rows, plus the LowMem detail
  text naming the workdir (environment).

Every change shrinks its count or moves the walk's first difference later. The chain-keyed census reads 0 away on
every one (section 4).

**The law index at the base:** every sweep exits 1 because tests/LAWS.md is stale. This holds at the base too: a
clean `551c9751` worktree reads STALE, because the index records each law's landing commit, and a landing commit
cannot list its own hash. The verified patch carries the index regenerated with this directory in the tree.

**Canaries** on the law csvs:

| check | result |
|---|---|
| canaries.sh, surelog | ok=47 changed=5: the five SimpleUVM, BuildUVMPkg and Scoreboard changes |
| canaries.sh, uhdm2rtlil | ok=16 changed=0 |
| ctcan2 EXPECT_UNKNOWN=1, surelog | ok=57 changed=1: BlackBePipeInt t, the claimed change. The pristine csv reads ok=58 PASS. |
| ctcan2 EXPECT_UNKNOWN=6, uhdm2rtlil | PASS |

**uhdm-cmp** reads 0 lines on every touched row-mode and probe case: all of them are judge-equal in the law sweep.

## 3. Movers (the implementer's prediction, frozen before its law sweep, checked)

**The prediction was frozen before the sweep.** predict_final.txt (md5 `c7573329...`) is stamped
08:21:59Z. The implementer's law-sweep probe directory was born at 08:22:14Z.

| set | movers | how measured |
|---|---|---|
| corpus | **10 of 2560**: BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t, SimpleUVM d/t, BlackBePipeInt t | byteverify, SELFCHECK=1, on hard-link mirrors without the 8 fenced row-mode databases (drivers/bvmirror.sh) |
| probe | **7 of 4087**: the five conversions and the two changes | byte comparison (see below) |
| downstream lanes | **0 of 805** | slang.uhdm, law vs pristine downstream sweeps |

- **Corpus:** every mover is predicted by name.
  - StringWithBackslash d/t (uhdm2rtlil) was predicted but does not move. The implementer explains why: its two
    escaped identifiers give +8 under both the new and the old count.
  - SELFCHECK reads 2559 of 2560. The negative control compares every patched file against ONE fixed pristine file
    (the first path). The patched file at that same path is byte-equal to it whenever it is not a mover, so that
    one path can never be flagged. This is an artifact of the self-check, not a mover line.
- **Probe:** exactly the 7 predicted.
  - The probe databases embed the source path, and the two gate sweeps ran from two worktrees. So the pristine
    probe stage was re-run from the law worktree (`Q`, 3443 + 644, 0/0/0) and compared byte for byte with the law
    probe stage.
- **Downstream lanes:** no lane directory holds a fenced name as a word. One uhdm2rtlil test holds one as a
  substring; it is a different test.

**R11U224_OFF over the whole corpus** (law.bin, surelog + uhdm2rtlil): 0 / 0 / 0 in both stages, and byteverify
against the pristine sweep reads **0 of 2560 movers**
([evidence/movers/byteverify_R11U224_OFF.txt](evidence/movers/byteverify_R11U224_OFF.txt)).

## 4. Away-moved census (map 12 / map 13, chain-keyed, raw full names; drivers/awayrows.py)

Over the 17 moving databases the census reads **chain away 0, toward 134**, and flat toward 131 with 13 flat away
on BlackBePipeInt t alone. The reversed positive control reads **away 134**
([evidence/away/](evidence/away/)). The per-database lines are identical to the implementer's evidence, line for
line.

**The flat 13 on BlackBePipeInt t** are the ours-only expansion that pristine walked at #66: the module copy's
`dev_addr_width_gp` subtree, depth 6, where golden walks `host_dev_gp` at depth 2. Its records match golden records
elsewhere in the flat multiset. The strict walk itself agrees with golden through #15267 now, where it diverged at
#66. This is the flat-key artifact pass 219 described.

## 5. Breaking the laws: fresh cases (cases/, 140 case directories, both views)

Each case dir holds `dut.sv`, whose first line names its law. Goldens come from the pinned Surelog
(`-parse -nobuiltin -nocache -sv`, plus `-elabuhdm` in the elaborated view). Ours runs with
`--single-unit --nobuiltin` (and `--elabuhdm`), judged by uhdm-cmp and then uhdm-strictcmp. Run with
drivers/grid.sh; evidence in [evidence/grid/](evidence/grid/).

| group | law | cases | views | enter EQUAL | leave EQUAL | moved w/o converting (0 away) |
|---|---|---|---|---|---|---|
| SX | § strLitPpEscIdShift224 | sa01-sa12, sb01-sb08, sx01-sx16 | 72 | 54 | 0 | 14 |
| CX | § strLitContOwnerEnd224 | ca01-ca04, cb01, cb02, cx01-cx09 | 30 | 22 | 0 | 4 |
| HX | § hpLvNewClassFirstElemSpan224 | hb01-hb07, hc01, he01, he02, hx01-hx10 | 40 | 25 | 0 | 3 |
| LX | § hpLvSelIdxNamesByPath224 | la01-la08, lb01, lb02, ld01-ld06, le01, lx01-lx17 | 68 | 34 | 0 | 20 |
| IX | § ipsBasePfxScopeJoin224 | ib01-ib04, ic01, ix01-ix08 | 26 | 11 | 0 | 11 |
| NX | § newArrayBitSelIdxOpStripped224 (nb01, nc01, nx01, nx03, nx04); § newArrayVarSelStripped224 (nb02, nx02, nx05) | 8 | 16 | 9 | 0 | 2 |
| BX | § sysCallTypeArgScopeJoin224 | bc01-bc04, bd01, bx01-bx06 | 22 | 4 | 0 | 2 |
| DS | § strLitPpEscIdShift224 (ds01, ds02); § strLitContOwnerEnd224 (ds03) | 3 | 6 | 6 | 0 | 0 |
| **total** | | **140** | **280** | **165** | **0** | **56** |

- **Movers:** 224 case-views move.
  - **Away census:** 0 in all three censuses (chain-keyed, flat, and the uhdm-dump multiset with the
    weaklyReferenced tail cut). 994 chain-keyed records move toward golden.
  - **Changed strict details:** on every one the first walk difference moves later, or the count shrinks with the
    same first field.

    | case | pristine | law |
    |---|---|---|
    | bx05_el | fullname #13 | endcol #34 |
    | sx11 | endcol #14 | col #17 |
    | sb05 | endcol #2 | type #77 |
    | nx05 | fullname #47 (7 objects) | fullname #57 (1 object) |
    | ib01_el | fullname (2 objects) | fullname (1 object) |

- **R11U224_OFF** writes the pristine binary's bytes on all 276 case-views that produce a database. On the other
  4 (ld03, ld04), slang rejects the design with both binaries.
- **Each law drops alone.** Every one of the 224 moved case-views is restored to the pristine bytes by exactly its
  own law's switch, except ix06, lx15, lx16, lb01, lb02, he01 and he02. Those need their law pair
  (IPSPFXJOIN+IPSWIDTH, LVSELIDX+LVSELCOL), or the three laws the case mixes on purpose (he01, he02:
  LVNEWSPAN+SYSTYPEJOIN+IPSPFXJOIN), and restore under that set
  ([switch_reach_fresh_and_wide.txt](evidence/grid/switch_reach_fresh_and_wide.txt),
  [switch_reach_batteries3to6.txt](evidence/grid/switch_reach_batteries3to6.txt)).

**Shapes the brief asks for, and where they are:**

| shape | cases |
|---|---|
| implicit nets | lx13 (an implicit net as the lvalue path index: converts) |
| interface bodies | lx08, ix01, ib03, hb03 |
| class specializations in bounds and widths | ix06, bx04, bc02, sa02 |
| `this.` paths | hx01, lx16, nx04 |
| named calls | hx05 (named constructor arguments), le01 (a named call as an lvalue index) |
| extern and pure virtual prototypes above and below the caller | he01, he02, ib02 |
| for-generate, two-level generate, if-generate | lx04, lx17, la01, hb01, sa10, ca04 |
| instance depth 3 | la02, hb02 |
| inc/dec, compound assignment, concatenation lvalue | lx11, lx12 |
| unary, call and path indices, paths two levels deep | la03, lx06, lx05, lx14 |
| enum, package-qualified and `$unit` indices | ld01, ld02, ld06 |
| macro-born tokens | sx11, sa01, sb04, sb07, hb06 |
| package imports and importer clones | sb05, sb06, cb01, cb02, lb01, lb02, nc01, hc01, ic01, bd01 |
| program blocks | hb07, bc03 |
| every escape shape the preprocessor lexer can meet | see below |

The escape shapes: `` `\ `` (Macro_Escaped_identifier, sx01), `\W` and `\S` (sx07, sa05, sa07), a backslash then a
blank (sb02), `` \` `` (sb01), `\x41` (sx09), `\\\\` (sa06), a tab (sa09), a trailing blank (sb03), brackets (sx14,
sa12).

**Downstream on fresh cases** (drivers/dsgrid.py, the harness's own `one()`; [evidence/downstream/dsgrid_fresh.txt](evidence/downstream/dsgrid_fresh.txt)):

- ds01 and ds02 go **EQUIVALENT -> IDENTICAL**: the string law's line shift reaches the RTLIL src attributes of
  the processes after the literal.
- The other 28 cases (the whole LX group and ds03) keep their verdict, and none leaves IDENTICAL.
- lx05, lx14 and lb02 are DIVERGENT on both binaries, with the slang lanes' `_nohier.il` identical.

## 6. Wide byte control (drivers/bytes.sh + judge.sh; [evidence/wide/](evidence/wide/))

Every tools/probe case directory at the base ran in both views with pristine.bin and law.bin: **28,234
case-views**. Paths holding a fenced name, word-bounded, are refused unread; none occurred.

**Exit-code parity is exact:** 0 case-views differ in rc.

- 278 case-views are rc 3 on both binaries: slang rejects them, and no output exists.
- 13 are rc 139 on both: a pre-existing crash. These are r10v226 b13, r10vrgg8 v8_recurse*, r11v105 v09,
  r11v124 x02, v11u112 m07 and v11u219 s01*; the $size crash was fixed at HEAD by pass 223.

**54 case-views move with rc 0. 35 enter EQUAL and 0 leave.** The other 19:

- **Eight `--elabuhdm` cases of § pcwAllPkgListingBindsOwn224** (r11u191dec B/b01, r11u207repro P/p02 and p03,
  r11u213verify CW/w01, w02 and w04, X/x01, v11u207repro G/g03) are stage 1 on both binaries, from the sister's
  module import copies.
  - Their flat census reads 3-21 away, and w02 reads 2 away chain-keyed. On all eight, the law's walk agrees with
    golden **longer**: its first walk-order difference moves from #7-#10 to #24-#53
    ([walkprefix_nonconverting.txt](evidence/wide/walkprefix_nonconverting.txt)).
  - On w02, golden's first p1 listing (records 2-18) equals the law's exactly. Pristine expanded the mark there
    into `p2::dw` and `work@top.dw`.
  - The "away" records are pristine's wrong expansion whose chain key (type:name only) collides with golden's
    correct expansion in the SECOND p1 listing (TopPackages). Both binaries write that listing identically,
    unexpanded.
  - This is a key-collapse artifact, not a loss.
- **Four views read 0 in every census:** v11u187 T/t35 and v11u220 G/g26 (both views). They are stage 1 on both,
  and the first walk difference is unchanged (#94, #67). This is wrong to wrong: the lvalue branch writes
  `bit_select`+`part_select` where golden holds a `var_select`, and only the index name moves.
- **Seven views move toward:** the r11u220 / v11u220 K and NW cases.

Three converting directories lie outside the implementer's 611-case wide set, and all convert:

- r11u123canon t01_class_self_member
- r11v169repro ml/mb10
- r11v174repro dp/d03

## 7. Other reproductions

- **Own grid** (tools/probe/r11u224repro/cases, 124 dirs, 248 views, this verifier's goldens): 123 enter EQUAL,
  0 leave. R11U224_OFF writes the pristine bytes on all 248 (the three SURELOG_FAIL dirs hn08, hn12 and sp36
  checked by direct byte comparison).
  - 163 views move, where the implementer counts 161: hn12, which leaves Surelog no database, moves in both views
    unjudged.
  - 149 are restored by their own law's switch alone, and 14 by exactly their pair: the implementer's 147 + 14,
    plus hn12's two, which LVNEWSPAN restores.
- **§ landingSwitchReach224** (drivers/reach224.sh on the same case roots as the implementer): the numbers match
  the implementer's table exactly ([evidence/reach/](evidence/reach/)).

  | pass | case-views | old switch moves | split moves | split moves where the old does not |
  |---|---|---|---|---|
  | 112 | 204 | 106 | 54 | 0 |
  | 175 | 160 | 56 | 34 | 0 |
  | 183 | 406 | 191 | 107 | 0 |
  | 191 | 358 | 146 | 70 | 0 |

  The split gates sit only in ExprEmit, ParamEmit and StmtEmit. The old switches keep every check they had.
- **Determinism** (drivers/det.sh, three concurrent harness runs, both binaries; [evidence/det/](evidence/det/)):
  - Earlgrey_0_1, SeqDriver, SimpleUVM and BuildUVMPkg give one hash per row-mode on both binaries. Earlgrey's
    hashes are the same on both.
  - MiniAmiq d and Scoreboard d give two hashes on BOTH binaries (pristine 21ff/99fe and 10e7/1c15). These are the
    known coins, not new. Their dumps are identical within a set of draws.
  - The Scoreboard d draw of the gate sweep lists the svunit class methods in another order: 92 dump lines, before
    the weaklyReferenced tail, with the same `file(26)` verdict in all four law draws. This is pass 221's svunit
    listing-order coin.
- **UVM order-blind distance** (drivers/uvmdist.sh): the numbers match the implementer's exactly
  ([evidence/det/uvmdist.txt](evidence/det/uvmdist.txt)).

  | row | before | after |
  |---|---|---|
  | MiniAmiq | 2461 | 2448 |
  | SeqDriver | 2122 | 2107 |
  | SimpleUVM | 1535 | 1524 |
  | Scoreboard | 1098 | 1089 |
  | BuildUVMPkg | 648 | 636 |

- **Item 2** (pass 215's stamp against r11u214's law), with pristine.bin:
  - **R11U215_TDALIAS_OFF:** the probe stage is 0/0/0. The single byte mover (r10uvm49repro/a3) has a uhdm-dump
    identical line for line, ids included. On the six corpus tests (both modes) the csv is identical, with 9 byte
    movers. BuildUVMPkg d, SeqDriver d and SimpleUVM t have dumps identical both sorted and unsorted.
  - **R11U215_ENUMCLONE_OFF:** 0 probe byte movers.
  - **Conclusion:** the claim holds, and no inert switch is warranted.
- **Composition with HEAD** (`75a564b0`, pass 223 landed after the base): the patch's source files apply clean.
  Only tests/LAWS.md conflicts, and it is regenerated at integration.

## 8. Residues found by this verification (ranked; none is a break)

1. **A macro-born string literal with a backtick.** The law shifts the literal's own end, but not the objects after
   the macro call on the usage line, which Surelog does shift: SX sx11 `` `M("a\nb` c") k = 1; `` moves from
   `endcol` #14 to `col` #17 (6 objects). ExprEmit's `isMacroLoc` branch of the StringLiteral branch.
2. **§ hpLvSelIdxNamesByPath224 inside an lvalue select's index** (`o[s.arr[i][1:0]] = d`, v11u220 G/g26, and
   v11u187 T/t35). Golden builds the read form, a `var_select` holding the part select, named `...arr.i`. Ours
   builds `bit_select`+`part_select`, and the law names the index `...[1:0].i`. Stage 1 on both, wrong to wrong.
   ExprEmit, the lvalue branch of the hier_path builder (pass 218's § lvIdxPathRangeTailIsRead218 face).
3. **A package-qualified variable as an lvalue path index** (LX ld02 `s.arr[p::k][1:0]`). Pristine already writes
   the name `p::@@BAD_SYMBOL@@`; golden writes `p::k`. The law now writes golden's prefix. ExprEmit, stage 1 on
   both.
4. **A `$unit` class's element index in the elaborated view** (IX ib01_el: golden
   `work@c::f::arr[i].v[k+:2]::i`, ours `work@c::f::i`). The parse view converts.
5. **A part select inside `new[...]`** (NX nx05 `new[arr[k][k][1:0]]`): golden `arr.arr`, ours
   `p::c::f::arr.arr`. After § newArrayVarSelStripped224 this is the one object left.
6. **The implementer's residues stand as listed:** BlackBePipeInt #15268/#15272, the sister's UVM and Earlgrey
   heads (the Earlgrey #106660 `ref_typespec` full name was re-read here), the minted clone return variables, C/c21,
   C/c22, K/k09, HN hn10, TP tp12, the six unsplit cross-ground switches, and the carried faces.

   The decode of the 598 minted return variables was checked in UHDM's templates/clone_tree.cpp:
   `function::DeepClone` copies `Return()` by pointer.
7. **Untested (no legal shape was found):** a macro-stringified literal (`macroQuoted9`) whose text holds a backtick
   and an escaped identifier. The design-final registration loop of § strLitPpEscIdShift224 would treat it as a
   plain literal.

## 9. Corrections to the implementer's README

- **Section 4 read "away 0, toward 159" and "the reversed positive control reads away 159".** Its own evidence
  files (awayrows_law.txt, awayrows_reversed_control.txt) sum to **134** chain-keyed toward (131 flat), and this
  verifier's census reads the same 17 lines. The line is corrected in place, with a note.
- **Section 5.1's "161 moved case-views"** leaves out hn12, whose two views move without a golden (section 7 here).
  This is not corrected in place.

## 10. Fence and process

- **The fence:** every driver here reads the four names from the FENCED= line of
  tools/probe/r11u107repro/canaudit.sh through drivers/env.sh, and fails closed.
  - bvmirror.sh, awayrows.py, bytes.sh, judge.sh, caseaway.py, walkprefix.py, dsgrid.py, switches.sh, grid.sh,
    case.sh, det.sh and uvmdist.sh all read it.
  - The gate sweeps dispatched every row as the gate mandates.
  - No binary, gdb session or script ran on a fenced test's sources or databases outside them: byteverify ran on
    mirrors without the 8 fenced row-mode databases.
  - Every evidence file drops every line that holds a fenced name, even as a substring. A word-bounded grep of this
    directory for the four names reads 0.
- **Processes:** no process was killed. One removal command was refused by the tool's safety check (an unguarded
  `$t/*.uhdm`); it was rewritten with literal paths and nothing was deleted.
- **Scratch and worktrees:** scratch lived under `/tmp/v11u224_*`, with worktrees `/tmp/wt_v11u224`,
  `/tmp/wt_v11u224pris` and `/tmp/wt_v11u224head` (the last for the HEAD apply check only).
- **Drivers:** they resolve their paths from this checkout. `$B` (the frozen binaries) and `$S` (the scratch root)
  come from the caller.

## 11. Files

- **`drivers/`:**
  - Copied from r11u224repro, each marked in its header: env.sh, case.sh, bvmirror.sh, awayrows.py, det.sh,
    uvmdist.sh, reach224.sh.
  - New: gsweep.sh, grid.sh, judge.sh, bytes.sh, caseaway.py, walkprefix.py, switches.sh, dsgrid.py.
- **`cases/`:** SX, CX, HX, LX, IX, NX, BX, DS (140 dirs; each dut.sv names its law on its first line).
- **`evidence/`:**
  - sweeps/: the law csvs, rowdiffs.txt and the sweep logs
  - movers/, away/, grid/, wide/, reach/, det/, downstream/, pass215/
