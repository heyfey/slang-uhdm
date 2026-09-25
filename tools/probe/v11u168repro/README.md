# v11u168: adversarial verification of r11u168 (the module/type ground, pair B: the r11u166 location model landed, six laws of its own)

Base `35ed4056` (branch matrix-1.87). Worktrees `/tmp/wt_v11u168` (the implementer's patch `/tmp/r11u168.patch`) and
`/tmp/wt_v11u168pris` (pristine), both built with system deps at `-j 2`. The patch applies clean (no
`--whitespace=fix`) on a fresh `35ed4056`. The fenced tests are written `FENCED=` here and never spelled: every script
that reads corpus databases (`drivers/rowcmp.sh`, `drivers/uvmdist.sh`, the implementer's `bvmirror.sh`) refuses to run
without `$FENCED` and skips a fenced test by word boundary; the byte comparisons ran on hard-link mirrors that leave out
the 8 fenced row-mode databases. No fenced source or database was run, read or decoded outside the gate sweeps.

## 1. Verdict

**ACCEPT, no fix needed.** Every headline number of the implementer reproduces bit-for-bit with binaries built here.
92 fresh cases attack all six r11u168 laws and the landed r11u166 location model on the shapes the brief names (pasted
tokens, stringified formals, nested calls, multi-line actuals, inactive branches, calls inside macro arguments). None
turns a pristine-right cell wrong: no case leaves strict-equal, no uhdm-cmp line count grows, and no downstream verdict
leaves IDENTICAL. Each switch drops its law alone, and with both switch sets off the bytes are pristine's on every
case. `/tmp/r11u168.verified.patch` is the implementer's patch plus this directory and the regenerated
`tests/LAWS.md`. Its source files are byte-identical to `/tmp/r11u168.patch`'s.

## 2. Binaries (frozen `chmod 555` before any measurement, `/tmp/v11u168_bin/`)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `c44c82a6e8ea26acdcb20e08215f67f4` | `35ed4056` worktree build = the brief's pristine md5 |
| `law.bin` | `ffa0d8101cf14fc3e6e3aeb88172a6db` | `35ed4056` + `/tmp/r11u168.patch` = the implementer's `dec8.bin`, byte for byte |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

The landed r11u166 part was checked against its delivery: `law_on_d48f8f8a8.patch`, `law_macroconn.patch` and
`law_litall.patch` applied to a fresh `35ed4056` give `src/EmitHelpers.h`, `src/ExprEmit.cpp` and `src/StmtEmit.cpp`
byte-identical to the patch's. The patch's remaining differences are the six r11u168 laws, in `src/UhdmExporter.cpp`,
`src/ModuleEmit.cpp` and `src/TypeEmit.cpp` only. `uhdm_main.cpp` and `src/TaskFuncEmit.cpp` are untouched.

## 3. The gate sweeps, reproduced (`tests/sweep.sh --jobs 3`, all four stages; `evidence/sweeps/`)

Pristine `/tmp/v11u168_swP` (run from the pristine worktree) and law `/tmp/v11u168_swL` (run from the patch worktree),
same-length names. All 3273 `slang:` lines of the corpus `cmds.txt` files name `/tmp/v11u168_bin/law.bin` in swL, and
all 3273 name `pris.bin` in swP. The pristine sweep exits 1 for one reason only, `law index STALE` (the main tree reads
the same at `35ed4056`). The law sweep exits **0**.

| stage | pristine | law |
|---|---|---|
| probe vs golden_probe.csv | EQUAL 2647 / STRICT_NOTEQUAL 1440, 0/0/0 | **regressions 0**, conversions 21, changes 5 (EQUAL 2668) |
| surelog vs golden_surelog.csv | 0/0/0 | **regressions 0**, conversions 8, changes 21 |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 0/0/0 | **regressions 0**, conversions 2, changes 2 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; `downstream.csv` identical to pristine's row by row |

Every conversion and change line is the implementer's, name for name and count for count. The rows it converts, from
the law sweep's csvs:

    GenForStructParamBound,default,CMP_EQUAL,,,equal     GenForStructParamBound,testflags,CMP_EQUAL,,,equal
    StructArrayNet,default,CMP_EQUAL,,,equal             StructArrayNet,testflags,CMP_EQUAL,,,equal
    YosysMarlann,default,CMP_EQUAL,,,equal               YosysMarlann,testflags,CMP_EQUAL,,,equal
    YosysOldOpen,default,CMP_EQUAL,,,equal               YosysOldOpen,testflags,CMP_EQUAL,,,equal
    ibex_load_store_unit,default,CMP_EQUAL,,,equal       ibex_load_store_unit,testflags,CMP_EQUAL,,,equal
    downstream: ibex_load_store_unit,IDENTICAL,OK,OK,736,736,,   ibex_pmp,IDENTICAL,OK,OK,52,52,,

The set of rows outside judge-equality (every status but CMP_EQUAL and STRICT_NOTEQUAL) is identical in both sweeps, in
both corpora. No row matches a crash signature.

**No strict column gets worse** (`evidence/sweeps/changed_rows_fields.txt`). I re-ran every CHANGE row with
`uhdm-strictcmp --max 100000` on both sweeps. On each one, every per-field count is at or below pristine's. Every row
whose walk diverges diverges at the same record in both: ApbSlave #372, Earlgrey_0_1 #130430, MiniAmiq #2450,
SeqDriver #2433, SimpleUVM #2484, Scoreboard #2492, Scr1SvTests #16033 and ibex_pmp #13972. So the smaller counts are
real gains, not a horizon that moved. Examples:

- Earlgrey_0_1: fullname 416 -> 407, col 142 -> 28, endcol 1212 -> 51, objects 1686 -> 511.
- MiniAmiq: line 156 -> 19, objects 183 -> 46.
- YosysOldOr: 75 -> 1.
- Rggen: bytes move but every count is unchanged.

**Byte movers** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fence-clean mirrors; `evidence/sweeps/byteverify_*.txt`):

- surelog: **30 / 952**, SELFCHECK 951 / 952.
- uhdm2rtlil: **4 / 1608**, SELFCHECK 1607 / 1608.
- The mover set is the implementer's, name for name.
- Every patched md5 matches the implementer's except the six UVM row-modes (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t). Their pristine md5s differ between our two runs as well: that is the known UVM coin.

**Canaries:**

- `r11u107repro/canaries.sh`: surelog ok=37, changed=15, and the 15 are exactly the attributed conversion and change rows; uhdm2rtlil ok=16, changed=0. The pristine control reads surelog ok=52, changed=0.
- `ctcan2.sh`: surelog `EXPECT_UNKNOWN=1` PASS; uhdm2rtlil `EXPECT_UNKNOWN=6` PASS.

**UVM file facets** (the brief's (1a) proof; `drivers/uvmdist.sh`, `evidence/sweeps/uvm_file_facets.txt`): the
order-blind distance to golden, and the method_func_call file facets ours holds that golden does not:

| row | pristine | law |
|---|---|---|
| MiniAmiq d/t | 28599 / 15 | 16872 / 15 |
| SeqDriver d/t | 29454-29455 / 15 | 15772 / 15 |
| SimpleUVM d/t | 20221 / 15 | 10672 / 15 |
| Scoreboard d | 16921 / 15 | 9306 / 15 |

MiniAmiq default re-run with `R11U168_PPFILECALL_OFF=1` (`/tmp/v11u168_swX`) reads 16872 / **215**. That reproduces
the delivered decode's FILE move and shows that § ppFileCallArgBody168 is what removes it.

## 4. The attack: fresh cases (`cases/`, 92 cases, first line `// § <law>`; `evidence/grid/`)

`drivers/case.sh` builds the golden with the pinned Surelog using check_probe's arguments (a `dut.v` case runs without
`-sv`; an `args` case lists several root files of one compilation unit). The golden is cached by the md5 of every file
of the case. The driver then runs ours with `dut.sv --single-unit --nobuiltin` and applies uhdm-cmp and uhdm-strictcmp.
Every case's rc is recorded; all 184 runs read rc=0. `evidence/grid/grid_pris_law.txt` holds both binaries' verdicts
and md5s.

| dir | law under attack | cases | pristine -> law (strict) |
|---|---|---|---|
| `H/` | § hcSelIdxInstName168 | 13 | x07 x08 x09 x10 x12 x13 -> **equal**. The index shapes are: a generate-local net, two instances crossing two buses, an ordered connection, an unpacked array element, a nested hierarchy and an array-element index. x05 x06 x11 go fullname -> depth, the pre-existing binding face at the same record #79 / #64 / #87. With 5 / 3 / 4 fullname objects cleared to 1, the same divergence becomes the first record. x02 (genvar index), x03 (package parameter index) and x04 (struct-member index) stay the same bytes. x01 (a localparam index) is stage 1 on both; order-blind it is 6 -> 4 dump lines away from golden. |
| `P/` | § paramBaseSelTsInstName168 | 6 | x03 (a bound in a concatenation plus a mixed bound, overridden instance) and x06 (a typed parameter bound) -> **equal**. x02 (package-scoped bound) and x04 (in a generate block) are untouched. x01 and x05 (both bounds parameters, both bases parameters) stay stage 1: golden folds the whole part-select to one constant, a pre-existing face. |
| `R/` | § structParamBoundAtPatternLeaf168 + § rangeHierPathNoFullName168 | 17 | Stage 1 -> **equal** on x01-x03, x05, x09-x12 and x14. The member widths are byte, shortint, `logic [3:0]`, integer, `logic [1:0]`, `bit [3:0]` and int; the patterns include `'{W: 3, default: 1}`, and x14 is a parent-parameter override. x04 (longint) goes fullname -> equal. x13 (a package-localparam override) goes stage 1 -> line: the leaf now sits at the other localparam's value, and what is left is the param_assign operation's location (5:30 vs our 12:17), outside the law. x06 (`'d3`), x07 (`cfg_t'{...}`) and x15 (literal override plus a descending dimension) stay stage 1 and move toward golden order-blind (12->6, 106->102, 30->17). x08 (`'{default: 3}`) falls back as designed; only its hier_path name moves. x16 (module arrays) is untouched: the law is gated to interfaces. x17 (interface wire arrays) stays stage 1, 49->41. |
| `U/` | § undefKeepsOtherRootMacro168 | 10 | y01 (the definition in root A's include), y02 (a bodied first definition), y04 (three roots, the undef in the middle one), y08 (drops between three includes) and y11 (a double bare redefinition in both roots) -> **equal**. y03 (bodied redefinition in the current root, then undef, then bare define) and y06 (`` `undefineall ``) keep their line, as Surelog does. y12 (same-root redefinition in an include) and y13 (unknown undef) are controls, equal on both. y10 moves 3 -> 2 objects; see residue 1. |
| `F/` | § ppFileCallArgBody168 | 9 | z07 (the outer macro in its own include), z08 (the reporting macro in the caller file) and z09 (three levels in one include): the file is golden's under the law. `R11U168_PPFILECALL_OFF` (the delivered decode) writes the wrong file on z07 and z08. The rest is the S1 span, sister ground. z01-z03 and z06 (receiver from a formal, not nested, one- and multi-line, macro in an include) are equal on both. z04 and z05 have an unchanged endline, a pre-existing face. |
| `M/`, `N/` | the r11u166 model (LINE, COL, ONELINE, LIT, MACROCONN) | 20 + 17 | Converted: m01 (an inactive `` `ifdef `` in a body, text after the call), m02 and n17 (multi-line actuals), m03 (a paste in a multi-line body), m04 and n02 (stringified formals), m06 (macro port connections: stage 1 -> equal, § macroConnInRange166), m07, m20, n03 (a nested call in a multi-line actual), n12 (empty macros before text) and n14 (a multi-line body inside a one-line wrapper). Stage 1 on both and closer order-blind: m15 (spaced literals in a body), n11 and n20. Equal on both: m05 m08-m12 m14 m16-m19 n04 n05 n07 n09 n10 n13 n15 n18. n01 (a one-line paste) and n06 (`` `line ``) are unchanged, model limits falling back to the pristine arithmetic. |

**Downstream** (`drivers/dscase.py` through the harness's own `one()`, fresh `GOLDEN_CACHE`; `evidence/downstream/`, 54
module-level cases): m02, m03, m06 and m20 go EQUIVALENT -> **IDENTICAL**. The other 50 keep their verdict: 46 are
IDENTICAL on both; R/x07 and R/x17 are DIVERGENT on both, R/x15 is EQUIVALENT on both, and M/m13 is STATUS_DIFF on
both.

**Switches** (`evidence/grid/switches.txt`): each switch was run alone over the whole grid. Every case moves only
under its own law's switch:

- `R11U168_UNDEFXROOT_OFF`: the U movers only.
- `R11U168_PSBOUNDTS_OFF`: P only.
- `R11U168_HCIDXNAME_OFF`: H only.
- `R11U168_SPLEAF_OFF` and `R11U168_RNGHPNAME_OFF`: R only.
- `R11U166_LINE_OFF`, `_COL_OFF`, `_ONELINE_OFF`, `_COL_LIT_OFF` and `_MACROCONN_OFF`: M and N only.

`R11U166_OFF=1 R11U168_OFF=1` gives the pristine bytes on all 89 cases that have a database. r11u166's laws keep their
own switches, as the brief orders, so one pass-wide off needs both variables.

**Landed-law byte controls** (`drivers/controls1.sh`; `evidence/controls/`): 1964 cases. They are every case of the
21 evidence dirs the implementer listed, plus `r11u166mac/cases` and `r11u168repro/cases`, run with both binaries;
13 cases have no database on either side (Surelog aborts or slang rejects, the same on both binaries).

- **112 byte movers, 0 away from golden.** No case leaves strict-equal and no uhdm-cmp line count grows.
- Within the implementer's 21 dirs the movers are exactly its 24.
- The rest are r11u166mac's and r11u168repro's own cases, all toward golden. Examples: r11u166mac `ds/c05` and `ds/c08` go from 31 uhdm-cmp lines to equal, and r11u168repro `R/h01`, `r11` and `r12` go from stage 1 to equal.
- r11u168repro F/f02 and f05-f07 read line first where pristine read col or endcol. The objects differing drop from 12 / 9 / … to 2 / 1, and the remaining line record is the S1 method-call record, which pristine also differs on.

## 5. Checks on the patch

- **Surface.** src (six files, three of them only at litall's compaction sites, identical to the delivery), `tests/LAWS.md` and `tools/probe/r11u168repro/`. Nothing under results/ or third_party/. No fenced name appears in the patch.
- **Law index.** `scripts/law_index.py --check` reads current on the patch tree. Every law a case names (`// § …`) exists at a site in `src`. The r11u166 laws list pass `-` in `tests/LAWS.md`, because their evidence dir `r11u166mac` does not end in `repro`. Their cases and sites are indexed, so this is cosmetic.
- **Prediction.**
  - The implementer's `pred2_*.tsv` names 32 of the 34 corpus movers before the final sweep. PackedArrayHighConn d/t were missed: the regex refused a nested bracket, and the implementer states this.
  - A predicted set of 177 rows for 34 movers is an upper bound, not a sharp prediction.
  - The predictor fails closed without `$FENCED` (`REFUSE: FENCED unset`).
- **Integration.** On the moved main tree `45b8e774`, every file applies except the generated `tests/LAWS.md`, which must be regenerated there.

## 6. Residues found here (ranked; none is a break: pristine is wrong on each, or the law moves it toward golden)

1. **U/y10.** A cross-root `` `undef `` followed by a bare redefinition INSIDE an included file lowers that included
   file's later OBJECT lines by one in golden (`module xx` at x.vh 2, ours 3). Two controls do not do this: the same-root
   redefinition in an include (y12) and an unknown `` `undef `` (y13). The law fixes the include_file_info line of the same
   case (3 -> 2 differing objects). The object line model of a redefinition inside an include is the next face of
   § undefKeepsOtherRootMacro168 / § includeInfoEmptyRedefineLine125. Not modelled: Surelog also keeps such a macro
   defined for a later `` `ifdef ``, a branch divergence no location law can fix.
2. **The S1 span of a method call whose receiver is a formal passed to a nested call**. This is ExprEmit, the sister
   ground, at the `nameSpan(recv.sourceRange.end() + 1, ...)` sites under § macroPasteRecvMisreadIsAstChain132. Our
   endline is garbage (`5:72-13:9` against golden `6:13-6:26`, cases F/z07-z09). It holds the UVM rows' remaining
   distance on this family.
3. **R/x13.** An override by a package localparam leaves the param_assign operation located at the override
   (12:17-12:27) where golden locates it at the localparam's value pattern (5:30-5:46). ParamEmit, sister ground.
4. **H/x05, x06, x11.** The binding face under an index operation: golden binds only the index's last net, the
   implementer's h15/h16 face. P/x01 and x05: golden folds a part-select whose base and bounds are all parameters to
   one constant.
5. The implementer's residues (its README sections 7-8) stand as measured.

## 7. Files

- `cases/{H,P,R,U,F,M,N}/`: 92 cases.
- `drivers/`:
  - `case.sh`: one case, both producers.
  - `dscase.py`: the downstream harness per case.
  - `orderblind.sh`: uhdm-dump multiset distance.
  - `rowcmp.sh`: strict fields of a sweep row, pristine vs law; fail-closed on `$FENCED`.
  - `controls1.sh`: one control case with both binaries.
  - `uvmdist.sh`: the implementer's UVM facet driver with this pass's paths.
- `evidence/`:
  - `grid/`: verdicts and switch matrix.
  - `downstream/`.
  - `controls/`: the case list and movers.
  - `sweeps/`: sweep logs, byteverify, changed-row field summaries and UVM facets.
