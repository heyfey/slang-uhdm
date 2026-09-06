# r10earl109 — § `elabPortBoundIntParamTs109`: an elaborated port's own packed bound is folded in a scope that has already moved on

Everything in this directory is **MEASUREMENT ONLY**. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

`Earlgrey_0_1` **testflags** goes from **48 cmp lines / 1 head to 176 / 1** — a
NEW object in a different family, reached deeper in the walk (counts are DEPTH,
not distance). `Earlgrey_0_1` **default** keeps its own earlier head
**byte-identical** while its database moves. Three databases moved: **two by
the law and one by the recorded coin**, and the corpus census scores
**TO-GOLDEN 2 / AWAY-GOLDEN 0 / MOVED-WRONG 0** on surelog and **0 / 0 / 0** on
uhdm2rtlil.

* BASE COMMIT `644e74ee`, branch `auto5h`. Worktree `/tmp/wt_r10earl109`.
* Pristine binary md5 `4240036c187c394c758e629799b3bd1c` — **byte-identical to
  the main tree's own build at `644e74ee`**, so the base is confirmed, not
  assumed. Patched `0cc21f5211296045f6c32efe344fd9a9`. Both frozen `chmod 555`
  at immutable paths **before any sweep**; all **3035** `cmds.txt` audited BY
  BINARY PATH (2981 name the frozen pass binary, **0** name the main-tree binary
  and **0** name the worktree's own `build/`).
* `/tmp/r10earl109.patch` applied to a **FRESH `644e74ee` worktree** with
  `git apply -3` (clean, 0 conflict markers) and rebuilt there produces the
  **BYTE-IDENTICAL** binary, same md5 `0cc21f5211296045f6c32efe344fd9a9` — the
  patch IS the artifact every number below was measured on.
* Production diff: `include/UhdmExporter.h` (one flag, one declaration),
  `src/ModuleEmit.cpp` (one save/set/restore around ONE existing call) and
  `src/TypeEmit.cpp` (one admission test, one arm). `slang` is NOT patched.
  `results/*.csv` were **READ ONLY** and **no row was converted**.
  `GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never
  dispatched and appear in **0** of the 4891 boundary-listed files; they are
  named only inside `canaudit.sh`'s own fence list, which `widerun109.sh` reads
  to build its filter.

---

## 1. THE HEAD, and WHICH FIELD FAILS FIRST — decoded before a line of law

`rowheads.sh` on this pass's **own pristine build**, not carried forward:
`Earlgrey_0_1` **default 31 / 1**, **testflags 48 / 1**. Only testflags is
this pass's; the default head is the pre-existing
`u_pinmux.gen_mio_periph_in[0].data_mux` null that r10earl107 named.

```
LHS (golden)  constant id:729390  usbdev_usbif.sv 54:17-54:21
              |vpiDecompile:6  |vpiSize:32  |UINT:6  |vpiConstType:9
              |vpiTypespec -> ref_typespec (NO fullname) -> int_typespec vpiSigned:1
              |vpiParent -> range 54:16-54:24 -> logic_typespec 54:10-54:24
RHS (ours)    constant id:580709  54:17-54:21
              |vpiDecompile:6  |vpiSize:64  |UINT:6  |vpiConstType:9
                                            and NO typespec at all
```

```systemverilog
usbdev_usbif.sv:12   module usbdev_usbif #(
usbdev_usbif.sv:16     parameter int MaxPktSizeByte = 64,
usbdev_usbif.sv:20     localparam int PktW = $clog2(MaxPktSizeByte) )  // int, 32-bit, 6
usbdev_usbif.sv:50   ( ... output       [3:0]            out_endpoint_o,
usbdev_usbif.sv:53         input  logic [NBufWidth - 1:0] in_buf_i,
usbdev_usbif.sv:54         input  logic [PktW:0]          in_size_i,     <- THE HEAD
usbdev_usbif.sv:55         input  logic [NEndpoints-1:0]  in_stall_i, ... );
usbdev_usbif.sv:342    usbdev_linkstate u_usbdev_linkstate ( ... );
```

**THE JUDGE, read out of the generated `Compare`s and not assumed**
(`~/git-repos/UHDM/build/generated/src/{BaseClass,expr,constant,range}.cpp` plus
`~/.local/include/uhdm/BaseClass.h`'s SafeCompare overloads):

| order | reader | field | here |
|---|---|---|---|
| 1–3 | `BaseClass::Compare` | `VpiType`, `VpiName`, `VpiDefName` | all equal |
| 4 | `expr::Compare` | `VpiDecompile` | `"6"` on both |
| 5 | `expr::Compare` | **`VpiSize`** | **32 vs 64 — THE FIRST FAILURE** |
| 6 | `expr::Compare` | `Typespec` | an `int_typespec` ref vs `<null>` |
| 7 | `constant::Compare` | `VpiConstType` | 9 on both |

No location is read anywhere — not `VpiFile`, not the line, not the column.
`range::Compare` reads `VpiSize`, then `Left_expr`, then `Right_expr`, which is
why the walk reaches this bound at all: the RIGHT bound (`0`) is size 64 on
both sides and equal. The **sibling** bounds in the very same port listing —
`[3:0]` at :50, `[NBufWidth - 1:0]` at :53, `[NEndpoints-1:0]` at :55 — are
size 64 with no typespec **on both sides**, so the rule is not "every range
bound".

### The owner (`own109.cpp`, `OWNER.r10earl109.txt`)

The dump's parent chain stops at a bare `logic_typespec`, so the earlier
owner-finders (which walk `Operands` / selects / `cont_assign` and
`param_assign` edges) name nothing here. `own109` walks three edges they never
look at: every `range` whose `Left_expr`/`Right_expr` IS the target, every
object whose `Ranges()` VECTOR holds that range, and **every `ref_typespec`
whose `Actual_typespec()` is that typespec** — the last one is what matters,
because no generated `Compare` reads `VpiParent` (RESUME.md §9), so "who owns
it" has to be enumerated rather than read off the dump.

```
golden constant#729390 <- range#729389 Left_expr
                       <- logic_typespec#729394 Ranges[0]
                       <- ref_typespec#1576416
                          "work@top_earlgrey.u_usbdev.usbdev_impl.in_size_i"
                       <- port#1576412 in_size_i 54:36-54:45
                       <- module_inst work@top_earlgrey.u_usbdev.usbdev_impl
                       <- module_inst work@top_earlgrey.u_usbdev
                       <- module_inst work@top_earlgrey
