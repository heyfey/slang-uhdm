# r11v16 — ADVERSARIAL VERIFICATION of r11u16 § `caAsmMemberSliceFold`

Verdict: **ACCEPT-WITH-FIX**.  The law is golden's, both corpus conversions
reproduce bit-for-bit, and the whole gate battery reproduces on binaries this
verifier built itself.  Three faces of the law were broken on REAL v1.87
goldens; two of them are `pristine-right -> patched-wrong` and are FIXED here.

Base commit `6c6d4768`.  Worktrees `/tmp/wt_v11u16pris` (pristine) and
`/tmp/wt_v11u16` (patch + fix), both fresh at the base.  Pins per
`SUPPORT_MATRIX.md`.  `results/*.csv` UNTOUCHED.

## 1. Binaries, built here

| binary | md5 |
|---|---|
| pristine at `6c6d4768` | `d84acd3f88dab953d1b7348d80682a2d` — the OPS-brief value |
| r11u16 patch as submitted | `ed5a9c1ae38338608d206509e5cbce88` — the implementer's value |
| r11u16 + this verifier's fix | `5c8af8a5eed06d988ed61af79c0fc79e` |

`tests/check_goldens.sh`: 23 PASS / 0 FAIL on all three; `SLANG_UHDM=/bin/false`
0 PASS / 23 FAIL.

## 2. Headline numbers, reproduced

* uhdm2rtlil, both modes, own sweeps: pristine **757 / 47 / 67**, patched
  **759 / 45 / 67**.  The four differing row-sides are exactly the ones the pass
  quotes, against `results/gate_uhdm2rtlil.csv`, against
  `results/golden_uhdm2rtlil.csv` and against this verifier's own pristine
  sweeps — **`struct_param_func_arg` and `struct_param_func_loop` CONVERT in
  both modes.**
* Surelog suite: **468 / 15** (default) and **464 / 13** (testflags) on both
  binaries; the only differing row-sides are the workdir PATH inside the
  `SURELOG_FAIL` string of `LowMemLib` and `LowMemPkg`.
* `byteverify SELFCHECK=1` uhdm2rtlil, patched vs own pristine: **4 / 1608**,
  selfcheck 1607/1608 — the two names in both modes, nothing else.
* `byteverify SELFCHECK=1` Surelog, patched vs own pristine: **5 / 960**,
  selfcheck 959/960.  A DIFFERENT DRAW from the implementer's five, and every
  one inside the proven UVM coin family: `Scoreboard`/default (0 order-blind
  lines), `SeqDriver`/default, `SimpleUVM`/default, `MiniAmiq`/testflags,
  `SeqDriver`/testflags (4 order-blind lines each, every line of the
  `UINT:<line>` / `vpiDecompile:<line>` class).  **POSITIVE CONTROL:** the
  PRISTINE binary alone, run twice on `MiniAmiq`'s own command line, gives
  `d28fdd4e9ce4bdb9e76ca8b20356e99d` and `0d75391ae8953e8f80297819a30ed1cd`.
  The count is a per-run draw; the names and the class are the pin.
* `predict.py` re-run here: 861 uhdm2rtlil dirs reached, **2 named** — the two
  that convert; 700 + 93 Surelog dirs reached, 3 named, all bail witnesses.
* Every `cmds.txt` audited BY BINARY PATH: 1742 u2r rows and 1531 Surelog rows
  per arm, each on its own frozen binary, 0 rows anywhere else.
* HARD byte pins `SVSwitch` **4842211c4030** and `YosysVerx` **6ccda350c24a**,
  both modes both binaries; STATUS pins `InterfaceModPort` **59a365f3ce2c**,
  `BlackParrotComplex`, `YosysOldOr` byte-identical.
* Boundary: `r11u11` a1–a12 **12/12 byte-identical**, `r11u13` b1–b9 **9/9
  byte-identical**, `r11u14` c1–c9 byte-identical with **c10 CONVERTING**.
