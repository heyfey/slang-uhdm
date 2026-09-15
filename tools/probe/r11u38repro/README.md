# r11u38 — § dimMemberSelBinFold38 + § paNameCopiesSrcConst38

**THE TWO SUBSTITUTIONS A NAME MAKES.** The r11u29 triage's **K8** — "a folded
constant's ENCODING at equal size" — is two tests on two different producer
arms, and this pass decodes both.

1. **§ dimMemberSelBinFold38.** A size-form unpacked dimension written
   `[<struct parameter>.<member>]` is `ExprEval::hierarchicalSelector`'s FIRST
   arm's mint: a fresh `BIN:` bit string of the member's own bits, decompiled
   BARE, sized at the member, carrying a ref onto **the member's own
   typespec** — and re-spanned on the BASE NAME's token.
2. **§ paNameCopiesSrcConst38.** A DEFINITION-listing `param_assign` Rhs folded
   from a bare NAME of a package parameter **is that parameter's own constant,
   copied**: the value tag and the `vpiConstType` come from the SOURCE, never
   from a re-derivation off the target's declared type.

Base `6068228a`, worktree `/tmp/wt_r11u38`, patch `/tmp/r11u38.patch`.
Production surface: `src/TypeEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h`,
`src/UhdmExporter.cpp`, `include/UhdmExporter.h`.
**`results/*.csv` WAS READ ONLY.** LHS is ALWAYS golden; the judge is the
official `uhdm-cmp` through `scripts/verify_golden.py`.

## HEADLINE — SAY IT LOUDLY

**`struct_param_dim` CONVERTS IN BOTH MODES.**

```
< struct_param_dim,default,CMP_NOTEQUAL,decompile:,,
> struct_param_dim,default,CMP_EQUAL,,,differ
< struct_param_dim,testflags,CMP_NOTEQUAL,decompile:,,
> struct_param_dim,testflags,CMP_EQUAL,,,differ
```

**uhdm2rtlil goes 776/28 -> 777/27 CMP_EQUAL/CMP_NOTEQUAL in BOTH MODES.**
The Surelog suite stays **474/9 default and 469/8 testflags**, byte for byte.
`ibex_icache`'s head CLEARS (64 cmp lines -> 60, a NEW head object) but the row
does not convert: its database still differs from golden on 7588 dump lines in
other families.

## 1. The two heads, re-measured at 6068228a

Own build from this worktree, `-j 2`, md5 `fad856692f9431ebe8e264a4ed99f3bf` —
**byte-identical to the main tree's `build/slang-uhdm` at the base and to the
OPS-stated md5**, so the baseline is the pin and not a copy. Frozen `chmod 555`
at `/tmp/r11u38_pris.bin`; every `cmds.txt` of every sweep in this pass names an
immutable frozen path and no other.

| row | cmp lines | heads | cmp rc |
|---|---|---|---|
| `ibex_icache` default | 64 | 1 | 255 |
| `ibex_icache` testflags | 64 | 1 | 255 |
| `struct_param_dim` default | 64 | 1 | 255 |
| `struct_param_dim` testflags | 64 | 1 | 255 |

`evidence/pristine_*.cmp` carries all four in full. Quoted, LHS = golden:

**`struct_param_dim`** — `logic mem[pt.t]` with
`parameter test_struct_t pt = 32'h4` (`dut.sv:16`, `dut.sv:8`):

```
LHS:                                     RHS:
constant: , line:16:13, endln:16:15      constant: , line:8:34, endln:8:39
|vpiParent: \_operation: 16:13-16:17     |vpiParent: \_operation: 16:13-16:17
|vpiDecompile:000…00000100               |vpiDecompile:32'h4
|vpiSize:32                              |vpiSize:32
|BIN:000…00000100                        |UINT:4
|vpiTypespec: \_ref_typespec:            |vpiTypespec: \_ref_typespec:
   |vpiActual: \_logic_typespec: 5:25       |vpiActual: \_struct_typespec: (test_struct_t)
|vpiConstType:3                          |vpiConstType:9
```