ours   constant#580709 <- the IDENTICAL chain, object for object
```

**The owner is the ELABORATED INSTANCE PORT's own `vpiTypedef` typespec** — not
the parameter, and **not the elaborated NET of the same signal, whose copy of
the very same written bound is already exactly golden** (size 32, `UINT:6`,
ct 9, a ts ref to a signed `int_typespec`, differing from golden only in the
ref's `VpiFullName`, which no `Compare` reads). Golden's port copy is the same
payload with a BARE ref. Our side has two `ref_typespec` holders where golden
has one — a pre-existing duplicate-port residue, likewise invisible to the
judge.

---

## 2. OUR OBJECT'S ORIGIN — measured at the branch, not hypothesised

`R10E24_BNDDBG=1` (r10earl24's committed env-gated trace at this very branch)
plus a temporary scope probe, on the corpus command line itself. The bound is
folded TWICE for this one declaration:

```
sym=in_size_i bound=PktW  cs=usbdev_usbif     own="…usbdev_impl.in_size_i"
                          par=PktW bp=1 sz=32     <- the ELAB NET copy
sym=in_size_i bound=PktW  cs=usbdev_linkstate own=""
                          par=-    bp=0 sz=64     <- the ELAB PORT copy
```

`currentScope` is assigned in exactly two places — `emitModuleDef`
(`ModuleEmit.cpp:591`) and `emitModuleDefPorts` (`:2457`) — and **never inside
`emitInstance`** (RESUME.md §9, earl57 R3). An instance's elaborated port
typespecs are built **after its children have been walked**, so by then
`currentScope` names the last child DEFINITION's body: here `usbdev_linkstate`,
which `usbdev_usbif` instantiates at `:342`. `Expression::bind` in that foreign
body resolves nothing, `boundParam` and `elabModPar` both come back null, and
the fold falls out of the arm chain at the unsized 64. `boundOwnerFullName` is
empty at that site too — it is set only around the net/var build — so no ts ref
is minted either. **Both halves of the head are that one stale scope**, and the
elaborated NET of the same signal, built BEFORE the children, is the control
that proves it.

`g1_home109` (one child) reproduces only the typespec half — its
`currentScope` happens still to be the right body. `g2_stale109` adds the one
thing the corpus has and `g1` lacks, a child instantiation inside the module
that declares the port, and reproduces the head **exactly: 48 cmp lines, one
head, the same two fields**.

---

## 3. THE LAW

> **§ `elabPortBoundIntParamTs109`** — on an **ELABORATED instance PORT's own
> `vpiTypedef` typespec**, a packed-dimension bound written as a **BARE
> parameter name** is resolved in **the port's own declaring scope**, not in
> `currentScope`, and folds to that parameter's declared width with a **BARE
> (fullname-less), LOCATION-LESS `ref_typespec` to a SIGNED `int_typespec`** —
> **when, and only when, the parameter is a non-overridden parameter of that
> instance body written with the `int` keyword and SIGNED, whose initializer is
> not a based literal.**  The **SIZE and the ts ref are all this law moves**:
> the `INT`/ct 7 vs `UINT`/ct 9 pick stays § `defNetBoundPkgIntEnc`'s, read off
> the parameter's own `paramIntEnc` entry (r10v109 — see §10).
>
> Golden's elaborated PORT bound and its elaborated NET bound carry the same
> compare-visible payload in every cell of the grid; this arm is the port half
> of the one written kind whose net half this tree already writes exactly.

### 3.1 STATED GATE == CODE GATE

| stated clause | code |
|---|---|
| only the ELABORATED instance port's own typespec | `elabPortBoundScope109` is set and restored around the ONE `makeTypespec` call at `ModuleEmit.cpp` ~11437; every other typespec builder leaves it null and `elabPortIntBoundParam109` returns null immediately |
| resolved in the PORT's own declaring scope | `Lookup::unqualified(*elabPortBoundScope109, nm109)`, with the flag set to `internal->getParentScope()` |
| a BARE parameter name | `bsyn->kind == syntax::SyntaxKind::IdentifierName` |
| of THAT instance body | `psc109->asSymbol().kind == SymbolKind::InstanceBody` |
| non-overridden | `!isOverriddenParam(p109)` |
| the `int` keyword | `ct109.as<PredefinedIntegerType>().integerKind == PredefinedIntegerType::Int` plus a non-`ImplicitType` type syntax |
| and SIGNED | `p109.getType().isSigned()` |
| initializer not a based literal | the `IntegerLiteral` + `'` refusal `pkgVarDimBoundEnc82` already makes |
| the folded shape | `VpiSize(width)`, a `ref_typespec` with NO `VpiFullName` and NO `setLoc`, over an `int_typespec` with `VpiSigned(true)` and no location; the const type / value encoding is `paramIntEnc`'s (`vpiIntConst`+`INT:` when marked, `vpiUIntConst`+`UINT:` otherwise) — r10v109, §10 |

