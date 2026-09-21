# r11v80 — the adversarial verification of r11u80, and the three faces the
# builder had to be told about

Base commit `15ff66f6`. Both binaries rebuilt from scratch in this verifier's
own worktrees, `-j 2`, md5 taken separately, frozen `chmod 555` before any
sweep:

```
pristine   c56e3f2c141ee7e9a6bb41c9d4e38f8c   == the main tree's build/slang-uhdm
                                                 @15ff66f6 and == the OPS pin
r11u80     b1136aebd7f36e4e42a8ea30f23e3f9e   == the implementer's claimed md5,
                                                 reproduced BIT FOR BIT from a
                                                 fresh 15ff66f6 + /tmp/r11u80.patch
r11u80.verified  a27d19b6f7515623f3c1d19c753153ce   the same tree + the two
                                                    corrections below
```

This patch applies clean on a FRESH `15ff66f6` worktree (`git apply` rc=0,
output written to a file), reproduces `src/ModuleEmit.cpp` byte-identically
(`43b105db65af99a26ace4ce4f15cd23c`) and both probe directories, and a clean
`-j 2` build of that tree links `a27d19b6f7515623f3c1d19c753153ce` bit for
bit.  `GATES.r11v80.txt`, `CENSUS.r11v80.txt`, `LEDGER.r11v80.txt` and
`LEDGER.r11u80-as-submitted.txt` carry every number.

