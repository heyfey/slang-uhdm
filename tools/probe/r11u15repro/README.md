# r11u15 — a generate scope's continuous assignment reads the module symbolically, and a block's part-select owns the name

Base commit `401ed722`, worktree `/tmp/wt_r11u15`. Pristine binary md5
`aa22f942076295f56fd20551df1ee939` — byte-identical to the main tree at the
base. Law binary md5 `71f3672cb6c14f8eefa74b9958b77210`. The judge is the
official `uhdm-cmp` through `scripts/verify_golden.py`; everything in this
directory is measurement-only. `results/*.csv` ARE NOT EDITED BY THIS PASS.

**TWO uhdm2rtlil tests CONVERT in BOTH modes**, four row-modes, each confirmed
at `uhdm-cmp` rc 0 against the golden the sweep itself used:

    ibex_wb_stage        latch_tlb_napot

u2r reads **759 CMP_EQUAL / 45 CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH modes**
against the base's 757/47/67. `ibex_alu` and `ibex_multdiv_fast` are
byte-corrected without converting: each clears one cell of this law and lands
on a head of its own (§8 R1, R2).

## 1. The two heads, RE-MEASURED on my own pristine build

The pristine build reproduces the base exactly — u2r 757/47/67 both modes,
surelog 468/15 + 464/13, and `ct8rows.sh` reads `PASS: every row byte-identical
to the committed baseline` against `results/gate_uhdm2rtlil.csv`.

One head per row (`grep -c '^LHS:'` on **stderr**), identical in both modes:

| row | head | cmp lines |
|---|---|---|
| `ibex_alu` | `LHS: <null>` / RHS `logic_var work@ibex_alu.butterfly_result` @ `ibex_alu.sv 407:16` | 15 |
| `ibex_wb_stage` | `LHS: <null>` / RHS `logic_net work@ibex_wb_stage.perf_instr_ret_wb_o` @ `36:36` | 15 |
| `ibex_multdiv_fast` | `LHS: <null>` / RHS `logic_var work@ibex_multdiv_fast.sign_a` @ `54:16` | 15 |
| `latch_tlb_napot` | LHS `part_select patched_pte` @ `dut.sv 58:9` / RHS `logic_net work@ltn_leaf.patched_pte` @ `40:16` | 36 |

**The brief's inherited framing was stale and the re-measure is the authority.**
`ibex_multdiv_fast` does NOT share `ibex_alu`'s head at this base: its head is
its own (`sign_a`, a gen-scope PROCESS reference, §8 R2), and it is the one of
the three ibex rows this pass does not reach. `latch_tlb_napot`'s head is not
the cast-typespec resolution either — that cell is real and remains, and it is
indeed judge-invisible: the row CONVERTS with it still in place (§7).

### Reading the heads

`BaseClass.h:187-199`: the SINGULAR `SafeCompare` with `lhs == nullptr` and
`rhs != nullptr` sets `m_failedRhs` to **the value** and leaves `m_failedLhs`
unset. The VECTOR overload sets the **owner** on both sides. Every head above
prints the VALUE, so all four are singular-field heads, and the field is
`ref_obj::Actual_group` — **golden's reference carries no `vpiActual` and ours
does** (rows 1-3), or **golden's points somewhere else** (row 4).

That is invisible in a `cmp` line count and visible only in the dumps, so the
instrument for this pass is `refcen.py`: every `ref_obj` in a database keyed by
(vpiFullName, line:col) with the CLASS and NAME of its `vpiActual`, golden
against ours. It is what turns "15 lines" into "two cells".

    ibex_alu           25 differing ref keys at pristine  ->  23 under the law
    ibex_wb_stage      21                                 ->  19
    ibex_multdiv_fast  31                                 ->  30
    latch_tlb_napot     2                                 ->   0

## 2. DECODE — LAW A, the generate-scope continuous assignment

`ibex_alu.sv:1290-1313`, the LIVE arm of `if (RV32B != RV32BNone)`:

```systemverilog
  end else begin : g_no_alu_rvb
    logic [31:0] unused_butterfly_result;
    assign unused_butterfly_result    = butterfly_result;   // :1294
    ...
    assign butterfly_result    = '0;                        // :1306
```