The `§` is greppable and appears in exactly four places: the flag and the
declaration (`include/UhdmExporter.h`), the call site (`src/ModuleEmit.cpp`) and
the helper + arm (`src/TypeEmit.cpp`).

### 3.2 It does NOT disturb earl104's mint or earl106's adjust

The brief asked to stop and report if the fix wanted them. It does not touch
either. § `replFoldElabSelRead104` is a `param_assign` **Rhs** question about a
folded replication's minted `int_typespec` and is decided in `ParamEmit`;
§ `genCaCastFoldAdjustSize106` is a gen-scope **`cont_assign` Rhs** question
decided in `ModuleEmit`. This law is a **range-bound** question inside
`makeTypespec`, gated on a flag only the elaborated-port call site sets. All
three of r10earl104/105/106's committed arms are byte-identical on both
binaries in the wide boundary.

---

## 4. THE GRID — and the two readings it REFUTED

`grid109.sh` builds a Surelog golden for each arm in both views, runs both
frozen binaries, and joins a **compare-visible, carrier-keyed, DEDUPED** census
of every range bound any `ref_typespec` reaches (`cen109` + `score109.py`).
Full table: `GRID.r10earl109.txt`.

| arm | axis |
|---|---|
| `g1_home109` | the corpus shape reduced — one child, so `currentScope` is still right and only the TYPESPEC half shows |
| `g2_stale109` | the corpus shape with its child instantiation — **48/1, the head exactly** |
| `g3_kind109` | 18 WRITTEN KINDS on one port listing: `int`, `int signed`, `int unsigned`, `int` with an `8'd6` init, `logic [7:0]`, `byte`, `shortint`, untyped literal, untyped computed, package `int`, package untyped, OVERRIDDEN `int`, `<p>-1`, `<p>+1`, a literal, `$clog2(...)`, the bound on the RIGHT |
| `g4_type109` | 12 PARAMETER TYPES, each on a PORT and on a NET of the same width — the arm that says which types our net half already gets right |
| `g5_neg109` | the MUST-NOT-MOVE half: overridden, package, `$unit`, named typedef, gen-scope localparam, struct member, unpacked parameter dimension, instance array, interface |
| `g6_carrier109` | 8 CARRIERS for the law's own written bound: input / output / inout / two packed dims both orders / packed+unpacked / a `var` port / a struct-typed port whose member dimension is built RECURSIVELY under the same call |

