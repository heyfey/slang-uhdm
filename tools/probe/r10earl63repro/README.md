# r10earl63 — § constCallFoldAdjustSize63

**MEASUREMENT-ONLY directory** (the sources under it are probe arms; the only
production change this pass ships is in `src/ParamEmit.cpp`).  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `18340d0`.**  `results/*.csv` are READ-ONLY and untouched — **no corpus
row was converted by this pass** (Earlgrey_0_1 is `CMP_NOTEQUAL` before and
after; its head moved).

---

## 1. THE LAW

> **§ constCallFoldAdjustSize63 — an explicitly-TYPED integral parameter whose
> initializer is a foldable USER CONST-CALL gets the ExprEval PRODUCER's
> encoding run through `CompileHelper::adjustSize` against its OWN declared
> typespec.**  The FUNCTION BODY decides the encoding; the PARAMETER decides
> the width.  It is the very same {producer, consumer} pipeline
> § paramInitAdjustSizeElab52 already runs for a literal-originated
> initializer, and we were running **neither half** here.

PRODUCER (`constCallProducer63`, decoded from UHDM `ExprEval` and measured on
six grids):

| return-var assignment / `return` expression | producer |
|---|---|
| `{a,b}` (vpiConcatOp) | `BIN` at the CONCAT's own width |
| `{N{x}}` (vpiMultiConcatOp) | `BIN` at the REPLICATION's width **+ an int_typespec** |
| `c ? t : f` | `INT` at 64 |
| `a == b`, `<`, `>=`, … | `BIN` at **one** bit |
| `a-b`, `a*b`, `a/b`, `a%b` — predefined-integer return only | `INT` at 64 |
| `-a` — predefined-integer return only | `INT` at 64 |
| `$signed(a)` | `INT` at **one** bit |
| `x[h:l]`, `x[i]` over a packed base | `BIN` at the SELECT's width (§ selCallBin) |
| everything else (`+`, `>>`, `<<`, `\|`, `&&`, `\|\|`, `~`, `$clog2`, `$bits`, `$unsigned`, a literal, a local, a nested call) | `UINT` |

CONSUMER: `srlgAdjustSize` against `clsParam8`'s classification of the
parameter — `UINT` is MASKED to the target width, `INT`/`HEX`/`OCT` keep their
digits and TAKE the target width, `BIN` truncates from the left under a `logic`
target, sign-extends into a negative `vpiIntConst` under a signed `int` target
and is untouched under `bit`/`byte`/`shortint`/`longint`/`integer` — plus the
replication's own int_typespec arm, which only clamps `vpiSize` to
`min(producer, target)` and never touches the digits.

Three consequences the grids pin, none of which the old arm could produce:

* the DIGITS are the CALL's own value, not the parameter's — `bit [7:0] X =
  neg(300)` reads golden `INT:-300` at `vpiSize 8`, a value the 8-bit parameter
  cannot hold (`f3_earl63` `t_b8_neg`, `t_b8_sub`);
* a `UINT` producer renders the value UNSIGNED before the mask — `int I =
  bitnot(300)` (`return ~v` on an `integer`) is golden `UINT:4294966995`
  `vpiSize 32`, not `-301` (`f4_earl63` `i_not`);
* the LOGICAL operators are NOT the comparison family: `return v && 1` is
  `UINT:1` size 64 where `return v > 3` is `BIN:1` size **1** (`f5_earl63`
  `u_aand` vs `u_acmp`).

### THE HEAD IT CLEARS (earl62's R0, both Earlgrey modes)