`butterfly_result` is declared in the MODULE BODY (`ibex_alu.sv:407`). In the
elaborated listing golden binds the `assign`'s **Lhs** at `:1306` to the
module's `logic_var` and leaves the **Rhs** at `:1294:41` with no `vpiActual`
at all. We bound it.

`UhdmWriter::writeCont_assign` (Surelog v1.87 `UhdmWriter.cpp:2090-2299`) is the
producer: it calls `bindVariable` on the Lhs only, and the re-bind
`((ref_obj*)lhs)->Actual_group(var)` sits inside `if (rhs->UhdmType() ==
uhdmoperation)`; nothing in that function ever touches an Rhs reference. So an
Rhs reference in a generate scope keeps whatever the DEFINITION compile gave
it — and the definition compile resolves generate-scope names in the generate
scope, not in the module body.

Our emitter already models this: `ModuleEmit.cpp:~17405` suppresses Rhs ref
binding for a gen-scope cont_assign unless the Rhs has a `hasBindableRef`. One
of that predicate's two openers was too wide:

```cpp
else if (blkWrites.count(&nvp.symbol))     // "driven in this gen-scope"
    hasBindableRef = true;
```

`blkWrites` is every symbol the block assigns, **module-body signals
included**. `assign butterfly_result = '0;` puts the module's own
`butterfly_result` into it, the gate opens, and the whole Rhs of `:1294` binds.

**THE LAW.** The opener requires the driven symbol to be a GENERATE-SCOPE
declaration. Its witness always was one: `r5p_gpr_2r1w.sv:158-175`'s `gen_default`
declares `gpr` inside the block, writes it with the block's own `always_ff`, and
reads it in the block's own `assign t_rs1 = gpr[a_rs1];` — while the same
module's `gen_wb_default` reads the MODULE-level `t_rs1` and golden leaves that
unbound. The clause was calibrated on the gen-local half and shipped the
module-level half by accident.

## 3. DECODE — LAW B, the block's part-select owns the name

`latch_tlb_napot/dut.sv:56-60`, inside `always_comb begin : translation`:

```systemverilog
        patched_pte      = pte_i;                    // :57
        patched_pte[3:0] = flush_vaddr_i[3:0];       // :58
        content_o        = patched_pte;              // :59
```

Golden's `:57` **Lhs** and `:59` **Rhs** whole references BOTH carry
`vpiActual -> part_select patched_pte (…:58:9)`. Surelog's per-scope symbol map
holds ONE object per name and the bare references bind whatever it holds when
the body is done — the `:58` part-select, which registered itself under
`patched_pte`, wins for the references before it as well as after it. We bound
both to the declaration's `logic_net`.

`endSelTrack` (`StmtEmit.cpp:335-…`) already implements the back-patch. One
carve-out stopped it:

```cpp
if (selWholeWrittenVars.count(wr.sym) &&
    sel->UhdmType() == uhdmpart_select && <folded constant left bound>)
    continue;      // "a var ALSO written whole keeps the net"
```

`patched_pte` IS written whole at `:57`, so the carve-out fired.

**THE CARVE-OUT WAS READING THE WRONG AXIS.** Its named witness,
`multiple_blocking_gate`, does not need it: that test's 32 selects are CASE-ITEM
statements, and `noteSelectObj` (`StmtEmit.cpp:453-465`) registers only when the
innermost sel-scope `isBlock`, so "a select under a bare `if`/`case` arm …
registers nowhere" — that test is right by the SCOPE rule, carve-out or not.
Arm `a13` reproduces it exactly and is golden-`logic_net` on both binaries with
the carve-out gone.

**THE LAW.** The carve-out no longer applies when the reference's current actual
is a `nets`-class object. The half that survives is `V-FIX vbuvm5`'s own cell —
a `ref_var` subroutine local (`bs = 8'h00;` next to `bs[3:0] = 4'hf;`) is golden
`ref_var`, pristine-right, and re-pointing it is a measured pristine-right ->
patched-wrong. Every arm of this pass's `a` grid binds a module-level NET, so the
two populations do not overlap and the narrowing is exact.

## 4. THE GOLDEN GRID — 44 arms, every rc recorded