**Two readings were written down and then refuted by measurement, both by the
WIDE BOUNDARY on an EARLIER pass's arm — not by the corpus and not by this
pass's first four arms.**

1. **"the `int` keyword decides"** — refuted by `r10earl82repro/g5_enc82.sv`
   `p_NOZ`, `parameter int unsigned NOZ = 8`: golden's port bound there is size
   32 / `UINT:8` / ct 9 with **NO ts ref**, which is what we already wrote, and
   a signedness-blind gate turned a RIGHT cell WRONG (**AWAY-GOLDEN 2**, both
   instances, both views). `g3_kind109` `k_ius_i` carries the case here now.
2. **"any `int` parameter's width may be lent"** — refuted by the same file's
   `p_NOD`, `parameter int NOD = 8'd8`: golden folds it at the LITERAL's own
   width and encoding, size **8** / `INT:8` / **ct 7**, so lending it the ts ref
   moved a wrong cell to a differently wrong one (**STILL-WRONG 2**). The fix is
   the same based-literal refusal § `rangeBoundStoredWidth82`'s
   `pkgVarDimBoundEnc82` already makes, for the same reason and on the same
   witness family. `g3_kind109` `k_ibl_i` carries it here now.

With both gates the six arms score, over both views:

```
TO-GOLDEN 30   AWAY-GOLDEN 0   STILL-WRONG 0   ONLY-GOLDEN 8   ONLY-OURS 8
g1_home109 1   g2_stale109 1   g3_kind109 3   g4_type109 2   g5_neg109 1   g6_carrier109 7   (per view)
```

and `g1_home109`, `g2_stale109` and `g6_carrier109` go **to 0 cmp lines / 0
heads, EQUAL** in both views. `g5_neg109` moves exactly ONE cell — its own
deliberate `localparam int LOC109` control — and nothing else: the overridden,
package, `$unit`, typedef, gen-scope, struct-member, unpacked-parameter-dim,
instance-array and interface shapes are all untouched.

### The GOLDEN matrix the grid measured (both views, PORT and NET agree in golden)

| written bound | golden's folded bound |
|---|---|
| bare `int` / `int signed` param | sz 32, `UINT`, ct 9, **ts SIGNED `int_typespec`** |
| bare `int unsigned` param | sz 32, `UINT`, ct 9, ts NONE |
| bare `int` param initialised `8'd6` | sz 8, `INT`, ct 7, ts SIGNED `int_typespec` |
| bare `integer` param | sz 32, `UINT`, ct 9, ts NONE |
| bare `shortint` / `byte` param | sz 16 / 8, `UINT`, ct 9, ts NONE |
| bare `bit` / `logic` param | sz 1, `BIN`, ct 3, ts NONE |
| bare `bit [7:0]` / `logic [15:0]` param | sz 8 / 16, `INT`, ct 7, ts NONE |
| bare `longint` param | sz 64, `UINT`, ct 9, ts NONE (we already match) |
| bare untyped LITERAL-init param | sz 32, `UINT`, ct 9, ts NONE |
| bare untyped COMPUTED-init param | sz 64 (we already match) |
| bare PACKAGE param | sz 32, `UINT`, ct 9, ts NONE |
| `<p>-<lit>`, `<p>+<lit>`, a literal, `$clog2(...)` | 64 on both sides |

Only the first row is this law's; the rest are R1/R2 below.

---

## 5. THE MOVER PREDICTION (made from PRISTINE databases only)

`cen109` emits one ROW per range bound of every typespec a `ref_typespec`
names, **keyed** by the carrier's kind, that ref's own fullname and the
carrier's span, the typespec kind, the dimension index and the side; the
**payload is compare-visible only** (kind, `VpiName`, `VpiDecompile`, `VpiSize`,
`VpiValue`, the typespec's kind and signedness, `VpiConstType`, a `ref_obj`'s
`Actual_group` kind, an operation's opType and operand count) and the bound's
own span rides in the KEY, never the payload. Two calibration failures are
recorded in the code: keying on the carrier's FILE joined nothing (our
typespecs carry an empty `VpiFile` where golden carries the path — BOTH-SAME 0,
ONLY-GOLDEN 270), and keying on the carrier's NAME merged the def-view port
with its elaborated twin and hid the flip behind a multiplicity difference.
The join is DEDUPED per key for the same reason RESUME.md §9 gives.

