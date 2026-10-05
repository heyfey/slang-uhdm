# v11u247 — adversarial verification of r11u247

Verifier of pass r11u247 (PAIR B, the module/type ground), base `08d31c79`, worktrees `/tmp/wt_v11u247` (law) and
`/tmp/wt_v11u247pris` (pristine). **Verdict: PASS, no production fix.** Every headline number of the implementer
reproduces bit for bit on binaries I built myself; 60 fresh cases in both views (120 case-views, 1080 grid lines)
found no case where pristine was right and the law is wrong. One delivery defect is fixed (no database changes):
six of the implementer's cases named laws that do not exist in their first line, so tests/LAWS.md attributed
§ cloneArrTsHomeRefOwn247 no case at all.

## Binaries (built by me, frozen `chmod 555` before any measurement)

pristine `2af88ce8c0c70f3e728d6e8fdfaf0d9a` (equal to the main tree's build), law `da60f833fd263102ef74d71140183800`
(the implementer's md5), uhdm-strictcmp `fa6e4f42f252ae0ab69d9845003e71c5`. Every cmds.txt of both corpus sweeps
names its own frozen binary: 3265 of 3315 per sweep (fence-filtered list; the other 50 have no slang line).

## Reproduced (each equal to the implementer's report)

* **Sweeps** (`tests/sweep.sh --jobs 3`, both run from the law worktree so the probe databases embed the same
  path; `evidence/sweep_law.log`, `evidence/sweep_pristine.log`):
  * probe: law 3511 EQUAL + 576 STRICT_NOTEQUAL, regressions=0, conversion `r10svs6repro/b4_qual`
    (fresh row `r10svs6repro/b4_qual,EQUAL,,equal`), change `r10uvm52repro/a1` `differ:line(2)` -> `differ:depth(1)`;
    pristine 3510 + 577, 0/0/0.
  * surelog: 936 + 18, regressions=0, conversions=0, changes=6: BuildUVMPkg d/t `endcol(3)` -> `type(1)`,
    MiniAmiq d/t and SeqDriver d/t `depth(1)` -> `type(1)`. uhdm2rtlil 1606 + 0, 0/0/0. Row by row, the law csvs
    differ from the pristine csvs only on these 6 surelog rows, the 2 probe rows and the LowMem log-path text.
  * downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on both, the two csvs identical;
    slang-lane databases moved 0 of 805.
  * Every sweep's exit 1 is the law-index check alone (stale at the base: `scripts/law_index.py --check` in the
    pristine worktree reads STALE).
* **First records** (`evidence/heads.txt`, uhdm-strictcmp golden vs ours):

  | row-mode | pristine | law |
  |---|---|---|
  | BuildUVMPkg d/t | #91593 int_typespec 9187:66-9187:69 golden, -9187:78 ours; #129711 14837:35 golden, 14699:13 ours | #153018 golden constant INT:63 60725:24, ours operation (ground A, StmtEmit `arrayVarArrayTs`) |
  | MiniAmiq d/t | #76762 golden class_var `uvm_pkg::uvm_phase::execute_phase::iter` 164:49, ours method_func_call 165:29 | #78478 golden unlocated int_typespec, ours class_typespec `uvm_phase` 575:33 (objects 434326 -> 434734 of golden 435559) |
  | SeqDriver d / t | #76718 / #76730, the same face | #78434 / #78446, the same face as MiniAmiq |
  | SimpleUVM d/t | #98800 / #98812 enum_typespec vs unsupported_typespec (ground A) | unchanged |
  | Scoreboard d | #130737 constant INT:63 vs operation (ground A) | unchanged |

* **uhdm-cmp** 0 lines (rc 0) on all 9 law corpus movers.
* **Byte movers** (`tools/probe/r11v75repro/byteverify.sh` on fence-filtered hard-link mirrors, `drivers/bvmirror.sh`,
  8 fenced paths skipped by name; `evidence/byteverify.txt`): **9 of 2560**, SELFCHECK 2559 / 2560 flagged; probe
  **4 of 4087** (b4_qual, a1, g208_e_head, v208_f_io); downstream 0 of 805. All 13 are named in the implementer's
  prediction frozen before its law sweep (`r11u247repro/evidence/prediction.txt`), and no other database moved.
  Law + `R11U247_OFF` writes pristine bytes on all 9 corpus movers.
* **Away census** (chain key, `drivers/awayrows.py` with the variant comparator built by `drivers/cc_x.sh`,
  `evidence/away.txt`): away=0 on all 13 moved databases; toward 431 per MiniAmiq mode, 256 per SeqDriver mode, 9 per
  BuildUVMPkg mode, SimpleUVM mode and Scoreboard d, 2 b4_qual, 1 a1, 0 on g208_e_head and v208_f_io. Flat-key
  losses MiniAmiq 27 and SeqDriver 17 per mode, as reported (pristine surplus records, chain away 0). Positive
  control: the swapped run reads every toward count as away (`evidence/away_swapped.txt`).
* **Canaries**: surelog ok=48 changed=4 (SeqDriver d/t, BuildUVMPkg d/t), uhdm2rtlil ok=16 changed=0;
  `EXPECT_UNKNOWN=1 ctcan2.sh` PASS (ok=58) and `EXPECT_UNKNOWN=6` PASS (ok=2).
* **Determinism** (`drivers/det.sh`, three concurrent draws of the law binary, `evidence/determinism.txt`): one hash
  per row-mode on 11 of 11, each equal to the law sweep's database (Scoreboard testflags is a SLANG_REJECT).
* **The implementer's grid** (`evidence/grid_r11u247_cases.txt`): 558 lines, verdicts identical line by line to its
  evidence/grid.txt; 48 case-views enter STRICT_EQUAL, none leaves, no uhdm-cmp line count rises, `R11U247_OFF`
  pristine on 62 of 62, per-switch movers ELEMALIAS 6, HOMEARRTS 2, HOMEVARDUP 2, KWELEM 14, PUREFORMAL 14,
  TPKWELEM 20. Downstream on its 31 cases + decode d01 + v11u245 A/a06: pristine 26 IDENTICAL / 2 EQUIVALENT /
  1 DIVERGENT / 4 STATUS_DIFF, law 33 IDENTICAL (`evidence/downstream_r11u247_cases.txt`).
* **Byte controls** (`drivers/controls.sh`, `evidence/controls.txt`): the implementer's 10 repros plus r11u118repro,
  r11v11u118repro, r11u119repro, r11u231repro, r11u237repro, v11u237repro, r11u239repro and v11u239repro: 2406
  case-views, 4816 lines with exit codes. 2390 byte-identical, 16 moved (exactly the implementer's 16): 4 enter
  STRICT_EQUAL (v11u241 AR/r09, v11u245 A/a06, both views), none leaves, no uhdm-cmp line count rises; the 12
  stage-1 movers read away=0 by the chain key (r11u234dec N/n05 1, v11u241 AR/r02 9, AR/r03 2, v11u243 E/e01_mixed 1,
  v11u244 E/e07_x_2d_assoc 3 / 6, W/w04_x_forms 2 toward). Non-zero exits only where pristine has the same one
  (rc 4: r11u188 T t11-t19, r11u241 TD d05 / d08, r11u243 decode tf_f01-f04, r11u244 X/x02, r11u245 UA a02 / a06;
  r11u244 F/f19 slang rc 3).

## Attack grid (60 fresh cases, both views, 9 configurations; `drivers/grid.sh`, `evidence/grid.txt`)

1080 lines, each with its exit code. **40 case-views enter STRICT_EQUAL, none leaves**; `R11U247_OFF` gives pristine
bytes on 120 of 120; each switch moves only its own law's cases (ELEMALIAS 12, HOMEARRTS 10, HOMEVARDUP 8, KWELEM 18,
PUREFORMAL 22, TPKWELEM 10 case-views). Chain-keyed away census on every moved case-view (`drivers/awaycase.py`):
**away=0 on all**. Downstream (`evidence/downstream_cases.txt`): pristine 50 IDENTICAL / 5 EQUIVALENT / 3
STATUS_DIFF / 2 DIVERGENT, law 54 / 2 / 1 / 3; no case leaves IDENTICAL. The only non-zero exits are K/k10_union and
E/e07_multidim, rc 4 on both binaries (pre-existing exporter exits: an unpacked union with an array member, and a
class property `my_t m2[2][3]` / `v_t dq[][$]`).

| cases | what | law | result |
|---|---|---|---|
| P p01-p12 | pure virtual formals: `logic`/`reg`/`bit` vectors, 2-D packed, every atom with signing, unpacked formals and defaults, a class in a module, `$unit`, `const ref`/`var`/`ref`/`output`/`inout` (p06, stage 1 on both, abstains), a parameterized base and specialization, CRLF with the signing on the next line, one header macro in two packages, macro-argument types, a DPI import and an out-of-body extern beside the prototype, extern overrides in an importer copy | § pureVirtFormalSignKwTrim247 | 11 of 12 enter STRICT_EQUAL in both views; p06 unchanged |
| H h01-h07 (+ `q` variants) | multi-line macro locals: three expansions, in-body methods and package functions, a type argument per expansion, fork branches, two headers declaring at the same line and column, a nested macro; the `q` variants add an importer package (`package q; import p::*; class u`), the shape that makes the copy | § cloneStmtHomeVarDupKeyByOrder247 | without an importer package the law cannot fire (pristine already STRICT_EQUAL); with it h01q enters STRICT_EQUAL, the others stay stage 1 (the importer copies' other faces) with 6-18 records toward and 0 away |
| A a01-a05 (+ `q` variants) | home foreach operands vs the copy's array_typespec: a local shadowing a class property and `this.` paths, sibling blocks declaring the same name (dynamic and queue), queue and associative locals in a task, in-body methods and package functions, two importer modules | § cloneArrTsHomeRefOwn247 | a03q enters STRICT_EQUAL; a01q / a02q stay STRICT_NOTEQUAL with the same first field (2 toward each); 0 away everywhere |
| T t01-t07 | keyword-default type-parameter array elements: `bit`/`int unsigned` defaults with a specialization, `logic [3:0]` / `string` defaults (t02, abstains), a typedef default (t03, abstains), a class in a module with `m[T]`, a derived class `#(T)`, `$unit` with a 2-D fixed array, signed and atom defaults (t07, stage 1 on both, 2 toward) | § clsTpKwDefaultArrElemAtUse247 | t01, t04, t05, t06 enter STRICT_EQUAL |
| K k01-k11 | `bit`/atom elements: package typedefs (k01, k04: stage 1 on both, ParamEmit emitPackage's listing first), $unit and package struct members, `reg`/`logic`/2-D/`integer`/`time`/`longint` (k03, the 2-D face first), a function formal, a parameterized submodule, a generate block (k05, k07, k08), every atom with signing (k09), an unpacked union and struct bit members (k10, rc 4 on both) | § anonAggElemKeywordTs247 | k06, k09, k11 enter STRICT_EQUAL; downstream k02, k09, k11 EQUIVALENT -> IDENTICAL, k06 STATUS_DIFF -> IDENTICAL |
| E e01-e07 | class-property element alias names: alias of alias, a package-qualified element from another package (e02), class-scope typedefs and enums with a derived class, a class in a module, a parameterized class, struct and enum elements, multi-dim / static / local / rand | § clsPropElemAliasName247 | every move 0 away by the chain key; e06 STRICT_EQUAL on both |

### Findings on the attack grid (none a regression)

1. **K/k05_gen: uhdm-cmp lines 92 -> 476 (stage 1 on both), downstream STATUS_DIFF -> DIVERGENT.** Not a law
   defect: pristine stops at the `bit` element typespec (golden bit_typespec, ours logic_typespec) and the law clears
   it; the walk then meets the generate-block face, which reads 476 lines on BOTH binaries when the module holds only
   the generate block (K/k07_genonly 476 / 476, and the `logic` twin K/k08_genlogic 476 / 476). The same module
   without the generate block (K/k06_sub) goes stage 1 -> STRICT_EQUAL and STATUS_DIFF -> IDENTICAL. k07 is
   DIVERGENT downstream on pristine as well ("Constant value mismatch"): pass 245's residue "statements in a
   generate block's def view" (US/u15, ModuleEmit), now with a downstream reader face. Away census on k05: 0 away,
   16 toward.
2. **E/e02_qual: bytes move, 0 toward, 0 away, verdict `name` on both.** For an element typed `a::my_t` from another
   package golden binds the listing object `a::my_t` itself and has no per-declaration alias; ours already writes a
   per-declaration copy (pass 243's residue x01, LAW S on a package-qualified type in a foreign package), and the law
   renames that ours-only copy's alias to `p::q::aq::my_t`. Harmless (no golden record moves), but the law fires on a
   shape golden does not have; it disappears once x01 is fixed.
3. **E/e01_alias2: flat key 1 away, chain key 0.** A bare `my_t` alias golden lists 4 times moves to
   `p::q::fa::my_t`, a name golden lists at that chain position; the flat record matched one of golden's 4 bare
   records in another context (the pass 241 reading).

## Delivery defect fixed (no database changes)

Six of the implementer's cases named laws that do not exist in their first line: `r11u247repro/cases/F/f01`
(`cloneLocalArrayTsHomeForeachOwn247`) and `T/t01`-`t05` (`clsTpDefaultElemSharesTpTs247`). LAWS.md therefore listed
no case for § cloneArrTsHomeRefOwn247 and only t06-t11 for § clsTpKwDefaultArrElemAtUse247. Each first line now
names the law whose switch changes that case's bytes (F/f01: R11U247_HOMEARRTS_OFF; T t01, t03-t05:
R11U247_TPKWELEM_OFF; T/t02, the scalar control no switch moves, is marked as that law's control). Rerun on both
binaries: the same verdicts (f01 fullname -> STRICT_EQUAL 543 / 750 objects, t01 / t03 / t04 / t05 line ->
STRICT_EQUAL, t02 STRICT_EQUAL on both). tests/LAWS.md is regenerated.

## Process notes (the implementer's, read from its README, and mine)

* The implementer's `pkill -f` on a pattern holding its own scratch path killed its own shell (the brief forbids
  `pkill -f`); its `pgrep -f` waiter matched its own shell. Both recorded in its README; no other process was named.
* Mine: no process listed or signalled other than my own background tasks by id; every corpus path list was filtered
  by `$FENCED` (word boundary, read fail-closed from tools/probe/r11u107repro/canaudit.sh) before any file was opened;
  byteverify ran on fence-filtered mirrors; the away census skips fenced rows unread; uhdm-cmp and the record dumps
  were run only on the 9 UVM movers, none fenced. One driver mistake: my first `sed` on the copied `case.sh` broke
  its `rel=` line; it was rewritten before any run. Two first-draft cases were illegal or rejected (K/k04's
  `$unit` type in a package function: slang rc 3; H/h07's nested macro with arguments: Surelog failure); both were
  rewritten and only the rewritten runs are in evidence/grid.txt.

## Residues, ranked (for the next pass on this ground)

1. The ground-A heads: MiniAmiq / SeqDriver #78478 / #78434 / #78446 (StmtEmit § cloneLoopVarHomeObject183 /
   § cloneLoopVarClassPropArrayTs238, the associative member array over a dotted loop list, decode
   r11u247repro/decode/d01), BuildUVMPkg #153018 (StmtEmit `arrayVarArrayTs`), SimpleUVM #98800 / #98812 (ExprEmit
   § dpiExportedPkgSubBareOwnTdUnsupported170), Scoreboard #130737 (ParamEmit / ExprEmit folded constant).
2. The generate-block def view (K/k07, DIVERGENT downstream on both binaries; pass 245's US/u15, ModuleEmit).
3. Exporter exit 4: an unpacked union with an array member (K/k10), a class property `my_t m2[2][3]` or a queue of
   dynamic arrays (E/e07).
4. Package-qualified element typedefs from another package (E/e02, pass 243's x01).
5. The importer-copy faces stage 1 on both binaries (H h02q-h07q, A a04q, a05q: integer locals and package functions
   in importer copies), pure virtual formals with `const` / `var` / `ref` (P/p06, stage 1 on both), `logic` / `string`
   / typedef type-parameter defaults (T t02, t03), package array typedef listings (K k01, k04), 2-D $unit arrays (K/k03).

## Drivers

`drivers/env.sh`, `case.sh`, `controls.sh`, `dscases.py`, `bvmirror.sh`, `det.sh`, `awayrows.py`, `cc_x.sh`,
`strictcmp_x.cpp` (copied from r11u247repro/drivers, header line added), `grid.sh` (this pass: four cases in
parallel, optional fix-binary columns) and `awaycase.py` (this pass: the chain-keyed census on case.sh's store). Every
driver reads `$FENCED` fail-closed and resolves its paths from the repo.