`grid/` carries one `dut.sv` per arm; `run.sh <binary> <tag>` builds the GOLDEN
(`surelog -parse -nobuiltin -nocache -sv`) and ours (`--single-unit --nobuiltin`)
and records **both** return codes plus the head count and cmp line count.
**Every arm is `golden_rc=0 ours_rc=0` in every tag** — no arm is testing
error recovery. `GRID.pris.txt` / `GRID.law.txt` / `GRID.law2.txt` are the
three tables, each row carrying its `refcen.py` verdict beside the cmp numbers.

**AN ARM AGREEING AT rc 0 IS NOT AN ARM TESTING THE LAW.** `a17` is the proof:
it reads `cmp_rc=0` at pristine and its census says golden `part_select` against
our `logic_net` — the judge reaches the module's `Nets()` first and
short-circuits. Every `a` verdict below is read off `refcen.py`, never off the rc.

### LAW B axes — selects × holders × forms × views

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| `a01` | `p = a; p[3:0] = b[3:0]; o = p;` in `begin : blk` | REPOINT both | net | REPOINT |
| `a03` | same, UNNAMED block | REPOINT | net | REPOINT |
| `a05` | no later read (only the earlier whole ref) | REPOINT | net | REPOINT |
| `a09` | a second module var present | REPOINT | net | REPOINT |
| `a11` | the target is an output PORT | REPOINT | net | REPOINT |
| `a12` | TWO selects | REPOINT to the FIRST | net | REPOINT |
| `a14` | the whole write READS ITSELF (`p = p + 1`) | REPOINT | net | REPOINT |
| `a15` | non-ANSI `reg`, `always @(posedge clk)` | REPOINT | net | REPOINT |
| `a16` | the select is on an output `reg` PORT | REPOINT | net | REPOINT |
| `a17` | the whole write AFTER the select | REPOINT | net | REPOINT |
| `a18` | TWO whole writes around the select | REPOINT | net | REPOINT |
| `a19` | the name also read at MODULE level | REPOINT | net | REPOINT |
| `a20` | the whole write in a NESTED block | REPOINT | net | REPOINT |
| `a02` | no select at all | net | net | net |
| `a04` | a BIT select | REPOINT | REPOINT | REPOINT |
| `a06` | select first, no whole write | REPOINT | REPOINT | REPOINT |
| `a07` | the select is on the RHS only | net | net | net |
| `a08` | the select is on a DIFFERENT name | `p` net, `q` REPOINT | same | same |
| `a13` | the select in a CASE ITEM (`multiple_blocking_gate`) | net | net | net |
| `a21` | the select in a NESTED block, whole refs outside | net | net | net |
| `a22` | an INDEXED part-select | REPOINT | REPOINT | REPOINT |
| `a10` | `always_ff` with NONBLOCKING `<=` | REPOINT | net | net (R3) |

### LAW A axes — target kinds × holders × Rhs forms

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| `b01` | gen-if, Rhs bare ref to a module VAR driven in this block | UNBOUND | bound | UNBOUND |
| `b05` | same, Rhs an OPERATION | UNBOUND | bound | UNBOUND |
| `b18` | same, the module signal is a NET | UNBOUND | bound | UNBOUND |
| `b19` | same, driven by a PROCESS in the block | UNBOUND | bound | UNBOUND |
| `b20` | same, read inside an operation | UNBOUND | bound | UNBOUND |
| `b22` | same, the module signal is a PORT | UNBOUND | bound | UNBOUND |
| `b02` | the module net is driven at MODULE level | UNBOUND | UNBOUND | UNBOUND |
| `b03` | a module PORT, not driven in the block | UNBOUND | UNBOUND | UNBOUND |
| `b06` | the Rhs is a PART-SELECT of the module var | UNBOUND | UNBOUND | UNBOUND |
| `b07` | a module LOCALPARAM | bound | bound | bound |
| `b08` | a module unpacked ARRAY | UNBOUND | UNBOUND | UNBOUND |
| `b09` | the cont_assign is at MODULE level | bound | bound | bound |
| `b10` | gen-FOR, driven at module level | UNBOUND | UNBOUND | UNBOUND |
| `b11` | NESTED gen-if, driven at module level | UNBOUND | UNBOUND | UNBOUND |
| `b13` | driven by a module-level `always_comb` | UNBOUND | UNBOUND | UNBOUND |
| `b14` | two bare Rhs refs, module signal driven outside | UNBOUND | UNBOUND | UNBOUND |
| `b04` | the Rhs names a SAME-scope gen LOCAL | BOUND | BOUND | BOUND |
| `b17` | the Rhs names an ANCESTOR gen local | UNBOUND | UNBOUND | UNBOUND |
| `b12` | the LHS is the module var, the Rhs a constant | Lhs bound | bound | bound |
| `b15` | a gen local and a module name in ONE Rhs | gen local BOUND, module UNBOUND | both bound | both bound (R4) |
| `b16` | same, the module name also driven here | same | both bound | both bound (R4) |
| `b21` | gen-FOR, driven in this block | Rhs UNBOUND, **Lhs BOUND** | Rhs bound, Lhs unbound | Rhs UNBOUND, Lhs unbound (R5) |