Run over BOTH corpora on the PRISTINE binary **before the law was written**
(`CEN_sl_pris.txt`, `CEN_u2r_pris.txt`; the full prediction is `PREDICT_R0.txt`):

```
uhdm2rtlil   970 databases joined.  WHOLE CENSUS  BOTH-SAME 153632  FLIP 44
                                    ONLY-GOLDEN 1562  ONLY-OURS 388
             THE LAW'S CELLS: ZERO.  Nothing to fix, nothing to break — and the
             153632-row agreement is the instrument's calibration.

surelog      631 databases joined.  WHOLE CENSUS  BOTH-SAME 309996  FLIP 18
                                    ONLY-GOLDEN 20752  ONLY-OURS 6300
             THE LAW'S CELLS: TWO, and they are
                default__Earlgrey_0_1     port@work@top_earlgrey.u_usbdev.
                testflags__Earlgrey_0_1   usbdev_impl.in_size_i   54:17-54:21
             The other SIXTEEN flips are named and are NOT this family:
                MiniAmiq / SeqDriver  the io_decl `UVM_LARGE_STRING` bound whose
                  ref_obj Actual_group we bind and golden leaves unbound   (4)
                UnionCast  typespec_member bounds whose golden VALUE keeps the
                  written leading zero (`UINT:00` vs our `UINT:0`)        (12)
```

**PREDICTION: EXACTLY TWO DATABASES MOVE — `Earlgrey_0_1` default and
`Earlgrey_0_1` testflags. uhdm2rtlil: ZERO movers in either mode.**

---

## 6. WHAT ACTUALLY MOVED

`byteverify.sh SELFCHECK=1`, patched vs this pass's OWN pristine sweep, both
binaries frozen:

```
uhdm2rtlil  MOVERS 0 / 1358    <- as predicted (PATH_SETS_IDENTICAL,
                                  selfcheck 1357/1358 flagged)
surelog     MOVERS 3 /  956    <- the two predicted Earlgrey databases, plus
    ./default/Earlgrey_0_1        Scoreboard/default, the KNOWN svunit_pkg
    ./testflags/Earlgrey_0_1      vpiTaskFunc order coin
    ./default/Scoreboard       (PATH_SETS_IDENTICAL, selfcheck 955/956 flagged)
```

**Each attributed line by line** (`ATTRIB.r10earl109.txt`, workdir-normalised
whole-dump diffs, 244 MB and 360 MB):

* `Earlgrey_0_1/default` — **10 changed lines, unsorted AND order-blind**.
* `Earlgrey_0_1/testflags` — **10 changed lines, unsorted AND order-blind**.
  Both are the one cell and nothing else:

  ```
  <       |vpiSize:64                    >       |vpiSize:32
                                         >       |vpiTypespec:
                                         >       \_ref_typespec:
                                         >         |vpiParent:
                                         >         \_constant: , line:54:17, endln:54:21
                                         >         |vpiActual:
                                         >         \_int_typespec:
                                         > \_int_typespec:
                                         >   |vpiSigned:1
  ```
* `Scoreboard/default` — **92 lines unsorted, 0 ORDER-BLIND**: the documented
  ~50/50 `vpiTaskFunc` list flip (RESUME.md §9), not a content move. Its head
  log is byte-identical before and after.

### The census re-scored over the SAME fixed universe

`censcore109.py` joins golden × pristine × patched per database
(`CEN_sl_score.txt`, `CEN_u2r_score.txt`):

```
surelog     TO-GOLDEN 2   AWAY-GOLDEN 0  STILL-WRONG 0  MOVED-WRONG 0  REMOVED 0
            census movers: default__Earlgrey_0_1 1, testflags__Earlgrey_0_1 1
            WHOLE CENSUS  BOTH-SAME 309996   FLIP 18 -> 16
uhdm2rtlil  TO-GOLDEN 0   AWAY-GOLDEN 0  STILL-WRONG 0  MOVED-WRONG 0  REMOVED 0
            WHOLE CENSUS  BOTH-SAME 153632  FLIP 44 -> 44
```

**HEADS** (`rowheads.sh`, before → after): SeqDriver 33/33 both modes,
SimpleUVM 52/52, Scoreboard/default 95/95, MiniAmiq 29/29, BuildUVMPkg 52/52,
Rggen/default 0/0, Earlgrey/default 31/31 — **every one of those head logs is
byte-identical**, including Earlgrey/default whose database moved. Only
`Earlgrey_0_1/testflags` changed: **48 → 176, one head**, and it is a NEW
object in a different family (§8 R0).

---

## 7. THE GATES