`prim_ram_1p_adv.sv:32` — `localparam int Aw = vbits(Depth)` in the PARAMETER
PORT LIST, elaborated as `work@top_earlgrey.u_ram1p_ram_main` (`Depth =
16384`).  `vbits` is `prim_util.svh`'s `function automatic integer
vbits(integer value); return (value == 1) ? 1 : $clog2(value);` — a TERNARY
body, so the producer is `INT:14` and the `int` target's `adjustSize` keeps the
digits and takes the target width:

```
LHS(golden): constant 32:41-32:53  vpiDecompile "14"  vpiSize 32  INT:14   ct 7
RHS(ours)  : constant 32:41-32:53  vpiDecompile "32'b…1110"  vpiSize 32
                                   BIN:00000000000000000000000000001110  ct 3
```

`expr::Compare` reaches `VpiDecompile` FIRST, then `VpiSize`, then `Typespec`;
`constant::Compare` adds `VpiConstType` LAST — decoded from
`~/.local/include/uhdm/BaseClass.h` + `UHDM/build/generated/src/{constant,expr}.cpp`.
`VpiValue` is **not** read by any generated `Compare`; it is reported by the
census anyway because it names the Value TYPE Surelog folded to, which is what
the law is about.

**A 17-LINE REPRODUCTION** (`c2` in §3) puts the whole head in one file:
`function automatic integer vbits(integer v); return (v==1)?1:$clog2(v);
endfunction` + `module sub #(parameter int Depth=512, localparam int Aw =
vbits(Depth))` instantiated with `Depth=16384`.  Patched output is now
byte-identical to golden's `INT:14 / ct 7 / "14" / size 32`.

**THE BRIEF'S FRAMING WAS TOO NARROW, AND THE CENSUS SAID SO.**  The brief
asked whether "a localparam whose initializer is a USER FUNCTION CALL folds to
a plain DECIMAL constant".  It does not: `$clog2` written DIRECTLY as the
initializer is `UINT:9` while the SAME `$clog2` inside a user function is
`UINT:14` and the same function wrapped in a ternary is `INT:14` — the
function-call-ness is not the rule, the RETURNED EXPRESSION's ExprEval arm is.
`g_body_S`'s `clogs` cell and `f2_earl63`'s `i_a_clog` / `i_c_ternc` pair are
the refutation, in one file each.

---

## 2. FENCES (all four cost a measurement)

* **F1 TYPED ONLY.**  An UNTYPED localparam keeps the general arm, which is
  separately measured (`PreprocFunc`'s formal-argument typespec rule and the
  `RepeatStmt` `function [31:0] pow2` negative control ride there).  The
  untyped half of this same law IS decoded and measured here — see R1 in
  `PREDICT_R0.txt` — and is deliberately NOT shipped.
* **F2 NO RANGED-UNTYPED.**  `localparam [31:0] X = f(..)` keeps its own arm.
  Golden obeys the producer model there but its CONSUMER is not `logic`:
  `r4_cat` keeps EIGHT `BIN` digits at `vpiSize 4` where `logic [3:0]`
  truncates to four (`f4_earl63`), i.e. Surelog gives it the int_typespec arm.
* **F3 NO ENUM / STRUCT / > 64-bit targets** — their own arms own the encoding.
* **F4 EVERY ARGUMENT MUST BE INTEGRAL.**  This one was paid for by a REAL
  REGRESSION that the first patched sweep produced and the row gate caught:
  `ArrayExprFuncArg` (both modes) went `CMP_EQUAL → CMP_NOTEQUAL`.
  A four-cell ablation of that one file (`abl/`) names the discriminator:

  | cell | change | golden ELAB `MAX_VADDR` |
  |---|---|---|
  | `abl_a` | the file verbatim | `BIN:…101` size 32 |
  | `abl_b` | `VADDR` written as the literal `'{3,5,4}` | `UINT:5` size 32 |
  | `abl_c` | `abl_a` minus the three generate-if reads | `BIN:…101` size 32 |
  | `abl_d` | `abl_b` minus the three generate-if reads | `UINT:5` size 32 |

  so it is the ARGUMENT (an unpacked array produced by an unreduced const-call)
  and not the body, and not the reads.  `f6_earl63.sv` rebuilds the same body
  shape from scratch with a literal array and reads `UINT` in golden — which is
  why the fence is written on the ARGUMENT TYPE.  With F4 in place both
  `ArrayExprFuncArg` rows are byte-identical to the committed baseline again.