**19 arms convert, 0 arms regress.** `b17` is why the gate reads "declared in a
GENERATE scope" and not "declared in THIS block": `oloc` is an ancestor gen
local driven here, and narrowing to this block would have suppressed its Lhs.

## 5. PREDICTION — the mover set BY NAME, a priori, with a positive control

Both predictors read **PRISTINE databases only**; neither needs the patched
binary, and a database with no flagged cell cannot move.

* `predict.py` (LAW A) — a `ref_obj` in the Rhs of a `cont_assign` owned by a
  `gen_scope`, whose `vpiActual` names an object OUTSIDE that gen scope's path.
  Over the pristine u2r workdir (1608 databases) it names **10 rows × 2 modes**:
  `arb_idx_cast`, `genscope_module_ctx_reset`, `hier_path`, `ibex_alu`,
  `ibex_icache`, `ibex_multdiv_fast`, `ibex_pmp`, `ibex_wb_stage`,
  `MultirangesStartNotFromZero`,
  `ParameterInitializedByPartSelectOfParametersAssignedToVar`.
* `predict2.py` (LAW B) — a `ref_obj` bound to a `nets`-class object whose
  `vpiFullName` is also carried by a plain `part_select`. Over the same
  workdir it names **62 rows** (`PREDICT2.u2r.txt`), `latch_tlb_napot` and
  `multiple_blocking_gate` among them.

Both are deliberate SUPERSETS: LAW A leaves a cell alone when a gen-local
shares the Rhs, LAW B when the select registered in a scope the reference
cannot see. The requirement they answer is containment, and it holds.

Both take a workdir OR a single database directory. On the surelog corpus a
whole-corpus run is impractical (`Earlgrey_0_1` alone dumps 135 523 references),
so containment there is checked per database on the rows `byteverify.sh` names:
`predict2.py` flags `Earlgrey_0_1` (356 candidate cells, the moved
`work@aes_key_expand.drive_regular.regular` among them) and `YosysOldSystem`
(24), which is every surelog mover this pass owns (§6).

**POSITIVE CONTROL** — the grid arms, scored by the same scripts:
`predict.py` flags `b01`/`b18`/`b21` (all real movers) and is silent on
`b02`/`b04`/`b14`/`b17`; `predict2.py` flags `a01` (a real mover) and is silent
on `a02`/`a06`/`a21`/`a22`. A scan that could not see would have been silent on
the movers too.

**MEASURED MOVERS, u2r, `byteverify.sh SELFCHECK=1` against my own pristine
workdir: 8 of 1608**, `PATH_SETS_IDENTICAL`, and the self-check flags 1607 of
1608 so the gate can see:

    default/ibex_alu   default/ibex_multdiv_fast   default/ibex_wb_stage   default/latch_tlb_napot
    testflags/ …the same four…

Every one is in both predicted sets. **AWAY-GOLDEN 0 / MOVED-WRONG 0**, cell by
cell, from `refcen.py` on the four rows:

    ibex_wb_stage      213:50 perf_instr_ret_wb_o        ours bound   -> golden's <none>
                       213:72 instr_is_compressed_id_i   ours bound   -> golden's <none>
    ibex_alu          1294:41 butterfly_result           ours bound   -> golden's <none>
                      1296:41 invbutterfly_result        ours bound   -> golden's <none>
    ibex_multdiv_fast  279:39 mac_res_signed             ours bound   -> golden's <none>
    latch_tlb_napot      57:9 patched_pte (Lhs)          ours net     -> golden's part_select
                        59:28 patched_pte (Rhs)          ours net     -> golden's part_select