| gate | result |
|---|---|
| build both, md5 | pristine `4240036c187c394c758e629799b3bd1c` (= the main tree at `644e74ee`), patched `0cc21f5211296045f6c32efe344fd9a9` |
| golden dumps | **23 PASS / 0 FAIL** patched (and 23/0 pristine); negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| u2r status, both modes | CMP_EQUAL **679** / SLANG_REJECT **50** / SURELOG_FAIL **2**, unchanged |
| surelog status histogram | CMP_EQUAL 937 / CMP_NOTEQUAL 19 / DEFERRED 10 / NO_DATABASE 3 / NO_UHDM 1 / SLANG_REJECT 567 / SURELOG_FAIL 48 / TIMEOUT 1 / UNTRANSLATABLE 2 — **identical pristine and patched**, so no rc=139 hid as a SLANG_REJECT |
| `ct8rows` u2r tf vs the committed baseline | **PASS — every row byte-identical** |
| `ct8rows` u2r tf / def vs this pass's own pristine | **PASS, PASS** |
| `ct8rows` surelog vs the committed baseline AND vs own pristine | **PASS — 0 differing rows over 1588. NO ROW CONVERTED** |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1358** |
| `byteverify SELFCHECK=1` surelog | **MOVERS 3 / 956** = the 2 predicted + the attributed coin |
| canaries | surelog `ok=52 changed=0 absent=0`, u2r `ok=8 changed=0 absent=0` |
| `ctcan2` | PASS (surelog, `EXPECT_UNKNOWN=1`) and PASS (u2r, `EXPECT_UNKNOWN=6`) |
| `canaudit.sh canaries.sh ctcan2.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical in both modes; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** — all 10 pins SAME |
| `cmds.txt` audit | 3035 per side; **0 name the main-tree binary, 0 name the worktree build** |
| GOLDEN_DEFER | UNSET throughout |
| `results/*.csv` | READ ONLY — nothing edited, no row converted |

### The wide boundary — and the two regressions only it could see

`widerun109.sh` + `wide109.sh`: every `.sv` / `.v` under a COPY of `tools/probe`
**at any depth**, both views, both frozen binaries, workdir-normalised whole-dump
byte compare. The file list is read on **fd 3** with children `</dev/null`, and
`PROCESSED` is asserted against `LISTED`. The fence filter reads the four names
out of `canaudit.sh`'s own `FENCED=` line, so it cannot drift from the audit and
the names are not spelled here.

```
LISTED=4891   PROCESSED=4891   identical=9382   DIFFERING=20   no_output=380
FENCED_REMOVED=0   (none of the 4891 sources matches a fenced name)
rc by side    A: 0x9013  3x364  4x389  139x16
              B: 0x9013  3x364  4x389  139x16      symmetric, ASYMMETRY 0
rc=139 signal set A == set B, file for file (16 each, pre-existing on BOTH)
```

The 20 differing cells resolve completely:

* **12 = this pass's own six arms, both views** — the gate's POSITIVE CONTROL:
  a boundary that reaches nothing prints green, and this one demonstrably sees
  the law.
* **4 = `r10earl82repro/g5_enc82.sv` and `r10earl_repro/vq.sv`, both views** —
  earlier passes' arms that carry this law's written shape. Judged against
  their own Surelog goldens: **TO-GOLDEN 4 and TO-GOLDEN 1, AWAY-GOLDEN 0,
  STILL-WRONG 0.** These are the cells that convicted the first two drafts of
  the gate (§4), and they are the reason the law has a signedness clause and a
  based-literal clause at all.
* **4 = `r10buvm22repro/g22.sv` and `r10uvm154repro/l154_noenum.sv`, both
  views** — NOT this law. Both differ only in a `UINT:225xxxxx` constant that
  sits **BELOW `\_weaklyReferenced:`** in the dump (line 6471 and line 646
  respectively), which RESUME.md §9 records as unreachable to the judge, and
  the two values are exactly **4096 apart**. `r10uvm154repro`'s own README §7
  documents this file as a deliberate **LAYOUT PROOF** — "NOT an arm" — for
  precisely this binary-layout artifact. `l154_noenum.sv` contains **no module
  port and no child instance at all**, so `elabPortBoundScope109` is never set
  while compiling it and the law's code provably cannot execute. `uhdm-cmp`
  agrees: both arms are **unchanged** (`g22` 3438/1 → 3438/1, `l154_noenum`
  17/1 → 17/1).

Every committed r10earl45–108 arm, every uvm / buvm arm, r10earl59's
`genCaNestedModuleLhsOpRhsBinds59` binder mirror, r10earl102's unpacked-dim
window, r10earl104/105/106's clone, adjust and cast windows, the port
`high_conn` arms and every subdirectory arm are byte-identical.

---

## 8. RESIDUES, and R0

* **R0 — THE NEXT HEAD IS NAMED AND MEASURED.** `Earlgrey_0_1/testflags`,
  **176 cmp lines, one head**, a different family — a `hier_path` whose
  `Path_elems` size differs (RESUME.md §9's buvm14 shape):

  ```
  LHS (golden)  hier_path (tl_h_i[i].a_source[0+:8 - 2])  id:1615258
                xbar_main.sv 97:7-97:41
                |vpiParent -> operation 96:25-99:6
                |vpiActual -> bit_select (tl_h_i[i]) 97:7-97:13
                              |vpiActual -> array_var
                                 work@top_earlgrey.u_xbar_main.u_sm1_17.tl_h_i
                              |vpiIndex  -> ref_obj i -> parameter
                                 …u_sm1_17.gen_host_fifo[0].i
                |vpiActual -> indexed_part_select 97:17-97:40
  ```

  `Earlgrey_0_1/default` keeps its own pre-existing head, the
  `u_pinmux.gen_mio_periph_in[0].data_mux` null r10earl107 named, at 31 lines —
  unchanged and byte-identical. Both head logs are committed
  (`HEAD_AFTER_Earlgrey_*.cmp`).

* **R1 — the ELAB NET copy's own encoding for every parameter type that is not
  `int`.** `g4_type109` measures twelve types on a net and a port side by side:
  our net copy mints an `int_typespec` ref where golden has none (`integer`,
  `shortint`, `byte`, `longint`, `bit`, `logic`, `bit [7:0]`, `logic [15:0]`),
  and writes `UINT`/ct 9 where golden writes `INT`/ct 7 (`bit [7:0]`,
  `logic [15:0]`) or `BIN`/ct 3 (`bit`, `logic`). 24 flips per view, and this
  law deliberately does not reach any of them: because the net half is wrong
  there, giving the port half the same answer would be MOVED-WRONG. Its own
  law, its own census.

* **R2 — the ELAB PORT copy for the non-`int` kinds.** The mirror of R1 on the
  port side: `g3_kind109` `k_log_i` / `k_byt_i` / `k_sho_i` / `k_pki_i` /
  `k_unt_i` / `k_ius_i` / `k_ibl_i` and `g4_type109`'s ten non-`int` ports stay
  at the unsized 64 with no typespec where golden has the parameter's width.
  ZERO corpus cells (the corpus census finds none), 13 arm flips per view.
  These become reachable the moment R1 is solved, and not before.

* **R3 — an INSTANCE-ARRAY element's port typespec.** `sharedTypespec(…,
  elemPortTs, …)` supplies `pts` before the law's call site is reached, so an
  instance array's element ports never enter it. `g5_neg109`'s `u_arr [0:1]`
  carries the position; its bound names an OVERRIDDEN parameter, so it is
  doubly excluded today. ZERO corpus cells.

* **R4 — a struct MEMBER's packed dimension under an elaborated port.**
  `g6_carrier109`'s `g6_st109` gives a port a struct type whose member bound is
  the law's own written shape. Golden keeps that member bound a **symbolic
  `ref_obj`** in both views and so do we — BOTH-SAME, and the law correctly
  never enters (a `ref_obj` is not a folded constant). The position is tested,
  not assumed.

* **R5 — our duplicate elaborated `port` object.** `own109` finds TWO
  `ref_typespec` holders for the head's typespec on our side and ONE on
  golden's, both with the same fullname. It is a parenting residue of another
  family, unchanged by this pass, and invisible to the judge — no generated
  `Compare` reads `VpiParent`, and the port vectors themselves compare equal.

---

## 9. FILE MAP

| file | what it is |
|---|---|
| `PREDICT_R0.txt` | the head decode, the owner, our object's measured ORIGIN, the Surelog fold matrix and the mover prediction, written from PRISTINE databases |
| `own109.cpp` | the owner-finder for a RANGE BOUND: range holders, `Ranges()` holders, and every `ref_typespec` pointing at the typespec |
| `cen109.cpp`, `cenrun109.sh` | the range-bound census and its corpus driver (LISTED / PROCESSED / SKIP-NOFILE / CENRC all asserted) |
| `score109.py` | the three-way ARM scorer (TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / UNMOVED-WRONG), deduped per key |
| `censcore109.py` | the three-way CORPUS scorer, plus the law's-cells finder used for the prediction |
| `g1_home109.sv` … `g6_carrier109.sv`, `TOPS.txt`, `grid109.sh` | the six arms and their driver |
| `GRID.r10earl109.txt` | the grid table, the three-way scores and every moved cell with its golden |
| `CEN_{sl,u2r}_pris.txt`, `CEN_{sl,u2r}_score.txt` | the corpus census before, and the three-way score after |
| `OWNER.r10earl109.txt` | `own109` on both sides of the corpus head |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the pristine and patched head logs |
| `ATTRIB.r10earl109.txt` | the order-blind whole-dump attribution of all three movers |
| `BOUNDARY_WIDE.*`, `wide109.sh`, `widerun109.sh` | the wide boundary: list, tally, rc histogram, rc by side, signals, and the 20 differing cells |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the shared gate instruments, carried so this directory reproduces on its own |

---

## 10. VERIFIER'S FIX (r10v109) — the ENCODING is not part of the SIZE question

The first revision of this arm wrote `vpiUIntConst` / `UINT:<digits>`
unconditionally beside the size and the ts ref.  Two of the pass's own axes
never reached it — every `int` parameter in `g1`–`g6` is initialised by a plain
literal or by `$clog2`, and `analyzeParamEnc` marks neither — so the arms
scored clean while the encoding was being overwritten.

**MEASURED** (`tools/probe/r10v109repro/vA_enc109.sv`, an `int` localparam per
`paramIntEnc` form on an elaborated port, in a STALE-scope module and in a
HOME module side by side, both views):

| written init | pristine | first revision | golden |
|---|---|---|---|
| `MaxA/8` (`/`) HOME | sz 64, `INT:8`, **ct 7** | sz 32, `UINT:8`, **ct 9** | sz 32, `INT:8`, **ct 7**, ts SIGNED |
| `MaxA%58` (`%`) HOME | sz 64, `INT:6`, ct 7 | sz 32, `UINT:6`, ct 9 | sz 32, `INT:6`, ct 7, ts SIGNED |
| `2**3` (signed `**`) HOME | sz 64, `INT:8`, ct 7 | sz 32, `UINT:8`, ct 9 | sz 32, `INT:8`, ct 7, ts SIGNED |
| `MaxA-58` (`X-1` form) HOME | sz 64, `INT:6`, ct 7 | sz 32, `UINT:6`, ct 9 | sz 32, `INT:6`, ct 7, ts SIGNED |
| `2 - 3` → **−1** (arm C) | sz 64, `UINT:-1`, ct 9 | sz 32, `UINT:-1`, ct 9 | sz 32, `INT:-1`, ct 7, ts SIGNED |

`VpiConstType` **is** read by `constant::Compare`, so the four HOME rows are a
right field overwritten with a wrong one; none of them was EQUAL before (the
size failed first), so no database flips, but the cell moved from one wrong
shape to a differently wrong one — the same MOVED-WRONG the based-literal
clause exists to prevent.

**FIX** (`src/TypeEmit.cpp`, inside this arm only): read the encoding off
`paramIntEnc[ip109]`, exactly as § `defNetBoundPkgIntEnc` (`TypeEmit.cpp` ~501)
already does for a package parameter's bound.  Nothing else changes.

**RESULT.** `vA`/`vB`/`vC`/`vD` score **TO-GOLDEN 124 / AWAY-GOLDEN 0 /
STILL-WRONG 4** over both views (before the fix: 96 / 0 / 28 on `vA`+`vB`+`vC`).
The six arms above are **unchanged at TO-GOLDEN 30 / AWAY 0 / STILL 0**, the
wide boundary's differing set is **the same 20 cells**, and the corpus is
**byte-identical to the first revision on every one of the 956 surelog and 1358
u2r databases** — the corpus head's `localparam int PktW = $clog2(...)` is a
SYSTEM CALL, which `analyzeParamEnc` does not mark, so it keeps `UINT` / ct 9.

**R6 (new residue, PRE-EXISTING, not this pass's).** `analyzeParamEnc` marks
`/`, `%`, a signed `**` and the `X-1` SUBTRACT form, but **not `*` and not
`+`**: `localparam int M = 3 * 2` reads golden `INT:6` / ct 7 and both binaries
write `UINT:6` / ct 9 (`vA_enc109` `b_mul_i` / `a_mul_i`, the 4 STILL-WRONG
cells above; pristine is wrong there too).  That is § `defNetBoundPkgIntEnc`'s
own encoding rule and belongs to its own pass — ZERO corpus cells today.
