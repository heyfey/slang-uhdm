# r11v11u10 — the ADVERSARIAL VERIFICATION of r11u10, and the `!overridden` gate

Base commit `056796c3`. Pristine worktree `/tmp/wt_v11u10pris`, law worktree
`/tmp/wt_v11u10`. Everything here is measurement-only; the judge is the
official `uhdm-cmp` through `scripts/verify_golden.py`. `results/*.csv` are
NOT edited by this pass.

Two binaries were built from scratch by the verifier, `-j 2`, md5 taken
separately, both frozen `chmod 555` before any sweep:

    pristine  0978a9156e9c598936519e7a86ff505d   (= the main tree at 056796c3)
    r11u10    734455b3bb05aec1571d65f3579c6fc7   (= the implementer's own md5)
    +fix      5d0f1ed4ea9005b86f909ba4bec450e1   (r11u10 + § the !overridden gate)

## 1. What reproduced, bit for bit

* Pristine u2r **746 CMP_EQUAL / 58 CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH
  modes**; `ct8rows.sh` against `results/golden_uhdm2rtlil.csv` (both mode
  columns, 1742 rows) reads *every row byte-identical to the committed
  baseline*.
* The seven ibex heads: ONE head each, both modes, `operation` @
  `ibex_pkg.sv 750:52`. The implementer's `2267` is the cmp STDOUT line count;
  `rowheads.sh` merges stderr and therefore reads `4534` for the same head —
  the same number, counted twice. Both instruments read `heads=1`.
* The vector sizes, which the brief demanded first: golden `op75 n=16` →
  16 × `op75 n=5`; ours at pristine `op75 n=80`, all leaves. **16 against 80 in
  the ELABORATED module listing and nowhere else** — one vector-size print, not
  a distance.
* `v11_16e5m` (this directory) reproduces that head STANDALONE: a 16-element
  array of a 5-member packed struct, `surelog_rc=0 ours_rc=0`, **2267 cmp lines
  and one head at pristine**, the corpus head in 30 lines of SystemVerilog.
* Law u2r **752 / 52 / 67 both modes**; the whole-row gate moves **12 rows
  (24 row-sides), all six named tests, every one CMP_NOTEQUAL → CMP_EQUAL**,
  no row regressing in either column.
* `byteverify.sh SELFCHECK=1`, law vs my own pristine workdirs:
  `PATH_SETS_IDENTICAL (1608 paths)`, **`MOVERS: 24 / 1608`**, selfcheck
  1607/1608 — the 12 predicted rows × 2 modes, **zero unpredicted**.
* The a-priori predictor run on MY pristine databases returns the same
  `rows=12`, and its positive control on my own arms flags `v11_16e5m`
  (16 elements) while flagging neither `v7_1e_definner` nor `v18_ov_1e`
  (one element) nor `v8_2e_sub` (the fold bails there, so there is nothing for
  the law to remove).
* Goldens 23 PASS / 0 FAIL for the law binary AND for the fixed binary;
  `/bin/false` 0 PASS / 23 FAIL.
* Each of the six conversions re-confirmed one at a time with the official
  `uhdm-cmp` against the golden the sweep itself used: **rc=0, twelve for
  twelve** (both modes).
* Surelog corpus, law vs pristine and vs the committed
  `results/golden_surelog.csv`: default **467 / 16**, testflags **463 / 14**,
  every status class and both dump columns unchanged. The only two rows
  `ct8rows.sh` prints are `LowMemLib` and `LowMemPkg`, whose `SURELOG_FAIL`
  DETAIL STRING embeds the workdir path.
* Surelog `byteverify.sh SELFCHECK=1`: `MOVERS 5 / 960`, every one in the
  proven UVM coin family, attributed ORDER-BLIND (0 or 4 sorted-dump lines,
  every changed line a line-number-class `UINT:` / `vpiDecompile:` pair), with
  the positive control run here: the PRISTINE binary alone, four runs,
  identical arguments, four DISTINCT md5s. My mover SET is not the
  implementer's (mine: MiniAmiq ×2, SeqDriver/default, SimpleUVM/default,
  Scoreboard/default; theirs: MiniAmiq ×2, SeqDriver ×2, Scoreboard/default) —
  which is itself the coin.