---

## 3. THE GRIDS (1,006 keyed cells, six homes, golden-vs-pristine-vs-patched)

`gen63.py` generates `g_{port,body,genif}_{F,S}.sv`: 3 homes ×
{`localparam`,`parameter`} × 12 declared types (`int`, `int unsigned`,
`integer`, `byte`, `shortint`, `longint`, `bit`, `bit [7:0]`, `logic [31:0]`,
`logic signed [31:0]`, untyped, ranged-untyped) × {7 user-call shapes, 16
non-call initializer shapes}.  `f2`–`f6_earl63.sv` are hand-written: 26
function-BODY shapes (F2), vector returns and concat/compare/negate/`$signed`
(F3), unary and system-function returns and replications into six targets (F4),
the ASSIGNMENT-form vs RETURN-form pairing of all twelve shapes (F5), and the
`ArrayExprFuncArg` body rebuilt with a literal array (F6).

`run63.sh` runs Surelog and one slang-uhdm binary over one arm; `pacen63`
(a DIRECT `.uhdm` reader — Earlgrey's `uhdm-dump` is > 1 GB, earl61/earl62's
lesson) emits one keyed line per `param_assign` with exactly the four fields
`constant::Compare` reads plus `VpiValue`; `cmp63.py` joins two censuses,
`score63.py` joins three (golden / pristine / patched) as a MULTISET and buckets
every cell TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-*.

**Golden-vs-golden was calibrated first**: every grid's DEF section is
identical on both sides before and after (the def-view `param_assign` Rhs of a
const-call is an unfolded `func_call` in golden and in ours), so the whole
measurement lives in the ELAB section.

| grid | cells | TO-GOLDEN | **AWAY-GOLDEN** | MOVED-WRONG | STILL-RIGHT | STILL-WRONG |
|---|---|---|---|---|---|---|
| `g_port_F` | 172 | **59** | **0** | 0 | 109 | 4 |
| `g_body_F` | 344 | **118** | **0** | 0 | 218 | 8 |
| `g_genif_F` | 176 | 0 | **0** | 0 | 122 | 54 |
| `g_port_S` | 388 | 0 | **0** | 0 | 336 | 52 |
| `g_body_S` | 776 | 0 | **0** | 0 | 672 | 104 |
| `g_genif_S` | 392 | 0 | **0** | 0 | 172 | 220 |
| `f2_earl63` | 66 | **25** | **0** | 1 | 38 | 2 |
| `f3_earl63` | 72 | **20** | **0** | 1 | 41 | 10 |
| `f4_earl63` | 70 | **15** | **0** | 0 | 42 | 13 |
| `f5_earl63` | 48 | **14** | **0** | 0 | 27 | 7 |
| `f6_earl63` | 22 | 0 | **0** | 0 | 13 | 9 |
| **total** | **2,526** | **251** | **0** | **2** | 1,790 | 483 |

The `_S` grids (non-call initializers) are the FENCE and they are byte-still:
**0 cells move in any of the 1,556 of them.**  `g_genif_*` is byte-still too —
the gen-scope home has its own arm (R2).

The two MOVED-WRONG cells were wrong before and after and lose no field:
`f2 i_i_hex` (golden does not fold `return 8'hab;` at all — R5) and
`f3 t_int_b8sub` (golden's digits are the UNMASKED `299`, ours the return-type
masked `43`; ct and size now right, decompile wrong before and after).

---

## 4. GATES (all mandatory legs, both binaries, frozen before any sweep)