FOUR judged fields on ONE cell, and the owning site is the **right bound of the
size-form unpacked dimension** — `[E]` rewritten to `[0 : E-1]`, the operand of
that `vpiSubOp`. The whole-database order-blind dump diff is **that cell and
nothing else**, which is why this row was the conversion candidate before a line
was written.

**`ibex_icache`** — `parameter int unsigned TagSizeECC = IC_TAG_SIZE`
(`ibex_icache.sv:17`), with `ibex_pkg::IC_TAG_SIZE = ADDR_W - IC_INDEX_W -
IC_LINE_W + 1`:

```
LHS:                                     RHS:
constant: , line:17:44, endln:17:55      constant: , line:17:44, endln:17:55
|vpiParent: \_param_assign: 17:26-17:55  |vpiParent: \_param_assign: 17:26-17:55
|vpiDecompile:22   |vpiSize:32           |vpiDecompile:22   |vpiSize:32
|INT:22                                  |UINT:22
|vpiTypespec: … \_int_typespec: 17:13    |vpiTypespec: … \_int_typespec: 17:13
|vpiConstType:7                          |vpiConstType:9
```

The owning site is the **DEFINITION listing's `param_assign` Rhs**
(`work@ibex_icache`, `uhdmallModules`). The whole-design `param_assign` census
on the pristine database reports **148 cells agreeing and exactly ONE
differing** — this one, and only its definition-view copy: the elaborated copy
already matches golden. The pass-32 landing's ibex_icache mover was a RANGE
BOUND and a different cell; this is the sibling the brief predicted.

## 2. The producers, decoded

### 2a. § dimMemberSelBinFold38 — `hierarchicalSelector`'s FIRST arm

`CompileHelper::compileRanges`
(`Surelog/src/DesignCompile/CompileExpression.cpp:4038-4155`) rewrites `[E]` into
`[0 : E-1]` and compiles `E` with `Reduce::Yes`. A member select goes through
`ExprEval::decodeHierPath` -> `ExprEval::hierarchicalSelector`
(`UHDM/templates/ExprEval.cpp:2329-2403`), whose **FIRST** arm fires: the base
resolves to the parameter's own `param_assign` Rhs CONSTANT carrying a
`struct_typespec`, so the member is sliced straight out of the packed bits and a
NEW constant is minted —

```cpp
c->VpiValue("BIN:" + mbits);   c->VpiDecompile(mbits);       // BARE, no <w>'b
c->VpiSize(mbits.size());      c->VpiConstType(vpiBinaryConst);
ref_typespec -> THE MEMBER'S OWN typespec
```