* Hard byte pins hold in both modes, pristine vs law: SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`; status pins byte-identical:
  InterfaceModPort `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a` /
  `73a10e8217e5`, YosysOldOr `d68e0796d62c`.

## 2. The producer, re-decoded from source (and one correction)

`ExprEval::flattenPatternAssignments` (UHDM v1.87 `templates/ExprEval.cpp:751`)
reads exactly as the implementer transcribed it: the descent into the element's
nested pattern at `:808` is guarded by `orig->size() == 1`, and with N ≥ 2 the
first operand is an `uhdmoperation`, so `:862-863` returns the unmodified tree.
**The element count is the whole rule.**

One correction to the write-up, which does not change the law. The
`DesignElaboration.cpp:2601` road cannot be where the flattened vector lands:
`CompileHelper::expandPatternAssignment` sets `expr* result = rhs;` BEFORE
calling `flattenPatternAssignments`, and for an `array_typespec` target none of
its trailing branches reassign `result`, so that road returns the ORIGINAL
expression. The vector lands on the CONNECTION road, in place:

    NetlistElaboration.cpp:413-419
      if (expr* tmp = eval.flattenPatternAssignments(s, tps, (expr*)rhs))
        if (tmp->UhdmType() == uhdmoperation)
          ((operation*)rhs)->Operands(((operation*)tmp)->Operands());

— the operand VECTOR is copied into the existing operation and nothing else is.
That is also why the typespec half is a separate rule: `NetlistElaboration`
never touches `Typespec()`, and the stamp comes only from
`DesignElaboration.cpp:2606-2637`.

## 3. THE BREAK — `§ unpackedStructArrPatElabTs` over-fires on an OVERRIDDEN parameter

The stamp at `DesignElaboration.cpp:2620-2628` is reached on the road that
elaborates a parameter from its DECLARATION. An instance parameter the
instantiation OVERRODE is rebuilt by `NetlistElaboration::elabModule_`
(`NetlistElaboration.cpp:262-419`), which clones the `param_assign`,
substitutes the override actual, copies the flattened operand vector at `:413`
— and never stamps a typespec. **Golden's overridden elaborated operation
carries no `ref_typespec` at all.**

Measured, every arm `--nobuiltin`, every arm `surelog_rc=0 ours_rc=0`:

| arm | elems | shape | overridden | golden elab Rhs ts |
|---|---|---|---|---|
| `v19_noov_default` | 2 | scalar members, module default | no | **HAS** `array_typespec` |
| `v20_noov_sub` | 2 | sub-struct member | no | **HAS** |
| `v10_2e_override` | 2 | scalar members | yes | **NONE** |
| `v16_ov_sub` | 2 | sub-struct member | yes | **NONE** |
| `v17_ov_refobj` | 2 | `'{A, B}` ref_obj elements | yes | **NONE** |
| `v18_ov_1e` | 1 | scalar members | yes | **NONE** |

`v16` and `v17` are the two arms where the fold BAILS for its own reasons, so
PRISTINE minted no ref either and **PRISTINE WAS RIGHT**. Under r11u10 as
submitted they gain a `ref_typespec` golden does not have — and that addition
is the WHOLE change to both databases (`diff` of the path-normalised
`uhdm-dump`, pristine vs law, is seven `>` lines and nothing else on each arm;
pristine vs FIXED is **zero lines on both**). `v16`'s seven:

    > |vpiTypespec:
    > \_ref_typespec: (work@dut.u)
    >   |vpiParent:
    >   \_operation: , line:11:49, endln:11:108
    >   |vpiFullName:work@dut.u
    >   |vpiActual:
    >   \_array_typespec: , line:11:38, endln:11:46

and `uhdm-cmp` then reads `LHS: <null>` with our ref as RHS — a NEW head placed
AHEAD of the arm's own pre-existing one (`v16` 18 cmp lines → 8). That is
pristine-right → patched-wrong on legal SV.