No cell moved in the other direction and no cell appeared that was not there.

## 6. THE SURELOG CORPUS — the coin, proved, and LAW B's two byte-corrections

Statuses are **IDENTICAL row for row** to my own pristine sweep: 468 / 15 and
464 / 13. `ct8rows.sh` against `results/golden_surelog.csv` names two rows, and
both are the WORKDIR PATH inside a `SURELOG_FAIL` log message
(`LowMemLib`/testflags, `LowMemPkg`/testflags) — the PRISTINE sweep produces the
identical two against the same baseline, so it is a workdir artefact.

`byteverify.sh` reports **9 movers of 960** (self-check 959/960 flagged):

    default/{MiniAmiq, Scoreboard, SeqDriver, SimpleUVM}   testflags/{MiniAmiq, SeqDriver}
                                                        -> the proven UVM coin family
    default+testflags/Earlgrey_0_1                      -> LAW B, 3 cells
    default+testflags/YosysOldSystem                    -> LAW B, 10 cells

**The two LAW-B rows are byte-corrections, not conversions** — both were
`CMP_EQUAL` before and after, because the cells sit where the judge's visited
set had already closed. Attributed cell by cell with `refcen.py`, golden
against ours:

    YosysOldSystem   10 differing ref keys at pristine -> 0 under the law.
                     `keysched` W_var / col_t / K_var and `mixcolum` data_i_var:
                     our `logic_net` -> golden's `part_select`.  The database is
                     now reference-for-reference identical to golden.
    Earlgrey_0_1     13785 -> 13782.  The SET DIFF of the two census listings
                     removes exactly three keys —
                     `work@aes_key_expand.drive_regular.regular` at 218:20,
                     276:22 and 280:11 — and ADDS NONE.

Both are named a priori by `predict2.py` run on their own PRISTINE databases
(`Earlgrey_0_1` flags 356 candidate cells, `drive_regular.regular` among them;
`YosysOldSystem` flags 24).  AWAY-GOLDEN 0 / MOVED-WRONG 0.

**POSITIVE CONTROL for the coin, and it convicts the coin and not the law.** The PRISTINE
binary alone, run FOUR times on MiniAmiq's own command line, produced FOUR
different databases; the order-blind delta between any pair is the SAME 4-line
shape — one constant in `array_typespec types_t`'s range, drawing 0 / 565 / 885
/ 961 across the four runs. The pristine-vs-law delta on the same test is that
identical 4-line shape. `Scoreboard/default` is order-blind IDENTICAL (0 lines).
Nothing here is attributable to this pass.

## 7. WHAT `latch_tlb_napot` STILL CARRIES, AND WHY IT CONVERTS ANYWAY

Its whole-dump diff against golden still holds two non-head differences, and
the row is `CMP_EQUAL` with both in place:

* the cast typespec at `dut.sv:14:31` (`localparam cfg_t CfgEmpty = cfg_t'(0);`)
  — golden `struct_typespec (ltn_cfg_pkg::cfg_t)`, ours `integer_typespec`. It
  is judge-invisible exactly as the brief said: `scope::Compare` reaches the
  `Parameters` before the `Param_assigns` and the object is already in
  `m_visited`. This pass does not touch it; it is now PROVED harmless to the
  judge rather than assumed so.
* `endln` columns `76:54` vs `76:55` on the `.*` port connections — Compare
  never reads a span.

The row's dump column therefore reads `differ` while its status reads
`CMP_EQUAL`, and that is the correct, quoted outcome.

## 8. Residues

* **R1 — `ibex_alu`'s next head is the ARRAY half of LAW A's Lhs.**
  `assign imd_val_d_o = '{default: '0};` in `g_no_alu_rvb`: golden binds every
  SCALAR module-level Lhs in that block (`bitcnt_result` … `imd_val_we_o`) and
  leaves the unpacked-array one `<none>`; we bind it. `bindVariable`
  (`CompileStmt.cpp:3089`) searches `Variables()` and `Nets()` — an `array_net`
  lives in `Array_nets()` and is never found, while a gen-local `array_var` IS
  in `Variables()` and golden binds it (`unused_imd_val_q`, same block). One
  cell, one row; behind it sits a SECOND family — golden keeps the ternaries at
  `ibex_alu.sv:269`/`:275` symbolic where we fold them on the constant
  `RV32B != RV32BNone`, so clearing R1 alone will not convert the row.