Worktree `/tmp/wt_r10earl63` at `18340d0`; both builds `-j 2`, `md5` taken only
after `Built target slang_uhdm`, then frozen `chmod 555` under
`/tmp/r10earl63_bin/` BEFORE any sweep; `SLANG_UHDM` exported explicitly per
binary and **every one of the 1,458 + 956 `cmds.txt` audited by binary PATH**
(`/tmp/r10earl63_bin/pris` and `/tmp/r10earl63_bin/pat2`, nothing else).

| leg | result |
|---|---|
| pristine binary md5 | `453ceefaa6b1d6b1eb8d3ad81d4e0012` |
| patched binary md5 | `63fb95ea530aa509f87781a7aa62736c` |
| goldens, pristine / patched / `/bin/false` | 23-0 / 23-0 / **0-23** |
| u2r testflags + default (patched) | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, both modes |
| u2r `ct8rows` vs committed baseline, both modes | **PASS, 0 differing rows** |
| u2r `ct8rows` patched vs pristine sweep, both modes | **PASS, 0 differing rows** |
| u2r `byteverify SELFCHECK=1` | **MOVERS 0 / 1358**, selfcheck 1357/1358 |
| surelog `--mode both` `ct8rows` vs committed baseline | **PASS, 0 differing rows over 1588** |
| surelog `ct8rows` patched vs pristine sweep | **PASS, 0 differing rows** |
| surelog `byteverify SELFCHECK=1` | **MOVERS 2 / 956 — `default/Earlgrey_0_1` and `testflags/Earlgrey_0_1`, EXACTLY THE PREDICTED SET**, selfcheck 955/956 |
| named-row heads (`rowheads.sh`), pristine → patched | only `Earlgrey_0_1/testflags` moves, 64 → 28; every other row's depth unchanged |
| canaries | `ok=52 changed=0` (surelog), `ok=8 changed=0` (u2r) |
| `ctcan2` | `ok=58 changed=0` / `ok=1 changed=0`, both **PASS** |
| `canaudit.sh canaries.sh ctcan2.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| byte pins | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` byte-identical to pristine in BOTH modes |

**The mover set was PREDICTED BY NAME before the sweep** (Earlgrey_0_1, both
modes, and nothing else) and the byte verifier found exactly that — no
Scoreboard coin this time.  Earlgrey both modes are byte-deterministic per
binary, so both movers are real.

### The regression this pass CAUGHT AND FIXED before shipping

The FIRST patched binary (md5 `9f0e3c7b5c523895b87ab99cc17dbe98`, no F4 fence)
passed goldens, passed u2r 0-rows, passed u2r byteverify 0/1358 — and turned
**`ArrayExprFuncArg` from `CMP_EQUAL` to `CMP_NOTEQUAL` in BOTH modes**.  Only
the whole-row surelog gate saw it.  It is quoted here because the campaign's
rule is that a corpus row that WAS equal outranks any probe row that was not:

```
< ArrayExprFuncArg,default,CMP_EQUAL,,,differ
> ArrayExprFuncArg,default,CMP_NOTEQUAL,decompile:,,
```

`abl/` is the four-cell ablation that turned it into fence F4; the shipped
binary restores both rows byte-identically.

---

## 5. BOUNDARY (both shapes, both views, both binaries)

`vwide63.sh` — EVERY `.sv` under `tools/probe/` at ANY depth (list on fd 3,
children `</dev/null`, `PROCESSED` asserted), plain and `--elabuhdm`:

```
PROCESSED=2835 identical=5342 DIFFERING=66 no_output=262
signal rows: patched=8 pristine=8      (symmetric: pre-existing rc=139 arms)
```

`vdir63.sh` — every probe directory holding `.sv` files compiled as ONE unit:

```
PROCESSED=1336 identical=2388 DIFFERING=45 no_output=239
signal rows: patched=5 pristine=5      (symmetric)
```

**Every differing arm was then SCORED AGAINST GOLDEN**, not merely listed
(`armscore63.sh`, `dirscore63.sh` — Surelog + both binaries + `pacen63` +
`score63.py`):