* An independent keyed cont_assign-Rhs census (`cacen.py` + the scorer) over
  the pass's own 14 grid arms: **TO-GOLDEN 32, AWAY-GOLDEN 0, MOVED-WRONG 0.**

## 3. THE ADVERSARIAL GRID — 16 arms, every arm's rc recorded

Surelog v1.87 golden per arm (`-parse -nobuiltin -nocache -sv dut.sv -mt 0
-mp 0`), all **`slrc=0`, `[ERROR] : 0`, gold present, pris/pat/fix rc=0**.
`v3`'s first cut used a named pattern on a packed union, which slang rejects —
an arm whose compile fails teaches error recovery, not golden, so the arm was
rewritten to a plain-constant union write before it was read.

| arm | face | pristine | r11u16 | + fix |
|---|---|---|---|---|
| `v1` | strength + delay + plain, one module | 1 head | 1 head | 1 head (a Surelog quirk drops `assign (s0,s1) #2` from BOTH listings; the fold cells all TO-GOLDEN) |
| `v1b` | plain + strength + delay | 1 head | **1 head, 58 lines** | **0 — CONVERTS** |
| `v1c` | `assign (supply0, supply1) o = CFG.n;` alone | 1 head | **1 head** | **0 — CONVERTS** |
| `v1d` | `assign #3 o = CFG.n;` alone | 1 head | **1 head** | **0 — CONVERTS** |
| `v2` | five Lhs shapes: port, typedef'd port, typedef'd net, plain net, variable | 1 head | **0 — CONVERTS** | 0 |
| `v3` | member of a struct carrying a packed ARRAY OF PACKED STRUCT, and one carrying a packed UNION | 1 head | 1 head | 1 head — **fence hole, see §4.3** |
| `v4` | ONE def, THREE elaborated instances + the parent's own read | 1 head | **0 — CONVERTS** | 0 |
| `v5` | member typespec kinds: enum, bit, byte, packed array, shortint | 1 head (unrelated) | same | same; all six cells TO-GOLDEN |
| `v6` | Lhs WIDTH matrix, both `adjustSize` branches + part-select and concat targets | 1 head | 1 head | 1 head; 6 TO-GOLDEN, 2 SAME-WRONG (§4.4) |
| `v7` | interface / gen-if / gen-for / net-decl-assign reading sites | 1 head | unchanged | unchanged — R5 |
| `v8` | comma-list assign + whole read + repeated read | 1 head | **0 — CONVERTS** | 0 |
| `v9` | a member the builder never writes (x digits) | 1 head | unchanged | unchanged — correctly DECLINED |
| `v10` | a HIERARCHICAL read from a child, `assign o = dut.CFG.n;` | 1 head | **0 — CONVERTS** | 0 |
| `v11` | base reached through a CHAIN of bare parameter refs + two params of one type | 1 head (unrelated) | same | same; 3 cells TO-GOLDEN |
| `v12` | packed array of struct-bearing UNIONS | 1 head (unrelated) | same | same; 2 cells TO-GOLDEN |
| `v13` | the SAME packed-array-of-struct member written with a PLAIN CONSTANT | 1 head | **0 — CONVERTS** | 0 |
| `v14` | four further delay/strength shapes: `#(1:2:3)`, `#(2,4)`, `#D`, `(pull0, highz1)` | 1 head | 1 head, **all four fields dropped** | 1 head, **all four restored** (the head is the unrelated `#D` residue, §6 RV4) |

Keyed census over the 16 arms, pristine -> r11u16 -> fix:
**AWAY-GOLDEN 7 -> 1, TO-GOLDEN 35 -> 41, MOVED-WRONG 0 -> 0.**
(The one `v10` row the scorer calls MOVED-WRONG is the dump BACKREFERENCE
artifact the pass's own README documents as trap (a): golden's cell prints as a
repeat, ours expanded, and `uhdm-cmp` judges that arm EQUAL.)

## 4. WHAT BROKE

### 4.1 THE SHARED-SLOT CLONE DROPS THE DRIVE STRENGTHS — FIXED