### The fix (one conjunct, `src/ParamEmit.cpp`)

    if (topView && !inPackage && !overridden && rhs && init && hasParamArrTs &&

With it:

* `v16` and `v17` return to their pristine databases exactly (the directional
  arm census below reads SAME for both, `pris_extra == fix_extra` and
  `pris_missing == fix_missing`);
* `v19` and `v20` keep the stamp — golden has it there, and both stay FIXED;
* `v10` improves PAST pristine: at N ≥ 2 the fold no longer runs and nothing
  else stamps, which is golden's own shape, and its `LHS: <null>` head clears
  (8 → 18 lines, the head moving on to a deeper pre-existing object);
* **the whole uhdm2rtlil corpus is byte-identical to r11u10 as submitted** —
  `byteverify.sh fix vs law: MOVERS 0 / 1608` — and the six conversions stand
  (752 / 52 / 67 both modes, the fix CSV byte-identical to the law CSV).

## 4. The verifier's break grid (18 arms built, 16 shipped; `vgrid10.sh`, `grid/v*`)

Directional per-arm dump census (`armcen10v.py`: id-stripped, path-normalised
line multisets; `extra` = lines we have and golden does not, `missing` = the
mirror). Two arms are NOT in this directory because their GOLDEN side does not
compile and an arm whose compile fails teaches error recovery, not golden: an
array parameter written `'{default: '{...}}` SEGFAULTS Surelog v1.87
(`surelog_rc=139`) and an indexed `'{0: '{...}, 1: '{...}}` array pattern is
rejected (`surelog_rc=4`).

    arm                 pris_ex  law_ex  fix_ex  pris_mis  law_mis  fix_mis  law   fix
    v11_16e5m              1774     497     497      7050     3857     3857  FIXED FIXED
    v13_2e_twoinst          142      42      42      1545     1308     1308  FIXED FIXED
    v15_2e_modnoport         33      19      19       508      423      423  FIXED FIXED
    v9_2e_localparam         24      10      10       288      203      203  FIXED FIXED
    v5_modparam_2e           26      12      12       279      194      194  FIXED FIXED
    v19_noov_default         27      13      13       291      206      206  FIXED FIXED
    v3_2d_2x2                38      38      38      1078     1064     1064  FIXED FIXED
    v8_2e_sub                51      51      51      1243     1229     1229  FIXED FIXED
    v20_noov_sub             23      23      23       277      270      270  FIXED FIXED
    v10_2e_override          42      57      52       206      150      152  FIXED FIXED
    v1_2e_refobj            101     107     107      1867     1859     1859  FIXED FIXED
    v16_ov_sub               72      77      72       202      200      202  WORSE SAME
    v17_ov_refobj           186     192     186       430      429      430  WORSE SAME
    v18_ov_1e                19      19      19       264      264      264  SAME  SAME
    v4_2e_repl               24      24      24       919      919      919  SAME  SAME
    v7_1e_definner           22      22      22      1151     1151     1151  SAME  SAME

**With the fix: MOVED-WRONG = 0, BROKEN = 0, FIXED = 11, SAME = 5.**

`v8_2e_sub` and `v11_16e5m` grow their cmp LINE count (8 → 139, 2267 → 1621)
while their parameter goes golden-exact: in both, the head moves on to the
elaborated PORT high_conn, which is `operation` in golden and `ref_obj (p::P)`
in ours — and **that object reads `ref_obj` in the PRISTINE dump too**
(`v8_2e_sub`, `uhdmtopModules` section, `vpiHighConn`), so it is a mask
cleared, not a break. A cmp count is not a distance; the shape lister is.

## 5. The census, re-run independently (`cen10v.py`)

Per mover row, id-stripped / path-normalised / INDENT-stripped `uhdm-dump` line
multisets — golden vs pristine vs law — scored on both modes over all 24 mover
databases:

    TOTAL TO-GOLDEN = 23244      TOTAL AWAY-GOLDEN = 2348

(The absolute numbers differ from the implementer's 16784 / 788 because this
normalisation keeps spans. The direction is the same and the ratio is ~10:1.)

**The AWAY is the multiset trap, and stripping the indent is load-bearing.**
Scored WITHOUT stripping it, AWAY nearly doubles (4336) purely because a
deepened tree re-indents every line under it. With it stripped, the AWAY set is
dominated by PARENT-LABEL lines — `\_operation: , line:751..766:5`, the
sixteen element patterns, each printed once per child it now has —
`|vpiParent:` and `|vpiActual:`, all content-free structural tags.

The content-bearing AWAY lines are confined to ONE row, `ibex_tracer`
(`|BIN:00` golden 143 / pristine 144 / law 160, and the `|vpiSize:2` /
`|vpiConstType:3` pairs that ride with them, each +16) — **and counting them
per DESIGN LISTING dissolves them**, because a whole-database multiset sums a
section the law moved with sections it never touched:

    |BIN:00 per listing      allPackages  topPackages  allModules  topModules
      ibex_tracer  golden        44           38           32          29
      ibex_tracer  pristine      44           46           40          14
      ibex_tracer  law           44           46           40          30
      ibex_alu     golden        19           19           25          20
      ibex_alu     pristine      19           19           25           0
      ibex_alu     law           19           19           25          16

Only `topModules` moves. `ibex_tracer` goes from 15 SHORT of golden to 1 OVER
it; `ibex_alu` from 20 short to 4 short. The `topPackages`/`allModules`
excesses on `ibex_tracer` (+8 each) are PRE-EXISTING and byte-identical before
and after. Nothing in the census is a content regression.

**SHAPE LISTER beside the census.** `PmpCfgRst`'s `param_assign` Rhs tree,
all four listings, `SHAPE_DEPTH=5`, gold-vs-ours, per row:

    ibex_alu  ibex_icache  ibex_multdiv_fast  ibex_pmp  ibex_wb_stage
        pristine NO MATCH  ->  law SHAPE-IDENTICAL TO GOLDEN
    ibex_tracer
        pristine NO MATCH  ->  law differs from golden in ONE line (R1)

## 5b. Heads, before and after (`heads10.sh`, from the sweep's own databases)

    row                  pristine                                   law/fix
    ibex_alu             operation @750:52   2267 lines             15 lines (R3)
    ibex_multdiv_fast    operation @750:52   2267                   15 (R3)
    ibex_wb_stage        operation @750:52   2267                   15 (R3)
    ibex_icache          constant  @17:44      32                   32 UNCHANGED (id 10003)
    ibex_pmp             constant  @34:10      18                   18 UNCHANGED (id 12543)
    ibex_tracer          ref_obj OPCODE_C0     18                   18 UNCHANGED (id 16236)

R3, read in full: `LHS: <null>` / `logic_var: (work@ibex_alu.butterfly_result)`
@ `ibex_alu.sv 407:16` — a variable WE emit and golden does not. A different
family; the three rows share it. The `icache` / `pmp` / `tracer` heads are
byte-identical object-for-object before and after, so those three are indeed
byte-corrected behind an unmoved head.

Each of the six conversions was re-confirmed one at a time with the official
`uhdm-cmp` against the golden the sweep itself used: **rc=0, twelve for
twelve.**

## 6. Canaries and pins

u2r `canaries.sh ok=8 changed=0`, `ctcan2.sh ok=1 changed=0 PASS`,
`canaudit.sh audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS` — for both the law
and the fix binaries. The battery scripts the implementer copied into
`tools/probe/r11u10repro` are **byte-identical** to `tools/probe/r10uvm221repro`
(`canaries.sh ctcan2.sh canaudit.sh byteverify.sh ct8rows.sh rowheads.sh`,
all six `diff`-clean), and the four slang-fenced names appear in no file of the
patch outside `canaudit.sh`'s own fence list.

## 7. Ranked residues

* **R1 — the elaborated stamp is NOT unconditional, and `ibex_tracer` proves it
  in the corpus.** `ibex_tracer`'s golden `topModules` `PmpCfgRst` reads
  `op75 n=16` with **NO** `ts=`, where the other six ibex rows' goldens read
  `op75 n=16 ts=array_typespec`. The parameter is not overridden there, so
  `!overridden` does not cover it. Ours carries the ref in BOTH pristine and
  law (pristine minted it in the fold), so this pass neither creates nor cures
  it — but it is the next distinguisher in this family and the one line of
  `PmpCfgRst`'s shape that still differs from golden on that row.
* **R2 — a REPLICATED array pattern gets no stamp from either half.**
  `v4_2e_repl` (`parameter s_t P[2] = '{2{'{...}}}`): golden's elaborated
  `op76` carries `ts=array_typespec`, ours carries none, in pristine and law
  alike. Both halves gate on `ExpressionKind::SimpleAssignmentPattern`, which a
  replication is not.
* **R3 — an N ≥ 2 array whose elements are REF_OBJs keeps a bare element op.**
  `v1_2e_refobj` (`'{A, B}` over a 2-member struct): golden's two element
  `op75`s each carry `ts=struct_typespec (p::s_t)`; ours carry none. The outer
  array ts is now right; the per-element struct ts is not.
* **R4 — the elaborated PORT high_conn of an unpacked-struct-array parameter is
  a `ref_obj` where golden builds an `operation`.** Pre-existing, visible in
  the pristine dump, and now the head of `v8_2e_sub` and `v11_16e5m`. This is
  the next head any pass in this family will meet.
* **R5 — the implementer's R0 stands as written**: the ONE-ELEMENT absorb is
  still wrong for an ENUM member (`grid/h7_1e1menum`, golden folds to a
  `constant`, we keep the `ref_obj`) and for a SUB-STRUCT member
  (`grid/hB_1e1msub`, golden drops the tags, our `foldField` bails). Both are
  byte-identical before and after and confirmed here.

## 8. The sister landing — checked, not assumed

While this verification ran, the master landed the struct-assembler sister as
`d23a8d3f` ("v1.87 pass 8"), moving the u2r baseline to **748 CMP_EQUAL / 56
CMP_NOTEQUAL / 67 SLANG_REJECT** in both modes. The two laws do **not**
collide:

* the sister's own a-priori mover list (`tools/probe/r11u9repro/PREDICT.u2r.txt`,
  committed) names `cva6_equiv`, `def_ctx_struct_param`,
  `latch_decoder_partial`, `latch_tlb_napot`, `param_nested_struct_field_width`,
  `pkg_nested_struct_param_width`, `portsel_struct_param`,
  `struct_member_cfg_width`, `struct_param_field_shift`, `struct_param_func_arg`,
  `struct_param_func_config`, `struct_param_func_loop` — **disjoint from this
  pass's twelve**;