| boundary | arms | cells | TO-GOLDEN | **AWAY-GOLDEN** | MOVED-WRONG | STILL-RIGHT | STILL-WRONG |
|---|---|---|---|---|---|---|---|
| per-file (33 movers) | 33 | 695 | **109** | **0** | 65 | 477 | 44 |
| per-directory (23 movers) | 23 | 485 | **32** | **0** | 53 | 382 | 18 |

**0 pristine-right → patched-wrong cells in either boundary.**  Every mover is
an `rgg`/`rggen`/`vrgg`/`oth3` const-call-parameter arm, i.e. the law's own
family; the MOVED-WRONG cells are all the same shape — golden's fold VALUE
differs from slang's (Surelog's 64-bit `ExprEval` model, `SrlgFold`'s domain, R4)
— and they were wrong before too; the pass makes their SHAPE right (`UINT` +
decimal decompile) and leaves the digits wrong.

**One listed mover was an INSTRUMENT ARTEFACT and is refuted here.**
`vdir63` reported `elab r10uvm88repro` as DIFFERING; the retained staging pair
shows FOUR diff lines that are a `vpiTaskFunc` LIST-ORDER flip of
`p3::base3::oob_base` — the known nondeterminism coin (RESUME §9).  Sorted
(order-blind) the two dumps differ by **0 lines**, and three runs of EACH binary
on that arm give ONE md5 (`13a6f965cea185c489d09cf0700e1c6f`, six runs).  It is
not a mover.

**A first version of `armscore63.sh` was also thrown away as an instrument.**
It scored the whole path-normalised `uhdm-dump` as a MULTISET OF LINES and
reported `FIXED == BROKEN` on several arms (`w_pkgparam_gate` 233/233).  That
was an artefact: the dump's commonest lines are bare `|vpiParent:` /
`|vpiOperand:` markers, so one changed constant shifts the MULTIPLICITY of
dozens of identical strings and the diff counts each shift twice.  The shipped
scorer is keyed on the OBJECT (`pacen63` + `score63.py`) and has no such blind
spot; the discarded version's numbers appear nowhere in this report.

---

## 6. FILES

| file | what |
|---|---|
| `pacen63.cpp` | `param_assign` Rhs ENCODING census, read straight from a `.uhdm` (never `uhdm-dump`); one keyed line per `param_assign` = (DEF/ELAB, owner, line:col, param name, Rhs kind, ct/size/value/decompile, `vpiOverriden`); `R63_INST=1` swaps the defname for the instance fullname |
| `cfind63.cpp` | locates a cmp HEAD by span in a database too large to dump: every `constant` at `<line>[:col]` with its file, its Compare-visible fields and its full parent chain — this is how both new R0 heads were named |
| `gen63.py` | the 6-home × 12-type × 23-initializer grid generator |
| `run63.sh` | one arm → Surelog golden + one slang-uhdm binary → two `pacen63` censuses |
| `cmp63.py` | 2-way keyed join (golden vs ours) |
| `score63.py` | 3-way keyed join (golden / pristine / patched) with the TO-GOLDEN / AWAY-GOLDEN buckets |
| `f2..f6_earl63.sv` | the hand-written function-body / return-shape / argument-shape grids |
| `abl/` | the four-cell `ArrayExprFuncArg` ablation that defines fence F4 |
| `earl63.sh` | Earlgrey_0_1 in either mode with ONE binary → `{slang.uhdm, cmp.log}` against the immutable golden cache |
| `vwide63.sh`, `vdir63.sh` | the recursive per-file and the per-directory boundary sweeps |
| `armscore63.sh`, `dirscore63.sh` | score every boundary mover AGAINST GOLDEN |
| `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the standard gate battery, carried forward unchanged |
| `PREDICT_R0.txt` | the two NEW heads (default and testflags), named off the parent chain, plus the ranked residue list |