`cont_assign::Compare` (UHDM `build/generated/src/cont_assign.cpp:99`) reads,
in order: `VpiNetDeclAssign`, `VpiStrength0`, `VpiStrength1`, `Delay`, `Rhs`,
`Lhs`, `Cont_assign_bits`.  `drainCaAsmMemberSlice`'s fresh `cont_assign`
carried only `VpiNetDeclAssign` and the span.

`v1c`, `assign (supply0, supply1) o_str = CFG.n;` —

```
GOLDEN   cont_assign  |vpiStrength0:11 |vpiStrength1:10 |vpiRhs: BIN…0011 sz 32 ct 3
PRISTINE cont_assign  |vpiStrength0:11 |vpiStrength1:10 |vpiRhs: hier_path (CFG.n)   <- head at `decompile:` on the Rhs
r11u16   cont_assign  (no strengths)   |vpiRhs: BIN…0011 sz 32 ct 3                  <- head at vpiStrength0
```

Golden KEEPS both strengths on the very cont_assign whose Rhs it folds.  The
patch gets the Rhs right and turns two fields pristine had RIGHT into wrong
ones.  With the strengths carried, `v1c` **converts**.

### 4.2 THE SHARED-SLOT CLONE DROPS THE DELAY — FIXED

`v1d`, `assign #3 o_dly = CFG.n;` — golden's elaborated cont_assign carries
`|vpiDelay: constant |vpiDecompile:#3 |vpiSize:64 |UINT:3 |vpiConstType:9`
beside the folded Rhs; pristine carried it (it shared the definition object
outright); the patch's clone has `Delay() == nullptr`, and `uhdm-cmp` prints
the head as `RHS: <null>`.  With the delay carried, `v1d` **converts**.

`v14` widens the face: a min:typ:max delay (`vpiOpType:38`), a rise/fall pair
(`vpiOpType:37`), a parameter-valued delay and the `(pull0, highz1)` strength
pair (32 / 1).  The submitted patch drops ALL FOUR; the fix reproduces golden's
payload on all four, delay operand trees included.

The fix carries `VpiStrength0`, `VpiStrength1`, `Delay` and
`Cont_assign_bits` onto the clone, and on the cloned Lhs `ref_obj` the four
fields `ref_obj::Compare` / `expr::Compare` read that were also being dropped
(`VpiDefName`, `VpiGeneric`, `VpiStructMember`, `VpiDecompile`, `VpiSize`,
`Typespec`).  Nothing new is minted; the delay EXPRESSION OBJECT is carried
over, and `BaseClass::Compare` reads only VpiType/VpiName/VpiDefName, never a
parent.  Over the whole uhdm2rtlil corpus the fix is **BYTE-IDENTICAL to the
submitted patch (0 movers / 1608)** — it only reaches shapes no corpus row
carries.

### 4.3 THE NESTED-STRUCT FENCE IS INCOMPLETE — RESIDUE, NOT FIXED