* all twelve of this pass's rows are still `CMP_NOTEQUAL` in both modes in
  `results/golden_uhdm2rtlil.csv` at `d23a8d3f`;
* the source hunks are disjoint too — the sister's `ParamEmit.cpp` hunks sit
  around lines 1762-2178 and 8111-8500, this pass's around 13966 and 15990 —
  and the verified patch passes `git apply --check` on a fresh `d23a8d3f`
  worktree with **zero conflict markers**.

So on top of the sister the scoreboard is **748 → 754 CMP_EQUAL, 56 → 50
CMP_NOTEQUAL, 67 SLANG_REJECT unchanged, BOTH modes** — measured, not
predicted, with a binary built at `d23a8d3f` + this patch (md5
`b895cb0435893c2af6edf08661fccc54`). The whole-row gate against the committed
`d23a8d3f` baseline moves **exactly the same twelve row-sides**: the six named
tests, every one `CMP_NOTEQUAL → CMP_EQUAL`, in both modes.

## 9. Instruments in this directory

* `vgrid10.sh` — the verifier's 18-arm break grid; records `surelog_rc`,
  `ours_rc`, `cmp_rc`, cmp lines and head count for every arm.
* `grid/v*` — the arms. `v11_16e5m` is the corpus head standalone;
  `v16`/`v17`/`v18`/`v10` are the OVERRIDDEN road; `v19`/`v20` are its negative
  controls; `v8` is the sub-struct bail; `v13` is the two-instance sharing
  control; `v3` is a 2-D array; `v4` a replication; `v1` ref_obj elements.
* `armcen10v.py` — the directional per-arm dump census (extra / missing against
  golden, pristine vs patched), the instrument that found the break.
* `cen10v.py` — the corpus-row directional census over the mover databases,
  with the AWAY lines printed so the multiset trap can be told from a break.
* `VGRID.{pristine,law,fix}.txt` — every arm, every rc, all three binaries.