— recursing on the next level, so a NESTED read simply adds the offsets. FIRST
DECLARED MEMBER OCCUPIES THE MSBs. The arm mints no location; the
`compileExpression` tail re-spans the result on the expression node's FIRST
CHILD (§ dimExprBoundFold79's span rule), which is the BASE NAME's own token.

**THE ARM WE USED TO MODEL IS THE OTHER ONE.** `hierarchicalSelector`'s later
`constant *cons` arm (`ExprEval.cpp:2690`) MUTATES the base constant in place to
`UINT:<value>` at the member width and leaves the STRUCT typespec on it. That is
exactly the pristine shape — `32'h4` decompile, `UINT:4`, ct 9, a per-use
`struct_typespec` clone — a correct model of the OLD code path, and dead at this
pin because the new first arm preempts it.

### 2b. § paNameCopiesSrcConst38 — `CompileHelper::getValue`'s substitution

A name written as a parameter's default reduces through
`CompileHelper::getValue` (`CompileExpression.cpp:966-981`), which mints the
operand from the DEFINITION-time stored `Value`:

```cpp
c->VpiValue(sval->uhdmValue());        c->VpiDecompile(sval->decompiledValue());
c->VpiConstType(sval->vpiValType());   c->VpiSize(sval->getSize());
```

— the SAME four-field stamp § dimBoundInheritsParamEnc74 decoded at an
unpacked-dimension bound, at the `param_assign` site this time. That stored
`Value` is `ExprEval::reduceExpr`'s answer over the SOURCE's own initializer
(§ caFoldEnc27's operator table), and `CompileHelper::adjustSize`
(`CompileHelper.cpp:3949-4218`) has NO arm that re-types a `vpiIntConst`, so the
encoding survives the hop intact and the TARGET's declared type contributes
nothing to it.

**WHERE THAT VALUE LIVES, measured and not assumed.** It is the **ELABORATED**
package listing, not the definition one: golden's `uhdmallPackages` is written
before elaboration and keeps `SUB = A32 - 8 - 3 + 1` as an `operation`
(`vpiOpType:24`, `g2_paenc38.sv:4`), while `uhdmtopPackages` carries the reduced
`INT:22` constant every reader of the name is handed. A first draft of this law
read the DEFINITION listing's Rhs and moved **nothing at all**; a second read it
at the end of the emitting `emitParameters` call and moved nothing either,
because several later passes install a package parameter's folded constant after
that call returns. The law is therefore a **design-level drain**
(`drainPaNameCopySrc38`, dead last in `exportDesign`) reading a settled Rhs on
both sides.

## 3. THE GOLDEN GRID

`goldengrid38.sh` + `grid/`, three arms plus a NEGATIVE CONTROL, every arm
compiled by BOTH producers with both rcs and Surelog's own `[FATAL]`/`[ERROR]`
counts printed (`golden_rc=0 ours_rc=0 FATAL=0 ERROR=0` on all three; the `zz`
arm names a file that does not exist and is the ONLY compiled-nothing arm). Two
POSITIVE CONTROLS are asserted: golden must carry at least one `BIN:` member
fold in `g1` and at least one ct 7 `param_assign` in `g2`, or the grid is blind.

* **`g1_memsel38`** — THE MEMBER SHAPE. Eleven member selects across five packed
  structs (a one-member struct, a three-member struct read at the FIRST /
  MIDDLE / LAST member, `int`, `byte`, two `bit` members, a NESTED
  `po.n.u`, and a member read after a struct member), on a VAR and on a NET,
  beside the two arms this law does NOT claim:

  | written bound | golden |
  |---|---|
  | `[p1.t]` logic [31:0], only member | `BIN:…00100` ct 3 size 32, `logic_typespec` |
  | `[p3.a]` logic [7:0], FIRST (MSBs) | `BIN:00001010` size 8 |
  | `[p3.b]` logic [15:0], MIDDLE | `BIN:0000001100000000` size 16 |
  | `[p3.c]` logic [7:0], LAST | `BIN:00000101` size 8 |
  | `[pi.i]` int | `BIN:…00110` size 32, `int_typespec` |
  | `[py.y]` byte, FIRST | `BIN:00000111` size 8, `byte_typespec` |
  | `[py.z]` logic [23:0] | `BIN:…0001000` size 24 |
  | `[pb.p]` bit [11:0], FIRST | `BIN:000000001001` size 12, `bit_typespec` |
  | `[pb.q]` bit [3:0] | `BIN:1010` size 4, `bit_typespec` |
  | `[po.n.u]` NESTED logic [31:0] | `BIN:…01011` size 32, `logic_typespec` |
  | `[po.m]` logic [7:0] after a struct member | `BIN:00001100` size 8 |
  | `[p3.b-1:0]` a RANGE-form bound | `INT:767` ct 7 at 64 — **not this law** |
  | `[p3.a + 1]` a select inside an ADD | `UINT:11` ct 9 at 64 — **not this law** |

  and the span is the BASE NAME's token on every claimed row (`[p1.t]` folds at
  `17:15-17:17`, which is `p1`; `[po.n.u]` at `26:15-26:17`, which is `po`).
  The two unclaimed rows are DISJOINT BY CONSTRUCTION — this law claims a bound
  whose expression IS a `MemberAccess` and nothing else — and both already agree
  with golden at pristine.

* **`g2_paenc38`** — THE SOURCE ENCODING x THE TARGET TYPE. One module with 18
  parameters and 5 localparams reading 11 package parameters, instantiated twice
  (default and with one override), scored in the DEFINITION listing, the
  ELABORATED listing and the package's own two listings:

  | written default | golden (definition listing) |
  |---|---|
  | `int unsigned P = SUB` (`= A32-8-3+1`) | `INT:22` ct 7 |
  | `int` / untyped / `bit [7:0]` / `logic [15:0]` `P = SUB` | `INT:22` ct 7 |
  | `P = MUL` (`= A32*2`) | `INT:64` ct 7 |
  | `P = CMPV` (`= (A32>8)`) | `BIN:1` ct 3 |
  | `P = NEG` (`= 0-5`) | `INT:-5` ct 7 |
  | `P = ADDU` (`= A32+8`) / `CLG` / `LIT` | `UINT:` ct 9 |
  | `P = LVEC` (`= 8'hA5`) | `HEX:A5` ct 5 |
  | `P = ip::SUB` QUALIFIED, `P = HOP` (a hop) | `INT:22` ct 7 |
  | `P = SUB` on an OVERRIDDEN instance parameter | `INT:22` ct 7 |
  | `L = P_SUB` / `L = L_SUB` (a MODULE-local name) | a `ref_obj`, unfolded |
  | `P = CAT` (a source whose own Rhs is an operation) | a `ref_obj`, unfolded |

  The declared TARGET type is not an axis on any row. The SIZE is the source's
  (`bit [7:0] P_BSUB = SUB` is golden size 32 in the definition listing and 8 in
  the elaborated one), which our emitter already tracks.

* **`g3_home38`** — THE HOLDER and the non-integral sources: a package ENUM
  parameter, a STRING one, a REAL one, a CROSS-package hop (`pb::R1 = pa::S1`
  then `M6 = pb::R1`), a package parameter naming a sibling, an INTERFACE
  parameter, and a module localparam. Every integral row measures identically to
  `g2`.

**SCORE (gold x pristine x law, per cell, view-aware — `evidence/grid_score38.txt`):**

| arm | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG | UNMOVED |
|---|---|---|---|---|---|
| `g1_memsel38` | **12** | **0** | 0 | 0 | 2 |
| `g2_paenc38` | **11** | **0** | 1 | 12 | 100 |
| `g3_home38` | **5** | **0** | 0 | 8 | 57 |
| **total** | **28** | **0** | **1** | **20** | **159** |

The single MOVED-WRONG is `work@m.P_NEG`: golden `INT:-5`, pristine
`UINT:4294967291`, law `INT:4294967291`. The const type and the tag land on
golden and the DIGITS do not, because the source we copy — our own elaborated
`ip::NEG` constant — already carries `4294967291` where golden carries `-5`.
That is a pre-existing negative-fold residue of the package elaborated listing,
named in §7, and this law models the copy faithfully rather than papering over
it. Every STILL-WRONG cell is a real/string/`ref_obj` residue this law
deliberately abstains from.

## 4. THE WIDE BOUNDARY — and the two AWAY-GOLDEN cells it caught

`boundary38.sh` compiles **every** `.sv`/`.svh`/`.v` under `tools/probe` —
**7058 files, LISTED == PROCESSED == 7058**, subdirectory arms included, the file
list read on fd 3 with each child's stdin closed — using the **NEUTRAL** binary
(`R11U38_OFF=1`), so each law's CLAIMS are printed without a byte being written.
Its own positive control is this pass's grid, which must claim cells or the
driver is blind (it claims 29).

**The first version of § paNameCopiesSrcConst38 failed here, and that is what
the boundary is for.** It copied the source constant whenever the source's const
type was integral, and over the committed arms it produced:

* **AWAY-GOLDEN** `r10rgg1repro/v5_vrgg1.sv work@dut_v5.L3` — golden and
  pristine both `BIN:10` ct 3 size 2; the copy wrote `UINT:2` ct 9.
* **AWAY-GOLDEN** `r10v201repro/grid_v201/v201_a_refforms.sv work@m201va.R_RNG`
  — golden and pristine both `DEC:12` ct 1 size 6; the copy wrote `INT:12` ct 7.
* three cells where the source was ALSO `UINT:` and only the DIGITS changed,
  wrongly: `r10earl93repro/g6_pkg93.sv work@g6.i_64`,
  `r10v93repro/v1_ctx93.sv work@v1_top.L_imp`,
  `r10v93repro/v5_more93.sv work@v5_top.v5_b`.

**The gate the boundary bought** is the one now in the code: the law fires only
when OUR OWN cell is the generic unsigned fold (`vpiUIntConst`) AND the source's
const type is something else. A cell we did not write as `UINT:` is already
carrying an arm's deliberate answer; a same-tag copy is a SIZE/TRUNCATION
question, which is a different law.

**Re-measured with the gate in place** — 7 committed arms outside this pass's
grid carry a claimed cell, each re-compiled by BOTH producers and scored
view-aware:

| arm | golden_rc | ours_rc | TO-GOLDEN | AWAY | MOVED-WRONG |
|---|---|---|---|---|---|
| `r10earl52repro/v1_earl52.sv` | 0 | 0 | **5** | 0 | 0 |
| `r10earl52repro/a3_earl52.sv` | 0 | 0 | **1** | 0 | 0 |
| `r10earl60repro/vfa_v60.sv` | 0 | 0 | **2** | 0 | 0 |
| `r10earl_repro/wa.sv` | 0 | 0 | **1** | 0 | 0 |
| `r10v187repro/arms187/v187_i_signedonly.sv` | 0 | 0 | **1** | 0 | 0 |
| `r10earl60repro/vfe_v60.sv` | **4** | 0 | 1 | 0 | 1 |
| `r10earl60repro/vff_v60.sv` | 0 | **4** | 1 | 0 | 1 |
| **total** | | | **12** | **0** | **2** |

**AWAY-GOLDEN 0 over 7058 committed arms.** Both MOVED-WRONG cells sit on an arm
where one producer's compile FAILS, so neither is golden evidence:

* `vfe_v60` `work@s_take2.t_cmp` (Surelog exits 4) — golden `BIN:1 ct3 sz1
  dec=1`, pristine `UINT:1 ct9`, law `BIN:1 ct3 dec=1'b1`: value and const type
  land on golden, the rendering does not.
* `vff_v60` `work@s_np.u_catsel` (our own compile exits 4, *"unsupported
  constructs: range select base"*) — golden keeps an `operation` and folds
  nothing; pristine and law are both a constant, wrong before and wrong after.

The five `v1_earl52` / `a3_earl52` cells are the ones that made the census
VIEW-AWARE: pooling `uhdmallModules` with `uhdmtopModules` in one multiset read
them as MOVED-WRONG when the definition entry had in fact landed exactly on
golden (`BIN:1` ct 3 decompiled `1'b1`, from pristine's `UINT:1` ct 9 decompiled
`1`) and the elaborated entry had not moved at all. The two listings have two
producers; a law that claims one of them must never be scored against a multiset
that pools both. `pacen38.py` now keys by view.

## 5. THE MOVER PREDICTION — a priori, BY NAME, with a positive control

`predict38.sh` runs the **NEUTRAL** binary over the exact command line every row
of a pristine `verify_golden` workdir already used (the source directory is
recovered from the workdir leaf's `sha1(dir)[0:8]`, and every rebuilt command
line is audited to a file), and prints one line per claimed cell keyed by row.

**uhdm2rtlil — LISTED == PROCESSED == 1742, and the whole corpus claims FOUR
cells in TWO rows:**

```
ibex_icache       R11U38 PA  work@ibex_icache.TagSizeECC src=IC_TAG_SIZE
                             old=UINT:22/ct9/sz32  new=INT:22/ct7
struct_param_dim  R11U38 DIM mem @16:13 w=32 bits=00000000000000000000000000000100
```
(one per row per mode).

**Surelog suite — LISTED == PROCESSED == 1581, and the whole corpus claims
ZERO cells.**

**THE POSITIVE CONTROL FOR THE NEUTRAL BINARY.** A full `verify_golden` sweep
with `R11U38_OFF=1` over uhdm2rtlil, both modes, byte-compared against the
pristine sweep:

```
databases: patched=1608 pristine=1608   PATH_SETS_IDENTICAL
MOVERS: 0 / 1608        SELFCHECK: 1607 / 1608 flagged
```

so the neutral binary IS pristine, and every byte the law binary moves is these
two laws and nothing else. The same OFF sweep over the Surelog suite moves 4
databases — `MiniAmiq` (both modes), `SeqDriver`, `SimpleUVM` — which is the
proof that those are the documented per-invocation coin and not a law.

## 6. THE GATES

| gate | result |
|---|---|
| pristine build, `-j 2`, md5 | `fad856692f9431ebe8e264a4ed99f3bf` — byte-identical to the main tree at `6068228a` |
| law build, `-j 2`, md5 | `7cc9a38434c99391ba8e604a7a0030e6`, 0 compiler errors |
| `tests/check_goldens.sh` | **23 PASS / 0 FAIL** |
| negative control `SLANG_UHDM=/bin/false` | **0 PASS / 23 FAIL** |
| every `cmds.txt` audited by binary PATH | frozen `chmod 555` paths only |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | 1 row: the `struct_param_dim` CONVERSION |
| u2r default vs the pristine control | 1 row: the `struct_param_dim` CONVERSION |
| u2r both modes | 776/28 -> **777/27** |
| surelog both modes vs `results/golden_surelog.csv` | 0 status rows, 0 dump-column rows |
| surelog both modes | 474/9 and 469/8, unchanged |
| `byteverify` u2r (SELFCHECK on) | **4 / 1608**, every one PREDICTED BY NAME |
| `byteverify` surelog (SELFCHECK on) | **4 / 960**, UVM coin only, attributed order-blind |
| `canaries.sh` vs MY pristine control, surelog / u2r | `ok=52 changed=0` / `ok=8 changed=0` |
| `canaries.sh` vs the committed CSVs | `ok=51 changed=1` / `ok=8 changed=0` — the one row is `Earlgrey_0_1`/testflags `CMP_EQUAL/differ -> CMP_EQUAL/<blank>`, a uhdm-dump TIMEOUT draw that reads the SAME way in my PRISTINE sweep, on a database byte-identical to the pin |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |

**THE CANARY DATABASES, by name and by md5 against the pristine control:**

| canary | default | testflags |
|---|---|---|
| `Earlgrey_0_1` | `8bdf25272e08` = pin | `59d0ee6d10c3` = pin |
| `SVSwitch` | `4842211c4030` = pin | `4842211c4030` = pin |
| `YosysVerx` | `6ccda350c24a` = pin | `6ccda350c24a` = pin |
| `InterfaceModPort` | `59a365f3ce2c` = pin | `59a365f3ce2c` = pin |
| `BlackParrotComplex` | same as pristine | same as pristine |
| `YosysOldOr` | same as pristine | same as pristine |
| `Rggen` | same as pristine | (no testflags database) |

`rowheads.sh` over the UVM family and the canaries reads **0 cmp lines / 0
heads** on `SeqDriver`, `SimpleUVM`, `Scoreboard`, `MiniAmiq`, `BuildUVMPkg` and
`Earlgrey_0_1` in both modes, and `Rggen`/default keeps its own pre-existing
head byte-identical to pristine's.

**THE SURELOG BYTE MOVERS, attributed.** The law sweep moves 4 of 960 databases,
every one in the UVM family. Each was re-dumped and diffed ORDER-BLIND with the
workdir path normalised away:

| database | order-blind differing lines | what they are |
|---|---|---|
| `Scoreboard`/default | 2 | the dump BANNER (the workdir path) only — content identical |
| `SimpleUVM`/default | 2 | the same |
| `MiniAmiq`/testflags | 6 | the banner + one `UINT:696` / `vpiDecompile:696` against `UINT:0` / `0` |
| `SeqDriver`/testflags | 6 | the banner + the same pair at `1509`, in the OPPOSITE direction |

That is the documented line-number class (RESUME §9), it moves both ways, and
the NEUTRAL binary — proven byte-identical to pristine on 1608 uhdm2rtlil
databases — produces its own set of four on the very same corpus
(`MiniAmiq` both modes, `SeqDriver`/default, `SimpleUVM`/default), which is the
control that names this class a per-invocation coin and not a law. An earlier
law build drew a different subset again (five: the four above plus
`SeqDriver`/default). No cell of either law appears in any of them, and every
UVM row stays CMP_EQUAL.

## 7. RESIDUES, and R0

* **R0 — THE NEW `ibex_icache` HEAD, and it is the same question one site over.**
  `ibex_icache.sv:87 logic [IC_TAG_SIZE-1:0] fill_tag_ic0;` — a PACKED range
  bound whose substituted leaf is golden `INT:22` ct 7 at 32 where we write
  `UINT:22` ct 9 at 32, both carrying the same `int_typespec` at
  `ibex_pkg.sv:396`. It is § elabParamOpLeafValueFold85 / § rangeBoundReduceEnc33
  territory: **the stored `Value`'s ENCODING at an OPERATION LEAF**, the third
  site of the same substitution this pass decoded at a dimension bound and at a
  `param_assign`. 60 cmp lines, 1 head, both modes.
* **R1 — the package ELABORATED listing's negative fold.** `ip::NEG = 0 - 5` is
  golden `INT:-5` and ours `INT:4294967291` (the slang value read unsigned at 32
  bits). It is what makes `g2`'s `P_NEG` the pass's one grid MOVED-WRONG, and it
  is a pre-existing residue of the package fold, not of this law.
* **R2 — a STRING or REAL package parameter read by name.** `g3`'s `M3 = STR`
  (golden `STRING:abc` ct 6, ours `UINT:6382179` ct 9) and `M4 = RP` (golden a
  `REAL:` constant, ours a bare `ref_obj`). Deliberately NOT claimed: a
  string/real hop is a different Value rendering and the UVM family is full of
  them.
* **R3 — the same-tag copy.** `vfa_v60 work@s_a.a_tm` (golden `UINT:10000000`,
  ours `UINT:10`) is a cell the un-gated draft fixed and the gated law declines,
  because three committed arms measured a same-tag copy as a SIZE/TRUNCATION
  question rather than an encoding one.
* **R4 — `struct_param_dim`'s remaining dump-only gap.** After the law our
  database has **ZERO lines golden does not have**; golden carries 59 lines we do
  not (spare copies of the shared struct typespec and the weaklyReferenced tail,
  unreachable to the judge). The row is CMP_EQUAL.

## 8. What was written

Five files, +414 lines, **no line removed**.

* `src/TypeEmit.cpp` — `memberSelBinFold38` (the member-chain walk, the MSB-first
  slice, the member typespec out of the SHARED typedef typespec, and the base
  name for the span) and the arm that calls it in `buildUnpackedRanges`' size-form
  branch, ahead of the pristine struct-clone arm, which stands unchanged whenever
  the new one abstains.
* `src/ParamEmit.cpp` — the two records (`pkgValuePa38`, `paNameSrc38`) and
  `drainPaNameCopySrc38`.
* `src/UhdmExporter.cpp` — the drain's call, dead last in `exportDesign`.
* `src/EmitHelpers.h` — `R11U38_CELLDBG` and `R11U38_OFF`, both inert when unset.
* `include/UhdmExporter.h` — the declarations and the two maps.

## 9. Reproducing

```bash
tools/probe/r11u38repro/goldengrid38.sh  <binary> <outdir>     # the grid, both producers
tools/probe/r11u38repro/score38.py {dim|pa} <gold> <pris> <law>  # the three-way score
tools/probe/r11u38repro/predict38.sh <workdir> <binary> <outdir> # the a-priori movers
tools/probe/r11u38repro/boundary38.sh <binary> <outdir>          # 7058 committed arms
```