* **R2 — `ibex_multdiv_fast`'s head is the PROCESS analogue of LAW A.**
  `mult3_sign_a = sign_a;` inside `gen_mult_fast`'s `always_comb` reads the
  module-level `sign_a` (`:54`), golden leaves it unbound, we bind it. It is
  `inGenScopeProc`'s window, not `inGenScopeCaRhs`'s, and no arm of this grid
  keys it.
* **R3 — `a10`: NONBLOCKING selects do not register.** `p <= a; p[3:0] <= b[3:0];`
  in an `always_ff`: golden re-points both whole references to the part_select
  exactly as it does for blocking assignments, and we keep the net on both
  binaries. Wrong at pristine, unchanged by this pass, no corpus row.
* **R4 — `b15`/`b16`: `hasBindableRef` is per-ASSIGNMENT, golden is per-REFERENCE.**
  With a gen local and a module-body name in ONE Rhs, golden binds the local and
  leaves the module name bare; our gate opens for the whole Rhs. Wrong at
  pristine, unchanged, no corpus row. Closing it means moving the suppression
  from the assignment to the reference.
* **R5 — `b21`: a for-generate's module-level Lhs.** Golden binds `assign mv = a;`'s
  Lhs to the module `logic_var` in BOTH unrollings; we leave it unbound
  (`§ genCaAncestorNetShadowUnbinds98`'s reach). Wrong at pristine, unchanged by
  this pass — the law only removed the Rhs over-bind that sat beside it.

## 9. Instruments

* `refcen.py` — THE instrument. Every `ref_obj` keyed by (vpiFullName,
  line:col) with the CLASS and NAME of its `vpiActual`, golden against ours,
  printing only the differing keys and the totals. It exists because an
  `Actual_group` head prints one object and says nothing about how many cells
  are wrong, and because `uhdm-cmp` rc 0 can mask a real cell (arm `a17`).
* `refall.py` — the same listing UNFILTERED, for reading a single arm's shape.
* `run.sh` — the 44-arm grid runner; golden and ours per arm, **both** rcs, head
  count, cmp line count.
* `predict.py` / `predict2.py` — the a-priori mover predictions (§5), computed
  from pristine databases and scored on the grid arms as their positive control.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied byte-for-byte unmodified.

## 10. Gates

`GATES.r11u15.txt` carries the transcript. All green:

1. both binaries built `-j 2`, md5s taken separately; pristine
   `aa22f942076295f56fd20551df1ee939` = the main tree at `401ed722`.
2. `tests/check_goldens.sh` 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` 0 PASS /
   23 FAIL.
3. u2r both modes: `ct8rows.sh` names exactly the two law rows, quoted, both
   `CMP_NOTEQUAL -> CMP_EQUAL`; canaries `ok=8 changed=0`; `ctcan2`
   `EXPECT_UNKNOWN=6` PASS.
4. surelog `--mode both`: statuses identical row for row; canaries `ok=52
   changed=0`; `ctcan2` `EXPECT_UNKNOWN=1` PASS; `rowheads.sh` identical on the
   pristine and the law binaries (measured=12, SKIP-NOFILE=2, UNKNOWN-NAME=0).
5. `byteverify.sh SELFCHECK=1` against my own pristine workdirs: u2r 8/1608,
   surelog 9/960, every mover named and attributed (§5, §6) — the coin family
   with its four-run pristine positive control, plus LAW B's two
   byte-corrections, cell by cell, AWAY 0 / MOVED-WRONG 0.
6. protected databases by name: `InterfaceModPort` `59a365f3ce2c`,
   `BlackParrotComplex` `e3e354129d5a`/`73a10e8217e5`, `YosysOldOr`
   `d68e0796d62c`, `SVSwitch` `4842211c4030`, `YosysVerx` `6ccda350c24a` —
   all SAME.