`v3`: a struct whose member is `inner_t [1:0] arr` (a packed ARRAY of packed
structs) written by a NESTED assignment pattern reaches the same producer bail
a bare packed-struct member does — golden's elaborated `CA.n` is
`constant, line:11:13 |vpiDecompile:5 |vpiSize:32 |UINT:5 |ct 9`, the leftover
arm's answer, with no typespec — while we assemble the base and the drain
slices `BIN:00000000000000000000000000000101 ct 3` off our own constant.  That
is precisely the cell the fence exists to refuse ("folding off OUR constant
there would put a cell that is merely wrong today onto a DIFFERENT wrong
answer"), and `ok16` misses it because it tests only the member's own canonical
kind.

**It is deliberately NOT tightened by type.**  The fence is keyed on the member
TYPE where the producer is keyed on the BUILDER's pattern shape, and two
measured arms prove a type-keyed widening would cost golden-agreed folds:
`v13` writes the SAME `inner_t [1:0] arr` member with a plain constant and
golden DOES assemble and fold (that arm CONVERTS), and `v12`'s packed array of
struct-bearing UNIONS likewise.  The cell is wrong before and after, and no
configuration turns a RIGHT cell wrong through this hole — the drain only fires
when our own assemble arm produced a constant, and in that state our
cont_assign cell is the unfolded `hier_path` (measured: `v3` pristine).
Recorded as a ranked residue with the comment at the fence rewritten to say so.

### 4.4 A NON-`ref_obj` Lhs IS DECLINED WHERE GOLDEN FOLDS — RESIDUE

`v6` `assign o_ps[15:0] = CFG.n;` and `assign {o_ca,o_cb} = CFG.n;`: golden
folds both to the member's 32 BIN digits at VpiSize 32; the law declines them
because the shared-slot path only clones a plain `ref_obj` target.  The pass
names the fence; the README's §3 `d8` line ("the target kind changes NOTHING
but the size; every one folds in golden") reads as though they were covered.
Two SAME-WRONG cells, no regression.

## 5. What did NOT break

* Legal SV faces that fold correctly and were not in the pass's own grid:
  five Lhs declaration shapes (`v2`), three elaborated instances off one def
  (`v4`), five further member typespec kinds (`v5`), a comma-list assign
  (`v8`), a HIERARCHICAL `dut.CFG.n` read from a child (`v10`), a chain of bare
  parameter references and two parameters of one struct type (`v11`), a packed
  array of struct-bearing unions (`v12`), a packed array of structs written by a
  plain constant (`v13`).  Every one TO-GOLDEN; five of them CONVERT.
* An x-bearing assembly (`v9`) is correctly declined — the producer's
  "only a FULLY-DEFINED slice is a usable value" rule is modelled.
* The four landed family laws, their converted tests and their bail witnesses:
  `FuncStructVal`, `FuncStructValSimple`, `struct_param_func_config`,
  `pkg_nested_struct_param_width`, `portsel_struct_param`,
  `def_ctx_struct_param`, `latch_decoder_partial` all CMP_EQUAL and unchanged;
  `StructParamFuncBodyFieldCompare`, `param_nested_struct_field_width`,
  `struct_param_field_shift`, `struct_member_cfg_width`,
  `cva6_struct_param_field`, `latch_tlb_napot` all CMP_NOTEQUAL with unmoved
  heads.
* `canaries.sh` u2r ok=8 changed=0 absent=0; `ctcan2.sh` PASS;
  `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0.
* Fence check: the four slang-fenced tests appear 0 times in the production
  diff and 0 times anywhere in this directory; no driver dispatches them.

## 6. Residues, ranked (on top of the pass's own R0–R6)

* **RV1** — the nested-struct fence's predicate (§4.3).  The producer keys on
  `assemble()`'s operand reduction; we key on the member type.  Closing it
  needs the PARAM-site assemble arm to take the producer's `tagged_pattern`
  bail, which is where R3 already points.
* **RV2** — a part-select or concat Lhs (§4.4): golden folds, the shared-slot
  path declines because it will not clone a target shape it has not decoded.
  One clone-builder away.
* **RV4** — a PARAMETER-VALUED continuous-assign delay (`assign #D o = …;`),
  `v14`: golden keeps `vpiDelay -> ref_obj (work@dut.D)`, we fold it to a
  `constant |vpiDecompile:#D |UINT:0`.  PRE-EXISTING and identical on pristine
  and patched — unrelated to this family, recorded because `v14` measures it.
* **RV3** — the emission sites of R5, re-measured here on `v7`: an interface
  body, a generate-if body, a generate-for body and a net-declaration assign
  all fold in golden and are all untouched, pristine and patched alike.

## 7. How to re-run

```bash
# per arm: Surelog golden + all three binaries
PRIS=<pristine> PAT=<patched> bash grid.sh v1 v1b v1c v1d v2 v3 v4 v5 \
                                          v6 v7 v8 v9 v10 v11 v12 v13
# the keyed elaborated-cont_assign census, gold vs pris vs pat
python3 cacen.py <arm>/gold.dump <arm>/pris.dump <arm>/pat.dump
```