`src/ModuleEmit.cpp` reproduced byte-identically from the implementer's patch
(`efde22ca03f9e799c406e46198edabc4`) before the fixes; `src/ParamEmit.cpp`
untouched by both (`fadfb3803a8b57c44cfad3e61b2fb4d4`, the pristine md5 — the
sister pass's ground is intact); patch surface = `src/ModuleEmit.cpp` +
`tools/probe/r11u80repro/` + this directory, `results/*.csv` never written,
the four slang-fenced names absent from the production diff.

---

## 1. VERDICT

**ACCEPT-WITH-FIX.** r11u80's two laws are real, decoded from the producer and
measured against real v1.87 goldens; every headline number reproduces; there is
**no pristine-right -> patched-wrong row anywhere** and **no object invented
that golden lacks**. But the holder builder, run over nine NEW arms spelling
faces r11u80's grid never wrote, mints **ten holders whose COMPARED fields are
not golden's** — the exact class pass 77's own law refuses ("a holder whose
compared fields are not golden's is the same invention"). All ten are on faces
r11u80 inferred from a single arm each. Two minimal, in-law corrections (§3)
clear all ten; the third face (§2c) is recorded as a refuted rule and a
residue, because neither binary matches golden there.

Ledger over **43 arms** (this verifier's 9 + r11u80's 34) x 2 dump sections,
golden vs pristine vs patched, at the ELEMENT level:

```
                       CONVERTED   MOVED-WRONG   STILL-WRONG   PRE-EXISTING
r11u80                    85            0            10             5
r11u80.verified          102            0             0             5
```

The five PRE-EXISTING are unchanged by both binaries and are listed in §6.

---

## 2. THE THREE FACES (each a measured golden table, each a defect)

### 2a. § caImportedPkgHoistUnpackedSizeFolds80 — the size-style dim folds, or contributes ONE

r11u80's LAW A states the hoist site takes "the plain product of the written
dimensions' widths" and that "IT IS NOT § fixedUnpackedCount6". Its whole
evidence for the second half is `z1_arrgrid` z_szexp, `logic [7:0] z_szexp
[2*2]`, golden FOUR. `[2*2]` is a *literal* expression: it folds on both
sites, so it separates nothing.

`compileRanges`' "specified by size" branch
(`CompileExpression.cpp:4062-4082`) evaluates the dimension with
`m_exprBuilder.evalExpr(fC, rexpr, instance, true)` and multiplies the running
product **only `if (rightV->isValid())`**. The "specified by range" branch
instead `reduceExpr`s both bounds and takes `eval.get_value`, which *does*
resolve parameters. At the package-import hoist site the instance handed to
`evalExpr` cannot see a package parameter, so a size-style dim that names one
contributes ONE.

MEASURED, one real Surelog golden per row, arm `q8_sizefaces` (plus the
two-dimensional faces on `q2_dims`); `PN` a package parameter, `LN`/`LM`
package localparams:

```
spelling            GOLDEN   r11u80   pristine   verified
[4]                    4        4         4         4
[2*2]                  4        4         4         4     <- r11u80's only arm
[3+1]                  4        4         4         4
[(4)]                  4        4         4         4
[PN]                   1        3         3         1
[LN]                   1        5         5         1
[PN*2]                 1        6         6         1
[LM*2]                 1        4         4         1
[0:3]                  4        4         4         4
[PN-1:0]               3        3         3         3     <- RANGE form resolves
[LN-1:0]               5        5         5         5
[PN][0:1]              2        6      <none>       2
[0:1][PN]              2        6      <none>       2
[PN][LN]               1       15      <none>       1
wire [PN]              1        3         3         1
wire [PN][0:1]         2        6      <none>       2
```

The 1-D rows are pre-existing (pristine wrote the outer width, which for one
dimension IS the product) and the patch preserved them; the multi-dimensional
rows are objects pristine did not write at all and r11u80 writes with a
`vpiSize` that is not golden's — and `expr::Compare` reads `VpiSize`.

The two laws still differ: § fixedUnpackedCount6 keys "param-sized" on
`kind != IntegerLiteralExpression`, which would make `[2*2]` ONE, and golden
reads FOUR here. The predicate this site needs is "the expression folds
without naming anything", implemented as `hoistSizeExprFolds80`.

### 2b. § caImportedPkgHoistUnpackedTdRoad80 — the typedef'd array takes the same road

r11u80's ArrayTdEmpty arm stamps `vpiVisibility 1` on every typedef'd unpacked
array and always binds a FRESH `array_typespec` carrying the UNQUALIFIED name.
Its evidence is `vb_unpackedfaces` u_td and `z1_arrgrid` z_td2 — both
`typedef logic [7:0] … [dims]`, the one base on which the two readings agree.

A typedef'd array takes `elabSignal`'s ordinary net-or-variable road, read on
the TYPEDEF'S OWN written base keyword. `paIntVec_TypeReg` is absent from the
non-net list, so a `reg`-based array typedef keeps `isNet` and lands in
`getSimpleVarFromTypespec` (`NetlistElaboration.cpp:2505-2512`), which names
the object and binds the RESOLVED typespec but **never stamps
`vpiVisibility`**; every other base goes through `makeVar_`, whose tail stamps
`vpiVisibility 1` (`ElaborationStep.cpp:2416`). And the unqualified clone is
golden only when the typedef's own written base is the `logic` keyword.

MEASURED, one real Surelog golden per row, arm `q5_tdarr`:

```
typedef                                GOLDEN                  r11u80
arr_t    logic [7:0] arr_t [0:1]       vis 1  ts (arr_t)        same
arr2d_t  logic [7:0] .. [0:1][0:2]     vis 1  ts (arr2d_t)      same
arr2_t   arr_t arr2_t                  vis 1  ts (pq5::arr2_t)  ts (arr2_t)   WRONG
arr3_t   arr2_t arr3_t                 vis 1  ts (pq5::arr3_t)  ts (arr3_t)   WRONG
arrs_t   sl_t arrs_t [0:1]             vis 1  ts (pq5::arrs_t)  ts (arrs_t)   WRONG
arrn_t   arr_t arrn_t [0:2]            vis 1  ts (pq5::arrn_t)  ts (arrn_t)   WRONG
arrr_t   reg [7:0] arrr_t [0:1]        NO vis ts (pq5::arrr_t)  vis 1 + (arrr_t) WRONG
```

`variables::Compare` reads `VpiVisibility`; `expr::Compare` reads `Typespec()`
and the typespec's own `Compare` reads `VpiName`. Both are compared fields.
Pristine wrote no holder for any of these seven, so all seven are r11u80's own
objects and five of them carry a non-golden field.

### 2c. LAW B's boundary — `var` does NOT always answer 0

Not fixed; recorded as refuted. `var static logic [7:0] v_stlog;` at package
scope (arm `q3_varnt2`): golden's def-view `vpiNetType` is **1**, pristine
stamps 36, r11u80 stamps none. Both binaries disagree with golden, so this is
a residue and not a regression — but LAW B's stated rule ("a `var` declaration
answers 0 whatever its base keyword") is refuted at this one boundary. The
cause is the same one-node offset the law decodes: with `var` AND a lifetime
keyword written, `CompileHelper.cpp:2341-2344` hops once and
`Child(data_type)` lands on a different node again. Every other `var`
spelling on `q3_varnt2` — `var logic`, `var reg`, `var w_t`, `var r_t`,
`var logic signed`, `var logic [3:0][7:0]`, `const var reg`, and the four
unpacked ones — CONVERTS to golden.

---

## 3. THE CORRECTIONS (both inside LAW A, both under `R11U80_HOLDER_OFF`)

`src/ModuleEmit.cpp` only:

1. `hoistSizeExprFolds80` + `hoistUnpackedSize80` — one flattened-size routine
   for both the `ArrayVar` and the `ArrayNet` arm, replacing the two inline
   product loops.
2. `ArrayTdEmpty` — `vpiVisibility` only off the `reg` road; the package's own
   typespec object unless the typedef's base is the `logic` keyword.

No new switch: both live behind § 80's own `R11U80_HOLDER_OFF=1` /
`R11U80_OFF=1`, so each law stays droppable alone and the SWITCH LEDGER is
UNCHANGED — reproduced with the verified binary on r11u80's own 34 arms:

```
arm                       ON     OFF   HOLDER_OFF   VARNT_OFF
vb_unpackedfaces         216       0            0         216
vh_arrelem               272       0            0         272
vi_defnt                   1       0            1           0
z1_arrgrid               678       0            1         677
z2_varnt                   5       0            5           0
... the other 29 arms 0 in every column
```

and on this verifier's nine (`OFF` 0 on every one, the two switches additive):

```
q1a_netchain  34/0/0/34     q5_tdarr     101/0/0/101
q1b_varchain 292/0/0/292    q6_twohop    665/0/1/664
q2_dims      584/0/0/584    q7_mixed     142/0/0/142
q3_varnt2    373/0/6/367    q8_sizefaces 417/0/0/417
q4_class     408/0/0/408
```

**The fixes move NONE of r11u80's 34 arms**: the whole-dump delta between the
r11u80 binary and the verified one is 0 lines on every one of them. They only
reach faces r11u80's grid never spelled.

---

## 4. THE NINE ARMS

| arm | what it asks |
|---|---|
| `q1a_netchain` | the element NAME/net-type one-hop seam on the NET road under typedef CHAINS (struct, union, logic) |
| `q1b_varchain` | the same seam on the VARIABLE road (reg / struct / int-struct / enum / union chains) |
| `q2_dims` | 2-D/3-D/4-D, descending, `[0:0]`, size-style, `[2*2]`, parameter- and localparam-sized, param x literal, param range, a packed dim beside unpacked ones, both roads |
| `q3_varnt2` | LAW B's boundary: `static`/`automatic`/`const` with and without `var`, var + chain, var + packed 2-D, and the unpacked spellings of each |
| `q4_class` | the whole element-class table — every integral atom, both floats, string, time, a packed 2-D element, 2-state-member and nested packed structs, int- and logic-based enums, net- and variable-declared |
| `q5_tdarr` | the typedef'd unpacked array: chains, 2-D, struct element, reg base, an array of a typedef'd array, and one with a declarator dim on top |
| `q6_twohop` | the `vpiAutomatic`/road predicate, `const` on an aggregate, `var` on enum/union, the signed faces |
| `q7_mixed` | THE BOUNDARY — the module's own arrays, an interface's, a function's locals, a class property, a generate block's, an EXPLICIT import and a qualified reference with no import |
| `q8_sizefaces` | the size-style dimension's fold, literal vs named, size form vs range form |

`q7_mixed` is the boundary control and it is clean: golden, pristine and the
verified binary agree on `m_own`, `m_own2` (the module's OWN 1-D and 2-D
arrays) and `h_plain` (the explicitly imported one); the only two names whose
dump lines move at all are `g_si` and `g_2d`, the two conversions.

Per-arm goldens are CACHED at `grid/<arm>/gold.uhdm` by `rr80v.sh` because
**Surelog v1.87 segfaults nondeterministically** (~5 runs in 6) on a package
holding a two-deep chain of packed-struct typedefs beside a union chain — the
reason `q1_elemname` was split into `q1a`/`q1b`. That is a golden-producer
instability, out of scope (patching Surelog is out of scope), and it is
recorded here so the next operator does not read it as our crash.

---

## 5. GATES (the verified binary, and r11u80's beside it)

```
build          pristine c56e3f2c141ee7e9a6bb41c9d4e38f8c (compared to the main
               tree, not assumed); r11u80 b1136aebd7f36e4e42a8ea30f23e3f9e
               reproduced bit for bit from a fresh 15ff66f6 worktree
goldens        pristine 23/0, r11u80 23/0, verified 23/0; /bin/false 0/23
u2r            788 CMP_EQUAL / 16 CMP_NOTEQUAL / 67 SLANG_REJECT on BOTH modes
               and ALL THREE binaries — the committed baseline exactly
               vs results/golden_uhdm2rtlil.csv (mode-joined): 0 differing rows,
               every binary, both modes
               pristine vs verified: 0 differing rows; r11u80 vs verified: 0
               byteverify SELFCHECK=1 vs the pristine workdir:
                 r11u80   MOVERS 0/1608 (selfcheck 1607)
                 verified MOVERS 0/1608 (selfcheck 1607)
surelog        see GATES.r11v80.txt (both sweeps run by this verifier, per
               binary, SLANG_UHDM exported per binary, every cmds.txt audited
               by binary PATH, every arm's rc recorded)
census         uhdm2rtlil, both modes, the harness's own discovery and argv,
               the VERIFIED binary with R11U77_CELLDBG=1: 9480 cell rows,
               **0 R11U77HOIST and 0 R11U77DEFNT lines** — the unpacked road
               and the def-view net-type rule are both corpus-invisible there.
               POSITIVE CONTROL, same counter, same binary: this verifier's
               grid fires kinds 5, 6, 7 AND 8 (q5_tdarr alone prints 7 x kind=8)
               and DEFNT MOVED on six of nine arms.
canaudit       audited=29 UNCOVERED=0 FENCE-BREACH=0
results/*.csv  UNTOUCHED
```

---

## 6. RESIDUES THIS VERIFICATION LEAVES (ranked; none is a regression)

1. **R0, unchanged — the PACKAGE's own listing** (`emitPackage`,
   `src/ParamEmit.cpp`, the sister pass's ground). It is the single masking
   head on all 43 arms, which is why every arm's `cmp_rc` and head count is
   identical on all three binaries although 102 object slots converted. Not
   touched here.
2. **A chained UNION typedef, net-declared** (`wire un2_t x [0:1]`,
   `q1a_netchain` q_nun2): golden's element is a `union_var`, ours a
   `logic_net`. Pre-existing, unchanged by both binaries. The one-hop seam
   names the element for the DIRECT spelling and golden changes its CLASS for
   the chain — a face the kind table does not yet model.
3. **A chained LOGIC typedef, net-declared** (`wire w2_t x [0:1]`, q_nw2):
   golden NAMES the element, we leave it bare. Pre-existing and unchanged, but
   it refutes r11u80's stated "a typedef CHAIN is UNNAMED" — that reading is
   right for the struct chain (`sl2_t`, golden bare) and wrong for the logic
   one.
4. **A typedef'd array with a declarator dimension on top** (`arr_t x [0:2]`,
   q5 t_plus / z1 z_tdplus): golden wraps its own `array_var` in a SECOND one.
   Both binaries write nothing. One nested-holder arm away — r11u80's residue 2,
   confirmed.
5. **`var` + a lifetime keyword** (`var static logic`, q3 v_stlog): golden
   stamps `vpiNetType 1`; pristine 36, both patched binaries none. §2c.
6. **A signed NET element** (`wire signed [7:0] x [0:1]`, q6 a_nslog): golden's
   element carries `vpiSigned 1`, ours does not. Pre-existing and unchanged —
   § arrayVarSignedWritten8 is consulted on the variable road only.

---

## 7. How to re-run

```bash
GRID=<this dir>/grid bash rr80v.sh <binary> <tag>        # every arm, both rc values
python3 elem80v.py <dump> uhdmtopModules                 # the element-level reader
python3 tsname80v.py <dump> <section> '<name-rx>'        # holder + typespec NAME
python3 emcmp80v.py <grid> <arm> <section> <tag>         # the conversion ledger
GRID=<this dir>/grid bash ../r11u80repro/sw80.sh <patched> <pristine>   # switches
```

No corpus test is dispatched from this directory; every arm is its own
`dut.sv`, and the four slang-fenced names appear in no file here.
